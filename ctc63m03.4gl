###########################################################################
# Nome do Modulo: ctc63m03                               Humberto Santos  #
# Rastreamento Ligacoes                                          Jan/2012 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
# 20/01/2012    Anderson                     Adicionado no input data,    #
#               Doblinski                    hora inicial, final e enviado#                                                                        #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep      smallint
define porcentagem smallint

define r_ctc63m03 array[1000] of record
       seta           char(1)         
      ,s_lignum       like datmligacao.lignum
      ,c24astcod      like datmligacao.c24astcod
      ,s_lighorfnl    like datmligacao.lighorfnl
      ,msgenverrdes   like datmmsgenvrst.msgenverrdes
      ,enviado        char(3)  
end record

define r_ligacao record
       lignum    like datmligacao.lignum
      ,ligdat    like datmligacao.ligdat
      ,lighorinc like datmligacao.lighorinc
      ,lighorfnl like datmligacao.lighorfnl
      ,envio     char(1)
      ,s_status  smallint
end record

define r_ctc63m03_aux array[1000] of record
			 msgenverrcod   like datmmsgenvrst.msgenverrcod 
			,emaendnom      like datmmsgenvrst.emaendnom
      ,cpnmdunom      like datmmsgenvrst.cpnmdunom
      ,pcscod         like datmmsgenvrst.pcscod
      ,cpodes         like datkdominio.cpodes 
      ,s_ligdat       like datmligacao.ligdat
end record 

define param_cponom	  like datkdominio.cponom

#===============================================  
function ctc63m03_prepare()
#===============================================

define l_sql char(1000)                                          
                                                                           
   
   let l_sql = " select cpodes "
                 ,"from datkdominio "
                ,"where cponom = ? "
                  ,"and cpocod = ?"
   prepare p_ctc63m03_002 from l_sql
   declare c_ctc63m03_002 cursor for p_ctc63m03_002
     
 let m_prep = 1
    
end function


#=============================================
function ctc63m03_prepare_pesquisa()
#=============================================
define l_sql char(1000) 

     let l_sql = " select a.lignum "
                     ,",a.c24astcod "
                     ,",a.lighorfnl "
                     ,",b.msgenverrdes "
                     ,",b.msgenverrcod "
                     ,",b.cpnmdunom "
                     ,",b.emaendnom "
                     ,",b.pcscod "
                     ,",a.ligdat "
                 ,"from datmligacao a "
                     ,",datmmsgenvrst b "
                ,"where a.lignum = b.lignum "
      
      if r_ligacao.lignum is not null then
         let l_sql = l_sql clipped,"  and a.lignum = ",r_ligacao.lignum
      else
      	 if r_ligacao.envio is not null then
      	    let l_sql = l_sql clipped," and b.msgenverrcod = '",r_ligacao.s_status,"' "
      	 end if
         let l_sql = l_sql clipped," and a.ligdat = '",r_ligacao.ligdat,"' "
         let l_sql = l_sql clipped," and a.lighorinc >= '",r_ligacao.lighorinc,"' "
         let l_sql = l_sql clipped," and a.lighorfnl <= '",r_ligacao.lighorfnl,"' "
         let l_sql = l_sql clipped," order by a.lighorfnl desc "
      end if
      
      prepare p_ctc63m03_001  from l_sql                
      declare c_ctc63m03_001  cursor for p_ctc63m03_001  

end function


#==============================================
function ctc63m03()
#==============================================
define l_index smallint
define arr_aux smallint
define scr_aux smallint
  
let param_cponom = 'proc_rastreamento'

initialize r_ctc63m03 to null
initialize r_ligacao to null

if m_prep <> 1 then
    call ctc63m03_prepare()
