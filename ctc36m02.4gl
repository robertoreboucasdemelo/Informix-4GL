###########################################################################
# Nome do Modulo: ctc36m02                                        Marcelo #
#                                                                Gilberto #
#                                                                  Wagner #
# Manutencao dos laudos de vistoria de veiculos (LAUDO)          Dez/1998 #
###########################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


#------------------------------------------------------------
function ctc36m02()
#------------------------------------------------------------

   define ctc36m02     record
          socvstnum    like datmsocvst.socvstnum,
          socvstsit    like datmsocvst.socvstsit,
          sitdesc      char(20),
          socvsttip    like datmsocvst.socvsttip,
          tipdesc      char(11),
          atdvclsgl    like datkveiculo.atdvclsgl,
          socvclcod    like datmsocvst.socvclcod,
          vcldesc      char(58),
          vcllicnum    like datkveiculo.vcllicnum,
          socoprsitcod like datkveiculo.socoprsitcod,
          sitvcldesc   char(10),
          pstcoddig    like datkveiculo.pstcoddig,
          nomgrr       like dpaksocor.nomgrr,
          socvstdat    like datmsocvst.socvstdat,
          socvstlclcod like datmsocvst.socvstlclcod,
          socvstlclnom like datkvstlcl.socvstlclnom,
          socvstmotnom like datmsocvst.socvstmotnom,
          socvstfotqtd like datmsocvst.socvstfotqtd,
          atldat       like datmsocvst.atldat,
          funnom       like isskfunc.funnom
   end record

   define k_ctc36m02   record
          socvstnum    like datmsocvst.socvstnum
   end record


   if not get_niv_mod(g_issk.prgsgl, "ctc36m02") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   let int_flag = false

   initialize ctc36m02.*   to  null
   initialize k_ctc36m02.* to  null

   open window ctc36m02 at 04,02 with form "ctc36m02"

   menu "LAUDO"

       before menu
          hide option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then
              show option "Seleciona", "Proximo", "Anterior", "Fases"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then
              show option "Seleciona", "Proximo", "Anterior", "Modifica",
                          "Itens", "Obs", "Fases", "Cancela"
          end if
          show option "Encerra"

   command "Seleciona" "Pesquisa vistoria conforme criterios"
            call ctc36m02_seleciona() returning k_ctc36m02.*, ctc36m02.*
            if k_ctc36m02.socvstnum is not null  then
               message ""
               next option "Proximo"
            else
               error " Nenhuma vistoria selecionada!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proxima vistoria selecionada"
            message ""
            if k_ctc36m02.socvstnum is not null then
               call ctc36m02_proximo(k_ctc36m02.*)
                    returning k_ctc36m02.*, ctc36m02.*
            else
               error " Nenhuma vistoria nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra vistoria anterior selecionada"
            message ""
            if k_ctc36m02.socvstnum is not null then
               call ctc36m02_anterior(k_ctc36m02.*)
                    returning k_ctc36m02.*, ctc36m02.*
            else
               error " Nenhuma vistoria nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica vistoria corrente selecionada"
            message ""
            if k_ctc36m02.socvstnum  is not null   then
               if ctc36m02.socvstsit >= 2   and
                  ctc36m02.socvstsit <= 3   then
                  call ctc36m02_modifica(k_ctc36m02.*, ctc36m02.*)
                       returning k_ctc36m02.*
                 else
                  error " Vistoria nesta fase, nao pode ser alterada!"
               end if
               next option "Seleciona"
             else
               error " Nenhuma vistoria selecionada!"
               next option "Seleciona"
            end if

   command key ("I") "Itens" "Itens da vistoria selecionada"
           message ""
           if k_ctc36m02.socvstnum  is not null   then
              if ctc36m02.socvstsit  = 3  then
                 clear form
                 # Manutencao itens
                 call ctc36m03(k_ctc36m02.*, g_issk.empcod, g_issk.funmat)
                 initialize ctc36m02.*     to null
                 initialize k_ctc36m02.*   to null
                 next option "Seleciona"
               else
                 error " Itens da vistoria nesta fase, disponiveis so' para revisao!"
                 call ctc36m08(k_ctc36m02.*)         #-> Consulta itens
                 next option "Seleciona"
              end if
             else
              error " Nenhuma vistoria selecionada!"
              next option "Seleciona"
           end if

  command key ("O") "Obs"  "Observacoes da vistoria selecionada"
           message ""
           if k_ctc36m02.socvstnum  is not null   then
              call ctc37n00(k_ctc36m02.*, g_issk.empcod, g_issk.funmat)
              next option "Seleciona"
            else
              error " Nenhuma vistoria selecionada!"
              next option "Seleciona"
           end if

   command key ("F") "Fases" "Fases da vistoria selecionada"
           message ""
           if k_ctc36m02.socvstnum  is not null   then
              call ctc36m05(k_ctc36m02.*)
              next option "Seleciona"
           else
              error " Nenhuma vistoria selecionada!"
              next option "Seleciona"
           end if

   command key ("C") "Cancela" "Cancela vistoria selecionada"
           message ""
           if k_ctc36m02.socvstnum  is not null   then
              if ctc36m02.socvstsit = 6   then
                 error " Vistoria ja' cancelada!"
                else
                 if ctc36m02.socvstsit = 5 then
                    error " Vistoria com situacao realizada, portanto nao deve ser cancelada!"
                   else
                    if ctc36m02.socvstsit = 4 then
                       error " Vistoria com situacao digitada, portanto nao deve ser cancelada!"
                      else
                       if ctc36m02.socvstdat < today then
                          call ctc36m02_cancela(k_ctc36m02.*)
                               returning k_ctc36m02.*
                         else
                          if ctc36m02.socvsttip <> 2 then
                             error " Vistoria com data superior a hoje, portanto nao deve ser cancelada!"
                            else
                             call ctc36m02_cancela(k_ctc36m02.*)
                                  returning k_ctc36m02.*
                          end if
                       end if
                    end if
                 end if
              end if
              next option "Seleciona"
            else
              error " Nenhuma vistoria selecionada!"
              next option "Seleciona"
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu

   end menu

   close window ctc36m02

