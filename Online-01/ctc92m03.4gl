###########################################################################
# Nome do Modulo: ctc92m03                                                #
#                                                                         #
# Associacao do Plano de Assistencia as Coberturas               Jan/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

   define m_prep     smallint
   define m_mens     char(80)
   define arr_aux    smallint
   define scr_aux    smallint


   define a_ctc92m03 record
       itaasiplncod        like datkitaasipln.itaasiplncod
      ,itaasiplndes        like datkitaasipln.itaasiplndes
   end record

   define b_ctc92m03 record
       itacbtcod           like datkitacbt.itacbtcod
      ,itacbtdes           like datkitacbt.itacbtdes
   end record

   define c_ctc92m03 array[500] of record
       controle            char(1)
      ,itaasisrvcod        like datkitacbtintrgr.itaasisrvcod
      ,ubbcod              like datkitacbtintrgr.ubbcod
      ,vcltipdes           like datkubbvcltip.vcltipdes
      ,rsrcaogrtcod        like datkitacbtintrgr.rsrcaogrtcod
      ,itarsrcaosrvcod     like datkitacbtintrgr.itarsrcaosrvcod
   end record

   define d_ctc92m03 record
       atldat              like datkitacbtintrgr.atldat
      ,atlusr              like isskfunc.funnom
   end record

