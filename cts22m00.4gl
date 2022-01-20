#############################################################################
# Nome do Modulo: CTS22M00                                         Marcelo  #
#                                                                  Gilberto #
# Laudo para assistencia a passageiros - hospedagem                Abr/1999 #
#############################################################################
# Alteracoes:                                                               #
#
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 10/06/1999  PSI 7547-7   Gilberto     Permitir digitacao de historico du- #
#                                       rante a inclusao do servico.        #
#---------------------------------------------------------------------------#
# 12/07/1999  CI  1012-0   Gilberto     Retirar critica que impede preen-   #
#                                       chimento do laudo quando domicilio  #
#                                       e ocorrencia forem os mesmos.       #
#---------------------------------------------------------------------------#
# 11/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a   #
#                                       serem excluidos.                    #
#---------------------------------------------------------------------------#
# 27/08/1999               Gilberto     Ampliacao da faixa final (limite)   #
#                                       de 169999 para 174999.              #
#---------------------------------------------------------------------------#
# 10/09/1999  PSI 9119-7   Wagner       Incluir Historico no modulo cts06g03#
#                                       e padroniza gravacao do historico.  #
#---------------------------------------------------------------------------#
# 24/09/1999  PSI 9164-2   Wagner       Bloqueia servico ate o retorno do   #
#                                       historico.(Inclusao)                #
#---------------------------------------------------------------------------#
# 20/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 12/11/1999  PSI 9118-9   Gilberto     Retirada do campo LIGREF.           #
#---------------------------------------------------------------------------#
# 25/11/1999               Gilberto     Inclusao de validacao do ano do     #
#                                       veiculo.                            #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 29/12/1999  Correio      Gilberto     Permitir cortesia para assunto S43  #
#---------------------------------------------------------------------------#
# 09/02/2000  PSI 10260-7  Wagner       Manutencao campo nivel prioridade   #
#                                       do servico.                         #
#---------------------------------------------------------------------------#
# 14/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 05/06/2000  PSI 10865-0  Akio         Gravacao da tabela DATMSERVICO      #
#                                       via funcao                          #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 13/09/2000  PSI 11459-6  Wagner       Adaptacao acionamento servico.      #
#---------------------------------------------------------------------------#
# 25/09/2000  PSI 11253-4  Ruiz         Grava oficina na datmlcl para o     #
#                                       relatorio bdata080.                 #
#---------------------------------------------------------------------------#
# 29/11/2000               Raji         Inclusao do paramentro codigo da    #
#                                       oficina destino para laudos         #
#---------------------------------------------------------------------------#
# 14/02/2001               Raji         Atalho p/ visualizacao Pto Referecia#
#---------------------------------------------------------------------------#
# 16/02/2001  PSI 11254-2  Ruiz         Consulta o Condutor do Veiculo      #
#---------------------------------------------------------------------------#
# 10/10/2001  PSI 14063-5  Wagner       Liberacao clausula 35A igual 035.   #
#---------------------------------------------------------------------------#
# 23/11/2001  PSI 14177-1  Ruiz         Permitir assistencia ao ramo 78     #
#                                       transporte.                         #
#---------------------------------------------------------------------------#
# 23/01/2001  Miriam       Raji         Email e pager de comunicado         #
#---------------------------------------------------------------------------#
# 01/03/2002  Correio      Wagner       Incluir dptsgl psocor na pesquisa.  #
#---------------------------------------------------------------------------#
# 26/07/2002  PSI 15758-9  Ruiz         eliminar a confirmacao de servico   #
#                                       liberado(cts02m06).                 #
#---------------------------------------------------------------------------#
# 10/10/2002  PSI 16258-2  Wagner       Incluir acesso a funcao informativo #
#                                       convenio ctx17g00.                  #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Carlos Ruiz                      OSF : 12718            #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 27/12/2002       #
#  Objetivo       : Alterar Valor maximo para cobertura                     #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 18/09/2003 Julianna,Meta PSI175552 Inibir chamada da funcao ctx17g00 e    #
#                          OSF26077  Inibir codigo entre as linhas 1630-1726#
#---------------------------------------------------------------------------#
# 19/05/2005 Coutelle,Meta PSI191108 Implementado codigo da via (emeviacod) #
#---------------------------------------------------------------------------#
# 20/02/2006 Andrei, Meta  PSi196878 incluir chamada das funcoes            #
#                                    cts22m01_gravar(), cts22m01_selecionar #
#                                    cts22m01_hotel()                       #
#---------------------------------------------------------------------------#
# 06/02/2006 Priscila      Zeladoria Buscar data e hora do banco de dados   #
# 11/12/2006  Ligia Mattge   CT6121350 Chamada do cts40g12 apos os updates  #
# 28/12/2006  Ligia Mattge             Implementacao de m_c24lclpdrcod e    #
#                                      chamada de cts02m00_valida_indexacao #
#---------------------------------------------------------------------------#
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 15/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32            #
#---------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
# 13/08/2009 Sergio Burini     PSI 244236 Inclusão do Sub-Dairro            #
#---------------------------------------------------------------------------#
# 05/01/2010  Amilton                   Projeto sucursal smallint           #
#---------------------------------------------------------------------------#
# 01/10/2012  Raul Biztalking          Retirar empresa 1 fixa p/ funcionario#
#############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   --> 223689

 define d_cts22m00   record
    servico          char (13)                         ,
    c24solnom        like datmligacao.c24solnom        ,
    nom              like datmservico.nom              ,
    doctxt           char (32)                         ,
    corsus           like datmservico.corsus           ,
    cornom           like datmservico.cornom           ,
    cvnnom           char (19)                         ,
    vclcoddig        like datmservico.vclcoddig        ,
    vcldes           like datmservico.vcldes           ,
    vclanomdl        like datmservico.vclanomdl        ,
    vcllicnum        like datmservico.vcllicnum        ,
    vclcordes        char (11)                         ,
#   asitipcod        like datmservico.asitipcod        ,
#   asitipabvdes     like datkasitip.asitipabvdes      ,
    asimtvcod        like datkasimtv.asimtvcod         ,
    asimtvdes        like datkasimtv.asimtvdes         ,
    refatdsrvorg     like datmservico.atdsrvorg        ,
    refatdsrvnum     like datmassistpassag.refatdsrvnum,
    refatdsrvano     like datmassistpassag.refatdsrvano,
    seghospedado     like datmhosped.hspsegsit,
#   hpdlcl           like datmlcl.lclidttxt            ,
#   hpdlgdtxt        char (65)                         ,
#   hpdbrrnom        like datmlcl.lclbrrnom            ,
#   hpdcidnom        like datmlcl.cidnom               ,
#   hpdufdcod        like datmlcl.ufdcod               ,
    hpddiapvsqtd     like datmhosped.hpddiapvsqtd      ,
    hpdqrtqtd        like datmhosped.hpdqrtqtd         ,
    imdsrvflg        char (01)                         ,
    atdprinvlcod     like datmservico.atdprinvlcod     ,
    atdprinvldes     char (06)                         ,
    atdlibflg        like datmservico.atdlibflg        ,
    frmflg           char (01)                         ,
    atdtxt           char (48)                         ,
    atdlibdat        like datmservico.atdlibdat        ,
    atdlibhor        like datmservico.atdlibhor
 end record

 define w_cts22m00   record
    atdsrvnum        like datmservico.atdsrvnum   ,
    atdsrvano        like datmservico.atdsrvano   ,
    vclcorcod        like datmservico.vclcorcod   ,
    lignum           like datrligsrv.lignum       ,
    atdhorpvt        like datmservico.atdhorpvt   ,
    atdpvtretflg     like datmservico.atdpvtretflg,
    atddatprg        like datmservico.atddatprg   ,
    atdhorprg        like datmservico.atdhorprg   ,
    atdlibflg        like datmservico.atdlibflg   ,
    antlibflg        like datmservico.atdlibflg   ,
    atdlibdat        like datmservico.atdlibdat   ,
    atdlibhor        like datmservico.atdlibhor   ,
    atddat           like datmservico.atddat      ,
    atdhor           like datmservico.atdhor      ,
    cnldat           like datmservico.cnldat      ,
    atdfnlhor        like datmservico.atdfnlhor   ,
    atdfnlflg        like datmservico.atdfnlflg   ,
    atdetpcod        like datmsrvacp.atdetpcod    ,
    atdprscod        like datmservico.atdprscod   ,
    c24opemat        like datmservico.c24opemat   ,
    c24nomctt        like datmservico.c24nomctt   ,
    atdcstvlr        like datmservico.atdcstvlr   ,
    ligcvntip        like datmligacao.ligcvntip   ,
    ano              char (02)                    ,
    data             char (10)                    ,
    hora             char (05)                    ,
    funmat           like datmservico.funmat      ,
    atddmccidnom     like datmassistpassag.atddmccidnom,
    atddmcufdcod     like datmassistpassag.atddmcufdcod,
    atdocrcidnom     like datmlcl.cidnom,
    atdocrufdcod     like datmlcl.ufdcod,
    atddstcidnom     like datmassistpassag.atddstcidnom,
    atddstufdcod     like datmassistpassag.atddstufdcod,
    operacao         char (01)                     ,
    atdrsdflg        like datmservico.atdrsdflg
 end record

 define a_cts22m00   array[2] of record
    operacao         char (01)                    ,
    lclidttxt        like datmlcl.lclidttxt       ,
    lgdtxt           char (65)                    ,
    lgdtip           like datmlcl.lgdtip          ,
    lgdnom           like datmlcl.lgdnom          ,
    lgdnum           like datmlcl.lgdnum          ,
    brrnom           like datmlcl.brrnom          ,
    lclbrrnom        like datmlcl.lclbrrnom       ,
    endzon           like datmlcl.endzon          ,
    cidnom           like datmlcl.cidnom          ,
    ufdcod           like datmlcl.ufdcod          ,
    lgdcep           like datmlcl.lgdcep          ,
    lgdcepcmp        like datmlcl.lgdcepcmp       ,
    lclltt           like datmlcl.lclltt          ,
    lcllgt           like datmlcl.lcllgt          ,
    dddcod           like datmlcl.dddcod          ,
    lcltelnum        like datmlcl.lcltelnum       ,
    lclcttnom        like datmlcl.lclcttnom       ,
    lclrefptotxt     like datmlcl.lclrefptotxt    ,
    c24lclpdrcod     like datmlcl.c24lclpdrcod    ,
    ofnnumdig        like sgokofi.ofnnumdig       ,
    emeviacod        like datmlcl.emeviacod       ,
    celteldddcod     like datmlcl.celteldddcod    ,
    celtelnum        like datmlcl.celtelnum       ,
    endcmp           like datmlcl.endcmp
 end record

 define arr_aux      smallint

 define a_passag     array[15] of record
    pasnom           like datmpassageiro.pasnom,
    pasidd           like datmpassageiro.pasidd
 end record

 define
   aux_today         char (10),
   aux_hora          char (05),
   ws_cgccpfnum      like aeikcdt.cgccpfnum,
   ws_cgccpfdig      like aeikcdt.cgccpfdig,
   m_resultado       smallint  ,
   m_mensagem        char(100)  ,
   m_srv_acionado    smallint


 define mr_hotel record
                 hsphotnom     like datmhosped.hsphotnom
                ,hsphotend     like datmhosped.hsphotend
                ,hsphotbrr     like datmhosped.hsphotbrr
                ,hsphotuf      like datmhosped.hsphotuf
                ,hsphotcid     like datmhosped.hsphotcid
                ,hsphottelnum  like datmhosped.hsphottelnum
                ,hsphotcttnom  like datmhosped.hsphotcttnom
                ,hsphotdiavlr  like datmhosped.hsphotdiavlr
                ,hsphotacmtip  like datmhosped.hsphotacmtip
                ,obsdes        like datmhosped.obsdes
                ,hsphotrefpnt  like datmhosped.hsphotrefpnt
             end record

 define m_c24lclpdrcod like datmlcl.c24lclpdrcod

 define m_clscod    like abbmclaus.clscod
 define m_extenso   char(20)
 define m_asitipcod like datmservico.asitipcod

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

define m_retctb83m00 smallint ##PSI207233



#---------------------------------------------------------------
 function cts22m00()
#---------------------------------------------------------------

 define ws           record
    vclchsinc        like abbmveic.vclchsinc,
    vclchsfnl        like abbmveic.vclchsfnl,
    confirma         char (01),
    grvflg           smallint
 end record

#--------------------------------#
 define l_data       date,
        l_hora2      datetime hour to minute




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  ws.*  to  null

  let g_documento.atdsrvorg = 3
#--------------------------------#

 let int_flag   = false

 initialize d_cts22m00.* to null
 initialize w_cts22m00.* to null
 initialize ws.*         to null
 initialize mr_hotel to null

 initialize a_cts22m00   to null
 initialize a_passag     to null
 initialize m_subbairro  to null

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2

 let aux_today       = l_data
 let aux_hora        = l_hora2
 let w_cts22m00.data = l_data
 let w_cts22m00.hora = l_hora2
 let w_cts22m00.ano  = w_cts22m00.data[9,10]
 let m_resultado = null
 let m_mensagem = null
 let m_srv_acionado = false
 let m_c24lclpdrcod = null

 open window cts22m00 at 04,02 with form "cts22m00"
                      attribute(form line 1)

 display "/" at 7,50
 display "-" at 7,58
 let w_cts22m00.ligcvntip = g_documento.ligcvntip

#---------------------------------------------------------------
# Identificacao do CONVENIO
#---------------------------------------------------------------

 select cpodes into d_cts22m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = w_cts22m00.ligcvntip

 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  then
    call consulta_cts22m00()

    display by name d_cts22m00.*
    display by name d_cts22m00.c24solnom attribute (reverse)
    display by name d_cts22m00.cvnnom    attribute (reverse)
    display by name mr_hotel.hsphotnom
                   ,mr_hotel.hsphotbrr
                   ,mr_hotel.hsphotcid
                   ,mr_hotel.hsphotrefpnt
                   ,mr_hotel.hsphottelnum
                   ,mr_hotel.hsphotcttnom


#    display by name a_cts22m00[1].lgdtxt,
#                    a_cts22m00[1].lclbrrnom,
#                    a_cts22m00[1].cidnom,
#                    a_cts22m00[1].ufdcod,
#                    a_cts22m00[1].lclrefptotxt,
#                    a_cts22m00[1].endzon,
#                    a_cts22m00[1].dddcod,
#                    a_cts22m00[1].lcltelnum,
#                    a_cts22m00[1].lclcttnom

    if d_cts22m00.atdlibflg = "N"   then
       display by name d_cts22m00.atdlibdat attribute (invisible)
       display by name d_cts22m00.atdlibhor attribute (invisible)
    end if

    if w_cts22m00.atdfnlflg = "S"  then
       error " Atencao! Servico ja' acionado!"
       let m_srv_acionado = true
    end if

    call modifica_cts22m00() returning ws.grvflg

    if ws.grvflg = false  then
       initialize g_documento.acao to null
    end if

    if g_documento.acao is not null then
       call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                     g_issk.funmat, w_cts22m00.data, w_cts22m00.hora)

       let g_rec_his = true
    end if
 else
    if g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  and
       g_documento.itmnumdig is not null  then

