#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTS40G16                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTOMOVEL                  #
#                  1) VERIFICA SE O PRESTADOR POSSUI SERVICOS COM STATUS A-   #
#                     GUARDANDO NO PORTAL DE NEGOCIOS.                        #
#                  2) BUSCA A PENULTIMA ETAPA DO SERVICO DE INTERNET.         #
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

  define m_cts40g16_prep smallint

#-------------------------#
function cts40g16_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select count(*) ",
                " from datmsrvint a, ",
                     " datmsrvintseqult b ",
               " where a.atdsrvnum = b.atdsrvnum ",
                 " and a.atdsrvano = b.atdsrvano ",
                 " and a.atdetpseq = b.atdetpseq ",
                 " and a.atdetpcod = 0 ",
                 " and a.pstcoddig = ? "

  prepare pcts40g16001 from l_sql
  declare ccts40g16001 cursor for pcts40g16001

  let l_sql = " select atdetpcod ",
                " from datmsrvint ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdetpseq = (select max(atdetpseq) ",
                                    " from datmsrvint ",
                                   " where atdsrvnum = ? ",
                                     " and atdsrvano = ?) "

  prepare pcts40g16002 from l_sql
  declare ccts40g16002 cursor for pcts40g16002

  let m_cts40g16_prep = true

end function

#-------------------------------------#
function cts40g16_srv_pend(l_pstcoddig)
#-------------------------------------#

  # VERIFICA SE O PRESTADOR POSSUI SERVICOS COM STATUS AGUARDANDO
  # NO PORTAL DE NEGOCIOS.

  define l_pstcoddig like datmsrvint.pstcoddig,
         l_qtd_srv   smallint,
         l_msg       char(80),
         l_status    smallint # 0 -> OK   <> 0 -> ERRO DE ACESSO AO BD


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_qtd_srv  =  null
        let     l_msg  =  null
        let     l_status  =  null

  if m_cts40g16_prep is null or
     m_cts40g16_prep <> true then
     call cts40g16_prepare()
  end if

  open ccts40g16001 using l_pstcoddig
  whenever error continue
  fetch ccts40g16001 into l_qtd_srv
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro SELECT ccts40g16001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
     call errorlog(l_msg)
     let l_msg = "cts40g16_srv_pend() / ", l_pstcoddig
     call errorlog(l_msg)
  end if
  let l_status = sqlca.sqlcode
  close ccts40g16001

  if l_qtd_srv is null then
     let l_qtd_srv = 0
  end if

  return l_status,
         l_qtd_srv

end function

#-------------------------------------------#
function cts40g16_pnletp_srvint(lr_parametro)
#-------------------------------------------#

  # BUSCA A PENULTIMA ETAPA DO SERVICO DE INTERNET.

  define lr_parametro record
         atdsrvnum    like datmsrvint.atdsrvnum,
         atdsrvano    like datmsrvint.atdsrvano
  end record

  define l_msg       char(80),
         l_atdetpcod like datmsrvint.atdetpcod,
         l_status    smallint # 0 -> OK     <> 0 -> ERRO DE ACESSO AO BD


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_msg  =  null
        let     l_atdetpcod  =  null
        let     l_status  =  null

  if m_cts40g16_prep is null or
     m_cts40g16_prep <> true then
     call cts40g16_prepare()
  end if

  let l_status    = 0

  open ccts40g16002 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano,
                          lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano

  whenever error continue
  fetch ccts40g16002 into l_atdetpcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_atdetpcod = null
     else
        let l_msg = "Erro SELECT ccts40g16002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg)
        let l_msg = "cts40g16_pnletp_srvint() / ", lr_parametro.atdsrvnum, "/",
                                                   lr_parametro.atdsrvano
        call errorlog(l_msg)
        let l_status = sqlca.sqlcode
     end if
  end if

  close ccts40g16002

  return l_status,
         l_atdetpcod

end function

