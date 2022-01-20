#############################################################################
# Nome do Modulo: ctc52m00                                          GUSTAVO #
#                                                                           #
# Cadastro de grupo conforme crierios                               DEZ/2000#
#############################################################################
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- ------------------------------------ #
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso  #
#---------------------------------------------------------------------------#

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc52m00()
#------------------------------------------------------------

 define d_ctc52m00   record
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpdes like datktltgrp.c24tltgrpdes,
        c24tltgrpstt like datktltgrp.c24tltgrpstt,
        descsit      char(10),
        caddat       like datktltgrp.caddat,
        cademp       like datktltgrp.cademp,
        cadmat       like datktltgrp.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltgrp.cadusrtip,
        atldat       like datktltgrp.atldat,
        atlemp       like datktltgrp.atlemp,
        atlmat       like datktltgrp.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltgrp.atlusrtip
 end record

 let int_flag = false
 initialize d_ctc52m00.*  to null

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc52m00") then
 #    error " Modulo sem nivel de consulta e atualizacao!"
 #    return
 #end if

 open window ctc52m00 at 04,2 with form "ctc52m00"

 menu "GRUPO_TELETRIM"

 before menu
     hide option all
     show option all
     #PSI 202290
     #if g_issk.acsnivcod >= g_issk.acsnivcns  then
     #   show option "Seleciona", "Proximo", "Anterior"
     #end if
     #if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui"
     #end if

     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa Grupo conforme criterios"
          call ctc52m00_seleciona(d_ctc52m00.c24tltgrpnum)
               returning d_ctc52m00.*
          if d_ctc52m00.c24tltgrpnum  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum Grupo selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo Grupo selecionado"
          message ""
          call ctc52m00_proximo(d_ctc52m00.c24tltgrpnum)
               returning d_ctc52m00.*

 command key ("A") "Anterior"
                   "Mostra Grupo anterior selecionado"
          message ""
          if d_ctc52m00.c24tltgrpnum is not null then
             call ctc52m00_anterior(d_ctc52m00.c24tltgrpnum)
                  returning d_ctc52m00.*
          else
             error " Nenhum Grupo nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                    "Modifica Grupo selecionado"
          message ""
          if d_ctc52m00.c24tltgrpnum is not null then
             call ctc52m00_modifica(d_ctc52m00.c24tltgrpnum, d_ctc52m00.*)
                  returning d_ctc52m00.*
             next option "Seleciona"
          else
             error " Nenhum Grupo selecionado!"
             next option "Seleciona"
          end if
          initialize d_ctc52m00.*  to null

 command key ("I") "Inclui"
                   "Inclui Grupo"
          message ""
          call ctc52m00_inclui()
          next option "Seleciona"
          initialize d_ctc52m00.*  to null

 command key (interrupt,E) "Encerra"
         "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc52m00

 end function  # ctc52m00

#------------------------------------------------------------
 function ctc52m00_seleciona(param)
#------------------------------------------------------------

 define param        record
        c24tltgrpnum like datktltgrp.c24tltgrpnum
 end record

 define d_ctc52m00   record
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpdes like datktltgrp.c24tltgrpdes,
        c24tltgrpstt like datktltgrp.c24tltgrpstt,
        descsit      char(10),
        caddat       like datktltgrp.caddat,
        cademp       like datktltgrp.cademp,
        cadmat       like datktltgrp.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltgrp.cadusrtip,
        atldat       like datktltgrp.atldat,
        atlemp       like datktltgrp.atlemp,
        atlmat       like datktltgrp.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltgrp.atlusrtip
 end record

 let int_flag = false
 initialize d_ctc52m00.*  to null
 let d_ctc52m00.c24tltgrpnum = param.c24tltgrpnum
 clear form

 input by name d_ctc52m00.c24tltgrpnum without defaults

    before field c24tltgrpnum

        display by name d_ctc52m00.c24tltgrpnum attribute (reverse)

    after  field c24tltgrpnum
        display by name d_ctc52m00.c24tltgrpnum

        if d_ctc52m00.c24tltgrpnum is null   then
           error " Grupo deve ser informado!"
           next field c24tltgrpnum
        end if

        select c24tltgrpnum
          from datktltgrp
        where datktltgrp.c24tltgrpnum = d_ctc52m00.c24tltgrpnum

        if sqlca.sqlcode  =  notfound   then
           error " Grupo nao existe!"
           next field c24tltgrpnum
        end if

        on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc52m00.*   to null
    let d_ctc52m00.c24tltgrpnum = param.c24tltgrpnum
    clear form
    error " Operacao cancelada!"
    return d_ctc52m00.*
 end if

 call ctc52m00_ler(d_ctc52m00.c24tltgrpnum)
      returning d_ctc52m00.*

 if d_ctc52m00.c24tltgrpnum is not null   then
    case d_ctc52m00.c24tltgrpstt
         when "A" let d_ctc52m00.descsit = "ATIVO"
         when "C" let d_ctc52m00.descsit = "CANCELADO"
         otherwise
         let d_ctc52m00.descsit   = " "
    end case
    display by name d_ctc52m00.c24tltgrpnum,
                    d_ctc52m00.c24tltgrpdes,
                    d_ctc52m00.c24tltgrpstt,
                    d_ctc52m00.descsit,
                    d_ctc52m00.caddat,
                    d_ctc52m00.atldat,
                    d_ctc52m00.cadnom,
                    d_ctc52m00.atlnom

    call display_ctc52m00(d_ctc52m00.c24tltgrpnum)

 else
    error " Grupo nao existe!"
    initialize d_ctc52m00.*    to null
 end if

 return d_ctc52m00.*

 end function  # ctc52m00_seleciona

