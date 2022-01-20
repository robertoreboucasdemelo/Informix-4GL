#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Regras Siebel                                             #
# Modulo.........: cty44g00                                                  #
# Objetivo.......: Relatorio Auto Premium                                    #
# Analista Resp. : Carlos Ruiz                                               #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: R.Fornax                                                  #
# Liberacao      : 28/11/2015                                                #
#............................................................................#
#............................................................................#
#............................................................................#
                                                              
globals "/homedsa/projetos/geral/globals/glct.4gl"

globals                         
   define g_ismqconn smallint   
end globals                      

define mr_tela record  
   dt_ini    date     ,   
   dt_fnl    date     ,   
   tipo      char(01) ,   
   tipdes    char(10) ,
   obs       char(50)    
end record


define mr_retorno record  
  c24astcod     like datmligacao.c24astcod     ,   
  c24empcod     like datmligacao.c24empcod     ,
  c24funmat     like datmligacao.c24funmat     ,
  lignum        like datmligacao.lignum        ,
  atdsrvano     like datmligacao.atdsrvano     ,
  atdsrvnum     like datmligacao.atdsrvnum     ,
  ligdat        like datmligacao.ligdat        ,
  lighorinc     like datmligacao.lighorinc     ,
  c24soltipcod  like datmligacao.c24soltipcod  ,
  succod        like datrligapol.succod        ,
  ramcod        like datrligapol.ramcod        ,
  aplnumdig     like datrligapol.aplnumdig     ,
  itmnumdig     like datrligapol.itmnumdig     ,   
  segnumdig     like gsakseg.segnumdig         ,   
  cgccpfnum     like gsakseg.cgccpfnum         ,
  cgcord        like gsakseg.cgcord            ,
  cgccpfdig     like gsakseg.cgccpfdig         ,
  atdnum        like datratdlig.atdnum         ,
  c24soltipdes  like datksoltip.c24soltipdes   , 
  c24astdes     like datkassunto.c24astdes     ,
  atdetpdes     like datketapa.atdetpdes       ,
  prporg        like datrligprp.prporg         ,
  prpnumdig     like datrligprp.prpnumdig      ,  
  segdes        char(50)                       ,
  confirma      char(01)                       ,  
  path          char(200)                      ,
  arquivo       char(200)                      ,
  cont          integer 
end record

define m_prepare smallint
define m_acesso  smallint

#------------------------------------------------------#        
function  cty44g00_prepare()
#------------------------------------------------------#        

