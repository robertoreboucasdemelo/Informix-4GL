#----------------------------------------------------------------------------#  
# Porto Seguro Cia Seguros Gerais                                            #  
#............................................................................#  
# Sistema........: Auto e RE - Itau Seguros                                  #  
# Modulo.........: cts12g06                                                  #  
# Objetivo.......: Lista de Naturezas a Residencia do Plano Itau RE          #  
# Analista Resp. : Ligia Mattge                                              #  
# PSI            :                                                           #  
#............................................................................#  
# Desenvolvimento: Ligia Mattge                                              #  
# Liberacao      : ago/2012                                                  #  
#............................................................................#    
database porto                                       
                                                     
globals "/homedsa/projetos/geral/globals/glct.4gl"  

define m_cts12g06_prep  smallint       

define mr_retorno array[500] of record                                                 
       socntzcod    like  datksocntz.socntzcod  ,                                       
       socntzdes    like  datksocntz.socntzdes  ,
       utzlmtqtd    integer                     , 
       grplmtqtd    integer                     ,
       grpcod       like datkresitagrp.grpcod   ,
       lmicob       smallint                    
end record

define mr_servicos   array[500] of record             
       socntzcod     like datksocntz.socntzcod 
      ,socntzdes     char(50)
      ,utiliz        integer
      ,limite        integer #like rgfrclsemrsrv.atdqtd 
      ,saldo         integer 
      ,grpcod        integer     
      ,lmicob        smallint
end record

define mr_servicos_agrupados   array[500] of record              
       socntzcod     like datksocntz.socntzcod         
      ,socntzdes     char(50)                          
      ,utiliz        integer                           
      ,limite        integer #like rgfrclsemrsrv.atdqtd
      ,saldo         integer                           
      ,grpcod        integer                           
      ,lmicob        smallint                          
end record                                             

define m_grupos record 
       multiplo  char(1)
      ,socntzcod like datksocntz.socntzcod
end record 

define m_asiplncod like datkresitaasipln.asiplncod
      
       
#------------------------------------------------------------------------------
function cts12g06_prepare()
#------------------------------------------------------------------------------

define l_sql char(10000)

  let l_sql = ' select a.socntzcod               '
          ,  '       , a.socntzdes               '
          ,  '       , b.ntzivcqtd               '          
          ,  '       , b.grpivcqtd               '
          ,  '       , b.grpcod                  '          
          ,  '       , b.ntzvlr                  '             
          ,  '   from datksocntz a               '
          ,  '      , datrntzasipln b            '
          ,  '  where a.socntzcod  = b.socntzcod '
          ,  '    and b.asiplncod = ?            '
          ,  '  order by b.grpcod,a.socntzcod    '
 prepare p_cts12g06_001 from l_sql                                             
 declare c_cts12g06_001 cursor for p_cts12g06_001  
 
 
 let l_sql = ' select asiplncod  ',
             '  from datkresitaasipln ',
             '  where  ',
             '  srvcod = ? '
 prepare p_cts12g06_002 from l_sql                                             
 declare c_cts12g06_002 cursor for p_cts12g06_002

 let l_sql = ' select ctonumflg  ',             
             '  from datkresitagrp ',
             '  where  ',
             '  grpcod = ? '
 prepare p_cts12g06_003 from l_sql                                             
 declare c_cts12g06_003 cursor for p_cts12g06_003

   
 let l_sql = " select count(*) ",                            
             " from datrgrpntz a, datksocntz b , datrempgrp c ", 
             " where a.socntzcod = b.socntzcod ",                
             " and  a.socntzgrpcod = c.socntzgrpcod ",           
             " and b.socntzstt    = 'A'",                        
             " and c.empcod = ? ",                          
             " and c.c24astcod = ?" ,                       
             " and b.socntzcod = ?"                
 prepare p_cts12g06_004 from l_sql                            
 declare c_cts12g06_004 cursor for p_cts12g06_004
   

   
 let l_sql = ' select grpcod '
            ,' from datrntzasipln '
            ,' where socntzcod = ? '
            ,' and asiplncod = ? '
 prepare p_cts12g06_005 from l_sql                                             
 declare c_cts12g06_005 cursor for p_cts12g06_005
 
 let l_sql = ' select launumflg  ',              
             '  from datkresitagrp ', 
             '  where  ',                          
             '  grpcod = ? '                     
 prepare p_cts12g06_006 from l_sql               
 declare c_cts12g06_006 cursor for p_cts12g06_006
 
 let l_sql = ' select desnom  ',              
             '  from datkresitagrp ',            
             '  where  ',                        
             '  grpcod = ? '                     
 prepare p_cts12g06_007 from l_sql               
 declare c_cts12g06_007 cursor for p_cts12g06_007
 
 
