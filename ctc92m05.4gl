###########################################################################
# Nome do Modulo: ctc92m05                                                #
#                                                                         #
# Associacao do Plano de Assistencia aos Assuntos                Jan/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

   define m_prep     smallint
   define m_mens     char(80)
   define arr_aux    smallint
   define scr_aux    smallint


   define a_ctc92m05 record
       itaasiplncod        like datkitaasipln.itaasiplncod
      ,itaasiplndes        like datkitaasipln.itaasiplndes
   end record

   define b_ctc92m05 array[500] of record
       astcod              like datritaasiplnast.astcod 
      ,c24astdes           like datkassunto.c24astdes  
      ,itaasiplntipcod     like datkasttip.itaasiplntipcod
      ,itaasiplntipdes     like datkasttip.itaasiplntipdes
      ,evtctbflg           like datritaasiplnast.evtctbflg
      ,sinflg              like datritaasiplnast.sinflg         
   end record

   define d_ctc92m05 record
       atldat              like datkitacbtintrgr.atldat
      ,atlusr              char(50)
   end record

#========================================================================
function ctc92m05_prepare()
#========================================================================
   define l_sql char(800)

   let l_sql = "SELECT itaasiplndes ",
               "FROM datkitaasipln ",
               "WHERE itaasiplncod = ? "
   prepare p_ctc92m05_001 from l_sql
   declare c_ctc92m05_001 cursor with hold for p_ctc92m05_001

   let l_sql = "SELECT PLN.atldat, NVL(FUN.funnom,'') ",     
               "FROM datritaasiplnast PLN ",                
               "LEFT JOIN isskfunc FUN ",                    
               "   ON (PLN.atlmat    = FUN.funmat ",         
               "   AND PLN.atlemp    = FUN.empcod ",         
               "   AND PLN.atlusrtip = FUN.usrtip) ",        
               "WHERE PLN.itaasiplncod = ?  ",
               "  AND PLN.astcod = ? "
   prepare p_ctc92m05_002 from l_sql
   declare c_ctc92m05_002 cursor with hold for p_ctc92m05_002

   let l_sql = " SELECT PLN.astcod                                      ",
               "        ,NVL(ASS.c24astdes,'')                          ",
               "        ,NVL(TPA.itaasiplntipcod,'')                    ",
               "        ,NVL(TPA.itaasiplntipdes,'')                    ",
               "        ,NVL(PLN.evtctbflg,'')                          ",
               "        ,NVL(PLN.sinflg,'')                             ",
               "   FROM datritaasiplnast PLN                            ",
               "  LEFT JOIN datkassunto ASS                             ",
               "          ON ASS.c24astcod = PLN.astcod                 ",
               "  LEFT JOIN datkasttip TPA                              ",
               "          ON TPA.itaasiplntipcod = PLN.itaasiplntipcod  ",
               "  WHERE PLN.itaasiplncod = ?                            "
   prepare p_ctc92m05_003 from l_sql
   declare c_ctc92m05_003 cursor with hold for p_ctc92m05_003

   let l_sql = "SELECT c24astdes        ",
               "FROM datkassunto        ",
               "WHERE c24astcod = ?     ",
               "  AND c24astagp IN      ",
               "    (SELECT c24astagp   ",
               "     FROM datkastagp    ",
               "     WHERE ciaempcod = 84) ",
               "  AND itaasstipcod = 2  "     # Somente assunto de SERVICO (2) datkassunto
   prepare p_ctc92m05_004 from l_sql
   declare c_ctc92m05_004 cursor with hold for p_ctc92m05_004

   let l_sql = "DELETE ",
               "FROM datritaasiplnast ",
               "WHERE itaasiplncod = ? ",
               "AND   astcod = ? "
   prepare p_ctc92m05_005 from l_sql

   let l_sql = "SELECT COUNT(*) ",
               "FROM datritaasiplnast ",
               "WHERE itaasiplncod = ? ",
               "AND   astcod = ? "
   prepare p_ctc92m05_006 from l_sql
   declare c_ctc92m05_006 cursor with hold for p_ctc92m05_006

   let l_sql = "INSERT INTO datritaasiplnast ",
               "(itaasiplncod, astcod, itaasiplntipcod, evtctbflg, sinflg, atlusrtip, atlemp, atlmat, atldat) ",
               " VALUES (?, ?, ?, ?, ?, ?, ?, ?, today) "
   prepare p_ctc92m05_007 from l_sql

   let l_sql = "UPDATE datritaasiplnast ",
               "SET evtctbflg = ? ",
               "   ,atlusrtip =? ",
               "   ,atlemp = ? ",
               "   ,atlmat = ? ",
               "   ,atldat = today ",
               "   ,itaasiplntipcod =? ",
               "   ,sinflg =? ",
               "WHERE itaasiplncod = ? ",
               "AND   astcod = ? "
   prepare p_ctc92m05_008 from l_sql

   let l_sql =  '  SELECT itaasiplntipcod       '
               ,'       , itaasiplntipdes       '
               ,'    FROM datkasttip      '
               ,'  WHERE itaasiplntipcod IN (5,6,7)' # Apenas PAI, FILHO e HIBRIDO
               ,'  ORDER BY itaasiplntipcod     '

   prepare p_ctc92m05_009 from l_sql
   declare c_ctc92m05_009 cursor for p_ctc92m05_009

   let l_sql =  '  SELECT itaasiplntipdes       '
               ,'    FROM datkasttip            '
               ,'   WHERE itaasiplntipcod = ?   '

   prepare p_ctc92m05_010 from l_sql
   declare c_ctc92m05_010 cursor for p_ctc92m05_010

   let m_prep = true

