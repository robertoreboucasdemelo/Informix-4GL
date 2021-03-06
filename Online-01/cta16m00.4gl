#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                   #
# Modulo.........: cta16m00                                                   #
# Objetivo.......: Espelho do Itau                                            #
# Analista Resp. : Roberto Melo                                               #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: Roberto Melo                                               #
# Liberacao      : 11/02/2010                                                 #
#.............................................................................#
#                         * * * ALTERACOES * * *                              #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 08/09/2011   Marcos Goes                Adaptacao dos campos do novo layout #
#                                         do Itau adicionados a global.       #
#-----------------------------------------------------------------------------#


database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare   smallint
define m_hostname  char(12)

define mr_tela record
      atdnum            like datmatd6523.atdnum              ,
      itaciacod         like datmitaapl.itaciacod            ,
      succod            like datrligapol.succod              ,
      itaaplnum         like datmitaapl.itaaplnum            ,
      itaaplitmnum      like datmitaaplitm.itaaplitmnum      ,
      aplseqnum         like datmitaapl.aplseqnum            ,
      solnom            char(15)                             ,
      sucnom            like gabksuc.sucnom                  ,
      itasgrplncod      like datkitasgrpln.itasgrplncod      ,
      itasgrplndes      like datkitasgrpln.itasgrplndes      ,
      itaasiplncod      like datkitaasipln.itaasiplncod      ,
      itaasiplndes      like datkitaasipln.itaasiplndes      ,
      itaaplvigincdat   like datmitaapl.itaaplvigincdat      ,
      itaaplvigfnldat   like datmitaapl.itaaplvigfnldat      ,
      itaclisgmdes      like datkitaclisgm.itaclisgmdes      ,
      sitdoc            char(09)                             ,
      autfbrnom         like datmitaaplitm.autfbrnom         ,
      autlnhnom         like datmitaaplitm.autlnhnom         ,
      autmodnom         like datmitaaplitm.autmodnom         ,
      autchsnum         like datmitaaplitm.autchsnum         ,
      autplcnum         like datmitaaplitm.autplcnum         ,
      autfbrano         like datmitaaplitm.autfbrano         ,
      autmodano         like datmitaaplitm.autmodano         ,
      autcornom         like datmitaaplitm.autcornom         ,
      itacbtcod         like datkitacbt.itacbtcod            ,
      itacbtdes         like datkitacbt.itacbtdes            ,
      segnom            like datmitaapl.segnom               ,
      segresteldddnum   like datmitaapl.segresteldddnum      ,
      segrestelnum      like datmitaapl.segrestelnum         ,
      cornom            like gcakcorr.cornom                 ,
      corsus            like gcaksusep.corsus                ,
      dddtel            like gcakfilial.dddcod               ,
      numtel            like gcakfilial.teltxt               ,
      itaasisrvcod      like datkitaasisrv.itaasisrvcod      ,
      itaasisrvdes      like datkitaasisrv.itaasisrvdes      ,
      pansoclmtqtd      like datkitaasipln.pansoclmtqtd      ,
      socqlmqtd         like datkitaasipln.socqlmqtd         ,
      qtdutilizado      integer                              ,
      seta              char(01)                             ,
      okmflgdes         char(03)                             ,
      impautflgdes      char(03)                             ,
      bldflgdes         char(03)                             ,
      label1            char(35)                             ,
      label2            char(75)
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
function cta16m00_prepare()
#------------------------------------------------------------------------------

define l_sql char(500)

   let l_sql = "  select cornom               ",
               "  from gcaksusep a,           ",
               "       gcakcorr b             ",
               "where a.corsus  = ?           ",
               "and a.corsuspcp = b.corsuspcp "
   prepare p_cta16m00_001  from l_sql
   declare c_cta16m00_001  cursor for p_cta16m00_001


   let m_prepare = true

end function

#------------------------------------------------------------------------------
function cta16m00()
#------------------------------------------------------------------------------

define lr_retorno record
   erro          integer   ,
   mensagem      char(50)  ,
   confirma      char(01)
end record

initialize lr_retorno.* ,
           mr_tela.*    ,
           r_gcakfilial.*  to null

if m_prepare is null or
   m_prepare <> true then
   call cta16m00_prepare()
end if

