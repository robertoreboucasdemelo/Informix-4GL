#############################################################################
# Nome do Modulo: bdbsr053                                          Marcelo #
#                                                                  Gilberto #
# Relacao de Lojas de Locacao de Veiculos                          Fev/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 06/10/1998  PSI 7056-4   Gilberto     Alterar situacao da loja de (A)tiva #
#                                       ou (C)ancelada para codificacao nu- #
#                                       merica: (1)Ativa;     (2)Bloqueada; #
#                                               (3)Cancelada; (4)Desativada #
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

define ws_cctcod     like igbrrelcct.cctcod
define ws_relviaqtd  like igbrrelcct.relviaqtd

main
   call fun_dba_abre_banco("CT24HS") 
   call bdbsr053()
end main

#---------------------------------------------------------------
 function bdbsr053()
#---------------------------------------------------------------

 define d_bdbsr053    record
    lcvcod            like datkavislocal.lcvcod       ,
    lcvextcod         like datkavislocal.lcvextcod    ,
    aviestnom         like datkavislocal.aviestnom    ,
    endlgd            like datkavislocal.endlgd       ,
    endbrr            like datkavislocal.endbrr       ,
    endcid            like datkavislocal.endcid       ,
    endufd            like datkavislocal.endufd       ,
    endcep            like datkavislocal.endcep       ,
    endcepcmp         like datkavislocal.endcepcmp    ,
    dddcod            like datkavislocal.dddcod       ,
    teltxt            like datkavislocal.teltxt       ,
    facnum            like datkavislocal.facnum       ,
    horsegsexinc      like datkavislocal.horsegsexinc ,
    horsegsexfnl      like datkavislocal.horsegsexfnl ,
    horsabinc         like datkavislocal.horsabinc    ,
    horsabfnl         like datkavislocal.horsabfnl    ,
    hordominc         like datkavislocal.hordominc    ,
    hordomfnl         like datkavislocal.hordomfnl    ,
    lcvlojtip         like datkavislocal.lcvlojtip    ,
    obs               like datkavislocal.obs
 end record

 define ws            record
    sql               char (500)                      ,
    lcvstt            like datklocadora.lcvstt        ,
    vclalglojstt      like datkavislocal.vclalglojstt ,
    dirfisnom         like ibpkdirlog.dirfisnom       ,
    pathrel01         char (60)
 end record

 initialize d_bdbsr053.*  to null
 initialize ws.*          to null


#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "RELATO")                                     # Marcio  Meta - PSI185035
      returning ws.dirfisnom                      
 
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if          
 
 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS05301"
                                                                  
#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDBS05301")                                       # Marcio  Meta - PSI185035
      returning  ws_cctcod,
		 ws_relviaqtd


 let ws.sql = "select lcvextcod   , ",
              "       aviestnom   , ",
              "       endlgd      , ",
              "       endbrr      , ",
              "       endcid      , ",
              "       endufd      , ",
              "       endcep      , ",
              "       endcepcmp   , ",
              "       dddcod      , ",
              "       teltxt      , ",
              "       facnum      , ",
              "       horsegsexinc, ",
              "       horsegsexfnl, ",
              "       horsabinc   , ",
              "       horsabfnl   , ",
              "       hordominc   , ",
              "       hordomfnl   , ",
              "       lcvlojtip   , ",
              "       vclalglojstt, ",
              "       obs           ",
              "  from datkavislocal ",
              " where lcvcod = ?    "
   prepare sel_avislocal from ws.sql
   declare c_avislocal cursor for sel_avislocal

   declare  c_bdbsr053  cursor for
      select lcvcod, lcvstt
        from datklocadora

   start report  rep_avislocal to ws.pathrel01

   foreach  c_bdbsr053  into  d_bdbsr053.lcvcod,
                              ws.lcvstt

      if ws.lcvstt <> "A"  then
         continue foreach
      end if

      open     c_avislocal using d_bdbsr053.lcvcod
      foreach  c_avislocal into  d_bdbsr053.lcvextcod   ,
                                 d_bdbsr053.aviestnom   ,
                                 d_bdbsr053.endlgd      ,
                                 d_bdbsr053.endbrr      ,
                                 d_bdbsr053.endcid      ,
                                 d_bdbsr053.endufd      ,
                                 d_bdbsr053.endcep      ,
                                 d_bdbsr053.endcepcmp   ,
                                 d_bdbsr053.dddcod      ,
                                 d_bdbsr053.teltxt      ,
                                 d_bdbsr053.facnum      ,
                                 d_bdbsr053.horsegsexinc,
                                 d_bdbsr053.horsegsexfnl,
                                 d_bdbsr053.horsabinc   ,
                                 d_bdbsr053.horsabfnl   ,
                                 d_bdbsr053.hordominc   ,
                                 d_bdbsr053.hordomfnl   ,
                                 d_bdbsr053.lcvlojtip   ,
                                 ws.vclalglojstt        ,
                                 d_bdbsr053.obs

         if ws.vclalglojstt <> 1  and
            ws.vclalglojstt <> 2  then
            continue foreach
         end if

         output to report  rep_avislocal (d_bdbsr053.*)

      end foreach
   end foreach

   finish report rep_avislocal

