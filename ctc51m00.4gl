#############################################################################
# Nome do Modulo: ctc51m00                                          GUSTAVO #
#                                                                           #
# Cadastro de mensagens conforme crierios                           DEZ/2000#
#############################################################################
#                                                                           #
#                    * * * Alteracoes * * *                                 #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- ------------------------------------ #
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso  #
#---------------------------------------------------------------------------#

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc51m00()
#------------------------------------------------------------

   define d_ctc51m00   record
          tltmsgcod    like datktltmsg.tltmsgcod,
          tltmsgtxt    like datktltmsg.tltmsgtxt,
          tltmsgtxt1   char(50),
          tltmsgtxt2   char(50),
          tltmsgtxt3   char(50),
          tltmsgtxt4   char(50),
          tltmsgtxt5   char(40),
          tltmsgstt    like datktltmsg.tltmsgstt,
          descsit      char(10),
          caddat       like datktltmsg.caddat,
          cademp       like datktltmsg.cademp,
          cadmat       like datktltmsg.cadmat,
          cadnom       like isskfunc.funnom,
          cadusrtip    like datktltmsg.cadusrtip,
          atldat       like datktltmsg.atldat,
          atlemp       like datktltmsg.atlemp,
          atlmat       like datktltmsg.atlmat,
          atlnom       like isskfunc.funnom,
          atlusrtip    like datktltmsg.atlusrtip
   end record

   let int_flag = false
   initialize d_ctc51m00.*  to null

    #PSI 202290
    #if not get_niv_mod(g_issk.prgsgl, "ctc51m00") then
    #    error " Modulo sem nivel de consulta e atualizacao!"
    #    return
    #end if

   open window ctc51m00 at 4,2 with form "ctc51m00"

 menu "MENSAGEM"

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
                    "Pesquisa Mensagem conforme criterios"
          call ctc51m00_seleciona(d_ctc51m00.tltmsgcod)
               returning d_ctc51m00.*
          if d_ctc51m00.tltmsgcod is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma Mensagem selecionada!"
             message ""
             next option "Seleciona"
          end if

  command key ("P") "Proximo"
                    "Mostra proxima Mensagem selecionada"
          message ""
          call ctc51m00_proximo(d_ctc51m00.tltmsgcod)
               returning d_ctc51m00.*

  command key ("A") "Anterior"
                   "Mostra Mensagem anterior selecionado"
          message ""
          if d_ctc51m00.tltmsgcod is not null then
             call ctc51m00_anterior(d_ctc51m00.tltmsgcod)
                  returning d_ctc51m00.*
          else
             error " Nenhuma Mensagem nesta direcao!"
             next option "Seleciona"
          end if

  command key ("M") "Modifica"
                    "Modifica Mensagem selecionada"
          message ""
          if d_ctc51m00.tltmsgcod  is not null then
             call ctc51m00_modifica(d_ctc51m00.tltmsgcod, d_ctc51m00.*)
                  returning d_ctc51m00.*
             next option "Seleciona"
          else
             error " Nenhuma Mensagem  selecionada!"
             next option "Seleciona"
          end if
          initialize d_ctc51m00.*  to null

  command key ("I") "Inclui"
                    "Inclui Mensagem"
          message ""
          call ctc51m00_inclui()
          next option "Seleciona"
          initialize d_ctc51m00.*  to null

  command key (interrupt,E) "Encerra"
         "Retorna ao menu anterior"
          exit menu
  end menu

  close window ctc51m00

  end function  # ctc51m00

#------------------------------------------------------------
 function ctc51m00_seleciona(param)
