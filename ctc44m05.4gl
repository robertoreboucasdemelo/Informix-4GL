 ############################################################################
 # Nome do Modulo: ctc44m05                                        Gilberto #
 #                                                                  Marcelo #
 # Pesquisa cadastro de socorristas                                Jul/1999 #
 ############################################################################
 # Alteracoes:                                                              #
 #                                                                          #
 #     DATA    SOLICITACAO  RESPONSAVEL     DESCRICAO                       #
 #--------------------------------------------------------------------------#
 # 18/01/2012   P12010030   Celso Yamahaki  Correcao na clausula where do   #
 #                                          Filtro de pesquisa              #
 ############################################################################

 database porto

 define m_prepare smallint

#---------------------------#
 function ctc44m05_prepare()
#---------------------------#

 define l_sql char(2000)

     let l_sql = "select cpodes ",
                  " from iddkdominio ",
                 " where cponom = ? ",
                   " and cpocod = ? "

     prepare p_ctc44m0502 from l_sql
     declare c_ctc44m0502  cursor for p_ctc44m0502

     let l_sql = "select nomgrr ",
                  " from dpaksocor ",
                 " where pstcoddig = ? "

     prepare p_ctc44m0503 from l_sql
     declare c_ctc44m0503  cursor for p_ctc44m0503

     let l_sql = "select asitipdes ",
                  " from datkasitip ",
                 " where asitipcod = ? "

     prepare p_ctc44m0504 from l_sql
     declare c_ctc44m0504  cursor for p_ctc44m0504

     let l_sql = "select socntzdes ",
                  " from datksocntz ",
                 " where socntzcod = ? "

     prepare p_ctc44m0505 from l_sql
     declare c_ctc44m0505  cursor for p_ctc44m0505

     let l_sql = "select pstcoddig ",
                 "  from datrsrrpst ",
                 " where srrcoddig = ? ",
                 "   and vigfnl = (select max(vigfnl)",
                 "                   from datrsrrpst ",
                 "                  where srrcoddig = ?)"

                   #" and today between viginc and vigfnl "


     prepare p_ctc44m0506 from l_sql
     declare c_ctc44m0506  cursor for p_ctc44m0506

 end function

#------------------------------------------------------------
 function ctc44m05()
