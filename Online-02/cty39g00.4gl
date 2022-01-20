#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty39g00                                                    #
# Objetivo.......: Controlador Assunto SDF                                     #
# Analista Resp. : Alberto Rodrigues                                           #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 09/02/2015                                                  #
#..............................................................................#  
# 25/03/2015 ST-2015-00006  Alberto/Roberto                                    #
#------------------------------------------------------------------------------#
# 23/03/2016 Alberto/Roberto  SPR-2016-03858 - Carro Reserva Itaú, fase II     #
#------------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"       
                                                         
database porto                                           
                                                         
define m_prepare smallint  

define mr_param record                 
    sinvstnum  like ssamsin.sinvstnum       , 	
    sinvstano  like ssamsin.sinvstano       ,
    clscod     like abbmclaus.clscod        ,
    beneficio  smallint                     ,
    programa   smallint  
end record                                                         
                                

#----------------------------------------------#                
 function cty39g00_prepare()                                    
#----------------------------------------------#                
                                                                
  define l_sql char(1000)                                        
                                                                
  let l_sql = ' select cpodes           '                       
          ,  '  from datkdominio        '                       
          ,  '  where cponom = ?        '                       
          ,  '  order by cpocod         '                       
  prepare pcty39g00001 from l_sql                               
  declare ccty39g00001 cursor for pcty39g00001 
  	
  let l_sql = ' select clscod           	'
            , ' from abbmclaus            '
            , ' where succod  = ?         '
            , ' and aplnumdig = ?         ' 
            , ' and itmnumdig = ?         '  
            , ' and dctnumseq = ?	        '
  prepare pcty39g00002 from l_sql              
  declare ccty39g00002 cursor for pcty39g00002
  	
  	
  let l_sql = 'select a.atddat ,   '                  	
             ,'       a.atddatprg, '
             ,'       a.atdsrvnum, '
             ,'       a.atdsrvano  '                   	
             ,'from datmservico a, '                  	
             ,'     datmligacao b, '                  	
             ,'     datrligapol c  '             	
             ,'where a.atdsrvnum = b.atdsrvnum '      	
             ,'and a.atdsrvano = b.atdsrvano   '        	
             ,'and b.lignum    = c.lignum      '           	
             ,'and c.succod    = ?             '                  	
             ,'and c.ramcod    = ?             '                  	
             ,'and c.aplnumdig = ?             '                  	
             ,'and c.itmnumdig = ?             '               	
             ,'and b.c24astcod = "SDF"         '
             ,'order by 1                      '                  	
  prepare pcty39g00003 from l_sql                  	
  declare ccty39g00003 cursor for pcty39g00003 
  	
  let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '          
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 ' 
           ,  '   ,atlult)                '           
           ,  ' values(?,?,?,?)           '
  prepare pcty39g00007 from l_sql
  
  
  let l_sql = ' select max(cpocod)             '
           ,  ' from datkdominio               '   
           ,  ' where cponom = ?               '   
  prepare pcty39g00008 from l_sql
  declare ccty39g00008 cursor for pcty39g00008
  	
  	
  let l_sql = '  select cpodes[01,06],         '       	
          ,  '          cpodes[08,11]          '       	  	
          ,  '  from datkdominio               '       	
          ,  '  where cponom = ?               ' 
          ,  '  and   cpodes[13,22] = ?        '
          ,  '  and   cpodes[24,27] = ?        ' 	  	     	
  prepare pcty39g00009 from l_sql                    	     
  declare ccty39g00009 cursor for pcty39g00009 
  
  	
  let l_sql = 'select a.atdsrvnum,             '      
             ,'       a.atdsrvano              '            
             ,'from datmservico  a,            '                 
             ,'     datmligacao  b,            '                 
             ,'     datrligapol  c,            '
             ,'     datmavisrent d             '          	   
             ,'where a.atdsrvnum = b.atdsrvnum '     
             ,'and a.atdsrvano = b.atdsrvano   '     	
             ,'and b.lignum    = c.lignum      ' 
             ,'and a.atdsrvnum = d.atdsrvnum   '   
             ,'and a.atdsrvano = d.atdsrvano   '       	
             ,'and c.succod    = ?             '     	
             ,'and c.ramcod    = ?             '     	
             ,'and c.aplnumdig = ?             '     	
             ,'and c.itmnumdig = ?             '     	
             ,'and b.c24astcod in ("H10","H12")' 
             ,'and d.avialgmtv = 21            '    	   	
  prepare pcty39g00010 from l_sql                  	 	
  declare ccty39g00010 cursor for pcty39g00010  
  	
  let l_sql = ' select count(*)          '                       
           ,  '  from datkdominio        '                       
           ,  '  where cponom = ?        '                       
           ,  '  and  cpodes  = ?        '                       
  prepare pcty39g00011 from l_sql                               
  declare ccty39g00011 cursor for pcty39g00011  
  	
  	
  let l_sql = ' select segnumdig  '
             ,' from abbmdoc      '
             ,' where succod = ?  '
             ,' and aplnumdig = ? '
             ,' and dctnumseq in( select max(dctnumseq) from abbmdoc '
                               ,' where succod = ?    '
                               ,' and aplnumdig = ? ) '
  prepare pcty39g00012 from l_sql             
  declare ccty39g00012 cursor for pcty39g00012
  	
  let l_sql = ' select cgccpfnum    '
             ,'       ,cgcord       '
             ,'       ,cgccpfdig    ' 
             ,'       ,pestip       '
             ,'       ,segnom       '
             ,' from gsakseg        '
             ,' where segnumdig = ? '
  prepare pcty39g00013 from l_sql             
  declare ccty39g00013 cursor for pcty39g00013	
  	
  let l_sql = ' select endcid       '                
             ,' from gsakend        '           
             ,' where segnumdig = ? '   
             ,' and endfld = 1      '        
  prepare pcty39g00014 from l_sql               
  declare ccty39g00014 cursor for pcty39g00014	
	
	let l_sql = ' select dddnum       '           
             ,'       ,telnum       '               
             ,' from gsaktel        '           
             ,' where segnumdig = ? '           
  prepare pcty39g00015 from l_sql               
  declare ccty39g00015 cursor for pcty39g00015
  	
  
  let l_sql = ' select c24astdes       '                
             ,' from datkassunto       '           
             ,' where c24astcod = ?    '        
  prepare pcty39g00016 from l_sql               
  declare ccty39g00016 cursor for pcty39g00016
  	
  	
  let l_sql =  ' select ctgtrfcod  '                           	
              ,' from abbmcasco    '                     	
              ,' where succod  = ? '                     	
              ,' and aplnumdig = ? '                     	
              ,' and itmnumdig = ? '                     	
              ,' and dctnumseq = ? '                     	
  prepare pcty39g00017 from l_sql              	
  declare ccty39g00017 cursor for pcty39g00017 	
  
  	  	                                                    
  let m_prepare = true                                          
                                                                
end function


#--------------------------------------------------------#                                                                         
 function cty39g00_verifica_clausula_principal(lr_param)                         
#--------------------------------------------------------#                     
                                                                     
define lr_param record     
	clscod    like abbmclaus.clscod                                                                 
end record                                                           
                                                                     
define lr_retorno record                                             
  clscod    like abbmclaus.clscod,                                             
  chave     char(20)                                            
end record                                                           
                                                                                                                                              
                                                                     
initialize lr_retorno.* to null                                      
                                                                     
let lr_retorno.chave = "cty39g00_claus1"                                                                     

                                                                                       
    #--------------------------------------------------------        
    # Valida Clausula Principal                         
    #--------------------------------------------------------        
                                                                     
                                                                     
    open ccty39g00001  using  lr_retorno.chave                         
    foreach ccty39g00001 into lr_retorno.clscod            
                                                                     
        if lr_param.clscod  = lr_retorno.clscod then
        	 return true                                  
        end if
                                                                     
    end foreach                                                      
                                                                     
    return false                                
                                                                     
                                                                     
