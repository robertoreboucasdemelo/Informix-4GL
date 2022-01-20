#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Teleatendimento                                            #
# MODULO.........: ctx35g01                                                   #
# ANALISTA RESP..: Humberto Benedito                                          #
# DESENVOLVEDOR..: R.Fornax                                                   #
# PSI/OSF........:                                                            #
# DATA...........: 15/09/2014                                                 #
# OBJETIVO.......: Criar uma inferface unica de atualizacao dos serviços na   #
#                  base do Oracle da base de serviço                          #
#-----------------------------------------------------------------------------#
globals  "/homedsa/projetos/geral/globals/glct.4gl"
 
database porto

define  m_ctx35g01_prep  smallint
define  m_multiplo       char(01)                    

#------------------------------------------#
function ctx35g01_prepare()
#------------------------------------------#

define l_sql char(6000)

 
   let l_sql = " select atdsrvorg,   ",
               "        atdlibflg    ",
               " from datmservico    ",
               " where atdsrvnum = ? ",
               " and   atdsrvano = ? "  
   prepare p_ctx35g01_001 from l_sql
   declare c_ctx35g01_001 cursor for p_ctx35g01_001
 
   let l_sql = " select socntzcod,   ",
               "        espcod       ",              	
               " from datmsrvre      ",              	
               " where atdsrvnum = ? ",              	
               " and   atdsrvano = ? "      
   prepare p_ctx35g01_002 from l_sql
   declare c_ctx35g01_002 cursor for p_ctx35g01_002
 
   let l_sql = "select c24astcod,",
                     " lignum    ",
                " from datmligacao                     ",
                " where lignum = (select min(lignum)   ",
                                  " from datmligacao   ",
                                  "where atdsrvnum = ? ",
                                  "  and atdsrvano = ?)"
   prepare p_ctx35g01_003 from l_sql
   declare c_ctx35g01_003 cursor for p_ctx35g01_003

   let l_sql = "select prporg,   ",
               "       prpnumdig ",
               "  from datrligprp",
               " where lignum = ?"
   prepare p_ctx35g01_004 from l_sql
   declare c_ctx35g01_004 cursor for p_ctx35g01_004
   	  
   let l_sql = " select asitipcod    ",
               " from datmservico    ",
               " where atdsrvnum = ? ",
               " and   atdsrvano = ? "  
   prepare p_ctx35g01_005 from l_sql
   declare c_ctx35g01_005 cursor for p_ctx35g01_005  
   	   	
   let l_sql = " select avialgmtv    ",              	
               " from datmavisrent   ",              	
               " where atdsrvnum = ? ",              	
               " and   atdsrvano = ? "               	
   prepare p_ctx35g01_006 from l_sql                 	
   declare c_ctx35g01_006 cursor for p_ctx35g01_006 
   	
   let l_sql = " select count(*)      ",              	
               " from datratdmltsrv   ",              	
               " where atdsrvnum = ?  ",              	
               " and   atdsrvano = ?  "               	
   prepare p_ctx35g01_007 from l_sql                 	
   declare c_ctx35g01_007 cursor for p_ctx35g01_007 
   
   let l_sql = " select count(*)  ,      ",   
               "        atdsrvnum ,      ",
               "        atdsrvano        ",  
               " from datratdmltsrv      ",           	
               " where atdmltsrvnum = ?  ",           	
               " and   atdmltsrvano = ?  ",
               " group by 2,3            "      
   prepare p_ctx35g01_008 from l_sql                	
   declare c_ctx35g01_008 cursor for p_ctx35g01_008    
   	
   
   let l_sql = " select atdmltsrvnum, ",             	
               "        atdmltsrvano  ",            
               " from datratdmltsrv   ",             	
               " where atdsrvnum = ?  ",            	
               " and   atdsrvano = ?  "             	
   prepare p_ctx35g01_009 from l_sql                 	
   declare c_ctx35g01_009 cursor for p_ctx35g01_009
   	
   	
   let l_sql = " select cpodes[11,13]           "  	         
            ,  " from datkdominio               "  	         
            ,  " where cponom = ?               "  	         
            ,  " and   cpodes[01,02] = ?        "  	         
            ,  " and   cpodes[04,05] = ?        "  	         
            ,  " and   cpodes[07,09] = ?        "  	 	       
   prepare p_ctx35g01_010 from l_sql                          
   declare c_ctx35g01_010 cursor for p_ctx35g01_010  	
   

   let l_sql = "select succod,       ",
               "       ramcod,       ",
               "       aplnumdig,    ",
               "       itmnumdig     ",
               "  from datrservapol  ",
               " where atdsrvnum = ? ",
               "   and atdsrvano= ?  "
   prepare p_ctx35g01_012 from l_sql
   declare c_ctx35g01_012 cursor for p_ctx35g01_012


   let l_sql = " select relpamtxt ",
                 " from igbmparam ",
                " where relsgl    = ? ",
                  " and relpamtip = ? "
   prepare p_ctx35g01_026 from l_sql
   declare c_ctx35g01_026 cursor for p_ctx35g01_026

   let l_sql = " select cpodes ",
         		" from iddkdominio ",
                 " where cponom = ? ",
                 " and cpocod = ?"
   prepare p_ctx35g01_027 from l_sql
   declare c_ctx35g01_027 cursor for p_ctx35g01_027

   let l_sql = "select seqregcnt, ",
                     " c24astcod ",
                " from datmcntsrv ",
               " where dstsrvnum = ? ",
                 " and dstsrvano = ?"
   prepare p_ctx35g01_028 from l_sql
   declare c_ctx35g01_028 cursor for p_ctx35g01_028

   let l_sql = "select srv.atdsrvorg, ",
                     " lig.c24astcod ",
                " from datmservico srv,",
                    "  datmligacao lig ",
               " where lig.lignum = (select min(ligmin.lignum) ",
                                     " from datmligacao ligmin ",
                                    " where ligmin.atdsrvnum = srv.atdsrvnum ",
                                      " and ligmin.atdsrvano = srv.atdsrvano) ",
                 " and srv.atdsrvnum = ? ",
                 " and srv.atdsrvano = ? "
   prepare p_ctx35g01_029 from l_sql
   declare c_ctx35g01_029 cursor for p_ctx35g01_029

     

