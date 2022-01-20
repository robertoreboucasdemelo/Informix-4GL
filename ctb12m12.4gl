###############################################################################
# Nome do Modulo: CTB12m12                                           Wagner   #
# Exibe pop-up servicos relacionados                                 Jul/2001 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctb12m12(param)
#-----------------------------------------------------------

 define param      record
   atdsrvnum       like datmservico.atdsrvnum,
   atdsrvano       like datmservico.atdsrvano
 end record

 define a_ctb12m12 array[30] of record
   linha           char(50)
 end record

 define ws         record
   atddat          like datmservico.atddat,   
   atdsrvnum       like datmsrvre.atdsrvnum,
   atdsrvano       like datmsrvre.atdsrvano,
   socntzcod       like datmsrvre.socntzcod,
   socntzdes       like datksocntz.socntzdes,
   total           char (08),
   atdetpcod       like datmsrvacp.atdetpcod,
   comando         char (400),
   count           char (50)
 end record

 define arr_aux    smallint,
        cont_aux   smallint

 let ws.comando = "select atdetpcod    ",
                  "  from datmsrvacp   ",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?",
                  "   and atdsrvseq = (select max(atdsrvseq)",
                                      "  from datmsrvacp    ",
                                      " where atdsrvnum = ? ",
                                      "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from ws.comando
 declare c_datmsrvacp cursor for sel_datmsrvacp                     
 
 select count(*)
   into ws.count
   from datmsrvre
  where datmsrvre.atdorgsrvnum = param.atdsrvnum
    and datmsrvre.atdorgsrvano = param.atdsrvano

 let cont_aux = 0
 
 if ws.count is  null or
    ws.count = 0     then        
    
    select atdorgsrvnum, atdorgsrvano
      into ws.atdsrvnum, ws.atdsrvano
      from datmsrvre
     where datmsrvre.atdsrvnum = param.atdsrvnum
       and datmsrvre.atdsrvano = param.atdsrvano       

    if ws.atdsrvnum is  null then
 
       return
    else
       let param.atdsrvnum = ws.atdsrvnum
       let param.atdsrvano = ws.atdsrvano
       let cont_aux = 1
    end if
 end if

 let int_flag = false
 initialize a_ctb12m12   to null
 initialize ws.*         to null

 select socntzcod, atddat
   into ws.socntzcod, ws.atddat
   from datmsrvre, datmservico
  where datmsrvre.atdsrvnum   = param.atdsrvnum
    and datmsrvre.atdsrvano   = param.atdsrvano
    and datmservico.atdsrvnum = param.atdsrvnum
    and datmservico.atdsrvano = param.atdsrvano

 initialize ws.socntzdes to null
 select socntzdes
   into ws.socntzdes
   from datksocntz
  where socntzcod = ws.socntzcod

 let a_ctb12m12[1].linha = "09/", param.atdsrvnum using "&&&&&&&","-",
                                  param.atdsrvano using "&&",
                           " ", ws.socntzcod using "&&",
                           "-", ws.socntzdes clipped
 let a_ctb12m12[1].linha[30,40] = " ",ws.atddat
 
 let a_ctb12m12[1].linha = a_ctb12m12[1].linha clipped, "  O"
 
 select count(*)
   into ws.count 
  from datmsrvre, datmservico                   
 where datmsrvre.atdorgsrvnum = param.atdsrvnum 
   and datmsrvre.atdorgsrvano = param.atdsrvano 
   and datmservico.atdsrvnum  = param.atdsrvnum 
   and datmservico.atdsrvano  = param.atdsrvano   
   
 declare c_ctb12m12 cursor for
  select datmsrvre.socntzcod, datmsrvre.atdsrvnum, 
         datmsrvre.atdsrvano, datmservico.atddat 
    from datmsrvre, datmservico
   where datmsrvre.atdorgsrvnum = param.atdsrvnum
     and datmsrvre.atdorgsrvano = param.atdsrvano
     and datmservico.atdsrvnum  = param.atdsrvnum
     and datmservico.atdsrvano  = param.atdsrvano
   order by atdsrvnum, atdsrvano

 let arr_aux  = 2
 
 foreach c_ctb12m12 into ws.socntzcod, ws.atdsrvnum, ws.atdsrvano, ws.atddat  
    #------------------------------------------------------------
    # VERIFICA ETAPA DO SERVICO
    #------------------------------------------------------------
    
    open  c_datmsrvacp using  ws.atdsrvnum, ws.atdsrvano, 
                              ws.atdsrvnum, ws.atdsrvano
    fetch c_datmsrvacp into   ws.atdetpcod
    close c_datmsrvacp
    
    if ws.atdetpcod = 5   or
       ws.atdetpcod = 6   then
 
       continue foreach
    end if
    
    select socntzcod, atddat
     into ws.socntzcod, ws.atddat
     from datmsrvre, datmservico
    where datmsrvre.atdsrvnum   = ws.atdsrvnum
      and datmsrvre.atdsrvano   = ws.atdsrvano
      and datmservico.atdsrvnum = ws.atdsrvnum
      and datmservico.atdsrvano = ws.atdsrvano
      
    initialize ws.socntzdes to null 
    select socntzdes                
      into ws.socntzdes             
      from datksocntz               
     where socntzcod = ws.socntzcod 
    
    let a_ctb12m12[arr_aux].linha = "09/", ws.atdsrvnum using "&&&&&&&","-",
                                     ws.atdsrvano using "&&",
                                    " ", ws.socntzcod using "&&",
                                    "-", ws.socntzdes clipped
    let a_ctb12m12[arr_aux].linha[30,40] = " ",ws.atddat
    
    let a_ctb12m12[arr_aux].linha = a_ctb12m12[arr_aux].linha clipped, "  R"  

    let arr_aux = arr_aux + 1
    let cont_aux = cont_aux + 1
    if arr_aux  >  30 then
       error "Limite excedido. Foram encontradas mais de 30 servicos!"
       exit foreach
    end if

 end foreach

 if  cont_aux > 0 then
 
     open window ctb12m12 at 12,32 with form "ctb12m12"
                          attribute(form line 1, border)
     
     let ws.total = "total ",arr_aux -1  using "&&"
     display ws.total to total attribute(reverse)
     
     message " (F17)Abandona"
     call set_count(arr_aux-1)
     
     display array a_ctb12m12 to s_ctb12m12.*
     
        on key (interrupt,control-c)
           exit display
     
     end display
     
     let int_flag = false
     initialize a_ctb12m12   to null
     close window ctb12m12
 end if

end function  ###  ctb12m12
