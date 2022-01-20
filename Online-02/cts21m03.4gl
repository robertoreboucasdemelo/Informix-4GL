#############################################################################
# Nome do Modulo: CTS21M03                                          Marcelo #
#                                                                  Gilberto #
# Consulta & Cancelamento de Vistoria de Sinistro de R.E.          Nov/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 25/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-  #
#                                       coes, com a utilizacao de funcoes.  #
#---------------------------------------------------------------------------#
# 09/12/1999  PSI 7263-0   Gilberto     Utilizar funcao CTS20G01 para aces- #
#                                       sar documento de referencia.        #
#---------------------------------------------------------------------------#
# 22/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# Fabrica de Software                                                       #
# 07/08/2001  PSI 120340   Junior       Inclusao do motivo de cancelamento  #
#                                       Tela para consulta do cancelamento  #
#---------------------------------------------------------------------------#
# 19/12/2001  PSI 130257   Ruiz         Alteracao no acionamento dos        #
#                                       reguladores.                        #
#---------------------------------------------------------------------------#
# 03/03/2006  Zeladoria    Priscila     Buscar data e hora do banco de dados#
#---------------------------------------------------------------------------#
# 16/06/2006  PSI 200140   Priscila     Atalho para exibir cobertura/naturez#
#                                       da vistoria de sisnitro             #
#---------------------------------------------------------------------------#
# 18/09/2006  PSI 199850   Priscila     Atualizar ao transferir ligacao     #
#                                       para sistema RE                     #
#---------------------------------------------------------------------------#
# 21/09/2006  Ligia Mattge   PSI202720  Passando ult.campo nulo no cts16g00 #
#---------------------------------------------------------------------------#
# 05/01/2010  Amilton                   Projeto sucursal smallint           #
#---------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo PSI 219444  .acessar datmpedvsit p/ selecionar  #
#                                        Local de Risco / Bloco para chamar #
#                                        o espelho com o docto correto      #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define l_fim smallint
define aux_jitre   char(01)
define w_succod          like datrligapol.succod
define w_ramcod          like datrligapol.ramcod
define w_aplnumdig       like datrligapol.aplnumdig
define w_itmnumdig       like datrligapol.itmnumdig
define w_edsnumref       like datrligapol.edsnumref
define w_prporg          like datrligprp.prporg
define w_prpnumdig       like datrligprp.prpnumdig
define w_fcapacorg       like datrligpac.fcapacorg
define w_fcapacnum       like datrligpac.fcapacnum
define w_itaciacod       like datrligitaaplitm.itaciacod  


#----------------------------------------------------------------------
 function cts21m03(param)
