#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                   #
# Modulo.........: cta21m00                                                   #
# Objetivo.......: Espelho do Itau Residencia                                 #
# Analista Resp. : JUNIOR  (FORNAX)                                           #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: JUNIOR  (FORNAX)                                           #
# Liberacao      :   /  /                                                     #
#.............................................................................#
#                         * * * ALTERACOES * * *                              #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
#   /  /                                                                      #
#                                                                             #
#-----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare   smallint
define m_hostname  char(10)

define mr_tela record
      atdnum            like datmatd6523.atdnum              ,
      itaciacod         like datmitaapl.itaciacod            ,
      succod            like datrligapol.succod              ,
      aplnum            like datmresitaapl.aplnum               ,
      aplitmnum         like datmresitaaplitm.aplitmnum         ,
      aplseqnum         like datmresitaapl.aplseqnum            ,
      solnom            char(15)                             ,
      sucnom            like gabksuc.sucnom                  ,
      prdcod            like datmresitaaplitm.prdcod         ,
      prddes            char(70),
      prpnum            like datmresitaapl.prpnum            ,
      itaaplvigincdat   like datmitaapl.itaaplvigincdat      ,
      itaaplvigfnldat   like datmitaapl.itaaplvigfnldat      ,
      sgmdes            like datkresitaclisgm.sgmdes         ,
      sitdoc            char(20)                             ,
      #rscsegcbttipcod   like datmresitaaplitm.rscsegcbttipcod,
      rscsegimvtipcod   like datmresitaaplitm.rscsegimvtipcod,
      rscsegrestipcod   like datmresitaaplitm.rscsegrestipcod,
      #rscsegcbttipdes   like datkrscsegcbttip.rscsegcbttipdes,
      rscsegrestipdes   like datkrscsegrestip.rscsegrestipdes,
      rscsegimvtipdes   like datkrscsegimvtip.rscsegimvtipdes,
      segnom            like datmitaapl.segnom               ,
      segresteldddnum   like datmitaapl.segresteldddnum      ,
      segrestelnum      like datmitaapl.segrestelnum         ,
      cornom            like gcakcorr.cornom                 ,
      corsus            like gcaksusep.corsus                ,
      dddtel            like gcakfilial.dddcod               ,
      numtel            like gcakfilial.teltxt               ,
      srvcod            like datmresitaaplitm.srvcod         ,
      srvdes            like datkresitasrv.srvdes            ,
      #plncod            like datkresitapln.plncod            ,
      #plndes            like datkresitapln.plndes            ,
      label2            char(78)                             ,
      vipsegflg         char(03)                             ,
      cgccpf            char(25)                             ,
      pestip            char(08)                             ,
      seta              char(01)
end record

define mr_tela2 record
      aplitmnum        like datmresitaaplitm.aplitmnum,
      rscsegcbttipcod  like datmresitaaplitm.rscsegcbttipcod,
      rscsegimvtipcod  like datmresitaaplitm.rscsegimvtipcod,
      rscsegrestipcod  like datmresitaaplitm.rscsegrestipcod,
      rscsegcbttipdes  like datkrscsegcbttip.rscsegcbttipdes,
      rscsegrestipdes  like datkrscsegrestip.rscsegrestipdes   ,
      rscsegimvtipdes  like datkrscsegimvtip.rscsegimvtipdes,
      succod           like datmresitaapl.succod         ,
      prdcod           like datmresitaaplitm.prdcod      ,
      prddes           char(70)                          ,
      #plncod           like datkresitapln.plncod         ,
      #plndes           like datkresitapln.plndes         ,
      prpnum           like datmresitaapl.prpnum         ,
      sgmcod           like datkresitaclisgm.sgmcod      ,
      sgmdes           like datkresitaclisgm.sgmdes      ,
      segnom           like datmresitaapl.segnom         ,
      segcpjcpfnum     like datmresitaapl.segcpjcpfnum   ,
      cpjordnum        like datmresitaapl.cpjordnum      ,
      cpjcpfdignum     like datmresitaapl.cpjcpfdignum   ,
      suscod           like datmresitaapl.suscod         ,
      srvdes           like datkresitasrv.srvdes
end record

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


#------------------------------------------------------------------------------
function cta21m00_prepare()
#------------------------------------------------------------------------------

