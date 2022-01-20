#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema        : PORTO SOCORRO                                              #
# Modulo         : ctc00m15                                                   #
#                  Função para validação de tarifas Porto Seguro              #
# Analista Resp. : Sergio Burini                                              #
# PSI            : 208264                                                     #
#.............................................................................#
#                                                                             #
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data        Autor Fabrica  Data   Alteracao                                 #
# ----------  -------------  ------ ------------------------------------------#
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------#
 function ctc00m15_prepare()
#----------------------------#

    define l_sql char(500)

    let l_sql = "select soctrfcod ",
                 " from dparpstsrvprc ",
                " where pstcoddig = ? ",
                  " and empcod    = ? ",
                  " and atdsrvorg = ? ",
                  " and asitipcod = ? "

    prepare prctc00m15_01 from l_sql
    declare cqctc00m15_01 cursor for prctc00m15_01

    let l_sql = "select soctrfvignum ",
                 " from dbsmvigtrfsocorro ",
                " where soctrfcod = ? ",
                  " and ? between soctrfvigincdat ",
                            " and soctrfvigfnldat "

    prepare prctc00m15_02 from l_sql
    declare cqctc00m15_02 cursor for prctc00m15_02

    let l_sql = "select socgtfcod ",
                 " from dbsrvclgtf ",
                " where vclcoddig = ? "

    prepare prctc00m15_03 from l_sql
    declare cqctc00m15_03 cursor for prctc00m15_03

    let l_sql = " select socgtfcstvlr ",
                  " from dbstgtfcst ",
                 " where soctrfvignum = ? ",
                   " and socgtfcod    = ? ",
                   " and soccstcod    = ? "

    prepare prctc00m15_04 from l_sql
    declare cqctc00m15_04 cursor for prctc00m15_04

    let l_sql = " select atdsrvnum, ",
                       " atdsrvano ",
                  " from dbsmopgitm ",
                 " where socopgnum = ? "

    prepare prctc00m15_05 from l_sql
    declare cqctc00m15_05 cursor for prctc00m15_05

    let l_sql = " select ciaempcod, ",
                       " atdsrvorg, ",
                       " asitipcod, ",
                       " atddat ",
                  " from datmservico ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "

    prepare prctc00m15_06 from l_sql
    declare cqctc00m15_06 cursor for prctc00m15_06

 end function

#-------------------------------------#
 function ctc00m15_rettrfvig(lr_param)
