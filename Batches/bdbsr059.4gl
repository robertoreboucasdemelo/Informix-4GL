############################################################################
# Nome do Modulo: bdbsr059                                        Gilberto #
#                                                                  Marcelo #
# Relacao de tarifas do Porto Socorro (vigentes)                  Mar/1997 #
############################################################################
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

database porto

define g_traco       char(132)
define ws_cctcod     like igbrrelcct.cctcod
define ws_relviaqtd  like igbrrelcct.relviaqtd

main
   call fun_dba_abre_banco("CT24HS") 
   call bdbsr059()
end main

#---------------------------------------------------------------
 function  bdbsr059()
#---------------------------------------------------------------

   define d_bdbsr059   record
      soctrfvignum     like dbstgtfcst.soctrfvignum,
      soctrfcod        like dbsktarifasocorro.soctrfcod,
      soctrfdes        like dbsktarifasocorro.soctrfdes,
      socgtfcod        like dbskgtf.socgtfcod,
      socgtfdes        like dbskgtf.socgtfdes,
      vclcoddig        like dbsrvclgtf.vclcoddig,
      vclmrccod        like agbkveic.vclmrccod,
      vcltipcod        like agbkveic.vcltipcod,
      vcldes           char (60)
   end record

   define ws           record
      comando          char(400),
      data             date,
      vclmdlnom        like agbkveic.vclmdlnom,
      vcltipnom        like agbktip.vcltipnom,
      vclmrcnom        like agbkmarca.vclmrcnom,
      dirfisnom        like ibpkdirlog.dirfisnom,
      pathrel01        char (60)
   end record

let g_traco = "------------------------------------------------------------------------------------------------------------------------------------"

initialize d_bdbsr059.*  to null
initialize ws.*          to null

#let ws.data = today + 1 units day
 let ws.data = today + 30 units day


#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "RELATO")                                 # Marcio  Meta - PSI185035
      returning ws.dirfisnom
      
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if          
 
 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS05901"
                                                              # Marcio  Meta - PSI185035

#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDBS05901")                                   # Marcio  Meta - PSI185035
      returning  ws_cctcod,
		 ws_relviaqtd


let ws.comando = "select vclmrccod, vcltipcod, vclmdlnom ",
                 "  from agbkveic ",
                 " where agbkveic.vclcoddig = ? "
prepare sel_veic  from ws.comando
declare c_veic  cursor for sel_veic

let ws.comando = "select vclmrcnom ",
                 "  from agbkmarca ",
                 " where agbkmarca.vclmrccod = ? "
prepare sel_marca  from ws.comando
declare c_marca  cursor for sel_marca

let ws.comando =  "select vcltipnom ",
                  "  from agbktip   ",
                  " where agbktip.vclmrccod = ?  and ",
                  "       agbktip.vcltipcod = ?      "
prepare sel_tipo  from ws.comando
declare c_tipo  cursor for sel_tipo

let ws.comando =  "select soctrfdes from dbsktarifasocorro",
                  " where dbsktarifasocorro.soctrfcod = ? "
prepare sel_trfsoc from ws.comando
declare c_trfsoc cursor for sel_trfsoc

let ws.comando =  "select socgtfdes from dbskgtf",
                  " where dbskgtf.socgtfcod = ? "
prepare sel_grptrf from ws.comando
declare c_grptrf cursor for sel_grptrf

let ws.comando = "select dbskcustosocorro.soccstdes   ,  ",
                 "       dbskcustosocorro.soccstexbseq,  ",
                 "       dbstgtfcst.socgtfcstvlr         ",
                 "  from dbstgtfcst, dbskcustosocorro    ",
                 " where dbstgtfcst.soctrfvignum = ?  and",
                 "       dbstgtfcst.socgtfcod    = ?  and",
                 "       dbstgtfcst.soccstcod    =       ",
                 "       dbskcustosocorro.soccstcod      ",
                 " order by dbskcustosocorro.soccstexbseq"
prepare sel_custo from ws.comando
declare c_bdbsr059cst cursor for sel_custo

let ws.comando = "select vclcoddig    ",
                 "  from dbsrvclgtf   ",
                 " where socgtfcod = ?"
