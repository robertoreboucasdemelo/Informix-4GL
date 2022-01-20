 ##############################################################################
 # Nome do Modulo: ctn46c01                                          Gilberto #
 #                                                                    Marcelo #
 # Calcula distancia entre dois logradouros                          Out/1999 #
 ##############################################################################
 # Alteracoes:                                                                #
 #                                                                            #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
 #----------------------------------------------------------------------------#
 # 20/02/2001  PSI 12597-0  Marcus       Calculo entre cidades                #
 ##############################################################################

 database porto

#------------------------------------------------------------
 function ctn46c01(param)
#------------------------------------------------------------

 define param         record
    lgdnom_1          char (71),
    brrnom_1          like datkmpabrr.brrnom,
    mpalgdincnum_1    like datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum_1    like datkmpalgdsgm.mpalgdfnlnum,
    lclltt_1          like datkmpalgdsgm.lclltt,
    lcllgt_1          like datkmpalgdsgm.lcllgt,
    ufdcod_1          like datkmpacid.ufdcod,
    cidnom_1          like datkmpacid.cidnom,
    lgdnom_2          char (71),
    brrnom_2          like datkmpabrr.brrnom,
    mpalgdincnum_2    like datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum_2    like datkmpalgdsgm.mpalgdfnlnum,
    lclltt_2          like datkmpalgdsgm.lclltt,
    lcllgt_2          like datkmpalgdsgm.lcllgt,
    ufdcod_2          like datkmpacid.ufdcod,
    cidnom_2          like datkmpacid.cidnom
 end record

 define a_ctn46c01    array[002]  of  record
    lgdnom            char (71),
    brrnom            like datkmpabrr.brrnom,
    mpalgdincnum      like datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum      like datkmpalgdsgm.mpalgdfnlnum,
    lclltt            like datkmpalgdsgm.lclltt,
    lcllgt            like datkmpalgdsgm.lcllgt,
    ufdcod            like datkmpacid.ufdcod,
    cidnom            like datkmpacid.cidnom
 end record

 define ws            record
    dstqtd            dec (8,4)
 end record

 define arr_aux       smallint



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  2
		initialize  a_ctn46c01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 open window w_ctn46c01 at  09,04 with form "ctn46c01"
             attribute(form line first, border)

 initialize ws.*        to null
 initialize a_ctn46c01  to null

 for arr_aux = 1 to 2
   if arr_aux  =  1   then
      let a_ctn46c01[arr_aux].ufdcod       = param.ufdcod_1
      let a_ctn46c01[arr_aux].cidnom       = param.cidnom_1
      let a_ctn46c01[arr_aux].lgdnom       = param.lgdnom_1
      let a_ctn46c01[arr_aux].brrnom       = param.brrnom_1
      let a_ctn46c01[arr_aux].mpalgdincnum = param.mpalgdincnum_1
      let a_ctn46c01[arr_aux].mpalgdfnlnum = param.mpalgdfnlnum_1
      let a_ctn46c01[arr_aux].lclltt       = param.lclltt_1
      let a_ctn46c01[arr_aux].lcllgt       = param.lcllgt_1
   end if

   if arr_aux  =  2   then
      let a_ctn46c01[arr_aux].ufdcod       = param.ufdcod_2
      let a_ctn46c01[arr_aux].cidnom       = param.cidnom_2
      let a_ctn46c01[arr_aux].lgdnom       = param.lgdnom_2
      let a_ctn46c01[arr_aux].brrnom       = param.brrnom_2
      let a_ctn46c01[arr_aux].mpalgdincnum = param.mpalgdincnum_2
      let a_ctn46c01[arr_aux].mpalgdfnlnum = param.mpalgdfnlnum_2
      let a_ctn46c01[arr_aux].lclltt       = param.lclltt_2
      let a_ctn46c01[arr_aux].lcllgt       = param.lcllgt_2
   end if
 end for

 if a_ctn46c01[01].lclltt  is not null   and
    a_ctn46c01[01].lcllgt  is not null   and
    a_ctn46c01[02].lclltt  is not null   and
    a_ctn46c01[02].lcllgt  is not null   then

    call cts18g00(a_ctn46c01[01].lclltt, a_ctn46c01[01].lcllgt,
                  a_ctn46c01[02].lclltt, a_ctn46c01[02].lcllgt)
         returning ws.dstqtd

    display by name ws.dstqtd

 end if

 call set_count(arr_aux - 1)
 message " (F17)Abandona"

 display array a_ctn46c01 to s_ctn46c01.*
    on key (interrupt,control-c)
       let int_flag = false
       exit display
 end display

 let int_flag = false
 close window  w_ctn46c01

end function   ###  ctn46c01
