 #############################################################################
 # Nome do Modulo: ctn46c00                                         Gilberto #
 #                                                                   Marcelo #
 # Pesquisa logradouro na base de mapas                             Out/1999 #
 #############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 20/02/2001  PSI 12597-0  Marcus       Calculo entre cidades               #
 #---------------------------------------------------------------------------#
 # 19/03/2002  PSI 15000-2  Marcus       Consulta de prestadores Porto Socor #
 #                                       ro por coordenadas (Mapa)           #
 #---------------------------------------------------------------------------#
 # 13/09/2002  CORREIO EDU  Raji         Ordenar por lgd e bairro            #
 ##############################################################################


 database porto

#------------------------------------------------------------
 function ctn46c00(param)
#------------------------------------------------------------

 define param         record
    tipo              dec (1,0)
 end record

 define d_ctn46c00    record
    ufdcodpsq         like datkmpacid.ufdcod,
    cidnompsq         like datkmpacid.cidnom,
    lgdnompsq         like datkmpalgd.lgdnom,
    lgdnumpsq         like datkmpalgdsgm.mpalgdincnum,
    tippsq            char (01)
 end record

 define a_ctn46c00    array[500]  of  record
    lgdnom            char (71),
    brrnom            like datkmpabrr.brrnom,
    mpalgdincnum      like datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum      like datkmpalgdsgm.mpalgdfnlnum,
    lclltt            like datkmpalgdsgm.lclltt,
    lcllgt            like datkmpalgdsgm.lcllgt,
    ufdcod            like datkmpacid.ufdcod,
    cidnom            like datkmpacid.cidnom
 end record

 define a_ctn46c00n   array[100]  of  record
    lgdnom            char (71),
    brrnom            like datkmpabrr.brrnom,
    mpalgdincnum      like datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum      like datkmpalgdsgm.mpalgdfnlnum,
    lclltt            like datkmpalgdsgm.lclltt,
    lcllgt            like datkmpalgdsgm.lcllgt,
    ufdcod            like datkmpacid.ufdcod,
    cidnom            like datkmpacid.cidnom
 end record

 define a_ctn46c00s   array[002]  of  record
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
    lgdtip            like datkmpalgd.lgdtip,
    mpacidcod         like datkmpacid.mpacidcod,
    prifoncod         like datkmpalgd.prifoncod,
    segfoncod         like datkmpalgd.segfoncod,
    terfoncod         like datkmpalgd.terfoncod,
    cidcod            like glakcid.cidcod,
    lgdnompsq         char (062),
    entfon            char (051),
    saifon            char (100),
    sql               char (1200),
    comando           char (600),
    condicao          char (600),
    confirma          char (01),
    cont              dec  (6,0),
    mpacrglgdflg      like datkmpacid.mpacrglgdflg,
    lclltt            like datkmpacid.lclltt,
    lcllgt            like datkmpacid.lcllgt,
    psqtip            dec (1,0)
 end record

 define arr_aux       smallint
 define arr_sel       smallint
 define arr_aux2      smallint

