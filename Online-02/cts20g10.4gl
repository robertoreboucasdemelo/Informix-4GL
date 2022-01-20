#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24hrs.                                             #
# Modulo        : cts20g10                                                   #
# Analista Resp.: Carlos Ruiz                                                #
# PSI           : 202720                                                     #
#                 Obter os dados da tabela datrsrvsau                        #
#............................................................................#
# Desenvolvimento: Ligia Mattge                                              #
# Liberacao      : 22/09/2006                                                #
#............................................................................#
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#----------------------------------------------------------------------------#

 database porto

#----------------------------------------------------------------------------
 function cts20g10_prepare()
#----------------------------------------------------------------------------

 define l_sql char (900)

 let l_sql =  " select atdsrvnum, atdsrvano ",
              "  from datrsrvsau ",
              " where crtnum = ? "

 prepare p_cts20g10_001 from l_sql
 declare c_cts20g10_001 cursor with hold for p_cts20g10_001

 let l_sql =  " select succod, ramcod, aplnumdig, crtnum ",
              "  from datrsrvsau ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "

 prepare p_cts20g10_002 from l_sql
 declare c_cts20g10_002 cursor with hold for p_cts20g10_002

end function  ###  cts20g10_prepare

#----------------------------------------------------------------------------
function cts20g10_cartao(l_param)
#----------------------------------------------------------------------------

 define l_param      record
    tp_retorno       smallint,
    atdsrvnum        like datrsrvsau.atdsrvnum,
    atdsrvano        like datrsrvsau.atdsrvano
 end record

 define l_retorno    record
    resultado        smallint,
    mensagem         char(80),
    succod           like datrsrvsau.succod,
    ramcod           like datrsrvsau.ramcod,
    aplnumdig        like datrsrvsau.aplnumdig,
    crtnum           like datrsrvsau.crtnum
 end record

 initialize l_retorno.* to null

 whenever error continue
 open c_cts20g10_002 using l_param.atdsrvnum, l_param.atdsrvano
 if status <> 0 then
    call cts20g10_prepare()
    open c_cts20g10_002 using l_param.atdsrvnum, l_param.atdsrvano
 end if
 whenever error stop

 fetch c_cts20g10_002 into l_retorno.succod,
                         l_retorno.ramcod,
                         l_retorno.aplnumdig,
                         l_retorno.crtnum
 if sqlca.sqlcode = 0 then
    let l_retorno.resultado = 1
 else
    if sqlca.sqlcode = notfound then
       let l_retorno.resultado = 2
       let l_retorno.mensagem = "Nao encontrado cartao saude para servico"
    else
       let l_retorno.resultado = 3
       let l_retorno.mensagem = "ERRO ", sqlca.sqlcode, " em datrligppt - cts20g10002"
    end if
 end if
 close c_cts20g10_002

 if l_param.tp_retorno = 1 then
    #retorna o numero do cartao
    return  l_retorno.resultado,
            l_retorno.mensagem,
            l_retorno.crtnum
 end if

 if l_param.tp_retorno = 2 then
    #retorna dados da apolice de saude
    return l_retorno.resultado,
           l_retorno.mensagem,
           l_retorno.succod,
           l_retorno.ramcod,
           l_retorno.aplnumdig,
           l_retorno.crtnum
  end if

end function

#----------------------------------------------------------------------------
function cts20g10_servico(l_param)
#----------------------------------------------------------------------------

 define l_param      record
    crtnum           like datrsrvsau.crtnum
 end record

 define l_retorno    record
    resultado        smallint,
    mensagem         char(80),
    atdsrvnum        like datrsrvsau.atdsrvnum,
    atdsrvano        like datrsrvsau.atdsrvano
 end record

 initialize l_retorno.* to null

 whenever error continue
 open c_cts20g10_001 using l_param.crtnum
 if status <> 0 then
    call cts20g10_prepare()
    open c_cts20g10_001 using l_param.crtnum
 end if
 whenever error stop

 fetch c_cts20g10_001 into l_retorno.atdsrvnum, l_retorno.atdsrvano
 if sqlca.sqlcode = 0 then
    let l_retorno.resultado = 1
 else
    if sqlca.sqlcode = notfound then
       let l_retorno.resultado = 2
       let l_retorno.mensagem = "Servico nao encontrado para esse cartao"
    else
       let l_retorno.resultado = 3
       let l_retorno.mensagem = "ERRO ", sqlca.sqlcode, " em datrligppt - cts20g10001"
    end if
 end if
 close c_cts20g10_001

 return l_retorno.resultado,
        l_retorno.mensagem,
        l_retorno.atdsrvnum,
        l_retorno.atdsrvano

end function
