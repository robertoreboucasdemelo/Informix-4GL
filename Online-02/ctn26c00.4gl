###############################################################################
# Nome do Modulo: CTN26C00                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de etapas para acompanhamento de servicos                   Ago/1998 #
###############################################################################
#                                                                             #
# 07/06/2000  PSI 108669    Ruiz    Alteracao do campo atdtip p/ atdsrvorg    #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctn26c00(param)
#-----------------------------------------------------------

 define param      record
    atdsrvorg      like datksrvtip.atdsrvorg
 end record

 define a_ctn26c00 array[50] of record
    atdetpdes      like datketapa.atdetpdes,
    atdetpcod      like datketapa.atdetpcod
 end record

 define arr_aux smallint

 define ws         record
    sql            char (200),
    atdsrvorg      like datksrvtip.atdsrvorg,
    atdetpcod      like datketapa.atdetpcod
 end record


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn26c00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let ws.sql = "select atdsrvorg from datrsrvetp",
              " where atdsrvorg = ?  and    ",
              "       atdetpcod = ?  and    ",
              "       atdsrvetpstt = 'A'    "
 prepare p_ctn26c00_001 from ws.sql
 declare c_ctn26c00_001 cursor for p_ctn26c00_001

 let int_flag = false

 let arr_aux  = 1
 initialize a_ctn26c00   to null

 declare c_ctn26c00_002 cursor for
    select atdetpdes, atdetpcod
      from datketapa
     where atdetpstt = "A"
     order by atdetpdes

 foreach c_ctn26c00_002 into a_ctn26c00[arr_aux].atdetpdes,
                         a_ctn26c00[arr_aux].atdetpcod

    if param.atdsrvorg is not null  then
       open  c_ctn26c00_001 using param.atdsrvorg, a_ctn26c00[arr_aux].atdetpcod
       fetch c_ctn26c00_001
       if sqlca.sqlcode = notfound  then
          continue foreach
       end if
       close c_ctn26c00_001
    end if

    let arr_aux = arr_aux + 1

    if arr_aux > 50  then
       error " Limite excedido. Foram encontrados mais de 50 etapas de acompanhamento!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.atdetpcod = a_ctn26c00[arr_aux - 1].atdetpcod
    else
       open window ctn26c00 at 12,52 with form "ctn26c00"
                            attribute(form line 1, border)

       message " (F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_ctn26c00 to s_ctn26c00.*

          on key (interrupt,control-c)
             initialize a_ctn26c00     to null
             initialize ws.atdetpcod to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.atdetpcod = a_ctn26c00[arr_aux].atdetpcod
             exit display

       end display

       let int_flag = false
       close window ctn26c00
    end if
 else
    initialize ws.atdetpcod to null
    error " ATENCAO: Nao foi encontrado nenhuma etapa de acompanhamento!"
    sleep 2
 end if

 let int_flag = false

 return ws.atdetpcod

end function  ###  ctn26c00
