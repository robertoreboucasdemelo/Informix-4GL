###############################################################################
# Nome do Modulo: ctc25m02                                           Marcus   #
#                                                                             #
# Consulta dos procedimentos de tela  cadastrados                    Abr/2002 #
###############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc25m02()
#------------------------------------------------------------

 define d_ctc25m02    record
    viginc1           date,
    viginchor1        datetime hour to minute,
    viginchordat      like datktelprc.viginchordat,
    telprccod1        like datktelprc.telprccod
 end record

 define a_datktelprc  array[1000] of record
    viginchordat      like datktelprc.viginchordat,
    vigfnlhordat      like datktelprc.vigfnlhordat,
    telcod            like datktelprc.telcod,
    telprccod         like datktelprc.telprccod,
    prcsitcod         like datktelprc.prcsitcod
 end record

 define a_ctc25m02    array[1000] of record
    telprccod         like datktelprc.telprccod,
    telnom            like datktel.telnom,
    teldsc            like datktel.teldsc,
    viginc            date,
    viginchor         datetime hour to minute,
    vigfnl            date,
    vigfnlhor         datetime hour to minute,
    prcsitcod         like datktelprc.prcsitcod
 end record

 define ws            record
    prcsitcod         like datktelprc.prcsitcod,
    confirma          char(01),
    comando           char(400),
    acao              char(1),
    data1             char(20),
    data2             char(20),
    count             integer,
    horaatu           char(05)
 end record

 define ws_tmp        record
    viginc            date,
    viginchor         datetime hour to minute,
    vigfnl            date,
    vigfnlhor         datetime hour to minute,
    prcsitcod         like datktelprc.prcsitcod
 end record

 define arr_aux integer
 define scr_aux integer


 initialize ws.*  to null

 open window w_ctc25m02 at 6,2 with form "ctc25m02"
             attribute (form line 1)

 options insert key F40
 let int_flag = false


 while not int_flag

   initialize d_ctc25m02.*  to null
   clear form

   input by name d_ctc25m02.viginc1,
                 d_ctc25m02.viginchor1,
                 d_ctc25m02.telprccod1  without defaults

     before field viginc1
        display by name d_ctc25m02.viginc1 attribute (reverse)

     after  field viginc1
        display by name d_ctc25m02.viginc1

        if d_ctc25m02.viginc1 is null then
           next field telprccod1
        end if

     before field viginchor1
        display by name d_ctc25m02.viginchor1 attribute (reverse)

        after  field viginchor1
        display by name d_ctc25m02.viginchor1

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           initialize d_ctc25m02.viginchor1  to null
           display by name d_ctc25m02.viginchor1
           next field viginc1
        end if

        if d_ctc25m02.viginchor1 is null   then
           error " Horario de inicio de vigencia deve ser informado!"
           next field viginchor1
        end if
        exit input

     before field telprccod1
        display by name d_ctc25m02.telprccod1  attribute (reverse)

     after  field telprccod1
        display by name d_ctc25m02.telprccod1

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           initialize d_ctc25m02.telprccod1  to null
           display by name d_ctc25m02.telprccod1
           next field viginc1
        end if

        if d_ctc25m02.telprccod1 is null then
           error " Numero do procedimento deve ser informado!"
           next field telprccod1
        end if

        on key (interrupt)
           exit input

   end input

   if int_flag then
      exit while
   end if

   #----------------------------------------------------------------------
   # Prepara as consultas - prepare
   #----------------------------------------------------------------------
   let ws.data1 = d_ctc25m02.viginc1
   let ws.data2   = ws.data1[7,10],  "-",
                   ws.data1[4,5],   "-",
                   ws.data1[1,2],   " ",
                   d_ctc25m02.viginchor1

   let d_ctc25m02.viginchordat  = ws.data2

   if d_ctc25m02.telprccod1 is not null then
      let ws.comando = " select viginchordat, ",
                       "        vigfnlhordat, ",
                       "        telcod, ",
                       "        telprccod,    ",
                       "        prcsitcod     ",
                       "from datktelprc       ",
                        " where telprccod = ",d_ctc25m02.telprccod1,
                        " order by telprccod  "
   else
      let ws.comando = " select viginchordat, ",
                       "        vigfnlhordat, ",
                       "        telcod, ",
                       "        telprccod,    ",
                       "        prcsitcod     ",
                       " from datktelprc  ",
                     " where vigfnlhordat >= ","'",d_ctc25m02.viginchordat,"'",
                     " order by telprccod  "
   end if

   prepare  sel_datktelprc from ws.comando
   declare  c_ctc25m02 cursor with hold for sel_datktelprc

   #----------------------------------------------------------------------
   # Ler registros
   #----------------------------------------------------------------------
   open c_ctc25m02

   while not int_flag

     let arr_aux = 1
     message " Aguarde, pesquisando..."  attribute(reverse)

     foreach c_ctc25m02 into a_datktelprc[arr_aux].*

        select telnom,
               teldsc
          into a_ctc25m02[arr_aux].telnom,
               a_ctc25m02[arr_aux].teldsc
          from datktel
         where telcod = a_datktelprc[arr_aux].telcod

         let a_ctc25m02[arr_aux].telprccod    =
                                             a_datktelprc[arr_aux].telprccod
         let a_ctc25m02[arr_aux].prcsitcod =
                                             a_datktelprc[arr_aux].prcsitcod

         let ws.data1 = a_datktelprc[arr_aux].viginchordat
         let ws.data2   = ws.data1[9,10], "/",
                         ws.data1[6,7],  "/",
                        ws.data1[1,4]

         let a_ctc25m02[arr_aux].viginc  = ws.data2
         let a_ctc25m02[arr_aux].viginchor = ws.data1[12,16]

         let ws.data1 = a_datktelprc[arr_aux].vigfnlhordat
         let ws.data2   = ws.data1[9,10], "/",
                         ws.data1[6,7], "/",
                         ws.data1[1,4]

         let a_ctc25m02[arr_aux].vigfnl     =  ws.data2
         let a_ctc25m02[arr_aux].vigfnlhor  =  ws.data1[12,16]

         let arr_aux = arr_aux + 1

         if arr_aux  >  1000   then
            error " Limite excedido. Pesquisa com mais de 1000 procedimentos!"
            exit foreach
         end if

     end foreach

      message ""
      if arr_aux  =  1   then
         error " Nao existem procedimentos para pesquisa solicitada!"
        exit while
      end if


      call set_count(arr_aux - 1)

      input array a_ctc25m02 without defaults from s_ctc25m02.*

         before row
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            let ws.acao = "A"
            let ws.prcsitcod = a_ctc25m02[arr_aux].prcsitcod

         before insert
            let ws.acao = "I"
            initialize a_ctc25m02[arr_aux].* to null

         before field telnom
            next field vigfnl

         before field vigfnl
            display a_ctc25m02[arr_aux].vigfnl to
                    s_ctc25m02[scr_aux].vigfnl attribute(reverse)

         after field vigfnl
            display a_ctc25m02[arr_aux].vigfnl to
                    s_ctc25m02[scr_aux].vigfnl

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field vigfnl
            end if

            if a_ctc25m02[arr_aux].vigfnl  is null   then
              error " Vigencia final deve ser informada!"
                next field vigfnl
            end if

            if a_ctc25m02[arr_aux].vigfnl < a_ctc25m02[arr_aux].viginc   then
               error " Vigencia final menor que vigencia inicial!"
               next field vigfnl
            end if

            if a_ctc25m02[arr_aux].vigfnl < today   then
               error " Vigencia final nao deve ser inferior a data atual!"
               next field vigfnl
            end if

            if fgl_lastkey() = fgl_keyval("down")   then
               next field vigfnlhor
            end if

          before field vigfnlhor
            let ws_tmp.vigfnlhor  = get_fldbuf(vigfnlhor)
            display a_ctc25m02[arr_aux].vigfnlhor to
                    s_ctc25m02[scr_aux].vigfnlhor attribute(reverse)

          after field vigfnlhor
            display a_ctc25m02[arr_aux].vigfnlhor to
                    s_ctc25m02[scr_aux].vigfnlhor

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field vigfnl
            end if

            if a_ctc25m02[arr_aux].vigfnlhor  is null   then
               error " Horario vigencia final deve ser informado!"
               next field vigfnlhor
            end if

            if a_ctc25m02[arr_aux].vigfnl = a_ctc25m02[arr_aux].viginc then
               if a_ctc25m02[arr_aux].vigfnlhor < a_ctc25m02[arr_aux].viginchor then
                  error " Horario vig. final menor que horario vig. inicial!"
                  next field vigfnlhor
               end if
            end if

            if ws_tmp.vigfnlhor <> a_ctc25m02[arr_aux].vigfnlhor then
               if a_ctc25m02[arr_aux].vigfnl = today   then
                  let ws.horaatu  =  current hour to minute
                  if a_ctc25m02[arr_aux].vigfnlhor < current hour to minute  then
                     error " Horario vig final nao deve ser menor que hora atual --> ", ws.horaatu
                     next field vigfnlhor
                  end if
               end if
            end if

            let ws.data1  =  a_ctc25m02[arr_aux].vigfnl
            let ws.data2  =  ws.data1[7,10], "-",
                             ws.data1[4,5],  "-",
                             ws.data1[1,2],  " ",
                             a_ctc25m02[arr_aux].vigfnlhor
            let a_datktelprc[arr_aux].vigfnlhordat = ws.data2

        #  let ws.count  = 0
        #  select count(*) into ws.count from datktelprc
        #  where  (telcod = a_datktelprc[arr_aux].telcod  and
        #          prtprccntdes = a_datktelprc[arr_aux].prtprccntdes) and
        #        ((vigfnlhordat between a_datktelprc[arr_aux].viginchordat and
        #                               a_datktelprc[arr_aux].vigfnlhordat) or
        #         (viginchordat between a_datktelprc[arr_aux].viginchordat and
        #                               a_datktelprc[arr_aux].vigfnlhordat))
        #
        #if ws.count > 1 then
        #   error " Esta alteracao de vigencia eh coincidente!"
        #   next field vigfnl
        #end if

         before field prcsitcod
            display a_ctc25m02[arr_aux].prcsitcod to
                    s_ctc25m02[scr_aux].prcsitcod attribute(reverse)

         after  field prcsitcod
            display a_ctc25m02[arr_aux].prcsitcod to
                    s_ctc25m02[scr_aux].prcsitcod

            if a_ctc25m02[arr_aux].prcsitcod <> "A" and
               a_ctc25m02[arr_aux].prcsitcod <> "C" and
               a_ctc25m02[arr_aux].prcsitcod <> "P" then
               error " Situacao deve ser: (A)tivo,(C)ancelado ou (P)rovisorio!"
               next field prcsitcod
            end if

            if ws.prcsitcod  =  "C"   then
               if a_ctc25m02[arr_aux].prcsitcod <> ws.prcsitcod   then
                  error " Situacao nao deve ser alterada!"
                  next field prcsitcod
               end if
            end if

            let a_datktelprc[arr_aux].prcsitcod =
                a_ctc25m02[arr_aux].prcsitcod

         on key (f8)
            call ctc21m06(1,1,a_datktelprc[arr_aux].telprccod)

         after row
            update datktelprc
               set    (prcsitcod,vigfnlhordat) =
                      (a_datktelprc[arr_aux].prcsitcod,
                       a_datktelprc[arr_aux].vigfnlhordat)
              where  telprccod    = a_datktelprc[arr_aux].telprccod

         before delete
            if a_ctc25m02[arr_aux].prcsitcod  =  "A"   then
               error " Exclusao so' c/ situacao: (P)rovisorio ou (C)ancelado!"
               exit input
            end if

            call cts08g01("A","S", "","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                 returning ws.confirma

            if ws.confirma  =  "S"   then
               let ws.acao  =  "D"
               initialize a_ctc25m02[arr_aux].* to null
               display a_ctc25m02[arr_aux].*    to s_ctc25m02[scr_aux].*

               begin work
                  delete
                    from datktelprc
                    where telprccod = a_datktelprc[arr_aux].telprccod

                  delete
                    from datkprctxt
                    where telprccod = a_datktelprc[arr_aux].telprccod
               commit work
           else
              display a_ctc25m02[arr_aux].vigfnl to
                      s_ctc25m02[scr_aux].vigfnl
              display a_ctc25m02[arr_aux].vigfnlhor to
                      s_ctc25m02[scr_aux].vigfnlhor
              display a_ctc25m02[arr_aux].prcsitcod to
                      s_ctc25m02[scr_aux].prcsitcod

              error " Exclusao cancelada!"
              exit input
            end if

           on key (accept)
              continue input

           on key (interrupt)
              let int_flag = true
              exit input

         end input

      end while

     let int_flag = false

 end while

 options insert key F1
 let int_flag = false
 close window w_ctc25m02

end function  ###--- ctc25m02
