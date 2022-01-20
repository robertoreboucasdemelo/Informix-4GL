#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc69m27                                                   # 
# Objetivo.......: Cadastro de Clausulas Azul                                 # 
# Analista Resp. : Amilton Pinto                                              # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 12/03/2015                                                 # 
#.............................................................................# 

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m27 array[500] of record
      clscod   char(03)
    , clsdes   char(60)
    , processa char(01)   
end record

define mr_param array[500] of record
   cpocod integer 
end record
 
define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_chave     like datkdominio.cponom


define  m_prepare  smallint

#===============================================================================
 function ctc69m27_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = ' select cpocod       '
          ,  '      , cpodes[1,3]  '    
          ,  '      , cpodes[5,5]  ' 
          ,  '      , cpodes[7,50] '          
          ,  '   from datkdominio  '
          ,  '  where cponom = ? " ' 
          ,  '  order by 2         '
 prepare p_ctc69m27_001 from l_sql
 declare c_ctc69m27_001 cursor for p_ctc69m27_001
 	
 let l_sql = ' select count(*)    '
          ,  '   from datkdominio '
          ,  '  where cponom = ?  '        
          ,  '   and  cpodes[1,3] = ?  '
 prepare p_ctc69m27_002 from l_sql
 declare c_ctc69m27_002 cursor for p_ctc69m27_002
 
 let l_sql =  ' update datkdominio        '
           ,  '     set cpodes[1,3]  = ?  '  
           ,  '    ,    cpodes[5,5]  = ?  '                      
           ,  '    ,    cpodes[7,50] = ?  ' 
           ,  '   where cpocod  = ?       '       
           ,  '     and cponom  = ?       '  
 prepare p_ctc69m27_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc69m27_004 from l_sql 	
  
 
 let l_sql = '  delete datkdominio    '                               	
         ,  '   where cpodes[1,3] = ? '                             	
         ,  '   and cponom        = ? '                             	
 prepare p_ctc69m27_005 from l_sql 
 	
 let l_sql = ' select max(cpocod)             '  	
          ,  ' from datkdominio               '  	
          ,  ' where cponom = ?               '  	
 prepare p_ctc69m27_007 from l_sql                  	
 declare c_ctc69m27_007 cursor for p_ctc69m27_007   	
 
                            
 let m_prepare = true


end function

#===============================================================================
 function ctc69m27()
#===============================================================================
 
 
define lr_retorno record
    flag                smallint ,
    cont                integer  ,
    clscod              char(03) ,
    clsdes              char(60) ,
    msg                 char(60) ,
    cpocod              integer  ,
    data                date     ,
    cpodes              char(50) ,
    processa            char(01)
end record
  
for  arr_aux  =  1  to  500                  
   initialize  ma_ctc69m27[arr_aux].*, mr_param[arr_aux].* to  null  
