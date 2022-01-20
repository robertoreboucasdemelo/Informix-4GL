#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc69m34                                                   # 
# Objetivo.......: Cadastro de E-mails Itau Ato                               # 
# Analista Resp. : Amilton Pinto                                              # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 17/08/2015                                                 # 
#.............................................................................# 

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m34 array[500] of record
      cpocod   char(03)
    , cpodes   char(60)   
end record
 
define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_chave     like datkdominio.cponom


define  m_prepare  smallint

#===============================================================================
 function ctc69m34_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = ' select cpocod       '
          ,  '      , cpodes       '          
          ,  '   from datkdominio  '
          ,  '  where cponom = ? " ' 
          ,  '  order by 2         '
 prepare p_ctc69m34_001 from l_sql
 declare c_ctc69m34_001 cursor for p_ctc69m34_001
 	
 let l_sql = ' select count(*)    '
          ,  '   from datkdominio '
          ,  '  where cponom = ?  '        
          ,  '   and  cpodes = ?  '
 prepare p_ctc69m34_002 from l_sql
 declare c_ctc69m34_002 cursor for p_ctc69m34_002
 
 let l_sql =  ' update datkdominio        '
           ,  '     set cpodes  = ?       '                      
           ,  '   where cpocod  = ?       '       
           ,  '     and cponom  = ?       '  
 prepare p_ctc69m34_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc69m34_004 from l_sql 	
  
 
 let l_sql = '  delete datkdominio    '                               	
         ,  '   where cpocod = ?      '                             	
         ,  '   and cponom   = ?      '                             	
 prepare p_ctc69m34_005 from l_sql 
 
 
 let l_sql = ' select count(*)    '         
          ,  '   from datkdominio '              
          ,  '  where cponom = ?  '   
          ,  '   and  cpodes = ?  '               
 prepare p_ctc69m34_006 from l_sql               
 declare c_ctc69m34_006 cursor for p_ctc69m34_006 
 	
                            
 let m_prepare = true


end function

#===============================================================================
 function ctc69m34()
#===============================================================================
 
 
define lr_retorno record
    flag       smallint ,
    cont       integer  ,
    cpocod     integer  ,   
    cpodes     char(50) ,
    msg        char(60) , 
    data       date     
end record
  
for  arr_aux  =  1  to  500                  
   initialize  ma_ctc69m34[arr_aux].* to  null  
