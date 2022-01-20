###########################################################################
# Nome do Modulo: CTG1                                    Cristiane Silva #
#                                                                         #
# Menu Central 24 Horas                                                   #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################
#.........................................................................#
#                  * * *  ALTERACOES  * * *                               #
#                                                                         #
# Data       Autor Fabrica PSI       Alteracao                            #
# --------   ------------- ------    -------------------------------------#
# 21/02/2006 Andrei, Meta  PSI196878 Cria opcao de menu 'Ciaaereas'       #
#-------------------------------------------------------------------------#
#  Data       Autor Fabrica PSI       Alteracao                           #
# --------   ------------- ------    -------------------------------------#
# 24/09/2007 Ana Raquel,Meta 211982  Inclusao das opcoes no Menu          #
#                                    Permissao_Cartao e Grupo             #
#-------------------------------------------------------------------------#
#            Kevellin                PSI Melhorias na Comunicacao e       #
#                                    PSI Gerenciamento Frota Extra        #
#-------------------------------------------------------------------------#
#            Kevellin                PSI Gerenciamento da Frota Extra     #
#-------------------------------------------------------------------------#
# 05/05/2010 Burini        255734    Integração PSO x VST                 #
#-------------------------------------------------------------------------#
# 17/09/2010 Robert Lima   00009EV   Inclusão do menu cadeia de gestao    #
#-------------------------------------------------------------------------#
# 09/10/2013 Vinicius      XXXX      Inclusão do menu Campanhas           #
###########################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define w_log   char(60)

 define mr_entrada record
                           prtbnfcod like dpakprtbnf.prtbnfcod,
                           pstcoddig like dpakprtbnf.pstcoddig,
                           nomgrr    like dpaksocor.nomgrr,
                           srvqtd    like dpakprtbnf.srvqtd,
                           bnfqtd    like dpakprtbnf.bnfqtd,
                           actbnfqtd like dpakprtbnf.actbnfqtd,
                           bnfvlr    like dpakprtbnf.bnfvlr
                       end record

 define where_clause char(1000),
        m_consulta_ativa smallint

main

   define x_data  date
   define ws_qtde integer
   define l_parm  smallint

   call fun_dba_abre_banco("CT24HS")

   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg1.log"

   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------



   select unique sitename into g_hostname from dual

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last,
      message line last,
      accept  key  F40

   ##whenever error continue

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
           "----------ctg1--" at 03,01

   menu "CADASTROS"


      before menu
      command key ("I") "msg_mId"
              "Envio de mensagens MDT"
         call cts24m02()

      command key ("R") "gRupos"
              "Manutencao dos grupos de naturezas de socorro"
         call ctc16m02()

      command key ("N") "Naturezas"
              "Manutencao das naturezas de socorro"
         call ctc16m00()

      command  key ("P") "Problemas"
              "Cadastro de Problemas"
         call ctc48m00()

      command key ("G")  "Grp_problemas"
              "Cadastro de Agrupamento de Problemas"
         call ctc49m00()

      command  key("S")  "eSpecialidades"
              "Cadastro de Especialidades"
         call ctc73m00()

      # Psi198714
      command key ("Q")  "categ x eQuip"
              "Cadastro de de Categorias Tarifarias por Equipamento"
         call ctc78m00()

      command  key ("X") "eXcecoes"
	      "Excecoes de Veiculos por Guincho"
         call ctc79m00()

      # PSI196878
      command key ("A") 'ciaAereas' 'Manutencao das companhias aereas'
         call ctc10m00()

      # PSI196878
      command key ("B") 'Bonificacao' 'Manutencao das companhias aereas'
         call ctg1_bnf()

      command key ("T") "parameTros" 'Parametros Portal Prestador'
         call ctc86m00()

      command key ("O") "param x Origem" 'Parametros Portal Prestador'
         call ctc86m01()

      command key ("M") "PerMissao_Cartao"
            "Cadastro de Permissoes do Cartao"
         call ctc82m00()

      # PSI 241423 - Orientação de Complemento de Endereço.
      command key ("D") "inDexacao"
            "Cadastro de Permissoes do Cartao"
         call ctc87m00()

      command key ("C") "sms_cliente x Cidades"
                        "Manutencao do cadastro de cidades que possuem aviso via SMS"
        call ctc89m00()          
      
      command key("L")  "paineL_Controle"
            "Painel de Controle"
         call ctc88m00()

      command key("y") "e-mail_rel" "Manutencao de e-mail dos relatorios"
         call ctb26m00()
      
      command key("k") "cadeia de gestao" "Matem o cadastro do grupo de gestao Porto Socorro"
         call ctc00m22()
         
      command key("f") "ger_esp" "Matem o cadastro de config do gerenciamento de especialidades"
         call ctc00m23()

      command key("U") "bloqUeios" "Menu de Bloqueios"
         call ctc94m00()
      
      command key("z") "contabilidade" "Cadastro de parametros contabeis para Integracao com a Contabilidade"
         call ctc93m00()
         
      command key("V") "Valor referncia" "Cadastro do valor referencia(M.O.) e pecas"
         call ctc98m00()   
      
      command key("H") "campanHas" "Cadastro de Campanhas de Atualizacao Cadastral do Prestador"
         call ctc00m26()
      
 # inicio PSI 2013-07173
      command Key ("W") "cli_saps" "Cadastro de Clientes I"
         Call ctc67m00()
 # fim PSI 2013-07173

      command key ("E",interrupt) "Encerra" "Retorna ao menu anterior"
         exit menu
         clear screen
   end menu

   let int_flag = false

   close window win_cab
   close window win_menu

