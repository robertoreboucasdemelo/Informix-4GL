 ############################################################################
 # Nome do Modulo: bdbsa075                                        Marcelo  #
 #                                                                 Gilberto #
 # Consistencia do arquivo de mapas da MultiSpectral (Logradouro)  Abr/1999 #
 ############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 20/07/2000  PSI 111481   Marcus          Adaptar Modulo para carga RJ     #
 #                                                                           #
 #############################################################################
 #                                                                           #
 #                          * * * Alteracoes * * *                           #
 #                                                                           #
 # Data       Autor Fabrica     Origem     Alteracao                         #
 # ---------- ----------------- ---------- --------------------------------- #
 # 28/06/2004 Marcio,  Meta     PSI185035  Padronizar o processamento Batch  #
 #                              OSF036870  do Porto Socorro.                 #
 #...........................................................................#

 database work

 define a_bdbsa075   array[99] of record
    errcod           dec(2,0),
    errdes           char(50),
    errqtd           integer
 end record

 define wsg_contador integer
 define m_path    char(100)                      # Marcio Meta - PSI185035

 main
                                                 # Marcio Meta - PSI185035
    let m_path = f_path("DBS","LOG")
    
    if m_path is null then
       let m_path = "."
    end if
    
    let m_path = m_path clipped,"/bdbsa075.log"

    call startlog(m_path)
                                                 # Marcio Meta - PSI185035
    call bdbsa075()                     
    
 end main

#---------------------------------------------------------------------------
 function bdbsa075()