#-------------------------------------#

    define lr_param record
        pstcoddig   like dparpstsrvprc.pstcoddig,
        empcod      like dparpstsrvprc.empcod,
        atdsrvorg   like dparpstsrvprc.atdsrvorg,
        asitipcod   like dparpstsrvprc.asitipcod,
        dattrfvig   date
    end record

    define lr_result record
        soctrfcod       like dparpstsrvprc.soctrfcod,
        soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum,
        err             smallint,
        msgerr          char(100)
    end record

    define l_zero smallint

    call ctc00m15_prepare()

    initialize lr_result.* to null
    let l_zero = 0

    open cqctc00m15_01 using lr_param.pstcoddig,
                             lr_param.empcod,
                             lr_param.atdsrvorg,
                             lr_param.asitipcod
    fetch cqctc00m15_01 into lr_result.soctrfcod

    if  sqlca.sqlcode = notfound then
        open cqctc00m15_01 using lr_param.pstcoddig,
                                 lr_param.empcod,
                                 lr_param.atdsrvorg,
                                 l_zero
        fetch cqctc00m15_01 into lr_result.soctrfcod

        if  sqlca.sqlcode = notfound then
            open cqctc00m15_01 using lr_param.pstcoddig,
                                     lr_param.empcod,
                                     l_zero,
                                     lr_param.asitipcod
            fetch cqctc00m15_01 into lr_result.soctrfcod

            if  sqlca.sqlcode = notfound then
                open cqctc00m15_01 using lr_param.pstcoddig,
                                         lr_param.empcod,
                                         l_zero,
                                         l_zero
                fetch cqctc00m15_01 into lr_result.soctrfcod

                if  sqlca.sqlcode = notfound then
                    open cqctc00m15_01 using lr_param.pstcoddig,
                                             l_zero,
                                             lr_param.atdsrvorg,
                                             lr_param.asitipcod
                    fetch cqctc00m15_01 into lr_result.soctrfcod

                    if  sqlca.sqlcode = notfound then
                        open cqctc00m15_01 using lr_param.pstcoddig,
                                                 l_zero,
                                                 lr_param.atdsrvorg,
                                                 l_zero
                        fetch cqctc00m15_01 into lr_result.soctrfcod

                        if  sqlca.sqlcode = notfound then
                            open cqctc00m15_01 using lr_param.pstcoddig,
                                                     l_zero,
                                                     l_zero,
                                                     lr_param.asitipcod
                            fetch cqctc00m15_01 into lr_result.soctrfcod

                            if  sqlca.sqlcode = notfound then
                                open cqctc00m15_01 using lr_param.pstcoddig,
                                                         l_zero,
                                                         l_zero,
                                                         l_zero
                                fetch cqctc00m15_01 into lr_result.soctrfcod
                            end if
                        end if
                    end if
                end if
            end if
        end if
    end if

    if  sqlca.sqlcode <> 0 and sqlca.sqlcode <> notfound then
        let lr_result.err = sqlca.sqlcode
        let lr_result.msgerr =
            ' Erro ctc00m15_rettrfvig() /',
            ' P1=', lr_param.pstcoddig,
            ' P2=', lr_param.empcod,
            ' P3=', lr_param.atdsrvorg,
            ' P4=', lr_param.asitipcod,
            ' / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2]
display "ERR 1"
       
        return lr_result.*
    end if
    close cqctc00m15_01

    open cqctc00m15_02 using lr_result.soctrfcod,
                             lr_param.dattrfvig
    fetch cqctc00m15_02 into lr_result.soctrfvignum
    let lr_result.err = sqlca.sqlcode
    if  sqlca.sqlcode = 0 then
        let lr_result.msgerr = 'OK'
    else
        if  sqlca.sqlcode = notfound then
            let lr_result.msgerr =
                'Vigencia nao encontrada (tarifa: ', lr_result.soctrfcod,
                ' / data: ', lr_param.dattrfvig, ')'
display "ERR 2 ", lr_result.msgerr

        else
            let lr_result.msgerr =
                ' Erro SELECT dbsmvigtrfsocorro / ctc00m15_rettrfvig() / ',
                sqlca.sqlcode, ' / ', sqlca.sqlerrd[2]
display "ERR 3 ", lr_result.msgerr
        end if
    end if
    close cqctc00m15_02

    return lr_result.*

 end function

#----------------------------------------#
 function ctc00m15_retsocgtfcod(lr_param)
#----------------------------------------#
    define lr_param record
        vclcoddig  like dbsrvclgtf.vclcoddig
    end record

    define lr_result record
        socgtfcod   like dbsrvclgtf.socgtfcod,
        err         smallint,
        msgerr      char(100)
    end record

    define l_ctgtrfcod   like agekcateg.ctgtrfcod

    call ctc00m15_prepare()

    if  lr_param.vclcoddig = 99999 then
        let l_ctgtrfcod = 10
    else
        select autctgatu into l_ctgtrfcod
          from agetdecateg
         where vclcoddig = lr_param.vclcoddig
           and viginc <= today
           and vigfnl >= today
    end if
       
    open cqctc00m15_03 using l_ctgtrfcod
    fetch cqctc00m15_03 into lr_result.socgtfcod
    let lr_result.err = sqlca.sqlcode
    if  sqlca.sqlcode = 0 then
        let lr_result.msgerr = "OK"
    else
        if  sqlca.sqlcode = notfound then
            let lr_result.msgerr = "Grupo tarifario nao encontrado"
        else
            let lr_result.msgerr =
                "Erro SELECT ctc00m15_retsocgtfcod() / ",
                sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
        end if
    end if

    return lr_result.*
    close cqctc00m15_03

 end function

