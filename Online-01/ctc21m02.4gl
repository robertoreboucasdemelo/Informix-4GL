###############################################################################
# Nome do Modulo: ctc21m02                                           Almeida  #
#                                                                             #
# Consulta dos procedimentos cadastrados                             mai/1998 #
###############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep char(1)



#-------------------------------------------------------------------------------
 function ctc21m02_prepare()
#-------------------------------------------------------------------------------
define l_sql char(5000)

let l_sql = '   select empcod          '
          , '    from datrprcemp       '
          , '   where prtcpointcod = ? '
prepare p_ctc21m02_001 from l_sql
declare c_ctc21m02_001 cursor for p_ctc21m02_001

let l_sql = '   delete  datrprcemp  '
          , '   where  prtcpointcod = ? '
prepare p_ctc21m02_002 from l_sql

let l_sql = ' select empnom      '
           , '  from gabkemp     '
           , ' where empcod = ?  '
prepare p_ctc21m02_003 from l_sql
declare c_ctc21m02_003 cursor for p_ctc21m02_003


let m_prep = 'S'


end function

#-------------------------------------------------------------------------------
 function ctc21m02()
#-------------------------------------------------------------------------------

 define d_ctc21m02    record
    viginc1           date,
    viginchor1        datetime hour to minute,
    viginchordat      like datmprtprc.viginchordat,
    prtprcnum1        like datmprtprc.prtprcnum
 end record

 define a_datmprtprc  array[1000] of record
    viginchordat      like datmprtprc.viginchordat,
    vigfnlhordat      like datmprtprc.vigfnlhordat,
    prtcpointcod      like datmprtprc.prtcpointcod,
    prtprccntdes      like datmprtprc.prtprccntdes,
    prtprcnum         like datmprtprc.prtprcnum,
    prtprcexcflg      like datmprtprc.prtprcexcflg,
    prtprcsitcod      like datmprtprc.prtprcsitcod
 end record

 define a_ctc21m02    array[1000] of record
    prtprcnum         like datmprtprc.prtprcnum,
    prtcponom         like dattprt.prtcponom,
    relacional        char(02),
    prtprccntdes      like datmprtprc.prtprccntdes,
    viginc            date,
    viginchor         datetime hour to minute,
    vigfnl            date,
    vigfnlhor         datetime hour to minute,
    prtprcsitcod      like datmprtprc.prtprcsitcod
 end record

 define ws            record
    prtprcsitcod      like datmprtprc.prtprcsitcod,
    confirma          char(01),
    comando           char(400),
    acao              char(1),
    data1             char(20),
    data2             char(20),
    count             integer,
    horaatu           char(05)
 end record

 define arr_aux integer
 define scr_aux integer
 
 define l_empcod       like dbsmopg.empcod
 define l_empnom       like gabkemp.empnom

 initialize ws.*  to null

 let m_prep = 'N'

 if m_prep <> 'S' then
    call ctc21m02_prepare()
 end if
    

 open window w_ctc21m02 at 6,2 with form "ctc21m02"
             attribute (form line 1)

 options insert key F40
 let int_flag = false


 while not int_flag

   initialize d_ctc21m02.*  to null
   clear form

   input by name d_ctc21m02.viginc1,
                 d_ctc21m02.viginchor1,
                 d_ctc21m02.prtprcnum1  without defaults

     before field viginc1
        display by name d_ctc21m02.viginc1 attribute (reverse)

     after  field viginc1
        display by name d_ctc21m02.viginc1

        if d_ctc21m02.viginc1 is null then
           next field prtprcnum1
        end if

     before field viginchor1
        display by name d_ctc21m02.viginchor1 attribute (reverse)

        after  field viginchor1
        display by name d_ctc21m02.viginchor1

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           initialize d_ctc21m02.viginchor1  to null
           display by name d_ctc21m02.viginchor1
           next field viginc1
        end if

        if d_ctc21m02.viginchor1 is null   then
           error " Horario de inicio de vigencia deve ser informado!"
           next field viginchor1
        end if
        exit input

     before field prtprcnum1
        display by name d_ctc21m02.prtprcnum1  attribute (reverse)

     after  field prtprcnum1
        display by name d_ctc21m02.prtprcnum1

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           initialize d_ctc21m02.prtprcnum1  to null
           display by name d_ctc21m02.prtprcnum1
           next field viginc1
        end if

        if d_ctc21m02.prtprcnum1 is null then
           error " Numero do procedimento deve ser informado!"
           next field prtprcnum1
        end if

        on key (interrupt)
           exit input

   end input

   if int_flag then
      exit while
   end if

   #----------------------------------------------------------------------
   # Prepara comandos SQL - Leitura conforme parametro informado
   #----------------------------------------------------------------------
   let ws.data1 = d_ctc21m02.viginc1
   let ws.data2   = ws.data1[7,10],  "-",
                   ws.data1[4,5],   "-",
                   ws.data1[1,2],   " ",
                   d_ctc21m02.viginchor1

   let d_ctc21m02.viginchordat  = ws.data2

   if d_ctc21m02.prtprcnum1 is not null then
      let ws.comando = " select * from datmprtprc    ",
                        " where prtprcnum = ",d_ctc21m02.prtprcnum1,
                        " order by prtprcnum  "
   else
      let ws.comando = " select * from datmprtprc    ",
                     " where vigfnlhordat >= ","'",d_ctc21m02.viginchordat,"'",
                     " order by prtprcnum  "
   end if

   prepare  sel_datmprtprc from ws.comando
   declare  c_ctc21m02 cursor with hold for sel_datmprtprc

   #----------------------------------------------------------------------
   # Ler registros
   #----------------------------------------------------------------------
   open c_ctc21m02

   while not int_flag

     let arr_aux = 1
     message " Aguarde, pesquisando..."  attribute(reverse)

     foreach c_ctc21m02 into a_datmprtprc[arr_aux].*

        select prtcponom
          into a_ctc21m02[arr_aux].prtcponom
          from dattprt
         where prtcpointcod = a_datmprtprc[arr_aux].prtcpointcod

         if a_datmprtprc[arr_aux].prtprcexcflg = "R" then
             let a_ctc21m02[arr_aux].relacional = "="
         else
            let a_ctc21m02[arr_aux].relacional = "<>"
         end if

         let a_ctc21m02[arr_aux].prtprcnum    =
                                             a_datmprtprc[arr_aux].prtprcnum
         let a_ctc21m02[arr_aux].prtprccntdes =
                                             a_datmprtprc[arr_aux].prtprccntdes
         let a_ctc21m02[arr_aux].prtprcsitcod =
                                             a_datmprtprc[arr_aux].prtprcsitcod

         let ws.data1 = a_datmprtprc[arr_aux].viginchordat
         let ws.data2   = ws.data1[9,10], "/",
                         ws.data1[6,7],  "/",
                        ws.data1[1,4]

         let a_ctc21m02[arr_aux].viginc  = ws.data2
         let a_ctc21m02[arr_aux].viginchor = ws.data1[12,16]

         let ws.data1 = a_datmprtprc[arr_aux].vigfnlhordat
         let ws.data2   = ws.data1[9,10], "/",
                         ws.data1[6,7], "/",
                         ws.data1[1,4]

         let a_ctc21m02[arr_aux].vigfnl     =  ws.data2
         let a_ctc21m02[arr_aux].vigfnlhor  =  ws.data1[12,16]

         let arr_aux  =  arr_aux + 1

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

      input array a_ctc21m02 without defaults from s_ctc21m02.*

         before row
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            let ws.acao = "A"
            let ws.prtprcsitcod = a_ctc21m02[arr_aux].prtprcsitcod

         before insert
            let ws.acao = "I"
            initialize a_ctc21m02[arr_aux].* to null

         before field prtcponom
            next field vigfnl

         before field vigfnl
            display a_ctc21m02[arr_aux].vigfnl to
                    s_ctc21m02[scr_aux].vigfnl attribute(reverse)

         after field vigfnl
            display a_ctc21m02[arr_aux].vigfnl to
                    s_ctc21m02[scr_aux].vigfnl

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field vigfnl
            end if

            if a_ctc21m02[arr_aux].vigfnl  is null   then
              error " Vigencia final deve ser informada!"
                next field vigfnl
            end if

            if a_ctc21m02[arr_aux].vigfnl < a_ctc21m02[arr_aux].viginc   then
               error " Vigencia final menor que vigencia inicial!"
               next field vigfnl
            end if

            if a_ctc21m02[arr_aux].vigfnl < today   then
               error " Vigencia final nao deve ser inferior a data atual!"
               next field vigfnl
            end if

            if fgl_lastkey() = fgl_keyval("down")   then
               next field vigfnlhor
            end if

          before field vigfnlhor
            display a_ctc21m02[arr_aux].vigfnlhor to
                    s_ctc21m02[scr_aux].vigfnlhor attribute(reverse)

          after field vigfnlhor
            display a_ctc21m02[arr_aux].vigfnlhor to
                    s_ctc21m02[scr_aux].vigfnlhor

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field vigfnl
            end if

            if a_ctc21m02[arr_aux].vigfnlhor  is null   then
               error " Horario vigencia final deve ser informado!"
               next field vigfnlhor
            end if

            if a_ctc21m02[arr_aux].vigfnl = a_ctc21m02[arr_aux].viginc then
               if a_ctc21m02[arr_aux].vigfnlhor < a_ctc21m02[arr_aux].viginchor then
                  error " Horario vig. final menor que horario vig. inicial!"
                  next field vigfnlhor
               end if
            end if

            if a_ctc21m02[arr_aux].vigfnl = today   then
               let ws.horaatu  =  current hour to minute
               if a_ctc21m02[arr_aux].vigfnlhor < current hour to minute  then
                  error " Horario vig final nao deve ser menor que hora atual --> ", ws.horaatu
                  next field vigfnlhor
               end if
            end if

            let ws.data1  =  a_ctc21m02[arr_aux].vigfnl
            let ws.data2  =  ws.data1[7,10], "-",
                             ws.data1[4,5],  "-",
                             ws.data1[1,2],  " ",
                             a_ctc21m02[arr_aux].vigfnlhor
            let a_datmprtprc[arr_aux].vigfnlhordat = ws.data2

        #  let ws.count  = 0
        #  select count(*) into ws.count from datmprtprc
        #  where  (prtcpointcod = a_datmprtprc[arr_aux].prtcpointcod  and
        #          prtprccntdes = a_datmprtprc[arr_aux].prtprccntdes) and
        #        ((vigfnlhordat between a_datmprtprc[arr_aux].viginchordat and
        #                               a_datmprtprc[arr_aux].vigfnlhordat) or
        #         (viginchordat between a_datmprtprc[arr_aux].viginchordat and
        #                               a_datmprtprc[arr_aux].vigfnlhordat))
        #
        #if ws.count > 1 then
        #   error " Esta alteracao de vigencia eh coincidente!"
        #   next field vigfnl
        #end if

         before field prtprcsitcod
            display a_ctc21m02[arr_aux].prtprcsitcod to
                    s_ctc21m02[scr_aux].prtprcsitcod attribute(reverse)

         after  field prtprcsitcod
            display a_ctc21m02[arr_aux].prtprcsitcod to
                    s_ctc21m02[scr_aux].prtprcsitcod

            if a_ctc21m02[arr_aux].prtprcsitcod <> "A" and
               a_ctc21m02[arr_aux].prtprcsitcod <> "C" and
               a_ctc21m02[arr_aux].prtprcsitcod <> "P" then
               error " Situacao deve ser: (A)tivo,(C)ancelado ou (P)rovisorio!"
               next field prtprcsitcod
            end if

            if ws.prtprcsitcod  =  "C"   then
               if a_ctc21m02[arr_aux].prtprcsitcod <> ws.prtprcsitcod   then
                  error " Situacao nao deve ser alterada!"
                  next field prtprcsitcod
               end if
            end if

            let a_datmprtprc[arr_aux].prtprcsitcod =
                a_ctc21m02[arr_aux].prtprcsitcod

         on key (f8)
            call ctc21m05(a_datmprtprc[arr_aux].prtprcnum,
                          a_ctc21m02[arr_aux].prtcponom,
                          a_ctc21m02[arr_aux].relacional,
                          a_ctc21m02[arr_aux].prtprccntdes)

         after row
            update datmprtprc
               set    (prtprcsitcod,vigfnlhordat) =
                      (a_datmprtprc[arr_aux].prtprcsitcod,
                       a_datmprtprc[arr_aux].vigfnlhordat)
              where  prtprcnum    = a_datmprtprc[arr_aux].prtprcnum

         before delete
            if a_ctc21m02[arr_aux].prtprcsitcod  =  "A"   then
               error " Exclusao so' c/ situacao: (P)rovisorio ou (C)ancelado!"
               exit input
            end if

            call cts08g01("A","S", "","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                 returning ws.confirma

            if ws.confirma  =  "S"   then
               let ws.acao  =  "D"
               initialize a_ctc21m02[arr_aux].* to null
               display a_ctc21m02[arr_aux].*    to s_ctc21m02[scr_aux].*

               begin work
                  delete
                    from datmprtprc
                    where prtprcnum = a_datmprtprc[arr_aux].prtprcnum

                  delete
                    from datmprctxt
                    where prtprcnum = a_datmprtprc[arr_aux].prtprcnum
                  
                  # Procedimento X Empresa  
                  execute p_ctc21m02_002 using a_datmprtprc[arr_aux].prtprcnum  
               commit work
           else
              display a_ctc21m02[arr_aux].vigfnl to
                      s_ctc21m02[scr_aux].vigfnl
              display a_ctc21m02[arr_aux].vigfnlhor to
                      s_ctc21m02[scr_aux].vigfnlhor
              display a_ctc21m02[arr_aux].prtprcsitcod to
                      s_ctc21m02[scr_aux].prtprcsitcod

              error " Exclusao cancelada!"
              exit input
            end if

           on key (accept)
              continue input

           on key (interrupt)
              let int_flag = true
              exit input
 
          #------------
           on key (F1)
          #------------
           if a_datmprtprc[arr_aux].prtprcnum  is not null and
              a_datmprtprc[arr_aux].prtprcnum  >= 0 then
               call ctc21m02_mostra_empresa(a_datmprtprc[arr_aux].prtprcnum)
           end if
            
          
         end input

      end while

     let int_flag = false

 end while

 options insert key F1
 let int_flag = false
 close window w_ctc21m02

end function  ###--- ctc21m02

#-------------------------------------------------------------------------------
 function ctc21m02_mostra_empresa(l_procedimento)
#-------------------------------------------------------------------------------
define l_procedimento char(5)
define l_empcod       like gabkemp.empcod
define l_empnom       like gabkemp.empnom  
define l_index        smallint

define la_ctc21m02_emp array[100] of record
    empcod    like gabkemp.empcod  
   ,empnom    like gabkemp.empnom  
end record

  let l_procedimento = l_procedimento clipped
  let l_index = 1

  open window w_ctc21m02a at 8,10 with form 'ctc21m02a'
     attribute(border, form line 1)
 
 #carrega array de empresa
  open c_ctc21m02_001 using l_procedimento  # busca empresas 
  foreach c_ctc21m02_001 into l_empcod
      
      open c_ctc21m02_003 using l_empcod   # busca nome de cada empresa
      fetch c_ctc21m02_003 into l_empnom
      
      let la_ctc21m02_emp[l_index].empcod = l_empcod
      let la_ctc21m02_emp[l_index].empnom = l_empnom  
      
      let l_index = l_index + 1
      
  end foreach    
    
 #displays
  display l_procedimento to procedimento
  
  call set_count(l_index -1)
  display array la_ctc21m02_emp to sa_ctc21m02a.*
      on key (interrupt)
        exit display
  end display 

  close window w_ctc21m02a
  
end function

