###########################################################################
# Nome do Modulo: CTC05M00                                          Pedro #
#                                                                         #
# Manutencao no Cadastro de Inspetorias                          Out/1994 #
###########################################################################
#                                                                         #
#                  * * * Alteracoes * * *                                 #
#                                                                         #
# Data        Autor Fabrica  Origem    Alteracao                          #
# ----------  -------------- --------- ---------------------------------- #
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso#
#-------------------------------------------------------------------------#
# 20/08/2007  Luiz, Meta     AS146056  Inclusao da chamada da funcao      #
#                                      figrc012                           #
#-------------------------------------------------------------------------#

database porto
globals "/homedsa/projetos/geral/globals/figrc012.4gl"
globals "/homedsa/projetos/geral/globals/glct.4gl"

define wdata        date      ,
       wprepare     char (700),
       wresp        char (001)

define m_host       like ibpkdbspace.srvnom #Humberto
define l_sql        char (500)
define l_sql1       char (500)
#------------------------------------------------------------
function ctc05m00()
#------------------------------------------------------------
# Menu do modulo
# --------------

   define  ctc05m00     record
           iptcod       like gabkins.iptcod,
           iptnom       like gabkins.iptnom,
           rspnom       like gabkins.rspnom,
           endlgd       like gabkins.endlgd,
           endbrr       like gabkins.endbrr,
           endcid       like gabkins.endcid,
           endufd       like gabkins.endufd,
           endcep       like gabkins.endcep,
           endcepcmp    like gabkins.endcepcmp,
           dddcod       like gabkins.dddcod,
           teltxt       like gabkins.teltxt,
           tlxtxt       like gabkins.tlxtxt,
           factxt       like gabkins.factxt,
           atlult       like gabkins.atlult
   end record

   define k_ctc05m00    record
          iptcod        like gabkins.iptcod
   end record

   #PSI 202290
   #if not get_niv_mod(g_issk.prgsgl, "ctc05m00") then
   #   error "Modulo sem nivel de consulta e atualizacao!"
   #   return
   #end if

   open window ctc05m00 at 4,2 with form "ctc05m00"

   let int_flag = false
   let wdata    = today

   initialize ctc05m00.*   to  null
   initialize k_ctc05m00.* to  null

   menu "INSPETORIAS"
       before menu
          hide option all
         #PSI 202290
         #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior"
          #end if
          #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
          #      show option "Seleciona", "Proximo", "Anterior"
          #           #####  "Modifica", "Remove", "Inclui"
          #end if

          show option "Encerra"

   command "Seleciona" "Pesquisa tabela conforme criterios"
            call seleciona_ctc05m00() returning k_ctc05m00.*
            if k_ctc05m00.iptcod is not null  then
               message ""
               next option "Proximo"
            else
               error "Nenhum registro selecionado!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo registro selecionado"
            message ""
            if k_ctc05m00.iptcod is not null then
               call proximo_ctc05m00(k_ctc05m00.*)
                    returning k_ctc05m00.*
            else
               error "Nao ha' mais registro nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra registro anterior selecionado"
            message ""
            if k_ctc05m00.iptcod is not null then
               call anterior_ctc05m00(k_ctc05m00.*)
                    returning k_ctc05m00.*
            else
               error "Nao ha' mais registro nesta direcao!"
               next option "Seleciona"
            end if

 ##command "Modifica" "Modifica registro corrente selecionado"
 ##         message ""
 ##         if k_ctc05m00.iptcod is not null then
 ##            call modifica_ctc05m00(k_ctc05m00.*)
 ##                 returning k_ctc05m00.*
 ##            next option "Seleciona"
 ##         else
 ##            error "Nenhum registro selecionado!"
 ##            next option "Seleciona"
 ##         end if
 ##
 ##command "Remove" "Remove registro corrente selecionado"
 ##         message ""
 ##         if k_ctc05m00.iptcod is not null then
 ##            call remove_ctc05m00(k_ctc05m00.*)
 ##                 returning k_ctc05m00.*
 ##            next option "Seleciona"
 ##         else
 ##            error "Nenhum registro selecionado!"
 ##            next option "Seleciona"
 ##         end if
 ##
 ##command "Inclui" "Inclui registro na tabela"
 ##          message ""
 ##          call inclui_ctc05m00()
 ##          next option "Seleciona"

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc05m00

