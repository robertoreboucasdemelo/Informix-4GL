############################################################################
# Nome do Modulo: BDATR039                                           Pedro #
#                                                                  Marcelo #
# Relacao de Distritos Policiais                                  Fev/1995 #
############################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 Helio (Meta)       Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################

database porto

define wstraco       char(80)
define ws_cctcod     like igbrrelcct.cctcod
define ws_relviaqtd  like igbrrelcct.relviaqtd

main
   call fun_dba_abre_banco("CT24HS") 
   call bdatr039()
end main

#---------------------------------------------------------------
function  bdatr039()
#---------------------------------------------------------------

   define  d_bdatr039    record
      battip         like   dpakbat.battip,
      batnum         like   dpakbat.batnum,
      batnom         like   dpakbat.batnom,
      endlgd         like   dpakbat.endlgd,
      endbrr         like   dpakbat.endbrr,
      endcid         like   dpakbat.endcid,
      endufd         like   dpakbat.endufd,
      endcep         like   dpakbat.endcep,
      endcepcmp      like   dpakbat.endcepcmp,
      dddcod         like   dpakbat.dddcod,
      teltxt         like   dpakbat.teltxt,
      endzon         char(02)
   end record

   define ws            record
      dirfisnom         like ibpkdirlog.dirfisnom ,
      pathrel01         char (60)
   end record


#---------------------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------------------

   initialize d_bdatr039.*  to null
   initialize ws.*          to null

   let wstraco = "-------------------------------------------------------------------------------"


#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT03901"


#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDAT03901")
      returning  ws_cctcod,
		 ws_relviaqtd



   declare  c_bdatr039  cursor for
      select
         battip, batnum, batnom, endlgd, endbrr,
         endcid, endufd, endcep, endcepcmp,
         dddcod, teltxt
      from
         dpakbat
      where
         battip = "D"

   start report  rep_distrito  to ws.pathrel01

   foreach  c_bdatr039  into  d_bdatr039.battip   ,
                              d_bdatr039.batnum   ,
                              d_bdatr039.batnom   ,
                              d_bdatr039.endlgd   ,
                              d_bdatr039.endbrr   ,
                              d_bdatr039.endcid   ,
                              d_bdatr039.endufd   ,
                              d_bdatr039.endcep   ,
                              d_bdatr039.endcepcmp,
                              d_bdatr039.dddcod   ,
                              d_bdatr039.teltxt

      let d_bdatr039.endzon = d_bdatr039.endcep[1,2]
      case d_bdatr039.endzon
           when  "01"
              let d_bdatr039.endzon = "ZC"
           when  "02"
              let d_bdatr039.endzon = "ZN"
           when  "03"
              let d_bdatr039.endzon = "ZL"
           when  "04"
              let d_bdatr039.endzon = "ZS"
           when  "05"
              let d_bdatr039.endzon = "ZO"
           when  "08"
              let d_bdatr039.endzon = "  "
              if d_bdatr039.endcep  <  "08500"  then
                 let d_bdatr039.endzon = "ZL"
              end if
           otherwise
              let d_bdatr039.endzon = "  "
      end case

      output to report  rep_distrito (d_bdatr039.*)

   end foreach

   finish report rep_distrito

   close c_bdatr039

end function   ###  bdatr039

#---------------------------------------------------------------------------
report rep_distrito(r_bdatr039)
#---------------------------------------------------------------------------

   define  r_bdatr039    record
      battip         like   dpakbat.battip,
      batnum         like   dpakbat.batnum,
      batnom         like   dpakbat.batnom,
      endlgd         like   dpakbat.endlgd,
      endbrr         like   dpakbat.endbrr,
      endcid         like   dpakbat.endcid,
      endufd         like   dpakbat.endufd,
      endcep         like   dpakbat.endcep,
      endcepcmp      like   dpakbat.endcepcmp,
      dddcod         like   dpakbat.dddcod,
      teltxt         like   dpakbat.teltxt,
      endzon         char(02)
   end record

   define  wsquebra  char(01)


   output
      left   margin  00
      right  margin  132
      top    margin  00
      bottom margin  00
      page   length  90

   order by  r_bdatr039.endufd,
             r_bdatr039.endcid,
             r_bdatr039.endzon,
             r_bdatr039.batnom

   format
      page header
           if pageno = 1  then
              print "OUTPUT JOBNAME=DAT03901 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - DISTRITOS POLICIAIS"
              print "$DJDE$ JDL=XJ0030, JDE=XD0030, FORMS=XF6560, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
              print ascii(12)
           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if

           print column 047, "RDAT039-01",
                 column 061, "PAGINA : ", pageno using "##,###,###"
           print column 061, "DATA   : ", today
           print column 026, "DISTRITOS POLICIAIS",
                 column 061, "HORA   :   ", time
           skip 2 lines
           let wsquebra  = "n"

      before group of r_bdatr039.endufd
           skip 1 line
           print column 001, wstraco
           print column 001, "UF : ",
                 column 006, r_bdatr039.endufd,
                 column 013, "CIDADE : ",
                 column 022, r_bdatr039.endcid,
                 column 050, "ZONA : ",
                 column 056, r_bdatr039.endzon
           print column 001, wstraco
           let wsquebra = "s"

      before group of r_bdatr039.endcid
           if wsquebra  =  "n"   then
              let wsquebra = "s"
              print column 001, wstraco
              print column 001, "UF : ",
                    column 006, r_bdatr039.endufd,
                    column 013, "CIDADE : ",
                    column 022, r_bdatr039.endcid,
                    column 050, "ZONA : ",
                    column 056, r_bdatr039.endzon
              print column 001, wstraco
           end if

      before group of r_bdatr039.endzon
           if wsquebra  =  "n"   then
              print column 001, wstraco
              print column 001, "UF : ",
                    column 006, r_bdatr039.endufd,
                    column 013, "CIDADE : ",
                    column 022, r_bdatr039.endcid,
                    column 050, "ZONA : ",
                    column 056, r_bdatr039.endzon
              print column 001, wstraco
           end if

      on every row
           need 7 lines
           let wsquebra = "n"
           if lineno  >  78   then
              skip to top of page
           end if
           print column 005, "IDENT.: ",
                 column 013, r_bdatr039.batnom,
                 column 054, "CODIGO: ",
                 column 060, r_bdatr039.batnum  using "####"
           print column 005, "END.  : ",
                 column 013, r_bdatr039.endlgd
           print column 005, "BAIRRO: ",
                 column 013, r_bdatr039.endbrr
           print column 005, "FONE  : ",
                 column 013, "(",
                 column 014, r_bdatr039.dddcod,
                 column 018, ")",
                 column 019, r_bdatr039.teltxt
           print column 005, "CEP   : ",
                 column 013, r_bdatr039.endcep;

           if r_bdatr039.endcepcmp  is not null   and
              r_bdatr039.endcepcmp  <> "   "      then
              print column 018, "-", r_bdatr039.endcepcmp;
           end if
           print column 030, "  "
           skip 1 line

      on last  row
           print "$FIMREL$"

end report
