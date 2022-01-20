###############################################################################
# Nome do Modulo: CTA00M11                                           Pedro    #
#                                                                    Marcelo  #
# Mostra Todas Apolices Encontradas por Nome do Segurado (AUTO)      Dez/1994 #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"
#------------------------------------------------------------------------------
function cta00m11()
#------------------------------------------------------------------------------

 define     t_cta00m11 array[500] of record
  lixo      char (01)              ,
  documento char (30)              ,
  emsdat    like abamapol.emsdat   ,
  viginc    like abamapol.viginc   ,
  vigfnl    like abamapol.vigfnl   ,
  segcod    like abamapol.etpnumdig,
  segnom    like gsakseg.segnom    ,
  vcldes    char (25)              ,
  corsus    like abamcor.corsus    
 end record
 
#---------------Anderson------------------- 
 define l_qtd       smallint
 define l_index     smallint
 define scr_aux     smallint
 define l_index_aux smallint
 define l_disp      smallint
 define l_cont      smallint
 define l_prop      smallint
 define informacao  char (20) 
 define l_pp        smallint
 
 define prop array[20] of record
        prporgpcp like apamcapa.prporgpcp,
        prpnumpcp like apamcapa.prpnumpcp
 end record
 
 define l_prppcp record
       viginc    like apamcapa.viginc  ,
       vigfnl    like apamcapa.vigfnl  ,
       segnumdig like gsakseg.segnumdig,
       segnom    like gsakseg.segnom   ,
       vcldes    char (25)             ,
       corsus    like abamcor.corsus
end record

define w_dcto record
  succod    char(02),
  aplnumdig char(09)
end record

define l_dados_veiculo record
       vcllicnum like apbmveic.vcllicnum ,
       vclmrccod like agbkveic.vclmrccod , 
       vcltipcod like agbkveic.vcltipcod , 
       vclmdlnom like agbkveic.vclmdlnom ,
       vclmrcnom like agbkmarca.vclmrcnom,
       vcltipnom like agbktip.vcltipnom  ,
       vclanofbc like apbmveic.vclanofbc ,
       vclanomdl like apbmveic.vclanomdl ,
       vclchsinc like apbmveic.vclchsinc ,
       vclchsfnl like apbmveic.vclchsfnl
end record
#-------------------------------------------  

 define bd_abamapol record
  etpnumdig like abamapol.etpnumdig,
  emsdat    like abamapol.emsdat   ,
  viginc    like abamapol.viginc   ,
  vigfnl    like abamapol.vigfnl   ,
  aplstt    like abamapol.aplstt
 end record

 define bd_abamcor record
  corsus    like abamcor.corsus
 end record

 define bd_abbmdoc record
  segnumdig like abbmdoc.segnumdig,
  viginc    like abbmdoc.viginc   ,
  vigfnl    like abbmdoc.vigfnl
 end record

 define bd_abamdoc record
  edsnumdig like abamdoc.edsnumdig,
  emsdat    like abamdoc.emsdat
 end record

 define bd_gsakseg record
  segnom    like gsakseg.segnom
 end record

 define bd_abbmveic record
  vclcoddig like abbmveic.vclcoddig
 end record

 define bd_agbkveic record
  vclmdlnom like agbkveic.vclmdlnom,
  vclmrccod like agbkveic.vclmrccod,
  vcltipcod like agbkveic.vcltipcod
 end record

 define bd_agbkmarca record
  vclmrcnom like agbkmarca.vclmrcnom
 end record

 define bd_agbktip record
  vcltipnom like agbktip.vcltipnom
 end record

 define arr_aux integer

 define w_documento char(30)

 define w_dctoalfa record
  succod    char(02),
  aplnumdig char(09),
  itmnumdig char(07),
  edsnumdig char(09)
 end record

	define	w_pf1	integer

	let	arr_aux  =  null
	let	w_documento  =  null
	
#---------------Anderson-------------------- 
	let l_prop = 0   
	let l_pp = 0
