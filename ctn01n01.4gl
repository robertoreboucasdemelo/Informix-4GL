#############################################################################
# Nome do Modulo: CTN01N01                                         WAGNER   #
#                                                                           #
# Menu de Consulta de Prestadores SEM MAPA                         OUT/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 17/10/2000  ERRO         Wagner       TELA CONTABILIDADE CAINDO FOI       #
#                                       NECESSARIO GERAR OUTRA VERSAO PROG. #
#############################################################################

database porto

#--------------------------------------------------------------------------
 function ctn01n01(par)
#--------------------------------------------------------------------------
define par         record
  ufdcod           like glakcid.ufdcod,
  cidnom           like glakcid.cidnom,
  brrnom           like glakbrr.brrnom,
  lgdnom           like glaklgd.lgdnom,
  atdsrvnum        like datmservico.atdsrvnum,
  atdsrvano        like datmservico.atdsrvano
end record

define k_ctn01n01  record
       endcep      like glaklgd.lgdcep,
       endcepcmp   like glaklgd.lgdcepcmp
end    record

define d_ctn01n01  record
       pstcoddig   like dpaksocor.pstcoddig
end    record


   let int_flag = false

   open window w_ctn01n01 at 4,2 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctn01n01--" at 3,1

   menu "PRESTADORES"
     command key ("N") "Nome"
                 "Consulta prestadores por NOME DE GUERRA ou RAZAO SOCIAL"
          call ctn24c00()  returning d_ctn01n01.pstcoddig
          exit menu

     command key ("C") "Cep"
                 "Consulta prestadores por CEP"
          call ctn00c02 (par.ufdcod, par.cidnom, par.brrnom, par.lgdnom)
               returning k_ctn01n01.endcep, k_ctn01n01.endcepcmp

          if k_ctn01n01.endcep is null     then
             error "Nenhum criterio foi selecionado!"
          else
             call ctn06c04(k_ctn01n01.endcep) returning d_ctn01n01.pstcoddig
          end if
          exit menu

     command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
       exit menu

     clear screen
   end menu

   let int_flag = false
   close window w_ctn01n01
   return  d_ctn01n01.pstcoddig

end function  # ctn01n01
