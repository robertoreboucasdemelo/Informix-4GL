#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTS40G17                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTOMOVEL                  #
#                  BUSCA OS PRESTADORES DA ESTAPA DO SERVICO DESEJADA.        #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 28/06/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g17_prep smallint

#-------------------------#
function cts40g17_prepare()
#-------------------------#

  define l_sql char(400)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select pstcoddig ",
                " from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdetpcod = ? "

  prepare pcts40g17001 from l_sql
  declare ccts40g17001 cursor for pcts40g17001

  let l_sql = " select pstcoddig ",
                " from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdetpcod = ? ",
                 " and atdsrvseq = (select max(atdsrvseq) ",
                                    " from datmsrvacp ",
                                   " where atdsrvnum = ? ",
                                     " and atdsrvano = ? ",
                                     " and atdetpcod = ? )"

  prepare pcts40g17002 from l_sql
  declare ccts40g17002 cursor for pcts40g17002

  let m_cts40g17_prep = true

end function

#-----------------------------------------#
function cts40g17_lista_prest(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdetpcod    like datmsrvacp.atdetpcod
  end record

  define al_prestador array[10] of integer

  define l_contador smallint


        define  w_pf1   integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_contador  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  10
                initialize  al_prestador[w_pf1]    to  null
        end     for

  if m_cts40g17_prep is null or
     m_cts40g17_prep <> true then
     call cts40g17_prepare()
  end if

  let al_prestador[1]  = null
  let al_prestador[2]  = null
  let al_prestador[3]  = null
  let al_prestador[4]  = null
  let al_prestador[5]  = null
  let al_prestador[6]  = null
  let al_prestador[7]  = null
  let al_prestador[8]  = null
  let al_prestador[9]  = null
  let al_prestador[10] = null

  let l_contador = 1

  open ccts40g17001 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano,
                          lr_parametro.atdetpcod

  foreach ccts40g17001 into al_prestador[l_contador]
     let l_contador = (l_contador + 1)

     if l_contador > 10 then
        call errorlog("O LIMITE DE REGISTROS NO ARRAY FOI SUPERADO. CTS40G17.4GL")
        exit foreach
     end if

  end foreach
  close ccts40g17001

  let l_contador = (l_contador - 1)

  return al_prestador[1],
         al_prestador[2],
         al_prestador[3],
         al_prestador[4],
         al_prestador[5],
         al_prestador[6],
         al_prestador[7],
         al_prestador[8],
         al_prestador[9],
         al_prestador[10]

end function

#-----------------------------------------#
function cts40g17_unico_prest(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdetpcod    like datmsrvacp.atdetpcod
  end record

  define l_status     smallint,
         l_msg        char(100),
         l_pstcoddig  like datmsrvacp.pstcoddig


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_status  =  null
        let     l_msg  =  null
        let     l_pstcoddig  =  null

  if m_cts40g17_prep is null or
     m_cts40g17_prep <> true then
     call cts40g17_prepare()
  end if

  open ccts40g17002 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano,
                          lr_parametro.atdetpcod,
                          lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano,
                          lr_parametro.atdetpcod
  whenever error continue
  fetch ccts40g17002 into l_pstcoddig
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode <> notfound then
        let l_msg = "Erro SELECT ccts40g17002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg)
        let l_msg = "cts40g17_prest_etp() / ", lr_parametro.atdsrvnum, "/",
                                               lr_parametro.atdsrvano, "/",
                                               lr_parametro.atdetpcod
        call errorlog(l_msg)
     end if
  end if

  let l_status = sqlca.sqlcode
  close ccts40g17002

  return l_status,
         l_pstcoddig

end function
