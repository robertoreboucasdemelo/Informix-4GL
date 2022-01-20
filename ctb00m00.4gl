#---------------------------------------------------------------------------#
# 11/11/1998  PSI 6471-8   Gilberto     Alterar acesso as tabelas de lojas  #
#                                       e veiculos, que tiveram o campo     #
#                                       LCVCOD incluido na chave primaria.  #
#                                       Incluir campo EMPCOD na tabela      #
#                                       DBLMPAGTO (pagamentos de locacoes). #
#---------------------------------------------------------------------------#
# 10/02/1999  PSI 7669-4   Wagner       Data do calculo para saldo de dias  #
#                                       foi alterado de (data atendimento)  #
#                                       para (data do sinistro).            #
#---------------------------------------------------------------------------#
# 03/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
# Nome do Modulo: CTB00M00                                         Marcelo  #
#                                                                  Gilberto #
# Pagamento de locacao de veiculos (digitacao da capa)             Set/1996 #
#---------------------------------------------------------------------------#
# 11/11/1998  PSI 6471-8   Gilberto     Alterar acesso as tabelas de lojas  #
#                                       e veiculos, que tiveram o campo     #
#                                       LCVCOD incluido na chave primaria.  #
#                                       Incluir campo EMPCOD na tabela      #
#                                       DBLMPAGTO (pagamentos de locacoes). #
#---------------------------------------------------------------------------#
# 10/02/1999  PSI 7669-4   Wagner       Data do calculo para saldo de dias  #
#                                       foi alterado de (data atendimento)  #
#                                       para (data do sinistro).            #
#---------------------------------------------------------------------------#
# 03/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 11/11/1998  PSI 6471-8   Gilberto     Alterar acesso as tabelas de lojas  #
#                                       e veiculos, que tiveram o campo     #
#                                       LCVCOD incluido na chave primaria.  #
#                                       Incluir campo EMPCOD na tabela      #
#                                       DBLMPAGTO (pagamentos de locacoes). #
#---------------------------------------------------------------------------#
# 10/02/1999  PSI 7669-4   Wagner       Data do calculo para saldo de dias  #
#                                       foi alterado de (data atendimento)  #
#                                       para (data do sinistro).            #
#---------------------------------------------------------------------------#
# 03/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
#                                       para verificacao do servico.        #
#---------------------------------------------------------------------------#
# 25/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-  #
#                                       coes, com a utilizacao de funcoes.  #
#---------------------------------------------------------------------------#
# 02/12/1999  ** ERRO **   Gilberto     Corrigir a inclusao da reserva na   #
#                                       apolice, de forma a gravar tambem   #
#                                       as demais ligacoes relacionados ao  #
#                                       servico (reserva).                  #
#---------------------------------------------------------------------------#
# 10/12/1999  PSI 7263-0   Gilberto     Verificar se apolice foi emitida    #
#                                       para a proposta informada no ato da #
#                                       reserva do veiculo.                 #
#---------------------------------------------------------------------------#
# 27/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 16/03/2004 OSF 33367     Teresinha S. Inclusao de case ws.avialgmtv       #
#---------------------------------------------------------------------------#
# 16/12/2006  psi 205206   Alteracao para Azul Seguros                      #
# 06/06/2011  Projeto Carro Extra - alt na chamada de ctx01g00_saldo_novo
#---------------------------------------------------------------------------#
# 10/07/2013  Gabriel, Fornax P13070041  Inclusao da Variavel               #
#                                        param.avialgmtv na chamada         #
#                                        da funcao ctx01g01_claus_novo      #
#---------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

define g_privez  smallint

#-----------------------------------------------------------
 function ctb00m00()
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like dblmpagto.atdsrvnum    ,
    atdsrvano        like dblmpagto.atdsrvano
 end record

 if not get_niv_mod(g_issk.prgsgl, "ctb00m00") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 let g_privez = true

 open window ctb00m00 at 04,02 with form "ctb00m00"
                         attribute (form line 1, comment line last - 1)

 message " (F17)Abandona, (F6)Historico"

 menu "PAGAMENTOS"

    before menu
       hide option all
       if g_issk.acsnivcod >= g_issk.acsnivcns  then
          show option "Seleciona", "iTens", "Historico"
       end if

       if g_issk.acsnivcod >= g_issk.acsnivatl  then
          show option "Seleciona", "Inclui", "Modifica", "iTens", "Historico"
       end if

       show option "Encerra"

    command key ("S")  "Seleciona" "Seleciona pagamento de servico"
       clear form
       initialize param.*  to null

       call ctb00m00_selec("s",param.*) returning param.*

       if param.atdsrvnum is not null  and
          param.atdsrvano is not null  then
          call ctb00m00_exibe(param.*)
       end if

    command key ("I")  "Inclui"    "Inclui pagamento de servico"
       clear form
       initialize param.*  to null
       call ctb00m00_inclui(param.*)
       initialize param.*  to null

    command key ("M")  "Modifica"  "Modifica pagamento de servico"
       if param.atdsrvnum is not null  and
          param.atdsrvano is not null  then
          call ctb00m00_modifica(param.*)
          initialize param.*  to null
          next option "Seleciona"
       else
          error " Nenhum servico selecionado!"
          next option "Seleciona"
       end if

    command key ("T")  "iTens"     "Consulta itens excedentes"
       if param.atdsrvnum is not null  and
          param.atdsrvano is not null  then
          call ctb00m00_itens(param.*)
       else
          error " Nenhum servico selecionado!"
          next option "Seleciona"
       end if

    command key ("H")  "Historico" "Acesso ao historico do servico"
       if param.atdsrvnum is not null  and
          param.atdsrvano is not null  then
          call cts10n00(param.atdsrvnum, param.atdsrvano,
                        today, current , g_issk.funmat  )
       else
          error " Nenhum servico selecionado!"
          next option "Seleciona"
       end if

    command key ("E",interrupt)  "Encerra"  "Retorna ao menu anterior"
       exit menu

end menu

let int_flag = false
close window ctb00m00

end function  ###  ctb00m00

#-----------------------------------------------------------
 function ctb00m00_selec(param)
