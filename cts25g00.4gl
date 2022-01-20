#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24H                                                #
# MODULO.........: CTS25G00                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI............: 187550                                                     #
#                  OBTENCAO DE INFORMACOES RELACIONADAS AO ASSUNTO.           #
# ........................................................................... #
# DESENVOLVIMENTO: META, LUCAS SCHEID                                         #
# LIBERACAO......: 10/09/2004                                                 #
# ........................................................................... #
#                                                                             #
#                          * * * ALTERACOES * * *                             #
#                                                                             #
# DATA       AUTOR FABRICA      ORIGEM     ALTERACAO                          #
# ---------- ------------------ ---------- -----------------------------------#
# 28/02/2005 Robson Carmo,Meta PSI190772   Inclusao e tratamento de novo      #
#                                          parametro na funcao                #
#                                          (cts25g00_dados_assunto)           #
#-----------------------------------------------------------------------------#
# 24/08/2005 Julianna,Meta     PSI194654   Inclusao do nivel de retorno = 3   #
#-----------------------------------------------------------------------------#
# 08/02/2006 Lucas Scheid      PSI196541   Inclusao do campo webrlzflg no re- #
#                                          torno da funcao cts25g00_dados_ass-#
#                                          unto().                            #
#-----------------------------------------------------------------------------#

database porto

  define m_prep smallint

#-------------------------#
function cts25g00_prepare()
#-------------------------#

  define l_sql_stmt  char(400)

  let l_sql_stmt = " select rcuccsmtvobrflg, ",
                          " c24astexbflg, ",
                          " telmaiatlflg, ",
                          " prgcod, ",
                          " c24aststt, ",
                          " c24asttltflg, ",
                          " cndslcflg, ",
                          " c24atrflg, ",
                          " c24jstflg, ",
                          " c24astpgrtxt, ",
                          " maimsgenvflg, ",
                          " webrlzflg,",
                          " c24astagp, ",
                          " prgcod, ",
                          " atmacnflg, ",
                          " c24astdes ",
                     " from datkassunto ",
                    " where c24astcod = ? "

  prepare p_cts25g00_001 from l_sql_stmt
  declare c_cts25g00_001 cursor for p_cts25g00_001

  let l_sql_stmt = " select ciaempcod  ",
                     " from datkastagp ",
                    " where c24astagp = ? "

  prepare p_cts25g00_002 from l_sql_stmt
  declare c_cts25g00_002 cursor for p_cts25g00_002

  let m_prep = true

end function

#---------------------------------------#
function cts25g00_dados_assunto(lr_param)
#---------------------------------------#

  define lr_param      record
         nivel_retorno smallint,
         c24astcod     like datkassunto.c24astcod
  end record

  define l_resultado         smallint,
         l_mensagem          char(30)

  define lr_retorno1       record
         rcuccsmtvobrflg   like datkassunto.rcuccsmtvobrflg,
         c24astexbflg      like datkassunto.c24astexbflg,
         telmaiatlflg      like datkassunto.telmaiatlflg,
         prgcod            like datkassunto.prgcod,
         c24aststt         like datkassunto.c24aststt,
         c24asttltflg      like datkassunto.c24asttltflg,
         cndslcflg         like datkassunto.cndslcflg,
         c24atrflg         like datkassunto.c24atrflg,
         c24jstflg         like datkassunto.c24jstflg,
         c24astpgrtxt      like datkassunto.c24astpgrtxt,
         maimsgenvflg      like datkassunto.maimsgenvflg,
         webrlzflg         like datkassunto.webrlzflg,
         ciaempcod         like datkastagp.ciaempcod
  end record

  define l_c24astexbflg like datkassunto.c24astexbflg
  define l_prgcod       like datkassunto.prgcod
  define l_c24astdes    like datkassunto.c24astdes
  define l_c24astagp    like datkastagp.c24astagp
  define l_atmacnflg    like datkassunto.atmacnflg

  if m_prep is null or m_prep <> true then
     call cts25g00_prepare()
  end if

  initialize lr_retorno1 to null
  let l_resultado = 1
  let l_mensagem     = null
  let l_c24astexbflg = null
  let l_prgcod       = null
  let l_c24astdes    = null
  let l_c24astagp    = null
  let l_atmacnflg    = null

  open c_cts25g00_001 using lr_param.c24astcod
  whenever error continue
  fetch c_cts25g00_001 into lr_retorno1.rcuccsmtvobrflg
                         ,lr_retorno1.c24astexbflg
                         ,lr_retorno1.telmaiatlflg
                         ,lr_retorno1.prgcod
                         ,lr_retorno1.c24aststt
                         ,lr_retorno1.c24asttltflg
                         ,lr_retorno1.cndslcflg
                         ,lr_retorno1.c24atrflg
                         ,lr_retorno1.c24jstflg
                         ,lr_retorno1.c24astpgrtxt
                         ,lr_retorno1.maimsgenvflg
                         ,lr_retorno1.webrlzflg
                         ,l_c24astagp
                         ,l_prgcod
                         ,l_atmacnflg
                         ,l_c24astdes

  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_resultado = 2
        let l_mensagem = 'Assunto invalido'
     else
        let l_resultado = 3
        let l_mensagem = 'Erro ', sqlca.sqlcode, ' em datkassunto'
     end if
  else
     open c_cts25g00_002 using l_c24astagp
     whenever error continue
       fetch c_cts25g00_002 into lr_retorno1.ciaempcod
     whenever error stop
     close c_cts25g00_002

     let l_resultado = 1
  end if
  close c_cts25g00_001

  if lr_param.nivel_retorno = 1 then
     return l_resultado, l_mensagem, lr_retorno1.*
  end if

  if lr_param.nivel_retorno = 2 then
     return l_resultado, l_mensagem, lr_retorno1.c24astexbflg
  end if

  if lr_param.nivel_retorno = 3 then
     return l_resultado, l_mensagem, l_prgcod
  end if

  if lr_param.nivel_retorno = 4 then
     return l_resultado, l_mensagem, l_atmacnflg
  end if

  if lr_param.nivel_retorno = 5 then
     return l_resultado, l_mensagem, l_c24astdes
  end if

end function
