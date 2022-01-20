#############################################################################
# Nome do Modulo: CTP01M00                                            Pedro #
#                                                                   Marcelo #
# Pesquisa Telemarketing - consulta dados do servico               Mar/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Nao permitir a pesquisa de servicos #
#                                       atendidos como particular.          #
#---------------------------------------------------------------------------#
# 18/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a   #
#                                       serem excluidos.                    #
#---------------------------------------------------------------------------#
# 14/09/1999  PSI 8821-8   Marcelo      Substituicao do campo ATDMOTNOM por #
#                                       cadastro de motoristas (datksrr).   #
#---------------------------------------------------------------------------#
# 28/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-  #
#                                       coes, com a utilizacao de funcoes.  #
#---------------------------------------------------------------------------#
# 16/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 04/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa   PSI.168920     Resolucao 86
# 22/09/2006  Ligia Mattge      PSI 202720  Implementacao do cartao Saude   #
#---------------------------------------------------------------------------#
# 04/01/2010  Amilton, Meta             Projeto Sucursal Smallint           #               
#############################################################################



globals "/homedsa/projetos/geral/globals/glct.4gl"

 define d_ctp01m00    record
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    cttqtd            like datmpesquisa.cttqtd  ,
    nom               like datmservico.nom      ,
    cvnnom            char (20)                 ,
    dddcodseg         like gsakend.dddcod       ,
    teltxtseg         like gsakend.teltxt       ,
    doctxt            char (32)                 ,
    vcldes            like datmservico.vcldes   ,
    vcllicnum         like datmservico.vcllicnum,
    mtvdes            char (65)                 ,
    c24solnom         like datmligacao.c24solnom,
    c24soltipdes      like datksoltip.c24soltipdes,
    funnom            like isskfunc.funnom      ,
    atdlibdat         like datmservico.atdlibdat,
    atdlibhor         like datmservico.atdlibhor,
    atddatprg         like datmservico.atddatprg,
    atdhorprg         like datmservico.atdhorprg,
    nomgrr            like dpaksocor.nomgrr     ,
    srrcoddig         like datmservico.srrcoddig,
    srrabvnom         like datksrr.srrabvnom    ,
    atdhorpvt         like datmservico.atdhorpvt,
    trjdsthor         like datmtrajeto.trjdsthor,
    atrhor            char (06)                 ,
    hsttxt            char (65)                 ,
    ultctt            char (50)
 end record

 define w_ctp01m00    record
    atddat            like datmservico.atddat      ,
    succod            like datrligapol.succod      ,
    ramcod            like datrligapol.ramcod      ,
    aplnumdig         like datrligapol.aplnumdig   ,
    itmnumdig         like datrligapol.itmnumdig   ,
    achflg            smallint,
    data              date ,
    hora              datetime hour to minute      ,
    c24soltipcod      like datmligacao.c24soltipcod
 end record

 define m_crtsaunum   like datrligsau.crtnum

#------------------------------------------------------------
 function ctp01m00()
