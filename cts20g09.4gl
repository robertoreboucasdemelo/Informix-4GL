#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24hrs.                                             #
# Modulo        : cts20g09                                                   #
# Analista Resp.: Carlos Ruiz                                                #
# PSI           : 202720                                                     #
#                 Obter o cartao saude pela ligacao                          #
#............................................................................#
# Desenvolvimento: Ligia Mattge                                              #
# Liberacao      : 21/09/2006                                                #
#............................................................................#
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#----------------------------------------------------------------------------#
 database porto

#----------------------------------------------------------------------------
 function cts20g09_prepare()
#----------------------------------------------------------------------------

 define l_sql char (900)

 let l_sql =  " select succod, ramcod, aplnumdig, crtnum, bnfnum ",
              "  from datrligsau ",
              " where lignum = ? "

 prepare p_cts20g09_001 from l_sql
 declare c_cts20g09_001 cursor with hold for p_cts20g09_001

end function  ###  cts20g09_prepare

#----------------------------------------------------------------------------
function cts20g09_docto(l_param)
#----------------------------------------------------------------------------

 define l_param      record
    nivel_retorno    smallint,
    lignum           like datmligacao.lignum
 end record

 define l_retorno    record
    succod           like datrligsau.succod,
    ramcod           like datrligsau.ramcod,
    aplnumdig        like datrligsau.aplnumdig,
    crtnum           like datrligsau.crtnum,
    bnfnum           like datrligsau.bnfnum
 end record

 initialize l_retorno.* to null

 whenever error continue
 open c_cts20g09_001 using l_param.lignum
 if status <> 0 then
    call cts20g09_prepare()
    open c_cts20g09_001 using l_param.lignum
 end if
 whenever error stop

 fetch c_cts20g09_001 into l_retorno.succod, l_retorno.ramcod,
                         l_retorno.aplnumdig, l_retorno.crtnum,
                         l_retorno.bnfnum
 close c_cts20g09_001

 case l_param.nivel_retorno
      when 1 return l_retorno.crtnum
      when 2 return l_retorno.succod, l_retorno.ramcod,
                    l_retorno.aplnumdig, l_retorno.crtnum, l_retorno.bnfnum
 end case

end function
