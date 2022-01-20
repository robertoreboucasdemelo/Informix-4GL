###############################################################################
# Nome do Modulo: CTB10M00                                            Marcelo #
#                                                                    Gilberto #
# Cadastro de tarifas do Porto Socorro                               Nov/1996 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 07/05/2002  PSI 15053-3  Wagner       Inclusao do novo campo tabela precos  #
#                                       para RE.                              #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"
define  wresp   char(01)

#------------------------------------------------------------
function ctb10m00_prepare()
#------------------------------------------------------------
   define l_sql char(200)
   
   let l_sql = " select first 1 funnom ",
               " from isskfunc " ,
               " where isskfunc.funmat = ? "
   prepare p_ctb10m0001 from l_sql
   declare cctb10m0001 cursor with hold for p_ctb10m0001
      
end function  # ctb10m00_prepare()

#------------------------------------------------------------
function ctb10m00()
#------------------------------------------------------------
# Menu do modulo
# --------------

   define  ctb10m00     record
           soctrfcod    like dbsktarifasocorro.soctrfcod,
           soctrfdes    like dbsktarifasocorro.soctrfdes,
           soctip       like dbsktarifasocorro.soctip,           
           soctipdes    char (20),                                 
           soctrfsitcod like dbsktarifasocorro.soctrfsitcod,
           caddat       like dbsktarifasocorro.caddat,
           cadfunnom    like isskfunc.funnom,
           atldat       like dbsktarifasocorro.atldat,
           funnom       like isskfunc.funnom
   end record

   define k_ctb10m00    record
          soctrfcod     like dbsktarifasocorro.soctrfcod
   end record
   
   call ctb10m00_prepare()

   if not get_niv_mod(g_issk.prgsgl, "ctb10m00") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   let int_flag = false

   initialize ctb10m00.*   to  null
   initialize k_ctb10m00.* to  null

   open window ctb10m00 at 4,2 with form "ctb10m00"

   menu "TARIFAS"

       before menu
          hide option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica", "Inclui", "Remove"
          end if

          show option "Encerra"

   command "Seleciona" "Pesquisa tarifa conforme criterios"
            call seleciona_ctb10m00() returning k_ctb10m00.*, ctb10m00.*
            if k_ctb10m00.soctrfcod is not null  then
               message ""
               next option "Proximo"
            else
               error " Nenhuma tarifa selecionada!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proxima tarifa selecionada"
            message ""
            if k_ctb10m00.soctrfcod is not null then
               call proximo_ctb10m00(k_ctb10m00.*)
                    returning k_ctb10m00.*, ctb10m00.*
            else
               error " Nenhuma tarifa nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra tarifa anterior selecionada"
            message ""
            if k_ctb10m00.soctrfcod is not null then
               call anterior_ctb10m00(k_ctb10m00.*)
                    returning k_ctb10m00.*, ctb10m00.*
            else
               error " Nenhuma tarifa nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica tarifa corrente selecionada"
            message ""
            if k_ctb10m00.soctrfcod is not null then
               call modifica_ctb10m00(k_ctb10m00.*, ctb10m00.*)
                    returning k_ctb10m00.*
               next option "Seleciona"
            else
               error " Nenhuma tarifa selecionada!"
               next option "Seleciona"
            end if

   command "Remove" "Remove tarifa corrente selecionada"
            message ""
            if k_ctb10m00.soctrfcod is not null then
               call remove_ctb10m00(k_ctb10m00.*)
                    returning k_ctb10m00.*
               next option "Seleciona"
            else
               error " Nenhuma tarifa selecionada!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui tarifa"
            message ""
            call inclui_ctb10m00()
            next option "Seleciona"

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctb10m00

end function  # ctb10m00