#------------------------------------------------------------

  open window ctp01m00 at 04,02 with form "ctp01m00"
  initialize d_ctp01m00.*   to null
  let m_crtsaunum = null

  menu  "PESQUISA "

    command key ("S")  "Seleciona" "Seleciona servicos para pesquisa"
       clear form
       initialize  d_ctp01m00.*  to null
       call ctp01m00_seleciona()

    command key ("A")  "Avaliacao" "Avaliacao do servico"
       if d_ctp01m00.atdsrvnum  is not null   and
          d_ctp01m00.atdsrvano  is not null   then
          call ctp01m02(d_ctp01m00.atdsrvnum, d_ctp01m00.atdsrvano,
                        w_ctp01m00.atddat  , w_ctp01m00.data, w_ctp01m00.hora)
       else
          error " Nenhum servico foi selecionado!"
       end if
       next option "Seleciona"

    command key ("H")  "Historico" "Historico da pesquisa"
       if d_ctp01m00.atdsrvnum  is not null   and
          d_ctp01m00.atdsrvano  is not null   then

          select atdsrvnum, atdsrvano
            from datmpesquisa
           where atdsrvnum = d_ctp01m00.atdsrvnum   and
                 atdsrvano = d_ctp01m00.atdsrvano

          if sqlca.sqlcode  <>  0  then
             error " Antes de registrar historico, informe codigo da pesquisa!"
          else
             call ctp01m03(d_ctp01m00.atdsrvnum, d_ctp01m00.atdsrvano,
                           g_issk.funmat, w_ctp01m00.data, w_ctp01m00.hora)
          end if
       else
          error " Nenhum servico foi selecionado!"
       end if
       next option "Seleciona"

    command  key ("G")  "liGacoes" "Ligacoes da apolice"
       if d_ctp01m00.atdsrvnum is not null  and
          d_ctp01m00.atdsrvano is not null  then
          if w_ctp01m00.succod    is not null  and
             w_ctp01m00.aplnumdig is not null  then
             call ctp01m01(w_ctp01m00.succod, w_ctp01m00.ramcod, w_ctp01m00.aplnumdig, w_ctp01m00.itmnumdig, "", "","","", m_crtsaunum)
          else
             error " Servico sem documento informado!"
          end if
       else
          error " Nenhum servico foi selecionado!"
       end if
       next option "Seleciona"

    command  key ("V")  "serVicos" "Servicos da apolice a serem pesquisados"
       if d_ctp01m00.atdsrvnum  is not null   and
          d_ctp01m00.atdsrvano  is not null   then
          if w_ctp01m00.succod    is not null  and
             w_ctp01m00.aplnumdig is not null  then
             call ctp01m06(w_ctp01m00.succod   , w_ctp01m00.ramcod,
                           w_ctp01m00.aplnumdig, w_ctp01m00.itmnumdig,
                           d_ctp01m00.atdsrvnum, m_crtsaunum)
          else
             error " Servico sem documento informado!"
          end if
       else
          error " Nenhum servico foi selecionado!"
       end if
       next option "Seleciona"

    command  key ("I")  "Imprime"   "Imprime Laudo/historico do servico"
       if d_ctp01m00.atdsrvnum  is not null   and
          d_ctp01m00.atdsrvano  is not null   then
          call ctr03m02(d_ctp01m00.atdsrvnum, d_ctp01m00.atdsrvano)
       else
          error " Nenhum servico foi selecionado!"
       end if
       next option "Seleciona"

    command  key (interrupt, E )  "Encerra"  "Retorna ao Menu Anterior"
       exit menu
  end menu

  close window ctp01m00

end function  ###  ctp01m00

#------------------------------------------------------------------
 function ctp01m00_seleciona()
#------------------------------------------------------------------

 initialize d_ctp01m00.*  to null
 initialize w_ctp01m00.*  to null

 let int_flag  = false
 let w_ctp01m00.data = today
 let w_ctp01m00.hora = current hour to minute

 input by name d_ctp01m00.atdsrvnum,
               d_ctp01m00.atdsrvano   without defaults

   before field atdsrvnum
      display by name d_ctp01m00.atdsrvnum  attribute (reverse)

   after  field atdsrvnum
      display by name d_ctp01m00.atdsrvnum

   before field atdsrvano
      display by name d_ctp01m00.atdsrvano  attribute (reverse)

   after  field atdsrvano
      display by name d_ctp01m00.atdsrvano

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field atdsrvnum
      end if

      if d_ctp01m00.atdsrvano   is null      and
         d_ctp01m00.atdsrvnum   is not null  then
         error " Informe o ano do servico!"
         next field atdsrvano
      end if

      if d_ctp01m00.atdsrvano   is not null   and
         d_ctp01m00.atdsrvnum   is null       then
         error " Informe o numero do servico!"
         next field atdsrvnum
      end if

      if ctp01m00_avalia() = true  then
         exit input
      else
         next field atdsrvnum
      end if

   on key (interrupt)
      exit input

 end input

 if int_flag  then
    initialize d_ctp01m00.*   to null
    clear form
    let int_flag = false
 end if

