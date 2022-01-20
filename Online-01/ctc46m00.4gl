 ###########################################################################
 # Nome do Modulo: ctc46m00                                        Marcelo #
 #                                                                Gilberto #
 # Cadastro de configuracoes de MDT's                             Nov/1999 #
 ###########################################################################
 #                                                                         #
 #                  * * * Alteracoes * * *                                 #
 #                                                                         #
 # Data        Autor Fabrica  Origem    Alteracao                          #
 # ----------  -------------- --------- ---------------------------------- #
 # 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso#
 #-------------------------------------------------------------------------#

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc46m00()
#------------------------------------------------------------

 define d_ctc46m00    record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdttrxtmpitv      like datkmdtcfg.mdttrxtmpitv,
    mdtrtrtmpitv      like datkmdtcfg.mdtrtrtmpitv,
    mdtttvrinitvmin   like datkmdtcfg.mdtttvrinitvmin,
    mdtcnlplrcod      like datkmdtcfg.mdtcnlplrcod,
    mdtmvtitvmin      like datkmdtcfg.mdtmvtitvmin,
    mdtprditvmin      like datkmdtcfg.mdtprditvmin,
    mdtlimvlc         like datkmdtcfg.mdtlimvlc,
    mdtptdenvcod      like datkmdtcfg.mdtptdenvcod,
    mdtptdenvdes      char (15),
    mdtmsgapgflg      like datkmdtcfg.mdtmsgapgflg,
    mdtfncpriflg      like datkmdtcfg.mdtfncpriflg,
    mdtfncsegflg      like datkmdtcfg.mdtfncsegflg,
    mdtcfgstt         like datkmdtcfg.mdtcfgstt,
    caddat            like datkmdtcfg.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtcfg.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc46m00.*  to null

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc46m00") then
 #   error " Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 open window ctc46m00 at 4,2 with form "ctc46m00"

 menu "CONFIGURACOES"

  before menu
     hide option all
     #PSI 202290
     #if g_issk.acsnivcod >= g_issk.acsnivcns  then
     #   show option "Seleciona", "Proximo", "Anterior"
     #end if
     #if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "Remove"
     #end if

     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa configuracao de MDT conforme criterios"
          clear form
          call ctc46m00_seleciona()  returning d_ctc46m00.*
          if d_ctc46m00.mdtcfgcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma configuracao de MDT selecionada!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proxima configuracao de MDT selecionada"
          message ""
          call ctc46m00_proximo(d_ctc46m00.mdtcfgcod)
               returning d_ctc46m00.*

 command key ("A") "Anterior"
                   "Mostra configuracao de MDT anterior selecionada"
          message ""
          if d_ctc46m00.mdtcfgcod is not null then
             call ctc46m00_anterior(d_ctc46m00.mdtcfgcod)
                  returning d_ctc46m00.*
          else
             error " Nenhuma configuracao de MDT nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica configuracao de MDT corrente selecionada"
          message ""
          if d_ctc46m00.mdtcfgcod  is not null then
             call ctc46m00_modifica(d_ctc46m00.mdtcfgcod, d_ctc46m00.*)
                  returning d_ctc46m00.*
             next option "Seleciona"
          else
             error " Nenhuma configuracao de MDT selecionada!"
             next option "Seleciona"
          end if
          clear form
          initialize d_ctc46m00.*  to null

 command key ("I") "Inclui"
                   "Inclui configuracao de MDT"
          message ""
          clear form
          call ctc46m00_inclui()
          next option "Seleciona"
          initialize d_ctc46m00.*  to null

 command "Remove" "Remove configuracao de MDT corrente selecionada"
          message ""
          if d_ctc46m00.mdtcfgcod  is not null   then
             call ctc46m00_remove(d_ctc46m00.*)
                  returning d_ctc46m00.*
             next option "Seleciona"
          else
             error " Nenhuma configuracao de MDT selecionada!"
             next option "Seleciona"
          end if
          clear form
          initialize d_ctc46m00.*  to null

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc46m00

 end function  # ctc46m00


#------------------------------------------------------------
 function ctc46m00_seleciona()
