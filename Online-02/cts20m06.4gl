###############################################################################
# Nome do Modulo: CTS20M06                                           Gilberto #
#                                                                     Marcelo #
# Laudo Remocoes - Exibe informacoes sobre ultimo sinistro aberto    Jan/1997 #
###############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 25/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-  #
#                                       coes, com a utilizacao de funcoes.  #
#############################################################################


database porto

#-----------------------------------------------------------
 function cts20m06(param)
#-----------------------------------------------------------

 define param          record
    atdsrvnum          like datmservico.atdsrvnum,
    atdsrvano          like datmservico.atdsrvano
 end record

 define d_cts20m06     record
    atddat             like datmservico.atddat,
    sindat             like datmservicocmp.sindat,
    sinhor             like datmservicocmp.sinhor,
    orrdat             like ssamsin.orrdat,
    ramcod             like ssamsin.ramcod,
    sinnum             like ssamsin.sinnum,
    sinano             like ssamsin.sinano,
    tipprddes          char (10),
    sinvstnum          like ssamsin.sinvstnum,
    sinvstano          like ssamsin.sinvstano
 end record

 define ws             record
    pergunta           char (01),
    lignum             like datmligacao.lignum,
    c24astcod          like datmligacao.c24astcod,
    succod             like datrservapol.succod,
    ramcod             like datrservapol.ramcod,
    aplnumdig          like datrservapol.aplnumdig,
    itmnumdig          like datrservapol.itmnumdig,
    prdtipcod          like ssamitem.prdtipcod
 end record

 let int_flag  =  false
 initialize ws.*          to null
 initialize d_cts20m06.*  to null

 open window cts20m06 at 10,31 with form "cts20m06"
             attribute (border, form line first)

 #------------------------------------------------
 # BUSCA DADOS DO SERVICO
 #------------------------------------------------
 message " Aguarde, pesquisando... "   attribute(reverse)

 select datmservico.atddat,
        datmservicocmp.sindat,
        datmservicocmp.sinhor,
        datrservapol.succod,
        datrservapol.aplnumdig,
        datrservapol.itmnumdig
   into d_cts20m06.atddat,
        d_cts20m06.sindat,
        d_cts20m06.sinhor,
        ws.succod,
        ws.aplnumdig,
        ws.itmnumdig
   from datmservico, outer datmservicocmp, outer datrservapol
  where datmservico.atdsrvnum    = param.atdsrvnum         and
        datmservico.atdsrvano    = param.atdsrvano         and

        datmservicocmp.atdsrvnum = datmservico.atdsrvnum   and
        datmservicocmp.atdsrvano = datmservico.atdsrvano   and

        datrservapol.atdsrvnum   = datmservico.atdsrvnum   and
        datrservapol.atdsrvano   = datmservico.atdsrvano

 if sqlca.sqlcode <> 0   then
    error "Erro (", sqlca.sqlcode ,") na leitura dos dados do servico!"
 end if

 let ws.lignum = cts20g00_servico(param.atdsrvnum, param.atdsrvano)

 select c24astcod into ws.c24astcod
   from datmligacao
  where lignum = ws.lignum

 if sqlca.sqlcode <> 0  then
    error " Erro(", sqlca.sqlcode, ") na localizacao do assunto da ligacao. AVISE A INFORMATICA!"
    return
 else
   #if ws.c24astcod = "G13"  then   # resolucao 86 03/2003
   #   let ws.ramcod = 53
   #else
   #   let ws.ramcod = 31
   #end if
 end if

 #------------------------------------------------
 # BUSCA DADOS DO ULTIMO SINISTRO ABERTO
 #------------------------------------------------
 if ws.succod     is null   or
    ws.aplnumdig  is null   or
    ws.itmnumdig  is null   then
    error " Servico nao possui numero de apolice!"
 else
    if ws.c24astcod = "G13" then
       declare c_ssamsin cursor for
          select ramcod, sinnum   , sinano,
                 orrdat, sinvstnum, sinvstano
            from ssamsin
           where succod    = ws.succod      and
                 ramcod    in (53,553)      and
                 aplnumdig = ws.aplnumdig   and
                 itmnumdig = ws.itmnumdig   and
                 orrdat    = (select max(orrdat) from ssamsin
                               where succod    = ws.succod     and
                                     ramcod    in (53,553)     and
                                     aplnumdig = ws.aplnumdig  and
                                     itmnumdig = ws.itmnumdig)
       foreach c_ssamsin into d_cts20m06.ramcod,
                              d_cts20m06.sinnum,
                              d_cts20m06.sinano,
                              d_cts20m06.orrdat,
                              d_cts20m06.sinvstnum,
                              d_cts20m06.sinvstano
       end foreach
    else
       declare c_ssamsin1 cursor for
          select ramcod, sinnum   , sinano,
                 orrdat, sinvstnum, sinvstano
            from ssamsin
           where succod    = ws.succod      and
                 ramcod    in (31,531)      and
                 aplnumdig = ws.aplnumdig   and
                 itmnumdig = ws.itmnumdig   and
                 orrdat    = (select max(orrdat) from ssamsin
                               where succod    = ws.succod     and
                                     ramcod    in (31,531)     and
                                     aplnumdig = ws.aplnumdig  and
                                     itmnumdig = ws.itmnumdig)
       foreach c_ssamsin1 into d_cts20m06.ramcod,
                               d_cts20m06.sinnum,
                               d_cts20m06.sinano,
                               d_cts20m06.orrdat,
                               d_cts20m06.sinvstnum,
                               d_cts20m06.sinvstano
       end foreach
    end if
   #foreach c_ssamsin into d_cts20m06.ramcod,
   #                       d_cts20m06.sinnum,
   #                       d_cts20m06.sinano,
   #                       d_cts20m06.orrdat,
   #                       d_cts20m06.sinvstnum,
   #                       d_cts20m06.sinvstano
   #end foreach

    if d_cts20m06.sinnum  is null   or
       d_cts20m06.sinano  is null   then
       error " Apolice nao possui sinistro aberto!"
    else
       select prdtipcod
         into ws.prdtipcod
         from ssamitem
        where ramcod    = d_cts20m06.ramcod      and
              sinano    = d_cts20m06.sinano      and
              sinnum    = d_cts20m06.sinnum      and
              sinitmseq = 0

      case ws.prdtipcod
           when 1  let d_cts20m06.tipprddes = "TOTAL"
           when 2  let d_cts20m06.tipprddes = "PARCIAL"
      end case
   end if
 end if

 message ""
 display by name d_cts20m06.*
 prompt " (F17)Abandona " for ws.pergunta

 let int_flag = false
 close window cts20m06

end function  #  cts20m06
