#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: CENTRAL 24H                                                #
# Modulo.........: cts47g00                               07/2007             #
# Analista Resp..: Fabiano Santos                                             #
# PSI/OSF........: Modulo para retornar dados referente ao acionamento        #
# ........................................................................... #


globals  "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------#
 function cts47g00_mesma_cidsed_cid(lr_param)
#--------------------------------------------#
    define lr_param record
        cidnomorg   like datmlcl.cidnom, #cidade origem
        ufdcodorg   like datmlcl.ufdcod, #uf origem
        cidnomdst   like datmlcl.cidnom, #cidade destino
        ufdcoddst   like datmlcl.ufdcod  #uf destino
    end record

    define lr_cty10g00 array[2] of record
        cidcod      like glakcid.cidcod
    end record

    define lr_ctd01g00 array[2] of record
         cidsedcod  like datrcidsed.cidsedcod
    end record

    define l_ind        smallint,
           l_resultado  smallint,
           l_mensagem   char(100)

    initialize lr_cty10g00, lr_ctd01g00 to null

    #Busca codigo cidade origem
    call cty10g00_obter_cidcod(lr_param.cidnomorg,
                               lr_param.ufdcodorg)
        returning l_resultado,
                  l_mensagem,
                  lr_cty10g00[1].*

    #Busca codigo cidade destino
    call cty10g00_obter_cidcod(lr_param.cidnomdst,
                               lr_param.ufdcoddst)
        returning l_resultado,
                  l_mensagem,
                  lr_cty10g00[2].*

    for l_ind = 1 to 2
        call ctd01g00_obter_cidsedcod(1, #tipo retorno
                                      lr_cty10g00[l_ind].cidcod)
            returning l_resultado,
                      l_mensagem,
                      lr_ctd01g00[l_ind].*
    end for

    if  lr_ctd01g00[1].cidsedcod = lr_ctd01g00[2].cidsedcod then
        return 1 #endereco encontrado e mesma cidade sede
    else
        return 0 #endereco encontrado e nao eh mesma cidade sede
    end if

 end function

#--------------------------------------------#
 function cts47g00_mesma_cidsed_srv(lr_param)
#--------------------------------------------#
    define lr_param record
        atdsrvnum   like datmservico.atdsrvnum,
        atdsrvano   like datmservico.atdsrvano
    end record

    define lr_ctd07g03 array[2] of record
        cidnom  like datmlcl.cidnom,
        ufdcod  like datmlcl.ufdcod,
        lclltt  like datmlcl.lclltt,
        lcllgt  like datmlcl.lcllgt
    end record

    define lr_cty10g00 array[2] of record
        cidcod  like glakcid.cidcod
    end record

    define lr_ctd01g00 array[2] of record
         cidsedcod  like datrcidsed.cidsedcod
    end record

    define l_ind        smallint,
           l_resultado  smallint,
           l_mensagem   char(100)

    initialize lr_ctd07g03, lr_cty10g00, lr_ctd01g00 to null

    for l_ind = 1 to 2
        call ctd07g03_busca_local(1, #nivel retorno
                                  lr_param.atdsrvnum,
                                  lr_param.atdsrvano,
                                  l_ind) #1-REC, 2-FIM
            returning l_resultado,
                      l_mensagem,
                      lr_ctd07g03[l_ind].*

        if  l_resultado <> 1 then
            return -1 #endereco nao encontrado
        end if

        call cty10g00_obter_cidcod(lr_ctd07g03[l_ind].cidnom,
                                   lr_ctd07g03[l_ind].ufdcod)
            returning l_resultado,
                      l_mensagem,
                      lr_cty10g00[l_ind].*

        call ctd01g00_obter_cidsedcod(1, #tipo retorno
                                      lr_cty10g00[l_ind].cidcod)
            returning l_resultado,
                      l_mensagem,
                      lr_ctd01g00[l_ind].*
    end for

    if  lr_ctd01g00[1].cidsedcod = lr_ctd01g00[2].cidsedcod then
        return 1 #endereco encontrado e mesma cidade sede
    else
        return 0 #endereco encontrado e nao eh mesma cidade sede
    end if

 end function

#--------------------------------------#
 function cts47g00_verif_tmp(lr_param)
