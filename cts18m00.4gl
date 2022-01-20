############################################################################
# Nome do Modulo: CTS18M00                                         Marcelo  #
#                                                                  Gilberto #
# Laudo - Aviso de Sinistro                                        Ago/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 03/11/1998  Via correio  Gilberto     Substituir a verificacao da vigen-  #
#                                       cia da apolice em relacao a data do #
#                                       sinistro, utilizando a vigencia fi- #
#                                       nal da apolice ao inves da vigencia #
#                                       final do endosso.                   #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00), passando parametros #
#                                       de registro via formulario.         #
#---------------------------------------------------------------------------#
# 06/08/1999  Samir        Gilberto     Alterar parametros da funcao de en- #
#                                       vio de fax de aviso de sinistro.    #
#---------------------------------------------------------------------------#
# 20/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 04/11/1999  PSI 9118-9   Gilberto     Inclusao da data e hora da ocorren- #
#                                       cia na tela principal.              #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 21/12/1999  PSI 8852-8   Gilberto     Obter informacoes referentes a fur- #
#                                       to/roubo.                           #
#---------------------------------------------------------------------------#
# 22/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 28/06/2000  PSI 10865-0  Ruiz         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 23/07/2001  PSI 13233-0  Ruiz         Inclusao do numero da apolice       #
#                                       na consulta.                        #
#---------------------------------------------------------------------------#
# 23/01/2002  PSI 14654-4  Ruiz         Aproveitar os dados qdo da apolice  #
#                                       do "terceiro segurado".             #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Renato Zattar                    OSF : 4774             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 10/07/2002       #
#  Objetivo       : Alteracao para comportar Endereco Eletronico (E-mail)   #
#---------------------------------------------------------------------------#
# 08/05/2003  PSI 168920  Aguinaldo    Resolucao 86                         #
#---------------------------------------------------------------------------#
#...........................................................................#
#                                                                           #
#                   * * * Alteracoes * * *                                  #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
# 18/09/2003 Gustavo, Meta RS  PSI175552  Inibir a chamada da funcao        #
#                              OSF26077   "ctx17g00_assist.                 #
#                                                                           #
# 03/03/2004 Amaury, FSW       PSI 172090 OSF 32859. Inclusao de novos para-#
#                                       metros na chamada da funcao cts18m01#
#                                                                           #
# 16/08/2004 Meta, James       PSI183431  Passar a retornar parametros na   #
#                                         chamada do cta00m01               #
#                                                                           #
# 20/08/2004 Daniel, Meta      PSI183431  Alterar a definicao da variavel   #
#                                         averbacao                         #
#---------------------------------------------------------------------------#
# 03/02/2006 Priscila         Zeladoria   Buscar data e hora do banco       #
#---------------------------------------------------------------------------#
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 15/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32            #
#---------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta Psi223689 Incluir tratamento de erro com a       #
#                                         global                            #
#---------------------------------------------------------------------------#
# 20/11/2008 Amilton, Meta Psi230669 incluir relacionamento de ligacao      #
#                                         com atedimento                    #
#---------------------------------------------------------------------------#
# 30/12/2008 Priscila                      Exibir mensagem de erro retornada#
#                                          por ctd25g00                     #
#---------------------------------------------------------------------------#
# 04/01/2010 Amilton                       projeto sucursal smallint        #
# 08/03/2010 Adriano Santos CT10029839 Retirar emails com padrao antigo     #
#---------------------------------------------------------------------------#
# 03/05/2012 Silvia,Meta PSI-2012-07408/PR Projeto Anatel-Aumento DDD/Telef #
#---------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689


 define d_cts18m00    record
    prporgpcp         like apbmitem.prporgpcp      ,
    prpnumpcp         like apbmitem.prpnumpcp      ,
    prporgidv         like ssamavs.prporgidv       ,
    prpnumidv         like ssamavs.prpnumidv       ,
    sinocrdat         like ssamavs.sinocrdat       ,
    sinocrhor         like ssamavs.sinocrhor       ,
    ramcod            like ssamavs.ramcod          ,
    subcod            like ssamavs.subcod          ,
    sinvstnum         like ssamavs.sinvstnum       ,
    sinvstano         like ssamavs.sinvstano       ,
    sinavsnum         like ssamavs.sinavsnum       ,
    sinavsano         like ssamavs.sinavsano       ,
    segnom            like gsakseg.segnom          ,
    segdddcod         like gsakend.dddcod          ,
    segtelnum         char (09)                    , ## Anatel - char (08)                    ,
    cornom            like gcakcorr.cornom         ,
    corsus            like gcaksusep.corsus        ,
    cordddcod         like gcakfilial.dddcod       ,
    cortelnum         char (09)                    ,
    vcldes            char (50)                    ,
    vcllicnum         like abbmveic.vcllicnum      ,
    vclcoddig         like abbmveic.vclcoddig      ,
    vclchsnum         char (20)                    ,
    vclanofbc         like abbmveic.vclanofbc      ,
    vclanomdl         like abbmveic.vclanomdl      ,
    apolice           char (30)                    ,
    sinrclnom         like ssamavs.sinrclnom       ,
    cgccpfnum         like ssamterc.cgccpfnum      ,
    cgcord            like ssamterc.cgcord         ,
    cgccpfdig         like ssamterc.cgccpfdig      ,
    endlgd            like ssamterc.endlgd         ,
    endbrr            char (20)                    ,
    endcid            char (20)                    ,
    endufd            char (02)                    ,
    trcdddcod         char (04)                    ,
    trctelnum         like ssammot.telnum          ,
    trcvclcod         like ssamavsvcl.vclcoddig    ,
    sinbemdes         like ssamavsvcl.sinbemdes    ,
    trccorcod         like ssamavsvcl.vclcorcod    ,
    trccordes         char (11)                    ,
    trcvclchs         char (20)                    ,
    trcvcllic         like ssamavsvcl.vcllicnum    ,
    trcanofbc         like ssamavsvcl.vclanofbc    ,
    trcanomdl         like ssamavsvcl.vclanomdl    ,
    sinrclsgrflg      like ssamavs.sinrclsgrflg    ,
    sinrclsgdnom      like ssamavs.sinrclsgdnom    ,
    sinrclapltxt      like ssamavs.sinrclapltxt    ,
    viginc            like abamapol.viginc         ,
    vigfnl            like abamapol.vigfnl         ,
    sinvclguiflg      like ssamavs.sinvclguiflg    ,
    sinvclguinom      like ssamavs.sinvclguinom    ,
    filler            char (01)                    ,
    succod            like datrligapol.succod      ,
    aplnumdig         like datrligapol.aplnumdig   ,
    itmnumdig         like datrligapol.itmnumdig
 end record

 define acid_cts18m00 record
    sinlcldes         like ssammot.sinlcldes       ,
    sinendcid         like ssammot.sinendcid       ,
    sinlclufd         like ssammot.sinlclufd       ,
    sinntzcod         like ssamavs.sinntzcod       ,
    sinbocflg         like ssammot.sinbocflg       ,
    dgcnum            like ssammot.dgcnum          ,
    sinvcllcldes      like ssammot.sinvcllcldes    ,
    vclatulgd         like ssammot.vclatulgd       ,
    sinmotcplflg      like ssammot.sinmotcplflg    ,
    sinrclcpdflg      char (01)                    ,
    avsrbfsegvitflg   char (01)                    ,
    segrbfantsim      char (01)                    ,
    segrbfantnao      char (01)                    ,
    segrbfantnaosabe  char (01)                    ,
    segqtdum          char (01)                    ,
    segqtddois        char (01)                    ,
    segqtdtres        char (01)                    ,
    segqtdmaistres    char (01)                    ,
    segqtdnaosabe     char (01)                    ,
    vitrbfantsim      char (01)                    ,
    vitrbfantnao      char (01)                    ,
    vitrbfantnaosabe  char (01)                    ,
    vitqtdum          char (01)                    ,
    vitqtddois        char (01)                    ,
    vitqtdtres        char (01)                    ,
    vitqtdmaistres    char (01)                    ,
    vitqtdnaosabe     char (01)
 end record

 define a_cts18m00    array[02] of record
    sinmotnom         like ssammot.sinmotnom       ,
    cgccpfnum         like ssammot.cgccpfnum       ,
    cgcord            like ssammot.cgcord          ,
    cgccpfdig         like ssammot.cgccpfdig       ,
    endlgd            like ssammot.endlgd          ,
    endbrr            like ssammot.endbrr          ,
    endcid            like ssammot.endcid          ,
    endufd            like ssammot.endufd          ,
    dddcod            like gsakend.dddcod          ,
    telnum            like ssammot.telnum          ,
    cnhnum            like ssammot.cnhnum          ,
    cnhvctdat         like ssammot.cnhvctdat       ,
    sinmotidd         like ssammot.sinmotidd       ,
    sinmotsex         like ssammot.sinmotsex       ,
    cdtestcod         like ssammot.cdtestcod       ,
    sinmotprfcod      like ssammot.sinmotprfcod    ,
    sinmotprfdes      like ssammot.sinmotprfdes    ,
    sinsgrvin         like ssammot.sinsgrvin       ,
    vstnumdig         like avlmlaudo.vstnumdig
 end record

 define slv_segurado  record
    succod            like datrligapol.succod      ,
    ramcod            like gtakram.ramcod          ,
    aplnumdig         like datrligapol.aplnumdig   ,
    itmnumdig         like datrligapol.itmnumdig   ,
    edsnumref         like datrligapol.edsnumref   ,
    lignum            like datmligacao.lignum      ,
    c24soltipcod      like datmligacao.c24soltipcod,
    solnom            char (15)                    ,
    c24astcod         like datkassunto.c24astcod   ,
    ligcvntip         like datmligacao.ligcvntip   ,
    prporg            like datrligprp.prporg       ,
    prpnumdig         like datrligprp.prpnumdig    ,
    fcapacorg         like datrligpac.fcapacorg    ,
    fcapacnum         like datrligpac.fcapacnum    ,
    dctnumseq         dec (04,00)                  ,
    vclsitatu         dec (04,00)                  ,
    autsitatu         dec (04,00)                  ,
    dmtsitatu         dec (04,00)                  ,
    dpssitatu         dec (04,00)                  ,
    atdnum            like datratdlig.atdnum

 end record

 define m_retorno    record
        sinrclnom    like ssamavs.sinrclnom
       ,sinrcltel    like ssamavs.sinrcltel
       ,cgccpfnum    like ssamavs.cgccpfnum
       ,cgcord       like ssamavs.cgcord
       ,cgccpfdig    like ssamavs.cgccpfdig
       ,sinrclend    char(25)
       ,sinrclendcid like ssamavs.sinrclendcid
       ,sinrclendufd like ssamavs.sinrclendufd
       ,vclcoddig    like ssamavs.vclcoddig
       ,sinbemdes    like ssamavs.sinbemdes
       ,vclcorcod    like ssamavs.vclcorcod
       ,vcldencor    char(20)
       ,vclchsnum    like ssamavs.vclchsnum
       ,vcllicnum    like ssamavs.vcllicnum
       ,vclanofbc    like ssamavs.vclanofbc
       ,vclanomdl    like ssamavs.vclanomdl
       ,sinrclsgrflg like ssamavs.sinrclsgrflg
       ,sinrclsgdnom like ssamavs.sinrclsgdnom
       ,sinrclapltxt like ssamavs.sinrclapltxt
       ,endbrr       char(25)
       ,sinano       like ssamsin.sinano
       ,sinnum       like ssamsin.sinnum
       ,sinvstano    like ssamsin.sinvstano
       ,sinvstnum    like ssamsin.sinvstnum
       ,viginc       like abbmdoc.viginc
       ,vigfnl       like abbmdoc.vigfnl
       ,succod       like datrligapol.succod
       ,aplnumdig    like datrligapol.aplnumdig
       ,itmnumdig    like datrligapol.itmnumdig
 end record

 define m_opcao       char(1)
 define aux_atdsrvnum like datmservico.atdsrvnum
 define aux_atdsrvano like datmservico.atdsrvano
 define aux_smallint  smallint
 define aux_char      char(10)
 define aux_email     smallint
 define m_dtres86     date
 define m_newramo31   dec(4,0)

#--------------------------------------------------------------------
 function cts18m00(param)
#--------------------------------------------------------------------

 define param         record
    sinavsnum         like ssamavs.sinavsnum,
    sinavsano         like ssamavs.sinavsano
 end record

 define ws            record
    mnuflg            smallint
 end record



        initialize  ws.*  to  null

 let aux_email = 0

 open window w_cts18m00 at 04,02 with form "cts18m00"
                        attribute(form line 1, comment line last - 1)

 if param.sinavsnum is null  and
    param.sinavsano is null  then
    call inclui_cts18m00()
    if aux_email = 1 then
       call email_cts18m00() #-- Henrique : 12/12/2002
    end if
    return
 end if

 let ws.mnuflg = false

 while true
    menu "AVISO SINISTRO"
       before menu
          hide option "Modifica"
          hide option "mOt_segurado"
          hide option "mot_Terceiro"
          hide option "Causador"
          hide option "Veic_causador"
          hide option "Acidente"
          hide option "Fax"
          hide option "Historico"

       command key ("S") "Seleciona"     "Seleciona aviso de sinistro"
          call seleciona_cts18m00 (param.sinavsnum, param.sinavsano)

          let int_flag = false

          show option "Modifica"
          show option "Acidente"
          show option "Fax"
          show option "Historico"

          if d_cts18m00.ramcod = 31  or
             d_cts18m00.ramcod = 531 then
             if acid_cts18m00.sinmotcplflg = "T"  then
                show option "Causador"
                show option "Veic_causador"
             end if
          else
             show option "mOt_segurado"
             show option "mot_Terceiro"
          end if

          next option "Modifica"

       command key ("M") "Modifica"      "Modifica aviso de sinistro selecionado"
          call input_cts18m00("M")

          if int_flag  then
             error " Operacao cancelada! (1)"
             initialize d_cts18m00.*     to null
             initialize a_cts18m00       to null
             initialize acid_cts18m00.*  to null
             exit menu
          end if
          let aux_email = 1

       command key ("O") "mOt_segurado"  "Motorista do segurado"
          call cts18m01 ("M", 31, d_cts18m00.segnom, a_cts18m00[1].*
                         #-----> PSI 172090
                        ,g_documento.succod    ,g_documento.aplnumdig
                        ,g_documento.itmnumdig ,d_cts18m00.prporgidv
                        ,d_cts18m00.prpnumidv)
               returning a_cts18m00[1].*

          if int_flag  then
             error " Operacao cancelada! (2)"
             initialize d_cts18m00.*     to null
             initialize a_cts18m00       to null
             initialize acid_cts18m00.*  to null
             exit menu
          end if
          let aux_email = 1

       command key ("T") "mot_Terceiro"  "Motorista do terceiro"
          call cts18m01 ("M", 53, "", a_cts18m00[2].*
                         #-----> PSI 172090
                        ,g_documento.succod    ,g_documento.aplnumdig
                        ,g_documento.itmnumdig ,d_cts18m00.prporgidv
                        ,d_cts18m00.prpnumidv)
               returning a_cts18m00[2].*

          if int_flag  then
             error " Operacao cancelada! (3)"
             initialize d_cts18m00.*     to null
             initialize a_cts18m00       to null
             initialize acid_cts18m00.*  to null
             exit menu
          end if
          let aux_email = 1

       command key ("C") "Causador"      "Causador do acidente"
          if acid_cts18m00.sinmotcplflg = "T"  then
             call cts18m01 ("M", 99, "", a_cts18m00[2].*
                           #-----> PSI 172090
                           ,"" ,"" ,"" ,"" ,"")
                  returning a_cts18m00[2].*

             if int_flag  then
                error " Operacao cancelada! (4)"
                initialize d_cts18m00.*     to null
                initialize a_cts18m00       to null
                initialize acid_cts18m00.*  to null
                exit menu
             end if
             let aux_email = 1
          else
             error " Causador do acidente nao informado!"
          end if

       command key ("V") "Veic_causador" "Veiculo causador do acidente"
          if acid_cts18m00.sinmotcplflg = "T"  then
             call cts18m09 ("M"                 ,
                            d_cts18m00.trcvclcod,
                            d_cts18m00.sinbemdes,
                            d_cts18m00.trccorcod,
                            d_cts18m00.trcvclchs,
                            d_cts18m00.trcvcllic,
                            d_cts18m00.trcanofbc,
                            d_cts18m00.trcanomdl)
                  returning d_cts18m00.trcvclcod,
                            d_cts18m00.sinbemdes,
                            d_cts18m00.trccorcod,
                            d_cts18m00.trcvclchs,
                            d_cts18m00.trcvcllic,
                            d_cts18m00.trcanofbc,
                            d_cts18m00.trcanomdl

             if int_flag  then
                error " Operacao cancelada! (5)"
                initialize d_cts18m00.*     to null
                initialize a_cts18m00       to null
                initialize acid_cts18m00.*  to null
                exit menu
             end if
             let aux_email = 1
          else
             error " Veiculo causador do acidente nao informado!"
          end if

       command key ("A") "Acidente"      "Informacoes sobre acidente"
          call cts18m03 ("M", acid_cts18m00.*)
               returning acid_cts18m00.*

          if int_flag  then
             error " Operacao cancelada! (6)"
             initialize d_cts18m00.*     to null
             initialize a_cts18m00       to null
             initialize acid_cts18m00.*  to null
             exit menu
          end if
          let aux_email = 1

       command key ("F") "Fax"           "Envia aviso de sinistro via fax"
          call fax_cts18m00 (param.sinavsnum, param.sinavsano)
          let aux_email = 1

       command key ("H") "Historico"     "Historico do aviso de sinistro"
          call cts18n04 (param.sinavsnum, param.sinavsano)
          let aux_email = 1

       command key (interrupt,"E") "Encerra" "Retorna ao menu anterior"
          if g_documento.acao is not null then
             call cts18n04(param.sinavsnum, param.sinavsano)
          end if
          let ws.mnuflg = true
          exit menu
    end menu

    if int_flag = false  then
       call modifica_cts18m00 (param.sinavsnum, param.sinavsano)
       exit while
    end if

    if ws.mnuflg = true  then
       exit while
    end if
 end while

 close window w_cts18m00

 if aux_email = 1 then
    call email_cts18m00() #-- Henrique : 12/12/2002
 end if

end function  ###  cts18m00

#--------------------------------------------------------------------
function email_cts18m00() #-- Envia e-mail para convenio!
#--------------------------------------------------------------------

   let aux_smallint = 0
   let aux_char     = d_cts18m00.sinavsano
   let aux_smallint = aux_char
   if d_cts18m00.sinavsano < 2000 then
      let aux_smallint = aux_smallint - 1900
   else
      let aux_smallint = aux_smallint - 2000
   end if

   let aux_atdsrvano = aux_smallint
   let aux_atdsrvnum = d_cts18m00.sinavsnum


   ### PSI175552 / OSF26077
   ###call ctx17g00_assist(g_documento.ligcvntip ,
   ###                     g_documento.c24astcod ,
   ###                     aux_atdsrvnum         ,
   ###                     aux_atdsrvano         ,
   ###                     g_documento.lignum    ,
   ###                     ""                    ,
   ###                     ""                    ,
   ###                     ""                    ,
   ###                     ""                    ,
   ###                     ""                    ,
   ###                     ""                    ,
   ###                     ""                    ,
   ###                     ""                    )

end function

#----------------------------------
 function seleciona_cts18m00(param)
