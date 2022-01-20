#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m04                                                   #
# Objetivo.......: Popup Generica Siebel                                      #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 16/08/2013                                                 #
#.............................................................................#

database porto
#----------------------------------#
function ctc69m04_popup(lr_param)
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
            let lr_retorno.sql =  " select srvespnum, srvespnom "
                                 ," from datksrvesp             "
                                 ," order by 2                  "
         when 2
            let lr_retorno.sql =  " select empcod, empnom "
                                 ," from gabkemp          "
                                 ," order by 1            "
         when 3
            let lr_retorno.sql =  " select ramcod, ramnom  "
                                 ," from gtakram           "
                                 ," order by 2             "
         when 4
            let lr_retorno.sql = " select srvcod, srvnom "
                                ," from datksrv          "
                                ," where srvsitflg = 'A' "
                                ," order by 2            "
         when 5
            let lr_retorno.sql = " select cpocod, cpodes        "
                                ," from datkdominio             "
                                ," where cponom = 'unid_siebel' "
                                ," order by 1                   "
         when 6
            let lr_retorno.sql = " select a.ctgtrfcod, a.ctgtrfdes "
                                ," from agekcateg a,               "
                                ,"      itatvig b                  "
                                ," where a.tabnum = b.tabnum       "
                                ,"   and a.ramcod = 531            "
                                ,"   and b.tabnom = 'agekcateg'    "
                                ,"   and b.viginc <= today         "
                                ,"   and b.vigfnl >= today         "
                                ," order by 2                      "
          when 7
            let lr_retorno.sql = " select cpocod, cpodes   "
                                ," from iddkdominio        "
                                ," where cponom = 'cbtcod' "
                                ," order by 1              "

          when 8
             let lr_retorno.sql = " select cpocod, cpodes        "
                                 ," from datkdominio             "
                                 ," where cponom = 'PF_PERFIL'   "
                                 ," order by 1                   "
          when 9
            let lr_retorno.sql = " select c24astcod, c24astdes  "
                                ," from datkassunto             "
                                ," where c24aststt = 'A'        "
                                ," order by 1                   "
          when 10
            let lr_retorno.sql = " select socntzcod, socntzdes  "
                                ," from datksocntz              "
                                ," where socntzstt = 'A'        "
                                ," order by 2                   "

         when 11
           let lr_retorno.sql = " select asitipcod, asitipdes  "
                               ," from datkasitip              "
                               ," where asitipstt = 'A'        "
                               ," order by 1                   "
         when 12
           let lr_retorno.sql = " select asimtvcod, asimtvdes  "
                               ," from datkasimtv              "
                               ," where asimtvsit = 'A'        "
                               ," order by 1                   "
         when 13
            let lr_retorno.sql = " select cpocod, cpodes        "
                                ," from datkdominio             "
                                ," where cponom = 'PF_MOTIVO'   "
                                ," order by 1                   "
         when 14
            let lr_retorno.sql = " select cpocod, cpodes        "
                                ," from datkdominio             "
                                ," where cponom = 'PF_BLOCO'    "
                                ," order by 1                   "
         when 15
            let lr_retorno.sql = " select c24pbmgrpcod, c24pbmgrpdes    "
                                ," from datkpbmgrp                      "
                                ," where c24pbmgrpstt = 'A'             "
                                ," order by 1                           "
         when 16
            let lr_retorno.sql = " select cpodes[1,3], cpodes[7,50] "
                                ," from datkdominio                 "
                                ," where cponom = 'claus_azul'      "
                                ," order by 1                       "
         when 17
            let lr_retorno.sql = " select a.clscod, a.clsdes  "
                                ," from aackcls a             "
                                ," group by 1,2               "
                                ," order by 1                 "
         when 18
            let lr_retorno.sql = " select atdsrvorg, srvtipabvdes       "
                                ," from datksrvtip                      "
                                ," order by 1                           "
         when 19
            let lr_retorno.sql = " select cpocod, cpodes        "
                                ," from datkdominio             "
                                ," where cponom = 'subnatureza' "
                                ," order by 1                   "
         when 20
            let lr_retorno.sql = " select cpocod, cpodes        "
                                ," from datkdominio             "
                                ," where cponom = 'cob_azul'    "
                                ," order by 1                   "  
         when 21                                                                          
            let lr_retorno.sql = " select itaasiplncod, itaasiplndes "                         
                                ," from datkitaasipln                "                                                
                                ," order by 1                        "    
         when 22                                                                                     
            let lr_retorno.sql = " select srvcod, srvdes "                              
                                ," from datkresitasrv    "                              
                                ," order by 1            "                                     
         when 23                                                        
            let lr_retorno.sql = " select itaramcod, itaramdes "              
                                ," from datkitaram             "                                     
                                ," order by 1                  "                                     
         when 24                                                        
            let lr_retorno.sql = " select cpocod, cpodes "              
                                ," from iddkdominio            " 
                                ," where cponom = 'bncsgmcod'  "                                    
                                ," order by 1                  " 
         
         when 25                                                        
            let lr_retorno.sql = " select itaprdcod, itaprddes "              
                                ," from datkitaprd             "                                 
                                ," order by 1                  " 
         
         when 26                                                  
            let lr_retorno.sql = " select cpocod, cpodes         "        
                                ," from datkdominio              "  
                                ," where cponom = 'IT_GRP_PROD'  "  
                                ," order by 1                    "  
                                                                                                               
                                
     end case

     let l_index = 1

     prepare pctc69m04001 from lr_retorno.sql
     declare cctc69m04001 cursor for pctc69m04001

     open cctc69m04001
     foreach cctc69m04001 into lr_array[l_index].codigo   ,
                               lr_array[l_index].descricao

           let l_index = l_index + 1

           if l_index > 500 then
              error "Limite excedido. Foram Encontrados mais de 500 Registros!"
              exit foreach
           end if

     end foreach

     open window ctc69m04 at 10,27 with form "ctc69m04"
        attribute (border,form line 1)

     message " (F17)Abandona, (F8)Seleciona"
     call set_count(l_index-1)

     display array lr_array to s_ctc69m04.*

        on key (interrupt,control-c)
           initialize lr_array to null
           let l_index = 1
           exit display

        on key (f8)
           let l_index = arr_curr()
           exit display
     end display


     close window ctc69m04

     let int_flag = false

     return lr_array[l_index].codigo,
            lr_array[l_index].descricao

