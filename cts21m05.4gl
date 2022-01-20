###############################################################################
# Nome do Modulo: CTS21M05                                            Marcelo #
#                                                                    Gilberto #
# Localiza Vistoria de Sinistro de R.E.                              Nov/1995 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 30/08/2001  PSI 132306    Ruiz        Permitir a consulta atraves do        #
#                                       sistema de atendimento.(cta00m01)     #
#-----------------------------------------------------------------------------#
# 20/06/2006  PSI 200140    Priscila    Adicionar atalho para exibir cob/nat  #
#-----------------------------------------------------------------------------#

database porto

#------------------------------------------------------------
 function cts21m05(param)
#------------------------------------------------------------
 define param         record
    pgm               char (08)
 end record

 define d_cts21m05    record
    sinvstdat         like datmpedvist.sinvstdat,
    sinvstnum         like datmpedvist.sinvstnum,
    sinvstano         like datmpedvist.sinvstano,
    acipriflg         char(01)
 end record

 define a_cts21m05 array[400] of record
    sinvstdat         like datmpedvist.sinvstdat,
    sinvstnum         like datmpedvist.sinvstnum,
    sinvstano         like datmpedvist.sinvstano,
    segper            char(49),
    sinvsthor         like datmpedvist.sinvsthor,
    #sinntzdes         like sgaknatur.sinntzdes,   #PSI 200140
    sindat            like datmpedvist.sindat,
    sinhor            like datmpedvist.sinhor
 end record

 define ws            record
    sql_select        char(300),
    sql_condition     char(140),
    sinvstdat         char(10),
    total             char(10),
    sinpricod         like datmpedvist.sinpricod,
    nomrazsoc         like sgkkperi.nomrazsoc,
    segnom            like datmpedvist.segnom,
    rglvstflg         like datmpedvist.rglvstflg,
    sinvsthor         like datmpedvist.sinvsthor,
    sindat            like datmpedvist.sindat,
    sinhor            like datmpedvist.sinhor
    #sinntzcod         like datmpedvist.sinntzcod  #PSI 200140
 end record

 define retorno       record
    sinvstnum         like datmpedvist.sinvstnum,
    sinvstano         like datmpedvist.sinvstano
 end record

 define arr_aux       smallint
 define ws_necessario smallint
 define aux_char      char(04)
 define aux_ano2      dec(2,0)


	define	w_pf1	integer

	let	arr_aux  =  null
	let	ws_necessario  =  null

	for	w_pf1  =  1  to  400
		initialize  a_cts21m05[w_pf1].*  to  null
	end	for

	initialize  d_cts21m05.*  to  null

	initialize  ws.*  to  null

	initialize  retorno.*  to  null

 #PSI 200140
 #let ws.sql_select = "select sinntzdes ",
 #                    "  from sgaknatur ",
 #                    " where sinramgrp = '4' ",
 #                    "   and sinntzcod = ? "
 #prepare comando_aux from ws.sql_select
 #declare c_sgaknatur cursor for comando_aux

 let ws_necessario = false


 open window w_cts21m05 at  06,02 with form "cts21m05"
             attribute(form line first, message line last)

 while true

    initialize ws.*          to null
    initialize a_cts21m05    to null
    let int_flag = false
    let arr_aux  = 1

    input by name d_cts21m05.*

       before field sinvstdat
              display by name d_cts21m05.sinvstdat attribute (reverse)

              let d_cts21m05.sinvstdat = today

       after  field sinvstdat
              display by name d_cts21m05.sinvstdat

              if d_cts21m05.sinvstdat  is null   then
                 error " Informe a data para pesquisa!"
                 next field sinvstdat
              end if

       before field sinvstnum
              display by name d_cts21m05.sinvstnum attribute (reverse)

       after  field sinvstnum
              display by name d_cts21m05.sinvstnum

       before field sinvstano
              display by name d_cts21m05.sinvstano attribute (reverse)

       after  field sinvstano
              display by name d_cts21m05.sinvstano

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field sinvstnum
              end if

              if d_cts21m05.sinvstnum     is null    then
                 if d_cts21m05.sinvstano  is not null   then
                    error " Numero da vistoria deve ser informado !!"
                    next field sinvstnum
                 end if
              else
                 if d_cts21m05.sinvstano  is null   then
                    error " Ano da vistoria deve ser informado !!"
                   next field sinvstano
                 end if
              end if

              if d_cts21m05.sinvstdat is null  and
                 d_cts21m05.sinvstnum is null  and
                 d_cts21m05.sinvstano is null  then
                 error " Informe uma chave para pesquisa!"
              end if

       before field acipriflg
              display by name d_cts21m05.acipriflg attribute (reverse)

       after  field acipriflg
              display by name d_cts21m05.acipriflg

              display " "  to  cabper
              if fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then
                 if d_cts21m05.acipriflg <> "A" and
                    d_cts21m05.acipriflg <> "N" and
                    d_cts21m05.acipriflg is not null then
                    error " Exibir reguladores: (A)cionados ou (N)ao Acionados."
                    next field acipriflg
                 end if

                 if d_cts21m05.acipriflg  = "A"   then
                    display "Regulador" to cabper
                 end if
              end if

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

 #-------------------------------------------
 # VERIFICA SE JIT-RE E DESPREZA
 #-------------------------------------------
 let ws.sql_select= "select atdsrvnum ",
                    "  from datmsrvjit ",
                    " where refatdsrvnum = ? ",
                    "   and refatdsrvano = ? "
 prepare p_cts21m05_001 from ws.sql_select
 declare c_cts21m05_001 cursor for p_cts21m05_001

 #-------------------------------------------
 # CONSULTA AS VISTORIAS MARCADAS
 #-------------------------------------------

 if d_cts21m05.sinvstnum is not null   then
    let ws.sql_condition = "  from datmpedvist                ",
                           " where datmpedvist.sinvstnum = ?  ",
                           "   and datmpedvist.sinvstano = ?  "
 else
    let ws.sql_condition = "  from datmpedvist                ",
                           " where datmpedvist.sinvstdat >= ? "
 end if

 let ws.sql_select= "select sinvstdat, ",
                    "       sinvsthor, ",
                    "       sinvstnum, ",
                    "       sinvstano, ",
                    "       segnom,    ",
                    "       sinpricod, ",
                    "       rglvstflg, ",
                    "       sindat,    ",
                    "       sinhor    ",
                    #"       sinntzcod  ",
                    ws.sql_condition  clipped

 message " Aguarde, pesquisando..."  attribute(reverse)
 prepare p_cts21m05_002 from ws.sql_select
 declare c_cts21m05_002 cursor for p_cts21m05_002

 if d_cts21m05.sinvstnum  is not null   then
    open c_cts21m05_002  using d_cts21m05.sinvstnum, d_cts21m05.sinvstano
 else
    open c_cts21m05_002  using d_cts21m05.sinvstdat
 end if

 if d_cts21m05.acipriflg is null then
    foreach  c_cts21m05_002  into  a_cts21m05[arr_aux].sinvstdat,
                               a_cts21m05[arr_aux].sinvsthor,
                               a_cts21m05[arr_aux].sinvstnum,
                               a_cts21m05[arr_aux].sinvstano,
                               a_cts21m05[arr_aux].segper,
                               ws.sinpricod,
                               ws.rglvstflg,
                               a_cts21m05[arr_aux].sindat,
                               a_cts21m05[arr_aux].sinhor
                               #ws.sinntzcod                     #PSI 200140

        #initialize a_cts21m05[arr_aux].sinntzdes to null        #PSI 200140
        initialize aux_char, aux_ano2 to null

        let aux_char = a_cts21m05[arr_aux].sinvstano
        let aux_ano2 = aux_char[3,4]

        open c_cts21m05_001 using a_cts21m05[arr_aux].sinvstnum, aux_ano2
        fetch c_cts21m05_001

        if status <> notfound then
           initialize a_cts21m05[arr_aux].* to null
           initialize ws.sinpricod,
                      ws.rglvstflg to null
                      #ws.sinntzcod to null
           continue foreach
        end if

        #PSI 200140
        #open  c_sgaknatur using ws.sinntzcod
        #fetch c_sgaknatur into  a_cts21m05[arr_aux].sinntzdes
        #close c_sgaknatur

        let arr_aux = arr_aux + 1
        if arr_aux > 400  then
           error " Limite excedido, pesquisa com mais de 400 marcacoes!"
           exit foreach
        end if
    end foreach

 else
    foreach  c_cts21m05_002  into  d_cts21m05.sinvstdat,
                               ws.sinvsthor,
                               d_cts21m05.sinvstnum,
                               d_cts21m05.sinvstano,
                               ws.segnom,
                               ws.sinpricod,
                               ws.rglvstflg,
                               ws.sindat,
                               ws.sinhor
                               #ws.sinntzcod                #PSI 200140

       if ws.rglvstflg = "S" then {As condicoes da vistoria pedem um regulador}
          #------------ Exibe apenas os reguladores ja' acionados -------------#
          if ( d_cts21m05.acipriflg = "A" and ws.sinpricod is not null )
          #----------- Exibe apenas os reguladores ainda nao acionados --------#
          or ( d_cts21m05.acipriflg = "N" and ws.sinpricod is     null )  then

             let a_cts21m05[arr_aux].sinvstdat = d_cts21m05.sinvstdat
             let a_cts21m05[arr_aux].sinvsthor = ws.sinvsthor
             let a_cts21m05[arr_aux].sinvstnum = d_cts21m05.sinvstnum
             let a_cts21m05[arr_aux].sinvstano = d_cts21m05.sinvstano
             let a_cts21m05[arr_aux].sindat    = ws.sindat
             let a_cts21m05[arr_aux].sinhor    = ws.sinhor

             #PSI 200140
             #initialize a_cts21m05[arr_aux].sinntzdes to null

             #open  c_sgaknatur using ws.sinntzcod
             #fetch c_sgaknatur into  a_cts21m05[arr_aux].sinntzdes
             #close c_sgaknatur

             if ws.sinpricod  is null   then
                let a_cts21m05[arr_aux].segper = ws.segnom
             else
                select nomrazsoc
                  into ws.nomrazsoc
                  from sgkkperi
                 where sindptcod = 1
                   and sinpricod = ws.sinpricod

                let a_cts21m05[arr_aux].segper = ws.segnom[1,26], "   ",
                                                 ws.nomrazsoc
             end if
             let arr_aux = arr_aux + 1
          else
              continue foreach
          end if
       else
          continue foreach
       end if

      if arr_aux > 400  then
           error " Limite excedido, pesquisa com mais de 400 marcacoes!"
          exit foreach
       end if
    end foreach

 end if

 let ws.total = "Total: ", arr_aux - 1 using "&&&"
 display by name ws.total  attribute (reverse)

 if arr_aux  > 1   then
    message " (F17)Abandona, (F4)Cob/Nat, (F8)Seleciona"
    call set_count(arr_aux-1)

    display array  a_cts21m05 to s_cts21m05.*

      on key(interrupt)
         initialize ws.total to null
         display by name ws.total
         exit display

      #PSI 200140
      on key (F4)
         let arr_aux = arr_curr()
         call cts21m11(a_cts21m05[arr_aux].sinvstnum,
                       a_cts21m05[arr_aux].sinvstano)

      on key(f8)
         let arr_aux = arr_curr()
         if param.pgm = "cta00m01"  then
            let retorno.sinvstnum = a_cts21m05[arr_aux].sinvstnum
            let retorno.sinvstano = a_cts21m05[arr_aux].sinvstano
            exit display
         end if
         error " Selecione e tecle ENTER!"
         call cts21m03(a_cts21m05[arr_aux].sinvstnum,
                       a_cts21m05[arr_aux].sinvstano)
    end display

    for arr_aux = 1 to 4
        clear s_cts21m05[arr_aux].vstmrcdat
        clear s_cts21m05[arr_aux].vstmrchor
        clear s_cts21m05[arr_aux].sinvstnum2
        clear s_cts21m05[arr_aux].sinvstano2
        clear s_cts21m05[arr_aux].segper
        clear s_cts21m05[arr_aux].sindat
        clear s_cts21m05[arr_aux].sinhor
        #clear s_cts21m05[arr_aux].sinntzdes
    end for
 else
    error " Nao existem vistorias programadas para pesquisa!"
 end if
 if param.pgm = "cta00m01"  and
    retorno.sinvstnum is not null then
    exit while
 end if
 end while

 let int_flag = false
 close window  w_cts21m05
 if param.pgm = "cta00m01" then
    return retorno.sinvstnum,
           retorno.sinvstano
 end if
 end function  #  cts21m05
