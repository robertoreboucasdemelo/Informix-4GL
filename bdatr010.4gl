###############################################################################
# Nome do Modulo: BDATR010                                           Gilberto #
#                                                                     Marcelo #
# Relacao de comunicados de localizacao de veiculos segurados        Out/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL     DESCRICAO                          #
#-----------------------------------------------------------------------------#
# 01/04/1999  PSI 8087-0   Wagner          Incluir no relatorio o codigo do   #
#                                          servico e o tipo do servico.       #
#-----------------------------------------------------------------------------#
# 17/02/2000  PSI 10079-0  Gilberto        Substituir tipo de solicitante pelo#
#                                          novo campo criado (c24soltipcod).  #
#-----------------------------------------------------------------------------#
# 13/04/2000  Chamado      Ruiz            Nao Imprimi letras minusculas.     #
#-----------------------------------------------------------------------------#
# 14/07/2000  PSI 10865-0  Ruiz            Alteracao do tamanho do campo      #
#                                          atdsrvnum de 6 p/ 10.              #
#                                          Troca do campo atdtip p/ atdsrvorg.#
#-----------------------------------------------------------------------------#
# Alterado : 23/07/2002 - Celso                                               #
#            Utilizacao da funcao    fgckc811 para enderecamento de corretores#
#-----------------------------------------------------------------------------#
# 30/09/2002  Chamado      Raji            Set isolation nos registros.       #
#.............................................................................#
#                                                                             #
#                     * * * Alteracoes * * *                                  #
#                                                                             #
# Data        Autor Fabrica  Origem       Alteracao                           #
# ----------  -------------- ---------    ------------------------------------#
# 10/09/2005  Julianna, Meta Melhorias    Melhorias de performance            #
#-----------------------------------------------------------------------------#
# 01/12/2006 Alberto Rodrigues  PSI205206 Nao foi alterado, pois, assuntos p/ #
#                                         Azul nao tem como agrupar(K15/K16)  #
#-----------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define ws_traco      char (80)
 define ws_data       date
 define ws_cctcod     like igbrrelcct.cctcod
 define ws_relviaqtd  like igbrrelcct.relviaqtd

 main
    call fun_dba_abre_banco('CT24HS')
    call bdatr010()
 end main

