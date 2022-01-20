# Porto Seguro Cia Seguros Gerais                                            #    
#............................................................................#    
# Sistema........: Porto Socorro                                             #    
# Modulo.........: ctc17g00                                                  #    
# Objetivo.......: Obter dados do veiculo da locadora                        #    
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
function ctc17g00_prepare()
#--------------------------

 define l_sql char(500)
 
 let l_sql = 'select avivclmdl, avivcldes, avivclgrp '
            ,'  from datkavisveic '
            ,' where lcvcod = ? '
            ,'   and avivclcod = ? '
            
 prepare pctc17g00001 from l_sql
 declare cctc17g00001 cursor for pctc17g00001
 
 let m_prep_sql = true
 
end function 

#-------------------------------------
function ctc17g00_dados_veic(lr_param)
#-------------------------------------

 define lr_param record 
                 nvlretorno smallint
                ,lcvcod     like datkavisveic.lcvcod   
                ,avivclcod  like datkavisveic.avivclcod
             end record

 define lr_retorno record
                   resultado smallint
                  ,mensagem  char(080)
                  ,avivclmdl like datkavisveic.avivclmdl
                  ,avivcldes like datkavisveic.avivcldes
                  ,avivclgrp like datkavisveic.avivclgrp
               end record

 initialize lr_retorno to null

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctc17g00_prepare()
 end if    

 let lr_retorno.resultado = 1

 if lr_param.nvlretorno = 1 then
    open cctc17g00001 using lr_param.lcvcod   
                           ,lr_param.avivclcod
    whenever error continue
    fetch cctc17g00001 into lr_retorno.avivclmdl
                           ,lr_retorno.avivcldes
                           ,lr_retorno.avivclgrp
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Dados do veiculo nao encontrado '
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro SELECT cctc17g00001 ', sqlca.sqlcode, '/', sqlca.sqlerrd[2] 
                                    ,' - ctc17g00_dados_veic()'    
       end if                             
    end if 

    return lr_retorno.resultado
          ,lr_retorno.mensagem 
          ,lr_retorno.avivclmdl
          ,lr_retorno.avivcldes
          ,lr_retorno.avivclgrp
 end if
                      
 
end function