#------------------------------------------------------------

 define d_ctc46m00    record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdttrxtmpitv      like datkmdtcfg.mdttrxtmpitv,
    mdtrtrtmpitv      like datkmdtcfg.mdtrtrtmpitv,
    mdtttvrinitvmin   like datkmdtcfg.mdtttvrinitvmin,
    mdtcnlplrcod      like datkmdtcfg.mdtcnlplrcod,
    mdtmvtitvmin      like datkmdtcfg.mdtmvtitvmin,
    mdtprditvmin      like datkmdtcfg.mdtprditvmin,
    mdtlimvlc         like datkmdtcfg.mdtlimvlc,
    mdtptdenvcod      like datkmdtcfg.mdtptdenvcod,
    mdtptdenvdes      char (15),
    mdtmsgapgflg      like datkmdtcfg.mdtmsgapgflg,
    mdtfncpriflg      like datkmdtcfg.mdtfncpriflg,
    mdtfncsegflg      like datkmdtcfg.mdtfncsegflg,
    mdtcfgstt         like datkmdtcfg.mdtcfgstt,
    caddat            like datkmdtcfg.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtcfg.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc46m00.*  to null
 display by name d_ctc46m00.*

 input by name d_ctc46m00.mdtcfgcod

    before field mdtcfgcod
        display by name d_ctc46m00.mdtcfgcod attribute (reverse)

    after  field mdtcfgcod
        display by name d_ctc46m00.mdtcfgcod

        if d_ctc46m00.mdtcfgcod  is null   then
           error " Configuracao deve ser informada!"
           next field mdtcfgcod
        end if

        select mdtcfgcod
          from datkmdtcfg
         where datkmdtcfg.mdtcfgcod = d_ctc46m00.mdtcfgcod

        if sqlca.sqlcode  =  notfound   then
           error " Configuracao nao cadastrada!"
           next field mdtcfgcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc46m00.*   to null
    display by name d_ctc46m00.*
    error " Operacao cancelada!"
    return d_ctc46m00.*
 end if

 call ctc46m00_ler(d_ctc46m00.mdtcfgcod)
      returning d_ctc46m00.*

 if d_ctc46m00.mdtcfgcod  is not null   then
    display by name  d_ctc46m00.*
 else
    error " Configuracao nao cadastrada!"
    initialize d_ctc46m00.*    to null
 end if

 return d_ctc46m00.*

 end function  # ctc46m00_seleciona


#------------------------------------------------------------
 function ctc46m00_proximo(param)
#------------------------------------------------------------

 define param         record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod
 end record

 define d_ctc46m00    record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdttrxtmpitv      like datkmdtcfg.mdttrxtmpitv,
    mdtrtrtmpitv      like datkmdtcfg.mdtrtrtmpitv,
    mdtttvrinitvmin   like datkmdtcfg.mdtttvrinitvmin,
    mdtcnlplrcod      like datkmdtcfg.mdtcnlplrcod,
    mdtmvtitvmin      like datkmdtcfg.mdtmvtitvmin,
    mdtprditvmin      like datkmdtcfg.mdtprditvmin,
    mdtlimvlc         like datkmdtcfg.mdtlimvlc,
    mdtptdenvcod      like datkmdtcfg.mdtptdenvcod,
    mdtptdenvdes      char (15),
    mdtmsgapgflg      like datkmdtcfg.mdtmsgapgflg,
    mdtfncpriflg      like datkmdtcfg.mdtfncpriflg,
    mdtfncsegflg      like datkmdtcfg.mdtfncsegflg,
    mdtcfgstt         like datkmdtcfg.mdtcfgstt,
    caddat            like datkmdtcfg.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtcfg.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc46m00.*   to null

 if param.mdtcfgcod  is null   then
    let param.mdtcfgcod = 0
 end if

 select min(datkmdtcfg.mdtcfgcod)
   into d_ctc46m00.mdtcfgcod
   from datkmdtcfg
  where datkmdtcfg.mdtcfgcod  >  param.mdtcfgcod

 if d_ctc46m00.mdtcfgcod  is not null   then

    call ctc46m00_ler(d_ctc46m00.mdtcfgcod)
         returning d_ctc46m00.*

    if d_ctc46m00.mdtcfgcod  is not null   then
       display by name d_ctc46m00.*
    else
       error " Nao ha' configuracao nesta direcao!"
       initialize d_ctc46m00.*    to null
    end if
 else
    error " Nao ha' configuracao nesta direcao!"
    initialize d_ctc46m00.*    to null
 end if

 return d_ctc46m00.*

 end function    # ctc46m00_proximo


#------------------------------------------------------------
 function ctc46m00_anterior(param)
