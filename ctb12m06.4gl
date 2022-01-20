###############################################################################
# Nome do Modulo: CTB12M06                                           Marcelo  #
#                                                                    Gilberto #
# Acerta valor (custo) com prestador                                 Abr/1997 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctb12m06(param)
#-----------------------------------------------------------

 define param        record
   atdsrvnum         like datmservico.atdsrvnum ,
   atdsrvano         like datmservico.atdsrvano
 end record

 define d_ctb12m06   record
   srvinccst         like datmpreacp.srvinccst ,
   atdcstvlr         like datmservico.atdcstvlr ,
   confirma          char (01)
 end record

 define ws           record
   pgtdat            like datmservico.pgtdat   ,
   atdprscod         like datmservico.atdprscod,
   socopgnum         like dbsmopg.socopgnum    ,
   sqlca_preacp      integer
 end record

 let int_flag  =  false
 initialize d_ctb12m06.*  to null
 initialize ws.*          to null

#-----------------------------------------------------------
# Verifica se o servico ja' foi pago
#-----------------------------------------------------------

 select atdcstvlr, pgtdat , atdprscod
   into d_ctb12m06.atdcstvlr, ws.pgtdat, ws.atdprscod
   from datmservico
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 if sqlca.sqlcode <> 0   then
    error " Erro (", sqlca.sqlcode,") na leitura do servico. AVISE A INFORMATICA!"
    return
 end if

 if ws.atdprscod = 1  or
    ws.atdprscod = 4  or
    ws.atdprscod = 8  then
    error " Servico realizado pela Frota - Porto Seguro!"
    return
 end if

 select dbsmopg.socopgnum
   into ws.socopgnum
   from dbsmopgitm, dbsmopg
  where dbsmopgitm.atdsrvnum = param.atdsrvnum    and
        dbsmopgitm.atdsrvano = param.atdsrvano    and
        dbsmopgitm.socopgnum = dbsmopg.socopgnum  and
        dbsmopg.socopgsitcod <> 8

 if sqlca.sqlcode <> 0     and
    sqlca.sqlcode <> 100   then
    error " Erro (", sqlca.sqlcode, ") na leitura da O.P. AVISE A INFORMATICA!"
    return
 end if

 if ws.pgtdat     is not null   or
    ws.socopgnum  is not null   then
    error " Nao e' possivel fazer o acerto de valor para servico ja' pago!"
    return
 end if

 open window ctb12m06 at 14,47 with form "ctb12m06"
                         attribute (border, form line 1)

 select srvinccst
   into d_ctb12m06.srvinccst
   from datmpreacp
  where datmpreacp.atdsrvnum = param.atdsrvnum
    and datmpreacp.atdsrvano = param.atdsrvano

 let ws.sqlca_preacp = sqlca.sqlcode
 if  ws.sqlca_preacp <> 0 then
     let d_ctb12m06.srvinccst = 0
 end if
 display by name d_ctb12m06.srvinccst

 input by name d_ctb12m06.srvinccst,
               d_ctb12m06.atdcstvlr,
               d_ctb12m06.confirma without defaults

   before field srvinccst
      if d_ctb12m06.srvinccst is not null     and
         d_ctb12m06.srvinccst <> 0            then
         if d_ctb12m06.atdcstvlr  is not null or
            d_ctb12m06.atdcstvlr  <> 0        then
            next field atdcstvlr
         end if
      end if
      display by name d_ctb12m06.srvinccst attribute (reverse)

   after field srvinccst
      display by name d_ctb12m06.srvinccst

      if d_ctb12m06.srvinccst  is null   or
         d_ctb12m06.srvinccst  =  0.00   then
         error " Valor inicial deve ser informado!"
         next field srvinccst
      end if

   before field atdcstvlr
      display by name d_ctb12m06.atdcstvlr attribute (reverse)

   after field atdcstvlr
      display by name d_ctb12m06.atdcstvlr

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field srvinccst
      end if
      if d_ctb12m06.atdcstvlr  is null   or
         d_ctb12m06.atdcstvlr  =  0.00   then
         error " Valor final deve ser informado!"
         next field atdcstvlr
      end if

   before field confirma
      display by name d_ctb12m06.confirma  attribute (reverse)

   after field confirma
      display by name d_ctb12m06.confirma

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field atdcstvlr
      end if

      if d_ctb12m06.confirma   is null   or
         d_ctb12m06.confirma   =  " "    then
         error " Confirmacao e' obrigatoria!"
         next field confirma
      else
         if d_ctb12m06.confirma  <> "S"  and
            d_ctb12m06.confirma  <> "N"  then
            error " Confirmacao incorreta!"
            next field confirma
         end if
      end if

   on key (interrupt)
      exit input

 end input

 if int_flag = true  then
    close window ctb12m06
    return
 end if

 if d_ctb12m06.confirma = "S"  then
    update datmservico set atdcstvlr = d_ctb12m06.atdcstvlr
     where atdsrvnum = param.atdsrvnum  and
           atdsrvano = param.atdsrvano

    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na atualizacao do valor. AVISE A INFORMATICA!"
    else
       call cts00g07_apos_grvlaudo(param.atdsrvnum,param.atdsrvano)
    end if

    if ws.sqlca_preacp <> 0 then  # GRAVA CUSTO INICIAL
       insert into datmpreacp (atdsrvnum ,
                               atdsrvano ,
                               srvinccst ,
                               caddat    ,
                               usrtip    ,
                               cademp    ,
                               cadmat    )
                       values (param.atdsrvnum     ,
                               param.atdsrvano     ,
                               d_ctb12m06.srvinccst,
                               today               ,
                               g_issk.usrtip       ,
                               g_issk.empcod       ,
                               g_issk.funmat       )

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na atualizacao do valor inicial. AVISE A INFORMATICA!"
       end if
    end if
 end if

 let int_flag = false
 close window ctb12m06

end function  ###  ctb12m06
