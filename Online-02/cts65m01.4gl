#---------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                            #
#...........................................................................#
#Sistema       : Central 24hs                                               #
#Modulo        : cts65m01                                                   #
#Analista Resp : Ligia Mattge                                               #
#...........................................................................#
#Desenvolvimento: Ligia Mattge / Fornax                                     #
#Liberacao      : agosto/2012                                               #
#---------------------------------------------------------------------------#
#                                                                           #
#                         * * * Alteracoes * * *                            #
#                                                                           #
#Data       Autor Fabrica  Origem     Alteracao                             #
#---------- -------------- ---------- --------------------------------------#
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_cts65m01_prep smallint
define m_contabiliza   smallint

#--------------------------#
function cts65m01_prepare()
#--------------------------#
 define l_sql char(600)

 let l_sql = ' select b.grpivcqtd               '
         ,  '  from datrntzasipln b             '
         ,  '  where b.asiplncod = ?            '
         ,  '  and b.grpcod      = ?            '
 prepare p_cts65m01_008 from l_sql               
 declare c_cts65m01_008 cursor for p_cts65m01_008
 
 
 let l_sql = ' select count(*) '                  
              ,' from datmsrvre '
             ,' where atdsrvnum = ?'             
             ,' and atdsrvano = ? '
             ,' and socntzcod = ? '                          

 prepare p_cts65m01_002 from l_sql
 declare c_cts65m01_002 cursor for p_cts65m01_002
 
 let l_sql =  ' select grpcod '
             ,' from datrntzasipln '
             ,' where  '
             ,' socntzcod = ? '
             ,' and asiplncod = ? '

 prepare p_cts65m01_003 from l_sql
 declare c_cts65m01_003 cursor for p_cts65m01_003
 
 
 let l_sql = ' select socntzcod '                   
             ,' from datrntzasipln '  
             ,' where  '                         
             ,' socntzcod <> ? '                  
             ,' and grpcod = ? '
             ,' and asiplncod = ? '              
                                                 
 prepare p_cts65m01_004 from l_sql               
 declare c_cts65m01_004 cursor for p_cts65m01_004  
  
 let l_sql = ' select ctonumflg  ',              
             '  from datkresitagrp ',            
             '  where  ',                        
             '  grpcod = ? '                     
 prepare p_cts65m01_005 from l_sql               
 declare c_cts65m01_005 cursor for p_cts65m01_005
 
   let l_sql = " select atdetpcod ",
                " from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdsrvseq = (select max(atdsrvseq) ",
                                    " from datmsrvacp ",
                                   " where atdsrvnum = ? ",
                                     " and atdsrvano = ?) "
  prepare p_cts65m01_006 from l_sql
  declare c_cts65m01_006 cursor for p_cts65m01_006
  
   let l_sql = " select a.atdsrvnum ,"
              ,"       a.atdsrvano "
              ," from datmservico a, "
              ,"      datmligacao b, "
              ,"      datrligitaaplitm d "
              ," where a.atdsrvnum = b.atdsrvnum "
              ," and a.atdsrvano = b.atdsrvano "
              ," and b.lignum    = d.lignum "
              ," and d.itaciacod = ? "
              ," and d.itaramcod = ? "
              ," and d.itaaplnum = ? "
              ," and d.itaaplitmnum = ? " 
              ," and b.c24astcod not in ('ALT','CON','CAN') "                         
 prepare p_cts65m01_007 from l_sql
 declare c_cts65m01_007 cursor for p_cts65m01_007
  
  
  
          
  
 let m_cts65m01_prep = true

end function