#========================================================================
function ctc92m03_prepare()
#========================================================================
   define l_sql char(800)

   let l_sql = "SELECT itaasiplndes ",
               "FROM datkitaasipln ",
               "WHERE itaasiplncod = ? "
   prepare p_ctc92m03_001 from l_sql
   declare c_ctc92m03_001 cursor with hold for p_ctc92m03_001

   let l_sql = "SELECT itacbtdes ",
               "FROM datkitacbt ",
               "WHERE itacbtcod = ?"
   prepare p_ctc92m03_002 from l_sql
   declare c_ctc92m03_002 cursor with hold for p_ctc92m03_002

   let l_sql = "SELECT itacbtcod, itacbtdes ",
               "FROM datkitacbt ",
               "WHERE itacbtcod = ",
               "  (SELECT MIN(itacbtcod) ",
               "   FROM datkitacbtintrgr ",
               "   WHERE itaasiplncod = ? ",
               "     AND itacbtcod > ? ",
               "   ) "
   prepare p_ctc92m03_003 from l_sql
   declare c_ctc92m03_003 cursor with hold for p_ctc92m03_003

   let l_sql = "SELECT itacbtcod, itacbtdes ",
               "FROM datkitacbt ",
               "WHERE itacbtcod = ",
               "  (SELECT MAX(itacbtcod) ",
               "   FROM datkitacbtintrgr ",
               "   WHERE itaasiplncod = ? ",
               "     AND itacbtcod < ? ",
               "   ) "
   prepare p_ctc92m03_004 from l_sql
   declare c_ctc92m03_004 cursor with hold for p_ctc92m03_004

   let l_sql = "SELECT RGR.itaasisrvcod, RGR.ubbcod, NVL(UBB.vcltipdes,''), RGR.rsrcaogrtcod, ",
               "       RGR.itarsrcaosrvcod, RGR.atldat, NVL(FUN.funnom,'') ",
               "FROM datkitacbtintrgr RGR ",
               "LEFT JOIN isskfunc FUN ",
               "   ON (RGR.atlmat    = FUN.funmat ",
               "   AND RGR.atlemp    = FUN.empcod ",
               "   AND RGR.atlusrtip = FUN.usrtip) ",
               "LEFT JOIN datkubbvcltip UBB ",
               "   ON (RGR.ubbcod = UBB.ubbcod) ",
               "WHERE RGR.itaasiplncod = ? ",
               "AND   RGR.itacbtcod = ? ",
               "ORDER BY 1, 2 "
   prepare p_ctc92m03_005 from l_sql
   declare c_ctc92m03_005 cursor with hold for p_ctc92m03_005

   let l_sql = "DELETE FROM datkitacbtintrgr ",
               "WHERE itaasisrvcod = ? ",
               "AND   rsrcaogrtcod = ? ",
               "AND   itarsrcaosrvcod = ? ",
               "AND   ubbcod = ? "
   prepare p_ctc92m03_006 from l_sql

   let l_sql = "SELECT COUNT(*)        ",
               "FROM datkitaasisrv     ",
               "WHERE itaasisrvcod = ? "
   prepare p_ctc92m03_007 from l_sql
   declare c_ctc92m03_007 cursor for p_ctc92m03_007

   let l_sql = "SELECT vcltipdes ",
               "FROM datkubbvcltip ",
               "WHERE ubbcod = ? "
   prepare p_ctc92m03_008 from l_sql
   declare c_ctc92m03_008 cursor for p_ctc92m03_008

   let l_sql = "SELECT COUNT(*)        ",
               "FROM datkitarsrcaogar     ",
               "WHERE rsrcaogrtcod = ? "
   prepare p_ctc92m03_009 from l_sql
   declare c_ctc92m03_009 cursor for p_ctc92m03_009

   let l_sql = "SELECT COUNT(*)        ",
               "FROM datkitarsrcaosrv     ",
               "WHERE itarsrcaosrvcod = ? "
   prepare p_ctc92m03_010 from l_sql
   declare c_ctc92m03_010 cursor for p_ctc92m03_010

   let l_sql = "INSERT INTO datkitacbtintrgr ",
               "  (itaasisrvcod ",
               "  ,rsrcaogrtcod ",
               "  ,itarsrcaosrvcod ",
               "  ,ubbcod ",
               "  ,itacbtcod ",
               "  ,itaasiplncod ",
               "  ,atldat ",
               "  ,atlmat ",
               "  ,atlemp ",
               "  ,atlusrtip) ",
               " VALUES (?, ?, ?, ?, ?, ?, today, ?, ?, ?) "
   prepare p_ctc92m03_011 from l_sql

   let l_sql = "SELECT PLN.itaasiplncod, PLN.itaasiplndes, CBT.itacbtcod, CBT.itacbtdes ",
               "FROM datkitacbtintrgr RGR ",
               "LEFT JOIN datkitacbt CBT ",
               "   ON CBT.itacbtcod = RGR.itacbtcod ",
               "LEFT JOIN datkitaasipln PLN ",
               "    ON PLN.itaasiplncod = RGR.itaasiplncod ",
               "WHERE RGR.itaasisrvcod = ? ",
               "AND   RGR.rsrcaogrtcod = ? ",
               "AND   RGR.itarsrcaosrvcod = ? ",
               "AND   RGR.ubbcod = ? "
   prepare p_ctc92m03_012 from l_sql
   declare c_ctc92m03_012 cursor for p_ctc92m03_012

   let l_sql = "SELECT RGR.atldat, NVL(FUN.funnom,'') ",
               "FROM datkitacbtintrgr RGR ",
               "LEFT JOIN isskfunc FUN ",
               "   ON (RGR.atlmat    = FUN.funmat ",
               "   AND RGR.atlemp    = FUN.empcod ",
               "   AND RGR.atlusrtip = FUN.usrtip) ",
               "WHERE RGR.itaasisrvcod = ? ",
               "  AND RGR.ubbcod = ? ",
               "  AND RGR.rsrcaogrtcod = ? ",
               "  AND RGR.itarsrcaosrvcod = ? "
   prepare p_ctc92m03_013 from l_sql
   declare c_ctc92m03_013 cursor with hold for p_ctc92m03_013

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitacbtintrgr ",
               "WHERE itaasiplncod = ? ",
               "  AND itacbtcod = ? "
   prepare p_ctc92m03_014 from l_sql
   declare c_ctc92m03_014 cursor with hold for p_ctc92m03_014

   let l_sql = "SELECT RGR.itaasiplncod, PLN.itaasiplndes ",
               "FROM datkitacbtintrgr RGR ",
               "INNER JOIN datkitaasipln PLN ",
               "   ON (RGR.itaasiplncod = PLN.itaasiplncod) ",
               "WHERE RGR.itacbtcod = ? ",
               "GROUP BY RGR.itaasiplncod, PLN.itaasiplndes "
   prepare p_ctc92m03_015 from l_sql
   declare c_ctc92m03_015 cursor with hold for p_ctc92m03_015

   let l_sql = "SELECT MAX(NVL(itacbtcod,0)) + 1 ",
               "FROM datkitacbt "
   prepare p_ctc92m03_016 from l_sql
   declare c_ctc92m03_016 cursor with hold for p_ctc92m03_016
   
   let l_sql = "INSERT INTO datkitacbt ",
               " (itacbtcod, itacbtdes, atldat, atlmat, atlemp, atlusrtip) ",
               "VALUES (?, ?, today, ?, ?, ?) "
   prepare p_ctc92m03_017 from l_sql

   let l_sql = "SELECT itacbtcod ",
               "FROM datkitacbt ",
               "WHERE UPPER(itacbtdes) = ? "
   prepare p_ctc92m03_018 from l_sql
   declare c_ctc92m03_018 cursor for p_ctc92m03_018

   let m_prep = true

#========================================================================
end function # Fim da ctc92m03_prepare
#========================================================================


