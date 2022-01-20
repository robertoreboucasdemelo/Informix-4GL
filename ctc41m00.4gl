###########################################################################
# Nome do Modulo: ctc41m00                                        Marcelo #
#                                                                Gilberto #
# Cadastro de Controladoras de MDT's                             Jul/1999 #
#-------------------------------------------------------------------------#
# 18/12/2000  PSI 12023-5  Marcus       Alterar cadastro de controladoras #
#                                       para trabalhar com grupo de       #
#                                       acionamento                       #
#-------------------------------------------------------------------------#
# 17/01/2001  PSI 12340-4  Marcus       Adicionar os campos referentes a  #
#                                       qual frequencia a controladora    #
#                                       trabalha                          #
###########################################################################
# 27/12/2005  PSI 197092   Lucas Scheid Inclusao dos campos:              #
#                                       Tempo Atualizacao Rapida,         #
#                                       Velocidade Limite e               #
#                                       Tempo Atualizacao Lenta no cadas- #
#                                       tro das Controladoras e MDT's.    #
#-------------------------------------------------------------------------#
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso#
#-------------------------------------------------------------------------#
# 17/04/2009  Kevellin       PSI237337 Opção contingência - envio sms     #
#-------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctc41m00_prep smallint

#-------------------------#
function ctc41m00_prepare()
#-------------------------#

  define l_sql char(500)

  let l_sql = " update datkmdtctr set ",
              " (mdtcnxsrvdes, ",
              " mdtcmuttvqtd, ",
              " mdtaatitv, ",
              " mdtttvitv, ",
              " mdtcnlplr, ",
              " mdtctrstt, ",
              " atldat, ",
              " atlemp, ",
              " atlmat, ",
              " gpsacngrpcod, ",
              " mdtfqcnum, ",
              " mdtfqcdes, ",
              " segrpdatltmpqtd, ",
              " fqctrclimvlcqtd, ",
              " seglntatltmpqtd) = ",
             " (?, ?, ?, ?, ?, ?, ",
              " ?, ?, ?, ?, ?, ?, ?, ?, ?) ",
        " where mdtctrcod = ? "

  prepare pctc41m00001 from l_sql

  let l_sql = " insert into datkmdtctr(mdtctrcod, ",
                         " mdtcnxsrvdes, ",
                         " mdtcmuttvqtd, ",
                         " mdtaatitv, ",
                         " mdtttvitv, ",
                         " mdtcnlplr, ",
                         " mdtctrstt, ",
                         " caddat, ",
                         " cademp, ",
                         " cadmat, ",
                         " atldat, ",
                         " atlemp, ",
                         " atlmat, ",
                         " gpsacngrpcod, ",
                         " mdtfqcnum, ",
                         " mdtfqcdes, ",
                         " segrpdatltmpqtd, ",
                         " fqctrclimvlcqtd, ",
                         " seglntatltmpqtd) ",
                 " values (?, ?, ?, ?, ?, ?, ?, ?, ",
                         " ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "

  prepare pctc41m00002 from l_sql

  let l_sql = " select 1 ",
                " from datkmdtctr ",
               " where mdtctrcod = ? "

  prepare pctc41m00003 from l_sql
  declare cctc41m00003 cursor for pctc41m00003

  let l_sql = " select min(mdtctrcod) ",
                " from datkmdtctr ",
               " where datkmdtctr.mdtctrcod > ? "

  prepare pctc41m00004 from l_sql
  declare cctc41m00004 cursor for pctc41m00004

  let l_sql = " select max(mdtctrcod) ",
                " from datkmdtctr ",
               " where datkmdtctr.mdtctrcod < ? "

  prepare pctc41m00005 from l_sql
  declare cctc41m00005 cursor for pctc41m00005

  let l_sql = " delete from datkmdtctr where mdtctrcod = ? "

  prepare pctc41m00006 from l_sql

  let l_sql = " select mdtctrcod, ",
                     " mdtcnxsrvdes, ",
                     " mdtcmuttvqtd, ",
                     " mdtaatitv, ",
                     " mdtttvitv, ",
                     " mdtcnlplr, ",
                     " mdtctrstt, ",
                     " caddat, ",
                     " cademp, ",
                     " cadmat, ",
                     " atldat, ",
                     " atlemp, ",
                     " atlmat, ",
                     " gpsacngrpcod, ",
                     " mdtfqcnum, ",
                     " mdtfqcdes, ",
                     " segrpdatltmpqtd, ",
                     " fqctrclimvlcqtd, ",
                     " seglntatltmpqtd ",
                " from datkmdtctr ",
               " where mdtctrcod = ? "

  prepare pctc41m00007 from l_sql
  declare cctc41m00007 cursor for pctc41m00007

  let l_sql = " select gpsacngrpdes ",
                " from datkacngrp ",
               " where gpsacngrpcod = ? "

  prepare pctc41m00008 from l_sql
  declare cctc41m00008 cursor for pctc41m00008

  let l_sql = " select cpodes ",
                " from iddkdominio ",
               " where cponom = 'mdtctrstt' ",
                 " and cpocod = ? "

  prepare pctc41m00009 from l_sql
  declare cctc41m00009 cursor for pctc41m00009

  let l_sql = " select count(*) ",
                " from datkmdt ",
               " where mdtctrcod = ? "

  prepare pctc41m00010 from l_sql
  declare cctc41m00010 cursor for pctc41m00010

  let l_sql = " select funnom ",
                " from isskfunc ",
               " where empcod = ? ",
                 " and funmat = ? "

  prepare pctc41m00011 from l_sql
  declare cctc41m00011 cursor for pctc41m00011

  let l_sql = " select max(mdtctrcod) ",
                " from datkmdtctr "

  prepare pctc41m00012 from l_sql
  declare cctc41m00012 cursor for pctc41m00012

  let l_sql = " select grlinf, atlhor ",
                " from datkgeral ",
                "where grlchv = ? "

  prepare pctc41m00013 from l_sql
  declare cctc41m00013 cursor for pctc41m00013

  let l_sql = " insert into datkgeral(grlchv, ",
                "                     grlinf, ",
                "                     atldat, ",
                "                     atlhor, ",
                "                     atlemp, ",
                "                     atlmat) ",
                " values(?,?,?,?,?,?) "

  prepare pctc41m00014 from l_sql

  let l_sql = " update datkgeral set(grlinf, ",
                "                    atldat, ",
                "                    atlhor, ",
                "                    atlemp, ",
                "                    atlmat) ",
                " = (?,?,?,?,?)              ",
                " where grlchv = ?           "

  prepare pctc41m00015 from l_sql

  let l_sql = " delete from datkgeral where grlchv = ? "

  prepare pctc41m00016 from l_sql

  let m_ctc41m00_prep = true

