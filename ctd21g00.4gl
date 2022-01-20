#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd21g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 198404                                                     #
#                  Modulo responsavel pelo acesso a tabela DATKLOCADORA       #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#
database porto

define m_ctd21g00_prep smallint

#---------------------------#
function ctd21g00_prepare()
#---------------------------#
   define l_sql_stmt  char(1000)
   
   let l_sql_stmt = " select lcvnom, dddcod, teltxt, endufd, ",
                    "        cidnom, lgdnom, brrnom, maides ",
                    " from datklocadora ",
                    " where lcvcod = ? "
                    
   prepare pctd21g00001 from l_sql_stmt
   declare cctd21g00001 cursor for pctd21g00001   
   
   let m_ctd21g00_prep = true

end function

#-------------------------------------------------------#
function ctd21g00_dados_loc(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,lcvcod        like datklocadora.lcvcod
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   define lr_retorno  record
          lcvnom      like datklocadora.lcvnom,
          dddcod      like datklocadora.dddcod,
          teltxt      like datklocadora.teltxt,
          endufd      like datklocadora.endufd,
          cidnom      like datklocadora.cidnom,
          lgdnom      like datklocadora.lgdnom, 
          brrnom      like datklocadora.brrnom,
          maides      like datklocadora.maides
          end record

   if m_ctd21g00_prep is null or
      m_ctd21g00_prep <> true then
      call ctd21g00_prepare()
   end if  

   let l_resultado = null
   let l_mensagem  = null
   initialize lr_retorno.* to null

   open cctd21g00001 using lr_param.lcvcod
   
   whenever error continue
   fetch cctd21g00001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2                                  
         let l_mensagem = "Nao achou dados em datklocadora"
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a datklocadora ", sqlca.sqlcode
      end if
   end if

   close cctd21g00001

   if lr_param.nivel_retorno = 1 then
      return l_resultado,
             l_mensagem,
             lr_retorno.lcvnom,
             lr_retorno.dddcod,
             lr_retorno.teltxt,
             lr_retorno.endufd,
             lr_retorno.cidnom,
             lr_retorno.lgdnom,
             lr_retorno.brrnom,
             lr_retorno.maides
   end if

end function

