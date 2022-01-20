#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc91m37                                                   # 
# Objetivo.......: Cadastro Alerta X Motivo de Hospedagem                     # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 27/10/2014                                                 # 
#.............................................................................# 
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc91m37 array[04] of record
      linha char(40)            
end record


define mr_param   record
     itaclisgmcod   smallint,                    
     itaclisgmdes   char(60),                    
     asimtvcod      like datkasimtv.asimtvcod , 
     asimtvdes      like datkasimtv.asimtvdes ,
     linha1         char(40)                  ,
     linha2         char(40)                  ,
     linha3         char(40)                  ,
     linha4         char(40)                  
end record
 
define mr_ctc91m37 record
      atldat          date    
     ,funmat          char(20)
     ,msg             char(80)
     ,cpocod          like datkdominio.cpocod  
end record

define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

define m_chave     like datkdominio.cponom 

#===============================================================================
 function ctc91m37_prepare()
#===============================================================================

define l_sql char(10000)
                      
 let l_sql = '  select cpodes,         '  
         ,   '  atlult[01,10],         '  
         ,   '  atlult[12,18]          '
         ,  '  from datkdominio        '     
         ,  '  where cponom = ?        '     
         ,  '  order by cpocod         '     
 prepare p_ctc91m37_001 from l_sql
 declare c_ctc91m37_001 cursor for p_ctc91m37_001
 	
 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
          ,  ' and   cpocod = ?               '
 prepare p_ctc91m37_002 from l_sql
 declare c_ctc91m37_002 cursor for p_ctc91m37_002

 let l_sql =  ' update datkdominio             '
           ,  '     set cpodes           = ? , ' 
           ,  '         atlult[01,10]    = ? , '
           ,  '         atlult[12,18]    = ?   '
           ,  ' where cponom = ?               '    
           ,  ' and   cpocod = ?               '                 
 prepare p_ctc91m37_003 from l_sql
  
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc91m37_004 from l_sql 	
  
 
 
 let l_sql = '  delete datkdominio           '                               	
            ,'    where cponom  =  ?         '                           	                            	
 prepare p_ctc91m37_006 from l_sql 
 
 
 let l_sql = ' select count(*)                '   
          ,  ' from datkdominio               '   
          ,  ' where cponom = ?               '   
 prepare p_ctc91m37_007 from l_sql                
 declare c_ctc91m37_007 cursor for p_ctc91m37_007

 
 let m_prepare = true


end function

#===============================================================================
 function ctc91m37(lr_param)
#===============================================================================
 
define lr_param record
    itaclisgmcod  smallint                   ,  
    itaclisgmdes  char(60)                   ,   
    asimtvcod     like datkasimtv.asimtvcod  , 
    asimtvdes     like datkasimtv.asimtvdes 
end record
 
define lr_retorno record
    flag       smallint                     ,
    cont       integer                      ,
    limite     integer                      ,
    confirma   char(01) 
