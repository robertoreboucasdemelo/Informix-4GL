#############################################################################
# Nome do Modulo: CTC16M00                                         Marcelo  #
#                                                                  Gilberto #
# Cadastro de naturezas de socorro                                 Abr/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 04/10/1999  PSI 9234-7   Wagner       Incluir janela para digitacao das   #
#                                       clausulas agregadas a natureza.     #
#---------------------------------------------------------------------------#
# 15/07/2002  PSI 156248   Raji         Incluir grupo de natureza.          #
#---------------------------------------------------------------------------#
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso  #
#---------------------------------------------------------------------------#
# 18/06/2008  Andre Oliveira           Retorno do grupo de natureza para    #
#					              processo de cotas.		           #
# 17/08/2008  Fabio Costa PSI 221635   Adicionar descricao WEB              #
#############################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_res   smallint,
        m_msg   char(40)

#------------------------------------------------------------
 function ctc16m00()
#------------------------------------------------------------

 define ctc16m00      record
    socntzcod         like datksocntz.socntzcod,
    socntzdes         like datksocntz.socntzdes,
    socntzstt         like datksocntz.socntzstt,
    socntzgrpcod      like datksocntz.socntzgrpcod, 
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    natagdflg         like datksocntz.natagdflg,
    caddat            like datksocntz.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntz.atldat,
    atlfunnom         like isskfunc.funnom,
    c24pbmgrpcod      like datksocntz.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    webntzdes         like datksocntz.webntzdes,
    webvslflg         like datksocntz.webvslflg
 end record

 let int_flag = false
 let m_res = null
 let m_msg = null

 initialize ctc16m00.*  to null

 open window ctc16m00 at 04,02 with form "ctc16m00"

 menu "NATUREZAS"

 before menu
      hide option all
      #PSI 202290
      #if get_niv_mod(g_issk.prgsgl,"ctc16m00")  then
      #   if g_issk.acsnivcod >= g_issk.acsnivcns  then  ### NIVEL 3
            show option "Seleciona", "Proximo", "Anterior"
      #   end if
      #   if g_issk.acsnivcod >= g_issk.acsnivatl  then  ### NIVEL 6
            show option "Modifica", "Inclui", "Clausulas", "grupoXnaturezas"
      #   end if
      #   if g_issk.acsnivcod >= 8                 then  ### NIVEL 8
            show option "Remove"
      #   end if
      #end if
      show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa natureza conforme criterios"
          call ctc16m00_seleciona()  returning ctc16m00.*
          if ctc16m00.socntzcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma natureza selecionada!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proxima natureza selecionada"
          message ""
          call ctc16m00_proximo(ctc16m00.socntzcod)
               returning ctc16m00.*

 command key ("A") "Anterior"
                   "Mostra natureza anterior selecionada"
          message ""
          if ctc16m00.socntzcod is not null then
             call ctc16m00_anterior(ctc16m00.socntzcod)
                  returning ctc16m00.*
          else
             error " Nenhuma natureza nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica natureza selecionada"
          message ""
          if ctc16m00.socntzcod  is not null then
             call ctc16m00_modifica(ctc16m00.socntzcod, ctc16m00.*)
                  returning ctc16m00.*
             next option "Seleciona"
          else
             error " Nenhuma natureza selecionada!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui natureza"
          message ""
          call ctc16m00_inclui()
          next option "Seleciona"

 command key ("C") "Clausulas"
                   "Clausulas relacionadas a natureza selecionada"
          message ""
          if ctc16m00.socntzcod  is not null then
             call ctc16m01(ctc16m00.socntzcod)
             next option "Seleciona"
          else
             error " Nenhuma natureza selecionada!"
             next option "Seleciona"
          end if

 command key ("X") "GrupoXnaturezas"
                   "Clausulas relacionadas a natureza selecionada"
          message ""
          if ctc16m00.socntzcod is not null or  
             ctc16m00.socntzcod = 0 then
               call ctc65m00(ctc16m00.socntzcod, ctc16m00.socntzdes)
               next option "Seleciona"
          else
               error " Nenhuma natureza selecionada!"
               next option "Seleciona"
          end if

 command key ("R") "Remove"
                   "Remove natureza"
          message ""
          if ctc16m00.socntzcod  is not null then
             call ctc16m00_remove(ctc16m00.socntzcod)
             next option "Seleciona"
          else
             error " Nenhuma natureza selecionada!"
             next option "Seleciona"
          end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc16m00

 end function  ###  ctc16m00

#------------------------------------------------------------
 function ctc16m00_seleciona()