end function  

#--------------------------------------------------------#                                                                         
 function cty39g00_verifica_clausula_secundaria(lr_param)                         
#--------------------------------------------------------#                     
                                                                     
define lr_param record     
	clscod    like abbmclaus.clscod                                                                 
end record                                                           
                                                                     
define lr_retorno record                                             
  clscod    like abbmclaus.clscod,                                             
  chave     char(20)                                            
end record                                                           
                                                                                                                                              
                                                                     
initialize lr_retorno.* to null                                      
                                                                     
let lr_retorno.chave = "cty39g00_claus2"                                                                     

                                                                                       
    #--------------------------------------------------------        
    # Valida Clausula Secundaria                        
    #--------------------------------------------------------        
                                                                     
                                                                     
    open ccty39g00001  using  lr_retorno.chave                         
    foreach ccty39g00001 into lr_retorno.clscod            
                                                                     
        if lr_param.clscod  = lr_retorno.clscod then
        	 return true                                  
        end if
                                                                     
    end foreach    
    
    
    #--------------------------------------------------------       
    # Valida se a Apolice e de Deficiente Fisico                                    
    #--------------------------------------------------------       
   
    if cty31g00_valida_fisico_apolice(g_documento.succod   ,           
                                      g_documento.aplnumdig,           
                                      g_documento.itmnumdig) then  
                                  	
        return true
    end if                                  	    
                                                                                                                       
    return false                                
                                                                     
                                                                     
end function

#--------------------------------------------------------#                                                                         
 function cty39g00_valida_permissao(lr_param)                         
#--------------------------------------------------------#

define lr_param record                    
	c24astcod like datkassunto.c24astcod    
end record                                                     
                                                                     
   if g_documento.ciaempcod = 1     and
   	  g_documento.ramcod    = 531   and 
   	  lr_param.c24astcod    = "SDF" then
          return true                         
   end if                                                                  
                     
   return false                  
                                                                     
end function

#--------------------------------------------------------#                                                                         
 function cty39g00_valida_clausula(lr_param)                         
#--------------------------------------------------------#                     
                                                                     
define lr_param record     
  succod     like abbmvtg.succod    ,      	
	aplnumdig  like abbmvtg.aplnumdig ,
  itmnumdig  like abbmvtg.itmnumdig ,
  dctnumseq  like abbmvtg.dctnumseq 
end record                                                         
                                                                     
define lr_retorno record                                             
  clscod    like abbmclaus.clscod,                                             
  clausula1 smallint             ,
  clausula2 smallint                                            
end record                                                           
                                                                                                                                              
                                                                     
initialize lr_retorno.* to null 

    if m_prepare is null or         
       m_prepare <> true then       
       call cty39g00_prepare()      
    end if 
    
    let lr_retorno.clausula1 = false
    let lr_retorno.clausula2 = false                                                         
                                                                                                                                                                                                                             
    #--------------------------------------------------------        
    # Recupera Clausulas                       
    #--------------------------------------------------------        
                                                                     
                                                                     
    open ccty39g00002  using lr_param.succod    ,    
                             lr_param.aplnumdig ,
                             lr_param.itmnumdig ,
                             lr_param.dctnumseq
                        
    foreach ccty39g00002 into lr_retorno.clscod   
                                                                       
        #-------------------------------------------------------- 
        # Valida Clausula Principal                                      
        #-------------------------------------------------------- 
        
        if not lr_retorno.clausula1 then
        	  let lr_retorno.clausula1 = cty39g00_verifica_clausula_principal(lr_retorno.clscod)
        	  let mr_param.clscod      = lr_retorno.clscod
        end if  
        
        #--------------------------------------------------------   
        # Valida Clausula Secundaria                                 
        #--------------------------------------------------------   
        
        if not lr_retorno.clausula2 then                                                            
        	  let lr_retorno.clausula2 = cty39g00_verifica_clausula_secundaria(lr_retorno.clscod)      
        end if	                                                                                  	
               
                                                                     
    end foreach                                                      
                                                                     
    if lr_retorno.clausula1 and
    	 lr_retorno.clausula2 then 
       return true
    end if
    
    return false                                
                                                                     
                                                                     
end function 

#--------------------------------------------------------#                                                                       
 function cty39g00(lr_param)                                                                                                                                                 
#--------------------------------------------------------#

define lr_param record
	c24astcod like datkassunto.c24astcod
end record   

define lr_retorno record                                   
  confirma   char(01),
  resultado  integer                                                                          
end record

   initialize lr_retorno.*, mr_param.* to null                                        

   let mr_param.beneficio = false
   let mr_param.programa  = false      
            
   #--------------------------------------------------------
   # Verifica se Empresa e Ramo tem Acesso                           
   #--------------------------------------------------------
   
   if cty39g00_valida_permissao(lr_param.c24astcod) then
   	
      
      #--------------------------------------------------------
      # Verifica se Clausulas tem Acesso                            
      #--------------------------------------------------------
      
      if cty39g00_valida_clausula(g_documento.succod    ,
                                  g_documento.aplnumdig ,
                                  g_documento.itmnumdig ,
                                  g_funapol.dctnumseq   ) then
   
         
         #--------------------------------------------------------
         # Recupera o Numero do Aviso de Sinistro                              
         #--------------------------------------------------------
         
         call cty39g00_seleciona_sinistro(g_documento.succod    ,
                                          g_documento.aplnumdig ,
                                          g_documento.itmnumdig )        
         returning mr_param.sinvstnum,
                   mr_param.sinvstano,
                   lr_retorno.resultado
         
         if lr_retorno.resultado <> 0 then
            return false
         end if	 
                    
         #--------------------------------------------------------
         # Verifica se Tem Beneficio                           
         #--------------------------------------------------------
         
         call faemc935_beneficio(g_documento.succod    , 
                                 g_documento.aplnumdig , 
                                 g_documento.itmnumdig , 
                                 g_funapol.dctnumseq   )
         returning mr_param.beneficio
         
         #--------------------------------------------------------------- 
         # Verifica Se Ja Foi Aberto um Carro Reserva Para Essa Apolice                              
         #--------------------------------------------------------------- 
         
         if not cty39g00_valida_reserva(g_documento.succod   , 
                                        g_documento.ramcod   ,
                                        g_documento.aplnumdig,
                                        g_documento.itmnumdig) then
           return false
           
         end if
         
         call cty39g00_qtd_servico(g_documento.succod    , 
                                   g_documento.ramcod    ,
                                   g_documento.aplnumdig ,
                                   g_documento.itmnumdig )
         
         
         if not cty39g00_valida_periodo() then
         	
         	  call cts08g01("A","N",                       
                          "",                            
                          "LIMITE DE 7 DIAS EXCEDIDO.",  
                          "",                            
                          "")                            
            returning lr_retorno.confirma                
 	
            return false
         else
            if not cty39g00_valida_diaria(today) then  
            	
            	 call cts08g01("C","S",                                                      
            	               "LIMITE DE 2 ATENDIMENTOS"   ,    
            	               "PARA A DATA ATUAL EXCEDIDO.",                              
            	               "DESEJA ABRIR ATENDIMENTO "  ,
            	               "PARA UMA DATA PROGRAMADA?")                             
            	 returning lr_retorno.confirma                  
            	                                                
            	 if lr_retorno.confirma = "N" then 
            	    return false                                   
            	 else
            	 	  let mr_param.programa  = true    
            	 end if
            	
            end if	
         end if        
                  
      else   
      	
      	  call cts08g01("A","N",                        
      	                "",                             
      	                "CLAUSULA SEM PERMISSAO",   
      	                "DE ACESSO AO SDF",                             
      	                "")                             
      	  returning lr_retorno.confirma 
      	  
      	  return false                
      	
      end if
     
   end if	
   
   return true             
                                                                                     
