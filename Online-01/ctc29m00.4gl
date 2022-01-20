############################################################################
# Nome do Modulo: CTC29M00                                        Marcelo  #
#                                                                 Gilberto #
# Identificacao do relatorio solicitado                           Mai/1996 #
############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc29m00()
#---------------------------------------------------------------

 define d_ctc29m00 record
    relsgl         char (08)           ,
    reldes         like dgbkrel.reldes
 end record

 let int_flag  =  false

 open window ctc29m00 at 06,02 with form "ctc29m00"
             attribute (form line 1)

 while TRUE

    clear form
    initialize d_ctc29m00.* to null
    input by name d_ctc29m00.relsgl without defaults

        before field relsgl
               display by name d_ctc29m00.relsgl    attribute (reverse)

        after  field relsgl
               display by name d_ctc29m00.relsgl
               if d_ctc29m00.relsgl  is null  or
                  d_ctc29m00.relsgl  =  " "   then
                  error " Sigla do relatorio nao informada! " ,
                        "Consulte a lista de relatorios disponiveis!"
                  call ctc29m01() returning d_ctc29m00.relsgl
                  next field relsgl
               else
                  select reldes into d_ctc29m00.reldes
                    from dgbkrel where relsgl = d_ctc29m00.relsgl

                  if d_ctc29m00.reldes is null then
                     error " Sigla do relatorio invalida!"
                     next field relsgl
                  end if
               end if

        on key (interrupt,control-c)
           exit input

      end input

      if int_flag then
         exit while
      end if

      display by name d_ctc29m00.*

      case d_ctc29m00.relsgl
         when 'RDAT005'
            call ctc29m03()
         otherwise
            error " Este relatorio nao permite solicitacao via sistema!"
      end case

   end while

let int_flag = false
close window ctc29m00
end function  #  ctc29m00