end function  ###  ctc36m02


#------------------------------------------------------------
function ctc36m02_seleciona()
#------------------------------------------------------------

   define ctc36m02     record
          socvstnum    like datmsocvst.socvstnum,
          socvstsit    like datmsocvst.socvstsit,
          sitdesc      char(20),
          socvsttip    like datmsocvst.socvsttip,
          tipdesc      char(11),
          atdvclsgl    like datkveiculo.atdvclsgl,
          socvclcod    like datmsocvst.socvclcod,
          vcldesc      char(58),
          vcllicnum    like datkveiculo.vcllicnum,
          socoprsitcod like datkveiculo.socoprsitcod,
          sitvcldesc   char(10),
          pstcoddig    like datkveiculo.pstcoddig,
          nomgrr       like dpaksocor.nomgrr,
          socvstdat    like datmsocvst.socvstdat,
          socvstlclcod like datmsocvst.socvstlclcod,
          socvstlclnom like datkvstlcl.socvstlclnom,
          socvstmotnom like datmsocvst.socvstmotnom,
          socvstfotqtd like datmsocvst.socvstfotqtd,
          atldat       like datmsocvst.atldat,
          funnom       like isskfunc.funnom
   end record

   define k_ctc36m02   record
          socvstnum    like datmsocvst.socvstnum
   end record

   clear form
   let int_flag = false
   initialize  ctc36m02.*  to null

   input by name k_ctc36m02.socvstnum

      before field socvstnum
          display by name k_ctc36m02.socvstnum attribute (reverse)

          if k_ctc36m02.socvstnum is null then
             let k_ctc36m02.socvstnum = 0
          end if

      after  field socvstnum
          display by name k_ctc36m02.socvstnum

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctc36m02.*   to null
      initialize k_ctc36m02.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctc36m02.*, ctc36m02.*
   end if

   if k_ctc36m02.socvstnum  =  0   then
      select min (datmsocvst.socvstnum)
        into k_ctc36m02.socvstnum
        from datmsocvst
       where socvstnum > k_ctc36m02.socvstnum
         and socvstsit in (2,3,4)

      display by name k_ctc36m02.socvstnum
   end if

   call ctc36m02_ler(k_ctc36m02.*)  returning  ctc36m02.*

   if ctc36m02.socvstnum  is not null    then
      display by name  ctc36m02.socvstnum thru ctc36m02.funnom
   else
      error " Nro. Vistoria nao cadastrada!"
      initialize ctc36m02.*    to null
      initialize k_ctc36m02.*  to null
   end if

   return k_ctc36m02.*, ctc36m02.*

end function  ###  ctc36m02_seleciona


