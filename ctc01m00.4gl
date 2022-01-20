###########################################################################
# Nome do Modulo: CTC01M00                                          Pedro #
#                                                                   Fabio #
# Manutencao no Cadastro de Distrito Policial e Batalhoes        Ago/1994 #
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
function ctc01m00()
#------------------------------------------------------------
# Menu do modulo
# --------------

   define  ctc01m00     record
           battip       like dpakbat.battip,
           batcod       like dpakbat.batnum,
           batnom       like dpakbat.batnom,
           endlgd       like dpakbat.endlgd,
           endbrr       like dpakbat.endbrr,
           endcid       like dpakbat.endcid,
           endufd       like dpakbat.endufd,
           endcep       like dpakbat.endcep,
           endcepcmp    like dpakbat.endcepcmp,
           dddcod       like dpakbat.dddcod,
           teltxt       like dpakbat.teltxt,
           atldat       like dpakbat.atldat
   end record

   define k_ctc01m00    record
          battip        like dpakbat.battip,
          batcod        like dpakbat.batnum
   end record

   define aux_tipdes     char (9)

   #PSI 202290
   #if not get_niv_mod(g_issk.prgsgl, "ctc01m00") then
   #   error "Modulo sem nivel de consulta e atualizacao!"
   #   return
   #end if

   let int_flag = false

   initialize ctc01m00.*   to  null
   initialize k_ctc01m00.* to  null

   open window ctc01m00 at 4,2 with form "ctc01m00"

   menu "D_POLICIAL/BATALHOES"

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
            call seleciona_ctc01m00() returning k_ctc01m00.*
            if k_ctc01m00.batcod is not null  then
               message ""
               next option "Proximo"
            else
               error "Nenhum registro selecionado!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo registro selecionado"
            message ""
            if k_ctc01m00.batcod is not null then
               call proximo_ctc01m00(k_ctc01m00.*)
                    returning k_ctc01m00.*
            else
               error "Nenhum registro nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra registro anterior selecionado"
            message ""
            if k_ctc01m00.batcod is not null then
               call anterior_ctc01m00(k_ctc01m00.*)
                    returning k_ctc01m00.*
            else
               error "Nenhum registro nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica registro corrente selecionado"
            message ""
            if k_ctc01m00.batcod is not null then
               call modifica_ctc01m00(k_ctc01m00.*)
                    returning k_ctc01m00.*
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Remove" "Remove registro corrente selecionado"
            message ""
            if k_ctc01m00.batcod is not null then
               call remove_ctc01m00(k_ctc01m00.*)
                    returning k_ctc01m00.*
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui registro na tabela"
            message ""
            call inclui_ctc01m00()
            next option "Seleciona"

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc01m00

end function  # ctc01m00