end function  # ctc05m00

#------------------------------------------------------------
function seleciona_ctc05m00()
#------------------------------------------------------------

   define  ctc05m00     record
           iptcod       like gabkins.iptcod,
           iptnom       like gabkins.iptnom,
           rspnom       like gabkins.rspnom,
           endlgd       like gabkins.endlgd,
           endbrr       like gabkins.endbrr,
           endcid       like gabkins.endcid,
           endufd       like gabkins.endufd,
           endcep       like gabkins.endcep,
           endcepcmp    like gabkins.endcepcmp,
           dddcod       like gabkins.dddcod,
           teltxt       like gabkins.teltxt,
           tlxtxt       like gabkins.tlxtxt,
           factxt       like gabkins.factxt,
           atlult       like gabkins.atlult
   end record

   define k_ctc05m00    record
          iptcod        like gabkins.iptcod
   end record

   define aux_atlult    char(49)
   define aux_flag      char(49)

   clear form

   let int_flag = false

   input by name k_ctc05m00.iptcod

      before field iptcod
          display by name k_ctc05m00.iptcod attribute (reverse)

          if k_ctc05m00.iptcod is null then
             let k_ctc05m00.iptcod = 0
          end if

      after  field iptcod
          display by name k_ctc05m00.iptcod

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctc05m00.* to null
      error "Operacao cancelada!"
      clear form
      return k_ctc05m00.*
   end if

   if k_ctc05m00.iptcod = 0 then
      select min (gabkins.iptcod)
      into   k_ctc05m00.iptcod
      from   gabkins
      where  gabkins.iptcod > 0

      display by name k_ctc05m00.iptcod
   end if

   select
                 iptnom   ,
                 rspnom   ,
                 endlgd   ,
                 endbrr   ,
                 endcid   ,
                 endufd   ,
                 endcep   ,
                 endcepcmp,
                 dddcod   ,
                 teltxt   ,
                 tlxtxt   ,
                 factxt   ,
                 atlult
      into
                 ctc05m00.iptnom   ,
                 ctc05m00.rspnom   ,
                 ctc05m00.endlgd   ,
                 ctc05m00.endbrr   ,
                 ctc05m00.endcid   ,
                 ctc05m00.endufd   ,
                 ctc05m00.endcep   ,
                 ctc05m00.endcepcmp,
                 ctc05m00.dddcod   ,
                 ctc05m00.teltxt   ,
                 ctc05m00.tlxtxt   ,
                 ctc05m00.factxt   ,
                 ctc05m00.atlult
      from   gabkins
      where  gabkins.iptcod = k_ctc05m00.iptcod

   if status = 0   then
      let aux_atlult      = F_FUNGERAL_ATLULT_MSG(ctc05m00.atlult)
      let ctc05m00.atlult = aux_atlult

      display by name
                 ctc05m00.iptnom   ,
                 ctc05m00.rspnom   ,
                 ctc05m00.endlgd   ,
                 ctc05m00.endbrr   ,
                 ctc05m00.endcid   ,
                 ctc05m00.endufd   ,
                 ctc05m00.endcep   ,
                 ctc05m00.endcepcmp,
                 ctc05m00.dddcod   ,
                 ctc05m00.teltxt   ,
                 ctc05m00.tlxtxt   ,
                 ctc05m00.factxt

    # display aux_atlult to atlult
    #             attribute (reverse)
   else
      error "Registro nao Cadastrado!"
      initialize ctc05m00.*    to null
      initialize k_ctc05m00.*  to null
   end if

   return k_ctc05m00.*

