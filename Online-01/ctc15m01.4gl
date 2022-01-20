###########################################################################
# Nome do Modulo: CTC15M01                                       Marcelo  #
#                                                                Gilberto #
# Cadastro de tipos de assistencia                               Jul/1998 #
#                                                                         # 
#-------------------------------------------------------------------------#
#                          Alteracao Fabrica                              # 
#                          -----------------                              # 
# Nome             Data        Alteracao                                  # 
# ---------------  ----------  -------------------------------------------# 
# Helio            03/06/2003  OSF 19968 - Incluir campo "Indicacao de    # 
#                              Oficina para assistencia "                 # 
#                                                                         # 
# ........................................................................#
#                                                                         #
#                           * * * Alteracoes * * *                        #
#                                                                         #
# Data       Autor Fabrica   Origem     Alteracao                         #
# ---------- --------------  ---------- ----------------------------------#
# 28/07/2005 Vinicius, Meta  PSI192015  Inclusao do campo vclcndlclflg    #
#-------------------------------------------------------------------------#
# 06/04/2006 Priscila        PSI198714  Inclusao do campo atmacnflg       #
#-------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql    smallint

#--------------------------
 function ctc15m01_prepare()
#--------------------------
 define l_sql     char(500)

 let l_sql = "select asitipcod, asitipabvdes, asitipdes, asitipstt, "
            ,"       caddat, cademp, cadmat, atldat, "
            ,"       atlemp, atlmat, asiofndigflg, vclcndlclflg, "
            ,"       atmacnflg  "
            ,"  from datkasitip "
            ," where asitipcod = ? "
 prepare pctc15m01001 from l_sql
 declare cctc15m01001 cursor for pctc15m01001

 let l_sql = " update datkasitip set  ( asitipabvdes, asitipdes,     "
                                     ," asitipstt, atldat,           "
                                     ," atlemp, atlmat, asiofndigflg," 
                                     ," vclcndlclflg, atmacnflg )    "
                                     ," = (?,?,?,?,?,?,?,?,?) "
            ,"  where asitipcod = ? "
 prepare pctc15m01002 from l_sql

 let l_sql = " insert into datkasitip ( asitipcod, asitipabvdes, asitipdes, "
                                     ," asitipstt, caddat, cademp, cadmat, " 
                                     ," atldat, atlemp, atlmat,            "
                                     ," asiofndigflg, vclcndlclflg, atmacnflg)"
                            ," values (?,?,?,?,?,?,?,?,?,?,?,?,?) "
 prepare pctc15m01003 from l_sql

 let m_prep_sql = true

end function

#------------------------------------------------------------
 function ctc15m01()
#------------------------------------------------------------

 define ctc15m01      record
    asitipcod         like datkasitip.asitipcod,
    asitipabvdes      like datkasitip.asitipabvdes,
    asitipdes         like datkasitip.asitipdes,
    asitipstt         like datkasitip.asitipstt,
    asitipsttdes      char (10),
    vclcndlclflg      like datkasitip.vclcndlclflg,
    atmacnflg         like datkasitip.atmacnflg,
    caddat            like datkasitip.caddat,
    cademp            like datkasitip.cademp,
    cadmat            like datkasitip.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasitip.atldat,
    atlemp            like datkasitip.atlemp,
    atlmat            like datkasitip.atlmat,
    atlfunnom         like isskfunc.funnom, 
    asiofndigflg      like datkasitip.asiofndigflg 
 end record

 let int_flag = false
 initialize ctc15m01.*  to null

 open window ctc15m01 at 04,02 with form "ctc15m01"

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctc15m01_prepare()
 end if

 menu "TIPOS ASSISTENCIAS"

 before menu
      show option "Seleciona", "Proximo", "Anterior", "Modifica", "Inclui" ,
                  "Motivos", "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa tipo de assistencia conforme criterios"
          call ctc15m01_seleciona()  returning ctc15m01.*
          if ctc15m01.asitipcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum tipo de assistencia selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo tipo de assistencia"
          message ""
          call ctc15m01_proximo(ctc15m01.asitipcod)
               returning ctc15m01.*

 command key ("A") "Anterior"
                   "Mostra tipo de assistencia anterior"
          message ""
          if ctc15m01.asitipcod is not null then
             call ctc15m01_anterior(ctc15m01.asitipcod)
                  returning ctc15m01.*
          else
             error " Nenhum tipo de assistencia nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica tipo de assistencia selecionado"
          message ""
          if ctc15m01.asitipcod  is not null then
             call ctc15m01_modifica(ctc15m01.asitipcod
                                   ,ctc15m01.asiofndigflg   #OSF 19968 
                                   ,ctc15m01.*)
                  returning ctc15m01.*
             next option "Seleciona"
          else
             error " Nenhum tipo de assistencia selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui tipo de assistencia"
          message ""
          call ctc15m01_inclui()
          next option "Seleciona"

 command key ("T") "moTivos"
                   "Manutencao dos motivos para assistencia"
          message ""
          if ctc15m01.asitipcod is not null then
             call ctc15m06(ctc15m01.asitipcod)
          else
             error " Nenhum tipo de assistencia selecionado!"
             next option "Seleciona"
          end if

