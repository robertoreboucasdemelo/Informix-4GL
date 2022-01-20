###############################################################################
# Nome do Modulo: CTC28M01                                           Marcelo  #
#                                                                    Gilberto #
# Manutencao no cadastro de faixas de regiao                         Mai/1996 #
###############################################################################

database porto

#------------------------------------------------------------
 function ctc28m01(param)
#------------------------------------------------------------

define param      record
   atdregcod      like datkatdreg.atdregcod
end record

define d_ctc28m01 record
   atdregcod      like datkatdreg.atdregcod ,
   atdregdes      like datkatdreg.atdregdes
end record

define a_ctc28m01 array[10] of record
   atdregfxacod   like datkfxareg.atdregfxacod ,
   cepinc         like datkfxareg.cepinc       ,
   cepfnl         like datkfxareg.cepfnl
end record

define salva      record
   cepinc         like datkfxareg.cepinc       ,
   cepfnl         like datkfxareg.cepfnl
end record

define ws         record
   operacao       char(01)                     ,
   atdregcod      like datkatdreg.atdregcod    ,
   atdregdes      like datkatdreg.atdregdes
end record

define arr_aux    smallint
define scr_aux    smallint

open window w_ctc28m01 at  06,02 with form "ctc28m01"
            attribute(form line first)

   message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

   let d_ctc28m01.atdregcod = param.atdregcod

   select atdregdes
     into d_ctc28m01.atdregdes
     from datkatdreg
    where atdregcod = param.atdregcod

   if sqlca.sqlcode = NOTFOUND  then
      error "Regiao nao cadastrada. AVISE A INFORMATICA!"
   else
      if sqlca.sqlcode < 0  then
         error "Erro (", sqlca.sqlcode, ") durante localizacao da regiao. ",
               "AVISE A INFORMATICA!"
         close window w_ctc28m01
         return
      end if
   end if

   display by name d_ctc28m01.*

   initialize ws.*        to null
   initialize salva.*     to null
   initialize a_ctc28m01  to null
   let int_flag = false
   let arr_aux  = 1

   declare c_ctc28m01  cursor for
      select atdregfxacod, cepinc, cepfnl
        from datkfxareg
       where atdregcod  =  param.atdregcod
       order by cepinc

   foreach c_ctc28m01 into a_ctc28m01[arr_aux].atdregfxacod ,
                           a_ctc28m01[arr_aux].cepinc       ,
                           a_ctc28m01[arr_aux].cepfnl

      let arr_aux = arr_aux + 1
      if arr_aux > 10 then
         error " Limite excedido. Regiao com mais de 10 faixas!"
         exit foreach
      end if
   end foreach

   if arr_aux = 1   then
      error " Nao existem faixas cadastradas para esta regiao !"
   end if
   call set_count(arr_aux-1)

   input array a_ctc28m01 without defaults from s_ctc28m01.*
      before row
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         if arr_aux <= arr_count()  then
            let ws.operacao = "a"
            let salva.cepinc = a_ctc28m01[arr_aux].cepinc
            let salva.cepfnl = a_ctc28m01[arr_aux].cepfnl
         end if

      before insert
         let ws.operacao = "i"
         initialize a_ctc28m01[arr_aux].*  to null

      before field cepinc
         display a_ctc28m01[arr_aux].cepinc to
                 s_ctc28m01[scr_aux].cepinc attribute (reverse)

      after  field cepinc
         display a_ctc28m01[arr_aux].cepinc to
                 s_ctc28m01[scr_aux].cepinc

         if fgl_lastkey() = fgl_keyval("down")   then
            if a_ctc28m01[arr_aux + 1].cepinc is null   then
               error "Nao existem linhas nesta direcao!"
               next field cepinc
            end if
         end if

         if a_ctc28m01[arr_aux].cepinc is null then
            error "CEP Inicial e' obrigatorio!"
            next field cepinc
         end if

         if length(a_ctc28m01[arr_aux].cepinc) <> 5 then
            error "CEP Inicial deve ter obrigatoriamente 5 numeros!"
            next field cepinc
         end if

         if ws.operacao = "i" then

            select atdregcod
              into ws.atdregcod
              from datkfxareg
                   where cepinc <= a_ctc28m01[arr_aux].cepinc and
                         cepfnl >= a_ctc28m01[arr_aux].cepinc

            if sqlca.sqlcode = 0 then
               call ctc28m01_error(ws.atdregcod)
               next field cepinc
            end if
         else
            if ws.operacao = "a"   and
               a_ctc28m01[arr_aux].cepinc <> salva.cepinc then

               select atdregcod
                 into ws.atdregcod
                 from datkfxareg
                      where cepinc       <= a_ctc28m01[arr_aux].cepinc     and
                            cepfnl       >= a_ctc28m01[arr_aux].cepinc     and
                            atdregfxacod <> a_ctc28m01[arr_aux].atdregfxacod

               if sqlca.sqlcode = 0 then
                  call ctc28m01_error(ws.atdregcod)
                  next field cepinc
               end if
            end if
         end if

      before field cepfnl
         display a_ctc28m01[arr_aux].cepfnl to
                 s_ctc28m01[scr_aux].cepfnl attribute (reverse)

      after  field cepfnl
         display a_ctc28m01[arr_aux].cepfnl to
                 s_ctc28m01[scr_aux].cepfnl

         if fgl_lastkey() = fgl_keyval("down")   then
            if a_ctc28m01[arr_aux + 1].cepfnl is null   then
               error "Nao existem linhas nesta direcao!"
               next field cepfnl
            end if
         end if

         if a_ctc28m01[arr_aux].cepfnl is null then
            error "CEP Final e' obrigatorio!"
            next field cepfnl
         end if

         if a_ctc28m01[arr_aux].cepfnl < a_ctc28m01[arr_aux].cepinc then
            error "CEP Final nao pode ser menor que o CEP Inicial!"
            next field cepfnl
         end if

         if length(a_ctc28m01[arr_aux].cepfnl) <> 5 then
            error "CEP Final deve ter obrigatoriamente 5 numeros!"
            next field cepfnl
         end if

         if ws.operacao = "i" then

            select atdregcod
              into ws.atdregcod
              from datkfxareg
                   where cepinc <= a_ctc28m01[arr_aux].cepfnl and
                         cepfnl >= a_ctc28m01[arr_aux].cepfnl

            if sqlca.sqlcode = 0 then
               call ctc28m01_error(ws.atdregcod)
               next field cepfnl
            end if
         else
            if ws.operacao = "a"   and
               a_ctc28m01[arr_aux].cepfnl <> salva.cepfnl then

               select atdregcod
                 into ws.atdregcod
                 from datkfxareg
                      where cepinc       <= a_ctc28m01[arr_aux].cepfnl and
                            cepfnl       >= a_ctc28m01[arr_aux].cepfnl and
                            atdregfxacod <> a_ctc28m01[arr_aux].atdregfxacod

               if sqlca.sqlcode = 0 then
                  call ctc28m01_error(ws.atdregcod)
                  next field cepfnl
               end if
            end if
         end if

      declare c_cursor cursor for
         select atdregcod
           from datkfxareg
                where cepinc   > a_ctc28m01[arr_aux].cepinc and
                      cepfnl   < a_ctc28m01[arr_aux].cepfnl

      open  c_cursor
      fetch c_cursor into ws.atdregcod
      if sqlca.sqlcode = 0 then
         call ctc28m01_error(ws.atdregcod)
         next field cepinc
      end if
      close c_cursor

      on key (interrupt)
            exit input

      before delete
            if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
               exit input
            end if
            let ws.operacao = "d"

            BEGIN WORK
               delete from datkfxareg
                where atdregfxacod = a_ctc28m01[arr_aux].atdregfxacod and
                         atdregcod = d_ctc28m01.atdregcod
            COMMIT WORK

            initialize a_ctc28m01[arr_aux].* to null
            display a_ctc28m01[arr_aux].* to s_ctc28m01[scr_aux].*

      after row
            BEGIN WORK

            case ws.operacao
               when "i"

                 select max(atdregfxacod)
                   into a_ctc28m01[arr_aux].atdregfxacod
                   from datkfxareg

                 if a_ctc28m01[arr_aux].atdregfxacod is null then
                    let a_ctc28m01[arr_aux].atdregfxacod = 0
                 end if

                 let a_ctc28m01[arr_aux].atdregfxacod =
                     a_ctc28m01[arr_aux].atdregfxacod + 1

                 display a_ctc28m01[arr_aux].* to s_ctc28m01[scr_aux].*

                 insert into datkfxareg
                        (atdregfxacod, atdregcod, cepinc, cepfnl)
                 values (a_ctc28m01[arr_aux].atdregfxacod ,
                         d_ctc28m01.atdregcod             ,
                         a_ctc28m01[arr_aux].cepinc       ,
                         a_ctc28m01[arr_aux].cepfnl       )

               when "a"
                  update datkfxareg set (cepinc, cepfnl) =
                         (a_ctc28m01[arr_aux].cepinc       ,
                          a_ctc28m01[arr_aux].cepfnl       ) where
                          atdregfxacod = a_ctc28m01[arr_aux].atdregfxacod and
                          atdregcod    = d_ctc28m01.atdregcod
            end case

            COMMIT WORK
            let ws.operacao = " "
    end input

    for arr_aux = 1  to  11
        clear s_ctc28m01[arr_aux].*
    end for

let int_flag = false
close window  w_ctc28m01

end function  #  ctc28m01

#--------------------------------------
 function ctc28m01_error(param)
#--------------------------------------

define param   record
   atdregcod   like datkatdreg.atdregcod
end record

define saida   record
   atdregdes   like datkatdreg.atdregdes
end record

  let saida.atdregdes = "NAO CADASTRADA!"

  select atdregdes
    into saida.atdregdes
    from datkatdreg
   where atdregcod = param.atdregcod

  error "Este CEP ja' pertence `a regiao ", saida.atdregdes clipped, "!"

end function  ### ctc28m01_error
