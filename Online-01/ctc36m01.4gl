##########################################################################
# Nome do Modulo: CTC36M01                                        Marcelo #
#                                                                Gilberto #
#                                                                  Wagner #
# Manutencao dos laudos de vistoria de veiculos (AGENDA)         Dez/1998 #
###########################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


#------------------------------------------------------------
function ctc36m01()
#------------------------------------------------------------

   define ctc36m01        record
          socvstnum       like datmsocvst.socvstnum,
          socvstsit       like datmsocvst.socvstsit,
          sitdesc         char(20),
          socvsttip       like datmsocvst.socvsttip,
          tipdesc         char(11),
          atdvclsgl       like datkveiculo.atdvclsgl,
          socvclcod       like datmsocvst.socvclcod,
          socoprsitcod    like datkveiculo.socoprsitcod,
          sitvcldesc      char(10),
          vcldesc         char(58),
          vcllicnum       like datkveiculo.vcllicnum,
          pstcoddig       like datkveiculo.pstcoddig,
          nomgrr          like dpaksocor.nomgrr,
          socvstlclcod    like datmsocvst.socvstlclcod,
          socvstlclnom    like datkvstlcl.socvstlclnom,
          socvstdat       like datmsocvst.socvstdat,
          atldat          like datmsocvst.atldat,
          funnom          like isskfunc.funnom,
          socvstorgdat    like datmsocvst.socvstorgdat,
          socvstlautipcod like datkveiculo.socvstlautipcod,
          rowid           integer
   end record

   define k_ctc36m01   record
          socvstnum    like datmsocvst.socvstnum
   end record


   if not get_niv_mod(g_issk.prgsgl, "ctc36m01") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   let int_flag = false

   initialize ctc36m01.*   to  null
   initialize k_ctc36m01.* to  null

   open window ctc36m01 at 04,02 with form "ctc36m01"

   menu "AGENDA"

       before menu
          hide option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica", "Inclui", "Confirma", "Remove"
          end if
          show option "Encerra"

   command "Seleciona" "Pesquisa vistoria conforme criterios"
            call ctc36m01_seleciona() returning k_ctc36m01.*, ctc36m01.*
            if k_ctc36m01.socvstnum is not null  then
               message ""
               next option "Proximo"
            else
               error " Nenhuma vistoria selecionada!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proxima vistoria selecionada"
            message ""
            if k_ctc36m01.socvstnum is not null then
               call ctc36m01_proximo(k_ctc36m01.*)
                    returning k_ctc36m01.*, ctc36m01.*
            else
               error " Nenhuma vistoria nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra vistoria anterior selecionada"
            message ""
            if k_ctc36m01.socvstnum is not null then
               call ctc36m01_anterior(k_ctc36m01.*)
                    returning k_ctc36m01.*, ctc36m01.*
            else
               error " Nenhuma vistoria nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica vistoria corrente selecionada"
            message ""
            if k_ctc36m01.socvstnum  is not null   then
               if ctc36m01.socvsttip = 1 then
                  error " Vistoria automatica, portanto nao deve ser alterada!"
                 else
                  if ctc36m01.socvstsit <> 1   then
                     error " Vistoria nao esta na fase agendada, portanto nao deve ser alterada!"
                    else
                     call ctc36m01_modifica(k_ctc36m01.*, ctc36m01.*)
                            returning k_ctc36m01.*
                  end if
               end if
               next option "Seleciona"
             else
               error " Nenhuma vistoria selecionada!"
               next option "Seleciona"
            end if

   command "Remove" "Remove vistoria corrente selecionada"
            message ""
            if k_ctc36m01.socvstnum is not null then
               if ctc36m01.socvstsit <> 1   then
                    error " Vistoria nao esta na fase agendada, portanto nao deve ser removida!"
                  else
                    call ctc36m01_remove(k_ctc36m01.*)
                         returning k_ctc36m01.*
               end if
               next option "Seleciona"
            else
               error " Nenhuma vistoria selecionada!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui vistoria"
            message ""
            call ctc36m01_inclui()
            next option "Seleciona"

   command "Confirma" "Confirma vistoria corrente selecionada"
            message ""
            if k_ctc36m01.socvstnum  is not null   then
               if ctc36m01.socvstsit > 2    then
                    error " Vistoria nao esta na fase agendada/confirmada, portanto nao deve ser confirmada!"
                  else
                    call ctc36m01_confirma(k_ctc36m01.*, ctc36m01.*)
                         returning k_ctc36m01.*
                    next option "Seleciona"
               end if
             else
               error " Nenhuma vistoria selecionada!"
               next option "Seleciona"
            end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc36m01

end function  ###  ctc36m01