#------------------------------------------------------------
function ctc36m02_proximo(k_ctc36m02)
#------------------------------------------------------------

   define ctc36m02     record
          socvstnum    like datmsocvst.socvstnum,
          socvstsit    like datmsocvst.socvstsit,
          sitdesc      char(20),
          socvsttip    like datmsocvst.socvsttip,
          tipdesc      char(11),
          atdvclsgl    like datkveiculo.atdvclsgl,
          socvclcod    like datmsocvst.socvclcod,
          vcldesc      char(58),
          vcllicnum    like datkveiculo.vcllicnum,
          socoprsitcod like datkveiculo.socoprsitcod,
          sitvcldesc   char(10),
          pstcoddig    like datkveiculo.pstcoddig,
          nomgrr       like dpaksocor.nomgrr,
          socvstdat    like datmsocvst.socvstdat,
          socvstlclcod like datmsocvst.socvstlclcod,
          socvstlclnom like datkvstlcl.socvstlclnom,
          socvstmotnom like datmsocvst.socvstmotnom,
          socvstfotqtd like datmsocvst.socvstfotqtd,
          atldat       like datmsocvst.atldat,
          funnom       like isskfunc.funnom
   end record

   define k_ctc36m02   record
          socvstnum    like datmsocvst.socvstnum
   end record

   initialize ctc36m02.*   to null

   select min (datmsocvst.socvstnum)
     into ctc36m02.socvstnum
     from datmsocvst
    where socvstnum > k_ctc36m02.socvstnum
      and socvstsit in (2,3,4)

   if ctc36m02.socvstnum  is not null   then
      let k_ctc36m02.socvstnum = ctc36m02.socvstnum
      call ctc36m02_ler(k_ctc36m02.*)  returning  ctc36m02.*

      if ctc36m02.socvstnum  is not null    then
         display by name  ctc36m02.socvstnum thru ctc36m02.funnom
      else
         error " Nao ha' vistoria nesta direcao!"
         initialize k_ctc36m02.*  to null
      end if
   else
      error " Nao ha' vistoria nesta direcao!"
      call ctc36m02_ler(k_ctc36m02.*)  returning  ctc36m02.*
   end if

   return k_ctc36m02.*, ctc36m02.*

end function  ###  ctc36m02_proximo


#------------------------------------------------------------
function ctc36m02_anterior(k_ctc36m02)
#------------------------------------------------------------

   define ctc36m02     record
          socvstnum    like datmsocvst.socvstnum,
          socvstsit    like datmsocvst.socvstsit,
          sitdesc      char(20),
          socvsttip    like datmsocvst.socvsttip,
          tipdesc      char(11),
          atdvclsgl    like datkveiculo.atdvclsgl,
          socvclcod    like datmsocvst.socvclcod,
          vcldesc      char(58),
          vcllicnum    like datkveiculo.vcllicnum,
          socoprsitcod like datkveiculo.socoprsitcod,
          sitvcldesc   char(10),
          pstcoddig    like datkveiculo.pstcoddig,
          nomgrr       like dpaksocor.nomgrr,
          socvstdat    like datmsocvst.socvstdat,
          socvstlclcod like datmsocvst.socvstlclcod,
          socvstlclnom like datkvstlcl.socvstlclnom,
          socvstmotnom like datmsocvst.socvstmotnom,
          socvstfotqtd like datmsocvst.socvstfotqtd,
          atldat       like datmsocvst.atldat,
          funnom       like isskfunc.funnom
   end record

   define k_ctc36m02   record
          socvstnum    like datmsocvst.socvstnum
   end record

   let int_flag = false
   initialize ctc36m02.*  to null

   select max (datmsocvst.socvstnum)
     into ctc36m02.socvstnum
     from datmsocvst
    where socvstnum < k_ctc36m02.socvstnum
      and socvstsit in (2,3,4)

   if ctc36m02.socvstnum  is  not  null  then
      let k_ctc36m02.socvstnum = ctc36m02.socvstnum
      call ctc36m02_ler(k_ctc36m02.*)  returning  ctc36m02.*

      if ctc36m02.socvstnum  is not null    then
         display by name  ctc36m02.socvstnum thru ctc36m02.funnom
      else
         error " Nao ha' vistoria nesta direcao!"
         initialize k_ctc36m02.*  to null
      end if
   else
      error " Nao ha' vistoria nesta direcao!"
      call ctc36m02_ler(k_ctc36m02.*)  returning  ctc36m02.*
   end if

   return k_ctc36m02.*, ctc36m02.*