end function

#----------------------------------------------#
function ctc69m04_recupera_descricao(lr_param)
#----------------------------------------------#

define lr_param record
  tipo   smallint,
  codigo char(10)
end record

define lr_retorno record
  sql       char(500),
  descricao char(50)
end record

initialize lr_retorno.* to null


     case lr_param.tipo
         when 1
            let lr_retorno.sql =  " select srvespnom   "
                                 ," from datksrvesp    "
                                 ," where srvespnum = ?"
         when 2
            let lr_retorno.sql =  " select empnom    "
                                 ," from gabkemp     "
                                 ," where empcod = ? "
         when 3
            let lr_retorno.sql =  " select ramnom    "
                                 ," from gtakram     "
                                 ," where ramcod = ? "
         when 4
            let lr_retorno.sql = " select srvnom         "
                                ," from datksrv          "
                                ," where srvsitflg = 'A' "
                                ,"   and srvcod = ?      "
         when 5
            let lr_retorno.sql = " select cpodes                "
                                ," from datkdominio             "
                                ," where cponom = 'unid_siebel' "
                                ,"   and cpocod = ?             "
         when 6
            let lr_retorno.sql = " select a.ctgtrfdes            "
                                ," from agekcateg a,             "
                                ,"      itatvig b                "
                                ," where a.tabnum = b.tabnum     "
                                ,"   and a.ramcod = 531          "
                                ,"   and b.tabnom = 'agekcateg'  "
                                ,"   and b.viginc <= today       "
                                ,"   and b.vigfnl >= today       "
                                ,"   and ctgtrfcod = ?           "
         when 7
            let lr_retorno.sql = " select cpodes           "
                                ," from iddkdominio        "
                                ," where cponom = 'cbtcod' "
                                ,"   and cpocod = ?        "

         when 8
            let lr_retorno.sql = " select cpodes                "
                                ," from datkdominio             "
                                ," where cponom = 'PF_PERFIL'   "
                                ,"   and cpocod = ?             "

         when 10
            let lr_retorno.sql = " select  socntzdes            "
                                ," from datksocntz              "
                                ," where socntzstt = 'A'        "
                                ," and socntzcod   = ?          "

         when 11
            let lr_retorno.sql = " select asitipdes             "
                                ," from datkasitip              "
                                ," where asitipstt = 'A'        "
                                ," and asitipcod = ?            "
         when 12
           let lr_retorno.sql = " select asimtvdes             "
                               ," from datkasimtv              "
                               ," where asimtvsit = 'A'        "
                               ," and asimtvcod = ?            "
         when 13
            let lr_retorno.sql = " select cpodes                "
                                ," from datkdominio             "
                                ," where cponom = 'PF_MOTIVO'   "
                                ,"   and cpocod = ?             "
         when 14
            let lr_retorno.sql = " select cpodes                "
                                ," from datkdominio             "
                                ," where cponom = 'PF_BLOCO'    "
                                ,"   and cpocod = ?             "
         when 15
            let lr_retorno.sql = " select c24pbmgrpdes          "
                                ," from datkpbmgrp              "
                                ," where c24pbmgrpstt = 'A'     "
                                ," and c24pbmgrpcod = ?         "
         when 16
            let lr_retorno.sql = " select cpodes[7,50]          "
                                ," from datkdominio             "
                                ," where cponom = 'claus_azul'  "
                                ," and cpodes[1,3] = ?          "
         when 17
            let lr_retorno.sql = " select a.clsdes            "
                                ," from aackcls a             "
                                ," where a.clscod = ?         "
         when 18
            let lr_retorno.sql = " select srvtipabvdes          "
                                ," from datksrvtip              "
                                ," where atdsrvorg = ?          "
         when 19
            let lr_retorno.sql = " select cpodes                "
                                ," from datkdominio             "
                                ," where cponom = 'subnatureza' "
                                ,"   and cpocod = ?             "
         when 20
            let lr_retorno.sql = " select cpodes                "
                                ," from datkdominio             "
                                ," where cponom = 'cob_azul'    "
                                ," and cpocod = ?               "  
         when 21                                                                            
            let lr_retorno.sql = " select itaasiplndes          "                          
                                ," from datkitaasipln           "                          
                                ," where itaasiplncod = ?       " 
         when 22                                                                          
            let lr_retorno.sql = " select srvdes                "                         
                                ," from datkresitasrv           "                                                  
                                ," where srvcod = ?             "   
         when 23                                                                           
            let lr_retorno.sql = " select itaramdes             "                          
                                ," from datkitaram              "                          
                                ," where itaramcod = ?          "                          
                                
        when 24                                                                           
            let lr_retorno.sql = " select cpodes                "                          
                                ," from iddkdominio             "                          
                                ," where cponom = 'bncsgmcod'   "
                                ," and   cpocod = ?             "                          
        
       when 25                                                     
           let lr_retorno.sql = " select itaprddes             "   
                               ," from datkitaprd              "   
                               ," where itaprdcod = ?          "                                                                                  
                 
                                
       when 26                                                                          
            let lr_retorno.sql = " select cpodes                "                          
                                ," from datkdominio             "                          
                                ," where cponom = 'IT_GRP_PROD' "
                                ," and   cpocod = ?             "                          
        
     
     end case


     prepare pctc69m04002 from lr_retorno.sql
     declare cctc69m04002 cursor for pctc69m04002

     open cctc69m04002 using lr_param.codigo

     whenever error continue
     fetch cctc69m04002 into lr_retorno.descricao
     whenever error stop

     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if

     close cctc69m04002


    return lr_retorno.descricao

