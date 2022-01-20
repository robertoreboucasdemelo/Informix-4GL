############################################################################
# Menu de Modulo: CTC15M04                                        Marcelo  #
#                                                                 Gilberto #
# Manutencao no Relacionamento Tipo de Servico/Assistencia        Jul/1998 #
############################################################################
# 10/07/2000  PSI 10865-0  Ruiz         troca do campo atdtip p/ atdsrvorg.#
#--------------------------------------------------------------------------#
# 22/06/2001  Arnaldo      Ruiz         Grava atdtip="X" para evitar queda #
#                                       de tela.                           #
#--------------------------------------------------------------------------#
# 27/08/2001  AS Arnaldo   Raji         Aumentar limite de etapas para 30  #
#--------------------------------------------------------------------------#

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------------
 function ctc15m04(param)
#-------------------------------------------------------------------

 define param         record
    atdsrvorg         like datksrvtip.atdsrvorg
 end record

 define d_ctc15m04    record
    atdsrvorg         like datksrvtip.atdsrvorg      ,
    srvtipdes         like datksrvtip.srvtipdes
 end record

 define a_ctc15m04    array[30] of record
    atdetpcod         like datrsrvetp.atdetpcod     ,
    atdetpdes         like datketapa.atdetpdes      ,
    atdsrvetpstt      like datrsrvetp.atdsrvetpstt  ,
    atdsrvetpsttdes   char (10)                     ,
    caddat            like datrsrvetp.caddat        ,
    cademp            like datrsrvetp.cademp        ,
    cadmat            like datrsrvetp.cadmat        ,
    cadnom            like isskfunc.funnom          ,
    atldat            like datrsrvetp.atldat        ,
    atlemp            like datrsrvetp.atlemp        ,
    atlmat            like datrsrvetp.atlmat        ,
    atlnom            like isskfunc.funnom
 end record

 define ws            record
    operacao          char (01)                     ,
    confirma          smallint                      ,
    atdetpcod         like datrsrvetp.atdetpcod     ,
    atdsrvetpstt      like datrsrvetp.atdsrvetpstt
 end record

 define arr_aux       smallint
 define scr_aux       smallint

 options delete key F40

 select srvtipdes
   into d_ctc15m04.srvtipdes
   from datksrvtip
  where atdsrvorg = param.atdsrvorg

 open window w_ctc15m04 at 06,02 with form "ctc15m04"
                        attribute(form line first, comment line last - 1)

 message " (F17)Abandona"

 let d_ctc15m04.atdsrvorg = param.atdsrvorg

 display by name d_ctc15m04.* attribute(reverse)

 declare c_ctc15m04 cursor for
    select datrsrvetp.atdetpcod,
           datketapa.atdetpdes,
           datrsrvetp.atdsrvetpstt,
           datrsrvetp.caddat,
           datrsrvetp.cademp,
           datrsrvetp.cadmat,
           datrsrvetp.atldat,
           datrsrvetp.atlemp,
           datrsrvetp.atlmat
      from datrsrvetp, datketapa
     where datrsrvetp.atdsrvorg    = param.atdsrvorg     and
           datrsrvetp.atdetpcod = datketapa.atdetpcod

 let arr_aux = 1
 initialize a_ctc15m04  to null

 foreach c_ctc15m04 into a_ctc15m04[arr_aux].atdetpcod,
                         a_ctc15m04[arr_aux].atdetpdes,
                         a_ctc15m04[arr_aux].atdsrvetpstt,
                         a_ctc15m04[arr_aux].caddat,
                         a_ctc15m04[arr_aux].cademp,
                         a_ctc15m04[arr_aux].cadmat,
                         a_ctc15m04[arr_aux].atldat,
                         a_ctc15m04[arr_aux].atlemp,
                         a_ctc15m04[arr_aux].atlmat

    let a_ctc15m04[arr_aux].cadnom = "*** NAO CADASTRADO ***"

    select funnom
      into a_ctc15m04[arr_aux].cadnom
      from isskfunc
     where empcod = a_ctc15m04[arr_aux].cademp  and
           funmat = a_ctc15m04[arr_aux].cadmat

    let a_ctc15m04[arr_aux].cadnom = upshift(a_ctc15m04[arr_aux].cadnom)

    let a_ctc15m04[arr_aux].atlnom = "*** NAO CADASTRADO ***"

    select funnom
      into a_ctc15m04[arr_aux].atlnom
      from isskfunc
     where empcod = a_ctc15m04[arr_aux].atlemp  and
           funmat = a_ctc15m04[arr_aux].atlmat

    let a_ctc15m04[arr_aux].atlnom = upshift(a_ctc15m04[arr_aux].atlnom)

    if a_ctc15m04[arr_aux].atdsrvetpstt = "A"  then
       let a_ctc15m04[arr_aux].atdsrvetpsttdes = "ATIVO"
    else
       let a_ctc15m04[arr_aux].atdsrvetpsttdes = "CANCELADO"
    end if

    let arr_aux = arr_aux + 1
    if arr_aux > 30   then
       error " Limite excedido. Foram encontrados mais de 30 etapas para acompanhamento deste tipo de servico!"
       exit foreach
    end if
 end foreach

 call set_count(arr_aux-1)

 while true

    let int_flag = false

    input array a_ctc15m04 without defaults from s_ctc15m04.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao     = "a"
             let ws.atdetpcod    =  a_ctc15m04[arr_aux].atdetpcod
             let ws.atdsrvetpstt = a_ctc15m04[arr_aux].atdsrvetpstt
         end if

      before insert
         let ws.operacao = "i"
         initialize  a_ctc15m04[arr_aux]  to null

      before field atdetpcod
         if ws.operacao = "a"  then
            next field atdsrvetpstt
         else
            display a_ctc15m04[arr_aux].atdetpcod to
                    s_ctc15m04[scr_aux].atdetpcod attribute (reverse)
         end if

      after field atdetpcod
         display a_ctc15m04[arr_aux].atdetpcod to
                 s_ctc15m04[scr_aux].atdetpcod

         if fgl_lastkey() = fgl_keyval("up")     or
            fgl_lastkey() = fgl_keyval("left")   then
            let ws.operacao = " "
         end if

         initialize a_ctc15m04[arr_aux].atdetpdes to null
         if a_ctc15m04[arr_aux].atdetpcod is null  then
            error " Etapa deve ser informada!"
            call ctn26c00 ("")
                 returning a_ctc15m04[arr_aux].atdetpcod
            next field atdetpcod
         else
            select atdetpdes
              into a_ctc15m04[arr_aux].atdetpdes
              from datketapa
             where atdetpcod = a_ctc15m04[arr_aux].atdetpcod

            if sqlca.sqlcode = notfound  then
               error " Etapa nao cadastrada!"
               next field atdetpcod
            else
               display a_ctc15m04[arr_aux].atdetpdes to
                       s_ctc15m04[scr_aux].atdetpdes
            end if
         end if

         #---------------------------------------------------------
         # Verifica existencia da etapa a ser incluida
         #---------------------------------------------------------
         if ws.operacao = "i"  then
            select atdetpcod
              from datrsrvetp
             where atdsrvorg    = param.atdsrvorg
               and atdetpcod = a_ctc15m04[arr_aux].atdetpcod

            if sqlca.sqlcode <> notfound  then
               error " Etapa ja' cadastrada para este tipo de servico!"
               next field atdetpcod
            end if
         end if

      before field atdsrvetpstt
         if ws.operacao = "i"  then
            let a_ctc15m04[arr_aux].atdsrvetpstt = "A"
         end if

         display a_ctc15m04[arr_aux].atdsrvetpstt to
                 s_ctc15m04[scr_aux].atdsrvetpstt attribute (reverse)

      after field atdsrvetpstt
         display a_ctc15m04[arr_aux].atdsrvetpstt to
                 s_ctc15m04[scr_aux].atdsrvetpstt

         if fgl_lastkey() = fgl_keyval("up")     or
            fgl_lastkey() = fgl_keyval("left")   then
            next field atdetpcod
         end if

         if a_ctc15m04[arr_aux].atdsrvetpstt is null  then
            error " Status da etapa para acompanhamento deste tipo de servico deve ser informado!"
            next field atdsrvetpstt
         end if

         if a_ctc15m04[arr_aux].atdsrvetpstt = "A"  then
            let a_ctc15m04[arr_aux].atdsrvetpsttdes = "ATIVO"
         else
            if a_ctc15m04[arr_aux].atdsrvetpstt = "C"  then
               let a_ctc15m04[arr_aux].atdsrvetpsttdes = "CANCELADO"
            else
               error " Status da etapa para acompanhamento deve ser (A)tivo ou (C)ancelado!"
               next field atdsrvetpstt
            end if
         end if

      on key (interrupt)
         exit input

      after row
         if ws.operacao = "i"  then
            let a_ctc15m04[arr_aux].cademp = g_issk.empcod
            let a_ctc15m04[arr_aux].cadmat = g_issk.funmat
            let a_ctc15m04[arr_aux].caddat = today

            select funnom
              into a_ctc15m04[arr_aux].cadnom
              from isskfunc
             where empcod = a_ctc15m04[arr_aux].cademp  and
                   funmat = a_ctc15m04[arr_aux].cadmat

            let a_ctc15m04[arr_aux].cadnom = upshift(a_ctc15m04[arr_aux].cadnom)
         end if

         if ws.operacao = "i"  or  (ws.operacao = "a"  and
            ws.atdsrvetpstt <> a_ctc15m04[arr_aux].atdsrvetpstt)  then
            let a_ctc15m04[arr_aux].atlemp = g_issk.empcod
            let a_ctc15m04[arr_aux].atlmat = g_issk.funmat
            let a_ctc15m04[arr_aux].atldat = today

            select funnom
              into a_ctc15m04[arr_aux].atlnom
              from isskfunc
             where empcod = a_ctc15m04[arr_aux].atlemp  and
                   funmat = a_ctc15m04[arr_aux].atlmat

            let a_ctc15m04[arr_aux].atlnom = upshift(a_ctc15m04[arr_aux].atlnom)
         end if

         case ws.operacao
            when "i"
               insert into datrsrvetp (atdsrvorg       ,
                                       atdetpcod    ,
                                       atdsrvetpstt ,
                                       caddat       ,
                                       cademp       ,
                                       cadmat       ,
                                       atldat       ,
                                       atlemp       ,
                                       atlmat       ,
                                       atdtip       )
                               values (param.atdsrvorg                    ,
                                       a_ctc15m04[arr_aux].atdetpcod   ,
                                       a_ctc15m04[arr_aux].atdsrvetpstt,
                                       a_ctc15m04[arr_aux].caddat      ,
                                       a_ctc15m04[arr_aux].cademp      ,
                                       a_ctc15m04[arr_aux].cadmat      ,
                                       a_ctc15m04[arr_aux].atldat      ,
                                       a_ctc15m04[arr_aux].atlemp      ,
                                       a_ctc15m04[arr_aux].atlmat      ,
                                       "C" )
            when "a"
               if ws.atdsrvetpstt <> a_ctc15m04[arr_aux].atdsrvetpstt  then
                  update datrsrvetp set  (atdsrvetpstt ,
                                          atldat       ,
                                          atlemp       ,
                                          atlmat       )
                                      =  (a_ctc15m04[arr_aux].atdsrvetpstt,
                                          a_ctc15m04[arr_aux].atldat      ,
                                          a_ctc15m04[arr_aux].atlemp      ,
                                          a_ctc15m04[arr_aux].atlmat      )
                                    where atdsrvorg    = param.atdsrvorg   and
                                          atdetpcod = a_ctc15m04[arr_aux].atdetpcod
               end if
         end case

         display a_ctc15m04[arr_aux].* to s_ctc15m04[scr_aux].*
         let ws.operacao = " "

    end input

    if int_flag  then
       exit while
    end if

 end while

 let int_flag = false
 options delete key F2

 close window w_ctc15m04

end function  ###  ctc15m04
