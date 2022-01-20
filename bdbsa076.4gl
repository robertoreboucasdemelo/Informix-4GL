 ############################################################################
 # Nome do Modulo: bdbsa076                                        Marcelo  #
 #                                                                 Gilberto #
 # Carga dos mapas para o banco porto                              Out/1999 #
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
 # 28/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
 #                              OSF036870  do Porto Socorro.                 #
 #...........................................................................#

 database work

 define a_bdbsa076  array[10000] of record
    cidnom          like porto:datkmpacid.cidnom,
    ufdcod          like porto:datkmpacid.ufdcod
 end record

 define wsg         record
    cidades         integer,
    bairros         integer,
    ruas            integer,
    segmentos       integer,
    total           integer,
    transacao       integer,
    today           date,
    time            datetime hour to second
 end record

 define m_path      char(100)

 main
 
    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsa076.log"

    call startlog(m_path)
    # PSI 185035 - Final
 
    call bdbsa076()
 end main

#---------------------------------------------------------------------------
 function bdbsa076()
#---------------------------------------------------------------------------

 define d_bdbsa076  record
    lgdnum          like datmmaplgd.lgdnum,
    lgdtip          like porto:datkmpalgd.lgdtip,
    rua             like datmmaplgd.rua,
    lgdnom          like porto:datkmpalgd.lgdnom,
    lgdnomfon       char (51),
    mpalgdincnum    like porto:datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum    like porto:datkmpalgdsgm.mpalgdfnlnum,
    cidcod          like datmmaplgd.cidcod,
    bairro          like datmmaplgd.bairro,
    latitude        like datmmaplgd.latitude,
    longitude       like datmmaplgd.longitude
 end record

 define ws          record
    fromleft        like datmmaplgd.fromleft,
    toleft          like datmmaplgd.toleft,
    fromright       like datmmaplgd.fromright,
    toright         like datmmaplgd.toright,
    errcod          smallint,
    latitude        integer,
    longitude       integer,
    sqlcode         integer,
    errflg          char (01),
    lgdcmp          char (11),
    comando         char (200)
 end record

 define arr_aux     integer


 initialize ws.*          to null
 initialize d_bdbsa076.*  to null
 let wsg.total      =  0
 let wsg.cidades    =  0
 let wsg.bairros    =  0
 let wsg.ruas       =  0
 let wsg.segmentos  =  0
 let wsg.transacao  =  0
 let wsg.today      =  today

 #---------------------------------------------------------------
 # Prepara comandos SQL
 #---------------------------------------------------------------
 let ws.comando  =  "select cidnom ",
                    "  from porto:glakcid ",
                    " where porto:glakcid.ufdcod = ? ",
                    "   and porto:glakcid.cidnom = ? "
 prepare s_glakcid        from  ws.comando
 declare c_glakcid  cursor for  s_glakcid

 let ws.comando  =  "select max(mpacidcod) ",
                    "  from porto:datkmpacid "
 prepare s_datkmpacid_1        from  ws.comando
 declare c_datkmpacid_1  cursor for  s_datkmpacid_1

 let ws.comando  =  "select mpacidcod ",
                    "  from porto:datkmpacid ",
                    " where porto:datkmpacid.cidnom = ? ",
                    "   and porto:datkmpacid.ufdcod = ? "
 prepare s_datkmpacid_2        from  ws.comando
 declare c_datkmpacid_2  cursor for  s_datkmpacid_2

 let ws.comando  =  "select max(mpabrrcod) ",
                    "  from porto:datkmpabrr ",
                    " where porto:datkmpabrr.mpacidcod = ? "
 prepare s_datkmpabrr_1        from  ws.comando
 declare c_datkmpabrr_1  cursor for  s_datkmpabrr_1

 let ws.comando  =  "select max(mpalgdcod) ",
                    "  from porto:datkmpalgd "
 prepare s_datmmpalgd        from  ws.comando
 declare c_datmmpalgd  cursor for  s_datmmpalgd

 let ws.comando  =  "select mpabrrcod ",
                    "  from porto:datkmpabrr ",
                    " where brrnom = ? ",
                    "   and mpacidcod = ? "
 prepare s_datkmpabrr_2        from  ws.comando
 declare c_datkmpabrr_2  cursor for  s_datkmpabrr_2

 let ws.comando  =  "insert into porto:datkmpacid (mpacidcod,",
                                                 " cidnom,   ",
                                                 " ufdcod,   ",
                                                 " caddat)   ",
                                        " values (?,?,?,?)"
 prepare ins_datkmpacid  from  ws.comando

 let ws.comando  =  "insert into porto:datkmpabrr (mpacidcod,",
                                                 " mpabrrcod,",
                                                 " brrnom) ",
                                        " values (?,?,?)"
 prepare ins_datkmpabrr  from  ws.comando

 let ws.comando  =  "insert into porto:datkmpalgd (mpalgdcod,",
                                                 " lgdtip,   ",
                                                 " lgdnom,   ",
                                                 " mpacidcod,",
                                                 " prifoncod,",
                                                 " segfoncod,",
                                                 " terfoncod)",
                                        " values (?,?,?,?,?,?,?)"
 prepare ins_datkmpalgd  from  ws.comando

 let ws.comando  =  "insert into porto:datkmpalgdsgm (mpalgdcod,",
                                                    " mpalgdsgmseq,",
                                                    " mpalgdincnum,",
                                                    " mpalgdfnlnum,",
                                                    " mpacidcod,",
                                                    " mpabrrcod,",
                                                    " lclltt,",
                                                    " lcllgt)",
                                           " values (?,?,?,?,?,?,?,?)"
 prepare ins_datkmpalgdsgm  from  ws.comando

 let ws.comando  =  "update datmmaplgd set crgsitcod = '1' ",
                    " where lgdnum = ?"
 prepare upd_datmmaplgd  from  ws.comando


 #---------------------------------------------------------------
 # Carrega tabela de cidades (Nome deve ser igual ao guia postal)
 #---------------------------------------------------------------
 for arr_aux = 1 to 10000

   case arr_aux
     when 01  let a_bdbsa076[arr_aux].cidnom = "RIO GRANDE DA SERRA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 02  let a_bdbsa076[arr_aux].cidnom = "SANTA ISABEL"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 03  let a_bdbsa076[arr_aux].cidnom = "SANTANA DE PARNAIBA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 04  let a_bdbsa076[arr_aux].cidnom = "SAO LOURENCO DA SERRA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 05  let a_bdbsa076[arr_aux].cidnom = "SUZANO"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 06  let a_bdbsa076[arr_aux].cidnom = "TABOAO DA SERRA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 07  let a_bdbsa076[arr_aux].cidnom = "VARGEM GRANDE PAULISTA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 08  let a_bdbsa076[arr_aux].cidnom = "MAUA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 09  let a_bdbsa076[arr_aux].cidnom = "BARUERI"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 10  let a_bdbsa076[arr_aux].cidnom = "BIRITIBA-MIRIM"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 11  let a_bdbsa076[arr_aux].cidnom = "CAIEIRAS"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 12  let a_bdbsa076[arr_aux].cidnom = "CAJAMAR"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 13  let a_bdbsa076[arr_aux].cidnom = "CARAPICUIBA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 14  let a_bdbsa076[arr_aux].cidnom = "COTIA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 15  let a_bdbsa076[arr_aux].cidnom = "EMBU"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 16  let a_bdbsa076[arr_aux].cidnom = "EMBU-GUACU"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 17  let a_bdbsa076[arr_aux].cidnom = "FERRAZ DE VASCONCELOS"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 18  let a_bdbsa076[arr_aux].cidnom = "FRANCISCO MORATO"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 19  let a_bdbsa076[arr_aux].cidnom = "FRANCO DA ROCHA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 20  let a_bdbsa076[arr_aux].cidnom = "ARUJA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 21  let a_bdbsa076[arr_aux].cidnom = "GUARAREMA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 22  let a_bdbsa076[arr_aux].cidnom = "ITAPECERICA DA SERRA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 23  let a_bdbsa076[arr_aux].cidnom = "ITAPEVI"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 24  let a_bdbsa076[arr_aux].cidnom = "ITAQUAQUECETUBA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 25  let a_bdbsa076[arr_aux].cidnom = "JANDIRA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 26  let a_bdbsa076[arr_aux].cidnom = "JUQUITIBA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 27  let a_bdbsa076[arr_aux].cidnom = "MAIRIPORA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 28  let a_bdbsa076[arr_aux].cidnom = "SALESOPOLIS"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 29  let a_bdbsa076[arr_aux].cidnom = "MOGI DAS CRUZES"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 30  let a_bdbsa076[arr_aux].cidnom = "PIRAPORA DO BOM JESUS"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 31  let a_bdbsa076[arr_aux].cidnom = "POA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 32  let a_bdbsa076[arr_aux].cidnom = "RIBEIRAO PIRES"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 33  let a_bdbsa076[arr_aux].cidnom = "DIADEMA"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 34  let a_bdbsa076[arr_aux].cidnom = "OSASCO"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 35  let a_bdbsa076[arr_aux].cidnom = "SAO CAETANO DO SUL"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 36  let a_bdbsa076[arr_aux].cidnom = "GUARULHOS"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 37  let a_bdbsa076[arr_aux].cidnom = "SANTO ANDRE"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 38  let a_bdbsa076[arr_aux].cidnom = "SAO BERNARDO DO CAMPO"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 39  let a_bdbsa076[arr_aux].cidnom = "SAO PAULO"
              let a_bdbsa076[arr_aux].ufdcod = "SP"
     when 40  let a_bdbsa076[arr_aux].cidnom = "RIO DE JANEIRO"
              let a_bdbsa076[arr_aux].ufdcod = "RJ"
     when 41  let a_bdbsa076[arr_aux].cidnom = "NITEROI"
              let a_bdbsa076[arr_aux].ufdcod = "RJ"

     when 3908  let a_bdbsa076[arr_aux].cidnom = "NILOPOLIS"
                let a_bdbsa076[arr_aux].ufdcod = "RJ"
     when 3910  let a_bdbsa076[arr_aux].cidnom = "DUQUE DE CAXIAS"
                let a_bdbsa076[arr_aux].ufdcod = "RJ"
     when 3955  let a_bdbsa076[arr_aux].cidnom = "BELFORD ROXO"
                let a_bdbsa076[arr_aux].ufdcod = "RJ"
     when 3958  let a_bdbsa076[arr_aux].cidnom = "NOVA IGUACU"
                let a_bdbsa076[arr_aux].ufdcod = "RJ"
   end case

   if a_bdbsa076[arr_aux].cidnom <> "" then
      open  c_glakcid  using  a_bdbsa076[arr_aux].ufdcod,
                              a_bdbsa076[arr_aux].cidnom
      fetch c_glakcid
      if sqlca.sqlcode  =  notfound   then
          display " Cidade ",a_bdbsa076[arr_aux].cidnom clipped,
                  " *** nao existe no guia postal ***"
         # exit program(1)
      end if
      close c_glakcid
   end if

 end for


 #---------------------------------------------------------------
 # Ler todos os logradouros do banco work
 #---------------------------------------------------------------
 set lock mode to wait
 set isolation to dirty read

 start report  rep_carga

 declare c_bdbsa076  cursor  with hold  for
    select datmmaplgd.lgdnum,
           datmmaplgd.cidcod,
           datmmaplgd.rua,
           datmmaplgd.fromleft,
           datmmaplgd.toleft,
           datmmaplgd.fromright,
           datmmaplgd.toright,
           datmmaplgd.bairro,
           datmmaplgd.latitude,
           datmmaplgd.longitude
      from datmmaplgd
     where datmmaplgd.crgsitcod  =  0        #--> Nao carregado
       and datmmaplgd.consitcod  in (1,2)    #--> OK, Com erro

 foreach c_bdbsa076  into  d_bdbsa076.lgdnum,
                           d_bdbsa076.cidcod,
                           d_bdbsa076.rua,
                           ws.fromleft,
                           ws.toleft,
                           ws.fromright,
                           ws.toright,
                           d_bdbsa076.bairro,
                           d_bdbsa076.latitude,
                           d_bdbsa076.longitude

    let wsg.total  =  wsg.total + 1

    #------------------------------------------------------------
    # Verifica codigo da cidade
    #------------------------------------------------------------
    call cts17g00_cidade(d_bdbsa076.cidcod)
         returning  ws.errflg

    if ws.errflg  =  "S"   then
       display " Cidade ", d_bdbsa076.cidcod, " *** codigo invalido! ***"
       exit program(1)
    end if

    let d_bdbsa076.rua = upshift(d_bdbsa076.rua)

    #------------------------------------------------------------
    # Gera numeracao inicial/final
    #------------------------------------------------------------
    call bdbsa076_numeracao(ws.fromleft,
                            ws.toleft,
                            ws.fromright,
                            ws.toright)
         returning  d_bdbsa076.mpalgdincnum,
                    d_bdbsa076.mpalgdfnlnum,
                    ws.lgdcmp

    #------------------------------------------------------------
    # Separa tipo do logradouro do nome do logradouro
    #------------------------------------------------------------
    call cts17g00_tprua(d_bdbsa076.rua)
         returning  ws.errcod,
                    d_bdbsa076.lgdtip,
                    d_bdbsa076.lgdnom

    let d_bdbsa076.lgdnomfon  =  d_bdbsa076.lgdnom

    if ws.lgdcmp  is not null   then
       let d_bdbsa076.rua     =  d_bdbsa076.rua     clipped, ws.lgdcmp
       let d_bdbsa076.lgdnom  =  d_bdbsa076.lgdnom  clipped, ws.lgdcmp
    end if

    #------------------------------------------------------------
    # Converte latitude/longitude para o padrao do MDT
    #------------------------------------------------------------
    let ws.latitude          =  d_bdbsa076.latitude * -1
    let d_bdbsa076.latitude  =  d_bdbsa076.latitude + ws.latitude
    let d_bdbsa076.latitude  =  d_bdbsa076.latitude * 0.6
    let d_bdbsa076.latitude  =  d_bdbsa076.latitude - ws.latitude

    let ws.longitude         =  d_bdbsa076.longitude * -1
    let d_bdbsa076.longitude =  d_bdbsa076.longitude + ws.longitude
    let d_bdbsa076.longitude =  d_bdbsa076.longitude * 0.6
    let d_bdbsa076.longitude =  d_bdbsa076.longitude - ws.longitude


    output to report rep_carga(d_bdbsa076.*)

 end foreach

 finish report rep_carga
 close c_bdbsa076

 display " "
 display "             Resumo da Carga    "
 display "         -----------------------"
 display "          Cidades.....:  ", wsg.cidades    using  "###&&&"
 display "          Bairros.....:  ", wsg.bairros    using  "###&&&"
 display "          Ruas........:  ", wsg.ruas       using  "###&&&"
 display "          Segmentos...:  ", wsg.segmentos  using  "###&&&"
 display " "
 display "          Total.......:  ", wsg.total      using  "###&&&"
 display " "

 end function  ###  bdbsa076


