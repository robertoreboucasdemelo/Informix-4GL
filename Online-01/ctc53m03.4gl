#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc53m03                                                   # 
# Objetivo.......: Cadastro do Perfil                                         # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 31/03/2014                                                 # 
#.............................................................................# 

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc53m03 array[500] of record
      avialgmtv   integer
    , avialgdes   char(60)   
end record
 
define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_chave     like datkdominio.cponom

define  m_prepare  smallint

#===============================================================================
 function ctc53m03_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = ' select cpocod       '
          ,  '      , cpodes       '          
          ,  '   from datkdominio  '
          ,  '  where cponom = ? " ' 
          ,  '  order by 1         '
 prepare p_ctc53m03_001 from l_sql
 declare c_ctc53m03_001 cursor for p_ctc53m03_001
 	
 let l_sql = ' select count(*)    '
          ,  '   from datkdominio '
          ,  '  where cponom = ?  '        
          ,  '   and  cpocod = ?  '
 prepare p_ctc53m03_002 from l_sql
 declare c_ctc53m03_002 cursor for p_ctc53m03_002
 
 let l_sql = ' update datkdominio    '
           ,  '     set cpodes  = ?  '                      
           ,  '   where cpocod  = ?  '       
           ,  '     and cponom  = ?  '  
 prepare p_ctc53m03_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc53m03_004 from l_sql 	
  
 
 let l_sql = '  delete datkdominio    '                               	
         ,  '   where cpocod = ?      '                             	
         ,  '   and cponom   = ?      '                             	
 prepare p_ctc53m03_005 from l_sql 
 
 
 let l_sql = ' select count(*)    '         
          ,  '   from datkdominio '              
          ,  '  where cponom = ?  '   
          ,  '   and  cpodes = ?  '               
 prepare p_ctc53m03_006 from l_sql               
 declare c_ctc53m03_006 cursor for p_ctc53m03_006
 
                            
 let m_prepare = true


end function

#===============================================================================
 function ctc53m03()
#===============================================================================
 
 
define lr_retorno record
    flag                smallint ,
    cont                integer  ,
    avialgmtv           integer  ,
    avialgdes           char(60) ,
    msg                 char(60)
end record
  
for  arr_aux  =  1  to  500                  
   initialize  ma_ctc53m03[arr_aux].* to  null  