#------------------------------------------------------------
function ctc36m01_seleciona()
#------------------------------------------------------------

   define ctc36m01        record
          socvstnum       like datmsocvst.socvstnum,
          socvstsit       like datmsocvst.socvstsit,
          sitdesc         char(20),
          socvsttip       like datmsocvst.socvsttip,
          tipdesc         char(11),
          atdvclsgl       like datkveiculo.atdvclsgl,
          socvclcod       like datmsocvst.socvclcod,
          socoprsitcod    like datkveiculo.socoprsitcod,
          sitvcldesc      char(10),
          vcldesc         char(58),
          vcllicnum       like datkveiculo.vcllicnum,
          pstcoddig       like datkveiculo.pstcoddig,
          nomgrr          like dpaksocor.nomgrr,
          socvstlclcod    like datmsocvst.socvstlclcod,
          socvstlclnom    like datkvstlcl.socvstlclnom,
          socvstdat       like datmsocvst.socvstdat,
          atldat          like datmsocvst.atldat,
          funnom          like isskfunc.funnom,
          socvstorgdat    like datmsocvst.socvstorgdat,
          socvstlautipcod like datkveiculo.socvstlautipcod,
          rowid           integer
   end record

   define k_ctc36m01   record
          socvstnum    like datmsocvst.socvstnum
   end record

   clear form
   let int_flag = false
   initialize  ctc36m01.*  to null

   input by name k_ctc36m01.socvstnum

      before field socvstnum
          display by name k_ctc36m01.socvstnum attribute (reverse)

          if k_ctc36m01.socvstnum is null then
             let k_ctc36m01.socvstnum = 0
          end if

      after  field socvstnum
          display by name k_ctc36m01.socvstnum

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctc36m01.*   to null
      initialize k_ctc36m01.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctc36m01.*, ctc36m01.*
   end if

   if k_ctc36m01.socvstnum  =  0   then
      select min (datmsocvst.socvstnum)
        into k_ctc36m01.socvstnum
        from datmsocvst
       where socvstnum > k_ctc36m01.socvstnum
         and socvstsit in (1,2)

      display by name k_ctc36m01.socvstnum
   end if

   call ctc36m01_ler(k_ctc36m01.*)  returning  ctc36m01.*

   if ctc36m01.socvstnum  is not null    then
      display by name  ctc36m01.socvstnum thru ctc36m01.funnom
   else
      error " Nro. Vistoria nao cadastrada!"
      initialize ctc36m01.*    to null
      initialize k_ctc36m01.*  to null
   end if

   return k_ctc36m01.*, ctc36m01.*

end function  ###  ctc36m01_seleciona


#------------------------------------------------------------
function ctc36m01_proximo(k_ctc36m01)
#------------------------------------------------------------

   define ctc36m01        record
          socvstnum       like datmsocvst.socvstnum,
          socvstsit       like datmsocvst.socvstsit,
          sitdesc         char(20),
          socvsttip       like datmsocvst.socvsttip,
          tipdesc         char(11),
          atdvclsgl       like datkveiculo.atdvclsgl,
          socvclcod       like datmsocvst.socvclcod,
          socoprsitcod    like datkveiculo.socoprsitcod,
          sitvcldesc      char(10),
          vcldesc         char(58),
          vcllicnum       like datkveiculo.vcllicnum,
          pstcoddig       like datkveiculo.pstcoddig,
          nomgrr          like dpaksocor.nomgrr,
          socvstlclcod    like datmsocvst.socvstlclcod,
          socvstlclnom    like datkvstlcl.socvstlclnom,
          socvstdat       like datmsocvst.socvstdat,
          atldat          like datmsocvst.atldat,
          funnom          like isskfunc.funnom,
          socvstorgdat    like datmsocvst.socvstorgdat,
          socvstlautipcod like datkveiculo.socvstlautipcod,
          rowid           integer
   end record

   define k_ctc36m01   record
          socvstnum    like datmsocvst.socvstnum
   end record

   initialize ctc36m01.*   to null

   select min (datmsocvst.socvstnum)
     into ctc36m01.socvstnum
     from datmsocvst
    where socvstnum > k_ctc36m01.socvstnum
      and socvstsit in (1,2)

   if ctc36m01.socvstnum  is not null   then
      let k_ctc36m01.socvstnum = ctc36m01.socvstnum
      call ctc36m01_ler(k_ctc36m01.*)  returning  ctc36m01.*

      if ctc36m01.socvstnum  is not null    then
         display by name  ctc36m01.socvstnum thru ctc36m01.funnom
      else
         error " Nao ha' vistoria nesta direcao!"
         initialize k_ctc36m01.*  to null
      end if
   else
      error " Nao ha' vistoria nesta direcao!"
      call ctc36m01_ler(k_ctc36m01.*)  returning  ctc36m01.*
   end if

   return k_ctc36m01.*, ctc36m01.*

end function  ###  ctc36m01_proximo


#------------------------------------------------------------
function ctc36m01_anterior(k_ctc36m01)
#------------------------------------------------------------

   define ctc36m01        record
          socvstnum       like datmsocvst.socvstnum,
          socvstsit       like datmsocvst.socvstsit,
          sitdesc         char(20),
          socvsttip       like datmsocvst.socvsttip,
          tipdesc         char(11),
          atdvclsgl       like datkveiculo.atdvclsgl,
          socvclcod       like datmsocvst.socvclcod,
          socoprsitcod    like datkveiculo.socoprsitcod,
          sitvcldesc      char(10),
          vcldesc         char(58),
          vcllicnum       like datkveiculo.vcllicnum,
          pstcoddig       like datkveiculo.pstcoddig,
          nomgrr          like dpaksocor.nomgrr,
          socvstlclcod    like datmsocvst.socvstlclcod,
          socvstlclnom    like datkvstlcl.socvstlclnom,
          socvstdat       like datmsocvst.socvstdat,
          atldat          like datmsocvst.atldat,
          funnom          like isskfunc.funnom,
          socvstorgdat    like datmsocvst.socvstorgdat,
          socvstlautipcod like datkveiculo.socvstlautipcod,
          rowid           integer
   end record

   define k_ctc36m01   record
          socvstnum    like datmsocvst.socvstnum
   end record

   let int_flag = false
   initialize ctc36m01.*  to null

   select max (datmsocvst.socvstnum)
     into ctc36m01.socvstnum
     from datmsocvst
    where socvstnum < k_ctc36m01.socvstnum
      and socvstsit in (1,2)

   if ctc36m01.socvstnum  is  not  null  then
      let k_ctc36m01.socvstnum = ctc36m01.socvstnum
      call ctc36m01_ler(k_ctc36m01.*)  returning  ctc36m01.*

      if ctc36m01.socvstnum  is not null    then
         display by name  ctc36m01.socvstnum thru ctc36m01.funnom
      else
         error " Nao ha' vistoria nesta direcao!"
         initialize k_ctc36m01.*  to null
      end if
   else
      error " Nao ha' vistoria nesta direcao!"
      call ctc36m01_ler(k_ctc36m01.*)  returning  ctc36m01.*
   end if

   return k_ctc36m01.*, ctc36m01.*