#---------------------------------------------------------------------------
 report rep_carga(r_bdbsa076)
#---------------------------------------------------------------------------

 define r_bdbsa076  record
    lgdnum          like datmmaplgd.lgdnum,
    lgdtip          like porto:datkmpalgd.lgdtip,
    rua             like datmmaplgd.rua,
    lgdnom          like porto:datkmpalgd.lgdnom,
    lgdnomfon       char (51),
    mpalgdincnum    like porto:datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum    like porto:datkmpalgdsgm.mpalgdfnlnum,
    cidcod          like datmmaplgd.cidcod,
    bairro          like datmmaplgd.bairro,
    latitude        like datmmaplgd.latitude,
    longitude       like datmmaplgd.longitude
 end record

 define ws          record
    mpacidcod       like porto:datkmpacid.mpacidcod,
    mpabrrcod       like porto:datkmpalgdsgm.mpabrrcod,
    mpalgdcod       like porto:datkmpalgd.mpalgdcod,
    prifoncod       like porto:datkmpalgd.prifoncod,
    segfoncod       like porto:datkmpalgd.segfoncod,
    terfoncod       like porto:datkmpalgd.terfoncod,
    mpalgdsgmseq    like porto:datkmpalgdsgm.mpalgdsgmseq,
    today           date,
    errcod          smallint
 end record

 define ws_cidcod   integer


 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 order by  r_bdbsa076.cidcod,
           r_bdbsa076.rua,
           r_bdbsa076.mpalgdincnum


 format

    before group of r_bdbsa076.cidcod
         initialize ws.mpacidcod  to null
         let ws_cidcod  =  r_bdbsa076.cidcod

         open  c_datkmpacid_2  using  a_bdbsa076[ws_cidcod].cidnom,
                                      a_bdbsa076[ws_cidcod].ufdcod
         fetch c_datkmpacid_2  into   ws.mpacidcod
         close c_datkmpacid_2

         #---------------------------------------------------------
         # Grava cidade se nao cadastrada
         #---------------------------------------------------------
         if ws.mpacidcod  is null   then

            open  c_datkmpacid_1
            fetch c_datkmpacid_1  into  ws.mpacidcod
            close c_datkmpacid_1

            if ws.mpacidcod  is null   then
               let ws.mpacidcod  =  0
            end if
            let ws.mpacidcod  =  ws.mpacidcod + 1

            whenever error continue
               let wsg.cidades  =  wsg.cidades + 1

               execute ins_datkmpacid using  ws.mpacidcod,
                                             a_bdbsa076[ws_cidcod].cidnom,
                                             a_bdbsa076[ws_cidcod].ufdcod,
                                             wsg.today
               if sqlca.sqlcode  <>  0   then
                  display "Erro (",sqlca.sqlcode,") inclusao tabela DATKMPACID!"
                  rollback work
                  exit program (1)
               end if
            whenever error stop
         end if

    before group of r_bdbsa076.rua
         let ws.mpalgdsgmseq  =  0

         open  c_datmmpalgd
         fetch c_datmmpalgd  into  ws.mpalgdcod
         close c_datmmpalgd

         if ws.mpalgdcod  is null   then
            let ws.mpalgdcod  =  0
         end if
         let ws.mpalgdcod  =  ws.mpalgdcod + 1

         #------------------------------------------------------------
         # Gera codigos foneticos para o nome do logradouro
         #------------------------------------------------------------
         call bdbsa076_fonetico(ws.mpalgdcod,
                                r_bdbsa076.lgdnomfon)
              returning  ws.prifoncod,
                         ws.segfoncod,
                         ws.terfoncod

         #------------------------------------------------------------
         # Inicio da transacao
         #------------------------------------------------------------
         if wsg.transacao  =  0   then
            begin work
         end if

         whenever error continue
            let wsg.ruas  =  wsg.ruas + 1

            execute ins_datkmpalgd using  ws.mpalgdcod,
                                          r_bdbsa076.lgdtip,
                                          r_bdbsa076.lgdnom,
                                          ws.mpacidcod,
                                          ws.prifoncod,
                                          ws.segfoncod,
                                          ws.terfoncod
            if sqlca.sqlcode  <>  0   then
               display "Erro (",sqlca.sqlcode,") inclusao tabela DATKMPALGD!"
               rollback work
               exit program (1)
            end if
         whenever error stop

    after group of r_bdbsa076.rua
         #------------------------------------------------------------
         # Final da transacao
         #------------------------------------------------------------
         if wsg.transacao  >  3000   then
            let wsg.time  =  current
            display " Fechou transacao as ", wsg.time, "  ", wsg.segmentos
            commit work
            let wsg.transacao  =  0
         end if

    on every row
         if r_bdbsa076.bairro  is not null   then

            initialize ws.mpabrrcod  to null

            open  c_datkmpabrr_2  using  r_bdbsa076.bairro,
                                         ws.mpacidcod
            fetch c_datkmpabrr_2  into   ws.mpabrrcod
            close c_datkmpabrr_2

            #---------------------------------------------------------
            # Grava bairro se nao cadastrado
            #---------------------------------------------------------
            if ws.mpabrrcod  is null   then

               open  c_datkmpabrr_1 using  ws.mpacidcod
               fetch c_datkmpabrr_1 into   ws.mpabrrcod
               close c_datkmpabrr_1

               if ws.mpabrrcod  is null   then
                  let ws.mpabrrcod  =  0
               end if
               let ws.mpabrrcod  =  ws.mpabrrcod + 1

               whenever error continue
                  let wsg.bairros  =  wsg.bairros + 1

                  execute ins_datkmpabrr using  ws.mpacidcod,
                                                ws.mpabrrcod,
                                                r_bdbsa076.bairro
                  if sqlca.sqlcode  <>  0   then
                     display "Erro (",sqlca.sqlcode,") inclusao tabela DATKMPALGDSGM!"
                     rollback work
                     exit program (1)
                  end if
               whenever error stop
            end if
         else
            initialize ws.mpabrrcod  to null
         end if

         #------------------------------------------------------------
         # Grava segmento (trecho) da rua
         #------------------------------------------------------------
         let wsg.transacao    =  wsg.transacao + 1
         let ws.mpalgdsgmseq  =  ws.mpalgdsgmseq + 1

         whenever error continue
            let wsg.segmentos  =  wsg.segmentos + 1

            execute ins_datkmpalgdsgm using  ws.mpalgdcod,
                                             ws.mpalgdsgmseq,
                                             r_bdbsa076.mpalgdincnum,
                                             r_bdbsa076.mpalgdfnlnum,
                                             ws.mpacidcod,
                                             ws.mpabrrcod,
                                             r_bdbsa076.latitude,
                                             r_bdbsa076.longitude
            if sqlca.sqlcode  <>  0   then
               display "Erro (",sqlca.sqlcode,") inclusao tabela DATKMPALGDSGM!"
               rollback work
               exit program (1)
            end if
         whenever error stop

         #------------------------------------------------------------
         # Marca registro como ja' carregado
         #------------------------------------------------------------
         whenever error continue
            execute upd_datmmaplgd using  r_bdbsa076.lgdnum

            if sqlca.sqlcode  <>  0   then
               display "Erro (",sqlca.sqlcode,") atualizacao tabela DATMMAPLGD!"
               rollback work
               exit program (1)
            end if
         whenever error stop

    on last row
         #------------------------------------------------------------
         # Fecha a ultima transacao
         #------------------------------------------------------------
         if wsg.transacao  >  0   then
            let wsg.time  =  current
            display " Fechou transacao as ", wsg.time, "  ", wsg.segmentos
            commit work
         end if

 end report    ###  rep_carga


