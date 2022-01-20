#############################################################################
# Nome do Modulo: ctn42C00                                         Marcelo  #
#                                                                  Gilberto #
# Consulta aeroportos                                              Jul/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

 define g_pesquisa smallint

#------------------------------------------------------------------------
 function ctn42c00(param)
#------------------------------------------------------------------------

 define param      record
    endcep         like glaklgd.lgdcep
 end record

 define retorno    record
    arpcod         like datkaeroporto.arpcod
 end record



	initialize  retorno.*  to  null

 open window w_ctn42c00 at 04,02 with form "ctn42c00"
             attribute(form line first)

 initialize retorno.* to null
 let g_pesquisa = 0

 menu "AEROPORTOS"

    before menu
       hide option "Proxima_regiao"

    command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
       if param.endcep is null     then
          error " Nenhum CEP selecionado!"
          next option "Encerra"
       else
          let g_pesquisa = 0
          call pesquisa_ctn42c00(param.*) returning retorno.*

          show option "Proxima_regiao"

          if retorno.arpcod is not null  then
             next option "Encerra"
          else
             next option "Proxima_regiao"
          end if
       end if

       if retorno.arpcod is not null  then
          exit menu
       end if

    command key ("P") "Proxima_regiao" "Pesquisa proxima regiao do CEP "
       if param.endcep is null  then
          error " Nenhum CEP selecionado!"
          next option "Seleciona"
       else
          let g_pesquisa = g_pesquisa + 1

          call pesquisa_ctn42c00(param.*) returning retorno.*

          if retorno.arpcod is not null  then
             next option "Encerra"
          else
             next option "Proxima_regiao"
          end if
       end if

       if retorno.arpcod is not null  then
          exit menu
       end if

    command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
       exit menu
 end menu

 close window w_ctn42c00

 return retorno.*

end function  ###  ctn42c00

#------------------------------------------------------------------------
 function pesquisa_ctn42c00(param)