#----------------------------------

 define param         record
    sinavsnum         like ssamavs.sinavsnum    ,
    sinavsano         like ssamavs.sinavsano
 end record

 define ws            record
    sinsgrmotflg      like ssammot.sinsgrmotflg ,
    segnumdig         like gsakseg.segnumdig    ,
    vclchsinc         like abbmveic.vclchsinc   ,
    vclchsfnl         like abbmveic.vclchsfnl   ,
    dctnumseq         like abamdoc.dctnumseq    ,
    edsstt            smallint,
    succod            like datrligapol.succod,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    prporg            like datrligprp.prporg,
    prpnumdig         like datrligprp.prpnumdig
 end record



        initialize  ws.*  to  null

 initialize d_cts18m00.*    to null
 initialize a_cts18m00      to null
 initialize acid_cts18m00.* to null

 select ramcod into d_cts18m00.ramcod
   from ssamavs
  where sinavsnum = param.sinavsnum  and
        sinavsano = param.sinavsano

 if sqlca.sqlcode = notfound  then
    error " Aviso de sinistro nao encontrado!"
    return
 else
    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na localizacao do aviso de sinistro. AVISE A INFORMATICA!"
       return
    end if
 end if

 if d_cts18m00.ramcod = 31   or
    d_cts18m00.ramcod = 531  then
    select succod   ,
           aplnumdig,
           itmnumdig,
           subcod   ,
           prporgidv,
           prpnumidv,
           sinvstnum,
           sinvstano,
           sinocrdat,
           sinocrhor,
           sinntzcod,
           sinrclnom,
           sinrcltel,
           vclcoddig,
           vclchsnum,
           vcllicnum,
           vclanofbc,
           vclanomdl,
           sinrclcpdflg
      into d_cts18m00.succod,
           d_cts18m00.aplnumdig,
           d_cts18m00.itmnumdig,
           d_cts18m00.subcod    ,
           d_cts18m00.prporgidv ,
           d_cts18m00.prpnumidv ,
           d_cts18m00.sinvstnum ,
           d_cts18m00.sinvstano ,
           d_cts18m00.sinocrdat ,
           d_cts18m00.sinocrhor ,
           acid_cts18m00.sinntzcod,
           d_cts18m00.segnom    ,
           d_cts18m00.segtelnum ,
           d_cts18m00.vclcoddig ,
           d_cts18m00.vclchsnum ,
           d_cts18m00.vcllicnum ,
           d_cts18m00.vclanofbc ,
           d_cts18m00.vclanomdl ,
           acid_cts18m00.sinrclcpdflg
      from ssamavs
     where sinavsnum = param.sinavsnum  and
           sinavsano = param.sinavsano

     let g_documento.ramcod = d_cts18m00.ramcod

    call veiculo_cts18m00(d_cts18m00.vclcoddig)
                returning d_cts18m00.vcldes
 else
    select succod   ,
           aplnumdig,
           itmnumdig,
           subcod   ,
           prporgidv,
           prpnumidv,
           sinvstnum,
           sinvstano,
           sinocrdat,
           sinocrhor,
           sinntzcod,
           sinrclnom,
           sinrcltel,
           sinrclend,
           sinrclbrrnom,
           sinrclendcid,
           sinrclendufd,
           cgccpfnum,
           cgcord   ,
           cgccpfdig,
           vclcoddig,
           vclcorcod,
           vclchsnum,
           vcllicnum,
           vclanofbc,
           vclanomdl,
           sinrclsgrflg,
           sinrclsgdnom,
           sinrclapltxt,
           sinrclcpdflg,
           sinvclguiflg,
           sinvclguinom
      into d_cts18m00.succod,
           d_cts18m00.aplnumdig,
           d_cts18m00.itmnumdig,
           d_cts18m00.subcod   ,
           d_cts18m00.prporgidv,
           d_cts18m00.prpnumidv,
           d_cts18m00.sinvstnum,
           d_cts18m00.sinvstano,
           d_cts18m00.sinocrdat,
           d_cts18m00.sinocrhor,
           acid_cts18m00.sinntzcod,
           d_cts18m00.sinrclnom,
           d_cts18m00.trctelnum,
           d_cts18m00.endlgd   ,
           d_cts18m00.endbrr   ,
           d_cts18m00.endcid   ,
           d_cts18m00.endufd   ,
           d_cts18m00.cgccpfnum,
           d_cts18m00.cgcord   ,
           d_cts18m00.cgccpfdig,
           d_cts18m00.trcvclcod,
           d_cts18m00.trccorcod,
           d_cts18m00.trcvclchs,
           d_cts18m00.trcvcllic,
           d_cts18m00.trcanofbc,
           d_cts18m00.trcanomdl,
           d_cts18m00.sinrclsgrflg,
           d_cts18m00.sinrclsgdnom,
           d_cts18m00.sinrclapltxt,
           acid_cts18m00.sinrclcpdflg,
           d_cts18m00.sinvclguiflg,
           d_cts18m00.sinvclguinom
      from ssamavs
     where sinavsnum = param.sinavsnum  and
           sinavsano = param.sinavsano

    initialize d_cts18m00.trccordes to null

    select cpodes into d_cts18m00.trccordes
      from iddkdominio
     where cponom = "vclcorcod"  and
           cpocod = d_cts18m00.trccorcod

    call veiculo_cts18m00(d_cts18m00.trcvclcod)
                returning d_cts18m00.sinbemdes
 end if

 -----------[ salva global qdo chamado da tela cta00m01 ]----------19/10/06
 if g_documento.aplnumdig is not null then
    let ws.succod     =  g_documento.succod
    let ws.aplnumdig  =  g_documento.aplnumdig
    let ws.itmnumdig  =  g_documento.itmnumdig
    let ws.prporg     =  g_documento.prporg
    let ws.prpnumdig  =  g_documento.prpnumdig
 end if
 -------[ alimenta as globais com apolice ou proposta do aviso consultado]----
 let g_documento.succod    = d_cts18m00.succod
 let g_documento.aplnumdig = d_cts18m00.aplnumdig
 let g_documento.itmnumdig = d_cts18m00.itmnumdig
 let g_documento.prporg    = d_cts18m00.prporgidv
 let g_documento.prpnumdig = d_cts18m00.prpnumidv
 ------------------------------------------------------------------------------

 if d_cts18m00.sinvclguinom is not null  then
    display "por" to sinvclguitxt
 end if

 select sinmotnom   ,
        cgccpfnum   ,
        cgcord      ,
        cgccpfdig   ,
        endlgd      ,
        endbrr      ,
        endcid      ,
        endufd      ,
        telnum      ,
        cnhnum      ,
        cnhvctdat   ,
        sinmotsex   ,
        cdtestcod   ,
        sinmotidd   ,
        sinmotprfcod,
        sinmotprfdes,
        sinsgrvin   ,
        sinlcldes   ,
        sinendcid   ,
        sinlclufd   ,
        sinvcllcldes,
        sinmotcplflg,
        vclatulgd   ,
        sinbocflg   ,
        dgcnum
   into a_cts18m00[1].sinmotnom,
        a_cts18m00[1].cgccpfnum,
        a_cts18m00[1].cgcord   ,
        a_cts18m00[1].cgccpfdig,
        a_cts18m00[1].endlgd   ,
        a_cts18m00[1].endbrr   ,
        a_cts18m00[1].endcid   ,
        a_cts18m00[1].endufd   ,
        a_cts18m00[1].telnum   ,
        a_cts18m00[1].cnhnum   ,
        a_cts18m00[1].cnhvctdat,
        a_cts18m00[1].sinmotsex,
        a_cts18m00[1].cdtestcod,
        a_cts18m00[1].sinmotidd,
        a_cts18m00[1].sinmotprfcod,
        a_cts18m00[1].sinmotprfdes,
        a_cts18m00[1].sinsgrvin   ,
        acid_cts18m00.sinlcldes   ,
        acid_cts18m00.sinendcid   ,
        acid_cts18m00.sinlclufd   ,
        acid_cts18m00.sinvcllcldes,
        acid_cts18m00.sinmotcplflg,
        acid_cts18m00.vclatulgd   ,
        acid_cts18m00.sinbocflg   ,
        acid_cts18m00.dgcnum
   from ssammot
  where sinavsnum    = param.sinavsnum  and
        sinavsano    = param.sinavsano  and
        sinsgrmotflg = "S"

 if a_cts18m00[1].sinmotprfcod is not null  and
    a_cts18m00[1].sinmotprfcod <> 999       then
    let a_cts18m00[1].sinmotprfdes = "*** NAO CADASTRADA ***"

    select irfprfdes
      into a_cts18m00[1].sinmotprfdes
      from ssakprf
     where irfprfcod = a_cts18m00[1].sinmotprfcod
 end if

 declare c_cts18m00_001 cursor with hold for
    select sinsgrmotflg,
           sinmotnom   ,
           cgccpfnum   ,
           cgcord      ,
           cgccpfdig   ,
           endlgd      ,
           endbrr      ,
           endcid      ,
           endufd      ,
           telnum      ,
           cnhnum      ,
           cnhvctdat   ,
           cdtestcod
      from ssammot
     where sinavsnum = param.sinavsnum  and
           sinavsano = param.sinavsano  and
           sinsgrmotflg in ("C", "T")

 foreach c_cts18m00_001 into ws.sinsgrmotflg        ,
                        a_cts18m00[2].sinmotnom,
                        a_cts18m00[2].cgccpfnum,
                        a_cts18m00[2].cgcord   ,
                        a_cts18m00[2].cgccpfdig,
                        a_cts18m00[2].endlgd   ,
                        a_cts18m00[2].endbrr   ,
                        a_cts18m00[2].endcid   ,
                        a_cts18m00[2].endufd   ,
                        a_cts18m00[2].telnum   ,
                        a_cts18m00[2].cnhnum   ,
                        a_cts18m00[2].cnhvctdat,
                        a_cts18m00[2].cdtestcod

    if acid_cts18m00.sinmotcplflg = "T"  and
       ws.sinsgrmotflg = "T"             then
       continue foreach
    end if
 end foreach

 if acid_cts18m00.sinmotcplflg = "T"  then
    select vclcoddig,
           sinbemdes,
           vclcorcod,
           vclchsnum,
           vcllicnum,
           vclanofbc,
           vclanomdl
      into d_cts18m00.trcvclcod,
           d_cts18m00.sinbemdes,
           d_cts18m00.trccorcod,
           d_cts18m00.trcvclchs,
           d_cts18m00.trcvcllic,
           d_cts18m00.trcanofbc,
           d_cts18m00.trcanomdl
      from ssamavsvcl
     where sinavsnum = param.sinavsnum  and
           sinavsano = param.sinavsano  and
           sinsgrvclflg = "C"
 end if

 if a_cts18m00[2].sinmotprfcod is not null  and
    a_cts18m00[2].sinmotprfcod <> 999       then
    let a_cts18m00[2].sinmotprfdes = "*** NAO CADASTRADA ***"

    select irfprfdes
      into a_cts18m00[2].sinmotprfdes
      from ssakprf
     where irfprfcod = a_cts18m00[2].sinmotprfcod
 end if
 if g_documento.succod    is not null  and
    g_documento.aplnumdig is not null  and
    g_documento.itmnumdig is not null  then
    let d_cts18m00.apolice = g_documento.succod    using "<<<&&", #"&&", projeto succod
                        " ", d_cts18m00.ramcod     using "&&&&",
                        " ", g_documento.aplnumdig using "<<<<<<<& &"

#--------------------------------------------------------------------
# Dados do corretor
#--------------------------------------------------------------------

    select corsus
      into d_cts18m00.corsus
      from abamcor
     where succod    = g_documento.succod     and
           aplnumdig = g_documento.aplnumdig  and
           corlidflg = "S"

    select gcakcorr.cornom  ,
           gcakfilial.dddcod,
           gcakfilial.teltxt
        #  gcakfilial.factxt
      into d_cts18m00.cornom   ,
           d_cts18m00.segdddcod,
           d_cts18m00.cortelnum
      from gcaksusep, gcakcorr, gcakfilial
     where gcaksusep.corsus     = d_cts18m00.corsus    and
           gcakcorr.corsuspcp   = gcaksusep.corsuspcp  and
           gcakfilial.corsuspcp = gcaksusep.corsuspcp  and
           gcakfilial.corfilnum = gcaksusep.corfilnum

    if d_cts18m00.ramcod = 53   or
       d_cts18m00.ramcod = 553  then

#--------------------------------------------------------------------
# Situacao da apolice na data de ocorrencia do sinistro
#--------------------------------------------------------------------

       call findeds (g_documento.succod   , g_documento.aplnumdig,
                     g_documento.itmnumdig, d_cts18m00.sinocrdat)
           returning ws.dctnumseq, ws.edsstt

       select edsnumdig
         into g_documento.edsnumref
         from abamdoc
        where succod     =  g_documento.succod      and
              aplnumdig  =  g_documento.aplnumdig   and
              dctnumseq  =  ws.dctnumseq

       call f_funapol_auto (g_documento.succod   , g_documento.aplnumdig,
                            g_documento.itmnumdig, g_documento.edsnumref)
                  returning g_funapol.*

#--------------------------------------------------------------------
# Dados do segurado
#--------------------------------------------------------------------
       select segnumdig
         into ws.segnumdig
         from abbmdoc
        where succod    = g_documento.succod    and
              aplnumdig = g_documento.aplnumdig and
              itmnumdig = g_documento.itmnumdig and
              dctnumseq = g_funapol.dctnumseq

       select segnom
         into d_cts18m00.segnom
         from gsakseg
        where segnumdig  =  ws.segnumdig

       select dddcod, teltxt
         into d_cts18m00.segdddcod,
              d_cts18m00.segtelnum
         from gsakend
        where segnumdig  =  ws.segnumdig    and
              endfld     =  "1"

#--------------------------------------------------------------------
# Dados do veiculo
#--------------------------------------------------------------------

       select vclcoddig,
              vcllicnum,
              vclanofbc,
              vclanomdl,
              vclchsinc,
              vclchsfnl
         into d_cts18m00.vclcoddig,
              d_cts18m00.vcllicnum,
              d_cts18m00.vclanofbc,
              d_cts18m00.vclanomdl,
              ws.vclchsinc        ,
              ws.vclchsfnl
         from abbmveic
        where succod    = g_documento.succod     and
              aplnumdig = g_documento.aplnumdig  and
              itmnumdig = g_documento.itmnumdig  and
              dctnumseq = g_funapol.vclsitatu

       if sqlca.sqlcode = notfound  then
          select vclcoddig,
                 vcllicnum,
                 vclanofbc,
                 vclanomdl,
                 vclchsinc,
                 vclchsfnl
            into d_cts18m00.vclcoddig,
                 d_cts18m00.vcllicnum,
                 d_cts18m00.vclanofbc,
                 d_cts18m00.vclanomdl,
                 ws.vclchsinc        ,
                 ws.vclchsfnl
            from abbmveic
           where succod    = g_documento.succod      and
                 aplnumdig = g_documento.aplnumdig   and
                 itmnumdig = g_documento.itmnumdig   and
                 dctnumseq = (select max(dctnumseq)
                                from abbmveic
                               where succod    = g_documento.succod      and
                                     aplnumdig = g_documento.aplnumdig   and
                                     itmnumdig = g_documento.itmnumdig)
       end if

       if sqlca.sqlcode <> notfound  then
          call veiculo_cts18m00(d_cts18m00.vclcoddig)
               returning d_cts18m00.vcldes
       end if

       let d_cts18m00.vclchsnum = ws.vclchsinc clipped, ws.vclchsfnl clipped
    end if
 end if

 display by name d_cts18m00.sinocrdat, d_cts18m00.sinocrhor,
                 d_cts18m00.segnom thru d_cts18m00.sinvclguinom

 if d_cts18m00.ramcod = 31   or
    d_cts18m00.ramcod = 531  then
    call cts18m01("S", d_cts18m00.ramcod, d_cts18m00.segnom, a_cts18m00[1].*
                 #-----> PSI 172090
                 ,g_documento.succod    ,g_documento.aplnumdig
                 ,g_documento.itmnumdig ,d_cts18m00.prporgidv
                 ,d_cts18m00.prpnumidv)
        returning a_cts18m00[1].*
 end if
 ---------[ devolve a salva qdo chamado da tela cta00m01 ]------19/10/06
 if ws.aplnumdig is not null then
    let g_documento.succod     =  ws.succod
    let g_documento.aplnumdig  =  ws.aplnumdig
    let g_documento.itmnumdig  =  ws.itmnumdig
    let g_documento.prporg     =  ws.prporg
    let g_documento.prpnumdig  =  ws.prpnumdig
 end if

end function  ###  seleciona_cts18m00

#--------------------------------------------------------------------
 function modifica_cts18m00(param)
#--------------------------------------------------------------------

 define param         record
    sinavsnum         like ssamavs.sinavsnum    ,
    sinavsano         like ssamavs.sinavsano
 end record

 define ws            record
    tabname           like systables.tabname,
    codigosql         integer               ,
    confirma          char (01)
 end record



        initialize  ws.*  to  null

 let d_cts18m00.sinavsnum = param.sinavsnum
 let d_cts18m00.sinavsano = param.sinavsano

 if d_cts18m00.ramcod = 31   or
    d_cts18m00.ramcod = 531  then
    if a_cts18m00[1].sinmotnom is null  then
       call cts08g01("A","N","","HOUVE UM ERRO INTERNO DURANTE O",
                                "PREENCHIMENTO DO AVISO. FAVOR",
                                "COMUNICAR A INFORMATICA!")
            returning ws.confirma
       return
    end if
 else
    if d_cts18m00.sinrclnom is null  then
       call cts08g01("A","N","","HOUVE UM ERRO INTERNO DURANTE O",
                                "PREENCHIMENTO DO AVISO. FAVOR",
                                "COMUNICAR A INFORMATICA!")
            returning ws.confirma
       return
    end if
 end if

 whenever error continue

 begin work

 message " Aguarde, gravando alteracoes realizadas... " attribute (reverse)

#--------------------------------------------------------------------
# Atualiza AVISO DE SINISTRO para SEGURADO (Ramo 31)
#--------------------------------------------------------------------

 if d_cts18m00.ramcod = 31   or
    d_cts18m00.ramcod = 531  then
    call ssamavs_upd (d_cts18m00.sinavsnum      ,
                      d_cts18m00.sinavsano      ,
                      d_cts18m00.segnom         ,
                      d_cts18m00.segtelnum      ,
                      d_cts18m00.cgccpfnum      ,
                      d_cts18m00.cgcord         ,
                      d_cts18m00.cgccpfdig      ,
                      d_cts18m00.vclcoddig      ,
                      ""                        ,
                      d_cts18m00.vclchsnum      ,
                      d_cts18m00.vcllicnum      ,
                      d_cts18m00.vclanofbc      ,
                      d_cts18m00.vclanomdl      ,
                      d_cts18m00.sinrclsgrflg   ,
                      d_cts18m00.sinrclsgdnom   ,
                      d_cts18m00.sinrclapltxt   ,
                      acid_cts18m00.sinrclcpdflg,
                      d_cts18m00.sinvclguiflg   ,
                      d_cts18m00.sinvclguinom   ,
                      d_cts18m00.endlgd         ,
                      ""                        ,
                      d_cts18m00.endcid         ,
                      d_cts18m00.endufd         ,
                      d_cts18m00.sinbemdes      ,
                      acid_cts18m00.sinntzcod   ,
                      2                         , #prdtipcod 2=perda parcial
                      ""                        , #chsliccnfflg
                      ""                        , #docrouflg
                      ""                        , #docroutxt
                      ""                        , #sinavsobs
                      ""                        , #sinrbftip
                      ""                        , #sinlclcep
                      a_cts18m00[2].endbrr      , #sinrclbrrnom
                      ""                        , #sinrclprimotflg
                      ""                        , #sinmotidd
                      ""                        , #trcaplvigfnl
                      ""                      )   #trcaplviginc
            returning ws.tabname, ws.codigosql

    if ws.codigosql <> 0  then
       error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
             " na atualizacao do aviso de sinistro (ramo 531).",
             " AVISE A INFORMATICA!"
       rollback work
       close window w_cts18m00
       return
    end if

