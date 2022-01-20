#-----------------------------------------------------------------------------#  
# Porto Seguro Cia Seguros Gerais                                             #  
#.............................................................................#  
# Sistema........: Regras Siebel                                              #  
# Modulo.........: ctc69m22                                                   #  
# Objetivo.......: Cadastro Grupo de Servico                                  #  
# Analista Resp. : Amilton Pinto                                              #  
# PSI            :                                                            #  
#.............................................................................#  
# Desenvolvimento: R.Fornax                                                   #  
# Liberacao      : 12/08/2013                                                 #  
#.............................................................................#  
globals  "/homedsa/projetos/geral/globals/glct.4gl"

database porto

#------------------------------------------------------------------------------
function ctc69m22_prep_temp()
#------------------------------------------------------------------------------

define l_sql char(10000)
    
    let l_sql = 'insert into ctc69m22_temp'
	            , ' values(?,?,?,?)'
    prepare p_ctc69m22_001 from l_sql
    
    let l_sql = ' select paccod ,               '    
             ,  '        pacdes ,               '
             ,  '        paclim ,               '
             ,  '        pacuni                '
             ,  '   from ctc69m22_temp         '    
    prepare p_ctc69m22_002 from l_sql                
    declare c_ctc69m22_002 cursor for p_ctc69m22_002 

end function                                 


#------------------------------------------------------------
 function ctc69m22()
#------------------------------------------------------------
  
define lr_param record 
   xml_request   char(32766) ,
   online        smallint    ,
   fila          char(20)    ,
   xml_response  char(32766) ,
   msg           char(200)   ,                          
   status        integer     ,
   cont1         integer     ,
   cont2         integer     ,  
   cont3         integer     ,  
   cont4         integer     ,  
   descricao     char(1000) 
end record 

define la_retorno array[200] of record
   paccod  integer  ,
   pacdes  char(60) ,
   paclim  dec(13,2),
   pacuni  char(60) ,
   srvcod  integer  ,
   srvdes  char(60) ,
   espcod  integer  ,
   espdes  char(60) ,
   limcod  integer  ,
   limdes  char(60) ,
   limlim  dec(13,2),
   limuni  char(60) 
end record

define lr_retorno record
  paccod  integer  ,
  pacdes  char(60) ,
  paclim  dec(13,2),
  pacuni  char(60) 
end record

define l_doc_handle integer
define l_idx1       integer  
define l_idx2       integer 
define l_idx3       integer 
define l_idx4       integer          

initialize lr_param.*, lr_retorno.* to null

for l_idx1 = 1 to 200 
	 initialize la_retorno[l_idx1].* to null 
end for	

if not ctc69m22_cria_temp() then                                                           
    error  "Erro na Criacao da Tabela Temporaria!"                                        
else
	  call ctc69m22_prep_temp()
end if                                                   
  

let l_doc_handle = null 

let lr_param.fila = "ATDBASERVPCTSOA01R"
                     
let lr_param.online = online() 

let lr_param.xml_request = ctc69m22_monta_xml()

 call figrc006_enviar_pseudo_mq(lr_param.fila               ,       
                                lr_param.xml_request clipped,      
                                lr_param.online)           
      returning lr_param.status,                          
                lr_param.msg   ,                                 
                lr_param.xml_response 
 
 let lr_param.xml_response = figrc100_remove_namespace(lr_param.xml_response) 
                      
