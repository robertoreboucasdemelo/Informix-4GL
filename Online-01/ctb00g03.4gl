#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : PORTO SOCORRO                                               #
# Modulo         : ctb00g03                                                    #
#                  Metodo para inclusao de provisionamento - Apura o valor     #
#                  inicial dos serviços e provisiona.                          #
# Analista Resp. : Carlos Zyon                                                 #
#..............................................................................#
# Desenvolvimento: Fabrica de Software, JUNIOR                                 #
# OSF            : 35050                                                       #
# PSI            : 182516                                                      #
# Liberacao      :                                                             #
#..............................................................................#
#                           * * *  ALTERACOES  * * *                           #
# PSI       Autor            Data        Alteracao                             #
# --------  ---------------  ----------  --------------------------------------#
#                                                                              #
#                             * * * Alteracoes * * *                           #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- ------------------------------------ #
# 06/07/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch     #
#                              OSF036870  do Porto Socorro.                    #
# 06/12/2004 Mariana, Meta     PSI188220  Provisionar despesas do Porto Socorro#
# 28/12/2005 Cristiane Silva   AS88838    Buscar codigo de corretor diretamente#
#                                         da proposta quando nao houver apolice#
# 30/12/2005 Cristiane Silva   PSI196606  Interface PeopleSoft                 #
# 16/10/2006 Priscila          PSI202720  Implementacao saude + casa           #
# 30/06/2009 Fabio Costa       PSI 198404 Adequacoes People AP                 #
# 08/10/2009 PSI 247790        Burini     Adequação de tabelas                 #
# 29/12/2009 Fabio Costa       PSI 198404 Tratar fim de linha windows Ctrl+M   #
# 19/04/2010 Fabio Costa       PSI 198404 Tratar initialize, adequacao People  #
# 04/10/2010 Beatriz Araujo PSI-2010-00003 Verificar o ramo de contabilizacao  #
#                                          das clausulas - Circular 395        #
# 15/04/2013 Jorge Modena  PSI201308022EV Variar o Valor do Provisionamento    #
#                                          por Origem do Serviço               #
#------------------------------------------------------------------------------#

database porto

define m_ctb00g03   record
    conitfcod       like ctimsocprv.conitfcod,
    prvtip          like ctimsocprv.prvtip,
    empcod          like ctimsocprv.empcod,
    atdsrvnum       like ctimsocprv.atdsrvnum,
    atdsrvano       like ctimsocprv.atdsrvano,
    opgnum          like ctimsocprv.opgnum,
    opgitmnum       like ctimsocprv.opgitmnum,
    prvmvttip       like ctimsocprv.prvmvttip,
    opgmvttip       like ctimsocprv.opgmvttip,
    corsus          like ctimsocprv.corsus,
    nfsnum          like ctimsocprv.nfsnum,
    nfsemsdat       like ctimsocprv.nfsemsdat,
    nfsvncdat       like ctimsocprv.nfsvncdat,
    sinano          like ctimsocprv.sinano,
    sinnum          like ctimsocprv.sinnum,
    fvrnom          like ctimsocprv.fvrnom,
    opgvlr          like ctimsocprv.opgvlr,
    opgcncflg       like ctimsocprv.opgcncflg,
    opgprcflg       like ctimsocprv.opgprcflg,
    atldat          like ctimsocprv.atldat,
    atlemp          like ctimsocprv.atlemp,
    atlmat          like ctimsocprv.atlmat,
    atlusrtip       like ctimsocprv.atlusrtip,
    pestip          like ctimsocprv.pestip,
    succod          like ctimsocprv.succod,
    ramcod          like ctimsocprv.ramcod,
    rmemdlcod       like ctimsocprv.rmemdlcod,
    aplnumdig       like ctimsocprv.aplnumdig,
    itmnumdig       like ctimsocprv.itmnumdig,
    edsnumref       like ctimsocprv.edsnumref,
    atdsrvorg       like datmservico.atdsrvorg,
    atdprscod       like datmservico.atdprscod,
    asitipcod       like datmservico.asitipcod,
    vclcoddig       like datmservico.vclcoddig,
    vclcoddig_acn   like datmservico.vclcoddig,
    socvclcod       like datmservico.socvclcod,
    socgtfcod       like dbstgtfcst.socgtfcod,
    socgtfcod_acn   like dbstgtfcst.socgtfcod,
    soctrfcod       like dpaksocor.soctrfcod,
    soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum,
    atdsrvabrdat    like ctimsocprv.atdsrvabrdat,
    opgemsdat       like ctimsocprv.opgemsdat,
    ciaempcod       like datmservico.ciaempcod
end record

define ws record
        provisionamento char(06),
        empresa         smallint,
        socitmdspcod    like dbsmopgitm.socitmdspcod,
        atddat          like datmservico.atddat,
        cctnum char(06),
        ctbcrtcod       integer,
        atldat          like ctimsocprv.atldat,
        corsus          like ctimsocprv.corsus,
        nfsvncdat       like ctimsocprv.nfsvncdat,
        aplnumdig       like ctimsocprv.aplnumdig,
        atdsrvabrdat    like ctimsocprv.atdsrvabrdat,
        nfsnum          like ctimsocprv.nfsnum,
        rmemdlcod       like ctimsocprv.rmemdlcod,
        ramcod          like ctimsocprv.ramcod,
        nfsemsdat       like ctimsocprv.nfsemsdat,
        fvrnom          like ctimsocprv.fvrnom,
        emsdat          like abamapol.emsdat,
        descfvr         char(50),
        opgnum          like dbsmopgitm.socopgnum,
        ramo_novo       smallint,
        modalidade_nova dec(3,0),
        vlrprm          like dbsmopgitm.socopgitmvlr
end record

define m_data_processamento  date,
         m_reg_lidos           integer,
         m_reg_enviados        integer,
         m_reg_erros           integer,
         m_reg_erro_data       integer,
         m_reg_erro_empresa    integer,
         m_reg_erro_sucursal   integer,
         m_reg_erro_ramo       integer,
         m_reg_erro_modalidade integer,
         m_reg_erro_susep      integer,
         m_reg_erro_sinistro   integer,
         m_reg_erro_valor      integer,
         m_reg_erro_lote       integer,
         m_reg_erro_mq         integer,
         m_mensagemerro        char(200),
         m_valor_teste         like ctimsocprv.opgvlr,
         m_contab_teste        smallint,
         m_cortesia            char(300)


define ws_sqlcode    integer
define m_prep_flag   smallint
define m_ligcvntip   like datmligacao.ligcvntip
define ws_tipo  char(1)


#PSI196606 - inicio
define lr_evento                 record
         evento                  char(06),
         empresa                 char(50),
         dt_movto                date,
         chave_primaria          char(50),
         op                      char(50),
         apolice                 char(50),
         sucursal                char(50),
         projeto                 char(50),
         dt_chamado              date,
         fvrcod                  char(50),
         fvrnom                  char(50),
         nfnum                   char(50),
         corsus                  char(50),
         cctnum                  char(50),
         modalidade              char(50),
         ramo                    char(50),
         opgvlr                  char(50),
         dt_vencto               date
end record

define lr_eventoalt              record
         evento                  char(06),
         empresa                 char(50),
         dt_movto                date,
         chave_primaria          char(50),
         op                      char(50),
         apolice                 char(50),
         sucursal                char(50),
         projeto                 char(50),
         dt_chamado              date,
         fvrcod                  char(50),
         fvrnom                  char(50),
         nfnum                   char(50),
         corsus                  char(50),
         cctnum                  char(50),
         modalidade              char(50),
         ramo                    char(50),
         opgvlr                  char(50),
         dt_vencto               date,
         dt_ocorrencia           date
end record

define lr_eventobaixa            record
         evento                  char(06),
         empresa                 char(50),
         dt_movto                date,
         chave_primaria          char(50),
         op                      char(50),
         apolice                 char(50),
         sucursal                char(50),
         projeto                 char(50),
         dt_chamado              date,
         fvrcod                  char(50),
         fvrnom                  char(50),
         nfnum                   char(50),
         corsus                  char(50),
         cctnum                  char(50),
         modalidade              char(50),
         ramo                    char(50),
         opgvlr                  char(50),
         dt_vencto               date,
         dt_ocorrencia           date
end record

define lr_eventoinc            record
         evento                  char(06),
         empresa                 char(50),
         dt_movto                date,
         chave_primaria          char(50),
         op                      char(50),
         apolice                 char(50),
         sucursal                char(50),
         projeto                 char(50),
         dt_chamado              date,
         fvrcod                  char(50),
         fvrnom                  char(50),
         nfnum                   char(50),
         corsus                  char(50),
         cctnum                  char(50),
         modalidade              char(50),
         ramo                    char(50),
         opgvlr                  char(50),
         dt_vencto               date,
         dt_ocorrencia           date
end record

define lr_eventocan            record
         evento                  char(06),
         empresa                 char(50),
         dt_movto                date,
         chave_primaria          char(50),
         op                      char(50),
         apolice                 char(50),
         sucursal                char(50),
         projeto                 char(50),
         dt_chamado              date,
         fvrcod                  char(50),
         fvrnom                  char(50),
         nfnum                   char(50),
         corsus                  char(50),
         cctnum                  char(50),
         modalidade              char(50),
         ramo                    char(50),
         opgvlr                  char(50),
         dt_vencto               date,
         dt_ocorrencia           date
end record

define lr_eventoaju           record
         evento                  char(06),
         empresa                 char(50),
         dt_movto                date,
         chave_primaria          char(50),
         op                      char(50),
         apolice                 char(50),
         sucursal                char(50),
         projeto                 char(50),
         dt_chamado              date,
         fvrcod                  char(50),
         fvrnom                  char(50),
         nfnum                   char(50),
         corsus                  char(50),
         cctnum                  char(50),
         modalidade              char(50),
         ramo                    char(50),
         opgvlr                  char(50),
         dt_vencto               date,
         dt_ocorrencia           date
end record

#PSI196606 - fim

define l_prompt  char(1)

#--------------------------------------------------------------------------#
#------------   P R E P A R A N D O   C U R S O R E S  --------------------#
#--------------------------------------------------------------------------#
function ctb00g03_seleciona_sql()
#--------------------------------------------------------------------------#
    define l_cmd char(1500)

    ### // Seleciona o valor do ajuste //
    let l_cmd = " select opgvlr "
               ,"   from ctimsocprv  "
               ," where atdsrvnum = ? "
               ,"   and atdsrvano = ? "
               ,"   and prvmvttip = 2   "

    prepare pctb00g03001 from l_cmd
    declare cctb00g03001 cursor for pctb00g03001

    ### // Inclui registro na tabela da contabilidade //
    let l_cmd = " insert into ctimsocprv "
               ,"(conitfcod,prvtip,empcod,atdsrvnum,atdsrvano,opgnum,"
               ," opgitmnum,prvmvttip,opgmvttip,corsus,nfsnum,nfsemsdat,"
               ," nfsvncdat,sinano,sinnum,fvrnom,opgvlr,opgcncflg,"
               ," opgprcflg,atldat,atlemp,atlmat,atlusrtip,pestip,"
               ," succod,ramcod,rmemdlcod,aplnumdig,itmnumdig,edsnumref,"
               ," atdsrvabrdat,opgemsdat,dctcaddat,dctnumidf,srvabrclscod)"
               ," values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,"
               ,"        ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    prepare ipctb00g03001 from l_cmd
    ### // Procura se existe um registro já cadastrado no banco para fazer o update
    let l_cmd = "select opgnum from ctimsocprv ",
                " where empcod    = ? ",
                "   and opgnum    = ? ",
                "   and opgitmnum = ? ",
                "   and opgmvttip = ? ",
                "   and conitfcod = ? ",
                "   and prvmvttip = ? ",
                "   and atdsrvnum = ? ",
                "   and atdsrvano = ? "
    prepare ipctb00g03027 from l_cmd
    declare icctb00g03027 cursor for ipctb00g03027

    ### //Update de registro já cadastrado
    let l_cmd = " update ctimsocprv set opgvlr = opgvlr + ? ",
                "  where empcod    = ? ",
                "    and opgnum    = ? ",
                "    and opgitmnum = ? ",
                "    and opgmvttip = ? ",
                "    and conitfcod = ? ",
                "    and prvmvttip = ? ",
                "    and atdsrvnum = ? ",
                "    and atdsrvano = ? "
    prepare ipctb00g03028 from l_cmd

    let l_cmd = " select ratvlr "
               ,"   from ctimsocprvrat  "
               ," where empcod    = ? "
               ,"   and atdsrvnum = ? "
               ,"   and atdsrvano = ? "
               ,"   and opgnum    = ? "
               ,"   and opgitmnum = ? "
               ,"   and opgmvttip = ? "
               ,"   and succod    = ? "
               ,"   and cctcod    = ? "

    prepare pctb00g03002 from l_cmd
    declare cctb00g03002 cursor for pctb00g03002

let l_cmd = "update ctimsocprvrat "
           ,"   set ratvlr    = ratvlr + ? "
         ," where empcod    = ? "
           ,"   and atdsrvnum = ? "
           ,"   and atdsrvano = ? "
           ,"   and opgnum    = ? "
           ,"   and opgitmnum = ? "
           ,"   and opgmvttip = ? "
           ,"   and succod    = ? "
           ,"   and cctcod    = ? "

 prepare upctb00g03001 from l_cmd

let l_cmd = " insert into ctimsocprvrat "
           ,"(empcod,atdsrvnum,atdsrvano,opgnum,opgitmnum,"
           ," opgmvttip,succod,cctcod,ratvlr)"
           ," values(?,?,?,?,?,?,?,?,?) "
prepare ipctb00g03002 from l_cmd

    ### // Selecionar dados do serviço //
    let l_cmd = " select atdsrvorg, atddat, pgtdat, atdprscod, "
               ,"        asitipcod, vclcoddig, socvclcod, ciaempcod "
               ,"   from  datmservico  "
               ," where atdsrvnum = ? "
               ,"   and atdsrvano = ? "

    prepare pctb00g03003 from l_cmd
    declare cctb00g03003 cursor for pctb00g03003

    ### // Selecionar dados da apólice //
    let l_cmd = " select succod, ramcod, aplnumdig, itmnumdig, edsnumref"
               ,"   from  datrservapol  "
               ,"  where atdsrvnum = ? "
               ,"    and atdsrvano = ? "

    prepare pctb00g03004 from l_cmd
    declare cctb00g03004 cursor for pctb00g03004

    ### // Seleciona susep da apólice //

    let l_cmd = " select corsus "
               ,"   from  abamcor "
               ,"  where succod = ? "
               ,"    and aplnumdig = ? "
               ,"    and corlidflg = 'S' "

    prepare pctb00g03005 from l_cmd
    declare cctb00g03005 cursor for pctb00g03005

    ### // Seleciona a data de emissão da apólice //
    let l_cmd = " select emsdat "
               ,"   from  abamapol "
               ,"  where succod = ? "
               ,"    and aplnumdig = ? "

    prepare pctb00g03006 from l_cmd
    declare cctb00g03006 cursor for pctb00g03006

    ### // Seleciona os dados do prestador //
    let l_cmd = " select nomrazsoc, pestip, soctrfcod, crnpgtcod "
               ,"   from  dpaksocor "
               ," where pstcoddig = ? "

    prepare pctb00g03007 from l_cmd
    declare cctb00g03007 cursor for pctb00g03007

    ### // Seleciona a próxima data de entrega //
    let l_cmd = " select min(crnpgtetgdat) "
               ,"   from  dbsmcrnpgtetg "
               ," where crnpgtcod = ? "
               ,"   and crnpgtetgdat >= ? "

    prepare pctb00g03008 from l_cmd
    declare cctb00g03008 cursor for pctb00g03008

    ### // Seleciona os dados da ligação //
    let l_cmd = " select ligcvntip, c24astcod "
               ,"   from  datmligacao "
               ," where lignum = ? "

    prepare pctb00g03009 from l_cmd
    declare cctb00g03009 cursor for pctb00g03009


    ### // Seleciona a data do sinistro //
    let l_cmd = " select sindat "
               ,"   from  datmservicocmp "
               ," where atdsrvnum = ? "
               ,"   and atdsrvano = ? "

    prepare pctb00g03010 from l_cmd
    declare cctb00g03010 cursor for pctb00g03010

    ### // Seleciona a data da resolução 86 //
    let l_cmd = " select grlinf[1,10]  "
               ,"  from  datkgeral "
               ," where grlchv = 'ct24resolucao86' "

    prepare pctb00g03011 from l_cmd
    declare cctb00g03011 cursor for pctb00g03011

    ### // Seleciona os dados do provisionamento //
    let l_cmd = " select conitfcod, prvtip, empcod, atdsrvnum, "
               ,"        atdsrvano, opgnum, opgitmnum, prvmvttip, "
               ,"        opgmvttip, corsus, nfsnum, nfsemsdat,  "
               ,"        nfsvncdat, sinano, sinnum, fvrnom, opgvlr, "
               ,"        opgcncflg, opgprcflg, atldat, atlemp, atlmat, "
               ,"        atlusrtip, pestip, succod, ramcod, rmemdlcod, "
               ,"        aplnumdig, itmnumdig, edsnumref, atdsrvabrdat, "
               ,"        opgemsdat"
               ,"  from ctimsocprv "
               ," where atdsrvnum = ? "
               ,"   and atdsrvano = ? "
               ,"   and prvmvttip = 1 "   ### // Provisionamento //

    prepare pctb00g03012 from l_cmd
    declare cctb00g03012 cursor for pctb00g03012

    ### // Seleciona o código da tabela de vigência //
    let l_cmd = " select soctrfvignum "
               ,"  from  dbsmvigtrfsocorro "
               ," where soctrfcod = ? "
               ,"   and ? between soctrfvigincdat and soctrfvigfnldat "

    prepare pctb00g03013 from l_cmd
    declare cctb00g03013 cursor for pctb00g03013

    ### // Seleciona o grupo tarifário do veículo acionado //
    let l_cmd = " select vclcoddig "
               ,"  from datkveiculo "
               ," where socvclcod = ? "

    prepare pctb00g03014 from l_cmd
    declare cctb00g03014 cursor for pctb00g03014

    ### // Compara o grupo tarifário do veículo acionado //
    let l_cmd = " select socgtfcod "
               ,"  from  dbsrvclgtf "
               ," where vclcoddig = ? "

    prepare pctb00g03015 from l_cmd
    declare cctb00g03015 cursor for pctb00g03015

    ### // Verifica o preço de tabela da faixa 1=valor inicial //
    let l_cmd = " select socgtfcstvlr "
               ,"  from  dbstgtfcst "
               ," where soctrfvignum = ? "
               ,"   and socgtfcod    = ? "
               ,"   and soccstcod    = 1   "

    prepare pctb00g03016 from l_cmd
    declare cctb00g03016 cursor for pctb00g03016

    ### // Seleciona os dados do laudo de locação //
    let l_cmd = " select av.lcvcod, loc.lcvnom, av.aviestcod, av.avialgmtv, av.avioccdat, "
               ,"        av.avivclvlr, av.aviprvent, av.aviretdat, av.avivclcod "
               ,"  from  datmavisrent av,  datklocadora loc "
               ," where av.lcvcod = loc.lcvcod "
               ," and av.atdsrvnum = ? "
               ," and av.atdsrvano = ? "

    prepare pctb00g03017 from l_cmd
    declare cctb00g03017 cursor for pctb00g03017

    ### // Seleciona dados do favorecido //
    let l_cmd = " select favnom, pestip "
               ,"  from  datklcvfav "
               ," where lcvcod    = ? "
               ,"   and aviestcod = ? "

    prepare pctb00g03018 from l_cmd
    declare cctb00g03018 cursor for pctb00g03018

    ### // Seleciona os dados da loja locadora //
    let l_cmd = "  select lcvlojtip, lcvregprccod "
               ,"  from  datkavislocal "
               ," where aviestcod = ? "

    prepare pctb00g03019 from l_cmd
    declare cctb00g03019 cursor for pctb00g03019

    ### // Seleciona os dados da tarifa de locação //
    let l_cmd = "  select prtsgrvlr, diafxovlr "
               ,"    from  datklocaldiaria  "
               ,"   where avivclcod    = ? "
               ,"     and lcvlojtip    = ? "
               ,"     and lcvregprccod = ? "
               ,"     and lcvcod       = ? "
               ,"     and ? between viginc and vigfnl "
               ,"     and ? between fxainc and fxafnl "

    prepare pctb00g03020 from l_cmd
    declare cctb00g03020 cursor for pctb00g03020

    ### // Seleciona os dados do sinistro //
    let l_cmd = " select sinnum, sinano "
               ,"  from ssamsin "
               ," where succod    = ? "
               ,"   and aplnumdig = ? "
               ,"   and itmnumdig = ? "
               ,"   and orrdat    = ? "

    prepare pctb00g03021 from l_cmd
    declare cctb00g03021 cursor for pctb00g03021

    ### // Seleciona a modalidade //
    let l_cmd = " select rmemdlcod "
               ,"  from rsamseguro "
               ," where succod    = ? "
               ,"   and ramcod    = ? "
               ,"   and aplnumdig = ? "
    prepare pctb00g03022 from l_cmd
    declare cctb00g03022 cursor for pctb00g03022

    ### // Seleciona cláusulas //
    let l_cmd = " select count(*)  "
               ,"  from  abbmclaus "
               ," where succod    = ? "
               ,"   and aplnumdig = ? "
               ,"   and itmnumdig = ? "
               ,"   and clscod in('095','34A','35A','33','33R') "

    prepare pctb00g03023 from l_cmd
    declare cctb00g03023 cursor for pctb00g03023

    ### // Seleciona o valor do provisionamento de caixa //
    let l_cmd = " select opgvlr"
               ,"   from ctimsocprv"
               ,"  where atdsrvnum = ?  "
               ,"    and atdsrvano = ?  "
               ,"    and prvtip    = 'C'"   ## // Caixa //
               ,"    and prvmvttip = 3  "   ## // Provisionamento //

    prepare pctb00g03024 from l_cmd
    declare cctb00g03024 cursor for pctb00g03024

    ### // Seleciona o nome da loja locadora //
    let l_cmd = "select aviestnom"
               ,"  from  datkavislocal"
               ," where aviestcod = ?"

    prepare pctb00g03025 from l_cmd
    declare cctb00g03025 cursor for pctb00g03025

    ### // Seleciona o nome da locadora //
    let l_cmd = "select lcvnom"
               ,"  from  datklocadora"
               ," where lcvcod = ?"

    prepare pctb00g03026 from l_cmd
    declare cctb00g03026 cursor for pctb00g03026

    ### // Seleciona valores iniciais dos serviços //
    let l_cmd = " select grlinf, grlchv from  datkgeral "
               ,"  where grlchv >= ? and grlchv <= ?   "
               ,"  order by grlchv desc "
    prepare pctb00g03100 from l_cmd
    declare cctb00g03100 cursor for pctb00g03100

    ### // Seleciona corretor da proposta //
    let l_cmd = " select prp.prporg, prp.prpnumdig "
                ," from  datrligprp prp,  datmservico srv,  datmligacao lig "
                ," where srv.atdsrvnum = lig.atdsrvnum "
                ," and srv.atdsrvano = lig.atdsrvano "
                ," and lig.lignum = prp.lignum "
                ," and srv.atdsrvnum = ? "
                ," and srv.atdsrvano = ? "
    prepare pctb00g03101 from l_cmd
    declare cctb00g03101 cursor for pctb00g03101

    let l_cmd = " select corsus from  apamcor "
                ," where prporgpcp = ? "
                ," and prpnumpcp = ? "
                ," and corlidflg = 'S' "
    prepare pctb00g03102 from l_cmd
    declare cctb00g03102 cursor for pctb00g03102
    
    let l_cmd = "select ctbcrtcod from ctgrcrtram_new "
                ," where empcod = ? "
                ," and ramcod = ? "
                ," and rmemdlcod = ? "
                ," and ctbcrtcod not in (1981, 1965) "
    prepare pctb00g03104 from l_cmd
    declare cctb00g03104 cursor for pctb00g03104
    
    ###Identifica proposta caso apolice seja nula
    let l_cmd = "select prop.prpnumdig, prop.prporg "
                ," from  datrligprp prop,  datmligacao lig "
                ," where prop.lignum = lig.lignum "
                ," and lig.atdsrvnum = ? "
                ," and lig.atdsrvano = ? "
    prepare pctb00g03106 from l_cmd
    declare cctb00g03106 cursor for pctb00g03106

    let l_cmd = " select ciaempcod ",
                " from datmservico ",
                " where atdsrvnum = ? ",
                "   and atdsrvano = ? "
    prepare pctb00g03108 from l_cmd
    declare cctb00g03108 cursor for pctb00g03108

    let l_cmd = "select opgvlr ",
                 " from ctimsocprv ",
                " where empcod    = ? ",
                  " and opgnum    = ? ",
                  " and opgitmnum = ? ",
                  " and opgmvttip = ? ",
                  " and conitfcod = ? ",
                  " and prvmvttip = ? ",
                  " and atdsrvnum = ? ",
                  " and atdsrvano = ? "

    prepare pctb00g03109 from l_cmd
    declare cctb00g03109 cursor for pctb00g03109
    
    let l_cmd = "select a.atdsrvorg,   ",                
                "       b.pgttipcodps, ",
                "       d.itaasstipcod,",
                "       e.prporg,      ",
                "       e.prpnumdig,   ",
                "       c.c24astcod    ",
                "  from datmservico a, ",
                "       outer dbscadtippgt b,  ",
                "       datmligacao c,         ",
                "       datkassunto d,         ",
                "       outer datrligprp e     ",
                " where a.atdsrvnum = b.nrosrv ",
                "   and a.atdsrvano = b.anosrv ",
                "   and c.lignum = (select min(lignum) ",
                "                     from datmligacao ",
                "                    where atdsrvnum = a.atdsrvnum  ",
                "                      and atdsrvano = a.atdsrvano) ",
                "   and d.c24astcod = c.c24astcod                   ",
                "   and c.lignum = e.lignum                         ",
                "   and a.atdsrvnum = ?                             ",
                "   and a.atdsrvano = ?                             "
    prepare pctb00g03111 from l_cmd             
    declare cctb00g03111 cursor for pctb00g03111
     
    let l_cmd = " select 1                                               ",                            
                "   from datmservico srv,                                ", 
                "        datmcntsrv  ctg                                 ", 
                " where srv.atdsrvnum = ctg.atdsrvnum                    ", 
                "   and srv.atdsrvano = ctg.atdsrvano                    ", 
                "   and not exists ( select atdsrvnum                    ", 
                "                       from datrservapol doc            ", 
                "                    where doc.atdsrvnum = srv.atdsrvnum ", 
                "                      and doc.atdsrvano = srv.atdsrvano)", 
                "   and srv.atdsrvnum = ?                                ", 
                "   and srv.atdsrvano = ?                                "
   prepare pctb00g03112 from l_cmd
   declare cctb00g03112 cursor for pctb00g03112 
   
   ### // Seleciona o valor do ajuste //       
   let l_cmd = " select opgvlr "               
              ,"   from ctimsocprv  "          
              ," where atdsrvnum = ? "         
              ,"   and atdsrvano = ? "         
              ,"   and prvmvttip = 1   "       
                                               
   prepare pctb00g03113 from l_cmd             
   declare cctb00g03113 cursor for pctb00g03113
   
   let l_cmd  = "select cpodes                     ",                    
                "from iddkdominio                  ",
                "where cponom = 'valor_padrao'     ",          
                "and cpocod = ?                    "
               
   prepare pctb00g03114 from l_cmd             
   declare cctb00g03114 cursor for pctb00g03114   
   
   
   let l_cmd  = "select grlinf                     ",   
                "from datkgeral                    ",
                "where grlchv = 'PSOVLRPDRPVS'     "   
               
   prepare pctb00g03115 from l_cmd             
   declare cctb00g03115 cursor for pctb00g03115
  

     
