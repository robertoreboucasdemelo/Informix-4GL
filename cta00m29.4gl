#----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                            # 
#............................................................................# 
# Sistema........: Auto e RE - Itau Seguros                                  # 
# Modulo.........: cta00m29                                                  # 
# Objetivo.......: Itens da Apolice do Itau                                  # 
# Analista Resp. : Roberto Melo                                              # 
# PSI            :                                                           # 
#............................................................................# 
# Desenvolvimento: Roberto Melo                                              # 
# Liberacao      : 25/01/2010                                                # 
#............................................................................# 


database porto                                        
                                                      
globals "/homedsa/projetos/geral/globals/glct.4gl"    
                                                      
define m_prepare  smallint 

define mr_array array[1000] of record         
       itaaplitmnum  like datmitaaplitm.itaaplitmnum ,             
       veiculo       char(40)                        ,                 
       autplcnum     like datmitaaplitm.autplcnum                          
end record   

define m_index integer    
                              
#------------------------------------------------------------------------------                            
function cta00m29_prepare()                                                     
#------------------------------------------------------------------------------ 

define l_sql char(500)                                          
                                                                
   let l_sql = " select  a.itaaplitmnum, " , 
               "         a.autplcnum  ,  " ,
               "         a.autfbrnom  ,  " ,
               "         a.autlnhnom  ,  " ,
               "         a.autmodnom  ,  " , 
               "         b.succod        " ,               
               " from datmitaaplitm a, datmitaapl b "  ,                        
               " where a.itaciacod = b.itaciacod    "  ,
               " and   a.itaramcod = b.itaramcod    "  ,
               " and   a.itaaplnum = b.itaaplnum    "  ,
               " and   a.aplseqnum = b.aplseqnum    "  ,
               " and   a.itaciacod = ? "  ,                        
               " and   a.itaramcod = ? "  ,                        
               " and   a.itaaplnum = ? "  ,
               " and   a.aplseqnum = ? "                          
   prepare p_cta00m29_001  from l_sql                           
   declare c_cta00m29_001  cursor for p_cta00m29_001
   
   let l_sql = " select a.itaaplitmnum, " , 
               "        b.succod        " ,            
               " from datmitaaplitm a,  " ,
               "      datmitaapl b      " ,            
               " where a.itaciacod = b.itaciacod    "  , 
               " and   a.itaramcod = b.itaramcod    "  , 
               " and   a.itaaplnum = b.itaaplnum    "  , 
               " and   a.aplseqnum = b.aplseqnum    "  ,            
               " and   a.itaciacod    = ? " ,            
               " and   a.itaramcod    = ? " ,            
               " and   a.itaaplnum    = ? " ,            
               " and   a.aplseqnum    = ? " ,
               " and   a.itaaplitmnum = ? "             
   prepare p_cta00m29_002  from l_sql                
   declare c_cta00m29_002  cursor for p_cta00m29_002
                                                                                                                               
   let m_prepare = true                                
                                                                
end function   


#------------------------------------------------------------------------------                                                 
function cta00m29(lr_param)                                                    
#------------------------------------------------------------------------------

define lr_param record                        
   itaciacod     like datmitaapl.itaciacod       ,   
   itaramcod     like datmitaapl.itaramcod       ,   
   itaaplnum     like datmitaapl.itaaplnum       ,
   aplseqnum     like datmitaapl.aplseqnum       ,
   itaaplitmnum  like datmitaaplitm.itaaplitmnum   
end record   

define lr_retorno record
   itaaplitmnum  like datmitaaplitm.itaaplitmnum ,
   autplcnum     like datmitaaplitm.autplcnum    ,
   autfbrnom     like datmitaaplitm.autfbrnom    ,
   autlnhnom     like datmitaaplitm.autlnhnom    ,
   autmodnom     like datmitaaplitm.autmodnom    ,
   succod        like datmitaapl.succod          ,
   erro          integer                         ,       
   mensagem      char(50)                                
end record            


initialize lr_retorno.* to null