define l_sql  char(2000) 

  let l_sql = " select a.c24astcod ,            ", 
              "        a.c24empcod ,            ",
              "        a.c24funmat ,            ",
              "        a.lignum    ,            ",
              "        a.atdsrvano ,            ",
              "        a.atdsrvnum ,            ",
              "        a.ligdat    ,            ",
              "        a.lighorinc ,            ",
              "        a.c24soltipcod,          ",
              "        b.succod    ,            ",
              "        b.ramcod    ,            ",
              "        b.aplnumdig ,            ",
              "        b.itmnumdig              ",
              " from datmligacao a ,            ",
              "      datrligapol b              ", 
              " where a.lignum = b.lignum       ",     
              " and a.ligdat between ? and ?    ",
              " and a.c24astcod not in ('CON', 'ALT','CAN', 'RET') ", 
              " and a.ciaempcod = 1             ",
              " order by a.ligdat, a.lighorinc  "                                                               
   prepare pcty44g00001  from l_sql              
   declare ccty44g00001  cursor for pcty44g00001
   	
   let l_sql = " select segnumdig  ",            
               " from abbmdoc      ",
               " where succod  = ? ",
               " and aplnumdig = ? ",
               " and itmnumdig = ? ",
               " and dctnumseq = 1 "                                                                
   prepare pcty44g00002  from l_sql              
   declare ccty44g00002  cursor for pcty44g00002	
   
   
   let l_sql = " select cgccpfnum,    ",   
               "        cgcord   ,    ",
               "        cgccpfdig     ",       
               " from gsakseg         ",                
               " where segnumdig  = ? "                           	
   prepare pcty44g00003  from l_sql                 	
   declare ccty44g00003  cursor for pcty44g00003	  
   	
   let l_sql = " select count(*)      ",       
               " from apamconclisgm   ",                
               " where clisgmcod  = 2 ",  
               " and   cpjcpfnum  = ? ", 
               " and   cpjordnum  = ? ",
               " and   cpjcpfdig  = ? "                                      	
   prepare pcty44g00004  from l_sql                 	
   declare ccty44g00004  cursor for pcty44g00004	
   	
   
   let l_sql = " select atdnum       ",   
               " from datratdlig     ",                
               " where lignum  = ?   "                           	
   prepare pcty44g00005  from l_sql                 	
   declare ccty44g00005  cursor for pcty44g00005	
   	
   
   let l_sql = " select c24soltipdes       ",           	
               " from datksoltip           ",           	
               " where c24soltipcod  = ?   "            	
   prepare pcty44g00006  from l_sql               	
   declare ccty44g00006  cursor for pcty44g00006		
   	
   
   let l_sql = " select cpodes        "                
              ," from datkdominio     "                	
              ," where cponom =  ?    "                	
   prepare pcty44g00007  from l_sql                    	
   declare ccty44g00007  cursor for pcty44g00007	
   	
   let l_sql = "select segnumdig,  ",
               "       clalclcod   ",
               " from abbmdoc      ",
               " where succod  = ? ",
               " and aplnumdig = ? ",
               " and itmnumdig = ? ",
               " and dctnumseq = ? "
  prepare pcty44g00008  from l_sql                
  declare ccty44g00008  cursor for pcty44g00008  	
  	
  
  let l_sql = "select viginc,     ",            	
              "       vigfnl      ",            	
              " from abamapol     ",            	
              " where succod  = ? ",            	
              " and aplnumdig = ? "             	
  prepare pcty44g00009  from l_sql                	
  declare ccty44g00009  cursor for pcty44g00009	  
  	
  let l_sql = "select clscod        "
	 				   ," from abbmclaus      "
	           ," where succod    = ? "
	   				 ,"   and aplnumdig = ? "
	   				 ,"   and itmnumdig = ? "
	    	  	 ,"   and dctnumseq = ? "
	           ,"   and clscod in ('033','33R','034','035') "
	prepare pcty44g00010  from l_sql                
	declare ccty44g00010  cursor for pcty44g00010  
		
  let l_sql = "select nscdat,        ",
              "       segsex,        ",
              "       pestip,        ",
              "       cgccpfnum,     ",
              "       cgcord,        ",
              "       cgccpfdig      ",              
              " from gsakseg         ",
              " where segnumdig  = ? "
  prepare pcty44g00011  from l_sql                
  declare ccty44g00011  cursor for pcty44g00011	  
  	
  	
  let l_sql = "select vcl0kmflg,    "
	           ,"       vcluso        "
	 				   ," from abbmveic       "
	           ," where succod    = ? "
	   				 ,"   and aplnumdig = ? "
	   				 ,"   and itmnumdig = ? "
	    	  	 ,"   and dctnumseq = ? "
	prepare pcty44g00012  from l_sql                
	declare ccty44g00012  cursor for pcty44g00012  
		
		
	let l_sql = "select imsvlr,       "
             ,"       ctgtrfcod     "
	 				   ," from abbmcasco      "
	           ," where succod    = ? "
	   				 ,"   and aplnumdig = ? "
	   				 ,"   and itmnumdig = ? "
	    	  	 ,"   and dctnumseq = ? "
	prepare pcty44g00013  from l_sql                
	declare ccty44g00013  cursor for pcty44g00013	  
		
	let l_sql = "select rspdat           "
	 				   ," from abbmquestionario  "
	           ," where succod    = ?    "
	   				 ,"   and aplnumdig = ?    "
	   				 ,"   and itmnumdig = ?    "
	    	  	 ,"   and dctnumseq = ?    "
	    	  	 ,"   and qstcod    = 2    "
	prepare pcty44g00014  from l_sql                
	declare ccty44g00014  cursor for pcty44g00014	  

  let l_sql = "select rspcod           "
	 				   ," from abbmquestionario  "
	           ," where succod    = ?    "
	   				 ,"   and aplnumdig = ?    "
	   				 ,"   and itmnumdig = ?    "
	    	  	 ,"   and dctnumseq = ?    "
	    	  	 ,"   and qstcod    = 120  "
	prepare pcty44g00015  from l_sql                
  declare ccty44g00015  cursor for pcty44g00015  
  	
  let l_sql = " select dctsgmcod           "
             ," from abbmapldctsgm         "
             ," where succod    = ?        "
             ," and   aplnumdig = ?        "
             ," and   itmnumdig = ?        "
             ," and   dctnumseq = ?        "
  prepare pcty44g00016 from l_sql
  declare ccty44g00016 cursor for pcty44g00016
  	
  let l_sql = " select cpodes          "           	
            , " from datkdominio       "           	
            , " where cponom =  ?      "           	
            , " and   cpocod =  ?      "           	
  prepare pcty44g00017 from l_sql              
  declare ccty44g00017 cursor for pcty44g00017
  	
  let l_sql = " select b.atdetpdes              "      	
            , " from datmservico a,             "   
            , "      datketapa b                "   	
            , " where a.atdetpcod = b.atdetpcod " 
            , " and   a.atdsrvnum =  ?          "      		 	
            , " and   a.atdsrvano =  ?          "                  	
  prepare pcty44g00018 from l_sql              	    	
  declare ccty44g00018 cursor for pcty44g00018 
  	
  
  let l_sql = " select c24astdes       "        
            , " from datkassunto       "        
            , " where c24astcod =  ?   "              
  prepare pcty44g00019 from l_sql               
  declare ccty44g00019 cursor for pcty44g00019		
  	
  
  let l_sql = " select a.c24astcod ,            ", 
              "        a.c24empcod ,            ",
              "        a.c24funmat ,            ",
              "        a.lignum    ,            ",
              "        a.atdsrvano ,            ",
              "        a.atdsrvnum ,            ",
              "        a.ligdat    ,            ",
              "        a.lighorinc ,            ",
              "        a.c24soltipcod,          ",
              "        b.prporg    ,            ",
              "        b.prpnumdig              ",
              " from datmligacao a ,            ",
              "      datrligprp b               ", 
              " where a.lignum = b.lignum       ",     
              " and a.ligdat between ? and ?    ",
              " and a.c24astcod not in ('CON', 'ALT','CAN', 'RET') ", 
              " and a.ciaempcod = 1             ",
              " order by a.ligdat, a.lighorinc  "                                                               
   prepare pcty44g00020  from l_sql              
   declare ccty44g00020  cursor for pcty44g00020	
   	
   
   
   let l_sql = " select etpnumdig     ",         
                 " from apamcapa      ",          
                " where prporgpcp = ? ",     
                "   and prpnumpcp = ? "      
   prepare pcty44g00021  from l_sql               
   declare ccty44g00021  cursor for pcty44g00021	
   	
   
   let l_sql =  "  select clalclcod     "
               ,"  from  apbmitem       "
               ,"  where prporgpcp =  ? "
               ,"  and   prpnumpcp =  ? "
               ,"  and   prporgidv =  ? "
               ,"  and   prpnumidv =  ? "
   prepare pcty44g00022  from l_sql               
   declare ccty44g00022  cursor for pcty44g00022		
   	
   	
   let l_sql =  " select cbtcod    ,    "
               ,"        ctgtrfcod ,    "
               ,"        clcdat         "
               ," from apbmcasco        "
               ," where  prporgpcp =  ? "
               ,"  and   prpnumpcp =  ? "
               ,"  and   prporgidv =  ? "
               ,"  and   prpnumidv =  ? "
   prepare pcty44g00023  from l_sql               
   declare ccty44g00023  cursor for pcty44g00023	
   	
   let l_sql =  " select vcluso      "                 	
    				   ," from apbmveic      "                
               ," where  prporgpcp =  ? "              	
      				 ,"  and   prpnumpcp =  ? "             	
      				 ,"  and   prporgidv =  ? "             	
       	  	   ,"  and   prpnumidv =  ? "               	
   prepare pcty44g00024  from l_sql                     	
   declare ccty44g00024  cursor for pcty44g00024	   
   	
  
   let l_sql = " select rspdat          "
    				  ," from apbmquestionario  "
              ," where  prporgpcp =  ?  "
      				,"  and   prpnumpcp =  ?  "
      				,"  and   prporgidv =  ?  "
       	  	  ,"  and   prpnumidv =  ?  "
       	  	  ,"   and qstcod    = 2    "
   prepare pcty44g00025  from l_sql               
   declare ccty44g00025  cursor for pcty44g00025	
   
   let l_sql = "select rspcod           "
    				  ," from apbmquestionario  "
              ," where  prporgpcp =  ?  "
      				,"  and   prpnumpcp =  ?  "
      				,"  and   prporgidv =  ?  "
       	  	  ,"  and   prpnumidv =  ?  "
       	  	  ,"   and qstcod    = 120  "
   prepare pcty44g00026  from l_sql               
   declare ccty44g00026  cursor for pcty44g00026
   	
   
   let l_sql = " select dctsgmcod      "
              ," from apbmprpdctsgm    "
              ," where prporgpcp = ?   "
              ," and   prpnumpcp = ?   "
   prepare pcty44g00027  from l_sql               
   declare ccty44g00027  cursor for pcty44g00027 
   	
   	                         
   let l_sql = " select viginc       ",                      
               " from apamcapa       ",                          	
               " where prporgpcp = ? ",                          	
               "   and prpnumpcp = ? "                           	              	                                                                  	
   prepare pcty44g00028  from l_sql                  	
   declare ccty44g00028  cursor for pcty44g00028     	
   	
   	
   
   	 
   let m_prepare = true    
  

end function 

#------------------------------------------------------#                      
 function cty44g00()                                                          
#------------------------------------------------------#                      
                                                                              
                                                                                                                                                                                                                          
                                                                              
   open window cty44g00 at 6,2 with form "cty44g00"
   attribute(form line 1)                           
                                                                                      
   call cty44g00_input()                                               
                                                                                                                                                            
   close window cty44g00                                                      
                                                                              
   let int_flag = false                                                       
                                                                              
 end function                                                                 
                                                                              
#------------------------------------------------------#                                                
function cty44g00_input()                                                                              
#------------------------------------------------------#                                               
                                                                                                       
   initialize mr_tela.*, mr_retorno.* to null                                                   
                                                                                                       
   let mr_tela.obs = "                          (F17)Abandona"             
                                                                                                                                                                                                             
   let int_flag = false

   input by name   mr_tela.dt_ini
                 , mr_tela.dt_fnl
                 , mr_tela.tipo  without defaults
    
   
      
   #---------------------------------------------
    before field dt_ini
   #---------------------------------------------
   			  
   				 let mr_tela.dt_ini = today
           let mr_tela.dt_fnl = today
           
           display by name mr_tela.dt_ini  attribute (reverse)
           display by name mr_tela.obs
            
            
   #---------------------------------------------
    after  field dt_ini
   #--------------------------------------------- 	
           display by name mr_tela.dt_ini


           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
                 next field dt_ini
           end if

           if mr_tela.dt_ini   is  null   then
              error "Por Favor Informe uma Data!"
              next field dt_ini 
           end if
           
       
    
   #--------------------------------------------- 
    before field dt_fnl
   #---------------------------------------------
       display by name mr_tela.dt_fnl   attribute (reverse)

   #--------------------------------------------- 
    after  field dt_fnl
   #--------------------------------------------- 	
       display by name mr_tela.dt_fnl


       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
             next field dt_ini
       end if

       if mr_tela.dt_fnl   is  null   then
          error "Por Favor Informe uma Data!"
          next field dt_fnl 
       end if
       
       if mr_tela.dt_ini > mr_tela.dt_fnl then
          error "Data Inicial nao pode ser Maior que a Final!"  
          next field dt_fnl                    
       end if
           
     
      #---------------------------------------------
       before field tipo
      #---------------------------------------------
				   display by name mr_tela.tipo attribute (reverse)
   

      #---------------------------------------------
       after field tipo
      #---------------------------------------------
      
          if mr_tela.tipo   is  null   then       
             error "Por Favor Informe A-Apolice ou P-Proposta!"    
             next field tipo                      
        	end if 
        	
        	if mr_tela.tipo <> "A" and 
        		 mr_tela.tipo <> "P" then                        
        	   error "Por Favor Informe A-Apolice ou P-Proposta!"    
        	   next field tipo                                       
        	end if 
        	
        	case mr_tela.tipo      
        		when "A"
        			 let  mr_tela.tipdes = "POLICE"                                           
        	  when "P"
        	  	 let  mr_tela.tipdes = "ROPOSTA"                                     
          end case 
          
          display by name mr_tela.tipo    
          display by name mr_tela.tipdes 
          
          
          let mr_retorno.confirma =                                                         
          cts08g01("C","S","","DESEJA GERAR","O RELATORIO?","")          
          
          if mr_retorno.confirma = "S" then         
             
             case mr_tela.tipo
             	 when "A"
                   call cty44g00_carrega_dados_apolice()
               when "P"
               	   call cty44g00_carrega_dados_proposta()   
             
             end case  	              
             
             next field tipo
          else
             next field tipo
          end if
             
                                                        
                                                                                                       
     on key (interrupt)        
         exit input 
         	
                                                                      
                                                                                                       
   end input                                                                                           
                                                                                                       