end function

#--------------------------------------------------------------------------#
function ctb00g03_altprvdsp(l_param)
#--------------------------------------------------------------------------#

    define l_param      record
        atdsrvnum       like ctimsocprv.atdsrvnum,
        atdsrvano       like ctimsocprv.atdsrvano,
        opgnum          like ctimsocprv.opgnum,
        opgitmnum       like ctimsocprv.opgitmnum,
        novovalor       like ctimsocprv.opgvlr,
        nfsemsdat       like ctimsocprv.nfsemsdat,
        opgemsdat       like ctimsocprv.opgemsdat,
        nfsvncdat       like ctimsocprv.nfsvncdat
    end record

    define l_lcvcod         like datmavisrent.lcvcod
    define l_lcvnom         like datklocadora.lcvnom
    define l_vlrdifer       like ctimsocprv.opgvlr
    define l_aviestcod      like datmavisrent.aviestcod
    define l_avialgmtv      like datmavisrent.avialgmtv
    define l_avioccdat      like datmavisrent.avioccdat
    define l_avivclvlr      like datmavisrent.avivclvlr
    define l_aviprvent      like datmavisrent.aviprvent
    define l_avivclcod      like datmavisrent.avivclcod
    define l_lcvlojtip      like datkavislocal.lcvlojtip
    define l_lcvregprccod   like datkavislocal.lcvregprccod
    define l_lcvvcldiavlr   like datklocaldiaria.lcvvcldiavlr
    define l_prtsgrvlr      like datklocaldiaria.prtsgrvlr
    define l_diafxovlr      like datklocaldiaria.diafxovlr
    define l_atdprscod      like datmservico.atdprscod
    define l_notafiscal     like dbsmopgitm.nfsnum
    define l_prpnumdig      like datrligprp.prpnumdig
    define l_prporg         like datrligprp.prporg
    define lr_evento_baixa  char(06)
    define l_valorajuste    decimal(5,0)
    define l_cmd char(800)
    define ws_eventogrv_evento             char(06)
    define l_provisao       decimal(5,2)
    define l_ciaempcod      like datmservico.ciaempcod

    define ws_evento record
           evento                   char(06),
           empresa                 char(50),
           dt_movto                date,
           chave_primaria          char(50),
           op                      char(50),
           apolice                 char(50),
           sucursal                char(50),
           projeto                 char(50),
           dt_chamado              date,
           fvrcod                  char(50),
           fvrnom                  char(50),
           nfnum                   char(50),
           corsus                  char(50),
           cctnum                  char(50),
           modalidade              char(50),
           ramo                    char(50),
           opgvlr                  char(50),
           dt_vencto               date,
           dt_ocorrencia           date
    end record

    initialize m_ctb00g03.* to null
    initialize ws_evento.* to null
    initialize lr_eventoalt.* to null
    initialize lr_eventobaixa.* to null
    let m_valor_teste = 0
    let m_cortesia = " "

    let l_ciaempcod = 0

    let l_vlrdifer = 0

    let l_valorajuste = 0

    let ws_tipo = null

    let ws.descfvr = null

    let ws_eventogrv_evento = null

    let l_provisao = 0

    if m_prep_flag = false then
        call ctb00g03_seleciona_sql()
        let m_prep_flag = true
    end if

    ### // Seleciona os dados do provisionamento de despesa //
    call ctb00g03_selprvdsp(l_param.atdsrvnum,
                            l_param.atdsrvano)
                  returning ws_sqlcode

    ### // Se encontrou o provisionamento de despesa //
    if ws_sqlcode = 0 then
        let m_ctb00g03.opgnum       = l_param.opgnum
        let m_ctb00g03.opgitmnum    = l_param.opgitmnum
        let m_ctb00g03.prvmvttip    = 2   ### // Ajuste //
        let m_ctb00g03.atldat       = today
        let m_ctb00g03.opgprcflg    = "N"

        let m_ctb00g03.nfsemsdat    = l_param.nfsemsdat ### // Emissão NF //
        let m_ctb00g03.opgemsdat    = l_param.opgemsdat ### // Emissão OP //
        let m_ctb00g03.nfsvncdat    = l_param.nfsvncdat ### // Vencto  NF //

        ### // Guardar o valor do provisionamento //
        let l_provisao = 0.00
        let l_provisao = m_ctb00g03.opgvlr

        ### // Verifica se já foi efetuado algum provisionamento de caixa //
        open cctb00g03024 using l_param.atdsrvnum,
                                l_param.atdsrvano
        fetch cctb00g03024 into l_vlrdifer

        ### // Se não encontrou o provisionamento de caixa //
        if sqlca.sqlcode = notfound then

                ### // Identifica proposta caso apolice seja nula //
                open cctb00g03106 using l_param.atdsrvnum,
                                        l_param.atdsrvano
                fetch cctb00g03106 into l_prpnumdig, l_prporg
                if ws_sqlcode = notfound then
                        let l_prpnumdig = 0
                        let l_prporg = 0
                end if

                ### // Verifica se há diferença a provisionar //
                if m_ctb00g03.opgvlr <> l_param.novovalor then
                        if m_ctb00g03.opgvlr > l_param.novovalor then
                                let l_valorajuste = m_ctb00g03.opgvlr - l_param.novovalor
                        end if

                        ### // Inverte o valor original com o novo //
                        let m_ctb00g03.opgvlr = l_param.novovalor - m_ctb00g03.opgvlr
                else
                        let m_ctb00g03.opgvlr = 0.00
                end if

                ### // Se encontrou o provisionamento de caixa //
        else

                ### // Novo provisionamento de despesa com valor total + Nr. OP //
                let m_ctb00g03.opgvlr = l_param.novovalor

        end if

        #Identificando a empresa
        open cctb00g03108 using l_param.atdsrvnum, l_param.atdsrvano
        fetch cctb00g03108 into l_ciaempcod
        
        if m_ctb00g03.opgvlr <> 0 then

                ### // Inclui registro de ajuste na tabela da contabilidade //
                whenever error continue
                call ctb00g03_grvprvdsp(m_ctb00g03.conitfcod,
                                        m_ctb00g03.prvtip,
                                        m_ctb00g03.empcod,
                                        m_ctb00g03.atdsrvnum,
                                        m_ctb00g03.atdsrvano,
                                        m_ctb00g03.opgnum,
                                        m_ctb00g03.opgitmnum,
                                        m_ctb00g03.prvmvttip,
                                        m_ctb00g03.opgmvttip,
                                        m_ctb00g03.corsus,
                                        m_ctb00g03.nfsnum,
                                        m_ctb00g03.nfsemsdat,
                                        m_ctb00g03.nfsvncdat,
                                        m_ctb00g03.sinano,
                                        m_ctb00g03.sinnum,
                                        m_ctb00g03.fvrnom,
                                        m_ctb00g03.opgvlr,
                                        m_ctb00g03.opgcncflg,
                                        m_ctb00g03.opgprcflg,
                                        m_ctb00g03.atldat,
                                        m_ctb00g03.atlemp,
                                        m_ctb00g03.atlmat,
                                        m_ctb00g03.atlusrtip,
                                        m_ctb00g03.pestip,
                                        m_ctb00g03.succod,
                                        m_ctb00g03.ramcod,
                                        m_ctb00g03.rmemdlcod,
                                        m_ctb00g03.aplnumdig,
                                        m_ctb00g03.itmnumdig,
                                        m_ctb00g03.edsnumref,
                                        m_ctb00g03.atdsrvabrdat,
                                        m_ctb00g03.opgemsdat)
                                
                      returning sqlca.sqlcode, ws_eventogrv_evento

                whenever error stop
                if sqlca.sqlcode <> 0 then
                        display 'OCORREU UM ERRO EM   - ctb00g03_grvprvdsp - SqlCode ',sqlca.sqlcode
                        return sqlca.sqlcode, lr_eventoalt.*, lr_eventobaixa.*
                end if

                #AS 88838 inicio
                if m_ctb00g03.ramcod is null or m_ctb00g03.ramcod = 0 then
                        let m_ctb00g03.ramcod = 531
                end if
                if l_ciaempcod = 1 then
                        if m_ctb00g03.conitfcod = 5 then
                                let l_cmd = " select socitmdspcod, nfsnum from dbsmopgitm ",
                                " where atdsrvnum = ? ",
                                " and atdsrvano = ? "
                                prepare pctb00g03103 from l_cmd
                                declare cctb00g03103 cursor for pctb00g03103
                                open cctb00g03103 using l_param.atdsrvnum, l_param.atdsrvano
                                fetch cctb00g03103 into ws.socitmdspcod, l_notafiscal
                                close cctb00g03103
                                if ws.socitmdspcod is null or ws.socitmdspcod = 0 or ws.socitmdspcod = " " then
                                        let ws.socitmdspcod = m_ctb00g03.opgmvttip
                                end if
                                if m_ctb00g03.opgmvttip = 1 or
                                m_ctb00g03.opgmvttip = 5 or
                                m_ctb00g03.opgmvttip = 6 or
                                m_ctb00g03.opgmvttip = 7 then
                                        if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.117"
                                                else
                                                        let ws.provisionamento = "25.116"
                                                end if
                                        else
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.103"
                                                else
                                                        let ws.provisionamento = "25.90"
                                                end if
                                        end if
                                end if
                                if m_ctb00g03.opgmvttip = 2 then
                                        if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.117"
                                                else
                                                        let ws.provisionamento = "25.116"
                                                end if
                                        else
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.114"
                                                else
                                                        let ws.provisionamento = "25.100"
                                                end if
                                        end if
                                end if
                                if m_ctb00g03.opgmvttip = 4 then
                                        if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.117"
                                                else
                                                        let ws.provisionamento = "25.116"
                                                end if
                                        else
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.105"
                                                else
                                                        let ws.provisionamento = "25.92"
                                                end if
                                        end if
                                end if
                                if m_ctb00g03.opgmvttip = 21 or
                                m_ctb00g03.opgmvttip = 23 or
                                m_ctb00g03.opgmvttip = 25 or
                                m_ctb00g03.opgmvttip = 26 then
                                        if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.117"
                                                else
                                                        let ws.provisionamento = "25.116"
                                                end if
                                        else
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.109"
                                                else
                                                        let ws.provisionamento = "25.96"
                                                end if
                                        end if
                                end if
                                if m_ctb00g03.opgmvttip = 22 then
                                        if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.117"
                                                else
                                                        let ws.provisionamento = "25.116"
                                                end if
                                        else
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.102"
                                                else
                                                        let ws.provisionamento = "25.89"
                                                end if
                                        end if
                                end if
                                if m_ctb00g03.opgmvttip = 24 then
                                        if l_valorajuste > 0 then
                                                let ws.provisionamento = "25.110"
                                        else
                                                let ws.provisionamento = "25.97"
                                        end if
                                end if
                                if m_ctb00g03.opgmvttip = 30 then
                                        if l_valorajuste > 0 then
                                                let ws.provisionamento = "25.127"
                                        else
                                                let ws.provisionamento = "25.126"
                                        end if
                                end if
                        else
                                if m_ctb00g03.conitfcod = 25 then
                                        let l_cmd = " select socitmdspcod, nfsnum from dbsmopgitm ",
                                        " where socopgnum = ? ",
                                        " and socopgitmnum = ? "
                                        prepare pctb00g03105 from l_cmd
                                        declare cctb00g03105 cursor for pctb00g03105
                                        open cctb00g03105 using l_param.opgnum, l_param.opgitmnum
                                        fetch cctb00g03105 into ws.socitmdspcod, l_notafiscal
                                        close cctb00g03105
                                        if ws.socitmdspcod is null or ws.socitmdspcod = 0 then
                                                let ws.socitmdspcod = m_ctb00g03.opgmvttip
                                        end if
                                        if m_ctb00g03.opgmvttip = 1 then
                                                if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                        if l_valorajuste > 0 then
                                                                let ws.provisionamento = "25.117"
                                                        else
                                                                let ws.provisionamento = "25.116"
                                                        end if
                                                else
                                                        if l_valorajuste > 0 then
                                                                let ws.provisionamento = "25.106"
                                                        else
                                                                let ws.provisionamento = "25.93"
                                                        end if
                                                end if
                                        end if
                                        if m_ctb00g03.opgmvttip = 2 then
                                                if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                        if l_valorajuste > 0 then
                                                                let ws.provisionamento = "25.117"
                                                        else
                                                                let ws.provisionamento = "25.116"
                                                        end if
                                                else
                                                        if l_valorajuste > 0 then
                                                                let ws.provisionamento = "25.104"
                                                        else
                                                                let ws.provisionamento = "25.91"
                                                        end if
                                                end if
                                        end if
                                        if m_ctb00g03.opgmvttip = 3 then
                                                if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                        if l_valorajuste > 0 then
                                                                let ws.provisionamento = "25.117"
                                                        else
                                                                let ws.provisionamento = "25.116"
                                                        end if
                                                else
                                                        if l_valorajuste > 0 then
                                                                let ws.provisionamento = "25.112"
                                                        else
                                                                let ws.provisionamento = "25.99"
                                                        end if
                                                end if
                                        end if
                                        if m_ctb00g03.opgmvttip = 4 then
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.106"
                                                else
                                                        let ws.provisionamento = "25.93"
                                                end if
                                        end if
                                        if m_ctb00g03.opgmvttip = 5 then
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.104"
                                                else
                                                        let ws.provisionamento = "25.91"
                                                end if
                                        end if
                                        if m_ctb00g03.opgmvttip = 6 then
                                                if l_valorajuste > 0 then
                                                        let ws.provisionamento = "25.112"
                                                else
                                                        let ws.provisionamento = "25.99"
                                                end if
                                        end if
                                end if
                        end if
                else
                        if l_ciaempcod = 35 then
                                if l_valorajuste > 0 then
                                        let ws.provisionamento = "25.123"
                                else
                                        let ws.provisionamento = "25.124"
                                end if
                        end if
                end if

                # Tratando o ramo
                call depara_ramo(m_ctb00g03.ramcod, m_ctb00g03.rmemdlcod)
                returning ws.ramo_novo, ws.modalidade_nova

                if ws.ramo_novo <> 0 then
                        let m_ctb00g03.ramcod = ws.ramo_novo
                        let m_ctb00g03.rmemdlcod = ws.modalidade_nova
                end if


                #Identificando o centro de custo
                if m_ctb00g03.conitfcod = 5 then #auto e re

                        if m_ctb00g03.opgmvttip = 1 or m_ctb00g03.opgmvttip = 2 or
                        m_ctb00g03.opgmvttip = 4 or m_ctb00g03.opgmvttip = 5 or
                        m_ctb00g03.opgmvttip = 6 or m_ctb00g03.opgmvttip = 7 or
                        m_ctb00g03.opgmvttip = 21 or m_ctb00g03.opgmvttip = 22 or
                        m_ctb00g03.opgmvttip = 23 or m_ctb00g03.opgmvttip = 24 or
                        m_ctb00g03.opgmvttip = 25 or m_ctb00g03.opgmvttip = 26 then
                                call ctb00g03_ccusto(l_ciaempcod, m_ctb00g03.ramcod, m_ctb00g03.rmemdlcod)
                                returning ws.ctbcrtcod
                                if ws.ctbcrtcod = 0 or ws.ctbcrtcod is null then
                                        let ws.cctnum = 0
                                else
                                        let ws.cctnum = ws.ctbcrtcod
                                end if
                        end if
                end if

                if m_ctb00g03.conitfcod = 25 then #carro-extra
                        call ctb00g03_ccusto(l_ciaempcod, m_ctb00g03.ramcod, m_ctb00g03.rmemdlcod)
                        returning ws.ctbcrtcod
                        if ws.ctbcrtcod = 0 or ws.ctbcrtcod is null then
                                let ws.cctnum = 0
                        else
                                let ws.cctnum = ws.ctbcrtcod
                        end if
                end if


                #Preparando variáveis para interface
                #evento
                let lr_evento.evento = ws.provisionamento

                #Empresa e Data da competencia
                let l_cmd = "select empcod, atdprscod,atddat from datmservico where atdsrvnum = ? and atdsrvano = ?"
                prepare pctb00g03051 from l_cmd
                declare cctb00g03051 cursor for pctb00g03051

                whenever error continue
                        open cctb00g03051 using m_ctb00g03.atdsrvnum, m_ctb00g03.atdsrvano
                        fetch cctb00g03051 into ws.empresa, l_atdprscod,ws.atddat

                if ws.empresa is not null then
                        let lr_evento.empresa = ws.empresa
                end if

                let lr_evento.dt_movto = today
                
                close cctb00g03051    
                
                whenever error stop
                #Chave primaria
                #a chave primaria deste evento e composta por data competencia, evento, servico, op, data de vencimento, corretor
                let lr_evento.chave_primaria        = ws.atddat,
                                                    ws.provisionamento,
                                                    m_ctb00g03.atdsrvnum,
                                                    0,
                                                    m_ctb00g03.nfsvncdat,
                                                    m_ctb00g03.corsus

                #OP
                let lr_evento.op = m_ctb00g03.opgnum

                #Apolice
                if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                        open cctb00g03101 using m_ctb00g03.atdsrvnum,
                            m_ctb00g03.atdsrvano
                        fetch cctb00g03101 into l_prporg,
                            l_prpnumdig
                        close cctb00g03101
                        if l_prpnumdig is not null then
                                let lr_evento.apolice = l_prpnumdig
                        end if
                else
                        let lr_evento.apolice = m_ctb00g03.aplnumdig
                end if
                if lr_evento.apolice is null then
                        let lr_evento.apolice = 0
                end if

                #Sucursal
                if m_ctb00g03.succod is null or m_ctb00g03.succod = 0 then
                        let m_ctb00g03.succod = 1
                end if
                let lr_evento.sucursal = m_ctb00g03.succod

                #Projeto
                let lr_evento.projeto = m_ctb00g03.atdsrvnum

                #Data do Chamado
                let lr_evento.dt_chamado = m_ctb00g03.atdsrvabrdat

                #Favorecido
                if m_ctb00g03.conitfcod = 25 then
                        ### // Seleciona os dados do laudo de locação //
                        whenever error continue
                        open cctb00g03017 using m_ctb00g03.atdsrvnum,
                                            m_ctb00g03.atdsrvano
                        fetch cctb00g03017 into l_lcvcod   ,
                                                l_lcvnom,
                                                l_aviestcod,
                                                l_avialgmtv,
                                                l_avioccdat,
                                                l_avivclvlr,
                                                l_aviprvent,
                                                m_ctb00g03.nfsemsdat,
                                                l_avivclcod
                        whenever error stop
                        if sqlca.sqlcode < 0 then
                                display 'OCORREU UM ERRO EM cctb00g03017 - SqlCode ',sqlca.sqlcode
                                return sqlca.sqlcode, lr_eventoalt.*, lr_eventobaixa.*
                        end if
                        close cctb00g03017

                        let lr_evento.fvrcod = l_lcvcod
                        let lr_evento.fvrnom = l_lcvnom
                        call ctx25g05_carac_fon(lr_evento.fvrnom) returning ws.descfvr
                        if ws.descfvr is not null then
                                let lr_evento.fvrnom = ws.descfvr
                        end if

                else
                        if l_atdprscod is not null then
                                let lr_evento.fvrcod = l_atdprscod
                                let lr_evento.fvrnom = m_ctb00g03.fvrnom
                                call ctx25g05_carac_fon(lr_evento.fvrnom) returning ws.descfvr
                                if ws.descfvr is not null then
                                        let lr_evento.fvrnom = ws.descfvr
                                end if
                        end if
                end if

                #Nota fiscal
                if m_ctb00g03.nfsnum is null or m_ctb00g03.nfsnum = 0 then
                        if l_notafiscal is not null then
                                let lr_evento.nfnum = l_notafiscal
                        end if
                else
                        let lr_evento.nfnum = m_ctb00g03.nfsnum
                end if

                #Corretor
                let lr_evento.corsus = m_ctb00g03.corsus

                #Centro de custo
                let lr_evento.cctnum = ws.cctnum

                #Modalidade
                let lr_evento.modalidade = m_ctb00g03.rmemdlcod

                #Ramo
                let lr_evento.ramo = m_ctb00g03.ramcod

                #Valor
                if l_valorajuste > 0 and l_valorajuste is not null then
                        let lr_evento.opgvlr = m_ctb00g03.opgvlr * (-1)
                else
                        let lr_evento.opgvlr = m_ctb00g03.opgvlr
                end if

                #Data de vencimento
                let lr_evento.dt_vencto =  m_ctb00g03.nfsvncdat

                if lr_evento.evento is null or lr_evento.evento = 0 then
                        if l_ciaempcod = 1 then
                                if m_ctb00g03.conitfcod = 5 then
                                        let lr_evento.evento = "25.90"
                                else
                                        if m_ctb00g03.conitfcod = 25 then
                                                let lr_evento.evento = "25.91"
                                        else
                                                let lr_evento.evento = "25.96"
                                        end if
                                end if
                        else
                                let lr_evento.evento = "25.124"
                        end if
                end if

                call ctb00g03_evento_25(lr_evento.*)
                let lr_eventoalt.evento         = lr_evento.evento
                let lr_eventoalt.empresa        = lr_evento.empresa
                let lr_eventoalt.dt_movto       = lr_evento.dt_movto
                let lr_eventoalt.chave_primaria = lr_evento.chave_primaria
                let lr_eventoalt.op             = lr_evento.op
                let lr_eventoalt.apolice        = lr_evento.apolice
                let lr_eventoalt.sucursal       = lr_evento.sucursal
                let lr_eventoalt.projeto        = lr_evento.projeto
                let lr_eventoalt.dt_chamado     = lr_evento.dt_chamado
                let lr_eventoalt.fvrcod         = lr_evento.fvrcod
                let lr_eventoalt.fvrnom         = lr_evento.fvrnom
                let lr_eventoalt.nfnum          = lr_evento.nfnum
                let lr_eventoalt.corsus         = lr_evento.corsus
                let lr_eventoalt.cctnum         = lr_evento.cctnum
                let lr_eventoalt.modalidade     = lr_evento.modalidade
                let lr_eventoalt.ramo           = lr_evento.ramo
                let lr_eventoalt.opgvlr         = lr_evento.opgvlr
                let lr_eventoalt.dt_vencto      = lr_evento.dt_vencto
                let lr_eventoalt.dt_ocorrencia  = lr_evento.dt_chamado

                #Efetuar o envio da baixa do pagamento
                if l_ciaempcod = 1 then
                        if m_ctb00g03.conitfcod = 25 then #Carro-Extra
                                let lr_evento_baixa = null
                                whenever error continue
                                        open cctb00g03017 using m_ctb00g03.atdsrvnum,
                                                                m_ctb00g03.atdsrvano
                                        fetch cctb00g03017 into l_lcvcod   ,
                                                                l_lcvnom,
                                                                l_aviestcod,
                                                                l_avialgmtv,
                                                                l_avioccdat,
                                                                l_avivclvlr,
                                                                l_aviprvent,
                                                                m_ctb00g03.nfsemsdat,
                                                                l_avivclcod
                                whenever error stop
                                        if sqlca.sqlcode < 0 then
                                                display 'OCORREU UM ERRO EM cctb00g03017 - SqlCode ',sqlca.sqlcode
                                                return sqlca.sqlcode, lr_eventoalt.*, lr_eventobaixa.*
                                        end if
                                close cctb00g03017
                                if m_ctb00g03.opgmvttip = 1 or
                                m_ctb00g03.opgmvttip = 2 then
                                        if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                let lr_evento_baixa = "25.118"
                                        else
                                                let lr_evento_baixa = "25.2"
                                        end if
                                end if
                                if m_ctb00g03.opgmvttip = 3 then
                                        let lr_evento_baixa = "25.118"
                                end if
                                if m_ctb00g03.opgmvttip = 4 or
                                m_ctb00g03.opgmvttip = 5 or
                                m_ctb00g03.opgmvttip = 6 then
                                        let lr_evento_baixa = "25.119"
                                end if

                                let lr_evento.evento = null
                                let lr_evento.evento = lr_evento_baixa

                                let lr_evento.dt_movto = lr_evento.dt_vencto

                                if lr_evento.evento is null or lr_evento.evento = 0 then
                                        let lr_evento.evento = "25.2"
                                end if

                                if lr_evento.evento = "25.2" or lr_evento.evento = "25.119" then
                                        let lr_evento.opgvlr = l_provisao + lr_evento.opgvlr
                                        let lr_evento.opgvlr = lr_evento.opgvlr * (-1)
                                end if

                                call ctb00g03_evento_25(lr_evento.*)
                        else
                                let lr_evento_baixa = null
                                if m_ctb00g03.opgmvttip = 1 or
                                m_ctb00g03.opgmvttip = 4 or
                                m_ctb00g03.opgmvttip = 5 or
                                m_ctb00g03.opgmvttip = 6 or
                                m_ctb00g03.opgmvttip = 7 or
                                m_ctb00g03.opgmvttip = 22 then
                                        if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                let lr_evento_baixa = "25.118"
                                        else
                                                let lr_evento_baixa = "25.2"
                                        end if
                                end if
                                if m_ctb00g03.opgmvttip = 2 then
                                        if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                let lr_evento_baixa = "25.118"
                                        end if
                                end if
                                if m_ctb00g03.opgmvttip = 21 or
                                m_ctb00g03.opgmvttip = 23 or
                                m_ctb00g03.opgmvttip = 24 or
                                m_ctb00g03.opgmvttip = 25 or
                                m_ctb00g03.opgmvttip = 26 or
                                m_ctb00g03.opgmvttip = 30 then
                                        let lr_evento_baixa = "25.118"
                                end if

                                let lr_evento.evento = null
                                let lr_evento.evento = lr_evento_baixa

                                let lr_evento.dt_movto = lr_evento.dt_vencto

                                if lr_evento.evento is null or lr_evento.evento = 0 then
                                        let lr_evento.evento = "25.2"
                                end if
                                if lr_evento.evento = "25.2" or lr_evento.evento = "25.119"
                                or lr_evento.evento = "25.120" or lr_evento.evento = "25.118" then
                                        let lr_evento.opgvlr = l_provisao + lr_evento.opgvlr
                                        let lr_evento.opgvlr = lr_evento.opgvlr * (-1)
                                end if

                                call ctb00g03_evento_25(lr_evento.*)
                        end if
                end if

                let lr_eventobaixa.evento               = lr_evento.evento
                let lr_eventobaixa.empresa              = lr_evento.empresa
                let lr_eventobaixa.dt_movto             = lr_evento.dt_movto
                let lr_eventobaixa.chave_primaria       = lr_evento.chave_primaria
                let lr_eventobaixa.op                   = lr_evento.op
                let lr_eventobaixa.apolice              = lr_evento.apolice
                let lr_eventobaixa.sucursal             = lr_evento.sucursal
                let lr_eventobaixa.projeto              = lr_evento.projeto
                let lr_eventobaixa.dt_chamado           = lr_evento.dt_chamado
                let lr_eventobaixa.fvrcod               = lr_evento.fvrcod
                let lr_eventobaixa.fvrnom               = lr_evento.fvrnom
                let lr_eventobaixa.nfnum                = lr_evento.nfnum
                let lr_eventobaixa.corsus               = lr_evento.corsus
                let lr_eventobaixa.cctnum               = lr_evento.cctnum
                let lr_eventobaixa.modalidade           = lr_evento.modalidade
                let lr_eventobaixa.ramo                 = lr_evento.ramo
                let lr_eventobaixa.opgvlr               = lr_evento.opgvlr
                let lr_eventobaixa.dt_vencto            = lr_evento.dt_vencto
                let lr_eventobaixa.dt_ocorrencia        = lr_evento.dt_chamado
        else
                initialize lr_eventoalt.* to null
                initialize lr_eventobaixa.* to null
                return 0, lr_eventoalt.*, lr_eventobaixa.*
        end if
    else ### // Se não encontrou o registro, não faz ajuste //
          if sqlca.sqlcode <> 0 then
              initialize lr_eventoalt.* to null
              initialize lr_eventobaixa.* to null
              return 0, lr_eventoalt.*, lr_eventobaixa.*
          end if
    end if

    return sqlca.sqlcode, lr_eventoalt.*, lr_eventobaixa.*

