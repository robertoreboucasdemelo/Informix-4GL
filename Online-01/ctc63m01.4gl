###########################################################################
# Nome do Modulo: ctc63m01                                Humberto Santos #
#                                                         Helde Oliveira  #
# Matriculas Associadas ao Menu                                  Jul/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_prep      smallint
  define m_operacao  char(1)
  define m_errflg    char(1)
  define m_confirma  char(1)
  
  define a_ctc63m01 array[8000] of record
            funmat    like isskfunc.funmat
           ,funnom    like isskfunc.funnom
           ,dptsgl    like isskfunc.dptsgl          
        end record

  define r_ctc63m01 record
         atlemp     like datrc24mnufun.atlemp
        ,atlmat     like datrc24mnufun.atlmat
        ,atldat     like datrc24mnufun.atldat
        ,funnom1    like isskfunc.funnom
        ,point      smallint
       end record

#==============================================================================
function ctc63m01_prepare()
#==============================================================================
 define l_sql char(5000)

 let l_sql =  "select a.funmat "
							     ,",a.funnom "
							     ,",a.dptsgl "
							 ,"from isskfunc a "
							     ,",datrc24mnufun b "
							,"where a.funmat = b.funmat "
							  ,"and a.empcod = b.empcod "
							  ,"and a.usrtip = b.usrtip "
							  ,"and b.mnucod = ? "
							  ,"order by a.funmat"
 prepare pctc63m01001 from l_sql
 declare cctc63m01001 cursor for pctc63m01001
 
  let l_sql = "select atlemp "
								   ,",atlmat "
								   ,",atldat "
							 ,"from datrc24mnufun  "
							,"where funmat  =  ? "
							  ,"and mnucod = ? "
 prepare pctc63m01002 from l_sql
 declare cctc63m01002 cursor for pctc63m01002
 
 
  let l_sql =  "delete datrc24mnufun "
              ,"where funmat  = ? "
                ,"and mnucod =?"
 prepare pctc63m01003 from l_sql
 
 let l_sql =  "select funnom "
               ,"from isskfunc "
              ,"where empcod = ? "
                ,"and funmat = ?"
 prepare pctc63m01004 from l_sql
 declare cctc63m01004 cursor for pctc63m01004
 
 let l_sql = "select sisdes "
              ,"from datkc24mnuacs "
             ,"where mnucod = ?"
 prepare pctc63m01005 from l_sql
 declare cctc63m01005 cursor for pctc63m01005
 
 let l_sql = "delete from datrc24mnufun "
 							 ,"where mnucod =?"
 prepare pctc63m01006 from l_sql
 
 let l_sql = "select a.funmat "
							    ,",a.funnom "							     
							 ,"from isskfunc a "
							     ,",datrc24mnufun b "
							,"where a.funmat = b.funmat "
							  ,"and a.empcod = b.empcod "
							  ,"and a.usrtip = b.usrtip "
							  ,"and b.mnucod = ? "
							  ,"and b.funmat = ?"							  
 prepare pctc63m01007 from l_sql
 declare cctc63m01007 cursor for pctc63m01007


 let m_prep = 1

end function

