###########################################################################
# Nome do Modulo: CTB10M01                                        Marcelo #
#                                                                Gilberto #
# Cadastro de custos dos prestadores                             Nov/1996 #
###########################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"
define  wresp   char(01)

#-------------------------------------------------------------
function ctb10m01()
#-------------------------------------------------------------
# Menu do modulo
# --------------

   define  ctb10m01         record
           soccstcod        like dbskcustosocorro.soccstcod,
           soccstdes        like dbskcustosocorro.soccstdes,
           soccstclccod     like dbskcustosocorro.soccstclccod,
           soccstclcdes     char(20),
           soccstexbseq     like dbskcustosocorro.soccstexbseq,
           soctip           like dbskcustosocorro.soctip,       
           soctipdes        char (25),
           soccstsitcod     like dbskcustosocorro.soccstsitcod,
           caddat           like dbskcustosocorro.caddat,
           cadfunnom        like isskfunc.funnom,
           atldat           like dbskcustosocorro.atldat,
           funnom           like isskfunc.funnom
   end record

   define k_ctb10m01        record
          soccstcod         like dbskcustosocorro.soccstcod
   end record


   if not get_niv_mod(g_issk.prgsgl, "ctb10m01") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   let int_flag = false

   initialize ctb10m01.*   to  null
   initialize k_ctb10m01.* to  null

   open window ctb10m01 at 4,2 with form "ctb10m01"

   menu "CUSTO_PRS"

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

   command "Seleciona" "Pesquisa custo conforme criterios"
            call seleciona_ctb10m01() returning k_ctb10m01.*, ctb10m01.*
            if k_ctb10m01.soccstcod is not null  then
               message ""
               next option "Proximo"
            else
               error " Nenhum custo selecionado!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo custo selecionado"
            message ""
            if k_ctb10m01.soccstcod is not null then
               call proximo_ctb10m01(k_ctb10m01.*)
                    returning k_ctb10m01.*, ctb10m01.*
            else
               error " Nenhum custo nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra custo anterior selecionado"
            message ""
            if k_ctb10m01.soccstcod is not null then
               call anterior_ctb10m01(k_ctb10m01.*)
                    returning k_ctb10m01.*, ctb10m01.*
            else
               error " Nenhum custo nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica custo corrente selecionado"
            message ""
            if k_ctb10m01.soccstcod is not null then
               call modifica_ctb10m01(k_ctb10m01.*, ctb10m01.*)
                    returning k_ctb10m01.*
               next option "Seleciona"
            else
               error " Nenhum custo selecionado!"
               next option "Seleciona"
            end if

   command "Remove" "Remove custo corrente selecionado"
            message ""
            if k_ctb10m01.soccstcod is not null then
               call remove_ctb10m01(k_ctb10m01.*)
                    returning k_ctb10m01.*
               next option "Seleciona"
            else
               error " Nenhum custo selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui custo"
            message ""
            call inclui_ctb10m01()
            next option "Seleciona"

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctb10m01

end function  # ctb10m01


