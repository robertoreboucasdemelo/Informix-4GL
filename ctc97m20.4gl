###########################################################################
# Nome do Modulo: ctc97m20                                                #
#                                                                         #
# Tipo Inconsistencia Arquivo Assistencia Itau Residencia        SET/2012 #
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
   define m_errflg   char(1)
   define msg        char(80)
   define m_versao   integer

   define m_mens char(80)

   define a_ctc97m20 array[2000] of record
       marca               char(1)
      ,versao              like datmresitaarqcrgic.vrscod
      ,linha               like datmresitaarqcrgic.linnum
      ,process             like datmresitaarqcrgic.pcmnum
      ,apolice             like datmresitaarqcrgic.aplnum
      ,item                like datmresitaarqcrgic.itmnum
      ,incons              char(50)
      ,imped               like datmresitaarqcrgic.ipvicoflg
   end record

   define a2_ctc97m20 array[2000] of record
       campo            like datmresitaarqcrgic.icocponom
      ,conteudo         like datmresitaarqcrgic.icocpocuddes
      ,operacao         like datmresitaarqdet.movsttcod
   end record

   define a3_ctc97m20 record
       filversao        like datmresitaarqcrgic.vrscod
      ,fildtini         date
      ,fildtfim         date
      ,filapol          like datmresitaarqcrgic.aplnum
      ,filimped         like datmresitaarqcrgic.ipvicoflg
   end record

   define a4_ctc97m20 record
       qtd  integer
   end record

   define a5_ctc97m20 array[2000] of record
       itaciacod  like datmresitaapl.itaciacod
      ,itaramcod  like datmresitaapl.itaramcod
      ,aplseqnum  like datmresitaapl.aplseqnum
      ,incvigdat  like datmresitaapl.incvigdat
      ,fnlvigdat  like datmresitaapl.fnlvigdat
   end record
#========================================================================
function ctc97m20_prepare()
#========================================================================
   define l_sql char(800)

   let l_sql = "SELECT INCON.vrscod, INCON.pcmnum, INCON.linnum, INCON.iconum ",
               "FROM datmresitaarqcrgic INCON ",
               "INNER JOIN datmresitaarqpcmhs PROCESS ",
               "   ON INCON.vrscod = PROCESS.vrscod ",
               "  AND INCON.pcmnum = PROCESS.pcmnum ",
               "WHERE INCON.aplnum = ? ",
               "AND INCON.livicoflg = 'N' ",
               "AND INCON.ipvicoflg = 'S' ",
               "ORDER BY PROCESS.pcminihordat, INCON.vrscod, INCON.linnum "
   prepare p_ctc97m20_002 from l_sql
   declare c_ctc97m20_002 cursor with hold for p_ctc97m20_002

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmresitaarqcrgic ",
               "WHERE aplnum = ? ",
               "AND   livicoflg = 'N' "
   prepare p_ctc97m20_003 from l_sql
   declare c_ctc97m20_003 cursor with hold for p_ctc97m20_003

   let l_sql = "SELECT vrscod,linnum,ciacod,ramcod,aplnum "
              ,",aplitmnum,viginidat,vigfimdat,prpnum "
              ,",prdcod,plncod,empcod,srvcod,segnom  "
              ,",pestipcod,cpjcpfcod,seglgdnom,seglgdnum "
              ,",seglcacplnom,segbrrnom,segcidnom,segestsgl "
              ,",segcepcod,dddcod,telnum,rsclgdnom,rsclgdnum  "
              ,",rsclcacpldes,rscbrrnom,rsccidnom  "
              ,",rscestsgl,rsccepcod, rscsegcbttipcod,restipcod "
              ,",imvtipcod,movsttcod,adnicldat,pcmdat,sgmtipcod "
              ,",suscod "
              ,"FROM datmresitaarqdet "
              ,"WHERE vrscod = ? "
              ,"AND   linnum = ? "
              ,"ORDER BY ciacod, ramcod, aplnum, linnum "

   prepare p_ctc97m20_004 from l_sql
   declare c_ctc97m20_004 cursor with hold for p_ctc97m20_004

   let l_sql = "SELECT MAX(aplseqnum) ",
               "FROM datmresitaapl ",
               "WHERE itaciacod = ? ",
               "AND itaramcod = ? ",
               "AND aplnum = ? "
   prepare p_ctc97m20_005 from l_sql
   declare c_ctc97m20_005 cursor with hold for p_ctc97m20_005

   let l_sql = "SELECT segcpjcpfnum,cpjordnum,cpjcpfdignum ",
               "FROM datmresitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   aplnum = ? ",
               "AND   aplseqnum = ? "
   prepare p_ctc97m20_006 from l_sql
   declare c_ctc97m20_006 cursor with hold for p_ctc97m20_006

   let l_sql = "SELECT NVL(MAX(aplseqnum),0) + 1 ",
               "FROM datmresitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   aplnum = ? "
   prepare p_ctc97m20_007 from l_sql
   declare c_ctc97m20_007 cursor with hold for p_ctc97m20_007

   let l_sql = "SELECT itaciacod, itaramcod, aplnum, aplseqnum, itmnum ",
               "FROM datmresitaarqcrgic ",
               "WHERE vrscod = ? ",
               "AND   linnum = ? ",
               "AND   pcmnum = ? "
   prepare p_ctc97m20_008 from l_sql
   declare c_ctc97m20_008 cursor with hold for p_ctc97m20_008


   let l_sql = "SELECT srvcod ",
               "FROM datmresitaaplitm ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   aplnum = ? ",
               "AND   aplseqnum = ? ",
               "AND   aplitmnum = ? "
   prepare p_ctc97m20_009 from l_sql
   declare c_ctc97m20_009 cursor with hold for p_ctc97m20_009

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmresitaarqcrgic INCON ",
               "INNER JOIN datmresitaarqpcmhs HIST ",
               "   ON HIST.vrscod = INCON.vrscod ",
               "  AND HIST.pcmnum = INCON.pcmnum ",
               "INNER JOIN datmresitaarqdet DETALHE ",
               "   ON DETALHE.vrscod = INCON.vrscod ",
               "  AND DETALHE.linnum = INCON.linnum ",
               "LEFT JOIN datkitaasiarqicotip TIPO ON (TIPO.itaasiarqicotipcod = INCON.itaasiarqicotipcod) ",
               "WHERE INCON.livicoflg = 'N' "
   prepare p_ctc97m20_010 from l_sql
   declare c_ctc97m20_010 cursor with hold for p_ctc97m20_010

   let l_sql = "SELECT INCON.vrscod, INCON.pcmnum, INCON.linnum, DETALHE.movsttcod, ",
               "       INCON.aplnum, INCON.ipvicoflg ",
               "FROM datmresitaarqcrgic INCON ",
               "INNER JOIN datmresitaarqpcmhs HIST ",
               "   ON HIST.vrscod = INCON.vrscod ",
               "  AND HIST.pcmnum = INCON.pcmnum ",
               "INNER JOIN datmresitaarqdet DETALHE ",
               "   ON DETALHE.vrscod = INCON.vrscod ",
               "  AND DETALHE.linnum = INCON.linnum ",
               "LEFT JOIN datkitaasiarqicotip TIPO ON (TIPO.itaasiarqicotipcod = INCON.itaasiarqicotipcod) ",
               "WHERE INCON.livicoflg = 'N' ",
               "ORDER BY 1, 3, 2 "
   prepare p_ctc97m20_011 from l_sql
   declare c_ctc97m20_011 cursor with hold for p_ctc97m20_011
   let l_sql = "UPDATE datmresitaarqcrgic SET livicoflg = 'C' " ,
               "WHERE vrscod = ?"                               ,
               "AND   pcmnum = ?"                               ,
               "AND   linnum = ?"
   prepare p_ctc97m20_012 from l_sql
   let l_sql = "SELECT incvigdat,       ",
               "       fnlvigdat        ",
               "FROM datmresitaapl      ",
               "WHERE itaciacod = ?     ",
               "AND itaramcod  = ?      ",
               "AND aplnum     = ?      ",
               "AND aplseqnum  = ?      "
   prepare p_ctc97m20_013 from l_sql
   declare c_ctc97m20_013 cursor with hold for p_ctc97m20_013

   let m_prep = true