end if
      open window w_ctc63m03 at 4,2 with form 'ctc63m03'
		        attribute (border,form line 1) 		                    
  
  input by name r_ligacao.lignum 
               ,r_ligacao.ligdat
               ,r_ligacao.lighorinc
               ,r_ligacao.lighorfnl
               ,r_ligacao.envio
        without defaults

      #--------------------------------      
        before field lignum
      #--------------------------------      
          display r_ligacao.lignum to lignum attribute(reverse)
          
      #--------------------------------      
        after field lignum
      #-------------------------------- 
          display r_ligacao.lignum to lignum
          
          if r_ligacao.lignum is not null then
             initialize r_ligacao.ligdat
                       ,r_ligacao.lighorinc
                       ,r_ligacao.lighorfnl
                       ,r_ligacao.envio
             to null
             
             display by name r_ligacao.ligdat
                            ,r_ligacao.lighorinc
                            ,r_ligacao.lighorfnl
                            ,r_ligacao.envio
             
             error 'Pesquisando Ligacoes ...' 
             call ctc63m03_pesquisa()    
             
             next field lignum
          end if
              
      #--------------------------------      
        before field ligdat
      #--------------------------------
        display r_ligacao.ligdat to ligdat attribute(reverse)
      
      #--------------------------------      
        after field ligdat
      #--------------------------------
        display r_ligacao.ligdat to ligdat
        
        if r_ligacao.ligdat is null then
           let r_ligacao.ligdat = today
           display r_ligacao.ligdat to ligdat
        end if          
      #--------------------------------      
        before field lighorinc
      #--------------------------------
        display r_ligacao.lighorinc to lighorinc attribute(reverse)
      
      #--------------------------------      
        after field lighorinc
      #--------------------------------
        display r_ligacao.lighorinc to lighorinc 
        
        if r_ligacao.lighorinc is null then
           let r_ligacao.lighorfnl = extend(current, hour to minute)
           let r_ligacao.lighorinc = extend(r_ligacao.lighorfnl -1 UNITS HOUR, hour to minute) 
           display by name r_ligacao.lighorinc
        else
        
           if r_ligacao.lighorinc != extend(r_ligacao.lighorfnl -1 UNITS HOUR, hour to minute) then
              let r_ligacao.lighorfnl = extend(r_ligacao.lighorinc +1 UNITS HOUR, hour to minute)
              display by name r_ligacao.lighorfnl
           end if 
           
           if r_ligacao.lighorfnl is null then
              let r_ligacao.lighorfnl = extend(r_ligacao.lighorinc +1 UNITS HOUR, hour to minute)
           end if
        end if
      
      #--------------------------------      
        before field lighorfnl
      #--------------------------------
        display r_ligacao.lighorfnl to lighorfnl attribute(reverse)
      
      #--------------------------------      
        after field lighorfnl
      #--------------------------------
        display r_ligacao.lighorfnl to lighorfnl
        
        if r_ligacao.lighorfnl != extend(r_ligacao.lighorinc +1 UNITS HOUR, hour to minute) then
           let r_ligacao.lighorinc = extend(r_ligacao.lighorfnl -1 UNITS HOUR, hour to minute)
           display by name r_ligacao.lighorinc
        end if
      
      #--------------------------------      
        before field envio
      #--------------------------------
        display r_ligacao.envio to envio attribute(reverse)
      
      #--------------------------------      
        after field envio
      #--------------------------------
        display r_ligacao.envio to envio
        
         if fgl_lastkey() <> fgl_keyval("up") and     
            fgl_lastkey() <> fgl_keyval("left") then
            
            if r_ligacao.envio = "S" then
               let r_ligacao.s_status = 0
            else
               let r_ligacao.s_status = 1
            end if
        
            if r_ligacao.envio <> "S" and r_ligacao.envio <> "N" then               
               error " Preencha apenas S ou N."
               let r_ligacao.envio = " "
               next field envio
            end if
            
            error 'Pesquisando Ligacoes ...' 
            call ctc63m03_pesquisa()
            
            next field lignum
        end if

      #-------------------------------- 
        on key (interrupt, control-c)
          exit input
       
  end input     
       
close window w_ctc63m03        
       
end function
       
