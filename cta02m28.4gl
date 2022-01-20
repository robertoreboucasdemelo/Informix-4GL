#---------------------------------------------------------------------    #
# Porto Seguro Cia Seguros Gerais                                         #
# ....................................................................    #
# Sistema       : Central 24h                                             #
# Modulo        : cta02m28                                                #
# Analista Resp.: Alberto Rodrigues                                       #
# PSI           :                                                         #
# Objetivo      : Exibir valores e qtde de servicos pagos                 #
#.....................................................................    #
# Desenvolvimento: Amilton , META                                         #
# Liberacao      :                                                        #
#.....................................................................    #
#                                                                         #
#                  * * * Alteracoes * * *                                 #
#                                                                         #
# Data        Autor Fabrica  Origem    Alteracao                          #
# ----------  -------------- --------- ------------------------------     #
#-------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"


function cta02m28(lr_param)
    define lr_param     record
           qtde   integer,
           vlr    integer
    end record
    define l_cabec     char(60)
           ,prompt_key char (01)
    initialize l_cabec to null
    let l_cabec = null
    let prompt_key = null
   # Abre a tela
    open window w_cta02m28 at 09,20 with form "cta02m28"
              attribute(form line 1, border)
    #message "           (F1)Tela de Extrato          (F8)Seleciona"
    let l_cabec = "Suc: " , g_documento.succod    using "<<<&&",
                  " Ramo: ", g_documento.ramcod    using "&&&&",
                  " Apl.: ", g_documento.aplnumdig using "<<<<<<<<#"
    display l_cabec to cabec attribute(reverse)

    display by name lr_param.qtde
    display by name lr_param.vlr
   while true
       prompt " (F17)Abandona" attribute(reverse) for prompt_key
       on key (interrupt,control-c,f17)
          exit while
       end prompt
   end while
   close window  w_cta02m28
   let int_flag = false
   return
end function