end function  

#----------------------------------------#
function cty39g00_qtd_servico(lr_param)
#----------------------------------------#
 
 define lr_param record
    succod    like datrligapol.succod   
   ,ramcod    like datrligapol.ramcod   
   ,aplnumdig like datrligapol.aplnumdig   
   ,itmnumdig like datrligapol.itmnumdig
 end record

 define lr_retorno record
    atdsrvnum   like datrservapol.atdsrvnum
   ,atdsrvano   like datrservapol.atdsrvano 
   ,atddat      like datmservico.atddat  
   ,atddatprg   like datmservico.atddatprg
   ,sinvstnum   like ssamsin.sinvstnum        	  
   ,sinvstano   like ssamsin.sinvstano            
   ,data        date
   ,qtd_evento  integer   
   ,qtd_dia     integer          
   ,resultado   smallint   
 end record


 if m_prepare is null or      
    m_prepare <> true then        
    call cty39g00_prepare()   
 end if  
 
 if not cty39g00_cria_temp() then                                                       
   error  "Erro na Criacao da Tabela Temporaria!"     
 else
 	 call cty39g00_prep_temp()
 end if 
  	
                                                
                      

 initialize lr_retorno.* to null

    let lr_retorno.qtd_evento = 0    
    let lr_retorno.qtd_dia    = 0    
   
  
    if lr_param.aplnumdig is not null then
       
      #--------------------------------------------------------    
      # Recupera os Servicos Feito Pela Apolice                                                    
      #--------------------------------------------------------                   
            
       open ccty39g00003 using lr_param.succod   
                              ,lr_param.ramcod   
                              ,lr_param.aplnumdig
                              ,lr_param.itmnumdig     
       
       foreach ccty39g00003 into lr_retorno.atddat
       	                        ,lr_retorno.atddatprg 
       	                        ,lr_retorno.atdsrvnum 
       	                        ,lr_retorno.atdsrvano 
                                               
       
        #--------------------------------------------------------  
        # Consiste o Servico                      
        #--------------------------------------------------------  
        
        call cty39g00_consiste_servico(lr_retorno.atdsrvnum,
                                       lr_retorno.atdsrvano)                                     
        returning lr_retorno.resultado                             
          
          
        if lr_retorno.resultado = 1 then   
        	 
           if lr_retorno.atddatprg is null then
              let lr_retorno.data  = lr_retorno.atddat
           else
           	  let lr_retorno.data  = lr_retorno.atddatprg   
           end if
           
           #--------------------------------------------------------
           # Recupera o Numero do Sinistro                                     
           #--------------------------------------------------------
          
           call cty39g00_recupera_sinistro(lr_retorno.atdsrvnum,
                                           lr_retorno.atdsrvano,
                                           1)
           returning lr_retorno.sinvstnum,
                     lr_retorno.sinvstano
           
           
           #-------------------------------------------------------- 
           # Grava na Temporaria                           
           #-------------------------------------------------------- 
                      
           call cty39g00_grava_data(lr_retorno.data 
                                   ,1
                                   ,lr_retorno.sinvstnum
                                   ,lr_retorno.sinvstano)
           
        end if
          
       end foreach
       
       close ccty39g00003
    end if 
         

end function


#---------------------------------------------#
function cty39g00_consiste_servico(lr_param)
#---------------------------------------------#

define lr_param record
   atdsrvnum like datmservico.atdsrvnum
  ,atdsrvano like datmservico.atdsrvano
end record

 define lr_retorno record
   resultado smallint                                    
  ,atdetpcod like datmsrvacp.atdetpcod                           
 end record

 initialize lr_retorno.* to null


 #-------------------------------------------------------- 
 # Recupera a Ultima Etapa do Servico                
 #-------------------------------------------------------- 
 
 let lr_retorno.atdetpcod = cts10g04_ultima_etapa(lr_param.atdsrvnum
                                                 ,lr_param.atdsrvano)  
                                                 
 #--------------------------------------------------------                                                 
 # Para Taxi Descarta Servicos (5) Cancelados                                                                          
 #--------------------------------------------------------                                                 
                                                    
 if  lr_retorno.atdetpcod  <> 5   then        
     let lr_retorno.resultado = 1           
 else
     let lr_retorno.resultado = 0           
 end if                  
 
 
 return lr_retorno.resultado

end function  

#------------------------------------------------------------------------------                                                                
function cty39g00_drop_temp()                                                           
#------------------------------------------------------------------------------         
                                                                                        
    whenever error continue                                                             
        drop table cty39g00_temp                                                        
    whenever error stop                                                                 
                                                                                        
    return                                                                              
                                                                                        
end function 

#------------------------------------------------------------------------------                                                                                                              
function cty39g00_cria_temp()                                                                                     
#------------------------------------------------------------------------------                                   
                                                                                                                  
 call cty39g00_drop_temp()                                                                                        
                                                                                                                  
 whenever error continue                                                                                          
      create temp table cty39g00_temp(data       date        ,                                                 
                                      qtd        smallint    ,
                                      sinvstnum  decimal(6,0),
                                      sinvstano  datetime year to year) with no log                                     
  whenever error stop                                                                                             
                                                                                                                  
  if sqlca.sqlcode <> 0  then                                                                                     
                                                                                                                  
	 if sqlca.sqlcode = -310 or                                                                                     
	    sqlca.sqlcode = -958 then                                                                                   
	        call cty39g00_drop_temp()                                                                               
	  end if                                                                                                        
                                                                                                                  
	 return false                                                                                                   
                                                                                                                  
  end if                                                                                                          
                                                                                                                  
  return true                                                                                                     
                                                                                                                  
end function 

#------------------------------------------------------------------------------                                                                                                         
function cty39g00_prep_temp()                                                      
#------------------------------------------------------------------------------    
                                                                                   
define l_sql char(1000)  

let l_sql = null                                                      
                                                                                   
    let l_sql = 'insert into cty39g00_temp '                                        
	            , ' values(?,?,?,?)'                      
    prepare pcty39g00004 from l_sql         
    
    
    let l_sql = 'select count(distinct(data)) ' 
               ,'from cty39g00_temp           '  
               ,'where sinvstnum = ?          '
               ,'and   sinvstano = ?          '
    prepare pcty39g00005 from l_sql                                 
    declare ccty39g00005 cursor for pcty39g00005  
    	
    
    let l_sql = 'select count(*)      ' 
               ,'from cty39g00_temp   ' 
               ,'where data = ?       '
               ,'and   sinvstnum = ?  '   
               ,'and   sinvstano = ?  '   
    prepare pcty39g00006 from l_sql                                 
    declare ccty39g00006 cursor for pcty39g00006
    	
    
  
    	
    	                                                                                  
end function

#---------------------------------------------#                                                                                                           
function cty39g00_grava_data(lr_param)                                       
#---------------------------------------------#                                    
                                                                                   
define lr_param record                                                             
   data        date                    ,
   qtd         smallint                ,
   sinvstnum   like ssamsin.sinvstnum  ,  
   sinvstano   like ssamsin.sinvstano                                                                                    
end record                                                                         
                                                                                   
 
   whenever error continue                                
   execute pcty39g00004 using lr_param.data       , 
                              lr_param.qtd        ,
                              lr_param.sinvstnum  ,
                              lr_param.sinvstano        
   whenever error stop    
   
                   
                                                                                   
end function 

#---------------------------------------------#                                                                            
function cty39g00_valida_periodo()               
#---------------------------------------------#      
                                                     
define lr_retorno record                                                         
   qtd      integer                             
end record

