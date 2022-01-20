#############################################################################
# Nome do Modulo: CTS14M00                                            Pedro #
#                                                                   Marcelo #
# Marcacao de Vistoria Sinistro de Automovel                       Jun/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00), passando parametros #
#                                       de registro via formulario.         #
#---------------------------------------------------------------------------#
# 02/12/1998  PSI 7265-6   Gilberto     Incluir criticas referentes a data  #
#                                       de marcacao da vistoria de sinistro #
#---------------------------------------------------------------------------#
# 07/12/1998  PSI 6478-5   Gilberto     Alteracao na chamada da funcao de   #
#                                       cabecalho (CTS05G00), inclusao do   #
#                                       parametro RAMO.                     #
#---------------------------------------------------------------------------#
# 20/08/1999  PSI 5591-3   Gilberto     Retirada dos campos DDD e telefone  #
#                                       do cabecalho.                       #
#---------------------------------------------------------------------------#
# 27/08/1999  PSI 9165-0   Wagner       Alterar mensagem do codigo "V11"    #
#                                       de 48 para 24HORAS.                 #
#---------------------------------------------------------------------------#
# 20/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 12/11/1999  PSI 9118-9   Gilberto     Retirada do campo LIGREF.           #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 22/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 01/03/2002  PSI 132314   Ruiz         Obrigar digitar historico.          #
#---------------------------------------------------------------------------#
# 26/03/2002  AS           Ruiz         Alterar horario para marcacao de    #
#                                       18:35 p/ 18:00 e retorno de 13:35 p/#
#                                       18:00 hrs.                          #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor   Fabrica     Origem     Alteracao                        #
# ---------- ----------------- ---------- -----------------------------------#
# 11/03/2005 Daniel, Meta       PS191094  Chamar a funcao cta00m06()         #
#                                         Exibir as teclas de funcoes        #
#                                         Chamar a funcao cta01m12()         #
#----------------------------------------------------------------------------#
# 22/12/2005 Julianna,Meta      PSI195693 Inclusao da funcao                 #
#                                         cts14m00_monta_xml()               #
#----------------------------------------------------------------------------#
# 02/02/2006 Priscila           Zeladoria Buscar data e hora no banco de dado#
#----------------------------------------------------------------------------#
# 22/09/2006 Ruiz               PSI 202720  Inclusao de parametros na funcao #
#                                           cta01m12(cartao saude).          #
# 16/11/2006 Ligia              PSI 205206  ciaempcod                        #
#----------------------------------------------------------------------------#
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# ---------- ------------- --------- ----------------------------------------#
# 15/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32             #
# -------------------------------------------------------------------------- #
# 07/04/2008 Luiz Araujo   PSI216445 Inclusao de envio de email com          #
#                                    informacoes da oficina escolhida        #
#----------------------------------------------------------------------------#
# 24/11/2008 Luiz Araujo   PSI228125 ??????????????????????????????          #
#                                    ??????????????????????????????          #
#----------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a   #
#                                         global                             #
#----------------------------------------------------------------------------#
# 30/12/2008 Priscila                      Exibir mensagem de erro retornada #
#                                          por ctd25g00                      #
#----------------------------------------------------------------------------#
# 04/01/2010 Amilton                       Projeto sucursal smallint         #
#----------------------------------------------------------------------------#
# 09/05/2012   Silvia        PSI 2012-07408  Anatel - DDD/Telefone           #
#----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail  #
##############################################################################


 globals  "/homedsa/projetos/geral/globals/glct.4gl"
 globals "/homedsa/projetos/geral/globals/figrc072.4gl"   --> 223689
 # Projeto separacao do ambientes
globals "/homedsa/projetos/geral/globals/figrc012.4gl"

 define d_cts14m00    record
    vistoria          char (09)                ,
    tipo              char (08)                ,
    vstsolnom         like datmvstsin.vstsolnom,
    segnom            like datmvstsin.segnom   ,
    doctxt            char (32)                ,
    cornom            like gcakcorr.cornom     ,
    corsus            like gcaksusep.corsus    ,
    cvnnom            char (19)                ,
    vcldes            like datmvstsin.vcldes   ,
    vclanomdl         like datmvstsin.vclanomdl,
    vcllicnum         like datmvstsin.vcllicnum,
    vclchsfnl         like datmvstsin.vclchsfnl,
    vclchsinc         like datmvstsin.vclchsinc,
    vstretflg         like datmvstsin.vstretflg,
    vstretnum         like datmvstsin.sinvstnum,
    vstretano         like datmvstsin.sinvstano,
   #sinvstrgi         like datmvstsin.sinvstrgi,
   #descricao         char (22)                ,
    sindat            like datmvstsin.sindat   ,
    sinavs            like datmvstsin.sinavs   ,
    avisocom          char (09)                ,
    orcvlr            like datmvstsin.orcvlr   ,
    nomrazsoc         like gkpkpos.nomrazsoc   ,
    ofnnumdig         like datmvstsin.ofnnumdig,
    endlgd            like gkpkpos.endlgd      ,
    endbrr            like gkpkpos.endbrr      ,
    endcid            like gkpkpos.endcid      ,
    endufd            like gkpkpos.endufd      ,
    dddcodofi         like datmvstsin.dddcod   ,
    telnumofi         like gkpkpos.telnum1     ,
    vstdat            like datmvstsin.vstdat   ,
    sinvstorgnum      like datmvstsin.sinvstnum,
    sinvstorgano      like datmvstsin.sinvstano,
    dddcodctt         char (04)                ,
    telnumctt         char (20)
    ,chassi            char (20)
    ,horvst            datetime hour to second

 end record

 define w_cts14m00    record
    ano2              char (02)                 ,
    ano4              char (04)                 ,
    data              char (10)                 ,
    hora              char (05)                 ,
    vistoria          char (08)                 ,
    sinvstnum         like datmvstsin.sinvstnum ,
    ramcod            like datmvstsin.ramcod    ,
    ofnstt            like sgokofi.ofnstt       ,
    pstcoddig         like gkpkpos.pstcoddig    ,
    telnumofi         like gkpkpos.telnum1      ,
    ligcvntip         like datmligacao.ligcvntip,
    dddcod            like datmvstsin.dddcod    ,
    teltxt            char (09)
 end record

 define l_cmd        char(500)
 # LH
 define r_erro varchar(100)

 define l_mens       record
        msg          char(200)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(100)
       ,cc           char(100)
 end record
 define m_hostname    like ibpkdbspace.srvnom
 define m_server      char(04)
 define m_hostname1   like ibpkdbspace.srvnom
 define m_server1     char(04)

 define l_sql         char(2000)

 ## PSI 206.938 Aviso Demais Naturezas
 define m_sinevtnum like sanmevt.sinevtnum
 define m_aviso     like sanmavs.sinavsnum
 define m_ordem     integer
 define m_regular   char (1)
 define m_trcvclcod like ssamavsvcl.vclcoddig

#-----------------------------------------------------------
 function cts14m00()
#-----------------------------------------------------------

 define ws        record
        vclcoddig like abbmveic.vclcoddig,
        vclchsinc like abbmveic.vclchsinc,
        vclcordes char(11),
        grvflg    smallint
 end record

 define l_data      date,
        l_hora2     datetime hour to minute,
        l_grlchv    like datkgeral.grlchv,
        l_grlinf    like datkgeral.grlinf,
        l_succod    like abamapol.succod,
        l_ramcod    like rsamseguro.ramcod,
        l_aplnumdig like abamapol.aplnumdig,
        l_itmnumdig like abbmdoc.itmnumdig

 define l_semdoc    char(1)

 let l_succod    = null
 let l_ramcod    = null
 let l_aplnumdig = null
 let l_itmnumdig = null

 let m_sinevtnum  = null
 let m_aviso      = null
 let m_ordem      = null
 let m_regular    = null
 let l_semdoc     = null


 initialize  ws.*  to  null

 initialize d_cts14m00.* to null
 initialize w_cts14m00.* to null
 initialize ws.*         to null
 initialize m_hostname   to null
 initialize m_server     to null
 initialize l_sql        to null

 let int_flag        = false
 let ws.grvflg       = false

 call fun_dba_abre_banco('ORCAMAUTO')
 let m_server   = fun_dba_servidor("EMISAUTO")
 let m_hostname = "porto@", m_server clipped , ":"
 let m_server1   = fun_dba_servidor("SINIS")
 let m_hostname1 = "porto@", m_server clipped , ":"


 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
 let w_cts14m00.data = l_data
 let w_cts14m00.hora = l_hora2
 let w_cts14m00.ano2 = w_cts14m00.data[9,10]
 let w_cts14m00.ano4 = w_cts14m00.data[7,10]

 open window cts14m00 at 04,02 with form "cts14m00"
             attribute (form line 1)

 ## PSI 191965 - Parametro de Horario para atendimento
 let d_cts14m00.horvst = "18:30:00"
 select grlinf
 into   d_cts14m00.horvst
 from datkgeral
 where  grlchv = 'HORVSTCT24H'

 if g_documento.c24astcod = "V10" then
    let d_cts14m00.tipo = "SEGURADO"
    if g_documento.ramcod  is null or g_documento.ramcod  = " " then
       let g_documento.ramcod = 531 ## Problemas com V10 - Ramos estava nulo
    end if
    let w_cts14m00.ramcod = g_documento.ramcod
 else
    let d_cts14m00.tipo = "TERCEIRO"
    let w_cts14m00.ramcod = 553
    if g_documento.ramcod = 31 then   # vem da tela cta00m01
       let w_cts14m00.ramcod = 53
    end if
 end if

 let l_grlchv = null
 let l_grlinf = null

 # -> MONTA A CHAVE DE PESQUISA NA DATKGERAL
 let l_grlchv = cts40g23_monta_chv_pesq(g_issk.funmat, g_issk.maqsgl)

 # -> BUSCA grlinf DA DATKGERAL
 let l_grlinf = cts40g23_busca_chv(l_grlchv)

 if l_grlinf is not null then
    # -> DESMONTA A CHAVE DE INSERCAO
    call cts40g23_dmnta_chv_insercao(l_grlinf)
         returning l_succod,
                   l_ramcod,
                   l_aplnumdig,
                   l_itmnumdig
 end if

 ## PSI 206.938 Aviso Demais Naturezas
 let l_semdoc = "N"

 if g_documento.succod     is null and
    g_documento.ramcod     is null and
    g_documento.aplnumdig  is null and
    g_documento.itmnumdig  is null and
    g_documento.edsnumref  is null and
    g_documento.prporg     is null and
    g_documento.prpnumdig  is null then  ## and  g_documento.vstnumdig  is null then
    let l_semdoc = "S"
 end if

   call ssact000 (g_documento.succod, ## 1
                  g_documento.aplnumdig, ## 11234
                  g_documento.itmnumdig, ## 19
                  g_documento.edsnumref, ## 0
                  g_documento.prporg, ## 0
                  g_documento.prpnumdig, ## 0
                  "", # g_documento.vstnumdig ## 02
                  "", # cobertura provisoria  ## 045656
                  l_semdoc, ## N
                  g_documento.c24astcod) ## 531
                  returning m_sinevtnum, m_aviso, m_ordem, m_regular

 # -> VERIFICA O TIPO DE ATENDIMENTO: COM OU SEM DOCUMENTO
 if g_documento.succod    is not null and
    g_documento.ramcod    is not null and
    g_documento.aplnumdig is not null and
    g_documento.itmnumdig is not null then

    # ATENDIMENTO C/DOCUMENTO

    if g_documento.succod    <> l_succod    or
       g_documento.ramcod    <> l_ramcod    or
       g_documento.aplnumdig <> l_aplnumdig or
       g_documento.itmnumdig <> l_itmnumdig then

       # -> ENVIAR E-MAIL INFORMANDO A DIFERENCA

        call cts40g23_envia_email("CTS14M00 - DIFERENCA ENTRE DATKGERAL E DOCUMENTO",
                                  l_aplnumdig,
                                  l_succod,
                                  l_ramcod,
                                  l_itmnumdig,
                                  g_documento.aplnumdig,
                                  g_documento.succod,
                                  g_documento.ramcod,
                                  g_documento.itmnumdig,
                                  g_c24paxnum,
                                  g_issk.funmat,
                                  g_issk.funnom,
                                  g_documento.c24astcod)

       ###let g_documento.succod    = l_succod
       ###let g_documento.ramcod    = l_ramcod
       ###let g_documento.aplnumdig = l_aplnumdig
       ###let g_documento.itmnumdig = l_itmnumdig
   end if
 else
    # ATENDIMENTO SEM DOCUMENTO

    if l_grlinf is not null then # TEM DOCUMENTO NA DATKGERAL

       # -> ENVIAR E-MAIL INFORMANDO O ERRO

       call cts40g23_envia_email("CTS14M00 - DATKGERAL C/DOCUMENTO, GLOBAIS NULAS",
                                 l_aplnumdig,
                                 l_succod,
                                 l_ramcod,
                                 l_itmnumdig,
                                 g_documento.aplnumdig,
                                 g_documento.succod,
                                 g_documento.ramcod,
                                 g_documento.itmnumdig,
                                 g_c24paxnum,
                                 g_issk.funmat,
                                 g_issk.funnom,
                                 g_documento.c24astcod)


       ###let g_documento.succod    = l_succod
       ###let g_documento.ramcod    = l_ramcod
       ###let g_documento.aplnumdig = l_aplnumdig
       ###let g_documento.itmnumdig = l_itmnumdig

    end if
 end if

 let w_cts14m00.ligcvntip = g_documento.ligcvntip

 select cpodes
   into d_cts14m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = w_cts14m00.ligcvntip

 if g_documento.succod    is not null  and
    g_documento.ramcod    is not null  and
    g_documento.aplnumdig is not null  then
    let d_cts14m00.doctxt = "Apolice.: ", g_documento.succod    using "&&", #"&&", projeto succod
                                     " ", g_documento.ramcod    using "##&&",
                                     " ", g_documento.aplnumdig using "<<<<<<<& &"

