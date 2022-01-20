############################################################################
# Nome do Modulo: bdbsr057                                        Marcelo  #
#                                                                 Gilberto #
# Mala direta (etiquetas) do jornal do Porto Socorro              Jul/1996 #
############################################################################# 
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
############################################################################# 
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

define ws_cctcod01     like igbrrelcct.cctcod
define ws_relviaqtd01  like igbrrelcct.relviaqtd
define ws_cctcod02     like igbrrelcct.cctcod
define ws_relviaqtd02  like igbrrelcct.relviaqtd

main
   call fun_dba_abre_banco("CT24HS") 
   call bdbsr057()
end main

#---------------------------------------------------------------
 function bdbsr057()
#---------------------------------------------------------------

   define d_bdbsr057 record
      pstcoddig      like dpaksocor.pstcoddig,
      nomrazsoc      like dpaksocor.nomrazsoc,
      pptnom         like dpaksocor.pptnom   ,
      endlgd         like dpaksocor.endlgd   ,
      endbrr         like dpaksocor.endbrr   ,
      endcid         like dpaksocor.endcid   ,
      endufd         like dpaksocor.endufd   ,
      endcep         like dpaksocor.endcep   ,
      endcepcmp      like dpaksocor.endcepcmp,
      prssitcod      like dpaksocor.prssitcod,
      pstsrvtip      like dpckserv.pstsrvtip
   end record

   define ws         record
      dirfisnom      like ibpkdirlog.dirfisnom,
      pathrel01      char (60)                ,
      pathrel02      char (60)
   end record


#________________________[ Inicializacao das Variaveis ]___________________#

   initialize  d_bdbsr057.*  to null
   initialize  ws.*          to null


#____________________[ Define diretorios para relatorios e arquivos

 call f_path("DBS", "RELATO")                                       # Marcio  Meta - PSI185035
      returning ws.dirfisnom  
 
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if          
 
 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS05701"
 let ws.pathrel02 = ws.dirfisnom clipped, "/RDBS05702"
                                                                    # Marcio  Meta - PSI185035
                                                                    
#____________________[ Define numero de vias e account dos relatorios

 call fgerc010("RDBS05701")                                         # Marcio  Meta - PSI185035
      returning  ws_cctcod01,
		 ws_relviaqtd01

 call fgerc010("RDBS05702")                                         # Marcio  Meta - PSI185035
      returning  ws_cctcod02,                                       
		 ws_relviaqtd02


#____________________[ Definicao do cursor PRESTADORES ]___________________#

   declare c_bdbsr057 cursor for
      select dpaksocor.pstcoddig, dpaksocor.nomrazsoc, dpaksocor.pptnom   ,
             dpaksocor.endlgd   , dpaksocor.endbrr   , dpaksocor.endcid   ,
             dpaksocor.endufd   , dpaksocor.endcep   , dpaksocor.endcepcmp,
             dpaksocor.prssitcod, dpatserv.pstsrvtip
        from dpaksocor, dpatserv
       where dpaksocor.pstcoddig > 0  and
              dpatserv.pstcoddig = dpaksocor.pstcoddig

   start report  rep_etiq  to ws.pathrel01
   start report  rep_total to ws.pathrel02

   foreach c_bdbsr057 into d_bdbsr057.pstcoddig,
                           d_bdbsr057.nomrazsoc,
                           d_bdbsr057.pptnom   ,
                           d_bdbsr057.endlgd   ,
                           d_bdbsr057.endbrr   ,
                           d_bdbsr057.endcid   ,
                           d_bdbsr057.endufd   ,
                           d_bdbsr057.endcep   ,
                           d_bdbsr057.endcepcmp,
                           d_bdbsr057.prssitcod,
                           d_bdbsr057.pstsrvtip

#__________________[ Descarta prestadores CANCELADOS ]____________________#

      if d_bdbsr057.prssitcod <> "A"  then
         continue foreach
      end if

#_______[ Descarta prestadores que prestam outros tipos de servicos ]______#

      if d_bdbsr057.pstsrvtip <> 1  and     ## Servico: (1) Mecanica
         d_bdbsr057.pstsrvtip <> 2  and     ##          (2) Eletrico
         d_bdbsr057.pstsrvtip <> 3  and     ##          (3) Guinchos Leves
         d_bdbsr057.pstsrvtip <> 7  then    ##          (7) Guinchos Pesados
         continue foreach
      end if