let m_ctx35g01_prep = true

end function 

#------------------------------------------#   
function ctx35g01_carrega_dados(lr_param)                    
#------------------------------------------#

define lr_param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
end record 

define lr_retorno record                                   
	 atdsrvnum       like datmservico.atdsrvnum  ,         
	 atdsrvano       like datmservico.atdsrvano  ,         
	 atdsrvorg       like datmservico.atdsrvorg  ,         
   atdlibflg       like datmservico.atdlibflg  ,         
   c24astcod       like datmligacao.c24astcod  ,         
   lignum          like datmligacao.lignum     ,         
   succod          like datrservapol.succod    ,         
   ramcod          like datrservapol.ramcod    ,         
   aplnumdig       like datrservapol.aplnumdig ,         
   itmnumdig       like datrservapol.itmnumdig ,         
   prporg          like datrligprp.prporg      ,         
   prpnumdig       like datrligprp.prpnumdig   ,                   
   numsolic        char(20)                    ,         
   doctip          integer                     ,         
   documento       char(80)                    ,         
   datahora        char(30)                    ,
   data            datetime  year to day       ,  
   hora            datetime hour to second     ,           
   valuti          integer                          
end record	                                              

    initialize lr_retorno.* to null

    let lr_retorno.valuti = 1
    
    #-----------------------------------------------------#
    # CURSOR PARA TRAZER OS DADOS DO SERVICO              #
    #-----------------------------------------------------#
		whenever error continue                                         
     open c_ctx35g01_001 using lr_param.atdsrvnum,
                               lr_param.atdsrvano       
     fetch c_ctx35g01_001 into lr_retorno.atdsrvorg,
                               lr_retorno.atdlibflg                           
                                                                                    
    whenever error stop 
    
    
    #-----------------------------------------------------#       
    # CURSOR PARA TRAZER O CODIGO DO ASSUNTO E LIGACAO    #       
    #-----------------------------------------------------#       
    whenever error continue                                       
      open c_ctx35g01_003 using lr_param.atdsrvnum  ,                  
                                lr_param.atdsrvano                   
      fetch c_ctx35g01_003 into lr_retorno.c24astcod,           
                                lr_retorno.lignum         
    whenever error stop 
    
    
    #-----------------------------------------------------#                                  
    # CURSOR PARA TRAZER OS DADOS DA APOLICE              #                                  
    #-----------------------------------------------------#                                  
    whenever error continue                                                                  
      open c_ctx35g01_012 using lr_param.atdsrvnum ,                                             
                                lr_param.atdsrvano                                              
      fetch c_ctx35g01_012 into lr_retorno.succod    ,                                   
                                lr_retorno.ramcod    ,                                   
                                lr_retorno.aplnumdig ,                                
                                lr_retorno.itmnumdig                                 
            
    whenever error stop 
    
    
    #----------------------------------------------#                                                                          
    # CURSOR PARA TRAZER A PROPOSTA DO SERVICO     #                                                                          
    #----------------------------------------------#                                                                          
    whenever error continue                                                                                                   
      open c_ctx35g01_004 using lr_retorno.lignum                                                                      
      fetch c_ctx35g01_004 into lr_retorno.prporg   ,                                                                    
                                lr_retorno.prpnumdig                                                                  
                                                                                                                               
    whenever error stop 
    
    
    let lr_retorno.numsolic = lr_param.atdsrvano using "&&", lr_param.atdsrvnum using "<<<<<<<<<&" 
    
    let lr_retorno.hora = current                   
    let lr_retorno.data = current                   
    let lr_retorno.datahora = lr_retorno.data, "T", lr_retorno.hora   
  
    
    if lr_retorno.prporg     is not null and                                                                                                         
       lr_retorno.prpnumdig  is not null then
        
       #----------------------------------------------# 
       # MONTA DOCUMENTO PROPOSTA                     # 
       #----------------------------------------------# 
       
       let lr_retorno.doctip    = 2                                                                                       
       let lr_retorno.documento = lr_retorno.prporg using "<<<&",'-',
                                  lr_retorno.prpnumdig using "<<<<<<<<<&"  
        
    
    else  
    	
    	 #----------------------------------------------#
    	 # MONTA DOCUMENTO APOLICE                      #
    	 #----------------------------------------------#
    	
    	 let lr_retorno.doctip    = 1
    	 let lr_retorno.documento = lr_retorno.succod    using "<<<&",'-',             
    	                            lr_retorno.ramcod    using "<<<<&",'-',          
                                  lr_retorno.aplnumdig using "<<<<<<<<<<&"       
    end if	   	
    
     
    return lr_retorno.doctip    ,    
           lr_retorno.documento ,
           lr_retorno.numsolic  ,   
           lr_retorno.itmnumdig ,
           lr_retorno.atdsrvorg ,
           lr_retorno.atdlibflg ,
           lr_retorno.c24astcod ,
           lr_retorno.datahora  ,
           lr_retorno.valuti
     
                                                                        
