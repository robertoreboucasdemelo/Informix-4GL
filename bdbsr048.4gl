#############################################################################
# Nome do Modulo: bdbsr048                                           Pedro  #
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

define wstraco       char(80)
define ws_cctcod     like igbrrelcct.cctcod
define ws_relviaqtd  like igbrrelcct.relviaqtd
define ws_comando    char(400)

main
   call fun_dba_abre_banco("CT24HS") 
   call bdbsr048()
end main

#---------------------------------------------------------------
function  bdbsr048()
#---------------------------------------------------------------

   define  d_bdbsr048    record
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
   
   define l_retorno     smallint                                # Marcio Meta - PSI185035

#---------------------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------------------

 initialize d_bdbsr048.*  to null
 initialize ws.*          to null

 let wstraco = "--------------------------------------------------------------------------------"


#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "ARQUIVO")                                    # Marcio Meta - PSI185035
      returning ws.dirfisnom 
 
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if     
 
 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS04801"
                                                                  # Marcio Meta - PSI185035
#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDBS04801")
      returning  ws_cctcod,
		 ws_relviaqtd


   declare  c_bdbsr048  cursor for
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

   foreach c_bdbsr048 into d_bdbsr048.nomgrr,
                           d_bdbsr048.pstcoddig,
                           d_bdbsr048.endlgd   ,
                           d_bdbsr048.endbrr   ,
                           d_bdbsr048.endcid   ,
                           d_bdbsr048.endufd   ,
                           d_bdbsr048.endcep   ,
                           d_bdbsr048.endcepcmp,
                           d_bdbsr048.dddcod   ,
                           d_bdbsr048.teltxt   ,
                           d_bdbsr048.rspnom   ,
                           d_bdbsr048.horsegsexinc,
                           d_bdbsr048.horsegsexfnl,
                           d_bdbsr048.horsabinc,
                           d_bdbsr048.horsabfnl,
                           d_bdbsr048.hordominc,
                           d_bdbsr048.hordomfnl,
                           d_bdbsr048.srvnteflg,
                           d_bdbsr048.pstobs   ,
                           d_bdbsr048.prssitcod

      let d_bdbsr048.endzon = d_bdbsr048.endcep[1,2]
      case d_bdbsr048.endzon
           when  "01"
              let d_bdbsr048.endzon = "ZC"
           when  "02"
              let d_bdbsr048.endzon = "ZN"
           when  "03"
              let d_bdbsr048.endzon = "ZL"
           when  "04"
              let d_bdbsr048.endzon = "ZS"
           when  "05"
              let d_bdbsr048.endzon = "ZO"
           when  "08"
              let d_bdbsr048.endzon = "  "
              if d_bdbsr048.endcep  <  "08500"  then
                 let d_bdbsr048.endzon = "ZL"
              end if
           otherwise
              let d_bdbsr048.endzon = "  "
      end case

      output to report  rep_socorro (d_bdbsr048.*)

   end foreach

   finish report rep_socorro
                                                                     # Marcio Meta - PSI185035
   let ws_comando = ' SERVICOS FORA DE HORA COM PORTO SOCORRO '
 
   let l_retorno = ctx22g00_envia_email('BDBSR048',
                                        ws_comando,
                                        ws.pathrel01)
   if l_retorno <> 0 then
      if l_retorno <> 99 then
         display " Erro ao enviar email(ctx22g00)-", ws.pathrel01
      else
         display " Email nao encontrado para este modulo BDBSR048 "
      end if
   end if                                                            # Marcio Meta - PSI185035
  
  # let ws_comando = "mailx -r 'ct24hs.email@portoseguro.com.br'",
  #                  " -s 'SERVICOS FORA DE HORA COM PORTO SOCORRO '",
  #                  " 'inhasz_sofia/spaulo_ct24hs_teleatendimento@u55'",
  #                  " < ",ws.pathrel01
  # run ws_comando
  # initialize ws_comando to null
  # let ws_comando = "mailx -r 'ct24hs.email@portoseguro.com.br'",
  #                  " -s 'SERVICOS FORA DE HORA COM PORTO SOCORRO '",
  #                  " 'carlos.ruiz@portoseguro.com.br'",                    
  #                  " < ",ws.pathrel01
  # run ws_comando
  #
  #let ws_comando = "uuencode ", ws.pathrel01  clipped, " ",
  #                              ws.pathrel01  clipped, ".xls | remsh U07 ",
  #               "mailx -r 'ct24hs.email@portoseguro.com.br'",
  #               " -s 'SERVICOS FORA DE HORA COM PORTO SOCORRO' ",
  #               "inhasz_sofia/spaulo_ct24hs_teleatendimento@u55"
  #              #"Ct24hs_Relatorios/spaulo_ct24hs_teleatendimento@u55"
  #run ws_comando
  #let ws_comando = "uuencode ", ws.pathrel01  clipped, " ",
  #                              ws.pathrel01  clipped, ".xls | remsh U07 ",
  #               "mailx -r 'ct24hs.email@portoseguro.com.br'",
  #               " -s 'SERVICOS FORA DE HORA COM PORTO SOCORRO' ",
  #               "carlos.ruiz@portoseguro.com.br"                 
  #              #"Ct24hs_Relatorios/spaulo_ct24hs_teleatendimento@u55"
  #run ws_comando

