#############################################################################
# Nome do Modulo: ctn49c00                                             RAJI #
#                                                                           #
# Menu do Auto Ct24h para espelho da apolice                       Jul/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA       RESPONSAVEL       DESCRICAO                                    #
#---------------------------------------------------------------------------#
# 21/07/2008 Carla Rampazzo    Nao mostrar error/display/abrir tela qdo for #
#                              chamado pelo Portal do Segurado              #
#---------------------------------------------------------------------------#
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------------
function ctn49c00()
#----------------------------------------------------------------------

   define w_data    date
   define w_ret     integer


   let w_data  =  null
   let w_ret   =  null

   ---> Chamado pelo Informix - tela
   if g_origem is null or
      g_origem = "IFX"   then

      open window ctn49c00_cab at 2,2 with 22 rows,78 columns
      attribute (border)
      let w_data = today

      display "CENTRAL 24 HS" at 01,01
      display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
      display w_data       at 01,69

      open window ctn49c00_menu at 04,02 with 20 rows, 78 columns

      call p_reg_logo_ctn49c00()

      display "---------------------------------------------------------------",
              "-----ctn49c00--" at 03,01

      menu "OPCOES"

      before menu
         hide option all

         call acess_prog("Auto_ct24h", "apeds")  returning w_ret
         if w_ret  <>  -1   then
            show option "Apol/Eds"
         end if

         call acess_prog("Auto_ct24h", "sma")  returning w_ret
         if w_ret  <>  -1   then
            show option "aVs_sinis"
         end if

         call acess_prog("Auto_ct24h", "sct")  returning w_ret
         if w_ret  <>  -1   then
            show option "Lig_sinis"
         end if

         call acess_prog("Auto_ct24h", "ars")  returning w_ret
         if w_ret  <>  -1   then
            show option "RS"
         end if

         call acess_prog("Auto_ct24h", "abs")  returning w_ret
         if w_ret  <>  -1   then
            show option "Consulta"
         end if

         show option "Encerra"

         command key ("A") "Apol/Eds"
                           "Emissao de apolice e endosso - automovel"
            initialize w_ret           to null

            call chama_prog("Auto_ct24h","apeds","") returning w_ret

            if w_ret = -1  then
               error " Sistema nao disponivel no momento!"
            end if

         command key ("V") "aVs_sinis"
                           "Marcacao de aviso de sinistro"
            initialize w_ret           to null

            call chama_prog("Auto_ct24h","sma","") returning w_ret

            if w_ret = -1  then
               error " Sistema nao disponivel no momento!"
            end if

         command key ("L") "Lig_sinis"
                           "Atendimento telefonico do sinistro"

            initialize w_ret           to null

            call chama_prog("Auto_ct24h", "sct", "")  returning w_ret

            if w_ret = -1  then
               error " Sistema nao disponivel no momento!"
            end if

         command key ("R") "RS"
                           "Condicoes para Renovacao Simplificada"
            initialize w_ret           to null

            call chama_prog("Auto_ct24h","ars","") returning w_ret

            if w_ret = -1  then
               error " Sistema nao disponivel no momento!"
            end if

         command key ("C") "Consulta"
                           "Consultas a Documentos Emitidos"
            initialize w_ret           to null

            call chama_prog("Auto_ct24h","abs","") returning w_ret

            if w_ret = -1  then
               error " Sistema nao disponivel no momento!"
            end if

         command key (interrupt,E) "Encerra" "Fim de servico"
            exit menu

      end menu

      close window ctn49c00_cab
      close window ctn49c00_menu
   end if

end function

#----------------------------------------------------------
function p_reg_logo_ctn49c00()
#----------------------------------------------------------

   define ba char(01)

   let ba  =  null

   open form reg from "apelogo2"
   display form reg
   let ba = ascii(92)
   display ba at 15,23
   display ba at 14,22
   display "PORTO SEGURO" AT 16,52
   display "                                  Seguros" at 17,23
   attribute (reverse)
end function