#---------------------------------------------------------------
# Verifica se apolice tem clausula 35, 55 ou 35A se nao for cortesia
#---------------------------------------------------------------
       if g_documento.c24astcod <> "S43"  then
          call f_funapol_ultima_situacao
               (g_documento.succod,g_documento.aplnumdig,g_documento.itmnumdig)
            returning g_funapol.*

          if g_documento.ramcod <> 78    and  # transporte
            (g_documento.ramcod <> 171   or   # transporte
             g_documento.ramcod <> 195 ) then # Garantia Estendida
             select clscod into m_clscod from abbmclaus  --varani
              where succod    = g_documento.succod    and
                    aplnumdig = g_documento.aplnumdig and
                    itmnumdig = g_documento.itmnumdig and
                    dctnumseq = g_funapol.dctnumseq   and
                    clscod   in ("033","33R","035","35A","35R","055","044","046","048","44R","46R","047","47R","48R")
                    ##clscod   in ("035","055","35A")

             if sqlca.sqlcode = notfound  then
                call cts08g01("A","N","NAO E' POSSIVEL REALIZAR A ASSISTENCIA!",
                                  " ","CLAUSULA ASSISTENCIA 24 HORAS COMPLETA",
                                      "NAO FOI CONTRATADA PARA ESTA APOLICE!")
                     returning ws.confirma
                close window cts22m00
                return
             end if
          end if
       end if

       let d_cts22m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&", #"&&",projeto succod
                                        " ", g_documento.ramcod    using "##&&",
                                  " ", g_documento.aplnumdig using "<<<<<<<& &"

       call cts05g00 (g_documento.succod   ,
                      g_documento.ramcod   ,
                      g_documento.aplnumdig,
                      g_documento.itmnumdig)
            returning d_cts22m00.nom      ,
                      d_cts22m00.corsus   ,
                      d_cts22m00.cornom   ,
                      d_cts22m00.cvnnom   ,
                      d_cts22m00.vclcoddig,
                      d_cts22m00.vcldes   ,
                      d_cts22m00.vclanomdl,
                      d_cts22m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      d_cts22m00.vclcordes
    end if

    if g_documento.prporg    is not null  and
       g_documento.prpnumdig is not null  then

        call figrc072_setTratarIsolamento()        --> 223689
        call cts05g04 (g_documento.prporg   ,
                      g_documento.prpnumdig)
            returning d_cts22m00.nom      ,
                      d_cts22m00.corsus   ,
                      d_cts22m00.cornom   ,
                      d_cts22m00.cvnnom   ,
                      d_cts22m00.vclcoddig,
                      d_cts22m00.vcldes   ,
                      d_cts22m00.vclanomdl,
                      d_cts22m00.vcllicnum,
                      d_cts22m00.vclcordes
         if g_isoAuto.sqlCodErr <> 0 then --> 223689
            error "Função cts05g04 indisponivel no momento! Avise a Informatica !" sleep 2
            return
         end if    --> 223689


       let d_cts22m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                 " ", g_documento.prpnumdig using "<<<<<<<& &"
    end if

    if g_documento.pcacarnum is not null  and
       g_documento.pcaprpitm is not null  then
       let d_cts22m00.doctxt = "Cartao..: ",
                               g_documento.pcacarnum using "&&&&&&&&&&&&&&&&"

       call cts05g02 (g_documento.pcacarnum,
                      g_documento.pcaprpitm)
            returning d_cts22m00.nom      ,
                      d_cts22m00.corsus   ,
                      d_cts22m00.cornom   ,
                      d_cts22m00.cvnnom   ,
                      d_cts22m00.vclcoddig,
                      d_cts22m00.vcldes   ,
                      d_cts22m00.vclanomdl,
                      d_cts22m00.vcllicnum,
                      ws.vclchsinc        ,
                      ws.vclchsfnl        ,
                      d_cts22m00.vclcordes
    end if

    let d_cts22m00.c24solnom   = g_documento.solnom

    display by name d_cts22m00.*
    display by name d_cts22m00.c24solnom attribute (reverse)
    display by name d_cts22m00.cvnnom    attribute (reverse)

    initialize ws_cgccpfnum, ws_cgccpfdig to null

    call inclui_cts22m00() returning ws.grvflg

    if ws.grvflg = true  then
       call cts10n00(w_cts22m00.atdsrvnum, w_cts22m00.atdsrvano,
                     g_issk.funmat, w_cts22m00.data, w_cts22m00.hora)

       #-----------------------------------------------
       # Envia msg convenio/assunto se houver
       #-----------------------------------------------
       #call ctx17g00_assist(g_documento.ligcvntip,   #psi175552
       #                     g_documento.c24astcod,
       #                     w_cts22m00.atdsrvnum ,
       #                     w_cts22m00.atdsrvano ,
       #                     g_documento.lignum   ,
       #                     g_documento.succod   ,
       #                     g_documento.ramcod   ,
       #                     g_documento.aplnumdig,
       #                     g_documento.itmnumdig,
       #                     g_documento.prporg   ,
       #                     g_documento.prpnumdig,
       #                     ws_cgccpfnum         ,
       #                     ws_cgccpfdig         )   #fim psi175552

       #-----------------------------------------------
       # Desbloqueio do servico
       #-----------------------------------------------
       if w_cts22m00.atdfnlflg = "N"  or
          w_cts22m00.atdfnlflg = "A" then
          update datmservico set c24opemat = null
                           where atdsrvnum = w_cts22m00.atdsrvnum
                             and atdsrvano = w_cts22m00.atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico.",
                   " AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
             call cts00g07_apos_servdesbloqueia(w_cts22m00.atdsrvnum,w_cts22m00.atdsrvano)
          end if
       end if

    end if
 end if

 close window cts22m00

end function  ###  cts22m00

#---------------------------------------------------------------
 function consulta_cts22m00()
#---------------------------------------------------------------

 define ws           record
    passeq           like datmpassageiro.passeq,
    funmat           like isskfunc.funmat,
    funnom           like isskfunc.funnom,
    dptsgl           like isskfunc.dptsgl,
    codigosql        integer,
    succod           like datrservapol.succod   ,
    ramcod           like datrservapol.ramcod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    edsnumref        like datrservapol.edsnumref,
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig,
    fcapcorg         like datrligpac.fcapacorg,
    fcapacnum        like datrligpac.fcapacnum,
    empcod           like datmservico.empcod                          #Raul, Biz
 end record


 define l_hpddiapvsqtd like datmhosped.hpddiapvsqtd
       ,l_hpdqrtqtd    like datmhosped.hpdqrtqtd


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

 initialize ws.*  to null

 initialize mr_hotel to null

 select nom         ,
        vclcoddig   ,
        vcldes      ,
        vclanomdl   ,
        vcllicnum   ,
        corsus      ,
        cornom      ,
        vclcorcod   ,
        funmat      ,
        atddat      ,
        atdhor      ,
        atdlibflg   ,
        atdlibhor   ,
        atdlibdat   ,
        atdhorpvt   ,
        atdpvtretflg,
        atddatprg   ,
        atdhorprg   ,
        atdfnlflg   ,
#        asitipcod   ,
        atdcstvlr   ,
        atdprinvlcod,
        ciaempcod,
        empcod                                                        #Raul, Biz
   into d_cts22m00.nom      ,
        d_cts22m00.vclcoddig,
        d_cts22m00.vcldes   ,
        d_cts22m00.vclanomdl,
        d_cts22m00.vcllicnum,
        d_cts22m00.corsus   ,
        d_cts22m00.cornom   ,
        w_cts22m00.vclcorcod,
        ws.funmat           ,
        w_cts22m00.atddat   ,
        w_cts22m00.atdhor   ,
        d_cts22m00.atdlibflg,
        d_cts22m00.atdlibhor,
        d_cts22m00.atdlibdat,
        w_cts22m00.atdhorpvt,
        w_cts22m00.atdpvtretflg,
        w_cts22m00.atddatprg,
        w_cts22m00.atdhorprg,
        w_cts22m00.atdfnlflg,
#        d_cts22m00.asitipcod,
        w_cts22m00.atdcstvlr,
        d_cts22m00.atdprinvlcod,
        g_documento.ciaempcod,
        ws.empcod                                                     #Raul, Biz
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = notfound then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         1)
               returning a_cts22m00[1].lclidttxt   ,
                         a_cts22m00[1].lgdtip      ,
                         a_cts22m00[1].lgdnom      ,
                         a_cts22m00[1].lgdnum      ,
                         a_cts22m00[1].lclbrrnom   ,
                         a_cts22m00[1].brrnom      ,
                         a_cts22m00[1].cidnom      ,
                         a_cts22m00[1].ufdcod      ,
                         a_cts22m00[1].lclrefptotxt,
                         a_cts22m00[1].endzon      ,
                         a_cts22m00[1].lgdcep      ,
                         a_cts22m00[1].lgdcepcmp   ,
                         a_cts22m00[1].lclltt      ,
                         a_cts22m00[1].lcllgt      ,
                         a_cts22m00[1].dddcod      ,
                         a_cts22m00[1].lcltelnum   ,
                         a_cts22m00[1].lclcttnom   ,
                         a_cts22m00[1].c24lclpdrcod,
                         a_cts22m00[1].celteldddcod,
                         a_cts22m00[1].celtelnum   ,
                         a_cts22m00[1].endcmp ,
                         ws.codigosql              ,
                         a_cts22m00[1].emeviacod
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts22m00[1].lclbrrnom

 call cts06g10_monta_brr_subbrr(a_cts22m00[1].brrnom,
                                a_cts22m00[1].lclbrrnom)
      returning a_cts22m00[1].lclbrrnom
 select ofnnumdig into a_cts22m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.codigosql <> 0  then
    error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local",
          " de ocorrencia. AVISE A INFORMATICA!"
    return
 end if

 let a_cts22m00[1].lgdtxt = a_cts22m00[1].lgdtip clipped, " ",
                            a_cts22m00[1].lgdnom clipped, " ",
                            a_cts22m00[1].lgdnum using "<<<<#"

#####
##--------------------------------------------------------------------
## Informacoes do local de destino
##--------------------------------------------------------------------
# if w_cts22m00.atdfnlflg = "S"  then
#    call ctx04g00_local_gps(g_documento.atdsrvnum,
#                            g_documento.atdsrvano,
#                            3)
#                  returning a_cts22m00[2].lclidttxt   ,
#                            a_cts22m00[2].lgdtip      ,
#                            a_cts22m00[2].lgdnom      ,
#                            a_cts22m00[2].lgdnum      ,
#                            a_cts22m00[2].lclbrrnom   ,
#                            a_cts22m00[2].brrnom      ,
#                            a_cts22m00[2].cidnom      ,
#                            a_cts22m00[2].ufdcod      ,
#                            a_cts22m00[2].lclrefptotxt,
#                            a_cts22m00[2].endzon      ,
#                            a_cts22m00[2].lgdcep      ,
#                            a_cts22m00[2].lgdcepcmp   ,
#                            a_cts22m00[2].lclltt      ,
#                            a_cts22m00[2].lcllgt      ,
#                            a_cts22m00[2].dddcod      ,
#                            a_cts22m00[2].lcltelnum   ,
#                            a_cts22m00[2].lclcttnom   ,
#                            a_cts22m00[2].c24lclpdrcod,
#                            ws.codigosql               ,
#                            a_cts22m00[2].emeviacod
#
# select ofnnumdig into a_cts22m00[2].ofnnumdig
#   from datmlcl
#  where atdsrvano = g_documento.atdsrvano
#    and atdsrvnum = g_documento.atdsrvnum
#    and c24endtip = 2
#
#    if ws.codigosql = 0  then
#       let a_cts22m00[2].lgdtxt = a_cts22m00[2].lgdtip clipped, " ",
#                                  a_cts22m00[2].lgdnom clipped, " ",
#                                  a_cts22m00[2].lgdnum using "<<<<#"
#
##       let d_cts22m00.hpdlcl    = a_cts22m00[2].lclidttxt
##       let d_cts22m00.hpdlgdtxt = a_cts22m00[2].lgdtxt
##       let d_cts22m00.hpdbrrnom = a_cts22m00[2].lclbrrnom
##       let d_cts22m00.hpdcidnom = a_cts22m00[2].cidnom
##       let d_cts22m00.hpdufdcod = a_cts22m00[2].ufdcod
#    else
#       error " Erro (", ws.codigosql using "<<<<<&", ") na leitura do local",
#             " de destino. AVISE A INFORMATICA!"
#       return
#    end if
# end if
#####

# let d_cts22m00.asitipabvdes = "NAO PREV"
#
# select asitipabvdes
#   into d_cts22m00.asitipabvdes
#   from datkasitip
#  where asitipcod = d_cts22m00.asitipcod

#---------------------------------------------------------------
# Obtencao dos dados da ASSISTENCIA A PASSAGEIROS
#---------------------------------------------------------------

 select datmassistpassag.refatdsrvnum,
        datmassistpassag.refatdsrvano,
        datmassistpassag.asimtvcod   ,
#        datmassistpassag.atddstcidnom,
#        datmassistpassag.atddstufdcod,
        datmhosped.hpddiapvsqtd      ,
        datmhosped.hpdqrtqtd         ,
        datmservico.atdsrvorg,
        datmhosped.hspsegsit
   into d_cts22m00.refatdsrvnum      ,
        d_cts22m00.refatdsrvano      ,
        d_cts22m00.asimtvcod         ,
#        d_cts22m00.hpdcidnom         ,
#        d_cts22m00.hpdufdcod         ,
        d_cts22m00.hpddiapvsqtd      ,
        d_cts22m00.hpdqrtqtd         ,
        d_cts22m00.refatdsrvorg, d_cts22m00.seghospedado
   from datmassistpassag, datmhosped, outer datmservico
  where datmassistpassag.atdsrvnum = g_documento.atdsrvnum  and
        datmassistpassag.atdsrvano = g_documento.atdsrvano  and
        datmassistpassag.atdsrvnum = datmhosped.atdsrvnum   and
        datmassistpassag.atdsrvano = datmhosped.atdsrvano   and
        datmservico.atdsrvnum = datmassistpassag.refatdsrvnum and
        datmservico.atdsrvano = datmassistpassag.refatdsrvano

 if sqlca.sqlcode = notfound then
    error " Assistencia a passageiros nao encontrado. AVISE A INFORMATICA!"
    return
 end if

#---------------------------------------------------------------
# Identificacao do MOTIVO DA ASSISTENCIA
#---------------------------------------------------------------

 let d_cts22m00.asimtvdes = "*** NAO PREVISTO ***"

 select asimtvdes
   into d_cts22m00.asimtvdes
   from datkasimtv
  where asimtvcod = d_cts22m00.asimtvcod

#---------------------------------------------------------------
# Relacao dos passageiros
#---------------------------------------------------------------
 declare ccts22m00001 cursor for
    select pasnom, pasidd, passeq
      from datmpassageiro
     where atdsrvnum = g_documento.atdsrvnum
       and atdsrvano = g_documento.atdsrvano
     order by passeq

 let arr_aux = 1

 foreach ccts22m00001 into a_passag[arr_aux].pasnom,
                               a_passag[arr_aux].pasidd,
                               ws.passeq
    let arr_aux = arr_aux + 1

    if arr_aux > 15  then
       error " Limite excedido. Foram encontrados mais de 15 passageiros!"
       exit foreach
    end if
 end foreach

#---------------------------------------------------------------
# Identificacao do CONVENIO
#---------------------------------------------------------------

 let w_cts22m00.lignum = cts20g00_servico(g_documento.atdsrvnum,
                                          g_documento.atdsrvano)

 call cts20g01_docto(w_cts22m00.lignum)
      returning g_documento.succod,
                g_documento.ramcod,
                g_documento.aplnumdig,
                g_documento.itmnumdig,
                g_documento.edsnumref,
                g_documento.prporg,
                g_documento.prpnumdig,
                g_documento.fcapacorg,
                g_documento.fcapacnum,
                g_documento.itaciacod

 if g_documento.succod    is not null  and
    g_documento.ramcod    is not null  and
    g_documento.aplnumdig is not null  then
    let d_cts22m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&", #"&&", projeto succod
                                     " ", g_documento.ramcod    using "##&&",
                                   " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 if  g_documento.prporg    is not null  and
     g_documento.prpnumdig is not null  then
    let d_cts22m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                   " ", g_documento.prpnumdig using "<<<<<<<& &"
 end if

 select ligcvntip,
        c24solnom, c24astcod
   into w_cts22m00.ligcvntip,
        d_cts22m00.c24solnom, g_documento.c24astcod
   from datmligacao
  where lignum = w_cts22m00.lignum

 select lignum
   from datmligfrm
  where lignum = w_cts22m00.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts22m00.frmflg = "N"
 else
    let d_cts22m00.frmflg = "S"
 end if

 select cpodes into d_cts22m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts22m00.ligcvntip

