#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m03                                                   #
# Objetivo.......: Popup Pacotes                                              #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 12/04/2014                                                 #
#.............................................................................#

define  m_prepare  smallint

#===============================================================================
 function ctc69m03_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select paccod              '
          ,  '      , pacdes              '
          ,  '      , paclim              '
          ,  '      , pacuni              '
          ,  '   from pacote_temp         '
          ,  '  order by paccod           '
 prepare p_ctc69m03_001 from l_sql
 declare c_ctc69m03_001 cursor for p_ctc69m03_001
 let l_sql = ' select pacdes              '
          ,  '      , paclim              '
          ,  '      , pacuni              '
          ,  '   from pacote_temp         '
          ,  '  where paccod = ?          '
 prepare p_ctc69m03_002 from l_sql
 declare c_ctc69m03_002 cursor for p_ctc69m03_002


 let m_prepare = true


end function

#----------------------------------#
function ctc69m03_popup()
#----------------------------------#

define lr_array array[500] of record
  paccod    integer  ,
  pacdes    char(60) ,
  paclim    dec(13,2),
  pacuni    char(60)
end record


define l_index  smallint
define l_acesso smallint

for  l_index  =  1  to  500
   initialize  lr_array[l_index].* to  null
end  for

     call ctc69m03_prepare()

     let l_index = 1


     open c_ctc69m03_001
     foreach c_ctc69m03_001 into lr_array[l_index].paccod   ,
                                 lr_array[l_index].pacdes   ,
                                 lr_array[l_index].paclim   ,
                                 lr_array[l_index].pacuni

           let l_index = l_index + 1

           if l_index > 500 then
              error "Limite excedido. Foram Encontrados mais de 500 Registros!"
              exit foreach
           end if

     end foreach

     open window ctc69m03 at 6,2 with form "ctc69m03"
        attribute (border,form line 1)

     message " (F17)Abandona, (F7)Servicos, (F8)Confirma"
     call set_count(l_index-1)

     display array lr_array to s_ctc69m03.*

        on key (interrupt,control-c)
           initialize lr_array to null
           let l_index = 1
           exit display
       on key (f7)
           let l_index = arr_curr()
           call ctc69m00_popup(lr_array[l_index].paccod)
           returning l_acesso
           if l_acesso = 1 then
              exit display
           end if

        on key (f8)
           let l_index = arr_curr()
           exit display
     end display

     close window ctc69m03
     let int_flag = false

     return lr_array[l_index].paccod,
            lr_array[l_index].pacdes,
            lr_array[l_index].paclim,
            lr_array[l_index].pacuni

end function

#----------------------------------------------#
function ctc69m03_recupera_descricao(lr_param)
#----------------------------------------------#

define lr_param record
  paccod integer
end record

define lr_retorno record
  pacdes    char(60) ,
  paclim    dec(13,2),
  pacuni    char(60)
end record

initialize lr_retorno.* to null



     call ctc69m03_prepare()

     open c_ctc69m03_002 using lr_param.paccod

     whenever error continue
     fetch c_ctc69m03_002 into lr_retorno.pacdes,
                               lr_retorno.paclim,
                               lr_retorno.pacuni
     whenever error stop

     if sqlca.sqlcode = notfound  then
        error "Pacote Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar o Pacote ", sqlca.sqlcode
       end if
     end if

     close c_ctc69m03_002


    return lr_retorno.pacdes,
           lr_retorno.paclim,
           lr_retorno.pacuni

end function