end function  # seleciona

#------------------------------------------------------------
function proximo_ctc05m00(k_ctc05m00)
#------------------------------------------------------------

   define  ctc05m00     record
           iptcod       like gabkins.iptcod,
           iptnom       like gabkins.iptnom,
           rspnom       like gabkins.rspnom,
           endlgd       like gabkins.endlgd,
           endbrr       like gabkins.endbrr,
           endcid       like gabkins.endcid,
           endufd       like gabkins.endufd,
           endcep       like gabkins.endcep,
           endcepcmp    like gabkins.endcepcmp,
           dddcod       like gabkins.dddcod,
           teltxt       like gabkins.teltxt,
           tlxtxt       like gabkins.tlxtxt,
           factxt       like gabkins.factxt,
           atlult       like gabkins.atlult
   end record

   define k_ctc05m00    record
          iptcod        like gabkins.iptcod
   end record

   define aux_flag      char(49)

   select min (gabkins.iptcod)
   into   ctc05m00.iptcod
   from   gabkins
   where
          gabkins.iptcod > k_ctc05m00.iptcod

   if  ctc05m00.iptcod  is  not  null  then
       let k_ctc05m00.iptcod    = ctc05m00.iptcod
   end if

   select
                 iptcod   ,
                 iptnom   ,
                 rspnom   ,
                 endlgd   ,
                 endbrr   ,
                 endcid   ,
                 endufd   ,
                 endcep   ,
                 endcepcmp,
                 dddcod   ,
                 teltxt   ,
                 tlxtxt   ,
                 factxt   ,
                 atlult
      into
                 ctc05m00.iptcod   ,
                 ctc05m00.iptnom   ,
                 ctc05m00.rspnom   ,
                 ctc05m00.endlgd   ,
                 ctc05m00.endbrr   ,
                 ctc05m00.endcid   ,
                 ctc05m00.endufd   ,
                 ctc05m00.endcep   ,
                 ctc05m00.endcepcmp,
                 ctc05m00.dddcod   ,
                 ctc05m00.teltxt   ,
                 ctc05m00.tlxtxt   ,
                 ctc05m00.factxt   ,
                 ctc05m00.atlult
      from    gabkins
      where   gabkins.iptcod  =  ctc05m00.iptcod

   if status = 0   then
      display by name
                 ctc05m00.iptcod   ,
                 ctc05m00.iptnom   ,
                 ctc05m00.rspnom   ,
                 ctc05m00.endlgd   ,
                 ctc05m00.endbrr   ,
                 ctc05m00.endcid   ,
                 ctc05m00.endufd   ,
                 ctc05m00.endcep   ,
                 ctc05m00.endcepcmp,
                 ctc05m00.dddcod   ,
                 ctc05m00.teltxt   ,
                 ctc05m00.factxt

      display aux_flag to atlult
   else
      error "Nao ha' mais registro nesta direcao!"
      initialize ctc05m00.*    to null
   end if

   return k_ctc05m00.*

end function    # proximo_ctc05m00