#---------------------------------------------------------------------------
 function bdbsa076_numeracao(param)
#---------------------------------------------------------------------------

 define param       record
    fromleft        like datmmaplgd.fromleft,
    toleft          like datmmaplgd.toleft,
    fromright       like datmmaplgd.fromright,
    toright         like datmmaplgd.toright
 end record

 define ws          record
    mpalgdincnum    like porto:datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum    like porto:datkmpalgdsgm.mpalgdfnlnum,
    lgdcmp          char (11),
    errcod          smallint
 end record


 initialize ws.*    to null
 let ws.errcod   =  0

 #------------------------------------------------------------
 # Numeracao nao informada
 #------------------------------------------------------------
 if param.fromleft   is null   and
    param.toleft     is null   and
    param.fromright  is null   and
    param.toright    is null   then
    return ws.mpalgdincnum, ws.mpalgdfnlnum, ws.lgdcmp
 end if

 if param.fromleft   =  0   and
    param.toleft     =  0   and
    param.fromright  =  0   and
    param.toright    =  0   then
    return ws.mpalgdincnum, ws.mpalgdfnlnum, ws.lgdcmp
 end if

 #------------------------------------------------------------
 # Quando logradouro possuir duas pistas (Ex. Marginal Tiete)
 #------------------------------------------------------------
 if ((param.fromleft  =  0    or
      param.fromleft  is null)    and
     (param.toleft    =  0    or
      param.toleft    is null))   then

    if param.fromright  >  0   or
       param.toright    >  0   then
       let ws.mpalgdincnum  =  param.fromright
       let ws.mpalgdfnlnum  =  param.toright
       let ws.lgdcmp        =  " - LD PAR"
       return ws.mpalgdincnum, ws.mpalgdfnlnum, ws.lgdcmp
    end if
 end if

 if ((param.fromright  =  0    or
      param.fromright  is null)    and
     (param.toright    =  0    or
      param.toright    is null))   then

    if param.fromleft  >  0   or
       param.toleft    >  0   then
       let ws.mpalgdincnum  =  param.fromleft
       let ws.mpalgdfnlnum  =  param.toleft
       let ws.lgdcmp        =  " - LD IMPAR"
       return ws.mpalgdincnum, ws.mpalgdfnlnum, ws.lgdcmp
    end if
 end if

 #------------------------------------------------------------
 # Numeracao regular
 #------------------------------------------------------------
 if param.fromleft  <  param.fromright   then
    let ws.mpalgdincnum  =  param.fromleft
 else
    let ws.mpalgdincnum  =  param.fromright
 end if

 if param.toleft  >  param.toright   then
    let ws.mpalgdfnlnum  =  param.toleft
 else
    let ws.mpalgdfnlnum  =  param.toright
 end if

 return ws.mpalgdincnum, ws.mpalgdfnlnum, ws.lgdcmp

 end function  ###  bdbsa076_numeracao