#----------------------------------------------------------------------

 define param   record
    sinvstnum   like datmvstsin.sinvstnum ,
    sinvstano   like datmvstsin.sinvstano
 end record

 define d_cts21m03  record
    vistoria        char (11)                 ,
    vstsolnom       like datmpedvist.vstsolnom,
    segnom          like datmpedvist.segnom   ,
    doctxt          char (37)                 ,
    cornom          like datmpedvist.cornom   ,
    cvnnom          char (19)                 ,
    lclrsccod       like datmpedvist.lclrsccod,
    lclendflg       like datmpedvist.lclendflg,
    lgdtip          like datmpedvist.lgdtip   ,
    lgdnom          like datmpedvist.lgdnom   ,
    lgdnum          like datmpedvist.lgdnum   ,
    lgdnomcmp       like datmpedvist.lgdnomcmp,
    endbrr          like datmpedvist.endbrr   ,
    endcep          like datmpedvist.endcep   ,
    endcepcmp       like datmpedvist.endcepcmp,
    endcid          like datmpedvist.endcid   ,
    endufd          like datmpedvist.endufd   ,
    endddd          like datmpedvist.endddd   ,
    teldes          like datmpedvist.teldes   ,
    lclcttnom       like datmpedvist.lclcttnom,
    endrefpto       like datmpedvist.endrefpto,
    #sinntzcod       like datmpedvist.sinntzcod,     #PSI 200140
    #sinntzdes       like sgaknatur.sinntzdes  ,     #PSI 200140
    sindat          like datmpedvist.sindat   ,
    sinhor          like datmpedvist.sinhor   ,
    #orcvlr          like datmpedvist.orcvlr   ,     #PSI 200140
    sinpricod       like datmpedvist.sinpricod,
    nomrazsoc       like sgkkperi.nomrazsoc   ,
    funnom          char (20)                 ,
    sinvstdat       like datmpedvist.sinvstdat,
    sinvsthor       like datmpedvist.sinvsthor,
    rglvstflg       like datmpedvist.rglvstflg,
    vstsoltip       like datmpedvist.vstsoltip
 end record

 define k_cts21m03  record
    sinvstnum       like datmvstsin.sinvstnum,
    sinvstano       like datmvstsin.sinvstano
 end record

 define h_cts21m03  record
    sinhst          like datmpedvist.sinhst ,
    sinobs          like datmpedvist.sinobs
 end record

 define ws          record
    sinpricod       like datmpedvist.sinpricod,
    pgrflg          smallint,
    confirma        char(01),
    vstsolstt       like datmpedvist.vstsolstt,
    funmat          like datmpedvist.funmat ,
    funnom          char(20),
    dtplantao       char(10),
    motivo          char(50),
    sindat          like datmpedvist.sindat,
    sinhor          like datmpedvist.sinhor,
    sinvstnum       like datmsrvre.sinvstnum,  # psi 172413
    sinvstano       like datmsrvre.sinvstano
 end record

 ---> Danos Eletricos
 define lr_retorno1    record
        erro           smallint,
        lignum         like datratdlig.lignum
 end record

 define v_count     smallint
 define aux_today   char(10)
 define aux_hora    char(05)
 define aux_selec   char(01)
 define aux_char    char(04)
 define aux_ano2    dec (2,0)
 define l_acesso    smallint

 define  cpl_atdsrvnum like datmservico.atdsrvnum,
         cpl_atdsrvano like datmservico.atdsrvano,
         cpl_atdsrvorg like datmservico.atdsrvorg

 define l_prpflg    char(01),
        l_opcao     smallint,
        l_opcaodes  char(20)

 define l_data      date,
        l_hora2     datetime hour to minute

 #PSI 199850
 define  l_transfere like sremligsnc.sncinftxt

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     v_count  =  null
        let     aux_today  =  null
        let     aux_hora  =  null
        let     aux_selec  =  null
        let     aux_char  =  null
        let     aux_ano2  =  null
        let     cpl_atdsrvnum  =  null
        let     cpl_atdsrvano  =  null
        let     cpl_atdsrvorg  =  null
        let     l_prpflg  =  null
        let     l_opcao  =  null
        let     l_opcaodes  =  null
        let     l_data  =  null
        let     l_hora2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_cts21m03.*  to  null

        initialize  k_cts21m03.*  to  null

        initialize  h_cts21m03.*  to  null

        initialize  ws.*  to  null

        initialize  lr_retorno1.* to null


 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
 let aux_today       = l_data
 let aux_hora        = l_hora2

 let aux_selec       = "N"
 let aux_jitre       = "N"
 let l_transfere     = null

 initialize d_cts21m03, h_cts21m03, k_cts21m03, ws to null

 open window cts21m03 at 04,02 with form "cts21m03"

 menu "VISTORIA R.E."

   before menu
    #  initialize aux_jitre to null                # psi 172413
      if g_documento.c24astcod = "P10" and        # esta situacao acontece
         g_documento.atdsrvnum is null then       # qdo este modulo e chamado
         let aux_jitre = "N"                      # pelo laudo cts04m00.
      else
         if g_documento.atdsrvnum is not null then # esta situacao acontece
            select sinvstnum,sinvstano             # qdo este modulo e chamado
               into ws.sinvstnum,ws.sinvstano      # pela telas de consulta.
               from datmsrvre
              where atdsrvnum = g_documento.atdsrvnum
                and atdsrvano = g_documento.atdsrvano
            if sqlca.sqlcode <> notfound then
               if ws.sinvstnum = param.sinvstnum and
                  ws.sinvstano = param.sinvstano then
                  let aux_jitre = "N"
               end if
            end if
          end if
      end if
     #if aux_jitre is null then                 # psi 172413
      let aux_char = param.sinvstano
      let aux_ano2 = aux_char[3,4]
      select refatdsrvnum, refatdsrvano
        from datmsrvjit
       where refatdsrvnum = param.sinvstnum
         and refatdsrvano = aux_ano2

      if status <> notfound then
         let aux_jitre = "S"

         hide option "Regulador"
         hide option "Pager"
         hide option "Cancela"
      end if
     #end if
   command key ("S") "Seleciona" "Seleciona vistoria de sinistro"
       initialize ws.*  to null
       call seleciona_cts21m03(param.sinvstnum, param.sinvstano)
            returning k_cts21m03.sinvstnum, k_cts21m03.sinvstano
            let aux_selec = "S"

   command key (F1)
      if aux_selec = "S" then
         if g_documento.c24astcod is not null then
            call ctc58m00_vis(g_documento.c24astcod)
         end if
      end if

   command key(F3)
       select vstsolstt
          into ws.vstsolstt
          from datmpedvist
         where sinvstnum = k_cts21m03.sinvstnum  and
               sinvstano = k_cts21m03.sinvstanO
       if ws.vstsolstt = 3  or
          ws.vstsolstt = 4  then
          call mostra_cts21m03(param.sinvstnum, param.sinvstano)
          message ""
       end if

   #PSI 200140
   command key (F4)
       call cts21m11(param.sinvstnum, param.sinvstano)

   command key (F5)
      if aux_selec = "S" then

         let g_documento.succod    = w_succod
         let g_documento.ramcod    = w_ramcod
         let g_documento.aplnumdig = w_aplnumdig
         let g_documento.itmnumdig = w_itmnumdig
         let g_documento.prporg    = w_prporg
         let g_documento.prpnumdig = w_prpnumdig

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

   command key (F6)
      if aux_selec = "S" then

         if g_documento.atdsrvnum is null then
            call cts14m10(param.sinvstnum,
                          param.sinvstano,
                          g_issk.funmat,
                          aux_today,
                          aux_hora)
         else
            if aux_selec = "S" and aux_jitre = "S" then
               call cts10n00(g_documento.atdsrvnum,
                             g_documento.atdsrvano,
                             g_issk.funmat,
                             aux_today,
                             aux_hora)
            else
               call cts14m10(param.sinvstnum,
                             param.sinvstano,
                             g_issk.funmat,
                             aux_today,
                             aux_hora)
            end if
         end if
      end if

   command key (F7)
      if aux_selec = "S" and aux_jitre = "S" then
         call ctx14g00("Funcoes","Impressao|Condutor|Caminhao|Distancia")
              returning l_opcao,
                        l_opcaodes
         case l_opcao
            when 1  ### Impressao
               if g_documento.atdsrvnum is null then
                  ERROR " Impressao somente com cadastramento do servico!"
               else
                  call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
               end if

            when 2  ### Condutor
               if g_documento.succod    is not null and
                  g_documento.ramcod    is not null and
                  g_documento.aplnumdig is not null then
                  select clscod
                    from abbmclaus
                   where succod    = g_documento.succod    and
                         aplnumdig = g_documento.aplnumdig and
                         itmnumdig = g_documento.itmnumdig and
                         dctnumseq = g_funapol.dctnumseq   and
                         clscod    = "018"
                  if sqlca.sqlcode  = 0  then
                     if g_documento.atdsrvnum is null or
                        g_documento.atdsrvano is null then
                        if g_documento.cndslcflg = "S"  then
                           call cta07m00(g_documento.succod,
                                         g_documento.aplnumdig,
                                         g_documento.itmnumdig, "I")
                        else
                           call cta07m00(g_documento.succod,
                                         g_documento.aplnumdig,
                                         g_documento.itmnumdig, "C")
                        end if
                     else
                        call cta07m00(g_documento.succod,
                                      g_documento.aplnumdig,
                                      g_documento.itmnumdig, "C")
                     end if
                  else
                      error "Docto nao possui clausula 18 !"
                  end if
               else
                  error "Condutor so' com Documento localizado!"
               end if
         end case
      end if

   command key (F8)
      call cts21m03_mostra_p10(param.sinvstnum, param.sinvstano)
           returning lr_retorno1.*  

      let g_documento.acao = 'CON'

   command key (F9)
      if aux_selec = "S" and aux_jitre = "S" then
         if g_documento.atdsrvnum is null and
            g_documento.atdsrvano is null then
            if cpl_atdsrvnum is not null or
               cpl_atdsrvano is not null then
               error " Servico ja' selecionado para copia!"
            else
               call cts16g00 (g_documento.succod   ,
                              g_documento.ramcod   ,
                              g_documento.aplnumdig,
                              g_documento.itmnumdig,
                              9                    ,  # atdsrvorg (SOCORRO RE)
                              " "                  ,
                              30,  ""              )  # nr dias p/pesquisa
                    returning cpl_atdsrvnum, cpl_atdsrvano, cpl_atdsrvorg

               if cpl_atdsrvorg <> 9 then
                  initialize cpl_atdsrvnum, cpl_atdsrvano to null
               end if

            end if
         else
           call cta00m06_sinistro_re(g_issk.dptsgl)
           returning l_acesso 
           
           if l_acesso = true then 
              call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano,0)
           else
              call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 2 )
           end if                          
         end if
      end if

   command key (F10)
      if aux_selec = "S" then
        if aux_jitre = "S" then
        else
           if g_documento.atdsrvnum is null and
              g_documento.atdsrvano is null then
              error " impressao somente com preenchimento do servico!"
           else
              call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
           end if
        end if
      end if

   command key ("R") "Regulador" "Regulador a ser acionado"
       if k_cts21m03.sinvstnum is not null  then
          select rglvstflg, sinpricod
            into d_cts21m03.rglvstflg,
                 ws.sinpricod       # regulador atual
            from datmpedvist
           where sinvstnum = k_cts21m03.sinvstnum  and
                 sinvstano = k_cts21m03.sinvstanO

          if d_cts21m03.rglvstflg = "S" then
             call regulador_cts21m03(k_cts21m03.sinvstnum,
                                     k_cts21m03.sinvstano)
                           returning d_cts21m03.sinpricod, # novo regulador
                                     ws.dtplantao,
                                     ws.motivo
             if d_cts21m03.sinpricod is not null then
                if d_cts21m03.sinpricod <> ws.sinpricod then
                   call cts21m07(k_cts21m03.sinvstnum,
                                 k_cts21m03.sinvstano,
                                 d_cts21m03.sinpricod, # novo regulador
                                 ws.sinpricod,         # reguladro atual
                                 ws.dtplantao,
                                 ws.motivo,"","","","")
                       returning ws.pgrflg
                   if ws.pgrflg = false  then
                      call cts08g01("A", "N", "",
                                    "NAO FOI POSSIVEL ACIONAR O REGULADOR",
                                    "VIA PAGER ATRAVES DO SISTEMA!","")
                           returning ws.confirma
                   end if
                end if
             end if
          else
             error " Nao e' necessario selecionar regulador para esta vistoria."
          end if
          next option "Encerra"
       else
          error " Nenhum registro selecionado!"
          next option "Seleciona"
       end if

   command key ("P") "Pager"    "Acionamento de regulador via pager"
       if k_cts21m03.sinvstnum is not null then
          select rglvstflg, sinpricod,sinvstdat,sinvsthor
            into d_cts21m03.rglvstflg,
                 d_cts21m03.sinpricod,ws.sindat,ws.sinhor
            from datmpedvist
           where sinvstnum = k_cts21m03.sinvstnum  and
                 sinvstano = k_cts21m03.sinvstano

          if d_cts21m03.rglvstflg = "S" then
             call fsrea200_valida_plantao(ws.sindat,ws.sinhor)
                 returning ws.dtplantao
             let ws.sinpricod = d_cts21m03.sinpricod
             call cts21m07(k_cts21m03.sinvstnum,
                           k_cts21m03.sinvstano,
                           d_cts21m03.sinpricod, # regulador atual
                           ws.sinpricod,         # regulador atual
                           ws.dtplantao,
                           ws.motivo,"","","","")
                 returning ws.pgrflg

             if ws.pgrflg = false  then
                call cts08g01("A", "N", "",
                              "NAO FOI POSSIVEL ACIONAR O REGULADOR",
                              "VIA PAGER ATRAVES DO SISTEMA!","")
                     returning ws.confirma
             end if
          else
             error " Nao e' necessario acionar regulador para esta vistoria!"
          end if
          next option "Encerra"
       else
          error " Nenhum registro selecionado!"
          next option "Seleciona"
       end if

   command key ("C") "Cancela"  "Cancela vistoria de sinistro"
       menu "Confirma cancelamento ? "
          command "Nao" "NAO cancela vistoria"
                  exit menu

          command "Sim" "Cancela vistoria "
                if k_cts21m03.sinvstnum is not null then
                   call cancela_cts21m03(k_cts21m03.sinvstnum,
                                         k_cts21m03.sinvstano)
                   initialize k_cts21m03.* to null
                   next option "Encerra"
                else
                   error " Nenhum registro selecionado!"
                   next option "Seleciona"
                end if
          exit menu
       end menu

   command key ("H") "Historico" "Historico e Relacao de bens sinistrados"
       if k_cts21m03.sinvstnum is not null then
          select sinhst    , sinobs
            into h_cts21m03.sinhst,
                 h_cts21m03.sinobs
            from datmpedvist
           where sinvstnum = k_cts21m03.sinvstnum
             and sinvstano = k_cts21m03.sinvstano

          if sqlca.sqlcode = notfound  then
             error " Historico e bens sinistrados nao foram encontrados.",
                   " AVISE A INFORMATICA!"
             next option "Encerra"
          else
             if sqlca.sqlcode < 0 then
                error " Erro (", sqlca.sqlcode, ") na localizacao do",
                      " historico. AVISE A INFORMATICA!"
                next option "Encerra"
             end if
          end if
          call cts21m02 (h_cts21m03.*) returning h_cts21m03.*

          update datmpedvist set (sinhst, sinobs) =
                 (h_cts21m03.sinhst, h_cts21m03.sinobs)
           where sinvstnum = k_cts21m03.sinvstnum and
                 sinvstano = k_cts21m03.sinvstano

          if sqlca.sqlcode <> 0 then
             error " Erro (",sqlca.sqlcode,") durante a atualizacao dos",
                   " bens sinistrados/historico. AVISE A INFORMATICA!"
          end if

          initialize h_cts21m03.* to null
       else
          error " Nenhum registro selecionado!"
          next option "Seleciona"
       end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
       if g_documento.acao is not null then
          if aux_jitre = "S"  and
             (g_documento.atdsrvnum is not null or
              g_documento.atdsrvnum > 0 )       then
             call cts10n00(g_documento.atdsrvnum,
                           g_documento.atdsrvano,
                           g_issk.funmat,
                           aux_today,
                           aux_hora)
          else
             call cts14m10(param.sinvstnum,
                           param.sinvstano,
                           g_issk.funmat,
                           aux_today,
                           aux_hora)
          end if
       else
          exit menu
       end if
 end menu

 close window cts21m03

 #PSI 199850 - sincronizar ligação com sistema RE
 #montar chave para transferir ligacao
 let l_transfere = "SINRE",                      #chave para RE
               ";","V12",                        #assunto para V12
               ";",param.sinvstano,              #ano vistoria
               ";",param.sinvstnum,              #numero vistoria
               ";",g_documento.succod,           #sucursal
               ";",g_documento.ramcod,           #ramo
               ";",g_documento.aplnumdig,        #apolice
               ";",g_documento.c24soltipcod,     #tipo solicitante
               ";",g_documento.solnom,           #nome solicitante
               ";"

 begin work
 if cts39g00_transfere_ligacao(g_c24paxnum,               #PA do atendente
                               l_transfere) then          #chave para transferencia
    #atualizou tabela do sincronismo para transferencia da ligação
    commit work
 else
    rollback work
 end if


