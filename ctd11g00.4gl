#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd11g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 211982                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datrsrrpst           #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

define m_ctd11g00_prep smallint

#---------------------------#
function ctd11g00_prepare()
#---------------------------#
   define l_sql_stmt  char(1000)
   let l_sql_stmt = " select pstcoddig, viginc ",
                    " from datrsrrpst ",
                    " where datrsrrpst.srrcoddig  =  ? ",
                    " order by viginc desc "
   prepare pctd11g00001 from l_sql_stmt
   declare cctd11g00001 cursor for pctd11g00001
   let m_ctd11g00_prep = true

end function

#-------------------------------------------------------#
function ctd11g00_inf_socor(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,srrcoddig        like datrsrrpst.srrcoddig
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   define lr_retorno  record
          pstcoddig   like datrsrrpst.pstcoddig,
          viginc      like datrsrrpst.viginc
          end record

   if m_ctd11g00_prep is null or
      m_ctd11g00_prep <> true then
      call ctd11g00_prepare()
   end if

   let l_resultado = null
   let l_mensagem  = null
   initialize lr_retorno.* to null

   open cctd11g00001 using lr_param.srrcoddig
   whenever error continue
   fetch cctd11g00001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em datrsrrpst"
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a datrsrrpst ", sqlca.sqlcode
      end if
   end if

   close cctd11g00001

   if lr_param.nivel_retorno = 1 then
      return l_resultado,
             l_mensagem,
             lr_retorno.pstcoddig
   end if

   if lr_param.nivel_retorno = 2 then
      return l_resultado,
             l_mensagem,
             lr_retorno.pstcoddig,
             lr_retorno.viginc
   end if
end function
