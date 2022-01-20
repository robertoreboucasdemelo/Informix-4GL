###############################################################################
# Nome do Modulo: bdbsr340                                        Wagner      #
#                                                                             #
# Relatorio mensal de total de servicos RE pagos por ramo/cls     Mar/2002    #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 01/10/2002  Correio      Wagner       Troca de e-mail Francisco Castro p/   #
#                                       Roberto Costa.                        #
#-----------------------------------------------------------------------------#
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                          #
###############################################################################
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
# ----------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# ----------------------------------------------------------------------------#
# 29/09/2006 Priscila           PSI 202720 implementar cartao saude           #
# ---------- --------------------- ------ ------------------------------------#
# 14/02/2007 Fabiano, Meta      AS 130087 Migracao para a versao 7.32         #
#-----------------------------------------------------------------------------#
# 04/06/2007 Cristiane Silva    PSI207373 Atendimento clausulas 33,34,94      #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
###############################################################################

 database porto

 define ws_data_de     date,
        ws_data_ate    date,
        ws_data_aux    char(10),
        ws_flgcab1     integer

 main
    call bdbsr340_cria_log()
    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read
    set lock mode to wait 10

    call bdbsr340()
 end main

#---------------------------------------------------------------
 function bdbsr340()
#---------------------------------------------------------------

 define d_bdbsr340    record
    atdprscod         like datmservico.atdprscod,
    atdprstip         smallint,
    nomrazsoc         like dpaksocor.nomrazsoc,
    nomgrr            like dpaksocor.nomgrr,
    endcid            like dpaksocor.endcid,
    endbrr            like dpaksocor.endbrr,
    endufd            like dpaksocor.endufd,
    endcep            like dpaksocor.endcep,
    qldgracod         like dpaksocor.qldgracod,
    cpodes            like iddkdominio.cpodes,
    atdsrvorg         like datmservico.atdsrvorg,
    atdcstvlr         like datmservico.atdcstvlr,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    clscod            char (04)
 end record

 define ws            record
    atdfnlflg         like datmservico.atdfnlflg,
    atdetpcod         like datmsrvacp.atdetpcod,
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    rodar               char (500)
 end record

 define sql_select    char(300)
 define l_retorno     smallint                                # Marcio Meta - PSI185035
 define l_mensagem    char(80)                                #PSI 202720
 define l_tpdocto     char(15)                                #PSI 202720
 define l_crtnum      like datrsrvsau.crtnum                  #PSI 202720
 define l_cntanvdat   like datksegsau.cntanvdat               #PSI 202720

 #---------------------------------------------------------------
 # Inicializacao das variaveis
 #---------------------------------------------------------------
 initialize d_bdbsr340.*  to null
 initialize ws.*          to null

 let l_mensagem = null                                    #PSI 202720
 let l_tpdocto = null                                     #PSI 202720
 let l_crtnum = null                                      #PSI 202720

 let ws_flgcab1 = 0

 #---------------------------------------------------------------
 # Preparacao dos comandos SQL
 #---------------------------------------------------------------
 let sql_select = "select nomrazsoc, nomgrr, endcid,    ",
                  "       endufd   , endcep, vlrtabflg, ",
                  "       endbrr, qldgracod             ",
                  "  from dpaksocor where pstcoddig = ? "
 prepare sel_guerra from sql_select
 declare c_guerra cursor for sel_guerra

 let sql_select = "select cpodes "
                 ,"  from iddkdominio "
                 ," where cponom = 'qldgracod' "
                 ,"   and cpocod = ? "

 prepare p_qualid from sql_select
 declare c_qualid cursor for p_qualid

 #---------------------------------------------------------------
 # Define o periodo de extracao
 #---------------------------------------------------------------
 let ws_data_aux = arg_val(1)

 if ws_data_aux is null       or
    ws_data_aux =  "  "       then
    let ws_data_aux = today
 else
    if length(ws_data_aux) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws_data_aux = "01","/",ws_data_aux[4,5],"/",ws_data_aux[7,10]
 let ws_data_ate = ws_data_aux
 let ws_data_ate = ws_data_ate - 1 units day

 let ws_data_aux = ws_data_ate
 let ws_data_aux = "01","/",ws_data_aux[4,5],"/",ws_data_aux[7,10]
 let ws_data_de  = ws_data_aux