#========================================================================
end function # Fim da ctc92m05_prepare
#========================================================================


#========================================================================
function ctc92m05(lr_param)
#========================================================================

   define lr_param record
      itaasiplncod      like datkitaasipln.itaasiplncod
   end record

   let int_flag = false
   initialize a_ctc92m05.*  to null
   initialize d_ctc92m05.*  to null

   if m_prep = false or
      m_prep is null then
      call ctc92m05_prepare()
   end if

   options delete key F2
   options insert key F1

#   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO
#   let g_issk.funmat = 6118
#   let g_issk.empcod = 1
#   let g_issk.usrtip = 'F'
#   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO   

   open window ctc92m05 at 6,2 with form "ctc92m05"
      attribute(form line first, message line first +17 ,comment line first +16)

   let a_ctc92m05.itaasiplncod = lr_param.itaasiplncod

   call ctc92m05_preenche_plano_assistencia()

   if a_ctc92m05.itaasiplncod = " " or
      a_ctc92m05.itaasiplndes is null or
      a_ctc92m05.itaasiplndes = " " then
      error " Codigo do plano invalido. Selecione um plano valido para acessar coberturas."
      close window ctc92m05
      return
   end if

   call ctc92m05_input()


   close window ctc92m05

#========================================================================
end function # Fim da ctc92m05
#========================================================================

#========================================================================
function ctc92m05_preenche_plano_assistencia()
#========================================================================
   let a_ctc92m05.itaasiplndes = null
   whenever error continue
      open c_ctc92m05_001 using a_ctc92m05.itaasiplncod
      fetch c_ctc92m05_001 into a_ctc92m05.itaasiplndes
      close c_ctc92m05_001
   whenever error stop
   display by name a_ctc92m05.*

#========================================================================
end function # Fim da funcao ctc92m05_preenche_plano_assistencia()
#========================================================================


#========================================================================
 function ctc92m05_insere()
