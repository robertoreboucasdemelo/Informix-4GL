#############################################################################
# Nome do Modulo: bdbsr080                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Gera relatorio indicacao oficinas                                Jan/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 18/02/2000  MUDANCA      Wagner       Alterar envio uuencode para mailx   #
#---------------------------------------------------------------------------#
# 10/04/2000  ALTERACAO    Wagner       Inclusao nr.tel segurado e nr.tel.  #
#                                       origem (AGUARDANDO PSI)             #
#---------------------------------------------------------------------------#
# 13/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 21/09/2000  PSI 11253-4  Ruiz         Inclusao do codigo da oficina no    #
#                                       destino da remocao.                 #
#---------------------------------------------------------------------------#
# 18/10/2000               Raji         Formato excel , impressao apenas das#
#                                       remocoes com processo no dia anterio#
#                                       r e sem processo a 15 dias          #
#---------------------------------------------------------------------------#
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                        #
#---------------------------------------------------------------------------#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# 16/11/2006 Alberto Rodrigues    205206  implementado leitura campo ciaempcod#
#                                        para desprezar qdo for Azul Segur.   #
###############################################################################
#.............................................................................#
#                                                                             #
#                          * * * ALTERACAO * * *                              #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- ---------------------------------------#
# 20/08/2007  Saulo, Meta    AS146056  Substituicao de palavras reservadas    #
#-----------------------------------------------------------------------------#

 database porto

 define g_traco        char(80)
 define ws_incdat      date
 define ws_fnldat      date
 define m_path         char(100)

 main
    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr080.log"

    call startlog(m_path)
    # PSI 185035 - Final

    call bdbsr080()
 end main

#---------------------------------------------------------------
 function bdbsr080()