#------------------------------------------------------------------------

 define param      record
    endcep         like glaklgd.lgdcep
 end record

 define a_ctn42c00 array[30] of record
    arpcod         like datkaeroporto.arpcod      ,
    arpnom         like datkaeroporto.arpnom      ,
    arpend         char (65)                      ,
    brrnom         like datkaeroporto.brrnom      ,
    cidnom         like datkaeroporto.cidnom      ,
    ufdcod         like datkaeroporto.ufdcod      ,
    lgdcep         like datkaeroporto.lgdcep      ,
    lgdcepcmp      like datkaeroporto.lgdcepcmp   ,
    dddcod         like datkaeroporto.dddcod      ,
    lcltelnum      like datkaeroporto.lcltelnum   ,
    lclrefptotxt   like datkaeroporto.lclrefptotxt,
    hor24h         char (01)                      ,
    horsegsexinc   like datkaeroporto.horsegsexinc,
    horsegsexfnl   like datkaeroporto.horsegsexfnl,
    horsabinc      like datkaeroporto.horsabinc   ,
    horsabfnl      like datkaeroporto.horsabfnl   ,
    hordominc      like datkaeroporto.hordominc   ,
    hordomfnl      like datkaeroporto.hordomfnl
 end record

 define arr_aux    smallint

 define retorno    record
    arpcod         like datkaeroporto.arpcod
 end record

 define ws         record
    sql            char (800),
    lgdtip         like datkaeroporto.lgdtip,
    lgdnom         like datkaeroporto.lgdnom,
    lgdnum         like datkaeroporto.lgdnum,
    endufd         like datkavislocal.endufd,
    endcep         char (05)
 end record


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  30
		initialize  a_ctn42c00[w_pf1].*  to  null
	end	for

	initialize  retorno.*  to  null

	initialize  ws.*  to  null

 initialize a_ctn42c00    to null
 initialize retorno.*     to null
 initialize ws.*          to null

 let int_flag = false

 if g_pesquisa = 0  then
    clear form
 end if

 let ws.endcep = param.endcep

 case g_pesquisa
    when 0  let ws.endcep = param.endcep
    when 1  let ws.endcep[5,5] = "*"
    when 2  let ws.endcep[4,5] = "* "
    when 3  let ws.endcep[3,5] = "*  "
    when 4  let ws.endcep[2,5] = "*   "
    otherwise
       error " Nenhum aeroporto localizado nesta regiao!"
       initialize retorno.* to null
       return retorno.*
 end case

 let int_flag = false

 let ws.sql = "select arpcod      , arpnom      , ",
              "       lgdtip      , lgdnom      , ",
              "       lgdnum      , brrnom      , ",
              "       cidnom      , ufdcod      , ",
              "       lgdcep      , lgdcepcmp   , ",
              "       dddcod      , lcltelnum   , ",
              "       lclrefptotxt, horsegsexinc, ",
              "       horsegsexfnl, horsabinc   , ",
              "       horsabfnl   , hordominc   , ",
              "       hordomfnl                   ",
              "  from datkaeroporto               "

 if g_pesquisa = 0  then
    let ws.sql = ws.sql clipped, " where lgdcep = ? "
 else
    let ws.sql = ws.sql clipped, " where lgdcep matches '" ,ws.endcep, "'"
 end if

 let ws.sql = ws.sql clipped, " order by lgdcep "

 if g_pesquisa > 0  then
    let ws.sql = ws.sql clipped, " desc "
 end if

 prepare p_ctn42c00_001 from ws.sql

 while not int_flag
    let arr_aux = 1

    declare c_ctn42c00_001 cursor for p_ctn42c00_001

    if g_pesquisa = 0  then
       open c_ctn42c00_001 using ws.endcep
    else
       open c_ctn42c00_001
    end if

    message " Aguarde, pesquisando... ", ws.endcep  attribute (reverse)

    foreach c_ctn42c00_001  into  a_ctn42c00[arr_aux].arpcod      ,
                              a_ctn42c00[arr_aux].arpnom      ,
                              ws.lgdtip                       ,
                              ws.lgdnom                       ,
                              ws.lgdnum                       ,
                              a_ctn42c00[arr_aux].brrnom      ,
                              a_ctn42c00[arr_aux].cidnom      ,
                              a_ctn42c00[arr_aux].ufdcod      ,
                              a_ctn42c00[arr_aux].lgdcep      ,
                              a_ctn42c00[arr_aux].lgdcepcmp   ,
                              a_ctn42c00[arr_aux].dddcod      ,
                              a_ctn42c00[arr_aux].lcltelnum   ,
                              a_ctn42c00[arr_aux].lclrefptotxt,
                              a_ctn42c00[arr_aux].horsegsexinc,
                              a_ctn42c00[arr_aux].horsegsexfnl,
                              a_ctn42c00[arr_aux].horsabinc   ,
                              a_ctn42c00[arr_aux].horsabfnl   ,
                              a_ctn42c00[arr_aux].hordominc   ,
                              a_ctn42c00[arr_aux].hordomfnl

       let a_ctn42c00[arr_aux].arpend = ws.lgdtip clipped, " ",
                                        ws.lgdnom clipped, " ",
                                        ws.lgdnum using "####"

       if a_ctn42c00[arr_aux].horsegsexinc = "00:00"  and
          a_ctn42c00[arr_aux].horsegsexfnl = "23:59"  and
          a_ctn42c00[arr_aux].horsabinc    = "00:00"  and
          a_ctn42c00[arr_aux].horsabfnl    = "23:59"  and
          a_ctn42c00[arr_aux].hordominc    = "00:00"  and
          a_ctn42c00[arr_aux].hordomfnl    = "23:59"  then
          let a_ctn42c00[arr_aux].hor24h = "S"
       else
          let a_ctn42c00[arr_aux].hor24h = "N"
       end if

       let arr_aux = arr_aux + 1
       if arr_aux > 30   then
          error " Limite excedido. Pesquisa com mais de 30 lojas!"
          exit foreach
       end if
    end foreach

    if arr_aux > 1  then
       call set_count(arr_aux-1)
       message " (F17)Abandona, (F8)Seleciona "

       display array  a_ctn42c00 to s_ctn42c00.*

          on key (interrupt)
             initialize a_ctn42c00   to null
             initialize retorno.*    to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let retorno.arpcod = a_ctn42c00[arr_aux].arpcod
             error " Aeroporto selecionado! "
             let int_flag = true
             exit display
       end display
    else
       error " Nenhuma loja localizada neste CEP - Tente proxima regiao!"
       let int_flag = true
    end if
 end while

 let int_flag = false

 return retorno.*

end function  ###  pesquisa_ctn42c00