end record
 
 let mr_param.itaclisgmcod  = lr_param.itaclisgmcod   
 let mr_param.itaclisgmdes  = lr_param.itaclisgmdes   
 let mr_param.asimtvcod     = lr_param.asimtvcod
 let mr_param.asimtvdes     = lr_param.asimtvdes 

 
 
 for  arr_aux  =  1  to  04                  
    initialize  ma_ctc91m37[arr_aux].* to  null  
 end  for                                     
 
 
 initialize mr_ctc91m37.*, lr_retorno.* to null 
 
 let arr_aux = 1
 
 if m_prepare is null or
    m_prepare <> true then
    call ctc91m37_prepare()
 end if
    
 let m_chave = ctc91m37_monta_chave(mr_param.itaclisgmcod  , 
                                    mr_param.asimtvcod     )
 let m_operacao = 'i' 
 
 #--------------------------------------------------------     
 # Recupera os Dados do Segmento X Motivo         
 #--------------------------------------------------------     
                                                               
                                                               
 open c_ctc91m37_001  using  m_chave                           
 foreach c_ctc91m37_001 into ma_ctc91m37[arr_aux].linha,       
 	                           mr_ctc91m37.atldat        ,        
                             mr_ctc91m37.funmat                
                                                               
     let m_operacao = 'a'                                      
     let arr_aux = arr_aux + 1                                 
                                                               
 end foreach
 
 let mr_param.linha1 = ma_ctc91m37[1].linha
 let mr_param.linha2 = ma_ctc91m37[2].linha
 let mr_param.linha3 = ma_ctc91m37[3].linha
 let mr_param.linha4 = ma_ctc91m37[4].linha
 

 open window w_ctc91m37 at 6,2 with form 'ctc91m37'
 attribute(form line 1)
  
 let mr_ctc91m37.msg =  '                      (F17)Abandona,(F2)Exclui'
 
   
  display by name mr_param.itaclisgmcod   
                , mr_param.itaclisgmdes   
                , mr_param.asimtvcod
                , mr_param.asimtvdes 
                , mr_param.linha1
                , mr_param.linha2
                , mr_param.linha3
                , mr_param.linha4
                , mr_ctc91m37.atldat 
                , mr_ctc91m37.funmat                 
                , mr_ctc91m37.msg  
 
   
  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if 
  
  
 input by name mr_param.linha1, 
 	             mr_param.linha2,
 	             mr_param.linha3,
 	             mr_param.linha4 without defaults 
      
      
      #---------------------------------------------
       before field linha1
      #---------------------------------------------
        
        display by name mr_param.linha1  attribute (reverse)                                                                                     
      
      #---------------------------------------------          
       after field linha1                                    
      #---------------------------------------------          
                                                              
        display by name mr_param.linha1 
        
      #---------------------------------------------             
       before field linha2                                       
      #---------------------------------------------             
                                                                 
        display by name mr_param.linha2  attribute (reverse)     
                                                                 
      #---------------------------------------------             
       after field linha2                                        
      #---------------------------------------------             
                                                                 
        display by name mr_param.linha2
        
        if fgl_lastkey() = fgl_keyval ("up")     or
           fgl_lastkey() = fgl_keyval ("left")   then   
             next field linha1 
        end if

      #---------------------------------------------             
       before field linha3                                       
      #---------------------------------------------             
                                                                 
        display by name mr_param.linha3  attribute (reverse)     
                                                                 
      #---------------------------------------------             
       after field linha3                                        
      #---------------------------------------------             
                                                                 
        display by name mr_param.linha3
        
        if fgl_lastkey() = fgl_keyval ("up")     or        
           fgl_lastkey() = fgl_keyval ("left")   then      
             next field linha2                             
        end if                                                                       
      
      
      #---------------------------------------------             
       before field linha4                                       
      #---------------------------------------------             
                                                                 
        display by name mr_param.linha4  attribute (reverse)     
                                                                 
      #---------------------------------------------             
       after field linha4                                        
      #---------------------------------------------                
                                                                 
        display by name mr_param.linha4
        
        if fgl_lastkey() = fgl_keyval ("up")     or        
           fgl_lastkey() = fgl_keyval ("left")   then      
             next field linha3                             
        end if                                                                                       
             
                      
         if m_operacao <> 'i' then                         
                            
            #--------------------------------------------------------
            # Atualiza Associacao Alerta X Motivo         
            #--------------------------------------------------------
            
            call ctc91m37_altera()
            next field linha1                              
                                                 
         else
            
           
            #-------------------------------------------------------- 
            # Inclui Associacao Alerta X Motivo                  
            #-------------------------------------------------------- 
            call ctc91m37_inclui()                
            next field linha1            
         
         end if
                 
               
      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
         	
         	
      #---------------------------------------------                     
       on key (F2)                                                       
      #---------------------------------------------                     
                                                             	            
        
         #-------------------------------------------------------- 
         # Exclui Associacao Alerta X Motivo                  
         #-------------------------------------------------------- 
         
         if not ctc91m37_delete() then       	
             let lr_retorno.flag = 1                                              	
             exit input                                                  	
         else
         	  error "Dados Excluidos com Sucesso"
         	  
         	  let mr_param.linha1 = null
         	  let mr_param.linha2 = null
         	  let mr_param.linha3 = null
         	  let mr_param.linha4 = null
         	  
         	  display by name mr_param.*
         	  
         end if   
         
      
         next field linha1
                                                                   	
 
      
  end input
 
 close window w_ctc91m37
 
 if lr_retorno.flag = 1 then
    call ctc91m37(mr_param.itaclisgmcod   
                 ,mr_param.itaclisgmdes   
                 ,mr_param.asimtvcod
                 ,mr_param.asimtvdes)
 end if
 
 
end function


                               
              

#==============================================                                                
 function ctc91m37_delete()                                                               
#==============================================                                                

define lr_retorno record
	confirma char(1)                                                                      
end record

initialize lr_retorno.* to null                                                                                               
                                                                                               
  call cts08g01("A","S"                                                                        
               ,""                                                            
               ,"CONFIRMA EXCLUSAO "                                                       
               ,"DO ALERTA ?"                                                                
               ," ")                                                                           
     returning lr_retorno.confirma                                                                      
                                                                                               
     if lr_retorno.confirma  = "S" then                                                                  
                                                                                                                                                                       
        begin work
        
        whenever error continue                                                                
        execute p_ctc91m37_006 using m_chave
                                                                                                                                                                                                                                    
        whenever error stop   
        if sqlca.sqlcode <> 0 then                                                             
           if sqlca.sqlcode <> notfound then
             error 'ERRO (',sqlca.sqlcode,') ao Excluir o Alerta!'   
             rollback work
             return false
           else
           	 return true
           end if                                                                                                                                               
        end if 
                                                                                                                                                                       
        commit work
        let m_operacao = 'i' 
        return true                                                                            
     else                                                                                      
        return false                                                                           
     end if                                                                                    
                                                                                               
