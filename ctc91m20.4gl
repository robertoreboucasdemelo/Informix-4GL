###########################################################################
# Nome do Modulo: ctc91m20                                                #
#                                                                         #
# Tipo Inconsistencia Arquivo Assistencia Itau                   Jan/2011 #
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

   define a_ctc91m20 array[2000] of record
       marca               char(1)
      ,versao              like datmitaasiarqico.itaasiarqvrsnum
      ,linha               like datmitaasiarqico.itaasiarqlnhnum
      ,process             like datmitaasiarqico.pcsseqnum
      ,apolice             like datmitaasiarqico.itaaplnum
      ,item                like datmitaasiarqico.itaaplitmnum
      ,incons              char(50)#like datkitaasiarqicotip.itaasiarqicotipdes #
      ,imped               like datmitaasiarqico.impicoflg
   end record

   define a2_ctc91m20 array[2000] of record
       campo            like datmitaasiarqico.icocponom
      ,conteudo         like datmitaasiarqico.icocpocntdes
      ,operacao         like datmdetitaasiarq.mvtsttcod
      ,itaaplvigincdat  like datmitaapl.itaaplvigincdat
      ,itaaplvigfnldat  like datmitaapl.itaaplvigfnldat
   end record

   define a3_ctc91m20 record
       filversao        like datmitaasiarqico.itaasiarqvrsnum
      ,fildtini         date
      ,fildtfim         date
      ,filapol          like datmitaasiarqico.itaaplnum
      ,filimped         like datmitaasiarqico.impicoflg
   end record

   define ar_param array[2000] of record
   	  itaciacod   like datmitaasiarqico.itaciacod
     ,itaramcod   like datmitaasiarqico.itaramcod
     ,aplseqnum   like datmitaasiarqico.aplseqnum
   end record


#========================================================================
function ctc91m20_prepare()
#========================================================================
   define l_sql char(800)

   let l_sql = "SELECT INCON.itaasiarqvrsnum, INCON.pcsseqnum, INCON.itaasiarqlnhnum, INCON.icoseqnum ",
               "FROM datmitaasiarqico INCON ",
               "INNER JOIN datmitaarqpcshst PROCESS ",
               "   ON INCON.itaasiarqvrsnum = PROCESS.itaasiarqvrsnum ",
               "  AND INCON.pcsseqnum = PROCESS.pcsseqnum ",
               "WHERE INCON.itaaplnum = ? ",
               "AND INCON.libicoflg = 'N' ",
               "AND INCON.impicoflg = 'S' ",
               "ORDER BY PROCESS.arqpcsinchordat, INCON.itaasiarqvrsnum, INCON.itaasiarqlnhnum "
   prepare p_ctc91m20_002 from l_sql
   declare c_ctc91m20_002 cursor with hold for p_ctc91m20_002

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmitaasiarqico ",
               "WHERE itaaplnum = ? ",
               "AND   libicoflg = 'N' "
   prepare p_ctc91m20_003 from l_sql
   declare c_ctc91m20_003 cursor with hold for p_ctc91m20_003

   let l_sql = "SELECT itaasiarqvrsnum,itaasiarqlnhnum,itaciacod,itaramcod,",
               " itaaplnum,itaaplitmnum,itaaplvigincdat,itaaplvigfnldat,itaprpnum,",
               " itaprdcod,itasgrplncod,itaempasicod,itaasisrvcod,rsrcaogrtcod,",
               " segnom,pestipcod,segcgccpfnum,seglgdnom,seglgdnum,segendcmpdes,",
               " segbrrnom,segcidnom,segufdsgl,segcepnum,segresteldddnum,",
               " segrestelnum,autchsnum,autplcnum,autfbrnom,autlnhnom,autmodnom,",
               " autfbrano,autmodano,autcmbnom,autcornom,autpintipdes,",
               " itavclcrgtipcod,mvtsttcod,adniclhordat,itapcshordat,asiincdat,",
               " okmflg,impautflg,itacorsuscod,rsclclcepnum,itacliscocod,",
               " itaaplcanmtvcod,itarsrcaosrvcod,itaclisgmcod,casfrqvlr,ubbcod,porvclcod, ",
               " frtmdlnom,plndes,vndcnldes,bldflg,vcltipnom ",
               "FROM datmdetitaasiarq ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   itaasiarqlnhnum = ? ",
               "ORDER BY itaciacod, itaramcod, itaaplnum, itaasiarqlnhnum "
   prepare p_ctc91m20_004 from l_sql
   declare c_ctc91m20_004 cursor with hold for p_ctc91m20_004

   let l_sql = "SELECT MAX(aplseqnum) ",
               "FROM datmitaapl ",
               "WHERE itaciacod = ? ",
               "AND itaramcod = ? ",
               "AND itaaplnum = ? "
   prepare p_ctc91m20_005 from l_sql
   declare c_ctc91m20_005 cursor with hold for p_ctc91m20_005

   let l_sql = "SELECT segcgccpfnum,segcgcordnum,segcgccpfdig,itaprdcod,itacliscocod ",
               "      ,vndcnlcod,frtmdlcod ",
               "FROM datmitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? "
   prepare p_ctc91m20_006 from l_sql
   declare c_ctc91m20_006 cursor with hold for p_ctc91m20_006

   let l_sql = "SELECT NVL(MAX(aplseqnum),0) + 1 ",
               "FROM datmitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? "
   prepare p_ctc91m20_007 from l_sql
   declare c_ctc91m20_007 cursor with hold for p_ctc91m20_007

   let l_sql = "SELECT itaciacod, itaramcod, itaaplnum, aplseqnum, itaaplitmnum ",
               "FROM datmitaasiarqico ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   itaasiarqlnhnum = ? ",
               "AND   pcsseqnum = ? "
   prepare p_ctc91m20_008 from l_sql
   declare c_ctc91m20_008 cursor with hold for p_ctc91m20_008


   let l_sql = "SELECT itaasisrvcod,itarsrcaosrvcod,rsrcaogrtcod,ubbcod,itasgrplncod ",
               "      ,itaempasicod,itaaplcanmtvcod,itaclisgmcod,itavclcrgtipcod,vcltipcod ",
               "FROM datmitaaplitm ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? ",
               "AND   itaaplitmnum = ? "
   prepare p_ctc91m20_009 from l_sql
   declare c_ctc91m20_009 cursor with hold for p_ctc91m20_009


   let l_sql = "SELECT FIRST 1 itaaplcanmtvcod ",
               "FROM datmitaaplitm ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? "
   prepare p_ctc91m20_010 from l_sql
   declare c_ctc91m20_010 cursor with hold for p_ctc91m20_010

   let l_sql = "SELECT itaaplvigincdat, ",
               "       itaaplvigfnldat  ",
               "FROM datmitaapl         ",
               "WHERE itaciacod = ?     ",
               "AND itaramcod = ?       ",
               "AND itaaplnum = ?       ",
               "AND aplseqnum = ?       "
   prepare p_ctc91m20_011 from l_sql
   declare c_ctc91m20_011 cursor with hold for p_ctc91m20_011


   let l_sql = "SELECT COUNT(*) " ,
               "FROM datmitaasiarqico INCON ",
               "INNER JOIN datmitaarqpcshst HIST ",
               "   ON HIST.itaasiarqvrsnum = INCON.itaasiarqvrsnum ",
               "  AND HIST.pcsseqnum = INCON.pcsseqnum ",
               "INNER JOIN datmdetitaasiarq DETALHE ",
               "   ON DETALHE.itaasiarqvrsnum = INCON.itaasiarqvrsnum ",
               "  AND DETALHE.itaasiarqlnhnum = INCON.itaasiarqlnhnum ",
               "LEFT JOIN datkitaasiarqicotip TIPO ON (TIPO.itaasiarqicotipcod = INCON.itaasiarqicotipcod) ",
               "WHERE INCON.libicoflg = 'N' "
   prepare p_ctc91m20_012 from l_sql
   declare c_ctc91m20_012 cursor with hold for p_ctc91m20_012

   let l_sql = "SELECT INCON.itaasiarqvrsnum, INCON.itaasiarqlnhnum, INCON.pcsseqnum, ",
               "       INCON.itaaplnum, INCON.impicoflg, DETALHE.mvtsttcod ",
               "FROM datmitaasiarqico INCON ",
               "INNER JOIN datmitaarqpcshst HIST ",
               "   ON HIST.itaasiarqvrsnum = INCON.itaasiarqvrsnum ",
               "  AND HIST.pcsseqnum = INCON.pcsseqnum ",
               "INNER JOIN datmdetitaasiarq DETALHE ",
               "   ON DETALHE.itaasiarqvrsnum = INCON.itaasiarqvrsnum ",
               "  AND DETALHE.itaasiarqlnhnum = INCON.itaasiarqlnhnum ",
               "LEFT JOIN datkitaasiarqicotip TIPO ON (TIPO.itaasiarqicotipcod = INCON.itaasiarqicotipcod) ",
               "WHERE INCON.libicoflg = 'N' ",
               "ORDER BY 1, 3, 2 "
   prepare p_ctc91m20_013 from l_sql
   declare c_ctc91m20_013 cursor with hold for p_ctc91m20_013

   let l_sql = "UPDATE datmitaasiarqico SET libicoflg = 'C' " ,
               "WHERE itaasiarqvrsnum = ?"                    ,
               "AND   pcsseqnum = ?      "                    ,
               "AND   itaasiarqlnhnum = ?"
   prepare p_ctc91m20_014 from l_sql
   let m_prep = true

