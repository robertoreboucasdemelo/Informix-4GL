#############################################################################
# Nome do Modulo: CTB05m00                                         Wagner   #
#                                                                           #
# Tela de consulta de servico e acerto de valor para RE            Nov/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#---------------------------------------------------------------------------#
#  Analista Resp. : Raji                             OSF : 30155            #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 16/12/2003       #
#  Objetivo       : Substituir o codigo de pesquisa de bloqueio de servico  #
#                   pela chamada da funcao de pesquisa ctb00g01_srvanl.     #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 05/10/2006  PSI 202720   Priscila     Implementar cartao saude            #
# 13/08/2009  PSI 244236   Burini       Inclusão do Sub-Dairro              #
#############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"

 define k_ctb05m00   record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

#-----------------------------------------------------------
 function ctb05m00(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define ws           record
    atdcstvlr        like datmservico.atdcstvlr,
    time             char (11),
    hoje             char (10),
    hora             char (05)
 end record

 initialize k_ctb05m00.* to null

 let ws.hoje = today
 let ws.time = time
 let ws.hora = ws.time[1,5]

 let int_flag = false

 open window ctb05m00 at 04,02 with form "ctb05m00"
 display "/" at 02,13
 display "-" at 02,21
 display "-" at 04,21

 menu "SERVICO"

    before menu
           hide option all
#WWWX      if get_niv_mod(g_issk.prgsgl,"ctb05m00")  then        ## NIVEL 1
#WWWX         if g_issk.acsnivcod >= g_issk.acsnivcns  then
                 show option "Seleciona","Prestador",
                             "Historico","pesQuisa","Imprime" ,
                             "Acompanhamento","liGacoes","Ref_local"
#WWWX         end if

#WWWX         if g_issk.prgsgl <> "ctg8"  then
#WWWX            if g_issk.acsnivcod >= g_issk.acsnivatl  then   ## NIVEL 6
                    show option "Valor"
#WWWX            end if

                 if g_issk.acsnivcod >= 8  then                  ## NIVEL 8
                    show option "Libera"
                 end if
#WWWX         end if
#WWWX      end if

           show option "Encerra"

    command key ("S") "Seleciona"
                      "Seleciona servico para consulta"
            clear form
            call seleciona_ctb05m00(param.*) returning k_ctb05m00.*

            if k_ctb05m00.atdsrvnum is not null  then
               next option "Prestador"
            else
               error "Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key ("P") "Prestador"
                     "Prestador acionado"
           if k_ctb05m00.atdsrvnum is not null then
              call cts20m05(k_ctb05m00.atdsrvnum, k_ctb05m00.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("V") "Valor"
                     "Acerta valor do servico selecionado"
           if k_ctb05m00.atdsrvnum is not null then
              call ctb05m15(k_ctb05m00.atdsrvnum, k_ctb05m00.atdsrvano)
              select datmservico.atdcstvlr
                into ws.atdcstvlr
                from datmservico
               where datmservico.atdsrvnum = k_ctb05m00.atdsrvnum
                 and datmservico.atdsrvano = k_ctb05m00.atdsrvano

              display ws.atdcstvlr to atdcstvlr
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("H") "Historico"
                     "Exibe historico do servico selecionado"
           if k_ctb05m00.atdsrvnum is not null  then
              call cts10n00(k_ctb05m00.atdsrvnum, k_ctb05m00.atdsrvano,
                            g_issk.funmat       , ws.hoje  , ws.hora  )
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("Q") "pesQuisa"
                     "Pesquisa por data, tipo, placa, ou nome do solicitante"
              call ctb12m07() returning k_ctb05m00.atdsrvnum,
                                        k_ctb05m00.atdsrvano
              if k_ctb05m00.atdsrvnum  is not null   and
                 k_ctb05m00.atdsrvano  is not null   then
                 error "Selecione e tecle ENTER!"
                 next option "Seleciona"
              else
                 error " Nenhum servico foi selecionado!"
              end if

   command key ("A") "Acompanhamento"
                     "Acompanhamento do servico selecionado"
           if k_ctb05m00.atdsrvnum is not null then
              call cts00m11(k_ctb05m00.atdsrvnum, k_ctb05m00.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("G") "liGacoes"
                     "Ligacoes referente a apolice deste servico"
           if k_ctb05m00.atdsrvnum is not null then
              call ligacoes_ctb05m00(k_ctb05m00.atdsrvnum, k_ctb05m00.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("R") "Ref_local"
                     "Referencia do local do socorro"
           if k_ctb05m00.atdsrvnum is not null then
              call cts00m23(k_ctb05m00.atdsrvnum, k_ctb05m00.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("I") "Imprime"
                     "Imprime servico selecionado"
           if k_ctb05m00.atdsrvnum is not null then
              call ctr03m02(k_ctb05m00.atdsrvnum, k_ctb05m00.atdsrvano)
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key ("L") "Libera"
                     "Libera servico selecionado"
           if k_ctb05m00.atdsrvnum is not null then
              call ctb12m08(k_ctb05m00.atdsrvnum, k_ctb05m00.atdsrvano)
              next option "Seleciona"
           else
              error "Nenhum registro selecionado!"
              next option "Seleciona"
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
 end menu

 close window ctb05m00

end function  ###  ctb05m00

#-----------------------------------------------------------
 function seleciona_ctb05m00(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define d_ctb05m00  record
    atdsrvorg       like datmservico.atdsrvorg   ,
    atdsrvnum       like datmservico.atdsrvnum   ,
    atdsrvano       like datmservico.atdsrvano   ,
    srvtipabvdes    like datksrvtip.srvtipabvdes ,
    c24solnom       like datmligacao.c24solnom   ,
    nom             like datmservico.nom         ,
    doctxt          char (28)                    ,
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

 define a_ctb05m00    array[1] of record
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (80)                    ,
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
    itaciacod       like datrligitaaplitm.itaciacod   
 end record

 define l_retorno      smallint,               #PSI 202720
        l_mensagem     char(80),               #PSI 202720
        l_tpdocto      char(15),               #PSI 202720
        l_txt_cartao   char(28)                #PSI 202720

 let int_flag = false
 initialize d_ctb05m00.*   to null
 initialize ws.*           to null

 let l_retorno = null                          #PSI 202720
 let l_mensagem = null                         #PSI 202720
 let l_txt_cartao = null                       #PSI 202720
 let l_tpdocto = null                          #PSI 202720

 if param.atdsrvnum is not null and
    param.atdsrvano is not null then
    let k_ctb05m00.atdsrvnum = param.atdsrvnum
    let k_ctb05m00.atdsrvano = param.atdsrvano
 end if

 input by name k_ctb05m00.atdsrvnum,
               k_ctb05m00.atdsrvano  without defaults

      before field atdsrvnum
         display by name k_ctb05m00.atdsrvnum  attribute (reverse)

      after  field atdsrvnum
         display by name k_ctb05m00.atdsrvnum

         if k_ctb05m00.atdsrvnum   is null   then
            error "Informe o numero do servico!"
            next field atdsrvnum
         end if

      before field atdsrvano
         display by name k_ctb05m00.atdsrvano  attribute (reverse)

      after  field atdsrvano
         display by name k_ctb05m00.atdsrvano

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdsrvnum
         end if

         if k_ctb05m00.atdsrvano   is null   then
            error "Informe o ano do servico!"
            next field atdsrvano
         end if
         select atdsrvorg
           into d_ctb05m00.atdsrvorg
           from datmservico
          where atdsrvnum = k_ctb05m00.atdsrvnum
            and atdsrvano = k_ctb05m00.atdsrvano

         if sqlca.sqlcode = notfound then
            error " Servico nao encontrado!"
            next field atdsrvano
         else
            if d_ctb05m00.atdsrvorg <> 9  and
               d_ctb05m00.atdsrvorg <> 13 then
               error " Consulta disponivel somente para servicos de RE-Ramos Elementares!"
               next field atdsrvano
            end if
         end if
         display "/" at 04,13
         display by name d_ctb05m00.atdsrvorg

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    error "Operacao cancelada!"
    clear form
    initialize k_ctb05m00.* to null
    initialize d_ctb05m00.* to null
    return d_ctb05m00.atdsrvnum, d_ctb05m00.atdsrvano
 end if

 let d_ctb05m00.atdsrvnum = k_ctb05m00.atdsrvnum
 let d_ctb05m00.atdsrvano = k_ctb05m00.atdsrvano

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
        datmservicocmp.sindat ,
        datmservicocmp.bocnum ,
        datmservicocmp.bocemi
   into d_ctb05m00.atdsrvorg  ,
        d_ctb05m00.nom        ,
        d_ctb05m00.cornom     ,
        d_ctb05m00.corsus     ,
        d_ctb05m00.vclcoddig  ,
        d_ctb05m00.vcldes     ,
        d_ctb05m00.vclanomdl  ,
        d_ctb05m00.vcllicnum  ,
        ws.vclcorcod          ,
        ws.atddat             ,
        ws.atdhor             ,
        ws.funmat             ,
        ws.asitipcod          ,
        ws.atddatprg          ,
        ws.atdhorprg          ,
        ws.atdhorpvt          ,
        ws.pgtdat             ,
        d_ctb05m00.atdcstvlr  ,
        ws.atdlibdat          ,
        ws.atdlibhor          ,
        ws.atddfttxt          ,
        ws.sindat             ,
        ws.bocnum             ,
        ws.bocemi
   from datmservico, outer datmservicocmp
  where datmservico.atdsrvnum    = d_ctb05m00.atdsrvnum    and
        datmservico.atdsrvano    = d_ctb05m00.atdsrvano    and
        datmservicocmp.atdsrvnum = datmservico.atdsrvnum   and
        datmservicocmp.atdsrvano = datmservico.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao cadastrado!"
    sleep 2
    clear form
    initialize d_ctb05m00.* to null
    return d_ctb05m00.atdsrvnum, d_ctb05m00.atdsrvano
 end if

 let d_ctb05m00.srvtipabvdes = "NAO PREV."
 select srvtipabvdes
   into d_ctb05m00.srvtipabvdes
   from datksrvtip
  where atdsrvorg = d_ctb05m00.atdsrvorg

 #PSI 202720 - origem nunca sera 10, 11 ou 8 pois o input permite apenas que
 # seja selecionado serviços com origem 9 e 13
 #if d_ctb05m00.atdsrvorg = 10  or
 #   d_ctb05m00.atdsrvorg = 11  or
 #   d_ctb05m00.atdsrvorg =  8  then
 #   error "Consulta de ", d_ctb05m00.srvtipabvdes clipped, " nao disponivel!"
 #   sleep 2
 #   clear form
 #   initialize d_ctb05m00.* to null
 #   return d_ctb05m00.atdsrvnum, d_ctb05m00.atdsrvano
 #end if

#--------------------------------------------------------------------
# Informacoes do local da ocorrencia
#--------------------------------------------------------------------
 call ctx04g00_local_completo(d_ctb05m00.atdsrvnum,
                              d_ctb05m00.atdsrvano,
                              1)
                    returning a_ctb05m00[1].lclidttxt   ,
                              a_ctb05m00[1].lgdtip      ,
                              a_ctb05m00[1].lgdnom      ,
                              a_ctb05m00[1].lgdnum      ,
                              a_ctb05m00[1].lclbrrnom   ,
                              a_ctb05m00[1].brrnom      ,
                              a_ctb05m00[1].cidnom      ,
                              a_ctb05m00[1].ufdcod      ,
                              a_ctb05m00[1].lclrefptotxt,
                              a_ctb05m00[1].endzon      ,
                              a_ctb05m00[1].lgdcep      ,
                              a_ctb05m00[1].lgdcepcmp   ,
                              a_ctb05m00[1].dddcod      ,
                              a_ctb05m00[1].lcltelnum   ,
                              a_ctb05m00[1].lclcttnom   ,
                              a_ctb05m00[1].c24lclpdrcod,
                              ws.sqlcode,
                              a_ctb05m00[1].endcmp
                              
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 call cts06g10_monta_brr_subbrr(a_ctb05m00[1].brrnom,
                                a_ctb05m00[1].lclbrrnom)
      returning a_ctb05m00[1].lclbrrnom                               
                              
 if ws.sqlcode <> 0  then
    error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    initialize d_ctb05m00.* to null
    return d_ctb05m00.atdsrvnum, d_ctb05m00.atdsrvano
 end if

 let a_ctb05m00[1].lgdtxt = a_ctb05m00[1].lgdtip clipped, " ",
                            a_ctb05m00[1].lgdnom clipped, " ",
                            a_ctb05m00[1].lgdnum using "<<<<#", " ",
                            a_ctb05m00[1].endcmp clipped

#--------------------------------------------------------------------
# Dados da Ligacao
#--------------------------------------------------------------------

 #PSI 202720
 #verifica tipo de documento utilizado no servico
 call cts20g11_identifica_tpdocto(d_ctb05m00.atdsrvnum,
                                  d_ctb05m00.atdsrvano)
      returning l_tpdocto

 if l_tpdocto = "SAUDE" then
    #se documento saude - é do cartao saude, entao buscar ramo na
    # tabela de apolices do saude
    call cts20g10_cartao(2,
                         d_ctb05m00.atdsrvnum,
                         d_ctb05m00.atdsrvano)
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
       let d_ctb05m00.doctxt = "Cartao: ", l_txt_cartao
    end if
 else
    #if ws.succod    is not null  and
    #   ws.ramcod    is not null  and
    #   ws.aplnumdig is not null  and
    #   ws.itmnumdig is not null  then
    if l_tpdocto = "APOLICE" then
       call cts20g13_obter_apolice(d_ctb05m00.atdsrvnum,
                                   d_ctb05m00.atdsrvano)
            returning l_retorno,
                      l_mensagem,
                      ws.aplnumdig,
                      ws.succod,
                      ws.ramcod,
                      ws.itmnumdig

       let d_ctb05m00.doctxt = "Apolice.: ", ws.succod    using "&&"        , " ",
                                             ws.ramcod    using "&&&&"      , " ",
                                             ws.aplnumdig using "<<<<<<<& &"
    else
       #se não é cartão, nem apolice - preciso do numero da ligação
       let ws.lignum = cts20g00_servico(d_ctb05m00.atdsrvnum, d_ctb05m00.atdsrvano)

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
          let d_ctb05m00.doctxt = "Proposta: ", ws.prporg    using "&&"      , " ",
                                                ws.prpnumdig using "<<<<<<<&"
       else
          if ws.fcapacorg is not null  and
             ws.fcapacnum is not null  then
             let d_ctb05m00.doctxt = "PAC.....: ", ws.fcapacorg using "&&", " ",
                                                   ws.fcapacnum using "<<<<<<<&"
          else
             let d_ctb05m00.doctxt    = "** LAUDO EM BRANCO **"
          end if
       end if
    end if

 end if



 select c24astcod, ligcvntip,
        c24solnom
   into d_ctb05m00.c24astcod,
        ws.ligcvntip,
        d_ctb05m00.c24solnom
   from datmligacao
  where lignum  =  ws.lignum

#-----------------------  CONVENIO  ------------------------

 select cpodes into d_ctb05m00.cvnnom
   from iddkdominio
  where cponom  =  "ligcvntip" and
        cpocod  =  ws.ligcvntip

#-----------------  DESCRICAO DO ASSUNTO  ------------------

 call c24geral8(d_ctb05m00.c24astcod)
      returning d_ctb05m00.c24astdes

#-----------------  DESCRICAO DA COR  ----------------------

 select cpodes into d_ctb05m00.vclcordes
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

 let d_ctb05m00.atdlibtxt = ws.atddat                 clipped, " " ,
                            ws.atdhor                 clipped, " " ,
                            upshift(ws.dptsgl)        clipped, " " ,
                            ws.funmat using "&&&&&&"  clipped, " " ,
                            upshift(ws.funnom)        clipped, "  ",
                            ws.atdlibdat              clipped, " " ,
                            ws.atdlibhor

#-------------------  NUMERO DA O.P. ----------------------

 select dbsmopg.socopgnum,
        dbsmopg.socfatentdat
   into d_ctb05m00.socopgnum,
        ws.socfatentdat
   from dbsmopgitm, dbsmopg
  where dbsmopgitm.atdsrvnum  =  d_ctb05m00.atdsrvnum  and
        dbsmopgitm.atdsrvano  =  d_ctb05m00.atdsrvano  and
        dbsmopgitm.socopgnum  =  dbsmopg.socopgnum     and
        dbsmopg.socopgsitcod  <> 8

 if ws.asitipcod is not null  then
    select asitipdes
      into d_ctb05m00.asitipdes
      from datkasitip
     where asitipcod = ws.asitipcod
 end if

 if ws.atdhorpvt is not null  then
    let d_ctb05m00.tmptxt = "Previsao.: ", ws.atdhorpvt
 else
    let d_ctb05m00.tmptxt = "Program..: ", ws.atddatprg, " - ", ws.atdhorprg
 end if

#-------------------  DADOS COMPLEMENTARES RE -------------
 if d_ctb05m00.atdsrvorg  =  9   then  #--> SOCORRO RE
    select socntzcod, atdorgsrvnum, atdorgsrvano
      into ws.socntzcod, ws.atdorgsrvnum, ws.atdorgsrvano
      from datmsrvre
     where atdsrvnum  =  d_ctb05m00.atdsrvnum
       and atdsrvano  =  d_ctb05m00.atdsrvano

    if sqlca.sqlcode = 0 then
       select socntzdes
         into ws.socntzdes
         from datksocntz
        where socntzcod = ws.socntzcod

       select c24pbmcod
         into ws.c24pbmcod
         from datrsrvpbm
        where atdsrvnum    = d_ctb05m00.atdsrvnum
          and atdsrvano    = d_ctb05m00.atdsrvano
          and c24pbminforg = 1
          and c24pbmseq    = 1

       let d_ctb05m00.livre1 = "Natureza.:  ", ws.socntzcod using "#&",
                               " ", ws.socntzdes
       let d_ctb05m00.livre2 = "Problema.: ", ws.c24pbmcod using "##&",
                               " ", ws.atddfttxt
       if ws.atdorgsrvnum is not null then
          let d_ctb05m00.livre2[49,76] = "Servico Orig.: 09/",
                                         ws.atdorgsrvnum using "&&&&&&&","-",
                                         ws.atdorgsrvano using "&&"
       end if
    end if
 end if

 #------ FORMATA DADOS PARA REMOCAO POR SINISTRO E SOCORRO ------

 #PSI 202720 - origem nunca sera 4 ou 1 pois o input permite apenas que
 # seja selecionado serviços com origem 9 e 13
 #if d_ctb05m00.atdsrvorg  =  4   then  #--> Sinistro
 #   let d_ctb05m00.livre1 = "Sinistro.: ", ws.sindat,
 #                           " B.O: ", ws.bocnum using "#####", "/", ws.bocemi
 #else
 #   if d_ctb05m00.atdsrvorg  =  1   then  #--> Socorro
 #      let d_ctb05m00.livre1 = "Problema.: ", ws.atddfttxt
 #   end if
 #end if

 if ws.pgtdat is null  then
    if ws.socfatentdat is not null  then
       let d_ctb05m00.opgtxt = "Entrega..:"
       let d_ctb05m00.pgtdattxt = ws.socfatentdat
    end if
 else
    if ws.socfatentdat is not null  then
       let d_ctb05m00.opgtxt = "Entr/Pagt:"
       let d_ctb05m00.pgtdattxt = ws.socfatentdat, " ", ws.pgtdat
    else
       let d_ctb05m00.opgtxt = "Pagamento:"
       let d_ctb05m00.pgtdattxt = ws.pgtdat
    end if
 end if

 display by name d_ctb05m00.*
 display by name a_ctb05m00[1].lgdtxt          ,
                 a_ctb05m00[1].lclbrrnom       ,
                 a_ctb05m00[1].cidnom          ,
                 a_ctb05m00[1].ufdcod          ,
                 a_ctb05m00[1].lclrefptotxt    ,
                 a_ctb05m00[1].endzon          ,
                 a_ctb05m00[1].dddcod          ,
                 a_ctb05m00[1].lcltelnum       ,
                 a_ctb05m00[1].lclcttnom

 #------ VERIFICA SERVICOS RELACIONADOS SO PARA RE --------------
 if d_ctb05m00.atdsrvorg  =  9   then
    call ctb12m12(d_ctb05m00.atdsrvnum, d_ctb05m00.atdsrvano)
 end if

 if d_ctb05m00.atdcstvlr is not null  and
    ws.socfatentdat      is null      and
    ws.pgtdat            is null      then
    error " Ja' existe acerto de valor para este servico!"
 end if

 # -- OSF 30155 - Fabrica de Software, Katiucia -- #
 # ---------------------------------------------- #
 # VERIFICA SE SERVICO FASE DO SERVICO EM ANALISE #
 # ---------------------------------------------- #
 call ctb00g01_srvanl ( d_ctb05m00.atdsrvnum
                       ,d_ctb05m00.atdsrvano
                       ,"S" )
      returning ws.totanl
               ,ws.c24evtcod
               ,ws.c24fsecod

 #--------------------------------------------------------------------
 # Obtem documento do servico
 #--------------------------------------------------------------------
       let ws.lignum = cts20g00_servico(d_ctb05m00.atdsrvnum, d_ctb05m00.atdsrvano)

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

       ##Seta número do docto do serviço
       initialize g_documento.* to null
       initialize g_ppt.* to null

       let g_documento.ramcod     = ws.ramcod
       let g_documento.succod     = ws.succod
       let g_documento.aplnumdig  = ws.aplnumdig
       let g_documento.itmnumdig  = ws.itmnumdig
       let g_documento.prporg     = ws.prporg
       let g_documento.prpnumdig  = ws.prpnumdig
       let g_documento.fcapacorg  = ws.fcapacorg
       let g_documento.fcapacnum  = ws.fcapacnum
       ##

 ## # VERIFICA SE SERVICO JA ESTEVE EM ANALISE
 ## declare c_datmsrvanlhst cursor for
 ##  select c24evtcod, caddat
 ##    from datmsrvanlhst
 ##   where atdsrvnum    =  d_ctb05m00.atdsrvnum
 ##     and atdsrvano    =  d_ctb05m00.atdsrvano
 ##     and c24evtcod    <> 0
 ##     and srvanlhstseq =  1

 ## let ws.totanl = 0   # total de analise do servico

 ## foreach c_datmsrvanlhst into ws.c24evtcod, ws.caddat

 ##    select c24fsecod, cadmat
 ##      into ws.c24fsecod, ws.cadmat
 ##      from datmsrvanlhst
 ##     where atdsrvnum    =  d_ctb05m00.atdsrvnum
 ##       and atdsrvano    =  d_ctb05m00.atdsrvano
 ##       and c24evtcod    =  ws.c24evtcod
 ##       and srvanlhstseq = (select max(srvanlhstseq)
 ##                             from datmsrvanlhst
 ##                            where atdsrvnum  =  d_ctb05m00.atdsrvnum
 ##                              and atdsrvano  =  d_ctb05m00.atdsrvano
 ##                              and c24evtcod  =  ws.c24evtcod)

 ##    if ws.c24fsecod <> 2  and        # 2- ok analisado e pago
 ##       ws.c24fsecod <> 4  then       # 4- nao procede
 ##       if ws.totanl = 0 then
 ##          let ws.totanl = 1
 ##          let ws.c24evtcod_svl = ws.c24evtcod
 ##          let ws.c24fsecod_svl = ws.c24fsecod
 ##          let ws.cadmat_svl    = ws.cadmat
 ##          let ws.caddat_svl    = ws.caddat
 ##       else
 ##          if ws.caddat > ws.caddat_svl then
 ##             let ws.c24evtcod_svl = ws.c24evtcod
 ##             let ws.c24fsecod_svl = ws.c24fsecod
 ##             let ws.cadmat_svl    = ws.cadmat
 ##             let ws.caddat_svl    = ws.caddat
 ##          end if
 ##          let ws.totanl = ws.totanl + 1
 ##       end if
 ##    else
 ##       continue foreach
 ##    end if

 ## end foreach

 ## if ws.totanl > 0   then
 ##    initialize ws.c24evtrdzdes, ws.c24fsedes to null
 ##    select c24evtrdzdes
 ##      into ws.c24evtrdzdes
 ##      from datkevt
 ##     where datkevt.c24evtcod = ws.c24evtcod_svl

 ##    select c24fsedes
 ##      into ws.c24fsedes
 ##      from datkfse
 ##     where datkfse.c24fsecod = ws.c24fsecod_svl

 ##    select funnom
 ##      into ws.funnom_hst
 ##      from isskfunc
 ##     where empcod = 1
 ##       and funmat = ws.cadmat_svl

 ##    let ws.msg1 = "ULT.ANALISE : ",ws.c24evtrdzdes,"."
 ##    let ws.msg2 = "FASE ...... : ",ws.c24fsedes,"."
 ##    let ws.msg3 = "ANALISTA... : ",ws.funnom_hst,"."
 ##    if ws.totanl > 1 then
 ##       let ws.msg4 = "ATENCAO:  EXISTEM ", ws.totanl using "&&"," ANALISES"
 ##    end if

 ##    call cts08g01("A","N", ws.msg1, ws.msg2, ws.msg3, ws.msg4)
 ##         returning ws.confirma
 ## end if

 return d_ctb05m00.atdsrvnum, d_ctb05m00.atdsrvano

end function  ###  seleciona_ctb05m00

#-----------------------------------------------------------
 function ligacoes_ctb05m00(param)
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

 let l_retorno = null        #PSI 202720
 let l_mensagem = null       #PSI 202720
 let l_tpdocto = null        #PSI 202720

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
    (ws.crtnum is not null) then

     call ctp01m01(ws.succod   , ws.ramcod   ,
                   ws.aplnumdig, ws.itmnumdig,
                   ws.prporg   , ws.prpnumdig,
                   ws.fcapacorg, ws.fcapacnum,
                   ws.crtnum)
 else
    error " Servico sem documento informado!"
 end if

end function  ###  ligacoes_ctb05m00
