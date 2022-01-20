###########################################################################
# Nome do Modulo: ctc14m00                                        Marcelo #
#                                                                Gilberto #
# Cadastro de agrupamento de codigos de assunto                  Mar/1998 #
# Alteracoes:                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
# 06/07/2006  PSI 199850   Priscila     Inclusao do campo departamento    #
#-------------------------------------------------------------------------#
# 14/11/2007  PSI 205206   Priscila     Inclusao do campo empresa         #
###########################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc14m00()
#------------------------------------------------------------

 define ctc14m00      record
    c24astagp         like datkastagp.c24astagp,
    c24astagpdes      like datkastagp.c24astagpdes,
    dptsgl            like datkastagp.dptsgl,      #PSI 199850
    dptnom            like isskdepto.dptnom,       #PSI 199850
    ciaempcod         like datkastagp.ciaempcod,   #PSI 205206
    empsgl            like gabkemp.empsgl,         #PSI 205206
    c24astagpsit      like datkastagp.c24astagpsit,
    caddat            like datkastagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkastagp.atldat,
    funnom            like isskfunc.funnom,
    observacao        char (60)
 end record


 let int_flag = false
 initialize ctc14m00.*  to null

 open window ctc14m00 at 4,2 with form "ctc14m00"


 menu "AGRUPAMENTOS"

 command key ("S") "Seleciona"
                   "Pesquisa agrupamento conforme criterios"
          call ctc14m00_seleciona()  returning ctc14m00.*
          if ctc14m00.c24astagp  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum agrupamento selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo agrupamento selecionado"
          message ""
          call ctc14m00_proximo(ctc14m00.c24astagp)
               returning ctc14m00.*

 command key ("A") "Anterior"
                   "Mostra agrupamento anterior selecionado"
          message ""
          if ctc14m00.c24astagp is not null then
             call ctc14m00_anterior(ctc14m00.c24astagp)
                  returning ctc14m00.*
          else
             error " Nenhum agrupamento nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica agrupamento corrente selecionado"
          message ""
          if ctc14m00.c24astagp  is not null then
             call ctc14m00_modifica(ctc14m00.c24astagp, ctc14m00.*)
                  returning ctc14m00.*
             next option "Seleciona"
          else
             error " Nenhum agrupamento selecionado!"
             next option "Seleciona"
          end if

 command key ("T") "assunTos"
                   "Manutencao dos assuntos do agrupamento corrente selecionado"
          message ""
          if ctc14m00.c24astagp  is not null then
             call ctc14m01(ctc14m00.c24astagp, ctc14m00.c24astagpdes)
             next option "Seleciona"
          else
             error " Nenhum agrupamento selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui agrupamento"
          message ""
          call ctc14m00_inclui()
          next option "Seleciona"

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc14m00

 end function  # ctc14m00


#------------------------------------------------------------
 function ctc14m00_seleciona()
#------------------------------------------------------------

 define ctc14m00      record
    c24astagp         like datkastagp.c24astagp,
    c24astagpdes      like datkastagp.c24astagpdes,
    dptsgl            like datkastagp.dptsgl,      #PSI 199850
    dptnom            like isskdepto.dptnom,       #PSI 199850
    ciaempcod         like datkastagp.ciaempcod,   #PSI 205206
    empsgl            like gabkemp.empsgl,         #PSI 205206
    c24astagpsit      like datkastagp.c24astagpsit,
    caddat            like datkastagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkastagp.atldat,
    funnom            like isskfunc.funnom,
    observacao        char (60)
 end record


 let int_flag = false
 initialize ctc14m00.*  to null
 display by name ctc14m00.*

 input by name ctc14m00.c24astagp

    before field c24astagp
        display by name ctc14m00.c24astagp attribute (reverse)

    after  field c24astagp
        display by name ctc14m00.c24astagp

        select c24astagp
          from datkastagp
         where datkastagp.c24astagp = ctc14m00.c24astagp

        if sqlca.sqlcode  =  notfound   then
           error " Agrupamento nao cadastrado!"
           next field c24astagp
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc14m00.*   to null
    display by name ctc14m00.*
    error " Operacao cancelada!"
    return ctc14m00.*
 end if

 call ctc14m00_ler(ctc14m00.c24astagp)
      returning ctc14m00.*

 if ctc14m00.c24astagp  is not null   then
    display by name  ctc14m00.*
 else
    error " Agrupamento nao cadastrado!"
    initialize ctc14m00.*    to null
 end if

 return ctc14m00.*

 end function  # ctc14m00_seleciona