end function

#----------------------------------#
function ctc69m04_popup_2(lr_param)
#----------------------------------#

define lr_param record
  tipo     smallint ,
  codigo   smallint
end record

define lr_array array[500] of record
  codigo    char(06),
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
           let lr_retorno.sql = " select a.asitipcod, a.asitipdes  "
                               ," from datkasitip a,               "
                               ,"      datrasitipsrv b             "
                               ," where a.asitipcod = b.asitipcod  "
                               ," and   a.asitipstt = 'A'          "
                               ," and   b.atdsrvorg =  ?           "
                               ," order by 1                       "
         when 8
            let lr_retorno.sql = " select a.srvespnum, a.srvespnom "
                                ," from datksrvesp a  ,            "
                                ,"      datksrvgrpesp b            "
                                ," where a.srvespnum = b.srvespcod "
                                ," and b.srvgrpcod = ?             "
                                ," and b.regsitflg = 'A'           "
                                ," order by 2                      "
         when 11
            let lr_retorno.sql = " select a.clscod, a.clsdes  "
                                ," from aackcls a             "
                                ," where  a.ramcod = ?        "
                                ," group by 1,2               "
                                ," order by 1                 "

     end case

     let l_index = 1

     prepare pctc69m04003 from lr_retorno.sql
     declare cctc69m04003 cursor for pctc69m04003

     open cctc69m04003 using lr_param.codigo
     foreach cctc69m04003 into lr_array[l_index].codigo   ,
                               lr_array[l_index].descricao

           let l_index = l_index + 1

           if l_index > 500 then
              message "Limite excedido. Foram Encontrados mais de 500 Registros!"
              exit foreach
           end if

     end foreach

     open window ctc69m04 at 10,27 with form "ctc69m04"
        attribute (border,form line 1)

     message " (F17)Abandona, (F8)Seleciona"
     call set_count(l_index-1)

     display array lr_array to s_ctc69m04.*

        on key (interrupt,control-c)
           initialize lr_array to null
           let l_index = 1
           exit display

        on key (f8)
           let l_index = arr_curr()
           exit display
     end display

     close window ctc69m04

     let int_flag = false

     return lr_array[l_index].codigo,
            lr_array[l_index].descricao