#-----------------------------------------------------------

 define param         record
    operacao          char (01)                 ,
    atdsrvnum         like dblmpagto.atdsrvnum  ,
    atdsrvano         like dblmpagto.atdsrvano
 end record

 define ws            record
    atdetpcod         like datmsrvacp.atdetpcod  ,
    atdsrvorg         like datmservico.atdsrvorg ,
    atddat            like datmservico.atddat    ,
    lignum            like datrligsrv.lignum     ,
    outlignum         like datrligsrv.lignum     ,
    atdfnlflg         like datmservico.atdfnlflg ,
    succod            like datrligapol.succod    ,
    ramcod            like datrligapol.ramcod    ,
    aplnumdig         like datrligapol.aplnumdig ,
    itmnumdig         like datrligapol.itmnumdig ,
    edsnumref         like datrligapol.edsnumref ,
    prporg            like datrligprp.prporg     ,
    prpnumdig         like datrligprp.prpnumdig  ,
    fcapacorg         like datrligpac.fcapacorg  ,
    fcapacnum         like datrligpac.fcapacnum  ,
    itaciacod         like datrligitaaplitm.itaciacod
 end record

 let int_flag = FALSE

 initialize ws.*        to null

   input by name param.atdsrvnum,
                 param.atdsrvano  without defaults

      before field atdsrvnum
         initialize ws.atdsrvorg to null
         display by name ws.atdsrvorg
         display by name param.atdsrvnum  attribute (reverse)

      after  field atdsrvnum
         display by name param.atdsrvnum

      before field atdsrvano
         display by name param.atdsrvano  attribute (reverse)

      after  field atdsrvano
         display by name param.atdsrvano

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdsrvnum
         end if

         if param.atdsrvano   is null      and
            param.atdsrvnum   is not null  then
            error " Informe o ano do servico!"
            next field atdsrvano
         end if

         if param.atdsrvano   is not null   and
            param.atdsrvnum   is null       then
            error " Informe o numero do servico!"
            next field atdsrvnum
         end if

         select atddat, atdsrvorg, atdfnlflg
           into ws.atddat, ws.atdsrvorg, ws.atdfnlflg
           from datmservico
          where atdsrvnum = param.atdsrvnum  and
                atdsrvano = param.atdsrvano

         if sqlca.sqlcode = notfound  then
            error " Servico de locacao nao cadastrado!"
            next field atdsrvnum
         end if

         if ws.atdsrvorg <> 8    then
            error " Servico nao e' uma LOCACAO!"
            next field atdsrvnum
         end if

         display by name ws.atdsrvorg

     #------------------------------------------------------------
     # Verifica etapa dos servicos
     #------------------------------------------------------------
     #   if ws.atdfnlflg is null  or
     #      ws.atdfnlflg <> "C"   then
     #      error " Nao e' possivel fazer um pagamento para uma locacao nao concluida!"
     #      next field atdsrvnum
     #   end if
         select atdetpcod
           into ws.atdetpcod
           from datmsrvacp
          where atdsrvnum = param.atdsrvnum
            and atdsrvano = param.atdsrvano
            and atdsrvseq = (select max(atdsrvseq)
                               from datmsrvacp
                              where atdsrvnum = param.atdsrvnum
                                and atdsrvano = param.atdsrvano)

         if ws.atdetpcod <> 4  then
            error " Nao e' possivel fazer um pagamento para uma locacao nao concluida!"
            next field atdsrvnum
         end if

        let ws.lignum = cts20g00_servico(param.atdsrvnum, param.atdsrvano)

        call cts20g01_docto(ws.lignum)
                  returning ws.succod,
                            ws.ramcod,
                            ws.aplnumdig,
                            ws.itmnumdig,
                            ws.edsnumref,
                            ws.prporg,
                            ws.prpnumdig,
                            ws.fcapacorg,
                            ws.fcapacnum,
                            ws.itaciacod

         if ws.succod    is null  or
            ws.ramcod    is null  or
            ws.aplnumdig is null  or
            ws.itmnumdig is null  or
            ws.edsnumref is null  then
            error " Locacao sem documento informado! Localize documento..."
            call ctb00m05 (ws.atddat, ws.prporg, ws.prpnumdig)
                 returning ws.succod,
                           ws.ramcod,
                           ws.aplnumdig,
                           ws.itmnumdig,
                           ws.edsnumref

            if ws.succod    is null  or
               ws.ramcod    is null  or
               ws.aplnumdig is null  or
               ws.itmnumdig is null  or
               ws.edsnumref is null  then
               error " Nao e' possivel fazer um pagamento para uma locacao sem documento informado!"
               next field atdsrvnum
            else
               BEGIN WORK
               insert into datrservapol ( succod   , ramcod   , aplnumdig,
                                          itmnumdig, edsnumref,
                                          atdsrvnum, atdsrvano)
                                 values ( ws.succod,
                                          ws.ramcod,
                                          ws.aplnumdig,
                                          ws.itmnumdig,
                                          ws.edsnumref,
                                          param.atdsrvnum     ,
                                          param.atdsrvano     )

               if sqlca.sqlcode <> 0  then
                  error " Erro (", sqlca.sqlcode, ") na gravacao do relacionamento Servico x Apolice. AVISE A INFORMATICA!"
                  rollback work
                  return
               end if

               declare c_datrligsrv cursor with hold for
                  select lignum from datrligsrv
                   where atdsrvnum = param.atdsrvnum
                     and atdsrvano = param.atdsrvano

               foreach c_datrligsrv into ws.lignum
                  insert into datrligapol ( succod   , ramcod   , aplnumdig,
                                            itmnumdig, edsnumref, lignum   )
                                   values ( ws.succod,
                                            ws.ramcod,
                                            ws.aplnumdig ,
                                            ws.itmnumdig ,
                                            ws.edsnumref ,
                                            ws.lignum           )

                  if sqlca.sqlcode <> 0  then
                     error " Erro (", sqlca.sqlcode, ") na gravacao do relacionamento Ligacao x Apolice. AVISE A INFORMATICA!"
                     rollback work
                     return
                  end if
               end foreach
               COMMIT WORK
            end if
         end if

         if param.operacao = "i"   or
            param.operacao = "s"   then
            select atdsrvnum from dblmpagto
             where atdsrvnum = param.atdsrvnum  and
                   atdsrvano = param.atdsrvano

            if sqlca.sqlcode  =  0   and
               param.operacao = "i"  then
               error " Ja' foi realizado pagamento para este servico!"
               next field atdsrvnum
            else
               if sqlca.sqlcode  = notfound  and
                  param.operacao = "s"       then
                  error " Nao foi realizado pagamento para este servico!"
                  initialize param.atdsrvnum, param.atdsrvano to null
                  clear form
                  exit input
               end if
            end if
         end if

      on key(interrupt)
         initialize param.* to null
         error " Operacao cancelada!"
         exit input

   end input

   return param.atdsrvnum, param.atdsrvano

