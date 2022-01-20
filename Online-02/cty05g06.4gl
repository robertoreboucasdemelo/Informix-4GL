################################################################################
# Porto Seguro Cia Seguros Gerais                                      Nov/2010#
# .............................................................................#
# Sistema       : Central 24h                                                  #
# Modulo        : cty05g06                                                     #
# Analista Resp.: Carla Rampazzo                                               #
# PSI           :                                                              #
# Objetivo      : Obter Limites/Utilizacoes do Help Desk                       #
# .............................................................................#
#                                                                              #
#                  * * * Alteracoes * * *                                      #
#                                                                              #
# Data        Autor Fabrica  Origem    Alteracao                               #
# ----------  -------------- --------- ----------------------------------------#
#                                                                              #
################################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define m_viginc    like abbmdoc.viginc

#---------------------------------------
--> Controles de Atendimento - Help Desk
#---------------------------------------
define m_hdk      record
       qtd_lmt    smallint              --> Limite Total (Auto/RE)
      ,qtd_utz    smallint              --> Quantidade Utilizada (Auto/RE)
      ,qtd_lmt_206    smallint              --> Limite Total Conecitividade
      ,qtd_utz_206    smallint              --> Quantidade Utilizada Conect
      ,sld_re     char(01) --"S"im/"N"ao--> Se tem saldo (RE com LMI)
      ,usa_re     char(01) --"S"im/"N"ao--> Se Re Contratou Servico (RE com LMI)
end record

define m_param         record
       ramcod          smallint
      ,succod          like abbmitem.succod
      ,aplnumdig       like abbmitem.aplnumdig
      ,itmnumdig       like abbmitem.itmnumdig
      ,c24astcod       like datmligacao.c24astcod
end record

define m_c24astcod     like datmligacao.c24astcod
define m_flg_HDK       smallint

define m_ret           record
       codigo          smallint --> = 0 - OK / <> 0 - Erro
      ,mensagem        char(80)
end record

#-----------------------------------------------------------------------------
function cty05g06_limite_hdk(lr_param,l_viginc,l_flg_HDK)
#-----------------------------------------------------------------------------

   define lr_param    record
          ramcod          smallint
         ,succod          like abbmitem.succod
         ,aplnumdig       like abbmitem.aplnumdig
         ,itmnumdig       like abbmitem.itmnumdig
         ,c24astcod       like datmligacao.c24astcod
   end record
   define l_viginc    like abbmdoc.viginc
   define l_flg_HDK   smallint

   let m_viginc = l_viginc
   let m_flg_HDK = l_flg_HDK
   initialize m_hdk.*, m_ret.*, m_param.* to null

   let m_param.*    = lr_param.*
   let m_ret.codigo = 0


   #-------------------------------
   --> Chama Controle conforme Ramo
   #-------------------------------
   if lr_param.ramcod = 531 then

      #------------------------------
      --> Controle de Limites p/ Auto
      #------------------------------
      call cty05g06_hdk_auto()

   else
      let m_c24astcod = lr_param.c24astcod

      #----------------------------
      --> Controle de Limites p/ RE
      #----------------------------
      call cts12g99_verifica_saldo(lr_param.succod
                                  ,lr_param.ramcod
                                  ,lr_param.aplnumdig
                                  ,g_documento.prporg
                                  ,g_documento.prpnumdig
                                  ,g_documento.lclnumseq
                                  ,g_documento.rmerscseq
                                  ,lr_param.c24astcod)
           returning m_ret.*

      let m_hdk.qtd_lmt = g_hdk.qtd_lmt
      let m_hdk.qtd_utz = g_hdk.qtd_utz
      let m_hdk.sld_re  = g_hdk.sld_re
      let m_hdk.usa_re  = g_hdk.usa_re
   end if

   return m_hdk.*, m_ret.*

end function