#command key ("R") "Remove"
#                  "Remove tipo de assistencia"
#         message ""
#         if ctc15m01.asitipcod  is not null then
#            call ctc15m01_remove(ctc15m01.asitipcod)
#            next option "Seleciona"
#         else
#            error " Nenhum tipo de assistencia selecionado!"
#            next option "Seleciona"
#         end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc15m01

 end function  ###  ctc15m01

#------------------------------------------------------------
 function ctc15m01_seleciona()
#------------------------------------------------------------

 define ctc15m01      record
    asitipcod         like datkasitip.asitipcod,
    asitipabvdes      like datkasitip.asitipabvdes,
    asitipdes         like datkasitip.asitipdes,
    asitipstt         like datkasitip.asitipstt,
    asitipsttdes      char (10),
    vclcndlclflg      like datkasitip.vclcndlclflg,
    atmacnflg         like datkasitip.atmacnflg,
    caddat            like datkasitip.caddat,
    cademp            like datkasitip.cademp,
    cadmat            like datkasitip.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasitip.atldat,
    atlemp            like datkasitip.atlemp,
    atlmat            like datkasitip.atlmat,
    atlfunnom         like isskfunc.funnom , 
    asiofndigflg      like datkasitip.asiofndigflg 
 end record


 let int_flag = false
 initialize ctc15m01.*  to null
 display by name ctc15m01.*

 input by name ctc15m01.asitipcod #, ctc15m01.asiofndigflg 

    before field asitipcod
        display by name ctc15m01.asitipcod attribute (reverse)

    after  field asitipcod
        display by name ctc15m01.asitipcod

        if ctc15m01.asitipcod is null  then
           select min(asitipcod)
             into ctc15m01.asitipcod
             from datkasitip

           if ctc15m01.asitipcod is null  then
              error " Nao existe nenhum tipo de assistencia cadastrado!"
              exit input
           end if
        end if

        select asitipcod
          from datkasitip
         where asitipcod = ctc15m01.asitipcod

        if sqlca.sqlcode = notfound  then
           error " Tipo de assistencia nao cadastrado!"
           next field asitipcod
        end if
#        next field asiofndigflg 

{    before field asiofndigflg        #OSF 19968 
       display by name ctc15m01.asiofndigflg attribute(reverse)

    after field asiofndigflg
       display by name ctc15m01.asiofndigflg
       if ctc15m01.asiofndigflg is null then
          error "Obrigatorio informar!"
          next field asiofndigflg
       end if
       if ctc15m01.asiofndigflg <> "N" and 
          ctc15m01.asiofndigflg <> "S" then
          error "Informar S ou N "
          next field asiofndigflg
       end if 
}
    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc15m01.*   to null
    display by name ctc15m01.*
    error " Operacao cancelada!"
    return ctc15m01.*
 end if

 call ctc15m01_ler(ctc15m01.asitipcod)
      returning ctc15m01.*

 if ctc15m01.asitipcod  is not null   then
    display by name  ctc15m01.*
 else
    error " Tipo de assistencia nao cadastrado!"
    initialize ctc15m01.*    to null
 end if

 return ctc15m01.*

 end function  ###  ctc15m01_seleciona

#------------------------------------------------------------
 function ctc15m01_proximo(param)