#========================================================================
end function # Fim da ctc91m20_prepare
#========================================================================

#========================================================================
function ctc91m20_consulta_inconsistencias()
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

   if a3_ctc91m20.filversao is not null then
      let l_sql1 = " AND   INCON.itaasiarqvrsnum = ", a3_ctc91m20.filversao clipped
   end if

   if a3_ctc91m20.filapol is not null then
      let l_sql2 = " AND   INCON.itaaplnum       = ", a3_ctc91m20.filapol clipped
   end if

   if a3_ctc91m20.fildtini is not null and a3_ctc91m20.fildtfim is not null then
      let l_sql3 = " AND   to_date(to_char(HIST.pcshordat,'%d/%m/%Y'), '%d/%m/%Y') ",
                   " BETWEEN to_date('", a3_ctc91m20.fildtini clipped, "','%d/%m/%Y') ",
                   " AND to_date('", a3_ctc91m20.fildtfim clipped, "','%d/%m/%Y') "
   end if

   if a3_ctc91m20.filimped is not null and a3_ctc91m20.filimped <> " " then
      let l_sql4 = " AND impicoflg = '", a3_ctc91m20.filimped, "' "
   end if


   let l_sql = "SELECT INCON.itaasiarqvrsnum, INCON.itaasiarqlnhnum, INCON.pcsseqnum, ",
               "       INCON.itaciacod, INCON.itaramcod, INCON.aplseqnum,  ",
               "       INCON.itaaplnum, INCON.itaaplitmnum, NVL(TIPO.itaasiarqicotipdes,'DESCONHECIDO'), ",
               "       INCON.impicoflg, INCON.icocponom, INCON.icocpocntdes, DETALHE.mvtsttcod ",
               "FROM datmitaasiarqico INCON ",
               "INNER JOIN datmitaarqpcshst HIST ",
               "   ON HIST.itaasiarqvrsnum = INCON.itaasiarqvrsnum ",
               "  AND HIST.pcsseqnum = INCON.pcsseqnum ",
               "INNER JOIN datmdetitaasiarq DETALHE ",
               "   ON DETALHE.itaasiarqvrsnum = INCON.itaasiarqvrsnum ",
               "  AND DETALHE.itaasiarqlnhnum = INCON.itaasiarqlnhnum ",
               "LEFT JOIN datkitaasiarqicotip TIPO ON (TIPO.itaasiarqicotipcod = INCON.itaasiarqicotipcod) ",
               "WHERE INCON.libicoflg = 'N' ",
               l_sql1 clipped, " ",
               l_sql2 clipped, " ",
               l_sql3 clipped, " ",
               l_sql4 clipped, " ",
               "ORDER BY 1, 3, 2 "
   prepare p_ctc91m20_001 from l_sql
   declare c_ctc91m20_001 cursor with hold for p_ctc91m20_001


#========================================================================
end function # Fim da ctc91m20_consulta_inconsistencias
#========================================================================