#--------------------------------------#

    define lr_param   record
                          atdsrvnum like datmservico.atdsrvnum,
                          atdsrvano like datmservico.atdsrvano,
                          tipo      char(10)
                      end record

    define lr_retorno record
                          tmpacn like datrgrpntz.atmacnatchorqtd,
                          erro     integer,
                          msg      char(20)
                      end record

    define l_c24astcod     like datrempgrp.c24astcod,
           l_socntzcod     like datmsrvre.socntzcod,
           l_ciaempcod     like datmservico.ciaempcod,
           l_atdsrvorg     like datmservico.atdsrvorg,
           l_sql           char(1000),
           l_resultado     smallint,
           l_mensagem      char(100),
           l_acntntlmtqtd  like datkatmacnprt.acntntlmtqtd,
           l_netacnflg     like datkatmacnprt.netacnflg,
           l_atmacnprtcod  like datkatmacnprt.atmacnprtcod,
           l_aux           char(15)

    let lr_retorno.erro = 0
    let lr_retorno.msg  = ""
    let l_c24astcod    = null
    let l_socntzcod    = null
    let l_ciaempcod    = null
    let l_atdsrvorg    = null
    let l_sql          = null
    let l_resultado    = null
    let l_mensagem     = null
    let l_acntntlmtqtd = null
    let l_netacnflg    = null
    let l_atmacnprtcod = null
    let l_aux          = null
    initialize lr_retorno to null

    whenever error continue
     select ciaempcod
       into l_ciaempcod
       from datmservico
      where atdsrvnum  = lr_param.atdsrvnum
        and atdsrvano  = lr_param.atdsrvano
    whenever error stop
    call ctd06g00_pri_ligacao(1,
                              lr_param.atdsrvnum,
                              lr_param.atdsrvano)
      returning l_resultado,
                l_mensagem,
                l_c24astcod
    if  sqlca.sqlcode = 100 then
        let lr_retorno.erro = 2
        let lr_retorno.msg  = "Assunto nao encontradao na tabela DATMLIGACAO"
    else
        if  sqlca.sqlcode <> 0 then
            let lr_retorno.erro = 3
            let lr_retorno.msg  = "Erro ",sqlca.sqlcode ," no acesso a tabela DATMLIGACAO"
        else
            whenever error continue
              select socntzcod
                into l_socntzcod
                from datmsrvre
               where atdsrvnum = lr_param.atdsrvnum
                 and atdsrvano = lr_param.atdsrvano
            whenever error stop

            if  sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
                let lr_retorno.erro = 3
                let lr_retorno.msg  = "Erro ",sqlca.sqlcode ," no acesso a tabela DATMSRVRE"
            else
                if  sqlca.sqlcode <> 100 then
                    let l_sql = "select "
                    case lr_param.tipo
                         when "ACIONA"
                              let l_sql = l_sql clipped, " atmacnatchorqtd"
                         when "AVISO"
                              let l_sql = l_sql clipped, " cliavsenvhorqtd"
                         when "ACEITE"
                              let l_sql = l_sql clipped, " srvacthorqtd"
                    end case
                    let l_sql = l_sql clipped,
                               " from datrgrpntz a, ",
                                    " datrempgrp b ",
                              " where a.socntzgrpcod = b.socntzgrpcod ",
                                " and empcod    = ? ",
                                " and socntzcod = ? ",
                                " and c24astcod = ? "
                    prepare prcts47g00 from l_sql
                    declare cqcts47g00 cursor for prcts47g00

                    open cqcts47g00 using l_ciaempcod,
                                          l_socntzcod,
                                          l_c24astcod
                    fetch cqcts47g00 into lr_retorno.tmpacn
                end if
                if  lr_retorno.tmpacn is null or lr_retorno.tmpacn = " "  then
                    if  lr_param.tipo = "ACIONA" then
                        whenever error continue
                          select atdsrvorg
                            into l_atdsrvorg
                            from datmservico
                           where atdsrvnum = lr_param.atdsrvnum
                             and atdsrvano = lr_param.atdsrvano
                        whenever error stop
                        call cts40g00_obter_parametro(l_atdsrvorg)
                             returning l_resultado,
                                       l_mensagem,
                                       l_aux,
                                       l_acntntlmtqtd,
                                       l_netacnflg,
                                       l_atmacnprtcod
                        let lr_retorno.tmpacn = l_aux
                        if  lr_retorno.tmpacn is not null and
                            lr_retorno.tmpacn <> " "  then
                            let lr_retorno.erro = 2
                            let lr_retorno.msg  = "Grupo nao encontradao na tabela DATRGRPNTZ"
                        end if
                    else
                        if  lr_param.tipo = "AVISO" then
                            let lr_retorno.tmpacn = 0
                        end if
                    end if
                end if
            end if
        end if
    end if

    return lr_retorno.*

 end function
#-----------------------------------------#
 function cts47g00_verif_grp_ntz(lr_param)
#-----------------------------------------#

    define lr_param   record
                          atdsrvnum like datmservico.atdsrvnum,
                          atdsrvano like datmservico.atdsrvano
                      end record

    define l_resultado     smallint,
           l_mensagem      char(100),
           l_ciaempcod     like datmservico.ciaempcod,
           l_socntzcod     like datmsrvre.socntzcod,
           l_c24astcod     like datmligacao.c24astcod,
           l_socntzgrpcod  like datrgrpntz.socntzgrpcod
    initialize l_socntzgrpcod to null
    call cts10g06_dados_servicos(10, lr_param.atdsrvnum,
                                     lr_param.atdsrvano)
         returning l_resultado, l_mensagem, l_ciaempcod
    whenever error continue
      select socntzcod
        into l_socntzcod
        from datmsrvre
       where atdsrvnum = lr_param.atdsrvnum
         and atdsrvano = lr_param.atdsrvano
    whenever error continue
    whenever error continue
      select c24astcod
        into l_c24astcod
        from datmligacao
       where atdsrvnum = lr_param.atdsrvnum
         and atdsrvano = lr_param.atdsrvano
    whenever error stop

    whenever error continue
      select a.socntzgrpcod
        into l_socntzgrpcod
        from datrgrpntz a,
             datrempgrp b
       where a.socntzgrpcod = b.socntzgrpcod
         and empcod    = l_ciaempcod
         and socntzcod = l_socntzcod
         and c24astcod = l_c24astcod
    whenever error stop

    return l_socntzgrpcod
 end function