#------------------------------------------------------------
function seleciona_ctb10m01()
#------------------------------------------------------------

   define  ctb10m01         record
           soccstcod        like dbskcustosocorro.soccstcod,
           soccstdes        like dbskcustosocorro.soccstdes,
           soccstclccod     like dbskcustosocorro.soccstclccod,
           soccstclcdes     char(20),
           soccstexbseq     like dbskcustosocorro.soccstexbseq,
           soctip           like dbskcustosocorro.soctip,       
           soctipdes        char (25),
           soccstsitcod     like dbskcustosocorro.soccstsitcod,
           caddat           like dbskcustosocorro.caddat,
           cadfunnom        like isskfunc.funnom,
           atldat           like dbskcustosocorro.atldat,
           funnom           like isskfunc.funnom
   end record

   define k_ctb10m01        record
          soccstcod         like dbskcustosocorro.soccstcod
   end record

   define ws             record
          funmat         like isskfunc.funmat,
          cadfunmat      like isskfunc.funmat
   end record


   clear form
   let int_flag = false
   initialize ws.*         to null
   initialize  ctb10m01.*  to null

   input by name k_ctb10m01.soccstcod

      before field soccstcod
          display by name k_ctb10m01.soccstcod attribute (reverse)

          if k_ctb10m01.soccstcod is null then
             let k_ctb10m01.soccstcod = 0
          end if

      after  field soccstcod
          display by name k_ctb10m01.soccstcod

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctb10m01.*   to null
      initialize k_ctb10m01.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctb10m01.*, ctb10m01.*
   end if

   if k_ctb10m01.soccstcod  =  0 then
      select min (dbskcustosocorro.soccstcod)
        into  k_ctb10m01.soccstcod
        from  dbskcustosocorro
       where  dbskcustosocorro.soccstcod > k_ctb10m01.soccstcod

      display by name k_ctb10m01.soccstcod
   end if

   select  soccstcod   ,
           soccstdes   ,
           soccstclccod,
           soccstexbseq,
           soccstsitcod,
           soctip      ,            
           caddat      ,
           cadfunmat   ,
           atldat      ,
           funmat
     into  ctb10m01.soccstcod   ,
           ctb10m01.soccstdes   ,
           ctb10m01.soccstclccod,
           ctb10m01.soccstexbseq,
           ctb10m01.soccstsitcod,
           ctb10m01.soctip      , 
           ctb10m01.caddat      ,
           ws.cadfunmat         ,
           ctb10m01.atldat      ,
           ws.funmat
     from  dbskcustosocorro
    where  dbskcustosocorro.soccstcod = k_ctb10m01.soccstcod

   if sqlca.sqlcode = 0   then
      case ctb10m01.soccstclccod
           when  1 let ctb10m01.soccstclcdes = "VALOR FIXO"
           when  2 let ctb10m01.soccstclcdes = "VARIAVEL EM HORAS"
           when  3 let ctb10m01.soccstclcdes = "VARIAVEL EM KM"
      end case

      case ctb10m01.soctip   
           when  1 let ctb10m01.soctipdes = "SERVICOS PORTO SOCORRO"
           when  2 let ctb10m01.soctipdes = "SERVICOS CARRO-EXTRA" 
           when  3 let ctb10m01.soctipdes = "SERVICOS RESIDENCIA"  
      end case

      select funnom
        into ctb10m01.cadfunnom
        from isskfunc
       where isskfunc.funmat = ws.cadfunmat

      select funnom
        into ctb10m01.funnom
        from isskfunc
       where isskfunc.funmat = ws.funmat

       display by name  ctb10m01.*
   else
      error " Custo nao cadastrado!"
      initialize ctb10m01.*    to null
      initialize k_ctb10m01.*  to null
   end if

   return k_ctb10m01.*, ctb10m01.*

end function  # seleciona


