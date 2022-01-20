###############################################################################
# Nome do Modulo: CTB03M05                                           Wagner   #
# Exibe pop-up OP-s relacionadas a este servico                      Jul/2001 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctb03m05(param)                             
#-----------------------------------------------------------

 define param      record
   atdsrvnum       like datmservico.atdsrvnum,
   atdsrvano       like datmservico.atdsrvano
 end record

 define a_ctb03m05 array[30] of record
   socopgnum       like dbsmopg.socopgnum,
   pagas           integer,
   rsrincdat       like dbsmopgitm.rsrincdat,
   rsrfnldat       like dbsmopgitm.rsrfnldat
 end record

 define arr_aux    smallint
 
 open window ctb03m05 at 12,39 with form "ctb03m05"
                      attribute(form line 1, border)

 let int_flag = false
 initialize a_ctb03m05   to null

 declare c_ctb03m05 cursor for
  select dbsmopgitm.socopgnum, dbsmopgitm.c24pagdiaqtd,
         dbsmopgitm.rsrincdat, dbsmopgitm.rsrfnldat
    from dbsmopgitm, dbsmopg
   where dbsmopgitm.atdsrvnum = param.atdsrvnum 
     and dbsmopgitm.atdsrvano = param.atdsrvano 
     and dbsmopg.socopgnum    = dbsmopgitm.socopgnum
     and dbsmopg.socopgsitcod <> 8
   order by dbsmopgitm.socopgnum

 let arr_aux  = 1

 foreach c_ctb03m05 into a_ctb03m05[arr_aux].socopgnum, 
                         a_ctb03m05[arr_aux].pagas,
                         a_ctb03m05[arr_aux].rsrincdat,
                         a_ctb03m05[arr_aux].rsrfnldat

    let arr_aux = arr_aux + 1

    if arr_aux  >  30 then 
       error "Limite excedido. Foram encontradas mais de 30 OP' relacionadas!"
       exit foreach
    end if

 end foreach

 message " (F17)Abandona"
 call set_count(arr_aux-1)

 display array a_ctb03m05 to s_ctb03m05.*

    on key (interrupt,control-c)
       exit display

 end display

 let int_flag = false
 initialize a_ctb03m05   to null
 close window ctb03m05

end function  ###  ctb03m05