#------------------------------------------------------------
 function ctc52m00_proximo(param)
#------------------------------------------------------------

 define param        record
        c24tltgrpnum like datktltgrp.c24tltgrpnum
 end record

 define d_ctc52m00   record
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpdes like datktltgrp.c24tltgrpdes,
        c24tltgrpstt like datktltgrp.c24tltgrpstt,
        descsit      char(10),
        caddat       like datktltgrp.caddat,
        cademp       like datktltgrp.cademp,
        cadmat       like datktltgrp.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltgrp.cadusrtip,
        atldat       like datktltgrp.atldat,
        atlemp       like datktltgrp.atlemp,
        atlmat       like datktltgrp.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltgrp.atlusrtip
 end record

 let int_flag = false

 initialize d_ctc52m00.*   to null

 if param.c24tltgrpnum is null   then
    let param.c24tltgrpnum = 0
 end if

 select min(datktltgrp.c24tltgrpnum)
   into d_ctc52m00.c24tltgrpnum
   from datktltgrp
 where datktltgrp.c24tltgrpnum  >  param.c24tltgrpnum

 if d_ctc52m00.c24tltgrpnum is not null   then
    call ctc52m00_ler(d_ctc52m00.c24tltgrpnum)
         returning d_ctc52m00.*

    if d_ctc52m00.c24tltgrpnum  is not null   then
       call ctc52m00_func(d_ctc52m00.cademp, d_ctc52m00.cadmat)
            returning d_ctc52m00.cadnom

       call ctc52m00_func(d_ctc52m00.atlemp, d_ctc52m00.atlmat)
            returning d_ctc52m00.atlnom
       case d_ctc52m00.c24tltgrpstt
            when "A" let d_ctc52m00.descsit = "ATIVO"
            when "C" let d_ctc52m00.descsit = "CANCELADO"
            otherwise
            let d_ctc52m00.descsit   = " "
       end case
       display by name d_ctc52m00.c24tltgrpnum,
                       d_ctc52m00.c24tltgrpdes,
                       d_ctc52m00.c24tltgrpstt,
                       d_ctc52m00.descsit,
                       d_ctc52m00.caddat,
                       d_ctc52m00.atldat,
                       d_ctc52m00.cadnom,
                       d_ctc52m00.atlnom

       call display_ctc52m00(d_ctc52m00.c24tltgrpnum)
    else
       error " Nao ha' Grupo nesta direcao!"
       initialize d_ctc52m00.*    to null
    end if
 else
    error " Nao ha' Grupo nesta direcao!"
    initialize d_ctc52m00.*    to null

 end if

 return d_ctc52m00.*

 end function    # ctc52m00_proximo

#------------------------------------------------------------
 function ctc52m00_anterior(param)
