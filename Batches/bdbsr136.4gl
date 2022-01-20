#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Integracao Carro Extra                                    #
# Modulo         : bdbsr136.4gl                                              #
#                  Gera um relatório diário com informações das transmissões #
#                  de reservas para acompanhamento e geracao dos indicadores #
#                  de processamento. Este relatório será enviado por e-mail. #
#                  e gera arquivo xls                                        #
# Analista Resp. : Weliton S. Rosa                                           #
#............................................................................#
# Desenvolvimento: Fornax                                                    #
# Data           : 02/06/2011                                                #
#............................................................................#
#                          * * *  ALTERACOES  * * *                          #
#                                                                            #
# Data        Autor Fabrica  PSI/CT     Alteracao                            #
# ----------  -------------  ---------- -------------------------------------#
# 15/01/2013  Celso Issamu   1301114043 Alteracao da Periodicidade para      #
#                                       Execução diária                      #
#----------------------------------------------------------------------------#
   database porto
#----------------------------------------------------------------------------#
   define m_data_inicial date
   define m_data_final   date
   define m_path_relato  char(100)

   #--> Contadores
   #--------------
   define m_qtde_localiza                   smallint #--> todos status.
   define m_qtde_nao_processada             smallint #--> status=1 (Solicitada)
   define m_qtde_em_processamento           smallint #--> status=2(Encaminhada)
   define m_qtde_via_integracao             smallint #--> status=4 (cancelado)
   define m_qtde_com_confirmacoes_imediatas smallint #--> status=3(RespostaObtida)
   define m_qtde_com_erro_negocio           smallint #--> status=6 ou 7(Divergente 
                                                     #    ou DadosInconsistentes)
   define m_qtde_com_erro_sistema           smallint #--> status=8 (ErroInterface)