initialize lr_retorno.* to null                                           
                                                      
     open ccty39g00005 using mr_param.sinvstnum, 
                             mr_param.sinvstano
              
     whenever error continue                                              
     fetch ccty39g00005 into lr_retorno.qtd                            
     close ccty39g00005                                                  
     
     if lr_retorno.qtd >= 7 then
          return false
     end if                                                
  
     return true
                                                       
end function 

#---------------------------------------------#                                                        
function cty39g00_valida_diaria(lr_param)                              
#---------------------------------------------#


define lr_param record 
   data  date       
end record               

                                                              
define lr_retorno record                                       
   qtd      integer                                        
end record                                                     
                                                               
initialize lr_retorno.* to null 
                           
     open ccty39g00006 using lr_param.data     ,
                             mr_param.sinvstnum, 
                             mr_param.sinvstano                   
     
     whenever error continue                                   
     fetch ccty39g00006 into lr_retorno.qtd                    
     close ccty39g00006                                        
                                                       
     if lr_retorno.qtd >= 2 then                                  
          return false                                                                                                       
     end if                                                    
                                                                                                                             
     return true                                               
                                                                                                                              
end function

#---------------------------------------------#                                                                                                           
function cty39g00_verifica_diaria(lr_param)                                       
#---------------------------------------------#                                    
                                                                                   
define lr_param record                                                             
   data date                                                                                       
end record 

define lr_retorno record                                       
   qtd      integer ,                                          
   confirma char(01)                                           
end record                                                     
                                                               
initialize lr_retorno.* to null                                                                                  
   
   if not cty39g00_valida_diaria(lr_param.data) then  
            	
      call cts08g01("A","N","",                                                      
                    "LIMITE DE 2 ATENDIMENTOS"        ,    
                    "PARA A DATA PROGRAMADA EXCEDIDO.",                              
                    "")                             
      returning lr_retorno.confirma                  
            	                                                
      return false                                   
         	
   end if	
   
   return true
                                                                               
end function 

#---------------------------------------------#                                                                                                           
function cty39g00_programado()                                       
#---------------------------------------------#                                    
                                                                                  
   return mr_param.programa
                                                                    
end function   

#---------------------------------------------#                                                                        
function cty39g00_seleciona_sinistro(lr_param)                           
#---------------------------------------------#                       
                                                                      
define lr_param record                                                
   succod     like datrligapol.succod    ,    
   aplnumdig  like datrligapol.aplnumdig ,
   itmnumdig  like datrligapol.itmnumdig                                                             
end record                                                            
                                                                      
define lr_retorno record  
	 sinvstnum       like ssamsin.sinvstnum  ,
	 sinvstano       like ssamsin.sinvstano  ,                                               
   nulo            integer                 ,
   data_ocorrencia date                    ,          
   telefone        char(10)                ,      
   data_prevista   date                    ,          
   confirma        char(01)                ,      
   mensagem        char(30)                ,
   prdtipcod       integer                 ,
   liberado        char(1)                 ,
   encerrado       char(1)                 ,
   resultado       integer                                            
end record                                                            
                                                                      
initialize lr_retorno.* to null                                       
                                                                         
    let lr_retorno.resultado = 0
    
    #--------------------------------------------------------
    # Abre Tela do Sinistro                      
    #--------------------------------------------------------
    
    call ossaa009_vistorias(lr_param.succod       ,                          
                            lr_param.aplnumdig    ,                       
                            lr_param.itmnumdig    ,                       
                            lr_retorno.nulo       ,            
                            lr_retorno.nulo       ,            
                            lr_retorno.nulo       ,              
                            lr_retorno.nulo       ,              
                            lr_retorno.nulo       ,              
                            lr_retorno.nulo       ,              
                            3, "D")                      
    returning  lr_retorno.data_ocorrencia ,                  
               lr_retorno.mensagem        ,                         
               lr_retorno.telefone        ,                         
               lr_retorno.data_prevista   ,                   
               lr_retorno.confirma        ,
               lr_retorno.sinvstano       ,
               lr_retorno.sinvstnum      
                                    
    if lr_retorno.sinvstnum is not null and
    	 lr_retorno.sinvstano is not null then
    	 	   
           
           #--------------------------------------------------------
           # Recupera Dados do Sinistro para Deficientes                      
           #--------------------------------------------------------
           
           call ossaa009_cbt_deficiente(lr_retorno.sinvstano,
                                        lr_retorno.sinvstnum)
           returning lr_retorno.prdtipcod, 
                     lr_retorno.encerrado,      
                     lr_retorno.liberado
           
       
           #--------------------------------------------------------
           # Verifica se o Sinistro e Perda Parcial                       
           #--------------------------------------------------------
           
           if lr_retorno.prdtipcod <> 2    or
           	  lr_retorno.prdtipcod is null then               
              let lr_retorno.resultado = 1
              
              call cts08g01("A","N",                   
                            "ACESSO NEGADO",           
                            "VISTORIA DE SINISTRO",    
                            "DEVE SER PERDA PARCIAL",  
                            "")                        
              returning lr_retorno.confirma            
              
              
           else                
               
               #--------------------------------------------------------
               # Verifica se o Sinistro Esta Liberado                      
               #--------------------------------------------------------
             
               if lr_retorno.liberado = "N"   or
               	  lr_retorno.liberado is null then            
                  let lr_retorno.resultado = 2   
                  
                  call cts08g01("A","N",                       
                                "ACESSO NEGADO",               
                                "VISTORIA DE SINISTRO",        
                                "SE ENCONTRA NAO LIBERADO",    
                                "")                            
                  returning lr_retorno.confirma                
                                  
               else
               	 
               	 #--------------------------------------------------------
               	 # Verifica se o Sinistro esta Aberto                    
               	 #--------------------------------------------------------
               	 
               	 if lr_retorno.encerrado = "S"   or
               	 	  lr_retorno.encerrado is null then 
               	    let lr_retorno.resultado = 3 
               	    
               	    call cts08g01("A","N",                     
               	                  "ACESSO NEGADO",             
               	                  "VISTORIA DE SINISTRO",      
               	                  "SE ENCONTRA ENCERRADO",     
               	                  "")                          
               	    returning lr_retorno.confirma                            	    
               	    
               	 end if 
               end if	   
           end if
    else
      	  let lr_retorno.resultado = 4 
      	  
      	  call cts08g01("A","N",                        
      	                "ACESSO NEGADO",                
      	                "NENHUMA VISTORIA",             
      	                "DE SINISTRO SELECIONADA",      
      	                "")                             
      	  returning lr_retorno.confirma                 
      	      	  
    end if
      

   
    return lr_retorno.sinvstnum,                                                                      
           lr_retorno.sinvstano,
           lr_retorno.resultado
              


end function 

#===============================================================================                                                                       
 function cty39g00_monta_chave1()                                                                                                                                    
#===============================================================================              
                                                                                              
define lr_retorno record                                                                      
	  chave like datkdominio.cponom	, 
	  ano   smallint                                                           
end record                                                                                    
                                                                                              
initialize lr_retorno.* to null  
                                                             
 let lr_retorno.ano   =  year(today)                                                                                              
 let lr_retorno.chave = "cty39g00_cd1_", lr_retorno.ano using "&&&&"                                                    
                                                                                              
 return lr_retorno.chave                                                                      
                                                                                              
end function

#===============================================================================       
 function cty39g00_monta_chave2()                                                      
#===============================================================================       
                                                                                       
define lr_retorno record                                                               
	  chave like datkdominio.cponom	,                                                    
	  ano   smallint                                                                     
end record                                                                             
                                                                                       
initialize lr_retorno.* to null                                                        
                                                                                       
 let lr_retorno.ano   =  year(today)                                                   
 let lr_retorno.chave = "cty39g00_cd2_", lr_retorno.ano using "&&&&"                   
                                                                                       
 return lr_retorno.chave                                                               
                                                                                       