end function  ###  ctb00m00_selec

#-----------------------------------------------------------
 function ctb00m00_exibe(param)
#-----------------------------------------------------------

 define param         record
    atdsrvnum         like dblmpagto.atdsrvnum    ,
    atdsrvano         like dblmpagto.atdsrvano
 end record

 define d_ctb00m00    record
    nfsnum            like dblmpagto.nfsnum       ,
    nfsvctdat         like dblmpagto.nfsvctdat    ,
    nfspgtdat         like dblmpagto.nfspgtdat    ,
    c24utidiaqtd      like dblmpagto.c24utidiaqtd ,
    c24pagdiaqtd      like dblmpagto.c24pagdiaqtd ,
    aviprvent         like datmavisrent.aviprvent ,
    vclalgdat         like datmavisrent.vclalgdat ,
    c24diaparvlr      like dblmpagto.c24diaparvlr ,
    c24diadifvlr      like dblmpagto.c24diaparvlr ,
    c24diatotvlr      like dblmpagto.c24diaparvlr ,
    cademp            like dblmpagto.cademp       ,
    cadmat            like dblmpagto.cadmat       ,
    funnom            like isskfunc.funnom        ,
    caddat            like dblmpagto.caddat       ,
    cadhor            like dblmpagto.cadhor
 end record

 define k_ctb00m00    record
    avilocnom         like datmavisrent.avilocnom ,
    gratuita          char (12)                   ,
    saldo             char (12)                   ,
    lcvextcod         like datkavislocal.lcvextcod,
    aviestnom         like datkavislocal.aviestnom,
    lcvlojdes         char (10)                   ,
    avivclgrp         like datkavisveic.avivclgrp ,
    descricao         char (40)                   ,
    motivo            char (12)
 end record

 define ws            record
    clscod            like abbmclaus.clscod        ,
    saldo             smallint                     ,
    lcvcod            like datklocadora.lcvcod     ,
    aviestcod         like datkavislocal.aviestcod ,
    avivclcod         like datkavisveic.avivclcod  ,
    avivcldes         like datkavisveic.avivcldes  ,
    avivclvlr         like datmavisrent.avivclvlr  ,
    aviretdat         like datmavisrent.aviretdat  ,
    locsegvlr         like datmavisrent.locsegvlr  ,
    lcvlojtip         like datkavislocal.lcvlojtip ,
    avialgmtv         like datmavisrent.avialgmtv  ,
    avioccdat         like datmavisrent.avioccdat  ,
    aviprodiaqtd      like datmprorrog.aviprodiaqtd,
    atdsrvorg         like datmservico.atdsrvorg   ,
    ciaempcod         like datmservico.ciaempcod
 end record

 select lcvcod   , aviestcod,
        avivclcod, avivclvlr,
        locsegvlr, avialgmtv,
        aviretdat, vclalgdat,
        aviprvent, avilocnom,
        avioccdat
   into ws.lcvcod   , ws.aviestcod,
        ws.avivclcod, ws.avivclvlr,
        ws.locsegvlr, ws.avialgmtv,
        ws.aviretdat,
        d_ctb00m00.vclalgdat      ,
        d_ctb00m00.aviprvent      ,
        k_ctb00m00.avilocnom      ,
        ws.avioccdat
   from datmavisrent
  where atdsrvnum = param.atdsrvnum    and
        atdsrvano = param.atdsrvano

 if d_ctb00m00.vclalgdat is null  then
    let d_ctb00m00.vclalgdat = ws.aviretdat
 end if

 select sum(aviprodiaqtd)
   into ws.aviprodiaqtd
   from datmprorrog
  where atdsrvnum = param.atdsrvnum   and
        atdsrvano = param.atdsrvano   and
        aviprostt = "A"

 if ws.aviprodiaqtd is null  then
    let ws.aviprodiaqtd = 0
 end if

 select ciaempcod
   into ws.ciaempcod
   from datmservico
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

 let d_ctb00m00.aviprvent = d_ctb00m00.aviprvent + ws.aviprodiaqtd

 call ctb02m06_motivo(ws.avialgmtv,ws.ciaempcod)
              returning k_ctb00m00.motivo

 select lcvextcod, aviestnom, lcvlojtip
   into k_ctb00m00.lcvextcod,
        k_ctb00m00.aviestnom,
        ws.lcvlojtip
   from datkavislocal
  where lcvcod    = ws.lcvcod    and
        aviestcod = ws.aviestcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na localizacao da LOJA. AVISE A INFORMATICA!"
    return
 end if

 case ws.lcvlojtip
    when 1 let k_ctb00m00.lcvlojdes = "CORPORACAO"
    when 2 let k_ctb00m00.lcvlojdes = "FRANQUIA"
 end case

 select avivclgrp, avivclmdl, avivcldes
   into k_ctb00m00.avivclgrp,
        k_ctb00m00.descricao,
        ws.avivcldes
   from datkavisveic
  where lcvcod    = ws.lcvcod   and
        avivclcod = ws.avivclcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na localizacao da VEICULO. AVISE A INFORMATICA!"
    return
 end if

 let k_ctb00m00.descricao = k_ctb00m00.descricao clipped, " ", ws.avivcldes

 initialize ws.saldo to null

 call ctb00m00_condicoes(param.atdsrvnum, param.atdsrvano,
                         k_ctb00m00.avivclgrp, ws.avialgmtv,
                         ws.avioccdat)
               returning k_ctb00m00.gratuita, ws.clscod, ws.saldo

 initialize k_ctb00m00.saldo to null

 if ws.avialgmtv = 1  and k_ctb00m00.avivclgrp = "A"  then
    if ws.saldo is not null  then
       let k_ctb00m00.saldo = "Saldo..:", ws.saldo using "###&"
    end if
 end if

 select atdsrvorg into ws.atdsrvorg
   from datmservico
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

 display by name k_ctb00m00.*
 if k_ctb00m00.gratuita is not null  then
    display by name k_ctb00m00.gratuita attribute (reverse)
 end if
 display by name ws.atdsrvorg

 select nfsnum, nfsvctdat, nfspgtdat,
        c24utidiaqtd, c24pagdiaqtd,
        c24diaparvlr, cademp ,
        cadmat, caddat, cadhor
   into d_ctb00m00.nfsnum      ,
        d_ctb00m00.nfsvctdat   ,
        d_ctb00m00.nfspgtdat   ,
        d_ctb00m00.c24utidiaqtd,
        d_ctb00m00.c24pagdiaqtd,
        d_ctb00m00.c24diaparvlr,
        d_ctb00m00.cademp      ,
        d_ctb00m00.cadmat      ,
        d_ctb00m00.caddat      ,
        d_ctb00m00.cadhor
   from dblmpagto
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 if sqlca.sqlcode = 0 then
   let d_ctb00m00.funnom = "** NAO CADASTRADO **"

    select funnom
      into d_ctb00m00.funnom
      from isskfunc
     where empcod = d_ctb00m00.cademp  and
           funmat = d_ctb00m00.cadmat

    let d_ctb00m00.funnom = upshift(d_ctb00m00.funnom)

    select sum(c24pgtitmvlr)
      into d_ctb00m00.c24diadifvlr
      from dblmpagitem
     where atdsrvnum = param.atdsrvnum  and
           atdsrvano = param.atdsrvano

    if d_ctb00m00.c24diadifvlr is null then
       let d_ctb00m00.c24diadifvlr = 0
    end if

    if d_ctb00m00.c24diadifvlr = 0     then
       let d_ctb00m00.c24diatotvlr = d_ctb00m00.c24diaparvlr
    else
       let d_ctb00m00.c24diatotvlr =
           d_ctb00m00.c24diaparvlr + d_ctb00m00.c24diadifvlr
    end if
 end if

 display by name k_ctb00m00.*
 if k_ctb00m00.gratuita is not null  then
    display by name k_ctb00m00.gratuita attribute (reverse)
 end if
 display by name d_ctb00m00.*

