###########################################################################
# Nome do Modulo: CTG                                               Pedro #
#                                                                         #
# Menu principal da Central 24 Horas                                      #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
# 24/01/2001  PSI 120197   Wagner       Inclusao acesso ao menu Teletrim  #
#                                       modulo ctc42n00.                  #
###########################################################################
#                                                                         #
#                       * * * Alteracoes * * *                            #
#                                                                         #
# Data        Autor Fabrica  Origem      Alteracao                        #
# ----------  -------------- ---------  --------------------------------  #
# 23/08/2003  Meta,Bruno     PSI175552   Criar nova opcao de menu         #
#                            OSF26077    Menu - Parametros.               #
# 24/10/2003  Meta, Bruno    PSI175269   Chamar funcao ctc21n00.          #
#                            OSF25780                                     #
# 17/12/2003  Paulo, Meta    PSI180475   Inserir a opcao Motivos no menu. #
# 18/03/2004  Klaus Paiva    OSF33553    Cadastro de Locais especiais     #
#-------------------------------------------------------------------------#
# 22/04/2004  Meta, Ivone    PSI170771   Chamar funcao ctc04m00.          #
#                            OSF34703                                     #
#-------------------------------------------------------------------------#
# 18/05/2005  Adriano, Meta  PSI191108   Inclusao de opcao Vias_emergen-  #
#                                        ciais no menu "CADASTROS"        #
#-------------------------------------------------------------------------#
# 29/07/2005  Vinicius, Meta PSI192015   Nova opcao no menu:              #
#                                        "Local Condicoes_veicUlo"        #
#-------------------------------------------------------------------------#
# 01/11/2005  Priscila       PSI195138   Nova opcao no menu:"Acionamento" #
#                                        Nova opcao no menu:"Rodizio"     #
#-------------------------------------------------------------------------#
# 07/08/2006  Priscila       PSI202290   Parametrizacao cadastro Cad_ct24h#
# 24/11/2006  Ligia          PSI 205206  Clausulas_Azul                   #
###########################################################################


 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define w_log   char(60)
 define m_prep      smallint

