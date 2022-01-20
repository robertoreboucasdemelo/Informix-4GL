#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m18                                                   #
# Objetivo.......: Consulta de Clausula                                       #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 23/08/2013                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define   m_prepare  smallint

#------------------------------------------------------------------------------
function ctc69m18_prepare()
#------------------------------------------------------------------------------

define l_sql char(1000)

    let l_sql = ' select clscod   '
              , '        ,clsdes  '
              ,' from aackcls a, '
              ,'      itatvig b     '
              ,' where a.tabnum = b.tabnum '
              ,'   and b.tabnom = "aackcls"'
              ,'   and b.viginc <= today   '
              ,'   and b.vigfnl >= today   '
              ,'   and a.ramcod = 531      '
              ,' order by 1 '
    prepare p_ctc69m18_001 from l_sql
    declare c_ctc69m18_001 cursor for p_ctc69m18_001
    let l_sql = ' select count(*)    '
             ,  '   from datkdominio '
             ,  '  where cponom = ?  '
             ,  '   and  cpodes = ?  '
    prepare p_ctc69m18_002 from l_sql
    declare c_ctc69m18_002 cursor for p_ctc69m18_002
    let l_sql = ' select max(cpocod)             '
             ,  ' from datkdominio               '
             ,  ' where cponom = ?               '
    prepare p_ctc69m18_003 from l_sql
    declare c_ctc69m18_003 cursor for p_ctc69m18_003
    let l_sql =  ' insert into datkdominio   '
              ,  '   (cpocod                 '
              ,  '   ,cpodes                 '
              ,  '   ,cponom                 '
              ,  '   ,atlult)                '
              ,  ' values(?,?,?,?)           '
    prepare p_ctc69m18_004 from l_sql

    let l_sql = '  delete datkdominio     '
             ,  '   where cpodes = ?      '
             ,  '   and   cponom = ?      '
    prepare p_ctc69m18_005 from l_sql

    let m_prepare = true


end function

#-----------------------------------------------------------
 function ctc69m18()
#-----------------------------------------------------------


define a_ctc69m18 array[500] of record
   clscod   like aackcls.clscod ,
   clsdes   like aackcls.clsdes ,
   processa char(03)
end record


define lr_retorno  record
  clscod  like aackcls.clscod    ,
  clsdes  like aackcls.clsdes
end record


define arr_aux  smallint
define scr_aux  smallint
define l_idx	  integer

let	arr_aux  =  null

for	l_idx  =  1  to  500
	initialize  a_ctc69m18[l_idx].*  to  null
end	for

initialize  lr_retorno.*  to  null

let int_flag = false
let arr_aux  = 1

if m_prepare is null or
   m_prepare <> true then
   call ctc69m18_prepare()
end if


 open c_ctc69m18_001
 foreach c_ctc69m18_001  into a_ctc69m18[arr_aux].clscod,
                              a_ctc69m18[arr_aux].clsdes

    if ctc69m18_recupera_processa(a_ctc69m18[arr_aux].clscod) then
       let a_ctc69m18[arr_aux].processa = "SIM"
    else
    	 let a_ctc69m18[arr_aux].processa = "NAO"
    end if
    let arr_aux = arr_aux + 1

    if arr_aux > 500  then
       error " Limite Excedido. Foram Encontrados Mais de 500 Clausulas!"
       exit foreach
    end if

 end foreach

 open window ctc69m18 at 4,2 with form "ctc69m18"
                   attribute(form line 1, border)

 message "              (F17)Abandona, (F7)Processa Sim, (F8)Processa Nao"

 call set_count(arr_aux-1)

 display array a_ctc69m18 to s_ctc69m18.*

    #---------------------------------------------
     on key (F7)
    #---------------------------------------------
     let arr_aux = arr_curr()
     let scr_aux = scr_line()
     if a_ctc69m18[arr_aux].processa = "NAO" then
          if ctc69m18_inclui_dados(a_ctc69m18[arr_aux].clscod) then
          	  let a_ctc69m18[arr_aux].processa = "SIM"
              display a_ctc69m18[arr_aux].processa to s_ctc69m18[scr_aux].processa
          end if
     end if
    #---------------------------------------------
     on key (F8)
    #---------------------------------------------
    let arr_aux = arr_curr()
    let scr_aux = scr_line()
    if a_ctc69m18[arr_aux].processa = "SIM" then
         if ctc69m18_exclui_dados(a_ctc69m18[arr_aux].clscod) then
         	  let a_ctc69m18[arr_aux].processa = "NAO"
         	  display a_ctc69m18[arr_aux].processa to s_ctc69m18[scr_aux].processa
         end if
    end if

    on key (interrupt,control-c)
       initialize a_ctc69m18     to null
       exit display

 end display

 let int_flag = false
 close window ctc69m18


end function


#========================================================================
 function ctc69m18_recupera_processa(lr_param)
#========================================================================

define lr_param  record
   clscod  like abbmclaus.clscod
end record

define l_count integer

define lr_retorno record
	cponom  like datkdominio.cponom
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata001_claus"

let l_count = 0

  open c_ctc69m18_002 using  lr_retorno.cponom,
                             lr_param.clscod

  whenever error continue
  fetch c_ctc69m18_002 into l_count
  whenever error stop

  if l_count > 0 then
     return true
  else
    return false
  end if

#========================================================================
end function
#========================================================================


#========================================================================
 function ctc69m18_inclui_dados(lr_param)
#========================================================================
define lr_param record
	cpodes  like datkdominio.cpodes
end record
define lr_retorno record
	cponom     like datkdominio.cponom ,
	cpocod     like datkdominio.cpocod ,
	data_atual date                    ,
  atlult     like datkdominio.atlult
end record
initialize lr_retorno.* to null
    let lr_retorno.cponom     = "bdata001_claus"
    let lr_retorno.cpocod     = ctc69m18_gera_codigo()
    let lr_retorno.data_atual = today
    let lr_retorno.atlult     = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"
    whenever error continue
    execute p_ctc69m18_004 using lr_retorno.cpocod
                               , lr_param.cpodes
                               , lr_retorno.cponom
                               , lr_retorno.atlult
    whenever error stop

    if sqlca.sqlcode <> 0 then
       return false
    else
    	 return true
    end if
end function

#---------------------------------------------------------
 function ctc69m18_gera_codigo()
#---------------------------------------------------------
define lr_retorno record
	 codigo integer                  ,
	 cponom like datkdominio.cponom
end record
initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata001_claus"
   open c_ctc69m18_003 using lr_retorno.cponom
   whenever error continue
   fetch c_ctc69m18_003 into  lr_retorno.codigo
   whenever error stop
   if lr_retorno.codigo is null or
   	  lr_retorno.codigo = 0     then
   	    let lr_retorno.codigo = 1
   else
   	    let lr_retorno.codigo =  lr_retorno.codigo + 1
   end if
   return lr_retorno.codigo
end function

#==============================================
 function ctc69m18_exclui_dados(lr_param)
#==============================================

define lr_param record
	cpodes  like datkdominio.cpodes
end record

define lr_retorno record
	cponom like datkdominio.cponom
end record

initialize lr_retorno.* to null
let lr_retorno.cponom = "bdata001_claus"
    whenever error continue
    execute p_ctc69m18_005 using lr_param.cpodes
                                ,lr_retorno.cponom
    whenever error stop

    if sqlca.sqlcode <> 0 then
       return false
    else
    	 return true
    end if
end function
