############################################################################
# Nome do Modulo: CTN14C00                                           Pedro #
#                                                                          #
# Consulta Cadastro de Sucursais                                  Set/1994 #
############################################################################

database porto

#---------------------------------------------------------------
 function ctn14c00()
#---------------------------------------------------------------

 open window w_ctn14c00 at 06,02 with form "ctn14c00"
      attribute(form line 1)

 call pesquisa_ctn14c00()

 close window w_ctn14c00

end function  ###  ctn14c00

#-------------------------------------------------------------------
 function pesquisa_ctn14c00()
#-------------------------------------------------------------------

   define a_ctn14c00 array[100] of record
      sucnom         like gabksuc.sucnom,
      succod         like gabksuc.succod,
      endlgd         like gabksuc.endlgd,
      endnum         like gabksuc.endnum,
      endcid         like gabksuc.endcid,
      dddcod         like gabksuc.dddcod,
      teltxt         like gabksuc.teltxt,
      endcep         like gabksuc.endcep,
      endcepcmp      like gabksuc.endcepcmp,
      tlxtxt         like gabksuc.tlxtxt,
      factxt         like gabksuc.factxt,
      cgccpfnum      like gabksuc.cgccpfnum,
      cgccpfdig      like gabksuc.cgccpfdig,
      estinsnum      like gabksuc.estinsnum
   end record

   define i smallint


	define	w_pf1	integer

	let	i  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn14c00[w_pf1].*  to  null
	end	for

   let int_flag = false
   while not int_flag
      declare c_ctn14c00 cursor for
         select sucnom   , succod,
                endlgd   , endnum,
                endcid   , dddcod,
                teltxt   , endcep,
                endcepcmp, tlxtxt,
                factxt   , cgccpfnum,
                cgccpfdig, estinsnum
           from gabksuc
          order by sucnom

      let i = 1
      foreach c_ctn14c00 into a_ctn14c00[i].*
         let i = i + 1

         if i > 100 then
	    error " Limite de consulta excedido. AVISE A INFORMATICA!"
	    exit foreach
         end if
      end foreach

      call set_count(i-1)
      message " (F17)Abandona"

      display array a_ctn14c00 to s_ctn14c00.*
         on key (interrupt,control-m)
            exit display
      end display

   end while

   let int_flag = false
   let i = arr_curr()

end function  ###  ctn14c00
