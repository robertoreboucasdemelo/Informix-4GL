###############################################################################
# Nome do Modulo: ctc33m00                                            Marcelo #
#                                                                    Gilberto #
# Cadastro de matriculas com permissao de liberacao codigo assunto   Mar/1998 #
###############################################################################
#                                                                             #
#                  * * * Alteracoes * * *                                     #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- ---------------------------------------#
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso    #
#-----------------------------------------------------------------------------#

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep smallint 

function ctc33m00_prepare() 
   
   define l_sql char(800) 
   
   let l_sql = "  select funnom              ",
               "  from isskfunc              ",
               "  where isskfunc.funmat = ?  ",
               "  and   isskfunc.empcod = 1  "
    prepare pctc33m00001 from l_sql                        
    declare cctc33m00001 cursor with hold for pctc33m00001
    
    let m_prep = true

end function 


#------------------------------------------------------------
 function ctc33m00()
#------------------------------------------------------------

 define ctc33m00      record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
    funatusnh         like datkfun.funsnh,
    funsnh            like datkfun.funsnh,
    caddat            like datkfun.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkfun.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc33m00")  then
 #   error " Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 let int_flag = false

 initialize ctc33m00.*   to  null

 open window w_ctc33m00 at 04,02 with form "ctc33m00"


 menu "MATRICULAS"

 before menu
          hide option all
          #PSI 202290
          #if g_issk.acsnivcod >= g_issk.acsnivcns  then
             show option "Seleciona", "Proximo", "Anterior"
          #end if
          #if g_issk.acsnivcod >= g_issk.acsnivatl  then
             show option "Modifica", "Remove", "Inclui"
          #end if

          show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa matricula conforme criterios"
          call ctc33m00_seleciona()  returning ctc33m00.*
          if ctc33m00.funmat  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma matricula selecionada!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proxima matricula selecionada"
          message ""
          call ctc33m00_proximo(ctc33m00.empcod, ctc33m00.funmat)
               returning ctc33m00.*

 command key ("A") "Anterior"
                   "Mostra matricula anterior selecionada"
          message ""
          if ctc33m00.funmat is not null then
             call ctc33m00_anterior(ctc33m00.empcod, ctc33m00.funmat)
                  returning ctc33m00.*
          else
             error " Nenhuma matricula nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica matricula corrente selecionada"
          message ""
          if ctc33m00.funmat  is not null then
             call ctc33m00_modifica(ctc33m00.*) returning ctc33m00.*
             next option "Seleciona"
          else
             error " Nenhuma matricula selecionada!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui matricula"
          message ""
          call ctc33m00_inclui()
          next option "Seleciona"

 command key ("R") "Remove"
                   "Remove matricula corrente selecionada"
          message ""
          if ctc33m00.funmat  is not null then
             call ctc33m00_remove(ctc33m00.*) returning ctc33m00.*
             next option "Seleciona"
          else
             error " Nenhuma matricula selecionada!"
             next option "Seleciona"
          end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 let int_flag = false
 close window w_ctc33m00

 end function  # ctc33m00


#------------------------------------------------------------
 function ctc33m00_seleciona()
#------------------------------------------------------------

 define ctc33m00      record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
    funatusnh         like datkfun.funsnh,
    funsnh            like datkfun.funsnh,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 let int_flag = false
 initialize ctc33m00.*  to null
 display by name ctc33m00.*

 input by name ctc33m00.empcod,
               ctc33m00.funmat

    before field empcod
        display by name ctc33m00.empcod attribute (reverse)

    after  field empcod
        display by name ctc33m00.empcod

        if ctc33m00.empcod  is null   then
           error " Empresa deve ser informada!"
           next field empcod
        end if

      # liberado para outras empresas, exemplo empresa 99 - 13/12/06
      # if ctc33m00.empcod  <>  1    then
      #   error " So e' permitido o cadastro de matriculas da empresa 01!"
      #    next field empcod
      # end if

        select empcod
          from gabkemp
         where gabkemp.empcod = ctc33m00.empcod

        if sqlca.sqlcode  =  notfound   then
           error " Empresa nao cadastrada!"
           next field empcod
        end if

    before field funmat
        display by name ctc33m00.funmat attribute (reverse)

    after  field funmat
        display by name ctc33m00.funmat

        select funmat
          from isskfunc
         where isskfunc.empcod = ctc33m00.empcod
           and isskfunc.funmat = ctc33m00.funmat

        if sqlca.sqlcode  =  notfound   then
           error " Matricula nao cadastrada no sistema de seguranca!"
           next field funmat
        end if

        select funmat
          from datkfun
         where datkfun.empcod = ctc33m00.empcod
           and datkfun.funmat = ctc33m00.funmat

        if sqlca.sqlcode  =  notfound   then
           error " Matricula nao cadastrada!"
           next field funmat
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc33m00.*   to null
    display by name ctc33m00.*
    error " Operacao cancelada!"
    return ctc33m00.*
 end if

 call ctc33m00_ler(ctc33m00.empcod, ctc33m00.funmat)
      returning ctc33m00.*

 if ctc33m00.funmat  is not null   then
    display by name  ctc33m00.*
 else
    error " Matricula nao cadastrada!"
    initialize ctc33m00.*    to null
 end if

 return ctc33m00.*

 end function  # ctc33m00_seleciona