#------------------------------------------------------------

 define param         record
    asitipcod            like datkasitip.asitipcod
 end record

 define ctc15m01      record
    asitipcod         like datkasitip.asitipcod,
    asitipabvdes      like datkasitip.asitipabvdes,
    asitipdes         like datkasitip.asitipdes,
    asitipstt         like datkasitip.asitipstt,
    asitipsttdes      char (10),
    vclcndlclflg      like datkasitip.vclcndlclflg,
    atmacnflg         like datkasitip.atmacnflg,
    caddat            like datkasitip.caddat,
    cademp            like datkasitip.cademp,
    cadmat            like datkasitip.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasitip.atldat,
    atlemp            like datkasitip.atlemp,
    atlmat            like datkasitip.atlmat,
    atlfunnom         like isskfunc.funnom, 
    asiofndigflg      like datkasitip.asiofndigflg 
 end record

 let int_flag = false
 initialize ctc15m01.*   to null

 if param.asitipcod  is null   then
    let param.asitipcod = " "
 end if

 select min(datkasitip.asitipcod)
   into ctc15m01.asitipcod
   from datkasitip
  where asitipcod  >  param.asitipcod

 if ctc15m01.asitipcod is not null  then

    call ctc15m01_ler(ctc15m01.asitipcod)
         returning ctc15m01.*

    if ctc15m01.asitipcod is not null  then
       display by name ctc15m01.*
    else
       error " Nao ha' nenhum tipo de assistencia nesta direcao!"
       initialize ctc15m01.*    to null
    end if
 else
    error " Nao ha' nenhum tipo de assistencia nesta direcao!"
    initialize ctc15m01.*    to null
 end if

 return ctc15m01.*

 end function  ###  ctc15m01_proximo

#------------------------------------------------------------
 function ctc15m01_anterior(param)
#------------------------------------------------------------

 define param         record
    asitipcod            like datkasitip.asitipcod
 end record

 define ctc15m01      record
    asitipcod         like datkasitip.asitipcod,
    asitipabvdes      like datkasitip.asitipabvdes,
    asitipdes         like datkasitip.asitipdes,
    asitipstt         like datkasitip.asitipstt,
    asitipsttdes      char (10),
    vclcndlclflg      like datkasitip.vclcndlclflg,
    atmacnflg         like datkasitip.atmacnflg,
    caddat            like datkasitip.caddat,
    cademp            like datkasitip.cademp,
    cadmat            like datkasitip.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasitip.atldat,
    atlemp            like datkasitip.atlemp,
    atlmat            like datkasitip.atlmat,
    atlfunnom         like isskfunc.funnom, 
    asiofndigflg      like datkasitip.asiofndigflg 
 end record


 let int_flag = false
 initialize ctc15m01.*  to null

 if param.asitipcod  is null   then
    let param.asitipcod = " "
 end if

 select max(datkasitip.asitipcod)
   into ctc15m01.asitipcod
   from datkasitip
  where asitipcod  <  param.asitipcod

 if ctc15m01.asitipcod  is not null   then
    call ctc15m01_ler(ctc15m01.asitipcod)
         returning ctc15m01.*

    if ctc15m01.asitipcod  is not null   then
       display by name ctc15m01.*
    else
       error " Nao ha' nenhum tipo de assistencia nesta direcao!"
       initialize ctc15m01.*    to null
    end if
 else
    error " Nao ha' nenhum tipo de assistencia nesta direcao!"
    initialize ctc15m01.*    to null
 end if

 return ctc15m01.*

 end function  ###  ctc15m01_anterior

#------------------------------------------------------------
 function ctc15m01_modifica(param, ctc15m01)
