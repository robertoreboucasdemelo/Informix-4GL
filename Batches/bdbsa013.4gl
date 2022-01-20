#############################################################################
# Nome do Modulo: bdbsa013                                         Wagner   #
# cria registros para W04                                          Fev/2002 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL          DESCRICAO                   #
# 20/05/2003               FERNANDO ( FABRICA ) RESOLUCAO 86                #
#############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 28/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################


 database porto

 main
   call fun_dba_abre_banco("CT24HS") 
   set isolation to dirty read
   call bdbsa013()
 end main


#---------------------------------------------------------------
 function bdbsa013()
#---------------------------------------------------------------

 define d_bdbsa013  record
    lignum          like datmsitrecl.lignum,
    succod          like datrligapol.succod,
    ramcod          like datrligapol.ramcod, 
    aplnumdig       like datrligapol.aplnumdig,
    itmnumdig       like datrligapol.itmnumdig,
    edsnumref       like datrligapol.edsnumref,
    segnumdig       like abbmdoc.segnumdig,
    segnom          like gsakseg.segnom,
    endlgdtip       like gsakend.endlgdtip,
    endlgd          like gsakend.endlgd,
    endnum          like gsakend.endnum,
    endcmp          like gsakend.endcmp,
    endbrr          like gsakend.endbrr,
    endcid          like gsakend.endcid,
    endufd          like gsakend.endufd,
    endcep          like gsakend.endcep,  
    endcepcmp       like gsakend.endcepcmp 
 end record

 define w_funapol   record
    resultado       char(01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
 end record

 define ws          record
    dirfisnom       like ibpkdirlog.dirfisnom,
    pathrel01       char (60),
    executa         char (500)
 end record

 define l_retorno smallint

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
  call f_path("DBS", "ARQUIVO") # PSI 185035
       returning ws.dirfisnom

  if ws.dirfisnom is null then
     let ws.dirfisnom = "."
  end if

 let ws.pathrel01 = ws.dirfisnom clipped, "/QDBS01301.TXT" # PSI 185035

 #----------------------------------
 # Processamento principal
 #----------------------------------
 declare c_bdatq012 cursor for
  select datmsitrecl.lignum   , datrligapol.succod   ,
         datrligapol.ramcod   , datrligapol.aplnumdig,
         datrligapol.itmnumdig, datrligapol.edsnumref
    from datmsitrecl, datrligapol       
   where datmsitrecl.rclrlzdat    between "01/02/2002" 
                                  and     "21/02/2002"
     and datmsitrecl.c24rclsitcod = 20
     and datmsitrecl.c24astcod    = "W04"
     and datrligapol.lignum       = datmsitrecl.lignum 

 start report  rel_reclam  to  ws.pathrel01  

 foreach c_bdatq012 into d_bdbsa013.lignum   , d_bdbsa013.succod   ,
                         d_bdbsa013.ramcod   , d_bdbsa013.aplnumdig,
                         d_bdbsa013.itmnumdig, d_bdbsa013.edsnumref

    call f_funapol_auto (d_bdbsa013.succod    , d_bdbsa013.aplnumdig,
                         d_bdbsa013.itmnumdig, d_bdbsa013.edsnumref )
              returning  w_funapol.*

    #--------------------------------------
    # Numero do segurado e tipo de endosso
    #--------------------------------------
    select segnumdig
      into d_bdbsa013.segnumdig
      from abbmdoc
     where abbmdoc.succod    =  d_bdbsa013.succod    
       and abbmdoc.aplnumdig =  d_bdbsa013.aplnumdig 
       and abbmdoc.itmnumdig =  d_bdbsa013.itmnumdig 
       and abbmdoc.dctnumseq =  w_funapol.dctnumseq

    if sqlca.sqlcode <> notfound  then
       #----------------------
       # Dados do segurado
       #----------------------
       select segnom 
         into d_bdbsa013.segnom
         from gsakseg
        where gsakseg.segnumdig = d_bdbsa013.segnumdig

       if sqlca.sqlcode = notfound  then
          let d_bdbsa013.segnom = "Segurado nao cadastrado!"
       else
          select gsakend.endlgdtip, gsakend.endlgd   ,
                 gsakend.endnum   , gsakend.endcmp   ,
                 gsakend.endbrr   , gsakend.endcid   ,
                 gsakend.endufd   , gsakend.endcep   ,
                 gsakend.endcepcmp 
            into d_bdbsa013.endlgdtip, d_bdbsa013.endlgd   ,
                 d_bdbsa013.endnum   , d_bdbsa013.endcmp   ,
                 d_bdbsa013.endbrr   , d_bdbsa013.endcid   ,
                 d_bdbsa013.endufd   , d_bdbsa013.endcep   ,
                 d_bdbsa013.endcepcmp 
            from gsakend
           where gsakend.segnumdig = d_bdbsa013.segnumdig 
             and gsakend.endfld    = "1"

       end if
    end if

    output to report rel_reclam(d_bdbsa013.*) 

    initialize d_bdbsa013.* to null

 end foreach

 finish report rel_reclam 

 #------------------------------------------------------------------
 # E-MAIL PORTO SOCORRO
 #------------------------------------------------------------------

 let ws.executa = "  Lista segurados para cartas W04 "
 let l_retorno = ctx22g00_envia_email("BDBSA013",
                                      ws.executa,
                                      ws.pathrel01)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display "Erro ao enviar email(ctx22g00) - ",ws.pathrel01
    else
       display "Nao existe email cadastrado para este modulo - BDBSA013"
    end if
 end if 
 
 #let ws.executa =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
 #              " -s 'Lista segurados para cartas W04' ",
 #              "agostinho_wagner/spaulo_info_sistemas@u55 < ",
 #               ws.pathrel01 clipped
 #run ws.executa

end function  ###  bdbsa013      

#---------------------------------------------------------------------------
 report rel_reclam(r_bdbsa013)       
#---------------------------------------------------------------------------

 define r_bdbsa013  record
    lignum          like datmsitrecl.lignum,
    succod          like datrligapol.succod,
    ramcod          like datrligapol.ramcod, 
    aplnumdig       like datrligapol.aplnumdig,
    itmnumdig       like datrligapol.itmnumdig,
    edsnumref       like datrligapol.edsnumref,
    segnumdig       like abbmdoc.segnumdig,
    segnom          like gsakseg.segnom,
    endlgdtip       like gsakend.endlgdtip,
    endlgd          like gsakend.endlgd,
    endnum          like gsakend.endnum,
    endcmp          like gsakend.endcmp,
    endbrr          like gsakend.endbrr,
    endcid          like gsakend.endcid,
    endufd          like gsakend.endufd,
    endcep          like gsakend.endcep,  
    endcepcmp       like gsakend.endcepcmp 
 end record

 output 
    left   margin  000
    right  margin  000
    top    margin  000
    bottom margin  000
    page   length  001

 format
    on every row 
       print column 001, r_bdbsa013.ramcod    using "&&&&"       ,"/",
                         r_bdbsa013.succod    using "&&"         ,"/",
                         r_bdbsa013.aplnumdig using "<<<<<<<& &" ,"/",
                         r_bdbsa013.itmnumdig using "<<<<<& &"   ,"|",
                         r_bdbsa013.segnom    clipped            ,"|",
                         r_bdbsa013.endlgdtip clipped            ," ",
                         r_bdbsa013.endlgd    clipped            ," ",
                         r_bdbsa013.endnum    using "<<<<<&"     ," ",
                         r_bdbsa013.endcmp    clipped            ,"|",
                         r_bdbsa013.endbrr    clipped            ,"|",
                         r_bdbsa013.endcep    clipped            ,
                         r_bdbsa013.endcepcmp clipped            ,"|",
                         r_bdbsa013.endcid    clipped            ,"|",
                         r_bdbsa013.endufd    clipped            ,"|",
                         ascii(13)

end report  ###  rel_reclam 

