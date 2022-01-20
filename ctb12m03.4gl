#############################################################################
# Nome do Modulo: CTB12M03                                         Marcelo  #
#                                                                  Gilberto #
# Tela de consulta de servico e acerto de valor                    Abr/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 11/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a   #
#                                       serem excluidos.                    #
#---------------------------------------------------------------------------#
# 02/12/1999  PSI 9428-5   Wagner       Consultar e informar se servico tem #
#                                       analise.                            #
#---------------------------------------------------------------------------#
# 17/12/1999  PSI 9805-1   Gilberto     Incluir data de protocolo da OP.    #
#---------------------------------------------------------------------------#
# 02/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 11/04/2000  PSI 10426-4  Wagner       Informar qtde de analises que o ser-#
#                                       vico se encontra.                   #
#---------------------------------------------------------------------------#
# 30/05/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 27/03/2001  PSI 12768-0  Wagner       Incluir recepcao parametro o nro do #
#                                       servico e o ano..                   #
#---------------------------------------------------------------------------#
# 20/07/2001  PSI 13511-9  Wagner       Incluir acesso a ligacoes.          #
#---------------------------------------------------------------------------#
# 22/05/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
#---------------------------------------------------------------------------#
# 05/10/2006  PSI 202720   Priscila     Implementar cartao saude            #
#---------------------------------------------------------------------------#
# 12/01/2007  PSI 205206   Priscila     Incluir empresa do servico          #
#---------------------------------------------------------------------------#
# 18/01/2007  PSI 205206   Priscila     Incluir limite kilometragem         #
# 13/08/2009  PSI 244236   Burini       Inclusão do Sub-Dairro              #
#---------------------------------------------------------------------------#
# 01/10/2009  PSI 248800   Beatriz      Menu de coordenadas                 #
#---------------------------------------------------------------------------#
# 31/12/2009               Amilton,Meta Projeto succod smallint             #
#---------------------------------------------------------------------------#
# 02/03/2010 PSI 252891    Adriano S    Inclusao do padrao idx 4 e 5        #
#############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"

 define k_ctb12m03   record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