#------------------------------------------------------------

 define param         record
    asitipcod            like datkasitip.asitipcod
   ,asiofndigflg         like datkasitip.asiofndigflg 
 end record

 define ctc15m01      record
    asitipcod         like datkasitip.asitipcod,
    asitipabvdes      like datkasitip.asitipabvdes,
    asitipdes         like datkasitip.asitipdes,
    asitipstt         like datkasitip.asitipstt,
    asitipsttdes      char (10),
    vclcndlclflg      like datkasitip.vclcndlclflg,
    atmacnflg         like datkasitip.atmacnflg,
    caddat            like datkasitip.caddat,
    cademp            like datkasitip.cademp,
    cadmat            like datkasitip.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasitip.atldat,
    atlemp            like datkasitip.atlemp,
    atlmat            like datkasitip.atlmat,
    atlfunnom         like isskfunc.funnom, 
    asiofndigflg      like datkasitip.asiofndigflg 
 end record


 call ctc15m01_input("a", ctc15m01.*) returning ctc15m01.*

 if int_flag  then
    let int_flag = false
    initialize ctc15m01.*  to null
    display by name ctc15m01.*
    error " Operacao cancelada!"
    return ctc15m01.*
 end if

 let ctc15m01.atldat = today
 whenever error continue
 execute pctc15m01002 using ctc15m01.asitipabvdes, 
                            ctc15m01.asitipdes, ctc15m01.asitipstt,
                            ctc15m01.atldat, g_issk.empcod, g_issk.funmat,
                            ctc15m01.asiofndigflg, ctc15m01.vclcndlclflg,
                            ctc15m01.atmacnflg,
                            ctc15m01.asitipcod
 whenever error stop
 if sqlca.sqlcode <> 0  then
    display "ctc15m01.asitipabvdes: ",ctc15m01.asitipabvdes
    display "ctc15m01.asitipdes:    ",ctc15m01.asitipdes   
    display "ctc15m01.asitipstt:    ",ctc15m01.asitipstt
    display "ctc15m01.atldat:       ",ctc15m01.atldat
    display "g_issk.empcod:         ",g_issk.empcod        
    display "g_issk.funmat:         ",g_issk.funmat 
    display "ctc15m01.asiofndigflg: ",ctc15m01.asiofndigflg 
    display "ctc15m01.vclcndlclflg: ",ctc15m01.vclcndlclflg
    display "ctc15m01.atmacnflg:    ",ctc15m01.atmacnflg   
    display "ctc15m01.asitipcod:    ",ctc15m01.asitipcod
    
    error "Erro UPDATE pctc15m01002 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
    error "CTC15M01 / ctc15m01_modifica() "

    initialize ctc15m01.*   to null
    return ctc15m01.*
 else
    error " Alteracao efetuada com sucesso!"
 end if


 initialize ctc15m01.*  to null
 display by name ctc15m01.*
 message ""
 return ctc15m01.*

 end function  ###  ctc15m01_modifica

#------------------------------------------------------------
 function ctc15m01_inclui()
#------------------------------------------------------------

 define ctc15m01      record
    asitipcod         like datkasitip.asitipcod,
    asitipabvdes      like datkasitip.asitipabvdes,
    asitipdes         like datkasitip.asitipdes,
    asitipstt         like datkasitip.asitipstt,
    asitipsttdes      char (10),
    vclcndlclflg      like datkasitip.vclcndlclflg,
    atmacnflg         like datkasitip.atmacnflg,
    caddat            like datkasitip.caddat,
    cademp            like datkasitip.cademp,
    cadmat            like datkasitip.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasitip.atldat,
    atlemp            like datkasitip.atlemp,
    atlmat            like datkasitip.atlmat,
    atlfunnom         like isskfunc.funnom, 
    asiofndigflg      like datkasitip.asiofndigflg 
 end record

 define prompt_key    char (01)

 initialize ctc15m01.*   to null
 display by name ctc15m01.*

 call ctc15m01_input("i", ctc15m01.*) returning ctc15m01.*

 if int_flag  then
    let int_flag = false
    initialize ctc15m01.*  to null
    display by name ctc15m01.*
    error " Operacao cancelada!"
    return
 end if

 let ctc15m01.caddat = today
 let ctc15m01.cademp = g_issk.empcod
 let ctc15m01.cadmat = g_issk.funmat

 let ctc15m01.atldat = today
 let ctc15m01.atlemp = g_issk.empcod
 let ctc15m01.atlmat = g_issk.funmat

 whenever error continue

 select max(asitipcod)
   into ctc15m01.asitipcod
   from datkasitip
  where asitipcod > 0

 if sqlca.sqlcode < 0  then
    error " Erro (", sqlca.sqlcode, ") na geracao do codigo do tipo de assistencia!"
    return
 end if

 if ctc15m01.asitipcod is null  then
    let ctc15m01.asitipcod = 0
 end if

 let ctc15m01.asitipcod = ctc15m01.asitipcod + 1

 execute pctc15m01003 using ctc15m01.asitipcod,
                            ctc15m01.asitipabvdes,
                            ctc15m01.asitipdes,
                            ctc15m01.asitipstt,
                            ctc15m01.caddat,
                            ctc15m01.cademp,
                            ctc15m01.cadmat,
                            ctc15m01.atldat,
                            ctc15m01.atlemp,
                            ctc15m01.atlmat,
                            ctc15m01.asiofndigflg,
                            ctc15m01.vclcndlclflg,
                            ctc15m01.atmacnflg
 whenever error stop

 if sqlca.sqlcode <> 0  then
    error "Erro INSERT pctc15m01003 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
    error "CTC15M01 / ctc15m01_inclui() / ", ctc15m01.asitipcod sleep 2
    return
 end if

 call ctc15m01_func(ctc15m01.cademp, ctc15m01.cadmat)
      returning ctc15m01.cadfunnom

 call ctc15m01_func(ctc15m01.atlemp, ctc15m01.atlmat)
      returning ctc15m01.atlfunnom

 display by name ctc15m01.*

 display by name ctc15m01.asitipcod attribute (reverse)
 error " Inclusao efetuada com sucesso! Tecle ENTER..."
 prompt "" for char prompt_key

 initialize ctc15m01.*  to null
 display by name ctc15m01.*

 end function  ###  ctc15m01_inclui