end function  ###  ctc36m02_anterior


#------------------------------------------------------------
function ctc36m02_modifica(k_ctc36m02, ctc36m02)
#------------------------------------------------------------

   define ctc36m02     record
          socvstnum    like datmsocvst.socvstnum,
          socvstsit    like datmsocvst.socvstsit,
          sitdesc      char(20),
          socvsttip    like datmsocvst.socvsttip,
          tipdesc      char(11),
          atdvclsgl    like datkveiculo.atdvclsgl,
          socvclcod    like datmsocvst.socvclcod,
          vcldesc      char(58),
          vcllicnum    like datkveiculo.vcllicnum,
          socoprsitcod like datkveiculo.socoprsitcod,
          sitvcldesc   char(10),
          pstcoddig    like datkveiculo.pstcoddig,
          nomgrr       like dpaksocor.nomgrr,
          socvstdat    like datmsocvst.socvstdat,
          socvstlclcod like datmsocvst.socvstlclcod,
          socvstlclnom like datkvstlcl.socvstlclnom,
          socvstmotnom like datmsocvst.socvstmotnom,
          socvstfotqtd like datmsocvst.socvstfotqtd,
          atldat       like datmsocvst.atldat,
          funnom       like isskfunc.funnom
   end record

   define k_ctc36m02   record
          socvstnum    like datmsocvst.socvstnum
   end record

   call ctc36m02_input("a", k_ctc36m02.* , ctc36m02.*) returning ctc36m02.*

   if int_flag  then
      let int_flag = false
      initialize k_ctc36m02.*  to null
      initialize ctc36m02.*    to null
      error " Operacao cancelada!"
      clear form
      return k_ctc36m02.*
   end if

   whenever error continue

   begin work
      update datmsocvst set (socvstsit,
                             socvstmotnom,
                             socvstfotqtd,
                             atldat,
                             atlemp,
                             atlmat)
                         =  (3,
                             ctc36m02.socvstmotnom,
                             ctc36m02.socvstfotqtd,
                             today,
                             g_issk.empcod,
                             g_issk.funmat)
         where socvstnum  =  k_ctc36m02.socvstnum

      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteracao da vistoria!"
         rollback work
         initialize ctc36m02.*   to null
         initialize k_ctc36m02.* to null
         return k_ctc36m02.*
      else
         error " Alteracao efetuada com sucesso!"
      end if

   commit work

   initialize ctc36m02.*    to null
   initialize k_ctc36m02.*  to null
   clear form
   message ""
   return k_ctc36m02.*

end function  ###  ctc36m02_modifica


#--------------------------------------------------------------------
function ctc36m02_input(operacao_aux, k_ctc36m02, ctc36m02)
#--------------------------------------------------------------------

   define operacao_aux char (01)

   define ctc36m02     record
          socvstnum    like datmsocvst.socvstnum,
          socvstsit    like datmsocvst.socvstsit,
          sitdesc      char(20),
          socvsttip    like datmsocvst.socvsttip,
          tipdesc      char(11),
          atdvclsgl    like datkveiculo.atdvclsgl,
          socvclcod    like datmsocvst.socvclcod,
          vcldesc      char(58),
          vcllicnum    like datkveiculo.vcllicnum,
          socoprsitcod like datkveiculo.socoprsitcod,
          sitvcldesc   char(10),
          pstcoddig    like datkveiculo.pstcoddig,
          nomgrr       like dpaksocor.nomgrr,
          socvstdat    like datmsocvst.socvstdat,
          socvstlclcod like datmsocvst.socvstlclcod,
          socvstlclnom like datkvstlcl.socvstlclnom,
          socvstmotnom like datmsocvst.socvstmotnom,
          socvstfotqtd like datmsocvst.socvstfotqtd,
          atldat       like datmsocvst.atldat,
          funnom       like isskfunc.funnom
   end record

   define k_ctc36m02   record
          socvstnum    like datmsocvst.socvstnum
   end record

   define ws           record
          vclcoddig    like datkveiculo.vclcoddig,
          socvstdiaqtd like datkveiculo.socvstdiaqtd,
          socvstlclcod like datkveiculo.socvstlclcod,
          dias         smallint,
          diasem       smallint,
          prssitcod    like dpaksocor.prssitcod,
          socvstlclsit like datkvstlcl.socvstlclsit,
          confirma     char (01),
          conta        smallint,
          socvsttip    like datmsocvst.socvsttip
   end record


   let int_flag    = false
   initialize ws.*   to null

   input by name ctc36m02.socvstmotnom,
                 ctc36m02.socvstfotqtd  without defaults

      before field socvstmotnom
             display by name ctc36m02.socvstmotnom   attribute (reverse)

      after  field socvstmotnom
             display by name ctc36m02.socvstmotnom

             if ctc36m02.socvstmotnom   is null     or
                ctc36m02.socvstmotnom[1,2] = "  "   then
                error " Nome do motorista deve ser informado! "
                next field socvstmotnom
             end if

      before field socvstfotqtd
             display by name ctc36m02.socvstfotqtd   attribute (reverse)

      after  field socvstfotqtd
             display by name ctc36m02.socvstfotqtd

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field  socvstmotnom
             end if

             if ctc36m02.socvstfotqtd   is null  then
                error " Quantidade de fotos deve ser informada! "
                next field socvstfotqtd
             end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      initialize ctc36m02.*  to null
      return ctc36m02.*
   end if

   return ctc36m02.*