#----------------------------------------#
function cts65m01_qtd_servico(lr_entrada)
#----------------------------------------#
 define lr_entrada record
    itaciacod    like datmresitaapl.itaciacod
   ,itaramcod    like datmresitaapl.itaramcod   
   ,aplnum       like datmresitaapl.aplnum      
   ,aplitmnum    like datmresitaaplitm.aplitmnum
   ,grpcod       like datkresitagrp.grpcod
   ,socntzcod    like datksocntz.socntzcod  
   ,c24astcod    like datkassunto.c24astcod 
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd integer
       ,l_resultado smallint
       ,l_mensagem  char(60)
       ,l_sql       char(600)

 if m_cts65m01_prep is null or
    m_cts65m01_prep <> true then        
    call cts65m01_prepare()
 end if

 initialize lr_servico to null

 let l_qtd         = 0
 let l_resultado   = null
 let l_mensagem    = null
 let m_contabiliza = false   

 if lr_entrada.c24astcod = 'R11' or   ##ligia fornax set/2012
    lr_entrada.c24astcod = 'R12' then 
     let l_sql = " select a.atdsrvnum,"               
                ,"        a.atdsrvano "                
                ," from datmservico a, "               
                ,"      datmligacao b, "               
                ,"      datrligitaaplitm d "           
                ," where a.atdsrvnum = b.atdsrvnum "   
                ," and a.atdsrvano = b.atdsrvano "     
                ," and b.lignum    = d.lignum "        
                ," and d.itaciacod = ? "               
                ," and d.itaramcod = ? "               
                ," and d.itaaplnum = ? "               
                ," and d.itaaplitmnum = ? "            
                ," and b.c24astcod in ('R11','R12')"
  else 
  	if lr_entrada.c24astcod = 'R66' or
  		 lr_entrada.c24astcod = 'R67' then
     
       let l_sql = " select a.atdsrvnum,"               
                  ,"        a.atdsrvano "                
                  ," from datmservico a, "               
                  ,"      datmligacao b, "               
                  ,"      datrligitaaplitm d "           
                  ," where a.atdsrvnum = b.atdsrvnum "   
                  ," and a.atdsrvano = b.atdsrvano "     
                  ," and b.lignum    = d.lignum "        
                  ," and d.itaciacod = ? "               
                  ," and d.itaramcod = ? "               
                  ," and d.itaaplnum = ? "               
                  ," and d.itaaplitmnum = ? "            
                  ," and b.c24astcod in ('R66','R67')"
    else
      let l_sql = " select a.atdsrvnum,"               
               ,"        a.atdsrvano "                 
               ," from datmservico a, "                
               ,"      datmligacao b, "                
               ,"      datrligitaaplitm d "            
               ," where a.atdsrvnum = b.atdsrvnum "    
               ," and a.atdsrvano = b.atdsrvano "                         
               ," and b.lignum    = d.lignum "                     
               ," and d.itaciacod = ? "                
               ," and d.itaramcod = ? "                
               ," and d.itaaplnum = ? "                
               ," and d.itaaplitmnum = ? "             
               ," and b.c24astcod = ? " 
    end if               
  end if            
 
  prepare p_cts65m01_001 from l_sql                
  declare c_cts65m01_001 cursor for p_cts65m01_001 
  
                
    
    ##-- Obter os servicos dos atendimentos realizados pela apolice --##
    if lr_entrada.aplnum is not null then             
      if lr_entrada.c24astcod is not null then                  
         
         if lr_entrada.c24astcod = 'R11' or   ##ligia fornax set/2012
            lr_entrada.c24astcod = 'R12' or 
            lr_entrada.c24astcod = 'R66' or
            lr_entrada.c24astcod = 'R67' then                              
            open c_cts65m01_001 using lr_entrada.itaciacod
                                     ,lr_entrada.itaramcod
                                     ,lr_entrada.aplnum
                                     ,lr_entrada.aplitmnum                                     
                                     
         else                      
           open c_cts65m01_001 using lr_entrada.itaciacod
                                    ,lr_entrada.itaramcod 
                                    ,lr_entrada.aplnum   
                                    ,lr_entrada.aplitmnum
                                    ,lr_entrada.c24astcod
           
         
         end if                                                                                                 
       
         foreach c_cts65m01_001 into lr_servico.*            
          
          call cts65m01_consiste_servico(lr_servico.*,
                                         lr_entrada.socntzcod,
                                         lr_entrada.c24astcod)
          returning l_resultado 
               
            if l_resultado = 1 then
               let l_qtd  = l_qtd + 1
            else
               if l_resultado = 3 then
                  error l_mensagem sleep 2
                  exit foreach
               end if
            end if
         end foreach
         close c_cts65m01_001
      else        
         open c_cts65m01_007 using lr_entrada.itaciacod
                                  ,lr_entrada.itaramcod
                                  ,lr_entrada.aplnum
                                  ,lr_entrada.aplitmnum                                  
         foreach c_cts65m01_007 into lr_servico.*  
          
          call cts65m01_consiste_servico(lr_servico.*,
                                         lr_entrada.socntzcod,
                                         lr_entrada.c24astcod)
               returning l_resultado                                     
            
            if l_resultado = 1 then
               let l_qtd  = l_qtd + 1
            else
               if l_resultado = 3 then
                  error l_mensagem sleep 2
                  exit foreach
               end if
            end if
         end foreach
         close c_cts65m01_007      
      end if    
    end if 
    
    #---------------------------------------------
    # Se for Contabilizado Por Grupo faz Acerto                  
    #---------------------------------------------
  
    if m_contabiliza then
        call cts65m01_acerta_qtd_grupo(g_doc_itau[1].itaasisrvcod,
                                       lr_entrada.grpcod         ,
                                       l_qtd                     )       
        returning l_qtd 
    end if
                                        
         

 return l_qtd