#------------------------------------------------------------

 define param        record
        c24tltgrpnum like datktltgrp.c24tltgrpnum
 end record

 define d_ctc52m00   record
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpdes like datktltgrp.c24tltgrpdes,
        c24tltgrpstt like datktltgrp.c24tltgrpstt,
        descsit      char(10),
        caddat       like datktltgrp.caddat,
        cademp       like datktltgrp.cademp,
        cadmat       like datktltgrp.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltgrp.cadusrtip,
        atldat       like datktltgrp.atldat,
        atlemp       like datktltgrp.atlemp,
        atlmat       like datktltgrp.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltgrp.atlusrtip
 end record

 let int_flag = false
 initialize d_ctc52m00.*  to null

 if param.c24tltgrpnum  is null   then
    let param.c24tltgrpnum = 0
 end if

 select max(datktltgrp.c24tltgrpnum)
   into d_ctc52m00.c24tltgrpnum
   from datktltgrp
  where datktltgrp.c24tltgrpnum  <  param.c24tltgrpnum

 if d_ctc52m00.c24tltgrpnum is not null   then

    call ctc52m00_ler(d_ctc52m00.c24tltgrpnum)
         returning d_ctc52m00.*

    if d_ctc52m00.c24tltgrpnum is not null   then
       call ctc52m00_func(d_ctc52m00.cademp, d_ctc52m00.cadmat)
            returning d_ctc52m00.cadnom

       call ctc52m00_func(d_ctc52m00.atlemp, d_ctc52m00.atlmat)
            returning d_ctc52m00.atlnom
       case d_ctc52m00.c24tltgrpstt
            when "A" let d_ctc52m00.descsit = "ATIVO"
            when "C" let d_ctc52m00.descsit = "CANCELADO"
            otherwise
            let d_ctc52m00.descsit   = " "
       end case
       display by name d_ctc52m00.c24tltgrpnum,
                       d_ctc52m00.c24tltgrpdes,
                       d_ctc52m00.c24tltgrpstt,
                       d_ctc52m00.descsit,
                       d_ctc52m00.caddat,
                       d_ctc52m00.atldat,
                       d_ctc52m00.cadnom,
                       d_ctc52m00.atlnom

       call display_ctc52m00(d_ctc52m00.c24tltgrpnum)
    else
       error " Nao ha' Grupo nesta direcao!"
       initialize d_ctc52m00.*    to null
    end if
 else
    error " Nao ha' Grupo nesta direcao!"
    initialize d_ctc52m00.*    to null
 end if

 return d_ctc52m00.*

 end function    # ctc52m00_anterior


#------------------------------------------------------------
 function ctc52m00_modifica(param, d_ctc52m00)
#------------------------------------------------------------

 define param        record
        c24tltgrpnum like datktltgrp.c24tltgrpnum
 end record

 define d_ctc52m00   record
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpdes like datktltgrp.c24tltgrpdes,
        c24tltgrpstt like datktltgrp.c24tltgrpstt,
        descsit      char(10),
        caddat       like datktltgrp.caddat,
        cademp       like datktltgrp.cademp,
        cadmat       like datktltgrp.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltgrp.cadusrtip,
        atldat       like datktltgrp.atldat,
        atlemp       like datktltgrp.atlemp,
        atlmat       like datktltgrp.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltgrp.atlusrtip
 end record

 call ctc52m00_ler(d_ctc52m00.c24tltgrpnum)
      returning d_ctc52m00.*

 if d_ctc52m00.c24tltgrpnum is null then
    error " Registro nao localizado "
    return param.*
 end if

 call ctc52m00_input("a", d_ctc52m00.*) returning d_ctc52m00.*


 if int_flag  then
    let int_flag = false
    initialize d_ctc52m00.*  to null
    clear form
    error " Operacao cancelada!"
    return d_ctc52m00.*
 end if

 whenever error continue

 begin work
    update datktltgrp    set  ( c24tltgrpdes,
                                c24tltgrpstt,
                                atldat,
                                atlemp,
                                atlmat,
                                atlusrtip)
                           =  ( d_ctc52m00.c24tltgrpdes,
                                d_ctc52m00.c24tltgrpstt,
                                today,
                                g_issk.empcod,
                                g_issk.funmat,
                                g_issk.usrtip)
    where datktltgrp.c24tltgrpnum = param.c24tltgrpnum

    if sqlca.sqlcode <>  0  then
      error " Erro (",sqlca.sqlcode,") na alteracao do grupo!"
      rollback work
      initialize d_ctc52m00.*   to null
      return d_ctc52m00.*
   end if

   call ctc52m01("a", d_ctc52m00.c24tltgrpnum, d_ctc52m00.c24tltgrpdes,
                      d_ctc52m00.c24tltgrpstt, d_ctc52m00.descsit,
                      d_ctc52m00.caddat,       d_ctc52m00.cademp,
                      d_ctc52m00.cadmat,       d_ctc52m00.cadnom,
                      d_ctc52m00.cadusrtip,    d_ctc52m00.atldat,
                      d_ctc52m00.atlemp,       d_ctc52m00.atlmat,
                      d_ctc52m00.atlnom,       d_ctc52m00.atlusrtip)

   commit work

   whenever error stop

   clear form
   initialize d_ctc52m00.*  to null
   message ""
   return d_ctc52m00.*

 end function   #  ctc52m00_modifica

#------------------------------------------------------------
 function ctc52m00_inclui()