#---------------------------------------------------------------
# Identificacao do ATENDENTE
#---------------------------------------------------------------

 let ws.funnom = "*** NAO CADASTRADO ***"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod                                            #Raul, Biz
    and funmat = ws.funmat

 let d_cts22m00.atdtxt = w_cts22m00.atddat         clipped, " ",
                         w_cts22m00.atdhor         clipped, " ",
                         upshift(ws.dptsgl)        clipped, " ",
                         ws.funmat using "&&&&&&"  clipped, " ",
                         upshift(ws.funnom)

#---------------------------------------------------------------
# Descricao da COR do veiculo
#---------------------------------------------------------------

 select cpodes
   into d_cts22m00.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = w_cts22m00.vclcorcod

 if w_cts22m00.atdhorpvt is not null  or
    w_cts22m00.atdhorpvt =  "00:00"   then
    let d_cts22m00.imdsrvflg = "S"
 end if

 if w_cts22m00.atddatprg is not null   then
    let d_cts22m00.imdsrvflg = "N"
 end if

 if d_cts22m00.atdlibflg = "N"  then
    let d_cts22m00.atdlibdat = w_cts22m00.atddat
    let d_cts22m00.atdlibhor = w_cts22m00.atdhor
 end if

 let w_cts22m00.antlibflg = d_cts22m00.atdlibflg

 let d_cts22m00.servico = g_documento.atdsrvorg using "&&",
                     "/", g_documento.atdsrvnum using "&&&&&&&",
                     "-", g_documento.atdsrvano using "&&"

 select cpodes
   into d_cts22m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_cts22m00.atdprinvlcod


 call cts22m01_selecionar(1
                         ,g_documento.atdsrvnum
                         ,g_documento.atdsrvano)
     returning m_resultado
              ,m_mensagem
              ,mr_hotel.hsphotnom
              ,mr_hotel.hsphotend
              ,mr_hotel.hsphotbrr
              ,mr_hotel.hsphotuf
              ,mr_hotel.hsphotcid
              ,mr_hotel.hsphottelnum
              ,mr_hotel.hsphotcttnom
              ,mr_hotel.hsphotdiavlr
              ,mr_hotel.hsphotacmtip
              ,mr_hotel.obsdes
              ,mr_hotel.hsphotrefpnt
              ,l_hpddiapvsqtd
              ,l_hpdqrtqtd

 let m_c24lclpdrcod = a_cts22m00[1].c24lclpdrcod

end function  ###  consulta_cts22m00

#---------------------------------------------------------------
 function modifica_cts22m00()
#---------------------------------------------------------------

 define ws           record
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    passeq           like datmpassageiro.passeq,
    errflg           smallint,
    codigosql        integer
 end record

 define hist_cts22m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define prompt_key   char (01)
 define w_retorno    smallint

 define l_data       date,
        l_hora2      datetime hour to minute


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     prompt_key  =  null
        let     w_retorno  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  hist_cts22m00.*  to  null

        let     prompt_key  =  null
        let     w_retorno  =  null

        initialize  ws.*  to  null

        initialize  hist_cts22m00.*  to  null

 initialize ws.*  to null

 call input_cts22m00() returning hist_cts22m00.*

 if d_cts22m00.seghospedado = 'S' then
    call cts22m01_gravar('M'
                        ,g_documento.atdsrvnum
                        ,g_documento.atdsrvano
                        ,d_cts22m00.hpddiapvsqtd
                        ,d_cts22m00.hpdqrtqtd
                        ,mr_hotel.hsphotnom
                        ,mr_hotel.hsphotend
                        ,mr_hotel.hsphotbrr
                        ,mr_hotel.hsphotuf
                        ,mr_hotel.hsphotcid
                        ,mr_hotel.hsphottelnum
                        ,mr_hotel.hsphotcttnom
                        ,mr_hotel.hsphotacmtip
                        ,mr_hotel.obsdes
                        ,mr_hotel.hsphotrefpnt)
      returning m_resultado
               ,m_mensagem

    if m_resultado = 3 then
        error m_mensagem
    end if
 end if

 if g_documento.acao = "CON" then
    return false
 end if

 if m_srv_acionado = true then
    return true
 end if

 if int_flag then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts22m00      to null
    initialize a_passag        to null
    initialize d_cts22m00.*    to null
    initialize w_cts22m00.*    to null
    clear form
    return false
 end if

 whenever error continue

 begin work

 update datmservico set ( nom           ,
                          corsus        ,
                          cornom        ,
                          vclcoddig     ,
                          vcldes        ,
                          vclanomdl     ,
                          vcllicnum     ,
                          vclcorcod     ,
                          atdlibflg     ,
                          atdlibdat     ,
                          atdlibhor     ,
                          atdhorpvt     ,
                          atddatprg     ,
                          atdhorprg     ,
                          atdpvtretflg  ,
                          asitipcod     ,
                          atdprinvlcod  )
                      = ( d_cts22m00.nom,
                          d_cts22m00.corsus,
                          d_cts22m00.cornom,
                          d_cts22m00.vclcoddig,
                          d_cts22m00.vcldes,
                          d_cts22m00.vclanomdl,
                          d_cts22m00.vcllicnum,
                          w_cts22m00.vclcorcod,
                          d_cts22m00.atdlibflg,
                          d_cts22m00.atdlibdat,
                          d_cts22m00.atdlibhor,
                          w_cts22m00.atdhorpvt,
                          w_cts22m00.atddatprg,
                          w_cts22m00.atdhorprg,
                          w_cts22m00.atdpvtretflg,
                          13, #d_cts22m00.asitipcod,
                          d_cts22m00.atdprinvlcod)
                    where atdsrvnum = g_documento.atdsrvnum  and
                          atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados do servico.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 update datmassistpassag set ( refatdsrvnum ,
                               refatdsrvano ,
                               asimtvcod    ,
                               atddmccidnom ,
                               atddmcufdcod ,
                               atddstcidnom ,
                               atddstufdcod )
                           = ( d_cts22m00.refatdsrvnum,
                               d_cts22m00.refatdsrvano,
                               d_cts22m00.asimtvcod   ,
                               w_cts22m00.atddmccidnom,
                               w_cts22m00.atddmcufdcod,
                               w_cts22m00.atddstcidnom,
                               w_cts22m00.atddstufdcod)
                         where atdsrvnum = g_documento.atdsrvnum  and
                               atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados da assistencia.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 update datmhosped set (hpddiapvsqtd,
                        hpdqrtqtd   )
                     = (d_cts22m00.hpddiapvsqtd,
                        d_cts22m00.hpdqrtqtd   )
                  where atdsrvnum = g_documento.atdsrvnum  and
                        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao dos dados da hospedagem.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 delete from datmpassageiro
  where atdsrvnum = g_documento.atdsrvnum
    and atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na substituicao da relacao de",
          " passageiros. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 for arr_aux = 1 to 15
    if a_passag[arr_aux].pasnom is null  or
       a_passag[arr_aux].pasidd is null  then
       exit for
    end if

    initialize ws.passeq to null

    select max(passeq)
      into ws.passeq
      from datmpassageiro
     where atdsrvnum = g_documento.atdsrvnum  and
           atdsrvano = g_documento.atdsrvano

    if sqlca.sqlcode < 0  then
       error " Erro (", sqlca.sqlcode, ") na localizacao do ultimo",
             " passageiro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if

    if ws.passeq is null  then
       let ws.passeq = 0
    end if

    let ws.passeq = ws.passeq + 1

    insert into datmpassageiro (atdsrvnum,
                                atdsrvano,
                                passeq,
                                pasnom,
                                pasidd)
                        values (g_documento.atdsrvnum,
                                g_documento.atdsrvano,
                                ws.passeq,
                                a_passag[arr_aux].pasnom,
                                a_passag[arr_aux].pasidd)

    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao do ",
               arr_aux using "<&", "o. passageiro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 for arr_aux = 1 to 1
    if a_cts22m00[arr_aux].operacao is null  then
       let a_cts22m00[arr_aux].operacao = "M"
    end if
    let a_cts22m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

    call cts06g07_local(a_cts22m00[arr_aux].operacao,
                        g_documento.atdsrvnum,
                        g_documento.atdsrvano,
                        arr_aux,
                        a_cts22m00[arr_aux].lclidttxt,
                        a_cts22m00[arr_aux].lgdtip,
                        a_cts22m00[arr_aux].lgdnom,
                        a_cts22m00[arr_aux].lgdnum,
                        a_cts22m00[arr_aux].lclbrrnom,
                        a_cts22m00[arr_aux].brrnom,
                        a_cts22m00[arr_aux].cidnom,
                        a_cts22m00[arr_aux].ufdcod,
                        a_cts22m00[arr_aux].lclrefptotxt,
                        a_cts22m00[arr_aux].endzon,
                        a_cts22m00[arr_aux].lgdcep,
                        a_cts22m00[arr_aux].lgdcepcmp,
                        a_cts22m00[arr_aux].lclltt,
                        a_cts22m00[arr_aux].lcllgt,
                        a_cts22m00[arr_aux].dddcod,
                        a_cts22m00[arr_aux].lcltelnum,
                        a_cts22m00[arr_aux].lclcttnom,
                        a_cts22m00[arr_aux].c24lclpdrcod,
                        a_cts22m00[arr_aux].ofnnumdig,
                        a_cts22m00[arr_aux].emeviacod,
                        a_cts22m00[arr_aux].celteldddcod,
                        a_cts22m00[arr_aux].celtelnum,
                        a_cts22m00[arr_aux].endcmp )
              returning ws.codigosql

    if ws.codigosql is null   or
       ws.codigosql <> 0      then
       error " Erro (", ws.codigosql, ") na alteracao do local de ocorrencia.",
             " AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end for

 if w_cts22m00.antlibflg <> d_cts22m00.atdlibflg  then
    if d_cts22m00.atdlibflg = "S"  then
       let w_cts22m00.atdetpcod = 1
       let ws.atdetpdat = d_cts22m00.atdlibdat
       let ws.atdetphor = d_cts22m00.atdlibhor
    else
       let w_cts22m00.atdetpcod = 2
       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       let ws.atdetpdat = l_data
       let ws.atdetphor = l_hora2
    end if

    call cts10g04_insere_etapa(g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               w_cts22m00.atdetpcod,
                               " ",
                               " ",
                               " ",
                               " ") returning w_retorno



    if w_retorno <> 0 then
       error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de",
             " acompanhamento. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end if

 whenever error stop

 commit work
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                             g_documento.atdsrvano)

  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts22m00[1].cidnom,
                          a_cts22m00[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         g_documento.c24astcod,
                                         13,   #d_cts22m00.asitipcod,
                                         a_cts22m00[1].lclltt,
                                         a_cts22m00[1].lcllgt,
                                         "",
                                         d_cts22m00.frmflg,
                                         g_documento.atdsrvnum,
                                         g_documento.atdsrvano,
                                         " ",
                                         "", "") then
        #servico nao pode ser acionado automaticamente
        #display "Servico acionado manual"
     else
        #display "Servico foi para acionamento automatico!!"
     end if
  end if

 ###call cts02m00_valida_indexacao(g_documento.atdsrvnum,
 ###                                g_documento.atdsrvano,
 ###                                m_c24lclpdrcod,
 ###                                a_cts22m00[1].c24lclpdrcod)

 return true

end function  ###  modifica_cts22m00

#-------------------------------
 function inclui_cts22m00()
