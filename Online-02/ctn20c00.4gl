###############################################################################
# Nome do Modulo: CTN20C00                                           Pedro    #
#                                                                    Marcelo  #
# Mostra todos os convenios para atendimento                         Nov/1995 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctn20c00()
#-----------------------------------------------------------

 define a_ctn20c00 array[50] of record
    cvnnom         char (30)           ,
    cvnnum         like datkscv.cvnnum
 end record

 define ws         record
    cvnnom         char (30)           ,
    cvnnum         like datkscv.cvnnum
 end record

 define arr_aux    smallint

 define sql        char (100)


	define	w_pf1	integer

	let	arr_aux  =  null
	let	sql  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn20c00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let sql = "select cpocod from datkdominio",
           " where cponom = 'cvnnum'   and",
           "       cpocod = ?"

 prepare sel_datkdominio from sql
 declare c_datkdominio cursor for sel_datkdominio

 open window ctn20c00 at 10,43 with form "ctn20c00"
                      attribute(form line 1, border)

 let int_flag = false
 initialize a_ctn20c00   to null
 initialize ws.*         to null

 declare c_ctn20c00    cursor for
    select cpocod, cpodes
      from datkdominio
     where cponom = "ligcvntip"

 let arr_aux  = 1

 foreach c_ctn20c00 into ws.cvnnum,
                         ws.cvnnom

    if ws.cvnnum = 00    then
       continue foreach
    end if

    open  c_datkdominio using ws.cvnnum
    fetch c_datkdominio
    if sqlca.sqlcode = notfound  then
       continue foreach
    end if
    close c_datkdominio

    let a_ctn20c00[arr_aux].cvnnum = ws.cvnnum
    let a_ctn20c00[arr_aux].cvnnom = ws.cvnnom

    let arr_aux = arr_aux + 1
    if arr_aux  >  50   then
       error " Limite excedido, tabela de convenios com mais de 50 itens!"
       exit foreach
    end if

 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_ctn20c00 to s_ctn20c00.*

    on key (interrupt,control-c)
       initialize a_ctn20c00   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

 end display

 close window  ctn20c00
 let int_flag = false

 return a_ctn20c00[arr_aux].cvnnum

end function  ###  ctn20c00
