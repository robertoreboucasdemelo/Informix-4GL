#-----------------------------------------------------------------------------#
# Nome do Modulo: CTB11M04                                           Marcelo  #
#                                                                    Gilberto #
# Mostra todos destinos da ordem de pagamento                        Dez/1996 #
# ........................................................................... #
# Alteracoes                                                                  #
# 27/08/2009  PSI198404  Fabio Costa  Filtrar destino pagto ativo             #
#-----------------------------------------------------------------------------#
database porto

#-----------------------------------------------------------
function ctb11m04()
#-----------------------------------------------------------

  define a_ctb11m04 array[400] of record
     pgtdstdes       like fpgkpgtdst.pgtdstdes,
     pgtdstcod       like fpgkpgtdst.pgtdstcod
  end record
 
  define arr_aux smallint
 
  initialize a_ctb11m04 to null
  initialize arr_aux to null
  
  let arr_aux = 1
 
  open window ctb11m04 at 10,31 with form "ctb11m04"
              attribute (form line first, border)
 
  declare  c_ctb11m04  cursor for
    select pgtdstdes, pgtdstcod
      from fpgkpgtdst
     where fpgkpgtdst.pgtdstcod > 0
       and fpgkpgtdst.pgtdstsit = 'A'
  order by pgtdstdes
  
  foreach  c_ctb11m04  into  a_ctb11m04[arr_aux].pgtdstdes,
                             a_ctb11m04[arr_aux].pgtdstcod
 
       let arr_aux = arr_aux + 1
       if arr_aux > 400   then
          error "Limite excedido. Cadastro com mais de 400 destinos!"
          exit foreach
       end if
  end foreach
 
  message " (F17)Abandona, (F8)Seleciona"
  call set_count(arr_aux - 1)
 
  display array  a_ctb11m04 to s_ctb11m04.*
    on key(interrupt)
       initialize a_ctb11m04   to null
       exit display
 
    on key(F8)
       let arr_aux = arr_curr()
       exit display
  end display
 
  let int_flag = false
  close window ctb11m04
 
  return a_ctb11m04[arr_aux].pgtdstcod

end function  ###  ctb11m04