let g_documento.itaciacod = 33


      call cty22g00_rec_dados_itau(g_documento.itaciacod,
                                   g_documento.ramcod   ,
                                   g_documento.aplnumdig,
                                   g_documento.edsnumref,
                                   g_documento.itmnumdig)
      returning lr_retorno.erro    ,
                lr_retorno.mensagem


     if lr_retorno.erro = 0 then

         call cta16m00_carrega_campo()

         open window cta16m00 at 03,02 with form "cta16m00"
              attribute(form line 1)

         input by name mr_tela.* without defaults

         before field atdnum
           call cta16m00_display()

           error ""

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
                  error "Tecla F1 n�o Disponivel no Momento ! ",lr_retorno.mensagem ," ! Avise a Informatica "
                  sleep 2
               end if

            on key (F3)
               if g_doc_itau[1].itaasiplncod = 3                             and
               	  cts12g08_valida_data_vigencia(g_doc_itau[1].itaasiplncod     ,
               	                                g_doc_itau[1].itaclisgmcod     ,
               	                                g_doc_itau[1].itaaplvigincdat) then
                 call cts12g08(g_doc_itau[1].itaasiplncod   ,
                               g_doc_itau[1].itaclisgmcod   ,
                               g_doc_itau[1].itaaplvigincdat)
               else
                 call cts12g07(g_doc_itau[1].itaasiplncod   ,
                               g_doc_itau[1].itaclisgmcod   ,
                               g_doc_itau[1].itaaplvigincdat)
               end if

            on key (F4)

             let m_hostname = null
             call cta13m00_verifica_instancias_u37()
             returning lr_retorno.erro    ,
                       lr_retorno.mensagem

               let   lr_retorno.mensagem = true
             if lr_retorno.mensagem = true then
               call ctn09c00(g_doc_itau[1].corsus)
             else
               error "Tecla F4 n�o Disponivel no Momento ! ", lr_retorno.mensagem  ," ! Avise a Informatica "
               sleep 2
             end if


            on key (f9)
               call cta18m00()

            on key (f10)
               call cta17m00()



         end input
         #--------------------------------------------------------
         # Chama o Processo da Contigencia Online
         #--------------------------------------------------------
         call cty42g00(g_documento.ciaempcod        ,
                       g_documento.succod           ,
                       g_documento.ramcod           ,
                       g_documento.aplnumdig        ,
                       g_documento.itmnumdig        ,
                       g_doc_itau[1].segcgccpfnum   ,
                       g_doc_itau[1].segcgcordnum   ,
                       g_doc_itau[1].segcgccpfdig   ,
                       g_doc_itau[1].autplcnum      )

         close window cta16m00

         let int_flag = false

     else
         error lr_retorno.mensagem
     end if


end function


#------------------------------------------------------------------------------
function cta16m00_carrega_campo()
#------------------------------------------------------------------------------

define lr_retorno record
   erro          integer   ,
   mensagem      char(50)
end record

