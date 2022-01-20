#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc53m04                                                   # 
# Objetivo.......: Cadastro de Segmento X Assunto                              # 
# Analista Resp. : Humberto Benedito                                          # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 01/04/2014                                                 # 
#.............................................................................#  
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define  m_sql       char(1)
define  m_chave     char(20) 
define  arr_aux     integer 

define mr_ctc53m04     record                     
   codper    integer                     ,        
   desper    char(60)                    ,        
   atldat    date                        ,        
   funmat    char(20)                             
end record                                        

#------------------------------------------------------------
 function ctc53m04_prepare()
#------------------------------------------------------------

define l_sql char(10000)

 
 let l_sql = ' select cpocod       ' 
          ,  '   from datkdominio  '
          ,  '   where cponom = ?  '   
          ,  '   and   cpocod = ?  '        
 prepare p_ctc53m04_001 from l_sql
 declare c_ctc53m04_001 cursor for p_ctc53m04_001

 
 let l_sql = ' select min(cpocod)  '
           , '  from datkdominio   '
           , '  where cponom = ?   ' 
           , '  and   cpocod  >  ? '
 prepare p_ctc53m04_002 from l_sql
 declare c_ctc53m04_002 cursor for p_ctc53m04_002
 
 
 let l_sql = ' select max(cpocod)  '
           , '  from datkdominio   '
           , '  where cponom = ?   ' 
           , '  and   cpocod  <  ? '
 prepare p_ctc53m04_003 from l_sql
 declare c_ctc53m04_003 cursor for p_ctc53m04_003

 
 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc53m04_005 from l_sql
 
 
 
 let l_sql = ' select count(*)     '
          ,  '   from datkdominio  '
          ,  '   where cponom = ?  '   
          ,  '   and   cpocod = ?  '    
 prepare p_ctc53m04_007 from l_sql
 declare c_ctc53m04_007 cursor for p_ctc53m04_007

 
 let l_sql = ' select cpocod,              '
          ,  '        atlult[01,10],       '
          ,  '        atlult[12,18]        '      
          ,  '   from datkdominio '
          ,  '  where cponom = ?  ' 
          ,  '  and   cpocod = ?  '       
 prepare p_ctc53m04_008 from l_sql
 declare c_ctc53m04_008 cursor for p_ctc53m04_008
 	
 
 let l_sql = ' select min(cpocod)  '   
          ,  '   from datkdominio  '   
          ,  '   where cponom = ?  '         	
 prepare p_ctc53m04_009 from l_sql               	
 declare c_ctc53m04_009 cursor for p_ctc53m04_009	
 	
 let l_sql =  ' insert into datkdominio   '        
           ,  '   (cponom                 '        
           ,  '   ,cpocod                 '        	
           ,  '   ,cpodes                 '        	
           ,  '   ,atlult)                '        	
           ,  ' values(?,?,?,?)           '        	
 prepare p_ctc53m04_010 from l_sql
 
 let l_sql = ' delete from datkdominio '   
          ,  '   where cponom = ?  '         	
 prepare p_ctc53m04_011 from l_sql
 
 
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_01_ASS_DIA_*"  '         	
 prepare p_ctc53m04_012 from l_sql               	
 declare c_ctc53m04_012 cursor for p_ctc53m04_012
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_DIA_01_*"  '         	
 prepare p_ctc53m04_013 from l_sql               	
 declare c_ctc53m04_013 cursor for p_ctc53m04_013
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_01_ASS_NAT_*"  '         	
 prepare p_ctc53m04_014 from l_sql               	
 declare c_ctc53m04_014 cursor for p_ctc53m04_014
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_01_ASS_LIM_*"  '         	
 prepare p_ctc53m04_015 from l_sql               	
 declare c_ctc53m04_015 cursor for p_ctc53m04_015
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_ACN_01_*"  '         	
 prepare p_ctc53m04_016 from l_sql               	
 declare c_ctc53m04_016 cursor for p_ctc53m04_016
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PFACN01*"  '         	
 prepare p_ctc53m04_017 from l_sql               	
 declare c_ctc53m04_017 cursor for p_ctc53m04_017
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_01_ASS_KM_*"  '         	
 prepare p_ctc53m04_018 from l_sql               	
 declare c_ctc53m04_018 cursor for p_ctc53m04_018
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_TIP_01_*"  '         	
 prepare p_ctc53m04_019 from l_sql               	
 declare c_ctc53m04_019 cursor for p_ctc53m04_019							
 
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_MTV01*"  '         	
 prepare p_ctc53m04_020 from l_sql               	
 declare c_ctc53m04_020 cursor for p_ctc53m04_020
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_A01*"  '         	
 prepare p_ctc53m04_021 from l_sql               	
 declare c_ctc53m04_021 cursor for p_ctc53m04_021			
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_ALE01*"  '         	
 prepare p_ctc53m04_022 from l_sql               	
 declare c_ctc53m04_022 cursor for p_ctc53m04_022
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_01_ASS_BLO_*"  '         	
 prepare p_ctc53m04_023 from l_sql               	
 declare c_ctc53m04_023 cursor for p_ctc53m04_023	
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_BLO_01_*"  '         	
 prepare p_ctc53m04_024 from l_sql               	
 declare c_ctc53m04_024 cursor for p_ctc53m04_024
 	
 let l_sql = ' select cponom  ,  ' 
          ,  '        cpocod  ,  '
          ,  '        cpodes  ,  '      
          ,  '        atlult     '      
          ,  ' from datkdominio  '   
          ,  ' where cponom matches "PF_01_ASS_PRO_*"  '         	
 prepare p_ctc53m04_025 from l_sql               	
 declare c_ctc53m04_025 cursor for p_ctc53m04_025		

            
 