end function  ###  cts21m03

#----------------------------------------------------------------------
 function seleciona_cts21m03(param)
#----------------------------------------------------------------------

 define param   record
    sinvstnum   like datmvstsin.sinvstnum ,
    sinvstano   like datmvstsin.sinvstano
 end record

 define d_cts21m03  record
    vistoria        char (11)                 ,
    vstsolnom       like datmpedvist.vstsolnom,
    segnom          like datmpedvist.segnom   ,
    doctxt          char (34)                 ,
    cornom          like datmpedvist.cornom   ,
    cvnnom          char (19)                 ,
    lclrsccod       like datmpedvist.lclrsccod,
    lclendflg       like datmpedvist.lclendflg,
    lgdtip          like datmpedvist.lgdtip   ,
    lgdnom          like datmpedvist.lgdnom   ,
    lgdnum          like datmpedvist.lgdnum   ,
    lgdnomcmp       like datmpedvist.lgdnomcmp,
    endbrr          like datmpedvist.endbrr   ,
    endcep          like datmpedvist.endcep   ,
    endcepcmp       like datmpedvist.endcepcmp,
    endcid          like datmpedvist.endcid   ,
    endufd          like datmpedvist.endufd   ,
    endddd          like datmpedvist.endddd   ,
    teldes          like datmpedvist.teldes   ,
    lclcttnom       like datmpedvist.lclcttnom,
    endrefpto       like datmpedvist.endrefpto,
    #sinntzcod       like datmpedvist.sinntzcod,    #PSI200140
    #sinntzdes       like sgaknatur.sinntzdes  ,    #PSI200140
    sindat          like datmpedvist.sindat   ,
    sinhor          like datmpedvist.sinhor   ,
    #orcvlr          like datmpedvist.orcvlr   ,    #PSI200140
    sinpricod       like datmpedvist.sinpricod,
    nomrazsoc       like sgkkperi.nomrazsoc   ,
    funnom          char (20)                 ,
    sinvstdat       like datmpedvist.sinvstdat,
    sinvsthor       like datmpedvist.sinvsthor,
    rglvstflg       like datmpedvist.rglvstflg
 end record

 define k_cts21m03  record
    sinvstnum       like datmvstsin.sinvstnum,
    sinvstano       like datmvstsin.sinvstano
 end record

 define ws          record
    succod          like datrligapol.succod,
    ramcod          like datrligapol.ramcod,
    aplnumdig       like datrligapol.aplnumdig,
    itmnumdig       like datrligapol.itmnumdig,
    edsnumref       like datrligapol.edsnumref,
    prporg          like datrligprp.prporg,
    prpnumdig       like datrligprp.prpnumdig,
    fcapacorg       like datrligpac.fcapacorg,
    fcapacnum       like datrligpac.fcapacnum,
    lignum          like datrligsinvst.lignum,
    ligcvntip       like datmligacao.ligcvntip,
    funmat          like datmpedvist.funmat,
    vstsolstt       like datmpedvist.vstsolstt,
    vstsoltip       like datmpedvist.vstsoltip
 end record

 define l_c24soltipdes  like datksoltip.c24soltipdes

 define motivo record
    cncmtvtxt  char(100)
 end record



 define l_resp         CHAR(1)

 define l_des          CHAR(40)

 define  aux_ano       CHAR(02),
         aux_today     CHAR(10),
         l_count_p10   smallint


 define l_data         date,
        l_hora2        datetime hour to minute

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_c24soltipdes  =  null
        let     l_resp  =  null
        let     l_des  =  null
        let     aux_ano  =  null
        let     aux_today  =  null
        let     l_data  =  null
        let     l_hora2  =  null
        let     l_count_p10 = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_cts21m03.*  to  null

        initialize  k_cts21m03.*  to  null

        initialize  ws.*  to  null

        initialize  motivo.*  to  null

 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2

 let aux_today = l_data
 let aux_ano   = aux_today[9,10]

 initialize d_cts21m03, k_cts21m03, ws to null

 let k_cts21m03.sinvstnum = param.sinvstnum
 let k_cts21m03.sinvstano = param.sinvstano