#---------------------------------------------------------------
 function  bdatr010()
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

 define d_bdatr010    record
    lignum            like datmligacao.lignum,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    segnom            like gsakseg.segnom,
    dddcodseg         like gsakend.dddcod,
    teltxtseg         like gsakend.teltxt,
    corsus            like gcaksusep.corsus,
    cornom            like gcakcorr.cornom,
    dddcodcor         like gcakfilial.dddcod,
    teltxtcor         like gcakfilial.teltxt,
    funnom            like isskfunc.funnom,
    ligdat            like datmligacao.ligdat,
    lighorinc         like datmligacao.lighorinc,
    c24astdes         char (65),
    ramcod            like datrligapol.ramcod,
    succod            like datrligapol.succod,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    vcllicnum         like abbmveic.vcllicnum,
    vclanofbc         like abbmveic.vclanofbc,
    vclanomdl         like abbmveic.vclanomdl,
    vcldes            char (80),
    chassi            char (20),
    atdsrvnum         like datmligacao.atdsrvnum,
    atdsrvano         like datmligacao.atdsrvano,
    sitatucod         smallint
 end record

 define ws            record
    comando           char(600),
    segnumdig         like gsakseg.segnumdig,
    vclcoddig         like abbmveic.vclcoddig,
    vclchsinc         like abbmveic.vclchsinc,
    vclchsfnl         like abbmveic.vclchsfnl,
    c24funmat         like datmligacao.c24funmat,
    c24soltipcod      like datmligacao.c24soltipcod,
    ligdat            like datmligacao.ligdat,
    vclmrcnom         like agbkmarca.vclmrcnom,
    vcltipnom         like agbktip.vcltipnom,
    vclmdlnom         like agbkveic.vclmdlnom,
    c24astcod         like datmligacao.c24astcod,
    c24agpdes         like datkastagp.c24astagpdes,
    auxdat            char (10),
    dirfisnom         like ibpkdirlog.dirfisnom  ,
    pathrel01         char (60)
 end record


 #---------------------------------------------------------------
 # Inicializacao das variaveis
 #---------------------------------------------------------------
 initialize d_bdatr010.*  to null
 initialize ws.*          to null

 let ws_traco = "-------------------------------------------------------------------------------"

 #---------------------------------------------------------------
 # Definicao da data-parametro
 #---------------------------------------------------------------

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

 let ws_data  = ws.auxdat

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT01001"

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDAT01001")
      returning  ws_cctcod,
         	 ws_relviaqtd
 #---------------------------------------------------------------
 # Preparacao dos comandos SQL
 #---------------------------------------------------------------
 set isolation to dirty read;
 let ws.comando = "select funnom",
                  "  from isskfunc",
                  " where empcod = 1",
                  "   and funmat = ?"
 prepare sql_isskfunc from ws.comando
 declare c_isskfunc cursor for sql_isskfunc

 let ws.comando = "select c24soltipdes",
                  "  from datksoltip  ",
                  " where c24soltipcod = ?"
 prepare sql_datksoltip from ws.comando
 declare c_datksoltip cursor for sql_datksoltip

 let ws.comando = "select segnom",
                  "  from gsakseg",
                  " where segnumdig = ?"
 prepare sql_gsakseg from   ws.comando
 declare c_gsakseg   cursor for  sql_gsakseg

 let ws.comando = "select segnumdig",
                  "  from abbmdoc",
                  " where succod    = ? ",
                  "   and aplnumdig = ? ",
                  "   and itmnumdig = ? ",
                  "   and dctnumseq = ? "
 prepare sel_abbmdoc  from ws.comando
 declare c_abbmdoc  cursor for sel_abbmdoc

 let ws.comando = "select dddcod, teltxt",
                  "  from gsakend",
                  " where gsakend.segnumdig = ?",
                  "   and gsakend.endfld    = '1'"
 prepare sql_gsakend from   ws.comando
 declare c_gsakend   cursor for  sql_gsakend

 let ws.comando = "select corsus",
                  "  from abamcor",
                  " where abamcor.succod    = ? ",
                  "   and abamcor.aplnumdig = ? ",
                  "   and abamcor.corlidflg = 'S'"
 prepare sql_abamcor from   ws.comando
 declare c_abamcor   cursor for  sql_abamcor

 let ws.comando = " select cornom",
                  "   from gcaksusep, gcakcorr",
                  "  where gcaksusep.corsus     = ? ",
                  "    and gcakcorr.corsuspcp   = gcaksusep.corsuspcp"
 prepare sql_gcaksusep from   ws.comando
 declare c_gcaksusep   cursor for  sql_gcaksusep

 let ws.comando = "select vclcoddig, vclchsinc,",
                  "       vclchsfnl, vcllicnum,",
                  "       vclanofbc, vclanomdl",
                  "  from abbmveic",
                  " where abbmveic.succod     = ?",
                  "   and abbmveic.aplnumdig  = ?",
                  "   and abbmveic.itmnumdig  = ?",
                  "   and abbmveic.dctnumseq  = ?"
 prepare sql_abbmveic from   ws.comando
 declare c_abbmveic   cursor for  sql_abbmveic

 let ws.comando = "select vclcoddig, vclchsinc,",
                  "       vclchsfnl, vcllicnum,",
                  "       vclanofbc, vclanomdl",
                  "  from abbmveic",
                  " where abbmveic.succod     = ?",
                  "   and abbmveic.aplnumdig  = ?",
                  "   and abbmveic.itmnumdig  = ?",
                  "   and abbmveic.dctnumseq  = ",
                  "       (select max(dctnumseq)",
                  "          from abbmveic",
                  "         where abbmveic.succod     = ?",
                  "           and abbmveic.aplnumdig  = ?",
                  "           and abbmveic.itmnumdig  = ?)"
 prepare sql_abbmveic2 from   ws.comando
 declare c_abbmveic2   cursor for  sql_abbmveic2

 let ws.comando = "select vclmrcnom,",
                  "       vcltipnom,",
                  "       vclmdlnom",
                  "  from agbkveic, agbkmarca, agbktip",
                  " where agbkveic.vclcoddig = ?",
                  "   and agbkmarca.vclmrccod = agbkveic.vclmrccod",
                  "   and agbktip.vclmrccod   = agbkveic.vclmrccod",
                  "   and agbktip.vcltipcod   = agbkveic.vcltipcod"
 prepare sql_veiculo from   ws.comando
 declare c_veiculo   cursor for  sql_veiculo

 let ws.comando = "select nom      , corsus   ,",
                  "       cornom   , vcldes   ,",
                  "       vcllicnum, vclanomdl ",
                  "  from datmservico",
                  " where datmservico.atdsrvnum  = ?",
                  "   and datmservico.atdsrvano  = ?"
 prepare sql_datmservico from   ws.comando
 declare c_datmservico   cursor for  sql_datmservico

 let ws.comando = "select datkassunto.c24astdes,   ",
                  "       datkastagp.c24astagpdes  ",
                  "  from datkassunto, datkastagp  ",
                  " where datkassunto.c24astcod = ?",
                  "   and datkastagp.c24astagp = datkassunto.c24astagp"
 prepare select_assunto  from ws.comando
 declare c_assunto cursor for select_assunto

 let ws.comando = "select datmservico.atdsrvnum,",
                  "       datmservico.atdsrvano,",
                  "       datmservicocmp.c24sintip",
                  "  from datrservapol, datmservico, datmservicocmp",
                  " where datrservapol.succod      = ? ",
                  "   and datrservapol.ramcod      = ? ",
                  "   and datrservapol.aplnumdig   = ? ",
                  "   and datrservapol.itmnumdig   = ? ",
                  "   and datmservico.atdsrvnum = datrservapol.atdsrvnum",
                  "   and datmservico.atdsrvano = datrservapol.atdsrvano",
                  "   and datmservico.atdsrvorg = 11  ",
                  "   and datmservicocmp.atdsrvnum =  datmservico.atdsrvnum",
                  "   and datmservicocmp.atdsrvano =  datmservico.atdsrvano"
 prepare sql_datmservicocmp  from ws.comando
 declare c_datmservicocmp cursor for sql_datmservicocmp

 declare c_bdatr010   cursor for
    select datmligacao.c24astcod,
           datmligacao.lignum   ,
           datmligacao.c24solnom,
           datmligacao.c24soltipcod,
           datmligacao.c24funmat,
           datmligacao.ligdat   ,
           datmligacao.lighorinc,
           datmligacao.atdsrvnum,
           datmligacao.atdsrvano,
           datrligapol.ramcod   ,
           datrligapol.succod   ,
           datrligapol.aplnumdig,
           datrligapol.itmnumdig
      from datmligacao, outer datrligapol
     where datmligacao.ligdat     =  ws_data
       and datmligacao.c24astcod in ("L10","L11","L12","L45") ## PSI205206 nao alterado(K15/16)
       and datrligapol.lignum     =  datmligacao.lignum

 start report  rep_localiz  to  ws.pathrel01

 foreach c_bdatr010  into  ws.c24astcod,
                           d_bdatr010.lignum,
                           d_bdatr010.c24solnom,
                           ws.c24soltipcod,
                           ws.c24funmat,
                           d_bdatr010.ligdat,
                           d_bdatr010.lighorinc,
                           d_bdatr010.atdsrvnum,
                           d_bdatr010.atdsrvano,
                           d_bdatr010.ramcod,
                           d_bdatr010.succod,
                           d_bdatr010.aplnumdig,
                           d_bdatr010.itmnumdig

      let d_bdatr010.c24soltipdes = "** NAO INFORMADO **"

      open  c_datksoltip using ws.c24soltipcod
      fetch c_datksoltip into  d_bdatr010.c24soltipdes
      close c_datksoltip

      #--------------------------------------------------------------
      # Descricao do codigo do assunto da ligacao
      #--------------------------------------------------------------
      initialize d_bdatr010.c24astdes  to null
      initialize ws.c24agpdes          to null

      open  c_assunto using ws.c24astcod
      fetch c_assunto into  d_bdatr010.c24astdes,
                            ws.c24agpdes
      close c_assunto

      let d_bdatr010.c24astdes = ws.c24agpdes clipped, " ",
                                 d_bdatr010.c24astdes

      #--------------------------------------------------------------
      # Ler nome do funcionario (atendente)
      #--------------------------------------------------------------
      initialize d_bdatr010.funnom      to null

      open  c_isskfunc  using  ws.c24funmat
      fetch c_isskfunc  into   d_bdatr010.funnom
      if sqlca.sqlcode < 0 then
         display "Erro (", sqlca.sqlcode, ") leitura do nome do funcionario"
         continue foreach
      end if
      close c_isskfunc

      #--------------------------------------------------------------
      # Ler ultima situacao da apolice
      #--------------------------------------------------------------
      initialize ws.segnumdig          to null
      initialize ws.vclchsinc          to null
      initialize ws.vclchsfnl          to null
      initialize ws.vclcoddig          to null
      initialize d_bdatr010.segnom     to null
      initialize d_bdatr010.dddcodseg  to null
      initialize d_bdatr010.teltxtseg  to null
      initialize d_bdatr010.corsus     to null
      initialize d_bdatr010.cornom     to null
      initialize d_bdatr010.dddcodcor  to null
      initialize d_bdatr010.teltxtcor  to null
      initialize d_bdatr010.vcldes     to null
      initialize d_bdatr010.vcllicnum  to null
      initialize d_bdatr010.chassi     to null
      initialize d_bdatr010.vclanomdl  to null
      initialize d_bdatr010.vclanofbc  to null

      if d_bdatr010.succod      is not null   and
         d_bdatr010.aplnumdig   is not null   and
         d_bdatr010.itmnumdig   is not null   then

         call f_funapol_ultima_situacao
              (d_bdatr010.succod, d_bdatr010.aplnumdig, d_bdatr010.itmnumdig)
              returning g_funapol.*

         #--------------------------------------------------------------
         # Ler dados cadastrais do segurado
         #--------------------------------------------------------------
         open  c_abbmdoc  using d_bdatr010.succod   , d_bdatr010.aplnumdig,
                                d_bdatr010.itmnumdig, g_funapol.dctnumseq
         fetch c_abbmdoc  into  ws.segnumdig
         if sqlca.sqlcode < 0 then
            display "Erro (", sqlca.sqlcode, ") leitura do codigo do segurado"
            continue foreach
         end if
         close c_abbmdoc

         open  c_gsakseg  using  ws.segnumdig
         fetch c_gsakseg  into   d_bdatr010.segnom
         if sqlca.sqlcode < 0 then
            display "Erro (", sqlca.sqlcode, ") leitura do nome do segurado"
            continue foreach
         end if
         close c_gsakseg

         open  c_gsakend  using  ws.segnumdig
         fetch c_gsakend  into   d_bdatr010.dddcodseg,
                                 d_bdatr010.teltxtseg
         if sqlca.sqlcode < 0 then
            display "Erro (", sqlca.sqlcode, ") leitura do endereco do segurado"
            continue foreach
         end if
         close c_gsakend

         #--------------------------------------------------------------
         # Ler dados cadastrais do corretor
         #--------------------------------------------------------------
         open  c_abamcor  using  d_bdatr010.succod,
                                 d_bdatr010.aplnumdig
         fetch c_abamcor  into   d_bdatr010.corsus
         if sqlca.sqlcode < 0 then
            display "Erro (", sqlca.sqlcode, ") leitura do corretor da apolice"
            continue foreach
         end if
         close c_abamcor

         if sqlca.sqlcode = notfound   then
            let d_bdatr010.cornom = "** CORRETOR NAO CADASTRADO **"
         else

            open  c_gcaksusep  using  d_bdatr010.corsus
            fetch c_gcaksusep  into   d_bdatr010.cornom
            if sqlca.sqlcode < 0 then
               display "Erro (", sqlca.sqlcode, ") leitura dados do corretor"
               continue foreach
            end if
            close c_gcaksusep

            #---> Utilizacao da nova funcao de comissoes p/ enderecamento
            initialize r_gcakfilial.* to null
            call fgckc811(d_bdatr010.corsus)
                 returning r_gcakfilial.*
            let d_bdatr010.dddcodcor = r_gcakfilial.dddcod
            let d_bdatr010.teltxtcor = r_gcakfilial.teltxt
            #------------------------------------------------------------

         end if

         #--------------------------------------------------------------
         # Ler dados do veiculo da apolice
         #--------------------------------------------------------------
         if g_funapol.vclsitatu  is not null   and
            g_funapol.vclsitatu  <> 0          then
            open  c_abbmveic  using  d_bdatr010.succod,
                                     d_bdatr010.aplnumdig,
                                     d_bdatr010.itmnumdig,
                                     g_funapol.vclsitatu
            fetch c_abbmveic  into   ws.vclcoddig,
                                     ws.vclchsinc,
                                     ws.vclchsfnl,
                                     d_bdatr010.vcllicnum,
                                     d_bdatr010.vclanofbc,
                                     d_bdatr010.vclanomdl
            if sqlca.sqlcode < 0 then
               display "Erro (", sqlca.sqlcode, ") leitura do veiculo"
               continue foreach
            end if
            close c_abbmveic
         else

            open  c_abbmveic2  using  d_bdatr010.succod,
                                      d_bdatr010.aplnumdig,
                                      d_bdatr010.itmnumdig,
                                      d_bdatr010.succod,
                                      d_bdatr010.aplnumdig,
                                      d_bdatr010.itmnumdig
            fetch c_abbmveic2  into   ws.vclcoddig,
                                      ws.vclchsinc,
                                      ws.vclchsfnl,
                                      d_bdatr010.vcllicnum,
                                      d_bdatr010.vclanofbc,
                                      d_bdatr010.vclanomdl
            if sqlca.sqlcode < 0 then
               display "Erro (", sqlca.sqlcode, ") leitura do veiculo 2"
               continue foreach
            end if
            close c_abbmveic2
         end if

         let d_bdatr010.chassi = ws.vclchsinc, ws.vclchsfnl

         if ws.vclcoddig  is not null   then
            open  c_veiculo  using  ws.vclcoddig
            fetch c_veiculo  into   ws.vclmrcnom,
                                    ws.vcltipnom,
                                    ws.vclmdlnom
            if sqlca.sqlcode < 0 then
               display "Erro (", sqlca.sqlcode, ") leitura descricao do veiculo"
               continue foreach
            end if
            close c_veiculo
            let d_bdatr010.vcldes = ws.vclmrcnom clipped, " ",
                                    ws.vcltipnom clipped, " ",
                                    ws.vclmdlnom
         end if
      else
         #--------------------------------------------------------------
         # Localizacao de veiculo com guincho (Laudo em Branco)
         #--------------------------------------------------------------
         if d_bdatr010.atdsrvnum  is not null   and
            d_bdatr010.atdsrvano  is not null   then

            open  c_datmservico  using  d_bdatr010.atdsrvnum,
                                        d_bdatr010.atdsrvano
            fetch c_datmservico  into   d_bdatr010.segnom,
                                        d_bdatr010.corsus,
                                        d_bdatr010.cornom,
                                        d_bdatr010.vcldes,
                                        d_bdatr010.vcllicnum,
                                        d_bdatr010.vclanomdl
            if sqlca.sqlcode < 0 then
               display "Erro (", sqlca.sqlcode, ") leitura dos dados do servico"
               continue foreach
            end if
            close c_datmservico
         else
            continue foreach
         end if

      end if

      #--------------------------------------------------------------
      # Interface com o sistema da Replace
      #--------------------------------------------------------------
      initialize d_bdatr010.sitatucod  to null
      if ws.vclcoddig  is not null   then
         if ((ws.vclchsinc  is not null            and
              ws.vclchsfnl  is not null)           or
             (d_bdatr010.vcllicnum  is not null))  then

               call srpf008(ws.vclcoddig, ws.vclchsinc, ws.vclchsfnl,
                            d_bdatr010.vcllicnum, ws.c24funmat)
                    returning d_bdatr010.sitatucod
         end if
      end if

      output to report rep_localiz(d_bdatr010.*)

 end foreach

 finish report  rep_localiz

 end function  ###  bdatr010


