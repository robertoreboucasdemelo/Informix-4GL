############################################################################### 
# Nome do Modulo: ctc81m00c                                Robson Ruas        # 
#                                                                             # 
#  Limitar o valor de desconto da OP SAP                   02/2013            # 
############################################################################### 
# Alteracoes:                                                                 # 
#                                                                             # 
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             # 
#-----------------------------------------------------------------------------# 
database porto

function ctc81m00c(l_socopgnum)                                         
                                                                           
define l_socopgnum    like dbsmopg.socopgnum
define l_socfattotvlr like dbsmopg.socfattotvlr
define l_descop       integer
define lr_vlr_aux     like dbsmopg.socfattotvlr

define lr_param record
      vlr     like dbsmopg.socfattotvlr
end record


      
    let int_flag     = false
    #let lr_param.vlr = 100.00
    display "OP: ",l_socopgnum
    
    #Valor Bruto da OP    
    select socfattotvlr
      into l_socfattotvlr
      from dbsmopg
     where socopgnum = l_socopgnum
     
     display "Valor: ",l_socfattotvlr
     
     #Percentoal de desconto para OP
     select grlinf 
       into  l_descop 
       from  datkgeral
       where grlchv = 'PSOPERCDESCOP'
     display "Porcentagem: ",l_descop 
     
    let lr_param.vlr = (l_socfattotvlr * (l_descop/100)) 
    let lr_vlr_aux = lr_param.vlr

    open window w_ctc81m00c at 10,21 with form "ctc81m00c"           
    attribute (form line 1,border)      

 while not int_flag

    input lr_param.* without defaults from vlr 
                                                                           
       before field vlr 
       
           display lr_param.vlr to vlr attribute (reverse)
                                                                           
       after field vlr                  
       
           display lr_param.vlr to vlr 
           if lr_param.vlr <> lr_vlr_aux then 
              let lr_param.vlr = lr_vlr_aux
              display lr_param.vlr to vlr 
           end if 

       on key (interrupt, control-c)                   
	  let int_flag = true 
          exit input                                 
                                                                       
    end input                                                              
                                                                           
    if int_flag  then
       exit while
    end if

 end while

 close window w_ctc81m00c                                                  
 let int_flag = false
 
 return lr_param.vlr

end function 