let l_sql = ' select socntzcod '                   
           ,' from datrntzasipln '              
           ,' where grpcod  = ?  '             
           ,' and asiplncod = ?  '               
prepare p_cts12g06_008 from l_sql               
declare c_cts12g06_008 cursor for p_cts12g06_008

  
 let l_sql = ' select socntzdes  ',              
             '  from datksocntz ',            
             '  where  ',                        
             '  socntzcod = ? '                     
 prepare p_cts12g06_009 from l_sql               
 declare c_cts12g06_009 cursor for p_cts12g06_009
 
 let l_sql = ' select itaasstipcod  ',              
             '  from datkassunto ',               
             '  where  ',                        
             '  c24astcod = ? '                  
 prepare p_cts12g06_010 from l_sql               
 declare c_cts12g06_010 cursor for p_cts12g06_010
 
 let m_cts12g06_prep = true
  
 
end function

#------------------------------------------------------------------------------ 
function cts12g06_rec_natureza(lr_param)             
                           
#------------------------------------------------------------------------------ 

define lr_param record
   srvcod like datkresitaasipln.srvcod
end record

define l_index        integer 


for  l_index  =  1  to  500                     
   initialize  mr_retorno[l_index].* to  null       
end  for     
                                   

if m_cts12g06_prep is null or        
   m_cts12g06_prep <> true then   
   call cts12g06_prepare()  
end if           

   let l_index        = 1
   let m_asiplncod    = null    
   
   
       whenever error continue 
       open c_cts12g06_002 using lr_param.srvcod
       fetch c_cts12g06_002 into m_asiplncod
       whenever error stop 
                
       
       open c_cts12g06_001 using m_asiplncod 
       foreach c_cts12g06_001 into mr_retorno[l_index].socntzcod  ,  
                                   mr_retorno[l_index].socntzdes  ,
                                   mr_retorno[l_index].utzlmtqtd  ,
                                   mr_retorno[l_index].grplmtqtd  ,
                                   mr_retorno[l_index].grpcod     ,
                                   mr_retorno[l_index].lmicob     
                                  
                       
          
          if cty46g00_bloqueia_linha_marrom(mr_retorno[l_index].grpcod        ,       
          	                                g_doc_itau[1].itaprdcod           ,        
          	                                g_doc_itau[1].itaasisrvcod        ,        
          	                                g_doc_itau[1].itaaplvigincdat)    then   
                                                                                 
             continue foreach   
          end if                                                                 
       
       
       
       let l_index = l_index + 1
       
       end foreach
      
   return l_index
   
end function          

