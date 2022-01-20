#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Central Itau                                               #
# Modulo.........: bdata006                                                   #
# Objetivo.......: Batch Para Transferir os Dados dos Servicos para o Siebel  #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 30/01/2015                                                 #
#.............................................................................#


database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

globals
   define g_ismqconn smallint
end globals



 
define m_bdata006_prep   smallint
define m_arquivo         char(100)
define m_mensagem        char(150)
define m_path_log        char(100)


define mr_total record
   lidos         integer ,
   gravados      integer ,
   processados   integer 
end record

define mr_param record
	  ini date                                     ,
	  fim date                                     ,
	  hour_ini datetime hour to second             ,
	  hour_fim datetime hour to second                
end record


define mr_data record
  inicio date ,
  fim    date
end record

#========================================================================
main
#========================================================================

   define l_path char(200)

   let m_path_log = null
   let m_path_log = f_path("DAT","LOG")

   if m_path_log is null or
      m_path_log = " " then
      let m_path_log = "."
   end if

  
   display 'DIRETORIO DE LOG: ',m_path_log

   let m_path_log = m_path_log clipped, "/bdata006.log"

   call startlog(m_path_log)


   call bdata006()

#========================================================================
end main
#========================================================================




#========================================================================
function bdata006()
#========================================================================



initialize mr_param.*, mr_data.* to null  
  
   call bdata006_exibe_inicio()

   call fun_dba_abre_banco("CT24HS")
  

   set lock mode to wait 10
   set isolation to dirty read

   let m_bdata006_prep = false
   
   call bdata006_prepare()

   let mr_total.lidos         = 0
   let mr_total.gravados      = 0
   
  

   display "##################################"
   display " TRANSFERINDO SERVICOS            "
   display "##################################"  
   
  
   if not bdata006_carga_full() then
      exit program
   end if

   call bdata006_exibe_final()

   call bdata006_dispara_email()




#========================================================================
end function
#========================================================================

#===============================================================================
 function bdata006_prepare()
#===============================================================================

define l_sql char(10000)

     
   let l_sql = ' select a.atdsrvnum,               ',
               '        a.atdsrvano                ',         
               ' from datmservico a,               ',
               '      datmligacao b                ',         
               ' where a.atdsrvnum = b.atdsrvnum   ',              
               ' and   a.atdsrvano = b.atdsrvano   ',
               ' and   b.c24astcod = ?             ',
               ' and   a.atdlibdat between ? and ? ',
               ' and   a.atdlibflg = "S"           '                       
   prepare p_bdata006_001 from l_sql                
   declare c_bdata006_001 cursor for p_bdata006_001


   let l_sql = 'select atdetpcod     ',                       
               '  from datmsrvacp    ',                       
               ' where atdsrvnum = ? ',                       
               '   and atdsrvano = ? ',                       
               '   and atdsrvseq = (select max(atdsrvseq)',   
                                   '  from datmsrvacp    ',   
                                   ' where atdsrvnum = ? ',   
                                   '   and atdsrvano = ?)'    
   prepare p_bdata006_002 from l_sql                         
   declare c_bdata006_002 cursor for p_bdata006_002          
  

  let l_sql = ' select cpodes        '
             ,' from datkdominio     '
             ,' where cponom =  ?    '
             ,' and   cpocod =  ?    '
  prepare p_bdata006_003 from l_sql
  declare c_bdata006_003 cursor for p_bdata006_003
  	
  let l_sql = ' select cpodes        '
             ,' from datkdominio     '
             ,' where cponom =  ?    '
  prepare p_bdata006_004 from l_sql
  declare c_bdata006_004 cursor for p_bdata006_004 	
  	


 let m_bdata006_prep = true

#========================================================================
end function
#========================================================================







#========================================================================
function bdata006_exibe_inicio()
#========================================================================
define l_data  date,
       l_hora  datetime hour to second

let l_data            = today
let l_hora            = current
let mr_param.ini      = today
let mr_param.hour_ini = current

   display " "
   display "-----------------------------------------------------------"
   display " INICIO bdata006 - CARGA DE LIMITES DO ITAU       "
   display "-----------------------------------------------------------"
   display " "
   display " INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog("------------------------------------------------------")
   let m_mensagem = "INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog(m_mensagem)


#========================================================================
end function
#========================================================================

#========================================================================
function bdata006_exibe_final()
#========================================================================
   define l_data  date,
          l_hora  datetime hour to second


   let l_data            = today
   let l_hora            = current
   let mr_param.fim      = today
   let mr_param.hour_fim = current
   display " "
   display " TERMINO DO PROCESSAMENTO...: ", l_data, " ", l_hora
   let m_mensagem = " TERMINO DO PROCESSAMENTO...: ", l_data, " ", l_hora
   call errorlog(m_mensagem)
   call errorlog("------------------------------------------------------")

#========================================================================
end function
#========================================================================



#========================================================================
 function bdata006_recupera_data_inicio()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata006_inicio"
