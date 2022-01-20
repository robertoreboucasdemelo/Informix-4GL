#############################################################################
# Nome do Modulo: wdatc076                                         Ligia    #
# Exibe os campos para preenchimento das opcoes de voo             Mar/2006 #
#############################################################################
#-----------------------------------------------------------------------------#
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 23/08/2007 Saulo, Meta     AS146056   fun_dba movida para o inicio do modulo#
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

globals
    define g_ismqconn        smallint,
           g_servicoanterior smallint,
           g_meses           integer,
           w_hostname        char(03),
           g_isbigchar       smallint
end globals

    define param record
        usrtip              char (001),
        webusrcod           char (006),
        sesnum              dec  (010),
        macsissgl           char (010),
        atdsrvnum           like datmservico.atdsrvnum,
        atdsrvano           like datmservico.atdsrvano,
        acao                char(15),
        aerciacod       like datmtrppsgaer.aerciacod,
        trpaervoonum    like datmtrppsgaer.trpaervoonum,
        trpaerptanum    like datmtrppsgaer.trpaerptanum,
        trpaerlzdnum    like datmtrppsgaer.trpaerlzdnum,
        adlpsgvlr       like datmtrppsgaer.adlpsgvlr,
        crnpsgvlr       like datmtrppsgaer.crnpsgvlr,
        totpsgvlr       like datmtrppsgaer.totpsgvlr,
        arpembcod       like datmtrppsgaer.arpembcod,
        trpaersaidat    like datmtrppsgaer.trpaersaidat,
        trpaersaihor    like datmtrppsgaer.trpaersaihor,
        arpchecod       like datmtrppsgaer.arpchecod,
        trpaerchedat    like datmtrppsgaer.trpaerchedat,
        trpaerchehor    like datmtrppsgaer.trpaerchehor,
        vooopc         like datmtrppsgaer.vooopc,
        voocnxseq      like datmtrppsgaer.voocnxseq
    end record

    define ws1 record
        statusprc           dec  (01,0),
        sestblvardes1       char (0256),
        sestblvardes2       char (0256),
        sestblvardes3       char (0256),
        sestblvardes4       char (0256),
        sespcsprcnom        char (0256),
        prgsgl              char (0256),
        acsnivcod           dec  (01,0),
        webprscod           dec  (16,0)
    end record