#========================================================================
function ctc92m03(lr_param)
#========================================================================

   define lr_param record
      itaasiplncod         smallint
   end record

   let int_flag = false
   initialize a_ctc92m03.*  to null
   initialize b_ctc92m03.*  to null

   if m_prep = false or
      m_prep is null then
      call ctc92m03_prepare()
   end if
   
   options delete key F2
   options insert key F1
   
   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO
   let g_issk.funmat = 6117
   let g_issk.empcod = 1
   let g_issk.usrtip = 'F'
   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO

   open window ctc92m03 at 4,2 with form "ctc92m03"
      attribute(form line first + 2, message line first +19 ,comment line first +18)

   let a_ctc92m03.itaasiplncod = lr_param.itaasiplncod

   call ctc92m03_preenche_plano_assistencia()

   if a_ctc92m03.itaasiplncod = " " or
      a_ctc92m03.itaasiplndes is null or
      a_ctc92m03.itaasiplndes = " " then
      error " Codigo do plano invalido. Selecione um plano valido para acessar coberturas."
      close window ctc92m03
      return
   end if


   menu "COBERTURAS"

      command key ("S") "Seleciona"
                        "Pesquisa cobertura conforme criterios"
         call ctc92m03_seleciona()
         call ctc92m03_input("v")
         if b_ctc92m03.itacbtcod is not null  then
            next option "Proximo"
         else
            error " Nenhuma cobertura selecionada!"
            next option "Seleciona"
         end if
         message " (F17)Abandona"


      command key ("P") "Proximo"
                        "Mostra a proxima cobertura"
         call ctc92m03_proximo()
         call ctc92m03_input("v")
         message " (F17)Abandona"

      command key ("A") "Anterior"
                        "Mostra a cobertura anterior"
         call ctc92m03_anterior()
         call ctc92m03_input("v")
         message " (F17)Abandona"

      command key ("M") "Modifica"
                        "Modifica a cobertura selecionada"
         if not (b_ctc92m03.itacbtcod is null or b_ctc92m03.itacbtcod = " ") then
            call ctc92m03_input("c")
         else
            error " Nenhuma cobertura selecionada!"
            next option "Seleciona"
         end if
         message " (F17)Abandona"

      command key ("I") "Inclui"
                        "Inclui agrupamento"
         message " (F17)Abandona"
         call ctc92m03_inclui()
         next option "Modifica"

      command key (interrupt,E) "Encerra"
                                "Retorna ao menu anterior"
         exit menu

   end menu

 close window ctc92m03

#========================================================================
end function # Fim da ctc92m03
#========================================================================



#========================================================================
function ctc92m03_preenche_plano_assistencia()
#========================================================================
   let a_ctc92m03.itaasiplndes = null
   whenever error continue
      open c_ctc92m03_001 using a_ctc92m03.itaasiplncod
      fetch c_ctc92m03_001 into a_ctc92m03.itaasiplndes
      close c_ctc92m03_001
   whenever error stop
   display by name a_ctc92m03.*

#========================================================================
end function # Fim da funcao ctc92m03_preenche_plano_assistencia()
#========================================================================

#========================================================================
function ctc92m03_preenche_cobertura()
#========================================================================
   let b_ctc92m03.itacbtdes = null
   whenever error continue
      open c_ctc92m03_002 using b_ctc92m03.itacbtcod
      fetch c_ctc92m03_002 into b_ctc92m03.itacbtdes
      close c_ctc92m03_002
   whenever error stop
   display by name b_ctc92m03.*

#========================================================================
end function # Fim da funcao ctc92m03_preenche_cobertura()
#========================================================================

#========================================================================
function ctc92m03_verifica_servico_assist()
#========================================================================
   define l_count smallint
   whenever error continue
   open c_ctc92m03_007 using c_ctc92m03[arr_aux].itaasisrvcod
   fetch c_ctc92m03_007 into l_count
   whenever error stop
   close c_ctc92m03_007
   return l_count

#========================================================================
end function # Fim da funcao ctc92m03_verifica_servico_assist()
#========================================================================

#========================================================================
function ctc92m03_verifica_garantia()
#========================================================================
   define l_count smallint
   whenever error continue
   open c_ctc92m03_009 using c_ctc92m03[arr_aux].rsrcaogrtcod
   fetch c_ctc92m03_009 into l_count
   whenever error stop
   close c_ctc92m03_009
   return l_count

#========================================================================
end function # Fim da funcao ctc92m03_verifica_garantia()
#========================================================================

#========================================================================
function ctc92m03_verifica_cobertura()
#========================================================================
   define l_cobcod smallint
   let l_cobcod = null
   whenever error continue
   open c_ctc92m03_018 using b_ctc92m03.itacbtdes
   fetch c_ctc92m03_018 into l_cobcod    
   whenever error stop
   close c_ctc92m03_018
   return l_cobcod

#========================================================================
end function # Fim da funcao ctc92m03_verifica_cobertura()
#========================================================================

#========================================================================
function ctc92m03_verifica_serv_carro_reserva()
#========================================================================
   define l_count smallint
   whenever error continue
   open c_ctc92m03_010 using c_ctc92m03[arr_aux].itarsrcaosrvcod
   fetch c_ctc92m03_010 into l_count
   whenever error stop
   close c_ctc92m03_010
   return l_count

#========================================================================
end function # Fim da funcao ctc92m03_verifica_serv_carro_reserva()
#========================================================================

