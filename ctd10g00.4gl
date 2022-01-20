#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd10g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 211982                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA dattfrotalocal       #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

define m_ctd10g00_prep smallint

#---------------------------#
function ctd10g00_prepare()
#---------------------------#
   define l_sql_stmt  char(1000)
   
   let l_sql_stmt = " select srrcoddig, cttdat, ctthor,  ",
                    "        atlemp,    atlmat, atlusrtip ",
                    " from dattfrotalocal ",
                    " where socvclcod = ?  "

   prepare pctd10g00001 from l_sql_stmt
   declare cctd10g00001 cursor for pctd10g00001   
   
   let m_ctd10g00_prep = true

end function

#-------------------------------------------------------#
function ctd10g00_dados_frotalocal(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,socvclcod        like dattfrotalocal.socvclcod
   end record


   define l_resultado   smallint,
          l_mensagem    char(60)

   define lr_retorno  record
          srrcoddig   like dattfrotalocal.srrcoddig,
          cttdat      like dattfrotalocal.cttdat,
          ctthor      like dattfrotalocal.ctthor,
          atlemp      like dattfrotalocal.atlemp,
          atlmat      like dattfrotalocal.atlmat,
          atlusrtip   like dattfrotalocal.atlusrtip
          end record

   if m_ctd10g00_prep is null or
      m_ctd10g00_prep <> true then
      call ctd10g00_prepare()
   end if  

   let l_resultado = null
   let l_mensagem  = null
   initialize lr_retorno.* to null

   open cctd10g00001 using lr_param.socvclcod
   
   whenever error continue
   fetch cctd10g00001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2                                  
         let l_mensagem = "Nao achou dados em dattfrotalocal"
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a dattfrotalocal ", sqlca.sqlcode
      end if
   end if

   close cctd10g00001

   if lr_param.nivel_retorno = 1 then
      return l_resultado,
             l_mensagem,
             lr_retorno.srrcoddig,
             lr_retorno.cttdat,
             lr_retorno.ctthor,
             lr_retorno.atlemp,
             lr_retorno.atlmat,
             lr_retorno.atlusrtip
   end if
   if lr_param.nivel_retorno = 2 then
      return l_resultado,
             l_mensagem,
             lr_retorno.srrcoddig
   end if
   
   
end function