#------------------------------------------------------------
function anterior_ctc05m00(k_ctc05m00)
#------------------------------------------------------------

   define  ctc05m00     record
           iptcod       like gabkins.iptcod,
           iptnom       like gabkins.iptnom,
           rspnom       like gabkins.rspnom,
           endlgd       like gabkins.endlgd,
           endbrr       like gabkins.endbrr,
           endcid       like gabkins.endcid,
           endufd       like gabkins.endufd,
           endcep       like gabkins.endcep,
           endcepcmp    like gabkins.endcepcmp,
           dddcod       like gabkins.dddcod,
           teltxt       like gabkins.teltxt,
           tlxtxt       like gabkins.tlxtxt,
           factxt       like gabkins.factxt,
           atlult       like gabkins.atlult
   end record

   define k_ctc05m00    record
          iptcod        like gabkins.iptcod
   end record

   define aux_flag      char(49)

   let int_flag = false

   select max (gabkins.iptcod)
   into   ctc05m00.iptcod
   from   gabkins
   where
          gabkins.iptcod < k_ctc05m00.iptcod

   if  ctc05m00.iptcod  is  not  null  then
       let k_ctc05m00.iptcod    = ctc05m00.iptcod
   end if

   select
                 iptcod   ,
                 iptnom   ,
                 rspnom   ,
                 endlgd   ,
                 endbrr   ,
                 endcid   ,
                 endufd   ,
                 endcep   ,
                 endcepcmp,
                 dddcod   ,
                 teltxt   ,
                 tlxtxt   ,
                 factxt   ,
                 atlult
      into
                 ctc05m00.iptcod   ,
                 ctc05m00.iptnom   ,
                 ctc05m00.rspnom   ,
                 ctc05m00.endlgd   ,
                 ctc05m00.endbrr   ,
                 ctc05m00.endcid   ,
                 ctc05m00.endufd   ,
                 ctc05m00.endcep   ,
                 ctc05m00.endcepcmp,
                 ctc05m00.dddcod   ,
                 ctc05m00.teltxt   ,
                 ctc05m00.tlxtxt   ,
                 ctc05m00.factxt   ,
                 ctc05m00.atlult
      from   gabkins
      where  gabkins.iptcod  =  ctc05m00.iptcod

   if status = 0   then
      display by name
                 ctc05m00.iptcod   ,
                 ctc05m00.iptnom   ,
                 ctc05m00.rspnom   ,
                 ctc05m00.endlgd   ,
                 ctc05m00.endbrr   ,
                 ctc05m00.endcid   ,
                 ctc05m00.endufd   ,
                 ctc05m00.endcep   ,
                 ctc05m00.endcepcmp,
                 ctc05m00.dddcod   ,
                 ctc05m00.teltxt   ,
                 ctc05m00.tlxtxt   ,
                 ctc05m00.factxt

      display aux_flag to atlult
   else
      error "Nao ha' mais registro nesta direcao!"
      initialize ctc05m00.*    to null
   end if

   return k_ctc05m00.*

end function    # anterior_ctc05m00

