############################################################################
# Menu de Modulo: CTS11M07                                        Marcelo  #
#                                                                 Gilberto #
# Solicitacao de cotacoes via pager - assistencia a passageiros   Jun/1999 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 04/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.  #
#--------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
############################################################################
#                                                                          #
#                      * * * Alteracoes * * *                              #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ----------------------------------- #
# 17/09/2003  Meta,Jefferson PSI175552 Chamada da funcao cts20g00_servico  #
#                            OSF26077  Chamar a funcao cts30m00            #
#                                                                          #
# 01/10/2008 Amilton,Meta   PSI 223689  Incluir tratamento de erro com     #
#                                       global ( Isolamento U01 )          #
############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689


   define m_prepara_sql     smallint

#---------------------------#
function cts11m07_prepara()
#---------------------------#
   define l_sql   char(200)
   let l_sql = " select c24astcod, ligcvntip, c24solnom "
              ,"   from datmligacao "
              ,"  where lignum = ? "
   prepare pcts11m07001 from l_sql
   declare ccts11m07001 cursor for pcts11m07001
   let m_prepara_sql = true
end function


#--------------------------------------------------------------
 function cts11m07(param)
#--------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record

 define d_cts11m07    record
    srvtipdes         like datksrvtip.srvtipdes,
    asitipdes         like datkasitip.asitipdes,
    atddat            like datmservico.atddat,
    atdhor            like datmservico.atdhor,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    nom               like datmservico.nom,
    atddmccidnom      like datmassistpassag.atddmccidnom,
    atddmcufdcod      like datmassistpassag.atddmcufdcod,
    atdocrcidnom      like datmlcl.cidnom,
    atdocrufdcod      like datmlcl.ufdcod,
    atddstcidnom      like datmassistpassag.atddstcidnom,
    atddstufdcod      like datmassistpassag.atddstufdcod,
    trppfrdat         like datmassistpassag.trppfrdat,
    trppfrhor         like datmassistpassag.trppfrhor,
    asimtvdes         like datkasimtv.asimtvdes,
    pasqtd            smallint,
    hpddiapvsqtd      like datmhosped.hpddiapvsqtd,
    hpdqrtqtd         like datmhosped.hpdqrtqtd
 end record

 define ws            record
    atdsrvorg         like datmservico.atdsrvorg,
    asitipcod         like datkasitip.asitipcod,
    asimtvcod         like datkasimtv.asimtvcod,
    mstnum            like htlmmst.mstnum,
    mstastdes         like htlmmst.mstastdes,
    msgtxt            char (1080),
    msgblc            char (360),
    ustcod            like htlrust.ustcod,
    errcod            smallint,
    sqlcod            integer,
    saiflg            smallint,
    confirma          char (01)
 end record
 define lr_datmligacao record
        c24astcod     like datmligacao.c24astcod,
        ligcvntip     like datmligacao.ligcvntip,
        c24solnom     like datmligacao.c24solnom
 end record

 define i, j          smallint
 define l_lignum      like datrligsrv.lignum,
        l_flag_envio  smallint,
        l_nulo        char(01)

 define prompt_key    char(01)

#-----------------------------------------------------------------------
# Inicializacao das variaveis
#-----------------------------------------------------------------------

	if m_prepara_sql is null or
	   m_prepara_sql <> true then
	   call cts11m07_prepara()
	end if
	let	i  =  null
	let	j  =  null
	let	prompt_key  =  null

	initialize  d_cts11m07.*  to  null

	initialize  ws.*  to  null

 initialize d_cts11m07.* to null
 initialize ws.*         to null

 let ws.mstastdes = "ASSISTENCIA A PASSAGEIROS - COTACAO"

 let ws.ustcod = 2499     ###  Pager Teletrim no. 4070901

 if param.atdsrvnum is null  or
    param.atdsrvano is null  then
    error " Parametros nao informados! AVISE A INFORMATICA!"
    return false
 end if

 call cts08g01("C","S","","SOLICITACAO DE COTACAO","VIA TELETRIM","") returning ws.confirma

 if ws.confirma = "N"  then
    return false
 end if

 error " Aguarde, acionando prestador de servicos via Teletrim ", ws.ustcod, "..."

