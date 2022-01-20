###########################################################################
# Nome do Modulo: ctc43m00                                        Marcelo #
#                                                                Gilberto #
# Cadastro de Botoes dos MDT's                                   Jul/1999 #
#----------------------------------------------------------------------------#
#                          Alteracoes/Manutencoes                            #
# DATA         OBJETIVO                                  RESPONSAVEL         #
#----------------------------------------------------------------------------#
# 23/09/2002   Incluir a chamada da funcao que controla  Paula Romanini      #
#              o wordwrap.                                                   #
# ...........................................................................#
#                                                                            #
#                       * * * Alteracoes * * *                               #
#                                                                            #
# Data       Autor Fabrica   Origem        Alteracao                         #
# ---------- --------------  ----------    ----------------------------------#
# 10/09/2005 T. Solda,Meta   PSIMelhorias  Chamada da funcao                 #
#                                          "fun_dba_abre_banco" e troca da   #
#                                          "systables" por "dual"            #
#----------------------------------------------------------------------------#
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso   #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--- main deletar (paula) ---#
#main   #teste 1
# defer interrupt
# call ctc43m00()
#end main

#------------------------------------------------------------
 function ctc43m00()
#------------------------------------------------------------

 define d_ctc43m00    record
    mdtbotcod         like datkmdtbot.mdtbotcod,
    mdtbottxt         like datkmdtbot.mdtbottxt,
    mdtbotfncdes      like datkmdtbot.mdtbotfncdes,
    mdtbotstt         like datkmdtbot.mdtbotstt,
    caddat            like datkmdtbot.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtbot.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc43m00.*  to null

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc43m00") then
 #   error " Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if    #paula desinibir

 open window ctc43m00 at 04,02 with form "ctc43m00"

 menu "BOTOES"

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
   #paula desinibir
    command key ("S") "Seleciona"
                      "Pesquisa botao conforme criterios"
       call ctc43m00_seleciona() returning d_ctc43m00.*
       if d_ctc43m00.mdtbotcod is not null  then
          message ""
          next option "Proximo"
       else
          error " Nenhum botao selecionado!"
          message ""
          next option "Seleciona"
       end if

    command key ("P") "Proximo"
                      "Mostra proximo botao selecionado"
       message ""
       if d_ctc43m00.mdtbotcod is not null then
          call ctc43m00_proximo(d_ctc43m00.mdtbotcod)
               returning d_ctc43m00.*
       else
          error " Nenhum botao nesta direcao!"
          next option "Seleciona"
       end if

    command key ("A") "Anterior"
                      "Mostra botao anterior selecionado"
       message ""
       if d_ctc43m00.mdtbotcod is not null then
          call ctc43m00_anterior(d_ctc43m00.mdtbotcod)
               returning d_ctc43m00.*
       else
          error " Nenhum botao nesta direcao!"
          next option "Seleciona"
       end if

    command key ("M") "Modifica"
                      "Modifica botao corrente selecionado"
       message ""
       if d_ctc43m00.mdtbotcod  is not null then
          call ctc43m00_modifica(d_ctc43m00.mdtbotcod, d_ctc43m00.*)
               returning d_ctc43m00.*
               clear form
          next option "Seleciona"
       else
          error " Nenhum botao selecionado!"
          next option "Seleciona"
       end if
       initialize d_ctc43m00.*  to null

    command key ("I") "Inclui"
                      "Inclui botao"
       message ""
       call ctc43m00_inclui()
       next option "Seleciona"
       initialize d_ctc43m00.*  to null

    command key ("R") "Remove"
                      "Remove botao corrente selecionado"
       message ""
       if d_ctc43m00.mdtbotcod  is not null   then
          call ctc43m00_remove(d_ctc43m00.*)
               returning d_ctc43m00.*
          next option "Seleciona"
       else
          error " Nenhum botao selecionado!"
          next option "Seleciona"
       end if
       initialize d_ctc43m00.*  to null

    command key (interrupt,"E") "Encerra"
                                "Retorna ao menu anterior"
       exit menu
 end menu

 close window ctc43m00

 end function  ###  ctc43m00


#------------------------------------------------------------
 function ctc43m00_seleciona()