end  for                                     
 
 
 initialize lr_retorno.* to null 
 
 let arr_aux = 1 
 
 let m_chave = "bdata008_email"
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc69m34_prepare()
 end if
    

 options delete key F2
 
 open window w_ctc69m34 at 6,2 with form 'ctc69m34'
 attribute(form line 1)
  
 let lr_retorno.msg = '                (F17)Abandona, (F1)Inclui, (F2)Exclui'
 
 display by name lr_retorno.msg    
  
  open c_ctc69m34_001 using m_chave  
  foreach c_ctc69m34_001 into ma_ctc69m34[arr_aux].cpocod 
                            , ma_ctc69m34[arr_aux].cpodes                          
                           
                           
       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " E-mail Excedido! Foram Encontradas Mais de 500 E-mails!"
          exit foreach
       end if
       
  end foreach 
  
  let m_operacao = " " 
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 

  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc69m34 without defaults from s_ctc69m34.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
                
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc69m34[arr_aux].cpocod  is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
              
      #---------------------------------------------
       before field cpocod 
      #---------------------------------------------
                  
        if ma_ctc69m34[arr_aux].cpocod  is null then                                                   
           display ma_ctc69m34[arr_aux].cpocod  to s_ctc69m34[scr_aux].cpocod  attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                  
          let lr_retorno.cpocod = ma_ctc69m34[arr_aux].cpocod
          display ma_ctc69m34[arr_aux].* to s_ctc69m34[scr_aux].* attribute(reverse)                         
        end if                                                                                               
                      
        
         
      #---------------------------------------------
       after field cpocod                    
      #---------------------------------------------
        
        if fgl_lastkey() = fgl_keyval ("down")     or  
           fgl_lastkey() = fgl_keyval ("return")   then
          
             if m_operacao = 'i' then
             	
             	if ma_ctc69m34[arr_aux].cpocod  is null then
             		 error "Por Favor Informe o Codigo "
             		 next field cpocod          		
               end if 
               
               
               open c_ctc69m34_002 using m_chave
                                        ,ma_ctc69m34[arr_aux].cpocod         
               whenever error continue                                                
               fetch c_ctc69m34_002 into lr_retorno.cont           
               whenever error stop                                                    
                                                                                      
               if lr_retorno.cont >  0   then                                          
                  error " Codigo ja Cadastrado!" 
                  next field cpocod  
               end if 
                             
             else         
             	let ma_ctc69m34[arr_aux].cpocod = lr_retorno.cpocod
             	display ma_ctc69m34[arr_aux].* to s_ctc69m34[scr_aux].*       	                                                    
             end if
        else                                                                     
         	 if m_operacao = 'i' then                                              
         	    let ma_ctc69m34[arr_aux].cpocod = ''                            
         	    display ma_ctc69m34[arr_aux].* to s_ctc69m34[scr_aux].*            
         	    let m_operacao = ' '                                               
         	 else                                                                  
         	    let ma_ctc69m34[arr_aux].cpocod = lr_retorno.cpocod                     
         	    display ma_ctc69m34[arr_aux].* to s_ctc69m34[scr_aux].*             
         	 end if                                                                
        end if	 
        
        
                                                                       
      #---------------------------------------------
       before field cpodes
      #---------------------------------------------         
         display ma_ctc69m34[arr_aux].cpodes to s_ctc69m34[scr_aux].cpodes attribute(reverse)         
         let lr_retorno.cpodes =  ma_ctc69m34[arr_aux].cpodes                                        
      
      #---------------------------------------------
       after field cpodes
      #---------------------------------------------
         
         if fgl_lastkey() = fgl_keyval ("up")     or            
            fgl_lastkey() = fgl_keyval ("left")   then   
               next field cpocod 
         end if 
         
         if ma_ctc69m34[arr_aux].cpodes is null then
         	  error "Por Favor Informe o E-mail "
        		next field cpodes          		        	
         end if 
         
         
         open c_ctc69m34_006 using m_chave
                                  ,ma_ctc69m34[arr_aux].cpodes 
         whenever error continue                               
         fetch c_ctc69m34_006 into lr_retorno.cont             
         whenever error stop                                   
                                                               
         if lr_retorno.cont >  0   then                        
            error " E-mail ja Cadastrado!"                                           
            next field cpodes                                  
         end if                                                       
         
         
         if m_operacao <> 'i' then 
                        
            if ma_ctc69m34[arr_aux].cpodes <> lr_retorno.cpodes then
               	
               		             	                                                                                                    
                whenever error continue 
                execute p_ctc69m34_003 using ma_ctc69m34[arr_aux].cpodes
                                           , ma_ctc69m34[arr_aux].cpocod 
                                           , m_chave
                whenever error continue 
                
                if sqlca.sqlcode <> 0 then
                    error 'ERRO(',sqlca.sqlcode,') na Alteracao do E-Mail!'       
                else
                	  error 'Dados Alterados com Sucesso!' 
                end if 
              end if  
              
              let m_operacao = " "
              next field cpocod                                
         else
                
            
           let lr_retorno.data = today 
           
           whenever error continue
           execute p_ctc69m34_004 using ma_ctc69m34[arr_aux].cpocod 
                                      , ma_ctc69m34[arr_aux].cpodes  
                                      , m_chave                                    
                                      , lr_retorno.data
                                      
           whenever error stop
           if sqlca.sqlcode = 0 then
              error 'Dados Incluidos com Sucesso!'                                                                                                                                            
           else
              error 'ERRO(',sqlca.sqlcode,') na Insercao do E-Mail!'
           end if
           
           display ma_ctc69m34[arr_aux].cpocod   to s_ctc69m34[scr_aux].cpocod 
           display ma_ctc69m34[arr_aux].cpodes   to s_ctc69m34[scr_aux].cpodes 
           
           let m_operacao = " "  
           next field cpocod 
           
         end if
         
         display ma_ctc69m34[arr_aux].cpocod   to s_ctc69m34[scr_aux].cpocod
         display ma_ctc69m34[arr_aux].cpodes   to s_ctc69m34[scr_aux].cpodes
             
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      
      #---------------------------------------------                          
       before insert                                                          
      #---------------------------------------------                          
                                    
         let m_operacao = 'i'                                                 
                                                                              
         initialize  ma_ctc69m34[arr_aux] to null                             
                                                                              
         display ma_ctc69m34[arr_aux].cpocod   to s_ctc69m34[scr_aux].cpocod  
         display ma_ctc69m34[arr_aux].cpodes   to s_ctc69m34[scr_aux].cpodes  
      
          
      
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc69m34[arr_aux].cpocod  is null   then                    	
            continue input                                                  	
         else                                                               	
            if not ctc69m34_delete(ma_ctc69m34[arr_aux].cpocod) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if                                                          	
         end if                                                             	
         	     
          
  end input
  
 close window w_ctc69m34
 
 if lr_retorno.flag = 1 then
    call ctc69m34()
 end if
 
 
end function

#==============================================                                                
 function ctc69m34_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
	cpocod   integer     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"  
               ," "                                                                      
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO E-MAIL? "                                                                                                                      
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        whenever error continue                                                                
        execute p_ctc69m34_005 using lr_param.cpocod 
                                    ,m_chave                                                    
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o E-Mail!'   
           return false                                                                                                                                               
        end if                                                                                                                                                                               
        return true                                                                            
     else                                                                                      
        return false                                                                           
     end if                                                                                    
                                                                                               
end function






             
          






                                                                                      