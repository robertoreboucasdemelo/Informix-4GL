 #############################################################################
 # Nome do Modulo: CTG3                                                Pedro #
 #                                                                           #
 # Menu de Consultas Informacoes Gerais                             Jan/1995 #
 #############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 11/11/1998  PSI 6471-8   Gilberto     Incluir parametro CLSCOD na funcao  #
 #                                       CTN18C00 (conteudo nulo).           #
 #---------------------------------------------------------------------------#
 # 24/06/1999  PSI 7574-7   Gilberto     Incluir consulta a aeroportos.      #
 #---------------------------------------------------------------------------#
 # 06/12/1999  PSI 9838-8   Wagner       Incluir consulta a Vidros Carglass. #
 #---------------------------------------------------------------------------#
 # 30/10/2000  AS 22241     Ruiz         Chamar funcao abre banco            #
 #---------------------------------------------------------------------------#
 # 26/03/2001  PSI 124354   Ruiz         Altera a funcao fsgoa007 (beneficio)#
 #---------------------------------------------------------------------------#
 # 25/07/2001  Rosana       Ruiz         Chamar tela de consulta a corretores#
 #                                       atravez da tela VP(cts06m00).       #
 #---------------------------------------------------------------------------#
 # 19/03/2002  PSI 15000-2  Marcus       Consulta de prestadores Porto Socor #
 #                                       ro por coordenadas (Mapa)           #
 # 22/06/2004  OSF 37184    Teresinha S. Alterar chamada funcao ctn18c00 pas #
 #                                       sando zero como cod do motivo da lo #
 #                                       cacao ao inves da flag de oficinas  #
 # ..........................................................................#
 #                                                                           #
 #                         * * * * Alteracoes * * * *                        #
 #                                                                           #
 # Data       Autor Fabrica   Origem     Alteracao                           #
 # ---------- --------------  ---------- ------------------------------------#
 # 18/05/2005 Adriano, Meta   PSI191108  Incluir campo emeviacod no record   #
 #                                       a_cts06g03 da funcao ctg3_pesqloja()#
 #---------------------------------------------------------------------------#
 # 21/02/2006 Priscila        PSI 198390 Alterar chamada funcao ctn18c00     #
 #                                       incluindo "" para parametro cidcep  #
 #---------------------------------------------------------------------------#
 # 02/03/2006 Priscila        Zeladoria  Buscar data e hora do banco de dados#
 #---------------------------------------------------------------------------#
 # 28/11/2006 Priscila          PSI205206  Passar empresa para ctn18c00      #
 #---------------------------------------------------------------------------#
 #---------------------------------------------------------------------------#
 # 08/12/2007 Amilton,Meta    PSI223689  Bloquear acesso a fsgoa007 caso     #
 #                                       as instancias estejam fora do ar    #
 #---------------------------------------------------------------------------#



 globals  "/homedsa/projetos/geral/globals/glct.4gl"
 define   w_log    char(60)

main

 define ws      record
    pstcoddig   like dpaksocor.pstcoddig,
    nomrazsoc   like gkpkpos.nomrazsoc,
    endlgd      like gkpkpos.endlgd,
    endbrr      like gkpkpos.endbrr,
    endcid      like gkpkpos.endcid,
    endufd      like gkpkpos.endufd,
    endcep      like glaklgd.lgdcep,
    endcepcmp   like glaklgd.lgdcepcmp,
    arpcod      like datkaeroporto.arpcod,
    lcvcod      like datklocadora.lcvcod,
    aviestcod   like datkavislocal.aviestcod,
    vclpsqflg   smallint ,
    avivclcod   like datkavisveic.avivclcod,
    comando     char(200),
    argval      char(08) ,
    ret         integer
 end record
 define x_data      date
 define l_hora2     datetime hour to minute
 define m_hostname  char(12)
 define m_server    char(05)
 define l_status    smallint
 define l_msg       char(100)


   ## Flexvision
   initialize g_monitor.dataini   to null ## dataini   date,
   initialize g_monitor.horaini   to null ## horaini   datetime hour to fraction,
   initialize g_monitor.horafnl   to null ## horafnl   datetime hour to fraction,
   initialize g_monitor.intervalo to null ## intervalo datetime hour to fraction

 call fun_dba_abre_banco("CT24HS")

 let w_log = f_path("ONLTEL","LOG")
 if w_log is null then
    let w_log = "."
 end if
 let w_log = w_log clipped,"/dat_ctg3.log"

 call startlog(w_log)