end main

#----------------------------------------------------------
function p_reg_logo()
#----------------------------------------------------------
     define ba char(01)

     open form reg from "apelogo2"
     display form reg
     let ba = ascii(92)
     display ba at 15,23
     display ba at 14,22
     display "PORTO SEGURO" AT 16,52
     display "                                  Seguros" at 17,23
             attribute (reverse)
end function

#---------------------------#
 function ctg1_bnf_prepare()
#---------------------------#

     define l_sql char(5000)

     let l_sql = "select nomgrr ",
                  " from dpaksocor ",
                 " where pstcoddig = ? "

     prepare pcctg1_bnf_02 from l_sql
     declare cqctg1_bnf_02 cursor for pcctg1_bnf_02

 end function

#-------------------#
 function ctg1_bnf()
#-------------------#


     #open window w_ctg1_bnf at 4,2 with form "ctc20m00"
     #     attribute(form line first, border)

     options
        help file "ctg1_bnf.hlp",
        help key f3

     menu "BONIFICACAO"

      command key ("P") "Processos"
                       "Manutencao do Cadastro de Criterios da Bonificacao"
        call ctc20m06()

      command key ("R") "cRiterios"
                       "Manutencao do Cadastro de Criterios da Bonificacao"
        call ctc20m01()

      command key ("G") "Grupo_Servico"
                       "Manutencao do Cadastro de Grupos de Servico"
        call ctc20m02()

      command key (interrupt,E) "Encerra"
                       "Retorna ao menu anterior"
        exit menu
     end menu

     #close window w_ctg1_bnf

 end function

{#-----------------------------#
 function ctg1_bnf_seleciona()
#-----------------------------#

     define where_clause char(1000),
            l_sql        char(5000)

     initialize mr_entrada.* to null

     let int_flag = false
     let m_consulta_ativa = false
     display by name mr_entrada.prtbnfcod
          attribute(reverse)
     construct by name where_clause on prtbnfcod,
                                       pstcoddig

        on key (f3)
           case
              when infield(prtbnfcod)
                   call showhelp(101)
              when infield(pstcoddig)
                   call showhelp(102)
           end case

     end construct

     if  not int_flag then

         let l_sql = "select prtbnfcod, ",
                           " pstcoddig, ",
                           " srvqtd, ",
                           " bnfqtd, ",
                           " actbnfqtd, ",
                           " bnfvlr ",
                      " from dpakprtbnf ",
                     " where ", where_clause

         prepare pcctg1_bnf_01 from l_sql
         declare cqctg1_bnf_01 scroll cursor for pcctg1_bnf_01

         open  cqctg1_bnf_01
         fetch cqctg1_bnf_01 into mr_entrada.prtbnfcod,
                                  mr_entrada.pstcoddig,
                                  mr_entrada.srvqtd,
                                  mr_entrada.bnfqtd,
                                  mr_entrada.actbnfqtd,
                                  mr_entrada.bnfvlr

         if  sqlca.sqlcode = 0 then
             let m_consulta_ativa = true
             call ctg1_bnf_exibe_dados()
         else
             if  sqlca.sqlcode = notfound then
                 let m_consulta_ativa = false
                 error "Nenhuma Bonificação selecionada."
                 clear form
             end if
         end if
     end if

 end function

#-------------------------------#
 function ctg1_bnf_exibe_dados()
#-------------------------------#

     display by name mr_entrada.prtbnfcod
     display by name mr_entrada.pstcoddig

     open cqctg1_bnf_02 using mr_entrada.pstcoddig
     fetch cqctg1_bnf_02 into mr_entrada.nomgrr

     display by name mr_entrada.srvqtd
     display by name mr_entrada.bnfqtd
     display by name mr_entrada.actbnfqtd
     display by name mr_entrada.bnfvlr

 end function

#----------------------------------#
 function ctg1_bnf_paginacao(l_opcao)
#----------------------------------#

    define l_opcao char(1)

    define lr_retorno record
                         erro       smallint,
                         mensagem   char(60)
                      end record

    if  l_opcao = "P" then
        whenever error continue
        fetch next cqctg1_bnf_01 into mr_entrada.prtbnfcod,
                                      mr_entrada.pstcoddig,
                                      mr_entrada.srvqtd,
                                      mr_entrada.bnfqtd,
                                      mr_entrada.actbnfqtd,
                                      mr_entrada.bnfvlr
        whenever error stop
    else
        whenever error continue
        fetch previous cqctg1_bnf_01 into mr_entrada.prtbnfcod,
                                          mr_entrada.pstcoddig,
                                          mr_entrada.srvqtd,
                                          mr_entrada.bnfqtd,
                                          mr_entrada.actbnfqtd,
                                          mr_entrada.bnfvlr
        whenever error stop
    end if

    if  sqlca.sqlcode = 0 then
        call ctg1_bnf_exibe_dados()
    else
        error 'Nao existem mais dados nessa direção.'
    end if

 end function
}