end function                                                                           


#---------------------------------------------------------                                                                                                                        
 function cty39g00_inclui(lr_param)                                                                     
#--------------------------------------------------------- 

define lr_param record
  atdsrvnum  like datrservapol.atdsrvnum  ,   
  atdsrvano  like datrservapol.atdsrvano  ,
  canal      integer    
end record

                                                                                               
define lr_retorno record                                                                        
   data_atual date                    ,                                                         
   cpodes     like datkdominio.cpodes ,                                                         
   atlult     like datkdominio.atlult ,
   chave      like datkdominio.cponom ,
   codigo     integer	                                                          
end record

   if m_prepare is null or        
      m_prepare <> true then      
      call cty39g00_prepare()     
	 end if                                                                                                            
                                                                                                
   initialize lr_retorno.* to null    


    if lr_param.canal = 1 then     
    	
    	 #-------------------------------------------------------- 
    	 # Integracao Taxi X Sinistro                 
    	 #--------------------------------------------------------                                                           
       let lr_retorno.chave = cty39g00_monta_chave1()
    end if 
    
    if lr_param.canal = 2 then 
    	
    	 #-------------------------------------------------------- 
    	 # Integracao Carro Reserva X Sinistro                              
    	 #--------------------------------------------------------                       
       let lr_retorno.chave = cty39g00_monta_chave2()  
    end if                                             
    
    let lr_retorno.codigo     = cty39g00_gera_codigo(lr_retorno.chave)                                                                                           
    let lr_retorno.data_atual = today                                                           
    let lr_retorno.atlult     = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"             
    let lr_retorno.cpodes     = mr_param.sinvstnum  using "&&&&&&"     , "|",                 
                                mr_param.sinvstano                     , "|",                
                                lr_param.atdsrvnum  using "&&&&&&&&&&" , "|",                      
                                lr_param.atdsrvano  using "&&"                                                                         
    
    whenever error continue      
                                                                        
    execute pcty39g00007 using   lr_retorno.codigo                                   
                               , lr_retorno.cpodes                                              
                               , lr_retorno.chave                                                       
                               , lr_retorno.atlult                                              
                                                                                                
    whenever error continue                                                                     
                                                                                                
    if sqlca.sqlcode <> 0 then                                                                                                                  
       error 'ERRO(',sqlca.sqlcode,') na Insercao do Sinistro X Atendimento!'                                  
    end if
    
    
    if lr_param.canal = 1 then    
    
       #--------------------------------------------------------    
       # Faz Integracao com o Sinistro                              
       #--------------------------------------------------------                                                                                          
       call cty39g00_comunica_sinistro() 
    
    end if    
                                                                                                                       
end function


#---------------------------------------------------------                                                                                            
 function cty39g00_gera_codigo(lr_param)                                             
#--------------------------------------------------------- 

define lr_param record
	chave  like datkdominio.cponom	
end record

define lr_retorno record
	 codigo integer
end record                                      
                                                  
initialize lr_retorno.* to null 
                                                               
   open ccty39g00008 using lr_param.chave                                                   
   whenever error continue                                                 
   fetch ccty39g00008 into  lr_retorno.codigo                                                                                                                                                                 
   whenever error stop  
                                                                                                                                        
   if lr_retorno.codigo is null or
   	  lr_retorno.codigo = 0     then	  	
   	    let lr_retorno.codigo = 1
   else
   	    let lr_retorno.codigo =  lr_retorno.codigo + 1                                                                           
   end if  
   
   return lr_retorno.codigo                             
                                                                                                                                                                              
end function 


#---------------------------------------------#                                                                                                           
function cty39g00_grava()                                       
#---------------------------------------------#                                    
                                                                                   
   
   if mr_param.sinvstnum is not null and 
   	  mr_param.sinvstano is not null then
   	  return true
   end if	 
   
   return false
                                                                    
end function 

#---------------------------------------------------------                                                                                            
 function cty39g00_recupera_sinistro(lr_param)                                             
#--------------------------------------------------------- 

define lr_param record                        
  atdsrvnum  like datrservapol.atdsrvnum  ,   
  atdsrvano  like datrservapol.atdsrvano  ,
  canal      integer     
end record                                    

define lr_retorno record
  sinvstnum  like ssamsin.sinvstnum       , 	   	
  sinvstano  like ssamsin.sinvstano       ,
  chave      char(20)             	                                     	
end record                                      
                                                  
initialize lr_retorno.* to null 

   
   if lr_param.canal = 1 then                                
      let lr_retorno.chave = cty39g00_monta_chave1()         
   end if                                                    
                                                             
   if lr_param.canal = 2 then                                
      let lr_retorno.chave = cty39g00_monta_chave2()         
   end if                                                    
                                                               
   open ccty39g00009 using lr_retorno.chave  ,
                           lr_param.atdsrvnum,
                           lr_param.atdsrvano
                                                     
   whenever error continue                                                 
   fetch ccty39g00009 into  lr_retorno.sinvstnum,
                            lr_retorno.sinvstano
                                                                                                                                                                   
   whenever error stop  
                                                                                                                                        
   return lr_retorno.sinvstnum, 
          lr_retorno.sinvstano 
                               
                                                                                                                                                                              
end function 

#---------------------------------------------#                                                                                                           
function cty39g00_comunica_sinistro()                                       
#---------------------------------------------#                                    


define lr_retorno record                                                                                                         
  sqlcode    integer	 ,  
  msg        char(50)             	             
end record 


   initialize lr_retorno.* to null 
                             
   if mr_param.beneficio      then   
       
       if mr_param.clscod = "035" or
       	  mr_param.clscod = "033" or     
       	  mr_param.clscod = "33R" or     
       	  mr_param.clscod = "046" or     
       	  mr_param.clscod = "46R" then  
       	  
       	  display "Integracao Efetuada com Sucesso!!!" 
       	  
       	  call sinitfopc (mr_param.sinvstnum    ,   
       	                  mr_param.sinvstano    ,
                          g_documento.succod    ,
                          g_documento.aplnumdig ,
                          g_documento.itmnumdig ,
                          ""                    ,
                          ""                    ,
                          today                 , 
                          ""                    ,
                          "C"                   , ## Estava como F
                          g_issk.funmat         ,
                          "S"                   ) 
          returning lr_retorno.sqlcode, 
                    lr_retorno.msg
          display "<1142> lr_retorno.sqlcode/lr_retorno.msg > ", 
                          lr_retorno.sqlcode,"/",lr_retorno.msg
      
      end if   	
   end if 
  
                                                                    
end function

#---------------------------------------------------------                                                                                                             
 function cty39g00_valida_reserva(lr_param)                                                                                                                                  
#---------------------------------------------------------                      
                                                                                
define lr_param record                          
   succod    like datrligapol.succod            
  ,ramcod    like datrligapol.ramcod                                         
  ,aplnumdig like datrligapol.aplnumdig                                      
  ,itmnumdig like datrligapol.itmnumdig                                      
end record                                                                   
                                                                                
define lr_retorno record  
  atdsrvnum   like datrservapol.atdsrvnum ,
  atdsrvano   like datrservapol.atdsrvano , 
  sinvstnum   like ssamsin.sinvstnum      ,      
  sinvstano   like ssamsin.sinvstano      ,                                                    
  qtd         integer                     ,
  confirma    char(01)                    ,
  resultado   smallint                  	      
end record                                                                      
                                                                                
