###############################################################################
# Nome do Modulo: CTB24M01                                           Wagner   #
#                                                                             #
# POPUP MOTIVOS RETORNO                                              Set/2002 #
###############################################################################
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 01/09/2004 Robson, Meta      PSI186406  Adicionada funcao para descricao   #
#                                         do motivo de retorno.              #
#----------------------------------------------------------------------------#

database porto
#PSI186406 -Robson -inicio
define m_prep smallint

#--------------------------#
function ctb24m01_prepare()
#--------------------------#
 define l_sql char(200)
 let l_sql = ' select srvretmtvdes '
              ,' from datksrvret '
             ,' where srvretmtvcod = ? '
 prepare pctb24m01001 from l_sql
 declare cctb24m01001 cursor for pctb24m01001

 let m_prep = true
end function
#PSI186406 -Robson -Fim

#-----------------------------------------------------------
 function ctb24m01()
#-----------------------------------------------------------

 define a_ctb24m01 array[200] of record
        srvretmtvcod   like datksrvret.srvretmtvcod,
        srvretmtvdes   like datksrvret.srvretmtvdes
 end record

 define arr_aux    smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctb24m01[w_pf1].*  to  null
	end	for

 initialize a_ctb24m01    to null

 open window ctb24m01 at 10,30 with form "ctb24m01"
                     attribute(form line 1, border)

 let int_flag = false
 initialize a_ctb24m01  to null

 let arr_aux = 1

 declare c_ctb24m01_001 cursor for
  select srvretmtvcod,srvretmtvdes
    from datksrvret
   order by srvretmtvdes

 foreach c_ctb24m01_001  into  a_ctb24m01[arr_aux].srvretmtvcod,
                           a_ctb24m01[arr_aux].srvretmtvdes
    let arr_aux = arr_aux + 1
 end foreach

 message "  (F17)Abandona,  (F8)Seleciona"
 call set_count(arr_aux - 1)

 display array a_ctb24m01 to s_ctb24m01.*

    on key (interrupt,control-c)
       initialize a_ctb24m01   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

 end display

 let int_flag = false

 close window  ctb24m01

 return a_ctb24m01[arr_aux].srvretmtvcod

end function  ###  ctb24m01

# PSI186406 - Robson - inicio

#--------------------------------------#
function ctb24m01_desc_motivo(lr_param)
#--------------------------------------#
 define lr_param record
    srvretmtvcod like datksrvret.srvretmtvcod
 end record

 define lr_retorno record
    resultado    smallint
   ,mensagem     char(60)
   ,srvretmtvdes like datksrvret.srvretmtvdes
 end record
 initialize lr_retorno to null
 if m_prep is null or
    m_prep <> true then
    call ctb24m01_prepare()
 end if
 if lr_param.srvretmtvcod is not null then
    open cctb24m01001 using lr_param.srvretmtvcod
    whenever error continue
       fetch cctb24m01001 into lr_retorno.srvretmtvdes
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Motivo nao encontrado'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datksrvret'
          error ' Erro no SELECT cctb24m01001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
          error ' Funcao ctb24m01_desc_motivo() ', lr_param.srvretmtvcod sleep 2
       end if
    else
       let lr_retorno.resultado = 1
    end if
    close cctb24m01001
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros Nulos'
 end if
 return lr_retorno.*
end function

# PSI186406 - Robson - fim