#------------------------------------------------------------
function proximo_ctb10m01(k_ctb10m01)
#------------------------------------------------------------

   define  k_ctb10m01       record
           soccstcod        like dbskcustosocorro.soccstcod
   end record

   define  ctb10m01         record
           soccstcod        like dbskcustosocorro.soccstcod,
           soccstdes        like dbskcustosocorro.soccstdes,
           soccstclccod     like dbskcustosocorro.soccstclccod,
           soccstclcdes     char(20),
           soccstexbseq     like dbskcustosocorro.soccstexbseq,
           soctip           like dbskcustosocorro.soctip,       
           soctipdes        char (25),
           soccstsitcod     like dbskcustosocorro.soccstsitcod,
           caddat           like dbskcustosocorro.caddat,
           cadfunnom        like isskfunc.funnom,
           atldat           like dbskcustosocorro.atldat,
           funnom           like isskfunc.funnom
   end record

   define ws                record
          funmat            like isskfunc.funmat,
          cadfunmat         like isskfunc.funmat
   end record


   initialize ws.*         to null
   initialize ctb10m01.*   to null

   select min (dbskcustosocorro.soccstcod)
     into ctb10m01.soccstcod
     from dbskcustosocorro
    where dbskcustosocorro.soccstcod > k_ctb10m01.soccstcod

   if  ctb10m01.soccstcod  is not null   then
       let k_ctb10m01.soccstcod = ctb10m01.soccstcod

       select  soccstcod   ,
               soccstdes   ,
               soccstclccod,
               soccstexbseq,
               soccstsitcod,
               soctip      ,            
               caddat      ,
               cadfunmat   ,
               atldat      ,
               funmat
         into  ctb10m01.soccstcod   ,
               ctb10m01.soccstdes   ,
               ctb10m01.soccstclccod,
               ctb10m01.soccstexbseq,
               ctb10m01.soccstsitcod,
               ctb10m01.soctip      ,
               ctb10m01.caddat      ,
               ws.cadfunmat         ,
               ctb10m01.atldat      ,
               ws.funmat
         from  dbskcustosocorro
        where  dbskcustosocorro.soccstcod = k_ctb10m01.soccstcod

       if sqlca.sqlcode = 0   then
          case ctb10m01.soccstclccod
               when  1 let ctb10m01.soccstclcdes = "VALOR FIXO"
               when  2 let ctb10m01.soccstclcdes = "VARIAVEL EM HORAS"
               when  3 let ctb10m01.soccstclcdes = "VARIAVEL EM KM"
          end case

          case ctb10m01.soctip   
               when  1 let ctb10m01.soctipdes = "SERVICOS PORTO SOCORRO"
               when  2 let ctb10m01.soctipdes = "SERVICOS CARRO-EXTRA" 
               when  3 let ctb10m01.soctipdes = "SERVICOS RESIDENCIA"  
          end case

          select funnom
            into ctb10m01.cadfunnom
            from isskfunc
           where isskfunc.funmat = ws.cadfunmat

          select funnom
            into ctb10m01.funnom
            from isskfunc
           where isskfunc.funmat = ws.funmat

           display by name  ctb10m01.*
       else
          error " Nao ha' custo nesta direcao!"
          initialize ctb10m01.*    to null
          initialize k_ctb10m01.*  to null
       end if
   else
      error " Nao ha' custo nesta direcao!"
      initialize ctb10m01.*    to null
      initialize k_ctb10m01.*  to null
   end if

   return k_ctb10m01.*, ctb10m01.*

end function    # proximo_ctb10m01


#------------------------------------------------------------
function anterior_ctb10m01(k_ctb10m01)
#------------------------------------------------------------

   define  k_ctb10m01       record
           soccstcod        like dbskcustosocorro.soccstcod
   end record

   define  ctb10m01         record
           soccstcod        like dbskcustosocorro.soccstcod,
           soccstdes        like dbskcustosocorro.soccstdes,
           soccstclccod     like dbskcustosocorro.soccstclccod,
           soccstclcdes     char(20),
           soccstexbseq     like dbskcustosocorro.soccstexbseq,
           soctip           like dbskcustosocorro.soctip,       
           soctipdes        char (25),
           soccstsitcod     like dbskcustosocorro.soccstsitcod,
           caddat           like dbskcustosocorro.caddat,
           cadfunnom        like isskfunc.funnom,
           atldat           like dbskcustosocorro.atldat,
           funnom           like isskfunc.funnom
   end record

   define ws                record
          funmat            like isskfunc.funmat,
          cadfunmat         like isskfunc.funmat
   end record


   let int_flag = false
   initialize ws.*        to null
   initialize ctb10m01.*  to null

   select max (dbskcustosocorro.soccstcod)
     into ctb10m01.soccstcod
     from dbskcustosocorro
    where dbskcustosocorro.soccstcod < k_ctb10m01.soccstcod

   if  ctb10m01.soccstcod  is  not  null  then
       let k_ctb10m01.soccstcod = ctb10m01.soccstcod

       select  soccstcod   ,
               soccstdes   ,
               soccstclccod,
               soccstexbseq,
               soccstsitcod,
               soctip      ,
               caddat      ,
               cadfunmat   ,
               atldat      ,
               funmat
         into  ctb10m01.soccstcod   ,
               ctb10m01.soccstdes   ,
               ctb10m01.soccstclccod,
               ctb10m01.soccstexbseq,
               ctb10m01.soccstsitcod,
               ctb10m01.soctip      ,
               ctb10m01.caddat      ,
               ws.cadfunmat         ,
               ctb10m01.atldat      ,
               ws.funmat
         from  dbskcustosocorro
        where  dbskcustosocorro.soccstcod = k_ctb10m01.soccstcod

       if sqlca.sqlcode = 0   then
          case ctb10m01.soccstclccod
               when  1 let ctb10m01.soccstclcdes = "VALOR FIXO"
               when  2 let ctb10m01.soccstclcdes = "VARIAVEL EM HORAS"
               when  3 let ctb10m01.soccstclcdes = "VARIAVEL EM KM"
          end case
 
          case ctb10m01.soctip   
               when  1 let ctb10m01.soctipdes = "SERVICOS PORTO SOCORRO"
               when  2 let ctb10m01.soctipdes = "SERVICOS CARRO-EXTRA" 
               when  3 let ctb10m01.soctipdes = "SERVICOS RESIDENCIA"  
          end case

          select funnom
            into ctb10m01.cadfunnom
            from isskfunc
           where isskfunc.funmat = ws.cadfunmat

          select funnom
            into ctb10m01.funnom
            from isskfunc
           where isskfunc.funmat = ws.funmat

           display by name  ctb10m01.*
       else
          error " Nao ha' custo nesta direcao!"
          initialize ctb10m01.*    to null
          initialize k_ctb10m01.*  to null
       end if
   else
      error " Nao ha' custo nesta direcao!"
      initialize ctb10m01.*    to null
      initialize k_ctb10m01.*  to null
   end if

   return k_ctb10m01.*, ctb10m01.*