#------------------------------------------------------------
function modifica_ctc05m00(k_ctc05m00)
#------------------------------------------------------------
# Modifica registros na tabela
#

   define  ctc05m00     record
           iptcod       like gabkins.iptcod,
           iptnom       like gabkins.iptnom,
           rspnom       like gabkins.rspnom,
           endlgd       like gabkins.endlgd,
           endbrr       like gabkins.endbrr,
           endcid       like gabkins.endcid,
           endufd       like gabkins.endufd,
           endcep       like gabkins.endcep,
           endcepcmp    like gabkins.endcepcmp,
           dddcod       like gabkins.dddcod,
           teltxt       like gabkins.teltxt,
           tlxtxt       like gabkins.tlxtxt,
           factxt       like gabkins.factxt,
           atlult       like gabkins.atlult
   end record

   define aux_atlult    char(49)
   define aux_flag      char(49)

   define k_ctc05m00    record
          iptcod        like gabkins.iptcod
   end record

   select
                 iptcod   ,
                 iptnom   ,
                 rspnom   ,
                 endlgd   ,
                 endbrr   ,
                 endcid   ,
                 endufd   ,
                 endcep   ,
                 endcepcmp,
                 dddcod   ,
                 teltxt   ,
                 tlxtxt   ,
                 factxt   ,
                 atlult
      into
                 ctc05m00.iptcod   ,
                 ctc05m00.iptnom   ,
                 ctc05m00.rspnom   ,
                 ctc05m00.endlgd   ,
                 ctc05m00.endbrr   ,
                 ctc05m00.endcid   ,
                 ctc05m00.endufd   ,
                 ctc05m00.endcep   ,
                 ctc05m00.endcepcmp,
                 ctc05m00.dddcod   ,
                 ctc05m00.teltxt   ,
                 ctc05m00.tlxtxt   ,
                 ctc05m00.factxt   ,
                 ctc05m00.atlult
      from    gabkins
      where   gabkins.iptcod  =  k_ctc05m00.iptcod

   display aux_flag to atlult

   call input_ctc05m00(k_ctc05m00.* , ctc05m00.*) returning ctc05m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc05m00.*  to null
      error "Operacao cancelada!"
      clear form
      return k_ctc05m00.*
   end if

   let aux_atlult      = F_FUNGERAL_ATLULT()
   let ctc05m00.atlult = aux_atlult

   whenever error continue

   initialize wprepare to null

   let wprepare    = "update gabkins set ( ",
                     "iptnom, ",
                     "rspnom, ",
                     "endlgd, ",
                     "endbrr, ",
                     "endcid, ",
                     "endufd, ",
                     "endcep, ",
                     "endcepcmp, ",
                     "dddcod, ",
                     "teltxt, ",
                     "tlxtxt, ",
                     "factxt, ",
                     "atlult  ",
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
                     "?  ",
                     ") ",
              "where ",
                     "gabkins.iptcod = ?"

   begin work
    prepare comando_aux1 from wprepare

    execute comando_aux1 using
                         ctc05m00.iptnom   ,
                         ctc05m00.rspnom   ,
                         ctc05m00.endlgd   ,
                         ctc05m00.endbrr   ,
                         ctc05m00.endcid   ,
                         ctc05m00.endufd   ,
                         ctc05m00.endcep   ,
                         ctc05m00.endcepcmp,
                         ctc05m00.dddcod   ,
                         ctc05m00.teltxt   ,
                         ctc05m00.tlxtxt   ,
                         ctc05m00.factxt   ,
                         ctc05m00.atlult   ,
                         k_ctc05m00.iptcod

    if status <>  0  then
      error "Erro na Alteracao do Registro, AVISE A INFORMATICA!"
      rollback work
      initialize ctc05m00.*   to null
      initialize k_ctc05m00.* to null
      return k_ctc05m00.*
   else
      error "Alteracao efetuada com sucesso!"
   end if

   whenever error stop

   commit work

   clear form
   message ""

   return k_ctc05m00.*

end function

#--------------------------------------------------------------------
function remove_ctc05m00(k_ctc05m00)
#--------------------------------------------------------------------

   define  ctc05m00     record
           iptcod       like gabkins.iptcod,
           iptnom       like gabkins.iptnom,
           rspnom       like gabkins.rspnom,
           endlgd       like gabkins.endlgd,
           endbrr       like gabkins.endbrr,
           endcid       like gabkins.endcid,
           endufd       like gabkins.endufd,
           endcep       like gabkins.endcep,
           endcepcmp    like gabkins.endcepcmp,
           dddcod       like gabkins.dddcod,
           teltxt       like gabkins.teltxt,
           tlxtxt       like gabkins.tlxtxt,
           factxt       like gabkins.factxt,
           atlult       like gabkins.atlult
   end record

   define k_ctc05m00    record
          iptcod        like gabkins.iptcod
   end record

   menu "Confirma Exclusao ?"

      command "Nao" "Cancela exclusao do registro."
              clear form
              initialize ctc05m00.*   to null
              initialize k_ctc05m00.* to null
              error "Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui registro"
              call sel_ctc05m00(k_ctc05m00.*) returning ctc05m00.*

              if status = notfound  then
                 initialize ctc05m00.*   to null
                 initialize k_ctc05m00.* to null
                 error "Registro nao localizado!"
              else
                 initialize wprepare to null

                 let wprepare = "delete from gabkins ",
                                "where ",
                                "gabkins.iptcod = ?"

                 begin work
                   prepare comando_aux2 from wprepare

                   execute comando_aux2 using k_ctc05m00.iptcod

                   if status <> 0 then
                      error  "Erro na exclusao do registro, AVISE A INFORMATICA!"
                      rollback work
                      initialize ctc05m00.*   to null
                      initialize k_ctc05m00.* to null
                      return k_ctc05m00.*
                   end if

                 commit work

                 initialize ctc05m00.*   to null
                 initialize k_ctc05m00.* to null
                 error   "Registro excluido!"
                 message ""
                 clear form
              end if
              exit menu
   end menu

   return k_ctc05m00.*