#------------------------------------------------------------
function seleciona_ctc01m00()
#------------------------------------------------------------

   define  ctc01m00   record
           battip       like dpakbat.battip,
           batcod       like dpakbat.batnum,
           batnom       like dpakbat.batnom,
           endlgd       like dpakbat.endlgd,
           endbrr       like dpakbat.endbrr,
           endcid       like dpakbat.endcid,
           endufd       like dpakbat.endufd,
           endcep       like dpakbat.endcep,
           endcepcmp    like dpakbat.endcepcmp,
           dddcod       like dpakbat.dddcod,
           teltxt       like dpakbat.teltxt,
           atldat       like dpakbat.atldat
   end record

   define k_ctc01m00    record
          battip        like dpakbat.battip,
          batcod        like dpakbat.batnum
   end record

   define aux_tipdes     char (9)

   clear form

   let int_flag = false

   input by name k_ctc01m00.battip,
                 k_ctc01m00.batcod

      before field battip
          display by name k_ctc01m00.battip attribute (reverse)

      after  field battip
          display by name k_ctc01m00.battip

          if k_ctc01m00.battip = "B"  then
             let aux_tipdes = "BATALHAO"
             display "Batalhao"       to descricao
          else
             if k_ctc01m00.battip = "D"  then
                let aux_tipdes = "DPOLICIAL"
                display "D. Policial"    to descricao
             else
                error "Item obrigatorio mesmo p/ consulta!"
                next field battip
             end if
          end if

      before field batcod
          display by name k_ctc01m00.batcod attribute (reverse)

          if k_ctc01m00.batcod is null then
             let k_ctc01m00.batcod = 0
          end if

      after  field batcod
          display by name k_ctc01m00.batcod

      on key (interrupt)
          exit input

   end input

   if int_flag  then
      let int_flag = false
      initialize ctc01m00.* to null
      error "Operacao cancelada!"
      clear form
      return k_ctc01m00.*
   end if

   if k_ctc01m00.batcod  =  0 then
      select min (dpakbat.batnum)
      into   k_ctc01m00.batcod
      from   dpakbat
      where  dpakbat.battip = k_ctc01m00.battip  and
             dpakbat.batnum > 0

      display by name k_ctc01m00.batcod
   end if

   select
      battip   ,
      batnum   ,
      batnom   ,
      endlgd   ,
      endbrr   ,
      endcid   ,
      endufd   ,
      endcep   ,
      endcepcmp,
      dddcod   ,
      teltxt   ,
      atldat
      into   ctc01m00.*
      from   dpakbat
      where  dpakbat.battip = k_ctc01m00.battip   and
             dpakbat.batnum = k_ctc01m00.batcod

   if status = 0   then
      display by name
                 ctc01m00.batnom,
                 ctc01m00.endlgd,
                 ctc01m00.endbrr,
                 ctc01m00.endcid,
                 ctc01m00.endufd,
                 ctc01m00.endcep,
                 ctc01m00.endcepcmp,
                 ctc01m00.dddcod,
                 ctc01m00.teltxt,
                 ctc01m00.atldat
   else
      error "Registro nao Cadastrado!"
      initialize ctc01m00.*    to null
      initialize k_ctc01m00.*  to null
   end if

   return k_ctc01m00.*

end function  # seleciona

#------------------------------------------------------------
function proximo_ctc01m00(k_ctc01m00)
#------------------------------------------------------------

   define  ctc01m00   record
           battip       like dpakbat.battip,
           batcod       like dpakbat.batnum,
           batnom       like dpakbat.batnom,
           endlgd       like dpakbat.endlgd,
           endbrr       like dpakbat.endbrr,
           endcid       like dpakbat.endcid,
           endufd       like dpakbat.endufd,
           endcep       like dpakbat.endcep,
           endcepcmp    like dpakbat.endcepcmp,
           dddcod       like dpakbat.dddcod,
           teltxt       like dpakbat.teltxt,
           atldat       like dpakbat.atldat
   end record

   define k_ctc01m00    record
          battip        like dpakbat.battip,
          batcod        like dpakbat.batnum
   end record

   define aux_tipdes     char (9)

   select min (dpakbat.batnum)
   into   ctc01m00.batcod
   from   dpakbat
   where
          dpakbat.battip = k_ctc01m00.battip   and
          dpakbat.batnum > k_ctc01m00.batcod

   if  ctc01m00.batcod  is  not  null  then
       let k_ctc01m00.batcod    = ctc01m00.batcod
   end if

   select
      battip   ,
      batnum   ,
      batnom   ,
      endlgd   ,
      endbrr   ,
      endcid   ,
      endufd   ,
      endcep   ,
      endcepcmp,
      dddcod   ,
      teltxt   ,
      atldat
      into    ctc01m00.*
      from    dpakbat
      where   dpakbat.battip  =  k_ctc01m00.battip  and
              dpakbat.batnum  =  ctc01m00.batcod

   if status = 0   then
      display by name
                 ctc01m00.battip,
                 ctc01m00.batcod,
                 ctc01m00.batnom,
                 ctc01m00.endlgd,
                 ctc01m00.endbrr,
                 ctc01m00.endcid,
                 ctc01m00.endufd,
                 ctc01m00.endcep,
                 ctc01m00.endcepcmp,
                 ctc01m00.dddcod,
                 ctc01m00.teltxt,
                 ctc01m00.atldat
   else
      error "Nao ha' mais registro nesta direcao!"
      initialize ctc01m00.*    to null
   end if

   return k_ctc01m00.*

end function    # proximo_ctc01m00