end function






#------------------------------------------------------------                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
 function ctx35g01_monta_xml_inclusao(lr_param)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#------------------------------------------------------------

define lr_param record
	numsolic   char(30),   
  doctip     char(30),
  documento  char(30),
  itmnumdig  char(30),
  datahora   char(30),
  srvespnum  char(30),    
  c24astcod  char(30),
  atdsrvorg  char(30),
  valuti     char(30),
  usrtip     char(30),
  funmat     char(30),
  empcod     char(30)
end record	
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
define l_xml_request char(3000)  

  let l_xml_request = null
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
  let l_xml_request = '<v1:incluirBeneficioRequestMQ xmlns:v1="http://www.portoseguro.com.br/corporativo/business/BeneficioServicoEBS/V1_0/">',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
                       '<v1:Request xmlns:v11="http://www.portoseguro.com.br/ebo/BeneficioServico/V1_0">',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                         '<v11:codigoSistemaOrigem>2</v11:codigoSistemaOrigem>',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
                         '<v11:numeroSolicitacao>',lr_param.numsolic clipped,'</v11:numeroSolicitacao>',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
                         '<v11:codigoTipoDocumento>',lr_param.doctip clipped,'</v11:codigoTipoDocumento>',             
                         '<v11:documento>',lr_param.documento clipped,'</v11:documento>',                              
                         '<v11:numeroItemDocumento>',lr_param.itmnumdig clipped,'</v11:numeroItemDocumento>',         
                         '<v11:codigoPacote></v11:codigoPacote>',                                          
                         '<v11:dataHoraInclusao>',lr_param.datahora clipped,'</v11:dataHoraInclusao>',              
                         '<v11:codigoEspecialidade>',lr_param.srvespnum clipped,'</v11:codigoEspecialidade>',            
                         '<v11:valorUtilizado>',lr_param.valuti clipped,'</v11:valorUtilizado>',    
                         '<v11:tipoUsuario>',lr_param.usrtip clipped,'</v11:tipoUsuario>',                                                                
                         '<v11:matriculaUsuario>',lr_param.funmat clipped,'</v11:matriculaUsuario>', 
                         '<v11:empresaUsuario>',lr_param.empcod clipped,'</v11:empresaUsuario>',                         
                         '<v11:origemServico>',lr_param.atdsrvorg clipped,'</v11:origemServico>',                                                              
                         '<v11:codigoAssunto>',lr_param.c24astcod clipped,'</v11:codigoAssunto>',                                      
                       '</v1:Request>',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                      '</v1:incluirBeneficioRequestMQ>'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
  return l_xml_request                                                                                         
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
end function