end function  ###  ctp01m00_seleciona

#-----------------------------------------------------------
 function ctp01m00_avalia()
#-----------------------------------------------------------

 define ws            record
    h24cal            datetime hour to minute      ,
    funatd            like datmservico.funmat      ,
    funpsq            like datmpesquisa.funmat     ,
    psqnom            like isskfunc.funnom         ,
    psqdpt            like isskfunc.dptsgl         ,
    cttdat            like datmpesquisa.cttdat     ,
    ctthor            like datmpesquisa.ctthor     ,
    sinvitflg         like datmservicocmp.sinvitflg,
    srvprlflg         like datmservico.srvprlflg   ,
    lignum            like datrligsrv.lignum       ,
    ligcvntip         like datmligacao.ligcvntip   ,
    c24astcod         like datmligacao.c24astcod   ,
    lighorinc         like datmligacao.lighorinc   ,
    ligastcod         like datmligacao.c24astcod   ,
    atdprscod         like datmservico.atdprscod   ,
    atdmotnom         like datmservico.atdmotnom   ,
    ciaempcod         like datmservico.ciaempcod
 end record

 define lr_ffpfc073 record
        cgccpfnumdig char(18) ,
        cgccpfnum    char(12) ,
        cgcord       char(4)  ,
        cgccpfdig    char(2)  ,
        mens         char(50) ,
        erro         smallint
 end record

 define l_resultado   smallint,
        l_mensagem    char(50),
        l_grupo       smallint,
        l_segnom      char(50),
        l_doc_handle  integer

 initialize ws.*          to null
 initialize lr_ffpfc073.* to null
 let l_resultado = null
 let l_mensagem  = null
 let l_grupo     = null
 let l_segnom    = null
 let l_doc_handle    = null

