#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : ctn06c11.4gl                                               #
# Analista Resp : Adriano Santos                                             #
# PSI           : 242853                                                     #
#                 Exibe as naturezas do prestador RE                         #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#
database porto

#---------------------------------------------------------
 function ctn06c11(l_pstcoddig)
#---------------------------------------------------------

   define a_ctn06c11 array [300] of record
      socntzcod      like dparpstntz.socntzcod,
      socntzdes      like datksocntz.socntzdes
   end record

   define l_pstcoddig     like dparpstntz.pstcoddig,
          l_resultado     smallint,
          l_mensagem      char(80),
          l_socntzgrpcod  like datksocntz.socntzgrpcod

   define arr_aux smallint
   define w_pf1	integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_resultado  =  null
	let	l_mensagem  =  null
	let	arr_aux  =  null
	let	w_pf1  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	for	w_pf1  =  1  to  300
		initialize  a_ctn06c11[w_pf1].*  to  null
	end	for

   let l_resultado = null
   let l_mensagem = null
   let arr_aux = null

   for w_pf1 = 1 to 300
       initialize a_ctn06c11[w_pf1].* to null
   end	for

   open window w_ctn06c11 at 12,40 with form "ctn06c11"
      attribute (border, form line 1)

   let int_flag = false

   declare c_ctn06c11_001 cursor for
      select socntzcod,'' from dparpstntz
       where pstcoddig = l_pstcoddig
       order by socntzcod

   let arr_aux = 1
   foreach c_ctn06c11_001 into a_ctn06c11[arr_aux].*

      #call ctx24g00_descricao(a_ctn06c11[arr_aux].socntzcod)
      #     returning l_resultado, l_mensagem, a_ctn06c11[arr_aux].socntzdes
      call ctx24g01_descricao(a_ctn06c11[arr_aux].socntzcod)
           returning l_resultado, l_mensagem, a_ctn06c11[arr_aux].socntzdes
      let arr_aux = arr_aux + 1

      if arr_aux > 300   then
         error "Limite de consulta excedido. AVISE A INFORMATICA!"
         exit foreach
      end if
   end foreach

   message " (F17)Abandona F8(Seleciona)"

   call set_count(arr_aux-1)

   display array a_ctn06c11 to dparpstntz.*
      on key (interrupt,control-c)
         initialize a_ctn06c11 to null
         let arr_aux = arr_curr()
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         exit display
   end display

   let int_flag = false
   close window w_ctn06c11

   return a_ctn06c11[arr_aux].socntzcod, a_ctn06c11[arr_aux].socntzdes

end function

