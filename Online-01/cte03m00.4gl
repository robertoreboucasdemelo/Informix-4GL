###############################################################################
# Nome do Modulo: cte03m00                                           Raji     #
#                                                                             #
# Acompanhamento de pendencias                                       Set/2000 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
###############################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Alterado caminho da global          #
###############################################################################

globals  "/homedsa/projetos/geral/globals/glcte.4gl"

#main
#call cte03m00()
#end main

#--------------------------------------------------------------------
 function cte03m00()
#--------------------------------------------------------------------

 define d_cte03m00   record
    faxdat           like dacmligurastt.atdtrxdat    ,
    faxsitcod        like dacmligurastt.atdtrxenvstt ,
    faxsitdsc        char (15)                       ,
    oridocto         like dacmligurastt.dctorg       ,
    documento         like dacmligurastt.dctnumdig    ,
    totqtd           smallint
 end record

 define ws           record
    errflg           smallint                     ,
    totqtd           smallint                     ,
    atdtrxenvstt     like dacmligurastt.atdtrxenvstt,
    dddcod           like dacmligurastt.dddcod,
    facnum           like dacmligurastt.facnum
 end record

 define a_cte03m00   array[10001] of record
    dctorg           like dacmligurastt.dctorg    ,
    dctnumdig        like dacmligurastt.dctnumdig ,
    atdtrxdat        like dacmligurastt.atdtrxdat ,
    atdtrxhor        like dacmligurastt.atdtrxhor ,
    atdtrxenvstt     like dacmligurastt.atdtrxenvstt,
    descstt          char (15)                    ,
    dddcod           like dacmligurastt.dddcod    ,
    facnum           like dacmligurastt.facnum
 end record

 define arr_aux      smallint
 define scr_aux      smallint

 define sql_comando  char (900)


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null
	let	sql_comando  =  null

	for	w_pf1  =  1  to  10001
		initialize  a_cte03m00[w_pf1].*  to  null
	end	for

	initialize  d_cte03m00.*  to  null

	initialize  ws.*  to  null

 open window w_cte03m00 at 06,02 with form "cte03m00"
             attribute(form line 1)

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------
 initialize a_cte03m00    to null
 initialize ws.*          to null

 if weekday(today) = 1  then
    let d_cte03m00.faxdat = today - 3 units day
 else
    let d_cte03m00.faxdat = today - 1 units day
 end if

 while true
    let int_flag             = false

    clear form
    display by name d_cte03m00.*

    input by name d_cte03m00.faxdat   ,
                  d_cte03m00.faxsitcod,
                  d_cte03m00.faxsitdsc,
                  d_cte03m00.oridocto ,
                  d_cte03m00.documento without defaults

       before field faxdat
          display by name d_cte03m00.faxdat  attribute (reverse)
       after  field faxdat
          display by name d_cte03m00.faxdat

       before field faxsitcod
          display by name d_cte03m00.faxsitcod  attribute (reverse)
          display by name d_cte03m00.faxsitdsc  attribute (reverse)

       after  field faxsitcod
          if fgl_lastkey() = fgl_keyval("down")  then
             next field documento
          else
             if d_cte03m00.faxsitcod is null  or
                d_cte03m00.faxsitcod =  " "   then
                let d_cte03m00.faxsitdsc = "TODOS"
             else
             end if
          end if
          display by name d_cte03m00.faxsitcod
          display by name d_cte03m00.faxsitdsc


       before field oridocto
          display by name d_cte03m00.oridocto  attribute (reverse)
       after  field oridocto
          display by name d_cte03m00.oridocto

       before field documento
          display by name d_cte03m00.documento  attribute (reverse)
       after  field documento
          display by name d_cte03m00.documento

       on key (interrupt)
          let int_flag = true
          exit input

    end input

    if int_flag = true  then
       let arr_aux = 1
       initialize a_cte03m00[arr_aux].* to null
       exit while
    end if

    while TRUE

      let ws.totqtd = 0
      let arr_aux   = 1

      #--------------------------------------------------------------------
      # Cursor para obtencao da situacao de envio do fax ura
      #--------------------------------------------------------------------
      let sql_comando = "select dctorg       ,",
                        "       dctnumdig    ,",
                        "       atdtrxdat    ,",
                        "       atdtrxhor    ,",
                        "       atdtrxenvstt ,",
                        "       dddcod       ,",
                        "       facnum        ",
                        "  from dacmligurastt "

      if d_cte03m00.documento is not null  then
         let sql_comando = sql_comando clipped,
                           " where dctnumdig  = ", d_cte03m00.documento
      else
         let sql_comando = sql_comando clipped,
                           " where atdtrxdat = '", d_cte03m00.faxdat, "'"
      end if
      if d_cte03m00.faxsitcod is not null  then
         let sql_comando = sql_comando clipped,
                           " and atdtrxenvstt = ", d_cte03m00.faxsitcod
      end if
      if d_cte03m00.oridocto is not null  then
         let sql_comando = sql_comando clipped,
                           " and dctorg = ", d_cte03m00.oridocto
      end if
      let sql_comando = sql_comando clipped,
                      " order by atdtrxdat, atdtrxhor"
      prepare select_main from sql_comando
      declare c_cte03m00 cursor with hold for select_main

      foreach c_cte03m00  into   a_cte03m00[arr_aux].dctorg       ,
                                 a_cte03m00[arr_aux].dctnumdig    ,
                                 a_cte03m00[arr_aux].atdtrxdat    ,
                                 a_cte03m00[arr_aux].atdtrxhor    ,
                                 a_cte03m00[arr_aux].atdtrxenvstt ,
                                 a_cte03m00[arr_aux].dddcod       ,
                                 a_cte03m00[arr_aux].facnum

         case a_cte03m00[arr_aux].atdtrxenvstt
              when 1
                   let a_cte03m00[arr_aux].descstt = "ENVIO OK"
              when 2
                   let a_cte03m00[arr_aux].descstt = "ERRO NO ENVIO"
              when 3
                   let a_cte03m00[arr_aux].descstt = "AGENDADO"
         end case

         let ws.totqtd = ws.totqtd + 1

         let arr_aux = arr_aux + 1
         if arr_aux  >  10000   then
            error " Limite excedido. Foram encontradas mais de 1000 Fax - URA!"
            exit foreach
         end if

      end foreach

      let d_cte03m00.totqtd =  ws.totqtd using "&&&"
      display by name d_cte03m00.totqtd  attribute(reverse)

      if arr_aux = 1  then
         error " Nao existem status para a pesquisa!"
         let int_flag = true
         exit while
      else
         call set_count(arr_aux-1)
         options insert  key  F35,
                 delete  key  F36,
                 comment line last

         let ws.errflg = false

         input array a_cte03m00 without defaults from s_cte03m00.*
            before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()

               display a_cte03m00[arr_aux].dctorg     to
                       s_cte03m00[scr_aux].dctorg     attribute(reverse)

               display a_cte03m00[arr_aux].dctnumdig  to
                       s_cte03m00[scr_aux].dctnumdig  attribute(reverse)

               display a_cte03m00[arr_aux].atdtrxdat  to
                       s_cte03m00[scr_aux].atdtrxdat  attribute(reverse)

               display a_cte03m00[arr_aux].atdtrxhor  to
                       s_cte03m00[scr_aux].atdtrxhor  attribute(reverse)

               display a_cte03m00[arr_aux].atdtrxenvstt  to
                       s_cte03m00[scr_aux].atdtrxenvstt  attribute(reverse)

               display a_cte03m00[arr_aux].descstt  to
                       s_cte03m00[scr_aux].descstt  attribute(reverse)

               display a_cte03m00[arr_aux].dddcod  to
                       s_cte03m00[scr_aux].dddcod  attribute(reverse)

               display a_cte03m00[arr_aux].facnum  to
                       s_cte03m00[scr_aux].facnum  attribute(reverse)

               if ws.errflg = false  then
                  let ws.atdtrxenvstt = a_cte03m00[arr_aux].atdtrxenvstt
                  let ws.dddcod       = a_cte03m00[arr_aux].dddcod
                  let ws.facnum       = a_cte03m00[arr_aux].facnum
               else
                  let ws.errflg = false
               end if

            after  field atdtrxenvstt
               display a_cte03m00[arr_aux].atdtrxenvstt to
                       s_cte03m00[scr_aux].atdtrxenvstt attribute(reverse)

               if a_cte03m00[arr_aux].atdtrxenvstt is null  then
                  error " Codigo da situacao do envio e' item obrigatorio!"
                  let ws.errflg = true
                  next field atdtrxenvstt
               end if

               if fgl_lastkey() = fgl_keyval("down")  then
                  if a_cte03m00[arr_aux + 1].atdtrxenvstt is null  then
                     error " Nao ha' mais pendencias nesta direcao!"
                     next field atdtrxenvstt
                  end if
               end if

               if ws.atdtrxenvstt <> a_cte03m00[arr_aux].atdtrxenvstt  then
                  case a_cte03m00[arr_aux].atdtrxenvstt
                       when 1
                            let a_cte03m00[arr_aux].descstt = "ENVIO OK"
                       when 2
                            let a_cte03m00[arr_aux].descstt = "ERRO NO ENVIO"
                       when 3
                            let a_cte03m00[arr_aux].descstt = "AGENDADO"
                  end case

                  display a_cte03m00[arr_aux].descstt to
                          s_cte03m00[scr_aux].descstt attribute(reverse)
               end if

            after row
               display a_cte03m00[arr_aux].dctorg     to
                       s_cte03m00[scr_aux].dctorg

               display a_cte03m00[arr_aux].dctnumdig  to
                       s_cte03m00[scr_aux].dctnumdig

               display a_cte03m00[arr_aux].atdtrxdat  to
                       s_cte03m00[scr_aux].atdtrxdat

               display a_cte03m00[arr_aux].atdtrxhor  to
                       s_cte03m00[scr_aux].atdtrxhor

               display a_cte03m00[arr_aux].atdtrxenvstt  to
                       s_cte03m00[scr_aux].atdtrxenvstt

               display a_cte03m00[arr_aux].descstt  to
                       s_cte03m00[scr_aux].descstt

               display a_cte03m00[arr_aux].dddcod  to
                       s_cte03m00[scr_aux].dddcod

               display a_cte03m00[arr_aux].facnum  to
                       s_cte03m00[scr_aux].facnum

               if ws.atdtrxenvstt <> a_cte03m00[arr_aux].atdtrxenvstt or
                  ws.dddcod       <> a_cte03m00[arr_aux].dddcod       or
                  ws.facnum       <> a_cte03m00[arr_aux].facnum  then
                  update dacmligurastt set (atdtrxenvstt,dddcod,facnum)
                                         = (a_cte03m00[arr_aux].atdtrxenvstt,
                                            a_cte03m00[arr_aux].dddcod,
                                            a_cte03m00[arr_aux].facnum)
                         where dctorg    = a_cte03m00[arr_aux].dctorg
                           and dctnumdig = a_cte03m00[arr_aux].dctnumdig
                           and atdtrxdat = a_cte03m00[arr_aux].atdtrxdat
                           and atdtrxhor = a_cte03m00[arr_aux].atdtrxhor
               end if

               initialize ws.atdtrxenvstt to null
               initialize ws.dddcod       to null
               initialize ws.facnum       to null

            on key (interrupt)
               let int_flag = true
               initialize a_cte03m00 to null
               let arr_aux = arr_curr()
               exit input

         end input

         options comment line last
      end if

      if int_flag = true  then
         exit while
      end if

    end while

 end while

 let int_flag = false
 close window w_cte03m00

end function  ##-- cte03m00
