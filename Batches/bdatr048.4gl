#############################################################################
# Nome do Modulo: BDATR048                                           Pedro  #
#                                                                   Marcelo #
# Relacao de Prestadores  (Porto Socorro)                         Fev/1995  #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 04/06/2001  PSI 13253-5  Wagner       Inclusao nova situacao prestador    #
#                                       B-Bloqueado.                        #
#############################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 Helio (Meta)       Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################

database porto

globals
   define g_ismqconn smallint
end globals
define wstraco       char(80)
define ws_cctcod     like igbrrelcct.cctcod
define ws_relviaqtd  like igbrrelcct.relviaqtd
define ws_comando    char(400)

main
   call fun_dba_abre_banco("CT24HS")
   set isolation to dirty read
   set lock mode to wait 10
   call bdatr048()
end main

#---------------------------------------------------------------
function  bdatr048()
#---------------------------------------------------------------

   define  d_bdatr048    record
      pstcoddig      like   dpaksocor.pstcoddig,
      nomgrr         like   dpaksocor.nomgrr,
      endlgd         like   dpaksocor.endlgd,
      endbrr         like   dpaksocor.endbrr,
      endcid         like   dpaksocor.endcid,
      endufd         like   dpaksocor.endufd,
      endcep         like   dpaksocor.endcep,
      endcepcmp      like   dpaksocor.endcepcmp,
      dddcod         like   dpaksocor.dddcod,
      teltxt         like   dpaksocor.teltxt,
      rspnom         like   dpaksocor.rspnom,
      horsegsexinc   like   dpaksocor.horsegsexinc,
      horsegsexfnl   like   dpaksocor.horsegsexfnl,
      horsabinc      like   dpaksocor.horsabinc,
      horsabfnl      like   dpaksocor.horsabfnl,
      hordominc      like   dpaksocor.hordominc,
      hordomfnl      like   dpaksocor.hordomfnl,
      srvnteflg      like   dpaksocor.srvnteflg,
      pstobs         like   dpaksocor.pstobs   ,
      prssitcod      like   dpaksocor.prssitcod,
      endzon         char(02)
   end record

   define ws         record
      dirfisnom      like ibpkdirlog.dirfisnom ,
      pathrel01      char (60)
   end record

   define l_assunto     char(100),
          l_erro_envio  smallint

#---------------------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------------------

 initialize d_bdatr048.*  to null
 initialize ws.*          to null

 let wstraco = "--------------------------------------------------------------------------------"


#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT04801.rtf"

#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDAT04801")
      returning  ws_cctcod,
                 ws_relviaqtd


   declare  c_bdatr048  cursor for
      select   nomgrr   ,    pstcoddig,    endlgd,
               endbrr   ,    endcid,       endufd,
               endcep   ,    endcepcmp,    dddcod,
               teltxt   ,    rspnom   ,    horsegsexinc,
               horsegsexfnl, horsabinc,    horsabfnl,
               hordominc,    hordomfnl,    srvnteflg,
               pstobs   ,    prssitcod
         from  dpaksocor
         where dpaksocor.pstcoddig  >  0

   start report  rep_socorro  to ws.pathrel01

   foreach c_bdatr048 into d_bdatr048.nomgrr,
                           d_bdatr048.pstcoddig,
                           d_bdatr048.endlgd   ,
                           d_bdatr048.endbrr   ,
                           d_bdatr048.endcid   ,
                           d_bdatr048.endufd   ,
                           d_bdatr048.endcep   ,
                           d_bdatr048.endcepcmp,
                           d_bdatr048.dddcod   ,
                           d_bdatr048.teltxt   ,
                           d_bdatr048.rspnom   ,
                           d_bdatr048.horsegsexinc,
                           d_bdatr048.horsegsexfnl,
                           d_bdatr048.horsabinc,
                           d_bdatr048.horsabfnl,
                           d_bdatr048.hordominc,
                           d_bdatr048.hordomfnl,
                           d_bdatr048.srvnteflg,
                           d_bdatr048.pstobs   ,
                           d_bdatr048.prssitcod

      let d_bdatr048.endzon = d_bdatr048.endcep[1,2]
      case d_bdatr048.endzon
           when  "01"
              let d_bdatr048.endzon = "ZC"
           when  "02"
              let d_bdatr048.endzon = "ZN"
           when  "03"
              let d_bdatr048.endzon = "ZL"
           when  "04"
              let d_bdatr048.endzon = "ZS"
           when  "05"
              let d_bdatr048.endzon = "ZO"
           when  "08"
              let d_bdatr048.endzon = "  "
              if d_bdatr048.endcep  <  "08500"  then
                 let d_bdatr048.endzon = "ZL"
              end if
           otherwise
              let d_bdatr048.endzon = "  "
      end case

      output to report  rep_socorro (d_bdatr048.*)

   end foreach

   finish report rep_socorro

   let l_assunto    = null
   let l_erro_envio = null

   let l_assunto    = "SERVICOS FORA DE HORA COM PORTO SOCORRO"
   let l_erro_envio = ctx22g00_envia_email("BDATR048",
                                           l_assunto,
                                           ws.pathrel01)
   if l_erro_envio <> 0 then
      if l_erro_envio <> 99 then
         display "Erro ao enviar email(ctx22g00) - ", ws.pathrel01
      else
         display "Nao existe email cadastrado para o modulo - BDATR048"
      end if
   end if

