############################################################################
# Nome do Modulo: bdbsr330                                        Wagner   #
#                                                                          #
# Relatorio mensal de total de servicos RE pagos por prestador    FEV/2002 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 01/10/2002  Correio      Wagner       Troca de e-mail Francisco Castro p/#
#                                       Roberto Costa.                     #
#--------------------------------------------------------------------------#
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                       #
############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# --------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# ----------------------------------------------------------------------------#
# 29/09/2006 Priscila           PSI 202720 implementar cartao saude           #
# ---------- --------------------- ------ ------------------------------------#
# 14/02/2007 Fabiano, Meta      AS 130087 Migracao para a versao 7.32         #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
#                                                                             #
###############################################################################


 database porto

 define ws_data_de     date,
        ws_data_ate    date,
        ws_data_aux    char(10),
        ws_flgcab1     integer

 main
    call bdbsr330_cria_log()
    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read
    set lock mode to wait 10

    call bdbsr330()
 end main

#---------------------------------------------------------------
 function bdbsr330()
#---------------------------------------------------------------

 define d_bdbsr330    record
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
    ramcod            like datrservapol.ramcod,
    atdsrvorg         like datmservico.atdsrvorg,
    atdcstvlr         like datmservico.atdcstvlr,
    pasqtd            smallint,
    asitipcod         like datmservico.asitipcod
 end record

 define ws            record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdfnlflg         like datmservico.atdfnlflg,
    atdetpcod         like datmsrvacp.atdetpcod,
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    rodar               char (500)
 end record

 define docto         record                                  #PSI 202720
        aplnumdig  like datrservapol.aplnumdig,
        succod     like datrservapol.succod,
        itmnumdig  like datrservapol.itmnumdig,
        crtnum     like datrsrvsau.crtnum
 end record

 define sql_select    char(300)
 define l_retorno     smallint                                # Marcio Meta - PSI185035
 define l_mensagem    char(80)                                #PSI 202720
 define l_tpdocto     char(15)                                #PSI 202720


 #---------------------------------------------------------------
 # Inicializacao das variaveis
 #---------------------------------------------------------------
 initialize d_bdbsr330.*  to null
 initialize ws.*          to null
 initialize docto.* to null                               #PSI 202720

 let ws_flgcab1 = 0
 let l_mensagem = null                                    #PSI 202720
 let l_tpdocto = null                                     #PSI 202720



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

 #periodo = mês anterior a data passada no arg_val
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

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS33001.TXT"
                                                              # Marcio Meta - PSI185035
 #---------------------------------------------------------------
 # Definicao de cursores para extracao
 #---------------------------------------------------------------
 declare  c_bdbsr330  cursor for
    #busca servicos de um OP no período definido que está EMITIDA e seja de RE
    select datmservico.atdsrvnum,
           datmservico.atdsrvano,
           datmservico.atdprscod,
           datmservico.atdsrvorg,
           datmservico.atdcstvlr,
           datmservico.asitipcod
      from dbsmopg, dbsmopgitm, datmservico
     where dbsmopg.socfatpgtdat   between  ws_data_de and ws_data_ate
       and dbsmopg.socopgsitcod   =  7   #emitida
       and dbsmopg.soctip         =  3   #RE
       and dbsmopgitm.socopgnum   =  dbsmopg.socopgnum
       and datmservico.atdsrvnum  =  dbsmopgitm.atdsrvnum
       and datmservico.atdsrvano  =  dbsmopgitm.atdsrvano

 start report  rep_prssrv  to  ws.pathrel01
 start report  rep_prsvlr  to  ws.pathrel01

 #---------------------------------------------------------------
 # Extracao dos servicos pagos no periodo
 #---------------------------------------------------------------
 foreach c_bdbsr330  into  ws.atdsrvnum        ,
                           ws.atdsrvano        ,
                           d_bdbsr330.atdprscod,
                           d_bdbsr330.atdsrvorg,
                           d_bdbsr330.atdcstvlr,
                           d_bdbsr330.asitipcod

    if d_bdbsr330.atdsrvorg  <> 9    then  # RE
       continue foreach
    end if

    if d_bdbsr330.atdcstvlr is null  then   #Custo do atendimento
       let d_bdbsr330.atdcstvlr = 0
    end if

    #PSI 202720 - inicio
    #Busca ramo da tabela de apolice (apenas para Auto e RE)
    #select ramcod
    #  into d_bdbsr330.ramcod
    #  from datrservapol
    # where atdsrvnum = ws.atdsrvnum
    #   and atdsrvano = ws.atdsrvano

    #verifica tipo de documento utilizado no servico
    call cts20g11_identifica_tpdocto(ws.atdsrvnum,
                                     ws.atdsrvano)
         returning l_tpdocto
    if l_tpdocto = "APOLICE" then
       #se documento e apolice - pode ser apolice AUTO ou RE
       # entao buscar ramo na tabela de apolices
       call cts20g13_obter_apolice(ws.atdsrvnum,
                                   ws.atdsrvano)
            returning l_retorno,
                      l_mensagem,
                      docto.aplnumdig,
                      docto.succod,
                      d_bdbsr330.ramcod,
                      docto.itmnumdig
       if l_retorno <> 1 then
          #erro ao obter apolice auto ou RE
          continue foreach
       end if
    else
       if l_tpdocto = "SAUDE" then
          #se documento saude - é do cartao saude, entao buscar ramo na
          # tabela de apolices do saude
          call cts20g10_cartao(2,
                               ws.atdsrvnum,
                               ws.atdsrvano)
               returning l_retorno,
                         l_mensagem,
                         docto.succod,
                         d_bdbsr330.ramcod,
                         docto.aplnumdig,
                         docto.crtnum
          if l_retorno <> 1 then
             #erro ao obter apolice do saude
             continue foreach
          end if
       end if
    end if
    #se for proposta, semdocto ou contrato não tem ramo,
    # entao contabilizar esse servicos em outros

    #PSI 202720 - fim

    output to report rep_prssrv(d_bdbsr330.*)

    #limpar variaveis para ler proximo servico
    let l_tpdocto = null                    #PSI 202720
    initialize d_bdbsr330.* to null         #PSI 202720

 end foreach

 finish report  rep_prssrv
 finish report  rep_prsvlr
                                                               # Marcio Meta - PSI185035
 #------------------------------------------------------------------
 # E-MAIL PORTO SOCORRO
 #------------------------------------------------------------------
 let ws.rodar = ' RE mensal pagos: '

 let l_retorno = ctx22g00_envia_email('BDBSR330',
                                       ws.rodar,
                                       ws.pathrel01)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display " Erro ao enviar email(ctx22g00)-", ws.pathrel01
    else
       display " Email nao encontrado para este modulo BDBSR330 "
    end if
 end if
                                                               # Marcio Meta - PSI185035