#------------------------------------------------------------
function seleciona_ctb10m00()
#------------------------------------------------------------

   define  ctb10m00     record
           soctrfcod    like dbsktarifasocorro.soctrfcod,
           soctrfdes    like dbsktarifasocorro.soctrfdes,
           soctip       like dbsktarifasocorro.soctip,           
           soctipdes    char (20),                                 
           soctrfsitcod like dbsktarifasocorro.soctrfsitcod,
           caddat       like dbsktarifasocorro.caddat,
           cadfunnom    like isskfunc.funnom,
           atldat       like dbsktarifasocorro.atldat,
           funnom       like isskfunc.funnom
   end record

   define k_ctb10m00     record
          soctrfcod      like dbsktarifasocorro.soctrfcod
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record
      
   clear form
   let int_flag = false
   initialize ws.*         to null
   initialize  ctb10m00.*  to null

   input by name k_ctb10m00.soctrfcod

      before field soctrfcod
          display by name k_ctb10m00.soctrfcod attribute (reverse)

          if k_ctb10m00.soctrfcod is null then
             let k_ctb10m00.soctrfcod = 0
          end if

      after  field soctrfcod
          display by name k_ctb10m00.soctrfcod

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctb10m00.*   to null
      initialize k_ctb10m00.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctb10m00.*, ctb10m00.*
   end if

   if k_ctb10m00.soctrfcod  =  0 then
      select min (dbsktarifasocorro.soctrfcod)
        into  k_ctb10m00.soctrfcod
        from  dbsktarifasocorro
       where  dbsktarifasocorro.soctrfcod > k_ctb10m00.soctrfcod

      display by name k_ctb10m00.soctrfcod
   end if

   select  soctrfcod   ,
           soctrfdes   ,
           soctrfsitcod,
           caddat      ,
           cadfunmat   ,
           atldat      ,
           funmat      ,
           soctip 
     into  ctb10m00.soctrfcod   ,
           ctb10m00.soctrfdes   ,
           ctb10m00.soctrfsitcod,
           ctb10m00.caddat      ,
           ws.cadfunmat         ,
           ctb10m00.atldat      ,
           ws.funmat            , 
           ctb10m00.soctip     
     from  dbsktarifasocorro
    where  dbsktarifasocorro.soctrfcod = k_ctb10m00.soctrfcod

   if sqlca.sqlcode = 0   then
            
      open cctb10m0001 using ws.funmat
      fetch cctb10m0001 into ctb10m00.cadfunnom   
      close cctb10m0001
      let ctb10m00.funnom = ctb10m00.cadfunnom
   
       case ctb10m00.soctip
          when 1  let ctb10m00.soctipdes = "PORTO SOCORRO"
          when 2  let ctb10m00.soctipdes = "CARRO-EXTRA"
          when 3  let ctb10m00.soctipdes = "RAMOS ELEMENTARES-RE"
       end case

       display by name  ctb10m00.*
   else
      error " Tarifa nao cadastrada!"
      initialize ctb10m00.*    to null
      initialize k_ctb10m00.*  to null
   end if

   return k_ctb10m00.*, ctb10m00.*

end function  # seleciona