initialize lr_retorno.* to null


    let mr_tela.atdnum          = g_documento.atdnum
    let mr_tela.itaciacod       = g_doc_itau[1].itaciacod
    let mr_tela.succod          = g_documento.succod
    let mr_tela.itaaplnum       = g_doc_itau[1].itaaplnum
    let mr_tela.itaaplitmnum    = g_doc_itau[1].itaaplitmnum
    let mr_tela.aplseqnum       = g_doc_itau[1].aplseqnum
    let mr_tela.solnom          = g_documento.solnom
    let mr_tela.itasgrplncod    = g_doc_itau[1].itasgrplncod
    let mr_tela.itaaplvigincdat = g_doc_itau[1].itaaplvigincdat
    let mr_tela.itaaplvigfnldat = g_doc_itau[1].itaaplvigfnldat
    let mr_tela.autfbrnom       = g_doc_itau[1].autfbrnom
    let mr_tela.autlnhnom       = g_doc_itau[1].autlnhnom
    let mr_tela.autmodnom       = g_doc_itau[1].autmodnom
    let mr_tela.autchsnum       = g_doc_itau[1].autchsnum
    let mr_tela.autplcnum       = g_doc_itau[1].autplcnum
    let mr_tela.autfbrano       = g_doc_itau[1].autfbrano
    let mr_tela.autmodano       = g_doc_itau[1].autmodano
    let mr_tela.autcornom       = g_doc_itau[1].autcornom
    let mr_tela.segnom          = g_doc_itau[1].segnom
    let mr_tela.segresteldddnum = g_doc_itau[1].segresteldddnum
    let mr_tela.segrestelnum    = g_doc_itau[1].segrestelnum
    let mr_tela.corsus          = g_doc_itau[1].corsus
    let mr_tela.itaasisrvcod    = g_doc_itau[1].itaasisrvcod
    let mr_tela.itacbtcod       = g_doc_itau[1].itacbtcod
    let mr_tela.itaasiplncod    = g_doc_itau[1].itaasiplncod


    # Verifica Situa��o do Documento

    if mr_tela.itaaplvigincdat <= today and
       mr_tela.itaaplvigfnldat  >= today then
          if g_doc_itau[1].itaaplcanmtvcod is null then
               let mr_tela.sitdoc = "ATIVA"
          else
               let mr_tela.sitdoc = "CANCELADA"
          end if
    else
          let mr_tela.sitdoc = "VENCIDA"
    end if

    # Verifica 0Km

    case g_doc_itau[1].okmflg
       when "S"
            let mr_tela.okmflgdes = "SIM"
       when "N"
            let mr_tela.okmflgdes = "NAO"
    end case


    # Verifica Importado

    case g_doc_itau[1].impautflg
       when "S"
            let mr_tela.impautflgdes = "SIM"
       when "N"
            let mr_tela.impautflgdes = "NAO"
    end case


    # Verifica Blindagem
    let mr_tela.bldflgdes = " "

    case g_doc_itau[1].bldflg
       when "S"
            let mr_tela.bldflgdes = "SIM"
       when "N"
            let mr_tela.bldflgdes = "NAO"
       otherwise
            let mr_tela.bldflgdes = "NAO"
    end case

    # Recupera Nome da Sucursal

    call f_fungeral_sucursal(g_documento.succod)
    returning mr_tela.sucnom

    # Recupera Descricoes

    call cto00m10_recupera_descricao(7,g_doc_itau[1].itaclisgmcod)
    returning mr_tela.itaclisgmdes

    call cto00m10_recupera_descricao(5,g_doc_itau[1].itasgrplncod)
    returning mr_tela.itasgrplndes

    call cto00m10_recupera_descricao(6,g_doc_itau[1].itaasisrvcod)
    returning mr_tela.itaasisrvdes

    call cto00m10_recupera_descricao(13,g_doc_itau[1].itaasiplncod)
    returning mr_tela.itaasiplndes

    call cto00m10_recupera_descricao(14,g_doc_itau[1].itacbtcod)
    returning mr_tela.itacbtdes


    # Recupera Corretor

    open c_cta16m00_001 using g_doc_itau[1].corsus
    whenever error continue
    fetch c_cta16m00_001 into mr_tela.cornom
    whenever error stop

    if sqlca.sqlcode = notfound  then
       let mr_tela.cornom = "Corretor nao Cadastrado!"
    else
       call fgckc811(g_doc_itau[1].corsus)
       returning r_gcakfilial.*

       let mr_tela.dddtel = r_gcakfilial.dddcod
       let mr_tela.numtel = r_gcakfilial.teltxt

    end if
    close c_cta16m00_001

    # Recupera Limites do Plano

    if g_documento.ramcod = 14 then
       call cty25g00_rec_plano_assistencia(g_doc_itau[1].itaasiplncod)
       returning mr_tela.pansoclmtqtd ,
                 mr_tela.socqlmqtd    ,
                 lr_retorno.erro      ,
                 lr_retorno.mensagem
    else
       call cty22g00_rec_plano_assistencia(g_doc_itau[1].itaasiplncod)
       returning mr_tela.pansoclmtqtd ,
                 mr_tela.socqlmqtd    ,
                 lr_retorno.erro      ,
                 lr_retorno.mensagem
    end if

    # Recupera a Quantidade de Servi�os J� Prestados

    call cty22g00_qtd_ligacoes_itau(g_doc_itau[1].itaasiplncod   ,
                                    g_doc_itau[1].itaaplvigincdat,
                                    g_doc_itau[1].itaaplvigfnldat,
                                    g_doc_itau[1].itaciacod      ,
                                    g_doc_itau[1].itaramcod      ,
                                    g_doc_itau[1].itaaplnum      ,
                                    g_doc_itau[1].itaaplitmnum   )
    returning mr_tela.qtdutilizado

    let mr_tela.label1 = "                AUTO"
    let mr_tela.label2 = "       (F1)Funcoes (F3)Extrato (F4)Corr (F9)Endereco (F10)OutInf"

end function

#------------------------------------------------------------------------------
function cta16m00_display()
#------------------------------------------------------------------------------

   display by name mr_tela.atdnum
   display by name mr_tela.itaciacod
   display by name mr_tela.succod
   display by name mr_tela.sucnom
   display by name mr_tela.itaaplnum
   display by name mr_tela.itaaplitmnum
   display by name mr_tela.aplseqnum
   display by name mr_tela.itaasiplndes
   display by name mr_tela.itacbtdes
   display by name mr_tela.solnom attribute(reverse)
   display by name mr_tela.itasgrplncod
   display by name mr_tela.itaaplvigincdat
   display by name mr_tela.itaaplvigfnldat
   display by name mr_tela.autfbrnom
   display by name mr_tela.autlnhnom
   display by name mr_tela.autmodnom
   display by name mr_tela.autchsnum
   display by name mr_tela.autplcnum
   display by name mr_tela.autfbrano
   display by name mr_tela.autmodano
   display by name mr_tela.autcornom
   display by name mr_tela.segnom
   display by name mr_tela.segresteldddnum
   display by name mr_tela.segrestelnum
   display by name mr_tela.corsus
   display by name mr_tela.itaasisrvcod
   display by name mr_tela.sitdoc attribute(reverse)
   display by name mr_tela.impautflgdes
   display by name mr_tela.bldflgdes
   display by name mr_tela.itaclisgmdes
   display by name mr_tela.itasgrplndes
   display by name mr_tela.itaasisrvdes
   display by name mr_tela.itacbtcod
   display by name mr_tela.itaasiplncod
   display by name mr_tela.pansoclmtqtd
   display by name mr_tela.socqlmqtd
   display by name mr_tela.cornom
   display by name mr_tela.dddtel
   display by name mr_tela.numtel
   display by name mr_tela.qtdutilizado
   display by name mr_tela.label1 attribute(reverse)
   display by name mr_tela.label2

end function
