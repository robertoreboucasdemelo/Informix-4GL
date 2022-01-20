###########################################################################
# Nome do Modulo: CTC56M00                                           Raji #
#                                                                         #
# Manutencao no Cadastro de textos para clausulas                Fev/2002 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONS. DESCRICAO                             #
#-------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
# 25/09/06   Ligia Mattge  PSI 202720 Implementando grupo/cartao saude    #
###########################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ramgrpcod     like gtakram.ramgrpcod,
         m_status        smallint, 
         m_msg           char(20),
         m_plnatnlimnum  smallint

#------------------------------------------------------------
 function ctc56m00()
#------------------------------------------------------------
# Menu do modulo
# --------------
   define ctc56m00     record
          ramcod       like datkclstxt.ramcod,
          rmemdlcod    like datkclstxt.rmemdlcod,
          clscod       like datkclstxt.clscod
   end record

   define k_ctc56m00   record
          ciaempcod    like datkclstxt.ciaempcod,
          ramcod       like datkclstxt.ramcod,
          rmemdlcod    like datkclstxt.rmemdlcod,
          clscod       like datkclstxt.clscod
   end record

   initialize  ctc56m00.*  to  null

   initialize  k_ctc56m00.*  to  null
   let m_ramgrpcod = null
   let m_status    = null
   let m_msg       = null
   let m_plnatnlimnum  = null

   #if not get_niv_mod(g_issk.prgsgl, "ctc56m00") then
   #   error "Modulo sem nivel de consulta e atualizacao!"
   #   return
   #end if

   let int_flag = false

   initialize ctc56m00.*   to  null
   initialize k_ctc56m00.* to  null

   open window ctc56m00 at 4,2 with form "ctc56m00"
           attribute(message line last, comment line last -1)

   menu "CLAUSULAS"

       before menu
          hide option all
          #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
          #      show option "Seleciona", "Proximo", "Anterior"
          #end if
          #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica" , "siTuacao" , "Inclui"
          #end if

          show option "Encerra"

   command "Seleciona" "Seleciona registro na tabela conforme criterios"
            call seleciona_ctc56m00() returning k_ctc56m00.*
            if k_ctc56m00.clscod    is not null then
               next option "Proximo"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if
            call display_ctc56m00(k_ctc56m00.*)

   command "Proximo" "Mostra proximo texto"
            if k_ctc56m00.clscod    is not null then
               call proximo_ctc56m00(k_ctc56m00.*)  returning k_ctc56m00.*
            else
               error "Nenhum registro nesta direcao!"
               next option "Seleciona"
            end if
            call display_ctc56m00(k_ctc56m00.*)

   command "Anterior" "Mostra texto anterior"
            if k_ctc56m00.clscod    is not null then
               call anterior_ctc56m00(k_ctc56m00.*)  returning k_ctc56m00.*
            else
               error "Nenhum registro nesta direcao!"
               next option "Seleciona"
            end if
            call display_ctc56m00(k_ctc56m00.*)

   command "Modifica" "Modifica registro corrente selecionado"
            if k_ctc56m00.clscod    is not null then
               call ctc56m01("a", k_ctc56m00.*, m_ramgrpcod)
               clear form
               initialize ctc56m00.*   to  null
               initialize k_ctc56m00.* to  null
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key ("T") "siTuacao" "Ativa/Cancela registro corrente selecionado"
            if k_ctc56m00.clscod    is not null then
               call remove_ctc56m00(k_ctc56m00.*)  returning k_ctc56m00.*
               next option "Seleciona"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui registro na tabela"
            call inclui_ctc56m00()
            initialize ctc56m00.*   to  null
            initialize k_ctc56m00.* to  null

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc56m00

end function  # ctc56m00

#------------------------------------------------------------
 function seleciona_ctc56m00()