end function    # remove_ctc05m00

#------------------------------------------------------------
function inclui_ctc05m00()
#------------------------------------------------------------
# Inclui registros na tabela
#
   define  ctc05m00     record
           iptcod       like gabkins.iptcod,
           iptnom       like gabkins.iptnom,
           rspnom       like gabkins.rspnom,
           endlgd       like gabkins.endlgd,
           endbrr       like gabkins.endbrr,
           endcid       like gabkins.endcid,
           endufd       like gabkins.endufd,
           endcep       like gabkins.endcep,
           endcepcmp    like gabkins.endcepcmp,
           dddcod       like gabkins.dddcod,
           teltxt       like gabkins.teltxt,
           tlxtxt       like gabkins.tlxtxt,
           factxt       like gabkins.factxt,
           atlult       like gabkins.atlult
   end record

   define aux_atlult    char (49)

   define k_ctc05m00    record
          iptcod        like gabkins.iptcod
   end record

   clear form

   initialize ctc05m00.*   to null
   initialize k_ctc05m00.* to null


   call input_ctc05m00(k_ctc05m00.*, ctc05m00.*) returning ctc05m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc05m00.*  to null
      error "Operacao cancelada!"
      clear form
      return
   end if

   whenever error continue

   let m_host = fun_dba_servidor("EXTRATOR")










   let l_sql = "select grlinf "








              ,"from   porto@",m_host clipped,":igbkgeral x "
              ,"where  x.mducod = 'GKP' "
              ,"and    x.grlchv = 'INSPETORIA' "
   prepare s_xgral1 from l_sql







   declare c_xgral1 cursor with hold for s_xgral1

   open c_xgral1
   foreach c_xgral1 into k_ctc05m00.iptcod
      exit foreach
   end foreach

      if k_ctc05m00.iptcod is null then
         begin work
          initialize wprepare to null

          let wprepare = "insert into porto@",m_host clipped,":igbkgeral ",
                         "(mducod, grlchv, grlinf, atlult) ",
                         "values ",
                         "('GKP', 'INSPETORIA', '0', ?) "

          prepare comando_aux6 from wprepare

          execute comando_aux6 using wdata

          if status <> 0 then
             error "Erro na criacao do igbkgeral, AVISE A INFORMATICA!"
             rollback work
             return
          end if

          commit work

          let k_ctc05m00.iptcod = 0
      end if

      let aux_atlult        = F_FUNGERAL_ATLULT()
      let ctc05m00.atlult   = aux_atlult

      begin work

      let l_sql1 = "select grlinf "
                  ,"from   porto@",m_host clipped,":igbkgeral x "
                  ,"where  x.mducod = 'GKP' "
                  ,"and    x.grlchv = 'INSPETORIA' "
      prepare s_xgral2 from l_sql1
      declare i_xgral1 cursor with hold for s_xgral2
      open i_xgral1

       foreach i_xgral1 into k_ctc05m00.iptcod
         let k_ctc05m00.iptcod = k_ctc05m00.iptcod + 1
         let ctc05m00.iptcod   = k_ctc05m00.iptcod

         initialize wprepare to null

         let wprepare       = "insert into gabkins (",
                              "iptcod,",
                              "iptnom,",
                              "rspnom,",
                              "endlgd,",
                              "endbrr,",
                              "endcid,",
                              "endufd,",
                              "endcep,",
                              "endcepcmp,",
                              "dddcod,",
                              "teltxt,",
                              "tlxtxt,",
                              "factxt,",
                              "atlult" ,
                             ")",
                     " values (",
                              "?,",
                              "?,",
                              "?,",
                              "?,",
                              "?,",
                              "?,",
                              "?,",
                              "?,",
                              "?,",
                              "?,",
                              "?,",
                              "?,",
                              "?,",
                              "?",
                             ")"

         prepare comando_aux7 from wprepare

         execute comando_aux7 using
                               ctc05m00.iptcod   ,
                               ctc05m00.iptnom   ,
                               ctc05m00.rspnom   ,
                               ctc05m00.endlgd   ,
                               ctc05m00.endbrr   ,
                               ctc05m00.endcid   ,
                               ctc05m00.endufd   ,
                               ctc05m00.endcep   ,
                               ctc05m00.endcepcmp,
                               ctc05m00.dddcod   ,
                               ctc05m00.teltxt   ,
                               ctc05m00.tlxtxt   ,
                               ctc05m00.factxt   ,
                               ctc05m00.atlult

         if status <> 0 then
            error "Erro na inclusao da inspetoria, AVISE A INFORMATICA!"
            rollback work
            return
         end if

         initialize wprepare to null

         let wprepare = "update porto@",m_host clipped,":igbkgeral ",
                        "set (grlinf, atlult) = ",
                        "(? , ?) ",
                        "where ",
                        "mducod = 'GKP'  and ",
                        "grlchv = 'INSPETORIA'"

         prepare comando_aux8 from wprepare

         execute comando_aux8 using k_ctc05m00.iptcod,
                                    wdata

         if status <>  0  then
            error "Erro na alteracao do igbkgeral, AVISE A INFORMATICA!"
            rollback work
            return
         end if

         whenever error stop

         commit work

         exit foreach

      end foreach


   display by name ctc05m00.iptcod attribute (reverse)
   error "Verifique o codigo da inspetoria e tecle ENTER!"
   prompt "" for char wresp
   error "Inclusao efetuada com sucesso!"

   clear form