main

    define l_padrao         char(2000)
    define l_selecionado    dec(1,0)
    define l_aerciacod      like datkciaaer.aerciacod
    define l_aercianom      like datkciaaer.aercianom
    define l_ufdcod         like glakest.ufdcod
    define l_ufdnom         like glakest.ufdnom
    define l_arpcod         like datkaeroporto.arpcod
    define l_arpnom         char(40)  ##like datkaeroporto.arpnom
    define l_sttsess        integer
    define l_cmd            char(500)
    define l_vooopc         like datmtrppsgaer.vooopc
    define l_voocnxseq      like datmtrppsgaer.voocnxseq
    define l_today          date
    define l_time           datetime hour to minute
    define l_atdetpcod      like datmsrvacp.atdetpcod,
           l_atdprvdat      like datmservico.atdprvdat,
           l_srvobs         like datmsrvint.srvobs,
           l_txivlr         like datmassistpassag.txivlr,
           l_msg            char(100),
           l_valor          dec(10,2),
           l_hidden         char(200),
           l_trpaersaidat like datmtrppsgaer.trpaersaidat,
           l_trpaersaihor like datmtrppsgaer.trpaersaihor,
           l_trpaerchedat like datmtrppsgaer.trpaerchedat,
           l_trpaerchehor like datmtrppsgaer.trpaerchehor,
           l_resultado    smallint,
           l_mensagem     char(40),
           l_ciaempcod    like datmservico.ciaempcod,
           l_asimtvcod    like datmassistpassag.asimtvcod

    initialize g_ismqconn        to null
    initialize g_servicoanterior to null
    initialize g_meses           to null
    initialize w_hostname        to null
    initialize g_isbigchar       to null
    initialize param.*       to null
    initialize ws1.*       to null

    initialize l_padrao         to null
    initialize l_selecionado    to null
    initialize l_aerciacod      to null
    initialize l_aercianom      to null
    initialize l_ufdcod         to null
    initialize l_ufdnom         to null
    initialize l_arpcod         to null
    initialize l_arpnom         to null
    initialize l_sttsess        to null
    initialize l_cmd            to null
    initialize l_vooopc         to null
    initialize l_voocnxseq      to null
    initialize l_today          to null
    initialize l_time           to null
    initialize l_atdetpcod      to null
    initialize l_atdprvdat      to null
    initialize l_srvobs         to null
    initialize l_txivlr         to null
    initialize l_msg            to null
    initialize l_valor          to null
    initialize l_hidden         to null
    initialize l_trpaersaidat to null
    initialize l_trpaersaihor to null
    initialize l_trpaerchedat to null
    initialize l_trpaerchehor to null
    initialize l_resultado    to null
    initialize l_mensagem     to null
    initialize l_ciaempcod    to null
    initialize l_asimtvcod    to null

    #------------------------------------------
    #  ABRE BANCO   (TESTE ou PRODUCAO)
    #------------------------------------------
    call fun_dba_abre_banco("CT24HS")

    let l_padrao         = null
    let l_selecionado    = null
    let l_aerciacod      = null
    let l_aercianom      = null
    let l_ufdcod         = null
    let l_ufdnom         = null
    let l_arpcod         = null
    let l_arpnom         = null
    let l_cmd            = null
    let l_voocnxseq      = null
    let l_vooopc         = null
    let l_today          = null
    let l_time           = null
    let l_atdetpcod      = null
    let l_msg            = null
    let l_valor          = null
    let l_hidden         = null
    let l_trpaersaidat   = null
    let l_trpaersaihor   = null
    let l_trpaerchedat   = null
    let l_trpaerchehor   = null
    let l_resultado      = null
    let l_mensagem       = null
    let l_ciaempcod      = null

    #---------------------------------
    # Le parametros recebidos do PERL
    #---------------------------------
    let param.usrtip       = arg_val(1)
    let param.webusrcod    = arg_val(2)
    let param.sesnum       = arg_val(3)
    let param.macsissgl    = arg_val(4)
    let param.atdsrvnum    = arg_val(5)
    let param.atdsrvano    = arg_val(6)
    let param.acao         = arg_val(7)
    let l_atdprvdat        = arg_val(8)
    let l_srvobs            = arg_val(9)
    let l_txivlr            = arg_val(10)
    let param.aerciacod     = arg_val(11)
    let param.trpaervoonum  = arg_val(12)
    let param.trpaerptanum  = arg_val(13)
    let param.trpaerlzdnum  = arg_val(14)
    let param.adlpsgvlr     = arg_val(15)
    let param.crnpsgvlr     = arg_val(16)
    let param.totpsgvlr     = arg_val(17)
    let param.arpembcod     = arg_val(18)
    let param.trpaersaidat  = arg_val(19)
    let param.trpaersaihor  = arg_val(20)
    let param.arpchecod     = arg_val(21)
    let param.trpaerchedat  = arg_val(22)
    let param.trpaerchehor  = arg_val(23)
    let param.vooopc        = arg_val(24)
    let param.voocnxseq     = arg_val(25)

    set isolation to dirty read

    #---------------------------------------------
    #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
    #---------------------------------------------
    initialize ws1.* to null
    call wdatc002(param.usrtip,
                  param.webusrcod,
                  param.sesnum,
                  param.macsissgl)
                  returning ws1.*

    if ws1.statusprc <> 0 then
        display "NOSESS@@Por questões de segurança seu tempo de<BR> permanência nesta página atingiu o limite máximo.@@"
        exit program(0)
    end if

    call cts40g03_data_hora_banco(2) returning l_today, l_time

    if param.aerciacod is not null then

       call cts10g04_ultima_etapa(param.atdsrvnum, param.atdsrvano)
            returning l_atdetpcod

       call ctc11g00_aviao
             (param.atdsrvnum, param.atdsrvano, param.acao,
              param.aerciacod, param.trpaervoonum, param.trpaerptanum,
              param.trpaerlzdnum, param.adlpsgvlr, param.crnpsgvlr,
              param.totpsgvlr, param.arpembcod, param.trpaersaidat,
              param.trpaersaihor, param.arpchecod, param.trpaerchedat,
              param.trpaerchehor, l_atdetpcod, param.vooopc, param.voocnxseq)
             returning l_atdetpcod
    end if

    call ctc11g00_ver_par(param.atdsrvnum, param.atdsrvano, param.acao,
                          param.vooopc)
         returning l_vooopc, l_voocnxseq

    ## Obter data/hora do voo anterior, se tiver
    call ctc11g00_obter_dados (1, param.atdsrvnum, param.atdsrvano)
         returning l_trpaersaidat, l_trpaersaihor, l_trpaerchedat,
                   l_trpaerchehor

    if l_trpaersaidat is null then
       let l_trpaersaidat = l_today
    end if

    if l_trpaerchedat is null then
       let l_trpaerchedat = l_today
    end if

    display 'DATA@@<input type="hidden" name="dtsaida" value=', l_trpaersaidat, '>@@'
    display 'DATA@@<input type="hidden" name="hrsaida" value=',l_trpaersaihor, '>@@'
    display 'DATA@@<input type="hidden" name="dtchegada" value=', l_trpaerchedat, '>@@'
    display 'DATA@@<input type="hidden" name="hrchegada" value=',l_trpaerchehor, '>@@'

    display "PADRAO@@1@@B@@C@@0@@Informações sobre o vôo@@"

    let ws1.prgsgl = "wdatc0076"

    declare c_datkciaaer cursor for
         select aerciacod, aercianom
           from datkciaaer
           where aercmpsit = "A"
           order by 2

    let l_padrao = "PADRAO@@2@@aerciacod@@Empresa@@0@@0@@@@1@@@@" clipped

    foreach c_datkciaaer into l_aerciacod, l_aercianom
        let l_padrao = l_padrao clipped, l_aercianom clipped ,"@@0@@",l_aerciacod clipped , "@@" clipped
    end foreach

    display l_padrao

    display "PADRAO@@5@@No. do Vôo@@0@@@@@@10@@20@@text@@trpaervoonum@@@@"
    display "PADRAO@@5@@No. do PTA@@0@@@@@@10@@20@@text@@trpaerptanum@@@@"
    display "PADRAO@@5@@No. do Localizador@@0@@@@@@10@@20@@text@@trpaerlzdnum@@@@"
    ###display "PADRAO@@5@@Valor Passagem Adulto@@0@@@@@@8@@10@@text@@adlpsgvlr@@@@return func_adlpsgvlr()@@"

    display 'PADRAO2@@',
            '<table cellpadding="0" width="550" cellspacing="1" border="0"> <tr><td width="29%" align="left" height="23" bgcolor="#A8CDEC">',
            '<font size="1" face="ARIAL,HELVETICA,VERDANA">Valor passagem adulto</font> </td> <td width="71%" align="left" height="23" bgcolor="#D7E7F1">',
            '<input type="text" name="adlpsgvlr"  size="8" maxlength="10" type="text" onBlur="return func_adlpsgvlr()"> </td> </tr> </table> @@'

    ##display "PADRAO@@5@@Valor Passagem Criança@@0@@@@@@8@@10@@text@@crnpsgvlr@@ @@return func_crnpsgvlr()@@"

    display 'PADRAO2@@',
            '<table cellpadding="0" width="550" cellspacing="1" border="0"> <tr><td width="29%" align="left" height="23" bgcolor="#A8CDEC">',
            ' <font size="1" face="ARIAL,HELVETICA,VERDANA">Valor passagem crianga</font> </td> <td width="71%" align="left" height="23" bgcolor="#D7E7F1">',
            ' <input type="text" name="crnpsgvlr"  size="8" maxlength="10" type="text" onBlur="return func_crnpsgvlr()"> </td> </tr> </table> @@'

     let l_msg = null
     let l_valor = null

     call cts10g06_dados_servicos (10, param.atdsrvnum, param.atdsrvano)
           returning  l_resultado, l_mensagem, l_ciaempcod

     if l_ciaempcod = 1 then

        let l_asimtvcod = null
          select asimtvcod into l_asimtvcod
             from datmassistpassag
            where atdsrvnum = param.atdsrvnum and
                  atdsrvano = param.atdsrvano

        if l_asimtvcod = 3 then
           let l_msg = "'LIMITE DE COBERTURA RESTRITO AO VALOR DE UMA PASSAGEM "
                       ,"AÉREA NA CLASSE ECONÔMICA'"
        else
           call cts45g00_limites_cob(1,param.atdsrvnum, param.atdsrvano,
                                    "","","", 10 , "",l_asimtvcod, 1,0)
                returning l_valor

           if l_valor > 0 then
              let l_msg = "'LIMITE DE COBERTURA RESTRITO AO VALOR MAXIMO DE R$ "
                          , l_valor, "'"
           else
              let l_msg = "0"
           end if
        end if
    else
       let l_msg = "0"
    end if

    display 'PADRAO2@@',
            '<table cellpadding="0" width="550" cellspacing="1" border="0"> <tr><td width="29%" align="left" height="23" bgcolor="#A8CDEC">',
            '<font size="1" face="ARIAL,HELVETICA,VERDANA">Valor total</font> </td> <td width="71%" align="left" height="23" bgcolor="#D7E7F1">',
            '<input type="text" name="totpsgvlr"  size="8" maxlength="10" type="text" onBlur="return func_totpsgvlr(', l_msg clipped, ')"> </td> </tr> </table>  @@'

    display "PADRAO@@1@@B@@C@@0@@Embarque@@"

    #let l_cmd = ' select ufdcod, ufdnom from glakest ',
    #          ' order by 2 '
    #prepare cmd2 from l_cmd
    #declare c_glakest cursor for cmd2

    #let l_padrao = "PADRAO@@2@@ufdcodemb@@Estado@@0@@0@@@@1@@@@" clipped

    #foreach c_glakest into l_ufdcod, l_ufdnom
    #    let l_padrao = l_padrao clipped, l_ufdnom clipped ,"@@0@@",l_ufdcod clipped , "@@" clipped
    #end foreach

    #display l_padrao

    let l_cmd = ' select arpcod, arpnom from datkaeroporto ',
              ' where arpsitcod = 1 '

    prepare cmd3 from l_cmd
    declare c_datkaeroporto cursor for cmd3

    let l_padrao = "PADRAO@@2@@arpembcod@@Aeroporto@@0@@0@@@@1@@@@" clipped

    foreach c_datkaeroporto into l_arpcod, l_arpnom
        let l_padrao = l_padrao clipped, l_arpnom clipped ,"@@0@@",l_arpcod clipped , "@@" clipped
    end foreach

    display l_padrao

    ###display "PADRAO@@5@@Data do Embarque@@0@@@@(dd/mm/aaaa)@@10@@10@@text@@trpaersaidat@@", l_trpaerchedat, " @@func_saiDat()@@"

    display 'PADRAO2@@',
            '<table cellpadding="0" width="550" cellspacing="1" border="0"> <tr><td width="29%" align="left" height="23" bgcolor="#A8CDEC">',
            '<font size="1" face="ARIAL,HELVETICA,VERDANA">Data do embarque</font> </td> <td width="71%" align="left" height="23" bgcolor="#D7E7F1">',
            '<input type="text" name="trpaersaidat" value="', l_trpaerchedat, '" size="10" maxlength="10" type="text" onblur="return func_saiDat()">',
            '<font size="1" face="ARIAL,HELVETICA,VERDANA">(dd/mm/aaaa)</font> </td> </tr> </table>@@'

    ###display "PADRAO@@5@@Hora do Embarque@@0@@@@0000@@5@@5@@text@@trpaersaihor@@@@func_saiHor()@@"

    display 'PADRAO2@@',
            '<table cellpadding="0" width="550" cellspacing="1" border="0"><tr><td width="29%" align="left" height="23" bgcolor="#A8CDEC">',
            '<font size="1" face="ARIAL,HELVETICA,VERDANA">Hora do embarque</font> </td> <td width="71%" align="left" height="23" bgcolor="#D7E7F1">',
            '<input type="text" name="trpaersaihor"  size="5" maxlength="5" type="text" onBlur="return func_saiHor()"> ',
            '<font size="1" face="ARIAL,HELVETICA,VERDANA">0000</font></td>@@'

    display "PADRAO@@1@@B@@C@@0@@Chegada@@"

    #let l_padrao = "PADRAO@@2@@ufdcodche@@Estado@@0@@0@@@@1@@@@" clipped

    #foreach c_glakest into l_ufdcod, l_ufdnom
    #    let l_padrao = l_padrao clipped, l_ufdnom clipped ,"@@0@@",l_ufdcod clipped , "@@" clipped
    #end foreach

    #display l_padrao

    let l_padrao = "PADRAO@@2@@arpchecod@@Aeroporto@@0@@0@@@@1@@@@" clipped

    foreach c_datkaeroporto into l_arpcod, l_arpnom
        let l_padrao = l_padrao clipped, l_arpnom clipped ,"@@0@@",l_arpcod clipped , "@@" clipped
    end foreach

    display l_padrao

    ##display "PADRAO@@5@@Data da Chegada@@0@@@@(dd/mm/aaaa)@@10@@10@@text@@trpaerchedat@@", l_trpaerchedat, " @@func_cheDat()@@"

    display 'PADRAO2@@',
            '<table cellpadding="0" width="550" cellspacing="1" border="0"> <tr><td width="29%" align="left" height="23" bgcolor="#A8CDEC">',
            '<font size="1" face="ARIAL,HELVETICA,VERDANA">Data da chegada</font> </td> <td width="71%" align="left" height="23" bgcolor="#D7E7F1">',
            '<input type="text" name="trpaerchedat" value="', l_trpaerchedat, '" size="10" maxlength="10" type="text" onBlur="return func_cheDat()">',
            '<font size="1" face="ARIAL,HELVETICA,VERDANA">(dd/mm/aaaa)</font> </td> </tr> </table> @@'

    ##display "PADRAO@@5@@Hora da Chegada@@0@@@@0000@@5@@5@@text@@trpaerchehor@@@@func_cheHor()@@"

    display 'PADRAO2@@',
            '<table cellpadding="0" width="550" cellspacing="1" border="0"> <tr><td width="29%" align="left" height="23" bgcolor="#A8CDEC">',
            '<font size="1" face="ARIAL,HELVETICA,VERDANA">Hora da chegada</font> </td> <td width="71%" align="left" height="23" bgcolor="#D7E7F1">',
            '<input type="text" name="trpaerchehor"  size="5" maxlength="5" type="text" onBlur="return func_cheHor()">',
            '<font size="1" face="ARIAL,HELVETICA,VERDANA">0000</font> </td> </tr> </table> @@'


    #if l_voocnxseq < 3 then
       display "BOTAO@@Com conexão@@",l_vooopc using "<", "@@",l_voocnxseq using "<", "@@"
    #end if

    #if l_vooopc < 3 or l_vooopc = ' ' or l_vooopc is null then
       display "BOTAO@@Cotar mais vôos@@",l_vooopc using "<","@@", l_voocnxseq using "<","@@"
    #end if

    display "BOTAO@@Enviar@@",l_vooopc using "<","@@", l_voocnxseq using "<","@@"
   display 'HIDDEN@@<input type="hidden" name="vooopc" value=', l_vooopc, '>@@'
   display 'HIDDEN@@<input type="hidden" name="voocnxseq" value=', l_voocnxseq, '>@@'

    display 'DATA@@<input type="hidden" name="hoje" value=', l_today, '>@@'
    display 'DATA@@<input type="hidden" name="hora" value=', l_time, '>@@'

  display "PADRAO@@12@@", l_ciaempcod, "@@"

    #------------------------------------
    # ATUALIZA TEMPO DE SESSAO DO USUARIO
    #------------------------------------

    call wdatc003(param.usrtip,
                  param.webusrcod,
                  param.sesnum,
                  param.macsissgl,
                  ws1.*)
        returning l_sttsess

end main


 function fonetica2()

 end function
 
 function conqua59()

 end function