end function  ###  ctb00m00_exibe

#-----------------------------------------------------------
 function ctb00m00_inclui(param)
#-----------------------------------------------------------

 define param         record
    atdsrvnum         like dblmpagto.atdsrvnum    ,
    atdsrvano         like dblmpagto.atdsrvano
 end record

 define d_ctb00m00    record
    nfsnum            like dblmpagto.nfsnum       ,
    nfsvctdat         like dblmpagto.nfsvctdat    ,
    nfspgtdat         like dblmpagto.nfspgtdat    ,
    c24utidiaqtd      like dblmpagto.c24utidiaqtd ,
    c24pagdiaqtd      like dblmpagto.c24pagdiaqtd ,
    aviprvent         like datmavisrent.aviprvent ,
    vclalgdat         like datmavisrent.vclalgdat ,
    c24diaparvlr      like dblmpagto.c24diaparvlr ,
    c24diadifvlr      like dblmpagto.c24diaparvlr ,
    c24diatotvlr      like dblmpagto.c24diaparvlr ,
    cademp            like dblmpagto.cademp       ,
    cadmat            like dblmpagto.cadmat       ,
    funnom            like isskfunc.funnom        ,
    caddat            like dblmpagto.caddat       ,
    cadhor            like dblmpagto.cadhor
 end record

 define ws            record
    succod            like datrservapol.succod    ,
    aplnumdig         like datrservapol.aplnumdig ,
    itmnumdig         like datrservapol.itmnumdig ,
    sqlcode           integer
 end record

 initialize d_ctb00m00.* to null

 call ctb00m00_selec("i",param.*) returning param.*

 if param.atdsrvnum is null  or
    param.atdsrvano is null  then
    clear form
    return
 end if

 call ctb00m00_input("i", param.*, d_ctb00m00.*)
      returning d_ctb00m00.*

 if d_ctb00m00.cadmat is null  then
    clear form
    return
 end if

 if d_ctb00m00.c24diadifvlr = 0  then
    BEGIN WORK
    call ctb00m00_grava("i"                    ,
                        param.atdsrvnum        ,
                        param.atdsrvano        ,
                        d_ctb00m00.nfsnum      ,
                        d_ctb00m00.nfsvctdat   ,
                        d_ctb00m00.nfspgtdat   ,
                        d_ctb00m00.c24utidiaqtd,
                        d_ctb00m00.c24pagdiaqtd,
                        d_ctb00m00.c24diaparvlr,
                        d_ctb00m00.cademp      ,
                        d_ctb00m00.cadmat      ,
                        d_ctb00m00.caddat      ,
                        d_ctb00m00.cadhor      ,
                        d_ctb00m00.vclalgdat   )
              returning ws.sqlcode

    if ws.sqlcode <> 0  then
       rollback work
       return
    end if
    COMMIT WORK
 else
    call ctb00m01("i"                    ,
                  param.atdsrvnum        ,
                  param.atdsrvano        ,
                  d_ctb00m00.nfsnum      ,
                  d_ctb00m00.nfsvctdat   ,
                  d_ctb00m00.nfspgtdat   ,
                  d_ctb00m00.c24utidiaqtd,
                  d_ctb00m00.c24pagdiaqtd,
                  d_ctb00m00.c24diaparvlr,
                  d_ctb00m00.c24diatotvlr,
                  d_ctb00m00.cademp      ,
                  d_ctb00m00.cadmat      ,
                  d_ctb00m00.caddat      ,
                  d_ctb00m00.cadhor      ,
                  d_ctb00m00.vclalgdat   )
 end if

 call cts10n00(param.atdsrvnum  , param.atdsrvano  , d_ctb00m00.cadmat,
               d_ctb00m00.caddat, d_ctb00m00.cadhor)

 error " Pagamento efetuado com sucesso!"
 clear form

end function  ###  ctb00m00_inclui

#-----------------------------------------------------------
 function ctb00m00_modifica(param)