end function

#------------------------------------------------#
function ctc69m04_recupera_descricao_2(lr_param)
#------------------------------------------------#

define lr_param record
  tipo    smallint,
  codigo1 integer ,
  codigo2 integer
end record

define lr_retorno record
  sql       char(500),
  descricao char(50)
end record

initialize lr_retorno.* to null


     case lr_param.tipo
         when 1
           let lr_retorno.sql = " select a.asitipdes              "
                               ," from datkasitip a,              "
                               ,"      datrasitipsrv b            "
                               ," where a.asitipcod = b.asitipcod "
                               ," and   a.asitipstt = 'A'         "
                               ," and   a.asitipcod =  ?          "
                               ," and   b.atdsrvorg =  ?          "
                               ," order by 1                      "
         when 8
           let lr_retorno.sql = " select a.srvespnom                "
                                ," from datksrvesp a,               "
                                ,"      datksrvgrpesp b             "
                                ," where a.srvespnum = b.srvespcod  "
                                ," and b.srvgrpcod = ?              "
                                ," and b.regsitflg = 'A'            "
                                ," and a.srvespnum = ?              "

     end case


     prepare pctc69m04004 from lr_retorno.sql
     declare cctc69m04004 cursor for pctc69m04004

     open cctc69m04004 using lr_param.codigo1, lr_param.codigo2

     whenever error continue
     fetch cctc69m04004 into lr_retorno.descricao
     whenever error stop

     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if

     close cctc69m04004


    return lr_retorno.descricao

end function

#----------------------------------#
function ctc69m04_popup_3(lr_param)
#----------------------------------#

define lr_param record
  tipo     smallint
end record

define lr_array array[500] of record
  codigo    smallint ,
  descricao char(50)
end record

define lr_array_aux array[500] of record
  codigo    smallint
end record

define lr_retorno record
  sql       char(500)
end record

define l_index smallint

for  l_index  =  1  to  500
   initialize  lr_array[l_index].*, lr_array_aux[l_index].* to  null
end  for

