###############################################################################
# Nome do Modulo: CTS06M03                                              Pedro #
#                                                                     Marcelo #
# Vistorias previas programadas (agenda)                             Jan/1995 #
###############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function cts06m03(param)
#------------------------------------------------------------

 define param         record
    vstdat            like datmvstagen.vstdat,
    succod            like datmvstagen.succod
 end record

 define d_cts06m03    record
    vstdat            like datmvstagen.vstdat,
    succod            like datmvstagen.succod
 end record

 define a_cts06m03    array[60] of record
    diasem            char (07)                    ,
    vstdat2           like datmvstagen.vstdat      ,
    atrvstqtdc24      like datmvstagen.atrvstqtdc24,
    vstqtdc24         like datmvstagen.vstqtdc24   ,
    vstqtdaut         like datmvstagen.vstqtdaut   ,
    vstqtdvol         like datmvstagen.vstqtdvol
 end record

 define ws            record
    cons              smallint,
    sucnom            like gabksuc.sucnom
 end record

 define arr_aux       smallint
 define scr_aux       smallint



	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  60
		initialize  a_cts06m03[w_pf1].*  to  null
	end	for

	initialize  d_cts06m03.*  to  null

	initialize  ws.*  to  null

 open window w_cts06m03 at 06,02 with form "cts06m03"
             attribute(form line first)

 let d_cts06m03.vstdat = param.vstdat
 let d_cts06m03.succod = param.succod

 while true

   let int_flag = false
   let arr_aux  = 1
   initialize a_cts06m03  to null

   if d_cts06m03.vstdat is null  then
      let ws.cons = false

      input by name d_cts06m03.* without defaults

         before field vstdat
            let d_cts06m03.vstdat = today
            display by name d_cts06m03.vstdat    attribute (reverse)

         after field vstdat
            display by name d_cts06m03.vstdat

            if d_cts06m03.vstdat  is null   then
              error " Data de realizacao da vistoria previa deve ser informada!"
               next field vstdat
            end if

         before field succod
            display by name d_cts06m03.succod    attribute (reverse)

            let d_cts06m03.succod = g_issk.succod

            select sucnom  into  ws.sucnom
              from gabksuc
             where succod = d_cts06m03.succod
             display by name ws.sucnom

         after field succod
            display by name d_cts06m03.succod

            if d_cts06m03.succod  is null   then
               error " Sucursal deve ser informada!"
               next field succod
            end if

            select sucnom  into  ws.sucnom
              from gabksuc
             where succod = d_cts06m03.succod
             display by name ws.sucnom

            if g_issk.dptsgl  <>  "desenv"   then
               if d_cts06m03.succod  <>  g_issk.succod   then
                 error " Nao devem ser consultadas vistorias de outra sucursal!"
                  next field succod
               end if
            end if

         on key (interrupt)
            exit input

      end input

      if int_flag   then
         exit while
      end if
   else
      display by name d_cts06m03.vstdat
      let ws.cons = true
   end if

   #-------------------------------------------
   # CONSULTA AS VISTORIAS MARCADAS
   #-------------------------------------------
   declare c_cts06m03_001   cursor  for
      select vstdat   , atrvstqtdc24, vstqtdaut,
             vstqtdc24, vstqtdvol
        from datmvstagen
       where vstdat >= d_cts06m03.vstdat   and
             succod  = d_cts06m03.succod

   foreach  c_cts06m03_001  into  a_cts06m03[arr_aux].vstdat2     ,
                              a_cts06m03[arr_aux].atrvstqtdc24,
                              a_cts06m03[arr_aux].vstqtdaut   ,
                              a_cts06m03[arr_aux].vstqtdc24   ,
                              a_cts06m03[arr_aux].vstqtdvol

      call c24geral12(a_cts06m03[arr_aux].vstdat2)
           returning  a_cts06m03[arr_aux].diasem

      let arr_aux = arr_aux + 1
      if arr_aux > 60  then
         error " Limite excedido. Pesquisa com mais de 60 dias!"
         exit foreach
      end if
   end foreach

   if arr_aux  >  1   then
      message " (F17)Abandona"
      call set_count(arr_aux-1)

      display array  a_cts06m03 to s_cts06m03.*
         on key(interrupt)
            initialize d_cts06m03.vstdat to null
            exit display
      end display

      for scr_aux = 1 to 10
         clear s_cts06m03[scr_aux].diasem
         clear s_cts06m03[scr_aux].vstdat2
         clear s_cts06m03[scr_aux].atrvstqtdc24
         clear s_cts06m03[scr_aux].vstqtdaut
         clear s_cts06m03[scr_aux].vstqtdc24
         clear s_cts06m03[scr_aux].vstqtdvol
      end for
   else
      error " Nao existem vistorias programadas para pesquisa!"
   end if

   if ws.cons = true  then
      exit while
   end if
end while

let int_flag = false
close window  w_cts06m03

end function  #  cts06m03
