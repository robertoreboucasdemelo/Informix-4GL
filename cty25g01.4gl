#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Seguro Residencia - Itau Seguros                          #
# Modulo.........: cty25g01                                                  #
# Objetivo.......: Atendimento Itau Seguros para Seguro Residencia           #
# Analista Resp. : Junior (FORNAX)                                           #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: Junior (FORNAX)                                           #
# Liberacao      :   /  /                                                    #
#............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare  smallint

define mr_array array[500] of record         
       seta              smallint                        ,             
       segnom            like datmitaapl.segnom          ,           
       itaaplvigincdat   like datmitaapl.itaaplvigincdat ,
       itaaplvigfnldat   like datmitaapl.itaaplvigfnldat 
end record

define mr_array_aux array[500] of record      
       sitdoc            char(10)                        ,
       adnicldat         date                            ,
       documento         char(20)                       
end record  

define mr_retorno array[500] of record                        
       itaciacod     like datmresitaapl.itaciacod    ,    
       itaramcod     like datmresitaapl.itaramcod    ,  
       aplnum        like datmresitaapl.aplnum       ,  
       aplseqnum     like datmresitaapl.aplseqnum    ,  
       aplitmnum     like datmresitaaplitm.aplitmnum ,
       succod        like datmresitaapl.succod       ,
       cgccpfnum     like datkitavippes.cgccpfnum    ,  
       cgccpford     like datkitavippes.cgccpford    ,
       cgccpfdig     like datkitavippes.cgccpfdig   
end record                                                       

define m_index   integer
define m_segnom  like datmitaapl.segnom    

#------------------------------------------------------------------------------
function cty25g01_prepare()
#------------------------------------------------------------------------------