#---------------------------------------------------------------

 define d_bdbsr080    record
    tiporel           dec(1,0),
    tiporeldes        char (41),
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atddat            like datmservico.atddat,
    atdprscod         like datmservico.atdprscod,
    atdvclsgl         like datmservico.atdvclsgl,
    srrcoddig         like datmservico.srrcoddig,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    srrabvnom         like datksrr.srrabvnom,
    segnom            like gsakseg.segnom,
    endcid            like gsakend.endcid,
    endufd            like gsakend.endufd,
    dddcod            like gsakend.dddcod,
    teltxt            like gsakend.teltxt,
    lclidttxt         like datmlcl.lclidttxt,
    lgdnom            like datmlcl.lgdnom,
    brrnom            like datmlcl.brrnom,
    cidnom            like datmlcl.cidnom,
    ufdcod            like datmlcl.ufdcod,
    lcldddcod         like datmlcl.dddcod,
    lcltelnum         like datmlcl.lcltelnum,
    sinano            like ssamsin.sinano,         # ano processo
    sinnum            like ssamsin.sinnum,         # nr. processo
    ofnnumdigproc     like svomroteiro.ofnnumdig,  # codigo oficina processo
    sinlaudat         like svomroteiro.sinlaudat,  # data do processo
    ofnnumdigdest     like datmlcl.ofnnumdig    ,  # codigo oficina destino
    nomrazsoc_of      like gkpkpos.nomrazsoc,      # razao oficina
    nomgrr_of         like gkpkpos.nomgrr,         # fantasia oficina
    endlgd_of         like gkpkpos.endlgd,         # end oficina
    endbrr_of         like gkpkpos.endbrr,         # bairro oficina
    endcid_of         like gkpkpos.endcid,         # cidade oficina
    endufd_of         like gkpkpos.endufd,         # UF oficina
    creddestino       char (03),
    credprocesso      char (03),
    ciaempcod         like datmservico.ciaempcod
 end record

 define ws_funapol    record
    resultado         char (01),
    dctnumseq         decimal(04,00),
    vclsitatu         decimal(04,00),
    autsitatu         decimal(04,00),
    dmtsitatu         decimal(04,00),
    dpssitatu         decimal(04,00),
    appsitatu         decimal(04,00),
    vidsitatu         decimal(04,00)
 end record

 define ws            record
    auxdat            char (10),
    atdetpcod         like datmsrvacp.atdetpcod,
    socvclcod         like datmservico.socvclcod,
    segnumdig         like abbmdoc.segnumdig,
    clalclcod         like abbmdoc.clalclcod,
    edsnumref         like datrservapol.edsnumref,
    ramcod            like datrservapol.ramcod,
    sindat            like datmservicocmp.sindat,
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    comando           char (400),
    coderr            integer,
    jitflg            char (01),
    privez            char (01),
    ofncrdflg         like sgokofi.ofncrdflg,
    ofncvnflg         like sgokofi.ofncvnflg
 end record

 define l_retorno      smallint

 initialize d_bdbsr080.*  to null
 initialize ws_funapol.*  to null
 initialize ws.*          to null
 let ws.privez  = "S"
 let g_traco = "--------------------------------------------------------------------------------"


 #--------------------------------------------------------------------
 # Preparando SQL ETAPAS
 #--------------------------------------------------------------------
 let ws.comando  = "select atdetpcod    ",
                   "  from datmsrvacp   ",
                   " where atdsrvnum = ?",
                   "   and atdsrvano = ?",
                   "   and atdsrvseq = (select max(atdsrvseq)",
                                       "  from datmsrvacp    ",
                                       " where atdsrvnum = ? ",
                                       "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from ws.comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

 #---------------------------------------------------------------
 # Preparando SQL NOME DO SEGURADO
 #---------------------------------------------------------------
 let ws.comando  = "select segnom     ",
                   "  from gsakseg    ",
                   " where segnumdig = ? "
 prepare sel_gsakseg from ws.comando
 declare c_gsakseg cursor for sel_gsakseg

 #---------------------------------------------------------------
 # Preparando SQL  Cidade/UF/ddd/telefone DO SEGURADO
 #---------------------------------------------------------------
 let ws.comando  = "select endcid, endufd, ",
                   "       dddcod, teltxt  ",
                   "  from gsakend         ",
                   " where segnumdig = ?   ",
                   "   and endfld    = '1' "
 prepare sel_gsakend from ws.comando
 declare c_gsakend cursor for sel_gsakend

 #---------------------------------------------------------------
 # Preparando SQL TEL LOCAL ORIGEM
 #---------------------------------------------------------------
 let ws.comando  = "select dddcod, lcltelnum ",
                   "  from datmlcl           ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? ",
                   "   and c24endtip = 1 "
 prepare sel_datmlcl_ori from ws.comando
 declare c_datmlcl_ori cursor for sel_datmlcl_ori

 #---------------------------------------------------------------
 # Preparando SQL  LOCAL DESTINO
 #---------------------------------------------------------------
 let ws.comando  = "select lclidttxt, lgdnom, ",
                   "       brrnom,    cidnom, ",
                   "       ufdcod, ofnnumdig  ",
                   "  from datmlcl            ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? ",
                   "   and c24endtip = 2 "
 prepare sel_datmlcl from ws.comando
 declare c_datmlcl cursor for sel_datmlcl

 #--------------------------------------------------------------------
 # Preparando SQL PRESTADOR
 #--------------------------------------------------------------------
 let ws.comando  = "select nomrazsoc     ",
                   "  from dpaksocor     ",
                   " where pstcoddig = ? "
 prepare sel_dpaksocor from ws.comando
 declare c_dpaksocor cursor for sel_dpaksocor

 #---------------------------------------------------------------
 # Preparando SQL MOTORISTA
 #---------------------------------------------------------------
 let ws.comando = "select srrabvnom ",
                  "  from datksrr   ",
                  " where srrcoddig = ? "
 prepare sel_datksrr from ws.comando
 declare c_datksrr cursor for sel_datksrr

 #--------------------------------------------------------------------
 # Preparando SQL SIGLA VEICULO
 #--------------------------------------------------------------------
 let ws.comando  = "select atdvclsgl     ",
                   "  from datkveiculo   ",
                   " where socvclcod = ? "

 prepare sel_datkveiculo from ws.comando
 declare c_datkveiculo cursor for sel_datkveiculo

 #--------------------------------------------------------------------
 # Preparando SQL OFICINA CREDENCIADA
 #--------------------------------------------------------------------
 let ws.comando  = "select ofncrdflg,ofncvnflg ",
                   "  from sgokofi       ",
                   " where ofnnumdig = ? "

 prepare sel_sgokofi from ws.comando
 declare c_sgokofi cursor for sel_sgokofi

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
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws_fnldat       = ws.auxdat
 let ws_incdat       = ws_fnldat - 15 units day


 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DBS", "ARQUIVO")
      returning ws.dirfisnom

 if ws.dirfisnom is null then
    let ws.dirfisnom = "."
 end if