main

   define x_data  date
   define ws_qtde integer
   define l_parm  smallint   ## PSI 175269
   define l_acesso smallint
   define l_acesso_menu record
          flag          smallint
         ,acesso        smallint
   end record

   call fun_dba_abre_banco("CT24HS")

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg.log"

   call startlog(w_log)

  let l_acesso_menu.flag = 0
  let l_acesso_menu.acesso = 0
   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------



   select unique sitename into g_hostname from dual   # PSI 175552

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last,
      message line last,
      accept  key  F40

   whenever error continue

   open window WIN_CAB at 02,02 with 22 rows, 78 columns
        attribute (border)

   let x_data = today
   display "CENTRAL 24 HS"  at  01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" at 01,20
   display x_data           at  01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()

   display "---------------------------------------------------------------",
           "----------ctg--" at 03,01

   menu "CADASTROS"

      ## PSI 175269 - Inicio

      before menu

         #PSI 202290 - verificar nivel de acesso do modulo para o programa
         # e comparar com o nievl de acesso do usuario, caso seja maior ou
         # igual, permitir usuario de executar o item de menu

         hide option all

      call ctg_acessa_submenu(g_issk.empcod
                             ,g_issk.funmat)
         returning l_acesso_menu.acesso
                  ,l_acesso_menu.flag
         #display "prgsgl ", g_issk.prgsgl
         #display "acsnivcod ", g_issk.acsnivcod

         if get_niv_mod(g_issk.prgsgl,"ctc01m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Dp_batalhoes"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc03m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Escritorios"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc05m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Inspetorias"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc12m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Lista_oesp"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc27m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Aeroportos"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc47m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Solicitantes"
            end if
         end if
     if l_acesso_menu.flag = 1 then
         if get_niv_mod(g_issk.prgsgl,"ctc14n00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Assuntos"
            end if
         end if
     end if

         if get_niv_mod(g_issk.prgsgl,"ctc21n00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Procedimentos"
            end if
         end if

         #if get_niv_mod(g_issk.prgsgl,"ctc41n00") then
         #   if g_issk.acsnivcod >= g_issk.acsnivcns then
         #      show option "Gps"
         #   end if
         #end if

         if get_niv_mod(g_issk.prgsgl,"ctc32n00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Bloqueios"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc33m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Matriculas"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc15n00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Servico_assistencia"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc22n00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Convenios"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc23m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Agenda"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc29n00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Relatorios"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc40m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Dominios"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc42n00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Teletrim"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc54m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Patio_RPT"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc64m00") then  #psi 205206
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "clausulas_Azul"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc56m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Texto_clausulas"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc55m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "RamoXclausulas"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc58m01") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Custos"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc59m01") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Cidade_sede"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc59m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Regulador"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctb24m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Motivos_retorno"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc71m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Locais_Fixos"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc00m10") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Parametros"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc26m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Motivos"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc04m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "tipo_Fax"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc17m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Vias_emergenciais"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc61m01") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "local_condicoes_veicUlo"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc72m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Acionamento"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc72m01") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Rodizio"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctb26m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "e-mail_reL"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctb29m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "param_ct24h"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc83m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
              show option "Grupos_Atd"
            end if
         end if

         if get_niv_mod(g_issk.prgsgl,"ctc62m00") then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
              show option "Acesso_Servicos"
            end if
         end if

          show option "Regras_Segmento"
          show option "Rastreamento_ligacoes"

         #if get_niv_mod(g_issk.prgsgl,"ctc95m00") then
         #   if g_issk.acsnivcod >= g_issk.acsnivcns then
              show option "Login_Azul"
         #   end if
         #end if
         if l_acesso_menu.acesso = 1 then
         			 show option "Liberacao_Acesso"
         end if
        show option "Encerra"

         #if g_issk.dptsgl <> "ct24hs" and
         #   g_issk.dptsgl <> "psocor" and
         #   g_issk.dptsgl <> "desenv" then
         #   hide option all
         #   show option "Procedimentos"
         #   show option "Locais_Fixos"
         #   show option "Encerra"
         #end if
         #PSI 202290 - fim

      ## PSI 175269 - Final

      command "Dp_batalhoes"
              "Manutencao de Distrito Policial/Batalhoes"
         call ctc01m00()

      command "Escritorios"
              "Manutencao de escritorios de corretagem"
         call ctc03m00()

      command "Inspetorias"
              "Manutencao de inspetorias"
         call ctc05m00()

      command "Lista_oesp"
              "Manutencao da lista de empresas X servicos"
         call ctc12m00()

      command "Aeroportos"
              "Manutencao de aeroportos"
         call ctc27m00()

      command "Solicitantes"
              "Manutencao de tipos de solicitante"
         call ctc47m00()

      command "Assuntos"
              "Manutencao dos codigos de assunto para atendimento"
         call ctc14n00()

      command "Procedimentos"
              "Manutencao dos procedimentos para atendimento"

## PSI 175269 - Inicio
         call cta00m06_acionamento(g_issk.dptsgl)
         returning l_acesso

         if l_acesso = true then
            let l_parm = 0
         else
            let l_parm = 2
         end if

         call ctc21n00(l_parm)

## PSI 175269 - Final

      command "Bloqueios"
              "Manutencao dos bloqueios de atendimento"
         call ctc32n00()

      command "Matriculas"
              "Manutencao das matriculas com permissao de liberacao"
         call ctc33m00()

      command "Servico_assistencia"
              "Manutencao dos tipos de servicos/assistencias"
         call ctc15n00()

      # PSI 195138 - Cadastros foram para Porto Socorro
      #command "Naturezas"
      #        "Manutencao das naturezas de socorro"
      #   call ctc16m00()

      command "Convenios"
              "Manutencao das informacoes dos convenios"
         call ctc22n00()

      command "Agenda"
              "Manutencao da agenda de telefones"
         call ctc23m00()

      command "Relatorios"
              "Solicitacao de relatorios"
         call ctc29n00()

      command "Dominios"
              "Manutencao de dominios"
         call ctc40m00()

      # PSI 195138 - Cadastros foram para Porto Socorro
      #command  "Problemas"
      #        "Cadastro de Problemas"
      #   call ctc48m00()

      # PSI 195138 - Cadastros foram para Porto Socorro
      #command  "Grp_Problemas"
      #        "Cadastro de Agrupamento de Problemas"
      #   call ctc49m00()

      command  "Teletrim"
              "Manutencao de Cadastros referente ao Teletrim"
         call ctc42n00()

      command  "Patio_RPT"
              "Manutencao de Cadastros Patio de RPT"
         call ctc54m00()

      command  "clausulas_Azul" #psi 205206
              "Manutencao das clausulas da Azul Seguros"
         call ctc64m00()

      command  "Texto_clausulas"
              "Manutencao de textos para Clausulas"
         call ctc56m00()

      command  "RamoXclausulas"
              "Manutencao de Ramo x Clausulas"
         call ctc55m00()

      command  "Custos"
              "Manutencao de Centro de Custo para Assunto/Agrupamento"
         call ctc58m01()

      command  "Cidade_sede"
              "Manutencao de Cidades x Cidade Sede "
         call ctc59m01()

      command  "Regulador"
              "Manutencao de regulador de servico"
         call ctc59m00()

      command  "Motivos_retorno"
              "Manutencao de Motivos de Retorno de servicos RE"
         call ctb24m00()

      command "Locais_Fixos"
              "Manutencao de locais Fixos "
              call inisql_ctc71m00()
              call tela_ctc71m00()

      command  "Parametros"                                   # PSI 175552
              "Manutencao dos Parametros para envio de Mensagens"
         call ctc00m10()

      ###
      ### Inicio PSI180475 - Paulo
      ###
      command "Motivos" "Cadastro de Motivos"
         call ctc26m00()
      ###
      ### Final PSI180475 - Paulo
      ###

      #inicio psi170771  ivone
      command key ("F") "tipo_Fax"
              "Manutencao de Motivos de Tipos de fax do Porto View"
         call ctc04m00()
      #fim psi170771  ivone

      command "Vias_emergenciais" "Manutencao de vias emergencias"
         call ctc17m00()

      command key ("U") "local_condicoes_veicUlo" "Cadastro de Locais/Condicoes do Veiculo "
         call ctc61m01()

      #PSI195138
      command "Acionamento" "Parametros do Acionamento Automatico"
         call ctc72m00()
      #PSI 195138

      command "Rodizio" "Cadastro de Parametros de Rodizio"
         call ctc72m01()

      command "e-mail_reL" "Manutencao de e-mail dos relatorios"
         call ctb26m00()

      command "param_ct24h" "Manutencao dos parametros da Central 24H"
         call ctb29m00()

      command "Grupos_Atd" "Grupos de Atendimento da Teleperformance"
         call ctc83m00()

      command "Acesso_Servicos" "Controle de Acesso a Tela de Servicos"
         call ctc62m00()

      command "Liberacao_Acesso" "Controle de Acesso a Tela de Atendimento"
         call ctc63m00()
      command "Rastreamento_ligacoes" "Consulta Email Rastreamento"
         call ctc63m03()

      command "Regras_Segmento" "Cadastro de Regras do Segmento"
         call ctc53m00()
      command "Login_Azul" "Cadastro de depara login_azul"
         call ctc95m00()
      command key (interrupt) "Encerra" "Retorna ao menu anterior"
         exit menu
         clear screen

   end menu

   let int_flag = false         #psi170771   ivone

   close window win_cab
   close window win_menu

end main
#---------------------------------
function ctg_prepare()
#---------------------------------
define l_sql       char(300)
let l_sql = " select count(*) "
           ," from datrc24mnufun "
           ," where empcod = ? "
           ,"   and funmat = ? "
prepare p_ctg_001 from l_sql
declare c_ctg_001 cursor for p_ctg_001
let l_sql = " select cpodes[02,03]        "
           ,"       ,cpodes[04,08]        "
           ,"   from datkdominio          "
           ,"  where cponom = 'novo_menu' "
prepare p_ctg_002 from l_sql
declare c_ctg_002 cursor for p_ctg_002
let m_prep = 1
end function

#----------------------------------------------------------
function p_reg_logo()
#----------------------------------------------------------
     define ba char(01)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

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
#--------------------------------------
function ctg_acessa_submenu(lr_param)
#--------------------------------------
define lr_param record
       empcod   like datrc24mnufun.empcod,
       funmat   like datrc24mnufun.funmat
end record
define l_retorno record
       flag      smallint
      ,acesso    smallint
      ,cpodes    like datkdominio.cpodes
      ,cpodes1   like datkdominio.cpodes
end record
let l_retorno.flag = 0
let l_retorno.acesso = 0
 call ctg_prepare()
    open c_ctg_002
    foreach c_ctg_002 into l_retorno.cpodes
                           ,l_retorno.cpodes1
        if l_retorno.cpodes = g_issk.empcod and
           l_retorno.cpodes1 = g_issk.funmat then
           let l_retorno.acesso = 1
           exit foreach
        end if
    end foreach

       open c_ctg_001 using lr_param.empcod
                           ,lr_param.funmat
       fetch c_ctg_001 into l_retorno.flag
       close c_ctg_001

 return l_retorno.acesso
       ,l_retorno.flag
end function
