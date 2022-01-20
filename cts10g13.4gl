#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cts10g13                                                   #
# Analista Resp : Roberto Reboucas                                           #
# PSI           : PSI-2011-26008/EV                                          #
# Data          : 10/01/2012                                                 #
# Objetivo      : Gravar Rastreamento de Envio de Mensagens                  #
#............................................................................#
database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare  smallint

#---------------------------------------------------------------------
function cts10g13_prepare()
#---------------------------------------------------------------------

define l_sql     char(2000)

  let l_sql = ' select count(*) '
             ,'   from datmmsgenvrst '
             ,'  where lignum  =  ? '
             ,'  and pcscod = ?'
  prepare p_cts10g13_001  from l_sql
  declare c_cts10g13_001  cursor for p_cts10g13_001

  let l_sql = ' insert into datmmsgenvrst ' ,
              ' (lignum, pcscod,cpnmdunom, msgenverrcod, msgenverrdes, emaendnom) ',
              '  values(?,?,?,?,?,?) '                                                                                                           
  prepare p_cts10g13_002 from l_sql        
  
  let l_sql = ' update datmmsgenvrst      '         
             ,'    set (cpnmdunom, msgenverrcod, msgenverrdes, emaendnom) '
             ,'    =   (?,?,?,?)'
             ,'  where lignum    = ? '  
             ,'  and pcscod = ?'                                                
  prepare p_cts10g13_003 from l_sql             
  

  let m_prepare = true

end function

#--------------------------------------------------------------------- 
function cts10g13_grava_rastreamento(lr_param)                                            
#--------------------------------------------------------------------- 

define lr_param record                            
     lignum        like datmmsgenvrst.lignum       ,    
     pcscod        like datmmsgenvrst.pcscod       ,
     cpnmdunom     like datmmsgenvrst.cpnmdunom    ,
     msgenverrcod  like datmmsgenvrst.msgenverrcod ,
     msgenverrdes  like datmmsgenvrst.msgenverrdes ,
     emaendnom     like datmmsgenvrst.emaendnom             
end record      

define lr_retorno record                                                 
     qtd integer  
end record                 

initialize lr_retorno.* to null

 if lr_param.lignum is not null and
    lr_param.pcscod is not null then  
    
    if m_prepare is null or    
       m_prepare <> true then  
       call cts10g13_prepare()  
    end if                      

    open c_cts10g13_001 using lr_param.lignum,
                              lr_param.pcscod 
                                                   
    whenever error continue                        
    fetch c_cts10g13_001 into lr_retorno.qtd       
    whenever error stop                            
                                                   
    if sqlca.sqlcode <> 0 then                     
       error "Erro ao pesquisar o rastreamento de mensagens! ", sqlca.sqlcode                      
    end if                                         
                                                   
    close c_cts10g13_001                           
     
    if lr_retorno.qtd = 0 then
    
       whenever error continue                        
       execute p_cts10g13_002 using lr_param.lignum       ,    
                                    lr_param.pcscod       ,   
                                    lr_param.cpnmdunom    ,
                                    lr_param.msgenverrcod ,
                                    lr_param.msgenverrdes ,
                                    lr_param.emaendnom   
       
       whenever error stop    
       
       if sqlca.sqlcode <> 0 then                                                
          error "Erro ao gravar o rastreamento de mensagens! ", sqlca.sqlcode 
       end if                                                                    
                              
    else
       if lr_retorno.qtd > 0 then   
    
         whenever error continue                               
         execute p_cts10g13_003 using lr_param.cpnmdunom    ,  
                                      lr_param.msgenverrcod ,  
                                      lr_param.msgenverrdes ,  
                                      lr_param.emaendnom    ,
                                      lr_param.lignum       ,
                                      lr_param.pcscod             
                                                               
         whenever error stop                                   
         
         if sqlca.sqlcode <> 0 then                                                
            error "Erro ao atualizar o rastreamento de mensagens! ", sqlca.sqlcode    
         end if                                                                    
       
       end if 
    end if 
 end if    
    
    return

end function