end function    # anterior_ctb10m01


#------------------------------------------------------------
function modifica_ctb10m01(k_ctb10m01, ctb10m01)
#------------------------------------------------------------
# Modifica custos
#

   define  k_ctb10m01       record
           soccstcod        like dbskcustosocorro.soccstcod
   end record

   define  ctb10m01         record
           soccstcod        like dbskcustosocorro.soccstcod,
           soccstdes        like dbskcustosocorro.soccstdes,
           soccstclccod     like dbskcustosocorro.soccstclccod,
           soccstclcdes     char(20),
           soccstexbseq     like dbskcustosocorro.soccstexbseq,
           soctip           like dbskcustosocorro.soctip,       
           soctipdes        char (25),
           soccstsitcod     like dbskcustosocorro.soccstsitcod,
           caddat           like dbskcustosocorro.caddat,
           cadfunnom        like isskfunc.funnom,
           atldat           like dbskcustosocorro.atldat,
           funnom           like isskfunc.funnom
   end record

   define ws                record
          funmat            like isskfunc.funmat,
          cadfunmat         like isskfunc.funmat
   end record


   call input_ctb10m01("a", k_ctb10m01.* , ctb10m01.*) returning ctb10m01.*

   if int_flag  then
      let int_flag = false
      initialize ctb10m01.*  to null
      error " Operacao cancelada!"
      clear form
      return k_ctb10m01.*
   end if

   whenever error continue

   let ctb10m01.atldat = today

   begin work
      update dbskcustosocorro set  (soccstdes,
                                    soccstclccod,
                                    soccstsitcod,
                                    soccstexbseq,
                                    soctip, 
                                    atldat,
                                    funmat
                                   )
                              =    (ctb10m01.soccstdes,
                                    ctb10m01.soccstclccod,
                                    ctb10m01.soccstsitcod,
                                    ctb10m01.soccstexbseq,
                                    ctb10m01.soctip,          
                                    ctb10m01.atldat,
                                    g_issk.funmat
                                   )
             where dbskcustosocorro.soccstcod  =  k_ctb10m01.soccstcod

      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteracao do custo!"
         rollback work
         initialize ctb10m01.*   to null
         initialize k_ctb10m01.* to null
         return k_ctb10m01.*
      else
         error " Alteracao efetuada com sucesso!"
      end if

   commit work

   whenever error stop

   clear form
   message ""
   return k_ctb10m01.*

end function