end function  ###  bdbsr053

#---------------------------------------------------------------------------
 report rep_avislocal(r_bdbsr053)
#---------------------------------------------------------------------------

 define r_bdbsr053    record
    lcvcod            like datkavislocal.lcvcod       ,
    lcvextcod         like datkavislocal.lcvextcod    ,
    aviestnom         like datkavislocal.aviestnom    ,
    endlgd            like datkavislocal.endlgd       ,
    endbrr            like datkavislocal.endbrr       ,
    endcid            like datkavislocal.endcid       ,
    endufd            like datkavislocal.endufd       ,
    endcep            like datkavislocal.endcep       ,
    endcepcmp         like datkavislocal.endcepcmp    ,
    dddcod            like datkavislocal.dddcod       ,
    teltxt            like datkavislocal.teltxt       ,
    facnum            like datkavislocal.facnum       ,
    horsegsexinc      like datkavislocal.horsegsexinc ,
    horsegsexfnl      like datkavislocal.horsegsexfnl ,
    horsabinc         like datkavislocal.horsabinc    ,
    horsabfnl         like datkavislocal.horsabfnl    ,
    hordominc         like datkavislocal.hordominc    ,
    hordomfnl         like datkavislocal.hordomfnl    ,
    lcvlojtip         like datkavislocal.lcvlojtip    ,
    obs               like datkavislocal.obs
 end record

 define ws            record
    lcvlojdes         char (10) ,
    lcvnom            like datklocadora.lcvnom
 end record

   output
      left   margin  00
      right  margin  132
      top    margin  00
      bottom margin  00
      page   length  90

   order by  r_bdbsr053.lcvcod,
             r_bdbsr053.endufd,
             r_bdbsr053.endcid,
             r_bdbsr053.lcvextcod

   format
      page header
           if pageno = 1  then
              print "OUTPUT JOBNAME=DBS05301 FORMNAME=BRANCO"        # Marcio  Meta - PSI185035
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - LOJAS DE LOCACAO DE VEICULOS"
              print "$DJDE$ JDL=XJ0030, JDE=XD0030, FORMS=XF6560, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
              print ascii(12)
           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if

           print column 047, "RDBS053-01",
                 column 061, "PAGINA : ", pageno using "##,###,###"
           print column 061, "DATA   : ", today
           print column 010, "LOJAS DE LOCACAO DE VEICULOS" ,
                 column 061, "HORA   :   ", time

           skip 2 lines

      before group of r_bdbsr053.lcvcod
           skip to top of page

           let ws.lcvnom = "NAO CADASTRADA"

           select lcvnom into ws.lcvnom
             from datklocadora
            where lcvcod = r_bdbsr053.lcvcod

           print column 001, "LOCADORA: ", r_bdbsr053.lcvcod using "#&&",
                             " - ", ws.lcvnom
           skip 1 line

      on every row
           case r_bdbsr053.lcvlojtip
              when  1   let ws.lcvlojdes = "CORPORACAO"
              when  2   let ws.lcvlojdes = "FRANQUIA"
              otherwise let ws.lcvlojdes = "********"
           end case

           need 10 lines
           print column 005, "NOME  : ",
                 column 013, r_bdbsr053.aviestnom ,
                 column 060, "CODIGO: ",
                 column 066, r_bdbsr053.lcvextcod
           print column 005, "END.  : ",
                 column 013, r_bdbsr053.endlgd
           print column 005, "BAIRRO: ",
                 column 013, r_bdbsr053.endbrr
           print column 005, "CIDADE: ",
                 column 013, r_bdbsr053.endcid clipped ,
                     " - " , r_bdbsr053.endufd
           print column 005, "FONE  : ",
                 column 013, "(",
                 column 014, r_bdbsr053.dddcod,
                 column 018, ")",
                 column 019, r_bdbsr053.teltxt,
                 column 060, "FAX...: ",
                 column 066, r_bdbsr053.facnum   using "<<<<<<<<"
           print column 005, "CEP   : ",
                 column 013, r_bdbsr053.endcep;

           if r_bdbsr053.endcepcmp  is not null   and
              r_bdbsr053.endcepcmp  <> "   "      then
              print column 018, "-", r_bdbsr053.endcepcmp;
           end if
           print column 030, "  "
           print column 005, "HORA  : ",
                 column 013, r_bdbsr053.horsegsexinc, " AS ",
                             r_bdbsr053.horsegsexfnl;

           if r_bdbsr053.horsabinc is not null  and
              r_bdbsr053.horsabfnl is not null  then
              print "; SAB. ", r_bdbsr053.horsabinc, " AS ",
                               r_bdbsr053.horsabfnl;
           end if

           if r_bdbsr053.hordominc is not null  and
              r_bdbsr053.hordomfnl is not null  then
              print "; DOM. ", r_bdbsr053.hordominc, " AS ",
                               r_bdbsr053.hordomfnl
           else
              print " "
           end if

           print column 005, "TIPO..: ", ws.lcvlojdes
           print column 005, "OBS...: ", r_bdbsr053.obs
           skip 1 line

      on last  row
           print "$FIMREL$"

end report
