###########################################################################
# Nome do Modulo: CTC23M00                                        Marcelo #
#                                                                Gilberto #
# Manutencao na Agenda de telefones (Nome)                       Fev/1996 #
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

#------------------------------------------------------------
function ctc23m00()
#------------------------------------------------------------
# Menu do modulo
# --------------

   define  ctc23m00     record
           pescod       like datkpesagetel.pescod ,
           pesnom       like datkpesagetel.pesnom ,
           pesobs       like datkpesagetel.pesobs
   end record

   define k_ctc23m00    record
          pescod        like datkpesagetel.pescod
   end record

   #PSI 202290
   #if not get_niv_mod(g_issk.prgsgl, "ctc23m00") then
   #   error "Modulo sem nivel de consulta e atualizacao!"
   #   return
   #end if

   let int_flag = false

   initialize ctc23m00.*   to  null
   initialize k_ctc23m00.* to  null

   open window ctc23m00 at 4,2 with form "ctc23m00"

   menu "AGENDA FONES"

       before menu
          hide option all
          #PSI 202290
          #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
          #      show option "Seleciona", "Proximo", "Anterior", "Pesquisa"
          #end if
          #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica", "Remove", "Inclui", "Pesquisa"
          #end if

          show option "Encerra"

   command "Seleciona" "Seleciona registro na tabela conforme criterios"
            call seleciona_ctc23m00(k_ctc23m00.*) returning k_ctc23m00.*
            if k_ctc23m00.pescod is not null  then
               message ""
               next option "Proximo"
            else
               error "Nenhum registro selecionado!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo registro selecionado"
            message ""
            if k_ctc23m00.pescod is not null then
               call proximo_ctc23m00(k_ctc23m00.*)  returning k_ctc23m00.*
            else
               error "Nenhum registro nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra registro anterior selecionado"
            message ""
            if k_ctc23m00.pescod is not null then
               call anterior_ctc23m00(k_ctc23m00.*)  returning k_ctc23m00.*
            else
               error "Nenhum registro nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica registro corrente selecionado"
            message ""
            if k_ctc23m00.pescod is not null then
               call modifica_ctc23m00(k_ctc23m00.*)  returning k_ctc23m00.*
               initialize ctc23m00.*   to  null
               initialize k_ctc23m00.* to  null
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Remove" "Remove registro corrente selecionado"
            message ""
            if k_ctc23m00.pescod is not null then
               call remove_ctc23m00(k_ctc23m00.*)  returning k_ctc23m00.*
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui registro na tabela"
            message ""
            call inclui_ctc23m00()
            initialize ctc23m00.*   to  null
            initialize k_ctc23m00.* to  null

   command key ("Q") "pesQuisa" "Pesquisa nome na agenda"
            message ""
            call ctc23m02()  returning k_ctc23m00.pescod
            message " Selecione e tecle ENTER "  attribute(reverse)
            next option "Seleciona"

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc23m00

end function  # ctc23m00

#------------------------------------------------------------
function seleciona_ctc23m00(k_ctc23m00)
#------------------------------------------------------------

   define  ctc23m00   record
           pescod     like datkpesagetel.pescod ,
           pesnom     like datkpesagetel.pesnom ,
           pesobs     like datkpesagetel.pesobs
   end record

   define k_ctc23m00  record
          pescod      like datkpesagetel.pescod
   end record


   clear form
   let int_flag = false

   input by name k_ctc23m00.pescod  without defaults

      before field pescod
          display by name k_ctc23m00.pescod attribute (reverse)

          if k_ctc23m00.pescod is null then
             let k_ctc23m00.pescod = 0
          end if

      after  field pescod
          display by name k_ctc23m00.pescod

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctc23m00.* to null
      error "Operacao cancelada!"
      clear form
      return k_ctc23m00.*
   end if

   if k_ctc23m00.pescod  =  0 then
      select min (datkpesagetel.pescod)
        into k_ctc23m00.pescod
        from datkpesagetel
       where datkpesagetel.pescod > k_ctc23m00.pescod
   end if

   select pescod, pesnom, pesobs
     into ctc23m00.pescod, ctc23m00.pesnom, ctc23m00.pesobs
     from datkpesagetel
    where datkpesagetel.pescod = k_ctc23m00.pescod

   if status = 0   then
      display by name  ctc23m00.pescod, ctc23m00.pesnom, ctc23m00.pesobs
      call display_ctc23m00(k_ctc23m00.pescod)
   else
      error "Registro nao Cadastrado!"
      initialize ctc23m00.*    to null
      initialize k_ctc23m00.*  to null
   end if

   return k_ctc23m00.*

