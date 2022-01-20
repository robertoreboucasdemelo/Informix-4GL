###########################################################################
# Nome do Modulo: CTC03M00                                          Pedro #
#                                                                         #
# Manutencao no Cadastro de Escritorios de Corretagem            Set/1994 #
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

define wdata     date      ,
       wprepare  char (700),
       wresp     char (001)

#------------------------------------------------------------
function ctc03m00()
#------------------------------------------------------------
# Menu do modulo
# --------------

   define  ctc03m00     record
           esccod       like gabkesc.esccod,
           escnom       like gabkesc.escnom,
           rspnom       like gabkesc.rspnom,
           endlgd       like gabkesc.endlgd,
           endbrr       like gabkesc.endbrr,
           endcid       like gabkesc.endcid,
           endufd       like gabkesc.endufd,
           endcep       like gabkesc.endcep,
           endcepcmp    like gabkesc.endcepcmp,
           dddcod       like gabkesc.dddcod,
           teltxt       like gabkesc.teltxt,
           factxt       like gabkesc.factxt
   end record

   define k_ctc03m00    record
          esccod        like gabkesc.esccod
   end record

   #PSI 202290
   #if not get_niv_mod(g_issk.prgsgl, "ctc03m00") then
   #   error "Modulo sem nivel de consulta e atualizacao!"
   #   return
   #end if

   open window ctc03m00 at 4,2 with form "ctc03m00"

   let int_flag = false
   let wdata    = today

   initialize ctc03m00.*   to  null
   initialize k_ctc03m00.* to  null

   menu "ESCRITORIOS DE CORRETAGEM"
       before menu
          hide option all
          #PSI 202290
          #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior"
          #end if
          #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
          #      show option "Seleciona", "Proximo", "Anterior"
                     ###### "Modifica", "Remove", "Inclui"
          #end if

          show option "Encerra"

   command "Seleciona" "Pesquisa tabela conforme criterios"
            call seleciona_ctc03m00() returning k_ctc03m00.*
            if k_ctc03m00.esccod is not null  then
               message ""
               next option "Proximo"
            else
               error "Nenhum registro selecionado!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo registro selecionado"
            message ""
            if k_ctc03m00.esccod is not null then
               call proximo_ctc03m00(k_ctc03m00.*)
                    returning k_ctc03m00.*
            else
               error "Nao ha' mais registro nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra registro anterior selecionado"
            message ""
            if k_ctc03m00.esccod is not null then
               call anterior_ctc03m00(k_ctc03m00.*)
                    returning k_ctc03m00.*
            else
               error "Nao ha' mais registro nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica registro corrente selecionado"
            message ""
            if k_ctc03m00.esccod is not null then
               call modifica_ctc03m00(k_ctc03m00.*)
                    returning k_ctc03m00.*
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Remove" "Remove registro corrente selecionado"
            message ""
            if k_ctc03m00.esccod is not null then
               call remove_ctc03m00(k_ctc03m00.*)
                    returning k_ctc03m00.*
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui registro na tabela"
            message ""
            call inclui_ctc03m00()
            next option "Seleciona"

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc03m00

end function  # ctc03m00