end function


#---------------------------------------------#
function cts65m01_consiste_servico(lr_entrada)
#---------------------------------------------#
 define lr_entrada record
    atdsrvnum like datmservico.atdsrvnum
   ,atdsrvano like datmservico.atdsrvano
   ,socntzcod like datksocntz.socntzcod  
   ,c24astcod like datkassunto.c24astcod  
 end record

 define l_resultado smallint
       ,l_mensagem  char(60)
       ,l_atdetpcod like datmsrvacp.atdetpcod
       ,l_qtde      integer
       ,l_qtde_grp  integer

 initialize l_resultado to  null
 initialize l_mensagem  to  null
 initialize l_atdetpcod to  null
 let l_qtde = 0
 let l_qtde_grp  = 0

 if not m_cts65m01_prep then
    call cts65m01_prepare()
 end if
 
  
 ##-- Obtem a ultima etapa do servico --##
 let l_atdetpcod = cts65m01_ultima_etapa(lr_entrada.atdsrvnum
                                        ,lr_entrada.atdsrvano)
 
 ##-- Para servico a residencia, conta servicos Liberados(1) e Acionados(3)      
 
 if lr_entrada.c24astcod <> "R66" and 
 	  lr_entrada.c24astcod <> "R67" then 
 	
 	  if  l_atdetpcod   <> 1   and     
 	      l_atdetpcod   <> 3  then     
 	     
 	      let l_resultado = 0           
 	      return l_resultado            
 	  end if                           
 	       
 	                                                                                  
 else                                        
 
    if l_atdetpcod <> 1   and        
    	 l_atdetpcod <> 2   and         
       l_atdetpcod <> 3   and        
       l_atdetpcod <> 4   then      
     
         let l_resultado = 0
         return l_resultado       
    end if                         
 
 end if
  
 whenever error continue 
 open c_cts65m01_002 using lr_entrada.atdsrvnum,
                           lr_entrada.atdsrvano,
                           lr_entrada.socntzcod
 fetch c_cts65m01_002 into l_qtde
 whenever error stop  
 
 call cts65m01_servicos_grupo(lr_entrada.atdsrvnum,
                              lr_entrada.atdsrvano,
                              lr_entrada.socntzcod )
 returning l_qtde_grp     
 
 
 if l_qtde_grp > 0 then  
    let l_qtde = l_qtde + l_qtde_grp
 end if    
 

 if l_qtde = 0 then 
    let l_resultado = 0
 else 
    let l_resultado = 1
 end if                                   
 close c_cts65m01_002
 
 return l_resultado

