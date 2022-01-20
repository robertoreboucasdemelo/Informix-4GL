###########################################################################
# Nome do Modulo: CTC22M00                                          Pedro #
#                                                                 Marcelo #
# Manutencao das Sucursais dos Convenios                         Nov/1995 #
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

define wresp char (01)

#------------------------------------------------------------
 function ctc22m00()
#------------------------------------------------------------
# Menu do modulo
# --------------

   define  ctc22m00     record
           cvnnum       like datkscv.cvnnum      ,
           scvsuccod    like datkscv.scvsuccod   ,
           scvsucnom    like datkscv.scvsucnom   ,
           scvendlog    like datkscv.scvendlog   ,
           scvendbrr    like datkscv.scvendbrr   ,
           scvendcid    like datkscv.scvendcid   ,
           scvufd       like datkscv.scvufd      ,
           scvendcep    like datkscv.scvendcep   ,
           scvendcepcmp like datkscv.scvendcepcmp,
           scvdddcod    like datkscv.scvdddcod   ,
           scvtelnum    like datkscv.scvtelnum   ,
           scvfaxnum    like datkscv.scvfaxnum   ,
           scvrspnom    like datkscv.scvrspnom   ,
           atldat       like datkscv.atldat      ,
           funmat       like datkscv.funmat      ,
           funnom       like isskfunc.funnom
   end record

   define k_ctc22m00    record
          cvnnum        like datkscv.cvnnum,
          scvsuccod     like datkscv.scvsuccod
   end record

   #PSI 202290
   #if not get_niv_mod(g_issk.prgsgl, "ctc22m00") then
   #   error "Modulo sem nivel de consulta e atualizacao!"
   #   return
   #end if

   let int_flag = false

   initialize ctc22m00.*   to  null
   initialize k_ctc22m00.* to  null

   open window ctc22m00 at 04,02 with form "ctc22m00"

   menu "SUCURSAIS"

       before menu
          hide option all
          #PSI 202290
          #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
          #      show option "Seleciona", "Proximo", "Anterior"
          #end if
          #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica", "Remove", "Inclui"
          #end if

          show option "Encerra"

   command "Seleciona" "Pesquisa tabela conforme criterios"
            call seleciona_ctc22m00() returning k_ctc22m00.*
            if k_ctc22m00.scvsuccod is not null  then
               message ""
               next option "Proximo"
            else
               error "Nenhum registro selecionado!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo registro selecionado"
            message ""
            if k_ctc22m00.scvsuccod is not null then
               call proximo_ctc22m00(k_ctc22m00.*)
                    returning k_ctc22m00.*
            else
               error "Nenhum registro nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra registro anterior selecionado"
            message ""
            if k_ctc22m00.scvsuccod is not null then
               call anterior_ctc22m00(k_ctc22m00.*)
                    returning k_ctc22m00.*
            else
               error "Nenhum registro nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica registro corrente selecionado"
            message ""
            if k_ctc22m00.scvsuccod is not null then
               call modifica_ctc22m00(k_ctc22m00.*)
                    returning k_ctc22m00.*
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Remove" "Remove registro corrente selecionado"
            message ""
            if k_ctc22m00.scvsuccod is not null then
               call remove_ctc22m00(k_ctc22m00.*)
                    returning k_ctc22m00.*
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui registro na tabela"
            message ""
            call inclui_ctc22m00()
            next option "Seleciona"

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc22m00

end function  # ctc22m00

#------------------------------------------------------------
 function seleciona_ctc22m00()
