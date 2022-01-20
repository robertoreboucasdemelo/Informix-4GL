################################################################################
# Nome do Modulo: CTS14M13                                            Marcelo  #
#                                                                     Gilberto #
# Pesquisa vistoria sinistro de auto (p/ terceiros)                   Fev/1996 #
################################################################################

database porto

#------------------------------------------------------------------------
 function cts14m13(param)
#------------------------------------------------------------------------

 define param         record
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig
 end record

 define d_cts14m13    record
    sinvstorgnum      like datmvstsin.sinvstorgnum ,
    sinvstorgano      like datmvstsin.sinvstorgano
 end record

 define a_cts14m13    array[15] of record
    bnfnom            like ssamterc.bnfnom      ,
    sinbemdes         like ssamterc.sinbemdes   ,
    vclanomdl         like ssamterc.vclanomdl   ,
    vcllicnum         like ssamterc.vcllicnum   ,
    ## vclchsfnl         like ssamterc.vclchsfnl psi191965
    chassi            char(20)
 end record

 define ws            record
    ramcod            like ssamsin.ramcod          ,
    sinnum            like ssamsin.sinnum          ,
    sinano            like ssamsin.sinano          ,
    orrdat            like ssamsin.orrdat          ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig
 end record

 define l_vclchsfnl         like ssamterc.vclchsfnl,
        l_vclchsinc         like ssamterc.vclchsinc

 define arr_aux       smallint

	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  15
		initialize  a_cts14m13[w_pf1].*  to  null
	end	for

	initialize  d_cts14m13.*  to  null

	initialize  ws.*  to  null

 initialize  l_vclchsfnl to null
 initialize  l_vclchsinc to null


 open window w_cts14m13 at 09,08 with form "cts14m13"
             attribute(form line first, border)

 while true

    initialize a_cts14m13  to null
    initialize ws.*        to null

    let int_flag   = false
    let arr_aux    = 1

    input by name d_cts14m13.*  without defaults

       before field sinvstorgnum
          display by name d_cts14m13.sinvstorgnum attribute (reverse)

       after  field sinvstorgnum
          display by name d_cts14m13.sinvstorgnum

          if d_cts14m13.sinvstorgnum   is null    then
             error " Para marcacao vistoria de terceiro, numero e' obrigatorio!"
             next field sinvstorgnum
          end if