#------------------------------------------------------------

   define ctc56m00    record
          ramcod       like datkclstxt.ramcod,
          rmemdlcod    like datkclstxt.rmemdlcod,
          clscod      like datkclstxt.clscod
   end record

   define k_ctc56m00  record
          ciaempcod    like datkclstxt.ciaempcod,
          ramcod       like datkclstxt.ramcod,
          rmemdlcod    like datkclstxt.rmemdlcod,
          clscod      like datkclstxt.clscod
   end record

   define ws          record
          count       smallint ,
          clsdes      char(30) ,
          empnom      like gabkemp.empnom,
          ramnom      like gtakram.ramnom,
          ramsgl      like gtakram.ramsgl
   end record

   define aux_status  char(01)


        let     aux_status  =  null

        initialize  ctc56m00.*  to  null

        initialize  k_ctc56m00.*  to  null

        initialize  ws.*  to  null

   clear form
   let int_flag = false
   initialize k_ctc56m00.* to null

   input by name k_ctc56m00.*  without defaults

      before field ciaempcod
          display by name k_ctc56m00.ciaempcod attribute (reverse)

      after  field ciaempcod
          display by name k_ctc56m00.ciaempcod 

          if k_ctc56m00.ciaempcod is null then
             call cty14g00_popup_empresa()
                  returning m_status, k_ctc56m00.ciaempcod, ws.empnom

             if m_status <> 1 then
                error "Informe a empresa"
                next field ciaempcod
             end if  

          end if

          if k_ctc56m00.ciaempcod <> 1  and
             k_ctc56m00.ciaempcod <> 35 and
             k_ctc56m00.ciaempcod <> 50 then
             error "Informe a empresa: 1-Porto ou 35-Azul ou 5-Saude"
             next field ciaempcod
          end if

          call cty14g00_empresa(1, k_ctc56m00.ciaempcod)
               returning m_status, m_msg,  ws.empnom

          if m_status <> 1 then
             error m_msg
             next field ciaempcod
          end if

          display by name ws.empnom 

      before field ramcod
          display by name k_ctc56m00.ramcod attribute (reverse)

      after  field ramcod

          let m_status = null
          let m_msg = null
          let ws.ramnom = null
          let ws.ramsgl = null

          call cty10g00_descricao_ramo(k_ctc56m00.ramcod, 1)
               returning m_status, m_msg, ws.ramnom,  ws.ramsgl 

          if m_status <> 1  then
             error " Ramo nao cadastrado!"
             call c24geral10()
                  returning k_ctc56m00.ramcod, ws.ramnom
             next field ramcod
          end if

          let m_ramgrpcod = null
          call cty10g00_grupo_ramo(1,k_ctc56m00.ramcod)
               returning m_status, m_msg, m_ramgrpcod

          display by name k_ctc56m00.ramcod
          display by name ws.ramnom

      before field rmemdlcod
          display by name k_ctc56m00.rmemdlcod attribute (reverse)

      after  field rmemdlcod
          display by name k_ctc56m00.rmemdlcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field ramcod
          end if

          if k_ctc56m00.rmemdlcod is null then
             error "Codigo da Modalidade e' obrigatoria!"
             call ctc56m05(k_ctc56m00.ramcod)
                 returning k_ctc56m00.rmemdlcod
             next field rmemdlcod
          end if

          select rmemdlnom
            from gtakmodal
           where ramcod = k_ctc56m00.ramcod
             and rmemdlcod = k_ctc56m00.rmemdlcod
             and empcod = 1

          if sqlca.sqlcode = notfound then
             error "Modalidade nao encontrada! Informe novamente."
             call ctc56m05(k_ctc56m00.ramcod)
                 returning k_ctc56m00.rmemdlcod
             next field rmemdlcod
          end if

      before field clscod
          let m_status = 1
          display by name k_ctc56m00.clscod attribute (reverse)

      after  field clscod
          display by name k_ctc56m00.clscod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field rmemdlcod
          end if

          if k_ctc56m00.clscod is null then
             error "Codigo da Clausula e' obrigatoria!"
             call ctc56m02(k_ctc56m00.ciaempcod,
                           k_ctc56m00.ramcod,
                           k_ctc56m00.rmemdlcod,
                           m_ramgrpcod)
                 returning k_ctc56m00.clscod
             next field clscod
          end if

          ### PSI 202720
          let ws.clsdes = null
          call ctc56m06_clsdes(k_ctc56m00.ciaempcod, 
                               m_ramgrpcod, 
                               k_ctc56m00.ramcod,
                               k_ctc56m00.clscod, 
                               k_ctc56m00.rmemdlcod)
               returning ws.clsdes

          if ws.clsdes is null then
             error "Clausula nao encontrada! Informe novamente."
             call ctc56m02(k_ctc56m00.ciaempcod,
                           k_ctc56m00.ramcod,
                           k_ctc56m00.rmemdlcod,
                           m_ramgrpcod)
                 returning k_ctc56m00.clscod
             next field clscod
          end if

         display by name ws.clsdes

         let ws.count = 0

         select count(*) into ws.count
           from datkclstxt
          where clscod    = k_ctc56m00.clscod
            and ramcod    = k_ctc56m00.ramcod
            and rmemdlcod = k_ctc56m00.rmemdlcod
            and ciaempcod = k_ctc56m00.ciaempcod

         if ws.count = 0 then
            error "Nao existem textos cadastrados para esta clausula!"
            next field clscod
         end if

      on key (interrupt)
          exit input

   end input

   if int_flag  then
      let int_flag = false
      initialize ctc56m00.* to null
      error "Operacao cancelada!"
      clear form
      return k_ctc56m00.*
   end if

   display by name  k_ctc56m00.clscod, ws.clsdes

   return k_ctc56m00.*

