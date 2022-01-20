############################################################################
# Nome do Modulo: bdbsr054                                         Marcelo #
#                                                                 Gilberto #
# Relacao de Veiculos - CARRO EXTRA                               Fev/1996 #
############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 20/11/1998  PSI 7056-4   Gilberto     Alterar acesso a tabela de valores  #
#                                       DATKLOCALDIARIA que teve chave pri- #
#                                       maria alterada.                     #
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

define wstraco       char(080)
define ws_cctcod     like igbrrelcct.cctcod
define ws_relviaqtd  like igbrrelcct.relviaqtd

main
   call fun_dba_abre_banco("CT24HS") 
   call bdbsr054()
end main

#---------------------------------------------------------------
 function bdbsr054()
#---------------------------------------------------------------

   define d_bdbsr054     record
      lcvcod             like datkavisveic.lcvcod    ,
      avivclcod          like datkavisveic.avivclcod ,
      avivclgrp          like datkavisveic.avivclgrp ,
      avivclmdl          like datkavisveic.avivclmdl ,
      avivcldes          like datkavisveic.avivcldes ,
      obs                like datkavisveic.obs
   end record

   define ws             record
      sql                char (200)                  ,
      lcvstt             like datklocadora.lcvstt    ,
      avivclstt          like datkavisveic.avivclstt ,
      dirfisnom          like ibpkdirlog.dirfisnom   ,
      pathrel01          char (60)
   end record

   initialize d_bdbsr054.*  to null
   initialize ws.*          to null

   let wstraco = "-------------------------------------------------------------------------------"


#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "RELATO")                                  # Marcio  Meta - PSI185035
      returning ws.dirfisnom
 
 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if          
      
 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS05401"
                                                               
#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDBS05401")                                    # Marcio  Meta - PSI185035
      returning  ws_cctcod,
		 ws_relviaqtd


   let ws.sql = " select avivclcod,  ",
                "        avivclgrp,  ",
                "        avivclmdl,  ",
                "        avivcldes,  ",
                "        avivclstt,  ",
                "        obs         ",
                "   from datkavisveic",
                "  where lcvcod = ?  "
   prepare sel_avisveic from ws.sql
   declare c_avisveic cursor for sel_avisveic

   declare  c_bdbsr054  cursor for
      select lcvcod, lcvstt
        from datklocadora

   start report  rep_avisveic to ws.pathrel01

   foreach  c_bdbsr054  into  d_bdbsr054.lcvcod,
                              ws.lcvstt

      if ws.lcvstt <> "A"  then
         continue foreach
      end if

      open    c_avisveic using d_bdbsr054.lcvcod

      foreach c_avisveic into  d_bdbsr054.avivclcod,
                               d_bdbsr054.avivclgrp,
                               d_bdbsr054.avivclmdl,
                               d_bdbsr054.avivcldes,
                               ws.avivclstt        ,
                               d_bdbsr054.obs

         if ws.avivclstt <> "A"  then
            continue foreach
         end if

         output to report  rep_avisveic (d_bdbsr054.*)

      end foreach
   end foreach

   finish report rep_avisveic

end function  ###  bdbsr054

#---------------------------------------------------------------------------
 report rep_avisveic(r_bdbsr054)
