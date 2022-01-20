##############################################################################
# Nome do Modulo: CTA05M03                                          Marcelo  #
#                                                                   Gilberto #
# Direciona e imprime pedido de desculpas (reclamacao)              Jul/1997 #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
# 23/10/1998 Marcelo        PSI 6966-3  Incluir configuracoes para envio de  #
#                                       fax atraves do servidor VSI-Fax.     #
#----------------------------------------------------------------------------#
# 22/04/2003 Aguinaldo Costa PSI168920  Resolucao 86                         #
#----------------------------------------------------------------------------#
# 21/09/2006 Ligia Mattge   PSI 202720  Implementar cartao Saude (crtsaunum) #
#----------------------------------------------------------------------------#
# 27/11/2006 Ligia Mattge   PSI 205206  ciaempcod                            #
#----------------------------------------------------------------------------#
# 11/10/2010 Carla Rampazzo PSI 260606  Tratar Fluxo de Reclamacao p/PSS(107)#
#----------------------------------------------------------------------------#
# 14/02/2011 Carla Rampazzo PSI         Fluxo de Reclamacao p/ PortoSeg(518) #
#----------------------------------------------------------------------------#
# 19/04/2012 Silvia, Meta   PSI 2012-07408 Projeto Anatel - DDD/Telefone     #
#----------------------------------------------------------------------------#
# 10/02/2014 interax                    Projeto RightFax                     #
#----------------------------------------------------------------------------#
##############################################################################

globals "/homedsa/projetos/geral/globals/figrc012.4gl" #Saymon ambnovo
globals "/homedsa/projetos/geral/globals/glct.4gl"

 define ws_pipe      char (80)
 define ws_fax       char (03)
 define l_docHandle  integer                    #RightFax
#--------------------------------------------------------------
 function cta05m03(param)
