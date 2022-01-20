#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#------------------------------------------------------------------------------#
# Sistema    : PORTO SOCORRO                                                   #
# Modulo     : ctd30g00.4gl                                                    #
# Objetivo   : Modulo responsavel pelo acesso a tabela IGBMPARAM (db18w)       #
# Projeto    : PSI 258610                                                      #
# Analista   : Fabio Costa                                                     #
# Liberacao  : 31/08/2010                                                      #
#------------------------------------------------------------------------------#
# ALTERACOES                                                                   #
# Data        Responsavel         PSI     Alteracao                            #
# ----------  ------------------  ------  -------------------------------------#
#------------------------------------------------------------------------------#
database porto

define m_ctd30g00_prep  smallint
     , m_host           char(05)
     , m_banco          char(11)

#----------------------------------------------------------------
function ctd30g00_prepare()
#----------------------------------------------------------------
  define l_sql    char(400)
  
  initialize l_sql, m_banco, m_host to null
  
  let m_ctd30g00_prep = false
  
  # definir sitename, apontar para banco u18 quando em producao
  whenever error continue
  select sitename into m_host from dual
  whenever error stop
  
  if m_host is not null and m_host = 'u07'
     then
     let m_banco = ' '
  else
     let m_banco = 'porto@u18w:'
  end if
  
  let l_sql = ' update ', m_banco,' igbmparam set (relpamtxt) = (?) ',
              ' where relsgl    = ? ',
              '   and relpamseq = ? ',
              '   and relpamtip = ? '
  prepare p_upd_igbm from l_sql
  
  let l_sql = ' insert into ', m_banco,' igbmparam(relsgl   , ',  # NN
                                        '          relpamseq, ',  # NN
                                        '          relpamtip, ', 
                                        '          relpamtxt )',
                                        '   values (?,?,?,?)'
  prepare p_ins_igbm from l_sql

  let l_sql = ' select relpamseq, relpamtip, relpamtxt ',
              '   from ', m_banco,' igbmparam     ',
              '  where relsgl    = ? ',
              '    and relpamseq = ? ',
              '    and relpamtip = ? '
  prepare p_sel_igbm from l_sql
  declare c_sel_igbm cursor with hold for p_sel_igbm
  
  let l_sql = '  delete from ', m_banco,' igbmparam ',
              '  where relsgl    = ? ',
              '    and relpamseq = ? ',
              '    and relpamtip = ? '
  prepare p_del_igbm from l_sql
  
  let m_ctd30g00_prep = true

end function

#----------------------------------------------------------------
function ctd30g00_sel_igbm(l_param)
#----------------------------------------------------------------

  define l_param record
         nivel_retorno  smallint                ,
         relsgl         like igbmparam.relsgl   ,
         relpamseq      like igbmparam.relpamseq,
         relpamtip      like igbmparam.relpamtip
  end record
  
  define l_retorno record
         relpamseq  like igbmparam.relpamseq,
         relpamtip  like igbmparam.relpamtip,
         relpamtxt  like igbmparam.relpamtxt
  end record
  
  define l_err  integer ,
         l_msg  char(50)
         
  if m_ctd30g00_prep is null or
     m_ctd30g00_prep != true then
     call ctd30g00_prepare()
  end if
  
  initialize l_retorno.* to null
  
  whenever error continue
  open  c_sel_igbm using l_param.relsgl, l_param.relpamseq, l_param.relpamtip
  fetch c_sel_igbm into  l_retorno.relpamseq , l_retorno.relpamtip ,
                         l_retorno.relpamtxt
                         
  let l_err = sqlca.sqlcode
  whenever error stop
  
  close c_sel_igbm
  
  if l_param.nivel_retorno = 1
     then
     return l_err, l_retorno.relpamtxt
  end if
   
end function

