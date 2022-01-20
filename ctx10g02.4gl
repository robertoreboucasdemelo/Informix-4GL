#############################################################################
# Nome do Modulo: CTX10G02                                         Wagner   #
#                                                                           #
# Funcao verifica e retorna o valor da total pago a prestadores    Set/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
#---------------------------------------------------------------------------#
# 24/11/2008 Priscila Staingel 230650  Nao utilizar a 1 posicao do assunto  #
#                                      como sendo o agrupamento, buscar cod #
#                                      agrupamento.                         #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

# TESTE DE FUNCIONAMENTO
# define ws_valor   dec(15,2),
#        ws_ultdat  date,
#        ws_suc     integer,
#        ws_apl     integer,
#        ws_itm     integer
# main
#   while true
#    prompt " sucursal " for ws_suc
#    prompt " apolice "  for ws_apl
#    prompt " item "     for ws_itm
#    call ctx10g02(ws_suc, ws_apl, ws_itm)
#        returning ws_valor, ws_ultdat
#    display " --> ",ws_valor
#    display " --> ",ws_ultdat
#   end while
# end main

#---------------------------------------------------------------
 function ctx10g02(param)
#---------------------------------------------------------------

 define param      record
    succod         like datrligapol.succod,
    aplnumdig      like datrligapol.aplnumdig,
    itmnumdig      like datrligapol.itmnumdig
 end record

 define ws         record
    comando        char (400),
    lignum         like datrligapol.lignum   , 
    atdetpcod      like datmsrvacp.atdetpcod ,
    c24astcod      like datmligacao.c24astcod,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    atdsrvorg      like datmservico.atdsrvorg,
    atddat         like datmservico.atddat   ,   
    asitipcod      like datmservico.asitipcod,
    socopgitmvlr   like dbsmopgitm.socopgitmvlr,
    totvlr         decimal (15,2),
    ultdat         date,
    c24astagp      like datkassunto.c24astagp
 end record

 set isolation to dirty read

 initialize ws.* to null
 let ws.totvlr   =  0

 #---------------------------------------------------------------
 # Preparando SQL 
 #---------------------------------------------------------------
 let ws.comando  = "select datmligacao.atdsrvnum, ",
                   "       datmligacao.atdsrvano, ",
                   "       datmligacao.c24astcod  ", 
                   "  from datmligacao ",
                   " where datmligacao.lignum = ? "                  
 prepare sel_datmligacao from ws.comando
 declare c_datmligacao cursor for sel_datmligacao

 let ws.comando  = "select c24astagp     ",
                   "  from datkassunto   ",
                   " where c24astcod = ? "                  
 prepare sel_datkassunto from ws.comando
 declare c_datkassunto cursor for sel_datkassunto

 let ws.comando  = "select datmservico.atdsrvorg, ", 
                   "       datmservico.atddat   , ", 
                   "       datmservico.asitipcod  ", 
                   "  from datmservico ",
                   " where datmservico.atdsrvnum = ? ",  
                   "   and datmservico.atdsrvano = ? "  
 prepare sel_datmservico from ws.comando
 declare c_datmservico cursor for sel_datmservico

 let ws.comando  = "select a.atdetpcod  ",
                   "  from datmsrvacp a",
                   " where a.atdsrvnum = ? ",
                   "   and a.atdsrvano = ? ",
                   "   and a.atdsrvseq = (select max(b.atdsrvseq)",
                                         "  from datmsrvacp b    ",
                                         " where b.atdsrvnum = a.atdsrvnum ",
                                         "   and b.atdsrvano = a.atdsrvano )"
 prepare sel_datmsrvacp from ws.comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

 let ws.comando  = "select dbsmopgitm.socopgitmvlr ",
                   "  from dbsmopgitm, dbsmopg ",
                   " where dbsmopgitm.atdsrvnum = ? ", 
                   "   and dbsmopgitm.atdsrvano = ? ",  
                   "   and dbsmopg.socopgnum    = dbsmopgitm.socopgnum ",
                   "   and dbsmopg.socopgsitcod = 7 "  
 prepare sel_pagtos from ws.comando
 declare c_pagtos cursor for sel_pagtos

 #---------------------------------------------------------------
 # Cursor principal
 #---------------------------------------------------------------
 declare c_ctx10g02 cursor for
  select datrligapol.lignum  
    from datrligapol
   where datrligapol.succod    = param.succod
     and datrligapol.ramcod    in  (31,531)
     and datrligapol.aplnumdig = param.aplnumdig
     and datrligapol.itmnumdig = param.itmnumdig

 foreach c_ctx10g02  into ws.lignum 

    #------------------------------------------------------------
    # Verifica Ligacao com servico
    #------------------------------------------------------------
    open  c_datmligacao using ws.lignum  
    fetch c_datmligacao into  ws.atdsrvnum ,ws.atdsrvano, ws.c24astcod   
      if sqlca.sqlcode = notfound then
         continue foreach
      end if
    close c_datmligacao

    #PSI 230650 - Buscar agrupamento do assunto
    open c_datkassunto using ws.c24astcod
    fetch c_datkassunto into ws.c24astagp
      if sqlca.sqlcode = notfound then
         continue foreach
      end if
    close c_datkassunto

    # Verifica assuntos dai ligacao 
    #if ws.c24astcod[1,1] <> "W"     and     ##psi230650
    if ws.c24astagp <> "W"     and 
       ws.c24astcod <> "ALT"   and 
       ws.c24astcod <> "REC"   and 
       ws.c24astcod <> "CAN"   and 
       ws.c24astcod <> "RET"   and 
       ws.c24astcod <> "IND"   and 
       ws.c24astcod <> "CON"   THEN
       # assunto valido!
    else
       continue foreach
    end if

    #------------------------------------------------------------
    # Verifica servico               
    #------------------------------------------------------------
    open  c_datmservico using ws.atdsrvnum ,ws.atdsrvano
    fetch c_datmservico into  ws.atdsrvorg ,ws.atddat   
      if sqlca.sqlcode = notfound then
         continue foreach
      end if
    close c_datmservico

    # Verifica data atendimento,  tipo do servico e etapa
    if ws.atddat >= "01/06/2001"  and   
       ws.atddat <= "30/06/2001"  then  
       # OK registro valido
    else
       continue foreach
    end if
    if ws.atdsrvorg <> 1  and     #Porto Socorro
       ws.atdsrvorg <> 2  and     #Transporte       
       ws.atdsrvorg <> 4  and     #Remocoes         
       ws.atdsrvorg <> 5  and     #RPT 
       ws.atdsrvorg <> 6  and     #DAF              
       ws.atdsrvorg <> 7  and     #Replace 
       ws.atdsrvorg <>17  then    #Replace s/ docto
       continue foreach
    end if 
    if ws.atdsrvorg = 2   and     #Transporte taxi  
       ws.asitipcod <> 5  then    
       continue foreach
    end if
    open  c_datmsrvacp using ws.atdsrvnum ,ws.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp
    if ws.atdetpcod <> 4  then
       continue foreach
    end if
    
    #------------------------------------------------------------
    # Verifica valor pago servico   
    #------------------------------------------------------------
    let ws.socopgitmvlr = 0
    open  c_pagtos using ws.atdsrvnum ,ws.atdsrvano
    fetch c_pagtos into  ws.socopgitmvlr
      if sqlca.sqlcode = notfound then
         let ws.socopgitmvlr = 0
         continue foreach
      end if
    close c_pagtos

    if ws.socopgitmvlr is not null and
       ws.socopgitmvlr <> 0        then
       let ws.totvlr = ws.totvlr + ws.socopgitmvlr
       let ws.ultdat = ws.atddat
    end if

 end foreach

 return ws.totvlr, ws.ultdat

end function

