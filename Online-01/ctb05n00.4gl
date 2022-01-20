#############################################################################
# Nome do Modulo: CTB05N00                                         Wagner   #
#                                                                           #
# Menu de consultas - Pagamentos Ramos Elementares RE              Nov/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################


 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------------------
 function ctb05n00()
#-------------------------------------------------------------------------

 define ws       record
    pstcoddig    like dpaksocor.pstcoddig,
    pestip       like dpaksocor.pestip,
    cgccpfnum    like dpaksocor.cgccpfnum,
    cgcord       like dpaksocor.cgcord,
    cgccpfdig    like dpaksocor.cgccpfdig
 end record

 let int_flag = false

 open window w_ctb05n00 at 04,02 with 20 rows,78 columns

 display "---------------------------------------------------------------",
         "-----ctb05n00--" at 3,1

 menu "CONSULTAS"

    before menu
    hide option all

    show option "Servico",
                "por_Data",
                "por_Numero",
                "por_sitUacao",
                "disTribuicao",
                "Encerra"

    command key ("S") "Servico"
                      "Consulta por numero do servico"
       call ctb05m00("","")

    command key ("D") "por_Data"
                      "Consulta O.P. por data de entrega/pagamento"
       call ctb05m01()

    command key ("N") "por_Numero"
                      "Consulta O.P. por numero ou por ordem de servico"
       call ctb05m02("")

    command key ("U") "por_sitUacao"
                      "Consulta situacao diaria de pagamentos"
       call ctb05m03()

    command key ("T") "disTribuicao"
                      "Servicos de Reserva de veiculos "
       call ctb05m04()

    command key (interrupt,E) "Encerra"
                      "Retorna ao menu anterior"
       exit menu
 end menu

 close window w_ctb05n00
 let int_flag = false

end function  ###  ctb05n00
