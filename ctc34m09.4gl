###########################################################################
# Nome do Modulo: ctc34m09                                        Marcelo #
#                                                                Gilberto #
# Cadastro de pager's para impressao remota                      Set/1998 #
###########################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc34m09()
#------------------------------------------------------------

 define d_ctc34m09    record
    atdimpcod         like datktrximp.atdimpcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    atdimpsit         like datktrximp.atdimpsit,
    atdimpsitdes      char (13),
    caddat            like datktrximp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datktrximp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m09.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctc34m09") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc34m09 at 4,2 with form "ctc34m09"

 menu "PAGERS"

  before menu
     hide option all
     if g_issk.acsnivcod >= g_issk.acsnivcns  then
        show option "Seleciona", "Proximo", "Anterior"
     end if
     if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "Remove"
     end if

     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa pager conforme criterios"

          call ctc34m09_seleciona()  returning d_ctc34m09.*

          if d_ctc34m09.atdimpcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum pager selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo pager selecionado"
          message ""
          call ctc34m09_proximo(d_ctc34m09.atdimpcod)
               returning d_ctc34m09.*

 command key ("A") "Anterior"
                   "Mostra pager anterior selecionado"
          message ""
          if d_ctc34m09.atdimpcod is not null then
             call ctc34m09_anterior(d_ctc34m09.atdimpcod)
                  returning d_ctc34m09.*
          else
             error " Nenhum pager nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica pager corrente selecionado"
          message ""
          if d_ctc34m09.atdimpcod  is not null then
             call ctc34m09_modifica(d_ctc34m09.atdimpcod, d_ctc34m09.*)
                  returning d_ctc34m09.*
             next option "Seleciona"
          else
             error " Nenhum pager selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui pager"
          message ""
          call ctc34m09_inclui()
          next option "Seleciona"

   command "Remove" "Remove pager corrente selecionado"
            message ""
            if d_ctc34m09.atdimpcod  is not null   then
               call ctc34m09_remove(d_ctc34m09.*)  returning d_ctc34m09.*
               next option "Seleciona"
            else
               error " Nenhum pager selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc34m09

 end function  # ctc34m09


#------------------------------------------------------------
 function ctc34m09_seleciona()
#------------------------------------------------------------

 define d_ctc34m09    record
    atdimpcod         like datktrximp.atdimpcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    atdimpsit         like datktrximp.atdimpsit,
    atdimpsitdes      char (13),
    caddat            like datktrximp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datktrximp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m09.*  to null
 display by name d_ctc34m09.*

 input by name d_ctc34m09.atdimpcod

    before field atdimpcod
        display by name d_ctc34m09.atdimpcod attribute (reverse)

    after  field atdimpcod
        display by name d_ctc34m09.atdimpcod

        select atdimpcod
          from datktrximp
         where datktrximp.atdimpcod = d_ctc34m09.atdimpcod

        if sqlca.sqlcode  =  notfound   then
           error " Pager nao cadastrado!"
           next field atdimpcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m09.*   to null
    display by name d_ctc34m09.*
    error " Operacao cancelada!"
    return d_ctc34m09.*
 end if

 call ctc34m09_ler(d_ctc34m09.atdimpcod)
      returning d_ctc34m09.*

 if d_ctc34m09.atdimpcod  is not null   then
    display by name  d_ctc34m09.*
 else
    error " Pager nao cadastrado!"
    initialize d_ctc34m09.*    to null
 end if

 return d_ctc34m09.*

 end function  # ctc34m09_seleciona


#------------------------------------------------------------
 function ctc34m09_proximo(param)