end function

#-----------------#
function ctc41m00()
#-----------------#

 define d_ctc41m00    record
    mdtctrcod         like datkmdtctr.mdtctrcod,
    mdtcnxsrvdes      like datkmdtctr.mdtcnxsrvdes,
    mdtcmuttvqtd      like datkmdtctr.mdtcmuttvqtd,
    mdtttvitv         like datkmdtctr.mdtttvitv,
    mdtaatitv         like datkmdtctr.mdtaatitv,
    mdtcnlplr         like datkmdtctr.mdtcnlplr,
    mdtctrstt         like datkmdtctr.mdtctrstt,
    mdtctrsttdes      char (20),
    caddat            like datkmdtctr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtctr.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes,
    mdtfqcnum         like datkmdtctr.mdtfqcnum,
    mdtfqcdes         like datkmdtctr.mdtfqcdes,
    segrpdatltmpqtd   like datkmdtctr.segrpdatltmpqtd,
    fqctrclimvlcqtd   like datkmdtctr.fqctrclimvlcqtd,
    seglntatltmpqtd   like datkmdtctr.seglntatltmpqtd,
    infctr            char(1),
    previsao          char(50)
 end record

 let int_flag = false

 initialize d_ctc41m00.*  to null

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc41m00") then
 #   error " Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 if m_ctc41m00_prep is null or
    m_ctc41m00_prep <> true then
    call ctc41m00_prepare()
 end if

 open window ctc41m00 at 4,2 with form "ctc41m00"

 menu "CONTROLADORAS"

  before menu
     hide option all
     #PSI 202290
     #if g_issk.acsnivcod >= g_issk.acsnivcns  then
     #   show option "Seleciona", "Proximo", "Anterior"
     #end if
     #if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "Remove"
#                   "Transfere"
     #end if

     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa controladora conforme criterios"
          clear form
          call ctc41m00_seleciona()  returning d_ctc41m00.*
          if d_ctc41m00.mdtctrcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma controladora selecionada!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proxima controladora selecionada"
          message ""
          call ctc41m00_proximo(d_ctc41m00.mdtctrcod)
               returning d_ctc41m00.*

 command key ("A") "Anterior"
                   "Mostra controladora anterior selecionada"
          message ""
          if d_ctc41m00.mdtctrcod is not null then
             call ctc41m00_anterior(d_ctc41m00.mdtctrcod)
                  returning d_ctc41m00.*
          else
             error " Nenhuma controladora nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica controladora corrente selecionada"
          message ""
          if d_ctc41m00.mdtctrcod  is not null then
             call ctc41m00_modifica(d_ctc41m00.mdtctrcod, d_ctc41m00.*)
                  returning d_ctc41m00.*
             next option "Seleciona"
          else
             error " Nenhuma controladora selecionada!"
             next option "Seleciona"
          end if
          clear form
          initialize d_ctc41m00.*  to null

 command key ("I") "Inclui"
                   "Inclui controladora"
          message ""
          clear form
          call ctc41m00_inclui()
          next option "Seleciona"
          initialize d_ctc41m00.*  to null

 command "Remove" "Remove controladora corrente selecionada"
          message ""
          if d_ctc41m00.mdtctrcod  is not null   then
             call ctc41m00_remove(d_ctc41m00.*)
                  returning d_ctc41m00.*
             next option "Seleciona"
          else
             error " Nenhuma controladora selecionada!"
             next option "Seleciona"
          end if
          clear form
          initialize d_ctc41m00.*  to null

 command key ("T") "Transfere"
                   "Transfere MDT's entre controladoras"
          message ""
          if d_ctc41m00.mdtctrcod  is not null   then
             call ctc41m01(d_ctc41m00.mdtctrcod)
             next option "Seleciona"
          else
             error " Nenhuma controladora selecionada!"
             next option "Seleciona"
          end if
          clear form
          initialize d_ctc41m00.*  to null
          next option "Seleciona"

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc41m00

end function  # ctc41m00

