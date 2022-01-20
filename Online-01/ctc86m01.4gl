###############################################################################
# Nome do Modulo: ctc86m01                                           Andre    #
#                                                                    Pinto    #
# Cadastro de Parametros do Portal do Prestador                      Nov/2008 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
#
###############################################################################
database porto

define mr_ctc86m01 record
	atdsrvorg like datksrvtip.atdsrvorg,
	srvtipabvdes like datksrvtip.srvtipabvdes,
	cpocod    like iddkdominio.cpocod,
	cpodes    like iddkdominio.cpodes
end record
	

function ctc86m01()
	define l_flag smallint
	
	initialize mr_ctc86m01 to null
	
	open window ctc86m01 at 04,02 with form "ctc86m01"
               attribute(prompt line last-2)
	
	menu "Parametros.:"
		command key("c") "Consulta" "Consulta Parametros"
		        clear form
			call ctc86m01_seleciona()
			
		#command key("a") "Alterar" "Altera Parametro Selecionado"
		#	
		
		command key("i") "Inserir" "Insere novo Parametro."
		        clear form
			call ctc86m01_incluir()
			if int_flag then
			        let int_flag = false
			        next option "Consulta"
			end if
			display "" to mensagem
			
		command key("x") "eXcluir" "Exclui parametro Selecionado"
			call ctc86m01_excluir()
				returning l_flag
				
			if l_flag then
			  error "Nao ha parametro para excluir!"
			  next option "Consulta"
			end if
			clear form
			
		command key(interrupt, E) "Encerrar" "Sair"
			exit menu
	end menu
		
	close window ctc86m01	
		
end function


function ctc86m01_excluir()
	define l_resp char(2)
	
	if mr_ctc86m01.atdsrvorg is null and
	   mr_ctc86m01.cpocod is null then
	   	return true
	end if
	
	while true
		prompt "Certeza que deseja exluir o registro? (S/N)" for char l_resp
		if upshift(l_resp) = 'S' or upshift(l_resp) = 'N' then
			exit while
		end if
	end while
	
	if upshift(l_resp) = 'S' then
		delete from datrsrvtipdmn
			where atdsrvorg = mr_ctc86m01.atdsrvorg
			and cpocod = mr_ctc86m01.cpocod
	else
                error "Operacao Cancelada!"
	end if
	
	return false	
end function



function ctc86m01_alterar()
	
end function



function ctc86m01_incluir()
  
  define l_sql char(200),
         l_flg smallint,
         l_mensagem char(80)
  
  let int_flag = false;
  initialize mr_ctc86m01.* to null
  
  let l_mensagem = "F8 - Gravar   Control+C - Cancelar"
  display l_mensagem to mensagem
  
  input by name mr_ctc86m01.cpocod, 
  	        mr_ctc86m01.atdsrvorg without defaults
    	
    before field cpocod
        display by name mr_ctc86m01.cpocod attribute (reverse)

    after  field cpocod
        display by name mr_ctc86m01.cpocod
       
        select cpodes
          into mr_ctc86m01.cpodes
          from iddkdominio
         where cpocod = mr_ctc86m01.cpocod
           and cponom = "tipoparametro"

        if sqlca.sqlcode  =  notfound   then
           error " Tipo de Parametro nao cadastrado!"
        end if
	
	let l_sql = "select cpocod, cpodes",
        	    "  from iddkdominio ",
        	    " where cponom = 'tipoparametro' "
        	    
	if mr_ctc86m01.cpocod is null or 
	   mr_ctc86m01.cpocod = 0 then
		call ofgrc001_popup(10,10,"PARAMETROS","CODIGO","DESCRICAO",
        				'N',l_sql, 
        				"",'D')
        	returning l_flg,
			mr_ctc86m01.cpocod, 
			mr_ctc86m01.cpodes
	end if
	
	display by name mr_ctc86m01.cpocod,
			mr_ctc86m01.cpodes
			
    before field atdsrvorg
        display by name mr_ctc86m01.atdsrvorg attribute (reverse)

    after  field atdsrvorg
        display by name mr_ctc86m01.atdsrvorg
       
        select srvtipabvdes
          into mr_ctc86m01.srvtipabvdes
          from datksrvtip
         where atdsrvorg = mr_ctc86m01.atdsrvorg

        if sqlca.sqlcode  =  notfound   then
           error " Origem nao cadastrado!"
           let mr_ctc86m01.atdsrvorg = null
        end if
        
        let l_sql = "select b.atdsrvorg, b.srvtipabvdes",
        	    "  from datksrvtip b "
        	    
       if fgl_lastkey() != fgl_keyval("up") and
       	  fgl_lastkey() != fgl_keyval("left") and
       	  fgl_lastkey() != fgl_keyval("esc") then
       	  
	        if mr_ctc86m01.atdsrvorg is null or
	        	mr_ctc86m01.atdsrvorg = 0 then
	        	
	        	call ofgrc001_popup(10,10,"ORIGEM DO PARAMETRO","ORIGEM","DESCRICAO",
	        				'N',l_sql, 
	        				"order by b.atdsrvorg",'D')
	        	returning l_flg,
				mr_ctc86m01.atdsrvorg, 
				mr_ctc86m01.srvtipabvdes
	        end if
      end if
      
        display by name mr_ctc86m01.atdsrvorg, 
        		mr_ctc86m01.srvtipabvdes
        		
        next field atdsrvorg			

    on key ("F8")
    	
    	 if mr_ctc86m01.cpocod is null or mr_ctc86m01.cpocod = 0 then
    		Error "Escolha um parametro!"
    		next field cpocod
    	 end if
    
    	 if mr_ctc86m01.atdsrvorg is null or mr_ctc86m01.atdsrvorg = 0 then
    		 error "Escolha uma origem!"
    		 next field atdsrvorg
    	 end if
    	
    	 select 1 from datrsrvtipdmn
    	  where cpocod = mr_ctc86m01.cpocod
    	    and atdsrvorg = mr_ctc86m01.atdsrvorg
    	
    	 if sqlca.sqlcode = 0 then
    		 error "Parametro já Cadastrado!"
    	 else
    		 insert into datrsrvtipdmn
    	  	 values (mr_ctc86m01.atdsrvorg,
    			mr_ctc86m01.cpocod,
    			'tipoparametro')
    		
    		 error "Gravado!"
    		 exit input
    	 end if
    	
    on key (interrupt)
    	 if int_flag then
    		let int_flag = false
    	 end if
    	
     	 error "Operacao cancelada!"
         exit input 
    
  end input