end function

#---------------------------------------------------
function cts65m01_servicos_grupo(lr_param) 
#---------------------------------------------------

define lr_param record
    atdsrvnum like datmservico.atdsrvnum
   ,atdsrvano like datmservico.atdsrvano
   ,socntzcod like datksocntz.socntzcod  
end record

define l_qtde integer
define l_qtde_grp integer 
define l_socntzcod   like datksocntz.socntzcod                                       
define l_grpcod      like datkresitagrp.grpcod
define l_contabiliza char(1)
      ,l_atdetpcod like datmsrvacp.atdetpcod
      

let l_qtde = 0 
let l_qtde_grp = 0 

let l_grpcod = null
let l_contabiliza = "N"


whenever error continue 
open c_cts65m01_003 using lr_param.socntzcod,g_doc_itau[1].itaasisrvcod
fetch c_cts65m01_003 into l_grpcod
whenever error stop 

whenever error continue
    open c_cts65m01_005 using l_grpcod
    fetch c_cts65m01_005 into l_contabiliza
whenever error stop 

if l_contabiliza = "S" then 

   let m_contabiliza = true
   
   whenever error continue 
   open c_cts65m01_004 using lr_param.socntzcod,
                             l_grpcod,
                             g_doc_itau[1].itaasisrvcod
   whenever error stop 
   
   let l_socntzcod = null
   foreach c_cts65m01_004 into l_socntzcod 
                                                                                                                   
    whenever error continue 
    let l_qtde_grp = 0
    open c_cts65m01_002 using lr_param.atdsrvnum,
                              lr_param.atdsrvano,
                              l_socntzcod
    fetch c_cts65m01_002 into l_qtde_grp
    whenever error stop 
    
    
    
    if l_qtde_grp > 0 then 
       let l_qtde = l_qtde + l_qtde_grp
       return l_qtde
    end if 
    
   end foreach 
   
       
end if    


return l_qtde

end function   


#--------------------------------------#
function cts65m01_ultima_etapa(l_param)
#--------------------------------------#

define l_param        record
 atdsrvnum          like datmsrvacp.atdsrvnum,
 atdsrvano          like datmsrvacp.atdsrvano
end record

define tmp_atdetpcod    like datmsrvacp.atdetpcod

 if m_cts65m01_prep is null or
    m_cts65m01_prep <> true then
    call cts65m01_prepare()
 end if

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     tmp_atdetpcod  =  null

        let     tmp_atdetpcod  =  null

let    tmp_atdetpcod = 0

 open c_cts65m01_006 using l_param.atdsrvnum,
                         l_param.atdsrvano,
                         l_param.atdsrvnum,
                         l_param.atdsrvano
 fetch c_cts65m01_006 into tmp_atdetpcod
 close c_cts65m01_006

return tmp_atdetpcod

end function   

#---------------------------------------------------  
function cts65m01_acerta_qtd_grupo(lr_param)            
#---------------------------------------------------   
                                                       
define lr_param record                                 
    asiplncod like datrntzasipln.asiplncod              
   ,grpcod    like datrntzasipln.grpcod  
   ,qtd       smallint                           
end record

define lr_retorno record                      
    grpivcqtd like datrntzasipln.grpivcqtd   
end record   

initialize lr_retorno.* to null                              

   #---------------------------------------------
   # Recupera o Limite do Grupo
   #---------------------------------------------
   
   open c_cts65m01_008 using lr_param.asiplncod,
                             lr_param.grpcod   
                             
   fetch c_cts65m01_008 into lr_retorno.grpivcqtd 
   close c_cts65m01_008 
   
   if lr_param.qtd > lr_retorno.grpivcqtd then
   	  let lr_param.qtd = lr_retorno.grpivcqtd  
   end if	  

   return lr_param.qtd 
   
end function                                           