#---------------------------#
function ctc41m00_seleciona()
#---------------------------#

 define d_ctc41m00    record
    mdtctrcod         like datkmdtctr.mdtctrcod,
    mdtcnxsrvdes      like datkmdtctr.mdtcnxsrvdes,
    mdtcmuttvqtd      like datkmdtctr.mdtcmuttvqtd,
    mdtttvitv         like datkmdtctr.mdtttvitv,
    mdtaatitv         like datkmdtctr.mdtaatitv,
    mdtcnlplr         like datkmdtctr.mdtcnlplr,
    mdtctrstt         like datkmdtctr.mdtctrstt,
    mdtctrsttdes      char (20),
    caddat            like datkmdtctr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtctr.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes,
    mdtfqcnum         like datkmdtctr.mdtfqcnum,
    mdtfqcdes         like datkmdtctr.mdtfqcdes,
    segrpdatltmpqtd   like datkmdtctr.segrpdatltmpqtd,
    fqctrclimvlcqtd   like datkmdtctr.fqctrclimvlcqtd,
    seglntatltmpqtd   like datkmdtctr.seglntatltmpqtd,
    infctr            char(1),
    previsao          char(50)
 end record

 let int_flag = false

 initialize d_ctc41m00 to null

 display by name d_ctc41m00.*

 input by name d_ctc41m00.mdtctrcod

    before field mdtctrcod
        display by name d_ctc41m00.mdtctrcod attribute (reverse)

    after  field mdtctrcod
        display by name d_ctc41m00.mdtctrcod

        if d_ctc41m00.mdtctrcod  is null   then
           error " Controladora deve ser informada!"
           next field mdtctrcod
        end if

        open cctc41m00003 using d_ctc41m00.mdtctrcod
        fetch cctc41m00003

        if sqlca.sqlcode  =  notfound   then
           error " Controladora nao cadastrada!"
           next field mdtctrcod
        end if

        close cctc41m00003

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc41m00 to null
    display by name d_ctc41m00.*
    error " Operacao cancelada!"
    return d_ctc41m00.*
 end if

 call ctc41m00_ler(d_ctc41m00.mdtctrcod)
      returning d_ctc41m00.*

 if d_ctc41m00.mdtctrcod  is not null   then
    display by name  d_ctc41m00.*
 else
    error " Controladora nao cadastrada!"
    initialize d_ctc41m00.*    to null
 end if

 return d_ctc41m00.*

end function

#------------------------------#
function ctc41m00_proximo(param)
#------------------------------#

 define param         record
    mdtctrcod         like datkmdtctr.mdtctrcod
 end record

 define d_ctc41m00    record
    mdtctrcod         like datkmdtctr.mdtctrcod,
    mdtcnxsrvdes      like datkmdtctr.mdtcnxsrvdes,
    mdtcmuttvqtd      like datkmdtctr.mdtcmuttvqtd,
    mdtttvitv         like datkmdtctr.mdtttvitv,
    mdtaatitv         like datkmdtctr.mdtaatitv,
    mdtcnlplr         like datkmdtctr.mdtcnlplr,
    mdtctrstt         like datkmdtctr.mdtctrstt,
    mdtctrsttdes      char (20),
    caddat            like datkmdtctr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtctr.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes,
    mdtfqcnum         like datkmdtctr.mdtfqcnum,
    mdtfqcdes         like datkmdtctr.mdtfqcdes,
    segrpdatltmpqtd   like datkmdtctr.segrpdatltmpqtd,
    fqctrclimvlcqtd   like datkmdtctr.fqctrclimvlcqtd,
    seglntatltmpqtd   like datkmdtctr.seglntatltmpqtd,
    infctr            char(1),
    previsao          char(50)
 end record

 let int_flag = false

 initialize d_ctc41m00 to null

 if param.mdtctrcod  is null   then
    let param.mdtctrcod = 0
 end if

 open cctc41m00004 using param.mdtctrcod
 fetch cctc41m00004 into d_ctc41m00.mdtctrcod
 close cctc41m00004

 if d_ctc41m00.mdtctrcod  is not null   then

    call ctc41m00_ler(d_ctc41m00.mdtctrcod)
         returning d_ctc41m00.*

    if d_ctc41m00.mdtctrcod  is not null   then
       display by name d_ctc41m00.*
    else
       error " Nao ha' controladora nesta direcao!"
       initialize d_ctc41m00.*    to null
    end if
 else
    error " Nao ha' controladora nesta direcao!"
    initialize d_ctc41m00.*    to null
 end if

 return d_ctc41m00.*

end function    # ctc41m00_proximo

#-------------------------------#
function ctc41m00_anterior(param)
#-------------------------------#

 define param         record
    mdtctrcod         like datkmdtctr.mdtctrcod
 end record

 define d_ctc41m00    record
    mdtctrcod         like datkmdtctr.mdtctrcod,
    mdtcnxsrvdes      like datkmdtctr.mdtcnxsrvdes,
    mdtcmuttvqtd      like datkmdtctr.mdtcmuttvqtd,
    mdtttvitv         like datkmdtctr.mdtttvitv,
    mdtaatitv         like datkmdtctr.mdtaatitv,
    mdtcnlplr         like datkmdtctr.mdtcnlplr,
    mdtctrstt         like datkmdtctr.mdtctrstt,
    mdtctrsttdes      char (20),
    caddat            like datkmdtctr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtctr.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes,
    mdtfqcnum         like datkmdtctr.mdtfqcnum,
    mdtfqcdes         like datkmdtctr.mdtfqcdes,
    segrpdatltmpqtd   like datkmdtctr.segrpdatltmpqtd,
    fqctrclimvlcqtd   like datkmdtctr.fqctrclimvlcqtd,
    seglntatltmpqtd   like datkmdtctr.seglntatltmpqtd,
    infctr            char(1),
    previsao          char(50)
 end record

 let int_flag = false

 initialize d_ctc41m00 to null

 if param.mdtctrcod  is null   then
    let param.mdtctrcod = 0
 end if

 open cctc41m00005 using param.mdtctrcod
 fetch cctc41m00005 into d_ctc41m00.mdtctrcod
 close cctc41m00005

 if d_ctc41m00.mdtctrcod is not null then

    call ctc41m00_ler(d_ctc41m00.mdtctrcod)
         returning d_ctc41m00.*

    if d_ctc41m00.mdtctrcod  is not null   then
       display by name  d_ctc41m00.*
    else
       error " Nao ha' controladora nesta direcao!"
       initialize d_ctc41m00.*    to null
    end if
 else
    error " Nao ha' controladora nesta direcao!"
    initialize d_ctc41m00.*    to null
 end if

 return d_ctc41m00.*