#----------- DADOS DO SERVICO -----------

 select nom      , vcldes   , vcllicnum,
        funmat   , atddat   , atdlibhor,
        atdlibdat, atdhorpvt, atddatprg,
        atdhorprg, atdprscod, atdmotnom,
        sinvitflg, atdsrvorg   ,
        srvprlflg, srrcoddig   ,
        ciaempcod
   into d_ctp01m00.nom       , d_ctp01m00.vcldes    ,
        d_ctp01m00.vcllicnum , ws.funatd            ,
        w_ctp01m00.atddat    , d_ctp01m00.atdlibhor ,
        d_ctp01m00.atdlibdat , d_ctp01m00.atdhorpvt ,
        d_ctp01m00.atddatprg , d_ctp01m00.atdhorprg ,
        ws.atdprscod         , ws.atdmotnom         ,
        ws.sinvitflg         , d_ctp01m00.atdsrvorg ,
        ws.srvprlflg         , d_ctp01m00.srrcoddig,
        ws.ciaempcod
   from datmservico, outer datmservicocmp
  where datmservico.atdsrvnum = d_ctp01m00.atdsrvnum and
        datmservico.atdsrvano = d_ctp01m00.atdsrvano and

        datmservico.atdsrvnum = datmservicocmp.atdsrvnum and
        datmservico.atdsrvano = datmservicocmp.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado!"
    return false
 end if

 if ws.srvprlflg = "S"  then
    error " Servico particular nao deve ser pesquisado!"
    return false
 end if

 if d_ctp01m00.atdsrvorg <>  4   and
    d_ctp01m00.atdsrvorg <>  6   and
    d_ctp01m00.atdsrvorg <>  1   then
    error " Servico nao deve ser pesquisado!"
    return false
 end if

 let d_ctp01m00.nomgrr = "** NAO CADASTRADO! **"

 select nomgrr into d_ctp01m00.nomgrr
   from dpaksocor
  where pstcoddig = ws.atdprscod

 if ws.atdmotnom  is not null   and
    ws.atdmotnom  <>  "  "      then
    let d_ctp01m00.srrabvnom  =  ws.atdmotnom
 else
    if d_ctp01m00.srrcoddig  is not null   then
       select srrabvnom
         into d_ctp01m00.srrabvnom
         from datksrr
        where srrcoddig  =  d_ctp01m00.srrcoddig
    end if
 end if

 #----- BUSCA SUCURSAL/APOLICE/ITEM DO SERVICO-------

 select succod   , ramcod   , aplnumdig, itmnumdig
   into w_ctp01m00.succod   , w_ctp01m00.ramcod   ,
        w_ctp01m00.aplnumdig, w_ctp01m00.itmnumdig
   from datrservapol
  where atdsrvnum = d_ctp01m00.atdsrvnum and
        atdsrvano = d_ctp01m00.atdsrvano

 if sqlca.sqlcode = notfound  then
    let d_ctp01m00.doctxt = "SEM DOCUMENTO INFORMADO"
 else
    let d_ctp01m00.doctxt = w_ctp01m00.succod    using "###&&", " ", #"&&", " ", # Projeto Sucursal
                            w_ctp01m00.ramcod    using "&&&&", " ",
                            w_ctp01m00.aplnumdig using "<<<<<<<& &", " ",
                            w_ctp01m00.itmnumdig using "<<<<<<& &"
 end if


  #----------- DADOS DA LIGACAO/CONVENIO -------------

 let ws.lignum = cts20g00_servico(d_ctp01m00.atdsrvnum, d_ctp01m00.atdsrvano)

 ## PSI 202720 busca o cartao do saude
 call cts20g09_docto(1, ws.lignum)
      returning m_crtsaunum

 if m_crtsaunum is not null then
    let d_ctp01m00.doctxt = m_crtsaunum
 end if

 call cty10g00_grupo_ramo(g_issk.empcod, w_ctp01m00.ramcod)
      returning l_resultado, l_mensagem, l_grupo

 select c24solnom, c24soltipcod,
        c24astcod, ligcvntip
   into d_ctp01m00.c24solnom,
        w_ctp01m00.c24soltipcod,
        ws.c24astcod,
        ws.ligcvntip
   from datmligacao
  where lignum = ws.lignum

  select c24soltipdes
    into d_ctp01m00.c24soltipdes
    from datksoltip
         where c24soltipcod = w_ctp01m00.c24soltipcod

 call c24geral8(ws.c24astcod) returning d_ctp01m00.mtvdes

 select cpodes
   into d_ctp01m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = ws.ligcvntip


 let d_ctp01m00.funnom = "** NAO CADASTRADO! **"

 select funnom
   into d_ctp01m00.funnom
   from isskfunc
  where succod = g_issk.succod  and
        funmat = ws.funatd

 ### PSI 202720
 if l_grupo = 5 then ## Saude
    call cta01m15_sel_datksegsau (3, m_crtsaunum, "","","")
         returning l_resultado, l_mensagem, l_segnom, d_ctp01m00.dddcodseg,
                   d_ctp01m00.teltxtseg
 else

    if ws.ciaempcod = 1 then #Porto
       call cts09g00(w_ctp01m00.ramcod,
                     w_ctp01m00.succod,
                     w_ctp01m00.aplnumdig,
                     w_ctp01m00.itmnumdig,
                     false)
           returning d_ctp01m00.dddcodseg,
                     d_ctp01m00.teltxtseg
    else
       ## obtem o telefone do segurado da Azul
       if ws.ciaempcod = 35 then
          call cts42g00_doc_handle(w_ctp01m00.succod, w_ctp01m00.ramcod,
                                   w_ctp01m00.aplnumdig, w_ctp01m00.itmnumdig,
                                   g_documento.edsnumref)
               returning l_resultado, l_mensagem, l_doc_handle

          if l_resultado = 1 and
             l_doc_handle is not null then
             call cts40g02_extraiDoXML(l_doc_handle, "FONE_SEGURADO")
                  returning d_ctp01m00.dddcodseg,
                            d_ctp01m00.teltxtseg
          end if
       end if
       
       # Itau
       
       if ws.ciaempcod = 84 then
           let d_ctp01m00.dddcodseg = g_doc_itau[1].segresteldddnum 
           let d_ctp01m00.teltxtseg = g_doc_itau[1].segrestelnum    
       end if
       
       ## PortoSeg

       if ws.ciaempcod = 40 then

         select cgccpfnum,
                cgcord   ,
                cgccpfdig
         into lr_ffpfc073.cgccpfnum ,
              lr_ffpfc073.cgcord    ,
              lr_ffpfc073.cgccpfdig
         from datrligcgccpf
         where lignum = ws.lignum

         let lr_ffpfc073.cgccpfnumdig = ffpfc073_formata_cgccpf(lr_ffpfc073.cgccpfnum ,
                                                                lr_ffpfc073.cgcord    ,
                                                                lr_ffpfc073.cgccpfdig )

            call ffpfc073_rec_tel(lr_ffpfc073.cgccpfnumdig,'F')
                  returning d_ctp01m00.dddcodseg ,
                            d_ctp01m00.teltxtseg ,
                            lr_ffpfc073.mens     ,
                            lr_ffpfc073.erro

            if lr_ffpfc073.erro <> 0 then
                error lr_ffpfc073.mens
            end if

       end if

    end if

 end if

