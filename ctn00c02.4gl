#############################################################################
# Nome do Modulo: CTN00C02                                            Pedro #
#                                                                           #
# Menu para Localizacao (CONSULTAS)                                Nov/1994 #
#############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------
function ctn00c02(par)
#-------------------------------------
define par         record
  ufdcod           like glakcid.ufdcod,
  cidnom           like glakcid.cidnom,
  brrnom           like glakbrr.brrnom,
  lgdnom           like glaklgd.lgdnom
end record

define k_ctn00c02  record
  endcep           like glaklgd.lgdcep,
  endcepcmp        like glaklgd.lgdcepcmp
end record




	initialize  k_ctn00c02.*  to  null

   let int_flag = false

   open window w_ctn00c02 at 4,2 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctn00c02--" at 3,1

   menu "LOCALIZACAO"

   command key ("C") "Cidade"    "Pesquisa por Cidade"
           call ctn11c03(par.cidnom) returning k_ctn00c02.endcep

           if k_ctn00c02.endcep is null or
              k_ctn00c02.endcep =  " " then
              error "Nenhum CEP foi selecionado!"
              next option "Cidade"
           else
              exit menu
           end if

   command key ("B") "Bairro" "Mostra a Rua de Menor Cep do Bairro"
	   call ctn11c04(par.ufdcod, par.cidnom, par.brrnom)
                returning k_ctn00c02.endcep

           if k_ctn00c02.endcep is null or
              k_ctn00c02.endcep =  " " then
              error "Nenhum CEP foi selecionado!"
              next option "Bairro"
           else
              exit menu
           end if

   command key ("L") "Logradouro" "Pesquisa por Logradouro"
	   call ctn11c02(par.ufdcod, par.cidnom, par.lgdnom)
                returning k_ctn00c02.endcep, k_ctn00c02.endcepcmp

           if k_ctn00c02.endcep is null or
              k_ctn00c02.endcep =  " " then
              error "Nenhum CEP foi selecionado!"
              next option "Logradouro"
           else
              exit menu
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window w_ctn00c02
   return  k_ctn00c02.endcep, k_ctn00c02.endcepcmp

end function # ctn00c02