#----------------------------------------------------------------------
# Dados da vistoria de sinistro
#----------------------------------------------------------------------

 select vstsolnom            ,
        cornom               ,
        segnom               ,
        lclrsccod            ,
        lclendflg            ,
        lgdtip               ,
        lgdnom               ,
        lgdnum               ,
        lgdnomcmp            ,
        endbrr               ,
        endcid               ,
        endufd               ,
        endcep               ,
        endcepcmp            ,
        endddd               ,
        teldes               ,
        lclcttnom            ,
        endrefpto            ,
        sindat               ,
        sinhor               ,
        sinpricod            ,
        vstsolstt            ,
        sinvstdat            ,
        sinvsthor            ,
        funmat                 
   into d_cts21m03.vstsolnom ,
        d_cts21m03.cornom    ,
        d_cts21m03.segnom    ,
        d_cts21m03.lclrsccod ,
        d_cts21m03.lclendflg ,
        d_cts21m03.lgdtip    ,
        d_cts21m03.lgdnom    ,
        d_cts21m03.lgdnum    ,
        d_cts21m03.lgdnomcmp ,
        d_cts21m03.endbrr    ,
        d_cts21m03.endcid    ,
        d_cts21m03.endufd    ,
        d_cts21m03.endcep    ,
        d_cts21m03.endcepcmp ,
        d_cts21m03.endddd    ,
        d_cts21m03.teldes    ,
        d_cts21m03.lclcttnom ,
        d_cts21m03.endrefpto ,
        d_cts21m03.sindat    ,
        d_cts21m03.sinhor    ,
        d_cts21m03.sinpricod ,
        ws.vstsolstt         ,
        d_cts21m03.sinvstdat ,
        d_cts21m03.sinvsthor ,
        ws.funmat             
   from datmpedvist
  where sinvstnum = k_cts21m03.sinvstnum
    and sinvstano = k_cts21m03.sinvstano

 if sqlca.sqlcode = notfound then
    error " Vistoria nao encontrada. AVISE A INFORMATICA!"
    return k_cts21m03.*
 else
    if sqlca.sqlcode < 0 then
       error " Erro (", sqlca.sqlcode, ") na localizacao da vistoria.",
             " AVISE A INFORMATICA!"
       return k_cts21m03.*
    end if
 end if

