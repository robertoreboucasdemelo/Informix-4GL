 ###########################################################################
 # Nome do Modulo: CTN47C00 - ctg3                                Gilberto #
 #                                                                 Marcelo #
 #                                                                 Wagner  #
 # Menu de consulta atendimento vidros                            Dez/1999 #
 ###########################################################################
 #                            MANUTENCOES
 # 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
 #-------------------------------------------------------------------------#
 # 31/12/2009  Amilton, Meta                      Projeto Succod smallint  # 
 #-------------------------------------------------------------------------#
 
 database porto

#--------------------------------------------------------------------------
 function ctn47c00()
#--------------------------------------------------------------------------

 define d_ctn47c00   record
    atddat           date,
    atdorigem        like datmservico.atdsrvorg,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define a_ctn47c00   array[200] of record
    servico          char (13),
    documento        char (30),
    nomemp           like adikvdrrprgrp.vdrrprgrpnom,
    atdetpdes        like datketapa.atdetpdes
 end record

 define ws           record
    atlhor           char (08),
    succod           like abbmdoc.succod,
    ramcod           like gtakram.ramcod,
    aplnumdig        like abbmdoc.aplnumdig,
    itmnumdig        like abbmdoc.itmnumdig,
    c24astcod        like datmligacao.c24astcod,
    msg1             char (40),
    msg2             char (40),
    confirma         char (01),
    comando          char (500),
    vstnumdig        like datmvistoria.vstnumdig,
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig,
    codemp           like adikvdrrpremp.vdrrprgrpcod,
    atdsrvorg        like datmservico.atdsrvorg,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvnum1       like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdetpcod        like datketapa.atdetpcod,
    lignum           like datmligacao.lignum
 end record
 define arr_aux     smallint
 define scr_aux     smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctn47c00[w_pf1].*  to  null
	end	for

	initialize  d_ctn47c00.*  to  null

	initialize  ws.*  to  null

 initialize d_ctn47c00.*    to null
 initialize ws.*            to null

 open window w_ctn47c00a at 05,02 with form "ctn47c00"
             attribute (form line first)

 while true

   let int_flag = false
   initialize a_ctn47c00  to null
   let arr_aux  = 1

   input by name d_ctn47c00.atddat,
                 d_ctn47c00.atdorigem,
                 d_ctn47c00.atdsrvnum,
                 d_ctn47c00.atdsrvano   without defaults

      before field atddat
             initialize d_ctn47c00  to null
             display by name d_ctn47c00.*
             display by name d_ctn47c00.atddat      attribute (reverse)

      after  field atddat
             display by name d_ctn47c00.atddat
             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field atdrvnum
             end if
             if d_ctn47c00.atddat  is not  null then
                exit input
             end if

      before field atdsrvnum
             initialize d_ctn47c00  to null
             display by name d_ctn47c00.*
             display by name d_ctn47c00.atdsrvnum    attribute (reverse)

      after  field atdsrvnum
             display by name d_ctn47c00.atdsrvnum

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field atddat
             end if

             if d_ctn47c00.atdsrvnum   is null   then
                error " Data ou numero do servico deve ser informado!"
                next field atdsrvnum
             end if

       before field atdsrvano
              display by name d_ctn47c00.atdsrvano  attribute (reverse)

       after  field atdsrvano
              display by name d_ctn47c00.atdsrvano

              if  fgl_lastkey() = fgl_keyval("up")   or
                  fgl_lastkey() = fgl_keyval("left") then
                  next field atdsrvnum
              end if

              if d_ctn47c00.atdsrvano   is null      and
                 d_ctn47c00.atdsrvnum   is not null  then
                 error " Ano do servico deve ser informado!"
                 next field atdsrvano
              end if

              if d_ctn47c00.atdsrvano   is not null   and
                 d_ctn47c00.atdsrvnum   is null       then
                 error " Numero do servico deve ser informado!"
                 next field atdsrvnum
              end if
              if d_ctn47c00.atdsrvnum  is not null   and
                 d_ctn47c00.atdsrvano  is not null   then
                 select atdsrvorg
                   into ws.atdsrvorg
                   from DATMSERVICO
                        where atdsrvnum = d_ctn47c00.atdsrvnum
                          and atdsrvano = d_ctn47c00.atdsrvano

                 let d_ctn47c00.atdorigem = ws.atdsrvorg
                 display by name d_ctn47c00.atdorigem
              end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   if d_ctn47c00.atddat is not null then
      let ws.comando = "select lignum   ,",
                     "       atdetpcod,",
                     "       vstnumdig,",
                     "       prporg   ,",
                     "       prpnumdig,",
                     "       succod,   ",
                     "       ramcod,   ",
                     "       aplnumdig,",
                     "       itmnumdig,",
                     "       atdsrvnum,",
                     "       atdsrvano,",
                     "       vdrrprgrpcod ",
                     "  from datmsrvext1 ",
                     " where ligdat   = ? ",
                     " order by lignum desc"
   else
      let ws.comando = "select lignum   ,",
                     "       atdetpcod,",
                     "       vstnumdig,",
                     "       prporg   ,",
                     "       prpnumdig,",
                     "       succod,   ",
                     "       ramcod,   ",
                     "       aplnumdig,",
                     "       itmnumdig,",
                     "       atdsrvnum,",
                     "       atdsrvano,",
                     "       vdrrprgrpcod ",
                     "  from datmsrvext1 ",
                     " where atdsrvnum   = ? ",
                     "   and atdsrvano   = ? "
   end if

   message " Aguarde, pesquisando..."  attribute(reverse)
   prepare sql_ctn47c00 from ws.comando 
   declare c_ctn47c00  cursor for  sql_ctn47c00

   if d_ctn47c00.atddat is not null then
      open c_ctn47c00  using  d_ctn47c00.atddat
   else
      open c_ctn47c00  using  d_ctn47c00.atdsrvnum,
                              d_ctn47c00.atdsrvano
   end if
   let ws.atdsrvorg = 14

   foreach  c_ctn47c00  into  ws.lignum   ,
                              ws.atdetpcod,
                              ws.vstnumdig,
                              ws.prporg,
                              ws.prpnumdig,
                              ws.succod,
                              ws.ramcod,
                              ws.aplnumdig,
                              ws.itmnumdig,
                              ws.atdsrvnum,
                              ws.atdsrvano,
                              ws.codemp

      if ws.atdsrvnum1 = ws.atdsrvnum then
         continue foreach
      end if
      let ws.atdsrvnum1 = ws.atdsrvnum

      if ws.atdetpcod = 6 then
         let ws.atdetpcod = 5
      end if
      select atdetpdes
           into a_ctn47c00[arr_aux].atdetpdes
           from datketapa
          where atdetpcod = ws.atdetpcod
      if sqlca.sqlcode <> 0 then
         let a_ctn47c00[arr_aux].atdetpdes = "NAO ENCONTRADO"
      end if

      let a_ctn47c00[arr_aux].servico  =  ws.atdsrvorg using "&&",
                                     "/", ws.atdsrvnum using "&&&&&&&",
                                     "-", ws.atdsrvano using "&&"
      if  ws.aplnumdig  is not null then
          let a_ctn47c00[arr_aux].documento = ws.succod using "&&&&&", #using "&&", # projeto succod
                                              "/",
                                              ws.ramcod using "&&&&",
                                              "/",
                                              ws.aplnumdig  using "&&&&&&&& &",
                                              "/",
                                              ws.itmnumdig  using "<<<<<& &"
      else
         if ws.prpnumdig is not null then
            let a_ctn47c00[arr_aux].documento = ws.prporg using "&&",
                                                "-",
                                                ws.prpnumdig using "&&&&&&&&"
         else
            if ws.vstnumdig is not null then
               let a_ctn47c00[arr_aux].documento = ws.vstnumdig
            end if
         end if
      end if
      let a_ctn47c00[arr_aux].nomemp = "NAO ENCONTRADO"
      select vdrrprgrpnom
            into a_ctn47c00[arr_aux].nomemp
            from adikvdrrprgrp
           where vdrrprgrpcod = ws.codemp

      let arr_aux = arr_aux + 1
      if arr_aux > 200 then
         error "Limite excedido. Pesquisa com mais de 200 registros!"
         exit foreach
      end if

   end foreach

   if arr_aux  > 1   then
      message " (F17)Abandona,(F3)Status do Servico"

      call set_count(arr_aux-1)

      display array  a_ctn47c00 to s_ctn47c00.*
        on key(interrupt)
           exit display

        on key (F3)
           let arr_aux = arr_curr()
           call ctn47c01(a_ctn47c00[arr_aux].servico,
                         a_ctn47c00[arr_aux].nomemp)

      end display
      clear form
   else
  #   if d_ctn47c00.lignum is not null then
  #      select c24astcod
  #        into ws.c24astcod
  #        from datmligacao
  #       where lignum = d_ctn47c00.lignum