define l_sql char(500)

   let l_sql = " select cornom                 ",
               "  from gcaksusep a,            ",
               "       gcakcorr b              ",
               " where a.corsus  = ?           ",
               " and a.corsuspcp = b.corsuspcp "
   prepare p_cta21m00_001  from l_sql
   declare c_cta21m00_001  cursor for p_cta21m00_001

   let l_sql = " select  a.aplitmnum, a.rscsegcbttipcod, ",
	       "         a.rscsegimvtipcod, a.rscsegrestipcod, ",
	       "         a.prdcod, b.succod, " ,
	       "         b.prpnum, b.segnom, b.suscod,b.sgmcod  ",
	       " from datmresitaaplitm a, ",
	       "      datmresitaapl b     ",
	       " where a.itaciacod = b.itaciacod    ",
	       " and   a.itaramcod = b.itaramcod    ",
	       " and   a.aplnum    = b.aplnum       ",
	       " and   a.aplseqnum = b.aplseqnum    ",
	       " and   a.itaciacod = ? "  ,
	       " and   a.itaramcod = ? "  ,
	       " and   a.aplnum    = ? "  ,
	       " and   a.aplseqnum = ? "
   prepare p_cta21m00_002  from l_sql
   declare c_cta21m00_002  cursor for p_cta21m00_002

   let l_sql = " select prdcod ",
               "  from datmresitaaplitm ",
               " where itaciacod  = ? "  ,
	       " and   itaramcod  = ? "  ,
	       " and   aplnum     = ? "  ,
	       " and   aplseqnum  = ? "
   prepare p_cta21m00_009  from l_sql
   declare c_cta21m00_009  cursor for p_cta21m00_009

   let m_prepare = true

end function

#------------------------------------------------------------------------------
function cta21m00()
#------------------------------------------------------------------------------

define lr_retorno record
   erro          integer   ,
   mensagem      char(50)  ,
   confirma      char(01)
end record

initialize lr_retorno.* ,
           mr_tela.*    ,
           r_gcakfilial.*  to null

      call cta21m00_prepare()

      call cty25g01_rec_dados_itau(g_documento.itaciacod,
                                   g_documento.ramcod   ,
                                   g_documento.aplnumdig,
                                   g_documento.edsnumref,
                                   g_documento.itmnumdig)
      returning lr_retorno.erro    ,
                lr_retorno.mensagem


     if lr_retorno.erro = 0 then

         call cta21m00_carrega_campo()

         open window cta21m00 at 03,02 with form "cta21m00"
              attribute(form line 1)

         input by name mr_tela.* without defaults

         after field seta
	       next field seta

         before field atdnum
           #call cta21m00_display()

           #error ""

           #-----------------------------------------------------------
           # Verifica se o Cliente e VIP
           #-----------------------------------------------------------

           if  g_doc_itau[1].vipsegflg = "S" then
              call cts08g01 ("A","N","",
                             "Esta apolice pertence a um CLIENTE VIP ",
                             "do ITAU.                        ",
                             "")
                   returning lr_retorno.confirma
           end if

          #if g_doc_itau[1].itaaplitmsttcod = "C" then
          #
          #    call cts08g01("C","S",
          #        "ESTA APOLICE ESTA CANCELADA",
          #        "PROCURE UMA APOLICE VIGENTE",
          #        "OU CONSULTE A SUPERVISAO.",
          #        "DESEJA PROSSEGUIR?")
          #   returning lr_retorno.confirma
          #end if


          #-----------------------------------------------------------
          # Verifica se existe ligacao para advertencia ao atendente
          #-----------------------------------------------------------

           call cta01m09(g_documento.succod,
                         g_documento.ramcod,
                         g_documento.aplnumdig,
                         g_documento.itmnumdig)



           if g_documento.succod    is not null and
              g_documento.ramcod    is not null and
              g_documento.aplnumdig is not null and
              g_documento.itmnumdig is not null then


              #--------------------------------------------------#
              # Identifica atendimento em duplicidade
              #--------------------------------------------------#

              if g_documento.apoio <> 'S' or
                 g_documento.apoio is null then
                 call cta02m20(g_documento.succod    ,
                               g_documento.ramcod    ,
                               g_documento.aplnumdig ,
                               g_documento.itmnumdig ,
                               "","")
              end if

              #--------------------------------------------------#
              # Verifica Procedimentos
              #--------------------------------------------------#

              call cts14g00_itau(""                   ,
                                 g_documento.ramcod   ,
                                 g_documento.succod   ,
                                 g_documento.aplnumdig,
                                 g_documento.itmnumdig,
                                 "", "", "N"          ,
                                 "2099-12-31 23:00")
            end if


            on key (interrupt,control-c)
               exit input


            on key (F1)

               let m_hostname = null
               call cta13m00_verifica_status(m_hostname)
               returning lr_retorno.erro    ,
                         lr_retorno.mensagem


               if lr_retorno.erro = true then

                   call cta01m10_auto(g_documento.ramcod     ,
                                      g_documento.succod     ,
                                      g_documento.aplnumdig  ,
                                      g_documento.itmnumdig  ,
                                      g_documento.edsnumref  ,
                                      g_documento.prporg     ,
                                      g_documento.prpnumdig  ,
                                      g_documento.ligcvntip  ,
                                      0)

               else
                  error "Tecla F1 não Disponivel no Momento ! ",lr_retorno.mensagem ," ! Avise a Informatica "
                  sleep 2
               end if

            on key (F3)
              call cts12g06(g_doc_itau[1].itaasisrvcod)

            on key (F4)

             let m_hostname = null
             call cta13m00_verifica_instancias_u37()
             returning lr_retorno.erro    ,
                       lr_retorno.mensagem

               let   lr_retorno.mensagem = true
             if lr_retorno.mensagem = true then
               call ctn09c00(g_doc_itau[1].corsus)
             else
               error "Tecla F4 não Disponivel no Momento ! ", lr_retorno.mensagem  ," ! Avise a Informatica "
               sleep 2
             end if


         on key (f9)
            call cta21m01()

         #on key (f10)
         #
	       #if g_documento.ramcod = 14 then
         #      call cta20m00()
	       #else
         #     call cta17m00()
         #end if

         end input
         #--------------------------------------------------------
         # Chama o Processo da Contigencia Online
         #--------------------------------------------------------
         call cty42g00(g_documento.ciaempcod      ,
                       g_documento.succod         ,
                       g_documento.ramcod         ,
                       g_documento.aplnumdig      ,
                       g_documento.itmnumdig      ,
                       g_doc_itau[1].segcgccpfnum ,
                       g_doc_itau[1].segcgcordnum ,
                       g_doc_itau[1].segcgccpfdig ,
                       ""                         )

         close window cta21m00

         let int_flag = false

     else
         error lr_retorno.mensagem
     end if


