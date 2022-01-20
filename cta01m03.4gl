###############################################################################
# Nome do Modulo: CTA01M03                                           Ruiz     #
#                                                                    Sergio   #
# Espelho da apolice - Azul Seguros                                  DEZ/2006 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA       SOLICITACAO RESPONSAVEL     DESCRICAO                            #
#-----------------------------------------------------------------------------#
# 15/12/2006 psi 205206  Sergio          espelho apolice Azul Seguros.        #
#-----------------------------------------------------------------------------#
# 18/08/08               Carla Rampazzo  Substituir tratamento da clausula 037#
#                                        DE  :kilometragem                    #
#                                        PARA:Limite Retorno/Desc.Assistencia #
#-----------------------------------------------------------------------------#
# 18/10/2008 PSI 230650  Carla Rampazzo  Incluir Nro.de Atendimento na tela   #
#-----------------------------------------------------------------------------#
# 14/07/2009 PSI         Roberto Melo    Inclusão do Alerta de Atendentes     #
#                                        consultando a mesma apolice          #
#-----------------------------------------------------------------------------#
# 21/11/2009             Carla Rampazzo  Tratar novas Clausulas:              #
#                                        37A : Assist.24h - Rede Referenciada #
#                                        37B : Assist.24h - Livre Escolha     #
#-----------------------------------------------------------------------------#
# 30/09/2010             Carla Rampazzo  Tratar Apolices Convenio Itau        #
#                        Amilton Pinto   Mostar Alerta e Descricao            #
#-----------------------------------------------------------------------------#
# 07/12/2015 Sol 715257  Alberto         Alerta Itau                          #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_cvnnum     like datmligacao.ligcvntip
define m_ctgtrfcod  like abbmcasco.ctgtrfcod
#--------------------------#
 function cta01m03_prepare()
#--------------------------#

     define l_sql   char(500)

     let l_sql = " SELECT cpodes ",
                   " FROM datkdominio ",
                  " WHERE cponom = 'cvnnum' ",
                    " AND cpocod = ? "

     prepare pcts01m03_01 from l_sql
     declare ccts01m03_01 cursor for pcts01m03_01

 end function

#-------------------------------#
 function cta01m03(l_doc_handle)