initialize lr_retorno.* to null                                                 
                                                                                                            
  let lr_retorno.qtd = 0
    
  if mr_param.beneficio      and                                                                              
     mr_param.clscod = "035" then
    
       open ccty39g00010 using lr_param.succod    ,                                
                               lr_param.ramcod    ,                                
                               lr_param.aplnumdig ,                                
                               lr_param.itmnumdig                                            
                                                            
       foreach ccty39g00010 into lr_retorno.atdsrvnum,
                                 lr_retorno.atdsrvano
                                                 
            
           #--------------------------------------------------------         
           # Recupera o Numero do Sinistro                                   
           #--------------------------------------------------------         
                                                                             
           call cty39g00_recupera_sinistro(lr_retorno.atdsrvnum,             
                                           lr_retorno.atdsrvano,             
                                           2)                                  
           returning lr_retorno.sinvstnum,                                  
                     lr_retorno.sinvstano
                     
                    
           #--------------------------------------------------------  
           # Soma Somente Se for o Mesmo Evento de Sinistro           
           #--------------------------------------------------------  
                                                                      
           if (lr_retorno.sinvstnum = mr_param.sinvstnum  and         
           	   lr_retorno.sinvstano = mr_param.sinvstano) then                 
                     
              call cty39g00_consiste_servico(lr_retorno.atdsrvnum, 
                                             lr_retorno.atdsrvano) 
              returning lr_retorno.resultado                       
              
              if lr_retorno.resultado = 1 then 
                 let lr_retorno.qtd = lr_retorno.qtd + 1 
              end if
           
           end if 
                                                              
       end foreach                                                         
        
       
       if lr_retorno.qtd > 0 then 
       	
       	   call cts08g01("A","N",                       
       	                 "ABERTURA NEGADA",                            
       	                 "JA EXISTE UMA SOLICITACAO ",  
       	                 "DE CARRO RESERVA MOTIVO 21 ",                            
       	                 "PARA ESTA APOLICE")                            
       	   returning lr_retorno.confirma  
       	   
       	   return false              
       
       end if	                                         
  
   end if
   
   return true                                                                              
                                                                                
end function 

#----------------------------------------#                                                                                                                   
function cty39g00_valida_SDF(lr_param)                                                   
#----------------------------------------#                                                
                                                                                          
 define lr_param record                                                                   
    succod    like datrligapol.succod                                                     
   ,ramcod    like datrligapol.ramcod                                                     
   ,aplnumdig like datrligapol.aplnumdig                                                  
   ,itmnumdig like datrligapol.itmnumdig                                                  
 end record                                                                               
                                                                                          
 define lr_retorno record                                                                 
    atdsrvnum   like datrservapol.atdsrvnum                                               
   ,atdsrvano   like datrservapol.atdsrvano                                               
   ,atddat      like datmservico.atddat                                                   
   ,atddatprg   like datmservico.atddatprg  
   ,sinvstnum   like ssamsin.sinvstnum    
   ,sinvstano   like ssamsin.sinvstano                                                                                                                   
   ,qtd         integer                                                                                                                               
   ,resultado   smallint
   ,confirma    char(1)                                                                    
 end record                                                                               
                                                                                          
                                                                                          
 if m_prepare is null or                                                                  
    m_prepare <> true then                                                                
    call cty39g00_prepare()                                                               
 end if                                                                                   
                                                                                          
                                                                                                                                                                    
 initialize lr_retorno.* to null  
 
    let lr_retorno.qtd = 0                                                        
                                                           
    if lr_param.aplnumdig is not null then                                                
                                                                                          
      #--------------------------------------------------------                           
      # Recupera os Servicos Feito Pela Apolice                                           
      #--------------------------------------------------------                           
                                                                                          
       open ccty39g00003 using lr_param.succod                                            
                              ,lr_param.ramcod                                            
                              ,lr_param.aplnumdig                                         
                              ,lr_param.itmnumdig                                         
                                                                                          
       foreach ccty39g00003 into lr_retorno.atddat                                        
       	                        ,lr_retorno.atddatprg                                     
       	                        ,lr_retorno.atdsrvnum                                     
       	                        ,lr_retorno.atdsrvano                                     
                                                                                          
                                                                                          
        #--------------------------------------------------------     
        # Recupera o Numero do Sinistro                               
        #--------------------------------------------------------     
                                                                      
        call cty39g00_recupera_sinistro(lr_retorno.atdsrvnum,         
                                        lr_retorno.atdsrvano,         
                                        1)                            
        returning lr_retorno.sinvstnum,                               
                  lr_retorno.sinvstano                                
        
    
        #-------------------------------------------------------- 
        # Soma Somente Se for o Mesmo Evento de Sinistro                  
        #-------------------------------------------------------- 
        
        if (lr_retorno.sinvstnum = mr_param.sinvstnum  and                                                                                    
        	  lr_retorno.sinvstano = mr_param.sinvstano) then   
        
            #--------------------------------------------------------                         
            # Consiste o Servico                                                              
            #--------------------------------------------------------                         
                                                                                              
            call cty39g00_consiste_servico(lr_retorno.atdsrvnum,                              
                                           lr_retorno.atdsrvano)                              
            returning lr_retorno.resultado                                                    
                                                                                          
            if lr_retorno.resultado = 1 then                                                  
            	 let lr_retorno.qtd = lr_retorno.qtd + 1                                                                                                                                                                        
            end if  
        
         end if                                                                          
                                                                                          
       end foreach                                                                        
                                                                                          
       close ccty39g00003                                                                 
    end if 
    
    if lr_retorno.qtd > 0 then                                 
    	                                                         
    	   call cts08g01("A","N",                                
    	                 "ABERTURA NEGADA ",                      
    	                 "JA EXISTE UMA SOLICITACAO ",           
    	                 "DE TAXI CLAUSULA 26D ",          
    	                 "PARA ESTA APOLICE")                    
    	   returning lr_retorno.confirma                         
    	                                                         
    	   return false                                          
                                                               
    end if	                                                   
    
    return true                                                                               
                                                                                          
                                                                                          
end function 

#--------------------------------------------------------#                                                                                                                         
 function cty39g00_acessa()                                                                          
#--------------------------------------------------------#                                            
                                                                                                      
                                                                                           
define lr_retorno record                                                                                                                                                            
  resultado  integer                                                                                  
end record                                                                                            
                                                                                                      
   initialize lr_retorno.*, mr_param.* to null                                                        
                                                                                                                                     
   #--------------------------------------------------------                                          
   # Verifica se Empresa e Ramo tem Acesso                                                            
   #--------------------------------------------------------                                          
                                                                                                      
   if g_documento.ciaempcod = 1     and
   	  g_documento.ramcod    = 531   then                                               
   	                                                                                                  
                                                                                                      
      #--------------------------------------------------------                                       
      # Verifica se Clausulas tem Acesso                                                              
      #--------------------------------------------------------                                       
                                                                                                      
      if cty39g00_valida_clausula(g_documento.succod    ,                                             
                                  g_documento.aplnumdig ,                                             
                                  g_documento.itmnumdig ,                                             
                                  g_funapol.dctnumseq   ) then                                        
                                                                                                      
                                                                                                      
         #--------------------------------------------------------
         # Verifica se Tem Beneficio                           
         #--------------------------------------------------------
         
         call faemc935_beneficio(g_documento.succod    , 
                                 g_documento.aplnumdig , 
                                 g_documento.itmnumdig , 
                                 g_funapol.dctnumseq   )
         returning mr_param.beneficio
         
         if mr_param.beneficio      and          
            mr_param.clscod = "035" then         
            
                   
            #--------------------------------------------------------                                    
            # Recupera o Numero do Aviso de Sinistro                                                     
            #--------------------------------------------------------                                    
                                                                                                         
            call cty39g00_seleciona_sinistro(g_documento.succod    ,                                     
                                             g_documento.aplnumdig ,                                     
                                             g_documento.itmnumdig )                                     
            returning mr_param.sinvstnum,                                                                
                      mr_param.sinvstano,                                                                
                      lr_retorno.resultado                                                               
                                                                                                         
            if lr_retorno.resultado <> 0 then                                                            
               return false                                                                              
            end if
            
        end if	                                                                                                                                                                                                                                                                                                                                                   	                                                                                              
      
      end if                                                                                          
                                                                                                      
   end if	                                                                                            
                                                                                                      
   return true                                                                                        
                                                                                                      
