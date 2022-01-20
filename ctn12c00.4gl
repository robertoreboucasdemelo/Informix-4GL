############################################################################
# Nome do Modulo: CTN12C00                                                 #
#                                                                          #
# Consulta Cadastro de Moedas                                     Set/1994 #
############################################################################

#---------------------------------------------------------------
# Modulo de manutencao em array na tabela gfatmda
# Gerado por: porto em: 20/01/93
#---------------------------------------------------------------

database porto

#---------------------------------------------------------------
function ctn12c00()
#---------------------------------------------------------------
#
  open window w_ctn12c00 at 4,2 with form "ctn12c00"

   menu "COTACOES"
        command key ("S") "Seleciona"  "Seleciona cotacoes"
              call ctn12c00_sel()

        command key (interrupt,E) "Encerra"  "Retorna ao menu anterior"
             exit menu
   end menu

  close window w_ctn12c00

end function

#---------------------------------------------------------------
function ctn12c00_sel()
#---------------------------------------------------------------
#
   define f_ctn12c00 record
      mdacotdat like gfatmda.mdacotdat
   end record

   define arr_aux integer
   define scr_aux integer

   define a_ctn12c00 array[50] of record
      mdacod    like gfatmda.mdacod,
      mdanom    like gfakmda.mdanom,
      mdatipnom CHAR(9),
      mdacotvlr like gfatmda.mdacotvlr
   end record

   define aux record
      alterado  integer,
      mdatip    like gfakmda.mdatip,
      mdacotvlr like gfatmda.mdacotvlr
   end record

   define r_gfakmda record like gfakmda.*


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn12c00[w_pf1].*  to  null
	end	for

	initialize  f_ctn12c00.*  to  null

	initialize  aux.*  to  null

	initialize  r_gfakmda.*  to  null

   let int_flag = false

   input by name f_ctn12c00.*
      after field mdacotdat

         if f_ctn12c00.mdacotdat is null then
            error "Informe a data da cotacao!"
            next field mdacotdat
         end if
   end input

   while not int_flag
      declare c_ctn12c00 cursor for
         select
            gfatmda.mdacod,
            gfakmda.mdanom,
            gfakmda.mdatip,
            gfatmda.mdacotvlr
         from gfatmda,gfakmda
         where
            gfatmda.mdacotdat = f_ctn12c00.mdacotdat and
            gfatmda.mdacod    = gfakmda.mdacod
         order by mdacod

      let arr_aux = 1
      foreach c_ctn12c00 into a_ctn12c00[arr_aux].mdacod,
                              a_ctn12c00[arr_aux].mdanom,
                              aux.mdatip,
                              a_ctn12c00[arr_aux].mdacotvlr

         case aux.mdatip
         when "R" let a_ctn12c00[arr_aux].mdatipnom = "Real"
         when "P" let a_ctn12c00[arr_aux].mdatipnom = "Projetada"
         end case

         if arr_aux < 11 then
            display a_ctn12c00[arr_aux].mdacod to
                     s_gfatmda[arr_aux].mdacod
            display a_ctn12c00[arr_aux].mdanom to
                     s_gfatmda[arr_aux].mdanom
            display a_ctn12c00[arr_aux].mdatipnom to
                     s_gfatmda[arr_aux].mdatipnom
            display a_ctn12c00[arr_aux].mdacotvlr to
                     s_gfatmda[arr_aux].mdacotvlr
         end if

         let arr_aux = arr_aux + 1
         if arr_aux > 50  then
            error "Limite de consulta excedido (50). Avise a informatica!"
            sleep 5
            exit foreach
         end if
      end foreach

      call set_count(arr_aux-1)

      display array a_ctn12c00 to s_gfatmda.*
         on key (interrupt,control-m)
            exit display

      end display
   end while

   clear form

   let int_flag = false

end function  #  ctn12c00