#------------------------------------------------------------
function seleciona_ctc03m00()
#------------------------------------------------------------

   define  ctc03m00     record
           esccod       like gabkesc.esccod,
           escnom       like gabkesc.escnom,
           rspnom       like gabkesc.rspnom,
           endlgd       like gabkesc.endlgd,
           endbrr       like gabkesc.endbrr,
           endcid       like gabkesc.endcid,
           endufd       like gabkesc.endufd,
           endcep       like gabkesc.endcep,
           endcepcmp    like gabkesc.endcepcmp,
           dddcod       like gabkesc.dddcod,
           teltxt       like gabkesc.teltxt,
           factxt       like gabkesc.factxt
   end record

   define k_ctc03m00    record
          esccod        like gabkesc.esccod
   end record

   clear form

   let int_flag = false

   input by name k_ctc03m00.esccod

      before field esccod
          display by name k_ctc03m00.esccod attribute (reverse)

          if k_ctc03m00.esccod is null then
             let k_ctc03m00.esccod = 0
          end if

      after  field esccod
          display by name k_ctc03m00.esccod

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctc03m00.* to null
      error "Operacao cancelada!"
      clear form
      return k_ctc03m00.*
   end if

   if k_ctc03m00.esccod = 0 then
      select min (gabkesc.esccod)
      into   k_ctc03m00.esccod
      from   gabkesc
      where gabkesc.esccod > 0

      display by name k_ctc03m00.esccod
   end if

   select esccod   ,
          escnom   ,
          rspnom   ,
          endlgd   ,
          endbrr   ,
          endcid   ,
          endufd   ,
          endcep   ,
          endcepcmp,
          dddcod   ,
          teltxt   ,
          factxt
      into
          ctc03m00.esccod   ,
          ctc03m00.escnom   ,
          ctc03m00.rspnom   ,
          ctc03m00.endlgd   ,
          ctc03m00.endbrr   ,
          ctc03m00.endcid   ,
          ctc03m00.endufd   ,
          ctc03m00.endcep   ,
          ctc03m00.endcepcmp,
          ctc03m00.dddcod   ,
          ctc03m00.teltxt   ,
          ctc03m00.factxt
      from   gabkesc
      where  gabkesc.esccod = k_ctc03m00.esccod

   if status = 0   then
      display by name
                 ctc03m00.escnom   ,
                 ctc03m00.rspnom   ,
                 ctc03m00.endlgd   ,
                 ctc03m00.endbrr   ,
                 ctc03m00.endcid   ,
                 ctc03m00.endufd   ,
                 ctc03m00.endcep   ,
                 ctc03m00.endcepcmp,
                 ctc03m00.dddcod   ,
                 ctc03m00.teltxt   ,
                 ctc03m00.factxt
   else
      error "Registro nao Cadastrado!"
      initialize ctc03m00.*    to null
      initialize k_ctc03m00.*  to null
   end if

   return k_ctc03m00.*

end function  # seleciona

#------------------------------------------------------------
function proximo_ctc03m00(k_ctc03m00)
#------------------------------------------------------------

   define  ctc03m00     record
           esccod       like gabkesc.esccod,
           escnom       like gabkesc.escnom,
           rspnom       like gabkesc.rspnom,
           endlgd       like gabkesc.endlgd,
           endbrr       like gabkesc.endbrr,
           endcid       like gabkesc.endcid,
           endufd       like gabkesc.endufd,
           endcep       like gabkesc.endcep,
           endcepcmp    like gabkesc.endcepcmp,
           dddcod       like gabkesc.dddcod,
           teltxt       like gabkesc.teltxt,
           factxt       like gabkesc.factxt
   end record

   define k_ctc03m00    record
          esccod        like gabkesc.esccod
   end record

   select min (gabkesc.esccod)
   into   ctc03m00.esccod
   from   gabkesc
   where
          gabkesc.esccod > k_ctc03m00.esccod

   if  ctc03m00.esccod  is  not  null  then
       let k_ctc03m00.esccod    = ctc03m00.esccod
   end if

   select  esccod   ,
           escnom   ,
           rspnom   ,
           endlgd   ,
           endbrr   ,
           endcid   ,
           endufd   ,
           endcep   ,
           endcepcmp,
           dddcod   ,
           teltxt   ,
           factxt
      into
           ctc03m00.esccod   ,
           ctc03m00.escnom   ,
           ctc03m00.rspnom   ,
           ctc03m00.endlgd   ,
           ctc03m00.endbrr   ,
           ctc03m00.endcid   ,
           ctc03m00.endufd   ,
           ctc03m00.endcep   ,
           ctc03m00.endcepcmp,
           ctc03m00.dddcod   ,
           ctc03m00.teltxt   ,
           ctc03m00.factxt
      from    gabkesc
      where   gabkesc.esccod  =  ctc03m00.esccod

   if status = 0   then
      display by name
                 ctc03m00.esccod   ,
                 ctc03m00.escnom   ,
                 ctc03m00.rspnom   ,
                 ctc03m00.endlgd   ,
                 ctc03m00.endbrr   ,
                 ctc03m00.endcid   ,
                 ctc03m00.endufd   ,
                 ctc03m00.endcep   ,
                 ctc03m00.endcepcmp,
                 ctc03m00.dddcod   ,
                 ctc03m00.teltxt   ,
                 ctc03m00.factxt
   else
      error "Nao ha' mais registro nesta direcao!"
      initialize ctc03m00.*    to null
   end if

   return k_ctc03m00.*