end  for                                     
 
 
 initialize lr_retorno.* to null 
 
 let arr_aux = 1 
 
 let m_chave = "claus_azul"
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc69m27_prepare()
 end if
    

 options delete key F2
 
 open window w_ctc69m27 at 6,2 with form 'ctc69m27'
 attribute(form line 1)
  
 let lr_retorno.msg = '                (F17)Abandona, (F1)Inclui, (F2)Exclui'
 
 display by name lr_retorno.msg    
  
  open c_ctc69m27_001 using m_chave  
  foreach c_ctc69m27_001 into mr_param[arr_aux].cpocod 
  	                        , ma_ctc69m27[arr_aux].clscod 
  	                        , ma_ctc69m27[arr_aux].processa 
                            , ma_ctc69m27[arr_aux].clsdes                          
                           
                           
       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Clausula Excedida! Foram Encontradas Mais de 500 Clausulas!"
          exit foreach
       end if
       
  end foreach 
  
  let m_operacao = " " 
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 

  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc69m27 without defaults from s_ctc69m27.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
                
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc69m27[arr_aux].clscod  is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
              
      #---------------------------------------------
       before field clscod 
      #---------------------------------------------
                  
        if ma_ctc69m27[arr_aux].clscod  is null then                                                   
           display ma_ctc69m27[arr_aux].clscod  to s_ctc69m27[scr_aux].clscod  attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          let lr_retorno.clscod = ma_ctc69m27[arr_aux].clscod
          display ma_ctc69m27[arr_aux].* to s_ctc69m27[scr_aux].* attribute(reverse)                         
        end if                                                                                               
                      
        
         
      #---------------------------------------------
       after field clscod                    
      #---------------------------------------------
         
         if fgl_lastkey() = fgl_keyval ("down")     or     
            fgl_lastkey() = fgl_keyval ("return")   then   
         
         
          
             if m_operacao = 'i' then
             	
             	if ma_ctc69m27[arr_aux].clscod  is null then
             		 error "Por Favor Informe o Codigo da Clausula "
             		 next field clscod          		
               end if 
               
               
               open c_ctc69m27_002 using m_chave
                                        ,ma_ctc69m27[arr_aux].clscod         
               whenever error continue                                                
               fetch c_ctc69m27_002 into lr_retorno.cont           
               whenever error stop                                                    
                                                                                      
               if lr_retorno.cont >  0   then                                          
                  error " Codigo ja Cadastrado!" 
                  next field clscod  
               end if 
                             
             else          
             	let ma_ctc69m27[arr_aux].clscod = lr_retorno.clscod
             	display ma_ctc69m27[arr_aux].* to s_ctc69m27[scr_aux].*       	                                                    
             end if
        else                                                                   
         	 if m_operacao = 'i' then                                            
         	    let ma_ctc69m27[arr_aux].clscod = ''                             
         	    display ma_ctc69m27[arr_aux].* to s_ctc69m27[scr_aux].*          
         	    let m_operacao = ' '                                             
         	 else                                                                
         	    let ma_ctc69m27[arr_aux].clscod = lr_retorno.clscod                     
         	    display ma_ctc69m27[arr_aux].* to s_ctc69m27[scr_aux].*          
         	 end if                                                              
        end if	                                                               
                                                                      
      
      #---------------------------------------------
       before field clsdes
      #---------------------------------------------         
         display ma_ctc69m27[arr_aux].clsdes to s_ctc69m27[scr_aux].clsdes attribute(reverse)         
         let lr_retorno.clsdes =  ma_ctc69m27[arr_aux].clsdes                                        
      
      #---------------------------------------------
       after field clsdes
      #---------------------------------------------
         
         if fgl_lastkey() = fgl_keyval ("up")     or            
            fgl_lastkey() = fgl_keyval ("left")   then   
               next field clscod 
         end if 
         
         if ma_ctc69m27[arr_aux].clsdes is null then
         	  error "Por Favor Informe a Descricao da Clausula "
        		next field clsdes          		        	
         end if 
         
       
      #---------------------------------------------
       before field processa
      #---------------------------------------------         
         display ma_ctc69m27[arr_aux].processa to s_ctc69m27[scr_aux].processa attribute(reverse)         
         let lr_retorno.processa =  ma_ctc69m27[arr_aux].processa                                        
      
      #---------------------------------------------
       after field processa
      #---------------------------------------------
         
         if fgl_lastkey() = fgl_keyval ("up")     or            
            fgl_lastkey() = fgl_keyval ("left")   then   
               next field clsdes
         end if 
         
         if ma_ctc69m27[arr_aux].processa <> "S" and
         	  ma_ctc69m27[arr_aux].processa <> "N" then
         	  error "Por Favor Informe <S> ou <N> "
        		next field processa          		        	
         end if                                                          
         
         
         if m_operacao <> 'i' then 
                        
            if ma_ctc69m27[arr_aux].clsdes   <> lr_retorno.clsdes   or
               ma_ctc69m27[arr_aux].processa <> lr_retorno.processa then
               		             	                                                                                                    
                whenever error continue 
                execute p_ctc69m27_003 using ma_ctc69m27[arr_aux].clscod                                           
                                           , ma_ctc69m27[arr_aux].processa
                                           , ma_ctc69m27[arr_aux].clsdes
                                           , mr_param[arr_aux].cpocod 
                                           , m_chave
                whenever error continue 
                
                if sqlca.sqlcode <> 0 then
                    error 'ERRO(',sqlca.sqlcode,') na Alteracao da Clausula!'       
                else
                	  error 'Dados Alterados com Sucesso!' 
                end if 
              end if  
              
              let m_operacao = " "
              next field clscod                                
         else
           
           call ctc69m27_gera_codigo()
           returning lr_retorno.cpocod                    
           
           
           let mr_param[arr_aux].cpocod = lr_retorno.cpocod
           
           let lr_retorno.cpodes = ma_ctc69m27[arr_aux].clscod clipped    , "|",
                                   ma_ctc69m27[arr_aux].processa          , "|",   
                                   ma_ctc69m27[arr_aux].clsdes                   
            
           let lr_retorno.data = today 
           
           whenever error continue
           execute p_ctc69m27_004 using lr_retorno.cpocod 
                                      , lr_retorno.cpodes 
                                      , m_chave                                    
                                      , lr_retorno.data
                                      
           whenever error stop
           if sqlca.sqlcode = 0 then
              error 'Dados Incluidos com Sucesso!'                                                                                                                                            
           else
              error 'ERRO(',sqlca.sqlcode,') na Insercao da Clausula!'
           end if
           
           display ma_ctc69m27[arr_aux].clscod   to s_ctc69m27[scr_aux].clscod 
           display ma_ctc69m27[arr_aux].clsdes   to s_ctc69m27[scr_aux].clsdes
           display ma_ctc69m27[arr_aux].processa to s_ctc69m27[scr_aux].processa 
           
           let m_operacao = " "  
           next field clscod 
           
         end if
         
         display ma_ctc69m27[arr_aux].clscod   to s_ctc69m27[scr_aux].clscod
         display ma_ctc69m27[arr_aux].clsdes   to s_ctc69m27[scr_aux].clsdes
         display ma_ctc69m27[arr_aux].processa to s_ctc69m27[scr_aux].processa 
             
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      
      #---------------------------------------------                          
       before insert                                                          
      #---------------------------------------------                          
                                    
         let m_operacao = 'i'                                                 
                                                                              
         initialize  ma_ctc69m27[arr_aux] to null                             
                                                                              
         display ma_ctc69m27[arr_aux].clscod   to s_ctc69m27[scr_aux].clscod  
         display ma_ctc69m27[arr_aux].clsdes   to s_ctc69m27[scr_aux].clsdes
         display ma_ctc69m27[arr_aux].processa to s_ctc69m27[scr_aux].processa   
      
          
      
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc69m27[arr_aux].clscod  is null   then                    	
            continue input                                                  	
         else                                                          	
            if not ctc69m27_delete(ma_ctc69m27[arr_aux].clscod) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if                                                          	
         end if                                                             	
         	     
          
  end input
  
 close window w_ctc69m27
 
 if lr_retorno.flag = 1 then
    call ctc69m27()
 end if
 
 