#------------------------------------------------------------

 define ctc16m00      record
    socntzcod         like datksocntz.socntzcod,
    socntzdes         like datksocntz.socntzdes,
    socntzstt         like datksocntz.socntzstt,
    socntzgrpcod      like datksocntz.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    natagdflg         like datksocntz.natagdflg,
    caddat            like datksocntz.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntz.atldat,
    atlfunnom         like isskfunc.funnom,
    c24pbmgrpcod      like datksocntz.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    webntzdes         like datksocntz.webntzdes,
    webvslflg         like datksocntz.webvslflg
 end record


 let int_flag = false
 initialize ctc16m00.*  to null
 display by name ctc16m00.*

 input by name ctc16m00.socntzcod

    before field socntzcod
        display by name ctc16m00.socntzcod attribute (reverse)

    after  field socntzcod
        display by name ctc16m00.socntzcod

        if ctc16m00.socntzcod is null  then
           select min(socntzcod)
             into ctc16m00.socntzcod
             from datksocntz

           if ctc16m00.socntzcod is null  then
              error " Nao existe nenhuma natureza cadastrada!"
              exit input
           end if
        end if

        select socntzcod
          from datksocntz
         where socntzcod = ctc16m00.socntzcod

        if sqlca.sqlcode = notfound  then
           error " Natureza nao cadastrada!"
           next field socntzcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc16m00.*   to null
    display by name ctc16m00.*
    error " Operacao cancelada!"
    return ctc16m00.*
 end if

 call ctc16m00_ler(ctc16m00.socntzcod)
      returning ctc16m00.*

 if ctc16m00.socntzcod  is not null   then
    display by name  ctc16m00.*
 else
    error " Natureza nao cadastrada!"
    initialize ctc16m00.*    to null
 end if

 return ctc16m00.*

 end function  ###  ctc16m00_seleciona

#------------------------------------------------------------
 function ctc16m00_proximo(param)
#------------------------------------------------------------

 define param         record
    socntzcod         like datksocntz.socntzcod
 end record

 define ctc16m00      record
    socntzcod         like datksocntz.socntzcod,
    socntzdes         like datksocntz.socntzdes,
    socntzstt         like datksocntz.socntzstt,
    socntzgrpcod      like datksocntz.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    natagdflg         like datksocntz.natagdflg,
    caddat            like datksocntz.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntz.atldat,
    atlfunnom         like isskfunc.funnom,
    c24pbmgrpcod      like datksocntz.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    webntzdes         like datksocntz.webntzdes,
    webvslflg         like datksocntz.webvslflg
 end record


 let int_flag = false
 initialize ctc16m00.*   to null

 if param.socntzcod  is null   then
    let param.socntzcod = " "
 end if

 select min(datksocntz.socntzcod)
   into ctc16m00.socntzcod
   from datksocntz
  where socntzcod  >  param.socntzcod

 if ctc16m00.socntzcod is not null  then

    call ctc16m00_ler(ctc16m00.socntzcod)
         returning ctc16m00.*

    if ctc16m00.socntzcod is not null  then
       display by name ctc16m00.*
    else
       error " Nao ha' nenhuma natureza nesta direcao!"
       initialize ctc16m00.*    to null
    end if
 else
    error " Nao ha' nenhuma natureza nesta direcao!"
    initialize ctc16m00.*    to null
 end if

 return ctc16m00.*

 end function  ###  ctc16m00_proximo

#------------------------------------------------------------
 function ctc16m00_anterior(param)
#------------------------------------------------------------

 define param         record
    socntzcod         like datksocntz.socntzcod
 end record

 define ctc16m00      record
    socntzcod         like datksocntz.socntzcod,
    socntzdes         like datksocntz.socntzdes,
    socntzstt         like datksocntz.socntzstt,
    socntzgrpcod      like datksocntz.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    natagdflg         like datksocntz.natagdflg,
    caddat            like datksocntz.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntz.atldat,
    atlfunnom         like isskfunc.funnom,
    c24pbmgrpcod      like datksocntz.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    webntzdes         like datksocntz.webntzdes,
    webvslflg         like datksocntz.webvslflg
 end record


 let int_flag = false
 initialize ctc16m00.*  to null

 if param.socntzcod  is null   then
    let param.socntzcod = " "
 end if

 select max(datksocntz.socntzcod)
   into ctc16m00.socntzcod
   from datksocntz
  where socntzcod  <  param.socntzcod

 if ctc16m00.socntzcod  is not null   then
    call ctc16m00_ler(ctc16m00.socntzcod)
         returning ctc16m00.*

    if ctc16m00.socntzcod  is not null   then
       display by name ctc16m00.*
    else
       error " Nao ha' nenhuma natureza nesta direcao!"
       initialize ctc16m00.*    to null
    end if
 else
    error " Nao ha' nenhuma natureza nesta direcao!"
    initialize ctc16m00.*    to null
 end if

 return ctc16m00.*

 end function  ###  ctc16m00_anterior