#-------------------------------

 define ws              record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,

        caddat           like datmligfrm.caddat    ,
        cadhor           like datmligfrm.cadhor    ,
        cademp           like datmligfrm.cademp    ,
        cadmat           like datmligfrm.cadmat    ,
        atdetpdat        like datmsrvacp.atdetpdat ,
        atdetphor        like datmsrvacp.atdetphor ,
        etpfunmat        like datmsrvacp.funmat    ,
        atdsrvseq        like datmsrvacp.atdsrvseq ,
        passeq           like datmpassageiro.passeq,
        ano              char (02)                 ,
        hoje            char (10)                 ,
        histerr          smallint                  ,
        cdtnom          like aeikcdt.cdtnom        ,  # ruiz
        cgccpfnum       like aeikcdt.cgccpfnum     ,
        cgccpfdig       like aeikcdt.cgccpfdig     ,
        cdtseq          like aeikcdt.cdtseq        ,
        c24trxnum       like dammtrx.c24trxnum     ,  # Msg pager/email
        lintxt          like dammtrxtxt.c24trxtxt
 end record

 define hist_cts22m00    record
        hist1            like datmservhist.c24srvdsc,
        hist2            like datmservhist.c24srvdsc,
        hist3            like datmservhist.c24srvdsc,
        hist4            like datmservhist.c24srvdsc,
        hist5            like datmservhist.c24srvdsc
 end record
 define lr_clausula record
         erro     smallint,
         msg      char(300),
         clscod   like datrsrvcls.clscod
 end record

 define l_data       date,
        l_hora2      datetime hour to minute




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  hist_cts22m00.*  to  null

        initialize  ws.*  to  null

        initialize  hist_cts22m00.*  to  null
        initialize  lr_clausula.*  to  null

 while true
   initialize ws.*  to null

   let g_documento.acao = "INC"
   let w_cts22m00.operacao = "i"

   call input_cts22m00() returning hist_cts22m00.*

   if  int_flag then
       let int_flag  =  false
       initialize a_cts22m00      to null
       initialize a_passag        to null
       initialize d_cts22m00.*    to null
       initialize w_cts22m00.*    to null
       initialize hist_cts22m00.* to null
       initialize ws.*            to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if

   call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
   if  w_cts22m00.data is null  or
       w_cts22m00.hora is null  then
       let w_cts22m00.data   = l_data
       let w_cts22m00.hora   = l_hora2
   end if

   if  w_cts22m00.funmat is null  then
       let w_cts22m00.funmat = g_issk.funmat
   end if

   if  d_cts22m00.frmflg = "S"  then
       let ws.caddat = l_data
       let ws.cadhor = l_hora2
       let ws.cademp = g_issk.empcod
       let ws.cadmat = g_issk.funmat
   else
       initialize ws.caddat to null
       initialize ws.cadhor to null
       initialize ws.cademp to null
       initialize ws.cadmat to null
   end if

   let ws.hoje  = l_data
   let ws.ano    = ws.hoje[9,10]


   if  w_cts22m00.atdfnlflg is null  then
       let w_cts22m00.atdfnlflg = "N"
       let w_cts22m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if

 #------------------------------------------------------------------------------
 # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
 #------------------------------------------------------------------------------
 if g_documento.lclocodesres = "S" then
    let w_cts22m00.atdrsdflg = "S"
 else
    let w_cts22m00.atdrsdflg = "N"
 end if

 #------------------------------------------------------------------------------
 # Busca clausula
 #------------------------------------------------------------------------------

  if g_documento.ramcod = 531 then
     call cty05g00_clausula_assunto(g_documento.c24astcod)
          returning lr_clausula.*
  end if
 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "H" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

   if  ws.codigosql = 0  then
       commit work
   else
       let ws.msg = "CTS22M00 - ",ws.msg
       call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   let g_documento.lignum   = ws.lignum
   let w_cts22m00.atdsrvnum = ws.atdsrvnum
   let w_cts22m00.atdsrvano = ws.atdsrvano

   if d_cts22m00.seghospedado = 'S' then
      call cts22m01_gravar('I'
                          ,w_cts22m00.atdsrvnum
                          ,w_cts22m00.atdsrvano
                          ,d_cts22m00.hpddiapvsqtd
                          ,d_cts22m00.hpdqrtqtd
                          ,mr_hotel.hsphotnom
                          ,mr_hotel.hsphotend
                          ,mr_hotel.hsphotbrr
                          ,mr_hotel.hsphotuf
                          ,mr_hotel.hsphotcid
                          ,mr_hotel.hsphottelnum
                          ,mr_hotel.hsphotcttnom
                          ,mr_hotel.hsphotacmtip
                          ,mr_hotel.obsdes
                          ,mr_hotel.hsphotrefpnt)
      returning m_resultado
               ,m_mensagem

      if m_resultado = 3 then
         error m_mensagem
      end if
   end if


  #-----------------------------------------------------
  # Grava ligacao e servico
  #-----------------------------------------------------
    begin work

    call cts10g00_ligacao ( g_documento.lignum      ,
                            w_cts22m00.data         ,
                            w_cts22m00.hora         ,
                            g_documento.c24soltipcod,
                            g_documento.solnom      ,
                            g_documento.c24astcod   ,
                            w_cts22m00.funmat       ,
                            g_documento.ligcvntip   ,
                            g_c24paxnum             ,
                            ws.atdsrvnum            ,
                            ws.atdsrvano            ,
                            "","","",""             ,
                            g_documento.succod      ,
                            g_documento.ramcod      ,
                            g_documento.aplnumdig   ,
                            g_documento.itmnumdig   ,
                            g_documento.edsnumref   ,
                            g_documento.prporg      ,
                            g_documento.prpnumdig   ,
                            g_documento.fcapacorg   ,
                            g_documento.fcapacnum   ,
                            "","","",""             ,
                            ws.caddat               ,
                            ws.cadhor               ,
                            ws.cademp               ,
                            ws.cadmat                )
         returning ws.tabname,
                   ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


   call cts10g02_grava_servico( w_cts22m00.atdsrvnum,
                                w_cts22m00.atdsrvano,
                                g_documento.soltip  ,     # atdsoltip
                                g_documento.solnom  ,     # c24solnom
                                w_cts22m00.vclcorcod,
                                w_cts22m00.funmat   ,
                                d_cts22m00.atdlibflg,
                                d_cts22m00.atdlibhor,
                                d_cts22m00.atdlibdat,
                                w_cts22m00.data     ,     # atddat
                                w_cts22m00.hora     ,     # atdhor
                                ""                  ,     # atdlclflg
                                w_cts22m00.atdhorpvt,
                                w_cts22m00.atddatprg,
                                w_cts22m00.atdhorprg,
                                "H"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                w_cts22m00.atdprscod,
                                w_cts22m00.atdcstvlr,
                                w_cts22m00.atdfnlflg,
                                w_cts22m00.atdfnlhor,
                                w_cts22m00.atdrsdflg,
                                ""                  ,     # atddfttxt
                                ""                  ,     # atddoctxt
                                w_cts22m00.c24opemat,
                                d_cts22m00.nom      ,
                                d_cts22m00.vcldes   ,
                                d_cts22m00.vclanomdl,
                                d_cts22m00.vcllicnum,
                                d_cts22m00.corsus   ,
                                d_cts22m00.cornom   ,
                                w_cts22m00.cnldat   ,
                                ""                  ,     # pgtdat
                                ""                  ,     # c24nomctt
                                w_cts22m00.atdpvtretflg,
                                ""                  ,     # atdvcltip
                                13,  #d_cts22m00.asitipcod,
                                ""                  ,     # socvclcod
                                d_cts22m00.vclcoddig,
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                d_cts22m00.atdprinvlcod,
                                g_documento.atdsrvorg   ) # ATDSRVORG
        returning ws.tabname,
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

 #------------------------------------------------------------------------------
 # Insere Clausula X Servicos
 #------------------------------------------------------------------------------
   if lr_clausula.clscod is not null then
       call cts10g02_grava_servico_clausula(w_cts22m00.atdsrvnum
                                           ,w_cts22m00.atdsrvano
                                           ,g_documento.ramcod
                                           ,lr_clausula.clscod)
            returning ws.tabname,
                      ws.codigosql
       if  ws.codigosql  <>  0  then
           error " Erro (", ws.codigosql, ") na gravacao da",
                 " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
    end if


  #-----------------------------------------------------------------------------
  # Gravacao dos dados da ASSISTENCIA A PASSAGEIROS
  #-----------------------------------------------------------------------------
    insert into DATMASSISTPASSAG ( atdsrvnum    ,
                                   atdsrvano    ,
                                   bagflg       ,
                                   refatdsrvnum ,
                                   refatdsrvano ,
                                   asimtvcod    ,
                                   atddmccidnom ,
                                   atddmcufdcod ,
                                   atddstcidnom ,
                                   atddstufdcod  )
                          values ( w_cts22m00.atdsrvnum   ,
                                   w_cts22m00.atdsrvano   ,
                                   "N"                    ,
                                   d_cts22m00.refatdsrvnum,
                                   d_cts22m00.refatdsrvano,
                                   d_cts22m00.asimtvcod   ,
                                   w_cts22m00.atddmccidnom,
                                   w_cts22m00.atddmcufdcod,
                                   w_cts22m00.atddstcidnom,
                                   w_cts22m00.atddstufdcod )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " assistencia a passageiro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


#  #-----------------------------------------------------------------------------
#  # Gravacao dos dados da hospedagem
#  #-----------------------------------------------------------------------------
    if d_cts22m00.seghospedado = "N" then

       insert into DATMHOSPED ( atdsrvnum   ,
                                atdsrvano   ,
                                hpddiapvsqtd,
                                hpdqrtqtd,
                                hspsegsit    )
                       values ( w_cts22m00.atdsrvnum   ,
                                w_cts22m00.atdsrvano   ,
                                d_cts22m00.hpddiapvsqtd,
                                d_cts22m00.hpdqrtqtd,
                                d_cts22m00.seghospedado)

      if  sqlca.sqlcode  <>  0  then
          error " Erro (", sqlca.sqlcode, ") na gravacao do",
                " dados da hospedagem. AVISE A INFORMATICA!"
          rollback work
          prompt "" for char ws.prompt_key
          let ws.retorno = false
          exit while
      end if

   end if

 #------------------------------------------------------------------------------
 # Gravacao dos passageiros
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 15
       if  a_passag[arr_aux].pasnom is null  or
           a_passag[arr_aux].pasidd is null  then
           exit for
       end if

       initialize ws.passeq to null

       select max(passeq)
         into ws.passeq
         from DATMPASSAGEIRO
              where atdsrvnum = w_cts22m00.atdsrvnum
                and atdsrvano = w_cts22m00.atdsrvano

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na selecao do",
                 " ultimo hospede. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if

       if  ws.passeq is null  then
           let ws.passeq = 0
       end if

       let ws.passeq = ws.passeq + 1

       insert into DATMPASSAGEIRO ( atdsrvnum,
                                    atdsrvano,
                                    passeq   ,
                                    pasnom   ,
                                    pasidd    )
                           values ( w_cts22m00.atdsrvnum    ,
                                    w_cts22m00.atdsrvano    ,
                                    ws.passeq               ,
                                    a_passag[arr_aux].pasnom,
                                    a_passag[arr_aux].pasidd )

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao do",
                 arr_aux using "<&", "o. hospede. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava local de ocorrencia
 #------------------------------------------------------------------------------
   for arr_aux = 1 to 1
       if  a_cts22m00[arr_aux].operacao is null  then
           let a_cts22m00[arr_aux].operacao = "I"
       end if

       let a_cts22m00[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom
       call cts06g07_local( a_cts22m00[arr_aux].operacao    ,
                            w_cts22m00.atdsrvnum            ,
                            w_cts22m00.atdsrvano            ,
                            arr_aux                         ,
                            a_cts22m00[arr_aux].lclidttxt   ,
                            a_cts22m00[arr_aux].lgdtip      ,
                            a_cts22m00[arr_aux].lgdnom      ,
                            a_cts22m00[arr_aux].lgdnum      ,
                            a_cts22m00[arr_aux].lclbrrnom   ,
                            a_cts22m00[arr_aux].brrnom      ,
                            a_cts22m00[arr_aux].cidnom      ,
                            a_cts22m00[arr_aux].ufdcod      ,
                            a_cts22m00[arr_aux].lclrefptotxt,
                            a_cts22m00[arr_aux].endzon      ,
                            a_cts22m00[arr_aux].lgdcep      ,
                            a_cts22m00[arr_aux].lgdcepcmp   ,
                            a_cts22m00[arr_aux].lclltt      ,
                            a_cts22m00[arr_aux].lcllgt      ,
                            a_cts22m00[arr_aux].dddcod      ,
                            a_cts22m00[arr_aux].lcltelnum   ,
                            a_cts22m00[arr_aux].lclcttnom   ,
                            a_cts22m00[arr_aux].c24lclpdrcod,
                            a_cts22m00[arr_aux].ofnnumdig   ,
                            a_cts22m00[arr_aux].emeviacod ,
                            a_cts22m00[arr_aux].celteldddcod,
                            a_cts22m00[arr_aux].celtelnum,
                            a_cts22m00[arr_aux].endcmp )
            returning ws.codigosql

       if  ws.codigosql is null  or
           ws.codigosql <> 0     then
           error " Erro (", ws.codigosql, ") na gravacao do",
                 " local de ocorrencia. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
   end for


 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------
   select max(atdsrvseq)
     into ws.atdsrvseq
     from datmsrvacp
          where atdsrvnum = w_cts22m00.atdsrvnum
            and atdsrvano = w_cts22m00.atdsrvano

   if  ws.atdsrvseq is null  then
       let ws.atdsrvseq = 0
   end if

   if  w_cts22m00.atdetpcod is null  then
       if  d_cts22m00.atdlibflg = "S"  then
           let w_cts22m00.atdetpcod = 1
           let ws.etpfunmat = w_cts22m00.funmat
           let ws.atdetpdat = d_cts22m00.atdlibdat
           let ws.atdetphor = d_cts22m00.atdlibhor
       else
           let w_cts22m00.atdetpcod = 2
           let ws.etpfunmat = w_cts22m00.funmat
           let ws.atdetpdat = w_cts22m00.data
           let ws.atdetphor = w_cts22m00.hora
       end if
   else
       #let ws.atdsrvseq = ws.atdsrvseq + 1
       #
       #insert into DATMSRVACP ( atdsrvnum,
       #                         atdsrvano,
       #                         atdsrvseq,
       #                         atdetpcod,
       #                         atdetpdat,
       #                         atdetphor,
       #                         empcod   ,
       #                         funmat    )
       #                values ( w_cts22m00.atdsrvnum,
       #                         w_cts22m00.atdsrvano,
       #                         ws.atdsrvseq        ,
       #                         1                   ,
       #                         w_cts22m00.data     ,
       #                         w_cts22m00.hora     ,
       #                         g_issk.empcod       ,
       #                         w_cts22m00.funmat    )

   call cts10g04_insere_etapa(w_cts22m00.atdsrvnum,
                              w_cts22m00.atdsrvano,
                              1, "", "", "", "")
        returning ws.codigosql

       if  ws.codigosql  <>  0  then
           error " Erro (", ws.codigosql, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = w_cts22m00.cnldat
       let ws.atdetphor = w_cts22m00.atdfnlhor
       let ws.etpfunmat = w_cts22m00.c24opemat
   end if

   #let ws.atdsrvseq = ws.atdsrvseq + 1

   #insert into DATMSRVACP ( atdsrvnum,
   #                         atdsrvano,
   #                         atdsrvseq,
   #                         atdetpcod,
   #                         atdetpdat,
   #                         atdetphor,
   #                         empcod   ,
   #                         funmat   ,
   #                         pstcoddig )
   #                values ( w_cts22m00.atdsrvnum,
   #                         w_cts22m00.atdsrvano,
   #                         ws.atdsrvseq        ,
   #                         w_cts22m00.atdetpcod,
   #                         ws.atdetpdat        ,
   #                         ws.atdetphor        ,
   #                         g_issk.empcod       ,
   #                         ws.etpfunmat        ,
   #                         w_cts22m00.atdprscod )

   call cts10g04_insere_etapa(w_cts22m00.atdsrvnum,
                              w_cts22m00.atdsrvano,
                              w_cts22m00.atdetpcod,
                              w_cts22m00.atdprscod,
                              "", "", "")
        returning ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava relacionamento servico / apolice
 #------------------------------------------------------------------------------
   if g_documento.succod    is not null  and
      g_documento.ramcod    is not null  and
      g_documento.aplnumdig is not null  then
      call cts10g02_grava_servico_apolice( w_cts22m00.atdsrvnum         ,
                                           w_cts22m00.atdsrvano         ,
                                           g_documento.succod   ,
                                           g_documento.ramcod   ,
                                           g_documento.aplnumdig,
                                           g_documento.itmnumdig,
                                           g_documento.edsnumref)
       returning ws.tabname,
                 ws.codigosql
      if  ws.codigosql <> 0  then
          error " Erro (", ws.codigosql, ") na gravacao do",
                " relacionamento servico x apolice. AVISE A INFORMATICA!"
          rollback work
          prompt "" for char ws.prompt_key
          let ws.retorno = false
          exit while
      end if
      if g_documento.cndslcflg = "S"  then
         select ctcdtnom,ctcgccpfnum,ctcgccpfdig
                into ws.cdtnom,ws.cgccpfnum,ws.cgccpfdig
                from tmpcondutor
         call grava_condutor(g_documento.succod,g_documento.aplnumdig,
                             g_documento.itmnumdig,ws.cdtnom,ws.cgccpfnum,
                             ws.cgccpfdig,"D","CENTRAL24H") returning ws.cdtseq
         let ws_cgccpfnum = ws.cgccpfnum
         let ws_cgccpfdig = ws.cgccpfdig
              # esta funcao esta no modulo /projetos/pesqs/oaeia200.4gl
         insert into datrsrvcnd (atdsrvnum, atdsrvano, succod   ,
                                 aplnumdig, itmnumdig, vclcndseq)
                         values (w_cts22m00.atdsrvnum , w_cts22m00.atdsrvano ,
                                 g_documento.succod   , g_documento.aplnumdig,
                                 g_documento.itmnumdig, ws.cdtseq             )
         if  sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") na gravacao do",
                   " relacionamento servico x condutor. AVISE A INFORMATICA!"
             rollback work
             prompt "" for char ws.prompt_key
             let ws.retorno = false
             exit while
        end if
      end if
   else
      # este registro indica um atendimento sem documento
      if g_documento.ramcod is not null then
         call cts10g02_grava_servico_apolice(w_cts22m00.atdsrvnum         ,
                                             w_cts22m00.atdsrvano         ,
                                             0,
                                             g_documento.ramcod   ,
                                             0,
                                             0,
                                             0)
              returning ws.tabname,
                        ws.codigosql
         if  ws.codigosql <> 0  then
             error " Erro (", ws.codigosql, ") na gravacao do",
                   " relac. servico x apolice-atd.s/docto.AVISE A INFORMATICA!"
             rollback work
             prompt "" for char ws.prompt_key
             let ws.retorno = false
             exit while
         end if
      end if
   end if

   commit work
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(w_cts22m00.atdsrvnum,
                               w_cts22m00.atdsrvano)

 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------
   call cts10g02_historico( w_cts22m00.atdsrvnum,
                            w_cts22m00.atdsrvano,
                            w_cts22m00.data     ,
                            w_cts22m00.hora     ,
                            w_cts22m00.funmat   ,
                            hist_cts22m00.*      )
        returning ws.histerr

### if ws.histerr  = 0  then
### initialize g_documento.acao  to null
### end if

 #------------------------------------------------------------------------------
 # Envia e-mail de comunicado assunto S33
 #------------------------------------------------------------------------------
#    whenever error continue                    #psi175552
#    call ctx14g00_msg( 9999,
#                       g_documento.lignum,
#                       w_cts22m00.atdsrvnum,
#                       w_cts22m00.atdsrvano,
#                       "AVISO_S33_HOSPEDAGEM")
#         returning ws.c24trxnum
#   #call ctx14g00_msgdst( ws.c24trxnum,
#   #                      "ct24hs_catia/spaulo_ct24hs_teleatendimento@u55",
#   #                      "Catia",
#   #                      1) # 1-email
#   #call ctx14g00_msgdst( ws.c24trxnum,
#   #                      "cardoso_arnaldo/spaulo_ct24hs_teleatendimento@u55",
#   #                      "Arnaldo",
#   #                      1) # 1-email
#   #call ctx14g00_msgdst( ws.c24trxnum,
#   #                      "ct24hs_ivan/spaulo_ct24hs_teleatendimento@u55",
#   #                      "Ivan",
#   #                      1) # 1-email
#   #call ctx14g00_msgdst( ws.c24trxnum,
#   #                      "ct24hs_natalia/spaulo_ct24hs_teleatendimento@u55",
#   #                      "Natalia",
#   #                      1) # 1-email
#    call ctx14g00_msgdst( ws.c24trxnum,
#                          "anselmo_miriam/spaulo_ct24hs_teleatendimento@u55",
#                          "Miriam",
#                          1) # 1-email
#   #call ctx14g00_msgdst( ws.c24trxnum,   04/10/2002-silmara
#   #                      "rodrigues_silmara/spaulo_ct24hs_teleatendimento@u55",
#   #                      "Silmara",
#   #                      1) # 1-email
#    call ctx14g00_msgdst( ws.c24trxnum,
#                          "correia_lucio/spaulo_psocorro_comercial@u23",
#                          "Lucio Correia",
#                          1) # 1-email
#   #call ctx14g00_msgdst( ws.c24trxnum,
#   #                      "inhasz_sofia/spaulo_ct24hs_teleatendimento@u55",
#   #                      "Sofia",
#   #                      1) # 1-email
#    call ctx14g00_msgdst( ws.c24trxnum,
#                          "ct24hs_michael/spaulo_ct24hs_teleatendimento@u55",
#                          "Michael",
#                          1) # 1-email
#
#    -------------------[ PAGER'S ]---------------------------
#    call ctx14g00_msgdst( ws.c24trxnum,
#                          "2048",
#                          "pager",
#                          2) # 2-pager
#    call ctx14g00_msgdst( ws.c24trxnum,
#                          "5994",
#                          "pager",
#                          2) # 2-pager
#    call ctx14g00_msgdst( ws.c24trxnum,
#                          "5981",
#                          "pager",
#                          2) # 2-pager
#
#    let ws.lintxt = "Servico: ", g_documento.atdsrvorg using "&&",
#                                 "/", w_cts22m00.atdsrvnum using "&&&&&&&",
#                                 "-", w_cts22m00.atdsrvano using "&&"
#    call ctx14g00_msgtxt( ws.c24trxnum,
#                          ws.lintxt)
#    let ws.lintxt = "Segurado: ", d_cts22m00.nom
#    call ctx14g00_msgtxt( ws.c24trxnum,
#                          ws.lintxt)
#    let ws.lintxt = "Atendimento: ", w_cts22m00.data,
#                    " AS ", w_cts22m00.hora
#    call ctx14g00_msgtxt( ws.c24trxnum,
#                          ws.lintxt)
#
#    if g_documento.ramcod     is not null  and
#       g_documento.succod     is not null  and
#       g_documento.aplnumdig  is not null  then
#       let ws.lintxt = "Suc: ", g_documento.succod    using "&&",
#                    "  Ramo: ", g_documento.ramcod    using "##&&",
#                    "  Apl.: ", g_documento.aplnumdig using "<<<<<<<# #"
#       if g_documento.itmnumdig is not null  and
#          g_documento.itmnumdig <>  0        then
#          let ws.lintxt = ws.lintxt clipped,
#                         "  Item: ", g_documento.itmnumdig using "<<<<<# #"
#       end if
#       let ws.lintxt = ws.lintxt clipped,
#                      " End: ", g_documento.edsnumref using "<<<<<<<<&"
#       call ctx14g00_msgtxt( ws.c24trxnum,
#                             ws.lintxt)
#    end if
#    update dammtrx
#        set c24msgtrxstt = 9   # STATUS DE ENVIO
#    where c24trxnum = ws.c24trxnum
#
# ## call ctx14g00_msgok(ws.c24trxnum )
#    call ctx14g00_envia(ws.c24trxnum,"")
#    whenever error stop
#fim psi175552

  # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
  # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
  if cts34g00_acion_auto (g_documento.atdsrvorg,
                          a_cts22m00[1].cidnom,
                          a_cts22m00[1].ufdcod) then

     # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
     # --DO SERVICO ESTA OK
     # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
     # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
     if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg,
                                         g_documento.c24astcod,
                                         13,   #d_cts22m00.asitipcod,
                                         a_cts22m00[1].lclltt,
                                         a_cts22m00[1].lcllgt,
                                         "",
                                         d_cts22m00.frmflg,
                                         w_cts22m00.atdsrvnum,
                                         w_cts22m00.atdsrvano,
                                         " ",
                                         "", "") then
        #servico nao pode ser acionado automaticamente
        #display "Servico acionado manual"
     else
        #display "Servico foi para acionamento automatico!!"
     end if
  end if

 #------------------------------------------------------------------------------
 # Insere inf. de pagamentos na tabela dbscadtippgt  ## PSI207233
 #------------------------------------------------------------------------------
    if g_documento.c24astcod = "S11"  or
       g_documento.c24astcod = "S14"  or
       g_documento.c24astcod = "S53"  or
       g_documento.c24astcod = "S64"  then

         let g_cc.anosrv = w_cts22m00.atdsrvano
         let g_cc.nrosrv = w_cts22m00.atdsrvnum


         Insert into dbscadtippgt (anosrv,
                                   nrosrv,
                                   pgttipcodps,
                                   pgtmat,
                                   corsus,
                                   cadmat,
                                   cademp,
                                   caddat,
                                   atlmat,
                                   atlemp,
                                   atldat,
                                   cctcod,
                                   succod,
                                   empcod,
                                   pgtempcod)

                 values           (g_cc.anosrv,
                                   g_cc.nrosrv,
                                   g_cc.pgttipcodps,
                                   g_cc.pgtmat,
                                   g_cc.corsus,
                                   g_cc.cadmat,
                                   g_cc.cademp,
                                   g_cc.caddat,
                                   g_cc.atlmat,
                                   g_cc.atlemp,
                                   g_cc.atldat,
                                   g_cc.cctcod,
                                   g_cc.succod,
                                   g_cc.cademp,
                                   g_cc.pgtempcod)

    end if


 #------------------------------------------------------------------------------
 # Exibe o numero do servico
 #------------------------------------------------------------------------------
   let d_cts22m00.servico = g_documento.atdsrvorg using "&&",
                            "/", w_cts22m00.atdsrvnum using "&&&&&&&",
                            "-", w_cts22m00.atdsrvano using "&&"
   display by name d_cts22m00.servico attribute (reverse)

   error  " Verifique o numero do servico e tecle ENTER!"
   prompt "" for char ws.prompt_key

   error " Inclusao efetuada com sucesso!"
   let ws.retorno = true

   exit while
 end while

 return ws.retorno