#------------------------------------------------------------
 function ctc33m00_proximo(param)
#------------------------------------------------------------

 define param         record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat
 end record

 define ctc33m00      record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
    funatusnh         like datkfun.funsnh,
    funsnh            like datkfun.funsnh,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 let int_flag = false
 initialize ctc33m00.*   to null

 if param.empcod  is null   then
    let param.empcod = 1
 end if

 if param.funmat  is null   then
    let param.funmat = 0
 end if

 select min(datkfun.funmat)
   into ctc33m00.funmat
   from datkfun
  where datkfun.empcod  >=  param.empcod
    and datkfun.funmat  >   param.funmat

 if ctc33m00.funmat  is not null   then

    call ctc33m00_ler(param.empcod, ctc33m00.funmat)
         returning ctc33m00.*

    if ctc33m00.funmat  is not null   then
       display by name  ctc33m00.*
    else
       error " Nao ha' matricula nesta direcao!"
       initialize ctc33m00.*    to null
    end if
 else
    error " Nao ha' matricula nesta direcao!"
    initialize ctc33m00.*    to null
 end if

 return ctc33m00.*

 end function    # ctc33m00_proximo


#------------------------------------------------------------
 function ctc33m00_anterior(param)
#------------------------------------------------------------

 define param         record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat
 end record

 define ctc33m00      record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
    funatusnh         like datkfun.funsnh,
    funsnh            like datkfun.funsnh,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 let int_flag = false
 initialize ctc33m00.*  to null

 select max(datkfun.funmat)
   into ctc33m00.funmat
   from datkfun
  where datkfun.empcod = param.empcod
    and datkfun.funmat < param.funmat

 if ctc33m00.funmat  is not null   then

    call ctc33m00_ler(param.empcod, ctc33m00.funmat)
         returning ctc33m00.*

    if ctc33m00.funmat  is not null   then
       display by name  ctc33m00.*
    else
       error " Nao ha' matricula nesta direcao!"
       initialize ctc33m00.*    to null
    end if
 else
    error " Nao ha' matricula nesta direcao!"
    initialize ctc33m00.*    to null
 end if

 return ctc33m00.*

 end function    # ctc33m00_anterior


#------------------------------------------------------------
 function ctc33m00_modifica(ctc33m00)
#------------------------------------------------------------

 define ctc33m00      record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
    funatusnh         like datkfun.funsnh,
    funsnh            like datkfun.funsnh,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    atlfunnom         like isskfunc.funnom
 end record


 call ctc33m00_input("a", ctc33m00.*) returning ctc33m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc33m00.*  to null
    display by name ctc33m00.*
    error " Operacao cancelada!"
    return ctc33m00.*
 end if

 whenever error continue

 let ctc33m00.atldat = today

 begin work
    update datkfun set  ( funsnh,
                          atldat,
                          atlmat )
                    =   ( ctc33m00.funsnh,
                          ctc33m00.atldat,
                          g_issk.funmat )
       where datkfun.empcod  =  ctc33m00.empcod
         and datkfun.funmat  =  ctc33m00.funmat

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao da matricula!"
       rollback work
       initialize ctc33m00.*   to null
       return ctc33m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize ctc33m00.*  to null
 display by name ctc33m00.*
 message ""
 return ctc33m00.*

 end function   #  ctc33m00_modifica


#------------------------------------------------------------
 function ctc33m00_inclui()