for  m_index  =  1  to  1000                  
   initialize  mr_array[m_index].* to  null  
end  for                                     

if m_prepare is null or        
   m_prepare <> true then      
   call cta00m29_prepare()     
end if 

let lr_retorno.erro = 0 
  
   if lr_param.itaaplitmnum is null then 
   
        let m_index = 1  
          
        open  c_cta00m29_001 using lr_param.itaciacod, 
                                   lr_param.itaramcod,
                                   lr_param.itaaplnum,
                                   lr_param.aplseqnum                                                              
        
        foreach c_cta00m29_001 into mr_array[m_index].itaaplitmnum , 
                                    mr_array[m_index].autplcnum    ,                       
                                    lr_retorno.autfbrnom           ,
                                    lr_retorno.autlnhnom           ,
                                    lr_retorno.autmodnom           ,
                                    lr_retorno.succod 
                                                              
              let mr_array[m_index].veiculo = lr_retorno.autfbrnom clipped, " ",
                                              lr_retorno.autlnhnom clipped, " ",
                                              lr_retorno.autmodnom clipped
                                                                                                    
              let m_index = m_index + 1                                                
                                                                                       
              if m_index > 1000 then                                                                         
                 message "Limite excedido. Foram Encontrados mais de 1000 Itens!"                             
                 exit foreach                                                          
              end if                                                                   
                                                                                       
        end foreach
       
        if m_index > 2 then
            call cta00m29_display()
            returning lr_retorno.itaaplitmnum   
            
            if lr_retorno.itaaplitmnum is null then
               let lr_retorno.erro     = 1   
            end if
        else
            
            let lr_retorno.itaaplitmnum = mr_array[m_index - 1].itaaplitmnum 
        end if   
    else
    
        open c_cta00m29_002 using lr_param.itaciacod   ,
                                  lr_param.itaramcod   ,
                                  lr_param.itaaplnum   ,
                                  lr_param.aplseqnum   , 
                                  lr_param.itaaplitmnum
                                  
        whenever error continue                                        
        fetch c_cta00m29_002 into lr_retorno.itaaplitmnum,
                                  lr_retorno.succod                
        whenever error stop                                            
        
        if sqlca.sqlcode <> 0  then                                                                     
           if sqlca.sqlcode = notfound  then                                                            
              let lr_retorno.mensagem = "Item da Apolice nao Encontrada!"                           
              let lr_retorno.erro     = 1                                                               
           else                                                                                         
              let lr_retorno.mensagem =  "Erro ao selecionar o cursor c_cta00m29_002 ", sqlca.sqlcode     
              let lr_retorno.erro     =  sqlca.sqlcode                                                  
           end if                                                                                       
        end if                                                                                          
       
        close c_cta00m29_002                                              
        
    end if     
    
   return lr_retorno.itaaplitmnum ,
          lr_retorno.succod       ,
          lr_retorno.erro         ,   
          lr_retorno.mensagem       
                                                                  
end function

#------------------------------------------------------------------------------ 
function cta00m29_display()                                                             
#------------------------------------------------------------------------------ 

define lr_retorno record                            
   itaaplitmnum  like datmitaaplitm.itaaplitmnum 
end record       

initialize lr_retorno.* to null


      open window cta00m29 at 08,14 with form "cta00m29"     
         attribute (border,form line 1)                      
                                                             
      message " (F17)Abandona, (F8)Seleciona"                
      call set_count(m_index-1)                              
                                                             
      display array mr_array to s_cta00m29.*            
                                                             
         on key (interrupt,control-c)                        
            initialize mr_array to null                      
            let lr_retorno.itaaplitmnum = null                            
            exit display                                     
                                                             
         on key (f8)                                         
            let m_index = arr_curr()     
            let lr_retorno.itaaplitmnum = mr_array[m_index].itaaplitmnum                    
            exit display                                     
      end display                                            
                                                             
      close window cta00m29                                  
                                                             
      let int_flag = false                                   
      
      return lr_retorno.itaaplitmnum      
            
end function
      
      
      