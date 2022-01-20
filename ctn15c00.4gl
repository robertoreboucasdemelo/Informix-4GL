############################################################################
# Nome do Modulo: CTN15C00                                           Pedro #
#                                                                          #
# Consulta Cadastro de Empresas                                   Set/1994 #
############################################################################

#---------------------------------------------------------------
# Modulo de consulta na tabela gabkemp
# Gerado por: ct24h em: 20/09/94
#---------------------------------------------------------------

database porto

#---------------------------------------------------------------
function ctn15c00()
#---------------------------------------------------------------

   open window w_ctn15c00 at 6,2 with form "ctn15c00"
        attribute(form line 1)

   call pesquisa_ctn15c00()

   close window w_ctn15c00

end function  # ctn15c00

#-------------------------------------------------------------------
function pesquisa_ctn15c00()
#-------------------------------------------------------------------

   define a_ctn15c00 array[50] of record
      empnom         like gabkemp.empnom,
      empcod         like gabkemp.empcod,
      endlgd         like gabkemp.endlgd,
      endcid         like gabkemp.endcid,
      dddcod         like gabkemp.dddcod,
      teltxt         like gabkemp.teltxt,
      endcep         like gabkemp.endcep,
      endcepcmp      like gabkemp.endcepcmp,
      cgc            char (20)             ,
      factxt         like gabkemp.factxt
   end record

   define wsendnum     like gabkemp.endnum
   define wsendcmp     like gabkemp.endcmp
   define comando      char(500)
   define wscgccpfnum  like gabkemp.cgccpfnum
   define wscgcord     like gabkemp.cgcord
   define wscgccpfdig  like gabkemp.cgccpfdig
   define i            smallint


	define	w_pf1	integer

	let	wsendnum  =  null
	let	wsendcmp  =  null
	let	comando  =  null
	let	wscgccpfnum  =  null
	let	wscgcord  =  null
	let	wscgccpfdig  =  null
	let	i  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn15c00[w_pf1].*  to  null
	end	for

   let int_flag = false
   while not int_flag
      let comando  =
         " select",
            " empnom,",
            " empcod,",
            " endlgd,",
            " endnum,",
            " endcmp,",
            " endcid,",
            " dddcod,",
            " teltxt,",
            " endcep,",
            " endcepcmp,",
            " cgccpfnum,",
            " cgcord   ,",
            " cgccpfdig,",
            " factxt ",
         " from gabkemp ",
         " where ",
         " gabkemp.empcod is not null ",
         " order by",
           " empnom "

      prepare comando_aux from comando
      declare c_ctn15c00 cursor for comando_aux
      let i = 1
      foreach c_ctn15c00 into a_ctn15c00[i].empnom,
                              a_ctn15c00[i].empcod,
                              a_ctn15c00[i].endlgd,
                              wsendnum            ,
                              wsendcmp            ,
                              a_ctn15c00[i].endcid,
                              a_ctn15c00[i].dddcod,
                              a_ctn15c00[i].teltxt,
                              a_ctn15c00[i].endcep,
                              a_ctn15c00[i].endcepcmp,
                              wscgccpfnum         ,
                              wscgcord            ,
                              wscgccpfdig         ,
                              a_ctn15c00[i].factxt

         let a_ctn15c00[i].endlgd = a_ctn15c00[i].endlgd  clipped, " ",
                                    wsendnum   clipped, " ", wsendcmp

         if wscgccpfnum  is not null  then
            let a_ctn15c00[i].cgc =
                             wscgccpfnum using "############" clipped, "/",
                             wscgcord    using "&&&&"         clipped, "-",
                             wscgccpfdig using "&&"
         end if

         let i = i + 1
         if i > 50  then
	    error "Limite de consulta excedido. Ha' mais de 50 empresas cadastradas!"
	    exit foreach
         end if
      end foreach

      call set_count(i-1)
      message " (F17)Abandona"

      display array a_ctn15c00 to s_ctn15c00.*
         on key (interrupt,control-c)
            exit display
      end display

   end while

   let int_flag = false
   let i = arr_curr()

end function  #  ctn15c00
