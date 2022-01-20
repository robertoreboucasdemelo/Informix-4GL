###############################################################################
# Nome do Modulo: CTB12M08                                           Marcelo  #
#                                                                    Gilberto #
# Libera servico para pagamento                                      Jan/1998 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 03/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas    #
#                                       para verificacao do servico.          #
###############################################################################

database porto

#------------------------------------------------------------
 function ctb12m08(param)
#------------------------------------------------------------

 define param       record
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano
 end record

 define ws          record
    cnflibflg       like datmservico.atdlibflg,
    atdlibflg       like datmservico.atdlibflg,
    atdfnlflg       like datmservico.atdfnlflg
 end record

 initialize ws.*  to null

 select atdlibflg, atdfnlflg
   into ws.atdlibflg,
        ws.atdfnlflg
   from datmservico
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Erro (", sqlca.sqlcode, ") na localizacao do servico. AVISE A INFORMATICA!"
    return
 end if

 if ws.atdlibflg = "N"  and   ###  Servico nao liberado
    ws.atdfnlflg = "S"  then  ###  e acionado
    call cts02m06() returning ws.cnflibflg

    if ws.cnflibflg = "N"  then
       error " Liberacao nao confirmada!"
       return
    end if

    update datmservico set
       (atdlibflg, atdlibdat, atdlibhor) = ("S", today, current)
     where atdsrvnum = param.atdsrvnum  and
           atdsrvano = param.atdsrvano

    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na liberacao do servico. AVISE A INFORMATICA!"
    else
      call cts00g07_apos_grvlaudo(param.atdsrvnum,param.atdsrvano)
      error " Servico liberado com sucesso!"
    end if
 else
    error " Servico nao pode ser liberado!"
 end if

end function  ###  ctb12m08
