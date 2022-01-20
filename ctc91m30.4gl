#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc91m30                                                   #
# Objetivo.......: Popup Generica Siebel                                      #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 16/08/2013                                                 #
#.............................................................................#

database porto
#----------------------------------#
function ctc91m30_popup(lr_param)
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
            let lr_retorno.sql = " select c24astcod, c24astdes      "
                                ," from datkassunto a, datkastagp b "
                                ," where a.c24astagp = b.c24astagp  "
                                ," and a.c24aststt = 'A'            "
                                ," and b.ciaempcod = 84             "         
                                ," order by 1                       "
          when  2
            let lr_retorno.sql = " select asimtvcod, asimtvdes  "
                                ," from datkasimtv              "
                                ," where asimtvsit = 'A'        "
                                ," order by 1                   "
          when  3 
            let lr_retorno.sql = " select c24pbmgrpcod, c24pbmgrpdes    "
                                ," from datkpbmgrp                      "
                                ," where c24pbmgrpstt = 'A'             "
                                ," and atdsrvorg = 1                    "  
                                ," order by 2                           " 
          when  4                                                            
            let lr_retorno.sql = " select asitipcod, asitipdes          "              
                                ," from datkasitip                      "        
                                ," where asitipstt = 'A'                "        
                                ," order by 1                           "        
                                                                        
     end case

     let l_index = 1

     prepare pctc91m30001 from lr_retorno.sql
     declare cctc91m30001 cursor for pctc91m30001

     open cctc91m30001
     foreach cctc91m30001 into lr_array[l_index].codigo   ,
                               lr_array[l_index].descricao

           let l_index = l_index + 1

           if l_index > 500 then
              error "Limite excedido. Foram Encontrados mais de 500 Registros!"
              exit foreach
           end if

     end foreach

     open window ctc91m30 at 10,27 with form "ctc91m30"
        attribute (border,form line 1)

     message " (F17)Abandona, (F8)Seleciona"
     call set_count(l_index-1)

     display array lr_array to s_ctc91m30.*

        on key (interrupt,control-c)
           initialize lr_array to null
           let l_index = 1
           exit display

        on key (f8)
           let l_index = arr_curr()
           exit display
     end display


     close window ctc91m30

     let int_flag = false

     return lr_array[l_index].codigo,
            lr_array[l_index].descricao

end function


#------------------------------------------------#
function ctc91m30_recupera_descricao(lr_param)
#------------------------------------------------#
define lr_param record
  tipo    smallint ,
  codigo  char(04)
end record

define lr_retorno record
  sql       char(500),
  descricao char(50)
end record

initialize lr_retorno.* to null
     case lr_param.tipo
         when 1
             let lr_retorno.sql = " select c24astdes                 "
                                 ," from datkassunto a, datkastagp b "
                                 ," where a.c24astagp = b.c24astagp  "
                                 ," and a.c24aststt = 'A'            "
                                 ," and a.c24astcod = ?              " 
                                 ," and b.ciaempcod = 84             " 
         when  2                                                      
             let lr_retorno.sql = " select asimtvdes            "      
                                 ," from datkasimtv             "      
                                 ," where asimtvsit = 'A'       "      
                                 ," and asimtvcod   =  ?        "
         when  3                                                         
             let lr_retorno.sql = " select c24pbmgrpdes         "  
                                 ," from datkpbmgrp             "  
                                 ," where c24pbmgrpstt = 'A'    "  
                                 ," and c24pbmgrpcod = ?        " 
                                 ," and atdsrvorg = 1           "
          
        when  4                                                      
            let lr_retorno.sql = " select asitipdes            "     
                                ," from datkasitip             "     
                                ," where asitipstt = 'A'       "     
                                ," and asitipcod   =  ?        "   
     
     end case
     
     prepare pctc91m30011 from lr_retorno.sql
     
     declare cctc91m30011 cursor for pctc91m30011
     
     open cctc91m30011 using lr_param.codigo
     whenever error continue
     fetch cctc91m30011 into lr_retorno.descricao
     whenever error stop
     
     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if
     
     close cctc91m30011
    
     return lr_retorno.descricao
end function