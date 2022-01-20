#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd20g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 198404                                                     #
#                  Modulo responsavel pelo acesso a tabela DBSMOPG            #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

define m_ctd20g00_prep smallint

#---------------------------#
function ctd20g00_prepare()
#---------------------------#
  define l_sql  char(600)
  
  let l_sql = " update dbsmopg set socopgsitcod = ? ", 
              " where socopgnum = ? "
  prepare pctd20g00001 from l_sql
  
  let l_sql = " select socopgnum from dbsmopg ", 
              " where socfatpgtdat between ? and ? ",
              " and pstcoddig = ? ",
              " and socopgsitcod  < 6 "
  prepare pctd20g00002 from l_sql
  declare cctd20g00002 cursor for pctd20g00002
  
  let l_sql = ' select socopgnum   , pstcoddig   , segnumdig   , corsus      ,',
              '        socfatentdat, socfatpgtdat, socfatitmqtd, socfatrelqtd,',
              '        socfattotvlr, empcod      , cctcod      , pestip      ,',
              '        cgccpfnum   , cgcord      , cgccpfdig   , socopgdscvlr,',
              '        socopgsitcod, atldat      , funmat      , soctrfcod   ,',
              '        succod      , socpgtdsctip, socpgtdoctip, socemsnfsdat,',
              '        pgtdstcod   , socopgorgcod, soctip      , lcvcod      ,',
              '        aviestcod ',
              ' from dbsmopg ',
              ' where socopgnum = ? '
  prepare p_opg_sel from l_sql
  declare c_opg_sel cursor with hold for p_opg_sel
  
  let m_ctd20g00_prep = true

end function

#-------------------------------------------------------#
function ctd20g00_upd_opg(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          socopgnum        like dbsmopg.socopgnum,
          socopgsitcod     like dbsmopg.socopgsitcod
   end record
   
   if m_ctd20g00_prep is null or
      m_ctd20g00_prep <> true then
      call ctd20g00_prepare()
   end if  
   
   whenever error continue
   execute pctd20g00001 using lr_param.socopgsitcod, lr_param.socopgnum
   whenever error stop
   
   return sqlca.sqlcode, sqlca.sqlerrd[3]
   
end function

#-------------------------------------------------------#
function ctd20g00_sel_op(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          datai            date,
          dataf            date,
          pstcoddig        like dbsmopg.pstcoddig
   end record

   define l_resultado   smallint,
          l_mensagem    char(60),
          l_socopgnum   like dbsmopg.socopgnum

   if m_ctd20g00_prep is null or
      m_ctd20g00_prep <> true then
      call ctd20g00_prepare()
   end if  

   let l_resultado  = 1
   let l_mensagem   = null
   let l_socopgnum  = null

   whenever error continue
   open cctd20g00002 using lr_param.datai, lr_param.dataf, lr_param.pstcoddig
   fetch cctd20g00002 into l_socopgnum
   whenever error stop

   if sqlca.sqlcode = 0 then
      let l_resultado = 1
      let l_mensagem = ""
   else
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou OP neste periodo para o prestador"
      else
         let l_resultado = 3
         let l_mensagem = "Erro na atualizacao de dbsmopg ", sqlca.sqlcode
      end if
   end if

   close cctd20g00002
   return l_resultado, l_mensagem, l_socopgnum
 
end function

#----------------------------------------------------------------
function ctd20g00_sel_opg_chave(l_param)
#----------------------------------------------------------------
  
  define l_param record
         nivel_retorno  smallint ,
         socopgnum      like dbsmopg.socopgnum
  end record
  
  define l_dbsmopg record
         socopgnum     like dbsmopg.socopgnum    ,
         pstcoddig     like dbsmopg.pstcoddig    ,
         segnumdig     like dbsmopg.segnumdig    ,
         corsus        like dbsmopg.corsus       ,
         socfatentdat  like dbsmopg.socfatentdat ,
         socfatpgtdat  like dbsmopg.socfatpgtdat ,
         socfatitmqtd  like dbsmopg.socfatitmqtd ,
         socfatrelqtd  like dbsmopg.socfatrelqtd ,
         socfattotvlr  like dbsmopg.socfattotvlr ,
         empcod        like dbsmopg.empcod       ,
         cctcod        like dbsmopg.cctcod       ,
         pestip        like dbsmopg.pestip       ,
         cgccpfnum     like dbsmopg.cgccpfnum    ,
         cgcord        like dbsmopg.cgcord       ,
         cgccpfdig     like dbsmopg.cgccpfdig    ,
         socopgdscvlr  like dbsmopg.socopgdscvlr ,
         socopgsitcod  like dbsmopg.socopgsitcod ,
         atldat        like dbsmopg.atldat       ,
         funmat        like dbsmopg.funmat       ,
         soctrfcod     like dbsmopg.soctrfcod    ,
         succod        like dbsmopg.succod       ,
         socpgtdsctip  like dbsmopg.socpgtdsctip ,
         socpgtdoctip  like dbsmopg.socpgtdoctip ,
         socemsnfsdat  like dbsmopg.socemsnfsdat ,
         pgtdstcod     like dbsmopg.pgtdstcod    ,
         socopgorgcod  like dbsmopg.socopgorgcod ,
         soctip        like dbsmopg.soctip       ,
         lcvcod        like dbsmopg.lcvcod       ,
         aviestcod     like dbsmopg.aviestcod
  end record
  
  define l_ret integer, l_msg char(60)
  
  initialize l_dbsmopg.* to null
  let l_ret = 0
  
  if l_param.nivel_retorno is null or
     l_param.nivel_retorno <= 0
     then
     let l_ret = 999
     let l_msg = 'Erro no envio de parametros'
     return l_ret, l_msg, l_dbsmopg.*
  end if
  
  if m_ctd20g00_prep is null or
     m_ctd20g00_prep <> true then
     call ctd20g00_prepare()
  end if
  
  whenever error continue
  open c_opg_sel using l_param.socopgnum
  fetch c_opg_sel into l_dbsmopg.*
  whenever error stop
  
  let l_ret = sqlca.sqlcode
  
  close c_opg_sel
  
  if l_param.nivel_retorno = 1
     then
     return l_ret, l_msg, l_dbsmopg.socopgsitcod
  end if
  
  if l_param.nivel_retorno = 2
     then
     return l_ret, l_msg, l_dbsmopg.pstcoddig, l_dbsmopg.segnumdig,
                          l_dbsmopg.lcvcod   , l_dbsmopg.aviestcod,
                          l_dbsmopg.succod   , l_dbsmopg.soctip
  end if
  
end function