#------------------------------------------------------------

 define param         record
        tltmsgcod     like datktltmsg.tltmsgcod
 end record

 define d_ctc51m00   record
        tltmsgcod    like datktltmsg.tltmsgcod,
        tltmsgtxt    like datktltmsg.tltmsgtxt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        tltmsgstt    like datktltmsg.tltmsgstt,
        descsit      char(10),
        caddat       like datktltmsg.caddat,
        cademp       like datktltmsg.cademp,
        cadmat       like datktltmsg.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltmsg.cadusrtip,
        atldat       like datktltmsg.atldat,
        atlemp       like datktltmsg.atlemp,
        atlmat       like datktltmsg.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltmsg.atlusrtip
 end record

 let int_flag = false
 initialize d_ctc51m00.*  to null
 let d_ctc51m00.tltmsgcod = param.tltmsgcod
 clear form

 input by name d_ctc51m00.tltmsgcod  without defaults

    before field tltmsgcod

        display by name d_ctc51m00.tltmsgcod attribute (reverse)

    after  field tltmsgcod
        display by name d_ctc51m00.tltmsgcod

        if d_ctc51m00.tltmsgcod is null   then
           error " Mensagem deve ser informada!"
           next field tltmsgcod
        end if

        select tltmsgcod
          from datktltmsg
        where datktltmsg.tltmsgcod = d_ctc51m00.tltmsgcod

        if sqlca.sqlcode  =  notfound   then
           error " Mensagem nao existe!"
           next field tltmsgcod
        end if

        on key (interrupt)
           exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc51m00.*   to null
    let d_ctc51m00.tltmsgcod  =  param.tltmsgcod
    clear form
    error " Operacao cancelada!"
    return d_ctc51m00.*
 end if

 call ctc51m00_ler(d_ctc51m00.tltmsgcod)
      returning d_ctc51m00.*

 if d_ctc51m00.tltmsgcod is not null   then
    case d_ctc51m00.tltmsgstt
         when "A" let d_ctc51m00.descsit = "ATIVO"
         when "C" let d_ctc51m00.descsit = "CANCELADO"
         otherwise
         let d_ctc51m00.descsit = " "
    end case

    let d_ctc51m00.tltmsgtxt1 =  d_ctc51m00.tltmsgtxt[001,050]
    let d_ctc51m00.tltmsgtxt2 =  d_ctc51m00.tltmsgtxt[051,100]
    let d_ctc51m00.tltmsgtxt3 =  d_ctc51m00.tltmsgtxt[101,150]
    let d_ctc51m00.tltmsgtxt4 =  d_ctc51m00.tltmsgtxt[151,200]
    let d_ctc51m00.tltmsgtxt5 =  d_ctc51m00.tltmsgtxt[201,240]

    display by name d_ctc51m00.tltmsgcod,
                    d_ctc51m00.tltmsgtxt1,
                    d_ctc51m00.tltmsgtxt2,
                    d_ctc51m00.tltmsgtxt3,
                    d_ctc51m00.tltmsgtxt4,
                    d_ctc51m00.tltmsgtxt5,
                    d_ctc51m00.tltmsgstt,
                    d_ctc51m00.descsit,
                    d_ctc51m00.caddat,
                    d_ctc51m00.atldat,
                    d_ctc51m00.cadnom,
                    d_ctc51m00.atlnom
 else
    error " Mensagem nao existe!"
    initialize d_ctc51m00.*    to null
 end if

 return d_ctc51m00.*

 end function  # ctc51m00_seleciona

#------------------------------------------------------------
 function ctc51m00_proximo(param)
#------------------------------------------------------------

 define param         record
        tltmsgcod     like datktltmsg.tltmsgcod
 end record

 define d_ctc51m00   record
        tltmsgcod    like datktltmsg.tltmsgcod,
        tltmsgtxt    like datktltmsg.tltmsgtxt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        tltmsgstt    like datktltmsg.tltmsgstt,
        descsit      char(10),
        caddat       like datktltmsg.caddat,
        cademp       like datktltmsg.cademp,
        cadmat       like datktltmsg.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltmsg.cadusrtip,
        atldat       like datktltmsg.atldat,
        atlemp       like datktltmsg.atlemp,
        atlmat       like datktltmsg.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltmsg.atlusrtip
 end record

 let int_flag = false
 initialize d_ctc51m00.*   to null

 if param.tltmsgcod  is null   then
    let param.tltmsgcod = 0
 end if

 select min(datktltmsg.tltmsgcod)
   into d_ctc51m00.tltmsgcod
   from datktltmsg
  where datktltmsg.tltmsgcod  >  param.tltmsgcod

 if d_ctc51m00.tltmsgcod is not null   then
    call ctc51m00_ler(d_ctc51m00.tltmsgcod)
         returning d_ctc51m00.*

    if d_ctc51m00.tltmsgcod is not null   then
       call ctc51m00_func(d_ctc51m00.cademp, d_ctc51m00.cadmat)
            returning d_ctc51m00.cadnom

       call ctc51m00_func(d_ctc51m00.atlemp, d_ctc51m00.atlmat)
            returning d_ctc51m00.atlnom

       case d_ctc51m00.tltmsgstt
            when "A" let d_ctc51m00.descsit = "ATIVO"
            when "C" let d_ctc51m00.descsit = "CANCELADO"
            otherwise
            let d_ctc51m00.descsit = " "
       end case

       let d_ctc51m00.tltmsgtxt1 =  d_ctc51m00.tltmsgtxt[001,050]
       let d_ctc51m00.tltmsgtxt2 =  d_ctc51m00.tltmsgtxt[051,100]
       let d_ctc51m00.tltmsgtxt3 =  d_ctc51m00.tltmsgtxt[101,150]
       let d_ctc51m00.tltmsgtxt4 =  d_ctc51m00.tltmsgtxt[151,200]
       let d_ctc51m00.tltmsgtxt5 =  d_ctc51m00.tltmsgtxt[201,240]

       display by name d_ctc51m00.tltmsgcod,
                       d_ctc51m00.tltmsgtxt1,
                       d_ctc51m00.tltmsgtxt2,
                       d_ctc51m00.tltmsgtxt3,
                       d_ctc51m00.tltmsgtxt4,
                       d_ctc51m00.tltmsgtxt5,
                       d_ctc51m00.tltmsgstt,
                       d_ctc51m00.descsit,
                       d_ctc51m00.caddat,
                       d_ctc51m00.atldat,
                       d_ctc51m00.cadnom,
                       d_ctc51m00.atlnom
    else
       error " Nao ha' Mensagem nesta direcao!"
       initialize d_ctc51m00.*    to null
    end if
 else
    error " Nao ha' Mensagem nesta direcao!"
    initialize d_ctc51m00.*    to null
 end if

 return d_ctc51m00.*

 end function    # ctc51m00_proximo

