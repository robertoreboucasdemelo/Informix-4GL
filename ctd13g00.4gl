#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd13g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........:                                                            #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datkvcleqp          #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

define m_ctd13g00_prep smallint

#---------------------------#
function ctd13g00_prepare()
#---------------------------#
   define l_sql_stmt  char(1000)
   let l_sql_stmt = " select eqpacndst, eqpimsvlr ",
                    " from datkvcleqp ",
                    " where soceqpcod  =  ? "
   prepare pctd13g00001 from l_sql_stmt
   declare cctd13g00001 cursor for pctd13g00001
   let m_ctd13g00_prep = true

end function

#-------------------------------------------------------#
function ctd13g00_dados_eqp(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,soceqpcod        like datkvcleqp.soceqpcod
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   define lr_retorno  record
          eqpacndst   like datkvcleqp.eqpacndst,
          eqpimsvlr   like datkvcleqp.eqpimsvlr
          end record

   if m_ctd13g00_prep is null or
      m_ctd13g00_prep <> true then
      call ctd13g00_prepare()
   end if

   let l_resultado = null
   let l_mensagem  = null
   initialize lr_retorno.* to null

   open cctd13g00001 using lr_param.soceqpcod
   whenever error continue
   fetch cctd13g00001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em datkvcleqp"
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a datkvcleqp ", sqlca.sqlcode
      end if
   end if

   close cctd13g00001

   if lr_param.nivel_retorno = 1 then
      return l_resultado,
             l_mensagem,
             lr_retorno.eqpacndst,
             lr_retorno.eqpimsvlr
   end if
end function
