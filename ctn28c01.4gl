###############################################################################
# Nome do Modulo: CTN28C01                                           Marcelo  #
#                                                                    Gilberto #
# Consulta log das impressoes remotas                                Set/1996 #
###############################################################################

database porto

#------------------------------------------------------------
 function ctn28c01(param)
#------------------------------------------------------------

 define param        record
    atdtrxnum        like datmtrxlog.atdtrxnum
 end record

 define a_ctn28c01   array[100]   of record
    atdtrxlogdat     like datmtrxlog.atdtrxlogdat,
    atdtrxloghor     like datmtrxlog.atdtrxloghor,
    atdtrxretcod     like datmtrxlog.atdtrxretcod,
    atdtrxretdes     char(40)
 end record

 define arr_aux      smallint
 define scr_aux      smallint

 define sql_comando  char(800)


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null
	let	sql_comando  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn28c01[w_pf1].*  to  null
	end	for

 initialize a_ctn28c01    to null
 let int_flag = false
 let arr_aux  = 1

 open window w_ctn28c01 at  06,02 with form "ctn28c01"
             attribute(form line first)

   display by name param.atdtrxnum

   declare c_ctn28c01 cursor for
      select atdtrxlogdat, atdtrxloghor, atdtrxretcod
        from datmtrxlog
       where atdtrxnum = param.atdtrxnum

   foreach  c_ctn28c01  into  a_ctn28c01[arr_aux].atdtrxlogdat ,
                              a_ctn28c01[arr_aux].atdtrxloghor ,
                              a_ctn28c01[arr_aux].atdtrxretcod

      case a_ctn28c01[arr_aux].atdtrxretcod
           when 0
              let a_ctn28c01[arr_aux].atdtrxretdes = "TRANSMISSAO OK"
           when -1
              let a_ctn28c01[arr_aux].atdtrxretdes = "NAO FOI POSSIVEL ABRIR O DEVICE(PORTA/MODEM)"
           when -2
              let a_ctn28c01[arr_aux].atdtrxretdes = "NAO FOI POSSIVEL ESTABELECER CONEXAO"
           when -3
              let a_ctn28c01[arr_aux].atdtrxretdes = "PROBLEMAS COM O CODIGO DE RETORNO"
           when -4
              let a_ctn28c01[arr_aux].atdtrxretdes = "MODEM NAO RESPONDE"
           when -5
              let a_ctn28c01[arr_aux].atdtrxretdes = "PROBLEMAS COM A DESCONEXAO"
           when -6
              let a_ctn28c01[arr_aux].atdtrxretdes = "ERRO CHECKSUM / TRANSMISSAO"
           when -7
              let a_ctn28c01[arr_aux].atdtrxretdes = "RECEPTOR INEXISTENTE"
           when -8
              let a_ctn28c01[arr_aux].atdtrxretdes = "ABANDONO DE TRANSMISSAO"
           otherwise
              let a_ctn28c01[arr_aux].atdtrxretdes = "RETORNO NAO PREVISTO!"
        end case

      let arr_aux = arr_aux + 1
      if arr_aux > 100  then
         error " Limite excedido, transmissao com mais de 100 entradas no log!"
         exit foreach
      end if

   end foreach

   if arr_aux  =  1   then
      error " Nao foi feita nenhuma tentativa de transmissao!"
   end if

   message " (F17)Abandona"

   call set_count(arr_aux-1)

   display array  a_ctn28c01 to s_ctn28c01.*
      on key (interrupt)
         exit display
   end display

   for scr_aux = 1 to 11
      clear s_ctn28c01[scr_aux].*
   end for

let int_flag = false
close window  w_ctn28c01

end function  #  ctn28c01
