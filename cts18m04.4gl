############################################################################
# Nome do Modulo: CTS18M04                                        Marcelo  #
#                                                                 Gilberto #
# Implementacao e consulta de informacoes sobre acidente          Ago/1997 #
############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function cts18m04(param)
#---------------------------------------------------------------
 define param       record
    operacao        char (01)                ,
    sinavsnum       like ssamavsdes.sinavsnum,
    sinavsano       like ssamavsdes.sinavsano,
    sinacdflg       like ssamavsdes.sinacdflg
 end record



 if param.operacao = "I"  then
    call cts18m04_impl(param.sinavsnum thru param.sinacdflg)
 else
    call cts18m04_cons(param.sinavsnum thru param.sinacdflg)
 end if

end function  ###  cts18m04

#---------------------------------------------------------------
 function cts18m04_impl(d_cts18m04)
#---------------------------------------------------------------

 define d_cts18m04  record
    sinavsnum       like ssamavsdes.sinavsnum,
    sinavsano       like ssamavsdes.sinavsano,
    sinacdflg       like ssamavsdes.sinacdflg
 end record

 define a_cts18m04  array[200] of record
    sintxtlin       like ssamavsdes.sintxtlin
 end record

 define arr_aux     smallint
 define scr_aux     smallint

 define ws          record
    tabname         like systables.tabname,
    sqlcode         integer
 end record


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_cts18m04[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let arr_aux = 1

 while true
    let int_flag = false

    call set_count(arr_aux - 1)

    options insert key F35,
            delete key F36

    input array a_cts18m04 without defaults from s_cts18m04.*
       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

       before insert
          initialize a_cts18m04[arr_aux].sintxtlin  to null

          display a_cts18m04[arr_aux].sintxtlin to
                  s_cts18m04[scr_aux].sintxtlin

       before field sintxtlin
          display a_cts18m04[arr_aux].sintxtlin to
                  s_cts18m04[scr_aux].sintxtlin attribute (reverse)

       after field sintxtlin
          display a_cts18m04[arr_aux].sintxtlin to
                  s_cts18m04[scr_aux].sintxtlin

          if fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("up")    then
             error " Alteracoes e/ou correcoes nao sao permitidas!"
             next field sintxtlin
          else
             if a_cts18m04[arr_aux].sintxtlin is null  or
                a_cts18m04[arr_aux].sintxtlin =  "  "  then
                error " Complemento deve ser informado!"
                next field sintxtlin
             end if
          end if

       on key (interrupt)
          exit input

# Chamado Pdm# 34968
#      on key (up)
#         error "Alteracoes e/ou correcoes nao sao permitidas!"
#         next field sintxtlin
#
#      on key (left)
#         error "Alteracoes e/ou correcoes nao sao permitidas!"
#         next field sintxtlin

       after row

          ### Adalberto - Chamado 296930
          ### Inclusao de dois parametros: empcod e usrtip - 06/05/2003
          call ssamavsdes_ins ( d_cts18m04.sinavsnum         ,
                                d_cts18m04.sinavsano         ,
                                d_cts18m04.sinacdflg         ,
                                a_cts18m04[arr_aux].sintxtlin,
                                g_issk.funmat                ,
                                arr_aux                      ,
                                g_issk.empcod                ,
                                g_issk.usrtip                )
                      returning ws.tabname, ws.sqlcode

          if ws.sqlcode <> 0  then
             error "Erro (", ws.sqlcode, ") na inclusao do historico. ",
                   "Favor re-digitar a linha."
             next field sintxtlin
          end if
          initialize g_documento.acao to null
       end input

       if int_flag  then
          exit while
       end if

   end while

   let int_flag = false

end function  ###  cts18m04_impl

#---------------------------------------------------------------
 function cts18m04_cons(d_cts18m04)
#---------------------------------------------------------------

 define d_cts18m04  record
    sinavsnum       like ssamavsdes.sinavsnum,
    sinavsano       like ssamavsdes.sinavsano,
    sinacdflg       like ssamavsdes.sinacdflg
 end record

 define a_cts18m04  array[200] of record
    sintxtlin       like ssamavsdes.sintxtlin
 end record

 define ws          record
    sinlinseq       like ssamavsdes.sinlinseq
 end record

 define arr_aux     smallint
 define scr_aux     smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_cts18m04[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let int_flag = false

 declare c_cts18m04_001 cursor for
    select sintxtlin, sinlinseq
      from ssamavsdes
     where sinavsnum = d_cts18m04.sinavsnum  and
           sinavsano = d_cts18m04.sinavsano  and
           sinacdflg = d_cts18m04.sinacdflg
     order by sinlinseq

 initialize ws.* to null

 let arr_aux  =  1

 initialize a_cts18m04  to null

 foreach c_cts18m04_001 into a_cts18m04[arr_aux].sintxtlin,
                         ws.sinlinseq

    let arr_aux = arr_aux + 1

    if arr_aux > 200 then
       error " Limite de consulta excedido. AVISE A INFORMATICA!"
       sleep 5
       exit foreach
    end if
 end foreach

 if arr_aux  >  1  then
    call set_count(arr_aux - 1)

    display array a_cts18m04 to s_cts18m04.*
       on key (interrupt,control-c)
          exit display
    end display
 else
    error " Nenhuma informacao foi cadastrada!"
 end if

 let int_flag = false

end function  ###  cts18m04_cons