end function    # proximo_ctc03m00

#------------------------------------------------------------
function anterior_ctc03m00(k_ctc03m00)
#------------------------------------------------------------

   define  ctc03m00     record
           esccod       like gabkesc.esccod,
           escnom       like gabkesc.escnom,
           rspnom       like gabkesc.rspnom,
           endlgd       like gabkesc.endlgd,
           endbrr       like gabkesc.endbrr,
           endcid       like gabkesc.endcid,
           endufd       like gabkesc.endufd,
           endcep       like gabkesc.endcep,
           endcepcmp    like gabkesc.endcepcmp,
           dddcod       like gabkesc.dddcod,
           teltxt       like gabkesc.teltxt,
           factxt       like gabkesc.factxt
   end record

   define k_ctc03m00    record
          esccod        like gabkesc.esccod
   end record

   let int_flag = false

   select max (gabkesc.esccod)
   into   ctc03m00.esccod
   from   gabkesc
   where
          gabkesc.esccod < k_ctc03m00.esccod

   if  ctc03m00.esccod  is  not  null  then
       let k_ctc03m00.esccod    = ctc03m00.esccod
   end if

   select  esccod   ,
           escnom   ,
           rspnom   ,
           endlgd   ,
           endbrr   ,
           endcid   ,
           endufd   ,
           endcep   ,
           endcepcmp,
           dddcod   ,
           teltxt   ,
           factxt
      into
           ctc03m00.esccod   ,
           ctc03m00.escnom   ,
           ctc03m00.rspnom   ,
           ctc03m00.endlgd   ,
           ctc03m00.endbrr   ,
           ctc03m00.endcid   ,
           ctc03m00.endufd   ,
           ctc03m00.endcep   ,
           ctc03m00.endcepcmp,
           ctc03m00.dddcod   ,
           ctc03m00.teltxt   ,
           ctc03m00.factxt
      from   gabkesc
      where  gabkesc.esccod  =  ctc03m00.esccod

   if status = 0   then
      display by name
                 ctc03m00.esccod   ,
                 ctc03m00.escnom   ,
                 ctc03m00.rspnom   ,
                 ctc03m00.endlgd   ,
                 ctc03m00.endbrr   ,
                 ctc03m00.endcid   ,
                 ctc03m00.endufd   ,
                 ctc03m00.endcep   ,
                 ctc03m00.endcepcmp,
                 ctc03m00.dddcod   ,
                 ctc03m00.teltxt   ,
                 ctc03m00.factxt
   else
      error "Nao ha' mais registro nesta direcao!"
      initialize ctc03m00.*    to null
   end if

   return k_ctc03m00.*

end function    # anterior_ctc03m00

