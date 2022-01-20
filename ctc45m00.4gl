###########################################################################
# Nome do Modulo: ctc45m00                                        Marcelo #
#                                                                Gilberto #
# Cadastro de pontos geograficos para GPS                        Set/1999 #
#-------------------------------------------------------------------------#
# 18/12/2000  PSI 12023-5  Marcus       Alterar cadastro de viaturas para #
#                                       trabalhar com grupo de acionamento#
#-------------------------------------------------------------------------#
# 25/09/2006  PSI 202290   Priscila    Remover verificacao nivel de acesso#
###########################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc45m00()
#------------------------------------------------------------

 define d_ctc45m00    record
    geoptocod         like datkgpsgeopto.geoptocod,
    ufdcod            like datkgpsgeopto.ufdcod,
    cidnom            like datkgpsgeopto.cidnom,
    brrnom            like datkgpsgeopto.brrnom,
    endzon            like datkgpsgeopto.endzon,
    lclltt            like datkgpsgeopto.lclltt,
    lcllgt            like datkgpsgeopto.lcllgt,
    caddat            like datkgpsgeopto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkgpsgeopto.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkgpsgeopto.gpsacngrpcod
 end record


 let int_flag = false
 initialize d_ctc45m00.*  to null

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc45m00") then
 #   error " Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 open window ctc45m00 at 4,2 with form "ctc45m00"

 menu "PONTOS"

  before menu
     hide option all
     #PSI 202290
     #if g_issk.acsnivcod >= g_issk.acsnivcns  then
     #   show option "Seleciona", "Proximo", "Anterior",
     #               "pesQuisa"
     #end if
     #if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "Remove"  ,
                    "pesQuisa"
     #end if

     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa ponto geografico conforme criterios"
          call ctc45m00_seleciona(d_ctc45m00.geoptocod)
               returning d_ctc45m00.*
          if d_ctc45m00.geoptocod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum ponto geografico selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo ponto geografico selecionado"
          message ""
          call ctc45m00_proximo(d_ctc45m00.geoptocod)
               returning d_ctc45m00.*

 command key ("A") "Anterior"
                   "Mostra ponto geografico anterior selecionado"
          message ""
          if d_ctc45m00.geoptocod is not null then
             call ctc45m00_anterior(d_ctc45m00.geoptocod)
                  returning d_ctc45m00.*
          else
             error " Nenhum ponto geografico nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica ponto geografico corrente selecionado"
          message ""
          if d_ctc45m00.geoptocod  is not null then
             call ctc45m00_modifica(d_ctc45m00.geoptocod, d_ctc45m00.*)
                  returning d_ctc45m00.*
             next option "Seleciona"
          else
             error " Nenhum ponto geografico selecionado!"
             next option "Seleciona"
          end if
          initialize d_ctc45m00.*  to null

 command key ("I") "Inclui"
                   "Inclui ponto geografico"
          message ""
          call ctc45m00_inclui()
          next option "Seleciona"
          initialize d_ctc45m00.*  to null

 command key ("Q") "pesQuisa"
                   "Pesquisa ponto geografico por: uf/cidade"
          message ""
          initialize d_ctc45m00.*  to null
          display by name d_ctc45m00.*

          call ctc45m01() returning d_ctc45m00.geoptocod
          next option "Seleciona"

   command "Remove" "Remove ponto geografico corrente selecionado"
            message ""
            if d_ctc45m00.geoptocod  is not null   then
               call ctc45m00_remove(d_ctc45m00.*)
                    returning d_ctc45m00.*
               next option "Seleciona"
            else
               error " Nenhum ponto geografico selecionado!"
               next option "Seleciona"
            end if
          initialize d_ctc45m00.*  to null

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc45m00

 end function  # ctc45m00


#------------------------------------------------------------
 function ctc45m00_seleciona(param)
