#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc53m25                                                   # 
# Objetivo.......: Cadastro de Blocos                                         # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 31/03/2014                                                 # 
#.............................................................................# 

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc53m25 array[500] of record
      blocod   integer
    , blodes   char(60)   
end record
 
define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_chave     like datkdominio.cponom

define  m_prepare  smallint

#===============================================================================
 function ctc53m25_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = ' select cpocod       '
          ,  '      , cpodes       '          
          ,  '   from datkdominio  '
          ,  '  where cponom = ? " ' 
          ,  '  order by 1         '
 prepare p_ctc53m25_001 from l_sql
 declare c_ctc53m25_001 cursor for p_ctc53m25_001
 	
 let l_sql = ' select count(*)    '
          ,  '   from datkdominio '
          ,  '  where cponom = ?  '        
          ,  '   and  cpocod = ?  '
 prepare p_ctc53m25_002 from l_sql
 declare c_ctc53m25_002 cursor for p_ctc53m25_002
 
 let l_sql = ' update datkdominio    '
           ,  '     set cpodes  = ?  '                      
           ,  '   where cpocod  = ?  '       
           ,  '     and cponom  = ?  '  
 prepare p_ctc53m25_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc53m25_004 from l_sql 	
  
 
 let l_sql = '  delete datkdominio    '                               	
         ,  '   where cpocod = ?      '                             	
         ,  '   and cponom   = ?      '                             	
 prepare p_ctc53m25_005 from l_sql 
 
 
 let l_sql = ' select count(*)    '         
          ,  '   from datkdominio '              
          ,  '  where cponom = ?  '   
          ,  '   and  cpodes = ?  '               
 prepare p_ctc53m25_006 from l_sql               
 declare c_ctc53m25_006 cursor for p_ctc53m25_006
 
                            
 let m_prepare = true


end function

#===============================================================================
 function ctc53m25()
#===============================================================================
 
 
define lr_retorno record
    flag                smallint ,
    cont                integer  ,
    blocod              integer  ,
    blodes              char(60) ,
    msg                 char(60) ,
    data_atual          date
end record
  
for  arr_aux  =  1  to  500                  
   initialize  ma_ctc53m25[arr_aux].* to  null  