#------------------------------------------------------------

 define d_ctc44m05 record
     srrnom    like datksrr.srrnom,
     srrstt    like datksrr.srrstt,
     srrsttdes char (12),
     pstcoddig like datrsrrpst.pstcoddig,
     nomgrr    like dpaksocor.nomgrr,
     asitipcod like datrsrrasi.asitipcod,
     asitipdes like datkasitip.asitipdes,
     cgccpfnum like datksrr.cgccpfnum,
     cgccpfdig like datksrr.cgccpfdig,
     socntzcod like datksocntz.socntzcod,
     socntzdes like datksocntz.socntzdes
 end record

 define a_ctc44m05 array[2000] of record
     srrcoddig    like datksrr.srrcoddig,
     srrnomarr    like datksrr.srrnom,
     srrsttdesarr char (12),
     pstcoddigarr like dpaksocor.pstcoddig,
     nomgrrarr    like dpaksocor.nomgrr
 end record

 define ws record
     pestip    like dpaksocor.pestip,
     srrstt    like datksrr.srrstt,
     total     char (12),
     comando   char (600),
     seleciona char (01)
 end record

 define l_cgccpfnum   like dpaksocor.cgccpfnum,
        l_cgcord      like dpaksocor.cgcord,
        l_cgccpfdig   like dpaksocor.cgccpfdig,
        l_clscod      like rsdmclaus.clscod,
        where_clause  char(500),
        l_aux         char(20),
        arr_aux       smallint,
        l_flgntz      smallint,
        l_flgpst      smallint,
        l_flgasi      smallint,
        l_flgwhere    smallint #P12010030

 call ctc44m05_prepare()

 open window w_ctc44m05 at  06,02 with form "ctc44m05"
             attribute(form line first)

 # WHILE PRINCIPAL - PERMANECER NA CONSULTA
 while true

    clear form
    let int_flag  =  false
    let arr_aux   =  1
    initialize d_ctc44m05  to null
    initialize a_ctc44m05  to null
    initialize ws.*        to null

    while true

        construct by name where_clause on datksrr.srrnom,
                                          datksrr.srrstt,
                                          datrsrrpst.pstcoddig,
                                          datrsrrasi.asitipcod,
                                          datksrr.cgccpfnum,
                                          datksrr.cgccpfdig,
                                          dbsrntzpstesp.socntzcod

            after field srrnom

                  let d_ctc44m05.srrnom = GET_FLDBUF(srrnom)

                  if  d_ctc44m05.srrnom is not null then
                      exit construct
                  end if

            after field srrstt

                  let d_ctc44m05.srrstt = GET_FLDBUF(srrstt)

                  if d_ctc44m05.srrstt is not null then

                      let l_aux = "srrstt"
                      open c_ctc44m0502 using l_aux,
                                              d_ctc44m05.srrstt
                      fetch c_ctc44m0502 into d_ctc44m05.srrsttdes


                      if  sqlca.sqlcode = notfound then
                          error 'Situacao nao cadastrada.'

                          call ctn36c00("Situacao do socorrista", "srrstt")
                               returning d_ctc44m05.srrstt

                          display d_ctc44m05.srrstt to srrstt
                          next field srrstt
                      end if
                  else
                      initialize d_ctc44m05.srrsttdes  to null
                      initialize d_ctc44m05.srrstt to null
                  end if

                  display d_ctc44m05.srrstt to srrstt
                  display d_ctc44m05.srrsttdes to srrsttdes

            before field pstcoddig

                  let l_flgpst = false
            
            after field pstcoddig

                  let d_ctc44m05.pstcoddig = GET_FLDBUF(pstcoddig)

                  if d_ctc44m05.pstcoddig  is not null   then

                     open c_ctc44m0503 using d_ctc44m05.pstcoddig
                     fetch c_ctc44m0503 into d_ctc44m05.nomgrr

                     if sqlca.sqlcode  <>  0   then
                        error " Prestador nao cadastrado!"
                        call ctb12m02("")  returning  d_ctc44m05.pstcoddig,
                                                      ws.pestip,
                                                      l_cgccpfnum,
                                                      l_cgcord,
                                                      l_cgccpfdig
                        display by name d_ctc44m05.pstcoddig
                        next field pstcoddig
                     end if
                     let l_flgpst = true
                  else
                     initialize d_ctc44m05.nomgrr   to null
                  end if

                  display by name d_ctc44m05.nomgrr

            before field asitipcod

                  let l_flgasi = false
            
            after field asitipcod

                  let d_ctc44m05.asitipcod = GET_FLDBUF(asitipcod)

                  if fgl_lastkey() = fgl_keyval("up")   or
                     fgl_lastkey() = fgl_keyval("left") then
                     next field pstcoddig
                  end if
                  
                  if d_ctc44m05.asitipcod  is not null   then

                     open c_ctc44m0504 using d_ctc44m05.asitipcod
                     fetch c_ctc44m0504 into d_ctc44m05.asitipdes

                     if sqlca.sqlcode  <>  0   then
                        error " Tipo de assistencia nao cadastrada!"
                        call ctn25c00("")  returning  d_ctc44m05.asitipcod
                        display by name d_ctc44m05.asitipcod
                        next field asitipcod
                     end if
                     let l_flgasi = true
                  end if

                  display by name d_ctc44m05.asitipcod
                  display by name d_ctc44m05.asitipdes

            after field cgccpfnum


                  let d_ctc44m05.cgccpfnum = GET_FLDBUF(cgccpfnum)

                  if  d_ctc44m05.cgccpfnum is null then

                      let d_ctc44m05.cgccpfnum = ""
                      let d_ctc44m05.cgccpfdig = ""
                      display d_ctc44m05.cgccpfnum to cgccpfnum
                      display d_ctc44m05.cgccpfdig to cgccpfdig

                      if fgl_lastkey() = fgl_keyval("up")   or
                         fgl_lastkey() = fgl_keyval("left") then
                         next field asitipcod
                      else
                         next field socntzcod
                      end if
                  else                      
                      next field cgccpfdig
                  end if

            after field cgccpfdig

                  let d_ctc44m05.cgccpfdig = GET_FLDBUF(cgccpfdig)

                  if  d_ctc44m05.cgccpfdig is null then
                      if  d_ctc44m05.cgccpfnum is not null then
                          error "O digito verificador deve ser informado."
                          next field cgccpfnum
                      end if
                  else
                      exit construct
                  end if

                  if int_flag   then
                     exit while
                  end if

            before field socntzcod

                  let l_flgntz = false

            after field socntzcod

                  let d_ctc44m05.socntzcod = GET_FLDBUF(socntzcod)

                  display "d_ctc44m05.socntzcod: ",d_ctc44m05.socntzcod
                  if d_ctc44m05.socntzcod  is not null and 
                     d_ctc44m05.socntzcod <> ' '   then
                     display "Coloquei a natureza"
                     open c_ctc44m0505 using d_ctc44m05.socntzcod
                     fetch c_ctc44m0505 into d_ctc44m05.socntzdes

                     if sqlca.sqlcode  <>  0   then
                        error " Prestador nao cadastrado!"
                        call cts12g00("1","","","","","","","")  returning  d_ctc44m05.socntzcod,
                                                      l_clscod
                        display by name d_ctc44m05.socntzcod
                        next field socntzcod
                     end if

                     let l_flgntz = true
                  else
                     initialize d_ctc44m05.socntzcod   to null
                     initialize d_ctc44m05.socntzdes   to null
                     let l_flgntz = false
                  end if

                  display d_ctc44m05.socntzdes to socntzdes
                  display d_ctc44m05.socntzcod to socntzcod

                  if fgl_lastkey() = fgl_keyval("up")   or
                     fgl_lastkey() = fgl_keyval("left") then
                     next field cgccpfnum
                  end if


        end construct

        if  where_clause = " 1=1" then
            error "Para pequisa um dos campos deve ser informado"
            continue while
        else
            exit while
        end if

    end while

    if int_flag   then
       exit while
    end if

    let ws.comando  = " select distinct datksrr.srrcoddig,",
                             " datksrr.srrnom,",
                             " datksrr.srrstt ",
                        " from datksrr " #, datrsrrpst, datrsrrasi "

    
    
    if  l_flgasi then
        let ws.comando  = ws.comando  clipped," , datrsrrasi, datrsrrpst "
    else
        if  l_flgpst then
            let ws.comando  = ws.comando  clipped," , datrsrrpst "
        end if
    end if
    #P12010030  Inicio
    let l_flgwhere = false
    if  l_flgntz and not l_flgpst then
        let ws.comando  = ws.comando  clipped," , datrsrrpst "
        let l_flgwhere = true
    end if
    #P12010030  Fim
    
    display "l_flgntz: ",l_flgntz
    if  l_flgntz then
        display "Estou no outer"
        let ws.comando  = ws.comando  clipped," , outer dbsrntzpstesp "
    end if

    let ws.comando  = ws.comando  clipped, " where ", where_clause clipped
                                             #," and datksrr.srrcoddig       = datrsrrpst.srrcoddig "
                                             #," and datrsrrasi.srrcoddig    = datrsrrpst.srrcoddig "

    if  l_flgpst then
        let ws.comando  = ws.comando  clipped, " and datksrr.srrcoddig       = datrsrrpst.srrcoddig "
    end if
    
    if  l_flgasi then
        let ws.comando  = ws.comando  clipped, " and datrsrrasi.srrcoddig    = datrsrrpst.srrcoddig "
    end if
    
    if  d_ctc44m05.pstcoddig is not null
        and d_ctc44m05.pstcoddig <> 0  then
           # let ws.comando  = ws.comando  clipped, " and today between viginc and vigfnl "
           let ws.comando = ws.comando clipped, " and vigfnl = (select max(vigfnl) from datrsrrpst a ",
                                                " where a.srrcoddig = datksrr.srrcoddig) "
    end if

    #P12010030 Inicio    
    if l_flgwhere then
       let ws.comando  = ws.comando  clipped, " and datksrr.srrcoddig = datrsrrpst.srrcoddig "
    end if
    #P12010030 Fim

    if  l_flgntz then
        let ws.comando  = ws.comando  clipped, " and dbsrntzpstesp.srrcoddig = datrsrrpst.srrcoddig "
    end if
    display 'ws.comando: ',ws.comando clipped

    message " Aguarde, pesquisando..."  attribute(reverse)

    prepare comando_aux from ws.comando
    declare c_ctc44m0501  cursor for comando_aux

    foreach  c_ctc44m0501  into  a_ctc44m05[arr_aux].srrcoddig,
                               a_ctc44m05[arr_aux].srrnomarr,
                               ws.srrstt

       #----------------------------------------------------------------
       # Verifica situacao do socorrista
       #----------------------------------------------------------------
       let l_aux = "srrstt"
       open c_ctc44m0502 using l_aux,
                               ws.srrstt
       fetch c_ctc44m0502 into a_ctc44m05[arr_aux].srrsttdesarr

       #----------------------------------------------------------------
       # Verifica vinculo com prestador (pela data atual)
       #----------------------------------------------------------------
       open c_ctc44m0506 using a_ctc44m05[arr_aux].srrcoddig, a_ctc44m05[arr_aux].srrcoddig
       fetch c_ctc44m0506 into a_ctc44m05[arr_aux].pstcoddigarr

       #----------------------------------------------------------------
       # Monta nome de guerra do prestador
       #----------------------------------------------------------------
       if a_ctc44m05[arr_aux].pstcoddigarr  is not null   then
          open c_ctc44m0503 using a_ctc44m05[arr_aux].pstcoddigarr
          fetch c_ctc44m0503 into a_ctc44m05[arr_aux].nomgrrarr
       end if

       let arr_aux = arr_aux + 1
       if arr_aux > 3000  then
          error " Limite excedido, pesquisa com mais de 3000 socorristas!"
          exit foreach
       end if

    end foreach

    if arr_aux  =  1   then
       error " Nao existem socorristas para pesquisa!"
    end if

    let l_flgntz = false 

    let ws.total = "Total: ", arr_aux - 1 using "&&&&"
    display by name ws.total  attribute (reverse)
    message " (F17)Abandona, (F8)Seleciona"

    call set_count(arr_aux-1)
    let ws.seleciona = "n"

    display array  a_ctc44m05 to s_ctc44m05.*
       on key (interrupt)
          initialize ws.total   to null
          initialize a_ctc44m05 to null
          display by name ws.total
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let ws.seleciona = "s"
          exit display
    end display

    if ws.seleciona = "s" then
       exit while
    end if

    for arr_aux = 1 to 03
       clear s_ctc44m05[arr_aux].*
    end for

    close c_ctc44m0501

 end while

 let int_flag = false
 close window  w_ctc44m05

 return a_ctc44m05[arr_aux].srrcoddig

end function  #  ctc44m05
