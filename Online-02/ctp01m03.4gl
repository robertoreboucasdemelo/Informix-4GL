###############################################################################
# Nome do Modulo: CTP01m03                                              Pedro #
#                                                                     Marcelo #
# Menu de Historico da Pesquisa                                      Mar/1995 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 04/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
###############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------
function ctp01m03(k_ctp01m03)
#-------------------------------------

   define k_ctp01m03  record
     atdsrvnum  like  datmservico.atdsrvnum,
     atdsrvano  like  datmservico.atdsrvano,
     funmat     like  datmservico.funmat,
     data       like  datmservico.atddat,
     hora       like  datmservico.atdhor
   end record

   define ws_atdsrvorg  like  datmservico.atdsrvorg
   define ws_servico    char(13)


   open window w_ctp01m03 at 4,2 with form "ctp01m03"

   select atdsrvorg
     into ws_atdsrvorg
     from datmservico
    where atdsrvnum = k_ctp01m03.atdsrvnum
      and atdsrvano = k_ctp01m03.atdsrvano

   let ws_servico =  ws_atdsrvorg         using "&&", " ",
                     k_ctp01m03.atdsrvnum using "&&&&&&&", "-",
                     k_ctp01m03.atdsrvano using "&&"
   display ws_servico  to  servico

   let int_flag = false

   menu "HISTORICO"
      command key ("I")      "Implementa"
                             "Implementa dados no historico da pesquisa"
        call ctp01m04(k_ctp01m03.*)
        clear form
        display ws_servico  to  servico
        next option "Encerra"

      command key ("C")      "Consulta"
                             "Consulta historico ja' cadastrado p/ pesquisa"
        call ctp01m05(k_ctp01m03.atdsrvnum, k_ctp01m03.atdsrvano)
        clear form
        display ws_servico  to  servico
        next option "Encerra"

      command key (interrupt,E)   "Encerra"    "Retorna ao menu anterior"
        exit menu
   end menu

   let int_flag = false

   close window w_ctp01m03

end function # ctp01m03