#------------------------------------------------------------
 function ctc16m00_modifica(param, ctc16m00)
#------------------------------------------------------------

 define param         record
    socntzcod         like datksocntz.socntzcod
 end record

 define ctc16m00      record
    socntzcod         like datksocntz.socntzcod,
    socntzdes         like datksocntz.socntzdes,
    socntzstt         like datksocntz.socntzstt,
    socntzgrpcod      like datksocntz.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    natagdflg         like datksocntz.natagdflg,
    caddat            like datksocntz.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntz.atldat,
    atlfunnom         like isskfunc.funnom,
    c24pbmgrpcod      like datksocntz.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    webntzdes         like datksocntz.webntzdes,
    webvslflg         like datksocntz.webvslflg
 end record


 call ctc16m00_input("a", ctc16m00.*) returning ctc16m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc16m00.*  to null
    display by name ctc16m00.*
    error " Operacao cancelada!"
    return ctc16m00.*
 end if

 whenever error continue

 let ctc16m00.atldat = today

 update datksocntz set  ( socntzdes,
                          socntzstt,
                          socntzgrpcod,
                          natagdflg,
                          atldat,
                          atlemp,
                          atlmat, 
                          c24pbmgrpcod,
                          webntzdes,
                          webvslflg )
                     =  ( ctc16m00.socntzdes,
                          ctc16m00.socntzstt,
                          ctc16m00.socntzgrpcod,
                          ctc16m00.natagdflg,
                          ctc16m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat,  
                          ctc16m00.c24pbmgrpcod,
                          ctc16m00.webntzdes,
                          ctc16m00.webvslflg )
                where socntzcod  =  ctc16m00.socntzcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao da natureza!"
    initialize ctc16m00.*   to null
    return ctc16m00.*
 else
    error " Alteracao efetuada com sucesso!"
 end if

 whenever error stop

 display by name ctc16m00.*
 message ""
 return ctc16m00.*

 end function  ###  ctc16m00_modifica

#------------------------------------------------------------
 function ctc16m00_inclui()
#------------------------------------------------------------

 define ctc16m00      record
    socntzcod         like datksocntz.socntzcod,
    socntzdes         like datksocntz.socntzdes,
    socntzstt         like datksocntz.socntzstt,
    socntzgrpcod      like datksocntz.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    natagdflg         like datksocntz.natagdflg,
    caddat            like datksocntz.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntz.atldat,
    atlfunnom         like isskfunc.funnom,
    c24pbmgrpcod      like datksocntz.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    webntzdes         like datksocntz.webntzdes,
    webvslflg         like datksocntz.webvslflg
 end record

 define prompt_key    char (01)
 
 initialize ctc16m00.*   to null
 display by name ctc16m00.*

 call ctc16m00_input("i", ctc16m00.*) returning ctc16m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc16m00.*  to null
    display by name ctc16m00.*
    error " Operacao cancelada!"
    return
 end if

 let ctc16m00.atldat = today
 let ctc16m00.caddat = today

 whenever error continue

 select max(socntzcod)
   into ctc16m00.socntzcod
   from datksocntz

 if ctc16m00.socntzcod is null  then
    let ctc16m00.socntzcod = 0
 end if

 let ctc16m00.socntzcod = ctc16m00.socntzcod + 1

 insert into datksocntz ( socntzcod,
                          socntzdes,
                          socntzstt,
                          socntzgrpcod,
                          natagdflg,
                          caddat,
                          cademp,
                          cadmat,
                          atldat,
                          atlemp,
                          atlmat,  
                          c24pbmgrpcod,
                          webntzdes,
                          webvslflg )
                 values ( ctc16m00.socntzcod,
                          ctc16m00.socntzdes,
                          ctc16m00.socntzstt,
                          ctc16m00.socntzgrpcod,
                          ctc16m00.natagdflg,
                          ctc16m00.caddat,
                          g_issk.empcod,
                          g_issk.funmat,
                          ctc16m00.atldat,
                          g_issk.empcod,
                          g_issk.funmat,  
                          ctc16m00.c24pbmgrpcod,
                          ctc16m00.webntzdes,
                          ctc16m00.webvslflg )

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao da natureza!"
    return
 end if

 whenever error stop

 call ctc16m00_func(g_issk.empcod, g_issk.funmat)
      returning ctc16m00.cadfunnom

 call ctc16m00_func(g_issk.empcod, g_issk.funmat)
      returning ctc16m00.atlfunnom

 display by name ctc16m00.*

 display by name ctc16m00.socntzcod attribute (reverse)
 error " Inclusao efetuada com sucesso! Tecle ENTER..."
 prompt "" for char prompt_key

 initialize ctc16m00.*  to null
 display by name ctc16m00.*

 end function  ###  ctc16m00_inclui

