#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc91m24                                                   #
# Objetivo.......: Popup Generica Itau                                        #
# Analista Resp. : Moises Gabel                                               #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 29/07/2014                                                 #
#.............................................................................#

database porto

#----------------------------------#
function ctc91m24_popup(lr_param)
#----------------------------------#

define lr_param record
  tipo  smallint
end record

define lr_array array[500] of record
  codigo    char(06) ,
  descricao char(50)
end record

define lr_retorno record
  sql       char(500)
end record

define l_index smallint

for  l_index  =  1  to  500
   initialize  lr_array[l_index].* to  null
end  for

initialize lr_retorno.* to null


     case lr_param.tipo
         when 1
            let lr_retorno.sql =  " select itarsrcaomtvcod , itarsrcaomtvdes  " 
                                 ," from datkitarsrcaomtv       " 
                                 ," order by 1                  "
         when 2                                                                  
            let lr_retorno.sql =  " select itaclisgmcod , itaclisgmdes  "  
                                 ," from datkitaclisgm                  "                 
                                 ," order by 1                          "                                                                           
                                                                            
     end case

     let l_index = 1

     prepare pctc91m24001 from lr_retorno.sql
     declare cctc91m24001 cursor for pctc91m24001

     open cctc91m24001
     foreach cctc91m24001 into lr_array[l_index].codigo   ,
                               lr_array[l_index].descricao

           let l_index = l_index + 1

           if l_index > 500 then
              error "Limite excedido. Foram Encontrados mais de 500 Registros!"
              exit foreach
           end if

     end foreach

     open window ctc91m24 at 10,27 with form "ctc91m24"
        attribute (border,form line 1)

     message " (F17)Abandona, (F8)Seleciona"
     call set_count(l_index-1)

     display array lr_array to s_ctc91m24.*

        on key (interrupt,control-c)
           initialize lr_array to null
           let l_index = 1
           exit display

        on key (f8)
           let l_index = arr_curr()
           exit display
     end display
     

     close window ctc91m24

     let int_flag = false

     return lr_array[l_index].codigo,
            lr_array[l_index].descricao

end function

#----------------------------------------------#
function ctc91m24_recupera_descricao(lr_param)
#----------------------------------------------#

define lr_param record
  tipo   smallint,
  codigo integer
end record
                                                  
define lr_retorno record                          
  sql       char(500),                             
  descricao char(50)                              
end record

initialize lr_retorno.* to null


     case lr_param.tipo
         when 1
            let lr_retorno.sql =  " select itarsrcaomtvdes   " 
                                 ," from datkitarsrcaomtv    " 
                                 ," where itarsrcaomtvcod = ?" 
         when 2                                                                        
            let lr_retorno.sql =  " select itaclisgmdes   "                         
                                 ," from datkitaclisgm    "                                                                                             
                                 ," where itaclisgmcod = ?"                                       
   
     end case


     prepare pctc91m24002 from lr_retorno.sql
     declare cctc91m24002 cursor for pctc91m24002

     open cctc91m24002 using lr_param.codigo
     
     whenever error continue
     fetch cctc91m24002 into lr_retorno.descricao
     whenever error stop
     
     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if
     
     close cctc91m24002


    return lr_retorno.descricao

end function

                                 