#------------------------------------------------------------

   define  ctc22m00     record
           cvnnum       like datkscv.cvnnum      ,
           scvsuccod    like datkscv.scvsuccod   ,
           scvsucnom    like datkscv.scvsucnom   ,
           scvendlog    like datkscv.scvendlog   ,
           scvendbrr    like datkscv.scvendbrr   ,
           scvendcid    like datkscv.scvendcid   ,
           scvufd       like datkscv.scvufd      ,
           scvendcep    like datkscv.scvendcep   ,
           scvendcepcmp like datkscv.scvendcepcmp,
           scvdddcod    like datkscv.scvdddcod   ,
           scvtelnum    like datkscv.scvtelnum   ,
           scvfaxnum    like datkscv.scvfaxnum   ,
           scvrspnom    like datkscv.scvrspnom   ,
           atldat       like datkscv.atldat      ,
           funmat       like datkscv.funmat      ,
           funnom       like isskfunc.funnom
   end record

   define k_ctc22m00    record
          cvnnum        like datkscv.cvnnum,
          scvsuccod     like datkscv.scvsuccod
   end record
   define ws_cvnnom     like datkdominio.cpodes

   clear form
   let int_flag = false

   input by name k_ctc22m00.cvnnum,
                 k_ctc22m00.scvsuccod

      before field cvnnum
          display by name k_ctc22m00.cvnnum attribute (reverse)

      after  field cvnnum
          display by name k_ctc22m00.cvnnum

          if k_ctc22m00.cvnnum  is null   then
             error "Codigo do convenio e' obrigatorio!"
             call ctn20c00()  returning  k_ctc22m00.cvnnum
             next field cvnnum
          else
             if k_ctc22m00.cvnnum = 0   then
                error "PORTO SEGURO nao e' um convenio operacional!"
                next field cvnnum
             end if

             initialize ws_cvnnom  to null

             select cpodes
               into ws_cvnnom
               from datkdominio
              where cponom = "ligcvntip"      and
                    cpocod = k_ctc22m00.cvnnum

              if sqlca.sqlcode = NOTFOUND   then
                 error "Convenio nao cadastrado !!"
                 call ctn20c00()  returning  k_ctc22m00.cvnnum
                 next field cvnnum
              else
                 select * from datkdominio
                  where cponom = "cvnnum"   and
                        cpocod = k_ctc22m00.cvnnum

                 if sqlca.sqlcode = NOTFOUND  then
                    error ws_cvnnom clipped, " nao e' um convenio operacional!"
                    call ctn20c00()  returning  k_ctc22m00.cvnnum
                    next field cvnnum
                 else
                    display ws_cvnnom to cvnnom
                 end if
              end if
          end if

      before field scvsuccod
          display by name k_ctc22m00.scvsuccod attribute (reverse)

          if k_ctc22m00.scvsuccod is null then
             let k_ctc22m00.scvsuccod = 0
          end if

      after  field scvsuccod
          display by name k_ctc22m00.scvsuccod

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctc22m00.* to null
      error "Operacao cancelada!"
      clear form
      return k_ctc22m00.*
   end if

   if k_ctc22m00.scvsuccod  =  0 then
      select min (datkscv.scvsuccod)
        into k_ctc22m00.scvsuccod
        from datkscv
       where datkscv.cvnnum    = k_ctc22m00.cvnnum  and
             datkscv.scvsuccod > 0

      display by name k_ctc22m00.scvsuccod
   end if

   select cvnnum      ,
          scvsuccod   ,
          scvsucnom   ,
          scvendlog   ,
          scvendbrr   ,
          scvendcid   ,
          scvufd      ,
          scvendcep   ,
          scvendcepcmp,
          scvdddcod   ,
          scvtelnum   ,
          scvfaxnum   ,
          scvrspnom   ,
          atldat      ,
          funmat
     into ctc22m00.cvnnum      ,
          ctc22m00.scvsuccod   ,
          ctc22m00.scvsucnom   ,
          ctc22m00.scvendlog   ,
          ctc22m00.scvendbrr   ,
          ctc22m00.scvendcid   ,
          ctc22m00.scvufd      ,
          ctc22m00.scvendcep   ,
          ctc22m00.scvendcepcmp,
          ctc22m00.scvdddcod   ,
          ctc22m00.scvtelnum   ,
          ctc22m00.scvfaxnum   ,
          ctc22m00.scvrspnom   ,
          ctc22m00.atldat      ,
          ctc22m00.funmat
     from datkscv
    where datkscv.cvnnum    = k_ctc22m00.cvnnum   and
          datkscv.scvsuccod = k_ctc22m00.scvsuccod

   if sqlca.sqlcode = 0   then
      initialize ctc22m00.funnom to null

      select funnom
        into ctc22m00.funnom
        from isskfunc
       where funmat = ctc22m00.funmat

      display by name  ctc22m00.*
   else
      error "Registro nao cadastrado!"
      initialize ctc22m00.*    to null
      initialize k_ctc22m00.*  to null
   end if

   return k_ctc22m00.*

end function  # seleciona_ctc22m00

#------------------------------------------------------------
 function proximo_ctc22m00(k_ctc22m00)