#---------------------------------------------------------------------------

 define d_bdbsa075  record
    lgdnum          like porto:datmmaplgd.lgdnum,
    cidcod          like porto:datmmaplgd.cidcod,
    rua             like porto:datmmaplgd.rua,
    fromleft        like porto:datmmaplgd.fromleft,
    toleft          like porto:datmmaplgd.toleft,
    fromright       like porto:datmmaplgd.fromright,
    toright         like porto:datmmaplgd.toright,
    obs             like porto:datmmaplgd.obs,
    bairro          like porto:datmmaplgd.bairro,
    latitude        like porto:datmmaplgd.latitude,
    longitude       like porto:datmmaplgd.longitude,
    errcod          dec  (2,0)
 end record

 define ws          record
    rua             like porto:datmmaplgd.rua,
    fromleft        like porto:datmmaplgd.fromleft,
    toleft          like porto:datmmaplgd.toleft,
    fromright       like porto:datmmaplgd.fromright,
    toright         like porto:datmmaplgd.toright,
    consitcod       like porto:datmmaplgd.consitcod,
    cidcod          like porto:datmmaplgd.cidcod,
    lgdtip          like porto:datkmpalgd.lgdtip,
    lgdnom          like porto:datkmpalgd.lgdnom,
    sqlcode         integer,
    tamanho         integer,
    lidos           integer,
    count           integer,
    errflg          char (01),
    comando         char (200)
 end record

 define arr_aux     integer
 define l_arq01     char(60)     
 define l_arq02     char(60)


 #---------------------------------------------------------------
 # Inicializacao das variaveis
 #---------------------------------------------------------------
 initialize ws.*          to null
 initialize a_bdbsa075    to null
 initialize d_bdbsa075.*  to null

 let ws.comando  =  "update datmmaplgd set consitcod = ? ",
                    " where lgdnum = ? "
 prepare upd_datmmaplgd  from  ws.comando

 let ws.comando  =  "delete from datmmaplgd ",
                    " where lgdnum = ? "
 prepare del_datmmaplgd  from  ws.comando

 let ws.comando  =  "select count(*) ",
                    "  from datmmaplgd ",
                    " where cidcod = ? ",
                    "   and consitcod = ? "
 prepare con_datmmaplgd       from  ws.comando
 declare c_datmmaplgd2  cursor for  con_datmmaplgd

 #---------------------------------------------------------------
 # Inicializacao da tabela de erros
 #---------------------------------------------------------------
 for arr_aux = 1 to 99

   case arr_aux
     when 01
        let a_bdbsa075[arr_aux].errdes =
            "NOME DO LOGRADOURO NAO INFORMADO"
     when 02
        let a_bdbsa075[arr_aux].errdes =
            "TIPO DO LOGRADOURO NAO IDENTIFICADO"
     when 03
        let a_bdbsa075[arr_aux].errdes =
            "NUMERACAO DO LOGRADOURO NAO INFORMADA"
     when 04
        let a_bdbsa075[arr_aux].errdes =
            "NUMERACAO INICIAL IGUAL NUMERACAO FINAL - LADO ESQ"
     when 05
        let a_bdbsa075[arr_aux].errdes =
            "NUMERACAO INICIAL IGUAL NUMERACAO FINAL - LADO DIR"
     when 06
        let a_bdbsa075[arr_aux].errdes =
            "NUMERACAO INICIAL MAIOR NUMERACAO FINAL - LADO ESQ"
     when 07
        let a_bdbsa075[arr_aux].errdes =
            "NUMERACAO INICIAL MAIOR NUMERACAO FINAL - LADO DIR"
     when 08
        let a_bdbsa075[arr_aux].errdes =
            "NUMERACAO INICIAL LADO ESQ IGUAL NUMERACAO LAD DIR"
     when 09
        let a_bdbsa075[arr_aux].errdes =
            "NUMERACAO FINAL LADO ESQ IGUAL NUMERACAO LADO DIR"
     when 10
        let a_bdbsa075[arr_aux].errdes =
            "CONTEUDO CAMPO OBS INVALIDO"
     when 11
        let a_bdbsa075[arr_aux].errdes =
            "LATITUDE NAO INFORMADA"
     when 12
        let a_bdbsa075[arr_aux].errdes =
            "LATITUDE INVALIDA MAIOR QUE 0"
     when 13
        let a_bdbsa075[arr_aux].errdes =
            "LATITUDE FORA DE FAIXA LIMITE"
     when 14
        let a_bdbsa075[arr_aux].errdes =
            "LONGITUDE NAO INFORMADA"
     when 15
        let a_bdbsa075[arr_aux].errdes =
            "LONGITUDE INVALIDA MAIOR QUE 0"
     when 16
        let a_bdbsa075[arr_aux].errdes =
            "LONGITUDE FORA DE FAIXA LIMITE"
     when 17
        let a_bdbsa075[arr_aux].errdes =
            "NUMERACAO LADO ESQUERDO NAO E IMPAR"
     when 18
        let a_bdbsa075[arr_aux].errdes =
            "NUMERACAO LADO ESQUERDO NAO E PAR"
     when 19
        let a_bdbsa075[arr_aux].errdes =
            "LOGRADOURO COM MENOS DE 2 CARACTERES"
     when 20
        let a_bdbsa075[arr_aux].errdes =
            "BAIRRO NAO INFORMADO"
     when 21
        let a_bdbsa075[arr_aux].errdes =
            "INFORMADO APENAS O TIPO DO LOGRADOURO"

     when 98
        let a_bdbsa075[arr_aux].errdes =
            "TOTAL DE REGISTROS COM ERRO"
     when 99
        let a_bdbsa075[arr_aux].errdes =
            "TOTAL DE REGISTROS LIDOS"
   end case

   let a_bdbsa075[arr_aux].errcod = arr_aux
   let a_bdbsa075[arr_aux].errqtd = 0
 end for

 #-----------------------------------------------------------------
 # Ler todos logradouros carregados no work e realiza consistencia
 #-----------------------------------------------------------------
 set lock mode to wait
 set isolation to dirty read

 let ws.lidos      =  0
 let wsg_contador  =  0 
 
 call f_path("DBS", "ARQUIVO")                                    # Marcio Meta - PSI185035
      returning m_path
      
 if m_path is null then
    let m_path = '.' 
 end if 
 
 let l_arq02 = m_path  clipped, "/maperros.arq"
 let l_arq01 = m_path  clipped, "/maptotal.arq"
 
 start report  arq_erros  to  l_arq02
 start report  arq_totais to  l_arq01

 begin work

 declare c_bdbsa075  cursor  with hold  for
    select datmmaplgd.lgdnum,
           datmmaplgd.cidcod,
           datmmaplgd.rua,
           datmmaplgd.fromleft,
           datmmaplgd.toleft,
           datmmaplgd.fromright,
           datmmaplgd.toright,
           datmmaplgd.obs,
           datmmaplgd.bairro,
           datmmaplgd.latitude,
           datmmaplgd.longitude
      from datmmaplgd
     where datmmaplgd.crgsitcod  =  0    #--> Nao carregado
       and datmmaplgd.consitcod  =  0    #--> Nao consistido

 foreach c_bdbsa075  into  d_bdbsa075.lgdnum,
                           d_bdbsa075.cidcod,
                           d_bdbsa075.rua,
                           d_bdbsa075.fromleft,
                           d_bdbsa075.toleft,
                           d_bdbsa075.fromright,
                           d_bdbsa075.toright,
                           d_bdbsa075.obs,
                           d_bdbsa075.bairro,
                           d_bdbsa075.latitude,
                           d_bdbsa075.longitude

    #------------------------------------------------------------
    # Verifica codigo da cidade
    #------------------------------------------------------------
    let ws.cidcod = d_bdbsa075.cidcod
    call cts17g00_cidade(d_bdbsa075.cidcod)
         returning  ws.errflg

    if ws.errflg  =  "S"   then
       display " Cidade ", d_bdbsa075.cidcod, " *** codigo invalido! ***"
       exit program(1)
    end if

    #------------------------------------------------------------
    # Verifica qtde de registros lidos / inicializa variaveis
    #------------------------------------------------------------
    let ws.lidos               =  ws.lidos + 1
    let d_bdbsa075.errcod      =  0
    let ws.consitcod           =  1
    let ws.errflg              =  "N"
    let a_bdbsa075[99].errqtd  =  a_bdbsa075[99].errqtd + 1

    let wsg_contador  =  wsg_contador + 1

    #------------------------------------------------------------
    # Consiste campo rua
    #------------------------------------------------------------
    let d_bdbsa075.rua  =  upshift(d_bdbsa075.rua)

    if d_bdbsa075.rua  is null   or
       d_bdbsa075.rua  =  "  "   then
       let d_bdbsa075.errcod  =  01
       let ws.errflg          =  "S"
       let d_bdbsa075.errcod  =  00

       let ws.consitcod  =  3
       call bdbsa075_situacao(d_bdbsa075.lgdnum,
                              ws.consitcod)
       continue foreach
    else

       let ws.tamanho  =  length(d_bdbsa075.rua)
       if ws.tamanho  <  2   then
          let d_bdbsa075.errcod  =  19
          let ws.errflg          =  "S"
          let d_bdbsa075.errcod  =  00

          let ws.consitcod  =  3
          call bdbsa075_situacao(d_bdbsa075.lgdnum,
                                 ws.consitcod)
          continue foreach
       else

          call cts17g00_tprua(d_bdbsa075.rua)
               returning  d_bdbsa075.errcod,
                          ws.lgdtip,
                          ws.lgdnom

          if d_bdbsa075.errcod  >  0   then
             let ws.errflg          =  "S"
             output to report arq_erros(d_bdbsa075.*)
             let d_bdbsa075.errcod  =  00

             let ws.consitcod  =  3
             call bdbsa075_situacao(d_bdbsa075.lgdnum,
                                    ws.consitcod)
             continue foreach
          else
             if ws.lgdnom  is null   or
                ws.lgdnom  =  "  "   then
                let ws.errflg          =  "S"
                let d_bdbsa075.errcod  =  21
                output to report arq_erros(d_bdbsa075.*)
                let d_bdbsa075.errcod  =  00

                let ws.consitcod  =  3
                call bdbsa075_situacao(d_bdbsa075.lgdnum,
                                       ws.consitcod)
                continue foreach
             end if
          end if
       end if
    end if

    #------------------------------------------------------------
    # Consiste campos de numeracao
    #------------------------------------------------------------

    if d_bdbsa075.cidcod  =  246  or    #--> Sao Vicente
       d_bdbsa075.cidcod  =  243  or    #--> Guaruja
       d_bdbsa075.cidcod  =  241  or    #--> Santos
       d_bdbsa075.cidcod  =  41   or    #--> Niteroi
       d_bdbsa075.cidcod  =  40   or    #--> Rio de Janeiro
       d_bdbsa075.cidcod  =  39   or    #--> Sao Paulo
       d_bdbsa075.cidcod  =  38   or    #--> Sao Bernardo do Campo
       d_bdbsa075.cidcod  =  37   or    #--> Santo Andre
       d_bdbsa075.cidcod  =  35   or    #--> Sao Caetano do Sul
       d_bdbsa075.cidcod  =  33   or    #--> Diadema
       d_bdbsa075.cidcod  =  34   or    #--> Osasco
       d_bdbsa075.cidcod  =  36   or    #--> Guarulhos
       d_bdbsa075.cidcod  =  05   or    #--> Suzano
       d_bdbsa075.cidcod  =  09   or    #--> Barueri
       d_bdbsa075.cidcod  =  06   then  #--> Taboao da Serra

       call bdbsa075_numeracao(d_bdbsa075.fromleft,
                               d_bdbsa075.toleft,
                               d_bdbsa075.fromright,
                               d_bdbsa075.toright)
            returning d_bdbsa075.errcod

       if d_bdbsa075.errcod  >  0   then
          let ws.errflg          =  "S"
          output to report arq_erros(d_bdbsa075.*)
          let d_bdbsa075.errcod  =  00
       end if

    end if

    #------------------------------------------------------------
    # Consiste campo obs
    #------------------------------------------------------------
    if d_bdbsa075.obs    is not null   and
       d_bdbsa075.obs    <> "   "      and
       d_bdbsa075.obs    <> "001"      and
       d_bdbsa075.obs    <> "002"      and
       d_bdbsa075.obs    <> "003"      and
       d_bdbsa075.obs    <> "004"      then
       let d_bdbsa075.errcod  =  10
       let ws.errflg          =  "S"
       output to report arq_erros(d_bdbsa075.*)
       let d_bdbsa075.errcod  =  00
    end if

    #------------------------------------------------------------
    # Consiste campo latitude
    #------------------------------------------------------------
    if d_bdbsa075.latitude  is null   or
       d_bdbsa075.latitude  =  0      then
       let d_bdbsa075.errcod  =  11
       let ws.errflg          =  "S"
       output to report arq_erros(d_bdbsa075.*)
       let d_bdbsa075.errcod  =  00
    else

       if d_bdbsa075.latitude    >  0   then
          let d_bdbsa075.errcod  =  12
          let ws.errflg          =  "S"
          output to report arq_erros(d_bdbsa075.*)
          let d_bdbsa075.errcod  =  00
       else

          if d_bdbsa075.latitude    <  -26.999999   or
             d_bdbsa075.latitude    >  -20.000000   then
             let d_bdbsa075.errcod  =  13
             let ws.errflg          =  "S"
             output to report arq_erros(d_bdbsa075.*)
             let d_bdbsa075.errcod  =  00
          end if
       end if
    end if

    #------------------------------------------------------------
    # Consiste campo longitude
    #------------------------------------------------------------
    if d_bdbsa075.longitude  is null   or
       d_bdbsa075.longitude  =  0      then
       let d_bdbsa075.errcod  =  14
       let ws.errflg          =  "S"
       output to report arq_erros(d_bdbsa075.*)
       let d_bdbsa075.errcod  =  00
    else

       if d_bdbsa075.longitude   >  0   then
          let d_bdbsa075.errcod  =  15
          let ws.errflg          =  "S"
          output to report arq_erros(d_bdbsa075.*)
          let d_bdbsa075.errcod  =  00
       else
          if d_bdbsa075.longitude   <  -48.999999   or
             d_bdbsa075.longitude   >  -40.999999   then
             let d_bdbsa075.errcod  =  16
             let ws.errflg          =  "S"
             output to report arq_erros(d_bdbsa075.*)
             let d_bdbsa075.errcod  =  00
          end if
       end if
    end if

    #------------------------------------------------------------
    # Consiste campo bairro
    #------------------------------------------------------------
    if d_bdbsa075.cidcod  =  41   or    #--> Niteroi
       d_bdbsa075.cidcod  =  40   or    #--> Rio de Jan
       d_bdbsa075.cidcod  =  39   or    #--> Sao Paulo
       d_bdbsa075.cidcod  =  33   or    #--> Diadema
       d_bdbsa075.cidcod  =  34   then  #--> Osasco

       if d_bdbsa075.bairro  is null   or
          d_bdbsa075.bairro  =  " "    then
          let d_bdbsa075.errcod  =  20
          let ws.errflg          =  "S"
          output to report arq_erros(d_bdbsa075.*)
          let d_bdbsa075.errcod  =  00

          let a_bdbsa075[98].errqtd = a_bdbsa075[98].errqtd + 1

          let ws.consitcod  =  3
          call bdbsa075_situacao(d_bdbsa075.lgdnum,
                                 ws.consitcod)
          continue foreach
       end if

    end if

    #------------------------------------------------------------
    # Atualiza situacao da consistencia
    #------------------------------------------------------------
    if ws.errflg  =  "S"   then
       let ws.consitcod  =  2
       let a_bdbsa075[98].errqtd = a_bdbsa075[98].errqtd + 1
    end if

    call bdbsa075_situacao(d_bdbsa075.lgdnum,
                           ws.consitcod)

 end foreach

 #------------------------------------------------------------
 # Fecha ultima transacao
 #------------------------------------------------------------
 commit work

 finish report  arq_erros
 finish report  arq_totais
 close c_bdbsa075

 #------------------------------------------------------------
 # Exibe totais
 #------------------------------------------------------------
 display "                     Lidos................ ",ws.lidos using "&&&&&&"

 let ws.consitcod  =  0
 let ws.count      =  0
 open  c_datmmaplgd2  using  ws.cidcod, ws.consitcod
 fetch c_datmmaplgd2  into   ws.count
 close c_datmmaplgd2
 display "                     Nao consistidos...... ",ws.count using "&&&&&&"

 let ws.consitcod  =  1
 let ws.count      =  0
 open  c_datmmaplgd2  using  ws.cidcod, ws.consitcod
 fetch c_datmmaplgd2  into   ws.count
 close c_datmmaplgd2
 display "                     Consistidos OK....... ",ws.count using "&&&&&&"

 let ws.consitcod  =  2
 let ws.count      =  0
 open  c_datmmaplgd2  using  ws.cidcod, ws.consitcod
 fetch c_datmmaplgd2  into   ws.count
 close c_datmmaplgd2
 display "                     Consistidos com erro. ",ws.count using "&&&&&&"

 let ws.consitcod  =  3
 let ws.count      =  0
 open  c_datmmaplgd2  using  ws.cidcod, ws.consitcod
 fetch c_datmmaplgd2  into   ws.count
 close c_datmmaplgd2
 display "                     Desprezados.......... ",ws.count using "&&&&&&"