#========================================================================
end function # Fim da ctc97m20_prepare
#========================================================================

#========================================================================
function ctc97m20_consulta_inconsistencias()
#========================================================================
   define l_sql char(800)
   define l_sql1 char(100)
   define l_sql2 char(100)
   define l_sql3 char(200)
   define l_sql4 char(100)

   let l_sql1 = ""
   let l_sql2 = ""
   let l_sql3 = ""
   let l_sql4 = ""

   if a3_ctc97m20.filversao is not null then
      let l_sql1 = " AND   INCON.vrscod = ", a3_ctc97m20.filversao clipped
   end if

   if a3_ctc97m20.filapol is not null then
      let l_sql2 = " AND   INCON.aplnum       = ", a3_ctc97m20.filapol clipped
   end if

   if a3_ctc97m20.fildtini is not null and a3_ctc97m20.fildtfim is not null then
      let l_sql3 = " AND   to_date(to_char(HIST.pcshordat,'%d/%m/%Y'), '%d/%m/%Y') ",
                   " BETWEEN to_date('", a3_ctc97m20.fildtini clipped, "','%d/%m/%Y') ",
                   " AND to_date('", a3_ctc97m20.fildtfim clipped, "','%d/%m/%Y') "
   end if

   if a3_ctc97m20.filimped is not null and a3_ctc97m20.filimped <> " " then
      let l_sql4 = " AND INCON.ipvicoflg = '", a3_ctc97m20.filimped, "' "
   end if


   let l_sql = "SELECT INCON.vrscod, INCON.linnum, INCON.pcmnum, INCON.itaciacod, INCON.itaramcod, ",
               "       INCON.aplnum, INCON.itmnum, INCON.aplseqnum, NVL(TIPO.itaasiarqicotipdes,'DESCONHECIDO'), ",
               "       INCON.ipvicoflg, INCON.icocponom, INCON.icocpocuddes, DETALHE.movsttcod ",
               "FROM datmresitaarqcrgic INCON ",
               "INNER JOIN datmresitaarqpcmhs HIST ",
               "   ON HIST.vrscod = INCON.vrscod ",
               "  AND HIST.pcmnum = INCON.pcmnum ",
               "INNER JOIN datmresitaarqdet DETALHE ",
               "   ON DETALHE.vrscod = INCON.vrscod ",
               "  AND DETALHE.linnum = INCON.linnum ",
               "LEFT JOIN datkitaasiarqicotip TIPO ON (TIPO.itaasiarqicotipcod = INCON.itaasiarqicotipcod) ",
               "WHERE INCON.livicoflg = 'N' ",
               l_sql1 clipped, " ",
               l_sql2 clipped, " ",
               l_sql3 clipped, " ",
               l_sql4 clipped, " ",
               "ORDER BY 1, 3, 2 "
   prepare p_ctc97m20_001 from l_sql

   declare c_ctc97m20_001 cursor with hold for p_ctc97m20_001

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmresitaarqcrgic INCON ",
               "INNER JOIN datmresitaarqpcmhs HIST ",
               "   ON HIST.vrscod = INCON.vrscod ",
               "  AND HIST.pcmnum = INCON.pcmnum ",
               "INNER JOIN datmresitaarqdet DETALHE ",
               "   ON DETALHE.vrscod = INCON.vrscod ",
               "  AND DETALHE.linnum = INCON.linnum ",
               "LEFT JOIN datkitaasiarqicotip TIPO ON (TIPO.itaasiarqicotipcod = INCON.itaasiarqicotipcod) ",
               "WHERE INCON.livicoflg = 'N' ",
               l_sql1 clipped, " ",
               l_sql2 clipped, " ",
               l_sql3 clipped, " ",
               l_sql4 clipped, " "
   prepare p_ctc97m20_000 from l_sql

   declare c_ctc97m20_000 cursor with hold for p_ctc97m20_000


#========================================================================
end function # Fim da ctc97m20_consulta_inconsistencias
#========================================================================