#------------------------------------------------------------
function proximo_ctb10m00(k_ctb10m00)
#------------------------------------------------------------

   define  k_ctb10m00    record
           soctrfcod     like dbsktarifasocorro.soctrfcod
   end record

   define  ctb10m00     record
           soctrfcod    like dbsktarifasocorro.soctrfcod,
           soctrfdes    like dbsktarifasocorro.soctrfdes,
           soctip       like dbsktarifasocorro.soctip,           
           soctipdes    char (20),                                 
           soctrfsitcod like dbsktarifasocorro.soctrfsitcod,
           caddat       like dbsktarifasocorro.caddat,
           cadfunnom    like isskfunc.funnom,
           atldat       like dbsktarifasocorro.atldat,
           funnom       like isskfunc.funnom
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record


   initialize ws.*         to null
   initialize ctb10m00.*   to null

   select min (dbsktarifasocorro.soctrfcod)
     into ctb10m00.soctrfcod
     from dbsktarifasocorro
    where dbsktarifasocorro.soctrfcod > k_ctb10m00.soctrfcod

   if  ctb10m00.soctrfcod  is not null   then
       let k_ctb10m00.soctrfcod = ctb10m00.soctrfcod

       select  soctrfcod   ,
               soctrfdes   ,
               soctrfsitcod,
               caddat      ,
               cadfunmat   ,
               atldat      ,
               funmat      ,
               soctip
         into  ctb10m00.soctrfcod   ,
               ctb10m00.soctrfdes   ,
               ctb10m00.soctrfsitcod,
               ctb10m00.caddat      ,
               ws.cadfunmat         ,
               ctb10m00.atldat      ,
               ws.funmat            , 
               ctb10m00.soctip           
         from  dbsktarifasocorro
        where  dbsktarifasocorro.soctrfcod = ctb10m00.soctrfcod

       if sqlca.sqlcode = 0   then
          open cctb10m0001 using ws.funmat              
          fetch cctb10m0001 into ctb10m00.cadfunnom     
          close cctb10m0001                                              
          let ctb10m00.funnom = ctb10m00.cadfunnom      

           case ctb10m00.soctip
              when 1  let ctb10m00.soctipdes = "PORTO SOCORRO"
              when 2  let ctb10m00.soctipdes = "CARRO-EXTRA"
              when 3  let ctb10m00.soctipdes = "RAMOS ELEMENTARES-RE"
           end case

           display by name  ctb10m00.*
       else
          error " Nao ha' tarifa nesta direcao!"
          initialize ctb10m00.*    to null
          initialize k_ctb10m00.*  to null
       end if
   else
      error " Nao ha' tarifa nesta direcao!"
      initialize ctb10m00.*    to null
      initialize k_ctb10m00.*  to null
   end if

   return k_ctb10m00.*, ctb10m00.*

end function    # proximo_ctb10m00


#------------------------------------------------------------
function anterior_ctb10m00(k_ctb10m00)
#------------------------------------------------------------

   define  k_ctb10m00    record
           soctrfcod     like dbsktarifasocorro.soctrfcod
   end record

   define  ctb10m00     record
           soctrfcod    like dbsktarifasocorro.soctrfcod,
           soctrfdes    like dbsktarifasocorro.soctrfdes,
           soctip       like dbsktarifasocorro.soctip,           
           soctipdes    char (20),                                 
           soctrfsitcod like dbsktarifasocorro.soctrfsitcod,
           caddat       like dbsktarifasocorro.caddat,
           cadfunnom    like isskfunc.funnom,
           atldat       like dbsktarifasocorro.atldat,
           funnom       like isskfunc.funnom
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record


   let int_flag = false
   initialize ws.*        to null
   initialize ctb10m00.*  to null

   select max (dbsktarifasocorro.soctrfcod)
     into ctb10m00.soctrfcod
     from dbsktarifasocorro
    where dbsktarifasocorro.soctrfcod < k_ctb10m00.soctrfcod

   if  ctb10m00.soctrfcod  is  not  null  then
       let k_ctb10m00.soctrfcod = ctb10m00.soctrfcod

       select  soctrfcod   ,
               soctrfdes   ,
               soctrfsitcod,
               caddat      ,
               cadfunmat   ,
               atldat      ,
               funmat      , 
               soctip 
         into  ctb10m00.soctrfcod   ,
               ctb10m00.soctrfdes   ,
               ctb10m00.soctrfsitcod,
               ctb10m00.caddat      ,
               ws.cadfunmat         ,
               ctb10m00.atldat      ,
               ws.funmat            , 
               ctb10m00.soctip 
         from  dbsktarifasocorro
        where  dbsktarifasocorro.soctrfcod = ctb10m00.soctrfcod

       if sqlca.sqlcode = 0   then
           open cctb10m0001 using ws.funmat              
           fetch cctb10m0001 into ctb10m00.cadfunnom     
           close cctb10m0001                                              
           let ctb10m00.funnom = ctb10m00.cadfunnom 
          
           case ctb10m00.soctip
              when 1  let ctb10m00.soctipdes = "PORTO SOCORRO"
              when 2  let ctb10m00.soctipdes = "CARRO-EXTRA"
              when 3  let ctb10m00.soctipdes = "RAMOS ELEMENTARES-RE"
           end case

           display by name  ctb10m00.*
       else
          error " Nao ha' tarifa nesta direcao!"
          initialize ctb10m00.*    to null
          initialize k_ctb10m00.*  to null
       end if
   else
      error " Nao ha' tarifa nesta direcao!"
      initialize ctb10m00.*    to null
      initialize k_ctb10m00.*  to null
   end if

   return k_ctb10m00.*, ctb10m00.*

