###############################################################################
# Nome do Modulo: CTA02M09                                           Marcelo  #
#                                                                    Gilberto #
# Informe o numero da posicao de atendimento                         Abr/1997 #
###############################################################################

database porto

#-----------------------------------------------------------
 function cta02m09()
#-----------------------------------------------------------

 define d_cta02m09   record
   c24paxnum         like datmligacao.c24paxnum
 end record



	initialize  d_cta02m09.*  to  null

 open window cta02m09 at 13,34 with form "cta02m09"
                         attribute (border, form line 1)

 let int_flag  =  false

 initialize d_cta02m09.*  to null

 input by name d_cta02m09.c24paxnum without defaults

   before field c24paxnum
      display by name d_cta02m09.c24paxnum attribute (reverse)

   after  field c24paxnum
      display by name d_cta02m09.c24paxnum

      if d_cta02m09.c24paxnum is null  then
         error "Numero da Posicao de Atendimento e' obrigatorio!"
         next field c24paxnum
      end if

   on key (interrupt)
      initialize d_cta02m09.* to null
      exit input

 end input

 let int_flag = false

 close window cta02m09

 return d_cta02m09.c24paxnum

end function  #  cta02m09
