#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd12g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 211982                                                     # 
#                  Modulo responsavel pelo acesso a tabela DPAKSOCOR          #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 26/02/2010  Fabio Costa    PSI198404  Obter dados da cidade do prestador    #
# 25/05/2012  Jose Kurihara  PSI-11-19199PR Incluir flag Optante Simples      #
#                                           e nivel retorno 7                 #
#-----------------------------------------------------------------------------#

database porto

define m_ctd12g00_prep smallint

#---------------------------#
function ctd12g00_prepare()
#---------------------------#
   define l_sql char(300)
   let l_sql = " select nomrazsoc, rspnom, dddcod, teltxt, nomgrr, ",
               "        endufd   , endcid, endlgd, endcep, endcepcmp, ",
               "        endbrr   , maides, lgdtip, lgdnum, mpacidcod, ",
               "        muninsnum, succod, pisnum, nitnum, prscootipcod, ",
               "        pcpatvcod ",
               "       ,simoptpstflg ",
               " from dpaksocor ",
               " where pstcoddig = ? "
   prepare pctd12g00001 from l_sql
   declare cctd12g00001 cursor for pctd12g00001
   let l_sql = " select cidnom, ufdcod ",
               " from glakcid ",
               " where cidcod = ? "
   prepare pctd12g00002 from l_sql
   declare cctd12g00002 cursor for pctd12g00002
   let m_ctd12g00_prep = true

end function