let ws.pathrel01  = ws.dirfisnom clipped, "/RDBS08001"

 #---------------------------------------------------------------
 # Cursor principal
 #---------------------------------------------------------------
 declare c_bdbsr080 cursor for
  select datmservico.atdsrvorg ,
         datmservico.atdsrvnum ,
         datmservico.atdsrvano ,
         datmservico.atddat    ,
         datmservico.atdprscod ,
         datmservico.atdvclsgl ,
         datmservico.socvclcod ,
         datmservico.srrcoddig ,
         datrservapol.succod   ,
         datrservapol.ramcod   ,
         datrservapol.aplnumdig,
         datrservapol.itmnumdig,
         datrservapol.edsnumref,
         datmservico.ciaempcod
    from datmservico, datrservapol
   where datmservico.atddat       between  ws_incdat  and ws_fnldat
     and datmservico.atdsrvorg    = 4   # Servico de Remocao
     and datmservico.ciaempcod    = 1   # Apenas servico Porto
     and datrservapol.atdsrvnum   = datmservico.atdsrvnum
     and datrservapol.atdsrvano   = datmservico.atdsrvano
     and datmservico.atdetpcod    = 4   # Servico acionado


 start report bdbsr080_rel to ws.pathrel01

 foreach c_bdbsr080  into  d_bdbsr080.atdsrvorg,
                           d_bdbsr080.atdsrvnum, d_bdbsr080.atdsrvano,
                           d_bdbsr080.atddat   , d_bdbsr080.atdprscod,
                           d_bdbsr080.atdvclsgl, ws.socvclcod,
                           d_bdbsr080.srrcoddig, d_bdbsr080.succod   ,
                           d_bdbsr080.ramcod   , d_bdbsr080.aplnumdig,
                           d_bdbsr080.itmnumdig, ws.edsnumref,
                           d_bdbsr080.ciaempcod

    #---------------------------------------------------------------
    # Busca ultima situacao da apolice
    #---------------------------------------------------------------
    initialize ws_funapol.*   to null
    initialize ws.segnumdig   to null

    call f_funapol_ultima_situacao
         (d_bdbsr080.succod, d_bdbsr080.aplnumdig, d_bdbsr080.itmnumdig)
          returning  ws_funapol.*

    select segnumdig, clalclcod
      into ws.segnumdig, ws.clalclcod
      from abbmdoc
     where succod    = d_bdbsr080.succod
       and aplnumdig = d_bdbsr080.aplnumdig
       and itmnumdig = d_bdbsr080.itmnumdig
       and dctnumseq = ws_funapol.dctnumseq

    if sqlca.sqlcode <> 0  then
       continue foreach
    else
       if ws.clalclcod <> 11 then  # SOMENTE CLASSE LOCALIZACAO 11
          continue foreach
       end if
    end if

    #---------------------------------------------------------------
    # Verifica acionamento do JUST IN TIME
    #---------------------------------------------------------------
    call ctx03g00(d_bdbsr080.ramcod,      # ramo
                  d_bdbsr080.succod,      # sucursal
                  d_bdbsr080.aplnumdig,   # apolice
                  d_bdbsr080.itmnumdig,   # item
                  d_bdbsr080.atddat   )   # dt.atend
        returning ws.coderr, ws.jitflg

    if ws.coderr  =  0    and
       ws.jitflg   = "S"   then
       continue foreach
    end if

    #---------------------------------------------------------------
    # Verifica se tem processo de sinistro em aberto
    #---------------------------------------------------------------
    initialize d_bdbsr080.sinano thru d_bdbsr080.endufd_of to null
    initialize ws.sindat                                   to null

    select datmservicocmp.sindat
      into ws.sindat
      from datmservicocmp
     where datmservicocmp.atdsrvnum = d_bdbsr080.atdsrvnum
       and datmservicocmp.atdsrvano = d_bdbsr080.atdsrvano

    if ws.sindat is null then
       let ws.sindat = d_bdbsr080.atddat
    end if

    call osauc040_sinistro(d_bdbsr080.ramcod,      # ramo
                           d_bdbsr080.succod,      # sucursal
                           d_bdbsr080.aplnumdig,   # apolice
                           d_bdbsr080.itmnumdig,   # item
                           ws.sindat,              # dt.sinistro
                           d_bdbsr080.atddat,      # dt.atend
                           ws.privez)
                returning  ws.ramcod,
                           d_bdbsr080.sinano,
                           d_bdbsr080.sinnum

    let ws.privez = "N"

    if d_bdbsr080.sinano is not null and
       d_bdbsr080.sinnum is not null then

       declare c_svomroteiro cursor for
        select ofnnumdig,
               sinlaudat
          from svomroteiro
        where svomroteiro.ramcod    = d_bdbsr080.ramcod
          and svomroteiro.sinano    = d_bdbsr080.sinano
          and svomroteiro.sinnum    = d_bdbsr080.sinnum
          and svomroteiro.sinitmseq = 0

       foreach c_svomroteiro into d_bdbsr080.ofnnumdigproc,
                                  d_bdbsr080.sinlaudat

          # Verifica se o processo e da data do processamento
          if d_bdbsr080.sinlaudat <> ws.auxdat then
             continue foreach
          end if

          select nomrazsoc, nomgrr, endlgd, endbrr, endcid, endufd
            into d_bdbsr080.nomrazsoc_of, d_bdbsr080.nomgrr_of,
                 d_bdbsr080.endlgd_of   , d_bdbsr080.endbrr_of,
                 d_bdbsr080.endcid_of   , d_bdbsr080.endufd_of
            from gkpkpos
           where gkpkpos.pstcoddig = d_bdbsr080.ofnnumdigproc
           exit foreach
       end foreach
    else
       # Verifica se nao eh sem processo a 15 dias
       if d_bdbsr080.atddat <> ws_incdat then
          continue foreach
       end if
    end if

    if d_bdbsr080.nomrazsoc_of is null  and
       d_bdbsr080.nomgrr_of    is null  then
       continue foreach
    end if

    #---------------------------------------------------------------
    # Busca nome do segurado
    #---------------------------------------------------------------
    open  c_gsakseg using  ws.segnumdig
    fetch c_gsakseg into   d_bdbsr080.segnom
    close c_gsakseg

    #---------------------------------------------------------------
    # Obtem Cidade/UF DO SEGURADO
    #---------------------------------------------------------------
    open  c_gsakend using  ws.segnumdig
    fetch c_gsakend into   d_bdbsr080.endcid, d_bdbsr080.endufd,
                           d_bdbsr080.dddcod, d_bdbsr080.teltxt
    close c_gsakend

    #---------------------------------------------------------------
    # Busca Tel Origem
    #---------------------------------------------------------------
    open  c_datmlcl_ori using  d_bdbsr080.atdsrvnum, d_bdbsr080.atdsrvano
    fetch c_datmlcl_ori into   d_bdbsr080.lcldddcod, d_bdbsr080.lcltelnum
    close c_datmlcl_ori

    #---------------------------------------------------------------
    # Busca LOCAL
    #---------------------------------------------------------------
    initialize d_bdbsr080.ofnnumdigdest to null
    open  c_datmlcl using  d_bdbsr080.atdsrvnum, d_bdbsr080.atdsrvano
    fetch c_datmlcl into   d_bdbsr080.lclidttxt, d_bdbsr080.lgdnom,
                           d_bdbsr080.brrnom   , d_bdbsr080.cidnom,
                           d_bdbsr080.ufdcod   , d_bdbsr080.ofnnumdigdest
    if d_bdbsr080.ofnnumdigdest is null then
       let d_bdbsr080.ofnnumdigdest = 0
    end if
    close c_datmlcl

    #---------------------------------------------------------------
    # Busca se a oficina e credenciada ou nao
    #---------------------------------------------------------------
    initialize d_bdbsr080.creddestino   to null
    open  c_sgokofi using  d_bdbsr080.ofnnumdigdest
    fetch c_sgokofi into   ws.ofncrdflg,ws.ofncvnflg
    if sqlca.sqlcode = 0 then
       if ws.ofncrdflg = "S" then
          let d_bdbsr080.creddestino = "SIM"
       else
          let d_bdbsr080.creddestino = "NAO"
       end if
    else
          let d_bdbsr080.creddestino = "NAO"
    end if
    close c_sgokofi

    initialize d_bdbsr080.credprocesso  to null
    open  c_sgokofi using  d_bdbsr080.ofnnumdigproc
    fetch c_sgokofi into   ws.ofncrdflg,ws.ofncvnflg
    if sqlca.sqlcode = 0 then
       if ws.ofncrdflg = "S" then
          let d_bdbsr080.credprocesso = "SIM"
       else
          let d_bdbsr080.credprocesso = "NAO"
       end if
    else
          let d_bdbsr080.credprocesso = "NAO"
    end if
    close c_sgokofi

    #---------------------------------------------------------------
    # Define o tipo do relatorio
    #---------------------------------------------------------------
    let d_bdbsr080.tiporel      =  0
    initialize d_bdbsr080.tiporeldes to null
    if d_bdbsr080.ofnnumdigproc =  d_bdbsr080.ofnnumdigdest then
       let d_bdbsr080.tiporel   =  3
       let d_bdbsr080.tiporeldes = "OK"
    end if
    if d_bdbsr080.ofnnumdigproc <> d_bdbsr080.ofnnumdigdest then
       let d_bdbsr080.tiporel   =  1
       let d_bdbsr080.tiporeldes = "OFICINA DIF."
    end if
    if d_bdbsr080.ofnnumdigproc is null then
       let d_bdbsr080.tiporel   =  2
       let d_bdbsr080.tiporeldes = "SEM PROCESSO"
    end if

    #---------------------------------------------------------------
    # Busca nome prestador
    #---------------------------------------------------------------
    open  c_dpaksocor using d_bdbsr080.atdprscod
    fetch c_dpaksocor into  d_bdbsr080.nomrazsoc
    close c_dpaksocor

    #---------------------------------------------------------------
    # Busca nome motorista
    #---------------------------------------------------------------
    open  c_datksrr using d_bdbsr080.srrcoddig
    fetch c_datksrr into  d_bdbsr080.srrabvnom
    close c_datksrr

    #---------------------------------------------------------------
    # Busca sigla veiculo
    #---------------------------------------------------------------
    if d_bdbsr080.atdvclsgl is null then
       open  c_datkveiculo using ws.socvclcod
       fetch c_datkveiculo into  d_bdbsr080.atdvclsgl
       close c_datkveiculo
    end if

    output to report bdbsr080_rel(d_bdbsr080.*)

    initialize d_bdbsr080.* to null

 end foreach

 finish report bdbsr080_rel

 let ws.comando = "Relatorio_Oficinas_indicadas"
 let l_retorno = ctx22g00_envia_email("BDBSR080",
                                      ws.comando,
                                      ws.pathrel01)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display "Erro ao enviar email(ctx22g00) - ",ws.pathrel01
    else
       display "Nao foi encontrado email para o modulo BDBSR080"
    end if
 end if


 #let ws.comando = "uuencode ", ws.pathrel01  clipped, " ",
 #                              ws.pathrel01  clipped, ".xls | remsh U07 ",
 #                 "mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
 #                 " -s 'Relatorio_Oficinas_indicadas' ",
 #                 "Ct24hs_Relatorios/spaulo_ct24hs_teleatendimento@u55"
 #run ws.comando