let m_sql = 'S'

end function

#------------------------------------------------------------
 function ctc53m04()
#------------------------------------------------------------


 let int_flag = false

 initialize mr_ctc53m04.*  to null
 

 call ctc53m04_prepare()
 
 let m_chave = "PF_REGRA_PERFIL"
 
 open window ctc53m04 at 4,2 with form "ctc53m04"


 menu "PERFIL"

 command key ("S") "Seleciona"
                   "Pesquisa Segmento Conforme Criterios"
          
          call ctc53m04_seleciona()  returning mr_ctc53m04.*
          
          if mr_ctc53m04.codper  is not null  then
             message ""
             next option "Proximo"
          end if

 command key ("P") "Proximo"
                   "Mostra Proximo Segmento Selecionado"
          message ""
         
             call ctc53m04_proximo()
                  returning mr_ctc53m04.*
             
             if mr_ctc53m04.codper is null then
                display by name mr_ctc53m04.* 
                next option "Seleciona"
             end if 
         

 command key ("A") "Anterior"
                   "Mostra Segmento Anterior Selecionado"
          message ""
          
          if mr_ctc53m04.codper is not null then
             call ctc53m04_anterior()
                  returning mr_ctc53m04.*
      
             if mr_ctc53m04.codper is null then
                display by name mr_ctc53m04.*
                next option "Seleciona"
             end if
          end if


 
 command key ("I") "Inclui"
                   "Inclui Segmento"
          message "" 
          call ctc53m04_inclui()
          next option "Seleciona"

 
 command key ("V") "Assuntos"
                   "Assuntos do Segmento"
          
          if mr_ctc53m04.codper  is not null then
         
             call ctc53m05(mr_ctc53m04.codper,
                           mr_ctc53m04.desper)
          else
             error " Nenhum Segmento Selecionado!"
             next option "Seleciona"
          end if
 
 command key ("C") "Copia"
                   "Copia do Perfil"
          
          call ctc53m04_copia()
 
          
 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc53m04

 end function  


#------------------------------------------------------------
 function ctc53m04_seleciona()
