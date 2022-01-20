###############################################################################
# Nome do Modulo: CTB11M15                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Janela para informar Nr.NF para pagamento                          Mai/1999 #
###############################################################################

 database porto

#-----------------------------------------------------------------------------
 function ctb11m15(d_ctb11m15)
#-----------------------------------------------------------------------------

 define d_ctb11m15   record
    nfsnum           integer
 end record

 open window w_ctb11m15 at 11,19 with form "ctb11m15"
           attribute(border, form line first, message line last - 1)

    input by name d_ctb11m15.nfsnum without defaults

       before field nfsnum
          display by name d_ctb11m15.nfsnum  attribute (reverse)

       after field nfsnum
          display by name d_ctb11m15.nfsnum

          if d_ctb11m15.nfsnum  =  0   then
             error " Numero da nota fiscal nao deve ser zeros!"
             next field nfsnum
          end if

       on key (interrupt, control-c)
          exit input

    end input

 let int_flag = false
 close window w_ctb11m15

 return d_ctb11m15.nfsnum

end function  ###  ctb11m15