end function




#------------------------------------------------------#   
function cty44g00_carrega_dados_apolice()                            
#------------------------------------------------------# 

define lr_retorno record
  nscdat      like gsakseg.nscdat          ,
  segsex      like gsakseg.segsex          ,
  pestip      like gsakseg.pestip          ,
  viginc      like abamapol.viginc         ,
  clscod      like abbmclaus.clscod        ,
  perfil      smallint                     ,
  dt_cal      date                         ,
  vcl0kmflg   like abbmveic.vcl0kmflg      ,
  imsvlr      like abbmcasco.imsvlr        ,
  vcluso      like abbmveic.vcluso         ,
  rspdat      like abbmquestionario.rspdat ,
  rspcod      like abbmquestionario.rspcod ,
  ctgtrfcod   like abbmcasco.ctgtrfcod     ,
  clalclcod   like abbmdoc.clalclcod       ,
  dctsgmcod   like abbmapldctsgm.dctsgmcod ,  
  clisgmcod   like apamconclisgm.clisgmcod ,
  cgccpfnum   like gsakseg.cgccpfnum       , 
  cgcord      like gsakseg.cgcord          , 
  cgccpfdig   like gsakseg.cgccpfdig         
end record



    initialize lr_retorno.*, g_funapol.* to null

    call cty44g00_prepare()
    
    call cty44g00_recupera_diretorio()
    call cty44g00_recupera_diretorio2()
    
    let mr_retorno.arquivo  = mr_retorno.path clipped, "/PremiumApolice.xls"
    display "mr_retorno.arquivo ", mr_retorno.arquivo
    start report cty44g00_report_apolice to mr_retorno.arquivo
       
    open ccty44g00001 using mr_tela.dt_ini,
                            mr_tela.dt_fnl                                      
                                                                                     
    foreach ccty44g00001 into mr_retorno.c24astcod    ,   
    	                        mr_retorno.c24empcod    ,   
    	                        mr_retorno.c24funmat    ,   
    	                        mr_retorno.lignum       ,   
    	                        mr_retorno.atdsrvano    ,   
    	                        mr_retorno.atdsrvnum    ,   
    	                        mr_retorno.ligdat       ,   
    	                        mr_retorno.lighorinc    ,   
    	                        mr_retorno.c24soltipcod , 
    	                        mr_retorno.succod       ,   
    	                        mr_retorno.ramcod       ,   
    	                        mr_retorno.aplnumdig    ,   
    	                        mr_retorno.itmnumdig     
    	    

    	    
    	    message "Gerando a Data ...", mr_retorno.ligdat 
    	    
    	    if not cty44g00_recupera_segurado() then                                                                                      
             continue foreach                                     
          end if
          
          if not cty44g00_recupera_cgccpf() then  
             continue foreach  
          end if 
          
          if not cty44g00_recupera_segurado_premium() then  
             continue foreach                    
          end if
          
          call cty44g00_recupera_atendimento()
          call cty44g00_recupera_tipo_solicitante()
          call cty44g00_recupera_assunto()
          call cty44g00_recupera_servico()
          
          #-----------------------------------------------------------
          # Recupera os Dados do Segurado
          #-----------------------------------------------------------
          
          call cty44g00_recupera_dados_apolice(mr_retorno.succod   ,
                                               mr_retorno.aplnumdig,
                                               mr_retorno.itmnumdig)
          returning lr_retorno.nscdat    ,
                    lr_retorno.segsex    ,
                    lr_retorno.pestip    ,
                    lr_retorno.viginc    ,
                    lr_retorno.clscod    ,
                    lr_retorno.dt_cal    ,
                    lr_retorno.vcl0kmflg ,
                    lr_retorno.imsvlr    ,
                    lr_retorno.vcluso    ,
                    lr_retorno.rspdat    ,
                    lr_retorno.rspcod    ,
                    lr_retorno.ctgtrfcod ,
                    lr_retorno.clalclcod ,
                    lr_retorno.cgccpfnum ,
                    lr_retorno.cgcord    ,
                    lr_retorno.cgccpfdig
                    
          
          
          if m_acesso then
          
              
       
              #----------------------------------------------------------- 
              # Recupera o Segmento Auto do Segurado                              
              #----------------------------------------------------------- 
              
              call cty44g00_recupera_segmento(mr_retorno.succod    , 
                                              mr_retorno.aplnumdig ,
                                              mr_retorno.itmnumdig ,
                                              g_funapol.dctnumseq)
              returning lr_retorno.perfil ,
                        lr_retorno.dctsgmcod  
                   
              
              if lr_retorno.perfil is null then
              
                  
                  #----------------------------------------------------------- 
                  # Recupera o Segmento Central do Segurado                        
                  #----------------------------------------------------------- 
                  
                  call cty44g00_calcula_perfil(lr_retorno.nscdat    ,
                                               lr_retorno.segsex    ,
                                               lr_retorno.pestip    ,
                                               lr_retorno.viginc    ,
                                               lr_retorno.vcluso    ,
                                               lr_retorno.rspdat    ,
                                               lr_retorno.rspcod    ,
                                               lr_retorno.ctgtrfcod ,
                                               lr_retorno.imsvlr    )
                  returning lr_retorno.perfil
                  
                
          
              end if   
              
          end if
          
          call cty44g00_descricao_segmento(lr_retorno.perfil)
          returning mr_retorno.segdes 
     
          
          output to report cty44g00_report_apolice()
          
                                                                             
    end foreach
    
    finish report cty44g00_report_apolice
    
    call cty44g00_dispara_email()
    
    error "Arquivo Gerado com Sucesso" sleep 3                                                                 


end function

#------------------------------------------------------#   
function cty44g00_carrega_dados_proposta()                            
#------------------------------------------------------# 

define lr_retorno record
  nscdat      like gsakseg.nscdat          ,
  segsex      like gsakseg.segsex          ,
  pestip      like gsakseg.pestip          ,
  viginc      like abamapol.viginc         ,
  clscod      like abbmclaus.clscod        ,
  perfil      smallint                     ,
  dt_cal      date                         ,
  vcl0kmflg   like abbmveic.vcl0kmflg      ,
  imsvlr      like abbmcasco.imsvlr        ,
  vcluso      like abbmveic.vcluso         ,
  rspdat      like abbmquestionario.rspdat ,
  rspcod      like abbmquestionario.rspcod ,
  ctgtrfcod   like abbmcasco.ctgtrfcod     ,
  clalclcod   like abbmdoc.clalclcod       ,
  dctsgmcod   like abbmapldctsgm.dctsgmcod ,  
  clisgmcod   like apamconclisgm.clisgmcod ,
  cgccpfnum   like gsakseg.cgccpfnum       , 
  cgcord      like gsakseg.cgcord          , 
  cgccpfdig   like gsakseg.cgccpfdig         