#------------------------------------------------------------

 define d_ctc43m00    record
    mdtbotcod         like datkmdtbot.mdtbotcod,
    mdtbottxt         like datkmdtbot.mdtbottxt,
    mdtbotfncdes      like datkmdtbot.mdtbotfncdes,
    mdtbotstt         like datkmdtbot.mdtbotstt,
    caddat            like datkmdtbot.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtbot.atldat,
    funnom            like isskfunc.funnom
 end record

 define w_edtxt_ok    char(01)

 let int_flag = false
 initialize d_ctc43m00.*  to null
 ###display by name d_ctc43m00.*   #paula deleta
 display by name d_ctc43m00.mdtbotcod
                ,d_ctc43m00.mdtbottxt
                ,d_ctc43m00.mdtbotstt
                ,d_ctc43m00.caddat
                ,d_ctc43m00.cadfunnom
                ,d_ctc43m00.atldat
                ,d_ctc43m00.funnom

 #----------------------------------------------------
 # Funcao que controla o wordwrap somente consulta
 #----------------------------------------------------
 call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
 returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes

 input by name d_ctc43m00.mdtbotcod

    before field mdtbotcod
        display by name d_ctc43m00.mdtbotcod attribute (reverse)

    after  field mdtbotcod
        display by name d_ctc43m00.mdtbotcod

        if d_ctc43m00.mdtbotcod  is null   then
           error " Botao deve ser informado!"
           next field mdtbotcod
        end if

        select mdtbotcod
          from datkmdtbot
         where datkmdtbot.mdtbotcod = d_ctc43m00.mdtbotcod

        if sqlca.sqlcode  =  notfound   then
           error " Botao nao cadastrado!"
           next field mdtbotcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc43m00.*   to null
    display by name d_ctc43m00.*  #paula deletar
    display by name d_ctc43m00.mdtbotcod   
                   ,d_ctc43m00.mdtbottxt         
                   ,d_ctc43m00.mdtbotstt       
                   ,d_ctc43m00.caddat         
                   ,d_ctc43m00.cadfunnom     
                   ,d_ctc43m00.atldat       
                   ,d_ctc43m00.funnom      

    #------------------------------------------
    # Funcao que controla o wordwrap
    #------------------------------------------
    call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
    returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes

    error " Operacao cancelada!"
    return d_ctc43m00.*
 end if

 call ctc43m00_ler(d_ctc43m00.mdtbotcod)
      returning d_ctc43m00.*

 if d_ctc43m00.mdtbotcod  is not null   then
    ###display by name  d_ctc43m00.*
    display by name d_ctc43m00.mdtbotcod   
                   ,d_ctc43m00.mdtbottxt         
                   ,d_ctc43m00.mdtbotstt       
                   ,d_ctc43m00.caddat         
                   ,d_ctc43m00.cadfunnom     
                   ,d_ctc43m00.atldat       
                   ,d_ctc43m00.funnom      

    #------------------------------------------
    # Funcao que controla o wordwrap
    #------------------------------------------
    call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
    returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes
 else
    error " Botao nao cadastrado!"
    initialize d_ctc43m00.*    to null
 end if

 return d_ctc43m00.*

 end function  ###  ctc43m00_seleciona


#------------------------------------------------------------
 function ctc43m00_proximo(param)
#------------------------------------------------------------

 define param         record
    mdtbotcod         like datkmdtbot.mdtbotcod
 end record

 define d_ctc43m00    record
    mdtbotcod         like datkmdtbot.mdtbotcod,
    mdtbottxt         like datkmdtbot.mdtbottxt,
    mdtbotfncdes      like datkmdtbot.mdtbotfncdes,
    mdtbotstt         like datkmdtbot.mdtbotstt,
    caddat            like datkmdtbot.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtbot.atldat,
    funnom            like isskfunc.funnom
 end record

 define w_edtxt_ok    char(01) 

 let int_flag = false
 initialize d_ctc43m00.*   to null

 if param.mdtbotcod  is null   then
    let param.mdtbotcod = 0
 end if

 select min(datkmdtbot.mdtbotcod)
   into d_ctc43m00.mdtbotcod
   from datkmdtbot
  where datkmdtbot.mdtbotcod  >  param.mdtbotcod

 if d_ctc43m00.mdtbotcod  is not null   then

    call ctc43m00_ler(d_ctc43m00.mdtbotcod)
         returning d_ctc43m00.*

    if d_ctc43m00.mdtbotcod  is not null   then
       ###display by name d_ctc43m00.*
       display by name d_ctc43m00.mdtbotcod   
                      ,d_ctc43m00.mdtbottxt         
                      ,d_ctc43m00.mdtbotstt       
                      ,d_ctc43m00.caddat         
                      ,d_ctc43m00.cadfunnom     
                      ,d_ctc43m00.atldat       
                      ,d_ctc43m00.funnom      

       #------------------------------------------
       # Funcao que controla o wordwrap
       #------------------------------------------
       call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
       returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes

    else
       error " Nao ha' botao nesta direcao!"
       initialize d_ctc43m00.*    to null
    end if
 else
    error " Nao ha' botao nesta direcao!"
    initialize d_ctc43m00.*    to null
 end if

 return d_ctc43m00.*

 end function  ###  ctc43m00_proximo


