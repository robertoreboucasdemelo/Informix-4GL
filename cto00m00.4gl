###############################################################################
# Nome do Modulo: cto00m00                                           Wagner   #
#                                                                    Akio     #
# Pop-up de tipos de solicitante                                     Mar/2000 #
###############################################################################
#.............................................................................#
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 18/06/2004 James, Meta       PSI 183431 Obter o nome do solicitante criando #
#                              OSF 36.439 a funcao cto00m00_nome_solicitante  #
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
#                                                                             #
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor  Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- ------------------------------------#
# 21/10/2004 Daniel Meta       PSI188514  Receber tipo ligacao como parametro #
#                                         na funcao cto00m00() e incluir a    #
#                                         condicao c24soltipcod = tipo ligacao#
#                                         no cursor c_cto00m00                #
#-----------------------------------------------------------------------------#
#                                                                             #
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor  Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- ------------------------------------#
# 03/03/2005 Robson Carmo,Meta PSI190772  Tratamento do param c24ligtipcod    #
#                                         da funcao cto00m00_nome_solicitante #
#                                         para quando for <> nulo             #
#-----------------------------------------------------------------------------#



database porto

## PSI 183431 - Inicio

## PSI 183431 - Final

#-----------------------------------------------------------
 function cto00m00(l_c24ligtipcod)
#-----------------------------------------------------------

 define l_c24ligtipcod  like datksoltip.c24ligtipcod
 define a_cto00m00 array[20] of record
    c24soltipdes   like datksoltip.c24soltipdes,
    c24soltipcod   like datksoltip.c24soltipcod
 end record

 define arr_aux    smallint

 define ws         record
    c24soltipcod   like datksoltip.c24soltipcod,
    c24soltipord   like datksoltip.c24soltipord
 end record


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  20
		initialize  a_cto00m00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let int_flag = false

 let arr_aux  = 1
 initialize a_cto00m00   to null

 declare c_cto00m00 cursor for
    select c24soltipdes, c24soltipcod, c24soltipord
      from datksoltip
      where c24ligtipcod = l_c24ligtipcod
     order by c24soltipord

 foreach c_cto00m00 into a_cto00m00[arr_aux].c24soltipdes,
                         a_cto00m00[arr_aux].c24soltipcod,
                         ws.c24soltipord

    let arr_aux = arr_aux + 1

    if arr_aux > 20  then
       error " Limite excedido. Foram encontrados mais de 20 tipos de solicitante!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.c24soltipcod = a_cto00m00[arr_aux - 1].c24soltipcod
    else
       open window cto00m00 at 12,52 with form "cto00m00"
                            attribute(form line 1, border)

       message " (F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_cto00m00 to s_cto00m00.*

          on key (interrupt,control-c)
             initialize a_cto00m00     to null
             initialize ws.c24soltipcod to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.c24soltipcod = a_cto00m00[arr_aux].c24soltipcod
             exit display

       end display

       let int_flag = false
       close window cto00m00
    end if
 else
    initialize ws.c24soltipcod to null
    error " Nao foi encontrado nenhum tipo de solicitante!"
 end if

 return ws.c24soltipcod

end function  ###  cto00m00

## PSI 183431 - Inicio

#-------------------------------------------#
 function cto00m00_nome_solicitante(lr_parm)
#-------------------------------------------#
 define lr_parm        record
        c24soltipcod   like datksoltip.c24soltipcod,
        c24ligtipcod   like datksoltip.c24ligtipcod
 end record
 define lr_retorno     record
        erro           smallint,
        mensagem       char(60),
        c24soltipdes   like datksoltip.c24soltipdes
 end record

 define l_msg          char(60)
 define l_sql        char(100)
 initialize lr_retorno.* to null
 let l_msg = null
 let l_sql = 'select c24soltipdes ',
             '  from datksoltip ',
             ' where c24soltipcod = ? '
 if lr_parm.c24ligtipcod is not null then
    let l_sql = l_sql clipped, ' and c24ligtipcod = ', lr_parm.c24ligtipcod
 end if
 prepare pcto00m00002 from l_sql
 declare ccto00m00002 cursor for pcto00m00002

 open ccto00m00002  using lr_parm.c24soltipcod
 whenever error continue
 fetch ccto00m00002 into  lr_retorno.c24soltipdes
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = "Tipo solicitante nao encontrado "
    else
       let lr_retorno.erro = 3
       let l_msg = " Erro de SELECT - ccto00m00002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
       let lr_retorno.mensagem = "ERRO ",sqlca.sqlcode, " em datksoltip "
       call errorlog(l_msg)
       let l_msg = " cto00m00_nome_solicitante() / c24soltipcod = ",lr_parm.c24soltipcod
       call errorlog(l_msg)
    end if
 else
    let lr_retorno.erro = 1
 end if
 close ccto00m00002
 return lr_retorno.*
end function

## PSI 183431 - Final