#------------------------------------------------------------

   define  ctc22m00     record
           cvnnum       like datkscv.cvnnum      ,
           scvsuccod    like datkscv.scvsuccod   ,
           scvsucnom    like datkscv.scvsucnom   ,
           scvendlog    like datkscv.scvendlog   ,
           scvendbrr    like datkscv.scvendbrr   ,
           scvendcid    like datkscv.scvendcid   ,
           scvufd       like datkscv.scvufd      ,
           scvendcep    like datkscv.scvendcep   ,
           scvendcepcmp like datkscv.scvendcepcmp,
           scvdddcod    like datkscv.scvdddcod   ,
           scvtelnum    like datkscv.scvtelnum   ,
           scvfaxnum    like datkscv.scvfaxnum   ,
           scvrspnom    like datkscv.scvrspnom   ,
           atldat       like datkscv.atldat      ,
           funmat       like datkscv.funmat      ,
           funnom       like isskfunc.funnom
   end record

   define k_ctc22m00    record
          cvnnum        like datkscv.cvnnum,
          scvsuccod     like datkscv.scvsuccod
   end record


   select min (datkscv.scvsuccod)
     into ctc22m00.scvsuccod
     from datkscv
    where datkscv.cvnnum    = k_ctc22m00.cvnnum      and
          datkscv.scvsuccod > k_ctc22m00.scvsuccod

   if ctc22m00.scvsuccod  is  not  null  then
      let k_ctc22m00.scvsuccod    = ctc22m00.scvsuccod
   end if

   select cvnnum      ,
          scvsuccod   ,
          scvsucnom   ,
          scvendlog   ,
          scvendbrr   ,
          scvendcid   ,
          scvufd      ,
          scvendcep   ,
          scvendcepcmp,
          scvdddcod   ,
          scvtelnum   ,
          scvfaxnum   ,
          scvrspnom   ,
          atldat      ,
          funmat
     into ctc22m00.cvnnum      ,
          ctc22m00.scvsuccod   ,
          ctc22m00.scvsucnom   ,
          ctc22m00.scvendlog   ,
          ctc22m00.scvendbrr   ,
          ctc22m00.scvendcid   ,
          ctc22m00.scvufd      ,
          ctc22m00.scvendcep   ,
          ctc22m00.scvendcepcmp,
          ctc22m00.scvdddcod   ,
          ctc22m00.scvtelnum   ,
          ctc22m00.scvfaxnum   ,
          ctc22m00.scvrspnom   ,
          ctc22m00.atldat      ,
          ctc22m00.funmat
     from datkscv
    where datkscv.cvnnum     =  k_ctc22m00.cvnnum  and
          datkscv.scvsuccod  =  ctc22m00.scvsuccod

   if sqlca.sqlcode = 0   then
      initialize ctc22m00.funnom to null

      select funnom
        into ctc22m00.funnom
        from isskfunc
       where funmat = ctc22m00.funmat

      display by name ctc22m00.*
   else
      error "Nao ha' mais registros nesta direcao!"
      initialize ctc22m00.*    to null
   end if

   return k_ctc22m00.*

end function    # proximo_ctc22m00

#------------------------------------------------------------
 function anterior_ctc22m00(k_ctc22m00)
