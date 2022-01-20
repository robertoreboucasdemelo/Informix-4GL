 ##############################################################################
 # Modulo: cts14g01                                                   Almeida #
 #                                                                            #
 # Procedimentos cadastrados - condicoes satisfeitas                 Mai/1998 #
 ##############################################################################

 database porto

#---------------------------------------------------------------------
 function cts14g01(param)
#---------------------------------------------------------------------

 define param     record
   prtprcnum      like datmprtprc.prtprcnum
 end record

 define a_cts14g01 array[100] of record
   prctxtseq      like datmprctxt.prctxtseq,
   prctxt         like datmprctxt.prctxt
 end record

 define ws        record
   prtprcnum      like datmprtprc.prtprcnum,
   prtcponom      like dattprt.prtcponom,
   prtprccntdes   like datmprtprc.prtprccntdes,
   prtprcexcflg   like datmprtprc.prtprcexcflg,
   cabtxt         char(70)
 end record

 define arr_aux   integer



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_cts14g01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize ws.*        to null
 initialize a_cts14g01  to null
 let arr_aux  =  1

 open window w_cts14g01 at 3,5 with form "cts14g01"
      attribute (border,form line 1, message line last)

 let ws.cabtxt = "                 CONDICOES PARA EXIBICAO DESTE TEXTO"
 display ws.cabtxt  to  cabtxt
 message " (F17)Abandona"

 declare c_cts14g01_001 cursor for
    select datmprtprc.prtprccntdes,
           datmprtprc.prtprcnum,
           datmprtprc.prtprcexcflg,
           dattprt.prtcponom
      from datmprtprc,dattprt
     where datmprtprc.prtprcnum     =  param.prtprcnum
       and datmprtprc.prtcpointcod  =  dattprt.prtcpointcod

 foreach c_cts14g01_001 into  ws.prtprccntdes,
                          ws.prtprcnum,
                          ws.prtprcexcflg,
                          ws.prtcponom

    if ws.prtprcexcflg  =  "R"   then
       let a_cts14g01[arr_aux].prctxt = "Procedimentos para ",
           ws.prtcponom clipped, " igual a ", ws.prtprccntdes
    else
       let a_cts14g01[arr_aux].prctxt = "Procedimentos para ",
           ws.prtcponom clipped, " diferente de ", ws.prtprccntdes
    end if

    let arr_aux  = arr_aux  + 1
    if arr_aux  >  100    then
       error " Limite excedido. Atendimento c/ mais de 100 linhas de condicoes!"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux - 1)

 display array a_cts14g01 to s_cts14g01.*

  on key (interrupt)
     exit display

 end display

 let int_flag = false
 close window w_cts14g01

end function   ###--- cts14g01