#========================================================================
   define l_count    smallint

   if a_ctc92m05.itaasiplncod       is null  or
      b_ctc92m05[arr_aux].astcod    is null  or
      b_ctc92m05[arr_aux].evtctbflg is null  or
      a_ctc92m05.itaasiplncod    = " "       or
      b_ctc92m05[arr_aux].astcod    = " "    or
      (b_ctc92m05[arr_aux].evtctbflg <> "S"  and
       b_ctc92m05[arr_aux].evtctbflg <> "N") then
      error "Inclusao cancelada. Todos os campos devem ser preenchidos."
      sleep 2
      return false
   end if

   whenever error continue
   open c_ctc92m05_006 using a_ctc92m05.itaasiplncod
                            ,b_ctc92m05[arr_aux].astcod
   fetch c_ctc92m05_006 into l_count
   whenever error stop
   close c_ctc92m05_006

   if l_count is not null and
      l_count > 0 then
      error "Inclusao cancelada. Assunto ja associado ao plano selecionado."
      sleep 2
      return false
   end if

   error "Aguarde..."


   whenever error continue
   execute p_ctc92m05_007 using a_ctc92m05.itaasiplncod
                               ,b_ctc92m05[arr_aux].astcod
                               ,b_ctc92m05[arr_aux].itaasiplntipcod
                               ,b_ctc92m05[arr_aux].evtctbflg
                               ,b_ctc92m05[arr_aux].sinflg
                               ,g_issk.usrtip 
                               ,g_issk.empcod
                               ,g_issk.funmat
   whenever error stop

   if sqlca.sqlcode <> 0 then
      error "Erro (", sqlca.sqlcode clipped, ") ao inserir ASSUNTO. Tabela <datritaasiplnast>."
      sleep 2
      return false
   end if

   error "Inclusao realizada com sucesso."
   return true

#========================================================================
 end function  # Fim da funcao ctc92m05_insere
#========================================================================

#========================================================================
 function ctc92m05_exclui()
#========================================================================
   define l_flg_ok char(1)

   call cts08g01("C", "S",
                 " ",
                 "CONFIRMA EXCLUSAO",
                 "DO ASSUNTO SELECIONADO ?",
                 " ")
   returning l_flg_ok

   if l_flg_ok = "S" then

      error "Aguarde..."

      whenever error continue
      execute p_ctc92m05_005 using a_ctc92m05.itaasiplncod
                                  ,b_ctc92m05[arr_aux].astcod
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error "Erro (", sqlca.sqlcode clipped, ") ao excluir ASSUNTO. Tabela <datritaasiplnast>."
         sleep 3
         return false
      end if

      error "Exclusao realizada com sucesso."
   else
      return false
   end if

   return true
#========================================================================
 end function  # Fim da funcao ctc92m05_exclui
#========================================================================

#========================================================================
 function ctc92m05_atualiza()
#========================================================================
   define l_count    smallint

   if a_ctc92m05.itaasiplncod       is null  or
      b_ctc92m05[arr_aux].astcod    is null  or
      b_ctc92m05[arr_aux].evtctbflg is null  or
      a_ctc92m05.itaasiplncod    = " "       or
      b_ctc92m05[arr_aux].astcod    = " "    or
      (b_ctc92m05[arr_aux].evtctbflg <> "S"  and
       b_ctc92m05[arr_aux].evtctbflg <> "N") then
      error "Alteracao cancelada. Todos os campos devem ser preenchidos."
      sleep 2
      return false
   end if


   error "Aguarde..."

   whenever error continue
   execute p_ctc92m05_008 using b_ctc92m05[arr_aux].evtctbflg
                               ,g_issk.usrtip 
                               ,g_issk.empcod
                               ,g_issk.funmat
                               ,b_ctc92m05[arr_aux].itaasiplntipcod
                               ,b_ctc92m05[arr_aux].sinflg
                               ,a_ctc92m05.itaasiplncod
                               ,b_ctc92m05[arr_aux].astcod

   whenever error stop

   if sqlca.sqlcode <> 0 then
      error "Erro (", sqlca.sqlcode clipped, ") ao atualizar ASSUNTO. Tabela <datritaasiplnast>."
      sleep 3
      return false
   end if

   error "Alteracao realizada com sucesso."
   return true
#========================================================================
 end function  # Fim da funcao ctc92m05_exclui
#========================================================================

#========================================================================
 function ctc92m05_preenche_dados()