end function    # anterior_ctb10m00


#------------------------------------------------------------
function modifica_ctb10m00(k_ctb10m00, ctb10m00)
#------------------------------------------------------------
# Modifica tarifas
#

   define  k_ctb10m00    record
           soctrfcod     like dbsktarifasocorro.soctrfcod
   end record

   define  ctb10m00     record
           soctrfcod    like dbsktarifasocorro.soctrfcod,
           soctrfdes    like dbsktarifasocorro.soctrfdes,
           soctip       like dbsktarifasocorro.soctip,           
           soctipdes    char (20),                                 
           soctrfsitcod like dbsktarifasocorro.soctrfsitcod,
           caddat       like dbsktarifasocorro.caddat,
           cadfunnom    like isskfunc.funnom,
           atldat       like dbsktarifasocorro.atldat,
           funnom       like isskfunc.funnom
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record


   call input_ctb10m00("a", k_ctb10m00.* , ctb10m00.*) returning ctb10m00.*

   if int_flag  then
      let int_flag = false
      initialize ctb10m00.*  to null
      error " Operacao cancelada!"
      clear form
      return k_ctb10m00.*
   end if

   whenever error continue

   let ctb10m00.atldat = today

   begin work
      update dbsktarifasocorro set  (soctrfdes   ,
                                     soctrfsitcod,
                                     atldat      ,
                                     funmat      ,
                                     soctip 
                                    )
                               =    (ctb10m00.soctrfdes   ,
                                     ctb10m00.soctrfsitcod,
                                     ctb10m00.atldat      ,
                                     g_issk.funmat        , 
                                     ctb10m00.soctip          
                                    )
             where dbsktarifasocorro.soctrfcod  =  k_ctb10m00.soctrfcod

      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteracao da tarifa!"
         rollback work
         initialize ctb10m00.*   to null
         initialize k_ctb10m00.* to null
         return k_ctb10m00.*
      else
         error " Alteracao efetuada com sucesso!"
      end if

   commit work

   whenever error stop

   clear form
   message ""
   return k_ctb10m00.*

end function


#------------------------------------------------------------
function inclui_ctb10m00()
#------------------------------------------------------------
# Inclui tarifas
#
   define  ctb10m00     record
           soctrfcod    like dbsktarifasocorro.soctrfcod,
           soctrfdes    like dbsktarifasocorro.soctrfdes,
           soctip       like dbsktarifasocorro.soctip,           
           soctipdes    char (20),                                 
           soctrfsitcod like dbsktarifasocorro.soctrfsitcod,
           caddat       like dbsktarifasocorro.caddat,
           cadfunnom    like isskfunc.funnom,
           atldat       like dbsktarifasocorro.atldat,
           funnom       like isskfunc.funnom
   end record

   define k_ctb10m00    record
          soctrfcod        like dbsktarifasocorro.soctrfcod
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record


   clear form

   initialize ctb10m00.*   to null
   initialize k_ctb10m00.* to null
   initialize ws.*         to null

   call input_ctb10m00("i",k_ctb10m00.*, ctb10m00.*) returning ctb10m00.*

   if int_flag  then
      let int_flag = false
      initialize ctb10m00.*  to null
      error " Operacao cancelada!"
      clear form
      return
   end if

   let ctb10m00.atldat = today
   let ctb10m00.caddat = today

   declare c_ctb10m00m  cursor with hold  for
           select  max(soctrfcod)
             from  dbsktarifasocorro
            where  dbsktarifasocorro.soctrfcod > 0

   foreach c_ctb10m00m  into  ctb10m00.soctrfcod
       exit foreach
   end foreach

   if ctb10m00.soctrfcod is null   then
      let ctb10m00.soctrfcod = 0
   end if
   let ctb10m00.soctrfcod = ctb10m00.soctrfcod + 1

   whenever error continue

   begin work
      insert into dbsktarifasocorro (soctrfcod   ,
                                     soctrfdes   ,
                                     soctrfsitcod,
                                     caddat      ,
                                     cadfunmat   ,
                                     atldat      ,
                                     funmat      ,
                                     soctip           
                                    )
                            values  (ctb10m00.soctrfcod   ,
                                     ctb10m00.soctrfdes   ,
                                     ctb10m00.soctrfsitcod,
                                     ctb10m00.caddat      ,
                                     g_issk.funmat        ,
                                     ctb10m00.atldat      ,
                                     g_issk.funmat        ,
                                     ctb10m00.soctip      
                                    )

      if sqlca.sqlcode <>  0   then
         error " Erro (",sqlca.sqlcode,") na Inclusao da tarifa!"
         rollback work
         return
      end if

   commit work

   whenever error stop
   open cctb10m0001 using ws.funmat              
   fetch cctb10m0001 into ctb10m00.cadfunnom     
   close cctb10m0001                                              
   let ctb10m00.funnom = ctb10m00.cadfunnom  
   
   display by name  ctb10m00.*

   display by name ctb10m00.soctrfcod attribute (reverse)
   error " Verifique o codigo da tarifa e tecle ENTER!"
   prompt "" for char wresp
   error " Inclusao efetuada com sucesso!"

   clear form

