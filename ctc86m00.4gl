###############################################################################
# Nome do Modulo: ctc86m00                                           Andre    #
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

define mr_ctc86m00 record
	prtseq like datkprt.prtseq,
	prtdes like datkprt.prtdes,
	prtitmcod like datkprt.prtitmcod,
	cpocod like iddkdominio.cpocod,
	cpodes like iddkdominio.cpodes,
	prtgrpcod like datkprt.prtgrpcod,
	prtgrpsubcod like datkprt.prtgrpsubcod,
	abrgrpsubflg like datkprt.abrgrpsubflg,
	txticlflg like datkprt.txticlflg,
	obrtxtflg like datkprt.obrtxtflg
end record

define m_flag smallint
define m_sql char(300)

function ctc86m00()
	open window ctc86m00 at 04,02 with form "ctc86m00"
                 attribute(prompt line last-2)	
	
	initialize mr_ctc86m00 to null
	menu "Parametros.:"
		command key("c") "Consulta" "Consulta Parametros"
		    call ctc86m00_limpa()
                    call ctc86m00_consultar()
			
		command key("p") "Proximo" "Proximo Registro"
		    call ctc86m00_proximo()
		    if m_flag then
		        let m_flag = false
		        error "Nao ha parametros nesta direcao!"
		    	next option "Consulta"
		    end if
		     
		command key("a") "Anterior" "Registro Anterior"
                    call ctc86m00_anterior()
		    if m_flag then
		        let m_flag = false
		        error "Nao ha parametros nesta direcao!"
		    	next option "Consulta"
		    end if
		    
		command key("l") "aLtera" "Altera Parametro Selecionado"
		    if mr_ctc86m00.cpocod is null then
		        error "Nao existe parametro seleciondao!"
		        next option "Consulta"
		    else
		        call ctc86m00_alterar()
		    end if
		    
		command key("i") "Insere" "Insere novo Parametro."
		        call ctc86m00_limpa()
		        call ctc86m00_incluir()
	 	    
		command key("x") "eXclui" "Exclui parametro Selecionado"
		     call ctc86m00_excluir()
		         returning m_flag
		         
		     if m_flag then
		        error "Nao ha parametro para excluir!"
		        next option "Consulta"
		     end if
		     
		     call ctc86m00_limpa()
		     
		command key(interrupt, E) "Encerra" "Sair"
		        exit menu
	end menu	
		
	close window ctc86m00	
end function

function ctc86m00_excluir()
    define l_resp char(2)

    if mr_ctc86m00.prtseq is null then
       return true
    end if

    while true
        prompt "Certeza que deseja exluir o registro? (S/N)" for char l_resp
        if upshift(l_resp) = 'S' or upshift(l_resp) = 'N' then
	    exit while
        end if
    end while

    if upshift(l_resp) = 'S' then
        delete from datkprt
         where prtseq = mr_ctc86m00.prtseq
         error "Registro excluido!"
    else
        error "Operacao Cancelada!"
    end if
    
    return false	
end function