#========================================================================
   define l_index smallint

   initialize b_ctc92m05 to null

   let l_index = 1

   whenever error continue
   open c_ctc92m05_003 using a_ctc92m05.itaasiplncod
   whenever error stop

   foreach c_ctc92m05_003 into b_ctc92m05[l_index].astcod         
                              ,b_ctc92m05[l_index].c24astdes      
                              ,b_ctc92m05[l_index].itaasiplntipcod
                              ,b_ctc92m05[l_index].itaasiplntipdes
                              ,b_ctc92m05[l_index].evtctbflg      
                              ,b_ctc92m05[l_index].sinflg         
      
      let l_index = l_index + 1

      if l_index > 500 then
         error " Limite excedido! Foram encontradas mais de 500 regras cadastradas!"
         exit foreach
      end if

   end foreach

   return l_index
#========================================================================
 end function  # Fim da funcao ctc92m05_preenche_dados
#========================================================================

#========================================================================
 function ctc92m05_preenche_assunto()
#========================================================================
   let b_ctc92m05[arr_aux].c24astdes = null
   
   whenever error continue
   open c_ctc92m05_004 using b_ctc92m05[arr_aux].astcod
   fetch c_ctc92m05_004 into b_ctc92m05[arr_aux].c24astdes
   whenever error stop
   close c_ctc92m05_004

   display b_ctc92m05[arr_aux].c24astdes to
      s2_ctc92m05[scr_aux].c24astdes attribute(normal)
#========================================================================
 end function  # Fim da funcao ctc92m05_preenche_dados
#========================================================================

#========================================================================
 function ctc92m05_preenche_funcionario()
#========================================================================
   whenever error continue
   open c_ctc92m05_002 using a_ctc92m05.itaasiplncod
                            ,b_ctc92m05[arr_aux].astcod
   fetch c_ctc92m05_002 into d_ctc92m05.atldat
                            ,d_ctc92m05.atlusr
   whenever error stop
   close c_ctc92m05_002
   
   let d_ctc92m05.atlusr = upshift(d_ctc92m05.atlusr)

   display by name d_ctc92m05.*
#========================================================================
 end function  # Fim da funcao ctc92m05_preenche_funcionario
#========================================================================


#========================================================================
 function ctc92m05_input()
#========================================================================

   define l_flg_ok   char(1)
   define l_operacao char(1)
   define l_evtctbflg_ant   like datritaasiplnast.evtctbflg  
   define l_sinflg_ant      like datritaasiplnast.sinflg  
   define l_astcod_ant      like datritaasiplnast.astcod
   define l_itaasiplntipcod like datritaasiplnast.itaasiplntipcod

   while true

      call ctc92m05_preenche_dados()
         returning arr_aux

      message " (F17)Abandona, (F1)Inclui, (F2)Exclui"


      if arr_aux - 1 <= 0 then
         let l_operacao = "i"
         error "Nenhum registro encontrado. Inclua novos."
      else
         let l_operacao = "c"
      end if


      call set_count(arr_aux - 1)
      input array b_ctc92m05 without defaults from s2_ctc92m05.*

        #-----------------------------
         before row
        #-----------------------------
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            
            if b_ctc92m05[arr_aux].astcod is null or 
               b_ctc92m05[arr_aux].astcod = " "   or
               b_ctc92m05[arr_aux].astcod = ""    then
               let l_operacao = "i"
            end if