#-----------------------------------------------------------

 define param         record
    atdsrvnum         like dblmpagto.atdsrvnum    ,
    atdsrvano         like dblmpagto.atdsrvano
 end record

 define d_ctb00m00    record
    nfsnum            like dblmpagto.nfsnum       ,
    nfsvctdat         like dblmpagto.nfsvctdat    ,
    nfspgtdat         like dblmpagto.nfspgtdat    ,
    c24utidiaqtd      like dblmpagto.c24utidiaqtd ,
    c24pagdiaqtd      like dblmpagto.c24pagdiaqtd ,
    aviprvent         like datmavisrent.aviprvent ,
    vclalgdat         like datmavisrent.vclalgdat ,
    c24diaparvlr      like dblmpagto.c24diaparvlr ,
    c24diadifvlr      like dblmpagto.c24diaparvlr ,
    c24diatotvlr      like dblmpagto.c24diaparvlr ,
    cademp            like dblmpagto.cademp       ,
    cadmat            like dblmpagto.cadmat       ,
    funnom            like isskfunc.funnom        ,
    caddat            like dblmpagto.caddat       ,
    cadhor            like dblmpagto.cadhor
 end record

 define ws            record
    succod            like datrservapol.succod    ,
    aplnumdig         like datrservapol.aplnumdig ,
    itmnumdig         like datrservapol.itmnumdig ,
    sqlcode           integer
 end record

 call ctb00m00_input("a", param.*, d_ctb00m00.*)
      returning d_ctb00m00.*

 if d_ctb00m00.cadmat is null  then
    clear form
    return
 end if

 if d_ctb00m00.c24diadifvlr = 0  then
    BEGIN WORK
    call ctb00m00_grava("a"                    ,
                        param.atdsrvnum        ,
                        param.atdsrvano        ,
                        d_ctb00m00.nfsnum      ,
                        d_ctb00m00.nfsvctdat   ,
                        d_ctb00m00.nfspgtdat   ,
                        d_ctb00m00.c24utidiaqtd,
                        d_ctb00m00.c24pagdiaqtd,
                        d_ctb00m00.c24diaparvlr,
                        d_ctb00m00.cademp      ,
                        d_ctb00m00.cadmat      ,
                        d_ctb00m00.caddat      ,
                        d_ctb00m00.cadhor      ,
                        d_ctb00m00.vclalgdat   )
              returning ws.sqlcode

    if ws.sqlcode <> 0  then
       rollback work
       return
    end if

    if d_ctb00m00.c24diatotvlr = d_ctb00m00.c24diaparvlr  then
       delete from dblmpagitem
        where atdsrvnum = param.atdsrvnum  and
              atdsrvano = param.atdsrvano

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na eliminacao da diferenca (itens). AVISE A INFORMATICA!"
          rollback work
          return
       end if
    end if

    COMMIT WORK
 else
    call ctb00m01("a"                    ,
                  param.atdsrvnum        ,
                  param.atdsrvano        ,
                  d_ctb00m00.nfsnum      ,
                  d_ctb00m00.nfsvctdat   ,
                  d_ctb00m00.nfspgtdat   ,
                  d_ctb00m00.c24utidiaqtd,
                  d_ctb00m00.c24pagdiaqtd,
                  d_ctb00m00.c24diaparvlr,
                  d_ctb00m00.c24diatotvlr,
                  d_ctb00m00.cademp      ,
                  d_ctb00m00.cadmat      ,
                  d_ctb00m00.caddat      ,
                  d_ctb00m00.cadhor      ,
                  d_ctb00m00.vclalgdat   )
 end if

 call cts10n00(param.atdsrvnum  , param.atdsrvano  , d_ctb00m00.cadmat,
               d_ctb00m00.caddat, d_ctb00m00.cadhor)

 error " Alteracao efetuada com sucesso!"
 clear form

end function  ###  ctb00m00_modifica

#-----------------------------------------------------------
 function ctb00m00_input(param, d_ctb00m00)
