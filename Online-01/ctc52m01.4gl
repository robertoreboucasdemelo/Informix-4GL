############################################################################
# Menu de Modulo: ctc52m01                                         GUSTAVO #
# Manutencao no cadastro de grupos                                 DEZ/2000#
############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------------
function ctc52m01(param)
#--------------------------------------------------------------------------

 define param        record
        operacao     char(01),
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpdes like datktltgrp.c24tltgrpdes,
        c24tltgrpstt like datktltgrp.c24tltgrpstt,
        descsit      char(10),
        caddat       like datktltgrp.caddat,
        cademp       like datktltgrp.cademp,
        cadmat       like datktltgrp.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltgrp.cadusrtip,
        atldat       like datktltgrp.atldat,
        atlemp       like datktltgrp.atlemp,
        atlmat       like datktltgrp.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltgrp.atlusrtip
 end record

 define a_ctc52m01  array[100] of record
        atdvclsgl   like datktltgrpitm.atdvclsgl,
        vcldes      char(58),
        pgrnum      like datktltgrpitm.pgrnum,
        ustnom      like htlrust.ustnom,
        contr       char (1)
 end record

 define ws           record
        comando      char(400),
        vclcoddig    like datkveiculo.vclcoddig,
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpseq like datktltgrpitm.c24tltgrpseq,
        atdvclsgl    like datktltgrpitm.atdvclsgl,
        pgrnum       like datktltgrpitm.pgrnum,
        ustnom       like htlrust.ustnom,
        operacao     char(01),
        count        smallint,
        confirma     char(01)
 end record

 define arr_aux     smallint
 define scr_aux     smallint
 define for_aux     smallint

 initialize a_ctc52m01 to null
 initialize ws.*      to null
 let arr_aux = 1

 let ws.comando = " select vclcoddig      ",
                  " from datkveiculo      ",
                  " where atdvclsgl  = ?  "
 prepare s_datkveiculo from ws.comando
 declare c_datkveiculo cursor for s_datkveiculo

 let ws.comando = " select ustnom         ",
                  " from htlrust          ",
                  " where pgrnum = ?      "
 prepare s_htlrust from ws.comando
 declare c_htlrust cursor for s_htlrust

 declare c_datktltgrpitm cursor for
    select atdvclsgl, pgrnum
    from datktltgrpitm
    where c24tltgrpnum = param.c24tltgrpnum

 foreach c_datktltgrpitm into a_ctc52m01[arr_aux].atdvclsgl,
                              a_ctc52m01[arr_aux].pgrnum

    if a_ctc52m01[arr_aux].atdvclsgl is not null then
       open c_datkveiculo using a_ctc52m01[arr_aux].atdvclsgl
       fetch c_datkveiculo into ws.vclcoddig
       close c_datkveiculo

       call cts15g00(ws.vclcoddig)
            returning a_ctc52m01[arr_aux].vcldes
    end if

    if a_ctc52m01[arr_aux].pgrnum is not null then
       open c_htlrust using a_ctc52m01[arr_aux].pgrnum
       fetch c_htlrust into a_ctc52m01[arr_aux].ustnom
       close c_htlrust
    end if

    let arr_aux = arr_aux + 1
    if arr_aux > 100 then
       error " Limite excedido! Grupo com mais de 100 itens!"
       exit foreach
    end if
 end foreach

 error ""
 call set_count(arr_aux - 1)

 open window w_ctc52m01 at 06,2 with form "ctc52m01"
      attribute(form line first, comment line last - 1)

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

 display param.c24tltgrpnum  to  c24tltgrpnum
 display param.c24tltgrpdes  to  c24tltgrpdes
 display param.c24tltgrpstt  to  c24tltgrpstt
 display param.descsit       to  descsit
 display param.caddat        to  caddat
 display param.cadnom        to  cadnom
 display param.atldat        to  atldat
 display param.atlnom        to  atlnom

 while true
     let int_flag = false

     input array a_ctc52m01 without defaults from s_ctc52m01.*

        before row
              let arr_aux = arr_curr()
              let scr_aux = scr_line()
              if arr_aux <= arr_count()  then
                 let ws.operacao = "a"
                 let ws.atdvclsgl = a_ctc52m01[arr_aux].atdvclsgl
                 let ws.pgrnum    = a_ctc52m01[arr_aux].pgrnum
              end if

           before insert
              let ws.operacao = "i"
              initialize a_ctc52m01[arr_aux].*  to null
              display a_ctc52m01[arr_aux].* to s_ctc52m01[scr_aux].*

           before field atdvclsgl

              display a_ctc52m01[arr_aux].atdvclsgl to
                      s_ctc52m01[scr_aux].atdvclsgl attribute (reverse)

           after field atdvclsgl

              display a_ctc52m01[arr_aux].atdvclsgl to
                      s_ctc52m01[scr_aux].atdvclsgl

              if fgl_lastkey() = fgl_keyval("up")             or
                 fgl_lastkey() = fgl_keyval("left")           then
                 let ws.operacao = " "
              end if

              if a_ctc52m01[arr_aux].atdvclsgl is not null   then
                 open c_datkveiculo using a_ctc52m01[arr_aux].atdvclsgl
                 fetch c_datkveiculo into ws.vclcoddig

                 if sqlca.sqlcode = notfound then
                    error " Codigo da sigla nao existe!"
                    next field atdvclsgl
                 end if
                 close c_datkveiculo

                 call cts15g00(ws.vclcoddig)
                      returning a_ctc52m01[arr_aux].vcldes

                 #--------------------------------------------------------------
                 #Verifica se esta sigla  ja' foi cadastrada
                 #--------------------------------------------------------------
                 if ws.operacao = "i" then
                    for for_aux = 1 to arr_aux -1
                       if a_ctc52m01[for_aux].atdvclsgl is not null and
                          a_ctc52m01[for_aux].atdvclsgl =
                          a_ctc52m01[arr_aux].atdvclsgl             then
                          error " Sigla da viatura ja' contida neste grupo!"
                          next field atdvclsgl
                       end if
                    end for
                 end if
              else
                 next field pgrnum
              end if

              if ws.operacao  =  "a"                             and
                 a_ctc52m01[arr_aux].atdvclsgl <> ws.atdvclsgl    then
                 error " Codigo da sigla nao deve ser alterado!"
                 next field atdvclsgl
              end if

              display a_ctc52m01[arr_aux].vcldes to s_ctc52m01[scr_aux].vcldes

           before field pgrnum

           if a_ctc52m01[arr_aux].atdvclsgl is null then
               display a_ctc52m01[arr_aux].pgrnum to
                       s_ctc52m01[scr_aux].pgrnum attribute (reverse)
           else
               next field contr
           end if

           after field pgrnum

           if a_ctc52m01[arr_aux].atdvclsgl is null then
              display a_ctc52m01[arr_aux].pgrnum to
                      s_ctc52m01[scr_aux].pgrnum

              if fgl_lastkey() = fgl_keyval("up")    or
                 fgl_lastkey() = fgl_keyval("left")  then
                 next field atdvclsgl
              end if

              if a_ctc52m01[arr_aux].pgrnum = 0           or
                 a_ctc52m01[arr_aux].pgrnum is null       then
                 error " Codigo do numero do teletrim deve ser informado!"
                 next field pgrnum
                 let ws.operacao = ""
              end if

              if ws.operacao  =  "a"                             and
                 a_ctc52m01[arr_aux].atdvclsgl <> ws.atdvclsgl    then
                 error " Codigo do numero do teletrim nao deve ser alterado!"
                 next field pgrnum
              end if

              open c_htlrust using a_ctc52m01[arr_aux].pgrnum
              fetch c_htlrust into a_ctc52m01[arr_aux].ustnom

              if sqlca.sqlcode <> 0   then
                 error " Numero do Teletrim nao existe!"
                 let ws.operacao = ""
                 next field pgrnum
              end if
              close c_htlrust

              display  a_ctc52m01[arr_aux].ustnom to s_ctc52m01[scr_aux].ustnom
           end if

              #--------------------------------------------------------------
              #Verifica se esta teletrim  ja' foi cadastrada
              #--------------------------------------------------------------
              if ws.operacao = "i" then
                 for for_aux = 1 to arr_aux -1
                   if a_ctc52m01[for_aux].pgrnum is not null and
                      a_ctc52m01[for_aux].pgrnum =
                      a_ctc52m01[arr_aux].pgrnum             then
                      error " Nro. Teletrim ja' contido neste grupo!"
                      initialize a_ctc52m01[arr_aux].ustnom to null
                      display a_ctc52m01[arr_aux].ustnom to s_ctc52m01[arr_aux].ustnom
                      next field pgrnum
                   end if
                 end for
              end if

              on key (interrupt)
                 exit input

              before delete
                 let ws.confirma = "N"
                 call cts08g01("A","S","","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                 returning ws.confirma

                 if ws.confirma = "N"   then
                    exit input
                 end if

                 let ws.count = 0
                 select count(*) into ws.count
                        from datktltgrpitm
                        where c24tltgrpnum = param.c24tltgrpnum
                 if ws.count = 1 then
                    error "Grupo todo deve ser removido!"
                    exit input
                 end if

                 let ws.operacao = "d"
                 if a_ctc52m01[arr_aux].atdvclsgl is null and
                    a_ctc52m01[arr_aux].pgrnum    is null then
                    continue input
                 else
                    if a_ctc52m01[arr_aux].pgrnum    is null     then
                          delete from datktltgrpitm
                                 where c24tltgrpnum = param.c24tltgrpnum
                                 and   atdvclsgl = a_ctc52m01[arr_aux].atdvclsgl

                          if sqlca.sqlcode <> 0  then
                             initialize a_ctc52m01[arr_aux].*  to null
                             error " Sigla nao excluida!"
                          else
                             initialize a_ctc52m01[arr_aux].*  to null
                             error   " Sigla excluida !"
                          end if
                    else
                       if a_ctc52m01[arr_aux].atdvclsgl is null then
                          delete from datktltgrpitm
                                 where c24tltgrpnum = param.c24tltgrpnum
                                 and   pgrnum       = a_ctc52m01[arr_aux].pgrnum
                          if sqlca.sqlcode <> 0  then
                             initialize  a_ctc52m01[arr_aux].*  to null
                             error " Pager nao excluido!"
                          else
                             initialize a_ctc52m01[arr_aux].*  to null
                             error   " Pager excluido !"
                          end if
                       end if
                    end if
                    initialize a_ctc52m01[arr_aux].*  to null
                    display a_ctc52m01[arr_aux].* to s_ctc52m01[scr_aux].*
                 end if

            after row

                 case ws.operacao
                      when "i"
                        if param.operacao = "i"   then  #--> qdo inclusao de grupo
                            initialize param.operacao   to null
                            call grupo_ctc52m01(param.*)  returning param.c24tltgrpnum
                            if param.c24tltgrpnum is null   then
                               exit input
                            end if
                        end if

                        select max(c24tltgrpseq)
                               into ws.c24tltgrpseq
                               from datktltgrpitm
                             where datktltgrpitm.c24tltgrpseq > 0

                        if ws.c24tltgrpseq is null   then
                           let ws.c24tltgrpseq = 0
                        end if

                        let ws.c24tltgrpseq = ws.c24tltgrpseq + 1

                        insert into datktltgrpitm(c24tltgrpnum,
                                                  c24tltgrpseq,
                                                  atdvclsgl,
                                                  pgrnum)
                                        values
                                                (param.c24tltgrpnum,
                                                 ws.c24tltgrpseq,
                                                 a_ctc52m01[arr_aux].atdvclsgl,
                                                 a_ctc52m01[arr_aux].pgrnum)
                   end case

                   let ws.operacao = " "
          end input

          if int_flag    then
             exit while
          end if

   end while

   let int_flag = false
   close window w_ctc52m01

end function  ###  ctc52m01

#---------------------------------------------------------------
function grupo_ctc52m01(param2)
#---------------------------------------------------------------

 define param2       record
        operacao     char(01),
        c24tltgrpnum like datktltgrp.c24tltgrpnum,
        c24tltgrpdes like datktltgrp.c24tltgrpdes,
        c24tltgrpstt like datktltgrp.c24tltgrpstt,
        descsit      char(10),
        caddat       like datktltgrp.caddat,
        cademp       like datktltgrp.cademp,
        cadmat       like datktltgrp.cadmat,
        cadnom       like isskfunc.funnom,
        cadusrtip    like datktltgrp.cadusrtip,
        atldat       like datktltgrp.atldat,
        atlemp       like datktltgrp.atlemp,
        atlmat       like datktltgrp.atlmat,
        atlnom       like isskfunc.funnom,
        atlusrtip    like datktltgrp.atlusrtip
 end record

 define ws2              record
         codgrptelprx    like datktltgrp.c24tltgrpnum,
         resp            char(01)
 end record

 initialize  ws2.*   to null

 begin work

 select max(c24tltgrpnum)
   into ws2.codgrptelprx
   from datktltgrp
 where datktltgrp.c24tltgrpnum > 0

 if ws2.codgrptelprx is null   then
    let ws2.codgrptelprx = 0
  end if
  let ws2.codgrptelprx = ws2.codgrptelprx + 1


  insert into datktltgrp (c24tltgrpnum,
                          c24tltgrpdes,
                          c24tltgrpstt,
                          caddat,
                          cademp,
                          cadmat,
                          cadusrtip,
                          atldat,
                          atlemp,
                          atlmat,
                          atlusrtip
                         )
              values
                      (ws2.codgrptelprx,
                       param2.c24tltgrpdes,
                       param2.c24tltgrpstt,
                       today,
                       g_issk.empcod,
                       g_issk.funmat,
                       g_issk.usrtip,
                       today,
                       g_issk.empcod,
                       g_issk.funmat,
                       g_issk.usrtip
                      )

  if sqlca.sqlcode <> 0   then
     error " Erro (",sqlca.sqlcode,") na inclusao do grupo !"
     rollback work
     initialize ws2.codgrptelprx to null
  else

     let param2.cademp = g_issk.empcod
     let param2.cadmat = g_issk.funmat
     let param2.atlemp = g_issk.empcod
     let param2.atlmat = g_issk.funmat

     call ctc52m01_func(param2.cademp, param2.cadmat)
          returning param2.cadnom

     call ctc52m01_func(param2.atlemp, param2.atlmat)
          returning param2.atlnom

     display by name param2.caddat,
                     param2.atldat,
                     param2.cadnom,
                     param2.atlnom

     display ws2.codgrptelprx to  c24tltgrpnum  attribute (reverse)
     error "Verifique o codigo do grupo e tecle ENTER!"
     prompt "" for char ws2.resp

  end if

  commit work

  return ws2.codgrptelprx

end function  ###  grupo_ctc52m01

#---------------------------------------------------------
 function ctc52m01_func(k_ctc52m01)
#---------------------------------------------------------

 define k_ctc52m01 record
    empcod         like isskfunc.empcod ,
    funmat         like isskfunc.funmat
 end record

 define ws         record
    funnom         like isskfunc.funnom
 end record

 let ws.funnom = "NAO CADASTRADO!"

 select funnom
   into ws.funnom
   from isskfunc
  where empcod = k_ctc52m01.empcod  and
        funmat = k_ctc52m01.funmat

 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

end function  ###  ctc52m01_func