#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
#WWWX call f_path("DAT", "RELATO")
#WWWX      returning ws.dirfisnom

#WWWX -->teste
#let ws.dirfisnom = "/rdat"
#WWWX --
                                                                     # Marcio Meta - PSI185035
 call f_path("DBS", "ARQUIVO")
    returning ws.dirfisnom

 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS34001.TXT"
                                                                     # Marcio Meta - PSI185035
 #---------------------------------------------------------------
 # Definicao de cursores para extracao
 #---------------------------------------------------------------
 declare  c_bdbsr340  cursor for
     #busca servicos de um OP no período definido que está EMITIDA e seja de RE
    select datmservico.atdsrvnum,
           datmservico.atdsrvano,
           datmservico.atdprscod,
           datmservico.atdsrvorg,
           datmservico.atdcstvlr
      from dbsmopg, dbsmopgitm, datmservico
     where dbsmopg.socfatpgtdat   between  ws_data_de and ws_data_ate
       and dbsmopg.socopgsitcod   =  7
       and dbsmopg.soctip         =  3
       and dbsmopgitm.socopgnum   =  dbsmopg.socopgnum
       and datmservico.atdsrvnum  =  dbsmopgitm.atdsrvnum
       and datmservico.atdsrvano  =  dbsmopgitm.atdsrvano

 start report  rep_prssrv  to  ws.pathrel01

 #---------------------------------------------------------------
 # Extracao dos servicos pagos no periodo
 #---------------------------------------------------------------
 foreach c_bdbsr340  into  d_bdbsr340.atdsrvnum,
                           d_bdbsr340.atdsrvano,
                           d_bdbsr340.atdprscod,
                           d_bdbsr340.atdsrvorg,
                           d_bdbsr340.atdcstvlr

    if d_bdbsr340.atdsrvorg  <> 9    then  # RE
       continue foreach
    end if

    if d_bdbsr340.atdcstvlr is null  then  #Custo do atendimento
       let d_bdbsr340.atdcstvlr = 0
    end if

    call cts20g11_identifica_tpdocto(d_bdbsr340.atdsrvnum,
                                     d_bdbsr340.atdsrvano)
         returning l_tpdocto

    if l_tpdocto = "APOLICE" then
       #se documento e apolice - pode ser apolice AUTO ou RE
       # entao buscar ramo na tabela de apolices
       call cts20g13_obter_apolice(d_bdbsr340.atdsrvnum,
                                   d_bdbsr340.atdsrvano)
            returning l_retorno,
                      l_mensagem,
                      d_bdbsr340.aplnumdig,
                      d_bdbsr340.succod,
                      d_bdbsr340.ramcod,
                      d_bdbsr340.itmnumdig
       if l_retorno <> 1 then
          #erro ao obter apolice auto ou RE
          continue foreach
       end if
       #se for do tipo apolice é AUTO ou RE, entao buscar clausula
       let d_bdbsr340.clscod = bdbsr340_clausulas(d_bdbsr340.succod,
                                                  d_bdbsr340.ramcod,
                                                  d_bdbsr340.aplnumdig,
                                                  d_bdbsr340.itmnumdig)
    else
       if l_tpdocto = "SAUDE" then
          #buscar cartao segurado
          call cts20g10_cartao(2,
                               d_bdbsr340.atdsrvnum,
                               d_bdbsr340.atdsrvano)
               returning l_retorno,
                         l_mensagem,
                         d_bdbsr340.succod,
                         d_bdbsr340.ramcod,
                         d_bdbsr340.aplnumdig,
                         l_crtnum

          #buscar plano do segurado e ramo
          call cta01m15_sel_datksegsau(4,
                                       l_crtnum,
                                       "",
                                       "",
                                       "" )
               returning l_retorno,
                         l_mensagem,
                         d_bdbsr340.clscod,    #plano do segurado
                         l_cntanvdat           #data vencimento do plano
       end if
    end if
    #PSI 202720 - fim

    output to report rep_prssrv(d_bdbsr340.*)

    #PSI 202720 - inicializar variaveis
    initialize d_bdbsr340.*  to null          #PSI 202720
    let l_crtnum = null

 end foreach

 finish report  rep_prssrv
                                                                 # Marcio Meta - PSI185035
 #------------------------------------------------------------------
 # E-MAIL PORTO SOCORRO
 #------------------------------------------------------------------
 let ws.rodar = ' RE mensal pagos por clausula '

 let l_retorno = ctx22g00_envia_email('BDBSR340',
                                       ws.rodar,
                                       ws.pathrel01)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display " Erro ao enviar email(ctx22g00)-", ws.pathrel01
    else
       display " Email nao encontrado para este modulo BDBSR340 "
    end if
 end if
                                                               # Marcio Meta - PSI185035