#------------------------------------------------------------
function anterior_ctc01m00(k_ctc01m00)
#------------------------------------------------------------

   define  ctc01m00     record
           battip       like dpakbat.battip,
           batcod       like dpakbat.batnum,
           batnom       like dpakbat.batnom,
           endlgd       like dpakbat.endlgd,
           endbrr       like dpakbat.endbrr,
           endcid       like dpakbat.endcid,
           endufd       like dpakbat.endufd,
           endcep       like dpakbat.endcep,
           endcepcmp    like dpakbat.endcepcmp,
           dddcod       like dpakbat.dddcod,
           teltxt       like dpakbat.teltxt,
           atldat       like dpakbat.atldat
   end record

   define k_ctc01m00    record
          battip        like dpakbat.battip,
          batcod        like dpakbat.batnum
   end record

   define aux_tipdes     char (9)

   let int_flag = false

   select max (dpakbat.batnum)
   into   ctc01m00.batcod
   from   dpakbat
   where
          dpakbat.batnum < k_ctc01m00.batcod   and
          dpakbat.battip = k_ctc01m00.battip

   if  ctc01m00.batcod  is  not  null  then
       let k_ctc01m00.batcod    = ctc01m00.batcod
   end if

   select
      battip   ,
      batnum   ,
      batnom   ,
      endlgd   ,
      endbrr   ,
      endcid   ,
      endufd   ,
      endcep   ,
      endcepcmp,
      dddcod   ,
      teltxt   ,
      atldat
      into   ctc01m00.*
      from   dpakbat
      where  dpakbat.battip  =  k_ctc01m00.battip  and
             dpakbat.batnum  =  ctc01m00.batcod

   if status = 0   then
      display by name
                 ctc01m00.battip,
                 ctc01m00.batcod,
                 ctc01m00.batnom,
                 ctc01m00.endlgd,
                 ctc01m00.endbrr,
                 ctc01m00.endcid,
                 ctc01m00.endufd,
                 ctc01m00.endcep,
                 ctc01m00.endcepcmp,
                 ctc01m00.dddcod,
                 ctc01m00.teltxt,
                 ctc01m00.atldat
   else
      error "Nao ha' mais registro nesta direcao!"
      initialize ctc01m00.*    to null
   end if

   return k_ctc01m00.*

end function    # anterior_ctc01m00

#------------------------------------------------------------
function modifica_ctc01m00(k_ctc01m00)
#------------------------------------------------------------
# Modifica registros na tabela
#

   define  ctc01m00     record
           battip       like dpakbat.battip,
           batcod       like dpakbat.batnum,
           batnom       like dpakbat.batnom,
           endlgd       like dpakbat.endlgd,
           endbrr       like dpakbat.endbrr,
           endcid       like dpakbat.endcid,
           endufd       like dpakbat.endufd,
           endcep       like dpakbat.endcep,
           endcepcmp    like dpakbat.endcepcmp,
           dddcod       like dpakbat.dddcod,
           teltxt       like dpakbat.teltxt,
           atldat       like dpakbat.atldat
   end record

   define k_ctc01m00    record
          battip        like dpakbat.battip,
          batcod        like dpakbat.batnum
   end record

   select
      battip   ,
      batnum   ,
      batnom   ,
      endlgd   ,
      endbrr   ,
      endcid   ,
      endufd   ,
      endcep   ,
      endcepcmp,
      dddcod   ,
      teltxt   ,
      atldat
      into    ctc01m00.*
      from    dpakbat
      where   dpakbat.battip  =  k_ctc01m00.battip  and
              dpakbat.batnum  =  k_ctc01m00.batcod

   call input_ctc01m00("a", k_ctc01m00.* , ctc01m00.*) returning ctc01m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc01m00.*  to null
      error "Operacao cancelada!"
      clear form
      return k_ctc01m00.*
   end if

   whenever error continue

   let ctc01m00.atldat = today

   begin work
   update dpakbat set  (
                        batnom   ,
                        endlgd   ,
                        endbrr   ,
                        endcid   ,
                        endufd   ,
                        endcep   ,
                        endcepcmp,
                        dddcod   ,
                        teltxt   ,
                        atldat
                       )
               =       (
                        ctc01m00.batnom   ,
                        ctc01m00.endlgd   ,
                        ctc01m00.endbrr   ,
                        ctc01m00.endcid   ,
                        ctc01m00.endufd   ,
                        ctc01m00.endcep   ,
                        ctc01m00.endcepcmp,
                        ctc01m00.dddcod   ,
                        ctc01m00.teltxt   ,
                        ctc01m00.atldat
                       )
               where
                        dpakbat.batnum   =   k_ctc01m00.batcod  and
                        dpakbat.battip   =   k_ctc01m00.battip

   if status <>  0  then
      error "Erro na Alteracao do Registro!"
      rollback work
      initialize ctc01m00.*   to null
      initialize k_ctc01m00.* to null
      return k_ctc01m00.*
   else
      error "Alteracao efetuada com sucesso!"
   end if

   whenever error stop

   commit work

   clear form
   message ""

   return k_ctc01m00.*

