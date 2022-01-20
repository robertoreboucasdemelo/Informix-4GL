###############################################################################
# Nome do Modulo: ctn36c00                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up para escolha de informacoes da tabela IDDKDOMINIO           Ago/1998 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/figrc072.4gl"

define m_hostname   char(12)                                
define m_server     like ibpkdbspace.srvnom #Saymon ambnovo 


#-----------------------------------------------------------
 function ctn36c00(param)
#-----------------------------------------------------------

 define param      record
    cabec          char(40),
    cponom         like iddkdominio.cponom
 end record

 define a_ctn36c00 array[50] of record
   cpodes          like iddkdominio.cpodes,
   cpocod          like iddkdominio.cpocod
 end record

 define ws         record
    cpocod         like iddkdominio.cpocod
 end record

 define arr_aux    smallint

 define l_sql char(200)

	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn36c00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize ws.*         to null
 initialize a_ctn36c00   to null
 let int_flag = false
 let arr_aux  = 1

 let m_server   = fun_dba_servidor("CT24HS")
 let m_hostname = "porto@", m_server clipped , ":"

 
 let l_sql = "select cpodes, cpocod",
             "  from ",m_hostname clipped,"iddkdominio",
             " where cponom  = ? ",
             " order by cpodes"
             
 prepare p_ctn36c00_001 from l_sql 
 declare c_ctn36c00_001 cursor for p_ctn36c00_001

 open  c_ctn36c00_001 using param.cponom

 foreach c_ctn36c00_001 into a_ctn36c00[arr_aux].cpodes,
                         a_ctn36c00[arr_aux].cpocod

    let arr_aux = arr_aux + 1

    if arr_aux > 50  then
       error " Limite excedido. Existem mais de 50 registros cadastrados!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    open window ctn36c00 at 10,20 with form "ctn36c00"
         attribute(form line 1, border)

    display by name param.cabec
    message " (F17)Abandona, (F8)Seleciona"
    call set_count(arr_aux-1)

    display array a_ctn36c00 to s_ctn36c00.*

       on key (interrupt,control-c)
          initialize a_ctn36c00  to null
          initialize ws.cpocod   to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let ws.cpocod = a_ctn36c00[arr_aux].cpocod
          exit display

    end display

    let int_flag = false
    close window ctn36c00
 else
    initialize ws.cpocod to null
    error " Nao existem registros cadastrados!"
 end if

 return ws.cpocod

end function  ###  ctn36c00
