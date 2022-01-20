 #############################################################################
 # Nome do Modulo: ctn45c00                                         Gilberto #
 #                                                                   Marcelo #
 # Consulta socorristas do prestador                                Set/1999 #
 #############################################################################

 database porto

#------------------------------------------------------------
 function ctn45c00(param)
#------------------------------------------------------------

 define param         record
    pstcoddig         like dpaksocor.pstcoddig,
    srrabvnom         like datksrr.srrabvnom
 end record

 define a_ctn45c00    array[400]  of  record
    srrcoddig         like datksrr.srrcoddig,
    srrabvnom         like datksrr.srrabvnom,
    srrnom            like datksrr.srrnom
 end record

 define ws            record
    comando1          char (700),
    comando2          char (500),
    srrabvpsq         char (20)
 end record

 define arr_aux       smallint



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  400
		initialize  a_ctn45c00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize ws.*        to null
 initialize a_ctn45c00  to null
 let arr_aux       =  1
 let ws.srrabvpsq  =  "*", param.srrabvnom  clipped, "*"

 #-------------------------------------------------------------------
 # Monta condicao para pesquisa dos socorristas por prestador
 #-------------------------------------------------------------------
 if param.srrabvnom  is not null   then
    let ws.comando2 = "  from datrsrrpst, datksrr ",
                   " where datrsrrpst.pstcoddig  =  ? ",
                      "   and today  between  viginc and vigfnl ",
                      "   and datksrr.srrcoddig    =  datrsrrpst.srrcoddig ",
                      "   and srrabvnom  matches '", ws.srrabvpsq, "' ",
                      "   and datksrr.srrstt        in (1,2) ",
                      " order by datksrr.srrnom "
 else
    let ws.comando2 = "  from datrsrrpst, datksrr ",
                      " where datrsrrpst.pstcoddig  =  ? ",
                      "   and today  between  viginc and vigfnl ",
                      "   and datksrr.srrcoddig    =  datrsrrpst.srrcoddig ",
                      "   and datksrr.srrstt        in (1,2) ",
                      " order by datksrr.srrnom "
 end if

 let ws.comando1 = " select datksrr.srrcoddig, ",
                   "        datksrr.srrabvnom, ",
                   "        datksrr.srrnom ",
                   ws.comando2 clipped

 prepare p_ctn45c00_001 from ws.comando1
 declare c_ctn45c00_001  cursor for p_ctn45c00_001

 if param.srrabvnom  is not null   then
    open c_ctn45c00_001  using param.pstcoddig
 else
    open c_ctn45c00_001  using param.pstcoddig
 end if


 foreach  c_ctn45c00_001  into  a_ctn45c00[arr_aux].srrcoddig,
                            a_ctn45c00[arr_aux].srrabvnom,
                            a_ctn45c00[arr_aux].srrnom

    let arr_aux = arr_aux + 1
    if arr_aux > 400  then
       error " Limite excedido, pesquisa com mais de 400 socorristas!"
       exit foreach
    end if

 end foreach

 if arr_aux  =  1   then
    error " Nao existem socorristas cadastrados para este prestador!"
 else
    open window w_ctn45c00 at  08,08 with form "ctn45c00"
                attribute(form line first, border)

    message " (F17)Abandona, (F8)Seleciona"
    call set_count(arr_aux-1)

    display array  a_ctn45c00 to s_ctn45c00.*
       on key (interrupt)
          initialize a_ctn45c00 to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          exit display
    end display

    close window  w_ctn45c00
 end if

 close c_ctn45c00_001
 let int_flag = false

 return a_ctn45c00[arr_aux].srrcoddig

end function    ###--  ctn45c00