#------------------------------------------------------------
 function ctc43m00_anterior(param)
#------------------------------------------------------------

 define param         record
    mdtbotcod         like datkmdtbot.mdtbotcod
 end record

 define d_ctc43m00    record
    mdtbotcod         like datkmdtbot.mdtbotcod,
    mdtbottxt         like datkmdtbot.mdtbottxt,
    mdtbotfncdes      like datkmdtbot.mdtbotfncdes,
    mdtbotstt         like datkmdtbot.mdtbotstt,
    caddat            like datkmdtbot.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtbot.atldat,
    funnom            like isskfunc.funnom
 end record

 define w_edtxt_ok    char(01)

 let int_flag = false
 initialize d_ctc43m00.*  to null

 if param.mdtbotcod  is null   then
    let param.mdtbotcod = 0
 end if

 select max(datkmdtbot.mdtbotcod)
   into d_ctc43m00.mdtbotcod
   from datkmdtbot
  where datkmdtbot.mdtbotcod  <  param.mdtbotcod

 if d_ctc43m00.mdtbotcod  is not null   then

    call ctc43m00_ler(d_ctc43m00.mdtbotcod)
         returning d_ctc43m00.*

    if d_ctc43m00.mdtbotcod  is not null   then
       ###display by name  d_ctc43m00.*  #paula deletar
       display by name d_ctc43m00.mdtbotcod   
                      ,d_ctc43m00.mdtbottxt         
                      ,d_ctc43m00.mdtbotstt       
                      ,d_ctc43m00.caddat         
                      ,d_ctc43m00.cadfunnom     
                      ,d_ctc43m00.atldat       
                      ,d_ctc43m00.funnom      

       #------------------------------------------
       # Funcao que controla o wordwrap
       #------------------------------------------
       call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
       returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes
    else
       error " Nao ha' botao nesta direcao!"
       initialize d_ctc43m00.*    to null
    end if
 else
    error " Nao ha' botao nesta direcao!"
    initialize d_ctc43m00.*    to null
 end if

 return d_ctc43m00.*

 end function  ###  ctc43m00_anterior


#------------------------------------------------------------
 function ctc43m00_modifica(param, d_ctc43m00)