end  for                                     
 
 
 initialize lr_retorno.* to null 
 
 let arr_aux = 1 
 
 let m_chave = "PF_BLOCO"
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc53m25_prepare()
 end if
    

 options delete key F2
 
 open window w_ctc53m25 at 6,2 with form 'ctc53m25'
 attribute(form line 1)
  
 let lr_retorno.msg = '                (F17)Abandona, (F1)Inclui, (F2)Exclui'
 
 display by name lr_retorno.msg    
  
  open c_ctc53m25_001 using m_chave  
  foreach c_ctc53m25_001 into ma_ctc53m25[arr_aux].blocod 
                            , ma_ctc53m25[arr_aux].blodes                          
                           
                           
       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Bloco Excedido! Foram Encontradas Mais de 500 Blocos!"
          exit foreach
       end if
       
  end foreach 
  
  let m_operacao = " " 
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 

  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc53m25 without defaults from s_ctc53m25.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
                
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc53m25[arr_aux].blocod  is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
              
      #---------------------------------------------
       before field blocod 
      #---------------------------------------------
                  
        if ma_ctc53m25[arr_aux].blocod  is null then                                                   
           display ma_ctc53m25[arr_aux].blocod  to s_ctc53m25[scr_aux].blocod  attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          let lr_retorno.blocod = ma_ctc53m25[arr_aux].blocod
          display ma_ctc53m25[arr_aux].* to s_ctc53m25[scr_aux].* attribute(reverse)                         
        end if                                                                                               
                      
        
         
      #---------------------------------------------
       after field blocod                    
      #---------------------------------------------
          
        if m_operacao = 'i' then
        	
        	if ma_ctc53m25[arr_aux].blocod  is null then
        		 error "Por Favor Informe o Codigo do Bloco"
        		 next field blocod          		
          end if 
          
          
          open c_ctc53m25_002 using m_chave
                                   ,ma_ctc53m25[arr_aux].blocod         
          whenever error continue                                                
          fetch c_ctc53m25_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Codigo ja Cadastrado!" 
             next field blocod  
          end if 
                        
        else          
        	let ma_ctc53m25[arr_aux].blocod = lr_retorno.blocod
        	display ma_ctc53m25[arr_aux].* to s_ctc53m25[scr_aux].*       	                                                    
        end if
        
       
      
      #---------------------------------------------
       before field blodes
      #---------------------------------------------         
         display ma_ctc53m25[arr_aux].blodes to s_ctc53m25[scr_aux].blodes attribute(reverse)         
         let lr_retorno.blodes =  ma_ctc53m25[arr_aux].blodes                                        
      
      #---------------------------------------------
       after field blodes
      #---------------------------------------------
         
         if fgl_lastkey() = fgl_keyval ("up")     or            
            fgl_lastkey() = fgl_keyval ("left")   then   
               next field blocod 
         end if 
         
         if ma_ctc53m25[arr_aux].blodes is null then
         	  error "Por Favor Informe a Descricao do Bloco "
        		next field blodes          		        	
         end if 
         
         
         open c_ctc53m25_006 using m_chave
                                  ,ma_ctc53m25[arr_aux].blodes 
         whenever error continue                               
         fetch c_ctc53m25_006 into lr_retorno.cont             
         whenever error stop                                   
                                                               
         if lr_retorno.cont >  0   then                        
            error " Descricao ja Cadastrado!"                                           
            next field blodes                                  
         end if                                                       
         
         
         if m_operacao <> 'i' then 
                        
            if ma_ctc53m25[arr_aux].blodes <> lr_retorno.blodes then
               	
               		             	                                                                                                    
                whenever error continue 
                execute p_ctc53m25_003 using ma_ctc53m25[arr_aux].blodes                                           
                                           , ma_ctc53m25[arr_aux].blocod
                                           , m_chave
                whenever error continue 
                
                if sqlca.sqlcode <> 0 then
                    error 'ERRO(',sqlca.sqlcode,') na Alteracao do Bloco!'       
                else
                	  error 'Dados Alterados com Sucesso!' 
                end if 
              end if  
              
              let m_operacao = " "
              next field blocod                                
         else
           
                              
            let lr_retorno.data_atual = today 
           
           whenever error continue
           execute p_ctc53m25_004 using ma_ctc53m25[arr_aux].blocod 
                                      , ma_ctc53m25[arr_aux].blodes 
                                      , m_chave                                    
                                      , lr_retorno.data_atual
                                      
           whenever error continue
           if sqlca.sqlcode = 0 then
              error 'Dados Incluidos com Sucesso!'                                                                                                                                            
           else
              error 'ERRO(',sqlca.sqlcode,') na Insercao do Bloco!'
           end if
           
           display ma_ctc53m25[arr_aux].blocod   to s_ctc53m25[scr_aux].blocod 
           display ma_ctc53m25[arr_aux].blodes   to s_ctc53m25[scr_aux].blodes 
           
           let m_operacao = " "  
           next field blocod 
           
         end if
         
         display ma_ctc53m25[arr_aux].blocod   to s_ctc53m25[scr_aux].blocod
         display ma_ctc53m25[arr_aux].blodes   to s_ctc53m25[scr_aux].blodes
             
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      
      #---------------------------------------------                          
       before insert                                                          
      #---------------------------------------------                          
                                    
         let m_operacao = 'i'                                                 
                                                                              
         initialize  ma_ctc53m25[arr_aux] to null                             
                                                                              
         display ma_ctc53m25[arr_aux].blocod   to s_ctc53m25[scr_aux].blocod  
         display ma_ctc53m25[arr_aux].blodes   to s_ctc53m25[scr_aux].blodes  
      
          
      
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc53m25[arr_aux].blocod  is null   then                    	
            continue input                                                  	
         else                                                               	
            if not ctc53m25_delete(ma_ctc53m25[arr_aux].blocod) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if                                                          	
         end if                                                             	
         	     
          
  end input
  
 close window w_ctc53m25
 
 if lr_retorno.flag = 1 then
    call ctc53m25()
 end if
 
 
end function

#==============================================                                                
 function ctc53m25_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
	blocod   integer     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DE BLOCO ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        whenever error continue                                                                
        execute p_ctc53m25_005 using lr_param.blocod 
                                    ,m_chave                                                    
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Bloco!'   
           return false                                                                                                                                               
        end if                                                                                                                                                                               
        return true                                                                            
     else                                                                                      
        return false                                                                           
     end if                                                                                    
                                                                                               
end function                                                                                   

































             
          






                                                                                      