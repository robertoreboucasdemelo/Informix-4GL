#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m16                                                   #
# Objetivo.......: Popup Limites                                              #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 12/04/2014                                                 #
#.............................................................................#


define  m_prepare  smallint

#===============================================================================
 function ctc69m16_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select limcod              '
          ,  '      , limdes              '
          ,  '      , limlim              '
          ,  '      , limuni              '
          ,  '   from limite_temp         '
          ,  '  where paccod = ?          '
          ,  '  and   srvcod = ?          '
          ,  '  and   espcod = ?          '
          ,  '  order by limcod           '
 prepare p_ctc69m16_001 from l_sql
 declare c_ctc69m16_001 cursor for p_ctc69m16_001




 let m_prepare = true


end function


#----------------------------------#
function ctc69m16_popup(lr_param)
#----------------------------------#

define lr_param record
	paccod integer,
	srvcod integer,
	espcod integer
end record
define lr_array array[500] of record
  limcod    integer  ,
  limdes    char(60) ,
  limlim    dec(13,2),
  limuni    char(60)
end record

define l_index  smallint
define l_acesso smallint
for  l_index  =  1  to  500
   initialize  lr_array[l_index].* to  null
end  for
let l_acesso = 0



     call ctc69m16_prepare()



     let l_index = 1


     open c_ctc69m16_001 using lr_param.paccod,
                               lr_param.srvcod,
                               lr_param.espcod



     foreach c_ctc69m16_001 into lr_array[l_index].limcod   ,
                                 lr_array[l_index].limdes   ,
                                 lr_array[l_index].limlim   ,
                                 lr_array[l_index].limuni

           let l_index = l_index + 1

           if l_index > 500 then
              error "Limite excedido. Foram Encontrados mais de 500 Registros!"
              exit foreach
           end if

     end foreach





     open window ctc69m16 at 6,2 with form "ctc69m16"




        attribute (border,form line 1)







     message " (F17)Abandona, (F8)Confirma"




     call set_count(l_index-1)





















     display array lr_array to s_ctc69m16.*













        on key (interrupt,control-c)






           initialize lr_array to null
           let l_index = 1
           exit display


















        on key (f8)








           let l_acesso = 1
           exit display
     end display


     close window ctc69m16

     let int_flag = false

     return l_acesso


end function






