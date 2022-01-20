################################################################################
# Nome do Modulo: BDATR007                                         Marcelo     #
#                                                                  Gilberto    #
# Relacao diaria de inconsistencias nos atendimentos               Mar/1997    #
################################################################################
# Alteracoes:                                                                  #
#                                                                              #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
# 05/05/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti-    #
#                                       ma etapa do servico.                   #
#------------------------------------------------------------------------------#
# 10/08/1999  PSI 9018-1   Wagner       Formatar e enviar relatorios em        #
#                                       WORD e excluir 08-Limite atend.34/35   #
#------------------------------------------------------------------------------#
# 30/08/1999  PSI 9235-5   Wagner       incluir 08-Limite atend.34/35          #
#------------------------------------------------------------------------------#
# 21/09/1999  *Correio*    Wagner       Alteracao no endereco do e_mail        #
#------------------------------------------------------------------------------#
# 11/10/1999  PSI 9427-7   Wagner       excluir itens no relatorio de:         #
#                                       02-Documento vencido                   #
#                                       04-Documento sem clausula contratada   #
#                                       07-Dados do veiculo nao conferem       #
#                                       10-Outra sol.no prazo de 24/48 horas   #
#------------------------------------------------------------------------------#
# 28/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-     #
#                                       coes, com a utilizacao de funcoes.     #
#------------------------------------------------------------------------------#
# 18/02/2000  MUDANCA      Wagner       Alterar envio uuencode para mailx      #
#------------------------------------------------------------------------------#
# 16/06/2000  PSI 10924-0  Wagner       abilitar tratamento para inconsis-     #
#                                       tencia atendimento com proposta.       #
#------------------------------------------------------------------------------#
# 13/07/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo          #
#                                       atdsrvnum de 6 p/ 10.                  #
#                                       Troca do campo atdtip p/ atdsrvorg.    #
#------------------------------------------------------------------------------#
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                           #
#------------------------------------------------------------------------------#
################################################################################
#==============================================================================#
# Alterado : 23/07/2002 - Celso                                                #
#            Utilizacao da funcao fgckc811 para enderecamento de corretores    #
#==============================================================================#
#                  * * *  A L T E R A C O E S  * * *                           #
#                                                                              #
# Data       Autor Fabrica         PSI    Alteracoes                           #
# ---------- --------------------- ------ -------------------------------------#
# 10/09/2005 Helio (Meta)       Melhorias incluida funcao fun_dba_abre_banco.  #
#------------------------------------------------------------------------------#
# 29/09/2006  Alberto           PSI202720 Saude + casa                         #
#------------------------------------------------------------------------------#
# 08/12/2006 Alberto            PSI205206 Nao foi possivel alterar devido ao   #
#                                         agrupamento. Sera necessario defi-   #
#                                         nir novo relatorio.                  #
#------------------------------------------------------------------------------#
# 19/05/2007 Alberto Rodrigues     207446 Desprezar serviços SAF-Assist.Funeral#
#                                         atdsrvorg(origem)18                  #
#------------------------------------------------------------------------------#
# 06/03/2008 Sergio Burini         218545 Incluir função padrao para inclusao  #
#                                         de etapas (cts10g04_insere_etapa()   #
#------------------------------------------------------------------------------#
# 30/04/2008 Norton Nery-Meta    psi221112  Mudanca no nome da tabela gtakram. #
#                                                                              #
#------------------------------------------------------------------------------#
# 25/07/2011 Helder Oliv-Meta          Inclusao de chamada para inconsistencia #
#                                         AZUL e ITAU                          #
################################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

 database porto
globals
   define g_ismqconn smallint
end globals

 define g_traco        char(80)

 define arr_aux        smallint

 define a_inconsist    array[12] of record
    incdsc             char (50),
    quant              smallint
 end record

  define a_inconsist_porto    array[12] of record
    incdsc             char (50),
    quant              smallint
 end record

  define a_inconsist_azul    array[12] of record
    incdsc             char (50),
    quant              smallint
 end record

  define a_inconsist_itau    array[12] of record
    incdsc             char (50),
    quant              smallint
 end record

 define m_totinccod_porto,
        m_totinccod_azul ,
        m_totinccod_itau ,
        m_totsrvcvn_porto,
        m_totsrvcvn_azul ,
        m_totsrvcvn_itau ,
        m_totsrvgrl_porto,
        m_totsrvgrl_azul ,
        m_totsrvgrl_itau  dec (06,00)

 define l_log char(100)
 define l_retorno  smallint

 main

 let l_retorno = 0
   # -> CRIA O ARQUIVO DE LOG DO PROGRAMA
   call bdatr007_cria_log()

   call fun_dba_abre_banco("CT24HS")
   set isolation to dirty read
   set lock mode to wait 10
   call bdatr007()
      returning l_retorno
 end main


#---------------------------------------------------------------
 function bdatr007()