#========================================================================
function ctc91m20_input()
#========================================================================
   define l_index       smallint
   define arr_aux       smallint
   define arr_aux2      smallint
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
   define lr_retorno record
     qtd         integer
    ,nulo        smallint
    ,status      smallint
    ,confirma    char(1)
   end record

   define lr_chave_apolice record
      itaciacod     like datmitaaplitm.itaciacod
     ,itaramcod     like datmitaaplitm.itaramcod
     ,itaaplnum     like datmitaaplitm.itaaplnum
     ,aplseqnum     like datmitaaplitm.aplseqnum
     ,itaaplitmnum  like datmitaaplitm.itaaplitmnum
     ,operacao      char(1)
   end record

   define l_aplnum_ant like datmitaaplitm.itaaplnum

   let int_flag = false
   let l_reconsulta = false

   initialize lr_retorno.* to null
   let m_versao = 0

   if m_prep is null or
      m_prep = false then
      call ctc91m20_prepare()
   end if

   open window w_ctc91m20 at 4,2 with form 'ctc91m20'
      #attribute(form line first, message line first +19 ,comment line first +18, border)
      attribute(form line first, message line last,comment line last - 1, border)

   while true
      message "                                    (F17)Abandonar"

      if not l_reconsulta then
         initialize a3_ctc91m20.* to null
         input by name a3_ctc91m20.* without defaults
           #--------------------
            on key (interrupt, control-c)
           #--------------------
               let int_flag = true
               exit input

           #--------------------
            after field fildtfim
           #--------------------
               if (a3_ctc91m20.fildtfim is null and
                   a3_ctc91m20.fildtini is not null) or
                  (a3_ctc91m20.fildtfim is not null and
                   a3_ctc91m20.fildtini is null) then
                  error " As datas de inicio e fim devem ser preenchidas."
                  next field fildtini
               end if

           #--------------------
            after field filimped
           #--------------------
               if a3_ctc91m20.filimped is not null then
                  let a3_ctc91m20.filimped = upshift(a3_ctc91m20.filimped)
                  display by name a3_ctc91m20.filimped
               end if

               if a3_ctc91m20.filimped is not null and
                  a3_ctc91m20.filimped <> "S" and
                  a3_ctc91m20.filimped <> "N" then
                  error "Preencha apenas 'S' ou 'N'."
                  let a3_ctc91m20.filimped = null
                  display by name a3_ctc91m20.filimped
                  next field filimped
               end if

         end input
      else
         let l_reconsulta = false
         display by name a3_ctc91m20.*
      end if

      if int_flag then
         let int_flag = false
         exit while
      end if

      initialize a_ctc91m20 to null
      let l_index = 1

      call ctc91m20_consulta_inconsistencias()

      whenever error continue
      open c_ctc91m20_001
      whenever error stop

      foreach c_ctc91m20_001 into a_ctc91m20[l_index].versao
                                 ,a_ctc91m20[l_index].linha
                                 ,a_ctc91m20[l_index].process
                                 ,ar_param[l_index].itaciacod
                                 ,ar_param[l_index].itaramcod
                                 ,ar_param[l_index].aplseqnum
                                 ,a_ctc91m20[l_index].apolice
                                 ,a_ctc91m20[l_index].item
                                 ,a_ctc91m20[l_index].incons
                                 ,a_ctc91m20[l_index].imped
                                 ,a2_ctc91m20[l_index].campo
                                 ,a2_ctc91m20[l_index].conteudo
                                 ,a2_ctc91m20[l_index].operacao

         call ctc91m20_recupera_vigencia(ar_param[l_index].itaciacod
                                        ,ar_param[l_index].itaramcod
                                        ,a_ctc91m20[l_index].apolice
                                        ,ar_param[l_index].aplseqnum)
         returning a2_ctc91m20[l_index].itaaplvigincdat,
                   a2_ctc91m20[l_index].itaaplvigfnldat
         let l_index = l_index + 1

         let lr_retorno.qtd = l_index
         if l_index > 2000 then
            error " Limite excedido! Foram encontrados mais de 2000 registros!"
            exit foreach
         end if

      end foreach

      close c_ctc91m20_001

      let arr_aux = l_index
      if arr_aux = 1  then
         error "Nenhum registro encontrado..."
         continue while
      end if

      message "(F5)Espelho,(F7)Remover,(F8)Tratar,(F9)Reprocessar,(F10)Rep.Todas,(F17)Voltar"

      call set_count(arr_aux - 1)
      input array a_ctc91m20 without defaults from s_ctc91m20.*

        #--------------------
         before field marca
        #--------------------
            display a_ctc91m20[arr_aux].* to s_ctc91m20[scr_aux].* attribute(reverse)



            display by name  a2_ctc91m20[arr_aux].campo
                            ,a2_ctc91m20[arr_aux].conteudo
                            ,a2_ctc91m20[arr_aux].operacao
                            ,a2_ctc91m20[arr_aux].itaaplvigincdat
                            ,a2_ctc91m20[arr_aux].itaaplvigfnldat
                            ,lr_retorno.qtd


        #--------------------
         after field marca
        #--------------------
            #let a_ctc91m20[arr_aux].versao = m_versao

            if a_ctc91m20[arr_aux].marca <> "X" or
               a_ctc91m20[arr_aux].apolice is null then
               let a_ctc91m20[arr_aux].marca = " "
            end if

            if fgl_lastkey() = fgl_keyval("down") or
               fgl_lastkey() = fgl_keyval("right") or
               fgl_lastkey() = fgl_keyval("enter") then
               if a_ctc91m20[arr_aux + 1].versao is null then
                  next field marca
               end if
            end if

            if fgl_lastkey() = fgl_keyval("up") or
               fgl_lastkey() = fgl_keyval("left") then
               if arr_aux -1 <= 0 then
                  next field marca
               end if
            end if

            display a_ctc91m20[arr_aux].* to s_ctc91m20[scr_aux].*

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
         on key (F5)
        #--------------------
            let arr_aux2  = arr_curr()
            if a_ctc91m20[arr_aux2].imped = 'N' then
                 call cta00m16_chama_prog("ctg18", ar_param[arr_aux2].itaramcod  ,
                                                   lr_retorno.nulo               ,
                                                   a_ctc91m20[arr_aux2].apolice  ,
                                                   a_ctc91m20[arr_aux2].item     ,
                                                   ar_param[arr_aux2].aplseqnum  ,
                                                   lr_retorno.nulo,
                                                   lr_retorno.nulo,
                                                   lr_retorno.nulo,
                                                   lr_retorno.nulo,
                                                   84,
                                                   lr_retorno.nulo,
                                                   lr_retorno.nulo,
                                                   lr_retorno.nulo,
                                                   lr_retorno.nulo,
                                                   lr_retorno.nulo,
                                                   lr_retorno.nulo,
                                                   ar_param[arr_aux2].itaciacod)
                              returning lr_retorno.status
                 if lr_retorno.status  = -1 then
                      error "Espelho da apolice nao disponivel no momento"
                      sleep 2
                 end if
            else
            	 error "Espelho Disponivel Somente para Apolices Nao Impeditivas"
            end if
        #--------------------
         on key (F7)
        #--------------------
            if a2_ctc91m20[arr_aux].itaaplvigfnldat < today or
	       a2_ctc91m20[arr_aux].itaaplvigincdat is null or           	 
               a2_ctc91m20[arr_aux].itaaplvigfnldat is null then
                
                call cts08g01("C", "S","","DESEJA REMOVER", "O REGISTRO?","")
                returning lr_retorno.confirma
                
                if lr_retorno.confirma = "S" then
                   
                   call ctc91m20_remove(a_ctc91m20[arr_aux].versao  ,
                                        a_ctc91m20[arr_aux].process ,
                                        a_ctc91m20[arr_aux].linha   )
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
            if a_ctc91m20[arr_aux].imped = 'S' then
               # Inconsistencias impeditivas devem ser tratadas na tabela de movimento
               # e tentar carregar novamente.
               if a2_ctc91m20[arr_aux].operacao = 'I' then
                  call ctc91m21_input(a_ctc91m20[arr_aux].versao, a_ctc91m20[arr_aux].linha)
               end if
               if a2_ctc91m20[arr_aux].operacao = 'C' then
                  call ctc91m22_input(a_ctc91m20[arr_aux].versao, a_ctc91m20[arr_aux].linha)
               end if

            else
               # Inconsistencias nao impeditivas ja foram carregadas e devem ser
               # corrigidas diretamente na apolice
               initialize lr_chave_apolice.* to null

               whenever error continue
               open c_ctc91m20_008 using a_ctc91m20[arr_aux].versao
                                        ,a_ctc91m20[arr_aux].linha
                                        ,a_ctc91m20[arr_aux].process
               fetch c_ctc91m20_008 into lr_chave_apolice.itaciacod
                                         ,lr_chave_apolice.itaramcod
                                         ,lr_chave_apolice.itaaplnum
                                         ,lr_chave_apolice.aplseqnum
                                         ,lr_chave_apolice.itaaplitmnum
               whenever error stop
               close c_ctc91m20_008

               let lr_chave_apolice.operacao = a2_ctc91m20[arr_aux].operacao

               call ctc91m23_input(lr_chave_apolice.*)

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

               if  a_ctc91m20[l_loop].marca = "X" and
                   a_ctc91m20[l_loop].apolice is not null then

                  if l_aplnum_ant <> a_ctc91m20[l_loop].apolice then
                     whenever error continue
                     open c_ctc91m20_003 using a_ctc91m20[l_loop].apolice
                     fetch c_ctc91m20_003 into l_count
                     #display "COUNT: ", l_count
                     whenever error stop
                     close c_ctc91m20_003

                     let l_count_apl = l_count_apl + 1
                     let l_count_ico = l_count_ico + l_count
                     let l_count = 0
                  end if

                  let l_aplnum_ant = a_ctc91m20[l_loop].apolice

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
                     if a_ctc91m20[l_loop].marca = 'X' and
                        a_ctc91m20[l_loop].imped = 'S' then
                        call ctc91m20_processa_recarga_impeditiva(a_ctc91m20[l_loop].apolice)
                     end if
                     let l_loop = l_loop + 1
                  end while

                  # Na sequencia processa todas as inconsistencias nao impeditivas selecionadas
                  let l_loop = 1
                  while l_loop <= 2000
                     if a_ctc91m20[l_loop].marca = 'X' and
                        a_ctc91m20[l_loop].imped = 'N' then
                        call ctc91m20_processa_recarga_nao_impeditiva(a_ctc91m20[l_loop].versao
                                                                     ,a_ctc91m20[l_loop].process
                                                                     ,a_ctc91m20[l_loop].linha
                                                                     ,a2_ctc91m20[l_loop].operacao)

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

             call ctc91m20_reprocessa_todos()

      end input

   end while

   let int_flag = false

   close window w_ctc91m20

