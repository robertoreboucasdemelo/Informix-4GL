###############################################################################
# Nome do Modulo: CTS14M03                                           Pedro    #
#                                                                    Marcelo  #
# Mostra todas as regioes cadastradas                                Jul/1995 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts14m03(par_cidade)
#-----------------------------------------------------------

 define par_cidade char (30)

 define a_cts14m03 array[100] of record
    ofcbrrdes      like gkpkbairro.ofcbrrdes,
    ofnrgicod      like gkpkbairro.ofnrgicod,
    succod         like gkpkbairro.succod   ,
    sucnom         like gabksuc.sucnom
 end record

 define arr_aux    smallint

 define ws         record
    succod         like gkpkbairro.succod,
    ofnrgicod      like gkpkbairro.ofnrgicod,
    ofcbrrdes      like gkpkbairro.ofcbrrdes,
    fvistsuc       char(01)
 end record


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_cts14m03[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

   open window cts14m03 at 11,22 with form "cts14m03"
               attribute (border, form line first)

   let int_flag = false
   let ws.ofcbrrdes = par_cidade
   let par_cidade = par_cidade clipped, "*"

   initialize  a_cts14m03   to null

   declare c_cts14m03_001 cursor for
      select ofcbrrdes, succod, ofnrgicod
        from gkpkbairro
       where ofcbrrdes matches par_cidade
        order by 1

   let arr_aux  = 1

   foreach c_cts14m03_001 into a_cts14m03[arr_aux].ofcbrrdes,
                           a_cts14m03[arr_aux].succod   ,
                           a_cts14m03[arr_aux].ofnrgicod
      call fvistsuc(0,"",a_cts14m03[arr_aux].succod) returning ws.fvistsuc
      if ws.fvistsuc = "N"  then
         continue foreach
      end if
      select sucnom
          into a_cts14m03[arr_aux].sucnom
          from gabksuc
          where succod = a_cts14m03[arr_aux].succod
      if sqlca.sqlcode <> 0 then
         let a_cts14m03[arr_aux].sucnom = "Nao encontrada"
      end if

      let arr_aux = arr_aux + 1
      if arr_aux  >  100  then
         error "Limite excedido, mais de 100  cidades!"
         exit foreach
      end if
   end foreach
   if a_cts14m03[1].succod   is null then
      error "Regiao nao autorizada a marcar vistoria"
   end if

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_cts14m03 to s_cts14m03.*

      on key (interrupt,control-c)
         initialize a_cts14m03    to null
         initialize ws.succod     to null
         initialize ws.ofnrgicod  to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let ws.succod    = a_cts14m03[arr_aux].succod
         let ws.ofnrgicod = a_cts14m03[arr_aux].ofnrgicod
         let ws.ofcbrrdes = a_cts14m03[arr_aux].ofcbrrdes
         exit display

   end display

   let int_flag = false

   close window  cts14m03

   return ws.succod   ,
          ws.ofnrgicod,
          ws.ofcbrrdes

end function  #  cts14m03