#------------------------------------------
#  ABRE BANCO   (TESTE ou PRODUCAO)
#------------------------------------------


 select sitename into g_hostname from dual
# where tabname = "systables"  -- OSF 37184
  defer interrupt

  # --CLAUSULA PARA EXECUTAR A "LEITURA SUJA" DOS REGISTROS
  set isolation to dirty read
  # --TEMPO PARA VERIFICAR SE O REGISTRO ESTA ALOCADO
  set lock mode to wait 180

 options
    prompt  line last,
    comment line last,
    message line last

 whenever error continue

 open window WIN_CAB at 02,02 with 22 rows,78 columns
      attribute (border)

 call cts40g03_data_hora_banco(2)
      returning x_data, l_hora2
 display "CENTRAL 24 HS"  at 01,01
 display "P O R T O   S E G U R O  -  S E G U R O S" at 01,20
 display x_data       at 01,69

 open window WIN_MENU at 04,02 with 20 rows, 78 columns
 call p_reg_logo()
 call get_param()

 display "---------------------------------------------------------------",
         "---------ctg3--" at 03,01

 if arg_val(15) is not null then    # esta informacao vem tela cts06m00.4gl
    let ws.argval  =  arg_val(15)
    if ws.argval   =  "cts06m00"  then
       call ctn09c02()
       exit program
    end if
 end if


 let ws.comando = "" #"novofglgo ofpgc094"
                  ,g_issk.succod     , " "    #-> Sucursal
                  ,g_issk.funmat     , " "    #-> Matricula do funcionario
              ,"'",g_issk.funnom,"'" , " "    #-> Nome do funcionario
                  ,g_issk.dptsgl     , " "    #-> Sigla do departamento
                  ,g_issk.dpttip     , " "    #-> Tipo do departamento
                  ,g_issk.dptcod     , " "    #-> Codigo do departamento
                  ,"FPG"             , " "    #-> Sigla sistema - "FPG"
                  ,1                 , " "    #-> Nivel de acesso
                  ,"Consultas"       , " "    #-> Sigla programa - "Consultas"
                  ,g_issk.usrtip     , " "    #-> Tipo de usuario
                  ,g_issk.empcod     , " "    #-> Codigo da empresa
                  ,g_issk.iptcod     , " "
                  ,g_issk.usrcod     , " "    #-> Codigo do usuario
                  ,g_issk.maqsgl     , " "    #-> Sigla da maquina

 menu "CONSULTAS "

   before menu
          hide option all
          show option "Lojas_Vidros"
          show option "Caps" #Johnny,Biz
          if g_issk.prgsgl = "ctg3T" then
             let g_issk.prgsgl = "ctg3"
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn06n00") then   ### NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Oficinas"
                show option "Referenciadas"  # a pedido Rosana 04/11/05
                show option "Garantia_mecanica"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn29c00") then   ### NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Auto_revendas"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn07c01") then   ### NIVEL 6/4/3
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Vistoria"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn05c02") then   ### NIVEL 6/4/3
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Dispositivos"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn09c02") then   ### NIVEL 6/4/3
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Corretores"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn06c05") then   ### NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Lista_oesp"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn06c04") then   ### NIVEL 6/4
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Prestador"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn03c01") then   ### NIVEL 6/4
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Dp_batalhoes"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn04c00") then   ### NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Reguladores"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn02c01") then   ### NIVEL 6/4
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Inspetorias"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn08c01") then   ### NIVEL 6/4
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Escritorios"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn14c00") then   ### NIVEL 6/4
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Sucursais"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn15c00") then   ### NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Empresas"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn21c00") then   ### NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Congeneres"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn18c00") then   ### NIVEL 6/4
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Carro_extra"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn42c00") then   ### NIVEL 6/4
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Aeroportos"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn11c00") then   ### NIVEL 6/4
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Guia_postal"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn46c00") then   ### NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Mapas"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn12c00") then   ### NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Moeda"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn19c00") then   ### NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Convenios"
             end if
          end if