define l_sql char(2000)

   let l_sql = " select a.itaciacod  ,                      ",
	       "        a.itaramcod  ,                      ",
	       "        a.aplnum     ,                      ",
	       "        a.aplseqnum  ,                      ",
	       "        a.succod     ,                      ",
	       "        a.incvigdat  ,                      ",
	       "        a.fnlvigdat  ,                      ",
	       "        a.adnicldat  ,                      ",
	       "          a.segnom                          ",
	       " from datmresitaapl a                        ",
	       " where a.segnom matches '*", m_segnom clipped,"*' ",
	       " and a.aplseqnum = (select max(b.aplseqnum) ",
	       " from datmresitaapl b                        ",
	       " where a.itaciacod = b.itaciacod            ",
	       " and   a.itaramcod = b.itaramcod            ",
	       " and   a.aplnum    = b.aplnum)              ",
	       " order by a.segnom, a.fnlvigdat desc        "

   prepare p_cty25g01_004  from l_sql
   declare c_cty25g01_004  cursor for p_cty25g01_004 

   let l_sql = " select aplitmnum    " ,
	       " from datmresitaaplitm " ,
	       " where itaciacod = ? "  ,
	       " and   itaramcod = ? "  ,
	       " and   aplnum    = ? "  ,
	       " and   aplseqnum = ? "  ,
	       " order by aplitmnum  "
   prepare p_cty25g01_005  from l_sql
   declare c_cty25g01_005  cursor for p_cty25g01_005


   let l_sql = " select max(aplseqnum) " ,
	       " from datmresitaapl " ,
	       " where itaciacod = ?   " ,
	       " and   itaramcod = ?   " ,
	       " and   aplnum    = ?   "
   prepare p_cty25g01_006  from l_sql
   declare c_cty25g01_006  cursor for p_cty25g01_006

   let l_sql = " select a.itaciacod  ,                    ",    
               "        a.itaramcod  ,                    ",    
               "        a.aplnum     ,                    ",    
               "        a.aplseqnum  ,                    ",   
               "        a.succod     ,                    ", 
               "        a.incvigdat  ,                    ",    
               "        a.fnlvigdat  ,                    ",    
               "        a.adnicldat  ,                    ",    
               "          a.segnom                        ",
               " from datmresitaapl a                     ",    
               " where a.pestipcod    = ?                 ",      
               " and   a.segcpjcpfnum = ?                 ",
               " and   a.cpjordnum    = ?                 ",
               " and   a.cpjcpfdignum = ?                 ",
               " and a.aplseqnum =(select max(b.aplseqnum)",    
               " from datmresitaapl b                     ",       
               " where a.itaciacod = b.itaciacod          ",   
               " and   a.itaramcod = b.itaramcod          ",   
               " and   a.aplnum    = b.aplnum)            ",                  
               " order by a.segnom, a.fnlvigdat desc      "     
   prepare p_cty25g01_008  from l_sql                         
   declare c_cty25g01_008  cursor for p_cty25g01_008

   let l_sql = "select a.itaciacod  , ",
	             "  a.itaramcod       , ",
	             "  a.aplnum          , ",
	             "  a.aplseqnum       , ",
	             "  a.prpnum          , ",
	             "  a.incvigdat       , ",
	             "  a.fnlvigdat       , ",
	             "  a.segnom          , ",
	             "  a.pestipcod       , ",
	             "  a.segcpjcpfnum    , ",
	             "  a.cpjordnum       , ",
	             "  a.cpjcpfdignum    , ",
	             "  b.prdcod          , ",
	             "  b.empcod          , ",
	             "  b.srvcod          , ",
	             "  a.suscod          , ",
               "  a.seglgdnom       , ",
	             "  a.seglgdnum       , ",
	             "  a.seglcacpldes    , ",
	             "  a.brrnom          , ",
	             "  a.segcidnom       , ",
	             "  a.estsgl          , ",
	             "  a.cepcod          , ",
	             "  a.cepcplcod       , ",
	             "  a.dddcod          , ",
	             "  a.telnum          , ",
	             "  a.adnicldat       , ",
	             "  a.vrsnum          , ",
	             "  a.pcmnum          , ",
	             "  a.succod          , ",
	             "  a.eslsegflg       , ",
	             "  a.sgmcod          , ",
	             "  b.aplitmnum       , ",
	             "  b.itmsttcod       , ",
	             "  b.rsccepcod       , ",   
	             "  b.rsclgdnom       , ",
	             "  b.rsclgdnum       , ",
	             "  b.rsccpldes       , ",
	             "  b.rscbrrnom       , ",
	             "  b.rsccidnom       , ",
	             "  b.rscestsgl       , ",
	             "  b.rsccepcod       , ",
	             "  b.rsccepcplcod      ",
	       " from datmresitaapl a    ,  ",
	       "      datmresitaaplitm b    ",
	       " where a.itaciacod = b.itaciacod  ",
	       " and   a.itaramcod = b.itaramcod  ",
	       " and   a.aplnum    = b.aplnum     ",
	       " and   a.aplseqnum = b.aplseqnum  ",
	       " and   a.itaciacod     = ? ",
         " and   a.itaramcod     = ? ",
	       " and   a.aplnum        = ? ",
	       " and   a.aplseqnum     = ? ",
	       " and   b.aplitmnum     = ? "
   prepare p_cty25g01_009  from l_sql
   declare c_cty25g01_009  cursor for p_cty25g01_009

   let l_sql = " select  itacbtcod,    " ,
	       "         itaasiplncod  " ,
	       " from datkitacbtintrgr " ,
	       " where itaasisrvcod     = ?     " ,
	       " and   rsrcaogrtcod     = ?     " ,
	       " and   itarsrcaosrvcod  = ?     " ,
	       " and   ubbcod           = ?     "
   prepare p_cty25g01_010  from l_sql
   declare c_cty25g01_010  cursor for p_cty25g01_010

end function

#------------------------------------------------------------------------------
function cty25g01_rec_apolice_por_nome(lr_param)
#------------------------------------------------------------------------------

define lr_param record
       segnom        like datmitaapl.segnom
end record