end function

#--------------------------------------------------------------------
function input_ctc05m00(k_ctc05m00, ctc05m00)
#--------------------------------------------------------------------

   define  ctc05m00     record
           iptcod       like gabkins.iptcod,
           iptnom       like gabkins.iptnom,
           rspnom       like gabkins.rspnom,
           endlgd       like gabkins.endlgd,
           endbrr       like gabkins.endbrr,
           endcid       like gabkins.endcid,
           endufd       like gabkins.endufd,
           endcep       like gabkins.endcep,
           endcepcmp    like gabkins.endcepcmp,
           dddcod       like gabkins.dddcod,
           teltxt       like gabkins.teltxt,
           tlxtxt       like gabkins.tlxtxt,
           factxt       like gabkins.factxt,
           atlult       like gabkins.atlult
   end record

   define k_ctc05m00    record
          iptcod        like gabkins.iptcod
   end record

   define w_retlgd       char   (40)
   define w_contador     decimal(6,0)

   let int_flag = false

   input by name
            ctc05m00.iptnom   ,
            ctc05m00.rspnom   ,
            ctc05m00.endlgd   ,
            ctc05m00.endbrr   ,
            ctc05m00.endcid   ,
            ctc05m00.endufd   ,
            ctc05m00.endcep   ,
            ctc05m00.endcepcmp,
            ctc05m00.dddcod   ,
            ctc05m00.teltxt   ,
            ctc05m00.tlxtxt   ,
            ctc05m00.factxt
   without defaults

   before field iptnom
          display by name ctc05m00.iptnom attribute (reverse)

   after  field iptnom
          display by name ctc05m00.iptnom

   before field rspnom
          display by name ctc05m00.rspnom attribute (reverse)

   after  field rspnom
          display by name ctc05m00.rspnom

   before field endlgd
          display by name ctc05m00.endlgd attribute (reverse)

   after  field endlgd
          display by name ctc05m00.endlgd

   before field endbrr
          display by name ctc05m00.endbrr attribute (reverse)

   after  field endbrr
          display by name ctc05m00.endbrr

   before field endcid
          display by name ctc05m00.endcid attribute (reverse)

   after  field endcid
          display by name ctc05m00.endcid

   before field endufd
          display by name ctc05m00.endufd attribute (reverse)

   after  field endufd
          display by name ctc05m00.endufd

          if fgl_lastkey()   <>   fgl_keyval("up")   and
             fgl_lastkey()   <>   fgl_keyval("left") then

             select ufdcod
             from   glakest
             where  glakest.ufdcod = ctc05m00.endufd

             if status = notfound  then
                error "Unidade Federativa nao Cadastrada!"
                next field endufd
             end if
          end if

   before field endcep
          display by name ctc05m00.endcep attribute (reverse)

   after  field endcep
          display by name ctc05m00.endcep

          if fgl_lastkey()    <>     fgl_keyval("up")   and
             fgl_lastkey()    <>     fgl_keyval("left") then

             let w_contador   =      0

             select  count(*)
               into  w_contador
               from  glakcid
               where glakcid.cidcep  =  ctc05m00.endcep

             if w_contador           =  0  then
                let w_contador       =  0

                select  count(*)
                  into  w_contador
                  from  glaklgd
                  where glaklgd.lgdcep  =  ctc05m00.endcep

                if w_contador =         0  then

                   call  C24GERAL_TRATSTR(ctc05m00.endlgd, 40)
                                          returning  w_retlgd

                   error "Cep nao cadastrado - Consulte pelo logradouro!"

                   call  ctn11c02(ctc05m00.endufd,ctc05m00.endcid,w_retlgd)
                                          returning ctc05m00.endcep,
                                                    ctc05m00.endcepcmp

                   if ctc05m00.endcep is null then
                      error "Ver cep por cidade - Consulte!"

                      call  ctn11c03(ctc05m00.endcid)
                                             returning ctc05m00.endcep
                   end if

                   next  field endcep
                end if
             end if
          end if

   before field endcepcmp
          display by name ctc05m00.endcepcmp attribute (reverse)

   after  field endcepcmp
          display by name ctc05m00.endcepcmp

   before field dddcod
          display by name ctc05m00.dddcod attribute (reverse)

   after  field dddcod
          display by name ctc05m00.dddcod

   before field teltxt
          display by name ctc05m00.teltxt attribute (reverse)

   after  field teltxt
          display by name ctc05m00.teltxt

   before field tlxtxt
          display by name ctc05m00.tlxtxt attribute (reverse)

   after  field tlxtxt
          display by name ctc05m00.tlxtxt

   before field factxt
          display by name ctc05m00.factxt attribute (reverse)

   after  field factxt
          display by name ctc05m00.factxt

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctc05m00.*  to null
      return ctc05m00.*
   end if

   return ctc05m00.*

end function   # input_ctc05m00

#---------------------------------------------------------
function sel_ctc05m00(k_ctc05m00)
#---------------------------------------------------------

   define  ctc05m00     record
           iptcod       like gabkins.iptcod,
           iptnom       like gabkins.iptnom,
           rspnom       like gabkins.rspnom,
           endlgd       like gabkins.endlgd,
           endbrr       like gabkins.endbrr,
           endcid       like gabkins.endcid,
           endufd       like gabkins.endufd,
           endcep       like gabkins.endcep,
           endcepcmp    like gabkins.endcepcmp,
           dddcod       like gabkins.dddcod,
           teltxt       like gabkins.teltxt,
           tlxtxt       like gabkins.tlxtxt,
           factxt       like gabkins.factxt,
           atlult       like gabkins.atlult
   end record

   define k_ctc05m00    record
          iptcod        like gabkins.iptcod
   end record

   select *
      into   ctc05m00.*
      from   gabkins
      where  gabkins.iptcod = k_ctc05m00.iptcod

   return ctc05m00.*

end function   # sel_ctc05m00
