###############################################################################
# Nome do Modulo: CTS00M09                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de tipos de servico                                         Out/1996 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 13/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
#.............................................................................#
#                                                                             #
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 21/07/2004 James, Meta       PSI186414  criar funcao cts00m09_desc_tipo_srv #
#                              OSF 37940  (obter descricao tipo de servico)   #
###############################################################################

## PSI 186414 - Inicio

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql         smallint

#--------------------------#
function cts00m09_prepare()
#--------------------------#

  define l_sql        char(200)
  let l_sql = "select srvtipabvdes,srvtipdes  ",
              "  from datksrvtip ",
              " where atdsrvorg = ? "

  prepare pcts00m09001  from l_sql
  declare ccts00m09001  cursor for pcts00m09001

  let m_prep_sql = true

end function

## PSI 186414 - Final

#-----------------------------------------------------------
 function cts00m09()
#-----------------------------------------------------------

 define a_cts00m09 array[30] of record
    srvtipdes   like datksrvtip.srvtipdes,
    atdsrvorg   like datksrvtip.atdsrvorg
 end record

 define arr_aux smallint

 define retorno record
    atdsrvorg   like datksrvtip.atdsrvorg
 end record


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  30
		initialize  a_cts00m09[w_pf1].*  to  null
	end	for

	initialize  retorno.*  to  null

 open window cts00m09 at 08,42 with form "cts00m09"
                      attribute(form line 1, border)

 let int_flag = false

 let arr_aux  = 1
 initialize a_cts00m09   to null

 declare c_cts00m09_001 cursor for
    select srvtipdes, atdsrvorg
      from datksrvtip
     order by srvtipdes

 foreach c_cts00m09_001 into a_cts00m09[arr_aux].srvtipdes,
                         a_cts00m09[arr_aux].atdsrvorg

    let arr_aux = arr_aux + 1

    if arr_aux > 30  then
       error " Limite excedido. Foram encontrados mais de 30 tipos de servico!"
       exit foreach
    end if

 end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_cts00m09 to s_cts00m09.*

    on key (interrupt,control-c)
       initialize a_cts00m09     to null
       initialize retorno.atdsrvorg to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       let retorno.atdsrvorg = a_cts00m09[arr_aux].atdsrvorg
       exit display

 end display

 let int_flag = false
 close window cts00m09
 return retorno.atdsrvorg

end function  ###  cts00m09

## PSI 186414 - Inicio

#---------------------------------------#
function cts00m09_desc_tipo_srv(lr_parm)
#---------------------------------------#

 define lr_parm        record
        atdsrvorg      like datksrvtip.atdsrvorg,
        flag_desc      char(01)
 end record

 define lr_aux         record
        srvtipabvdes   like datksrvtip.srvtipabvdes,
        srvtipdes      like datksrvtip.srvtipdes
 end record

 define lr_retorno     record
        erro           smallint,
        mensagem       char(70),
        descricao      char(40)
 end record

 define l_msg          char(70)
 if m_prep_sql is null or m_prep_sql <> true then
    call cts00m09_prepare()
 end if

 initialize lr_retorno.* to null

 if lr_parm.atdsrvorg is null then
    let lr_retorno.erro = 3
    let lr_retorno.mensagem = "Parametro nulo"
    return lr_retorno.*
 end if

 open ccts00m09001  using lr_parm.atdsrvorg
 whenever error continue
 fetch ccts00m09001 into  lr_aux.*
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.erro = 2
       let lr_retorno.mensagem = "Tipo de servico nao encontrado "
    else
       let lr_retorno.erro = 3
       let l_msg = " Erro de SELECT - ccts00m09001 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
       let lr_retorno.mensagem = "Erro <", sqlca.sqlcode, "> na consulta datksrvtip "
       call errorlog(l_msg)
       let l_msg = " cts00m09_desc_tipo_srv() / Origem : ",lr_parm.atdsrvorg
       call errorlog(l_msg)
    end if
 else
    let lr_retorno.erro = 1
    if  lr_parm.flag_desc = "A" then
        let lr_retorno.descricao = lr_aux.srvtipabvdes
    else
        let lr_retorno.descricao = lr_aux.srvtipdes
    end if
 end if
 close ccts00m09001
 return lr_retorno.*

end function

## PSI 186414 - Final