#-----------------------------------------------------------------------
# Montagem do corpo da mensagem
#-----------------------------------------------------------------------
 select datmservico.atddat,
        datmservico.atdhor,
        datmservico.atdsrvorg,
        datmservico.asitipcod,
        datrservapol.succod,
        datrservapol.ramcod,
        datrservapol.aplnumdig,
        datrservapol.itmnumdig,
        datmservico.nom
   into d_cts11m07.atddat,
        d_cts11m07.atdhor,
        ws.atdsrvorg,
        ws.asitipcod,
        d_cts11m07.succod,
        d_cts11m07.ramcod,
        d_cts11m07.aplnumdig,
        d_cts11m07.itmnumdig,
        d_cts11m07.nom
   from datmservico, outer datrservapol
  where datmservico.atdsrvnum = param.atdsrvnum
    and datmservico.atdsrvano = param.atdsrvano
    and datmservico.atdsrvnum = datrservapol.atdsrvnum
    and datmservico.atdsrvano = datrservapol.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado! AVISE A INFORMATICA!"
    prompt "" for char prompt_key
    return false
 end if
 ####psi175552####
 call cts20g00_servico(param.atdsrvnum, param.atdsrvano)
      returning l_lignum
 open ccts11m07001 using l_lignum
 whenever error continue
 fetch ccts11m07001 into lr_datmligacao.*
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       error "Dados nao encontrados selecionando DATMLIGACAO"
    else
       error " Erro SELECT datmligacao: ",
                sqlca.sqlcode," | ",sqlca.sqlerrd[2] sleep 2
    end if
    return false
 end if
 let l_nulo = null
 call figrc072_setTratarIsolamento() -- > psi 223689
 call cts30m00(d_cts11m07.ramcod,
               lr_datmligacao.c24astcod,
               lr_datmligacao.ligcvntip,
               d_cts11m07.succod,
               d_cts11m07.aplnumdig,
               d_cts11m07.itmnumdig,
               l_lignum,
               param.atdsrvnum,
               param.atdsrvano,
               l_nulo,
               l_nulo,
               lr_datmligacao.c24solnom)
 returning l_flag_envio
 if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
    error "Problemas na função cts30m00 ! Avise a Informatica !" sleep 2
    return
 end if        -- > 223689
 {select count(*)
   into d_cts11m07.pasqtd
   from datmpassageiro
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

 select atddmccidnom, atddmcufdcod,
        atddstcidnom, atddstufdcod,
        trppfrdat   , trppfrhor,
        asimtvcod
   into d_cts11m07.atddmccidnom,
        d_cts11m07.atddmcufdcod,
        d_cts11m07.atddstcidnom,
        d_cts11m07.atddstufdcod,
        d_cts11m07.trppfrdat,
        d_cts11m07.trppfrhor,
        ws.asimtvcod
   from datmassistpassag
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Dados da assistencia nao encontrados. AVISE A INFORMATICA!"
    prompt "" for char prompt_key
    return false
 end if

 select cidnom, ufdcod
   into d_cts11m07.atdocrcidnom,
        d_cts11m07.atdocrufdcod
   from datmlcl
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and c24endtip = 1

 if sqlca.sqlcode = notfound  then
    return false
 end if

 select srvtipdes
   into d_cts11m07.srvtipdes
   from datksrvtip
  where atdsrvorg = ws.atdsrvorg

 select asitipdes
   into d_cts11m07.asitipdes
   from datkasitip
  where asitipcod = ws.asitipcod

 select asimtvdes
   into d_cts11m07.asimtvdes
   from datkasimtv
  where asimtvcod = ws.asimtvcod

 let ws.msgtxt = "Laudo: ", d_cts11m07.srvtipdes clipped, " - ", d_cts11m07.asitipdes clipped, "  Ordem Servico: ", ws.atdsrvorg using "&&", "/", param.atdsrvnum using "&&&&&&&", "-", param.atdsrvano using "&&", "  Solicitado: ", d_cts11m07.atddat, " as ", d_cts11m07.atdhor

 if d_cts11m07.succod    is null  or
    d_cts11m07.ramcod    is null  or
    d_cts11m07.aplnumdig is null  then
    let ws.msgtxt = ws.msgtxt clipped, "  Documento: NAO INFORMADO"
 else
    let ws.msgtxt = ws.msgtxt clipped, "  Documento: ", d_cts11m07.succod using "&&", " ", d_cts11m07.ramcod using "##&&", " ", d_cts11m07.aplnumdig using "<<<<<<<& &"

    if d_cts11m07.itmnumdig <> 0  then
       let ws.msgtxt = ws.msgtxt clipped, " ", d_cts11m07.itmnumdig using "<<<<<& &"
    end if
 end if

 let ws.msgtxt = ws.msgtxt clipped, "  Segurado: ", d_cts11m07.nom clipped, "  Domicilio: ", d_cts11m07.atddmccidnom clipped, " - ", d_cts11m07.atddmcufdcod, "  Ocorrencia: ", d_cts11m07.atdocrcidnom clipped, " - ", d_cts11m07.atdocrufdcod, "  Destino: ", d_cts11m07.atddstcidnom clipped, " - ", d_cts11m07.atddstufdcod, "  Motivo: ", d_cts11m07.asimtvdes clipped, "  Quant. Passageiros: ", d_cts11m07.pasqtd using "<&"

 if ws.asitipcod = 10  then
    if d_cts11m07.trppfrdat is not null  then
       let ws.msgtxt = ws.msgtxt clipped, "  Preferencia para Viagem: ", d_cts11m07.trppfrdat

       if d_cts11m07.trppfrhor is not null  then
          let ws.msgtxt = ws.msgtxt clipped, "  `as ", d_cts11m07.trppfrhor
       end if
    end if
 end if

 if ws.atdsrvorg =  3   then
    select hpddiapvsqtd, hpdqrtqtd
      into d_cts11m07.hpddiapvsqtd,
           d_cts11m07.hpdqrtqtd
      from datmhosped
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

    let ws.msgtxt = ws.msgtxt clipped, "  Diarias: ", d_cts11m07.hpddiapvsqtd   using "<&", "  Quartos: ", d_cts11m07.hpdqrtqtd using "<&"
 end if

#-----------------------------------------------------------------------
# Interface com sistema Teletrim de envio de mensagens
#-----------------------------------------------------------------------
 let i = 0
 let j = 0

 if length(ws.msgtxt clipped) <= 360  then
    let ws.saiflg = true
 else
    let ws.saiflg = false
 end if

 while true
    let i = j + 1
    let j = j + 360

    if j >= 1080  then
       let j = 1080
       let ws.saiflg = true
    end if

    let ws.msgblc = ws.msgtxt[i,j] clipped

#---------------------------------------------------------------
# Grava tabela de mensagens a serem enviadas
#---------------------------------------------------------------

    call fptla025_usuario(ws.ustcod,
                          ws.mstastdes,
                          ws.msgblc,
                          g_issk.funmat,
                          g_issk.empcod,
                          false,       ###  Nao controla transacoes
                          "O",         ###  Online
                          "M",         ###  Mailtrim
                          "",          ###  Data Transmissao
                          "",          ###  Hora Transmissao
                          g_issk.maqsgl)  ###  Maquina de aplicacao

                returning ws.errcod,
                          ws.sqlcod,
                          ws.mstnum

    if ws.errcod > 5  then
       error "Erro (", ws.errcod using "<&", ":",ws.sqlcod, ") na gravacao da interface com Teletrim. AVISE A INFORMATICA!"
       prompt "" for char prompt_key
       return false
    end if

    if ws.saiflg = true  then
       exit while
    end if
 end while

 whenever error stop} ####psi175552####
 return true

end function  ###  cts11m07