#----------------------------------------------------------------------
# Verifica se vistoria de sinistro esta' cancelada
#----------------------------------------------------------------------

 let l_count_p10 = null

 select count(*)
   into l_count_p10
   from datmsrvre   a
       ,datmligacao b
  where a.sinvstnum = k_cts21m03.sinvstnum
    and a.sinvstano = k_cts21m03.sinvstano
    and b.atdsrvnum = a.atdsrvnum
    and b.atdsrvano = a.atdsrvano

 if ws.vstsolstt = 3 or ws.vstsolstt = 4  then

    if l_count_p10 > 0 then
       message "(F3) Motivo_Cancelamento (F8) Serv. P10" 
    else
       message "(F3) Motivo_Cancelamento"
    end if

    error "Vistoria cancelada nao pode ser alterada!"
 else

    if aux_jitre = "S" then

       if l_count_p10 > 0 then
          message "(F1)Help,(F4)Cob/Nat,(F5)Espelho,(F6)Hist,(F7)Funcoes,(F9)Conclui,(F8) Serv. P10"
       else
          message "(F1)Help,(F4)Cob/Nat,(F5)Espelho,(F6)Hist,(F7)Funcoes,(F9)Conclui"
       end if
    else
      #message "(F1)Help, (F5)Espelho, (F6)Hist,(F10)Imprime "

       if l_count_p10 > 0 then
          message "(F1)Help, (F4)Cob/Nat, (F5)Espelho, (F6)Historico, (F8) Serv. P10"
       else
          message "(F1)Help, (F4)Cob/Nat, (F5)Espelho, (F6)Historico "
       end if
    end if
 end if

 if d_cts21m03.sinpricod  is not null then
    select nomrazsoc
      into d_cts21m03.nomrazsoc
      from sgkkperi
     where sindptcod = 1
       and sinpricod = d_cts21m03.sinpricod
 end if

#----------------------------------------------------------------------
# Localiza ligacao da vistoria de sinistro
#----------------------------------------------------------------------

 let ws.lignum = cts20g00_sinvst(k_cts21m03.sinvstnum, k_cts21m03.sinvstano, 2)

 select ligcvntip
   into ws.ligcvntip
   from datmligacao
  where lignum = ws.lignum

 if sqlca.sqlcode = notfound then
    error " Ligacao da marcacao de sinistro nao foi encontrada.",
          " AVISE A INFORMATICA!"
    return k_cts21m03.*
 else
    if sqlca.sqlcode < 0 then
       error " Erro (",sqlca.sqlcode,") na localizacao da ligacao.",
             " AVISE A INFORMATICA!"
       return k_cts21m03.*
    end if
 end if

 select cpodes
   into d_cts21m03.cvnnom
   from datkdominio
  where cponom = "ligcvntip"
    and cpocod = ws.ligcvntip


 ---> Buscar Sequencia do Local de Risco / Bloco - Doctos. do RE
 select lclnumseq
       ,rmerscseq
   into g_documento.lclnumseq
       ,g_documento.rmerscseq
   from datmrsclcllig
  where lignum = ws.lignum

#----------------------------------------------------------------------
# Obtem documento de referencia
#----------------------------------------------------------------------

 call cts20g01_docto(ws.lignum)
           returning w_succod,
                     w_ramcod,
                     w_aplnumdig,
                     w_itmnumdig,
                     w_edsnumref,
                     w_prporg,
                     w_prpnumdig,
                     w_fcapacorg,
                     w_fcapacnum,
                     w_itaciacod     

 if w_succod    is not null  and
    w_ramcod    is not null  and
    w_aplnumdig is not null  then
    let d_cts21m03.doctxt = "Apol.: ", w_succod    using "<<<&&",#"&&", projeto succod
                                  " ", w_ramcod    using "&&&&",
                                  " ", w_aplnumdig using "<<<<<<<& &",
                                  " ", w_itmnumdig using "<<<<<<& &"
 end if

 if w_prporg    is not null  and
    w_prpnumdig is not null  then
    let d_cts21m03.doctxt = "Proposta: ", w_prporg    using "&&",
                                     " ", w_prpnumdig using "<<<<<<<& &"
 end if


#----------------------------------------------------------------------
# Verifica se vistoria sera' realizada no local de risco
#----------------------------------------------------------------------

 if d_cts21m03.lclendflg = "S" then
    call endereco_cts21m03(d_cts21m03.lclrsccod)
           returning  d_cts21m03.lgdtip    ,
                      d_cts21m03.lgdnom    ,
                      d_cts21m03.lgdnum    ,
                      d_cts21m03.lgdnomcmp ,
                      d_cts21m03.endbrr    ,
                      d_cts21m03.endcid    ,
                      d_cts21m03.endufd    ,
                      d_cts21m03.endcep    ,
                      d_cts21m03.endcepcmp
 end if

 if aux_jitre = "S" then

    if g_documento.succod is null and w_succod is not null then
       let g_documento.succod = w_succod
    end if

    if g_documento.ramcod is null and w_ramcod is not null then
       let g_documento.ramcod = w_ramcod
    end if

    if g_documento.aplnumdig is null and w_aplnumdig is not null then
       let g_documento.aplnumdig = w_aplnumdig
    end if

    if g_documento.itmnumdig is null and w_itmnumdig is not null then
       let g_documento.itmnumdig = w_itmnumdig
    end if

    let d_cts21m03.vistoria = g_documento.atdsrvnum using "&&&&&&&",
                          "-",g_documento.atdsrvano using "&&"
    display "                   " at 17,35
 else
    let d_cts21m03.vistoria = F_FUNDIGIT_INTTOSTR(k_cts21m03.sinvstnum,6) , "-",
                              k_cts21m03.sinvstano
 end if

 select funnom
   into d_cts21m03.funnom
   from isskfunc
  where empcod = 01
    and funmat = ws.funmat

 display by name d_cts21m03.vistoria thru d_cts21m03.sinvsthor
 display by name d_cts21m03.vstsolnom attribute (reverse)
 display by name d_cts21m03.cvnnom    attribute (reverse)

 return k_cts21m03.*

end function  ###  seleciona_cts21m03

#----------------------------------------------------------------------
 function cancela_cts21m03(param)
