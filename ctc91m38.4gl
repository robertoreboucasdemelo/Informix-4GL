#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Itau                                              # 
# Modulo.........: ctc91m38                                                   # 
# Objetivo.......: Cadastro Agrupamento do Produto                            # 
# Analista Resp. : R.Fornax                                                   # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 09/04/2016                                                 # 
#.............................................................................# 
 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc91m38 array[500] of record
      grpprdcod   integer
    , grpprddes   char(60)   
end record
 
define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_chave     like datkdominio.cponom

define  m_prepare  smallint

#===============================================================================
 function ctc91m38_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = ' select cpocod       '
          ,  '      , cpodes       '          
          ,  '   from datkdominio  '
          ,  '  where cponom = ? " ' 
          ,  '  order by 1         '
 prepare p_ctc91m38_001 from l_sql
 declare c_ctc91m38_001 cursor for p_ctc91m38_001
 	
 let l_sql = ' select count(*)    '
          ,  '   from datkdominio '
          ,  '  where cponom = ?  '        
          ,  '   and  cpocod = ?  '
 prepare p_ctc91m38_002 from l_sql
 declare c_ctc91m38_002 cursor for p_ctc91m38_002
 
 let l_sql = ' update datkdominio    '
           ,  '     set cpodes  = ?  '                      
           ,  '   where cpocod  = ?  '       
           ,  '     and cponom  = ?  '  
 prepare p_ctc91m38_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc91m38_004 from l_sql 	
  
 
 let l_sql = '  delete datkdominio    '                               	
         ,  '   where cpocod = ?      '                             	
         ,  '   and cponom   = ?      '                             	
 prepare p_ctc91m38_005 from l_sql 
 
 
 let l_sql = ' select count(*)    '         
          ,  '   from datkdominio '              
          ,  '  where cponom = ?  '   
          ,  '   and  cpodes = ?  '               
 prepare p_ctc91m38_006 from l_sql               
 declare c_ctc91m38_006 cursor for p_ctc91m38_006
 
                            
 let m_prepare = true


end function

#===============================================================================
 function ctc91m38()
#===============================================================================
 
 
define lr_retorno record
    flag                smallint ,
    cont                integer  ,
    grpprdcod              integer  ,
    grpprddes              char(60) ,
    msg                 char(60) ,
    data_atual          date
end record
  
for  arr_aux  =  1  to  500                  
   initialize  ma_ctc91m38[arr_aux].* to  null  