end function  ###  ctc36m01_anterior


#------------------------------------------------------------
function ctc36m01_modifica(k_ctc36m01, ctc36m01)
#------------------------------------------------------------

   define ctc36m01        record
          socvstnum       like datmsocvst.socvstnum,
          socvstsit       like datmsocvst.socvstsit,
          sitdesc         char(20),
          socvsttip       like datmsocvst.socvsttip,
          tipdesc         char(11),
          atdvclsgl       like datkveiculo.atdvclsgl,
          socvclcod       like datmsocvst.socvclcod,
          socoprsitcod    like datkveiculo.socoprsitcod,
          sitvcldesc      char(10),
          vcldesc         char(58),
          vcllicnum       like datkveiculo.vcllicnum,
          pstcoddig       like datkveiculo.pstcoddig,
          nomgrr          like dpaksocor.nomgrr,
          socvstlclcod    like datmsocvst.socvstlclcod,
          socvstlclnom    like datkvstlcl.socvstlclnom,
          socvstdat       like datmsocvst.socvstdat,
          atldat          like datmsocvst.atldat,
          funnom          like isskfunc.funnom,
          socvstorgdat    like datmsocvst.socvstorgdat,
          socvstlautipcod like datkveiculo.socvstlautipcod,
          rowid           integer
   end record

   define k_ctc36m01   record
          socvstnum    like datmsocvst.socvstnum
   end record

   call ctc36m01_input("a", k_ctc36m01.* , ctc36m01.*) returning ctc36m01.*

   if int_flag  then
      let int_flag = false
      initialize k_ctc36m01.*  to null
      initialize ctc36m01.*    to null
      error " Operacao cancelada!"
      clear form
      return k_ctc36m01.*
   end if

   whenever error continue

   begin work
      update datmsocvst set (socvsttip,
                             socvclcod,
                             socvstlclcod,
                             socvstdat,
                             atldat,
                             atlemp,
                             atlmat)
                         =  (ctc36m01.socvsttip,
                             ctc36m01.socvclcod,
                             ctc36m01.socvstlclcod,
                             ctc36m01.socvstdat,
                             today,
                             g_issk.empcod,
                             g_issk.funmat)
         where socvstnum  =  k_ctc36m01.socvstnum

      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteracao da vistoria!"
         rollback work
         initialize ctc36m01.*   to null
         initialize k_ctc36m01.* to null
         return k_ctc36m01.*
      else
         error " Alteracao efetuada com sucesso!"
      end if

   commit work

   initialize ctc36m01.*    to null
   initialize k_ctc36m01.*  to null
   clear form
   message ""
   return k_ctc36m01.*

end function  ###  ctc36m01_modifica


