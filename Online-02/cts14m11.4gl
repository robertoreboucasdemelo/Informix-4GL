############################################################################
# Menu de Modulo: CTS14M11                                        Marcelo  #
#                                                                 Gilberto #
# Implementacao de Dados no Historico da Vistoria de Sinistro     Jan/1996 #
############################################################################

database porto


globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
function cts14m11(k_cts14m11)
#---------------------------------------------------------------

   define k_cts14m11 record
      sinvstnum like datmsinhist.sinvstnum,
      sinvstano like datmsinhist.sinvstano,
      funmat    like datmsinhist.c24funmat,
      data      like datmvstsin.atddat    ,
      hora      like datmvstsin.atdhor
   end record

   define a_cts14m11 array[200] of record
      c24vstdsc like datmsinhist.c24vstdsc
   end record

   define ws    record
      ligdat    like datmvstsin.atddat    ,
      lighor    like datmvstsin.atdhor    ,
      funmat    like datmsinhist.c24funmat,
      c24txtseq like datmsinhist.c24txtseq,
      c24vstdsc like datmsinhist.c24vstdsc
   end record

   define arr_aux      integer
   define scr_aux      integer
   define aux_times    char(11)


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null
	let	aux_times  =  null

	for	w_pf1  =  1  to  200
		initialize  a_cts14m11[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

   if  k_cts14m11.data is null then
       let aux_times = time
       let ws.lighor = aux_times[1,5]
       let ws.ligdat = today
       let ws.funmat = g_issk.funmat
   else
       let ws.lighor = k_cts14m11.hora
       let ws.ligdat = k_cts14m11.data
       let ws.funmat = k_cts14m11.funmat
   end if

   let arr_aux = 1

   while true
     let int_flag = false

     call set_count(arr_aux - 1)

     options
        insert key F35 ,
        delete key F36

     input array a_cts14m11 without defaults from s_cts14m11.*
        before row
           let arr_aux      = arr_curr()
           let scr_aux      = scr_line()

        before insert
           initialize a_cts14m11[arr_aux].c24vstdsc  to null

           display a_cts14m11[arr_aux].c24vstdsc  to
                   s_cts14m11[scr_aux].c24vstdsc

        before field c24vstdsc
           display a_cts14m11[arr_aux].c24vstdsc to
                   s_cts14m11[scr_aux].c24vstdsc attribute (reverse)

        after  field c24vstdsc
           display a_cts14m11[arr_aux].c24vstdsc to
                   s_cts14m11[scr_aux].c24vstdsc

           if fgl_lastkey() = fgl_keyval("left")  or
              fgl_lastkey() = fgl_keyval("up")    then
              error " Alteracoes e/ou correcoes nao sao permitidas!"
              next field c24vstdsc
           else
              if a_cts14m11[arr_aux].c24vstdsc is null  or
                 a_cts14m11[arr_aux].c24vstdsc =  "  "  then
                 error " Complemento deve ser informado!"
                 next field c24vstdsc
              end if
           end if

        on key (interrupt)
           exit input

        after row
           select max (c24txtseq)
             into ws.c24txtseq
             from datmsinhist
            where datmsinhist.sinvstnum = k_cts14m11.sinvstnum and
                  datmsinhist.sinvstano = k_cts14m11.sinvstano

           if ws.c24txtseq is null then
              let ws.c24txtseq = 0
           end if

           let ws.c24txtseq = ws.c24txtseq + 1

           begin work

             insert into datmsinhist ( sinvstnum ,
                                       sinvstano ,
                                       c24funmat ,
                                       lighorinc ,
                                       ligdat    ,
                                       c24txtseq ,
                                       c24vstdsc )
                    values           ( k_cts14m11.sinvstnum ,
                                       k_cts14m11.sinvstano ,
                                       ws.funmat            ,
                                       ws.lighor            ,
                                       ws.ligdat            ,
                                       ws.c24txtseq         ,
                                       a_cts14m11[arr_aux].c24vstdsc)

             if sqlca.sqlcode <> 0   then
                error "Erro (", sqlca.sqlcode, ") na inclusao do historico." ,
                      "Favor re-digitar a linha."
                rollback work
                next field c24vstdsc
             end if

             let g_documento.acao = "INC"

             commit work

             initialize g_documento.acao  to null

       end input

       if int_flag  then
          exit while
       end if

   end while

   let int_flag = false

   clear form

end function # cts14m11