#------------------------------------------------------------
 function ctc51m00_anterior(param)
#------------------------------------------------------------

 define param         record
        tltmsgcod     like datktltmsg.tltmsgcod
 end record

 define d_ctc51m00   record
        tltmsgcod    like datktltmsg.tltmsgcod,
        tltmsgtxt    like datktltmsg.tltmsgtxt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        tltmsgstt    like datktltmsg.tltmsgstt,
        descsit      char(10),
        caddat       like datktltmsg.caddat,
        cademp       like datktltmsg.cademp,
        cadmat       like datktltmsg.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltmsg.cadusrtip,
        atldat       like datktltmsg.atldat,
        atlemp       like datktltmsg.atlemp,
        atlmat       like datktltmsg.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltmsg.atlusrtip
 end record

 initialize d_ctc51m00.*  to null

 if param.tltmsgcod  is null   then
    let param.tltmsgcod = 0
 end if

 select max(datktltmsg.tltmsgcod)
   into d_ctc51m00.tltmsgcod
   from datktltmsg
  where datktltmsg.tltmsgcod  <  param.tltmsgcod

 if d_ctc51m00.tltmsgcod is not null   then

    call ctc51m00_ler(d_ctc51m00.tltmsgcod)
         returning d_ctc51m00.*

    if d_ctc51m00.tltmsgcod is not null   then
       call ctc51m00_func(d_ctc51m00.cademp, d_ctc51m00.cadmat)
            returning d_ctc51m00.cadnom

       call ctc51m00_func(d_ctc51m00.atlemp, d_ctc51m00.atlmat)
            returning d_ctc51m00.atlnom

       case d_ctc51m00.tltmsgstt
            when "A" let d_ctc51m00.descsit = "ATIVO"
            when "C" let d_ctc51m00.descsit = "CANCELADO"
            otherwise
            let d_ctc51m00.descsit = " "
       end case

       let d_ctc51m00.tltmsgtxt1 =  d_ctc51m00.tltmsgtxt[001,050]
       let d_ctc51m00.tltmsgtxt2 =  d_ctc51m00.tltmsgtxt[051,100]
       let d_ctc51m00.tltmsgtxt3 =  d_ctc51m00.tltmsgtxt[101,150]
       let d_ctc51m00.tltmsgtxt4 =  d_ctc51m00.tltmsgtxt[151,200]
       let d_ctc51m00.tltmsgtxt5 =  d_ctc51m00.tltmsgtxt[201,240]

       display by name d_ctc51m00.tltmsgcod,
                       d_ctc51m00.tltmsgtxt1,
                       d_ctc51m00.tltmsgtxt2,
                       d_ctc51m00.tltmsgtxt3,
                       d_ctc51m00.tltmsgtxt4,
                       d_ctc51m00.tltmsgtxt5,
                       d_ctc51m00.tltmsgstt,
                       d_ctc51m00.descsit,
                       d_ctc51m00.caddat,
                       d_ctc51m00.atldat,
                       d_ctc51m00.cadnom,
                       d_ctc51m00.atlnom
    else
       error " Nao ha' Mensagem nesta direcao!"
       initialize d_ctc51m00.*    to null
    end if
 else
    error " Nao ha' Mensagem nesta direcao!"
    initialize d_ctc51m00.*    to null
 end if

 return d_ctc51m00.*

 end function    # ctc51m00_anterior

