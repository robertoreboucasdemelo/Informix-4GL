#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Cadastros                                                  #
# Modulo.........: ctg26                                                      #
# Objetivo.......: Modulo Principal de Cadastro                               #
# PSI            : PSI-2014-19759EV                                           #
#.............................................................................#
# Desenvolvimento: Ligia Mattge - Fornax                                      #
# Liberacao      : out/2014                                                   #
#-----------------------------------------------------------------------------#
# 11/dez/2014 - Marcos Souza (BizTalking)- PSI SPR-2014-28503 - Inclusão da   #
#               chamada do "Cadastro Voucher - Cadastro de Cupom de Desconto  #
#               de Servico".                                                  #
#-----------------------------------------------------------------------------#
# 05/fev/2015 - Marcos Souza(BizTalking)- PSI SPR-2014-28503 - Inclusão da    #
#               chamada do "Cadastro Descrição Fiscal" e "Descrição do SKU"   #
#-----------------------------------------------------------------------------#
# 31/mar/2015 - INTERA, Marcos MP        - PSI SPR-2015-06510                 #
#               Inclusao da chamada do "Cad Valores Prestador por Cidade",    #
#               "Cad Tipos de Justificativa" e "Grupo de SKU".                #
#-----------------------------------------------------------------------------#
# 10/jun/2015 - Marcos Souza(BizTalking)- SPR-2015-17043 - Cadastro Campanha  #
#               de Desconto                                                   #
#               - Retirada do menu do "Cadastro Cupom Desconto e inclusao da  #
#               opcao "Campanha Descontos"                                    #
#-----------------------------------------------------------------------------#
# 05/out/2015 - Marcos Souza(BizTalking)- SPR-2015-19757-Cadastro de Valores  #
#               Adicionais Prestador                                          #
#               - Inclusao no menu da opcao "Cadastro de Grupo de Cidades     #
#-----------------------------------------------------------------------------#
# 18/04/2016 - Marcos Souza(InforSystem)- SPR-2016-03565 - Vendas e Parcerias.#
#              - Cadastro de Progama de Pontos                                #
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
   let w_log = w_log clipped,"/dat_ctg26.log"

   call startlog(w_log)

   select sitename into g_hostname from dual

   let g_hostname = g_hostname[1,3]

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last - 1,
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
           "-------ctg26---" at 03,01

   call ctg26_menu()

   close window WIN_MENU
   close window WIN_CAB

end main

#=====================
 function ctg26_menu()
#=====================

 let int_flag = false

 menu "CADASTROS:"

    before menu
         show option "AssuntoxRamo"
	       show option "Encerra"

    command key ("A") "AssuntoxRamo" "Cadastro de parametros para contabilizacao da empresa 43-Servicos Avulsos"
         call ctc99m01()

    command key ("S") "cad_Sku" "Cadastro de SKU (opsfa001)"
         call opsfa001()  #=> SPR-2014-28503 - Inclusao de chamada

    command key ("G") "Grupo_sku" "Cadastro de Grupos de SKU (opsfa022)"
         call opsfa022()  #=> SPR-2015-06510

#--- SPR-2015-17043 - Cadastro Campanha de Desconto
#   command key ("C") "Cupom_Desconto" "Cadastro de Cupom de Desconto de Servicos (opsfa002)"
#        call opsfa002()  #--- SPR-2014-28503 - Inclusao de chamada
#
    command key ("P") "Perfil_cliente" "Cadastro de Perfis de Clientes (opsfa012)"
        call opsfa012()   #--- SPR-2014-28503 - Inclusao de chamada

    command key ("F") "descricao_Fiscal" "Cadastro de Descricao Fiscal (opsfa013)"
         call opsfa013()  #--- SPR-2014-28503 - Inclusao de chamada

    command key ("T") "Tipo_Justificava" "Cad Tipos de Justificativa (opsfa017)"
         call opsfa017()  #=> SPR-2015-06510

    command key ("V") "Val_prest_cid" "Valores Prestador por Cidade (opsfa019)"
         call opsfa019()  #=> SPR-2015-06510

   command key ("H") "campanHa" "Cadastro de Campanha de Descontos (opsfa036)"
        call opsfa036()  #=> SPR-2015-17043 - Cadastro Campanha de Desconto

   command key ("C") "grupo_Cidades" "Cadastro de Grupo de Cidades (opsfa037)"
        call opsfa037()  #=> SPR-2015-19757-Cadastro Valores Adicionais Prestador

   command key ("R") "pRograma_pontos" "Cadastro de Programa de Pontos" 
      call opsfa046()    #- SPR-2016-03565 - Vendas e Parcerias.

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
