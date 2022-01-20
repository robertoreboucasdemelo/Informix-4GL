###############################################################################
# Nome do Modulo: CTA00M02                                           Marcelo  #
#                                                                             #
# Pesquisa apolice por licenca - Automovel (ramo 31)                 NOV/1994 #
###############################################################################
# Data                                                                        #
# ---------  --------------                                                   #
# 30/11/2015 chamado 721738                                                   #
#-----------------------------------------------------------------------------#
###############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------------
function cta00m02(par_vcllicnum)
#------------------------------------------------------------------------------

 define par_vcllicnum like abbmveic.vcllicnum

 define parametros record
  succod     like abbmveic.succod   ,
  ramcod     like gtakram.ramcod    ,
  aplnumdig  like abbmveic.aplnumdig,
  itmnumdig  like abbmveic.itmnumdig,
  prporgpcp  like apamcapa.prporgpcp,
	prpnumpcp  like apamcapa.prpnumpcp
 end record

 define cta00m02 array[200] of record
  marca      char(1),
  succod    like abbmveic.succod   ,
  ramcod    like gtakram.ramcod    ,
  aplnumdig like abbmveic.aplnumdig,
  itmnumdig like abbmveic.itmnumdig,
  viginc    like abamapol.viginc   ,
  vigfnl    like abamapol.vigfnl   ,
  segnom    like gsakseg.segnom    
 end record

 define cta00m02_aux array[200] of record
  aplstt      like abamapol.aplstt,
  tipdoc      char(30)
 end record
 
 {define cta00m02_tela array[200] of record
   marca char(1)
 end record}

 define d_abbmveic record
  succod    like abbmveic.succod,
  aplnumdig like abbmveic.aplnumdig,
  itmnumdig like abbmveic.itmnumdig,
  dctnumseq like abbmveic.dctnumseq
 end record

 define d_abamapol record
  etpnumdig like abamapol.etpnumdig,
  aplstt    like abamapol.aplstt   ,
  viginc    like abamapol.viginc   ,
  vigfnl    like abamapol.vigfnl
 end record
 
#---------------Humberto-------------------
 define r_retorno record
	 	prporgpcp    like apamcapa.prporgpcp,
		prpnumpcp    like apamcapa.prpnumpcp,
		succod       like apamcapa.succod,    
    viginc       like apamcapa.viginc,
    vigfnl       like apamcapa.vigfnl, 
		segnom       like gsakseg.segnom,
    dddcod       like gsakend.dddcod,
    teltxt       like gsakend.teltxt    
 end record