#------------------------------------------------------------                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
 function ctx35g01_monta_xml_cancelamento(lr_param)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
#------------------------------------------------------------

define lr_param record                      
	numsolic   char(30),                                           
  datahora   char(30),                                           
  usrtip     char(30),                      
  funmat     char(30),                      
  empcod     char(30)                       
end record	                                
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
define l_xml_request char(3000)

  let l_xml_request = null  
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
  let l_xml_request = '<ns0:cancelamentoBeneficioRequestMQ xmlns:ns0="http://www.portoseguro.com.br/corporativo/business/BeneficioServicoEBS/V1_0/" xmlns:ns1="http://www.portoseguro.com.br/ebo/BeneficioServico/V1_0">',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
                       '<ns0:Request>',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                         '<ns1:codigoSistemaOrigem>2</ns1:codigoSistemaOrigem>',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
                         '<ns1:numeroSolicitacao>',lr_param.numsolic clipped,'</ns1:numeroSolicitacao>',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
                         '<ns1:dataHoraCancelamento>',lr_param.datahora clipped,'</ns1:dataHoraCancelamento>', 
                         '<ns1:tipoUsuario>',lr_param.usrtip clipped,'</ns1:tipoUsuario>',
                         '<ns1:matriculaUsuario>',lr_param.funmat clipped,'</ns1:matriculaUsuario>',
                         '<ns1:empresaUsuario>',lr_param.empcod clipped,'</ns1:empresaUsuario>',
                       '</ns0:Request>',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                      '</ns0:cancelamentoBeneficioRequestMQ>'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
  return l_xml_request   
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
end function   

#------------------------------------------------------------                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
 function ctx35g01_inclui_xml(lr_param)                    
#------------------------------------------------------------

define lr_param record                                           
	 atdsrvorg       like datmservico.atdsrvorg  ,         
   c24astcod       like datmligacao.c24astcod  ,                      
   itmnumdig       like datrservapol.itmnumdig ,                         
   srvespnum       like datksrvesp.srvespnum   ,             
   numsolic        char(20)                    ,         
   doctip          integer                     ,         
   documento       char(80)                    ,         
   datahora        char(30)                    ,         
   valuti          integer                          
end record	                                             

define lr_retorno record             
   xml_request    char(32766) ,     
   online         smallint    ,     
   fila           char(20)    ,     
   xml_response   char(32766) ,     
   msg            char(200)   ,       
   status         integer     ,                                                                                                                                                                                                                                                                                                                                                        
   descricao      char(1000)  ,     
   erro           integer     ,     
   msg_erro       char(100)                                         
end record 
                        
define l_doc_handle integer 

initialize lr_retorno.* to null

let l_doc_handle = null
let lr_retorno.fila = "ATDBASERVINCSOA01R"
let lr_retorno.online = online()

    # ATIVA BIGCHAR 
   call setBigChar()  
   display "inclui " , lr_param.numsolic   
   
   call ctx35g01_monta_xml_inclusao(lr_param.numsolic , 
                                    lr_param.doctip   ,
                                    lr_param.documento,
                                    lr_param.itmnumdig,
                                    lr_param.datahora ,
                                    lr_param.srvespnum,
                                    lr_param.c24astcod,
                                    lr_param.atdsrvorg,
                                    lr_param.valuti   ,
                                    g_issk.usrtip     ,
                                    g_issk.funmat     ,
                                    g_issk.empcod     )
   
   returning lr_retorno.xml_request
   display "lr_retorno.xml_request ", lr_retorno.xml_request clipped
   call figrc006_enviar_pseudo_mq(lr_retorno.fila               ,
                                  lr_retorno.xml_request clipped,
                                  lr_retorno.online)
   returning lr_retorno.status,
             lr_retorno.msg   ,
             lr_retorno.xml_response
    
   display "sai" 
   
   
    # Desativa o Bigchar        
    call unSetBigChar()         
                                               