end function   ###  bdatr048

#---------------------------------------------------------------------------
report rep_socorro(r_bdatr048)
#---------------------------------------------------------------------------

   define  r_bdatr048    record
      pstcoddig      like   dpaksocor.pstcoddig,
      nomgrr         like   dpaksocor.nomgrr,
      endlgd         like   dpaksocor.endlgd,
      endbrr         like   dpaksocor.endbrr,
      endcid         like   dpaksocor.endcid,
      endufd         like   dpaksocor.endufd,
      endcep         like   dpaksocor.endcep,
      endcepcmp      like   dpaksocor.endcepcmp,
      dddcod         like   dpaksocor.dddcod,
      teltxt         like   dpaksocor.teltxt,
      rspnom         like   dpaksocor.rspnom,
      horsegsexinc   like   dpaksocor.horsegsexinc,
      horsegsexfnl   like   dpaksocor.horsegsexfnl,
      horsabinc      like   dpaksocor.horsabinc,
      horsabfnl      like   dpaksocor.horsabfnl,
      hordominc      like   dpaksocor.hordominc,
      hordomfnl      like   dpaksocor.hordomfnl,
      srvnteflg      like   dpaksocor.srvnteflg,
      pstobs         like   dpaksocor.pstobs   ,
      prssitcod      like   dpaksocor.prssitcod,
      endzon         char(02)
   end record

   define  wsquebra  char(01)
   define  wsstatus  char(09)
   define  wsatd24hs char(14)
   define  wsserv    like dpckserv.pstsrvdes
   define  wsservemp char(65)


   output
      left   margin  000
      right  margin  080
      top    margin  000
      bottom margin  000
      page   length  090

   order by  r_bdatr048.endufd,
             r_bdatr048.endcid,
             r_bdatr048.endzon,
             r_bdatr048.nomgrr

   format
      page header
           if pageno = 1   then
              print "OUTPUT JOBNAME=DAT04801 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - PORTO SOCORRO"
              print "$DJDE$ JDL=XJ0030, JDE=XD0030, FORMS=XF6560, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
              print ascii(12)
           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if

           print column 047, "RDAT048-01",
                 column 061, "PAGINA : ", pageno using "##,###,##&"
           print column 061, "DATA   : ", today
           print column 015, "SERVICOS FORA DE HORA COM PORTO SOCORRO",
                 column 061, "HORA   :   ", time

           skip 2 lines

      before group of r_bdatr048.endufd
           skip 1 lines
           print column 001, wstraco
           print column 001, "UF: ", r_bdatr048.endufd,
                 column 013, "CIDADE: ", r_bdatr048.endcid;
           if r_bdatr048.endzon is not null  and
              r_bdatr048.endzon <> "  "      then
              print column 071, "ZONA: ", r_bdatr048.endzon
           else
              print " "
           end if
           print column 001, wstraco
           let wsquebra = "s"

      before group of r_bdatr048.endcid
           if wsquebra  =  "n"   then
              let wsquebra = "s"
              print column 001, wstraco
              print column 001, "UF: ", r_bdatr048.endufd,
                    column 013, "CIDADE: ", r_bdatr048.endcid;
              if r_bdatr048.endzon is not null  and
                 r_bdatr048.endzon <> "  "      then
                 print column 071, "ZONA: ", r_bdatr048.endzon
              else
                 print " "
              end if
              print column 001, wstraco
           end if

      before group of r_bdatr048.endzon
           if wsquebra  =  "n"   then
              print column 001, wstraco
              print column 001, "UF: ", r_bdatr048.endufd,
                    column 013, "CIDADE: ", r_bdatr048.endcid;
              if r_bdatr048.endzon is not null  and
                 r_bdatr048.endzon <> "  "      then
                 print column 071, "ZONA: ", r_bdatr048.endzon
              else
                 print " "
              end if
              print column 001, wstraco
           end if

      on every row
           let wsquebra = "n"
           initialize  wsserv     to null
           initialize  wsservemp  to null

           declare  c_bdatr048srv   cursor for
              select pstsrvdes
                 from  dpatserv, dpckserv
                 where dpatserv.pstcoddig  = r_bdatr048.pstcoddig    and
                       dpckserv.pstsrvtip  = dpatserv.pstsrvtip

           foreach  c_bdatr048srv   into  wsserv
              let wsservemp = wsservemp  clipped, wsserv  clipped,  ", "
           end foreach

           initialize wsstatus   to null
           case r_bdatr048.prssitcod
              when "A"  let wsstatus = "ATIVO"
              when "C"  let wsstatus = "CANCELADO"
              when "P"  let wsstatus = "PROPOSTA"
              when "B"  let wsstatus = "BLOQUEADO"
              otherwise let wsstatus = "NAO PREV."
           end case

           need 10 lines
           print column 005, "NOME  : ",
                 column 013, r_bdatr048.nomgrr,
                 column 054, "CODIGO: ",
                 column 060, r_bdatr048.pstcoddig  using "&&&&&&",
                 column 070, wsstatus
           print column 005, "END.  : ",
                 column 013, r_bdatr048.endlgd
           print column 005, "BAIRRO: ",
                 column 013, r_bdatr048.endbrr
           print column 005, "FONE  : ",
                 column 013, "(",
                 column 014, r_bdatr048.dddcod,
                 column 018, ")",
                 column 019, r_bdatr048.teltxt
           print column 005, "CEP   : ",
                 column 013, r_bdatr048.endcep;
                 if r_bdatr048.endcepcmp  is not null   and
                    r_bdatr048.endcepcmp  <> "   "      then
                    print column 018, "-", r_bdatr048.endcepcmp;
                 end if
           print column 030, "   "

           if r_bdatr048.srvnteflg  <>  "S"   then
              print column 005, "HORA  : ",
                    column 013, r_bdatr048.horsegsexinc, " AS ",
                                r_bdatr048.horsegsexfnl, "; SAB. ",
                                r_bdatr048.horsabinc, " AS ",
                                r_bdatr048.horsabfnl, "; DOM. ",
                                r_bdatr048.hordominc, " AS ",
                                r_bdatr048.hordomfnl
           else
              let wsatd24hs = "** 24 HORAS **"
              print column 005, "HORA  : ",
                    column 013, wsatd24hs
           end if

           print column 005, "SERV. : ",
                 column 013, wsservemp
           print column 005, "RESP. : ",
                 column 013, r_bdatr048.rspnom
           print column 005, "OBS.  : ",
                 column 013, r_bdatr048.pstobs
           skip 1 line

      on last row
           print "$FIMREL$"

end report
