###############################################################################
# Nome do Modulo: cto00m07                                           Alberto  #
#                                                                             #
# Pop-up de Grau de parentesco                                       Mai/2007 #
###############################################################################
#.............................................................................#
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor             Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 09/05/2007 Alberto           PSI 207446 Obter o nome grau de parentesco com #
#                                         o segurado.                         #
#-----------------------------------------------------------------------------#
database porto

#-----------------------------------------------------------
 function cto00m07(l_cponom)
#-----------------------------------------------------------

 define l_cponom  like iddkdominio.cponom


 define a_cto00m07 array[30] of record
    cpodes   like iddkdominio.cpodes,
    cpocod   like iddkdominio.cpocod
 end record

 define l_cto00m07 record
        tlt char(30)
 end record

 define arr_aux    smallint

 define ws         record
    cpocod         like iddkdominio.cpocod,
    cpodes         like iddkdominio.cpodes
 end record

	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  30
		initialize  a_cto00m07[w_pf1].*  to  null
	end	for

	initialize  ws.*          to  null
	initialize  l_cto00m07.*  to  null

 let int_flag = false

 let arr_aux  = 1
 initialize a_cto00m07   to null

 if l_cponom = 'c24depsaf'       or
    l_cponom = 'datmfuneral'     or
    l_cponom = 'c24depsafRENNER' then
    let l_cto00m07.tlt = " Grau de Parentesco "
 end if

 if l_cponom = 'c24lclret' then
    let l_cto00m07.tlt = "Local Retirada do Corpo"
 end if

 if l_cponom = 'c24caumrt' then
     let l_cto00m07.tlt = "Causa da Morte"
 end if

 if l_cponom = 'c24fnrtip' then
     let l_cto00m07.tlt = "Tipo de Funeral"
 end if

 declare c_cto00m07_001 cursor for
    select cpodes, cpocod
      from iddkdominio
      where cponom = l_cponom
     order by cpodes

 foreach c_cto00m07_001 into a_cto00m07[arr_aux].cpodes,
                         a_cto00m07[arr_aux].cpocod

    let arr_aux = arr_aux + 1

    if arr_aux > 30  then
       error " Limite excedido. Foram encontrados mais de 30 ", l_cto00m07.tlt , " !"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.cpocod = a_cto00m07[arr_aux - 1].cpocod
    else
       open window cto00m07 at 12,52 with form "cto00m07"
                            attribute(form line 1, border)

       message "<F8> Seleciona"

       display by name l_cto00m07.tlt

          call set_count(arr_aux-1)
          display array a_cto00m07 to s_cto00m07.*

          on key (interrupt,control-c)
             initialize a_cto00m07     to null
             initialize ws.cpocod to null
             initialize ws.cpodes to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.cpocod = a_cto00m07[arr_aux].cpocod
             let ws.cpodes = a_cto00m07[arr_aux].cpodes
             exit display

          end display



       let int_flag = false
       close window cto00m07
    end if
 else
    initialize ws.cpocod to null
    error " Nao foi encontrado nenhum tipo ", l_cto00m07.tlt, "!"
 end if


 return ws.*

end function  ###  cto00m07



#-------------------------------------------#
 function cto00m07_busca_descricao(lr_param)
#-------------------------------------------#

 define lr_param        record
        cpocod   like iddkdominio.cpocod,
        cponom   like iddkdominio.cponom
 end record

 define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        cpodes         like iddkdominio.cpodes
 end record

 define l_msg          char(60)
 define l_sql        char(100)

 initialize lr_retorno.* to null
 let l_msg = null

 let l_sql = 'select cpodes ',
             '  from iddkdominio ',
             ' where cpocod = ? '

 if lr_param.cponom is not null then
    let l_sql = l_sql clipped, ' and cponom = ', lr_param.cponom
 end if


 prepare p_cto00m07_001 from l_sql
 declare c_cto00m07_002 cursor for p_cto00m07_001

 open c_cto00m07_002  using lr_param.cpocod
 whenever error continue
 fetch c_cto00m07_002 into  lr_retorno.cpodes
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = "Tipo solicitado nao encontrado "
    else
       let lr_retorno.erro = 3
       let l_msg = " Erro de SELECT - c_cto00m07_002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
       let lr_retorno.mensagem = "ERRO ",sqlca.sqlcode, " em iddkdominio "
       call errorlog(l_msg)
       let l_msg = " cto00m07_busca_descricao() / cpocod = ",lr_param.cpocod
       call errorlog(l_msg)
    end if
 else
    let lr_retorno.erro = 1
 end if
 close c_cto00m07_002

 return lr_retorno.*

end function