#-------------------------------#


     define l_doc_handle integer
     define l_acesso     smallint
     define l_ligcvntip  like datmligacao.ligcvntip
     define l_confirma   char (01)
     define l_origem     char(5)
     define l_desc       char(30)

     define lr_relat record
                          vclmrcnom like agbkmarca.vclmrcnom,
                          vcltipnom like agbktip.vcltipnom,
                          vclmdlnom like agbkveic.vclmdlnom,
                          vclchs    char(20),
                          vcllicnum like abbmveic.vcllicnum,
                          vclanofbc like abbmveic.vclanofbc,
                          vclanomdl like abbmveic.vclanomdl,
                          segnom    like gsakseg.segnom,
                          segteltxt like gsakend.teltxt,
                          cornom    like gcakcorr.cornom,
                          corsus    like gcaksusep.corsus,
                          corteltxt like gcakfilial.teltxt,
                          ctgtrfcod like abbmcasco.ctgtrfcod,
                          viginc    like abamapol.viginc,
                          vigfnl    like abamapol.vigfnl,
                          emsdat    like abamapol.emsdat,
                          cpfnumdig char(15),
                          cvnnom    char(25),
                          sitdes    char(15),
                          sucnom    char(40)
                      end record

     call cta01m03_prepare()
     initialize m_ctgtrfcod to null
     initialize lr_relat.* to null
     let l_ligcvntip = null
     let l_confirma  = null


     message " Aguarde, formatando os dados..."  attribute(reverse)

     if g_documento.ciaempcod = 35 then
        call cts14g00_azul("",
                      g_documento.ramcod,
                      g_documento.succod,
                      g_documento.aplnumdig,
                      g_documento.itmnumdig,
                      "",
                      "",
                      "N",
                      "2099-12-31 23:00")
     end if
     message ""

     if l_doc_handle is not null then
        call cts40g02_extraiDoXML(l_doc_handle,'CNPJ/CPF')
                      returning lr_relat.cpfnumdig
        
        
        
        call cts40g02_extraiDoXML(l_doc_handle,
                                  'SUCURSAL')
            returning g_documento.succod,
                      lr_relat.sucnom
     end if

     call cts38m00_extrai_dados_veicul(l_doc_handle)
         returning lr_relat.vclmrcnom,
                   lr_relat.vcltipnom,
                   lr_relat.vclmdlnom,
                   lr_relat.vclchs,
                   lr_relat.vcllicnum,
                   lr_relat.vclanofbc,
                   lr_relat.vclanomdl

     call cts38m00_extrai_dados_seg(l_doc_handle)
          returning lr_relat.segnom,
                    lr_relat.segteltxt


     call cts38m00_extrai_dados_corr(l_doc_handle)
          returning lr_relat.cornom,
                    lr_relat.corsus,
                    lr_relat.corteltxt

     call cts38m00_extrai_situacao(l_doc_handle)
          returning lr_relat.sitdes

     call cts38m00_extrai_categoria(l_doc_handle)
          returning lr_relat.ctgtrfcod

     if g_documento.ciaempcod = 35 then
        let m_ctgtrfcod = lr_relat.ctgtrfcod
     end if

     call cts38m00_extrai_vigencia(l_doc_handle)
          returning lr_relat.viginc,
                    lr_relat.vigfnl

     call cts38m00_extrai_origemcalculo(l_doc_handle)
          returning l_origem,l_desc

     ---[altera a situacao no espelho, o XML nao esta alterado - 23/01/07 ]---
     if lr_relat.sitdes <> "CANCELADA" and    # Modificada a Pedido do Ruiz # Amilton
        lr_relat.sitdes <> "RECUSADA"  then  # Modificada a Pedido do Ruiz # Amilton
        if lr_relat.vigfnl < today then
           let lr_relat.sitdes  =  "VENCIDA"
        end if
     end if

     call cts38m00_extrai_emissao(l_doc_handle)
          returning lr_relat.emsdat

     call cta01m03_convenio_itau(l_origem)
          returning l_ligcvntip

     let m_cvnnum = l_ligcvntip
     let g_documento.ligcvntip = l_ligcvntip
     if l_ligcvntip is not null then
         open ccts01m03_01 using l_ligcvntip
     else
        open ccts01m03_01 using g_documento.ligcvntip
     end if

     whenever error continue
     fetch ccts01m03_01 into lr_relat.cvnnom
     whenever error stop

     message ""

     if   g_documento.aplnumdig is not null then

          call cta00m06_acionamento(g_issk.dptsgl)
              returning l_acesso

          if l_acesso = true then
             call cta01m09(g_documento.succod,
                           g_documento.ramcod,
                           g_documento.aplnumdig,
                           g_documento.itmnumdig)
          end if

          open window cta01m03 at 03,02 with form "cta01m03"
                      attribute(form line 1)

          ---> Alerta so para Apolices do Convenio Itau
          if l_ligcvntip = 105 then

           #===========================================================
           # Frase alterada a pedido do Willian Michel em 07/01/2011
           #===========================================================

           #call cts08g01("A","N"," *CONVENIO ITAU*",
           #                      "Esta e uma apólice do convênio Itaú .",
           #                      "Observe os procedimentos diferenciados",
           #                      "a seguir e através do F1.")
           call cts08g01("A","N","* Atenção apólice do Convênio Itaú *",  
                                 "Observe os procedimentos na Base do ",  
                                 "conhecimento.Comunidade Central 24 ",   
                                 "horas / Convênios / Convênio Marcep")   
           returning l_confirma


           #call cts08g01_6l ("A","N","Problemas com proposta: cliente contata",
           #                          "gerente, gerente liga p/ 0800-7230004. ",
           #                          "Endosso: transf seg/ger p/ 2441 (Porto)",
           #                          "e 2442 (Azul).Renovações: transf seg/ger",
           #                          " p/ 1111. Demais assuntos: atender cfe ",
           #                          "procedimentos vigentes.")
           #       returning l_confirma

          end if

          display g_documento.atdnum    to atdnum attribute(reverse)
          display lr_relat.sucnom       to sucnom
          display g_documento.succod    to succod
          display g_documento.aplnumdig to aplnumdig
          display g_documento.itmnumdig to itmnumdig
          display g_documento.edsnumref to edsnumref
          display g_documento.solnom    to solnom
          display g_ppt.emsdat          to emsdat
          display g_ppt.viginc          to viginc
          display g_ppt.vigfnl          to vigfnl
          display g_documento.corsus    to corsus
          display g_ppt.emsdat          to emsdat
          display g_documento.atdnum    to atdnum

          display lr_relat.vclmrcnom    to vclmrcnom
          display lr_relat.cpfnumdig    to cpfnumdig
          display lr_relat.vcltipnom    to vcltipnom
          display lr_relat.vclmdlnom    to vclmdlnom
          display lr_relat.vclchs       to vclchs
          display lr_relat.vcllicnum    to vcllicnum
          display lr_relat.vclanofbc    to vclanofbc
          display lr_relat.vclanomdl    to vclanomdl
          display lr_relat.segnom       to segnom
          display lr_relat.segteltxt    to segteltxt
          display lr_relat.cornom       to cornom
          display lr_relat.corsus       to corsus
          display lr_relat.corteltxt    to corteltxt
          display lr_relat.sitdes       to sitdes
          display lr_relat.ctgtrfcod    to ctgtrfcod
          display lr_relat.viginc       to viginc
          display lr_relat.vigfnl       to vigfnl
          display lr_relat.emsdat       to emsdat

          if l_ligcvntip is not null then
             display lr_relat.cvnnom to cvnnom attribute (reverse)
          else
             display lr_relat.cvnnom to cvnnom
          end if

          call cta01m03_clausulas(l_doc_handle)
          #--------------------------------------------------------
          # Chama o Processo da Contigencia Online
          #--------------------------------------------------------
          call cty42g00(g_documento.ciaempcod ,
                        g_documento.succod    ,
                        g_documento.ramcod    ,
                        g_documento.aplnumdig ,
                        g_documento.itmnumdig ,
                        ""                    ,
                        ""                    ,
                        ""                    ,
                        lr_relat.vcllicnum    )

          close window cta01m03
     end if

 end function