#-------------------------------------#
 function ctc00m15_retvlrvig(lr_param)
#-------------------------------------#
    define lr_param record
        soctrfvignum    like dbstgtfcst.soctrfvignum,
        socgtfcod       like dbstgtfcst.socgtfcod,
        soccstcod       like dbstgtfcst.soccstcod
    end record

    define lr_result record
        socgtfcstvlr    like dbstgtfcst.socgtfcstvlr,
        err             smallint,
        msgerr          char(100)
    end record

    call ctc00m15_prepare()

    open cqctc00m15_04 using lr_param.soctrfvignum,
                             lr_param.socgtfcod,
                             lr_param.soccstcod
    fetch cqctc00m15_04 into lr_result.socgtfcstvlr
    let lr_result.err = sqlca.sqlcode
    if  sqlca.sqlcode = 0 then
        let lr_result.msgerr = "OK"
    else
        let lr_result.socgtfcstvlr = 0
        if  sqlca.sqlcode = notfound then
            let lr_result.msgerr = "Valor nao encontrado"
        else
            let lr_result.msgerr =
                "Erro SELECT ctc00m15_retvlrvig() / ",
                sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
        end if
    end if
    close cqctc00m15_04

    return lr_result.*

 end function

#-------------------------------------#
 function ctc00m15_retddssrv(lr_param)
#-------------------------------------#
    define lr_param record
        socopgnum   like dbsmopgitm.socopgnum
    end record

    define lr_result record
        empcod      like datmservico.empcod,
        atdsrvorg   like datmservico.atdsrvorg,
        asitipcod   like datmservico.asitipcod,
        atddat      like datmservico.atddat,
        err         smallint,
        msgerr      char(100)
    end record

    define lr_dados record
        atddat      like datmservico.atddat,
        atdsrvnum   like datmservico.atdsrvnum,
        atdsrvano   like datmservico.atdsrvano
    end record

    call ctc00m15_prepare()

    open cqctc00m15_05 using lr_param.socopgnum
    fetch cqctc00m15_05 into lr_dados.atdsrvnum,
                             lr_dados.atdsrvano
    let lr_result.err = sqlca.sqlcode
    if  sqlca.sqlcode = 0 then
        let lr_result.msgerr = "OK"
    else
        if  sqlca.sqlcode = notfound then
            let lr_result.msgerr =
                "Nao foi encontrado servico relacionado a OP: ",
                lr_param.socopgnum, " / ctc00m15_retatddat()"
        else
            let lr_result.msgerr =
                "Erro SELECT ctc00m15_retatddat() / ",
                sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
        end if
        #Se nao encontrou servico ja retorna
        return lr_result.*
    end if
    close cqctc00m15_05

    open cqctc00m15_06 using lr_dados.atdsrvnum,
                             lr_dados.atdsrvano
    fetch cqctc00m15_06 into lr_result.empcod,
                             lr_result.atdsrvorg,
                             lr_result.asitipcod,
                             lr_result.atddat
    let lr_result.err = sqlca.sqlcode
    if  sqlca.sqlcode = 0 then
        let lr_result.msgerr = "OK"
    else
        if  sqlca.sqlcode = notfound then
            let lr_result.msgerr =
                "Servico ", lr_dados.atdsrvnum, "-", lr_dados.atdsrvano,
                " nao encontrado / ctc00m15_retatddat()"
        else
            let lr_result.msgerr =
                "Erro SELECT ctc00m15_retatddat() / ",
                sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
        end if
    end if
    close cqctc00m15_06

    return lr_result.*

 end function