#--------------------------------------------------------------------
# Para segurado, exibir dados da apolice
#--------------------------------------------------------------------

    if g_documento.c24astcod = "V10"  then
       call cts05g00 (g_documento.succod   ,
                      g_documento.ramcod   ,
                      g_documento.aplnumdig,
                      g_documento.itmnumdig)
            returning d_cts14m00.segnom   ,
                      d_cts14m00.corsus   ,
                      d_cts14m00.cornom   ,
                      d_cts14m00.cvnnom   ,
                      ws.vclcoddig        ,
                      d_cts14m00.vcldes   ,
                      d_cts14m00.vclanomdl,
                      d_cts14m00.vcllicnum,
                      ws.vclchsinc        ,
                      d_cts14m00.vclchsfnl,
                      ws.vclcordes
    end if
 end if

 let d_cts14m00.chassi =  ws.vclchsinc clipped, d_cts14m00.vclchsfnl clipped

 if g_documento.prporg    is not null  and
    g_documento.prpnumdig is not null  then


    call figrc072_setTratarIsolamento()        --> 223689

    call cts05g04 (g_documento.prporg   ,
                   g_documento.prpnumdig)
         returning d_cts14m00.segnom   ,
                   d_cts14m00.corsus   ,
                   d_cts14m00.cornom   ,
                   d_cts14m00.cvnnom   ,
                   ws.vclcoddig        ,
                   d_cts14m00.vcldes   ,
                   d_cts14m00.vclanomdl,
                   d_cts14m00.vcllicnum,
                   ws.vclcordes

     if g_isoAuto.sqlCodErr <> 0 then --> 223689
        error "Função cts05g04 indisponivel no momento ! Avise a Informatica !" sleep 2
        close window cts14m00
        return
     end if    --> 223689


    let d_cts14m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                     " ", g_documento.prpnumdig using "<<<<<<<& &"
 end if

 let d_cts14m00.vstsolnom   = g_documento.solnom
 #initialize d_cts14m00.sinvstrgi to null   # ruiz
 ## display by name d_cts14m00.*  ## devera ser comentado qdo entrar o psi 191965


 display by name d_cts14m00.vistoria         ## retirado comentario psi 191965
 display by name d_cts14m00.tipo             ## retirado comentario psi 191965
 display by name d_cts14m00.segnom           ## retirado comentario psi 191965
 display by name d_cts14m00.doctxt           ## retirado comentario psi 191965
 display by name d_cts14m00.cornom           ## retirado comentario psi 191965
 display by name d_cts14m00.corsus           ## retirado comentario psi 191965
 display by name d_cts14m00.vcldes           ## retirado comentario psi 191965
 display by name d_cts14m00.vclanomdl        ## retirado comentario psi 191965
 display by name d_cts14m00.vcllicnum        ## retirado comentario psi 191965
 display by name d_cts14m00.chassi           ## retirado comentario psi 191965
 display by name d_cts14m00.vstretflg        ## retirado comentario psi 191965
 display by name d_cts14m00.vstretnum        ## retirado comentario psi 191965
 display by name d_cts14m00.vstretano        ## retirado comentario psi 191965
 display by name d_cts14m00.sindat           ## retirado comentario psi 191965
 display by name d_cts14m00.sinavs           ## retirado comentario psi 191965
 display by name d_cts14m00.avisocom         ## retirado comentario psi 191965
 display by name d_cts14m00.orcvlr           ## retirado comentario psi 191965
 display by name d_cts14m00.nomrazsoc        ## retirado comentario psi 191965
 display by name d_cts14m00.ofnnumdig        ## retirado comentario psi 191965
 display by name d_cts14m00.endlgd           ## retirado comentario psi 191965
 display by name d_cts14m00.endbrr           ## retirado comentario psi 191965
 display by name d_cts14m00.endcid           ## retirado comentario psi 191965
 display by name d_cts14m00.endufd           ## retirado comentario psi 191965
 display by name d_cts14m00.dddcodofi        ## retirado comentario psi 191965
 display by name d_cts14m00.telnumofi        ## retirado comentario psi 191965
 display by name d_cts14m00.vstdat           ## retirado comentario psi 191965
 display by name d_cts14m00.sinvstorgnum     ## retirado comentario psi 191965
 display by name d_cts14m00.sinvstorgano     ## retirado comentario psi 191965
 display by name d_cts14m00.dddcodctt        ## retirado comentario psi 191965
 display by name d_cts14m00.telnumctt        ## retirado comentario psi 191965

 display by name d_cts14m00.vstsolnom attribute (reverse)
 display by name d_cts14m00.cvnnom    attribute (reverse)

 #LH - inicio - Faz voltar para a tela de assuntos.
 if (m_sinevtnum <> -1 and m_aviso <> -1 and m_ordem <> -1) then
    call inclui_cts14m00() returning ws.grvflg

    if ws.grvflg = true  then
       if d_cts14m00.vstretflg = "S" then
          let g_documento.acao = "INC"
       else
          let g_documento.acao = "AAA" # obriga a digitacao do historico(cts14m10)
       end if

       call cts14m10 (w_cts14m00.sinvstnum, w_cts14m00.ano4, g_issk.funmat,
                      w_cts14m00.data, w_cts14m00.hora)
    end if
 end if
 #LH - fim

 close window cts14m00

end function  ###  cts14m00


#-------------------------------------------------------------------------------
 function inclui_cts14m00()