#------------------------------------------------------------
function inclui_ctb10m01()
#------------------------------------------------------------
# Inclui custos
#

   define  ctb10m01         record
           soccstcod        like dbskcustosocorro.soccstcod,
           soccstdes        like dbskcustosocorro.soccstdes,
           soccstclccod     like dbskcustosocorro.soccstclccod,
           soccstclcdes     char(20),
           soccstexbseq     like dbskcustosocorro.soccstexbseq,
           soctip           like dbskcustosocorro.soctip,       
           soctipdes        char (25),
           soccstsitcod     like dbskcustosocorro.soccstsitcod,
           caddat           like dbskcustosocorro.caddat,
           cadfunnom        like isskfunc.funnom,
           atldat           like dbskcustosocorro.atldat,
           funnom           like isskfunc.funnom
   end record

   define k_ctb10m01        record
          soccstcod         like dbskcustosocorro.soccstcod
   end record

   define ws                record
          funmat            like isskfunc.funmat,
          cadfunmat         like isskfunc.funmat
   end record


   clear form

   initialize ctb10m01.*   to null
   initialize k_ctb10m01.* to null
   initialize ws.*         to null

   call input_ctb10m01("i",k_ctb10m01.*, ctb10m01.*) returning ctb10m01.*

   if int_flag  then
      let int_flag = false
      initialize ctb10m01.*  to null
      error " Operacao cancelada!"
      clear form
      return
   end if

   let ctb10m01.atldat = today
   let ctb10m01.caddat = today

   declare c_ctb10m01m  cursor with hold  for
           select  max(soccstcod)
             from  dbskcustosocorro
            where  dbskcustosocorro.soccstcod > 0

   foreach c_ctb10m01m  into  ctb10m01.soccstcod
       exit foreach
   end foreach

   if ctb10m01.soccstcod is null   then
      let ctb10m01.soccstcod = 0
   end if
   let ctb10m01.soccstcod = ctb10m01.soccstcod + 1

   whenever error continue

   begin work
      insert into dbskcustosocorro (soccstcod,
                                    soccstdes,
                                    soccstclccod,
                                    soccstexbseq,
                                    soccstsitcod,
                                    soctip,          
                                    caddat,
                                    cadfunmat,
                                    atldat,
                                    funmat)
                            values (ctb10m01.soccstcod,
                                    ctb10m01.soccstdes,
                                    ctb10m01.soccstclccod,
                                    ctb10m01.soccstexbseq,
                                    ctb10m01.soccstsitcod,
                                    ctb10m01.soctip,                
                                    ctb10m01.caddat,
                                    g_issk.funmat,
                                    ctb10m01.atldat,
                                    g_issk.funmat)

      if sqlca.sqlcode <>  0   then
         error " Erro (",sqlca.sqlcode,") na inclusao do custo!"
         rollback work
         return
      end if

   commit work

   whenever error stop

   select funnom
     into ctb10m01.cadfunnom
     from isskfunc
    where isskfunc.funmat = g_issk.funmat

   select funnom
     into ctb10m01.funnom
     from isskfunc
    where isskfunc.funmat = g_issk.funmat
   display by name  ctb10m01.*

   display by name ctb10m01.soccstcod attribute (reverse)
   error " Verifique o codigo do custo e tecle ENTER!"
   prompt "" for char wresp
   error " Inclusao efetuada com sucesso!"

   clear form

end function