#========================================================================
function ctc92m03_verifica_regra_plano_cob()
#========================================================================
   define l_count smallint
   whenever error continue
   open c_ctc92m03_014 using a_ctc92m03.itaasiplncod
                            ,b_ctc92m03.itacbtcod
   fetch c_ctc92m03_014 into l_count
   whenever error stop
   close c_ctc92m03_014
   return l_count

#========================================================================
end function # Fim da funcao ctc92m03_verifica_regra_plano_cob()
#========================================================================

#========================================================================
function ctc92m03_verifica_regra_cob()
#========================================================================
   define l_count smallint
   whenever error continue
   open c_ctc92m03_014 using b_ctc92m03.itacbtcod
   fetch c_ctc92m03_014 into l_count
   whenever error stop
   close c_ctc92m03_014
   return l_count

#========================================================================
end function # Fim da funcao ctc92m03_verifica_regra_cob()
#========================================================================

#========================================================================
function ctc92m03_retorna_plano_regra_cob()
#========================================================================
   define lr_plano record
       itaasiplncod        like datkitaasipln.itaasiplncod
      ,itaasiplndes        like datkitaasipln.itaasiplndes
   end record

   initialize lr_plano.* to null

   whenever error continue
   open c_ctc92m03_015 using b_ctc92m03.itacbtcod
   fetch c_ctc92m03_015 into lr_plano.*
   whenever error stop
   close c_ctc92m03_015
   
   return lr_plano.*

#========================================================================
end function # Fim da funcao ctc92m03_retorna_plano_regra_cob()
#========================================================================

#========================================================================
function ctc92m03_retorna_proximo_cbtcod()
#========================================================================
   define l_retorno smallint

   whenever error continue
   open c_ctc92m03_016
   fetch c_ctc92m03_016 into l_retorno
   whenever error stop
   close c_ctc92m03_016
   
   return l_retorno

#========================================================================
end function # Fim da funcao ctc92m03_retorna_plano_regra_cob()
#========================================================================

#========================================================================
function ctc92m03_preenche_ubb()
#========================================================================
   let c_ctc92m03[arr_aux].vcltipdes = null
   whenever error continue
      open c_ctc92m03_008 using c_ctc92m03[arr_aux].ubbcod
      fetch c_ctc92m03_008 into c_ctc92m03[arr_aux].vcltipdes
      close c_ctc92m03_008
   whenever error stop
   display c_ctc92m03[arr_aux].vcltipdes to s2_ctc92m03[scr_aux].vcltipdes

#========================================================================
end function # Fim da funcao ctc92m03_preenche_ubb()
#========================================================================

#========================================================================
function ctc92m03_seleciona()
#========================================================================
   define l_flg_ok char(1)
   define l_count  smallint

   let int_flag = false

   display by name b_ctc92m03.*

   input by name b_ctc92m03.* without defaults

     #--------------------
      before field itacbtcod
     #--------------------
         display by name b_ctc92m03.itacbtcod

     #--------------------
      after field itacbtcod
     #--------------------
         call ctc92m03_preenche_cobertura()

         if b_ctc92m03.itacbtcod = " " or
            b_ctc92m03.itacbtdes is null or
            b_ctc92m03.itacbtdes = " " then

            call cts08g01("A", "N",
                          " ",
                          "COBERTURA NAO ENCONTRADA",
                          "DIGITE UM CODIGO DE COBERTURA VALIDO.",
                          " ")
            returning l_flg_ok

            initialize b_ctc92m03.* to null
            display by name b_ctc92m03.*
            exit input
         end if

         call ctc92m03_verifica_regra_plano_cob()
            returning l_count

         if l_count <= 0 then

            call cts08g01("A", "N",
                          " ",
                          "COBERTURA NAO ASSOCIADA A ESTE PLANO.",
                          "DIGITE UM CODIGO DE COBERTURA VALIDO!",
                          " ")
            returning l_flg_ok

            initialize b_ctc92m03.* to null
            display by name b_ctc92m03.*

         end if

     #--------------------
      before field itacbtdes
     #--------------------
         exit input

     #--------------------
      on key (interrupt)
     #--------------------
         exit input

   end input

   if int_flag  then
      let int_flag = false
      initialize b_ctc92m03.*   to null
      display by name b_ctc92m03.*
      error " Operacao cancelada!"
   end if

#========================================================================
 end function  # Fim da funcao ctc92m03_seleciona
#========================================================================

#========================================================================
 function ctc92m03_insere_cobertura()
