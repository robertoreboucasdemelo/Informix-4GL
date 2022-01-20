###############################################################################
# Nome do Modulo: cta01m51                                           Marcelo  #
#                                                                    Gilberto #
# Pesquisa por Nome do Titular ou Adicional                          Jan/1996 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function  cta01m51(par_nome, par_tipo)
#---------------------------------------------------------------
 define par_nome      char(41)
 define par_tipo      char(01)

 define a_cta01m51 array [50] of record
         pcaclinom    like eccmcli.pcaclinom   ,
         tipo         char(09)                 ,
         pcapticod    like eccmpti.pcapticod   ,
         situacao     char(09)
 end record

 define  ws           record
         achou        char(1),
         pcaptitip    char(1),
         pcaptistt    like eccmpti.pcaptistt
 end record

 define arr_aux       integer
 define scr_aux       integer


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_cta01m51[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let arr_aux = 1
 initialize a_cta01m51  to null
 initialize ws.*        to null

 if par_tipo = "T" then
    declare   c_cta01m51_001     cursor for
       select a.pcaclinom , "T" , c.pcaptistt  , c.pcapticod
         from eccmcli a,  eccmcta b,  eccmpti c
        where a.pcaclinom  matches  par_nome        and
              a.pcaclicod     =     b.pcaclicod     and
              b.pcactacod     =     c.pcactacod     and
              c.pcaptitip     =     1

    foreach c_cta01m51_001    into  a_cta01m51[arr_aux].pcaclinom,
                                 ws.pcaptitip,
                                 ws.pcaptistt,
                                 a_cta01m51[arr_aux].pcapticod

    if ws.pcaptitip = "T"  then
       let a_cta01m51[arr_aux].tipo = "Titular"
    else
       let a_cta01m51[arr_aux].tipo = "Adicional"
    end if

    case ws.pcaptistt
         when  "A"
               let a_cta01m51[arr_aux].situacao = "ATIVO"
         when  "B"
               let a_cta01m51[arr_aux].situacao = "BLOQUEADO"
         when  "C"
               let a_cta01m51[arr_aux].situacao = "CANCELADO"
         otherwise
               let a_cta01m51[arr_aux].situacao = "N/PREVIST"
    end case

    let arr_aux = arr_aux + 1
    if arr_aux  >  50   then
       error "Pesquisa com mais de 50 nomes !!!"
       exit foreach
    end if

 end foreach

 else
    declare   c_cta01m51_002     cursor for
       select pcaptinom , "A" , pcaptistt  , pcapticod
         from eccmpti
        where pcaptinom  matches  par_nome        and
              pcaptitip     >     1

    foreach c_cta01m51_002    into  a_cta01m51[arr_aux].pcaclinom,
                                 ws.pcaptitip,
                                 ws.pcaptistt,
                                 a_cta01m51[arr_aux].pcapticod

    if ws.pcaptitip = "T"  then
       let a_cta01m51[arr_aux].tipo = "Titular"
    else
       let a_cta01m51[arr_aux].tipo = "Adicional"
    end if

    case ws.pcaptistt
         when  "A"
               let a_cta01m51[arr_aux].situacao = "ATIVO"
         when  "B"
               let a_cta01m51[arr_aux].situacao = "BLOQUEADO"
         when  "C"
               let a_cta01m51[arr_aux].situacao = "CANCELADO"
         otherwise
               let a_cta01m51[arr_aux].situacao = "N/PREVIST"
    end case


    let arr_aux = arr_aux + 1
    if arr_aux  >  50   then
       error "Pesquisa com mais de 50 nomes !!!"
       exit foreach
    end if

 end foreach

 end if

 if arr_aux > 2   then
    open window cta01m51 at 4,2 with form "cta01m51"
                attribute(form line 1)
    call set_count(arr_aux-1)
    message " (F17)Abandona, (F8)Seleciona"

    display array a_cta01m51 to s_cta01m51.*

       on key (interrupt,control-c)
          initialize a_cta01m51 to null
          exit display

       on key (f8)
          let arr_aux = arr_curr()
          exit display

    end display
    close window cta01m51
 else
    if arr_aux = 2  then   ### se encontrar apenas um nome
       let arr_aux = 1     ### posiciona na ocorrencia 1 p/ retornar parametro
    end if
 end if

 if par_tipo = "T" then
    close c_cta01m51_001
 else
    close c_cta01m51_002
 end if
 let int_flag = false

 return a_cta01m51[arr_aux].pcapticod

end function   ### cta01m51