#------------------------------------------------------------

 define lr_retorno record
 	  codper   integer   
 end record 	

  if m_sql <> 'S' then
    call ctc53m04_prepare()
  end if
      

 let int_flag = false
 
 initialize mr_ctc53m04.*, lr_retorno.*  to null
 
 display by name mr_ctc53m04.*

 input by name mr_ctc53m04.codper

    before field codper
        display by name mr_ctc53m04.codper attribute (reverse)

    after  field codper
        display by name mr_ctc53m04.codper

        open c_ctc53m04_001 using  m_chave 
                                  ,mr_ctc53m04.codper 
        whenever error continue  
        fetch c_ctc53m04_001 into lr_retorno.codper
        whenever error stop   
         
        if lr_retorno.codper  is null or
           lr_retorno.codper  = ''    then
           
           #--------------------------------------------------------
           # Recupera o Primeiro Codigo do Segmento              
           #--------------------------------------------------------
           
           open c_ctc53m04_009 using m_chave
           whenever error continue    
           fetch c_ctc53m04_009 into mr_ctc53m04.codper
           whenever error stop  
            
           if mr_ctc53m04.codper  is null or   
              mr_ctc53m04.codper  = ''    then            
              next field codper
           end if
        end if

    on key (interrupt)
        exit input
        	
            	
 end input

 if int_flag  then
    let int_flag = false
    initialize mr_ctc53m04.*   to null
    display by name mr_ctc53m04.*
    error " Operacao Cancelada!"
    return mr_ctc53m04.*
 end if

 #--------------------------------------------------------
 # Recupera os Dados do Perfil                 
 #-------------------------------------------------------- 
 
 call ctc53m04_ler()
 returning mr_ctc53m04.*

 if mr_ctc53m04.codper  is not null   then
    display by name  mr_ctc53m04.*
 else
    error " Codigo do Segmento Nao Cadastrada!"
    initialize mr_ctc53m04.*    to null
 end if

 return mr_ctc53m04.*

 end function  


#------------------------------------------------------------
 function ctc53m04_proximo()
#------------------------------------------------------------


  if m_sql <> 'S' then
    call ctc53m04_prepare()
  end if

 let int_flag = false

 #--------------------------------------------------------
 # Recupera o Proximo Codigo de Segmento                
 #--------------------------------------------------------
 
 
 if mr_ctc53m04.codper  is null   then 
    
    open c_ctc53m04_009 using m_chave
    whenever error continue  
    fetch c_ctc53m04_009 into mr_ctc53m04.codper
    whenever error stop  
    
    let mr_ctc53m04.codper = mr_ctc53m04.codper - 1
 
 end if

  open c_ctc53m04_002 using  m_chave
                            ,mr_ctc53m04.codper
  whenever error continue  
  fetch c_ctc53m04_002 into mr_ctc53m04.codper
  whenever error stop

 if mr_ctc53m04.codper  is not null   then
    
    call ctc53m04_ler()
         returning mr_ctc53m04.*

    if mr_ctc53m04.codper  is not null   then
       display by name  mr_ctc53m04.*
    else
       error "Nao ha'Segmento Nesta Direcao!"
       initialize mr_ctc53m04.*    to null
    end if
 else
    error " Nao ha' Segmento Nesta Direcao!"
    initialize mr_ctc53m04.*    to null
 end if

 return mr_ctc53m04.*

 end function    


#------------------------------------------------------------
 function ctc53m04_anterior()
#------------------------------------------------------------

  if m_sql <> 'S' then
    call ctc53m04_prepare()
  end if

 let int_flag = false

 if mr_ctc53m04.codper  is null   then
    let mr_ctc53m04.codper = " "
 end if

 
 #--------------------------------------------------------
 # Recupera o Codigo do Segmento Anterior                 
 #--------------------------------------------------------
 
 
 open c_ctc53m04_003 using  m_chave
                           ,mr_ctc53m04.codper
 fetch c_ctc53m04_003 into mr_ctc53m04.codper

 if mr_ctc53m04.codper  is not null   then

    call ctc53m04_ler()
         returning mr_ctc53m04.*

    if mr_ctc53m04.codper  is not null   then
       display by name  mr_ctc53m04.*
    else
       error " Nao ha' Segmento Nesta Direcao!"
       initialize mr_ctc53m04.*    to null
    end if
 else
    error " Nao ha' Segmento Nesta Direcao!"
    initialize mr_ctc53m04.*    to null
 end if
 
 return mr_ctc53m04.*

 end function    