#----------------------------------------------------------------
function ctd30g00_sel_igbm_whe(l_param)
#----------------------------------------------------------------

  define l_param record
         nivel_retorno  smallint                ,
         relsgl         like igbmparam.relsgl   ,
         relpamseq      like igbmparam.relpamseq,
         relpamtip      like igbmparam.relpamtip,
         wherecond      char(100)
  end record
  
  define l_retorno record
         relpamseq  like igbmparam.relpamseq,
         relpamtip  like igbmparam.relpamtip,
         relpamtxt  like igbmparam.relpamtxt
  end record
  
  define l_err  integer ,
         l_msg  char(50),
         l_sql  char(400)
         
  if m_ctd30g00_prep is null or
     m_ctd30g00_prep != true then
     call ctd30g00_prepare()
  end if
  
  initialize l_retorno.*, l_sql to null
  
  if m_banco is null
     then
     let m_banco = 'porto@u18w:'
  end if
  
  let l_sql = ' select relpamseq, relpamtip, relpamtxt ',
              '   from ', m_banco,' igbmparam     ',
              '  where relsgl    = "', l_param.relsgl clipped, '" ',
              '    and relpamseq = ' , l_param.relpamseq,
              '    and relpamtip = ' , l_param.relpamtip,
              l_param.wherecond clipped
  prepare p_sel_igbm_whe from l_sql
  declare c_sel_igbm_whe cursor for p_sel_igbm_whe
  
  whenever error continue
  open  c_sel_igbm_whe
  fetch c_sel_igbm_whe into  l_retorno.relpamseq ,
                             l_retorno.relpamtip ,
                             l_retorno.relpamtxt
  let l_err = sqlca.sqlcode
  whenever error stop
  
  close c_sel_igbm
  
  if l_param.nivel_retorno = 1
     then
     return l_err, l_retorno.relpamtxt
  end if
   
end function

#----------------------------------------------------------------
function ctd30g00_ins_igbm(l_param)
#----------------------------------------------------------------

  define l_param record
         relsgl     like igbmparam.relsgl   ,
         relpamseq  like igbmparam.relpamseq,
         relpamtip  like igbmparam.relpamtip,
         relpamtxt  like igbmparam.relpamtxt
  end record
  
  if m_ctd30g00_prep is null or
     m_ctd30g00_prep != true then
     call ctd30g00_prepare()
  end if
  
  whenever error continue
  execute p_ins_igbm using l_param.relsgl   , l_param.relpamseq, 
                           l_param.relpamtip, l_param.relpamtxt
  whenever error stop

  return sqlca.sqlcode

end function

#----------------------------------------------------------------
function ctd30g00_upd_igbm(l_param)
#----------------------------------------------------------------

  define l_param record
         relsgl     like igbmparam.relsgl   ,
         relpamseq  like igbmparam.relpamseq,
         relpamtip  like igbmparam.relpamtip,
         relpamtxt  like igbmparam.relpamtxt
  end record
  
  if m_ctd30g00_prep is null or
     m_ctd30g00_prep != true then
     call ctd30g00_prepare()
  end if
  
  whenever error continue
  execute p_upd_igbm using l_param.relpamtxt, l_param.relsgl   ,
                           l_param.relpamseq, l_param.relpamtip
  whenever error stop

  return sqlca.sqlcode, sqlca.sqlerrd[3]

end function

#----------------------------------------------------------------
function ctd30g00_del_igbm(l_param)
#----------------------------------------------------------------

  define l_param record
         relsgl     like igbmparam.relsgl   ,
         relpamseq  like igbmparam.relpamseq,
         relpamtip  like igbmparam.relpamtip
  end record
  
  if m_ctd30g00_prep is null or
     m_ctd30g00_prep != true then
     call ctd30g00_prepare()
  end if
  
  whenever error continue
  execute p_del_igbm using l_param.relsgl, l_param.relpamseq, l_param.relpamtip
  whenever error stop

  return sqlca.sqlcode, sqlca.sqlerrd[3]

end function