#------------------------------------------------------------

 define param         record
    mdtbotcod         like datkmdtbot.mdtbotcod
 end record

 define d_ctc43m00    record
    mdtbotcod         like datkmdtbot.mdtbotcod,
    mdtbottxt         like datkmdtbot.mdtbottxt,
    mdtbotfncdes      like datkmdtbot.mdtbotfncdes,
    mdtbotstt         like datkmdtbot.mdtbotstt,
    caddat            like datkmdtbot.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtbot.atldat,
    funnom            like isskfunc.funnom
 end record

 define prompt_key    char (01)
 define w_edtxt_ok    char (01)

 call ctc43m00_input("a", d_ctc43m00.*) returning d_ctc43m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc43m00.*  to null
    ###display by name d_ctc43m00.*  #paula deletar
    display by name d_ctc43m00.mdtbotcod   
                   ,d_ctc43m00.mdtbottxt         
                   ,d_ctc43m00.mdtbotstt       
                   ,d_ctc43m00.caddat         
                   ,d_ctc43m00.cadfunnom     
                   ,d_ctc43m00.atldat       
                   ,d_ctc43m00.funnom      

    #------------------------------------------
    # Funcao que controla o wordwrap
    #------------------------------------------
    call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
    returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes

    error " Operacao cancelada!"
    return d_ctc43m00.*
 end if

 whenever error continue

 let d_ctc43m00.atldat = today

 update datkmdtbot set  ( mdtbottxt,
                          mdtbotfncdes,
                          mdtbotstt,
                          atldat,
                          atlemp,
                          atlmat )
                     =  ( d_ctc43m00.mdtbottxt,
                          d_ctc43m00.mdtbotfncdes,
                          d_ctc43m00.mdtbotstt,
                          d_ctc43m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat )
        where datkmdtbot.mdtbotcod  =  d_ctc43m00.mdtbotcod

 if sqlca.sqlcode <>  0  then
    error " Erro (",sqlca.sqlcode,") na alteracao do botao!"
    prompt "" for char prompt_key
    initialize d_ctc43m00.*   to null
    return d_ctc43m00.*
 else
    error " Alteracao efetuada com sucesso!"
 end if

 whenever error stop

 initialize d_ctc43m00.*  to null
 ###display by name d_ctc43m00.*  #paula deletar
 display by name d_ctc43m00.mdtbotcod   
                ,d_ctc43m00.mdtbottxt         
                ,d_ctc43m00.mdtbotstt       
                ,d_ctc43m00.caddat         
                ,d_ctc43m00.cadfunnom     
                ,d_ctc43m00.atldat       
                ,d_ctc43m00.funnom      

 #------------------------------------------
 # Funcao que controla o wordwrap
 #------------------------------------------
 call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
 returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes

 message ""
 return d_ctc43m00.*

 end function  ###  ctc43m00_modifica


#------------------------------------------------------------
 function ctc43m00_inclui()
#------------------------------------------------------------

 define d_ctc43m00    record
    mdtbotcod         like datkmdtbot.mdtbotcod,
    mdtbottxt         like datkmdtbot.mdtbottxt,
    mdtbotfncdes      like datkmdtbot.mdtbotfncdes,
    mdtbotstt         like datkmdtbot.mdtbotstt,
    caddat            like datkmdtbot.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtbot.atldat,
    funnom            like isskfunc.funnom
 end record

 define prompt_key    char(01)
 define w_edtxt_ok    char(01)

 initialize d_ctc43m00.*   to null
 ###display by name d_ctc43m00.*
 display by name d_ctc43m00.mdtbotcod   
                ,d_ctc43m00.mdtbottxt         
                ,d_ctc43m00.mdtbotstt       
                ,d_ctc43m00.caddat         
                ,d_ctc43m00.cadfunnom     
                ,d_ctc43m00.atldat       
                ,d_ctc43m00.funnom      

 #------------------------------------------
 # Funcao que controla o wordwrap
 #------------------------------------------
 call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
 returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes

 call ctc43m00_input("i", d_ctc43m00.*) returning d_ctc43m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc43m00.*  to null
    ###display by name d_ctc43m00.*
    display by name d_ctc43m00.mdtbotcod   
                   ,d_ctc43m00.mdtbottxt         
                   ,d_ctc43m00.mdtbotstt       
                   ,d_ctc43m00.caddat         
                   ,d_ctc43m00.cadfunnom     
                   ,d_ctc43m00.atldat       
                   ,d_ctc43m00.funnom      

    #------------------------------------------
    # Funcao que controla o wordwrap
    #------------------------------------------
    call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
    returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes

    error " Operacao cancelada!"
    return
 end if

 let d_ctc43m00.atldat = today
 let d_ctc43m00.caddat = today

 declare c_ctc43m00m  cursor with hold  for
         select  max(mdtbotcod)
           from  datkmdtbot
          where  datkmdtbot.mdtbotcod > 0

 foreach c_ctc43m00m  into  d_ctc43m00.mdtbotcod
     exit foreach
 end foreach

 if d_ctc43m00.mdtbotcod is null   then
    let d_ctc43m00.mdtbotcod = 0
 end if
 let d_ctc43m00.mdtbotcod = d_ctc43m00.mdtbotcod + 1

 whenever error continue

 insert into datkmdtbot ( mdtbotcod,
                          mdtbottxt,
                          mdtbotfncdes,
                          mdtbotstt,
                          caddat,
                          cademp,
                          cadmat,
                          atldat,
                          atlemp,
                          atlmat )
                 values ( d_ctc43m00.mdtbotcod,
                          d_ctc43m00.mdtbottxt,
                          d_ctc43m00.mdtbotfncdes,
                          d_ctc43m00.mdtbotstt,
                          d_ctc43m00.caddat,
                          g_issk.empcod,
                          g_issk.funmat,
                          d_ctc43m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat )

 if sqlca.sqlcode <>  0   then
    error " Erro (",sqlca.sqlcode,") na inclusao do botao!"
    prompt "" for char prompt_key
    return
 end if

 whenever error stop

 call ctc43m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc43m00.cadfunnom

 call ctc43m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc43m00.funnom

 ###display by name  d_ctc43m00.*
 display by name d_ctc43m00.mdtbotcod   
                ,d_ctc43m00.mdtbottxt         
                ,d_ctc43m00.mdtbotstt       
                ,d_ctc43m00.caddat         
                ,d_ctc43m00.cadfunnom     
                ,d_ctc43m00.atldat       
                ,d_ctc43m00.funnom      

 #------------------------------------------
 # Funcao que controla o wordwrap
 #------------------------------------------
 call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
 returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes

 display by name d_ctc43m00.mdtbotcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char prompt_key

 initialize d_ctc43m00.*  to null
 ###display by name d_ctc43m00.*
 display by name d_ctc43m00.mdtbotcod   
                ,d_ctc43m00.mdtbottxt         
                ,d_ctc43m00.mdtbotstt       
                ,d_ctc43m00.caddat         
                ,d_ctc43m00.cadfunnom     
                ,d_ctc43m00.atldat       
                ,d_ctc43m00.funnom      

 #------------------------------------------
 # Funcao que controla o wordwrap
 #------------------------------------------
 call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
 returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes

 end function  ###  ctc43m00_inclui