#========================================================================
function ctc97m20_input()
#========================================================================
   define l_index       smallint
   define arr_aux       smallint
   define scr_aux       smallint
   define l_prox_arr    smallint
   define l_reconsulta  smallint
   define l_flg_ok      char(1)
   define l_count       smallint
   define l_count_apl   smallint
   define l_count_ico   smallint
   define l_acumul      smallint
   define l_loop        smallint

   define l_linha1      char(40)
   define l_linha2      char(40)
   define l_linha3      char(40)
   define l_linha4      char(40)

   define lr_chave_apolice record
      itaciacod     like datmresitaaplitm.itaciacod
     ,itaramcod     like datmresitaaplitm.itaramcod
     ,itaaplnum     like datmresitaaplitm.aplnum
     ,aplseqnum     like datmresitaaplitm.aplseqnum
     ,itaaplitmnum  like datmresitaaplitm.aplitmnum
     ,operacao      char(1)
   end record

   define l_aplnum_ant like datmresitaaplitm.aplnum

   let int_flag = false
   let l_reconsulta = false

   let m_versao = 0

   if m_prep is null or
      m_prep = false then
      call ctc97m20_prepare()
   end if

   initialize a4_ctc97m20.* to null

   open window w_ctc97m20 at 4,2 with form 'ctc97m20'
      attribute(form line first, message line first +19 ,comment line first +18, border)


   while true
      message "                                    (F17)Abandonar"

      if not l_reconsulta then
         initialize a3_ctc97m20.* to null
         input by name a3_ctc97m20.* without defaults
           #--------------------
            on key (interrupt, control-c)
           #--------------------
               let int_flag = true
               exit input

           #--------------------
            after field fildtfim
           #--------------------
               if (a3_ctc97m20.fildtfim is null and
                   a3_ctc97m20.fildtini is not null) or
                  (a3_ctc97m20.fildtfim is not null and
                   a3_ctc97m20.fildtini is null) then
                  error " As datas de inicio e fim devem ser preenchidas."
                  next field fildtini
               end if

           #--------------------
            after field filimped
           #--------------------
               if a3_ctc97m20.filimped is not null then
                  let a3_ctc97m20.filimped = upshift(a3_ctc97m20.filimped)
                  display by name a3_ctc97m20.filimped
               end if

               if a3_ctc97m20.filimped is not null and
                  a3_ctc97m20.filimped <> "S" and
                  a3_ctc97m20.filimped <> "N" then
                  error "Preencha apenas 'S' ou 'N'."
                  let a3_ctc97m20.filimped = null
                  display by name a3_ctc97m20.filimped
                  next field filimped
               end if

         end input
      else
         let l_reconsulta = false
         display by name a3_ctc97m20.*
      end if

      if int_flag then
         let int_flag = false
         exit while
      end if

      initialize a_ctc97m20 to null
      initialize a5_ctc97m20 to null
      let l_index = 1

      call ctc97m20_consulta_inconsistencias()

      whenever error continue
      open c_ctc97m20_000
      fetch c_ctc97m20_000 into a4_ctc97m20.qtd

      whenever error stop
      close c_ctc97m20_000

      display by name a4_ctc97m20.qtd attribute(reverse)

      whenever error continue
      open c_ctc97m20_001
      whenever error stop

      foreach c_ctc97m20_001 into a_ctc97m20[l_index].versao
                                 ,a_ctc97m20[l_index].linha
                                 ,a_ctc97m20[l_index].process
                                 ,a5_ctc97m20[l_index].itaciacod
                                 ,a5_ctc97m20[l_index].itaramcod
                                 ,a_ctc97m20[l_index].apolice
                                 ,a_ctc97m20[l_index].item
                                 ,a5_ctc97m20[l_index].aplseqnum
                                 ,a_ctc97m20[l_index].incons
                                 ,a_ctc97m20[l_index].imped
                                 ,a2_ctc97m20[l_index].campo
                                 ,a2_ctc97m20[l_index].conteudo
                                 ,a2_ctc97m20[l_index].operacao

         call ctc97m20_recupera_vigencia(a5_ctc97m20[l_index].itaciacod
                                        ,a5_ctc97m20[l_index].itaramcod
                                        ,a_ctc97m20[l_index].apolice
                                        ,a5_ctc97m20[l_index].aplseqnum)
         returning a5_ctc97m20[l_index].incvigdat,
                   a5_ctc97m20[l_index].fnlvigdat
         let l_index = l_index + 1

         if l_index > 2000 then
            error " Limite excedido! Foram encontrados mais de 2000 registros!"
            exit foreach
         end if

      end foreach

      close c_ctc97m20_001

      let arr_aux = l_index
      if arr_aux = 1  then
         error "Nenhum registro encontrado..."
         continue while
      end if


      message "(F7)Remover, (F8)Tratar, (F9)Reprocessar, (F10)Reprocessar Todos, (F17)Voltar"

      call set_count(arr_aux - 1)
      input array a_ctc97m20 without defaults from s_ctc97m20.*

        #--------------------
         before field marca
        #--------------------
            display a_ctc97m20[arr_aux].* to s_ctc97m20[scr_aux].* attribute(reverse)



            display by name  a2_ctc97m20[arr_aux].campo
                            ,a2_ctc97m20[arr_aux].conteudo
                            ,a2_ctc97m20[arr_aux].operacao
                            ,a5_ctc97m20[arr_aux].incvigdat
                            ,a5_ctc97m20[arr_aux].fnlvigdat

        #--------------------
         after field marca
        #--------------------


            if a_ctc97m20[arr_aux].marca <> "X" or
               a_ctc97m20[arr_aux].apolice is null then
               let a_ctc97m20[arr_aux].marca = " "
            end if

            if fgl_lastkey() = fgl_keyval("down") or
               fgl_lastkey() = fgl_keyval("right") or
               fgl_lastkey() = fgl_keyval("enter") then
               if a_ctc97m20[arr_aux + 1].versao is null then
                  next field marca
               end if
            end if

            if fgl_lastkey() = fgl_keyval("up") or
               fgl_lastkey() = fgl_keyval("left") then
               if arr_aux -1 <= 0 then
                  next field marca
               end if
            end if

            display a_ctc97m20[arr_aux].* to s_ctc97m20[scr_aux].*

        #------------------
         before row
        #------------------
            let arr_aux = arr_curr()
            let scr_aux = scr_line()

        #--------------------
         before insert
        #--------------------
            next field marca

        #--------------------
         before delete
        #--------------------
            next field marca

        #--------------------
         on key (accept)
        #--------------------
            continue input

        #--------------------
         on key (interrupt, control-c)
        #--------------------
            let int_flag = false
            clear form
            exit input

        #--------------------
         on key (F7)
        #--------------------
            if a5_ctc97m20[arr_aux].fnlvigdat < today or
               a5_ctc97m20[arr_aux].incvigdat is null or
               a5_ctc97m20[arr_aux].fnlvigdat is null then
               call cts08g01("C", "S","","DESEJA REMOVER", "O REGISTRO?","")
               returning l_flg_ok
                
               if l_flg_ok = "S" then
                   
                  call ctc97m20_remove(a_ctc97m20[arr_aux].versao  ,
                                       a_ctc97m20[arr_aux].process ,
                                       a_ctc97m20[arr_aux].linha   )
                  let int_flag = false
                  clear form
                  let l_reconsulta = true
                  exit input
                
               end if
            else
               error "Apolice dentro da vigencia nao pode ser removida!"
            end if
        #--------------------
         on key (F8)
        #--------------------
            if a_ctc97m20[arr_aux].imped = 'S' then
               # Inconsistencias impeditivas devem ser tratadas na tabela de movimento
               # e tentar carregar novamente.
               if a2_ctc97m20[arr_aux].operacao = 'I' then
                  call ctc97m21_input(a_ctc97m20[arr_aux].versao, a_ctc97m20[arr_aux].linha)
               end if
               if a2_ctc97m20[arr_aux].operacao = 'C' then
                  call ctc97m21_input(a_ctc97m20[arr_aux].versao, a_ctc97m20[arr_aux].linha)
               end if

            else
               # Inconsistencias nao impeditivas ja foram carregadas e devem ser
               # corrigidas diretamente na apolice
               initialize lr_chave_apolice.* to null

               whenever error continue
               open c_ctc97m20_008 using a_ctc97m20[arr_aux].versao
                                        ,a_ctc97m20[arr_aux].linha
                                        ,a_ctc97m20[arr_aux].process
               fetch c_ctc97m20_008 into lr_chave_apolice.itaciacod
                                         ,lr_chave_apolice.itaramcod
                                         ,lr_chave_apolice.itaaplnum
                                         ,lr_chave_apolice.aplseqnum
                                         ,lr_chave_apolice.itaaplitmnum
               whenever error stop
               close c_ctc97m20_008

               let lr_chave_apolice.operacao = a2_ctc97m20[arr_aux].operacao


            end if



        #--------------------
         on key (F9)
        #--------------------

            let l_flg_ok = "N"
            let l_count = 0
            let l_count_apl = 0
            let l_count_ico = 0
            let l_linha1 = " "
            let l_linha2 = " "
            let l_linha3 = " "
            let l_linha4 = " "
            let l_loop = 1
            let l_aplnum_ant = 0

            while l_loop <= 2000

               if  a_ctc97m20[l_loop].marca = "X" and
                   a_ctc97m20[l_loop].apolice is not null then

                  if l_aplnum_ant <> a_ctc97m20[l_loop].apolice then
                     whenever error continue
                     open c_ctc97m20_003 using a_ctc97m20[l_loop].apolice
                     fetch c_ctc97m20_003 into l_count
                     whenever error stop
                     close c_ctc97m20_003

                     let l_count_apl = l_count_apl + 1
                     let l_count_ico = l_count_ico + l_count
                     let l_count = 0
                  end if

                  let l_aplnum_ant = a_ctc97m20[l_loop].apolice

               end if

               let l_loop = l_loop + 1

            end while


            if l_count_apl >= 1 then
               call cty22g02_trim(l_count_apl)
               returning l_linha1

               call cty22g02_trim(l_count_ico)
               returning l_linha2
               let l_linha1 = l_linha1 clipped , " apolice(s) selecionada(s)."
               let l_linha2 = "Existem ", l_linha2 clipped , " inconsistencia(s) "
               let l_linha3 = "para as apolices selecionadas."
               let l_linha4 = "Confirma o Reprocessamento?"

               call cts08g01("C", "S",
                             l_linha1,
                             l_linha2,
                             l_linha3,
                             l_linha4)
               returning l_flg_ok

               if l_flg_ok = "S" then

                  error "Aguarde. Reprocessando..."
                  sleep 1

                  # Processa primeiro todas as inconsistencias impeditivas selecionadas
                  let l_loop = 1
                  while l_loop <= 2000
                     if a_ctc97m20[l_loop].marca = 'X' and
                        a_ctc97m20[l_loop].imped = 'S' then
                        call ctc97m20_processa_recarga_impeditiva(a_ctc97m20[l_loop].apolice)
                     end if
                     let l_loop = l_loop + 1
                  end while

                  # Na sequencia processa todas as inconsistencias nao impeditivas selecionadas
                  let l_loop = 1
                  while l_loop <= 2000
                     if a_ctc97m20[l_loop].marca = 'X' and
                        a_ctc97m20[l_loop].imped = 'N' then
                        call ctc97m20_processa_recarga_nao_impeditiva(a_ctc97m20[l_loop].versao
                                                                     ,a_ctc97m20[l_loop].process
                                                                     ,a_ctc97m20[l_loop].linha
                                                                     ,a2_ctc97m20[l_loop].operacao)

                     end if
                     let l_loop = l_loop + 1
                  end while

                  error "Reprocessamento finalizado."
                  sleep 2
                  let int_flag = false
                  clear form
                  let l_reconsulta = true
                  exit input
               end if

            end if

            #--------------------
             on key (F10)
            #--------------------

              call ctc97m20_reprocessa_todos()


      end input

   end while

   let int_flag = false

   close window w_ctc97m20

