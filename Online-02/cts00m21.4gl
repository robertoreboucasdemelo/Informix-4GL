 #############################################################################
 # Nome do Modulo: cts00m21                                         Gilberto #
 #                                                                   Marcelo #
 # Exibe alertas para os operadores de radio                        Dez/1999 #
 #############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function cts00m21()
#------------------------------------------------------------

 define a_cts00m21    array[40]  of  record
    opraledes         char (50),
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclaleseq      like datmfrtale.socvclaleseq
 end record

 define ws            record
    socvclalecod      like datmfrtale.socvclalecod,
    socvclcod         like datmfrtale.socvclcod,
    openwinflg        char (01),
    comando           char (300)
 end record

 define arr_aux       smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  40
		initialize  a_cts00m21[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 set isolation to dirty read

 initialize ws.*        to null
 let ws.openwinflg  =  "N"
 let int_flag       =  false

 #-------------------------------------------------------------------
 # Le todos os alertas pendentes
 #-------------------------------------------------------------------
 while not int_flag

    initialize a_cts00m21  to null
    let arr_aux  =  1

    declare c_cts00m21_001 cursor for
       select socvclaleseq,
              socvclalecod,
              socvclcod
         from datmfrtale
        where socvclalesit  =  1

    foreach  c_cts00m21_001  into  a_cts00m21[arr_aux].socvclaleseq,
                               ws.socvclalecod,
                               ws.socvclcod

       select cpodes
         into a_cts00m21[arr_aux].opraledes
         from iddkdominio
        where cponom  =  "socvclalecod"
          and cpocod  =  ws.socvclalecod

       if ws.socvclcod  is not null   then
          select atdvclsgl
            into a_cts00m21[arr_aux].atdvclsgl
            from datkveiculo
           where socvclcod  =  ws.socvclcod
       end if

       let arr_aux = arr_aux + 1
       if arr_aux > 40  then
          error " Limite excedido, pesquisa com mais de 40 alertas!"
          exit foreach
       end if

    end foreach

    if arr_aux  =  1   then
       exit while
    end if

    if ws.openwinflg  =  "N"  then
       let ws.openwinflg  =  "S"
       open window w_cts00m21 at  07,06 with form "cts00m21"
                   attribute(form line first, border)
    end if

    display "                         Alertas pendentes"
            to cabec  attribute(reverse)
    message " (F17)Abandona, (F8)Verificado"
    call set_count(arr_aux-1)

    display array  a_cts00m21 to s_cts00m21.*
       on key (interrupt)
          initialize a_cts00m21 to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()

          whenever error continue
          begin work
            update datmfrtale set ( socvclalesit,
                                    atlemp,
                                    atlmat )
                               =  ( 2,
                                    g_issk.empcod,
                                    g_issk.funmat )
             where socvclaleseq  =  a_cts00m21[arr_aux].socvclaleseq

            if sqlca.sqlcode  <>  0   then
               error " Erro (", sqlca.sqlcode, ") na atualizacao do alerta!"
            end if
          commit work
          whenever error stop

          exit display
    end display

 end while

 if ws.openwinflg  =  "S"   then
    close window  w_cts00m21
 end if

 close c_cts00m21_001
 let int_flag = false

 set isolation to committed read

end function  ###  cts00m21