#----------------------------------------------------------------------------#
main

   define l_relatorio  record
          atdsrvnum    like datmavisrent.atdsrvnum    ,
          atdsrvano    like datmavisrent.atdsrvano    ,
          ciaempcod    like datmservico.ciaempcod     ,
          avilocnom    like datmavisrent.avilocnom    ,
          rsvlclcod    like datmrsvvcl.rsvlclcod      ,
          loccntcod    like datmrsvvcl.loccntcod      ,
          vclitfseq    like datmvclrsvitf.vclitfseq   ,
          itftipcod    like datmvclrsvitf.itftipcod   ,
          itfsttcod    like datmvclrsvitf.itfsttcod   ,
          itfenvhordat like datmvclrsvitf.itfenvhordat,
          itfrethordat like datmvclrsvitf.itfrethordat,
          intsttcrides like datmvclrsvitf.intsttcrides,
          lcvcod       like datklocadora.lcvcod       ,
          lcvnom       like datklocadora.lcvnom       ,
          lcvextcod    like datkavislocal.lcvextcod   ,
          aviestcod    like datkavislocal.aviestcod   ,
          aviestnom    like datkavislocal.aviestnom 
   end record

   define l_path_log      char(100)

   define l_atdsrvnum_ant like datmavisrent.atdsrvnum
   define l_vclitfseq_ant like datmvclrsvitf.vclitfseq
   define l_itfsttcod_ant like datmvclrsvitf.itfsttcod    
   define l_msg           char(100)
   define l_erro          smallint

   define l_data_parametro date
   
   set isolation to dirty read   

   #--> Gerando Alerta no LOG de Inicio de processamento do relatorio
   #-----------------------------------------------------------------
   call cts40g03_exibe_info("I","BDBSR136")

   #--> Incializando Contadores    
   let m_qtde_localiza                   = 0
   let m_qtde_nao_processada             = 0
   let m_qtde_em_processamento           = 0
   let m_qtde_via_integracao             = 0
   let m_qtde_com_confirmacoes_imediatas = 0
   let m_qtde_com_erro_negocio           = 0
   let m_qtde_com_erro_sistema           = 0 

   #--> Definido caminho para LOG e RELATO
   #--------------------------------------
   call fun_dba_abre_banco("CT24HS")

   let l_path_log = f_path("DBS","LOG")
   if l_path_log is null then
      let l_path_log = "."
   end if

   let l_path_log = l_path_log clipped, "/bdbsr136.LOG"
   call startlog(l_path_log)

   let m_path_relato = f_path("DBS", "RELATO")
   if m_path_relato is null then
       let m_path_relato = "."
   end if
   let m_path_relato  = m_path_relato clipped, "/bdbsr136.xls"

   #--> Processo de Identificacao da data de processamento
   #------------------------------------------------------
   # Executando sempre o dia anterior a data de processamento
   # Se receber uma data de parametro executa a data solicitada
   #-----------------------------------------------------------
   let l_data_parametro = arg_val(1)

   if l_data_parametro is not null then
      let m_data_inicial = l_data_parametro - 1 units day
      let m_data_final   = l_data_parametro - 1 units day
   else
      let m_data_inicial = today - 1 units day
      let m_data_final   = today - 1 units day
   end if
   
   #--> Comentado(Utilizar somente para processar uma data específica)
    #let m_data_inicial = '01/06/2011'
    #let m_data_final   = '31/12/2011'
   #------------------------------------------------------------------

   #--> Processo Principal Lendo registros a serem processados
   #----------------------------------------------------------

   #database porto@u18wr
     
   display "Periodo do relatorio: ",m_data_inicial," ate ",m_data_final
     
   start report relatorio_bdbsr136 to m_path_relato

   declare cbdbsr136001 cursor for 
      select a.atdsrvnum,      #--> Numero da Reserva Central
             a.atdsrvano,      #--> Ano da Reserva da Central
             f.ciaempcod,      #--> Empresa dos servico
             a.avilocnom,      #--> Nome do locatario
             b.rsvlclcod,      #--> Codigo Localizador
             b.loccntcod,      #--> Codigo do Contrato
             c.vclitfseq,      #--> Sequencia Interface
             c.itftipcod,      #--> Tipo da Interface
             c.itfsttcod,      #--> Status da Interface
             c.itfenvhordat,   #--> Data/hora do envio
             c.itfrethordat,   #--> Data/hora do retorno
             c.intsttcrides,   #--> Mensagem de Erro  
             d.lcvcod      ,   #--> Codigo da Locadora
             d.lcvnom      ,   #--> Nome da Locadorea
             e.lcvextcod   ,   #--> Codigo Extenso da Loja
             e.aviestcod   ,   #--> Codigo da Loja da Locadora
             e.aviestnom       #--> Nome da Loja Locadora,
        from datmavisrent a, 
	     datmrsvvcl b, 
	     datmvclrsvitf c, 
	     datklocadora d, 
	     datkavislocal e,
	     datmservico f
         where a.atdsrvnum = b.atdsrvnum
           and a.atdsrvano = b.atdsrvano
           and b.atdsrvnum = c.atdsrvnum
           and b.atdsrvano = c.atdsrvano 
           and a.atdsrvnum = f.atdsrvnum
           and a.atdsrvano = f.atdsrvano
           and a.lcvcod    = d.lcvcod
           and a.lcvcod    = e.lcvcod
           and a.aviestcod = e.aviestcod
           and 
              (date(c.itfenvhordat) = m_data_inicial
               or
               date(c.itfrethordat) = m_data_inicial)
         order by a.atdsrvnum, a.atdsrvano, c.vclitfseq


   let l_atdsrvnum_ant = 0
   let l_vclitfseq_ant = 0
   let l_itfsttcod_ant = 0

   initialize l_relatorio.* to null
   display "Inicio Relatorio"
   output to report relatorio_bdbsr136 (l_relatorio.*)   
   display "-----"
   foreach cbdbsr136001 into l_relatorio.*
   
      if l_atdsrvnum_ant = 0 then
         let l_atdsrvnum_ant = l_relatorio.atdsrvnum
         let l_vclitfseq_ant = l_relatorio.vclitfseq
         let l_itfsttcod_ant = l_relatorio.itfsttcod
      end if

      if l_relatorio.atdsrvnum <> l_atdsrvnum_ant then
         call bdbsr136_soma_contadores(l_itfsttcod_ant)
         let l_atdsrvnum_ant = l_relatorio.atdsrvnum
         let l_vclitfseq_ant = l_relatorio.vclitfseq
         let l_itfsttcod_ant = l_relatorio.itfsttcod
      end if

      display "Numero_Servico", l_relatorio.atdsrvnum
      # Código Localizador         rsvlclcod
      # Código do Contrato         loccntcod
      # Nome do locatario          avilocnom
      # Tipo da Interface          itftipcod
      # status Interface           itfsttcod
      # Data/hora do envio         itfenvhordat 
      # Data/hora do retorno       itfrethordat
      # Mensagem de Erro           intsttcrides

      output to report relatorio_bdbsr136 (l_relatorio.*)

   end foreach
   call bdbsr136_soma_contadores(l_relatorio.itfsttcod)

   finish report relatorio_bdbsr136
    
   call modulo_envia_email(m_data_inicial)
   
   let l_erro = ctx22g00_envia_email("BDBSR136", 
                                     "Relatorio Integracao Carro Extra - Localiza", 
                                     m_path_relato)
   
   
   display "-----"
   #--> Gerando Alerta no LOG de Final de processamento do relatorio
   #----------------------------------------------------------------
   call cts40g03_exibe_info("F","BDBSR136")