#------------------------------------------------------------
 function ctc14m00_proximo(param)
#------------------------------------------------------------

 define param         record
    c24astagp         like datkastagp.c24astagp
 end record

 define ctc14m00      record
    c24astagp         like datkastagp.c24astagp,
    c24astagpdes      like datkastagp.c24astagpdes,
    dptsgl            like datkastagp.dptsgl,      #PSI 199850
    dptnom            like isskdepto.dptnom,       #PSI 199850
    ciaempcod         like datkastagp.ciaempcod,   #PSI 205206
    empsgl            like gabkemp.empsgl,         #PSI 205206
    c24astagpsit      like datkastagp.c24astagpsit,
    caddat            like datkastagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkastagp.atldat,
    funnom            like isskfunc.funnom,
    observacao        char (60)
 end record


 let int_flag = false
 initialize ctc14m00.*   to null

 if param.c24astagp  is null   then
    let param.c24astagp = " "
 end if

 select min(datkastagp.c24astagp)
   into ctc14m00.c24astagp
   from datkastagp
  where datkastagp.c24astagp  >  param.c24astagp

 if ctc14m00.c24astagp  is not null   then

    call ctc14m00_ler(ctc14m00.c24astagp)
         returning ctc14m00.*

    if ctc14m00.c24astagp  is not null   then
       display by name  ctc14m00.*
    else
       error " Nao ha' agrupamento nesta direcao!"
       initialize ctc14m00.*    to null
    end if
 else
    error " Nao ha' agrupamento nesta direcao!"
    initialize ctc14m00.*    to null
 end if

 return ctc14m00.*

 end function    # ctc14m00_proximo


#------------------------------------------------------------
 function ctc14m00_anterior(param)
#------------------------------------------------------------

 define param         record
    c24astagp         like datkastagp.c24astagp
 end record

 define ctc14m00      record
    c24astagp         like datkastagp.c24astagp,
    c24astagpdes      like datkastagp.c24astagpdes,
    dptsgl            like datkastagp.dptsgl,      #PSI 199850
    dptnom            like isskdepto.dptnom,       #PSI 199850
    ciaempcod         like datkastagp.ciaempcod,   #PSI 205206
    empsgl            like gabkemp.empsgl,         #PSI 205206
    c24astagpsit      like datkastagp.c24astagpsit,
    caddat            like datkastagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkastagp.atldat,
    funnom            like isskfunc.funnom,
    observacao        char (60)
 end record


 let int_flag = false
 initialize ctc14m00.*  to null

 if param.c24astagp  is null   then
    let param.c24astagp = " "
 end if

 select max(datkastagp.c24astagp)
   into ctc14m00.c24astagp
   from datkastagp
  where datkastagp.c24astagp  <  param.c24astagp

 if ctc14m00.c24astagp  is not null   then

    call ctc14m00_ler(ctc14m00.c24astagp)
         returning ctc14m00.*

    if ctc14m00.c24astagp  is not null   then
       display by name  ctc14m00.*
    else
       error " Nao ha' agrupamento nesta direcao!"
       initialize ctc14m00.*    to null
    end if
 else
    error " Nao ha' agrupamento nesta direcao!"
    initialize ctc14m00.*    to null
 end if

 return ctc14m00.*

 end function    # ctc14m00_anterior


#------------------------------------------------------------
 function ctc14m00_modifica(param, ctc14m00)
#------------------------------------------------------------

 define param         record
    c24astagp         like datkastagp.c24astagp
 end record

 define ctc14m00      record
    c24astagp         like datkastagp.c24astagp,
    c24astagpdes      like datkastagp.c24astagpdes,
    dptsgl            like datkastagp.dptsgl,      #PSI 199850
    dptnom            like isskdepto.dptnom,       #PSI 199850
    ciaempcod         like datkastagp.ciaempcod,   #PSI 205206
    empsgl            like gabkemp.empsgl,         #PSI 205206
    c24astagpsit      like datkastagp.c24astagpsit,
    caddat            like datkastagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkastagp.atldat,
    funnom            like isskfunc.funnom,
    observacao        char (60)
 end record


 call ctc14m00_input("a", ctc14m00.*) returning ctc14m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc14m00.*  to null
    display by name ctc14m00.*
    error " Operacao cancelada!"
    return ctc14m00.*
 end if

 whenever error continue

 let ctc14m00.atldat = today

 begin work
    update datkastagp set  ( c24astagpdes,
                             dptsgl,                 #PSI 199850
                             ciaempcod,              #PSI 205206
                             c24astagpsit,
                             atldat,
                             atlmat )
                        =  ( ctc14m00.c24astagpdes,
                             ctc14m00.dptsgl,         #PSI 199850
                             ctc14m00.ciaempcod,      #PSI 205206
                             ctc14m00.c24astagpsit,
                             ctc14m00.atldat,
                             g_issk.funmat )
           where datkastagp.c24astagp  =  ctc14m00.c24astagp

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do agrupamento!"
       rollback work
       initialize ctc14m00.*   to null
       return ctc14m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize ctc14m00.*  to null
 display by name ctc14m00.*
 message ""
 return ctc14m00.*

 end function   #  ctc14m00_modifica