end function


#------------------------------------------------------------------------------
function cta21m00_carrega_campo()
#------------------------------------------------------------------------------

define lr_retorno record
   erro          integer   ,
   mensagem      char(50)
end record


  open c_cta21m00_002 using  g_documento.itaciacod ,
	                           g_doc_itau[1].itaramcod ,
                      	     g_doc_itau[1].itaaplnum  ,
		                         g_doc_itau[1].aplseqnum

  whenever error continue

  fetch c_cta21m00_002 into mr_tela2.aplitmnum
                           ,mr_tela2.rscsegcbttipcod
			                     ,mr_tela2.rscsegimvtipcod
			                     ,mr_tela2.rscsegrestipcod
			                     ,mr_tela2.prdcod
			                     #,mr_tela2.plncod
			                     ,mr_tela2.succod
			                     ,mr_tela2.prpnum
			                     ,mr_tela2.segnom
			                     ,mr_tela2.suscod
			                     ,mr_tela2.sgmcod

  whenever error stop

  if sqlca.sqlcode <> 0  then
     if sqlca.sqlcode = notfound  then
        let lr_retorno.mensagem = "Dados nao encontrado c_cta21m00_002"
     else
        let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cta21m00_002 "
     end if
  end if

  open c_cta21m00_009 using  g_documento.itaciacod ,
	                           g_doc_itau[1].itaramcod,
		                         g_doc_itau[1].itaaplnum,
		                         g_doc_itau[1].aplseqnum

  whenever error continue

  fetch c_cta21m00_009 into mr_tela2.prdcod
  whenever error stop

  if sqlca.sqlcode <> 0  then
     if sqlca.sqlcode = notfound  then
        let lr_retorno.mensagem = "Dados nao encontrado c_cta21m00_009"
     else
        let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cta21m00_009 "
     end if
  end if

  let mr_tela.atdnum          = g_documento.atdnum
  let mr_tela.itaciacod       = g_doc_itau[1].itaciacod
  let mr_tela.succod          = mr_tela2.succod
  let mr_tela.aplnum          = g_doc_itau[1].itaaplnum
  let mr_tela.aplitmnum       = mr_tela2.aplitmnum
  let mr_tela.aplseqnum       = g_doc_itau[1].aplseqnum
  let mr_tela.solnom          = g_documento.solnom
  let mr_tela.prdcod          = mr_tela2.prdcod
  let mr_tela.prpnum          = mr_tela2.prpnum
  let mr_tela.itaaplvigincdat = g_doc_itau[1].itaaplvigincdat
  let mr_tela.itaaplvigfnldat = g_doc_itau[1].itaaplvigfnldat
  #let mr_tela.rscsegcbttipcod = mr_tela2.rscsegcbttipcod
  let mr_tela.rscsegimvtipcod = mr_tela2.rscsegimvtipcod
  let mr_tela.rscsegrestipcod = mr_tela2.rscsegrestipcod
  let mr_tela.segnom          = mr_tela2.segnom
  let mr_tela.segresteldddnum = g_doc_itau[1].segresteldddnum
  let mr_tela.segrestelnum    = g_doc_itau[1].segrestelnum
  let mr_tela.corsus          = mr_tela2.suscod
  let mr_tela.srvcod          = g_doc_itau[1].itaasisrvcod
  #let mr_tela.plncod          = mr_tela2.plncod
  #let g_doc_itau[1].itaasiplncod = mr_tela.plncod


  let mr_tela.label2 = "(F1)Funcoes (F3)Extrato (F4)Corr (F9)Endereco"

    # Verifica Situação do Documento
    if mr_tela.itaaplvigincdat <= today and
       mr_tela.itaaplvigfnldat  >= today then
          if g_doc_itau[1].itaaplcanmtvcod is null then
               let mr_tela.sitdoc = "ATIVA"
          else
               let mr_tela.sitdoc = "CANCELADA"
          end if
    else
        if g_doc_itau[1].itaaplcanmtvcod is null then
           if mr_tela.itaaplvigfnldat >= mr_tela.itaaplvigfnldat + 15 units day then
              let mr_tela.sitdoc = "VENCIDA"
           else
              let mr_tela.sitdoc = "EM RENOVACAO"
           end if
        end if
    end if

    # Recupera Nome da Sucursal

    call f_fungeral_sucursal(g_documento.succod)
    returning mr_tela.sucnom

    # Recupera Descricoes

    #call cty25g03_recupera_descricao2(1,mr_tela2.plncod,mr_tela.prdcod)
    #returning mr_tela.plndes

    call cty25g03_recupera_descricao(2,mr_tela.prdcod)
    returning mr_tela.prddes

    call cty25g03_recupera_descricao(3,mr_tela.srvcod)
    returning mr_tela.srvdes

    call cty25g03_recupera_descricao(4,mr_tela2.sgmcod)
    returning mr_tela.sgmdes

    #call cty25g03_recupera_descricao(5,mr_tela2.rscsegcbttipcod)
    #returning mr_tela.rscsegcbttipdes

    call cty25g03_recupera_descricao(6,mr_tela2.rscsegrestipcod)
    returning mr_tela.rscsegrestipdes

    call cty25g03_recupera_descricao(7,mr_tela2.rscsegimvtipcod)
    returning mr_tela.rscsegimvtipdes


    # Recupera Corretor
    open c_cta21m00_001 using g_doc_itau[1].corsus
    whenever error continue
    fetch c_cta21m00_001 into mr_tela.cornom

    whenever error stop

    if sqlca.sqlcode = notfound  then
       let mr_tela.cornom = "Corretor nao Cadastrado!"
    else
       call fgckc811(g_doc_itau[1].corsus)
       returning r_gcakfilial.*

       let mr_tela.dddtel = r_gcakfilial.dddcod
       let mr_tela.numtel = r_gcakfilial.teltxt

    end if

    # Formata Campo CGC/CPF

     if g_doc_itau[1].segcgcordnum is null or
        g_doc_itau[1].segcgcordnum = 0     or
        g_doc_itau[1].segcgcordnum = " "   then

          let mr_tela.cgccpf = g_doc_itau[1].segcgccpfnum using "<<&&&&&&&", "-", g_doc_itau[1].segcgccpfdig using "&&"
          let mr_tela.pestip = "FISICA"

     else

          let mr_tela.cgccpf = g_doc_itau[1].segcgccpfnum using "<<&&&&&&&", "/", g_doc_itau[1].segcgcordnum using "&&&&", "-", g_doc_itau[1].segcgccpfdig using "&&"
          let mr_tela.pestip = "JURIDICA"

     end if

     if g_doc_itau[1].vipsegflg = "N" then
        let mr_tela.vipsegflg = "NAO"
     else
        let mr_tela.vipsegflg = "SIM"
     end if




