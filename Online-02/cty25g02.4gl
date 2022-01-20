#----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                            # 
#............................................................................# 
# Sistema........: Auto e RE - Itau Seguros                                  # 
# Modulo.........: cty25g02                                                  # 
# Objetivo.......: Itens da Apolice do Itau                                  # 
# Analista Resp. : JUNIOR  (FORNAX)                                          # 
# PSI            :                                                           # 
#............................................................................# 
# Desenvolvimento: JUNIOR (FORNAX)                                           # 
# Liberacao      :   /  /                                                    # 
#............................................................................# 

database porto                                        
                                                      
globals "/homedsa/projetos/geral/globals/glct.4gl"    
                                                      
define m_prepare  smallint 

define mr_array array[1000] of record         
       aplitmnum     like datmresitaaplitm.aplitmnum              
end record   

define m_index integer    
                              
#------------------------------------------------------------------------------                            
function cty25g02_prepare()                                                     
#------------------------------------------------------------------------------ 

define l_sql char(500)                                          
                                                                
   let l_sql = " select  a.aplitmnum, " , 
               "         b.succod        " ,               
               " from datmresitaaplitm a, ",
	       "      datmresitaapl b "  ,                        
               " where a.itaciacod = b.itaciacod    "  ,
               " and   a.itaramcod = b.itaramcod    "  ,
               " and   a.aplnum    = b.aplnum    "  ,
               " and   a.aplseqnum = b.aplseqnum    "  ,
               " and   a.itaciacod = ? "  ,                        
               " and   a.itaramcod = ? "  ,                        
               " and   a.aplnum    = ? "  ,
               " and   a.aplseqnum = ? "                          
   prepare p_cty25g02_001  from l_sql                           
   declare c_cty25g02_001  cursor for p_cty25g02_001
   
   let l_sql = " select a.aplitmnum,    " , 
               "        b.succod        " ,            
               " from datmresitaaplitm a,  " ,
               "      datmresitaapl b      " ,            
               " where a.itaciacod = b.itaciacod    "  , 
               " and   a.itaramcod = b.itaramcod    "  , 
               " and   a.aplnum    = b.aplnum       "  , 
               " and   a.aplseqnum = b.aplseqnum    "  ,            
               " and   a.itaciacod = ? " ,            
               " and   a.itaramcod = ? " ,            
               " and   a.aplnum    = ? " ,            
               " and   a.aplseqnum = ? " ,
               " and   a.aplitmnum = ? "             
   prepare p_cty25g02_002  from l_sql                
   declare c_cty25g02_002  cursor for p_cty25g02_002
                                                                                                                               
   let m_prepare = true                                
                                                                
end function   


#------------------------------------------------------------------------------                                                 
function cty25g02(lr_param)                                                    
#------------------------------------------------------------------------------

define lr_param record                        
   itaciacod     like datmresitaapl.itaciacod       ,   
   itaramcod     like datmresitaapl.itaramcod       ,   
   aplnum        like datmresitaapl.aplnum          ,
   aplseqnum     like datmresitaapl.aplseqnum       ,
   aplitmnum     like datmresitaaplitm.aplitmnum   
end record   

define lr_retorno record
   aplitmnum     like datmresitaaplitm.aplitmnum ,
   succod        like datmresitaapl.succod       ,
   erro          integer                         ,       
   mensagem      char(50)                                
end record            


initialize lr_retorno.* to null

for  m_index  =  1  to  1000                  
   initialize  mr_array[m_index].* to  null  
end  for                                     

if m_prepare is null or        
   m_prepare <> true then      
   call cty25g02_prepare()     
end if 

let lr_retorno.erro = 0 
  
   if lr_param.aplitmnum is null then 
   
        let m_index = 1  
          
        open  c_cty25g02_001 using lr_param.itaciacod, 
                                   lr_param.itaramcod,
                                   lr_param.aplnum   ,
                                   lr_param.aplseqnum                                                              
        
        foreach c_cty25g02_001 into mr_array[m_index].aplitmnum , 
                                    lr_retorno.succod 
                                                              
              let m_index = m_index + 1                                                
                                                                                       
              if m_index > 1000 then                                                                         
                 message "Limite excedido. Foram Encontrados mais de 1000 Itens!"                             
                 exit foreach                                                          
              end if                                                                   
                                                                                       
        end foreach
       
        if m_index > 2 then
            call cty25g02_display()
            returning lr_retorno.aplitmnum   
            
            if lr_retorno.aplitmnum is null then
               let lr_retorno.erro     = 1   
            end if
        else
            
            let lr_retorno.aplitmnum = mr_array[m_index - 1].aplitmnum 
        end if   
    else
    
        open c_cty25g02_002 using lr_param.itaciacod   ,
                                  lr_param.itaramcod   ,
                                  lr_param.aplnum      ,
                                  lr_param.aplseqnum   , 
                                  lr_param.aplitmnum
                                  
        whenever error continue                                        
        fetch c_cty25g02_002 into lr_retorno.aplitmnum,
                                  lr_retorno.succod                
        whenever error stop                                            
        
        if sqlca.sqlcode <> 0  then                                                                     
           if sqlca.sqlcode = notfound  then                                                            
              let lr_retorno.mensagem = "Item da Apolice nao Encontrada!"                           
              let lr_retorno.erro     = 1                                                               
           else                                                                                         
              let lr_retorno.mensagem =  "Erro ao selecionar o cursor c_cty25g02_002 ", sqlca.sqlcode     
              let lr_retorno.erro     =  sqlca.sqlcode                                                  
           end if                                                                                       
        end if                                                                                          
       
        close c_cty25g02_002                                              
        
    end if     
    
   return lr_retorno.aplitmnum ,
          lr_retorno.succod       ,
          lr_retorno.erro         ,   
          lr_retorno.mensagem       
                                                                  
end function

#------------------------------------------------------------------------------ 
function cty25g02_display()                                                             
#------------------------------------------------------------------------------ 

define lr_retorno record                            
   aplitmnum    like datmresitaaplitm.aplitmnum 
end record       

initialize lr_retorno.* to null


      open window cta00m29 at 08,14 with form "cta00m29"     
         attribute (border,form line 1)                      
                                                             
      message " (F17)Abandona, (F8)Seleciona"                
      call set_count(m_index-1)                              
                                                             
      display array mr_array to s_cta00m29.*            
                                                             
         on key (interrupt,control-c)                        
            initialize mr_array to null                      
            let lr_retorno.aplitmnum = null                            
            exit display                                     
                                                             
         on key (f8)                                         
            let m_index = arr_curr()     
            let lr_retorno.aplitmnum = mr_array[m_index].aplitmnum                    
            exit display                                     
      end display                                            
                                                             
      close window cta00m29                                  
                                                             
      let int_flag = false                                   
      
      return lr_retorno.aplitmnum      
            
end function
      
      
      