#------------------------------------------------------------

 define param         record
    geoptocod         like datkgpsgeopto.geoptocod
 end record

 define d_ctc45m00    record
    geoptocod         like datkgpsgeopto.geoptocod,
    ufdcod            like datkgpsgeopto.ufdcod,
    cidnom            like datkgpsgeopto.cidnom,
    brrnom            like datkgpsgeopto.brrnom,
    endzon            like datkgpsgeopto.endzon,
    lclltt            like datkgpsgeopto.lclltt,
    lcllgt            like datkgpsgeopto.lcllgt,
    caddat            like datkgpsgeopto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkgpsgeopto.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkgpsgeopto.gpsacngrpcod
 end record


 let int_flag = false
 initialize d_ctc45m00.*  to null
 let d_ctc45m00.geoptocod  =  param.geoptocod

 display by name d_ctc45m00.*

 input by name d_ctc45m00.geoptocod  without defaults

    before field geoptocod
        display by name d_ctc45m00.geoptocod attribute (reverse)

    after  field geoptocod
        display by name d_ctc45m00.geoptocod

        if d_ctc45m00.geoptocod  is null   then
           error " Ponto geografico deve ser informado!"
           next field geoptocod
        end if

        select geoptocod
          from datkgpsgeopto
         where datkgpsgeopto.geoptocod = d_ctc45m00.geoptocod

        if sqlca.sqlcode  =  notfound   then
           error " Ponto geografico nao cadastrado!"
           next field geoptocod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc45m00.*   to null
    display by name d_ctc45m00.*
    error " Operacao cancelada!"
    return d_ctc45m00.*
 end if

 call ctc45m00_ler(d_ctc45m00.geoptocod)
      returning d_ctc45m00.*

 if d_ctc45m00.geoptocod  is not null   then
    display by name  d_ctc45m00.*
 else
    error " Ponto geografico nao cadastrado!"
    initialize d_ctc45m00.*    to null
 end if

 return d_ctc45m00.*

 end function  # ctc45m00_seleciona


#------------------------------------------------------------
 function ctc45m00_proximo(param)
#------------------------------------------------------------

 define param         record
    geoptocod         like datkgpsgeopto.geoptocod
 end record

 define d_ctc45m00    record
    geoptocod         like datkgpsgeopto.geoptocod,
    ufdcod            like datkgpsgeopto.ufdcod,
    cidnom            like datkgpsgeopto.cidnom,
    brrnom            like datkgpsgeopto.brrnom,
    endzon            like datkgpsgeopto.endzon,
    lclltt            like datkgpsgeopto.lclltt,
    lcllgt            like datkgpsgeopto.lcllgt,
    caddat            like datkgpsgeopto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkgpsgeopto.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkgpsgeopto.gpsacngrpcod
 end record


 let int_flag = false
 initialize d_ctc45m00.*   to null

 if param.geoptocod  is null   then
    let param.geoptocod = 0
 end if

 select min(datkgpsgeopto.geoptocod)
   into d_ctc45m00.geoptocod
   from datkgpsgeopto
  where datkgpsgeopto.geoptocod  >  param.geoptocod

 if d_ctc45m00.geoptocod  is not null   then

    call ctc45m00_ler(d_ctc45m00.geoptocod)
         returning d_ctc45m00.*

    if d_ctc45m00.geoptocod  is not null   then
       display by name d_ctc45m00.*
    else
       error " Nao ha' ponto geografico nesta direcao!"
       initialize d_ctc45m00.*    to null
    end if
 else
    error " Nao ha' ponto geografico nesta direcao!"
    initialize d_ctc45m00.*    to null
 end if

 return d_ctc45m00.*

 end function    # ctc45m00_proximo


#------------------------------------------------------------
 function ctc45m00_anterior(param)
