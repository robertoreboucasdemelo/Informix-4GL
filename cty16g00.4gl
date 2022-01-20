#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: cty16g00                                                   #
# ANALISTA RESP..: Fabio Costa                                                #
# PSI............: 198404                                                     #
# OBJETIVO.......: Modulo responsavel pelo acesso a dados de SUCURSAIS        #
# DATA...........: 04/08/2009                                                 #
# ........................................................................... #
# Alteracoes                                                                  #
#-----------------------------------------------------------------------------#
define m_cty16g00_prep smallint
define m_vldsuc smallint

#----------------------------------------------------------------
function cty16g00_prepare()
#----------------------------------------------------------------
  define l_sql char(200)
  
  let m_cty16g00_prep = null
  let l_sql = null
  
  let l_sql = ' select 1 ',
              ' from gabkfilial ',
              ' where empcod = ? ',
              '   and filcod = ?  ' 
  prepare p_sucursal_sel from l_sql
  declare c_sucursal_sel cursor with hold for p_sucursal_sel
  
  let m_cty16g00_prep = true

end function

#----------------------------------------------------------------
function cty16g00_existe_sucursal(l_empcod, l_filcod)
#----------------------------------------------------------------

  define l_empcod  decimal(2,0) , 
         l_filcod  smallint     ,
         l_errcod  smallint     ,
         l_errmsg  char(60)
  
  if m_cty16g00_prep is null or
     m_cty16g00_prep <> true then
     call cty16g00_prepare()
  end if
  
  initialize m_vldsuc to null
  initialize l_errcod, l_errmsg to null
  
  whenever error continue
  open c_sucursal_sel using l_empcod, l_filcod
  fetch c_sucursal_sel into m_vldsuc
  whenever error stop
  
  let l_errcod = sqlca.sqlcode
  
  if l_errcod != 0
     then
     let l_errmsg = 'Erro na selecao da sucursal: ', sqlca.sqlcode
  end if
  
  return l_errcod, l_errmsg

end function