end function


#--------------------------------------------------------------------
function input_ctb10m00(operacao_aux, k_ctb10m00, ctb10m00)
#--------------------------------------------------------------------

   define  operacao_aux  char (1)

   define  k_ctb10m00    record
           soctrfcod     like dbsktarifasocorro.soctrfcod
   end record

   define  ctb10m00     record
           soctrfcod    like dbsktarifasocorro.soctrfcod,
           soctrfdes    like dbsktarifasocorro.soctrfdes,
           soctip       like dbsktarifasocorro.soctip,           
           soctipdes    char (20),                                 
           soctrfsitcod like dbsktarifasocorro.soctrfsitcod,
           caddat       like dbsktarifasocorro.caddat,
           cadfunnom    like isskfunc.funnom,
           atldat       like dbsktarifasocorro.atldat,
           funnom       like isskfunc.funnom
   end record

   let int_flag = false

   input by name ctb10m00.soctrfcod,
                 ctb10m00.soctrfdes,
                 ctb10m00.soctip,
                 ctb10m00.soctrfsitcod  without defaults

      before field soctrfcod
             next field soctrfdes
             display by name ctb10m00.soctrfcod attribute (reverse)

      after  field soctrfcod
             display by name ctb10m00.soctrfcod

      before field soctrfdes
             display by name ctb10m00.soctrfdes attribute (reverse)

      after  field soctrfdes
             display by name ctb10m00.soctrfdes

             if ctb10m00.soctrfdes  is null   then
                error " Descricao da tarifa deve ser informada!"
                next field soctrfdes
             end if

      before field soctip
             initialize ctb10m00.soctipdes to null 
             display by name ctb10m00.soctip attribute (reverse)
             display by name ctb10m00.soctipdes

      after  field soctip
             display by name ctb10m00.soctip

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field  soctrfdes
             end if
             case ctb10m00.soctip
                when 1    let ctb10m00.soctipdes = "PORTO SOCORRO"
                when 2    let ctb10m00.soctipdes = "CARRO-EXTRA"
                when 3    let ctb10m00.soctipdes = "RAMOS ELEMENTARES-RE"
                otherwise error " Favor informar codigo de 1 a 3!"
                          next field soctip  
             end case
             display by name ctb10m00.soctipdes

      before field soctrfsitcod
             display by name ctb10m00.soctrfsitcod attribute (reverse)

      after  field soctrfsitcod
             display by name ctb10m00.soctrfsitcod

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field  soctip
             end if

             if ctb10m00.soctrfsitcod  is null   or
               (ctb10m00.soctrfsitcod  <> "A"    and
                ctb10m00.soctrfsitcod  <> "C")   then
                error " Situacao da tarifa deve ser: (A)tiva ou (C)ancelada!"
                next field soctrfsitcod
             end if

             if operacao_aux           = "i"   and
                ctb10m00.soctrfsitcod  = "C"   then
                error " Nao deve ser incluida tarifa com situacao (C)ancelada!"
                next field soctrfsitcod
             end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      initialize ctb10m00.*  to null
      return ctb10m00.*
   end if

   return ctb10m00.*