end function  # seleciona

#--------------------------------------------------------------------
function remove_ctc56m00(k_ctc56m00)
#--------------------------------------------------------------------
   define k_ctc56m00 record
          ciaempcod  like datkclstxt.ciaempcod,
          ramcod     like datkclstxt.ramcod,
          rmemdlcod  like datkclstxt.rmemdlcod,
          clscod     like datkclstxt.clscod
   end record

   define ws record
          clslinseq  like datkclstxt.clslinseq
   end record



        initialize  ws.*  to  null

   select max(clslinseq)
          into ws.clslinseq
     from datkclstxt
    where clscod = k_ctc56m00.clscod
      and ramcod = k_ctc56m00.ramcod
      and rmemdlcod = k_ctc56m00.rmemdlcod
      and ciaempcod = k_ctc56m00.ciaempcod

   menu "Confirma Exclusao ?"

      command "Nao" "Cancela exclusao do texto"
              clear form
              initialize k_ctc56m00.* to null
              error "Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui texto"

                 whenever error continue
                 begin work
                    update datkclstxt set clstxtstt = 2
                          where datkclstxt.clscod    = k_ctc56m00.clscod
                            and datkclstxt.ramcod    = k_ctc56m00.ramcod
                            and datkclstxt.rmemdlcod = k_ctc56m00.rmemdlcod
                            and datkclstxt.ciaempcod = k_ctc56m00.ciaempcod
                            and datkclstxt.clslinseq = ws.clslinseq
                 commit work

                 if sqlca.sqlcode <>  0  then
                    error "Erro na Remocao do Registro!"
                    rollback work
                 else
                    error  "Registro removido!"
                 end if
                 whenever error stop

                 initialize k_ctc56m00.* to null
                 clear form
              exit menu
   end menu

   return k_ctc56m00.*

end function    # remove_ctc56m00

#------------------------------------------------------------
function inclui_ctc56m00()
#------------------------------------------------------------
# Inclui registros na tabela
#
   define ctc56m00   record
          ciaempcod  like datkclstxt.ciaempcod,
          ramcod     like datkclstxt.ramcod,
          rmemdlcod  like datkclstxt.rmemdlcod,
          clscod     like datkclstxt.clscod
   end record

   define k_ctc56m00  record
          ciaempcod  like datkclstxt.ciaempcod,
          ramcod     like datkclstxt.ramcod,
          rmemdlcod  like datkclstxt.rmemdlcod,
          clscod     like datkclstxt.clscod
   end record



        initialize  ctc56m00.*  to  null

        initialize  k_ctc56m00.*  to  null

   clear form

   initialize ctc56m00.*   to null
   initialize k_ctc56m00.* to null

   call input_ctc56m00("i",k_ctc56m00.*, ctc56m00.*) returning ctc56m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc56m00.*  to null
      error "Operacao cancelada!"
      clear form
      return
   end if

   call ctc56m01("i", ctc56m00.*, m_ramgrpcod)

   clear form