#---------------------------------------------------------------------------
 report rep_localiz(r_bdatr010)
#---------------------------------------------------------------------------

 define r_bdatr010    record
    lignum            like datmligacao.lignum,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    segnom            like gsakseg.segnom,
    dddcodseg         like gsakend.dddcod,
    teltxtseg         like gsakend.teltxt,
    corsus            like gcaksusep.corsus,
    cornom            like gcakcorr.cornom,
    dddcodcor         like gcakfilial.dddcod,
    teltxtcor         like gcakfilial.teltxt,
    funnom            like isskfunc.funnom,
    ligdat            like datmligacao.ligdat,
    lighorinc         like datmligacao.lighorinc,
    c24astdes         char (65),
    ramcod            like datrligapol.ramcod,
    succod            like datrligapol.succod,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    vcllicnum         like abbmveic.vcllicnum,
    vclanofbc         like abbmveic.vclanofbc,
    vclanomdl         like abbmveic.vclanomdl,
    vcldes            char (80),
    chassi            char (20),
    atdsrvnum         like datmligacao.atdsrvnum,
    atdsrvano         like datmligacao.atdsrvano,
    sitatucod         smallint
 end record

 define r_bdatr010h   record
    c24txtseq         like datmlighist.c24txtseq,
    c24ligdsc         char (70),
    c24funmat         like datmlighist.c24funmat,
    ligdat            like datmlighist.ligdat   ,
    lighorinc         like datmlighist.lighorinc
 end record

 define ws2           record
    comando           char(300),
    hfunnom           like isskfunc.funnom,
    hlinha            char (70),
    hligdatn          like datmlighist.ligdat,
    hlighorn          like datmlighist.lighorinc,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdsrvorg         like datmservico.atdsrvorg,
    c24sintip         like datmservicocmp.c24sintip,
    tiposrv           char (12),
    sitatudes         char (30),
    barra             char (1)
 end record


 output
    left   margin  00
    right  margin  80
    top    margin  00
    bottom margin  00
    page   length  80

 order by  r_bdatr010.segnom

 format
    page header
         if pageno  =  1   then
            print "OUTPUT JOBNAME=DAT01001 FORMNAME=BRANCO"
            print "HEADER PAGE"
            print "       JOBNAME= CT24HS - COMUNICADOS DE LOCALIZACAO"
            print "$DJDE$ JDL=XJ0030, JDE=XD0031, FORMS=XF6560, COPIES=",ws_relviaqtd using "&&", ", DEPT='", ws_cctcod using "&&&", "', END;"

            print ascii(12)

            let ws2.comando = "select funnom",
                             "  from isskfunc",
                             " where succod =  '01'",
                             "   and funmat = ? "
            prepare sql_isskfunc2 from   ws2.comando
            declare c_isskfunc2   cursor for  sql_isskfunc2

            let ws2.comando = "select ligdat   , lighorinc,",
                              "       c24funmat, c24ligdsc",
                              "  from datmlighist",
                              " where datmlighist.lignum = ? "
            prepare sql_datmlighist from   ws2.comando
            declare c_datmlighist   cursor for  sql_datmlighist

            let ws2.comando = "select ligdat   , lighorinc,",
                              "       c24funmat, c24srvdsc",
                              "  from datmservhist",
                              " where datmservhist.atdsrvnum = ? ",
                              "   and datmservhist.atdsrvano = ? "
            prepare sql_datmservhist from   ws2.comando
            declare c_datmservhist   cursor for  sql_datmservhist

            let ws2.comando = "select atdsrvorg      ",
                              "   from datmservico   ",
                              "  where atdsrvnum = ? ",
                              "    and atdsrvano = ? "
            prepare sql_datmservico1 from   ws2.comando
            declare c_datmservico1   cursor for  sql_datmservico1

         else
           print "$DJDE$ C LIXOLIXO, ;"
           print "$DJDE$ C LIXOLIXO, ;"
           print "$DJDE$ C LIXOLIXO, ;"
           print "$DJDE$ C LIXOLIXO, END ;"
           print ascii(12)
         end if
         print column 048, "RDAT010-01",
               column 062, "PAGINA : ", pageno using "##,###,###"
         print column 062, "DATA   : ", today

         print column 005,
               "COMUNICADOS DE LOCALIZACAO DE VEICULO EM : ", ws_data,
               column 062, "HORA   :   ", time
         skip 3 lines

    on every row
         initialize ws2.sitatudes  to null
         case r_bdatr010.sitatucod
              when  1    let ws2.sitatudes = "** A ATUALIZAR **"
              when  2    let ws2.sitatudes = "** JA ATUALIZADO **"
              when  3    let ws2.sitatudes = "** NAO HA REGISTRO **"
              when  4    let ws2.sitatudes = "** MAIS DE UM REGISTRO **"
              otherwise  let ws2.sitatudes = "** NAO PESQUISADO **"
         end case

         print column 001, "DOCUMENTO : ",
                           r_bdatr010.succod    using "&&"        , "/",
                           r_bdatr010.aplnumdig using "<<<<<<&& &", "/",
                           r_bdatr010.itmnumdig using "<<<<<& &",
               column 045, ws2.sitatudes
         skip 1 line

         initialize ws2.atdsrvnum, ws2.atdsrvano,
                    ws2.c24sintip, ws2.tiposrv    to null
         open    c_datmservicocmp  using  r_bdatr010.succod   ,
                                          r_bdatr010.ramcod   ,
                                          r_bdatr010.aplnumdig,
                                          r_bdatr010.itmnumdig

         foreach c_datmservicocmp  into ws2.atdsrvnum,
                                        ws2.atdsrvano,
                                        ws2.c24sintip
              let ws2.tiposrv = "TIPO : FURTO"
              if ws2.c24sintip = "R" then
                 let ws2.tiposrv = "TIPO : ROUBO"
              end if
              exit foreach
         end foreach

         let ws2.barra  =  "/"
         open c_datmservico1 using ws2.atdsrvnum,
                                   ws2.atdsrvano
         fetch c_datmservico1   into  ws2.atdsrvorg
         if sqlca.sqlcode < 0 then
            initialize ws2.atdsrvorg,ws2.barra to null
         end if

         print column 001, "SERVICO   : ",
                           ws2.atdsrvorg using "&&",    ws2.barra,
                           ws2.atdsrvnum using "&&&&&&&","-",
                           ws2.atdsrvano using "&&"    ,
               column 045, ws2.tiposrv
         skip 1 line

         print column 001, "SEGURADO  : ", r_bdatr010.segnom
         print column 001, "TELEFONE  : ", "(",r_bdatr010.dddcodseg,") ",
               r_bdatr010.teltxtseg
         skip 1 line

         print column 001, "CORRETOR  : ", r_bdatr010.corsus, " - ",
               r_bdatr010.cornom
         print column 001, "TELEFONE  : ", "(",r_bdatr010.dddcodcor,") ",
               r_bdatr010.teltxtcor
       skip 1 lines

         print column 001,
               "----------------------------  DADOS DO VEICULO  -------------------------------"
         skip 1 line

         print column 001, "VEICULO   : ", r_bdatr010.vcldes
         print column 001, "FAB/MOD   : ", r_bdatr010.vclanofbc,"/",
               r_bdatr010.vclanomdl
         print column 001, "PLACA     : ", r_bdatr010.vcllicnum
         print column 001, "CHASSI    : ", r_bdatr010.chassi
         skip 1 lines

         print column 001,
               "--------------------------  DADOS DO ATENDIMENTO ------------------------------"
         skip 1 line

         print column 001, "INFORMANTE: ", r_bdatr010.c24solnom,
               column 040, "TIPO  : "    , r_bdatr010.c24soltipdes
         print column 001, "HORARIO   : ", r_bdatr010.ligdat, " AS ",
                                           r_bdatr010.lighorinc,
               column 040, "POR   : ",     upshift(r_bdatr010.funnom)
         print column 001, "ASSUNTO   : ", r_bdatr010.c24astdes
         skip 1 line

         let ws2.barra  =  "/"
         open c_datmservico1 using r_bdatr010.atdsrvnum,
                                   r_bdatr010.atdsrvano
         fetch c_datmservico1   into  ws2.atdsrvorg
         if sqlca.sqlcode < 0 then
            initialize ws2.atdsrvorg,ws2.barra to null
         end if

         print column 001, "NR.SERVICO: ", ws2.atdsrvorg        using "&&",
                                ws2.barra, r_bdatr010.atdsrvnum using "&&&&&&&",
                                      "-", r_bdatr010.atdsrvano using "&&"
         skip 1 lines

         print column 001,
               "---------------------------  DADOS DO HISTORICO -------------------------------"

         if r_bdatr010.atdsrvnum   is null   or
            r_bdatr010.atdsrvano   is null   then

            open  c_datmlighist  using  r_bdatr010.lignum

            foreach c_datmlighist into  r_bdatr010h.ligdat,
                                        r_bdatr010h.lighorinc,
                                        r_bdatr010h.c24funmat,
                                        r_bdatr010h.c24ligdsc

              if ws2.hligdatn <> r_bdatr010h.ligdat     or
                 ws2.hlighorn <> r_bdatr010h.lighorinc  then
                 open  c_isskfunc2  using  r_bdatr010h.c24funmat
                 fetch c_isskfunc2  into   ws2.hfunnom

                 let ws2.hlinha =  "EM: "   , r_bdatr010h.ligdat    clipped,
                                 "  AS: " , r_bdatr010h.lighorinc   clipped,
                                 "  POR: ", upshift(ws2.hfunnom)    clipped
                 let ws2.hligdatn = r_bdatr010h.ligdat
                 let ws2.hlighorn = r_bdatr010h.lighorinc
                 skip 1 line

                 print column 001,  ws2.hlinha
                 skip 1 line
              end if

              print column 001, upshift(r_bdatr010h.c24ligdsc)

            end foreach
         else

            open  c_datmservhist  using  r_bdatr010.atdsrvnum,
                                         r_bdatr010.atdsrvano

            foreach c_datmservhist into  r_bdatr010h.ligdat,
                                         r_bdatr010h.lighorinc,
                                         r_bdatr010h.c24funmat,
                                         r_bdatr010h.c24ligdsc

              if ws2.hligdatn <> r_bdatr010h.ligdat     or
                 ws2.hlighorn <> r_bdatr010h.lighorinc  then

                 open  c_isskfunc2  using  r_bdatr010h.c24funmat
                 fetch c_isskfunc2  into   ws2.hfunnom

                 let ws2.hlinha =  "EM: "   , r_bdatr010h.ligdat    clipped,
                                 "  AS: " , r_bdatr010h.lighorinc   clipped,
                                 "  POR: ", upshift(ws2.hfunnom)    clipped
                 let ws2.hligdatn = r_bdatr010h.ligdat
                 let ws2.hlighorn = r_bdatr010h.lighorinc
                 skip 1 line

                 print column 001,  ws2.hlinha
              end if

              print column 001, upshift(r_bdatr010h.c24ligdsc)

            end foreach
         end if

         skip to top of page

    on last  row
         print "$FIMREL$"

 end report  ###  rep_localiz