#------------------------------------------- 

	for	w_pf1  =  1  to  500
		initialize  t_cta00m11[w_pf1].*  to  null
	end	for

	initialize  bd_abamapol.*  to  null

	initialize  bd_abamcor.*  to  null

	initialize  bd_abbmdoc.*  to  null

	initialize  bd_abamdoc.*  to  null

	initialize  bd_gsakseg.*  to  null

	initialize  bd_abbmveic.*  to  null

	initialize  bd_agbkveic.*  to  null

	initialize  bd_agbkmarca.*  to  null

	initialize  bd_agbktip.*  to  null

	initialize  w_dctoalfa.*  to  null

 if int_flag then
    let int_flag = false
    return
 end if

 let int_flag = false
 
 
 
 if g_index                        =  1 and
    g_dctoarray[g_index].itmnumdig <> 0 then
    let g_documento.succod    = g_dctoarray[g_index].succod
    let g_documento.aplnumdig = g_dctoarray[g_index].aplnumdig
    let g_documento.itmnumdig = g_dctoarray[g_index].itmnumdig

    select edsnumdig
     into  bd_abamdoc.edsnumdig
     from  abamdoc
     where abamdoc.succod    = g_documento.succod    and
           abamdoc.aplnumdig = g_documento.aplnumdig and
           abamdoc.dctnumseq = g_dctoarray[g_index].dctnumseq

    let g_documento.edsnumref = bd_abamdoc.edsnumdig

 else

    let arr_aux = 0
    for arr_aux = 1 to g_index

     if int_flag then
        let arr_aux = 0
        exit for
     end if

     let w_dctoalfa.succod    = g_dctoarray[arr_aux].succod
     let w_dctoalfa.aplnumdig = g_dctoarray[arr_aux].aplnumdig
     let w_dctoalfa.itmnumdig = g_dctoarray[arr_aux].itmnumdig

     let w_documento          = w_dctoalfa.succod clipped, ".",
                                w_dctoalfa.aplnumdig 
    #
    #---- exibe dados de documentos coletivos
    #

     if g_dctoarray[arr_aux].itmnumdig = 0 then
        select edsnumdig,
               emsdat
         into  bd_abamdoc.*
         from  abamdoc
         where abamdoc.succod    = g_dctoarray[arr_aux].succod    and
               abamdoc.aplnumdig = g_dctoarray[arr_aux].aplnumdig and
               abamdoc.dctnumseq = g_dctoarray[arr_aux].dctnumseq

        let w_dctoalfa.edsnumdig = bd_abamdoc.edsnumdig
        let w_documento          = w_documento          clipped, ".",
                                   w_dctoalfa.edsnumdig clipped
        let w_documento          = w_documento clipped,
                                   g_dctoarray[arr_aux].aplqtditm,
                                   " itens"
        let t_cta00m11[arr_aux].documento = w_documento

        select max(viginc),
               max(vigfnl)
         into  bd_abbmdoc.viginc,
               bd_abbmdoc.vigfnl
         from  abbmdoc
         where abbmdoc.succod    = g_dctoarray[arr_aux].succod    and
               abbmdoc.aplnumdig = g_dctoarray[arr_aux].aplnumdig and
               abbmdoc.dctnumseq = g_dctoarray[arr_aux].dctnumseq

        select etpnumdig,
               emsdat,
               viginc,
               vigfnl,
               aplstt
         into  bd_abamapol.*
         from  abamapol
         where abamapol.succod    = g_dctoarray[arr_aux].succod    and
               abamapol.aplnumdig = g_dctoarray[arr_aux].aplnumdig

        select corsus
         into  bd_abamcor.*
         from  abamcor
         where abamcor.succod    = g_dctoarray[arr_aux].succod    and
               abamcor.aplnumdig = g_dctoarray[arr_aux].aplnumdig and
               abamcor.corlidflg = "S"

        select segnom
         into  bd_gsakseg.*
         from  gsakseg
         where gsakseg.segnumdig = bd_abamapol.etpnumdig

        if g_dctoarray[arr_aux].dctnumseq = 1 then
           let t_cta00m11[arr_aux].emsdat = bd_abamapol.emsdat
           let t_cta00m11[arr_aux].viginc = bd_abamapol.viginc
           let t_cta00m11[arr_aux].vigfnl = bd_abamapol.vigfnl
        else
           let t_cta00m11[arr_aux].emsdat = bd_abamdoc.emsdat
           let t_cta00m11[arr_aux].viginc = bd_abbmdoc.viginc
           let t_cta00m11[arr_aux].vigfnl = bd_abbmdoc.vigfnl
        end if

        let t_cta00m11[arr_aux].segcod    = bd_abamapol.etpnumdig
        let t_cta00m11[arr_aux].segnom    = bd_gsakseg.segnom
        let t_cta00m11[arr_aux].corsus    = bd_abamcor.corsus
     else
     
        select segnumdig,
               viginc,
               vigfnl
         into  bd_abbmdoc.*
         from  abbmdoc
         where abbmdoc.succod    = g_dctoarray[arr_aux].succod    and
               abbmdoc.aplnumdig = g_dctoarray[arr_aux].aplnumdig and
               abbmdoc.itmnumdig = g_dctoarray[arr_aux].itmnumdig and
               abbmdoc.dctnumseq = g_dctoarray[arr_aux].dctnumseq

        select edsnumdig,
               emsdat
         into  bd_abamdoc.*
         from  abamdoc
         where abamdoc.succod    = g_dctoarray[arr_aux].succod    and
               abamdoc.aplnumdig = g_dctoarray[arr_aux].aplnumdig and
               abamdoc.dctnumseq = g_dctoarray[arr_aux].dctnumseq

        let w_dctoalfa.edsnumdig = bd_abamdoc.edsnumdig
        let w_documento          = w_documento          clipped, ".",
                                   w_dctoalfa.itmnumdig clipped, ".",
                                   w_dctoalfa.edsnumdig
        let t_cta00m11[arr_aux].documento = w_documento
        let t_cta00m11[arr_aux].emsdat    = bd_abamdoc.emsdat
        let t_cta00m11[arr_aux].viginc    = bd_abbmdoc.viginc
        let t_cta00m11[arr_aux].vigfnl    = bd_abbmdoc.vigfnl
        let t_cta00m11[arr_aux].segcod    = bd_abbmdoc.segnumdig

        select segnom
         into  bd_gsakseg.*
         from  gsakseg
         where gsakseg.segnumdig = bd_abbmdoc.segnumdig

        let t_cta00m11[arr_aux].segnom    = bd_gsakseg.segnom

        call F_FUNAPOL_AUTO(g_dctoarray[arr_aux].succod   ,
                            g_dctoarray[arr_aux].aplnumdig,
                            g_dctoarray[arr_aux].itmnumdig,
                            bd_abamdoc.edsnumdig)
         returning g_funapol.*

        select vclcoddig
         into  bd_abbmveic.*
         from  abbmveic
         where abbmveic.succod    = g_dctoarray[arr_aux].succod    and
               abbmveic.aplnumdig = g_dctoarray[arr_aux].aplnumdig and
               abbmveic.itmnumdig = g_dctoarray[arr_aux].itmnumdig and
               abbmveic.dctnumseq = g_funapol.vclsitatu

        select vclmdlnom,
               vclmrccod,
               vcltipcod
         into  bd_agbkveic.*
         from  agbkveic
         where agbkveic.vclcoddig = bd_abbmveic.vclcoddig

        select vclmrcnom
         into  bd_agbkmarca.*
         from  agbkmarca
         where agbkmarca.vclmrccod = bd_agbkveic.vclmrccod

        select vcltipnom
         into  bd_agbktip.*
         from  agbktip
         where agbktip.vclmrccod = bd_agbkveic.vclmrccod and
               agbktip.vcltipcod = bd_agbkveic.vcltipcod

        let t_cta00m11[arr_aux].vcldes = bd_agbkmarca.vclmrcnom clipped, " ",
                                         bd_agbktip.vcltipnom   clipped, " ",
                                         bd_agbkveic.vclmdlnom

        select corsus
         into  bd_abamcor.*
         from  abamcor
         where abamcor.succod    = g_dctoarray[arr_aux].succod    and
               abamcor.aplnumdig = g_dctoarray[arr_aux].aplnumdig and
               abamcor.corlidflg = "S"

        let t_cta00m11[arr_aux].corsus = bd_abamcor.corsus

     end if

    end for 