#---------------------------------------------------------------

  define r_gcakfilial    record
         endlgd          like gcakfilial.endlgd
        ,endnum          like gcakfilial.endnum
        ,endcmp          like gcakfilial.endcmp
        ,endbrr          like gcakfilial.endbrr
        ,endcid          like gcakfilial.endcid
        ,endcep          like gcakfilial.endcep
        ,endcepcmp       like gcakfilial.endcepcmp
        ,endufd          like gcakfilial.endufd
        ,dddcod          like gcakfilial.dddcod
        ,teltxt          like gcakfilial.teltxt
        ,dddfax          like gcakfilial.dddfax
        ,factxt          like gcakfilial.factxt
        ,maides          like gcakfilial.maides
        ,crrdstcod       like gcaksusep.crrdstcod
        ,crrdstnum       like gcaksusep.crrdstnum
        ,crrdstsuc       like gcaksusep.crrdstsuc
        ,status          smallint
  end record

 define d_bdatr007   record
    ligcvntip        like datmligacao.ligcvntip ,
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    c24astcod        like datmligacao.c24astcod ,
    nom              like datmservico.nom       ,
    vcldes           like datmservico.vcldes    ,
    vclanomdl        like datmservico.vclanomdl ,
    vcllicnum        like datmservico.vcllicnum ,
    atdsrvorg        like datmservico.atdsrvorg ,
    atddat           like datmservico.atddat    ,
    atdhor           like datmservico.atdhor    ,
    ciaempcod        like datmservico.ciaempcod ,
    atdetpdes        like datketapa.atdetpdes   ,
    funmat           like isskfunc.funmat       ,
    funnom           like isskfunc.funnom       ,
    ramcod           like datrservapol.ramcod   ,
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    edsnumref        like datrservapol.edsnumref,
    inccod           smallint                   ,
    prporg           like datrligprp.prporg     ,
    prpnumdig        like datrligprp.prpnumdig  ,
    ofnnumdig        like sgokofi.ofnnumdig     ,
    nomrazsoc        like gkpkpos.nomrazsoc
 end record

 define ws           record
    hora             char (08)                  ,
    hoje             date                       ,
    agora            char (05)                  ,
    auxdat           char (10)                  ,
    excflg           smallint                   ,
    qtdatd           smallint                   ,
    clscod           like abbmclaus.clscod      ,
    corsus           like gcaksusep.corsus      ,
    cornom           like gcakcorr.cornom       ,
    dddcod           like gcakfilial.dddcod     ,
    factxt           like gcakfilial.factxt     ,
    pgrnum           like htlrust.pgrnum        ,
    atddat           like datmservico.atddat    ,
    lignum           like datmligacao.lignum    ,
    ligdat           like datmligacao.ligdat    ,
    atddatprg        like datmservico.atddatprg ,
    c24txtseq        like datmservhist.c24txtseq,
    c24srvdsc        like datmservhist.c24srvdsc,
    dirfisnom        like ibpkdirlog.dirfisnom  ,
    sgrorg           like rsamseguro.sgrorg     ,
    sgrnumdig        like rsamseguro.sgrnumdig  ,
    atdsrvseq        like datmsrvacp.atdsrvseq  ,
    atdetpcod        like datmsrvacp.atdetpcod  ,
    comando          char (400)                 ,
    pathrel01_porto  char (65)                  ,
    pathrel01_azul   char (65)                  ,
    pathrel01_itau   char (65)                  ,
    path_atd         char (65)                  ,
    ciaempcod        like datmservico.ciaempcod
 end record

 define erros        record
    x1               smallint,
    x2               smallint,
    x3               smallint,
    x4               smallint,
    x5               smallint,
    x6               smallint,
    x7               smallint,
    x8               smallint,
    x9               smallint,
    x10              smallint,
    x11              smallint,
    x12              smallint
 end record

 define a_bdatr007   array[12] of record
    inccod           smallint
 end record

 define sql_comando  char(400),
        l_assunto    char(300),
        l_erro_envio smallint,
        l_ret        smallint,
        l_mensagem   char(50),
        l_erro       smallint

 define l_retorno1   smallint
 define l_msg        char (500)

 define ml_tpdocto  char(15)

 #--------------------------------------------------------------------
 # Inicializacao das variaveis
 #--------------------------------------------------------------------
 let g_traco = "--------------------------------------------------------------------------------"

 initialize d_bdatr007.*  to null
 initialize ws.*          to null
 initialize g_ppt.*       to null

 let ws.hoje  = today
 let ws.agora = time
 let l_assunto    = null
 let l_erro_envio = null

 let ml_tpdocto  = null
 let l_log = null
 let l_retorno1 = 0
 let l_msg = null
 #--------------------------------------------------------------------
 # Cursor SERVICO x APOLICE
 #--------------------------------------------------------------------
 let sql_comando = " select ramcod, succod, aplnumdig, itmnumdig, edsnumref ",
                   "   from datrservapol        ",
                   "  where atdsrvnum = ?   and ",
                   "        atdsrvano = ?       "
 prepare sel_datrservapol from sql_comando
 declare c_datrservapol cursor for sel_datrservapol

 #--------------------------------------------------------------------
 # Cursor BUSCA ORIGEM/NUMERO DO SEGURO - RAMOS ELEMENTARES
 #--------------------------------------------------------------------
 let sql_comando = "select sgrorg, ",
                   "       sgrnumdig ",
                   "  from rsamseguro",
                   " where succod    = ?",
                   "   and ramcod    = ?",
                   "   and aplnumdig = ? "
 prepare sel_rsamseguro from sql_comando
 declare c_rsamseguro cursor for sel_rsamseguro

 #--------------------------------------------------------------------
 # Cursor LIGACOES DE COMPLEMENTO
 #--------------------------------------------------------------------
 let sql_comando = " select max(ligdat) from datmligacao   ",
                   "  where atdsrvnum = ? and atdsrvano = ?",
                   "    and c24astcod in ('ALT','CAN','REC')"
 prepare sel_datmligacao_max from sql_comando
 declare c_datmligacao_max cursor for sel_datmligacao_max

 #--------------------------------------------------------------------
 # Cursor NOME DO FUNCIONARIO
 #--------------------------------------------------------------------
 let sql_comando = " select funnom from isskfunc ",
                   "  where funmat = ?           "
 prepare sel_isskfunc from sql_comando
 declare c_isskfunc cursor for sel_isskfunc

 #--------------------------------------------------------------------
 # Cursor CORRETOR DA APOLICE - AUTOMOVEL
 #--------------------------------------------------------------------
 let sql_comando = "select corsus from abamcor",
                   " where succod    = ?   and",
                   "       aplnumdig = ?   and",
                   "       corlidflg = 'S'    "
 prepare sel_abamcor from sql_comando
 declare c_abamcor cursor for sel_abamcor

 #--------------------------------------------------------------------
 # Cursor CORRETOR DA APOLICE - RAMOS ELEMENTARES
 #--------------------------------------------------------------------
 let sql_comando = "select corsus ",
                   "  from rsampcorre",
                   " where sgrorg    = ?  ",
                   "   and sgrnumdig = ?  ",
                   "   and corlidflg = 'S' "
 prepare sel_rsampcorre from sql_comando
 declare c_rsampcorre cursor for sel_rsampcorre

 #--------------------------------------------------------------------
 # Cursor NUMERO DO FAX
 #--------------------------------------------------------------------
 let sql_comando = "select cornom ",
                   "  from gcaksusep, gcakcorr ",
                   " where gcaksusep.corsus     = ? ",
                   "   and gcakcorr.corsuspcp   = gcaksusep.corsuspcp "
 prepare sel_gcakcorr from sql_comando
 declare c_gcakcorr cursor for sel_gcakcorr

 #--------------------------------------------------------------------
 # Cursor NUMERO DO PAGER
 #--------------------------------------------------------------------
 let sql_comando = "select pgrnum from htlrust",
                   " where corsus = ?      and",
                   "       ustsit = 'A'       "
 prepare sel_htlrust from sql_comando
 declare c_htlrust cursor for sel_htlrust

 #--------------------------------------------------------------------
 # Cursor DESCRICAO DOMINIO
 #--------------------------------------------------------------------
 let sql_comando = "select cpodes from datkdominio ",
                   " where cponom = 'ligcvntip' and",
                   "       cpocod = ? "
 prepare sel_datkdominio from sql_comando
 declare c_datkdominio cursor for sel_datkdominio

 #--------------------------------------------------------------------
 # Cursor BUSCA DESCRICAO DO RAMO
 #--------------------------------------------------------------------
 let sql_comando = "select ramnom  ",
                   "  from gtakram",
                   " where ramcod = ?",
                   "   and empcod = 1 "
 prepare sel_gtakram from sql_comando
 declare c_gtakram cursor for sel_gtakram

 #--------------------------------------------------------------------
 # Cursor DESCRICAO TIPO SERVICO
 #--------------------------------------------------------------------
 let sql_comando = "select srvtipabvdes",
                   "  from datksrvtip  ",
                   " where atdsrvorg = ?  "
 prepare sel_datksrvtip from sql_comando
 declare c_datksrvtip cursor for sel_datksrvtip

 #--------------------------------------------------------------------
 # Dados da Ligacao
 #--------------------------------------------------------------------
 let sql_comando = "select ligcvntip, ",
                   "       c24astcod  ",
                   "  from datmligacao",
                   " where lignum = ? "
 prepare sel_datmligacao from sql_comando
 declare c_datmligacao cursor for sel_datmligacao

 #--------------------------------------------------------------------
 # Cursores ETAPA
 #--------------------------------------------------------------------
 let sql_comando = "select max(atdsrvseq)",
                   "  from datmsrvacp    ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? "

 prepare sel_datmsrvacp from sql_comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

 let sql_comando = "select atdetpcod ",
                   "  from datmsrvacp",
                   " where atdsrvnum = ?",
                   "   and atdsrvano = ?",
                   "   and atdsrvseq = ?"

 prepare sel_srvultetp from sql_comando
 declare c_srvultetp cursor for sel_srvultetp

 let sql_comando = "select atdetpdes ",
                   "  from datketapa ",
                   " where atdetpcod = ?"

 prepare sel_datketapa from sql_comando
 declare c_datketapa cursor for sel_datketapa

 #--------------------------------------------------------------------
 # Cursor HISTORICO
 #--------------------------------------------------------------------
 let sql_comando = " select max(c24txtseq) ",
                   "   from datmservhist   ",
                   "  where atdsrvnum = ?  ",
                   "    and atdsrvano = ?  "
 prepare sel_datmservhist from sql_comando
 declare c_datmservhist cursor for sel_datmservhist

 let sql_comando = "select ligdat   , lighorinc,",
                   "       c24funmat, c24srvdsc ",
                   "  from datmservhist         ",
                   " where atdsrvnum = ?   and  ",
                   "       atdsrvano = ?        "
 prepare sel_historico from sql_comando
 declare c_historico cursor for sel_historico

 #--------------------------------------------------------------------
 # Cursor PROPOSTA
 #--------------------------------------------------------------------
 let sql_comando = " select prporg, prpnumdig  ",
                   "   from datmligacao, datrligprp ",
                   "  where datmligacao.atdsrvnum = ? ",
                   "    and datmligacao.atdsrvano = ? ",
                   "    and datrligprp.lignum     = datmligacao.lignum "
 prepare sel_datrligprp from sql_comando
 declare c_datrligprp cursor for sel_datrligprp

 #--------------------------------------------------------------------
 # Cursor OFICINA
 #--------------------------------------------------------------------
 let sql_comando = " select ofnnumdig ",
                   "   from datmlcl   ",
                   "  where datmlcl.atdsrvnum = ? ",
                   "    and datmlcl.atdsrvano = ? ",
                   "    and datmlcl.c24endtip = '2' "
 prepare sel_datmlcl from sql_comando
 declare c_datmlcl cursor for sel_datmlcl
 #--------------------------------------------------------------------
 # Cursor NOME OFICINA
 #--------------------------------------------------------------------
 let sql_comando = " select nomrazsoc ",
                   "   from gkpkpos   ",
                   "  where gkpkpos.pstcoddig = ? "
 prepare sel_gkpkpos from sql_comando
 declare c_gkpkpos cursor for sel_gkpkpos
 #--------------------------------------------------------------------
 # Insert HISTORICO
 #--------------------------------------------------------------------
 let sql_comando = " insert into datmservhist",
                   " (atdsrvnum , atdsrvano, ",
                   "  c24txtseq , c24funmat, ",
                   "  c24srvdsc , ligdat   , ",
                   "  lighorinc ) values     ",
                   " (?, ?, ?, ?, ?, ?, ?)   "
 prepare ins_datmservhist from sql_comando

 #--------------------------------------------------------------------
 # Insert ETAPA DE ACOMPANHAMENTO
 #--------------------------------------------------------------------
 let sql_comando = "insert into datmsrvacp  ",
                   "(atdsrvnum, atdsrvano,  ",
                   " atdsrvseq, atdetpcod,  ",
                   " atdetpdat, atdetphor,  ",
                   " empcod   , funmat   )  ",
                   "values (?,?,?,6,?,?,?,?)"
 prepare ins_datmsrvacp from sql_comando

 #--------------------------------------------------------------------
 # Update EXCLUSAO DO SERVICO
 #--------------------------------------------------------------------
 let sql_comando = " update datmservico set",
                   " (cnldat, atdfnlhor, c24opemat, atdfnlflg) = (?,?,?,?) ",
                   "  where atdsrvnum = ? and atdsrvano = ? "
 prepare upd_datmservico  from sql_comando

 #--------------------------------------------------------------------
 # Define data parametro
 #--------------------------------------------------------------------
 let ws.auxdat = arg_val(1)

 if ws.auxdat is null       or
    ws.auxdat =  "  "       then
    if time >= "17:00"  and
       time <= "23:59"  then
       let ws.auxdat = today
    else
       let ws.auxdat = today - 1
    end if
 else
    if ws.auxdat > today       or
       length(ws.auxdat) < 10  then
       let l_msg = "  *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       #exit program
       call bdatr007_envia_email_erro("AVISO DE ERRO BATCH - bdatr007 ",l_msg)
       let l_retorno1 = 1
       return l_retorno1
    end if
 end if

 let ws.atddat = ws.auxdat
 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom


 let ws.pathrel01_porto  = ws.dirfisnom clipped, "/RDAT00701.rtf"
 let ws.pathrel01_azul   = ws.dirfisnom clipped, "/RDAT00735.rtf"
 let ws.pathrel01_itau   = ws.dirfisnom clipped, "/RDAT00784.rtf"
 let ws.path_atd         = ws.dirfisnom clipped, "/RDAT00702.rtf"

 #--------------------------------------------------------------------
 # Cursor principal - VERIFICACAO SERVICOS DIARIOS
 #--------------------------------------------------------------------
 declare  c_bdatr007a  cursor for
     select datmservico.atdsrvnum,
            datmservico.atdsrvano,
            datmservico.atdsrvorg,
            datmservico.nom      ,
            datmservico.vcldes   ,
            datmservico.vclanomdl,
            datmservico.vcllicnum,
            datmservico.funmat   ,
            datmservico.atddat   ,
            datmservico.atdhor   ,
            datmservico.ciaempcod
       from datmservico
      where datmservico.atddat = ws.atddat

     start report rep_inconsist_porto to ws.pathrel01_porto
     start report rep_inconsist_azul  to ws.pathrel01_azul
     start report rep_inconsist_itau  to ws.pathrel01_itau

     start report rep_qtdatend  to ws.path_atd

 foreach c_bdatr007a into d_bdatr007.atdsrvnum,
                          d_bdatr007.atdsrvano,
                          d_bdatr007.atdsrvorg,
                          d_bdatr007.nom      ,
                          d_bdatr007.vcldes   ,
                          d_bdatr007.vclanomdl,
                          d_bdatr007.vcllicnum,
                          d_bdatr007.funmat   ,
                          d_bdatr007.atddat   ,
                          d_bdatr007.atdhor   ,
                          d_bdatr007.ciaempcod

    let l_log = "Servico ", d_bdatr007.atdsrvnum clipped, "/",d_bdatr007.atdsrvano clipped, " Origem ", d_bdatr007.atdsrvorg
    call errorlog(l_log)

    if d_bdatr007.atdsrvorg = 10  or     # Tipo atend.10 = VISTORIA nao tratar
       d_bdatr007.atdsrvorg = 15  or     # Tipo atend.15 = JIT nao tratar
       d_bdatr007.atdsrvorg = 18  then   # Funeral nao tratar
       continue foreach
    end if

    ## psi202720
    ## Verifica Tipo de Documento ("APOLICE", "SAUDE", "PROPOSTA", "CONTRATO", "SEMDOCTO" )
    let ml_tpdocto = null
    let ml_tpdocto = cts20g11_identifica_tpdocto(d_bdatr007.atdsrvnum, d_bdatr007.atdsrvano)

    if ml_tpdocto = "SAUDE" then
       continue foreach
    end if
    ## psi202720

    initialize d_bdatr007.succod   ,
               d_bdatr007.aplnumdig,
               d_bdatr007.itmnumdig to null

    open  c_datrservapol using d_bdatr007.atdsrvnum,
                               d_bdatr007.atdsrvano
    fetch c_datrservapol into  d_bdatr007.ramcod   ,
                               d_bdatr007.succod   ,
                               d_bdatr007.aplnumdig,
                               d_bdatr007.itmnumdig,
                               d_bdatr007.edsnumref
    close c_datrservapol

    let ws.lignum = cts20g00_servico(d_bdatr007.atdsrvnum, d_bdatr007.atdsrvano)

    let l_log = "Ligacao ", ws.lignum clipped
    call errorlog(l_log)

    open  c_datmligacao using ws.lignum
    fetch c_datmligacao into  d_bdatr007.ligcvntip,
                              d_bdatr007.c24astcod
    close c_datmligacao

    case
       when d_bdatr007.ciaempcod = 35
            #AZUL
            call cts01g00_azul (d_bdatr007.ramcod   ,
                                d_bdatr007.succod   ,
                                d_bdatr007.aplnumdig,
                                d_bdatr007.itmnumdig,
                                d_bdatr007.edsnumref,
                                d_bdatr007.c24astcod,
                                d_bdatr007.atdsrvorg,
                                d_bdatr007.vcldes   ,
                                d_bdatr007.vclanomdl,
                                d_bdatr007.vcllicnum,
                                d_bdatr007.atdsrvnum,
                                d_bdatr007.atdsrvano,
                                d_bdatr007.atddat   ,
                                "R")
                returning erros.*


       when d_bdatr007.ciaempcod = 84
            #ITAU
            call cts01g00_itau (d_bdatr007.ramcod   ,
                                d_bdatr007.succod   ,
                                d_bdatr007.aplnumdig,
                                d_bdatr007.itmnumdig,
                                d_bdatr007.edsnumref,
                                d_bdatr007.c24astcod,
                                d_bdatr007.atdsrvorg,
                                d_bdatr007.vcldes   ,
                                d_bdatr007.vclanomdl,
                                d_bdatr007.vcllicnum,
                                d_bdatr007.atdsrvnum,
                                d_bdatr007.atdsrvano,
                                d_bdatr007.atddat   ,
                                "R")
                returning erros.*

       otherwise
            #PORTO
            call cts01g00 (d_bdatr007.ramcod   ,
                           d_bdatr007.succod   ,
                           d_bdatr007.aplnumdig,
                           d_bdatr007.itmnumdig,
                           d_bdatr007.c24astcod,
                           d_bdatr007.atdsrvorg,
                           d_bdatr007.vcldes   ,
                           d_bdatr007.vclanomdl,
                           d_bdatr007.vcllicnum,
                           d_bdatr007.atdsrvnum,
                           d_bdatr007.atdsrvano,
                           d_bdatr007.atddat   ,
                           "R")
                returning erros.*, ws.qtdatd, ws.clscod

    end case

    let a_bdatr007[01].inccod = erros.x1
    let a_bdatr007[02].inccod = erros.x2
    let a_bdatr007[03].inccod = erros.x3
    let a_bdatr007[04].inccod = erros.x4
    let a_bdatr007[05].inccod = erros.x5
    let a_bdatr007[06].inccod = erros.x6
    let a_bdatr007[07].inccod = erros.x7
    let a_bdatr007[08].inccod = erros.x8
    let a_bdatr007[09].inccod = erros.x9
    let a_bdatr007[10].inccod = erros.x10
    let a_bdatr007[11].inccod = erros.x11
    let a_bdatr007[12].inccod = erros.x12

    open  c_datmsrvacp using d_bdatr007.atdsrvnum,
                             d_bdatr007.atdsrvano
    fetch c_datmsrvacp into  ws.atdsrvseq
    close c_datmsrvacp

    open  c_srvultetp  using d_bdatr007.atdsrvnum,
                             d_bdatr007.atdsrvano,
                             ws.atdsrvseq
    fetch c_srvultetp  into  ws.atdetpcod
    close c_srvultetp

    if a_bdatr007[1].inccod is not null  then
       let d_bdatr007.atdetpdes = "NAO CADASTRADA"

       open  c_datketapa using ws.atdetpcod
       fetch c_datketapa into  d_bdatr007.atdetpdes
       close c_datketapa

       let d_bdatr007.funnom = "** NAO CADASTRADO **"

       open  c_isskfunc using d_bdatr007.funmat
       fetch c_isskfunc into  d_bdatr007.funnom
       close c_isskfunc
    end if

    for arr_aux = 1 to 12
       let l_log = "Inconsistencia ", a_bdatr007[arr_aux].inccod clipped
       call errorlog(l_log)

       if a_bdatr007[arr_aux].inccod is not null  then
          case a_bdatr007[arr_aux].inccod
             when  2
                # Psi 9427-7 nao listar inconsist.(02) RDAT007-01 e RDAT007-02
             when  4
                # Psi 9427-7 nao listar inconsist.(04) RDAT007-01 e RDAT007-02
             when  7
                # Psi 9427-7 nao listar inconsist.(07) RDAT007-01 e RDAT007-02
             when  8
                # Psi 9235-5 nao listar inconsist.(08) somente no RDAT007-02
             when 10
                # Psi 9427-7 nao listar inconsist.(10) RDAT007-01 e RDAT007-02
             otherwise
                let d_bdatr007.inccod = a_bdatr007[arr_aux].inccod
                initialize d_bdatr007.prporg, d_bdatr007.prpnumdig to null
                if d_bdatr007.inccod = 11 then
                   open  c_datrligprp  using d_bdatr007.atdsrvnum,
                                             d_bdatr007.atdsrvano
                   fetch c_datrligprp  into  d_bdatr007.prporg,
                                             d_bdatr007.prpnumdig
                   close c_datrligprp
                   let l_log = "Proposta ", d_bdatr007.prpnumdig clipped ,"/" , d_bdatr007.prporg clipped
                   call errorlog(l_log)

                end if
                if d_bdatr007.inccod = 12 then
                   initialize d_bdatr007.ofnnumdig, d_bdatr007.nomrazsoc to null
                   open c_datmlcl using d_bdatr007.atdsrvnum,
                                        d_bdatr007.atdsrvano
                   fetch c_datmlcl into d_bdatr007.ofnnumdig
                   close c_datmlcl

                   open c_gkpkpos using d_bdatr007.ofnnumdig
                   fetch c_gkpkpos into d_bdatr007.nomrazsoc
                   close c_gkpkpos
                end if


                case
                  when d_bdatr007.ciaempcod = 35
                       output to report rep_inconsist_azul(ws.atddat, d_bdatr007.*)

                  when d_bdatr007.ciaempcod = 84
                       output to report rep_inconsist_itau(ws.atddat, d_bdatr007.*)

                  otherwise
                       output to report rep_inconsist_porto(ws.atddat, d_bdatr007.*)
                end case

          end case
       else
          exit for
       end if
    end for

    if ws.atdetpcod = 3  or
       ws.atdetpcod = 4  then
    else
       continue foreach
    end if

    if ws.qtdatd is not null  then
       initialize ws.sgrorg     to null
       initialize ws.sgrnumdig  to null
       initialize ws.corsus     to null
       initialize ws.cornom     to null
       initialize ws.dddcod     to null
       initialize ws.factxt     to null
       initialize ws.pgrnum     to null

       if d_bdatr007.ramcod  =  31  or
          d_bdatr007.ramcod  = 531  then
          open  c_abamcor  using d_bdatr007.succod, d_bdatr007.aplnumdig
          fetch c_abamcor  into  ws.corsus
          close c_abamcor
       else
          open  c_rsamseguro  using d_bdatr007.succod,
                                    d_bdatr007.ramcod,
                                    d_bdatr007.aplnumdig
          fetch c_rsamseguro  into  ws.sgrorg,
                                    ws.sgrnumdig
          close c_rsamseguro

          if ws.sgrorg     is not null   and
             ws.sgrnumdig  is not null   then
             open  c_rsampcorre  using ws.sgrorg,
                                       ws.sgrnumdig
             fetch c_rsampcorre  into  ws.corsus
             close c_rsampcorre
          end if
       end if

       if ws.corsus is not null  then
          open  c_gcakcorr using ws.corsus
          fetch c_gcakcorr into  ws.cornom
          close c_gcakcorr

          #---> Utilizacao da nova funcao de comissoes p/ enderecamento
          initialize r_gcakfilial.* to null
          call fgckc811(ws.corsus)
               returning r_gcakfilial.*
          let ws.dddcod = r_gcakfilial.dddcod
          let ws.factxt = r_gcakfilial.factxt
          #------------------------------------------------------------

          open  c_htlrust  using ws.corsus
          fetch c_htlrust  into  ws.pgrnum
          close c_htlrust

          output to report
                       rep_qtdatend(ws.atddat           , d_bdatr007.ligcvntip,
                                    d_bdatr007.atdsrvorg, d_bdatr007.atdsrvnum,
                                    d_bdatr007.atdsrvano, d_bdatr007.nom      ,
                                    d_bdatr007.vcldes   , d_bdatr007.vclanomdl,
                                    d_bdatr007.vcllicnum, d_bdatr007.ramcod   ,
                                    d_bdatr007.succod   , d_bdatr007.aplnumdig,
                                    d_bdatr007.itmnumdig, ws.corsus           ,
                                    ws.cornom           , ws.dddcod           ,
                                    ws.factxt           , ws.pgrnum           ,
                                    ws.clscod           , ws.qtdatd           )

       end if
    end if
 end foreach

 finish report rep_inconsist_porto
 finish report rep_inconsist_azul
 finish report rep_inconsist_itau
 finish report rep_qtdatend