#------------------------------------------------------------
function ctc36m01_inclui()
#------------------------------------------------------------

   define ctc36m01        record
          socvstnum       like datmsocvst.socvstnum,
          socvstsit       like datmsocvst.socvstsit,
          sitdesc         char(20),
          socvsttip       like datmsocvst.socvsttip,
          tipdesc         char(11),
          atdvclsgl       like datkveiculo.atdvclsgl,
          socvclcod       like datmsocvst.socvclcod,
          socoprsitcod    like datkveiculo.socoprsitcod,
          sitvcldesc      char(10),
          vcldesc         char(58),
          vcllicnum       like datkveiculo.vcllicnum,
          pstcoddig       like datkveiculo.pstcoddig,
          nomgrr          like dpaksocor.nomgrr,
          socvstlclcod    like datmsocvst.socvstlclcod,
          socvstlclnom    like datkvstlcl.socvstlclnom,
          socvstdat       like datmsocvst.socvstdat,
          atldat          like datmsocvst.atldat,
          funnom          like isskfunc.funnom,
          socvstorgdat    like datmsocvst.socvstorgdat,
          socvstlautipcod like datkveiculo.socvstlautipcod,
          rowid           integer
   end record

   define k_ctc36m01   record
          socvstnum    like datmsocvst.socvstnum
   end record

   define ws           record
          time         char(08),
          hora         char(05)
   end record

   define prompt_key   char (01)

   clear form

   initialize ctc36m01.*   to null
   initialize k_ctc36m01.* to null
   initialize ws.*         to null

   call ctc36m01_input("i",k_ctc36m01.*, ctc36m01.*) returning ctc36m01.*

   if int_flag  then
      let int_flag = false
      initialize ctc36m01.*  to null
      error " Operacao cancelada!"
      clear form
      return
   end if

   declare c_ctc36m01m  cursor with hold  for
      select max(socvstnum)
        from datmsocvst
       where socvstnum > 0

   foreach c_ctc36m01m  into  ctc36m01.socvstnum
       exit foreach
   end foreach

   if ctc36m01.socvstnum is null   then
      let ctc36m01.socvstnum = 0
   end if
   let ctc36m01.socvstnum = ctc36m01.socvstnum + 1
   let ws.time = time
   let ws.hora = ws.time[1,5]

   whenever error continue

   begin work
      insert into datmsocvst (socvstnum,
                              socvclcod,
                              socvsttip,
                              socvstsit,
                              socvstdat,
                              socvstorgdat,
                              socvstmotnom,
                              socvstlclcod,
                              socvstlautipcod,
                              socvstempcod,
                              socvstfunmat,
                              atldat,
                              atlemp,
                              atlmat)
                      values (ctc36m01.socvstnum,
                              ctc36m01.socvclcod,
                              ctc36m01.socvsttip,
                              1,
                              ctc36m01.socvstdat,
                              ctc36m01.socvstdat,
                              " ",
                              ctc36m01.socvstlclcod,
                              ctc36m01.socvstlautipcod,
                              g_issk.empcod,
                              g_issk.funmat,
                              today,
                              g_issk.empcod,
                              g_issk.funmat)

      if sqlca.sqlcode <>  0   then
         error " Erro (",sqlca.sqlcode,") na inclusao da vistoria!"
         rollback work
         return
      end if

      insert into datmvstfas (socvstnum,
                              socvstfasnum,
                              caddat,
                              cadhor,
                              cademp,
                              cadmat)
                     values  (ctc36m01.socvstnum,
                              1,
                              today,
                              ws.hora,
                              g_issk.empcod,
                              g_issk.funmat)

      if sqlca.sqlcode <>  0   then
         error " Erro (",sqlca.sqlcode,") na inclusao da fase da vistoria!"
         rollback work
         return
      end if

   commit work

   whenever error stop

   display by name ctc36m01.socvstnum attribute (reverse)
   error " Verifique o codigo da vistoria e tecle ENTER!"
   prompt "" for char prompt_key
   error " Inclusao efetuada com sucesso!"

   clear form

end function  ###  ctc36m01_inclui


#------------------------------------------------------------
function ctc36m01_confirma(k_ctc36m01, ctc36m01)
#------------------------------------------------------------

   define ctc36m01        record
          socvstnum       like datmsocvst.socvstnum,
          socvstsit       like datmsocvst.socvstsit,
          sitdesc         char(20),
          socvsttip       like datmsocvst.socvsttip,
          tipdesc         char(11),
          atdvclsgl       like datkveiculo.atdvclsgl,
          socvclcod       like datmsocvst.socvclcod,
          socoprsitcod    like datkveiculo.socoprsitcod,
          sitvcldesc      char(10),
          vcldesc         char(58),
          vcllicnum       like datkveiculo.vcllicnum,
          pstcoddig       like datkveiculo.pstcoddig,
          nomgrr          like dpaksocor.nomgrr,
          socvstlclcod    like datmsocvst.socvstlclcod,
          socvstlclnom    like datkvstlcl.socvstlclnom,
          socvstdat       like datmsocvst.socvstdat,
          atldat          like datmsocvst.atldat,
          funnom          like isskfunc.funnom,
          socvstorgdat    like datmsocvst.socvstorgdat,
          socvstlautipcod like datkveiculo.socvstlautipcod,
          rowid           integer
   end record

   define k_ctc36m01   record
          socvstnum    like datmsocvst.socvstnum
   end record

   define ws           record
          time         char(08),
          hora         char(05)
   end record

   call ctc36m01_input("c", k_ctc36m01.* , ctc36m01.*) returning ctc36m01.*

   if int_flag  then
      let int_flag = false
      initialize k_ctc36m01.*  to null
      initialize ctc36m01.*    to null
      error " Confirmacao cancelada!"
      clear form
      return k_ctc36m01.*
   end if

   whenever error continue

   begin work
      update datmsocvst set (socvstlclcod,
                             socvstdat,
                             socvstsit,
                             atldat,
                             atlemp,
                             atlmat)
                         =  (ctc36m01.socvstlclcod,
                             ctc36m01.socvstdat,
                             2,
                             today,
                             g_issk.empcod,
                             g_issk.funmat)
         where socvstnum  =  k_ctc36m01.socvstnum

      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na confirmacao da vistoria!"
         rollback work
         initialize ctc36m01.*   to null
         initialize k_ctc36m01.* to null
         return k_ctc36m01.*
      else
         let ws.time = time
         let ws.hora = ws.time[1,5]
         select socvstnum
           from datmvstfas
          where socvstnum    =  k_ctc36m01.socvstnum
            and socvstfasnum =  2

         if sqlca.sqlcode <> 0 then
            insert into datmvstfas (socvstnum,
                                    socvstfasnum,
                                    caddat,
                                    cadhor,
                                    cademp,
                                    cadmat)
                            values (ctc36m01.socvstnum,
                                    2,
                                    today,
                                    ws.hora,
                                    g_issk.empcod,
                                    g_issk.funmat)

            if sqlca.sqlcode <>  0   then
               error " Erro (",sqlca.sqlcode,") na inclusao da fase da vistoria!"
               rollback work
               return
            end if

           else

            update datmvstfas set (caddat,
                                   cadhor,
                                   cademp,
                                   cadmat)
                                = (today,
                                   ws.hora,
                                   g_issk.empcod,
                                   g_issk.funmat)
             where socvstnum    =  k_ctc36m01.socvstnum
               and socvstfasnum =  2

            if sqlca.sqlcode <>  0   then
               error " Erro (",sqlca.sqlcode,") na alteracao da fase da vistoria!"
               rollback work
               return
            end if
         end if

         error " Confirmacao efetuada com sucesso!"
      end if

   commit work

   initialize ctc36m01.*    to null
   initialize k_ctc36m01.*  to null
   clear form
   message ""
   return k_ctc36m01.*