#--------------------------------------------------------------

 define param        record
    lignum           like datmligacao.lignum,
    ciaempcod        like datmligacao.ciaempcod
 end record

 define d_cta05m03   record
    enviar           char (01),
    envdes           char (10),
    dddcod           like datmreclam.dddcod,
    faxnum           like datmreclam.faxnum
 end record

 define ws           record
    faxch1           like datmfax.faxch1,
    faxch2           like datmfax.faxch2,
    faxtxt           char (12),
    impnom           char (08),
    imp_ok           smallint,
    envflg           dec(1,0),
    faxflg           smallint,
    confirma         char (01),
    segnom           like gsakseg.segnom,
    destino          char (24)
 end record

 #RightFax - inicio
 define lr_param         record
        service            char(10)
       ,serviceType        char(10)
       ,typeOfConnection   char(3)
       ,fileSystem         char(100)
       ,jasperFileName     char(50)
       ,outFileName        char(100)
       ,outFileType        char(3)
       ,recordPath         char(100)
       ,aplicacao          char(30)
       ,outbox             char(100)
       ,generatorTIFF      smallint
 end record

 define l_hora            datetime hour to second
 define l_nomexml         char(200)
 define w_conta           smallint

 define lr_param_out      record
          codigo            smallint
        , mensagem          char(200)
 end    record

 define lr_fax             record
          ddd                char(3)
         ,telefone           char(16)
         ,destinatario 	     char(30)
         ,notas              char(30)
         ,caminhoarq         char(100)
         ,sistema            char(100)
         ,geratif            smallint
 end record
 initialize lr_param.* ,lr_param_out.*, l_hora to null
 #RightFax - Fim

 initialize d_cta05m03.*  to null
 initialize ws.*          to null

 let ws.envflg  =  true
 let ws.faxflg  =  false
 let int_flag   =  false

 #----------------------------------------------------------------------------
 # Define tipo do servidor de fax a ser utilizado (GSF)GS-Fax / (VSI) VSI-Fax
 #----------------------------------------------------------------------------
 let ws_fax = "VSI"

 initialize d_cta05m03.*  to null

 select dddcod, faxnum
   into d_cta05m03.dddcod,
        d_cta05m03.faxnum
   from datmreclam
  where lignum = param.lignum

 if d_cta05m03.dddcod is null  and
    d_cta05m03.faxnum is null  then
    let ws.faxflg = true
 end if


 open window cta05m03 at 05,05  with form "cta05m03"
             attribute (form line 1, border)

 message " (F17)Abandona"

 display by name d_cta05m03.*


 input by name d_cta05m03.enviar ,
               d_cta05m03.dddcod ,
               d_cta05m03.faxnum without defaults

    before field enviar
       display by name d_cta05m03.enviar    attribute (reverse)

    after  field enviar
       display by name d_cta05m03.enviar

       if d_cta05m03.enviar is null  then
          error " Enviar pedido de desculpas para (I)mpressora ou (F)ax!"
          next field enviar
       else
          if d_cta05m03.enviar = "F"  then
             let d_cta05m03.envdes = "FAX"
          else
             if d_cta05m03.enviar = "I"  then
                let d_cta05m03.envdes = "IMPRESSORA"
             else
                error " Enviar pedido de desculpas para (I)mpressora ou (F)ax!"
                next field enviar
             end if
          end if
       end if

       display by name d_cta05m03.envdes

       initialize  ws_pipe, ws.imp_ok, ws.impnom to null

       if d_cta05m03.enviar = "I"  then
          call fun_print_seleciona (g_issk.dptsgl,"")
               returning  ws.imp_ok, ws.impnom

          if ws.imp_ok = 0  then
             error " Departamento/Impressora nao cadastrada!"
             next field enviar
          end if

          if ws.impnom is null  then
             error " Uma impressora deve ser selecionada!"
             next field enviar
          end if
       else
          if g_outFigrc012.Is_Teste then #ambnovo
             error " Fax so' pode ser enviado no ambiente de producao !!!"
             next field enviar
          end if
       end if

    before field dddcod
       display by name d_cta05m03.dddcod    attribute (reverse)

    after  field dddcod
       display by name d_cta05m03.dddcod

       if fgl_lastkey() = fgl_keyval("up")     or
          fgl_lastkey() = fgl_keyval("left")   then
          next field enviar
       end if

       if d_cta05m03.dddcod is null  or
          d_cta05m03.dddcod  = "  "  then
          error " Codigo do DDD deve ser informado!"
          next field dddcod
       end if

       if d_cta05m03.dddcod   = "0   "   or
          d_cta05m03.dddcod   = "00  "   or
          d_cta05m03.dddcod   = "000 "   or
          d_cta05m03.dddcod   = "0000"   then
          error " Codigo do DDD invalido!"
          next field dddcod
       end if

    before field faxnum
       display by name d_cta05m03.faxnum    attribute (reverse)

    after  field faxnum
       display by name d_cta05m03.faxnum

       if fgl_lastkey() = fgl_keyval("up")     or
          fgl_lastkey() = fgl_keyval("left")   then
          next field dddcod
       end if

       if d_cta05m03.faxnum is null  or
          d_cta05m03.faxnum =  000   then
          error " Numero do fax deve ser informado!"
          next field faxnum
       else
          if d_cta05m03.faxnum > 99999  then
          else
             error " Numero do fax invalido!"
             next field faxnum
          end if
       end if

    on key (interrupt)
       exit input

 end input

 if not int_flag  then

    if ws.faxflg = true  then
       whenever error continue

       update datmreclam set (dddcod, faxnum) =
             (d_cta05m03.dddcod, d_cta05m03.faxnum)
        where lignum = param.lignum

       whenever error stop
    end if

    call cta05m03_segurado(param.lignum, param.ciaempcod)
         returning ws.segnom

    if d_cta05m03.enviar  =  "F"  then
       call cts10g01_enviofax("", "", param.lignum, "RC", g_issk.funmat)
                    returning ws.envflg, ws.faxch1, ws.faxch2

       if ws_fax = "GSF"  then
          if g_outFigrc012.Is_Teste then #ambnovo
             let ws.impnom = "tstclfax"
          else
             let ws.impnom = "ptsocfax"
          end if
          let ws_pipe = "lp -sd ", ws.impnom
       else
           #RightFax - Inicio
           #call cts02g01_fax(d_cta05m03.dddcod, d_cta05m03.faxnum)
           #       returning ws.faxtxt
           #
           #let ws.destino = ws.segnom
           #
           #let ws_pipe = "vfxCTRC ", ws.faxtxt   clipped, " ", ascii 34,
           #              ws.destino             clipped, ascii 34,  " ",
           #              ws.faxch1              using "&&&&&&&&&&", " ",
           #              ws.faxch2              using "&&&&&&&&&&"
           #RightFax - Fim
       end if
    else
       let ws_pipe = "lp -sd ", ws.impnom
    end if

    if ws.envflg = true  then
       #RightFax - Inicio
       #start report  rep_reclam
       let lr_param.service          = 'cta05m03.4gl'
       let lr_param.serviceType      = 'GENERATOR'
       let lr_param.typeOfConnection = 'xml'
       let lr_param.fileSystem       = '\\\\nt112\\jasper3\\atendimento_rightfax\\jaspers\\'
       let lr_param.jasperFileName   = 'cta05m03.jasper'
       let l_hora                    =  current
       let lr_param.outFileName      = 'agradecimento'
       let lr_param.outFileType      = 'pdf'
       let lr_param.recordPath       = '/report/data/file/cta'
       let lr_param.aplicacao        = 'cta05m03.4gl'
       let lr_param.outbox           = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\'
       let lr_param.generatorTIFF    = false
       let l_nomexml                 = 'cta05m03'
       call cty35g00_monta_estrutura_jasper(lr_param.*,l_nomexml)
           returning l_docHandle
       display "@@@l_docHandle = ",l_docHandle       #tirar

       #output to report rep_reclam (d_cta05m03.enviar,
       #                             param.lignum,
       #                             ws.segnom,
       #                             d_cta05m03.dddcod,
       #                             d_cta05m03.faxnum,
       #                             ws.faxch1,
       #                             ws.faxch2,
       #                             param.ciaempcod)
       call cta05m03_rep_reclam (d_cta05m03.enviar
                                ,param.lignum
                                ,ws.segnom
                                ,d_cta05m03.dddcod
                                ,d_cta05m03.faxnum
                                ,ws.faxch1
                                ,ws.faxch2
                                ,param.ciaempcod
                                ,l_docHandle)
       #finish report rep_reclam
          let lr_fax.ddd           = d_cta05m03.dddcod
          let lr_fax.telefone      = d_cta05m03.faxnum
          let lr_fax.destinatario  = ''
          let lr_fax.notas         = ''
          let lr_fax.caminhoarq    = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\',lr_param.outFileName ,'.pdf'
          let lr_fax.sistema       = 'ndh384'
          let lr_fax.geratif       = false

          call cty35g00_envia_fax(l_docHandle,lr_fax.*)
                returning lr_param_out.codigo
                         ,lr_param_out.mensagem

          if lr_param_out.codigo = 0 then
             display "Fax enviado com sucesso"
          end if
       #RightFax - Fim

    else
       call cts08g01 ("A", "S", "OCORREU UM PROBLEMA NO ENVIO",
                                "DO FAX",
                                "",
                                "*** TENTE NOVAMENTE ***")
            returning ws.confirma
    end if
 else
    error " ATENCAO !!! FAX NAO SERA' ENVIADO!"

    call cts08g01("A", "N", "",
                            "FAX COM PEDIDO DE DESCULPAS",
                            "*** NAO SERA' ENVIADO ***",
                            "")
         returning ws.confirma
 end if

 let int_flag = false
 clear form
 error ""
 close window cta05m03