end function  ###  bdbsa075


#---------------------------------------------------------------------------
 report arq_erros(r_bdbsa075)
#---------------------------------------------------------------------------

 define r_bdbsa075  record
    lgdnum          like porto:datmmaplgd.lgdnum,
    cidcod          like porto:datmmaplgd.cidcod,
    rua             like porto:datmmaplgd.rua,
    fromleft        like porto:datmmaplgd.fromleft,
    toleft          like porto:datmmaplgd.toleft,
    fromright       like porto:datmmaplgd.fromright,
    toright         like porto:datmmaplgd.toright,
    obs             like porto:datmmaplgd.obs,
    bairro          like porto:datmmaplgd.bairro,
    latitude        like porto:datmmaplgd.latitude,
    longitude       like porto:datmmaplgd.longitude,
    errcod          dec(2,0)
 end record

 define w_errcod      integer
 define arr_aux2      integer


 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  99

 order by  r_bdbsa075.lgdnum


 format

    on every row
         let w_errcod  =  r_bdbsa075.errcod
         let a_bdbsa075[w_errcod].errqtd = a_bdbsa075[w_errcod].errqtd + 1

         print column 001, r_bdbsa075.lgdnum,            "|",
                           r_bdbsa075.cidcod,            "|",
                           r_bdbsa075.rua,               "|",
                           r_bdbsa075.fromleft,          "|",
                           r_bdbsa075.toleft,            "|",
                           r_bdbsa075.fromright,         "|",
                           r_bdbsa075.toright,           "|",
                           r_bdbsa075.obs,               "|",
                           r_bdbsa075.bairro,            "|",
                           r_bdbsa075.latitude,          "|",
                           r_bdbsa075.longitude,         "|",
                           r_bdbsa075.errcod,            "|",
                           a_bdbsa075[w_errcod].errdes

    on last row
         #---------------------------------------------------------------
         # Gera arquivo de totais por erro
         #---------------------------------------------------------------
         for arr_aux2 = 1 to 99

             if a_bdbsa075[arr_aux2].errdes  is null   then
                continue for
             end if

             output to report arq_totais(a_bdbsa075[arr_aux2].*)

         end for