# display l_operacao 
# display b_ctc92m05[arr_aux].astcod
# display b_ctc92m05[arr_aux].itaasiplntipcod
# display b_ctc92m05[arr_aux].evtctbflg
# display b_ctc92m05[arr_aux].sinflg
 
 
            if l_operacao = "c" then
               display b_ctc92m05[arr_aux].* to
                  s2_ctc92m05[scr_aux].* attribute(reverse)
            else
               display b_ctc92m05[arr_aux].* to
                  s2_ctc92m05[scr_aux].* attribute(normal)
            end if

            call ctc92m05_preenche_funcionario()

        #-----------------------------
         before insert
        #-----------------------------
            let l_operacao = "i"

        #-----------------------------
         before field astcod
        #-----------------------------
            let l_astcod_ant = b_ctc92m05[arr_aux].astcod
            display b_ctc92m05[arr_aux].astcod to
                    s2_ctc92m05[scr_aux].astcod attribute(reverse)
            
            if b_ctc92m05[arr_aux].astcod is null or
               b_ctc92m05[arr_aux].astcod = "" then
               let l_operacao = 'i'
            end if        
               
        #-----------------------------
         after field astcod
        #-----------------------------
            if l_operacao <> "i" then
               let b_ctc92m05[arr_aux].astcod = l_astcod_ant
            end if

            if fgl_lastkey() = fgl_keyval("down") and
               b_ctc92m05[arr_aux + 1].astcod is null and
               b_ctc92m05[arr_aux].astcod is null then
                  let l_operacao = "c"
                  next field astcod
            end if

            if fgl_lastkey() = fgl_keyval("up") and
               arr_aux - 1 <= 0 then
                  let l_operacao = "c"
                  next field astcod
            end if

            call ctc92m05_preenche_assunto()

             if fgl_lastkey() <> fgl_keyval("up") and
                fgl_lastkey() <> fgl_keyval("left") and
                fgl_lastkey() <> fgl_keyval("down") then
       
               if b_ctc92m05[arr_aux].c24astdes is null or
                  b_ctc92m05[arr_aux].c24astdes = " " then
                  
                  if b_ctc92m05[arr_aux].astcod is null or
                     b_ctc92m05[arr_aux].astcod = '' then
                     display b_ctc92m05[arr_aux].* to
                             s2_ctc92m05[scr_aux].* attribute(normal)
                     error 'Digite um codigo de assunto valido!'
                   else
                     error " Assunto não encontrado ou nao permitido. Digite um codigo valido."
                     let b_ctc92m05[arr_aux].astcod = ''
                   end if
                  
                  next field astcod
               end if
            else
               let b_ctc92m05[arr_aux].astcod = l_astcod_ant

               display b_ctc92m05[arr_aux].astcod to
                       s2_ctc92m05[scr_aux].astcod attribute(normal)

               call ctc92m05_preenche_assunto() 
               let l_operacao = "c"
            end if
            
            display b_ctc92m05[arr_aux].astcod to
                    s2_ctc92m05[scr_aux].astcod attribute(normal)

        #-----------------------------h
         before field itaasiplntipcod
        #-----------------------------
             display b_ctc92m05[arr_aux].itaasiplntipcod to
                     s2_ctc92m05[scr_aux].itaasiplntipcod attribute(reverse)
                     let l_itaasiplntipcod = b_ctc92m05[arr_aux].itaasiplntipcod

        #-----------------------------
         after field itaasiplntipcod
        #-----------------------------
             display b_ctc92m05[arr_aux].itaasiplntipcod to
                     s2_ctc92m05[scr_aux].itaasiplntipcod attribute(normal)
                     
             if fgl_lastkey() <> fgl_keyval("up") and 
                fgl_lastkey() <> fgl_keyval("left") then         
                
                if b_ctc92m05[arr_aux].itaasiplntipcod is null then
                   call ctc92m05_popup()
                      returning b_ctc92m05[arr_aux].itaasiplntipcod
                              , b_ctc92m05[arr_aux].itaasiplntipdes
                else
                   whenever error continue
                     open c_ctc92m05_010 using b_ctc92m05[arr_aux].itaasiplntipcod
                     fetch c_ctc92m05_010 into b_ctc92m05[arr_aux].itaasiplntipdes
                   whenever error continue
                   
                   if sqlca.sqlcode <> 0 then
                      if sqlca.sqlcode <> 100 then
                         error 'Erro (',sqlca.sqlcode,') na selecao de dados (datkasttip)'
                      else
                         error 'Tipo de Assunto nao existe!'
                         next field itaasiplntipcod
                      end if
                   end if
                end if
             else
                if fgl_lastkey() = fgl_keyval("down") and
                   b_ctc92m05[arr_aux + 1].itaasiplntipcod is null and
                   b_ctc92m05[arr_aux].itaasiplntipcod is null then
                      let l_operacao = "c"
                      next field itaasiplntipcod
                end if
               
                if fgl_lastkey() = fgl_keyval("up") and
                   arr_aux - 1 <= 0 then
                      let l_operacao = "c"
                      next field itaasiplntipcod
                end if
             end if
             display b_ctc92m05[arr_aux].itaasiplntipcod to
                     s2_ctc92m05[scr_aux].itaasiplntipcod attribute(normal)
                     
             display b_ctc92m05[arr_aux].itaasiplntipdes to
                     s2_ctc92m05[scr_aux].itaasiplntipdes attribute(normal)

        #-----------------------------
         before field evtctbflg
        #-----------------------------
            let l_evtctbflg_ant = null
            let l_evtctbflg_ant = b_ctc92m05[arr_aux].evtctbflg
            display b_ctc92m05[arr_aux].evtctbflg to
               s2_ctc92m05[scr_aux].evtctbflg attribute(reverse)

        #-----------------------------
         after field evtctbflg
        #-----------------------------
        
            if fgl_lastkey() = fgl_keyval("down") and
               b_ctc92m05[arr_aux + 1].evtctbflg is null and
               b_ctc92m05[arr_aux].evtctbflg is null then               
                  let l_operacao = "c"
                  next field evtctbflg
            end if

            if fgl_lastkey() = fgl_keyval("up") and
               arr_aux - 1 <= 0 then
                  let l_operacao = "c"
                  next field evtctbflg
            end if
                    
            if fgl_lastkey() <> fgl_keyval("down") and 
               fgl_lastkey() <> fgl_keyval("up") and 
               fgl_lastkey() <> fgl_keyval("left") then

               if (b_ctc92m05[arr_aux].evtctbflg is null or
                     (b_ctc92m05[arr_aux].evtctbflg <> "S" and
                      b_ctc92m05[arr_aux].evtctbflg <> "N")) then
                  error " Digite apenas S ou N para este campo." 
                  let b_ctc92m05[arr_aux].evtctbflg = l_evtctbflg_ant
                  next field evtctbflg
               end if
               
            else
               let b_ctc92m05[arr_aux].evtctbflg = l_evtctbflg_ant
            end if
            
            display b_ctc92m05[arr_aux].evtctbflg to
               s2_ctc92m05[scr_aux].evtctbflg attribute(normal)

        #-----------------------------
         before field sinflg
        #-----------------------------
            let l_sinflg_ant = null
            let l_sinflg_ant = b_ctc92m05[arr_aux].sinflg
            display b_ctc92m05[arr_aux].sinflg to
               s2_ctc92m05[scr_aux].sinflg attribute(reverse)

        #-----------------------------
         after field sinflg
        #-----------------------------
        
            if fgl_lastkey() = fgl_keyval("down") and
               b_ctc92m05[arr_aux + 1].sinflg is null and
               b_ctc92m05[arr_aux].sinflg is null then               
                  let l_operacao = "c"
                  next field sinflg
            end if

            if fgl_lastkey() = fgl_keyval("up") and
               arr_aux - 1 <= 0 then
                  let l_operacao = "c"
                  next field sinflg
            end if
                    
            if fgl_lastkey() <> fgl_keyval("down") and 
               fgl_lastkey() <> fgl_keyval("up") and 
               fgl_lastkey() <> fgl_keyval("left") then

               if (b_ctc92m05[arr_aux].sinflg is null or
                   (b_ctc92m05[arr_aux].sinflg <> "S" and
                    b_ctc92m05[arr_aux].sinflg <> "N")
                  )then
                  error " Digite apenas S ou N para este campo." 
                  let b_ctc92m05[arr_aux].sinflg = l_sinflg_ant
                  next field sinflg
               end if

               if (l_operacao <> "i" ) and  
                  ( ( b_ctc92m05[arr_aux].sinflg           <>          l_sinflg_ant                  )or
                    ( b_ctc92m05[arr_aux].evtctbflg        <>          l_evtctbflg_ant               )or
                    ( b_ctc92m05[arr_aux].itaasiplntipcod  <>          l_itaasiplntipcod             )or 
                    ( b_ctc92m05[arr_aux].astcod           <>          l_astcod_ant                  )or
                    ( b_ctc92m05[arr_aux].sinflg           is not null and l_sinflg_ant      is null )or
                    ( b_ctc92m05[arr_aux].evtctbflg        is not null and l_evtctbflg_ant   is null )or
                    ( b_ctc92m05[arr_aux].itaasiplntipcod  is not null and l_itaasiplntipcod is null )or
                    ( b_ctc92m05[arr_aux].astcod           is not null and l_astcod_ant      is null ) 
                  ) then
                 
                  let l_flg_ok = null
               
                  call cts08g01("C", "S",
                                " ",
                                "Confirma alteracao deste registro?",
                                " ",
                                " ")
                  returning l_flg_ok
                  
                  if l_flg_ok = "S" then
                     let l_operacao = "a"
                  else
                     let b_ctc92m05[arr_aux].sinflg = l_sinflg_ant
                  end if
               end if
            
            
            else
               let b_ctc92m05[arr_aux].sinflg = l_sinflg_ant
            end if
            
            display b_ctc92m05[arr_aux].sinflg to
               s2_ctc92m05[scr_aux].sinflg attribute(normal)

        #-----------------------------
         after row
        #-----------------------------
            if l_operacao = 'i' then
               if not ctc92m05_insere() then
                  let int_flag = false
                  exit input
               end if
            end if
            if l_operacao = 'a' then
               if not ctc92m05_atualiza() then
                  let int_flag = false
                  exit input
               end if
            end if
                        
            let l_operacao = "c"
            display b_ctc92m05[arr_aux].* to s2_ctc92m05[scr_aux].* attribute(normal)
            
        #-----------------------------
         before delete
        #-----------------------------
          if b_ctc92m05[arr_aux].astcod is null then
             continue input
          else           
             if not ctc92m05_exclui() then
           #    display b_ctc92m05[arr_aux].* to s2_ctc92m05[scr_aux].* attribute(normal)
                let int_flag = false
                exit input
             end if
          end if

        #-----------------------------
         on key (interrupt)
        #-----------------------------
            let int_flag = true
            exit input            

      end input

      if int_flag  then
         let int_flag = false
         exit while
      end if

   end while

   let int_flag = false
   message " "

