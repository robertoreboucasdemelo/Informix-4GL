#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Cadastro Central                                           #
# Modulo.........: ctc53m02                                                   #
# Objetivo.......: Cadastro de Parametros                                     #
# Analista Resp. : Humberto Benedito                                          #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 07/04/2014                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define  m_sql       char(1)
define  arr_aux     integer

define m_chave      like datkdominio.cponom
define m_operacao   char(01)

define mr_ctc53m02 record
      data_corte     date 
     ,liberado       char(01)
     ,atldat         date    
     ,funmat         char(20)
end record

#------------------------------------------------------------
 function ctc53m02_prepare()
#------------------------------------------------------------

define l_sql char(10000)


 let l_sql = ' select cpodes[01,10],       '
          ,  '        cpodes[12,12],       '
          ,  '        atlult[01,10],       '
          ,  '        atlult[12,18]        '      
          ,  '   from datkdominio '
          ,  '  where cponom = ?  '        
 prepare p_ctc53m02_001 from l_sql
 declare c_ctc53m02_001 cursor for p_ctc53m02_001


 let l_sql =  ' update datkdominio             '
           ,  '     set cpodes[01,10]    = ? , '  
           ,  '         cpodes[12,12]    = ? , ' 
           ,  '         atlult[01,10]    = ? , '
           ,  '         atlult[12,18]    = ?   '
           ,  ' where cponom = ?               '             
 prepare p_ctc53m02_002 from l_sql

 

 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
 prepare p_ctc53m02_005 from l_sql


 let l_sql = ' select count(*)    '
          ,  '   from datkdominio '
          ,  '  where cponom = ?  '        
 prepare p_ctc53m02_007 from l_sql
 declare c_ctc53m02_007 cursor for p_ctc53m02_007
 	
 let l_sql = ' select cpodes[01,10]       '     	
          ,  '   from datkdominio '              	
          ,  '  where cponom = ?  '              	
 prepare p_ctc53m02_008 from l_sql               	
 declare c_ctc53m02_008 cursor for p_ctc53m02_008	
 	
 let l_sql = ' select cpodes[12,12]       '     	
          ,  '   from datkdominio '              	
          ,  '  where cponom = ?  '              	
 prepare p_ctc53m02_009 from l_sql               	
 declare c_ctc53m02_009 cursor for p_ctc53m02_009		
 	
 	
let m_sql = 'S'

end function

#------------------------------------------------------------
 function ctc53m02()
#------------------------------------------------------------

 let int_flag = false
 initialize mr_ctc53m02.* to null

 
 let m_chave = ctc53m02_monta_chave() 

 open window ctc53m02 at 4,2 with form "ctc53m02"
 
 call ctc53m02_prepare()   

 call ctc53m02_consulta()
 
 call ctc53m02_input()
 

 close window ctc53m02

 end function


#------------------------------------------------------------
 function ctc53m02_consulta()
#------------------------------------------------------------

 
 let int_flag = false

 initialize mr_ctc53m02.*  to null
 
 
 open c_ctc53m02_001 using m_chave
 whenever error continue
 fetch c_ctc53m02_001 into mr_ctc53m02.data_corte,
                           mr_ctc53m02.liberado  ,
                           mr_ctc53m02.atldat    ,
                           mr_ctc53m02.funmat
 whenever error stop

 display by name mr_ctc53m02.*


 end function





#------------------------------------------------------------
 function ctc53m02_inclui()
#------------------------------------------------------------


 define lr_retorno record
     resp       char(01),
     ret        smallint,
     mensagem   char(60),
     data_atual date    ,
     cpodes     like datkdominio.cpodes ,
     cpocod     like datkdominio.cpocod ,
     atlult     like datkdominio.atlult   
 end record

 initialize lr_retorno.* to null

 let lr_retorno.ret   = 0


  begin work
  
  let lr_retorno.data_atual = today 
  let lr_retorno.cpocod     = 1                                                
  let lr_retorno.atlult     = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"   
  let lr_retorno.cpodes     = mr_ctc53m02.data_corte , "|", mr_ctc53m02.liberado clipped   
  
  #--------------------------------------------------------
  # Inclui o Perfil
  #--------------------------------------------------------

  whenever error continue
  execute p_ctc53m02_005 using lr_retorno.cpocod
                             , lr_retorno.cpodes 
                             , m_chave                                    
                             , lr_retorno.atlult
                                      
  whenever error stop
  if sqlca.sqlcode <>  0   then
     error " Erro (",sqlca.sqlcode,") na Inclusao do Parametro!"
     rollback work
     return
  end if

 commit work

 end function


