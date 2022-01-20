###########################################################################
# Nome do Modulo: cta01m57                                       Marcelo  #
#                                                                Gilberto #
# Lista os adicionais do cartao                                  Jan/1996 #
###########################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function  cta01m57()
#---------------------------------------------------------------

   define a_cta01m57 array [04] of record
          cartao        dec(16),
          pcacarseq     like eccmpti.pcaptitip,
          pcacarnom     like eccmpti.pcaptinom,
          situacao      char(09)
   end record

   define ws            record
          pcacarseq     like eccmpti.pcaptitip,
          pcacarnom     like eccmpti.pcaptinom,
          pcacarstt     like eccmpti.pcaptistt,
          pcapticod     like eccmpti.pcapticod,
          conta         like eccmpti.pcactacod
   end record

   define arr_aux       integer
   define scr_aux       integer
   define nro_lin_corr  integer
   define scr_lin_corr  integer



	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null
	let	nro_lin_corr  =  null
	let	scr_lin_corr  =  null

	for	w_pf1  =  1  to  4
		initialize  a_cta01m57[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

   open window cta01m57 at 13,2 with form "cta01m57"
               attribute(form line 1)

   initialize  a_cta01m57      to null
   initialize  ws.*            to null
   let arr_aux = 1

   select pcactacod into ws.conta from eccmpti
    where pcapticod = g_documento.pcacarnum

   declare c_cta01m57_001   cursor for
      select  pcaptitip, pcaptinom, pcaptistt,pcapticod
         from eccmpti
         where eccmpti.pcactacod = ws.conta                 and
               eccmpti.pcaptitip > 1

      foreach c_cta01m57_001   into ws.pcacarseq,
                                ws.pcacarnom,
                                ws.pcacarstt,
                                ws.pcapticod

         if arr_aux > 3    then
            message "ASSOCIADO COM MAIS DE 3 CARTOES ADICIONAIS"
            sleep 3
            exit foreach
         end if

         let a_cta01m57[arr_aux].cartao  = ws.pcapticod
         let a_cta01m57[arr_aux].pcacarseq  = ws.pcacarseq
         let a_cta01m57[arr_aux].pcacarnom  = ws.pcacarnom

         case ws.pcacarstt
              when  "A"
                    let a_cta01m57[arr_aux].situacao = "ATIVO"
              when  "B"
                    let a_cta01m57[arr_aux].situacao = "BLOQUEADO"
              when  "C"
                    let a_cta01m57[arr_aux].situacao = "CANCELADO"
              otherwise
                    let a_cta01m57[arr_aux].situacao = "N/PREVISTO"
         end case

         let arr_aux = arr_aux + 1

     end foreach

     message " (F17)Abandona"
     call set_count(arr_aux-1)

     display array a_cta01m57 to s_cta01m57.*
        on key (interrupt,control-c)
           initialize a_cta01m57 to null
           exit display

        on key (f8)
           exit display
     end display

     clear form
     close  window cta01m57

end function  #  cta01m57

