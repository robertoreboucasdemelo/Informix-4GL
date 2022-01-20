###############################################################################
# Nome do Modulo: CTA01M06                                           Gilberto #
#                                                                     Marcelo #
# Exibe parcelas da apolice a partir da cobranca                     Set/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 19/04/1999  PSI 8181-7   Wagner       Fazer acesso a rotina cobranca para   #
#                                       informar data cobertura.              #
#-----------------------------------------------------------------------------#
# 22/05/2002  PSI 154180   Ruiz         Alerta qdo cobranca <> de carne.      #
#-----------------------------------------------------------------------------#
 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
 function cta01m06(param)
#----------------------------------------------------------------
 define param      record
    succod         like fctrpevparc.succod,
    ramcod         like fctrpevparc.ramcod,
    subcod         like fctrpevparc.subcod,
    aplnumdig      like fctrpevparc.aplnumdig
 end record

 define a_cta01m06 array[100] of record
    parnum         like fctrpevparc.parnum,
    vctdat         like fctmtitulos.vctdat,
    parvlr         like fctmtitulos.parvlr,
    situacao       char(03),
    pgtdat         like fctmpag.pgtdat,
    cptdat         like fctmpag.cptdat,
    pgtvlr         like fctmpag.pgtvlr
 end record

 define a_cta01m06a array[100] of record
    titnumdig      like fctmtitulos.titnumdig,
    cobemstip      like fctmtitulos.cobemstip,
    cobtip         like fctmtitulos.cobtip,
    cobtipdes      like fcakcobr.cobtipdes,
    edsnumdig      like fctrpevparc.edsnumdig,
    edstipdes      char(40)
 end record

 define ws         record
    itmnumdig      like abbmitem.itmnumdig,
    parsitcod      like fctmtitulos.parsitcod,
    parnumsva      like fctrpevparc.parnum,
    segtip         like abamapol.segtip,
    status         integer,
    inadimplente   smallint,
    edsstt         char(1),
    vigini         date,
    vigfin         date,
    przctodia      smallint,
    przfincob      date,
    prmlipag       dec(15,5),
    prmliqdev      dec(15,5),
    segtip2        like abamapol.segtip,
    mens           char(90),
    msglinha       char(40),
    confirma       char(1),
    itmqtd         integer
 end record

 define arr_aux    integer
 define scr_aux    integer



	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_cta01m06[w_pf1].*  to  null
	end	for

	for	w_pf1  =  1  to  100
		initialize  a_cta01m06a[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 open window cta01m06 at 6,2 with form "cta01m06"
             attribute (form line first, comment line last - 1)

 initialize ws.*         to null
 initialize a_cta01m06   to null
 initialize a_cta01m06a  to null
 let arr_aux = 1

 #----------------------------------------------------------------
 # Verifica se apolice e' de seguro mensal
 #----------------------------------------------------------------
 if param.ramcod = 31 or 
    param.ramcod = 531  then
    select segtip
      into ws.segtip
      from abamapol
     where succod    = param.succod     and
           aplnumdig = param.aplnumdig

    if sqlca.sqlcode <> 0   then
       error " Erro (",sqlca.sqlcode,") leitura tipo seguro, AVISE INFORMATICA!"
       sleep 4
    end if
   else
    let ws.segtip = 1
 end if

 #----------------------------------------------------------------
 # Le todas as parcelas da apolice no sistema de cobranca
 #----------------------------------------------------------------
 message " Aguarde, pesquisando..."  attribute(reverse)

 declare c_cta01m06 cursor for
    select parnum   , titnumdig,
           edsnumdig
      from fctrpevparc
     where succod    =  param.succod     and
           ramcod    =  param.ramcod     and
           subcod    =  param.subcod     and
           aplnumdig =  param.aplnumdig
    order by edsnumdig, parnum

 foreach c_cta01m06  into  a_cta01m06[arr_aux].parnum,
                           a_cta01m06a[arr_aux].titnumdig,
                           a_cta01m06a[arr_aux].edsnumdig

    #----------------------------------------------------------------
    # Le dados sobre o titulo
    #----------------------------------------------------------------
    select cobtip, parvlr,
           vctdat, parsitcod,
           cobemstip
      into a_cta01m06a[arr_aux].cobtip,
           a_cta01m06[arr_aux].parvlr,
           a_cta01m06[arr_aux].vctdat,
           ws.parsitcod,
           a_cta01m06a[arr_aux].cobemstip
      from fctmtitulos
      where titnumdig = a_cta01m06a[arr_aux].titnumdig

    if sqlca.sqlcode <> 0   then
       error " Erro (",sqlca.sqlcode,") leitura do titulo, AVISE INFORMATICA!"
       sleep 4
       exit foreach
    end if

    #----------------------------------------------------------------
    # Descricao do tipo de cobranca/forma de pagamento
    #----------------------------------------------------------------
    let a_cta01m06a[arr_aux].cobtipdes  =  "*** NAO ENCONTRADO ***"
    select cobtipdes
       into a_cta01m06a[arr_aux].cobtipdes
       from fcakcobr
      where cobtip = a_cta01m06a[arr_aux].cobtip

    if sqlca.sqlcode <> 0   then
       error " Erro (",sqlca.sqlcode,") na forma de pagto, AVISE INFORMATICA!"
       sleep 4
    end if

    #----------------------------------------------------------------
    # Verifica situacao do titulo
    #----------------------------------------------------------------
    if  ws.parsitcod = 1 then
       let a_cta01m06[arr_aux].situacao = "PEN"
    end if

    if  ws.parsitcod = 3 then
       let a_cta01m06[arr_aux].situacao = "CAN"
    end if

    if ws.parsitcod = 2 then
       let a_cta01m06[arr_aux].situacao = "PAG"

       select pgtdat, cptdat, pgtvlr
         into a_cta01m06[arr_aux].pgtdat,
              a_cta01m06[arr_aux].cptdat,
              a_cta01m06[arr_aux].pgtvlr
         from fctmpag
        where titnumdig = a_cta01m06a[arr_aux].titnumdig   and
              pgtsit    = 0

       if sqlca.sqlcode  <>  0   then
          error " Erro (",sqlca.sqlcode,") dados do pgto, AVISE INFORMATICA!"
          sleep 4
          let a_cta01m06[arr_aux].pgtdat = " "
          let a_cta01m06[arr_aux].cptdat = " "
          let a_cta01m06[arr_aux].pgtvlr =  0
       end if
    end if

    #----------------------------------------------------------------
    # Verifica tipo de endosso da parcela
    #----------------------------------------------------------------
    initialize a_cta01m06a[arr_aux].edstipdes   to null
    call endosso_cta01m06(param.succod,    param.ramcod,
                          param.aplnumdig, a_cta01m06a[arr_aux].edsnumdig)
         returning  a_cta01m06a[arr_aux].edstipdes

    let arr_aux = arr_aux + 1
    if arr_aux > 100   then
       error " Limite excedido, documento com mais de 100 parcelas!"
       exit foreach
    end if

 end foreach

 #----------------------------------------------------------------
 # Exibe parcelas da apolice, se houver
 #----------------------------------------------------------------
 if arr_aux  =  1   then
    error " Documento nao possui parcelas cadastradas!"
 else
    message " (F17)Abandona, (F8)Recalcula, (F9)Cobertura"
    options insert key F40,
            delete key F45

    call set_count(arr_aux-1)

    input array a_cta01m06 without defaults  from  s_cta01m06.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          display a_cta01m06[arr_aux].*  to
                  s_cta01m06[scr_aux].*  attribute(reverse)

          display a_cta01m06a[arr_aux].cobtipdes  to  cobtipdes
          display a_cta01m06a[arr_aux].edstipdes  to  edstipdes

       after row
          display a_cta01m06[arr_aux].*  to
                  s_cta01m06[scr_aux].*

       before field parnum
          display a_cta01m06[arr_aux].parnum  to
                  s_cta01m06[scr_aux].parnum  attribute (reverse)

          let ws.parnumsva = a_cta01m06[arr_aux].parnum

       after  field parnum
          let a_cta01m06[arr_aux].parnum = ws.parnumsva
          display a_cta01m06[arr_aux].parnum  to
                  s_cta01m06[scr_aux].parnum

          if fgl_lastkey() = fgl_keyval("down")     or
             fgl_lastkey() = fgl_keyval("right")    or
             fgl_lastkey() = fgl_keyval("return")   then
             if arr_aux   <  100                        and
                a_cta01m06[arr_aux+1].parnum  is null   then
                error " Nao existem mais linhas nesta direcao!"
                next field  parnum
             end if
          end if

       on key (F8)
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          if g_issk.acsnivcod  <  6   then
             error " Nivel de acesso nao permite recalculo!"
             continue input
          end if

          if a_cta01m06a[arr_aux].cobemstip = 6   then
             error " Nao e' permitido recalculo para o ramo  TRANSPORTE!"
             continue input
          end if

          if a_cta01m06[arr_aux].situacao <> "PEN"   then
             error " Recalculo so' e' permitido para parcelas pendentes!"
             continue input
          end if
         #if a_cta01m06a[arr_aux].cobtip  <>  01 then  # carne
         #   call cts08g01 ("A","N",
         #                  "O PAGAMENTO DA APOLICE NAO PODE SER CAL-",
         #                  "CULADO POIS NAO FOI FEITO EM CARNE, PARA",
         #                  "INFORMACOES SOBRE PAGAMENTOS FAVOR      ",
         #                  "TRANSFERIR PARA A COBRANCA.             ")
         #        returning ws.confirma
         #   continue input
         #end if
          if a_cta01m06a[arr_aux].cobtip  <>  01   and    #--> Banco(carne)
             a_cta01m06a[arr_aux].cobtip  <>  02   then   #--> Nota de seguro
             error " Recalculo so' e' permitido para carne/nota de seguro!"
             continue input
          end if

          if a_cta01m06a[arr_aux].titnumdig  is null   then
             error " Nao e' possivel recalcular, titulo nao encontrado, AVISE INFORMATICA!"
             continue input
          end if

          if a_cta01m06[arr_aux].vctdat  is null   then
             error " Nao e' possivel recalcular, vencto nao encontrado, AVISE INFORMATICA!"
             continue input
          end if

          display a_cta01m06[arr_aux].parnum   to
                  s_cta01m06[scr_aux].parnum

          call cta01m07(param.succod,
                        param.ramcod,
                        param.aplnumdig,
                        ws.segtip,
                        a_cta01m06[arr_aux].parnum,
                        a_cta01m06a[arr_aux].titnumdig,
                        a_cta01m06[arr_aux].vctdat,
                        a_cta01m06[arr_aux].parvlr,
                        a_cta01m06a[arr_aux].edstipdes)

       on key (F9)
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          display a_cta01m06[arr_aux].parnum   to
                  s_cta01m06[scr_aux].parnum

          if ws.segtip = 1 then
             # --->   MENSAGEM PARA NORMAL
             let ws.itmnumdig = g_documento.itmnumdig
             if ws.itmnumdig is null then
                let ws.itmnumdig = 0
             end if

             let ws.itmqtd = 0
             select count(*)
               into ws.itmqtd
               from abbmitem
              where succod    = param.succod
                and aplnumdig = param.aplnumdig

             if ws.itmqtd > 1  then
                let ws.itmnumdig = 0   # --> APOLICE COLETIVA
             end if

             call ffcic062_inad(param.succod,
                                param.ramcod,
                                param.aplnumdig,
                                0,
                                ws.itmnumdig,
                                today)
                      returning ws.status,
                                ws.inadimplente,
                                ws.edsstt,
                                ws.vigini,
                                ws.vigfin,
                                ws.przctodia,
                                ws.przfincob,
                                ws.prmlipag,
                                ws.prmliqdev,
                                ws.segtip2,
                                ws.mens

             if ws.status = 0 then
                if ws.inadimplente = 0 then
                   let ws.msglinha = "COBERTURA ATE' : ",ws.vigfin
                else
                   let ws.msglinha = "COBERTURA ATE' : ",ws.przfincob
                end if
                call cts08g01("I","N", "", "", ws.msglinha, "")
                     returning ws.confirma
             else
               if ws.mens[1,40] = "Documento nao possui cobranca" then
                  let ws.mens[1,40]="Favor Transferir Ligacao para Cobranca, "
                  let ws.mens[41,80]="documento com problemas para calculo das"
                  let ws.mens[81,90]=" parcelas."
               end if
               call cts08g01("A","N", "", ws.mens[1,40],ws.mens[41,80],ws.mens[81,90])
                     returning ws.confirma
              #call cts08g01("A","N", "", ws.mens[1,40], ws.mens[41,70], "")
              #     returning ws.confirma
             end if

          else

             # ####   MENSAGEM PARA MENSAL
             call cts08g01("I","N", "", "APOLICE MENSAL SEM COBERTURA DESDE",
                                        "A ULTIMA FATURA NAO PAGA", "")
                            returning ws.confirma
          end if

        on key (interrupt)
           clear form
           exit input

    end input

    options insert key F1,
            delete key F2
 close c_cta01m06
 end if
 close window cta01m06


end function   #-- cta01m06


#----------------------------------------------------------------
 function endosso_cta01m06(param2)
#----------------------------------------------------------------

 define param2     record
    succod         like fctrpevparc.succod,
    ramcod         like fctrpevparc.ramcod,
    aplnumdig      like fctrpevparc.aplnumdig,
    edsnumdig      like fctrpevparc.edsnumdig
 end record

 define ws2        record
    edstipdes      char(40),
    dctnumseq      like abamdoc.dctnumseq,
    edstip         integer,
    sgrorg         like rsdmdocto.sgrorg,
    sgrnumdig      like rsdmdocto.sgrnumdig
 end record




	initialize  ws2.*  to  null

 initialize ws2.*   to null
 let ws2.edstipdes = "*** NAO ENCONTRADO ***"

 #----------------------------------------------------------------
 # Verifica tipo de endosso para apolices de automovel
 #----------------------------------------------------------------
 if param2.ramcod  =  31  or
    param2.ramcod  =  531 then

    select dctnumseq  into  ws2.dctnumseq
      from abamdoc
     where succod    = param2.succod      and
           aplnumdig = param2.aplnumdig   and
           edsnumdig = param2.edsnumdig

    if sqlca.sqlcode  =  0   then
       select max(edstip)
         into ws2.edstip
         from abbmdoc
        where succod    = param2.succod      and
              aplnumdig = param2.aplnumdig   and
              dctnumseq = ws2.dctnumseq

       if sqlca.sqlcode  =  0   then
          select edstipdes
            into ws2.edstipdes
            from agdktip
           where edstip = ws2.edstip
       end if
    end if
 else
    #----------------------------------------------------------------
    # Verifica tipo de endosso para apolices de R.E.
    #----------------------------------------------------------------
    select sgrorg, sgrnumdig
      into ws2.sgrorg, ws2.sgrnumdig
      from rsamseguro
     where succod    = param2.succod      and
           ramcod    = param2.ramcod      and
           aplnumdig = param2.aplnumdig

    if sqlca.sqlcode  =  0   then
       select edstip
         into ws2.edstip
         from rsdmdocto
        where sgrorg     =  ws2.sgrorg         and
              sgrnumdig  =  ws2.sgrnumdig      and
              edsnumdig  =  param2.edsnumdig   and
              prpstt     in (19,65,66,88)

       if sqlca.sqlcode  =  0   then
          if ws2.edstip  =  00   then
             let ws2.edstipdes = "APOLICE"
          else
             select edstipdes
               into ws2.edstipdes
               from rgdktip
              where edstip  =  ws2.edstip
          end if
       end if
    end if

 end if

 return  ws2.edstipdes

end function   #-- endosso_cta01m06
