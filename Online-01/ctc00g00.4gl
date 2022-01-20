#############################################################################
# Nome do Modulo: ctc00g00                                         Marcelo  #
#                                                                  Gilberto #
# Digitacao padronizada de enderecos para cadastros                Jun/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 20/07/1999  Via correio  Gilberto     Retirar obrigatoriedade de padroni- #
#                                       zacao de endereco.                  #
#############################################################################

 database porto

#-----------------------------------------------------------
 function ctc00g00(param, d_ctc00g00)
#-----------------------------------------------------------

 define param      record
    cadendtip      dec (1,0)
 end record

 define d_ctc00g00 record
    cidnom         like datmlcl.cidnom,
    ufdcod         like datmlcl.ufdcod,
    brrnom         like datmlcl.brrnom,
    lgdtip         like datmlcl.lgdtip,
    lgdnom         like datmlcl.lgdnom,
    lgdnum         like datmlcl.lgdnum,
    lgdcep         like datmlcl.lgdcep,
    lgdcepcmp      like datmlcl.lgdcepcmp,
    lclrefptotxt   like datmlcl.lclrefptotxt,
    dddcod         like datmlcl.dddcod,
    lcltelnum      like datmlcl.lcltelnum
 end record

 define ws         record
    retflg         char (01),
    c24lclpdrcod   like datmlcl.c24lclpdrcod,
    cidcod         like glakcid.cidcod,
    qtdcep         integer,
    ufdcod         like glakest.ufdcod,
    cadenddes      char (20),
    cabtxt         char (68),
    confirma       char (01)
 end record

 initialize ws.*  to null

 if param.cadendtip = 1  then
    let ws.cadenddes = "AEROPORTO"
 end if

 let ws.cabtxt  =  "                 Endereco do ", downshift(ws.cadenddes)

 let ws.retflg = "N"

 open window ctc00g00 at 09,04 with form "ctc00g00"
      attribute(border, form line 1, message line last, comment line last - 1)

 display by name ws.cabtxt

 message " (F17)Abandona "

 let int_flag = false

 input by name d_ctc00g00.cidnom,
               d_ctc00g00.ufdcod,
               d_ctc00g00.lgdtip,
               d_ctc00g00.lgdnom,
               d_ctc00g00.lgdnum,
               d_ctc00g00.brrnom,
               d_ctc00g00.lgdcep,
               d_ctc00g00.lgdcepcmp,
               d_ctc00g00.lclrefptotxt,
               d_ctc00g00.dddcod,
               d_ctc00g00.lcltelnum without defaults


   before field cidnom
          display by name d_ctc00g00.cidnom thru d_ctc00g00.lcltelnum
          display by name d_ctc00g00.cidnom attribute (reverse)

   after  field cidnom
          display by name d_ctc00g00.cidnom

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
              if d_ctc00g00.cidnom is null  then
                 error " Cidade deve ser informada!"
                 next field cidnom
              end if
          end if

   before field ufdcod
          display by name d_ctc00g00.ufdcod attribute (reverse)

   after  field ufdcod
          display by name d_ctc00g00.ufdcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_ctc00g00.ufdcod is null  then
                error " Sigla da unidade da federacao deve ser informada!"
                next field ufdcod
             end if

             #--------------------------------------------------------------
             # Verifica se UF esta cadastrada
             #--------------------------------------------------------------
             select ufdcod
               from glakest
              where ufdcod = d_ctc00g00.ufdcod

             if sqlca.sqlcode = notfound then
                error " Unidade federativa nao cadastrada!"
                next field ufdcod
             end if

             if d_ctc00g00.ufdcod = d_ctc00g00.cidnom  then
                select ufdnom
                  into d_ctc00g00.cidnom
                  from glakest
                 where ufdcod = d_ctc00g00.cidnom

                if sqlca.sqlcode = 0  then
                   display by name d_ctc00g00.cidnom
                else
                   let d_ctc00g00.cidnom = d_ctc00g00.ufdcod
                end if
             end if

             #--------------------------------------------------------------
             # Verifica se a cidade esta cadastrada
             #--------------------------------------------------------------
             declare c_glakcid cursor for
                select cidcod
                  from glakcid
                 where cidnom = d_ctc00g00.cidnom
                   and ufdcod = d_ctc00g00.ufdcod

             open  c_glakcid
             fetch c_glakcid  into  ws.cidcod

             if sqlca.sqlcode  =  100   then
                call cts06g04(d_ctc00g00.cidnom, d_ctc00g00.ufdcod)
                     returning ws.cidcod, d_ctc00g00.cidnom, d_ctc00g00.ufdcod

                if d_ctc00g00.cidnom  is null   then
                   error " Cidade deve ser informada!"
                end if
                next field cidnom
             end if

             close c_glakcid
          end if

   before field lgdtip
          display by name d_ctc00g00.lgdtip attribute (reverse)

   after  field lgdtip
          display by name d_ctc00g00.lgdtip

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_ctc00g00.lgdtip is null  then
                error " Tipo do logradouro deve ser informado!"
                next field lgdtip
             end if
          end if

   before field lgdnom
          display by name d_ctc00g00.lgdnom attribute (reverse)

   after  field lgdnom
          display by name d_ctc00g00.lgdnom

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_ctc00g00.lgdnom is null then
                error " Logradouro deve ser informado!"
                next field lgdnom
             end if
          end if

   before field lgdnum
          display by name d_ctc00g00.lgdnum attribute (reverse)

   after  field lgdnum
          display by name d_ctc00g00.lgdnum

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_ctc00g00.lgdnum is null  then
                call cts08g01("C","S","","NUMERO DO LOGRADOURO","NAO INFORMADO!","") returning ws.confirma

                if ws.confirma = "N"  then
                   next field lgdnum
                end if
             end if

             call cts06g05(d_ctc00g00.lgdtip,
                           d_ctc00g00.lgdnom,
                           d_ctc00g00.lgdnum,
                           d_ctc00g00.brrnom,
                           ws.cidcod,
                           d_ctc00g00.ufdcod)
                 returning d_ctc00g00.lgdtip,
                           d_ctc00g00.lgdnom,
                           d_ctc00g00.brrnom,
                           d_ctc00g00.lgdcep,
                           d_ctc00g00.lgdcepcmp,
                           ws.c24lclpdrcod

             if ws.c24lclpdrcod is null  then
                error " Erro na padronizacao do endereco! AVISE A INFORMATICA!"
                next field lgdnom
             end if

             if ws.c24lclpdrcod = 01  then  ### Fora do Padrao
                call cts08g01("A","S","","ENDERECO DIGITADO","FORA DE PADRONIZACAO!","") returning ws.confirma
                if ws.confirma = "N"  then
                   next field cidnom
                else
                   let ws.retflg = "N"
                end if
             end if

             if ws.c24lclpdrcod = 02  then
                call cts06g06(d_ctc00g00.lgdnom)
                    returning d_ctc00g00.lgdnom
             end if

             display by name d_ctc00g00.cidnom thru d_ctc00g00.brrnom
          end if

   before field brrnom
          display by name d_ctc00g00.brrnom attribute (reverse)

   after  field brrnom
          display by name d_ctc00g00.brrnom

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_ctc00g00.brrnom is null then
                error " Bairro deve ser informado!"
                next field brrnom
             end if
          end if

   before field lgdcep
          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if ws.c24lclpdrcod = 02  then
                display by name d_ctc00g00.lgdcep
                display by name d_ctc00g00.lgdcepcmp
                next field lclrefptotxt
             else
                message " Aguarde, pesquisando CEP..." attribute (reverse)

                select count(*) into ws.qtdcep
                  from glaklgd
                 where cidcod = ws.cidcod

                message ""

                if ws.qtdcep > 1  then
                   call cts08g01("A","S","","CIDADE POSSUI CEP POR LOGRADOURO!","CONFIRMA UTILIZACAO DO CEP DA CIDADE?","") returning ws.confirma

                   if ws.confirma = "N"  then
                      next field lgdtip
                   end if
                end if

                select cidcep, cidcepcmp
                  into d_ctc00g00.lgdcep,
                       d_ctc00g00.lgdcepcmp
                  from glakcid
                 where ufdcod = d_ctc00g00.ufdcod  and
                       cidcod = ws.cidcod

                if sqlca.sqlcode = notfound  then
                   error " CEP generico da cidade nao encontrado!"
                else
                   display by name d_ctc00g00.lgdcep
                   display by name d_ctc00g00.lgdcepcmp
                   next field lclrefptotxt
                end if

                display by name d_ctc00g00.lgdcep attribute (reverse)
             end if
          end if

   after  field lgdcep
          display by name d_ctc00g00.lgdcep

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_ctc00g00.lgdcep is null then
                error " CEP deve ser informado!"
                next field lgdcep
             end if

             declare c_glaklgd cursor for
                select lgdcep from glaklgd
                 where lgdcep = d_ctc00g00.lgdcep

             open  c_glaklgd
             fetch c_glaklgd

             if sqlca.sqlcode = notfound  then
                error " CEP nao cadastrado! Informe novamente."
                next field lgdcep
             end if

             close c_glaklgd
          end if

   before field lgdcepcmp
          display by name d_ctc00g00.lgdcepcmp attribute (reverse)

   after  field lgdcepcmp
          display by name d_ctc00g00.lgdcepcmp

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_ctc00g00.lgdcepcmp is null then
                error " Complemento CEP deve ser informado!"
                next field lgdcepcmp
             end if
          end if

   before field lclrefptotxt
          display by name d_ctc00g00.lclrefptotxt attribute (reverse)

   after  field lclrefptotxt
          display by name d_ctc00g00.lclrefptotxt

   before field dddcod
          display by name d_ctc00g00.dddcod attribute (reverse)

   after  field dddcod
          display by name d_ctc00g00.dddcod

   before field lcltelnum
          display by name d_ctc00g00.lcltelnum attribute (reverse)

   after  field lcltelnum
          display by name d_ctc00g00.lcltelnum

          if (d_ctc00g00.dddcod    is not null  and
              d_ctc00g00.lcltelnum is null   )  or
             (d_ctc00g00.dddcod    is null      and
              d_ctc00g00.lcltelnum is not null) then
             error " Numero de telefone incompleto! "
             next field dddcod
          end if

   on key (interrupt)
      exit input

 end input

 if int_flag  then
    let int_flag = false
 end if

 if d_ctc00g00.cidnom        is not null  and
    d_ctc00g00.ufdcod        is not null  and
    d_ctc00g00.brrnom        is not null  and
    d_ctc00g00.lgdtip        is not null  and
    d_ctc00g00.lgdnom        is not null  and
    d_ctc00g00.dddcod        is not null  and
    d_ctc00g00.lcltelnum     is not null  and
    ws.c24lclpdrcod          is not null  then
    let ws.retflg = "S"
 end if

#------------------------------------------------------------------
# Verifica se UF foi alterada e nao foi feita pesquisa no cadastro
#------------------------------------------------------------------
 select ufdcod
   from glakest
  where ufdcod = d_ctc00g00.ufdcod

 if sqlca.sqlcode = notfound then
    let ws.retflg = "N"
 end if

#------------------------------------------------------------------------
# Verifica se cidade foi alterada e nao foi feita pesquisa no cadastro
#------------------------------------------------------------------------
 declare c_glakcid2 cursor for
    select cidcod
      from glakcid
     where cidnom = d_ctc00g00.cidnom
       and ufdcod = d_ctc00g00.ufdcod

 open  c_glakcid2
 fetch c_glakcid2

 if sqlca.sqlcode = notfound   then
    let ws.retflg = "N"
 end if

 close window ctc00g00

 return d_ctc00g00.*, ws.retflg

end function  ###  ctc00g00