end function    # ctc41m00_anterior

#-------------------------------------------#
function ctc41m00_modifica(param, d_ctc41m00)
#-------------------------------------------#

 define param         record
    mdtctrcod         like datkmdtctr.mdtctrcod
 end record

 define d_ctc41m00    record
    mdtctrcod         like datkmdtctr.mdtctrcod,
    mdtcnxsrvdes      like datkmdtctr.mdtcnxsrvdes,
    mdtcmuttvqtd      like datkmdtctr.mdtcmuttvqtd,
    mdtttvitv         like datkmdtctr.mdtttvitv,
    mdtaatitv         like datkmdtctr.mdtaatitv,
    mdtcnlplr         like datkmdtctr.mdtcnlplr,
    mdtctrstt         like datkmdtctr.mdtctrstt,
    mdtctrsttdes      char (20),
    caddat            like datkmdtctr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtctr.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes,
    mdtfqcnum         like datkmdtctr.mdtfqcnum,
    mdtfqcdes         like datkmdtctr.mdtfqcdes,
    segrpdatltmpqtd   like datkmdtctr.segrpdatltmpqtd,
    fqctrclimvlcqtd   like datkmdtctr.fqctrclimvlcqtd,
    seglntatltmpqtd   like datkmdtctr.seglntatltmpqtd,
    infctr            char(1),
    previsao          char(50)
 end record

 define  ws_resp       char(01),
         parametroctg  char(20),
         hora_atu      like datkgeral.atlhor,
         hora_int      integer

 call ctc41m00_input("a", d_ctc41m00.*) returning d_ctc41m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc41m00.*  to null
    display by name d_ctc41m00.*
    error " Operacao cancelada!"
    return d_ctc41m00.*
 end if

 whenever error continue

 let d_ctc41m00.atldat = today

 begin work
    execute pctc41m00001 using d_ctc41m00.mdtcnxsrvdes,
                               d_ctc41m00.mdtcmuttvqtd,
                               d_ctc41m00.mdtaatitv,
                               d_ctc41m00.mdtttvitv,
                               d_ctc41m00.mdtcnlplr,
                               d_ctc41m00.mdtctrstt,
                               d_ctc41m00.atldat,
                               g_issk.empcod,
                               g_issk.funmat,
                               d_ctc41m00.gpsacngrpcod,
                               d_ctc41m00.mdtfqcnum,
                               d_ctc41m00.mdtfqcdes,
                               d_ctc41m00.segrpdatltmpqtd,
                               d_ctc41m00.fqctrclimvlcqtd,
                               d_ctc41m00.seglntatltmpqtd,
                               d_ctc41m00.mdtctrcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao da controladora!"
       rollback work
       initialize d_ctc41m00.*   to null
       return d_ctc41m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 #CHAVE GERAL DATKGERAL PARA FUNCIONALIDADE CONTINGÊNCIA CONTROLADORA
 let parametroctg = 'PSOCTGCTR', d_ctc41m00.mdtctrcod
 if d_ctc41m00.infctr = 'S' then
    let hora_atu = current + 1 units hour
    #SE ACIONADO APÓS ÀS 23H00
    if hora_atu > '00:00:00' and hora_atu < '01:00:00' then
        let d_ctc41m00.atldat = today + 1 units day
    end if
 else
    let hora_atu = current
 end if

 whenever error continue

 begin work

 execute pctc41m00015 using d_ctc41m00.infctr,
                            d_ctc41m00.atldat,
                            hora_atu,
                            g_issk.empcod,
                            g_issk.funmat,
                            parametroctg

 if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na modificacao da contingencia sms da controladora!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 initialize d_ctc41m00 to null

 display by name d_ctc41m00.*

 message ""

 return d_ctc41m00.*

end function