function ctc86m00_incluir()
    define l_resp char(1)
    
    input by name mr_ctc86m00.cpocod
                 ,mr_ctc86m00.prtgrpcod
                 ,mr_ctc86m00.prtgrpsubcod
                 ,mr_ctc86m00.abrgrpsubflg
                 ,mr_ctc86m00.txticlflg
                 ,mr_ctc86m00.obrtxtflg 
                 ,mr_ctc86m00.prtdes without defaults
    
        before field cpocod
            display by name mr_ctc86m00.cpocod attribute (reverse)
            
        after field cpocod
            
            select cpodes
              into mr_ctc86m00.cpodes
              from iddkdominio
             where cpocod = mr_ctc86m00.cpocod
               and cponom = "tipoparametro"
            
            if sqlca.sqlcode  =  notfound   then
                error " Tipo de Parametro nao cadastrado!"
                let mr_ctc86m00.cpocod = null
            end if
            
            let m_sql = "select cpocod, cpodes",
                "  from iddkdominio ",
                " where cponom = 'tipoparametro' "
                
            if mr_ctc86m00.cpocod is null or 
               mr_ctc86m00.cpocod = 0 then
                   call ofgrc001_popup(10,10,"PARAMETROS","CODIGO","DESCRICAO",
                                       'N',m_sql, 
                                       "",'D')
                        returning m_flag,
                                  mr_ctc86m00.cpocod, 
                                  mr_ctc86m00.cpodes
            end if
            
            display by name mr_ctc86m00.cpocod,
            	            mr_ctc86m00.cpodes
            
        before field prtdes
            select max(prtseq)+1
              into mr_ctc86m00.prtseq
              from datkprt
            
            if mr_ctc86m00.prtseq is null then
            	let mr_ctc86m00.prtseq = 1
            end if
            
            select max(prtitmcod)+1
              into mr_ctc86m00.prtitmcod
              from datkprt
             where prttip = mr_ctc86m00.cpocod
               and prtgrpcod = mr_ctc86m00.prtgrpcod
            
            if mr_ctc86m00.prtitmcod is null then
            	let mr_ctc86m00.prtitmcod = 1
            end if
            
            display by name mr_ctc86m00.prtitmcod	                
            display by name mr_ctc86m00.prtdes attribute (reverse)
            
        after field prtdes
            display by name mr_ctc86m00.prtdes
            
        before field prtgrpcod
            display by name mr_ctc86m00.prtgrpcod attribute (reverse)
            
        after field prtgrpcod
            display by name mr_ctc86m00.prtgrpcod
            
            if mr_ctc86m00.prtgrpcod <> 1 then        
                select 1 
                  from datkprt
                 where prttip = mr_ctc86m00.cpocod
                   and prtgrpsubcod = mr_ctc86m00.prtgrpcod
                
                if sqlca.sqlcode = 100 then
                    error "Subgrupo nao cadastrado!"
                    let mr_ctc86m00.prtgrpcod = null
                    next field prtgrpcod
                end if	
            end if
            
            if mr_ctc86m00.prtgrpcod is null then
                error "Grupo é obrigatorio!"
                next field prtgrpcod	
            end if
        
        
        before field prtgrpsubcod
            display by name mr_ctc86m00.prtgrpsubcod attribute (reverse)
            
        after field prtgrpsubcod
            display by name mr_ctc86m00.prtgrpsubcod  
                        
        before field abrgrpsubflg
            display by name mr_ctc86m00.abrgrpsubflg attribute (reverse)
            
        after field abrgrpsubflg
            display by name mr_ctc86m00.abrgrpsubflg    
            
            if mr_ctc86m00.abrgrpsubflg is null or  
              (mr_ctc86m00.abrgrpsubflg <> "S" and  
               mr_ctc86m00.abrgrpsubflg <> "N") then
               
                error "Somente S (sim) ou N (nao)!"
                next field abrgrpsubflg
            end if
            
        before field txticlflg
            display by name mr_ctc86m00.txticlflg attribute (reverse)
                        
        after field txticlflg
            display by name mr_ctc86m00.txticlflg    
            
            if mr_ctc86m00.txticlflg is null or  
              (mr_ctc86m00.txticlflg <> "S" and  
               mr_ctc86m00.txticlflg <> "N") then
               
                error "Somente S (sim) ou N (nao)!"
                next field txticlflg
            end if
               
         
        before field obrtxtflg
            display by name mr_ctc86m00.obrtxtflg attribute (reverse)
            
        after field obrtxtflg
            display by name mr_ctc86m00.obrtxtflg                
            
            if  mr_ctc86m00.obrtxtflg is null or
               (mr_ctc86m00.obrtxtflg <> "S" and
                mr_ctc86m00.obrtxtflg <> "N") then
                error "Somente S (sim) ou N (nao)!"
                next field obrtxtflg
            end if    
    
        after input
           while true
               prompt "Deseja realmente fazer esta inclusao? (S/N)" for char l_resp
               if upshift(l_resp) = 'S' or
                  upshift(l_resp) = 'N' then 
                      exit while
               end if
               error "Somente S (sim) ou N (nao)!"
           end while  
           
           if upshift(l_resp) = 'S' then
               insert into datkprt values(mr_ctc86m00.prtseq
               	                         ,mr_ctc86m00.cpocod 
			                 ,mr_ctc86m00.prtgrpcod
			                 ,mr_ctc86m00.prtitmcod			                 
			                 ,mr_ctc86m00.prtgrpsubcod
			                 ,mr_ctc86m00.txticlflg
			                 ,mr_ctc86m00.prtdes
			                 ,mr_ctc86m00.obrtxtflg
			                 ,mr_ctc86m00.obrtxtflg)
               error "Parametro Cadastrado!"
           else
               call ctc86m00_limpa()
               error "Cancelado!"
               exit input               
           end if
    end input
end function