end function   ###  bdbsr340


#-------------------------------------------------------------------------------
 function bdbsr340_clausulas(param)
#-------------------------------------------------------------------------------

 define param    record
    succod       like datrservapol.succod,
    ramcod       like datrservapol.ramcod,
    aplnumdig    like datrservapol.aplnumdig,
    itmnumdig    like datrservapol.aplnumdig
 end record

 define ws      record
    clscod      like rsdmclaus.clscod      ,
    rsdclscod   like rsdmclaus.clscod      ,
    datclscod   like datrsocntzsrvre.clscod,
    sgrorg      like rsdmdocto.sgrorg      ,
    sgrnumdig   like rsdmdocto.sgrnumdig   ,
    prporg      like rsdmdocto.prporg      ,
    prpnumdig   like rsdmdocto.prpnumdig
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

 initialize ws.*  to null

 #se tem apolice
 if param.succod    is not null  and
    param.ramcod    is not null  and
    param.aplnumdig is not null  then
    # se apolice de auto
    if param.ramcod =  31 or
       param.ramcod = 531 then
       call f_funapol_ultima_situacao(param.succod,
                                      param.aplnumdig,
                                      param.itmnumdig)
                            returning w_funapol.*

       declare c_abbmclaus cursor for
        select clscod
          from abbmclaus
         where succod    = param.succod
           and aplnumdig = param.aplnumdig
           and itmnumdig = param.itmnumdig
           and dctnumseq = w_funapol.dctnumseq
           and clscod    in ("34A", "35A", "35R", "095",'033','33R') ## PSI207373
       #verifica se apolice tem clausulas de AUTO + casa
       foreach c_abbmclaus into ws.clscod
          exit foreach
       end foreach

    else  #se e apolice de RE
       #---------------------------------------------------------
       # Ramos Elementares
       #---------------------------------------------------------
       select sgrorg    , sgrnumdig
         into ws.sgrorg , ws.sgrnumdig
         from rsamseguro
        where succod    = param.succod
          and ramcod    = param.ramcod
          and aplnumdig = param.aplnumdig

       if sqlca.sqlcode = 0   then
          #---------------------------------------------------------
          # Procura situacao da apolice/endosso
          #---------------------------------------------------------
          select prporg    , prpnumdig
            into ws.prporg , ws.prpnumdig
            from rsdmdocto
           where sgrorg    = ws.sgrorg
             and sgrnumdig = ws.sgrnumdig
             and dctnumseq = (select max(dctnumseq)
                                from rsdmdocto
                               where sgrorg     = ws.sgrorg
                                 and sgrnumdig  = ws.sgrnumdig
                                 and prpstt     in (19,66,88))

          if sqlca.sqlcode = 0   then
             declare c_rsdmclaus2 cursor for
              select clscod
                from rsdmclaus
               where prporg     = ws.prporg
                 and prpnumdig  = ws.prpnumdig
                 and lclnumseq  = 1
                 and clsstt     = "A"

             let ws.clscod = 0

             foreach c_rsdmclaus2  into  ws.rsdclscod
                let ws.datclscod = ws.rsdclscod

                case param.ramcod
                   when 11
                      if (ws.datclscod = 13 or ws.datclscod = "13R") then
                         let ws.clscod = ws.datclscod
                      end if
                   when 111
                      if (ws.datclscod = 13 or ws.datclscod = "13R") then
                         let ws.clscod = ws.datclscod
                      end if
                   when 44
                      if (ws.datclscod = 20  or ws.datclscod = "20R")  or
                          ws.datclscod = 21  or
                          ws.datclscod = 22  or
                          ws.datclscod = 23  or
                         (ws.datclscod = 24  or ws.datclscod = "24R") then
                         if ws.datclscod > ws.clscod  then
                            let ws.clscod = ws.datclscod
                         end if
                      end if
                   when 118
                      if (ws.datclscod = 20    or ws.datclscod = "20R") or
                          ws.datclscod = 21    or
                          ws.datclscod = 22    or
                          ws.datclscod = 23    or
                         (ws.datclscod = 24    or ws.datclscod = "24C"  or ws.datclscod = "24R") or
                          ws.datclscod = 30    or
                         (ws.datclscod = 31    or ws.datclscod = "31C"  or ws.datclscod = "31R") or
                         (ws.datclscod = 32    or ws.datclscod = "32R") or
                         (ws.datclscod = 36    or ws.datclscod = "36R") or
                         (ws.datclscod = 38    or ws.datclscod = "38R") or   #  PSI-230.057 Inicio
                          ws.datclscod = "55"  or ws.datclscod = "56"   or
                          ws.datclscod = "56R" or ws.datclscod = "56C"  or
                          ws.datclscod = "57"  or ws.datclscod = "57R"  then #  PSI-230.057 Fim
                         #inclusao da cls 36/36R-a pedido Judite-08/05/07
                         if ws.datclscod > ws.clscod  then
                            let ws.clscod = ws.datclscod
                         end if
                      end if
                   when 45
                      if (ws.datclscod = 10  or ws.datclscod = "10R") or
                         (ws.datclscod = 11  or ws.datclscod = "11R")  or
                         (ws.datclscod = 12  or ws.datclscod = "12R")  or
                         (ws.datclscod = 13  or ws.datclscod = "13R") then
                         if ws.datclscod > ws.clscod  then
                            let ws.clscod = ws.datclscod
                         end if
                      end if
                   when 114
                      if (ws.datclscod = 08    or ws.datclscod = "08C"  or ws.datclscod = "08R" or
                          ws.datclscod = "8C"  or ws.datclscod = "8R")  or ## psi211044
                         (ws.datclscod = 10    or ws.datclscod = "10R") or
                         (ws.datclscod = 11    or ws.datclscod = "11R") or
                         (ws.datclscod = 12    or ws.datclscod = "12C"  or ws.datclscod = "12R") or
                         (ws.datclscod = 13    or ws.datclscod = "13R") or
                          ws.datclscod = 30    or
                         (ws.datclscod = 31    or ws.datclscod = "31C"  or ws.datclscod = "31R") or
                         (ws.datclscod = 32    or ws.datclscod = "32R") or
                          ws.datclscod = 39    or
                         (ws.datclscod = 40    or ws.datclscod = "40R") or   #  PSI-230.057 Inicio
                          ws.datclscod = "55"  or ws.datclscod = "56"   or
                          ws.datclscod = "56R" or ws.datclscod = "56C"  or
                          ws.datclscod = "57"  or ws.datclscod = "57R"  then #  PSI-230.057 Fim
                         #inclusao da cls 40/40R-a pedido Neia-07/05/07
                         if ws.datclscod > ws.clscod  then
                            let ws.clscod = ws.datclscod
                         end if
                      end if
                   when 46
                      if  ws.datclscod = 30  or
                         (ws.datclscod = 31  or ws.datclscod = "31R")  or
                         (ws.datclscod = 32  or ws.datclscod = "32R") then
                         if ws.datclscod > ws.clscod  then
                            let ws.clscod = ws.datclscod
                         end if
                      end if
                   when 746
                      if  ws.datclscod = 30    or
                         (ws.datclscod = 31    or ws.datclscod = "31C" or ws.datclscod = "31R") or
                         (ws.datclscod = 32    or ws.datclscod = "32R") then
                         if ws.datclscod > ws.clscod  then
                            let ws.clscod = ws.datclscod
                         end if
                      end if
                   when 47
                      if (ws.datclscod = 10  or ws.datclscod = "10R" ) or
                         (ws.datclscod = 13  or ws.datclscod = "13R" ) then
                         if ws.datclscod > ws.clscod  then
                            let ws.clscod = ws.datclscod
                         end if
                      end if
                end case
             end foreach

             if ws.clscod = 0  then
                initialize ws.clscod to null
             end if
          end if
       end if
    end if
 end if

 return ws.clscod

