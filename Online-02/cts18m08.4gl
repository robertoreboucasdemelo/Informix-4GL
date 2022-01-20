###############################################################################
# Nome do Modulo: cts18m08                                           Marcelo  #
#                                                                    Gilberto #
# Exibe propostas individuais para selecao                           Ago/1997 #
#-----------------------------------------------------------------------------#
#                       MANUTENCOES                                           #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86                 #
#-----------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a    #
#                                         global                              #
#-----------------------------------------------------------------------------#

database porto



globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689


#------------------------------------------------------------
 function cts18m08(param)
#------------------------------------------------------------

 define param         record
    prporgpcp         like apbmitem.prporgpcp  ,
    prpnumpcp         like apbmitem.prpnumpcp
 end record

 define d_cts18m08    record
    prporgidv         like apbmitem.prporgidv  ,
    prpnumidv         like apbmitem.prpnumidv
 end record

 define ws            record
    segnumdig         like apbmitem.segnumdig
 end record

 define a_cts18m08    array[60] of record
    prporgidv         like apbmitem.prporgidv  ,
    prpnumidv         like apbmitem.prpnumidv  ,
    segnom            char (40)                ,
    vcllicnum         like apbmveic.vcllicnum
 end record

 define arr_aux       smallint

 define sql_select    char (250)
 define l_host        like ibpkdbspace.srvnom #Saymon ambnovo

	define	w_pf1	integer

	let	arr_aux  =  null
	let	sql_select  =  null

	for	w_pf1  =  1  to  60
		initialize  a_cts18m08[w_pf1].*  to  null
	end	for

	initialize  d_cts18m08.*  to  null

	initialize  ws.*  to  null

 initialize a_cts18m08   to null
 initialize d_cts18m08.* to null
 initialize ws.*         to null
 call figrc072_initGlbIsolamento() --> 223689

 let arr_aux = 1


 whenever error continue

 if param.prporgpcp = 15  then
   let l_host = fun_dba_servidor("ORCAMAUTO")
 else
    let l_host = fun_dba_servidor("EMISAUTO")
 end if


 let sql_select = "select vcllicnum"
                 ," from porto@",l_host clipped,":apbmveic"
                 ," where prporgpcp = ?  "
                 ,"   and prpnumpcp = ?  "
                 ,"   and prporgidv = ?  "
                 ,"   and prpnumidv = ?  "

 prepare sel_apbmveic from sql_select
 declare c_apbmveic cursor for sel_apbmveic
 whenever error stop
  --> 223689
  if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
        "cts18m08"           ,
        "cts18m08"   ,
        "c_apbmveic"       ,
        "","","","","","")  then
    return d_cts18m08.*
  end if  --> 223689

 if param.prporgpcp = 15  then
  let l_host = fun_dba_servidor("ORCAMAUTO")
 else
  let l_host = fun_dba_servidor("EMISAUTO")
 end if

 whenever error continue
 let sql_select = "select prporgidv, prpnumidv, segnumdig"
                 ," from porto@",l_host clipped,":apbmitem"
                 ," where prporgpcp = ?  "
                 ,"   and prpnumpcp = ?  "

 prepare sel_apbmitem from sql_select
 declare c_cts18m08 cursor for sel_apbmitem
 whenever error stop
  --> 223689
  if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
        "cts18m08"           ,
        "cts18m08"   ,
        "c_cts18m08"       ,
        "","","","","","")  then
    return d_cts18m08.*
  end if  --> 223689

 open    c_cts18m08 using param.prporgpcp, param.prpnumpcp

 whenever error continue
 foreach c_cts18m08 into a_cts18m08[arr_aux].prporgidv,
                         a_cts18m08[arr_aux].prpnumidv,
                         ws.segnumdig

    select segnom
      into a_cts18m08[arr_aux].segnom
      from gsakseg
     where segnumdig = ws.segnumdig

    open   c_apbmveic  using  param.prporgpcp, param.prpnumpcp,
                              a_cts18m08[arr_aux].prporgidv,
                              a_cts18m08[arr_aux].prpnumidv
    fetch  c_apbmveic  into   a_cts18m08[arr_aux].vcllicnum
    close  c_apbmveic

    select vcllicnum
      from apbmveic
     where prporgpcp = param.prporgpcp                and
           prpnumpcp = param.prpnumpcp                and
           prporgidv = a_cts18m08[arr_aux].prporgidv  and
           prpnumidv = a_cts18m08[arr_aux].prpnumidv

    let arr_aux = arr_aux + 1
    if arr_aux  >  60   then
       error "Limite excedido, pesquisa com mais de 60 propostas!"
       exit foreach
    end if

 end foreach
 whenever error stop
 if g_isoAuto.sqlCodErr <> 0 then --> 223689
    close window  w_cts18m08
    return d_cts18m08.*
 end if    --> 223689

 if arr_aux = 1  then
    error " Proposta nao encontrada!"
    return d_cts18m08.*
 else
    if arr_aux = 2  then
       let d_cts18m08.prporgidv = a_cts18m08[1].prporgidv
       let d_cts18m08.prpnumidv = a_cts18m08[1].prpnumidv
    else
       open window w_cts18m08 at 09,09 with form "cts18m08"
                              attribute (form line first, border)

       display by name param.*

       message " (F17)Abandona, (F8)Seleciona"
       call set_count(arr_aux - 1)

       display array  a_cts18m08 to s_cts18m08.*
          on key (interrupt)
             initialize d_cts18m08.* to null
             error " Nenhuma proposta selecionada!"
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let d_cts18m08.prporgidv = a_cts18m08[arr_aux].prporgidv
             let d_cts18m08.prpnumidv = a_cts18m08[arr_aux].prpnumidv
             exit display

       end display

       close window  w_cts18m08
    end if
 end if

 let int_flag = false

 return d_cts18m08.*

end function  ###  cts18m08
