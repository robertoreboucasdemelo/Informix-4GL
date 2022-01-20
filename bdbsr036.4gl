############################################################################
# Nome do Modulo: bdbsr036                                        Marcelo  #
#                                                                 Gilberto #
#                                                                 Wagner   #
# Relacao de inconsistencias do cadastro de veiculos (P.Socorro)  Set/1998 #
# --------------------------------------------------------------------------#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# --------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################


 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define a_bdbsr036    array[20]  of record
    vclicsdes         char (30),
    vclicsqtd         dec  (5,0)
 end record

 define wsgtraco      char (132)
 define ws_cctcod     like igbrrelcct.cctcod
 define ws_relviaqtd  like igbrrelcct.relviaqtd
 
 main
    call fun_dba_abre_banco("CT24HS") 
    call bdbsr036()
 end main

#---------------------------------------------------------------
 function bdbsr036()
#---------------------------------------------------------------

 define d_bdbsr036    record
    pstcoddig         like datkveiculo.pstcoddig,
    socvclcod         like datkveiculo.socvclcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    vclcoddig         like datkveiculo.vclcoddig,
    vcllicnum         like datkveiculo.vcllicnum,
    vclicscod         dec  (2,0)
 end record

 define ws            record
    socoprsitcod      like datkveiculo.socoprsitcod,
    socvstdiaqtd      like datkveiculo.socvstdiaqtd,
    vclsgrseq         like datkvclsgr.vclsgrseq,
    sgdirbcod         like datkvclsgr.sgdirbcod,
    succod            like datkvclsgr.succod,
    aplnumdig         like datkvclsgr.aplnumdig,
    itmnumdig         like datkvclsgr.itmnumdig,
    sgraplnum         like datkvclsgr.sgraplnum,
    vigfnl            like datkvclsgr.vigfnl,
    sgrimsdmvlr       like datkvclsgr.sgrimsdmvlr,
    sgrimsdpvlr       like datkvclsgr.sgrimsdpvlr,
    vigfnlapl         like datkvclsgr.vigfnl,
    aplstt            like abamapol.aplstt,
    itmsttatu         like abbmitem.itmsttatu,
    dmimsvlrapl       like abbmdm.imsvlr,
    dpimsvlrapl       like abbmdp.imsvlr,
    vclcoddigapl      like abbmveic.vclcoddig,
    vcllicnumapl      like abbmveic.vcllicnum,
    count             smallint,
    auxdat            char (10),
    data_de           date,
    data_ate          date,
    comando           char (350),
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60)
 end record

 define arr_aux       integer
 define ws_vclicscod  integer


#---------------------------------------------------------------
# Limpa todas as variaveis
#---------------------------------------------------------------
 initialize d_bdbsr036.*  to null
 initialize a_bdbsr036    to null
 initialize ws.*          to null

 let wsgtraco  = "-----------------------------------------------------------------------------------------------------------------------------------"

#---------------------------------------------------------------
# Monta datas de referencia para vigencia do seguro
#---------------------------------------------------------------
 let ws.data_de  = today

 let ws.auxdat   = ws.data_de + 32
 let ws.auxdat   = "05","/", ws.auxdat[4,5],"/", ws.auxdat[7,10]
 let ws.data_ate = ws.auxdat