#------------------------#
function ctc41m00_inclui()
#------------------------#

 define d_ctc41m00    record
    mdtctrcod         like datkmdtctr.mdtctrcod,
    mdtcnxsrvdes      like datkmdtctr.mdtcnxsrvdes,
    mdtcmuttvqtd      like datkmdtctr.mdtcmuttvqtd,
    mdtttvitv         like datkmdtctr.mdtttvitv,
    mdtaatitv         like datkmdtctr.mdtaatitv,
    mdtcnlplr         like datkmdtctr.mdtcnlplr,
    mdtctrstt         like datkmdtctr.mdtctrstt,
    mdtctrsttdes      char (20),
    caddat            like datkmdtctr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtctr.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes,
    mdtfqcnum         like datkmdtctr.mdtfqcnum,
    mdtfqcdes         like datkmdtctr.mdtfqcdes,
    segrpdatltmpqtd   like datkmdtctr.segrpdatltmpqtd,
    fqctrclimvlcqtd   like datkmdtctr.fqctrclimvlcqtd,
    seglntatltmpqtd   like datkmdtctr.seglntatltmpqtd,
    infctr            char(1),
    previsao          char(50)
 end record

 define  ws_resp       char(01),
         parametroctg  char(20),
         previsaohor   like datkgeral.atlhor,
         hora_atu      like datkgeral.atlhor,
         hora_int      integer


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
 let     ws_resp  =  null
 let previsaohor  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize d_ctc41m00 to null
 display by name d_ctc41m00.*

 call ctc41m00_input("i", d_ctc41m00.*) returning d_ctc41m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc41m00.*  to null
    display by name d_ctc41m00.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc41m00.atldat = today
 let d_ctc41m00.caddat = today

 open cctc41m00012
 fetch cctc41m00012 into d_ctc41m00.mdtctrcod
 close cctc41m00012

 if d_ctc41m00.mdtctrcod is null then
    let d_ctc41m00.mdtctrcod = 0
 end if

 let d_ctc41m00.mdtctrcod = d_ctc41m00.mdtctrcod + 1

 whenever error continue

 begin work

 execute pctc41m00002 using d_ctc41m00.mdtctrcod,
                            d_ctc41m00.mdtcnxsrvdes,
                            d_ctc41m00.mdtcmuttvqtd,
                            d_ctc41m00.mdtaatitv,
                            d_ctc41m00.mdtttvitv,
                            d_ctc41m00.mdtcnlplr,
                            d_ctc41m00.mdtctrstt,
                            d_ctc41m00.caddat,
                            g_issk.empcod,
                            g_issk.funmat,
                            d_ctc41m00.atldat,
                            g_issk.empcod,
                            g_issk.funmat,
                            d_ctc41m00.gpsacngrpcod,
                            d_ctc41m00.mdtfqcnum,
                            d_ctc41m00.mdtfqcdes,
                            d_ctc41m00.segrpdatltmpqtd,
                            d_ctc41m00.fqctrclimvlcqtd,
                            d_ctc41m00.seglntatltmpqtd

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do controladora!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 #CHAVE GERAL DATKGERAL PARA FUNCIONALIDADE CONTINGÊNCIA CONTROLADORA
 let parametroctg = 'PSOCTGCTR', d_ctc41m00.mdtctrcod

 if d_ctc41m00.infctr = 'S' then
    let hora_atu = current + 1 units hour
    #SE ACIONADO APÓS ÀS 23H00
    if hora_atu > '00:00:00' and hora_atu < '01:00:00' then
        let d_ctc41m00.atldat = today + 1 units day
    end if
 else
    let hora_atu = current
 end if

 whenever error continue

 begin work

 execute pctc41m00014 using parametroctg,
                            d_ctc41m00.infctr,
                            d_ctc41m00.atldat,
                            hora_atu,
                            g_issk.empcod,
                            g_issk.funmat

 if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na inclusao da contingencia sms da controladora!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 open cctc41m00013 using parametroctg
 fetch cctc41m00013 into d_ctc41m00.infctr, previsaohor
 close cctc41m00013

 if d_ctc41m00.infctr = 'N' then
    let d_ctc41m00.previsao = null
 else
    let d_ctc41m00.previsao = "sera automaticamente desativada as ", previsaohor
 end if

 call ctc41m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc41m00.cadfunnom

 call ctc41m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc41m00.funnom

 display by name  d_ctc41m00.*

 display by name d_ctc41m00.mdtctrcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc41m00 to null

 display by name d_ctc41m00.*

end function