end function  ###  inclui_cts22m00

#------------------------------
 function input_cts22m00()
#------------------------------

 define ws           record
    refatdsrvorg     like datmservico.atdsrvorg,
    succod           like datrservapol.succod,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    segnumdig        like gsakend.segnumdig,
    atdsrvorg        like datmservico.atdsrvorg,
    vclanomdl        like datmservico.vclanomdl,
    vclcordes        char (11),
    blqnivcod        like datkblq.blqnivcod,
    vcllicant        like datmservico.vcllicnum,
    dddcod           like gsakend.dddcod,
    teltxt           like gsakend.teltxt,
    snhflg           char (01),
    retflg           char (01),
    prpflg           char (01),
    confirma         char (01),
    codigosql        integer
 end record

 define hist_cts22m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define l_vclcoddig_contingencia like datmservico.vclcoddig

 define l_data    date,
        l_hora2   datetime hour to minute,
        l_servico like datmservico.atdsrvnum,
        l_ano     like datmservico.atdsrvano

 define l_maxcstvlr like datmservico.atdcstvlr --varani
 define l_mens_dia  char (40)
 define l_mens_vlr  char (40)
 define l_sem_uso   char (40)
 define l_acesso    smallint
 define l_clscod    char (03)
 define l_flag      char (01)
 define l_limite_km   smallint
 define l_flag_atende char(01)
 define l_idx       smallint

 let l_sem_uso     = null
 let l_maxcstvlr   = null
 let l_clscod      = null
 let l_flag        = null
 let l_limite_km   = null
 let l_flag_atende = null
 let l_idx         = null


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_vclcoddig_contingencia  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  hist_cts22m00.*  to  null

 initialize  ws.*  to  null

 initialize  hist_cts22m00.*  to  null

 initialize ws.*  to null

 let ws.vcllicant = d_cts22m00.vcllicnum

 let l_vclcoddig_contingencia = d_cts22m00.vclcoddig

 input by name d_cts22m00.nom         ,
               d_cts22m00.corsus      ,
               d_cts22m00.cornom      ,
               d_cts22m00.vclcoddig   ,
               d_cts22m00.vclanomdl   ,
               d_cts22m00.vcllicnum   ,
               d_cts22m00.vclcordes   ,
#               d_cts22m00.asitipcod   ,
               d_cts22m00.asimtvcod   ,
               d_cts22m00.refatdsrvorg,
               d_cts22m00.refatdsrvnum,
               d_cts22m00.refatdsrvano,
               d_cts22m00.seghospedado,
               d_cts22m00.hpddiapvsqtd,
               d_cts22m00.hpdqrtqtd   ,
               d_cts22m00.imdsrvflg   ,
               d_cts22m00.atdprinvlcod,
               d_cts22m00.atdlibflg   ,
               d_cts22m00.frmflg      without defaults

   before field nom
          display by name d_cts22m00.nom        attribute (reverse)

   after  field nom
          display by name d_cts22m00.nom

          if g_documento.acao = "CON" then
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma
                next field nom
          end if
          if d_cts22m00.nom is null  then
             error " Nome deve ser informado!"
             next field nom
          end if

          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  then
             if g_documento.succod    is not null  and
                g_documento.aplnumdig is not null  and
                g_documento.itmnumdig is not null  and
                w_cts22m00.atddmccidnom is null    and
                w_cts22m00.atddmcufdcod is null    then
                call f_funapol_ultima_situacao (g_documento.succod,
                                                g_documento.aplnumdig,
                                                g_documento.itmnumdig)
                                      returning g_funapol.*

                select segnumdig
                  into ws.segnumdig
                  from abbmdoc
                 where succod    = g_documento.succod     and
                       aplnumdig = g_documento.aplnumdig  and
                       itmnumdig = g_documento.itmnumdig  and
                       dctnumseq = g_funapol.dctnumseq

                select endcid, endufd
                  into w_cts22m00.atddmccidnom,
                       w_cts22m00.atddmcufdcod
                  from gsakend
                 where segnumdig = ws.segnumdig  and
                       endfld    = "1"
             end if

             call cts11m06(w_cts22m00.atddmccidnom,
                           w_cts22m00.atddmcufdcod,
                           w_cts22m00.atdocrcidnom,
                           w_cts22m00.atdocrufdcod,
                           w_cts22m00.atddstcidnom,
                           w_cts22m00.atddstufdcod)
                 returning w_cts22m00.atddmccidnom,
                           w_cts22m00.atddmcufdcod,
                           w_cts22m00.atdocrcidnom,
                           w_cts22m00.atdocrufdcod,
                           w_cts22m00.atddstcidnom,
                           w_cts22m00.atddstufdcod

             if w_cts22m00.atddmccidnom is null  or
                w_cts22m00.atddmcufdcod is null  or
                w_cts22m00.atdocrcidnom is null  or
                w_cts22m00.atdocrufdcod is null  or
                w_cts22m00.atddstcidnom is null  or
                w_cts22m00.atddstufdcod is null  then
                error " Localidades devem ser informadas para confirmacao",
                      " do direito de utilizacao!"
                next field nom
             end if

             if w_cts22m00.atddmccidnom = w_cts22m00.atdocrcidnom  and
                w_cts22m00.atddmcufdcod = w_cts22m00.atdocrufdcod  then
                error " Nao e' possivel a utilizacao da clausula de",
                      " assistencia aos passageiros! "
                call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                              "A LOCAL DE DOMICILIO!","") returning ws.confirma
                if ws.confirma = "N"  then
                   next field nom
                end if
             end if

             let a_cts22m00[1].cidnom = w_cts22m00.atdocrcidnom
             let a_cts22m00[1].ufdcod = w_cts22m00.atdocrufdcod

          end if

          if w_cts22m00.atdfnlflg = "S"  then
             error " Servico ja' acionado nao pode ser alterado!"
             let m_srv_acionado = true
             call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                               " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                   "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                  returning ws.confirma