define lr_retorno record
   itaciacod     like datmresitaapl.itaciacod    ,
   itaramcod     like datmresitaapl.itaramcod    ,
   aplnum        like datmresitaapl.aplnum       ,
   aplseqnum     like datmresitaapl.aplseqnum    ,
   aplitmnum     like datmresitaaplitm.aplitmnum ,
   succod        like datmresitaapl.succod       ,
   erro          integer                      ,
   mensagem      char(50)
end record

define lr_aux record
       itaciacod        like datmitaapl.itaciacod          ,
       itaramcod        like datmitaapl.itaramcod          ,
       aplnum           like datmresitaapl.aplnum          ,
       aplseqnum        like datmresitaapl.aplseqnum       ,
       aplitmnum        like datmresitaaplitm.aplitmnum    ,
       succod           like datmitaapl.succod             ,
       segnom           like datmitaapl.segnom             ,
       itaaplcanmtvcod  like datmitaaplitm.itaaplcanmtvcod ,
       incvigdat        like datmresitaapl.incvigdat       ,
       fnlvigdat        like datmresitaapl.fnlvigdat       ,
       adnicldat        date                               
end record

initialize lr_retorno.*,
   lr_aux.*    to null

   let m_segnom = null

   for  m_index  =  1  to  500
      initialize  mr_array[m_index].*     ,
          	  mr_array_aux[m_index].* ,
		  mr_retorno[m_index].*   to null
   end  for

   let m_segnom = lr_param.segnom clipped , "*"

   if m_prepare is null or
      m_prepare <> true then
      call cty25g01_prepare()
   end if

   let lr_retorno.erro = 0

   let m_index = 0

   # Recupera a Lista de Segurados por Nome   
   open c_cty25g01_004

   foreach c_cty25g01_004 into lr_aux.itaciacod ,
			       lr_aux.itaramcod ,
			       lr_aux.aplnum    , 
			       lr_aux.aplseqnum ,
			       lr_aux.succod    ,
			       lr_aux.incvigdat ,
			       lr_aux.fnlvigdat ,
			       lr_aux.adnicldat ,
			       lr_aux.segnom


           # Recupera os Itens de cada Segurado

           open c_cty25g01_005 using  lr_aux.itaciacod ,
				      lr_aux.itaramcod ,
				      lr_aux.aplnum    ,
				      lr_aux.aplseqnum
    
	   foreach c_cty25g01_005 into lr_aux.aplitmnum  

		   if m_index = 0 then
		      let m_index = 1
                   end if
																						  # Carrega os Dados
       
		let mr_array[m_index].segnom           = lr_aux.segnom
		let mr_array[m_index].itaaplvigincdat  = lr_aux.incvigdat
		let mr_array[m_index].itaaplvigfnldat  = lr_aux.fnlvigdat
		let mr_retorno[m_index].itaciacod      = lr_aux.itaciacod
		let mr_retorno[m_index].itaramcod      = lr_aux.itaramcod
		let mr_retorno[m_index].aplnum         = lr_aux.aplnum
		let mr_retorno[m_index].aplseqnum      = lr_aux.aplseqnum
		let mr_retorno[m_index].aplitmnum      = lr_aux.aplitmnum
		let mr_retorno[m_index].succod         = lr_aux.succod
		let mr_array_aux[m_index].adnicldat    = lr_aux.adnicldat
 
		let mr_array_aux[m_index].documento    = lr_aux.itaciacod    using '<&&'       ,".",
                                                         lr_aux.itaramcod    using '<<<<&'     ,".",
                                                         lr_aux.aplnum    using '<<<&&&&&&' ,".",
		                                         lr_aux.aplseqnum    using '<<<&&'     ,".",
		                                         lr_aux.aplitmnum using '<<<&&'


		if lr_aux.incvigdat <= today and
		   lr_aux.fnlvigdat >= today then


		   if lr_aux.itaaplcanmtvcod is null then
		      let mr_array_aux[m_index].sitdoc = "ATIVA"
		   else
		      let mr_array_aux[m_index].sitdoc = "CANCELADA"
		   end if
		else
		   let mr_array_aux[m_index].sitdoc = "VENCIDA"
		end if


                let m_index = m_index + 1

		if m_index > 500 then
		   message "Limite excedido. Foram Encontrados mais de 500 Itens!"
		   exit foreach
                end if		    
         end foreach

	 if m_index > 500 then
	    exit foreach
         end if

   end foreach

   if m_index > 2 then
      call cty25g01_display()
      returning lr_retorno.itaciacod ,
                lr_retorno.itaramcod ,
                lr_retorno.aplnum    ,
                lr_retorno.aplseqnum ,
                lr_retorno.aplitmnum ,
                lr_retorno.succod

      if lr_retorno.aplnum is null then
         let lr_retorno.erro     = 1
      end if
   else
      if m_index = 0 then
         let lr_retorno.erro       = 1
	 let lr_retorno.mensagem   = "Nome do Segurado nao Encontrado!"
      else
	 let lr_retorno.itaciacod    =  mr_retorno[m_index - 1].itaciacod
	 let lr_retorno.itaramcod    =  mr_retorno[m_index - 1].itaramcod
         let lr_retorno.aplnum       =  mr_retorno[m_index - 1].aplnum
	 let lr_retorno.aplseqnum    =  mr_retorno[m_index - 1].aplseqnum
	 let lr_retorno.aplitmnum    =  mr_retorno[m_index - 1].aplitmnum
	 let lr_retorno.succod       =  mr_retorno[m_index - 1].succod
      end if
   end if

   return lr_retorno.itaciacod ,
          lr_retorno.itaramcod ,
	  lr_retorno.aplnum    ,
	  lr_retorno.aplseqnum ,
	  lr_retorno.aplitmnum ,
	  lr_retorno.succod    ,
	  lr_retorno.erro      ,
	  lr_retorno.mensagem

