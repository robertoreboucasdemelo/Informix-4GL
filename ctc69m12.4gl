#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m12                                                   #
# Objetivo.......: Consulta de Categoria                                      #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 23/08/2013                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"      

define   m_prepare  smallint  

#------------------------------------------------------------------------------   
function ctc69m12_prepare()                                                       
#------------------------------------------------------------------------------   

define l_sql char(1000)                                  
                                                         
    let l_sql = ' select ctgtrfcod   '          
              , '        ,ctgtrfdes  '    
              , '   from agekcateg  '  
              , 'where tabnum = 7      '
              , 'and ramcod in (531)'            
              , '   order by 1   '             
    prepare p_ctc69m12_001 from l_sql                    
    declare c_ctc69m12_001 cursor for p_ctc69m12_001     


    let m_prepare = true 


end function

#-----------------------------------------------------------
 function ctc69m12()
#-----------------------------------------------------------

 
define a_ctc69m12 array[500] of record
   ctgtrfcod  like agekcateg.ctgtrfcod , 
   ctgtrfdes  like agekcateg.ctgtrfdes
end record


define lr_retorno  record
  ctgtrfcod  like agekcateg.ctgtrfcod    ,  
  ctgtrfdes  like agekcateg.ctgtrfdes              
end record


define arr_aux  smallint   
define l_idx	  integer

let	arr_aux  =  null

for	l_idx  =  1  to  500
	initialize  a_ctc69m12[l_idx].*  to  null
end	for

initialize  lr_retorno.*  to  null

let int_flag = false
let arr_aux  = 1

if m_prepare is null or     
   m_prepare <> true then   
   call ctc69m12_prepare()   
end if                      
 
 
 open c_ctc69m12_001 
 foreach c_ctc69m12_001  into a_ctc69m12[arr_aux].ctgtrfcod,
                              a_ctc69m12[arr_aux].ctgtrfdes 
                                        

    let arr_aux = arr_aux + 1

    if arr_aux > 500  then
       error " Limite Excedido. Foram Encontrados Mais de 500 Categorias!"
       exit foreach
    end if

 end foreach

 open window ctc69m12 at 4,2 with form "ctc69m12"
                   attribute(form line 1, border)


 call set_count(arr_aux-1)

 display array a_ctc69m12 to s_ctc69m12.* 
 
    
    on key (interrupt,control-c)
       initialize a_ctc69m12     to null
       exit display

 end display

 let int_flag = false
 close window ctc69m12
   

end function  
 




















