#--------------------------------------------------------------------
 function ctc43m00_input(param, d_ctc43m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc43m00    record
    mdtbotcod         like datkmdtbot.mdtbotcod,
    mdtbottxt         like datkmdtbot.mdtbottxt,
    mdtbotfncdes      like datkmdtbot.mdtbotfncdes,
    mdtbotstt         like datkmdtbot.mdtbotstt,
    caddat            like datkmdtbot.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtbot.atldat,
    funnom            like isskfunc.funnom
 end record
 define l_aux_txt     like datkmdtbot.mdtbotfncdes
 
 define w_edtxt_ok    char(01)

 let int_flag = false
 let l_aux_txt = d_ctc43m00.mdtbotfncdes
 #initialize d_ctc43m00.mdtbotfncdes to null

 input by name d_ctc43m00.mdtbotcod,
               d_ctc43m00.mdtbottxt,
               d_ctc43m00.mdtbotfncdes,  #paula deletar
               d_ctc43m00.mdtbotstt  without defaults

    before field mdtbotcod
       call ctc43m00_wrap("C", l_aux_txt)
       returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes
       ##  let d_ctc43m00.mdtbotfncdes = l_aux_txt 
           next field mdtbottxt
           display by name d_ctc43m00.mdtbotcod attribute (reverse)

    after  field mdtbotcod
           display by name d_ctc43m00.mdtbotcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field mdtbotcod
           end if

           if d_ctc43m00.mdtbotcod is null  then
              error " Codigo do botao deve ser informado!"
              next field mdtbotcod
           end if

           select mdtbotcod
             from datkmdtbot
            where mdtbotcod = d_ctc43m00.mdtbotcod

           if sqlca.sqlcode = 0  then
              error " Codigo de botao ja' cadastrado!"
              next field mdtbotcod
           end if

    before field mdtbottxt
           display by name d_ctc43m00.mdtbottxt attribute (reverse)

    after  field mdtbottxt
           display by name d_ctc43m00.mdtbottxt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field mdtbottxt
           end if

           if d_ctc43m00.mdtbottxt is null  then
              error " Texto visivel no painel deve ser informado!"
              next field mdtbottxt
           end if

    before field mdtbotfncdes  #paula deletar
       #------------------------------------------
       # Funcao que controla o wordwrap
       #------------------------------------------
       call ctc43m00_wrap("I", d_ctc43m00.mdtbotfncdes)
       returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes
    
       if w_edtxt_ok = false then
          let int_flag = true
          exit input
         # next field mdtbotstt
       end if
    
       clear mdtbotfncdes[1]
       clear mdtbotfncdes[2]
       clear mdtbotfncdes[3]
       clear mdtbotfncdes[4]
       #----------------------------------------------------
       # Funcao que controla o wordwrap somente consulta
       #----------------------------------------------------
       call ctc43m00_wrap("C", d_ctc43m00.mdtbotfncdes)
       returning w_edtxt_ok, d_ctc43m00.mdtbotfncdes 
    
          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field mdtbottxt
           end if

           if d_ctc43m00.mdtbotfncdes is null  then
              error " Finalidade/Utilizacao deve ser informada!"
              next field mdtbotfncdes
           end if
           next field next

    before field mdtbotstt
           if param.operacao  =  "i"   then
              let d_ctc43m00.mdtbotstt  =  "A"
              display by name d_ctc43m00.mdtbotstt
              exit input
           else
              display by name d_ctc43m00.mdtbotstt attribute(reverse)
           end if

    after  field mdtbotstt
           display by name d_ctc43m00.mdtbotstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtbotfncdes #paula deleta
           end if

           if (d_ctc43m00.mdtbotstt  is null)   or
              (d_ctc43m00.mdtbotstt  <>  "A"    and
               d_ctc43m00.mdtbotstt  <>  "C")   then
              error " Situacao: (A)tivo, (C)ancelado!"
              next field  mdtbotstt
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag  then
    initialize d_ctc43m00.*  to null
 end if

 return d_ctc43m00.*

 end function  ###  ctc43m00_input


#--------------------------------------------------------------------
 function ctc43m00_remove(d_ctc43m00)
#--------------------------------------------------------------------

 define d_ctc43m00    record
    mdtbotcod         like datkmdtbot.mdtbotcod,
    mdtbottxt         like datkmdtbot.mdtbottxt,
    mdtbotfncdes      like datkmdtbot.mdtbotfncdes,
    mdtbotstt         like datkmdtbot.mdtbotstt,
    caddat            like datkmdtbot.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtbot.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    mdtprgcod         like datrmdtbotprg.mdtprgcod
 end record


 initialize ws.*  to null

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o botao"
       clear form
       initialize d_ctc43m00.* to null
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui botao"
       call ctc43m00_ler(d_ctc43m00.mdtbotcod) returning d_ctc43m00.*

       if sqlca.sqlcode = notfound  then
          initialize d_ctc43m00.* to null
          error " Botao nao localizado!"
       else

          initialize ws.mdtprgcod  to null

          select max (datrmdtbotprg.mdtprgcod)
            into ws.mdtprgcod
            from datrmdtbotprg
           where datrmdtbotprg.mdtbotcod = d_ctc43m00.mdtbotcod

          if ws.mdtprgcod  is not null   and
             ws.mdtprgcod  > 0           then
             error " Botao possui programacao cadastrada, portanto nao deve ser removido!"
             exit menu
          end if

          delete from datkmdtbot
           where mdtbotcod = d_ctc43m00.mdtbotcod

          if sqlca.sqlcode <> 0   then
             initialize d_ctc43m00.* to null
             error " Erro (",sqlca.sqlcode,") na exclusao do botao!"
          else
             initialize d_ctc43m00.* to null
             error   " Botao excluido!"
             message ""
             clear form
          end if
       end if
       exit menu
 end menu

 return d_ctc43m00.*

end function    # ctc43m00_remove


#---------------------------------------------------------
 function ctc43m00_ler(param)
#---------------------------------------------------------

 define param         record
    mdtbotcod         like datkmdtbot.mdtbotcod
 end record

 define d_ctc43m00    record
    mdtbotcod         like datkmdtbot.mdtbotcod,
    mdtbottxt         like datkmdtbot.mdtbottxt,
    mdtbotfncdes      like datkmdtbot.mdtbotfncdes,
    mdtbotstt         like datkmdtbot.mdtbotstt,
    caddat            like datkmdtbot.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdtbot.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat
 end record


 initialize d_ctc43m00.*   to null
 initialize ws.*           to null

 select  mdtbotcod,
         mdtbottxt,
         mdtbotfncdes,
         mdtbotstt,
         caddat,
         cademp,
         cadmat,
         atldat,
         atlemp,
         atlmat
   into  d_ctc43m00.mdtbotcod,
         d_ctc43m00.mdtbottxt,
         d_ctc43m00.mdtbotfncdes,
         d_ctc43m00.mdtbotstt,
         d_ctc43m00.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc43m00.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkmdtbot
  where  datkmdtbot.mdtbotcod = param.mdtbotcod

 if sqlca.sqlcode = notfound   then
    error " Botao nao cadastrado!"
    initialize d_ctc43m00.*    to null
    return d_ctc43m00.*
 else
    call ctc43m00_func(ws.cademp, ws.cadmat)
         returning d_ctc43m00.cadfunnom

    call ctc43m00_func(ws.atlemp, ws.atlmat)
         returning d_ctc43m00.funnom
 end if

 return d_ctc43m00.*

 end function   # ctc43m00_ler


#---------------------------------------------------------
 function ctc43m00_func(param)
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

 end function   # ctc43m00_func


#==============================================================================
function ctc43m00_wrap(l_tipo, l_mdtbotfncdes)
#==============================================================================

     define l_tipo               char (001),
            l_mdtbotfncdes       char(250),                      
            l_fimtxt             smallint,
            l_incpos             integer,
            l_string             char (300),
            l_null               char (001),
            l_i                  smallint

     clear mdtbotfncdes[1]
     clear mdtbotfncdes[2]
     clear mdtbotfncdes[3]
     clear mdtbotfncdes[4]

     if l_tipo = 'C' then
        let  l_incpos = 01
        let  l_fimtxt = false
        let  l_string = " "
        let  l_i      = 01

        while l_fimtxt = false
              call figrc001_wraptxt_jst ( l_mdtbotfncdes    # Texto
                                        , 50
                                        , l_incpos
                                        , ascii(10)
                                        , 005
                                        , 00
                                        , ""
                                        , ""
                                        , ""
                                        , "" )
              returning l_fimtxt
                      , l_string
                      , l_incpos
                      , l_null
                      , l_null

              display l_string to mdtbotfncdes[l_i]

              let  l_i = l_i + 01

              if l_i > 4 then
                 exit while
              end if
        end while
     end if

     if l_tipo = "I" then
        call figrc002_wraptxt_var (13            # 1. Linha   de inicio do txt
                                  ,22            # 2. Coluna  de inicio do txt
                                  ,04            # 3. Linhas  na tela
                                  ,50            # 4. Colunas na tela
                                  ,"N"           # 5. Flag exibir NomeTexto e
                                                 #    Situacao
                                  ,"NN"          # 6. Flag exibir Cab./Regua
                                  ,"N"           # 7. Opcao de acentuacao
                                  ,050           # 8. Tamanho max. da linha
                                  ,004           # 9. Tamanho max. do texto
                                  ,001           #10. Tamanho scroll
                                  ,ASCII(10)     #11. Caracter de Fim de Linha
                                  ,l_mdtbotfncdes#12. Texto Separado pelo #11.
                                  ,""            #13. Cabecalho do texto
                                  ,""            #14. Cabecalho Identificacao de
                                                 #    colunas.
                                  ,"S"           #15. Flag.Edicao Automatica
                                                 #    S-im / N-ao / B-loqueio
                                  ,002           #16. Flag.Maiusculo/Minusculo
                                  ,""            #17. Sequencia de Caracteres
                                                 #    NAO computados
                                  ,g_issk.empcod #18. Empresa do Funcionario
                                  ,g_issk.funmat #19. Matricula Ult. Alteracao
                                  ,today         #20. Data da Ultima Alteracao
                                  ," "           #21. Tipo de usuario
                                  ,"N"           #22. Exibir Borda (S/N)
                                  ,"N"           #23. Manter window aberta
                                  ,"S"           #24. SAIR COM CRTL-C
                                  ," "           #25. NAO Utilizado
                                  ," "           #26. NAO Utilizado
                                  ," "           #27. NAO Utilizado
                                  ," "           #28. NAO Utilizado
                                  ," "           #29. NAO Utilizado
                                  ," " )         #30. NAO Utilizado
        returning l_fimtxt
                , l_mdtbotfncdes

        if l_fimtxt = false then
           error "CANCELADO !"
           sleep 01
        end if
    end if

     return l_fimtxt, l_mdtbotfncdes

end  function