end function

#------------------------------------------------------------------------------ 
function cty25g01_display()                                                             
#------------------------------------------------------------------------------ 

define lr_retorno record                                         
   itaciacod     like datmresitaapl.itaciacod    ,               
   itaramcod     like datmresitaapl.itaramcod    ,               
   aplnum        like datmresitaapl.aplnum       ,               
   aplseqnum     like datmresitaapl.aplseqnum    ,               
   aplitmnum     like datmresitaaplitm.aplitmnum ,
   succod        like datmresitaapl.succod          
end record

define scr_aux smallint         

initialize lr_retorno.* to null
                                                       
      open window cty25g01 at 4,2 with form "cty25g01"     
         attribute (border,form line 1)                      
                                                             
      message " (F17)Abandona, (F8)Seleciona"                
      call set_count(m_index-1)  
      
      options insert   key F40 
      options delete   key F35 
      options next     key F30 
      options previous key F25 
                                                             
      input array  mr_array without defaults from s_cta00m28.* 
      
      #------------------         
       before row                 
      #------------------         
          let m_index = arr_curr()   
          let scr_aux = scr_line()
      
      #------------------    
       before field seta                                                          
      #------------------    
       display mr_array[m_index].* to s_cta00m28[scr_aux].* attribute(reverse)                                                                          
           
       display by name mr_array_aux[m_index].documento                                     
       display by name mr_array_aux[m_index].sitdoc                                        
       display by name mr_array_aux[m_index].adnicldat
       
      #------------------                                                                                
       after field seta                                                           
      #------------------   
       if  fgl_lastkey() <> fgl_keyval("up")   and                               
           fgl_lastkey() <> fgl_keyval("left") then                              
                if mr_array[m_index + 1 ].segnom is null then                 
                      next field seta                                            
                end if                                                           
       end if                                                                    
      
       display mr_array[m_index].* to s_cta00m28[scr_aux].*  
                                                             
         on key (interrupt,control-c)                        
            initialize mr_array to null                      
            let m_index = null
            exit input                                     
                                                             
         on key (f8)                                         
            let m_index = arr_curr()     
                       
            let lr_retorno.itaciacod   = mr_retorno[m_index].itaciacod       
            let lr_retorno.itaramcod   = mr_retorno[m_index].itaramcod    
            let lr_retorno.aplnum      = mr_retorno[m_index].aplnum    
            let lr_retorno.aplseqnum   = mr_retorno[m_index].aplseqnum    
            let lr_retorno.aplitmnum   = mr_retorno[m_index].aplitmnum 
            let lr_retorno.succod      = mr_retorno[m_index].succod
                        
            exit input                                
      end input                                           
                                                             
      close window cty25g01                                  
                                                             
      let int_flag = false                                   
      
      return lr_retorno.itaciacod ,  
             lr_retorno.itaramcod ,
             lr_retorno.aplnum    ,
             lr_retorno.aplseqnum ,
             lr_retorno.aplitmnum ,
             lr_retorno.succod
                 