#------------------------------------------------------------

 define param         record
    geoptocod         like datkgpsgeopto.geoptocod
 end record

 define d_ctc45m00    record
    geoptocod         like datkgpsgeopto.geoptocod,
    ufdcod            like datkgpsgeopto.ufdcod,
    cidnom            like datkgpsgeopto.cidnom,
    brrnom            like datkgpsgeopto.brrnom,
    endzon            like datkgpsgeopto.endzon,
    lclltt            like datkgpsgeopto.lclltt,
    lcllgt            like datkgpsgeopto.lcllgt,
    caddat            like datkgpsgeopto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkgpsgeopto.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkgpsgeopto.gpsacngrpcod
 end record


 let int_flag = false
 initialize d_ctc45m00.*  to null

 if param.geoptocod  is null   then
    let param.geoptocod = 0
 end if

 select max(datkgpsgeopto.geoptocod)
   into d_ctc45m00.geoptocod
   from datkgpsgeopto
  where datkgpsgeopto.geoptocod  <  param.geoptocod

 if d_ctc45m00.geoptocod  is not null   then

    call ctc45m00_ler(d_ctc45m00.geoptocod)
         returning d_ctc45m00.*

    if d_ctc45m00.geoptocod  is not null   then
       display by name  d_ctc45m00.*
    else
       error " Nao ha' ponto geografico nesta direcao!"
       initialize d_ctc45m00.*    to null
    end if
 else
    error " Nao ha' ponto geografico nesta direcao!"
    initialize d_ctc45m00.*    to null
 end if

 return d_ctc45m00.*

 end function    # ctc45m00_anterior


#------------------------------------------------------------
 function ctc45m00_modifica(param, d_ctc45m00)
#------------------------------------------------------------

 define param         record
    geoptocod         like datkgpsgeopto.geoptocod
 end record

 define d_ctc45m00    record
    geoptocod         like datkgpsgeopto.geoptocod,
    ufdcod            like datkgpsgeopto.ufdcod,
    cidnom            like datkgpsgeopto.cidnom,
    brrnom            like datkgpsgeopto.brrnom,
    endzon            like datkgpsgeopto.endzon,
    lclltt            like datkgpsgeopto.lclltt,
    lcllgt            like datkgpsgeopto.lcllgt,
    caddat            like datkgpsgeopto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkgpsgeopto.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkgpsgeopto.gpsacngrpcod
 end record


 call ctc45m00_input("a", d_ctc45m00.*) returning d_ctc45m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc45m00.*  to null
    display by name d_ctc45m00.*
    error " Operacao cancelada!"
    return d_ctc45m00.*
 end if

 whenever error continue

 let d_ctc45m00.atldat = today

 begin work
    update datkgpsgeopto set  ( ufdcod,
                                cidnom,
                                brrnom,
                                endzon,
                                lclltt,
                                lcllgt,
                                atldat,
                                atlemp,
                                atlmat,
                                gpsacngrpcod)
                           =  ( d_ctc45m00.ufdcod,
                                d_ctc45m00.cidnom,
                                d_ctc45m00.brrnom,
                                d_ctc45m00.endzon,
                                d_ctc45m00.lclltt,
                                d_ctc45m00.lcllgt,
                                d_ctc45m00.atldat,
                                g_issk.empcod,
                                g_issk.funmat,
                                d_ctc45m00.gpsacngrpcod)
           where datkgpsgeopto.geoptocod  =  d_ctc45m00.geoptocod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do ponto geografico!"
       rollback work
       initialize d_ctc45m00.*   to null
       return d_ctc45m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc45m00.*  to null
 display by name d_ctc45m00.*
 message ""
 return d_ctc45m00.*

 end function   #  ctc45m00_modifica


#------------------------------------------------------------
 function ctc45m00_inclui()