#-----------------------------------------------------------
 function ctb12m03(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define ws           record
    time             char (11),
    hoje             char (10),
    hora             char (05),
    msg1             char (40),
    msg2             char (40),
    msg3             char (40),
    msg4             char (40),
    confirma         char (01)
 end record

 define lr_ctc20m09     record
    coderro         integer,                         ## Cod.erro ret.0=OK/<>0 Error
    msgerro         char(100),                       ## Mensagem erro retorno
    pstprmvlr       like dpampstprm.pstprmvlr
 end record

 initialize k_ctb12m03.*, lr_ctc20m09.*, ws.* to null

 let ws.hoje = today
 let ws.time = time
 let ws.hora = ws.time[1,5]

 let int_flag = false

 open window ctb12m03 at 04,02 with form "ctb12m03"
 display "/" at 02,13
 display "-" at 02,21
 display "-" at 04,21

 menu "SERVICO"

    before menu
           hide option all
           if get_niv_mod(g_issk.prgsgl,"ctb12m03")  then        ## NIVEL 1
              if g_issk.acsnivcod >= g_issk.acsnivcns  then
                 show option "Seleciona","Destino","Prestador",
                             "Historico","pesQuisa","Imprime" ,
                             "Acompanhamento","liGacoes","Ref_local","Coordenadas","Bonificacao"
              end if

              if g_issk.prgsgl <> "ctg8"  then
                 if g_issk.acsnivcod >= g_issk.acsnivatl  then   ## NIVEL 6
                    show option "Valor"
                 end if

                 if g_issk.acsnivcod >= 8  then                  ## NIVEL 8
                    show option "Libera"
                 end if
              end if
           end if

           show option "Encerra"

    command key ("S") "Seleciona"
                      "Seleciona servico para consulta"
            clear form
            call seleciona_ctb12m03(param.*) returning k_ctb12m03.*
            if k_ctb12m03.atdsrvnum is not null  then
               next option "Destino"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key ("D") "Destino"
                     "Destino do veiculo"
           if k_ctb12m03.atdsrvnum is not null then
              call cts06g08(k_ctb12m03.atdsrvnum,
                            k_ctb12m03.atdsrvano,
                            2)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("P") "Prestador"
                     "Prestador acionado"
           if k_ctb12m03.atdsrvnum is not null then
              call cts20m05(k_ctb12m03.atdsrvnum, k_ctb12m03.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("V") "Valor"
                     "Acerta valor do servico selecionado"
           if k_ctb12m03.atdsrvnum is not null then
              call ctb12m06(k_ctb12m03.atdsrvnum, k_ctb12m03.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("H") "Historico"
                     "Exibe historico do servico selecionado"
           if k_ctb12m03.atdsrvnum is not null  then
              call cts10n00(k_ctb12m03.atdsrvnum, k_ctb12m03.atdsrvano,
                            g_issk.funmat       , ws.hoje  , ws.hora  )
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("Q") "pesQuisa"
                     "Pesquisa por data, tipo, placa, ou nome do solicitante"
              call ctb12m07() returning k_ctb12m03.atdsrvnum,
                                        k_ctb12m03.atdsrvano
              if k_ctb12m03.atdsrvnum  is not null   and
                 k_ctb12m03.atdsrvano  is not null   then
                 error "Selecione e tecle ENTER!"
                 next option "Seleciona"
              else
                 error " Nenhum servico foi selecionado!"
              end if

   command key ("A") "Acompanhamento"
                     "Acompanhamento do servico selecionado"
           if k_ctb12m03.atdsrvnum is not null then
              call cts00m11(k_ctb12m03.atdsrvnum, k_ctb12m03.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("G") "liGacoes"
                     "Ligacoes referente a apolice deste servico"
           if k_ctb12m03.atdsrvnum is not null then
              call ligacoes_ctb12m03(k_ctb12m03.atdsrvnum, k_ctb12m03.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("R") "Ref_local"
                     "Referencia do local do socorro"
           if k_ctb12m03.atdsrvnum is not null then
              call cts00m23(k_ctb12m03.atdsrvnum, k_ctb12m03.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("I") "Imprime"
                     "Imprime servico selecionado"
           if k_ctb12m03.atdsrvnum is not null then
              call ctr03m02(k_ctb12m03.atdsrvnum, k_ctb12m03.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("L") "Libera"
                     "Libera servico selecionado"
           if k_ctb12m03.atdsrvnum is not null then
              call ctb12m08(k_ctb12m03.atdsrvnum, k_ctb12m03.atdsrvano)
              next option "Seleciona"
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("C") "Coordenadas"
                     "Coordenadas do servico"
           if k_ctb12m03.atdsrvnum is not null then
              call coordenadas_ctb12m03(k_ctb12m03.atdsrvnum, k_ctb12m03.atdsrvano)
              next option "Seleciona"
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("B") "Bonificacao"
                     "Motivo Bonificacao"
           if k_ctb12m03.atdsrvnum is not null then

              call ctc20m09_valor_bonificacao(k_ctb12m03.atdsrvnum, k_ctb12m03.atdsrvano)
                   returning lr_ctc20m09.*

              case lr_ctc20m09.coderro
              	  when 0
              	  	let ws.msg1 = 'Existe bonificacao e esta OK'
              	  	let ws.msg2 = ''
              	  	let ws.msg3 = ''
              	  	let ws.msg4 = 'Valor: ', lr_ctc20m09.pstprmvlr using '"###,##&.&&"'
              	  when 1
              	  	let ws.msg1 = 'Existe bonificacao porem teve alguma penalidade'
              	  	let ws.msg2 = 'Motivo:'
              	  	let ws.msg3 = lr_ctc20m09.msgerro
              	  	let ws.msg4 = 'Valor: ', lr_ctc20m09.pstprmvlr using '"###,##&.&&"'
              	  when 2
              	  	let ws.msg1 = 'Nao existe bonificacao para servico'
              	  	let ws.msg2 = 'Motivo:'
              	  	let ws.msg3 = lr_ctc20m09.msgerro
              	  	let ws.msg4 = ''
              end case

              call cts08g01("A","N", ws.msg1, ws.msg2, ws.msg3, ws.msg4)
                   returning ws.confirma

              next option "Seleciona"
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
 end menu

 close window ctb12m03

end function  ###  ctb12m03

#-----------------------------------------------------------
 function seleciona_ctb12m03(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define d_ctb12m03  record
    atdsrvorg       like datmservico.atdsrvorg   ,
    atdsrvnum       like datmservico.atdsrvnum   ,
    atdsrvano       like datmservico.atdsrvano   ,
    srvtipabvdes    like datksrvtip.srvtipabvdes ,
    c24solnom       like datmligacao.c24solnom   ,
    limite          char(45)                     ,   #PSI 205206
    empresa         like gabkemp.empsgl          ,   #PSI 205206
    nom             like datmservico.nom         ,
    doctxt          char (32)                    ,
    corsus          like datmservico.corsus      ,
    cornom          like datmservico.cornom      ,
    cvnnom          char (15)                    ,
    vclcoddig       like datmservico.vclcoddig   ,
    vcldes          like datmservico.vcldes      ,
    vclanomdl       like datmservico.vclanomdl   ,
    vcllicnum       like datmservico.vcllicnum   ,
    vclcordes       char (12)                    ,
    livre1          char (50)                    ,
    livre2          char (76)                    ,
    c24astcod       like datkassunto.c24astcod   ,
    c24astdes       like datkassunto.c24astdes   ,
    atdlibtxt       char (64)                    ,
    tmptxt          char (30)                    ,
    asitipdes       like datkasitip.asitipdes    ,
    opgtxt          char (10)                    ,
    pgtdattxt       char (21)                    ,
    atdcstvlr       like datmservico.atdcstvlr   ,
    socopgnum       like dbsmopg.socopgnum
 end record

 define a_ctb12m03    array[1] of record
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (65)                    ,
    lgdtip            like datmlcl.lgdtip          ,
    lgdnom            like datmlcl.lgdnom          ,
    lgdnum            like datmlcl.lgdnum          ,
    brrnom            like datmlcl.brrnom          ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    endzon            like datmlcl.endzon          ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lgdcep            like datmlcl.lgdcep          ,
    lgdcepcmp         like datmlcl.lgdcepcmp       ,
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod    ,
    endcmp            like datmlcl.endcmp
 end record

 define ws          record
    lignum          like datrligsrv.lignum       ,
    asitipcod       like datmservico.asitipcod   ,
    atddatprg       like datmservico.atddatprg   ,
    atdhorprg       like datmservico.atdhorprg   ,
    atdhorpvt       like datmservico.atdhorpvt   ,
    ligcvntip       like datmligacao.ligcvntip   ,
    succod          like datrligapol.succod      ,
    ramcod          like datrligapol.ramcod      ,
    aplnumdig       like datrligapol.aplnumdig   ,
    itmnumdig       like datrligapol.itmnumdig   ,
    crtnum          like datrsrvsau.crtnum       ,     #PSI 202720
    edsnumref       like datrligapol.edsnumref   ,
    prporg          like datrligprp.prporg       ,
    prpnumdig       like datrligprp.prpnumdig    ,
    fcapacorg       like datrligpac.fcapacorg    ,
    fcapacnum       like datrligpac.fcapacnum    ,
    vclcorcod       like datmservico.vclcorcod   ,
    atddat          like datmservico.atddat      ,
    atdhor          like datmservico.atdhor      ,
    funmat          like datmservico.funmat      ,
    funnom          char (14)                    ,
    dptsgl          like isskfunc.dptsgl         ,
    atdlibdat       like datmservico.atdlibdat   ,
    atdlibhor       like datmservico.atdlibhor   ,
    atddfttxt       like datmservico.atddfttxt   ,
    sindat          like datmservicocmp.sindat   ,
    bocnum          like datmservicocmp.bocnum   ,
    bocemi          like datmservicocmp.bocemi   ,
    socfatentdat    like dbsmopg.socfatentdat    ,
    pgtdat          like datmservico.pgtdat      ,
    sqlcode         integer                      ,
    c24evtcod       like datkevt.c24evtcod       ,
    c24evtcod_svl   like datkevt.c24evtcod       ,
    c24evtrdzdes    like datkevt.c24evtrdzdes    ,
    c24fsecod       like datkfse.c24fsecod       ,
    c24fsecod_svl   like datkfse.c24fsecod       ,
    srvanlhstseq    like datmsrvanlhst.srvanlhstseq,
    c24fsedes       like datkfse.c24fsedes       ,
    cadmat          like datmsrvanlhst.cadmat    ,
    cadmat_svl      like datmsrvanlhst.cadmat    ,
    caddat          like datmsrvanlhst.caddat    ,
    caddat_svl      like datmsrvanlhst.caddat    ,
    funnom_hst      char (25)                    ,
    msg1            char (40)                    ,
    msg2            char (40)                    ,
    msg3            char (40)                    ,
    msg4            char (40)                    ,
    totanl          integer                      ,
    confirma        char (01)                    ,
    socntzcod       like datmsrvre.socntzcod     ,
    atdorgsrvnum    like datmsrvre.atdorgsrvnum  ,
    atdorgsrvano    like datmsrvre.atdorgsrvano  ,
    socntzdes       like datksocntz.socntzdes    ,
    c24pbmcod       like datrsrvpbm.c24pbmcod    ,
    ciaempcod       like datmservico.ciaempcod   ,    #PSI 205206
    itaciacod       like datrligitaaplitm.itaciacod
 end record

 define l_retorno      smallint,               #PSI 202720
        l_mensagem     char(80),               #PSI 202720
        l_tpdocto      char(15),               #PSI 202720
        l_txt_cartao   char(28)                #PSI 202720
 define l_succod    like datrservapol.succod   , #PSI 205206
        l_ramcod    like datrservapol.ramcod   ,
        l_aplnumdig like datrservapol.aplnumdig,
        l_itmnumdig like datrservapol.itmnumdig,
        l_edsnumref like datrservapol.edsnumref,
        l_azlaplcod like datkazlapl.azlaplcod,
        l_doc_handle integer,
        l_kmlimite  char(3),
        l_kmqtde    char(3),
        l_kmlimiteaux integer

 define lr_retorno record
         pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
         socqlmqtd     like datkitaasipln.socqlmqtd    ,
         erro          integer,
         mensagem      char(50)
  end record

 let int_flag = false
 initialize d_ctb12m03.*   to null
 initialize ws.*           to null
 initialize lr_retorno.*   to null

  let l_succod    = null
  let l_ramcod    = null
  let l_aplnumdig = null
  let l_itmnumdig = null
  let l_edsnumref = null
  let l_azlaplcod  = null
  let l_doc_handle = null
  let l_kmlimite   = null
  let l_kmlimiteaux = null
  let l_kmqtde     = null

 let l_retorno = null                          #PSI 202720
 let l_mensagem = null                         #PSI 202720
 let l_txt_cartao = null                       #PSI 202720
 let l_tpdocto = null                          #PSI 202720

 if param.atdsrvnum is not null and
    param.atdsrvano is not null then
    let k_ctb12m03.atdsrvnum = param.atdsrvnum
    let k_ctb12m03.atdsrvano = param.atdsrvano
 end if

 input by name k_ctb12m03.atdsrvnum,
               k_ctb12m03.atdsrvano  without defaults

      before field atdsrvnum
         display by name k_ctb12m03.atdsrvnum  attribute (reverse)

      after  field atdsrvnum
         display by name k_ctb12m03.atdsrvnum

         if k_ctb12m03.atdsrvnum   is null   then
            error "Informe o numero do servico!"
            next field atdsrvnum
         end if

      before field atdsrvano
         display by name k_ctb12m03.atdsrvano  attribute (reverse)

      after  field atdsrvano
         display by name k_ctb12m03.atdsrvano

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdsrvnum
         end if

         if k_ctb12m03.atdsrvano   is null   then
            error "Informe o ano do servico!"
            next field atdsrvano
         end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    error "Operacao cancelada!"
    clear form
    initialize k_ctb12m03.* to null
    initialize d_ctb12m03.* to null
    return d_ctb12m03.atdsrvnum, d_ctb12m03.atdsrvano
 end if

 let d_ctb12m03.atdsrvnum = k_ctb12m03.atdsrvnum
 let d_ctb12m03.atdsrvano = k_ctb12m03.atdsrvano

 select datmservico.atdsrvorg ,
        datmservico.nom       ,
        datmservico.cornom    ,
        datmservico.corsus    ,
        datmservico.vclcoddig ,
        datmservico.vcldes    ,
        datmservico.vclanomdl ,
        datmservico.vcllicnum ,
        datmservico.vclcorcod ,
        datmservico.atddat    ,
        datmservico.atdhor    ,
        datmservico.funmat    ,
        datmservico.asitipcod ,
        datmservico.atddatprg ,
        datmservico.atdhorprg ,
        datmservico.atdhorpvt ,
        datmservico.pgtdat    ,
        datmservico.atdcstvlr ,
        datmservico.atdlibdat ,
        datmservico.atdlibhor ,
        datmservico.atddfttxt ,
        datmservico.ciaempcod ,    #PSI 205206
        datmservicocmp.sindat ,
        datmservicocmp.bocnum ,
        datmservicocmp.bocemi
   into d_ctb12m03.atdsrvorg  ,
        d_ctb12m03.nom        ,
        d_ctb12m03.cornom     ,
        d_ctb12m03.corsus     ,
        d_ctb12m03.vclcoddig  ,
        d_ctb12m03.vcldes     ,
        d_ctb12m03.vclanomdl  ,
        d_ctb12m03.vcllicnum  ,
        ws.vclcorcod          ,
        ws.atddat             ,
        ws.atdhor             ,
        ws.funmat             ,
        ws.asitipcod          ,
        ws.atddatprg          ,
        ws.atdhorprg          ,
        ws.atdhorpvt          ,
        ws.pgtdat             ,
        d_ctb12m03.atdcstvlr  ,
        ws.atdlibdat          ,
        ws.atdlibhor          ,
        ws.atddfttxt          ,
        ws.ciaempcod          ,   #PSI 205206
        ws.sindat             ,
        ws.bocnum             ,
        ws.bocemi
   from datmservico, outer datmservicocmp
  where datmservico.atdsrvnum    = d_ctb12m03.atdsrvnum    and
        datmservico.atdsrvano    = d_ctb12m03.atdsrvano    and
        datmservicocmp.atdsrvnum = datmservico.atdsrvnum   and
        datmservicocmp.atdsrvano = datmservico.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao cadastrado!"
    sleep 2
    clear form
    initialize d_ctb12m03.* to null
    return d_ctb12m03.atdsrvnum, d_ctb12m03.atdsrvano
 end if

 display "/" at 04,13
 display by name d_ctb12m03.atdsrvorg

 let d_ctb12m03.srvtipabvdes = "NAO PREV."
 select srvtipabvdes
   into d_ctb12m03.srvtipabvdes
   from datksrvtip
  where atdsrvorg = d_ctb12m03.atdsrvorg

 if d_ctb12m03.atdsrvorg = 10  or
    d_ctb12m03.atdsrvorg = 11  or
    d_ctb12m03.atdsrvorg =  8  then
    error "Consulta de ", d_ctb12m03.srvtipabvdes clipped, " nao disponivel!"
    sleep 2
    clear form
    initialize d_ctb12m03.* to null
    return d_ctb12m03.atdsrvnum, d_ctb12m03.atdsrvano
 end if

 #PSI 205206
 #Buscar a descricao da empresa do servico
 call cty14g00_empresa (1, ws.ciaempcod)
      returning l_retorno,
                l_mensagem,
                d_ctb12m03.empresa
 if l_retorno <> 1 then
    error l_mensagem
 end if

 # verifica empresas que temos que buscar o limite de quilometragem
  case ws.ciaempcod
    # contida no XML na tag: APOLICE/ASSISTENCIA/GUINCHO/KMLIMITE.
    when 35
        #descobrir a apolice do servico
    call ctd07g02_busca_apolice_servico(1,
                                        d_ctb12m03.atdsrvnum,
                                        d_ctb12m03.atdsrvano)
        returning l_retorno,
                  l_mensagem,
                  l_succod,
                  l_ramcod,
                  l_aplnumdig,
                  l_itmnumdig,
                  l_edsnumref
    if l_retorno = 1 then
        #descobrir o código para busca do XML
        call ctd02g01_azlaplcod (l_succod,
                                 l_ramcod,
                                 l_aplnumdig,
                                 l_itmnumdig,
                                 l_edsnumref)
             returning l_retorno,
                       l_mensagem,
                       l_azlaplcod
        if l_retorno = 1 then
           #descobrir o doc_handle para busca do XML
           call ctd02g00_agrupaXML (l_azlaplcod)
                returning l_doc_handle
           #com o doc_handle conseguimos localizar um item do XML de uma
           # apolice da Azul

           ---> Buscar Limites da Azul
           call cts49g00_clausulas(l_doc_handle)
                returning l_kmlimite,
                          l_kmqtde

           #calcular ida e volta
           let l_kmlimiteaux = l_kmlimite
           let l_kmlimiteaux = l_kmlimiteaux * 2

           if l_kmlimiteaux is null or l_kmlimiteaux = 0 then
           			let d_ctb12m03.limite = "ATENCAO: APOLICE SEM LIMITE DE QUILOMETRAGEM"
           else
           			let d_ctb12m03.limite = "ATENCAO: LIMITE QUILOMETRICO DE ",
                                   l_kmlimiteaux using "<<<<<#", "KM TOTAIS."
           end if

        end if
        #se retorno diferente de 1, nao conseguiremos encontrar XML
     end if
     #se retorno diferente de 1, pode ser apolice sem documento
     # entao nao temos como encontrar o XML

    when 84
        call ctb25m01_busca_quilometragem_itau(param.atdsrvnum,
                                               param.atdsrvano)
            returning lr_retorno.pansoclmtqtd,
                      lr_retorno.socqlmqtd,
                      lr_retorno.erro,
                      lr_retorno.mensagem

          #calcular ida e volta
	   let l_kmlimiteaux = lr_retorno.socqlmqtd
	   let l_kmlimiteaux = l_kmlimiteaux * 2
		let d_ctb12m03.limite = "ATENCAO: LIMITE QUILOMETRICO DE ",
                                   l_kmlimiteaux using "<<<<<#", "KM TOTAIS."


 end case

#se nao carregou limite por qq motivo, preencher com ----
 if d_ctb12m03.limite is null then
    let d_ctb12m03.limite = "---------------------------------------------"
 end if

 #fim PSI 205206

#--------------------------------------------------------------------
# Informacoes do local da ocorrencia
#--------------------------------------------------------------------
 call ctx04g00_local_completo(d_ctb12m03.atdsrvnum,
                              d_ctb12m03.atdsrvano,
                              1)
                    returning a_ctb12m03[1].lclidttxt   ,
                              a_ctb12m03[1].lgdtip      ,
                              a_ctb12m03[1].lgdnom      ,
                              a_ctb12m03[1].lgdnum      ,
                              a_ctb12m03[1].lclbrrnom   ,
                              a_ctb12m03[1].brrnom      ,
                              a_ctb12m03[1].cidnom      ,
                              a_ctb12m03[1].ufdcod      ,
                              a_ctb12m03[1].lclrefptotxt,
                              a_ctb12m03[1].endzon      ,
                              a_ctb12m03[1].lgdcep      ,
                              a_ctb12m03[1].lgdcepcmp   ,
                              a_ctb12m03[1].dddcod      ,
                              a_ctb12m03[1].lcltelnum   ,
                              a_ctb12m03[1].lclcttnom   ,
                              a_ctb12m03[1].c24lclpdrcod,
                              ws.sqlcode,
                              a_ctb12m03[1].endcmp

 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 call cts06g10_monta_brr_subbrr(a_ctb12m03[1].brrnom,
                                a_ctb12m03[1].lclbrrnom)
      returning a_ctb12m03[1].lclbrrnom

 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    initialize d_ctb12m03.* to null
    return d_ctb12m03.atdsrvnum, d_ctb12m03.atdsrvano
 end if

 let a_ctb12m03[1].lgdtxt = a_ctb12m03[1].lgdtip clipped, " ",
                            a_ctb12m03[1].lgdnom clipped, " ",
                            a_ctb12m03[1].lgdnum using "<<<<#", " ",
                            a_ctb12m03[1].endcmp clipped

#--------------------------------------------------------------------
# Dados da Ligacao
#--------------------------------------------------------------------
 #PSI 202720
 #verifica tipo de documento utilizado no servico
 call cts20g11_identifica_tpdocto(d_ctb12m03.atdsrvnum,
                                  d_ctb12m03.atdsrvano)
      returning l_tpdocto

 if l_tpdocto = "SAUDE" then
    #se documento saude - é do cartao saude, entao buscar ramo na
    # tabela de apolices do saude
    call cts20g10_cartao(2,
                         d_ctb12m03.atdsrvnum,
                         d_ctb12m03.atdsrvano)
         returning l_retorno,
                   l_mensagem,
                   ws.succod,
                   ws.ramcod,
                   ws.aplnumdig,
                   ws.crtnum
    if l_retorno = 1 then
       #encontrou cartao saude - formata cartao
       let g_documento.crtsaunum    = ws.crtnum
       let l_txt_cartao = cts20g16_formata_cartao(ws.crtnum)
       let d_ctb12m03.doctxt = "Cartao: ", l_txt_cartao
    end if
 else
    #if ws.succod    is not null  and
    #   ws.ramcod    is not null  and
    #   ws.aplnumdig is not null  and
    #   ws.itmnumdig is not null  then
    if l_tpdocto = "APOLICE" then
       #obter apolice
       call cts20g13_obter_apolice(d_ctb12m03.atdsrvnum,
                                   d_ctb12m03.atdsrvano)
            returning l_retorno,
                      l_mensagem,
                      ws.aplnumdig,
                      ws.succod,
                      ws.ramcod,
                      ws.itmnumdig

       let g_documento.succod    = ws.succod
       let g_documento.ramcod    = ws.ramcod
       let g_documento.aplnumdig = ws.aplnumdig
       let g_documento.itmnumdig = ws.itmnumdig
       let d_ctb12m03.doctxt = "Apolice.: ", ws.succod    using "###&&" , " ", #using "&&"        , " ", # Projeto Succod
                                             ws.ramcod    using "&&&&"      , " ",
                                             ws.aplnumdig using "<<<<<<<& &"

    else
       #se não é cartão, nem apolice - preciso do numero da ligação
       let ws.lignum = cts20g00_servico(d_ctb12m03.atdsrvnum, d_ctb12m03.atdsrvano)

       #busca proposta, contrato ou pac
       call cts20g01_docto(ws.lignum) returning ws.succod,
                                                ws.ramcod,
                                                ws.aplnumdig,
                                                ws.itmnumdig,
                                                ws.edsnumref,
                                                ws.prporg,
                                                ws.prpnumdig,
                                                ws.fcapacorg,
                                                ws.fcapacnum,
                                                ws.itaciacod

       #if ws.prporg    is not null  and
       #   ws.prpnumdig is not null  then
       if l_tpdocto = "PROPOSTA" then
          let g_documento.prporg    = ws.prporg
          let g_documento.prpnumdig = ws.prpnumdig
          let d_ctb12m03.doctxt = "Proposta: ", ws.prporg    using "&&"      , " ",
                                                ws.prpnumdig using "<<<<<<<&"
       else
          if ws.fcapacorg is not null  and
             ws.fcapacnum is not null  then
             let d_ctb12m03.doctxt = "PAC.....: ", ws.fcapacorg using "&&", " ",
                                                   ws.fcapacnum using "<<<<<<<&"
          else
             let d_ctb12m03.doctxt    = "** LAUDO EM BRANCO **"
          end if
       end if
    end if
 end if


 select c24astcod, ligcvntip,
        c24solnom
   into d_ctb12m03.c24astcod,
        ws.ligcvntip,
        d_ctb12m03.c24solnom
   from datmligacao
  where lignum  =  ws.lignum

#-----------------------  CONVENIO  ------------------------

 select cpodes into d_ctb12m03.cvnnom
   from iddkdominio
  where cponom  =  "ligcvntip" and
        cpocod  =  ws.ligcvntip

#-----------------  DESCRICAO DO ASSUNTO  ------------------

 call c24geral8(d_ctb12m03.c24astcod)
      returning d_ctb12m03.c24astdes

#-----------------  DESCRICAO DA COR  ----------------------

 select cpodes into d_ctb12m03.vclcordes
   from iddkdominio
  where cponom  = "vclcorcod"  and
        cpocod  = ws.vclcorcod

#------------------  NOME DO FUNCIONARIO  ------------------

 let ws.funnom = "** NAO CADASTRADO **"
 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = 1
    and funmat  =  ws.funmat

 let d_ctb12m03.atdlibtxt = ws.atddat                 clipped, " " ,
                            ws.atdhor                 clipped, " " ,
                            upshift(ws.dptsgl)        clipped, " " ,
                            ws.funmat using "&&&&&&"  clipped, " " ,
                            upshift(ws.funnom)        clipped, "  ",
                            ws.atdlibdat              clipped, " " ,
                            ws.atdlibhor

#-------------------  NUMERO DA O.P. ----------------------

 select dbsmopg.socopgnum,
        dbsmopg.socfatentdat
   into d_ctb12m03.socopgnum,
        ws.socfatentdat
   from dbsmopgitm, dbsmopg
  where dbsmopgitm.atdsrvnum  =  d_ctb12m03.atdsrvnum  and
        dbsmopgitm.atdsrvano  =  d_ctb12m03.atdsrvano  and
        dbsmopgitm.socopgnum  =  dbsmopg.socopgnum     and
        dbsmopg.socopgsitcod  <> 8

 if ws.asitipcod is not null  then
    select asitipdes
      into d_ctb12m03.asitipdes
      from datkasitip
     where asitipcod = ws.asitipcod
 end if

 if ws.atdhorpvt is not null  then
    let d_ctb12m03.tmptxt = "Previsao.: ", ws.atdhorpvt
 else
    let d_ctb12m03.tmptxt = "Program..: ", ws.atddatprg, " - ", ws.atdhorprg
 end if

#-------------------  DADOS COMPLEMENTARES RE -------------
 if d_ctb12m03.atdsrvorg  =  9   then  #--> SOCORRO RE
    select socntzcod, atdorgsrvnum, atdorgsrvano
      into ws.socntzcod, ws.atdorgsrvnum, ws.atdorgsrvano
      from datmsrvre
     where atdsrvnum  =  d_ctb12m03.atdsrvnum
       and atdsrvano  =  d_ctb12m03.atdsrvano

    if sqlca.sqlcode = 0 then
       select socntzdes
         into ws.socntzdes
         from datksocntz
        where socntzcod = ws.socntzcod

       select c24pbmcod
         into ws.c24pbmcod
         from datrsrvpbm
        where atdsrvnum    = d_ctb12m03.atdsrvnum
          and atdsrvano    = d_ctb12m03.atdsrvano
          and c24pbminforg = 1
          and c24pbmseq    = 1

       let d_ctb12m03.livre1 = "Natureza.:  ", ws.socntzcod using "#&",
                               " ", ws.socntzdes
       let d_ctb12m03.livre2 = "Problema.: ", ws.c24pbmcod using "##&",
                               " ", ws.atddfttxt
       if ws.atdorgsrvnum is not null then
          let d_ctb12m03.livre2[49,76] = "Servico Orig.: 09/",
                                         ws.atdorgsrvnum using "&&&&&&&","-",
                                         ws.atdorgsrvano using "&&"
       end if
    end if
 end if

 #------ FORMATA DADOS PARA REMOCAO POR SINISTRO E SOCORRO ------

 if d_ctb12m03.atdsrvorg  =  4   then  #--> Sinistro
    let d_ctb12m03.livre1 = "Sinistro.: ", ws.sindat,
                            " B.O: ", ws.bocnum using "#####", "/", ws.bocemi
 else
    if d_ctb12m03.atdsrvorg  =  1   then  #--> Socorro
       let d_ctb12m03.livre1 = "Problema.: ", ws.atddfttxt
    end if
 end if

 if ws.pgtdat is null  then
    if ws.socfatentdat is not null  then
       let d_ctb12m03.opgtxt = "Entrega..:"
       let d_ctb12m03.pgtdattxt = ws.socfatentdat
    end if
 else
    if ws.socfatentdat is not null  then
       let d_ctb12m03.opgtxt = "Entr/Pagt:"
       let d_ctb12m03.pgtdattxt = ws.socfatentdat, " ", ws.pgtdat
    else
       let d_ctb12m03.opgtxt = "Pagamento:"
       let d_ctb12m03.pgtdattxt = ws.pgtdat
    end if
 end if

 display by name d_ctb12m03.*
 display by name d_ctb12m03.empresa attribute(reverse)  #PSI 205206
 if l_azlaplcod is not null then
    #se encontrou apolice da azul e buscou limite
    display by name d_ctb12m03.limite attribute(reverse)
 end if
 display by name a_ctb12m03[1].lgdtxt          ,
                 a_ctb12m03[1].lclbrrnom       ,
                 a_ctb12m03[1].cidnom          ,
                 a_ctb12m03[1].ufdcod          ,
                 a_ctb12m03[1].lclrefptotxt    ,
                 a_ctb12m03[1].endzon          ,
                 a_ctb12m03[1].dddcod          ,
                 a_ctb12m03[1].lcltelnum       ,
                 a_ctb12m03[1].lclcttnom

 #------ VERIFICA SERVICOS RELACIONADOS SO PARA RE --------------
 if d_ctb12m03.atdsrvorg  =  9   then
    call ctb12m12(d_ctb12m03.atdsrvnum, d_ctb12m03.atdsrvano)
 end if

 if d_ctb12m03.atdcstvlr is not null  and
    ws.socfatentdat      is null      and
    ws.pgtdat            is null      then
    error " Ja' existe acerto de valor para este servico!"
 end if

 # VERIFICA SE SERVICO JA ESTEVE EM ANALISE
 declare c_datmsrvanlhst cursor for
  select c24evtcod, caddat
    from datmsrvanlhst
   where atdsrvnum    =  d_ctb12m03.atdsrvnum
     and atdsrvano    =  d_ctb12m03.atdsrvano
     and c24evtcod    <> 0
     and srvanlhstseq =  1

 let ws.totanl = 0   # total de analise do servico

 foreach c_datmsrvanlhst into ws.c24evtcod, ws.caddat

    select c24fsecod, cadmat, srvanlhstseq
      into ws.c24fsecod, ws.cadmat, ws.srvanlhstseq
      from datmsrvanlhst
     where atdsrvnum    =  d_ctb12m03.atdsrvnum
       and atdsrvano    =  d_ctb12m03.atdsrvano
       and c24evtcod    =  ws.c24evtcod
       and srvanlhstseq = (select max(srvanlhstseq)
                             from datmsrvanlhst
                            where atdsrvnum  =  d_ctb12m03.atdsrvnum
                              and atdsrvano  =  d_ctb12m03.atdsrvano
                              and c24evtcod  =  ws.c24evtcod)

    if ws.c24fsecod <> 2  and        # 2- ok analisado e pago
       ws.c24fsecod <> 4  then       # 4- nao procede
       if ws.totanl = 0 then
          let ws.totanl = 1
          let ws.c24evtcod_svl = ws.c24evtcod
          let ws.c24fsecod_svl = ws.c24fsecod
          let ws.cadmat_svl    = ws.cadmat
          let ws.caddat_svl    = ws.caddat
       else
          if ws.caddat > ws.caddat_svl then
             let ws.c24evtcod_svl = ws.c24evtcod
             let ws.c24fsecod_svl = ws.c24fsecod
             let ws.cadmat_svl    = ws.cadmat
             let ws.caddat_svl    = ws.caddat
          end if
          let ws.totanl = ws.totanl + 1
       end if
    else
       continue foreach
    end if

 end foreach

 if ws.totanl > 0   then
    initialize ws.c24evtrdzdes, ws.c24fsedes to null
    select c24evtrdzdes
      into ws.c24evtrdzdes
      from datkevt
     where datkevt.c24evtcod = ws.c24evtcod_svl

    select c24fsedes
      into ws.c24fsedes
      from datkfse
     where datkfse.c24fsecod = ws.c24fsecod_svl

    select funnom
      into ws.funnom_hst
      from isskfunc
     where empcod = 1
       and funmat = ws.cadmat_svl

    let ws.msg1 = "ULT.ANALISE : ",ws.c24evtrdzdes,"."
    let ws.msg2 = "FASE ...... : ",ws.c24fsedes,"."
    let ws.msg3 = "ANALISTA... : ",ws.funnom_hst,"."
    if ws.totanl > 1 then
       let ws.msg4 = "ATENCAO:  EXISTEM ", ws.totanl using "&&"," ANALISES"

       call cts08g01("A","N", ws.msg1, ws.msg2, ws.msg3, ws.msg4)
            returning ws.confirma
    else
       if ws.c24fsecod = 1 or ws.c24fsecod =3 then #EM ANALISE
          let ws.msg4 = "ATENCAO:  DESEJA LIBERAR ANALISE?"
          call cts08g01("C","S", ws.msg1, ws.msg2, ws.msg3, ws.msg4)
               returning ws.confirma
          if ws.confirma = "S" then
             let ws.srvanlhstseq = ws.srvanlhstseq + 1
             insert into datmsrvanlhst (atdsrvnum,
                                        atdsrvano,
                                        srvanlhstseq,
                                        c24evtcod,
                                        c24fsecod,
                                        caddat,
                                        cademp,
                                        cadmat
                                        )
                              values   (d_ctb12m03.atdsrvnum,
                                        d_ctb12m03.atdsrvano,
                                        ws.srvanlhstseq,
                                        ws.c24evtcod,
                                        2,
                                        TODAY,
                                        g_issk.empcod,
                                        g_issk.funmat
                                       )
          end if
       else
          let ws.msg4 = ""

          call cts08g01("A","N", ws.msg1, ws.msg2, ws.msg3, ws.msg4)
               returning ws.confirma
       end if
    end if
 end if

 return d_ctb12m03.atdsrvnum, d_ctb12m03.atdsrvano

end function  ###  seleciona_ctb12m03

#-----------------------------------------------------------
 function ligacoes_ctb12m03(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define ws          record
    lignum          like datrligsrv.lignum       ,
    succod          like datrligapol.succod      ,
    ramcod          like datrligapol.ramcod      ,
    aplnumdig       like datrligapol.aplnumdig   ,
    itmnumdig       like datrligapol.itmnumdig   ,
    crtnum          like datrsrvsau.crtnum       ,     #PSI 202720
    edsnumref       like datrligapol.edsnumref   ,
    prporg          like datrligprp.prporg       ,
    prpnumdig       like datrligprp.prpnumdig    ,
    fcapacorg       like datrligpac.fcapacorg    ,
    fcapacnum       like datrligpac.fcapacnum    ,
    itaciacod       like datrligitaaplitm.itaciacod
 end record

 define l_retorno      smallint,                #PSI 202720
        l_mensagem     char(80),                #PSI 202720
        l_tpdocto      char(15)                 #PSI 202720

 let int_flag = false
 initialize ws.*           to null
 let l_retorno = null
 let l_mensagem = null
 let l_tpdocto = null

 #PSI 202720
 #verifica tipo de documento utilizado no servico
 call cts20g11_identifica_tpdocto(param.atdsrvnum,
                                  param.atdsrvano)
      returning l_tpdocto

 if l_tpdocto = "SAUDE" then
    #se documento saude - é do cartao saude, entao buscar ramo na
    # tabela de apolices do saude
    call cts20g10_cartao(2,
                         param.atdsrvnum,
                         param.atdsrvano)
         returning l_retorno,
                   l_mensagem,
                   ws.succod,
                   ws.ramcod,
                   ws.aplnumdig,
                   ws.crtnum
    if l_retorno <> 1 then
       error "Problemas ao buscar cartao saude do servico"
    end if
 else
    let ws.lignum = cts20g00_servico(param.atdsrvnum, param.atdsrvano)

    call cts20g01_docto(ws.lignum) returning ws.succod,
                                             ws.ramcod,
                                             ws.aplnumdig,
                                             ws.itmnumdig,
                                             ws.edsnumref,
                                             ws.prporg,
                                             ws.prpnumdig,
                                             ws.fcapacorg,
                                             ws.fcapacnum,
                                             ws.itaciacod
 end if

 if (ws.succod    is not null   and
     ws.ramcod    is not null   and
     ws.aplnumdig is not null)  or
    (ws.prporg    is not null   and
     ws.prpnumdig is not null)  or
    (ws.fcapacorg is not null   and
     ws.fcapacnum is not null)  or
    (ws.crtnum    is not null) then             #PSI 202720

     call ctp01m01(ws.succod   , ws.ramcod   ,
                   ws.aplnumdig, ws.itmnumdig,
                   ws.prporg   , ws.prpnumdig,
                   ws.fcapacorg, ws.fcapacnum,
                   ws.crtnum )                   #PSI 202720
 else
    error " Servico sem documento informado!"
 end if

end function  ###  ligacoes_ctb12m03

#-----------------------------------------------------------
 function coordenadas_ctb12m03(param)
#-----------------------------------------------------------

 define param         record
    atdsrvnum          like datmservico.atdsrvnum,
    atdsrvano          like datmservico.atdsrvano
 end record

 define ws           record
   confirma         char (01)
 end record

 define l_cts08g03    record
     lclltt            like datmlcl.lclltt,         # latitude do servico
     lcllgt            like datmlcl.lcllgt,         # longitude do servico
     c24endtip         like datmlcl.c24endtip,      # tipo de endereco se e destino ou local da ocorrencia
     srrltt            like datmservico.srrltt,     # latitude do socorrista
     srrlgt            like datmservico.srrlgt,      # longitude do socorrista
     c24lclpdrcod      like datmlcl.c24lclpdrcod    # tipo da indexação do serviço
 end record

 define param_popup   record
   linha1              char (40),
   linha2              char (40),
   linha3              char (40),
   linha4              char (40)
 end record

 define sql_socorrista char(200)
 define sql_servico    char(200)
 define l_tipo         int


 initialize l_cts08g03 , param_popup to null

 #para trazer as coodernadas do socorrista

     let sql_socorrista = 'select s.srrltt, ',
                                 's.srrlgt ',
                            'from datmservico s ',
                           'where s.atdsrvnum = ?',
                            ' and s.atdsrvano = ?'
     prepare p_lat_socor from sql_socorrista

     declare c_lat_socor cursor for p_lat_socor

     whenever error continue
           open c_lat_socor using param.atdsrvnum,
                                  param.atdsrvano

           fetch c_lat_socor into l_cts08g03.srrltt,
                                  l_cts08g03.srrlgt,
                                  l_cts08g03.c24lclpdrcod

          if l_cts08g03.srrltt is null or l_cts08g03.srrltt  = '' and
             l_cts08g03.srrlgt is null or l_cts08g03.srrlgt  = '' then
                 let param_popup.linha4 = "   Viatura: Coordenadas não Disponiveis"
           else
               let param_popup.linha4 = "Viatura: ",l_cts08g03.srrltt,", ",l_cts08g03.srrlgt
          end if
     whenever error stop

     close c_lat_socor
 #fim da operacao do socorrista

 #para trazer as coodernadas do servico
     let l_cts08g03.lclltt = null
     let l_cts08g03.lcllgt = null
     let sql_servico ='select l.lclltt,',
                            ' l.lcllgt,',
                            ' l.c24lclpdrcod',
                       ' from datmlcl l',
                      ' where l.atdsrvnum = ?',
                        ' and l.atdsrvano = ?',
                        ' and l.c24endtip = ?'

     let l_tipo = 1

     prepare p_lat_srv from sql_servico

     declare c_lat_srv cursor for p_lat_srv

     whenever error continue
            open c_lat_srv using param.atdsrvnum,
                                 param.atdsrvano,
                                 l_tipo     #local do servico

           fetch c_lat_srv into l_cts08g03.lclltt,
                                l_cts08g03.lcllgt,
                                l_cts08g03.c24lclpdrcod

        if (l_cts08g03.lclltt is null or l_cts08g03.lclltt  = '') or
           (l_cts08g03.lcllgt is null or l_cts08g03.lcllgt  = '') then

                  let param_popup.linha2 = "       QTH: Coordenadas não Disponiveis"
           else
                  let param_popup.linha2 = "   QTH: ",l_cts08g03.lclltt,", ",l_cts08g03.lcllgt
           end if
      whenever error stop
      # indexação do serviço
      case l_cts08g03.c24lclpdrcod # PSI 252891
          when 1
                 let param_popup.linha1 = " Indexacao: Por Cidade"
          when 2
                 let param_popup.linha1 = " Indexacao: Por Guia Postal"
          when 3
                 let param_popup.linha1 = " Indexacao: Por Rua"
          when 4
                 let param_popup.linha1 = " Indexacao: Por Bairro"
          when 5
                 let param_popup.linha1 = " Indexacao: Por Sub-bairro"
      end case
      #if (l_cts08g03.c24lclpdrcod == 1)then
      #        let param_popup.linha1 = " Indexacao: Por Cidade"
      #else if (l_cts08g03.c24lclpdrcod == 2)then
      #        let param_popup.linha1 = " Indexacao: Por Guia Postal"
      #     else if (l_cts08g03.c24lclpdrcod == 3)then
      #              let param_popup.linha1 = " Indexacao: Por Rua"
      #          end if
      #     end if
      #end if
      # fim da indexacao


      close c_lat_srv
 # fecha local do servico

 #para trazer as coordenadas do destino
      let l_cts08g03.lclltt = null
      let l_cts08g03.lcllgt = null
      let l_tipo = 2
      whenever error continue

            open c_lat_srv using param.atdsrvnum,
                                 param.atdsrvano,
                                 l_tipo     #destino
           fetch c_lat_srv into l_cts08g03.lclltt,
                                  l_cts08g03.lcllgt

        if (l_cts08g03.lclltt is null or l_cts08g03.lclltt  = '') or
           (l_cts08g03.lcllgt is null or l_cts08g03.lcllgt  = '') then
                    let param_popup.linha3 = "       QTI: Coordenadas não Disponiveis"
           else
                    let param_popup.linha3 = "   QTI: ",l_cts08g03.lclltt,", ",l_cts08g03.lcllgt
           end if
      whenever error stop

      close c_lat_srv
     # fecha destino
      call cts08g01("C","N",param_popup.linha1,
                            param_popup.linha2,
                            param_popup.linha3,
                            param_popup.linha4)
           returning ws.confirma

      if int_flag then
         let int_flag = "false"
      end if
 end function