end function

#--------------------------------------------------------------------------#
function ctb00g03_grvprvdsp(l_param_ctb00g03)
#--------------------------------------------------------------------------#

    define l_param_ctb00g03 record
        conitfcod      like ctimsocprv.conitfcod,
        prvtip         like ctimsocprv.prvtip,
        empcod         like ctimsocprv.empcod,
        atdsrvnum      like ctimsocprv.atdsrvnum,
        atdsrvano      like ctimsocprv.atdsrvano,
        opgnum         like ctimsocprv.opgnum,
        opgitmnum      like ctimsocprv.opgitmnum,
        prvmvttip      like ctimsocprv.prvmvttip,
        opgmvttip      like ctimsocprv.opgmvttip,
        corsus         like ctimsocprv.corsus,
        nfsnum         like ctimsocprv.nfsnum,
        nfsemsdat      like ctimsocprv.nfsemsdat,
        nfsvncdat      like ctimsocprv.nfsvncdat,
        sinano         like ctimsocprv.sinano,
        sinnum         like ctimsocprv.sinnum,
        fvrnom         like ctimsocprv.fvrnom,
        opgvlr         like ctimsocprv.opgvlr,
        opgcncflg      like ctimsocprv.opgcncflg,
        opgprcflg      like ctimsocprv.opgprcflg,
        atldat         like ctimsocprv.atldat,
        atlemp         like ctimsocprv.atlemp,
        atlmat         like ctimsocprv.atlmat,
        atlusrtip      like ctimsocprv.atlusrtip,
        pestip         like ctimsocprv.pestip,
        succod         like ctimsocprv.succod,
        ramcod         like ctimsocprv.ramcod,
        rmemdlcod      like ctimsocprv.rmemdlcod,
        aplnumdig      like ctimsocprv.aplnumdig,
        itmnumdig      like ctimsocprv.itmnumdig,
        edsnumref      like ctimsocprv.edsnumref,
        atdsrvabrdat   like ctimsocprv.atdsrvabrdat,
        opgemsdat      like ctimsocprv.opgemsdat
    end record
    
define l_ctb00g03_rcontabil record
    ctbramcod    like rsatdifctbramcvs.ctbramcod,
    ctbmdlcod    like rsatdifctbramcvs.ctbmdlcod,
    clscod       like rsatdifctbramcvs.clscod   , # codigo da clausula
    pgoclsflg    like dbskctbevnpam.pgoclsflg 
end record   


    define l_cmd             char(800),
           l_valorajuste_2   decimal(15,5),
           l_prpnumdig_2   	 like datrligprp.prpnumdig,
           l_prporg_2        like datrligprp.prporg,
           l_notafiscal_2    like dbsmopgitm.nfsnum,
           l_atdprscod_2   	 like datmservico.atdprscod,
           l_lcvcod_2      	 like datmavisrent.lcvcod,
           l_lcvnom_2        like datklocadora.lcvnom,
           l_aviestcod_2   	 like datmavisrent.aviestcod,
           l_avialgmtv_2   	 like datmavisrent.avialgmtv,
           l_avioccdat_2   	 like datmavisrent.avioccdat,
           l_avivclvlr_2   	 like datmavisrent.avivclvlr,
           l_aviprvent_2   	 like datmavisrent.aviprvent,
           l_avivclcod_2   	 like datmavisrent.avivclcod,
           l_prporg          like datrligprp.prporg,
           l_prpnumdig       like datrligprp.prpnumdig,
           lr_evento_bxa 	   char(06),
           ws_eventograva_evento char(06),
           l_ciaempcod           like datmservico.ciaempcod,
           l_opgvlr              like ctimsocprv.opgvlr,
           opgnumaux             like ctimsocprv.opgnum,
           l_doctip              char(3),
           l_docorg              like datrligprp.prporg,
           l_ligdctnum           dec(10,0),
           l_doctxt              char(20),
           l_errcod              smallint,
           l_lignum_aux          like datmligacao.lignum,
           l_dctcaddat           like ctimsocprv.dctcaddat,
           l_status              smallint
           
    initialize l_cmd           , l_valorajuste_2       ,
               l_prpnumdig_2   , l_prporg_2            ,
               l_notafiscal_2  , l_atdprscod_2         ,
               l_lcvcod_2      , l_lcvnom_2            ,
               l_aviestcod_2   , l_avialgmtv_2         ,
               l_avioccdat_2   , l_avivclvlr_2         ,
               l_aviprvent_2   , l_avivclcod_2         ,
               l_prporg        , l_prpnumdig           ,
               lr_evento_bxa   , ws_eventograva_evento ,
               l_ciaempcod     , l_opgvlr              ,
               opgnumaux       , l_doctip              ,
               l_docorg        , l_ligdctnum           ,
               l_doctxt        , l_errcod              ,
               l_lignum_aux    , l_dctcaddat           ,
               l_status          to null

    let l_valorajuste_2 = 0.00
    let l_ciaempcod     = 0
    let l_opgvlr        = 0
    let l_dctcaddat     = today

    initialize l_doctxt to null 
    initialize l_ctb00g03_rcontabil.* to null
    
    if m_prep_flag = false then
        call ctb00g03_seleciona_sql()
        let m_prep_flag = true
    end if

    #Identifica a empresa
    open cctb00g03108 using l_param_ctb00g03.atdsrvnum, l_param_ctb00g03.atdsrvano
    fetch cctb00g03108 into l_ciaempcod

    if l_param_ctb00g03.atdsrvabrdat is null then
    	let l_param_ctb00g03.atdsrvabrdat = today
    end if

    whenever error continue

        ### // Se for provisionamento de caixa //
        if l_param_ctb00g03.prvtip    = "C" and
           l_param_ctb00g03.prvmvttip = 3  then
                
               if l_param_ctb00g03.aplnumdig is null or
                  l_param_ctb00g03.aplnumdig = 0 then
                  ##Busca Codigo proposta/vist.previa/cob.prov. atendimento sem apolice
                    let  l_lignum_aux = 
                         cts20g00_servico(l_param_ctb00g03.atdsrvnum,
                                          l_param_ctb00g03.atdsrvano)

                    call ctb00g11(l_lignum_aux)
                         returning l_doctip,
                                   l_docorg,
                                   l_ligdctnum,
                                   l_doctxt,
                                   l_errcod 

                    if l_errcod < 0 and   
                       l_errcod <> 100 then
                       display 'OCORREU UM ERRO EM ctb00g03_grvprvdsp - SqlCode',
                               sqlca.sqlcode
                       return sqlca.sqlcode, ws_eventograva_evento
                    end if 
                end if

                ### // Verifica se há provisionamento de despesa //
                call ctb00g03_selprvdsp(l_param_ctb00g03.atdsrvnum,
                                        l_param_ctb00g03.atdsrvano)
                returning ws_sqlcode

                ### // Se não encontrou o provisionamento de despesa, gera //
                if ws_sqlcode = notfound then

                        if  l_doctip = "PRP" then
                            call faemc070("","",l_docorg,l_ligdctnum)
                                 returning l_param_ctb00g03.ramcod,
                                           l_param_ctb00g03.rmemdlcod,
                                           l_status
                        else
                            #PSI 249050 - DRE ISa+r (Modalidade)
                            if  l_param_ctb00g03.ramcod = 531 then
                                call faemc070(l_param_ctb00g03.succod,
                                              l_param_ctb00g03.aplnumdig,
                                              "","")
                                     returning l_param_ctb00g03.ramcod,
                                               l_param_ctb00g03.rmemdlcod,
                                               l_status
                            end if
                        end if
                       
                       #----------------------------------------------------------------------------------|                                                                                                                                                                                                                                                                                                    
                       # PSI-2010-00003 Beatriz Araujo - BUSCA O RAMO CONTABIL DO SERVICO PARA PAGAMENTO  |                                                                                                                                                                                                                                                                                                    
                       #----------------------------------------------------------------------------------| 
                        
                        call cts00g09_ramocontabil(l_param_ctb00g03.atdsrvnum,
                                                   l_param_ctb00g03.atdsrvano,
                                                   l_param_ctb00g03.rmemdlcod,
                                                   l_param_ctb00g03.ramcod)
                             returning l_ctb00g03_rcontabil.ctbramcod,
                                       l_ctb00g03_rcontabil.ctbmdlcod,
                                       l_ctb00g03_rcontabil.clscod,
                                       l_ctb00g03_rcontabil.pgoclsflg
                        
                        execute ipctb00g03001
                        using l_param_ctb00g03.conitfcod,
                        "D",
                        l_param_ctb00g03.empcod,
                        l_param_ctb00g03.atdsrvnum,
                        l_param_ctb00g03.atdsrvano,
                        "0",
                        "0",
                        "1",
                        l_param_ctb00g03.opgmvttip,
                        l_param_ctb00g03.corsus,
                        "0",
                        l_param_ctb00g03.nfsemsdat,
                        l_param_ctb00g03.nfsvncdat,
                        l_param_ctb00g03.sinano,
                        l_param_ctb00g03.sinnum,
                        l_param_ctb00g03.fvrnom,
                        l_param_ctb00g03.opgvlr,
                        "N",
                        "N",
                        l_param_ctb00g03.atldat,
                        l_param_ctb00g03.atlemp,
                        l_param_ctb00g03.atlmat,
                        l_param_ctb00g03.atlusrtip,
                        l_param_ctb00g03.pestip,
                        l_param_ctb00g03.succod,
                        l_ctb00g03_rcontabil.ctbramcod, #l_param_ctb00g03.ramcod,  retirando pela circular395 da susep
                        l_ctb00g03_rcontabil.ctbmdlcod, #l_param_ctb00g03.rmemdlcod,retirando pela circular395 da susep
                        l_param_ctb00g03.aplnumdig,
                        l_param_ctb00g03.itmnumdig,
                        l_param_ctb00g03.edsnumref,
                        l_param_ctb00g03.atdsrvabrdat,
                        l_param_ctb00g03.opgemsdat,
                        l_dctcaddat,
                        l_doctxt,
                        l_ctb00g03_rcontabil.clscod  
                         
                        whenever error stop
                        if sqlca.sqlcode < 0 then
                                display "ERRO no INSERT ipctb00g03001(a), sql = ", sqlca.sqlcode
                                return sqlca.sqlcode, ws_eventograva_evento
                        end if

                        if l_ciaempcod = 1 then
                                #Identificando se o valor pago eh diferente do valor provisionado
                                let l_cmd = " select opgvlr from ctimsocprv ",
                                            " where atdsrvnum = ? ",
                                        " and atdsrvano = ? ",
                                        " and opgnum = 0"
                                prepare pctb00g03107 from l_cmd
                                declare cctb00g03107 cursor for pctb00g03107
                                open cctb00g03107 using l_param_ctb00g03.atdsrvnum, l_param_ctb00g03.atdsrvano
                                fetch cctb00g03107 into l_valorajuste_2
                                close cctb00g03107
                                if l_param_ctb00g03.conitfcod = 5 then
                                        let l_cmd = " select socitmdspcod, nfsnum from dbsmopgitm ",
                                                    " where socopgnum = ? ",
                                                    " and socopgitmnum = ? "
                                        prepare pctb00g03103_2 from l_cmd
                                        declare cctb00g03103_2 cursor for pctb00g03103_2
                                        open cctb00g03103_2 using l_param_ctb00g03.opgnum, l_param_ctb00g03.opgitmnum
                                        fetch cctb00g03103_2 into ws.socitmdspcod, l_notafiscal_2
                                        close cctb00g03103_2
                                        if ws.socitmdspcod is null or ws.socitmdspcod = 0 then
                                                let ws.socitmdspcod = l_param_ctb00g03.opgmvttip
                                        end if
                                        if l_param_ctb00g03.opgmvttip = 1 or
                                        l_param_ctb00g03.opgmvttip = 5 or
                                        l_param_ctb00g03.opgmvttip = 6 or
                                        l_param_ctb00g03.opgmvttip = 7 then
                                                if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.117"
                                                        else
                                                                let ws.provisionamento = "25.116"
                                                        end if
                                                else
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.103"
                                                        else
                                                                let ws.provisionamento = "25.90"
                                                        end if
                                                end if
                                        end if
                                        if l_param_ctb00g03.opgmvttip = 2 then
                                                if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.117"
                                                        else
                                                                let ws.provisionamento = "25.116"
                                                        end if
                                                else
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.114"
                                                        else
                                                                let ws.provisionamento = "25.100"
                                                        end if
                                                end if
                                        end if
                                        if l_param_ctb00g03.opgmvttip = 4 then
                                                if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.117"
                                                        else
                                                                let ws.provisionamento = "25.116"
                                                        end if
                                                else
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.105"
                                                        else
                                                                let ws.provisionamento = "25.92"
                                                        end if
                                                end if
                                        end if
                                        if l_param_ctb00g03.opgmvttip = 21 or
                                        l_param_ctb00g03.opgmvttip = 23 or
                                        l_param_ctb00g03.opgmvttip = 25 or
                                        l_param_ctb00g03.opgmvttip = 26 then
                                                if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.117"
                                                        else
                                                                let ws.provisionamento = "25.116"
                                                        end if
                                                else
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.109"
                                                        else
                                                                let ws.provisionamento = "25.96"
                                                        end if
                                                end if
                                        end if
                                        if l_param_ctb00g03.opgmvttip = 22 then
                                                if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.117"
                                                        else
                                                                let ws.provisionamento = "25.116"
                                                        end if
                                                else
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.102"
                                                        else
                                                                let ws.provisionamento = "25.89"
                                                        end if
                                                end if
                                        end if
                                        if l_param_ctb00g03.opgmvttip = 24 then
                                                if l_valorajuste_2 > 0 then
                                                        let ws.provisionamento = "25.110"
                                                else
                                                        let ws.provisionamento = "25.97"
                                                end if
                                        end if
                                        if l_param_ctb00g03.opgmvttip = 30 then
                                                if l_valorajuste_2 > 0 then
                                                        let ws.provisionamento = "25.127"
                                                else
                                                        let ws.provisionamento = "25.126"
                                                end if
                                        end if
                                else
                                        if l_param_ctb00g03.conitfcod = 25 then
                                                let l_cmd = " select socitmdspcod, nfsnum from dbsmopgitm ",
                                                            " where socopgnum = ? ",
                                                            " and socopgitmnum = ? "
                                                prepare pctb00g03105_2 from l_cmd
                                                declare cctb00g03105_2 cursor for pctb00g03105_2
                                                open cctb00g03105_2 using l_param_ctb00g03.opgnum, l_param_ctb00g03.opgitmnum
                                                fetch cctb00g03105_2 into ws.socitmdspcod, l_notafiscal_2
                                                close cctb00g03105_2
                                                if ws.socitmdspcod is null or ws.socitmdspcod = 0 then
                                                        let ws.socitmdspcod = l_param_ctb00g03.opgmvttip
                                                end if
                                                if l_param_ctb00g03.opgmvttip = 1 then
                                                        if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                                                if l_valorajuste_2 > 0 then
                                                                        let ws.provisionamento = "25.117"
                                                                else
                                                                        let ws.provisionamento = "25.116"
                                                                end if
                                                        else
                                                                if l_valorajuste_2 > 0 then
                                                                        let ws.provisionamento = "25.106"
                                                                else
                                                                        let ws.provisionamento = "25.93"
                                                                end if
                                                        end if
                                                end if
                                                if l_param_ctb00g03.opgmvttip = 2 then
                                                        if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                                                if l_valorajuste_2 > 0 then
                                                                        let ws.provisionamento = "25.117"
                                                                else
                                                                        let ws.provisionamento = "25.116"
                                                                end if
                                                        else
                                                                if l_valorajuste_2 > 0 then
                                                                        let ws.provisionamento = "25.104"
                                                                else
                                                                        let ws.provisionamento = "25.91"
                                                                end if
                                                        end if
                                                end if
                                                if l_param_ctb00g03.opgmvttip = 3 then
                                                        if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                                                if l_valorajuste_2 > 0 then
                                                                        let ws.provisionamento = "25.117"
                                                                else
                                                                        let ws.provisionamento = "25.116"
                                                                end if
                                                        else
                                                                if l_valorajuste_2 > 0 then
                                                                        let ws.provisionamento = "25.112"
                                                                else
                                                                        let ws.provisionamento = "25.99"
                                                                end if
                                                        end if
                                                end if
                                                if l_param_ctb00g03.opgmvttip = 4 then
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.106"
                                                        else
                                                                let ws.provisionamento = "25.93"
                                                        end if
                                                end if
                                                if l_param_ctb00g03.opgmvttip = 5 then
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.104"
                                                        else
                                                                let ws.provisionamento = "25.91"
                                                        end if
                                                end if
                                                if l_param_ctb00g03.opgmvttip = 6 then
                                                        if l_valorajuste_2 > 0 then
                                                                let ws.provisionamento = "25.112"
                                                        else
                                                                let ws.provisionamento = "25.99"
                                                        end if
                                                end if
                                        end if
                                end if
                        else
                                if l_ciaempcod = 35 then
                                        if l_valorajuste_2 > l_param_ctb00g03.opgvlr then
                                                let ws.provisionamento = "25.123"
                                        else
                                                let ws.provisionamento = "25.124"
                                        end if
                                end if
                        end if

                        # Tratando o ramo
                        call depara_ramo(m_ctb00g03.ramcod, m_ctb00g03.rmemdlcod)
                        returning ws.ramo_novo, ws.modalidade_nova

                        if ws.ramo_novo <> 0 then
                                let m_ctb00g03.ramcod = ws.ramo_novo
                                let m_ctb00g03.rmemdlcod = ws.modalidade_nova
                        end if



                        #Identificando o centro de custo
                        if l_param_ctb00g03.conitfcod = 5 then #auto e re
                                if l_param_ctb00g03.opgmvttip = 1 or l_param_ctb00g03.opgmvttip = 2 or
                                l_param_ctb00g03.opgmvttip = 4 or l_param_ctb00g03.opgmvttip = 5 or
                                l_param_ctb00g03.opgmvttip = 6 or l_param_ctb00g03.opgmvttip = 7 or
                                l_param_ctb00g03.opgmvttip = 21 or l_param_ctb00g03.opgmvttip = 22 or
                                l_param_ctb00g03.opgmvttip = 23 or l_param_ctb00g03.opgmvttip = 24 or
                                l_param_ctb00g03.opgmvttip = 25 or l_param_ctb00g03.opgmvttip = 26 then
                                        call ctb00g03_ccusto(l_ciaempcod,l_param_ctb00g03.ramcod, l_param_ctb00g03.rmemdlcod)
                                        returning ws.ctbcrtcod
                                        if ws.ctbcrtcod = 0 or ws.ctbcrtcod is null then
                                                let ws.cctnum = 0
                                        else
                                                let ws.cctnum = ws.ctbcrtcod
                                        end if
                                end if
                        end if
                        if l_param_ctb00g03.conitfcod = 25 then #carro-extra
                                call ctb00g03_ccusto(l_ciaempcod, l_param_ctb00g03.ramcod, l_param_ctb00g03.rmemdlcod)
                                returning ws.ctbcrtcod
                                if ws.ctbcrtcod = 0 or ws.ctbcrtcod is null then
                                        let ws.cctnum = 0
                                else
                                        let ws.cctnum = ws.ctbcrtcod
                                end if
                        end if

                        #Preparando variáveis para interface
                        #evento
                        let lr_evento.evento = ws.provisionamento

                        #Empresa
                        let l_cmd = "select empcod, atdprscod from datmservico where atdsrvnum = ? and atdsrvano = ?"
                        prepare pctb00g03051_2 from l_cmd
                        declare cctb00g03051_2 cursor for pctb00g03051_2
                        whenever error continue
                                open cctb00g03051_2 using l_param_ctb00g03.atdsrvnum, l_param_ctb00g03.atdsrvano
                                fetch cctb00g03051_2 into ws.empresa, l_atdprscod_2
                        whenever error stop
                                if sqlca.sqlcode <> 0 then
                                        error "Erro ao selecionar empresa cctb00g03020:, ", sqlca.sqlcode, " = ", sqlca.sqlerrd[2]
                                end if
                        close cctb00g03051_2
                        if ws.empresa is not null then
                                let lr_evento.empresa = ws.empresa
                        end if

                        #Data da competencia
                        let lr_evento.dt_movto = l_param_ctb00g03.atldat

                        #Chave primaria
                        #a chave primaria deste evento e composta por data competencia, evento, servico, op, data de vencimento, corretor
                        let lr_evento.chave_primaria =  l_param_ctb00g03.atldat,
                                                        ws.provisionamento,
                                                        l_param_ctb00g03.atdsrvnum,
                                                        0,
                                                        l_param_ctb00g03.nfsvncdat,
                                                        l_param_ctb00g03.corsus

                        #OP
                        let lr_evento.op = l_param_ctb00g03.opgnum

                        #Apolice
                        if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                open cctb00g03101 using l_param_ctb00g03.atdsrvnum,
                                                        m_ctb00g03.atdsrvano
                                fetch cctb00g03101 into l_prporg,
                                                        l_prpnumdig
                                close cctb00g03101
                                if l_prpnumdig is not null then
                                        let lr_evento.apolice = l_prpnumdig
                                end if
                        else
                                let lr_evento.apolice = l_param_ctb00g03.aplnumdig
                        end if
                        if lr_evento.apolice is null then
                                let lr_evento.apolice = 0
                        end if

                        #Sucursal
                        if l_param_ctb00g03.succod is null or l_param_ctb00g03.succod = 0 then
                                let l_param_ctb00g03.succod = 1
                        end if
                        let lr_evento.sucursal = l_param_ctb00g03.succod

                        #Projeto
                        let lr_evento.projeto = l_param_ctb00g03.atdsrvnum

                        #Data do Chamado
                        let lr_evento.dt_chamado = l_param_ctb00g03.atdsrvabrdat
                        if lr_evento.dt_chamado is null then
                                let lr_evento.dt_chamado = today
                        end if

                        #Favorecido
                        if l_param_ctb00g03.conitfcod = 25 then
                                ### // Seleciona os dados do laudo de locação //
                                whenever error continue
                                        open cctb00g03017 using l_param_ctb00g03.atdsrvnum,
                                                                l_param_ctb00g03.atdsrvano
                                        fetch cctb00g03017 into l_lcvcod_2   ,
                                                                l_lcvnom_2,
                                                                l_aviestcod_2,
                                                                l_avialgmtv_2,
                                                                l_avioccdat_2,
                                                                l_avivclvlr_2,
                                                                l_aviprvent_2,
                                                                l_param_ctb00g03.nfsemsdat,
                                                                l_avivclcod_2
                                whenever error stop
                                        if sqlca.sqlcode < 0 then
                                                display 'OCORREU UM ERRO EM cctb00g03017 - SqlCode ',sqlca.sqlcode
                                                return sqlca.sqlcode, ws_eventograva_evento
                                        end if
                                close cctb00g03017

                                let lr_evento.fvrcod = l_lcvcod_2
                                let lr_evento.fvrnom = l_lcvnom_2
                                call ctx25g05_carac_fon(lr_evento.fvrnom) returning ws.descfvr
                                if ws.descfvr is not null then
                                        let lr_evento.fvrnom = ws.descfvr
                                end if
                        else
                                if l_atdprscod_2 is not null then
                                        let lr_evento.fvrcod = l_atdprscod_2
                                        let lr_evento.fvrnom = l_param_ctb00g03.fvrnom
                                        call ctx25g05_carac_fon(lr_evento.fvrnom) returning ws.descfvr
                                        if ws.descfvr is not null then
                                                let lr_evento.fvrnom = ws.descfvr
                                        end if
                                end if
                        end if

                        #Nota fiscal
                        if l_param_ctb00g03.nfsnum is null or l_param_ctb00g03.nfsnum = 0 then
                                if l_notafiscal_2 is not null then
                                        let lr_evento.nfnum = l_notafiscal_2
                                end if
                        else
                                let lr_evento.nfnum = l_param_ctb00g03.nfsnum
                        end if

                        #Corretor
                        let lr_evento.corsus = l_param_ctb00g03.corsus

                        #Centro de custo
                        let lr_evento.cctnum = ws.cctnum

                        #Modalidade
                        let lr_evento.modalidade = l_param_ctb00g03.rmemdlcod

                        #Ramo
                        let lr_evento.ramo = l_param_ctb00g03.ramcod

                        #Valor
                        let lr_evento.opgvlr = l_param_ctb00g03.opgvlr

                        #Data de vencimento
                        let lr_evento.dt_vencto =  l_param_ctb00g03.nfsvncdat

                        if lr_evento.evento is null or lr_evento.evento = 0 then
                                let lr_evento.evento = "25.92"
                        end if

                        call ctb00g03_evento_25(lr_evento.*)

                        let ws_eventograva_evento = lr_evento.evento

                        #Efetuar o envio da baixa do pagamento
                        if l_ciaempcod = 1 then
                                if l_param_ctb00g03.conitfcod = 25 then #Carro-Extra
                                        let lr_evento_bxa = null
                                        whenever error continue
                                                open cctb00g03017 using l_param_ctb00g03.atdsrvnum,
                                                                        l_param_ctb00g03.atdsrvano
                                                fetch cctb00g03017 into l_lcvcod_2   ,
                                                                        l_lcvnom_2,
                                                                        l_aviestcod_2,
                                                                        l_avialgmtv_2,
                                                                        l_avioccdat_2,
                                                                        l_avivclvlr_2,
                                                                        l_aviprvent_2,
                                                                        l_param_ctb00g03.nfsemsdat,
                                                                        l_avivclcod_2
                                        whenever error stop
                                                if sqlca.sqlcode < 0 then
                                                        display 'OCORREU UM ERRO EM cctb00g03017 - SqlCode ',sqlca.sqlcode
                                                        return sqlca.sqlcode, ws_eventograva_evento
                                                end if
                                        close cctb00g03017
                                        if l_param_ctb00g03.opgmvttip = 1 or
                                        l_param_ctb00g03.opgmvttip = 2 then
                                                if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                                        let lr_evento_bxa = "25.118"
                                                else
                                                        let lr_evento_bxa = "25.2"
                                                end if
                                        end if
                                        if l_param_ctb00g03.opgmvttip = 3 then
                                                let lr_evento_bxa = "25.118"
                                        end if
                                        if l_param_ctb00g03.opgmvttip = 4 or
                                        l_param_ctb00g03.opgmvttip = 5 or
                                        l_param_ctb00g03.opgmvttip = 6 then
                                                let lr_evento_bxa = "25.119"
                                        end if

                                        let lr_evento.evento = null
                                        let lr_evento.evento = lr_evento_bxa

                                        let lr_evento.dt_movto = lr_evento.dt_vencto

                                        if lr_evento.evento is null or lr_evento.evento = 0 then
                                                let lr_evento.evento = "25.2"
                                        end if

                                        if lr_evento.evento = "25.2" or lr_evento.evento = "25.119" then
                                                let lr_evento.opgvlr = lr_evento.opgvlr * (-1)
                                        end if


                                        #call ctb00g03_evento_25(lr_evento.*)

                                        let ws_eventograva_evento = lr_evento.evento
                                else
                                        let lr_evento_bxa = null
                                        if l_param_ctb00g03.opgmvttip = 1 or
                                        l_param_ctb00g03.opgmvttip = 4 or
                                        l_param_ctb00g03.opgmvttip = 5 or
                                        l_param_ctb00g03.opgmvttip = 6 or
                                        l_param_ctb00g03.opgmvttip = 7 or
                                        l_param_ctb00g03.opgmvttip = 22 then
                                                if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                                        let lr_evento_bxa = "25.118"
                                                else
                                                        let lr_evento_bxa = "25.2"
                                                end if
                                        end if
                                        if l_param_ctb00g03.opgmvttip = 2 then
                                                if l_param_ctb00g03.aplnumdig is null or l_param_ctb00g03.aplnumdig = 0 then
                                                        let lr_evento_bxa = "25.118"
                                                end if
                                        end if
                                        if l_param_ctb00g03.opgmvttip = 21 or
                                        l_param_ctb00g03.opgmvttip = 23 or
                                        l_param_ctb00g03.opgmvttip = 24 or
                                        l_param_ctb00g03.opgmvttip = 25 or
                                        l_param_ctb00g03.opgmvttip = 26 or
                                        l_param_ctb00g03.opgmvttip = 30 then
                                                let lr_evento_bxa = "25.118"
                                        end if

                                        let lr_evento.evento = null
                                        let lr_evento.evento = lr_evento_bxa

                                        let lr_evento.dt_movto = lr_evento.dt_vencto

                                        if lr_evento.evento is null or lr_evento.evento = 0 then
                                                let lr_evento.evento = "25.2"
                                        end if
                                        if lr_evento.evento = "25.2" or lr_evento.evento = "25.119"
                                        or lr_evento.evento = "25.120" or lr_evento.evento = "25.118" then
                                                let lr_evento.opgvlr = lr_evento.opgvlr * (-1)
                                        end if
                                end if
                                call ctb00g03_evento_25(lr_evento.*)
                                let ws_eventograva_evento = lr_evento.evento

                        end if ### // l_ciaempcod
                end if ### // ws_sqlcode = notfound //
        end if ### // l_param_ctb00g03.prvtip = "C" and l_param_ctb00g03.prvmvttip = 3 //

        whenever error continue

        open cctb00g03109 using l_param_ctb00g03.empcod,
                                l_param_ctb00g03.opgnum,
                                l_param_ctb00g03.opgitmnum,
                                l_param_ctb00g03.opgmvttip,
                                l_param_ctb00g03.conitfcod,
                                l_param_ctb00g03.prvmvttip,
                                l_param_ctb00g03.atdsrvnum,
                                l_param_ctb00g03.atdsrvano

        fetch cctb00g03109 into l_opgvlr

        if  sqlca.sqlcode = 0 then
            let l_param_ctb00g03.opgvlr = l_param_ctb00g03.opgvlr + l_opgvlr
        end if

        if l_param_ctb00g03.aplnumdig is null or 
           l_param_ctb00g03.aplnumdig = 0 then
           ##Busca Codigo proposta/vist.previa/cob.prov. atendimento sem apolice
  
           let  l_lignum_aux = cts20g00_servico(l_param_ctb00g03.atdsrvnum,
                                                l_param_ctb00g03.atdsrvano)
  
           call ctb00g11(l_lignum_aux)
                  returning l_doctip,
                            l_docorg,
                            l_ligdctnum,
                            l_doctxt,
                            l_errcod
   
           if l_errcod < 0 and  
              l_errcod <> 100 then
              display 'OCORREU UM ERRO EM ctb00g03_grvprvdsp - SqlCode',
                      sqlca.sqlcode
              return sqlca.sqlcode, ws_eventograva_evento
           end if

           if  l_dctcaddat is null then
               Let  l_dctcaddat = today
           end if
        end if

        #Verifica se existe registro na tabela para prorrogação
        open icctb00g03027 using  l_param_ctb00g03.empcod,
                                  l_param_ctb00g03.opgnum,
                                  l_param_ctb00g03.opgitmnum,
                                  l_param_ctb00g03.opgmvttip,
                                  l_param_ctb00g03.conitfcod,
                                  l_param_ctb00g03.prvmvttip,
                                  l_param_ctb00g03.atdsrvnum,
                                  l_param_ctb00g03.atdsrvano
        fetch icctb00g03027 into  opgnumaux

        if sqlca.sqlcode = notfound then
                            
            #PSI 249050 - DRE ISa+r (Modalidade)
            if  l_param_ctb00g03.ramcod = 531 then
                call faemc070(l_param_ctb00g03.succod,
                              l_param_ctb00g03.aplnumdig,
                              "","")
                     returning l_param_ctb00g03.ramcod,
                               l_param_ctb00g03.rmemdlcod,
                               l_status
            end if
              
            #----------------------------------------------------------------------------------|                                                                                                                                                                                                                                                                                                    
            # PSI-2010-00003 Beatriz Araujo - BUSCA O RAMO CONTABIL DO SERVICO PARA PAGAMENTO  |                                                                                                                                                                                                                                                                                                    
            #----------------------------------------------------------------------------------|                                                                                                                                                                                                                                                                                                    
             
             call cts00g09_ramocontabil(l_param_ctb00g03.atdsrvnum,                                                                                                                                                                                                                                                                                                     
                                        l_param_ctb00g03.atdsrvano,                                                                                                                                                                                                                                                                                                     
                                        l_param_ctb00g03.rmemdlcod,
                                        l_param_ctb00g03.ramcod)                                                                                                                                                                                                                                                                                                     
                  returning l_ctb00g03_rcontabil.ctbramcod,                                                                                                                                                                                                                                                                                                             
                            l_ctb00g03_rcontabil.ctbmdlcod,
                            l_ctb00g03_rcontabil.clscod,
                            l_ctb00g03_rcontabil.pgoclsflg                                                                                                                                                                                                                                                                                                              
            
              
            if m_contab_teste then
               let m_valor_teste = m_valor_teste + l_param_ctb00g03.opgvlr
            end if 
            display "l_param_ctb00g03.opgvlr   : ",l_param_ctb00g03.opgvlr
            display "l_param_ctb00g03.conitfcod: ",l_param_ctb00g03.conitfcod
            display "l_param_ctb00g03.prvtip   : ",l_param_ctb00g03.prvtip 
            display "l_param_ctb00g03.empcod   : ",l_param_ctb00g03.empcod  
            display "l_param_ctb00g03.atdsrvnum: ",l_param_ctb00g03.atdsrvnum
            display "l_param_ctb00g03.atdsrvano: ",l_param_ctb00g03.atdsrvano
            display "l_param_ctb00g03.prvmvttip: ",l_param_ctb00g03.prvmvttip
            display "l_param_ctb00g03.opgmvttip: ",l_param_ctb00g03.opgmvttip
            execute ipctb00g03001
            using l_param_ctb00g03.conitfcod,
                  l_param_ctb00g03.prvtip,
                  l_param_ctb00g03.empcod,
                  l_param_ctb00g03.atdsrvnum,
                  l_param_ctb00g03.atdsrvano,
                  l_param_ctb00g03.opgnum,
                  l_param_ctb00g03.opgitmnum,
                  l_param_ctb00g03.prvmvttip,
                  l_param_ctb00g03.opgmvttip,
                  l_param_ctb00g03.corsus,
                  l_param_ctb00g03.nfsnum,
                  l_param_ctb00g03.nfsemsdat,
                  l_param_ctb00g03.nfsvncdat,
                  l_param_ctb00g03.sinano,
                  l_param_ctb00g03.sinnum,
                  l_param_ctb00g03.fvrnom,
                  l_param_ctb00g03.opgvlr,
                  l_param_ctb00g03.opgcncflg,
                  l_param_ctb00g03.opgprcflg,
                  l_param_ctb00g03.atldat,
                  l_param_ctb00g03.atlemp,
                  l_param_ctb00g03.atlmat,
                  l_param_ctb00g03.atlusrtip,
                  l_param_ctb00g03.pestip,
                  l_param_ctb00g03.succod,
                  l_ctb00g03_rcontabil.ctbramcod, #l_param_ctb00g03.ramcod,  retirando pela circular395 da susep                                                                                                                                                                                                                                                             
                  l_ctb00g03_rcontabil.ctbmdlcod, #l_param_ctb00g03.rmemdlcod,retirando pela circular395 da susep                                                                                                                                                                                                                                                            
                  l_param_ctb00g03.aplnumdig,
                  l_param_ctb00g03.itmnumdig,
                  l_param_ctb00g03.edsnumref,
                  l_param_ctb00g03.atdsrvabrdat,
                  l_param_ctb00g03.opgemsdat,
                  l_dctcaddat,
                  l_doctxt,
                  l_ctb00g03_rcontabil.clscod   
                    
            #whenever error stop                    
            if sqlca.sqlcode <> 0 then             
                display "ERRO no INSERT ipctb00g03001(b), sql = ", sqlca.sqlcode
                display l_param_ctb00g03.*
                return sqlca.sqlcode, ws_eventograva_evento
            end if
           whenever error stop                    
            
        else
            #Update(para prorrogação) se houver registro
            whenever error continue
            execute ipctb00g03028 using  l_param_ctb00g03.opgvlr,
                                         l_param_ctb00g03.empcod,
                                         l_param_ctb00g03.opgnum,
                                         l_param_ctb00g03.opgitmnum,
                                         l_param_ctb00g03.prvmvttip,
                                         l_param_ctb00g03.conitfcod,
                                         l_param_ctb00g03.prvmvttip,
                                         l_param_ctb00g03.atdsrvnum,
                                         l_param_ctb00g03.atdsrvano

            whenever error stop
            if sqlca.sqlcode <> 0 then
                display "ERRO no UPDATE ipctb00g03028(b), sql = ", sqlca.sqlcode
                display l_param_ctb00g03.*
                return sqlca.sqlcode, ws_eventograva_evento
            end if

        end if

        whenever error stop
        if sqlca.sqlcode <> 0 then
            display "ERRO no SELECT icctb00g03027(b), sql = ", sqlca.sqlcode
            display l_param_ctb00g03.*
            return sqlca.sqlcode, ws_eventograva_evento
        end if
        close icctb00g03027