end function  ###  cta05m03


#--------------------------------------------------------------
 function cta05m03_segurado(param)
#--------------------------------------------------------------

 define param        record
    lignum           like datmligacao.lignum,
    ciaempcod        like datmligacao.ciaempcod
 end record

 define ws2          record
    succod           like datrligapol.succod,
    ramcod           like datrligapol.ramcod,
    aplnumdig        like datrligapol.aplnumdig,
    itmnumdig        like datrligapol.itmnumdig,
    sgrorg           like rsamseguro.sgrorg,
    sgrnumdig        like rsamseguro.sgrnumdig,
    segnumdig        like gsakseg.segnumdig,
    segnom           like gsakseg.segnom,
    crtsaunum        like datrligsau.crtnum,
    dddcod           like gsaktel.dddnum,
    teltxt           like gsaktel.telnum,
    status           smallint,
    msg              char(20)
 end record

 define lr_segurado record
        nome        char(60),
        cgccpf      char(15),
        pessoa      char(01),
        dddfone     char(05),
        numfone     char(15),
        email       char(100)
 end record

 define lr_ffpfc073 record
        cgccpfnumdig char(18) ,
        cgccpfnum    char(12) ,
        cgcord       char(4)  ,
        cgccpfdig    char(2)  ,
        mens         char(50) ,
        erro         smallint
 end record



 define l_erro    smallint
       ,l_msg     char(30)
       ,l_doc_handle integer

 initialize lr_segurado.* to null
 initialize ws2.*         to null
 initialize lr_ffpfc073.* to null

 let l_erro       = null
 let l_msg        = null
 let l_doc_handle = null

 ### PSI 202720
 call cts20g09_docto(1, param.lignum)
      returning ws2.crtsaunum

 ## se for ligacao do saude
 if ws2.crtsaunum  is not null then
    ## obter o nome do segurado saude
     call cta01m15_sel_datksegsau(3, ws2.crtsaunum, '','','')
         returning ws2.status, ws2.msg, ws2.segnom, ws2.dddcod, ws2.teltxt
 else

 #------------------------------------------------------------------
 # Documento da reclamacao
 #------------------------------------------------------------------
 select succod,
        ramcod,
        aplnumdig,
        itmnumdig
   into ws2.succod,
        ws2.ramcod,
        ws2.aplnumdig,
        ws2.itmnumdig
   from datrligapol
        where lignum = param.lignum

 #------------------------------------------------------------------
 # Obtem numero do segurado, dependendo do ramo
 #------------------------------------------------------------------

 if param.ciaempcod = 1 then ## PSI 205206
    if ws2.ramcod = 31  or
       ws2.ramcod = 531  then
       call f_funapol_ultima_situacao(ws2.succod, ws2.aplnumdig, ws2.itmnumdig)
            returning g_funapol.*

       select segnumdig
         into ws2.segnumdig
         from abbmdoc
        where succod    = ws2.succod
          and aplnumdig = ws2.aplnumdig
          and itmnumdig = ws2.itmnumdig
          and dctnumseq = g_funapol.dctnumseq

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na localizacao da apolice de automovel. AVISE A INFORMATICA!"
          return
       end if
    else
       select sgrorg,
              sgrnumdig
         into ws2.sgrorg,
              ws2.sgrnumdig
         from rsamseguro
        where succod    = ws2.succod
          and ramcod    = ws2.ramcod
          and aplnumdig = ws2.aplnumdig

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na localizacao da apolice de R.E. AVISE A INFORMATICA!"
          return
       else
          select segnumdig
            into ws2.segnumdig
            from rsdmdocto
           where sgrorg    = ws2.sgrorg
             and sgrnumdig = ws2.sgrnumdig
             and dctnumseq = (select max(dctnumseq)
                                from rsdmdocto
                               where sgrorg     = ws2.sgrorg
                                 and sgrnumdig  = ws2.sgrnumdig
                                 and prpstt    in (19,65,66,88))
       end if
    end if

    #------------------------------------------------------------------
    # Nome do segurado
    #------------------------------------------------------------------
    select segnom
      into ws2.segnom
      from gsakseg
     where segnumdig = ws2.segnumdig

 else
    ## obtem o nome do segurado da Azul
    if param.ciaempcod = 35 then ## PSI 205206 - Azul Seguros
       call cts42g00_doc_handle(ws2.succod, ws2.ramcod,
                                ws2.aplnumdig, ws2.itmnumdig,
                                g_documento.edsnumref)
            returning l_erro, l_msg, l_doc_handle

       if l_erro = 1 and
          l_doc_handle is not null then
          call cts40g02_extraiDoXML(l_doc_handle, "SEGURADO")
               returning lr_segurado.nome,
                         lr_segurado.cgccpf,
                         lr_segurado.pessoa,
                         lr_segurado.dddfone,
                         lr_segurado.numfone,
                         lr_segurado.email

          let  ws2.segnom  = lr_segurado.nome
       end if
    end if


    if param.ciaempcod = 40 then ## PSI 213438 - PortoSeg

       select cgccpfnum,
              cgcord   ,
              cgccpfdig
       into lr_ffpfc073.cgccpfnum ,
            lr_ffpfc073.cgcord    ,
            lr_ffpfc073.cgccpfdig
       from datrligcgccpf
       where lignum = param.lignum

       let lr_ffpfc073.cgccpfnumdig = ffpfc073_formata_cgccpf(lr_ffpfc073.cgccpfnum ,
                                                              lr_ffpfc073.cgcord    ,
                                                              lr_ffpfc073.cgccpfdig )

       call ffpfc073_rec_prop(lr_ffpfc073.cgccpfnumdig,'F')
            returning lr_ffpfc073.mens ,
                      lr_ffpfc073.erro ,
                      ws2.segnom

       if lr_ffpfc073.erro <> 0 then
          error  lr_ffpfc073.mens
       end if

    end if


 end if

 end if ## crtsaunum

 return ws2.segnom