#--------------------------------------------------------------------
function input_ctb10m01(operacao_aux, k_ctb10m01, ctb10m01)
#--------------------------------------------------------------------

   define  operacao_aux     char (1)

   define  k_ctb10m01       record
           soccstcod        like dbskcustosocorro.soccstcod
   end record

   define  ctb10m01         record
           soccstcod        like dbskcustosocorro.soccstcod,
           soccstdes        like dbskcustosocorro.soccstdes,
           soccstclccod     like dbskcustosocorro.soccstclccod,
           soccstclcdes     char(20),
           soccstexbseq     like dbskcustosocorro.soccstexbseq,
           soctip           like dbskcustosocorro.soctip,       
           soctipdes        char (25),
           soccstsitcod     like dbskcustosocorro.soccstsitcod,
           caddat           like dbskcustosocorro.caddat,
           cadfunnom        like isskfunc.funnom,
           atldat           like dbskcustosocorro.atldat,
           funnom           like isskfunc.funnom
   end record

   let int_flag = false

   input by name ctb10m01.soccstcod,
                 ctb10m01.soccstdes,
                 ctb10m01.soccstclccod,
                 ctb10m01.soccstexbseq,
                 ctb10m01.soctip,              
                 ctb10m01.soccstsitcod  without defaults

      before field soccstcod
             next field soccstdes
             display by name ctb10m01.soccstcod attribute (reverse)

      after  field soccstcod
             display by name ctb10m01.soccstcod

      before field soccstdes
             display by name ctb10m01.soccstdes attribute (reverse)

      after  field soccstdes
             display by name ctb10m01.soccstdes

             if ctb10m01.soccstdes  is null   then
                error " Descricao do custo deve ser informada!"
                next field soccstdes
             end if

      before field soccstclccod
             display by name ctb10m01.soccstclccod attribute (reverse)

      after  field soccstclccod
             display by name ctb10m01.soccstclccod

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field  soccstdes
             end if

             if ctb10m01.soccstclccod  is null   then
                error " Forma de calculo deve ser informada!"
                next field soccstclccod
             end if

             case ctb10m01.soccstclccod
                  when  1 let ctb10m01.soccstclcdes = "VALOR FIXO"
                  when  2 let ctb10m01.soccstclcdes = "VARIAVEL EM HORAS"
                  when  3 let ctb10m01.soccstclcdes = "VARIAVEL EM KM"
                  otherwise
                        error " Forma de calculo invalida!"
                        next field  soccstclccod
             end case
             display by name  ctb10m01.soccstclcdes

      before field soccstexbseq
             display by name ctb10m01.soccstexbseq attribute (reverse)

      after  field soccstexbseq
             display by name ctb10m01.soccstexbseq

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field  soccstclccod
             end if

             if ctb10m01.soccstexbseq  is null   or
                ctb10m01.soccstexbseq  = 000     then
                error " Ordem de exibicao deve ser informada!"
                next field soccstexbseq
             end if

             if operacao_aux = "a"   then
                select * from dbskcustosocorro
                 where soccstcod    <> ctb10m01.soccstcod        and
                       soccstexbseq  = ctb10m01.soccstexbseq
             else
                select * from dbskcustosocorro
                 where soccstcod     > 0                         and
                       soccstexbseq  = ctb10m01.soccstexbseq
             end if

             if sqlca.sqlcode = 0   then
                error " Ordem de exibicao ja' cadastrada!"
                next field soccstexbseq
             end if

      before field soctip
             display by name ctb10m01.soctip attribute (reverse)

      after  field soctip
             display by name ctb10m01.soctip

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field  soccstexbseq
             end if

             if ctb10m01.soctip  is null   then
                error " Adicional tipo deve ser informada!"
                next field soctip
             end if

             case ctb10m01.soctip   
                  when  1 let ctb10m01.soctipdes = "SERVICOS PORTO SOCORRO"
                  when  2 let ctb10m01.soctipdes = "SERVICOS CARRO-EXTRA" 
                  when  3 let ctb10m01.soctipdes = "SERVICOS RESIDENCIA"  
                  otherwise
                        error " Tipo adicional para servico invalido!"
                        next field  soctip
             end case
             display by name  ctb10m01.soctipdes 

      before field soccstsitcod
             display by name ctb10m01.soccstsitcod attribute (reverse)

      after  field soccstsitcod
             display by name ctb10m01.soccstsitcod

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field  soctip       
             end if

             if ctb10m01.soccstsitcod  is null   or
               (ctb10m01.soccstsitcod  <> "A"    and
                ctb10m01.soccstsitcod  <> "C")   then
                error " Situacao do custo deve ser: (A)tivo ou (C)ancelado!"
                next field soccstsitcod
             end if

             if operacao_aux           = "i"   and
                ctb10m01.soccstsitcod  = "C"   then
                error " Nao deve ser incluido custo com situacao (C)ancelado!"
                next field soccstsitcod
             end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      initialize ctb10m01.*  to null
      return ctb10m01.*
   end if

   return ctb10m01.*

end function   # input_ctb10m01