end main
#------------------------------------------------------------------------------#
function modulo_envia_email(l_cpt)
   
   define l_cpt date

   define l_i smallint
   define l_destinatario char(100)
   define l_remetente    char(100)
   define l_relatorio   char(100)
         ,l_destino     char(200)
         ,l_coderro     smallint
         ,l_total       smallint
         ,l_corpo       char(32766)

   let l_relatorio = null
   let l_destino   = null
   let l_coderro   = 0
   let l_total     = 0
   let l_corpo     = null

   let l_corpo = '<html> ',
                   '<body style="font-family: verdana;" ',
                   '<html> ',
                   '<body style="font-family: verdana;"> ',
                     '<br><br> ',
	             '<table style="width: 530px; border-collapse: collapse;  ',
                            ' font-size: 11px;"> ',
		     '<tr style="text-align: center;"> ',
		     '<td colspan="2" style="border: 1px solid; ',
                            ' background-color: darkBlue; ',
                            ' font-weight: bold; color: ',
                            ' white;">RELATORIOS GERENCIAIS PORTO SOCORRO - ',
                            ' INTEGRACAO COM AS LOCADORAS<td> ',
		     '</tr> ',
		     '<tr> ',
		     '<td>&nbsp;</td> ',
		     '<td></td> ',
		     '</tr> ',
		     '<tr style="text-align: center;"> ',
		     '<td colspan="2" style="border: 1px solid; ',
                            ' background-color: lightBlue; ',
                            ' font-weight: bold;">RESUMO DA INTERFACE LOCALIZA NO DIA - ',l_cpt,'<td> ',
		     '</tr> ',

		     '<tr> ',
		     '<td style="width: 420px; border: ',
                            ' 1px solid;">Quantidade de comunicacoes com a Localiza</td> ',
		     '<td style="border: ',
                            ' 1px solid;text-align: center;">',m_qtde_localiza,'</td> ',
		     '</tr> ',

		     '<tr> ',
		     '<td style="width: 420px; border: ',
                            ' 1px solid;">Quantidade de comunicacoes nao processada</td> ',
		     '<td style="border: ',
                            ' 1px solid;text-align: center;">',m_qtde_nao_processada,'</td> ',
		     '</tr> ',


		     '<tr> ',
		     '<td style="width: 420px; border: ',
                            ' 1px solid;">Quantidade de comunicacoes em processamento</td> ',
		     '<td style="border: ',
                            ' 1px solid;text-align: center;">',m_qtde_em_processamento,'</td> ',
		     '</tr> ',

		     '<tr> ',
		     '<td style="width: 420px; border: ',
                            ' 1px solid;">Quantidade de comunicacoes via integracao</td> ',
		     '<td style="border: ',
                            ' 1px solid;text-align: center;">',m_qtde_via_integracao,'</td> ',
		     '</tr> ',

		     '<tr> ',
		     '<td style="width: 420px; border: ',
                            ' 1px solid;">Quantidade de comunicacoes com confirmacoes imediatas</td> ',
		     '<td style="border: ',
                            ' 1px solid;text-align: center;">',m_qtde_com_confirmacoes_imediatas,'</td> ',
		     '</tr> ', 

		     '<tr> ',
		     '<td style="width: 420px; border: ',
                            ' 1px solid;">Quantidade de comunicacoes com erro de negocios</td> ',
		     '<td style="border: ',
                            ' 1px solid;text-align: center;">',m_qtde_com_erro_negocio,'</td> ',
		     '</tr> ',

		     '<tr> ',
		     '<td style="width: 420px; border: ',
                            ' 1px solid;">Quantidade de comunicacoes com erro de sistema</td> ',
		     '<td style="border: ',
                            ' 1px solid;text-align: center;">',m_qtde_com_erro_sistema,'</td> ',
		     '</tr> ',

		     '</table> ',
                   '</body> ',
                 '</html> '

   #--> Selecionando o destino dos emails
   #-------------------------------------
   
   let l_coderro = ctx22g00_envia_email_html("BDBSR136", 
                                             "Integracao Carro Extra - Localiza", 
                                             l_corpo)
   
   
   if l_coderro <> 0 then
      display  'Problemas ao enviar e-mail do relatorio de ',
               'Integracao Carro Extra - Localiza.'
   end if