end function  # seleciona

#------------------------------------------------------------
function proximo_ctc23m00(k_ctc23m00)
#------------------------------------------------------------

   define  ctc23m00   record
           pescod     like datkpesagetel.pescod ,
           pesnom     like datkpesagetel.pesnom ,
           pesobs     like datkpesagetel.pesobs
   end record

   define k_ctc23m00  record
           pescod     like datkpesagetel.pescod
   end record

   select min (datkpesagetel.pescod)
     into ctc23m00.pescod
     from datkpesagetel
    where datkpesagetel.pescod > k_ctc23m00.pescod

   if  ctc23m00.pescod  is not null  then
       let k_ctc23m00.pescod = ctc23m00.pescod

       select pescod, pesnom, pesobs
         into ctc23m00.pescod, ctc23m00.pesnom, ctc23m00.pesobs
         from datkpesagetel
        where datkpesagetel.pescod = k_ctc23m00.pescod

       if status = 0   then
          display by name  ctc23m00.pescod, ctc23m00.pesnom, ctc23m00.pesobs
          call display_ctc23m00(k_ctc23m00.pescod)
       else
          error "Nao ha' mais registro nesta direcao!"
          initialize ctc23m00.*    to null
       end if
   else
      error "Nao ha' mais registro nesta direcao!"
      initialize ctc23m00.*    to null
   end if

   return k_ctc23m00.*

end function    # proximo_ctc23m00

#------------------------------------------------------------
function anterior_ctc23m00(k_ctc23m00)
#------------------------------------------------------------

   define  ctc23m00   record
           pescod     like datkpesagetel.pescod ,
           pesnom     like datkpesagetel.pesnom ,
           pesobs     like datkpesagetel.pesobs
   end record

   define  k_ctc23m00 record
           pescod     like datkpesagetel.pescod
   end record


   select max(datkpesagetel.pescod)
     into ctc23m00.pescod
     from datkpesagetel
    where datkpesagetel.pescod < k_ctc23m00.pescod

   if  ctc23m00.pescod  is not  null  then
       let k_ctc23m00.pescod = ctc23m00.pescod

       select pescod, pesnom, pesobs
         into ctc23m00.pescod, ctc23m00.pesnom, ctc23m00.pesobs
         from datkpesagetel
        where datkpesagetel.pescod = k_ctc23m00.pescod

       if status = 0   then
          display by name  ctc23m00.pescod, ctc23m00.pesnom, ctc23m00.pesobs
          call display_ctc23m00(k_ctc23m00.pescod)
       else
          error "Nao ha' mais registro nesta direcao!"
          initialize ctc23m00.*    to null
       end if
   else
      error "Nao ha' mais registro nesta direcao!"
      initialize ctc23m00.*    to null
   end if

   return k_ctc23m00.*

end function    # anterior_ctc23m00

#------------------------------------------------------------
function modifica_ctc23m00(k_ctc23m00)
#------------------------------------------------------------
# Modifica registros na tabela
#

   define  ctc23m00   record
           pescod     like datkpesagetel.pescod ,
           pesnom     like datkpesagetel.pesnom ,
           pesobs     like datkpesagetel.pesobs
   end record

   define k_ctc23m00  record
           pescod     like datkpesagetel.pescod
   end record

   select pescod, pesnom, pesobs
     into ctc23m00.pescod, ctc23m00.pesnom, ctc23m00.pesobs
     from datkpesagetel
    where datkpesagetel.pescod = k_ctc23m00.pescod

   call input_ctc23m00("a", k_ctc23m00.* , ctc23m00.*) returning ctc23m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc23m00.*  to null
      error "Operacao cancelada!"
      clear form
      return k_ctc23m00.*
   end if

   whenever error continue

   begin work
   update datkpesagetel set  ( pesnom, pesobs )
                        =    ( ctc23m00.pesnom, ctc23m00.pesobs )
                 where
                     datkpesagetel.pescod  =  k_ctc23m00.pescod

   whenever error stop

   commit work

   if status <>  0  then
      error "Erro na Alteracao do Registro!"
      rollback work
      initialize ctc23m00.*   to null
      initialize k_ctc23m00.* to null
      return k_ctc23m00.*
   else
      call ctc23m01("a", k_ctc23m00.pescod, ctc23m00.pesnom, ctc23m00.pesobs)
   end if

   clear form
   message ""

   return k_ctc23m00.*

