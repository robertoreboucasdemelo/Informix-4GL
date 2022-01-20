###############################################################################
# Nome do Modulo: CTS02M06                                           Pedro    #
#                                                                    Marcelo  #
# Confirma Liberacao de Servico                                      Fev/1995 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl" 

#-----------------------------------------------------------
function cts02m06()
#-----------------------------------------------------------

 define  d_cts02m06   record
   atdlibflg   like datmservico.atdlibflg
 end record




	initialize  d_cts02m06.*  to  null

 open window cts02m06 at 12,26 with form "cts02m06"
                         attribute (border, form line 1)

 display "     Liberacao do servico" to cabec   attribute(reverse)
 let int_flag  =  false
 initialize d_cts02m06.*  to null

 input by name d_cts02m06.atdlibflg

   before field atdlibflg
      display by name d_cts02m06.atdlibflg attribute (reverse)

   after field atdlibflg
      display by name d_cts02m06.atdlibflg

      if ((d_cts02m06.atdlibflg  is null)   or
          (d_cts02m06.atdlibflg  <> "S"     and
           d_cts02m06.atdlibflg  <> "N"))   then
         error " Servico liberado: (S)im ou (N)ao"
         next field atdlibflg
      end if

   on key (interrupt)
      exit input

 end input

 let int_flag = false
 close window cts02m06

 return d_cts02m06.atdlibflg

end function  #  cts02m06