#--------------------------------------------------------------------------
function cts12g06(lr_param)
#--------------------------------------------------------------------------

   define lr_param record 
          itaasisrvcod  like datmresitaaplitm.srvcod          
   end record        

   define lr_retorno   record
          sqlcode      integer
         ,msgerro      char(500)       
         ,socntzcod    like datksocntz.socntzcod
   end record                   
   
   define t_cts12g06b    array[500] of record 
          socntzcod     like datksocntz.socntzcod
         ,socntzdes     char(50)                 
         ,utiliz        smallint
         ,limite        smallint
         ,saldo         smallint
         ,lmicob        smallint 
         ,flggrp        char(1)
   end record 
         
   define l_limite    decimal(15,5)
         ,l_saldo     integer
         ,l_util      decimal(15,5)
         ,l_index     integer   
         ,l_null      char(1)   
         ,l_flag      smallint
         ,l_qtde      smallint 
         ,arr_aux     integer
         ,l_existe    smallint
         ,l_tela      integer 
         ,l_tela2     integer
         ,l_contabiliza char(1)
         ,l_mens      char(300)
   
   let l_limite   = 0 
   let l_saldo    = 0 
   let l_util     = 0 
   let l_index    = 0 
   let l_null     = null 
   let l_qtde     = 0
   let arr_aux    = 0        
   let l_existe   = false      
   let l_contabiliza = 'N'   
   let l_mens = null 
      
   
   initialize lr_retorno.* to null
   
   # inicializando array modular de naturezas
   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null       
   end for                
   
   # inicializando array tela de naturezas
   for l_tela  =  1  to  500
       initialize  t_cts12g06b[l_tela].* to  null       
   end for       
   
      
   #------------------
   # Busca naturezas
   #------------------  
   call cts12g06_carrega_array(lr_param.itaasisrvcod)
        returning l_qtde
          
   let l_tela = 0 
   let l_tela2 = 0 
  
    
  for l_index = 1 to l_qtde
                                
     
     whenever error continue                                                        
       open c_cts12g06_003 using mr_servicos[l_index].grpcod 
       fetch c_cts12g06_003 into l_contabiliza                                      
     whenever error stop                                              
                    
     if (mr_servicos[l_index].grpcod = mr_servicos[l_index - 1].grpcod or
         mr_servicos[l_index].grpcod = 0) and l_contabiliza = "S" then                          
        
        let t_cts12g06b[l_tela2].socntzcod = mr_servicos[l_index].grpcod        
        let t_cts12g06b[l_tela2].flggrp = 'S'
        
        
        
        call cts12g06_busca_descricao_grupo(mr_servicos[l_index].grpcod)
        returning  t_cts12g06b[l_tela2].socntzdes
                        
        
        let t_cts12g06b[l_tela2].utiliz    = mr_servicos[l_index].utiliz    
        let t_cts12g06b[l_tela2].lmicob    = mr_servicos[l_index].lmicob            
        let t_cts12g06b[l_tela2].limite    = mr_servicos[l_index].limite    
        let t_cts12g06b[l_tela2].saldo     = t_cts12g06b[l_tela2].limite  -  
                                             t_cts12g06b[l_tela2].utiliz     
  
     else
          
          let l_tela2 = l_tela2 + 1          
          let t_cts12g06b[l_tela2].flggrp = 'N'
          let t_cts12g06b[l_tela2].socntzcod = mr_servicos[l_index].socntzcod 
          let t_cts12g06b[l_tela2].socntzdes = mr_servicos[l_index].socntzdes 
          let t_cts12g06b[l_tela2].utiliz    = mr_servicos[l_index].utiliz    
          let t_cts12g06b[l_tela2].lmicob    = mr_servicos[l_index].lmicob    
          let t_cts12g06b[l_tela2].utiliz    = mr_servicos[l_index].utiliz    
          let t_cts12g06b[l_tela2].limite    = mr_servicos[l_index].limite    
          let t_cts12g06b[l_tela2].saldo     = t_cts12g06b[l_tela2].limite  -  
                                               t_cts12g06b[l_tela2].utiliz    
                    
     
     end if
     
  
  
  end for                    
   
   #--------------
   # Abre a tela 
   #--------------
   open window w_cts12g06 at 07,4 with form "cts12g06"
              attribute(form line 1, border)                    
                                                            
   let int_flag = false                                    
                                                               
   message "(F8)Detalhe grupo                        "
     
   call set_count(l_tela2)

   display array t_cts12g06b to s_cts12g06.*                     
         
      
      on key (F8)                                                              
         
         let arr_aux = arr_curr()                  
                            
           if t_cts12g06b[arr_aux].flggrp = 'S' then 
              call cts12g06_busca_naturezas_detalhe(t_cts12g06b[arr_aux].socntzcod,
                                                    lr_param.itaasisrvcod)                              
           else                    
              error "Natureza não pertence ao um grupo de assistencia"
              if l_mens is not null then  
                 error l_mens 
              end if                      
           end if    
              
            #exit display   
                        
      
      on key (interrupt,control-c,f17)                
            exit display                             
         
   end display    
   
   close window  w_cts12g06
      
      
   let int_flag = false  
   
   return 
   
end function 