end function  ###  cta05m03_segurado


#RightFax - Inicio
##---------------------------------------------------------------------------
# report rep_reclam(r_cta05m03)
##---------------------------------------------------------------------------
#
# define r_cta05m03 record
#    enviar         char (01),
#    lignum         like datmligacao.lignum,
#    segnom         like gsakseg.segnom,
#    dddcod         like datmreclam.dddcod,
#    faxnum         like datmreclam.faxnum,
#    faxch1         like datmfax.faxch1,
#    faxch2         like datmfax.faxch2,
#    ciaempcod      like datmligacao.ciaempcod
# end record
#
# define ws         record
#    chrdat         char (10),
#    destino        char (24),
#    c24astcod      like datmligacao.c24astcod,
#    srvdes         char (30)
# end record
#
# define a_cta05m03 array[12] of record
#    mesext         char (10)
# end record
#
# define arr_aux    smallint
# define l_empnom char(12)
#
# output report to  pipe ws_pipe
#    left   margin  00
#    right  margin  80
#    top    margin  00
#    bottom margin  00
#    page   length  58
#
# format
#
#    first page header
#       #------------------------------------------------------------------
#       # Monta data por extenso para cabecalho
#       #------------------------------------------------------------------
#       let a_cta05m03[01].mesext = "janeiro"
#       let a_cta05m03[02].mesext = "fevereiro"
#       let a_cta05m03[03].mesext = "marco"
#       let a_cta05m03[04].mesext = "abril"
#       let a_cta05m03[05].mesext = "maio"
#       let a_cta05m03[06].mesext = "junho"
#       let a_cta05m03[07].mesext = "julho"
#       let a_cta05m03[08].mesext = "agosto"
#       let a_cta05m03[09].mesext = "setembro"
#       let a_cta05m03[10].mesext = "outubro"
#       let a_cta05m03[11].mesext = "novembro"
#       let a_cta05m03[12].mesext = "dezembro"
#
#       let ws.chrdat = today
#
#       let arr_aux   = ws.chrdat[4,5]
#
#    on every row
#       if r_cta05m03.enviar = "F"  then
#
#         # if ws_fax  =  "GSF"   then
#             if r_cta05m03.dddcod > 0099  then
#                print column 001, r_cta05m03.dddcod using "&&&&";
#             else
#                print column 001, r_cta05m03.dddcod using "&&&";
#             end if
#             if r_cta05m03.faxnum > 99999999  then    # Anatel  (+1 (9))
#                print r_cta05m03.faxnum using "&&&&&&&&&";  # Anatel (+1 &)
#             else
#                if r_cta05m03.faxnum > 9999999  then   # Anatel  (+1 (9))
#                   print r_cta05m03.faxnum using "&&&&&&&&";  # Anatel (+1 &)
#                else
#                   print r_cta05m03.faxnum using "&&&&&&&"; # Anatel (+1 & )
#                end if
#             end if
#
#             let ws.destino = r_cta05m03.segnom
#
#             #------------------------------------------------------------------
#             # Checa caracteres invalidos para o GSFAX
#             #------------------------------------------------------------------
#             call cts02g00(ws.destino) returning ws.destino
#
#             print column 001                        ,
#             "@"                                     ,  #---> Delimitador
#             ws.destino                              ,  #---> Destinat. Cx Postal
#             "*CTRC"                                 ,  #---> Sistema/Subsistema
#             r_cta05m03.faxch1   using "&&&&&&&&&&"  ,  #---> Numero/Ano Servico
#             r_cta05m03.faxch2   using "&&&&&&&&&&"  ,  #---> Sequencia
#             "@"                                     ,  #---> Delimitador
#             ws.destino                              ,  #---> Destinat.(Informix)
#             "@"                                     ,  #---> Delimitador
#             "CENTRAL 24 HORAS"                      ,  #---> Quem esta enviando
#             "@"                                     ,  #---> Delimitador
#             "PORTO.TIF"                             ,  #---> Arquivo Logotipo
#             "@"                                     ,  #---> Delimitador
#             "semcapa"                                  #---> Nao tem cover page
#         # else
#
#          {   if ws_fax  =  "VSI"   then
#                if r_cta05m03.ciaempcod = 1 then ## PSI 205206
#                   print column 001, "@+IMAGE[porto.tif]"
#                   skip 7 lines
#                end if
#             end if
#
#          end if }
#
#       else
#          print column 001, "Enviar para: ", r_cta05m03.segnom clipped,
#                column 058, "Fax: ", "(", r_cta05m03.dddcod clipped, ")",
#                            r_cta05m03.faxnum using "<<<<<<<<&"  ## Anatel (+1 (<))
#          skip 4 lines
#       end if
#
#       initialize ws.c24astcod to null
#
#       select c24astcod
#         into ws.c24astcod
#         from datmligacao
#        where lignum = r_cta05m03.lignum
#
#       case ws.c24astcod
#          when "W00"  let ws.srvdes = "a CENTRAL 24 HORAS"
#          when "W01"  let ws.srvdes = "a CENTRAL 24 HORAS"
#          when "W02"  let ws.srvdes = "o PORTO SOCORRO"
#          when "W03"  let ws.srvdes = "a CENTRAL 24 HORAS"
#          when "W04"  let ws.srvdes = "o PORTO SOCORRO"
#          when "W05"  let ws.srvdes = "o PORTO SOCORRO"
#          when "W06"  let ws.srvdes = "o CARRO EXTRA"
#          when "W07"  let ws.srvdes = "a CENTRAL 24 HORAS"
#          when "107"  let ws.srvdes = "a CENTRAL 24 HORAS"
#          when "518"  let ws.srvdes = "a CENTRAL 24 HORAS"
#          when "K00"  let ws.srvdes = "a CENTRAL 24 HORAS"
#          when "I99"  let ws.srvdes = "a CENTRAL 24 HORAS"
#          when "P24"  let ws.srvdes = "o PORTO SERVICOS AVULSOS"
#          otherwise   let ws.srvdes = "a CENTRAL 24 HORAS"
#
#       end case
#
#       skip 3 lines
#       print column 001, "Sao Paulo, ", ws.chrdat[1,2], " de ", a_cta05m03[arr_aux].mesext clipped, " de ", ws.chrdat[7,10], "."
#       skip 3 lines
#
#       print column 001, upshift(r_cta05m03.segnom)
#       skip 1 line
#
#       print column 001, "Prezado Segurado,"
#       skip 3 lines
#
#       if r_cta05m03.ciaempcod = 1 then ## PSI 205206
#          let l_empnom = "PORTO SEGURO"
#       else
#          if r_cta05m03.ciaempcod = 35 then
#             let l_empnom = "AZUL SEGUROS"
#          end if
#       end if
#
#       print column 001, "A principal intencao da ", l_empnom, "  e' a satisfacao de seus clientes, e para"
#       print column 001, "atingirmos este objetivo e' preciso um trabalho continuo e minucioso, ainda que"
#       print column 001, "nao tenhamos  conseguido atender  `as suas expectativas no momento  em que voce "
#       print column 001, "precisou utilizar-se de um dos nossos servicos, ", ws.srvdes clipped, "."
#       skip 2 lines
#
#       print column 001, "A ", l_empnom, " tem procurado  investir cada vez  mais no treinamento  de seus"
#       print column 001, "funcionarios,  no planejamento  de  sua estrutura  e  na  aproximacao  com seus"
#       print column 001, "clientes."
#       skip 2 lines
#
#       print column 001, "Como voce,  eles contribuem muito para o nosso aperfeicoamento, dando opinioes,"
#       print column 001, "apontando falhas  ou fazendo criticas,  as quais entendemos  de forma positiva."
#       print column 001, "Caso voce  queira  acrescentar  outras  impressoes  no futuro,  estaremos a sua"
#       print column 001, "disposicao para ouvir a sua necessidade e buscar a solucao adequada."
#       skip 2 lines
#
#       print column 001, "Hoje, gostariamos de agradecer a sua colaboracao e lhe dizer que estamos traba-"
#       print column 001, "lhando para aperfeicoar cada vez mais o nosso atendimento.  Atitudes como a sua"
#       print column 001, "e' que apontam o caminho da excelencia. Nos agradecemos em nome da ", l_empnom
#       print column 001, "e de  todos os  seus clientes que,  gracas a sua ajuda,  poderao contar com uma"
#       print column 001, "empresa cada vez melhor."
#       skip 5 lines
#
#       print column 055, "Atenciosamente,"
#       skip 3 lines
#       print column 055, "Patricia Inhasz"
#       print column 050, "Gerente de Teleatendimento"
#
# end report  ###  rep_reclam
#RightFax - Fim