call figrc011_inicio_parse()                     

 let l_doc_handle = figrc011_parse(lr_param.xml_response)
 
 let lr_param.cont1 = figrc011_xpath(l_doc_handle,"count(/consultarPacoteResponseMQ/Response/Pacotes/Pacote)")
 
 for l_idx1 = 1 to lr_param.cont1
                                                                                       
     let lr_param.descricao          = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/codigoPacote" 
     let la_retorno[l_idx1].paccod    = figrc011_xpath(l_doc_handle,lr_param.descricao)  
     
     let lr_param.descricao          = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/descricaoPacote" 
     let la_retorno[l_idx1].pacdes    = figrc011_xpath(l_doc_handle,lr_param.descricao) 
     
     let lr_param.descricao          = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/valorLimitePacote" 
     let la_retorno[l_idx1].paclim    = figrc011_xpath(l_doc_handle,lr_param.descricao) 
     
     let lr_param.descricao          = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/descricaoUnidadeLimitePacote" 
     let la_retorno[l_idx1].pacuni    = figrc011_xpath(l_doc_handle,lr_param.descricao) 
     
     let lr_param.descricao          =  "count(/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/Servico)"
     let lr_param.cont2              = figrc011_xpath(l_doc_handle,lr_param.descricao) 
      
     display "la_retorno[l_idx1].paccod " , la_retorno[l_idx1].paccod 
     display "la_retorno[l_idx1].pacdes " , la_retorno[l_idx1].pacdes 
     display "la_retorno[l_idx1].paclim " , la_retorno[l_idx1].paclim 
     display "la_retorno[l_idx1].pacuni " , la_retorno[l_idx1].pacuni 
     
     
     
     
     for l_idx2 = 1 to lr_param.cont2 
     
         let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/Servico[", l_idx2 using "<<<<&", "]/codigoServico"                                                                                                    
         let la_retorno[l_idx2].srvcod    = figrc011_xpath(l_doc_handle,lr_param.descricao)                                                                                                                                                 
                                                                                                                                                                                                                                            
         let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/Servico[", l_idx2 using "<<<<&", "]/descricaoServico"                                                                                                                                                                                
         let la_retorno[l_idx2].srvdes    = figrc011_xpath(l_doc_handle,lr_param.descricao)                                                                                                                                                 
     
         display "la_retorno[l_idx2].srvcod " , la_retorno[l_idx2].srvcod  
         display "la_retorno[l_idx2].srvdes " , la_retorno[l_idx2].srvdes 
         
         let lr_param.descricao          =  "count(/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/Servico[", l_idx2 using "<<<<&", "]/Especialidades/Especialidade)"
         let lr_param.cont3              =  figrc011_xpath(l_doc_handle,lr_param.descricao) 
         
         for l_idx3 = 1 to lr_param.cont3 
         
             let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"
                                              , "]/Servico[", l_idx2 using "<<<<&"
                                              , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&" 
                                              , "]/codigoEspecialidade"                                                                                                    
             let la_retorno[l_idx3].espcod    = figrc011_xpath(l_doc_handle,lr_param.descricao)                                                                                                                                                 
                                                                                                                                                                                                                                                
             let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"
                                              , "]/Servico[", l_idx2 using "<<<<&"
                                              , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&" 
                                              , "]/descricaoEspecialidade" 
                                                                                                                                                                     
             let la_retorno[l_idx3].espdes    = figrc011_xpath(l_doc_handle,lr_param.descricao)    
         
             display "la_retorno[l_idx3].espcod " , la_retorno[l_idx3].espcod   
             display "la_retorno[l_idx3].espdes " , la_retorno[l_idx3].espdes
             
             let lr_param.descricao          =  "count(/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"
                                              , "]/Servico[", l_idx2 using "<<<<&"
                                              , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"
                                              , "]/Limites/Limite)"
             let lr_param.cont4              =  figrc011_xpath(l_doc_handle,lr_param.descricao)                                                                                                         
             
             for l_idx4 = 1 to lr_param.cont4
             	
                 let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"   
                                                  , "]/Servico[", l_idx2 using "<<<<&"                                            
                                                  , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"                       
                                                  , "]/Limites/Limite[", l_idx4 using "<<<<&"  
                                                  , "]/codigoTipoLimiteEspecialidade"                                                       
                 let la_retorno[l_idx4].limcod    = figrc011_xpath(l_doc_handle,lr_param.descricao)                               
                 
                 
                 let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"   
                                                  , "]/Servico[", l_idx2 using "<<<<&"                                            
                                                  , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"                       
                                                  , "]/Limites/Limite[", l_idx4 using "<<<<&"  
                                                  , "]/descricaoTipoLimiteEspecialidade"                                                       
                 let la_retorno[l_idx4].limdes    = figrc011_xpath(l_doc_handle,lr_param.descricao) 
            
                 
                 let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"   
                                                  , "]/Servico[", l_idx2 using "<<<<&"                                            
                                                  , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"                       
                                                  , "]/Limites/Limite[", l_idx4 using "<<<<&"  
                                                  , "]/valorLimiteEspecialidade"                                                       
                 let la_retorno[l_idx4].limlim    = figrc011_xpath(l_doc_handle,lr_param.descricao) 
                 
                
                 let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"   
                                                  , "]/Servico[", l_idx2 using "<<<<&"                                            
                                                  , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"                       
                                                  , "]/Limites/Limite[", l_idx4 using "<<<<&"  
                                                  , "]/descricaoUnidadeLimiteEspecialidade"                                                       
                 let la_retorno[l_idx4].limuni    = figrc011_xpath(l_doc_handle,lr_param.descricao)
                 
                 display "la_retorno[l_idx4].limcod " , la_retorno[l_idx4].limcod  
                 display "la_retorno[l_idx4].limdes " , la_retorno[l_idx4].limdes
                 display "la_retorno[l_idx4].limlim " , la_retorno[l_idx4].limlim  
                 display "la_retorno[l_idx4].limuni " , la_retorno[l_idx4].limuni
                  
      
             end for	           
         end for 
     end for
     
  
     whenever error continue                        
     execute  p_ctc69m22_001 using  la_retorno[l_idx1].paccod 
                                   ,la_retorno[l_idx1].pacdes 
                                   ,la_retorno[l_idx1].paclim    
                                   ,la_retorno[l_idx1].pacuni   
     whenever error stop  
     
     
     open c_ctc69m22_002  
     foreach c_ctc69m22_002 into lr_retorno.paccod
  	                           , lr_retorno.pacdes
  	                           , lr_retorno.paclim
                               , lr_retorno.pacuni
        
        display "lr_retorno.paccod ", lr_retorno.paccod
        display "lr_retorno.pacdes ", lr_retorno.pacdes
        display "lr_retorno.paclim ", lr_retorno.paclim                        
        display "lr_retorno.pacuni ", lr_retorno.pacuni
     
     end foreach 
     
     
                                                                     
 end for 

 
 call figrc011_fim_parse()   
 end function  
 
