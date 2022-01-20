##########################################################################
# Nome do Modulo: CTN09C02                                         Pedro #
#                                                                        #
# Menu de Consulta de Corretores                                         #
##########################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

function ctn09c02()

   define k_ctn09c02  record
          endcep      like glaklgd.lgdcep,
          endcepcmp   like glaklgd.lgdcepcmp
   end    record




	initialize  k_ctn09c02.*  to  null

   let int_flag = false

   open window w_ctn09c02 at 4,2 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctn09c02--" at 3,1

   menu "CORRETORES"
      command key ("S") "Susep"        "Consulta Corretores por SUSEP/NOME"
           call ctn09c00("")

      command key ("C") "Cep"          "Consulta Corretores por CEP"
           message ""
           call  ctn00c02 ("SP","SAO PAULO"," "," ")
                 returning k_ctn09c02.endcep, k_ctn09c02.endcepcmp

           if k_ctn09c02.endcep is null     then
              error "Nenhum logradouro foi selecionado!"
              next option "Encerra"
           else
              call ctn09c01(k_ctn09c02.endcep)
           end if

      command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
        exit menu

      clear screen
   end menu

   let int_flag = false
   close window w_ctn09c02

end function  # ctn09c02