end function

#--------------------------------------------------------------------
function remove_ctc01m00(k_ctc01m00)
#--------------------------------------------------------------------

   define  ctc01m00   record
           battip       like dpakbat.battip,
           batcod       like dpakbat.batnum,
           batnom       like dpakbat.batnom,
           endlgd       like dpakbat.endlgd,
           endbrr       like dpakbat.endbrr,
           endcid       like dpakbat.endcid,
           endufd       like dpakbat.endufd,
           endcep       like dpakbat.endcep,
           endcepcmp    like dpakbat.endcepcmp,
           dddcod       like dpakbat.dddcod,
           teltxt       like dpakbat.teltxt,
           atldat       like dpakbat.atldat
   end record

   define k_ctc01m00    record
          battip        like dpakbat.battip,
          batcod        like dpakbat.batnum
   end record

   define aux_tipdes  char(9)

   menu "Confirma Exclusao ?"

      command "Nao" "Cancela exclusao do registro."
              clear form
              initialize ctc01m00.*   to null
              initialize k_ctc01m00.* to null
              error "Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui registro"
              call sel_ctc01m00(k_ctc01m00.*) returning ctc01m00.*

              if status = notfound  then
                 initialize ctc01m00.*   to null
                 initialize k_ctc01m00.* to null
                 error "Registro nao localizado!"
              else
                 begin work
                 delete from dpakbat
                        where dpakbat.batnum = k_ctc01m00.batcod  and
                              dpakbat.battip = k_ctc01m00.battip
                 commit work
                 initialize ctc01m00.*   to null
                 initialize k_ctc01m00.* to null
                 error   "Registro excluido!"
                 message ""
                 clear form
              end if
              exit menu
   end menu

   return k_ctc01m00.*

end function    # remove_ctc01m00