#========================================================================
   define l_cobcod smallint

   let l_cobcod = null

   if b_ctc92m03.itacbtcod    is null or
      b_ctc92m03.itacbtdes    is null or
      b_ctc92m03.itacbtcod    = " " or
      b_ctc92m03.itacbtdes    = " " then
      error "Inclusao cancelada. Todos os campos devem ser preenchidos."
      return false
   end if

   error "Aguarde..."

   call ctc92m03_verifica_cobertura()
      returning l_cobcod
   
   if l_cobcod is not null and
      l_cobcod > 0 then
      error "Esta cobertura ja esta cadastrada sob o codigo: ", l_cobcod clipped, "."
      return false
   end if
   
   whenever error continue
   execute p_ctc92m03_017 using b_ctc92m03.itacbtcod
                               ,b_ctc92m03.itacbtdes
                               ,g_issk.funmat 
                               ,g_issk.empcod
                               ,g_issk.usrtip                                 
   whenever error stop

   if sqlca.sqlcode <> 0 then
      error "Erro (", sqlca.sqlcode clipped, ") ao inserir COBERTURA. Tabela <datkitacbt>."
      sleep 3
      return false
   end if

   error "Inclusao realizada com sucesso."
   return true


#========================================================================
 end function  # Fim da funcao ctc92m03_insere_cobertura
#========================================================================


#========================================================================
 function ctc92m03_insere_regra()
#========================================================================
   define lr_plano_cob record
       itaasiplncod   like datkitaasipln.itaasiplncod
      ,itaasiplndes   like datkitaasipln.itaasiplndes
      ,itacbtcod      like datkitacbt.itacbtcod
      ,itacbtdes      like datkitacbt.itacbtdes
   end record   
   
   define l_linha1   char(40)
   define l_linha2   char(40)
   define l_flg_ok   char(1)

   initialize lr_plano_cob.* to null

   if c_ctc92m03[arr_aux].itaasisrvcod    is null or
      c_ctc92m03[arr_aux].rsrcaogrtcod    is null or
      c_ctc92m03[arr_aux].itarsrcaosrvcod is null or
      c_ctc92m03[arr_aux].ubbcod          is null or
      c_ctc92m03[arr_aux].itaasisrvcod    = " " or
      c_ctc92m03[arr_aux].rsrcaogrtcod    = " " or
      c_ctc92m03[arr_aux].itarsrcaosrvcod = " " or
      c_ctc92m03[arr_aux].ubbcod          = " " then
      error "Inclusao cancelada. Todos os campos devem ser preenchidos."
      return false
   end if

   
   whenever error continue
   open c_ctc92m03_012 using c_ctc92m03[arr_aux].itaasisrvcod
                            ,c_ctc92m03[arr_aux].rsrcaogrtcod
                            ,c_ctc92m03[arr_aux].itarsrcaosrvcod
                            ,c_ctc92m03[arr_aux].ubbcod
   fetch c_ctc92m03_012 into lr_plano_cob.*
   whenever error stop
   close c_ctc92m03_012

   if lr_plano_cob.itaasiplncod is not null then
      let l_linha1 = lr_plano_cob.itaasiplncod clipped, " - ", lr_plano_cob.itaasiplndes clipped
      let l_linha2 = lr_plano_cob.itacbtcod clipped, " - ", lr_plano_cob.itacbtdes clipped

            call cts08g01("A", "N",
                          "ESTA REGRA JA ESTA CADASTRADA",
                          "PARA OUTRO PLANO/COBERTURA:",
                          l_linha1,
                          l_linha2)
            returning l_flg_ok
   
      error "Inclusao cancelada. Esta regra ja esta cadastrada para outro Plano/Cobertura."
      return false
   end if

   error "Aguarde..."

   whenever error continue
   execute p_ctc92m03_011 using c_ctc92m03[arr_aux].itaasisrvcod
                               ,c_ctc92m03[arr_aux].rsrcaogrtcod
                               ,c_ctc92m03[arr_aux].itarsrcaosrvcod
                               ,c_ctc92m03[arr_aux].ubbcod
                               ,b_ctc92m03.itacbtcod
                               ,a_ctc92m03.itaasiplncod
                               ,g_issk.funmat 
                               ,g_issk.empcod
                               ,g_issk.usrtip                                 
   whenever error stop

   if sqlca.sqlcode <> 0 then
      error "Erro (", sqlca.sqlcode clipped, ") ao inserir REGRA. Tabela <datkitacbtintrgr>."
      sleep 3
      return false
   end if

   error "Inclusao realizada com sucesso."
   return true


#========================================================================
 end function  # Fim da funcao ctc92m03_insere_regra
#========================================================================

#========================================================================
 function ctc92m03_exclui_regra()
#========================================================================
   define l_flg_ok char(1)

   call cts08g01("C", "S",
                 " ",
                 "CONFIRMA EXCLUSAO",
                 "DA REGRA SELECIONADA?",
                 " ")
   returning l_flg_ok

   if l_flg_ok = "S" then

      error "Aguarde..."

      whenever error continue
      execute p_ctc92m03_006 using c_ctc92m03[arr_aux].itaasisrvcod
                                  ,c_ctc92m03[arr_aux].rsrcaogrtcod
                                  ,c_ctc92m03[arr_aux].itarsrcaosrvcod
                                  ,c_ctc92m03[arr_aux].ubbcod
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error "Erro (", sqlca.sqlcode clipped, ") ao excluir REGRA. Tabela <datkitacbtintrgr>."
         sleep 3
         return false
      end if

      error "Exclusao realizada com sucesso."
   else
      return false
   end if

   return true
