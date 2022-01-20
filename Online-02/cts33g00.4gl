#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24H                                                #
# MODULO.........: CTS33G00                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  OBTER INFORMACOES DO ACIONAMENTO PARA INTERNET.            #
#                  REGISTRAR INFORAMCOES PARA ACIONAMENTO INTERNET.           #
# ........................................................................... #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts33g00_prep smallint

#-------------------------#
function cts33g00_prepare()
#-------------------------#

 define l_sql_stmt  char(500)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_sql_stmt  =  null

 let l_sql_stmt = " select max(atdetpseq) ",
                    " from datmsrvint ",
                   " where atdsrvnum = ? ",
                     " and atdsrvano = ? "

 prepare p_cts33g00_001 from l_sql_stmt
 declare c_cts33g00_001 cursor for p_cts33g00_001

 let l_sql_stmt = " select atdetpcod ",
                    " from datmsrvint ",
                   " where atdsrvano = ? ",
                     " and atdsrvnum = ? ",
                     " and atdetpseq = ? "

 prepare p_cts33g00_002 from l_sql_stmt
 declare c_cts33g00_002 cursor for p_cts33g00_002

 let l_sql_stmt = " insert into datmsrvint ",
                             " (atdsrvano, ",
                              " atdsrvnum, ",
                              " atdetpseq, ",
                              " atdetpcod, ",
                              " cadorg, ",
                              " pstcoddig, ",
                              " cadusrtip, ",
                              " cademp, ",
                              " cadmat, ",
                              " caddat, ",
                              " cadhor, ",
                              " etpmtvcod) ",
                      " values (?,?,?,?,0,?,?,?,?, ",
                              " today,current,?) "

 prepare p_cts33g00_003 from l_sql_stmt

 let l_sql_stmt = " insert into datmsrvintseqult ",
                             " (atdsrvano, ",
                              " atdsrvnum, ",
                              " atdetpseq, ",
                              " atdetpcod) ",
                      " values (?,?,?,?) "

 prepare p_cts33g00_004 from l_sql_stmt

 let l_sql_stmt = " update datmsrvintseqult set ",
                        " (atdetpseq, ",
                         " atdetpcod) = (?,?) ",
                   " where atdsrvano = ? ",
                     " and atdsrvnum = ? "

 prepare p_cts33g00_005 from l_sql_stmt

 let m_cts33g00_prep = true

end function

#==========================================#
function cts33g00_inf_internet(lr_parametro)
#==========================================#

  define lr_parametro record
         atdsrvnum    like datmsrvint.atdsrvnum,
         atdsrvano    like datmsrvint.atdsrvano
  end record

  define lr_retorno   record
         resultado    smallint,
         mensagem     char(100),
         atdetpseq    like datmsrvint.atdetpseq,
         atdetpcod    like datmsrvint.atdetpcod
  end record

  define l_aux        like datmsrvint.atdetpseq


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_aux  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  lr_retorno.*  to  null

  if m_cts33g00_prep is null or
     m_cts33g00_prep <> true then
     call cts33g00_prepare()
  end if

  initialize lr_retorno.* to null

  open c_cts33g00_001 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano
  whenever error continue
  fetch c_cts33g00_001 into lr_retorno.atdetpseq
  whenever error stop
  if sqlca.sqlcode <> 0 then
     let lr_retorno.resultado = 3
     let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " na tabela datmsrvint."
     return lr_retorno.*
  end if

  close c_cts33g00_001

  if lr_retorno.atdetpseq is null then
     let lr_retorno.atdetpseq = 0
  end if

  let lr_retorno.atdetpseq = lr_retorno.atdetpseq + 1

  if lr_retorno.atdetpseq > 1 then
     let l_aux = lr_retorno.atdetpseq - 1
     open c_cts33g00_002 using lr_parametro.atdsrvano,
                             lr_parametro.atdsrvnum,
                             l_aux
     whenever error continue
     fetch c_cts33g00_002 into lr_retorno.atdetpcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           let lr_retorno.resultado = 2
           let lr_retorno.mensagem  = "Servico nao encontrado"
        else
           let lr_retorno.resultado = 3
           let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " na tabela datmsrvint."
        end if
     end if
     return lr_retorno.*
  else
     let lr_retorno.atdetpcod = 0
  end if

  close c_cts33g00_002

  let lr_retorno.resultado = 1
  let lr_retorno.mensagem  = null

  return lr_retorno.*

end function

#=====================================================#
function cts33g00_registrar_para_internet(lr_parametro)
#=====================================================#

  define lr_parametro record
         atdsrvano    like datmservico.atdsrvano,
         atdsrvnum    like datmservico.atdsrvnum,
         atdetpseq    like datmsrvint.atdetpseq,
         atdetpcod    like datmsrvint.atdetpcod,
         atdprscod    like datmservico.atdprscod,
         usrtip       like datmservico.usrtip,
         empcod       like datmservico.empcod,
         funmat       like datmservico.funmat,
         etpmtvcod    like datmsrvint.etpmtvcod
  end record

  define lr_retorno   record
         resultado    smallint,
         mensagem     char(100)
  end record



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  lr_retorno.*  to  null

  initialize lr_retorno.*  to  null

  if m_cts33g00_prep is null or
     m_cts33g00_prep <> true then
     call cts33g00_prepare()
  end if

  whenever error continue
  execute p_cts33g00_003 using lr_parametro.atdsrvano,
                             lr_parametro.atdsrvnum,
                             lr_parametro.atdetpseq,
                             lr_parametro.atdetpcod,
                             lr_parametro.atdprscod,
                             lr_parametro.usrtip,
                             lr_parametro.empcod,
                             lr_parametro.funmat,
                             lr_parametro.etpmtvcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     let lr_retorno.resultado = 2
     let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " na tabela datmsrvint"
     return lr_retorno.*
  end if

  if lr_parametro.atdetpseq = 1 then
     whenever error continue
     execute p_cts33g00_004 using lr_parametro.atdsrvano,
                                lr_parametro.atdsrvnum,
                                lr_parametro.atdetpseq,
                                lr_parametro.atdetpcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " na tabela datmsrvintseqult"
        return lr_retorno.*
     end if
  else
     whenever error continue
     execute p_cts33g00_005 using lr_parametro.atdetpseq,
                                lr_parametro.atdetpcod,
                                lr_parametro.atdsrvano,
                                lr_parametro.atdsrvnum
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " na tabela datmsrvintseqult"
        return lr_retorno.*
     end if
  end if

  let lr_retorno.resultado = 1
  let lr_retorno.mensagem  = null

  return lr_retorno.*

end function