#let param.tipo = arg_val(0)


	define	w_pf1	integer

	let	arr_aux  =  null
	let	arr_sel  =  null
	let	arr_aux2  =  null

	for	w_pf1  =  1  to  500
		initialize  a_ctn46c00[w_pf1].*  to  null
	end	for

	for	w_pf1  =  1  to  100
		initialize  a_ctn46c00n[w_pf1].*  to  null
	end	for

	for	w_pf1  =  1  to  2
		initialize  a_ctn46c00s[w_pf1].*  to  null
	end	for

	initialize  d_ctn46c00.*  to  null

	initialize  ws.*  to  null

 open window w_ctn46c00 at  06,02 with form "ctn46c00"
             attribute(form line first)

 let arr_sel  =  1

 while true

    initialize d_ctn46c00   to null
    initialize a_ctn46c00   to null
    initialize a_ctn46c00n  to null
    initialize ws.*         to null
    clear form
    let int_flag  =  false
    let arr_aux   =  1
    let arr_aux2  =  1

    input by name d_ctn46c00.ufdcodpsq,
                  d_ctn46c00.cidnompsq,
                  d_ctn46c00.lgdnompsq,
                  d_ctn46c00.lgdnumpsq,
                  d_ctn46c00.tippsq     without defaults

       before field ufdcodpsq
             display by name d_ctn46c00.ufdcodpsq  attribute(reverse)

       after field ufdcodpsq
             display by name d_ctn46c00.ufdcodpsq

             if d_ctn46c00.ufdcodpsq  is null   then
                let d_ctn46c00.ufdcodpsq  =  "SP"
                display by name d_ctn46c00.ufdcodpsq
             end if

             select ufdcod
               from glakest
              where ufdcod  =  d_ctn46c00.ufdcodpsq

             if sqlca.sqlcode  =  notfound   then
                error " Codigo de UF nao cadastrado!"
                next field ufdcodpsq
             end if

       before field cidnompsq
             display by name d_ctn46c00.cidnompsq  attribute(reverse)

       after field cidnompsq
             display by name d_ctn46c00.cidnompsq

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field ufdcodpsq
             end if

             if d_ctn46c00.cidnompsq  is null   then
                let d_ctn46c00.cidnompsq  =  "SAO PAULO"
                display by name d_ctn46c00.cidnompsq
             end if

             declare c_ctn46c00_001 cursor for
             select cidcod
               from glakcid
              where cidnom  = d_ctn46c00.cidnompsq
                and ufdcod  = d_ctn46c00.ufdcodpsq

              open c_ctn46c00_001

             if sqlca.sqlcode  =  notfound   then
                error " Cidade nao cadastrada!"
                call cts06g04(d_ctn46c00.cidnompsq,
                              d_ctn46c00.ufdcodpsq)
                     returning ws.cidcod,
                               d_ctn46c00.cidnompsq,
                               d_ctn46c00.ufdcodpsq
                display by name d_ctn46c00.cidnompsq
                display by name d_ctn46c00.ufdcodpsq
                next field cidnompsq
             end if

             close c_ctn46c00_001

             select mpacidcod,
                    mpacrglgdflg
               into ws.mpacidcod,
                    ws.mpacrglgdflg
               from datkmpacid
              where cidnom  =  d_ctn46c00.cidnompsq
                and ufdcod  =  d_ctn46c00.ufdcodpsq

             if sqlca.sqlcode  =  notfound   then
                error " Cidade nao cadastrada na base de mapas!"
                next field cidnompsq
             end if

       before field lgdnompsq
             display by name d_ctn46c00.lgdnompsq  attribute(reverse)
             if ws.mpacrglgdflg = 0 then
		# cidade nao possui carga dos mapas
                let ws.psqtip = 1
                error "Cidade nao possui logradouros carregados !"
                exit input
             end if

       after field lgdnompsq
             display by name d_ctn46c00.lgdnompsq

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field cidnompsq
             end if

             if d_ctn46c00.lgdnompsq  is null   then
               # Utilizar as coordenadas da cidade
               let ws.psqtip = 1
               exit input
             else
              let ws.psqtip = 0
             end if

       before field lgdnumpsq
             display by name d_ctn46c00.lgdnumpsq  attribute(reverse)

       after field lgdnumpsq
             display by name d_ctn46c00.lgdnumpsq

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field lgdnompsq
             end if

       before field tippsq
             let d_ctn46c00.tippsq  =  "F"
             display by name d_ctn46c00.tippsq  attribute(reverse)

       after field tippsq
             display by name d_ctn46c00.tippsq

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field lgdnumpsq
             end if

             if ((d_ctn46c00.tippsq  is null)    or
                 (d_ctn46c00.tippsq  <>  "F"     and
                  d_ctn46c00.tippsq  <>  "P"))   then
                error " Pesquisa deve ser: (F)onetica, (P)arcial!"
                next field tippsq
             end if

             if d_ctn46c00.tippsq  =  "F"   then
                exit input
             end if

             let ws.cont  =  0
             let ws.cont  =  length(d_ctn46c00.lgdnompsq)
             if ws.cont  <  5   then
                error " Logradouro nao deve conter menos que 5 caracteres!"
                next field lgdnompsq
             end if
             let ws.lgdnompsq = "*", d_ctn46c00.lgdnompsq clipped, "*"

       on key (interrupt)
              exit input

    end input

    if int_flag   then
       exit while
    end if

    message " Aguarde, pesquisando..."  attribute (reverse)

    let arr_aux   =  1
    let arr_aux2  =  1

    if ws.psqtip = 1 then
       let ws.comando  = "select lclltt,    ",
                       "       lcllgt     ",
                       "  from datkmpacid "
    else
       let ws.comando  = "select datkmpalgd.lgdtip, ",
                       "       datkmpalgd.lgdnom, ",
                       "       datkmpabrr.brrnom, ",
                       "       datkmpalgdsgm.mpalgdincnum, ",
                       "       datkmpalgdsgm.mpalgdfnlnum,",
                       "       datkmpalgdsgm.lclltt, ",
                       "       datkmpalgdsgm.lcllgt ",
                       "  from datkmpalgd, datkmpalgdsgm, outer datkmpabrr "
    end if
    #-----------------------------------------------------------
    # Pesquisa por parte do nome do logradouro
    #-----------------------------------------------------------
    if ws.psqtip = 1 then
       #cidade sem carga de mapas
       let ws.condicao = " where mpacidcod = ? "
       let ws.sql = ws.comando  clipped, ws.condicao

       prepare p_ctn46c00_001  from        ws.sql
       declare c_ctn46c00_002  cursor for  p_ctn46c00_001

       open  c_ctn46c00_002 using  ws.mpacidcod
       fetch c_ctn46c00_002 into   a_ctn46c00[arr_aux].lclltt,
                                   a_ctn46c00[arr_aux].lcllgt

       let a_ctn46c00[arr_aux].ufdcod = d_ctn46c00.ufdcodpsq
       let a_ctn46c00[arr_aux].cidnom = d_ctn46c00.cidnompsq

       let arr_aux = arr_curr()
       let a_ctn46c00s[arr_sel].* = a_ctn46c00[arr_aux].*

       if arr_sel  =  2    then
          call ctn46c01(a_ctn46c00s[01].*, a_ctn46c00s[02].*)
             let arr_sel  =  1
             initialize a_ctn46c00s  to null
       else
             if param.tipo = 0 then
                call cts08g01("A","N","",
                              "SELECIONE OUTRO LOCAL E TECLE",
                              "(F8) PARA CALCULAR A DISTANCIA",
                              "ENTRE OS DOIS LOCAIS")
                     returning ws.confirma
                let arr_sel = 2
             else
               close window w_ctn46c00
               return a_ctn46c00s[01].lclltt,
                      a_ctn46c00s[01].lcllgt,
                      a_ctn46c00s[01].ufdcod,
                      a_ctn46c00s[01].cidnom

             end if
       end if
    else
       if d_ctn46c00.tippsq  =  "P"   then

          let ws.condicao =
                 " where datkmpalgd.lgdnom matches '",ws.lgdnompsq,"'",
                 "   and datkmpalgd.mpacidcod    = ? ",
                 "   and datkmpalgdsgm.mpalgdcod = datkmpalgd.mpalgdcod ",
                 "   and datkmpabrr.mpacidcod  = datkmpalgdsgm.mpacidcod",
                 "   and datkmpabrr.mpabrrcod  = datkmpalgdsgm.mpabrrcod",
                 " order by 1,2,3,4"

          let ws.sql = ws.comando  clipped, ws.condicao

          prepare p_ctn46c00_002  from        ws.sql
          declare c_ctn46c00_003  cursor for  p_ctn46c00_002

          open    c_ctn46c00_003 using  ws.mpacidcod
          foreach c_ctn46c00_003 into   ws.lgdtip,
                                        a_ctn46c00[arr_aux].lgdnom,
                                        a_ctn46c00[arr_aux].brrnom,
                                        a_ctn46c00[arr_aux].mpalgdincnum,
                                        a_ctn46c00[arr_aux].mpalgdfnlnum,
                                        a_ctn46c00[arr_aux].lclltt,
                                        a_ctn46c00[arr_aux].lcllgt

             let a_ctn46c00[arr_aux].lgdnom  =  ws.lgdtip clipped, " ",
                                             a_ctn46c00[arr_aux].lgdnom

             if d_ctn46c00.lgdnumpsq  is not null   then
                if a_ctn46c00[arr_aux].mpalgdincnum <= d_ctn46c00.lgdnumpsq   and
                   a_ctn46c00[arr_aux].mpalgdfnlnum >= d_ctn46c00.lgdnumpsq   then
                   let a_ctn46c00n[arr_aux2].* = a_ctn46c00[arr_aux].*
                   let arr_aux2  =  arr_aux2 + 1
                end if
             end if

             let arr_aux = arr_aux + 1

             if arr_aux > 500  then
                error " Limite excedido! Encontrados mais de 500 logradouros (1)!"
                exit foreach
             end if
          end foreach

          if arr_aux > 1  then
             goto exibe_array
          else
             error " Nao foi encontrado nenhum logradouro para pesquisa!"
             continue while
          end if

       end if

       #-----------------------------------------------------------
       # Gera codigos foneticos para pesquisa
       #-----------------------------------------------------------
       let ws.entfon = "3", d_ctn46c00.lgdnompsq clipped

       call fonetica2(ws.entfon) returning ws.saifon

       if ws.saifon[1,3] = "100"  then
          error " Problema na geracao do codigo fonetico. AVISE A INFORMATICA!"
          continue while
       end if

       let ws.prifoncod = ws.saifon[01,15]
       let ws.segfoncod = ws.saifon[17,31]
       let ws.terfoncod = ws.saifon[33,47]

       if ws.prifoncod is null  or
          ws.prifoncod  =  " "  then
          let ws.prifoncod  =  d_ctn46c00.lgdnompsq[01,15]
       end if

       if ws.segfoncod is null  or
          ws.segfoncod  =  " "  then
          let ws.segfoncod = ws.prifoncod
       end if

       if ws.terfoncod is null  or
          ws.terfoncod  =  " "  then
          let ws.terfoncod = ws.prifoncod
       end if

       #-----------------------------------------------------------
       # Pesquisa pelo primeiro codigo fonetico
       #-----------------------------------------------------------
       let ws.condicao =
              " where datkmpalgd.prifoncod    = ? ",
              "   and datkmpalgd.mpacidcod    = ? ",
              "   and datkmpalgdsgm.mpalgdcod = datkmpalgd.mpalgdcod ",
              "   and datkmpabrr.mpacidcod  = datkmpalgdsgm.mpacidcod",
              "   and datkmpabrr.mpabrrcod  = datkmpalgdsgm.mpabrrcod",
              " order by 1,2,3,4"

       let ws.sql = ws.comando  clipped, ws.condicao

       prepare p_ctn46c00_003  from        ws.sql
       declare c_ctn46c00_004  cursor for  p_ctn46c00_003

       open    c_ctn46c00_004 using  ws.prifoncod,
                                     ws.mpacidcod
       foreach c_ctn46c00_004 into   ws.lgdtip,
                                     a_ctn46c00[arr_aux].lgdnom,
                                     a_ctn46c00[arr_aux].brrnom,
                                     a_ctn46c00[arr_aux].mpalgdincnum,
                                     a_ctn46c00[arr_aux].mpalgdfnlnum,
                                     a_ctn46c00[arr_aux].lclltt,
                                     a_ctn46c00[arr_aux].lcllgt

          let a_ctn46c00[arr_aux].lgdnom  =  ws.lgdtip clipped, " ",
                                             a_ctn46c00[arr_aux].lgdnom

          if d_ctn46c00.lgdnumpsq  is not null   then
             if a_ctn46c00[arr_aux].mpalgdincnum <= d_ctn46c00.lgdnumpsq   and
                a_ctn46c00[arr_aux].mpalgdfnlnum >= d_ctn46c00.lgdnumpsq   then
                let a_ctn46c00n[arr_aux2].* = a_ctn46c00[arr_aux].*
                let arr_aux2  =  arr_aux2 + 1
             end if
         end if

          let arr_aux = arr_aux + 1

          if arr_aux > 500  then
             error " Limite excedido! Encontrados mais de 500 logradouros (2)!"
             exit foreach
          end if
       end foreach

       if arr_aux > 1  then
          goto exibe_array
       end if

       #-----------------------------------------------------------
       # Pesquisa pelo segundo codigo fonetico
       #-----------------------------------------------------------
       let ws.condicao =
              " where datkmpalgd.segfoncod    = ? ",
              "   and datkmpalgd.mpacidcod    = ? ",
              "   and datkmpalgdsgm.mpalgdcod = datkmpalgd.mpalgdcod ",
              "   and datkmpabrr.mpacidcod  = datkmpalgdsgm.mpacidcod",
              "   and datkmpabrr.mpabrrcod  = datkmpalgdsgm.mpabrrcod",
              " order by 1,2,3,4"

       let ws.sql = ws.comando  clipped, ws.condicao

       prepare p_ctn46c00_004  from        ws.sql
       declare c_ctn46c00_005  cursor for  p_ctn46c00_004

       open    c_ctn46c00_005 using  ws.segfoncod,
                                     ws.mpacidcod
       foreach c_ctn46c00_005 into   ws.lgdtip,
                                     a_ctn46c00[arr_aux].lgdnom,
                                     a_ctn46c00[arr_aux].brrnom,
                                     a_ctn46c00[arr_aux].mpalgdincnum,
                                     a_ctn46c00[arr_aux].mpalgdfnlnum,
                                     a_ctn46c00[arr_aux].lclltt,
                                     a_ctn46c00[arr_aux].lcllgt

          let a_ctn46c00[arr_aux].lgdnom  =  ws.lgdtip clipped, " ",
                                             a_ctn46c00[arr_aux].lgdnom

          if d_ctn46c00.lgdnumpsq  is not null   then
             if a_ctn46c00[arr_aux].mpalgdincnum <= d_ctn46c00.lgdnumpsq   and
                a_ctn46c00[arr_aux].mpalgdfnlnum >= d_ctn46c00.lgdnumpsq   then
                let a_ctn46c00n[arr_aux2].* = a_ctn46c00[arr_aux].*
                let arr_aux2  =  arr_aux2 + 1
             end if
          end if

          let arr_aux = arr_aux + 1

          if arr_aux > 500  then
             error " Limite excedido! Encontrados mais de 500 logradouros!"
             exit foreach
          end if
       end foreach

       if arr_aux > 1  then
          goto exibe_array
       end if

       #-----------------------------------------------------------
       # Pesquisa pelo terceiro codigo fonetico
       #-----------------------------------------------------------
       let ws.condicao =
              " where datkmpalgd.terfoncod    = ? ",
              "   and datkmpalgd.mpacidcod    = ? ",
              "   and datkmpalgdsgm.mpalgdcod = datkmpalgd.mpalgdcod ",
              "   and datkmpabrr.mpacidcod  = datkmpalgdsgm.mpacidcod",
              "   and datkmpabrr.mpabrrcod  = datkmpalgdsgm.mpabrrcod",
              " order by 1,2,3,4"

       let ws.sql = ws.comando  clipped, ws.condicao

       prepare p_ctn46c00_005  from        ws.sql
       declare c_ctn46c00_006  cursor for  p_ctn46c00_005

       open    c_ctn46c00_006 using  ws.terfoncod,
                                     ws.mpacidcod
       foreach c_ctn46c00_006 into   ws.lgdtip,
                                     a_ctn46c00[arr_aux].lgdnom,
                                     a_ctn46c00[arr_aux].brrnom,
                                     a_ctn46c00[arr_aux].mpalgdincnum,
                                     a_ctn46c00[arr_aux].mpalgdfnlnum,
                                     a_ctn46c00[arr_aux].lclltt,
                                     a_ctn46c00[arr_aux].lcllgt

          let a_ctn46c00[arr_aux].lgdnom  =  ws.lgdtip clipped, " ",
                                             a_ctn46c00[arr_aux].lgdnom

          if d_ctn46c00.lgdnumpsq  is not null   then
             if a_ctn46c00[arr_aux].mpalgdincnum <= d_ctn46c00.lgdnumpsq   and
                a_ctn46c00[arr_aux].mpalgdfnlnum >= d_ctn46c00.lgdnumpsq   then
                let a_ctn46c00n[arr_aux2].* = a_ctn46c00[arr_aux].*
                let arr_aux2  =  arr_aux2 + 1
             end if
          end if

          let arr_aux = arr_aux + 1

          if arr_aux > 500  then
             error " Limite excedido! Encontrados mais de 500 logradouros (3)!"
             exit foreach
          end if
       end foreach

       if arr_aux > 1  then
          goto exibe_array
       else
          error " Nao foi encontrado nenhum logradouro para pesquisa!"
          continue while
       end if

       #-----------------------------------------------------------
       # Exibe logradouros encontrados na pesquisa
       #-----------------------------------------------------------
       label exibe_array:

          if arr_sel  =  2   then
             message " (F17)Abandona, (F8)Calculo, (F9)Limpa selecao"
          else
             message " (F17)Abandona, (F8)Seleciona, (F9)Limpa selecao"
          end if

          #-------------------------------------------------------------
          # Se encontrar numeracao informada, troca conteudo dos arrays
          #-------------------------------------------------------------
          if arr_aux2  >  1   then
             initialize a_ctn46c00  to null

             for arr_aux = 1 to arr_aux2 - 1
                let a_ctn46c00[arr_aux].*  =  a_ctn46c00n[arr_aux].*
             end for
          end if

          call set_count(arr_aux-1)

          display array a_ctn46c00 to s_ctn46c00.*
             on key (interrupt,control-c)
                let int_flag = false
                initialize d_ctn46c00.*  to null
                initialize a_ctn46c00    to null
                exit display

             on key (F8)
                let arr_aux = arr_curr()
                let a_ctn46c00s[arr_sel].* = a_ctn46c00[arr_aux].*

                let a_ctn46c00s[arr_sel].ufdcod  = d_ctn46c00.ufdcodpsq
                let a_ctn46c00s[arr_sel].cidnom  = d_ctn46c00.cidnompsq

                display a_ctn46c00s[arr_sel].lclltt
                display a_ctn46c00s[arr_sel].lcllgt

                if arr_sel  =  2    then
                   call ctn46c01(a_ctn46c00s[01].*, a_ctn46c00s[02].*)
                   let arr_sel  =  1
                   initialize a_ctn46c00s  to null
                else
                   if param.tipo = 0 then
                      call cts08g01("A","N","",
                                    "SELECIONE OUTRO LOCAL E TECLE",
                                    "(F8) PARA CALCULAR A DISTANCIA",
                                    "ENTRE OS DOIS LOCAIS")
                           returning ws.confirma
                      let arr_sel = 2
                   end if
                end if
                exit display

             on key (F9)
                let arr_sel = 1
                initialize a_ctn46c00s  to null
          end display
       if param.tipo = 1 then
          if arr_sel = 1 then
             close window w_ctn46c00
             return a_ctn46c00s[01].lclltt,
             a_ctn46c00s[01].lcllgt,
             a_ctn46c00s[01].ufdcod,
             a_ctn46c00s[01].cidnom
          end if
       end if

    end if

 end while

 let int_flag = false
 close window  w_ctn46c00
 ##Priscila 12/12/05 - correcao queda da tela - quando executamos o caminho
 ## Con_ct24h/Prestador/Mapa e usuario tecla ctrl+c nao esta
 ## retornando parametros
 if param.tipo = 1 then
    return a_ctn46c00s[01].lclltt,
           a_ctn46c00s[01].lcllgt,
           a_ctn46c00s[01].ufdcod,
           a_ctn46c00s[01].cidnom
 end if

end function   ###  ctn46c00