#------------------------------------------------------------

 define param         record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod
 end record

 define d_ctc46m00    record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdttrxtmpitv      like datkmdtcfg.mdttrxtmpitv,
    mdtrtrtmpitv      like datkmdtcfg.mdtrtrtmpitv,
    mdtttvrinitvmin   like datkmdtcfg.mdtttvrinitvmin,
    mdtcnlplrcod      like datkmdtcfg.mdtcnlplrcod,
    mdtmvtitvmin      like datkmdtcfg.mdtmvtitvmin,
    mdtprditvmin      like datkmdtcfg.mdtprditvmin,
    mdtlimvlc         like datkmdtcfg.mdtlimvlc,
    mdtptdenvcod      like datkmdtcfg.mdtptdenvcod,
    mdtptdenvdes      char (15),
    mdtmsgapgflg      like datkmdtcfg.mdtmsgapgflg,
    mdtfncpriflg      like datkmdtcfg.mdtfncpriflg,
    mdtfncsegflg      like datkmdtcfg.mdtfncsegflg,
    mdtcfgstt         like datkmdtcfg.mdtcfgstt,
    caddat            like datkmdtcfg.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtcfg.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc46m00.*  to null

 if param.mdtcfgcod  is null   then
    let param.mdtcfgcod = 0
 end if

 select max(datkmdtcfg.mdtcfgcod)
   into d_ctc46m00.mdtcfgcod
   from datkmdtcfg
  where datkmdtcfg.mdtcfgcod  <  param.mdtcfgcod

 if d_ctc46m00.mdtcfgcod  is not null   then

    call ctc46m00_ler(d_ctc46m00.mdtcfgcod)
         returning d_ctc46m00.*

    if d_ctc46m00.mdtcfgcod  is not null   then
       display by name  d_ctc46m00.*
    else
       error " Nao ha' configuracao nesta direcao!"
       initialize d_ctc46m00.*    to null
    end if
 else
    error " Nao ha' configuracao nesta direcao!"
    initialize d_ctc46m00.*    to null
 end if

 return d_ctc46m00.*

 end function    # ctc46m00_anterior


#------------------------------------------------------------
 function ctc46m00_modifica(param, d_ctc46m00)
#------------------------------------------------------------

 define param         record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod
 end record

 define d_ctc46m00    record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdttrxtmpitv      like datkmdtcfg.mdttrxtmpitv,
    mdtrtrtmpitv      like datkmdtcfg.mdtrtrtmpitv,
    mdtttvrinitvmin   like datkmdtcfg.mdtttvrinitvmin,
    mdtcnlplrcod      like datkmdtcfg.mdtcnlplrcod,
    mdtmvtitvmin      like datkmdtcfg.mdtmvtitvmin,
    mdtprditvmin      like datkmdtcfg.mdtprditvmin,
    mdtlimvlc         like datkmdtcfg.mdtlimvlc,
    mdtptdenvcod      like datkmdtcfg.mdtptdenvcod,
    mdtptdenvdes      char (15),
    mdtmsgapgflg      like datkmdtcfg.mdtmsgapgflg,
    mdtfncpriflg      like datkmdtcfg.mdtfncpriflg,
    mdtfncsegflg      like datkmdtcfg.mdtfncsegflg,
    mdtcfgstt         like datkmdtcfg.mdtcfgstt,
    caddat            like datkmdtcfg.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtcfg.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctc46m00_input("a", d_ctc46m00.*) returning d_ctc46m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc46m00.*  to null
    display by name d_ctc46m00.*
    error " Operacao cancelada!"
    return d_ctc46m00.*
 end if

 whenever error continue

 let d_ctc46m00.atldat = today

 begin work
    update datkmdtcfg set  ( mdtcfgdes,
                             mdttrxtmpitv,
                             mdtrtrtmpitv,
                             mdtttvrinitvmin,
                             mdtcnlplrcod,
                             mdtmvtitvmin,
                             mdtprditvmin,
                             mdtlimvlc,
                             mdtptdenvcod,
                             mdtmsgapgflg,
                             mdtfncpriflg,
                             mdtfncsegflg,
                             mdtcfgstt,
                             atldat,
                             atlemp,
                             atlmat )
                        =
                           ( d_ctc46m00.mdtcfgdes,
                             d_ctc46m00.mdttrxtmpitv,
                             d_ctc46m00.mdtrtrtmpitv,
                             d_ctc46m00.mdtttvrinitvmin,
                             d_ctc46m00.mdtcnlplrcod,
                             d_ctc46m00.mdtmvtitvmin,
                             d_ctc46m00.mdtprditvmin,
                             d_ctc46m00.mdtlimvlc,
                             d_ctc46m00.mdtptdenvcod,
                             d_ctc46m00.mdtmsgapgflg,
                             d_ctc46m00.mdtfncpriflg,
                             d_ctc46m00.mdtfncsegflg,
                             d_ctc46m00.mdtcfgstt,
                             d_ctc46m00.atldat,
                             g_issk.empcod,
                             g_issk.funmat )
           where datkmdtcfg.mdtcfgcod  =  d_ctc46m00.mdtcfgcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao da configuracao!"
       rollback work
       initialize d_ctc46m00.*   to null
       return d_ctc46m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc46m00.*  to null
 display by name d_ctc46m00.*
 message ""
 return d_ctc46m00.*

 end function   #  ctc46m00_modifica