end function

#--------------------------------------------------------------------
function remove_ctc23m00(k_ctc23m00)
#--------------------------------------------------------------------

   define  ctc23m00   record
           pescod     like datkpesagetel.pescod ,
           pesnom     like datkpesagetel.pesnom ,
           pesobs     like datkpesagetel.pesobs
   end record

   define k_ctc23m00  record
           pescod     like datkpesagetel.pescod
   end record


   menu "Confirma Exclusao ?"

      command "Nao" "Cancela exclusao do nome na agenda"
              clear form
              initialize ctc23m00.*   to null
              initialize k_ctc23m00.* to null
              error "Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui nome da agenda"
              call sel_ctc23m00(k_ctc23m00.*) returning ctc23m00.*

              if status = notfound  then
                 initialize ctc23m00.*   to null
                 initialize k_ctc23m00.* to null
                 error "Registro nao localizado!"
              else
                 begin work
                    delete from datkpesagetel
                           where datkpesagetel.pescod = k_ctc23m00.pescod

                    delete from datkagendatel
                           where datkagendatel.pescod = k_ctc23m00.pescod
                 commit work

                 if status <>  0  then
                    error "Erro na Remocao do Registro!"
                    rollback work
                 else
                    error  "Registro removido!"
                 end if

                 initialize ctc23m00.*   to null
                 initialize k_ctc23m00.* to null
                 message ""
                 clear form
              end if
              exit menu
   end menu

   return k_ctc23m00.*

end function    # remove_ctc23m00

#------------------------------------------------------------
function inclui_ctc23m00()
#------------------------------------------------------------
# Inclui registros na tabela
#
   define  ctc23m00   record
           pescod     like datkpesagetel.pescod ,
           pesnom     like datkpesagetel.pesnom ,
           pesobs     like datkpesagetel.pesobs
   end record

   define k_ctc23m00  record
           pescod     like datkpesagetel.pescod
   end record

   clear form

   initialize ctc23m00.*   to null
   initialize k_ctc23m00.* to null

   call input_ctc23m00("i",k_ctc23m00.*, ctc23m00.*) returning ctc23m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc23m00.*  to null
      error "Operacao cancelada!"
      clear form
      return
   end if

   call ctc23m01("i", k_ctc23m00.pescod, ctc23m00.pesnom, ctc23m00.pesobs)

   clear form

end function

#--------------------------------------------------------------------
function input_ctc23m00(operacao_aux, k_ctc23m00, ctc23m00)
#--------------------------------------------------------------------
   define operacao_aux   char (1)

   define  ctc23m00   record
           pescod     like datkpesagetel.pescod ,
           pesnom     like datkpesagetel.pesnom ,
           pesobs     like datkpesagetel.pesobs
   end record

   define  k_ctc23m00 record
           pescod     like datkpesagetel.pescod
   end record

   define  w_cont    integer

   let int_flag = false

   input by name ctc23m00.pesnom,
                 ctc23m00.pesobs    without defaults

   before field pesnom
          display by name ctc23m00.pesnom attribute (reverse)

   after field pesnom
          display by name ctc23m00.pesnom

          if ctc23m00.pesnom[1,1]  is null  or
             ctc23m00.pesnom[1,1]  = " "    then
             error " Primeira posicao do nome nao pode ser espaco !!"
             next field pesnom
          end if

          if ctc23m00.pesnom[1,1]  = "0"    or
             ctc23m00.pesnom[1,1]  = "1"    or
             ctc23m00.pesnom[1,1]  = "2"    or
             ctc23m00.pesnom[1,1]  = "3"    or
             ctc23m00.pesnom[1,1]  = "4"    or
             ctc23m00.pesnom[1,1]  = "5"    or
             ctc23m00.pesnom[1,1]  = "6"    or
             ctc23m00.pesnom[1,1]  = "7"    or
             ctc23m00.pesnom[1,1]  = "8"    or
             ctc23m00.pesnom[1,1]  = "9"    then
             error " Primeira posicao do nome nao pode ser um numero !!"
             next field pesnom
          end if

          let w_cont = 0
          let w_cont = length(ctc23m00.pesnom)
          if w_cont  <  4   then
             error " Nome nao pode possuir menos que 4 letras !!"
             next field pesnom
          end if

          if operacao_aux  =  "i"   then
             select * from datkpesagetel
              where pesnom = ctc23m00.pesnom

             if status  =  0   then
                error " Nome ja' cadastrado na agenda !!"
                next field pesnom
             end if
          end if

   before field pesobs
          display by name ctc23m00.pesobs attribute (reverse)

   after field pesobs
          display by name ctc23m00.pesobs

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctc23m00.*  to null
      return ctc23m00.*
   end if

   return ctc23m00.*