#------------------------------------------------------------
function modifica_ctc03m00(k_ctc03m00)
#------------------------------------------------------------
# Modifica registros na tabela
#

   define  ctc03m00     record
           esccod       like gabkesc.esccod,
           escnom       like gabkesc.escnom,
           rspnom       like gabkesc.rspnom,
           endlgd       like gabkesc.endlgd,
           endbrr       like gabkesc.endbrr,
           endcid       like gabkesc.endcid,
           endufd       like gabkesc.endufd,
           endcep       like gabkesc.endcep,
           endcepcmp    like gabkesc.endcepcmp,
           dddcod       like gabkesc.dddcod,
           teltxt       like gabkesc.teltxt,
           factxt       like gabkesc.factxt
   end record

   define k_ctc03m00    record
          esccod        like gabkesc.esccod
   end record

   select esccod   ,
          escnom   ,
          rspnom   ,
          endlgd   ,
          endbrr   ,
          endcid   ,
          endufd   ,
          endcep   ,
          endcepcmp,
          dddcod   ,
          teltxt   ,
          factxt
      into
          ctc03m00.esccod   ,
          ctc03m00.escnom   ,
          ctc03m00.rspnom   ,
          ctc03m00.endlgd   ,
          ctc03m00.endbrr   ,
          ctc03m00.endcid   ,
          ctc03m00.endufd   ,
          ctc03m00.endcep   ,
          ctc03m00.endcepcmp,
          ctc03m00.dddcod   ,
          ctc03m00.teltxt   ,
          ctc03m00.factxt
      from    gabkesc
      where   gabkesc.esccod  =  k_ctc03m00.esccod

   call input_ctc03m00("a", k_ctc03m00.* , ctc03m00.*) returning ctc03m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc03m00.*  to null
      error "Operacao cancelada!"
      clear form
      return k_ctc03m00.*
   end if

   whenever error continue

   initialize wprepare to null

   let wprepare    = "update gabkesc set ( ",
                     "escnom, ",
                     "rspnom, ",
                     "endlgd, ",
                     "endbrr, ",
                     "endcid, ",
                     "endufd, ",
                     "endcep, ",
                     "endcepcmp, ",
                     "dddcod, ",
                     "teltxt, ",
                     "factxt, ",
                     "atlmat, ",
                     "atldat  ",
                     ") = ( ",
                     "? , ",
                     "? , ",
                     "? , ",
                     "? , ",
                     "? , ",
                     "? , ",
                     "? , ",
                     "? , ",
                     "? , ",
                     "? , ",
                     "? , ",
                     "? , ",
                     "?   ",
                     ") ",
           "where "  ,
                     "gabkesc.esccod = ?"

   begin work
    prepare comando_aux1 from wprepare

    execute comando_aux1 using
                              ctc03m00.escnom   ,
                              ctc03m00.rspnom   ,
                              ctc03m00.endlgd   ,
                              ctc03m00.endbrr   ,
                              ctc03m00.endcid   ,
                              ctc03m00.endufd   ,
                              ctc03m00.endcep   ,
                              ctc03m00.endcepcmp,
                              ctc03m00.dddcod   ,
                              ctc03m00.teltxt   ,
                              ctc03m00.factxt   ,
                              g_issk.funmat     ,
                              wdata             ,
                              k_ctc03m00.esccod

   if status <>  0  then
      error "Erro na Alteracao do Registro, AVISE A INFORMATICA!"
      rollback work
      initialize ctc03m00.*   to null
      initialize k_ctc03m00.* to null
      return k_ctc03m00.*
   else
      error "Alteracao efetuada com sucesso!"
   end if

   whenever error stop

   commit work

   clear form
   message ""

   return k_ctc03m00.*

end function

#--------------------------------------------------------------------
function remove_ctc03m00(k_ctc03m00)
#--------------------------------------------------------------------

   define  ctc03m00     record
           esccod       like gabkesc.esccod,
           escnom       like gabkesc.escnom,
           rspnom       like gabkesc.rspnom,
           endlgd       like gabkesc.endlgd,
           endbrr       like gabkesc.endbrr,
           endcid       like gabkesc.endcid,
           endufd       like gabkesc.endufd,
           endcep       like gabkesc.endcep,
           endcepcmp    like gabkesc.endcepcmp,
           dddcod       like gabkesc.dddcod,
           teltxt       like gabkesc.teltxt,
           factxt       like gabkesc.factxt
   end record

   define k_ctc03m00    record
          esccod        like gabkesc.esccod
   end record

   menu "Confirma Exclusao ?"

      command "Nao" "Cancela exclusao do registro."
              clear form
              initialize ctc03m00.*   to null
              initialize k_ctc03m00.* to null
              error "Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui registro"
              call sel_ctc03m00(k_ctc03m00.*) returning ctc03m00.*

              if status = notfound  then
                 initialize ctc03m00.*   to null
                 initialize k_ctc03m00.* to null
                 error "Registro nao localizado!"
              else
                 initialize wprepare to null

                 let wprepare = "delete from gabkesc ",
                                "where ",
                                "gabkesc.esccod = ?"

                 begin work
                   prepare comando_aux2 from wprepare

                   execute comando_aux2 using k_ctc03m00.esccod

                   if status <>  0  then
                      error "Erro na Exclusao do Registro, AVISE A INFORMATICA!"
                      rollback work
                      initialize ctc03m00.*   to null
                      initialize k_ctc03m00.* to null
                      return k_ctc03m00.*
                   end if

                 commit work

                 initialize ctc03m00.*   to null
                 initialize k_ctc03m00.* to null
                 error   "Registro excluido!"
                 message ""
                 clear form
              end if
              exit menu
   end menu

   return k_ctc03m00.*

end function    # remove_ctc03m00