#========================================================================
 end function  # Fim da funcao ctc92m05_input
#========================================================================

#========================================================================
 function ctc92m05_popup()
#========================================================================
 define a_ctc92m05a array[500] of record
        itaasiplntipcod     like datkasttip.itaasiplntipcod
       ,itaasiplntipdes     like datkasttip.itaasiplntipdes
 end record
 
 define l_pi    smallint
 define arr_pop smallint

 initialize a_ctc92m05a to null
 let l_pi = 1
   whenever error continue
     open c_ctc92m05_009
   whenever error stop
  
   foreach c_ctc92m05_009 into a_ctc92m05a[l_pi].itaasiplntipcod
                             , a_ctc92m05a[l_pi].itaasiplntipdes
     let l_pi = l_pi + 1 
   end foreach
  
  open window w_ctc92m05a at 9,17 with form "ctc92m05a" attribute(form line first, border)

  call set_count(l_pi - 1)
  display array a_ctc92m05a to s_ctc92m05a.*
        
        #-----------------------------
          on key (F8)
        #-----------------------------
             let arr_pop = arr_curr()
             exit display 
                     
        #-----------------------------
         on key (interrupt)
        #-----------------------------
             error 'Tecle F8 para escolher o tipo de Assunto'
      
  end display 
  
  close window w_ctc92m05a
  
  return a_ctc92m05a[arr_pop].itaasiplntipcod
       , a_ctc92m05a[arr_pop].itaasiplntipdes 

#========================================================================
 end function  # Fim da funcao ctc92m05_popup
#========================================================================