end function  ###  ctc36m01_confirma


#--------------------------------------------------------------------
function ctc36m01_input(operacao_aux, k_ctc36m01, ctc36m01)
#--------------------------------------------------------------------

   define operacao_aux char (01)

   define ctc36m01        record
          socvstnum       like datmsocvst.socvstnum,
          socvstsit       like datmsocvst.socvstsit,
          sitdesc         char(20),
          socvsttip       like datmsocvst.socvsttip,
          tipdesc         char(11),
          atdvclsgl       like datkveiculo.atdvclsgl,
          socvclcod       like datmsocvst.socvclcod,
          socoprsitcod    like datkveiculo.socoprsitcod,
          sitvcldesc      char(10),
          vcldesc         char(58),
          vcllicnum       like datkveiculo.vcllicnum,
          pstcoddig       like datkveiculo.pstcoddig,
          nomgrr          like dpaksocor.nomgrr,
          socvstlclcod    like datmsocvst.socvstlclcod,
          socvstlclnom    like datkvstlcl.socvstlclnom,
          socvstdat       like datmsocvst.socvstdat,
          atldat          like datmsocvst.atldat,
          funnom          like isskfunc.funnom,
          socvstorgdat    like datmsocvst.socvstorgdat,
          socvstlautipcod like datkveiculo.socvstlautipcod,
          rowid           integer
   end record

   define k_ctc36m01   record
          socvstnum    like datmsocvst.socvstnum
   end record

   define ws           record
          vclcoddig    like datkveiculo.vclcoddig,
          socvstdiaqtd like datkveiculo.socvstdiaqtd,
          socvstlclcod like datkveiculo.socvstlclcod,
          socvstdat    like datmsocvst.socvstdat,
          dias         smallint,
          diasem       smallint,
          prssitcod    like dpaksocor.prssitcod,
          socvstlclsit like datkvstlcl.socvstlclsit,
          confirma     char (01),
          msglinha     char (40),
          conta        smallint,
          socvsttip    like datmsocvst.socvsttip
   end record


   let int_flag    = false
   initialize ws.*   to null

   input by name ctc36m01.socvstnum,
                 ctc36m01.socvsttip,
                 ctc36m01.atdvclsgl,
                 ctc36m01.socvstdat,
                 ctc36m01.socvstlclcod  without defaults

      before field socvstnum
             if operacao_aux = "c"   then
                next field socvstdat
             end if
             if operacao_aux = "i"   then
                let ctc36m01.socvstsit = 1
                let ctc36m01.sitdesc   = "AGENDADA"
                display by name ctc36m01.socvstsit
                display by name ctc36m01.sitdesc
             end if
             next field socvsttip
             display by name ctc36m01.socvstnum attribute (reverse)

      after  field socvstnum
             display by name ctc36m01.socvstnum

      before field socvsttip
             if operacao_aux = "c"   then
                next field socvstdat
             end if
             display by name ctc36m01.socvsttip   attribute (reverse)
             let ws.socvsttip = ctc36m01.socvsttip

      after  field socvsttip

             if ctc36m01.socvsttip   is null   then
                error " Tipo de vistoria deve ser informado!"
                next field socvsttip
             end if

             if ctc36m01.socvsttip >= 2 and
                ctc36m01.socvsttip <= 3 then
                select cpodes
                  into ctc36m01.tipdesc
                  from iddkdominio
                 where cponom = "socvsttip"
                   and cpocod = ctc36m01.socvsttip

                 if sqlca.sqlcode <> 0 then
                    error " Tipo de vistoria deve ser: (2)SOLICITADA, (3)RE-VISTORIA!"
                    next field socvsttip
                 end if
               else
                 error " Tipo de vistoria deve ser: (2)SOLICITADA, (3)RE-VISTORIA!"
                 next field socvsttip
             end if

             display by name ctc36m01.socvsttip
             display by name ctc36m01.tipdesc


      before field atdvclsgl
             if operacao_aux = "c"   then
                next field socvstdat
             end if
             display by name ctc36m01.atdvclsgl    attribute (reverse)

      after  field atdvclsgl
             display by name ctc36m01.atdvclsgl

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field  socvsttip
             end if

             if ctc36m01.atdvclsgl   is null   then
                error " Informe a sigla do veiculo! "
                next field atdvclsgl
             end if

             initialize ctc36m01.socvclcod,  ctc36m01.vcldesc,
                        ctc36m01.vcllicnum,  ctc36m01.pstcoddig,
                        ctc36m01.nomgrr   ,  ws.vclcoddig,
                        ws.socvstlclcod      to null

             display by name ctc36m01.socvclcod
             display by name ctc36m01.vcldesc
             display by name ctc36m01.vcllicnum
             display by name ctc36m01.pstcoddig
             display by name ctc36m01.nomgrr

             select socvclcod   , pstcoddig   , vclcoddig   , vcllicnum,
                    socvstlclcod, socvstdiaqtd, socoprsitcod, socvstlautipcod
               into ctc36m01.socvclcod   , ctc36m01.pstcoddig,
                    ws.vclcoddig         , ctc36m01.vcllicnum,
                    ws.socvstlclcod      , ws.socvstdiaqtd   ,
                    ctc36m01.socoprsitcod, ctc36m01.socvstlautipcod
               from datkveiculo
              where datkveiculo.atdvclsgl = ctc36m01.atdvclsgl

             if sqlca.sqlcode <> 0    then
                error " Veiculo nao cadastrado!"
                next field atdvclsgl
             end if

             call cts15g00(ws.vclcoddig) returning ctc36m01.vcldesc

             display by name ctc36m01.socvclcod
             display by name ctc36m01.vcldesc
             display by name ctc36m01.vcllicnum
             display by name ctc36m01.pstcoddig

             let ctc36m01.socvstlclcod = ws.socvstlclcod
             select socvstlclnom
               into ctc36m01.socvstlclnom
               from datkvstlcl
              where socvstlclcod = ctc36m01.socvstlclcod

             if sqlca.sqlcode <> 0 then
                let ctc36m01.socvstlclnom = " Local vistoria do cadastro!"
             end if

             display by name ctc36m01.socvstlclcod
             display by name ctc36m01.socvstlclnom

             select nomgrr, prssitcod
               into ctc36m01.nomgrr , ws.prssitcod
               from dpaksocor
              where dpaksocor.pstcoddig = ctc36m01.pstcoddig

             if sqlca.sqlcode <> 0    then
                let ctc36m01.nomgrr = "Prestador nao cadastrado!"
               else
                if ws.prssitcod <> "A"  then
                   let ctc36m01.nomgrr = "Prestador INATIVO!"
                end if
             end if

             display by name ctc36m01.nomgrr

             select cpodes
               into ctc36m01.sitvcldesc
               from iddkdominio
              where cponom = "socoprsitcod"
                and cpocod = ctc36m01.socoprsitcod

             display by name ctc36m01.sitvcldesc

             #VERIFICA SITUACAO DO VEICULO
             #---------------------------------------------------------
             if ctc36m01.socoprsitcod  =  3   then
                error " Veiculo cancelado! "
                next field atdvclsgl
             end if

             #VERIFICA SE VEICULO CONTEM PERIODICIDADE
             #---------------------------------------------------------
             if ws.socvstdiaqtd is null then
                error " Veiculo sem periodicidade para vistoria! "
                next field atdvclsgl
             end if

             #VERIFICA SE VEICULO JA' TEM VISTORIA (AGENDADA/CONFIRMADA)
             #---------------------------------------------------------
             initialize ws.socvstdat to null
             if ctc36m01.rowid is null then
                let ctc36m01.rowid = 0
             end if
             declare c_ctc36m01v cursor for
              select socvstdat
                from datmsocvst
               where socvclcod =  ctc36m01.socvclcod
                 and socvsttip in (2,3)          # <-- tip.: solicit./re-vist.
                 and socvstsit in (1,2)          # <-- sit.: agendada/confirm.
                 and rowid     <> ctc36m01.rowid # <-- mesmo registro

             foreach c_ctc36m01v into ws.socvstdat
                error " Veiculo ja' contem uma vistoria para o dia : ",ws.socvstdat," , favor verificar !"
                next field atdvclsgl
             end foreach

      before field socvstdat
             display by name ctc36m01.socvstdat    attribute (reverse)

      after  field socvstdat
             display by name ctc36m01.socvstdat

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field atdvclsgl
             end if

             if ctc36m01.socvstdat  is null  then
                error " Data da vistoria deve ser informada!"
                next field socvstdat
             end if

             if ctc36m01.socvstdat  <  today  then
                error " Data da vistoria nao deve ser menor que data atual!"
                next field socvstdat
             end if

             if ctc36m01.socvstdat  >  today + 30  then
                error " Data da vistoria nao deve ser maior que 30 dias da data atual!"
                next field socvstdat
             end if

             let ws.confirma = "N"
             let ws.diasem   = weekday(ctc36m01.socvstdat)

             case ws.diasem
                  when  0
                     call cts08g01("C","S", "",
                                            "DATA DA VISTORIA E UM DOMINGO",
                                            "",
                                            "CONFIRMA DATA ?")
                          returning ws.confirma

                     if ws.confirma  =  "N"   then
                        next field socvstdat
                     end if

                  when  1
                     call cts08g01("C","S", "",
                                            "DATA DA VISTORIA E UMA SEGUNDA-FEIRA",
                                            "",
                                            "CONFIRMA DATA ?")
                          returning ws.confirma

                     if ws.confirma  =  "N"   then
                        next field socvstdat
                     end if


                  when  6
                     call cts08g01("C","S", "",
                                            "DATA DA VISTORIA E UM SABADO",
                                            "",
                                            "CONFIRMA DATA ?")
                          returning ws.confirma

                     if ws.confirma  =  "N"   then
                        next field socvstdat
                     end if

                  otherwise
                        if dias_uteis(ctc36m01.socvstdat, 0, "", "S", "S") <>
                           ctc36m01.socvstdat  then
                           call cts08g01("C","S", "",
                                                "DATA DA VISTORIA E UM FERIADO",
                                                "",
                                                "CONFIRMA DATA ?")
                                returning ws.confirma

                           if ws.confirma  =  "N"   then
                              next field socvstdat
                           end if
                        end if
             end case

             # VERIFICA VISTORIA AUTOMATICA PARA O MESMO VEICULO
             #--------------------------------------------------
             if ctc36m01.rowid is null then
                let ctc36m01.rowid = 0
             end if
             let ws.conta = 0
             select count(*)
               into ws.conta
               from datmsocvst
              where socvclcod  =  ctc36m01.socvclcod
                and socvstdat  =  ctc36m01.socvstdat
                and socvsttip  =  1             # <-- tip.: automatica
                and socvstsit in (1,2)          # <-- sit.: agendada/confirm.
                and rowid      <> ctc36m01.rowid

             if ws.conta <> 0 then
                error " Ja' existe vistoria automatica com a mesma data!"
                next field socvstdat
             end if

             # VERIFICA QTDE DE VISTORIAS PARA A MESMA DATA
             #---------------------------------------------
             let ws.conta = 0
             select count(*)
               into ws.conta
               from datmsocvst
              where socvstdat  =  ctc36m01.socvstdat
                and socvstsit  in (1,2)
                and rowid      <> ctc36m01.rowid

             if ws.conta <> 0 then
                let ws.msglinha = "NESTA DATA, EXISTEM ",ws.conta using "###"
                call cts08g01("A","N"," ",
                                      ws.msglinha,
                                     " ",
                                     "VISTORIA(S) AGENDADAS/CONFIRMADAS !")
                  returning ws.confirma
             end if

             if operacao_aux = "c"   then
                let ws.dias = (ctc36m01.socvstdat - ctc36m01.socvstorgdat)
                if ws.dias > 10 then
                    error " Data vistoria excedeu ",ws.dias," dias da data original (",ctc36m01.socvstorgdat,") desta vistoria! "
                    next field socvstdat
                end if
             end if

      before field socvstlclcod
             display by name ctc36m01.socvstlclcod    attribute (reverse)
             display by name ctc36m01.socvstlclnom

      after  field socvstlclcod
             display by name ctc36m01.socvstlclcod

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field socvstdat
             end if

             if ctc36m01.socvstlclcod   is null   then
                error " Local da vistoria deve ser informado!"
                call ctc35m13()  returning ctc36m01.socvstlclcod
                next field socvstlclcod
             end if

             initialize ctc36m01.socvstlclnom,
                        ws.socvstlclsit     to null
             select socvstlclnom, socvstlclsit
               into ctc36m01.socvstlclnom, ws.socvstlclsit
               from datkvstlcl
              where socvstlclcod = ctc36m01.socvstlclcod

              if sqlca.sqlcode = notfound   then
                 error " Local da vistoria nao cadastrado!"
                 call ctc35m13()  returning ctc36m01.socvstlclcod
                 next field socvstlclcod
              end if

              display by name ctc36m01.socvstlclcod
              display by name ctc36m01.socvstlclnom

              if ws.socvstlclsit  <>  "A"   then
                 error " Local vistoria cancelado!"
                 next field socvstlclcod
              end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      initialize ctc36m01.*  to null
      return ctc36m01.*
   end if

   return ctc36m01.*