#------------------------------------------------------------
function inclui_ctc03m00()
#------------------------------------------------------------
# Inclui registros na tabela
#
   define  ctc03m00     record
           esccod       like gabkesc.esccod,
           escnom       like gabkesc.escnom,
           rspnom       like gabkesc.rspnom,
           endlgd       like gabkesc.endlgd,
           endbrr       like gabkesc.endbrr,
           endcid       like gabkesc.endcid,
           endufd       like gabkesc.endufd,
           endcep       like gabkesc.endcep,
           endcepcmp    like gabkesc.endcepcmp,
           dddcod       like gabkesc.dddcod,
           teltxt       like gabkesc.teltxt,
           factxt       like gabkesc.factxt
   end record

   define k_ctc03m00    record
          esccod        like gabkesc.esccod
   end record

   clear form

   initialize ctc03m00.*   to null
   initialize k_ctc03m00.* to null

   call input_ctc03m00("i",k_ctc03m00.*, ctc03m00.*) returning ctc03m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc03m00.*  to null
      error "Operacao cancelada!"
      clear form
      return
   end if

   whenever error continue

   if g_hostname = "u07" then
      declare c_xgral cursor with hold for
           select grlinf
           from   igbkgeral
           where
                  igbkgeral.mducod = "GKP"   and
                  igbkgeral.grlchv = "ESCRITORIO"
           for update

      foreach c_xgral into k_ctc03m00.esccod
          exit foreach
      end foreach

      if k_ctc03m00.esccod is null then
         begin work
          initialize wprepare to null

          let wprepare =  "insert into igbkgeral ",
                          "(mducod, grlchv, grlinf, atlult) ",
                          "values ",
                          "('GKP', 'ESCRITORIO', '0', wdata) "

          prepare comando_aux5 from wprepare

          execute comando_aux5

          if status <> 0 then
             error "Erro na criacao do igbkgeral. AVISE A INFORMATICA!"
             rollback work
             return
          end if

          commit work

          let k_ctc03m00.esccod = 0
      end if

      begin work
       declare i_xgral cursor with hold for
               select grlinf
               from   igbkgeral
               where
                      igbkgeral.mducod = "GKP"   and
                      igbkgeral.grlchv = "ESCRITORIO"
               for update

       foreach i_xgral into k_ctc03m00.esccod
         let k_ctc03m00.esccod = k_ctc03m00.esccod + 1

         initialize wprepare to null

         let wprepare       =    "insert into gabkesc ( ",
                                 "esccod, ",
                                 "escnom, ",
                                 "rspnom, ",
                                 "endlgd, ",
                                 "endbrr, ",
                                 "endcid, ",
                                 "endufd, ",
                                 "endcep, ",
                                 "endcepcmp, ",
                                 "dddcod, ",
                                 "teltxt, ",
                                 "factxt, ",
                                 "atlmat, ",
                                 "atldat " ,
                                ")",
                        " values ( ",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ",
                                " )"

         prepare comando_aux3 from wprepare

         execute comando_aux3 using
                                   k_ctc03m00.esccod,
                                   ctc03m00.escnom,
                                   ctc03m00.rspnom,
                                   ctc03m00.endlgd,
                                   ctc03m00.endbrr,
                                   ctc03m00.endcid,
                                   ctc03m00.endufd,
                                   ctc03m00.endcep,
                                   ctc03m00.endcepcmp,
                                   ctc03m00.dddcod,
                                   ctc03m00.teltxt,
                                   ctc03m00.factxt,
                                   g_issk.funmat ,
                                   wdata

         if status <>  0  then
            error "Erro na Inclusao do Registro, AVISE A INFORMATICA!"
            rollback work
            return
         end if

         initialize wprepare to null

         let wprepare = "update igbkgeral ",
                        "set (grlinf, atlult) = ",
                        "(? , ?) ",
                        "where ",
                        "igbkgeral.mducod = 'GKP'  and ",
                        "igbkgeral.grlchv = 'ESCRITORIO'"

         prepare comando_aux4 from wprepare

         execute comando_aux4 using k_ctc03m00.esccod,
                                    wdata

         if status <>  0  then
            error "Erro na Inclusao do Registro, AVISE A INFORMATICA!"
            rollback work
            return
         end if

         whenever error stop

         commit work

         exit foreach

       end foreach
  else
      declare c_xgral1 cursor with hold for
           select grlinf
           from   porto@u01:igbkgeral x
           where
                  x.mducod = "GKP"   and
                  x.grlchv = "ESCRITORIO"

      foreach c_xgral1 into k_ctc03m00.esccod
          exit foreach
      end foreach

      if k_ctc03m00.esccod is null then
         begin work
          initialize wprepare to null

          let wprepare =  "insert into porto@u01:igbkgeral ",
                          "(mducod, grlchv, grlinf, atlult) ",
                          "values ",
                          "('GKP', 'ESCRITORIO', '0', wdata) "

          prepare comando_aux6 from wprepare

          execute comando_aux6

          if status <> 0 then
             error "Erro na criacao do igbkgeral. AVISE A INFORMATICA!"
             rollback work
             return
          end if

          commit work

          let k_ctc03m00.esccod = 0
      end if

      begin work
       declare i_xgral1 cursor with hold for
               select grlinf
               from   porto@u01:igbkgeral x
               where
                      x.mducod = "GKP"   and
                      x.grlchv = "ESCRITORIO"
               for update

       foreach i_xgral1 into k_ctc03m00.esccod
         let k_ctc03m00.esccod = k_ctc03m00.esccod + 1

         initialize wprepare to null

         let wprepare       =    "insert into gabkesc ( ",
                                 "esccod, ",
                                 "escnom, ",
                                 "rspnom, ",
                                 "endlgd, ",
                                 "endbrr, ",
                                 "endcid, ",
                                 "endufd, ",
                                 "endcep, ",
                                 "endcepcmp, ",
                                 "dddcod, ",
                                 "teltxt, ",
                                 "factxt, ",
                                 "atlmat, ",
                                 "atldat " ,
                                ")",
                        " values ( ",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ,",
                                 "? ",
                                " )"

         prepare comando_aux7 from wprepare

         execute comando_aux7 using
                                   k_ctc03m00.esccod,
                                   ctc03m00.escnom,
                                   ctc03m00.rspnom,
                                   ctc03m00.endlgd,
                                   ctc03m00.endbrr,
                                   ctc03m00.endcid,
                                   ctc03m00.endufd,
                                   ctc03m00.endcep,
                                   ctc03m00.endcepcmp,
                                   ctc03m00.dddcod,
                                   ctc03m00.teltxt,
                                   ctc03m00.factxt,
                                   g_issk.funmat ,
                                   wdata

         if status <>  0  then
            error "Erro na Inclusao do Registro, AVISE A INFORMATICA!"
            rollback work
            return
         end if

         initialize wprepare to null

         let wprepare = "update porto@u01:igbkgeral ",
                        "set (grlinf, atlult) = ",
                        "(? , ?) ",
                        "where ",
                        "mducod = 'GKP'  and ",
                        "grlchv = 'ESCRITORIO'"

         prepare comando_aux8 from wprepare

         execute comando_aux8 using k_ctc03m00.esccod,
                                    wdata

         if status <>  0  then
            error "Erro na Inclusao do Registro, AVISE A INFORMATICA!"
            rollback work
            return
         end if

         whenever error stop

         commit work

         exit foreach

       end foreach
  end if

  let ctc03m00.esccod = k_ctc03m00.esccod

  display by name  ctc03m00.esccod attribute (reverse)
  error "Verifique o codigo do escritorio e tecle ENTER!"
  prompt "" for char wresp
  error "Inclusao efetuada com sucesso!"

  clear form