#--> PORTO
 let l_assunto    = "Inconsistencias Porto de ", ws.atddat, " DAT00701"
 let l_erro_envio = ctx22g00_envia_email("BDATR007",
                                         l_assunto,
                                         ws.pathrel01_porto)

 if l_erro_envio <> 0 then
    if l_erro_envio <> 99 then
       display "Erro ao enviar email(ctx22g00) - ", ws.pathrel01_porto
    else
       display "Nao existe email cadastrado para o modulo - BDATR007"
    end if
 end if

#--> AZUL
 let l_assunto    = "Inconsistencias Azul de ", ws.atddat, " DAT00735"
 let l_erro_envio = ctx22g00_envia_email("BDATR007",
                                         l_assunto,
                                         ws.pathrel01_azul)

 if l_erro_envio <> 0 then
    if l_erro_envio <> 99 then
       display "Erro ao enviar email(ctx22g00) - ", ws.pathrel01_azul
    else
       display "Nao existe email cadastrado para o modulo - BDATR007"
    end if
 end if

#--> ITAU
 let l_assunto    = "Inconsistencias Itau de ", ws.atddat, " DAT00784"
 let l_erro_envio = ctx22g00_envia_email("BDATR007",
                                         l_assunto,
                                         ws.pathrel01_itau)

 if l_erro_envio <> 0 then
    if l_erro_envio <> 99 then
       display "Erro ao enviar email(ctx22g00) - ",ws.pathrel01_itau
    else
       display "Nao existe email cadastrado para o modulo - BDATR007"
    end if
 end if

