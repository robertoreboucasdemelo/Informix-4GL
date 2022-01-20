#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd16g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........:                                                            #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datkmdtbot          #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

define m_ctd16g00_prep smallint

#---------------------------#
function ctd16g00_prepare()
#---------------------------#
   define l_sql_stmt  char(1000)
   let l_sql_stmt = " select mdtbotcod ",
                    " from datkmdtbot ",
                    " where mdtbottxt[1,3]  =  ? ",
                    " or mdtbottxt[5,7]  =  ? " ##para QRU RECEB (REC)
   prepare pctd16g00001 from l_sql_stmt
   declare cctd16g00001 cursor for pctd16g00001
   let m_ctd16g00_prep = true

end function

#-------------------------------------------------------#
function ctd16g00_dados_botao(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,mdtbottxt        char(3) ##like datkmdtbot.mdtbottxt
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   define lr_retorno  record
          mdtbotcod   like datkmdtbot.mdtbotcod
          end record

   if m_ctd16g00_prep is null or
      m_ctd16g00_prep <> true then
      call ctd16g00_prepare()
   end if

   let l_resultado = null
   let l_mensagem  = null
   initialize lr_retorno.* to null

   open cctd16g00001 using lr_param.mdtbottxt, lr_param.mdtbottxt
   whenever error continue
   fetch cctd16g00001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em datkmdtbot"
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a datkmdtbot ", sqlca.sqlcode
      end if
   end if

   close cctd16g00001

   if lr_param.nivel_retorno = 1 then
      return l_resultado,
             l_mensagem,
             lr_retorno.mdtbotcod
   end if
end function