# let ws.rodar =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'RE mensal pagos: ",ws_data_aux[4,5],"/",
#                ws_data_aux[7,10], "' ",
#               "agostinho_wagner/spaulo_info_sistemas@u55 < ",
#                ws.pathrel01 clipped
# run ws.rodar
#
# let ws.rodar =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'RE mensal pagos: ",ws_data_aux[4,5],"/",
#                ws_data_aux[7,10], "' ",
#               "costa_roberto/spaulo_psocorro_qualidade@u23 < ",
#                ws.pathrel01 clipped
# run ws.rodar
#
end function   ###  bdbsr330


#---------------------------------------------------------------------------
 report rep_prssrv(d_bdbsr330)
#---------------------------------------------------------------------------

 define d_bdbsr330    record
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
    ramcod            like datrservapol.ramcod,
    atdsrvorg         like datmservico.atdsrvorg,
    atdcstvlr         like datmservico.atdcstvlr,
    pasqtd            smallint,
    asitipcod         like datmservico.asitipcod
 end record

 define r_bdbsr330    record
    qtdr11            dec (06,0)                 ,
    qtdr31            dec (06,0)                 ,
    qtdr44            dec (06,0)                 ,
    qtdr45            dec (06,0)                 ,
    qtdr46            dec (06,0)                 ,
    qtdr71            dec (06,0)                 ,
    qtdr85            dec (06,0)                 ,     #PSI 202720
    qtdrOutro         dec (06,0)                 ,     #PSI 202720
    vlrr11            dec (13,2)                 ,
    vlrr31            dec (13,2)                 ,
    vlrr44            dec (13,2)                 ,
    vlrr45            dec (13,2)                 ,
    vlrr46            dec (13,2)                 ,
    vlrr71            dec (13,2)                 ,
    vlrr85            dec (13,2)                 ,     #PSI 202720
    vlrrOutro         dec (13,2)                       #PSI 202720
 end record

   output
      left   margin  000
      right  margin  160
      top    margin  000
      bottom margin  000
      page   length  099

   order by  d_bdbsr330.atdprscod

   format

      before group of d_bdbsr330.atdprscod
         let r_bdbsr330.qtdr11 = 0
         let r_bdbsr330.qtdr31 = 0
         let r_bdbsr330.qtdr44 = 0
         let r_bdbsr330.qtdr45 = 0
         let r_bdbsr330.qtdr46 = 0
         let r_bdbsr330.qtdr71 = 0
         let r_bdbsr330.qtdr85 = 0      #PSI 202720
         let r_bdbsr330.qtdrOutro = 0   #PSI 202720
         let r_bdbsr330.vlrr11 = 0
         let r_bdbsr330.vlrr31 = 0
         let r_bdbsr330.vlrr44 = 0
         let r_bdbsr330.vlrr45 = 0
         let r_bdbsr330.vlrr46 = 0
         let r_bdbsr330.vlrr71 = 0
         let r_bdbsr330.vlrr85 = 0      #PSI 202720
         let r_bdbsr330.vlrrOutro = 0   #PSI 202720

      after  group of d_bdbsr330.atdprscod
         output to report rep_prsvlr(d_bdbsr330.atdprscod thru
                                     d_bdbsr330.cpodes,
                                     r_bdbsr330.*)

      on every row
         case d_bdbsr330.ramcod
            when  11      # ramo 11
                  let r_bdbsr330.qtdr11 = r_bdbsr330.qtdr11 + 1
                  let r_bdbsr330.vlrr11 = r_bdbsr330.vlrr11 +
                                          d_bdbsr330.atdcstvlr
            when  111     # ramo 111
                  let r_bdbsr330.qtdr11 = r_bdbsr330.qtdr11 + 1
                  let r_bdbsr330.vlrr11 = r_bdbsr330.vlrr11 +
                                          d_bdbsr330.atdcstvlr
            when  31      # ramo 31
                  let r_bdbsr330.qtdr31 = r_bdbsr330.qtdr31 + 1
                  let r_bdbsr330.vlrr31 = r_bdbsr330.vlrr31 +
                                          d_bdbsr330.atdcstvlr
            when  531     # ramo 531
                  let r_bdbsr330.qtdr31 = r_bdbsr330.qtdr31 + 1
                  let r_bdbsr330.vlrr31 = r_bdbsr330.vlrr31 +
                                          d_bdbsr330.atdcstvlr
            when  44      # ramo 44
                  let r_bdbsr330.qtdr44 = r_bdbsr330.qtdr44 + 1
                  let r_bdbsr330.vlrr44 = r_bdbsr330.vlrr44 +
                                          d_bdbsr330.atdcstvlr
            when  118     # ramo 118
                  let r_bdbsr330.qtdr44 = r_bdbsr330.qtdr44 + 1
                  let r_bdbsr330.vlrr44 = r_bdbsr330.vlrr44 +
                                          d_bdbsr330.atdcstvlr
            when  45     # ramo 45
                  let r_bdbsr330.qtdr45 = r_bdbsr330.qtdr45 + 1
                  let r_bdbsr330.vlrr45 = r_bdbsr330.vlrr45 +
                                          d_bdbsr330.atdcstvlr
            when  114    # ramo 114
                  let r_bdbsr330.qtdr45 = r_bdbsr330.qtdr45 + 1
                  let r_bdbsr330.vlrr45 = r_bdbsr330.vlrr45 +
                                          d_bdbsr330.atdcstvlr
            when  46     # ramo 46
                  let r_bdbsr330.qtdr46 = r_bdbsr330.qtdr46 + 1
                  let r_bdbsr330.vlrr46 = r_bdbsr330.vlrr46 +
                                          d_bdbsr330.atdcstvlr
            when  746    # ramo 746
                  let r_bdbsr330.qtdr46 = r_bdbsr330.qtdr46 + 1
                  let r_bdbsr330.vlrr46 = r_bdbsr330.vlrr46 +
                                          d_bdbsr330.atdcstvlr
            when  71     # ramo 71
                  let r_bdbsr330.qtdr71 = r_bdbsr330.qtdr71 + 1
                  let r_bdbsr330.vlrr71 = r_bdbsr330.vlrr71 +
                                          d_bdbsr330.atdcstvlr
            when  171    # ramo 171
                  let r_bdbsr330.qtdr71 = r_bdbsr330.qtdr71 + 1
                  let r_bdbsr330.vlrr71 = r_bdbsr330.vlrr71 +
                                          d_bdbsr330.atdcstvlr

            when  195    # ramo 195       # Garantia Estendida (Novo)
                  let r_bdbsr330.qtdr71 = r_bdbsr330.qtdr71 + 1
                  let r_bdbsr330.vlrr71 = r_bdbsr330.vlrr71 +
                                          d_bdbsr330.atdcstvlr
            when  85     # ramo 85 - saude                             #PSI 202720
                  let r_bdbsr330.qtdr85 = r_bdbsr330.qtdr85 + 1
                  let r_bdbsr330.vlrr85 = r_bdbsr330.vlrr85 +
                                          d_bdbsr330.atdcstvlr
            when  86    # ramo 86 - saude                              #PSI 202720
                  let r_bdbsr330.qtdr85 = r_bdbsr330.qtdr85 + 1
                  let r_bdbsr330.vlrr85 = r_bdbsr330.vlrr85 +
                                          d_bdbsr330.atdcstvlr
            when  87    # ramo 87 - saude                              #PSI 202720
                  let r_bdbsr330.qtdr85 = r_bdbsr330.qtdr85 + 1
                  let r_bdbsr330.vlrr85 = r_bdbsr330.vlrr85 +
                                          d_bdbsr330.atdcstvlr

            otherwise   #Proposta, sem documento ou contrato
                  let r_bdbsr330.qtdrOutro = r_bdbsr330.qtdrOutro + 1    #PSI 202720
                  let r_bdbsr330.vlrrOutro = r_bdbsr330.vlrrOutro +
                                          d_bdbsr330.atdcstvlr
         end case