let lr_retorno.cpocod = 1


  open c_bdata006_003 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata006_003 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes is not null  then
     let mr_data.inicio =  lr_retorno.cpodes
  end if


#========================================================================
end function
#========================================================================

#========================================================================
 function bdata006_recupera_data_fim()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata006_fim"
let lr_retorno.cpocod = 1


  open c_bdata006_003 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata006_003 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes is not null  then
     let mr_data.fim =  lr_retorno.cpodes
  end if


#========================================================================
end function
#========================================================================

#========================================================================
 function bdata006_carga_full()
#========================================================================

define lr_retorno record
	cponom      like datkdominio.cponom     ,
	cpocod      like datkdominio.cpocod     ,
	cpodes      like datkdominio.cpodes     ,
	atdsrvnum   like datmservico.atdsrvnum  ,
	atdsrvano   like datmservico.atdsrvano  ,                  
	atdsrvorg   like datmservico.atdsrvorg  ,                  
  atdlibflg   like datmservico.atdlibflg  ,                  
  c24astcod   like datmligacao.c24astcod  ,                  
  lignum      like datmligacao.lignum     ,                  
  itmnumdig   like datrservapol.itmnumdig ,                  
  srvespnum   like datksrvesp.srvespnum   ,                  
  numsolic    char(20)                    ,                  
  doctip      integer                     ,                  
  documento   char(80)                    ,                  
  datahora    datetime year to second     ,                  
  valuti      integer                                                     
end record	                                                      


initialize mr_data.*, lr_retorno.* to null


  call bdata006_recupera_data_inicio()

  call bdata006_recupera_data_fim()

  if mr_data.inicio is null or
  	 mr_data.fim    is null then
  	  let m_mensagem = "Datas Invalidas!"
  	  call errorlog(m_mensagem);
  	  display m_mensagem
  	  return false
  end if
 
  
  if mr_data.fim	< mr_data.inicio then
  	  let m_mensagem = "Data Final Maior Que a Inicial"
      call errorlog(m_mensagem);
      display m_mensagem
      return false
  end if
  
   let lr_retorno.cponom = "bdata006_assunto"
  
   open c_bdata006_004 using   lr_retorno.cponom                       
   foreach c_bdata006_004 into lr_retorno.cpodes  
                           
       #---------------------------------------------#
       # RECUPERA OS SERVICOS                        #
       #---------------------------------------------#
       
       open c_bdata006_001 using lr_retorno.cpodes,
                                 mr_data.inicio   ,
                                 mr_data.fim  
   
       foreach c_bdata006_001 into lr_retorno.atdsrvnum, 
                                   lr_retorno.atdsrvano
                                   
          let mr_total.lidos = mr_total.lidos + 1
          
          #---------------------------------------------#  
          # VERIFICA A ETAPA DO SERVICO                 #  
          #---------------------------------------------#  
          
          if not bdata006_verifica_etapa(lr_retorno.atdsrvnum, 
                                         lr_retorno.atdsrvano) then 
             continue foreach
          end if
          
          #---------------------------------------------# 
          # RECUPERA OS DADOS DO SERVICO                # 
          #---------------------------------------------# 
          
          call ctx35g01_carrega_dados(lr_retorno.atdsrvnum,   
                                      lr_retorno.atdsrvano)   
          returning lr_retorno.doctip    , 
                    lr_retorno.documento , 
                    lr_retorno.numsolic  , 
                    lr_retorno.itmnumdig ,
                    lr_retorno.atdsrvorg ,
                    lr_retorno.atdlibflg ,
                    lr_retorno.c24astcod , 
                    lr_retorno.datahora  , 
                    lr_retorno.valuti     
           
                      		                                                        
         #---------------------------------------------#         
         # RECUPERA OS DADOS DO DE-PARA                #         
         #---------------------------------------------#           
                                                                   
         call ctx35g01_recupera_codigo(lr_retorno.atdsrvnum  ,       
                                       lr_retorno.atdsrvano  ,       
                                       lr_retorno.atdsrvorg)       
         returning lr_retorno.srvespnum
         
         let  mr_total.gravados =  mr_total.gravados + 1
         
         #---------------------------------------------------------#    
         # TRANSFERE PARA O SIEBEL UMA INCLUSAO                    #    
         #---------------------------------------------------------#    
                                                                        
         call ctx35g01_inclui_xml(lr_retorno.atdsrvorg ,                
                                  lr_retorno.c24astcod ,                
                                  lr_retorno.itmnumdig ,                
                                  lr_retorno.srvespnum ,                
                                  lr_retorno.numsolic  ,                
                                  lr_retorno.doctip    ,                
                                  lr_retorno.documento ,                
                                  lr_retorno.datahora  ,                
                                  lr_retorno.valuti    )                
            
                   
          
       end foreach

   end foreach


  call bdata006_exibe_dados_totais()

  return true
#========================================================================
end function
#========================================================================


