#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd19g02                                                   #
# ANALISTA RESP..: Fabio Costa                                                #
# PSI/OSF........: 198404                                                     #
#                  Modulo responsavel pelo acesso a tabela DATKLCVFAV         #
#                  (favorecidos da locadora)                                  #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#
database porto

define m_ctd19g02_prep smallint

#---------------------------#
function ctd19g02_prepare()
#---------------------------#
   define l_sql char(300)
   
   let l_sql = ' select favnom    , pestip    , cgccpfnum , cgcord    , ',
               '        cgccpfdig , bcocod    , bcoagnnum , bcoagndig , ',
               '        bcoctatip , bcoctanum , bcoctadig , pgtopccod , ',
               '        mncinscod ',
               ' from datklcvfav ',
               ' where lcvcod    = ? ',
               '   and aviestcod = ? '
   prepare p_lcvfav_sel from l_sql
   declare c_lcvfav_sel cursor with hold for p_lcvfav_sel   
   
   let m_ctd19g02_prep = true

end function

#----------------------------------------------------------------
function ctd19g02_lcvfav_sel(lr_param)
#----------------------------------------------------------------

   define lr_param record
          nivel_retorno  smallint ,
          lcvcod         like datkavislocal.lcvcod ,
          aviestcod      like datkavislocal.aviestcod
   end record
   
   define l_retorno record
          favnom     like  datklcvfav.favnom    ,
          pestip     like  datklcvfav.pestip    ,
          cgccpfnum  like  datklcvfav.cgccpfnum ,
          cgcord     like  datklcvfav.cgcord    ,
          cgccpfdig  like  datklcvfav.cgccpfdig ,
          bcocod     like  datklcvfav.bcocod    ,
          bcoagnnum  like  datklcvfav.bcoagnnum ,
          bcoagndig  like  datklcvfav.bcoagndig ,
          bcoctatip  like  datklcvfav.bcoctatip ,
          bcoctanum  like  datklcvfav.bcoctanum ,
          bcoctadig  like  datklcvfav.bcoctadig ,
          pgtopccod  like  datklcvfav.pgtopccod ,
          mncinscod  like  datklcvfav.mncinscod
   end record
   
   define l_err  integer ,
          l_msg  char(50)
          
   if m_ctd19g02_prep is null or
      m_ctd19g02_prep <> true then
      call ctd19g02_prepare()
   end if
   
   initialize l_retorno.* to null
   
   whenever error continue
   open  c_lcvfav_sel using lr_param.lcvcod, lr_param.aviestcod 
   fetch c_lcvfav_sel into l_retorno.favnom    ,
                           l_retorno.pestip    ,
                           l_retorno.cgccpfnum ,
                           l_retorno.cgcord    ,
                           l_retorno.cgccpfdig ,
                           l_retorno.bcocod    ,
                           l_retorno.bcoagnnum ,
                           l_retorno.bcoagndig ,
                           l_retorno.bcoctatip ,
                           l_retorno.bcoctanum ,
                           l_retorno.bcoctadig ,
                           l_retorno.pgtopccod ,
                           l_retorno.mncinscod
   whenever error stop               
   
   let l_err = sqlca.sqlcode
   
   if lr_param.nivel_retorno = 1
      then
      return l_err, l_retorno.mncinscod
   end if
   
   return l_err, l_retorno.*

end function

#----------------------------------------------------------------
function ctd19g02_lcvfav_upd(lr_param)
#----------------------------------------------------------------
  define lr_param record
         campo      char(18) ,
         valor      char(62) ,
         coltype    char(01) ,
         lcvcod     like datklcvfav.lcvcod ,
         aviestcod  like datklcvfav.aviestcod
  end record
  
  define l_sql char(300)
  
  if lr_param.campo is null or lr_param.valor is null
     then
     return 99, 0
  end if
  
  if lr_param.coltype = 'A'  # alfanumerico entre aspas
     then
     let lr_param.valor = "'", lr_param.valor clipped , "'"
  end if
  
  # update generico em datklcvfav
  whenever error continue
  let l_sql = ' update datklcvfav set (',lr_param.campo clipped,') = (',
                                         lr_param.valor clipped,') ' ,
              ' where lcvcod    = ' , lr_param.lcvcod,
              '   and aviestcod = ' , lr_param.aviestcod             
  prepare p_upd_lcvfav from l_sql
  whenever error stop
  
  whenever error continue
  execute p_upd_lcvfav
  whenever error stop
  
  return sqlca.sqlcode, sqlca.sqlerrd[3]
  
end function