#------------------------------------------------------------

   define  ctc22m00     record
           cvnnum       like datkscv.cvnnum      ,
           scvsuccod    like datkscv.scvsuccod   ,
           scvsucnom    like datkscv.scvsucnom   ,
           scvendlog    like datkscv.scvendlog   ,
           scvendbrr    like datkscv.scvendbrr   ,
           scvendcid    like datkscv.scvendcid   ,
           scvufd       like datkscv.scvufd      ,
           scvendcep    like datkscv.scvendcep   ,
           scvendcepcmp like datkscv.scvendcepcmp,
           scvdddcod    like datkscv.scvdddcod   ,
           scvtelnum    like datkscv.scvtelnum   ,
           scvfaxnum    like datkscv.scvfaxnum   ,
           scvrspnom    like datkscv.scvrspnom   ,
           atldat       like datkscv.atldat      ,
           funmat       like datkscv.funmat      ,
           funnom       like isskfunc.funnom
   end record

   define k_ctc22m00    record
          cvnnum        like datkscv.cvnnum,
          scvsuccod     like datkscv.scvsuccod
   end record


   let int_flag = false

   select max (datkscv.scvsuccod)
   into   ctc22m00.scvsuccod
   from   datkscv
   where  datkscv.cvnnum    = k_ctc22m00.cvnnum      and
          datkscv.scvsuccod < k_ctc22m00.scvsuccod

   if ctc22m00.scvsuccod  is  not  null  then
      let k_ctc22m00.scvsuccod    = ctc22m00.scvsuccod
   end if

   select cvnnum      ,
          scvsuccod   ,
          scvsucnom   ,
          scvendlog   ,
          scvendbrr   ,
          scvendcid   ,
          scvufd      ,
          scvendcep   ,
          scvendcepcmp,
          scvdddcod   ,
          scvtelnum   ,
          scvfaxnum   ,
          scvrspnom   ,
          atldat      ,
          funmat
     into ctc22m00.cvnnum      ,
          ctc22m00.scvsuccod   ,
          ctc22m00.scvsucnom   ,
          ctc22m00.scvendlog   ,
          ctc22m00.scvendbrr   ,
          ctc22m00.scvendcid   ,
          ctc22m00.scvufd      ,
          ctc22m00.scvendcep   ,
          ctc22m00.scvendcepcmp,
          ctc22m00.scvdddcod   ,
          ctc22m00.scvtelnum   ,
          ctc22m00.scvfaxnum   ,
          ctc22m00.scvrspnom   ,
          ctc22m00.atldat      ,
          ctc22m00.funmat
     from datkscv
    where datkscv.cvnnum     =  k_ctc22m00.cvnnum  and
          datkscv.scvsuccod  =  ctc22m00.scvsuccod

   if sqlca.sqlcode = 0   then
      initialize ctc22m00.funnom to null

      select funnom
        into ctc22m00.funnom
        from isskfunc
       where funmat = ctc22m00.funmat

      display by name  ctc22m00.*
   else
      error "Nao ha' mais registros nesta direcao!"
      initialize ctc22m00.*    to null
   end if

   return k_ctc22m00.*

end function    # anterior_ctc22m00

#------------------------------------------------------------
 function modifica_ctc22m00(k_ctc22m00)
#------------------------------------------------------------

   define  ctc22m00     record
           cvnnum       like datkscv.cvnnum      ,
           scvsuccod    like datkscv.scvsuccod   ,
           scvsucnom    like datkscv.scvsucnom   ,
           scvendlog    like datkscv.scvendlog   ,
           scvendbrr    like datkscv.scvendbrr   ,
           scvendcid    like datkscv.scvendcid   ,
           scvufd       like datkscv.scvufd      ,
           scvendcep    like datkscv.scvendcep   ,
           scvendcepcmp like datkscv.scvendcepcmp,
           scvdddcod    like datkscv.scvdddcod   ,
           scvtelnum    like datkscv.scvtelnum   ,
           scvfaxnum    like datkscv.scvfaxnum   ,
           scvrspnom    like datkscv.scvrspnom   ,
           atldat       like datkscv.atldat      ,
           funmat       like datkscv.funmat      ,
           funnom       like isskfunc.funnom
   end record

   define k_ctc22m00    record
          cvnnum        like datkscv.cvnnum,
          scvsuccod     like datkscv.scvsuccod
   end record

   select cvnnum      ,
          scvsuccod   ,
          scvsucnom   ,
          scvendlog   ,
          scvendbrr   ,
          scvendcid   ,
          scvufd      ,
          scvendcep   ,
          scvendcepcmp,
          scvdddcod   ,
          scvtelnum   ,
          scvfaxnum   ,
          scvrspnom   ,
          atldat      ,
          funmat
     into ctc22m00.cvnnum      ,
          ctc22m00.scvsuccod   ,
          ctc22m00.scvsucnom   ,
          ctc22m00.scvendlog   ,
          ctc22m00.scvendbrr   ,
          ctc22m00.scvendcid   ,
          ctc22m00.scvufd      ,
          ctc22m00.scvendcep   ,
          ctc22m00.scvendcepcmp,
          ctc22m00.scvdddcod   ,
          ctc22m00.scvtelnum   ,
          ctc22m00.scvfaxnum   ,
          ctc22m00.scvrspnom   ,
          ctc22m00.atldat      ,
          ctc22m00.funmat
     from datkscv
    where datkscv.cvnnum     =  k_ctc22m00.cvnnum  and
          datkscv.scvsuccod  =  k_ctc22m00.scvsuccod

   call input_ctc22m00("a", k_ctc22m00.* , ctc22m00.*) returning ctc22m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc22m00.*  to null
      error "Operacao cancelada!"
      clear form
      return k_ctc22m00.*
   end if

   whenever error continue

   let ctc22m00.atldat = today

   BEGIN WORK
      update datkscv set ( scvsucnom   ,
                           scvendlog   ,
                           scvendbrr   ,
                           scvendcid   ,
                           scvufd      ,
                           scvendcep   ,
                           scvendcepcmp,
                           scvdddcod   ,
                           scvtelnum   ,
                           scvfaxnum   ,
                           scvrspnom   ,
                           atldat      ,
                           funmat      )
                       = ( ctc22m00.scvsucnom   ,
                           ctc22m00.scvendlog   ,
                           ctc22m00.scvendbrr   ,
                           ctc22m00.scvendcid   ,
                           ctc22m00.scvufd      ,
                           ctc22m00.scvendcep   ,
                           ctc22m00.scvendcepcmp,
                           ctc22m00.scvdddcod   ,
                           ctc22m00.scvtelnum   ,
                           ctc22m00.scvfaxnum   ,
                           ctc22m00.scvrspnom   ,
                           ctc22m00.atldat      ,
                           g_issk.funmat        )
                    where  datkscv.cvnnum      =   k_ctc22m00.cvnnum     and
                           datkscv.scvsuccod   =   k_ctc22m00.scvsuccod

   if sqlca.sqlcode <>  0  then
      error "Erro (", sqlca.sqlcode, ") na alteracao dos dados da sucursal. ",
            "AVISE A INFORMATICA!"
      rollback work
      initialize ctc22m00.*   to null
      initialize k_ctc22m00.* to null
      return k_ctc22m00.*
   else
      error "Alteracao efetuada com sucesso!"
   end if

   whenever error stop

   COMMIT WORK

   clear form
   message ""

   return k_ctc22m00.*