#------------------------------------------------------------

 define d_ctc52m00   record
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpdes like datktltgrp.c24tltgrpdes,
        c24tltgrpstt like datktltgrp.c24tltgrpstt,
        descsit      char(10),
        caddat       like datktltgrp.caddat,
        cademp       like datktltgrp.cademp,
        cadmat       like datktltgrp.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltgrp.cadusrtip,
        atldat       like datktltgrp.atldat,
        atlemp       like datktltgrp.atlemp,
        atlmat       like datktltgrp.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltgrp.atlusrtip
 end record

 define  ws_resp      char(01)

 initialize d_ctc52m00.*   to null

 clear form

 call ctc52m00_input("i", d_ctc52m00.*) returning d_ctc52m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc52m00.*  to null
    clear form
    error " Operacao cancelada!"
    return
 end if

    call ctc52m01("i", d_ctc52m00.c24tltgrpnum, d_ctc52m00.c24tltgrpdes,
                       d_ctc52m00.c24tltgrpstt, d_ctc52m00.descsit,
                       d_ctc52m00.caddat,       d_ctc52m00.cademp,
                       d_ctc52m00.cadmat,       d_ctc52m00.cadnom,
                       d_ctc52m00.cadusrtip,    d_ctc52m00.atldat,
                       d_ctc52m00.atlemp,       d_ctc52m00.atlmat,
                       d_ctc52m00.atlnom,       d_ctc52m00.atlusrtip)

    initialize d_ctc52m00.*  to null

    clear form
    message ""

 end function   #  ctc52m00_inclui