#________[ Descarta prestadores que nao tenham endereco cadastrado ]_______#

      if d_bdbsr057.endlgd    is null  and  ## Endereco: Rua
         d_bdbsr057.endbrr    is null  and  ##           Bairro
         d_bdbsr057.endcid    is null  then ##           Cidade
         continue foreach
      end if

      output to report rep_etiq (d_bdbsr057.*)
      output to report rep_total(d_bdbsr057.*)

   end foreach

   finish report rep_etiq
   finish report rep_total

end function   ###  bdbsr057

#---------------------------------------------------------------------------
 report rep_etiq(r_bdbsr057)
#---------------------------------------------------------------------------

   define r_bdbsr057 record
      pstcoddig      like dpaksocor.pstcoddig,
      nomrazsoc      like dpaksocor.nomrazsoc,
      pptnom         like dpaksocor.pptnom   ,
      endlgd         like dpaksocor.endlgd   ,
      endbrr         like dpaksocor.endbrr   ,
      endcid         like dpaksocor.endcid   ,
      endufd         like dpaksocor.endufd   ,
      endcep         like dpaksocor.endcep   ,
      endcepcmp      like dpaksocor.endcepcmp,
      prssitcod      like dpaksocor.prssitcod,
      pstsrvtip      like dpckserv.pstsrvtip
   end record

   output
      left   margin  00
      right  margin  00
      top    margin  00
      bottom margin  00
      page   length  13

   order by  r_bdbsr057.endufd,
             r_bdbsr057.endcid,
             r_bdbsr057.endcep,
             r_bdbsr057.pstcoddig

   format
      first page header
          print "OUTPUT JOBNAME=DBS05701 FORMNAME=ETIQUETA"       # Marcio  Meta - PSI185035
          print "HEADER PAGE"
          print "       JOBNAME=MALA DIRETA PORTO SOCORRO (CT24HS)"
          print "$DJDE$ JDL=XJ7900, JDE=XD7900, COPIES=",ws_relviaqtd01 using "&&", ", DEPT='", ws_cctcod01 using "&&&", "', END;"
          print ascii(12)

      page header
          print "$DJDE$ C LIXOLIXO, ;"
          print "$DJDE$ C LIXOLIXO, ;"
          print "$DJDE$ C LIXOLIXO, ;"
          print "$DJDE$ C LIXOLIXO, END ;"
          print ascii(12)

      after group of r_bdbsr057.pstcoddig
          print column 003, r_bdbsr057.pstcoddig using "&&&&&&",
                     " - ", r_bdbsr057.nomrazsoc
          print column 003, r_bdbsr057.pptnom
          print column 003, r_bdbsr057.endlgd
          print column 003, r_bdbsr057.endbrr
          print column 003, r_bdbsr057.endcid clipped,
                     " - ", r_bdbsr057.endufd
          print column 003, "CEP: ", r_bdbsr057.endcep;
          if r_bdbsr057.endcepcmp  is not null   and
             r_bdbsr057.endcepcmp  <> "   "      then
             print "-", r_bdbsr057.endcepcmp;
          end if
          print " "
          skip to top of page

      on last  row
          print "$FIMREL$"

end report ## rep_etiq

#---------------------------------------------------------------------------
 report rep_total(r_bdbsr057)