#------------------------------------------------------------
 function ctc46m00_inclui()
#------------------------------------------------------------

 define d_ctc46m00    record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdttrxtmpitv      like datkmdtcfg.mdttrxtmpitv,
    mdtrtrtmpitv      like datkmdtcfg.mdtrtrtmpitv,
    mdtttvrinitvmin   like datkmdtcfg.mdtttvrinitvmin,
    mdtcnlplrcod      like datkmdtcfg.mdtcnlplrcod,
    mdtmvtitvmin      like datkmdtcfg.mdtmvtitvmin,
    mdtprditvmin      like datkmdtcfg.mdtprditvmin,
    mdtlimvlc         like datkmdtcfg.mdtlimvlc,
    mdtptdenvcod      like datkmdtcfg.mdtptdenvcod,
    mdtptdenvdes      char (15),
    mdtmsgapgflg      like datkmdtcfg.mdtmsgapgflg,
    mdtfncpriflg      like datkmdtcfg.mdtfncpriflg,
    mdtfncsegflg      like datkmdtcfg.mdtfncsegflg,
    mdtcfgstt         like datkmdtcfg.mdtcfgstt,
    caddat            like datkmdtcfg.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtcfg.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp       char(01)


 initialize d_ctc46m00.*   to null
 display by name d_ctc46m00.*

 call ctc46m00_input("i", d_ctc46m00.*) returning d_ctc46m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc46m00.*  to null
    display by name d_ctc46m00.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc46m00.atldat = today
 let d_ctc46m00.caddat = today


 declare c_ctc46m00m  cursor with hold  for
         select  max(mdtcfgcod)
           from  datkmdtcfg
          where  datkmdtcfg.mdtcfgcod > 0

 foreach c_ctc46m00m  into  d_ctc46m00.mdtcfgcod
     exit foreach
 end foreach

 if d_ctc46m00.mdtcfgcod is null   then
    let d_ctc46m00.mdtcfgcod = 0
 end if
 let d_ctc46m00.mdtcfgcod = d_ctc46m00.mdtcfgcod + 1


 whenever error continue

 begin work
    insert into datkmdtcfg ( mdtcfgcod,
                             mdtcfgdes,
                             mdttrxtmpitv,
                             mdtrtrtmpitv,
                             mdtttvrinitvmin,
                             mdtcnlplrcod,
                             mdtmvtitvmin,
                             mdtprditvmin,
                             mdtlimvlc,
                             mdtptdenvcod,
                             mdtmsgapgflg,
                             mdtfncpriflg,
                             mdtfncsegflg,
                             mdtcfgstt,
                             caddat,
                             cademp,
                             cadmat,
                             atldat,
                             atlemp,
                             atlmat )
                  values
                           ( d_ctc46m00.mdtcfgcod,
                             d_ctc46m00.mdtcfgdes,
                             d_ctc46m00.mdttrxtmpitv,
                             d_ctc46m00.mdtrtrtmpitv,
                             d_ctc46m00.mdtttvrinitvmin,
                             d_ctc46m00.mdtcnlplrcod,
                             d_ctc46m00.mdtmvtitvmin,
                             d_ctc46m00.mdtprditvmin,
                             d_ctc46m00.mdtlimvlc,
                             d_ctc46m00.mdtptdenvcod,
                             d_ctc46m00.mdtmsgapgflg,
                             d_ctc46m00.mdtfncpriflg,
                             d_ctc46m00.mdtfncsegflg,
                             d_ctc46m00.mdtcfgstt,
                             d_ctc46m00.caddat,
                             g_issk.empcod,
                             g_issk.funmat,
                             d_ctc46m00.atldat,
                             g_issk.empcod,
                             g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao da configuracao!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc46m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc46m00.cadfunnom

 call ctc46m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc46m00.funnom

 display by name  d_ctc46m00.*

 display by name d_ctc46m00.mdtcfgcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc46m00.*  to null
 display by name d_ctc46m00.*

 end function   #  ctc46m00_inclui


#--------------------------------------------------------------------
 function ctc46m00_input(param, d_ctc46m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc46m00    record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdttrxtmpitv      like datkmdtcfg.mdttrxtmpitv,
    mdtrtrtmpitv      like datkmdtcfg.mdtrtrtmpitv,
    mdtttvrinitvmin   like datkmdtcfg.mdtttvrinitvmin,
    mdtcnlplrcod      like datkmdtcfg.mdtcnlplrcod,
    mdtmvtitvmin      like datkmdtcfg.mdtmvtitvmin,
    mdtprditvmin      like datkmdtcfg.mdtprditvmin,
    mdtlimvlc         like datkmdtcfg.mdtlimvlc,
    mdtptdenvcod      like datkmdtcfg.mdtptdenvcod,
    mdtptdenvdes      char (15),
    mdtmsgapgflg      like datkmdtcfg.mdtmsgapgflg,
    mdtfncpriflg      like datkmdtcfg.mdtfncpriflg,
    mdtfncsegflg      like datkmdtcfg.mdtfncsegflg,
    mdtcfgstt         like datkmdtcfg.mdtcfgstt,
    caddat            like datkmdtcfg.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtcfg.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    cont              dec  (6,0)
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name d_ctc46m00.mdtcfgdes,
               d_ctc46m00.mdttrxtmpitv,
               d_ctc46m00.mdtrtrtmpitv,
               d_ctc46m00.mdtttvrinitvmin,
               d_ctc46m00.mdtcnlplrcod,
               d_ctc46m00.mdtmvtitvmin,
               d_ctc46m00.mdtprditvmin,
               d_ctc46m00.mdtlimvlc,
               d_ctc46m00.mdtptdenvcod,
               d_ctc46m00.mdtmsgapgflg,
               d_ctc46m00.mdtfncpriflg,
               d_ctc46m00.mdtfncsegflg,
               d_ctc46m00.mdtcfgstt  without defaults

    before field mdtcfgdes
           display by name d_ctc46m00.mdtcfgdes    attribute (reverse)

    after  field mdtcfgdes
           display by name d_ctc46m00.mdtcfgdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtcfgdes
           end if

           if d_ctc46m00.mdtcfgdes  is null   then
              error " Descricao da configuracao deve ser informada!"
              next field mdtcfgdes
           end if

    before field mdttrxtmpitv
           display by name d_ctc46m00.mdttrxtmpitv attribute (reverse)

    after  field mdttrxtmpitv
           display by name d_ctc46m00.mdttrxtmpitv

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtcfgdes
           end if

           if d_ctc46m00.mdttrxtmpitv  is null   then
              error " Intervalo para transmissao deve ser informado!"
              next field mdttrxtmpitv
           end if

    before field mdtrtrtmpitv
           display by name d_ctc46m00.mdtrtrtmpitv attribute (reverse)

    after  field mdtrtrtmpitv
           display by name d_ctc46m00.mdtrtrtmpitv

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdttrxtmpitv
           end if

           if d_ctc46m00.mdtrtrtmpitv  is null   then
              error " Intervalo para retransmissao deve ser informado!"
              next field mdtrtrtmpitv
           end if

           if d_ctc46m00.mdtrtrtmpitv  >  53612   then
              error " Intervalo nao deve ser maior que 53612 milisegundos!"
              next field mdtrtrtmpitv
           end if

    before field mdtttvrinitvmin
           display by name d_ctc46m00.mdtttvrinitvmin attribute (reverse)

    after  field mdtttvrinitvmin
           display by name d_ctc46m00.mdtttvrinitvmin

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtrtrtmpitv
           end if

           if d_ctc46m00.mdtttvrinitvmin  is null   then
              error " Intervalo p/ reinicio de transmissao deve ser informado!"
              next field mdtttvrinitvmin
           end if

           if d_ctc46m00.mdtttvrinitvmin  >  "16:30"  then
              error " Intervalo para reinicio nao deve ser maior que 16:30!"
              next field mdtttvrinitvmin
           end if

    before field mdtcnlplrcod
           display by name d_ctc46m00.mdtcnlplrcod attribute (reverse)

    after  field mdtcnlplrcod
           display by name d_ctc46m00.mdtcnlplrcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field mdtttvrinitvmin
           end if

           if d_ctc46m00.mdtcnlplrcod  is null   then
              error " Polaridade do canal deve ser informado!"
              next field mdtcnlplrcod
           end if

           if d_ctc46m00.mdtcnlplrcod  <>  0   and
              d_ctc46m00.mdtcnlplrcod  <>  1   and
              d_ctc46m00.mdtcnlplrcod  <>  2   and
              d_ctc46m00.mdtcnlplrcod  <>  3   then
              error " Polaridade do canal deve ser: 0,1,2 ou 3!"
              next field mdtcnlplrcod
           end if

    before field mdtmvtitvmin
           display by name d_ctc46m00.mdtmvtitvmin attribute (reverse)

    after  field mdtmvtitvmin
           display by name d_ctc46m00.mdtmvtitvmin

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field mdtcnlplrcod
           end if

           if d_ctc46m00.mdtmvtitvmin  is null   then
              error " Intervalo p/ transmissao em movimento deve ser informado!"
              next field mdtmvtitvmin
           end if

           if d_ctc46m00.mdtmvtitvmin  <  "00:30"   then
              error " Intervalo p/ transmissao nao deve ser menor que 00:30 segundos!"
              next field mdtmvtitvmin
           end if

           if d_ctc46m00.mdtmvtitvmin  >  "30:00"   then
              error " Intervalo p/ transmissao nao deve ser maior que 30 minutos!"
              next field mdtmvtitvmin
           end if

    before field mdtprditvmin
           display by name d_ctc46m00.mdtprditvmin attribute (reverse)

    after  field mdtprditvmin
           display by name d_ctc46m00.mdtprditvmin

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtmvtitvmin
           end if

           if d_ctc46m00.mdtprditvmin  is null   then
              error " Intervalo para transmissao parado deve ser informado!"
              next field mdtprditvmin
           end if

           if d_ctc46m00.mdtprditvmin  <  "03:00"   then
              error " Intervalo p/ transmissao nao deve ser menor que 3 minutos!"
              next field mdtprditvmin
           end if

           if d_ctc46m00.mdtprditvmin  >  "50:00"   then
              error " Intervalo p/ transmissao nao deve ser maior que 50 minutos!"
              next field mdtprditvmin
           end if

    before field mdtlimvlc
           display by name d_ctc46m00.mdtlimvlc attribute (reverse)

    after  field mdtlimvlc
           display by name d_ctc46m00.mdtlimvlc

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtprditvmin
           end if

           if d_ctc46m00.mdtlimvlc  is null   then
              error " Velocidade limite deve ser informada!"
              next field mdtlimvlc
           end if

           if d_ctc46m00.mdtlimvlc  <  5   then
              error " Velocidade limite nao deve ser menor que 5 KM!"
              next field mdtlimvlc
           end if

           if d_ctc46m00.mdtlimvlc  >  30   then
              error " Velocidade limite nao deve ser maior que 30 KM!"
              next field mdtlimvlc
           end if

    before field mdtptdenvcod
           display by name d_ctc46m00.mdtptdenvcod attribute (reverse)

    after  field mdtptdenvcod
           display by name d_ctc46m00.mdtptdenvcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field mdtlimvlc
           end if

           if d_ctc46m00.mdtptdenvcod  is null   then
              error " Codigo p/ envio sinal identificador deve ser informado!"
              call ctn36c00("Sinal identificador de PTT", "mdtptdenvcod")
                   returning  d_ctc46m00.mdtptdenvcod
              next field mdtptdenvcod
           end if

           select cpodes
             into d_ctc46m00.mdtptdenvdes
             from iddkdominio
            where cponom  =  "mdtptdenvcod"
              and cpocod  =  d_ctc46m00.mdtptdenvcod

           if sqlca.sqlcode  =  notfound   then
              error " Codigo p/ envio sinal identificador de PTT nao cadastrado!"
              call ctn36c00("Sinal identificador de PTT", "mdtptdenvcod")
                   returning  d_ctc46m00.mdtptdenvcod
              next field mdtptdenvcod
           end if
           display by name d_ctc46m00.mdtptdenvdes

    before field mdtmsgapgflg
           display by name d_ctc46m00.mdtmsgapgflg attribute (reverse)

    after  field mdtmsgapgflg
           display by name d_ctc46m00.mdtmsgapgflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field mdtptdenvcod
           end if

           if (d_ctc46m00.mdtmsgapgflg  is null)   or
              (d_ctc46m00.mdtmsgapgflg  <> "S"     and
               d_ctc46m00.mdtmsgapgflg  <> "N")    then
              error " Apaga mensagem display do MDT deve ser: (S)im ou (N)ao!"
              next field mdtmsgapgflg
           end if

    before field mdtfncpriflg
           display by name d_ctc46m00.mdtfncpriflg attribute (reverse)

    after  field mdtfncpriflg
           display by name d_ctc46m00.mdtfncpriflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field mdtmsgapgflg
           end if

           if (d_ctc46m00.mdtfncpriflg  is null)   or
              (d_ctc46m00.mdtfncpriflg  <> "S"     and
               d_ctc46m00.mdtfncpriflg  <> "N")    then
              error " Utiliza funcao 1 do MDT deve ser: (S)im ou (N)ao!"
              next field mdtfncpriflg
           end if

    before field mdtfncsegflg
           display by name d_ctc46m00.mdtfncsegflg attribute (reverse)

    after  field mdtfncsegflg
           display by name d_ctc46m00.mdtfncsegflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field mdtfncpriflg
           end if

           if (d_ctc46m00.mdtfncsegflg  is null)   or
              (d_ctc46m00.mdtfncsegflg  <> "S"     and
               d_ctc46m00.mdtfncsegflg  <> "N")    then
              error " Utiliza funcao 2 do MDT deve ser: (S)im ou (N)ao!"
              next field mdtfncsegflg
           end if

    before field mdtcfgstt
           if param.operacao  =  "i"   then
              let d_ctc46m00.mdtcfgstt = "A"
           end if
           display by name d_ctc46m00.mdtcfgstt attribute (reverse)

    after  field mdtcfgstt
           display by name d_ctc46m00.mdtcfgstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field mdtfncsegflg
           end if

           if (d_ctc46m00.mdtcfgstt  is null)  or
              (d_ctc46m00.mdtcfgstt  <> "A"    and
	       d_ctc46m00.mdtcfgstt  <> "C")   then
              error " Situacao da configuracao deve ser: (A)tiva ou (C)ancelada!"
              next field mdtcfgstt
           end if

           if param.operacao        =  "i"  and
              d_ctc46m00.mdtcfgstt  <> "A"  then
              error " Na inclusao situacao deve ser ATIVA!"
              next field mdtcfgstt
           end if

           if d_ctc46m00.mdtcfgstt = "C"   then
               let ws.cont  =  0

               select count(*)
                 into ws.cont
                 from datkmdt
                where datkmdt.mdtcfgcod  =  d_ctc46m00.mdtcfgcod

               if ws.cont   >  0   then
                  error " Existe MDT com esta configuracao, altere antes do cancelamento!"
                  next field mdtcfgstt
               end if
            end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc46m00.*  to null
 end if

 return d_ctc46m00.*

 end function   # ctc46m00_input


#--------------------------------------------------------------------
 function ctc46m00_remove(d_ctc46m00)
#--------------------------------------------------------------------

 define d_ctc46m00    record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdttrxtmpitv      like datkmdtcfg.mdttrxtmpitv,
    mdtrtrtmpitv      like datkmdtcfg.mdtrtrtmpitv,
    mdtttvrinitvmin   like datkmdtcfg.mdtttvrinitvmin,
    mdtcnlplrcod      like datkmdtcfg.mdtcnlplrcod,
    mdtmvtitvmin      like datkmdtcfg.mdtmvtitvmin,
    mdtprditvmin      like datkmdtcfg.mdtprditvmin,
    mdtlimvlc         like datkmdtcfg.mdtlimvlc,
    mdtptdenvcod      like datkmdtcfg.mdtptdenvcod,
    mdtptdenvdes      char (15),
    mdtmsgapgflg      like datkmdtcfg.mdtmsgapgflg,
    mdtfncpriflg      like datkmdtcfg.mdtfncpriflg,
    mdtfncsegflg      like datkmdtcfg.mdtfncsegflg,
    mdtcfgstt         like datkmdtcfg.mdtcfgstt,
    caddat            like datkmdtcfg.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtcfg.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod
 end record


 initialize ws.*  to null

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui a configuracao"
            clear form
            initialize d_ctc46m00.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui configuracao"
            call ctc46m00_ler(d_ctc46m00.mdtcfgcod) returning d_ctc46m00.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc46m00.* to null
               error " Configuracao nao localizada!"
            else

               initialize ws.mdtcfgcod  to null

               select max (datkmdt.mdtcfgcod)
                 into ws.mdtcfgcod
                 from datkmdt
                where datkmdt.mdtcfgcod = d_ctc46m00.mdtcfgcod

               if ws.mdtcfgcod  is not null   and
                  ws.mdtcfgcod  > 0           then
                  error " Existe MDT cadastrado com esta configuracao, portanto nao deve ser removida!"
                  exit menu
               end if

               begin work
                  delete from datkmdtcfg
                   where datkmdtcfg.mdtcfgcod = d_ctc46m00.mdtcfgcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc46m00.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao da configuracao!"
               else
                  initialize d_ctc46m00.* to null
                  error   " Configuracao excluida!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc46m00.*

end function    # ctc46m00_remove


#---------------------------------------------------------
 function ctc46m00_ler(param)
#---------------------------------------------------------

 define param         record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod
 end record

 define d_ctc46m00    record
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdttrxtmpitv      like datkmdtcfg.mdttrxtmpitv,
    mdtrtrtmpitv      like datkmdtcfg.mdtrtrtmpitv,
    mdtttvrinitvmin   like datkmdtcfg.mdtttvrinitvmin,
    mdtcnlplrcod      like datkmdtcfg.mdtcnlplrcod,
    mdtmvtitvmin      like datkmdtcfg.mdtmvtitvmin,
    mdtprditvmin      like datkmdtcfg.mdtprditvmin,
    mdtlimvlc         like datkmdtcfg.mdtlimvlc,
    mdtptdenvcod      like datkmdtcfg.mdtptdenvcod,
    mdtptdenvdes      char (15),
    mdtmsgapgflg      like datkmdtcfg.mdtmsgapgflg,
    mdtfncpriflg      like datkmdtcfg.mdtfncpriflg,
    mdtfncsegflg      like datkmdtcfg.mdtfncsegflg,
    mdtcfgstt         like datkmdtcfg.mdtcfgstt,
    caddat            like datkmdtcfg.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtcfg.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat
 end record


 initialize d_ctc46m00.*   to null
 initialize ws.*           to null

 select  mdtcfgcod,
         mdtcfgdes,
         mdttrxtmpitv,
         mdtrtrtmpitv,
         mdtttvrinitvmin,
         mdtcnlplrcod,
         mdtmvtitvmin,
         mdtprditvmin,
         mdtlimvlc,
         mdtptdenvcod,
         mdtmsgapgflg,
         mdtfncpriflg,
         mdtfncsegflg,
         mdtcfgstt,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into
         d_ctc46m00.mdtcfgcod,
         d_ctc46m00.mdtcfgdes,
         d_ctc46m00.mdttrxtmpitv,
         d_ctc46m00.mdtrtrtmpitv,
         d_ctc46m00.mdtttvrinitvmin,
         d_ctc46m00.mdtcnlplrcod,
         d_ctc46m00.mdtmvtitvmin,
         d_ctc46m00.mdtprditvmin,
         d_ctc46m00.mdtlimvlc,
         d_ctc46m00.mdtptdenvcod,
         d_ctc46m00.mdtmsgapgflg,
         d_ctc46m00.mdtfncpriflg,
         d_ctc46m00.mdtfncsegflg,
         d_ctc46m00.mdtcfgstt,
         d_ctc46m00.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc46m00.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkmdtcfg
  where  datkmdtcfg.mdtcfgcod = param.mdtcfgcod

 if sqlca.sqlcode = notfound   then
    error " Configuracao nao cadastrada!"
    initialize d_ctc46m00.*    to null
    return d_ctc46m00.*
 else
    select cpodes
      into d_ctc46m00.mdtptdenvdes
      from iddkdominio
     where cponom  =  "mdtptdenvcod"
       and cpocod  =  d_ctc46m00.mdtptdenvcod

    call ctc46m00_func(ws.cademp, ws.cadmat)
         returning d_ctc46m00.cadfunnom

    call ctc46m00_func(ws.atlemp, ws.atlmat)
         returning d_ctc46m00.funnom
 end if

 return d_ctc46m00.*

 end function   # ctc46m00_ler


#---------------------------------------------------------
 function ctc46m00_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = param.empcod
    and isskfunc.funmat = param.funmat

 return ws.funnom

 end function   # ctc46m00_func