end function #  bdbsr080


#----------------------------------------------------------------------------#
 report bdbsr080_rel(r_bdbsr080)
#----------------------------------------------------------------------------#

 define r_bdbsr080    record
    tiporel           dec(1,0),
    tiporeldes        char (41),
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atddat            like datmservico.atddat,
    atdprscod         like datmservico.atdprscod,
    atdvclsgl         like datmservico.atdvclsgl,
    srrcoddig         like datmservico.srrcoddig,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    srrabvnom         like datksrr.srrabvnom,
    segnom            like gsakseg.segnom,
    endcid            like gsakend.endcid,
    endufd            like gsakend.endufd,
    dddcod            like gsakend.dddcod,
    teltxt            like gsakend.teltxt,
    lclidttxt         like datmlcl.lclidttxt,
    lgdnom            like datmlcl.lgdnom,
    brrnom            like datmlcl.brrnom,
    cidnom            like datmlcl.cidnom,
    ufdcod            like datmlcl.ufdcod,
    lcldddcod         like datmlcl.dddcod,
    lcltelnum         like datmlcl.lcltelnum,
    sinano            like ssamsin.sinano,         # ano processo
    sinnum            like ssamsin.sinnum,         # nr. processo
    ofnnumdigproc     like svomroteiro.ofnnumdig,  # codigo oficina processo
    sinlaudat         like svomroteiro.sinlaudat,  # data do processo
    ofnnumdigdest     like datmlcl.ofnnumdig    ,  # codigo oficina destino
    nomrazsoc_of      like gkpkpos.nomrazsoc,      # razao oficina
    nomgrr_of         like gkpkpos.nomgrr,         # fantasia oficina
    endlgd_of         like gkpkpos.endlgd,         # end oficina
    endbrr_of         like gkpkpos.endbrr,         # bairro oficina
    endcid_of         like gkpkpos.endcid,         # cidade oficina
    endufd_of         like gkpkpos.endufd,         # UF oficina
    creddestino       char (03),
    credprocesso      char (03),
    ciaempcod         like datmservico.ciaempcod
 end record

 define h_bdbsr080   record
    c24txtseq        like datmservhist.c24txtseq,
    c24srvdsc        like datmservhist.c24srvdsc,
    c24funmat        like datmservhist.c24funmat,
    ligdat           like datmservhist.ligdat   ,
    lighorinc        like datmservhist.lighorinc
 end record

 define ws            record
    linha            char(3000),
    tab              char(1)
 end record

 define ws1           record
    c24srvdsc         like datmservhist.c24srvdsc,
    ligdat            like datmservhist.ligdat   ,
    lighorinc         like datmservhist.lighorinc,
    atdsrvnum         like datmservico.atdsrvnum ,
    funnom            like isskfunc.funnom
 end record

 define flag_hist       smallint

   output
      left   margin  000
      top    margin  000
      bottom margin  000

   order by r_bdbsr080.tiporel,
            r_bdbsr080.atdsrvnum,
            r_bdbsr080.atdsrvano
   format
      first page header
              let ws.tab = "	"
              print "TIPO", "	",
                    "SERVICO" , "	",
                    "DATA ATD", "	",
                    "DOCUMENTO","	",
                    "SEGURADO","	",
                    "FONE SEGURADO","	",
                    "FONE LOCAL","	",
                    "CIDADE DOMICILIO","	",
                    "OFICINA DESTINO","	",
                    "CREDENCIADA","	",
                    "ENDER.","	",
                    "BAIRRO","	",
                    "CIDADE","	",
                    "Nr.PROCESSO","	",
                    "DATA", "	",
                    "OFICINA PROCESSO","	",
                    "CREDENCIADA","	",
                    "FANTASIA","	",
                    "ENDER.","	",
                    "BAIRRO","	",
                    "CIDADE","	",
                    "PRESTADOR","	",
                    "MOTORISTA","	",
                    "SIGLA VEICULO","	",
                    "HISTORICO","	"
      on every row
           let ws.linha = r_bdbsr080.tiporeldes clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.atdsrvorg  using "&&",
                 "/", r_bdbsr080.atdsrvnum  using "&&&&&&&",
                 "-", r_bdbsr080.atdsrvano  using "&&",
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.atddat,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.ramcod     using "&&&&"       ,"/",
                 r_bdbsr080.succod     using "&&"         ,"/",
                 r_bdbsr080.aplnumdig  using "<<<<<<<& &" ,"/",
                 r_bdbsr080.itmnumdig  using "<<<<<& &" ,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.segnom clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 "(",r_bdbsr080.dddcod,") ",
                 r_bdbsr080.teltxt clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 "(",r_bdbsr080.lcldddcod,") ",
                 r_bdbsr080.lcltelnum clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.endcid clipped, "  ",
                 r_bdbsr080.endufd ,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.ofnnumdigdest using "#######","-",
                 r_bdbsr080.lclidttxt  clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.creddestino clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.lgdnom  clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.brrnom  clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.cidnom  clipped , "  ",
                 r_bdbsr080.ufdcod  ,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.sinnum using "##########", "  ",
                 ##r_bdbsr080.sinano using "####",
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.sinlaudat,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.ofnnumdigproc using "#######","-",
                 r_bdbsr080.nomrazsoc_of clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.credprocesso,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.nomgrr_of     clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.endlgd_of     clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.endbrr_of     clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.endcid_of  clipped , "  ",
                 r_bdbsr080.endufd_of    ,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.atdprscod using "#####" , "-",
                 r_bdbsr080.nomrazsoc[1,40]  clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.srrabvnom  clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdbsr080.atdvclsgl ,
                 ws.tab

           # MONTA HISTORICO
           let flag_hist = 0
           declare c_historico cursor for
            select ligdat, lighorinc, c24funmat, c24srvdsc
              from datmservhist
             where datmservhist.atdsrvnum = r_bdbsr080.atdsrvnum
               and datmservhist.atdsrvano = r_bdbsr080.atdsrvano

           foreach c_historico into  h_bdbsr080.ligdat   ,
                                     h_bdbsr080.lighorinc,
                                     h_bdbsr080.c24funmat,
                                     h_bdbsr080.c24srvdsc

              if ws1.atdsrvnum <> r_bdbsr080.atdsrvnum  or
                 ws1.ligdat    <> h_bdbsr080.ligdat     or
                 ws1.lighorinc <> h_bdbsr080.lighorinc  then
                 select funnom
                   into ws1.funnom
                   from isskfunc
                  where isskfunc.funmat = h_bdbsr080.c24funmat
                    and isskfunc.empcod = 1

                 let ws1.c24srvdsc = "EM: "   , h_bdbsr080.ligdat    clipped,
                                     "  AS: " , h_bdbsr080.lighorinc clipped,
                                     "  POR: ", ws1.funnom           clipped
                 let ws1.atdsrvnum = r_bdbsr080.atdsrvnum
                 let ws1.ligdat    = h_bdbsr080.ligdat
                 let ws1.lighorinc = h_bdbsr080.lighorinc

                 let ws.linha = ws.linha clipped, " ", ws1.c24srvdsc
              end if
              let ws.linha = ws.linha clipped, " ", h_bdbsr080.c24srvdsc
              let flag_hist = 1
           end foreach

           # IMPRIME LINHA
           print ws.linha

end report  ###  bdbsr080_rel