#------------------------------------------------------------

 define param         record
    atdimpcod         like datktrximp.atdimpcod
 end record

 define d_ctc34m09    record
    atdimpcod         like datktrximp.atdimpcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    atdimpsit         like datktrximp.atdimpsit,
    atdimpsitdes      char (13),
    caddat            like datktrximp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datktrximp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m09.*   to null

 if param.atdimpcod  is null   then
    let param.atdimpcod = 0
 end if

 select min(datktrximp.atdimpcod)
   into d_ctc34m09.atdimpcod
   from datktrximp
  where datktrximp.atdimpcod  >  param.atdimpcod

 if d_ctc34m09.atdimpcod  is not null   then

    call ctc34m09_ler(d_ctc34m09.atdimpcod)
         returning d_ctc34m09.*

    if d_ctc34m09.atdimpcod  is not null   then
       display by name d_ctc34m09.*
    else
       error " Nao ha' pager nesta direcao!"
       initialize d_ctc34m09.*    to null
    end if
 else
    error " Nao ha' pager nesta direcao!"
    initialize d_ctc34m09.*    to null
 end if

 return d_ctc34m09.*

 end function    # ctc34m09_proximo


#------------------------------------------------------------
 function ctc34m09_anterior(param)
#------------------------------------------------------------

 define param         record
    atdimpcod         like datktrximp.atdimpcod
 end record

 define d_ctc34m09    record
    atdimpcod         like datktrximp.atdimpcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    atdimpsit         like datktrximp.atdimpsit,
    atdimpsitdes      char (13),
    caddat            like datktrximp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datktrximp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize d_ctc34m09.*  to null

 if param.atdimpcod  is null   then
    let param.atdimpcod = 0
 end if

 select max(datktrximp.atdimpcod)
   into d_ctc34m09.atdimpcod
   from datktrximp
  where datktrximp.atdimpcod  <  param.atdimpcod

 if d_ctc34m09.atdimpcod  is not null   then

    call ctc34m09_ler(d_ctc34m09.atdimpcod)
         returning d_ctc34m09.*

    if d_ctc34m09.atdimpcod  is not null   then
       display by name  d_ctc34m09.*
    else
       error " Nao ha' pager nesta direcao!"
       initialize d_ctc34m09.*    to null
    end if
 else
    error " Nao ha' pager nesta direcao!"
    initialize d_ctc34m09.*    to null
 end if

 return d_ctc34m09.*

 end function    # ctc34m09_anterior


#------------------------------------------------------------
 function ctc34m09_modifica(param, d_ctc34m09)
#------------------------------------------------------------

 define param         record
    atdimpcod         like datktrximp.atdimpcod
 end record

 define d_ctc34m09    record
    atdimpcod         like datktrximp.atdimpcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    atdimpsit         like datktrximp.atdimpsit,
    atdimpsitdes      char (13),
    caddat            like datktrximp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datktrximp.atldat,
    funnom            like isskfunc.funnom
 end record


 call ctc34m09_input("a", d_ctc34m09.*) returning d_ctc34m09.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m09.*  to null
    display by name d_ctc34m09.*
    error " Operacao cancelada!"
    return d_ctc34m09.*
 end if

 whenever error continue

 let d_ctc34m09.atldat = today

 begin work
    update datktrximp set  ( atdimpsit,
                             atldat,
                             atlemp,
                             atlmat )
                        =  ( d_ctc34m09.atdimpsit,
                             d_ctc34m09.atldat,
                             g_issk.empcod,
                             g_issk.funmat )
           where datktrximp.atdimpcod  =  d_ctc34m09.atdimpcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do pager!"
       rollback work
       initialize d_ctc34m09.*   to null
       return d_ctc34m09.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc34m09.*  to null
 display by name d_ctc34m09.*
 message ""
 return d_ctc34m09.*

 end function   #  ctc34m09_modifica


#------------------------------------------------------------
 function ctc34m09_inclui()