#---------------------------------------------------------------
# Carrega tabelas de codigos de inconsistencia
#---------------------------------------------------------------
 for arr_aux = 1 to 15
     case arr_aux
          when 01
               let a_bdbsr036[arr_aux].vclicsdes = "BLOQUEADO"
          when 02
               let a_bdbsr036[arr_aux].vclicsdes = "SEM PLACA CADASTRADA"
          when 03
               let a_bdbsr036[arr_aux].vclicsdes = "SEM SEGURO CADASTRADO"
          when 04
               let a_bdbsr036[arr_aux].vclicsdes = "SEGURO VENCIDO"
          when 05
               let a_bdbsr036[arr_aux].vclicsdes = "SEGURO A VENCER NO MES"
          when 06
               let a_bdbsr036[arr_aux].vclicsdes = "APOLICE CANCELADA"
          when 07
               let a_bdbsr036[arr_aux].vclicsdes = "ITEM DA APOLICE CANCELADO"
          when 08
               let a_bdbsr036[arr_aux].vclicsdes = "VIGENCIA DIFERE DA APOLICE"
          when 09
               let a_bdbsr036[arr_aux].vclicsdes = "I.S. D.M. DIFERE DA APOLICE"
          when 10
               let a_bdbsr036[arr_aux].vclicsdes = "I.S. D.P. DIFERE DA APOLICE"
          when 11
               let a_bdbsr036[arr_aux].vclicsdes = "COD.VEICULO DIFERE DA APOLICE"
          when 12
               let a_bdbsr036[arr_aux].vclicsdes = "PLACA DIFERE DA APOLICE"
          when 13
               let a_bdbsr036[arr_aux].vclicsdes = "SEM VISTORIA AGENDADA"
          when 14
               let a_bdbsr036[arr_aux].vclicsdes = "COM VISTORIA VENCIDA"
          when 15
               let a_bdbsr036[arr_aux].vclicsdes = "VISTORIA NO MES S/CONFIRMACAO"
     end case

     let a_bdbsr036[arr_aux].vclicsqtd = 000
 end for

#---------------------------------------------------------------
# Preparacao dos comandos SQL
#---------------------------------------------------------------
 let ws.comando = "select max(vclsgrseq)  ",
                  "  from datkvclsgr   ",
                  " where socvclcod = ?"
 prepare sel_datkvclsgr1  from  ws.comando
 declare c_datkvclsgr1  cursor for sel_datkvclsgr1

 let ws.comando = "select sgdirbcod,   ",
                  "       succod,      ",
                  "       aplnumdig,   ",
                  "       itmnumdig,   ",
                  "       sgraplnum,   ",
                  "       vigfnl,      ",
                  "       sgrimsdmvlr, ",
                  "       sgrimsdpvlr  ",
                  "  from datkvclsgr ",
                  " where socvclcod = ?",
                  "   and vclsgrseq = ?"
 prepare sel_datkvclsgr2  from  ws.comando
 declare c_datkvclsgr2  cursor for sel_datkvclsgr2

 let ws.comando = "select vigfnl, aplstt ",
                  "  from abamapol ",
                  " where abamapol.succod    = ? ",
                  "   and abamapol.aplnumdig = ? "
 prepare sel_abamapol  from  ws.comando
 declare c_abamapol  cursor for sel_abamapol

 let ws.comando = "select itmsttatu ",
                  "  from abbmitem ",
                  " where abbmitem.succod    = ? ",
                  "   and abbmitem.aplnumdig = ? ",
                  "   and abbmitem.itmnumdig = ? "
 prepare sel_abbmitem  from  ws.comando
 declare c_abbmitem  cursor for sel_abbmitem

 let ws.comando = "select imsvlr ",
                  "  from abbmdm ",
                  " where succod    = ? ",
                  "   and aplnumdig = ? ",
                  "   and itmnumdig = ? ",
                  "   and dctnumseq = ? "
 prepare sel_abbmdm    from  ws.comando
 declare c_abbmdm    cursor for sel_abbmdm

 let ws.comando = "select imsvlr ",
                  "  from abbmdp ",
                  " where succod    = ? ",
                  "   and aplnumdig = ? ",
                  "   and itmnumdig = ? ",
                  "   and dctnumseq = ? "
 prepare sel_abbmdp    from  ws.comando
 declare c_abbmdp    cursor for sel_abbmdp

 let ws.comando = " select vclcoddig, ",
                  "        vcllicnum  ",
                  "   from abbmveic   ",
                  "  where abbmveic.succod    = ? ",
                  "    and abbmveic.aplnumdig = ? ",
                  "    and abbmveic.itmnumdig = ? ",
                  "    and abbmveic.dctnumseq = ? "
 prepare sel_abbmveic  from  ws.comando
 declare c_abbmveic  cursor for sel_abbmveic