#-----------------------------------------------------------

 define param         record
    operacao          char (01)                   ,
    atdsrvnum         like dblmpagto.atdsrvnum    ,
    atdsrvano         like dblmpagto.atdsrvano
 end record

 define d_ctb00m00    record
    nfsnum            like dblmpagto.nfsnum       ,
    nfsvctdat         like dblmpagto.nfsvctdat    ,
    nfspgtdat         like dblmpagto.nfspgtdat    ,
    c24utidiaqtd      like dblmpagto.c24utidiaqtd ,
    c24pagdiaqtd      like dblmpagto.c24pagdiaqtd ,
    aviprvent         like datmavisrent.aviprvent ,
    vclalgdat         like datmavisrent.vclalgdat ,
    c24diaparvlr      like dblmpagto.c24diaparvlr ,
    c24diadifvlr      like dblmpagto.c24diaparvlr ,
    c24diatotvlr      like dblmpagto.c24diaparvlr ,
    cademp            like dblmpagto.cademp       ,
    cadmat            like dblmpagto.cadmat       ,
    funnom            like isskfunc.funnom        ,
    caddat            like dblmpagto.caddat       ,
    cadhor            like dblmpagto.cadhor
 end record

 define k_ctb00m00    record
    avilocnom         like datmavisrent.avilocnom ,
    gratuita          char (12)                   ,
    saldo             char (12)                   ,
    lcvextcod         like datkavislocal.lcvextcod,
    aviestnom         like datkavislocal.aviestnom,
    lcvlojdes         char (10)                   ,
    avivclgrp         like datkavisveic.avivclgrp ,
    descricao         char (40)                   ,
    motivo            char (12)
 end record

 define ws            record
    saldo             smallint                     ,
    clscod            like abbmclaus.clscod        ,
    ctsopc            like ssamcts.ctsopc          ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,
    prporg            like datmavisrent.prporg     ,
    prpnumdig         like datmavisrent.prpnumdig  ,
    avioccdat         like datmavisrent.avioccdat  ,
    lcvcod            like datklocadora.lcvcod     ,
    aviestcod         like datkavislocal.aviestcod ,
    avivclcod         like datkavisveic.avivclcod  ,
    avivcldes         like datkavisveic.avivcldes  ,
    aviretdat         like datmavisrent.aviretdat  ,
    avivclvlr         like datmavisrent.avivclvlr  ,
    locsegvlr         like datmavisrent.locsegvlr  ,
    lcvlojtip         like datkavislocal.lcvlojtip ,
    avialgmtv         like datmavisrent.avialgmtv  ,
    aviprodiaqtd      like datmprorrog.aviprodiaqtd,
    confirma          char (01)                    ,
    ciaempcod         like datmservico.ciaempcod
 end record

 select lcvcod   , aviestcod,
        avivclcod, avivclvlr,
        locsegvlr, avialgmtv,
        aviretdat, vclalgdat,
        aviprvent, avilocnom,
        avioccdat, prporg   ,
        prpnumdig
   into ws.lcvcod   , ws.aviestcod,
        ws.avivclcod, ws.avivclvlr,
        ws.locsegvlr, ws.avialgmtv,
        ws.aviretdat,
        d_ctb00m00.vclalgdat      ,
        d_ctb00m00.aviprvent      ,
        k_ctb00m00.avilocnom      ,
        ws.avioccdat              ,
        ws.prporg   , ws.prpnumdig
   from datmavisrent
  where atdsrvnum = param.atdsrvnum    and
        atdsrvano = param.atdsrvano

 if d_ctb00m00.vclalgdat is null  then
    let d_ctb00m00.vclalgdat = ws.aviretdat
 end if

 select sum(aviprodiaqtd)
   into ws.aviprodiaqtd
   from datmprorrog
  where atdsrvnum = param.atdsrvnum   and
        atdsrvano = param.atdsrvano   and
        aviprostt = "A"

 if ws.aviprodiaqtd is null  then
    let ws.aviprodiaqtd = 0
 end if

 let d_ctb00m00.aviprvent = d_ctb00m00.aviprvent + ws.aviprodiaqtd

 select succod, aplnumdig, itmnumdig
   into ws.succod   ,
        ws.aplnumdig,
        ws.itmnumdig
   from datrservapol
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 select ciaempcod
   into ws.ciaempcod
   from datmservico
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

  call ctb02m06_motivo(ws.avialgmtv,ws.ciaempcod)
              returning k_ctb00m00.motivo

 select lcvextcod, aviestnom, lcvlojtip
   into k_ctb00m00.lcvextcod,
        k_ctb00m00.aviestnom,
        ws.lcvlojtip
   from datkavislocal
  where lcvcod    = ws.lcvcod   and
        aviestcod = ws.aviestcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na localizacao da LOJA. AVISE A INFORMATICA!"
    return
 end if

 case ws.lcvlojtip
    when 1 let k_ctb00m00.lcvlojdes = "CORPORACAO"
    when 2 let k_ctb00m00.lcvlojdes = "FRANQUIA"
 end case

 select avivclgrp, avivclmdl, avivcldes
   into k_ctb00m00.avivclgrp,
        k_ctb00m00.descricao,
        ws.avivcldes
   from datkavisveic
  where lcvcod    = ws.lcvcod  and
        avivclcod = ws.avivclcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na localizacao da VEICULO. AVISE A INFORMATICA!"
    return
 end if

 let k_ctb00m00.descricao = k_ctb00m00.descricao clipped, " ",
                            ws.avivcldes

 initialize ws.saldo to null

 call ctb00m00_condicoes(param.atdsrvnum, param.atdsrvano,
                         k_ctb00m00.avivclgrp, ws.avialgmtv,
                         ws.avioccdat)
               returning k_ctb00m00.gratuita, ws.clscod, ws.saldo

 initialize k_ctb00m00.saldo to null

 if ws.avialgmtv = 1 and k_ctb00m00.avivclgrp = "A"  then
    if ws.saldo is not null  then
       let k_ctb00m00.saldo = "Saldo..:", ws.saldo using "###&"
    end if
 end if

 display by name k_ctb00m00.*
 if k_ctb00m00.gratuita is not null  then
    display by name k_ctb00m00.gratuita attribute (reverse)
 end if

 select nfsnum, nfsvctdat, nfspgtdat,
        c24utidiaqtd, c24pagdiaqtd,
        c24diaparvlr, cademp, cadmat,
        caddat, cadhor
   into d_ctb00m00.nfsnum      ,
        d_ctb00m00.nfsvctdat   ,
        d_ctb00m00.nfspgtdat   ,
        d_ctb00m00.c24utidiaqtd,
        d_ctb00m00.c24pagdiaqtd,
        d_ctb00m00.c24diaparvlr,
        d_ctb00m00.cademp      ,
        d_ctb00m00.cadmat      ,
        d_ctb00m00.caddat      ,
        d_ctb00m00.cadhor
   from dblmpagto
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 if sqlca.sqlcode = 0 then
    let d_ctb00m00.funnom = "** NAO CADASTRADO! **"

    select funnom
      into d_ctb00m00.funnom
      from isskfunc
     where empcod = d_ctb00m00.cademp  and
           funmat = d_ctb00m00.cadmat

    let d_ctb00m00.funnom = upshift(d_ctb00m00.funnom)

    select sum(c24pgtitmvlr)
      into d_ctb00m00.c24diadifvlr
      from dblmpagitem
     where atdsrvnum = param.atdsrvnum  and
           atdsrvano = param.atdsrvano

    if d_ctb00m00.c24diadifvlr is null then
       let d_ctb00m00.c24diadifvlr = 0
    end if

    if d_ctb00m00.c24diadifvlr = 0     then
       let d_ctb00m00.c24diatotvlr = d_ctb00m00.c24diaparvlr
    else
       let d_ctb00m00.c24diatotvlr =
           d_ctb00m00.c24diaparvlr + d_ctb00m00.c24diadifvlr
    end if
 end if

 if d_ctb00m00.nfspgtdat  <  today  then
    error " Nao e' possivel realizar alteracoes em um pagamento ja' realizado!"
    initialize param.operacao to null
    initialize d_ctb00m00.*   to null
 end if