#--------------------------------------------------------------------
# Se o culpado for o TERCEIRO, atualiza dados do CAUSADOR do acidente
#--------------------------------------------------------------------

    if acid_cts18m00.sinmotcplflg = "T"  then
       call ssamavsvcl_upd(d_cts18m00.sinavsnum,
                           d_cts18m00.sinavsano,
                           "C"                 ,
                           d_cts18m00.trcvclcod,
                           d_cts18m00.trccorcod,
                           d_cts18m00.trcvclchs,
                           d_cts18m00.trcvcllic,
                           d_cts18m00.trcanofbc,
                           d_cts18m00.trcanomdl,
                           d_cts18m00.sinbemdes)
                 returning ws.tabname, ws.codigosql

       if ws.codigosql <> 0  then
          error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
                " na atualizacao do veiculo do causador. AVISE A INFORMATICA!"
          rollback work
          close window w_cts18m00
          return
       end if

       call ssammot_upd (d_cts18m00.sinavsnum      ,
                         d_cts18m00.sinavsano      ,
                         "C"                       ,
                         a_cts18m00[2].sinmotnom   ,
                         a_cts18m00[2].cgccpfnum   ,
                         a_cts18m00[2].endlgd      ,
                         a_cts18m00[2].endbrr      ,
                         a_cts18m00[2].endcid      ,
                         a_cts18m00[2].endufd      ,
                         a_cts18m00[2].dddcod      ,
                         a_cts18m00[2].telnum      ,
                         a_cts18m00[2].cnhnum      ,
                         a_cts18m00[2].cnhvctdat   ,
                         ""                        ,
                         ""                        ,
                         ""                        ,
                         ""                        ,
                         ""                        ,
                         a_cts18m00[2].sinmotsex   ,
                         a_cts18m00[2].sinmotprfcod,
                         a_cts18m00[2].sinsgrvin   ,
                         a_cts18m00[2].sinmotidd   ,
                         acid_cts18m00.sinmotcplflg,
                         a_cts18m00[2].cgcord      ,
                         a_cts18m00[2].cgccpfdig   ,
                         ""                        ,
                         a_cts18m00[2].sinmotprfdes,
                         ""                        ,
                         a_cts18m00[2].cdtestcod   )
               returning ws.tabname, ws.codigosql

       if ws.codigosql <> 0  then
          error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
                " na atualizacao do motorista do causador. AVISE A INFORMATICA!"
          rollback work
          close window w_cts18m00
          return
       end if
    end if
 else

#--------------------------------------------------------------------
# Atualiza AVISO DE SINISTRO para TERCEIRO (Ramo 53)
#--------------------------------------------------------------------

    call ssamavs_upd (d_cts18m00.sinavsnum   ,
                      d_cts18m00.sinavsano   ,
                      d_cts18m00.sinrclnom   ,
                      d_cts18m00.trctelnum   ,
                      d_cts18m00.cgccpfnum   ,
                      d_cts18m00.cgcord      ,
                      d_cts18m00.cgccpfdig   ,
                      d_cts18m00.trcvclcod   ,
                      d_cts18m00.trccorcod   ,
                      d_cts18m00.trcvclchs   ,
                      d_cts18m00.trcvcllic   ,
                      d_cts18m00.trcanofbc   ,
                      d_cts18m00.trcanomdl   ,
                      d_cts18m00.sinrclsgrflg,
                      d_cts18m00.sinrclsgdnom,
                      d_cts18m00.sinrclapltxt,
                      acid_cts18m00.sinrclcpdflg,
                      d_cts18m00.sinvclguiflg,
                      d_cts18m00.sinvclguinom,
                      d_cts18m00.endlgd      ,
                      ""                     ,
                      d_cts18m00.endcid      ,
                      d_cts18m00.endufd      ,
                      d_cts18m00.sinbemdes   ,
                      acid_cts18m00.sinntzcod,
                      2                         , #prdtipcod 2=perda parcial
                      ""                        , #chsliccnfflg
                      ""                        , #docrouflg
                      ""                        , #docroutxt
                      ""                        , #sinavsobs
                      ""                        , #sinrbftip
                      ""                        , #sinlclcep
                      a_cts18m00[2].endbrr      , #sinrclbrrnom
                      ""                        , #sinrclprimotflg
                      ""                        , #sinmotidd
                      ""                        , #trcaplvigfnl
                      ""                      )   #trcaplviginc
            returning ws.tabname, ws.codigosql

    if ws.codigosql <> 0  then
       error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
             " na atualizacao do aviso de sinistro (ramo 553).",
             " AVISE A INFORMATICA!"
       rollback work
       close window w_cts18m00
       return
    end if

#--------------------------------------------------------------------
# Atualiza MOTORISTA DO TERCEIRO (Ramo 53)
#--------------------------------------------------------------------

    call ssammot_upd (d_cts18m00.sinavsnum      ,
                      d_cts18m00.sinavsano      ,
                      "T"                       ,
                      a_cts18m00[2].sinmotnom   ,
                      a_cts18m00[2].cgccpfnum   ,
                      a_cts18m00[2].endlgd      ,
                      a_cts18m00[2].endbrr      ,
                      a_cts18m00[2].endcid      ,
                      a_cts18m00[2].endufd      ,
                      a_cts18m00[2].dddcod      ,
                      a_cts18m00[2].telnum      ,
                      a_cts18m00[2].cnhnum      ,
                      a_cts18m00[2].cnhvctdat   ,
                      ""                        ,
                      ""                        ,
                      ""                        ,
                      ""                        ,
                      ""                        ,
                      a_cts18m00[2].sinmotsex   ,
                      a_cts18m00[2].sinmotprfcod,
                      a_cts18m00[2].sinsgrvin   ,
                      a_cts18m00[2].sinmotidd   ,
                      acid_cts18m00.sinmotcplflg,
                      a_cts18m00[2].cgcord      ,
                      a_cts18m00[2].cgccpfdig   ,
                      ""                        ,
                      a_cts18m00[2].sinmotprfdes,
                      ""                        ,
                      a_cts18m00[2].cdtestcod   )
            returning ws.tabname, ws.codigosql

    if ws.codigosql <> 0  then
       error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
             " na atualizacao do motorista do terceiro. AVISE A INFORMATICA!"
       rollback work
       close window w_cts18m00
       return
    end if
 end if

#--------------------------------------------------------------------
# Atualiza MOTORISTA DO SEGURADO (Ramo 31)
#--------------------------------------------------------------------

 call ssammot_upd (d_cts18m00.sinavsnum      ,
                   d_cts18m00.sinavsano      ,
                   "S"                       ,
                   a_cts18m00[1].sinmotnom   ,
                   a_cts18m00[1].cgccpfnum   ,
                   a_cts18m00[1].endlgd      ,
                   a_cts18m00[1].endbrr      ,
                   a_cts18m00[1].endcid      ,
                   a_cts18m00[1].endufd      ,
                   a_cts18m00[1].dddcod      ,
                   a_cts18m00[1].telnum      ,
                   a_cts18m00[1].cnhnum      ,
                   a_cts18m00[1].cnhvctdat   ,
                   acid_cts18m00.sinlcldes   ,
                   acid_cts18m00.sinlclufd   ,
                   acid_cts18m00.sinendcid   ,
                   acid_cts18m00.sinbocflg   ,
                   acid_cts18m00.sinvcllcldes,
                   a_cts18m00[1].sinmotsex   ,
                   a_cts18m00[1].sinmotprfcod,
                   a_cts18m00[1].sinsgrvin   ,
                   a_cts18m00[1].sinmotidd   ,
                   acid_cts18m00.sinmotcplflg,
                   a_cts18m00[1].cgcord      ,
                   a_cts18m00[1].cgccpfdig   ,
                   acid_cts18m00.vclatulgd   ,
                   a_cts18m00[1].sinmotprfdes,
                   acid_cts18m00.dgcnum      ,
                   a_cts18m00[1].cdtestcod   )
         returning ws.tabname, ws.codigosql

 if ws.codigosql <> 0  then
    error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
          " na atualizacao do motorista do segurado. AVISE A INFORMATICA!"
    rollback work
    close window w_cts18m00
    return
 end if

 commit work

 whenever error stop
 error " Alteracoes efetuadas com sucesso!"

end function  ###  modifica_cts18m00

#--------------------------------------------------------------------
 function inclui_cts18m00()
#--------------------------------------------------------------------

 define prompt_key    char (01)

 define ws            record
    lignum            like datmligacao.lignum,
    tabname           like systables.tabname,
    codigosql         integer ,
    confirma          char (01),

    prompt_key        char(01)                   ,
    retorno           smallint                   ,
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    msg               char(80),
    dtresol86         date,
    emsdat            like abamdoc.emsdat,
    ramcod            like gtakram.ramcod,
    email             char (300)
 end record

 define l_data          date,
        l_hora2         datetime hour to minute

 define l_msg_pri   char(100)

 define  l_mail             record
      de                 char(500)   # De
     ,para               char(5000)  # Para
     ,cc                 char(500)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
  end  record
  define l_coderro  smallint
  define msg_erro char(500)
        let     prompt_key  =  null

        initialize  ws.*  to  null

 initialize ws.*  to null

 call input_cts18m00("I")

 if int_flag  then
    let int_flag = false
    error " Operacao cancelada! (7)"
    initialize d_cts18m00.*     to null
    initialize a_cts18m00       to null
    initialize acid_cts18m00.*  to null
    close window w_cts18m00
    return
 end if

 if d_cts18m00.ramcod = 31   or
    d_cts18m00.ramcod = 531  then
    if a_cts18m00[1].sinmotnom is null  then
       call cts08g01("A","N","","HOUVE UM ERRO INTERNO DURANTE O",
                                "PREENCHIMENTO DO AVISO. FAVOR",
                                "COMUNICAR A INFORMATICA!")
            returning ws.confirma
       close window w_cts18m00
       return
    end if
 else
    if d_cts18m00.sinrclnom is null  then
       call cts08g01("A","N","","HOUVE UM ERRO INTERNO DURANTE O",
                                "PREENCHIMENTO DO AVISO. FAVOR",
                                "COMUNICAR A INFORMATICA!")
            returning ws.confirma
       close window w_cts18m00
       return
    end if
 end if
 #-----------------------------------------------------------------------------
 # Busca numeracao ligacao
 #----------------------------------------------------------------------------
 begin work
 call cts10g03_numeracao( 1, "" )
       returning ws.lignum   ,
                 ws.atdsrvnum,
                 ws.atdsrvano,
                 ws.codigosql,
                 ws.msg

 if  ws.codigosql =  0 then
     commit work
 else
     let ws.msg = "CTS18M00 -", ws.msg
     call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
     rollback work
     prompt "" for char ws.prompt_key
     return
 end if
 let g_documento.lignum = ws.lignum
 let aux_atdsrvnum      = ws.atdsrvnum
 let aux_atdsrvano      = ws.atdsrvano

 begin work

 whenever error continue

#--------------------------------------------------------------------
# Grava AVISO DE SINISTRO para SEGURADO (Ramo 31)
#--------------------------------------------------------------------

 if d_cts18m00.ramcod = 31   or
    d_cts18m00.ramcod = 531  then
    call ssamavs_ins (g_documento.succod        ,
                      g_documento.aplnumdig     ,
                      g_documento.itmnumdig     ,
                      d_cts18m00.sinvstano      ,
                      d_cts18m00.sinvstnum      ,
                      0                         ,
                      d_cts18m00.sinocrdat      ,
                      d_cts18m00.sinocrhor      ,
                      d_cts18m00.segnom         ,
                      d_cts18m00.segtelnum      ,
                      d_cts18m00.cgccpfnum      ,
                      d_cts18m00.cgcord         ,
                      d_cts18m00.cgccpfdig      ,
                      d_cts18m00.vclcoddig      ,
                      ""                        ,
                      d_cts18m00.vclchsnum      ,
                      d_cts18m00.vcllicnum      ,
                     d_cts18m00.vclanofbc      ,
                      d_cts18m00.vclanomdl      ,
                      d_cts18m00.sinrclsgrflg   ,
                      d_cts18m00.sinrclsgdnom   ,
                      acid_cts18m00.sinrclcpdflg,
                      d_cts18m00.sinvclguiflg   ,
                      d_cts18m00.sinvclguinom   ,
                      d_cts18m00.ramcod         ,
                      d_cts18m00.subcod         ,
                      d_cts18m00.prporgidv      ,
                      d_cts18m00.prpnumidv      ,
                      g_issk.dptsgl             ,
                      g_issk.funmat             ,
                      d_cts18m00.endlgd         ,
                      ""                        ,
                      d_cts18m00.endcid         ,
                      d_cts18m00.endufd         ,
                      ""                        ,
                      ""                        ,
                      ""                        ,
                      d_cts18m00.sinrclapltxt   ,
                      acid_cts18m00.sinntzcod   ,
                      2                         , #prdtipcod 2=perda parcial
                      ""                        , #chsliccnfflg
                      ""                        , #docrouflg
                      ""                        , #docroutxt
                      ""                        , #sinavsobs
                      ""                        , #sinrbftip
                      ""                        , #sinlclcep
                      a_cts18m00[2].endbrr      , #sinrclbrrnom
                      ""                        , #sinrclprimotflg
                      ""                        , #sinmotidd
                      ""                        , #trcaplvigfnl
                      ""                      )   #trcaplviginc
            returning d_cts18m00.sinavsnum,
                      d_cts18m00.sinavsano,
                      ws.tabname, ws.codigosql
    if ws.codigosql <> 0 or d_cts18m00.sinavsnum is null or
       d_cts18m00.sinavsnum = 0 then
       error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
             " na gravacao do aviso de sinistro (ramo 531).AVISE A INFORMATICA!"
       call errorlog ("ERRO NA INCLUSAO ssamavs_ins 531 ")
       call errorlog (ws.codigosql)
       call errorlog (d_cts18m00.sinavsnum)
       call errorlog (d_cts18m00.sinavsano)
       call errorlog ("-----------------------------------------")
       rollback work
       close window w_cts18m00
       return
    end if

    if g_documento.aplnumdig is null and d_cts18m00.vcllicnum is null then
       #let ws.email  = "echo ' Suc: ",g_documento.succod using "<<<&&", #"&&", projeto succod
       #                " gRamo: ",g_documento.ramcod using "&&&&",
       #                " Apl:  ",g_documento.aplnumdig using "<<<<<<<& &",
       #                " wPla: ",d_cts18m00.vcllicnum using "&&&&&&&", "'|",
       #                " Numero: ",d_cts18m00.sinavsnum using "<<<<<<",
       #                "mailx -r 'danubio_ct24h/spaulo_info_sistemas@u55'",
       #                " -s 'Problemas na Gravacao do Sinistro '",
       #                " 'kiandra.antonello@correioporto'",
       #                " 'carlos.ruiz@correioporto'"
       #run ws.email
   end if

#--------------------------------------------------------------------
# Se o culpado for o TERCEIRO, grava dados do CAUSADOR do acidente
#--------------------------------------------------------------------

    if acid_cts18m00.sinmotcplflg = "T"  then
       call ssamavsvcl_ins(d_cts18m00.sinavsnum,
                           d_cts18m00.sinavsano,
                           "C"                 ,
                           d_cts18m00.trcvclcod,
                           d_cts18m00.trccorcod,
                           d_cts18m00.trcvclchs,
                           d_cts18m00.trcvcllic,
                           d_cts18m00.trcanofbc,
                           d_cts18m00.trcanomdl,
                           d_cts18m00.sinbemdes)
                 returning ws.tabname, ws.codigosql

       if ws.codigosql <> 0  then
          error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
                " na gravacao do veiculo do causador. AVISE A INFORMATICA!"
          call errorlog ("ERRO NA INCLUSAO - ssamavsvcl causador")
          call errorlog (ws.codigosql)
          call errorlog (d_cts18m00.sinavsnum)
          call errorlog (d_cts18m00.sinavsano)
          call errorlog ("-----------------------------------------")
          rollback work
          close window w_cts18m00
          return
       end if
       call ssammot_ins (d_cts18m00.sinavsnum      ,
                         d_cts18m00.sinavsano      ,
                         "C"                       ,
                         ""                        ,
                         ""                        ,
                         ""                        ,
                         a_cts18m00[2].sinmotnom   ,
                         a_cts18m00[2].cgccpfnum   ,
                         a_cts18m00[2].endlgd      ,
                         a_cts18m00[2].endbrr      ,
                         a_cts18m00[2].endcid      ,
                         a_cts18m00[2].endufd      ,
                         a_cts18m00[2].dddcod      ,
                         a_cts18m00[2].telnum      ,
                         a_cts18m00[2].cnhnum      ,
                         a_cts18m00[2].cnhvctdat   ,
                         ""                        ,
                         ""                        ,
                         ""                        ,
                         ""                        ,
                         ""                        ,
                         a_cts18m00[2].sinmotsex   ,
                         a_cts18m00[2].sinmotprfcod,
                         a_cts18m00[2].sinsgrvin   ,
                         a_cts18m00[2].sinmotidd   ,
                         acid_cts18m00.sinmotcplflg,
                         a_cts18m00[2].cgcord      ,
                         a_cts18m00[2].cgccpfdig   ,
                         ""                        ,
                         a_cts18m00[2].sinmotprfdes,
                         ""                        ,
                         a_cts18m00[2].cdtestcod   )
               returning ws.tabname, ws.codigosql

       if ws.codigosql <> 0  then
          error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
                " na gravacao do motorista do causador. AVISE A INFORMATICA!"
          call errorlog ("ERRO NA INCLUSAO - ssammot_ins mot.causador")
          call errorlog (ws.codigosql)
          call errorlog (d_cts18m00.sinavsnum)
          call errorlog (d_cts18m00.sinavsano)
          call errorlog ("-----------------------------------------")
          rollback work
          close window w_cts18m00
          return
       end if
    end if
 else

#--------------------------------------------------------------------
# Grava AVISO DE SINISTRO para TERCEIRO (Ramo 53)
#--------------------------------------------------------------------
    call ssamavs_ins (g_documento.succod     ,
                      g_documento.aplnumdig  ,
                      g_documento.itmnumdig  ,
                      d_cts18m00.sinvstano   ,
                      d_cts18m00.sinvstnum   ,
                      1                      ,
                      d_cts18m00.sinocrdat   ,
                      d_cts18m00.sinocrhor   ,
                      d_cts18m00.sinrclnom   ,
                      d_cts18m00.trctelnum   ,
                      d_cts18m00.cgccpfnum   ,
                      d_cts18m00.cgcord      ,
                      d_cts18m00.cgccpfdig   ,
                      d_cts18m00.trcvclcod   ,
                      d_cts18m00.trccorcod   ,
                      d_cts18m00.trcvclchs   ,
                      d_cts18m00.trcvcllic   ,
                      d_cts18m00.trcanofbc   ,
                      d_cts18m00.trcanomdl   ,
                      d_cts18m00.sinrclsgrflg,
                      d_cts18m00.sinrclsgdnom,
                      acid_cts18m00.sinrclcpdflg,
                      d_cts18m00.sinvclguiflg,
                      d_cts18m00.sinvclguinom,
                      d_cts18m00.ramcod      ,
                      d_cts18m00.subcod      ,
                      d_cts18m00.prporgidv   ,
                      d_cts18m00.prpnumidv   ,
                      g_issk.dptsgl          ,
                      g_issk.funmat          ,
                      d_cts18m00.endlgd      ,
                      ""                     ,
                      d_cts18m00.endcid      ,
                      d_cts18m00.endufd      ,
                      ""                     ,
                      ""                     ,
                      d_cts18m00.sinbemdes   ,
                      d_cts18m00.sinrclapltxt,
                      acid_cts18m00.sinntzcod,
                      2                         , #prdtipcod 2=perda parcial
                      ""                        , #chsliccnfflg
                      ""                        , #docrouflg
                      ""                        , #docroutxt
                      ""                        , #sinavsobs
                      ""                        , #sinrbftip
                      ""                        , #sinlclcep
                      a_cts18m00[2].endbrr      , #sinrclbrrnom
                      ""                        , #sinrclprimotflg
                      ""                        , #sinmotidd
                      d_cts18m00.viginc         , #trcaplvigfnl
                      d_cts18m00.vigfnl       )   #trcaplviginc
            returning d_cts18m00.sinavsnum,
                      d_cts18m00.sinavsano,
                      ws.tabname, ws.codigosql
    if ws.codigosql <> 0 or d_cts18m00.sinavsnum is null or
       d_cts18m00.sinavsnum = 0 then
       error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
             " na gravacao do aviso de sinistro (ramo 553).AVISE A INFORMATICA!"
       call errorlog ("ERRO NA INCLUSAO ssamavs_ins 553")
       call errorlog (ws.codigosql)
       call errorlog (d_cts18m00.sinavsnum)
       call errorlog (d_cts18m00.sinavsano)
       call errorlog ("-----------------------------------------")
       rollback work
       close window w_cts18m00
       return
    end if