#-------------------------------------------------------------------------------
   ### PSI216445 - Inicio ###
   define l_segurado record
      segnumdig like gsakendmai.segnumdig, # Numero e digito do segurado
      email_segurado like gsakendmai.maides # Email do segurado
   end record

   define l_oficina record
      ofnnumdig like sgokofi.ofnnumdig, # Numero e digito da oficina
      nomrazsoc like gkpkpos.nomrazsoc, # Razao Social
      nomgrr like gkpkpos.nomgrr, # Nome de Guerra (ou Nome Fantasia)
      endlgd like gkpkpos.endlgd, # Endereco
      endbrr like gkpkpos.endbrr, # Bairro
      endcep like gkpkpos.endcep, # Cep
      endcepcmp like gkpkpos.endcepcmp, # Complemento do Cep
      dddcod like gkpkpos.dddcod, # DDD da Regiao
      telnum1 like gkpkpos.telnum1, # Telefone
      endufd like gkpkpos.endufd, # Estado
      endcid like gkpkpos.endcid, # Cidade
      ofnblqtip like sgokofi.ofnblqtip, # Tipo de bloqueio da Oficina
      ofnbrrcod like sgokofi.ofnbrrcod, # Codigo do Bairro
      succod like sgokofi.succod, # Codigo da Sucursal
      ofnrgicod like sgokofi.ofnrgicod, # Codigo da Regiao da Oficina
      regiao like gkpkbairro.ofcbrrdes, # Bairro
      situacao char (36) # Situacao da Oficina
   end record

   define l_email record
      sistorig_ char (20), # Sistema de origem do e-mail
      sender_ like gsakendmai.maides, # Quem esta enviando (e-mail)
      from_ like gsakendmai.maides, # Quem esta enviando (identificacao do rementente)
      to_ like gsakendmai.maides, # Para quem esta sendo enviado o e-mail (e-mail)
      replayto_ like gsakendmai.maides, # Para quem sera retornada uma mensagem de resposta
      assunto_ char (100), # Assunto do e-mail
      mensagem_ char (2000), # Mensagem do e-mail
      sistema_ char (20) # Sistem de origem do e-mail
   end record

   define l_informacoes_oficina char (1) # Guarda a informacao de que as informacoes
                                         # da oficina foram encontradas (S) ou nao (N)

   define l_resposta_envio char (100) # Pode ser uma mensagem de sucesso ou nao.

   define l_aux char (50)
   ### PSI216445 - Fim ###

   define ws              record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             varchar(80)                ,
        cont            integer                    ,
        comando         char(500)                  ,
        grlchv          like igbkgeral.grlchv      ,
        grlinf          like igbkgeral.grlinf      ,
        subcod          like datmvstsin.subcod     ,
        seqdig          like gkpkpos.pstcoddig     , ## CT Alberto
        msglin1      char(40)                      ,
        msglin2      char(40)                      ,
        msglin3      char(40)                      ,
        msglin4      char(40)
 end record

 ##  CT Alberto V10

 define l_erro_servico smallint

 define l_data      date,
        l_hora2     datetime hour to minute
 define l_hora_unix datetime hour to second

 define lr_figrc006     record
        coderro         integer
       ,menserro        char(30)
       ,msgid           char(24)
       ,correlid        char(24)
        end record

 define l_xml       char(32766)
       ,l_online    smallint
       ,l_msg_erro  char(100)

 let l_erro_servico = 0

 ##  CT Alberto V11

 initialize lr_figrc006.* to null

 let l_msg_erro= null
 let l_xml     = null
 let l_online  = 0

 initialize  ws.*  to  null
 initialize  l_cmd  to  null
 initialize l_mens.* to  null

 while true
   initialize ws.*  to null

   call input_cts14m00()

   if  int_flag  then
       let int_flag = false
       initialize d_cts14m00.*  to null
       initialize w_cts14m00.*  to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Converte telefone numerico para string, alinhando a esquerda
 #------------------------------------------------------------------------------
   let w_cts14m00.telnumofi = d_cts14m00.telnumofi using "<<<<<<<<<"   # Anatel

   if  w_cts14m00.ramcod = 53      or
       w_cts14m00.ramcod = 553   then
       let ws.subcod = 02
   else
       let ws.subcod = 00
   end if

  #if  d_cts14m00.vstretflg = "N"  then
  #    if  today > "31/12/1998"  and
  #        today < "16/01/1999"  then
  #        if  d_cts14m00.sindat < "01/01/1999"  then
  #            let w_cts14m00.ano2 = 98
  #            let w_cts14m00.ano4 = "1998"
  #        end if
  #    end if
  #end if    # ruiz

  #if  w_cts14m00.ano4 <= "1997"  then
  #    if  d_cts14m00.sinvstrgi = "S" then
  #        let ws.grlchv = w_cts14m00.ano2,"VSTSINGSP"    ### VST DA GRANDE SP
  #    else
  #        let ws.grlchv = w_cts14m00.ano2,"VSTSININT"    ### VST DO INTERIOR
  #    end if
  #else
       let ws.grlchv = w_cts14m00.ano2,"SINISTRO"         ### NUM. UNIFICADA SIN
  #end if    # ruiz


 #------------------------------------------------------------------------------
 # Busca numeracao ligacao
 #------------------------------------------------------------------------------
   begin work

  #call cts10g03_numeracao( 1, "" )

   call cts10g03_numeracao( 2, "5" )# chama dessa maneira para pegar a
                                    # numeracao do jeito antigo(por faixa).
                                    # O depto sinistro ficou de alterar
                                    # seu sistema para o novo criterio de
                                    # numeracao(sequencial). ruiz 11/00.
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql  ,
                  ws.msg

   ---> Decreto - 6523
   #let g_lignum_dcr = ws.lignum

   if  ws.codigosql = 0  then
       let w_cts14m00.sinvstnum = ws.atdsrvnum
       commit work
   else
       let ws.msg = "CTS14M00 - ",ws.msg
       call ctx13g00( ws.codigosql, "DATKGERAL", ws.msg )
       rollback work
       let l_erro_servico = 1  ## Erro na Numeração
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   let w_cts14m00.ano4 =  '20', ws.atdsrvano using "&&"

 #------------------------------------------------------------------------------
 # Busca numeracao vistoria sinistro
 #------------------------------------------------------------------------------
   begin work

 {  # passou a buscar a numeracao chamando cts10g03(vide acima)

   declare c_cts14m00_001 cursor with hold for
           select grlinf[01,08]
             from datkgeral
                  where grlchv = "SINISTRO"
                  for update

   let ws.cont = 0

   while true
     let ws.cont = ws.cont + 1

     open  c_cts14m00_001
     fetch c_cts14m00_001 into w_cts14m00.vistoria

       let ws.codigosql = sqlca.sqlcode

       if  ws.codigosql <> 0  then
           if  ws.codigosql = -243  or
               ws.codigosql = -245  or
               ws.codigosql = -246  then
               if  ws.cont < 11  then
                   sleep 1
                   continue while
               else
                   let ws.msg = " Numero da vst sinistro travado!",
                                " AVISE A INFORMATICA! "
               end if
           else
               let ws.msg = " Erro (", ws.codigosql, ") na selecao do",
                            " numero da vst sinistro! AVISE A INFORMATICA!"
           end if
       end if

       exit while
   end while

   if  w_cts14m00.vistoria is null  then
      #if  w_cts14m00.ano4 <= "1997"  then
      #    if  d_cts14m00.sinvstrgi = "S"  then
      #        let w_cts14m00.vistoria = "809999"
      #        let ws.grlinf           =  809999
      #    else
      #        let w_cts14m00.vistoria = "799999"
      #        let ws.grlinf           =  799999
      #    end if
      #else
           let w_cts14m00.vistoria = "799999"
           let ws.grlinf           =  799999
      #end if   # ruiz
      call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2

       insert into datkgeral ( grlinf,
                               grlchv,
                               atldat,
                               atlhor,
                               atlemp,
                               atlmat )

                      values  (ws.grlinf,
                               "SINISTRO",
                               l_data    ,
                               l_hora2   ,
                               1         ,
                               61566)

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na inclusao da",
                 " numeracao da vst sinistro. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt
           let ws.retorno = false
           exit while
       end if
   end if

   let w_cts14m00.sinvstnum = w_cts14m00.vistoria[1,6]
   let w_cts14m00.sinvstnum = w_cts14m00.sinvstnum + 1

  #if  w_cts14m00.ano4 <= "1997"  then
  #    if  d_cts14m00.sinvstrgi = "S"  then
  #        if  w_cts14m00.sinvstnum > 999998  then
  #            error " Faixa de sinistro GRANDE S.PAULO esgotada.",
  #                  " AVISE A INFORMATICA!"
  #            rollback work
  #            let ws.retorno = false
  #            exit while
  #        end if
  #    else
  #        if  w_cts14m00.sinvstnum > 809999  then
  #            error " Faixa de sinistro INTERIOR esgotada.",
  #                  " AVISE A INFORMATICA!"
  #            rollback work
  #            let ws.retorno = false
  #            exit while
  #        end if
  #    end if
  #else
       if  w_cts14m00.sinvstnum > 999998  then
           error " Faixa de vistoria de sinistro esgotada.",
                 " AVISE A INFORMATICA!"
           rollback work
           let ws.retorno = false
           exit while
       end if
  #end if     #  ruiz

   call cts40g03_data_hora_banco(2)
        returning l_data, l_hora2
   update datkgeral
      set (grlinf[1,6],grlinf[7,8],atldat,atlhor) =
          (w_cts14m00.sinvstnum, "00", l_data, l_hora2)
          where grlchv = "SINISTRO"

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao do",
             " numero da vst sinistro. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.prompt
       let ws.retorno = false
       exit while
   end if
 }  #  fim

 #------------------------------------------------------------------------------
 # Grava dados da ligacao
 #------------------------------------------------------------------------------

   call cts10g00_ligacao ( ws.lignum               ,
                           w_cts14m00.data         ,
                           w_cts14m00.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           g_issk.funmat           ,
                           g_documento.ligcvntip   ,
                           g_c24paxnum             ,
                           "",""                   ,
                           w_cts14m00.sinvstnum    ,
                           w_cts14m00.ano4         ,
                           "",""                   ,
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
                           "", "", "", ""           )
        returning ws.tabname,
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       let l_erro_servico = 2
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work

       ## CT Alberto
       if g_documento.c24astcod = "V10" then
          let ws.msglin1 = "1-LIGACAO  : ",  ws.lignum
          let ws.msglin2 = "1-APOL/PRP : ",  g_documento.aplnumdig,"/",g_documento.prpnumdig
          let ws.msglin3 = "1-USR/DATA : ",  g_issk.funmat,"/",w_cts14m00.data,"-",w_cts14m00.hora
          let ws.msglin4 = "1-VISTORIA : ",  w_cts14m00.sinvstnum,"-",w_cts14m00.ano2, " Erro:", l_erro_servico
          let l_msg_erro = " Erro : ",ws.codigosql, " na gravacao da tabela - ",ws.tabname
          call cts14m00_envia_email(ws.msglin1,
                                    ws.msglin2,
                                    ws.msglin3,
                                    ws.msglin4,
                                    l_msg_erro)
       end if
       ## CT Alberto

       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   # Psi 230669
   if (g_documento.atdnum is not null and
       g_documento.atdnum <> 0) then

       call ctd25g00_insere_atendimento(g_documento.atdnum,ws.lignum)
       returning ws.codigosql,ws.tabname

       if  ws.codigosql  <>  0  then
           let l_erro_servico = 2
           error ws.tabname sleep 3
           rollback work


           if g_documento.c24astcod = "V10" then
              let ws.msglin1 = "1-LIGACAO  : ",  ws.lignum , "1-ATDNUM  : -  " ,g_documento.atdnum
              let ws.msglin2 = "1-APOL/PRP : ",  g_documento.aplnumdig,"/",g_documento.prpnumdig
              let ws.msglin3 = "1-USR/DATA : ",  g_issk.funmat,"/",w_cts14m00.data,"-",w_cts14m00.hora
              let ws.msglin4 = "1-VISTORIA : ",  w_cts14m00.sinvstnum,"-",w_cts14m00.ano2, " Erro:", l_erro_servico

              let l_msg_erro = " Erro : ",ws.codigosql, " na gravacao da tabela datratdlig- ",ws.tabname
              call cts14m00_envia_email(ws.msglin1,
                                        ws.msglin2,
                                        ws.msglin3,
                                        ws.msglin4,
                                        l_msg_erro)
           end if


           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
   end if

 #------------------------------------------------------------------------------
 # Grava dados da oficina (se necessario)
 #------------------------------------------------------------------------------
   if  d_cts14m00.ofnnumdig is null  then
     #--------------------------------------------------------------------------
     # Busca ultimo codigo de oficina
     #--------------------------------------------------------------------------
       call osgoa047_cria_seq()
            returning ws.seqdig

       display "ws.seqdig = ",ws.seqdig
       let d_cts14m00.ofnnumdig = ws.seqdig
       display by name d_cts14m00.ofnnumdig

     #--------------------------------------------------------------------------
     # Grava dados do posto
     #--------------------------------------------------------------------------
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2

       whenever error continue
       let l_sql = "insert into ", m_hostname clipped ,"GKPKPOS ",
                   "       ( pstcoddig,",
                   "         nomrazsoc,",
                   "         endlgd   ,",
                   "         endbrr   ,",
                   "         endcid   ,",
                   "         endufd   ,",
                   "         dddcod   ,",
                   "         telnum1  ,",
                   "         ofnflg   ,",
                   "         funmat   ,",
                   "         atldat   )",
                   "values ( ?,?,?,?,?,?,?,?,?,?,?)"
       prepare pcts14m00010 from l_sql
       execute pcts14m00010 using  ws.seqdig           ,
                                   d_cts14m00.nomrazsoc,
                                   d_cts14m00.endlgd   ,
                                   d_cts14m00.endbrr   ,
                                   d_cts14m00.endcid   ,
                                   d_cts14m00.endufd   ,
                                   d_cts14m00.dddcodofi,
                                   w_cts14m00.telnumofi,
                                   "X"                 ,
                                   g_issk.funmat       ,
                                   l_data
       whenever error continue

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na inclusao do",
                 " posto. AVISE A INFORMATICA!"
           let l_erro_servico = 4
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if

     #--------------------------------------------------------------------------
     # Grava dados da oficina
     #--------------------------------------------------------------------------
       whenever error continue
       let l_sql = "insert into ", m_hostname1 clipped, "SGOKOFI (",
                   " ofnnumdig,",
                   " ofnstt   ,",
                   " funmat   ,",
                   " atldat   ,",
                   " trzlvasrvflg ) ",
                   " values ( ?    ,",
                   " 'P'          , ",
                   " ?,?,'N' )"
      prepare pcts14m00011 from l_sql
      execute pcts14m00011 using ws.seqdig,
                                 g_issk.funmat,
                                 l_data
      whenever error stop
       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na inclusao da",
                 " oficina. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if


     #--------------------------------------------------------------------------
     # Atualiza ultimo codigo de oficina
     #--------------------------------------------------------------------------

         let l_sql = "update porto@",m_hostname,":IGBKGERAL          ",
                    "   set (grlinf, atlult) =                      ",
                    "       (",w_cts14m00.pstcoddig,",",w_cts14m00.data,") ",
                    "       where mducod = 'gkp'                    ",
                    "         and grlchv = 'posto'                  "
         prepare pcts14m00013 from l_sql
         execute pcts14m00013

       if  sqlca.sqlcode  <>  0  then
           error " Erro (", sqlca.sqlcode, ") na atualizacao do",
                 " codigo da oficina. AVISE A INFORMATICA!"
           let l_erro_servico = 5
           rollback work
           prompt "" for char ws.prompt_key
           let ws.retorno = false
           exit while
       end if
   else
       ### Solicitado por Severo no dia 01/08/2002
       #if  w_cts14m00.ofnstt  =  "I"   then
       #    update SGOKOFI
       #       set ofnstt = "P"
       #           where sgokofi.ofnnumdig = d_cts14m00.ofnnumdig
       #
       #    if  sqlca.sqlcode  <>  0  then
       #        error " Erro (", sqlca.sqlcode, ") na alteracao da",
       #              " oficina. AVISE A INFORMATICA!"
       #        rollback work
       #        prompt "" for char ws.prompt
       #        let ws.retorno = false
       #        exit while
       #    end if
       #end if
   end if

 let d_cts14m00.vclchsinc = d_cts14m00.chassi[1,12]

 #------------------------------------------------------------------------------
 # Grava vistoria de sinistro
 #------------------------------------------------------------------------------
   insert into DATMVSTSIN ( sinvstnum               ,
                            sinvstano               ,
                            vstsolnom               ,
                            vstsoltip               ,
                            vstsoltipcod            ,
                            segnom                  ,
                            aplnumdig               ,
                            itmnumdig               ,
                            succod                  ,
                            ramcod                  ,
                            subcod                  ,
                            dddcod                  ,
                            teltxt                  ,
                            cornom                  ,
                            corsus                  ,
                            vcldes                  ,
                            vclanomdl               ,
                            vcllicnum               ,
                            vclchsfnl               ,
                          # sinvstrgi               ,
                            sindat                  ,
                            sinavs                  ,
                            orcvlr                  ,
                            ofnnumdig               ,
                            vstdat                  ,
                            vstretdat               ,
                            vstretflg               ,
                            funmat                  ,
                            atddat                  ,
                            atdhor                  ,
                            sinvstorgnum            ,
                            sinvstorgano            ,
                            sinvstsolsit            ,
                            prporg                  ,
                            prpnumdig
                           ,vclchsinc   ## retirado comentario psi191965
                            )
                   values ( w_cts14m00.sinvstnum     ,
                            w_cts14m00.ano4          ,
                            g_documento.solnom       ,
                            g_documento.soltip       ,
                            g_documento.c24soltipcod ,
                            d_cts14m00.segnom        ,
                            g_documento.aplnumdig    ,
                            g_documento.itmnumdig    ,
                            g_documento.succod       ,
                            w_cts14m00.ramcod        ,
                            ws.subcod                ,
                            d_cts14m00.dddcodctt     ,
                            d_cts14m00.telnumctt     ,
                            d_cts14m00.cornom        ,
                            d_cts14m00.corsus        ,
                            d_cts14m00.vcldes        ,
                            d_cts14m00.vclanomdl     ,
                            d_cts14m00.vcllicnum     ,
                            d_cts14m00.vclchsfnl     ,
                          # d_cts14m00.sinvstrgi     ,
                            d_cts14m00.sindat        ,
                            d_cts14m00.sinavs        ,
                            d_cts14m00.orcvlr        ,
                            d_cts14m00.ofnnumdig     ,
                            d_cts14m00.vstdat        ,
                            d_cts14m00.vstdat        ,
                            d_cts14m00.vstretflg     ,
                            g_issk.funmat            ,
                            w_cts14m00.data          ,
                            w_cts14m00.hora          ,
                            d_cts14m00.sinvstorgnum  ,
                            d_cts14m00.sinvstorgano  ,
                            "N"                      ,
                            g_documento.prporg       ,
                            g_documento.prpnumdig    ,
                            d_cts14m00.vclchsinc ## retirado comentario psi191965
                            )

   if  sqlca.sqlcode  <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " vistoria de sinistro. AVISE A INFORMATICA!"
       let l_erro_servico = 6
       rollback work
       prompt "" for char ws.prompt_key
       let ws.retorno = false
       exit while
   end if

   ## CT Alberto
   if l_erro_servico > 0 then
    if g_documento.c24astcod = "V10" then
       let ws.msglin1 = "2-LIGACAO  : ",  ws.lignum
       let ws.msglin2 = "2-APOL/PRP : ",  g_documento.aplnumdig,"/",g_documento.prpnumdig
       let ws.msglin3 = "2-USR/DATA : ",  g_issk.funmat,"/",w_cts14m00.data,"-",w_cts14m00.hora
       let ws.msglin4 = "2-VISTORIA : ",  w_cts14m00.sinvstnum,"-",w_cts14m00.ano2, " Erro:", l_erro_servico
       let l_msg_erro = " Erro : ",ws.codigosql, " na gravacao da tabela - ",ws.tabname
       call cts14m00_envia_email(ws.msglin1,
                                 ws.msglin2,
                                 ws.msglin3,
                                 ws.msglin4,
                                 l_msg_erro)
       let l_erro_servico = 0
    end if
   end if
   ## CT Alberto

   commit work

 #------------------------------------------------------------------------------
 # Exibe o numero do servico
 #------------------------------------------------------------------------------
   let d_cts14m00.vistoria = F_FUNDIGIT_INTTOSTR(w_cts14m00.sinvstnum, 6), "-",
                             F_FUNDIGIT_INTTOSTR(w_cts14m00.ano2     , 2)

   if  d_cts14m00.sinvstorgnum is null then
       display d_cts14m00.vistoria to vistoria attribute (reverse)
       error  " Verifique o numero da vistoria sinistro e tecle ENTER!"
   else
       display d_cts14m00.vistoria to vistoria
       error " Verifique numero da vistoria original e tecle ENTER!"
   end if

   prompt "" for char ws.prompt_key

   ### PSI216445 - Inicio ###
   # Se os codigos de assunto forem V10 ou V11, oferece a opcao de enviar
   # por e-mail as informacoes da oficina escolhida.
   if (g_documento.c24astcod = "V10" or g_documento.c24astcod = "V11") then
      initialize l_segurado.* to null
      initialize l_oficina.* to null

      # Se for segurado, busca o e-mail do mesmo.
      if (g_documento.c24soltipcod = 1) then
         whenever error continue

         select segnumdig
         into l_segurado.segnumdig
         from abbmdoc
         where abbmdoc.succod = g_documento.succod and
               abbmdoc.aplnumdig = g_documento.aplnumdig and
               abbmdoc.itmnumdig = g_documento.itmnumdig and
               abbmdoc.dctnumseq = g_funapol.dctnumseq

         if sqlca.sqlcode <> 0 then
            error "Numero e digito do segurado nao encontrados - Erro: ", sqlca.sqlcode
            sleep 3
         else
            select maides
            into l_segurado.email_segurado
            from gsakendmai
            where segnumdig = l_segurado.segnumdig

            if sqlca.sqlcode <> 0 then
               error "E-mail do segurado nao encontrado - Erro: ", sqlca.sqlcode
               sleep 3
            end if
         end if

         whenever error stop
      end if # Fim da busca do e-mail do segurado

      # Busca as informacoes da oficina escolhida.
      whenever error continue

      select a.nomrazsoc, # Razao Social
             a.nomgrr, # Nome de Guerra (ou Nome Fantasia)
             a.endlgd, # Endereco
             a.endbrr, # Bairro
             a.endcep, # Cep
             a.endcepcmp, # Complemento do Cep
             a.dddcod, # DDD da Regiao
             a.telnum1, # Telefone
             a.endufd, # Estado
             a.endcid, # Cidade
             b.ofnblqtip, # Situacao da Oficina
             b.ofnbrrcod, # Codigo do bairro
             b.succod, # Codigo da sucursal
             b.ofnrgicod # Codigo da regiao
      into l_oficina.nomrazsoc, l_oficina.nomgrr, l_oficina.endlgd,
           l_oficina.endbrr, l_oficina.endcep, l_oficina.endcepcmp,
           l_oficina.dddcod, l_oficina.telnum1, l_oficina.endufd,
           l_oficina.endcid, l_oficina.ofnblqtip, l_oficina.ofnbrrcod,
           l_oficina.succod, l_oficina.ofnrgicod
      from gkpkpos a, sgokofi b
      where pstcoddig = ofnnumdig and ofnnumdig = d_cts14m00.ofnnumdig

      if (sqlca.sqlcode <> 0) then
         error "Informacoes da oficina nao encontradas!"
         sleep 3
         let l_informacoes_oficina = "N"
      else
         let l_informacoes_oficina = "S"

         if l_oficina.ofnblqtip = 1 then
            let l_oficina.situacao = "*** OFICINA LOTADA NESTE MOMENTO ***"
         end if

         if l_oficina.ofnblqtip is null then
            let l_oficina.situacao = "ATIVA"
         end if

         select ofcbrrdes
         into l_oficina.regiao
         from gkpkbairro
         where ofnbrrcod = l_oficina.ofnbrrcod and ofnrgicod = l_oficina.ofnrgicod
               and succod = l_oficina.succod

         if (sqlca.sqlcode <> 0) then
            let l_oficina.regiao = ""
         end if
      end if

      whenever error stop

      if (l_informacoes_oficina = "S") then
         initialize l_email.* to null

         let l_aux = "Oficina: ", l_oficina.nomgrr clipped
         let l_segurado.email_segurado = fsgoa007e_confirmacao_email ("        Envio das Informações da Oficina Escolhida",
             l_aux, l_segurado.email_segurado)

         let l_email.sistorig_ = "cts14m00"
         let l_email.sender_ = "info.oficinas@portoseguro.com.br"
         let l_email.from_  = "info.oficinas@portoseguro.com.br"
         let l_email.to_ = l_segurado.email_segurado clipped
         let l_email.replayto_ = l_segurado.email_segurado clipped
         let l_email.assunto_ = "Informações de Endereço da oficina"
         let l_email.mensagem_ = "Dados da oficina escolhida:\n\n"

         if (l_oficina.nomgrr is not null) then
            let l_email.mensagem_ = l_email.mensagem_ clipped, "Oficina: ", l_oficina.nomgrr clipped, "\n"
         else
            let l_email.mensagem_ = l_email.mensagem_ clipped, "Oficina: ", l_oficina.nomrazsoc clipped, "\n"
         end if

         let l_email.mensagem_ = l_email.mensagem_ clipped, "Endereco: ", l_oficina.endlgd clipped, "\n"
         let l_email.mensagem_ = l_email.mensagem_ clipped, "Bairro: ",  l_oficina.endbrr clipped, "\n"
         let l_email.mensagem_ = l_email.mensagem_ clipped, "Regiao: ", l_oficina.regiao clipped, "\n"
         let l_email.mensagem_ = l_email.mensagem_ clipped, "Cep: ", l_oficina.endcep clipped, "-", l_oficina.endcepcmp clipped, "\n"
         let l_email.mensagem_ = l_email.mensagem_ clipped, l_oficina.endcid clipped, " - ", l_oficina.endufd clipped, "\n"
         let l_email.mensagem_ = l_email.mensagem_ clipped, "Telefone: (", l_oficina.dddcod clipped, ") ", l_oficina.telnum1 clipped, "\n"
         let l_email.mensagem_ = l_email.mensagem_ clipped, "Situação: ", l_oficina.situacao clipped, "\n\n"
         let l_email.mensagem_ = l_email.mensagem_ clipped, "Atenciosamente,\n\n"
         let l_email.mensagem_ = l_email.mensagem_ clipped, "Porto Seguro"
         let l_email.sistema_ = "cts14m00"

         # Envia e-mail com as informacoes para o solicitante.
         if (l_segurado.email_segurado is not null) then
            let l_resposta_envio = fsgoa007e_enviar_email_mq (l_email.sistorig_ clipped, l_email.sender_ clipped,
                                   l_email.from_ clipped, l_email.to_ clipped,
                                   l_email.replayto_ clipped, l_email.assunto_ clipped,
                                   l_email.mensagem_ clipped, l_email.sistema_ clipped)
            error l_resposta_envio
            sleep 3
         else
            error "Envio cancelado!"
            sleep 3
         end if
      end if
   end if
   ### PSI216445 - Fim ###

   error " Marcacao efetuada com sucesso!"
   let ws.retorno = true

   #Chama funcao para montar o XML
   ##PSI 206.938 Aviso Demais Naturezas if d_cts14m00.vstretflg = "N" and
   ##PSI 206.938 Aviso Demais Naturezas    g_documento.c24astcod = "V10" then
   if (g_documento.c24astcod = "V10" or g_documento.c24astcod = "V11") then

      if (m_regular <> "N") then
         let l_xml = cts14m00_monta_xml (w_cts14m00.sinvstnum, w_cts14m00.ano4,
                                         "P", m_sinevtnum, m_aviso, ## PSI 206.938
                                         m_ordem, m_trcvclcod)

         #display l_xml clipped

         #chama funcao de envio para mq
         let l_msg_erro = null
         let l_online   = online()
         ## Inclui registro informando que Central 24 Horas chamou a rotina do MQ
         let l_hora_unix = current
         let l_msg_erro = "<cts14m00 ",l_hora_unix,"> CT24H enviando a msg de Servico ", g_documento.c24astcod

         call ssata603_grava_erro (w_cts14m00.ano4, w_cts14m00.sinvstnum, 2,
                                  l_msg_erro, g_issk.funmat, 1)

         call figrc006_enviar_datagrama_mq_rq ("SIAUTOANALISE4GLD", l_xml,
                                               "CORRELID", l_online)
         returning lr_figrc006.*

         #if lr_figrc006.coderro = 0 then
         #   display "Chamou o laudo"
         #end if

         if lr_figrc006.coderro <> 0 then
            let l_msg_erro = lr_figrc006.coderro,' - ',lr_figrc006.menserro clipped
            call ssata603_grava_erro (w_cts14m00.ano4, w_cts14m00.sinvstnum, 2,
                                      l_msg_erro, g_issk.funmat, 1)
         end if
      else
         whenever error continue

         update sanmavs
         set atdsrvnum = w_cts14m00.sinvstnum
         where sinavsnum = m_aviso and sinevtnum = m_sinevtnum

         whenever error stop

         # Pensar no que vou colocar
      end if
   end if

   exit while
 end while

 return ws.retorno