#----------------------------------------------------------------------

 define param     record
    sinvstnum     like datmvstsin.sinvstnum ,
    sinvstano     like datmvstsin.sinvstano
 end record
 define ws        record
    cncmtvtxt     char(100),
    vstsolstt     like datmpedvist.vstsolstt
 end record
 define aux_vstsolstt like datmpedvist.vstsolstt

 define l_data      date,
        l_hora2     datetime hour to minute

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     aux_vstsolstt  =  null
        let     l_data  =  null
        let     l_hora2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

 initialize  ws.*           to  null
 initialize  aux_vstsolstt  to  null

 select vstsolstt
   into aux_vstsolstt
   from datmpedvist
  where sinvstnum = param.sinvstnum
    and sinvstano = param.sinvstano

    if sqlca.sqlcode <> 0 then
       error " Erro (",sqlca.sqlcode,") na localizacao da vistoria",
             " para cancelamento. AVISE A INFORMATICA!"
       rollback work
       return
    end if

 if aux_vstsolstt = 3 or aux_vstsolstt = 4 then
    error " Vistoria cancelada nao pode ser alterada!"
 else
    call motivo_cancel03(param.sinvstnum,param.sinvstano)
              returning ws.cncmtvtxt

    if ws.cncmtvtxt = " " then
       let ws.cncmtvtxt = null
    end if


    if ws.cncmtvtxt is not null then
       if aux_vstsolstt =  2  then             #------------------------------#
          let ws.vstsolstt = 3                 # Status da Solicitacao        #
                                               #------------------------------#
                                               # 1 - Em emissao               #
                                               # 2 - Laudo emitido            #
       else                                    # 3 - Cancel. laudo emitido    #
          let ws.vstsolstt = 4                 # 4 - Cancel. laudo em emissao #
                                               #------------------------------#
       end if
       begin work
         update datmpedvist
            set vstsolstt = ws.vstsolstt
          where sinvstnum = param.sinvstnum
            and sinvstano = param.sinvstano

         call cts40g03_data_hora_banco(2)
              returning l_data, l_hora2

         insert into datmvstcnc
                   (sinvstnum, sinvstano,
                    empcod   , usrtip   ,
                    funmat   , atddat   ,
                    atdhor   , cncmtvtxt)
            values (param.sinvstnum,
                    param.sinvstano,
                    g_issk.empcod,
                    g_issk.usrtip,
                    g_issk.funmat,
                    l_data       ,
                    l_hora2      ,
                    ws.cncmtvtxt)
         if sqlca.sqlcode <> 0 then
            error " Erro (", sqlca.sqlcode, ") durante o cancelamento.",
                  " AVISE A INFORMATICA!"
            rollback work
            return
         else
            commit work
            error " Vistoria cancelada!"
         end if
    end if
 end if

end function  ###  cancela_cts21m03

#----------------------------------------------------------------------
 function mostra_cts21m03(param)
#----------------------------------------------------------------------

 define param     record
    sinvstnum     like datmvstsin.sinvstnum ,
    sinvstano     like datmvstsin.sinvstano
 end record

 define d_cts21m09  record
    vstsolnom       like datmpedvist.vstsolnom,
    c24soltipdes    like datksoltip.c24soltipdes,
    atddat          like datmvstcnc.atddat,
    atdhor          like datmvstcnc.atdhor,
    funmat          like datmvstcnc.funmat,
    funnom          like isskfunc.funnom,
    desccan         char (30)             ,
    cncmtvtxt       char(100)
 end record
 define ws    record
    vstsolstt       like datmpedvist.vstsolstt,
    vstsoltip       like datmpedvist.vstsoltip,
    resp            char (01),
    empcod          like isskfunc.empcod,
    usrtip          like isskfunc.usrtip
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_cts21m09.*  to  null

        initialize  ws.*  to  null

 select usrtip,funmat,atddat,atdhor,cncmtvtxt,empcod
      into ws.usrtip   ,        d_cts21m09.funmat,
           d_cts21m09.atddat,   d_cts21m09.atdhor,
           d_cts21m09.cncmtvtxt,ws.empcod
      from datmvstcnc
      where sinvstnum = param.sinvstnum
        and sinvstano = param.sinvstano

  select funnom into d_cts21m09.funnom # quem cancelou
      from isskfunc
     where funmat = d_cts21m09.funmat
       and empcod = ws.empcod
       and usrtip = ws.usrtip

  select vstsolnom,vstsoltip,vstsolstt
     into d_cts21m09.vstsolnom,
          ws.vstsoltip,
          ws.vstsolstt
     from datmpedvist
     where sinvstnum = param.sinvstnum  and
           sinvstano = param.sinvstano
  case
  when ws.vstsoltip  =  "S"
       let d_cts21m09.c24soltipdes = "SEGURADO"
  when ws.vstsoltip  =  "C"
       let d_cts21m09.c24soltipdes = "CORRETOR"
  when ws.vstsoltip  =  "O"
       let d_cts21m09.c24soltipdes = "OUTROS"
  when ws.vstsoltip  =  "T"
       let d_cts21m09.c24soltipdes = "TERCEIRO"
  end case

  case
  when ws.vstsolstt  =  3
       let d_cts21m09.desccan = "CANCELADO - LAUDO EMITIDO"
  when ws.vstsolstt  =  4
       let d_cts21m09.desccan = "CANCELADO - LAUDO EM EMISSAO"
  end case

  open window cts21m09 at 09,15 with form "cts21m09"
                 attribute(border)

      display by name d_cts21m09.vstsolnom,
                      d_cts21m09.c24soltipdes,
                      d_cts21m09.atddat,
                      d_cts21m09.atdhor,
                      d_cts21m09.funmat,
                      d_cts21m09.funnom,
                      d_cts21m09.desccan
      call cts21m03_wrap('C',d_cts21m09.cncmtvtxt)
           returning l_fim,d_cts21m09.cncmtvtxt

      prompt " Tecle algo para continuar !!! " for char ws.resp

  close window cts21m09

 end function

#----------------------------------------------------------------------
 function endereco_cts21m03(par_lclrsccod)