#--------------------------------------------------------------------
# Grava MOTORISTA DO TERCEIRO (Ramo 53)
#--------------------------------------------------------------------

    call ssammot_ins (d_cts18m00.sinavsnum      ,
                      d_cts18m00.sinavsano      ,
                      "T"                       ,
                      ""                        ,
                      ""                        ,
                      ""                        ,
                      a_cts18m00[2].sinmotnom   ,
                      a_cts18m00[2].cgccpfnum   ,
                      a_cts18m00[2].endlgd      ,
                      a_cts18m00[2].endbrr      ,
                      a_cts18m00[2].endcid      ,
                      a_cts18m00[2].endufd      ,
                      a_cts18m00[2].dddcod      ,
                      a_cts18m00[2].telnum      ,
                      a_cts18m00[2].cnhnum      ,
                      a_cts18m00[2].cnhvctdat   ,
                      ""                        ,
                      ""                        ,
                      ""                        ,
                      ""                        ,
                      ""                        ,
                      a_cts18m00[2].sinmotsex   ,
                      a_cts18m00[2].sinmotprfcod,
                      a_cts18m00[2].sinsgrvin   ,
                      a_cts18m00[2].sinmotidd   ,
                      acid_cts18m00.sinmotcplflg,
                      a_cts18m00[2].cgcord      ,
                      a_cts18m00[2].cgccpfdig   ,
                      ""                        ,
                      a_cts18m00[2].sinmotprfdes,
                      ""                        ,
                      a_cts18m00[2].cdtestcod   )
            returning ws.tabname, ws.codigosql

    if ws.codigosql <> 0  then
       error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
             " na gravacao do motorista do terceiro. AVISE A INFORMATICA!"
       call errorlog ("ERRO NA INCLUSAO - ssammot_ins 53 mot.terceiro")
       call errorlog (ws.codigosql)
       call errorlog (d_cts18m00.sinavsnum)
       call errorlog (d_cts18m00.sinavsano)
       call errorlog ("-----------------------------------------")
       rollback work
       close window w_cts18m00
       return
    end if
       if g_documento.aplnumdig is null and d_cts18m00.vcllicnum is null then
          #let ws.email  = "echo ' Suc: ",g_documento.succod using "<<<&&", #"&&", projeto succod
          #                " gRamo: ",g_documento.ramcod using "&&&&",
          #                " Apl:  ",g_documento.aplnumdig using "<<<<<<<& &",
          #                " wPla: ",d_cts18m00.vcllicnum using "&&&&&&&", "'|",
          #                " Numero: ",d_cts18m00.sinavsnum using "<<<<<<",
          #                "mailx -r 'danubio_ct24h/spaulo_info_sistemas@u55'",
          #                " -s 'Problemas na Gravacao do Sinistro T'",
          #                " 'kiandra.antonello@correioporto'",
          #                " 'carlos.ruiz@correioporto'"
          #run ws.email
       end if
 end if

#--------------------------------------------------------------------
# Grava MOTORISTA DO SEGURADO (Ramo 31)
#--------------------------------------------------------------------

 call ssammot_ins (d_cts18m00.sinavsnum      ,
                   d_cts18m00.sinavsano      ,
                   "S"                       ,
                   ""                        ,
                   ""                        ,
                   ""                        ,
                   a_cts18m00[1].sinmotnom   ,
                   a_cts18m00[1].cgccpfnum   ,
                   a_cts18m00[1].endlgd      ,
                   a_cts18m00[1].endbrr      ,
                   a_cts18m00[1].endcid      ,
                   a_cts18m00[1].endufd      ,
                   a_cts18m00[1].dddcod      ,
                   a_cts18m00[1].telnum      ,
                   a_cts18m00[1].cnhnum      ,
                   a_cts18m00[1].cnhvctdat   ,
                   acid_cts18m00.sinlcldes   ,
                   acid_cts18m00.sinlclufd   ,
                   acid_cts18m00.sinendcid   ,
                   acid_cts18m00.sinbocflg   ,
                   acid_cts18m00.sinvcllcldes,
                   a_cts18m00[1].sinmotsex   ,
                   a_cts18m00[1].sinmotprfcod,
                   a_cts18m00[1].sinsgrvin   ,
                   a_cts18m00[1].sinmotidd   ,
                   acid_cts18m00.sinmotcplflg,
                   a_cts18m00[1].cgcord      ,
                   a_cts18m00[1].cgccpfdig   ,
                   acid_cts18m00.vclatulgd   ,
                   a_cts18m00[1].sinmotprfdes,
                   acid_cts18m00.dgcnum      ,
                   a_cts18m00[1].cdtestcod   )
         returning ws.tabname, ws.codigosql

 if ws.codigosql <> 0  then
    error " Erro (", ws.tabname clipped, ": ", ws.codigosql, ")",
          " na gravacao do motorista do segurado. AVISE A INFORMATICA!"
    call errorlog ("ERRO NA INCLUSAO - ssammot_ins 31 mot.seg.")
    call errorlog (ws.codigosql)
    call errorlog (d_cts18m00.sinavsnum)
    call errorlog (d_cts18m00.sinavsano)
    call errorlog ("-----------------------------------------")
    rollback work
    close window w_cts18m00
    return
 end if

#--------------------------------------------------------------------
# Grava informacoes de FURTO/ROUBO
#--------------------------------------------------------------------
#
#if acid_cts18m00.sinntzcod = 30  or
#   acid_cts18m00.sinntzcod = 36  or
#   acid_cts18m00.sinntzcod = 64  or
#   acid_cts18m00.sinntzcod = 68  then
#   call fgavsrbf(acid_cts18m00.avsrbfsegvitflg ,
#                 acid_cts18m00.segrbfantsim    ,
#                 acid_cts18m00.segrbfantnao    ,
#                 acid_cts18m00.segrbfantnaosabe,
#                 acid_cts18m00.segqtdum        ,
#                 acid_cts18m00.segqtddois      ,
#                 acid_cts18m00.segqtdtres      ,
#                 acid_cts18m00.segqtdmaistres  ,
#                 acid_cts18m00.segqtdnaosabe   ,
#                 acid_cts18m00.vitrbfantsim    ,
#                 acid_cts18m00.vitrbfantnao    ,
#                 acid_cts18m00.vitrbfantnaosabe,
#                 acid_cts18m00.vitqtdum        ,
#                 acid_cts18m00.vitqtddois      ,
#                 acid_cts18m00.vitqtdtres      ,
#                 acid_cts18m00.vitqtdmaistres  ,
#                 acid_cts18m00.vitqtdnaosabe   ,
#                 d_cts18m00.sinavsano       ,
#                 d_cts18m00.sinavsnum       ,
#                 g_issk.empcod              ,
#                 g_issk.funmat              )
#       returning ws.tabname, ws.codigosql
#
#   if ws.codigosql <> 0  then
#      error " Erro (", ws.codigosql, ") na gravacao dos dados de furto/roubo. AVISE A INFORMATICA!"
#      rollback work
#      close window w_cts18m00
#      return
#   end if
#end if

#--------------------------------------------------------------------
# Grava LIGACAO da Central 24 Horas (caso haja apolice)
#--------------------------------------------------------------------

 ----------------------[ verifica ramo - ramcod ]-------------------------
 if g_documento.ramcod = 31 or
    g_documento.ramcod = 531 then
    if g_documento.succod    is not null and
       g_documento.aplnumdig is not null then
       select grlinf[01,10] into ws.dtresol86
          from datkgeral
          where grlchv='ct24resolucao86'
       select emsdat into ws.emsdat
          from abamdoc
       where succod    = g_documento.succod
         and aplnumdig = g_documento.aplnumdig
         and edsnumdig = 0
       if ws.emsdat >= ws.dtresol86 then
          let ws.ramcod = 531
       else
          let ws.ramcod = 31
       end if
       if ws.ramcod <> g_documento.ramcod then
          let ws.email = " Suc: ",g_documento.succod using "<<<&&", #"&&", projeto succod
               " gRamo: ",g_documento.ramcod using "&&&&",
               " Apl:  ",g_documento.aplnumdig using "<<<<<<<& &",
               " wRamo: ",ws.ramcod using "&&&&",
               " Assunto: ",g_documento.c24astcod
          let g_documento.ramcod = ws.ramcod
         #PSI-2013-23297 - Inicio
         let l_mail.de = "c24hs.email@portoseguro.com.br"
         let l_mail.para = "sistemas.madeira@portoseguro.com.br"
         #let l_mail.para = "carlos.ruiz@portoseguro.com.br"
         let l_mail.cc = ""
         let l_mail.cco = ""
         let l_mail.assunto = "Divergencias entre RAMOS"
         let l_mail.mensagem = ws.email
         let l_mail.id_remetente = "CT24H"
         let l_mail.tipo = "text"
         call figrc009_mail_send1 (l_mail.*)
          returning l_coderro,msg_erro
         #PSI-2013-23297 - Fim
         #display ws.email
       end if
    end if
 end if

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
 call cts10g00_ligacao (g_documento.lignum ,
                        l_data              ,
                        l_hora2               ,
                        g_documento.c24soltipcod,
                        g_documento.solnom    ,
                        g_documento.c24astcod ,
                        g_issk.funmat         ,
                        g_documento.ligcvntip ,
                        g_c24paxnum           ,
                        "","","","",
                        d_cts18m00.sinavsnum  ,
                        d_cts18m00.sinavsano  ,
                        g_documento.succod    ,
                        g_documento.ramcod    , #31                    ,
                        g_documento.aplnumdig ,
                        g_documento.itmnumdig ,
                        g_documento.edsnumref ,
                        g_documento.prporg    ,
                        g_documento.prpnumdig ,
                        g_documento.fcapacorg ,
                        g_documento.fcapacnum ,
                        "","","","",
                        "", "", "", ""        )
              returning  ws.tabname, ws.codigosql

 if ws.codigosql <> 0  then
    error " Erro (", ws.codigosql, ") na gravacao dos dados da ligacao.",
          " AVISE A INFORMATICA!"
    rollback work
    prompt ""  for  char ws.prompt_key
    close window w_cts18m00
    return
 end if

   # Psi 230669 inicio
     if (g_documento.atdnum is not null and
         g_documento.atdnum <> 0 ) then

         let l_msg_pri = "PRI - cts18m00 - chamando ctd25g00"
         call errorlog(l_msg_pri)

         call ctd25g00_insere_atendimento(g_documento.atdnum,g_documento.lignum)
         returning ws.codigosql,ws.tabname

         if ws.codigosql <> 0  then
             error ws.tabname sleep 3
             rollback work
             prompt ""  for  char ws.prompt_key
             close window w_cts18m00
             return
         end if
     end if
   # Psi 230669 Fim


 commit work

 whenever error stop

 let g_documento.lignum = ws.lignum

 display d_cts18m00.sinavsnum using "&&&&&&" at 02,09 attribute (reverse)
 display d_cts18m00.sinavsano                at 02,16 attribute (reverse)

 error  " Verifique o numero do aviso e tecle ENTER!"
 prompt "" for char prompt_key
 error  " Inclusao efetuada com sucesso!"

 close window w_cts18m00

 let g_documento.acao = "INC" # forca historico na inclusao do laudo(cts18n04)
 call cts18n04(d_cts18m00.sinavsnum, d_cts18m00.sinavsano)

 call fax_cts18m00(d_cts18m00.sinavsnum, d_cts18m00.sinavsano)
 let aux_email = 1

end function  ###  inclui_cts18m00

#--------------------------------------------------------------------
 function input_cts18m00(param)
#--------------------------------------------------------------------

 define param         record
    tipchv            char (01)
 end record

 define ws            record
    segnumdig         like gsakseg.segnumdig       ,
    viginc            like abbmdoc.viginc          ,
    vigfnl            like abbmdoc.vigfnl          ,
    cgccpfnum         like gsakseg.cgccpfnum       ,
    cgcord            like gsakseg.cgcord          ,
    cgccpfdig         like gsakseg.cgccpfdig       ,
    segsex            like gsakseg.segsex          ,
    nscdat            like gsakseg.nscdat          ,
    endlgd            like gsakend.endlgd          ,
    endnum            like gsakend.endnum          ,
    endcmp            like gsakend.endcmp          ,
    endbrr            like gsakend.endbrr          ,
    endcid            like gsakend.endcid          ,
    endufd            like gsakend.endufd          ,
    vclchsinc         like abbmveic.vclchsinc      ,
    vclchsfnl         like abbmveic.vclchsfnl      ,
    cgccpfdgt         like ssamterc.cgccpfdig      ,
    vclcorcod         like avlmveic.vclcorcod      ,
    trccordes         char (11)                    ,
    dctnumseq         like abamdoc.dctnumseq       ,
    edsstt            smallint                     ,
    confirma          char (01)                    ,
    sailoop           char (01)                    ,
    opcao             char (01)                    ,
    vstnumdig         like avlmlaudo.vstnumdig     ,
    vstdat            like avlmlaudo.vstdat
 end record


## PSI 183431 - Inicio

  define lr_documento  record
         succod        like datrligapol.succod,      # Codigo Sucursal
         aplnumdig     like datrligapol.aplnumdig,   # Numero Apolice
         itmnumdig     like datrligapol.itmnumdig,   # Numero do Item
         edsnumref     like datrligapol.edsnumref,   # Numero do Endosso
         prporg        like datrligprp.prporg,       # Origem da Proposta
         prpnumdig     like datrligprp.prpnumdig,    # Numero da Proposta
         fcapacorg     like datrligpac.fcapacorg,    # Origem PAC
         fcapacnum     like datrligpac.fcapacnum,    # Numero PAC
         pcacarnum     like eccmpti.pcapticod,       # No. Cartao PortoCard
         pcaprpitm     like epcmitem.pcaprpitm,      # Item (Veiculo) PortoCard
         solnom        char (15),                    # Solicitante
         soltip        char (01),                    # Tipo Solicitante
         c24soltipcod  like datmligacao.c24soltipcod,# Tipo do Solicitante
         ramcod        like datrservapol.ramcod,     # Codigo Ramo
         lignum        like datmligacao.lignum,      # Numero da Ligacao
         c24astcod     like datkassunto.c24astcod,   # Assunto da Ligacao
         ligcvntip     like datmligacao.ligcvntip,   # Convenio Operacional
         atdsrvnum     like datmservico.atdsrvnum,   # Numero do Servico
         atdsrvano     like datmservico.atdsrvano,   # Ano do Servico
         sinramcod     like ssamsin.ramcod,          # Prd Parcial - Ramo sinistro
         sinano        like ssamsin.sinano,          # Prd Parcial - Ano sinistro
         sinnum        like ssamsin.sinnum,          # Prd Parcial - Num sinistro
         sinitmseq     like ssamitem.sinitmseq,      # Prd Parcial - Item p/ramo 53
         acao          char (03),                    # ALT, REC ou CAN
         atdsrvorg     like datksrvtip.atdsrvorg,    # Origem do tipo de Servico
         cndslcflg     like datkassunto.cndslcflg,   # Flag solicita condutor
         lclnumseq     like rsdmlocal.lclnumseq,     # Local de Risco
         vstnumdig     like datmvistoria.vstnumdig,  # numero da vistoria
         flgIS096      char (01)                  ,  # flag cobertura claus.096
         flgtransp     char (01)                  ,  # flag averbacao transporte
         apoio         char (01)                  ,  # flag atend. pelo apoio(S/N)
         empcodatd     like datmligatd.apoemp     ,  # empresa do atendente
         funmatatd     like datmligatd.apomat     ,  # matricula do atendente
         usrtipatd     like datmligatd.apotip     ,  # tipo do atendente
         corsus        like gcaksusep.corsus      ,  #  /inicio psi172413 eduardo - meta
         dddcod        like datmreclam.dddcod     ,  # codigo da area de discagem
         ctttel        like datmreclam.ctttel     ,  # numero do telefone
         funmat        like isskfunc.funmat       ,  # matricula do funcionario
         cgccpfnum     like gsakseg.cgccpfnum     ,  # numero do CGC(CNPJ)
         cgcord        like gsakseg.cgcord        ,  # filial do CGC(CNPJ)
         cgccpfdig     like gsakseg.cgccpfdig     ,  # digito do CGC(CNPJ) ou CPF /fim psi172413 eduardo - meta
         atdprscod     like datmservico.atdprscod ,
         atdvclsgl     like datkveiculo.atdvclsgl ,
         srrcoddig     like datmservico.srrcoddig ,
         socvclcod     like datkveiculo.socvclcod ,
         dstqtd        dec(8,4)                   ,
         prvcalc       interval hour(2) to minute ,
         lclltt        like datmlcl.lclltt        ,
         lcllgt        like datmlcl.lcllgt        ,
         rcuccsmtvcod  like datrligrcuccsmtv.rcuccsmtvcod,    ## Codigo do Motivo
         c24paxnum     like datmligacao.c24paxnum ,           # Numero da P.A.
         averbacao     like datrligtrpavb.trpavbnum,          # PSI183431 Daniel
         crtsaunum     like datksegsau.crtsaunum,
         bnfnum        like datksegsau.bnfnum,
         ramgrpcod     like gtakram.ramgrpcod
  end record

  define lr_ppt        record
         segnumdig     like gsakseg.segnumdig,
         cmnnumdig     like pptmcmn.cmnnumdig,
         endlgdtip     like rlaklocal.endlgdtip,
         endlgdnom     like rlaklocal.endlgdnom,
         endnum        like rlaklocal.endnum,
         ufdcod        like rlaklocal.ufdcod,
         endcmp        like rlaklocal.endcmp,
         endbrr        like rlaklocal.endbrr,
         endcid        like rlaklocal.endcid,
         endcep        like rlaklocal.endcep,
         endcepcmp     like rlaklocal.endcepcmp,
         edsstt        like rsdmdocto.edsstt,
         viginc        like rsdmdocto.viginc,
         vigfnl        like rsdmdocto.vigfnl,
         emsdat        like rsdmdocto.emsdat,
         corsus        like rsampcorre.corsus,
         pgtfrm        like rsdmdadcob.pgtfrm,
         mdacod        like gfakmda.mdacod,
         lclrsccod     like rlaklocal.lclrsccod
  end record

  define la_pptcls    array[05] of record
         clscod       like aackcls.clscod,
         carencia     date
  end record

  define l_data      date,
         l_hora2     datetime hour to minute,
         l_ano       datetime year to year

  define l_host      like ibpkdbspace.srvnom #Saymon ambnovo
  define l_sql       char(500)               #Saymon ambnovo