#-----------  HISTORICO DO SERVICO  -----------

 declare c_ctp01m00lig  cursor for
    select lighorinc, c24astcod
      from datmligacao
     where atdsrvnum =  d_ctp01m00.atdsrvnum     and
           atdsrvano =  d_ctp01m00.atdsrvano     and
           c24astcod in ("ALT","CAN","REC")

 foreach c_ctp01m00lig  into  ws.lighorinc,
                              ws.ligastcod

    let d_ctp01m00.hsttxt = d_ctp01m00.hsttxt clipped, " ",
                               ws.lighorinc, "-", ws.ligastcod

 end foreach

#----------- DADOS DA PESQUISA ----------

 select cttqtd, funmat, cttdat, ctthor
   into d_ctp01m00.cttqtd , ws.funpsq,
        ws.cttdat, ws.ctthor
   from datmpesquisa
   where atdsrvnum = d_ctp01m00.atdsrvnum    and
         atdsrvano = d_ctp01m00.atdsrvano

 if sqlca.sqlcode = 0  then
    let ws.psqnom = "** NAO CADASTRADO! **"
    let ws.psqdpt = "N/CAD"

    select funnom, dptsgl
      into ws.psqnom, ws.psqdpt
      from isskfunc
     where succod = g_issk.succod  and
           funmat = ws.funpsq

   let d_ctp01m00.ultctt = "Em ", ws.cttdat," as ", ws.ctthor, " ",
                           upshift(ws.psqdpt)," ", upshift(ws.psqnom)
 else
    error " Nao foi realizado nenhum contato!"
 end if

 if d_ctp01m00.atddatprg  is null   then
    select trjdsthor  into d_ctp01m00.trjdsthor
      from datmtrajeto
     where atdsrvnum = d_ctp01m00.atdsrvnum   and
           atdsrvano = d_ctp01m00.atdsrvano   and
           trjnumseq = 1

    if sqlca.sqlcode <> notfound   then
       if d_ctp01m00.atdlibhor <=  d_ctp01m00.trjdsthor    then
          let d_ctp01m00.atrhor = (d_ctp01m00.trjdsthor - d_ctp01m00.atdlibhor)
                                  - d_ctp01m00.atdhorpvt
       else
          let ws.h24cal       =  "23:59"
          let d_ctp01m00.atrhor = ws.h24cal - d_ctp01m00.atdlibhor
          let ws.h24cal       =  "00:00"
          let d_ctp01m00.atrhor =
              d_ctp01m00.atrhor + (d_ctp01m00.trjdsthor - ws.h24cal)
                                + "00:01" - d_ctp01m00.atdhorpvt
       end if
    end if
 end if

 display by name  d_ctp01m00.*
 display by name  d_ctp01m00.cvnnom  attribute (reverse)

 if ws.sinvitflg  =  "S"   then
    display "VITIMAS"  to  vitimas   attribute (reverse)
 end if

 return true

end function  ###  ctp01m00_avalia