end function  # inclui

#--------------------------------------------------------------------
 function input_ctc56m00(operacao_aux, k_ctc56m00, ctc56m00)
#--------------------------------------------------------------------
   define operacao_aux   char (1)

   define  ctc56m00   record
           ciaempcod  like datkclstxt.ciaempcod,
           ramcod     like datkclstxt.ramcod,
           rmemdlcod  like datkclstxt.rmemdlcod,
           clscod     like datkclstxt.clscod
   end record

   define  k_ctc56m00 record
           ciaempcod  like datkclstxt.ciaempcod,
           ramcod     like datkclstxt.ramcod,
           rmemdlcod  like datkclstxt.rmemdlcod,
           clscod     like datkclstxt.clscod
   end record

   define ws          record
          count       smallint ,
          clsdes      char(30) ,
          empnom      like gabkemp.empnom,
          ramnom      like gtakram.ramnom,
          ramsgl      like gtakram.ramsgl
   end record

   initialize  ws.*  to  null

   let int_flag = false

   input by name ctc56m00.ciaempcod,
                 ctc56m00.ramcod,
                 ctc56m00.rmemdlcod,
                 ctc56m00.clscod without defaults

      before field ciaempcod
          display by name ctc56m00.ciaempcod attribute (reverse)

      after  field ciaempcod
          display by name ctc56m00.ciaempcod

          if ctc56m00.ciaempcod is null then
             error 'Informe o codigo da empresa (1)Porto/(35)Azul/(50)Saude'
             next field ciaempcod
          end if

          call cty14g00_empresa(1, ctc56m00.ciaempcod)
               returning m_status, m_msg,  ws.empnom

          if m_status <> 1 then
             error m_msg
             next field ciaempcod
          end if

          display by name ws.empnom  

      before field ramcod
          display by name ctc56m00.ramcod attribute (reverse)

      after  field ramcod

          let m_status = null
          let m_msg = null
          let ws.ramnom = null
          let ws.ramsgl = null

          call cty10g00_descricao_ramo(ctc56m00.ramcod, 1)
               returning m_status, m_msg, ws.ramnom, ws.ramsgl 

          if m_status <> 1  then
             error " Ramo nao cadastrado!"
             call c24geral10()
                  returning ctc56m00.ramcod, ws.ramnom
             next field ramcod
          end if

          display by name ctc56m00.ramcod
          display by name ws.ramnom

          ### PSI 202720
          let m_status = null
          let m_msg = null
          let m_ramgrpcod = null
 
          call cty10g00_grupo_ramo(1,ctc56m00.ramcod)
               returning m_status, m_msg, m_ramgrpcod

      before field rmemdlcod
          display by name ctc56m00.rmemdlcod attribute (reverse)

      after  field rmemdlcod
          display by name ctc56m00.rmemdlcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field ramcod
          end if

          if ctc56m00.rmemdlcod is null then
             error "Codigo da Modalidade e' obrigatoria!"
             call ctc56m05(ctc56m00.ramcod)
                 returning ctc56m00.rmemdlcod
             next field rmemdlcod
          end if

          select rmemdlnom
            from gtakmodal
           where ramcod = ctc56m00.ramcod
             and rmemdlcod = ctc56m00.rmemdlcod
             and empcod    = 1

          if sqlca.sqlcode = notfound then
             error "Modalidade nao encontrada! Informe novamente."
             call ctc56m05(ctc56m00.ramcod)
                 returning ctc56m00.rmemdlcod
             next field rmemdlcod
          end if

      before field clscod
          let m_status = 1
          display by name ctc56m00.clscod attribute (reverse)

      after  field clscod
          display by name ctc56m00.clscod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field ramcod
          end if

          if ctc56m00.clscod is null then
             error "Codigo da Clausula e' obrigatoria!"
             call ctc56m02(ctc56m00.ciaempcod,
                           ctc56m00.ramcod,
                           ctc56m00.rmemdlcod,
                           m_ramgrpcod)
                 returning ctc56m00.clscod
             next field clscod
          end if

          ### PSI 202720
          let ws.clsdes  = null

          call ctc56m06_clsdes(ctc56m00.ciaempcod, m_ramgrpcod, ctc56m00.ramcod,
                               ctc56m00.clscod, ctc56m00.rmemdlcod)
               returning ws.clsdes

          if ws.clsdes is null then
             error "Clausula nao encontrada! Informe novamente."
             call ctc56m02(ctc56m00.ciaempcod,
                           ctc56m00.ramcod,
                           ctc56m00.rmemdlcod,
                           m_ramgrpcod)
                 returning ctc56m00.clscod
             next field clscod
          end if

         display by name ws.clsdes
         display by name ws.ramnom

         let ws.count = 0

         select count(*) into ws.count
           from datkclstxt
          where clscod    = ctc56m00.clscod
            and ramcod    = ctc56m00.ramcod
            and rmemdlcod = ctc56m00.rmemdlcod
            and ciaempcod = ctc56m00.ciaempcod

         if ws.count > 0 then
            error "Existem textos cadastrados para esta clausula!"
            next field clscod
         end if

      on key (interrupt)
          exit input

   end input

   if int_flag   then
      initialize ctc56m00.*  to null
   end if

   return ctc56m00.*