## PSI 183431 - Final

   initialize  ws.*  to  null
   initialize  lr_documento.*  to  null  #---[ Ruiz ]---
   initialize  lr_ppt.*        to  null
   initialize  la_pptcls       to  null

 if param.tipchv = "I"  then
    initialize d_cts18m00.*     to null
    initialize a_cts18m00       to null
    initialize acid_cts18m00.*  to null

    display by name g_documento.solnom  attribute (reverse)

    while true

       call figrc072_setTratarIsolamento()        --> 223689

       call cts18m07 (d_cts18m00.sinocrdat, d_cts18m00.sinocrhor,
                      d_cts18m00.ramcod   , d_cts18m00.subcod   ,
                      d_cts18m00.sinvstnum, d_cts18m00.sinvstano,
                      d_cts18m00.prporgpcp, d_cts18m00.prpnumpcp,
                      d_cts18m00.prporgidv, d_cts18m00.prpnumidv,
                      d_cts18m00.vcllicnum, g_documento.c24astcod)
           returning  d_cts18m00.sinocrdat, d_cts18m00.sinocrhor,
                      d_cts18m00.ramcod   , d_cts18m00.subcod   ,
                      d_cts18m00.sinvstnum, d_cts18m00.sinvstano,
                      d_cts18m00.prporgpcp, d_cts18m00.prpnumpcp,
                      d_cts18m00.prporgidv, d_cts18m00.prpnumidv,
                      d_cts18m00.vcllicnum

          if g_isoAuto.sqlCodErr <> 0 then --> 223689
             error "Função cts18m07 indisponivel no momento ! Avise a Informatica !" sleep 2
             let int_flag = true
             return
          end if    --> 223689

       if int_flag = true  then
          error " Operacao cancelada! (8)"
          return
       end if

       if d_cts18m00.sinocrdat is null  or
          d_cts18m00.sinocrhor is null  then
          error " Data e hora do sinistro sao informacoes essenciais",
                " para o aviso de sinistro!"
          continue while
       end if

       if d_cts18m00.ramcod is null  then
          error " Ramo deve ser informado!"
          continue while
       else
          if (d_cts18m00.ramcod = 553     or
              d_cts18m00.ramcod = 53)     and
             d_cts18m00.subcod is null  then
             error " Sub-ramo deve ser informado para cobertura de RCF!"
             continue while
          end if
       end if

       if (g_documento.succod    is null  or
           g_documento.aplnumdig is null  or
           g_documento.itmnumdig is null) and
          (d_cts18m00.prporgidv  is null  or
           d_cts18m00.prpnumidv  is null) and
           d_cts18m00.vcllicnum  is null  then
          error " Documento deve ser informado para preenchimento",
                " do aviso de sinistro!"
          continue while
       end if

       if d_cts18m00.ramcod = 31  or
          d_cts18m00.ramcod = 531  then
          display "SEGURADO" to cabtxt
       else
          display "TERCEIRO" to cabtxt
       end if
       exit while

    end while
 end if

 if g_documento.succod    is not null  and
    g_documento.aplnumdig is not null  and
    g_documento.itmnumdig is not null  then

    let d_cts18m00.apolice = g_documento.succod    using "<<<&&",#"&&", projeto succod
                        " ", d_cts18m00.ramcod     using "&&&&",
                        " ", g_documento.aplnumdig using "<<<<<<<& &"
#--------------------------------------------------------------------
# Situacao da apolice na data de ocorrencia do sinistro
#--------------------------------------------------------------------

    call findeds (g_documento.succod   , g_documento.aplnumdig,
                  g_documento.itmnumdig, d_cts18m00.sinocrdat)
        returning ws.dctnumseq, ws.edsstt

    select edsnumdig
      into g_documento.edsnumref
      from abamdoc
     where succod     =  g_documento.succod      and
           aplnumdig  =  g_documento.aplnumdig   and
           dctnumseq  =  ws.dctnumseq

    call f_funapol_auto (g_documento.succod   , g_documento.aplnumdig,
                         g_documento.itmnumdig, g_documento.edsnumref)
               returning g_funapol.*

#--------------------------------------------------------------------
# Verifica existencia de aviso para a apolice na data
#--------------------------------------------------------------------

   #----> PSI 172090
   #if param.tipchv = "I"  then
   #   call avs_apol_cts18m00 (g_documento.succod   ,
   #                           g_documento.aplnumdig,
   #                           g_documento.itmnumdig,
   #                           d_cts18m00.sinocrdat ,
   #                           d_cts18m00.sinocrhor )
   #                 returning a_cts18m00[1].*,
   #                           acid_cts18m00.sinlcldes thru
   #                           acid_cts18m00.sinrclcpdflg
   #end if

#--------------------------------------------------------------------
# Dados do segurado da apolice
#--------------------------------------------------------------------

    select segnumdig
      into ws.segnumdig
      from abbmdoc
     where succod    = g_documento.succod    and
           aplnumdig = g_documento.aplnumdig and
           itmnumdig = g_documento.itmnumdig and
           dctnumseq = g_funapol.dctnumseq

    select viginc, vigfnl
      into ws.viginc   ,
           ws.vigfnl
      from abamapol
     where succod    = g_documento.succod    and
           aplnumdig = g_documento.aplnumdig

    if param.tipchv = "I"  then
       if d_cts18m00.sinocrdat < ws.viginc  or
          d_cts18m00.sinocrdat > ws.vigfnl  then
          call cts08g01("A","N","","DATA DA OCORRENCIA DO SINISTRO",
                                   "FORA DA VIGENCIA DA APOLICE!","")
            returning ws.confirma
          let int_flag = true
          return
       end if

       if d_cts18m00.ramcod = 31  or
          d_cts18m00.ramcod= 531  then
#----------------------------------------------------------------------------
# Comentado em 03/03/1998 por Gilberto Rodrigues conforme
# autorizacao de Neusa Almeida (Sinistro) enviada por correio
#----------------------------------------------------------------------------
#         if g_funapol.autsitatu is null  or
#            g_funapol.autsitatu =  0     then
#            call cts08g01("A","N","","DOCUMENTO SEM COBERTURA",
#                                     "PARA CASCO!","")
#                 returning ws.confirma
#            let int_flag = true
#            return
#         end if
#----------------------------------------------------------------------------
       else
          if d_cts18m00.subcod = 02  then
             if g_funapol.dmtsitatu is null  or
                g_funapol.dmtsitatu =  0     then
                call cts08g01("A","N","","DOCUMENTO SEM COBERTURA PARA",
                                         "DANOS MATERIAIS!","")
                     returning ws.confirma
                let int_flag = true
                return
             end if
          else
             if g_funapol.dpssitatu is null  or
                g_funapol.dpssitatu =  0     then
                call cts08g01("A","N","","DOCUMENTO SEM COBERTURA PARA",
                                      "DANOS PESSOAIS!","")
                     returning ws.confirma
                let int_flag = true
                return
             end if
          end if
       end if
    end if

#--------------------------------------------------------------------
# Dados do veiculo da apolice
#--------------------------------------------------------------------

    select vclcoddig,
           vcllicnum,
           vclanofbc,
           vclanomdl,
           vclchsinc,
           vclchsfnl
      into d_cts18m00.vclcoddig,
           d_cts18m00.vcllicnum,
           d_cts18m00.vclanofbc,
           d_cts18m00.vclanomdl,
           ws.vclchsinc        ,
           ws.vclchsfnl
      from abbmveic
     where succod    = g_documento.succod     and
           aplnumdig = g_documento.aplnumdig  and
           itmnumdig = g_documento.itmnumdig  and
           dctnumseq = g_funapol.vclsitatu

    if sqlca.sqlcode = notfound  then
       select vclcoddig,
              vcllicnum,
              vclanofbc,
              vclanomdl,
              vclchsinc,
              vclchsfnl
         into d_cts18m00.vclcoddig,
              d_cts18m00.vcllicnum,
              d_cts18m00.vclanofbc,
              d_cts18m00.vclanomdl,
              ws.vclchsinc        ,
              ws.vclchsfnl
         from abbmveic
        where succod    = g_documento.succod      and
              aplnumdig = g_documento.aplnumdig   and
              itmnumdig = g_documento.itmnumdig   and
              dctnumseq = (select max(dctnumseq)
                             from abbmveic
                            where succod    = g_documento.succod      and
                                  aplnumdig = g_documento.aplnumdig   and
                                  itmnumdig = g_documento.itmnumdig)
    end if

#--------------------------------------------------------------------
# Dados do corretor da apolice
#--------------------------------------------------------------------

    select corsus
      into d_cts18m00.corsus
      from abamcor
     where succod    = g_documento.succod     and
           aplnumdig = g_documento.aplnumdig  and
           corlidflg = "S"

 else
    if d_cts18m00.prporgidv is not null  and
       d_cts18m00.prpnumidv is not null  and
       param.tipchv = "I"                then

#--------------------------------------------------------------------
# Dados do segurado da proposta
#--------------------------------------------------------------------

       call figrc072_initGlbIsolamento() --> 223689
       #------------Saymon---------------------#
       # Carrega host do banco de dados        #
       #---------------------------------------#
       #ambnovo
          if d_cts18m00.prporgidv = 15  then
         let l_host = fun_dba_servidor("ORCAMAUTO")
          else
          let l_host = fun_dba_servidor("EMISAUTO")
       end if
             whenever error continue
          let l_sql =  'select segnumdig, viginc, vigfnl '
                      ,'  from porto@',l_host clipped,':apbmitem'
                      ,' where prporgpcp = ? '
                      ,'   and prpnumpcp = ? '
                      ,'   and prporgidv = ? '
                      ,'   and prpnumidv = ? '
          prepare p_cts18m00_01 from l_sql
          declare c_cts18m00_01 cursor with hold for p_cts18m00_01
             whenever error stop

              --> 223689
              if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                   "cts18m07"           ,
                   "cts18m07"   ,
                   ""       ,
                   "","","","","","")  then
                let int_flag = true
                return
              end if  --> 223689

           open c_cts18m00_01 using d_cts18m00.prporgpcp
                                ,d_cts18m00.prpnumpcp
                                ,d_cts18m00.prporgidv
                                ,d_cts18m00.prpnumidv

           fetch c_cts18m00_01 into ws.segnumdig
                                   ,ws.viginc
                                   ,ws.vigfnl
           #ambnovo

       if d_cts18m00.sinocrdat < ws.viginc  or
          d_cts18m00.sinocrdat > ws.vigfnl  then
          call cts08g01("A","N","","DATA DA OCORRENCIA DO SINISTRO",
                                   "FORA DA VIGENCIA DA PROPOSTA!","")
               returning ws.confirma
          let int_flag = true
          return
       end if

#--------------------------------------------------------------------
# Dados do veiculo da proposta
#--------------------------------------------------------------------

       select vclcoddig,
              vcllicnum,
              vclanofbc,
              vclanomdl,
              vclchsinc,
              vclchsfnl
         into d_cts18m00.vclcoddig,
              d_cts18m00.vcllicnum,
              d_cts18m00.vclanofbc,
              d_cts18m00.vclanomdl,
              ws.vclchsinc        ,
              ws.vclchsfnl
         from apbmveic
        where prporgpcp = d_cts18m00.prporgpcp  and
              prpnumpcp = d_cts18m00.prpnumpcp  and
              prporgidv = d_cts18m00.prporgidv  and
              prpnumidv = d_cts18m00.prpnumidv

#--------------------------------------------------------------------
# Dados do corretor da proposta
#--------------------------------------------------------------------


       select corsus
         into d_cts18m00.corsus
         from apamcor
        where prporgpcp = d_cts18m00.prporgpcp  and
              prpnumpcp = d_cts18m00.prpnumpcp  and
              corlidflg = "S"

    end if
 end if

#--------------------------------------------------------------------
# Dados do segurado
#--------------------------------------------------------------------

 select segnom   , cgccpfnum,
        cgcord   , cgccpfdig,
        segsex   , nscdat
   into d_cts18m00.segnom,
        ws.cgccpfnum,
        ws.cgcord   ,
        ws.cgccpfdig,
        ws.segsex   ,
        ws.nscdat
   from gsakseg
  where segnumdig  =  ws.segnumdig

 select endlgd, endnum, endcmp,
        endbrr, endcid, endufd,
        dddcod, teltxt
   into ws.endlgd, ws.endnum,
        ws.endcmp, ws.endbrr,
        ws.endcid, ws.endufd,
        d_cts18m00.segdddcod,
        d_cts18m00.segtelnum
   from gsakend
  where segnumdig  =  ws.segnumdig    and
        endfld     =  "1"

 let ws.endlgd = ws.endlgd clipped, " ",
                 ws.endnum clipped, " ",
                 ws.endcmp clipped

#--------------------------------------------------------------------
# Dados do corretor
#--------------------------------------------------------------------

 select gcakcorr.cornom  ,
        gcakfilial.dddcod,
        gcakfilial.teltxt
      # gcakfilial.factxt
   into d_cts18m00.cornom   ,
        d_cts18m00.segdddcod,
        d_cts18m00.cortelnum
   from gcaksusep, gcakcorr, gcakfilial
  where gcaksusep.corsus     = d_cts18m00.corsus    and
        gcakcorr.corsuspcp   = gcaksusep.corsuspcp  and
        gcakfilial.corsuspcp = gcaksusep.corsuspcp  and
        gcakfilial.corfilnum = gcaksusep.corfilnum

#--------------------------------------------------------------------
# Dados do veiculo
#--------------------------------------------------------------------

 if d_cts18m00.vclcoddig is not null  then
    call veiculo_cts18m00(d_cts18m00.vclcoddig)
         returning d_cts18m00.vcldes
 end if

 let d_cts18m00.vclchsnum = ws.vclchsinc clipped, ws.vclchsfnl clipped

 if param.tipchv = "I"  then
    message " (F1)Help, (F5)Espelho, (F6)Mot.Terceiro, (F7)Mot.Segurado, (F8)Acidente"
 else
    message " (F1)Help, (F5)Espelho"
 end if

 if g_documento.c24astcod = "N11" and
    d_cts18m00.subcod     = 02    then

    while true
      call cts08g01 ("A","S","",
                     "Veiculo do terceiro e' segurado ",
                     "Porto Seguro ?","")
           returning ws.confirma

      call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
      if ws.confirma = "S" then
         call cts18m00_salvaglobal("S")
         while true

## PSI 183431 - Inicio

            call cta00m01(g_documento.apoio,
                          g_documento.empcodatd,
                          g_documento.funmatatd,
                          g_documento.usrtipatd,
                          g_documento.c24astcod,
                          g_documento.solnom,
                          g_documento.c24soltipcod,
                          g_c24paxnum)
                returning lr_documento.*,
                          lr_ppt.*,
                          la_pptcls[1].*,
                          la_pptcls[2].*,
                          la_pptcls[3].*,
                          la_pptcls[4].*,
                          la_pptcls[5].*

            if lr_documento.aplnumdig is not null then
               ##call cta01m00()
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
            end if

## PSI 183431 - Final

            while true
               call cts18m00_opcao() returning ws.opcao
               if ws.opcao = "1" then   # aproveita os dados
                  #---> PSI 172090
                  let m_retorno.succod    = g_documento.succod
                  let m_retorno.aplnumdig = g_documento.aplnumdig
                  let m_retorno.itmnumdig = g_documento.itmnumdig
                  if g_documento.aplnumdig is not null then
                     call cts18m00_carregadados_terceiro()
                     call cts18m00_salvaglobal("V")
                     exit while
                  else
                      error "Nao existe dados a serem aproveitados !"
                      continue while
                  end if
               end if
               if ws.opcao <> "1" then
                  exit while
               end if
            end while
            if ws.opcao = "1" then
               exit while
            end if
            if ws.opcao = "2" then   # fazer nova consulta
               continue while
            end if
            if ws.opcao = "3"  then  # informar dados manualmente
               call fssac060(l_data, "S", g_issk.dptsgl)
                    returning m_retorno.*
               if m_retorno.aplnumdig is not null then
                  call cts18m00b()
                          returning m_opcao
                  if m_opcao = "S" then
                     let g_documento.succod    = m_retorno.succod
                     let g_documento.aplnumdig = m_retorno.aplnumdig
                     let g_documento.itmnumdig = m_retorno.itmnumdig
                     call cts18m00_carregadados_terceiro()
                     call cts18m00_salvaglobal("V")
                     exit while
                  else
                     let ws.vstnumdig = null
                     call cts18m00_salvaglobal("V")
                     exit while
                  end if
               else
                  let ws.vstnumdig = null
                  call cts18m00_salvaglobal("V")
                  exit while
               end if
            end if
         end while
      else
         prompt "*** VOCE LEU O ALERTA ? (S)im ou (N)ao "
              attribute(reverse) for char ws.confirma
         if ws.confirma = "S" or ws.confirma = "s"  then
            call cts18m00_salvaglobal("S")
            call fssac060(l_data, "S", g_issk.dptsgl)
                 returning m_retorno.*

            if m_retorno.aplnumdig is not null then
               call cts18m00b()
                    returning m_opcao

               if m_opcao = "S" then
                  let g_documento.succod    = m_retorno.succod
                  let g_documento.aplnumdig = m_retorno.aplnumdig
                  let g_documento.itmnumdig = m_retorno.itmnumdig
                  call cts18m00_carregadados_terceiro()
                  call cts18m00_salvaglobal("V")
                  exit while
               else
                  let ws.vstnumdig = null
                  call cts18m00_salvaglobal("V")
                  exit while
               end if
            else
               let ws.vstnumdig = null
               call cts18m00_salvaglobal("V")
               exit while
            end if
         else
            call cts08g01("A", "S", "", "Veiculo do terceiro e' segurado",
                          "Porto Seguro ?", "")
                 returning ws.confirma
            if ws.confirma = "S" or ws.confirma = "s"  then
               call cts18m00_salvaglobal("S")
               call fssac060(l_data, "S", g_issk.dptsgl)
                    returning m_retorno.*
               if m_retorno.aplnumdig is not null then
                  call cts18m00b()
                       returning m_opcao
                  if m_opcao = "S" then
                     let g_documento.succod    = m_retorno.succod
                     let g_documento.aplnumdig = m_retorno.aplnumdig
                     let g_documento.itmnumdig = m_retorno.itmnumdig
                     call cts18m00_carregadados_terceiro()
                     call cts18m00_salvaglobal("V")
                     exit while
                  else
                     let ws.vstnumdig = null
                     call cts18m00_salvaglobal("V")
                     exit while
                  end if
               else
                  let ws.vstnumdig = null
                  call cts18m00_salvaglobal("V")
                  exit while
               end if
            else
               call cts18m00_salvaglobal("S")
               call fssac060(l_data, "S", g_issk.dptsgl)
                    returning m_retorno.*
               if m_retorno.aplnumdig is not null then
                  call cts18m00b()
                       returning m_opcao
                  if m_opcao = "S" then
                     let g_documento.succod    = m_retorno.succod
                     let g_documento.aplnumdig = m_retorno.aplnumdig
                     let g_documento.itmnumdig = m_retorno.itmnumdig
                     call cts18m00_carregadados_terceiro()
                     call cts18m00_salvaglobal("V")
                     exit while
                  else
                     let ws.vstnumdig = null
                     call cts18m00_salvaglobal("V")
                     exit while
                  end if
               else
                  let ws.vstnumdig = null
                  call cts18m00_salvaglobal("V")
                  exit while
               end if
            end if
         end if
      end if
      if ws.confirma = "S" or ws.confirma = "s"  then
         exit while
      end if
    end while
 end if
 display by name d_cts18m00.sinocrdat, d_cts18m00.sinocrhor,
                 d_cts18m00.segnom thru d_cts18m00.sinvclguinom

 input by name d_cts18m00.sinrclnom,
               d_cts18m00.cgccpfnum,
               d_cts18m00.cgcord   ,
               d_cts18m00.cgccpfdig,
               d_cts18m00.endlgd   ,
               d_cts18m00.endbrr   ,
               d_cts18m00.endcid   ,
               d_cts18m00.endufd   ,
               d_cts18m00.trcdddcod,
               d_cts18m00.trctelnum,
               d_cts18m00.trcvclcod,
               d_cts18m00.sinbemdes,
               d_cts18m00.trccordes,
               d_cts18m00.trcvclchs,
               d_cts18m00.trcvcllic,
               d_cts18m00.trcanofbc,
               d_cts18m00.trcanomdl,
               d_cts18m00.sinrclsgrflg,
               d_cts18m00.sinrclsgdnom,
               d_cts18m00.sinrclapltxt,
               d_cts18m00.viginc      ,
               d_cts18m00.vigfnl      ,
               d_cts18m00.sinvclguiflg,
               d_cts18m00.sinvclguinom,
               d_cts18m00.filler        without defaults

   before field sinrclnom
      if param.tipchv = "M"  then
         if d_cts18m00.ramcod = 31  or
            d_cts18m00.ramcod = 531 then
            call cts18m01(param.tipchv, d_cts18m00.ramcod, d_cts18m00.segnom,
                          a_cts18m00[1].*
                          #-----> PSI 172090
                          ,g_documento.succod    ,g_documento.aplnumdig
                          ,g_documento.itmnumdig ,d_cts18m00.prporgidv
                          ,d_cts18m00.prpnumidv)
                returning a_cts18m00[1].*
            exit input
         else
            if d_cts18m00.sinrclnom is not null  then
               if fgl_lastkey() = fgl_keyval("up")    or
                  fgl_lastkey() = fgl_keyval("left")  then
                  next field filler
               else
                  next field cgccpfnum
               end if
            else
               display by name d_cts18m00.sinrclnom  attribute (reverse)
            end if
         end if
      else
         if d_cts18m00.ramcod = 31   or
            d_cts18m00.ramcod = 531  then

            #---> PSI 172090
            while true
             # if a_cts18m00[1].sinmotnom is null  then
                  let a_cts18m00[1].sinmotnom = d_cts18m00.segnom
                  let a_cts18m00[1].cgccpfnum = ws.cgccpfnum
                  let a_cts18m00[1].cgcord    = ws.cgcord
                  let a_cts18m00[1].cgccpfdig = ws.cgccpfdig
                  let a_cts18m00[1].endlgd    = ws.endlgd
                  let a_cts18m00[1].endbrr    = ws.endbrr
                  let a_cts18m00[1].endcid    = ws.endcid
                  let a_cts18m00[1].endufd    = ws.endufd
                  let a_cts18m00[1].dddcod    = d_cts18m00.segdddcod
                  let a_cts18m00[1].telnum    = d_cts18m00.segtelnum
                  let a_cts18m00[1].sinmotsex = ws.segsex

                  call cts40g03_data_hora_banco(2)
                     returning l_data, l_hora2
                  call idade_cts18m00(ws.nscdat, l_data)
                            returning a_cts18m00[1].sinmotidd
             # end if

               call cts18m01(param.tipchv, d_cts18m00.ramcod,
                             d_cts18m00.segnom, a_cts18m00[1].*
                             #-----> PSI 172090
                             ,g_documento.succod    ,g_documento.aplnumdig
                             ,g_documento.itmnumdig ,d_cts18m00.prporgidv
                             ,d_cts18m00.prpnumidv)
                   returning a_cts18m00[1].*

               if int_flag  then
                  if param.tipchv = "I"  then
                     if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","") = "S"  then
                        let int_flag = true
                        exit while
                     else
                        let int_flag = false
                        continue while
                     end if
                  else
                     exit while
                  end if
               end if

               call cts18m03 (param.tipchv, acid_cts18m00.*)
                    returning acid_cts18m00.*

               if int_flag  then
                  let int_flag = false
                  continue while
               end if

               if acid_cts18m00.sinmotcplflg = "T"  then
                  call cts18m01 (param.tipchv, 99, "", a_cts18m00[2].*
                                #-----> PSI 172090
                                ,"" ,"" ,"" ,"" ,"")
                               #,g_documento.succod    ,g_documento.aplnumdig
                               #,g_documento.itmnumdig ,g_documento.prporg
                               #,g_documento.prpnumdig)
                       returning a_cts18m00[2].*

                  if int_flag  then
                     let int_flag = false
                     continue while
                  end if

                  call cts18m09 ("I"                 ,
                                 d_cts18m00.trcvclcod,
                                 d_cts18m00.sinbemdes,
                                 d_cts18m00.trccorcod,
                                 d_cts18m00.trcvclchs,
                                 d_cts18m00.trcvcllic,
                                 d_cts18m00.trcanofbc,
                                 d_cts18m00.trcanomdl)
                       returning d_cts18m00.trcvclcod,
                                 d_cts18m00.sinbemdes,
                                 d_cts18m00.trccorcod,
                                 d_cts18m00.trcvclchs,
                                 d_cts18m00.trcvcllic,
                                 d_cts18m00.trcanofbc,
                                 d_cts18m00.trcanomdl

                  if int_flag  then
                     let int_flag = false
                     continue while
                  end if
               end if

               exit while
            end while

            if int_flag  then
               exit input
            end if

            exit input
         else
            display by name d_cts18m00.sinrclnom  attribute (reverse)
         end if
      end if

   after  field sinrclnom
      display by name d_cts18m00.sinrclnom

      if d_cts18m00.sinrclnom is null  then
         error " Nome do terceiro deve ser informado!"
         next field sinrclnom
      end if

   before field cgccpfnum
      if param.tipchv = "M"                and
         d_cts18m00.cgccpfnum is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinrclnom
         else
            next field endlgd
         end if
      end if

      display by name d_cts18m00.cgccpfnum  attribute (reverse)

   after  field cgccpfnum
      display by name d_cts18m00.cgccpfnum

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m00.cgccpfnum is null  then
            initialize d_cts18m00.cgcord, d_cts18m00.cgccpfdig to null
            display by name d_cts18m00.cgcord
            display by name d_cts18m00.cgccpfdig
            next field endlgd
         end if
      end if

   before field cgcord
      display by name d_cts18m00.cgcord  attribute (reverse)

   after  field cgcord
      display by name d_cts18m00.cgcord

   before field cgccpfdig
      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         if d_cts18m00.cgccpfnum is null  then
            next field cgccpfnum