if ws_eventograva_evento is null then
        let ws_eventograva_evento = "NULO"
end if

return sqlca.sqlcode, ws_eventograva_evento

end function


#--------------------------------------------------------------------------#
function ctb00g03_grvratdsp(l_ctb00g03_param)
#--------------------------------------------------------------------------#

    define l_ctb00g03_param record
        empcod     like ctimsocprv.empcod,
        atdsrvnum  like ctimsocprv.atdsrvnum,
        atdsrvano  like ctimsocprv.atdsrvano,
        opgnum     like ctimsocprv.opgnum,
        opgitmnum  like ctimsocprv.opgitmnum,
        opgmvttip  like ctimsocprv.opgmvttip,
        succod     like ctimsocprv.succod,
        cctcod     like ctimsocprvrat.cctcod,
        ratvlr     dec(15,5)
    end record

    define l_ratvlr like ctimsocprvrat.ratvlr
    define l_atdprscod_3      like datmservico.atdprscod
    define l_cmd2 char(500)
    define l_lcvcod_3         like datmavisrent.lcvcod
    define l_lcvnom_3       like datklocadora.lcvnom
    define l_aviestcod_3      like datmavisrent.aviestcod
    define l_avialgmtv_3      like datmavisrent.avialgmtv
    define l_avioccdat_3      like datmavisrent.avioccdat
    define l_avivclvlr_3      like datmavisrent.avivclvlr
    define l_aviprvent_3      like datmavisrent.aviprvent
    define l_avivclcod_3      like datmavisrent.avivclcod

    initialize l_ratvlr     , l_atdprscod_3,
               l_cmd2       , l_lcvcod_3   ,
               l_lcvnom_3   , l_aviestcod_3,
               l_avialgmtv_3, l_avioccdat_3,
               l_avivclvlr_3, l_aviprvent_3,
               l_avivclcod_3 to null
    
    if m_prep_flag = false then
        call ctb00g03_seleciona_sql()
        let m_prep_flag = true
    end if

    whenever error continue
    open cctb00g03002 using l_ctb00g03_param.empcod   ,
                            l_ctb00g03_param.atdsrvnum,
                            l_ctb00g03_param.atdsrvano,
                            l_ctb00g03_param.opgnum   ,
                            l_ctb00g03_param.opgitmnum,
                            l_ctb00g03_param.opgmvttip,
                            l_ctb00g03_param.succod   ,
                            l_ctb00g03_param.cctcod
    fetch cctb00g03002 into l_ratvlr

    whenever error stop
    if sqlca.sqlcode < 0 then
        display 'OCORREU UM ERRO EM cctb00g03002  - SqlCode ',sqlca.sqlcode
        return sqlca.sqlcode
    end if

    if sqlca.sqlcode = 0 then
       execute upctb00g03001 using l_ctb00g03_param.ratvlr,
                                   l_ctb00g03_param.empcod,
                                   l_ctb00g03_param.atdsrvnum,
                                   l_ctb00g03_param.atdsrvano,
                                   l_ctb00g03_param.opgnum,
                                   l_ctb00g03_param.opgitmnum,
                                   l_ctb00g03_param.opgmvttip,
                                   l_ctb00g03_param.succod,
                                   l_ctb00g03_param.cctcod
       if sqlca.sqlcode < 0 then
           display "ERRO no UPDATE upctb00g03001, sql = ", sqlca.sqlcode
           return sqlca.sqlcode
       end if
    else
        whenever error continue
        execute ipctb00g03002
          using l_ctb00g03_param.empcod,
                l_ctb00g03_param.atdsrvnum,
                l_ctb00g03_param.atdsrvano,
                l_ctb00g03_param.opgnum,
                l_ctb00g03_param.opgitmnum,
                l_ctb00g03_param.opgmvttip,
                l_ctb00g03_param.succod,
                l_ctb00g03_param.cctcod,
                l_ctb00g03_param.ratvlr
        whenever error stop
        if sqlca.sqlcode < 0 then
            display "ERRO no INSERT ipctb00g03002, sql = ", sqlca.sqlcode
            return sqlca.sqlcode
        end if
    end if

    #PSI196606 - Inicio
    #Customizar o evento 25.121 - PeopleSoft
    if m_ctb00g03.conitfcod =  25 then
        if l_ctb00g03_param.opgmvttip = 3 then
                let ws.provisionamento = "25.121"
                let lr_evento.evento = ws.provisionamento

                #Preparando variaveis para chamada da interface
                let l_cmd2 = " select atldat, corsus, nfsvncdat, aplnumdig, ",
                        " atdsrvabrdat, nfsnum, rmemdlcod, ramcod, nfsemsdat, fvrnom ",
                        " from ctimsocprv ",
                        " where atdsrvnum = ? ",
                        " and atdsrvano = ? ",
                        " and prvmvttip = 3 "
                prepare pctb00g03053 from l_cmd2
                declare cctb00g03053 cursor for pctb00g03053
                whenever error continue
                        open cctb00g03053 using l_ctb00g03_param.atdsrvnum, l_ctb00g03_param.atdsrvano
                        fetch cctb00g03053 into ws.atldat, ws.corsus, ws.nfsvncdat, ws.aplnumdig,
                                                ws.atdsrvabrdat, ws.nfsnum, ws.rmemdlcod, ws.ramcod,
                                                ws.nfsemsdat, ws.fvrnom
                whenever error stop
                        if sqlca.sqlcode <> 0 then
                                error "Erro ao selecionar cctb00g03053:, ", sqlca.sqlcode, " = ", sqlca.sqlerrd[2]
                        end if
                close cctb00g03053

                #Empresa
                let l_cmd2 = "select empcod, atdprscod from datmservico where atdsrvnum = ? and atdsrvano = ?"
                prepare pctb00g03051_3 from l_cmd2
                declare cctb00g03051_3 cursor for pctb00g03051_3
                whenever error continue
                        open cctb00g03051_3 using l_ctb00g03_param.atdsrvnum, l_ctb00g03_param.atdsrvano
                        fetch cctb00g03051_3 into ws.empresa, l_atdprscod_3
                whenever error stop
                        if sqlca.sqlcode <> 0 then
                                error "Erro ao selecionar empresa cctb00g03020:, ", sqlca.sqlcode, " = ", sqlca.sqlerrd[2]
                        end if
                close cctb00g03051_3
                if ws.empresa is not null then
                        let lr_evento.empresa = ws.empresa
                end if

                #Data da competencia
                let lr_evento.dt_movto = m_ctb00g03.atldat

                #Chave primaria
                #a chave primaria deste evento e composta por data competencia, evento, servico, op, data de vencimento, corretor
                let lr_evento.chave_primaria =  ws.atldat,
                                                ws.provisionamento,
                                                l_ctb00g03_param.atdsrvnum,
                                                0,
                                                ws.nfsvncdat,
                                                ws.corsus

                #OP
                let lr_evento.op = l_ctb00g03_param.opgnum

                #Apolice
                let lr_evento.apolice = ws.aplnumdig
                if lr_evento.apolice is null then
                        let lr_evento.apolice = 0
                end if

                #Sucursal
                let lr_evento.sucursal = l_ctb00g03_param.succod

                #Projeto
                let lr_evento.projeto = l_ctb00g03_param.atdsrvnum

                #Data do Chamado
                let lr_evento.dt_chamado = ws.atdsrvabrdat

                #Favorecido
                if m_ctb00g03.conitfcod = 25 then
                        ### // Seleciona os dados do laudo de locação //
                        whenever error continue
                                open cctb00g03017 using l_ctb00g03_param.atdsrvnum,
                                                        l_ctb00g03_param.atdsrvano
                                fetch cctb00g03017 into l_lcvcod_3   ,
                                                        l_lcvnom_3,
                                                        l_aviestcod_3,
                                                        l_avialgmtv_3,
                                                        l_avioccdat_3,
                                                        l_avivclvlr_3,
                                                        l_aviprvent_3,
                                                        ws.nfsemsdat,
                                                        l_avivclcod_3
                        whenever error stop
                                if sqlca.sqlcode < 0 then
                                        display 'OCORREU UM ERRO EM cctb00g03017 - SqlCode ',sqlca.sqlcode
                                        return sqlca.sqlcode
                                end if
                        close cctb00g03017
                        let lr_evento.fvrcod = l_lcvcod_3
                        let lr_evento.fvrnom = l_lcvnom_3
                else
                        if l_atdprscod_3 is not null then
                                let lr_evento.fvrcod = l_atdprscod_3
                                let lr_evento.fvrnom = ws.fvrnom
                        end if
                end if

                #Nota fiscal
                let lr_evento.nfnum = ws.nfsnum

                #Corretor
                let lr_evento.corsus = ws.corsus

                # Tratando o ramo
                call depara_ramo(m_ctb00g03.ramcod, m_ctb00g03.rmemdlcod)
                returning ws.ramo_novo, ws.modalidade_nova

                if ws.ramo_novo <> 0 then
                        let m_ctb00g03.ramcod = ws.ramo_novo
                        let m_ctb00g03.rmemdlcod = ws.modalidade_nova
                end if

                #Centro de custo
                let lr_evento.cctnum = l_ctb00g03_param.cctcod

                #Modalidade
                let lr_evento.modalidade = ws.rmemdlcod

                #Ramo
                let lr_evento.ramo = ws.ramcod

                #Valor
                let lr_evento.opgvlr = l_ctb00g03_param.ratvlr

                #Data de vencimento
                let lr_evento.dt_vencto =  ws.nfsvncdat

                if lr_evento.evento is null or lr_evento.evento = 0 then
                        let lr_evento.evento = "25.121"
                end if
                call ctb00g03_evento_25(lr_evento.*)
        end if
    end if
 return sqlca.sqlcode

end function