end function  ###  ctc36m01_input

#--------------------------------------------------------------------
function ctc36m01_remove(k_ctc36m01)
#--------------------------------------------------------------------

   define ctc36m01        record
          socvstnum       like datmsocvst.socvstnum,
          socvstsit       like datmsocvst.socvstsit,
          sitdesc         char(20),
          socvsttip       like datmsocvst.socvsttip,
          tipdesc         char(11),
          atdvclsgl       like datkveiculo.atdvclsgl,
          socvclcod       like datmsocvst.socvclcod,
          socoprsitcod    like datkveiculo.socoprsitcod,
          sitvcldesc      char(10),
          vcldesc         char(58),
          vcllicnum       like datkveiculo.vcllicnum,
          pstcoddig       like datkveiculo.pstcoddig,
          nomgrr          like dpaksocor.nomgrr,
          socvstlclcod    like datmsocvst.socvstlclcod,
          socvstlclnom    like datkvstlcl.socvstlclnom,
          socvstdat       like datmsocvst.socvstdat,
          atldat          like datmsocvst.atldat,
          funnom          like isskfunc.funnom,
          socvstorgdat    like datmsocvst.socvstorgdat,
          socvstlautipcod like datkveiculo.socvstlautipcod,
          rowid           integer
   end record

   define k_ctc36m01   record
          socvstnum    like datmsocvst.socvstnum
   end record

   menu "Confirma Exclusao ?"

      command "Nao" "Nao exclui vistoria "
              clear form
              initialize ctc36m01.*   to null
              initialize k_ctc36m01.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui vistoria"
              call ctc36m01_ler(k_ctc36m01.*) returning ctc36m01.*

              if sqlca.sqlcode = notfound  then
                 initialize ctc36m01.*   to null
                 initialize k_ctc36m01.* to null
                 error " Vistoria nao localizada!"
              else

                 begin work
                    delete from datmsocvst
                     where datmsocvst.socvstnum = k_ctc36m01.socvstnum

                    delete from datmvstfas
                     where datmvstfas.socvstnum = k_ctc36m01.socvstnum

                    delete from datmvstobs
                     where datmvstobs.socvstnum = k_ctc36m01.socvstnum
                 commit work

                 if sqlca.sqlcode <> 0   then
                    initialize ctc36m01.*   to null
                    initialize k_ctc36m01.* to null
                    error " Erro (",sqlca.sqlcode,") na exclusao da vistoria!"
                 else
                    initialize ctc36m01.*   to null
                    initialize k_ctc36m01.* to null
                    error   " Vistoria excluida!"
                    message ""
                    clear form
                 end if
              end if

              exit menu
   end menu

   initialize ctc36m01.*    to null
   initialize k_ctc36m01.*  to null
   clear form
   message ""
   return k_ctc36m01.*