end record



    initialize lr_retorno.*, g_funapol.* to null

    call cty44g00_prepare()
    
    call cty44g00_recupera_diretorio()
    call cty44g00_recupera_diretorio2()
    
    let mr_retorno.arquivo  = mr_retorno.path clipped, "/PremiumProposta.xls"
     display "mr_retorno.arquivo ", mr_retorno.arquivo
    start report cty44g00_report_proposta to mr_retorno.arquivo
       
    open ccty44g00020 using mr_tela.dt_ini,
                            mr_tela.dt_fnl                                      
                                                                                     
    foreach ccty44g00020 into mr_retorno.c24astcod    ,   
    	                        mr_retorno.c24empcod    ,   
    	                        mr_retorno.c24funmat    ,   
    	                        mr_retorno.lignum       ,   
    	                        mr_retorno.atdsrvano    ,   
    	                        mr_retorno.atdsrvnum    ,   
    	                        mr_retorno.ligdat       ,   
    	                        mr_retorno.lighorinc    ,   
    	                        mr_retorno.c24soltipcod , 
    	                        mr_retorno.prporg       ,   
    	                        mr_retorno.prpnumdig       
    	    
    	    
    	    message "Gerando a Data ...", mr_retorno.ligdat 
    	    
    	    if not cty44g00_recupera_segurado_proposta() then                                                                                      
             continue foreach                                     
          end if
          
          if not cty44g00_recupera_cgccpf() then  
             continue foreach  
          end if 
          
          if not cty44g00_recupera_segurado_premium() then  
             continue foreach                    
          end if
          
          call cty44g00_recupera_atendimento()
          call cty44g00_recupera_tipo_solicitante()
          call cty44g00_recupera_assunto()
          call cty44g00_recupera_servico()
          
          #-----------------------------------------------------------
          # Recupera os Dados do Segurado
          #-----------------------------------------------------------
          
          call cty44g00_recupera_dados_proposta(mr_retorno.prporg   ,
                                                mr_retorno.prpnumdig)
          returning lr_retorno.nscdat    ,
                    lr_retorno.segsex    ,
                    lr_retorno.pestip    ,
                    lr_retorno.viginc    ,
                    lr_retorno.clscod    ,
                    lr_retorno.dt_cal    ,
                    lr_retorno.vcl0kmflg ,
                    lr_retorno.imsvlr    ,
                    lr_retorno.vcluso    ,
                    lr_retorno.rspdat    ,
                    lr_retorno.rspcod    ,
                    lr_retorno.ctgtrfcod ,
                    lr_retorno.clalclcod ,
                    lr_retorno.cgccpfnum ,
                    lr_retorno.cgcord    ,
                    lr_retorno.cgccpfdig
                 
   
       
          #----------------------------------------------------------- 
          # Recupera o Segmento Auto do Segurado                              
          #----------------------------------------------------------- 
          
          call cty44g00_recupera_segmento_proposta(mr_retorno.prporg    , 
                                                   mr_retorno.prpnumdig )
                                         
                                         
          returning lr_retorno.perfil ,
                    lr_retorno.dctsgmcod  
                 
          
          if lr_retorno.perfil is null then
          
              
              #----------------------------------------------------------- 
              # Recupera o Segmento Central do Segurado                        
              #----------------------------------------------------------- 
              
              call cty44g00_calcula_perfil(lr_retorno.nscdat    ,
                                           lr_retorno.segsex    ,
                                           lr_retorno.pestip    ,
                                           lr_retorno.viginc    ,
                                           lr_retorno.vcluso    ,
                                           lr_retorno.rspdat    ,
                                           lr_retorno.rspcod    ,
                                           lr_retorno.ctgtrfcod ,
                                           lr_retorno.imsvlr    )
              returning lr_retorno.perfil
              
                       
          end if   
              
          
          
          call cty44g00_descricao_segmento(lr_retorno.perfil)
          returning mr_retorno.segdes
     
          
          output to report cty44g00_report_proposta()
          
                                                                             
    end foreach
    
    finish report cty44g00_report_proposta
    
    call cty44g00_dispara_email()
    
    error "Arquivo Gerado com Sucesso" sleep 3                                                                 


end function

#------------------------------------------------------#  
function cty44g00_recupera_segurado()                 
#------------------------------------------------------# 

  open ccty44g00002 using mr_retorno.succod    ,
                          mr_retorno.aplnumdig ,
                          mr_retorno.itmnumdig 
       
  whenever error continue                              
  fetch ccty44g00002 into mr_retorno.segnumdig             
  whenever error stop
  
  if mr_retorno.segnumdig is null then                                  
     return false
  end if

  return true

end function   

#------------------------------------------------------#  
function cty44g00_recupera_segurado_proposta()                 
#------------------------------------------------------# 

  open ccty44g00021 using mr_retorno.prporg    ,
                          mr_retorno.prpnumdig 
                         
                         
  whenever error continue                              
  fetch ccty44g00021 into mr_retorno.segnumdig             
  whenever error stop
  
  if mr_retorno.segnumdig is null then                                  
     return false
  end if

  return true

end function   
#------------------------------------------------------#     
function cty44g00_recupera_cgccpf()                       
#------------------------------------------------------#     
                                                         
  open ccty44g00003 using mr_retorno.segnumdig             
                                                                       
  whenever error continue                                    
  fetch ccty44g00003 into mr_retorno.cgccpfnum ,
                          mr_retorno.cgcord    ,
                          mr_retorno.cgccpfdig
  
                  
  whenever error stop                                        
                                                            
  if mr_retorno.cgccpfnum is null or
  	 mr_retorno.cgccpfnum = ''    or
  	 mr_retorno.cgccpfnum = 0     then                          
     return false                                            
  end if                                                     
                                                             
  return true                                                
                                                             
end function       

#------------------------------------------------------#     
function cty44g00_recupera_segurado_premium()                       
#------------------------------------------------------#     
                                                             
  
  let mr_retorno.cont = 0 
  
  open ccty44g00004 using mr_retorno.cgccpfnum ,    
                          mr_retorno.cgcord    ,  
                          mr_retorno.cgccpfdig    
                                                                                     
  whenever error continue                                    
  fetch ccty44g00004 into mr_retorno.cont                  
  whenever error stop                                        
                                                             
  if mr_retorno.cont = 0 then                     
     return false                                            
  end if                                                     
                                                             
  return true                                                
                                                             
end function  

#------------------------------------------------------#                                                                
function cty44g00_recupera_atendimento()                         
#------------------------------------------------------#     
                                                             
  open ccty44g00005 using mr_retorno.lignum                 
                                                                                              
  whenever error continue                                    
  fetch ccty44g00005 into mr_retorno.atdnum               
  whenever error stop                                        
                                                                              
                                                             
end function 

#------------------------------------------------------#                                                                
function cty44g00_recupera_servico()                         
#------------------------------------------------------#   

  if mr_retorno.atdsrvnum is not null then  
                                                             
     open ccty44g00018 using mr_retorno.atdsrvnum,
                             mr_retorno.atdsrvano                 
                                                                                                 
     whenever error continue                                    
     fetch ccty44g00018 into mr_retorno.atdetpdes               
     whenever error stop  
      
  end if                                         
                                                                              
                                                             
end function 

#------------------------------------------------------#                                                                
function cty44g00_recupera_assunto()                         
#------------------------------------------------------#   
  
                                                             
  open ccty44g00019 using mr_retorno.c24astcod
                                                                                                                                     
  whenever error continue                                    
  fetch ccty44g00019 into mr_retorno.c24astdes             
  whenever error stop  
      
                                        
                                                                                                                                  
end function 