end function

#------------------------------------------------------------------------------                         
function cty25g01_rec_apolice_por_cgccpf(lr_param)                                                              
#------------------------------------------------------------------------------                               
define lr_param record                                                                                  
  pestipcod     like datmresitaapl.pestipcod    , 
  segcpjcpfnum  like datmresitaapl.segcpjcpfnum , 
  cpjordnum     like datmresitaapl.cpjordnum    , 
  cpjcpfdignum  like datmresitaapl.cpjcpfdignum                                                             
end record                                                                                              
                                                                                                        
define lr_retorno record                                                           
   itaciacod     like datmresitaapl.itaciacod ,
   itaramcod     like datmresitaapl.itaramcod ,
   aplnum        like datmresitaapl.aplnum    ,
   aplseqnum     like datmresitaapl.aplseqnum ,
   aplitmnum     like datmresitaaplitm.aplitmnum ,
   succod        like datmresitaapl.succod    ,
   erro          integer                      ,
   mensagem      char(50)
end record    

define lr_aux record                                                                                    
   itaciacod        like datmresitaapl.itaciacod          ,
   itaramcod        like datmresitaapl.itaramcod          ,
   aplnum           like datmresitaapl.aplnum             ,
   aplseqnum        like datmresitaapl.aplseqnum          ,
   aplitmnum        like datmresitaaplitm.aplitmnum       ,
   succod           like datmresitaapl.succod             ,
   segnom           like datmresitaapl.segnom             , 
   itaaplcanmtvcod  like datmitaaplitm.itaaplcanmtvcod ,
   incvigdat        like datmresitaapl.incvigdat       ,
   fnlvigdat        like datmresitaapl.fnlvigdat       ,
   adnicldat        date               
end record                                                                                              
   
   if m_prepare is null or
      m_prepare <> true then
      call cty25g01_prepare()
   end if
                                                                                                        
initialize lr_retorno.*,                                                                                
           lr_aux.*    to null                                                                          
                                                                                                        
let m_segnom = null                                                                                     
                                                                                                        
for  m_index  =  1  to  500                                                                             
   initialize  mr_array[m_index].*     ,                                                                
               mr_array_aux[m_index].* ,                                                                
               mr_retorno[m_index].*   to null                                                          
end  for                                                                                                
                                                                                                        