end  for                                     
 
 
 initialize lr_retorno.* to null 
 
 let arr_aux = 1 
 
 let m_chave = "IT_GRP_PROD"
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc91m38_prepare()
 end if
    

 options delete key F2
 
 open window w_ctc91m38 at 6,2 with form 'ctc91m38'
 attribute(form line 1)
  
 let lr_retorno.msg = '       (F17)Abandona, (F1)Inclui, (F2)Exclui, (F8)Produtos'
 
 display by name lr_retorno.msg    
  
  open c_ctc91m38_001 using m_chave  
  foreach c_ctc91m38_001 into ma_ctc91m38[arr_aux].grpprdcod 
                            , ma_ctc91m38[arr_aux].grpprddes                          
                           
                           
       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Bloco Excedido! Foram Encontradas Mais de 500 Grupos!"
          exit foreach
       end if
       
  end foreach 
  
  let m_operacao = " " 
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 

  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc91m38 without defaults from s_ctc91m38.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
                
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc91m38[arr_aux].grpprdcod  is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
              
      #---------------------------------------------
       before field grpprdcod 
      #---------------------------------------------
                  
        if ma_ctc91m38[arr_aux].grpprdcod  is null then                                                   
           display ma_ctc91m38[arr_aux].grpprdcod  to s_ctc91m38[scr_aux].grpprdcod  attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          let lr_retorno.grpprdcod = ma_ctc91m38[arr_aux].grpprdcod
          display ma_ctc91m38[arr_aux].* to s_ctc91m38[scr_aux].* attribute(reverse)                         
        end if                                                                                               
                      
        
         
      #---------------------------------------------
       after field grpprdcod                    
      #---------------------------------------------
          
        if m_operacao = 'i' then
        	
        	if ma_ctc91m38[arr_aux].grpprdcod  is null then
        		 error "Por Favor Informe o Codigo do Grupo do Produto"
        		 next field grpprdcod          		
          end if 
          
          
          open c_ctc91m38_002 using m_chave
                                   ,ma_ctc91m38[arr_aux].grpprdcod         
          whenever error continue                                                
          fetch c_ctc91m38_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Codigo ja Cadastrado!" 
             next field grpprdcod  
          end if 
                        
        else          
        	let ma_ctc91m38[arr_aux].grpprdcod = lr_retorno.grpprdcod
        	display ma_ctc91m38[arr_aux].* to s_ctc91m38[scr_aux].*       	                                                    
        end if
        
       
      
      #---------------------------------------------
       before field grpprddes
      #---------------------------------------------         
         display ma_ctc91m38[arr_aux].grpprddes to s_ctc91m38[scr_aux].grpprddes attribute(reverse)         
         let lr_retorno.grpprddes =  ma_ctc91m38[arr_aux].grpprddes                                        
      
      #---------------------------------------------
       after field grpprddes
      #---------------------------------------------
         
         if fgl_lastkey() = fgl_keyval ("up")     or            
            fgl_lastkey() = fgl_keyval ("left")   then   
               next field grpprdcod 
         end if 
         
         if ma_ctc91m38[arr_aux].grpprddes is null then
         	  error "Por Favor Informe a Descricao Grupo do Produto "
        		next field grpprddes          		        	
         end if 
         
         
         open c_ctc91m38_006 using m_chave
                                  ,ma_ctc91m38[arr_aux].grpprddes 
         whenever error continue                               
         fetch c_ctc91m38_006 into lr_retorno.cont             
         whenever error stop                                   
                                                               
         if lr_retorno.cont >  0   then                        
            error " Descricao ja Cadastrado!"                                           
            next field grpprddes                                  
         end if                                                       
         
         
         if m_operacao <> 'i' then 
                        
            if ma_ctc91m38[arr_aux].grpprddes <> lr_retorno.grpprddes then
               	
               		             	                                                                                                    
                whenever error continue 
                execute p_ctc91m38_003 using ma_ctc91m38[arr_aux].grpprddes                                           
                                           , ma_ctc91m38[arr_aux].grpprdcod
                                           , m_chave
                whenever error continue 
                
                if sqlca.sqlcode <> 0 then
                    error 'ERRO(',sqlca.sqlcode,') na Alteracao do Grupo do Produto!'       
                else
                	  error 'Dados Alterados com Sucesso!' 
                end if 
              end if  
              
              let m_operacao = " "
              next field grpprdcod                                
         else
           
                              
            let lr_retorno.data_atual = today 
           
           whenever error continue
           execute p_ctc91m38_004 using ma_ctc91m38[arr_aux].grpprdcod 
                                      , ma_ctc91m38[arr_aux].grpprddes 
                                      , m_chave                                    
                                      , lr_retorno.data_atual
                                      
           whenever error continue
           if sqlca.sqlcode = 0 then
              error 'Dados Incluidos com Sucesso!'                                                                                                                                            
           else
              error 'ERRO(',sqlca.sqlcode,') na Insercao do Grupo do Produto!'
           end if
           
           display ma_ctc91m38[arr_aux].grpprdcod   to s_ctc91m38[scr_aux].grpprdcod 
           display ma_ctc91m38[arr_aux].grpprddes   to s_ctc91m38[scr_aux].grpprddes 
           
           let m_operacao = " "  
           next field grpprdcod 
           
         end if
         
         display ma_ctc91m38[arr_aux].grpprdcod   to s_ctc91m38[scr_aux].grpprdcod
         display ma_ctc91m38[arr_aux].grpprddes   to s_ctc91m38[scr_aux].grpprddes
             
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
      #---------------------------------------------                  	
       on key (F8)                                                    	
      #---------------------------------------------                  	
                                                                      	
                
         if ma_ctc91m38[arr_aux].grpprdcod is not null then      	
                                                                     	
             call ctc91m39(ma_ctc91m38[arr_aux].grpprdcod   ,
                           ma_ctc91m38[arr_aux].grpprddes   )      	               
                                                  	        	
         end if
          
        
         	
    
      #---------------------------------------------                          
       before insert                                                          
      #---------------------------------------------                          
                                    
         let m_operacao = 'i'                                                 
                                                                              
         initialize  ma_ctc91m38[arr_aux] to null                             
                                                                              
         display ma_ctc91m38[arr_aux].grpprdcod   to s_ctc91m38[scr_aux].grpprdcod  
         display ma_ctc91m38[arr_aux].grpprddes   to s_ctc91m38[scr_aux].grpprddes  
      
          
      
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc91m38[arr_aux].grpprdcod  is null   then                    	
            continue input                                                  	
         else                                                               	
            if not ctc91m38_delete(ma_ctc91m38[arr_aux].grpprdcod) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if                                                          	
         end if                                                             	
         	     
          
  end input
  
 close window w_ctc91m38
 
 if lr_retorno.flag = 1 then
    call ctc91m38()
 end if
 
 
end function

#==============================================                                                
 function ctc91m38_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
	grpprdcod   integer     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DO GRUPO DO PRODUTO ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        whenever error continue                                                                
        execute p_ctc91m38_005 using lr_param.grpprdcod 
                                    ,m_chave                                                    
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Grupo do Produto!'   
           return false                                                                                                                                               
        end if                                                                                                                                                                               
        return true                                                                            
     else                                                                                      
        return false                                                                           
     end if                                                                                    
                                                                                               
end function     
                                                                              

































             
          






                                                                                      