#------------------------------------------------------------
 function ctc15m01_remove(param)
#------------------------------------------------------------

 define param         record
    asitipcod            like datkasitip.asitipcod
 end record

 menu "Confirma Exclusao ?"

    command "Nao" "Cancela exclusao do tipo de assistencia."
       clear form
       initialize param.*  to null
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui tipo de assistencia."
       whenever error continue

       delete from datkasitip
        where asitipcod = param.asitipcod

       whenever error stop

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na remocao do tipo de assistencia!"
       else
          error " Exclusao efetuada com sucesso!"
          clear form
       end if
       exit menu
 end menu

 return

 end function  ###  ctc15m01_remove

#--------------------------------------------------------------------
 function ctc15m01_input(param, ctc15m01)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define ctc15m01      record
    asitipcod         like datkasitip.asitipcod,
    asitipabvdes      like datkasitip.asitipabvdes,
    asitipdes         like datkasitip.asitipdes,
    asitipstt         like datkasitip.asitipstt,
    asitipsttdes      char (10),
    vclcndlclflg      like datkasitip.vclcndlclflg,
    atmacnflg         like datkasitip.atmacnflg,
    caddat            like datkasitip.caddat,
    cademp            like datkasitip.cademp,
    cadmat            like datkasitip.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasitip.atldat,
    atlemp            like datkasitip.atlemp,
    atlmat            like datkasitip.atlmat,
    atlfunnom         like isskfunc.funnom, 
    asiofndigflg      like datkasitip.asiofndigflg 
 end record


 let int_flag = false

 input by name ctc15m01.asitipabvdes,
               ctc15m01.asitipdes   ,
               ctc15m01.asiofndigflg,    #OSF 19968 
               ctc15m01.asitipstt,
               ctc15m01.vclcndlclflg,
               ctc15m01.atmacnflg     without defaults 

    before field asitipabvdes
           display by name ctc15m01.asitipabvdes attribute (reverse)

    after  field asitipabvdes
           display by name ctc15m01.asitipabvdes

           if ctc15m01.asitipabvdes is null  then
              error " Descricao abreviada deve ser informada!"
              next field asitipabvdes
           end if

    before field asitipdes
           display by name ctc15m01.asitipdes attribute (reverse)

    after  field asitipdes
           display by name ctc15m01.asitipdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field asitipabvdes
           end if

           if ctc15m01.asitipdes is null  then
              error " Descricao completa deve ser informada!"
              next field asitipdes
           end if

    before field asitipstt
           if param.operacao = "i"  then
              let ctc15m01.asitipstt    = "A"
              let ctc15m01.asitipsttdes = "ATIVO"
              #exit input       #OSF 19968 
             ## next field asiofndigflg 
           else
              display by name ctc15m01.asitipstt attribute (reverse)
           end if

    after  field asitipstt
           display by name ctc15m01.asitipstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field asiofndigflg
           end if

           if ctc15m01.asitipstt is null  then
              error " Situacao deve ser informada!"
              next field asitipstt
           else
              if ctc15m01.asitipstt = "A"  then
                 let ctc15m01.asitipsttdes = "ATIVO"
              else
                 if ctc15m01.asitipstt = "C"  then
                    let ctc15m01.asitipsttdes = "CANCELADO"
                 else
                    error " Situacao deve ser (A)tivo ou (C)ancelado!"
                    next field asitipstt
                 end if
              end if
           end if

           display by name ctc15m01.asitipsttdes

    before field asiofndigflg          #OSF 19968 
       display by name ctc15m01.asiofndigflg attribute (reverse) 

    after field asiofndigflg
       display by name ctc15m01.asiofndigflg

       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
          #if param.operacao = "i" then
             next field asitipdes
          #else  
          #   next field asitipstt
          #end if 
       end if

       if ctc15m01.asiofndigflg is null then
          error "Obrigatorio informar!"
          next field asiofndigflg
       end if
       if ctc15m01.asiofndigflg <> "N" and 
          ctc15m01.asiofndigflg <> "S" then
          error "Informar S ou N "
          next field asiofndigflg
       end if 

       display by name ctc15m01.asiofndigflg 
       
    before field vclcndlclflg
       display by name ctc15m01.vclcndlclflg attribute (reverse)

    after field vclcndlclflg
       display by name ctc15m01.vclcndlclflg

       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
          next field asitipdes
       end if

       if ctc15m01.vclcndlclflg is null then
          error "Obrigatorio informar!"
          next field vclcndlclflg
       end if
       if ctc15m01.vclcndlclflg <> "N" and 
          ctc15m01.vclcndlclflg <> "S" then
          error "Informar S ou N "
          next field vclcndlclflg
       end if 

    before field atmacnflg
       display by name ctc15m01.atmacnflg attribute (reverse)

    after field atmacnflg
       display by name ctc15m01.atmacnflg

       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
          next field vclcndlclflg
       end if

       if ctc15m01.atmacnflg is null then
          error "Obrigatorio informar!"
          next field atmacnflg
       end if
       if ctc15m01.atmacnflg <> "N" and
          ctc15m01.atmacnflg <> "S" then
          error "Informar S ou N "
          next field atmacnflg
       end if

    on key (interrupt)
       exit input

 end input

 if int_flag  then
    initialize ctc15m01.*  to null
 end if

 return ctc15m01.*

 end function  ###  ctc15m01_input