#--> atendimento por ramo
 let l_assunto    = "Atendimento por Ramo de ", ws.atddat, " DAT00702"
 let l_erro_envio = ctx22g00_envia_email("BDATR007",
                                         l_assunto,
                                         ws.path_atd)

 if l_erro_envio <> 0 then
    if l_erro_envio <> 99 then
       display "Erro ao enviar email(ctx22g00) - ", ws.path_atd
    else
       display "Nao existe email cadastrado para o modulo - BDATR007"
    end if
 end if

 #--------------------------------------------------------------------
 # Cursor EXCLUSAO DE SERVICOS NAO LIBERADOS
 #--------------------------------------------------------------------
 declare  c_bdatr007b  cursor with hold for
     select datmservico.atdsrvnum, datmservico.atdsrvano,
            datmservico.atdsrvorg, datmservico.atddat   ,
            datmservico.atdhor   , datmservico.atddatprg,
            datmservico.ciaempcod
       from datmservico
      where datmservico.atdfnlflg = "N"

 foreach c_bdatr007b into d_bdatr007.atdsrvnum, d_bdatr007.atdsrvano,
                          d_bdatr007.atdsrvorg, d_bdatr007.atddat   ,
                          d_bdatr007.atdhor   , ws.atddatprg        ,
                          ws.ciaempcod

 ## Funeral d_bdatr007.atdsrvorg = definida pelo porto socorro

    let ws.excflg = FALSE

    --[ desprezar os servicos de cartao de credito(empresa 40) ]--
    --[ solicitado por Richard(porto socorro) em 06/12/07. ]--
    if ws.ciaempcod = 40 then
       continue foreach
    end if

    if (d_bdatr007.atdsrvorg =  4   or
        d_bdatr007.atdsrvorg =  6   or
        d_bdatr007.atdsrvorg =  1   or
        d_bdatr007.atdsrvorg =  7   or
        d_bdatr007.atdsrvorg = 17   or
        d_bdatr007.atdsrvorg =  9   or
        d_bdatr007.atdsrvorg = 13   or
        d_bdatr007.atdsrvorg =  2   or
        d_bdatr007.atdsrvorg =  3 ) and
        d_bdatr007.atddat < ws.atddat - 7 units day  then
       open  c_datmligacao_max using d_bdatr007.atdsrvnum, d_bdatr007.atdsrvano
       fetch c_datmligacao_max into  ws.ligdat
       close c_datmligacao_max

       if ws.ligdat is null  then
          let ws.excflg = TRUE
       else
          if ws.ligdat < ws.atddat - 7 units day  then
             let ws.excflg = TRUE
          end if
       end if

       if ws.atddatprg is not null                 and
          ws.atddatprg >  ws.atddat - 7 units day  then
          let ws.excflg = FALSE
       end if
    else
       if d_bdatr007.atdsrvorg =  5                        and
          d_bdatr007.atddat < ws.atddat - 30 units day  then
          open  c_datmligacao_max using d_bdatr007.atdsrvnum, d_bdatr007.atdsrvano
          fetch c_datmligacao_max into  ws.ligdat
          close c_datmligacao_max

          if ws.ligdat is null then
             let ws.excflg = TRUE
          else
             if ws.ligdat < ws.atddat - 30 units day  then
                let ws.excflg = TRUE
             end if
          end if

          if ws.atddatprg is not null                 and
             ws.atddatprg >  ws.atddat - 7 units day  then
             let ws.excflg = FALSE
          end if
       end if
    end if

    if ws.excflg = TRUE  then
       BEGIN WORK

       execute upd_datmservico using ws.hoje, ws.agora   ,
                                     "05048", "S"        ,
                                     d_bdatr007.atdsrvnum,
                                     d_bdatr007.atdsrvano

       if sqlca.sqlcode <> 0  then
          display "Erro (", sqlca.sqlcode, ") no acionamento do servico pelo sistema. AVISE A INFORMATICA!"
          rollback work
       end if

       # 218545 - Burini
       call cts10g04_insere_etapa(d_bdatr007.atdsrvnum,
                                  d_bdatr007.atdsrvano,
                                  6,
                                  "",
                                  "",
                                  "",
                                  "")
            returning l_erro


       if l_erro <> 0  then
          display "Erro (", l_erro, ") no gravacao da etapa de exclusao. AVISE A INFORMATICA!"
          rollback work
       end if

       #BURINI# open  c_datmservhist using d_bdatr007.atdsrvnum, d_bdatr007.atdsrvano
       #BURINI# fetch c_datmservhist into  ws.c24txtseq
       #BURINI# close c_datmservhist
       #BURINI#
       #BURINI# if ws.c24txtseq is null  then
       #BURINI#    let ws.c24txtseq = 0
       #BURINI# end if
       #BURINI#
       #BURINI# let ws.c24txtseq = ws.c24txtseq + 1
       #BURINI#
       #BURINI# execute ins_datmservhist using d_bdatr007.atdsrvnum ,
       #BURINI#                                d_bdatr007.atdsrvano ,
       #BURINI#                                ws.c24txtseq, "5048" ,
       #BURINI#                                ws.c24srvdsc, ws.hoje,
       #BURINI#                                ws.agora
       #BURINI#
       #BURINI# if sqlca.sqlcode <> 0  then
       #BURINI#    display "Erro (", sqlca.sqlcode, ") na inclusao automatica do historico. AVISE A INFORMATICA!"
       #BURINI#    rollback work
       #BURINI# end if

       call ctd07g01_ins_datmservhist(d_bdatr007.atdsrvnum,
                                      d_bdatr007.atdsrvano ,
                                      "5048",
                                      ws.c24srvdsc,
                                      ws.hoje,
                                      ws.agora,
                                      '1',
       				      'F')
            returning l_ret,
                      l_mensagem


       if  l_ret <> 1 then
           display l_mensagem, " - BDATR007 - AVISE A INFORMATICA!"
           rollback work
       else
          call cts00g07_apos_grvlaudo(d_bdatr007.atdsrvnum,d_bdatr007.atdsrvano)
           commit work
       end if

    end if

    initialize ws.ligdat to null
 end foreach

return l_retorno1
end function  ###  bdatr007


#----------------------------------------------------------------------------#
 report rep_inconsist_porto(param_data, r_bdatr007)
