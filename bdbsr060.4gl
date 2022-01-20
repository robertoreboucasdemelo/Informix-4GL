############################################################################
# Nome do Modulo: bdbsr060                                        Gilberto #
#                                                                  Marcelo #
# Relacao de veiculos sem grupo tarifario - Porto Socorro         Mar/1997 #
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

define wsgtraco      char(080)
define ws_cctcod     like igbrrelcct.cctcod
define ws_relviaqtd  like igbrrelcct.relviaqtd

main
   call fun_dba_abre_banco("CT24HS") 
   call bdbsr060()
end main

#---------------------------------------------------------------
 function  bdbsr060()
#---------------------------------------------------------------

   define d_bdbsr060   record
      vclmrccod        like agbkveic.vclmrccod,
      vcltipcod        like agbkveic.vcltipcod,
      autctgatu        like agetdecateg.autctgatu,
      vclcoddig        like dbsrvclgtf.vclcoddig,
      vcldes           char (60)
   end record

   define ws           record
      comando          char(400),
      data             date,
      vclcoddig        like dbsrvclgtf.vclcoddig,
      vclmdlnom        like agbkveic.vclmdlnom,
      vcltipnom        like agbktip.vcltipnom,
      vclmrcnom        like agbkmarca.vclmrcnom,
      dirfisnom        like ibpkdirlog.dirfisnom,
      pathrel01        char (60)
   end record

let wsgtraco = "-------------------------------------------------------------------------------"
initialize d_bdbsr060.*  to null
initialize ws.*          to null
let ws.data = today

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

let ws.comando =  "select vclcoddig ",
                  "  from dbsrvclgtf",
                  " where vclcoddig = ? "
prepare sel_grup  from ws.comando
declare c_grup  cursor for sel_grup

let ws.comando = "select autctgatu      ",
                  "  from agetdecateg    ",
                  " where vclcoddig  = ? ",
                  "   and viginc    <= ? ",
                  "   and vigfnl    >= ? "
prepare sel_categ from ws.comando
declare c_categ cursor for sel_categ

#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "RELATO")                            # Marcio  Meta - PSI185035
      returning ws.dirfisnom  
 
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if          
 
 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS06001"
                                                         # Marcio  Meta - PSI185035
#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDBS06001")                              # Marcio  Meta - PSI185035
      returning  ws_cctcod,
		 ws_relviaqtd


#-------------------------------------------
# LER TODOS OS VEICULOS E COMPARA COM GRUPO
#       TARIFARIO DO PORTO SOCORRO
#-------------------------------------------
declare c_bdbsr060   cursor for
   select vclcoddig,
          vclmrccod,
          vcltipcod,
          vclmdlnom
     from agbkveic
    where agbkveic.vclcoddig > 0

start report  rep_bdbsr060  to  ws.pathrel01

foreach c_bdbsr060 into  d_bdbsr060.vclcoddig,
                    d_bdbsr060.vclmrccod,
                    d_bdbsr060.vcltipcod,
                    ws.vclmdlnom

      open  c_grup  using d_bdbsr060.vclcoddig
      fetch c_grup  into  ws.vclcoddig

      if sqlca.sqlcode = 0    then
         continue foreach
      else
         if sqlca	.sqlcode <> 100   then
            display "Erro (",sqlca.sqlcode,") na leitura do GRUPO ", d_bdbsr060.vclcoddig using "&&&&&"
            exit foreach
         end if
      end if

      initialize ws.vcltipnom           to null
      initialize ws.vclmrcnom           to null

      open  c_marca  using d_bdbsr060.vclmrccod
      fetch c_marca  into  ws.vclmrcnom

      if sqlca.sqlcode <> 0   then
         display "Erro (",sqlca.sqlcode,") na leitura da MARCA do veiculo ", d_bdbsr060.vclcoddig using "&&&&&"
         exit foreach
      end if

      open  c_tipo  using d_bdbsr060.vclmrccod,
                          d_bdbsr060.vcltipcod
      fetch c_tipo  into  ws.vcltipnom

      if sqlca.sqlcode <> 0   then
         display "Erro (",sqlca.sqlcode,") na leitura do TIPO do veiculo ", d_bdbsr060.vclcoddig using "&&&&&"
       # exit foreach
         continue foreach
      end if

      let d_bdbsr060.vcldes = ws.vclmrcnom clipped, " ",
                              ws.vcltipnom clipped, " ",
                              ws.vclmdlnom

      initialize d_bdbsr060.autctgatu  to null

      open  c_categ using d_bdbsr060.vclcoddig, ws.data, ws.data
      fetch c_categ into  d_bdbsr060.autctgatu

      output to report rep_bdbsr060(d_bdbsr060.*)

end foreach

finish report  rep_bdbsr060

end function   ###  bdbsr060

#---------------------------------------------------------------------------
 report rep_bdbsr060(r_bdbsr060)
#---------------------------------------------------------------------------

 define r_bdbsr060   record
    vclmrccod        like agbkveic.vclmrccod,
    vcltipcod        like agbkveic.vcltipcod,
    autctgatu        like agetdecateg.autctgatu,
    vclcoddig        like dbsrvclgtf.vclcoddig,
    vcldes           char (60)
 end record

 output left   margin  000
        right  margin  132
        top    margin  000
        bottom margin  000
        page   length  090

   order by  r_bdbsr060.vclmrccod,
             r_bdbsr060.vcltipcod

   format
      page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DBS06001 FORMNAME=BRANCO"         # Marcio  Meta - PSI185035
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - VEICULOS SEM GRUPO (P.SOCORRO)"
            print "$DJDE$ JDL=XJ0030, JDE=XD0030, FORMS=XF6560, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
            print ascii(12)

         else
           print "$DJDE$ C LIXOLIXO, ;"
           print "$DJDE$ C LIXOLIXO, ;"
           print "$DJDE$ C LIXOLIXO, ;"
           print "$DJDE$ C LIXOLIXO, END ;"
           print ascii(12)
         end if

         print column 047, "RDBS060-01",
               column 061, "PAGINA : ", pageno using "##,###,###"
         print column 061, "DATA   : ", today
         print column 005, "VEICULOS SEM GRUPO TARIFARIO - PORTO SOCORRO",
               column 061, "HORA   :   ", time
         skip 2 lines
         print column 001, "CODIGO",
               column 009, "CATEGORIA",
               column 020, "VEICULO"
         print column 001, wsgtraco
         skip 1 lines

      on every row
         print column 002, r_bdbsr060.vclcoddig  using  "####&",
               column 013, r_bdbsr060.autctgatu  using  "&&",
               column 020, r_bdbsr060.vcldes

      on last  row
         print "$FIMREL$"

end report