#--------------------------------------------------------------------------#
function ctb00g03_incprvdsp(l_par_ctb00g03)
#--------------------------------------------------------------------------#

    define l_par_ctb00g03   record
        atdsrvnum           like ctimsocprv.atdsrvnum,
        atdsrvano           like ctimsocprv.atdsrvano
    end record

    define l_cmd            char(400)
    define l_primeiravez    char(01)
    define l_grlinf         like datkgeral.grlinf
    define l_dataentrega    date
    define l_crnpgtcod      like dpaksocor.crnpgtcod
    define l_lignum         like datmligacao.lignum
    define l_c24astcod      like datmligacao.c24astcod
    define l_sindat         like datmservicocmp.sindat
    define l_atddat         like datmservico.atddat
    define l_emsdat         like abamapol.emsdat
    define l_sinramcod      like ctimsocprv.ramcod
    define l_prporg         like datrligprp.prporg
    define l_prpnumdig      like datrligprp.prpnumdig
    define l_corsus         like apamcor.corsus
    define l_lcvcod         like datmavisrent.lcvcod
    define l_lcvnom         like datklocadora.lcvnom
    define l_aviestcod      like datmavisrent.aviestcod
    define l_avialgmtv      like datmavisrent.avialgmtv
    define l_avioccdat      like datmavisrent.avioccdat
    define l_avivclvlr      like datmavisrent.avivclvlr
    define l_aviprvent      like datmavisrent.aviprvent
    define l_avivclcod      like datmavisrent.avivclcod
    define l_lcvlojtip      like datkavislocal.lcvlojtip
    define l_lcvregprccod   like datkavislocal.lcvregprccod
    define l_lcvvcldiavlr   like datklocaldiaria.lcvvcldiavlr
    define l_prtsgrvlr      like datklocaldiaria.prtsgrvlr
    define l_diafxovlr      like datklocaldiaria.diafxovlr
    define l_eventograva    char(06)
    define l_ciaempcod      like datmservico.ciaempcod

    #PSI 202720
    define l_tpdocto     char(15),
           l_retorno     smallint,
           l_mensagem    char(80),
           l_cornom      like datksegsau.cornom,
           l_crtnum      like datrsrvsau.crtnum

    initialize l_cmd         , l_primeiravez, l_grlinf      ,  
               l_dataentrega , l_crnpgtcod  , l_lignum      ,  
               l_c24astcod   , l_sindat     , l_atddat      ,  
               l_emsdat      , l_sinramcod  , l_prporg      ,  
               l_prpnumdig   , l_corsus     , l_lcvcod      ,  
               l_lcvnom      , l_aviestcod  , l_avialgmtv   ,  
               l_avioccdat   , l_avivclvlr  , l_aviprvent   ,  
               l_avivclcod   , l_lcvlojtip  , l_lcvregprccod,  
               l_lcvvcldiavlr, l_prtsgrvlr  , l_diafxovlr   ,  
               l_eventograva , l_ciaempcod  , l_tpdocto     ,
               l_retorno     , l_mensagem   , l_cornom      ,
               l_crtnum  to null
    
    initialize lr_evento.* to null

    let ws_tipo = null

    initialize m_ctb00g03.* to null
    if m_prep_flag = false then
        call ctb00g03_seleciona_sql()
        let m_prep_flag = true
    end if

    ### // Número e ano do serviço passados como parâmetros //
    let m_ctb00g03.atdsrvnum = l_par_ctb00g03.atdsrvnum
    let m_ctb00g03.atdsrvano = l_par_ctb00g03.atdsrvano

    ### // Inicializar variável para interface osauc040_sinistro() //
    let l_primeiravez = "S"

    ### // Seleciona dados do serviço //
    whenever error continue
    open cctb00g03003 using m_ctb00g03.atdsrvnum,
                            m_ctb00g03.atdsrvano
    fetch cctb00g03003 into m_ctb00g03.atdsrvorg,
                            m_ctb00g03.atdsrvabrdat,
                            m_ctb00g03.nfsvncdat,
                            m_ctb00g03.atdprscod,
                            m_ctb00g03.asitipcod,
                            m_ctb00g03.vclcoddig,
                            m_ctb00g03.socvclcod,
                            l_ciaempcod
    whenever error stop
    
    if sqlca.sqlcode = notfound then
        let m_ctb00g03.atdsrvorg    = null
        let m_ctb00g03.atdsrvabrdat = null
        let m_ctb00g03.nfsvncdat    = null
        let m_ctb00g03.atdprscod    = null
        let m_ctb00g03.asitipcod    = null
        let m_ctb00g03.vclcoddig    = null
        let m_ctb00g03.socvclcod    = null
    else
        if sqlca.sqlcode < 0 then
            display "OCORREU UM ERRO EM cctb00g03003, ", sqlca.sqlcode
            return sqlca.sqlcode, lr_eventoinc.*
        end if
    end if

    # Atribuindo data do atendimento
    let l_atddat = m_ctb00g03.atdsrvabrdat
    let m_ctb00g03.ciaempcod = l_ciaempcod

    # ## // Seleciona dados da apólice //
    # PSI 202720
    # verifica tipo de documento utilizado no servico
    call cts20g11_identifica_tpdocto(m_ctb00g03.atdsrvnum,
                                     m_ctb00g03.atdsrvano)
         returning l_tpdocto

    if l_tpdocto = "SAUDE" then
       #se documento saude - é do cartao saude, entao buscar ramo na
       # tabela de apolices do saude
       call cts20g10_cartao(2,
                            m_ctb00g03.atdsrvnum,
                            m_ctb00g03.atdsrvano)
            returning l_retorno,
                      l_mensagem,
                      m_ctb00g03.succod,
                      m_ctb00g03.ramcod ,
                      m_ctb00g03.aplnumdig,
                      l_crtnum
       if l_retorno = 1 then
          #Obter corsus da tabela do saúde
          call cta01m15_sel_datksegsau(2,
                                       l_crtnum,
                                       "",
                                       "",
                                       "" )
               returning l_retorno,
                         l_mensagem,
                         m_ctb00g03.corsus,
                         l_cornom
       end if
    else
       whenever error continue
       open cctb00g03004 using m_ctb00g03.atdsrvnum,
                               m_ctb00g03.atdsrvano
       fetch cctb00g03004 into m_ctb00g03.succod,
                               m_ctb00g03.ramcod,
                               m_ctb00g03.aplnumdig,
                               m_ctb00g03.itmnumdig,
                               m_ctb00g03.edsnumref
       whenever error stop
       if sqlca.sqlcode = notfound then
          let m_ctb00g03.succod    = null
          let m_ctb00g03.ramcod    = null
          let m_ctb00g03.aplnumdig = null
          let m_ctb00g03.itmnumdig = null
          let m_ctb00g03.edsnumref = null
       else
          whenever error stop
          if sqlca.sqlcode < 0 then
              display "OCORREU UM ERRO EM cctb00g03004, ", sqlca.sqlcode
              return sqlca.sqlcode, lr_eventoinc.*
          end if
       end if

       ### // Seleciona susep da apólice //
       whenever error continue
       open cctb00g03005 using m_ctb00g03.succod,
                               m_ctb00g03.aplnumdig
       fetch cctb00g03005 into m_ctb00g03.corsus
   
       whenever error stop
       if sqlca.sqlcode = notfound then
           let m_ctb00g03.corsus = null
       else
           whenever error stop
           if sqlca.sqlcode < 0 then
               display "OCORREU UM ERRO EM cctb00g03005, ", sqlca.sqlcode
               return sqlca.sqlcode, lr_eventoinc.*
           end if
       end if
    end if
    
    ### // Seleciona a data de emissão da apólice //
    whenever error continue
    if m_ctb00g03.succod = 0 or m_ctb00g03.succod is null then
        let m_ctb00g03.succod = 1
    end if

    open cctb00g03006 using m_ctb00g03.succod,
                            m_ctb00g03.aplnumdig
    fetch cctb00g03006 into l_emsdat

    whenever error stop
    if sqlca.sqlcode = notfound then
        let l_emsdat = null
    else
        whenever error stop
        if sqlca.sqlcode < 0 then
            display "OCORREU UM ERRO EM cctb00g03006, ", sqlca.sqlcode
            return sqlca.sqlcode, lr_eventoinc.*
        end if
    end if
    

    #AS 88838 - inicio
    if m_ctb00g03.corsus is null then
       let l_prporg = null
       let l_prpnumdig = null
       let l_corsus = null
       
       ###  // Seleciona susep caso nao tenha apolice emitida
       whenever error continue
       open cctb00g03101 using m_ctb00g03.atdsrvnum,
                               m_ctb00g03.atdsrvano
       fetch cctb00g03101 into l_prporg,
                               l_prpnumdig
       whenever error stop
       if sqlca.sqlcode = notfound then
           let l_prporg = null
           let l_prpnumdig = null
       else
           whenever error stop
           if sqlca.sqlcode < 0 then
                   display "OCORREU UM ERRO EM cctb00g03101, ", sqlca.sqlcode
                   return sqlca.sqlcode, lr_eventoinc.*
           end if
       end if

       close cctb00g03101

       if l_prporg is not null and l_prpnumdig is not null 
          then
          whenever error continue
          open cctb00g03102 using l_prporg,
                                  l_prpnumdig
          fetch cctb00g03102 into l_corsus
          whenever error stop
          
          if sqlca.sqlcode = notfound then
             let l_corsus = null
          else
             whenever error stop
             if sqlca.sqlcode < 0 then
                     display "OCORREU UM ERRO EM cctb00g03102, ", sqlca.sqlcode
                     return sqlca.sqlcode, lr_eventoinc.*
             end if
          end if
       end if
       let m_ctb00g03.corsus = l_corsus
       
       close cctb00g03102
       
    end if
    # AS 88838 - Fim
    
    ###  // Seleciona a data da resolução 86 //
    whenever error continue
    open cctb00g03011
    fetch cctb00g03011 into l_grlinf
    
    whenever error stop
    if sqlca.sqlcode = notfound then
        let l_grlinf = null
    else
        whenever error stop
        if sqlca.sqlcode < 0 then
            display "OCORREU UM ERRO EM cctb00g03011, ", sqlca.sqlcode
            return sqlca.sqlcode, lr_eventoinc.*
        end if
    end if

    ###  // Se for carro-extra, trata diferente //
    if m_ctb00g03.atdsrvorg = 8 then

        let m_ctb00g03.conitfcod = 25   ### // Tipo Carro Extra //
        call ctb00g03_trsrvce(m_ctb00g03.atdsrvnum,m_ctb00g03.atdsrvano,m_ctb00g03.atdsrvorg,1)

    else

        let m_ctb00g03.conitfcod = 05   ### // Tipo Auto //

        ### // Seleciona os dados do prestador //
        whenever error continue
        open cctb00g03007 using m_ctb00g03.atdprscod
        fetch cctb00g03007 into m_ctb00g03.fvrnom,
                                m_ctb00g03.pestip,
                                m_ctb00g03.soctrfcod,
                                l_crnpgtcod

        whenever error stop
        if sqlca.sqlcode = notfound then
            let m_ctb00g03.fvrnom    = null
            let m_ctb00g03.pestip    = null
            let m_ctb00g03.soctrfcod = null
            let l_crnpgtcod          = null
        else
            whenever error stop
            if sqlca.sqlcode < 0 then
                display "OCORREU UM ERRO EM cctb00g03007, ", sqlca.sqlcode
                return sqlca.sqlcode, lr_eventoinc.*
            end if
        end if

        ### // Seleciona a próxima data de entrega //
        whenever error continue
        open cctb00g03008 using l_crnpgtcod,
                                m_ctb00g03.nfsvncdat
        fetch cctb00g03008 into l_dataentrega

        whenever error stop
        if sqlca.sqlcode = notfound then
            let l_dataentrega = null
        else
            whenever error stop
            if sqlca.sqlcode < 0 then
                display "OCORREU UM ERRO EM cctb00g03008, ", sqlca.sqlcode
                return sqlca.sqlcode, lr_eventoinc.*
            end if
        end if

        ### // Valida a data de entrega como dia útil //
        call dias_uteis(l_dataentrega, 0, "", "S", "S")
              returning l_dataentrega

        ### // Calcula a provável data de pagamento //
        call dias_uteis(l_dataentrega, 6, "", "S", "S")
              returning m_ctb00g03.nfsvncdat

        ###  // Seleciona o número da ligação //
        call cts20g00_servico(m_ctb00g03.atdsrvnum, m_ctb00g03.atdsrvano)
                    returning l_lignum


        ###  // Seleciona os dados da ligação //
        whenever error continue
        open cctb00g03009 using l_lignum
        fetch cctb00g03009 into m_ligcvntip,
                                l_c24astcod

        whenever error stop
        if sqlca.sqlcode = notfound then
            let m_ligcvntip = null
            let l_c24astcod = null
        else
            whenever error stop
            if sqlca.sqlcode < 0 then
                display "OCORREU UM ERRO EM cctb00g03009, ", sqlca.sqlcode
                return sqlca.sqlcode, lr_eventoinc.*
            end if
        end if


        ###  // Verifica o tipo de sinistro //
        if m_ctb00g03.atdsrvorg =  4 or   ## // Remoção por Sinistro
           m_ctb00g03.atdsrvorg =  5 or   ## // R.P.T.
           m_ctb00g03.atdsrvorg =  7 or   ## // Replace
           m_ctb00g03.atdsrvorg = 17 or   ## // Replace congênere
           m_ctb00g03.atdsrvorg = 13 then ## // Sinistro RE
           
           ### // Trata o ramo Auto //
           if m_ctb00g03.atdsrvorg <> 13 then
               if l_c24astcod = "G13" then
                   let m_ctb00g03.ramcod = 553
                   if  l_emsdat = l_grlinf then
                       let m_ctb00g03.ramcod = 553
                   end if
                   if l_emsdat = "" then
                       let m_ctb00g03.ramcod = 553
                   end if
               end if
           end if
           
           ### // Seleciona a data do sinistro //
           whenever error continue
           open cctb00g03010 using m_ctb00g03.atdsrvnum,
                                   m_ctb00g03.atdsrvano
           fetch cctb00g03010 into l_sindat

           whenever error stop
           if sqlca.sqlcode = notfound then
               let l_sindat = null
           else
               whenever error stop
               if sqlca.sqlcode < 0 then
                   display "OCORREU UM ERRO EM cctb00g03010, ", sqlca.sqlcode
                   return sqlca.sqlcode, lr_eventoinc.*
               end if
           end if

           let l_atddat = m_ctb00g03.atdsrvabrdat

           if l_sindat is null then
               let l_atddat = null
           end if

           ### // Seleciona os dados do sinistro //
           if m_ctb00g03.succod    is not null and
              m_ctb00g03.aplnumdig is not null and
              m_ctb00g03.itmnumdig is not null then
              call osauc040_sinistro(m_ctb00g03.ramcod,
                                     m_ctb00g03.succod,
                                     m_ctb00g03.aplnumdig,
                                     m_ctb00g03.itmnumdig,
                                     l_sindat,
                                     l_atddat,
                                     l_primeiravez)
                           returning l_sinramcod,
                                     m_ctb00g03.sinano,
                                     m_ctb00g03.sinnum


              let l_primeiravez = "N"

              ### // Se retornou ramo do sinistro, utiliza //
              if l_sinramcod is not null and
                 l_sinramcod <> 0 then
                  let m_ctb00g03.ramcod = l_sinramcod
              end if
           end if

        end if

        ### // Trata RE e Auto //
        if m_ctb00g03.atdsrvorg = 9 or m_ctb00g03.atdsrvorg = 13 then
            call ctb00g03_trsrvre(m_ctb00g03.atdsrvnum,m_ctb00g03.atdsrvano,m_ctb00g03.atdsrvorg,1)
        else
            call ctb00g03_trsrvauto(m_ctb00g03.atdsrvnum,m_ctb00g03.atdsrvano,m_ctb00g03.atdsrvorg,1)
        end if

        call ctb00g03_verifcod()

    end if
    
    if m_ctb00g03.ramcod is null then
        let m_ctb00g03.ramcod = 531
    end if
    
    if m_ctb00g03.ramcod = 31 then
        let m_ctb00g03.ramcod = 531
    end if
    
    if m_ctb00g03.ramcod = 53 then
        let m_ctb00g03.ramcod = 553
    end if
    
    ### // Constantes //
    let m_ctb00g03.prvtip       = "D"       ###  // Despesa             //
    let m_ctb00g03.opgnum       = 0         ###  // Ainda não tem OP    //
    let m_ctb00g03.opgitmnum    = 0         ###  // Ainda não tem OP    //
    let m_ctb00g03.prvmvttip    = 1         ###  // Provisionamento     //
    let m_ctb00g03.nfsnum       = 0         ###  // Ainda não tem NF    //
    let m_ctb00g03.atldat       = today     ###  // Data de atualização //
    let m_ctb00g03.atlemp       = 1         ###  // Fixo Um             //
    let m_ctb00g03.atlmat       = 999999    ###  // Fixo Noves          //
    let m_ctb00g03.atlusrtip    = "F"       ###  // Fixo                //
    let m_ctb00g03.opgcncflg    = "N"       ###  // Fixo                //
    let m_ctb00g03.opgprcflg    = "N"       ###  // Fixo                //
    
    # PSI 198404 - mandar empresa do servico no provisionamento da despesa
    # if m_ctb00g03.atdsrvorg = 18 then
    #    let m_ctb00g03.empcod = m_ctb00g03.ciaempcod
    # else
    #    let m_ctb00g03.empcod = 01          ###  // Fixo
    # end if
    
    let m_ctb00g03.empcod = m_ctb00g03.ciaempcod
    
    ### // Datas //
    let m_ctb00g03.nfsemsdat    = null      ###  // Data de emissão NF  //
    let m_ctb00g03.nfsvncdat    = null      ###  // Data de vencto  NF  //
    let m_ctb00g03.opgemsdat    = null      ###  // Data de emissão OP  //
    
    if m_ctb00g03.ramcod = 0 or m_ctb00g03.ramcod is null then
       let m_ctb00g03.ramcod = 531
    end if
    
    ### // Inclui registro de provisionamento na tabela da contabilidade//
    call ctb00g03_grvprvdsp(m_ctb00g03.conitfcod,
                            m_ctb00g03.prvtip,
                            m_ctb00g03.empcod,
                            m_ctb00g03.atdsrvnum,
                            m_ctb00g03.atdsrvano,
                            m_ctb00g03.opgnum,
                            m_ctb00g03.opgitmnum,
                            m_ctb00g03.prvmvttip,
                            m_ctb00g03.opgmvttip,
                            m_ctb00g03.corsus,
                            m_ctb00g03.nfsnum,
                            m_ctb00g03.nfsemsdat,
                            m_ctb00g03.nfsvncdat,
                            m_ctb00g03.sinano,
                            m_ctb00g03.sinnum,
                            m_ctb00g03.fvrnom,
                            m_ctb00g03.opgvlr,
                            m_ctb00g03.opgcncflg,
                            m_ctb00g03.opgprcflg,
                            m_ctb00g03.atldat,
                            m_ctb00g03.atlemp,
                            m_ctb00g03.atlmat,
                            m_ctb00g03.atlusrtip,
                            m_ctb00g03.pestip,
                            m_ctb00g03.succod,
                            m_ctb00g03.ramcod,
                            m_ctb00g03.rmemdlcod,
                            m_ctb00g03.aplnumdig,
                            m_ctb00g03.itmnumdig,
                            m_ctb00g03.edsnumref,
                            m_ctb00g03.atdsrvabrdat,
                            m_ctb00g03.opgemsdat)
                  returning ws_sqlcode, l_eventograva

    if ws_sqlcode != 0 then
       display 'OCORREU UM ERRO EM ctb00g03_grvprvdsp - SqlCode ',ws_sqlcode
       display "m_ctb00g03.conitfcod     :", m_ctb00g03.conitfcod     
       display "m_ctb00g03.prvtip        :", m_ctb00g03.prvtip        
       display "m_ctb00g03.empcod        :", m_ctb00g03.empcod        
       display "m_ctb00g03.atdsrvnum     :", m_ctb00g03.atdsrvnum     
       display "m_ctb00g03.atdsrvano     :", m_ctb00g03.atdsrvano     
       display "m_ctb00g03.opgnum        :", m_ctb00g03.opgnum        
       display "m_ctb00g03.opgitmnum     :", m_ctb00g03.opgitmnum     
       display "m_ctb00g03.prvmvttip     :", m_ctb00g03.prvmvttip     
       display "m_ctb00g03.opgmvttip     :", m_ctb00g03.opgmvttip     
       display "m_ctb00g03.corsus        :", m_ctb00g03.corsus        
       display "m_ctb00g03.nfsnum        :", m_ctb00g03.nfsnum        
       display "m_ctb00g03.nfsemsdat     :", m_ctb00g03.nfsemsdat     
       display "m_ctb00g03.nfsvncdat     :", m_ctb00g03.nfsvncdat     
       display "m_ctb00g03.sinano        :", m_ctb00g03.sinano        
       display "m_ctb00g03.sinnum        :", m_ctb00g03.sinnum        
       display "m_ctb00g03.fvrnom        :", m_ctb00g03.fvrnom        
       display "m_ctb00g03.opgvlr        :", m_ctb00g03.opgvlr        
       display "m_ctb00g03.opgcncflg     :", m_ctb00g03.opgcncflg     
       display "m_ctb00g03.opgprcflg     :", m_ctb00g03.opgprcflg     
       display "m_ctb00g03.atldat        :", m_ctb00g03.atldat        
       display "m_ctb00g03.atlemp        :", m_ctb00g03.atlemp        
       display "m_ctb00g03.atlmat        :", m_ctb00g03.atlmat        
       display "m_ctb00g03.atlusrtip     :", m_ctb00g03.atlusrtip     
       display "m_ctb00g03.pestip        :", m_ctb00g03.pestip        
       display "m_ctb00g03.succod        :", m_ctb00g03.succod        
       display "m_ctb00g03.ramcod        :", m_ctb00g03.ramcod        
       display "m_ctb00g03.rmemdlcod     :", m_ctb00g03.rmemdlcod     
       display "m_ctb00g03.aplnumdig     :", m_ctb00g03.aplnumdig     
       display "m_ctb00g03.itmnumdig     :", m_ctb00g03.itmnumdig     
       display "m_ctb00g03.edsnumref     :", m_ctb00g03.edsnumref     
       display "m_ctb00g03.atdsrvabrdat  :", m_ctb00g03.atdsrvabrdat  
       display "m_ctb00g03.opgemsdat     :", m_ctb00g03.opgemsdat     
       
       return sqlca.sqlcode, lr_eventoinc.*
       
    #PSI196606 - Início
    else
       if l_ciaempcod = 1 
          then
          if m_ctb00g03.conitfcod = 05 then #Auto
             case m_ctb00g03.atdsrvorg #Auto
                  when 1
                          if m_ligcvntip = 80 or
                          m_ligcvntip = 85 or
                          m_ligcvntip = 89 or
                          m_ligcvntip = 90 or
                          m_ligcvntip = 91 or
                          m_ligcvntip = 92 then
                                  if m_ctb00g03.aplnumdig is not null and m_ctb00g03.aplnumdig <> 0 then
                                          let ws.provisionamento = "25.5"
                                  else
                                          let ws.provisionamento = "25.115"
                                  end if
                          else
                                  if m_ctb00g03.aplnumdig is not null and m_ctb00g03.aplnumdig <> 0 then
                                          let ws.provisionamento = "25.7"
                                  else
                                          let ws.provisionamento = "25.115"
                                  end if
                          end if
                  when 2
                          if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                  let ws.provisionamento = "25.115"
                          else
                                  let ws.provisionamento = "25.7"
                          end if
                  when 3
                          if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                  let ws.provisionamento = "25.115"
                          else
                                  let ws.provisionamento = "25.7"
                          end if
                  when 4
                          if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                  let ws.provisionamento = "25.115"
                          else
                                  let ws.provisionamento = "25.5"
                          end if
                  when 5
                          if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                  let ws.provisionamento = "25.115"
                          else
                                  let ws.provisionamento = "25.5"
                          end if

                  when 6
                          if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                  let ws.provisionamento = "25.115"
                          else
                                  let ws.provisionamento = "25.7"
                          end if

                  when 7
                          if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                  let ws.provisionamento = "25.115"
                          else
                                  let ws.provisionamento = "25.16"
                          end if

                  when 17
                          if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                  let ws.provisionamento = "25.115"
                          else
                                  let ws.provisionamento = "25.16"
                          end if
                  when 9
                          if m_ctb00g03.opgmvttip = 21 or
                          m_ctb00g03.opgmvttip = 25 or
                          m_ctb00g03.opgmvttip = 26 then
                                  if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                          let ws.provisionamento = "25.115"
                                  else
                                          let ws.provisionamento = "25.11"
                                  end if
                          else
                                  if m_ctb00g03.opgmvttip = 22 then
                                          if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                                  let ws.provisionamento = "25.115"
                                          else
                                                  let ws.provisionamento = "25.4"
                                          end if
                                  else
                                          if m_ctb00g03.opgmvttip = 24 then
                                                  let ws.provisionamento = "25.12"
                                          else
                                                  if m_ctb00g03.opgmvttip = 30 then
                                                          let ws.provisionamento = "25.125"
                                                  end if
                                          end if
                                  end if
                          end if
                  when 13
                          if m_ctb00g03.opgmvttip = 23 then
                                  if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                          let ws.provisionamento = "25.115"
                                  else
                                          let ws.provisionamento = "25.11"
                                  end if
                          end if
             end case
          end if
          
          if m_ctb00g03.conitfcod = 25 then #Carro-Extra
             if m_ctb00g03.opgmvttip = 1 then
                if m_ctb00g03.aplnumdig is not null and m_ctb00g03.aplnumdig <> 0 then
                        let ws.provisionamento = "25.8"
                else
                        let ws.provisionamento = "25.115"
                end if
             else
                if m_ctb00g03.opgmvttip = 2 then
                        if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                let ws.provisionamento = "25.115"
                        else
                                let ws.provisionamento = "25.6"
                        end if
                else
                        if m_ctb00g03.opgmvttip = 3 then
                                if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                                        let ws.provisionamento = "25.115"
                                else
                                        let ws.provisionamento = "25.14"
                                end if
                        else
                                if m_ctb00g03.opgmvttip = 4 then
                                        let ws.provisionamento = "25.8"
                                else
                                        if m_ctb00g03.opgmvttip = 5 then
                                                let ws.provisionamento = "25.6"
                                        else
                                                if m_ctb00g03.opgmvttip = 6 then
                                                        let ws.provisionamento = "25.14"
                                                end if
                                        end if
                                end if
                        end if
                end if
             end if
          end if
       else
          if l_ciaempcod = 35 then
                  let ws.provisionamento = "25.122"
          end if
       end if
       
       #----------------------------------------------------------------
       # Tratando o ramo
       let ws.ramo_novo = null
       let ws.modalidade_nova = null

       call depara_ramo(m_ctb00g03.ramcod, m_ctb00g03.rmemdlcod)
       returning ws.ramo_novo, ws.modalidade_nova

       if ws.ramo_novo <> 0 and ws.ramo_novo is not null then
             let m_ctb00g03.ramcod = ws.ramo_novo
             let m_ctb00g03.rmemdlcod = ws.modalidade_nova
       end if

       #----------------------------------------------------------------
       #Identificando centro de custo
       if m_ctb00g03.conitfcod = 5 
          then #auto e re
          if m_ctb00g03.opgmvttip = 1 or m_ctb00g03.opgmvttip = 2 or
             m_ctb00g03.opgmvttip = 4 or m_ctb00g03.opgmvttip = 5 or
             m_ctb00g03.opgmvttip = 6 or m_ctb00g03.opgmvttip = 7 or
             m_ctb00g03.opgmvttip = 21 or m_ctb00g03.opgmvttip = 22 or
             m_ctb00g03.opgmvttip = 23 or m_ctb00g03.opgmvttip = 24 or
             m_ctb00g03.opgmvttip = 25 or m_ctb00g03.opgmvttip = 26 
             then
             let ws.cctnum = null
             let ws.ctbcrtcod = 0
             call ctb00g03_ccusto(l_ciaempcod, m_ctb00g03.ramcod, m_ctb00g03.rmemdlcod)
             returning ws.ctbcrtcod
             if ws.ctbcrtcod = 0 or ws.ctbcrtcod is null then
                     let ws.cctnum = 0
             else
                     let ws.cctnum = ws.ctbcrtcod
             end if
          end if
       end if

       if m_ctb00g03.conitfcod = 25 then
          let ws.cctnum = null
          let ws.ctbcrtcod = 0
          call ctb00g03_ccusto(l_ciaempcod, m_ctb00g03.ramcod, m_ctb00g03.rmemdlcod)
          returning ws.ctbcrtcod
          if ws.ctbcrtcod = 0 or ws.ctbcrtcod is null then
                  let ws.cctnum = 0
          else
                  let ws.cctnum = ws.ctbcrtcod
          end if
       end if

       #Preparando variáveis para interface
       #evento

       let lr_evento.evento = ws.provisionamento

       #Empresa
       let l_cmd = "select empcod, atddat from  datmservico where atdsrvnum = ? and atdsrvano = ?"
       prepare pctb00g03050 from l_cmd
       declare cctb00g03050 cursor for pctb00g03050

       whenever error continue
               open cctb00g03050 using m_ctb00g03.atdsrvnum, m_ctb00g03.atdsrvano
               fetch cctb00g03050 into ws.empresa, ws.atddat
       whenever error stop
               if sqlca.sqlcode <> 0 then
                       error "Erro ao selecionar empresa cctb00g03020:, ", sqlca.sqlcode, " = ", sqlca.sqlerrd[2]
               end if
       close cctb00g03050

       if ws.empresa is not null then
               let lr_evento.empresa = ws.empresa
       end if

       #Data da competencia
       let lr_evento.dt_movto = m_ctb00g03.atldat
       
       #Chave primaria
       #a chave primaria deste evento e composta por data competencia, evento, servico, op, data de vencimento, corretor
       let lr_evento.chave_primaria = m_ctb00g03.atldat,
                                      ws.provisionamento,
                                      m_ctb00g03.atdsrvnum,
                                      0,
                                      m_ctb00g03.nfsvncdat,
                                      m_ctb00g03.corsus

       #OP
       let lr_evento.op = null

       #Apolice
       if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
             let m_ctb00g03.aplnumdig = l_prpnumdig
             let lr_evento.apolice = m_ctb00g03.aplnumdig
       else
             let lr_evento.apolice = m_ctb00g03.aplnumdig
       end if
       if lr_evento.apolice is null then
             let lr_evento.apolice = 0
       end if

       #Sucursal
       let lr_evento.sucursal = m_ctb00g03.succod

       #Projeto
       let lr_evento.projeto = m_ctb00g03.atdsrvnum

       #Data do Chamado
       let l_atddat = m_ctb00g03.atdsrvabrdat
       let lr_evento.dt_chamado = l_atddat

       #Favorecido
       if m_ctb00g03.conitfcod = 25 then
          ### // Seleciona os dados do laudo de locação //
          whenever error continue
          open cctb00g03017 using m_ctb00g03.atdsrvnum,
                              m_ctb00g03.atdsrvano
          fetch cctb00g03017 into l_lcvcod   ,
                                  l_lcvnom,
                                  l_aviestcod,
                                  l_avialgmtv,
                                  l_avioccdat,
                                  l_avivclvlr,
                                  l_aviprvent,
                                  m_ctb00g03.nfsemsdat,
                                  l_avivclcod
          whenever error stop
          if sqlca.sqlcode < 0 then
                  display 'OCORREU UM ERRO EM cctb00g03017 - SqlCode ',sqlca.sqlcode
                  return sqlca.sqlcode, lr_eventoinc.*
          end if
          close cctb00g03017


          let lr_evento.fvrcod = l_lcvcod
          let lr_evento.fvrnom = l_lcvnom
          call ctx25g05_carac_fon(lr_evento.fvrnom) returning ws.descfvr
          if ws.descfvr is not null then
                  let lr_evento.fvrnom = ws.descfvr
          end if

       else
          if m_ctb00g03.atdprscod is not null then
                  let lr_evento.fvrcod = m_ctb00g03.atdprscod
                  let lr_evento.fvrnom = m_ctb00g03.fvrnom
                  call ctx25g05_carac_fon(lr_evento.fvrnom) returning ws.descfvr
                  if ws.descfvr is not null then
                          let lr_evento.fvrnom = ws.descfvr
                  end if
          end if
       end if

       #Nota fiscal
       let lr_evento.nfnum = m_ctb00g03.nfsnum

       #Corretor
       let lr_evento.corsus = m_ctb00g03.corsus

       #Centro de custo
       let lr_evento.cctnum = null
       let lr_evento.cctnum = ws.cctnum

       #Modalidade
       let lr_evento.modalidade = m_ctb00g03.rmemdlcod

       #Ramo
       let lr_evento.ramo = m_ctb00g03.ramcod

       #Valor
       let lr_evento.opgvlr = m_ctb00g03.opgvlr

       #Data de vencimento
       let lr_evento.dt_vencto =  m_ctb00g03.atldat
       
       if lr_evento.evento is null or lr_evento.evento = 0 then
          if l_ciaempcod = 1 then
             if m_ctb00g03.conitfcod = 5 then
                     let lr_evento.evento = "25.5"
             else
                     if m_ctb00g03.conitfcod = 25 then
                             let lr_evento.evento = "25.8"
                     else
                             let lr_evento.evento = "25.5"
                     end if
             end if
          else
             let lr_evento.evento = "25.122"
          end if
       end if
       
       call ctb00g03_evento_25(lr_evento.*)
       
       let lr_eventoinc.evento         = lr_evento.evento
       let lr_eventoinc.empresa        = lr_evento.empresa
       let lr_eventoinc.dt_movto       = lr_evento.dt_movto
       let lr_eventoinc.chave_primaria = lr_evento.chave_primaria
       let lr_eventoinc.op             = lr_evento.op
       let lr_eventoinc.apolice        = lr_evento.apolice
       let lr_eventoinc.sucursal       = lr_evento.sucursal
       let lr_eventoinc.projeto        = lr_evento.projeto
       let lr_eventoinc.dt_chamado     = lr_evento.dt_chamado
       let lr_eventoinc.fvrcod         = lr_evento.fvrcod
       let lr_eventoinc.fvrnom         = lr_evento.fvrnom
       let lr_eventoinc.nfnum          = lr_evento.nfnum
       let lr_eventoinc.corsus         = lr_evento.corsus
       let lr_eventoinc.cctnum         = lr_evento.cctnum
       let lr_eventoinc.modalidade     = lr_evento.modalidade
       let lr_eventoinc.ramo           = lr_evento.ramo
       let lr_eventoinc.opgvlr         = lr_evento.opgvlr
       let lr_eventoinc.dt_vencto      = lr_evento.dt_vencto
       let lr_eventoinc.dt_ocorrencia  = lr_evento.dt_chamado
       
       initialize lr_evento to null
    end if
    
    return sqlca.sqlcode, lr_eventoinc.*
    