end function   # input_ctc56m00

#---------------------------------------------------------------
 function display_ctc56m00(par_ctc56m00)
#---------------------------------------------------------------

   define par_ctc56m00 record
          ciaempcod like datkclstxt.ciaempcod,
          ramcod    like datkclstxt.ramcod,
          rmemdlcod like datkclstxt.rmemdlcod,
          clscod    like datkclstxt.clscod
   end record

   define a_ctc56m00 array[500] of record
      clstxt         like datkclstxt.clstxt ,
      clslin         like datkclstxt.clslin
   end record

   define ws   record
          count      smallint,
          clsdes     like aackcls.clsdes,
          empnom     like gabkemp.empnom,
          ramnom     like gtakram.ramnom
   end record

   define arr_aux    integer


        define  w_pf1   integer

        let     arr_aux  =  null

        for     w_pf1  =  1  to  500
                initialize  a_ctc56m00[w_pf1].*  to  null
        end     for

        initialize  ws.*  to  null

  ### PSI 202720
  let ws.clsdes = null
  let ws.ramnom = null

  call ctc56m06_clsdes(par_ctc56m00.ciaempcod, m_ramgrpcod, par_ctc56m00.ramcod,
                       par_ctc56m00.clscod, par_ctc56m00.rmemdlcod)
       returning ws.clsdes

   select ramnom
     into ws.ramnom
     from gtakram
    where ramcod = par_ctc56m00.ramcod
      and empcod = 1

   call cty14g00_empresa(1,par_ctc56m00.ciaempcod) 
        returning m_status, m_msg,  ws.empnom

   display by name par_ctc56m00.ciaempcod
   display by name ws.empnom
   display by name par_ctc56m00.ramcod
   display by name ws.ramnom
   display by name par_ctc56m00.rmemdlcod
   display by name par_ctc56m00.clscod
   display by name ws.clsdes

   declare c_ctc56m00 cursor for
      select clstxt, clslin
        from datkclstxt
       where clscod    = par_ctc56m00.clscod
         and ramcod    = par_ctc56m00.ramcod
         and rmemdlcod = par_ctc56m00.rmemdlcod
         and ciaempcod = par_ctc56m00.ciaempcod
         and clslinseq = (select max(clslinseq)
                            from datkclstxt
                           where clscod = par_ctc56m00.clscod
                             and ramcod    = par_ctc56m00.ramcod
                             and rmemdlcod = par_ctc56m00.rmemdlcod
                             and ciaempcod = par_ctc56m00.ciaempcod)
       order by clslin

   initialize a_ctc56m00  to null
   let arr_aux = 1

   foreach c_ctc56m00 into a_ctc56m00[arr_aux].clstxt ,
                           a_ctc56m00[arr_aux].clslin

      let arr_aux = arr_aux + 1
      if arr_aux > 500 then
         exit foreach
      end if
   end foreach

  if arr_aux > 1 then
     let ws.count = 0
     select count(*) into ws.count
         from datkclstxt
        where clscod    = par_ctc56m00.clscod
          and ramcod    = par_ctc56m00.ramcod
          and rmemdlcod = par_ctc56m00.rmemdlcod
          and ciaempcod = par_ctc56m00.ciaempcod
          and clslin    = 1
     if ws.count > 0 then
        message  "(F7)Historico"
     else
        message  ""
     end if
     call set_count(arr_aux - 1)
     display array a_ctc56m00 to s_ctc56m00.*
       on key (interrupt, control-c)
          exit display

       on key (f7)
          if ws.count > 0 then
             call ctc56m04(par_ctc56m00.ciaempcod,
                           par_ctc56m00.clscod,
                           par_ctc56m00.ramcod,
                           par_ctc56m00.rmemdlcod)
          end if
     end display
  end if
