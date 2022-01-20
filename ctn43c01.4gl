 ##############################################################################
 # Nome do Modulo: ctn43c01                                          Marcelo  #
 #                                                                   Gilberto #
 # Consulta log das mensagens enviadas para MDT's                    Ago/1999 #
 ##############################################################################

 database porto

#------------------------------------------------------------
 function ctn43c01(param)
#------------------------------------------------------------

 define param        record
    mdtmsgnum        like datmmdtlog.mdtmsgnum
 end record

 define a_ctn43c01   array[100]   of record
    atldat           like datmmdtlog.atldat,
    atlhor           like datmmdtlog.atlhor,
    mdtmsgstt        like datmmdtlog.mdtmsgstt,
    mdtmsgsttdes     char(40)
 end record

 define arr_aux      smallint



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn43c01[w_pf1].*  to  null
	end	for

 initialize a_ctn43c01    to null
 let int_flag = false
 let arr_aux  = 1

 open window w_ctn43c01 at  06,02 with form "ctn43c01"
             attribute(form line first)

 display by name param.mdtmsgnum

 declare c_ctn43c01_001 cursor for
    select atldat, atlhor, mdtmsgstt
      from datmmdtlog
     where mdtmsgnum = param.mdtmsgnum

 foreach  c_ctn43c01_001  into  a_ctn43c01[arr_aux].atldat,
                            a_ctn43c01[arr_aux].atlhor,
                            a_ctn43c01[arr_aux].mdtmsgstt

    select cpodes
      into a_ctn43c01[arr_aux].mdtmsgsttdes
      from iddkdominio
     where cponom  =  "mdtmsgstt"
       and cpocod  =  a_ctn43c01[arr_aux].mdtmsgstt

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

 display array  a_ctn43c01 to s_ctn43c01.*
    on key (interrupt)
       exit display
 end display

 let int_flag = false
 close window  w_ctn43c01

end function   ###---  ctn43c01