#
  #      if sqlca.sqlcode = notfound then
  #         error " Numero da ligacao nao cadastrada!"
  #         sleep 2
  #      else
  #         let ws.succod     =  null
  #         let ws.ramcod     =  null
  #         let ws.aplnumdig  =  null
  #         let ws.itmnumdig  =  null
  #         declare c_datrligapol cursor for
  #          select succod,    ramcod,
  #                 aplnumdig, itmnumdig
  #            from datrligapol
  #           where lignum = d_ctn47c00.lignum
  #         foreach c_datrligapol into ws.succod,    ws.ramcod,
  #                                    ws.aplnumdig, ws.itmnumdig
  #            exit foreach
  #         end foreach
  #         let ws.msg1 = "ASSUNTO : ", ws.c24astcod
  #         let ws.msg2 = "DOCUMENTO NR.: ", ws.succod using "&&",
  #                                          "/",
  #                                          ws.ramcod using "&&&&",
  #                                          "/",
  #                                          ws.aplnumdig  using "&&&&&&&& &",
  #                                          "/",
  #                                          ws.itmnumdig  using "<<<<<& &"
  #         call cts08g01("A","N", "",ws.msg1, ws.msg2, "")
  #             returning ws.confirma

  #      end if
  #   end if
      error " Nao existe ligacoes para esta pesquisa!"
   end if
   message ""
end while

let int_flag = false

close window w_ctn47c00a

end function    ###--  ctn47c00