#========================================================================
end function # Fim da funcao ctc97m20_input()
#========================================================================

#=================================================================
function ctc97m20_processa_recarga_impeditiva(lr_param)
#=================================================================

   define lr_param record
      apolice     like datmresitaarqcrgic.aplnum
   end record


   define lr_dados record
       itaasiarqvrsnum  	 like datmresitaarqdet.vrscod
      ,itaasiarqlnhnum  	 like datmresitaarqdet.linnum
      ,itaciacod        	 like datmresitaarqdet.ciacod
      ,itaramcod        	 like datmresitaarqdet.ramcod
      ,itaaplnum        	 like datmresitaarqdet.aplnum
      ,itaaplitmnum     	 like datmresitaarqdet.aplitmnum
      ,itaaplvigincdat  	 like datmresitaarqdet.viginidat
      ,itaaplvigfnldat  	 like datmresitaarqdet.vigfimdat
      ,itaprpnum        	 like datmresitaarqdet.prpnum
      ,itaprdcod        	 like datmresitaarqdet.prdcod
      ,itaplncod        	 like datmresitaarqdet.plncod
      ,itaempasicod     	 like datmresitaarqdet.empcod
      ,itaasisrvcod     	 like datmresitaarqdet.srvcod
      ,segnom           	 like datmresitaarqdet.segnom
      ,pestipcod        	 like datmresitaarqdet.pestipcod
      ,segcgccpfnum     	 like datmresitaarqdet.cpjcpfcod
      ,seglgdnom        	 like datmresitaarqdet.seglgdnom
      ,seglgdnum        	 like datmresitaarqdet.seglgdnum
      ,segendcmpdes     	 like datmresitaarqdet.seglcacplnom
      ,segbrrnom        	 like datmresitaarqdet.segbrrnom
      ,segcidnom        	 like datmresitaarqdet.segcidnom
      ,segufdsgl        	 like datmresitaarqdet.segestsgl
      ,segcepnum        	 like datmresitaarqdet.segcepcod
      ,segresteldddnum  	 like datmresitaarqdet.dddcod
      ,segrestelnum     	 like datmresitaarqdet.telnum
      ,rsclcllgdnom     	 like datmresitaarqdet.rsclgdnom
      ,rsclcllgdnum     	 like datmresitaarqdet.rsclgdnum
      ,rsclclendcmpdes  	 like datmresitaarqdet.rsclcacpldes
      ,rsclclbrrnom     	 like datmresitaarqdet.rscbrrnom
      ,rsclclcidnom     	 like datmresitaarqdet.rsccidnom
      ,rsclclufdsgl     	 like datmresitaarqdet.rscestsgl
      ,rsclclcepnum     	 like datmresitaarqdet.rsccepcod
      ,itacobsegcod     	 like datmresitaarqdet.rscsegcbttipcod
      ,itaressegcod     	 like datmresitaarqdet.restipcod
      ,itamrdsegcod     	 like datmresitaarqdet.imvtipcod
      ,mvtsttcod        	 like datmresitaarqdet.movsttcod
      ,adniclhordat     	 like datmresitaarqdet.adnicldat
      ,itapcshordat     	 like datmresitaarqdet.pcmdat
      ,itasegtipcod     	 like datmresitaarqdet.sgmtipcod
      ,corsus           	 like datmresitaarqdet.suscod
      ,itaasiarqvrsnumre	 like datmresitaarqdet.vrscod
      ,auxprdcod           like datmresitaaplitm.prdcod       # DAQUI PRA BAIXO SAO AUXILIARES #
      ,auxsgrplncod        like datmresitaaplitm.plncod
      ,auxempasicod        like datmresitaaplitm.empcod
      ,auxasisrvcod        like datmresitaaplitm.srvcod
      ,auxsegtipcod        like datmresitaapl.sgmcod

   end record

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_apolice_ant record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_hist_process record
       asiarqvrsnum     like datmresitaarqpcmhs.vrscod
      ,pcsseqnum        like datmresitaarqpcmhs.pcmnum
      ,lnhtotqtd        like datmresitaarqpcmhs.lintotnum
      ,pcslnhqtd        like datmresitaarqpcmhs.pdolinnum
   end record

   define lr_inconsistencia record
       asiarqvrsnum     like datmresitaarqcrgic.vrscod
      ,pcsseqnum        like datmresitaarqcrgic.pcmnum
      ,asiarqlnhnum     like datmresitaarqcrgic.linnum
      ,icoseqnum        like datmresitaarqcrgic.iconum
   end record

   define lr_inconsistencia_ant record
       asiarqvrsnum     like datmresitaarqcrgic.vrscod
      ,pcsseqnum        like datmresitaarqcrgic.pcmnum
      ,asiarqlnhnum     like datmresitaarqcrgic.linnum
      ,icoseqnum        like datmresitaarqcrgic.iconum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record


   define l_mens char(80)
   define l_qtd_inconsist smallint
   define l_cont_impedit smallint
   define l_cont_nimpedit smallint
   define l_flg_continua smallint # Flag para controlar o reprocessamento de uma mesma sequencia
   define l_flg_primeiro smallint

   initialize lr_dados.* to null
   initialize lr_hist_process.* to null
   initialize lr_erro.* to null
   initialize lr_apolice_ant.* to null
   initialize lr_inconsistencia.* to null
   initialize lr_inconsistencia_ant.* to null
   let lr_inconsistencia_ant.asiarqvrsnum = 0
   let lr_inconsistencia_ant.pcsseqnum    = 0
   let lr_inconsistencia_ant.asiarqlnhnum = 0
   let lr_inconsistencia_ant.icoseqnum    = 0

   let l_mens = null
   let l_flg_continua = true

   if m_prep is null or
      m_prep = false then
      call ctc97m20_prepare()
   end if



   begin work

   let l_flg_primeiro = true

   # Busca os dados (na ordem correta de reprocessamento) de inconsistencia da apolice selecionada
   whenever error continue
   open c_ctc97m20_002 using lr_param.apolice
   foreach c_ctc97m20_002 into lr_inconsistencia.*


      if l_flg_primeiro then
         call cty22g03_libera_inconsistencia(lr_param.apolice)
         returning lr_erro.*

         if lr_erro.sqlcode <> 0 then
            rollback work
            call ctc97m20_exibe_erro(lr_erro.*)
            return
         end if


         let l_flg_primeiro = false
      end if




      if lr_inconsistencia.asiarqvrsnum = lr_inconsistencia_ant.asiarqvrsnum and
         lr_inconsistencia.asiarqlnhnum = lr_inconsistencia_ant.asiarqlnhnum then
         # Se a versao e a linha forem as mesmas da anterior, significa que ja foi carregado
         # Neste caso entao ignora e passa para o próximo registro.
         # Isso acontece quando uma unica linha do arquivo possui mais de uma inconsistencia

         continue foreach
      end if

      #prompt "Loop principal 2 <ENTER>" for m_mens

      if not (lr_inconsistencia.asiarqvrsnum = lr_inconsistencia_ant.asiarqvrsnum) then
         # Se a versao do arquivo for diferente da anterior, gerar novo processamento


         if lr_hist_process.pcsseqnum > 0 and
            lr_hist_process.asiarqvrsnum > 0 then
            # Para gerar novo processamento, fechar o anterior se existir.
            call cty22g03_encerra_processamento(lr_hist_process.*)
            returning lr_erro.*

            if lr_erro.sqlcode <> 0 then
               rollback work
               call ctc97m20_exibe_erro(lr_erro.*)
               return
            end if
         end if

         initialize lr_hist_process.* to null
         let lr_hist_process.asiarqvrsnum = lr_inconsistencia.asiarqvrsnum
         let lr_hist_process.lnhtotqtd = 0 # Por enquanto nao ha rotina para calcular a qtde de registros a serem processados
         let lr_hist_process.pcslnhqtd = 0

         call cty22g03_gera_processamento(lr_hist_process.*)
         returning lr_erro.*,lr_hist_process.pcsseqnum

         if lr_erro.sqlcode <> 0 then
            rollback work
            call ctc97m20_exibe_erro(lr_erro.*)
            return
         end if


      end if

      # Seleciona os dados do movimento (versao/linha)
      whenever error continue
      open c_ctc97m20_004 using lr_inconsistencia.asiarqvrsnum, lr_inconsistencia.asiarqlnhnum
      fetch c_ctc97m20_004 into lr_dados.itaasiarqvrsnum
                               ,lr_dados.itaasiarqlnhnum
                               ,lr_dados.itaciacod
                               ,lr_dados.itaramcod
                               ,lr_dados.itaaplnum
                               ,lr_dados.itaaplitmnum
                               ,lr_dados.itaaplvigincdat
                               ,lr_dados.itaaplvigfnldat
                               ,lr_dados.itaprpnum
                               ,lr_dados.itaprdcod
                               ,lr_dados.itaplncod
                               ,lr_dados.itaempasicod
                               ,lr_dados.itaasisrvcod
                               ,lr_dados.segnom
                               ,lr_dados.pestipcod
                               ,lr_dados.segcgccpfnum
                               ,lr_dados.seglgdnom
                               ,lr_dados.seglgdnum
                               ,lr_dados.segendcmpdes
                               ,lr_dados.segbrrnom
                               ,lr_dados.segcidnom
                               ,lr_dados.segufdsgl
                               ,lr_dados.segcepnum
                               ,lr_dados.segresteldddnum
                               ,lr_dados.segrestelnum
                               ,lr_dados.rsclcllgdnom
                               ,lr_dados.rsclcllgdnum
                               ,lr_dados.rsclclendcmpdes
                               ,lr_dados.rsclclbrrnom
                               ,lr_dados.rsclclcidnom
                               ,lr_dados.rsclclufdsgl
                               ,lr_dados.rsclclcepnum
                               ,lr_dados.itacobsegcod
                               ,lr_dados.itaressegcod
                               ,lr_dados.itamrdsegcod
                               ,lr_dados.mvtsttcod
                               ,lr_dados.adniclhordat
                               ,lr_dados.itapcshordat
                               ,lr_dados.itasegtipcod
                               ,lr_dados.corsus
                               ,lr_dados.itaasiarqvrsnumre
                               ,lr_dados.auxprdcod
                               ,lr_dados.auxsgrplncod
                               ,lr_dados.auxempasicod
                               ,lr_dados.auxasisrvcod
                               ,lr_dados.auxsegtipcod

      whenever error stop
      close c_ctc97m20_004


      initialize lr_apolice_atual.* to null

      let lr_apolice_atual.ciacod       = lr_dados.itaciacod
      let lr_apolice_atual.ramcod       = lr_dados.itaramcod
      let lr_apolice_atual.aplnum       = lr_dados.itaaplnum
      let lr_apolice_atual.aplseqnum    = null # Sera recuperado a seguir
      let lr_apolice_atual.aplitmnum    = lr_dados.itaaplitmnum
      let lr_apolice_atual.aplitmsttcod = lr_dados.mvtsttcod
      let lr_apolice_atual.qtdinconsist = 0 # Sera recuperado a seguir


      if lr_apolice_atual.ciacod = lr_apolice_ant.ciacod and
         lr_apolice_atual.ramcod = lr_apolice_ant.ramcod and
         lr_apolice_atual.aplnum = lr_apolice_ant.aplnum then
         # Se a apolice atual for a mesma da anterior

         if lr_apolice_atual.aplitmsttcod  = lr_apolice_ant.aplitmsttcod and
            lr_inconsistencia.asiarqvrsnum = lr_inconsistencia_ant.asiarqvrsnum then
            # Se a operacao atual for a mesma da anterior recuperar a sequencia gerada
            # e a quantidade de inconsistencias

            let lr_apolice_atual.aplseqnum = lr_apolice_ant.aplseqnum
            let lr_apolice_atual.qtdinconsist = lr_apolice_ant.qtdinconsist

            if lr_apolice_atual.aplitmnum = lr_apolice_ant.aplitmnum then
               # Erro. Encontrado o mesmo item da apolice mais de uma vez.
               continue foreach
            end if
         else
            # Grava a quantidade de inconsistencias apenas quando for para outro bloco de operacao
            let l_flg_continua = false
            let lr_apolice_atual.qtdinconsist = l_qtd_inconsist
         end if
      else
         # Ao mudar de apolice zerar as inconsistencias
         let l_qtd_inconsist = 0
      end if

      # Incrementar o numero de linhas processadas para este reprocessamento
      let lr_hist_process.pcslnhqtd = lr_hist_process.pcslnhqtd + 1

      let l_cont_impedit = 0
      let l_cont_nimpedit = 0
      call cty22g03_verifica_inconsistencias(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
      returning lr_erro.*, l_cont_impedit, l_cont_nimpedit, lr_dados.*


      if lr_erro.sqlcode <> 0 then
         rollback work
         call ctc97m20_exibe_erro(lr_erro.*)
         return
      end if

      let l_qtd_inconsist = l_qtd_inconsist + l_cont_impedit


      if lr_apolice_atual.aplitmsttcod <> "I" then
         let l_flg_continua = false
      end if

      if l_flg_continua then
         call cty22g03_busca_sequencia_continua(lr_apolice_atual.*)
         returning lr_erro.*, lr_apolice_atual.aplseqnum

         if lr_erro.sqlcode <> 0 then
            rollback work
            call ctc97m20_exibe_erro(lr_erro.*)
            return
         end if

         if lr_apolice_atual.aplseqnum = 0 then
            let lr_apolice_atual.aplseqnum = null
            let l_flg_continua = false
         end if


      end if



      if l_cont_impedit = 0 then
         #Realizar o cancelamento, gravacao da apolice e item apenas se nao houver inconsistencia

         case lr_apolice_atual.aplitmsttcod # Verifica se eh inclusao ou cancelamento

         when 'C' # Processa cancelamento

            call cty22g03_carrega_cancelamento(lr_apolice_atual.*, lr_hist_process.*)
            returning lr_erro.*, lr_apolice_atual.aplseqnum

            if lr_erro.sqlcode <> 0 then
               rollback work
               call ctc97m20_exibe_erro(lr_erro.*)
               return
            end if

         when 'A' # Processa Atualização

            call cty22g03_carrega_Atualizacao(lr_apolice_atual.*,lr_dados.*, lr_hist_process.*)
            returning lr_erro.*, lr_apolice_atual.aplseqnum

            if lr_erro.sqlcode <> 0 then
               rollback work
               call ctc97m20_exibe_erro(lr_erro.*)
               return
            end if


         when 'I' # Processa inclusao

            if lr_apolice_atual.aplseqnum is null then
               # Se ja existir sequencia gravada pula a gravacao da apolice e passa para a gravacao do item
               # Se não existir ainda busca uma nova sequencia

               call cty22g03_gera_sequencia_apolice(lr_apolice_atual.*)
               returning lr_erro.*, lr_apolice_atual.aplseqnum

               if lr_erro.sqlcode <> 0 then
                  rollback work
                  call ctc97m20_exibe_erro(lr_erro.*)
                  return
               end if

               # Carrega a apolice
               call cty22g03_carrega_tabela_apolice(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
               returning lr_erro.*

               if lr_erro.sqlcode <> 0 then
                  rollback work
                  call ctc97m20_exibe_erro(lr_erro.*)
                  return
               end if

            end if


            # Carrega o item da apolice
            call cty22g03_carrega_tabela_item(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
            returning lr_erro.*

            if lr_erro.sqlcode <> 0 then
               rollback work
               call ctc97m20_exibe_erro(lr_erro.*)
               return
            end if

         end case


      end if


      # Atualiza os dados da apolice anterior
      initialize lr_apolice_ant.* to null

      let lr_apolice_ant.ciacod       = lr_apolice_atual.ciacod
      let lr_apolice_ant.ramcod       = lr_apolice_atual.ramcod
      let lr_apolice_ant.aplnum       = lr_apolice_atual.aplnum
      let lr_apolice_ant.aplseqnum    = lr_apolice_atual.aplseqnum
      let lr_apolice_ant.aplitmnum    = lr_apolice_atual.aplitmnum
      let lr_apolice_ant.aplitmsttcod = lr_apolice_atual.aplitmsttcod
      let lr_apolice_ant.qtdinconsist = lr_apolice_atual.qtdinconsist

      # Atualiza os dados da inconsistencia anterior
      let lr_inconsistencia_ant.asiarqvrsnum    = lr_inconsistencia.asiarqvrsnum
      let lr_inconsistencia_ant.pcsseqnum       = lr_inconsistencia.pcsseqnum
      let lr_inconsistencia_ant.asiarqlnhnum    = lr_inconsistencia.asiarqlnhnum
      let lr_inconsistencia_ant.icoseqnum       = lr_inconsistencia.icoseqnum

      let lr_erro.sqlcode = 0
      initialize lr_dados.* to null

   end foreach
   close c_ctc97m20_002



   if lr_erro.sqlcode = 0 then
      # Encerra o processamento atual
      call cty22g03_encerra_processamento(lr_hist_process.*)
      returning lr_erro.*

      if lr_erro.sqlcode <> 0 then
         rollback work
         call ctc97m20_exibe_erro(lr_erro.*)
         return
      end if
   end if

   if lr_erro.sqlcode = 0 then
      commit work
      return
   end if

   rollback work

#=======================================================
end function  # Fim funcao ctc97m20_processa_recarga_impeditiva
#=======================================================


#=================================================================
function ctc97m20_processa_recarga_nao_impeditiva(lr_param)
#=================================================================

   define lr_param record
      itaasiarqvrsnum   like datmresitaarqcrgic.vrscod
     ,pcsseqnum         like datmresitaarqcrgic.pcmnum
     ,itaasiarqlnhnum   like datmresitaarqcrgic.linnum
     ,operacao          char(1)
   end record

   define lr_apolice record
       itaaplnum       like datmresitaapl.aplnum
      ,itaaplitmnum    like datmresitaaplitm.aplitmnum
      ,aplseqnum       like datmresitaapl.aplseqnum
      ,itaciacod       like datmresitaapl.itaciacod
      ,itaramcod       like datmresitaapl.itaramcod
      ,segcgccpfnum    like datmresitaapl.segcpjcpfnum
      ,segcgcordnum    like datmresitaapl.cpjordnum
      ,segcgccpfdig    like datmresitaapl.cpjcpfdignum
      ,itaprdcod       like datmresitaaplitm.prdcod
      ,itaasisrvcod    like datmresitaaplitm.srvcod
      ,itasgrplncod    like datmresitaaplitm.plncod
      ,itaclisgmcod    like datmresitaapl.sgmcod
      ,operacao        char(1)
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_cont_nimpedit smallint

   initialize lr_apolice.* to null
   initialize lr_erro.* to null
   let l_cont_nimpedit = 0

   # Busca a chave da apolice na inconsistencia que esta sendo processada
   whenever error continue
   open c_ctc97m20_008 using lr_param.itaasiarqvrsnum
                            ,lr_param.itaasiarqlnhnum
                            ,lr_param.pcsseqnum
   fetch c_ctc97m20_008 into lr_apolice.itaciacod
                            ,lr_apolice.itaramcod
                            ,lr_apolice.itaaplnum
                            ,lr_apolice.aplseqnum
                            ,lr_apolice.itaaplitmnum
   whenever error stop
   close c_ctc97m20_008

   let lr_apolice.operacao = lr_param.operacao

   # Verifica se a apolice foi encontrada
   if lr_apolice.itaciacod is null or
      lr_apolice.itaramcod is null or
      lr_apolice.itaaplnum is null or
      lr_apolice.aplseqnum is null then

      let lr_erro.mens = "Apolice selecionada nao encontrada."
      call ctc97m20_exibe_erro(lr_erro.*)
      return
   end if

   # Busca os dados da apolice que serao verificados
   whenever error continue
   open c_ctc97m20_006 using lr_apolice.itaciacod
                            ,lr_apolice.itaramcod
                            ,lr_apolice.itaaplnum
                            ,lr_apolice.aplseqnum
   fetch c_ctc97m20_006 into lr_apolice.segcgccpfnum
                            ,lr_apolice.segcgcordnum
                            ,lr_apolice.segcgccpfdig
   whenever error stop
   close c_ctc97m20_006


   # Busca os dados do item da apolice que serao verificados, se existir
   if lr_apolice.itaaplitmnum is not null then

      whenever error continue
      open c_ctc97m20_009 using lr_apolice.itaciacod
                               ,lr_apolice.itaramcod
                               ,lr_apolice.itaaplnum
                               ,lr_apolice.aplseqnum
                               ,lr_apolice.itaaplitmnum
      fetch c_ctc97m20_009 into lr_apolice.itaasisrvcod

      whenever error stop
      close c_ctc97m20_009

   end if



   let l_cont_nimpedit = 0

   # Se estiver ok libera a inconsistencia
   if l_cont_nimpedit = 0 then

      call cty22g03_libera_inconsistencia2(lr_param.itaasiarqvrsnum
                                          ,lr_param.pcsseqnum
                                          ,lr_param.itaasiarqlnhnum)
      returning lr_erro.*

      if lr_erro.sqlcode <> 0 then
         call ctc97m20_exibe_erro(lr_erro.*)
         return
      end if

   end if

#=======================================================
end function  # Fim funcao ctc97m20_processa_recarga_nao_impeditiva
#=======================================================



#=======================================================
function ctc97m20_exibe_erro(lr_erro)
#=======================================================

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   error lr_erro.mens
   sleep 2
   error "Reprocessamento da apolice atual foi cancelada..."
   sleep 2

#=======================================================
end function  # Fim funcao ctc97m20_exibe_erro
#=======================================================

#=================================================================
function ctc97m20_reprocessa_todos()
#=================================================================

define lr_retorno record
    qtd         integer                           ,
    linha1      char(40)                          ,
    linha2      char(40)                          ,
    linha3      char(40)                          ,
    linha4      char(40)                          ,
    confirma    char(1)                           ,
    aplnum      like datmresitaarqcrgic.aplnum    ,
    ipvicoflg   like datmresitaarqcrgic.ipvicoflg ,
    vrscod      like datmresitaarqcrgic.vrscod    ,
    pcmnum      like datmresitaarqcrgic.pcmnum    ,
    linnum      like datmresitaarqcrgic.linnum    ,
    movsttcod   like datmresitaarqdet.movsttcod   ,
    processado  integer
end record

   let lr_retorno.processado = 0

   # Recupera a Quantidade Total de Inconsistencias
   whenever error continue
   open c_ctc97m20_010
   fetch c_ctc97m20_010 into lr_retorno.qtd
   whenever error stop
   close c_ctc97m20_010

   let lr_retorno.linha1 = ""
   let lr_retorno.linha2 = "Confirma o Reprocessamento"
   let lr_retorno.linha3 = "das ", lr_retorno.qtd using '<<<<<<' , " inconsistencia(s) ? "
   let lr_retorno.linha4 = ""


   call cts08g01("C", "S",
                 lr_retorno.linha1,
                 lr_retorno.linha2,
                 lr_retorno.linha3,
                 lr_retorno.linha4)
   returning lr_retorno.confirma

   if lr_retorno.confirma = "N" then
   	  return
   end if


   whenever error continue
   open c_ctc97m20_011
   foreach c_ctc97m20_011 into lr_retorno.vrscod    ,
   	                           lr_retorno.pcmnum    ,
   	                           lr_retorno.linnum    ,
   	                           lr_retorno.movsttcod ,
   	                           lr_retorno.aplnum    ,
                               lr_retorno.ipvicoflg

      if lr_retorno.ipvicoflg = "S" then
         call ctc97m20_processa_recarga_impeditiva(lr_retorno.aplnum)
      end if

      if lr_retorno.ipvicoflg = "N" then
         call ctc97m20_processa_recarga_nao_impeditiva(lr_retorno.vrscod
                                                      ,lr_retorno.pcmnum
                                                      ,lr_retorno.linnum
                                                      ,lr_retorno.movsttcod)

      end if

      let lr_retorno.processado = lr_retorno.processado + 1

      error "ATENCAO - REGISTROS PROCESSADOS: ", lr_retorno.processado using "<<<<<<<<&",
            " DE: ", lr_retorno.qtd  using "<<<<<<<<&"

   end foreach



#=======================================================
end function  # Fim funcao ctc97m20_reprocessa_todos
#=======================================================
#=================================================================
function ctc97m20_remove(lr_param)
#=================================================================
define lr_param record
  vrscod   like  datmresitaarqcrgic.vrscod  ,
  pcmnum   like  datmresitaarqcrgic.pcmnum  ,
  linnum   like  datmresitaarqcrgic.linnum
end record
    whenever error continue
    execute p_ctc97m20_012 using lr_param.vrscod
                                ,lr_param.pcmnum
                                ,lr_param.linnum
    whenever error stop
    if sqlca.sqlcode <> 0 then
       display "Erro (", sqlca.sqlcode clipped, ") na Remocao do Registro."
    end if
#=======================================================
end function  # Fim funcao ctc97m20_remove
#=======================================================
#---------------------------------------------------------
 function ctc97m20_recupera_vigencia(lr_param)
#---------------------------------------------------------
define lr_param record
  itaciacod like datmresitaapl.itaciacod
 ,itaramcod like datmresitaapl.itaramcod
 ,aplnum    like datmresitaapl.aplnum
 ,aplseqnum like datmresitaapl.aplseqnum
end record
define lr_retorno record
	  incvigdat  like datmresitaapl.incvigdat
	 ,fnlvigdat  like datmresitaapl.fnlvigdat
end record
   initialize lr_retorno.* to null
   open c_ctc97m20_013 using lr_param.itaciacod,
                             lr_param.itaramcod,
                             lr_param.aplnum   ,
                             lr_param.aplseqnum
   whenever error continue
   fetch c_ctc97m20_013 into  lr_retorno.incvigdat,
                              lr_retorno.fnlvigdat
   whenever error stop
   return lr_retorno.incvigdat,
          lr_retorno.fnlvigdat
end function