#        else
#           next field sinrclnom
         end if
      else
         display by name d_cts18m00.cgccpfdig  attribute (reverse)
      end if

   after  field cgccpfdig
      display by name d_cts18m00.cgccpfdig

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m00.cgccpfnum is not null  then
            if d_cts18m00.cgccpfdig is null  then
               error " Digito do CGC/CPF deve ser informado!"
               next field cgccpfdig
            end if

            let ws.cgccpfdgt = 0

            if d_cts18m00.cgcord is not null  then
              call f_fundigit_digitocgc(d_cts18m00.cgccpfnum, d_cts18m00.cgcord)
                               returning ws.cgccpfdgt
            else
               call f_fundigit_digitocpf(d_cts18m00.cgccpfnum)
                               returning ws.cgccpfdgt
            end if

            if ws.cgccpfdgt         is null          or
               d_cts18m00.cgccpfdig <> ws.cgccpfdgt  then
               if param.tipchv = "M"  then
                  initialize d_cts18m00.cgccpfnum,
                             d_cts18m00.cgcord   ,
                             d_cts18m00.cgccpfdig  to null
                  display by name d_cts18m00.cgccpfdig
               end if
               error " Digito do CGC/CPF incorreto! Informe novamente."
               next field cgccpfnum
            end if
         end if
      end if
------------aqui
   before field endlgd
      if param.tipchv = "M"             and
         d_cts18m00.endlgd is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field cgccpfnum
         else
            next field endbrr
         end if
      end if

      display by name d_cts18m00.endlgd  attribute (reverse)

   after  field endlgd
      display by name d_cts18m00.endlgd

   before field endbrr
      if param.tipchv = "M"             and
         d_cts18m00.endbrr is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endlgd
         else
            next field endcid
         end if
      end if

      display by name d_cts18m00.endbrr  attribute (reverse)

   after  field endbrr
      display by name d_cts18m00.endbrr

   before field endcid
      if param.tipchv = "M"             and
         d_cts18m00.endcid is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endbrr
         else
            next field endufd
         end if
      end if

      display by name d_cts18m00.endcid  attribute (reverse)

   after  field endcid
      display by name d_cts18m00.endcid

   before field endufd
      if param.tipchv = "M"             and
         d_cts18m00.endufd is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endcid
         else
            next field trcdddcod
         end if
      end if

      display by name d_cts18m00.endufd  attribute (reverse)

   after  field endufd
      display by name d_cts18m00.endufd

      if d_cts18m00.endufd is not null  then
         select ufdcod from glakest
          where ufdcod = d_cts18m00.endufd

         if sqlca.sqlcode = notfound  then
            error " Unidade federativa nao cadastrada!"
            next field endufd
         end if
      end if

   before field trcdddcod
      if param.tipchv = "M"                and
         d_cts18m00.trcdddcod is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endufd
         else
            next field trctelnum
         end if
      end if

      display by name d_cts18m00.trcdddcod  attribute (reverse)

   after  field trcdddcod
      display by name d_cts18m00.trcdddcod

   before field trctelnum
      if param.tipchv = "M"                and
         d_cts18m00.trctelnum is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field trcdddcod
         else
            next field trcvclcod
         end if
      end if

      display by name d_cts18m00.trctelnum  attribute (reverse)

   after  field trctelnum
      display by name d_cts18m00.trctelnum

   before field trcvclcod
      if param.tipchv = "M"                and
         d_cts18m00.trcvclcod is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field trctelnum
         else
            next field sinbemdes
         end if
      end if

      display by name d_cts18m00.trcvclcod  attribute (reverse)

   after  field trcvclcod
      display by name d_cts18m00.trcvclcod

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m00.trcvclcod is null  then
            call agguvcl() returning d_cts18m00.trcvclcod

            if d_cts18m00.trcvclcod is null  then
               next field sinbemdes
            else
               call veiculo_cts18m00(d_cts18m00.trcvclcod)
                    returning d_cts18m00.sinbemdes
               display by name d_cts18m00.sinbemdes
               next field trccordes
            end if
         else
            call veiculo_cts18m00(d_cts18m00.trcvclcod)
                 returning d_cts18m00.sinbemdes
            display by name d_cts18m00.sinbemdes
            next field trccordes
         end if
      end if

   before field sinbemdes
      if param.tipchv = "M"                and
         d_cts18m00.sinbemdes is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field trcvclcod
         else
            next field trccordes
         end if
      else
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            if d_cts18m00.trcvclcod is not null  then
               next field trcvclcod
            end if
         end if
      end if

      display by name d_cts18m00.sinbemdes  attribute (reverse)

   after  field sinbemdes
      display by name d_cts18m00.sinbemdes

      if fgl_lastkey() = fgl_keyval("up")    and
         fgl_lastkey() = fgl_keyval("left")  then
         next field trcvclcod
      end if

      if d_cts18m00.trcvclcod is null  and
         d_cts18m00.sinbemdes is null  then
         error " Veiculo/descricao do bem deve ser informado!"
         next field trcvclcod
      end if

      if d_cts18m00.trcvclcod is null  then
         next field sinrclsgrflg
      end if

   before field trccordes
      if param.tipchv = "M"                and
         d_cts18m00.trccordes is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinbemdes
         else
            next field trcvclchs
         end if
      end if

      display by name d_cts18m00.trccordes  attribute (reverse)

   after  field trccordes
      display by name d_cts18m00.trccordes

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m00.trccordes is null  then
            error " Cor do veiculo deve ser informada!"
            next field trccordes
         else
            let ws.trccordes = d_cts18m00.trccordes[02,11]

            select cpocod into d_cts18m00.trccorcod
              from iddkdominio
             where cponom        = "vclcorcod"  and
                   cpodes[02,11] = ws.trccordes

            if sqlca.sqlcode = notfound  then
               error " Cor fora do padrao!"
               call c24geral4()
                    returning d_cts18m00.trccorcod, d_cts18m00.trccordes

               if d_cts18m00.trccorcod is not null  then
                  display by name d_cts18m00.trccordes
               else
                  next field trccordes
               end if
            end if
         end if
      end if

   before field trcvclchs
      if param.tipchv = "M"                and
         d_cts18m00.trcvclchs is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field trccordes
         else
            next field trcvcllic
         end if
      end if

      display by name d_cts18m00.trcvclchs  attribute (reverse)

   after  field trcvclchs
      display by name d_cts18m00.trcvclchs

   before field trcvcllic
      if param.tipchv = "M"                and
         d_cts18m00.trcvcllic is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field trcvclchs
         else
            next field trcanofbc
         end if
      end if

      display by name d_cts18m00.trcvcllic  attribute (reverse)

   after  field trcvcllic
      display by name d_cts18m00.trcvcllic

   before field trcanofbc
      if param.tipchv = "M"                and
         d_cts18m00.trcanofbc is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field trcvcllic
         else
            next field trcanomdl
         end if
      end if

      display by name d_cts18m00.trcanofbc  attribute (reverse)

   after  field trcanofbc
      display by name d_cts18m00.trcanofbc

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m00.trcanofbc is null  then
            error " Ano de fabricacao do veiculo deve ser informado!"
            next field trcanofbc
         else
            call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
            ##if d_cts18m00.trcanofbc > current year to year  then
            let l_ano = l_data using "yyyy"
            if d_cts18m00.trcanofbc > l_ano  then
               error " Ano de fabricacao do veiculo nao pode ser",
                     " maior que o ano atual!"
               next field trcanofbc
            end if
         end if
      end if

   before field trcanomdl
      if param.tipchv = "M"                and
         d_cts18m00.trcanofbc is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field trcanofbc
         else
            next field sinrclsgrflg
         end if
      else
         if d_cts18m00.trcanomdl is null  then
            let d_cts18m00.trcanomdl = d_cts18m00.trcanofbc
         end if
      end if

      display by name d_cts18m00.trcanomdl  attribute (reverse)

   after  field trcanomdl
      display by name d_cts18m00.trcanomdl

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m00.trcanomdl is null  then
            error " Ano modelo do veiculo deve ser informado!"
            next field trcanomdl
         else
            if d_cts18m00.trcanomdl > d_cts18m00.trcanofbc + 1 units year  then
               error " Ano modelo do veiculo nao pode ser maior",
                     " que o proximo ano!"
               next field trcanomdl
            end if

            if d_cts18m00.trcanomdl < d_cts18m00.trcanofbc  then
               error " Ano modelo nao pode ser inferior ao ano de fabricacao!"
               next field trcanomdl
            end if
         end if
      end if

   before field sinrclsgrflg
      if param.tipchv = "M"                   and
         d_cts18m00.sinrclsgrflg is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field trcanomdl
         else
            if d_cts18m00.sinrclsgrflg = "S"  then
               next field sinrclsgdnom
            else
               next field sinvclguiflg
            end if
         end if
      else
         display by name d_cts18m00.sinrclsgrflg  attribute (reverse)
      end if

   after  field sinrclsgrflg
      display by name d_cts18m00.sinrclsgrflg

      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         if d_cts18m00.trcvclcod is null  then
            next field sinbemdes
         else
            next field trcanomdl
         end if
      else
         if d_cts18m00.sinrclsgrflg is null  then
            error " Informacao sobre seguro do terceiro deve ser informada!"
            initialize d_cts18m00.sinrclsgdnom, d_cts18m00.sinrclapltxt to null
            display by name d_cts18m00.sinrclsgdnom
            display by name d_cts18m00.sinrclapltxt
            next field sinrclsgrflg
         else
            if d_cts18m00.sinrclsgrflg = "N"  then
               next field sinvclguiflg
            else
               if d_cts18m00.sinrclsgrflg = "S"  then
               else
                  error " Informacao sobre seguro deve ser (S)im ou (N)ao!"
                  next field sinvclguiflg
               end if
            end if
         end if
      end if

   before field sinrclsgdnom
      if param.tipchv = "M"                   and
         d_cts18m00.sinrclsgdnom is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinrclsgrflg
         else
            next field sinrclapltxt
         end if
      end if

      display by name d_cts18m00.sinrclsgdnom  attribute (reverse)

   after  field sinrclsgdnom
      display by name d_cts18m00.sinrclsgdnom

   before field sinrclapltxt
      if param.tipchv = "M"                   and
         d_cts18m00.sinrclapltxt is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinrclsgdnom
         else
            next field sinvclguiflg
         end if
      end if

      display by name d_cts18m00.sinrclapltxt  attribute (reverse)

   after  field sinrclapltxt
      display by name d_cts18m00.sinrclapltxt

   before field viginc
      display by name d_cts18m00.viginc

   after field viginc
      if param.tipchv = "M"              and
         d_cts18m00.viginc  is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinrclapltxt
         end if
      end if

   before field vigfnl
      display by name d_cts18m00.vigfnl

   after field vigfnl
      if param.tipchv = "M"              and
         d_cts18m00.vigfnl  is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field viginc
         else
            if d_cts18m00.sinvclguiflg = "S"  then
               next field sinvclguinom
            else
               exit input
            end if
         end if
      end if

   before field sinvclguiflg
      if param.tipchv = "M"                   and
         d_cts18m00.sinvclguiflg is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinrclapltxt
         else
            if d_cts18m00.sinvclguiflg = "S"  then
               next field sinvclguinom
            else
               exit input
            end if
         end if
      end if

      display by name d_cts18m00.sinvclguiflg  attribute (reverse)

   after  field sinvclguiflg
      display by name d_cts18m00.sinvclguiflg

      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         if d_cts18m00.sinrclsgrflg = "S"  then
            next field sinrclapltxt
         else
            next field sinrclsgrflg
         end if
      else
         if d_cts18m00.sinvclguiflg is null  then
            error " Informacao sobre remocao do veiculo deve ser informada!"
            initialize d_cts18m00.sinvclguinom to null
            display "   " to sinvclguitxt
            display by name d_cts18m00.sinvclguinom
            next field sinvclguiflg
         else
            if d_cts18m00.sinvclguiflg = "N"  then
               next field filler
            else
               if d_cts18m00.sinvclguiflg = "S"  then
                  display "por" to sinvclguitxt
               else
                  error " Informacao sobre remocao deve ser (S)im ou (N)ao!"
                  next field sinvclguiflg
               end if
            end if
         end if
      end if

   before field sinvclguinom
      if param.tipchv = "M"                   and
         d_cts18m00.sinvclguinom is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinvclguiflg
         else
            next field filler
         end if
      end if

      display by name d_cts18m00.sinvclguinom  attribute (reverse)

   after  field sinvclguinom
      display by name d_cts18m00.sinvclguinom

   before field filler
      if param.tipchv <> "M"  then
#PSI 172090 if a_cts18m00[2].sinmotnom is null  then
            let a_cts18m00[2].sinmotnom = d_cts18m00.sinrclnom
            let a_cts18m00[2].cgccpfnum = d_cts18m00.cgccpfnum
            let a_cts18m00[2].cgcord    = d_cts18m00.cgcord
            let a_cts18m00[2].cgccpfdig = d_cts18m00.cgccpfdig
            let a_cts18m00[2].endlgd    = d_cts18m00.endlgd
            let a_cts18m00[2].endbrr    = d_cts18m00.endbrr
            let a_cts18m00[2].endcid    = d_cts18m00.endcid
            let a_cts18m00[2].endufd    = d_cts18m00.endufd
            let a_cts18m00[2].dddcod    = d_cts18m00.trcdddcod
            let a_cts18m00[2].telnum    = d_cts18m00.trctelnum
            let a_cts18m00[2].vstnumdig = ws.vstnumdig
#PSI 172090  end if

         call cts18m01 (param.tipchv, d_cts18m00.ramcod, "", a_cts18m00[2].*
                       #-----> PSI 172090
                       ,m_retorno.succod    ,m_retorno.aplnumdig
                       ,m_retorno.itmnumdig ,""
                       ,"")
              returning a_cts18m00[2].*

         if int_flag  then
            let int_flag = false
            next field sinvclguiflg
         end if

#PSI 172090  if a_cts18m00[1].sinmotnom is null  then
            let a_cts18m00[1].sinmotnom = d_cts18m00.segnom
            let a_cts18m00[1].cgccpfnum = ws.cgccpfnum
            let a_cts18m00[1].cgcord    = ws.cgcord
            let a_cts18m00[1].cgccpfdig = ws.cgccpfdig
            let a_cts18m00[1].endlgd    = ws.endlgd
            let a_cts18m00[1].endbrr    = ws.endbrr
            let a_cts18m00[1].endcid    = ws.endcid
            let a_cts18m00[1].endufd    = ws.endufd
            let a_cts18m00[1].dddcod    = d_cts18m00.segdddcod
            let a_cts18m00[1].telnum    = d_cts18m00.segtelnum
            let a_cts18m00[1].sinmotsex = ws.segsex

            call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
            call idade_cts18m00(ws.nscdat, l_data)
                      returning a_cts18m00[1].sinmotidd
#PSI 172090 end if

         select grlinf[01,10] into m_dtres86
            from datkgeral
            where grlchv='ct24resolucao86'

         call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
         if m_dtres86 <= l_data then
            let m_newramo31 = 531
         else
            let m_newramo31 = 31
         end if

         call cts18m01 (param.tipchv, m_newramo31, d_cts18m00.segnom
                      , a_cts18m00[1].*
                      #-----> PSI 172090
                      ,g_documento.succod    ,g_documento.aplnumdig
                      ,g_documento.itmnumdig ,d_cts18m00.prporgidv
                      ,d_cts18m00.prpnumidv)
              returning a_cts18m00[1].*

         if int_flag  then
            let int_flag = false
            next field sinvclguiflg
         end if

         call cts18m03 (param.tipchv, acid_cts18m00.*)
              returning acid_cts18m00.*

         if int_flag  then
            let int_flag = false
            next field sinvclguiflg
         end if
      end if

      error " Pressione ENTER para confirmar os dados! "

   after  field filler
      if fgl_lastkey() = fgl_keyval("return")  then
         exit input
      else
         next field filler
      end if