#------------------------------------------------------------
function inclui_ctc01m00()
#------------------------------------------------------------
# Inclui registros na tabela
#
   define  ctc01m00   record
           battip       like dpakbat.battip,
           batcod       like dpakbat.batnum,
           batnom       like dpakbat.batnom,
           endlgd       like dpakbat.endlgd,
           endbrr       like dpakbat.endbrr,
           endcid       like dpakbat.endcid,
           endufd       like dpakbat.endufd,
           endcep       like dpakbat.endcep,
           endcepcmp    like dpakbat.endcepcmp,
           dddcod       like dpakbat.dddcod,
           teltxt       like dpakbat.teltxt,
           atldat       like dpakbat.atldat
   end record

   define k_ctc01m00    record
          battip        like dpakbat.battip,
          batcod        like dpakbat.batnum
   end record

   define aux_tipdes    char(9)

   clear form

   initialize ctc01m00.*   to null
   initialize k_ctc01m00.* to null

   call input_ctc01m00("i",k_ctc01m00.*, ctc01m00.*) returning ctc01m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc01m00.*  to null
      error "Operacao cancelada!"
      clear form
      return
   end if

   whenever error continue

   let k_ctc01m00.battip = ctc01m00.battip
   let ctc01m00.atldat   = today
   let aux_tipdes        = "DPOLICIAL"

   if k_ctc01m00.battip  = "B" then
      let aux_tipdes     = "BATALHAO"
   end if

   declare c_xgral cursor with hold for
           select  grlinf
           from    igbkgeral
           where   igbkgeral.mducod = "C24"      and
                   igbkgeral.grlchv = aux_tipdes
           for update

   foreach c_xgral into k_ctc01m00.batcod
       exit foreach
   end foreach

   if k_ctc01m00.batcod is null then
      begin work
        insert into igbkgeral
                    (mducod, grlchv, grlinf, atlult)
               values
                    ("C24", aux_tipdes , "0", today)

        if status <> 0 then
           error "Erro na criacao do igbkgeral, AVISE A INFORMATICA!"
           rollback work
           return
        end if

     commit work

     let k_ctc01m00.batcod = 0
   end if

   begin work
    declare i_xgral cursor with hold for
            select  grlinf
            from    igbkgeral
            where   igbkgeral.mducod = "C24"  and
                    igbkgeral.grlchv = aux_tipdes
            for update

    foreach i_xgral into k_ctc01m00.batcod
      let k_ctc01m00.batcod = k_ctc01m00.batcod + 1
      let ctc01m00.batcod   = k_ctc01m00.batcod

      insert into dpakbat (
                           battip   ,
                           batnum   ,
                           batnom   ,
                           endlgd   ,
                           endbrr   ,
                           endcid   ,
                           endufd   ,
                           endcep   ,
                           endcepcmp,
                           dddcod   ,
                           teltxt   ,
                           atldat
                          )
                  values  (
                           ctc01m00.battip   ,
                           ctc01m00.batcod   ,
                           ctc01m00.batnom   ,
                           ctc01m00.endlgd   ,
                           ctc01m00.endbrr   ,
                           ctc01m00.endcid   ,
                           ctc01m00.endufd   ,
                           ctc01m00.endcep   ,
                           ctc01m00.endcepcmp,
                           ctc01m00.dddcod   ,
                           ctc01m00.teltxt   ,
                           ctc01m00.atldat
                          )

      if status <>  0  then
         error "Erro na Inclusao do Registro, AVISE A INFORMATICA!"
         rollback work
         return
      end if

      update igbkgeral
             set (grlinf         , atlult) =
                 (ctc01m00.batcod, today)
             where
                   igbkgeral.mducod = "C24"  and
                   igbkgeral.grlchv = aux_tipdes

      if status <>  0  then
         error "Erro na alteracao do igbkgeral, AVISE A INFORMATICA!"
         rollback work
         return
      end if

      whenever error stop

      commit work

      exit foreach

    end foreach

    display by name ctc01m00.batcod attribute (reverse)
    error "Verifique o codigo do registro e tecle ENTER!"
    prompt "" for char wresp
    error "Inclusao efetuada com sucesso!"

    clear form

end function