#---------------------------------------------------------------------------

   define r_bdbsr054    record
      lcvcod            like datkavisveic.lcvcod       ,
      avivclcod         like datkavisveic.avivclcod    ,
      avivclgrp         like datkavisveic.avivclgrp    ,
      avivclmdl         like datkavisveic.avivclmdl    ,
      avivcldes         like datkavisveic.avivcldes    ,
      obs               like datkavisveic.obs
   end record

   define r_bdbsr054_vlr record
      lcvlojdes         char (10)                         ,
      lcvregprccod      like datklocaldiaria.lcvregprccod ,
      lcvvcldiavlr      like datklocaldiaria.lcvvcldiavlr ,
      lcvvclsgrvlr      like datklocaldiaria.lcvvclsgrvlr
   end record

   define ws            record
      lcvnom            like datklocadora.lcvnom ,
      lcvlojtip         like datklocaldiaria.lcvlojtip
   end record

   define sql_comando    char (300)

   output
      left   margin  00
      right  margin  132
      top    margin  00
      bottom margin  00
      page   length  90

   order by  r_bdbsr054.lcvcod   ,
             r_bdbsr054.avivclgrp,
             r_bdbsr054.avivclcod

   format
      page header
           if pageno = 1  then
              print "OUTPUT JOBNAME=DBS05401 FORMNAME=BRANCO"     # Marcio  Meta - PSI185035
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - RELACAO DE VEICULOS CARRO EXTRA"
              print "$DJDE$ JDL=XJ0030, JDE=XD0030, FORMS=XF6560, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"
              print ascii(12)

              let sql_comando = "select lcvlojtip   ,   ",
                                "       lcvregprccod,   ",
                                "       lcvvcldiavlr,   ",
                                "       lcvvclsgrvlr    ",
                                "  from datklocaldiaria ",
                                " where lcvcod    = ?   ",
                                "   and avivclcod = ?   ",
                                " order by lcvlojtip   ,",
                                "          lcvregprccod "

              prepare sql_select from sql_comando

           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if

           print column 047, "RDBS054-01",
                 column 061, "PAGINA : ", pageno using "##,###,###"
           print column 061, "DATA   : ", today
           print column 015, "RELACAO DE VEICULOS - CARRO EXTRA",
                 column 061, "HORA   :   ", time

           skip 2 lines

      before group of r_bdbsr054.lcvcod
           skip to top of page

           let ws.lcvnom = "NAO CADASTRADA"

           select lcvnom into ws.lcvnom
             from datklocadora
            where lcvcod = r_bdbsr054.lcvcod

           print column 001, "LOCADORA: ", r_bdbsr054.lcvcod using "#&&",
                             " - ", ws.lcvnom
           skip 1 line

      before group of r_bdbsr054.avivclgrp
           print column 001, wstraco
           print column 005, "GRUPO: ", r_bdbsr054.avivclgrp
           print column 001, wstraco

      on every row
           initialize r_bdbsr054_vlr.* to null

           print column 005, "VEICULO: ",
                 column 014, r_bdbsr054.avivclmdl ,
                 column 054, "CODIGO : ",
                 column 060, r_bdbsr054.avivclcod  using "&&&&"
           print column 005, "DESCR. : ",
                 column 014, r_bdbsr054.avivcldes

           if r_bdbsr054.obs is not null then
              print column 005, "OBS....: ",
                    column 014, r_bdbsr054.obs
           end if

           print column 005, "TARIFAS: "

           declare c_bdbsr054_vlr cursor for sql_select
           open    c_bdbsr054_vlr using  r_bdbsr054.lcvcod,
                                         r_bdbsr054.avivclcod
           foreach c_bdbsr054_vlr into   ws.lcvlojtip               ,
                                         r_bdbsr054_vlr.lcvregprccod,
                                         r_bdbsr054_vlr.lcvvcldiavlr,
                                         r_bdbsr054_vlr.lcvvclsgrvlr

              case ws.lcvlojtip
                 when 1 let r_bdbsr054_vlr.lcvlojdes = "CORPORACAO"
                 when 2 let r_bdbsr054_vlr.lcvlojdes = "FRANQUIA  "
              end case

              print column 007, r_bdbsr054_vlr.lcvlojdes,
                                " - REGIAO ", r_bdbsr054_vlr.lcvregprccod using "<<"," - ",
                                "DIARIA = R$ ", r_bdbsr054_vlr.lcvvcldiavlr using "<<<,<<<,<<<,<<&.&&",
                    column 054, "SEGURO = R$ ", r_bdbsr054_vlr.lcvvclsgrvlr using "<<<,<<<,<<<,<<&.&&"
           end foreach

           skip 1 line
           initialize ws.lcvlojtip to null

      on last  row
           print "$FIMREL$"

end report  ###  rep_avisveic