#-------------------------------------------

 define d_gsakseg  record
      segnom       like gsakseg.segnom
 end record

 define ws   record
  confirma   char (01),
  erro       smallint,
  dtresol86  date,
  emsdat     like abamdoc.emsdat
 end record

 define msg record
    linha1            char(40),
    linha2            char(40),
    linha3            char(40),
    linha4            char(40)
 end record

 define arr_aux  integer
 define situacao smallint

	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  cta00m02[w_pf1].*      to  null
		initialize  cta00m02_aux[w_pf1].*  to  null
	end	for

	initialize  parametros.*  to  null

	initialize  d_abbmveic.*  to  null

	initialize  d_abamapol.*  to  null

	initialize  d_gsakseg.*  to  null
	initialize  r_retorno.*  to null

  initialize g_dctoarray  to null
  initialize parametros.* to null

 let int_flag = false
 let g_index  = 0
 let arr_aux  = 0
 let situacao = 0
 

 message " Aguarde, pesquisando..." attribute (reverse)

 select grlinf[01,10] into ws.dtresol86
   from datkgeral
   where grlchv='ct24resolucao86'
 # chamado 721738
 declare c_cta00m02_001 cursor for
   select abbmveic.succod,
          abbmveic.aplnumdig,
          abbmveic.itmnumdig,
          max(abbmveic.dctnumseq)
    from  abbmveic
         ,abamapol   ---> PSI-223689 - Alta disponibilidade
    where abbmveic.vcllicnum = par_vcllicnum                 
      and abamapol.succod    = abbmveic.succod                 
     and abamapol.aplnumdig = abbmveic.aplnumdig                 
    group by abbmveic.succod, abbmveic.aplnumdig, abbmveic.itmnumdig                 
                 
 foreach c_cta00m02_001 into   d_abbmveic.*
   let arr_aux = arr_aux + 1
                 
   if arr_aux > 200 then
      let arr_aux = 200
      error " Limite excedido, existem mais de 200 veiculos c/ a mesma licenca!"
   end if

   call F_FUNAPOL_ULTIMA_SITUACAO
          (d_abbmveic.succod,d_abbmveic.aplnumdig,d_abbmveic.itmnumdig)
           returning g_funapol.*

   if g_funapol.resultado = "O"   then
      let cta00m02[arr_aux].itmnumdig = d_abbmveic.itmnumdig

      select etpnumdig,
             aplstt   ,
             viginc   ,
             vigfnl
       into  d_abamapol.*
       from  abamapol
       where abamapol.succod    = d_abbmveic.succod    and
             abamapol.aplnumdig = d_abbmveic.aplnumdig

      let cta00m02[arr_aux].succod     = d_abbmveic.succod
      let cta00m02[arr_aux].aplnumdig  = d_abbmveic.aplnumdig
      let cta00m02[arr_aux].itmnumdig  = d_abbmveic.itmnumdig
      let cta00m02[arr_aux].viginc     = d_abamapol.viginc
      let cta00m02[arr_aux].vigfnl     = d_abamapol.vigfnl
      let cta00m02_aux[arr_aux].aplstt = d_abamapol.aplstt
      let cta00m02_aux[arr_aux].tipdoc = 'APOLICE'      
     
      select emsdat into ws.emsdat
           from abamdoc
          where succod    = d_abbmveic.succod
            and aplnumdig = d_abbmveic.aplnumdig
            and edsnumdig = 0

      if ws.emsdat >= ws.dtresol86 then
         let cta00m02[arr_aux].ramcod = 531
      else
         let cta00m02[arr_aux].ramcod = 31
      end if
      select segnom
        into d_gsakseg.*
        from gsakseg
       where gsakseg.segnumdig        = d_abamapol.etpnumdig
       let cta00m02[arr_aux].segnom    = d_gsakseg.segnom
                
       if (cta00m02_aux[arr_aux].aplstt = "A" or
           cta00m02[arr_aux].vigfnl > today) then 
           if cta00m02_aux[arr_aux].aplstt = "A" and
              cta00m02[arr_aux].vigfnl > today then          
              let situacao = 1
           end if
       end if                          
   end if              		    	 	    
 end foreach

 message " "

    if situacao = 0 then
				call faemc916_proposta_por_placa (par_vcllicnum)				  
					returning r_retorno.prporgpcp,
				         		r_retorno.prpnumpcp,
				         		r_retorno.viginc,
				         		r_retorno.vigfnl,
				         		r_retorno.succod
				 
				if r_retorno.prporgpcp is not null then				              		
					call faemc916_estipulante(r_retorno.prporgpcp, r_retorno.prpnumpcp)
					   returning r_retorno.segnom,
					             r_retorno.dddcod,
					             r_retorno.teltxt 
					             				    
					if arr_aux = 0 then
					   let parametros.prporgpcp = r_retorno.prporgpcp
	           let parametros.prpnumpcp = r_retorno.prpnumpcp
	           let cta00m02[arr_aux].aplnumdig  = null            
					else 			                 
						 let arr_aux = arr_aux + 1 
						 let cta00m02[arr_aux].succod     = r_retorno.prporgpcp
						 let cta00m02[arr_aux].aplnumdig  = r_retorno.prpnumpcp
						 let cta00m02[arr_aux].itmnumdig  = null
						 let cta00m02[arr_aux].viginc     = r_retorno.viginc
						 let cta00m02[arr_aux].vigfnl     = r_retorno.vigfnl
						 let cta00m02_aux[arr_aux].aplstt = ""
						 let cta00m02[arr_aux].segnom     = r_retorno.segnom
						 let cta00m02[arr_aux].ramcod     = null	
						 let cta00m02_aux[arr_aux].tipdoc = 'PROPOSTA'						    
					end if 
			  end if     				                   
	  end if 	 		       
 
 if arr_aux > 1 then
    open window cta00m02 at 09,02 with form "cta00m02" attribute(form line 1,message line last - 1)
         
    message " (F17)Abandona, (F8)Seleciona" 

    call set_count(arr_aux)
    
     input array cta00m02 without defaults from s_cta00m02.*
     
         before field marca
          
          let arr_aux = arr_curr()
           display by name cta00m02_aux[arr_aux].tipdoc attribute (reverse)
             
           after  field marca

	       if fgl_lastkey() = fgl_keyval("left")  or
	          fgl_lastkey() = fgl_keyval("up")    then
	          else
	             if cta00m02_aux[arr_aux+1].tipdoc is null or
	                cta00m02_aux[arr_aux+1].tipdoc < 0     then
	                error " There are no more rows in the direction ",
	                      "you are going "
	                next field marca
	             end if
	          end if          
   
      on key (F8)      
         let arr_aux              = arr_curr()
         let parametros.succod    = cta00m02[arr_aux].succod
         let parametros.ramcod    = cta00m02[arr_aux].ramcod
         let parametros.aplnumdig = cta00m02[arr_aux].aplnumdig
         let parametros.itmnumdig = cta00m02[arr_aux].itmnumdig
         let parametros.prporgpcp = null
         let parametros.prpnumpcp = null
         let ws.erro = 0         
                          
				 if cta00m02[arr_aux].ramcod is null and 
				    cta00m02[arr_aux].itmnumdig is null then
				    let parametros.prporgpcp = cta00m02[arr_aux].succod
            let parametros.prpnumpcp = cta00m02[arr_aux].aplnumdig
						let parametros.aplnumdig = null  
         end if
							 			
         if cta00m02_aux[arr_aux].aplstt = "C" or
            cta00m02[arr_aux].vigfnl < today then
            if cta00m02_aux[arr_aux].aplstt = "C" and
               cta00m02[arr_aux].vigfnl < today then
               let ws.erro = 3
               let msg.linha1 = "Esta apolice esta vencida e cancelada"
               let msg.linha2 = "Procure uma apolice vigente e ativa"
            else
               if cta00m02_aux[arr_aux].aplstt = "C" then
                  let ws.erro = 2
                  let msg.linha1 = "Esta apolice esta cancelada"
                  let msg.linha2 = "Procure uma apolice ativa"
               else
                  let ws.erro = 1
                  let msg.linha1 = "Esta apolice esta vencida"
                  let msg.linha2 = "Procure uma apolice vigente"
               end if               	            
            end if
            
            	let msg.linha3 = "Ou consulte a supervisao."
              let msg.linha4 = "Deseja prosseguir?"      			
                                  
            call cts08g01("C","S",msg.linha1,msg.linha2,msg.linha3,msg.linha4)
                 returning ws.confirma

            if ws.confirma = "S" then
               let ws.erro = 0
            end if

         end if

         if ws.erro = 0 then
            exit input
         end if

      on key (interrupt)
         let int_flag = false
                 
         	if situacao = 1 then
				      let r_retorno.prporgpcp = null
				      let r_retorno.prpnumpcp = null
			    end if
			      
         initialize parametros.* to null	         
         exit input         
    end input         
		close window cta00m02					
 else        
    if arr_aux <> 0 then       
       let parametros.succod    = cta00m02[arr_aux].succod
       let parametros.ramcod    = cta00m02[arr_aux].ramcod
       let parametros.aplnumdig = cta00m02[arr_aux].aplnumdig
       let parametros.itmnumdig = cta00m02[arr_aux].itmnumdig
       let parametros.prporgpcp = r_retorno.prporgpcp
       let parametros.prpnumpcp = r_retorno.prpnumpcp             
    end if    
 end if
            
 return  parametros.*
 
 let int_flag = false

end function #---- fim cta00m02