#--------------------------------------------------------------------
function remove_ctb10m01(k_ctb10m01)
#--------------------------------------------------------------------

   define  k_ctb10m01       record
           soccstcod        like dbskcustosocorro.soccstcod
   end record

   define  ctb10m01         record
           soccstcod        like dbskcustosocorro.soccstcod,
           soccstdes        like dbskcustosocorro.soccstdes,
           soccstclccod     like dbskcustosocorro.soccstclccod,
           soccstclcdes     char(20),
           soccstexbseq     like dbskcustosocorro.soccstexbseq,
           soctip           like dbskcustosocorro.soctip,       
           soctipdes        char (25),
           soccstsitcod     like dbskcustosocorro.soccstsitcod,
           caddat           like dbskcustosocorro.caddat,
           cadfunnom        like isskfunc.funnom,
           atldat           like dbskcustosocorro.atldat,
           funnom           like isskfunc.funnom
   end record

   define  ws               record
           soctrfvignum  like dbstgtfcst.soctrfvignum
   end record


   menu "Confirma Exclusao ?"

      command "Nao" "Nao exclui o custo"
              clear form
              initialize ctb10m01.*   to null
              initialize k_ctb10m01.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui custo"
              call sel_ctb10m01(k_ctb10m01.*) returning ctb10m01.*

              if sqlca.sqlcode = notfound  then
                 initialize ctb10m01.*   to null
                 initialize k_ctb10m01.* to null
                 error " Custo nao localizado!"
              else

                 initialize ws.soctrfvignum  to null

                 select max (dbstgtfcst.soctrfvignum)
                   into ws.soctrfvignum
                   from dbstgtfcst
                  where dbstgtfcst.soccstcod = k_ctb10m01.soccstcod

                 if ws.soctrfvignum  is not null     and
                    ws.soctrfvignum  > 0             then
                    error " Custo possui vigencia, portanto nao deve ser removido!"
                    exit menu
                 end if

                 begin work
                    delete from dbskcustosocorro
                     where dbskcustosocorro.soccstcod = k_ctb10m01.soccstcod
                 commit work

                 if sqlca.sqlcode <> 0   then
                    initialize ctb10m01.*   to null
                    initialize k_ctb10m01.* to null
                    error " Erro (",sqlca.sqlcode,") na exlusao do custo!"
                 else
                    initialize ctb10m01.*   to null
                    initialize k_ctb10m01.* to null
                    error   " Custo excluido!"
                    message ""
                    clear form
                 end if
              end if
              exit menu
   end menu

   return k_ctb10m01.*

end function    # remove_ctb10m01


#---------------------------------------------------------
function sel_ctb10m01(k_ctb10m01)
#---------------------------------------------------------

   define  k_ctb10m01       record
           soccstcod        like dbskcustosocorro.soccstcod
   end record

   define  ctb10m01         record
           soccstcod        like dbskcustosocorro.soccstcod,
           soccstdes        like dbskcustosocorro.soccstdes,
           soccstclccod     like dbskcustosocorro.soccstclccod,
           soccstclcdes     char(20),
           soccstexbseq     like dbskcustosocorro.soccstexbseq,
           soctip           like dbskcustosocorro.soctip,       
           soctipdes        char (25),
           soccstsitcod     like dbskcustosocorro.soccstsitcod,
           caddat           like dbskcustosocorro.caddat,
           cadfunnom        like isskfunc.funnom,
           atldat           like dbskcustosocorro.atldat,
           funnom           like isskfunc.funnom
   end record

   define ws                record
          funmat            like isskfunc.funmat,
          cadfunmat         like isskfunc.funmat
   end record


   initialize ctb10m01.*   to null
   initialize ws.*         to null

   select  soccstcod
     into  ctb10m01.soccstcod
     from  dbskcustosocorro
    where  dbskcustosocorro.soccstcod = k_ctb10m01.soccstcod

   if sqlca.sqlcode = notfound   then
      error " Custo nao cadastrado!"
      initialize ctb10m01.*    to null
      initialize k_ctb10m01.*  to null
   end if

   return ctb10m01.*

end function   # sel_ctb10m01
