#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m14                                                   #
# Objetivo.......: Consulta de Classe de Localizacao                          #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 23/08/2013                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"      

define   m_prepare  smallint  

#------------------------------------------------------------------------------   
function ctc69m14_prepare()                                                       
#------------------------------------------------------------------------------   

define l_sql char(1000)                                  
                                                         
    let l_sql = ' select clalclcod   '          
              , '        ,clalcldes  '    
              , '   from agekregiao  '  
              , 'where tabnum = 7    '       
              , '   order by 1   '             
    prepare p_ctc69m14_001 from l_sql                    
    declare c_ctc69m14_001 cursor for p_ctc69m14_001     


    let m_prepare = true 


end function

#-----------------------------------------------------------
 function ctc69m14()
#-----------------------------------------------------------

 
define a_ctc69m14 array[500] of record
   clalclcod  like agekregiao.clalclcod , 
   clalcldes  like agekregiao.clalcldes
end record


define lr_retorno  record
  clalclcod  like agekregiao.clalclcod    ,  
  clalcldes  like agekregiao.clalcldes              
end record


define arr_aux  smallint   
define l_idx	  integer

let	arr_aux  =  null

for	l_idx  =  1  to  500
	initialize  a_ctc69m14[l_idx].*  to  null
end	for

initialize  lr_retorno.*  to  null

let int_flag = false
let arr_aux  = 1

if m_prepare is null or     
   m_prepare <> true then   
   call ctc69m14_prepare()   
end if                      
 
 
 open c_ctc69m14_001 
 foreach c_ctc69m14_001  into a_ctc69m14[arr_aux].clalclcod,
                              a_ctc69m14[arr_aux].clalcldes 
                                        

    let arr_aux = arr_aux + 1

    if arr_aux > 500  then
       error " Limite Excedido. Foram Encontrados Mais de 500 Classes!"
       exit foreach
    end if

 end foreach

 open window ctc69m14 at 4,2 with form "ctc69m14"
                   attribute(form line 1, border)


 call set_count(arr_aux-1)

 display array a_ctc69m14 to s_ctc69m14.* 
 
    
    on key (interrupt,control-c)
       initialize a_ctc69m14     to null
       exit display

 end display

 let int_flag = false
 close window ctc69m14
   

end function  
 




















































