#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: CTB31N00                                                   #
# ANALISTA RESP..: CELSO YAMAHAKI                                             #
# PSI/OSF........:                                                            #
#                                                                             #
# ........................................................................... #
# DESENVOLVIMENTO: CELSO YAMAHAKI                                             #
# LIBERACAO......:   /  /                                                     #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
# 28/10/14   Franzon, Biz    PSI        Incluir relatorio carro extra itau    #
# 30/10/14   Franzon, Biz    PSI        Incluir relatorio servico sem dcto    #
# 30/10;14   Franzon, Biz.   PSI        Incluir realtorio telefone            #
#-----------------------------------------------------------------------------#
database porto
globals "/homedsa/projetos/geral/globals/glct.4gl"


#--------------------------------------------------------------------------
 function ctb31n00()
#--------------------------------------------------------------------------

   let int_flag = false

   if ctb31n00_validaMat() then

   open window w_ctb31n00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctb31n00--" at 03,01

   menu "RELATORIOS"

      command key ("I") "Ire" "Ligacoes IRE"
        call ctb31m00("IRE")

      command key ("A") "Agenda" "Extração de Entradas da Agenda"
        call ctb31m00("Agenda")

      command key ("S") "ServicosSAPS" "Servicos SAPS"
         call ctb31m00("SAPS")

      command key ("M") "sMs" "Envio de SMS"
         call ctb31m00("SMS")

      command key ("T") "Etapas" "Etapas de Acionamento"
         call ctb31m00("Etapa")

      command key ("N") "NotasFiscais"
                        "Servicos pagos com Notas Fiscais Emp 43"
        call ctb31m00("NF")

      command key ("C") "CidSede"
                        "Lista de Cidades Sede"
        call ctb31m00("CidSed")

      command key ("R") "Retorno"
                        "Servicos de Retorno"
        call ctb31m00("Retor")
      
      command key ("H") "HoraComb"
                        "Hora Combinada com Cliente"
        call ctb31m00("HorCom")
#Pas - central inicio
      command key ("X") "cX_itau_pg"
                        "Carro Extra Itau Pagos"    
        call ctb31m00("cX_ita")

      command key ("O") "sem_dOcumento"
                        "Servicos Sem Documento"    
        call ctb31m00("sem_dO")

      command key ("F") "teleFone"
                        "TeleFone"    
        call ctb31m00("tele")
#Pas - central fim
      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctb31n00

   else
      error "Usuario Sem Permissao de Acesso"

   end if
   let int_flag = false

end function   #---- ctb31n00

#--------------------------------------------------------------------------
 function ctb31n00_validaMat()
#--------------------------------------------------------------------------

   if g_issk.empcod = 01 then

      if g_issk.funmat = 8782  or
         g_issk.funmat = 2399  or
         g_issk.funmat = 9179  or
         g_issk.funmat = 11533 or
         g_issk.funmat = 2988  or
         g_issk.funmat = 12408 or
         g_issk.funmat = 3484  or
         g_issk.funmat = 18366 or
         g_issk.funmat = 5985  or
         g_issk.funmat = 17909 or
         g_issk.funmat = 17870 or
         g_issk.funmat = 14845 then
         
         return true
      else
         return false
      end if

   else

      return false
   end if


end function