#---------------------------------------------------------------------------

   define r_bdbsr057 record
      pstcoddig      like dpaksocor.pstcoddig,
      nomrazsoc      like dpaksocor.nomrazsoc,
      pptnom         like dpaksocor.pptnom   ,
      endlgd         like dpaksocor.endlgd   ,
      endbrr         like dpaksocor.endbrr   ,
      endcid         like dpaksocor.endcid   ,
      endufd         like dpaksocor.endufd   ,
      endcep         like dpaksocor.endcep   ,
      endcepcmp      like dpaksocor.endcepcmp,
      prssitcod      like dpaksocor.prssitcod,
      pstsrvtip      like dpckserv.pstsrvtip
   end record

   define a_serv     array[04] of record
      etq_srv        dec(05,0)
   end record

   define a_uf       array[30] of record
      ufdcod         like glakest.ufdcod,
      etq_uf         dec(05,0)
   end record

   define aux_pstsrvdes like dpckserv.pstsrvdes
   define aux_ufdnom    char (035)

   define cont_etiq  dec(05,0)
   define arr_ufd    smallint
   define arr_srv    smallint

   output
      left   margin  00
      right  margin  80
      top    margin  00
      bottom margin  00
      page   length  90

   order by  r_bdbsr057.endufd   ,
             r_bdbsr057.pstcoddig

   format
     page header
         if pageno = 1   then
            print "OUTPUT JOBNAME=DBS05702 FORMNAME=BRANCO"      # Marcio  Meta - PSI185035
            print "HEADER PAGE"
            print "JOBNAME=TOTALIZACAO - MALA DIRETA - CT24HS (PORTO SOCORRO)"
            print "$DJDE$ JDL=XJ0030, JDE=XD0031, FORMS=XF6560, COPIES=",ws_relviaqtd02 using "&&", ", DEPT='", ws_cctcod02 using "&&&", "', END;"
            print ascii(12)
         else
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, ;"
            print "$DJDE$ C LIXOLIXO, END ;"
            print ascii(12)
         end if
#________________________[ Inicializacao das Variaveis ]___________________#

         let cont_etiq = 0

         for arr_srv = 1 to 4 step 1
            let a_serv[arr_srv].etq_srv = 0
         end for

         let arr_ufd  = 1
         let arr_srv  = 1

         print column 047, "RDBS057-02",
               column 061, "PAGINA : ", pageno using "##,###,##&"
         print column 061, "DATA   : ", today
         print column 018, "TOTAL DE ETIQUETAS EMITIDAS" ,
               column 061, "HORA   :   ", time
         skip 2 lines

     before group of r_bdbsr057.endufd
         let a_uf[arr_ufd].etq_uf = 0

     after  group of r_bdbsr057.endufd
         let a_uf[arr_ufd].ufdcod = r_bdbsr057.endufd
         let arr_ufd = arr_ufd + 1

     after  group of r_bdbsr057.pstcoddig
         let cont_etiq = cont_etiq + 1

#_________________[ Totalizacao por UNIDADE DE FEDERACAO ]_________________#

         let a_uf[arr_ufd].etq_uf = a_uf[arr_ufd].etq_uf + 1

#____________________[ Totalizacao por TIPO DE SERVICO ]___________________#

         if r_bdbsr057.pstsrvtip = 7 then
            let a_serv[4].etq_srv = a_serv[4].etq_srv + 1
         else
            let arr_srv = r_bdbsr057.pstsrvtip
            let a_serv[arr_srv].etq_srv = a_serv[arr_srv].etq_srv + 1
         end if

     on last row
         print column 013, "UNIDADE DE FEDERACAO",
               column 055, "TOTAL"
         skip 1 line
         for arr_ufd = 1 to 30 step 1
            if a_uf[arr_ufd].ufdcod is null then
               exit for
            end if
            select ufdnom into aux_ufdnom
              from glakest
             where ufdcod = a_uf[arr_ufd].ufdcod

            print column 013, a_uf[arr_ufd].ufdcod, " - ", aux_ufdnom,
                  column 054, a_uf[arr_ufd].etq_uf using "##,##&"
         end for
         skip 3 lines

         print column 013, "SERVICO",
               column 055, "TOTAL"
         skip 1 line
         for arr_srv = 1 to 4 step 1
            if arr_srv = 4 then
               select pstsrvdes into aux_pstsrvdes
                 from dpckserv
                where pstsrvtip = 7
            else
               select pstsrvdes into aux_pstsrvdes
                 from dpckserv
                where pstsrvtip = arr_srv
            end if
            print column 013, aux_pstsrvdes,
                  column 054, a_serv[arr_srv].etq_srv using "##,##&"
         end for
         skip 3 lines

         print column 001, "--------------------------------------------------------------------------------"
         print column 013, "TOTAL DE ETIQUETAS EMITIDAS: ",
               column 054, cont_etiq using "##,##&"
         print column 001, "--------------------------------------------------------------------------------"
         print "$FIMREL$"

end report ## rep_total