#------------------------------------------------------------
 function ctc53m04_inclui()
#------------------------------------------------------------


 define lr_retorno record
     resp       char(01),
     ret        smallint,             
     mensagem   char(60),
     data_atual date    ,  
     atlult     like datkdominio.atlult
 end record

 initialize mr_ctc53m04.*, lr_retorno.*   to null
 
 let lr_retorno.ret   = 0  
                             

  if m_sql <> 'S' then
    call ctc53m04_prepare()
  end if
 
 display by name mr_ctc53m04.* 
 
  
 #-------------------------------------------------------- 
 # Abre os Campos Para Digitacao                           
 #-------------------------------------------------------- 

 call ctc53m04_input("i") returning mr_ctc53m04.*

 if int_flag  then
    let int_flag = false
    initialize mr_ctc53m04.*  to null
    display by name mr_ctc53m04.*
    error " Operacao cancelada!"
    return
 end if

 
 #--------------------------------------------------------
 # Valida se o Segmento ja Foi Criado               
 #--------------------------------------------------------
 
 if not ctc53m04_valida_geracao() then
    return
 end if
 
 let lr_retorno.data_atual = today                                                                                                         
 let lr_retorno.atlult     = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"    
 

 whenever error continue

 begin work
     
  #--------------------------------------------------------
  # Inclui o Plano/Clausula                              
  #--------------------------------------------------------
  
  whenever error continue  
  execute p_ctc53m04_005 using  mr_ctc53m04.codper    
                              , ""   
                              , m_chave   
                              , lr_retorno.atlult  
                              

  whenever error stop  
  if sqlca.sqlcode <>  0   then
     error " Erro (",sqlca.sqlcode,") na Inclusao do Segmento!"
     rollback work
     return
  end if

 commit work

 whenever error stop
 
 
 display by name  mr_ctc53m04.*

 display by name mr_ctc53m04.codper attribute (reverse)
 
 error " Inclusao Efetuada Com Sucesso, tecle ENTER!"
 
 prompt "" for char lr_retorno.resp

 initialize mr_ctc53m04.*  to null
 display by name mr_ctc53m04.*

 end function   


#--------------------------------------------------------------------
 function ctc53m04_input(lr_param)
#--------------------------------------------------------------------

 define lr_param  record
    operacao  char (1)
 end record


 define lr_retorno record 
     erro        smallint,
     mensagem    char(60),
     count       smallint,
     confirma    char(01)     
 end record

  if m_sql <> 'S' then
    call ctc53m04_prepare()
  end if

 let lr_retorno.count    = 0
 let lr_retorno.erro     = 0
 let lr_retorno.mensagem = null
 
 let int_flag = false  

 input by name   mr_ctc53m04.codper without defaults

   
    before field codper 
           display by name mr_ctc53m04.codper  attribute (reverse)

    after  field codper 
           display by name mr_ctc53m04.codper 

        
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then   
                 next field codper 
           end if

           if mr_ctc53m04.codper   is null   then
              
              #--------------------------------------------------------
              # Abre a Popup do Segmento                             
              #--------------------------------------------------------
              
              call ctc69m04_popup(8)                            
              returning mr_ctc53m04.codper
                      , mr_ctc53m04.desper 
              
              if mr_ctc53m04.codper   is null   then 
                 next field codper
              end if
           else
           	
           	 #--------------------------------------------------------
           	 # Recupera a Descricao da Empresa                              
           	 #--------------------------------------------------------
           	 
           	 call ctc69m04_recupera_descricao(8,mr_ctc53m04.codper )  
           	 returning mr_ctc53m04.desper                             
           	                                                                               
           	 if mr_ctc53m04.desper is null then                      
           	    next field codper                                              
           	 end if                                                                        
           end if 
           
           display by name mr_ctc53m04.codper 
           display by name mr_ctc53m04.desper 

       
           if lr_param.operacao = "i" then
                     
               let lr_retorno.confirma = cts08g01("C","S","",                
                                                  "DESEJA INCLUIR",          
                                                  "O SEGMENTO?",                
                                                  "")
           
           end if	                        
                                                                         
                                                                         
           if lr_retorno.confirma = "N" then                             
           	  next field regsitflg      	                             
           end if	                                                       
           
                               

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize mr_ctc53m04.*  to null
 end if

 return mr_ctc53m04.*

 end function   


