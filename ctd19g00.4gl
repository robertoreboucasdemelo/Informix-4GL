#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd19g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 198404                                                     #
#                  Modulo responsavel pelo acesso a tabela DATKAVISLOCAL      #
#                  (lojas da locadora)                                        #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 25/05/2009 Fabio Costa     PSI 198404 Buscar dados cadastrais da loja       #
#-----------------------------------------------------------------------------#

database porto

define m_ctd19g00_prep smallint

#---------------------------#
function ctd19g00_prepare()
#---------------------------#
   define l_sql_stmt  char(400)
   let l_sql_stmt = " select succod ",
                    " from datkavislocal ",
                    " where lcvcod    = ? ",
                    "   and aviestcod = ? "
   prepare pctd19g00001 from l_sql_stmt
   declare cctd19g00001 cursor with hold for pctd19g00001
   let l_sql_stmt = " select f.favnom   , d.endlgd, d.endbrr   , d.endcep, ",
                    "        d.endcepcmp, d.endcid, d.endufd   , d.dddcod, ",
                    "        d.teltxt   , d.maides, f.mncinscod, d.succod ",
                    " from datkavislocal d, datklcvfav f ",
                    " where d.lcvcod    = f.lcvcod ",
                    "   and d.aviestcod = f.aviestcod ",
                    "   and d.lcvcod    = ? ",
                    "   and d.aviestcod = ? "
   prepare p_end_fav_sel from l_sql_stmt
   declare c_end_fav_sel cursor with hold for p_end_fav_sel
   let l_sql_stmt = ' select l.lcvnom, a.aviestnom, a.lcvextcod ',
                    ' from datklocadora l, datkavislocal a ',
                    ' where l.lcvcod    = a.lcvcod ',
                    '   and a.lcvcod    = ? ',
                    '   and a.aviestcod = ? '
   prepare p_nome_loc_loja_sel from l_sql_stmt
   declare c_nome_loc_loja_sel cursor for p_nome_loc_loja_sel
   let m_ctd19g00_prep = true

end function

#-------------------------------------------------------#
function ctd19g00_dados_loja(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,lcvcod           like datkavislocal.lcvcod
         ,aviestcod        like datkavislocal.aviestcod
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   define lr_retorno  record
          succod      like datkavislocal.succod
          end record

   if m_ctd19g00_prep is null or
      m_ctd19g00_prep <> true then
      call ctd19g00_prepare()
   end if

   let l_resultado = null
   let l_mensagem  = null
   initialize lr_retorno.* to null

   open cctd19g00001 using lr_param.lcvcod, lr_param.aviestcod
   whenever error continue
   fetch cctd19g00001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em datkavislocal"
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a datkavislocal ", sqlca.sqlcode
      end if
   end if

   close cctd19g00001

   if lr_param.nivel_retorno = 1 then
      return l_resultado,
             l_mensagem,
             lr_retorno.succod
   end if

end function


#----------------------------------------------------------------
function ctd19g00_ender_fav_loja(lr_param)
#----------------------------------------------------------------

   define lr_param record
          lcvcod     like datkavislocal.lcvcod ,
          aviestcod  like datkavislocal.aviestcod
   end record
   define l_retorno record
          favnom     like datklcvfav.favnom       ,
          endlgd     like datkavislocal.endlgd    ,
          endbrr     like datkavislocal.endbrr    ,
          endcep     like datkavislocal.endcep    ,
          endcepcmp  like datkavislocal.endcepcmp ,
          endcid     like datkavislocal.endcid    ,
          endufd     like datkavislocal.endufd    ,
          dddcod     like datkavislocal.dddcod    ,
          teltxt     like datkavislocal.teltxt    ,
          maides     like datkavislocal.maides    ,
          mncinscod  like datklcvfav.mncinscod    ,
          succod     like datkavislocal.succod
   end record
   define l_err  integer ,
          l_msg  char(50)
   if m_ctd19g00_prep is null or
      m_ctd19g00_prep <> true then
      call ctd19g00_prepare()
   end if
   whenever error continue
   open c_end_fav_sel using lr_param.lcvcod, lr_param.aviestcod
   fetch c_end_fav_sel into l_retorno.favnom    ,
                            l_retorno.endlgd    ,
                            l_retorno.endbrr    ,
                            l_retorno.endcep    ,
                            l_retorno.endcepcmp ,
                            l_retorno.endcid    ,
                            l_retorno.endufd    ,
                            l_retorno.dddcod    ,
                            l_retorno.teltxt    ,
                            l_retorno.maides    ,
                            l_retorno.mncinscod ,
                            l_retorno.succod
   whenever error stop
   let l_err = sqlca.sqlcode
   return l_err, l_retorno.*

end function


#----------------------------------------------------------------
function ctd19g00_nome_loja(lr_param)
#----------------------------------------------------------------

   define lr_param record
          lcvcod     like datkavislocal.lcvcod ,
          aviestcod  like datkavislocal.aviestcod
   end record
   define l_retorno record
          lcvnom     like datklocadora.lcvnom     ,
          aviestnom  like datkavislocal.aviestnom ,
          lcvextcod  like datkavislocal.lcvextcod
   end record
   define l_err  integer ,
          l_msg  char(50)
   if m_ctd19g00_prep is null or
      m_ctd19g00_prep <> true
      then
      call ctd19g00_prepare()
   end if
   whenever error continue
   open c_nome_loc_loja_sel using lr_param.lcvcod, lr_param.aviestcod
   fetch c_nome_loc_loja_sel into l_retorno.lcvnom   ,
                                  l_retorno.aviestnom,
                                  l_retorno.lcvextcod
   whenever error stop
   let l_err = sqlca.sqlcode
   if l_err != 0
      then
      let l_msg = 'Erro na selecao da Loja/Locadora: ', l_err
   end if
   return l_err, l_msg, l_retorno.*

end function