#--------------------------------------------------------------------
 function ctc53m02_input()
#--------------------------------------------------------------------

 define lr_retorno record
     erro        smallint,
     mensagem    char(60),
     count       smallint,
     confirma    char(01)
 end record


 let lr_retorno.count    = 0
 let lr_retorno.erro     = 0
 let lr_retorno.mensagem = null

 let int_flag = false

 input by name   mr_ctc53m02.data_corte,
 	               mr_ctc53m02.liberado without defaults


    before field data_corte
           display by name mr_ctc53m02.data_corte attribute (reverse)

    after  field data_corte
           display by name mr_ctc53m02.data_corte


           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
                 next field data_corte
           end if

           if mr_ctc53m02.data_corte   is null   then
                 error "Data de Corte deve Ser Informada!"            
                 next field data_corte         
           end if
    
    before field liberado
           display by name mr_ctc53m02.liberado attribute (reverse)

    after  field liberado
           display by name mr_ctc53m02.liberado


           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
                 next field liberado
           end if

           if mr_ctc53m02.liberado   is null or
           	  (mr_ctc53m02.liberado  <> "S"   and
           	   mr_ctc53m02.liberado  <> "N")  then
                 error "Por Favor Informe <S> ou <N>!!"            
                 next field liberado         
           end if       
           
           call ctc53m02_valida_geracao()
           
           if m_operacao = 'i' then
              call ctc53m02_inclui()
           else
              call ctc53m02_altera()
           end if  
                     
           display by name mr_ctc53m02.*
           
            
       
    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize mr_ctc53m02.*  to null
 end if
 
 prompt "" for char lr_retorno.confirma


 end function




#---------------------------------------------------------
 function ctc53m02_valida_geracao()
#---------------------------------------------------------

define lr_retorno  record
   cont    integer
end record

initialize lr_retorno.* to null

let m_operacao = null

        open c_ctc53m02_007 using m_chave
                                
        whenever error continue
        fetch c_ctc53m02_007 into  lr_retorno.cont
        whenever error stop

        if lr_retorno.cont  >  0   then
           let m_operacao = 'a'
        else
        	 let m_operacao = 'i'
        end if

end function

#---------------------------------------------------------                                                                                            
 function ctc53m02_altera()                                             
#---------------------------------------------------------

define lr_retorno record                  
   data_atual date,
   funmat     like isskfunc.funmat
end record	                              
                                          
initialize lr_retorno.* to null           
                                                                                 
    let lr_retorno.data_atual = today
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"      
    
    whenever error continue 
    execute p_ctc53m02_002 using mr_ctc53m02.data_corte
                               , mr_ctc53m02.liberado
                               , lr_retorno.data_atual          
                               , lr_retorno.funmat         
                               , m_chave                                                
    whenever error continue 
    
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao do Parametro!'       
    else
    	  error 'Dados Alterados com Sucesso!' 
    end if             
                                                                                      
end function 

#===============================================================================     
 function ctc53m02_monta_chave()                                                         
#=============================================================================== 


define lr_retorno record
	  chave like datkdominio.cponom	                                  
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "PF_PARAM"

 return lr_retorno.chave 
 
end function  

#---------------------------------------------------------
 function ctc53m02_recupera_data()
#---------------------------------------------------------

define lr_retorno  record
   data_corte date     ,
   chave      char(20)
end record

initialize lr_retorno.* to null


        if m_sql is null or
           m_sql <> true then
           call ctc53m02_prepare()
        end if
              
        let lr_retorno.chave = ctc53m02_monta_chave() 
         
        open c_ctc53m02_008 using lr_retorno.chave
                                
        whenever error continue
        fetch c_ctc53m02_008 into  lr_retorno.data_corte
        whenever error stop

        return lr_retorno.data_corte  

end function

#---------------------------------------------------------
 function ctc53m02_recupera_liberacao()
#---------------------------------------------------------

define lr_retorno  record
   liberado      char(01),
   chave         char(20)   
end record

if m_sql is null or
   m_sql <> true then
   call ctc53m02_prepare()
end if

initialize lr_retorno.* to null
         
        let lr_retorno.chave = ctc53m02_monta_chave() 
         
        open c_ctc53m02_009 using lr_retorno.chave
                                
        whenever error continue
        fetch c_ctc53m02_009 into  lr_retorno.liberado
        whenever error stop

        return lr_retorno.liberado 

end function

                                       
















































