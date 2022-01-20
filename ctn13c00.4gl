###############################################################################
# Nome do Modulo: CTN13C00                                           Marcelo  #
#                                                                    Gilberto #
# Mostra todos os topicos relacionados ao convenio selecionado       Mar/1996 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


#-----------------------------------------------------------
 function ctn13c00(par_ctn13c00)
#-----------------------------------------------------------

   define par_ctn13c00  record
          cvnnum        like datktopcvn.cvnnum
   end record

   define a_ctn13c00 array[50] of record
          cvntopnom     like datktopcvn.cvntopnom,
          cvntopcod     like datktopcvn.cvntopcod
   end record

   define d_ctn13c00 record
          cvntopcod     like datktopcvn.cvntopcod
   end record

   define arr_aux    smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn13c00[w_pf1].*  to  null
	end	for

	initialize  d_ctn13c00.*  to  null

   let int_flag = false
   initialize  a_ctn13c00   to null

   declare  c_ctn13c00_001    cursor for
     select cvntopcod, cvntopnom
       from datktopcvn
      where par_ctn13c00.cvnnum = datktopcvn.cvnnum
      order by cvntopnom
   let arr_aux  = 1

   foreach c_ctn13c00_001 into a_ctn13c00[arr_aux].cvntopcod,
                           a_ctn13c00[arr_aux].cvntopnom

      let arr_aux = arr_aux + 1
      if arr_aux  >  50   then
         error " Limite excedido! Foram encontrados mais de 50 topicos!"
         exit foreach
      end if

   end foreach

    if arr_aux = 1 then
       error " Convenio nao possui procedimentos especificos de atendimento!"
       return
    end if

   open window ctn13c00 at 08,12 with form "ctn13c00"
                        attribute(form line 1, border)

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_ctn13c00 to s_ctn13c00.*

      on key (interrupt,control-c)
         initialize a_ctn13c00   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let d_ctn13c00.cvntopcod = a_ctn13c00[arr_aux].cvntopcod

         if par_ctn13c00.cvnnum   is not null and
            d_ctn13c00.cvntopcod  is not null then
            call ctn13c01(par_ctn13c00.cvnnum, d_ctn13c00.cvntopcod)
            initialize d_ctn13c00.cvntopcod to null
         else
            exit display
         end if

   end display

   close window  ctn13c00

## if not int_flag                      and
##    par_ctn13c00.cvnnum   is not null and
##    d_ctn13c00.cvntopcod  is not null then
##    call ctn13c01(par_ctn13c00.cvnnum, d_ctn13c00.cvntopcod)
## end if

   let int_flag = false

end function  #  ctn13c00