#---------------------------Anderson---------------------------     
       
           let l_prop = arr_aux
           let l_index = 1
           let l_disp = 0
           
           if arr_aux = 1 then
              let l_disp = 1 
           end if

        	 call faemc916_segnumdig_por_cpf(g_a_cliente[1].cgccpfnum
        	                                ,g_a_cliente[1].cgcord
        	                                ,g_a_cliente[1].cgccpfdig
        	                                ,g_a_cliente[1].pestip)
        	                       returning l_qtd
        	                       
        	  
  
        	  if l_qtd is not null then
        	  
        	     for l_index_aux = 1 to l_qtd
        	          
        	         call faemc916_proposta_por_segnumdig(g_dctoarray[l_index_aux].segnumdig)
        	                                    returning prop[l_index].prporgpcp
        	                                             ,prop[l_index].prpnumpcp
        	                                             ,l_prppcp.viginc
        	                                             ,l_prppcp.vigfnl

                                                           
                   if prop[l_index].prporgpcp is not null then
                   
                      call faemc916_dados_veiculo(prop[l_index].prporgpcp,prop[l_index].prpnumpcp)
                                        returning l_dados_veiculo.vcllicnum
                                                 ,l_dados_veiculo.vclmrccod
                                                 ,l_dados_veiculo.vclmrccod
                                                 ,l_dados_veiculo.vclmdlnom
                                                 ,l_dados_veiculo.vclmrcnom
                                                 ,l_dados_veiculo.vcltipnom
                                                 ,l_dados_veiculo.vclanofbc
                                                 ,l_dados_veiculo.vclanomdl
                                                 ,l_dados_veiculo.vclchsinc
                                                 ,l_dados_veiculo.vclchsfnl
                                     
                      let l_prppcp.vcldes = l_dados_veiculo.vclmrcnom clipped, " ",
                                            l_dados_veiculo.vcltipnom clipped, " ",
                                            l_dados_veiculo.vclmdlnom
                                            
                      for l_cont = 1 to (l_prop)
                          if l_prppcp.vcldes <> t_cta00m11[l_cont].vcldes then
                             let l_disp = 1
                          end if
                      end for
                   
                     if l_disp = 1 then
                   
                        select distinct(succod) 
                                       ,aplnumdig 
                                   into w_dcto.succod,
                                        w_dcto.aplnumdig
                                   from abbmdoc 
                                  where segnumdig = g_dctoarray[l_index_aux].segnumdig
                                    and aplnumdig = (select max(aplnumdig) 
                                                      from abbmdoc
                                                     where segnumdig = g_dctoarray[l_index_aux].segnumdig) 
                                            
                         select segnom
                           into l_prppcp.segnom
                           from gsakseg
                          where segnumdig = g_dctoarray[l_index_aux].segnumdig
                         
                         select corsus
                           into l_prppcp.corsus 
                           from abamcor
                          where succod = w_dcto.succod 
                            and aplnumdig = w_dcto.aplnumdig 
                            and corlidflg = 'S'                                              
        	                               
        	               let t_cta00m11[arr_aux].documento = prop[l_index].prporgpcp clipped, " ",
        	                                                   prop[l_index].prpnumpcp
                         let t_cta00m11[arr_aux].emsdat = l_prppcp.vigfnl
                         let t_cta00m11[arr_aux].viginc = l_prppcp.viginc
                         let t_cta00m11[arr_aux].vigfnl = l_prppcp.vigfnl
                         let t_cta00m11[arr_aux].segcod = g_dctoarray[l_index_aux].segnumdig 
                         let t_cta00m11[arr_aux].segnom = l_prppcp.segnom
                         let t_cta00m11[arr_aux].vcldes = l_prppcp.vcldes
                         let t_cta00m11[arr_aux].corsus = l_prppcp.corsus
             
                         let g_index = arr_aux
                   
                         let arr_aux = arr_aux + 1 
                         
                         let l_index = l_index + 1
                         
                      end if
                   end if 
               end for
               
            end if    
            
            if g_index = 0  and prop[l_index].prporgpcp is null then
               let arr_aux = 0
            end if                                         	