#---------------------------------------------------------
 function ctc15m01_ler(param)
#---------------------------------------------------------

 define param         record
    asitipcod            like datkasitip.asitipcod
 end record

 define ctc15m01      record
    asitipcod         like datkasitip.asitipcod,
    asitipabvdes      like datkasitip.asitipabvdes,
    asitipdes         like datkasitip.asitipdes,
    asitipstt         like datkasitip.asitipstt,
    asitipsttdes      char (10),
    vclcndlclflg      like datkasitip.vclcndlclflg,
    atmacnflg         like datkasitip.atmacnflg,
    caddat            like datkasitip.caddat,
    cademp            like datkasitip.cademp,
    cadmat            like datkasitip.cadmat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkasitip.atldat,
    atlemp            like datkasitip.atlemp,
    atlmat            like datkasitip.atlmat,
    atlfunnom         like isskfunc.funnom, 
    asiofndigflg      like datkasitip.asiofndigflg 
 end record

 initialize ctc15m01.*   to null
 
 open cctc15m01001 using param.asitipcod
 whenever error continue
 fetch cctc15m01001 into ctc15m01.asitipcod,
                         ctc15m01.asitipabvdes,
                         ctc15m01.asitipdes,
                         ctc15m01.asitipstt,
                         ctc15m01.caddat,
                         ctc15m01.cademp,
                         ctc15m01.cadmat,
                         ctc15m01.atldat,
                         ctc15m01.atlemp,
                         ctc15m01.atlmat,
                         ctc15m01.asiofndigflg,
                         ctc15m01.vclcndlclflg,
                         ctc15m01.atmacnflg
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound  then
       error " Tipo de assistencia nao cadastrado!"
       initialize ctc15m01.*    to null
       return ctc15m01.*
    else
       error "Erro SELECT cctc15m01001 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
       error "CTC15M01 / ctc15m01_ler() / ", param.asitipcod sleep 2
       exit program(1)
    end if
 end if

 call ctc15m01_func(ctc15m01.cademp, ctc15m01.cadmat)
      returning ctc15m01.cadfunnom

 call ctc15m01_func(ctc15m01.atlemp, ctc15m01.atlmat)
      returning ctc15m01.atlfunnom

 if ctc15m01.asitipstt = "A"  then
    let ctc15m01.asitipsttdes = "ATIVO"
 else
    let ctc15m01.asitipsttdes = "CANCELADO"
 end if

 return ctc15m01.*

 end function  ###  ctc15m01_ler

#---------------------------------------------------------
 function ctc15m01_func(param)
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
  where funmat = param.funmat
    and empcod = param.empcod

 return upshift(ws.funnom)

 end function  ###  ctc15m01_func
