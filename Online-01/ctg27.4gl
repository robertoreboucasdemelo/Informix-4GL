#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Atendimento Porto Seguro FAZ                               #
# Modulo.........: ctg27                                                      #
# Objetivo.......: Modulo Principal de Cadastro                               #
# PSI            : PSI-2014-19759EV                                           #
#.............................................................................#
# Desenvolvimento: Celso Yamahaki                                             #
# Liberacao      : out/2014                                                   #
#.............................................................................#
#                         * * * Alteracoes * * *                              #
#   Data     Autor Fabrica     Origem    Alteracao                            #
# ---------- ----------------- --------- -------------------------------------#
# 17/04/2015 Norton Biztalking PSI-2014-19759EV  Inclusao menu Indicadores    #
#-----------------------------------------------------------------------------#
# 09/10/2015 INTERA,Marcos MP  SPR-2015-19757  Incluir "Venda" no menu Indica-#
#                                              dores.                         #
#-----------------------------------------------------------------------------#
# 26/11/2015 BizTalking - SPR-2015-23591 - Indicadores Acionamento            #
#                         Incluir no menu "Indicadores" a chamada do modulo   #
#                         de Extracao de Acompanhamento de Acionamentos       #
#                         Incluir no Menu a chamada do modulo de Extracao     #
#                         Pelo numero de Telefone cadastrado no Servico       #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

globals
  define m_prep smallint
  define w_data date
  define w_log     char(60)

end globals

#------#
  main
#------#
   call fun_dba_abre_banco("CT24HS")
   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg27.log"

   call startlog(w_log)

   select sitename into g_hostname from dual

   let g_hostname = g_hostname[1,3]

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last,
      message line last,
      accept  key  F40

   whenever error continue
   initialize g_ppt.* to null

   open window WIN_CAB at 2,2 with 22 rows,78 columns
        attribute (border)

   let w_data = today
   display "CENTRAL 24 HS" at 01,01
   display "P O R T O  S E G U R O " AT 1,30
   display w_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns

   call p_reg_logo()
   call get_param()

    display "---------------------------------------------------------------",
           "-------ctg27---" at 03,01

   call ctg27_menu()

   close window WIN_MENU
   close window WIN_CAB

end main


#=====================
 function ctg27_menu()
#=====================
   define w_param   char(100)   # ruiz
   define w_apoio   char(01)
   define w_empcodatd like isskfunc.empcod
   define w_funmatatd like isskfunc.funmat
   define w_usrtipatd like isskfunc.usrtip
   define l_flag     smallint


 let int_flag = false   
 initialize w_apoio     to null
 initialize w_empcodatd to null
 initialize w_funmatatd to null
 initialize w_usrtipatd to null
 initialize g_c24paxnum to null
 menu "CADASTROS:"

      before menu
         hide option all
         if ctg27_acesso() then
            show option "Fechamento Etapas"
            show option "Indicadores"
         end if 
      show option "Atd_PSS"
	    show option "Encerra"


    command key ("F") "Fechamento Etapas" "Fechamento das Etapas do Servico"
             call opsfa008_fechamento()

    #command key ("P") "Produtividade" "Analise da Produtividade"
    #
    #         call opsfa011()

    command key ("I") "Indicadores" "Quantificador de Servicos"

             call menu_indicadores()

    command key ("U") "Atd_PSS"
                  "Atendimento Porto Seguro Serviços"
    initialize g_documento.* to null
    let g_documento.ciaempcod = '43'
    let g_issk.prgsgl = 'ctg2'
    let l_flag = cta00m05_controle(w_apoio,
                                   w_empcodatd,
                                   w_funmatatd,
                                   w_usrtipatd,
                                   g_c24paxnum)  
      command key ("E") "Encerra" "Fim de servico"
             exit menu


 end menu

end function

#----------------------------------------------------------
function p_reg_logo()
#----------------------------------------------------------
     define ba char(01)

	let	ba  =  null

     open form reg from "apelogo2"
     display form reg
     let ba = ascii(92)
     display ba at 15,23
     display ba at 14,22
     display "PORTO SEGURO" AT 16,52
     display "                                  Seguros" at 17,23
             attribute (reverse)
end function

#-----------------------------------------------------------
 function menu_indicadores()
#-----------------------------------------------------------

   menu "INDICADORES"

      command key ("P") "Produtividade" "Analise da Produtividade"
         call opsfa011()

      command key ("C") "Canais de venda"
                        "Indicadores Canais de Venda "
         call opsfa018()

      command key ("S") "Status do fechamento "
                        "Indicadores Status do Fechamento"
         call opsfa020()

      command key ("G") "Grupos de sku"
                        "Indicadores Grupos de SKU "
         call opsfa021()

      command key ("V") "Vendas_operador"
                        "Consulta Vendas por Operador "
         call opsfc030()

      command key ("I") "vendas_supervIsor"
                        "Consulta Vendas por Operador de acordo com o supervisor"
         call opsfc033()

      command key ("O") "Operadores"
                        "Cadastro de Operadores Televendas"
         call opsfa031()

      command key ("L") "geraL vendas"
                        "Consulta Geral de Vendas"
         call opsfc029()

      command key ("D") "consoliDado"
                        "Consulta de Consolidados "
         call opsfc032()

      #=> SPR-2015-19757
      command key ("N") "veNdas"
                        "Extracao de Vendas por periodo"
         call opsfc039()

      #- SPR-2015-23591 - Extracao de vendas pelo Telefone
      command key ("T") "Telefone"
                        "Extracao de Vendas Pelo Telefone"
         call opsfc041()

      #- SPR-2015-23591 - Indicadores Acionamento
      command key ("A") "Acionamentos"
                        "Extracao de Acionamentos por Data"
         call opsfc042()


      command key ("B") "coBranca pendentes"
                        "Extracao de Cobrancas Pendentes"
         call opsfc044_cobranca_pendentes()    

      command key (interrupt,"E") "Encerra"
                                  "Fim de Servico"
         exit menu
   end menu

   return

end function  ###  menu_indicadores

#---------------------------------------
function ctg27_acesso()
#---------------------------------------

   define l_chave char(15)
   let l_chave = g_issk.empcod using "<<&", ",", g_issk.funmat using "<<<<<<<<<&"
   whenever error continue 
      select 1 from iddkdominio 
        where cpodes = l_chave
          and cponom = 'Atd_PSS'
      
      if sqlca.sqlcode = 0 then
         return true 
      else
         select 1 from datkdominio 
          where cpodes = l_chave
            and cponom = 'Atd_PSS'
         
         if sqlca.sqlcode = 0 then
            return true 
         end if            
      end if    

   return false


end function
