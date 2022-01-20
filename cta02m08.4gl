###############################################################################
# Nome do Modulo: CTA02M08                                           Marcelo  #
#                                                                    Gilberto #
# Informa dados para contato com reclamante                          Jul/1997 #
###############################################################################
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# ---------- ------------- ------    ----------------------------------------#
# 16/04/2012 Silvia,Meta  PSI2012-07408  Projeto Anatel-Aumento DDD/Telefone #
#----------------------------------------------------------------------------#
database porto

#------------------------------------------------------------
 function cta02m08(d_cta02m08)
#------------------------------------------------------------

 define d_cta02m08    record
    dddcod            like datmreclam.dddcod,
    ctttel            like datmreclam.ctttel,
    faxnum            like datmreclam.faxnum,
    cttnom            like datmreclam.cttnom
 end record

 define i  smallint


	let	i  =  null

 open window w_cta02m08 at 10,36 with form "cta02m08"
                        attribute(border, form line 1)


 input by name d_cta02m08.*  without defaults

    before field dddcod
       display by name d_cta02m08.dddcod    attribute (reverse)

    after  field dddcod
       display by name d_cta02m08.dddcod

       if d_cta02m08.dddcod is null   or
          d_cta02m08.dddcod =  " "    then
          error "DDD para contato e' item obrigatorio!"
          next field dddcod
       else
          for i = 1 to 4
             if d_cta02m08.dddcod[i,i] is not null  and
                d_cta02m08.dddcod[i,i] <> " "       then
                if d_cta02m08.dddcod[i,i] >= "0"  and
                   d_cta02m08.dddcod[i,i] <= "9"  then
                else
                   error "DDD para contato invalido! Informe novamente."
                   next field dddcod
                end if
             end if
          end for
       end if

    before field ctttel
       display by name d_cta02m08.ctttel   attribute (reverse)

    after  field ctttel
       display by name d_cta02m08.ctttel

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if d_cta02m08.ctttel is null  or
             d_cta02m08.ctttel =  " "   then
             error "Telefone para contato e' item obrigatorio!"
             next field ctttel
          else
             if length(d_cta02m08.ctttel) < 8 then ## Anatel < 6  then   
                error "Telefone para contato invalido! Informe novamente."
                next field ctttel
             end if
          end if
       end if

    before field faxnum
       display by name d_cta02m08.faxnum    attribute (reverse)

    after  field faxnum
       display by name d_cta02m08.faxnum

       if d_cta02m08.faxnum is not null  and
          d_cta02m08.faxnum <= 99999     then
          error "Numero de FAX invalido! Informe novamente."
          next field faxnum
       end if

    before field cttnom
       display by name d_cta02m08.cttnom     attribute (reverse)

    after  field cttnom
       display by name d_cta02m08.cttnom

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if d_cta02m08.cttnom is null  or
             d_cta02m08.cttnom =  " "   then
             error "Pessoa para contato e' item obrigatorio!"
             next field cttnom
          end if
       end if

    on key (interrupt)
       initialize d_cta02m08.* to null
       exit input

 end input

 let int_flag = false
 close window w_cta02m08

 return d_cta02m08.*

end function  ###  cta02m08