---------aqui
   on key (interrupt)
      if param.tipchv = "I"  then
         if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")  =  "S"  then
            let int_flag = true
            exit input
         else
            let int_flag = false
         end if
      else
         exit input
      end if

   on key (F1)
      if g_documento.c24astcod is not null then
         call ctc58m00_vis(g_documento.c24astcod)
      end if


   on key (F5)  ###  Espelho da Apolice
{
      if g_documento.succod    is not null  or
         g_documento.aplnumdig is not null  or
         g_documento.itmnumdig is not null  then
         call cta01m00()
      else
         error " Espelho so' com documento localizado!"
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

   on key (F6)  ###  Motorista do Terceiro
      if param.tipchv = "I"  then
         call cts18m01 (param.tipchv, d_cts18m00.ramcod, "", a_cts18m00[2].*
                       #-----> PSI 172090
                       ,m_retorno.succod    ,m_retorno.aplnumdig
                       ,m_retorno.itmnumdig ,""
                       ,"")
              returning a_cts18m00[2].*
      end if

   on key (F7)  ###  Motorista do Segurado
      if param.tipchv = "I"  then
         select grlinf[01,10] into m_dtres86
            from datkgeral
            where grlchv='ct24resolucao86'

         call cts40g03_data_hora_banco(2)
              returning l_data, l_hora2
         if m_dtres86 <= l_data then
            let m_newramo31 = 531
         else
            let m_newramo31 = 31
         end if
         call cts18m01 (param.tipchv, m_newramo31, "", a_cts18m00[1].*
                       #-----> PSI 172090
                       ,g_documento.succod    ,g_documento.aplnumdig
                       ,g_documento.itmnumdig ,d_cts18m00.prporgidv
                       ,d_cts18m00.prpnumidv)
              returning a_cts18m00[1].*
      end if

   on key (F8)  ###  Acidente
      if param.tipchv = "I"  then
         call cts18m03 (param.tipchv, acid_cts18m00.*)
              returning acid_cts18m00.*
      end if

 end input
 let aux_email = 1

end function  ###  input_cts18m00

#--------------------------------------------------------------------
 function cts18m00_opcao()
#--------------------------------------------------------------------
  define d_cts18m00a record
     opcao   char (01)
  end record



        initialize  d_cts18m00a.*  to  null

  initialize d_cts18m00a.* to null

  open window cts18m00a at 10,15 with form "cts18m00a"
              attribute(border,form line 1)

  let int_flag = false
  input by name d_cts18m00a.opcao
         without defaults

      before field opcao
         display by name d_cts18m00a.opcao  attribute (reverse)

      after field opcao
         display by name d_cts18m00a.opcao
         if d_cts18m00a.opcao is not null  then
            if d_cts18m00a.opcao < 1  or
               d_cts18m00a.opcao > 3  then
               error "opcao invalida"
               next field opcao
            end if

         end if

      on key (interrupt)
         exit input

  end input
  if int_flag then
     let int_flag = false
  end if
  close window cts18m00a
  return d_cts18m00a.opcao

 end function

#--------------------------------------------------------------------
 function avs_apol_cts18m00(param)
#--------------------------------------------------------------------

 define param         record
    succod            like ssamavs.succod   ,
    aplnumdig         like ssamavs.aplnumdig,
    itmnumdig         like ssamavs.itmnumdig,
    sinocrdat         like ssamavs.sinocrdat,
    sinocrhor         like ssamavs.sinocrhor
 end record

 define ret           record
    sinmotnom         like ssammot.sinmotnom       ,
    cgccpfnum         like ssammot.cgccpfnum       ,
    cgcord            like ssammot.cgcord          ,
    cgccpfdig         like ssammot.cgccpfdig       ,
    endlgd            like ssammot.endlgd          ,
    endbrr            like ssammot.endbrr          ,
    endcid            like ssammot.endcid          ,
    endufd            like ssammot.endufd          ,
    dddcod            like gsakend.dddcod          ,
    telnum            like ssammot.telnum          ,
    cnhnum            like ssammot.cnhnum          ,
    cnhvctdat         like ssammot.cnhvctdat       ,
    sinmotidd         like ssammot.sinmotidd       ,
    sinmotsex         like ssammot.sinmotsex       ,
    cdtestcod         like ssammot.cdtestcod       ,
    sinmotprfcod      like ssammot.sinmotprfcod    ,
    sinmotprfdes      like ssammot.sinmotprfdes    ,
    sinsgrvin         like ssammot.sinsgrvin       ,
    vstnumdig         like avlmlaudo.vstnumdig     ,

    sinlcldes         like ssammot.sinlcldes       ,
    sinendcid         like ssammot.sinendcid       ,
    sinlclufd         like ssammot.sinlclufd       ,
    sinntzcod         like ssamavs.sinntzcod       ,
    sinbocflg         like ssammot.sinbocflg       ,
    dgcnum            like ssammot.dgcnum          ,
    sinvcllcldes      like ssammot.sinvcllcldes    ,
    vclatulgd         like ssammot.vclatulgd       ,
    sinmotcplflg      like ssammot.sinmotcplflg    ,
    sinrclcpdflg      char (01)
 end record

 define ws            record
    sinavsnum         like ssamavs.sinavsnum,
    sinavsano         like ssamavs.sinavsano,
    sinocrdat         like ssamavs.sinocrdat,
    sinocrhor         like ssamavs.sinocrhor
 end record



        initialize  ret.*  to  null

        initialize  ws.*  to  null

 initialize ret.* to null
 initialize ws.*  to null

 if param.sinocrdat is null  or
    param.sinocrhor is null  then
    return ret.*
 end if

 declare c_cts18m00_002 cursor for
    select sinavsnum, sinavsano,
           sinocrdat, sinocrhor
      from ssamavs
     where succod     =  param.succod     and
           ramcod    in  (31,53,531,553)  and
           aplnumdig  =  param.aplnumdig  and
           itmnumdig  =  param.itmnumdig

 foreach c_cts18m00_002 into ws.sinavsnum, ws.sinavsano,
                      ws.sinocrdat, ws.sinocrhor

    if param.sinocrdat <> ws.sinocrdat  then
####   param.sinocrhor <> ws.sinocrhor  then  #inibido conforme Arnaldo
       continue foreach                       #04/12/2002
    else
       select sinmotnom   , cgccpfnum   , cgcord      ,
              cgccpfdig   , endlgd      , endbrr      ,
              endcid      , endufd      , dddcod      ,
              telnum      , cnhnum      , cnhvctdat   ,
              sinmotsex   , sinmotidd   , sinmotprfcod,
              sinmotprfdes, sinsgrvin   , sinlcldes   ,
              sinendcid   , sinlclufd   , sinmotcplflg,
              sinbocflg   , dgcnum      , cdtestcod
         into ret.sinmotnom   ,
              ret.cgccpfnum   ,
              ret.cgcord      ,
              ret.cgccpfdig   ,
              ret.endlgd      ,
              ret.endbrr      ,
              ret.endcid      ,
              ret.endufd      ,
              ret.dddcod      ,
              ret.telnum      ,
              ret.cnhnum      ,
              ret.cnhvctdat   ,
              ret.sinmotsex   ,
              ret.sinmotidd   ,
              ret.sinmotprfcod,
              ret.sinmotprfdes,
              ret.sinsgrvin   ,
              ret.sinlcldes   ,
              ret.sinendcid   ,
              ret.sinlclufd   ,
              ret.sinmotcplflg,
              ret.sinbocflg   ,
              ret.dgcnum      ,
              ret.cdtestcod
         from ssammot
        where sinavsnum    = ws.sinavsnum  and
              sinavsano    = ws.sinavsano  and
              sinsgrmotflg = "S"

       if sqlca.sqlcode = 0  then
          exit foreach
       end if
    end if
 end foreach

 return ret.*

end function  ###  avs_apol_cts18m00

#--------------------------------------------------------------------
 function fax_cts18m00(param)
#--------------------------------------------------------------------

 define param         record
    sinavsnum         like ssamavs.sinavsnum,
    sinavsano         like ssamavs.sinavsano
 end record

 define ws            record
    enviar            char (01)               ,
    dddcod            char (04)               ,
    faxnum            char (09)               ,
    pips              char (20)               ,
    maides            like gcakfilial.maides  ,
    faxch1            like gfxmfax.faxch1     ,
    faxch2            like gfxmfax.faxch2     ,
    funnom            like isskfunc.funnom    ,
    vclmrccod         like agbkmarca.vclmrccod,
    vclmrcnom         like agbkmarca.vclmrcnom,
    vcltipcod         like agbktip.vcltipcod  ,
    vcltipnom         like agbktip.vcltipnom  ,
    vclmdlnom         like agbkveic.vclmdlnom ,
    tabname           like systables.tabname  ,
    codigosql         integer
 end record
 define w_texto   char (80)
 define vl_comando    char(100)
   define  l_mail             record
      de                 char(500)   # De
     ,para               char(5000)  # Para
     ,cc                 char(500)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
  end  record
  define l_coderro  smallint
  define msg_erro char(500)

        let     w_texto  =  null
        let     vl_comando  =  null

        initialize  ws.*  to  null

 let d_cts18m00.sinavsnum = param.sinavsnum
 let d_cts18m00.sinavsano = param.sinavsano

 initialize ws.*  to null
 initialize vl_comando  to null

 if d_cts18m00.corsus is null  then
    error " Corretor nao informado! O aviso nao sera' enviado!"
    return
 end if

 call cts18m10(d_cts18m00.corsus)
      returning ws.enviar, ws.dddcod,
                ws.faxnum, ws.pips,
                ws.maides
 if g_issk.funmat = 601566 then
    display "cts18m10 ws.enviar = ", ws.enviar
    display "         ws.dddcod = ", ws.dddcod
    display "         ws.faxnum = ", ws.faxnum
    display "         ws.pips   = ", ws.pips
    display "         ws.maides = ", ws.maides
 end if
 if ws.pips is null  then
    return
 else
    call cts09g02(ws.dddcod, ws.faxnum) returning ws.dddcod, ws.faxnum
    if g_issk.funmat = 601566 then
       display "cts09g02 ws.enviar = ", ws.enviar
       display "         ws.dddcod = ", ws.dddcod
       display "         ws.faxnum = ", ws.faxnum
       display "         ws.pips   = ", ws.pips
       display "         ws.maides = ", ws.maides
    end if

    if (ws.enviar = "E" and (ws.maides is null or ws.maides  = " " )) or
       (ws.enviar = "F" and (ws.faxnum is null or ws.faxnum  = " " )) then
       error " Corretor nao possui fax/e-mail!"
            ," O aviso sera' enviado atraves de carta!"
       call ssaminterf_ins(d_cts18m00.sinavsano,
                           d_cts18m00.sinavsnum,
                           d_cts18m00.ramcod   ,
                           g_issk.funmat       )
                 returning ws.tabname, ws.codigosql

       if ws.codigosql <> 0  then
          error " Erro (", ws.codigosql, ") na gravacao da interface",
                " com sistema de sinistro. AVISE A INFORMATICA!"
          return
       end if
    else
       if ws.enviar = "F"  or
          ws.enviar = "A"  or
          ws.enviar = "E"  then
          call ssamfax_ins(d_cts18m00.sinavsnum,
                           d_cts18m00.sinavsano,
                           g_issk.funmat       )
                 returning ws.faxch1 , ws.faxch2,
                           ws.tabname, ws.codigosql

          if ws.codigosql = 0  then
             case ws.enviar
               when "F" error " FAX sendo enviado... Prossiga..."
               when "A" error " FAX/E-MAIL sendo enviado... Prossiga..."
               when "E" error " E-MAIL sendo enviado... Prossiga..."
             end case
          else
             error " Erro (",ws.codigosql, ") no envio do fax/E-Mail."
                  ," AVISE A INFORMATICA!"
             return
          end if
       end if

       select funnom into ws.funnom
         from isskfunc
        where empcod = g_issk.empcod     #1                           #Raul, Biz
          and funmat = g_issk.funmat

       select vclmrccod, vcltipcod, vclmdlnom
         into ws.vclmrccod,
              ws.vcltipcod,
              ws.vclmdlnom
         from agbkveic
        where vclcoddig = d_cts18m00.vclcoddig

       if sqlca.sqlcode = 0  then
          select vclmrcnom
            into ws.vclmrcnom
            from agbkmarca
           where vclmrccod = ws.vclmrccod

          select vcltipnom
            into ws.vcltipnom
            from agbktip
           where vclmrccod = ws.vclmrccod  and
                 vcltipcod = ws.vcltipcod
       end if

       if ws.enviar = "A" then
         if g_hostname <> "u07" then
          let ws.enviar = "F"
          call ssarel09a(g_documento.succod         ,
                      d_cts18m00.ramcod          ,
                      d_cts18m00.subcod          ,
                      g_documento.aplnumdig      ,
                      g_documento.itmnumdig      ,
                      d_cts18m00.prpnumidv       ,
                      ""                         ,
                      d_cts18m00.sinvstnum       ,
                      d_cts18m00.sinvstano       ,
                      d_cts18m00.sinocrdat       ,
                      d_cts18m00.sinocrhor       ,
                      d_cts18m00.segnom          ,
                      d_cts18m00.endlgd          ,
                      d_cts18m00.segtelnum       ,
                      d_cts18m00.cornom          ,
                      d_cts18m00.corsus          ,
                      ws.vclmrcnom               ,
                      ws.vcltipnom               ,
                      ws.vclmdlnom               ,
                      d_cts18m00.vclchsnum[13,20],
                      d_cts18m00.vcllicnum       ,
                      d_cts18m00.cortelnum       ,
                      d_cts18m00.vclanofbc       ,
                      d_cts18m00.vclanomdl       ,
                      d_cts18m00.trcvclcod       ,
                      d_cts18m00.sinrclnom       ,
                      d_cts18m00.trctelnum       ,
                      d_cts18m00.endlgd          ,
                      d_cts18m00.cgccpfnum       ,
                      d_cts18m00.cgcord          ,
                      d_cts18m00.cgccpfdig       ,
                      d_cts18m00.sinbemdes       ,
                      d_cts18m00.trcvclcod       ,
                      d_cts18m00.trcvclchs       ,
                      d_cts18m00.trcvcllic       ,
                      d_cts18m00.trcanofbc       ,
                      d_cts18m00.trcanomdl       ,
                      d_cts18m00.trccorcod       ,
                      d_cts18m00.trccordes       ,
                      d_cts18m00.sinrclsgrflg    ,
                      d_cts18m00.sinrclsgdnom    ,
                      d_cts18m00.sinrclapltxt    ,
                      acid_cts18m00.sinrclcpdflg ,
                      d_cts18m00.sinvclguiflg    ,
                      d_cts18m00.sinvclguinom    ,
                      a_cts18m00[1].sinmotnom    ,
                      a_cts18m00[1].cgccpfnum    ,
                      a_cts18m00[1].cgcord       ,
                      a_cts18m00[1].cgccpfdig    ,
                      a_cts18m00[1].endlgd       ,
                      a_cts18m00[1].endbrr       ,
                      a_cts18m00[1].endcid       ,
                      a_cts18m00[1].endufd       ,
                      a_cts18m00[1].telnum       ,
                      a_cts18m00[1].sinmotidd    ,
                      a_cts18m00[1].sinmotsex    ,
                      a_cts18m00[1].sinmotprfcod ,
                      a_cts18m00[1].sinsgrvin    ,
                      a_cts18m00[1].cnhnum       ,
                      a_cts18m00[1].cnhvctdat    ,
                      acid_cts18m00.sinlcldes    ,
                      acid_cts18m00.sinendcid    ,
                      acid_cts18m00.sinlclufd    ,
                      acid_cts18m00.sinbocflg    ,
                      acid_cts18m00.dgcnum       ,
                      acid_cts18m00.sinvcllcldes ,
                      acid_cts18m00.vclatulgd    ,
                      acid_cts18m00.sinmotcplflg ,
                      a_cts18m00[2].sinmotnom    ,
                      a_cts18m00[2].cgccpfnum    ,
                      a_cts18m00[2].cgcord       ,
                      a_cts18m00[2].cgccpfdig    ,
                      a_cts18m00[2].endlgd       ,
                      a_cts18m00[2].endbrr       ,
                      a_cts18m00[2].endcid       ,
                      a_cts18m00[2].endufd       ,
                      a_cts18m00[2].telnum       ,
                      a_cts18m00[2].cnhnum       ,
                      a_cts18m00[2].cnhvctdat    ,
                      ws.pips                    ,
                      ws.enviar                  ,
                      ws.dddcod                  ,
                      ws.faxnum                  ,
                      ws.funnom                  ,
                      d_cts18m00.sinavsnum       ,
                      d_cts18m00.sinavsano       ,
                      ws.faxch1  , ws.faxch2     )
         end if
         let ws.pips = "rcts18m1001"
         let ws.enviar = "E"
         call ssarel09a(g_documento.succod         ,
                      d_cts18m00.ramcod          ,
                      d_cts18m00.subcod          ,
                      g_documento.aplnumdig      ,
                      g_documento.itmnumdig      ,
                      d_cts18m00.prpnumidv       ,
                      ""                         ,
                      d_cts18m00.sinvstnum       ,
                      d_cts18m00.sinvstano       ,
                      d_cts18m00.sinocrdat       ,
                      d_cts18m00.sinocrhor       ,
                      d_cts18m00.segnom          ,
                      d_cts18m00.endlgd          ,
                      d_cts18m00.segtelnum       ,
                      d_cts18m00.cornom          ,
                      d_cts18m00.corsus          ,
                      ws.vclmrcnom               ,
                      ws.vcltipnom               ,
                      ws.vclmdlnom               ,
                      d_cts18m00.vclchsnum[13,20],
                      d_cts18m00.vcllicnum       ,
                      d_cts18m00.cortelnum       ,
                      d_cts18m00.vclanofbc       ,
                      d_cts18m00.vclanomdl       ,
                      d_cts18m00.trcvclcod       ,
                      d_cts18m00.sinrclnom       ,
                      d_cts18m00.trctelnum       ,
                      d_cts18m00.endlgd          ,
                      d_cts18m00.cgccpfnum       ,
                      d_cts18m00.cgcord          ,
                      d_cts18m00.cgccpfdig       ,
                      d_cts18m00.sinbemdes       ,
                      d_cts18m00.trcvclcod       ,
                      d_cts18m00.trcvclchs       ,
                      d_cts18m00.trcvcllic       ,
                      d_cts18m00.trcanofbc       ,
                      d_cts18m00.trcanomdl       ,
                      d_cts18m00.trccorcod       ,
                      d_cts18m00.trccordes       ,
                      d_cts18m00.sinrclsgrflg    ,
                      d_cts18m00.sinrclsgdnom    ,
                      d_cts18m00.sinrclapltxt    ,
                      acid_cts18m00.sinrclcpdflg ,
                      d_cts18m00.sinvclguiflg    ,
                      d_cts18m00.sinvclguinom    ,
                      a_cts18m00[1].sinmotnom    ,
                      a_cts18m00[1].cgccpfnum    ,
                      a_cts18m00[1].cgcord       ,
                      a_cts18m00[1].cgccpfdig    ,
                      a_cts18m00[1].endlgd       ,
                      a_cts18m00[1].endbrr       ,
                      a_cts18m00[1].endcid       ,
                      a_cts18m00[1].endufd       ,
                      a_cts18m00[1].telnum       ,
                      a_cts18m00[1].sinmotidd    ,
                      a_cts18m00[1].sinmotsex    ,
                      a_cts18m00[1].sinmotprfcod ,
                      a_cts18m00[1].sinsgrvin    ,
                      a_cts18m00[1].cnhnum       ,
                      a_cts18m00[1].cnhvctdat    ,
                      acid_cts18m00.sinlcldes    ,
                      acid_cts18m00.sinendcid    ,
                      acid_cts18m00.sinlclufd    ,
                      acid_cts18m00.sinbocflg    ,
                      acid_cts18m00.dgcnum       ,
                      acid_cts18m00.sinvcllcldes ,
                      acid_cts18m00.vclatulgd    ,
                      acid_cts18m00.sinmotcplflg ,
                      a_cts18m00[2].sinmotnom    ,
                      a_cts18m00[2].cgccpfnum    ,
                      a_cts18m00[2].cgcord       ,
                      a_cts18m00[2].cgccpfdig    ,
                      a_cts18m00[2].endlgd       ,
                      a_cts18m00[2].endbrr       ,
                      a_cts18m00[2].endcid       ,
                      a_cts18m00[2].endufd       ,
                      a_cts18m00[2].telnum       ,
                      a_cts18m00[2].cnhnum       ,
                      a_cts18m00[2].cnhvctdat    ,
                      ws.pips                    ,
                      ws.enviar                  ,
                      ws.dddcod                  ,
                      ws.faxnum                  ,
                      ws.funnom                  ,
                      d_cts18m00.sinavsnum       ,
                      d_cts18m00.sinavsano       ,
                      ws.faxch1  , ws.faxch2     )
       else
          call ssarel09a(g_documento.succod         ,
                      d_cts18m00.ramcod          ,
                      d_cts18m00.subcod          ,
                      g_documento.aplnumdig      ,
                      g_documento.itmnumdig      ,
                      d_cts18m00.prpnumidv       ,
                      ""                         ,
                      d_cts18m00.sinvstnum       ,
                      d_cts18m00.sinvstano       ,
                      d_cts18m00.sinocrdat       ,
                      d_cts18m00.sinocrhor       ,
                      d_cts18m00.segnom          ,
                      d_cts18m00.endlgd          ,
                      d_cts18m00.segtelnum       ,
                      d_cts18m00.cornom          ,
                      d_cts18m00.corsus          ,
                      ws.vclmrcnom               ,
                      ws.vcltipnom               ,
                      ws.vclmdlnom               ,
                      d_cts18m00.vclchsnum[13,20],
                      d_cts18m00.vcllicnum       ,
                      d_cts18m00.cortelnum       ,
                      d_cts18m00.vclanofbc       ,
                      d_cts18m00.vclanomdl       ,
                      d_cts18m00.trcvclcod       ,
                      d_cts18m00.sinrclnom       ,
                      d_cts18m00.trctelnum       ,
                      d_cts18m00.endlgd          ,
                      d_cts18m00.cgccpfnum       ,
                      d_cts18m00.cgcord          ,
                      d_cts18m00.cgccpfdig       ,
                      d_cts18m00.sinbemdes       ,
                      d_cts18m00.trcvclcod       ,
                      d_cts18m00.trcvclchs       ,
                      d_cts18m00.trcvcllic       ,
                      d_cts18m00.trcanofbc       ,
                      d_cts18m00.trcanomdl       ,
                      d_cts18m00.trccorcod       ,
                      d_cts18m00.trccordes       ,
                      d_cts18m00.sinrclsgrflg    ,
                      d_cts18m00.sinrclsgdnom    ,
                      d_cts18m00.sinrclapltxt    ,
                      acid_cts18m00.sinrclcpdflg ,
                      d_cts18m00.sinvclguiflg    ,
                      d_cts18m00.sinvclguinom    ,
                      a_cts18m00[1].sinmotnom    ,
                      a_cts18m00[1].cgccpfnum    ,
                      a_cts18m00[1].cgcord       ,
                      a_cts18m00[1].cgccpfdig    ,
                      a_cts18m00[1].endlgd       ,
                      a_cts18m00[1].endbrr       ,
                      a_cts18m00[1].endcid       ,
                      a_cts18m00[1].endufd       ,
                      a_cts18m00[1].telnum       ,
                      a_cts18m00[1].sinmotidd    ,
                      a_cts18m00[1].sinmotsex    ,
                      a_cts18m00[1].sinmotprfcod ,
                      a_cts18m00[1].sinsgrvin    ,
                      a_cts18m00[1].cnhnum       ,
                      a_cts18m00[1].cnhvctdat    ,
                      acid_cts18m00.sinlcldes    ,
                      acid_cts18m00.sinendcid    ,
                      acid_cts18m00.sinlclufd    ,
                      acid_cts18m00.sinbocflg    ,
                      acid_cts18m00.dgcnum       ,
                      acid_cts18m00.sinvcllcldes ,
                      acid_cts18m00.vclatulgd    ,
                      acid_cts18m00.sinmotcplflg ,
                      a_cts18m00[2].sinmotnom    ,
                      a_cts18m00[2].cgccpfnum    ,
                      a_cts18m00[2].cgcord       ,
                      a_cts18m00[2].cgccpfdig    ,
                      a_cts18m00[2].endlgd       ,
                      a_cts18m00[2].endbrr       ,
                      a_cts18m00[2].endcid       ,
                      a_cts18m00[2].endufd       ,
                      a_cts18m00[2].telnum       ,
                      a_cts18m00[2].cnhnum       ,
                      a_cts18m00[2].cnhvctdat    ,
                      ws.pips                    ,
                      ws.enviar                  ,
                      ws.dddcod                  ,
                      ws.faxnum                  ,
                      ws.funnom                  ,
                      d_cts18m00.sinavsnum       ,
                      d_cts18m00.sinavsano       ,
                      ws.faxch1  , ws.faxch2     )
       end if
       if ws.enviar = "E" or
          ws.enviar = "A" then
          #PSI-2013-23297 - Inicio
          let l_mail.de = ""
          #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
          let l_mail.para = ws.maides
          let l_mail.cc = ""
          let l_mail.cco = ""
          let l_mail.assunto = "Aviso de Sinistro"
          let l_mail.mensagem = ""
          let l_mail.id_remetente = "CT24H"
          let l_mail.tipo = "text"

          call figrc009_attach_file(ws.pips)
          call figrc009_mail_send1 (l_mail.*)
           returning l_coderro,msg_erro
          #PSI-2013-23297 - Fim
          let vl_comando = " rm ", ws.pips clipped
          run vl_comando

       end if
       case ws.enviar
          when "F" error " FAX sendo enviado... Prossiga..."
          when "A" error " FAX/E-MAIL sendo enviado... Prossiga..."
          when "E" error " E-MAIL sendo enviado... Prossiga..."
       end case
       sleep 2
       error ""
    end if
 end if
end function  ###  fax_cts18m00

#--------------------------------------------------------------------
 function idade_cts18m00(param)
#--------------------------------------------------------------------

 define param         record
    nscdat            date,
    clcdat            date
 end record

 define w_idade       smallint


        let     w_idade  =  null

 initialize w_idade to null

 if param.nscdat is null  or
    param.clcdat is null  then
    return w_idade
 end if

 let w_idade = year(param.clcdat) - year(param.nscdat)

 if month(param.clcdat) > month(param.nscdat)  then
    return w_idade
 end if

 if month(param.clcdat)  =   month(param.nscdat)  and
    day  (param.clcdat)  >=  day  (param.nscdat)  then
    return w_idade
 end if

 let w_idade  =  w_idade  -  1
 return w_idade

end function  ###  idade_cts18m00

#--------------------------------------------------------------------
 function veiculo_cts18m00(param)
#--------------------------------------------------------------------

 define param         record
    vclcoddig         like agbkveic.vclcoddig
 end record

 define ws            record
    vclmrccod         like agbkveic.vclmrccod      ,
    vclmrcnom         like agbkmarca.vclmrcnom     ,
    vcltipcod         like agbkveic.vcltipcod      ,
    vcltipnom         like agbktip.vcltipnom       ,
    vclmdlnom         like agbkveic.vclmdlnom      ,
    vcldes            char (50)
 end record



        initialize  ws.*  to  null

 initialize ws.* to null

 if param.vclcoddig is null  then
    return ws.vcldes
 end if

 select vclmrccod,
        vcltipcod,
        vclmdlnom
   into ws.vclmrccod,
        ws.vcltipcod,
        ws.vclmdlnom
   from agbkveic
  where vclcoddig = param.vclcoddig

 select vclmrcnom
   into ws.vclmrcnom
   from agbkmarca
  where vclmrccod = ws.vclmrccod

 select vcltipnom
   into ws.vcltipnom
   from agbktip
  where vclmrccod = ws.vclmrccod    and
        vcltipcod = ws.vcltipcod

 let ws.vcldes = ws.vclmrcnom  clipped, " ",
                 ws.vcltipnom  clipped, " ",
                 ws.vclmdlnom  clipped

 return ws.vcldes

 end function  ###  veiculo_cts18m00
#-----------------------------------------------------------------------------
 function cts18m00_salvaglobal(param)
#-----------------------------------------------------------------------------
    define param   record
        segflg     char(01)
    end record


    if param.segflg   =  "S"  then
       let slv_segurado.succod        = g_documento.succod
       let slv_segurado.ramcod        = g_documento.ramcod
       let slv_segurado.aplnumdig     = g_documento.aplnumdig
       let slv_segurado.itmnumdig     = g_documento.itmnumdig
       let slv_segurado.edsnumref     = g_documento.edsnumref
       let slv_segurado.lignum        = g_documento.lignum
       let slv_segurado.c24soltipcod  = g_documento.c24soltipcod
       let slv_segurado.solnom        = g_documento.solnom
       let slv_segurado.c24astcod     = g_documento.c24astcod
       let slv_segurado.ligcvntip     = g_documento.ligcvntip
       let slv_segurado.prporg        = g_documento.prporg
       let slv_segurado.prpnumdig     = g_documento.prpnumdig
       let slv_segurado.fcapacorg     = g_documento.fcapacorg
       let slv_segurado.fcapacnum     = g_documento.fcapacnum
       let slv_segurado.dctnumseq     = g_funapol.dctnumseq
       let slv_segurado.vclsitatu     = g_funapol.vclsitatu
       let slv_segurado.autsitatu     = g_funapol.autsitatu
       let slv_segurado.dmtsitatu     = g_funapol.dmtsitatu
       let slv_segurado.dpssitatu     = g_funapol.dpssitatu
       let slv_segurado.atdnum        = g_documento.atdnum

       -------------[ mesma rotina de inicializacao do cta00m01 ]-------------
       initialize g_dctoarray            to null
       initialize g_funapol.*            to null
       initialize g_documento.succod     to null
       initialize g_documento.ramcod     to null
       initialize g_documento.aplnumdig  to null
       initialize g_documento.itmnumdig  to null
       initialize g_documento.edsnumref  to null
       initialize g_documento.fcapacorg  to null
       initialize g_documento.fcapacnum  to null
       initialize g_documento.sinramcod  to null
       initialize g_documento.sinano     to null
       initialize g_documento.sinnum     to null
       initialize g_documento.vstnumdig  to null
    else
       let g_documento.succod         = slv_segurado.succod
       let g_documento.ramcod         = slv_segurado.ramcod
       let g_documento.aplnumdig      = slv_segurado.aplnumdig
       let g_documento.itmnumdig      = slv_segurado.itmnumdig
       let g_documento.edsnumref      = slv_segurado.edsnumref
       let g_documento.lignum         = slv_segurado.lignum
       let g_documento.c24soltipcod   = slv_segurado.c24soltipcod
       let g_documento.solnom         = slv_segurado.solnom
       let g_documento.c24astcod      = slv_segurado.c24astcod
       let g_documento.ligcvntip      = slv_segurado.ligcvntip
       let g_documento.prporg         = slv_segurado.prporg
       let g_documento.prpnumdig      = slv_segurado.prpnumdig
       let g_documento.fcapacorg      = slv_segurado.fcapacorg
       let g_documento.fcapacnum      = slv_segurado.fcapacnum
       let g_funapol.dctnumseq        = slv_segurado.dctnumseq
       let g_funapol.vclsitatu        = slv_segurado.vclsitatu
       let g_funapol.autsitatu        = slv_segurado.autsitatu
       let g_funapol.dmtsitatu        = slv_segurado.dmtsitatu
       let slv_segurado.dpssitatu     = g_funapol.dpssitatu
       let g_documento.atdnum         = slv_segurado.atdnum


    end if
   #if g_issk.funmat = 601566 then
   #   display "** fiz a salva - ", param.segflg
   #end if
 end function

#------------------------------------------------------------------------------
 function cts18m00_carregadados_terceiro()
#------------------------------------------------------------------------------
    define ws       record
       dctnumseq1   like abamdoc.dctnumseq,
       edsstt1      smallint,
       segnumdig1   like gsakseg.segnumdig,
       vclchsinc1   like abbmveic.vclchsinc,
       vclchsfnl1   like abbmveic.vclchsfnl,
       endlgd1      like gsakend.endlgd,
       endnum1      like gsakend.endnum,
       endcmp1      like gsakend.endcmp,
       vstnumdig    like avlmlaudo.vstnumdig,
       vstdat       date                    ,
       viginc       like abbmdoc.viginc     ,
       vigfnl       like abbmdoc.vigfnl
    end record



        initialize  ws.*  to  null

    if g_documento.succod    is not null  and
       g_documento.aplnumdig is not null  and
       g_documento.itmnumdig is not null  then

      #let d_cts18m00.sinrclapltxt = g_documento.succod    using "&&",
      #                         " ", g_documento.ramcod    using "&&&&",
      #                         " ", g_documento.aplnumdig using "<<<<<<<& &"

       let d_cts18m00.sinrclapltxt = g_documento.aplnumdig using "<<<<<<<& &"

       #--------------------------------------------------------------------
       # Situacao da apolice na data de ocorrencia do sinistro
       #--------------------------------------------------------------------

       call findeds (g_documento.succod   , g_documento.aplnumdig,
                     g_documento.itmnumdig, d_cts18m00.sinocrdat)
           returning ws.dctnumseq1, ws.edsstt1


       select edsnumdig
         into g_documento.edsnumref
         from abamdoc
        where succod     =  g_documento.succod      and
              aplnumdig  =  g_documento.aplnumdig   and
              dctnumseq  =  ws.dctnumseq1

       call f_funapol_auto (g_documento.succod   , g_documento.aplnumdig,
                            g_documento.itmnumdig, g_documento.edsnumref)
                  returning g_funapol.*

       #--------------------------------------------------------------------
       # Dados do segurado da apolice
       #--------------------------------------------------------------------
       select segnumdig
          into ws.segnumdig1
          from abbmdoc
         where succod    = g_documento.succod    and
               aplnumdig = g_documento.aplnumdig and
               itmnumdig = g_documento.itmnumdig and
               dctnumseq = g_funapol.dctnumseq

       #--------------------------------------------------------------------
       # Dados do veiculo da apolice
       #--------------------------------------------------------------------
       select vclcoddig,
              vcllicnum,
              vclanofbc,
              vclanomdl,
              vclchsinc,
              vclchsfnl,
              vstnumdig
         into d_cts18m00.trcvclcod,
              d_cts18m00.trcvcllic,
              d_cts18m00.trcanofbc,
              d_cts18m00.trcanomdl,
              ws.vclchsinc1       ,
              ws.vclchsfnl1       ,
              ws.vstnumdig
         from abbmveic
        where succod    = g_documento.succod     and
              aplnumdig = g_documento.aplnumdig  and
              itmnumdig = g_documento.itmnumdig  and
              dctnumseq = g_funapol.vclsitatu

       if sqlca.sqlcode = notfound  then
          select vclcoddig,
                 vcllicnum,
                 vclanofbc,
                 vclanomdl,
                 vclchsinc,
                 vclchsfnl
            into d_cts18m00.trcvclcod,
                 d_cts18m00.trcvcllic,
                 d_cts18m00.trcanofbc,
                 d_cts18m00.trcanomdl,
                 ws.vclchsinc1        ,
                 ws.vclchsfnl1
            from abbmveic
           where succod    = g_documento.succod      and
                 aplnumdig = g_documento.aplnumdig   and
                 itmnumdig = g_documento.itmnumdig   and
                 dctnumseq = (select max(dctnumseq)
                                from abbmveic
                               where succod    = g_documento.succod      and
                                     aplnumdig = g_documento.aplnumdig   and
                                     itmnumdig = g_documento.itmnumdig)
       end if
       select viginc, vigfnl
            into ws.viginc,
                 ws.vigfnl
            from abamapol
           where succod    = g_documento.succod    and
                 aplnumdig = g_documento.aplnumdig

       let d_cts18m00.viginc = ws.viginc
       let d_cts18m00.vigfnl = ws.vigfnl

       if ws.vstnumdig is not null then
          select vstdat
             into ws.vstdat
             from avlmlaudo
            where vstnumdig = ws.vstnumdig
          if ws.vstdat is not null then
             if ws.vstdat >= ws.viginc and
                ws.vstdat <= ws.vigfnl then
             else
                let ws.vstnumdig = null
             end if
          end if
       end if
       if g_issk.funmat = 601566 then
          display "vp = ", ws.vstnumdig," data vp = ",ws.vstdat
       end if

       #--------------------------------------------------------------------
       # Dados do segurado
       #--------------------------------------------------------------------
       select segnom   , cgccpfnum,
              cgcord   , cgccpfdig,
              segsex   , nscdat
         into d_cts18m00.sinrclnom,
              d_cts18m00.cgccpfnum,
              d_cts18m00.cgcord   ,
              d_cts18m00.cgccpfdig
         from gsakseg
        where segnumdig  =  ws.segnumdig1

       select endlgd, endnum, endcmp,
              endbrr, endcid, endufd,
              dddcod, teltxt
         into ws.endlgd1          , ws.endnum1,
              ws.endcmp1          , d_cts18m00.endbrr,
              d_cts18m00.endcid   , d_cts18m00.endufd,
              d_cts18m00.trcdddcod, d_cts18m00.trctelnum
         from gsakend
        where segnumdig  =  ws.segnumdig1   and
              endfld     =  "1"

       let d_cts18m00.endlgd = ws.endlgd1 clipped, " ",
                               ws.endnum1 clipped, " ",
                               ws.endcmp1 clipped

       #--------------------------------------------------------------------
       # Dados do veiculo
       #--------------------------------------------------------------------
       if d_cts18m00.trcvclcod is not null  then
          call veiculo_cts18m00(d_cts18m00.trcvclcod)
               returning d_cts18m00.sinbemdes
       end if
       let d_cts18m00.trcvclchs = ws.vclchsinc1 clipped, ws.vclchsfnl1 clipped
       let d_cts18m00.sinrclsgrflg = "S"
       let d_cts18m00.sinrclsgdnom = "PORTO SEGURO"
    end if
 end function

###############################################################################
function cts18m00b()
#-----------------------------------------------------------------------------#

  define l_cts18m00b record
         opcao  char (01)
  end record



        initialize  l_cts18m00b.*  to  null

  initialize l_cts18m00b to null
  display  "CPF :", m_retorno.cgccpfnum   ,
                    m_retorno.cgcord      ,
                    m_retorno.cgccpfdig

  open window cts18m00b at 06,02 with form "cts18m00b"
       attribute(border,form line first)

     let int_flag = false

     display by name m_retorno.sinrclnom   ,
                     m_retorno.sinrcltel   ,
                     m_retorno.sinrclend   ,
                     m_retorno.endbrr      ,
                     m_retorno.sinrclendcid,
                     m_retorno.sinrclendufd,
                     m_retorno.vclcoddig   ,
                     m_retorno.vclchsnum   ,
                     m_retorno.vcllicnum   ,
                     m_retorno.vclanomdl   ,
                     m_retorno.vclanofbc   ,
                     m_retorno.vcldencor   ,
                     m_retorno.cgccpfnum   ,
                     m_retorno.cgcord      ,
                     m_retorno.cgccpfdig   ,
                     m_retorno.sinvstnum   ,
                     m_retorno.sinvstano   ,
                     m_retorno.sinnum      ,
                     m_retorno.sinano

     input by name l_cts18m00b.opcao
           without defaults

        before field opcao
           display by name l_cts18m00b.opcao  attribute (reverse)

        after field opcao
           display by name l_cts18m00b.opcao
           if l_cts18m00b.opcao is null then
              error "Informar 'S' ou 'N' !"
              next field opcao
           end if

           if l_cts18m00b.opcao <> "S" and
              l_cts18m00b.opcao <> "N" then
              error "Informar somente 'S' ou 'N' !"
              next field opcao
           end if

        on key (interrupt)
           exit input

     end input

     if int_flag then
        let int_flag = false
     end if

  close window cts18m00b

  return l_cts18m00b.opcao

end function