let lr_retorno.erro = 0                                                                                 
                                                                                                        
   let m_index = 0      
   
   if lr_param.pestipcod = "F" then
      let lr_param.cpjordnum = 0
   end if                                                                                
                                                                                                        
   # Recupera a Lista de Segurados por CGC/CPF                                                            
                                                                                                        
   open c_cty25g01_008 using lr_param.pestipcod     ,  
                             lr_param.segcpjcpfnum  ,
                             lr_param.cpjordnum     ,
                             lr_param.cpjcpfdignum 
                                                                                     
   foreach c_cty25g01_008 into lr_aux.itaciacod      ,                                                  
                               lr_aux.itaramcod      ,                                                  
                               lr_aux.aplnum         ,                                                  
                               lr_aux.aplseqnum      ,  
                               lr_aux.succod         ,                                                
                               lr_aux.incvigdat      ,                                                  
                               lr_aux.fnlvigdat      ,                                                  
                               lr_aux.adnicldat      ,                                                  
                               lr_aux.segnom         
                                                                                    
                                                                                                        
            # Recupera os Itens de cada Segurado                                                        
                                                                                                        
            open c_cty25g01_005 using  lr_aux.itaciacod ,                                               
                                       lr_aux.itaramcod ,                                               
                                       lr_aux.aplnum    ,                                               
                                       lr_aux.aplseqnum                                                 
                                                                                                        
            foreach c_cty25g01_005 into lr_aux.aplitmnum 
                   if m_index = 0 then  
                      let m_index = 1   
                   end if               
                  
                  # Carrega os Dados                                                                    
                  let mr_array[m_index].segnom      = lr_aux.segnom                                
                  let mr_array[m_index].itaaplvigincdat   = lr_aux.incvigdat                       
                  let mr_array[m_index].itaaplvigfnldat   = lr_aux.fnlvigdat                       
                  let mr_retorno[m_index].itaciacod = lr_aux.itaciacod                             
                  let mr_retorno[m_index].itaramcod = lr_aux.itaramcod                             
                  let mr_retorno[m_index].aplnum    = lr_aux.aplnum                             
                  let mr_retorno[m_index].aplseqnum = lr_aux.aplseqnum                             
                  let mr_retorno[m_index].aplitmnum = lr_aux.aplitmnum 
                  let mr_retorno[m_index].succod    = lr_aux.succod                         
                  let mr_array_aux[m_index].adnicldat = lr_aux.adnicldat                          
                                                                                                        
                  let mr_array_aux[m_index].documento    = lr_aux.itaciacod    using '<&&'       ,".",  
                                                           lr_aux.itaramcod    using '<<<<&'     ,".",  
                                                           lr_aux.aplnum    using '<<<&&&&&&' ,".",  
                                                           lr_aux.aplseqnum    using '<<<&&'     ,".",  
                                                           lr_aux.aplitmnum using '<<<&&'            
                                                                                                        
                  if lr_aux.incvigdat <= today and                                                
                     lr_aux.fnlvigdat >= today then                                              
                       
                       if lr_aux.itaaplcanmtvcod is null then           
                          let mr_array_aux[m_index].sitdoc = "ATIVA"    
                       else                                             
                          let mr_array_aux[m_index].sitdoc = "CANCELADA"
                       end if                                                                               
                  else                                                                                  
                        let mr_array_aux[m_index].sitdoc = "VENCIDA"                                    
                  end if                                                                                
                                                                                                        
                                                                                                        
                   let m_index = m_index + 1                                                            
                                                                                                        
                   if m_index > 500 then                                                                
                      message "Limite excedido. Foram Encontrados mais de 500 Itens!"                   
                      exit foreach                                                                      
                   end if                                                                               
            end foreach                                                                                 
                                                                                                        
            if m_index > 500 then                                                                       
               exit foreach                                                                             
            end if                                                                                      
                                                                                                        
   end foreach                                                                                          
                                                                                                        
   if m_index > 2 then                                                                                  
       call cty25g01_display()                                                                          
       returning lr_retorno.itaciacod ,                                                              
                 lr_retorno.itaramcod ,                                                              
                 lr_retorno.aplnum    ,                                                              
                 lr_retorno.aplseqnum ,                                                              
                 lr_retorno.aplitmnum ,
                 lr_retorno.succod                                                             
                                                                                                        
       if lr_retorno.aplnum is null then                                                             
          let lr_retorno.erro     = 1                                                                   
       end if                                                                                           
   else                                                                                                 
                                                                                                        
        if m_index = 0 then                                                      
           let lr_retorno.erro      = 1                                         
           let lr_retorno.mensagem  = "Segurado nao Encontrado!"        
        else                                                                     
           let lr_retorno.itaciacod =  mr_retorno[m_index - 1].itaciacod                                
           let lr_retorno.itaramcod =  mr_retorno[m_index - 1].itaramcod                                
           let lr_retorno.aplnum    =  mr_retorno[m_index - 1].aplnum                                
           let lr_retorno.aplseqnum =  mr_retorno[m_index - 1].aplseqnum                                
           let lr_retorno.aplitmnum =  mr_retorno[m_index - 1].aplitmnum 
           let lr_retorno.succod       =  mr_retorno[m_index - 1].succod                            
        end if                                                                                                                                                                   
   
   end if                                                                                               
                                                                                                                                                                                                                
                                                                                                        
   return lr_retorno.itaciacod ,                                                                     
          lr_retorno.itaramcod ,                                                                     
          lr_retorno.aplnum   ,                                                                     
          lr_retorno.aplseqnum ,                                                                     
          lr_retorno.aplitmnum , 
          lr_retorno.succod    ,                                                                    
          lr_retorno.erro      ,                                                                     
          lr_retorno.mensagem                                                                           