#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "RELATO")                                      # Marcio Meta - PSI185035
      returning ws.dirfisnom 
 
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if                                                            # Marcio Meta - PSI185035     

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS03601"


#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDBS03601")                                       # Marcio Meta - PSI185035     
      returning  ws_cctcod,
 	         ws_relviaqtd


#---------------------------------------------------------------
# Ler todos os veiculos do cadastro
#---------------------------------------------------------------
 declare  c_bdbsr036  cursor for
    select datkveiculo.socvclcod,
           datkveiculo.atdvclsgl,
           datkveiculo.vcllicnum,
           datkveiculo.pstcoddig,
           datkveiculo.vclcoddig,
           datkveiculo.socoprsitcod,
           datkveiculo.socvstdiaqtd
      from datkveiculo
     where datkveiculo.socvclcod  >  0

 start report  rep_icsvcl  to ws.pathrel01

 foreach c_bdbsr036  into  d_bdbsr036.socvclcod,
                           d_bdbsr036.atdvclsgl,
                           d_bdbsr036.vcllicnum,
                           d_bdbsr036.pstcoddig,
                           d_bdbsr036.vclcoddig,
                           ws.socoprsitcod,
                           ws.socvstdiaqtd

    if ws.socoprsitcod  =  3   then   #--> Cancelado
       continue foreach
    end if

    #---------------------------------------------------------------
    # Verifica veiculos com situacao bloqueada
    #---------------------------------------------------------------
    if ws.socoprsitcod  =  2   then
       let ws_vclicscod  =  01
       let d_bdbsr036.vclicscod  =  ws_vclicscod
       let a_bdbsr036[ws_vclicscod].vclicsqtd =
           a_bdbsr036[ws_vclicscod].vclicsqtd + 1

       output to report rep_icsvcl (d_bdbsr036.*)
    end if

    #---------------------------------------------------------------
    # Verifica veiculos sem placa cadastrada
    #---------------------------------------------------------------
    if d_bdbsr036.vcllicnum  is null   then
       let ws_vclicscod  =  02
       let d_bdbsr036.vclicscod  =  ws_vclicscod
       let a_bdbsr036[ws_vclicscod].vclicsqtd =
           a_bdbsr036[ws_vclicscod].vclicsqtd + 1

       output to report rep_icsvcl (d_bdbsr036.*)
    end if

    #---------------------------------------------------------------
    # Verifica informacoes sobre o seguro do veiculo
    #---------------------------------------------------------------
    initialize ws.vclsgrseq     to null
    initialize ws.sgdirbcod     to null
    initialize ws.succod        to null
    initialize ws.aplnumdig     to null
    initialize ws.itmnumdig     to null
    initialize ws.vigfnl        to null
    initialize ws.sgrimsdmvlr   to null
    initialize ws.sgrimsdpvlr   to null
    initialize ws.vclcoddigapl  to null
    initialize ws.vcllicnumapl  to null

    open  c_datkvclsgr1 using d_bdbsr036.socvclcod
    fetch c_datkvclsgr1 into  ws.vclsgrseq
    close c_datkvclsgr1

    if ws.vclsgrseq  is null   then
       if d_bdbsr036.pstcoddig  <>  1   and
          d_bdbsr036.pstcoddig  <>  4   and
          d_bdbsr036.pstcoddig  <>  8   then
          let ws_vclicscod  =  03
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)
       end if
    else

       open  c_datkvclsgr2 using d_bdbsr036.socvclcod,
                                 ws.vclsgrseq
       fetch c_datkvclsgr2 into  ws.sgdirbcod,
                                 ws.succod,
                                 ws.aplnumdig,
                                 ws.itmnumdig,
                                 ws.sgraplnum,
                                 ws.vigfnl,
                                 ws.sgrimsdmvlr,
                                 ws.sgrimsdpvlr
       close c_datkvclsgr2

       if ws.vigfnl  <  ws.data_de   then
          let ws_vclicscod  =  04
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)
       else
          if ws.vigfnl  >=  ws.data_de    and
             ws.vigfnl  <   ws.data_ate   then
             let ws_vclicscod  =  05
             let d_bdbsr036.vclicscod  =  ws_vclicscod
             let a_bdbsr036[ws_vclicscod].vclicsqtd =
                 a_bdbsr036[ws_vclicscod].vclicsqtd + 1

             output to report rep_icsvcl (d_bdbsr036.*)
          end if
       end if
    end if

    #---------------------------------------------------------------
    # Verifica situacao da apolice/item (so' para Porto Seguro)
    #---------------------------------------------------------------
    if ws.vclsgrseq   is not null   and
       ws.sgdirbcod   = 5886        then

       initialize ws.aplstt     to null
       initialize ws.itmsttatu  to null
       initialize ws.vigfnlapl  to null

       open  c_abamapol using ws.succod,
                              ws.aplnumdig
       fetch c_abamapol into  ws.vigfnlapl,
                              ws.aplstt
       close c_abamapol

       if ws.aplstt  is null   or
          ws.aplstt  <>  "A"   then
          let ws_vclicscod  =  06
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)
       end if

       if ws.vigfnlapl  <>  ws.vigfnl   then
          let ws_vclicscod  =  08
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)
       end if

       open  c_abbmitem using ws.succod,
                              ws.aplnumdig,
                              ws.itmnumdig
       fetch c_abbmitem into  ws.itmsttatu
       close c_abbmitem

       if ws.itmsttatu  is null   or
          ws.itmsttatu  <>  "A"   then
          let ws_vclicscod  =  07
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)
       end if

       #--------------------------------------------------------------
       # Busca ultima situacao da apolice
       #--------------------------------------------------------------
       initialize g_funapol.*     to null
       initialize ws.dmimsvlrapl  to null
       initialize ws.dpimsvlrapl  to null

       call f_funapol_ultima_situacao
            (ws.succod, ws.aplnumdig, ws.itmnumdig)
            returning g_funapol.*

       #--------------------------------------------------------------
       # Busca valores de Danos Materiais/Danos Pessoais da apolice
       #--------------------------------------------------------------
       open  c_abbmdm using ws.succod,
                            ws.aplnumdig,
                            ws.itmnumdig,
                            g_funapol.dmtsitatu
       fetch c_abbmdm into  ws.dmimsvlrapl
       close c_abbmdm

       open  c_abbmdp using ws.succod,
                            ws.aplnumdig,
                            ws.itmnumdig,
                            g_funapol.dpssitatu
       fetch c_abbmdp into  ws.dpimsvlrapl
       close c_abbmdp

       if (ws.sgrimsdmvlr  is null       and
           ws.dmimsvlrapl  is not null)          or

          (ws.sgrimsdmvlr  is not null   and
           ws.dmimsvlrapl  is null)              or

          (ws.sgrimsdmvlr  <>  ws.dmimsvlrapl)   then

          let ws_vclicscod  =  09
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)
       end if

       if (ws.sgrimsdpvlr  is null       and
           ws.dpimsvlrapl  is not null)          or

          (ws.sgrimsdpvlr  is not null   and
           ws.dpimsvlrapl  is null)              or

          (ws.sgrimsdpvlr  <>  ws.dpimsvlrapl)   then

          let ws_vclicscod  =  10
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)
       end if

       #--------------------------------------------------------------
       # Busca placa/codigo veiculo da apolice
       #--------------------------------------------------------------
       open  c_abbmveic using ws.succod,
                              ws.aplnumdig,
                              ws.itmnumdig,
                              g_funapol.vclsitatu
       fetch c_abbmveic into  ws.vclcoddigapl,
                              ws.vcllicnumapl
       close c_abbmveic

       if d_bdbsr036.vclcoddig  <>  ws.vclcoddigapl   then
          let ws_vclicscod  =  11
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)
       end if

       if d_bdbsr036.vcllicnum  <>  ws.vcllicnumapl   then
          let ws_vclicscod  =  12
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)
       end if

    end if

    #---------------------------------------------------------------
    # Verifica veiculos sem vistoria agendada
    #---------------------------------------------------------------
    if ws.socvstdiaqtd is not null then
       let ws.count = 0
       select count(*)
         into ws.count
         from datmsocvst
        where datmsocvst.socvclcod  =  d_bdbsr036.socvclcod
          and datmsocvst.socvstsit  in (1,2)  # <---(agendada/confirmada)
          and datmsocvst.socvstdat  >= today

       if ws.count = 0 then
          let ws_vclicscod  =  13
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)

       end if

    end if

    #---------------------------------------------------------------
    # Verifica veiculo com vistoria vencida
    #---------------------------------------------------------------
    if ws.socvstdiaqtd is not null then
       let ws.count = 0
       select count(*)
         into ws.count
         from datmsocvst
        where datmsocvst.socvclcod  = d_bdbsr036.socvclcod
          and datmsocvst.socvstsit in (1,2,3)  # <---(agend./conf./dig.inc.)
          and datmsocvst.socvstdat  < today

       if ws.count > 0 then
          let ws_vclicscod  =  14
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)

       end if

    end if

    #---------------------------------------------------------------
    # Verifica vistoria no mes sem confirmacao
    #---------------------------------------------------------------
    if ws.socvstdiaqtd is not null then
       let ws.count = 0
       select count(*)
         into ws.count
         from datmsocvst
        where datmsocvst.socvclcod  = d_bdbsr036.socvclcod
          and datmsocvst.socvstsit  = 1     # <---(agendada)
          and (datmsocvst.socvstdat >= today and
               datmsocvst.socvstdat <= ws.data_ate)

       if ws.count > 0 then
          let ws_vclicscod  =  15
          let d_bdbsr036.vclicscod  =  ws_vclicscod
          let a_bdbsr036[ws_vclicscod].vclicsqtd =
              a_bdbsr036[ws_vclicscod].vclicsqtd + 1

          output to report rep_icsvcl (d_bdbsr036.*)

       end if

    end if

 end foreach


 finish report  rep_icsvcl
 close c_bdbsr036