#----------------------------------------#
function ctc41m00_input(param, d_ctc41m00)
#----------------------------------------#

 define param         record
    operacao          char (1)
 end record

 define d_ctc41m00    record
    mdtctrcod         like datkmdtctr.mdtctrcod,
    mdtcnxsrvdes      like datkmdtctr.mdtcnxsrvdes,
    mdtcmuttvqtd      like datkmdtctr.mdtcmuttvqtd,
    mdtttvitv         like datkmdtctr.mdtttvitv,
    mdtaatitv         like datkmdtctr.mdtaatitv,
    mdtcnlplr         like datkmdtctr.mdtcnlplr,
    mdtctrstt         like datkmdtctr.mdtctrstt,
    mdtctrsttdes      char (20),
    caddat            like datkmdtctr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtctr.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes,
    mdtfqcnum         like datkmdtctr.mdtfqcnum,
    mdtfqcdes         like datkmdtctr.mdtfqcdes,
    segrpdatltmpqtd   like datkmdtctr.segrpdatltmpqtd,
    fqctrclimvlcqtd   like datkmdtctr.fqctrclimvlcqtd,
    seglntatltmpqtd   like datkmdtctr.seglntatltmpqtd,
    infctr            char(1),
    previsao          char(50)
 end record

 define ws            record
    cont              dec(6,0)
 end record

 let int_flag = false

 initialize ws to null

 input by name d_ctc41m00.mdtcnxsrvdes,
               d_ctc41m00.mdtcmuttvqtd,
               d_ctc41m00.mdtttvitv,
               d_ctc41m00.mdtaatitv,
               d_ctc41m00.mdtcnlplr,
               d_ctc41m00.mdtctrstt,
               d_ctc41m00.gpsacngrpcod,
               d_ctc41m00.mdtfqcnum,
               d_ctc41m00.mdtfqcdes,
               d_ctc41m00.segrpdatltmpqtd,
               d_ctc41m00.fqctrclimvlcqtd,
               d_ctc41m00.seglntatltmpqtd,
               d_ctc41m00.infctr without defaults

    before field mdtcnxsrvdes
           display by name d_ctc41m00.mdtcnxsrvdes attribute (reverse)

    after  field mdtcnxsrvdes
           display by name d_ctc41m00.mdtcnxsrvdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtcnxsrvdes
           end if

           if d_ctc41m00.mdtcnxsrvdes  is null   then
              error " Meio de conexao com o servidor deve ser informado!"
              next field mdtcnxsrvdes
           end if

    before field mdtcmuttvqtd
           display by name d_ctc41m00.mdtcmuttvqtd attribute (reverse)

    after  field mdtcmuttvqtd
           display by name d_ctc41m00.mdtcmuttvqtd

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtcnxsrvdes
           end if

           if d_ctc41m00.mdtcmuttvqtd  is null   then
              error " Numero de tentativas deve ser informado!"
              next field mdtcmuttvqtd
           end if

           if d_ctc41m00.mdtcmuttvqtd  >  9      then
              error " Numero de tentativas nao deve ser maior que 9!"
              next field mdtcmuttvqtd
           end if

    before field mdtttvitv
           display by name d_ctc41m00.mdtttvitv attribute (reverse)

    after  field mdtttvitv
           display by name d_ctc41m00.mdtttvitv

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtcmuttvqtd
           end if

           if d_ctc41m00.mdtttvitv  is null   then
              error " Intervalo entre tentativas deve ser informado!"
              next field mdtttvitv
           end if

           if d_ctc41m00.mdtttvitv  >  65535   then
              error " Intervalo nao deve ser maior que 65535 milisegundos!"
              next field mdtttvitv
           end if

    before field mdtaatitv
           display by name d_ctc41m00.mdtaatitv attribute (reverse)

    after  field mdtaatitv
           display by name d_ctc41m00.mdtaatitv

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtttvitv
           end if

           if d_ctc41m00.mdtaatitv  is null   then
              error " Atraso no ataque deve ser informado!"
              next field mdtaatitv
           end if

           if d_ctc41m00.mdtaatitv  >  65535   then
              error " Atraso no ataque nao deve ser maior que 65535 milisegundos!"
              next field mdtaatitv
           end if

    before field mdtcnlplr
           display by name d_ctc41m00.mdtcnlplr attribute (reverse)

    after  field mdtcnlplr
           display by name d_ctc41m00.mdtcnlplr

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtaatitv
           end if

           if d_ctc41m00.mdtcnlplr  is null   then
              error " Polaridade do canal deve ser informada!"
              next field mdtcnlplr
           end if

           if d_ctc41m00.mdtcnlplr  <>  0   and
              d_ctc41m00.mdtcnlplr  <>  1   and
              d_ctc41m00.mdtcnlplr  <>  2   and
              d_ctc41m00.mdtcnlplr  <>  3   then
              error " Polaridade do canal deve ser: 0,1,2 ou 3 !"
              next field mdtcnlplr
           end if

    before field mdtctrstt

           if param.operacao  =  "i"   then
              let d_ctc41m00.mdtctrstt = 0

              open cctc41m00009 using d_ctc41m00.mdtctrstt
              fetch cctc41m00009 into d_ctc41m00.mdtctrsttdes
              close cctc41m00009

              display by name d_ctc41m00.mdtctrsttdes

           end if

           display by name d_ctc41m00.mdtctrstt attribute(reverse)

    after  field mdtctrstt
           display by name d_ctc41m00.mdtctrstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtcnlplr
           end if

           if d_ctc41m00.mdtctrstt is null then
              error " Situacao da controladora deve ser informada!"
              call ctn36c00("Situacao da controladora", "mdtctrstt")
                   returning  d_ctc41m00.mdtctrstt

              display by name d_ctc41m00.mdtctrstt
              display by name d_ctc41m00.mdtctrsttdes

              next field mdtctrstt
           end if

           open cctc41m00009 using d_ctc41m00.mdtctrstt
           fetch cctc41m00009 into d_ctc41m00.mdtctrsttdes

           if sqlca.sqlcode = notfound then
              error " Situacao da controladora nao cadastrada!"
              call ctn36c00("Situacao da controladora", "mdtctrstt")
                   returning  d_ctc41m00.mdtctrstt

              display by name d_ctc41m00.mdtctrstt
              display by name d_ctc41m00.mdtctrsttdes

              next field mdtctrstt
           end if

           close cctc41m00009

           display by name d_ctc41m00.mdtctrstt
           display by name d_ctc41m00.mdtctrsttdes

           if param.operacao =  "i"  and
              d_ctc41m00.mdtctrstt  <>  0   then
              error " Na inclusao situacao deve ser ATIVA!"
              next field mdtctrstt
           end if

           if d_ctc41m00.mdtctrstt >  0   then

               let ws.cont = 0

               open cctc41m00010 using d_ctc41m00.mdtctrcod
               fetch cctc41m00010 into ws.cont
               close cctc41m00010

               if ws.cont > 0 then
                  error " Controladora possui MDT, estes devem ser transferidos p/ outra controladora!"
                  next field mdtctrstt
               end if

            end if

    before field gpsacngrpcod
        display by name d_ctc41m00.gpsacngrpcod attribute (reverse)

    after field gpsacngrpcod
        display by name d_ctc41m00.gpsacngrpcod

        if fgl_lastkey() = fgl_keyval ("up")     or
           fgl_lastkey() = fgl_keyval ("left")   then
           next field mdtctrstt
        end if

        open cctc41m00008 using d_ctc41m00.gpsacngrpcod
        fetch cctc41m00008 into d_ctc41m00.gpsacngrpdes

        if sqlca.sqlcode = notfound then
           error "Grupo nao cadastrado !"
           next field gpsacngrpcod
        end if

        close cctc41m00008

        display by name d_ctc41m00.gpsacngrpdes

    next field mdtfqcnum

    before field mdtfqcnum
        display by name d_ctc41m00.mdtfqcnum attribute (reverse)

    after field mdtfqcnum
        display by name d_ctc41m00.mdtfqcnum

    before field mdtfqcdes
        display by name d_ctc41m00.mdtfqcdes attribute (reverse)

    after field mdtfqcdes
        display by name d_ctc41m00.mdtfqcdes

    # --> TEMPO DE ATUALIZACAO RAPIDA
    before field segrpdatltmpqtd
       display by name d_ctc41m00.segrpdatltmpqtd attribute(reverse)

    after field segrpdatltmpqtd
       display by name d_ctc41m00.segrpdatltmpqtd

       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
          next field mdtfqcdes
       end if

       if d_ctc41m00.segrpdatltmpqtd is null then
          error "Informe o Tempo Atualizacao Rapida"
          next field segrpdatltmpqtd
       end if

       if d_ctc41m00.segrpdatltmpqtd < 60 or
          d_ctc41m00.segrpdatltmpqtd >= 3600 then
          error "Informe uma valor entre: 60 e 3599 segundos"
          next field segrpdatltmpqtd
       end if

    # --> VELOCIDADE LIMITE
    before field fqctrclimvlcqtd
       display by name d_ctc41m00.fqctrclimvlcqtd attribute(reverse)

    after field fqctrclimvlcqtd
       display by name d_ctc41m00.fqctrclimvlcqtd

       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
          next field segrpdatltmpqtd
       end if

       if d_ctc41m00.fqctrclimvlcqtd is null then
          error "Informe a Velocidade Limite"
          next field fqctrclimvlcqtd
       end if

       if d_ctc41m00.fqctrclimvlcqtd <= 0 or
          d_ctc41m00.fqctrclimvlcqtd > 200 then
          error "Informe uma valor entre: 1 e 200 Km/h"
          next field fqctrclimvlcqtd
       end if

    # --> TEMPO DE ATUALIZACAO LENTA
    before field seglntatltmpqtd
       display by name d_ctc41m00.seglntatltmpqtd attribute(reverse)

    after field seglntatltmpqtd
       display by name d_ctc41m00.seglntatltmpqtd

       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
          next field fqctrclimvlcqtd
       end if

       if d_ctc41m00.seglntatltmpqtd is null then
          error "Informe o Tempo Atualizacao Lenta"
          next field seglntatltmpqtd
       end if

       if d_ctc41m00.seglntatltmpqtd < 120 or
          d_ctc41m00.seglntatltmpqtd >= 3600 then
          error "Informe uma valor entre: 120 e 3599 segundos"
          next field seglntatltmpqtd
       end if

    # --> CONTINGÊNCIA CONTROLADORA
    before field infctr
        display by name d_ctc41m00.infctr attribute(reverse)

    after field infctr
        display by name d_ctc41m00.infctr

        if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
          next field seglntatltmpqtd
        end if

       if d_ctc41m00.infctr <> 'S' and
          d_ctc41m00.infctr <> 'N' then
          error "Informe 'S' para SIM ou 'N' para NÃO"
          next field infctr
       end if

       if d_ctc41m00.infctr is null then
          error "Informe 'S' para SIM ou 'N' para NÃO"
          next field infctr
       end if

 on key (control-c, f17, interrupt)
    exit input

 end input

 if int_flag   then
    initialize d_ctc41m00.*  to null
 end if

 return d_ctc41m00.*