#------------------------------------------------------#                                                     
function cty44g00_recupera_tipo_solicitante()                        
#------------------------------------------------------#     
                                                             
  open ccty44g00006 using mr_retorno.c24soltipcod              
                                                                                    
  whenever error continue                                    
  fetch ccty44g00006 into mr_retorno.c24soltipdes               
  whenever error stop                                        
                                                                                               
                                                             
end function   

#========================================================================
 report cty44g00_report_apolice()
#========================================================================

 output

  report to printer

  page      length  66
  left      margin  00
  top       margin  00
  bottom    margin  00

   format

   first page header

        print column 001, "Data"                             , ascii(09)
                        , "Horario"                          , ascii(09)
                        , "Ligacao"                          , ascii(09)
                        , "Numero Atendimento"               , ascii(09)
                        , "Servico"                          , ascii(09)
                        , "Etapa do Servico"                 , ascii(09)
                        , "Assunto"                          , ascii(09) 
                        , "Descricao do Assunto"             , ascii(09) 
                        , "Sucursal"                         , ascii(09)
                        , "Ramo"                             , ascii(09)
                        , "Apolice"                          , ascii(09)
                        , "Item"                             , ascii(09)
                        , "Empresa"                          , ascii(09)
                        , "Matricula"                        , ascii(09)
                        , "Solicitante"                      , ascii(09)
                        , "CGC/CPF"                          , ascii(09)
                        , "Filial"                           , ascii(09)
                        , "Digito"                           , ascii(09)
                        , "Atendimento"                      , ascii(09)
                        , "Segmento"                         , ascii(09)

        skip 1 line


   on every row



        print column 001    , mr_retorno.ligdat        clipped                                   ,ascii(9)
                            , mr_retorno.lighorinc     clipped                                   ,ascii(9)
                            , mr_retorno.lignum        using "<<&&&&&&&"                         ,ascii(9)
                            , mr_retorno.atdnum        using "<<&&&&&&&"                         ,ascii(9)
                            , mr_retorno.atdsrvnum     using "<<&&&&&&&", "-" 
                            , mr_retorno.atdsrvano     using "&&"                                ,ascii(9)
                            , mr_retorno.atdetpdes     clipped                                   ,ascii(9) 
                            , mr_retorno.c24astcod     clipped                                   ,ascii(9)   
                            , mr_retorno.c24astdes     clipped                                   ,ascii(9)   
                            , mr_retorno.succod        using "<<&&"                              ,ascii(9)
                            , mr_retorno.ramcod        using "<<&&&"                             ,ascii(9)
                            , mr_retorno.aplnumdig     using "<<&&&&&&&"                         ,ascii(9)
                            , mr_retorno.itmnumdig     using "<<&&"                              ,ascii(9)
                            , mr_retorno.c24empcod     using "<<<&&"                             ,ascii(9)
                            , mr_retorno.c24funmat     clipped                                   ,ascii(9)
                            , mr_retorno.c24soltipdes  clipped                                   ,ascii(9)                                                        
                            , mr_retorno.cgccpfnum     using "<<&&&&&&&"                         ,ascii(9)                                                              
                            , mr_retorno.cgcord        using "<<<<"                              ,ascii(9)                                                         
                            , mr_retorno.cgccpfdig     using "&&"                                ,ascii(9)
                            , "PREMIUM"                                                          ,ascii(9) 
                            , mr_retorno.segdes        clipped                                   ,ascii(9)                        
                                                                                                                            
                                                                                                                 
                                                                                                                               
                                                                                                                       

#========================================================================
end report
#========================================================================   

#========================================================================    
function cty44g00_recupera_diretorio()                                                  
#========================================================================     
                                                                              
                                                                                                                                                                                                            
   let mr_retorno.path = null                                                          
   
   call f_path("DAT", "RELATO")    
   returning mr_retorno.path   
     
                                                                                                                  
   if mr_retorno.path is null or                                                       
      mr_retorno.path = " " then                                                       
      let mr_retorno.path = "."                                                        
   end if                                                                     
                                                                              
                                                                                              
#========================================================================     
end function                                                                  
#======================================================================== 

#========================================================================
function cty44g00_dispara_email()
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

    case mr_tela.tipo
       when "A"
       	   let lr_mail.assunto   = "RELATORIO ATENDIMENTO PREMIUM APOLICE"
           let lr_mail.mensagem  = "RELATORIO ATENDIMENTO PREMIUM APOLICE"
       when "P"    
       	   let lr_mail.assunto   = "RELATORIO ATENDIMENTO PREMIUM PROPOSTA"
           let lr_mail.mensagem  = "RELATORIO ATENDIMENTO PREMIUM PROPOSTA"
    end case
    
    let lr_mail.de        = "ct24hs.email@portoseguro.com.br"
    let lr_mail.para      = cty44g00_recupera_email()
    let lr_mail.cc        = ""
    let lr_mail.cco       = ""
    let lr_mail.id_remetente = "CT24HS"
    let lr_mail.tipo = "html"

    #-----------------------------------------------
    # Dispara o E-mail
    #-----------------------------------------------

     call figrc009_attach_file(mr_retorno.arquivo)

     call figrc009_mail_send1 (lr_mail.*)
     returning l_erro
              ,msg_erro

#========================================================================
end function
#========================================================================

#========================================================================                    
 function cty44g00_recupera_email()                                                                                                     
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
                                                                                         
let lr_retorno.cponom = "cty44g00_email"                                                 
                                                                                         
  open ccty44g00007 using  lr_retorno.cponom                                           
                                                                                         
  foreach ccty44g00007 into lr_retorno.cpodes                                          
                                                                                         
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

#---------------------------------------------------#
 function cty44g00_recupera_dados_apolice(lr_param)
#---------------------------------------------------#

define lr_param  record
   succod      like datrservapol.succod     ,
   aplnumdig   like datrservapol.aplnumdig  ,
   itmnumdig   like datrservapol.itmnumdig
end record

define lr_retorno record
   segnumdig      like gsakseg.segnumdig       ,
   sgrorg         like rsamseguro.sgrorg       ,
   sgrnumdig      like rsamseguro.sgrnumdig    ,
   nscdat         like gsakseg.nscdat          ,
   segsex         like gsakseg.segsex          ,
   pestip         like gsakseg.pestip          ,
   viginc         like abamapol.viginc         ,
   vigfnl         like abamapol.vigfnl         ,
   clscod         like abbmclaus.clscod        ,
   acesso         smallint                     ,
   data_calculo   date                         ,
   flag_endosso   char(01)                     ,
   erro           integer                      ,
   clausula       like abbmclaus.clscod        ,
   vcl0kmflg      like abbmveic.vcl0kmflg      ,
   imsvlr         like abbmcasco.imsvlr        ,
   vcluso         like abbmveic.vcluso         ,
   rspdat         like abbmquestionario.rspdat ,
   rspcod         like abbmquestionario.rspcod ,
   ctgtrfcod      like abbmcasco.ctgtrfcod     ,
   clalclcod      like abbmdoc.clalclcod       ,
   cgccpfnum      like gsakseg.cgccpfnum       ,
   cgcord         like gsakseg.cgcord          ,
   cgccpfdig      like gsakseg.cgccpfdig  