#-------------------------------------------------------------------
# Verifica opcao (Carro Extra/Desc.20%) em caso de BENEF.OFICINA
#-------------------------------------------------------------------

 if (ws.avialgmtv = 3  or
    ws.avialgmtv = 6)  and
    ws.ciaempcod <> 35 and  ws.ciaempcod <> 84 then -- OSSF 33367
    call ossaa009_ultima_opc(ws.succod, ws.aplnumdig, ws.itmnumdig,
                             ws.prporg, ws.prpnumdig, ws.avioccdat)
                   returning ws.ctsopc

    if ws.ctsopc = "F"  then
       call cts08g01("A","N","SEGURADO OPTOU POR DESCONTO","DE 20% NA FRANQUIA.","","SOLICITE COBRANCA DAS DIARIAS!") returning ws.confirma
    end if
 end if

 input by name d_ctb00m00.*   without defaults

      before field nfsnum
         if param.operacao is null  then
            exit input
         end if
         display by name d_ctb00m00.nfsnum     attribute (reverse)

      after  field nfsnum
         display by name d_ctb00m00.nfsnum

         if d_ctb00m00.nfsnum     is null   then
            error " Nao e' possivel realizar pagamento sem numero de Nota Fiscal!"
            next field nfsnum
         end if

      before field nfsvctdat
         display by name d_ctb00m00.nfsvctdat  attribute (reverse)

      after  field nfsvctdat
         display by name d_ctb00m00.nfsvctdat

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field nfsnum
         end if

         if d_ctb00m00.nfsvctdat   is null     then
            error " Data de vencimento da Nota Fiscal deve ser informada!"
            next field nfsvctdat
         end if

         if d_ctb00m00.nfsvctdat   <  today    then
            call cts08g01("A","N","","NOTA FISCAL JA'","VENCIDA!","")
                 returning ws.confirma
         end if

      before field nfspgtdat
         display by name d_ctb00m00.nfspgtdat  attribute (reverse)

      after  field nfspgtdat
         display by name d_ctb00m00.nfspgtdat

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field nfsvctdat
         end if

         if d_ctb00m00.nfspgtdat   is null     then
            error " Data de pagamento da Nota Fiscal deve ser informada!"
            next field nfspgtdat
         end if

         if d_ctb00m00.nfspgtdat  <  today     then
            error " ATENCAO! Pagamento em atraso!"
            next field nfspgtdat
         end if

      before field c24utidiaqtd
         display by name d_ctb00m00.aviprvent
         display by name d_ctb00m00.c24utidiaqtd attribute (reverse)

      after  field c24utidiaqtd
         display by name d_ctb00m00.c24utidiaqtd

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field nfspgtdat
         end if

         if d_ctb00m00.c24utidiaqtd is null    then
            error " Quantidade de diarias utilizadas deve ser informada!"
            next field c24utidiaqtd
         end if

         if d_ctb00m00.c24utidiaqtd  <  1      then
            error " Quantidade de diarias utilizadas deve ser maior que ZERO!"
            next field c24utidiaqtd
         end if

      before field c24pagdiaqtd
         display by name d_ctb00m00.c24pagdiaqtd attribute (reverse)

      after  field c24pagdiaqtd
         display by name d_ctb00m00.c24pagdiaqtd

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field c24utidiaqtd
         end if

         if d_ctb00m00.c24pagdiaqtd is null    then
            error " Quantidade de diarias a serem pagas deve ser informada!"
            next field c24pagdiaqtd
         end if

         if d_ctb00m00.c24pagdiaqtd > d_ctb00m00.c24utidiaqtd  then
            error " Quant. de diarias a serem pagas nao pode ser maior que quantidade utilizada!"
            next field c24pagdiaqtd
         end if

       #------------------------------------------------------
       # Alterado em 18/02/97 por Gilberto conforme PSI 2458-9
       #------------------------------------------------------
         if ws.avialgmtv = 9  and
            d_ctb00m00.c24pagdiaqtd > 0  then
            error " Nao ha' pagamento de diarias para locacao espontanea!"
            next field c24pagdiaqtd
         end if
       #------------------------------------------------------

         if ws.locsegvlr is null  then
            let ws.locsegvlr = 0.00
         end if

         if param.operacao <> "a"  then
            let d_ctb00m00.c24diaparvlr = d_ctb00m00.c24pagdiaqtd * (ws.avivclvlr + ws.locsegvlr)
         end if

      before field vclalgdat
         display by name d_ctb00m00.vclalgdat  attribute (reverse)

      after  field vclalgdat
         display by name d_ctb00m00.vclalgdat

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field c24pagdiaqtd
         end if

         if d_ctb00m00.vclalgdat   is null     then
            error " Data de retirada do veiculo na loja deve ser informada!"
            next field vclalgdat
         end if

         if d_ctb00m00.vclalgdat  >  today     then
            error " Data de retirada do veiculo nao pode ser maior que hoje!"
            next field vclalgdat
         end if

      before field c24diaparvlr
         display by name d_ctb00m00.c24diaparvlr attribute (reverse)

      after  field c24diaparvlr
         display by name d_ctb00m00.c24diaparvlr

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field vclalgdat
         end if

         if d_ctb00m00.c24diaparvlr is null    or
            d_ctb00m00.c24diaparvlr < 0        then
            error " Valor parcial nao pode ser menor que ZERO!"
            next field c24diaparvlr
         end if

      before field c24diatotvlr
         display by name d_ctb00m00.c24diatotvlr attribute (reverse)

      after  field c24diatotvlr
         display by name d_ctb00m00.c24diatotvlr

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field c24diaparvlr
         end if

#        if d_ctb00m00.c24diatotvlr is null    or
#           d_ctb00m00.c24diatotvlr <  0       then
#           error " Valor total nao pode ser menor que ZERO!"
#           next field c24diatotvlr
#        end if
#
#        if d_ctb00m00.c24diatotvlr < d_ctb00m00.c24diaparvlr  then
#           error " Valor total nao pode ser menor que o valor parcial!"
#           next field c24diatotvlr
#        end if

         let d_ctb00m00.c24diadifvlr =
             d_ctb00m00.c24diatotvlr - d_ctb00m00.c24diaparvlr

         let d_ctb00m00.cademp = g_issk.empcod
         let d_ctb00m00.cadmat = g_issk.funmat

         let d_ctb00m00.funnom = "** NAO CADASTRADO! **"

         select funnom into d_ctb00m00.funnom
           from isskfunc
          where empcod = d_ctb00m00.cademp
            and funmat = d_ctb00m00.cadmat

         let d_ctb00m00.funnom = upshift(d_ctb00m00.funnom)

         let d_ctb00m00.caddat = today
         let d_ctb00m00.cadhor = current

         display by name d_ctb00m00.c24diadifvlr
         display by name d_ctb00m00.cademp
         display by name d_ctb00m00.cadmat
         display by name d_ctb00m00.funnom
         display by name d_ctb00m00.caddat
         display by name d_ctb00m00.cadhor

      on key(interrupt)
         initialize d_ctb00m00.* to null
         error " Operacao cancelada!"
         exit input

      on key(F6)
         if param.atdsrvnum is not null  and
            param.atdsrvano is not null  then
            call cts10n00(param.atdsrvnum  , param.atdsrvano, d_ctb00m00.cadmat,
                          d_ctb00m00.caddat, d_ctb00m00.cadhor)
         end if
         continue input
 end input

return d_ctb00m00.*

end function  ###  ctb00m00_input

#-----------------------------------------------------------
 function ctb00m00_grava(param)
