#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: Atendimento Segurado                                       #
# Modulo.........: cts20g04                                                   #
# Analista Resp..: Ligia Mattge                                               #
# PSI/OSF........: 190772                                                     #
#                  Obter codigo e nome do corretor atraves da ligacao.        #
#                                                                             #
# ........................................................................... #
# Desenvolvimento: Meta, Adriano Gerling                                      #
# Liberacao......: 03/03/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

define m_cts20g04_prep smallint

#-------------------------#
function cts20g04_prepare()
#-------------------------#
 define l_sql char(300)

 let l_sql = ' select a.corsus '
              ,' from datrligcor a , datmligacao b '
             ,' where a.lignum = b.lignum '
               ,' and a.dctcomatdflg = "N" '
               ,' and a.lignum = ? '
 prepare p_cts20g04_001 from l_sql
 declare c_cts20g04_001 cursor for p_cts20g04_001

 let m_cts20g04_prep = true

end function

#------------------------------------------#
function cts20g04_corretor_ligacao(l_lignum)
#------------------------------------------#
 define l_lignum like datrligcor.lignum

 define lr_retorno record
        resultado  smallint
       ,mensagem   char(60)
       ,corsus     like datrligcor.corsus
       ,cornom     like gcakcorr.cornom
 end record

 define l_msg    char(60)

 if m_cts20g04_prep is null or
    m_cts20g04_prep <> true then
    call cts20g04_prepare()
 end if

 initialize lr_retorno.* to null

 let l_msg = null
 let lr_retorno.resultado = 1

 open c_cts20g04_001 using l_lignum
 whenever error continue
 fetch c_cts20g04_001 into lr_retorno.corsus
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem = "Ligacao nao encontrada"
    else
       let lr_retorno.resultado = 3
       let l_msg = " Erro de SELECT - c_cts20g04_001 ",sqlca.sqlcode," / ",sqlca.sqlerrd[2]
       call errorlog(l_msg)
       let l_msg = " cts20g04_corretor_ligacao() / ",l_lignum
       call errorlog(l_msg)
       let lr_retorno.mensagem = "Erro ", sqlca.sqlcode, " em datrligcor/datmligacao"
    end if
 else
    call cty00g00_nome_corretor(lr_retorno.corsus)
         returning lr_retorno.resultado, lr_retorno.mensagem, lr_retorno.cornom
 end if
 close c_cts20g04_001

 return lr_retorno.*

end function
