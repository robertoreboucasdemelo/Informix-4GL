database porto

#------------------------------------------------------------
# Remocao na tabela dpatserv
#------------------------------------------------------------
function delete_dpatserv(r_fcpk10)
   define r_fcpk10 record
      pstcoddig    like   dpatserv.pstcoddig,
      pstsrvtip    like   dpatserv.pstsrvtip
   end record

   define cont_aux integer

   delete
     from dpatserv
   where
      pstcoddig =   r_fcpk10.pstcoddig   and
      pstsrvtip =   r_fcpk10.pstsrvtip

    return true

end function

#------------------------------------------------------------
# Remocao na tabela dparservlista
#------------------------------------------------------------
function delete_dparservlista(r_fcpk10)
   define r_fcpk10 record
      emplstcod    like   dparservlista.emplstcod,
      pstsrvtip    like   dparservlista.pstsrvtip
   end record

   define cont_aux integer

   delete
     from dparservlista
   where
      emplstcod =   r_fcpk10.emplstcod   and
      pstsrvtip =   r_fcpk10.pstsrvtip

    return true

end function

#------------------------------------------------------------
# Remocao na tabela DPCKSERV
#------------------------------------------------------------

function delete_dpckserv(r_fcpk10)

 define r_fcpk10 record
   pstsrvtip    like   dpatserv.pstsrvtip
 end record

 define cont_aux integer

 select count(*) into cont_aux
   from dpatserv
  where pstsrvtip = r_fcpk10.pstsrvtip

 if cont_aux > 0 then
    error "Nao foi possivel remover o servico! Existem referencias nos Servicos do Posto !"
    return false
 end if

 let cont_aux = 0

 select count(*) into cont_aux
   from dparservlista
  where pstsrvtip = r_fcpk10.pstsrvtip

 if cont_aux > 0 then
    error "Nao foi possivel remover o servico! Existem referencias na Lista Oesp!"
    return false
 end if

 delete from dpckserv
  where pstsrvtip =   r_fcpk10.pstsrvtip

 return true

end function

#------------------------------------------------------------
# Remocao na tabela dpatguincho
#------------------------------------------------------------
function delete_dpatguincho(r_fcpk10)
   define r_fcpk10 record
      pstcoddig    like   dpatguincho.pstcoddig,
      gchtip       like   dpatguincho.gchtip
   end record

   define cont_aux integer


   delete
     from dpatguincho
   where
      pstcoddig =   r_fcpk10.pstcoddig   and
      gchtip    =   r_fcpk10.gchtip

    return true


end function

#------------------------------------------------------------
# Remocao na tabela dpckguinco
#------------------------------------------------------------
function delete_dpckguincho(r_fcpk10)
   define r_fcpk10 record
      gchtip       like   dpckguincho.gchtip
   end record

   define cont_aux integer

   # verificacao de referencias na tabela servicos do posto
   #

   select count(*) into cont_aux
   from dpatguincho
   where
      gchtip    =   r_fcpk10.gchtip

   if cont_aux > 0 then
      error " Existem referencias nas Frotas do Posto  "
      return false
   end if

   delete
   from dpckguincho
   where
      gchtip    =   r_fcpk10.gchtip

   return true

end function