end function   


#--------------------------------------------------------#                                                                         
 function cty39g00_verifica_assunto_taxi()                         
#--------------------------------------------------------#                     
                                                                                                                     
define lr_retorno record                                             
  cont      smallint,                                           
  chave     char(20)                                            
end record                                                           
                                                                                                                                              
                                                                     
initialize lr_retorno.* to null                                      
                                                                     
let lr_retorno.chave = "cty39g00_ass_taxi"                                                                     

                                                                                       
    #--------------------------------------------------------        
    # Valida Assunto Vai Taxi                         
    #--------------------------------------------------------  
    
    open ccty39g00011 using lr_retorno.chave,
                            g_documento.c24astcod     
    whenever error continue                    
    fetch ccty39g00011 into  lr_retorno.cont 
    whenever error stop                        
          
                                                                     
    if lr_retorno.cont  > 0 then
    	 return true                                  
    end if
                                                                                                                                           
    return false                                
                                                                     
                                                                     
end function   

#--------------------------------------------------------#                                                                         
 function cty39g00_acessa_taxi()                         
#--------------------------------------------------------#                     
                                                                                                                            
define lr_retorno record                                             
  flag      char(01),                                           
  chave     char(20)                                            
end record
                                                                                                                                                                                                                                                                           
initialize lr_retorno.* to null                                      
                                                                     
let lr_retorno.chave = "cty39g00_taxi"                                                                     

                                                                                       
    #--------------------------------------------------------        
    # Valida se Acessa o Processo Vai de Taxi                        
    #--------------------------------------------------------        
                                                                     
                                                                     
    open ccty39g00001  using  lr_retorno.chave         
    whenever error continue                       
    fetch ccty39g00001 into  lr_retorno.flag      
    whenever error stop                           
                                                                   
    if lr_retorno.flag  = "S" then
    	 return true                                  
    end if
                                                                                                                                   
    return false                                
                                                                     
                                                                     
end function

#--------------------------------------------------------#                                                                         
 function cty39g00_vai_taxi()                         
#--------------------------------------------------------#                     
                                                                                                                            
define lr_retorno record                                             
  ctgtrfcod   like abbmcasco.ctgtrfcod                                           
end record   

if m_prepare is null or         
   m_prepare <> true then       
   call cty39g00_prepare()      
end if 

                                                                                                                                                                                                                                                                         
initialize lr_retorno.* to null  

     #--------------------------------------------------------   
     # Recupera a Categoria Tarifaria da Apolice                                   
     #--------------------------------------------------------   
     
     let lr_retorno.ctgtrfcod = cty39g00_recupera_categoria()
                                    
     #--------------------------------------------------------
     # Faz Todas a Validacoes do Vai de Taxi                                                                             
     #--------------------------------------------------------     
  
     if cty39g00_acessa_taxi()                                 and
     	  cty39g00_verifica_assunto_taxi()                       and
     	  cty39g00_valida_clausula_taxi()                        and 
     	  cty39g00_verifica_categoria_taxi(lr_retorno.ctgtrfcod) then
     	 
     
     	  #--------------------------------------------------------
     	  # Integra com o Sinistro              
     	  #--------------------------------------------------------
     	  
     	  call cty39g00_comunica_sinistro_taxi()  
        	
     	  #-------------------------------------------------------- 
     	  # Dispara o E-mail do Vai de Taxi                                  
     	  #-------------------------------------------------------- 
     	  
     	  call cty39g00_dispara_email()
     
     	
     end if	                         
                                                                     
end function

#---------------------------------------------#                                                                                                                     
function cty39g00_comunica_sinistro_taxi()                                     
#---------------------------------------------#                           
                                                                          
                                                                          
define lr_retorno record                                                  
  sqlcode    integer	 ,                                                  
  msg        char(50)  ,
  tipo       char(01)               	                                      
end record                                                                
                                                                          
                                                                          
   initialize lr_retorno.* to null 
   
   
   if g_documento.c24astcod = "750" or
   	  g_documento.c24astcod = "751" then                                   
       	                                                                  
       	  
       	  case g_documento.c24astcod 
       	  	when "750"
       	        let lr_retorno.tipo = "C" 
       	        display "Integracao Carro Reserva Efetuada com Sucesso!!!"
       	    when "751"
       	  			let lr_retorno.tipo = "F"       
       	  			display "Integracao Desconto na Franquia Efetuada com Sucesso!!!" 	  
       	  end case 
       	                
       	                                                                  
       	  call sinitfopc (""                    ,                         
       	                  ""                    ,                         
                          g_documento.succod    ,                         
                          g_documento.aplnumdig ,                         
                          g_documento.itmnumdig ,                         
                          ""                    ,                         
                          ""                    ,                         
                          today                 ,                         
                          ""                    ,                         
                          lr_retorno.tipo       ,       
                          g_issk.funmat         ,                         
                          "S"                   )                         
          returning lr_retorno.sqlcode,                                   
                    lr_retorno.msg                                        
                
                                                                          
                                                             
   end if                                                                 
                                                                          
                                                                          
end function  

#--------------------------------------------------------#                                                                         
 function cty39g00_verifica_clausula_taxi(lr_param)                         
#--------------------------------------------------------#                     
                                                                     
define lr_param record     
	clscod    like abbmclaus.clscod                                                                 
end record                                                           
                                                                     
define lr_retorno record                                             
  clscod    like abbmclaus.clscod,                                             
  chave     char(20)                                            
end record                                                           
                                                                                                                                              
                                                                     
initialize lr_retorno.* to null                                      
                                                                     
let lr_retorno.chave = "cty39g00_claus_tax"                                                                     

                                                                                       
    #--------------------------------------------------------        
    # Valida Clausula Taxi                        
    #--------------------------------------------------------        
                                                                
                                                                     
    open ccty39g00001  using  lr_retorno.chave                         
    foreach ccty39g00001 into lr_retorno.clscod            
                                                                 
        if lr_param.clscod  = lr_retorno.clscod then
        	 return true                                  
        end if
                                                                     
    end foreach                                                      
                                                                     
    return false                                
                                                                     
                                                                     
end function 

#--------------------------------------------------------#                                                                         
 function cty39g00_valida_clausula_taxi()                         
#--------------------------------------------------------#                     
                                                                                           
                                                                     
define lr_retorno record                                             
  clscod    like abbmclaus.clscod                                       
end record                                                           
                                                                                                                                              
                                                                     
initialize lr_retorno.* to null 

    if m_prepare is null or         
       m_prepare <> true then       
       call cty39g00_prepare()      
    end if 
                                                                                                                                                                                         
    #--------------------------------------------------------        
    # Recupera Clausulas                       
    #--------------------------------------------------------        
                                                                     
                                                                     
    open ccty39g00002  using g_documento.succod    ,    
                             g_documento.aplnumdig ,
                             g_documento.itmnumdig ,
                             g_funapol.dctnumseq
                        
    foreach ccty39g00002 into lr_retorno.clscod   
                                                                       
        #-------------------------------------------------------- 
        # Valida Clausula Taxi                                      
        #-------------------------------------------------------- 
        
     
        if cty39g00_verifica_clausula_taxi(lr_retorno.clscod) then
          return true
    	  end if       	
               
                                                                     
    end foreach                                                      
                                                                           
    return false                                
                                                                     
                                                                     
end function 

#--------------------------------------------------------#                                                                         
 function cty39g00_verifica_categoria_taxi(lr_param)                         
#--------------------------------------------------------#                     
                                                                     
define lr_param record     
	ctgtrfcod like abbmcasco.ctgtrfcod                                                                  