#----------------------------------------------------------------------------#

 define param_data   date

 define r_bdatr007   record
    ligcvntip        like datmligacao.ligcvntip ,
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    c24astcod        like datmligacao.c24astcod ,
    nom              like datmservico.nom       ,
    vcldes           like datmservico.vcldes    ,
    vclanomdl        like datmservico.vclanomdl ,
    vcllicnum        like datmservico.vcllicnum ,
    atdsrvorg        like datmservico.atdsrvorg ,
    atddat           like datmservico.atddat    ,
    atdhor           like datmservico.atdhor    ,
    ciaempcod        like datmservico.ciaempcod ,
    atdetpdes        char (10)                  ,
    funmat           like isskfunc.funmat       ,
    funnom           like isskfunc.funnom       ,
    ramcod           like datrservapol.ramcod   ,
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    edsnumref        like datrservapol.edsnumref,
    inccod           smallint                   ,
    prporg           like datrligprp.prporg     ,
    prpnumdig        like datrligprp.prpnumdig  ,
    ofnnumdig        like sgokofi.ofnnumdig     ,
    nomrazsoc        like gkpkpos.nomrazsoc
 end record

 define h_bdatr007   record
    c24txtseq        like datmservhist.c24txtseq,
    c24srvdsc        like datmservhist.c24srvdsc,
    c24funmat        like datmservhist.c24funmat,
    ligdat           like datmservhist.ligdat   ,
    lighorinc        like datmservhist.lighorinc
 end record

 define ws           record
    ligcvndes        char (025)  ,
    incdsc           char (050)  ,
    totsrvcvn        dec (06,00) ,
    totinccod        dec (06,00) ,
    totsrvgrl        dec (06,00) ,
    funnom           like isskfunc.funnom       ,
    c24srvdsc        like datmservhist.c24srvdsc,
    ligdat           like datmservhist.ligdat   ,
    lighorinc        like datmservhist.lighorinc,
    atdsrvnum        like datmservico.atdsrvnum ,
    srvtipabvdes     like datksrvtip.srvtipabvdes
 end record

 define flag_inccod     smallint
 define flag_inccod_porto     smallint
 define flag_inccod_azul     smallint
 define flag_inccod_itau     smallint
 define flag_hist       smallint

   output
      left   margin  000
      top    margin  000
      bottom margin  000

   order by  r_bdatr007.ligcvntip,
             r_bdatr007.inccod   ,
             r_bdatr007.atdsrvano,
             r_bdatr007.atdsrvnum

   format
      first page header
           for arr_aux = 1  to  12
              let a_inconsist[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist[arr_aux].incdsc #geral

              let a_inconsist_porto[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist_porto[arr_aux].incdsc #porto

              let a_inconsist_azul[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist_azul[arr_aux].incdsc #azul

              let a_inconsist_itau[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist_itau[arr_aux].incdsc #itau
           end for

           let ws.totsrvgrl = 0
           let m_totsrvgrl_porto = 0
           let m_totsrvgrl_azul  = 0
           let m_totsrvgrl_itau  = 0

           print column 072, "DAT007-01"
           print column 062, "DATA   : ", today
           print column 007, "INCONSISTENCIAS NOS ATENDIMENTOS DA PORTO DE ", param_data,
                 column 062, "HORA   :   ", time
           skip 1 lines

      before group of r_bdatr007.ligcvntip
           let ws.totsrvcvn = 0
           let m_totsrvcvn_porto = 0
           let m_totsrvcvn_azul = 0
           let m_totsrvcvn_itau = 0

           let ws.ligcvndes = "** NAO CADASTRADO **"

           open  c_datkdominio using r_bdatr007.ligcvntip
           fetch c_datkdominio into  ws.ligcvndes
           close c_datkdominio

           print column 001, "CONVENIO: ", r_bdatr007.ligcvntip  using "<<<&" clipped, " - ", ws.ligcvndes
           print column 001, g_traco
           skip 1 line

      after  group of r_bdatr007.ligcvntip
           let ws.totsrvgrl = ws.totsrvgrl + ws.totsrvcvn
           let m_totsrvgrl_porto = m_totsrvgrl_porto + m_totsrvcvn_porto
           let m_totsrvgrl_azul = m_totsrvgrl_azul + m_totsrvcvn_azul
           let m_totsrvgrl_itau = m_totsrvgrl_itau + m_totsrvcvn_itau


           skip 1 lines
           print column 001, g_traco
           print column 001, "TOTAL DE ", ws.totsrvcvn using "<<<,<<&",
                             " INCONSISTENCIA(S) DO CONVENIO: ",
                             r_bdatr007.ligcvntip  using "<<<&" clipped,
                             " - ", ws.ligcvndes
           print column 001, g_traco
           skip 2 line


      before group of r_bdatr007.inccod
           let ws.totinccod = 0
           let m_totinccod_porto = 0
           let m_totinccod_azul  = 0
           let m_totinccod_itau  = 0

           call cts01g00_descr(r_bdatr007.inccod) returning ws.incdsc

           if ws.incdsc is null  then
              let ws.incdsc = "*** INCONSISTENCIA NAO PREVISTA! ***"
           end if

           print column 001, "----------------"
           print column 001, "INCONSISTENCIAS: ",ws.incdsc
           print column 001, "----------------"
           skip 1 lines

      after  group of r_bdatr007.inccod
           print column 001, "TOTAL ",ws.incdsc clipped,": ",
                             ws.totinccod using "<<<,<<&"
           print column 001, g_traco
           skip 1 lines

           let flag_inccod = r_bdatr007.inccod
           let a_inconsist[flag_inccod].quant = a_inconsist[flag_inccod].quant + ws.totinccod
          let a_inconsist_porto[flag_inccod].quant = a_inconsist_porto[flag_inccod].quant + m_totinccod_porto
           let a_inconsist_azul[flag_inccod].quant = a_inconsist_azul[flag_inccod].quant + m_totinccod_azul
           let a_inconsist_itau[flag_inccod].quant = a_inconsist_itau[flag_inccod].quant + m_totinccod_itau


      before group of r_bdatr007.atdsrvnum
           let ws.srvtipabvdes = "NAO PREV."

           open  c_datksrvtip using r_bdatr007.atdsrvorg
           fetch c_datksrvtip into  ws.srvtipabvdes
           close c_datksrvtip

           print column 001, "SERVICO.....: ",  r_bdatr007.atdsrvorg
                                                               using "&&",
                                               "/", r_bdatr007.atdsrvnum
                                                               using "&&&&&&&",
                                               "-", r_bdatr007.atdsrvano
                                                               using "&&"
           print column 001, "Tipo Servico :", r_bdatr007.c24astcod,
                                               " - ", ws.srvtipabvdes
           print column 001, "DOCUMENTO...: ";
              if r_bdatr007.succod    is null  and
                 r_bdatr007.aplnumdig is null  and
                 r_bdatr007.itmnumdig is null  then
                 print column 015, "**NAO INFORMADO**"
              else
                 if r_bdatr007.ramcod  =  31   or
                    r_bdatr007.ramcod  = 531   then
                    print column 015, r_bdatr007.ramcod     using "###&"      ,
                                 "/", r_bdatr007.succod     using "&&"        ,
                                 "/", r_bdatr007.aplnumdig  using "<<<<<<<& &",
                                 "/", r_bdatr007.itmnumdig  using "<<<<<& &"
                 else
                    print column 015, r_bdatr007.ramcod     using "###&"      ,
                                 "/", r_bdatr007.succod     using "&&"        ,
                                 "/", r_bdatr007.aplnumdig  using "<<<<<<<& &"

                 end if
              end if


           let l_log = "Proposta Relatorio ", r_bdatr007.prporg clipped
           call errorlog(l_log)


           if r_bdatr007.prporg is not null then
              print column 001, "Proposta....: ", r_bdatr007.prporg using "&&",
                                                  " ",
                                                  r_bdatr007.prpnumdig using "<<<<<<<<&"
           end if
           print column 001, "Segurado....: ", r_bdatr007.nom
           print column 001, "Veiculo.....: ", r_bdatr007.vcldes
           print column 001, "Ano.........: ", r_bdatr007.vclanomdl
           print column 001, "Placa.......: ", r_bdatr007.vcllicnum
           print column 001, "Etapa.......: ", r_bdatr007.atdetpdes
           print column 001, "Atendente...: ", r_bdatr007.funmat using "&&&&&&",
                                               " - ", upshift(r_bdatr007.funnom)
           print column 001, "Data/Hora...: ", r_bdatr007.atddat,
                                               " ", r_bdatr007.atdhor
           print column 001, "Oficina.....: ", r_bdatr007.ofnnumdig,
                                               " ", r_bdatr007.nomrazsoc


      after  group of r_bdatr007.atdsrvnum
           let flag_hist = 0
           print column 001, "Historico...:"

              open    c_historico using r_bdatr007.atdsrvnum,
                                        r_bdatr007.atdsrvano
              foreach c_historico into  h_bdatr007.ligdat   ,
                                        h_bdatr007.lighorinc,
                                        h_bdatr007.c24funmat,
                                        h_bdatr007.c24srvdsc

              if ws.atdsrvnum <> r_bdatr007.atdsrvnum  or
                 ws.ligdat    <> h_bdatr007.ligdat     or
                 ws.lighorinc <> h_bdatr007.lighorinc  then
                 open  c_isskfunc using h_bdatr007.c24funmat
                 fetch c_isskfunc into  ws.funnom
                 close c_isskfunc

                 let ws.c24srvdsc = "EM: "   , h_bdatr007.ligdat    clipped,
                                    "  AS: " , h_bdatr007.lighorinc clipped,
                                    "  POR: ", ws.funnom            clipped
                 let ws.atdsrvnum = r_bdatr007.atdsrvnum
                 let ws.ligdat    = h_bdatr007.ligdat
                 let ws.lighorinc = h_bdatr007.lighorinc

                 if flag_hist = 1 then
                    skip 1 lines
                 end if

                 print column 009, ws.c24srvdsc

              end if

              print column 009, h_bdatr007.c24srvdsc

              let flag_hist = 1

           end foreach

           if flag_hist = 0 then
              print column 015, " "
              skip 1 lines
           end if

            let ws.totinccod = ws.totinccod + 1
            let ws.totsrvcvn = ws.totsrvcvn + 1

            case r_bdatr007.ciaempcod
             when 35
               let m_totinccod_azul = m_totinccod_azul + 1
               let m_totsrvcvn_azul = m_totsrvcvn_azul + 1
             when 84
               let m_totinccod_itau = m_totinccod_itau + 1
               let m_totsrvcvn_itau = m_totsrvcvn_itau + 1
             otherwise
               let m_totinccod_porto = m_totinccod_porto + 1
               let m_totsrvcvn_porto = m_totsrvcvn_porto + 1
            end case

           skip 2 lines


      on last row

      --> INCONSISTENCIAS VISAO GERAL

           print column 001, g_traco
           print column 003, ">>> VISAO GERAL DAS INCONSISTENCIAS <<<"
           print column 001, g_traco


           print column 010, "INCONSISTENCIA",
                 column 060, "QUANTIDADE"
           print column 010, g_traco[1,60]
           skip 1 lines

           for arr_aux = 1 to 12
              case arr_aux
                when  2
                  # Conf.Psi 9427-7 nao listar inconsist.(02)
                when  4
                  # Conf.Psi 9427-7 nao listar inconsist.(04)
                when  7
                  # Conf.Psi 9427-7 nao listar inconsist.(07)
                when  8
                  # Conf.Psi 9235-5 nao listar inconsist.(08)
                when  9
                  # Conf.Psi xxxx-x nao listar inconsist.(09)
                when 10
                  # Conf.Psi 9427-7 nao listar inconsist.(10)
                otherwise
                  if a_inconsist[arr_aux].incdsc is not null  then
                     print column 010, a_inconsist[arr_aux].incdsc,
                           column 059, a_inconsist[arr_aux].quant using "##,##&"
                  else
                     exit for
                  end if
              end case
           end for

           skip 1 lines
           print column 010, "TOTAL GERAL DE ATENDIMENTOS INCONSISTENTES",
                 column 060, ws.totsrvgrl using "##,##&"

           skip 2 lines

           print column 001, "------------------------------"
           print column 001, "           DETALHES "
           print column 001, "------------------------------"

       --> VISAO PARA PORTO

           print column 003, g_traco
           print column 005, "VISAO DE INCONSISTENCIAS PARA PORTO"
           print column 003, g_traco

           print column 012, "INCONSISTENCIA",
                 column 062, "QUANTIDADE"
           print column 012, g_traco[1,60]
           skip 1 lines

           for arr_aux = 1 to 12
              case arr_aux
                when  2
                  # Conf.Psi 9427-7 nao listar inconsist.(02)
                when  4
                  # Conf.Psi 9427-7 nao listar inconsist.(04)
                when  7
                  # Conf.Psi 9427-7 nao listar inconsist.(07)
                when  8
                  # Conf.Psi 9235-5 nao listar inconsist.(08)
                when  9
                  # Conf.Psi xxxx-x nao listar inconsist.(09)
                when 10
                  # Conf.Psi 9427-7 nao listar inconsist.(10)
                otherwise
                     if a_inconsist_porto[arr_aux].incdsc is not null  then
                        print column 012, a_inconsist_porto[arr_aux].incdsc,
                              column 061, a_inconsist_porto[arr_aux].quant using "##,##&"
                     else
                        exit for
                     end if
              end case
           end for

           skip 1 lines
           print column 012, "TOTAL DE ATENDIMENTOS INCONSISTENTES PORTO",
                 column 062, m_totsrvgrl_porto using "##,##&"

          skip 2 lines

          print column 001, "--------------------------------"
          print column 001, "    >> FIM DO RELATORIO << "
          print column 001, "--------------------------------"

end report  ###  rep_inconsist_porto

#----------------------------------------------------------------------------#
 report rep_inconsist_azul(param_data, r_bdatr007)
#----------------------------------------------------------------------------#

 define param_data   date

 define r_bdatr007   record
    ligcvntip        like datmligacao.ligcvntip ,
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    c24astcod        like datmligacao.c24astcod ,
    nom              like datmservico.nom       ,
    vcldes           like datmservico.vcldes    ,
    vclanomdl        like datmservico.vclanomdl ,
    vcllicnum        like datmservico.vcllicnum ,
    atdsrvorg        like datmservico.atdsrvorg ,
    atddat           like datmservico.atddat    ,
    atdhor           like datmservico.atdhor    ,
    ciaempcod        like datmservico.ciaempcod ,
    atdetpdes        char (10)                  ,
    funmat           like isskfunc.funmat       ,
    funnom           like isskfunc.funnom       ,
    ramcod           like datrservapol.ramcod   ,
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    edsnumref        like datrservapol.edsnumref,
    inccod           smallint                   ,
    prporg           like datrligprp.prporg     ,
    prpnumdig        like datrligprp.prpnumdig  ,
    ofnnumdig        like sgokofi.ofnnumdig     ,
    nomrazsoc        like gkpkpos.nomrazsoc
 end record

 define h_bdatr007   record
    c24txtseq        like datmservhist.c24txtseq,
    c24srvdsc        like datmservhist.c24srvdsc,
    c24funmat        like datmservhist.c24funmat,
    ligdat           like datmservhist.ligdat   ,
    lighorinc        like datmservhist.lighorinc
 end record

 define ws           record
    ligcvndes        char (025)  ,
    incdsc           char (050)  ,
    totsrvcvn        dec (06,00) ,
    totinccod        dec (06,00) ,
    totsrvgrl        dec (06,00) ,
    funnom           like isskfunc.funnom       ,
    c24srvdsc        like datmservhist.c24srvdsc,
    ligdat           like datmservhist.ligdat   ,
    lighorinc        like datmservhist.lighorinc,
    atdsrvnum        like datmservico.atdsrvnum ,
    srvtipabvdes     like datksrvtip.srvtipabvdes
 end record

 define flag_inccod     smallint
 define flag_inccod_porto     smallint
 define flag_inccod_azul     smallint
 define flag_inccod_itau     smallint
 define flag_hist       smallint

   output
      left   margin  000
      top    margin  000
      bottom margin  000

   order by  r_bdatr007.ligcvntip,
             r_bdatr007.inccod   ,
             r_bdatr007.atdsrvano,
             r_bdatr007.atdsrvnum

   format
      first page header
           for arr_aux = 1  to  12
              let a_inconsist[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist[arr_aux].incdsc #geral

              let a_inconsist_porto[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist_porto[arr_aux].incdsc #porto

              let a_inconsist_azul[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist_azul[arr_aux].incdsc #azul

              let a_inconsist_itau[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist_itau[arr_aux].incdsc #itau
           end for

           let ws.totsrvgrl = 0
           let m_totsrvgrl_porto = 0
           let m_totsrvgrl_azul  = 0
           let m_totsrvgrl_itau  = 0

           print column 072, "DAT007-01"
           print column 062, "DATA   : ", today
           print column 008, "INCONSISTENCIAS NOS ATENDIMENTOS DA AZUL DE ", param_data,
                 column 062, "HORA   :   ", time
           skip 1 lines

      before group of r_bdatr007.ligcvntip
           let ws.totsrvcvn = 0
           let m_totsrvcvn_porto = 0
           let m_totsrvcvn_azul = 0
           let m_totsrvcvn_itau = 0

           let ws.ligcvndes = "** NAO CADASTRADO **"

           open  c_datkdominio using r_bdatr007.ligcvntip
           fetch c_datkdominio into  ws.ligcvndes
           close c_datkdominio

           print column 001, "CONVENIO: ", r_bdatr007.ligcvntip  using "<<<&" clipped, " - ", ws.ligcvndes
           print column 001, g_traco
           skip 1 line

      after  group of r_bdatr007.ligcvntip
           let ws.totsrvgrl = ws.totsrvgrl + ws.totsrvcvn
           let m_totsrvgrl_porto = m_totsrvgrl_porto + m_totsrvcvn_porto
           let m_totsrvgrl_azul = m_totsrvgrl_azul + m_totsrvcvn_azul
           let m_totsrvgrl_itau = m_totsrvgrl_itau + m_totsrvcvn_itau


           skip 1 lines
           print column 001, g_traco
           print column 001, "TOTAL DE ", ws.totsrvcvn using "<<<,<<&",
                             " INCONSISTENCIA(S) DO CONVENIO: ",
                             r_bdatr007.ligcvntip  using "<<<&" clipped,
                             " - ", ws.ligcvndes
           print column 001, g_traco
           skip 2 line


      before group of r_bdatr007.inccod
           let ws.totinccod = 0
           let m_totinccod_porto = 0
           let m_totinccod_azul  = 0
           let m_totinccod_itau  = 0

           call cts01g00_descr(r_bdatr007.inccod) returning ws.incdsc

           if ws.incdsc is null  then
              let ws.incdsc = "*** INCONSISTENCIA NAO PREVISTA! ***"
           end if

           print column 001, "----------------"
           print column 001, "INCONSISTENCIAS: ",ws.incdsc
           print column 001, "----------------"
           skip 1 lines

      after  group of r_bdatr007.inccod
           print column 001, "TOTAL ",ws.incdsc clipped,": ",
                             ws.totinccod using "<<<,<<&"
           print column 001, g_traco
           skip 1 lines

           let flag_inccod = r_bdatr007.inccod
           let a_inconsist[flag_inccod].quant = a_inconsist[flag_inccod].quant + ws.totinccod
          let a_inconsist_porto[flag_inccod].quant = a_inconsist_porto[flag_inccod].quant + m_totinccod_porto
           let a_inconsist_azul[flag_inccod].quant = a_inconsist_azul[flag_inccod].quant + m_totinccod_azul
           let a_inconsist_itau[flag_inccod].quant = a_inconsist_itau[flag_inccod].quant + m_totinccod_itau


      before group of r_bdatr007.atdsrvnum
           let ws.srvtipabvdes = "NAO PREV."

           open  c_datksrvtip using r_bdatr007.atdsrvorg
           fetch c_datksrvtip into  ws.srvtipabvdes
           close c_datksrvtip

           print column 001, "SERVICO.....: ",  r_bdatr007.atdsrvorg
                                                               using "&&",
                                               "/", r_bdatr007.atdsrvnum
                                                               using "&&&&&&&",
                                               "-", r_bdatr007.atdsrvano
                                                               using "&&"
           print column 001, "Tipo Servico :", r_bdatr007.c24astcod,
                                               " - ", ws.srvtipabvdes
           print column 001, "DOCUMENTO...: ";
              if r_bdatr007.succod    is null  and
                 r_bdatr007.aplnumdig is null  and
                 r_bdatr007.itmnumdig is null  then
                 print column 015, "**NAO INFORMADO**"
              else
                 if r_bdatr007.ramcod  =  31   or
                    r_bdatr007.ramcod  = 531   then
                    print column 015, r_bdatr007.ramcod     using "###&"      ,
                                 "/", r_bdatr007.succod     using "&&"        ,
                                 "/", r_bdatr007.aplnumdig  using "<<<<<<<& &",
                                 "/", r_bdatr007.itmnumdig  using "<<<<<& &"
                 else
                    print column 015, r_bdatr007.ramcod     using "###&"      ,
                                 "/", r_bdatr007.succod     using "&&"        ,
                                 "/", r_bdatr007.aplnumdig  using "<<<<<<<& &"

                 end if
              end if


           let l_log = "Proposta Relatorio ", r_bdatr007.prporg clipped
           call errorlog(l_log)


           if r_bdatr007.prporg is not null then
              print column 001, "Proposta....: ", r_bdatr007.prporg using "&&",
                                                  " ",
                                                  r_bdatr007.prpnumdig using "<<<<<<<<&"
           end if
           print column 001, "Segurado....: ", r_bdatr007.nom
           print column 001, "Veiculo.....: ", r_bdatr007.vcldes
           print column 001, "Ano.........: ", r_bdatr007.vclanomdl
           print column 001, "Placa.......: ", r_bdatr007.vcllicnum
           print column 001, "Etapa.......: ", r_bdatr007.atdetpdes
           print column 001, "Atendente...: ", r_bdatr007.funmat using "&&&&&&",
                                               " - ", upshift(r_bdatr007.funnom)
           print column 001, "Data/Hora...: ", r_bdatr007.atddat,
                                               " ", r_bdatr007.atdhor
           print column 001, "Oficina.....: ", r_bdatr007.ofnnumdig,
                                               " ", r_bdatr007.nomrazsoc


      after  group of r_bdatr007.atdsrvnum
           let flag_hist = 0
           print column 001, "Historico...:"

              open    c_historico using r_bdatr007.atdsrvnum,
                                        r_bdatr007.atdsrvano
              foreach c_historico into  h_bdatr007.ligdat   ,
                                        h_bdatr007.lighorinc,
                                        h_bdatr007.c24funmat,
                                        h_bdatr007.c24srvdsc

              if ws.atdsrvnum <> r_bdatr007.atdsrvnum  or
                 ws.ligdat    <> h_bdatr007.ligdat     or
                 ws.lighorinc <> h_bdatr007.lighorinc  then
                 open  c_isskfunc using h_bdatr007.c24funmat
                 fetch c_isskfunc into  ws.funnom
                 close c_isskfunc

                 let ws.c24srvdsc = "EM: "   , h_bdatr007.ligdat    clipped,
                                    "  AS: " , h_bdatr007.lighorinc clipped,
                                    "  POR: ", ws.funnom            clipped
                 let ws.atdsrvnum = r_bdatr007.atdsrvnum
                 let ws.ligdat    = h_bdatr007.ligdat
                 let ws.lighorinc = h_bdatr007.lighorinc

                 if flag_hist = 1 then
                    skip 1 lines
                 end if

                 print column 009, ws.c24srvdsc

              end if

              print column 009, h_bdatr007.c24srvdsc

              let flag_hist = 1

           end foreach

           if flag_hist = 0 then
              print column 015, " "
              skip 1 lines
           end if

            let ws.totinccod = ws.totinccod + 1
            let ws.totsrvcvn = ws.totsrvcvn + 1

            case r_bdatr007.ciaempcod
             when 35
               let m_totinccod_azul = m_totinccod_azul + 1
               let m_totsrvcvn_azul = m_totsrvcvn_azul + 1
             when 84
               let m_totinccod_itau = m_totinccod_itau + 1
               let m_totsrvcvn_itau = m_totsrvcvn_itau + 1
             otherwise
               let m_totinccod_porto = m_totinccod_porto + 1
               let m_totsrvcvn_porto = m_totsrvcvn_porto + 1
            end case

           skip 2 lines


      on last row

           print column 003, g_traco
           print column 005, "VISAO DE INCONSISTENCIAS PARA AZUL"
           print column 003, g_traco

           print column 012, "INCONSISTENCIA",
                 column 062, "QUANTIDADE"
           print column 012, g_traco[1,60]
           skip 1 lines

           for arr_aux = 1 to 12
              case arr_aux
                when  2
                  # Conf.Psi 9427-7 nao listar inconsist.(02)
                when  4
                  # Conf.Psi 9427-7 nao listar inconsist.(04)
                when  7
                  # Conf.Psi 9427-7 nao listar inconsist.(07)
                when  8
                  # Conf.Psi 9235-5 nao listar inconsist.(08)
                when  9
                  # Conf.Psi xxxx-x nao listar inconsist.(09)
                when 10
                  # Conf.Psi 9427-7 nao listar inconsist.(10)
                otherwise
                     if a_inconsist_azul[arr_aux].incdsc is not null  then
                        print column 012, a_inconsist_azul[arr_aux].incdsc,
                              column 061, a_inconsist_azul[arr_aux].quant using "##,##&"
                     else
                        exit for
                     end if
              end case
           end for

           skip 1 lines
           print column 012, "TOTAL DE ATENDIMENTOS INCONSISTENTES AZUL",
                 column 062, m_totsrvgrl_azul using "##,##&"

           skip 2 lines
           print column 001, "--------------------------------"
           print column 001, "    >> FIM DO RELATORIO << "
           print column 001, "--------------------------------"

end report  ###  rep_inconsist_azul

#----------------------------------------------------------------------------#
 report rep_inconsist_itau(param_data, r_bdatr007)
#----------------------------------------------------------------------------#

 define param_data   date

 define r_bdatr007   record
    ligcvntip        like datmligacao.ligcvntip ,
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    c24astcod        like datmligacao.c24astcod ,
    nom              like datmservico.nom       ,
    vcldes           like datmservico.vcldes    ,
    vclanomdl        like datmservico.vclanomdl ,
    vcllicnum        like datmservico.vcllicnum ,
    atdsrvorg        like datmservico.atdsrvorg ,
    atddat           like datmservico.atddat    ,
    atdhor           like datmservico.atdhor    ,
    ciaempcod        like datmservico.ciaempcod ,
    atdetpdes        char (10)                  ,
    funmat           like isskfunc.funmat       ,
    funnom           like isskfunc.funnom       ,
    ramcod           like datrservapol.ramcod   ,
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    edsnumref        like datrservapol.edsnumref,
    inccod           smallint                   ,
    prporg           like datrligprp.prporg     ,
    prpnumdig        like datrligprp.prpnumdig  ,
    ofnnumdig        like sgokofi.ofnnumdig     ,
    nomrazsoc        like gkpkpos.nomrazsoc
 end record

 define h_bdatr007   record
    c24txtseq        like datmservhist.c24txtseq,
    c24srvdsc        like datmservhist.c24srvdsc,
    c24funmat        like datmservhist.c24funmat,
    ligdat           like datmservhist.ligdat   ,
    lighorinc        like datmservhist.lighorinc
 end record

 define ws           record
    ligcvndes        char (025)  ,
    incdsc           char (050)  ,
    totsrvcvn        dec (06,00) ,
    totinccod        dec (06,00) ,
    totsrvgrl        dec (06,00) ,
    funnom           like isskfunc.funnom       ,
    c24srvdsc        like datmservhist.c24srvdsc,
    ligdat           like datmservhist.ligdat   ,
    lighorinc        like datmservhist.lighorinc,
    atdsrvnum        like datmservico.atdsrvnum ,
    srvtipabvdes     like datksrvtip.srvtipabvdes
 end record

 define flag_inccod     smallint
 define flag_inccod_porto     smallint
 define flag_inccod_azul     smallint
 define flag_inccod_itau     smallint
 define flag_hist       smallint

   output
      left   margin  000
      top    margin  000
      bottom margin  000

   order by  r_bdatr007.ligcvntip,
             r_bdatr007.inccod   ,
             r_bdatr007.atdsrvano,
             r_bdatr007.atdsrvnum

   format
      first page header
           for arr_aux = 1  to  12
              let a_inconsist[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist[arr_aux].incdsc #geral

              let a_inconsist_porto[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist_porto[arr_aux].incdsc #porto

              let a_inconsist_azul[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist_azul[arr_aux].incdsc #azul

              let a_inconsist_itau[arr_aux].quant = 0
              call cts01g00_descr(arr_aux)
                        returning a_inconsist_itau[arr_aux].incdsc #itau
           end for

           let ws.totsrvgrl = 0
           let m_totsrvgrl_porto = 0
           let m_totsrvgrl_azul  = 0
           let m_totsrvgrl_itau  = 0

           print column 072, "DAT007-01"
           print column 062, "DATA   : ", today
           print column 008, "INCONSISTENCIAS NOS ATENDIMENTOS DO ITAU DE ", param_data,
                 column 062, "HORA   :   ", time
           skip 1 lines

      before group of r_bdatr007.ligcvntip
           let ws.totsrvcvn = 0
           let m_totsrvcvn_porto = 0
           let m_totsrvcvn_azul = 0
           let m_totsrvcvn_itau = 0

           let ws.ligcvndes = "** NAO CADASTRADO **"

           open  c_datkdominio using r_bdatr007.ligcvntip
           fetch c_datkdominio into  ws.ligcvndes
           close c_datkdominio

           print column 001, "CONVENIO: ", r_bdatr007.ligcvntip  using "<<<&" clipped, " - ", ws.ligcvndes
           print column 001, g_traco
           skip 1 line

      after  group of r_bdatr007.ligcvntip
           let ws.totsrvgrl = ws.totsrvgrl + ws.totsrvcvn
           let m_totsrvgrl_porto = m_totsrvgrl_porto + m_totsrvcvn_porto
           let m_totsrvgrl_azul = m_totsrvgrl_azul + m_totsrvcvn_azul
           let m_totsrvgrl_itau = m_totsrvgrl_itau + m_totsrvcvn_itau


           skip 1 lines
           print column 001, g_traco
           print column 001, "TOTAL DE ", ws.totsrvcvn using "<<<,<<&",
                             " INCONSISTENCIA(S) DO CONVENIO: ",
                             r_bdatr007.ligcvntip  using "<<<&" clipped,
                             " - ", ws.ligcvndes
           print column 001, g_traco
           skip 2 line


      before group of r_bdatr007.inccod
           let ws.totinccod = 0
           let m_totinccod_porto = 0
           let m_totinccod_azul  = 0
           let m_totinccod_itau  = 0

           call cts01g00_descr(r_bdatr007.inccod) returning ws.incdsc

           if ws.incdsc is null  then
              let ws.incdsc = "*** INCONSISTENCIA NAO PREVISTA! ***"
           end if

           print column 001, "----------------"
           print column 001, "INCONSISTENCIAS: ",ws.incdsc
           print column 001, "----------------"
           skip 1 lines

      after  group of r_bdatr007.inccod
           print column 001, "TOTAL ",ws.incdsc clipped,": ",
                             ws.totinccod using "<<<,<<&"
           print column 001, g_traco
           skip 1 lines

           let flag_inccod = r_bdatr007.inccod
           let a_inconsist[flag_inccod].quant = a_inconsist[flag_inccod].quant + ws.totinccod
          let a_inconsist_porto[flag_inccod].quant = a_inconsist_porto[flag_inccod].quant + m_totinccod_porto
           let a_inconsist_azul[flag_inccod].quant = a_inconsist_azul[flag_inccod].quant + m_totinccod_azul
           let a_inconsist_itau[flag_inccod].quant = a_inconsist_itau[flag_inccod].quant + m_totinccod_itau


      before group of r_bdatr007.atdsrvnum
           let ws.srvtipabvdes = "NAO PREV."

           open  c_datksrvtip using r_bdatr007.atdsrvorg
           fetch c_datksrvtip into  ws.srvtipabvdes
           close c_datksrvtip

           print column 001, "SERVICO.....: ",  r_bdatr007.atdsrvorg
                                                               using "&&",
                                               "/", r_bdatr007.atdsrvnum
                                                               using "&&&&&&&",
                                               "-", r_bdatr007.atdsrvano
                                                               using "&&"
           print column 001, "Tipo Servico :", r_bdatr007.c24astcod,
                                               " - ", ws.srvtipabvdes
           print column 001, "DOCUMENTO...: ";
              if r_bdatr007.succod    is null  and
                 r_bdatr007.aplnumdig is null  and
                 r_bdatr007.itmnumdig is null  then
                 print column 015, "**NAO INFORMADO**"
              else
                 if r_bdatr007.ramcod  =  31   or
                    r_bdatr007.ramcod  = 531   then
                    print column 015, r_bdatr007.ramcod     using "###&"      ,
                                 "/", r_bdatr007.succod     using "&&"        ,
                                 "/", r_bdatr007.aplnumdig  using "<<<<<<<& &",
                                 "/", r_bdatr007.itmnumdig  using "<<<<<& &"
                 else
                    print column 015, r_bdatr007.ramcod     using "###&"      ,
                                 "/", r_bdatr007.succod     using "&&"        ,
                                 "/", r_bdatr007.aplnumdig  using "<<<<<<<& &"

                 end if
              end if


           let l_log = "Proposta Relatorio ", r_bdatr007.prporg clipped
           call errorlog(l_log)


           if r_bdatr007.prporg is not null then
              print column 001, "Proposta....: ", r_bdatr007.prporg using "&&",
                                                  " ",
                                                  r_bdatr007.prpnumdig using "<<<<<<<<&"
           end if
           print column 001, "Segurado....: ", r_bdatr007.nom
           print column 001, "Veiculo.....: ", r_bdatr007.vcldes
           print column 001, "Ano.........: ", r_bdatr007.vclanomdl
           print column 001, "Placa.......: ", r_bdatr007.vcllicnum
           print column 001, "Etapa.......: ", r_bdatr007.atdetpdes
           print column 001, "Atendente...: ", r_bdatr007.funmat using "&&&&&&",
                                               " - ", upshift(r_bdatr007.funnom)
           print column 001, "Data/Hora...: ", r_bdatr007.atddat,
                                               " ", r_bdatr007.atdhor
           print column 001, "Oficina.....: ", r_bdatr007.ofnnumdig,
                                               " ", r_bdatr007.nomrazsoc


      after  group of r_bdatr007.atdsrvnum
           let flag_hist = 0
           print column 001, "Historico...:"

              open    c_historico using r_bdatr007.atdsrvnum,
                                        r_bdatr007.atdsrvano
              foreach c_historico into  h_bdatr007.ligdat   ,
                                        h_bdatr007.lighorinc,
                                        h_bdatr007.c24funmat,
                                        h_bdatr007.c24srvdsc

              if ws.atdsrvnum <> r_bdatr007.atdsrvnum  or
                 ws.ligdat    <> h_bdatr007.ligdat     or
                 ws.lighorinc <> h_bdatr007.lighorinc  then
                 open  c_isskfunc using h_bdatr007.c24funmat
                 fetch c_isskfunc into  ws.funnom
                 close c_isskfunc

                 let ws.c24srvdsc = "EM: "   , h_bdatr007.ligdat    clipped,
                                    "  AS: " , h_bdatr007.lighorinc clipped,
                                    "  POR: ", ws.funnom            clipped
                 let ws.atdsrvnum = r_bdatr007.atdsrvnum
                 let ws.ligdat    = h_bdatr007.ligdat
                 let ws.lighorinc = h_bdatr007.lighorinc

                 if flag_hist = 1 then
                    skip 1 lines
                 end if

                 print column 009, ws.c24srvdsc

              end if

              print column 009, h_bdatr007.c24srvdsc

              let flag_hist = 1

           end foreach

           if flag_hist = 0 then
              print column 015, " "
              skip 1 lines
           end if

            let ws.totinccod = ws.totinccod + 1
            let ws.totsrvcvn = ws.totsrvcvn + 1

            case r_bdatr007.ciaempcod
             when 35
               let m_totinccod_azul = m_totinccod_azul + 1
               let m_totsrvcvn_azul = m_totsrvcvn_azul + 1
             when 84
               let m_totinccod_itau = m_totinccod_itau + 1
               let m_totsrvcvn_itau = m_totsrvcvn_itau + 1
             otherwise
               let m_totinccod_porto = m_totinccod_porto + 1
               let m_totsrvcvn_porto = m_totsrvcvn_porto + 1
            end case

           skip 2 lines


      on last row

           print column 003, g_traco
           print column 005, "VISAO DE INCONSISTENCIAS PARA ITAU"
           print column 003, g_traco

           print column 012, "INCONSISTENCIA",
                 column 062, "QUANTIDADE"
           print column 012, g_traco[1,60]
           skip 1 lines

           for arr_aux = 1 to 12
              case arr_aux
                when  2
                  # Conf.Psi 9427-7 nao listar inconsist.(02)
                when  4
                  # Conf.Psi 9427-7 nao listar inconsist.(04)
                when  7
                  # Conf.Psi 9427-7 nao listar inconsist.(07)
                when  8
                  # Conf.Psi 9235-5 nao listar inconsist.(08)
                when  9
                  # Conf.Psi xxxx-x nao listar inconsist.(09)
                when 10
                  # Conf.Psi 9427-7 nao listar inconsist.(10)
                otherwise
                     if a_inconsist_itau[arr_aux].incdsc is not null  then
                        print column 012, a_inconsist_itau[arr_aux].incdsc,
                              column 061, a_inconsist_itau[arr_aux].quant using "##,##&"
                     else
                        exit for
                     end if
              end case
           end for


           skip 1 lines
           print column 012, "TOTAL DE ATENDIMENTOS INCONSISTENTES ITAU",
                 column 062, m_totsrvgrl_itau using "##,##&"

           skip 2 lines
           print column 001, "--------------------------------"
           print column 001, "    >> FIM DO RELATORIO << "
           print column 001, "--------------------------------"

end report  ###  rep_inconsist_itau


#----------------------------------------------------------------------------#
 report rep_qtdatend(param_data, r_bdatr007)
#----------------------------------------------------------------------------#

 define param_data   date

 define r_bdatr007   record
    ligcvntip        like datmligacao.ligcvntip ,
    atdsrvorg        like datmservico.atdsrvorg ,
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    nom              like datmservico.nom       ,
    vcldes           like datmservico.vcldes    ,
    vclanomdl        like datmservico.vclanomdl ,
    vcllicnum        like datmservico.vcllicnum ,
    ramcod           like datrservapol.ramcod   ,
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    corsus           like gcaksusep.corsus      ,
    cornom           like gcakcorr.cornom       ,
    dddcod           like gcakfilial.dddcod     ,
    factxt           like gcakfilial.factxt     ,
    pgrnum           like htlrust.pgrnum        ,
    clscod           like abbmclaus.clscod      ,
    qtdatd           smallint
 end record

 define ws           record
    ligcvndes        char (25)                  ,
    ramnom           like gtakram.ramnom        ,
    clausdesc        char (20)
 end record


   output
      left   margin  000
      top    margin  000
      bottom margin  000

   order by  r_bdatr007.ramcod,
             r_bdatr007.ligcvntip,
             r_bdatr007.corsus

   format
      first page header
           print column 072, "DAT007-02"
           print column 062, "DATA   : ", today
           print column 008, "CONTROLE DE ATENDIMENTOS RAMO/CLAUSULA EM ", param_data,
                 column 062, "HORA   :   ", time
           skip 1 lines

      before group of r_bdatr007.ramcod
           let ws.ramnom = "** NAO CADASTRADO **"
           open  c_gtakram using r_bdatr007.ramcod
           fetch c_gtakram into  ws.ramnom
           close c_gtakram

           initialize ws.clausdesc  to null
           case r_bdatr007.ramcod
                when  31
                  let ws.clausdesc = "CLAUSULAS: 34/35"
                when  45
                  let ws.clausdesc = "CLAUSULAS: 10   "
           end case

           print column 001, "RAMO    : ", r_bdatr007.ramcod    using "###&",
                                        " - ", ws.ramnom[1,20],
                 column 040, ws.clausdesc

           print column 001, g_traco
           skip 1 lines

      before group of r_bdatr007.ligcvntip
           let ws.ligcvndes = "** NAO CADASTRADO **"
           open  c_datkdominio using r_bdatr007.ligcvntip
           fetch c_datkdominio into  ws.ligcvndes
           close c_datkdominio

           print column 001, "---------"
           print column 001, "CONVENIO: ", r_bdatr007.ligcvntip using "###&",
                                        " - ", ws.ligcvndes
           print column 001, "---------"
           skip 1 lines

      on every row
           print column 001, "SERVICO..: ", r_bdatr007.atdsrvorg using "&&",
                                      "/", r_bdatr007.atdsrvnum using "&&&&&&&",
                                       "-", r_bdatr007.atdsrvano using "&&"
           print column 001, "SUSEP....: ", r_bdatr007.corsus
           print column 001, "CORRETOR.: ", r_bdatr007.cornom
           print column 001, "FAX......: ";
                if r_bdatr007.factxt is null  then
                   print column 012, "NAO TEM"
                else
                   print column 012, "(", r_bdatr007.dddcod, ") ",
                                     r_bdatr007.factxt
                end if
           print column 001, "PAGER....: ";
                if r_bdatr007.pgrnum is null  then
                   print column 012, " NAO TEM"
                else
                   print column 012, r_bdatr007.pgrnum  using "#######&"
                end if
           print column 001, "CLAUS....: ", r_bdatr007.clscod
           print column 001, "DOCUMENTO: ";
                if r_bdatr007.ramcod  =  31   or
                   r_bdatr007.ramcod  = 531   then
                   print column 012, r_bdatr007.succod     using "&&"        ,
                                "/", r_bdatr007.aplnumdig  using "<<<<<<<& &",
                                "/", r_bdatr007.itmnumdig  using "<<<<<& &"
                else
                   print column 012, r_bdatr007.succod     using "&&"        ,
                                "/", r_bdatr007.aplnumdig  using "<<<<<<<& &"

                end if
           print column 001, "SEGURADO.: ", r_bdatr007.nom
           print column 001, "VEICULO..: ", r_bdatr007.vcldes
           print column 001, "ANO......: ", r_bdatr007.vclanomdl
           print column 001, "PLACA....: ", r_bdatr007.vcllicnum
           print column 001, "ATEND....: ", r_bdatr007.qtdatd     using "#&"
           skip 1 line

      on last row
           print column 001, "-------------------"
           print column 001, " FIM DO RELATORIO!"
           print column 001, "-------------------"
           skip 1 line


end report  ###  rep_qtdatend

#--------------------------#
function bdatr007_cria_log()
#--------------------------#

  # -> FUNCAO P/CRIAR O ARQUIVO DE LOG DO PROGRAMA

  define l_path char(80)

  let l_path = null

  let l_path = f_path("DAT","LOG")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdatr007.log"


  call startlog(l_path)

end function

#------------------------------------------------#
function bdatr007_envia_email_erro(lr_parametro)
#------------------------------------------------#
  define lr_parametro record
         assunto      char(150),
         msg          char(400)
  end record
   define lr_mail record
          rem     char(50),
          des     char(250),
          ccp     char(250),
          cco     char(250),
          ass     char(150),
          msg     char(32000),
          idr     char(20),
          tip     char(4)
   end record
  define l_cod_erro      integer,
         l_msg_erro      char(20)
 initialize lr_mail.* to null
     let lr_mail.des = "sistemas.madeira@portoseguro.com.br"
     let lr_mail.rem = "ZeladoriaMadeira"
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = lr_parametro.assunto
     let lr_mail.idr = "bdatr007"
     let lr_mail.tip = "text"
     let lr_mail.msg = lr_parametro.msg
        call figrc009_mail_send1(lr_mail.*)
           returning l_cod_erro, l_msg_erro
  if l_cod_erro = 0  then
    display l_msg_erro
  else
    display l_msg_erro
  end if
end function