end function  # modifica_ctc22m00

#--------------------------------------------------------------------
 function remove_ctc22m00(k_ctc22m00)
#--------------------------------------------------------------------

   define  ctc22m00     record
           cvnnum       like datkscv.cvnnum      ,
           scvsuccod    like datkscv.scvsuccod   ,
           scvsucnom    like datkscv.scvsucnom   ,
           scvendlog    like datkscv.scvendlog   ,
           scvendbrr    like datkscv.scvendbrr   ,
           scvendcid    like datkscv.scvendcid   ,
           scvufd       like datkscv.scvufd      ,
           scvendcep    like datkscv.scvendcep   ,
           scvendcepcmp like datkscv.scvendcepcmp,
           scvdddcod    like datkscv.scvdddcod   ,
           scvtelnum    like datkscv.scvtelnum   ,
           scvfaxnum    like datkscv.scvfaxnum   ,
           scvrspnom    like datkscv.scvrspnom   ,
           atldat       like datkscv.atldat      ,
           funmat       like datkscv.funmat      ,
           funnom       like isskfunc.funnom
   end record

   define k_ctc22m00    record
          cvnnum        like datkscv.cvnnum,
          scvsuccod     like datkscv.scvsuccod
   end record


   menu "Confirma Exclusao ?"

      command "Nao" "Cancela exclusao do registro."
              clear form
              initialize ctc22m00.*   to null
              initialize k_ctc22m00.* to null
              error "Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui registro"
              call sel_ctc22m00(k_ctc22m00.*) returning ctc22m00.*

              if sqlca.sqlcode = NOTFOUND  then
                 initialize ctc22m00.*   to null
                 initialize k_ctc22m00.* to null
                 error "Registro nao localizado!"
              else
                 BEGIN WORK
                    delete from datkscv
                     where datkscv.cvnnum    = k_ctc22m00.cvnnum     and
                           datkscv.scvsuccod = k_ctc22m00.scvsuccod
                 COMMIT WORK
                 initialize ctc22m00.*   to null
                 initialize k_ctc22m00.* to null
                 error   "Registro excluido!"
                 message ""
                 clear form
              end if
              exit menu
   end menu

   return k_ctc22m00.*

end function    # remove_ctc22m00

#------------------------------------------------------------
 function inclui_ctc22m00()