#--------------------------------------------------------------------
 function bdbsa076_fonetico(param)
#--------------------------------------------------------------------

 define param        record
    mpalgdcod        like porto:datkmpalgd.mpalgdcod,
    lgdnomfon        char(51)
 end record

 define ws           record
    prifoncod        like porto:datkmpalgd.prifoncod,
    segfoncod        like porto:datkmpalgd.segfoncod,
    terfoncod        like porto:datkmpalgd.terfoncod,
    saida            char(100)
 end record


 initialize ws.*  to null

 let param.lgdnomfon = "3", param.lgdnomfon

 call fonetica2(param.lgdnomfon)
      returning ws.saida

 if ws.saida[01,03]  =  "100"   then
    let ws.saida  =  "################################################"
    display " Lograd ", param.mpalgdcod, " *** fonetico invalido! ***"
 end if

 let ws.prifoncod  =  ws.saida[01,15]
 let ws.segfoncod  =  ws.saida[17,31]
 let ws.terfoncod  =  ws.saida[33,47]

 if ws.prifoncod  is null   or
    ws.prifoncod  =  " "    then
    let ws.prifoncod  =  param.lgdnomfon[02,16]
 end if

 if ws.segfoncod  is null   or
    ws.segfoncod  =  " "    then
    let ws.segfoncod  =  ws.prifoncod
 end if

 if ws.terfoncod  is null   or
    ws.terfoncod  =  " "    then
    let ws.terfoncod  =  ws.prifoncod
 end if

 return  ws.prifoncod,
         ws.segfoncod,
         ws.terfoncod

 end function   ###  bdbsa076_fonetico