#------------------------------------------------------------

 define d_ctc45m00    record
    geoptocod         like datkgpsgeopto.geoptocod,
    ufdcod            like datkgpsgeopto.ufdcod,
    cidnom            like datkgpsgeopto.cidnom,
    brrnom            like datkgpsgeopto.brrnom,
    endzon            like datkgpsgeopto.endzon,
    lclltt            like datkgpsgeopto.lclltt,
    lcllgt            like datkgpsgeopto.lcllgt,
    caddat            like datkgpsgeopto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkgpsgeopto.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkgpsgeopto.gpsacngrpcod
 end record

 define  ws_resp      char(01)


 initialize d_ctc45m00.*   to null
 display by name d_ctc45m00.*

 call ctc45m00_input("i", d_ctc45m00.*) returning d_ctc45m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc45m00.*  to null
    display by name d_ctc45m00.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc45m00.atldat = today
 let d_ctc45m00.caddat = today


 declare c_ctc45m00m  cursor with hold  for
    select max(geoptocod)
      from datkgpsgeopto
     where datkgpsgeopto.geoptocod > 0

 foreach c_ctc45m00m  into  d_ctc45m00.geoptocod
     exit foreach
 end foreach

 if d_ctc45m00.geoptocod is null   then
    let d_ctc45m00.geoptocod = 0
 end if
 let d_ctc45m00.geoptocod = d_ctc45m00.geoptocod + 1


 whenever error continue

 begin work
    insert into datkgpsgeopto ( geoptocod,
                                ufdcod,
                                cidnom,
                                brrnom,
                                endzon,
                                lclltt,
                                lcllgt,
                                caddat,
                                cademp,
                                cadmat,
                                atldat,
                                atlemp,
                                atlmat,
                                gpsacngrpcod)
                     values
                              ( d_ctc45m00.geoptocod,
                                d_ctc45m00.ufdcod,
                                d_ctc45m00.cidnom,
                                d_ctc45m00.brrnom,
                                d_ctc45m00.endzon,
                                d_ctc45m00.lclltt,
                                d_ctc45m00.lcllgt,
                                d_ctc45m00.caddat,
                                g_issk.empcod,
                                g_issk.funmat,
                                d_ctc45m00.atldat,
                                g_issk.empcod,
                                g_issk.funmat,
                                d_ctc45m00.gpsacngrpcod)

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do ponto geografico!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc45m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc45m00.cadfunnom

 call ctc45m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc45m00.funnom

 display by name  d_ctc45m00.*

 display by name d_ctc45m00.geoptocod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc45m00.*  to null
 display by name d_ctc45m00.*

 end function   #  ctc45m00_inclui