end function    # ctb00g03_incprvdsp

#--------------------------------------------------------------------------#
function ctb00g03_selprvdsp(l_param)
--------------------------------------------------------------------------#

    define l_param record
        atdsrvnum  like ctimsocprv.atdsrvnum,
        atdsrvano  like ctimsocprv.atdsrvano
    end record

    if m_prep_flag = false then
       call ctb00g03_seleciona_sql()
       let m_prep_flag = true
    end if

    ### // Seleciona os dados do provisionamento //
    whenever error continue
    open cctb00g03012 using l_param.atdsrvnum,
                            l_param.atdsrvano
    fetch cctb00g03012 into m_ctb00g03.conitfcod,
                            m_ctb00g03.prvtip,
                            m_ctb00g03.empcod,
                            m_ctb00g03.atdsrvnum,
                            m_ctb00g03.atdsrvano,
                            m_ctb00g03.opgnum,
                            m_ctb00g03.opgitmnum,
                            m_ctb00g03.prvmvttip,
                            m_ctb00g03.opgmvttip,
                            m_ctb00g03.corsus,
                            m_ctb00g03.nfsnum,
                            m_ctb00g03.nfsemsdat,
                            m_ctb00g03.nfsvncdat,
                            m_ctb00g03.sinano,
                            m_ctb00g03.sinnum,
                            m_ctb00g03.fvrnom,
                            m_ctb00g03.opgvlr,
                            m_ctb00g03.opgcncflg,
                            m_ctb00g03.opgprcflg,
                            m_ctb00g03.atldat,
                            m_ctb00g03.atlemp,
                            m_ctb00g03.atlmat,
                            m_ctb00g03.atlusrtip,
                            m_ctb00g03.pestip,
                            m_ctb00g03.succod,
                            m_ctb00g03.ramcod,
                            m_ctb00g03.rmemdlcod,
                            m_ctb00g03.aplnumdig,
                            m_ctb00g03.itmnumdig,
                            m_ctb00g03.edsnumref,
                            m_ctb00g03.atdsrvabrdat,
                            m_ctb00g03.opgemsdat

    whenever error stop
    
    if sqlca.sqlcode != 0 then
       if sqlca.sqlcode < 0 then
           display 'OCORREU UM ERRO EM cctb00g03012 - SqlCode ', sqlca.sqlcode
           return sqlca.sqlcode
       else
           return sqlca.sqlcode
       end if
    end if
    
    return sqlca.sqlcode
    
end function

#--------------------------------------------------------------------------#
function ctb00g03_trsrvauto(l_atdsrvnum,l_atdsrvano,l_atdsrvorg,tipo)
#--------------------------------------------------------------------------#

    define l_atdsrvnum  like datmservico.atdsrvnum,
           l_atdsrvano  like datmservico.atdsrvano,
           l_atdsrvorg  like datmservico.atdsrvorg, 
           tipo smallint # 1- Sem retorno, 2 - Com retorno
    
    define l_auxerro  char(01)

    define l_valor          like ctimsocprv.opgvlr
    define l_chavei         like datkgeral.grlchv
    define l_chavef         like datkgeral.grlchv
    define l_lixo           like datkgeral.grlchv
    define l_atdsrvabrdat   char(10)

    define lr_erro record
        err    smallint,
        msgerr char(100)
    end record
    
    initialize l_auxerro, l_valor, l_chavei, l_chavef, l_lixo,
               l_atdsrvabrdat to null

    initialize lr_erro.* to null
    
    ########################################################
    ###  // Seleciona o código da despesa contábil //     ##
    ###  --------------------------------------------     ##
    ###  -  01 Sinistros a regularizar                    ##
    ###  -  02 Sinistros a regularizar - Replace          ##
    ###  -  03 Contas a pagar                             ##
    ###  -  04 Outras despesas operacionais               ##
    ###  -  05 Porto Socorro - Assistencia a locadoras    ##
    ###  -  06 Porto Socorro - Porto Card                 ##
    ###  -  07 Corporate                                  ##
    ###  -  08 Porto Socorro - AZUL SEGUROS               ##
    ###  -  09 Porto Socorro - Auxílio funeral            ##
    ###  -  10 PS - Auxílio funeral Migracao Interp.      ##
    ########################################################

    let m_ctb00g03.atdsrvnum = l_atdsrvnum
    let m_ctb00g03.atdsrvano = l_atdsrvano
    let m_ctb00g03.atdsrvorg = l_atdsrvorg
    
    if m_prep_flag = false then
        call ctb00g03_seleciona_sql()
        let m_prep_flag = true
    end if

    let l_atdsrvabrdat = m_ctb00g03.atdsrvabrdat

    if m_ctb00g03.ciaempcod = 35 then   #Empresa Azul Seguros

       let m_ctb00g03.opgmvttip = 8    ### // AZUL SEGUROS //

    else # Porto Seguro e demais empresas
       case m_ctb00g03.atdsrvorg

           when 1      ### // Se origem = Socorro //
               if m_ligcvntip = 80 then    ### // Porto Card //
                   let m_ctb00g03.opgmvttip = 6
               else
                   if m_ligcvntip = 85 then ### // Help Alphaville //
                       let m_ctb00g03.opgmvttip = 7
                   else
                       if m_ligcvntip = 89 or   ### // Mega //
                          m_ligcvntip = 90 or   ### // Avis //
                          m_ligcvntip = 91 or   ### // Seg Car //
                          m_ligcvntip = 92 then ### // Repar //
                           let m_ctb00g03.opgmvttip = 5
                       else
                           let m_ctb00g03.opgmvttip = 4 ### // Demais convênios //
                       end if
                   end if
               end if

           when 2      ### // Transportes //
               let m_ctb00g03.opgmvttip = 4

           when 3      ### // Hospedagem //
               let m_ctb00g03.opgmvttip = 4

           when 4      ### // Remoção //
               let m_ctb00g03.opgmvttip = 1

           when 5      ### // RPT //
               let m_ctb00g03.opgmvttip = 1

           when 6      ### // DAF //
               let m_ctb00g03.opgmvttip = 4

           when 7      ### // Replace //
               let m_ctb00g03.opgmvttip = 2

           when 17     ### // Replace Congenere //
               let m_ctb00g03.opgmvttip = 2

           when 18     ### // Auxílio funeral //
               if m_ctb00g03.ciaempcod = 1 and 
                 (m_ctb00g03.ramcod = 991 or m_ctb00g03.ramcod = 1391) then
                  let m_ctb00g03.opgmvttip = 9
               else
                  let m_ctb00g03.opgmvttip = 10
               end if
       end case
    end if
       
       call ctb00g03_trsrvcortesia()
      
      display "m_ctb00g03.atdsrvorgA: ",m_ctb00g03.atdsrvorg 
      display "m_ctb00g03.opgmvttipA: ",m_ctb00g03.opgmvttip
      
    if tipo = 2 then
       return  m_ctb00g03.opgmvttip
    end if 
    
    ##########################
    ### APURA VALOR DO SERVIÇO
    ##########################

    # Valor provisionamento com base em dominio
    #PSI-2013-08022EV - Variar o Valor do Provisionamento por Origem do Serviço
    
    ### // Seleciona o código da tabela de vigência //
    #call ctc00m15_rettrfvig(m_ctb00g03.atdprscod,
    #                        m_ctb00g03.ciaempcod,
    #                        m_ctb00g03.atdsrvorg,
    #                        m_ctb00g03.asitipcod,
    #                        m_ctb00g03.atdsrvabrdat)
    #     returning m_ctb00g03.soctrfcod,
    #               m_ctb00g03.soctrfvignum,
    #               lr_erro.*
    #
    #display "m_ctb00g03.soctrfcod   : ",m_ctb00g03.soctrfcod    
    #display "m_ctb00g03.soctrfvignum: ",m_ctb00g03.soctrfvignum
    #
    #if lr_erro.err <> 0 and lr_erro.err <> notfound then
    #    display lr_erro.msgerr
    #    let m_contab_teste = true
    #    #return
    #end if
    #
    #if lr_erro.err = notfound then
    #    
    #    display "sqlca.sqlcode1: ",sqlca.sqlcode  
    #    select cpodes
    #      into m_ctb00g03.opgvlr
    #      from iddkdominio
    #     where cponom = 'valor_padrao'
    #       and cpocod = m_ctb00g03.atdsrvorg
    #       display "l_valor: ",m_ctb00g03.opgvlr   
    #
    #else
    #    ### // Verifica o grupo tarifário do veículo //
    #    call ctc00m15_retsocgtfcod(m_ctb00g03.vclcoddig)
    #         returning m_ctb00g03.socgtfcod, lr_erro.*
    #    display "m_ctb00g03.socgtfcod: ",m_ctb00g03.socgtfcod
    #    ### // Se não encontrou, assume grupo 1=Passeio Nacional //
    #    if lr_erro.err <> 0 then
    #        let m_ctb00g03.socgtfcod = 1
    #    end if
    #
    #    ### // Verifica o grupo tarifário do veículo acionado //
    #    whenever error continue
    #    open cctb00g03014 using m_ctb00g03.socvclcod
    #    fetch cctb00g03014 into m_ctb00g03.vclcoddig_acn
    #    whenever error stop
    #    if sqlca.sqlcode < 0 then
    #        display 'OCORREU UM ERRO EM cctb00g03014 - SqlCode ',sqlca.sqlcode
    #        let m_contab_teste = true
    #        #return
    #    end if
    #
    #    if m_ctb00g03.vclcoddig_acn is not null then
    #        call ctc00m15_retsocgtfcod(m_ctb00g03.vclcoddig_acn)
    #            returning m_ctb00g03.socgtfcod_acn, lr_erro.*
    #
    #        if lr_erro.err <> 0 then
    #            display lr_erro.msgerr
    #            let m_contab_teste = true
    #            #return
    #        end if
    #
    #        if m_ctb00g03.socgtfcod = 5 and
    #           m_ctb00g03.socgtfcod > m_ctb00g03.socgtfcod_acn then
    #            let m_ctb00g03.socgtfcod = m_ctb00g03.socgtfcod_acn
    #            if  m_ctb00g03.socgtfcod is null then
    #                let m_ctb00g03.socgtfcod = 1
    #            end if
    #        end if
    #    end if
    #
    #    ### // Verifica o preço de tabela da faixa 1=valor inicial //
    #    call ctc00m15_retvlrvig(m_ctb00g03.soctrfvignum,
    #                            m_ctb00g03.socgtfcod,
    #                            1) #Custo Faixa 1 = Valor Inicial
    #         returning m_ctb00g03.opgvlr, lr_erro.*
	#display "m_ctb00g03.opgvlr: ",m_ctb00g03.opgvlr
	#call ctd00g00_vlrprmpgm(m_ctb00g03.atdsrvnum, 
    #                            m_ctb00g03.atdsrvano,
    #                            "INI")
    #         returning ws.vlrprm,
    #                   lr_erro.err  
    #    display "ws.vlrprm: ",ws.vlrprm   
    #    display "lr_erro.err: ",lr_erro.err
    #    if  lr_erro.err = 0 then
    #        let m_ctb00g03.opgvlr = ctd00g00_compvlr(m_ctb00g03.opgvlr, ws.vlrprm) 
    #        display "m_ctb00g03.opgvlr: ",m_ctb00g03.opgvlr 
    #    else
    #       if lr_erro.err = notfound then  
    #          initialize m_ctb00g03.opgvlr to null
    #       else
    #          display lr_erro.err, " - ", lr_erro.msgerr    
    #       end if                  
    #    end if         
    #    
    #    if m_ctb00g03.opgvlr is null then
    #                     
    #        display "sqlca.sqlcode2: ",sqlca.sqlcode  
    #        select cpodes                     
    #          into m_ctb00g03.opgvlr          
    #          from iddkdominio                
    #         where cponom = 'valor_padrao'    
    #           and cpocod = m_ctb00g03.atdsrvorg  
    #           display "l_valor: ",m_ctb00g03.opgvlr                
    #
    #    end if
    #
    #end if ### // sqlca.sqlcode = notfound //
    
    #whenever error continue
       open cctb00g03114 using m_ctb00g03.atdsrvorg  
           fetch cctb00g03114 into m_ctb00g03.opgvlr
       close cctb00g03114
       display "Valor pesquisado" , m_ctb00g03.opgvlr
    #whenever error stop
    
        if sqlca.sqlcode != 0 then
            #display 'OCORREU UM ERRO EM cctb00g03114 - SqlCode ',sqlca.sqlcode
            whenever error continue 
               open cctb00g03115
                  fetch cctb00g03115 into m_ctb00g03.opgvlr
               close cctb00g03115
               display "Valor pesquisado 2" , m_ctb00g03.opgvlr
            whenever error stop    
        end if
    
    # Fim PSI-2013-08022EV - Variar o Valor do Provisionamento por Origem do Serviço
    
end function

#--------------------------------------------------------------------------#
function ctb00g03_trsrvce(l_atdsrvnum,l_atdsrvano,l_atdsrvorg,tipo)
#--------------------------------------------------------------------------#

    define l_atdsrvnum  like datmservico.atdsrvnum,
           l_atdsrvano  like datmservico.atdsrvano,
           l_atdsrvorg  like datmservico.atdsrvorg, 
           tipo smallint # 1- Sem retorno, 2 - Com retorno
    
    define l_lcvcod         like datmavisrent.lcvcod
    define l_lcvnom         like datklocadora.lcvnom
    define l_aviestcod      like datmavisrent.aviestcod
    define l_avialgmtv      like datmavisrent.avialgmtv
    define l_avioccdat      like datmavisrent.avioccdat
    define l_avivclvlr      like datmavisrent.avivclvlr
    define l_aviprvent      like datmavisrent.aviprvent
    define l_avivclcod      like datmavisrent.avivclcod
    define l_lcvlojtip      like datkavislocal.lcvlojtip
    define l_lcvregprccod   like datkavislocal.lcvregprccod
    define l_lcvvcldiavlr   like datklocaldiaria.lcvvcldiavlr
    define l_prtsgrvlr      like datklocaldiaria.prtsgrvlr
    define l_diafxovlr      like datklocaldiaria.diafxovlr 
    define l_motivo         char(10)

    initialize l_lcvcod      , l_lcvnom      , l_aviestcod,
               l_avialgmtv   , l_avioccdat   , l_avivclvlr,
               l_aviprvent   , l_avivclcod   , l_lcvlojtip,
               l_lcvregprccod, l_lcvvcldiavlr, l_prtsgrvlr,
               l_diafxovlr,l_motivo  to null
    
    if m_prep_flag = false then
        call ctb00g03_seleciona_sql()
        let m_prep_flag = true
    end if
    
    let m_ctb00g03.atdsrvnum = l_atdsrvnum
    let m_ctb00g03.atdsrvano = l_atdsrvano
    let m_ctb00g03.atdsrvorg = l_atdsrvorg


    ### // Seleciona os dados do laudo de locação //
    whenever error continue
    open cctb00g03017 using m_ctb00g03.atdsrvnum,
                            m_ctb00g03.atdsrvano
    fetch cctb00g03017 into l_lcvcod   ,
                            l_lcvnom,
                            l_aviestcod,
                            l_avialgmtv,
                            l_avioccdat,
                            l_avivclvlr,
                            l_aviprvent,
                            m_ctb00g03.nfsemsdat,
                            l_avivclcod
    whenever error stop
    if sqlca.sqlcode < 0 then
        display 'OCORREU UM ERRO EM cctb00g03017 - SqlCode ',sqlca.sqlcode
        return
    end if

    ### // Seleciona dados do favorecido //
    whenever error continue
    open cctb00g03018 using l_lcvcod,
                            l_aviestcod
    fetch cctb00g03018 into m_ctb00g03.fvrnom,
                            m_ctb00g03.pestip
    whenever error stop
    if sqlca.sqlcode = notfound then
        let m_ctb00g03.fvrnom = null
        let m_ctb00g03.pestip = "J"
    else
        whenever error stop
        if sqlca.sqlcode < 0 then
            display 'OCORREU UM ERRO EM cctb00g03018 - SqlCode ',sqlca.sqlcode
            return
        end if
    end if

    ### // Se não encontrou dados do favorecido, seleciona da loja //
    if m_ctb00g03.fvrnom is null then
        whenever error continue
        open cctb00g03025 using l_aviestcod
        fetch cctb00g03025 into m_ctb00g03.fvrnom
        whenever error stop
        if sqlca.sqlcode = notfound then
            let m_ctb00g03.fvrnom = null
        else
            whenever error stop
            if sqlca.sqlcode < 0 then
                display 'OCORREU UM ERRO EM cctb00g03025 - SqlCode ',sqlca.sqlcode
                return
            end if
        end if
    end if

    ### // Se não encontrou dados do favorecido, seleciona da locadora //
    if m_ctb00g03.fvrnom is null then
        whenever error continue
        open cctb00g03026 using l_lcvcod
        fetch cctb00g03026 into m_ctb00g03.fvrnom
        whenever error stop
        if sqlca.sqlcode = notfound then
            let m_ctb00g03.fvrnom = null
        else
            whenever error stop
            if sqlca.sqlcode < 0 then
                display 'OCORREU UM ERRO EM cctb00g03026 - SqlCode ',sqlca.sqlcode
                return
            end if
        end if
    end if

    ### // Se não encontrou dados do favorecido, seleciona da locadora //
    if m_ctb00g03.fvrnom is null then
        whenever error continue
        open cctb00g03026 using l_lcvcod
        fetch cctb00g03026 into m_ctb00g03.fvrnom
        whenever error stop
        if sqlca.sqlcode = notfound then
            let m_ctb00g03.fvrnom = null
        else
            whenever error stop
            if sqlca.sqlcode < 0 then
                display 'OCORREU UM ERRO EM cctb00g03026 - SqlCode ',sqlca.sqlcode
                return
            end if
        end if
    end if

    ### // Seleciona os dados da loja locadora //
    whenever error continue
    open cctb00g03019 using l_aviestcod
    fetch cctb00g03019 into l_lcvlojtip,
                            l_lcvregprccod
    whenever error stop
    if sqlca.sqlcode < 0 then
        display 'OCORREU UM ERRO EM cctb00g03019 - SqlCode ',sqlca.sqlcode
        return
    end if

    ### // Seleciona os dados da tarifa de locação //
    whenever error continue
    open cctb00g03020 using l_avivclcod,
                            l_lcvlojtip,
                            l_lcvregprccod,
                            l_lcvcod,
                            m_ctb00g03.atdsrvabrdat,
                            l_aviprvent
    fetch cctb00g03020 into l_prtsgrvlr,
                            l_diafxovlr
    whenever error stop
    if sqlca.sqlcode = notfound then
        let l_prtsgrvlr = 0 ### // Valor da diária p/ Porto  //
        let l_diafxovlr = 0 ### // Valor fixo p/ faixa Porto //
    else
        whenever error stop
        if sqlca.sqlcode < 0 then
            display "OCORREU UM ERRO EM cctb00g03020, ", sqlca.sqlcode
            return
        end if
    end if

    ### // Calcula o valor do provisionamento //
    if l_diafxovlr > 0 then
        ### // Valor fixo (não multiplica) //
        let m_ctb00g03.opgvlr = (l_diafxovlr * l_aviprvent)
        display "l_diafxovlr: ",l_diafxovlr
        display "l_aviprvent: ",l_aviprvent
        display "m_ctb00g03.opgvlr: ",m_ctb00g03.opgvlr
    else
        if l_prtsgrvlr > 0 then
            ### // Valor da diária para a Porto //
            let m_ctb00g03.opgvlr = (l_prtsgrvlr * l_aviprvent) 
            display "l_prtsgrvlr: ",l_prtsgrvlr  
            display "l_aviprvent: ",l_aviprvent            
            display "m_ctb00g03.opgvlr: ",m_ctb00g03.opgvlr  
            
        else
            ### // Se não encontrou tabela tarifa, utiliza valor do laudo //
            let m_ctb00g03.opgvlr = (l_avivclvlr * l_aviprvent)
            display "l_avivclvlr: ",l_avivclvlr              
            display "l_aviprvent: ",l_aviprvent              
            display "m_ctb00g03.opgvlr: ",m_ctb00g03.opgvlr  
        end if
    end if

    ### // Calcula a provável data de pagamento //
    call dias_uteis(m_ctb00g03.nfsvncdat, 20, "", "S", "S")
          returning m_ctb00g03.nfsvncdat

    ###################################################
    ##    // Seleciona o Tipo de Movimento //        ##
    ##-----------------------------------------------##
    ##  1 -  Carro-Extra Pagamento                   ##
    ##  2 -  Carro-Extra Sinistros Pagamento         ##
    ##  3 -  Locação Veículos Para Cia Pagamento     ##
    ##  4 -  Carro-Extra Pagamento                   ##
    ##  5 -  Carro-Extra Sinistros Pagamento         ##
    ##  6 -  Locação Veículos Para Cia Pagamento     ##
    ##  7 -  Locação Veículos Para AZUL SEGUROS      ##
    ##  9 -  Indenização Integral                    ##
    ###################################################

    if l_avialgmtv = 0 or
       l_avialgmtv = 1 or
       l_avialgmtv = 3 or
       l_avialgmtv = 6 or
       l_avialgmtv = 9 then

        ### // Seleciona os dados do sinistro //
        if m_ctb00g03.succod    is not null and
           m_ctb00g03.aplnumdig is not null and
           m_ctb00g03.itmnumdig is not null then
            whenever error continue
            open cctb00g03021 using m_ctb00g03.succod,
                                    m_ctb00g03.aplnumdig,
                                    m_ctb00g03.itmnumdig,
                                    l_avioccdat
            fetch cctb00g03021 into m_ctb00g03.sinnum,
                                    m_ctb00g03.sinano
            whenever error stop
            if sqlca.sqlcode < 0 then
                display 'OCORREU UM ERRO EM cctb00g03021 - SqlCode ',sqlca.sqlcode
                    return
            end if
        end if

    end if

    call ctb00g03_verifcod()

    if m_ctb00g03.ciaempcod = 35 then   #Empresa Azul Seguros

       let m_ctb00g03.opgmvttip = 7    ### // AZUL SEGUROS //

    else # Porto Seguro e demais empresas
        case l_avialgmtv
           when 6
                ### // Se motivo 6 utiliza ramcod 553 //
                if m_ctb00g03.ramcod = 31 then
                    let m_ctb00g03.ramcod = 53
                else
                    let m_ctb00g03.ramcod = 553
                end if
           end case
             
           select cpodes 
             into m_ctb00g03.opgmvttip                 
             from iddkdominio              
            where cponom = 'algmtvXmvttip' 
              and cpocod = l_avialgmtv  
            
           if sqlca.sqlcode <> 0 then
             display "Nao encontrou tipo de movimento para o motivo l_avialgmtv : ",l_avialgmtv
           end if       
     end if
      
      if l_avialgmtv <> 0 and 
         l_avialgmtv <> 1 and 
         l_avialgmtv <> 2 and 
         l_avialgmtv <> 3 and 
         l_avialgmtv <> 4 and 
         l_avialgmtv <> 6 then 
         let m_contab_teste = true
      end if 
      
      call ctb00g03_trsrvcortesia()
      
     display "l_avialgmtvCE: ",l_avialgmtv 
     display "m_ctb00g03.opgmvttipCE: ",m_ctb00g03.opgmvttip
     
     if tipo = 2 then                 
        return  m_ctb00g03.opgmvttip  
     end if                            
      
end function

#--------------------------------------------------------------------------#
function ctb00g03_trsrvre(l_atdsrvnum,l_atdsrvano,l_atdsrvorg,tipo)
#--------------------------------------------------------------------------#

    define l_atdsrvnum  like datmservico.atdsrvnum,
           l_atdsrvano  like datmservico.atdsrvano,
           l_atdsrvorg  like datmservico.atdsrvorg, 
           tipo smallint # 1- Sem retorno, 2 - Com retorno
    
    define l_socntzcod   smallint
    define l_vlrmaximo   dec(12,2)
    define l_vlrdiferenc dec(12,2)
    define l_vlrmltdesc  dec(12,2)
    define l_nrsrvs      smallint
    define l_flgtab      smallint
    define l_contador    smallint
    define l_ramgrpcod   like gtakram.ramgrpcod     #PSI 202720
    define l_retorno     smallint                   #PSI 202720
    define l_mensagem    char(80)                   #PSI 202720

    initialize l_socntzcod  , l_vlrmaximo  , l_vlrdiferenc,
               l_vlrmltdesc , l_nrsrvs     , l_flgtab     ,
               l_contador   , l_ramgrpcod  , l_retorno    ,
               l_mensagem  to null
    
    if m_prep_flag = false then
        call ctb00g03_seleciona_sql()
        let m_prep_flag = true
    end if
    
    let m_ctb00g03.atdsrvnum = l_atdsrvnum
    let m_ctb00g03.atdsrvano = l_atdsrvano
    let m_ctb00g03.atdsrvorg = l_atdsrvorg 
    
    # Valor do Proviosionamento será consultado por origem com base em um dominio 
    # Inicio PSI-2013-08022EV - Variar o Valor do Provisionamento por Origem do Serviço  
    
    #### // Valor sugerido para o servico //
    #
    #call ctx15g00_vlrre(m_ctb00g03.atdsrvnum, m_ctb00g03.atdsrvano)
    #          returning l_socntzcod, m_ctb00g03.opgvlr, l_vlrmaximo,
    #                    l_vlrdiferenc, l_vlrmltdesc, l_nrsrvs, l_flgtab
    # 
    # display "m_ctb00g03.opgvlrRE: ",m_ctb00g03.opgvlr
    # display "l_socntzcod: ",l_socntzcod
    # 
    # if m_ctb00g03.opgvlr is null or m_ctb00g03.opgvlr <> '' then
    # 
    #    display "sqlca.sqlcode3: ",sqlca.sqlcode  
    #    select cpodes                     
    #      into m_ctb00g03.opgvlr          
    #      from iddkdominio                
    #     where cponom = 'valor_padrao'    
    #       and cpocod = m_ctb00g03.atdsrvorg  
    #       display "l_valor: ",m_ctb00g03.opgvlr  
    #       
    # end if 
    
    whenever error continue
       open cctb00g03114 using m_ctb00g03.atdsrvorg  
           fetch cctb00g03114 into m_ctb00g03.opgvlr
       close cctb00g03114
       display "Valor pesquisado" , m_ctb00g03.opgvlr
    whenever error stop
    
     if sqlca.sqlcode != 0 then
         display 'OCORREU UM ERRO EM cctb00g03114 - SqlCode ',sqlca.sqlcode
         whenever error continue 
            open cctb00g03115
               fetch cctb00g03115 into m_ctb00g03.opgvlr
            close cctb00g03115
            display "Valor pesquisado 2" , m_ctb00g03.opgvlr
         whenever error stop    
     end if
    
    
    # Fim PSI-2013-08022EV - Variar o Valor do Provisionamento por Origem do Serviço
     
    ### // Seleciona a modalidade //
    whenever error continue
    open cctb00g03022 using m_ctb00g03.succod,
                            m_ctb00g03.ramcod,
                            m_ctb00g03.aplnumdig
    fetch cctb00g03022 into m_ctb00g03.rmemdlcod

    whenever error stop
    if sqlca.sqlcode < 0 then
        display 'OCORREU UM ERRO EM cctb00g03022 - SqlCode ',sqlca.sqlcode
        return
    end if

                #-----------------------------------------------------------#
                # Cod.  Despesa Contabil                                    #
                #-----------------------------------------------------------#
                #  21   Atend.RE (clausulas 34A,35A,35R,30,31,32,10,11 e 12)#
                #  22   Porto Socorro - clausula 095                        #
                #  23   Sinistros a regularizar - Atendimento RE            #
                #  24   Residencia - Reparos sem cobertura                  #
                #  25   Atend resid apol seg Vida+Mulher                    #
                #  26   Atend resid apol seg Educacional Coletivo           #
                #  27   Atend garantia estendida                            #
                #  30   Atend resid cartao saude (grupo ramo = 5)           #
                #-----------------------------------------------------------#

    case m_ctb00g03.atdsrvorg

        when 9
            let m_ctb00g03.opgmvttip = 21   ### // Se origem = RE //

            if m_ctb00g03.ramcod =  31 or
               m_ctb00g03.ramcod = 531 then

                let l_contador = 0
                whenever error continue
                open cctb00g03023 using m_ctb00g03.succod,
                                        m_ctb00g03.aplnumdig,
                                        m_ctb00g03.itmnumdig
                fetch cctb00g03023 into l_contador

                whenever error stop
                if sqlca.sqlcode < 0 then
                    display 'OCORREU UM ERRO EM cctb00g03023 - SqlCode ',sqlca.sqlcode
                    return
                end if

                    let m_ctb00g03.opgmvttip = 22


            end if

            ### // 25 Atend resid apol seg Vida+Mulher //

            if m_ctb00g03.ramcod = 993 then
                let m_ctb00g03.opgmvttip = 25
            end if

            ### // 26 Atend resid apol seg Educacional Coletivo //
            if m_ctb00g03.ramcod = 980 then
                let m_ctb00g03.opgmvttip = 26
            end if

            ### // 27 Atend garantia estendida //
            if m_ctb00g03.ramcod = 171 or
               m_ctb00g03.ramcod = 195 then
                let m_ctb00g03.opgmvttip = 27
            end if

             #PSI 202720
            ### //30   Atend resid cartao saude (grupo ramo = 5)
            #buscar grupo do ramo
            call cty10g00_grupo_ramo(1,
                                     m_ctb00g03.ramcod)
                 returning l_retorno,
                           l_mensagem,
                           l_ramgrpcod
            if l_ramgrpcod = 5 then
               let m_ctb00g03.opgmvttip = 30
            end if

            ### // Se origem = Sinistro RE //

        when 13
            let m_ctb00g03.opgmvttip = 23   ### // Se origem = Sinistro RE //

    end case
    
     call ctb00g03_trsrvcortesia()
    
     display "m_ctb00g03.atdsrvorgRE: ",m_ctb00g03.atdsrvorg
     display "m_ctb00g03.opgmvttipRE: ",m_ctb00g03.opgmvttip
     
     if tipo = 2 then                 
        return  m_ctb00g03.opgmvttip  
     end if 
     