#------------------------------------------------------------

 define d_ctc34m09    record
    atdimpcod         like datktrximp.atdimpcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    atdimpsit         like datktrximp.atdimpsit,
    atdimpsitdes      char (13),
    caddat            like datktrximp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datktrximp.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp      char(01)


 initialize d_ctc34m09.*   to null
 display by name d_ctc34m09.*

 call ctc34m09_input("i", d_ctc34m09.*) returning d_ctc34m09.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m09.*  to null
    display by name d_ctc34m09.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc34m09.atldat = today
 let d_ctc34m09.caddat = today


 whenever error continue

 begin work
    insert into datktrximp ( atdimpcod,
                             atdimpsit,
                             caddat,
                             cademp,
                             cadmat,
                             atldat,
                             atlemp,
                             atlmat )
                  values
                           ( d_ctc34m09.atdimpcod,
                             d_ctc34m09.atdimpsit,
                             d_ctc34m09.caddat,
                             g_issk.empcod,
                             g_issk.funmat,
                             d_ctc34m09.atldat,
                             g_issk.empcod,
                             g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do pager!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc34m09_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc34m09.cadfunnom

 call ctc34m09_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc34m09.funnom

 display by name  d_ctc34m09.*

 display by name d_ctc34m09.atdimpcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc34m09.*  to null
 display by name d_ctc34m09.*

 end function   #  ctc34m09_inclui


#--------------------------------------------------------------------
 function ctc34m09_input(param, d_ctc34m09)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc34m09    record
    atdimpcod         like datktrximp.atdimpcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    atdimpsit         like datktrximp.atdimpsit,
    atdimpsitdes      char (13),
    caddat            like datktrximp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datktrximp.atldat,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false

 input by name d_ctc34m09.atdimpcod,
               d_ctc34m09.atdimpsit  without defaults

    before field atdimpcod
           if param.operacao  =  "a"   then
              next field atdimpsit
           end if
           display by name d_ctc34m09.atdimpcod attribute (reverse)

    after  field atdimpcod
           display by name d_ctc34m09.atdimpcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  atdimpcod
           end if

           if d_ctc34m09.atdimpcod  is null   then
              error " Codigo do pager deve ser informado!"
              next field atdimpcod
           end if

           select atdimpcod
             from datktrximp
            where datktrximp.atdimpcod  =  d_ctc34m09.atdimpcod

           if sqlca.sqlcode  =  0    then
              error " Codigo de pager ja' cadastrado!"
              next field atdimpcod
           end if

    before field atdimpsit
           display by name d_ctc34m09.atdimpsit attribute (reverse)

    after  field atdimpsit
           display by name d_ctc34m09.atdimpsit

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.operacao  =  "a"   then
                 next field atdimpsit
              end if
              next field  atdimpcod
           end if

           if d_ctc34m09.atdimpsit  is null   then
              error " Situacao do pager deve ser informada!"
              call ctn36c00("Situacao do pager", "atdimpsit")
                   returning  d_ctc34m09.atdimpsit
              next field atdimpsit
           end if

           select cpodes
             into d_ctc34m09.atdimpsitdes
             from iddkdominio
            where iddkdominio.cponom  =  "atdimpsit"
              and iddkdominio.cpocod  =  d_ctc34m09.atdimpsit

           if sqlca.sqlcode  <>  0   then
              error " Situacao nao cadastrada!"
              call ctn36c00("Situacao do pager", "atdimpsit")
                   returning  d_ctc34m09.atdimpsit
              next field atdimpsit
           end if
           display by name d_ctc34m09.atdimpsitdes

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc34m09.*  to null
 end if

 return d_ctc34m09.*

 end function   # ctc34m09_input


#--------------------------------------------------------------------
 function ctc34m09_remove(d_ctc34m09)
#--------------------------------------------------------------------

 define d_ctc34m09    record
    atdimpcod         like datktrximp.atdimpcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    atdimpsit         like datktrximp.atdimpsit,
    atdimpsitdes      char (13),
    caddat            like datktrximp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datktrximp.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    socvclcod         like datreqpvcl.socvclcod
 end record


 initialize ws.*  to null

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o pager"
            clear form
            initialize d_ctc34m09.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui pager"
            call ctc34m09_ler(d_ctc34m09.atdimpcod) returning d_ctc34m09.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc34m09.* to null
               error " Pager nao localizado!"
            else

               initialize ws.socvclcod  to null

               select max (datkveiculo.socvclcod)
                 into ws.socvclcod
                 from datkveiculo
                where datkveiculo.atdimpcod = d_ctc34m09.atdimpcod

               if ws.socvclcod  is not null   and
                  ws.socvclcod  > 0           then
                  error " Pager cadastrado no veiculo --> ", ws.socvclcod
                  exit menu
               end if

               begin work
                  delete from datktrximp
                   where datktrximp.atdimpcod = d_ctc34m09.atdimpcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc34m09.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do pager!"
               else
                  initialize d_ctc34m09.* to null
                  error   " Pager excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc34m09.*

end function    # ctc34m09_remove


#---------------------------------------------------------
 function ctc34m09_ler(param)
#---------------------------------------------------------

 define param         record
    atdimpcod         like datktrximp.atdimpcod
 end record

 define d_ctc34m09    record
    atdimpcod         like datktrximp.atdimpcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    atdimpsit         like datktrximp.atdimpsit,
    atdimpsitdes      char (13),
    caddat            like datktrximp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datktrximp.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    vclcoddig         like datkveiculo.vclcoddig,
    vclmrcnom         like agbkmarca.vclmrcnom,
    vcltipnom         like agbktip.vcltipnom,
    vclmdlnom         like agbkveic.vclmdlnom
 end record


 initialize d_ctc34m09.*   to null
 initialize ws.*           to null

 select  datktrximp.atdimpcod,
         datktrximp.atdimpsit,
         datktrximp.caddat,
         datktrximp.cademp,
         datktrximp.cadmat,
         datktrximp.atldat,
         datktrximp.atlemp,
         datktrximp.atlmat,
         datkveiculo.socvclcod,
         datkveiculo.atdvclsgl,
         datkveiculo.vclcoddig
   into  d_ctc34m09.atdimpcod,
         d_ctc34m09.atdimpsit,
         d_ctc34m09.caddat,
         ws.cademp,
         ws.cadmat,
         d_ctc34m09.atldat,
         ws.atlemp,
         ws.atlmat,
         d_ctc34m09.socvclcod,
         d_ctc34m09.atdvclsgl,
         ws.vclcoddig
   from  datktrximp, outer datkveiculo
  where  datktrximp.atdimpcod   =  param.atdimpcod
    and  datkveiculo.atdimpcod  =  datktrximp.atdimpcod

 if sqlca.sqlcode = notfound   then
    error " Pager nao cadastrado!"
    initialize d_ctc34m09.*    to null
    return d_ctc34m09.*
 else

    #---------------------------------------------------------
    # Descricao do veiculo
    #---------------------------------------------------------
    if ws.vclcoddig  is not null   then
       select vclmrcnom,
              vcltipnom,
              vclmdlnom
         into ws.vclmrcnom,
              ws.vcltipnom,
              ws.vclmdlnom
         from agbkveic, outer agbkmarca, outer agbktip
        where agbkveic.vclcoddig  = ws.vclcoddig
          and agbkmarca.vclmrccod = agbkveic.vclmrccod
          and agbktip.vclmrccod   = agbkveic.vclmrccod
          and agbktip.vcltipcod   = agbkveic.vcltipcod

       let d_ctc34m09.vcldes = ws.vclmrcnom clipped, " ",
                               ws.vcltipnom clipped, " ",
                               ws.vclmdlnom
    end if

    #---------------------------------------------------------
    # Situacao do pager
    #---------------------------------------------------------
    select cpodes
      into d_ctc34m09.atdimpsitdes
      from iddkdominio
     where iddkdominio.cponom  =  "atdimpsit"
       and iddkdominio.cpocod  =  d_ctc34m09.atdimpsit

    call ctc34m09_func(ws.cademp, ws.cadmat)
         returning d_ctc34m09.cadfunnom

    call ctc34m09_func(ws.atlemp, ws.atlmat)
         returning d_ctc34m09.funnom
 end if

 return d_ctc34m09.*

 end function   # ctc34m09_ler


#---------------------------------------------------------
 function ctc34m09_func(param)
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

 end function   # ctc34m09_func