function ctc86m00_alterar()
    define l_resp char(1)
    
    input by name mr_ctc86m00.prtgrpcod
                 ,mr_ctc86m00.prtgrpsubcod
                 ,mr_ctc86m00.abrgrpsubflg
                 ,mr_ctc86m00.txticlflg
                 ,mr_ctc86m00.obrtxtflg 
                 ,mr_ctc86m00.prtdes without defaults
    
        before field prtdes
            display by name mr_ctc86m00.prtdes attribute (reverse)
            
        after field prtdes
            display by name mr_ctc86m00.prtdes
            
        before field prtgrpcod
            display by name mr_ctc86m00.prtgrpcod attribute (reverse)
            
        after field prtgrpcod
            display by name mr_ctc86m00.prtgrpcod
            
            if mr_ctc86m00.prtgrpcod > 1 then        
                select 1 
                  from datkprt
                 where prttip = mr_ctc86m00.cpocod
                   and prtgrpsubcod = mr_ctc86m00.prtgrpcod
                
                if sqlca.sqlcode = 100 then
                    error "Subgrupo nao cadastrado!"
                    let mr_ctc86m00.prtgrpcod = null
                    next field prtgrpcod
                end if	
            end if
            
            if mr_ctc86m00.prtgrpcod is null then
                error "Grupo é obrigatorio!"
                next field prtgrpcod	
            end if
        
        
        before field prtgrpsubcod
            display by name mr_ctc86m00.prtgrpsubcod attribute (reverse)
            
        after field prtgrpsubcod
            display by name mr_ctc86m00.prtgrpsubcod  
                        
        before field abrgrpsubflg
            display by name mr_ctc86m00.abrgrpsubflg attribute (reverse)
            
        after field abrgrpsubflg
            display by name mr_ctc86m00.abrgrpsubflg    
        
        before field txticlflg
            display by name mr_ctc86m00.txticlflg attribute (reverse)
                        
        after field txticlflg
            display by name mr_ctc86m00.txticlflg    
            
            if mr_ctc86m00.txticlflg is null or  
              (mr_ctc86m00.txticlflg <> "S" and  
               mr_ctc86m00.txticlflg <> "N") then
               
                error "Somente S (sim) ou N (nao)!"
                next field txticlflg
            end if
               
         
        before field obrtxtflg
            display by name mr_ctc86m00.obrtxtflg attribute (reverse)
            
        after field obrtxtflg
            display by name mr_ctc86m00.obrtxtflg                
            
            if  mr_ctc86m00.obrtxtflg is null or
               (mr_ctc86m00.obrtxtflg <> "S" and
                mr_ctc86m00.obrtxtflg <> "N") then
                error "Somente S (sim) ou N (nao)!"
                next field obrtxtflg
            end if    
    
        after input
           while true
               prompt "Deseja realmente fazer esta alteracao? (S/N)" for char l_resp
               if upshift(l_resp) = 'S' or
                  upshift(l_resp) = 'N' then 
                      exit while
               end if
               error "Somente S (sim) ou N (nao)!"
           end while  
           
           if upshift(l_resp) = 'S' then
               update datkprt set
                  prtdes = mr_ctc86m00.prtdes
                 ,prtgrpcod = mr_ctc86m00.prtgrpcod
                 ,prtgrpsubcod = mr_ctc86m00.prtgrpsubcod
                 ,abrgrpsubflg = mr_ctc86m00.abrgrpsubflg
                 ,txticlflg = mr_ctc86m00.txticlflg
                 ,obrtxtflg = mr_ctc86m00.obrtxtflg
               where prttip = mr_ctc86m00.cpocod
                 and prtseq = mr_ctc86m00.prtseq
                 
               
               error "Parametro Atualizado!"
           
           else
               call ctc86m00_limpa()
               error "Operacao Cancelada!"
               exit input               
           end if
    end input
end function

