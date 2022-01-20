###########################################################################
# Nome do Modulo: CTN11C00                                          Pedro #
#                                                                         #
# Menu de Consultas do Guia Postal.                              Set/1994 #
###########################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

function ctn11c00()

   define f_cep    like glakcid.cidcep,
          f_cepcmp like glakcid.cidcepcmp


	let	f_cep  =  null
	let	f_cepcmp  =  null

   let int_flag = false

   open window w_ctn11c00 at 4,2 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctn11c00--" at 3,1

   menu "GUIA POSTAL"
      command key ("C")         "Cep"        "Consulta por CEP"
        call ctn11c01("","","s")  returning f_cep

      command key ("L")         "Logradouro" "Consulta por logradouro"
        call ctn11c02("SP","SAO PAULO"," ")  returning f_cep, f_cepcmp

      command key ("I")         "cIdade"     "Consulta por cidade"
        call ctn11c03(" ")  returning f_cep

      command key ("B")         "Bairro" "Mostra as Ruas de Menor cep do Bairro"
        call ctn11c04("SP","SAO PAULO"," ")  returning f_cep

      command key (interrupt,E) "Encerra"    "Retorna ao menu anterior"
        exit menu
   end menu

   let int_flag = false
   close window w_ctn11c00

end function  #-- ctn11c00