#------------------------------------------------------------
 function ctc51m00_modifica(param, d_ctc51m00)
#------------------------------------------------------------

 define param         record
        tltmsgcod     like datktltmsg.tltmsgcod
 end record

 define d_ctc51m00   record
        tltmsgcod    like datktltmsg.tltmsgcod,
        tltmsgtxt    like datktltmsg.tltmsgtxt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        tltmsgstt    like datktltmsg.tltmsgstt,
        descsit      char(10),
        caddat       like datktltmsg.caddat,
        cademp       like datktltmsg.cademp,
        cadmat       like datktltmsg.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltmsg.cadusrtip,
        atldat       like datktltmsg.atldat,
        atlemp       like datktltmsg.atlemp,
        atlmat       like datktltmsg.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltmsg.atlusrtip
 end record

 call ctc51m00_ler(d_ctc51m00.tltmsgcod)
      returning d_ctc51m00.*

 if d_ctc51m00.tltmsgcod is null then
    error " Registro nao localizado "
    return param.*
 end if

 call ctc51m00_input("a", d_ctc51m00.*) returning d_ctc51m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc51m00.*  to null
    error " Operacao cancelada!"
    return d_ctc51m00.*
 end if

 whenever error continue

 begin work
    update datktltmsg    set  ( tltmsgtxt,
                                tltmsgstt,
                                atldat,
                                atlemp,
                                atlmat,
                                atlusrtip)
                           =  ( d_ctc51m00.tltmsgtxt,
                                d_ctc51m00.tltmsgstt,
                                today,
                                g_issk.empcod,
                                g_issk.funmat,
                                g_issk.usrtip)
    where datktltmsg.tltmsgcod = param.tltmsgcod

    if sqlca.sqlcode <>  0  then
      error " Erro (",sqlca.sqlcode,") na alteracao da mensagem!"
      rollback work
      initialize d_ctc51m00.*   to null
      return d_ctc51m00.*
   else
      error " Alteracao efetuada com sucesso!"
   end if

 commit work

 whenever error stop

 call ctc51m00_func(d_ctc51m00.cademp, d_ctc51m00.cadmat)
      returning d_ctc51m00.cadnom

 call ctc51m00_func(d_ctc51m00.atlemp, d_ctc51m00.atlmat)
      returning d_ctc51m00.atlnom

 initialize d_ctc51m00.*  to null
 message ""
 return d_ctc51m00.*

 end function   #  ctc51m00_modifica

#------------------------------------------------------------
 function ctc51m00_inclui()
