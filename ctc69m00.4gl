#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m00                                                   #
# Objetivo.......: Popup Servicos                                             #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 12/04/2014                                                 #
#.............................................................................#

define  m_prepare  smallint

#===============================================================================
 function ctc69m00_prepare()
#===============================================================================

define l_sql char(10000)


 let l_sql = ' select srvcod              '
          ,  '      , srvdes              '
          ,  '   from servico_temp        '
          ,  '  where paccod = ?          '
          ,  '  order by srvcod           '
 prepare p_ctc69m00_001 from l_sql
 declare c_ctc69m00_001 cursor for p_ctc69m00_001


 let m_prepare = true


end function


#----------------------------------#
function ctc69m00_popup(lr_param)
#----------------------------------#

define lr_param record
	paccod integer
end record

define lr_array array[500] of record
  srvcod    integer  ,
  srvdes    char(60)
end record

define l_index  smallint
define l_acesso smallint

for  l_index  =  1  to  500
   initialize  lr_array[l_index].* to  null
end  for

let l_acesso = 0


     call ctc69m00_prepare()


     let l_index = 1


     open c_ctc69m00_001 using lr_param.paccod
     foreach c_ctc69m00_001 into lr_array[l_index].srvcod   ,
                                 lr_array[l_index].srvdes

           let l_index = l_index + 1
           if l_index > 500 then
              error "Limite excedido. Foram Encontrados mais de 500 Registros!"
              exit foreach
           end if

     end foreach

     open window ctc69m00 at 6,2 with form "ctc69m00"
        attribute (border,form line 1)

     message " (F17)Abandona, (F7)Especialidades, (F8)Confirma"
     call set_count(l_index-1)

     display array lr_array to s_ctc69m00.*

        on key (interrupt,control-c)
           initialize lr_array to null
           let l_index = 1
           exit display

       on key (f7)

           let l_index = arr_curr()

           call ctc69m01_popup(lr_param.paccod,
                               lr_array[l_index].srvcod)
           returning l_acesso

           if l_acesso = 1 then
               exit display
           end if

        on key (f8)
           let l_acesso = 1
           exit display
     end display


     close window ctc69m00

     let int_flag = false

     return l_acesso


end function














