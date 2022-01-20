############################################################################
# Menu de Modulo: CTC15M06                                        Marcelo  #
#                                                                 Gilberto #
# Manutencao no Relacionamento Tipo de Assistencia/Motivo         Mar/1999 #
############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------------
 function ctc15m06(param)
#-------------------------------------------------------------------

 define param         record
    asitipcod         like datrmtvasitip.asitipcod
 end record

 define d_ctc15m06    record
    asitipcod         like datrmtvasitip.asitipcod   ,
    asitipdes         like datkasitip.asitipdes
 end record

 define a_ctc15m06    array[20] of record
    asimtvcod         like datkasimtv.asimtvcod     ,
    asimtvdes         like datkasimtv.asimtvdes     ,
    asimtvsit         like datrmtvasitip.asimtvsit  ,
    asimtvsitdes      char (10)                     ,
    atldat            like datrsrvetp.atldat        ,
    txt               char (03)                     ,
    atlemp            like datrsrvetp.atlemp        ,
    atlmat            like datrsrvetp.atlmat        ,
    atlnom            like isskfunc.funnom
 end record

 define ws            record
    operacao          char (01)                     ,
    confirma          smallint                      ,
    asimtvcod         like datrmtvasitip.asimtvcod  ,
    asimtvsit         like datrmtvasitip.asimtvsit
 end record

 define arr_aux       smallint
 define scr_aux       smallint

 options delete key F40

 select asitipdes
   into d_ctc15m06.asitipdes
   from datkasitip
  where asitipcod = param.asitipcod

 open window w_ctc15m06 at 06,02 with form "ctc15m06"
                        attribute(form line first, comment line last - 1)

 message " (F17)Abandona"

 let d_ctc15m06.asitipcod = param.asitipcod

 display by name d_ctc15m06.* attribute(reverse)

 declare c_ctc15m06 cursor for
    select datrmtvasitip.asimtvcod,
           datkasimtv.asimtvdes,
           datrmtvasitip.asimtvsit,
           datrmtvasitip.atldat,
           datrmtvasitip.atlemp,
           datrmtvasitip.atlmat
      from datrmtvasitip, datkasimtv
     where datrmtvasitip.asitipcod = param.asitipcod  and
           datrmtvasitip.asimtvcod = datkasimtv.asimtvcod

 let arr_aux = 1
 initialize a_ctc15m06  to null

 foreach c_ctc15m06 into a_ctc15m06[arr_aux].asimtvcod,
                         a_ctc15m06[arr_aux].asimtvdes,
                         a_ctc15m06[arr_aux].asimtvsit,
                         a_ctc15m06[arr_aux].atldat,
                         a_ctc15m06[arr_aux].atlemp,
                         a_ctc15m06[arr_aux].atlmat

    let a_ctc15m06[arr_aux].txt = "por"

    let a_ctc15m06[arr_aux].atlnom = "*** NAO CADASTRADO ***"

    select funnom
      into a_ctc15m06[arr_aux].atlnom
      from isskfunc
     where empcod = a_ctc15m06[arr_aux].atlemp  and
           funmat = a_ctc15m06[arr_aux].atlmat

    let a_ctc15m06[arr_aux].atlnom = upshift(a_ctc15m06[arr_aux].atlnom)

    if a_ctc15m06[arr_aux].asimtvsit = "A"  then
       let a_ctc15m06[arr_aux].asimtvsitdes = "ATIVO"
    else
       let a_ctc15m06[arr_aux].asimtvsitdes = "CANCELADO"
    end if

    let arr_aux = arr_aux + 1
    if arr_aux > 20   then
       error " Limite excedido. Foram encontrados mais de 20 motivos para este tipo de assistencia!"
       exit foreach
    end if
 end foreach

 call set_count(arr_aux-1)

 while true

    let int_flag = false

    input array a_ctc15m06 without defaults from s_ctc15m06.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao  = "a"
             let ws.asimtvcod = a_ctc15m06[arr_aux].asimtvcod
             let ws.asimtvsit = a_ctc15m06[arr_aux].asimtvsit
         end if

      before insert
         let ws.operacao = "i"
         initialize  a_ctc15m06[arr_aux]  to null

      before field asimtvcod
         if ws.operacao = "a"  then
            next field asimtvsit
         else
            display a_ctc15m06[arr_aux].asimtvcod to
                    s_ctc15m06[scr_aux].asimtvcod attribute (reverse)
         end if

      after field asimtvcod
         display a_ctc15m06[arr_aux].asimtvcod to
                 s_ctc15m06[scr_aux].asimtvcod

         if fgl_lastkey() = fgl_keyval("up")     or
            fgl_lastkey() = fgl_keyval("left")   then
            let ws.operacao = " "
         end if

         initialize a_ctc15m06[arr_aux].asimtvdes to null
         if a_ctc15m06[arr_aux].asimtvcod is null  then
            error " Motivo deve ser informado!"
            call ctn26c01 ("")
                 returning a_ctc15m06[arr_aux].asimtvcod
            next field asimtvcod
         else
            select asimtvdes
              into a_ctc15m06[arr_aux].asimtvdes
              from datkasimtv
             where asimtvcod = a_ctc15m06[arr_aux].asimtvcod

            if sqlca.sqlcode = notfound  then
               error " Motivo nao cadastrado!"
               next field asimtvcod
            else
               display a_ctc15m06[arr_aux].asimtvdes to
                       s_ctc15m06[scr_aux].asimtvdes
            end if
         end if

         #---------------------------------------------------------
         # Verifica existencia do motivo a ser incluido
         #---------------------------------------------------------
         if ws.operacao = "i"  then
            select asimtvcod
              from datrmtvasitip
             where asitipcod = param.asitipcod
               and asimtvcod = a_ctc15m06[arr_aux].asimtvcod

            if sqlca.sqlcode <> notfound  then
               error " Motivo ja' cadastrado para este tipo de assistencia!"
               next field asimtvcod
            end if
         end if

      before field asimtvsit
         if ws.operacao = "i"  then
            let a_ctc15m06[arr_aux].asimtvsit = "A"
         end if

         display a_ctc15m06[arr_aux].asimtvsit to
                 s_ctc15m06[scr_aux].asimtvsit attribute (reverse)

      after field asimtvsit
         display a_ctc15m06[arr_aux].asimtvsit to
                 s_ctc15m06[scr_aux].asimtvsit

         if fgl_lastkey() = fgl_keyval("up")     or
            fgl_lastkey() = fgl_keyval("left")   then
            next field asimtvcod
         end if

         if a_ctc15m06[arr_aux].asimtvsit is null  then
            error " Status do motivo para este tipo de assistencia deve ser informado!"
            next field asimtvsit
         end if

         if a_ctc15m06[arr_aux].asimtvsit = "A"  then
            let a_ctc15m06[arr_aux].asimtvsitdes = "ATIVO"
         else
            if a_ctc15m06[arr_aux].asimtvsit = "C"  then
               let a_ctc15m06[arr_aux].asimtvsitdes = "CANCELADO"
            else
               error " Status do motivo deve ser (A)tivo ou (C)ancelado!"
               next field asimtvsit
            end if
         end if

      on key (interrupt)
         exit input

      after row
         let a_ctc15m06[arr_aux].txt = "por"

         if ws.operacao = "i"  or  (ws.operacao = "a"  and
            ws.asimtvsit <> a_ctc15m06[arr_aux].asimtvsit)  then
            let a_ctc15m06[arr_aux].atlemp = g_issk.empcod
            let a_ctc15m06[arr_aux].atlmat = g_issk.funmat
            let a_ctc15m06[arr_aux].atldat = today

            select funnom
              into a_ctc15m06[arr_aux].atlnom
              from isskfunc
             where empcod = a_ctc15m06[arr_aux].atlemp  and
                   funmat = a_ctc15m06[arr_aux].atlmat

            let a_ctc15m06[arr_aux].atlnom = upshift(a_ctc15m06[arr_aux].atlnom)
         end if

         case ws.operacao
            when "i"
               insert into datrmtvasitip (asitipcod    ,
                                          asimtvcod    ,
                                          asimtvsit    ,
                                          atldat       ,
                                          atlemp       ,
                                          atlmat       )
                               values (param.asitipcod                 ,
                                       a_ctc15m06[arr_aux].asimtvcod   ,
                                       a_ctc15m06[arr_aux].asimtvsit,
                                       a_ctc15m06[arr_aux].atldat      ,
                                       a_ctc15m06[arr_aux].atlemp      ,
                                       a_ctc15m06[arr_aux].atlmat      )
            when "a"
               if ws.asimtvsit <> a_ctc15m06[arr_aux].asimtvsit  then
                  update datrmtvasitip set (asimtvsit ,
                                            atldat    ,
                                            atlemp    ,
                                            atlmat    )
                                        =  (a_ctc15m06[arr_aux].asimtvsit,
                                            a_ctc15m06[arr_aux].atldat   ,
                                            a_ctc15m06[arr_aux].atlemp   ,
                                            a_ctc15m06[arr_aux].atlmat   )
                                      where asitipcod = param.asitipcod and
                                            asimtvcod = a_ctc15m06[arr_aux].asimtvcod
                 end if
         end case

         display a_ctc15m06[arr_aux].* to s_ctc15m06[scr_aux].*
         let ws.operacao = " "

    end input

    if int_flag  then
       exit while
    end if

 end while

 let int_flag = false
 options delete key F2

 close window w_ctc15m06

end function  ###  ctc15m06