prepare sel_vclgtf from ws.comando
declare c_bdbsr059gtf cursor for sel_vclgtf

declare c_bdbsr059   cursor for
   select dbsmvigtrfsocorro.soctrfvignum,
          dbsmvigtrfsocorro.soctrfcod,
          dbstgtfcst.socgtfcod
     from dbsmvigtrfsocorro, dbstgtfcst
    where ws.data  between  soctrfvigincdat  and  soctrfvigfnldat    and
          dbstgtfcst.soctrfvignum = dbsmvigtrfsocorro.soctrfvignum
    group by dbsmvigtrfsocorro.soctrfvignum,
             dbsmvigtrfsocorro.soctrfcod,
             dbstgtfcst.socgtfcod

start report  rep_bdbsr059  to  ws.pathrel01

foreach c_bdbsr059 into  d_bdbsr059.soctrfvignum,
                         d_bdbsr059.soctrfcod,
                         d_bdbsr059.socgtfcod

   if d_bdbsr059.soctrfvignum <> 1  then
      continue foreach
   end if

   open    c_bdbsr059gtf using d_bdbsr059.socgtfcod
   foreach c_bdbsr059gtf into  d_bdbsr059.vclcoddig

      initialize d_bdbsr059.vclmrccod   to null
      initialize d_bdbsr059.vcltipcod   to null
      initialize ws.vclmdlnom           to null
      initialize ws.vcltipnom           to null
      initialize ws.vclmrcnom           to null

      open  c_veic  using d_bdbsr059.vclcoddig
      fetch c_veic  into  d_bdbsr059.vclmrccod,
                          d_bdbsr059.vcltipcod,
                          ws.vclmdlnom

      if sqlca.sqlcode <> 0   then
         display "Erro (",sqlca.sqlcode,") na leitura do VEICULO ", d_bdbsr059.vclcoddig using "&&&&&"
         continue foreach
      end if

      open  c_marca  using d_bdbsr059.vclmrccod
      fetch c_marca  into  ws.vclmrcnom

      if sqlca.sqlcode <> 0   then
         display "Erro (",sqlca.sqlcode,") na leitura da MARCA do veiculo ", d_bdbsr059.vclcoddig using "&&&&&"
         continue foreach
      end if

      open  c_tipo  using d_bdbsr059.vclmrccod,
                          d_bdbsr059.vcltipcod
      fetch c_tipo  into  ws.vcltipnom

      if sqlca.sqlcode <> 0   then
         display "Erro (",sqlca.sqlcode,") na leitura do TIPO do veiculo ", d_bdbsr059.vclcoddig using "&&&&&"
         continue foreach
      end if

      let d_bdbsr059.vcldes = ws.vclmrcnom clipped, " ",
                              ws.vcltipnom clipped, " ",
                              ws.vclmdlnom

      output to report rep_bdbsr059(d_bdbsr059.*)

   end foreach

end foreach

finish report  rep_bdbsr059

end function   ###  bdbsr059

#---------------------------------------------------------------------------
 report rep_bdbsr059(r_bdbsr059)