#         if get_niv_mod(g_issk.prgsgl,"ctn10c00") then   ### NIVEL 6
#            if g_issk.acsnivcod >= g_issk.acsnivcns then
#               show option "Local_risco"
#            end if
#         end if
          if get_niv_mod(g_issk.prgsgl,"ctn22c00") then   ### NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Agenda"
             end if
          end if
          #if get_niv_mod(g_issk.prgsgl,"fivtc010") then   ### NIVEL 6
          #   if g_issk.acsnivcod >= g_issk.acsnivcns then
          #      show option "Fundos"
          #   end if
          #end if
          if get_niv_mod(g_issk.prgsgl,"ofpgc094") then    ### NIVEL 6/4
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Pagamentos"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn27n00") then    ### NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Transmissoes"
             end if
          end if
          if get_niv_mod(g_issk.prgsgl,"ctn47c00") then    ### NIVEL 2
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Vidros"
             end if
          end if
          show option "Encerra"

#  command key ("O") "Oficinas"
   command "Lojas_Vidros"
           "Localiza lojas da Abravauto"
           message ""
           call ctg3_pesqloja()
           #error "Funcionalidade temporariamente indisponivel !" sleep 3

   command "Oficinas"
           "Localiza oficinas por nome ou cidade/bairro/rua"
           message ""
           call ctn06n00("","ctg3") returning ws.pstcoddig thru ws.endufd

#  command key ("D") "creDenciadas" "Consulta oficinas credenciadas"
   command "Referenciadas"
           "Consulta oficinas referenciadas"
           let m_server   = fun_dba_servidor("SINIS")
           let m_hostname = "porto@",m_server clipped , ":"

           call cta13m00_verifica_status(m_hostname)
                returning l_status,l_msg

           if l_status = true then
              message " Aguarde, pesquisando..." attribute (reverse)
              call fsgoa007_credenciada("","","","","") returning ws.pstcoddig
              message ""
           else
              error "Oficinas não disponiveis no momento ! ",l_msg
           end if

#  command key ("G") "Garantia_mecanica"
   command "Garantia_mecanica"
           "Localiza oficinas da Garantia Mecanica por cidade/bairro/rua"
           message ""
           call ctn06n00("16","ctg3") returning ws.pstcoddig thru ws.endufd
           # este parametro (ramo 16) indica as oficinas de garantia mecanica
           # que sera utilizado para acesso no modulo ctn06c01.

          #call ctn00c02 ("SP","SAO PAULO"," "," ")
          #     returning ws.endcep, ws.endcepcmp

          #if ws.endcep is null     then
          #   error "Nenhum criterio foi selecionado!"
          #else
          #   call ctn06c01(ws.endcep, 1, "S")
          #        returning ws.pstcoddig,
          #                  ws.nomrazsoc,
          #                  ws.endlgd,
          #                  ws.endbrr,
          #                  ws.endcid,
          #                  ws.endufd
          #end if

#  command key ("R") "auto_Revendas"
   command "Auto_revendas"
           "Localiza oficinas do Auto Revendas por cidade/bairro/rua"
           message ""
           call  ctn00c02 ("SP","SAO PAULO"," "," ")
                 returning ws.endcep, ws.endcepcmp

           if ws.endcep is null  then
              error "Nenhum criterio foi selecionado!"
           else
              call ctn29c00(ws.endcep)
           end if

#  command key ("D") "prestaDor"
   command "Prestador"
           "Localiza Prestador por nome/cidade/bairro/rua"
           message ""
           call ctn01n00("SP","SAO PAULO"," "," "," "," "," "," ")
                returning ws.pstcoddig

#  command key ("V") "Vistoria"
   command "Vistoria"
           "Localiza Postos de Vistoria por cidade/bairro/rua"
           message ""
           call ctn00c02 ("SP","SAO PAULO"," "," ")
                returning ws.endcep, ws.endcepcmp

           if ws.endcep is null  then
              error "Nenhum criterio foi selecionado!"
           else
              call ctn07c01(ws.endcep)
           end if

   command "Caps"                 #Johnny,Biz
           call ctn56c00()


#  command key ("S") "dispoSitivos"
   command "Dispositivos"
           "Localiza Postos de Instalacao de Dispositivos por cidade/bairro/rua"
           message ""
           call ctn00c02 ("SP","SAO PAULO"," "," ")
                returning ws.endcep, ws.endcepcmp

           if ws.endcep is null  then
              error "Nenhum criterio foi selecionado!"
           else
              call ctn05c02(ws.endcep)
           end if

#  command key ("C") "Corretores"
   command "Corretores"
           "Localiza Corretores por susep/cidade/bairro/rua"
           message ""
           call ctn09c02()

