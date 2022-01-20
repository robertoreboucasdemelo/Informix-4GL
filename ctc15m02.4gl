############################################################################
# Menu de Modulo: ctc15m02                                        Marcelo  #
#                                                                 Gilberto #
# Manutencao no Relacionamento Tipo de Servico/Assistencia        Jul/1998 #
############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 22/06/2001  Arnaldo      Ruiz         Gravar atdtip com "X" para evitar   #
#                                       queda de tela.                      #
#---------------------------------------------------------------------------#

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------------
 function ctc15m02(param)
#-------------------------------------------------------------------

 define param         record
    atdsrvorg              like datksrvtip.atdsrvorg
 end record

 define d_ctc15m02    record
    atdsrvorg         like datksrvtip.atdsrvorg,
    srvtipdes         like datksrvtip.srvtipdes
 end record

 define a_ctc15m02    array[50] of record
    asitipcod         like datkasitip.asitipcod      ,
    asitipdes         like datkasitip.asitipdes      ,
    atlemp            like datrasitipsrv.atlemp      ,
    atlmat            like datrasitipsrv.atlmat      ,
    atlnom            like isskfunc.funnom           ,
    atldat            like datrasitipsrv.atldat
 end record

 define ws            record
    operacao          char (01)                     ,
    asitipdes         like datkasitip.asitipdes     ,
    asitipcod         like datrasitipsrv.asitipcod
 end record

 define arr_aux       smallint
 define scr_aux       smallint

 select srvtipdes
   into d_ctc15m02.srvtipdes
   from datksrvtip
  where atdsrvorg = param.atdsrvorg

 open window w_ctc15m02 at 06,02 with form "ctc15m02"
                        attribute(form line first, comment line last - 1, message line last)

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

 let d_ctc15m02.atdsrvorg = param.atdsrvorg

 display by name d_ctc15m02.* attribute(reverse)

 declare c_ctc15m02 cursor for
    select datrasitipsrv.asitipcod,
           datkasitip.asitipdes   ,
           datrasitipsrv.atlemp   ,
           datrasitipsrv.atlmat   ,
           datrasitipsrv.atldat
      from datrasitipsrv, datkasitip
     where datrasitipsrv.atdsrvorg    = param.atdsrvorg     and
           datrasitipsrv.asitipcod = datkasitip.asitipcod

 let arr_aux = 1
 initialize a_ctc15m02  to null

 foreach c_ctc15m02 into a_ctc15m02[arr_aux].asitipcod,
                         a_ctc15m02[arr_aux].asitipdes,
                         a_ctc15m02[arr_aux].atlemp   ,
                         a_ctc15m02[arr_aux].atlmat   ,
                         a_ctc15m02[arr_aux].atldat

    select funnom
      into a_ctc15m02[arr_aux].atlnom
      from isskfunc
     where empcod = a_ctc15m02[arr_aux].atlemp  and
           funmat = a_ctc15m02[arr_aux].atlmat

    let arr_aux = arr_aux + 1
    if arr_aux > 50   then
       error " Limite excedido. Foram encontrados mais de 50 tipos de assistencia para este servico!"
       exit foreach
    end if
 end foreach

 call set_count(arr_aux-1)

 while true

    let int_flag = false

    input array a_ctc15m02 without defaults from s_ctc15m02.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao  = "a"
             let ws.asitipcod =  a_ctc15m02[arr_aux].asitipcod
         end if

      before insert
         let ws.operacao = "i"
         initialize a_ctc15m02[arr_aux]  to null
         display a_ctc15m02[arr_aux].asitipcod  to
                 s_ctc15m02[scr_aux].asitipcod

      before field asitipcod
         display a_ctc15m02[arr_aux].asitipcod to
                 s_ctc15m02[scr_aux].asitipcod attribute (reverse)

      after field asitipcod
         display a_ctc15m02[arr_aux].asitipcod to
                 s_ctc15m02[scr_aux].asitipcod

         if fgl_lastkey() = fgl_keyval("up")     or
            fgl_lastkey() = fgl_keyval("left")   then
            let ws.operacao = " "
         end if

         initialize a_ctc15m02[arr_aux].asitipdes to null
         if a_ctc15m02[arr_aux].asitipcod is null  then
            error " Tipo da assistencia deve ser informado!"
            call ctn25c00 ("")
                 returning a_ctc15m02[arr_aux].asitipcod
            next field asitipcod
         else
            select asitipdes
              into a_ctc15m02[arr_aux].asitipdes
              from datkasitip
             where asitipcod = a_ctc15m02[arr_aux].asitipcod

            if sqlca.sqlcode = notfound  then
               error " Tipo de assistencia nao cadastrado!"
               next field asitipcod
            else
               display a_ctc15m02[arr_aux].asitipdes to
                       s_ctc15m02[scr_aux].asitipdes
            end if
         end if

         #---------------------------------------------------------
         # Verifica existencia do tipo de assistencia a ser incluido
         #---------------------------------------------------------
         if ws.operacao = "i"  then
            select asitipcod
              from datrasitipsrv
             where atdsrvorg    = param.atdsrvorg
               and asitipcod = a_ctc15m02[arr_aux].asitipcod

            if sqlca.sqlcode <> notfound  then
               error " Tipo de assistencia ja' cadastrado para este tipo de servico!"
               next field asitipcod
            end if
         end if

         if ws.operacao = "a"  then
            if ws.asitipcod <> a_ctc15m02[arr_aux].asitipcod  then
               error " Nao e' possivel alterar codigo da assistencia!"
               next field asitipcod
            end if
         end if

      on key (interrupt)
         exit input

      before delete
         let ws.operacao = "d"
         if a_ctc15m02[arr_aux].asitipcod is null  then
            continue input
         else
            if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
               exit input
            end if

            delete from datrasitipsrv
             where atdsrvorg    = param.atdsrvorg              and
                   asitipcod = a_ctc15m02[arr_aux].asitipcod

            initialize a_ctc15m02[arr_aux].* to null
            display    a_ctc15m02[scr_aux].* to s_ctc15m02[scr_aux].*
         end if

      after row
         if ws.operacao = "i"  then
            let a_ctc15m02[arr_aux].atlemp = g_issk.empcod
            let a_ctc15m02[arr_aux].atlmat = g_issk.funmat
            let a_ctc15m02[arr_aux].atldat = today

            select funnom
              into a_ctc15m02[arr_aux].atlnom
              from isskfunc
             where empcod = a_ctc15m02[arr_aux].atlemp  and
                   funmat = a_ctc15m02[arr_aux].atlmat
         end if

         case ws.operacao
            when "i"
               insert into datrasitipsrv (atdsrvorg       ,
                                          asitipcod    ,
                                          atldat       ,
                                          atlemp       ,
                                          atlmat       ,
                                          atdtip      )
                                  values (param.atdsrvorg                 ,
                                          a_ctc15m02[arr_aux].asitipcod,
                                          a_ctc15m02[arr_aux].atldat   ,
                                          a_ctc15m02[arr_aux].atlemp   ,
                                          a_ctc15m02[arr_aux].atlmat   ,
                                          "X" )
#           when "a"
#              update datrasitipsrv set  (asitipcod    ,
#                                         atldat       ,
#                                         atlemp       ,
#                                         atlmat       )
#                                     =  (a_ctc15m02[arr_aux].asitipcod,
#                                         a_ctc15m02[arr_aux].atldat   ,
#                                         a_ctc15m02[arr_aux].atlemp   ,
#                                         a_ctc15m02[arr_aux].atlmat   )
#                                   where atdsrvorg    = param.atdsrvorg   and
#                                         asitipcod = a_ctc15m02[arr_aux].asitipcod
         end case

         display a_ctc15m02[arr_aux].* to s_ctc15m02[scr_aux].*
         let ws.operacao = " "

    end input

    if int_flag  then
       exit while
    end if

 end while

 let int_flag = false

 close window w_ctc15m02

end function  ###  ctc15m02