#------------------------------------------------------------

 define ctc33m00      record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
    funatusnh         like datkfun.funsnh,
    funsnh            like datkfun.funsnh,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define  ws_resp       char(01)


 initialize ctc33m00.*   to null
 display by name ctc33m00.*

 call ctc33m00_input("i", ctc33m00.*) returning ctc33m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc33m00.*  to null
    display by name ctc33m00.*
    error " Operacao cancelada!"
    return
 end if

 let ctc33m00.atldat = today
 let ctc33m00.caddat = today

 whenever error continue

 begin work
    insert into datkfun ( empcod,
                          funmat,
                          funsnh,
                          caddat,
                          cadmat,
                          atldat,
                          atlmat )
              values
                        ( ctc33m00.empcod,
                          ctc33m00.funmat,
                          ctc33m00.funsnh,
                          ctc33m00.caddat,
                          g_issk.funmat,
                          ctc33m00.atldat,
                          g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao da matricula!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc33m00_func(g_issk.funmat)
      returning ctc33m00.cadfunnom

 call ctc33m00_func(g_issk.funmat)
      returning ctc33m00.atlfunnom

 display by name  ctc33m00.*

 display by name ctc33m00.funmat attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize ctc33m00.*  to null
 display by name ctc33m00.*

 end function   #  ctc33m00_inclui


#--------------------------------------------------------------------
 function ctc33m00_input(param, ctc33m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define ctc33m00      record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
    funatusnh         like datkfun.funsnh,
    funsnh            like datkfun.funsnh,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define ws            record
    cont              integer,
    snhdigqtd         smallint,
    funsnh            like datkfun.funsnh,
    funatusnh         like datkfun.funsnh
 end record


 let int_flag = false
 initialize ws.*   to null

 let ws.funatusnh = ctc33m00.funsnh

 input by name ctc33m00.empcod,
               ctc33m00.funmat,
               ctc33m00.funatusnh,
               ctc33m00.funsnh  without defaults

    before field empcod
            if param.operacao  =  "a"   then
               next field  funatusnh
            end if
           display by name ctc33m00.empcod attribute (reverse)

    after  field empcod
           display by name ctc33m00.empcod

           if ctc33m00.empcod  is null   then
              error " Empresa deve ser informada!"
              next field empcod
           end if

         # if ctc33m00.empcod  <>  01  then
         #    error " So e' permitido o cadastro de matriculas da empresa 01!"
         #    next field empcod
         # end if

           select empcod
             from gabkemp
            where empcod = ctc33m00.empcod

           if sqlca.sqlcode = notfound   then
              error " Empresa nao cadastrada!"
              next field empcod
           end if

    before field funmat
           display by name ctc33m00.funmat attribute (reverse)

    after  field funmat
           display by name ctc33m00.funmat

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field empcod
           end if

           if ctc33m00.funmat  is null   then
              error " Matricula deve ser informada!"
              next field funmat
           end if

           select funnom, dptsgl
             into ctc33m00.funnom, ctc33m00.dptsgl
             from isskfunc
            where empcod = ctc33m00.empcod
              and funmat = ctc33m00.funmat

           if sqlca.sqlcode = notfound   then
              error " Matricula nao cadastrada no sistema de seguranca!"
              next field funmat
           end if

           display by name ctc33m00.funnom
           display by name ctc33m00.dptsgl

           select funmat
             from datkfun
            where empcod = ctc33m00.empcod
              and funmat = ctc33m00.funmat

           if sqlca.sqlcode  =  0   then
              error " Matricula ja' cadastrada!"
              next field funmat
           end if

    before field funatusnh
           #if g_issk.acsnivcod >=  8   or
           if  param.operacao    = "i"  then
              next field funsnh
           end if

           display "Senha Atual.: " at 11,02
           display by name ctc33m00.funatusnh

    after  field funatusnh
           display by name ctc33m00.funatusnh

           if ctc33m00.funatusnh  is null   then
              error " Senha atual da matricula deve ser informada!"
              next field funatusnh
           end if

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field funatusnh
           end if

           let ws.cont = length(ctc33m00.funatusnh)
           if ws.cont  <  5   then
              error " Senha atual da matricula deve ter no minimo 5 caracteres!"
              next field funatusnh
           end if

           if ctc33m00.funatusnh <> ws.funatusnh   then
              initialize ctc33m00.funatusnh  to null
              display by name ctc33m00.funatusnh

              error " Senha atual nao confere!"
              next field funatusnh
           end if

    before field funsnh
           display by name ctc33m00.funsnh

           if ws.snhdigqtd  is null   then
              let ws.snhdigqtd = 1
           end if

    after  field funsnh
           display by name ctc33m00.funsnh

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.operacao  =  "i"   then
                 next field funmat
              else
                 next field funsnh
              end if
           end if

           if ctc33m00.funsnh  is null   then
              error " Senha da matricula deve ser informada!"
              next field funsnh
           end if

           let ws.cont = length(ctc33m00.funsnh)
           if ws.cont  <  5   then
              error " Senha da matricula deve ter no minimo 5 caracteres!"
              next field funsnh
           end if

           if ws.snhdigqtd  =  1   then
              let ws.funsnh = ctc33m00.funsnh
              initialize ctc33m00.funsnh  to null
              display by name ctc33m00.funsnh

              error " Digite a senha da matricula novamente"
              let ws.snhdigqtd = ws.snhdigqtd + 1
              next field funsnh
           else
              if ctc33m00.funsnh <> ws.funsnh   then
                 initialize ws.snhdigqtd     to null
                 initialize ctc33m00.funsnh  to null
                 display by name ctc33m00.funsnh

                 error " Senha nao confere, digite novamente!"
                 next field funsnh
              end if
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize ctc33m00.*  to null
 end if

 display "              " at 11,02
 return ctc33m00.*

 end function   # ctc33m00_input


#--------------------------------------------------------------------
 function ctc33m00_remove(ctc33m00)
#--------------------------------------------------------------------

 define ctc33m00      record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
    funatusnh         like datkfun.funsnh,
    funsnh            like datkfun.funsnh,
    caddat            like datkfun.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkfun.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define ws            record
    c24astcod         like datrastfun.c24astcod,
    confirma          char (01)
 end record


 initialize ws.*   to null


 menu "Confirma Exclusao ?"

 command "Nao" "Nao exclui a matricula"
         initialize ctc33m00.*   to null
         error " Exclusao cancelada!"
         exit menu

 command "Sim" "Exclui matricula"

         declare c_ctc33m00del  cursor for
            select c24astcod
              from datrastfun
             where datrastfun.empcod = ctc33m00.empcod
               and datrastfun.funmat = ctc33m00.funmat

         foreach c_ctc33m00del into  ws.c24astcod
            exit foreach
         end foreach

         call cts08g01("A", "N", "SERAO REMOVIDAS AUTOMATICAMENTE TODAS",
                                 "AS PERMISSOES DE LIBERACAO PARA OS",
                                 "CODIGOS DE ASSUNTOS E BLOQUEIOS",
                                 "RELACIONADOS A ESTA MATRICULA")
              returning ws.confirma

         begin work
            delete from datrastfun        #---> liberacao de assunto
             where datrastfun.empcod = ctc33m00.empcod
               and datrastfun.funmat = ctc33m00.funmat

            delete from datrfunblqlib     #---> liberacao de bloqueio
             where datrfunblqlib.empcod = ctc33m00.empcod
               and datrfunblqlib.funmat = ctc33m00.funmat

            delete from datkfun
             where datkfun.empcod = ctc33m00.empcod
               and datkfun.funmat = ctc33m00.funmat
         commit work

         if sqlca.sqlcode <> 0   then
            error " Erro (",sqlca.sqlcode,") na exlusao da matricula!"
         else
            initialize ctc33m00.*   to null
            error   " Matricula excluida!"
            message ""
         end if
         exit menu

 end menu

 display by name ctc33m00.*

 return ctc33m00.*

end function   ##-- ctc33m00_remove


#---------------------------------------------------------
 function ctc33m00_ler(param)
#---------------------------------------------------------

 define param         record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat
 end record

 define ctc33m00      record
    empcod            like datkfun.empcod,
    funmat            like datkfun.funmat,
    funnom            like isskfunc.funnom,
    dptsgl            like isskfunc.dptsgl,
    funatusnh         like datkfun.funsnh,
    funsnh            like datkfun.funsnh,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define ws            record
    atlmat            like isskfunc.funmat,
    cadmat            like isskfunc.funmat
 end record


 initialize ctc33m00.*   to null
 initialize ws.*         to null

 select  empcod,
         funmat,
         funsnh,
         caddat,
         cadmat,
         atldat,
         atlmat
   into  ctc33m00.empcod,
         ctc33m00.funmat,
         ctc33m00.funsnh,
         ctc33m00.caddat,
         ws.cadmat,
         ctc33m00.atldat,
         ws.atlmat
   from  datkfun
  where  datkfun.empcod  = param.empcod
    and  datkfun.funmat  = param.funmat

 if sqlca.sqlcode = notfound   then
    error " Matricula nao cadastrada!"
    initialize ctc33m00.*    to null
    return ctc33m00.*
 else
    select funnom, dptsgl
      into ctc33m00.funnom, ctc33m00.dptsgl
      from isskfunc
     where empcod = ctc33m00.empcod
       and funmat = ctc33m00.funmat

    call ctc33m00_func(ws.cadmat)
         returning ctc33m00.cadfunnom

    call ctc33m00_func(ws.atlmat)
         returning ctc33m00.atlfunnom
 end if

 return ctc33m00.*

 end function   # ctc33m00_ler


#---------------------------------------------------------
 function ctc33m00_func(param)
#---------------------------------------------------------

 define param         record
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null
 
 if m_prep = false or 
    m_prep = " " then 
    call ctc33m00_prepare() 
 end if    
 
 whenever error continue 
 open cctc33m00001 using param.funmat                  
 fetch cctc33m00001 into ws.funnom 
 whenever error stop 
 
 if sqlca.sqlcode <> 0 then 
    if sqlca.sqlcode = 100 then 
       error "matricula não cadastrada na isskfunc ! Avise a informatica."
    else 
       error "Erro<",sqlca.sqlcode clipped ,"> no cursor cctc33m00001 ! Avise a informatica "
    end if    
 end if       

 return ws.funnom

 end function   # ctc33m00_func