end function  #  display_ctc56m00

#------------------------------------------------------------
 function proximo_ctc56m00(k_ctc56m00)
#------------------------------------------------------------

   define ctc56m00   record
          ciaempcod  like datkclstxt.ciaempcod,
          ramcod     like datkclstxt.ramcod,
          rmemdlcod  like datkclstxt.rmemdlcod,
          clscod     like datkclstxt.clscod
   end record

   define k_ctc56m00 record
          ciaempcod  like datkclstxt.ciaempcod,
          ramcod     like datkclstxt.ramcod,
          rmemdlcod  like datkclstxt.rmemdlcod,
          clscod     like datkclstxt.clscod
   end record



        initialize  ctc56m00.*  to  null

     select min(clscod)
       into k_ctc56m00.clscod
       from datkclstxt
      where clscod    > k_ctc56m00.clscod
        and ramcod    = k_ctc56m00.ramcod
        and rmemdlcod = k_ctc56m00.rmemdlcod
        and ciaempcod = k_ctc56m00.ciaempcod

      if  k_ctc56m00.clscod is null  then
          error "Nao ha' mais registros nesta direcao!"
          initialize ctc56m00.*    to null
      end if

   return k_ctc56m00.*

end function    # proximo_ctc56m00

#------------------------------------------------------------
 function anterior_ctc56m00(k_ctc56m00)
#------------------------------------------------------------

   define ctc56m00   record
          ciaempcod  like datkclstxt.ciaempcod,
          ramcod     like datkclstxt.ramcod,
          rmemdlcod  like datkclstxt.rmemdlcod,
          clscod     like datkclstxt.clscod
   end record

   define k_ctc56m00 record
          ciaempcod  like datkclstxt.ciaempcod,
          ramcod     like datkclstxt.ramcod,
          rmemdlcod  like datkclstxt.rmemdlcod,
          clscod     like datkclstxt.clscod
   end record



        initialize  ctc56m00.*  to  null

     select max(clscod)
       into k_ctc56m00.clscod
       from datkclstxt
      where datkclstxt.clscod    < k_ctc56m00.clscod
        and ramcod    = k_ctc56m00.ramcod
        and rmemdlcod = k_ctc56m00.rmemdlcod
        and ciaempcod = k_ctc56m00.ciaempcod

     if  k_ctc56m00.clscod is null  then
         error "Nao ha' mais registros nesta direcao!"
         initialize ctc56m00.*    to null
     end if

   return k_ctc56m00.*

end function    # anterior_ctc56m00