#-----------------------------------------------------------------------------
function cty05g06_hdk_auto()
#-----------------------------------------------------------------------------

   define l_data_calculo      date
   define l_clscod_doc        char(03)
   define l_clscod_hdk        char(03)
   define l_flag_endosso      char(01)
   define l_qtde_at           integer
   define l_nulo              char (1)
   define l_prporgpcp         like abamdoc.prporgpcp
   define l_prpnumpcp         like abamdoc.prpnumpcp
   define l_prporg            like datrligprp.prporg
   define l_prpnumdig         like datrligprp.prpnumdig
   define l_sql               char(500)
   define l_cponom            like datkdominio.cponom
   define l_cpodes            like datkdominio.cpodes
   define l_codigo            smallint
   define l_mensagem          char(80)
   define l_qtd_limite  integer
	 ,l_saldo       integer
	 ,l_flag_limite char(01)
	 ,l_clscod4448  smallint

   let l_data_calculo    = null
   let l_clscod_doc      = null
   let l_clscod_hdk      = null
   let l_flag_endosso    = null
   let l_qtde_at         = null
   let l_nulo            = null
   let l_prporgpcp       = null
   let l_prpnumpcp       = null
   let l_prporg          = null
   let l_prpnumdig       = null
   let l_sql             = null
   let l_cpodes          = null
   let l_cponom          = null
   let l_codigo          = null
   let l_mensagem        = null

   let m_hdk.qtd_utz = 0
   let l_flag_limite = "N"
   let l_saldo = 0
   let l_clscod4448 = false

   #----------------------------------------------
   --> Buscar Clausulas Cadastradas para Help Desk
   #----------------------------------------------
   let l_sql = " select cpodes "
                ," from datkdominio "
                ," where cponom = ? "
   prepare p_cty05g06001 from l_sql
   declare c_cty05g06001 cursor for p_cty05g06001




   #-----------------------
   --> Obter Clausula Docto
   #-----------------------
   call faemc144_clausula(m_param.succod
                         ,m_param.aplnumdig
                         ,m_param.itmnumdig)
        returning l_codigo
                 ,l_clscod_doc
                 ,l_data_calculo
                 ,l_flag_endosso

   if l_codigo <> 0 or l_clscod_doc is null then
			 call cty26g00_srv_caca(531, m_param.succod    ##fornax set/12
			                            ,m_param.aplnumdig
			                            ,m_param.itmnumdig
			                            ,m_param.c24astcod,"","","",999)
	     returning l_flag_limite, l_saldo, m_hdk.qtd_lmt, m_hdk.qtd_utz, l_clscod4448

       if m_hdk.qtd_lmt is null or m_hdk.qtd_lmt = 999 then
          let m_ret.codigo   = 0
          let m_ret.mensagem = " Apolice sem clausula para Help Desk " sleep 3
          return
       end if
       let m_hdk.qtd_lmt_206 = null
	     let m_hdk.qtd_utz_206 = null
       if m_param.c24astcod = "S67" then
	       #Buscar o limite da conectividade (206)
	       call cty26g00_srv_caca(531, m_param.succod    ##fornax set/12
			                             ,m_param.aplnumdig
			                             ,m_param.itmnumdig
			                             ,m_param.c24astcod,"","",206,999)
	         returning l_flag_limite, l_saldo, m_hdk.qtd_lmt_206, m_hdk.qtd_utz_206, l_clscod4448
       end if
   end if
   if l_clscod4448 = true then
      return
   end if

   #-----------------------------------------------------------
   --> Padroniza Clausula para pesquisa em Dominio do Help Desk
   #-----------------------------------------------------------
   if l_clscod_doc =  ""   or
      l_clscod_doc is null then
      let l_clscod_doc = "000"
   end if

   if l_clscod_doc = "33" then
      let l_clscod_doc = "033"
   end if

   if l_clscod_doc = "34" then
      let l_clscod_doc = "034"
   end if

   if l_clscod_doc = "35" then
      let l_clscod_doc = "035"
   end if

   if l_clscod_doc = "46" then
      let l_clscod_doc = "046"
   end if
   let l_cponom = "limite_hdk"


   if cty31g00_nova_regra_clausula(m_param.c24astcod) then

        if cty31g00_nova_regra_corte1() then

        	  #-----------------------------------------------------------------------------
        	  # Verifica Novas Regras de Limite Por Clausula Data de Corte Abril 2014
        	  #-----------------------------------------------------------------------------
            let l_cponom = "limite_hdk_corte1"
        else
             if cty31g00_nova_regra_corte3() then
                 #-----------------------------------------------------------------------------
                 # Verifica Novas Regras de Limite Por Clausula Data de Corte Setembro 2014
                 #-----------------------------------------------------------------------------
                 let l_cponom = "limite_hdk_corte3"
             else
        	       #-----------------------------------------------------------------------------
        	       # Verifica Novas Regras de Limite Por Clausula Data de Corte Fevereiro 2014
        	       #-----------------------------------------------------------------------------
        	       let l_cponom = "limite_hdk_corte0"
        	   end if
        end if
   else
       if cty34g00_valida_clausula(l_clscod_doc) then
          #---------------------------------------------------------------------------------------
          # Verifica Novas Regras de Limite Por Clausula Data de Corte Fevereiro 2014
          #---------------------------------------------------------------------------------------
          let l_cponom = "limite_hdk_corte0"
       else
       	  #---------------------------------------------------------------------------------------
       	  # Verifica Novas Regras de Limite Por Clausula Anterior a Data de Corte Fevereiro 2014
       	  #---------------------------------------------------------------------------------------
       	  let l_cponom = "limite_hdk"
       end if
   end if
   open c_cty05g06001 using l_cponom
   foreach c_cty05g06001 into l_cpodes

      let l_clscod_hdk = l_cpodes[10,12]
      if l_clscod_hdk <> l_clscod_doc then
         continue foreach
      else
         #----------------------------------------------------------------
         --> Obter os Limites de Visita / Telefonico da Clausula - Dominio
         #----------------------------------------------------------------
         if l_cpodes[48,50] is not null and
            l_cpodes[48,50] <> ' '      then
            let m_hdk.qtd_lmt = l_cpodes[48,50] #limite unico

         else
            if m_param.c24astcod = "S66" then

               let m_hdk.qtd_lmt = l_cpodes[31,33] #telefonico
            else

               let m_hdk.qtd_lmt = l_cpodes[22,24] #visita
            end if
         end if

      end if
   end foreach


   if m_hdk.qtd_lmt is null then
      let m_ret.codigo   = 0
      let m_ret.mensagem = " Apolice sem clausula para Help Desk " sleep 3
      return
   end if

   #--------------------------------------------------
   --> Obter a Quantidade de atendimentos de Help Desk
   #--------------------------------------------------
   let l_qtde_at = cta02m15_qtd_serv_residencia(m_param.ramcod
                                               ,m_param.succod
                                               ,m_param.aplnumdig
                                               ,m_param.itmnumdig
                                               ,"",""
                                               ,l_data_calculo
                                               ,m_param.c24astcod
                                               ,"")  --> bnfnum
   if l_qtde_at is null then
      let l_qtde_at = 0
   end if

   #-----------------------------------------------
   --> Obter as Utilizacoes de Visita ou Telefonico
   #-----------------------------------------------
   let m_hdk.qtd_utz = m_hdk.qtd_utz + l_qtde_at

   #------------------------------------------------------------------
   --> Se nao tem endosso, contar os servicos realizados pela proposta
   #------------------------------------------------------------------
   if l_flag_endosso = "N" then

      #---------------------------------------------
      --> Obter proposta original atraves da apolice
      #---------------------------------------------
      call cty05g00_prp_apolice(m_param.succod
                               ,m_param.aplnumdig
                               ,0)
                     returning l_codigo
                              ,l_mensagem
                              ,l_prporgpcp
                              ,l_prpnumpcp

      if l_codigo <> 1 then
         let m_ret.codigo   =  1
         let m_ret.mensagem =  l_mensagem
         return
      end if


      let l_qtde_at = 0

      #--------------------------------------------------
      --> Obter a Quantidade de atendimentos de Help Desk
      #--------------------------------------------------
      let l_qtde_at = cta02m15_qtd_serv_residencia(""
                                                  ,""
                                                  ,""
                                                  ,""
                                                  ,l_prporgpcp
                                                  ,l_prpnumpcp
                                                  ,l_data_calculo
                                                  ,m_param.c24astcod
                                                  ,"")

      if l_qtde_at is null then
         let l_qtde_at = 0
      end if

      #----------------------------------------------
      --> Obter as Utilizacoes de Visita e Telefonico
      #----------------------------------------------
      let m_hdk.qtd_utz = m_hdk.qtd_utz + l_qtde_at

   end if

   return

end function