#---------------------------------------------------------------------------

 define r_bdbsr059   record
    soctrfvignum     like dbstgtfcst.soctrfvignum,
    soctrfcod        like dbsktarifasocorro.soctrfcod,
    soctrfdes        like dbsktarifasocorro.soctrfdes,
    socgtfcod        like dbskgtf.socgtfcod,
    socgtfdes        like dbskgtf.socgtfdes,
    vclcoddig        like dbsrvclgtf.vclcoddig,
    vclmrccod        like agbkveic.vclmrccod,
    vcltipcod        like agbkveic.vcltipcod,
    vcldes           char (60)
 end record

 define a_bdbsr059   array[20] of record
    socgtfcstvlr     like dbstgtfcst.socgtfcstvlr
 end record

 define arr_aux      smallint

 define ws           record
    cabflg           smallint,
    soctrfdes        like dbsktarifasocorro.soctrfdes,
    soccstcod        like dbskcustosocorro.soccstcod,
    soccstdes        like dbskcustosocorro.soccstdes,
    soccstexbseq     like dbskcustosocorro.soccstexbseq,
    socgtfdes        like dbskgtf.socgtfdes
 end record

 output left   margin  000
        right  margin  132
        top    margin  000
        bottom margin  000
        page   length  066

   order by  r_bdbsr059.soctrfcod,
             r_bdbsr059.socgtfcod,
             r_bdbsr059.vclmrccod,
             r_bdbsr059.vcltipcod

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS05901 FORMNAME=BRANCO"      # Marcio  Meta - PSI185035
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - TARIFAS VIGENTES - P.SOCORRO"
            print "$DJDE$ JDL=XJ0000, JDE=XD0000, FORMS=XF6530, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
            print ascii(12)

            initialize  ws.*   to null
            let ws.cabflg = TRUE

            for arr_aux = 01 to 20
               let a_bdbsr059[arr_aux].socgtfcstvlr = 0.00
            end for

            open  c_trfsoc  using r_bdbsr059.soctrfcod
            fetch c_trfsoc  into ws.soctrfdes
            close c_trfsoc

            open  c_grptrf  using r_bdbsr059.socgtfcod
            fetch c_grptrf  into ws.socgtfdes
            close c_grptrf
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if

         print column 100, "RDBS059-01",
               column 114, "PAGINA : ", pageno using "##,###,###"
         print column 040, "TARIFAS DO PORTO SOCORRO VIGENTES EM ", today,
               column 114, "DATA   : ", today
         print column 114, "HORA   :   ", time
         skip 1 lines
         print column 001, "TARIFA.........: ", r_bdbsr059.soctrfcod using "&&&&&&", " - " , ws.soctrfdes
         print column 001, "GRUPO TARIFARIO: ", r_bdbsr059.socgtfcod using "&&&&&&", " - ", ws.socgtfdes
         print column 001, g_traco

         if ws.cabflg = TRUE   then
            print column 015, "CUSTO",
                  column 072, "VALOR"
         else
            print column 001, "DESCRICAO DO VEICULO",
                  column 064, "VLR. FAIXA 1"        ,
                  column 078, "VLR. FAIXA 2"        ,
                  column 092, "KM EXCEDENTE"        ,
                  column 106, "    H.PARADA"        ,
                  column 120, "H.TRABALHADA"
         end if

         print column 001, g_traco
         skip 1 line

      before group of r_bdbsr059.soctrfcod
         initialize  ws.soctrfdes   to null

         open  c_trfsoc  using r_bdbsr059.soctrfcod
         fetch c_trfsoc  into ws.soctrfdes
         close c_trfsoc

         skip to top of page

      before group of r_bdbsr059.socgtfcod
         initialize  ws.socgtfdes   to null

         open  c_grptrf  using r_bdbsr059.socgtfcod
         fetch c_grptrf  into ws.socgtfdes
         close c_grptrf

         let ws.cabflg = TRUE
         skip to top of page

         let arr_aux = 1

         open    c_bdbsr059cst using r_bdbsr059.soctrfvignum,
                                     r_bdbsr059.socgtfcod

         foreach c_bdbsr059cst  into ws.soccstdes   , ws.soccstexbseq,
                                     a_bdbsr059[arr_aux].socgtfcstvlr
             if ws.soccstexbseq = 6  then  ## Nao imprime ADICIONAIS
                continue foreach
             end if
             print column 015, ws.soccstdes,
                   column 067, a_bdbsr059[arr_aux].socgtfcstvlr using "###,##&.&&"
             let arr_aux = arr_aux + 1
         end foreach

         let ws.cabflg = FALSE
         skip to top of page

      on every row
         print column 001, r_bdbsr059.vcldes ,
               column 066, a_bdbsr059[01].socgtfcstvlr using "###,##&.&&",
               column 080, a_bdbsr059[02].socgtfcstvlr using "###,##&.&&",
               column 094, a_bdbsr059[03].socgtfcstvlr using "###,##&.&&",
               column 108, a_bdbsr059[04].socgtfcstvlr using "###,##&.&&",
               column 122, a_bdbsr059[05].socgtfcstvlr using "###,##&.&&"

      on last row
         print "$FIMREL$"

end report