#RightFax - Inicio
function cta05m03_rep_reclam(r_cta05m03,l_docHandle)

 define r_cta05m03 record
    enviar         char (01),
    lignum         like datmligacao.lignum,
    segnom         like gsakseg.segnom,
    dddcod         like datmreclam.dddcod,
    faxnum         like datmreclam.faxnum,
    faxch1         like datmfax.faxch1,
    faxch2         like datmfax.faxch2,
    ciaempcod      like datmligacao.ciaempcod
 end record

 define l_docHandle  integer

 define ws         record
    chrdat         char (10),
    destino        char (24),
    c24astcod      like datmligacao.c24astcod,
    srvdes         char (30)
 end record

 define a_cta05m03 array[12] of record
    mesext         char (10)
 end record

 define arr_aux    smallint
 define l_empnom char(12)

 define l_path         char(500)
       ,l_path2        char(500)
       ,l_path_item    char(500)
       ,l_caminho      char(500)
       ,l_i            smallint
       ,l_ind          smallint

 let l_path = "/report/data/file/cta"

 let l_caminho = l_path clipped ,"/ddd_fax" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cta05m03.dddcod clipped)

 let l_caminho = l_path clipped ,"/numero_fax" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cta05m03.faxnum clipped)

 let l_caminho = l_path clipped ,"/nome_destinatario" clipped
 let ws.destino = r_cta05m03.segnom
 call cts02g00(ws.destino) returning ws.destino
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,ws.destino clipped)

 let l_caminho = l_path clipped ,"/numero_servico_central" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cta05m03.faxch1 clipped)

 let l_caminho = l_path clipped ,"/ano_servico_central" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cta05m03.faxch2 clipped)

 let l_caminho = l_path clipped ,"/endereco_imagem_logo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,"\\\\nt112\\jasper3\\atendimento_rightfax\\logo.jpg" clipped)

 let l_caminho = l_path clipped ,"/dia" clipped
 let a_cta05m03[01].mesext = "janeiro"
 let a_cta05m03[02].mesext = "fevereiro"
 let a_cta05m03[03].mesext = "marco"
 let a_cta05m03[04].mesext = "abril"
 let a_cta05m03[05].mesext = "maio"
 let a_cta05m03[06].mesext = "junho"
 let a_cta05m03[07].mesext = "julho"
 let a_cta05m03[08].mesext = "agosto"
 let a_cta05m03[09].mesext = "setembro"
 let a_cta05m03[10].mesext = "outubro"
 let a_cta05m03[11].mesext = "novembro"
 let a_cta05m03[12].mesext = "dezembro"
 let ws.chrdat = today
 let arr_aux   = ws.chrdat[4,5]
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,ws.chrdat[1,2] clipped)

 let l_caminho = l_path clipped ,"/mes" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,a_cta05m03[arr_aux].mesext clipped)

 let l_caminho = l_path clipped ,"/ano" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,ws.chrdat[7,10] clipped)

 let l_caminho = l_path clipped ,"/nome_segurado" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,upshift(r_cta05m03.segnom) clipped)

 let l_caminho = l_path clipped ,"/nome_empresa" clipped
 if r_cta05m03.ciaempcod = 1 then
    let l_empnom = "PORTO SEGURO"
 else
    if r_cta05m03.ciaempcod = 35 then
       let l_empnom = "AZUL SEGUROS"
    end if
 end if
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,l_empnom clipped)

 let l_caminho = l_path clipped ,"/descricao_servico" clipped
 initialize ws.c24astcod to null
 select c24astcod
   into ws.c24astcod
   from datmligacao
  where lignum = r_cta05m03.lignum
 case ws.c24astcod
    when "W00"  let ws.srvdes = "a CENTRAL 24 HORAS"
    when "W01"  let ws.srvdes = "a CENTRAL 24 HORAS"
    when "W02"  let ws.srvdes = "o PORTO SOCORRO"
    when "W03"  let ws.srvdes = "a CENTRAL 24 HORAS"
    when "W04"  let ws.srvdes = "o PORTO SOCORRO"
    when "W05"  let ws.srvdes = "o PORTO SOCORRO"
    when "W06"  let ws.srvdes = "o CARRO EXTRA"
    when "W07"  let ws.srvdes = "a CENTRAL 24 HORAS"
    when "107"  let ws.srvdes = "a CENTRAL 24 HORAS"
    when "518"  let ws.srvdes = "a CENTRAL 24 HORAS"
    when "K00"  let ws.srvdes = "a CENTRAL 24 HORAS"
    when "I99"  let ws.srvdes = "a CENTRAL 24 HORAS"
    when "P24"  let ws.srvdes = "o PORTO SERVICOS AVULSOS"
    otherwise   let ws.srvdes = "a CENTRAL 24 HORAS"
 end case
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,ws.srvdes clipped)

 end function
 #RightFax - Fim