end function

#==============================================                                                
 function ctc69m27_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
	cpodes   like datkdominio.cpodes     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DA CLAUSULA ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                                      
        whenever error continue                                                                
        execute p_ctc69m27_005 using lr_param.cpodes 
                                    ,m_chave                                                    
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Clausula!'   
           return false                                                                                                                                               
        end if 
                                                                                                                                                                                    
        return true                                                                            
     else                                                                                      
        return false                                                                           
     end if                                                                                    
                                                                                               
end function

#---------------------------------------------------------                                                                                                 
 function ctc69m27_gera_codigo()                                
#---------------------------------------------------------              
                                                                        
                                                                                                             
define lr_retorno record                                                
	 codigo integer                                                       
end record                                                              
                                                                        
initialize lr_retorno.* to null                                         
                                                                        
   open c_ctc69m27_007 using m_chave                              
   whenever error continue                                              
   fetch c_ctc69m27_007 into  lr_retorno.codigo                           
   whenever error stop                                                  
                                                                        
   if lr_retorno.codigo is null or                                      
   	  lr_retorno.codigo = 0     then	  	                              
   	    let lr_retorno.codigo = 1                                       
   else                                                                 
   	    let lr_retorno.codigo =  lr_retorno.codigo + 1                  
   end if                                                               
                                                                        
   return lr_retorno.codigo                                             
                                                                        
end function                                                            





             
          






                                                                                      