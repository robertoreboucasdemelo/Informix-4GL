#############################################################################
# Nome do Modulo: CTB12N00                                         Gilberto #
#                                                                   Marcelo #
# Menu de consultas - Pagamentos Porto Socorro                     Fev/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 20/12/1999  PSI 9805-1   Gilberto     Incluir opcao de consulta por si-   #
#                                       tuacao diaria dos pagamentos.       #
#---------------------------------------------------------------------------#
# 27/03/2001  Psi 12768-0  Wagner       Incluir na chamada do modulo        #
#                                       ctb12m03 dois campos nulo  srv/ano  #
#############################################################################
#                       * * * Alteracoes * * *                              #
#                                                                           #
# Data       Autor Fabrica      Origem     Alteracao                        #
# ---------- -----------------  ---------- ---------------------------------#
# 15/03/2005 Robson Carmo,Meta  PSI188751  Incluir a opcao para a chamada   #
#                                          "servicos_Ris"                   #
#---------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------------------
 function ctb12n00()
#-------------------------------------------------------------------------

 define ws       record
    pstcoddig    like dpaksocor.pstcoddig,
    pestip       like dpaksocor.pestip,
    cgccpfnum    like dpaksocor.cgccpfnum,
    cgcord       like dpaksocor.cgcord,
    cgccpfdig    like dpaksocor.cgccpfdig
 end record

 let int_flag = false

 open window w_ctb12n00 at 04,02 with 20 rows,78 columns

 display "---------------------------------------------------------------",
         "-----ctb12n00--" at 3,1

 menu "CONSULTAS"

    before menu
    hide option all

    show option "Servico",
                "por_Data",
                "por_Numero",
                "por_sitUacao",
                "Prestador",
                "servicos_Ris",
                "Encerra"

    if ((g_issk.dptsgl     =  "desenv")  or
        (g_issk.acsnivcod  >= 6))        then
       show option "disTribuicao"
    end if

    command key ("S") "Servico"
                      "Consulta e acerta valor do servico"
       call ctb12m03("","")

    command key ("D") "por_Data"
                      "Consulta O.P. por data de entrega/pagamento, prestador"
       call ctb12m00()

    command key ("U") "por_sitUacao"
                      "Consulta situacao diaria de pagamentos"
       call ctb12m11()

    command key ("N") "por_Numero"
                      "Consulta O.P. por numero ou por ordem de servico"
       call ctb12m01("")

    command key ("T") "disTribuicao"
                      "Servicos de Sinistro, P.Socorro, DAF, Ass.Passag, Replace por prestador"
       call ctb12m09()

    command key ("P") "Prestador"
                      "Pesquisa por Nome Guerra, Razao, Cgc/Cpf, O.S."
       call ctb12m02("")  returning  ws.pstcoddig,
                                     ws.pestip,
                                     ws.cgccpfnum,
                                     ws.cgcord,
                                     ws.cgccpfdig
                                     
    command key ("R") "servicos_Ris"
                      "Consulta servicos com laudo RIS"
       call ctb28m00()

    command key (interrupt,E) "Encerra"
                      "Retorna ao menu anterior"
       exit menu
 end menu

 close window w_ctb12n00
 let int_flag = false

end function  ###  ctb12n00