#==============================================================================
function ctc63m01_input_array(l_mnucod)
#==============================================================================
  define l_index       smallint
  define l_index1      smallint
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint
  define l_aux         smallint
  define l_flag        smallint   #verifica se existe letras no campo codigo
  define l_sisdes      char(50)
  define l_mnucod      like datkc24mnuacs.mnucod
  define l_matricula   decimal(6,0)
  define l_funmat      decimal(6,0)
  define l_funnom      like isskfunc.funnom
  define l_msg1, l_msg2, l_msg3 char(60)

  initialize a_ctc63m01 to null
  initialize r_ctc63m01.* to null
  let int_flag = false
  let l_count = 0
  let l_matricula = null
  

  if m_prep <> 1 then
    call ctc63m01_prepare()
  end if

  open window w_ctc63m01 at 6,2 with form 'ctc63m01'
             attribute(form line first, message line last,comment line last - 1, border)
   
   whenever error continue          
   		open cctc63m01005 using l_mnucod
   		fetch cctc63m01005 into l_sisdes 
    whenever error stop
            

  display 'MATRICULAS ASSOCIADAS AO MENU: ',l_sisdes at 1,1

  while true
    let l_index = 1

    whenever error continue
      open cctc63m01001 using l_mnucod
    whenever error stop

	    foreach cctc63m01001 into a_ctc63m01[l_index].funmat,
	                              	a_ctc63m01[l_index].funnom,
	                              	a_ctc63m01[l_index].dptsgl
	     
	      let a_ctc63m01[l_index].funnom = upshift (a_ctc63m01[l_index].funnom)
       	let l_index = l_index + 1
       	
       	error 'Coletando dados. Por favor aguarde ...'

       if l_index > 3000 then
          error " Limite excedido! Foram encontrados mais de 3000 Matriculas!"
        exit foreach
       end if

    		#message "(F2)-Exclui (F5)-Inclui (F6)-Exclui Todos (F9)-Busca Exclui (F17)-Abandona   "
    		message "(F2)-Exclui (F5)-Inclui (F6)-Exclui Todos (F17)-Abandona  "
    	end foreach
    error ''

    let arr_aux = l_index
    if arr_aux = 1  then
       error "Nao foi encontrado nenhum registro, inclua novos!"
       #message "(F2)-Exclui (F5)-Inclui (F6)-Exclui Todos (F9)-Busca Exclui (F17)-Abandona  "
       message "(F2)-Exclui (F5)-Inclui (F6)-Exclui Todos (F17)-Abandona  "
    end if

    let m_errflg = "N"
    let l_flag = true
    
		call set_count(arr_aux - 1)
    
   	 input array a_ctc63m01 without defaults from s_ctc63m01.*
   	 
   	     #------------------
          before row
         #------------------
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
												
             if arr_aux <= arr_count()  then
                let m_operacao = "p"       
             end if
            
             call ctc63m01_dados_alteracao(a_ctc63m01[arr_aux].funmat, l_mnucod) 
        
        #--------------------
           before insert
        #--------------------
          error "Para incluir utilize F5"
         
              
				 #--------------------
            on key (F5)
         #--------------------
         			 display a_ctc63m01[arr_aux].* to s_ctc63m01[scr_aux].*
               call ctc63m02(l_mnucod)
               
               exit input
               
        
        #--------------------
         before field funmat
        #--------------------
               
                  display a_ctc63m01[arr_aux].* to s_ctc63m01[scr_aux].* attribute(reverse)
                  let l_matricula = a_ctc63m01[arr_aux].funmat               
               
        #--------------------
         after field funmat
        #--------------------
              display a_ctc63m01[arr_aux].* to s_ctc63m01[scr_aux].*
									
                 let a_ctc63m01[arr_aux].funmat = l_matricula
                 display a_ctc63m01[arr_aux].funmat to s_ctc63m01[scr_aux].funmat
       
      #-------------------------------- 
        after row
      #--------------------------------             
         if (fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = fgl_keyval("right")   or
             fgl_lastkey() = fgl_keyval("tab")     or
             fgl_lastkey() = fgl_keyval("return")) and
             arr_aux = arr_count()                 then 
             next field funmat
         end if
             
        #--------------------
         before delete
        #--------------------
               let m_operacao = "d"								 
               initialize m_confirma to null
               
              	    call cts08g01("A"
	                               ,"S"
	                               ,"CONFIRMA A REMOCAO"
	                               ,"DO FUNCIONARIO ?"
	                               ," "
	                               ," " )
	                      returning m_confirma
	                  
	                  if m_confirma = "S"  then
	                     let m_errflg = "N"
	                  
	                     begin work
	                  
	                     whenever error continue
	                     execute pctc63m01003 using a_ctc63m01[arr_aux].funmat, l_mnucod
	                  
	                     if sqlca.sqlcode <> 0  then
	                            error " Erro (", sqlca.sqlcode, ") na remocao do Menu!"
	                  
	                            let m_errflg = "S"
	                            whenever error stop
	                     end if
	                  
	                         whenever error stop
	                         if m_errflg = "S"  then
	                            rollback work
	                         else
	                            commit work
	                         end if
	                         error "Remocao realizada com sucesso!"	                         
	                  else
	                     clear form
	                     error " Remocao Cancelada!"
	                     exit input
	                  end if              
     
               let m_operacao = " "
               initialize a_ctc63m01[arr_aux].*   to null
               display a_ctc63m01[arr_aux].* to s_ctc63m01[scr_aux].* attribute(reverse)     
               
               
          #---------------------
          	 on key (F6)
          #----------------------
          			call cts08g01("A"
	                               ,"S"
	                               ,"DESEJA EXCLUIR TODOS"
	                               ,"OS REGISTROS DO MENU ?"
	                               ," "
	                               ," " )
	                      returning m_confirma
	                  
	                  if m_confirma = "S"  then
	                     let m_errflg = "N"
	                     
	                     begin work
	                  
	                     whenever error continue
	                     execute pctc63m01006 using l_mnucod
	                  
	                     if sqlca.sqlcode <> 0  then
	                            error " Erro (", sqlca.sqlcode, ") na remocao do Menu!"
	                  
	                            let m_errflg = "S"
	                            whenever error stop
	                     end if	                 
	                         whenever error stop
	                         if m_errflg = "S"  then
	                            rollback work
	                         else
	                            commit work
	                         end if
	                         error "Remocao realizada com sucesso!"
	                         exit input
	                  else
		                     clear form
		                     error " Remocao Cancelada!"
		                     exit input		                     
                 		end if                                        

          #--------------------
            on key (accept)
          #--------------------
               continue input   
                       
         { #-------------------
          		on key (F9)
          #-------------------   
          if a_ctc63m01[arr_aux].funmat is null then
             error 'Nao há matricula cadastrada!'
             
	         else                     
	          call ctc63m01_matricula (l_mnucod) 
	              returning l_matricula, l_funnom              
             
             if l_matricula is null then
                 call cts08g01 ("I","N","MATRICULA NAO","LOCALIZADA","","")
                       returning m_confirma 
                       clear form 
                       exit input                     
             else            
	             let l_msg1 = "CONFIRMA A REMOCAO DO" 
	             let l_msg2 = "FUNCIONARIO: " clipped, l_funnom
	             let l_msg3 = "MATRICULA: " clipped, l_matricula clipped, "?" 
	             
            				call cts08g01("A","S","",l_msg1,l_msg2,l_msg3)
	                      returning m_confirma
	                      
							   if m_confirma = "S"  then
	                     let m_errflg = "N"
	                  
	                     begin work
	                  
	                     whenever error continue
	                     execute pctc63m01003 using l_matricula, l_mnucod
	                  
	                     if sqlca.sqlcode <> 0  then
	                            error " Erro (", sqlca.sqlcode, ") na remocao do funcionario!"
	                  
	                            let m_errflg = "S"
	                            whenever error stop
	                     end if
	                  
	                         whenever error stop
	                         if m_errflg = "S"  then
	                            rollback work
	                         else
	                            commit work
	                         end if
	                         display a_ctc63m01[arr_aux].* to s_ctc63m01[scr_aux].*
	                         error "Remocao realizada com sucesso!"		                                                                							
	                         exit input                         
	                  else	                     
	                     error " Remocao Cancelada!"
	                     exit input
	                  end if 	                              
                 end if                                                          
              end if}
          	#--------------------
            on key (interrupt, control-c)
          	#--------------------
              let int_flag = true
              exit input
            end input

			       if int_flag  then
			          let int_flag = false
			          exit while
			       end if

 			end while

  let int_flag = false

 close window w_ctc63m01