end function
#------------------------------------------------------------------------------#
report relatorio_bdbsr136(l_relatorio)

   define l_relatorio  record
          atdsrvnum    like datmavisrent.atdsrvnum    ,
          atdsrvano    like datmavisrent.atdsrvano    ,
          ciaempcod    like datmservico.ciaempcod     ,
          avilocnom    like datmavisrent.avilocnom    ,
          rsvlclcod    like datmrsvvcl.rsvlclcod      ,
          loccntcod    like datmrsvvcl.loccntcod      ,
          vclitfseq    like datmvclrsvitf.vclitfseq   ,
          itftipcod    like datmvclrsvitf.itftipcod   ,
          itfsttcod    like datmvclrsvitf.itfsttcod   ,
          itfenvhordat like datmvclrsvitf.itfenvhordat,
          itfrethordat like datmvclrsvitf.itfrethordat,
          intsttcrides like datmvclrsvitf.intsttcrides,
          lcvcod       like datklocadora.lcvcod       ,
          lcvnom       like datklocadora.lcvnom       ,
          lcvextcod    like datkavislocal.lcvextcod   ,
          aviestcod    like datkavislocal.aviestcod   ,
          aviestnom    like datkavislocal.aviestnom 
   end record

   define l_valor_char    char(30)
   define l_i             smallint
   define l_itfsttcod_des like iddkdominio.cpodes
   define l_itftipcod_des like iddkdominio.cpodes

   output
      top    margin 0
      left   margin 0
      right  margin 0
      bottom margin 0
      page   length 1
      

   format

      on every row

         if pageno = 01 then
            print "Nr. Reserva Central"	 , ascii(09),
                  "Empresa"              , ascii(09),
                  "Código Localizador"   , ascii(09),
                  "Código do Contrato"   , ascii(09),
                  "Código da Locadora"   , ascii(09), 
                  "Nome da Locadora"     , ascii(09), 
                  "Código da Loja"       , ascii(09),
                  "Sigla Loja"           , ascii(09),
                  "Nome da Loja"         , ascii(09), 
                  "Nome do Locatario"    , ascii(09),
                  "Tipo da Interface"    , ascii(09),
                  "status Interface"     , ascii(09),
                  "Data do Envio"        , ascii(09),
                  "Hora do Envio"        , ascii(09),
                  "Data do Retorno"      , ascii(09),
                  "Hora do Retorno"      , ascii(09),
                  "Mensagem de Erro"     , ascii(09)
         else 
           let l_itfsttcod_des = "NAO ENCONTRADO"
           select cpodes into l_itfsttcod_des from iddkdominio
              where cponom = 'itfsttcod'
                and cpocod = l_relatorio.itfsttcod

           let l_itftipcod_des = "NAO ENCONTRADO"
           select cpodes into l_itftipcod_des from iddkdominio
              where cponom = 'itftipcod'
                and cpocod = l_relatorio.itftipcod 

           print l_relatorio.atdsrvnum using "<<<<<<<<<<<<",
                 "-",
                 l_relatorio.atdsrvano using "<<<<" , ascii(09),
                 l_relatorio.ciaempcod    , ascii(09),
                 l_relatorio.rsvlclcod    , ascii(09),
                 l_relatorio.loccntcod    , ascii(09), 

                 l_relatorio.lcvcod       , ascii(09),
                 l_relatorio.lcvnom       , ascii(09),

                 l_relatorio.aviestcod    , ascii(09),
                 l_relatorio.lcvextcod    , ascii(09),
                 l_relatorio.aviestnom    , ascii(09),
                                 
                 l_relatorio.avilocnom    , ascii(09),

                 #l_relatorio.itftipcod    , ascii(09),
                 l_itftipcod_des          , ascii(09),

                 #l_relatorio.itfsttcod    , ascii(09),
                 l_itfsttcod_des          , ascii(09),

                 date(l_relatorio.itfenvhordat) , ascii(09),
                 extend(l_relatorio.itfenvhordat,hour to second) , ascii(09),
                 date(l_relatorio.itfrethordat) , ascii(09),
                 extend(l_relatorio.itfrethordat,hour to second) , ascii(09),
                 l_relatorio.intsttcrides , ascii(09)
         end if