#------------------------------------------------------------
 function ctc16m00_remove(param)
#------------------------------------------------------------

 define param         record
    socntzcod         like datksocntz.socntzcod
 end record

 menu "Confirma Exclusao ?"

    command "Nao" "Cancela exclusao da natureza."
       clear form
       initialize param.*  to null
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui natureza"
       whenever error continue

       delete from datksocntz
        where socntzcod = param.socntzcod

       whenever error stop

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na remocao da natureza!"
       else
          delete from datrsocntzsrvre
           where socntzcod = param.socntzcod

          error " Exclusao efetuada com sucesso!"
          clear form
       end if
       exit menu
 end menu

 return

 end function  ###  ctc16m00_remove

#--------------------------------------------------------------------
 function ctc16m00_input(param, ctc16m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define ctc16m00      record
    socntzcod         like datksocntz.socntzcod,
    socntzdes         like datksocntz.socntzdes,
    socntzstt         like datksocntz.socntzstt,
    socntzgrpcod      like datksocntz.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    natagdflg         like datksocntz.natagdflg,
    caddat            like datksocntz.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntz.atldat,
    atlfunnom         like isskfunc.funnom,
    c24pbmgrpcod      like datksocntz.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    webntzdes         like datksocntz.webntzdes,
    webvslflg         like datksocntz.webvslflg
 end record

 define l_sql         char (1000)
 define l_erro        smallint
 define l_mensagem    char(80)
 define l_resultado   smallint


 let int_flag = false

 input by name ctc16m00.socntzdes,
               ctc16m00.socntzstt,
               ctc16m00.c24pbmgrpcod,
               ctc16m00.socntzgrpcod,
	       ctc16m00.natagdflg,
               ctc16m00.webntzdes,
               ctc16m00.webvslflg  without defaults

    before field socntzdes
           display by name ctc16m00.socntzdes attribute (reverse)

    after  field socntzdes
           display by name ctc16m00.socntzdes

           if ctc16m00.socntzdes is null  then
              error " Descricao da natureza deve ser informada!"
              next field socntzdes
           end if
        
    before field socntzstt
           if param.operacao  =  "i"   then
              let ctc16m00.socntzstt = "A"
              display by name ctc16m00.socntzstt
              next field c24pbmgrpcod
           else
              display by name ctc16m00.socntzstt attribute (reverse)
           end if

    after  field socntzstt
           display by name ctc16m00.socntzstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socntzdes
           end if

           if ctc16m00.socntzstt  is null   or
             (ctc16m00.socntzstt  <> "A"    and
              ctc16m00.socntzstt  <> "C")   then
              error " Situacao ser: (A)tivo ou (C)ancelado!"
              next field socntzstt
           end if

    before field socntzgrpcod
    	  display by name ctc16m00.socntzgrpcod attribute (reverse)
   
    after field socntzgrpcod
    	  call ctx24g00_descricao(ctc16m00.socntzgrpcod)
    	  	returning l_resultado, l_mensagem, ctc16m00.socntzgrpdes
    	  display by name ctc16m00.socntzgrpcod
    	  display by name ctc16m00.socntzgrpdes
    	  
    before field c24pbmgrpcod
           display by name ctc16m00.c24pbmgrpcod attribute (reverse)

    after  field c24pbmgrpcod
           display by name ctc16m00.c24pbmgrpcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.operacao  =  "i"   then
                 next field socntzdes
	      else
                 next field socntzstt
	      end if
           end if
           
           if ctc16m00.c24pbmgrpcod is null then
              call ctc48m02(9) ## atdsrvorg 
                  returning ctc16m00.c24pbmgrpcod, ctc16m00.c24pbmgrpdes 
           else
              call ctc48m02_descricao(ctc16m00.c24pbmgrpcod)
                   returning m_res, m_msg, ctc16m00.c24pbmgrpdes
           end if

           if ctc16m00.c24pbmgrpdes is null then
              next field c24pbmgrpcod
           end if
 
           display by name  ctc16m00.c24pbmgrpdes
           
           
    before field webntzdes
       display by name ctc16m00.webntzdes attribute (reverse)
    
    after field webntzdes
       display by name ctc16m00.webntzdes
       
       
    before field webvslflg
       display by name ctc16m00.webvslflg attribute (reverse)
    
    before field natagdflg
           display by name ctc16m00.natagdflg attribute (reverse)

    after  field natagdflg
           display by name ctc16m00.natagdflg
           
           if ctc16m00.natagdflg <> 'S'
               and ctc16m00.natagdflg <> 'N' then
                    Error "Somente S <SIM> ou N <NAO>!"
                    next field natagdflg
           end if        

    after field webvslflg
       display by name ctc16m00.webvslflg
       
       if ctc16m00.webvslflg is not null
          then
          if ctc16m00.webvslflg != "S" and ctc16m00.webvslflg != "N"
             then
             error " Opcao: (S)Sim ou (N)Nao "
             next field webvslflg
          end if
       end if
       
       if ctc16m00.webvslflg is not null and
          ctc16m00.webvslflg = "S" and
          ( ctc16m00.webntzdes is null or ctc16m00.webntzdes = " " )
          then
          error "Para visualizacao na WEB digite a descricao "
          next field webntzdes
       end if
       
       
    on key (interrupt)
       exit input

 end input

 if int_flag  then
    initialize ctc16m00.*  to null
 end if

 return ctc16m00.*

 end function  ###  ctc16m00_input

#---------------------------------------------------------
 function ctc16m00_ler(param)
#---------------------------------------------------------

 define param         record
    socntzcod         like datksocntz.socntzcod
 end record

 define ctc16m00      record
    socntzcod         like datksocntz.socntzcod,
    socntzdes         like datksocntz.socntzdes,
    socntzstt         like datksocntz.socntzstt,
    socntzgrpcod      like datksocntz.socntzgrpcod,
    socntzgrpdes      like datksocntzgrp.socntzgrpdes,
    natagdflg         like datksocntz.natagdflg,
    caddat            like datksocntz.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksocntz.atldat,
    atlfunnom         like isskfunc.funnom,
    c24pbmgrpcod      like datksocntz.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    webntzdes         like datksocntz.webntzdes,
    webvslflg         like datksocntz.webvslflg
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat
 end record


 initialize ctc16m00.*   to null
 initialize ws.*         to null

 select socntzcod,
        socntzdes,
        socntzstt,
        socntzgrpcod,
        natagdflg,
        caddat,
        cademp,
        cadmat,
        atldat,
        atlemp,
        atlmat,
        c24pbmgrpcod,
        webntzdes,
        webvslflg
   into ctc16m00.socntzcod,
        ctc16m00.socntzdes,
        ctc16m00.socntzstt,
        ctc16m00.socntzgrpcod,
        ctc16m00.natagdflg,
        ctc16m00.caddat,
        ws.cademp,
        ws.cadmat,
        ctc16m00.atldat,
        ws.atlemp,
        ws.atlmat,
        ctc16m00.c24pbmgrpcod,
        ctc16m00.webntzdes,
        ctc16m00.webvslflg
   from datksocntz
  where socntzcod = param.socntzcod

 if sqlca.sqlcode = notfound  then
    error " Natureza nao cadastrada!"
    initialize ctc16m00.*    to null
    return ctc16m00.*
 else
    call ctc16m00_func(ws.cademp, ws.cadmat)
         returning ctc16m00.cadfunnom

    call ctc16m00_func(ws.atlemp, ws.atlmat)
         returning ctc16m00.atlfunnom

    if ctc16m00.c24pbmgrpcod is not null then
       call ctc48m02_descricao(ctc16m00.c24pbmgrpcod)
            returning m_res, m_msg, ctc16m00.c24pbmgrpdes
    end if
    
    if ctc16m00.socntzcod is not null then
    	call ctx24g00_descricao(ctc16m00.socntzgrpcod)
    	    returning m_res, m_msg, ctc16m00.socntzgrpdes
    end if
 end if

 return ctc16m00.*

 end function  ###  ctc16m00_ler

#---------------------------------------------------------
 function ctc16m00_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record

 initialize ws.* to null

 call cty08g00_nome_func(param.empcod, param.funmat, "F")
      returning m_res, m_msg, ws.funnom 

 return ws.funnom

 end function  ###  ctc16m00_func
