#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd07g05                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........:                                                            #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datmsrvacp           #
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

#utilizar módulo para criar funções que acessam a tabela datmsrvacp

globals  "/homedsa/projetos/geral/globals/glct.4gl"  

define m_ctd07g05_prep smallint

#---------------------------#
function ctd07g05_prepare()
#---------------------------#

   define l_sql_stmt  char(1000)

   let l_sql_stmt = " select empcod, funmat, atdetpcod ",
                    "   from datmsrvacp ",
                    "  where atdsrvnum = ? ",
                    "    and atdsrvano = ? ",
                    "    and atdsrvseq = " , 
                    "        (select min(atdsrvseq) ",  ### MIN 
                    "           from datmsrvacp ",
                    "          where atdsrvnum = ? ",
                    "            and atdsrvano = ? ",
                    "            and atdetpcod in (3, 4, 43)) ",
                    "    and atdetpcod in (3, 4, 43) "

   prepare pctd07g05001 from l_sql_stmt
   declare cctd07g05001 cursor for pctd07g05001   

   let l_sql_stmt = " select empcod, funmat, atdetpcod, pstcoddig, ",
                    "        srrcoddig from datmsrvacp ",
                    "  where atdsrvnum = ? ",
                    "    and atdsrvano = ? ",
                    "    and atdsrvseq = " , 
                    "        (select max(atdsrvseq) ", ### MAX
                    "           from datmsrvacp ",
                    "          where atdsrvnum = ? ",
                    "            and atdsrvano = ? ",
                    "            and atdetpcod in (3, 4, 43)) ",
                    "    and atdetpcod in (3, 4, 43) "

   prepare pctd07g05002 from l_sql_stmt
   declare cctd07g05002 cursor for pctd07g05002

   let l_sql_stmt = " select empcod, funmat, atdetpcod, pstcoddig, ",
                    "        srrcoddig from datmsrvacp ",
                    "  where atdsrvnum = ? ",
                    "    and atdsrvano = ? ",
                    "    and atdsrvseq = " , 
                    "        (select max(atdsrvseq) ", ### MAX
                    "           from datmsrvacp ",
                    "          where atdsrvnum = ? ",
                    "            and atdsrvano = ?)"

   prepare pctd07g05003 from l_sql_stmt
   declare cctd07g05003 cursor for pctd07g05003

   let m_ctd07g05_prep = true

   let m_ctd07g05_prep = true

end function

#------- Obtem dados do 1o acionamento do servico ----------------------------#
function ctd07g05_pri_acn(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param         record
          nivel_retorno    smallint
         ,atdsrvnum        like datmsrvacp.atdsrvnum
         ,atdsrvano        like datmsrvacp.atdsrvano
   end record  

   define l_resultado        smallint
         ,l_mensagem         char(60)

   define lr_retorno       record
          empcod           like datmsrvacp.empcod 
         ,funmat           like datmsrvacp.funmat
         ,atdetpcod        like datmsrvacp.atdetpcod
   end record  

   if m_ctd07g05_prep is null or
      m_ctd07g05_prep <> true then
      call ctd07g05_prepare()
   end if  

   let l_resultado = 1
   let l_mensagem  = null

   open cctd07g05001 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.atdsrvnum
                          ,lr_param.atdsrvano

   whenever error continue
   fetch cctd07g05001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Dados da etapa nao encontrado"
      else
         let l_resultado = 3
         let l_mensagem = "Erro em cctd07g05001: ", sqlca.sqlcode
      end if
   end if   

   close cctd07g05001

   case lr_param.nivel_retorno
        when 1 
             return l_resultado, l_mensagem, lr_retorno.empcod,
                    lr_retorno.funmat, lr_retorno.atdetpcod
   end case

end function

#------- Obtem dados do ultimo acionamento do servico ------------------------#
function ctd07g05_ult_acn(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param         record
          nivel_retorno    smallint
         ,atdsrvnum        like datmsrvacp.atdsrvnum
         ,atdsrvano        like datmsrvacp.atdsrvano
   end record

   define l_resultado        smallint
         ,l_mensagem         char(60)

   define lr_retorno       record
          empcod           like datmsrvacp.empcod
         ,funmat           like datmsrvacp.funmat
         ,atdetpcod        like datmsrvacp.atdetpcod
         ,pstcoddig        like datmsrvacp.pstcoddig
         ,srrcoddig        like datmsrvacp.srrcoddig
   end record

   if m_ctd07g05_prep is null or
      m_ctd07g05_prep <> true then
      call ctd07g05_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null

   open cctd07g05002 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.atdsrvnum
                          ,lr_param.atdsrvano

   whenever error continue
   fetch cctd07g05002 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Dados da etapa nao encontrado"
      else
         let l_resultado = 3
         let l_mensagem = "Erro em cctd07g05001: ", sqlca.sqlcode
      end if
   end if

   close cctd07g05002

   case lr_param.nivel_retorno
        when 1
             return l_resultado, l_mensagem, lr_retorno.empcod,
                    lr_retorno.funmat, lr_retorno.atdetpcod
        when 2
             return lr_retorno.empcod, lr_retorno.funmat, lr_retorno.atdetpcod,
                    lr_retorno.pstcoddig, lr_retorno.srrcoddig
   end case

end function    

#------- Obtem dados da ultima etapa do servico ------------------------------#
function ctd07g05_ult_etp(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param         record
          nivel_retorno    smallint
         ,atdsrvnum        like datmsrvacp.atdsrvnum
         ,atdsrvano        like datmsrvacp.atdsrvano
   end record

   define l_resultado        smallint
         ,l_mensagem         char(60)

   define lr_retorno       record
          empcod           like datmsrvacp.empcod
         ,funmat           like datmsrvacp.funmat
         ,atdetpcod        like datmsrvacp.atdetpcod
         ,pstcoddig        like datmsrvacp.pstcoddig
         ,srrcoddig        like datmsrvacp.srrcoddig
   end record

   if m_ctd07g05_prep is null or
      m_ctd07g05_prep <> true then
      call ctd07g05_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null

   open cctd07g05003 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.atdsrvnum
                          ,lr_param.atdsrvano

   whenever error continue
   fetch cctd07g05003 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Dados da etapa nao encontrado"
      else
         let l_resultado = 3
         let l_mensagem = "Erro em cctd07g05003: ", sqlca.sqlcode
      end if
   end if

   close cctd07g05003

   case lr_param.nivel_retorno
        when 1
             return l_resultado, l_mensagem, lr_retorno.empcod,
                    lr_retorno.funmat, lr_retorno.atdetpcod
        when 2
             return lr_retorno.empcod, lr_retorno.funmat, lr_retorno.atdetpcod,
                    lr_retorno.pstcoddig, lr_retorno.srrcoddig
   end case

end function    