end function  ###  bdbsr036


#---------------------------------------------------------------------------
 report rep_icsvcl(r_bdbsr036)
#---------------------------------------------------------------------------

 define r_bdbsr036    record
    pstcoddig         like datkveiculo.pstcoddig,
    socvclcod         like datkveiculo.socvclcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    vclcoddig         like datkveiculo.vclcoddig,
    vcllicnum         like datkveiculo.vcllicnum,
    vclicscod         dec  (2,0)
 end record

 define ws            record
    comando           char (400),
    socvclcodant      like datkveiculo.socvclcod,
    nomrazsoc         like dpaksocor.nomrazsoc,
    vclmrcnom         like agbkmarca.vclmrcnom,
    vcltipnom         like agbktip.vcltipnom,
    vclmdlnom         like agbkveic.vclmdlnom,
    vcldes            char (58),
    icsgrltot         dec  (5,0)
 end record

 define ws_vclicscod  integer


 output
    left   margin  000
    right  margin  132
    top    margin  000
    bottom margin  000
    page   length  066

 order by  r_bdbsr036.pstcoddig,
           r_bdbsr036.socvclcod,
           r_bdbsr036.vclicscod

 format
    page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS03601 FORMNAME=BRANCO"        # Marcio Meta - PSI185035     
            print "HEADER PAGE"
            print "       JOBNAME= INCONSISTENCIAS NO CADASTRO DE VEICULOS P.SOCORRO"
            print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
            print ascii(12)

            #---------------------------------------------------------------
            # Preparacao dos comandos SQL
            #---------------------------------------------------------------
            initialize ws.*  to null
            let ws.icsgrltot     =  0
            let ws.socvclcodant  =  0

            let ws.comando = "select nomrazsoc ",
                             "  from dpaksocor ",
                             " where pstcoddig = ?"
            prepare sel_dpaksocor    from ws.comando
            declare c_dpaksocor    cursor for sel_dpaksocor

            let ws.comando = "select vclmrcnom, ",
                             "       vcltipnom, ",
                             "       vclmdlnom  ",
                             " from agbkveic, outer agbkmarca, outer agbktip ",
                             "where agbkveic.vclcoddig  = ? ",
                             "  and agbkmarca.vclmrccod = agbkveic.vclmrccod ",
                             "  and agbktip.vclmrccod   = agbkveic.vclmrccod ",
                             "  and agbktip.vcltipcod   = agbkveic.vcltipcod "
            prepare sel_veiculo    from ws.comando
            declare c_veiculo    cursor for sel_veiculo

         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 100, "RDBS036-01",
               column 114, "PAGINA : ", pageno using "##,###,##&"
         print column 114, "DATA   : ", today
         print column 038, "INCONSISTENCIAS NO CADASTRO DE VEICULOS DO PORTO SOCORRO",
               column 114, "HORA   :   ", time
         skip 2 lines

         print column 001, "CODIGO",
               column 010, "PRESTADOR"

         print column 010, "SIGLA",
               column 017, "COD.",
               column 023, "DESCRICAO DO VEICULO",
               column 085, "PLACA",
               column 095, "INCONSISTENCIA"

         print column 001, wsgtraco
         skip 1 line

    before group of r_bdbsr036.pstcoddig
         initialize ws.nomrazsoc  to null
         open  c_dpaksocor using r_bdbsr036.pstcoddig
         fetch c_dpaksocor into  ws.nomrazsoc
         close c_dpaksocor

         need 3 lines
         print column 001, r_bdbsr036.pstcoddig  using "####&&",
               column 010, ws.nomrazsoc

    after group of r_bdbsr036.pstcoddig
         skip 2 lines

    before group of r_bdbsr036.socvclcod
         initialize ws.vclmrcnom  to null
         initialize ws.vcltipnom  to null
         initialize ws.vclmdlnom  to null
         initialize ws.vcldes     to null

         open  c_veiculo using r_bdbsr036.vclcoddig
         fetch c_veiculo into  ws.vclmrcnom,
                               ws.vcltipnom,
                               ws.vclmdlnom
         close c_veiculo

         let ws.vcldes = ws.vclmrcnom clipped, " ",
                         ws.vcltipnom clipped, " ",
                         ws.vclmdlnom

    on every row
         let ws_vclicscod = r_bdbsr036.vclicscod

         if r_bdbsr036.socvclcod  <>  ws.socvclcodant   then
            skip 1 line
            print column 010, r_bdbsr036.atdvclsgl,
                  column 017, r_bdbsr036.socvclcod  using "##&&",
                  column 023, ws.vcldes,
                  column 085, r_bdbsr036.vcllicnum,
                  column 095, a_bdbsr036[ws_vclicscod].vclicsdes
         else
            print column 095, a_bdbsr036[ws_vclicscod].vclicsdes
         end if

         let ws.icsgrltot = ws.icsgrltot + 1
         let ws.socvclcodant  =  r_bdbsr036.socvclcod

    on last  row
         skip to top of page
         skip 6 lines

         print column 038, "INCONSISTENCIA",
               column 079, "QTDE"
         print column 038, "-----------------------------------",
               column 079, "----"
         skip 1 line

         for ws_vclicscod = 1 to 15
             print column 038, ws_vclicscod          using "&&",     " - ",
                   column 043, a_bdbsr036[ws_vclicscod].vclicsdes,   "   ",
                   column 078, a_bdbsr036[ws_vclicscod].vclicsqtd using "###&&"
         end for
         skip 1 line

         print column 038, "TOTAL DE INCONSISTENCIAS ",
               column 078, ws.icsgrltot  using  "###&&"

         print "$FIMREL$"

end report  ## rep_icsvcl