end function               

#------------------------------------------------------------------------------
function cty25g01_rec_dados_itau(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod     like datmresitaapl.itaciacod       ,
   itaramcod     like datmresitaapl.itaramcod       ,
   aplnum        like datmresitaapl.aplnum       ,
   aplseqnum     like datmresitaapl.aplseqnum       ,
   aplitmnum     like datmresitaaplitm.aplitmnum
end record

define lr_retorno record
   erro          integer                         ,
   mensagem      char(50)
end record

define lr_retorno_aux record
   erro          integer ,
   mensagem      char(50)
end record

define l_index smallint

 if m_prepare is null or
    m_prepare <> true then
    call cty25g01_prepare()
 end if

 initialize lr_retorno.* ,
            lr_retorno_aux.* to null

 for  l_index  =  1  to  500
 initialize  g_doc_itau[l_index].* to  null
 end  for


 let lr_retorno.erro = 0

 open c_cty25g01_009 using lr_param.itaciacod    ,
                           lr_param.itaramcod    ,
			   lr_param.aplnum       ,
			   lr_param.aplseqnum    ,
			   lr_param.aplitmnum

 whenever error continue
 fetch c_cty25g01_009 into g_doc_itau[1].itaciacod          ,
			                     g_doc_itau[1].itaramcod          ,
		                       g_doc_itau[1].itaaplnum          ,
		                       g_doc_itau[1].aplseqnum          ,
			                     g_doc_itau[1].itaprpnum          ,
		                       g_doc_itau[1].itaaplvigincdat    ,
			                     g_doc_itau[1].itaaplvigfnldat    ,
			                     g_doc_itau[1].segnom             ,
			                     g_doc_itau[1].pestipcod          ,
			                     g_doc_itau[1].segcgccpfnum       ,
		                       g_doc_itau[1].segcgcordnum       ,
			                     g_doc_itau[1].segcgccpfdig       ,
		                       g_doc_itau[1].itaprdcod          ,
			                     g_doc_itau[1].itaempasicod       ,
			                     g_doc_itau[1].itaasisrvcod       ,
			                     g_doc_itau[1].corsus             ,
			                     g_doc_itau[1].seglgdnom          ,
			                     g_doc_itau[1].seglgdnum          ,
			                     g_doc_itau[1].segendcmpdes       ,
			                     g_doc_itau[1].segbrrnom          ,
			                     g_doc_itau[1].segcidnom          ,
			                     g_doc_itau[1].segufdsgl          ,
			                     g_doc_itau[1].segcepnum          ,
			                     g_doc_itau[1].segcepcmpnum       ,
			                     g_doc_itau[1].segresteldddnum    ,
			                     g_doc_itau[1].segrestelnum       ,
			                     g_doc_itau[1].adniclhordat       ,
			                     g_doc_itau[1].itaasiarqvrsnum    ,
			                     g_doc_itau[1].pcsseqnum          ,
			                     g_doc_itau[1].succod             ,
			                     g_doc_itau[1].vipsegflg          ,
			                     g_doc_itau[1].segmaiend          ,
			                     g_doc_itau[1].itaaplitmnum       ,
			                     g_doc_itau[1].itaaplitmsttcod    ,
			                     g_doc_itau[1].rsclclcepnum       ,
                           g_doc_itau[1].rsclgdnom          , 
                           g_doc_itau[1].rsclgdnum          ,
                           g_doc_itau[1].rsccpldes          ,
			                     g_doc_itau[1].rscbrrnom          ,
			                     g_doc_itau[1].rsccidnom          ,
			                     g_doc_itau[1].rscestsgl          ,
			                     g_doc_itau[1].rsccepcod          ,
			                     g_doc_itau[1].rsccepcplcod
			                       

 whenever error stop
 if sqlca.sqlcode <> 0  then
    if sqlca.sqlcode = notfound  then
       let lr_retorno.mensagem = "Dados do Itau nao Encontrado!"
       let lr_retorno.erro     = 1
    else
       let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty25g01_009 ", sqlca.sqlcode
       let lr_retorno.erro     = sqlca.sqlcode
    end if
 end if
 close c_cty25g01_009

 if lr_retorno.erro = 0 then

    # Recupera Plano e Cobertura

    call cty25g01_rec_cobertura_plano(g_doc_itau[1].itaasisrvcod     ,
                             	      g_doc_itau[1].rsrcaogrtcod     ,
				      g_doc_itau[1].itarsrcaosrvcod  ,
                                      g_doc_itau[1].ubbcod           )

    returning g_doc_itau[1].itacbtcod    ,
	      g_doc_itau[1].itaasiplncod ,
	      lr_retorno_aux.erro        ,
	      lr_retorno_aux.mensagem

 end if

 return lr_retorno.erro         ,
        lr_retorno.mensagem

end function
#------------------------------------------------------------------------------
function cty25g01_rec_cobertura_plano(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaasisrvcod    like datkitacbtintrgr.itaasisrvcod    ,
   rsrcaogrtcod    like datkitacbtintrgr.rsrcaogrtcod    ,
   itarsrcaosrvcod like datkitacbtintrgr.itarsrcaosrvcod ,
   ubbcod          like datkitacbtintrgr.ubbcod
end record

define lr_retorno record
       itacbtcod     like datkitacbtintrgr.itacbtcod    ,
       itaasiplncod  like datkitacbtintrgr.itaasiplncod ,
       erro          integer                            ,
       mensagem      char(50)
end record

 if m_prepare is null or
    m_prepare <> true then
    call cty25g01_prepare()
 end if

 initialize lr_retorno.* to null

 let lr_retorno.erro = 0

 open c_cty25g01_010 using lr_param.itaasisrvcod    ,
			   lr_param.rsrcaogrtcod    ,
			   lr_param.itarsrcaosrvcod ,
			   lr_param.ubbcod

 whenever error continue
 fetch c_cty25g01_010 into lr_retorno.itacbtcod     ,
		           lr_retorno.itaasiplncod
 whenever error stop

 if sqlca.sqlcode <> 0  then
    if sqlca.sqlcode = notfound  then
       let lr_retorno.mensagem = "Plano e Cobertura Nao Cadastrada!"
       let lr_retorno.erro     = 1
    else
       let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty25g01_010 ", sqlca.sqlcode
       let lr_retorno.erro     = sqlca.sqlcode
    end if
 end if

 close c_cty25g01_010

 return lr_retorno.itacbtcod     ,
        lr_retorno.itaasiplncod  ,
        lr_retorno.erro          ,
        lr_retorno.mensagem

end function
#------------------------------------------------------------------------------