end function  ###  bdbsr340_clausulas

#---------------------------------------------------------------------------
 report rep_prssrv(r_bdbsr340)
#---------------------------------------------------------------------------

 define r_bdbsr340    record
    atdprscod         like datmservico.atdprscod,
    atdprstip         smallint,
    nomrazsoc         like dpaksocor.nomrazsoc,
    nomgrr            like dpaksocor.nomgrr,
    endcid            like dpaksocor.endcid,
    endbrr            like dpaksocor.endbrr,
    endufd            like dpaksocor.endufd,
    endcep            like dpaksocor.endcep,
    qldgracod         like dpaksocor.qldgracod,
    cpodes            like iddkdominio.cpodes,
    atdsrvorg         like datmservico.atdsrvorg,
    atdcstvlr         like datmservico.atdcstvlr,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    clscod            char (04)
 end record

 define ws_tipo           char(13)
 define ws_vlrtabflg      like dpaksocor.vlrtabflg

 output
      left   margin  000
      right  margin  160
      top    margin  000
      bottom margin  000
      page   length  066

   order by r_bdbsr340.atdprscod


   format
      on every row
         #-----------------------------
         # Dados do prestador
         #-----------------------------
         let r_bdbsr340.nomgrr = "*** NAO CADASTRADO ***"
         let r_bdbsr340.endcid = "*** NAO CADASTRADO ***"
         open  c_guerra using r_bdbsr340.atdprscod
         fetch c_guerra into  r_bdbsr340.nomrazsoc, r_bdbsr340.nomgrr   ,
                              r_bdbsr340.endcid   , r_bdbsr340.endufd   ,
                              r_bdbsr340.endcep   , ws_vlrtabflg        ,
                              r_bdbsr340.endbrr   , r_bdbsr340.qldgracod
         close c_guerra

         if r_bdbsr340.atdprscod = 1  or
            r_bdbsr340.atdprscod = 4  or
            r_bdbsr340.atdprscod = 8  then
            let r_bdbsr340.atdprstip = 1
         else
            if ws_vlrtabflg = "S"  then
               let r_bdbsr340.atdprstip = 2
            else
               let r_bdbsr340.atdprstip = 3
            end if
         end if
         open c_qualid using r_bdbsr340.qldgracod
         fetch c_qualid into r_bdbsr340.cpodes
         close c_qualid

         case r_bdbsr340.atdprstip
              when 1 let ws_tipo = "FROTA"
              when 2 let ws_tipo = "TABELA"
              when 3 let ws_tipo = "OUTROS"
              when 4 let ws_tipo = "TODOS"
         end case

         if ws_flgcab1 = 0 then
            let ws_flgcab1 = 1
            print column 001, "Cod_prestador",     "|"
                            , "Nome_prestador",    "|"
                            , "Tipo",              "|"
                            , "Cidade",            "|"
                            , "UF",                "|"
                            , "Qualidade",         "|"
                            , "Nro.Servico",       "|"
                            , "Ano.Servico",       "|"
                            , "Ramo",              "|"
                            , "Clausula/Plano",    "|"    #PSI 202720
                            , "Valor / 100",       "|"
                            , ascii(13)
         end if

         print r_bdbsr340.atdprscod,      "|", #codigo prestador
               r_bdbsr340.nomgrr clipped, "|", #nome prestador
               ws_tipo clipped,           "|", #tipo prestador
               r_bdbsr340.endcid clipped, "|", #cidade prestador
               r_bdbsr340.endufd,         "|", #uf prestador
               r_bdbsr340.cpodes clipped, "|", #qual prestador
               r_bdbsr340.atdsrvnum    using "#######",     "|", #Nro.Srv.
               r_bdbsr340.atdsrvano    using "&&",          "|", #Ano.Srv.
               r_bdbsr340.ramcod,         "|", #Ramo
               r_bdbsr340.clscod clipped, "|", #Clausula ou Plano(p/ saude)
               r_bdbsr340.atdcstvlr * 100 using "--------&","|", #Custo
               ascii(13)

end report   ### rep_totais

#--------------------------#
function bdbsr340_cria_log()
#--------------------------#

  # -> FUNCAO P/CRIAR O ARQUIVO DE LOG DO PROGRAMA

  define l_path char(80)

  let l_path = null

  let l_path = f_path("DAT","LOG")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdbsr340.log"

  call startlog(l_path)

end function