#------------------------------------------------------------
 function ctc14m00_inclui()
#------------------------------------------------------------

 define ctc14m00      record
    c24astagp         like datkastagp.c24astagp,
    c24astagpdes      like datkastagp.c24astagpdes,
    dptsgl            like datkastagp.dptsgl,      #PSI 199850
    dptnom            like isskdepto.dptnom,       #PSI 199850
    ciaempcod         like datkastagp.ciaempcod,   #PSI 205206
    empsgl            like gabkemp.empsgl,         #PSI 205206
    c24astagpsit      like datkastagp.c24astagpsit,
    caddat            like datkastagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkastagp.atldat,
    funnom            like isskfunc.funnom,
    observacao        char (60)
 end record

 define  ws_resp       char(01)

 define l_ret       smallint,             #PSI 205206
        l_mensagem  char(60)

 initialize ctc14m00.*   to null
 let l_ret = 0                            #PSI 205206
 let l_mensagem = null                    #PSI 205206

 display by name ctc14m00.*

 call ctc14m00_input("i", ctc14m00.*) returning ctc14m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc14m00.*  to null
    display by name ctc14m00.*
    error " Operacao cancelada!"
    return
 end if

 let ctc14m00.atldat = today
 let ctc14m00.caddat = today

 whenever error continue

 begin work
    insert into datkastagp ( c24astagp,
                             c24astagpdes,
                             dptsgl,               #PSI 199850
                             ciaempcod,            #PSI 205206
                             c24astagpsit,
                             caddat,
                             cademp,
                             cadmat,
                             cadusrtip,
                             atldat,
                             atlmat,
                             atlemp,
                             atlusrtip )
                  values
                           ( ctc14m00.c24astagp,
                             ctc14m00.c24astagpdes,
                             ctc14m00.dptsgl,      #PSI 199850
                             ctc14m00.ciaempcod,   #PSI 205206
                             ctc14m00.c24astagpsit,
                             ctc14m00.caddat,
                             g_issk.empcod,
                             g_issk.funmat,                             
                             g_issk.usrtip,
                             ctc14m00.atldat,
                             g_issk.funmat,
                             g_issk.empcod,
                             g_issk.usrtip )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do agrupamento!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc14m00_func(g_issk.funmat,g_issk.empcod,g_issk.usrtip)
      returning ctc14m00.cadfunnom

 call ctc14m00_func(g_issk.funmat,g_issk.empcod,g_issk.usrtip)
      returning ctc14m00.funnom

 #PSI 199850
 #Buscar descrição do departamento
 call ctc14m00_depto(ctc14m00.dptsgl)
      returning ctc14m00.dptnom

 #PSI 205206
 #Buscar descricao da empresa
 call cty14g00_empresa(1, ctc14m00.ciaempcod)
      returning l_ret,
                l_mensagem,
                ctc14m00.empsgl

 display by name  ctc14m00.*

 display by name ctc14m00.c24astagp attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize ctc14m00.*  to null
 display by name ctc14m00.*

 end function   #  ctc14m00_inclui