end function  ###  inclui_cts14m00

#--------------------------------------------------------------------
 function input_cts14m00()
#--------------------------------------------------------------------

 define ws            record
    subcod            like ssamsin.subcod      ,
    sinvstnum         like ssamsin.sinvstnum   ,
    sinvstano         like ssamsin.sinvstano   ,
    orrdat            like ssamsin.orrdat      ,
    viginc            like abbmdoc.viginc      ,
    vigfnl            like abbmdoc.vigfnl      ,
    vstretnum         like ssamsin.sinvstnum   ,
    vstsegflg         like gkpkregi.vstsegflg  ,
    vstterflg         like gkpkregi.vstterflg  ,
    vstquaflg         like gkpkregi.vstquaflg  ,
    vstquiflg         like gkpkregi.vstquiflg  ,
    vstsexflg         like gkpkregi.vstsexflg  ,
    succod            like sgokofi.succod      ,
    ofnrgicod         like gkpkbairro.ofnrgicod,
    ofnbrrcod         like gkpkbairro.ofnbrrcod,
    ofnnumdig         like sgokofi.ofnnumdig   ,
    dddcod            like gkpkpos.dddcod      ,
    sinvstqtd         smallint                 ,
    diasem            dec (1,0)                ,
    hojdat            date                     ,
    agora             datetime hour to minute  ,
    utldat            date                     ,
    prpflg            char (01)                ,
    confirma          char (01)                ,
    conf48hs          char (01)                ,
    vstdattxt         char (40)                ,
    inclui            char (01)                ,
    fvistsuc          char (01)
 end record

 define l_data      date,
        l_hora2     datetime hour to minute

 define l_flag_acesso smallint

 initialize m_trcvclcod to null

 initialize ws.*  to null

 let ws.hojdat = w_cts14m00.data

 let ws.sinvstqtd = 0

 let l_flag_acesso = cta00m06(g_issk.dptsgl)

 if l_flag_acesso = 0 then
    display "(F1)Help             " at 19,2
 else
    display "(F1)Help  (F5)Espelho" at 19,2
 end if

 select count(*) into ws.sinvstqtd
   from datrligapol, datmligacao
  where datrligapol.succod    = g_documento.succod     and
        datrligapol.ramcod    in (31,531)              and
        datrligapol.aplnumdig = g_documento.aplnumdig  and
        datrligapol.itmnumdig = g_documento.itmnumdig  and
        datmligacao.lignum    = datrligapol.lignum     and
        datmligacao.ligdat    = ws.hojdat              and
        datmligacao.c24astcod = g_documento.c24astcod

 if ws.sinvstqtd > 0  then
    if g_documento.c24astcod = 'V10' then
       call cts08g01("A","N","","HOJE JA' FOI MARCADA VISTORIA DE","SINISTRO PARA ESTA APOLICE/ITEM!","") returning ws.confirma
    else
       call cts08g01("U","N","","HOJE JA' FOI MARCADA UMA VISTORIA","PARA ESTE SINISTRO ?","") returning ws.confirma
    end if
 end if

 let ws.hojdat = w_cts14m00.data

 initialize ws.conf48hs  to null

 input by name d_cts14m00.segnom   ,
               d_cts14m00.cornom   ,
               d_cts14m00.corsus   ,
               d_cts14m00.vcldes   ,
               d_cts14m00.vclanomdl,
               d_cts14m00.vcllicnum,
 ## comentado para psi 191965 d_cts14m00.vclchsfnl,
               d_cts14m00.chassi   , ## retirado comentario psi191965
               d_cts14m00.vstretflg,
               d_cts14m00.vstretnum,
               d_cts14m00.vstretano,
            #  d_cts14m00.sinvstrgi,
               d_cts14m00.sindat   ,
               d_cts14m00.sinavs   ,
               d_cts14m00.orcvlr   ,
               d_cts14m00.nomrazsoc,
               d_cts14m00.ofnnumdig,
               d_cts14m00.endlgd   ,
               d_cts14m00.endbrr   ,
               d_cts14m00.endcid   ,
               d_cts14m00.endufd   ,
               d_cts14m00.dddcodofi,
               d_cts14m00.telnumofi,
               d_cts14m00.vstdat   ,
               d_cts14m00.dddcodctt,
               d_cts14m00.telnumctt
       without defaults

   before field segnom
          if g_documento.c24astcod = "V10"       and       # Dados da apolice
             g_documento.aplnumdig is not null   and       # nao podem ser
             d_cts14m00.segnom     is not null   then      # alterados
             next field vstretflg
          end if

          if ((g_documento.atdsrvnum  is null       and
               g_documento.c24astcod  =  "V11")     and
              (d_cts14m00.sinvstorgnum is null  or
               d_cts14m00.sinvstorgano is null))    then

             call cts14m13 (g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig)
                  returning d_cts14m00.sinvstorgnum,
                            d_cts14m00.sinvstorgano,
                            d_cts14m00.segnom      ,
                            d_cts14m00.vcldes      ,
                            d_cts14m00.vclanomdl   ,
                            d_cts14m00.vcllicnum   ,
                            ## comentado para psi 191965 d_cts14m00.vclchsfnl   ,
                            d_cts14m00.chassi      , ## retirado comentario para psi 191965
                            d_cts14m00.sindat

             if d_cts14m00.sinvstorgnum is not null  and
                d_cts14m00.sinvstorgano is not null  then
                display by name d_cts14m00.sinvstorgnum attribute (reverse)
                display by name d_cts14m00.sinvstorgano attribute (reverse)
             end if

             if d_cts14m00.segnom  is not null    then
                display by name d_cts14m00.segnom
                display by name d_cts14m00.vcldes
                display by name d_cts14m00.vclanomdl
                display by name d_cts14m00.vcllicnum
                display by name d_cts14m00.chassi ## retirado comentario psi191965
                ## comentado para psi 191995 display by name d_cts14m00.vclchsfnl
                display by name d_cts14m00.sindat
                next field vstretflg
             end if
          end if
          display by name d_cts14m00.segnom     attribute (reverse)

   after  field segnom
          display by name d_cts14m00.segnom

          if d_cts14m00.sinvstorgnum  is not null   and
             d_cts14m00.sinvstorgano  is null       then
             error " Ano da vistoria deve ser informado !"
             next field segnom
          end if

          if g_documento.acao = "CON" then
                error " Servico sendo consultado, nao pode ser alterado!"
                call cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                  " ","FOI SOLICITADO UMA (CON)CONSULTA","")
                     returning ws.confirma
                next field segnom
          end if

          if d_cts14m00.segnom is null or
             d_cts14m00.segnom =  "  " then
             if g_documento.c24astcod = "V11"  then
                error " Nome do terceiro deve ser informado!"
             else
                error " Nome do segurado deve ser informado!"
             end if
             next field segnom
          end if

   before field cornom
          display by name d_cts14m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts14m00.cornom

   before field corsus
          display by name d_cts14m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts14m00.corsus

   before field vcldes
          display by name d_cts14m00.vcldes     attribute (reverse)

   after  field vcldes
      if m_trcvclcod is null then
         error "Voce deve selecionar um modelo" sleep 2
         error " "
         let d_cts14m00.vcldes = " "
         display by name d_cts14m00.vcldes
      end if

      call agguvcl() returning m_trcvclcod

      if m_trcvclcod is null then
         error "Voce precisa escolher um modelo" sleep 2
         next field vcldes
      else
	 call veiculo_cts18m00(m_trcvclcod)returning d_cts14m00.vcldes
	 display by name d_cts14m00.vcldes
	 next field vclanomdl
      end if

          #if fgl_lastkey() <> fgl_keyval("up")   and
          #   fgl_lastkey() <> fgl_keyval("left") then
          #   if d_cts14m00.vcldes is null or
          #      d_cts14m00.vcldes =  "  " then
          #      if g_documento.c24astcod = "V11"  then
          #         error " Descricao do veiculo do terceiro deve ser informada!"
          #      else
          #         error " Descricao do veiculo do segurado deve ser informada!"
          #      end if
          #      next field vcldes
          #   end if
          #end if

   before field vclanomdl
          display by name d_cts14m00.vclanomdl  attribute (reverse)

   after  field vclanomdl
          display by name d_cts14m00.vclanomdl

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts14m00.vclanomdl is null or
                d_cts14m00.vclanomdl =  0    then
                if g_documento.c24astcod = "V11"  then
                   error " Ano do veiculo do terceiro deve ser informado!"
                else
                   error " Ano do veiculo do segurado deve ser informado!"
                end if
                next field vclanomdl
             end if
          end if

   before field vcllicnum
          display by name d_cts14m00.vcllicnum  attribute (reverse)

   after  field vcllicnum
          display by name d_cts14m00.vcllicnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if not srp1415(d_cts14m00.vcllicnum)  then
                error " Placa invalida!"
                next field vcllicnum
             end if
          end if

