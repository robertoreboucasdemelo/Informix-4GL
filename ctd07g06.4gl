#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd07g06                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI............: 211982                                                     #
# OBJETIVO.......: Insere os dados de servicos multiplos para vincular ao     #
#                  servico original                                           #
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

define m_ctd07g06_prep smallint

#---------------------------#
function ctd07g06_prepare()
#---------------------------#
   define l_sql_stmt  char(500)

   let l_sql_stmt = "insert into datratdmltsrv "
                   ," (atdsrvnum, atdsrvano, atdmltsrvnum, atdmltsrvano) "
                   ," values "
                   ," (?, ?, ?, ?) "
   prepare pctd07g06001 from l_sql_stmt
   
   let m_ctd07g06_prep = true
end function

#-------------------------------------#
function ctd07g06_insere_mlt(lr_param)
#-------------------------------------#
   define lr_param           record
          atdsrvnum_original like datratdmltsrv.atdsrvnum
         ,atdsrvano_original like datratdmltsrv.atdsrvano
         ,atdsrvnum_multiplo like datratdmltsrv.atdmltsrvnum
         ,atdsrvano_multiplo like datratdmltsrv.atdmltsrvano
   end record

   define lr_retorno       record
             resultado     smallint
            ,mensagem      char(60)
   end record

   if m_ctd07g06_prep is null or
      m_ctd07g06_prep <> true then
      call ctd07g06_prepare()
   end if
   
   initialize lr_retorno to null
   let lr_retorno.resultado  = 1
  
   whenever error continue
   execute pctd07g06001 using lr_param.atdsrvnum_original
                             ,lr_param.atdsrvano_original
                             ,lr_param.atdsrvnum_multiplo
                             ,lr_param.atdsrvano_multiplo
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.resultado = 3
      let lr_retorno.mensagem = "Erro ", sqlca.sqlcode, " na inclusao do servico multiplo"
   end if
    
   return lr_retorno.resultado
         ,lr_retorno.mensagem 
end function