#-----------------------------------------------------------

 define param         record
    operacao          char (01)                   ,
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    nfsnum            like dblmpagto.nfsnum       ,
    nfsvctdat         like dblmpagto.nfsvctdat    ,
    nfspgtdat         like dblmpagto.nfspgtdat    ,
    c24utidiaqtd      like dblmpagto.c24utidiaqtd ,
    c24pagdiaqtd      like dblmpagto.c24pagdiaqtd ,
    c24diaparvlr      like dblmpagto.c24diaparvlr ,
    cademp            like dblmpagto.cademp       ,
    cadmat            like dblmpagto.cadmat       ,
    caddat            like dblmpagto.caddat       ,
    cadhor            like dblmpagto.cadhor       ,
    vclalgdat         like datmavisrent.vclalgdat
 end record

 if param.operacao = "i"  then
    insert into dblmpagto (atdsrvnum   , atdsrvano   ,
                           nfsnum      , nfsvctdat   ,
                           nfspgtdat   , c24utidiaqtd,
                           c24pagdiaqtd, c24diaparvlr,
                           cademp      , cadmat      ,
                           caddat      , cadhor      )
                   values (param.atdsrvnum   ,
                           param.atdsrvano   ,
                           param.nfsnum      ,
                           param.nfsvctdat   ,
                           param.nfspgtdat   ,
                           param.c24utidiaqtd,
                           param.c24pagdiaqtd,
                           param.c24diaparvlr,
                           param.cademp      ,
                           param.cadmat      ,
                           param.caddat      ,
                           param.cadhor      )

    if sqlca.sqlcode <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao do pagamento. AVISE A INFORMATICA! "
       return sqlca.sqlcode
    end if
 else
    update dblmpagto set (nfsnum      , nfsvctdat   ,
                          nfspgtdat   , c24utidiaqtd,
                          c24pagdiaqtd, c24diaparvlr,
                          cademp, cadmat, caddat, cadhor)
                       = (param.nfsnum      , param.nfsvctdat   ,
                          param.nfspgtdat   , param.c24utidiaqtd,
                          param.c24pagdiaqtd, param.c24diaparvlr,
                          param.cademp      , param.cadmat      ,
                          param.caddat      , param.cadhor      )
                    where atdsrvnum = param.atdsrvnum    and
                          atdsrvano = param.atdsrvano

    if sqlca.sqlcode <>  0  then
       error " Erro (", sqlca.sqlcode, ") na atualizacao do pagamento. AVISE A INFORMATICA! "
       return sqlca.sqlcode
    end if
 end if

 update datmavisrent set vclalgdat = param.vclalgdat
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 if sqlca.sqlcode <>  0  then
    error " Erro (", sqlca.sqlcode, ") na atualizacao da reserva. AVISE A INFORMATICA! "
    return sqlca.sqlcode
 end if

 return sqlca.sqlcode

 end function  ###  ctb00m00_grava

#-----------------------------------------------------------
 function ctb00m00_condicoes(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum  ,
    atdsrvano        like datmservico.atdsrvano  ,
    avivclgrp        like datkavisveic.avivclgrp ,
    avialgmtv        like datmavisrent.avialgmtv ,
    avioccdat        like datmavisrent.avioccdat
 end record

 define ws           record
    saldo            smallint  ,
    limite           smallint  ,
    condicao         char (25) ,
    clscod           like abbmclaus.clscod      ,
    viginc           like abbmclaus.viginc      ,
    vigfnl           like abbmclaus.vigfnl      ,
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    atddat           like datmservico.atddat    ,
    datasaldo        date                       ,
    ciaempcod        like datmservico.ciaempcod ,
    temcls           smallint,
    c24astcod        like datmligacao.c24astcod
 end record

 initialize ws.*   to null

 select succod   , aplnumdig   , itmnumdig, atddat, datmservico.ciaempcod,
        datmligacao.c24astcod
   into ws.succod, ws.aplnumdig,
        ws.itmnumdig, ws.atddat, ws.ciaempcod, ws.c24astcod
   from datmservico, datrservapol, datmligacao
  where datmservico.atdsrvnum  = param.atdsrvnum        and
        datmservico.atdsrvano  = param.atdsrvano        and
        datrservapol.atdsrvnum = datmservico.atdsrvnum  and
        datrservapol.atdsrvano = datmservico.atdsrvano  and
        datmligacao.atdsrvano = datmservico.atdsrvano  and
        datmligacao.atdsrvnum = datmservico.atdsrvnum  and
        datmligacao.c24astcod not in ("ALT", "CON", "CAN","RET")

 if sqlca.sqlcode <> 0  then
    return ws.condicao, ws.clscod, ws.saldo
 end if

#-----------------------------------------------------------
# Verifica existencia da clausula Carro Extra
#-----------------------------------------------------------
 let ws.datasaldo = ws.atddat
 if param.avialgmtv  =  1   then
    let ws.datasaldo = param.avioccdat
 end if

 if ws.ciaempcod =  35 then
    call cts44g01_claus_azul(ws.succod   ,
                             531                 ,
                             ws.aplnumdig,
                             ws.itmnumdig)
           returning ws.temcls,ws.clscod
 else
    call ctx01g01_claus_novo(ws.succod, ws.aplnumdig, ws.itmnumdig,
                        ws.datasaldo, true, param.avialgmtv)
           returning ws.clscod, ws.viginc, ws.vigfnl
 end if
 if param.avialgmtv  =  1   and
    ws.clscod  is not null  then
    if ws.clscod[1,2] = "26"  or
       ws.clscod[1,2] = "80"  or
       ws.clscod[1,2] = "58"  then   # azul
       let ws.condicao = "CLAUSULA ", ws.clscod
    end if
 else
    if param.avialgmtv = 1   or
       param.avialgmtv = 2   then
       if param.avivclgrp = "A"  then
          let ws.condicao  = "1a. GRATUITA"
       end if
    end if
 end if

 if ws.clscod[1,2] = "26"  or
    ws.clscod[1,2] = "80"  or
    ws.clscod[1,2] = "58"  then
    call ctx01g00_saldo_novo(ws.succod      ,
                        ws.aplnumdig   ,
                        ws.itmnumdig   ,
                        param.atdsrvnum,
                        param.atdsrvano,
                        ws.datasaldo, 2,
                        g_privez    ,
                        ws.ciaempcod ,
                        param.avialgmtv,
                        ws.c24astcod)
              returning ws.limite, ws.saldo

    if g_privez = true  then
       let g_privez = false
    end if

    if ws.saldo > 0  then
    else
       let ws.condicao  = "1a. GRATUITA"
       initialize ws.saldo to null
    end if
 end if

 return ws.condicao, ws.clscod, ws.saldo

end function  ###  ctb00m00_condicoes

#-----------------------------------------------------------
 function ctb00m00_itens(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum  ,
    atdsrvano        like datmservico.atdsrvano
 end record

 declare c_itens cursor for
    select atdsrvnum from dblmpagitem
     where atdsrvnum = param.atdsrvnum   and
           atdsrvano = param.atdsrvano

 open  c_itens
 fetch c_itens

 if sqlca.sqlcode = 0  then
    call ctb00m01("",param.atdsrvnum, param.atdsrvano,
                  "","","","","","","","","","","","")
 else
    error " Nao ha' nenhum excedente de valor para este pagamento!"
 end if

 close c_itens

end function  ###  ctb00m00_itens