## comentar para psi191965    before field vclchsfnl
## comentar para psi191965           display by name d_cts14m00.vclchsfnl  attribute (reverse)
## comentar para psi191965
## comentar para psi191965    after  field vclchsfnl
## comentar para psi191965           display by name d_cts14m00.vclchsfnl

## comentar psi191965                if fgl_lastkey() <> fgl_keyval("up")   and
## comentar psi191965                   fgl_lastkey() <> fgl_keyval("left") then
## comentar psi191965                   if d_cts14m00.vclchsfnl is null or
## comentar psi191965                      d_cts14m00.vclchsfnl =  "  " then
## comentar psi191965                      if g_documento.c24astcod = "V11"  then
## comentar psi191965                         error " Chassi do veiculo do terceiro deve ser informado!"
## comentar psi191965                      else
## comentar psi191965                         error " Chassi do veiculo do segurado deve ser informado!"
## comentar psi191965                      end if
## comentar psi191965                      next field vclchsfnl
## comentar psi191965                   end if
## comentar psi191965                end if

   before field chassi                                                         ## retirado comentario psi191965
          display by name d_cts14m00.chassi                                    ## retirado comentario psi191965

   after  field chassi                                                         ## retirado comentario psi191965
          call cts14m00_monta_chassi(d_cts14m00.chassi)                        ## retirado comentario psi191965
          returning d_cts14m00.vclchsinc, d_cts14m00.vclchsfnl                 ## retirado comentario psi191965
                                                                               ## retirado comentario psi191965
          if fgl_lastkey() <> fgl_keyval("up")   and                           ## retirado comentario psi191965
             fgl_lastkey() <> fgl_keyval("left") then                          ## retirado comentario psi191965
             if d_cts14m00.vclchsfnl is null or                                ## retirado comentario psi191965
                d_cts14m00.vclchsfnl =  "  " then                              ## retirado comentario psi191965
                if g_documento.c24astcod = "V11"  then                         ## retirado comentario psi191965
                   error " Chassi do veiculo do terceiro deve ser informado!"  ## retirado comentario psi191965
                else                                                           ## retirado comentario psi191965
                   error " Chassi do veiculo do segurado deve ser informado!"  ## retirado comentario psi191965
                end if                                                         ## retirado comentario psi191965
                next field chassi                                              ## retirado comentario psi191965
             end if                                                            ## retirado comentario psi191965
          end if                                                               ## retirado comentario psi191965

          # LH
          call cts14m00_chassi_valido (d_cts14m00.chassi, d_cts14m00.vclanomdl)
          returning r_erro

          if (r_erro is not null) then
             error r_erro
             next field chassi
          end if

   before field vstretflg
          display by name d_cts14m00.vstretflg attribute (reverse)

          if d_cts14m00.vstretflg = "N"  then
             initialize d_cts14m00.sindat, d_cts14m00.vstretnum,
                        d_cts14m00.vstretano   to null
             display by name d_cts14m00.sindat
             display by name d_cts14m00.vstretnum
             display by name d_cts14m00.vstretano
          end if

   after  field vstretflg
          display by name d_cts14m00.vstretflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if ((d_cts14m00.vstretflg is null)  or
                 (d_cts14m00.vstretflg <> "S"    and
                  d_cts14m00.vstretflg <> "N"))  then
                error " Vistoria e' um Retorno - (S)im ou (N)ao"
                next field vstretflg
             else
                if d_cts14m00.vstretflg  = "N"    or
                   g_documento.c24astcod = "V11"  then
                  #next field sinvstrgi
                   next field sindat
                end if
             end if
          else
             if g_documento.c24astcod = "V10"       and     #  dados da apl
                g_documento.aplnumdig is not null   and     #   nao podem
                d_cts14m00.segnom     is not null   then    #  ser alterados
                error " DADOS APOLICE NAO PODEM SER ALTERADOS !!!"
                next field vstretflg
             end if
           end if

   before field vstretnum
          display by name d_cts14m00.vstretnum attribute (reverse)

          initialize d_cts14m00.sinvstorgnum,
                     d_cts14m00.sinvstorgano  to null
          display by name d_cts14m00.sinvstorgnum
          display by name d_cts14m00.sinvstorgano

   after  field vstretnum
          display by name d_cts14m00.vstretnum

   before field vstretano
          display by name d_cts14m00.vstretano attribute (reverse)

   after  field vstretano
          display by name d_cts14m00.vstretano

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts14m00.vstretnum is not null   and
                d_cts14m00.vstretano is null       then
                error " Ano da vistoria deve ser informado!!"
                next field vstretnum
             end if

             if d_cts14m00.vstretano is not null   and
                d_cts14m00.vstretnum is null       then
                error " Numero da vistoria deve ser informado!!"
                next field vstretnum
             end if

             if d_cts14m00.vstretnum  is not null   then
                let d_cts14m00.sinvstorgnum = d_cts14m00.vstretnum
                let d_cts14m00.sinvstorgano = d_cts14m00.vstretano

                initialize ws.vstretnum  to null

                declare c_vstret  cursor for
                   select sinvstnum
                     from ssamsin
                    where sinvstnum = d_cts14m00.vstretnum  and
                          sinvstano = d_cts14m00.vstretano
                foreach c_vstret into ws.vstretnum
                   exit foreach
                end foreach
                if ws.vstretnum is null  then
                   error " Verifique se o numero da vistoria esta' correto!"
                else
                   display by name d_cts14m00.sinvstorgnum attribute (reverse)
                   display by name d_cts14m00.sinvstorgano attribute (reverse)
                end if
             end if
          end if

  #before field sinvstrgi
  #       display by name d_cts14m00.sinvstrgi attribute (reverse)

  #after  field sinvstrgi
  #       display by name d_cts14m00.sinvstrgi

  #       if fgl_lastkey() <> fgl_keyval("up")   and
  #          fgl_lastkey() <> fgl_keyval("left") then
  #          if d_cts14m00.sinvstrgi is null or
  #             d_cts14m00.sinvstrgi =  "  " then
  #             error " Verifique se municipio pertence a GRANDE SAO PAULO!"
  #             call c24geral13()
  #             next field sinvstrgi
  #          else
  #             if d_cts14m00.sinvstrgi <> "S"      and
  #                d_cts14m00.sinvstrgi <> "N"      then
  #                error " Vistoria na Grande Sao Paulo ? (S)im ou (N)ao"
  #                next field sinvstrgi
  #             else
  #                if d_cts14m00.sinvstrgi = "S" then
  #                   let d_cts14m00.descricao = "Grande S.P. e Capital"
  #                else
  #                   let d_cts14m00.descricao = "Interior"
  #                end if
  #                display by name d_cts14m00.descricao
  #             end if
  #          end if
  #       else
  #          if ((d_cts14m00.vstretflg = "N"  or
  #               g_documento.c24astcod = "V11")     and
  #               fgl_lastkey() = fgl_keyval("up"))  then
  #             next field vstretflg
  #          end if
  #       end if

   before field sindat
          if d_cts14m00.vstretflg = "S"  then
             next field sinavs
          end if
          display by name d_cts14m00.sindat attribute (reverse)

   after  field sindat
          display by name d_cts14m00.sindat

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts14m00.sindat is null then
                error " Data do sinistro deve ser informada!"
                next field sindat
             end if

             initialize d_cts14m00.sinvstorgnum,
                        d_cts14m00.sinvstorgano  to null
             display by name d_cts14m00.sinvstorgnum
             display by name d_cts14m00.sinvstorgano

             if g_documento.aplnumdig is not null then
                select viginc,vigfnl into ws.viginc,ws.vigfnl
                  from abamapol
                 where succod    = g_documento.succod    and
                       aplnumdig = g_documento.aplnumdig

                if d_cts14m00.sindat < ws.viginc or
                   d_cts14m00.sindat > ws.vigfnl then
                   error " Data do sinistro fora de vigencia da apolice!"
                   next field sindat
                end if
                call cts40g03_data_hora_banco(2)
                     returning l_data, l_hora2
                if d_cts14m00.sindat > l_data  then  # 05/09/2002.
                   error " Data de ocorrencia do sinistro nao pode",
                         " ser maior que hoje!"
                   next field sindat
                end if
                if g_documento.c24astcod = "V11"   then
                   next field sinavs
                end if

                ## VERIFICA SE JA' EXISTE VISTORIA DE SINISTRO P/ DATA ##

                initialize ws.sinvstnum, ws.sinvstano,
                           ws.orrdat   , ws.subcod      to null

                declare c_vstorig cursor for
                   select sinvstnum, sinvstano, orrdat, subcod
                     from ssamsin
                    where succod    = g_documento.succod    and
                          ramcod    = w_cts14m00.ramcod     and
                          aplnumdig = g_documento.aplnumdig

                foreach c_vstorig  into ws.sinvstnum,
                                        ws.sinvstano,
                                        ws.orrdat   ,
                                        ws.subcod

                   if d_cts14m00.sindat = ws.orrdat then
                      if (w_cts14m00.ramcod = 53  or
                          w_cts14m00.ramcod = 553)  and
                         ws.subcod         = 02  then
                         let d_cts14m00.sinvstorgnum = ws.sinvstnum
                         let d_cts14m00.sinvstorgano = ws.sinvstano
                         exit foreach
                      else
                         if w_cts14m00.ramcod = 31     or
                            w_cts14m00.ramcod = 531  then
                            let d_cts14m00.sinvstorgnum = ws.sinvstnum
                            let d_cts14m00.sinvstorgano = ws.sinvstano
                            exit foreach
                         end if
                       end if
                   end if
                 end foreach

                if d_cts14m00.sinvstorgnum  is not null   then
                   error " Sinistro possui numero vistoria original!"
                   display by name d_cts14m00.sinvstorgnum attribute (reverse)
                   display by name d_cts14m00.sinvstorgano attribute (reverse)
                else
                   call cts14m05(g_documento.succod   , w_cts14m00.ramcod,
                                 g_documento.aplnumdig, g_documento.itmnumdig,
                                 d_cts14m00.sindat)
                end if
             end if
          end if

   before field sinavs
          display by name d_cts14m00.sinavs attribute (reverse)

   after  field sinavs
          display by name d_cts14m00.sinavs

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts14m00.sinavs is null or
                d_cts14m00.sinavs =  "  " then
                error " Com quem esta' o aviso deve ser informado!"
                next field sinavs
             else
                case d_cts14m00.sinavs
                   when "C"  let d_cts14m00.avisocom = "Corretor"
                   when "O"  let d_cts14m00.avisocom = "Oficina"
                   when "I"  let d_cts14m00.avisocom = "Cia"
                   otherwise error " Informe com quem esta' o aviso!"
                             next field sinavs
                end case
                display by name d_cts14m00.avisocom
             end if
          else
             if d_cts14m00.vstretflg = "S"          and
                fgl_lastkey() = fgl_keyval("up")   then
               #next field sinvstrgi
                next field sindat
             end if
          end if

   before field orcvlr
          display by name d_cts14m00.orcvlr attribute (reverse)

   after  field orcvlr
          display by name d_cts14m00.orcvlr

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts14m00.orcvlr is null  or
                d_cts14m00.orcvlr =  0     then
               #if d_cts14m00.sinvstrgi = "N" then
               #   error " Para INTERIOR, o valor do orcamento deve ser informado!"
               #   next field orcvlr
               #end if   # ruiz

                error " Valor do Orcamento deve ser informado! "
                next field orcvlr
             end if
          end if

   before field nomrazsoc
          display by name d_cts14m00.nomrazsoc attribute (reverse)

   after  field nomrazsoc
          display by name d_cts14m00.nomrazsoc

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

              error " Localiza oficina no cadastro!"

              call ctn06c07(d_cts14m00.nomrazsoc,
                            d_cts14m00.dddcodofi,
                            d_cts14m00.telnumofi)
                  returning d_cts14m00.ofnnumdig,
                            d_cts14m00.nomrazsoc,
                            d_cts14m00.dddcodofi,
                            d_cts14m00.telnumofi

              initialize d_cts14m00.endlgd   , d_cts14m00.endbrr,
                         d_cts14m00.endcid   , d_cts14m00.endufd,
                         w_cts14m00.ofnstt   , ws.succod        ,
                         ws.ofnrgicod        , ws.inclui   to null

              display by name d_cts14m00.nomrazsoc
              display by name d_cts14m00.ofnnumdig
              display by name d_cts14m00.endlgd
              display by name d_cts14m00.endbrr
              display by name d_cts14m00.endcid
              display by name d_cts14m00.endufd
              display by name d_cts14m00.dddcodofi
              display by name d_cts14m00.telnumofi

              if d_cts14m00.nomrazsoc  is null   then
                 error " Nome da oficina e' obrigatorio!"
                 next field nomrazsoc
              end if
              ## PSI 191695 Alberto
              if g_documento.c24astcod = "V10" or
                 g_documento.c24astcod = "V11" then
                 if fissc101_portal(d_cts14m00.ofnnumdig,"OFCONLINE" ) then
                    let ws.confirma = cts08g01("A",
                                               "N",
                                               "",
                                               "OFICINA COM ACESSO AO PORTAL DE NEGOCIOS,",
                                               "SOLICITE MARCACAO DE VIST. PELA INTERNET ",
                                               "" )
                 end if
              end if
              ## PSI 191695 Alberto

              if d_cts14m00.ofnnumdig  is not null   then
                 select nomrazsoc, endlgd   , endbrr   , endcid   ,
                        endufd   , dddcod   , telnum1
                   into d_cts14m00.nomrazsoc, d_cts14m00.endlgd   ,
                        d_cts14m00.endbrr   , d_cts14m00.endcid   ,
                        d_cts14m00.endufd   , d_cts14m00.dddcodofi,
                        d_cts14m00.telnumofi
                   from gkpkpos
                  where pstcoddig = d_cts14m00.ofnnumdig

                 select ofnstt, ofnrgicod, succod, ofnbrrcod
                   into w_cts14m00.ofnstt,
                        ws.ofnrgicod,
                        ws.succod,
                        ws.ofnbrrcod
                   from sgokofi
                  where ofnnumdig = d_cts14m00.ofnnumdig

                 display by name d_cts14m00.nomrazsoc
                 display by name d_cts14m00.ofnnumdig
                 display by name d_cts14m00.endlgd
                 display by name d_cts14m00.endbrr
                 display by name d_cts14m00.endcid
                 display by name d_cts14m00.endufd
                 display by name d_cts14m00.dddcodofi
                 display by name d_cts14m00.telnumofi

                 if w_cts14m00.ofnstt = "C" then
                    call cts08g01("A", "N", "",
                                  "OFICINA EM OBSERVACAO!", "",
                                  "TRANSFIRA PARA DEPTO. DE SINISTRO")
                         returning ws.confirma
                    next field nomrazsoc
                 end if
                 next field vstdat

                #if ws.succod  =  1   then
                #   if d_cts14m00.sinvstrgi  =  "S"   and
                #      ws.ofnrgicod          >  30    then
                #      error " Vistoria na Grande Sao Paulo com oficina do interior !"
                #      next field nomrazsoc
                #   end if

                #   if d_cts14m00.sinvstrgi  =  "N"   and
                #      ws.ofnrgicod          <  31    then
                #      error " Vistoria no Interior com oficina da Grande Sao Paulo !"
                #      next field nomrazsoc
                #   end if
                #end if    # ruiz
              else
                 initialize d_cts14m00.dddcodofi  to null
                 initialize d_cts14m00.telnumofi  to null

                 call cts08g01("A", "N", "", "OFICINA SERA' INCLUIDA", "NO CADASTRO!", "") returning ws.confirma
                 let ws.inclui  =  "S"
              end if
          end if

   before field endlgd
          display by name d_cts14m00.endlgd    attribute (reverse)

   after  field endlgd
          display by name d_cts14m00.endlgd

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts14m00.endlgd    is null then
                error " Endereco da oficina deve ser informado!"
                next field endlgd
             end if
          end if

   before field endbrr
          display by name d_cts14m00.endbrr    attribute (reverse)

   after  field endbrr
          display by name d_cts14m00.endbrr

   before field endcid
          display by name d_cts14m00.endcid    attribute (reverse)

   after  field endcid
          display by name d_cts14m00.endcid

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts14m00.endcid    is null then
                error " Cidade da oficina deve ser informada!"
                next field endcid
             end if

           # if d_cts14m00.sinvstrgi = "S" then
           #    let ws.succod = 1
           #    let ws.ofnrgicod = 14
           # else
           #    error " Verifique a qual regiao pertence esta cidade!"

             if ws.inclui  =  "S"  then
                call cts14m03 (d_cts14m00.endcid)
                     returning ws.succod, ws.ofnrgicod, d_cts14m00.endcid
                if ws.ofnrgicod is null then
                   error " Cidade sem regiao cadastrada!"
                   next field endcid
                end if
                display by name d_cts14m00.endcid
             else
                select ofnrgicod
                    into ws.ofnrgicod
                    from gkpkbairro
                    where succod    = ws.succod
                      and ofnrgicod = ws.ofnrgicod
                      and ofnbrrcod = ws.ofnbrrcod
                if sqlca.sqlcode  <>  0 then
                   error " Cidade sem regiao cadastrada!"
                   next field endcid
                end if
                display by name d_cts14m00.endcid
             end if
          end if

   before field endufd
          display by name d_cts14m00.endufd    attribute (reverse)

   after  field endufd
          display by name d_cts14m00.endufd

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts14m00.endufd    is null then
                error " Unidade federativa deve ser informada!"
                next field endufd
             else
                select ufdcod from glakest
                 where glakest.ufdcod = d_cts14m00.endufd

                if sqlca.sqlcode = notfound then
                   error " Unidade federativa nao cadastrada!"
                   next field endufd
                end if
             end if
             call fvistsuc(0,d_cts14m00.endufd,"") returning ws.fvistsuc
             if ws.fvistsuc = "N"  then
                error "Sucursal nao pode fazer marcacao de Vistoria"
                next field endufd
             end if
          end if

   before field dddcodofi
          display by name d_cts14m00.dddcodofi attribute (reverse)

   after  field dddcodofi
          display by name d_cts14m00.dddcodofi

          if d_cts14m00.dddcodofi = " "         or
             d_cts14m00.dddcodofi = "9999"      then
             initialize d_cts14m00.dddcodofi to null
          end if

   before field telnumofi
          display by name d_cts14m00.telnumofi attribute (reverse)

   after  field telnumofi
          display by name d_cts14m00.telnumofi

          if d_cts14m00.dddcodofi is not null   and
             d_cts14m00.telnumofi is     null   then
             error " Numero de telefone nao informado para DDD!"
             next field dddcodofi
          end if

          let w_cts14m00.telnumofi = d_cts14m00.telnumofi

          set isolation to dirty read

          declare c_telefone cursor for
             select ofnnumdig, dddcod
               from gkpkpos, sgokofi
              where gkpkpos.telnum1   = w_cts14m00.telnumofi
                and sgokofi.ofnnumdig = gkpkpos.pstcoddig
              union
             select ofnnumdig, dddcod
               from gkpkpos, sgokofi
              where gkpkpos.telnum2   = w_cts14m00.telnumofi
                and sgokofi.ofnnumdig = gkpkpos.pstcoddig

          foreach c_telefone into ws.ofnnumdig, ws.dddcod
          if ws.ofnnumdig = d_cts14m00.ofnnumdig  then
             continue foreach
          end if

          set isolation to committed read

          if ws.dddcod = d_cts14m00.dddcodofi  then
             error " Ja' existe oficina cadastrada com este telefone! Pesquise por telefone."
             next field nomrazsoc
          end if
          end foreach

   before field vstdat

          if time > d_cts14m00.horvst and ## retirado comentario psi191965
          ## comentado para psi191965 if time > "18:30:00"    and
             ws.conf48hs is null  then
             call cts08g01("A","N","","VISTORIA SOMENTE EM","","2 (DOIS) DIAS UTEIS !") returning ws.conf48hs
          end if
          display by name d_cts14m00.vstdat    attribute (reverse)

   after  field vstdat
          display by name d_cts14m00.vstdat

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts14m00.vstdat is null then
                error " Opcoes de data de vistoria para esta cidade!"

                call cts14m04 (ws.succod, ws.ofnrgicod, d_cts14m00.vstretflg)
                     returning d_cts14m00.vstdat


                next field vstdat
             end if

             if d_cts14m00.vstdat <= ws.hojdat  then
                error " Data da vistoria nao pode ser menor ou igual a data atual!"
                next field vstdat
             end if

             if weekday(ws.hojdat) = 6  or    ###  Marcando vistoria no sabado
                weekday(ws.hojdat) = 0  then  ###  Marcando vistoria no domingo
                if d_cts14m00.vstdat < dias_uteis(ws.hojdat, +2, "", "N", "N")  then
                   error " Vistoria so' pode ser marcada em 2 dias uteis!"
                   next field vstdat
                end if
             end if