end function
          	
     		
     
#==============================================================================
function ctc63m01_dados_alteracao(l_cod, l_menu)
#==============================================================================
define l_cod char(6)
define l_menu smallint

	 initialize r_ctc63m01.* to null
   
   if m_prep <> 1 then
      call ctc63m01_prepare()
   end if
   
   whenever error continue
    open cctc63m01002 using l_cod, l_menu
    fetch cctc63m01002 into r_ctc63m01.atlemp
                             ,r_ctc63m01.atlmat
                             ,r_ctc63m01.atldat
                              
   whenever error stop
  
   call ctc63m01_func(r_ctc63m01.atlemp, r_ctc63m01.atlmat)
        		returning r_ctc63m01.funnom1

   display by name  r_ctc63m01.atldat
                   ,r_ctc63m01.funnom1


end function

#==============================================================================
 function ctc63m01_func(l_empcod, l_funmat) 
#==============================================================================

 define  l_empcod      like   isskfunc.empcod
 define  l_funmat      like   isskfunc.funmat
 define  l_funnom      like   isskfunc.funnom

  if m_prep <> 1 then
    call ctc63m01_prepare()
  end if

 whenever error continue
 open cctc63m01004 using l_empcod,
                           l_funmat

 fetch cctc63m01004 into l_funnom
 whenever error stop
 
  if sqlca.sqlcode = notfound then
    let l_funnom = '    '
  else
    if sqlca.sqlcode <> 0 then
       error 'Erro (',sqlca.sqlcode,') na Busca do nome do funcionario. Avise a Informatica!'
    end if
  end if
 
 close cctc63m01004
 
 let l_funnom = upshift(l_funnom)
 
 return l_funnom

end function


#-=============================================================================
function ctc63m01_matricula(w_mnucod)
#==============================================================================

   define w_mnucod  like datkc24mnuacs.mnucod
   define r_funmat  record  
          matricula decimal(6,0)
   end record
   
   define  l_funnom like   isskfunc.funnom 
   define  l_funmat like   isskfunc.funmat

   options
      prompt line last

   open window w_ctc63m01a at 10,15 with form "ctc63m01a"
        attribute (border, form line 1)

		   display "Matricula" at 01,05
		   clear form
		   let int_flag = false
		
		   input by name r_funmat.*
		
		      before field matricula
		         display by name r_funmat.matricula attribute (reverse)
		
		      after field matricula
		         display by name r_funmat.matricula      
		
		   end input
		   
	 whenever error continue
	 open cctc63m01007 using w_mnucod, r_funmat.matricula  
			  fetch cctc63m01007 into l_funmat
		                           ,l_funnom		                           
	 whenever error stop
	 
	  if sqlca.sqlcode = notfound then
	    let l_funnom = '    '
	  else
	    if sqlca.sqlcode <> 0 then
	       error 'Erro (',sqlca.sqlcode,') na Busca do nome do funcionario. Avise a Informatica!'
	    end if
	  end if
	 close cctc63m01007	
	 
   close window w_ctc63m01a
   
    let l_funnom = upshift(l_funnom)

   return l_funmat
         ,l_funnom

end function


