###############################################################################
# Nome do Modulo: CTX02G00                                           Marcelo  #
#                                                                    Gilberto #
# Retorna quantidade de atendimentos - Ramos Elementares             Mai/1998 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 04/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas    #
#                                       para verificacao do servico.          #
#-----------------------------------------------------------------------------#
# 28/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
# 15/07/2003  PSI 176087   Amaury       OSF22810 Alterar atdetpcod = 4 p/ 3.  #
# 08/12/2004  PSI 188239   Bruno(Meta)  Consistir ramcod = 31 ou 531.         #
###############################################################################

globals '/homedsa/projetos/geral/globals/glct.4gl'

#------------------------------------------------------------------
 function ctx02g00(param)
#------------------------------------------------------------------

 define param           record
    ramcod              like datrservapol.ramcod   ,
    succod              like datrservapol.succod   ,
    aplnumdig           like datrservapol.aplnumdig,
    incdat              date                       ,
    fnldat              date
 end record

 define ws              record
    atdsrvnum           like datrservapol.atdsrvnum,
    atdsrvano           like datrservapol.atdsrvano,
    atdfnlflg           like datmservico.atdfnlflg ,
    atdetpcod           like datmsrvacp.atdetpcod  ,
    comando             char(250)                  ,
    qtdatd              smallint
 end record

 define w_comando       char(800)


	initialize  ws.*  to  null

 initialize ws.*  to null
 let ws.qtdatd = 0

 if param.ramcod    is null  or
    param.succod    is null  or
    param.aplnumdig is null  or
    param.incdat    is null  or
    param.fnldat    is null  then
    return ws.qtdatd
 end if

#--------------------------
# PREPARA COMANDO SQL
#--------------------------
 let ws.comando = "select atdetpcod    ",
                  "  from datmsrvacp   ",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?",
                  "   and atdsrvseq = (select max(atdsrvseq)",
                                      "  from datmsrvacp    ",
                                      " where atdsrvnum = ? ",
                                      "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from ws.comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

 if param.ramcod = 31 or param.ramcod = 531 then
    let w_comando = " select datmservico.atdsrvnum, ",
                    " datmservico.atdsrvano, ",
                    " datmservico.atdfnlflg ",
               " from datmservico, datrservapol, datmligacao ",
               " where datrservapol.ramcod     = ", param.ramcod,
               " and datrservapol.succod     = ",  g_documento.succod ,
               " and datrservapol.aplnumdig  = ", g_documento.aplnumdig,
               " and datrservapol.itmnumdig  = ", g_documento.itmnumdig,
               " and datmservico.atddat >= ", "'", param.incdat, "'",
               " and datmservico.atddat <= ", "'", param.fnldat, "'",
               " and datmservico.atdsrvorg   =  9 ",
               " and datmservico.atdsrvnum   =  datrservapol.atdsrvnum ",
               " and datmservico.atdsrvano   =  datrservapol.atdsrvano ",
               " and datmligacao.atdsrvnum   =  datrservapol.atdsrvnum ",
               " and datmligacao.atdsrvano   =  datrservapol.atdsrvano ",
               " and datmligacao.c24astcod   = ", "'", g_documento.c24astcod,"'"
 else
    let w_comando = " select datmservico.atdsrvnum, ",
                    " datmservico.atdsrvano, ",
                    " datmservico.atdfnlflg ",
               " from datmservico, datrservapol ",
               " where datrservapol.ramcod     = ", param.ramcod,
               " and datrservapol.succod     = ",  param.succod ,
               " and datrservapol.aplnumdig  = ", param.aplnumdig,
               " and datrservapol.itmnumdig  =  0 ",
               " and datmservico.atddat >= ", "'", param.incdat, "'",
               " and datmservico.atddat <= ", "'", param.fnldat, "'",
               " and datmservico.atdsrvorg   =  9 ",
               " and datmservico.atdsrvnum   =  datrservapol.atdsrvnum ",
               " and datmservico.atdsrvano   =  datrservapol.atdsrvano "
 end if

 prepare s_ctx02g00 from w_comando
 declare c_ctx02g00 cursor for s_ctx02g00

 foreach c_ctx02g00 into ws.atdsrvnum, ws.atdsrvano, ws.atdfnlflg
    #------------------------------------------------------------
    # Verifica etapa do servico
    #------------------------------------------------------------
    #if ws.atdfnlflg is not null  and
    #   ws.atdfnlflg  = "C"       then
    #   let ws.qtdatd = ws.qtdatd + 1
    #else
    #   continue foreach
    #end if
    open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano,
                             ws.atdsrvnum, ws.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

   #---> PSI 176087
   #if ws.atdetpcod =  4      then   # somente servico etapa concluida
    
    if param.ramcod = 31 or
       param.ramcod = 531 then
       if ws.atdetpcod = 1 or
          ws.atdetpcod = 3 then
          let ws.qtdatd = ws.qtdatd + 1 
       end if
    else
       if ws.atdetpcod =  3 then
          let ws.qtdatd = ws.qtdatd + 1 
       end if
    end if

 end foreach

 return ws.qtdatd

end function  ###  ctx02g00