#--------------------------------------------------------------- 
  

    message " (F17)Abandona, (F8)Seleciona"

    if arr_aux > 0 then

      let arr_aux = g_index
      call set_count(arr_aux)
      
      open window cta00m11 at 4,2 with form "cta00m11"       
                  attribute(form line 1,message line last -1)
                  
      input array t_cta00m11 without defaults from s_cta00m11.* 
      
     #-------------------- 
      before field lixo
     #--------------------
      if l_prop > g_index then
         let informacao = "APOLICE"
      else
         let informacao = "PROPOSTA"
      end if
      display by name informacao attribute(reverse)
      
     #--------------------
      after field lixo
     #--------------------
      let t_cta00m11[g_index].lixo = null
      if l_prop > g_index then
         let informacao = "APOLICE"
      else
         let informacao = "PROPOSTA"
      end if
      display by name informacao attribute(reverse)
      display t_cta00m11[g_index].lixo to s_cta00m11[scr_aux].lixo attribute(normal)
      
      if fgl_lastkey() = fgl_keyval("down") or
           fgl_lastkey() = fgl_keyval("right") or
           fgl_lastkey() = fgl_keyval("enter") then
           if t_cta00m11[g_index + 1].documento is null then
              next field lixo
           end if
       end if
            
     #--------------------
      before row
     #--------------------
        let arr_aux = arr_curr()
        let scr_aux = scr_line()
        let g_index = arr_aux
         
       on key (interrupt)
       

        initialize g_documento.succod   ,
                   g_documento.aplnumdig,
                   g_documento.itmnumdig to null
        exit input

       on key (F8)

       ## Flexvision - Pegar hora com segundos
       let g_monitor.horafnl = current

       let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini

       if  g_monitor.intervalo is null or
           g_monitor.intervalo = ""    or
           g_monitor.intervalo = " "   or
           g_monitor.intervalo < "0:00:00.000" then
           let g_monitor.intervalo = "0:00:00.999"
       end if

       let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                                 "|CTA00M11-> ", g_issk.funmat,
                                 " ->", g_documento.ciaempcod

       let g_monitor.horaini   = g_monitor.horafnl
       call errorlog (g_monitor.txt)
       let g_monitor.txt = " "

        let arr_aux = arr_curr()
        let g_index = arr_aux

        if g_dctoarray[g_index].itmnumdig = 0 then
           call cta00m12()
           let int_flag = false
           exit input
        else
       
           if l_prop > g_index then
         
              select edsnumdig
               into  bd_abamdoc.edsnumdig
               from  abamdoc
               where abamdoc.succod    = g_dctoarray[g_index].succod    and
                     abamdoc.aplnumdig = g_dctoarray[g_index].aplnumdig and
                     abamdoc.dctnumseq = g_dctoarray[g_index].dctnumseq
 
              let g_documento.succod    = g_dctoarray[g_index].succod
              let g_documento.aplnumdig = g_dctoarray[g_index].aplnumdig
              let g_documento.itmnumdig = g_dctoarray[g_index].itmnumdig
              let g_documento.edsnumref = bd_abamdoc.edsnumdig
              exit input
              
           else
                                          
              let l_index = g_index - (l_prop - 1)        
                            
              let g_documento.prporg    = prop[l_index].prporgpcp
              let g_documento.prpnumdig = prop[l_index].prpnumpcp

              exit input
              
           end if
           
        end if
                  
      end input
      
      close window cta00m11

    end if

    let int_flag = false

 end if
 
 

end function #----fim cta00m11