end record                                                           
                                                                     
define lr_retorno record                                             
  ctgtrfcod like abbmcasco.ctgtrfcod  ,                                            
  chave     char(20)                                            
end record                                                           
                                                                                                                                              
                                                                     
initialize lr_retorno.* to null                                      
                                                                     
let lr_retorno.chave = "cty39g00_claus_cat"                                                                     

                                                                                       
    #--------------------------------------------------------        
    # Valida Categoria Tarifaria Taxi                        
    #--------------------------------------------------------        
                                                                     
                                                                     
    open ccty39g00001  using  lr_retorno.chave                         
    foreach ccty39g00001 into lr_retorno.ctgtrfcod            
                                                                     
        if lr_param.ctgtrfcod  = lr_retorno.ctgtrfcod then
        	 return true                                  
        end if
                                                                     
    end foreach                                                      
                                                                       
    return false                                
                                                                     
                                                                     
end function     

#--------------------------------------------------------#                                                                         
 function cty39g00_recupera_dados_taxi()                         
#--------------------------------------------------------#                     
                                                                     
                                                     
define lr_retorno record                                             
   segnumdig    like gsakseg.segnumdig  ,
   cgccpfnum    like gsakseg.cgccpfnum  ,
   cgcord       like gsakseg.cgcord     ,
   cgccpfdig    like gsakseg.cgccpfdig  ,
   pestip       like gsakseg.pestip     , 
   segnom       like gsakseg.segnom     ,
   endcid       like gsakend.endcid     ,
   dddnum       like gsaktel.dddnum     ,
   telnum       like gsaktel.telnum     ,
   msg1         char(50)                ,
   msg2         char(50)                ,
   msg3         char(50)                ,
   msg4         char(50)                ,
   msg5         char(100)               ,
   msg          char(500)    
end record                                                           
                                                                                                                                              
                                                                     
initialize lr_retorno.* to null                                      
                                                                     
    #--------------------------------------------------------        
    # Recupera o Numero do Segurado                      
    #--------------------------------------------------------        
                                                                                                                                         
    open ccty39g00012  using g_documento.succod   ,     
                             g_documento.aplnumdig,
                             g_documento.succod   ,   
                             g_documento.aplnumdig 
           
    whenever error continue                       
    fetch ccty39g00012 into  lr_retorno.segnumdig     
    whenever error stop    
    
    
    #--------------------------------------------------------  
    # Recupera o CPF/CNPJ e o Nome                  
    #--------------------------------------------------------  
                                                               
    open ccty39g00013  using lr_retorno.segnumdig                                                
    whenever error continue                                    
    fetch ccty39g00013 into  lr_retorno.cgccpfnum,
                             lr_retorno.cgcord   ,
                             lr_retorno.cgccpfdig, 
                             lr_retorno.pestip   ,                             
                             lr_retorno.segnom   
    whenever error stop 
    
    let lr_retorno.msg1 = "Nome do Segurado:", lr_retorno.segnom clipped  
    
    if lr_retorno.pestip = "F" then
        let lr_retorno.msg2 = "CPF:", lr_retorno.cgccpfnum ,"-", lr_retorno.cgccpfdig     
    else
    	  let lr_retorno.msg2 = "CNPJ:", lr_retorno.cgccpfnum,"-",lr_retorno.cgcord,"-", lr_retorno.cgccpfdig   
    end if	   
    
    #--------------------------------------------------------      
    # Recupera a Cidade                                 
    #--------------------------------------------------------      
                                                                   
    open ccty39g00014  using lr_retorno.segnumdig                  
    whenever error continue                                        
    fetch ccty39g00014 into  lr_retorno.endcid                                                      
    whenever error stop   
    
    let lr_retorno.msg3 = "Cidade:", lr_retorno.endcid clipped   
                          
    #--------------------------------------------------------      
    # Recupera o Telefone                                
    #--------------------------------------------------------      
                                                                   
    open ccty39g00015  using lr_retorno.segnumdig                  
    whenever error continue                                        
    fetch ccty39g00015 into  lr_retorno.dddnum,
                             lr_retorno.telnum                                                      
    whenever error stop   
    
    let lr_retorno.msg4 = "Telefone:", lr_retorno.dddnum, "-", lr_retorno.telnum   
    
    let lr_retorno.msg5 = "Apolice: ", g_documento.succod, "-", g_documento.ramcod, "-", 
                                       g_documento.aplnumdig, "-", g_documento.itmnumdig   

      
    
    let lr_retorno.msg =  lr_retorno.msg5 clipped, "<br>",
                          lr_retorno.msg1 clipped, "<br>",
                          lr_retorno.msg2 clipped, "<br>",
                          lr_retorno.msg3 clipped, "<br>",                                   
                          lr_retorno.msg4 clipped
                          
    return lr_retorno.msg                                                                                          
                                                                     
end function  

#========================================================================
function cty39g00_dispara_email()
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

   
    let lr_mail.assunto   = cty39g00_recupera_assuntos_taxi()
    let lr_mail.mensagem  = cty39g00_recupera_dados_taxi()
    
    
    let lr_mail.de        = "ct24hs.email@portoseguro.com.br"
    let lr_mail.para      = cty39g00_recupera_email()
    let lr_mail.cc        = ""
    let lr_mail.cco       = ""
    let lr_mail.id_remetente = "CT24HS"
    let lr_mail.tipo = "html"

    #-----------------------------------------------
    # Dispara o E-mail
    #-----------------------------------------------

     call figrc009_mail_send1 (lr_mail.*)
     returning l_erro
              ,msg_erro

#========================================================================
end function
#========================================================================

#========================================================================                    
 function cty39g00_recupera_email()                                                                                                     
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
                                                                                         
let lr_retorno.cponom = "cty39g00_email"                                                 
                                                                                         
  open ccty39g00001 using  lr_retorno.cponom                                           
                                                                                         
  foreach ccty39g00001 into lr_retorno.cpodes                                          
                                                                                         
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

#--------------------------------------------------------#                                                                         
 function cty39g00_recupera_assuntos_taxi()                         
#--------------------------------------------------------#                     
                                                                     
                                                     
define lr_retorno record                                             
   c24astdes    like datkassunto.c24astdes, 
   msg          char(100)    
end record                                                           
                                                                                                                                              
                                                                     
initialize lr_retorno.* to null                                      
                                                                     
    #--------------------------------------------------------        
    # Recupera a Descrição do Assunto                 
    #--------------------------------------------------------        
                                                                                                                                         
    open ccty39g00016  using g_documento.c24astcod            
    whenever error continue                       
    fetch ccty39g00016 into  lr_retorno.c24astdes    
    whenever error stop    
    
    
    let lr_retorno.msg = g_documento.c24astcod, " - ", lr_retorno.c24astdes  clipped
                          
    return lr_retorno.msg                                                                                          
                                                                     
end function 

#--------------------------------------------------------#                                                                         
 function cty39g00_recupera_categoria()                         
#--------------------------------------------------------#                     
                                                                     
                                                  
define lr_retorno record                                             
  ctgtrfcod   like abbmcasco.ctgtrfcod                                                                                    
end record                                                           
                                                                                                                                              
                                                                     
initialize lr_retorno.* to null                                      
                                                                                                                                                                                                                                
    #-----------------------------------------------         
    # Recupera Categoria Tarifaria             
    #-----------------------------------------------         
                                                             
    open ccty39g00017  using g_documento.succod     ,     
                             g_documento.aplnumdig  ,     
                             g_documento.itmnumdig  ,     
                             g_funapol.dmtsitatu          
    whenever error continue                                  
    fetch ccty39g00017  into lr_retorno.ctgtrfcod                
    whenever error stop                                      
        
    return lr_retorno.ctgtrfcod                                                                  
                                                                     
end function
