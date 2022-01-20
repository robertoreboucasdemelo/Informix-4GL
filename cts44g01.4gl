###############################################################################
# Nome do Modulo: CTS44g01                                           Ruiz     #
#                                                                             #
# Validação de Clausulas de carro extra por Apolice - Azul Seguros DEZ/2006   #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 14/12/2006  psi 205206   Ruiz         Validação de Clausulas carro extra.   #
#-----------------------------------------------------------------------------#
# 03/11/2009 Carla Rampazzo             Tratar novas clausulas do Carro Extra #
#                                       Livre Escolha: 58E-05dias / 58F-10dias#
#                                                      58G-15dias / 58H-30dias#
#-----------------------------------------------------------------------------#
# 16/07/2010 Carla Rampazzo             Tratar novas clausulas do Carro Extra #
#                                       Referenciada : 58I -  7 dias          #
#                                                      58J - 15 dias          #
#                                                      58K - 15 dias          #
#                                                                             #
#                                       Livre Escolha: 58L -  7 dias          #
#                                                      58M - 15 dias          #
#                                                      58N - 15 dias          #
#-----------------------------------------------------------------------------#

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------------------
 function cts44g01_claus_azul(param)
#-----------------------------------------------------------------------
    define param record
           succod     like datrservapol.succod,
           ramcod     like datrservapol.ramcod,
           aplnumdig  like datrservapol.aplnumdig,
           itmnumdig  like datrservapol.itmnumdig
    end record
    define l_retorno  record
           clsazul    smallint,
           clscod     like abbmclaus.clscod
    end record
    define l_clscod   like abbmclaus.clscod

    initialize l_retorno.* to null

    let l_retorno.clsazul = false
    let l_retorno.clscod  = "58A" ---> Referenciada - 5 diarias

    while true

        call cts44g00(param.succod,
                      param.ramcod,
                      param.aplnumdig,
                      param.itmnumdig,
                      "", #  mr_geral.edsnumref,
                      l_retorno.clscod) # clausula de carro extra - Azul
             returning l_retorno.clsazul

        if l_retorno.clsazul = true then
           return l_retorno.*
        end if

        if l_retorno.clscod = "58A" then
           let l_retorno.clscod = "58B" ---> Referenciada - 10 diarias
           continue while
        end if

        if l_retorno.clscod = "58B" then
           let l_retorno.clscod = "58C" ---> Referenciada - 15 diarias
           continue while
        end if

        if l_retorno.clscod = "58C" then
           let l_retorno.clscod = "58D" ---> Referenciada - 30 diarias
           continue while
        end if

        if l_retorno.clscod = "58D" then
           let l_retorno.clscod = "58E" ---> Livre Escolha - 5 diarias
           continue while
        end if

        if l_retorno.clscod = "58E" then
           let l_retorno.clscod = "58F" ---> Livre Escolha - 10 diarias
           continue while
        end if

        if l_retorno.clscod = "58F" then
           let l_retorno.clscod = "58G" ---> Livre Escolha - 15 diarias
           continue while
        end if

        if l_retorno.clscod = "58G" then
           let l_retorno.clscod = "58H" ---> Livre Escolha - 30 diarias
           continue while
        end if

        if l_retorno.clscod = "58H" then
           let l_retorno.clscod = "58I" ---> Referenciada - 07 diarias
           continue while
        end if

        if l_retorno.clscod = "58I" then
           let l_retorno.clscod = "58J" ---> Referenciada - 15 diarias
           continue while
        end if

        if l_retorno.clscod = "58J" then
           let l_retorno.clscod = "58K" ---> Referenciada - 30 diarias
           continue while
        end if

        if l_retorno.clscod = "58K" then
           let l_retorno.clscod = "58L" ---> Livre Escolha - 07 diarias
           continue while
        end if

        if l_retorno.clscod = "58L" then
           let l_retorno.clscod = "58M" ---> Livre Escolha - 15 diarias
           continue while
        end if

        if l_retorno.clscod = "58M" then
           let l_retorno.clscod = "58N" ---> Livre Escolha - 30 diarias
           continue while
        end if

        if l_retorno.clscod = "58N" then
           return l_retorno.*
        end if

    end while

    return l_retorno.*

 end function