#-------------------------------------------------------#
function ctd12g00_dados_pst(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint ,
          pstcoddig        like dpaksocor.pstcoddig
   end record

   define l_resultado   smallint ,
          l_mensagem    char(60) ,
          l_simoptpstflg like dpaksocor.simoptpstflg   # PSI-11-19199 Simples

   define lr_retorno record
          nomrazsoc     like dpaksocor.nomrazsoc,
          rspnom        like dpaksocor.rspnom,
          dddcod        like dpaksocor.dddcod,
          teltxt        like dpaksocor.teltxt,
          nomgrr        like dpaksocor.nomgrr,
          endufd        like dpaksocor.endufd,
          endcid        like dpaksocor.endcid,
          endlgd        like dpaksocor.endlgd,
          endcep        like dpaksocor.endcep,
          endcepcmp     like dpaksocor.endcepcmp,
          endbrr        like dpaksocor.endbrr,
          maides        like dpaksocor.maides,
          lgdtip        like dpaksocor.lgdtip,
          lgdnum        like dpaksocor.lgdnum,
          mpacidcod     like dpaksocor.mpacidcod,
          muninsnum     like dpaksocor.muninsnum,
          succod        like dpaksocor.succod,
          pisnum        like dpaksocor.pisnum,
          nitnum        like dpaksocor.nitnum,
          prscootipcod  like dpaksocor.prscootipcod,
          pcpatvcod     like dpaksocor.pcpatvcod
   end record

   if m_ctd12g00_prep is null or
      m_ctd12g00_prep <> true then
      call ctd12g00_prepare()
   end if

   let l_resultado = null
   let l_mensagem  = null
   let l_simoptpstflg = null
   initialize lr_retorno.* to null

   open cctd12g00001 using lr_param.pstcoddig
   whenever error continue
   fetch cctd12g00001 into lr_retorno.*
                         , l_simoptpstflg
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em dpaksocor"
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a dpaksocor ", sqlca.sqlcode
      end if
   end if
   close cctd12g00001
   if lr_param.nivel_retorno = 1 then
      let lr_retorno.teltxt = lr_retorno.dddcod clipped, " ",lr_retorno.teltxt
      return l_resultado,
             l_mensagem,
             lr_retorno.nomrazsoc,
             lr_retorno.rspnom,
             lr_retorno.teltxt
   end if
   if lr_param.nivel_retorno = 2 then
      return l_resultado,          l_mensagem,
             lr_retorno.nomrazsoc, lr_retorno.nomgrr,
             lr_retorno.endufd   , lr_retorno.endcid,
             lr_retorno.endlgd   , lr_retorno.endcep,
             lr_retorno.endcepcmp, lr_retorno.endbrr,
             lr_retorno.maides   , lr_retorno.lgdtip,
             lr_retorno.lgdnum   , lr_retorno.mpacidcod,
             lr_retorno.muninsnum, lr_retorno.pisnum,
             lr_retorno.nitnum   , lr_retorno.dddcod,
             lr_retorno.teltxt   , lr_retorno.prscootipcod
   end if
   if lr_param.nivel_retorno = 3 then
      return l_resultado, l_mensagem, lr_retorno.succod
   end if
   if lr_param.nivel_retorno = 4
      then
      return l_resultado, l_mensagem,
             lr_retorno.pisnum, lr_retorno.nitnum, lr_retorno.muninsnum
   end if
end function

#-------------------------------------------------------#
function ctd12g00_dados_pst2(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint ,
          pstcoddig        like dpaksocor.pstcoddig
   end record

   define l_sqlca     smallint ,
          l_mensagem  char(60)

   define lr_retorno record
          nomrazsoc     like dpaksocor.nomrazsoc,
          rspnom        like dpaksocor.rspnom,
          dddcod        like dpaksocor.dddcod,
          teltxt        like dpaksocor.teltxt,
          nomgrr        like dpaksocor.nomgrr,
          endufd        like dpaksocor.endufd,
          endcid        like dpaksocor.endcid,
          endlgd        like dpaksocor.endlgd,
          endcep        like dpaksocor.endcep,
          endcepcmp     like dpaksocor.endcepcmp,
          endbrr        like dpaksocor.endbrr,
          maides        like dpaksocor.maides,
          lgdtip        like dpaksocor.lgdtip,
          lgdnum        like dpaksocor.lgdnum,
          mpacidcod     like dpaksocor.mpacidcod,
          muninsnum     like dpaksocor.muninsnum,
          succod        like dpaksocor.succod,
          pisnum        like dpaksocor.pisnum,
          nitnum        like dpaksocor.nitnum,
          prscootipcod  like dpaksocor.prscootipcod,
          pcpatvcod     like dpaksocor.pcpatvcod
   end record

   define l_cidnom  like glakcid.cidnom ,
          l_ufdcod  like glakcid.ufdcod ,
          l_simoptpstflg like dpaksocor.simoptpstflg   # PSI-11-19199 Simples

   if m_ctd12g00_prep is null or
      m_ctd12g00_prep <> true then
      call ctd12g00_prepare()
   end if

   let l_sqlca = 0
   initialize lr_retorno.*, l_mensagem to null
   initialize l_cidnom, l_ufdcod to null
   let l_simoptpstflg = null

   whenever error continue
   open cctd12g00001 using lr_param.pstcoddig
   fetch cctd12g00001 into lr_retorno.*
                         , l_simoptpstflg
   whenever error stop
   let l_sqlca = sqlca.sqlcode
   close cctd12g00001
   if lr_param.nivel_retorno = 2
      then
      return l_sqlca, l_mensagem,
             lr_retorno.nomrazsoc, lr_retorno.nomgrr,
             lr_retorno.endufd   , lr_retorno.endcid,
             lr_retorno.endlgd   , lr_retorno.endcep,
             lr_retorno.endcepcmp, lr_retorno.endbrr,
             lr_retorno.maides   , lr_retorno.lgdtip,
             lr_retorno.lgdnum   , lr_retorno.mpacidcod,
             lr_retorno.muninsnum, lr_retorno.pisnum,
             lr_retorno.nitnum   , lr_retorno.dddcod,
             lr_retorno.teltxt   , lr_retorno.prscootipcod,
             lr_retorno.succod   , lr_retorno.pcpatvcod,
             l_simoptpstflg
   end if
   if lr_param.nivel_retorno = 4
      then
      return l_sqlca, l_mensagem,
             lr_retorno.pisnum, lr_retorno.nitnum, lr_retorno.muninsnum
   end if
   if lr_param.nivel_retorno = 5
      then
      return l_sqlca, l_mensagem, lr_retorno.nomrazsoc
   end if
   if lr_param.nivel_retorno = 6
      then
      whenever error continue
      open cctd12g00002 using lr_retorno.mpacidcod
      fetch cctd12g00002 into l_cidnom, l_ufdcod
      whenever error stop
      close cctd12g00001
      return l_sqlca, l_mensagem,
             lr_retorno.endlgd   , lr_retorno.lgdnum   ,
             lr_retorno.endbrr   , lr_retorno.mpacidcod,
             lr_retorno.endcep   , lr_retorno.maides   ,
             lr_retorno.muninsnum, lr_retorno.pcpatvcod,
             lr_retorno.pisnum   , lr_retorno.succod   ,
             l_cidnom, l_ufdcod
   end if
   if lr_param.nivel_retorno = 7                        # ini PSI-11-19199PR
      then
      return l_sqlca, l_mensagem, lr_retorno.nomrazsoc
           , l_simoptpstflg
   end if                                               # fim PSI-11-19199PR
end function

#----------------------------------------------------------------
function ctd12g00_pst_upd(lr_param)
#----------------------------------------------------------------
  define lr_param record
         campo      char(18) ,
         valor      char(62) ,
         coltype    char(01) ,
         pstcoddig  like dpaksocor.pstcoddig
  end record
  define l_sql char(250)
  if lr_param.campo is null or lr_param.valor is null
     then
     return 99, 0
  end if
  if upshift(lr_param.coltype) = 'A'  # alfanumerico entre aspas
     then
     let lr_param.valor = "'", lr_param.valor clipped , "'"
  end if
  # update generico em dpaksocor
  whenever error continue
  let l_sql = ' update dpaksocor set(',lr_param.campo clipped,') = (',
                                       lr_param.valor clipped,') ',
              ' where pstcoddig = ', lr_param.pstcoddig
  prepare p_upd_pst from l_sql
  whenever error stop
  whenever error continue
  execute p_upd_pst
  whenever error stop
  return sqlca.sqlcode, sqlca.sqlerrd[3]
end function