end function   ###  bdbsr048

#---------------------------------------------------------------------------
report rep_socorro(r_bdbsr048)
#---------------------------------------------------------------------------

   define  r_bdbsr048    record
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

   order by  r_bdbsr048.endufd,
             r_bdbsr048.endcid,
             r_bdbsr048.endzon,
             r_bdbsr048.nomgrr

   format
      page header
           if pageno = 1   then
              print "OUTPUT JOBNAME=DBS04801 FORMNAME=BRANCO"      # Marcio Meta - PSI185035
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

           print column 047, "RDBS048-01",
                 column 061, "PAGINA : ", pageno using "##,###,##&"
           print column 061, "DATA   : ", today
           print column 015, "SERVICOS FORA DE HORA COM PORTO SOCORRO",
                 column 061, "HORA   :   ", time

           skip 2 lines

      before group of r_bdbsr048.endufd
           skip 1 lines
           print column 001, wstraco
           print column 001, "UF: ", r_bdbsr048.endufd,
                 column 013, "CIDADE: ", r_bdbsr048.endcid;
           if r_bdbsr048.endzon is not null  and
              r_bdbsr048.endzon <> "  "      then
              print column 071, "ZONA: ", r_bdbsr048.endzon
           else
              print " "
           end if
           print column 001, wstraco
           let wsquebra = "s"

      before group of r_bdbsr048.endcid
           if wsquebra  =  "n"   then
              let wsquebra = "s"
              print column 001, wstraco
              print column 001, "UF: ", r_bdbsr048.endufd,
                    column 013, "CIDADE: ", r_bdbsr048.endcid;
              if r_bdbsr048.endzon is not null  and
                 r_bdbsr048.endzon <> "  "      then
                 print column 071, "ZONA: ", r_bdbsr048.endzon
              else
                 print " "
              end if
              print column 001, wstraco
           end if

      before group of r_bdbsr048.endzon
           if wsquebra  =  "n"   then
              print column 001, wstraco
              print column 001, "UF: ", r_bdbsr048.endufd,
                    column 013, "CIDADE: ", r_bdbsr048.endcid;
              if r_bdbsr048.endzon is not null  and
                 r_bdbsr048.endzon <> "  "      then
                 print column 071, "ZONA: ", r_bdbsr048.endzon
              else
                 print " "
              end if
              print column 001, wstraco
           end if

      on every row
           let wsquebra = "n"
           initialize  wsserv     to null
           initialize  wsservemp  to null

           declare  c_bdbsr048srv   cursor for
              select pstsrvdes
                 from  dpatserv, dpckserv
                 where dpatserv.pstcoddig  = r_bdbsr048.pstcoddig    and
                       dpckserv.pstsrvtip  = dpatserv.pstsrvtip

           foreach  c_bdbsr048srv   into  wsserv
              let wsservemp = wsservemp  clipped, wsserv  clipped,  ", "
           end foreach

           initialize wsstatus   to null
           case r_bdbsr048.prssitcod
              when "A"  let wsstatus = "ATIVO"
              when "C"  let wsstatus = "CANCELADO"
              when "P"  let wsstatus = "PROPOSTA"
              when "B"  let wsstatus = "BLOQUEADO"
              otherwise let wsstatus = "NAO PREV."
           end case

           need 10 lines
           print column 005, "NOME  : ",
                 column 013, r_bdbsr048.nomgrr,
                 column 054, "CODIGO: ",
                 column 060, r_bdbsr048.pstcoddig  using "&&&&&&",
                 column 070, wsstatus
           print column 005, "END.  : ",
                 column 013, r_bdbsr048.endlgd
           print column 005, "BAIRRO: ",
                 column 013, r_bdbsr048.endbrr
           print column 005, "FONE  : ",
                 column 013, "(",
                 column 014, r_bdbsr048.dddcod,
                 column 018, ")",
                 column 019, r_bdbsr048.teltxt
           print column 005, "CEP   : ",
                 column 013, r_bdbsr048.endcep;
                 if r_bdbsr048.endcepcmp  is not null   and
                    r_bdbsr048.endcepcmp  <> "   "      then
                    print column 018, "-", r_bdbsr048.endcepcmp;
                 end if
           print column 030, "   "

           if r_bdbsr048.srvnteflg  <>  "S"   then
              print column 005, "HORA  : ",
                    column 013, r_bdbsr048.horsegsexinc, " AS ",
                                r_bdbsr048.horsegsexfnl, "; SAB. ",
                                r_bdbsr048.horsabinc, " AS ",
                                r_bdbsr048.horsabfnl, "; DOM. ",
                                r_bdbsr048.hordominc, " AS ",
                                r_bdbsr048.hordomfnl
           else
              let wsatd24hs = "** 24 HORAS **"
              print column 005, "HORA  : ",
                    column 013, wsatd24hs
           end if

           print column 005, "SERV. : ",
                 column 013, wsservemp
           print column 005, "RESP. : ",
                 column 013, r_bdbsr048.rspnom
           print column 005, "OBS.  : ",
                 column 013, r_bdbsr048.pstobs
           skip 1 line

      on last row
           print "$FIMREL$"

end report