end record


  initialize lr_retorno.* to null

  let m_acesso = false

      #-----------------------------------------------------------
      # Localiza o Numero do Segurado
      #-----------------------------------------------------------


       if lr_param.succod    is not null  and
          lr_param.aplnumdig is not null  and
          lr_param.itmnumdig is not null  then


          if g_funapol.dctnumseq is null  then
             call f_funapol_ultima_situacao (lr_param.succod,
                                             lr_param.aplnumdig,
                                             lr_param.itmnumdig)
             returning g_funapol.*
          end if
          
     

          open ccty44g00008  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.dctnumseq
          whenever error continue
          fetch ccty44g00008 into lr_retorno.segnumdig,
                                  lr_retorno.clalclcod
          whenever error stop

          close ccty44g00008


          #-----------------------------------------------------------
          # Recupera a Vigencia da Apolice
          #-----------------------------------------------------------

          open ccty44g00009  using lr_param.succod    ,
                                   lr_param.aplnumdig
          whenever error continue
          fetch ccty44g00009 into lr_retorno.viginc,
                                  lr_retorno.vigfnl

          whenever error stop

          close ccty44g00009

          #-----------------------------------------------------------
          # Recupera a Clausula da Apolice
          #-----------------------------------------------------------

          open ccty44g00010  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.dctnumseq
          whenever error continue
          fetch ccty44g00010 into lr_retorno.clscod

          whenever error stop

          close ccty44g00010
          #-----------------------------------------------------------
          # Valida Duplicacao de Clausula 034
          #-----------------------------------------------------------
          if lr_retorno.clscod = "034" then
          	 if cta13m00_verifica_clausula(lr_param.succod      ,
                                           lr_param.aplnumdig   ,
                                           lr_param.itmnumdig   ,
                                           g_funapol.dctnumseq  ,
                                           lr_retorno.clscod    ) then
                let lr_retorno.clscod = null
             end if
          end if

          #-----------------------------------------------------------
          # Recupera os Dados do Segurado
          #----------------------------------------------------------- 
          
          open ccty44g00011 using lr_retorno.segnumdig

          whenever error continue
          fetch ccty44g00011 into lr_retorno.nscdat     ,
                                  lr_retorno.segsex     ,
                                  lr_retorno.pestip     ,
                                  lr_retorno.cgccpfnum  ,
                                  lr_retorno.cgcord     ,
                                  lr_retorno.cgccpfdig
          whenever error stop

          close ccty44g00011


          #-----------------------------------------------------------
          # Recupera a Data de Calculo
          #-----------------------------------------------------------

          call faemc144_clausula(lr_param.succod         ,
                                 lr_param.aplnumdig      ,
                                 lr_param.itmnumdig)
                       returning lr_retorno.erro         ,
                                 lr_retorno.clausula     ,
                                 lr_retorno.data_calculo ,
                                 lr_retorno.flag_endosso


          #-----------------------------------------------------------
          # Recupera Se o Veiculo e 0KM
          #-----------------------------------------------------------

          open ccty44g00012  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.dctnumseq
          whenever error continue
          fetch ccty44g00012 into lr_retorno.vcl0kmflg,
                                  lr_retorno.vcluso

          whenever error stop

          close ccty44g00012

          #-----------------------------------------------------------
          # Recupera a Importancia Segurada
          #-----------------------------------------------------------

          open ccty44g00013  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.autsitatu
          whenever error continue
          fetch ccty44g00013 into lr_retorno.imsvlr,
                                  lr_retorno.ctgtrfcod

          whenever error stop


          close ccty44g00013

          #-----------------------------------------------------------
          # Recupera a Data de Nascimento do Principal Condutor
          #-----------------------------------------------------------

          open ccty44g00014  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.dctnumseq
          whenever error continue
          fetch ccty44g00014 into lr_retorno.rspdat

          whenever error stop


          close ccty44g00014

          #-----------------------------------------------------------
          # Recupera o Sexo do Principal Condutor
          #-----------------------------------------------------------

          open ccty44g00015  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.dctnumseq
          whenever error continue
          fetch ccty44g00015 into lr_retorno.rspcod

          whenever error stop


          close ccty44g00015




      end if
      
       
      if  lr_retorno.pestip is not null and
          lr_retorno.viginc is not null then
          	   let m_acesso = true
      end if


      return  lr_retorno.nscdat
             ,lr_retorno.segsex
             ,lr_retorno.pestip
             ,lr_retorno.viginc
             ,lr_retorno.clscod
             ,lr_retorno.data_calculo
             ,lr_retorno.vcl0kmflg
             ,lr_retorno.imsvlr
             ,lr_retorno.vcluso
             ,lr_retorno.rspdat
             ,lr_retorno.rspcod
             ,lr_retorno.ctgtrfcod
             ,lr_retorno.clalclcod     
             ,lr_retorno.cgccpfnum
             ,lr_retorno.cgcord   
             ,lr_retorno.cgccpfdig

end function 


 



#--------------------------------------------------------------#
 function cty44g00_recupera_segmento(lr_param)
#--------------------------------------------------------------#

define lr_param record
	succod     like abbmapldctsgm.succod    ,
	aplnumdig  like abbmapldctsgm.aplnumdig ,
	itmnumdig  like abbmapldctsgm.itmnumdig ,
	dctnumseq  like abbmapldctsgm.dctnumseq
end record

define lr_retorno record  
	 perfil    integer                      ,
   dctsgmcod like abbmapldctsgm.dctsgmcod
end record


  initialize lr_retorno.* to null

  #------------------------------------------------#
  # Recupera o Segmento
  #------------------------------------------------#
  
  
  
  open ccty44g00016 using lr_param.succod
                         ,lr_param.aplnumdig
                         ,lr_param.itmnumdig
                         ,lr_param.dctnumseq
  whenever error continue
  fetch ccty44g00016 into lr_retorno.dctsgmcod
  whenever error stop
 
  
  if lr_retorno.dctsgmcod is not null then
     
     #------------------------------------------------#
     # Recupera o De-Para
     #------------------------------------------------#
          
     call cty44g00_recupera_depara(lr_retorno.dctsgmcod)
     returning lr_retorno.perfil 
     
  
  end if
  

  return lr_retorno.perfil ,
         lr_retorno.dctsgmcod

end function

#--------------------------------------------------------------#       
 function cty44g00_recupera_depara(lr_param)                         
#--------------------------------------------------------------#       

define lr_param  record   
   cpocod     like datkdominio.cpocod                 
end record                               
                                                                                                                                                                                          
define lr_retorno  record                                                    
	 cponom     like datkdominio.cponom,
	 cpodes     like datkdominio.cpodes                                        
end record 

                                                                                                                                                                                                                                                                             
initialize lr_retorno.* to null                                              
                                                                                                                                                          
         let lr_retorno.cponom = "ctc53m31_depara"                           
                                                                             
         #--------------------------------------------------------           
         # Recupera o Segmento                                               
         #--------------------------------------------------------           
                                                                                                                                                          
         open ccty44g00017 using lr_retorno.cponom ,        
                                 lr_param.cpocod              
                                                                             
         whenever error continue                                             
         fetch ccty44g00017 into lr_retorno.cpodes          
         whenever error stop 
         
         return lr_retorno.cpodes                                                
                                                                                                                                                          
end function

#----------------------------------------------#
 function cty44g00_calcula_perfil(lr_param)
#----------------------------------------------#

define lr_param record
  nscdat     like gsakseg.nscdat          ,
  segsex     like gsakseg.segsex          ,
  pestip     like gsakseg.pestip          ,
  viginc     like abamapol.viginc         ,
  vcluso     like abbmveic.vcluso         ,
  rspdat     like abbmquestionario.rspdat ,
  rspcod     like abbmquestionario.rspcod ,
  ctgtrfcod  like abbmcasco.ctgtrfcod     ,
  imsvlr     like abbmcasco.imsvlr
end record

define lr_retorno record
  idade  integer  ,
  perfil smallint ,
  dias   dec(10,2)
end record

#-----------------------------------------------------------
# Segmento 1 = Tradicional (25 a 59 anos)
# Segmento 2 = Jovem (Menor de 25 anos)
# Segmento 3 = Senior ( Maior de 59 anos)
# Segmento 4 = Mulher (Sexo: F)
# Segmento 5 = Taxi
# Segmento 6 = Caminhao
# Segmento 7 = Moto
# Segmento 8 = Auto Premium
# Segmento 9 = Juridica
#-----------------------------------------------------------