end function



function ctc86m01_seleciona()
	define l_sql char(200),
	       l_flg smallint
  
  let int_flag = false;
  initialize mr_ctc86m01.* to null
  
  input by name mr_ctc86m01.cpocod, 
  	        mr_ctc86m01.atdsrvorg
    	
    before field cpocod
        display by name mr_ctc86m01.cpocod attribute (reverse)

    after  field cpocod
        display by name mr_ctc86m01.cpocod
       
        select cpodes
          into mr_ctc86m01.cpodes
          from iddkdominio
         where cpocod = mr_ctc86m01.cpocod
           and cponom = "tipoparametro"

        if sqlca.sqlcode  =  notfound   then
           error " Tipo de Parametro nao cadastrado!"
        end if
	
	let l_sql = "select cpocod, cpodes",
        	    "  from iddkdominio ",
        	    " where cponom = 'tipoparametro' "
        	    
	if mr_ctc86m01.cpocod is null or 
	   mr_ctc86m01.cpocod = 0 then
		call ofgrc001_popup(10,10,"PARAMETROS","CODIGO","DESCRICAO",
        				'N',l_sql, 
        				"order by cpocod",'D')
        	returning l_flg,
			mr_ctc86m01.cpocod, 
			mr_ctc86m01.cpodes
	end if
	
	display by name mr_ctc86m01.cpocod,
			mr_ctc86m01.cpodes
			
    before field atdsrvorg
        if mr_ctc86m01.cpocod is null then
        	next field cpocod
        end if
        display by name mr_ctc86m01.atdsrvorg attribute (reverse)

    after  field atdsrvorg
        display by name mr_ctc86m01.atdsrvorg
       
        select srvtipabvdes
          into mr_ctc86m01.srvtipabvdes
          from datksrvtip
         where atdsrvorg = mr_ctc86m01.atdsrvorg

        if sqlca.sqlcode  =  notfound   then
           error " Origem nao cadastrado!"
        end if
        
        if mr_ctc86m01.atdsrvorg is not null then
       	   select a.atdsrvorg, b.srvtipabvdes
       	     into mr_ctc86m01.atdsrvorg,  mr_ctc86m01.srvtipabvdes
	     from datrsrvtipdmn a, datksrvtip b 
	    where a.atdsrvorg = mr_ctc86m01.atdsrvorg
	      and a.atdsrvorg = b.atdsrvorg
	   
	   if sqlca.sqlcode  =  notfound   then
               let mr_ctc86m01.atdsrvorg = null
           end if    	
        end if 	   	        	    
        
        if mr_ctc86m01.atdsrvorg is null or
        	mr_ctc86m01.atdsrvorg = 0 then
        
        let l_sql = "select a.atdsrvorg, b.srvtipabvdes         ",
		"	     from datrsrvtipdmn a, datksrvtip b ",
		"	    where a.cpocod =", mr_ctc86m01.cpocod ,
		"	      and a.atdsrvorg = b.atdsrvorg     "	
		
        	call ofgrc001_popup(10,10,"ORIGEM DO PARAMETRO","ORIGEM","DESCRICAO",
        				'N',l_sql, 
        				"order by a.atdsrvorg",'D')
        	returning l_flg,
			mr_ctc86m01.atdsrvorg, 
			mr_ctc86m01.srvtipabvdes
        end if
        
        display by name mr_ctc86m01.atdsrvorg, 
        		mr_ctc86m01.srvtipabvdes			

    on key (interrupt)
        exit input 
  
  end input	
	
end function