end function 

#---------------------------------------------------------                                                                                            
 function ctc91m37_altera()                                             
#---------------------------------------------------------

define lr_retorno record                  
   data_atual date,
   funmat     like isskfunc.funmat
end record

define l_arr_aux integer	                              
                                          
initialize lr_retorno.* to null           
                                                                                 
    let lr_retorno.data_atual = today
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"
    
    let ma_ctc91m37[1].linha = mr_param.linha1
    let ma_ctc91m37[2].linha = mr_param.linha2
    let ma_ctc91m37[3].linha = mr_param.linha3
    let ma_ctc91m37[4].linha = mr_param.linha4
    
       
    for  l_arr_aux  =  1  to  04
    	 
         whenever error continue 
         execute p_ctc91m37_003 using ma_ctc91m37[l_arr_aux].linha   
                                    , lr_retorno.data_atual          
                                    , lr_retorno.funmat         
                                    , m_chave                                                
                                    , l_arr_aux
         whenever error continue 
         
         if sqlca.sqlcode <> 0 then
             error 'ERRO(',sqlca.sqlcode,') na Alteracao do Alerta!'       
         else
         	  error 'Dados Alterados com Sucesso!' 
         end if   
         
         let m_operacao = 'a'           
    	                      
    end  for                                       
          
    
     
                                                                                      
end function   

#---------------------------------------------------------                                                                                            
 function ctc91m37_inclui()                                             
#---------------------------------------------------------   

define lr_retorno record
   data_atual date                    ,
   atlult     like datkdominio.atlult
end record

define l_arr_aux integer	 	  

initialize lr_retorno.* to null                                     

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&" 
    
    let ma_ctc91m37[1].linha = mr_param.linha1
    let ma_ctc91m37[2].linha = mr_param.linha2
    let ma_ctc91m37[3].linha = mr_param.linha3
    let ma_ctc91m37[4].linha = mr_param.linha4
    
   
    for  l_arr_aux  =  1  to  04
    
        whenever error continue
        execute p_ctc91m37_004 using l_arr_aux  
                                   , ma_ctc91m37[l_arr_aux].linha
                                   , m_chave
                                   , lr_retorno.atlult
                                   
        whenever error continue
        
        if sqlca.sqlcode = 0 then
           error 'Dados Incluidos com Sucesso!'             
           let m_operacao = 'a'                                                                                                                            
        else
           error 'ERRO(',sqlca.sqlcode,') na Insercao do Alerta!'
           let m_operacao = 'i'
        end if
    end for
                        
                                                                                      
end function 

#===============================================================================     
 function ctc91m37_monta_chave(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    itaclisgmcod  smallint                    ,                                           
    asimtvcod     like  datkasimtv.asimtvcod   
end record

define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

let lr_retorno.chave = "SGM_A_MTV", lr_param.itaclisgmcod using "&&"         
                                  , lr_param.asimtvcod using "&&&"         
                             
return lr_retorno.chave 
 
end function

#---------------------------------------------------------                     
 function ctc91m37_valida_exclusao(lr_param)                                   
#---------------------------------------------------------                     
                                                                               
define lr_param record                                                         
    itaclisgmcod smallint                    ,                                   
    asimtvcod    like  datkasimtv.asimtvcod                                                                      
end record                                                                     
                                                                               
                                                                               
define lr_retorno record                                                       
	cont integer                                                                 
end record                                                                     
                                                                               
if m_prepare is null or                                                        
    m_prepare <> true then                                                     
    call ctc91m37_prepare()                                                    
end if                                                                         
                                                                               
   initialize lr_retorno.* to null                                             
                                                                               
   let m_chave = ctc91m37_monta_chave(lr_param.itaclisgmcod   ,                      
                                      lr_param.asimtvcod      )                     
                                                                               
   open c_ctc91m37_007 using m_chave                                           
                                                                               
   whenever error continue                                                     
   fetch c_ctc91m37_007 into  lr_retorno.cont                                  
   whenever error stop                                                         
                                                                               
   if lr_retorno.cont > 0 then                                                 
      return false                                                             
   else                                                                        
   	  return true                                                              
   end if                                                                      
                                                                               
end function                                                                   