#========================================================================
 end function  # Fim da funcao ctc92m03_exclui_regra
#========================================================================


#========================================================================
 function ctc92m03_proximo()
#========================================================================
   let int_flag = false

   if b_ctc92m03.itacbtcod = " " or
      b_ctc92m03.itacbtcod is null then
      let b_ctc92m03.itacbtcod = 0
   end if

   whenever error continue
      open c_ctc92m03_003 using a_ctc92m03.itaasiplncod, b_ctc92m03.itacbtcod
      fetch c_ctc92m03_003 into b_ctc92m03.itacbtcod, b_ctc92m03.itacbtdes
      close c_ctc92m03_003
   whenever error stop
   display by name b_ctc92m03.*

   if b_ctc92m03.itacbtcod = " " or
      b_ctc92m03.itacbtdes is null or
      b_ctc92m03.itacbtdes = " " then
      error " Nao existem coberturas nesta direcao!"
   end if

#========================================================================
 end function  # Fim da funcao ctc92m03_proximo
#========================================================================

#========================================================================
 function ctc92m03_anterior()
#========================================================================
   let int_flag = false

   if b_ctc92m03.itacbtcod = " " or
      b_ctc92m03.itacbtcod is null then
      let b_ctc92m03.itacbtcod = 0
   end if

   whenever error continue
      open c_ctc92m03_004 using a_ctc92m03.itaasiplncod, b_ctc92m03.itacbtcod
      fetch c_ctc92m03_004 into b_ctc92m03.itacbtcod, b_ctc92m03.itacbtdes
      close c_ctc92m03_004
   whenever error stop
   display by name b_ctc92m03.*

   if b_ctc92m03.itacbtcod = " " or
      b_ctc92m03.itacbtdes is null or
      b_ctc92m03.itacbtdes = " " then
      error " Nao existem coberturas nesta direcao!"
   end if

#========================================================================
 end function  # Fim da funcao ctc92m03_anterior
#========================================================================


#========================================================================
 function ctc92m03_preenche_regras()
#========================================================================
   define l_index smallint

   initialize c_ctc92m03 to null

   let l_index = 1

   whenever error continue
   open c_ctc92m03_005 using a_ctc92m03.itaasiplncod,
                             b_ctc92m03.itacbtcod
   whenever error stop

   foreach c_ctc92m03_005 into c_ctc92m03[l_index].itaasisrvcod
                              ,c_ctc92m03[l_index].ubbcod
                              ,c_ctc92m03[l_index].vcltipdes
                              ,c_ctc92m03[l_index].rsrcaogrtcod
                              ,c_ctc92m03[l_index].itarsrcaosrvcod

      let c_ctc92m03[l_index].controle = ""
      let l_index = l_index + 1

      if l_index > 500 then
         error " Limite excedido! Foram encontradas mais de 500 regras cadastradas!"
         exit foreach
      end if

   end foreach

   return l_index
#========================================================================
 end function  # Fim da funcao ctc92m03_preenche_regra
#========================================================================

#========================================================================
 function ctc92m03_preenche_funcionario()
#========================================================================
   whenever error continue
   open c_ctc92m03_013 using c_ctc92m03[arr_aux].itaasisrvcod
                            ,c_ctc92m03[arr_aux].ubbcod
                            ,c_ctc92m03[arr_aux].rsrcaogrtcod
                            ,c_ctc92m03[arr_aux].itarsrcaosrvcod
   fetch c_ctc92m03_013 into d_ctc92m03.atldat
                            ,d_ctc92m03.atlusr
   whenever error stop
   close c_ctc92m03_013
   
   let d_ctc92m03.atlusr = upshift(d_ctc92m03.atlusr)

   display by name d_ctc92m03.*
#========================================================================
 end function  # Fim da funcao ctc92m03_preenche_funcionario
#========================================================================

#========================================================================
 function ctc92m03_inclui()
