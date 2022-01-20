###########################################################################
# Nome do Modulo: ctc44m04                                        Marcelo #
#                                                                Gilberto #
# Manutencao do cadastro de enderecos dos socorristas            Jul/1999 #
###########################################################################

 database porto

#------------------------------------------------------------
 function ctc44m04(d_ctc44m04)
#------------------------------------------------------------

 define d_ctc44m04    record
    lgdtip            like datksrrend.lgdtip,
    lgdnom            like datksrrend.lgdnom,
    lgdnum            like datksrrend.lgdnum,
    endlgdcmp         like datksrrend.endlgdcmp,
    brrnom            like datksrrend.brrnom,
    cidnom            like datksrrend.cidnom,
    ufdcod            like datksrrend.ufdcod,
    endcep            like datksrrend.endcep,
    endcepcmp         like datksrrend.endcepcmp,
    lgdrefptodes      like datksrrend.lgdrefptodes,
    dddcod            like datksrrend.dddcod,
    telnum            like datksrrend.telnum,
    srrendobs         like datksrrend.srrendobs
 end record

 define ws            record
    cidcod            like glakcid.cidcod,
    contador          smallint,
    retflg            char (01)
 end record


 initialize ws.*  to null
 let int_flag   =  false
 let ws.retflg  =  "N"

 open window ctc44m04 at 9,4 with form "ctc44m04"
      attribute (form line first, border)

 input by name  d_ctc44m04.lgdtip,
                d_ctc44m04.lgdnom,
                d_ctc44m04.lgdnum,
                d_ctc44m04.endlgdcmp,
                d_ctc44m04.brrnom,
                d_ctc44m04.cidnom,
                d_ctc44m04.ufdcod,
                d_ctc44m04.endcep,
                d_ctc44m04.endcepcmp,
                d_ctc44m04.dddcod,
                d_ctc44m04.telnum,
                d_ctc44m04.lgdrefptodes,
                d_ctc44m04.srrendobs   without defaults

   before field lgdtip
          display by name d_ctc44m04.lgdtip attribute (reverse)

   after  field lgdtip
          display by name d_ctc44m04.lgdtip

          if d_ctc44m04.lgdtip is null  then
             error " Tipo do logradouro deve ser informado!"
             next field lgdtip
          end if

   before field lgdnom
          display by name d_ctc44m04.lgdnom attribute (reverse)

   after  field lgdnom
          display by name d_ctc44m04.lgdnom

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field  lgdtip
          end if

          if d_ctc44m04.lgdnom is null  then
             error " Logradouro deve ser informado!"
             next field lgdnom
          end if

   before field lgdnum
          display by name d_ctc44m04.lgdnum attribute (reverse)

   after  field lgdnum
          display by name d_ctc44m04.lgdnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field  lgdnom
          end if

   before field endlgdcmp
          display by name d_ctc44m04.endlgdcmp attribute (reverse)

   after  field endlgdcmp
          display by name d_ctc44m04.endlgdcmp

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field  lgdnum
          end if

   before field brrnom
          display by name d_ctc44m04.brrnom attribute (reverse)

   after  field brrnom
          display by name d_ctc44m04.brrnom

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field  endlgdcmp
          end if

          if d_ctc44m04.brrnom is null  then
             error " Bairro deve ser informado!"
             next field brrnom
          end if

   before field cidnom
          display by name d_ctc44m04.cidnom attribute (reverse)

   after  field cidnom
          display by name d_ctc44m04.cidnom

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field  brrnom
          end if

          if d_ctc44m04.cidnom is null  then
             error " Cidade deve ser informada!"
             next field cidnom
          end if

   before field ufdcod
          display by name d_ctc44m04.ufdcod  attribute(reverse)

   after  field ufdcod
          display by name d_ctc44m04.ufdcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field  cidnom
          end if

          if d_ctc44m04.ufdcod is null  then
             error " Sigla da unidade da federacao deve ser informada!"
             next field ufdcod
          end if

          #--------------------------------------------------------------
          # Verifica se UF esta cadastrada
          #--------------------------------------------------------------
          select ufdcod
            from glakest
           where ufdcod = d_ctc44m04.ufdcod

          if sqlca.sqlcode = notfound then
             error " Unidade federativa nao cadastrada!"
             next field ufdcod
          end if

          #--------------------------------------------------------------
          # Verifica se a cidade esta cadastrada
          #--------------------------------------------------------------
          declare c_glakcid cursor for
             select cidcod
               from glakcid
              where cidnom = d_ctc44m04.cidnom
                and ufdcod = d_ctc44m04.ufdcod

          open  c_glakcid
          fetch c_glakcid

          if sqlca.sqlcode  =  100   then
             call cts06g04(d_ctc44m04.cidnom, d_ctc44m04.ufdcod)
                  returning ws.cidcod, d_ctc44m04.cidnom, d_ctc44m04.ufdcod

             if d_ctc44m04.cidnom  is null   then
                error " Cidade deve ser informada!"
             end if
             next field cidnom
          end if

          close c_glakcid

   before field endcep
          display by name d_ctc44m04.endcep attribute (reverse)

   after  field endcep
          display by name d_ctc44m04.endcep

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field  ufdcod
          end if

          if d_ctc44m04.endcep is null  then
             error " CEP deve ser informado!"
             next field endcep
          end if

          let ws.contador = 0
          select count(*) into ws.contador
            from glakcid
           where cidcep  =  d_ctc44m04.endcep

          if ws.contador = 0  then
             select count(*) into ws.contador
               from glaklgd
              where lgdcep = d_ctc44m04.endcep

             if ws.contador = 0  then
                error " CEP nao cadastrado - Consulte pelo logradouro!"
                initialize d_ctc44m04.endcep, d_ctc44m04.endcepcmp to null

                call ctn11c02(d_ctc44m04.ufdcod, d_ctc44m04.cidnom, d_ctc44m04.lgdnom)
                     returning d_ctc44m04.endcep, d_ctc44m04.endcepcmp

                if d_ctc44m04.endcep is null then
                   error " Ver CEP por cidade - Consulte pela cidade!"

                   call ctn11c03(d_ctc44m04.cidnom)
                       returning d_ctc44m04.endcep
                end if
                next field endcep
             end if
          end if