end report  ###  arq_erros


#---------------------------------------------------------------------------
 report arq_totais(r_bdbsa075)
#---------------------------------------------------------------------------

 define r_bdbsa075    record
    errcod            dec (2,0),
    errdes            char (50),
    errqtd            integer
 end record


 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  99


 format

    on every row
         if r_bdbsa075.errqtd  >  0   then
            print column 001, r_bdbsa075.errcod  using "&&",     "|",
                              r_bdbsa075.errdes,                 "|",
                              r_bdbsa075.errqtd  using "&&&&&&"
         end if

end report  ###  arq_totais


#---------------------------------------------------------------------------
 function bdbsa075_numeracao(param)
#---------------------------------------------------------------------------

 define param       record
    fromleft        like datmmaplgd.fromleft,
    toleft          like datmmaplgd.toleft,
    fromright       like datmmaplgd.fromright,
    toright         like datmmaplgd.toright
 end record

 define ws          record
    resto           integer,
    errcod          dec (2,0)
 end record


 initialize ws.*    to null
 let ws.errcod   =  0

 if param.fromleft   is null   or
    param.toleft     is null   or
    param.fromright  is null   or
    param.toright    is null   then
    let ws.errcod  =  03
    return ws.errcod
 end if

 if (param.fromleft   =  0  and
     param.toleft     =  0)      or
    (param.fromright  =  0  and
     param.toright    =  0)      then
    let ws.errcod  =  03
    return ws.errcod
 end if

 if param.fromleft  =  param.toleft   then
    let ws.errcod  =  04
    return ws.errcod
 end if

 if param.fromright  =  param.toright   then
    let ws.errcod  =  05
    return ws.errcod
 end if

 if param.fromleft  >  param.toleft   then
    let ws.errcod  =  06
    return ws.errcod
 end if

 if param.fromright  >  param.toright   then
    let ws.errcod  =  07
    return ws.errcod
 end if

 if param.fromleft  =  param.fromright  or
    param.fromleft  =  param.toright    then
    let ws.errcod  =  08
    return ws.errcod
 end if

 if param.toleft  =  param.fromright  or
    param.toleft  =  param.toright    then
    let ws.errcod  =  09
    return ws.errcod
 end if

 if param.fromleft  >  0   then
    let ws.resto  =  param.fromleft mod 2
    if ws.resto  =  0   then
       let ws.errcod  =  17
       return ws.errcod
    end if
 end if

 if param.toleft  >  0   then
    let ws.resto  =  param.toleft mod 2
    if ws.resto  =  0   then
       let ws.errcod  =  17
       return ws.errcod
    end if
 end if

 if param.fromright  >  0   then
    let ws.resto  =  param.fromright mod 2
    if ws.resto  >  0   then
       let ws.errcod  =  18
       return ws.errcod
    end if
 end if

 if param.toright  >  0   then
    let ws.resto  =  param.toright mod 2
    if ws.resto  >  0   then
       let ws.errcod  =  18
       return ws.errcod
    end if
 end if

 return ws.errcod

end function  ###  bdbsa075_numeracao


#---------------------------------------------------------------------------
 function bdbsa075_situacao(param)
#---------------------------------------------------------------------------

 define param       record
    lgdnum          like datmmaplgd.lgdnum,
    consitcod       like datmmaplgd.consitcod
 end record


 #------------------------------------------------------------
 # Conteudo campo consitcod: (0)Nao consistido,
 #                           (1)Consistido OK,
 #                           (2)Consistido com erro,
 #                           (3)Desprezados
 #------------------------------------------------------------
 execute upd_datmmaplgd  using  param.consitcod,
                                param.lgdnum
 if sqlca.sqlcode  <>  0   then
    display "Erro (",sqlca.sqlcode,") atualizacao da tabela DATMMAPLGD!"
    rollback work
    exit program (1)
 end if

 if wsg_contador  =  500   then
    commit work
    let wsg_contador  =  0
    begin work
 end if

end function  ###  bdbsa075_situacao


