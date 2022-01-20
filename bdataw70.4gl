#############################################################################
# Nome do Modulo: bdataw70                                         Wagner   #
# recarga ATDSRVORG na tabela dagksrvfat                           jul/2000 #
#############################################################################

 database porto

 main
    set isolation to dirty read
    call bdataw70()
 end main

#---------------------------------------------------------------
 function bdataw70()
#---------------------------------------------------------------

 define ws          record
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    atdsrvorg       like datmservico.atdsrvorg,
    pardat1         date,
    pardat2         date,
    auxdat1         char (10),
    auxdat2         char (10)
 end record

 initialize ws.*          to null


#---------------------------------------------------------------
# Data parametro para extracao das ligacoes
#---------------------------------------------------------------

 let ws.auxdat1 = arg_val(1)
 let ws.auxdat2 = arg_val(2)

 let ws.pardat1 = ws.auxdat1
 let ws.pardat2 = ws.auxdat2

#---------------------------------------------------------------
# Leitura principal
#---------------------------------------------------------------

 declare c_datmservico cursor for
  select atdsrvnum, atdsrvano, atdsrvorg
    from datmservico
   where atddat  between  ws.pardat1  and  ws.pardat2

 foreach c_datmservico into  ws.atdsrvnum,
                             ws.atdsrvano,
                             ws.atdsrvorg

       select atdsrvorg
         from dmct24h@u33:dagksrvfat
        where atdsrvnum = ws.atdsrvnum
          and atdsrvano = ws.atdsrvano

       if sqlca.sqlcode = 0 then
          update dmct24h@u33:dagksrvfat set atdsrvorg = ws.atdsrvorg
           where atdsrvnum = ws.atdsrvnum
             and atdsrvano = ws.atdsrvano
       end if

 end foreach

end function  ###  bdataw70

