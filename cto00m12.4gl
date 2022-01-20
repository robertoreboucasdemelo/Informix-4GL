###############################################################################
# Nome do Modulo: cto00m12                                           Alberto  #
#                                                                             #
# Pop-up de tipos de forma de pagamento                              12/2012  #
###############################################################################
#.............................................................................#
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor             Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 24/12/2012 Alberto           PSI-2012-22101 SAPS                            #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

#-----------------------------------------------------------
 function cto00m12(l_pgtfrmcod)
#-----------------------------------------------------------

 define l_pgtfrmcod  like datkpgtfrm.pgtfrmcod
 
 define a_cto00m12 array[20] of record
    pgtfrmdes   like datkpgtfrm.pgtfrmdes,
    pgtfrmcod   like datkpgtfrm.pgtfrmcod
 end record

 define arr_aux    smallint

 define ws         record
    pgtfrmdes   like datkpgtfrm.pgtfrmdes,
    pgtfrmcod   like datkpgtfrm.pgtfrmcod
 end record


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  20
		initialize  a_cto00m12[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let int_flag = false

 let arr_aux  = 1
 initialize a_cto00m12   to null

 declare c_cto00m12 cursor for
    select pgtfrmdes, pgtfrmcod
      from datkpgtfrm
#      where pgtfrmcod = l_pgtfrmcod
     order by pgtfrmdes
 foreach c_cto00m12 into a_cto00m12[arr_aux].pgtfrmdes,
                         a_cto00m12[arr_aux].pgtfrmcod
 
    let arr_aux = arr_aux + 1

    if arr_aux > 20  then
       error " Limite excedido. Foram encontrados mais de 20 tipos de forma de pagamento!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.pgtfrmcod = a_cto00m12[arr_aux - 1].pgtfrmcod
    else
       open window cto00m12 at 12,52 with form "cto00m12"
                            attribute(form line 1, border)

       message " (F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_cto00m12 to s_cto00m12.*

          on key (interrupt,control-c)
             initialize a_cto00m12   to null
             initialize ws.pgtfrmcod to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.pgtfrmcod = a_cto00m12[arr_aux].pgtfrmcod
             exit display

       end display

       let int_flag = false
       close window cto00m12
    end if
 else
    initialize ws.pgtfrmcod to null
    error " Nao foi encontrado nenhum tipo de forma de pagamento!"
 end if

 return ws.pgtfrmcod

end function  ###  cto00m12

## PSI 183431 - Inicio

#-------------------------------------------#
 function cto00m12_nome_frmpgto(lr_parm)
#-------------------------------------------#
 define lr_parm        record
        pgtfrmcod   like datkpgtfrm.pgtfrmcod,
        pgtfrmdes   like datkpgtfrm.pgtfrmdes
 end record
 define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        pgtfrmdes   like datkpgtfrm.pgtfrmdes
 end record

 define l_msg          char(60)
 define l_sql        char(100)
 initialize lr_retorno.* to null
 let l_msg = null
 let l_sql = 'select pgtfrmdes ',
             '  from datkpgtfrm',
             ' where pgtfrmcod = ? '
 
 prepare pcto00m12002 from l_sql
 declare ccto00m12002 cursor for pcto00m12002
                                           
 open ccto00m12002  using lr_parm.pgtfrmcod
 whenever error continue
 fetch ccto00m12002 into  lr_retorno.pgtfrmdes
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = "Tipo forma de pagamento nao encontrado "
    else
       let lr_retorno.erro = 3
       let l_msg = " Erro de SELECT - ccto00m12002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
       let lr_retorno.mensagem = "ERRO ",sqlca.sqlcode, " em pgtfrmcod "
       call errorlog(l_msg)
       let l_msg = " cto00m12_nome_frmpgto() / pgtfrmcod = ",lr_parm.pgtfrmcod
       call errorlog(l_msg)
    end if
 else
    let lr_retorno.erro = 1
 end if
 close ccto00m12002
 return lr_retorno.*

end function

## PSI 183431 - Final