end report    ### rep_prssrv

#---------------------------------------------------------------------------
 report rep_prsvlr(r_bdbsr330)  #SERVICOS PAGOS (VALORES)
#---------------------------------------------------------------------------

 define r_bdbsr330    record
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomrazsoc         like dpaksocor.nomrazsoc   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (20)                  ,
    endbrr            like dpaksocor.endbrr      ,
    endufd            like dpaksocor.endufd      ,
    endcep            like dpaksocor.endcep      ,
    qldgracod         like dpaksocor.qldgracod   ,
    cpodes            like iddkdominio.cpodes    ,
    qtdr11            dec (06,0)                 ,
    qtdr31            dec (06,0)                 ,
    qtdr44            dec (06,0)                 ,
    qtdr45            dec (06,0)                 ,
    qtdr46            dec (06,0)                 ,
    qtdr71            dec (06,0)                 ,
    qtdr85            dec (06,0)                 ,    #PSI 202720
    qtdrOutro         dec (06,0)                 ,    #PSI 202720
    vlrr11            dec (13,2)                 ,
    vlrr31            dec (13,2)                 ,
    vlrr44            dec (13,2)                 ,
    vlrr45            dec (13,2)                 ,
    vlrr46            dec (13,2)                 ,
    vlrr71            dec (13,2)                 ,
    vlrr85            dec (13,2)                 ,    #PSI 202720
    vlrrOutro         dec (13,2)                      #PSI 202720
 end record

 define ws_tipo           char(13)
 define ws_vlrtabflg      like dpaksocor.vlrtabflg

 output
      left   margin  000
      right  margin  160
      top    margin  000
      bottom margin  000
      page   length  066

   order by r_bdbsr330.atdprscod

   format

      on every row
         #-----------------------------
         # Dados do prestador
         #-----------------------------
         let r_bdbsr330.nomgrr = "*** NAO CADASTRADO ***"
         let r_bdbsr330.endcid = "*** NAO CADASTRADO ***"
         open  c_guerra using r_bdbsr330.atdprscod
         fetch c_guerra into  r_bdbsr330.nomrazsoc, r_bdbsr330.nomgrr   ,
                              r_bdbsr330.endcid   , r_bdbsr330.endufd   ,
                              r_bdbsr330.endcep   , ws_vlrtabflg        ,
                              r_bdbsr330.endbrr   , r_bdbsr330.qldgracod
         close c_guerra

         if r_bdbsr330.atdprscod = 1  or
            r_bdbsr330.atdprscod = 4  or
            r_bdbsr330.atdprscod = 8  then
            let r_bdbsr330.atdprstip = 1
         else
            if ws_vlrtabflg = "S"  then
               let r_bdbsr330.atdprstip = 2
            else
               let r_bdbsr330.atdprstip = 3
            end if
         end if
         open c_qualid using r_bdbsr330.qldgracod
         fetch c_qualid into r_bdbsr330.cpodes
         close c_qualid

         case r_bdbsr330.atdprstip
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
                            , "Vlr_Ramo_11(/100)", "|"
                            , "Qtd_Ramo_11 ",      "|"
                            , "Vlr_Ramo_31(/100)", "|"
                            , "Qtd_Ramo_31 ",      "|"
                            , "Vlr_Ramo_44(/100)", "|"
                            , "Qtd_Ramo_44 ",      "|"
                            , "Vlr_Ramo_45(/100)", "|"
                            , "Qtd_Ramo_45 ",      "|"
                            , "Vlr_Ramo_46(/100)", "|"
                            , "Qtd_Ramo_46 ",      "|"
                            , "Vlr_Ramo_71(/100)", "|"
                            , "Qtd_Ramo_71 ",      "|"
                            , "Vlr_Ramo_85(/100)", "|"               #PSI 202720
                            , "Qtd_Ramo_85 ",      "|"               #PSI 202720
                            , "Vlr_Outro_Ramo(/100)", "|"            #PSI 202720
                            , "Qtd_Outro_Ramo ",      "|"            #PSI 202720
                            , ascii(13)
         end if

         print r_bdbsr330.atdprscod,      "|", #codigo prestador
               r_bdbsr330.nomgrr clipped, "|", #nome prestador
               ws_tipo clipped,           "|", #tipo prestador
               r_bdbsr330.endcid clipped, "|", #cidade prestador
               r_bdbsr330.endufd,         "|", #uf prestador
               r_bdbsr330.cpodes clipped, "|", #qual prestador
               r_bdbsr330.vlrr11 * 100 using "-----------&","|", #vlr ramo11
               r_bdbsr330.qtdr11       using "------&",     "|", #qtd ramo11
               r_bdbsr330.vlrr31 * 100 using "-----------&","|", #vlr ramo31
               r_bdbsr330.qtdr31       using "------&",     "|", #qtd ramo31
               r_bdbsr330.vlrr44 * 100 using "-----------&","|", #vlr ramo44
               r_bdbsr330.qtdr44       using "------&",     "|", #qtd ramo44
               r_bdbsr330.vlrr45 * 100 using "-----------&","|", #vlr ramo45
               r_bdbsr330.qtdr45       using "------&",     "|", #qtd ramo45
               r_bdbsr330.vlrr46 * 100 using "-----------&","|", #vlr ramo46
               r_bdbsr330.qtdr46       using "------&",     "|", #qtd ramo46
               r_bdbsr330.vlrr71 * 100 using "-----------&","|", #vlr ramo71
               r_bdbsr330.qtdr71       using "------&",     "|", #qtd ramo71
               r_bdbsr330.vlrr85 * 100 using "-----------&","|", #vlr ramo85  #PSI 202720
               r_bdbsr330.qtdr85       using "------&",     "|", #qtd ramo85  #PSI 202720
               r_bdbsr330.vlrrOutro * 100 using "-----------&","|", #vlr ramo85  #PSI 202720
               r_bdbsr330.qtdrOutro       using "------&",     "|", #qtd ramo85  #PSI 202720
               ascii(13)

end report   ### rep_totais

#--------------------------#
function bdbsr330_cria_log()
#--------------------------#

  # -> FUNCAO P/CRIAR O ARQUIVO DE LOG DO PROGRAMA

  define l_path char(80)

  let l_path = null

  let l_path = f_path("DAT","LOG")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdbsr330.log"

  call startlog(l_path)

end function