#--------------------------------------------------------------------------
function cts12g06_carrega_array(lr_param)
#--------------------------------------------------------------------------

   define lr_param record 
          srvcod       like datkresitaasipln.srvcod     
   end record        

   define l_index integer,
          l_qtde  integer,
          l_contabiliza char(1),
          l_utiliz_grp integer,          
          l_grp  like datkresitagrp.grpcod,
          l_laudo char(1)
          
           
   
   let l_index = 0 
   let l_qtde = 0 
   let l_contabiliza = null
   let l_utiliz_grp = 0
   let l_grp = null 
   let l_laudo = null 

   # inicializando array modular de naturezas
   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null       
   end for 
   
   call cts12g06_rec_natureza(lr_param.srvcod)                                           
        returning l_qtde                      
   
   
   #-----------------
   # Carrega array tela  
   #-----------------
   # Retira o ultimo indice devido ao foreach utilizado na função.
   let l_qtde = l_qtde - 1 
   
   for l_index = 1 to l_qtde
        
        let mr_servicos[l_index].socntzcod = mr_retorno[l_index].socntzcod              
        let mr_servicos[l_index].socntzdes = mr_retorno[l_index].socntzdes              
        let mr_servicos[l_index].grpcod = mr_retorno[l_index].grpcod                    
        let mr_servicos[l_index].lmicob = mr_retorno[l_index].lmicob
                                                                                                
        call cts65m01_qtd_servico(g_documento.itaciacod ,                               
                                  g_documento.ramcod,                                   
                                  g_documento.aplnumdig,                                
                                  g_documento.itmnumdig,    
                                  mr_servicos[l_index].grpcod,                            
                                  mr_servicos[l_index].socntzcod,                       
                                  g_documento.c24astcod)                                
              returning mr_servicos[l_index].utiliz                                     
                                                                                        
         whenever error continue                                                        
           open c_cts12g06_003 using mr_retorno[l_index].grpcod                         
           fetch c_cts12g06_003 into l_contabiliza                                      
         whenever error stop                                                            
                                                                                        
                                                                                        
         if l_contabiliza = "S" then                                                    
            let mr_servicos[l_index].limite    = mr_retorno[l_index].grplmtqtd          
         else                                                                           
            let mr_servicos[l_index].limite    = mr_retorno[l_index].utzlmtqtd          
         end if                                                                         
            
         let mr_servicos[l_index].saldo     = mr_servicos[l_index].limite -          
                                                 mr_servicos[l_index].utiliz                                
                
   end for   
        
   return l_qtde
    
end function 


function cts12g06_verifica_grupo_assunto(lr_param)

define lr_param record 
       socntzcod  like datksocntz.socntzcod
end record 

define l_count integer 
      ,l_existe smallint 
      
      
  let l_existe = false    
  let l_count = 0           
   
   whenever error continue 
   open c_cts12g06_004 using g_documento.ciaempcod
                            ,g_documento.c24astcod
                            ,lr_param.socntzcod
   fetch c_cts12g06_004 into l_count

   whenever error stop      
   
   if l_count > 0 then 
      let l_existe = true 
   end if 
   
   
  return l_existe 
  
end function         

function cts12g06_busca_descricao_grupo(lr_param)

define lr_param record
      grpcod like datkresitagrp.grpcod
end record

define lr_retorno record
       desnom like datkresitagrp.desnom
end record

let lr_retorno.desnom = 'NAO LOCALIZADO'
if lr_param.grpcod is null then   
   return lr_retorno.desnom
end if

whenever error continue
open c_cts12g06_007 using lr_param.grpcod
fetch c_cts12g06_007 into lr_retorno.desnom
whenever error stop

return lr_retorno.desnom

end function       

function cts12g06_busca_naturezas_detalhe(lr_param)

define lr_param record 
      grpcod like datkresitagrp.grpcod 
     ,itaasisrvcod  like datmresitaaplitm.srvcod          
end record 

define lr_retorno record 
       mens char(300)
end record        

define l_index integer,
       l_socntzcod like datksocntz.socntzcod

define t_cts12g06    array[500] of record 
          socntzcod     like datksocntz.socntzcod
         ,socntzdes     char(50)                           
end record 

let l_index = 0 
       
let lr_retorno.mens = null 

