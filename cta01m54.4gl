###############################################################################
# Nome do Modulo: cta01m54                                           Marcelo  #
#                                                                    Gilberto #
# Pesquisa CGC/CPF                                                   Jan/1996 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------------------------
 function  cta01m54(par_pcaclicgc)
#-----------------------------------------------------------------------------

    define par_pcaclicgc like eccmcli.pcaclicgccpf

    define ret_pcapticod like eccmpti.pcapticod

    define a_cta01m54 array [50] of record
            cartao       dec(16,0),
            tpcar        char(03),
            pcaptinom    like eccmpti.pcaptinom,
            situacao     char(09)
    end record

    define  ws           record
            achou        char(1),
            pcactacod    like eccmpti.pcactacod,
            pcapticod    like eccmpti.pcapticod,
            pcaptitip    char(1)                  ,
            pcaptinom    like eccmpti.pcaptinom,
            pcaptistt    like eccmpti.pcaptistt
    end record

    define arr_aux       integer
    define scr_aux       integer


	define	w_pf1	integer

	let	ret_pcapticod  =  null
	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_cta01m54[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

    let arr_aux = 1
    initialize a_cta01m54  to null
    initialize ws.*        to null

    declare c_cta01m54_001       cursor for
       select pcactacod
          into ws.pcactacod
         from eccmcli a, eccmcta b
        where pcaclicgccpf = par_pcaclicgc  and
              a.pcaclicod  = b.pcaclicod

    foreach c_cta01m54_001    into  ws.pcactacod
       declare c_cta01m54_002       cursor for
          select pcapticod,
                 pcaptistt,
                 pcaptinom,
                 pcaptitip
            from eccmpti
           where eccmpti.pcactacod = ws.pcactacod

       foreach  c_cta01m54_002   into  ws.pcapticod,
                               ws.pcaptistt,
                               ws.pcaptinom,
                               ws.pcaptitip

          if arr_aux  >  50   then
             error " PESQUISA COM MAIS DE 50 ITENS"
             sleep 5
             exit program
          end if

          let a_cta01m54[arr_aux].cartao = ws.pcapticod
          let a_cta01m54[arr_aux].pcaptinom = ws.pcaptinom

          if ws.pcaptitip  = "1"   then
             let a_cta01m54[arr_aux].tpcar = "Tit"
          else
             if ws.pcaptitip  = "2"   then
                let a_cta01m54[arr_aux].tpcar = "Adi"
             else
                let a_cta01m54[arr_aux].tpcar = "INV"
             end if
          end if

          if ws.pcaptistt  =  "A"   then
             let a_cta01m54[arr_aux].situacao = "ATIVO"
          else
             if ws.pcaptistt  =  "C"   then
                let a_cta01m54[arr_aux].situacao = "CANCELADO"
             else
                let a_cta01m54[arr_aux].situacao = "N/PREVISTO"
             end if
          end if

          let arr_aux = arr_aux + 1

       end foreach

    end foreach

    #-------------------------------------------------
    # QUANDO MAIS DE UM ITEM ENCONTRADO MOSTRA POP-UP
    #-------------------------------------------------
    if arr_aux   >  2   then
       open window cta01m54 at 4,2 with form "cta01m54"
                                   attribute(form line 1)
       message " (F17)Abandona, (F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_cta01m54 to s_cta01m54.*
          on key (interrupt,control-c)
             initialize a_cta01m54 to null
             exit display

          on key (f8)
             exit display
       end display

       let arr_aux      = arr_curr()
       let ws.pcapticod = a_cta01m54[arr_aux].cartao
       close window  cta01m54
    end if

    if not int_flag                 and
       ws.pcapticod   is not null   then
       let ret_pcapticod  = ws.pcapticod
    end if

    return ret_pcapticod

end function

