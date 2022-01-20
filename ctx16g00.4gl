############################################################################
# Nome do Modulo: CTX16G00                                        Wagner   #
#                                                                          #
# Apura clausula e natureza dos servicos de RE                    Mar/2002 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
############################################################################

 database porto

#WWWX -------------- TESTE ---------------
#WWWX define ws_clscod      like abbmclaus.clscod,
#WWWx        ws_socntzcod   like datmsrvre.socntzcod,
#WWWx        ws_socntzdes   like datksocntz.socntzdes,
#WWWx        a              dec(10,0),
#WWWx        b              dec(02,0)
#WWWx main
#WWWx    prompt " servico : " for a
#WWWx    prompt " ano     : " for b
#WWWx    call ctx16g00(a,b)
#WWWx        returning ws_clscod, ws_socntzcod, ws_socntzdes
#WWWx    display ws_clscod
#WWWx    display ws_socntzcod
#WWWx    display ws_socntzdes
#WWWx end main
#WWWX ------------------------------------

define  m_dtresol86    date

#---------------------------------------------------------------
 function ctx16g00(param)
#---------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record

 define ws      record
    atdsrvorg   like datmservico.atdsrvorg,
    succod      like datrservapol.succod,
    ramcod      like datrservapol.ramcod,
    aplnumdig   like datrservapol.aplnumdig,
    itmnumdig   like datrservapol.aplnumdig,
    edsnumref   like datrservapol.edsnumref,
    prporg      like datrligprp.prporg,
    prpnumdig   like datrligprp.prpnumdig,
    clscod      like abbmclaus.clscod,
    dctnumseq   like abbmdoc.dctnumseq,
    lignum      like datmligacao.lignum,
    socntzcod   like datmsrvre.socntzcod,
    socntzdes   like datksocntz.socntzdes
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

 define sql_select    char(400)
 define l_exist       smallint
 

 initialize ws.*          to null


 #---------------------------------------------------------------
 # Preparacao dos comandos SQL
 #---------------------------------------------------------------
 let sql_select = "select atdsrvorg ",
                  "  from datmservico ",
                  " where datmservico.atdsrvnum = ? ",
                  "   and datmservico.atdsrvano = ? "
 prepare sel_datmservico from sql_select
 declare c_datmservico cursor for sel_datmservico

 let sql_select = "select succod, ramcod, aplnumdig, itmnumdig ,edsnumref",
                  "  from datrservapol ",
                  " where datrservapol.atdsrvnum = ? ",
                  "   and datrservapol.atdsrvano = ? "
 prepare sel_datrservapol from sql_select
 declare c_datrservapol cursor for sel_datrservapol

 let sql_select = "select datmsrvre.socntzcod, datksocntz.socntzdes ",
                  "  from datmsrvre, datksocntz ",
                  " where datmsrvre.atdsrvnum  = ? ",
                  "   and datmsrvre.atdsrvano  = ? ",
                  "   and datksocntz.socntzcod = datmsrvre.socntzcod "
 prepare sel_datmsrvre from sql_select
 declare c_datmsrvre cursor for sel_datmsrvre

 let sql_select = "select succod, aplnumdig, itmnumdig ,dctnumseq",
                  "  from abbmdoc      ",
                  " where prporgidv = ? " ,
                  "   and prpnumidv = ? "
 prepare sel_abbmdoc    from sql_select
 declare c_abbmdoc      cursor for sel_abbmdoc

 let sql_select = "select lignum from datmligacao ",
                  " where atdsrvnum = ? and atdsrvano = ? and lignum <> 0"
 prepare sel_datmligacao  from sql_select
 declare c_datmligacao    cursor for sel_datmligacao

 #---------------------------------------------------------------
 # Verificacao clausula srv RE
 #---------------------------------------------------------------
 let ws.clscod = "000"

 open  c_datmservico using  param.atdsrvnum, param.atdsrvano
 fetch c_datmservico into   ws.atdsrvorg
 close c_datmservico

 if ws.atdsrvorg  =  9    then  # RE
    open  c_datrservapol using  param.atdsrvnum, param.atdsrvano
    fetch c_datrservapol into   ws.succod   , ws.ramcod,
                                ws.aplnumdig, ws.itmnumdig,
                                ws.edsnumref

       if sqlca.sqlcode = notfound then
          whenever error continue

          select grlinf[01,10] into m_dtresol86
            from datkgeral
            where grlchv='ct24resolucao86'

          if m_dtresol86 <= today then
             let ws.ramcod = 531
          else
             let ws.ramcod = 31
          end if
          #----------------------
          # procura pela proposta
          #----------------------
          open c_datmligacao using param.atdsrvnum ,
                                   param.atdsrvano
          fetch c_datmligacao into ws.lignum

             if sqlca.sqlcode = 0 then
                select prporg, prpnumdig
                  into ws.prporg, ws.prpnumdig
                  from datrligprp
                 where lignum = ws.lignum

                if sqlca.sqlcode = 0 then
                   open c_abbmdoc using ws.prporg , ws.prpnumdig
                   fetch c_abbmdoc into ws.succod   , ws.aplnumdig,
                                        ws.itmnumdig, ws.dctnumseq
                      if sqlca.sqlcode = notfound  then
                         initialize ws.succod   , ws.aplnumdig,
                                    ws.itmnumdig, ws.dctnumseq to null
                      else
                         select edsnumdig
                           into ws.edsnumref
                           from abamdoc
                 where oc.succod    =  ws.succod
                            and abamdoc.aplnumdig =  ws.aplnumdig
                            and abamdoc.dctnumseq =  ws.dctnumseq
                         if sqlca.sqlcode = notfound  then
                            let ws.edsnumref = 0
                         end if
                      end if
                   close c_abbmdoc
                end if
             else
                initialize ws.succod   , ws.aplnumdig,
                           ws.itmnumdig, ws.dctnumseq to null
             end if
          close c_datmligacao
       end if


       if ws.ramcod = 31   or
          ws.ramcod = 531  then
          if ws.succod    is null and
             ws.aplnumdig is null and
             ws.itmnumdig is null and
             ws.dctnumseq is null then
             let ws.clscod = "000"
          else
             call f_funapol_ultima_situacao(ws.succod,
                                            ws.aplnumdig,
                                            ws.itmnumdig)
                                  returning w_funapol.*

             
             declare c_abbmclaus cursor for
             select clscod               
               from abbmclaus
              where succod    = ws.succod
                and aplnumdig = ws.aplnumdig
                and itmnumdig = ws.itmnumdig
                and dctnumseq = w_funapol.dctnumseq
                and clscod    in ( "033","33R","34A", "034", "035", "35A", "35R" ) ## psi201154

             let l_exist = false 
             foreach c_abbmclaus into ws.clscod 
             
                let l_exist = true 
                
                if ws.clscod = "034" or                                        
                   ws.clscod = "071" then                                      
                                                                           
                if cta13m00_verifica_clausula(ws.succod        ,           
                                              ws.aplnumdig     ,           
                                              ws.itmnumdig     ,           
                                              w_funapol.dctnumseq ,           
                                              ws.clscod           ) then      
                                                                            
                     continue foreach                                           
                   end if                                                        
                end if                                        
             end foreach
             
             if l_exist = false then
                let ws.clscod = "000"
             end if

             open  c_datmsrvre using  param.atdsrvnum, param.atdsrvano
             fetch c_datmsrvre into   ws.socntzcod, ws.socntzdes
             close c_datmsrvre
          end if
       end if
    close c_datrservapol
 end if

 return ws.clscod, ws.socntzcod, ws.socntzdes,
        ws.succod, ws.aplnumdig, ws.itmnumdig,
        ws.edsnumref

end function  ###  ctx16g00