#--------------------------------------------------------------------
 function ctc14m00_input(param, ctc14m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define ctc14m00      record
    c24astagp         like datkastagp.c24astagp,
    c24astagpdes      like datkastagp.c24astagpdes,
    dptsgl            like datkastagp.dptsgl,      #PSI 199850
    dptnom            like isskdepto.dptnom,       #PSI 199850
    ciaempcod         like datkastagp.ciaempcod,   #PSI 205206
    empsgl            like gabkemp.empsgl,         #PSI 205206
    c24astagpsit      like datkastagp.c24astagpsit,
    caddat            like datkastagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkastagp.atldat,
    funnom            like isskfunc.funnom,
    observacao        char (60)
 end record

 define l_erro        smallint,
        l_mensagem    char(60)     #PSI 205206

 let l_erro = 0
 let int_flag = false
 let l_mensagem = null

 input by name ctc14m00.c24astagp,
               ctc14m00.c24astagpdes,
               ctc14m00.dptsgl,             #PSI 199850
               ctc14m00.ciaempcod,          #PSI 205206
               ctc14m00.c24astagpsit  without defaults

    before field c24astagp
            if param.operacao  =  "a"   then
               next field  c24astagpdes
            end if
           display by name ctc14m00.c24astagp attribute (reverse)

    after  field c24astagp
           display by name ctc14m00.c24astagp

           if ctc14m00.c24astagp  is null   then
              error " Codigo do agrupamento deve ser informado!"
              next field c24astagp
           end if

           select c24astagp
             from datkastagp
            where c24astagp = ctc14m00.c24astagp

           if sqlca.sqlcode  =  0   then
              error " Codigo de agrupamento ja' cadastrado!"
              next field c24astagp
           end if

    before field c24astagpdes
           display by name ctc14m00.c24astagpdes attribute (reverse)

    after  field c24astagpdes
           display by name ctc14m00.c24astagpdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.operacao  =  "i"   then
                 next field  c24astagp
              else
                 next field  c24astagpdes
              end if
           end if

           if ctc14m00.c24astagpdes  is null   then
              error " Descricao do agrupamento deve ser informado!"
              next field c24astagpdes
           end if

    #PSI 199850
    before field dptsgl
           display by name ctc14m00.dptsgl attribute (reverse)

    after field dptsgl
           display by name ctc14m00.dptsgl

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  c24astagpdes
           end if

           if ctc14m00.dptsgl is null then
              #Abre pop-up com lista de departamentos
              call cty09g00_popup_isskdepto()
                    returning l_erro
                             ,ctc14m00.dptsgl
                             ,ctc14m00.dptnom
              if l_erro <> 1 then
                 error "Departamento nao selecionado"
                 #next field dptsgl
              end if
           else
              call ctc14m00_depto(ctc14m00.dptsgl)
                   returning ctc14m00.dptnom
              if ctc14m00.dptnom is null then
                   error "Sigla de departamento invalida!"
                   next field dptsgl
              end if
           end if
           display by name ctc14m00.dptnom

    #PSI 205206
    before field ciaempcod
           display by name ctc14m00.ciaempcod attribute (reverse)

    after field ciaempcod
           display by name ctc14m00.ciaempcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  dptsgl
           end if

           #se nao informou empresa ou se empresa e diferente de
           # 1 Porto Seguro ou 35 Azul
           if ctc14m00.ciaempcod is null then ## or
              ##(ctc14m00.ciaempcod <> 1   and
              ## ctc14m00.ciaempcod <> 27  and
              ## ctc14m00.ciaempcod <> 35  and
              ## ctc14m00.ciaempcod <> 40) then
            # error "Informe empresa: 1-Porto Seguro ou 35-Azul Seguros"

              call cty14g00_popup_empresa()
                    returning l_erro, ctc14m00.ciaempcod, ctc14m00.empsgl
              next field ciaempcod
           else
              call cty14g00_empresa(1,ctc14m00.ciaempcod)
                   returning l_erro,
                             l_mensagem,
                             ctc14m00.empsgl
              if l_erro <> 1 then
                 error l_mensagem
                 next field ciaempcod
              end if
           end if
           display by name ctc14m00.empsgl

    before field c24astagpsit
           if param.operacao  =  "i"   then
              let ctc14m00.c24astagpsit = "A"
           end if
           display by name ctc14m00.c24astagpsit attribute (reverse)

    after  field c24astagpsit
           display by name ctc14m00.c24astagpsit

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  ciaempcod
           end if

           if ctc14m00.c24astagpsit  is null   or
             (ctc14m00.c24astagpsit  <> "A"    and
              ctc14m00.c24astagpsit  <> "C")   then
              error " Situacao do agrupamento deve ser: (A)tivo ou (C)ancelado!"
              next field c24astagpsit
           end if

           if param.operacao      = "i"   and
              ctc14m00.c24astagpsit  = "C"   then
              error " Nao deve ser incluido agrupamento com situacao (C)ancelado!"
              next field c24astagpsit
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize ctc14m00.*  to null
 end if

 return ctc14m00.*

 end function   # ctc14m00_input


#---------------------------------------------------------
 function ctc14m00_ler(param)
#---------------------------------------------------------

 define param         record
    c24astagp         like datkastagp.c24astagp
 end record

 define ctc14m00      record
    c24astagp         like datkastagp.c24astagp,
    c24astagpdes      like datkastagp.c24astagpdes,
    dptsgl            like datkastagp.dptsgl,      #PSI 199850
    dptnom            like isskdepto.dptnom,       #PSI 199850
    ciaempcod         like datkastagp.ciaempcod,   #PSI 205206
    empsgl            like gabkemp.empsgl,         #PSI 205206
    c24astagpsit      like datkastagp.c24astagpsit,
    caddat            like datkastagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkastagp.atldat,
    funnom            like isskfunc.funnom,
    observacao        char (60)
 end record

 define ws            record
    atlmat            like isskfunc.funmat,
    cadmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    atlemp            like isskfunc.empcod,    
    cadusrtip         like isskfunc.usrtip,    
    atlusrtip         like isskfunc.usrtip,        
    cont              integer
 end record

 define l_ret       smallint,
        l_mensagem  char(60)


 initialize ctc14m00.*   to null
 initialize ws.*         to null
 let l_ret = 0
 let l_mensagem = null

 select  c24astagp,
         c24astagpdes,
         dptsgl,            #PSI 199850
         ciaempcod,         #PSI 205206
         c24astagpsit,
         caddat,
         cadmat,
         cademp,
         cadusrtip,
         atldat,
         atlmat,
         atlemp,
         atlusrtip         
   into  ctc14m00.c24astagp,
         ctc14m00.c24astagpdes,
         ctc14m00.dptsgl,    #PSI 199850
         ctc14m00.ciaempcod, #PSI 205206
         ctc14m00.c24astagpsit,
         ctc14m00.caddat,
         ws.cadmat,
         ws.cademp,
         ws.cadusrtip,
         ctc14m00.atldat,
         ws.atlmat,
         ws.atlemp,
         ws.atlusrtip
   from  datkastagp
  where  datkastagp.c24astagp = param.c24astagp

 if sqlca.sqlcode = notfound   then
    error " Agrupamento nao cadastrado!"
    initialize ctc14m00.*    to null
    return ctc14m00.*
 else
    call ctc14m00_func(ws.cadmat,ws.cademp,ws.cadusrtip)
         returning ctc14m00.cadfunnom

    call ctc14m00_func(ws.atlmat,ws.atlemp,ws.atlusrtip)
         returning ctc14m00.funnom

    #PSI 199850
    #Buscar descrição do departamento
    call ctc14m00_depto(ctc14m00.dptsgl)
         returning ctc14m00.dptnom

    #PSI 205206
    #Buscar descricao da empresa
    call cty14g00_empresa(1, ctc14m00.ciaempcod)
         returning l_ret,
                   l_mensagem,
                   ctc14m00.empsgl

    select count(*)
      into ws.cont
      from datkassunto
     where c24astagp = param.c24astagp
       and c24aststt = "A"

    if ws.cont  >  0   then
       let ctc14m00.observacao =  "EXISTE(M) ", ws.cont using "<<<,<<<", " CODIGO(S) DE ASSUNTO NESTE AGRUPAMENTO"
    else
       let ctc14m00.observacao =  "NAO EXISTE CODIGO DE ASSUNTO NESTE AGRUPAMENTO"
    end if

 end if

 return ctc14m00.*

 end function   # ctc14m00_ler


#---------------------------------------------------------
 function ctc14m00_func(param)
#---------------------------------------------------------

 define param         record
    funmat            like isskfunc.funmat,
    empcod            like isskfunc.empcod,
    usrtip            like isskfunc.usrtip
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null

   if param.empcod is null or 
      param.empcod = " " then
    let param.empcod = 1 
   end if 
 
   select funnom
     into ws.funnom
     from isskfunc
    where isskfunc.funmat = param.funmat
    and empcod = param.empcod 
    and usrtip = param.usrtip

 return ws.funnom

 end function   # ctc14m00_func

#PSI 199850
#---------------------------------------------------------
function ctc14m00_depto(param)
#---------------------------------------------------------

 define param         record
    dptsgl            like isskdepto.dptsgl
 end record

 define ws            record
    dptnom            like isskdepto.dptnom
 end record

 initialize ws.*    to null

 select dptnom
   into ws.dptnom
   from isskdepto
  where isskdepto.dptsgl = param.dptsgl

 return ws.dptnom

end function   # ctc14m00_depto