end function

#------------------------------------------------------------------------------
function cta21m00_display()
#------------------------------------------------------------------------------

   display  mr_tela.atdnum
   display  mr_tela.itaciacod
   display  mr_tela.succod
   display  mr_tela.sucnom
   display  mr_tela.aplnum
   display  mr_tela.aplitmnum
   display  mr_tela.aplseqnum
   display  mr_tela.solnom
   display  mr_tela.prdcod
   display  mr_tela.prddes
   display  mr_tela.prpnum
   display  mr_tela.sgmdes
   display  mr_tela.itaaplvigincdat
   display  mr_tela.itaaplvigfnldat
   display  mr_tela.sitdoc
   display  mr_tela.rscsegimvtipcod
   display  mr_tela.rscsegimvtipdes
   display  mr_tela.rscsegrestipcod
   display  mr_tela.rscsegrestipdes
   display  mr_tela.segnom
   display  mr_tela.segresteldddnum
   display  mr_tela.segrestelnum
   display  mr_tela.cornom
   display  mr_tela.corsus
   display  mr_tela.dddtel
   display  mr_tela.numtel
   display  mr_tela.srvcod
   display  mr_tela.srvdes
   display  mr_tela.pestip
   display  mr_tela.cgccpf
   display  mr_tela.vipsegflg



end function
