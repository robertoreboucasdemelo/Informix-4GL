database porto

define wa          record
   atdsrvnum       decimal(10,0),
   atdsrvano       decimal(2,0), 
   c24evtcod       smallint,   
   srvanlhstseq    smallint 
end record
 
main

   declare cur001 cursor for
    select atdsrvnum, atdsrvano, 
           c24evtcod, srvanlhstseq   
      from datmsrvanlhst
     where atdsrvnum    is not null
       and atdsrvano    is not null
       and c24evtcod    = 12          
       and srvanlhstseq > 0     

   foreach cur001 into wa.atdsrvnum, wa.atdsrvano,
                       wa.c24evtcod, wa.srvanlhstseq   
  
      delete from datmsrvanlhst 
       where atdsrvnum    = wa.atdsrvnum
         and atdsrvano    = wa.atdsrvano
         and c24evtcod    = 12          
         and srvanlhstseq = wa.srvanlhstseq   
   end foreach

end main