#------------------------------------------------------------

 define d_ctc51m00   record
        tltmsgcod    like datktltmsg.tltmsgcod,
        tltmsgtxt    like datktltmsg.tltmsgtxt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        tltmsgstt    like datktltmsg.tltmsgstt,
        descsit      char(10),
        caddat       like datktltmsg.caddat,
        cademp       like datktltmsg.cademp,
        cadmat       like datktltmsg.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltmsg.cadusrtip,
        atldat       like datktltmsg.atldat,
        atlemp       like datktltmsg.atlemp,
        atlmat       like datktltmsg.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltmsg.atlusrtip
 end record

 define  ws_resp      char(01)

 initialize d_ctc51m00.*   to null

 clear form

 call ctc51m00_input("i", d_ctc51m00.*) returning d_ctc51m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc51m00.*  to null
    error " Operacao cancelada!"
    return
 end if

 let d_ctc51m00.caddat = today

 declare c_ctc51m00  cursor with hold  for
    select max(tltmsgcod)
      from datktltmsg
     where datktltmsg.tltmsgcod > 0

 foreach c_ctc51m00  into  d_ctc51m00.tltmsgcod
     exit foreach
 end foreach

 if d_ctc51m00.tltmsgcod is null   then
    let d_ctc51m00.tltmsgcod = 0
 end if
 let d_ctc51m00.tltmsgcod = d_ctc51m00.tltmsgcod + 1

 whenever error continue

 begin work
    insert into datktltmsg             ( tltmsgcod,
                                         tltmsgtxt,
                                         tltmsgstt,
                                         caddat,
                                         cademp,
                                         cadmat,
                                         cadusrtip,
                                         atldat,
                                         atlemp,
                                         atlmat,
                                         atlusrtip)
                         values
                                      ( d_ctc51m00.tltmsgcod,
                                        d_ctc51m00.tltmsgtxt,
                                        d_ctc51m00.tltmsgstt,
                                        d_ctc51m00.caddat,
                                        g_issk.empcod,
                                        g_issk.funmat,
                                        g_issk.usrtip,
                                        today,
                                        g_issk.empcod,
                                        g_issk.funmat,
                                        g_issk.usrtip)
    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao da mensagem!"
       rollback work
       return
    end if

    commit work

    whenever error stop

    let d_ctc51m00.cademp = g_issk.empcod
    let d_ctc51m00.cadmat = g_issk.funmat
    let d_ctc51m00.atlemp = g_issk.empcod
    let d_ctc51m00.atlmat = g_issk.funmat

    call ctc51m00_func(d_ctc51m00.cademp, d_ctc51m00.cadmat)
         returning d_ctc51m00.cadnom

    call ctc51m00_func(d_ctc51m00.atlemp, d_ctc51m00.atlmat)
         returning d_ctc51m00.atlnom

    let d_ctc51m00.tltmsgtxt1 =  d_ctc51m00.tltmsgtxt[001,050]
    let d_ctc51m00.tltmsgtxt2 =  d_ctc51m00.tltmsgtxt[051,100]
    let d_ctc51m00.tltmsgtxt3 =  d_ctc51m00.tltmsgtxt[101,150]
    let d_ctc51m00.tltmsgtxt4 =  d_ctc51m00.tltmsgtxt[151,200]
    let d_ctc51m00.tltmsgtxt5 =  d_ctc51m00.tltmsgtxt[201,240]

    display by name d_ctc51m00.tltmsgcod,
                    d_ctc51m00.tltmsgtxt1,
                    d_ctc51m00.tltmsgtxt2,
                    d_ctc51m00.tltmsgtxt3,
                    d_ctc51m00.tltmsgtxt4,
                    d_ctc51m00.tltmsgtxt5,
                    d_ctc51m00.tltmsgstt,
                    d_ctc51m00.descsit,
                    d_ctc51m00.caddat,
                    d_ctc51m00.atldat,
                    d_ctc51m00.cadnom,
                    d_ctc51m00.atlnom

    display by name d_ctc51m00.tltmsgcod attribute (reverse)
    error " Inclusao efetuada com sucesso, tecle ENTER!"
    prompt "" for char ws_resp

    initialize d_ctc51m00.*  to null

    clear form

    end function   #  ctc51m00_inclui

#--------------------------------------------------------------------
 function ctc51m00_input(param, d_ctc51m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc51m00   record
        tltmsgcod    like datktltmsg.tltmsgcod,
        tltmsgtxt    like datktltmsg.tltmsgtxt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        tltmsgstt    like datktltmsg.tltmsgstt,
        descsit      char(10),
        caddat       like datktltmsg.caddat,
        cademp       like datktltmsg.cademp,
        cadmat       like datktltmsg.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltmsg.cadusrtip,
        atldat       like datktltmsg.atldat,
        atlemp       like datktltmsg.atlemp,
        atlmat       like datktltmsg.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltmsg.atlusrtip
 end record

 define p_ctc51m00   record
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40)
 end record

 define ws           record
        tltmsgcod    like datktltmsg.tltmsgcod
 end record

 initialize ws.*         to null
 initialize p_ctc51m00.* to null
 let int_flag     =  false
 select tltmsgtxt[001,050],
        tltmsgtxt[051,100],
        tltmsgtxt[101,150],
        tltmsgtxt[151,200],
        tltmsgtxt[201,240]
 into p_ctc51m00.*
 from datktltmsg
 where tltmsgcod = d_ctc51m00.tltmsgcod

 input p_ctc51m00.*, d_ctc51m00.tltmsgstt
       without defaults from tltmsgtxt1,
                             tltmsgtxt2,
                             tltmsgtxt3,
                             tltmsgtxt4,
                             tltmsgtxt5,
                             tltmsgstt

    after  field tltmsgtxt1

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt1
           end if

           if p_ctc51m00.tltmsgtxt1  is null   then
              error " Mensagem deve ser informada!"
              next field tltmsgtxt1
           end if

    after  field tltmsgtxt2

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt1
           end if

    after  field tltmsgtxt3

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt2
           end if

    after  field tltmsgtxt4

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt3
           end if

    after  field tltmsgtxt5

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt4
           end if
           let d_ctc51m00.tltmsgtxt = p_ctc51m00.tltmsgtxt1,
                                      p_ctc51m00.tltmsgtxt2,
                                      p_ctc51m00.tltmsgtxt3,
                                      p_ctc51m00.tltmsgtxt4,
                                      p_ctc51m00.tltmsgtxt5
    before field tltmsgstt
           display by name d_ctc51m00.tltmsgstt attribute (reverse)

    after field tltmsgstt
           display by name d_ctc51m00.tltmsgstt

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field tltmsgtxt1
       end if

       case d_ctc51m00.tltmsgstt
            when "A" let d_ctc51m00.descsit = "ATIVO"
            when "C" let d_ctc51m00.descsit = "CANCELADO"
            otherwise error " Situacao deve ser: (A)Ativo ou (C)Cancelado!"
            next field tltmsgstt
       end case

       display by name d_ctc51m00.descsit

        on key (interrupt)
        exit input

 end input

 if int_flag   then
    initialize d_ctc51m00.*  to null
 end if

 return d_ctc51m00.*

 end function   # ctc51m00_input