end function

#----------------------------------#
function ctc41m00_remove(d_ctc41m00)
#----------------------------------#

 define d_ctc41m00    record
    mdtctrcod         like datkmdtctr.mdtctrcod,
    mdtcnxsrvdes      like datkmdtctr.mdtcnxsrvdes,
    mdtcmuttvqtd      like datkmdtctr.mdtcmuttvqtd,
    mdtttvitv         like datkmdtctr.mdtttvitv,
    mdtaatitv         like datkmdtctr.mdtaatitv,
    mdtcnlplr         like datkmdtctr.mdtcnlplr,
    mdtctrstt         like datkmdtctr.mdtctrstt,
    mdtctrsttdes      char (20),
    caddat            like datkmdtctr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtctr.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes,
    mdtfqcnum         like datkmdtctr.mdtfqcnum,
    mdtfqcdes         like datkmdtctr.mdtfqcdes,
    segrpdatltmpqtd   like datkmdtctr.segrpdatltmpqtd,
    fqctrclimvlcqtd   like datkmdtctr.fqctrclimvlcqtd,
    seglntatltmpqtd   like datkmdtctr.seglntatltmpqtd,
    infctr            char(1),
    previsao          char(50)
 end record

 define ws            record
    mdtctrcod         like datkmdtctr.mdtctrcod
 end record

 define parametroctg  char(20)

 initialize ws to null

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o controladora"
            clear form
            initialize d_ctc41m00.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui controladora"
            call ctc41m00_ler(d_ctc41m00.mdtctrcod) returning d_ctc41m00.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc41m00.* to null
               error " controladora nao localizado!"
            else

               initialize ws.mdtctrcod  to null

               select max (datkmdt.mdtctrcod)
                 into ws.mdtctrcod
                 from datkmdt
                where datkmdt.mdtctrcod = d_ctc41m00.mdtctrcod

               if ws.mdtctrcod  is not null   and
                  ws.mdtctrcod  > 0           then
                  error " Controladora possui MDT's cadastrados, portanto nao deve ser removida!"
                  exit menu
               end if

               begin work
                  execute pctc41m00006 using d_ctc41m00.mdtctrcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc41m00.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao da controladora!"
               else

                  #CHAVE GERAL DATKGERAL PARA FUNCIONALIDADE CONTINGÊNCIA CONTROLADORA
                  let parametroctg = 'PSOCTGCTR', d_ctc41m00.mdtctrcod
                  begin work
                    execute pctc41m00016 using parametroctg
                  commit work

                  if sqlca.sqlcode <> 0   then
                    initialize d_ctc41m00.* to null
                    error " Erro (",sqlca.sqlcode,") na exlusao da contingencia!"
                  else
                    initialize d_ctc41m00.* to null
                    error   " Controladora excluida!"
                    message ""
                    clear form
                 end if

               end if

            end if

            exit menu
 end menu

 return d_ctc41m00.*