#========================================================================
   define l_inclusao smallint
   define l_regras   smallint
   define l_plano    char(40)
   define l_flg_ok   char(1)

   define lr_plano record
       itaasiplncod        like datkitaasipln.itaasiplncod
      ,itaasiplndes        like datkitaasipln.itaasiplndes
   end record   

   initialize lr_plano to null
   initialize b_ctc92m03.* to null
   display by name b_ctc92m03.*

   call ctc92m03_input("v")
   
   let l_inclusao = false
   let l_regras   = false

   input by name b_ctc92m03.* without defaults

     #--------------------
      before field itacbtcod
     #--------------------
         display by name b_ctc92m03.itacbtcod
         let l_inclusao = false

     #--------------------
      after field itacbtcod
     #--------------------
         call ctc92m03_preenche_cobertura()

         if b_ctc92m03.itacbtcod = " " or
            b_ctc92m03.itacbtcod is null then
            # Se usuario nao digitou um valor para codigo, buscar o proximo
            call ctc92m03_retorna_proximo_cbtcod()
               returning b_ctc92m03.itacbtcod
            display by name b_ctc92m03.itacbtcod            
            
            let l_inclusao = true
            next field itacbtdes
         end if

         if b_ctc92m03.itacbtdes is null or
            b_ctc92m03.itacbtdes = " " then
            # Se nao encontrou descricao eh uma inclusao nova
            
            let l_inclusao = true
            next field itacbtdes
         end if         

         call ctc92m03_retorna_plano_regra_cob()
            returning lr_plano.*

         if lr_plano.itaasiplncod is not null then
         
            let l_plano = lr_plano.itaasiplncod clipped, "-",
                          lr_plano.itaasiplndes
         
            call cts08g01("A", "N",
                          "ESTA COBERTURA NAO PODE SER SELECIONADA",
                          "POIS ESTA ASSOCIADA AO SEGUINTE PLANO:",
                          l_plano,
                          " ")
            returning l_flg_ok
            
            initialize b_ctc92m03.* to null
            display by name b_ctc92m03.*
            
            next field itacbtcod
         else
            call cts08g01("C", "S",
                          " ",
                          "ESTA COBERTURA JA EXISTE.",
                          "DESEJA SELECIONA-LA?",
                          " ")            
            returning l_flg_ok
            
            if l_flg_ok <> "S" then
               call ctc92m03_retorna_proximo_cbtcod()
                  returning b_ctc92m03.itacbtcod
               let b_ctc92m03.itacbtdes = null
               display by name b_ctc92m03.*      
               let l_inclusao = true
            else
               let l_regras   = true
            end if
            
         end if
         

     #--------------------
      before field itacbtdes
     #--------------------
         if not l_inclusao then
            exit input
         end if

     #--------------------
      after field itacbtdes
     #--------------------
         if b_ctc92m03.itacbtdes = " " or
            b_ctc92m03.itacbtdes is null then
            
            error " A descricao da cobertura nao pode ser deixada em branco."
            next field itacbtdes
         end if
         
         if ctc92m03_insere_cobertura() then
            let l_regras   = true
         end if

     #--------------------
      on key (interrupt)
     #--------------------
         exit input

   end input

   if l_regras then
      call ctc92m03_input("c")
   else
      call ctc92m03_input("v")
   end if

   initialize b_ctc92m03.* to null
   display by name b_ctc92m03.*


#========================================================================
 end function  # Fim da funcao ctc92m03_inclui
#========================================================================



#========================================================================
 function ctc92m03_input(lr_param)