#------------------------------------------------------------
 function ctc69m22_monta_xml()
#------------------------------------------------------------

define l_xml_request char(3000)


  let l_xml_request = '<ns0:consultarPacoteRequestMQ xmlns:ns0="http://www.portoseguro.com.br/corporativo/business/BeneficioServicoEBS/V1_0/" xmlns:ns1="http://www.portoseguro.com.br/ebo/BeneficioServico/V1_0">',
                       '<ns0:Request>',
                         '<ns1:codigoEmpresa>1</ns1:codigoEmpresa>',                     
                         '<ns1:codigoProduto>1</ns1:codigoProduto>',
                         '<ns1:codigoRamo>531</ns1:codigoRamo>',
                         '</ns0:Request>',
                      '</ns0:consultarPacoteRequestMQ>'                                                                                                                                                 
                      
                      
 
  return l_xml_request 



end function

#------------------------------------------------------------------------------         
function ctc69m22_cria_temp()                                                           
#------------------------------------------------------------------------------         
 call ctc69m22_drop_temp()                                                              
                                                                                        
 whenever error continue                                                                
      create temp table ctc69m22_temp (paccod  integer                            
                                      ,pacdes  char(60)                           
                                      ,paclim  dec(13,2)                          
                                      ,pacuni  char(60) ) with no log                  
      create index idx_tmpctc69m22 on ctc69m22_temp (paccod)                       
                                                                                        
  whenever error stop                                                                  
    if sqlca.sqlcode <> 0  then                                                        
	    if sqlca.sqlcode = -310 or                                                       
	       sqlca.sqlcode = -958 then                                                     
	           call ctc69m22_drop_temp()                                                 
	    end if                                                                           
	    return false                                                                     
    end if                                                                             
                                                                                       
    return true                                                                        
end function

#------------------------------------------------------------------------------                                                                                   
function ctc69m22_drop_temp()                                                           
#------------------------------------------------------------------------------        
    whenever error continue                                                            
        drop table ctc69m22_temp                                                       
    whenever error stop                                                                
                                                                                       
    return                                                                             
end function  

                                        