end function  ###  ctc36m02_input


#--------------------------------------------------------------------
function ctc36m02_cancela(k_ctc36m02)
#--------------------------------------------------------------------

   define ctc36m02     record
          socvstnum    like datmsocvst.socvstnum,
          socvstsit    like datmsocvst.socvstsit,
          sitdesc      char(20),
          socvsttip    like datmsocvst.socvsttip,
          tipdesc      char(11),
          atdvclsgl    like datkveiculo.atdvclsgl,
          socvclcod    like datmsocvst.socvclcod,
          vcldesc      char(58),
          vcllicnum    like datkveiculo.vcllicnum,
          socoprsitcod like datkveiculo.socoprsitcod,
          sitvcldesc   char(10),
          pstcoddig    like datkveiculo.pstcoddig,
          nomgrr       like dpaksocor.nomgrr,
          socvstdat    like datmsocvst.socvstdat,
          socvstlclcod like datmsocvst.socvstlclcod,
          socvstlclnom like datkvstlcl.socvstlclnom,
          socvstmotnom like datmsocvst.socvstmotnom,
          socvstfotqtd like datmsocvst.socvstfotqtd,
          atldat       like datmsocvst.atldat,
          funnom       like isskfunc.funnom
   end record

   define k_ctc36m02   record
          socvstnum    like datmsocvst.socvstnum
   end record

   menu "Confirma Cancelamento ?"

      command "Nao" "Nao cancela vistoria "
              clear form
              initialize ctc36m02.*   to null
              initialize k_ctc36m02.* to null
              error " Cancelamento nao confirmado!"
              exit menu

      command "Sim" "Cancela vistoria"
              call ctc36m02_ler(k_ctc36m02.*) returning ctc36m02.*

              if sqlca.sqlcode = notfound  then
                 initialize ctc36m02.*   to null
                 initialize k_ctc36m02.* to null
                 error " Vistoria nao localizada!"
                else

                 whenever error continue

                 begin work
                 update datmsocvst set (socvstsit,
                                        atldat,
                                        atlemp,
                                        atlmat)
                                    =  (6,
                                        today,
                                        g_issk.empcod,
                                        g_issk.funmat)
                    where socvstnum  =  k_ctc36m02.socvstnum

                 if sqlca.sqlcode <>  0  then
                    error " Erro (",sqlca.sqlcode,") na alteracao da vistoria!"
                    rollback work
                    initialize ctc36m02.*   to null
                    initialize k_ctc36m02.* to null
                    return k_ctc36m02.*
                   else
                    error " Cancelamento efetuado com sucesso!"
                 end if

                 commit work

                 exit menu

              end if
   end menu

   initialize ctc36m02.*    to null
   initialize k_ctc36m02.*  to null
   clear form
   message ""
   return k_ctc36m02.*

end function  ###  ctc36m02_cancela