end function

#--------------------------------------------------------------------------#
function ctb00g03_trsrvcortesia()
#--------------------------------------------------------------------------#

    define lr_servico   record
       atdsrvorg       like datmservico.atdsrvorg,                  
       pgttipcodps     like dbscadtippgt.pgttipcodps,           
       itaasstipcod    like datkassunto.itaasstipcod,           
       prporg          like datrligprp.prporg,           
       prpnumdig       like datrligprp.prpnumdig,
       c24astcod       like datmligacao.c24astcod            
    end record
    
    define l_chave        like datkgeral.grlchv, 
           l_FIM          like datkgeral.grlchv,
           l_contingecia  smallint,
           l_opgmvttip    like ctimsocprv.opgmvttip
    
    if m_prep_flag = false then
        call ctb00g03_seleciona_sql()
        let m_prep_flag = true
    end if

    ### // Seleciona os dados do laudo //
    whenever error continue
    open cctb00g03111 using m_ctb00g03.atdsrvnum,
                            m_ctb00g03.atdsrvano
                            
    fetch cctb00g03111 into lr_servico.atdsrvorg,   
                            lr_servico.pgttipcodps, 
                            lr_servico.itaasstipcod,
                            lr_servico.prporg,      
                            lr_servico.prpnumdig,
                            lr_servico.c24astcod
    if sqlca.sqlcode < 0 then
        display 'Ocorreu um erro ao buscar os dados cctb00g03110 - SqlCode ',sqlca.sqlcode
    end if
     
    close cctb00g03111      
    whenever error stop
    
    let l_chave = null 
    let l_FIM = null 
    
    if lr_servico.itaasstipcod = 3 then
       let l_FIM = 'ASSUNT',lr_servico.itaasstipcod using '<&'   
    end if 
    
    if lr_servico.pgttipcodps is not null and 
       lr_servico.pgttipcodps <> " " then
       
       let l_FIM = 'TIPPGT',lr_servico.pgttipcodps using '<&'       
    else
       if lr_servico.prporg is not null    and 
          lr_servico.prporg <> " "         and
          lr_servico.prpnumdig is not null and 
          lr_servico.prpnumdig <> " "      and 
          lr_servico.itaasstipcod <> 3     then
          
          let l_FIM = 'SEMAPOL'
       else
          whenever error continue
          open cctb00g03112 using m_ctb00g03.atdsrvnum,
                                  m_ctb00g03.atdsrvano
          fetch cctb00g03112 into l_contingecia
          
          if sqlca.sqlcode = 0 then   
             let l_FIM = 'CONTINGE'
          end if 
          
          close cctb00g03112
          whenever error stop          
       end if
    end if   
        
    if  l_FIM is not null then
       let l_chave = 'PSOORG',lr_servico.atdsrvorg using '<&',l_FIM clipped
       select grlinf 
         into l_opgmvttip
         from datkgeral
        where grlchv = l_chave
       
       if sqlca.sqlcode = notfound then
          let l_chave = 'PSOORG0',l_FIM clipped
          select grlinf 
            into l_opgmvttip
            from datkgeral
           where grlchv = l_chave 
           if sqlca.sqlcode = 0 then
             let m_ctb00g03.opgmvttip = l_opgmvttip
          end if           
       else
          if sqlca.sqlcode = 0 then
              let m_ctb00g03.opgmvttip = l_opgmvttip
          end if 
       end if
    end if 
    
    let m_cortesia = "Assunto: ",lr_servico.c24astcod,"Servico: ",m_ctb00g03.atdsrvnum using '<<<<<<<<<<&',"-",m_ctb00g03.atdsrvano using '<&',
                     " Tipo de Movimento: ",m_ctb00g03.opgmvttip," Chave: ",l_chave clipped
   display m_cortesia 
           
end function

#--------------------------------------------------------------------------#
function ctb00g03_verifcod()
#--------------------------------------------------------------------------#

    if m_prep_flag = false then
        call ctb00g03_seleciona_sql()
        let m_prep_flag = true
    end if

    ### // Verifica sucursal //
    if m_ctb00g03.succod is null or
       m_ctb00g03.succod = 0     then
        let m_ctb00g03.succod = 0
    end if

    ### // Verifica ramo //
    if m_ctb00g03.ramcod is null then
        let m_ctb00g03.ramcod = 0
    end if

    ### // Verifica susep //
    if m_ctb00g03.corsus is null then
        let m_ctb00g03.corsus = "######"
    end if

    ### // Verifica código da modalidade //
    if m_ctb00g03.rmemdlcod is null then
        let m_ctb00g03.rmemdlcod = 0
    end if

    ### // Verifica número da apólice //
    if m_ctb00g03.aplnumdig is null then
        let m_ctb00g03.aplnumdig = 0
    end if

    ### // Verifica item da apólice //
    if m_ctb00g03.itmnumdig is null then
        let m_ctb00g03.itmnumdig = 0
    end if

    ### // Verifica o número do endosso //
    if m_ctb00g03.edsnumref is null then
        let m_ctb00g03.edsnumref = 0
    end if

    ### // Verifica o nome do favorecido //
    if m_ctb00g03.fvrnom is null then
        let m_ctb00g03.fvrnom = "(NAO ENCONTRADO)"
    end if

end function


#------------------------------------------#
function ctb00g03_evento_25(lr_parametro)
#------------------------------------------#

define lr_parametro              record
         evento                  char(06),
         empresa                 char(50),
         dt_movto                date,
         chave_primaria          char(50),
         ordem_pagamento         char(50),
         apolice                 char(50),
         sucursal                char(50),
         projeto                 char(50),
         dt_chamado              date,
         fvrcod                  char(50),
         fvrnom                  char(50),
         nfnum                   char(50),
         corsus                  char(50),
         cctnum                  char(50),
         modalidade              char(50),
         ramo                    char(50),
         opgvlr                  char(50),
         dt_vencto               date
end record

define lr_figrc006 record
         coderro     integer,
         menserro    char(30),
         msgid       char(24),
         correlid    char(24)
  end record
  
  define l_xml         char(32766),
         l_docHandle   integer,
         l_tipodata1   char(02),
         l_tipodata2   char(02),
         l_tipodata3   char(02)
  
  initialize lr_figrc006.* to null
  initialize l_xml, l_docHandle, l_tipodata1, l_tipodata2, l_tipodata3 to null

if lr_parametro.evento = "25.2" or
lr_parametro.evento = "25.118" or
lr_parametro.evento = "25.119" or
lr_parametro.evento = "25.3" then
        let l_tipodata1 = "25"
        let l_tipodata2 = "9"
else
        let l_tipodata1 = "9"
        let l_tipodata2 = "25"
end if

let l_tipodata3 = "8"

if lr_parametro.dt_movto is null or lr_parametro.dt_movto = "" then
        let lr_parametro.dt_movto = today
end if

call fgl_inicia_protocolo_camada()

call fgl_novo_documento("Eventos") RETURNING l_docHandle


let lr_parametro.fvrnom = ctx14g00_TiraAcentos(lr_parametro.fvrnom)

call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/CodigoEvento",lr_parametro.evento)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/SistemaOrigem", "25")
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Empresa/Codigo", lr_parametro.empresa)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/DataCompetencia/Dia", DAY(lr_parametro.dt_movto))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/DataCompetencia/Mes", MONTH(lr_parametro.dt_movto))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/DataCompetencia/Ano", YEAR(lr_parametro.dt_movto))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/ChavePrimariaOrigem", lr_parametro.chave_primaria)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Documentos/OrdemPagamento/Numero", lr_parametro.ordem_pagamento)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Documentos/Apolice/Numero", lr_parametro.apolice)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Empresa/Sucursal/Codigo", lr_parametro.sucursal)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Documentos/Projeto/Numero", lr_parametro.projeto)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[0]/Dia", DAY(lr_parametro.dt_chamado))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[0]/Mes", MONTH(lr_parametro.dt_chamado))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[0]/Ano", YEAR(lr_parametro.dt_chamado))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[0]/Tipo", l_tipodata1)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[1]/Dia", DAY(lr_parametro.dt_chamado))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[1]/Mes", MONTH(lr_parametro.dt_chamado))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[1]/Ano", YEAR(lr_parametro.dt_chamado))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[1]/Tipo", l_tipodata3)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Fornecedor/Codigo", lr_parametro.fvrcod)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Fornecedor/Nome", lr_parametro.fvrnom)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Documentos/NotaFiscal/Numero", lr_parametro.nfnum)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Corretor/SUSEP", lr_parametro.corsus)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Empresa/Departamento/Codigo", lr_parametro.cctnum)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Empresa/ModalidadeRamo/Codigo", lr_parametro.modalidade)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Empresa/Ramo/Codigo", lr_parametro.ramo)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Valores/Valor/Valor", lr_parametro.opgvlr)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[2]/Dia", DAY(lr_parametro.dt_vencto))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[2]/Mes", MONTH(lr_parametro.dt_vencto))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[2]/Ano", YEAR(lr_parametro.dt_vencto))
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Datas/Data[2]/Tipo", l_tipodata2)
call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Valores/Valor/CaracteristicaValor", "25")

let l_xml = fgl_retorna_documento(l_docHandle)

display lr_parametro.evento, "|",
        lr_parametro.empresa, "|",
        lr_parametro.dt_movto, "|",
        lr_parametro.chave_primaria, "|",
        lr_parametro.ordem_pagamento, "|",
        lr_parametro.apolice, "|",
        lr_parametro.sucursal, "|",
        lr_parametro.projeto, "|",
        lr_parametro.dt_chamado, "|",
        lr_parametro.fvrcod, "|",
        lr_parametro.fvrnom, "|",
        lr_parametro.nfnum, "|",
        lr_parametro.corsus, "|",
        lr_parametro.cctnum, "|",
        lr_parametro.modalidade, "|",
        lr_parametro.ramo, "|",
        lr_parametro.opgvlr, "|",
        lr_parametro.dt_vencto, "|",
        lr_parametro.dt_chamado

call fgl_finaliza_protocolo_camada()

call figrc006_enviar_datagrama_mq_rq("CONTABIL.ENV", l_xml, "25", loop())
         returning lr_figrc006.*
  if lr_figrc006.coderro <> 0 then
    display "l_xml", l_xml clipped
    display "retorno lr_figrc006", lr_figrc006.*
    let m_reg_erro_mq = m_reg_erro_mq + 1
    let m_mensagemerro = ""
   let m_mensagemerro = "Erro no envio da mensagem :", lr_figrc006.menserro
    call errorlog(m_mensagemerro)
  else
    let m_reg_enviados = m_reg_enviados + 1
 end if

  initialize l_xml, l_docHandle to null
  
end function

#--------------------------------
function ctb00g03_ccusto(lr_param)
#--------------------------------

  define lr_param record
         empcod smallint,
         ramcod integer,
         rmemdlcod smallint
  end record
  
  define ws record
          ctbcrtcod integer
  end record
  
  define ret_ctbcrtcod integer
  
  initialize ws.* to null
  initialize ret_ctbcrtcod to null
  
  open cctb00g03104 using lr_param.empcod, lr_param.ramcod, lr_param.rmemdlcod
  fetch cctb00g03104 into ws.ctbcrtcod
  
  if ws.ctbcrtcod is not null and ws.ctbcrtcod <> 0 then
          let ret_ctbcrtcod = ws.ctbcrtcod
  else
          let ret_ctbcrtcod = null
  end if
  
  return ret_ctbcrtcod

end function


#TODO: ATENCAO FUNCAO REPLICADA POIS ws.ctbcrtcod NESTE MODULO DEFINIDA 
#      COMO LOCAL E GLOBAL, PODE GERAR ERRO DE DADOS VERIFICAR
#----------------------------------------------------------------
function ctb00g03_ccusto2(lr_param)
#----------------------------------------------------------------

  define lr_param record
         empcod     smallint,
         ramcod     integer ,
         rmemdlcod  smallint
  end record
  
  define l_ctbcrtcod   smallint ,
         ret_ctbcrtcod smallint ,
         l_cmd         char(300)
  
  initialize l_ctbcrtcod, ret_ctbcrtcod, l_cmd to null
  
  let l_cmd = " select ctbcrtcod from ctgrcrtram_new "
             ," where empcod = ? "
             ,"   and ramcod = ? "
             ,"   and rmemdlcod = ? "
             ,"   and ctbcrtcod not in (1981, 1965) "
  prepare p_carteira_sel from l_cmd
  declare c_carteira_sel cursor for p_carteira_sel
  
  #display "RECEB: "
  #display 'lr_param.empcod   : ', lr_param.empcod   
  #display 'lr_param.ramcod   : ', lr_param.ramcod   
  #display 'lr_param.rmemdlcod: ', lr_param.rmemdlcod
  
  whenever error continue
  open c_carteira_sel using lr_param.empcod, lr_param.ramcod, lr_param.rmemdlcod
  fetch c_carteira_sel into l_ctbcrtcod
  whenever error stop
  
  #display "RES: "
  #display 'ws.ctbcrtcod      : ', l_ctbcrtcod
  
  if l_ctbcrtcod is not null and 
     l_ctbcrtcod != 0 
     then
     let ret_ctbcrtcod = l_ctbcrtcod
  else
     let ret_ctbcrtcod = null
  end if
  
  return ret_ctbcrtcod

end function

#---------------------------------
function ctb00g03_canprvdsp(l_par)
#---------------------------------
#PSI196606
#Esta funcao eh a substituicao da ctb00g03_bxaprvdsp, pois
#esta denominacao condiz mais com seu objetivo, que eh
#o de cancelar o provisionamento e nao baixar o provisionamento

  define l_cmd char(400)

  define l_par record
      atdsrvnum   like ctimsocprv.atdsrvnum,
      atdsrvano   like ctimsocprv.atdsrvano,
      socopgnum   like ctimsocprv.opgnum
  end record

  define l_ajusvlr        like ctimsocprv.opgvlr
  define l_lcvcod         like datmavisrent.lcvcod
  define l_lcvnom         like datklocadora.lcvnom
  define l_aviestcod      like datmavisrent.aviestcod
  define l_avialgmtv      like datmavisrent.avialgmtv
  define l_avioccdat      like datmavisrent.avioccdat
  define l_avivclvlr      like datmavisrent.avivclvlr
  define l_aviprvent      like datmavisrent.aviprvent
  define l_avivclcod      like datmavisrent.avivclcod
  define l_lcvlojtip      like datkavislocal.lcvlojtip
  define l_lcvregprccod   like datkavislocal.lcvregprccod
  define l_lcvvcldiavlr   like datklocaldiaria.lcvvcldiavlr
  define l_prtsgrvlr      like datklocaldiaria.prtsgrvlr
  define l_diafxovlr      like datklocaldiaria.diafxovlr
  define l_prporg         like datrligprp.prporg
  define l_prpnumdig      like datrligprp.prpnumdig
  define l_corsus         like apamcor.corsus
  define l_eventograva    char(06)
  define l_ciaempcod      like datmservico.ciaempcod
  
  initialize l_cmd         , l_ajusvlr   ,  l_lcvcod      ,  l_lcvnom      , 
             l_aviestcod   , l_avialgmtv ,  l_avioccdat   ,  l_avivclvlr   , 
             l_aviprvent   , l_avivclcod ,  l_lcvlojtip   ,  l_lcvregprccod, 
             l_lcvvcldiavlr, l_prtsgrvlr ,  l_diafxovlr   ,  l_prporg      , 
             l_prpnumdig   , l_corsus    ,  l_eventograva ,  l_ciaempcod
             to null

  let l_ciaempcod = 0
  
  initialize m_ctb00g03.* to null
  if m_prep_flag = false then
      call ctb00g03_seleciona_sql()
      let m_prep_flag = true
  end if

  open cctb00g03108 using l_par.atdsrvnum, l_par.atdsrvano
  fetch cctb00g03108 into l_ciaempcod
  
  if l_ciaempcod = 1 then
  
     ### // Seleciona os dados do provisionamento //
     call ctb00g03_selprvdsp(l_par.atdsrvnum,
                             l_par.atdsrvano) returning ws_sqlcode

     if ws_sqlcode = 0 then

        whenever error continue
        open cctb00g03001 using l_par.atdsrvnum,
                                l_par.atdsrvano
        fetch cctb00g03001 into l_ajusvlr
        whenever error stop
        
        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode < 0 then
               error " Problemas de acesso cctb00g03001, ", sqlca.sqlcode
               return sqlca.sqlcode, lr_eventocan.*
           else
               let l_ajusvlr = 0
           end if
        end if
        
        ### // Seleciona dados do serviço //
        whenever error continue
        open cctb00g03003 using l_par.atdsrvnum,
                                l_par.atdsrvano
        fetch cctb00g03003 into m_ctb00g03.atdsrvorg,
                                m_ctb00g03.atdsrvabrdat,
                                m_ctb00g03.nfsvncdat,
                                m_ctb00g03.atdprscod,
                                m_ctb00g03.asitipcod,
                                m_ctb00g03.vclcoddig,
                                m_ctb00g03.socvclcod,
                                m_ctb00g03.ciaempcod
        whenever error stop
        
        if sqlca.sqlcode = notfound 
           then
           let m_ctb00g03.atdsrvorg    = null
           let m_ctb00g03.atdsrvabrdat = null
           let m_ctb00g03.nfsvncdat    = null
           let m_ctb00g03.atdprscod    = null
           let m_ctb00g03.asitipcod    = null
           let m_ctb00g03.vclcoddig    = null
           let m_ctb00g03.socvclcod    = null
        else
           if sqlca.sqlcode < 0 then
              display "OCORREU UM ERRO EM cctb00g03003, ", sqlca.sqlcode
              return sqlca.sqlcode, lr_eventocan.*
           end if
        end if
        
        ###// Calcula o valor provisionado original + valor ajustado //
        let m_ctb00g03.opgvlr = m_ctb00g03.opgvlr + l_ajusvlr

        ###// Inverte o sinal do valor //
        let m_ctb00g03.opgvlr    = m_ctb00g03.opgvlr * (-1)
        let m_ctb00g03.prvmvttip = 4    ## // Baixa //
        let m_ctb00g03.atldat    = today
        let m_ctb00g03.opgprcflg = "N"
        
        if m_ctb00g03.ramcod is null then
                let m_ctb00g03.ramcod = 531
        end if
        
        if m_ctb00g03.corsus is null or m_ctb00g03.corsus = "######" then
        
           ###  // Seleciona susep caso nao tenha apolice emitida
           whenever error continue
           open cctb00g03101 using l_par.atdsrvnum,
                                   l_par.atdsrvano
           fetch cctb00g03101 into l_prporg,
                                   l_prpnumdig
           whenever error stop
           
           if sqlca.sqlcode = notfound then
              let l_prporg = null
              let l_prpnumdig = null
           else
              if sqlca.sqlcode < 0 then
                 display "OCORREU UM ERRO EM cctb00g03101, ", sqlca.sqlcode
                 return sqlca.sqlcode, lr_eventocan.*
              end if
           end if
           close cctb00g03101
           
           if l_prporg is not null and l_prpnumdig is not null
              then
              whenever error continue
              open cctb00g03102 using l_prporg,
                                      l_prpnumdig
              fetch cctb00g03102 into l_corsus
              whenever error stop
              
              if sqlca.sqlcode = notfound then
                 let l_corsus = null
              else
                 if sqlca.sqlcode < 0 then
                    display "OCORREU UM ERRO EM cctb00g03102, ", sqlca.sqlcode
                    return sqlca.sqlcode, lr_eventocan.*
                 end if
              end if
           end if
           
           let m_ctb00g03.corsus = l_corsus
           close cctb00g03102
        end if
        
        if m_ctb00g03.corsus is null then
           let m_ctb00g03.corsus = "######"
        end if
        
        if m_ctb00g03.conitfcod = 5 
           then
           if m_ctb00g03.opgmvttip = 1 or
              m_ctb00g03.opgmvttip = 4 or
              m_ctb00g03.opgmvttip = 5 or
              m_ctb00g03.opgmvttip = 6 or
              m_ctb00g03.opgmvttip = 7 or
              m_ctb00g03.opgmvttip = 22
              then
              if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                 let ws.provisionamento = "25.100"
              else
                 let ws.provisionamento = "25.120"
              end if
           end if
           
           if m_ctb00g03.opgmvttip = 21 or
              m_ctb00g03.opgmvttip = 23 or
              m_ctb00g03.opgmvttip = 24 or
              m_ctb00g03.opgmvttip = 25 or
              m_ctb00g03.opgmvttip = 26 
              then
              let ws.provisionamento = "25.100"
           end if
        else
           if m_ctb00g03.conitfcod = 25 then
              if m_ctb00g03.opgmvttip = 1 or
                 m_ctb00g03.opgmvttip = 2 
                 then
                 if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 
                    then
                    let ws.provisionamento = "25.100"
                 else
                    let ws.provisionamento = "25.120"
                 end if
              end if
              if m_ctb00g03.opgmvttip  = 3 then
                 let ws.provisionamento = "25.100"
              end if
           end if
        end if
        
        # Tratando o ramo
        call depara_ramo(m_ctb00g03.ramcod, m_ctb00g03.rmemdlcod)
        returning ws.ramo_novo, ws.modalidade_nova

        if ws.ramo_novo <> 0 then
              let m_ctb00g03.ramcod = ws.ramo_novo
              let m_ctb00g03.rmemdlcod = ws.modalidade_nova
        end if

        #Identificando o centro de custo
        if m_ctb00g03.conitfcod = 5 
           then #auto e re
           if m_ctb00g03.opgmvttip = 1 or m_ctb00g03.opgmvttip = 2 or
              m_ctb00g03.opgmvttip = 4 or m_ctb00g03.opgmvttip = 5 or
              m_ctb00g03.opgmvttip = 6 or m_ctb00g03.opgmvttip = 7 or
              m_ctb00g03.opgmvttip = 21 or m_ctb00g03.opgmvttip = 22 or
              m_ctb00g03.opgmvttip = 23 or m_ctb00g03.opgmvttip = 24 or
              m_ctb00g03.opgmvttip = 25 or m_ctb00g03.opgmvttip = 26 
              then
              call ctb00g03_ccusto(l_ciaempcod, m_ctb00g03.ramcod, 
                                   m_ctb00g03.rmemdlcod)
                         returning ws.ctbcrtcod
              if ws.ctbcrtcod = 0 or ws.ctbcrtcod is null then
                 let ws.cctnum = 0
              else
                 let ws.cctnum = ws.ctbcrtcod
              end if
           end if
        end if
        
        if m_ctb00g03.conitfcod = 25 then
           call ctb00g03_ccusto(l_ciaempcod, m_ctb00g03.ramcod,
                                m_ctb00g03.rmemdlcod)
                      returning ws.ctbcrtcod
           if ws.ctbcrtcod = 0 or ws.ctbcrtcod is null then
              let ws.cctnum = 0
           else
              let ws.cctnum = ws.ctbcrtcod
           end if
        end if
        
        #Preparando variáveis para interface
        #evento
        let lr_evento.evento = ws.provisionamento

        #Empresa
        let l_cmd = "select empcod from  datmservico where atdsrvnum = ? and atdsrvano = ?"
        prepare pctb00g03052 from l_cmd
        declare cctb00g03052 cursor for pctb00g03052
        
        whenever error continue
        open cctb00g03052 using l_par.atdsrvnum, l_par.atdsrvano
        fetch cctb00g03052 into ws.empresa
        whenever error stop
        
        if sqlca.sqlcode <> 0 then
           error "Erro ao selecionar empresa cctb00g03020:, ", sqlca.sqlcode, 
                 " = ", sqlca.sqlerrd[2]
        end if
        close cctb00g03052
        
        if ws.empresa is not null then
           let lr_evento.empresa = ws.empresa
        end if

        #Data da competencia
        let lr_evento.dt_movto = m_ctb00g03.atldat

        #Chave primaria
        # a chave primaria deste evento e composta por data competencia, evento,
        # servico, op, data de vencimento, corretor
        let lr_evento.chave_primaria = m_ctb00g03.atldat,
                                       lr_evento.evento,
                                       l_par.atdsrvnum,
                                       0,
                                       m_ctb00g03.nfsvncdat,
                                       m_ctb00g03.corsus

        #OP
        let lr_evento.op = l_par.socopgnum

        #Apolice
        if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
           let m_ctb00g03.aplnumdig = l_prpnumdig
        else
           let lr_evento.apolice = m_ctb00g03.aplnumdig
        end if
        
        if lr_evento.apolice is null then
           let lr_evento.apolice = 0
        end if

        #Sucursal
        let lr_evento.sucursal = m_ctb00g03.succod

        #Projeto
        let lr_evento.projeto = m_ctb00g03.atdsrvnum

        #Data do Chamado
        let lr_evento.dt_chamado = m_ctb00g03.atdsrvabrdat

        #Favorecido
        if m_ctb00g03.conitfcod = 25 then
           ### // Seleciona os dados do laudo de locação //
           whenever error continue
           open cctb00g03017 using l_par.atdsrvnum,
                                   l_par.atdsrvano
           fetch cctb00g03017 into l_lcvcod   ,
                                   l_lcvnom,
                                   l_aviestcod,
                                   l_avialgmtv,
                                   l_avioccdat,
                                   l_avivclvlr,
                                   l_aviprvent,
                                   m_ctb00g03.nfsemsdat,
                                   l_avivclcod
           whenever error stop
           
           if sqlca.sqlcode < 0 then
              display 'OCORREU UM ERRO EM cctb00g03017 - SqlCode ',sqlca.sqlcode
              return sqlca.sqlcode, lr_eventocan.*
           end if
           close cctb00g03017
           
           let lr_evento.fvrcod = l_lcvcod
           let lr_evento.fvrnom = l_lcvnom
           
           call ctx25g05_carac_fon(lr_evento.fvrnom) returning ws.descfvr
           
           if ws.descfvr is not null then
              let lr_evento.fvrnom = ws.descfvr
           end if
        else
           if m_ctb00g03.atdprscod is not null then
              let lr_evento.fvrcod = m_ctb00g03.atdprscod
              let lr_evento.fvrnom = m_ctb00g03.fvrnom
              
              call ctx25g05_carac_fon(lr_evento.fvrnom) returning ws.descfvr
              if ws.descfvr is not null 
                 then
                 let lr_evento.fvrnom = ws.descfvr
              end if
           end if
        end if
        
        #Nota fiscal
        if m_ctb00g03.nfsnum is null or m_ctb00g03.nfsnum = 0 
           then
           let ws.nfsnum = 0
           
           let l_cmd = "select nfsnum from dbsmopgitm where socopgnum = ? "
           prepare pctb00g03056 from l_cmd
           declare cctb00g03056 cursor for pctb00g03056
           
           whenever error continue
           open cctb00g03056 using l_par.socopgnum
           fetch cctb00g03056 into ws.nfsnum
           whenever error stop
           
           if sqlca.sqlcode < 0 then
              error "Erro ao selecionar op cctb00g03056:, ", sqlca.sqlcode, 
                    " = ", sqlca.sqlerrd[2]
           end if
           close cctb00g03056
           
           let m_ctb00g03.nfsnum = ws.nfsnum
        end if
        
        if m_ctb00g03.nfsnum is null or m_ctb00g03.nfsnum = 0 then
           let m_ctb00g03.nfsnum = 1
        end if

        let lr_evento.nfnum = m_ctb00g03.nfsnum

        #Corretor
        let lr_evento.corsus = m_ctb00g03.corsus

        #Centro de custo
        let lr_evento.cctnum = ws.cctnum

        #Modalidade
        let lr_evento.modalidade = m_ctb00g03.rmemdlcod

        #Ramo
        let lr_evento.ramo = m_ctb00g03.ramcod

        #Valor
        let lr_evento.opgvlr = m_ctb00g03.opgvlr

        #Data de vencimento
        let lr_evento.dt_vencto =  m_ctb00g03.nfsvncdat
        if lr_evento.dt_vencto is null or lr_evento.dt_vencto = "" 
           then
           let l_cmd = "select socfatpgtdat from  dbsmopg where socopgnum = ?"
           prepare pctb00g03080 from l_cmd
           declare cctb00g03080 cursor for pctb00g03080
           
           whenever error continue
           open cctb00g03080 using lr_evento.op
           fetch cctb00g03080 into lr_evento.dt_vencto
           whenever error stop
           
           if sqlca.sqlcode < 0 then
              error "Erro ao selecionar dt vencimento - evento 25120",
                    sqlca.sqlcode,  sqlca.sqlerrd[2]
           end if
        close cctb00g03080
        
        end if

        if lr_evento.evento is null or lr_evento.evento = 0 then
           let lr_evento.evento = "25.120"
        end if

        if lr_evento.evento = "25.120" then
           let lr_evento.opgvlr = lr_evento.opgvlr * (-1)
        end if
        
        call ctb00g03_evento_25(lr_evento.*)
        
        let lr_eventocan.evento         = lr_evento.evento
        let lr_eventocan.empresa        = lr_evento.empresa
        let lr_eventocan.dt_movto       = lr_evento.dt_movto
        let lr_eventocan.chave_primaria = lr_evento.chave_primaria
        let lr_eventocan.op             = lr_evento.op
        let lr_eventocan.apolice        = lr_evento.apolice
        let lr_eventocan.sucursal       = lr_evento.sucursal
        let lr_eventocan.projeto        = lr_evento.projeto
        let lr_eventocan.dt_chamado     = lr_evento.dt_chamado
        let lr_eventocan.fvrcod         = lr_evento.fvrcod
        let lr_eventocan.fvrnom         = lr_evento.fvrnom
        let lr_eventocan.nfnum          = lr_evento.nfnum
        let lr_eventocan.corsus         = lr_evento.corsus
        let lr_eventocan.cctnum         = lr_evento.cctnum
        let lr_eventocan.modalidade     = lr_evento.modalidade
        let lr_eventocan.ramo           = lr_evento.ramo
        let lr_eventocan.opgvlr         = lr_evento.opgvlr
        let lr_eventocan.dt_vencto      = lr_evento.dt_vencto
        let lr_eventocan.dt_ocorrencia  = lr_evento.dt_chamado

        initialize lr_evento to null
     else
        return ws_sqlcode, lr_eventocan.*
     end if
  else
     return 999, lr_eventocan.*
  end if
  
  return 0, lr_eventocan.*