#----------------------------------------------------------------------

 define par_lclrsccod like datmpedvist.lclrsccod

 define d_cts21m03   record
    endlgdtip        like rlaklocal.endlgdtip,
    endlgdnom        like rlaklocal.endlgdnom,
    endnum           like rlaklocal.endnum   ,
    endcmp           like rlaklocal.endcmp   ,
    endbrr           like rlaklocal.endbrr   ,
    endcid           like rlaklocal.endcid   ,
    ufdcod           like rlaklocal.ufdcod   ,
    endcep           like rlaklocal.endcep   ,
    endcepcmp        like rlaklocal.endcepcmp
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_cts21m03.*  to  null

 select endlgdtip,
        endlgdnom,
        endnum   ,
        ufdcod   ,
        endcmp   ,
        endbrr   ,
        endcid   ,
        endcep
   into d_cts21m03.endlgdtip ,
        d_cts21m03.endlgdnom ,
        d_cts21m03.endnum    ,
        d_cts21m03.ufdcod    ,
        d_cts21m03.endcmp    ,
        d_cts21m03.endbrr    ,
        d_cts21m03.endcid    ,
        d_cts21m03.endcep
   from rlaklocal
  where lclrsccod = par_lclrsccod

  if sqlca.sqlcode <> 0  then
     error " Erro (", sqlca.sqlcode, ") na localizacao do local de risco.",
           " AVISE A INFORMATICA !"
  end if

  return d_cts21m03.*

end function  ###  endereco_cts21m03

#----------------------------------------------------------------------
 function regulador_cts21m03(param)
#----------------------------------------------------------------------

 define param      record
    sinvstnum      like datmpedvist.sinvstnum ,
    sinvstano      like datmpedvist.sinvstano
 end record

 define d_cts21m03 record
    sinpricod      like sgkkperi.sinpricod ,
    nomrazsoc      like sgkkperi.nomrazsoc
 end record
 define ws         record
    dtplantao      char(10),
    motivo         char(50),
    slvsinpricod   like sgkkperi.sinpricod
 end record

  define  aux_ano        CHAR(02),
          aux_today      CHAR(10),
          aux_hora       CHAR(05)

 define   l_data        date,
          l_hora2       datetime hour to minute

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     aux_ano  =  null
        let     aux_today  =  null
        let     aux_hora  =  null
        let     l_data  =  null
        let     l_hora2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_cts21m03.*  to  null

        initialize  ws.*  to  null

 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2

 let aux_today       = l_data
 let aux_hora        = l_hora2
 let aux_ano         = aux_today[9,10]

 initialize d_cts21m03.* to null
 initialize ws.*         to null

 select sinpricod
   into d_cts21m03.sinpricod
   from datmpedvist
  where sinvstnum = param.sinvstnum  and
        sinvstano = param.sinvstano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na localizacao do regulador acionado.",
          " AVISE A INFORMATICA!"
    return
 end if

 input by name d_cts21m03.sinpricod without defaults

    before field sinpricod
       display by name d_cts21m03.sinpricod attribute (reverse)
       let ws.slvsinpricod = d_cts21m03.sinpricod

    after  field sinpricod
       display by name d_cts21m03.sinpricod
       call osrec218() returning ws.dtplantao,
                                 d_cts21m03.sinpricod,
                                 ws.motivo
       if d_cts21m03.sinpricod is null then
          let d_cts21m03.sinpricod  = ws.slvsinpricod
       end if
       select nomrazsoc
         into d_cts21m03.nomrazsoc
         from sgkkperi
        where sindptcod = 1  and
              sinpricod = d_cts21m03.sinpricod

       if sqlca.sqlcode = notfound  then
          error " Regulador nao cadastrado!"
          next field sinpricod
       end if
       display by name d_cts21m03.nomrazsoc

    on key (interrupt)
       exit input

  end input
  if int_flag then
     let int_flag = false
     initialize d_cts21m03.* to null
     error " Operacao cancelada!"
     clear form
     return d_cts21m03.sinpricod,
            ws.dtplantao,
            ws.motivo
  end if

  return d_cts21m03.sinpricod,
         ws.dtplantao,
         ws.motivo

end function  ###  regulador_cts21m03

#------------------------------#
function motivo_cancel03(param)
#------------------------------#
   define param     record
       sinvstnum     like datmvstsin.sinvstnum ,
       sinvstano     like datmvstsin.sinvstano
   end record

   define motivo record
        cncmtvtxt  char(100)
   end record

   define lr_input record
          motivo1  char(50),
          motivo2  char(50)
   end record


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  motivo.*  to  null

        initialize  lr_input.*  to  null

   let lr_input.motivo1 = null
   let lr_input.motivo2 = null
   let motivo.cncmtvtxt = null

   open window cts21m08 at 09,10 with form "cts21m08"
      attribute(border, form line 1)

   input by name lr_input.motivo1,
                 lr_input.motivo2 without defaults

      before field motivo1
         display by name lr_input.motivo1 attribute(reverse)

      after field motivo1
         display by name lr_input.motivo1

      before field motivo2
         display by name lr_input.motivo2 attribute(reverse)

      after field motivo2
         display by name lr_input.motivo2

         if fgl_lastkey() = fgl_keyval("up") or
            fgl_lastkey() = fgl_keyval("left") then
            next field motivo1
         end if

         if lr_input.motivo1 is null and
            lr_input.motivo2 is null then
            error "Informe o motivo do cancelamento"
            next field motivo1
         end if

         error "Pressione F8 para confirmar!"
         next field motivo2 # -> OBRIGA O ATENDENTE SAIR COM F8

      on key(f8)
         if lr_input.motivo1 is null and
            lr_input.motivo2 is null then
            error "Informe o motivo do cancelamento"
            display by name lr_input.motivo2
            next field motivo1
         end if

         let motivo.cncmtvtxt = lr_input.motivo1 clipped,
                                lr_input.motivo2
         exit input

      on key (f17, control-c, interrupt)
         let lr_input.motivo1 = null
         let lr_input.motivo2 = null
         let motivo.cncmtvtxt = null
         exit input

   end input

   close window cts21m08
   let int_flag = false

   if motivo.cncmtvtxt = " " then
      let motivo.cncmtvtxt = null
   end if

   return motivo.cncmtvtxt

end function

