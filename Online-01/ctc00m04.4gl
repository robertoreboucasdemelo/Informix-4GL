###############################################################################
# Nome do Modulo: CTC00M04                                           Marcelo  #
#                                                                    Gilberto #
# Manutencao no horario de funcionamento dos prestadores             Jan/1997 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctc00m04(d_ctc00m04)
#-----------------------------------------------------------

 define d_ctc00m04  record
    horsegsexinc    like dpaksocor.horsegsexinc,
    horsegsexfnl    like dpaksocor.horsegsexfnl,
    horsabinc       like dpaksocor.horsabinc   ,
    horsabfnl       like dpaksocor.horsabfnl   ,
    hordominc       like dpaksocor.hordominc   ,
    hordomfnl       like dpaksocor.hordomfnl
 end record

 open window ctc00m04 at 11,46 with form "ctc00m04"
                         attribute (border, form line 1)

 let int_flag  =  false

 input by name d_ctc00m04.horsegsexinc,
               d_ctc00m04.horsegsexfnl,
               d_ctc00m04.horsabinc   ,
               d_ctc00m04.horsabfnl   ,
               d_ctc00m04.hordominc   ,
               d_ctc00m04.hordomfnl     without defaults

    before field horsegsexinc
       display by name d_ctc00m04.horsegsexinc attribute (reverse)

    after  field horsegsexinc
       display by name d_ctc00m04.horsegsexinc

    before field horsegsexfnl
       display by name d_ctc00m04.horsegsexfnl attribute (reverse)

    after  field horsegsexfnl
       display by name d_ctc00m04.horsegsexfnl

       if d_ctc00m04.horsegsexinc is null      and
          d_ctc00m04.horsegsexfnl is not null  then
          error "Horario de funcionamento invalido!"
          next field horsegsexinc
       end if

       if d_ctc00m04.horsegsexinc is not null  and
          d_ctc00m04.horsegsexfnl is null      then
          error "Horario de funcionamento invalido!"
          next field horsegsexfnl
       end if

       if d_ctc00m04.horsegsexinc is not null  and
          d_ctc00m04.horsegsexfnl is not null  and
          d_ctc00m04.horsegsexfnl <= d_ctc00m04.horsegsexinc then
          error "Horario de funcionamento incorreto!"
          next field horsegsexinc
       end if

       if d_ctc00m04.horsegsexinc <> "00:00"   and
          d_ctc00m04.horsegsexinc is not null  and
          d_ctc00m04.horsegsexfnl =  "00:00"   then
          error "Horario de funcionamento incorreto!"
          next field horsegsexinc
       end if

    before field horsabinc
       display by name d_ctc00m04.horsabinc  attribute (reverse)

    after  field horsabinc
       display by name d_ctc00m04.horsabinc

    before field horsabfnl
       display by name d_ctc00m04.horsabfnl  attribute (reverse)

    after  field horsabfnl
       display by name d_ctc00m04.horsabfnl

       if d_ctc00m04.horsabinc is null      and
          d_ctc00m04.horsabfnl is not null  then
          error "Horario de funcionamento invalido!"
          next field horsabinc
       end if

       if d_ctc00m04.horsabinc is not null  and
          d_ctc00m04.horsabfnl is null      then
          error "Horario de funcionamento invalido!"
          next field horsabfnl
       end if

       if d_ctc00m04.horsabinc is not null  and
          d_ctc00m04.horsabfnl is not null  and
          d_ctc00m04.horsabfnl <= d_ctc00m04.horsabinc then
          error "Horario de funcionamento incorreto!"
          next field horsabinc
       end if

       if d_ctc00m04.horsabinc <> "00:00"   and
          d_ctc00m04.horsabinc is not null  and
          d_ctc00m04.horsabfnl =  "00:00"   then
          error "Horario de funcionamento incorreto!"
          next field horsabinc
       end if

    before field hordominc
       display by name d_ctc00m04.hordominc  attribute (reverse)

    after  field hordominc
       display by name d_ctc00m04.hordominc

    before field hordomfnl
       display by name d_ctc00m04.hordomfnl  attribute (reverse)

    after  field hordomfnl
       display by name d_ctc00m04.hordomfnl

       if d_ctc00m04.hordominc is null      and
          d_ctc00m04.hordomfnl is not null  then
          error "Horario de funcionamento invalido!"
          next field hordominc
       end if

       if d_ctc00m04.hordominc is not null  and
          d_ctc00m04.hordomfnl is null      then
          error "Horario de funcionamento invalido!"
          next field hordomfnl
       end if

       if d_ctc00m04.hordominc is not null  and
          d_ctc00m04.hordomfnl is not null  and
          d_ctc00m04.hordomfnl <= d_ctc00m04.hordominc then
          error "Horario de funcionamento incorreto!"
          next field hordominc
       end if

       if d_ctc00m04.hordominc <> "00:00"   and
          d_ctc00m04.hordominc is not null  and
          d_ctc00m04.hordomfnl =  "00:00"   then
          error "Horario de funcionamento incorreto!"
          next field hordominc
       end if

    on key (interrupt)
       exit input

 end input

 let int_flag = false
 close window ctc00m04

 return d_ctc00m04.*

end function  #  ctc00m04