initialize lr_retorno.* to null


     case lr_param.tipo
          when 10
             let lr_retorno.sql = " select a.srvcod, b.srvnom, a.srvgrpcod "
                                 ," from datksrvgrp a,                     "
                                 ,"      datksrv b                         "
                                 ," where a.srvcod = b.srvcod              "
                                 ," and a.regsitflg = 'A'                  "
                                 ," order by 2                             "


     end case

     let l_index = 1

     prepare pctc69m04005 from lr_retorno.sql
     declare cctc69m04005 cursor for pctc69m04005

     open cctc69m04005
     foreach cctc69m04005 into lr_array[l_index].codigo    ,
                               lr_array[l_index].descricao ,
                               lr_array_aux[l_index].codigo

           let l_index = l_index + 1

           if l_index > 500 then
              message "Limite excedido. Foram Encontrados mais de 500 Registros!"
              exit foreach
           end if

     end foreach

     open window ctc69m04 at 10,27 with form "ctc69m04"
        attribute (border,form line 1)

     message " (F17)Abandona, (F8)Seleciona"
     call set_count(l_index-1)

     display array lr_array to s_ctc69m04.*

        on key (interrupt,control-c)
           initialize lr_array to null
           let l_index = 1
           exit display

        on key (f8)
           let l_index = arr_curr()
           exit display
     end display

     close window ctc69m04

     let int_flag = false

     return lr_array[l_index].codigo,
            lr_array[l_index].descricao,
            lr_array_aux[l_index].codigo

end function

#------------------------------------------------#
function ctc69m04_recupera_descricao_3(lr_param)
#------------------------------------------------#

define lr_param record
  tipo    smallint,
  codigo  integer
end record

define lr_retorno record
  sql       char(500),
  descricao char(50) ,
  codigo    integer
end record

initialize lr_retorno.* to null


     case lr_param.tipo
         when 10
           let lr_retorno.sql = " select b.srvnom, a.srvgrpcod "
                               ," from datksrvgrp a,           "
                               ,"      datksrv b               "
                               ," where a.srvcod = b.srvcod    "
                               ," and a.regsitflg  = 'A'       "
                               ," and a.srvcod     = ?         "


     end case


     prepare pctc69m04006 from lr_retorno.sql
     declare cctc69m04006 cursor for pctc69m04006

     open cctc69m04006 using lr_param.codigo
     whenever error continue
     fetch cctc69m04006 into lr_retorno.descricao,
                             lr_retorno.codigo
     whenever error stop
     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if
     close cctc69m04006


    return  lr_retorno.codigo    ,
            lr_retorno.descricao

end function

#------------------------------------------------#
function ctc69m04_recupera_descricao_4(lr_param)
#------------------------------------------------#

define lr_param record
  tipo    smallint,
  codigo  integer
end record

define lr_retorno record
  sql       char(500),
  descricao char(50) ,
  codigo    char(02)
end record

initialize lr_retorno.* to null


     case lr_param.tipo
         when 11
           let lr_retorno.sql = " select cidnom, ufdcod "
                               ," from glakcid          "
                               ," where cidcod = ?      "

     end case


     prepare pctc69m04007 from lr_retorno.sql
     declare cctc69m04007 cursor for pctc69m04007

     open cctc69m04007 using lr_param.codigo
     whenever error continue
     fetch cctc69m04007 into lr_retorno.descricao,
                             lr_retorno.codigo
     whenever error stop
     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if
     close cctc69m04007


    return  lr_retorno.descricao    ,
            lr_retorno.codigo

end function

#----------------------------------#
function ctc69m04_popup_5(lr_param)
#----------------------------------#

define lr_param record
  tipo     smallint
end record

define lr_array array[500] of record
  codigo    smallint ,
  descricao char(50)
end record

define lr_array_aux array[500] of record
  codigo    char(02)
end record

define lr_retorno record
  sql       char(500)
end record

define l_index smallint

for  l_index  =  1  to  500
   initialize  lr_array[l_index].*, lr_array_aux[l_index].* to  null
end  for