whenever error continue
open c_cts12g06_008 using lr_param.grpcod,lr_param.itaasisrvcod
whenever error stop 

   foreach c_cts12g06_008 into l_socntzcod 
   
        let l_index = l_index + 1 
        
        let t_cts12g06[l_index].socntzcod = l_socntzcod 
        
        whenever error continue 
        open c_cts12g06_009 using l_socntzcod
        fetch c_cts12g06_009 into t_cts12g06[l_index].socntzdes
        whenever error stop
   
   end foreach  
   
   if l_index = 0 then 
      let lr_retorno.mens = 'Grupo não tem mais naturezass'
   end if    
   
   
   #--------------
   # Abre a tela 
   #--------------
   open window w_cts12g06b at 07,4 with form "cts12g06b"
              attribute(form line 1, border)                    
                                                            
   let int_flag = false                                                                                                      
     
   call set_count(l_index)

   display array t_cts12g06 to s_cts12g06.*                                          
                        
      
      on key (interrupt,control-c,f17)                
            exit display                             
         
   end display    
   
   close window  w_cts12g06b
      
   let int_flag = false       
   
   return

end function  

function cts12g06_permissao_assunto(lr_param)

define lr_param record
   c24astcod like datkassunto.c24astcod
end record

   define l_index  integer,
          l_existe smallint,
          l_retorno smallint 

   for  l_index  =  1  to  500                     
      initialize  mr_retorno[l_index].* to  null       
   end  for     
                                         
   
   if m_cts12g06_prep is null or        
      m_cts12g06_prep <> true then   
      call cts12g06_prepare()  
   end if           

   let l_index = 1
   let l_existe = false
   let l_retorno = false
   let m_asiplncod = null    
   
   
       whenever error continue 
       open c_cts12g06_002 using g_doc_itau[1].itaasisrvcod
       fetch c_cts12g06_002 into m_asiplncod
       whenever error stop 
                
       
       open c_cts12g06_001 using m_asiplncod 
       foreach c_cts12g06_001 into mr_retorno[l_index].socntzcod  ,  
                                   mr_retorno[l_index].socntzdes  ,
                                   mr_retorno[l_index].utzlmtqtd  ,
                                   mr_retorno[l_index].grplmtqtd  ,
                                   mr_retorno[l_index].grpcod     ,
                                   mr_retorno[l_index].lmicob     
                                                                                               
              
       call cts12g06_verifica_grupo_assunto2(mr_retorno[l_index].socntzcod,lr_param.c24astcod)
            returning l_existe 
                   
       if l_existe = true then 
          let l_retorno = true
       end if           
       
       
       let l_index = l_index + 1
       
       end foreach
       
       for  l_index  =  1  to  500                        
          initialize  mr_retorno[l_index].* to  null      
       end  for                                           
       
         
   
   return l_retorno
   
end function          

function cts12g06_verifica_grupo_assunto2(lr_param)

define lr_param record 
       socntzcod  like datksocntz.socntzcod
      ,c24astcod  like datkassunto.c24astcod
end record 

define l_count integer 
      ,l_existe smallint 
      
   if m_cts12g06_prep is null or        
      m_cts12g06_prep <> true then   
      call cts12g06_prepare()  
   end if                
  
  let l_existe = false    
  let l_count = 0                 
    
   whenever error continue 
   open c_cts12g06_004 using g_documento.ciaempcod
                            ,lr_param.c24astcod
                            ,lr_param.socntzcod
   fetch c_cts12g06_004 into l_count

   whenever error stop      
      
   
   if l_count > 0 then 
      let l_existe = true 
   end if 
   
   
  return l_existe 
  
end function         

function cts12g06_verifica_assunto_servico(lr_param)

define lr_param record 
       c24astcod like datkassunto.c24astcod
end record      

define l_tipo_assunto like datkassunto.itaasstipcod,
       lr_retorno     smallint


if m_cts12g06_prep is null or        
   m_cts12g06_prep <> true then   
   call cts12g06_prepare()  
end if           


let lr_retorno = false 

whenever error continue 
open c_cts12g06_010 using lr_param.c24astcod
fetch c_cts12g06_010 into l_tipo_assunto
whenever error stop 

if l_tipo_assunto = 2 then 
   let lr_retorno = true
end if    
   

return lr_retorno

end function 