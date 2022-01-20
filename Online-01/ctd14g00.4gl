#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd14g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........:                                                            #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datrligapol          #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

define m_ctd14g00_prep smallint

#---------------------------#
function ctd14g00_prepare()
#---------------------------#
   define l_sql_stmt  char(1000)
   let l_sql_stmt = " select succod, ramcod, aplnumdig, itmnumdig, edsnumref ",
                    " from datrligapol ",
                    " where lignum  =  ? "
   prepare pctd14g00001 from l_sql_stmt
   declare cctd14g00001 cursor for pctd14g00001
   let m_ctd14g00_prep = true

end function

#-------------------------------------------------------#
function ctd14g00_apol_lig(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,lignum           like datrligapol.lignum
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   define lr_retorno  record
          succod    like datrligapol.succod,
          ramcod    like datrligapol.ramcod,
          aplnumdig like datrligapol.aplnumdig,
          itmnumdig like datrligapol.itmnumdig,
          edsnumref like datrligapol.edsnumref
          end record

   if m_ctd14g00_prep is null or
      m_ctd14g00_prep <> true then
      call ctd14g00_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null
   initialize lr_retorno.* to null

   open cctd14g00001 using lr_param.lignum
   whenever error continue
   fetch cctd14g00001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em datrligapol"
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a datrligapol ", sqlca.sqlcode
      end if
   end if

   close cctd14g00001

   if lr_param.nivel_retorno = 1 then
      return l_resultado,
             l_mensagem,
             lr_retorno.succod,
             lr_retorno.ramcod,
             lr_retorno.aplnumdig,
             lr_retorno.itmnumdig,
             lr_retorno.edsnumref
   end if
end function