initialize lr_retorno.* to null


     case lr_param.tipo
          when 9
            let lr_retorno.sql = " select a.clalclcod, a.clalcldes, a.ufdcod "
                                ," from agekregiao a,                        "
                                ,"      itatvig b                            "
                                ," where a.tabnum = b.tabnum                 "
                                ,"   and b.tabnom = 'agekregiao'             "
                                ,"   and b.viginc <= today                   "
                                ,"   and b.vigfnl >= today                   "
                                ," order by 1                                "

     end case

     let l_index = 1

     prepare pctc69m04008 from lr_retorno.sql
     declare cctc69m04008 cursor for pctc69m04008

     open cctc69m04008
     foreach cctc69m04008 into lr_array[l_index].codigo    ,
                               lr_array[l_index].descricao ,
                               lr_array_aux[l_index].codigo

           let l_index = l_index + 1

           if l_index > 500 then
              message "Limite excedido. Foram Encontrados mais de 500 Registros!"
              exit foreach
           end if

     end foreach

     open window ctc69m04 at 10,27 with form "ctc69m04"
        attribute (border,form line 1)

     message " (F17)Abandona, (F8)Seleciona"
     call set_count(l_index-1)

     display array lr_array to s_ctc69m04.*

        on key (interrupt,control-c)
           initialize lr_array to null
           let l_index = 1
           exit display

        on key (f8)
           let l_index = arr_curr()
           exit display
     end display

     close window ctc69m04

     let int_flag = false

     return lr_array[l_index].codigo,
            lr_array[l_index].descricao,
            lr_array_aux[l_index].codigo

end function

#------------------------------------------------#
function ctc69m04_recupera_descricao_5(lr_param)
#------------------------------------------------#

define lr_param record
  tipo    smallint,
  codigo  integer
end record

define lr_retorno record
  sql       char(500),
  descricao char(50) ,
  codigo    char(02)
end record

initialize lr_retorno.* to null


     case lr_param.tipo
         when 9
            let lr_retorno.sql = " select a.clalcldes, a.ufdcod    "
                                ," from agekregiao a,              "
                                ,"      itatvig b                  "
                                ," where a.tabnum = b.tabnum       "
                                ,"   and b.tabnom = 'agekregiao'   "
                                ,"   and b.viginc <= today         "
                                ,"   and b.vigfnl >= today         "
                                ,"   and a.clalclcod = ?           "



     end case


     prepare pctc69m04009 from lr_retorno.sql
     declare cctc69m04009 cursor for pctc69m04009

     open cctc69m04009 using lr_param.codigo
     whenever error continue
     fetch cctc69m04009 into lr_retorno.descricao,
                             lr_retorno.codigo
     whenever error stop
     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if
     close cctc69m04009


    return lr_retorno.descricao ,
           lr_retorno.codigo

end function

#------------------------------------------------#
function ctc69m04_recupera_descricao_6(lr_param)
#------------------------------------------------#

define lr_param record
  tipo    smallint ,
  codigo1 char(04) ,
  codigo2 integer
end record

define lr_retorno record
  sql       char(500),
  descricao char(50)
end record

initialize lr_retorno.* to null


     case lr_param.tipo
         when 11
            let lr_retorno.sql = " select a.clsdes            "
                                ," from aackcls a             "
                                ," where a.clscod = ?         "
                                ," and   a.ramcod = ?         "


     end case


     prepare pctc69m04010 from lr_retorno.sql
     declare cctc69m04010 cursor for pctc69m04010

     open cctc69m04010 using lr_param.codigo1, lr_param.codigo2

     whenever error continue
     fetch cctc69m04010 into lr_retorno.descricao
     whenever error stop

     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if

     close cctc69m04010


    return lr_retorno.descricao

end function
#------------------------------------------------#
function ctc69m04_recupera_descricao_7(lr_param)
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
         when 9
             let lr_retorno.sql = " select c24astdes             "
                                 ," from datkassunto             "
                                 ," where c24aststt = 'A'        "
                                 ," and   c24astcod = ?          "
     end case
     prepare pctc69m04011 from lr_retorno.sql
     declare cctc69m04011 cursor for pctc69m04011
     open cctc69m04011 using lr_param.codigo
     whenever error continue
     fetch cctc69m04011 into lr_retorno.descricao
     whenever error stop
     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if
     close cctc69m04011
    return lr_retorno.descricao
end function