#-----------------------------------------------------------------------
# Comentado em 16/12/1997, conforme correio enviado por Vianei
#-----------------------------------------------------------------------
#         if ((d_cts14m13.sinvstorgnum  >  205000   and
#              d_cts14m13.sinvstorgnum  <  300001      )  or
#             (d_cts14m13.sinvstorgnum  >  304000   and
#              d_cts14m13.sinvstorgnum  <  310001      )  or
#             (d_cts14m13.sinvstorgnum  >  592500   and
#              d_cts14m13.sinvstorgnum  <  612501      )  or
#             (d_cts14m13.sinvstorgnum  >  623999   and
#              d_cts14m13.sinvstorgnum  <  628001      )) then
#              let ws.nrook = "s"
#         else
#              error " Numero de vistoria de sinistro invalido !!"
#              next field sinvstorgnum
#              let ws.nrook = "n"
#         end if
#-----------------------------------------------------------------------

       before field sinvstorgano
          display by name d_cts14m13.sinvstorgano attribute (reverse)

       after  field sinvstorgano
          display by name d_cts14m13.sinvstorgano

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field sinvstorgnum
          end if

          if d_cts14m13.sinvstorgano   is null    then
             error " Ano da vistoria deve ser informado!"
             next field sinvstorgano
          end if

        # let ws.ramcod = 53

          select sinnum   , sinano      , orrdat   ,
                 succod   , aplnumdig   , itmnumdig
            into ws.sinnum, ws.sinano   , ws.orrdat,
                 ws.succod, ws.aplnumdig, ws.itmnumdig
            from ssamsin
           where ssamsin.sinvstnum = d_cts14m13.sinvstorgnum    and
                 ssamsin.sinvstano = d_cts14m13.sinvstorgano    and
                 ssamsin.ramcod    in (53,553)

          if sqlca.sqlcode = notfound  then        #---> laudo nao foi emitido
             initialize a_cts14m13    to null
             initialize ws.orrdat     to null
             error " Numero de vistoria nao encontrado! Informe novamente!"
             next field sinvstorgnum
          else
             if ws.succod       is not null  and
                ws.aplnumdig    is not null  and
                ws.itmnumdig    is not null  and
                param.succod    is not null  and
                param.aplnumdig is not null  and
                param.itmnumdig is not null  then
                if ws.succod    <> param.succod     or
                   ws.aplnumdig <> param.aplnumdig  or
                   ws.itmnumdig <> param.itmnumdig  then
                   error " Numero de vistoria informado nao pertence a esta apolice!"
                   next field sinvstorgnum
                end if
             end if

             display ws.orrdat  to  orrdat  attribute(reverse)
          end if

       on key (interrupt)
          initialize d_cts14m13.sinvstorgnum,
                     d_cts14m13.sinvstorgano   to null
          exit input

    end input

    if int_flag   then
       exit while
    end if

    declare c_cts14m13_001  cursor for
      #select bnfnom, sinbemdes, vclanomdl, vcllicnum, vclchsfnl
      #  from ssamsin, outer ssamterc

      # where ssamsin.ramcod   in (53,553)                  and
      #       ssamsin.sinnum   =  ws.sinnum                 and
      #       ssamsin.sinano   =  ws.sinano                 and

      #       ssamterc.ramcod  in (53,553)                  and
      #       ssamterc.sinano  =  ssamsin.sinano            and
      #       ssamterc.sinnum  =  ssamsin.sinnum

       select bnfnom, sinbemdes, vclanomdl, vcllicnum, vclchsfnl
             ,vclchsinc
         from ssamterc
        where ssamterc.ramcod  in (53,553)    and
              ssamterc.sinano  =  ws.sinano   and
              ssamterc.sinnum  =  ws.sinnum

    foreach  c_cts14m13_001  into  a_cts14m13[arr_aux].bnfnom    ,
                               a_cts14m13[arr_aux].sinbemdes ,
                               a_cts14m13[arr_aux].vclanomdl ,
                               a_cts14m13[arr_aux].vcllicnum ,
                               ## a_cts14m13[arr_aux].vclchsfnl psi191965
                               l_vclchsfnl,
                               l_vclchsinc

    let a_cts14m13[arr_aux].chassi = l_vclchsinc clipped , l_vclchsfnl clipped


       let arr_aux = arr_aux + 1
       if arr_aux > 15   then
          error " Limite excedido! Sinistro com mais de 15 terceiros envolvidos!"
          exit foreach
       end if
    end foreach

    if arr_aux  >  1   then
       message " (F17)Abandona, (F8)Seleciona"
       call set_count(arr_aux-1)

       display array  a_cts14m13 to s_cts14m13.*
          on key (interrupt)
             initialize d_cts14m13.sinvstorgnum,
                        d_cts14m13.sinvstorgano   to null
             initialize a_cts14m13                to null
             initialize ws.orrdat                 to null
             exit display

          on key (F8)
             let arr_aux  = arr_curr()
             let int_flag = true
             exit display
       end display
    else
       error " Nao foi encontrada nenhuma informacao sobre o terceiro!"
    end if

    if int_flag   then
       exit while
    end if

    for arr_aux = 1 to 2
       clear s_cts14m13[arr_aux].bnfnom
       clear s_cts14m13[arr_aux].sinbemdes
       clear s_cts14m13[arr_aux].vclanomdl
       clear s_cts14m13[arr_aux].vcllicnum
       #clear s_cts14m13[arr_aux].vclchsfnl
       clear s_cts14m13[arr_aux].chassi
    end for
 end while

 let int_flag = false
 close window  w_cts14m13

 return d_cts14m13.sinvstorgnum      , d_cts14m13.sinvstorgano      ,
        a_cts14m13[arr_aux].bnfnom   , a_cts14m13[arr_aux].sinbemdes,
        a_cts14m13[arr_aux].vclanomdl, a_cts14m13[arr_aux].vcllicnum,
        ## a_cts14m13[arr_aux].vclchsfnl, ws.orrdat psi 191965
        a_cts14m13[arr_aux].chassi,
        ws.orrdat

end function  ###  cts14m13