#            next field nom
             next field frmflg
          end if

   before field corsus
          display by name d_cts22m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts22m00.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts22m00.corsus is not null  then
                select cornom
                  into d_cts22m00.cornom
                  from gcaksusep, gcakcorr
                 where gcaksusep.corsus   = d_cts22m00.corsus    and
                       gcakcorr.corsuspcp = gcaksusep.corsuspcp

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts22m00.cornom
                   next field vclcoddig
                end if
             end if
          end if

   before field cornom
          display by name d_cts22m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts22m00.cornom

   before field vclcoddig
          display by name d_cts22m00.vclcoddig  attribute (reverse)

   after  field vclcoddig
          display by name d_cts22m00.vclcoddig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts22m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          else

             if d_cts22m00.vclcoddig = 99999 and
                l_vclcoddig_contingencia = 99999 then
                next field vclcordes
             end if

             if d_cts22m00.vclcoddig is null  then
                call agguvcl() returning d_cts22m00.vclcoddig
                next field vclcoddig
             end if

             select vclcoddig from agbkveic
              where vclcoddig = d_cts22m00.vclcoddig

             if sqlca.sqlcode = notfound  then
                error " Codigo de veiculo nao cadastrado!"
                next field vclcoddig
             end if

             call cts15g00(d_cts22m00.vclcoddig)
                 returning d_cts22m00.vcldes

             display by name d_cts22m00.vcldes
          end if

   before field vclanomdl
          display by name d_cts22m00.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts22m00.vclanomdl

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field vclcoddig
          end if

          if d_cts22m00.vclanomdl is null then
             error " Ano do veiculo deve ser informado!"
             next field vclanomdl
          else
             if cts15g01(d_cts22m00.vclcoddig,
                         d_cts22m00.vclanomdl) = false  then
                error " Veiculo nao consta como fabricado em ",
                        d_cts22m00.vclanomdl, "!"
                next field vclanomdl
             end if
          end if

   before field vcllicnum
          display by name d_cts22m00.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts22m00.vcllicnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if not srp1415(d_cts22m00.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if

        #---------------------------------------------------------------------
        # Chama verificacao de bloqueios cadastrados
        #---------------------------------------------------------------------
        if g_documento.aplnumdig   is null       and
           d_cts22m00.vcllicnum    is not null   then

           if d_cts22m00.vcllicnum  = ws.vcllicant   then
           else
              initialize ws.snhflg to null

              call cts13g00(g_documento.c24astcod,
                            "", "", "", "",
                            d_cts22m00.vcllicnum,
                            "", "", "")
                  returning ws.blqnivcod, ws.snhflg

              if ws.blqnivcod  =  3   then
                 error " Bloqueio cadastrado nao permite atendimento para",
                       " este assunto/apolice!"
                 next field vcllicnum
              end if

              if ws.blqnivcod  =  2     and
                 ws.snhflg     =  "n"   then
                 error " Bloqueio necessita de permissao para atendimento!"
                 next field vcllicnum
              end if
           end if
        end if

   before field vclcordes
          display by name d_cts22m00.vclcordes attribute (reverse)

   after  field vclcordes
          display by name d_cts22m00.vclcordes

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field vcllicnum
          end if

          if d_cts22m00.vclcordes is not null then
             let ws.vclcordes = d_cts22m00.vclcordes[2,9]

             select cpocod into w_cts22m00.vclcorcod
               from iddkdominio
              where cponom      = "vclcorcod"  and
                    cpodes[2,9] = ws.vclcordes

             if sqlca.sqlcode = notfound  then
                error " Cor fora do padrao!"
                call c24geral4()
                     returning w_cts22m00.vclcorcod, d_cts22m00.vclcordes

                if w_cts22m00.vclcorcod  is null   then
                   error " Cor do veiculo deve ser informada!"
                   next field vclcordes
                else
                   display by name d_cts22m00.vclcordes
                end if
             end if
          else
             call c24geral4()
                  returning w_cts22m00.vclcorcod, d_cts22m00.vclcordes

             if w_cts22m00.vclcorcod  is null   then
                error " Cor do veiculo deve ser informada!"
                next field  vclcordes
             else
                display by name d_cts22m00.vclcordes
             end if
          end if

          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  then
             call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
             call cts11m04(g_documento.succod   , g_documento.aplnumdig,
                           g_documento.itmnumdig, l_data,
                           g_documento.ramcod)
          else
             call cts11m04(g_documento.succod   , g_documento.aplnumdig,
                           g_documento.itmnumdig, w_cts22m00.atddat,
                           g_documento.ramcod)
          end if

#   before field asitipcod
#          display by name d_cts22m00.asitipcod attribute (reverse)
#
#   after  field asitipcod
#          display by name d_cts22m00.asitipcod
#
#          if fgl_lastkey() <> fgl_keyval("up")    and
#             fgl_lastkey() <> fgl_keyval("left")  then
#             if d_cts22m00.asitipcod is null  then
#                call ctn25c00(3) returning d_cts22m00.asitipcod
#
#                if d_cts22m00.asitipcod is not null  then
#                   select asitipabvdes
#                     into d_cts22m00.asitipabvdes
#                     from datkasitip
#                    where asitipcod = d_cts22m00.asitipcod  and
#                          asitipstt = "A"
#
#                   display by name d_cts22m00.asitipcod
#                   display by name d_cts22m00.asitipabvdes
#                   next field asimtvcod
#                else
#                   next field asitipcod
#                end if
#             else
#                select asitipabvdes
#                  into d_cts22m00.asitipabvdes
#                  from datkasitip
#                 where asitipcod = d_cts22m00.asitipcod  and
#                       asitipstt = "A"
#
#                if sqlca.sqlcode = notfound  then
#                   error " Tipo de assistencia invalido!"
#                   call ctn25c00(3) returning d_cts22m00.asitipcod
#                   next field asitipcod
#                else
#                   display by name d_cts22m00.asitipcod
#                end if
#
#                select asitipcod
#                  from datrasitipsrv
#                 where atdsrvorg = g_documento.atdsrvorg
#                   and asitipcod = d_cts22m00.asitipcod
#
#                if sqlca.sqlcode = notfound  then
#                   error " Tipo de assistencia nao pode ser enviada para",
#                         " este servico!"
#                   next field asitipcod
#                end if
#             end if
#
#             display by name d_cts22m00.asitipabvdes
#          end if

   before field asimtvcod
          display by name d_cts22m00.asimtvcod attribute (reverse)

   after  field asimtvcod
          display by name d_cts22m00.asimtvcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             let m_asitipcod = 13
             if d_cts22m00.asimtvcod is null  then
                call cts11m03(13)
                    returning d_cts22m00.asimtvcod
             end if

                if d_cts22m00.asimtvcod is null  then
                   call cts11m03(13)
                       returning d_cts22m00.asimtvcod
                if d_cts22m00.asimtvcod is not null  then
                   select asimtvdes
                     into d_cts22m00.asimtvdes
                     from datkasimtv
                    where asimtvcod = d_cts22m00.asimtvcod  and
                          asimtvsit = "A"

                   display by name d_cts22m00.asimtvcod
                   display by name d_cts22m00.asimtvdes
                   next field refatdsrvorg
                else
                   next field asimtvcod
                end if
             else
                select asimtvdes
                  into d_cts22m00.asimtvdes
                  from datkasimtv
                 where asimtvcod = d_cts22m00.asimtvcod  and
                       asimtvsit = "A"

                if sqlca.sqlcode = notfound  then
                   error " Motivo invalido!"
                   call cts11m03(13)
                       returning d_cts22m00.asimtvcod
                   next field asimtvcod
                else
                   display by name d_cts22m00.asimtvcod
                end if

                select asimtvcod
                  from datrmtvasitip
                 where asitipcod = 13
                   and asimtvcod = d_cts22m00.asimtvcod

                if sqlca.sqlcode = notfound  then
                   error " Motivo nao pode ser informado para este tipo de",
                         " assistencia!"
                   next field asimtvcod
                   end if
                end if
             end if

             display by name d_cts22m00.asimtvdes
             if cty31g00_valida_clausula() and
             	  g_nova.perfil <> 2         then
                   #-----------------------------------------------------------
                   # Recupera o Limite de Kilometragem
                   #-----------------------------------------------------------
                   call cty31g00_valida_km(g_documento.c24astcod ,
                                           g_nova.clscod         ,
                                           g_nova.perfil         ,
                                           m_asitipcod           ,
                                           d_cts22m00.asimtvcod  )
                   returning l_limite_km,
                             l_flag_atende
                   if l_flag_atende = "N" then
                       next field asimtvcod
                   end if
             else
                   call cty26g00_srv_pass(g_documento.ramcod    ## JUNIOR (FORNAX)
				                                 ,g_documento.succod
				                                 ,g_documento.aplnumdig
				                                 ,g_documento.itmnumdig
				                                 ,g_documento.c24astcod
				                                 ,m_asitipcod
				                                 ,d_cts22m00.asimtvcod)
	                 returning l_flag, l_clscod
	                 
	                 
	                 if g_documento.c24astcod = "S33" then
	                    
	                    if g_documento.prporg    is not null and      
	                    	 g_documento.prpnumdig is not null then    
	                    
	                       for l_idx  = 1  to 200             
	                       	  
	                          if g_clausulas_proposta[l_idx].clscod = "035" or 
	                          	 g_clausulas_proposta[l_idx].clscod = "35"  then
	                              let l_flag = "S"
	                              exit for
	                          end if                     
	                       end for 
	                       
	                       if l_flag = "S" then                                                                                                                         
	                            call cts08g01("A","N","",  "LIMITE DE R$200,00 POR DIA,", "MAXIMO 7 DIAS.", "")   
	                            returning ws.confirma                                                             
	                       else                                                                                   
	                            call cts08g01("A","N","",  "LIMITE DE R$400,00 POR DIA,", "MAXIMO 7 DIAS.", "")   
	                            returning ws.confirma                                                             
	                       end if                                                                                 
	                    
	                    
	                    else
	                        if l_clscod = "035" or
	                        	 l_clscod = "35"  then                    
	                             call cts08g01("A","N","",  "LIMITE DE R$200,00 POR DIA,", "MAXIMO 7 DIAS.", "")    
	                             returning ws.confirma                                                             
	                        else     
	                             call cts08g01("A","N","",  "LIMITE DE R$400,00 POR DIA,", "MAXIMO 7 DIAS.", "")
	                             returning ws.confirma
	                        end if
	                    end if    
	                 end if
             end if

             if d_cts22m00.asimtvcod = 4  then   ##  Outras Situacoes
                call cts08g01("A","N","","REGISTRE A SITUACAO NO HISTORICO","","")
                     returning ws.confirma
             end if

   before field refatdsrvorg
          display by name d_cts22m00.refatdsrvorg attribute (reverse)

   after  field refatdsrvorg
          display by name d_cts22m00.refatdsrvorg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field asimtvcod
          end if

          if  d_cts22m00.refatdsrvorg is null  then
           if  g_documento.succod    is not null  and
               g_documento.aplnumdig is not null  then
               call cts11m02 ( g_documento.succod   ,
                               g_documento.aplnumdig,
                               g_documento.itmnumdig, "",
                               g_documento.ramcod)
                     returning d_cts22m00.refatdsrvorg,
                               d_cts22m00.refatdsrvnum,
                               d_cts22m00.refatdsrvano
               display by name d_cts22m00.refatdsrvorg
               display by name d_cts22m00.refatdsrvnum
               display by name d_cts22m00.refatdsrvano

               if  d_cts22m00.refatdsrvnum is null  and
                   d_cts22m00.refatdsrvano is null  then

                   let a_cts22m00[1].cidnom = w_cts22m00.atddstcidnom
                   let a_cts22m00[1].ufdcod = w_cts22m00.atddstufdcod

                   let a_cts22m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
                   call cts06g03( 3,
                                  2,
                                  w_cts22m00.ligcvntip,
                                  aux_today,
                                  aux_hora,
                                  a_cts22m00[1].lclidttxt,
                                  a_cts22m00[1].cidnom,
                                  a_cts22m00[1].ufdcod,
                                  a_cts22m00[1].brrnom,
                                  a_cts22m00[1].lclbrrnom,
                                  a_cts22m00[1].endzon,
                                  a_cts22m00[1].lgdtip,
                                  a_cts22m00[1].lgdnom,
                                  a_cts22m00[1].lgdnum,
                                  a_cts22m00[1].lgdcep,
                                  a_cts22m00[1].lgdcepcmp,
                                  a_cts22m00[1].lclltt,
                                  a_cts22m00[1].lcllgt,
                                  a_cts22m00[1].lclrefptotxt,
                                  a_cts22m00[1].lclcttnom,
                                  a_cts22m00[1].dddcod,
                                  a_cts22m00[1].lcltelnum,
                                  a_cts22m00[1].c24lclpdrcod,
                                  a_cts22m00[1].ofnnumdig,
                                  a_cts22m00[1].celteldddcod   ,
                                  a_cts22m00[1].celtelnum,
                                  a_cts22m00[1].endcmp ,
                                  hist_cts22m00.*,
                                  a_cts22m00[1].emeviacod)
                        returning a_cts22m00[1].lclidttxt,
                                  a_cts22m00[1].cidnom,
                                  a_cts22m00[1].ufdcod,
                                  a_cts22m00[1].brrnom,
                                  a_cts22m00[1].lclbrrnom,
                                  a_cts22m00[1].endzon,
                                  a_cts22m00[1].lgdtip,
                                  a_cts22m00[1].lgdnom,
                                  a_cts22m00[1].lgdnum,
                                  a_cts22m00[1].lgdcep,
                                  a_cts22m00[1].lgdcepcmp,
                                  a_cts22m00[1].lclltt,
                                  a_cts22m00[1].lcllgt,
                                  a_cts22m00[1].lclrefptotxt,
                                  a_cts22m00[1].lclcttnom,
                                  a_cts22m00[1].dddcod,
                                  a_cts22m00[1].lcltelnum,
                                  a_cts22m00[1].c24lclpdrcod,
                                  a_cts22m00[1].ofnnumdig,
                                  a_cts22m00[1].celteldddcod   ,
                                  a_cts22m00[1].celtelnum,
                                  a_cts22m00[1].endcmp ,
                                  ws.retflg,
                                  hist_cts22m00.*,
                                  a_cts22m00[1].emeviacod
                  # PSI 244589 - Inclusão de Sub-Bairro - Burini
                  let m_subbairro[1].lclbrrnom = a_cts22m00[1].lclbrrnom
                  call cts06g10_monta_brr_subbrr(a_cts22m00[1].brrnom,
                                                 a_cts22m00[1].lclbrrnom)
                       returning a_cts22m00[1].lclbrrnom

                  let a_cts22m00[1].lgdtxt = a_cts22m00[1].lgdtip clipped, " ",
                                             a_cts22m00[1].lgdnom clipped, " ",
                                             a_cts22m00[1].lgdnum using "<<<<#"
#
#                   display by name a_cts22m00[1].lgdtxt
#                   display by name a_cts22m00[1].lclbrrnom
#                   display by name a_cts22m00[1].endzon
#                   display by name a_cts22m00[1].cidnom
#                   display by name a_cts22m00[1].ufdcod
#                   display by name a_cts22m00[1].lclrefptotxt
#                   display by name a_cts22m00[1].lclcttnom
#                   display by name a_cts22m00[1].dddcod
#                   display by name a_cts22m00[1].lcltelnum

                   if  w_cts22m00.atddmccidnom = w_cts22m00.atdocrcidnom  and
                       w_cts22m00.atddmcufdcod = w_cts22m00.atdocrufdcod  then
                       error " Nao e' possivel a utilizacao da clausula",
                             " de assistencia aos passageiros! "
                       call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                                     "A LOCAL DE DOMICILIO!","")
                            returning ws.confirma
                       if  ws.confirma = "N"  then
                           next field nom
                       end if
                   end if

									 if a_cts22m00[1].ufdcod = "EX" then
									    let ws.retflg = "S"
									 end if

                   if  ws.retflg = "N"  then
                       error " Dados referentes ao local incorretos",
                             " ou nao preenchidos!"
                       next field refatdsrvorg
                   else
                       next field seghospedado
                   end if
               end if
           else


               initialize d_cts22m00.refatdsrvano to null
               initialize d_cts22m00.refatdsrvnum to null
               display by name d_cts22m00.refatdsrvano
               display by name d_cts22m00.refatdsrvnum
           end if
          end if

          if  d_cts22m00.refatdsrvorg <> 4   and    # Remocao
              d_cts22m00.refatdsrvorg <> 6   and    # DAF
              d_cts22m00.refatdsrvorg <> 1   and    # Socorro
              d_cts22m00.refatdsrvorg <> 2   then   # Transporte
              error " Origem do servico de referencia deve ser",
                    " p/ SOCORRO ou REMOCAO!"
              next field refatdsrvorg
          end if

   before field refatdsrvnum
          display by name d_cts22m00.refatdsrvnum attribute (reverse)

   after  field refatdsrvnum
          display by name d_cts22m00.refatdsrvnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field refatdsrvorg
          end if

          if d_cts22m00.refatdsrvorg is not null  and
             d_cts22m00.refatdsrvnum is null      then
             error " Numero do servico de referencia nao informado!"
             next field refatdsrvnum
          end if

   before field refatdsrvano
         #if fgl_lastkey() = fgl_keyval("up")   or
         #   fgl_lastkey() = fgl_keyval("left") then
         #   if d_cts22m00.refatdsrvano is null  then
         #      next field refatdsrvnum
         #   end if
         #end if

          display by name d_cts22m00.refatdsrvano attribute (reverse)

   after  field refatdsrvano
          display by name d_cts22m00.refatdsrvano

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field refatdsrvnum
          end if

          if  d_cts22m00.refatdsrvnum is not null  then
           if  d_cts22m00.refatdsrvano is not null   then
               select atdsrvorg
                 into ws.refatdsrvorg
                 from DATMSERVICO
                      where atdsrvnum = d_cts22m00.refatdsrvnum
                        and atdsrvano = d_cts22m00.refatdsrvano

               if  ws.refatdsrvorg <> d_cts22m00.refatdsrvorg  then
                   error " Origem do numero de servico invalido.",
                         " A origem deve ser ", ws.refatdsrvorg using "&&"
                   next field refatdsrvorg
               end if

               if  g_documento.aplnumdig is not null  then
                   select succod   ,
                          aplnumdig,
                          itmnumdig
                     into ws.succod   ,
                          ws.aplnumdig,
                          ws.itmnumdig
                     from DATRSERVAPOL
                          where atdsrvnum = d_cts22m00.refatdsrvnum
                            and atdsrvano = d_cts22m00.refatdsrvano

                   if  sqlca.sqlcode <> notfound  then
                    if  ws.succod    <> g_documento.succod     or
                        ws.aplnumdig <> g_documento.aplnumdig  or
                        ws.itmnumdig <> g_documento.itmnumdig  then
                        error " Servico original nao pertence a esta apolice!"
                        next field refatdsrvorg
                    end if
                   end if
               end if
           else
               error " Ano do servico original nao informado!"
               next field refatdsrvano
           end if
          end if