function ctc86m00_consultar()
    
    initialize mr_ctc86m00 to null
    
    input by name  mr_ctc86m00.cpocod 
	          ,mr_ctc86m00.prtgrpcod without defaults
	      
        before field cpocod
            display by name mr_ctc86m00.cpocod attribute (reverse)
         
        after field cpocod
            display by name mr_ctc86m00.cpocod
            
            if mr_ctc86m00.cpocod is not null then
                select cpodes
                  into mr_ctc86m00.cpodes
                  from iddkdominio
                 where cponom = 'tipoparametro'
                   and cpocod = mr_ctc86m00.cpocod
            else
                let m_sql = "select cpocod, cpodes",
        	    "  from iddkdominio ",
        	    " where cponom = 'tipoparametro' "
        	
                call ofgrc001_popup(10,10,"PARAMETROS","CODIGO","DESCRICAO",
	                            'N',m_sql,"order by cpocod",'D')
                     returning m_flag,
                               mr_ctc86m00.cpocod, 
                               mr_ctc86m00.cpodes
            end if
            
            display by name mr_ctc86m00.cpocod, 
                            mr_ctc86m00.cpodes


        before field prtgrpcod
            display by name mr_ctc86m00.prtgrpcod attribute (reverse)
         
        after field prtgrpcod
            display by name mr_ctc86m00.prtgrpcod
            
            let m_sql = "select datkprt.prtseq, "
                        ,"      datkprt.prtitmcod, "
                        ,"      datkprt.prtdes, "
                        ,"      datkprt.prtgrpcod, "
                        ,"      datkprt.prtgrpsubcod, "
                        ,"      datkprt.abrgrpsubflg, "
                        ,"      datkprt.txticlflg, "
                        ,"      datkprt.obrtxtflg "
                        ," from datkprt "
                        ,"where prttip = ", mr_ctc86m00.cpocod
             
             if mr_ctc86m00.prtgrpcod is not null then
                 let m_sql = m_sql clipped, " and prtgrpcod = ", mr_ctc86m00.prtgrpcod
             end if
             
             prepare pctc86m001 from m_sql
             declare cctc86m001 scroll cursor for pctc86m001
             
             open cctc86m001
             fetch first cctc86m001 into mr_ctc86m00.prtseq
                                        ,mr_ctc86m00.prtitmcod
                                        ,mr_ctc86m00.prtdes
                                        ,mr_ctc86m00.prtgrpcod
                                        ,mr_ctc86m00.prtgrpsubcod
                                        ,mr_ctc86m00.abrgrpsubflg
                                        ,mr_ctc86m00.txticlflg
                                        ,mr_ctc86m00.obrtxtflg
	    
	    if sqlca.sqlcode = 0 then
	        display by name mr_ctc86m00.cpocod
	                       ,mr_ctc86m00.cpodes
	                       ,mr_ctc86m00.prtitmcod
                               ,mr_ctc86m00.prtdes
                               ,mr_ctc86m00.prtgrpcod
                               ,mr_ctc86m00.prtgrpsubcod
                               ,mr_ctc86m00.abrgrpsubflg
                               ,mr_ctc86m00.txticlflg
                               ,mr_ctc86m00.obrtxtflg
            else
               if sqlca.sqlcode = 100 then
                   error "Nao foi encontrado parametros cadastrados para este tipo!"
                   exit input
               else
                   error "erro: ",sqlca.sqlcode
               end if            
            end if                                                  
                            
     end input              
			    
end function

function ctc86m00_proximo()
    whenever error continue
    fetch next cctc86m001 into mr_ctc86m00.prtseq
                                      ,mr_ctc86m00.prtitmcod
	                              ,mr_ctc86m00.prtdes
	                              ,mr_ctc86m00.prtgrpcod
	                              ,mr_ctc86m00.prtgrpsubcod
	                              ,mr_ctc86m00.abrgrpsubflg
	                              ,mr_ctc86m00.txticlflg
	                              ,mr_ctc86m00.obrtxtflg
    whenever error stop
                                  
    if sqlca.sqlcode = 0 then
        display by name mr_ctc86m00.prtitmcod
                        ,mr_ctc86m00.prtdes
                        ,mr_ctc86m00.prtgrpcod
                        ,mr_ctc86m00.prtgrpsubcod
                        ,mr_ctc86m00.abrgrpsubflg
                        ,mr_ctc86m00.txticlflg
                        ,mr_ctc86m00.obrtxtflg
    else
        if sqlca.sqlcode = 100 then
            error "Nao existe registros nesta direcao!"
        else
            error "Nao foi selecionado nenhum registro!" 
            let m_flag = true           
        end if     
    end if
end function

function ctc86m00_anterior()
    whenever error continue
    fetch previous cctc86m001 into mr_ctc86m00.prtseq
                                      ,mr_ctc86m00.prtitmcod
	                              ,mr_ctc86m00.prtdes
	                              ,mr_ctc86m00.prtgrpcod
	                              ,mr_ctc86m00.prtgrpsubcod
	                              ,mr_ctc86m00.abrgrpsubflg
	                              ,mr_ctc86m00.txticlflg
	                              ,mr_ctc86m00.obrtxtflg
    whenever error stop
                                  
    if sqlca.sqlcode = 0 then
        display by name mr_ctc86m00.prtitmcod
                        ,mr_ctc86m00.prtdes
                        ,mr_ctc86m00.prtgrpcod
                        ,mr_ctc86m00.prtgrpsubcod
                        ,mr_ctc86m00.abrgrpsubflg
                        ,mr_ctc86m00.txticlflg
                        ,mr_ctc86m00.obrtxtflg
    else
        if sqlca.sqlcode = 100 then
            error "Nao existe registros nesta direcao!"
        else
            error "Nao foi selecionado nenhum registro!" 
            let m_flag = true           
        end if     
    end if
end function

function ctc86m00_limpa()
    initialize mr_ctc86m00 to null
    clear form
end function

function ctc86m00_fecha()
     close cctc86m001
end function
