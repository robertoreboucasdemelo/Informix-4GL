#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd08g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI............: 211982                                                     #
# OBJETIVO.......: Obter dados do tipo de assistencia (datkasitip) de acordo  #
#                  com o nivel de retorno                                     #
# ........................................................................... #
# DESENVOLVIMENTO: Luciano Lopes, META                                        #
# LIBERACAO......: 18/09/2007                                                 #
# ........................................................................... #
#                                                                             #
#                          * * * ALTERACOES * * *                             #
#                                                                             #
# DATA       AUTOR FABRICA      ORIGEM     ALTERACAO                          #
# ---------- ------------------ ---------- -----------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
database porto                                                                 

define m_ctd08g00_prep smallint

#---------------------------#
function ctd08g00_prepare()
#---------------------------#
   define l_sql_stmt  char(500)

   let l_sql_stmt = " select asitipabvdes   " 
                   ,"   from datkasitip     "
                   ,"   where asitipcod = ? "

   prepare pctd08g00001 from l_sql_stmt
   declare cctd08g00001 cursor for pctd08g00001
   
   let m_ctd08g00_prep = true
end function

#---------------------------#
function ctd08g00_dados_assist(lr_param)
#---------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,asitipcod        like datkasitip.asitipcod
   end record
   
   define lr_retorno       record
             resultado     smallint
            ,mensagem      char(60)
            ,asitipabvdes  like datkasitip.asitipabvdes
   end record

   if m_ctd08g00_prep is null or
      m_ctd08g00_prep <> true then
      call ctd08g00_prepare()
   end if
   
   initialize lr_retorno to null
   let lr_retorno.resultado  = 1
  
   open cctd08g00001 using lr_param.asitipcod

   whenever error continue
   fetch cctd08g00001 into lr_retorno.asitipabvdes
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.resultado = 2
         let lr_retorno.mensagem = "Nao achou tipo de assistencia cadastrado: ", lr_param.asitipcod
      else
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem = "Erro no acesso a tabela datkasitip: ", sqlca.sqlcode
      end if
   end if
   
   case lr_param.nivel_retorno
      when 1                                           
           return lr_retorno.resultado
                 ,lr_retorno.mensagem
                 ,lr_retorno.asitipabvdes
   end case
end function