#------------------------------------------------------------

   define  ctc22m00     record
           cvnnum       like datkscv.cvnnum      ,
           scvsuccod    like datkscv.scvsuccod   ,
           scvsucnom    like datkscv.scvsucnom   ,
           scvendlog    like datkscv.scvendlog   ,
           scvendbrr    like datkscv.scvendbrr   ,
           scvendcid    like datkscv.scvendcid   ,
           scvufd       like datkscv.scvufd      ,
           scvendcep    like datkscv.scvendcep   ,
           scvendcepcmp like datkscv.scvendcepcmp,
           scvdddcod    like datkscv.scvdddcod   ,
           scvtelnum    like datkscv.scvtelnum   ,
           scvfaxnum    like datkscv.scvfaxnum   ,
           scvrspnom    like datkscv.scvrspnom   ,
           atldat       like datkscv.atldat      ,
           funmat       like datkscv.funmat      ,
           funnom       like isskfunc.funnom
   end record

   define k_ctc22m00    record
          cvnnum        like datkscv.cvnnum,
          scvsuccod     like datkscv.scvsuccod
   end record

   clear form

   initialize ctc22m00.*   to null
   initialize k_ctc22m00.* to null

   call input_ctc22m00("i",k_ctc22m00.*, ctc22m00.*) returning ctc22m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc22m00.*  to null
      error "Operacao cancelada!"
      clear form
      return
   end if

   whenever error continue

   let k_ctc22m00.cvnnum = ctc22m00.cvnnum
   let ctc22m00.atldat   = today

   select max(scvsuccod)
     into k_ctc22m00.scvsuccod
     from datkscv
    where cvnnum  =  ctc22m00.cvnnum

   if k_ctc22m00.scvsuccod  is null    then
      let k_ctc22m00.scvsuccod = 0
   end if

   let k_ctc22m00.scvsuccod = k_ctc22m00.scvsuccod + 1
   let ctc22m00.scvsuccod   = k_ctc22m00.scvsuccod

   BEGIN WORK
      insert into datkscv ( cvnnum      ,
                            scvsuccod   ,
                            scvsucnom   ,
                            scvendlog   ,
                            scvendbrr   ,
                            scvendcid   ,
                            scvufd      ,
                            scvendcep   ,
                            scvendcepcmp,
                            scvdddcod   ,
                            scvtelnum   ,
                            scvfaxnum   ,
                            scvrspnom   ,
                            atldat      ,
                            funmat      )
                  values  ( ctc22m00.cvnnum      ,
                            ctc22m00.scvsuccod   ,
                            ctc22m00.scvsucnom   ,
                            ctc22m00.scvendlog   ,
                            ctc22m00.scvendbrr   ,
                            ctc22m00.scvendcid   ,
                            ctc22m00.scvufd      ,
                            ctc22m00.scvendcep   ,
                            ctc22m00.scvendcepcmp,
                            ctc22m00.scvdddcod   ,
                            ctc22m00.scvtelnum   ,
                            ctc22m00.scvfaxnum   ,
                            ctc22m00.scvrspnom   ,
                            ctc22m00.atldat      ,
                            g_issk.funmat        )

      if sqlca.sqlcode <>  0  then
         error "Erro (", sqlca.sqlcode, ") na gravacao da sucursal. AVISE A INFORMATICA!"
         rollback work
         return
      end if

      whenever error stop

    COMMIT WORK

    display by name ctc22m00.scvsuccod attribute (reverse)
    error "Verifique o codigo do registro e tecle ENTER!"
    prompt "" for char wresp
    error "Inclusao efetuada com sucesso!"

    clear form

end function

#--------------------------------------------------------------------
 function input_ctc22m00(operacao_aux, k_ctc22m00, ctc22m00)