#----------------------------------------#
 function cta01m03_clausulas(l_doc_handle)
#----------------------------------------#

     define l_doc_handle integer,
            l_qtd_end    smallint,
            l_ind        smallint,
            l_aux_char   char(100),
            l_clscod     like aackcls.clscod,
            l_grlchv     like datkgeral.grlchv,
            l_descricao  char(50)

     define la_clausula array[20] of record
                                         clscod like aackcls.clscod,
                                         clsdes like aackcls.clsdes
                                     end record

     define lr_km     record
            kmlimite  smallint,
            qtde      integer
     end record

     define l_confirma char(01)

     initialize la_clausula,
                l_aux_char,
                l_ind,
                l_confirma,
                l_qtd_end,
                l_grlchv to null

     #let l_doc_handle = figrc011_parse(l_xml)

     let l_qtd_end = figrc011_xpath
                     (l_doc_handle,"count(/APOLICE/CLAUSULAS/CLAUSULA)")

     for l_ind = 1 to l_qtd_end

         let l_aux_char = "/APOLICE/CLAUSULAS/CLAUSULA[", l_ind using "<<<<&","]/CODIGO"
         let la_clausula[l_ind].clscod = figrc011_xpath(l_doc_handle,l_aux_char)
	 if la_clausula[l_ind].clscod = "001" then
	    display "COMPREENSIVA" to cbtdes  # cobertura
         end if

         let l_aux_char = "/APOLICE/CLAUSULAS/CLAUSULA[", l_ind using "<<<<&", "]/DESCRICAO"

         if  la_clausula[l_ind].clscod = "037" then
	     ---> Busca descricao da Assistencia
             call cts40g02_extraiDoXML(l_doc_handle,'ASSISTENCIA_DESCRICAO')
                                       returning l_descricao

	     if l_descricao is not null and
                l_descricao <> " "      then

                case l_descricao
                   when "ASSISTENCIA PLUS II"
                      let la_clausula[l_ind].clsdes = 'ASSISTENCIA 24hrs PL.PLUS II'

                   when "ASSISTENCIAPLUS II"
                      let la_clausula[l_ind].clsdes = 'ASSISTENCIA 24hrs PL.PLUS II'

                   when "ASSISTENCIA PLUSII"
                      let la_clausula[l_ind].clsdes = 'ASSISTENCIA 24hrs PL.PLUS II'

                   when "SEM ASSISTENCIA"
                      let la_clausula[l_ind].clsdes = 'SEM ASSISTENCIA'

                   when "SEMASSISTENCIA"
                      let la_clausula[l_ind].clsdes = 'SEM ASSISTENCIA'


                   when "ASSISTENCIA REDE REFERENCIADA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-REDE REFERENCIADA'

                   when "ASSISTENCIAREDE REFERENCIADA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-REDE REFERENCIADA'

                   when "ASSISTENCIA REDEREFERENCIADA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-REDE REFERENCIADA'

                   when "ASSISTENCIA LIVRE ESCOLHA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-LIVRE ESCOLHA'

                   when "ASSISTENCIALIVRE ESCOLHA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-LIVRE ESCOLHA'

                   when "ASSISTENCIA LIVREESCOLHA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-LIVRE ESCOLHA'

                   when "ASSISTENCIA PLUS II - LIVRE ESCOLHA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-LIVRE ESCOLHA'

                   when "ASSISTENCIAPLUS II - LIVRE ESCOLHA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-LIVRE ESCOLHA'

                   when "ASSISTENCIA PLUSII - LIVRE ESCOLHA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-LIVRE ESCOLHA'

                   when "ASSISTENCIA PLUS II- LIVRE ESCOLHA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-LIVRE ESCOLHA'

                   when "ASSISTENCIA PLUS II -LIVRE ESCOLHA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-LIVRE ESCOLHA'

                   when "ASSISTENCIA PLUS II - LIVREESCOLHA"
                      let la_clausula[l_ind].clsdes = 'ASSIST.24h-LIVRE ESCOLHA'

                   otherwise
                      let la_clausula[l_ind].clsdes = "** NAO CADASTRADA **"
                end case
             end if
         else
            ----[ busca descricao da clausula do cadastro(ctc62m00)]----
            let l_grlchv = "CLS.AZUL.", la_clausula[l_ind].clscod

            select grlinf
               into la_clausula[l_ind].clsdes
               from datkgeral
              where grlchv = l_grlchv

            if sqlca.sqlcode = notfound then
               let la_clausula[l_ind].clsdes =
                   figrc011_xpath(l_doc_handle, l_aux_char)
            end if
         end if
     end for

     if  la_clausula[1].clscod is null then
         let la_clausula[l_ind].clsdes = "NENHUMA CLAUSULA  ***"
     end if

     call cta01m03_controle_atendimento()

     # Inicio Alerta para Categoria Tarifaria 80 e 81 - Taxi - tarifa Azul 05/2013
     if g_documento.ciaempcod   = 35     and # Empresa 35 -> Azul
         (m_ctgtrfcod           = 80 or      # Codigo tarifário
          m_ctgtrfcod           = 81)   then # Codigo tarifário
        #===========================================================
        # Tarifa 05/2013 Azul - taxi
        #===========================================================
        let l_confirma = "N"
        while l_confirma = "N"
           call cts08g01("C","S","",
                                 "Apolice comercializada como Taxi",
                                 "",
                                 "sem direito ao beneficio sinistro.")
           returning l_confirma

           if l_confirma = "N" then
              continue while
           else
              exit while
           end if
        end while
     end if
     # Fim Alerta para Categoria Tarifaria 80 e 81 - Taxi - tarifa Azul 05/2013

     message "(F1)Funcoes (F4)Corretor (F7)IS (F8)Acessorios (F10)Outras Info."

     call set_count(l_ind - 1)
     display array la_clausula to s_cta01m03.*

         on key(interrupt,control-c,f17)
            if g_documento.atdnum is null or
               g_documento.atdnum =  " "  then

               initialize l_confirma to null

               while l_confirma = "N"      or
                     l_confirma = " "      or
                     l_confirma is null

                  call cts08g01("A","S",""
                                ,"CONFIRMOU OS DADOS DO CLIENTE ? "
                                ,"","")
                       returning l_confirma

               end while
            end if
	    exit display


         on key (return)
            let l_ind = arr_curr()
            let l_clscod = la_clausula[l_ind].clscod

            call ctc56m03(35,                # empresa
                          g_documento.ramcod,
                          0,                 # modalidade
                          l_clscod)
         on key(f1)
            call cta01m10_auto(g_documento.ramcod,
                               g_documento.succod,
                               g_documento.aplnumdig,
                               g_documento.itmnumdig,
                               g_funapol.dctnumseq,
                               g_documento.prporg,
                               g_documento.prpnumdig,
                               m_cvnnum, # param.cvnnum)
                               0) # Tipo de chamada
         on key(f4)
            call ctn09c00("")

         on key(f7)
            call cta01m17(l_doc_handle)

         on key(f8)
            call cta01m01()

         on key(f10)
           call cta01m04("","","","","","","")



     end display

 end function

#----------------------------------------#
function cta01m03_controle_atendimento()
#----------------------------------------#

     if g_documento.succod    is not null and
        g_documento.ramcod    is not null and
        g_documento.aplnumdig is not null and
        g_documento.itmnumdig is not null then

        if g_documento.apoio <> 'S' or
           g_documento.apoio is null then

           call cta02m20(g_documento.succod   ,
                         g_documento.ramcod   ,
                         g_documento.aplnumdig,
                         g_documento.itmnumdig,
                         " ", " " )
        end if

     end if

end function


---------------------------------------------------------------------------
function cta01m03_convenio_itau(lr_param)
---------------------------------------------------------------------------

    define lr_param record
         origem   char(5)
    end record

    define lr_retorno smallint

    let lr_retorno = null


    if lr_param.origem = '02' then
       let lr_retorno = 105
    end if



    return lr_retorno

end function