#--------------------------------------------------------------------
 function ctc52m00_input(param, d_ctc52m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc52m00   record
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpdes like datktltgrp.c24tltgrpdes,
        c24tltgrpstt like datktltgrp.c24tltgrpstt,
        descsit      char(10),
        caddat       like datktltgrp.caddat,
        cademp       like datktltgrp.cademp,
        cadmat       like datktltgrp.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltgrp.cadusrtip,
        atldat       like datktltgrp.atldat,
        atlemp       like datktltgrp.atlemp,
        atlmat       like datktltgrp.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltgrp.atlusrtip
 end record

 define ws           record
        c24tltgrpnum like datktltgrp.c24tltgrpnum
 end record

 initialize ws.*  to null
 let int_flag     =  false

 input by name d_ctc52m00.c24tltgrpdes,
               d_ctc52m00.c24tltgrpstt without defaults

    before field c24tltgrpdes
           display by name d_ctc52m00.c24tltgrpdes attribute (reverse)

    after  field c24tltgrpdes
           display by name d_ctc52m00.c24tltgrpdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field c24tltgrpdes
           end if

           if d_ctc52m00.c24tltgrpdes  is null   then
              error " Grupo deve ser informado!"
              next field c24tltgrpdes
           end if

    before field c24tltgrpstt
           display by name d_ctc52m00.c24tltgrpstt attribute (reverse)

    after field c24tltgrpstt
           display by name d_ctc52m00.c24tltgrpstt

           if fgl_lastkey() = fgl_keyval("up")   and
              fgl_lastkey() = fgl_keyval("left") then
              next field c24tltgrpstt
           end if

           case d_ctc52m00.c24tltgrpstt
                when "A" let d_ctc52m00.descsit = "ATIVO"
                when "C" let d_ctc52m00.descsit = "CANCELADO"
                otherwise error " Situacao deve ser: (A)Ativo, (C)Cancelado!"
                next field c24tltgrpstt
           end case

           display by name d_ctc52m00.descsit

        on key (interrupt)
        exit input
 end input

 if int_flag   then
    initialize d_ctc52m00.*  to null
 end if

 return d_ctc52m00.*

 end function   # ctc52m00_input

#--------------------------------------------------------------------
 function ctc52m00_ler(param)
#--------------------------------------------------------------------

 define param        record
        c24tltgrpnum like datktltgrp.c24tltgrpnum
 end record

 define d_ctc52m00   record
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpdes like datktltgrp.c24tltgrpdes,
        c24tltgrpstt like datktltgrp.c24tltgrpstt,
        descsit      char(10),
        caddat       like datktltgrp.caddat,
        cademp       like datktltgrp.cademp,
        cadmat       like datktltgrp.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltgrp.cadusrtip,
        atldat       like datktltgrp.atldat,
        atlemp       like datktltgrp.atlemp,
        atlmat       like datktltgrp.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltgrp.atlusrtip
 end record

 initialize d_ctc52m00.*   to null

 select  c24tltgrpnum,
         c24tltgrpdes,
         c24tltgrpstt,
         caddat,
         cademp,
         cadmat,
         cadusrtip,
         atldat,
         atlemp,
         atlmat,
         atlusrtip
 into
         d_ctc52m00.c24tltgrpnum,
         d_ctc52m00.c24tltgrpdes,
         d_ctc52m00.c24tltgrpstt,
         d_ctc52m00.caddat,
         d_ctc52m00.cademp,
         d_ctc52m00.cadmat,
         d_ctc52m00.cadusrtip,
         d_ctc52m00.atldat,
         d_ctc52m00.atlemp,
         d_ctc52m00.atlmat,
         d_ctc52m00.atlusrtip
 from datktltgrp
 where datktltgrp.c24tltgrpnum = param.c24tltgrpnum

 if sqlca.sqlcode = notfound   then
    error " Grupo nao existe!"
    initialize d_ctc52m00.*    to null
    return d_ctc52m00.*
 end if

 call ctc52m00_func(d_ctc52m00.cademp, d_ctc52m00.cadmat)
      returning d_ctc52m00.cadnom

 call ctc52m00_func(d_ctc52m00.atlemp, d_ctc52m00.atlmat)
      returning d_ctc52m00.atlnom

 return d_ctc52m00.*

 end function   # ctc52m00_ler

#---------------------------------------------------------
 function display_ctc52m00(par_c24tltgrpnum)
#---------------------------------------------------------

 define par_c24tltgrpnum  like datktltgrp.c24tltgrpnum

 define a_ctc52m00  array[100] of record
        atdvclsgl   like datktltgrpitm.atdvclsgl,
        vcldes      char(58),
        pgrnum      like datktltgrpitm.pgrnum,
        ustnom      like htlrust.ustnom,
        contr       char(01)
 end record

 define ws           record
        comando      char(400),
        vclcoddig   like datkveiculo.vclcoddig,
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpseq like datktltgrpitm.c24tltgrpseq,
        atdvclsgl    like datktltgrpitm.atdvclsgl,
        pgrnum       like datktltgrpitm.pgrnum,
        ustnom       like htlrust.ustnom
 end record

 define arr_aux      smallint

 initialize a_ctc52m00 to null
 initialize ws.*      to null
 let arr_aux = 1

 let ws.comando = " select vclcoddig      ",
                  " from datkveiculo      ",
                  " where atdvclsgl  = ?  "
 prepare s_datkveiculo from ws.comando
 declare c_datkveiculo cursor for s_datkveiculo

 let ws.comando = " select ustnom         ",
                  " from htlrust          ",
                  " where pgrnum = ?      "
 prepare s_htlrust from ws.comando
 declare c_htlrust cursor for s_htlrust

 declare c_datktltgrpitm cursor for
    select atdvclsgl, pgrnum
    from datktltgrpitm
    where c24tltgrpnum = par_c24tltgrpnum

 foreach c_datktltgrpitm into a_ctc52m00[arr_aux].atdvclsgl,
                              a_ctc52m00[arr_aux].pgrnum

    if a_ctc52m00[arr_aux].atdvclsgl is not null then
       open c_datkveiculo using a_ctc52m00[arr_aux].atdvclsgl
       fetch c_datkveiculo into ws.vclcoddig
       close c_datkveiculo

       call cts15g00(ws.vclcoddig)
            returning a_ctc52m00[arr_aux].vcldes
    end if

    if a_ctc52m00[arr_aux].pgrnum is not null then
       open c_htlrust using a_ctc52m00[arr_aux].pgrnum
       fetch c_htlrust into a_ctc52m00[arr_aux].ustnom
       close c_htlrust
    end if

    let arr_aux = arr_aux + 1
    if arr_aux > 100 then
       error " Limite excedido! Grupo com mais de 100 itens!"
       exit foreach
    end if
 end foreach

 error ""
 call set_count(arr_aux - 1)
 message " (F17)Abandona"

 display array a_ctc52m00 to s_ctc52m00.*
    on key(interrupt)
    let int_flag = false
    exit display
 end display
 message ""
end function ### display_ctc52m00

#---------------------------------------------------------
 function ctc52m00_func(k_ctc52m00)
#---------------------------------------------------------

 define k_ctc52m00 record
    empcod         like isskfunc.empcod ,
    funmat         like isskfunc.funmat
 end record

 define ws         record
    funnom         like isskfunc.funnom
 end record

 let ws.funnom = "NAO CADASTRADO!"

 select funnom
   into ws.funnom
   from isskfunc
  where empcod = k_ctc52m00.empcod  and
        funmat = k_ctc52m00.funmat

 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

end function  ###  ctc52m00_func

