end function  ###  ctc36m01_remove

#---------------------------------------------------------
function ctc36m01_ler(k_ctc36m01)
#---------------------------------------------------------

   define ctc36m01        record
          socvstnum       like datmsocvst.socvstnum,
          socvstsit       like datmsocvst.socvstsit,
          sitdesc         char(20),
          socvsttip       like datmsocvst.socvsttip,
          tipdesc         char(11),
          atdvclsgl       like datkveiculo.atdvclsgl,
          socvclcod       like datmsocvst.socvclcod,
          socoprsitcod    like datkveiculo.socoprsitcod,
          sitvcldesc      char(10),
          vcldesc         char(58),
          vcllicnum       like datkveiculo.vcllicnum,
          pstcoddig       like datkveiculo.pstcoddig,
          nomgrr          like dpaksocor.nomgrr,
          socvstlclcod    like datmsocvst.socvstlclcod,
          socvstlclnom    like datkvstlcl.socvstlclnom,
          socvstdat       like datmsocvst.socvstdat,
          atldat          like datmsocvst.atldat,
          funnom          like isskfunc.funnom,
          socvstorgdat    like datmsocvst.socvstorgdat,
          socvstlautipcod like datkveiculo.socvstlautipcod,
          rowid           integer
   end record

   define k_ctc36m01   record
          socvstnum    like datmsocvst.socvstnum
   end record

   define ws           record
          vclcoddig    like datkveiculo.vclcoddig,
          socvstlclsit like datkvstlcl.socvstlclsit,
          prssitcod    like dpaksocor.prssitcod,
          atlemp       like isskfunc.empcod,
          atlmat       like isskfunc.funmat,
          cademp       like isskfunc.empcod,
          cadmat       like isskfunc.funmat
   end record

   initialize ctc36m01.*   to null
   initialize ws.*         to null

   select socvstnum,
          socvclcod,
          socvsttip,
          socvstsit,
          socvstdat,
          socvstorgdat,
          socvstlclcod,
          atldat,
          atlemp,
          atlmat,
          rowid
     into ctc36m01.socvstnum,
          ctc36m01.socvclcod,
          ctc36m01.socvsttip,
          ctc36m01.socvstsit,
          ctc36m01.socvstdat,
          ctc36m01.socvstorgdat,
          ctc36m01.socvstlclcod,
          ctc36m01.atldat,
          ws.atlemp,
          ws.atlmat,
          ctc36m01.rowid
     from datmsocvst
    where socvstnum = k_ctc36m01.socvstnum

   if sqlca.sqlcode = notfound   then
      error " Vistoria nao cadastrada!"
      initialize ctc36m01.*    to null
      initialize k_ctc36m01.*  to null
      return ctc36m01.*
     else
      select funnom
        into ctc36m01.funnom
        from isskfunc
       where isskfunc.empcod = ws.atlemp
         and isskfunc.funmat = ws.atlmat
   end if

   select cpodes
     into ctc36m01.sitdesc
     from iddkdominio
    where cponom = "socvstsit"
      and cpocod = ctc36m01.socvstsit

   if sqlca.sqlcode <> 0 then
      let ctc36m01.sitdesc = "INVALIDO !!"
   end if

   select cpodes
     into ctc36m01.tipdesc
     from iddkdominio
    where cponom = "socvsttip"
      and cpocod = ctc36m01.socvsttip

   if sqlca.sqlcode <> 0 then
      let ctc36m01.tipdesc = "INVALIDO !!"
   end if

   select atdvclsgl, pstcoddig, vclcoddig, vcllicnum, socoprsitcod
     into ctc36m01.atdvclsgl   , ctc36m01.pstcoddig,
          ws.vclcoddig         , ctc36m01.vcllicnum,
          ctc36m01.socoprsitcod
     from datkveiculo
    where datkveiculo.socvclcod = ctc36m01.socvclcod

   call cts15g00(ws.vclcoddig) returning ctc36m01.vcldesc

   select nomgrr,
          prssitcod
     into ctc36m01.nomgrr,
          ws.prssitcod
     from dpaksocor
    where dpaksocor.pstcoddig = ctc36m01.pstcoddig

   if sqlca.sqlcode <> 0    then
      let ctc36m01.nomgrr = "Prestador nao cadastrado!"
      error " Prestador nao cadastrado, AVISE INFORMATICA!"
   end if

   select cpodes
     into ctc36m01.sitvcldesc
     from iddkdominio
    where cponom = "socoprsitcod"
      and cpocod = ctc36m01.socoprsitcod

   select socvstlclnom, socvstlclsit
     into ctc36m01.socvstlclnom, ws.socvstlclsit
     from datkvstlcl
    where socvstlclcod = ctc36m01.socvstlclcod

   if sqlca.sqlcode = notfound   then
      let ctc36m01.socvstlclnom = " Codigo local vistoria nao cadastrado!"
      error " Local da vistoria nao cadastrado, AVISE INFORMATICA!"
   end if

   return ctc36m01.*

end function  ###  ctc36m01_ler

