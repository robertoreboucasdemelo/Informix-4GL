###########################################################################
# Nome do Modulo: CTN47C01                                       Ruiz     #
#     esta tela e chamada pelo pgm ctn47c00                               #
# Menu de consulta atendimento vidros                            Jun/2001 #
###########################################################################

database porto

#----------------------------------------------------------------------------
 function ctn47c01(param)
#----------------------------------------------------------------------------
   define param record
       servico     char  (13),
       nomemp      char  (15)
   end record
   define d_ctn47c01  record
       servico     char  (13),
       nomemp      char  (15),
       lignum      like  datmligacao.lignum,
       ligdat      like  datmligacao.ligdat,
       lighorinc   like  datmligacao.lighorinc,
       atdetpdes   like  datketapa.atdetpdes
   end record
   define a_ctn47c01 array[200] of record
       lignum      like  datmligacao.lignum,
       ligdat      like  datmligacao.ligdat,
       lighorinc   like  datmligacao.lighorinc,
       atdetpdes   like  datketapa.atdetpdes
   end record
   define ws   record
       comando     char (500),
       atdetpcod   like  datketapa.atdetpcod,
       atdsrvnum   like  datmservico.atdsrvnum,
       atdsrvano   like  datmservico.atdsrvano
   end record
   define arr_aux     smallint
   define scr_aux     smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctn47c01[w_pf1].*  to  null
	end	for

	initialize  d_ctn47c01.*  to  null

	initialize  ws.*  to  null

   if param.servico   is null then
      error "Parametro invalido"
      return
   end if

   initialize d_ctn47c01.*    to null
   initialize ws.*            to null

   open window w_ctn47c01a at 06,02 with form "ctn47c01"
               attribute (form line first)

   let ws.atdsrvnum        = param.servico[4,10]
   let ws.atdsrvano        = param.servico[12,13]

   let int_flag = false
   initialize a_ctn47c01  to null
   let arr_aux  = 1

   let ws.comando = "select lignum,    ",
                    "       ligdat,    ",
                    "       lighorinc, ",
                    "       atdetpcod  ",
                    " from datmsrvext1 ",
                    " where atdsrvnum = ? ",
                    "   and atdsrvano = ? "

   message " Aguarde, pesquisando..."  attribute(reverse)
   prepare p_ctn47c01_001 from ws.comando

   declare c_ctn47c01_001  cursor for  p_ctn47c01_001
   open c_ctn47c01_001  using  ws.atdsrvnum,
                           ws.atdsrvano

   let d_ctn47c01.servico  = param.servico
   let d_ctn47c01.nomemp   = param.nomemp
   display by name d_ctn47c01.*

   foreach c_ctn47c01_001 into a_ctn47c01[arr_aux].lignum,
                           a_ctn47c01[arr_aux].ligdat,
                           a_ctn47c01[arr_aux].lighorinc,
                           ws.atdetpcod
     if ws.atdetpcod = 6  then
        let ws.atdetpcod = 5
     end if

     select atdetpdes
         into a_ctn47c01[arr_aux].atdetpdes
         from datketapa
        where atdetpcod = ws.atdetpcod
     if sqlca.sqlcode <> 0 then
        let a_ctn47c01[arr_aux].atdetpdes = "NAO ENCONTRADA"
     end if

    let arr_aux = arr_aux + 1
    if arr_aux > 200 then
       error "Limite excedido. Pesquisa com mais de 200 registros!"
       exit foreach
    end if

   end foreach
   if arr_aux  > 1   then
      message " (F17)Abandona  (F8)Status da ligacao"

      call set_count(arr_aux-1)

      display array  a_ctn47c01 to s_ctn47c01.*
        on key(interrupt)
           exit display

        on key (F8)
           let arr_aux = arr_curr()
           call ctn47c02(d_ctn47c01.servico,
                         a_ctn47c01[arr_aux].lignum)
      end display
      clear form
   else
      error " Nao existe ligacoes para esta pesquisa!"
   end if
   message ""
   let int_flag = false

   close window w_ctn47c01a

 end function