#--------------------------------------------------------------------
# Marcando vistoria em feriado
#--------------------------------------------------------------------

             call dias_uteis(ws.hojdat, 0, "", "N", "N")
                   returning ws.utldat

             if ws.utldat is not null  and
                ws.utldat <> ws.hojdat then
                if d_cts14m00.vstdat < dias_uteis(ws.hojdat, +2, "", "N", "N")  then
                   error " Vistoria em feriado so' pode ser marcada em 2 dias uteis!"
                   next field vstdat
                end if
             end if

             if time > d_cts14m00.horvst then ## retirado comentario psi191965
             ## comentado para psi191965 if time > "18:30:00"  then
                if weekday(ws.hojdat) = 5  then  ###  Marcando vistoria na sexta
                   if d_cts14m00.vstdat < dias_uteis(ws.hojdat, +2, "", "N", "N")  then
                      error " Vistoria so' pode ser marcada em 3 dias uteis!"
                      next field vstdat
                   end if
                end if

                if d_cts14m00.vstdat < dias_uteis(ws.hojdat, +2, "", "N", "N")  then
                   error " Vistoria so' pode ser marcada em 2 dias uteis!"
                   next field vstdat
                end if
             end if

             if d_cts14m00.vstretflg = "S"           then
                if time              >  d_cts14m00.horvst then ## retirado comentario psi191965
                ## comentado para psi191965 if time              > "18:30:00"    then
                   if d_cts14m00.vstdat = ws.hojdat + 1 units day  then
                      error " Apos as 18:30 retorno em 24 horas uteis!"
                      next field vstdat
                   end if

                   if weekday(ws.hojdat) = 5  then  ###  Marcando retorno na sexta
                      if d_cts14m00.vstdat < ws.hojdat + 4 units day  then
                         error " Retorno em 24 horas uteis !!"
                         next field vstdat
                      end if
                   end if
                end if
             end if

             if d_cts14m00.vstdat > ws.hojdat + 30 units day  then
                error " Data da vistoria excede 30 dias!"
                next field vstdat
             end if

             if weekday(d_cts14m00.vstdat) = 0  or
                weekday(d_cts14m00.vstdat) = 6  then
                error " Nao fazemos vistorias em finais de semana!"
                next field vstdat
             end if

             call dias_uteis(d_cts14m00.vstdat, 0, "", "N", "N")
                  returning ws.utldat

             if ws.utldat is not null   and
                d_cts14m00.vstdat <> ws.utldat  then
                error " Nao fazemos vistorias em feriados!"
                next field vstdat
             end if

            #if d_cts14m00.sinvstrgi = "N"  then
                select vstsegflg,
                       vstterflg,
                       vstquaflg,
                       vstquiflg,
                       vstsexflg
                  into ws.vstsegflg,
                       ws.vstterflg,
                       ws.vstquaflg,
                       ws.vstquiflg,
                       ws.vstsexflg
                  from gkpkregi
                 where succod    = ws.succod   and
                       ofnrgicod = ws.ofnrgicod

                if weekday(d_cts14m00.vstdat) = 1  then
                   if ws.vstsegflg is null or
                      ws.vstsegflg =  "N"  then
                      error " Esta regiao nao faz vistoria as segundas-feiras!"
                      next field vstdat
                   end if
                end if

                if weekday(d_cts14m00.vstdat) = 2  then
                   if ws.vstterflg is null or
                      ws.vstterflg =  "N"  then
                      error " Esta regiao nao faz vistoria as tercas-feiras!"
                      next field vstdat
                   end if
                end if

                if weekday(d_cts14m00.vstdat) = 3  then
                   if ws.vstquaflg is null or
                      ws.vstquaflg =  "N"  then
                      error " Esta regiao nao faz vistoria as quartas-feiras!"
                      next field vstdat
                   end if
                end if

                if weekday(d_cts14m00.vstdat) = 4  then
                   if ws.vstquiflg is null or
                      ws.vstquiflg =  "N"  then
                      error " Esta regiao nao faz vistoria as quintas-feiras!"
                      next field vstdat
                   end if
                end if

                if weekday(d_cts14m00.vstdat) = 5  then
                   if ws.vstsexflg is null or
                      ws.vstsexflg =  "N"  then
                      error " Esta regiao nao faz vistoria as sextas-feiras!"
                      next field vstdat
                   end if
                end if
            #end if

             if g_documento.c24astcod = "V11"  and
                d_cts14m00.vstretflg  = "N"     then
                if d_cts14m00.vstdat  = ws.hojdat + 1 units day   then
                   call cts08g01("T", "N", "VISTORIA PODERA SER REALIZADA","", "ATE'  24 HORAS  APOS A MARCACAO", "") returning ws.confirma
                end if
             end if

             let ws.vstdattxt = "MARCADA PARA ", d_cts14m00.vstdat
             if cts08g01("C", "S", "", "VISTORIA DE SINISTRO AUTO", ws.vstdattxt, "") = "N"  then
                next field vstdat
             end if

             if g_documento.c24soltipcod = 1   and  # Tipo Solic = Segurado
                g_documento.c24astcod <> "V11" then
              # call cts09g00(g_documento.ramcod   ,  # psi 141003
              #               g_documento.succod   ,
              #               g_documento.aplnumdig,
              #               g_documento.itmnumdig,
              #               true)
              #     returning w_cts14m00.dddcod,
              #               w_cts14m00.teltxt
             end if
          end if

   before field dddcodctt
          display by name d_cts14m00.dddcodctt attribute (reverse)

   after  field dddcodctt
          display by name d_cts14m00.dddcodctt

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts14m00.dddcodctt = " "         or
                d_cts14m00.dddcodctt is null       then
                error " Codigo DDD deve ser informado!"
                next field dddcodctt
             end if
          end if

   before field telnumctt
          display by name d_cts14m00.telnumctt attribute (reverse)

   after  field telnumctt
          display by name d_cts14m00.telnumctt

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts14m00.telnumctt = "  "    or
                d_cts14m00.telnumctt is null   then
                error " Numero de telefone deve ser informado!"
                next field telnumctt
             end if
          end if

   on key (interrupt)

      if g_documento.atdsrvnum is null  then
         if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","") = "S"  then
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

   on key (F5)