#  command key ("L") "Lista_oesp"
   command "Lista_oesp"
           "Pesquisa Lista Pelo Criterio Selecionado"
           message ""
           call ctn00c02 ("SP","SAO PAULO"," "," ")
                returning ws.endcep, ws.endcepcmp

           if ws.endcep is null  then
              error "Nenhum criterio foi selecionado!"
           else
              call ctn06c05(ws.endcep)
           end if

#  command key ("B") "dp_Batalhoes"
   command "Dp_batalhoes"
           "Localiza D.policial/Batalhoes por cidade/bairro/rua"
           message ""
           call ctn00c02 ("SP","SAO PAULO"," "," ")
                returning ws.endcep, ws.endcepcmp

           if ws.endcep is null  then
              error "Nenhum criterio foi selecionado!"
           else
              call ctn03c01(ws.endcep)
           end if

#  command key ("R") "Reguladores"
   command "Reguladores"
           "Localiza Reguladores de Transportes por UF/cidade"
           message ""
           call ctn04c00()

#  command key ("N") "iNspetorias"
   command "Inspetorias"
           "Localiza Inspetorias por cidade/bairro/rua"
           message ""
           call  ctn00c02 ("SP","SAO PAULO"," "," ")
                 returning ws.endcep, ws.endcepcmp

           if ws.endcep is null  then
              error "Nenhum criterio foi selecionado!"
           else
              call ctn02c01(ws.endcep)
           end if

#  command key ("T") "escriTorios"
   command "Escritorios"
           "Localiza Escritorios por cidade/bairro/rua"
           message ""
           call ctn00c02 ("SP","SAO PAULO"," "," ")
                returning ws.endcep, ws.endcepcmp

           if ws.endcep is null  then
              error "Nenhum criterio foi selecionado!"
           else
              call ctn08c01(ws.endcep)
           end if

#  command key ("U") "sUcursais"  "Consulta sucursais"
   command "Sucursais"
           "Consulta sucursais"
           call ctn14c00()

#  command key ("R") "empResas"   "Consulta empresas"
   command "Empresas"
           "Consulta empresas"
           call ctn15c00()

#  command key ("G") "conGeneres" "Consulta congeneres"
   command "Congeneres"
           "Consulta congeneres"
           call ctn21c00()

#  command key ("X") "carro eXtra"  "Consulta lojas e/ou veiculos para locacao"
   command "Carro_extra"
           "Consulta lojas e/ou veiculos para locacao"

           call ctn00c02 ("SP","SAO PAULO"," "," ")
                returning ws.endcep, ws.endcepcmp

           if ws.endcep is null  or
              ws.endcep  =  0    then
              error "Nenhum criterio foi selecionado!"
           else
             #call ctn18c00("", ws.endcep, "", "", 0, false) -- OSF 37184
             #call ctn18c00("", ws.endcep, "", "", 0, 0)     -- OSF 37184
             #call ctn18c00("", ws.endcep, ws.endcepcmp, "", "", 0, 0)  -- PSI 198390
             call ctn18c00("", ws.endcep, ws.endcepcmp, "", "", 0, 0, "")  # PSI 205206
                   returning ws.lcvcod,
                             ws.aviestcod,
                             ws.vclpsqflg

              #if ws.vclpsqflg = TRUE  then
              #   call ctn17c00 (ws.lcvcod, ws.aviestcod)
              #        returning ws.avivclcod
              #end if

           end if

#  command key ("A") "Aeroportos"  "Consulta aeroportos"
   command "Aeroportos"
           "Consulta aeroportos"
           call ctn00c02 ("SP","SAO PAULO"," "," ")
                returning ws.endcep, ws.endcepcmp

           if ws.endcep is null  or
              ws.endcep  =  0    then
              error "Nenhum criterio foi selecionado!"
           else
              call ctn42c00(ws.endcep) returning ws.arpcod
           end if

#  command key ("A") "guia_postAl" "Consulta o guia postal"
   command "Guia_postal"
           "Consulta o guia postal"
           call ctn11c00()

   command "Mapas"
           "Consulta logradouro/calcula distancia pela base de dados de mapas"
           if ctx25g05_rota_ativa() then
              call ctx25g03("","","","","","")
           else
              call ctn46c00(0)
           end if

#  command key ("M") "Moeda"       "Cotacao por moeda"
   command "Moeda"
           "Cotacao por moeda"
           call ctn12c00()

