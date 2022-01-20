#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : ctn06c10.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 195138                                                     #
#                 Exibe o grupo de naturezas do prestador RE                 #
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
 function ctn06c10(l_pstcoddig)
#---------------------------------------------------------

   define a_ctn06c10 array [50] of record
      socntzgrpcod      like dparpstgrpntz.socntzgrpcod,
      socntzgrpdes      like datksocntzgrp.socntzgrpdes
   end record

   define l_pstcoddig   like dparpstgrpntz.pstcoddig,
          l_resultado   smallint,
          l_mensagem    char(50)

   define arr_aux smallint
   define w_pf1	integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_resultado  =  null
	let	l_mensagem  =  null
	let	arr_aux  =  null
	let	w_pf1  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	for	w_pf1  =  1  to  50
		initialize  a_ctn06c10[w_pf1].*  to  null
	end	for

   let l_resultado = null
   let l_mensagem = null
   let arr_aux = null

   for w_pf1 = 1 to 50
       initialize a_ctn06c10[w_pf1].* to null
   end	for

   open window w_ctn06c10 at 12,40 with form "ctn06c10"
      attribute (border, form line 1)

   let int_flag = false

   declare c_ctn06c10_001 cursor for
      select socntzgrpcod,'' from dparpstgrpntz
       where pstcoddig = l_pstcoddig
       order by socntzgrpcod

   let arr_aux = 1
   foreach c_ctn06c10_001 into a_ctn06c10[arr_aux].*

      call ctx24g00_descricao(a_ctn06c10[arr_aux].socntzgrpcod)
           returning l_resultado, l_mensagem, a_ctn06c10[arr_aux].socntzgrpdes

      let arr_aux = arr_aux + 1

      if arr_aux > 50   then
         error "Limite de consulta excedido. AVISE A INFORMATICA!"
         exit foreach
      end if
   end foreach

   message " (F17)Abandona F8(Seleciona)"

   call set_count(arr_aux-1)

   display array a_ctn06c10 to dparpstgrpntz.*
      on key (interrupt,control-c)
         initialize a_ctn06c10 to null
         let arr_aux = arr_curr()
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         exit display
   end display

   let int_flag = false
   close window w_ctn06c10

   return a_ctn06c10[arr_aux].socntzgrpcod, a_ctn06c10[arr_aux].socntzgrpdes

end function