#========================================================================
end function # Fim da funcao ctc91m20_input()
#========================================================================

#=================================================================
function ctc91m20_processa_recarga_impeditiva(lr_param)
#=================================================================

   define lr_param record
      apolice     like datmitaasiarqico.itaaplnum
   end record

   define lr_dados record
       asiarqvrsnum     like datmdetitaasiarq.itaasiarqvrsnum
      ,asiarqlnhnum     like datmdetitaasiarq.itaasiarqlnhnum
      ,ciacod           like datmdetitaasiarq.itaciacod
      ,ramcod           like datmdetitaasiarq.itaramcod
      ,aplnum           like datmdetitaasiarq.itaaplnum
      ,aplitmnum        like datmdetitaasiarq.itaaplitmnum
      ,aplvigincdat     like datmdetitaasiarq.itaaplvigincdat
      ,aplvigfnldat     like datmdetitaasiarq.itaaplvigfnldat
      ,prpnum           like datmdetitaasiarq.itaprpnum
      ,prdcod           like datmdetitaasiarq.itaprdcod
      ,sgrplncod        like datmdetitaasiarq.itasgrplncod
      ,empasicod        like datmdetitaasiarq.itaempasicod
      ,asisrvcod        like datmdetitaasiarq.itaasisrvcod
      ,rsrcaogrtcod     like datmdetitaasiarq.rsrcaogrtcod
      ,segnom           like datmdetitaasiarq.segnom
      ,pestipcod        like datmdetitaasiarq.pestipcod
      ,segcgccpfnum     like datmdetitaasiarq.segcgccpfnum
      ,seglgdnom        like datmdetitaasiarq.seglgdnom
      ,seglgdnum        like datmdetitaasiarq.seglgdnum
      ,segendcmpdes     like datmdetitaasiarq.segendcmpdes
      ,segbrrnom        like datmdetitaasiarq.segbrrnom
      ,segcidnom        like datmdetitaasiarq.segcidnom
      ,segufdsgl        like datmdetitaasiarq.segufdsgl
      ,segcepnum        like datmdetitaasiarq.segcepnum
      ,segresteldddnum  like datmdetitaasiarq.segresteldddnum
      ,segrestelnum     like datmdetitaasiarq.segrestelnum
      ,autchsnum        like datmdetitaasiarq.autchsnum
      ,autplcnum        like datmdetitaasiarq.autplcnum
      ,autfbrnom        like datmdetitaasiarq.autfbrnom
      ,autlnhnom        like datmdetitaasiarq.autlnhnom
      ,autmodnom        like datmdetitaasiarq.autmodnom
      ,autfbrano        like datmdetitaasiarq.autfbrano
      ,autmodano        like datmdetitaasiarq.autmodano
      ,autcmbnom        like datmdetitaasiarq.autcmbnom
      ,autcornom        like datmdetitaasiarq.autcornom
      ,autpintipdes     like datmdetitaasiarq.autpintipdes
      ,vclcrgtipcod     like datmdetitaasiarq.itavclcrgtipcod
      ,mvtsttcod        like datmdetitaasiarq.mvtsttcod
      ,adniclhordat     like datmdetitaasiarq.adniclhordat
      ,pcshordat        like datmdetitaasiarq.itapcshordat
      ,asiincdat        like datmdetitaasiarq.asiincdat
      ,okmflg           like datmdetitaasiarq.okmflg
      ,impautflg        like datmdetitaasiarq.impautflg
      ,corsuscod        like datmdetitaasiarq.itacorsuscod
      ,rsclclcepnum     like datmdetitaasiarq.rsclclcepnum
      ,cliscocod        like datmdetitaasiarq.itacliscocod
      ,aplcanmtvcod     like datmdetitaasiarq.itaaplcanmtvcod
      ,rsrcaosrvcod     like datmdetitaasiarq.itarsrcaosrvcod
      ,clisgmcod        like datmdetitaasiarq.itaclisgmcod
      ,casfrqvlr        like datmdetitaasiarq.casfrqvlr
      ,ubbcod           like datmdetitaasiarq.ubbcod
      ,porvclcod        like datmdetitaasiarq.porvclcod
      ,frtmdlnom        like datmdetitaasiarq.frtmdlnom
      ,plndes           like datmdetitaasiarq.plndes
      ,vndcnldes        like datmdetitaasiarq.vndcnldes
      ,bldflg           like datmdetitaasiarq.bldflg
      ,vcltipnom        like datmdetitaasiarq.vcltipnom
      ,auxprdcod        like datmitaapl.itaprdcod    # DAQUI PRA BAIXO SAO AUXILIARES #
      ,auxsgrplncod     like datmitaaplitm.itasgrplncod
      ,auxempasicod     like datmitaaplitm.itaempasicod
      ,auxasisrvcod     like datmitaaplitm.itaasisrvcod
      ,auxcliscocod     like datmitaapl.itacliscocod
      ,auxrsrcaosrvcod  like datmitaaplitm.itarsrcaosrvcod
      ,auxclisgmcod     like datmitaaplitm.itaclisgmcod
      ,auxaplcanmtvcod  like datmitaaplitm.itaaplcanmtvcod
      ,auxrsrcaogrtcod  like datmitaaplitm.rsrcaogrtcod
      ,auxubbcod        like datmitaaplitm.ubbcod
      ,auxvclcrgtipcod  like datmitaaplitm.itavclcrgtipcod
      ,auxfrtmdlcod     like datmitaapl.frtmdlcod
      ,auxvndcnlcod     like datmitaapl.vndcnlcod
      ,auxvcltipcod     like datmitaaplitm.vcltipcod
   end record

   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_apolice_ant record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_hist_process record
       asiarqvrsnum     like datmitaarqpcshst.itaasiarqvrsnum
      ,pcsseqnum        like datmitaarqpcshst.pcsseqnum
      ,lnhtotqtd        like datmitaarqpcshst.lnhtotqtd
      ,pcslnhqtd        like datmitaarqpcshst.pcslnhqtd
   end record

   define lr_inconsistencia record
       asiarqvrsnum     like datmitaasiarqico.itaasiarqvrsnum
      ,pcsseqnum        like datmitaasiarqico.pcsseqnum
      ,asiarqlnhnum     like datmitaasiarqico.itaasiarqlnhnum
      ,icoseqnum        like datmitaasiarqico.icoseqnum
   end record

   define lr_inconsistencia_ant record
       asiarqvrsnum     like datmitaasiarqico.itaasiarqvrsnum
      ,pcsseqnum        like datmitaasiarqico.pcsseqnum
      ,asiarqlnhnum     like datmitaasiarqico.itaasiarqlnhnum
      ,icoseqnum        like datmitaasiarqico.icoseqnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   #define l_contador integer
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
      call ctc91m20_prepare()
   end if

   #prompt "Iniciando Recarga. <ENTER>" for m_mens

   begin work

   let l_flg_primeiro = true

   # Busca os dados (na ordem correta de reprocessamento) de inconsistencia da apolice selecionada
   whenever error continue
   open c_ctc91m20_002 using lr_param.apolice
   foreach c_ctc91m20_002 into lr_inconsistencia.*


      if l_flg_primeiro then
         call cty22g02_libera_inconsistencia(lr_param.apolice)
         returning lr_erro.*

         if lr_erro.sqlcode <> 0 then
            rollback work
            call ctc91m20_exibe_erro(lr_erro.*)
            return
         end if

         #prompt "Inconsistencias Liberadas. <ENTER>" for m_mens
         let l_flg_primeiro = false
      end if


      #prompt "Loop principal 1 <ENTER>" for m_mens

      if lr_inconsistencia.asiarqvrsnum = lr_inconsistencia_ant.asiarqvrsnum and
         lr_inconsistencia.asiarqlnhnum = lr_inconsistencia_ant.asiarqlnhnum then
         # Se a versao e a linha forem as mesmas da anterior, significa que ja foi carregado
         # Neste caso entao ignora e passa para o próximo registro.
         # Isso acontece quando uma unica linha do arquivo possui mais de uma inconsistencia

         #prompt "Inconsistencia ja liberada. Pular. <ENTER>" for m_mens

         continue foreach
      end if

      #prompt "Loop principal 2 <ENTER>" for m_mens

      if not (lr_inconsistencia.asiarqvrsnum = lr_inconsistencia_ant.asiarqvrsnum) then
         # Se a versao do arquivo for diferente da anterior, gerar novo processamento


         if lr_hist_process.pcsseqnum > 0 and
            lr_hist_process.asiarqvrsnum > 0 then
            # Para gerar novo processamento, fechar o anterior se existir.
            call cty22g02_encerra_processamento(lr_hist_process.*)
            returning lr_erro.*

            if lr_erro.sqlcode <> 0 then
               rollback work
               call ctc91m20_exibe_erro(lr_erro.*)
               #exit foreach
               return
            end if
         end if

         initialize lr_hist_process.* to null
         let lr_hist_process.asiarqvrsnum = lr_inconsistencia.asiarqvrsnum
         let lr_hist_process.lnhtotqtd = 0 # Por enquanto nao ha rotina para calcular a qtde de registros a serem processados
         let lr_hist_process.pcslnhqtd = 0

         call cty22g02_gera_processamento(lr_hist_process.*)
         returning lr_erro.*,lr_hist_process.pcsseqnum

         if lr_erro.sqlcode <> 0 then
            rollback work
            call ctc91m20_exibe_erro(lr_erro.*)
            #exit foreach
            return
         end if

         #prompt "Novo Processamento. <ENTER>" for m_mens
      end if


      #prompt "Loop principal 3 <ENTER>" for m_mens

      # Seleciona os dados do movimento (versao/linha)
      whenever error continue
      open c_ctc91m20_004 using lr_inconsistencia.asiarqvrsnum, lr_inconsistencia.asiarqlnhnum
      fetch c_ctc91m20_004 into lr_dados.asiarqvrsnum
                                 ,lr_dados.asiarqlnhnum
                                 ,lr_dados.ciacod
                                 ,lr_dados.ramcod
                                 ,lr_dados.aplnum
                                 ,lr_dados.aplitmnum
                                 ,lr_dados.aplvigincdat
                                 ,lr_dados.aplvigfnldat
                                 ,lr_dados.prpnum
                                 ,lr_dados.prdcod
                                 ,lr_dados.sgrplncod
                                 ,lr_dados.empasicod
                                 ,lr_dados.asisrvcod
                                 ,lr_dados.rsrcaogrtcod
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
                                 ,lr_dados.autchsnum
                                 ,lr_dados.autplcnum
                                 ,lr_dados.autfbrnom
                                 ,lr_dados.autlnhnom
                                 ,lr_dados.autmodnom
                                 ,lr_dados.autfbrano
                                 ,lr_dados.autmodano
                                 ,lr_dados.autcmbnom
                                 ,lr_dados.autcornom
                                 ,lr_dados.autpintipdes
                                 ,lr_dados.vclcrgtipcod
                                 ,lr_dados.mvtsttcod
                                 ,lr_dados.adniclhordat
                                 ,lr_dados.pcshordat
                                 ,lr_dados.asiincdat
                                 ,lr_dados.okmflg
                                 ,lr_dados.impautflg
                                 ,lr_dados.corsuscod
                                 ,lr_dados.rsclclcepnum
                                 ,lr_dados.cliscocod
                                 ,lr_dados.aplcanmtvcod
                                 ,lr_dados.rsrcaosrvcod
                                 ,lr_dados.clisgmcod
                                 ,lr_dados.casfrqvlr
                                 ,lr_dados.ubbcod
                                 ,lr_dados.porvclcod
                                 ,lr_dados.frtmdlnom  # NOVO LAYOUT DAQUI PRA BAIXO
                                 ,lr_dados.plndes
                                 ,lr_dados.vndcnldes
                                 ,lr_dados.bldflg
                                 ,lr_dados.vcltipnom
      whenever error stop
      close c_ctc91m20_004


      initialize lr_apolice_atual.* to null

      let lr_apolice_atual.ciacod       = lr_dados.ciacod
      let lr_apolice_atual.ramcod       = lr_dados.ramcod
      let lr_apolice_atual.aplnum       = lr_dados.aplnum
      let lr_apolice_atual.aplseqnum    = null # Sera recuperado a seguir
      let lr_apolice_atual.aplitmnum    = lr_dados.aplitmnum
      let lr_apolice_atual.aplitmsttcod = lr_dados.mvtsttcod
      let lr_apolice_atual.qtdinconsist = 0 # Sera recuperado a seguir

      #prompt "Dados selecionados. <ENTER>" for m_mens

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

      #prompt "Antes de verificar inconsistencia. <ENTER>" for m_mens

      let l_cont_impedit = 0
      let l_cont_nimpedit = 0
      call cty22g02_verifica_inconsistencias(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
      returning lr_erro.*, l_cont_impedit, l_cont_nimpedit, lr_dados.*


      if lr_erro.sqlcode <> 0 then
         rollback work
         call ctc91m20_exibe_erro(lr_erro.*)
         #exit foreach
         return
      end if

      #prompt "Rotina de inconsistencias rodada. <ENTER>" for m_mens

      let l_qtd_inconsist = l_qtd_inconsist + l_cont_impedit


      if lr_apolice_atual.aplitmsttcod <> "I" then
         let l_flg_continua = false
      end if

      if l_flg_continua then
         call cty22g02_busca_sequencia_continua(lr_apolice_atual.*)
         returning lr_erro.*, lr_apolice_atual.aplseqnum

         if lr_erro.sqlcode <> 0 then
            rollback work
            call ctc91m20_exibe_erro(lr_erro.*)
            #exit foreach
            return
         end if

         if lr_apolice_atual.aplseqnum = 0 then
            let lr_apolice_atual.aplseqnum = null
            let l_flg_continua = false
         end if

         #prompt "Busca sequencia de continuacao de carregamento. <ENTER>" for m_mens
      end if

      #
      #if lr_apolice_atual.aplnum = 10058668 then
         #display "-------------------------------------"
         #display "COMPANHIA: ", lr_apolice_atual.ciacod clipped
         #display "RAMO: ", lr_apolice_atual.ramcod clipped
         #display "APOLICE: ", lr_apolice_atual.aplnum clipped
         #display "ITEM: ", lr_apolice_atual.aplitmnum clipped
         #display "SEQUENCIA: ", lr_apolice_atual.aplseqnum clipped
         #display "OPERACAO: ", lr_apolice_atual.aplitmsttcod clipped
         #display "INCONSISTENCIAS: ", lr_apolice_atual.qtdinconsist clipped
         #display "INCONSISTENCIA ATUAL: ", l_qtd clipped
         #display "CONTINUA: ", l_flg_continua
         #
         #prompt "<ENTER>" for m_mens
      #end if
      #

      if l_cont_impedit = 0 then
         #Realizar o cancelamento, gravacao da apolice e item apenas se nao houver inconsistencia

         case lr_apolice_atual.aplitmsttcod # Verifica se eh inclusao ou cancelamento

         when 'C' # Processa cancelamento

            call cty22g02_carrega_cancelamento(lr_apolice_atual.*, lr_hist_process.*, lr_dados.aplcanmtvcod)
            returning lr_erro.*, lr_apolice_atual.aplseqnum

            if lr_erro.sqlcode <> 0 then
               rollback work
               call ctc91m20_exibe_erro(lr_erro.*)
               #exit foreach
               return
            end if

            #prompt "Cancelamento processado. <ENTER>" for m_mens

         when 'I' # Processa inclusao

            if lr_apolice_atual.aplseqnum is null then
               # Se ja existir sequencia gravada pula a gravacao da apolice e passa para a gravacao do item
               # Se não existir ainda busca uma nova sequencia

               call cty22g02_gera_sequencia_apolice(lr_apolice_atual.*)
               returning lr_erro.*, lr_apolice_atual.aplseqnum

               if lr_erro.sqlcode <> 0 then
                  rollback work
                  call ctc91m20_exibe_erro(lr_erro.*)
                  #exit foreach
                  return
               end if

               # Carrega a apolice
               call cty22g02_carrega_tabela_apolice(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
               returning lr_erro.*

               if lr_erro.sqlcode <> 0 then
                  rollback work
                  call ctc91m20_exibe_erro(lr_erro.*)
                  #exit foreach
                  return
               end if

               #prompt "Apolice carregada. <ENTER>" for m_mens

            end if


            # Carrega o item da apolice
            call cty22g02_carrega_tabela_item(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
            returning lr_erro.*

            if lr_erro.sqlcode <> 0 then
               rollback work
               call ctc91m20_exibe_erro(lr_erro.*)
               #exit foreach
               return
            end if

            #prompt "Item da Apolice carregada. <ENTER>" for m_mens

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

      #prompt "Anteriores carregados. <ENTER>" for m_mens

      let lr_erro.sqlcode = 0
      initialize lr_dados.* to null

   end foreach
   close c_ctc91m20_002



   if lr_erro.sqlcode = 0 then
      # Encerra o processamento atual
      call cty22g02_encerra_processamento(lr_hist_process.*)
      returning lr_erro.*

      if lr_erro.sqlcode <> 0 then
         rollback work
         call ctc91m20_exibe_erro(lr_erro.*)
         return
      end if
   end if

   if lr_erro.sqlcode = 0 then
      #prompt "Commit. <ENTER>" for m_mens
      commit work
      return
   end if

   rollback work


   #sleep 2

#=======================================================
end function  # Fim funcao ctc91m20_processa_recarga_impeditiva
#=======================================================


#=================================================================
function ctc91m20_processa_recarga_nao_impeditiva(lr_param)
#=================================================================

   define lr_param record
      itaasiarqvrsnum   like datmitaasiarqico.itaasiarqvrsnum
     ,pcsseqnum         like datmitaasiarqico.pcsseqnum
     ,itaasiarqlnhnum   like datmitaasiarqico.itaasiarqlnhnum
     ,operacao          char(1)
   end record

   define lr_apolice record
       itaaplnum       like datmitaapl.itaaplnum
      ,itaaplitmnum    like datmitaaplitm.itaaplitmnum
      ,aplseqnum       like datmitaapl.aplseqnum
      ,itaciacod       like datmitaapl.itaciacod
      ,itaramcod       like datmitaapl.itaramcod
      ,segcgccpfnum    like datmitaapl.segcgccpfnum
      ,segcgcordnum    like datmitaapl.segcgcordnum
      ,segcgccpfdig    like datmitaapl.segcgccpfdig
      ,itaprdcod       like datmitaapl.itaprdcod
      ,itacliscocod    like datmitaapl.itacliscocod
      ,vndcnlcod       like datmitaapl.vndcnlcod
      ,frtmdlcod       like datmitaapl.frtmdlcod
      ,itaasisrvcod    like datmitaaplitm.itaasisrvcod
      ,itarsrcaosrvcod like datmitaaplitm.itarsrcaosrvcod
      ,rsrcaogrtcod    like datmitaaplitm.rsrcaogrtcod
      ,ubbcod          like datmitaaplitm.ubbcod
      ,itasgrplncod    like datmitaaplitm.itasgrplncod
      ,itaempasicod    like datmitaaplitm.itaempasicod
      ,itaaplcanmtvcod like datmitaaplitm.itaaplcanmtvcod
      ,itaclisgmcod    like datmitaaplitm.itaclisgmcod
      ,itavclcrgtipcod like datmitaaplitm.itavclcrgtipcod
      ,vcltipcod       like datmitaaplitm.vcltipcod
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
   open c_ctc91m20_008 using lr_param.itaasiarqvrsnum
                            ,lr_param.itaasiarqlnhnum
                            ,lr_param.pcsseqnum
   fetch c_ctc91m20_008 into lr_apolice.itaciacod
                            ,lr_apolice.itaramcod
                            ,lr_apolice.itaaplnum
                            ,lr_apolice.aplseqnum
                            ,lr_apolice.itaaplitmnum
   whenever error stop
   close c_ctc91m20_008

   let lr_apolice.operacao = lr_param.operacao

   # Verifica se a apolice foi encontrada
   if lr_apolice.itaciacod is null or
      lr_apolice.itaramcod is null or
      lr_apolice.itaaplnum is null or
      lr_apolice.aplseqnum is null then

      let lr_erro.mens = "Apolice selecionada nao encontrada."
      call ctc91m20_exibe_erro(lr_erro.*)
      return
   end if

   # Busca os dados da apolice que serao verificados
   whenever error continue
   open c_ctc91m20_006 using lr_apolice.itaciacod
                            ,lr_apolice.itaramcod
                            ,lr_apolice.itaaplnum
                            ,lr_apolice.aplseqnum
   fetch c_ctc91m20_006 into lr_apolice.segcgccpfnum
                            ,lr_apolice.segcgcordnum
                            ,lr_apolice.segcgccpfdig
                            ,lr_apolice.itaprdcod
                            ,lr_apolice.itacliscocod
                            ,lr_apolice.vndcnlcod
                            ,lr_apolice.frtmdlcod
   whenever error stop
   close c_ctc91m20_006


   # Busca os dados do item da apolice que serao verificados, se existir
   if lr_apolice.itaaplitmnum is not null then

      whenever error continue
      open c_ctc91m20_009 using lr_apolice.itaciacod
                               ,lr_apolice.itaramcod
                               ,lr_apolice.itaaplnum
                               ,lr_apolice.aplseqnum
                               ,lr_apolice.itaaplitmnum
      fetch c_ctc91m20_009 into lr_apolice.itaasisrvcod
                               ,lr_apolice.itarsrcaosrvcod
                               ,lr_apolice.rsrcaogrtcod
                               ,lr_apolice.ubbcod
                               ,lr_apolice.itasgrplncod
                               ,lr_apolice.itaempasicod
                               ,lr_apolice.itaaplcanmtvcod
                               ,lr_apolice.itaclisgmcod
                               ,lr_apolice.itavclcrgtipcod
                               ,lr_apolice.vcltipcod
      whenever error stop
      close c_ctc91m20_009

   else

      whenever error continue
      open c_ctc91m20_010 using lr_apolice.itaciacod
                               ,lr_apolice.itaramcod
                               ,lr_apolice.itaaplnum
                               ,lr_apolice.aplseqnum
      fetch c_ctc91m20_010 into lr_apolice.itaaplcanmtvcod
      whenever error stop
      close c_ctc91m20_010

   end if

   #display "itaaplnum       : ", lr_apolice.itaaplnum
   #display "itaaplitmnum    : ", lr_apolice.itaaplitmnum
   #display "aplseqnum       : ", lr_apolice.aplseqnum
   #display "itaciacod       : ", lr_apolice.itaciacod
   #display "itaramcod       : ", lr_apolice.itaramcod
   #display "segcgccpfnum    : ", lr_apolice.segcgccpfnum
   #display "segcgcordnum    : ", lr_apolice.segcgcordnum
   #display "segcgccpfdig    : ", lr_apolice.segcgccpfdig
   #display "itaprdcod       : ", lr_apolice.itaprdcod
   #display "itacliscocod    : ", lr_apolice.itacliscocod
   #display "vndcnlcod       : ", lr_apolice.vndcnlcod
   #display "frtmdlcod       : ", lr_apolice.frtmdlcod
   #display "itaasisrvcod    : ", lr_apolice.itaasisrvcod
   #display "itarsrcaosrvcod : ", lr_apolice.itarsrcaosrvcod
   #display "rsrcaogrtcod    : ", lr_apolice.rsrcaogrtcod
   #display "ubbcod          : ", lr_apolice.ubbcod
   #display "itasgrplncod    : ", lr_apolice.itasgrplncod
   #display "itaempasicod    : ", lr_apolice.itaempasicod
   #display "itaaplcanmtvcod : ", lr_apolice.itaaplcanmtvcod
   #display "itaclisgmcod    : ", lr_apolice.itaclisgmcod
   #display "itavclcrgtipcod : ", lr_apolice.itavclcrgtipcod
   #display "vcltipcod       : ", lr_apolice.vcltipcod
   #display "operacao        : ", lr_apolice.operacao


   # Verifica os dados da apolice
   call cty22g02_verifica_inconsistencias2(lr_apolice.*)
   returning l_cont_nimpedit

   # Se estiver ok libera a inconsistencia
   if l_cont_nimpedit = 0 then

      call cty22g02_libera_inconsistencia2(lr_param.itaasiarqvrsnum
                                          ,lr_param.pcsseqnum
                                          ,lr_param.itaasiarqlnhnum)
      returning lr_erro.*

      if lr_erro.sqlcode <> 0 then
         call ctc91m20_exibe_erro(lr_erro.*)
         return
      end if

   end if

#=======================================================
end function  # Fim funcao ctc91m20_processa_recarga_nao_impeditiva
#=======================================================



#=======================================================
function ctc91m20_exibe_erro(lr_erro)
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
end function  # Fim funcao ctc91m20_exibe_erro
#=======================================================
#---------------------------------------------------------
 function ctc91m20_recupera_vigencia(lr_param)
#---------------------------------------------------------
define lr_param record
  itaciacod like datmitaasiarqico.itaciacod
 ,itaramcod like datmitaasiarqico.itaramcod
 ,itaaplnum like datmitaasiarqico.itaaplnum
 ,aplseqnum like datmitaasiarqico.aplseqnum
end record
define lr_retorno record
	  itaaplvigincdat  like datmitaapl.itaaplvigincdat
	 ,itaaplvigfnldat  like datmitaapl.itaaplvigfnldat
end record
   initialize lr_retorno.* to null
   open c_ctc91m20_011 using lr_param.itaciacod,
                             lr_param.itaramcod,
                             lr_param.itaaplnum,
                             lr_param.aplseqnum
   whenever error continue
   fetch c_ctc91m20_011 into  lr_retorno.itaaplvigincdat,
                              lr_retorno.itaaplvigfnldat
   whenever error stop
   return lr_retorno.itaaplvigincdat,
          lr_retorno.itaaplvigfnldat
end function


#=================================================================
function ctc91m20_reprocessa_todos()
#=================================================================

define lr_retorno record
    qtd               integer                                  ,
    linha1            char(40)                                 ,
    linha2            char(40)                                 ,
    linha3            char(40)                                 ,
    linha4            char(40)                                 ,
    confirma          char(1)                                  ,
    itaaplnum         like datmitaasiarqico.itaaplnum          ,
    impicoflg         like datmitaasiarqico.impicoflg          ,
    itaasiarqvrsnum   like datmitaasiarqico.itaasiarqvrsnum    ,
    pcsseqnum         like datmitaasiarqico.pcsseqnum          ,
    itaasiarqlnhnum   like datmitaasiarqico.itaasiarqlnhnum    ,
    mvtsttcod         like datmdetitaasiarq.mvtsttcod          ,
    processado        integer
end record

   let lr_retorno.processado = 0

   # Recupera a Quantidade Total de Inconsistencias
   whenever error continue
   open c_ctc91m20_012
   fetch c_ctc91m20_012 into lr_retorno.qtd
   whenever error stop
   close c_ctc91m20_012

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
   open c_ctc91m20_013
   foreach c_ctc91m20_013 into lr_retorno.itaasiarqvrsnum    ,
   	                           lr_retorno.itaasiarqlnhnum    ,
   	                           lr_retorno.pcsseqnum          ,
   	                           lr_retorno.itaaplnum          ,
                               lr_retorno.impicoflg          ,
                               lr_retorno.mvtsttcod

      if lr_retorno.impicoflg = "S" then
         call ctc91m20_processa_recarga_impeditiva(lr_retorno.itaaplnum)
      end if

      if lr_retorno.impicoflg = "N" then
         call ctc91m20_processa_recarga_nao_impeditiva(lr_retorno.itaasiarqvrsnum
                                                      ,lr_retorno.pcsseqnum
                                                      ,lr_retorno.itaasiarqlnhnum
                                                      ,lr_retorno.mvtsttcod)

      end if

      let lr_retorno.processado = lr_retorno.processado + 1

      error "ATENCAO - REGISTROS PROCESSADOS: ", lr_retorno.processado using "<<<<<<<<&",
            " DE: ", lr_retorno.qtd  using "<<<<<<<<&"

   end foreach



#=======================================================
end function  # Fim funcao ctc91m20_reprocessa_todos
#=======================================================
#=================================================================
function ctc91m20_remove(lr_param)
#=================================================================
define lr_param record
  itaasiarqvrsnum   like  datmitaasiarqico.itaasiarqvrsnum ,
  pcsseqnum         like  datmitaasiarqico.pcsseqnum       ,
  itaasiarqlnhnum   like  datmitaasiarqico.itaasiarqlnhnum
end record
    whenever error continue
    execute p_ctc91m20_014 using lr_param.itaasiarqvrsnum
                                ,lr_param.pcsseqnum
                                ,lr_param.itaasiarqlnhnum
    whenever error stop
    if sqlca.sqlcode <> 0 then
       display "Erro (", sqlca.sqlcode clipped, ") na Remocao do Registro."
    end if
#=======================================================
end function  # Fim funcao ctc91m20_remove
#=======================================================