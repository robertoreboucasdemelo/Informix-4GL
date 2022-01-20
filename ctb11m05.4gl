###############################################################################
# Nome do Modulo: CTB11M05                                           Gilberto #
#                                                                     Marcelo #
# Consulta dados sobre favorecido (Ordem de pagamento)               Dez/1996 #
###############################################################################

database porto

#--------------------------------------------------------------
 function ctb11m05(param)
#--------------------------------------------------------------

 define  param        record
         pstcoddig    like dpaksocor.pstcoddig
 end record

 define  d_ctb11m05   record
         nomrazsoc    like dpaksocor.nomrazsoc,
         nomgrr       like dpaksocor.nomgrr,
         socpgtopccod like dpaksocorfav.socpgtopccod,
         socpgtopcdes char(10),
         socfavnom    like dpaksocorfav.socfavnom,
         pestip       like dpaksocorfav.pestip,
         cgccpfnum    like dpaksocorfav.cgccpfnum,
         cgcord       like dpaksocorfav.cgcord,
         cgccpfdig    like dpaksocorfav.cgccpfdig,
         bcocod       like dpaksocorfav.bcocod,
         bcosgl       like gcdkbanco.bcosgl,
         bcoagnnum    like dpaksocorfav.bcoagnnum,
         bcoagndig    like dpaksocorfav.bcoagndig,
         bcoagnnom    like gcdkbancoage.bcoagnnom,
         bcoctatip    like dpaksocorfav.bcoctatip,
         bcoctatipdes char(10),
         bcoctanum    like dpaksocorfav.bcoctanum,
         bcoctadig    like dpaksocorfav.bcoctadig,
         confirma     char(1)
 end record

 define  ws           record
         bcoagnnum    like gcdkbancoage.bcoagnnum
 end record

 initialize d_ctb11m05.*  to null
 initialize ws.*          to null
 let int_flag             =  false


 open window ctb11m05 at 10,19 with form "ctb11m05"
                         attribute (form line 1, border)

 input by name d_ctb11m05.confirma   without defaults

   before field confirma
          select nomrazsoc, nomgrr
            into d_ctb11m05.nomrazsoc, d_ctb11m05.nomgrr
            from dpaksocor
           where dpaksocor.pstcoddig = param.pstcoddig

          if sqlca.sqlcode <> 0   then
             error " Erro (",sqlca.sqlcode,") na leitura do prestador!"
             sleep 5
             exit input
          end if

          select pestip   , cgccpfnum   , cgcord   ,
                 cgccpfdig, socfavnom   , bcocod   ,
                 bcoagnnum, bcoagndig   , bcoctanum,
                 bcoctadig, socpgtopccod, bcoctatip
            into d_ctb11m05.pestip      , d_ctb11m05.cgccpfnum,
                 d_ctb11m05.cgcord      , d_ctb11m05.cgccpfdig,
                 d_ctb11m05.socfavnom   , d_ctb11m05.bcocod,
                 d_ctb11m05.bcoagnnum   , d_ctb11m05.bcoagndig,
                 d_ctb11m05.bcoctanum   , d_ctb11m05.bcoctadig,
                 d_ctb11m05.socpgtopccod, d_ctb11m05.bcoctatip
            from dpaksocorfav
           where dpaksocorfav.pstcoddig = param.pstcoddig

          if sqlca.sqlcode <> 0   then
             error " Erro (",sqlca.sqlcode,") na leitura do favorecido!"
             sleep 5
             exit input
          end if

         select cpodes
           into d_ctb11m05.socpgtopcdes
           from iddkdominio
          where iddkdominio.cponom = "socpgtopccod"         and
                iddkdominio.cpocod = d_ctb11m05.socpgtopccod

         if sqlca.sqlcode <> 0    then
             error " Erro (",sqlca.sqlcode,") na leitura opcao de pagamento!"
             sleep 5
             exit input
         end if

          case d_ctb11m05.bcoctatip
            when  1
                  let d_ctb11m05.bcoctatipdes = "C.CORRENTE"
            when  2
                  let d_ctb11m05.bcoctatipdes = "POUPANCA"
          end case

          if d_ctb11m05.bcocod   is not null   and
             d_ctb11m05.bcocod   <> 0          then
             select bcosgl
               into d_ctb11m05.bcosgl
               from gcdkbanco
              where gcdkbanco.bcocod = d_ctb11m05.bcocod

             if sqlca.sqlcode <> 0   then
                error " Erro (",sqlca.sqlcode,") na leitura do nome do banco!"
                sleep 5
                exit input
             end if
          end if

          if d_ctb11m05.bcoagnnum   is not null   and
             d_ctb11m05.bcoagnnum   <>  0         then
             let ws.bcoagnnum = d_ctb11m05.bcoagnnum

             select bcoagnnom
               into d_ctb11m05.bcoagnnom
               from gcdkbancoage
              where gcdkbancoage.bcocod    = d_ctb11m05.bcocod     and
                    gcdkbancoage.bcoagnnum = ws.bcoagnnum
          end if

          display by name d_ctb11m05.*
          display by name d_ctb11m05.confirma   attribute (reverse)

   after  field confirma
          display by name d_ctb11m05.confirma

          if ((d_ctb11m05.confirma   is null)    or
              (d_ctb11m05.confirma   <> "S"      and
               d_ctb11m05.confirma   <> "N"))    then
             error " Confirma deve ser: (S)im ou (N)ao !"
             next field confirma
          end if

          if d_ctb11m05.confirma  =  "N"   then
             initialize d_ctb11m05.*   to null
          end if

   on key (interrupt)
      exit input

 end input

 if int_flag   then
    initialize d_ctb11m05.*   to null
 end if

close window ctb11m05

return  d_ctb11m05.pestip      , d_ctb11m05.cgccpfnum,
        d_ctb11m05.cgcord      , d_ctb11m05.cgccpfdig,
        d_ctb11m05.socfavnom   , d_ctb11m05.bcocod   ,
        d_ctb11m05.bcosgl      , d_ctb11m05.bcoagnnum,
        d_ctb11m05.bcoagndig   , d_ctb11m05.bcoagnnom,
        d_ctb11m05.bcoctanum   , d_ctb11m05.bcoctadig,
        d_ctb11m05.socpgtopccod, d_ctb11m05.socpgtopcdes,
        d_ctb11m05.bcoctatip   , d_ctb11m05.bcoctatipdes,
        d_ctb11m05.confirma

end function  #  ctb11m05
