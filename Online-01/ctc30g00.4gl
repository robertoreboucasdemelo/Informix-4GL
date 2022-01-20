# Porto Seguro Cia Seguros Gerais                                            #    
#............................................................................#    
# Sistema........: Porto Socorro                                             #    
# Modulo.........: ctc30g00                                                  #    
# Objetivo.......: Obter o tipo de acionamento/email da locadora             #    
# Analista Resp. : Ligia Mattge                                              #    
# PSI            : 196878                                                    #    
#............................................................................#    
# Desenvolvimento: Andrei, META                                              #    
# Liberacao      : 21/02/2006                                                #    
#............................................................................#    
#                  * * *  ALTERACOES  * * *                                  #    
#                                                                            #    
# Data       Autor Fabrica PSI       Alteracao                               #    
# --------   ------------- ------    ----------------------------------------#    
#                                                                            #    
#----------------------------------------------------------------------------#    

database porto

 define m_prep_sql smallint
 
#--------------------------
function ctc30g00_prepare()
#--------------------------

 define  l_sql char(500)
 
 let l_sql = 'select lcvresenvcod, acntip, ' 
            ,'       maides, adcsgrtaxvlr, lcvnom  '
            ,'  from datklocadora '
            ,' where lcvcod = ? '
            
 prepare pctc30g00001 from l_sql
 declare cctc30g00001 cursor for pctc30g00001 
 
 let m_prep_sql = true
 
end function

#--------------------------------------
function ctc30g00_dados_loca(lr_param)
#--------------------------------------
 
 define lr_param record 
                 nvlretorno smallint
                ,lcvcod     like datklocadora.lcvcod
             end record
             
 define lr_retorno record
                   lcvresenvcod like datklocadora.lcvresenvcod 
                  ,acntip       like datklocadora.acntip       
                  ,maides       like datklocadora.maides       
                  ,adcsgrtaxvlr like datklocadora.adcsgrtaxvlr 
                  ,resultado    smallint
                  ,mensagem     char(080)
                  ,lcvnom       like datklocadora.lcvnom
               end record

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctc30g00_prepare()
 end if 
    
 initialize lr_retorno to null
 
 let lr_retorno.resultado = 1
 
    open cctc30g00001 using lr_param.lcvcod
    whenever error continue
    fetch cctc30g00001 into lr_retorno.lcvresenvcod
                           ,lr_retorno.acntip      
                           ,lr_retorno.maides      
                           ,lr_retorno.adcsgrtaxvlr
                           ,lr_retorno.lcvnom
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2 
          let lr_retorno.mensagem  = 'Dados da locadora nao encontrado' 
       else
          let lr_retorno.resultado = 3 
          let lr_retorno.mensagem  = 'Erro SELECT cctc30g00001 ', sqlca.sqlcode, '/', sqlca.sqlerrd[2]
                                   , 'ctc30g00_dados_loca()'
       end if
    end if

 if lr_param.nvlretorno = 1 then
    return lr_retorno.resultado 
          ,lr_retorno.mensagem
          ,lr_retorno.acntip
          ,lr_retorno.lcvresenvcod              
          ,lr_retorno.maides      
 end if  
 
 if lr_param.nvlretorno = 2 then
     return lr_retorno.resultado 
           ,lr_retorno.mensagem  
           ,lr_retorno.adcsgrtaxvlr
 end if 

 if lr_param.nvlretorno = 3 then
    return lr_retorno.resultado 
          ,lr_retorno.mensagem
          ,lr_retorno.lcvnom
 end if  

end function