#--------------------------------------------------------------------

   define  ctc22m00     record
           cvnnum       like datkscv.cvnnum      ,
           scvsuccod    like datkscv.scvsuccod   ,
           scvsucnom    like datkscv.scvsucnom   ,
           scvendlog    like datkscv.scvendlog   ,
           scvendbrr    like datkscv.scvendbrr   ,
           scvendcid    like datkscv.scvendcid   ,
           scvufd       like datkscv.scvufd      ,
           scvendcep    like datkscv.scvendcep   ,
           scvendcepcmp like datkscv.scvendcepcmp,
           scvdddcod    like datkscv.scvdddcod   ,
           scvtelnum    like datkscv.scvtelnum   ,
           scvfaxnum    like datkscv.scvfaxnum   ,
           scvrspnom    like datkscv.scvrspnom   ,
           atldat       like datkscv.atldat      ,
           funmat       like datkscv.funmat      ,
           funnom       like isskfunc.funnom
   end record

   define k_ctc22m00    record
          cvnnum        like datkscv.cvnnum,
          scvsuccod     like datkscv.scvsuccod
   end record

   define operacao_aux  char (1)
   define w_contador    decimal(6,0)
   define w_retlgd      char(40)
   define ws_cvnnom     like iddkdominio.cpodes

   let int_flag = false

   input by name
            ctc22m00.cvnnum,
            ctc22m00.scvsuccod,
            ctc22m00.scvsucnom,
            ctc22m00.scvendlog,
            ctc22m00.scvendbrr,
            ctc22m00.scvendcid,
            ctc22m00.scvufd,
            ctc22m00.scvendcep,
            ctc22m00.scvendcepcmp,
            ctc22m00.scvdddcod,
            ctc22m00.scvtelnum,
            ctc22m00.scvfaxnum,
            ctc22m00.scvrspnom
   without defaults

   before field cvnnum
          if  operacao_aux  =  "a"  then
              next field scvsucnom
          end if
          display by name ctc22m00.cvnnum attribute (reverse)

   after  field cvnnum
          display by name ctc22m00.cvnnum

          if ctc22m00.cvnnum   is null   then
             call ctn20c00()  returning  ctc22m00.cvnnum
             error "Codigo do convenio deve ser informado !!"
             next field cvnnum
          else
             if ctc22m00.cvnnum = 0   then
                error "PORTO SEGURO nao e' um convenio operacional!"
                next field cvnnum
             end if

             initialize ws_cvnnom  to null

             select cpodes
               into ws_cvnnom
               from datkdominio
              where cponom = "ligcvntip"      and
                    cpocod = ctc22m00.cvnnum

              if sqlca.sqlcode = NOTFOUND   then
                 error "Convenio nao cadastrado !!"
                 call ctn20c00()  returning  ctc22m00.cvnnum
                 next field cvnnum
              else
                 select * from datkdominio
                  where cponom = "cvnnum"   and
                        cpocod = ctc22m00.cvnnum

                 if sqlca.sqlcode = NOTFOUND  then
                    error ws_cvnnom clipped, " nao e' um convenio operacional!"
                    call ctn20c00()  returning  ctc22m00.cvnnum
                    next field cvnnum
                 else
                    display ws_cvnnom to cvnnom
                 end if
              end if
          end if

          next field scvsucnom

   before field scvsucnom
          display by name ctc22m00.scvsucnom attribute (reverse)

   after  field scvsucnom
          display by name ctc22m00.scvsucnom

   before field scvendlog
          display by name ctc22m00.scvendlog attribute (reverse)

   after  field scvendlog
          display by name ctc22m00.scvendlog

   before field scvendbrr
          display by name ctc22m00.scvendbrr attribute (reverse)

   after  field scvendbrr
          display by name ctc22m00.scvendbrr

   before field scvendcid
          display by name ctc22m00.scvendcid attribute (reverse)

   after  field scvendcid
          display by name ctc22m00.scvendcid

   before field scvufd
          display by name ctc22m00.scvufd attribute (reverse)

   after  field scvufd
          display by name ctc22m00.scvufd

          if fgl_lastkey() <> fgl_keyval ("up")    and
             fgl_lastkey() <> fgl_keyval ("left")  then
             select ufdcod
               from glakest
              where glakest.ufdcod = ctc22m00.scvufd

               if sqlca.sqlcode = NOTFOUND  then
                  error "Unidade Federativa nao cadastrada!"
                  next field scvufd
               end if
          end if

   before field scvendcep
          display by name ctc22m00.scvendcep attribute (reverse)

   after  field scvendcep
          display by name ctc22m00.scvendcep
          if fgl_lastkey()    <>     fgl_keyval("up")   and
             fgl_lastkey()    <>     fgl_keyval("left") then

             let w_contador   =      0

             select count(*)
               into w_contador
               from glakcid
              where glakcid.cidcep  =  ctc22m00.scvendcep

             if w_contador  =  0  then
                let w_contador = 0

                select count(*)
                  into w_contador
                  from glaklgd
                 where glaklgd.lgdcep  =  ctc22m00.scvendcep

                if w_contador =  0  then

                   call  C24GERAL_TRATSTR(ctc22m00.scvendlog, 40)
                                          returning  w_retlgd

                   error "CEP nao cadastrado! Consulte pelo logradouro!"

                   call  ctn11c02(ctc22m00.scvufd,ctc22m00.scvendcid,w_retlgd)
                                          returning ctc22m00.scvendcep,
                                                    ctc22m00.scvendcepcmp

                   if ctc22m00.scvendcep is null then
                      error "Consulte CEP por cidade!"
                      call  ctn11c03(ctc22m00.scvendcid)
                                             returning ctc22m00.scvendcep
                   end if

                   next  field scvendcep
                end if
             end if
          end if

   before field scvendcepcmp
          display by name ctc22m00.scvendcepcmp attribute (reverse)

   after  field scvendcepcmp
          display by name ctc22m00.scvendcepcmp

   before field scvdddcod
          display by name ctc22m00.scvdddcod attribute (reverse)

   after  field scvdddcod
          display by name ctc22m00.scvdddcod

   before field scvtelnum
          display by name ctc22m00.scvtelnum attribute (reverse)

   after  field scvtelnum
          display by name ctc22m00.scvtelnum

   before field scvfaxnum
          display by name ctc22m00.scvfaxnum attribute (reverse)

   after  field scvfaxnum
          display by name ctc22m00.scvfaxnum

   before field scvrspnom
          display by name ctc22m00.scvrspnom attribute (reverse)

   after  field scvrspnom
          display by name ctc22m00.scvrspnom

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctc22m00.*  to null
      return ctc22m00.*
   end if

   return ctc22m00.*