#------------------------------------------------------------------------
function cts21m03_wrap(l_tipo,l_texto)
#------------------------------------------------------------------------

     define

     l_tipo                  char (001),
     l_texto                 char(100),
     l_fimtxt                smallint,
     l_incpos                integer,
     l_string                char (50),
     l_null                  char (001),
     l_i                     smallint

     define l_data        date,
            l_hora2       datetime hour to minute

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_fimtxt  =  null
        let     l_incpos  =  null
        let     l_string  =  null
        let     l_null  =  null
        let     l_i  =  null
        let     l_data  =  null
        let     l_hora2  =  null

        let     l_fimtxt  =  null
        let     l_incpos  =  null
        let     l_string  =  null
        let     l_null  =  null
        let     l_i  =  null

     if   l_tipo = 'C' then
          let  l_incpos = 01
          let  l_fimtxt = false
          let  l_string = " "
          let  l_i      = 01

          while l_fimtxt = false
               call     figrc001_wraptxt_jst
                      ( l_texto                   # Texto
                      , 50
                      , l_incpos
                      , ascii(10)
                      , 002
                      , 00
                      , "" , "" , "" , "" )
              returning l_fimtxt
                      , l_string
                      , l_incpos
                      , l_null , l_null

              display l_string to cncmtvtxt[l_i]

              let  l_i = l_i + 01

              if   l_i > 02
              then
                   exit while
              end  if
          end  while
     end  if

     call cts40g03_data_hora_banco(2)
          returning l_data, l_hora2

     if   l_tipo = "I" then
          call      figrc002_wraptxt_var      # PARAMETROS ENVIADOS:
                  ( 15                        #  1. Linha   de inicio do txt
                  , 11                        #  2. Coluna  de inicio do txt
                  , 02                        #  3. Linhas  na tela
                  , 50                        #  4. Colunas na tela
                  , "N"                       #  5. Flag exibir NomeTexto e
                                              #     Situacao
                  , "NN"                      #  6. Flag exibir Cab./Regua
                  , "N"                       #  7. Opcao de acentuacao
                  , 050                       #  8. Tamanho max. da linha
                  , 002                       #  9. Tamanho max. do texto
                  , 001                       # 10. Tamanho scroll
                  , ASCII(10)                 # 11. Caracter de Fim de Linha
                  , l_texto                   # 12. Texto Separado pelo #11
                  , " "                       # 13. Cabecalho do texto
                  , ""                        # 14. Cabecalho Identificacao de
                                              #     colunas.
                  , "S"                       # 15. Flag.Edicao Automatica
                                              #     S-im / N-ao / B-loqueio
                  , 002                       # 16. Flag.Maiusculo/Minusculo
                  , ""                        # 17. Sequencia de Caracteres
                                              #     NAO computados
                  , " "                       # 18. Empresa do Funcionario
                  , " "                       # 19. Matricula Ult. Alteracao
                  , l_data                    # 20. Data da Ultima Alteracao
                  , " "                       # 21. Tipo de usuario
                  , "N"                       # 22. Exibir Borda (S/N)
                  , "N"                       # 23. Manter window aberta
                  , "S"                       # 24. NAO Utilizado
                  , " "                       # 25. NAO Utilizado
                  , " "                       # 26. NAO Utilizado
                  , " "                       # 27. NAO Utilizado
                  , " "                       # 28. NAO Utilizado
                  , " "                       # 29. NAO Utilizado
                  , " " )                     # 30. NAO Utilizado
          returning l_fimtxt
                  , l_texto

          if   l_fimtxt =  false
          then
               error "CANCELADO !"
               sleep 01
          end  if
     end  if

     return l_fimtxt, l_texto

end function #-->
#------------------------------------------------------------------------
function cts21m03_mostra_p10(param)
#------------------------------------------------------------------------

 define param       record
        sinvstnum   like datmvstsin.sinvstnum
       ,sinvstano   like datmvstsin.sinvstano
 end record

 define lr_retorno     record
        erro           smallint,
        atdsrvnum      like datmligacao.atdsrvnum,
        atdsrvano      like datmligacao.atdsrvano
 end record

 define w_cmd          char (500),
        w_lignum       like datmligacao.lignum,
        w_c24astcod    char(04),
        w_c24astdes    like datkassunto.c24astdes,
        w_ligdat       like datmligacao.ligdat,
        w_lighorinc    like  datmligacao.lighorinc,
        w_result       smallint,
        w_qualquer      char (1),
        w_ant_atdsrvnum like datmligacao.atdsrvnum,
        w_ant_atdsrvano like datmligacao.atdsrvano

 define l_count smallint

 initialize lr_retorno.*  to  null

 let w_cmd = null
 let w_lignum = null
 let w_c24astcod = null
 let w_c24astdes = null
 let w_ligdat = null
 let w_lighorinc = null
 let w_result = null
 let w_qualquer = null
 let l_count = null
 let w_ant_atdsrvnum = null
 let w_ant_atdsrvano = null

 let w_ant_atdsrvnum = g_documento.atdsrvnum
 let w_ant_atdsrvano = g_documento.atdsrvano

 let  w_cmd = " select b.atdsrvnum ,b.atdsrvano ,b.c24astcod,c.c24astdes "
            , "      , b.ligdat,b.lighorinc "
            , " from datmsrvre   a "
            , "     ,datmligacao b "
            , "     ,datkassunto c "
           , " where a.sinvstnum = " ,param.sinvstnum
           ,  "  and a.sinvstano = '" ,param.sinvstano ,"'"
           ,  "  and b.atdsrvnum = a.atdsrvnum "
           ,  "  and b.atdsrvano = a.atdsrvano "
           ,  "  and b.c24astcod = 'P10' "
           ,  "  and c.c24astcod = b.c24astcod "

 while true
    call ofgrc002_popup(08,06,10,70,5
          ,"VISUALIZACAO DE LAUDO DOS SERVICOS DE P10 DA VISTORIA R.E."
          ,"   SERVICO/ANO| AST  |DESCRICAO ASSUNTO|  DT.LIG|      HR.LIG|"
          ,w_cmd
          ,"NN0211##########|NN1314&#|AN1720|AN2340|DN4352dd/mm/yyyy|AN5660"
          ,"","","","order by 1 desc",'N')
       returning lr_retorno.erro
                ,lr_retorno.atdsrvnum
                ,lr_retorno.atdsrvano
                ,w_c24astcod
                ,w_c24astdes
                ,w_ligdat
                ,w_lighorinc
                ,w_qualquer,w_qualquer,w_qualquer,w_qualquer,w_qualquer
                ,w_qualquer,w_qualquer,w_qualquer,w_qualquer,w_qualquer
                ,w_qualquer,w_qualquer,w_qualquer,w_qualquer

    if lr_retorno.atdsrvnum is null then
       exit while
    else

       let g_documento.atdsrvnum = lr_retorno.atdsrvnum
       let g_documento.atdsrvano = lr_retorno.atdsrvano

       if cts04g00('cts21m03') = true  then
          continue while
       end if
    end if

 end while

 let int_flag = false

 let g_documento.atdsrvnum = w_ant_atdsrvnum
 let g_documento.atdsrvano = w_ant_atdsrvano

 return lr_retorno.erro
       ,lr_retorno.atdsrvnum

end function
#-----------------------------------------------------   fim.