#     if g_documento.succod    is not null  and
#        g_documento.ramcod    is not null  and
#        g_documento.aplnumdig is not null  then
#        if g_documento.ramcod = 31    or
#           g_documento.ramcod = 531  then
#           call cta01m00()
#        else
#           call cta01m20()
#        end if
#     else
#        if g_documento.prporg    is not null  and
#           g_documento.prpnumdig is not null  then
#           call opacc149(g_documento.prporg, g_documento.prpnumdig) returning ws.prpflg
#        else
#           if g_documento.pcacarnum is not null  and
#              g_documento.pcaprpitm is not null  then
#              call cta01m50(g_documento.pcacarnum, g_documento.pcaprpitm)
#           else
#              error " Espelho so' com documento localizado!"
#           end if
#        end if
#     end if

      let g_monitor.horaini = current ## Flexvision
      call cta01m12_espelho(g_documento.ramcod
                           ,g_documento.succod
                           ,g_documento.aplnumdig
                           ,g_documento.itmnumdig
                           ,g_documento.prporg
                           ,g_documento.prpnumdig
                           ,g_documento.fcapacorg
                           ,g_documento.fcapacnum
                           ,g_documento.pcacarnum
                           ,g_documento.pcaprpitm
                           ,g_ppt.cmnnumdig
                           ,g_documento.crtsaunum
                           ,g_documento.bnfnum
                           ,g_documento.ciaempcod) #psi 205206
 end input

end function  ###  input_cts14m00