#-------------------- Doblinski ---------------------------         

          
#==============================================================================
function ctc63m03_pesquisa()
#==============================================================================
define l_index     smallint
define arr_aux     smallint
define scr_aux     smallint
define l_return    smallint


  call ctc63m03_prepare_pesquisa()
 
  call ctc63m03_pega_dados()
     returning l_index
     
  let arr_aux = l_index
  let int_flag = false
  
 error ' '
 
 while true
 
   if l_index = 1 then
     error 'Ligacao nao localizada'
     initialize r_ligacao.* to null
     display by name r_ligacao.lignum    
                    ,r_ligacao.ligdat    
                    ,r_ligacao.lighorinc 
                    ,r_ligacao.lighorfnl 
                    ,r_ligacao.envio   
     exit while
   end if
   
  call set_count(l_index - 1)   
  
      display by name porcentagem      
         
  		input array r_ctc63m03 without defaults from s_ctc63m03.* 		        
					
				 #------------------
       		before row
      	 #------------------
        	let arr_aux = arr_curr()
        	let scr_aux = scr_line()						   
			
				 #--------------------
       		before field seta
      	 #--------------------
      		display r_ctc63m03[arr_aux].* to s_ctc63m03[scr_aux].* attribute(reverse)
      	      	
      		display by name r_ctc63m03_aux[arr_aux].emaendnom                                     
        	display by name r_ctc63m03_aux[arr_aux].cpnmdunom  
        	display by name r_ctc63m03_aux[arr_aux].cpodes
          display by name r_ctc63m03_aux[arr_aux].s_ligdat
      	
      	 #--------------------
       		after field seta
       	 #--------------------
        	let r_ctc63m03[arr_aux].seta = null
      		display r_ctc63m03[arr_aux].* to s_ctc63m03[scr_aux].* attribute(normal)

      	
      		if fgl_lastkey() = fgl_keyval("down") or
           	 fgl_lastkey() = fgl_keyval("right") or
           	 fgl_lastkey() = fgl_keyval("return") then
             if r_ctc63m03[arr_aux + 1].s_lignum is null then
                next field seta
           	 end if
        	end if

        	if fgl_lastkey() = fgl_keyval("up") or
           	 fgl_lastkey() = fgl_keyval("left") then
           	 if arr_aux -1 <= 0 then
              	next field seta
           	 end if
        	end if    
      	
      	 #-----------------------------	
       	  on key (interrupt,control-c)
      	 #-------------------- --------                       
            initialize r_ctc63m03 to null                      
            let int_flag = true
            initialize r_ligacao.lignum to null
            clear form
            exit input 
                   
   		end input  
   		
   		if int_flag  then
          let int_flag = false
          exit while
       end if
       
   end while     
   
   let int_flag = false  
end function

#==============================================================================
function ctc63m03_pega_dados()
#==============================================================================
define l_index smallint
define cont    smallint

 initialize r_ctc63m03 to null
 initialize r_ctc63m03_aux to null
 
 let cont = 0
 let l_index = 1
open c_ctc63m03_001
  foreach c_ctc63m03_001 into r_ctc63m03[l_index].s_lignum
                             ,r_ctc63m03[l_index].c24astcod    
                             ,r_ctc63m03[l_index].s_lighorfnl  
                             ,r_ctc63m03[l_index].msgenverrdes     
                             ,r_ctc63m03_aux[l_index].msgenverrcod
                             ,r_ctc63m03_aux[l_index].cpnmdunom
                             ,r_ctc63m03_aux[l_index].emaendnom 
                             ,r_ctc63m03_aux[l_index].pcscod 
                             ,r_ctc63m03_aux[l_index].s_ligdat   
             
      if  r_ctc63m03_aux[l_index].msgenverrcod <> 0 then
       		let r_ctc63m03[l_index].enviado = "Nao"
      else
          let r_ctc63m03[l_index].enviado = "Sim"
          let cont = cont + 1
      end if               
     
      open c_ctc63m03_002 using param_cponom
                               ,r_ctc63m03_aux[l_index].pcscod
                                          
        foreach c_ctc63m03_002 into r_ctc63m03_aux[l_index].cpodes                      
        
      end foreach   
       
      let l_index = l_index + 1    
          
      
     if l_index > 1000 then
        error '  Pesquisa limitada a 1000 registros!  ' sleep 2
        exit foreach
     end if
                                 
  end foreach

  let porcentagem = (100 * cont) / (l_index-1)

return l_index

end function