{ #ligia 27/04
          if  g_documento.atdsrvnum   is     null  and
              g_documento.atdsrvano   is     null  and
              d_cts22m00.refatdsrvnum is not null  and
              d_cts22m00.refatdsrvano is not null  then
              call ctx04g00_local_gps( d_cts22m00.refatdsrvnum,
                                       d_cts22m00.refatdsrvano,
                                       1                       )
                             returning a_cts22m00[1].lclidttxt   ,
                                       a_cts22m00[1].lgdtip      ,
                                       a_cts22m00[1].lgdnom      ,
                                       a_cts22m00[1].lgdnum      ,
                                       a_cts22m00[1].lclbrrnom   ,
                                       a_cts22m00[1].brrnom      ,
                                       a_cts22m00[1].cidnom      ,
                                       a_cts22m00[1].ufdcod      ,
                                       a_cts22m00[1].lclrefptotxt,
                                       a_cts22m00[1].endzon      ,
                                       a_cts22m00[1].lgdcep      ,
                                       a_cts22m00[1].lgdcepcmp   ,
                                       a_cts22m00[1].lclltt      ,
                                       a_cts22m00[1].lcllgt      ,
                                       a_cts22m00[1].dddcod      ,
                                       a_cts22m00[1].lcltelnum   ,
                                       a_cts22m00[1].lclcttnom   ,
                                       a_cts22m00[1].c24lclpdrcod,
                                       ws.codigosql                ,
                                       a_cts22m00[2].emeviacod

              select ofnnumdig into a_cts22m00[1].ofnnumdig
                from datmlcl
               where atdsrvano = g_documento.atdsrvano
                 and atdsrvnum = g_documento.atdsrvnum
                 and c24endtip = 1

              if  ws.codigosql <> 0  then
                  error " Erro (", ws.codigosql using "<<<<<&", ") na leitura",
                        " do local de ocorrencia. AVISE A INFORMATICA!"
                  next field refatdsrvorg
              end if

              let a_cts22m00[1].lgdtxt = a_cts22m00[1].lgdtip clipped, " ",
                                         a_cts22m00[1].lgdnom clipped, " ",
                                         a_cts22m00[1].lgdnum using "<<<<#"

#              display by name a_cts22m00[1].lgdtxt,
#                              a_cts22m00[1].lclbrrnom,
#                              a_cts22m00[1].cidnom,
#                              a_cts22m00[1].ufdcod,
#                              a_cts22m00[1].lclrefptotxt,
#                              a_cts22m00[1].endzon,
#                              a_cts22m00[1].dddcod,
#                              a_cts22m00[1].lcltelnum,
#                              a_cts22m00[1].lclcttnom
          end if
}
          let a_cts22m00[1].cidnom = w_cts22m00.atddstcidnom
          let a_cts22m00[1].ufdcod = w_cts22m00.atddstufdcod

          let a_cts22m00[1].lclbrrnom = m_subbairro[1].lclbrrnom

          call cts06g03( 3,
                         2,
                         w_cts22m00.ligcvntip,
                         aux_today,
                         aux_hora,
                         a_cts22m00[1].lclidttxt,
                         a_cts22m00[1].cidnom,
                         a_cts22m00[1].ufdcod,
                         a_cts22m00[1].brrnom,
                         a_cts22m00[1].lclbrrnom,
                         a_cts22m00[1].endzon,
                         a_cts22m00[1].lgdtip,
                         a_cts22m00[1].lgdnom,
                         a_cts22m00[1].lgdnum,
                         a_cts22m00[1].lgdcep,
                         a_cts22m00[1].lgdcepcmp,
                         a_cts22m00[1].lclltt,
                         a_cts22m00[1].lcllgt,
                         a_cts22m00[1].lclrefptotxt,
                         a_cts22m00[1].lclcttnom,
                         a_cts22m00[1].dddcod,
                         a_cts22m00[1].lcltelnum,
                         a_cts22m00[1].c24lclpdrcod,
                         a_cts22m00[1].ofnnumdig,
                         a_cts22m00[1].celteldddcod   ,
                         a_cts22m00[1].celtelnum,
                         a_cts22m00[1].endcmp ,
                         hist_cts22m00.*,
                         a_cts22m00[1].emeviacod)
               returning a_cts22m00[1].lclidttxt,
                         a_cts22m00[1].cidnom,
                         a_cts22m00[1].ufdcod,
                         a_cts22m00[1].brrnom,
                         a_cts22m00[1].lclbrrnom,
                         a_cts22m00[1].endzon,
                         a_cts22m00[1].lgdtip,
                         a_cts22m00[1].lgdnom,
                         a_cts22m00[1].lgdnum,
                         a_cts22m00[1].lgdcep,
                         a_cts22m00[1].lgdcepcmp,
                         a_cts22m00[1].lclltt,
                         a_cts22m00[1].lcllgt,
                         a_cts22m00[1].lclrefptotxt,
                         a_cts22m00[1].lclcttnom,
                         a_cts22m00[1].dddcod,
                         a_cts22m00[1].lcltelnum,
                         a_cts22m00[1].c24lclpdrcod,
                         a_cts22m00[1].ofnnumdig,
                         a_cts22m00[1].celteldddcod   ,
                         a_cts22m00[1].celtelnum,
                         a_cts22m00[1].endcmp ,
                         ws.retflg,
                         hist_cts22m00.*,
                         a_cts22m00[1].emeviacod

          # PSI 244589 - Inclusão de Sub-Bairro - Burini
          let m_subbairro[1].lclbrrnom = a_cts22m00[1].lclbrrnom
          call cts06g10_monta_brr_subbrr(a_cts22m00[1].brrnom,
                                         a_cts22m00[1].lclbrrnom)
               returning a_cts22m00[1].lclbrrnom

          let a_cts22m00[1].lgdtxt = a_cts22m00[1].lgdtip clipped, " ",
                                     a_cts22m00[1].lgdnom clipped, " ",
                                     a_cts22m00[1].lgdnum using "<<<<#"

#          display by name a_cts22m00[1].lgdtxt
#          display by name a_cts22m00[1].lclbrrnom
#          display by name a_cts22m00[1].endzon
#          display by name a_cts22m00[1].cidnom
#          display by name a_cts22m00[1].ufdcod
#          display by name a_cts22m00[1].lclrefptotxt
#          display by name a_cts22m00[1].lclcttnom
#          display by name a_cts22m00[1].dddcod
#          display by name a_cts22m00[1].lcltelnum

          if  w_cts22m00.atddmccidnom = w_cts22m00.atdocrcidnom  and
              w_cts22m00.atddmcufdcod = w_cts22m00.atdocrufdcod  then
              error " Nao e' possivel a utilizacao da clausula",
                    " de assistencia aos passageiros! "
              call cts08g01("C","S","","LOCAL DE OCORRENCIA E' IGUAL",
                            "A LOCAL DE DOMICILIO!","") returning ws.confirma
              if  ws.confirma = "N"  then
                  next field nom
              end if
          end if

#Humberto
			if a_cts22m00[1].ufdcod = 'EX' then
			    let ws.retflg = "S"
			end if

          if  ws.retflg = "N"  then
              error " Dados referentes ao local incorretos ou nao preenchidos!"
              next field refatdsrvano
          end if

   before field seghospedado
      display by name d_cts22m00.seghospedado attribute (reverse)

   after field seghospedado
      display by name d_cts22m00.seghospedado

      if (d_cts22m00.seghospedado <> 'S' and
         d_cts22m00.seghospedado <> 'N') or d_cts22m00.seghospedado is null then
         error 'Digite "S" ou "N" '
         next field seghospedado
      end if

      if d_cts22m00.seghospedado = 'S' then
         call cts22m01_hotel('', '', g_documento.acao, mr_hotel.*)
            returning mr_hotel.hsphotnom
                     ,mr_hotel.hsphotend
                     ,mr_hotel.hsphotbrr
                     ,mr_hotel.hsphotuf
                     ,mr_hotel.hsphotcid
                     ,mr_hotel.hsphottelnum
                     ,mr_hotel.hsphotcttnom
                     ,mr_hotel.hsphotdiavlr
                     ,mr_hotel.hsphotacmtip
                     ,mr_hotel.obsdes
                     ,mr_hotel.hsphotrefpnt

         display by name mr_hotel.hsphotnom
                        ,mr_hotel.hsphotbrr
                        ,mr_hotel.hsphotuf
                        ,mr_hotel.hsphotcid
                        ,mr_hotel.hsphotrefpnt
                        ,mr_hotel.hsphottelnum
                        ,mr_hotel.hsphotcttnom
      end if



   before field hpddiapvsqtd
          display by name d_cts22m00.hpddiapvsqtd attribute (reverse)

   after  field hpddiapvsqtd
          display by name d_cts22m00.hpddiapvsqtd

          --varani
          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then


             if d_cts22m00.hpddiapvsqtd is null  then
                error " Quantidade prevista de diarias deve ser informada!"
                next field hpddiapvsqtd
             end if

             if d_cts22m00.hpddiapvsqtd = 0  then
                error " Quantidade prevista de diarias nao pode ser zero!"
                next field hpddiapvsqtd
             end if
             --varani
                   call cts45g00_limites_cob(2 --retorno
                                             ,l_sem_uso
                                             ,l_sem_uso
                                             ,g_documento.succod
                                             ,g_documento.aplnumdig
                                             ,g_documento.itmnumdig
                                             ,13 --asitipcod
                                             ,g_documento.ramcod
                                             ,d_cts22m00.asimtvcod
                                             ,w_cts22m00.ligcvntip
                                             ,d_cts22m00.hpddiapvsqtd)

                   returning l_maxcstvlr
                            ,d_cts22m00.hpddiapvsqtd --limite de diarias

               let l_mens_dia = "CLAUSULA LIMITADA A ",d_cts22m00.hpddiapvsqtd using "<<"


               if l_maxcstvlr > 0 then
                call cts08g01("A","N","",l_mens_dia,
                                 "DIARIAS.","")
                        returning ws.confirma
                   #if ws.confirma = "N"  then
                      next field hpddiapvsqtd
                   #end if
               else
                    next field hpdqrtqtd
               end if

             {if d_cts22m00.hpddiapvsqtd > 7  then
                if g_documento.ramcod = 78  or   # transporte
                   g_documento.ramcod = 171  then # transporte
                   call cts08g01("C","S","","LIMITE MAXIMO DE SETE",
                                 "DIARIAS ATINGIDO!",
                                 "INFORME LIMITE DE R$50,00 DIARIO")
                        returning ws.confirma
                   if ws.confirma = "N"  then
                      next field hpddiapvsqtd
                   end if
                else
                   call cts08g01("C","S","","LIMITE MAXIMO DE SETE",
                                 "DIARIAS ATINGIDO!",
                                 "INFORME LIMITE DE R$100,00 DIARIO")
                        returning ws.confirma
                   if ws.confirma = "N"  then
                      next field hpddiapvsqtd
                   end if
                end if
             end if}
         end if