#---------------------------------------------------------
function ctc36m02_ler(k_ctc36m02)
#---------------------------------------------------------

   define ctc36m02     record
          socvstnum    like datmsocvst.socvstnum,
          socvstsit    like datmsocvst.socvstsit,
          sitdesc      char(20),
          socvsttip    like datmsocvst.socvsttip,
          tipdesc      char(11),
          atdvclsgl    like datkveiculo.atdvclsgl,
          socvclcod    like datmsocvst.socvclcod,
          vcldesc      char(58),
          vcllicnum    like datkveiculo.vcllicnum,
          socoprsitcod like datkveiculo.socoprsitcod,
          sitvcldesc   char(10),
          pstcoddig    like datkveiculo.pstcoddig,
          nomgrr       like dpaksocor.nomgrr,
          socvstdat    like datmsocvst.socvstdat,
          socvstlclcod like datmsocvst.socvstlclcod,
          socvstlclnom like datkvstlcl.socvstlclnom,
          socvstmotnom like datmsocvst.socvstmotnom,
          socvstfotqtd like datmsocvst.socvstfotqtd,
          atldat       like datmsocvst.atldat,
          funnom       like isskfunc.funnom
   end record

   define k_ctc36m02   record
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

   initialize ctc36m02.*   to null
   initialize ws.*         to null

   select socvstnum,
          socvclcod,
          socvsttip,
          socvstsit,
          socvstdat,
          socvstlclcod,
          socvstmotnom,
          socvstfotqtd,
          atldat,
          atlemp,
          atlmat
     into ctc36m02.socvstnum,
          ctc36m02.socvclcod,
          ctc36m02.socvsttip,
          ctc36m02.socvstsit,
          ctc36m02.socvstdat,
          ctc36m02.socvstlclcod,
          ctc36m02.socvstmotnom,
          ctc36m02.socvstfotqtd,
          ctc36m02.atldat,
          ws.atlemp,
          ws.atlmat
     from datmsocvst
    where socvstnum = k_ctc36m02.socvstnum

   if sqlca.sqlcode = notfound   then
      error " Vistoria nao cadastrada!"
      initialize ctc36m02.*    to null
      initialize k_ctc36m02.*  to null
      return ctc36m02.*
     else
      select funnom
        into ctc36m02.funnom
        from isskfunc
       where isskfunc.empcod = ws.atlemp
         and isskfunc.funmat = ws.atlmat
   end if

   select cpodes
     into ctc36m02.sitdesc
     from iddkdominio
    where cponom = "socvstsit"
      and cpocod = ctc36m02.socvstsit

   if sqlca.sqlcode <> 0 then
      let ctc36m02.sitdesc = "INVALIDO !!"
   end if

   select cpodes
     into ctc36m02.tipdesc
     from iddkdominio
    where cponom = "socvsttip"
      and cpocod = ctc36m02.socvsttip

   if sqlca.sqlcode <> 0 then
      let ctc36m02.tipdesc = "INVALIDO !!"
   end if

   select atdvclsgl, pstcoddig, vclcoddig, vcllicnum, socoprsitcod
     into ctc36m02.atdvclsgl   , ctc36m02.pstcoddig,
          ws.vclcoddig         , ctc36m02.vcllicnum,
          ctc36m02.socoprsitcod
     from datkveiculo
    where datkveiculo.socvclcod = ctc36m02.socvclcod

   call cts15g00(ws.vclcoddig) returning ctc36m02.vcldesc

   select nomgrr, prssitcod
     into ctc36m02.nomgrr , ws.prssitcod
     from dpaksocor
    where dpaksocor.pstcoddig = ctc36m02.pstcoddig

   if sqlca.sqlcode <> 0    then
      let ctc36m02.nomgrr = "Prestador nao cadastrado!"
     else
      if ws.prssitcod <> "A"  then
         let ctc36m02.nomgrr = "Prestador INATIVO!"
      end if
   end if

   select socvstlclnom, socvstlclsit
     into ctc36m02.socvstlclnom, ws.socvstlclsit
     from datkvstlcl
    where socvstlclcod = ctc36m02.socvstlclcod

   case ctc36m02.socoprsitcod
        when 1  let ctc36m02.sitvcldesc = "ATIVO     "
        when 2  let ctc36m02.sitvcldesc = "BLOQUEADO "
        when 3  let ctc36m02.sitvcldesc = "INATIVO   "
   end case

   if sqlca.sqlcode = notfound   then
      let ctc36m02.socvstlclnom = " Codigo local vistoria nao cadastrado!"
     else
      if ws.socvstlclsit <> "A" then
         let ctc36m02.socvstlclnom = " Codigo local vistoria nao esta' ativo!"
      end if
   end if

   return ctc36m02.*

end function  ###  ctc36m02_ler