## CT
#-----------------------------------------#
function cts14m00_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         msglin1      char(40),
         msglin2      char(40),
         msglin3      char(40),
         msglin4      char(40),
         msg_erro     char(100)
  end record

  define l_hora       datetime hour to second,
         l_data       date,
         l_de         char(30),
         l_para       char(30),
         l_cc         char(30),
         l_assunto    char(30),
         l_comando    char(500),
         l_msg        char(500)

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
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_hora  =  null
        let     l_data  =  null
        let     l_de  =  null
        let     l_para  =  null
        let     l_cc  =  null
        let     l_assunto  =  null
        let     l_comando  =  null
        let     l_msg  =  null

  call cts40g03_data_hora_banco(1)
       returning l_data, l_hora

  let l_de      = "Central-24-Horas"
  let l_para    = "Rodrigues_Alberto@correioporto"
  let l_cc      = "Ruiz_Carlos@correioporto"
  let l_assunto = "Vistoria V10 "
  let l_comando = null

  let l_msg = lr_parametro.msglin1 clipped, "  |  ",
              lr_parametro.msglin2 clipped, "  |  ",
              lr_parametro.msglin3 clipped, "  |  ",
              lr_parametro.msglin4 clipped, "  |  ",
              lr_parametro.msg_erro clipped

   #PSI-2013-23297 - Inicio
   let l_mail.de = l_de
   #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
   let l_mail.para = l_para
   let l_mail.cc = l_cc
   let l_mail.cco = ""
   let l_mail.assunto = l_assunto
   let l_mail.mensagem = l_msg
   let l_mail.id_remetente = "CT24HS"
   let l_mail.tipo = "text"

   call figrc009_mail_send1 (l_mail.*)
      returning l_coderro,msg_erro
   #PSI-2013-23297 - Fim

end function


#-------------------------------------------------------------#
 function cts14m00_monta_xml(lr_param)
#-------------------------------------------------------------#

 define lr_param  record
                  sinvstnum like datmvstsin.sinvstnum
                 ,sinvstano like datmvstsin.sinvstano
                 ,tipprd    char(001)
                 ,sinevtnum like sanmevt.sinevtnum
                 ,aviso     like sanmavs.sinavsnum
                 ,ordem     integer
                 ,veic      integer
 end record

 define l_xml       char(32766)

 let l_xml = "<mq>",
             "<servico>","EMISLAUDO","</servico>",
             "<param>",lr_param.sinvstnum,"</param>",
             "<param>",lr_param.sinvstano,"</param>",
             "<param>",lr_param.tipprd,"</param>",
             "<param>","CT","</param>",
             "<param>",g_issk.succod,"</param>",       ## Codigo da Sucursal
             "<param>",g_issk.empcod,"</param>",       ## Codigo da empresa
             "<param>",g_issk.dptsgl clipped,"</param>",          ## Codigo do depatramento
             "<param>",g_issk.funmat,"</param>",   ## Matricula do Solicitante
             "<param>",lr_param.sinevtnum,"</param>", ## Nº Evento
             "<param>",lr_param.aviso,"</param>",  ## Nº Aviso
             "<param>",lr_param.ordem,"</param>",     ## Ordem
             "<param>",lr_param.veic,"</param>", ## Codigo do Veiculo
             "</mq>"


{ let l_xml = "<mq>",
             "<servico>","EMISLAUDO","</servico>",
             "<param>",lr_param.sinvstnum using "<<<<<&","</param>",
             "<param>",lr_param.sinvstano,"</param>",
             "<param>",lr_param.tipprd,"</param>",
             "<param>","CT","</param>",
             "<param>",g_issk.succod using "&&","</param>",       ## Codigo da Sucursal
             "<param>",g_issk.empcod using "&&","</param>",       ## Codigo da empresa
             "<param>",g_issk.dptsgl clipped,"</param>",          ## Codigo do depatramento
             "<param>",g_issk.funmat using "&&&&&&","</param>",   ## Matricula do Solicitante
             "<param>",lr_param.sinevtnum using "&&&&&&&&","</param>", ## Nº Evento
             "<param>",lr_param.aviso using "&&&&&&","</param>",  ## Nº Aviso
             "<param>",lr_param.ordem using "&&&","</param>",     ## Ordem
             "<param>",lr_param.veic using "&&&&&&","</param>", ## Codigo do Veiculo
             "</mq>"}


 return l_xml

 end function

#-------------------------------------#                       ## retirado comentario psi195693
function cts14m00_monta_chassi(l_param)                       ## retirado comentario psi195693
#-------------------------------------#                       ## retirado comentario psi195693
                                                              ## retirado comentario psi195693
 define l_param      char(20)                                 ## retirado comentario psi195693
 define l_chsinc     char(12)                                 ## retirado comentario psi195693
 define l_chsfnl     char(08)                                 ## retirado comentario psi195693
 define l_tam_chassi smallint                                 ## retirado comentario psi195693
 define l_tam        smallint                                 ## retirado comentario psi195693
                                                              ## retirado comentario psi195693
 initialize l_chsinc     to null                              ## retirado comentario psi195693
 initialize l_chsfnl     to null                              ## retirado comentario psi195693
 initialize l_tam_chassi to null                              ## retirado comentario psi195693
 initialize l_tam        to null                              ## retirado comentario psi195693
                                                              ## retirado comentario psi195693
 let l_tam_chassi = 0                                         ## retirado comentario psi195693
 let l_tam        = 0                                         ## retirado comentario psi195693
                                                              ## retirado comentario psi195693
 let l_tam_chassi = length(l_param clipped)                   ## retirado comentario psi195693
                                                              ## retirado comentario psi195693
 for l_tam = 1 to (length(l_param clipped))                   ## retirado comentario psi195693
     if l_tam <= (length(l_param clipped) - 8 ) then          ## retirado comentario psi195693
        let l_chsinc = l_chsinc clipped , l_param[l_tam,l_tam]## retirado comentario psi195693
     else                                                     ## retirado comentario psi195693
        let l_chsfnl = l_chsfnl clipped , l_param[l_tam,l_tam]## retirado comentario psi195693
     end if                                                   ## retirado comentario psi195693
 end for                                                      ## retirado comentario psi195693
                                                              ## retirado comentario psi195693
 return l_chsinc, l_chsfnl                                    ## retirado comentario psi195693
                                                              ## retirado comentario psi195693
end function                                                  ## retirado comentario psi195693

# LH - 24/11/2008 - PSI228125
# A funcao 'cts14m00_branco' recebe um caracter 'l_caracter', retorna 0 caso ele
# seja um caracter branco (caracter vazio, espaco em branco, caracter de
# tabulacao horizontal ou caracter de nova linha) e retorna 1 caso contrario.
function cts14m00_branco (l_caracter)
   define l_caracter char(1)
   define l_ordinal integer

   # Obtem o valor numerico do caracter segunda a tabela ASCII.
   let l_ordinal = ord (l_caracter)

   # Verifica se o caracter recebido e igual a um dos caracteres branco.
   # 0 = caracter vazio, 9 = caracter de tabulacao horizontal, 10 = caracter de
   # nova linha e 32 = espaco em branco
   if (l_ordinal = 0 or l_ordinal = 9 or l_ordinal = 10 or l_ordinal = 32) then
      return (1)
   else
      return (0)
   end if
end function

# LH - 24/11/2008 - PSI228125
# A funcao 'cts14m00_right_trim' recebe um string e retorna o mesmo string sem
# qualquer caracter branco do lado direito do string.
function cts14m00_right_trim (l_string)
   define l_string varchar(100)
   define l_comp integer
   define l_i integer
   define l_b integer

   let l_comp = length (l_string)

   if (l_comp = 0) then
      return ('')
   end if

   let l_i = l_comp
   let l_b = 1

   while (l_i >= 1 and l_b = 1)
      let l_b = cts14m00_branco (l_string[l_i,l_i])
      let l_i = l_i - 1
   end while

   if (l_b = 0) then
      return (l_string[1, l_i + 1])
   else
      return ('')
   end if
end function

# LH - 24/11/2008 - PSI228125
# A funcao 'cts14m00_left_trim' recebe um string e retorna o mesmo string sem
# qualquer caracter branco do lado esquerdo do string.
function cts14m00_left_trim (l_string)
   define l_string varchar(100)
   define l_comp integer
   define l_i integer
   define l_b integer

   let l_comp = length (l_string)

   if (l_comp = 0) then
      return ('')
   end if

   let l_i = 1
   let l_b = 1

   while (l_i <= l_comp and l_b = 1)
      let l_b = cts14m00_branco (l_string[l_i,l_i])
      let l_i = l_i + 1
   end while

   if (l_b = 0) then
      return (l_string[l_i - 1, l_comp])
   else
      return ('')
   end if
end function

# LH - 24/11/2008 - PSI228125
# A funcao 'cts14m00_trim' recebe um string e retorna o mesmo string sem
# caracteres brancos em ambos os lados, direito e esquerdo.
function cts14m00_trim (l_string)
   define l_string varchar(100)
   define r_string varchar(100)

   let r_string = cts14m00_right_trim (l_string)
   let r_string = cts14m00_left_trim (r_string)

   return (r_string)
end function

function limparCaracteres (p_string)
   define p_string varchar (20)
   define r_string varchar (20)
   define l_i integer
   define l_comp integer

   let l_comp = length (p_string)
   let r_string = ""

   for l_i = 1 to l_comp
      if (p_string[l_i] <> '-' and p_string[l_i] <> '/' and
          p_string[l_i] <> '.' and p_string[l_i] <> ',' and
          p_string[l_i] <> '(' and p_string[l_i] <> ')' and
          p_string[l_i] <> ' ') then
         let r_string = r_string, p_string[l_i]
      end if
   end for

   return (r_string)
end function

function limparAlfabeto (p_string)
   define p_string varchar(20)
   define r_string varchar(20)
   define l_i integer
   define l_comp integer
   define l_ordinal integer

   let p_string = Maiuscula (p_string)
   let l_comp = length (p_string)

   let r_string = ""

   for l_i = 1 to l_comp
      let l_ordinal = ord (p_string[l_i])

      if (l_ordinal < 65 or l_ordinal > 90) then
         let r_string = r_string, p_string[l_i]
      end if
   end for

   return (r_string)
end function

function Maiuscula (p_string)
   define p_string varchar (255)
   define l_i integer
   define l_comp integer
   define l_ordinal integer

   let l_comp = length (p_string)

   for l_i = 1 to l_comp
      let l_ordinal = ord (p_string[l_i])

      if (l_ordinal >= 97 and l_ordinal <= 122) then
         let p_string[l_i] = ascii (l_ordinal - 32)
      end if
   end for

   return (p_string)
end function

function cts14m00_chassi_valido (p_chassi, p_modelo)
   define p_chassi varchar(20)
   define p_modelo like datmvstsin.vclanomdl
   define l_chassi_limpo varchar(20)
   define l_parte_final_chassi varchar(20)
   define l_parte_final_chassi_limpa varchar(20)
   define l_comp integer
   define l_i integer
   define l_valido integer
   define l_erro varchar(100)

   let p_chassi = cts14m00_trim (p_chassi)
   let l_comp = length (p_chassi)
   let l_valido = 1
   let l_erro = null

   if (p_modelo >= '1998' and l_comp < 17) then
      let l_erro = "O chassi nao pode ter menos de 17 caracteres a partir de 1998."
      return (l_erro)
   end if

   if (l_comp < 7) then
      let l_erro = "O comprimento do chassi nao pode ser menor que 7 caracteres."
      return (l_erro)
   end if

   if (l_comp > 17) then
      let l_erro = "O comprimento do chassi nao pode ser maior que 17 caracteres."
      return (l_erro)
   end if

   if (l_comp > 16) then
      let l_chassi_limpo = limparCaracteres (p_chassi);

      # Chassi não pode ter caracteres especiais
      if (p_chassi <> l_chassi_limpo) then
         let l_erro = "Chassi so pode conter letras e digitos."
         return (l_erro)
      end if

      let p_chassi = Maiuscula (p_chassi)

      # Chassi não pode conter letras I, O e Q
      let l_i = 1

      while (l_i <= l_comp and l_valido = 1)
         if (p_chassi[l_i] = "I" or p_chassi[l_i] = "O" or p_chassi[l_i] = "Q") then
            let l_valido = 0
         end if

         let l_i = l_i + 1
      end while

      if (l_valido = 0) then
         let l_erro = "O chassi nao pode conter os caracteres 'I', 'O' e 'Q'."
         return (l_erro)
      end if

      let l_parte_final_chassi = p_chassi[13,l_comp];
      let l_parte_final_chassi_limpa = limparAlfabeto (l_parte_final_chassi);

      if (l_parte_final_chassi <> l_parte_final_chassi_limpa) then
         let l_erro = "Os ultimos cinco caracteres do chassi devem ser digitos."
         return (l_erro)
      end if
   end if

   return (l_erro)
end function