#  command key ("I") "convenIos"   "Consulta Sucursais dos Convenios"
   command "Convenios"
           "Consulta Sucursais dos Convenios"
           message ""
           call ctn00c02 ("SP","SAO PAULO"," "," ")
                returning ws.endcep, ws.endcepcmp

           if ws.endcep is null  then
              error "Nenhum criterio foi selecionado!"
           else
              call ctn19c00(ws.endcep)
           end if

#  command key ("R") "loc_Risco"  "Localiza locais de risco/apolices de R.E."
#  command "Local_risco"
#          "Localiza locais de risco/apolices de R.E."
#          call ctn10c00("SP","SAO PAULO","")

#  command key ("A") "Agenda"      "Agenda de telefones"
   command "Agenda"
           "Agenda de telefones"
           call ctn22c00()

#  command key ("F") "Fundos"      "Cotacao de fundos de investimentos"
 #  command "Fundos"
 #          "Cotacao de fundos de investimentos"
 #          call fivtc010()

#  command key ("P") "Pagamentos"  "Consulta pagamentos no Sistema Contas a Pagar"
   command "Pagamentos"
           "Consulta pagamentos no Sistema Contas a Pagar"
           #run ws.comando
           call roda_prog("ofpgc094",ws.comando,1)
                returning ws.ret

          if  ws.ret <> 0  then
              error " Erro durante ",
                    "a execucao do programa ofpgc094",
                    ". AVISE A INFORMATICA!"
          end if

#  command key ("T") "Transmissoes"
   command "Transmissoes"
           "Consulta servicos/mensagens enviadas por fax, impr.remota ou MDT"
           call ctn27n00()

   command "Vidros"
           "Consulta atendimento reparos vidros Carglass"
           call ctn47c00()

#  command key (interrupt,"E") "Encerra"
   command key (interrupt) "Encerra"
           "Retorna ao menu anterior"
           exit menu
   end menu

end main

#----------------------------------------------------------
 function ctg3_pesqloja()