end  for                                     
 
 
 initialize lr_retorno.* to null 
 
 let arr_aux = 1 
 
 let m_chave = "PF_MOTIVO"
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc53m03_prepare()
 end if
    

 options delete key F2
 
 open window w_ctc53m03 at 6,2 with form 'ctc53m03'
 attribute(form line 1)
  
 let lr_retorno.msg = '                (F17)Abandona, (F1)Inclui, (F2)Exclui'
 
 display by name lr_retorno.msg    
  
  open c_ctc53m03_001 using m_chave  
  foreach c_ctc53m03_001 into ma_ctc53m03[arr_aux].avialgmtv 
                            , ma_ctc53m03[arr_aux].avialgdes                          
                           
                           
       let arr_aux = arr_aux + 1
       
       if arr_aux > 500 then
          error " Motivo Excedido! Foram Encontradas Mais de 500 Motivos!"
          exit foreach
       end if
       
  end foreach 
  
  let m_operacao = " " 
  
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if
 

  
 call set_count(arr_aux - 1 ) 

 input array ma_ctc53m03 without defaults from s_ctc53m03.*
      
      #---------------------------------------------
       before row
      #---------------------------------------------
                
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          
          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             
             if ma_ctc53m03[arr_aux].avialgmtv  is null then
                let m_operacao = 'i'             
             end if
          
          end if
          
              
      #---------------------------------------------
       before field avialgmtv 
      #---------------------------------------------
                  
        if ma_ctc53m03[arr_aux].avialgmtv  is null then                                                   
           display ma_ctc53m03[arr_aux].avialgmtv  to s_ctc53m03[scr_aux].avialgmtv  attribute(reverse)  
           let m_operacao = 'i'                                                                              
        else                                                                                                 
          let lr_retorno.avialgmtv = ma_ctc53m03[arr_aux].avialgmtv
          display ma_ctc53m03[arr_aux].* to s_ctc53m03[scr_aux].* attribute(reverse)                         
        end if                                                                                               
                      
        
         
      #---------------------------------------------
       after field avialgmtv                    
      #---------------------------------------------
          
        if m_operacao = 'i' then
        	
        	if ma_ctc53m03[arr_aux].avialgmtv  is null then
        		 error "Por Favor Informe o Codigo do Motivo"
        		 next field avialgmtv          		
          end if 
          
          
          open c_ctc53m03_002 using m_chave
                                   ,ma_ctc53m03[arr_aux].avialgmtv         
          whenever error continue                                                
          fetch c_ctc53m03_002 into lr_retorno.cont           
          whenever error stop                                                    
                                                                                 
          if lr_retorno.cont >  0   then                                          
             error " Codigo ja Cadastrado!" 
             next field avialgmtv  
          end if 
                        
        else          
        	let ma_ctc53m03[arr_aux].avialgmtv = lr_retorno.avialgmtv
        	display ma_ctc53m03[arr_aux].* to s_ctc53m03[scr_aux].*       	                                                    
        end if
        
       
      
      #---------------------------------------------
       before field avialgdes
      #---------------------------------------------         
         display ma_ctc53m03[arr_aux].avialgdes to s_ctc53m03[scr_aux].avialgdes attribute(reverse)         
         let lr_retorno.avialgdes =  ma_ctc53m03[arr_aux].avialgdes                                        
      
      #---------------------------------------------
       after field avialgdes
      #---------------------------------------------
         
         if fgl_lastkey() = fgl_keyval ("up")     or            
            fgl_lastkey() = fgl_keyval ("left")   then   
               next field avialgmtv 
         end if 
         
         if ma_ctc53m03[arr_aux].avialgdes is null then
         	  error "Por Favor Informe a Descricao do Motivo "
        		next field avialgdes          		        	
         end if 
         
         
         open c_ctc53m03_006 using m_chave
                                  ,ma_ctc53m03[arr_aux].avialgdes 
         whenever error continue                               
         fetch c_ctc53m03_006 into lr_retorno.cont             
         whenever error stop                                   
                                                               
         if lr_retorno.cont >  0   then                        
            error " Descricao ja Cadastrado!"                                           
            next field avialgdes                                  
         end if                                                       
         
         
         if m_operacao <> 'i' then 
                        
            if ma_ctc53m03[arr_aux].avialgdes <> lr_retorno.avialgdes then
               	
               		             	                                                                                                    
                whenever error continue 
                execute p_ctc53m03_003 using ma_ctc53m03[arr_aux].avialgdes                                           
                                           , ma_ctc53m03[arr_aux].avialgmtv
                                           , m_chave
                whenever error continue 
                
                if sqlca.sqlcode <> 0 then
                    error 'ERRO(',sqlca.sqlcode,') na Alteracao do Motivo!'       
                else
                	  error 'Dados Alterados com Sucesso!' 
                end if 
              end if  
              
              let m_operacao = " "
              next field avialgmtv                                
         else
           
                              
           whenever error continue
           execute p_ctc53m03_004 using ma_ctc53m03[arr_aux].avialgmtv 
                                      , ma_ctc53m03[arr_aux].avialgdes 
                                      , m_chave                                    
                                      , 'today'
                                      
           whenever error continue
           if sqlca.sqlcode = 0 then
              error 'Dados Incluidos com Sucesso!'                                                                                                                                            
           else
              error 'ERRO(',sqlca.sqlcode,') na Insercao do Motivo!'
           end if
           
           display ma_ctc53m03[arr_aux].avialgmtv   to s_ctc53m03[scr_aux].avialgmtv 
           display ma_ctc53m03[arr_aux].avialgdes   to s_ctc53m03[scr_aux].avialgdes 
           
           let m_operacao = " "  
           next field avialgmtv 
           
         end if
         
         display ma_ctc53m03[arr_aux].avialgmtv   to s_ctc53m03[scr_aux].avialgmtv
         display ma_ctc53m03[arr_aux].avialgdes   to s_ctc53m03[scr_aux].avialgdes
             
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      
      #---------------------------------------------                          
       before insert                                                          
      #---------------------------------------------                          
                                    
         let m_operacao = 'i'                                                 
                                                                              
         initialize  ma_ctc53m03[arr_aux] to null                             
                                                                              
         display ma_ctc53m03[arr_aux].avialgmtv   to s_ctc53m03[scr_aux].avialgmtv  
         display ma_ctc53m03[arr_aux].avialgdes   to s_ctc53m03[scr_aux].avialgdes  
      
          
      
      #---------------------------------------------                     
       before delete                                                     
      #---------------------------------------------                     
         if ma_ctc53m03[arr_aux].avialgmtv  is null   then                    	
            continue input                                                  	
         else                                                               	
            if not ctc53m03_delete(ma_ctc53m03[arr_aux].avialgmtv) then       	
                let lr_retorno.flag = 1                                              	
                exit input                                                  	
            end if                                                          	
         end if                                                             	
         	     
          
  end input
  
 close window w_ctc53m03
 
 if lr_retorno.flag = 1 then
    call ctc53m03()
 end if
 
 
end function

#==============================================                                                
 function ctc53m03_delete(lr_param)                                                               
#==============================================                                                

define lr_param record
	avialgmtv   integer     
end record                                                       

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,"CONFIRMA EXCLUSAO"                                                            
               ,"DO CODIGO "                                                       
               ,"DE MOTIVO ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
        let m_operacao = 'd'                                                                   
                                                                                               
        whenever error continue                                                                
        execute p_ctc53m03_005 using lr_param.avialgmtv 
                                    ,m_chave                                                    
                                                                                                                                                     
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Motivo!'   
           return false                                                                                                                                               
        end if                                                                                                                                                                               
        return true                                                                            
     else                                                                                      
        return false                                                                           
     end if                                                                                    
                                                                                               
end function                                                                                   

































             
          






                                                                                      