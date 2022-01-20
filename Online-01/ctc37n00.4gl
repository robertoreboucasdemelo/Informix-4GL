###############################################################################
# Nome do Modulo: CTC37N00                                           Gilberto #
#                                                                    Marcelo  #
#                                                                    Wagner   #
# Menu de Observacoes de vistoria auto-socorro                       Dez/1998 #
###############################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctc37n00(k_ctc37n00)
#-----------------------------------------------------------

  define k_ctc37n00  record
     socvstnum       like datmvstobs.socvstnum,
     cademp          like datmvstobs.cademp,
     cadmat          like datmvstobs.cadmat
  end record

 open window w_ctc37n00 at 04,02 with form "ctc37m01"

 display by name k_ctc37n00.socvstnum

 let int_flag = false

 menu "OBSERVACOES"
    command key ("I") "Implementa" "Implementa dados de observacao"
       call ctc37m01(k_ctc37n00.*)
       clear form
       display by name k_ctc37n00.socvstnum
       next option "Encerra"

    command key ("C") "Consulta" "Consulta observacoes ja' cadastradas"
       call ctc37m02(k_ctc37n00.socvstnum)
       clear form
       display by name k_ctc37n00.socvstnum
       next option "Encerra"

    command key (interrupt,"E")  "Encerra" "Retorna ao menu anterior"
       if g_documento.acao is not null then
          error " Obrigatorio registrar algo na observacao!"
          next option "Implementa"
       else
          exit menu
       end if
 end menu

 let int_flag = false

 close window w_ctc37n00

end function  ###  ctc37n00
