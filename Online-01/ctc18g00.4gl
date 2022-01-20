# Porto Seguro Cia Seguros Gerais                                            #     
#............................................................................#     
# Sistema........: Porto Socorro                                             #     
# Modulo.........: ctc18g00                                                  #     
# Objetivo.......: Obter dados da loja                                       #     
# Analista Resp. : Ligia Mattge                                              #     
# PSI            : 196878                                                    #     
#............................................................................#     
# Desenvolvimento: Andrei, META                                              #     
# Liberacao      : 22/02/2006                                                #     
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
function ctc18g00_prepare()
#--------------------------

 define l_sql char(500)

 let l_sql = null

 let l_sql = 'select lcvextcod, aviestnom, '
            ,'       lcvregprccod, maides '
            ,'  from datkavislocal '
            ,' where lcvcod = ? '
            ,'   and aviestcod = ? '
            
 prepare pctc18g00001 from l_sql 
 declare cctc18g00001 cursor for pctc18g00001
 
 let m_prep_sql = true
 
end function

#-------------------------------------
function ctc18g00_dados_loja(lr_param)
#-------------------------------------

 define lr_param record
                 nvlretorno
                ,lcvcod     like datkavislocal.lcvcod   
                ,aviestcod  like datkavislocal.aviestcod
             end record
             
 define lr_retorno record
                   resultado     smallint
                  ,mensagem      char(080)
                  ,lcvextcod     like datkavislocal.lcvextcod   
                  ,aviestnom     like datkavislocal.aviestnom   
                  ,lcvregprccod  like datkavislocal.lcvregprccod
                  ,maides        like datkavislocal.maides      
               end record
               
 initialize lr_retorno to null
 
 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctc18g00_prepare()
 end if    
 
 let lr_retorno.resultado = 1
 
    open cctc18g00001 using lr_param.lcvcod   
                           ,lr_param.aviestcod
    whenever error continue
    fetch cctc18g00001 into lr_retorno.lcvextcod   
                           ,lr_retorno.aviestnom       
                           ,lr_retorno.lcvregprccod
                           ,lr_retorno.maides      
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Dados da loja nao encontrados'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro SELECT cctc18g00001 ', sqlca.sqlcode, '/', sqlca.sqlerrd[2]  
                                    ,' - ctc18g00_dados_loja()'     
       end if 
    end if

 if lr_param.nvlretorno = 1 then
    return lr_retorno.resultado
          ,lr_retorno.mensagem 
          ,lr_retorno.lcvextcod    
          ,lr_retorno.aviestnom    
          ,lr_retorno.lcvregprccod 
 end if
 
 if lr_param.nvlretorno = 2 then
    return lr_retorno.resultado
          ,lr_retorno.mensagem 
          ,lr_retorno.maides
 end if                         

 if lr_param.nvlretorno = 3 then
    return lr_retorno.resultado
          ,lr_retorno.mensagem 
          ,lr_retorno.aviestnom    
          ,lr_retorno.lcvextcod
 end if
 
end function