#---------------------------------------------------------
 function ctc53m04_ler()
#---------------------------------------------------------


 define lr_retorno  record        
    cont           integer                    ,
    ret            smallint                   ,
    mensagem       char(60)  
 end record


  if m_sql <> 'S' then
    call ctc53m04_prepare()
  end if

 initialize lr_retorno.*   to null
 
 let lr_retorno.ret  = 0
 let lr_retorno.cont = 0

 #--------------------------------------------------------
 # Recupera os Dados do Segmento                         
 #--------------------------------------------------------
  
 open c_ctc53m04_008 using  m_chave
                           ,mr_ctc53m04.codper 
 whenever error continue  
 fetch c_ctc53m04_008 into  mr_ctc53m04.codper        
                          , mr_ctc53m04.atldat
                          , mr_ctc53m04.funmat              
                         
 whenever error stop
 
 if mr_ctc53m04.codper  is null  then
    error " Codigo Segmento Nao Cadastrado!"
    initialize mr_ctc53m04.*    to null
    return mr_ctc53m04.*
 else
    
    call ctc69m04_recupera_descricao(8,mr_ctc53m04.codper)
    returning mr_ctc53m04.desper                           
         
 end if

 return mr_ctc53m04.*

 end function   


#---------------------------------------------------------                                                                                                                                                                                                                                                                                                                                       
 function ctc53m04_valida_geracao()                                                                                                                                                                                                                                                                                                                                                                     
#---------------------------------------------------------                                                                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                          
                                                                                                                                 
define lr_retorno  record                                                                                                                                                                                                                  
   cont    integer                                                                                                               
end record                                                                                                                       
                                                                                                                                 
initialize lr_retorno.* to null                                                                                                  
                                                                                                                                 
             
        open c_ctc53m04_007 using   m_chave
                                  , mr_ctc53m04.codper       
                                                                                                                                            
        whenever error continue                                                                                                  
        fetch c_ctc53m04_007 into  lr_retorno.cont                                                                               
        whenever error stop                                                                                                      
                                                                                                                                 
        if lr_retorno.cont  >  0   then                                                                                          
           error "Segmento Ja Cadastrado!"    
           return false                                                                                                                                                                   
        end if  
        
        
        return true                                                                                                                                          
                                                                                                                                 
                                                                                                                                                                                                                                                                                                                                                               
end function 

#------------------------------------------------------------
 function ctc53m04_copia()