#--------------------------------------------------------------------
 function ctc45m00_input(param, d_ctc45m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc45m00    record
    geoptocod         like datkgpsgeopto.geoptocod,
    ufdcod            like datkgpsgeopto.ufdcod,
    cidnom            like datkgpsgeopto.cidnom,
    brrnom            like datkgpsgeopto.brrnom,
    endzon            like datkgpsgeopto.endzon,
    lclltt            like datkgpsgeopto.lclltt,
    lcllgt            like datkgpsgeopto.lcllgt,
    caddat            like datkgpsgeopto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkgpsgeopto.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkgpsgeopto.gpsacngrpcod
 end record

 define ws            record
    geoptocod         like datkgpsgeopto.geoptocod
 end record


 initialize ws.*  to null
 let int_flag     =  false

 input by name d_ctc45m00.ufdcod,
               d_ctc45m00.cidnom,
               d_ctc45m00.brrnom,
               d_ctc45m00.endzon,
               d_ctc45m00.lclltt,
               d_ctc45m00.lcllgt,
               d_ctc45m00.gpsacngrpcod without defaults

    before field ufdcod
           display by name d_ctc45m00.ufdcod attribute (reverse)

    after  field ufdcod
           display by name d_ctc45m00.ufdcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  ufdcod
           end if

           if d_ctc45m00.ufdcod  is null   then
              error " UF deve ser informada!"
              next field ufdcod
           end if

           select ufdcod
             from glakest
            where ufdcod  =  d_ctc45m00.ufdcod

           if sqlca.sqlcode  =  notfound   then
              error " UF nao cadastrada!"
              next field ufdcod
           end if

    before field cidnom
           display by name d_ctc45m00.cidnom attribute (reverse)

    after  field cidnom
           display by name d_ctc45m00.cidnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  ufdcod
           end if

           if d_ctc45m00.cidnom  is null   then
              error " Cidade deve ser informada!"
              next field cidnom
           end if

           select cidnom
             from glakcid
            where cidnom  =  d_ctc45m00.cidnom
              and ufdcod  =  d_ctc45m00.ufdcod

           if sqlca.sqlcode  =  notfound   then
              error " Cidade nao cadastrada!"
              next field cidnom
           end if

    before field brrnom
           display by name d_ctc45m00.brrnom attribute (reverse)

    after  field brrnom
           display by name d_ctc45m00.brrnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  cidnom
           end if

           if d_ctc45m00.brrnom  is null   then
              error " Bairro deve ser informado!"
              next field brrnom
           end if

    before field endzon
           display by name d_ctc45m00.endzon attribute (reverse)

    after  field endzon
           display by name d_ctc45m00.endzon

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  brrnom
           end if

           if d_ctc45m00.endzon  is null   then
              if d_ctc45m00.ufdcod  =  "SP"          and
                 d_ctc45m00.cidnom  =  "SAO PAULO"   then
                 error " Codigo da zona deve ser informado!"
                 next field endzon
              end if
           else
              if d_ctc45m00.endzon  <>  "CE"    and
                 d_ctc45m00.endzon  <>  "NO"    and
                 d_ctc45m00.endzon  <>  "SU"    and
                 d_ctc45m00.endzon  <>  "LE"    and
                 d_ctc45m00.endzon  <>  "OE"    then
                 error " Codigo da zona incorreto!"
                 next field endzon
              end if
           end if

    before field lclltt
           display by name d_ctc45m00.lclltt attribute (reverse)

    after  field lclltt
           display by name d_ctc45m00.lclltt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  endzon
           end if

           if d_ctc45m00.lclltt  is null   then
              error " Latitude deve ser informada!"
              next field lclltt
           end if

          #if d_ctc45m00.lclltt  <  -23.999999   or
          #   d_ctc45m00.lclltt  >  -23.000000   then
          #   error " Latitude incorreta!"
          #   next field lclltt
          #end if

    before field lcllgt
           display by name d_ctc45m00.lcllgt attribute (reverse)

    after  field lcllgt
           display by name d_ctc45m00.lcllgt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  lclltt
           end if

           if d_ctc45m00.lcllgt  is null   then
              error " Longitude deve ser informada!"
              next field lcllgt
           end if

          #if d_ctc45m00.lcllgt  <  -46.999999   or
          #   d_ctc45m00.lcllgt  >  -46.000000   then
          #   error " Longitude incorreta!"
          #   next field lcllgt
          #end if

           #------------------------------------------------------------
           # Verifica se latitude/longitude ja' cadastrada
           #------------------------------------------------------------
           initialize ws.geoptocod  to null
           select geoptocod
             into ws.geoptocod
             from datkgpsgeopto
            where datkgpsgeopto.lclltt = d_ctc45m00.lclltt
              and datkgpsgeopto.lcllgt = d_ctc45m00.lcllgt

           if sqlca.sqlcode  =  0   then
              if param.operacao  =  "i"   then
                 error " Latitude/longitude ja' cadastrada em outro",
                       " ponto! --> ", ws.geoptocod
                 next field lcllgt
              else
                 if d_ctc45m00.geoptocod  <>  ws.geoptocod   then
                    error " Latitude/longitude ja' cadastrada em outro",
                          " ponto! --> ", ws.geoptocod
                    next field lcllgt
                 end if
              end if
           end if

     before field gpsacngrpcod
         display by name d_ctc45m00.gpsacngrpcod attribute (reverse)

     after field gpsacngrpcod
         if d_ctc45m00.gpsacngrpcod is null then
	    error " Grupo de Acionamento deve ser informado!"
            next field gpsacngrpcod
         end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc45m00.*  to null
 end if

 return d_ctc45m00.*

 end function   # ctc45m00_input


#--------------------------------------------------------------------
 function ctc45m00_remove(d_ctc45m00)
#--------------------------------------------------------------------

 define d_ctc45m00    record
    geoptocod         like datkgpsgeopto.geoptocod,
    ufdcod            like datkgpsgeopto.ufdcod,
    cidnom            like datkgpsgeopto.cidnom,
    brrnom            like datkgpsgeopto.brrnom,
    endzon            like datkgpsgeopto.endzon,
    lclltt            like datkgpsgeopto.lclltt,
    lcllgt            like datkgpsgeopto.lcllgt,
    caddat            like datkgpsgeopto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkgpsgeopto.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkgpsgeopto.gpsacngrpcod
 end record


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o ponto geografico"
            clear form
            initialize d_ctc45m00.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui ponto geografico"
            call ctc45m00_ler(d_ctc45m00.geoptocod) returning d_ctc45m00.*

            if d_ctc45m00.geoptocod  is null   then
               initialize d_ctc45m00.* to null
               error " Ponto geografico nao localizado!"
            else

               begin work
                  delete from datkgpsgeopto
                   where datkgpsgeopto.geoptocod = d_ctc45m00.geoptocod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc45m00.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do ponto geografico!"
               else
                  initialize d_ctc45m00.* to null
                  error   " Ponto geografico excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc45m00.*

end function    # ctc45m00_remove


#--------------------------------------------------------------------
 function ctc45m00_ler(param)
#--------------------------------------------------------------------

 define param         record
    geoptocod         like datkgpsgeopto.geoptocod
 end record

 define d_ctc45m00    record
    geoptocod         like datkgpsgeopto.geoptocod,
    ufdcod            like datkgpsgeopto.ufdcod,
    cidnom            like datkgpsgeopto.cidnom,
    brrnom            like datkgpsgeopto.brrnom,
    endzon            like datkgpsgeopto.endzon,
    lclltt            like datkgpsgeopto.lclltt,
    lcllgt            like datkgpsgeopto.lcllgt,
    caddat            like datkgpsgeopto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkgpsgeopto.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkgpsgeopto.gpsacngrpcod
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat
 end record


 initialize d_ctc45m00.*   to null
 initialize ws.*           to null

 select  geoptocod,
         ufdcod,
         cidnom,
         brrnom,
         endzon,
         lclltt,
         lcllgt,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat,
         gpsacngrpcod
   into  d_ctc45m00.geoptocod,
         d_ctc45m00.ufdcod,
         d_ctc45m00.cidnom,
         d_ctc45m00.brrnom,
         d_ctc45m00.endzon,
         d_ctc45m00.lclltt,
         d_ctc45m00.lcllgt,
         d_ctc45m00.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc45m00.atldat,
         ws.atlemp,
         ws.atlmat,
         d_ctc45m00.gpsacngrpcod
   from  datkgpsgeopto
  where  datkgpsgeopto.geoptocod = param.geoptocod

 if sqlca.sqlcode = notfound   then
    error " Ponto geografico nao cadastrado!"
    initialize d_ctc45m00.*    to null
    return d_ctc45m00.*
 else
    call ctc45m00_func(ws.cademp, ws.cadmat)
         returning d_ctc45m00.cadfunnom

    call ctc45m00_func(ws.atlemp, ws.atlmat)
         returning d_ctc45m00.funnom
 end if

 return d_ctc45m00.*

 end function   # ctc45m00_ler


#---------------------------------------------------------
 function ctc45m00_func(param)
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

 end function   # ctc45m00_func
