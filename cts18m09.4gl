###############################################################################
# Nome do Modulo: CTS18M09                                           Marcelo  #
#                                                                    Gilberto #
# Informacoes sobre veiculo do causador                              Ago/1997 #
###############################################################################

database porto

#-----------------------------------------------------------
 function cts18m09(d_cts18m09)
#-----------------------------------------------------------

 define d_cts18m09    record
    tipchv            char (01)                    ,
    vclcoddig         like ssamavsvcl.vclcoddig    ,
    sinbemdes         like ssamavsvcl.sinbemdes    ,
    vclcorcod         like ssamavsvcl.vclcorcod    ,
    vclchsnum         like ssamavsvcl.vclchsnum    ,
    vcllicnum         like ssamavsvcl.vcllicnum    ,
    vclanofbc         like ssamavsvcl.vclanofbc    ,
    vclanomdl         like ssamavsvcl.vclanomdl
 end record

 define ws            record
    vclcordes         char (12),
    vclcor            char (12),
    filler            char (01),
    confirma          char (01)
 end record

 define l_data       date,
        l_hora2      datetime hour to minute,
        l_ano        datetime year to year


	initialize  ws.*  to  null

 initialize ws.* to null

 open window w_cts18m09 at 12,02 with form "cts18m09"
                        attribute(form line 1, border, comment line last - 1)

 message " (F17)Abandona"

 if d_cts18m09.tipchv = "I"  then
    call cts08g01("Q","N","","INFORMACOES REFERENTES",
                  "AO VEICULO DO CAUSADOR", "")
         returning ws.confirma
 end if

 if d_cts18m09.vclcorcod is not null  then
    select cpodes into ws.vclcordes
      from iddkdominio
     where cponom = "vclcorcod"      and
           cpocod = d_cts18m09.vclcorcod

    if sqlca.sqlcode = notfound  then
       initialize ws.vclcordes to null
    end if
 end if

 if d_cts18m09.vclcoddig is not null  and
    d_cts18m09.sinbemdes is null      then
    call veiculo_cts18m00(d_cts18m09.vclcoddig)
                returning d_cts18m09.sinbemdes
 end if

 display by name d_cts18m09.sinbemdes

 input by name d_cts18m09.vclcoddig,
               ws.vclcordes        ,
               d_cts18m09.vclchsnum,
               d_cts18m09.vcllicnum,
               d_cts18m09.vclanofbc,
               d_cts18m09.vclanomdl,
               ws.filler             without defaults

   before field vclcoddig
      if d_cts18m09.tipchv = "M"  then
         if d_cts18m09.vclcoddig is not null  then
            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               exit input
            else
               next field vclcordes
            end if
         else
            display by name d_cts18m09.vclcoddig  attribute (reverse)
         end if
      else
         display by name d_cts18m09.vclcoddig  attribute (reverse)
      end if

   after  field vclcoddig
      display by name d_cts18m09.vclcoddig

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m09.vclcoddig is null  then
#           error " Codigo do veiculo deve ser informado!"
            call agguvcl() returning d_cts18m09.vclcoddig
            if d_cts18m09.vclcoddig is null  then
               next field vclcordes
            else
               next field vclcoddig
            end if
         else
            call veiculo_cts18m00(d_cts18m09.vclcoddig)
                 returning d_cts18m09.sinbemdes

            if d_cts18m09.sinbemdes is null  or
               d_cts18m09.sinbemdes =  "  "  then
               error " Codigo do veiculo nao cadastrado!"
               next field vclcoddig
            else
               display by name d_cts18m09.sinbemdes
               next field vclcordes
            end if
         end if
      end if

   before field vclcordes
      if d_cts18m09.tipchv = "M"   and
         ws.vclcordes is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field vclcoddig
         else
            next field vclchsnum
         end if
      end if

      display by name ws.vclcordes  attribute (reverse)

   after  field vclcordes
      display by name ws.vclcordes

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if ws.vclcordes is null  then
#           error " Cor do veiculo deve ser informada!"
#           next field vclcordes
         else
            let ws.vclcor = ws.vclcordes[02,11]

            select cpocod into d_cts18m09.vclcorcod
              from iddkdominio
             where cponom        = "vclcorcod"  and
                   cpodes[02,11] = ws.vclcor

            if sqlca.sqlcode = notfound  then
               error " Cor fora do padrao!"
               call c24geral4()
                    returning d_cts18m09.vclcorcod, ws.vclcordes

               if d_cts18m09.vclcorcod is not null  then
                  display by name ws.vclcordes
               else
                  next field vclcordes
               end if
            end if
         end if
      end if

   before field vclchsnum
      if d_cts18m09.tipchv = "M"           and
         d_cts18m09.vclchsnum is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field vclcordes
         else
            next field vcllicnum
         end if
      end if

      display by name d_cts18m09.vclchsnum  attribute (reverse)

   after  field vclchsnum
      display by name d_cts18m09.vclchsnum

   before field vcllicnum
      if d_cts18m09.tipchv = "M"           and
         d_cts18m09.vcllicnum is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field vclchsnum
         else
            next field vclanofbc
         end if
      end if

      display by name d_cts18m09.vcllicnum  attribute (reverse)

   after  field vcllicnum
      display by name d_cts18m09.vcllicnum

   before field vclanofbc
      if d_cts18m09.tipchv = "M"           and
         d_cts18m09.vclanofbc is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field vcllicnum
         else
            next field vclanomdl
         end if
      end if

      display by name d_cts18m09.vclanofbc  attribute (reverse)

   after  field vclanofbc
      display by name d_cts18m09.vclanofbc

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m09.vclanofbc is null  then
#           error " Ano de fabricacao do veiculo deve ser informado!"
#           next field vclanofbc
         else
            call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
            ##if d_cts18m09.vclanofbc > current year to year  then
            let l_ano = l_data using "yyyy"
            if d_cts18m09.vclanofbc > l_ano then
               error " Ano de fabricacao do veiculo nao pode ser maior que o ano atual!"
               next field vclanofbc
            end if
         end if
      end if

   before field vclanomdl
      if d_cts18m09.tipchv = "M"           and
         d_cts18m09.vclanofbc is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field vclanofbc
         else
            next field filler
         end if
      else
         if d_cts18m09.vclanomdl is null  then
            let d_cts18m09.vclanomdl = d_cts18m09.vclanofbc
         end if
      end if

      display by name d_cts18m09.vclanomdl  attribute (reverse)

   after  field vclanomdl
      display by name d_cts18m09.vclanomdl

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m09.vclanomdl is null  then
#           error " Ano modelo do veiculo deve ser informado!"
#           next field vclanomdl
         else
            if d_cts18m09.vclanomdl > d_cts18m09.vclanofbc + 1 units year  then
               error " Ano modelo do veiculo nao pode ser maior que o proximo ano!"
               next field vclanomdl
            end if

            if d_cts18m09.vclanomdl < d_cts18m09.vclanofbc  then
               error " Ano modelo nao pode ser inferior ao ano de fabricacao!"
               next field vclanomdl
            end if
         end if
      end if

   before field filler
      if d_cts18m09.tipchv = "I"  then
         exit input
      else
         error " Pressione ENTER para continuar... "
      end if

   after  field filler
      if fgl_lastkey() = fgl_keyval("return")  then
         exit input
      else
         next field filler
      end if

   on key (interrupt)
      exit input

 end input

 close window w_cts18m09

 return d_cts18m09.vclcoddig thru d_cts18m09.vclanomdl

end function  ###  cts18m09