#--------------------------------------------------------------------
 function ctc51m00_ler(param)
#--------------------------------------------------------------------
 define param         record
        tltmsgcod     like datktltmsg.tltmsgcod
 end record

 define d_ctc51m00   record
        tltmsgcod    like datktltmsg.tltmsgcod,
        tltmsgtxt    like datktltmsg.tltmsgtxt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        tltmsgstt    like datktltmsg.tltmsgstt,
        descsit      char(10),
        caddat       like datktltmsg.caddat,
        cademp       like datktltmsg.cademp,
        cadmat       like datktltmsg.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltmsg.cadusrtip,
        atldat       like datktltmsg.atldat,
        atlemp       like datktltmsg.atlemp,
        atlmat       like datktltmsg.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltmsg.atlusrtip
 end record

 initialize d_ctc51m00.*   to null

  select  tltmsgcod,
          tltmsgtxt,
          tltmsgstt,
          caddat,
          cademp,
          cadmat,
          cadusrtip,
          atldat,
          atlemp,
          atlmat,
          atlusrtip
   into  d_ctc51m00.tltmsgcod,
         d_ctc51m00.tltmsgtxt,
         d_ctc51m00.tltmsgstt,
         d_ctc51m00.caddat,
         d_ctc51m00.cademp,
         d_ctc51m00.cadmat,
         d_ctc51m00.cadusrtip,
         d_ctc51m00.atldat,
         d_ctc51m00.atlemp,
         d_ctc51m00.atlmat,
         d_ctc51m00.atlusrtip
   from  datktltmsg
  where  datktltmsg.tltmsgcod    = param.tltmsgcod

 if sqlca.sqlcode = notfound   then
    error " Mensagem nao existe!"
    initialize d_ctc51m00.*    to null
    return d_ctc51m00.*
 end if

 call ctc51m00_func(d_ctc51m00.cademp, d_ctc51m00.cadmat)
      returning d_ctc51m00.cadnom

 call ctc51m00_func(d_ctc51m00.atlemp, d_ctc51m00.atlmat)
      returning d_ctc51m00.atlnom

 let d_ctc51m00.tltmsgtxt1 =  d_ctc51m00.tltmsgtxt[001,050]
 let d_ctc51m00.tltmsgtxt2 =  d_ctc51m00.tltmsgtxt[051,100]
 let d_ctc51m00.tltmsgtxt3 =  d_ctc51m00.tltmsgtxt[101,150]
 let d_ctc51m00.tltmsgtxt4 =  d_ctc51m00.tltmsgtxt[151,200]
 let d_ctc51m00.tltmsgtxt5 =  d_ctc51m00.tltmsgtxt[201,240]

 return d_ctc51m00.*

 end function   # ctc51m00_ler

#---------------------------------------------------------
 function ctc51m00_func(k_ctc51m00)
#---------------------------------------------------------

 define k_ctc51m00 record
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
  where empcod = k_ctc51m00.empcod  and
        funmat = k_ctc51m00.funmat

 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

end function  ###  ctc51m00_func

