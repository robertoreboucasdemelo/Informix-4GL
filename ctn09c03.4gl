############################################################################
# Nome do Modulo: CTN09C03                                        Marcelo  #
#                                                                 Gilberto #
# Consulta informacoes sobre o pager do corretor                  Dez/1996 #
############################################################################

database porto

#---------------------------------------------------------------
 function ctn09c03(param)
#---------------------------------------------------------------

 define param      record
    corsus         like gcaksusep.corsus
 end record

 define a_ctn09c03 array[10] of record
    ustcod         like htlrust.ustcod      ,
    ustnom         like htlrust.ustnom      ,
    pgrnum         like htlrust.pgrnum      ,
    pgrctl         like htlrust.pgrctl      ,
    situacao       char (10)                ,
    c24msgrcbflg   like htlrust.c24msgrcbflg,
    ustobs         like htlrust.ustobs
 end record

 define arr_aux    smallint
 define scr_aux    smallint

 define ws         record
    ustsit         like htlrust.ustsit
 end record


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  10
		initialize  a_ctn09c03[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize ws.*         to null
 initialize a_ctn09c03   to null

 let int_flag = false

 let arr_aux  = 1

 declare c_ctn09c03_001 cursor for
   select ustcod, ustnom, pgrnum, pgrctl,
          ustsit, c24msgrcbflg, ustobs
     from htlrust
    where corsus = param.corsus

 foreach c_ctn09c03_001 into a_ctn09c03[arr_aux].ustcod      ,
                         a_ctn09c03[arr_aux].ustnom      ,
                         a_ctn09c03[arr_aux].pgrnum      ,
                         a_ctn09c03[arr_aux].pgrctl      ,
                         ws.ustsit                       ,
                         a_ctn09c03[arr_aux].c24msgrcbflg,
                         a_ctn09c03[arr_aux].ustobs

    case ws.ustsit
       when "A"  let a_ctn09c03[arr_aux].situacao = "ATIVO"
       when "C"  let a_ctn09c03[arr_aux].situacao = "CANCELADO"
       when "S"  let a_ctn09c03[arr_aux].situacao = "SUSPENSO"
       otherwise let a_ctn09c03[arr_aux].situacao = "NAO PREV."
    end case

    let arr_aux = arr_aux + 1

    if arr_aux > 10  then
       error " Limite excedido. Corretor com mais de 10 pagers!"
       exit foreach
    end if
 end foreach

#options insert key F45,
#        delete key F46
#
 message " (F17)Abandona"
 call set_count(arr_aux - 1)

 if arr_aux > 1  then
    open window ctn09c03 at 08,02 with form "ctn09c03"
                attribute (form line 1)

    display array a_ctn09c03 to s_ctn09c03.*
#   input array a_ctn09c03 without defaults from s_ctn09c03.*
#      before row
#         let arr_aux = arr_curr()
#         let scr_aux = scr_line()
#
#      before field c24msgrcbflg
#         display a_ctn09c03[arr_aux].c24msgrcbflg to
#                 s_ctn09c03[scr_aux].c24msgrcbflg attribute (reverse)
#
#      after  field c24msgrcbflg
#         display a_ctn09c03[arr_aux].c24msgrcbflg to
#                 s_ctn09c03[scr_aux].c24msgrcbflg
#
#         if fgl_lastkey() = fgl_keyval("down")   then
#            if a_ctn09c03[arr_aux + 1].ustcod is null   then
#               error "Nao existem linhas nesta direcao!"
#               next field c24msgrcbflg
#            end if
#         end if
#
#         if a_ctn09c03[arr_aux].c24msgrcbflg is null  then
#            error "Informe (S)im ou (N)ao!"
#            next field c24msgrcbflg
#         else
#            if a_ctn09c03[arr_aux].c24msgrcbflg <> "S"  and
#               a_ctn09c03[arr_aux].c24msgrcbflg <> "N"  then
#               error "Informe (S)im ou (N)ao!"
#               next field c24msgrcbflg
#            end if
#         end if
#
#         update htlrust set
#          c24msgrcbflg = a_ctn09c03[arr_aux].c24msgrcbflg
#          where ustcod = a_ctn09c03[arr_aux].ustcod
#
#         if sqlca.sqlcode <> 0  then
#            error "Erro (", sqlca.sqlcode, ") na atualizacao do corretor. AVISE A INFORMATICA!"
#            return
#         else
#            if fgl_lastkey() <> fgl_keyval("up")     and
#               fgl_lastkey() <> fgl_keyval("left")   then
#               if a_ctn09c03[arr_aux + 1].ustcod is null   then
#                  error "Alteracao efetuada com sucesso!"
#                  exit input
#               end if
#            end if
#         end if

       on key (interrupt)
#         exit input
          exit display

#   end input
    end display

    let int_flag = false
    close window ctn09c03
 else
    error " Corretor nao possui pager cadastrado pela Porto Seguro!"
 end if

end function  #  seleciona_ctn09c03