#------------------------------------------------------------


 define lr_retorno record
     perfil     char(02)                ,
     chave      like datkdominio.cponom	,    
     cpocod     like datkdominio.cpocod ,            
     cpodes     like datkdominio.cpodes ,
     atlult     like datkdominio.atlult  
 end record

 define l_index integer

 initialize lr_retorno.*   to null
                             

  if m_sql <> 'S' then
    call ctc53m04_prepare()
  end if
  
  for l_index = 5 to 9 
  	
  	  case l_index
  	      when 5
  	      	 let lr_retorno.perfil = "05"     
  	      when 6                          	 
  	      	 let lr_retorno.perfil = "06"	 
  	      when 7                         	 
  	      	 let lr_retorno.perfil = "07"	 
  	      when 8                         	 
  	      	 let lr_retorno.perfil = "08"
  	      when 9                         
  	      	 let lr_retorno.perfil = "09" 	  
  	  end case
  	  
  	  call ctc53m04_remove_chave1(lr_retorno.perfil)
  	  call ctc53m04_remove_chave2(lr_retorno.perfil)
  	  call ctc53m04_remove_chave3(lr_retorno.perfil)
  	  call ctc53m04_remove_chave4(lr_retorno.perfil)
  	  call ctc53m04_remove_chave5(lr_retorno.perfil)
  	  call ctc53m04_remove_chave6(lr_retorno.perfil)
  	  call ctc53m04_remove_chave7(lr_retorno.perfil)
  	  call ctc53m04_remove_chave8(lr_retorno.perfil)
  	  call ctc53m04_remove_chave9(lr_retorno.perfil)
  	  call ctc53m04_remove_chave10(lr_retorno.perfil)
  	  call ctc53m04_remove_chave11(lr_retorno.perfil)
  	  call ctc53m04_remove_chave12(lr_retorno.perfil)
  	  call ctc53m04_remove_chave13(lr_retorno.perfil)
  	  call ctc53m04_remove_chave14(lr_retorno.perfil)
  	  
  	  call ctc53m04_monta_chave1(lr_retorno.perfil)
  	  call ctc53m04_monta_chave2(lr_retorno.perfil)
  	  call ctc53m04_monta_chave3(lr_retorno.perfil)
  	  call ctc53m04_monta_chave4(lr_retorno.perfil)
  	  call ctc53m04_monta_chave5(lr_retorno.perfil)
  	  call ctc53m04_monta_chave6(lr_retorno.perfil)
  	  call ctc53m04_monta_chave7(lr_retorno.perfil)
  	  call ctc53m04_monta_chave8(lr_retorno.perfil)
  	  call ctc53m04_monta_chave9(lr_retorno.perfil)
  	  call ctc53m04_monta_chave10(lr_retorno.perfil)
  	  call ctc53m04_monta_chave11(lr_retorno.perfil)
  	  call ctc53m04_monta_chave12(lr_retorno.perfil)
  	  call ctc53m04_monta_chave13(lr_retorno.perfil)
  	  call ctc53m04_monta_chave14(lr_retorno.perfil)
  	
  	  
  	  
  	  
  	
  end for 	
  
  
  
end function 

#---------------------------------------------------------                                                        
 function ctc53m04_inclui_copia(lr_param)                                                                                      
#---------------------------------------------------------                                                       
                                                                                                                 
define lr_param record                                                                                         
  cponom     like datkdominio.cponom , 
  cpocod     like datkdominio.cpocod ,                                                                
  cpodes     like datkdominio.cpodes ,                                                                
  atlult     like datkdominio.atlult                                                                 
end record	                                                                                                     
                                                                                                                                                                                                                                                                                             
                                                                                                                 
    display "lr_param.cponom ", lr_param.cponom  
    display "lr_param.cpocod ", lr_param.cpocod 
    display "lr_param.cpodes ", lr_param.cpodes 
    display "lr_param.atlult ", lr_param.atlult 
    
    whenever error continue                                                                                      
    execute p_ctc53m04_010 using lr_param.cponom                                             
                               , lr_param.cpocod                                              
                               , lr_param.cpodes                                              
                               , lr_param.atlult                                              
                                                                                                                 
    whenever error continue                                                                                      
    display "sqlca.sqlcode ", sqlca.sqlcode                                                                                                                                                            
                                                                                                                 
end function      

#---------------------------------------------------------                                                        
 function ctc53m04_deleta(lr_param)                                                                                      
#---------------------------------------------------------                                                       
                                                                                                                 
define lr_param record                                                                                         
  cponom     like datkdominio.cponom                                                             
end record	                                                                                                     
                                                                                                                                                                                                                                                                                             
                                                                                                                 
    whenever error continue                                                                                      
    execute p_ctc53m04_011 using lr_param.cponom                                                                                                                                                              
    whenever error continue                                                                                      
                                                                                                                                                                
                                                                                                                 
end function

