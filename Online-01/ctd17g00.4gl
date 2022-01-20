#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd17g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........:                                                            #
# MODULO RESPONSA. PELO ACESSO A TABELA datkmdt e datrmdtbotprg               #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

define m_ctd17g00_prep smallint

#---------------------------#
function ctd17g00_prepare()
#---------------------------#
   define l_sql_stmt  char(1000)
   let l_sql_stmt = " select mdtbotprgseq ",
                    " from datkmdt a, datrmdtbotprg b ",
                    " where a.mdtprgcod  = b.mdtprgcod ",
                    " and a.mdtcod = ? ",
                    " and b.mdtbotcod = ? "
   prepare pctd17g00001 from l_sql_stmt
   declare cctd17g00001 cursor for pctd17g00001
   let m_ctd17g00_prep = true

end function

#-------------------------------------------------------#
function ctd17g00_dados_botao(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint,
          mdtcod           like datkmdt.mdtcod,
          mdtbotcod        like datrmdtbotprg.mdtbotcod
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   define lr_retorno  record
          mdtbotprgseq like datrmdtbotprg.mdtbotprgseq
          end record

   if m_ctd17g00_prep is null or
      m_ctd17g00_prep <> true then
      call ctd17g00_prepare()
   end if

   let l_resultado = null
   let l_mensagem  = null
   initialize lr_retorno.* to null

   open cctd17g00001 using lr_param.mdtcod, lr_param.mdtbotcod
   whenever error continue
   fetch cctd17g00001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em datrmdtbotprg"
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a datrmdtbotprg ", sqlca.sqlcode
      end if
   end if

   close cctd17g00001

   if lr_param.nivel_retorno = 1 then
      return l_resultado,
             l_mensagem,
             lr_retorno.mdtbotprgseq
   end if
end function