end function   # input_ctc22m00

#---------------------------------------------------------
 function sel_ctc22m00(k_ctc22m00)
#---------------------------------------------------------

   define  ctc22m00     record
           cvnnum       like datkscv.cvnnum      ,
           scvsuccod    like datkscv.scvsuccod   ,
           scvsucnom    like datkscv.scvsucnom   ,
           scvendlog    like datkscv.scvendlog   ,
           scvendbrr    like datkscv.scvendbrr   ,
           scvendcid    like datkscv.scvendcid   ,
           scvufd       like datkscv.scvufd      ,
           scvendcep    like datkscv.scvendcep   ,
           scvendcepcmp like datkscv.scvendcepcmp,
           scvdddcod    like datkscv.scvdddcod   ,
           scvtelnum    like datkscv.scvtelnum   ,
           scvfaxnum    like datkscv.scvfaxnum   ,
           scvrspnom    like datkscv.scvrspnom   ,
           atldat       like datkscv.atldat      ,
           funmat       like datkscv.funmat      ,
           funnom       like isskfunc.funnom
   end record

   define k_ctc22m00  record
          cvnnum      like datkscv.cvnnum,
          scvsuccod   like datkscv.scvsuccod
   end record

   select cvnnum      ,
          scvsuccod   ,
          scvsucnom   ,
          scvendlog   ,
          scvendbrr   ,
          scvendcid   ,
          scvufd      ,
          scvendcep   ,
          scvendcepcmp,
          scvdddcod   ,
          scvtelnum   ,
          scvfaxnum   ,
          scvrspnom   ,
          atldat      ,
          funmat
     into ctc22m00.cvnnum      ,
          ctc22m00.scvsuccod   ,
          ctc22m00.scvsucnom   ,
          ctc22m00.scvendlog   ,
          ctc22m00.scvendbrr   ,
          ctc22m00.scvendcid   ,
          ctc22m00.scvufd      ,
          ctc22m00.scvendcep   ,
          ctc22m00.scvendcepcmp,
          ctc22m00.scvdddcod   ,
          ctc22m00.scvtelnum   ,
          ctc22m00.scvfaxnum   ,
          ctc22m00.scvrspnom   ,
          ctc22m00.atldat      ,
          ctc22m00.funmat
     from datkscv
    where datkscv.cvnnum    = k_ctc22m00.cvnnum    and
          datkscv.scvsuccod = k_ctc22m00.scvsuccod

   return ctc22m00.*

end function   # sel_ctc22m00