#========================================================================

   define lr_param record
      operacao char(1)
   end record

   define l_index    smallint
   define l_flg_ok   char(1)
   define l_operacao char(1)
   define l_count    smallint
   define l_temp     char(50)

   while true

      call ctc92m03_preenche_regras()
         returning arr_aux

      message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

      if lr_param.operacao = " " or
         lr_param.operacao is null then
         let l_operacao = "c"
      else
         let l_operacao = lr_param.operacao
      end if

      call set_count(arr_aux - 1)
      input array c_ctc92m03 without defaults from s2_ctc92m03.*

        #------------------
         before row
        #------------------
            let arr_aux = arr_curr()
            let scr_aux = scr_line()

            if l_operacao = "v" then
               display c_ctc92m03[arr_aux].* to s2_ctc92m03[scr_aux].* attribute(normal)
               let int_flag = true
               exit input
            end if

            display c_ctc92m03[arr_aux].* to s2_ctc92m03[scr_aux].* attribute(reverse)
            call ctc92m03_preenche_funcionario()

        #------------------
         after row
        #------------------
            display c_ctc92m03[arr_aux].* to s2_ctc92m03[scr_aux].* attribute(normal)

        #--------------------
         before field controle
        #--------------------
            if l_operacao = "i" then
               display c_ctc92m03[arr_aux].* to s2_ctc92m03[scr_aux].* attribute(normal)
               next field itaasisrvcod
            end if

        #--------------------
         before field itaasisrvcod
        #--------------------
            display c_ctc92m03[arr_aux].itaasisrvcod to
               s2_ctc92m03[scr_aux].itaasisrvcod attribute(reverse)

        #--------------------
         after field itaasisrvcod
        #--------------------
            let l_count = 0
            call ctc92m03_verifica_servico_assist()
               returning l_count
            if l_count <= 0 then
               call cto00m10_popup(6) returning c_ctc92m03[arr_aux].itaasisrvcod,
                                                l_temp
            end if
            display c_ctc92m03[arr_aux].itaasisrvcod to
               s2_ctc92m03[scr_aux].itaasisrvcod attribute(normal)
            next field ubbcod

        #--------------------
         before field ubbcod
        #--------------------
            display c_ctc92m03[arr_aux].ubbcod to
               s2_ctc92m03[scr_aux].ubbcod attribute(reverse)

        #--------------------
         after field ubbcod
        #--------------------
            call ctc92m03_preenche_ubb()
            if c_ctc92m03[arr_aux].ubbcod = " " or
               c_ctc92m03[arr_aux].vcltipdes is null or
               c_ctc92m03[arr_aux].vcltipdes = " " then
               call cto00m10_popup(15) returning c_ctc92m03[arr_aux].ubbcod,
                                                 c_ctc92m03[arr_aux].vcltipdes
               call ctc92m03_preenche_ubb()
            end if
            display c_ctc92m03[arr_aux].ubbcod to
               s2_ctc92m03[scr_aux].ubbcod attribute(normal)

            # Se for UNIBANCO, os dois ultimos campos são preenchidos com um valor padrao
            #if c_ctc92m03[arr_aux].ubbcod > 0 then
            #   let c_ctc92m03[arr_aux].rsrcaogrtcod = 0
            #   let c_ctc92m03[arr_aux].itarsrcaosrvcod = 999
            #
            #   display c_ctc92m03[arr_aux].rsrcaogrtcod to
            #      s2_ctc92m03[scr_aux].rsrcaogrtcod attribute(normal)
            #
            #   display c_ctc92m03[arr_aux].itarsrcaosrvcod to
            #      s2_ctc92m03[scr_aux].itarsrcaosrvcod attribute(normal)
            #
            #   if not ctc92m03_insere_regra() then
            #      display c_ctc92m03[arr_aux].* to s2_ctc92m03[scr_aux].* attribute(normal)
            #      let int_flag = false
            #      exit input
            #   end if
            #   let l_operacao = "c"
            #   display c_ctc92m03[arr_aux].* to s2_ctc92m03[scr_aux].* attribute(reverse)
            #   next field controle
            #else
            #   next field rsrcaogrtcod
            #end if            
            
            next field rsrcaogrtcod 


        #--------------------
         before field rsrcaogrtcod
        #--------------------
            display c_ctc92m03[arr_aux].rsrcaogrtcod to
               s2_ctc92m03[scr_aux].rsrcaogrtcod attribute(reverse)

        #--------------------
         after field rsrcaogrtcod
        #--------------------
            let l_count = 0
            call ctc92m03_verifica_garantia()
               returning l_count
            if l_count <= 0 then
               call cto00m10_popup(11) returning c_ctc92m03[arr_aux].rsrcaogrtcod,
                                                 l_temp

            end if
            display c_ctc92m03[arr_aux].rsrcaogrtcod to
               s2_ctc92m03[scr_aux].rsrcaogrtcod attribute(normal)
            next field itarsrcaosrvcod


        #--------------------
         before field itarsrcaosrvcod
        #--------------------
            display c_ctc92m03[arr_aux].itarsrcaosrvcod to
               s2_ctc92m03[scr_aux].itarsrcaosrvcod attribute(reverse)

        #--------------------
         after field itarsrcaosrvcod
        #--------------------
            let l_count = 0
            call ctc92m03_verifica_serv_carro_reserva()
               returning l_count
            if l_count <= 0 then
               call cto00m10_popup(4) returning c_ctc92m03[arr_aux].itarsrcaosrvcod,
                                                l_temp

            end if
            display c_ctc92m03[arr_aux].itarsrcaosrvcod to
               s2_ctc92m03[scr_aux].itarsrcaosrvcod attribute(normal)

            if not ctc92m03_insere_regra() then
               display c_ctc92m03[arr_aux].* to s2_ctc92m03[scr_aux].* attribute(normal)
               let int_flag = false
               exit input
            end if

            display c_ctc92m03[arr_aux].* to s2_ctc92m03[scr_aux].* attribute(reverse)
            let l_operacao = "c"
            next field controle

        #--------------------
         after field controle
        #--------------------
            let c_ctc92m03[arr_aux].controle = " "

            if fgl_lastkey() = fgl_keyval("down") and
               c_ctc92m03[arr_aux + 1].itaasisrvcod is null then
                  next field controle
            end if

            if fgl_lastkey() = fgl_keyval("right") or
               fgl_lastkey() = fgl_keyval("left") or
               fgl_lastkey() = fgl_keyval("return") then
                  next field controle
            end if

            if fgl_lastkey() = fgl_keyval("up") and
               arr_aux -1 <= 0 then
                  next field controle
            end if


        #--------------------
         before delete
        #--------------------
            if not ctc92m03_exclui_regra() then
               display c_ctc92m03[arr_aux].* to s2_ctc92m03[scr_aux].* attribute(normal)
               let int_flag = false
               exit input
            end if

        #--------------------
         before insert
        #--------------------
            let l_operacao = "i"
            display c_ctc92m03[arr_aux].* to s2_ctc92m03[scr_aux].* attribute(normal)

      end input

      if int_flag  then
         exit while
      end if

   end while

   let int_flag = false
   message " "

#========================================================================
 end function  # Fim da funcao ctc92m03_input
#========================================================================