end function   # input_ctb10m00


#--------------------------------------------------------------------
function remove_ctb10m00(k_ctb10m00)
#--------------------------------------------------------------------

   define  k_ctb10m00    record
           soctrfcod     like dbsktarifasocorro.soctrfcod
   end record

   define  ctb10m00     record
           soctrfcod    like dbsktarifasocorro.soctrfcod,
           soctrfdes    like dbsktarifasocorro.soctrfdes,
           soctip       like dbsktarifasocorro.soctip,           
           soctipdes    char (20),                                 
           soctrfsitcod like dbsktarifasocorro.soctrfsitcod,
           caddat       like dbsktarifasocorro.caddat,
           cadfunnom    like isskfunc.funnom,
           atldat       like dbsktarifasocorro.atldat,
           funnom       like isskfunc.funnom
   end record

   define  ws            record
           soctrfvignum  like dbsmvigtrfsocorro.soctrfvignum
   end record


   menu "Confirma Exclusao ?"

      command "Nao" "Nao exclui a tarifa"
              clear form
              initialize ctb10m00.*   to null
              initialize k_ctb10m00.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui tarifa"
              call sel_ctb10m00(k_ctb10m00.*) returning ctb10m00.*

              if sqlca.sqlcode = notfound  then
                 initialize ctb10m00.*   to null
                 initialize k_ctb10m00.* to null
                 error " Tarifa nao localizada!"
              else

                 initialize ws.soctrfvignum  to null

                 select max (dbsmvigtrfsocorro.soctrfvignum)
                   into ws.soctrfvignum
                   from dbsmvigtrfsocorro
                  where dbsmvigtrfsocorro.soctrfcod = k_ctb10m00.soctrfcod

                 if ws.soctrfvignum  is not null     and
                    ws.soctrfvignum  > 0             then
                    error " Tarifa possui vigencia, portanto nao deve ser removida!"
                    exit menu
                 end if

                 begin work
                    delete from dbsktarifasocorro
                     where dbsktarifasocorro.soctrfcod = k_ctb10m00.soctrfcod
                 commit work

                 if sqlca.sqlcode <> 0   then
                    initialize ctb10m00.*   to null
                    initialize k_ctb10m00.* to null
                    error " Erro (",sqlca.sqlcode,") na exlusao da tarifa!"
                 else
                    initialize ctb10m00.*   to null
                    initialize k_ctb10m00.* to null
                    error   " Tarifa excluida!"
                    message ""
                    clear form
                 end if
              end if
              exit menu
   end menu

   return k_ctb10m00.*

end function    # remove_ctb10m00


#---------------------------------------------------------
function sel_ctb10m00(k_ctb10m00)
#---------------------------------------------------------

   define  k_ctb10m00    record
           soctrfcod     like dbsktarifasocorro.soctrfcod
   end record

   define  ctb10m00     record
           soctrfcod    like dbsktarifasocorro.soctrfcod,
           soctrfdes    like dbsktarifasocorro.soctrfdes,
           soctip       like dbsktarifasocorro.soctip,           
           soctipdes    char (20),                                 
           soctrfsitcod like dbsktarifasocorro.soctrfsitcod,
           caddat       like dbsktarifasocorro.caddat,
           cadfunnom    like isskfunc.funnom,
           atldat       like dbsktarifasocorro.atldat,
           funnom       like isskfunc.funnom
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record


   initialize ctb10m00.*   to null
   initialize ws.*         to null

   select  soctrfcod
     into  ctb10m00.soctrfcod
     from  dbsktarifasocorro
    where  dbsktarifasocorro.soctrfcod = k_ctb10m00.soctrfcod

   if sqlca.sqlcode = notfound   then
      error " Tarifa nao cadastrada!"
      initialize ctb10m00.*    to null
      initialize k_ctb10m00.*  to null
   end if

   return ctb10m00.*

end function   # sel_ctb10m00
