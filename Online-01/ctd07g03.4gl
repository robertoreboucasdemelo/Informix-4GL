#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd07g03                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........:                                                            #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datmlcl              #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 09/02/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- --------------------------------------#
#-----------------------------------------------------------------------------#

#utilizar módulo para criar funções que acessam a tabela datmlcl

globals  "/homedsa/projetos/geral/globals/glct.4gl"  

define m_ctd07g03_prep smallint

#---------------------------#
function ctd07g03_prepare()
#---------------------------#

   define l_sql_stmt  char(1000)

   let l_sql_stmt = " select cidnom, ufdcod, lclltt, lcllgt ",
                    " from datmlcl ",
                    " where atdsrvnum = ? ",
                    " and atdsrvano   = ? ",
                    " and c24endtip   = ? "

   prepare pctd07g03001 from l_sql_stmt
   declare cctd07g03001 cursor for pctd07g03001   

   let m_ctd07g03_prep = true

end function

#------- Obtem o endereco do servico -----------------------------------------#
function ctd07g03_busca_local(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param         record
          nivel_retorno    smallint
         ,atdsrvnum        like datmlcl.atdsrvnum
         ,atdsrvano        like datmlcl.atdsrvano
         ,c24endtip        like datmlcl.c24endtip
   end record  

   define l_resultado        smallint
         ,l_mensagem         char(60)

   define lr_retorno       record
          cidnom           like datmlcl.cidnom
         ,ufdcod           like datmlcl.ufdcod
         ,lclltt           like datmlcl.lclltt
         ,lcllgt           like datmlcl.lcllgt
   end record  

   if m_ctd07g03_prep is null or
      m_ctd07g03_prep <> true then
      call ctd07g03_prepare()
   end if  

   let l_resultado = 1
   let l_mensagem  = null

   open cctd07g03001 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.c24endtip

   whenever error continue
   fetch cctd07g03001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Dados do endereco nao encontrado"
      else
         let l_resultado = 3
         let l_mensagem = "Erro em cctd07g03001: ", sqlca.sqlcode
      end if
   end if   

   close cctd07g03001

   case lr_param.nivel_retorno
        when 1 
             return l_resultado, l_mensagem, lr_retorno.cidnom,
                    lr_retorno.ufdcod, lr_retorno.lclltt, lr_retorno.lcllgt
   end case

end function