end report  
#------------------------------------------------------------------------------#
function modulo_email(dest
                     ,sbjct
                     ,msg
                     ,l_path
                     ,l_remetente)

  define l_run       char(2000)

  define dest        char(1000)
        ,sbjct       char(1000)
        ,msg         char(32766)
        ,l_path      char(300)
        ,l_remetente char(100)

  define l_cod smallint
  define l_msg char(80)

  call figrc009_attach_file(l_path)

  call figrc009_mail_send1(l_remetente,
                         dest,
                         " ",
                         " ",
                         sbjct,
                         msg,
                         "0",
                         "HTML")
     returning l_cod, l_msg

  return l_cod

end function
#------------------------------------------------------------------------------#
function bdbsr136_soma_contadores(l_itfsttcod)

   #--> m_qtde_localiza                   -> todos status.
   #--> m_qtde_nao_processada             -> status=1 (Solicitada)
   #--> m_qtde_em_processamento           -> status=2(Encaminhada)
   #--> m_qtde_via_integracao             -> status=4 (cancelado)
   #--> m_qtde_com_confirmacoes_imediatas -> status=3(RespostaObtida)
   #--> m_qtde_com_erro_negocio           -> status=6 ou 7 (Divergente ou DadosInconsistentes)
   #--> m_qtde_com_erro_sistema           -> status=8 (ErroInterface)

   define l_itfsttcod like datmvclrsvitf.itfsttcod

   let m_qtde_localiza = m_qtde_localiza + 1
   
   display "bdbsr136_soma_contadores - l_itfsttcod ", l_itfsttcod
   
   case l_itfsttcod
      when 1
         let m_qtde_nao_processada = m_qtde_nao_processada + 1
      when 2
         let m_qtde_em_processamento = m_qtde_em_processamento + 1
      when 3
         let m_qtde_com_confirmacoes_imediatas = m_qtde_com_confirmacoes_imediatas + 1
      when 4
         let m_qtde_via_integracao = m_qtde_via_integracao + 1
      when 6
         let m_qtde_com_erro_negocio = m_qtde_com_erro_negocio + 1
      when 7
         let m_qtde_com_erro_negocio = m_qtde_com_erro_negocio + 1
      when 8
         let m_qtde_com_erro_sistema = m_qtde_com_erro_sistema + 1
   end case


end function
#---------------------------------------------------------- Final do Modulo ---#