end function

#--------------------------------------------------------------------
function input_ctc03m00(operacao_aux, k_ctc03m00, ctc03m00)
#--------------------------------------------------------------------

   define  ctc03m00     record
           esccod       like gabkesc.esccod,
           escnom       like gabkesc.escnom,
           rspnom       like gabkesc.rspnom,
           endlgd       like gabkesc.endlgd,
           endbrr       like gabkesc.endbrr,
           endcid       like gabkesc.endcid,
           endufd       like gabkesc.endufd,
           endcep       like gabkesc.endcep,
           endcepcmp    like gabkesc.endcepcmp,
           dddcod       like gabkesc.dddcod,
           teltxt       like gabkesc.teltxt,
           factxt       like gabkesc.factxt
   end record

   define k_ctc03m00    record
          esccod        like gabkesc.esccod
   end record

   define w_retlgd       char(40)
   define w_contador     decimal(6,0)
   define operacao_aux   char (1)

   let int_flag = false

   input by name
            ctc03m00.escnom   ,
            ctc03m00.rspnom   ,
            ctc03m00.endlgd   ,
            ctc03m00.endbrr   ,
            ctc03m00.endcid   ,
            ctc03m00.endufd   ,
            ctc03m00.endcep   ,
            ctc03m00.endcepcmp,
            ctc03m00.dddcod   ,
            ctc03m00.teltxt   ,
            ctc03m00.factxt
   without defaults


   before field escnom
          display by name ctc03m00.escnom attribute (reverse)

   after  field escnom
          display by name ctc03m00.escnom

   before field rspnom
          display by name ctc03m00.rspnom attribute (reverse)

   after  field rspnom
          display by name ctc03m00.rspnom

   before field endlgd
          display by name ctc03m00.endlgd attribute (reverse)

   after  field endlgd
          display by name ctc03m00.endlgd

   before field endbrr
          display by name ctc03m00.endbrr attribute (reverse)

   after  field endbrr
          display by name ctc03m00.endbrr

   before field endcid
          display by name ctc03m00.endcid attribute (reverse)

   after  field endcid
          display by name ctc03m00.endcid

   before field endufd
          display by name ctc03m00.endufd attribute (reverse)

   after  field endufd
          display by name ctc03m00.endufd

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             select ufdcod
             from   glakest
             where  glakest.ufdcod = ctc03m00.endufd

             if status = notfound  then
                error "Unidade Federativa nao Cadastrada!"
                next field endufd
             end if
          end if

   before field endcep
          display by name ctc03m00.endcep attribute (reverse)

   after  field endcep
          display by name ctc03m00.endcep

          if fgl_lastkey()    <>     fgl_keyval("up")   and
             fgl_lastkey()    <>     fgl_keyval("left") then

             let w_contador   =      0

             select  count(*)
               into  w_contador
               from  glakcid
               where glakcid.cidcep  =  ctc03m00.endcep

             if w_contador           =  0  then
                let w_contador       =  0

                select  count(*)
                  into  w_contador
                  from  glaklgd
                  where glaklgd.lgdcep  =  ctc03m00.endcep

                if w_contador =         0  then

                   call  C24GERAL_TRATSTR(ctc03m00.endlgd, 40)
                                          returning  w_retlgd

                   error "Cep nao cadastrado - Consulte pelo logradouro!"

                   call  ctn11c02(ctc03m00.endufd,ctc03m00.endcid,w_retlgd)
                                          returning ctc03m00.endcep,
                                                    ctc03m00.endcepcmp

                   if ctc03m00.endcep is null then
                      error "Ver cep por cidade - Consulte!"

                      call  ctn11c03(ctc03m00.endcid)
                                             returning ctc03m00.endcep
                   end if

                   next  field endcep
                end if
             end if
          end if

   before field endcepcmp
          display by name ctc03m00.endcepcmp attribute (reverse)

   after  field endcepcmp
          display by name ctc03m00.endcepcmp

   before field dddcod
          display by name ctc03m00.dddcod attribute (reverse)

   after  field dddcod
          display by name ctc03m00.dddcod

   before field teltxt
          display by name ctc03m00.teltxt attribute (reverse)

   after  field teltxt
          display by name ctc03m00.teltxt

   before field factxt
          display by name ctc03m00.factxt attribute (reverse)

   after  field factxt
          display by name ctc03m00.factxt

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctc03m00.*  to null
      return ctc03m00.*
   end if

   return ctc03m00.*

end function   # input_ctc03m00

#---------------------------------------------------------
function sel_ctc03m00(k_ctc03m00)
#---------------------------------------------------------

   define  ctc03m00     record
           esccod       like gabkesc.esccod,
           escnom       like gabkesc.escnom,
           rspnom       like gabkesc.rspnom,
           endlgd       like gabkesc.endlgd,
           endbrr       like gabkesc.endbrr,
           endcid       like gabkesc.endcid,
           endufd       like gabkesc.endufd,
           endcep       like gabkesc.endcep,
           endcepcmp    like gabkesc.endcepcmp,
           dddcod       like gabkesc.dddcod,
           teltxt       like gabkesc.teltxt,
           factxt       like gabkesc.factxt
   end record

   define k_ctc03m00    record
          esccod        like gabkesc.esccod
   end record

   select *
      into   ctc03m00.*
      from   gabkesc
      where  gabkesc.esccod = k_ctc03m00.esccod

   return ctc03m00.*

end function   # sel_ctc03m00