initialize lr_retorno.* to null


   let lr_retorno.dias  = 365.25

   let lr_retorno.idade = ((lr_param.viginc - lr_param.rspdat)/lr_retorno.dias)

   #--------------#
   # Tradicional  #
   #--------------#

   let lr_retorno.perfil = 1

   #------------------------------#
   # Valida se o Segmento e Moto  #
   #------------------------------#

   if cty44g00_valida_segmento_moto(lr_param.ctgtrfcod) then
      let lr_retorno.perfil = 7

      return lr_retorno.perfil
   end if


   #------------------------------#
   # Valida se o Segmento e Taxi  #
   #------------------------------#

   if cty44g00_valida_segmento_taxi(lr_param.ctgtrfcod) then
      let lr_retorno.perfil = 5

      return lr_retorno.perfil
   end if


   #----------------------------------#
   # Valida se o Segmento e Caminhao  #
   #----------------------------------#

   if cty44g00_valida_segmento_caminhao(lr_param.ctgtrfcod) then
      let lr_retorno.perfil = 6

      return lr_retorno.perfil
   end if

   #----------------------------------#
   # Valida se o Segmento e Premium   #
   #----------------------------------#

   #if cty44g00_valida_segmento_premium(lr_retorno.idade,
   #	                                   lr_param.imsvlr ) then
   #   let lr_retorno.perfil = 8
   #
   #   return lr_retorno.perfil
   #end if

   if lr_param.pestip = "F" then

      	 #----------------------------------#
      	 # Valida se o Segmento e Mulher    #
      	 #----------------------------------#

      	 if cty44g00_valida_segmento_mulher(lr_retorno.idade,
      	 	                                  lr_param.rspcod ) then
      	    let lr_retorno.perfil = 4

      	    return lr_retorno.perfil
      	 end if


      	 #----------------------------------#
      	 # Valida se o Segmento e Jovem     #
      	 #----------------------------------#

      	 if cty44g00_valida_segmento_jovem(lr_retorno.idade) then
      	    let lr_retorno.perfil = 2

      	    return lr_retorno.perfil
      	 end if


      	 #----------------------------------#
      	 # Valida se o Segmento e Senior    #
      	 #----------------------------------#

      	 if cty44g00_valida_segmento_senior(lr_retorno.idade) then
      	    let lr_retorno.perfil = 3

      	    return lr_retorno.perfil
      	 end if

 	 end if 
 	 
 	 
 	 #-------------------------------------------#
 	 # Valida se o Segmento e Pessoa Juridica    # 
 	 #-------------------------------------------#	 

 	 if lr_param.pestip = "J" then
 	 	  let lr_retorno.perfil = 9 	
 	 end if

   return lr_retorno.perfil

end function 

#----------------------------------------------#
 function cty44g00_valida_segmento_moto(lr_param)
#----------------------------------------------#

define lr_param record
	ctgtrfcod      like abbmcasco.ctgtrfcod
end record

  if lr_param.ctgtrfcod = 30 or
  	 lr_param.ctgtrfcod = 31 then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------#
 function cty44g00_valida_segmento_taxi(lr_param)
#----------------------------------------------#

define lr_param record
	ctgtrfcod      like abbmcasco.ctgtrfcod
end record

  if lr_param.ctgtrfcod = 80 or
  	 lr_param.ctgtrfcod = 81 then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty44g00_valida_segmento_caminhao(lr_param)
#----------------------------------------------------#

define lr_param record
	ctgtrfcod      like abbmcasco.ctgtrfcod
end record


  if lr_param.ctgtrfcod = 40 or
  	 lr_param.ctgtrfcod = 41 or
  	 lr_param.ctgtrfcod = 42 or
  	 lr_param.ctgtrfcod = 43 then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty44g00_valida_segmento_premium(lr_param)
#----------------------------------------------------#

define lr_param record
	idade   integer               ,
	imsvlr  like abbmcasco.imsvlr
end record


  if lr_param.imsvlr >= 200000.00 and
  	 lr_param.idade  >= 25        and
  	 lr_param.idade  <= 59        then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty44g00_valida_segmento_mulher(lr_param)
#----------------------------------------------------#

define lr_param record
	idade   integer               ,
	rspcod  like abbmquestionario.rspcod
end record


  if lr_param.rspcod =  2   and
  	 lr_param.idade  >= 25  and
  	 lr_param.idade  <= 59  then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty44g00_valida_segmento_jovem(lr_param)
#----------------------------------------------------#

define lr_param record
	idade   integer
end record

  if lr_param.idade  >= 18  and
  	 lr_param.idade  <= 24  then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty44g00_valida_segmento_senior(lr_param)
#----------------------------------------------------#

define lr_param record
	idade   integer
end record

  if lr_param.idade  >= 60  then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty44g00_descricao_segmento(lr_param)
#----------------------------------------------------#

define lr_param record
	segmento   integer
end record

define lr_retorno record
	descricao   char(50)
end record


  initialize lr_retorno.* to null

   case lr_param.segmento
    	 when 1
    	   let lr_retorno.descricao = "TRADICIONAL"
    	 when 2
    	 	 let lr_retorno.descricao = "JOVEM "
       when 3
         let lr_retorno.descricao = "SENIOR "
       when 4
         let lr_retorno.descricao = "MULHER "
       when 5
    	   let lr_retorno.descricao = "TAXI "
    	 when 6
    	 	 let lr_retorno.descricao = "CAMINHAO "
       when 7
         let lr_retorno.descricao = "MOTO "
       when 8
         let lr_retorno.descricao = "PREMIUM"
       when 9
         let lr_retorno.descricao = "P.JURIDICA "
   end case

   return lr_retorno.descricao

end function 

#---------------------------------------------------#
 function cty44g00_recupera_dados_proposta(lr_param)
#---------------------------------------------------#

define lr_param  record
   prporg      like datrligprp.prporg     ,
   prpnumdig   like datrligprp.prpnumdig  
end record

define lr_retorno record
   segnumdig      like gsakseg.segnumdig       ,
   sgrorg         like rsamseguro.sgrorg       ,
   sgrnumdig      like rsamseguro.sgrnumdig    ,
   nscdat         like gsakseg.nscdat          ,
   segsex         like gsakseg.segsex          ,
   pestip         like gsakseg.pestip          ,
   viginc         like abamapol.viginc         ,
   vigfnl         like abamapol.vigfnl         ,
   clscod         like abbmclaus.clscod        ,
   acesso         smallint                     ,
   data_calculo   date                         ,
   flag_endosso   char(01)                     ,
   erro           integer                      ,
   clausula       like abbmclaus.clscod        ,
   vcl0kmflg      like abbmveic.vcl0kmflg      ,
   imsvlr         like abbmcasco.imsvlr        ,
   vcluso         like abbmveic.vcluso         ,
   rspdat         like abbmquestionario.rspdat ,
   rspcod         like abbmquestionario.rspcod ,
   ctgtrfcod      like abbmcasco.ctgtrfcod     ,
   clalclcod      like abbmdoc.clalclcod       ,
   cgccpfnum      like gsakseg.cgccpfnum       ,
   cgcord         like gsakseg.cgcord          ,
   cgccpfdig      like gsakseg.cgccpfdig       ,
   cbtcod         like abbmcasco.cbtcod        , 
   clcdat         like abbmcasco.clcdat                
