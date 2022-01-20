#############################################################################
# Nome do Modulo: CTS11M02                                         Marcelo  #
#                                                                  Gilberto #
# Mostra servicos solicitados para apolice informada               Nov/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 26/11/2001  PSI 14177-1  Ruiz         Adaptacao para atd. a transportes.  #
#############################################################################


database porto

#------------------------------------------------------------
 function cts11m02(param)
#------------------------------------------------------------

 define param         record
    succod            like datrservapol.succod   ,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    atdsrvorg         like datmservico.atdsrvorg,
    ramcod            like datrservapol.ramcod
 end record

 define a_cts11m02    array[05] of record
    servico           char (13)                  ,
    atddat            like datmservico.atddat    ,
    atdhor            char (05)                  ,
    c24solnom         like datmservico.c24solnom ,
    c24soltipdes      char (10)
 end record

 define retorno       record
    atdsrvorg         char (02)  ,
    atdsrvnum         char (07)  ,
    atdsrvano         char (02)
 end record

 define ws            record
    lignum            like datmligacao.lignum      ,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    atddat            like datmservico.atddat      ,
    atdhor            char (08)                    ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    c24soltipcod      like datksoltip.c24soltipcod
 end record

 define arr_aux       smallint
 define scr_aux       smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  5
		initialize  a_cts11m02[w_pf1].*  to  null
	end	for

	initialize  retorno.*  to  null

	initialize  ws.*  to  null

 initialize a_cts11m02   to null
 initialize ws.*         to null
 let arr_aux = 1

 declare c_cts11m02_001   cursor for
    select datrservapol.atdsrvnum, datrservapol.atdsrvano,
           datmservico.atddat    , datmservico.atdhor    ,
           datmservico.atdsrvorg
      from datrservapol, datmservico
     where datrservapol.succod     = param.succod        and
           datrservapol.ramcod     = param.ramcod        and
           datrservapol.aplnumdig  = param.aplnumdig     and
           datrservapol.itmnumdig  = param.itmnumdig     and

           datmservico.atdsrvnum   = datrservapol.atdsrvnum   and
           datmservico.atdsrvano   = datrservapol.atdsrvano
     order by datmservico.atddat desc, datmservico.atdhor desc

  foreach c_cts11m02_001  into  ws.atdsrvnum, ws.atdsrvano,
                            a_cts11m02[arr_aux].atddat,
                            ws.atdhor   ,
                            ws.atdsrvorg

     if param.atdsrvorg is null  then
        if ws.atdsrvorg <> 4   and   ### Servico diferente de SOCORRO
           ws.atdsrvorg <> 6   and   ### Servico diferente de DAF
           ws.atdsrvorg <> 1   then  ### Servico diferente de REMOCAO
           continue foreach
        end if
     else
        if ws.atdsrvorg <> param.atdsrvorg  then
           continue foreach
        end if
     end if

     call cts20g00_servico( ws.atdsrvnum,
                            ws.atdsrvano )
          returning ws.lignum

     select c24soltipcod,
            c24solnom
       into ws.c24soltipcod,
            a_cts11m02[arr_aux].c24solnom
       from datmligacao
            where lignum = ws.lignum

     select c24soltipdes
       into a_cts11m02[arr_aux].c24soltipdes
       from datksoltip
            where c24soltipcod = ws.c24soltipcod

     let a_cts11m02[arr_aux].atdhor  = ws.atdhor[1,5]

     let a_cts11m02[arr_aux].servico = ws.atdsrvorg using "&&",
                                  "/", ws.atdsrvnum using "&&&&&&&",
                                  "-", ws.atdsrvano using "&&"

     let arr_aux = arr_aux + 1
     if arr_aux > 05   then
        error " Limite excedido. Apolice com mais de CINCO servicos!"
        exit foreach
     end if
  end foreach

  if arr_aux  =  1   then
     error " Nao existe nenhuma solicitacao de servico para esta apolice!"
  else
     open window w_cts11m02 at 11,10  with form  "cts11m02"
           attribute(form line first, border)

     message " (F17)Abandona, (F8)Seleciona"

     call set_count(arr_aux-1)

     display array a_cts11m02 to s_cts11m02.*
        on key(interrupt)
           initialize retorno.*  to null
           exit display

        on key(F8)
           let arr_aux = arr_curr()
           let retorno.atdsrvorg = a_cts11m02[arr_aux].servico[01,02]
           let retorno.atdsrvnum = a_cts11m02[arr_aux].servico[04,10]
           let retorno.atdsrvano = a_cts11m02[arr_aux].servico[12,13]
           exit display
     end display

     close window  w_cts11m02
  end if

  let int_flag = false
  return retorno.*

end function   ### cts11m02