#--------------------------------------------------------------------
function input_ctc01m00(operacao_aux, k_ctc01m00, ctc01m00)
#--------------------------------------------------------------------

   define  ctc01m00   record
           battip       like dpakbat.battip,
           batcod       like dpakbat.batnum,
           batnom       like dpakbat.batnom,
           endlgd       like dpakbat.endlgd,
           endbrr       like dpakbat.endbrr,
           endcid       like dpakbat.endcid,
           endufd       like dpakbat.endufd,
           endcep       like dpakbat.endcep,
           endcepcmp    like dpakbat.endcepcmp,
           dddcod       like dpakbat.dddcod,
           teltxt       like dpakbat.teltxt,
           atldat       like dpakbat.atldat
   end record

   define k_ctc01m00    record
          battip        like dpakbat.battip,
          batcod        like dpakbat.batnum
   end record

   define aux_tipdes     char (9),
          operacao_aux   char (1)

   define w_contador     decimal(6,0)
   define w_retlgd       char(40)

   let int_flag = false

   input by name
            ctc01m00.battip,
            ctc01m00.batcod,
            ctc01m00.batnom,
            ctc01m00.endlgd,
            ctc01m00.endbrr,
            ctc01m00.endcid,
            ctc01m00.endufd,
            ctc01m00.endcep,
            ctc01m00.endcepcmp,
            ctc01m00.dddcod,
            ctc01m00.teltxt
   without defaults

   before field battip
          if  operacao_aux  =  "a"  then
              next field batnom
          end if
          display by name ctc01m00.battip attribute (reverse)

   after field battip
          display by name ctc01m00.battip

          if ctc01m00.battip       = "B"         then
             let aux_tipdes        = "BATALHAO"
             let k_ctc01m00.battip = "B"
             display "Batalhao"       to descricao
          else
             let aux_tipdes        = "DPOLICIAL"
             let k_ctc01m00.battip = "D"
             display "D. Policial"    to descricao
          end if

          next field batnom

   before field batnom
          display by name ctc01m00.batnom attribute (reverse)

   after  field batnom
          display by name ctc01m00.batnom

   before field endlgd
          display by name ctc01m00.endlgd attribute (reverse)

   after  field endlgd
          display by name ctc01m00.endlgd

   before field endbrr
          display by name ctc01m00.endbrr attribute (reverse)

   after  field endbrr
          display by name ctc01m00.endbrr

   before field endcid
          display by name ctc01m00.endcid attribute (reverse)

   after  field endcid
          display by name ctc01m00.endcid

   before field endufd
          display by name ctc01m00.endufd attribute (reverse)

   after  field endufd
          display by name ctc01m00.endufd

          if fgl_lastkey() <> fgl_keyval ("up")    and
             fgl_lastkey() <> fgl_keyval ("left")  then
             select ufdcod
               from   glakest
               where  glakest.ufdcod = ctc01m00.endufd

               if status = notfound  then
                  error "Unidade Federativa nao Cadastrada!"
                  next field endufd
               end if
          end if

   before field endcep
          display by name ctc01m00.endcep attribute (reverse)

   after  field endcep
          display by name ctc01m00.endcep
          if fgl_lastkey()    <>     fgl_keyval("up")   and
             fgl_lastkey()    <>     fgl_keyval("left") then

             let w_contador   =      0

             select  count(*)
               into  w_contador
               from  glakcid
               where glakcid.cidcep  =  ctc01m00.endcep

             if w_contador           =  0  then
                let w_contador       =  0

                select  count(*)
                  into  w_contador
                  from  glaklgd
                  where glaklgd.lgdcep  =  ctc01m00.endcep

                if w_contador =         0  then

                   call  C24GERAL_TRATSTR(ctc01m00.endlgd, 40)
                                          returning  w_retlgd

                   error "Cep nao cadastrado - Consulte pelo logradouro!"

                   call  ctn11c02(ctc01m00.endufd,ctc01m00.endcid,w_retlgd)
                                          returning ctc01m00.endcep,
                                                    ctc01m00.endcepcmp

                   if ctc01m00.endcep is null then
                      error "Ver cep por cidade - Consulte!"

                      call  ctn11c03(ctc01m00.endcid)
                                             returning ctc01m00.endcep
                   end if

                   next  field endcep
                end if
             end if
          end if

   before field endcepcmp
          display by name ctc01m00.endcepcmp attribute (reverse)

   after  field endcepcmp
          display by name ctc01m00.endcepcmp

   before field dddcod
          display by name ctc01m00.dddcod attribute (reverse)

   after  field dddcod
          display by name ctc01m00.dddcod

   before field teltxt
          display by name ctc01m00.teltxt attribute (reverse)

   after  field teltxt
          display by name ctc01m00.teltxt

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctc01m00.*  to null
      return ctc01m00.*
   end if

   return ctc01m00.*

end function   # input_ctc01m00

#---------------------------------------------------------
function sel_ctc01m00(k_ctc01m00)
#---------------------------------------------------------

   define  ctc01m00   record
           battip     like dpakbat.battip,
           batcod     like dpakbat.batnum,
           batnom     like dpakbat.batnom,
           endlgd     like dpakbat.endlgd,
           endbrr     like dpakbat.endbrr,
           endcid     like dpakbat.endcid,
           endufd     like dpakbat.endufd,
           endcep     like dpakbat.endcep,
           endcepcmp  like dpakbat.endcepcmp,
           dddcod     like dpakbat.dddcod,
           teltxt     like dpakbat.teltxt,
           atldat     like dpakbat.atldat
   end record

   define k_ctc01m00  record
          battip      like dpakbat.battip,
          batcod      like dpakbat.batnum
   end record

   define aux_tipdes   char (9)

   let aux_tipdes = "DPOLICIAL"

   if k_ctc01m00.battip = "B"  then
      let aux_tipdes = "BATALHAO"
   end if

   select
      battip   ,
      batnum   ,
      batnom   ,
      endlgd   ,
      endbrr   ,
      endcid   ,
      endufd   ,
      endcep   ,
      endcepcmp,
      dddcod   ,
      teltxt   ,
      atldat
      into   ctc01m00.*
      from   dpakbat
      where  dpakbat.batnum = k_ctc01m00.batcod and
             dpakbat.battip = k_ctc01m00.battip

   return ctc01m00.*

end function   # sel_ctc01m00
