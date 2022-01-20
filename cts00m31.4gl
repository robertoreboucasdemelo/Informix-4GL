 #############################################################################
 # Nome do Modulo: cts00m31                                         Marcus   #
 #                                                                           #
 # Exibe alertas de Internet para os operadores de radio            Set/2000 #
 #############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function cts00m31()
#------------------------------------------------------------

 define a_cts00m31    array[40]  of  record
    opraledes         char (65),
    servico           char (13),
#   atdsrvnum         like datmsrvintale.atdsrvnum,
#   atdsrvano         like datmsrvintale.atdsrvano,
    srvintaleseq      like datmsrvintale.srvintaleseq
 end record

 define ws            record
    srvintalecod      like datmsrvintale.srvintalecod,
    atdsrvnum         like datmsrvintale.atdsrvnum,
    atdsrvano         like datmsrvintale.atdsrvano,
#   servico           char(13),
    openwinflg        char (01),
    comando           char (300)
 end record

 define arr_aux       smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  40
		initialize  a_cts00m31[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 set isolation to dirty read

 initialize ws.*        to null
 let ws.openwinflg  =  "N"
 let int_flag       =  false

 #-------------------------------------------------------------------
 # Le todos os alertas Internet pendentes
 #-------------------------------------------------------------------
 while not int_flag

    initialize a_cts00m31  to null
    let arr_aux  =  1

    declare c_cts00m31_001 cursor for
       select srvintaleseq,
              srvintalecod,
              atdsrvnum,
              atdsrvano
         from datmsrvintale
        where srvintalesit  =  1

    foreach  c_cts00m31_001  into  a_cts00m31[arr_aux].srvintaleseq,
                               ws.srvintalecod,
                               ws.atdsrvnum,
                               ws.atdsrvano

       select cpodes
         into a_cts00m31[arr_aux].opraledes
         from iddkdominio
        where cponom  =  "srvintalecod"
          and cpocod  =  ws.srvintalecod

       let a_cts00m31[arr_aux].servico =  F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,7),
                         "/", F_FUNDIGIT_INTTOSTR(ws.atdsrvano,2)

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
       open window w_cts00m31 at  07,06 with form "cts00m31"
                   attribute(form line first, border)
    end if

    display "                Alertas Internet pendentes"
            to cabec  attribute(reverse)
    message " (F17)Abandona, (F8)Verificado"
    call set_count(arr_aux-1)

    display array  a_cts00m31 to s_cts00m31.*
       on key (interrupt)
          initialize a_cts00m31 to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()

          whenever error continue
          begin work
            update datmsrvintale set ( srvintalesit,
                                       atldat,
                                       atlhor,
                                       atlusrtip,
                                       atlemp,
                                       atlmat )
                                  =  ( 2,
                                       current,
                                       current,
                                       "F",
                                       g_issk.empcod,
                                       g_issk.funmat )
                where srvintaleseq  =  a_cts00m31[arr_aux].srvintaleseq

            if sqlca.sqlcode  <>  0   then
               error " Erro (", sqlca.sqlcode, ") na atualizacao do alerta!"
            end if
          commit work
          whenever error stop

          exit display
    end display

 end while

 if ws.openwinflg  =  "S"   then
    close window  w_cts00m31
 end if

 close c_cts00m31_001
 let int_flag = false

 set isolation to committed read

end function  ###  cts00m31
