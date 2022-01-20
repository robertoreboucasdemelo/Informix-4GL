#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd06g00                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........:                                                            #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datmligacao          #
# ........................................................................... #
# DESENVOLVIMENTO: Priscila Staingel                                          #
# LIBERACAO......: 15/01/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- --------------------------------------#
# 05/04/2007 Roberto Melo               Inclusao da funcao                    #
#                                       ctd06g00_ligacao_emp()                #
#----------- --------------  ---------- --------------------------------------#
# 18/09/2007 Luciano, Meta   psi211982  Inclusao tratamento nivel_retorno= 2  #
#                                       na funcao ctd06g00_ligacao_emp()      # 
#-----------------------------------------------------------------------------#

#utilizar módulo para criar funções que acessam a tabela datmligacao

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_ctd06g00_prep smallint

#---------------------------#
function ctd06g00_prepare()
#---------------------------#

   define l_sql_stmt  char(1000)

   let l_sql_stmt = " select c24astcod, c24funmat, lignum from datmligacao ",
                    " where atdsrvnum = ? ",
                    " and atdsrvano   = ? ",
                    " and lignum in (select min(lignum) from datmligacao ",
                                   " where atdsrvnum = ? ",
                                   " and atdsrvano   = ?) "

   prepare pctd06g00001 from l_sql_stmt
   declare cctd06g00001 cursor for pctd06g00001

   let l_sql_stmt = " select c24astcod from datmligacao ",
                    " where atdsrvnum = ? ",
                    " and atdsrvano   = ? ",
                    " and c24astcod   = ? "

   prepare pctd06g00002 from l_sql_stmt
   declare cctd06g00002 cursor for pctd06g00002
     
   let l_sql_stmt = ' select ciaempcod, ligcvntip, c24astcod, c24soltipcod, c24solnom, c24soltip ',
                    ' from datmligacao ',
                    ' where lignum = ? '

   prepare pctd06g00003 from l_sql_stmt
   declare cctd06g00003 cursor for pctd06g00003

   let m_ctd06g00_prep = true

end function

#------- Obtem dados da primeira ligacao do servico --------------------------#
function ctd06g00_pri_ligacao(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param         record
          nivel_retorno    smallint
         ,atdsrvnum        like datmservico.atdsrvnum
         ,atdsrvano        like datmservico.atdsrvano
   end record

   define l_resultado        smallint
         ,l_mensagem         char(60)
         ,l_c24astcod        like datmligacao.c24astcod
         ,l_c24funmat        like datmligacao.c24funmat
         ,l_lignum           like datmligacao.lignum   

   if m_ctd06g00_prep is null or
      m_ctd06g00_prep <> true then
      call ctd06g00_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null

   let l_c24astcod  = null
   let l_c24funmat  = null
   let l_lignum     = null

   open cctd06g00001 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.atdsrvnum
                          ,lr_param.atdsrvano

   whenever error continue
   fetch cctd06g00001 into l_c24astcod, l_c24funmat, l_lignum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Dados do servico nao encontrado"
      else
         let l_resultado = 3
         let l_mensagem = "Erro em ccts10g06001: ", sqlca.sqlcode
      end if
   end if

   close cctd06g00001

   case lr_param.nivel_retorno
        when 1
             return l_resultado, l_mensagem, l_c24astcod
        when 2
             return l_resultado, l_mensagem, l_c24funmat
        when 3
             return l_resultado, l_mensagem, l_lignum
   end case

end function

#-- Verifica se o servico tem ligacao referente a um determinado assunto -----#
function ctd06g00_ligacao_ass(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param         record
          atdsrvnum        like datmservico.atdsrvnum
         ,atdsrvano        like datmservico.atdsrvano
         ,c24astcod        like datmligacao.c24astcod
   end record

   define l_resultado        smallint
         ,l_mensagem         char(60)

   if m_ctd06g00_prep is null or
      m_ctd06g00_prep <> true then
      call ctd06g00_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null

   open cctd06g00002 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.c24astcod

   whenever error continue
   fetch cctd06g00002
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao tem ligacao de ", lr_param.c24astcod,
                          " para o servico"
      else
         let l_resultado = 3
         let l_mensagem = "Erro em ccts10g06001: ", sqlca.sqlcode
      end if
   end if

   close cctd06g00002
   return l_resultado, l_mensagem

end function

#-- Recupera a Empresa de uma determinada ligacao-----#
function ctd06g00_ligacao_emp(lr_param)
#-----------------------------------------------------------------------------#

  define lr_param         record
            nivel_retorno    smallint
           ,lignum           like datmligacao.lignum
  
  end record
  
  define lr_retorno  record
            resultado        smallint
           ,mensagem         char(60)
           ,ciaempcod        like datmligacao.ciaempcod
           ,ligcvntip        like datmligacao.ligcvntip   
           ,c24astcod        like datmligacao.c24astcod   
           ,c24soltipcod     like datmligacao.c24soltipcod
           ,c24solnom        like datmligacao.c24solnom      
           ,c24soltip        like datmligacao.c24soltip      
  end record

  if m_ctd06g00_prep is null or
     m_ctd06g00_prep <> true then
     call ctd06g00_prepare()
  end if

  initialize lr_retorno to null
  let lr_retorno.resultado  = 1

  open cctd06g00003 using lr_param.lignum

  whenever error continue
  fetch cctd06g00003 into lr_retorno.ciaempcod
                         ,lr_retorno.ligcvntip 
                         ,lr_retorno.c24astcod 
                         ,lr_retorno.c24soltipcod
                         ,lr_retorno.c24solnom
                         ,lr_retorno.c24soltip
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem = "Ligacao " , lr_param.lignum , " Inexistente"
     else
        let lr_retorno.resultado = 3
        let lr_retorno.mensagem = "Erro em ccts10g06003: ", sqlca.sqlcode
     end if
  end if

  close cctd06g00003

  case lr_param.nivel_retorno
       when 1
           return lr_retorno.resultado, lr_retorno.mensagem,  lr_retorno.ciaempcod
       when 2
           return lr_retorno.resultado, lr_retorno.mensagem,  lr_retorno.ciaempcod,
                  lr_retorno.ligcvntip, lr_retorno.c24astcod, lr_retorno.c24soltipcod,
                  lr_retorno.c24solnom, lr_retorno.c24soltip 
       when 3
           return lr_retorno.resultado, lr_retorno.mensagem,  
                  lr_retorno.ligcvntip, lr_retorno.c24astcod
  end case

end function