end function

#--------------------------#
function ctc41m00_ler(param)
#--------------------------#

 define param         record
    mdtctrcod         like datkmdtctr.mdtctrcod
 end record

 define d_ctc41m00    record
    mdtctrcod         like datkmdtctr.mdtctrcod,
    mdtcnxsrvdes      like datkmdtctr.mdtcnxsrvdes,
    mdtcmuttvqtd      like datkmdtctr.mdtcmuttvqtd,
    mdtttvitv         like datkmdtctr.mdtttvitv,
    mdtaatitv         like datkmdtctr.mdtaatitv,
    mdtcnlplr         like datkmdtctr.mdtcnlplr,
    mdtctrstt         like datkmdtctr.mdtctrstt,
    mdtctrsttdes      char (20),
    caddat            like datkmdtctr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtctr.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod,
    gpsacngrpdes      like datkacngrp.gpsacngrpdes,
    mdtfqcnum         like datkmdtctr.mdtfqcnum,
    mdtfqcdes         like datkmdtctr.mdtfqcdes,
    segrpdatltmpqtd   like datkmdtctr.segrpdatltmpqtd,
    fqctrclimvlcqtd   like datkmdtctr.fqctrclimvlcqtd,
    seglntatltmpqtd   like datkmdtctr.seglntatltmpqtd,
    infctr            char(1),
    previsao          char(50)
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    ctrmdtqtd         smallint,
    ctrmdtqtddes      char (14),
    parametroctg      char(20),
    previsaohor       like datkgeral.atlhor
 end record

 initialize d_ctc41m00 to null
 initialize ws to null

 open cctc41m00007 using param.mdtctrcod
 fetch cctc41m00007 into d_ctc41m00.mdtctrcod,
                         d_ctc41m00.mdtcnxsrvdes,
                         d_ctc41m00.mdtcmuttvqtd,
                         d_ctc41m00.mdtaatitv,
                         d_ctc41m00.mdtttvitv,
                         d_ctc41m00.mdtcnlplr,
                         d_ctc41m00.mdtctrstt,
                         d_ctc41m00.caddat,
                         ws.cademp,
                         ws.cadmat,
                         d_ctc41m00.atldat,
                         ws.atlemp,
                         ws.atlmat,
                         d_ctc41m00.gpsacngrpcod,
                         d_ctc41m00.mdtfqcnum,
                         d_ctc41m00.mdtfqcdes,
                         d_ctc41m00.segrpdatltmpqtd,
                         d_ctc41m00.fqctrclimvlcqtd,
                         d_ctc41m00.seglntatltmpqtd

 if sqlca.sqlcode = notfound   then
    error " Controladora nao cadastrada!"
    initialize d_ctc41m00.*    to null
    return d_ctc41m00.*
 else
    call ctc41m00_func(ws.cademp, ws.cadmat)
         returning d_ctc41m00.cadfunnom

    call ctc41m00_func(ws.atlemp, ws.atlmat)
         returning d_ctc41m00.funnom
 end if

 close cctc41m00007

 open cctc41m00008 using d_ctc41m00.gpsacngrpcod
 fetch cctc41m00008 into d_ctc41m00.gpsacngrpdes
 close cctc41m00008

 open cctc41m00009 using d_ctc41m00.mdtctrstt
 fetch cctc41m00009 into d_ctc41m00.mdtctrsttdes
 close cctc41m00009

 open cctc41m00010 using d_ctc41m00.gpsacngrpcod
 fetch cctc41m00010 into ws.ctrmdtqtd
 close cctc41m00010

 let ws.parametroctg = 'PSOCTGCTR', d_ctc41m00.mdtctrcod
 open cctc41m00013 using ws.parametroctg
 fetch cctc41m00013 into d_ctc41m00.infctr, ws.previsaohor
 close cctc41m00013

 if d_ctc41m00.infctr = 'N' then
    let d_ctc41m00.previsao = null
 else
    let d_ctc41m00.previsao = "sera automaticamente desativada as ", ws.previsaohor
 end if

 let ws.ctrmdtqtddes  =  "Qtde MDT.: " clipped,  ws.ctrmdtqtd  using "#&&&"

 display by name ws.ctrmdtqtddes

 return d_ctc41m00.*

end function

#---------------------------#
function ctc41m00_func(param)
#---------------------------#

 define param  record
        empcod like isskfunc.empcod,
        funmat like isskfunc.funmat
 end record

 define l_funnom like isskfunc.funnom

 let l_funnom = null

 open cctc41m00011 using param.empcod, param.funmat
 fetch cctc41m00011 into l_funnom
 close cctc41m00011

 return l_funnom

end function