#----------------------------------------------------------
   define ws   record
       hora         char(05),
       retflg       char(01),
       segsexinchor like adikvdrrpremp.segsexinchor,
       segsexfnlhor like adikvdrrpremp.segsexfnlhor,
       sabinchor    like adikvdrrpremp.sabinchor,
       sabfnlhor    like adikvdrrpremp.sabfnlhor,
       atntip       like adikvdrrpremp.atntip
   end record

   define lr_item      record
          parabrisa    char(01),
          traseiro     char(01),
          lateral      char(01),
          oculo        char(01),
          quebravento  char(01),
          retrovisor   char(01),
          farol        char(01),
          farolmilha   char(01),
          farolneblina char(01),
          pisca        char(01),
          lanterna     char(01)
   end record

   define w_cts19m05 record
       atdprscod    like datmservico.atdprscod,  # codigo do prestador
       nomprest     char(20),
       imdsrvflg    char(1),
       srrcoddig    like datmservico.srrcoddig,  # codigo da loja
       nomloja      char(30),
       cidnom       char(48),
       ufdcod       char(02),
       dddcod       like dpaksocor.dddcod,
       teltxt       like dpaksocor.teltxt,
       contato      char(20),
       horloja      char(52)
   end record
   define a_cts06g03  record
       lclidttxt    like datmlcl.lclidttxt       ,
       lgdtxt       char (65)                    ,
       lgdtip       like datmlcl.lgdtip          ,
       lgdnom       like datmlcl.lgdnom          ,
       lgdnum       like datmlcl.lgdnum          ,
       brrnom       like datmlcl.brrnom          ,
       lclbrrnom    like datmlcl.lclbrrnom       ,
       endzon       like datmlcl.endzon          ,
       cidnom       like datmlcl.cidnom          ,
       ufdcod       like datmlcl.ufdcod          ,
       lgdcep       like datmlcl.lgdcep          ,
       lgdcepcmp    like datmlcl.lgdcepcmp       ,
       lclltt       like datmlcl.lclltt          ,
       lcllgt       like datmlcl.lcllgt          ,
       dddcod       like datmlcl.dddcod          ,
       lcltelnum    like datmlcl.lcltelnum       ,
       lclcttnom    like datmlcl.lclcttnom       ,
       lclrefptotxt like datmlcl.lclrefptotxt    ,
       c24lclpdrcod like datmlcl.c24lclpdrcod    ,
       ofnnumdig    like sgokofi.ofnnumdig       ,
       emeviacod    like datkemevia.emeviacod    ,
       celteldddcod like datmlcl.celteldddcod    ,
       celtelnum    like datmlcl.celtelnum       ,
       endcmp       like datmlcl.endcmp
   end record
   define hist_cts06g03 record
       hist1        like datmservhist.c24srvdsc,
       hist2        like datmservhist.c24srvdsc,
       hist3        like datmservhist.c24srvdsc,
       hist4        like datmservhist.c24srvdsc,
       hist5        like datmservhist.c24srvdsc
   end record

   define l_data     date,
          l_hora2    datetime hour to minute

  initialize  ws, w_cts19m05, a_cts06g03, hist_cts06g03, lr_item to null

    let g_documento.atdsrvnum = null

   call cts40g03_data_hora_banco(2)
        returning l_data, l_hora2
   let ws.hora = l_hora2
   call cts06g03 (1,14,1,l_data,ws.hora,
                  a_cts06g03.lclidttxt,
                  a_cts06g03.cidnom,
                  a_cts06g03.ufdcod,
                  a_cts06g03.brrnom,
                  a_cts06g03.lclbrrnom,
                  a_cts06g03.endzon,
                  a_cts06g03.lgdtip,
                  a_cts06g03.lgdnom,
                  a_cts06g03.lgdnum,
                  a_cts06g03.lgdcep,
                  a_cts06g03.lgdcepcmp,
                  a_cts06g03.lclltt,
                  a_cts06g03.lcllgt,
                  a_cts06g03.lclrefptotxt,
                  a_cts06g03.lclcttnom,
                  a_cts06g03.dddcod,
                  a_cts06g03.lcltelnum,
                  a_cts06g03.c24lclpdrcod,
                  a_cts06g03.ofnnumdig,
                  a_cts06g03.celteldddcod,
                  a_cts06g03.celtelnum,
                  a_cts06g03.endcmp,
                  hist_cts06g03.*, a_cts06g03.emeviacod)
        returning a_cts06g03.lclidttxt,
                  a_cts06g03.cidnom,
                  a_cts06g03.ufdcod,
                  a_cts06g03.brrnom,
                  a_cts06g03.lclbrrnom,
                  a_cts06g03.endzon,
                  a_cts06g03.lgdtip,
                  a_cts06g03.lgdnom,
                  a_cts06g03.lgdnum,
                  a_cts06g03.lgdcep,
                  a_cts06g03.lgdcepcmp,
                  a_cts06g03.lclltt,
                  a_cts06g03.lcllgt,
                  a_cts06g03.lclrefptotxt,
                  a_cts06g03.lclcttnom,
                  a_cts06g03.dddcod,
                  a_cts06g03.lcltelnum,
                  a_cts06g03.c24lclpdrcod,
                  a_cts06g03.ofnnumdig,
                  a_cts06g03.celteldddcod,
                  a_cts06g03.celtelnum,
                  a_cts06g03.endcmp,
                  ws.retflg,
                  hist_cts06g03.*, a_cts06g03.emeviacod

   call cts19m05(0                    ,
                 ""                   ,
                 a_cts06g03.lclltt    ,
                 a_cts06g03.lcllgt    ,
                 "ctg3",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "",
                 "")

       returning w_cts19m05.srrcoddig ,
                 w_cts19m05.nomloja   ,
                 w_cts19m05.cidnom    ,
                 w_cts19m05.ufdcod    ,
                 w_cts19m05.dddcod    ,
                 w_cts19m05.teltxt    ,
                 w_cts19m05.atdprscod ,
                 w_cts19m05.nomprest  ,
                 w_cts19m05.horloja   ,
                 w_cts19m05.contato   ,
                 ws.segsexinchor       ,
                 ws.segsexfnlhor       ,
                 ws.sabinchor          ,
                 ws.sabfnlhor         ,
                 ws.atntip
 end function
#----------------------------------------------------------
 function p_reg_logo()
#----------------------------------------------------------
     define ba char(01)


        let     ba  =  null

     open form reg from "apelogo2"
     display form reg
     let ba = ascii(92)
     display ba at 15,23
     display ba at 14,22
     display "PORTO SEGURO" AT 16,52
     display "                                  Seguros" at 17,23
             attribute (reverse)
end function