#========================================================================
function bdata006_exibe_dados_totais()
#========================================================================

   display " "
   display "-----------------------------------------------------------"
   display " DADOS TOTAIS "
   display "-----------------------------------------------------------"
   display " "
   display " TOTAIS LIDOS APOLICE................: ", mr_total.lidos
   display " TOTAIS ENVIADOS SIEBEL..............: ", mr_total.gravados
   let m_mensagem = "-----------------------------------------------------------"
   call errorlog(m_mensagem)
   let m_mensagem = " DADOS TOTAIS "
   call errorlog(m_mensagem)
   let m_mensagem = "-----------------------------------------------------------"
   call errorlog(m_mensagem)
   let m_mensagem = " TOTAIS LIDOS APOLICE................: ", mr_total.lidos
   call errorlog(m_mensagem)
   let m_mensagem = " TOTAIS ENVIADOS SIEBEL..............: ", mr_total.gravados
   call errorlog(m_mensagem)
   let m_mensagem = "-----------------------------------------------------------"
   call errorlog(m_mensagem)
#========================================================================
end function
#========================================================================

#========================================================================
function bdata006_dispara_email()
#========================================================================
define lr_mail      record
       de           char(500)   # De
      ,para         char(5000)  # Para
      ,cc           char(500)   # cc
      ,cco          char(500)   # cco
      ,assunto      char(500)   # Assunto do e-mail
      ,mensagem     char(32766) # Nome do Anexo
      ,id_remetente char(20)
      ,tipo         char(4)     #
  end  record

define l_erro  smallint

define msg_erro char(500)

initialize lr_mail.* to null

    let lr_mail.de      = "ct24hs.email@portoseguro.com.br"
    let lr_mail.para    = bdata006_recupera_email()
    let lr_mail.cc      = ""
    let lr_mail.cco     = ""
    let lr_mail.assunto = "DADOS PROCESSADOS CARGA ENDERECO ITAU RE"
    let lr_mail.mensagem  = bdata006_monta_mensagem()
    let lr_mail.id_remetente = "CT24HS"
    let lr_mail.tipo = "html"

    #-----------------------------------------------
    # Dispara o E-mail
    #-----------------------------------------------

     call figrc009_attach_file(m_arquivo)

     call figrc009_mail_send1 (lr_mail.*)
     returning l_erro
              ,msg_erro

#========================================================================
end function
#========================================================================
#========================================================================
 function bdata006_recupera_email()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes,
	email   char(32766)            ,
	flag    smallint
end record

initialize lr_retorno.* to null

let lr_retorno.flag = true

let lr_retorno.cponom = "bdata006_email"

  open c_bdata006_004 using  lr_retorno.cponom

  foreach c_bdata006_004 into lr_retorno.cpodes

    if lr_retorno.flag then
      let lr_retorno.email = lr_retorno.cpodes clipped
      let lr_retorno.flag  = false
    else
      let lr_retorno.email = lr_retorno.email clipped, ";", lr_retorno.cpodes clipped
    end if

  end foreach

  return lr_retorno.email

#========================================================================
end function
#========================================================================

#========================================================================
function bdata006_monta_mensagem()
#========================================================================

define lr_retorno record
	mensagem  char(30000)
end record

initialize lr_retorno.* to null

          #-----------------------------------------------
          # Monta a Mensagem
          #-----------------------------------------------
          let lr_retorno.mensagem = " INICIO DO PROCESSAMENTO: "            , mr_param.ini, " - "   , mr_param.hour_ini , "<br><br>",
                                    " FINAL DO PROCESSAMENTO: "             , mr_param.fim, " - "   , mr_param.hour_fim , "<br><br>",
                                    " TOTAIS LIDOS APOLICE : "              , mr_total.lidos        , "<br>" ,                                 
                                    " TOTAIS ENVIADOS SIEBEL : "            , mr_total.gravados     , "<br>" 
          return lr_retorno.mensagem
#========================================================================
end function
#========================================================================



#========================================================================              
 function bdata006_verifica_etapa(lr_param)                                                    
#========================================================================              
                                                                                       
define lr_param record                         
	 atdsrvnum  like datmservico.atdsrvnum  ,    
	 atdsrvano  like datmservico.atdsrvano       
end record                                     

define lr_retorno record                                                               
	atdetpcod  like datmsrvacp.atdetpcod                                                                                                                   
end record                                                                             
                                                                                       
initialize lr_retorno.* to null                                                        
                                                                                                                             
  #-------------------------------
  # Verifica a Etapa do Servico                         
  #-------------------------------                                                      
  open  c_bdata006_002  using lr_param.atdsrvnum,     
                              lr_param.atdsrvano,     
                              lr_param.atdsrvnum,     
                              lr_param.atdsrvano      
  whenever error continue                               
  fetch c_bdata006_002  into  lr_retorno.atdetpcod      
  whenever error stop                                   
  
  if lr_retorno.atdetpcod <> 5 then
     return true
  else
     return false
  end if                                                                                                                                                
                                                                                       
#========================================================================              
end function                                                                           
#========================================================================              

































function fonetica2(a)
define a char(50)
let a = null

return a
end function
   