end function 

#------------------------------------------------------------                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
 function ctx35g01_cancela_xml(lr_param)                    
#------------------------------------------------------------

define lr_param record                                  
   numsolic  char(20) ,            
   datahora  char(30)                                         
end record	                                            

define lr_retorno record             
   xml_request   char(32766) ,     
   online        smallint    ,     
   fila          char(20)    ,     
   xml_response  char(32766) ,     
   msg           char(200)   ,       
   status        integer     ,                                                                                                                                                                                                                                                                                                                                                        
   descricao     char(1000)  ,     
   erro          integer     ,     
   msg_erro      char(100)                                         
end record 
                        
define l_doc_handle integer 

initialize lr_retorno.* to null

let l_doc_handle      = null              
let lr_retorno.fila   = "ATDBASERVCANSOA01R "
let lr_retorno.online = online()

    # ATIVA BIGCHAR 
    #call setBigChar()  
    display "cancela " , lr_param.numsolic     
    call ctx35g01_monta_xml_cancelamento(lr_param.numsolic ,               
                                         lr_param.datahora ,             
                                         g_issk.usrtip     ,        
                                         g_issk.funmat     ,        
                                         g_issk.empcod     )                                                                     
    returning lr_retorno.xml_request                    
    display "lr_retorno.xml_request ", lr_retorno.xml_request clipped
    call figrc006_enviar_pseudo_mq(lr_retorno.fila               ,
                                   lr_retorno.xml_request clipped,
                                   lr_retorno.online)
    returning lr_retorno.status,
              lr_retorno.msg   ,
              lr_retorno.xml_response
    display "Sai"
    
    
     # Desativa o Bigchar        
     call unSetBigChar()                      

end function 

#------------------------------------------#                                                                  
function ctx35g01_recupera_codigo(lr_param)                                                                     
#------------------------------------------#

define lr_param record                              
	 atdsrvnum  like datmservico.atdsrvnum  ,      
	 atdsrvano  like datmservico.atdsrvano  ,      
	 atdsrvorg  like datmservico.atdsrvorg  
end record

define lr_retorno record               
   espcod     like datmsrvre.espcod       ,   
   srvespnum  like datksrvesp.srvespnum   ,      
   codigo     integer                                              
end record	                                          

    
    initialize lr_retorno.* to null
    
    let lr_retorno.espcod    = 0        
      
    if lr_param.atdsrvorg = 9 then
       
          call ctx35g01_recupera_natureza(lr_param.atdsrvnum,
                                          lr_param.atdsrvano) 
          returning lr_retorno.codigo,
                    lr_retorno.espcod                                                                                                                                                                       
    
    end if                   
    
    if lr_param.atdsrvorg = 1  or
    	 lr_param.atdsrvorg = 4  or 
    	 lr_param.atdsrvorg = 5  or 
    	 lr_param.atdsrvorg = 6  or 
    	 lr_param.atdsrvorg = 7  or 
    	 lr_param.atdsrvorg = 15 or 
    	 lr_param.atdsrvorg = 18 then 
       
          call ctx35g01_recupera_tipo_assistencia(lr_param.atdsrvnum,
                                                  lr_param.atdsrvano)
          returning lr_retorno.codigo  
       
                                                                                                                                                                              
    end if                        
    
    if lr_param.atdsrvorg = 2 or
    	 lr_param.atdsrvorg = 3 or 
    	 lr_param.atdsrvorg = 8 then  
       
          call ctx35g01_recupera_motivo(lr_param.atdsrvnum,
                                        lr_param.atdsrvano)
          returning lr_retorno.codigo
                                                                                                                                                                              
    end if 
    
    
    #-----------------------------------------------------#  
    # RECUPERA A ESPECIALIDADE DO DE-PARA                 #  
    #-----------------------------------------------------#  
    
    call ctx35g01_recupera_especialidade(lr_param.atdsrvorg,
                                         lr_retorno.codigo ,
                                         lr_retorno.espcod )
    returning lr_retorno.srvespnum  
    
    return lr_retorno.srvespnum 
                                                                                                              
end function  