--varani
   before field hpdqrtqtd
          display by name d_cts22m00.hpdqrtqtd attribute (reverse)

   after  field hpdqrtqtd
          display by name d_cts22m00.hpdqrtqtd

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts22m00.hpdqrtqtd is null  then
                error " Numero de quartos deve ser informado!"
                next field hpdqrtqtd
             end if

             if d_cts22m00.hpdqrtqtd = 0  then
                error " Numero de quartos nao pode ser zero!"
                next field hpdqrtqtd
             end if

             if m_clscod = '033' or m_clscod = '33R' or -- then  --varani
                m_clscod = '046' or m_clscod = '46R' or    # novas Clausulas - Porto Socorro Mais
                m_clscod = '047' or m_clscod = '47R' then  # novas Clausulas - Porto Socorro Mais
                     call cts08g01("A","N",
                              "INFORME LIMITE 07 DIARIAS E R$400,00/DIA",
                              "REGISTRE INFORMACOES ADICIONAIS",
                              "(TIPO DE ACOMODACAO, PREFERENCIAS, ETC.)",
                              "NO HISTORICO DO SERVICO!")
                     returning ws.confirma
             else

             if g_documento.ramcod = 78    or   # transportes
               (g_documento.ramcod = 171   or   # transporte
                g_documento.ramcod = 195 ) then # Garantia Estendida
                call cts08g01("A","N",
                              "INFORME LIMITE 07 DIARIAS E R$50,00/DIA",
                              "REGISTRE INFORMACOES ADICIONAIS",
                              "(TIPO DE ACOMODACAO, PREFERENCIAS, ETC.)",
                              "NO HISTORICO DO SERVICO!")
                     returning ws.confirma
             else
                # -- OSF 12718 - Fabrica de Software, Katiucia -- #
                if w_cts22m00.ligcvntip = 64 then

                   # --ALTERACAO DA DIARIA P/R$200
                   # --CONFORME SOLICITACAO DA BEATRIZ CT24HS
                   # --DATA DA ALTERACAO: 22/12/2005

                   call cts08g01("A","N",
                                 "INFORME LIMITE 07 DIARIAS E R$200,00/DIA",
                                 "REGISTRE INFORMACOES ADICIONAIS",
                                 "(TIPO DE ACOMODACAO, PREFERENCIAS, ETC.)",
                                 "NO HISTORICO DO SERVICO!")
                        returning ws.confirma
                else
                   # --ALTERACAO DA DIARIA P/R$200
                   # --CONFORME SOLICITACAO DA BEATRIZ CT24HS
                   # --DATA DA ALTERACAO: 22/12/2005

                      select clscod into m_clscod from abbmclaus  --varani
                       where succod    = g_documento.succod    and
                             aplnumdig = g_documento.aplnumdig and
                             itmnumdig = g_documento.itmnumdig and
                             dctnumseq = g_funapol.dctnumseq   and
                             clscod   in ("046","46R","047","47R","044","44R","048","48R")
                      if m_clscod = '046' or m_clscod = '46R' or    # novas Clausulas - Porto Socorro Mais
                         m_clscod = '047' or m_clscod = '47R' then  # novas Clausulas - Porto Socorro Mais
                   call cts08g01("A","N",
                                       "INFORME LIMITE 07 DIARIAS E R$400,00/DIA",
                                       "REGISTRE INFORMACOES ADICIONAIS",
                                       "(TIPO DE ACOMODACAO, PREFERENCIAS, ETC.)",
                                       "NO HISTORICO DO SERVICO!")
                         returning ws.confirma
                   else
                      if m_clscod <> '044' and
			 m_clscod <> '44R' and
			 m_clscod <> '048' and
			 m_clscod <> '48R' then
                         call cts08g01("A","N",
                                 "INFORME LIMITE 07 DIARIAS E R$200,00/DIA",
                                 "REGISTRE INFORMACOES ADICIONAIS",
                                 "(TIPO DE ACOMODACAO, PREFERENCIAS, ETC.)",
                                 "NO HISTORICO DO SERVICO!")
                        returning ws.confirma
                      end if
                   end if
                end if
             end if
          end if
         end if
          error " Informe a relacao de hospedes!"
          call cts11m01 (a_passag[01].*,
                         a_passag[02].*,
                         a_passag[03].*,
                         a_passag[04].*,
                         a_passag[05].*,
                         a_passag[06].*,
                         a_passag[07].*,
                         a_passag[08].*,
                         a_passag[09].*,
                         a_passag[10].*,
                         a_passag[11].*,
                         a_passag[12].*,
                         a_passag[13].*,
                         a_passag[14].*,
                         a_passag[15].*)
               returning a_passag[01].*,
                         a_passag[02].*,
                         a_passag[03].*,
                         a_passag[04].*,
                         a_passag[05].*,
                         a_passag[06].*,
                         a_passag[07].*,
                         a_passag[08].*,
                         a_passag[09].*,
                         a_passag[10].*,
                         a_passag[11].*,
                         a_passag[12].*,
                         a_passag[13].*,
                         a_passag[14].*,
                         a_passag[15].*

   before field imdsrvflg
          let d_cts22m00.imdsrvflg    = "S"
          let w_cts22m00.atdpvtretflg = "S"
          let w_cts22m00.atdhorpvt    = "00:00"

          initialize w_cts22m00.atddatprg to null
          initialize w_cts22m00.atdhorprg to null

          display by name d_cts22m00.imdsrvflg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field hpdqrtqtd
          else
             next field atdprinvlcod
          end if

   after  field imdsrvflg
          display by name d_cts22m00.imdsrvflg

          if d_cts22m00.imdsrvflg = "N" then
             let d_cts22m00.atdprinvlcod  = 2
             select cpodes
               into d_cts22m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts22m00.atdprinvlcod

             display by name d_cts22m00.atdprinvlcod
             display by name d_cts22m00.atdprinvldes

             next field atdlibflg
          end if

   before field atdprinvlcod
          display by name d_cts22m00.atdprinvlcod attribute (reverse)

   after  field atdprinvlcod
          display by name d_cts22m00.atdprinvlcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts22m00.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             select cpodes
               into d_cts22m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts22m00.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa,",
                      " (2)-Normal ou (3)-Urgente"
                next field atdprinvlcod
             end if

             display by name d_cts22m00.atdprinvldes

          end if

   before field atdlibflg
          display by name d_cts22m00.atdlibflg attribute (reverse)

          if g_documento.atdsrvnum is not null then
             if w_cts22m00.atdfnlflg = "S"  then
                exit input
             end if
          end if

          if d_cts22m00.atdlibflg is null  and
             g_documento.c24soltipcod = 1  then   # Tipo Solic = Segurado
           # call cts09g00(g_documento.ramcod   ,
           #               g_documento.succod   ,
           #               g_documento.aplnumdig,
           #               g_documento.itmnumdig,
           #               true)
           #     returning ws.dddcod, ws.teltxt
          end if

   after  field atdlibflg
          display by name d_cts22m00.atdlibflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdprinvlcod
          end if

          if d_cts22m00.atdlibflg is null then
             error " Envio liberado deve ser informado!"
             next field atdlibflg
          end if

          if d_cts22m00.atdlibflg <> "S"  and
             d_cts22m00.atdlibflg <> "N"  then
             error " Informe (S)im ou (N)ao!"
             next field atdlibflg
          end if

         #call cts02m06() returning w_cts22m00.atdlibflg
          let w_cts22m00.atdlibflg   =  d_cts22m00.atdlibflg

          if w_cts22m00.atdlibflg is null   then
             next field atdlibflg
          end if

         #let d_cts22m00.atdlibflg = w_cts22m00.atdlibflg
          display by name d_cts22m00.atdlibflg

          if w_cts22m00.antlibflg is null  then
             if w_cts22m00.atdlibflg = "S"  then
                call cts40g03_data_hora_banco(2)
                   returning l_data, l_hora2
                let d_cts22m00.atdlibdat = l_data
                let d_cts22m00.atdlibhor =  l_hora2
             else
                let d_cts22m00.atdlibflg = "N"
                display by name d_cts22m00.atdlibflg
                initialize d_cts22m00.atdlibhor to null
                initialize d_cts22m00.atdlibdat to null
             end if
          else
             select atdfnlflg
               from datmservico
              where atdsrvnum = g_documento.atdsrvnum  and
                    atdsrvano = g_documento.atdsrvano  and
                    atdfnlflg in ("A","N") #PSI 198714
                     ## CT 5024358

             if sqlca.sqlcode = notfound  then
                error " Servico ja' acionado nao pode ser alterado!"
                let m_srv_acionado = true
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                      "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                     returning ws.confirma
                next field atdlibflg
             end if

             if w_cts22m00.antlibflg = "S"  then
                if w_cts22m00.atdlibflg = "S"  then
                   exit input
                else
                   error " A liberacao do servico nao pode ser cancelada!"
                   next field atdlibflg
                   let d_cts22m00.atdlibflg = "N"
                   display by name d_cts22m00.atdlibflg
                   initialize d_cts22m00.atdlibhor to null
                   initialize d_cts22m00.atdlibdat to null
                   error " Liberacao do servico cancelada!"
                   sleep 1
                   exit input
                end if
             else
                if w_cts22m00.antlibflg = "N"  then
                   if w_cts22m00.atdlibflg = "N"  then
                      exit input
                   else
                      call cts40g03_data_hora_banco(2)
                         returning l_data, l_hora2
                      let d_cts22m00.atdlibdat = l_data
                      let d_cts22m00.atdlibhor = l_hora2
                      exit input
                   end if
                end if
             end if
          end if

   before field frmflg
          if w_cts22m00.operacao = "i"  then
             let d_cts22m00.frmflg = "N"
             display by name d_cts22m00.frmflg attribute (reverse)
          else
             if w_cts22m00.atdfnlflg = "S"  then
                call cts11g00(w_cts22m00.lignum)
                let int_flag = true
             end if

             exit input
          end if

   after  field frmflg
          display by name d_cts22m00.frmflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdlibflg
          end if

          if d_cts22m00.frmflg = "S"  then
             if d_cts22m00.atdlibflg = "N"  then
                error " Nao e' possivel registrar servico nao liberado",
                      " via formulario!"
                next field atdlibflg
             end if

             call cts02m05(2) returning w_cts22m00.data,
                                        w_cts22m00.hora,
                                        w_cts22m00.funmat,
                                        w_cts22m00.cnldat,
                                        w_cts22m00.atdfnlhor,
                                        w_cts22m00.c24opemat,
                                        w_cts22m00.atdprscod

             if w_cts22m00.hora      is null or
                w_cts22m00.data      is null or
                w_cts22m00.funmat    is null or
                w_cts22m00.cnldat    is null or
                w_cts22m00.atdfnlhor is null or
                w_cts22m00.c24opemat is null or
                w_cts22m00.atdprscod is null  then
                error " Faltam dados para entrada via formulario!"
                next field frmflg
             end if

             let d_cts22m00.atdlibhor = w_cts22m00.hora
             let d_cts22m00.atdlibdat = w_cts22m00.data
             let w_cts22m00.atdfnlflg = "S"
             let w_cts22m00.atdetpcod =  4
          end if

          while true
             if a_passag[01].pasnom is null  or
                a_passag[01].pasidd is null  then
                error " Informe a relacao de hospedes!"
                call cts11m01 (a_passag[01].*,
                               a_passag[02].*,
                               a_passag[03].*,
                               a_passag[04].*,
                               a_passag[05].*,
                               a_passag[06].*,
                               a_passag[07].*,
                               a_passag[08].*,
                               a_passag[09].*,
                               a_passag[10].*,
                               a_passag[11].*,
                               a_passag[12].*,
                               a_passag[13].*,
                               a_passag[14].*,
                               a_passag[15].*)
                     returning a_passag[01].*,
                               a_passag[02].*,
                               a_passag[03].*,
                               a_passag[04].*,
                               a_passag[05].*,
                               a_passag[06].*,
                               a_passag[07].*,
                               a_passag[08].*,
                               a_passag[09].*,
                               a_passag[10].*,
                               a_passag[11].*,
                               a_passag[12].*,
                               a_passag[13].*,
                               a_passag[14].*,
                               a_passag[15].*
             else
                exit while
             end if
          end while

   on key (interrupt)
      if g_documento.atdsrvnum  is null   then
         if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?",
                     "","") = "S"  then
            let int_flag = true
            exit input
         end if
      else
         exit input
      end if

   on key (F1)
      if g_documento.c24astcod is not null then
         call ctc58m00_vis(g_documento.c24astcod)
      end if

   on key (F4)
{
      if g_documento.succod    is not null  and
         g_documento.ramcod    is not null  and
         g_documento.aplnumdig is not null  then
         call f_funapol_ultima_situacao
           (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
            returning g_funapol.*
         select clscod
             from abbmclaus
            where succod    = g_documento.succod  and
                  aplnumdig = g_documento.aplnumdig and
                  itmnumdig = g_documento.itmnumdig and
                  dctnumseq = g_funapol.dctnumseq and
                  clscod    = "018"
          if sqlca.sqlcode  = 0  then
             if g_documento.atdsrvnum is null  or
                g_documento.atdsrvano is null  then
                if g_documento.cndslcflg  =  "S"  then
                   call cta07m00(g_documento.succod,    g_documento.aplnumdig,
                                 g_documento.itmnumdig, "I")
                else
                   call cta07m00(g_documento.succod,    g_documento.aplnumdig,
                                 g_documento.itmnumdig, "C")
                end if
             else
                call cta07m00(g_documento.succod,    g_documento.aplnumdig,
                              g_documento.itmnumdig, "C")
             end if
          else
             error "Docto nao possui clausula 18 !"
          end if
      else
         error "Condutor so' com Documento localizado!"
      end if
}
              if d_cts22m00.refatdsrvnum is null then
                 let l_servico = g_documento.atdsrvnum
                 let l_ano     = g_documento.atdsrvano
              else
                 let l_servico = d_cts22m00.refatdsrvnum
                 let l_ano     = d_cts22m00.refatdsrvano
              end if

              call ctx04g00_local_gps( l_servico,
                                       l_ano,
                                       1                       )
                             returning a_cts22m00[1].lclidttxt   ,
                                       a_cts22m00[1].lgdtip      ,
                                       a_cts22m00[1].lgdnom      ,
                                       a_cts22m00[1].lgdnum      ,
                                       a_cts22m00[1].lclbrrnom   ,
                                       a_cts22m00[1].brrnom      ,
                                       a_cts22m00[1].cidnom      ,
                                       a_cts22m00[1].ufdcod      ,
                                       a_cts22m00[1].lclrefptotxt,
                                       a_cts22m00[1].endzon      ,
                                       a_cts22m00[1].lgdcep      ,
                                       a_cts22m00[1].lgdcepcmp   ,
                                       a_cts22m00[1].lclltt      ,
                                       a_cts22m00[1].lcllgt      ,
                                       a_cts22m00[1].dddcod      ,
                                       a_cts22m00[1].lcltelnum   ,
                                       a_cts22m00[1].lclcttnom   ,
                                       a_cts22m00[1].c24lclpdrcod,
                                       a_cts22m00[1].celteldddcod,
                                       a_cts22m00[1].celtelnum   ,
                                       a_cts22m00[1].endcmp,
                                       ws.codigosql              ,
                                       a_cts22m00[2].emeviacod

              select ofnnumdig into a_cts22m00[1].ofnnumdig
                from datmlcl
               where atdsrvano = g_documento.atdsrvano
                 and atdsrvnum = g_documento.atdsrvnum
                 and c24endtip = 1

              let a_cts22m00[1].lgdtxt = a_cts22m00[1].lgdtip clipped, " ",
                                         a_cts22m00[1].lgdnom clipped, " ",
                                         a_cts22m00[1].lgdnum using "<<<<#"

              let a_cts22m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
              call cts06g03( 1, ## Local ocorrencia
                             2,
                             w_cts22m00.ligcvntip,
                             aux_today,
                             aux_hora,
                             a_cts22m00[1].lclidttxt,
                             a_cts22m00[1].cidnom,
                             a_cts22m00[1].ufdcod,
                             a_cts22m00[1].brrnom,
                             a_cts22m00[1].lclbrrnom,
                             a_cts22m00[1].endzon,
                             a_cts22m00[1].lgdtip,
                             a_cts22m00[1].lgdnom,
                             a_cts22m00[1].lgdnum,
                             a_cts22m00[1].lgdcep,
                             a_cts22m00[1].lgdcepcmp,
                             a_cts22m00[1].lclltt,
                             a_cts22m00[1].lcllgt,
                             a_cts22m00[1].lclrefptotxt,
                             a_cts22m00[1].lclcttnom,
                             a_cts22m00[1].dddcod,
                             a_cts22m00[1].lcltelnum,
                             a_cts22m00[1].c24lclpdrcod,
                             a_cts22m00[1].ofnnumdig,
                             a_cts22m00[1].celteldddcod   ,
                             a_cts22m00[1].celtelnum,
                             a_cts22m00[1].endcmp,
                             hist_cts22m00.*,
                             a_cts22m00[1].emeviacod)
                   returning a_cts22m00[1].lclidttxt,
                             a_cts22m00[1].cidnom,
                             a_cts22m00[1].ufdcod,
                             a_cts22m00[1].brrnom,
                             a_cts22m00[1].lclbrrnom,
                             a_cts22m00[1].endzon,
                             a_cts22m00[1].lgdtip,
                             a_cts22m00[1].lgdnom,
                             a_cts22m00[1].lgdnum,
                             a_cts22m00[1].lgdcep,
                             a_cts22m00[1].lgdcepcmp,
                             a_cts22m00[1].lclltt,
                             a_cts22m00[1].lcllgt,
                             a_cts22m00[1].lclrefptotxt,
                             a_cts22m00[1].lclcttnom,
                             a_cts22m00[1].dddcod,
                             a_cts22m00[1].lcltelnum,
                             a_cts22m00[1].c24lclpdrcod,
                             a_cts22m00[1].ofnnumdig,
                             a_cts22m00[1].celteldddcod   ,
                             a_cts22m00[1].celtelnum,
                             a_cts22m00[1].endcmp,
                             ws.retflg,
                             hist_cts22m00.*,
                             a_cts22m00[1].emeviacod

   on key (F5)
{
      if g_documento.succod    is not null  and
         g_documento.ramcod    is not null  and
         g_documento.aplnumdig is not null  then
         if g_documento.ramcod = 31    or
            g_documento.ramcod = 531  then
            call cta01m00()
         else
            call cta01m20()
         end if
      else
         if g_documento.prporg    is not null  and
            g_documento.prpnumdig is not null  then
            call opacc149(g_documento.prporg, g_documento.prpnumdig)
                      returning ws.prpflg
         else
            if g_documento.pcacarnum is not null  and
               g_documento.pcaprpitm is not null  then
               call cta01m50(g_documento.pcacarnum, g_documento.pcaprpitm)
            else
               error " Espelho so' com documento localizado!"
            end if
         end if
      end if
}
      let g_monitor.horaini = current ## Flexvision
      call cta01m12_espelho(g_documento.ramcod,
                            g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            g_documento.pcacarnum,
                            g_documento.pcaprpitm,
                            g_ppt.cmnnumdig,
                            g_documento.crtsaunum,
                            g_documento.bnfnum,
                            g_documento.ciaempcod)

   on key (F6)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         call cts10m02 (hist_cts22m00.*) returning hist_cts22m00.*
      else
         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat, aux_today, aux_hora)
      end if

   on key (F7)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         error " Impressao somente com cadastramento do servico!"
      else
         call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
      end if

   on key (F9)
      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         error " Servico nao cadastrado!"
      else
         if d_cts22m00.atdlibflg = "N"   then
            error " Servico nao liberado!"
         else
            call cta00m06_acionamento(g_issk.dptsgl)
            returning l_acesso
            if l_acesso = true then
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 0 )
            else
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 2 )
            end if
         end if
      end if

   on key (F10)
      call cts11m01 (a_passag[01].*,
                     a_passag[02].*,
                     a_passag[03].*,
                     a_passag[04].*,
                     a_passag[05].*,
                     a_passag[06].*,
                     a_passag[07].*,
                     a_passag[08].*,
                     a_passag[09].*,
                     a_passag[10].*,
                     a_passag[11].*,
                     a_passag[12].*,
                     a_passag[13].*,
                     a_passag[14].*,
                     a_passag[15].*)
           returning a_passag[01].*,
                     a_passag[02].*,
                     a_passag[03].*,
                     a_passag[04].*,
                     a_passag[05].*,
                     a_passag[06].*,
                     a_passag[07].*,
                     a_passag[08].*,
                     a_passag[09].*,
                     a_passag[10].*,
                     a_passag[11].*,
                     a_passag[12].*,
                     a_passag[13].*,
                     a_passag[14].*,
                     a_passag[15].*

   on key (F3)
      call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

  on key (f2) ##PSI207233
       if g_documento.c24astcod = "S11"  or
          g_documento.c24astcod = "S14"  or
          g_documento.c24astcod = "S53"  or
          g_documento.c24astcod = "S64"  or
          g_documento.c24astcod = "SUC"  then
           call ctb83m00()
               returning m_retctb83m00
       else
          error "Esse assunto nao possui tipo de pagamento"
       end if

 end input

 if int_flag then
    error " Operacao cancelada!"
 end if

 return hist_cts22m00.*

end function  ###  input_cts22m00