#===============================================================================     
 function ctc53m04_monta_chave1(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_012                                              
  foreach c_ctc53m04_012 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                          
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
       
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function 

#===============================================================================     
 function ctc53m04_monta_chave2(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_013                                              
  foreach c_ctc53m04_013 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                      
       let lr_retorno.chave = lr_retorno.cponom[1,7], lr_param.perfil, lr_retorno.cponom[10,18]
      
       
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function                                           

#===============================================================================     
 function ctc53m04_monta_chave3(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_014                                              
  foreach c_ctc53m04_014 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                       
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
       
      
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function                                           

#===============================================================================     
 function ctc53m04_monta_chave4(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_015                                              
  foreach c_ctc53m04_015 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                           
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
       
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function                                           

#===============================================================================     
 function ctc53m04_monta_chave5(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_016                                              
  foreach c_ctc53m04_016 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                             
       let lr_retorno.chave = lr_retorno.cponom[1,7], lr_param.perfil, lr_retorno.cponom[10,18]
      
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function                                           

#===============================================================================     
 function ctc53m04_monta_chave6(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_017                                              
  foreach c_ctc53m04_017 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                            
       let lr_retorno.chave = lr_retorno.cponom[1,5], lr_param.perfil, lr_retorno.cponom[8,18]
       
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function                                           

#===============================================================================     
 function ctc53m04_monta_chave7(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_018                                              
  foreach c_ctc53m04_018 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                 
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
      
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function

#===============================================================================     
 function ctc53m04_monta_chave8(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_019                                              
  foreach c_ctc53m04_019 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                        
       let lr_retorno.chave = lr_retorno.cponom[1,7], lr_param.perfil, lr_retorno.cponom[10,18]
      
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function 
#===============================================================================     
 function ctc53m04_monta_chave9(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_020                                              
  foreach c_ctc53m04_020 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                             
       let lr_retorno.chave = lr_retorno.cponom[1,6], lr_param.perfil, lr_retorno.cponom[9,18]
        
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function                                       
#===============================================================================     
 function ctc53m04_monta_chave10(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_021                                              
  foreach c_ctc53m04_021 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                       
       let lr_retorno.chave = lr_retorno.cponom[1,4], lr_param.perfil, lr_retorno.cponom[7,18]
    
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function                                      

#===============================================================================     
 function ctc53m04_monta_chave11(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_022                                              
  foreach c_ctc53m04_022 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                            
       let lr_retorno.chave = lr_retorno.cponom[1,6], lr_param.perfil, lr_retorno.cponom[9,18]
  
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function                                      

#===============================================================================     
 function ctc53m04_monta_chave12(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_023                                              
  foreach c_ctc53m04_023 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                      
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
  
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function                                      

#===============================================================================     
 function ctc53m04_monta_chave13(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_024                                              
  foreach c_ctc53m04_024 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                           
       let lr_retorno.chave = lr_retorno.cponom[1,7], lr_param.perfil, lr_retorno.cponom[10,18]
       
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function                                  

#===============================================================================     
 function ctc53m04_monta_chave14(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_025                                              
  foreach c_ctc53m04_025 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                         
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
      
       
       call ctc53m04_inclui_copia(lr_retorno.chave , 
                                  lr_retorno.cpocod, 
                                  lr_retorno.cpodes, 
                                  lr_retorno.atlult) 
       
                                                                                  
  end foreach                                                                     
 
end function  

#===============================================================================     
 function ctc53m04_remove_chave1(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_012                                              
  foreach c_ctc53m04_012 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                     
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
   
       call ctc53m04_deleta(lr_retorno.chave)
       
                                                                                     
  end foreach                                                                     
 
end function 

#===============================================================================     
 function ctc53m04_remove_chave2(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_013                                              
  foreach c_ctc53m04_013 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                            
       let lr_retorno.chave = lr_retorno.cponom[1,7], lr_param.perfil, lr_retorno.cponom[10,18]
      
       call ctc53m04_deleta(lr_retorno.chave)
                                                                                  
  end foreach                                                                     
 
end function                                           

#===============================================================================     
 function ctc53m04_remove_chave3(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_014                                              
  foreach c_ctc53m04_014 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                             
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
       
       call ctc53m04_deleta(lr_retorno.chave)
       
                                                                                  
  end foreach                                                                     
 
end function                                           

#===============================================================================     
 function ctc53m04_remove_chave4(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_015                                              
  foreach c_ctc53m04_015 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                            
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
       
       call ctc53m04_deleta(lr_retorno.chave)
                                                                                  
  end foreach                                                                     
 
end function                                           

#===============================================================================     
 function ctc53m04_remove_chave5(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_016                                              
  foreach c_ctc53m04_016 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                            
       let lr_retorno.chave = lr_retorno.cponom[1,7], lr_param.perfil, lr_retorno.cponom[10,18]
       
       call ctc53m04_deleta(lr_retorno.chave)
                                           
  end foreach                                                                     
 
end function                                           

#===============================================================================     
 function ctc53m04_remove_chave6(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_017                                              
  foreach c_ctc53m04_017 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                         
       let lr_retorno.chave = lr_retorno.cponom[1,5], lr_param.perfil, lr_retorno.cponom[8,18]
       
       call ctc53m04_deleta(lr_retorno.chave)
                               
  end foreach                                                                     
 
end function                                           

#===============================================================================     
 function ctc53m04_remove_chave7(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_018                                              
  foreach c_ctc53m04_018 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                         
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
       
       call ctc53m04_deleta(lr_retorno.chave)
       
                                                    
  end foreach                                                                     
 
end function

#===============================================================================     
 function ctc53m04_remove_chave8(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_019                                              
  foreach c_ctc53m04_019 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                            
       let lr_retorno.chave = lr_retorno.cponom[1,7], lr_param.perfil, lr_retorno.cponom[10,18]
      
       call ctc53m04_deleta(lr_retorno.chave)
       
                                   
  end foreach                                                                     
 
end function 
#===============================================================================     
 function ctc53m04_remove_chave9(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_020                                              
  foreach c_ctc53m04_020 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                        
       let lr_retorno.chave = lr_retorno.cponom[1,6], lr_param.perfil, lr_retorno.cponom[9,18]
       
       call ctc53m04_deleta(lr_retorno.chave)
       
                                  
  end foreach                                                                     
 
end function                                       
#===============================================================================     
 function ctc53m04_remove_chave10(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_021                                              
  foreach c_ctc53m04_021 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                        
       let lr_retorno.chave = lr_retorno.cponom[1,4], lr_param.perfil, lr_retorno.cponom[7,18]
       
       call ctc53m04_deleta(lr_retorno.chave)
                            
  end foreach                                                                     
 
end function                                      

#===============================================================================     
 function ctc53m04_remove_chave11(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_022                                              
  foreach c_ctc53m04_022 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                       
       let lr_retorno.chave = lr_retorno.cponom[1,6], lr_param.perfil, lr_retorno.cponom[9,18]
       
       call ctc53m04_deleta(lr_retorno.chave)
       
                                   
  end foreach                                                                     
 
end function                                      

#===============================================================================     
 function ctc53m04_remove_chave12(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_023                                              
  foreach c_ctc53m04_023 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                         
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
       
       call ctc53m04_deleta(lr_retorno.chave)
                                    
  end foreach                                                                     
 
end function                                      

#===============================================================================     
 function ctc53m04_remove_chave13(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_024                                              
  foreach c_ctc53m04_024 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                          
       let lr_retorno.chave = lr_retorno.cponom[1,7], lr_param.perfil, lr_retorno.cponom[10,18]
       
       call ctc53m04_deleta(lr_retorno.chave)
                                      
  end foreach                                                                     
 
end function                                  

#===============================================================================     
 function ctc53m04_remove_chave14(lr_param)                                                         
#=============================================================================== 

define lr_param record                      
    perfil char(02)                                      
end record

define lr_retorno record
	  chave    like datkdominio.cponom ,	
	  cponom   like datkdominio.cponom ,    
	  cpocod   like datkdominio.cpocod ,    
	  cpodes   like datkdominio.cpodes ,    
	  atlult   like datkdominio.atlult                                     
end record

initialize lr_retorno.* to null
 
  #--------------------------------------------------------
  # Recupera os Dados da Carga          
  #-------------------------------------------------------- 
  
  open c_ctc53m04_025                                              
  foreach c_ctc53m04_025 into lr_retorno.cponom, 
  	                          lr_retorno.cpocod,
  	                          lr_retorno.cpodes,
  	                          lr_retorno.atlult
  	                                             
                                                                         
       let lr_retorno.chave = lr_retorno.cponom[1,3], lr_param.perfil, lr_retorno.cponom[6,18]
      
       call ctc53m04_deleta(lr_retorno.chave)
       
                        
  end foreach                                                                     
 
end function                                        