end record


  initialize lr_retorno.* to null

  
      #------------------------------------------------------       
      # Recupera Numero do Segurado e Classe de Localizacao         
      #------------------------------------------------------       
                                                                    
                                                                    
      open ccty44g00022 using   lr_param.prporg    ,            
                                lr_param.prpnumdig ,            
                                lr_param.prporg    ,            
                                lr_param.prpnumdig              
      whenever error continue                                       
      fetch ccty44g00022 into lr_retorno.clalclcod              
      whenever error stop 
      
      
      #------------------------------------------------------   
      # Recupera Cobertura, Categoria e Data de Calculo         
      #------------------------------------------------------   
                                                                
      open ccty44g00023 using lr_param.prporg   ,        
                              lr_param.prpnumdig,        
                              lr_param.prporg   ,        
                              lr_param.prpnumdig         
      whenever error continue                                   
      fetch ccty44g00023 into lr_retorno.cbtcod    ,        
                              lr_retorno.ctgtrfcod ,        
                              lr_retorno.clcdat             
      whenever error stop    
      
      
      #-----------------------------------------------------------
      # Recupera os Dados do Segurado
      #-----------------------------------------------------------

      open ccty44g00011 using lr_retorno.segnumdig

      whenever error continue
      fetch ccty44g00011 into lr_retorno.nscdat     ,
                              lr_retorno.segsex     ,
                              lr_retorno.pestip     ,
                              lr_retorno.cgccpfnum  ,
                              lr_retorno.cgcord     ,
                              lr_retorno.cgccpfdig
      whenever error stop

      close ccty44g00011
      
      if lr_retorno.pestip <> "F"  or
         lr_retorno.pestip <> "J"  or
         lr_retorno.pestip is null then
         
         if lr_retorno.cgcord = 0 or
            lr_retorno.cgcord is null then
            let lr_retorno.pestip = 'F'
         else
            let lr_retorno.pestip = 'J'
         end if
      
      end if
      
      if lr_retorno.cgcord is null then
         if lr_retorno.pestip = 'F' then
            let lr_retorno.cgcord = 0
         end if
      end if
      
      
      #-----------------------------------------------------------
      # Recupera Se o Veiculo e 0KM
      #-----------------------------------------------------------

      open ccty44g00024  using lr_param.prporg    ,
                               lr_param.prpnumdig ,
                               lr_param.prporg    ,
                               lr_param.prpnumdig
      whenever error continue
      fetch ccty44g00024 into lr_retorno.vcluso

      whenever error stop

      close ccty44g00024 
      
      #-----------------------------------------------------------
      # Recupera a Data de Nascimento do Principal Condutor
      #-----------------------------------------------------------

      open ccty44g00025 using lr_param.prporg    ,
                              lr_param.prpnumdig ,
                              lr_param.prporg    ,
                              lr_param.prpnumdig
      whenever error continue
      fetch ccty44g00025 into lr_retorno.rspdat

      whenever error stop

      close ccty44g00025

      #-----------------------------------------------------------
      # Recupera o Sexo do Principal Condutor
      #-----------------------------------------------------------

      open ccty44g00026  using lr_param.prporg    ,
                               lr_param.prpnumdig ,
                               lr_param.prporg    ,
                               lr_param.prpnumdig
      whenever error continue
      fetch ccty44g00026  into lr_retorno.rspcod

      whenever error stop

      close ccty44g00026
      
      
      open ccty44g00028 using lr_param.prporg    ,    
                              lr_param.prpnumdig      
                                                                                                             
      whenever error continue                           
      fetch ccty44g00028 into lr_retorno.viginc      
      whenever error stop                                    

      return  lr_retorno.nscdat
             ,lr_retorno.segsex
             ,lr_retorno.pestip
             ,lr_retorno.viginc
             ,lr_retorno.clscod
             ,lr_retorno.data_calculo
             ,lr_retorno.vcl0kmflg
             ,lr_retorno.imsvlr
             ,lr_retorno.vcluso
             ,lr_retorno.rspdat
             ,lr_retorno.rspcod
             ,lr_retorno.ctgtrfcod
             ,lr_retorno.clalclcod     
             ,lr_retorno.cgccpfnum
             ,lr_retorno.cgcord   
             ,lr_retorno.cgccpfdig

end function 

#--------------------------------------------------------------#
 function cty44g00_recupera_segmento_proposta(lr_param)
#--------------------------------------------------------------#

define lr_param record
	prporgpcp  like apbmprpdctsgm.prporgpcp ,  
  prpnumpcp  like apbmprpdctsgm.prpnumpcp 
end record

define lr_retorno record  
	 perfil    integer                      ,
   dctsgmcod like abbmapldctsgm.dctsgmcod
end record

 
  initialize lr_retorno.* to null

  #------------------------------------------------#
  # Recupera o Segmento por Proposta
  #------------------------------------------------#
   
  open ccty44g00027 using lr_param.prporgpcp
                         ,lr_param.prpnumpcp
  whenever error continue
  fetch ccty44g00027 into lr_retorno.dctsgmcod
  whenever error stop
 
  
  if lr_retorno.dctsgmcod is not null then
     
     #------------------------------------------------#
     # Recupera o De-Para
     #------------------------------------------------#
          
     call cty44g00_recupera_depara(lr_retorno.dctsgmcod)
     returning lr_retorno.perfil 
     
  
  end if
  

  return lr_retorno.perfil ,
         lr_retorno.dctsgmcod

end function


#========================================================================
 report cty44g00_report_proposta()
#========================================================================

 output

  report to printer

  page      length  66
  left      margin  00
  top       margin  00
  bottom    margin  00

   format

   first page header

        print column 001, "Data"                             , ascii(09)
                        , "Horario"                          , ascii(09)
                        , "Ligacao"                          , ascii(09)
                        , "Numero Atendimento"               , ascii(09)
                        , "Servico"                          , ascii(09)
                        , "Etapa do Servico"                 , ascii(09)
                        , "Assunto"                          , ascii(09) 
                        , "Descricao do Assunto"             , ascii(09) 
                        , "Origem Proposta"                  , ascii(09)
                        , "Numero Proposta"                  , ascii(09)
                        , "Empresa"                          , ascii(09)
                        , "Matricula"                        , ascii(09)
                        , "Solicitante"                      , ascii(09)
                        , "CGC/CPF"                          , ascii(09)
                        , "Filial"                           , ascii(09)
                        , "Digito"                           , ascii(09)
                        , "Atendimento"                      , ascii(09)
                        , "Segmento"                         , ascii(09)

        skip 1 line


   on every row



        print column 001    , mr_retorno.ligdat        clipped                                   ,ascii(9)
                            , mr_retorno.lighorinc     clipped                                   ,ascii(9)
                            , mr_retorno.lignum        using "<<&&&&&&&"                         ,ascii(9)
                            , mr_retorno.atdnum        using "<<&&&&&&&"                         ,ascii(9)
                            , mr_retorno.atdsrvnum     using "<<&&&&&&&", "-" 
                            , mr_retorno.atdsrvano     using "&&"                                ,ascii(9)
                            , mr_retorno.atdetpdes     clipped                                   ,ascii(9) 
                            , mr_retorno.c24astcod     clipped                                   ,ascii(9)   
                            , mr_retorno.c24astdes     clipped                                   ,ascii(9)   
                            , mr_retorno.prporg        using "<<&&"                              ,ascii(9)
                            , mr_retorno.prpnumdig     using "<<&&&&&&&"                         ,ascii(9)
                            , mr_retorno.c24empcod     using "<<<&&"                             ,ascii(9)
                            , mr_retorno.c24funmat     clipped                                   ,ascii(9)
                            , mr_retorno.c24soltipdes  clipped                                   ,ascii(9)                                                        
                            , mr_retorno.cgccpfnum     using "<<&&&&&&&"                         ,ascii(9)                                                              
                            , mr_retorno.cgcord        using "<<<<"                              ,ascii(9)                                                         
                            , mr_retorno.cgccpfdig     using "&&"                                ,ascii(9)
                            , "PREMIUM"                                                          ,ascii(9) 
                            , mr_retorno.segdes        clipped                                   ,ascii(9)                        
                                                                                                                            
                                                                                                                 
                                                                                                                               
                                                                                                                       

#========================================================================
end report
#======================================================================== 

#-------------------------------------------------#                  
 function cty44g00_recupera_diretorio2()                    
#-------------------------------------------------#                  
                                                                                                                      
                                                                     
define lr_retorno record                                             
  diretorio  char(200) ,                                                
  chave      char(20)                                                
end record    

                                                                                                                         
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "cty44g00_dir"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica um Novo Diretorio                         
    #--------------------------------------------------------        
                                                                     
    open ccty44g00007  using  lr_retorno.chave                   
                                       
    whenever error continue                                          
    fetch ccty44g00007 into lr_retorno.diretorio                       
    whenever error stop                                              
                                                                   
    if lr_retorno.diretorio is not null  then   	 	                                   
    	 let mr_retorno.path = lr_retorno.diretorio    	                                                 
    end if                                                                                                           
                                                                     
                                                                     
end function     
             