#         declare c_glaklgd  cursor for
#            select lgdcep
#              from glaklgd
#             where glaklgd.lgdcep  =  d_ctc44m04.endcep
#
#         declare c_glakcid2  cursor for
#            select cidcep
#              from glakcid
#             where glakcid.cidcep  =  d_ctc44m04.endcep
#
#         open  c_glaklgd
#         fetch c_glaklgd
#
#         if sqlca.sqlcode  =  notfound   then
#
#            open  c_glakcid2
#            fetch c_glakcid2
#            if sqlca.sqlcode  =  notfound   then
#               error " CEP nao cadastrado!"
#               next field endcep
#            end if
#            close c_glakcid2
#
#         end if
#
#         close c_glaklgd

   before field endcepcmp
          display by name d_ctc44m04.endcepcmp attribute (reverse)

   after  field endcepcmp
          display by name d_ctc44m04.endcepcmp

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field  endcep
          end if

   before field dddcod
          display by name d_ctc44m04.dddcod attribute (reverse)

   after  field dddcod
          display by name d_ctc44m04.dddcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field  endcepcmp
          end if

          if d_ctc44m04.dddcod is null  then
             initialize d_ctc44m04.dddcod  to null
             initialize d_ctc44m04.telnum  to null
             display by name d_ctc44m04.dddcod
             display by name d_ctc44m04.telnum
             next field lgdrefptodes
          end if

   before field telnum
          display by name d_ctc44m04.telnum attribute (reverse)

   after  field telnum
          display by name d_ctc44m04.telnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field  dddcod
          end if

          if d_ctc44m04.dddcod is not null  then
             if d_ctc44m04.telnum is null  then
                error " Numero do telefone deve ser informado!"
                next field telnum
             end if
          end if

   before field lgdrefptodes
          display by name d_ctc44m04.lgdrefptodes attribute (reverse)

   after  field lgdrefptodes
          display by name d_ctc44m04.lgdrefptodes

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             if d_ctc44m04.telnum  is not null   then
                next field  telnum
             end if
             next field  dddcod
          end if

   before field srrendobs
          display by name d_ctc44m04.srrendobs attribute (reverse)

   after  field srrendobs
          display by name d_ctc44m04.srrendobs

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field  lgdrefptodes
          end if

    on key (interrupt)
       exit input

 end input

 if not int_flag   then
    let ws.retflg  =  "S"
 end if

 close window ctc44m04

 return d_ctc44m04.*, ws.retflg

 end function   ###-- ctc44m04