#----------------------------------------------------#                                                                  
function ctx35g01_recupera_tipo_assistencia(lr_param)                                                                     
#----------------------------------------------------#

define lr_param record                              
	 atdsrvnum  like datmservico.atdsrvnum  ,      
	 atdsrvano  like datmservico.atdsrvano  
end record

define lr_retorno record           
   asitipcod  like datmservico.asitipcod                           
end record	                                         

       #---------------------------------------------------------#          
       # CURSOR PARA TRAZER O TIPO DE ASSISTENCIA DO SERVICO     #          
       #---------------------------------------------------------#          
       whenever error continue                                   
         open c_ctx35g01_005 using lr_param.atdsrvnum,  
                                   lr_param.atdsrvano 
                        
         fetch c_ctx35g01_005 into lr_retorno.asitipcod                                                                              
       whenever error stop 
       
       return lr_retorno.asitipcod                                            

end function  

#----------------------------------------------#                                                                                                                        
function ctx35g01_recupera_motivo(lr_param)                             
#----------------------------------------------#

define lr_param record                              
	 atdsrvnum  like datmservico.atdsrvnum  ,      
	 atdsrvano  like datmservico.atdsrvano  
end record

define lr_retorno record                
   avialgmtv like datmavisrent.avialgmtv                    
end record	                                          

                                                                     
       #--------------------------------------------#        
       # CURSOR PARA TRAZER O MOTIVO DO SERVICO     #        
       #--------------------------------------------#        
       whenever error continue                                            
         open c_ctx35g01_006 using lr_param.atdsrvnum,                    
                                   lr_param.atdsrvano                     
                                                                          
         fetch c_ctx35g01_006 into lr_retorno.avialgmtv                                                                                             
       whenever error stop 
       
       return lr_retorno.avialgmtv                                           
                                                                                                                                                                                                                        
end function

#----------------------------------------------#                                                                  
function ctx35g01_recupera_natureza(lr_param)                                                                     
#----------------------------------------------#

define lr_param record                              
	 atdsrvnum like datmservico.atdsrvnum  ,      
	 atdsrvano like datmservico.atdsrvano    
end record

define lr_retorno record             
   socntzcod like datmsrvre.socntzcod    ,      
   espcod    like datmsrvre.espcod                           
end record	                                        


       initialize lr_retorno.* to null

       #---------------------------------------------------------#          
       # CURSOR PARA TRAZER A NATUREZA DO SERVICO                #          
       #---------------------------------------------------------#          
       whenever error continue                                   
         open c_ctx35g01_002 using lr_param.atdsrvnum,  
                                   lr_param.atdsrvano 
                        
         fetch c_ctx35g01_002 into lr_retorno.socntzcod,
                                   lr_retorno.espcod                                                                            
       whenever error stop
       
       return lr_retorno.socntzcod,
              lr_retorno.espcod                                         

end function  



#-------------------------------------------------#                                      
function ctx35g01_recupera_especialidade(lr_param)                                       
#-------------------------------------------------#                                                                                                      
                                                                                         
define lr_param  record                                                                  
	    codori     integer                                                                 
    , codigo     integer                                                                 
    , subcod     integer                                                                 
end record                                                                               
                                                                                         
define lr_retorno record                                                                 
      srvespnum  integer,
      chave      char(30)                                                                 
end record                                                                               
                                                                                         
                                                                                         
      initialize lr_retorno.* to null                                                    
                                                                                         
      if m_ctx35g01_prep is null or                                                            
         m_ctx35g01_prep <> true then                                                          
         call ctx35g01_prepare()                                                         
      end if                                                                             
                                                                                         
      let lr_retorno.chave = "SIE_DEPARA_ESP"                                              
                                                                                         
      #---------------------------------------------------------#                        
      # CURSOR PARA TRAZER A NATUREZA DO SERVICO                #                        
      #---------------------------------------------------------#                        
      whenever error continue                                                            
        open c_ctx35g01_010 using lr_retorno.chave  ,                                    
                                  lr_param.codori   ,                                    
                                  lr_param.subcod   ,                                    
                                  lr_param.codigo                                        
                                                                                         
        fetch c_ctx35g01_010 into lr_retorno.srvespnum                                   
      whenever error stop                                                                
                                                                                         
      return lr_retorno.srvespnum                                                        
                                                                                         
end function                                                                             
                                                                                         
                                                                                         