###############################################################################
# Nome do Modulo: CTA02M12                                           Ruiz     #
# Solicita o numero do Aviso marcado via Internet                    fev/2001 #
# este modulo e chamado pelo prog. do agendamento osvom005(marcelo fornachari)#
###############################################################################

database porto

#------------------------------------------------------------
 function cta02m12()
#------------------------------------------------------------

 define d_cta02m12    record
    sinavsnum         like datrligsinavs.sinavsnum,
    sinavsano         like datrligsinavs.sinavsano
 end record

 open window w_cta02m12 at 10,36 with form "cta02m12"
                        attribute(border, form line 1)


 input by name d_cta02m12.* #without defaults

    before field sinavsnum
       display by name d_cta02m12.sinavsnum attribute (reverse)

    after  field sinavsnum
       display by name d_cta02m12.sinavsnum

       if d_cta02m12.sinavsnum is null   or
          d_cta02m12.sinavsnum  =  " "   then
          let d_cta02m12.sinavsnum = 0
       end if

    before field sinavsano
       display by name d_cta02m12.sinavsano attribute (reverse)

    after  field sinavsano
       display by name d_cta02m12.sinavsano

       if d_cta02m12.sinavsano is null  or
          d_cta02m12.sinavsano  =  " "   then
          let d_cta02m12.sinavsano = 0
       end if

    on key (interrupt)
       initialize d_cta02m12.* to null
       exit input

 end input

 let int_flag = false
 close window w_cta02m12

 return d_cta02m12.*

end function  ###  cta02m12