end function   # input_ctc23m00

#---------------------------------------------------------
function sel_ctc23m00(k_ctc23m00)
#---------------------------------------------------------

   define  ctc23m00   record
           pescod     like datkpesagetel.pescod ,
           pesnom     like datkpesagetel.pesnom ,
           pesobs     like datkpesagetel.pesobs
   end record

   define  k_ctc23m00 record
           pescod     like datkpesagetel.pescod
   end record


   select pescod, pesnom, pesobs
     into ctc23m00.pescod, ctc23m00.pesnom, ctc23m00.pesobs
     from datkpesagetel
    where datkpesagetel.pescod = k_ctc23m00.pescod

   return ctc23m00.*

end function   # sel_ctc23m00

#---------------------------------------------------------------
 function display_ctc23m00(par_pescod)
#---------------------------------------------------------------
   define par_pescod like datkpesagetel.pescod

   define a_ctc23m00 array[09] of record
      teltipcod      like datkagendatel.teltipcod ,
      teltipdes      char(09)                     ,
      dddcod         like datkagendatel.dddcod    ,
      telnum         like datkagendatel.telnum    ,
      rmlnum         like datkagendatel.rmlnum    ,
      bipnum         like datkagendatel.bipnum
   end record

   define arr_aux      integer

   declare c_ctc23m00 cursor for
      select teltipcod, dddcod, telnum, rmlnum, bipnum
       from datkagendatel
      where pescod = par_pescod

   initialize a_ctc23m00  to null
   let arr_aux = 1

   foreach c_ctc23m00 into a_ctc23m00[arr_aux].teltipcod ,
                           a_ctc23m00[arr_aux].dddcod    ,
                           a_ctc23m00[arr_aux].telnum    ,
                           a_ctc23m00[arr_aux].rmlnum    ,
                           a_ctc23m00[arr_aux].bipnum

      call tipo_ctc23m00(a_ctc23m00[arr_aux].teltipcod)
           returning a_ctc23m00[arr_aux].teltipdes

      let arr_aux = arr_aux + 1
      if arr_aux > 09 then
         error " Limite excedido, nome com mais de 09 telefones"
         exit foreach
      end if
   end foreach

  for arr_aux = 01 to 09
      display a_ctc23m00[arr_aux].teltipcod to s_ctc23m00[arr_aux].teltipcod
      display a_ctc23m00[arr_aux].teltipdes to s_ctc23m00[arr_aux].teltipdes
      display a_ctc23m00[arr_aux].dddcod    to s_ctc23m00[arr_aux].dddcod
      display a_ctc23m00[arr_aux].telnum    to s_ctc23m00[arr_aux].telnum
      display a_ctc23m00[arr_aux].rmlnum    to s_ctc23m00[arr_aux].rmlnum
      display a_ctc23m00[arr_aux].bipnum    to s_ctc23m00[arr_aux].bipnum
  end for

end function  #  display_ctc23m00

#---------------------------------------------------------------
 function tipo_ctc23m00(par_teltipcod)
#---------------------------------------------------------------
   define par_teltipcod  like datkagendatel.teltipcod
   define ret_teltipdes  char(09)

   case par_teltipcod
        when  1
           let ret_teltipdes = "TELEFONE"
        when  2
           let ret_teltipdes = "FAX"
        when  3
           let ret_teltipdes = "BIP"
        when  4
           let ret_teltipdes = "CELULAR"
        otherwise
           let ret_teltipdes = "N/PREVISTO"
   end case

   return ret_teltipdes

end function  #  teltipcod_ctc23m00

