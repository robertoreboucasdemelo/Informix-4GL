###############################################################################
# Nome do Modulo: CTB90G00                                           BURINI   #
#                                                                             #
# Consulta de RAMO e MODALIDADE do serviço Porto Seguro FAZ   .      Nov/2014 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRIÇÃO                             #
#-----------------------------------------------------------------------------#
###############################################################################

database porto

#------------------------------------#
 function ctb90g00_consula_srv(param)
#------------------------------------#

     define param record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
     end record

     define l_ciaempcod like datmservico.ciaempcod,
            l_ramcod    like datrmdlramast.ramcod,
            l_rmemdlcod like datrmdlramast.rmemdlcod

     initialize l_ciaempcod to null

     if  param.atdsrvnum is null or param.atdsrvnum = " " or
         param.atdsrvano is null or param.atdsrvano = " " then
         return 1,0,0, "Servico nulo"
     end if

     whenever error continue
       select ciaempcod
         into l_ciaempcod
         from datmservico
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
     whenever error stop

     if  sqlca.sqlcode <> 0 then
         return 1,0,0, "Servico nao encontrado na base da Central 24 Horas"
     end if

     if  l_ciaempcod <> 43 then
         return 1,0,0, "Servico nao aberto pela Porto Seguro FAZ"
     end if

     whenever error continue
     select ast.ramcod, ast.rmemdlcod
       into l_ramcod, l_rmemdlcod
       from datrctbramsrv srv, datrmdlramast ast, datmligacao lig
      where lig.atdsrvnum = param.atdsrvnum
        and lig.atdsrvano = param.atdsrvano
        and srv.atdsrvnum = lig.atdsrvnum
        and srv.atdsrvano = lig.atdsrvano
        and ast.c24astcod = lig.c24astcod
        and lig.lignum = (select min(lignum)
                            from datmligacao lig2
                           where lig.atdsrvnum = lig2.atdsrvnum
                             and lig.atdsrvano = lig2.atdsrvano)
     whenever error stop

     if  sqlca.sqlcode <> 0 then
         return 0,5009,1, "Ramo e modalidade padrão, registro nao encontrado na base"
     end if

     return 0,
            l_ramcod,
            l_rmemdlcod,
            "Ramo e modalidade encontrada com sucesso"

 end function