end function


#--------------------------------------------------------------------------#
function ctb00g03_bxaprvdsp(l_par2)
#--------------------------------------------------------------------------#

  define l_par2 record
      atdsrvnum   like ctimsocprv.atdsrvnum,
      atdsrvano   like ctimsocprv.atdsrvano
  end record

  define lr_evento_baixa  char(06)
  define l_cmd            char(400)
  define l_eventograva    char(06)
  define lr_evento_ajuste char(06)

  define l_ajusvlr        like ctimsocprv.opgvlr
  define l_lcvcod         like datmavisrent.lcvcod
  define l_lcvnom         like datklocadora.lcvnom
  define l_aviestcod      like datmavisrent.aviestcod
  define l_avialgmtv      like datmavisrent.avialgmtv
  define l_avioccdat      like datmavisrent.avioccdat
  define l_avivclvlr      like datmavisrent.avivclvlr
  define l_aviprvent      like datmavisrent.aviprvent
  define l_avivclcod      like datmavisrent.avivclcod
  define l_lcvlojtip      like datkavislocal.lcvlojtip
  define l_lcvregprccod   like datkavislocal.lcvregprccod
  define l_lcvvcldiavlr   like datklocaldiaria.lcvvcldiavlr
  define l_prtsgrvlr      like datklocaldiaria.prtsgrvlr
  define l_diafxovlr      like datklocaldiaria.diafxovlr
  define l_prporg         like datrligprp.prporg
  define l_prpnumdig      like datrligprp.prpnumdig
  define l_corsus         like apamcor.corsus
  define l_atdsrvorg      like datmservico.atdsrvorg
  define l_motivo         like datmavisrent.avialgmtv
  define l_lignum         like datmligacao.lignum
  define l_ligcvntip      like datmligacao.ligcvntip
  define l_contaclaus     integer
  define l_pstcoddig      like datmsrvacp.pstcoddig
  define l_fvrnom         like dpaksocorfav.socfavnom
  define l_desfvr         like dpaksocorfav.socfavnom
  define l_ciaempcod      like datmservico.ciaempcod

  initialize lr_evento_baixa , l_cmd           , l_eventograva   ,
             lr_evento_ajuste, l_ajusvlr       , l_lcvcod        ,
             l_lcvnom        , l_aviestcod     , l_avialgmtv     ,
             l_avioccdat     , l_avivclvlr     , l_aviprvent     ,
             l_avivclcod     , l_lcvlojtip     , l_lcvregprccod  ,
             l_lcvvcldiavlr  , l_prtsgrvlr     , l_diafxovlr     ,
             l_prporg        , l_prpnumdig     , l_corsus        ,
             l_atdsrvorg     , l_motivo        , l_lignum        ,
             l_ligcvntip     , l_contaclaus    , l_pstcoddig     ,
             l_fvrnom        , l_desfvr        , l_ciaempcod
             to null
 
  initialize m_ctb00g03.* to null

  let l_eventograva = null
  let l_ciaempcod = 0
  
  if m_prep_flag = false then
      call ctb00g03_seleciona_sql()
      let m_prep_flag = true
  end if

  open cctb00g03108 using l_par2.atdsrvnum, l_par2.atdsrvano
  fetch cctb00g03108 into l_ciaempcod

  ### // Seleciona os dados do provisionamento //
  call ctb00g03_selprvdsp(l_par2.atdsrvnum,
                          l_par2.atdsrvano)
                returning ws_sqlcode

  if ws_sqlcode = 0 then

     whenever error continue
     open cctb00g03001 using l_par2.atdsrvnum,
                             l_par2.atdsrvano
     fetch cctb00g03001 into l_ajusvlr
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = 100 then
           display "sqlca.sqlcode2: ",sqlca.sqlcode
           whenever error continue                  
           open cctb00g03113 using l_par2.atdsrvnum,
                                   l_par2.atdsrvano 
           fetch cctb00g03113 into l_ajusvlr        
           whenever error stop 
           if sqlca.sqlcode < 0 then
               error " Problemas de acesso cctb00g03113, ", sqlca.sqlcode
               return sqlca.sqlcode, lr_eventoaju.*
           else
              let l_ajusvlr = 0
           end if
        else 
           if sqlca.sqlcode < 0 then
               error " Problemas de acesso cctb00g03001, ", sqlca.sqlcode
               return sqlca.sqlcode, lr_eventoaju.*
           else
               let l_ajusvlr = 0
           end if
        end if
     end if

     ###// Calcula o valor provisionado original + valor ajustado //
     let m_ctb00g03.opgvlr = m_ctb00g03.opgvlr + l_ajusvlr

     ###// Inverte o sinal do valor //
     let m_ctb00g03.opgvlr    = m_ctb00g03.opgvlr * (-1)
     let m_ctb00g03.prvmvttip = 4    ## // Baixa //
     let m_ctb00g03.atldat    = today
     let m_ctb00g03.opgprcflg = "N"

     ###// Inclui registro de baixa na tabela da contabilidade //
     whenever error continue
     call ctb00g03_grvprvdsp(m_ctb00g03.conitfcod,
                             m_ctb00g03.prvtip,
                             m_ctb00g03.empcod,
                             m_ctb00g03.atdsrvnum,
                             m_ctb00g03.atdsrvano,
                             m_ctb00g03.opgnum,
                             m_ctb00g03.opgitmnum,
                             m_ctb00g03.prvmvttip,
                             m_ctb00g03.opgmvttip,
                             m_ctb00g03.corsus,
                             m_ctb00g03.nfsnum,
                             m_ctb00g03.nfsemsdat,
                             m_ctb00g03.nfsvncdat,
                             m_ctb00g03.sinano,
                             m_ctb00g03.sinnum,
                             m_ctb00g03.fvrnom,
                             m_ctb00g03.opgvlr,
                             m_ctb00g03.opgcncflg,
                             m_ctb00g03.opgprcflg,
                             m_ctb00g03.atldat,
                             m_ctb00g03.atlemp,
                             m_ctb00g03.atlmat,
                             m_ctb00g03.atlusrtip,
                             m_ctb00g03.pestip,
                             m_ctb00g03.succod,
                             m_ctb00g03.ramcod,
                             m_ctb00g03.rmemdlcod,
                             m_ctb00g03.aplnumdig,
                             m_ctb00g03.itmnumdig,
                             m_ctb00g03.edsnumref,
                             m_ctb00g03.atdsrvabrdat,
                             m_ctb00g03.opgemsdat)
                   returning ws_sqlcode, l_eventograva
     whenever error stop

     if ws_sqlcode != 0 then
        display 'OCORREU UM ERRO EM ctb00g03_grvprvdsp - SqlCode ',ws_sqlcode
        return sqlca.sqlcode, lr_eventoaju.*
     else
        if l_ciaempcod = 1 then
           #identificando origem do servico
           let l_cmd = " select atdsrvorg from  datmservico ",
                       " where atdsrvnum = ? and atdsrvano = ? "
           prepare pctb00g03030 from l_cmd
           declare cctb00g03030 cursor for pctb00g03030
           
           whenever error continue
           open cctb00g03030 using l_par2.atdsrvnum, l_par2.atdsrvano
           fetch cctb00g03030 into l_atdsrvorg
           whenever error stop
           
           if sqlca.sqlcode < 0 then
              display 'OCORREU UM ERRO EM cctb00g03030 - SqlCode ', sqlca.sqlcode
              return sqlca.sqlcode, lr_eventoaju.*
           end if
           close cctb00g03030
           
           if l_atdsrvorg = 9 
              then
              if m_ctb00g03.ramcod = 31 or m_ctb00g03.ramcod = 531 
                 then
                 let l_cmd = " select count(*) from  abbmclaus ",
                             " where succod    = ? ",
                             " and aplnumdig = ? ",
                             " and itmnumdig = ? ",
                             " and clscod in ('095','034','035','34A','35A','35R','33','33R')"
                 prepare pctb00g03040 from l_cmd
                 declare cctb00g03040 cursor for pctb00g03040
                 
                 whenever error continue
                 open cctb00g03040 using m_ctb00g03.succod, 
                                         m_ctb00g03.aplnumdig, 
                                         m_ctb00g03.itmnumdig
                 fetch cctb00g03040 into l_contaclaus
                 whenever error stop
                 
                 if sqlca.sqlcode < 0 then
                    display 'OCORREU UM ERRO EM cctb00g03040 - SqlCode ', sqlca.sqlcode
                    return sqlca.sqlcode, lr_eventoaju.*
                 end if
                 close cctb00g03040
                 
                 if l_contaclaus is not null and l_contaclaus <> 0 
                    then
                    if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 
                       then
                       let lr_evento_ajuste = "25.117"
                    else
                       let lr_evento_ajuste = "25.102"
                    end if
                 else
                    let lr_evento_ajuste = "25.110"
                 end if
              else
                 if m_ctb00g03.ramcod = 993  or
                    m_ctb00g03.ramcod = 991  or
                    m_ctb00g03.ramcod = 1391 or
                    m_ctb00g03.ramcod = 1329 or
                    m_ctb00g03.ramcod = 980 
                    then
                    if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                       let lr_evento_ajuste = "25.117"
                    else
                       let lr_evento_ajuste = "25.109"
                    end if
                 end if
              end if
           end if
           
           if l_atdsrvorg = 13 then
              if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                 let lr_evento_ajuste = "25.117"
              else
                 let lr_evento_ajuste = "25.109"
              end if
           end if
           
           if l_atdsrvorg = 8 then
              let l_cmd = " select avialgmtv from  datmavisrent where atdsrvnum = ? and atdsrvano = ? "
              prepare pctb00g03090 from l_cmd
              declare cctb00g03090 cursor for pctb00g03090
              
              whenever error continue
              open cctb00g03090 using l_par2.atdsrvnum, l_par2.atdsrvano
              fetch cctb00g03090 into l_motivo
              whenever error stop
              
              if sqlca.sqlcode < 0 then
                 display 'OCORREU UM ERRO EM cctb00g03090 - SqlCode ', sqlca.sqlcode
                 return sqlca.sqlcode, lr_eventoaju.*
              end if
              close cctb00g03090
              
              if l_motivo = 1 then
                 if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                    let lr_evento_ajuste = "25.117"
                 else
                    let lr_evento_ajuste = "25.106"
                 end if
              end if
              
              if l_motivo = 2 then
                 if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                    let lr_evento_ajuste = "25.117"
                 else
                    let lr_evento_ajuste = "25.104"
                 end if
              end if
              
              if l_motivo = 3 then
                 if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                    let lr_evento_ajuste = "25.117"
                 else
                    let lr_evento_ajuste = "25.112"
                 end if
              end if
              
              if l_motivo = 4 then
                 let lr_evento_ajuste = "25.106"
              end if
              
              if l_motivo = 5 then
                 let lr_evento_ajuste = "25.104"
              end if
              
              if l_motivo = 6 then
                 let lr_evento_ajuste = "25.112"
              end if
           end if

           if l_atdsrvorg = 2 or
              l_atdsrvorg = 3 or
              l_atdsrvorg = 6 
              then
              if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                 let lr_evento_ajuste = "25.117"
              else
                 let lr_evento_ajuste = "25.105"
              end if
           end if
           
           if l_atdsrvorg = 4 or
              l_atdsrvorg = 5 then
              if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                 let lr_evento_ajuste = "25.103"
              else
                 let lr_evento_ajuste = "25.117"
              end if
           end if
           
           if l_atdsrvorg = 1 then
              let  l_lignum = cts20g00_servico(l_par2.atdsrvnum,
                                               l_par2.atdsrvano)
              let l_cmd = " select ligcvntip from datmligacao where lignum = ? ",
                          " and atdsrvnum = ? and atdsrvano = ? "
              prepare pctb00g03110 from l_cmd
              declare cctb00g03110 cursor for pctb00g03110
              
              whenever error continue
              open cctb00g03110 using l_lignum, l_par2.atdsrvnum, 
                                      l_par2.atdsrvano
              fetch cctb00g03110 into l_ligcvntip
              whenever error stop
              
              if sqlca.sqlcode < 0 then
                 display 'OCORREU UM ERRO EM cctb00g03110 - SqlCode ', 
                         sqlca.sqlcode
                 return sqlca.sqlcode, lr_eventoaju.*
              end if
              close cctb00g03110
               
              if l_ligcvntip = 80 or
                 l_ligcvntip = 85 or
                 l_ligcvntip = 89 or
                 l_ligcvntip = 90 or
                 l_ligcvntip = 91 or
                 l_ligcvntip = 92
                 then
                 if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                    let lr_evento_ajuste = "25.117"
                 else
                    let lr_evento_ajuste = "25.103"
                 end if
              else
                 if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
                    let lr_evento_ajuste = "25.117"
                 else
                    let lr_evento_ajuste = "25.105"
                 end if
              end if
           end if
        else
           let lr_evento_baixa = "25.123"
        end if

        #Carregando parametros para envio a camada PeopleGL
        #evento
        let lr_evento.evento = lr_evento_ajuste

        #Empresa
        let l_cmd = "select empcod from  datmservico where atdsrvnum = ? and atdsrvano = ?"
        prepare pctb00g03600 from l_cmd
        declare cctb00g03600 cursor for pctb00g03600
        
        whenever error continue
        open cctb00g03600 using l_par2.atdsrvnum, l_par2.atdsrvano
        fetch cctb00g03600 into ws.empresa
        whenever error stop
        
        if sqlca.sqlcode <> 0 then
           error "Erro ao selecionar empresa cctb00g03020:, ", sqlca.sqlcode, 
                 " = ", sqlca.sqlerrd[2]
        end if
        close cctb00g03600
        
        if ws.empresa is not null then
           let lr_evento.empresa = ws.empresa
        end if
        
        #Data da competencia
        let lr_evento.dt_movto = today
        
        #Chave primaria
        # a chave primaria deste evento e composta por data competencia, evento, 
        # servico, op, data de vencimento, corretor
        let lr_evento.chave_primaria  = m_ctb00g03.atldat,
                                        lr_evento.evento,
                                        l_par2.atdsrvnum,
                                        0,
                                        m_ctb00g03.nfsvncdat,
                                        m_ctb00g03.corsus

        #OP
        let lr_evento.op = m_ctb00g03.opgnum

        #Apolice
        if m_ctb00g03.aplnumdig is null or m_ctb00g03.aplnumdig = 0 then
           let m_ctb00g03.aplnumdig = l_prpnumdig
        else
           let lr_evento.apolice = m_ctb00g03.aplnumdig
        end if
        
        if lr_evento.apolice is null then
           let lr_evento.apolice = 0
        end if

        #Sucursal
        let lr_evento.sucursal = m_ctb00g03.succod

        #Projeto
        let lr_evento.projeto = m_ctb00g03.atdsrvnum

        #Data do Chamado
        let lr_evento.dt_chamado = m_ctb00g03.atdsrvabrdat

        #Favorecido
        if m_ctb00g03.conitfcod = 25 
           then
           ### // Seleciona os dados do laudo de locação //
           whenever error continue
           open cctb00g03017 using l_par2.atdsrvnum,
                                   l_par2.atdsrvano
           fetch cctb00g03017 into l_lcvcod   ,
                                   l_lcvnom,
                                   l_aviestcod,
                                   l_avialgmtv,
                                   l_avioccdat,
                                   l_avivclvlr,
                                   l_aviprvent,
                                   m_ctb00g03.nfsemsdat,
                                   l_avivclcod
           whenever error stop
           
           if sqlca.sqlcode < 0 then
              display 'OCORREU UM ERRO EM cctb00g03017 - SqlCode ',sqlca.sqlcode
              return sqlca.sqlcode, lr_eventoaju.*
           end if
           close cctb00g03017
                
           let lr_evento.fvrcod = l_lcvcod
           let lr_evento.fvrnom = l_lcvnom
           
           call ctx25g05_carac_fon(lr_evento.fvrnom) returning ws.descfvr
           
           if ws.descfvr is not null then
              let lr_evento.fvrnom = ws.descfvr
           end if
        else
           if l_atdsrvorg = 9 or l_atdsrvorg = 13 then
              let l_cmd = " select pstcoddig from  datmsrvacp ",
                          " where atdsrvnum = ? ",
                          " and atdsrvano = ? ",
                          " and atdetpcod = 3 "
           else
              let l_cmd = " select pstcoddig from  datmsrvacp ",
                          " where atdsrvnum = ? ",
                          " and atdsrvano = ? ",
                          " and atdetpcod = 4 "
           end if
           prepare pctb00g03800 from l_cmd
           declare cctb00g03800 cursor for pctb00g03800
           
           whenever error continue
           open cctb00g03800 using l_par2.atdsrvnum, l_par2.atdsrvano
           fetch cctb00g03800 into l_pstcoddig
           whenever error stop
           
           if sqlca.sqlcode < 0 then
              display 'OCORREU UM ERRO EM cctb00g03800 - SqlCode ', sqlca.sqlcode
              return sqlca.sqlcode, lr_eventoaju.*
           end if
           close cctb00g03800
           
           if l_pstcoddig is not null then
              let lr_evento.fvrcod = l_pstcoddig
              let l_cmd = " select socfavnom from  dpaksocorfav ",
                          " where pstcoddig = ? "
              prepare pctb00g03900 from l_cmd
              declare cctb00g03900 cursor for pctb00g03900
              
              whenever error continue
              open cctb00g03900 using l_pstcoddig
              fetch cctb00g03900 into l_fvrnom
              whenever error stop
              
              if sqlca.sqlcode < 0 then
                 display 'OCORREU UM ERRO EM cctb00g03900 - SqlCode ', sqlca.sqlcode
                 return sqlca.sqlcode, lr_eventoaju.*
              end if
              close cctb00g03900
              
              call ctx25g05_carac_fon(l_fvrnom) returning l_desfvr
              
              if l_desfvr is not null then
                 let lr_evento.fvrnom = l_desfvr
              end if
           end if
        end if

        #Nota fiscal
        let lr_evento.nfnum = m_ctb00g03.nfsnum

        #Corretor
        let lr_evento.corsus = m_ctb00g03.corsus

        # Tratando o ramo
        call depara_ramo(m_ctb00g03.ramcod, m_ctb00g03.rmemdlcod)
             returning ws.ramo_novo, ws.modalidade_nova
             
        if ws.ramo_novo <> 0 then
           let m_ctb00g03.ramcod = ws.ramo_novo
           let m_ctb00g03.rmemdlcod = ws.modalidade_nova
        end if
        
        if m_ctb00g03.ramcod = 53 then
           let m_ctb00g03.ramcod = 553
        end if
        
        if m_ctb00g03.ramcod = 31 then
           let m_ctb00g03.ramcod = 531
        end if

        #Centro de custo
        call ctb00g03_ccusto(l_ciaempcod, m_ctb00g03.ramcod, m_ctb00g03.rmemdlcod)
        returning ws.ctbcrtcod
        
        if ws.ctbcrtcod = 0 or ws.ctbcrtcod is null then
           let ws.cctnum = 0
        else
           let ws.cctnum = ws.ctbcrtcod
        end if
        let lr_evento.cctnum = ws.cctnum
        
        #Modalidade
        let lr_evento.modalidade = m_ctb00g03.rmemdlcod
        
        #Ramo
        let lr_evento.ramo = m_ctb00g03.ramcod
        
        #Valor
        let lr_evento.opgvlr = m_ctb00g03.opgvlr
        
        #Data de vencimento
        let lr_evento.dt_vencto = m_ctb00g03.nfsvncdat
        
        if lr_evento.evento is null or lr_evento.evento = 0
           then
           if l_atdsrvorg = 9 then
              let lr_evento.evento = "25.102"
           else
              if l_atdsrvorg = 8 then
                 let lr_evento.evento = "25.106"
              else
                 let lr_evento.evento = "25.103"
              end if
           end if
        end if
        
        call ctb00g03_evento_25(lr_evento.*)
        
        let lr_eventoaju.evento         = lr_evento.evento
        let lr_eventoaju.empresa        = lr_evento.empresa
        let lr_eventoaju.dt_movto       = lr_evento.dt_movto
        let lr_eventoaju.chave_primaria = lr_evento.chave_primaria
        let lr_eventoaju.op             = lr_evento.op
        let lr_eventoaju.apolice        = lr_evento.apolice
        let lr_eventoaju.sucursal       = lr_evento.sucursal
        let lr_eventoaju.projeto        = lr_evento.projeto
        let lr_eventoaju.dt_chamado     = lr_evento.dt_chamado
        let lr_eventoaju.fvrcod         = lr_evento.fvrcod
        let lr_eventoaju.fvrnom         = lr_evento.fvrnom
        let lr_eventoaju.nfnum          = lr_evento.nfnum
        let lr_eventoaju.corsus         = lr_evento.corsus
        let lr_eventoaju.cctnum         = lr_evento.cctnum
        let lr_eventoaju.modalidade     = lr_evento.modalidade
        let lr_eventoaju.ramo           = lr_evento.ramo
        let lr_eventoaju.opgvlr         = lr_evento.opgvlr
        let lr_eventoaju.dt_vencto      = lr_evento.dt_vencto
        let lr_eventoaju.dt_ocorrencia  = lr_evento.dt_chamado
     end if
     
  else
     # Se não encontrou o registro, não faz
     initialize lr_eventoaju.* to null
     return ws_sqlcode, lr_eventoaju.*
  end if
  
  return 0, lr_eventoaju.*

end function