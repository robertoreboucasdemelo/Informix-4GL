#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: Atendimento Segurado                                       #
# Modulo.........: cts20g06                                                   #
# Analista Resp..: Ligia Mattge                                               #
# PSI/OSF........: 190772                                                     #
#                  Obter informacoes da vistoria de sinistros                 #
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

define m_cts20g06_prep smallint

#-------------------------#
function cts20g06_prepare()
#-------------------------#

 define l_sql char(200)

 let l_sql = ' select 1 '
              ,' from datmpedvist '
             ,' where sinvstnum = ? '
               ,' and sinvstano = ? '

 prepare p_cts20g06_001 from l_sql
 declare c_cts20g06_001 cursor for p_cts20g06_001

 let m_cts20g06_prep = true

end function

#------------------------------------------------------------------------#
function cts20g06_obter_vstsin(l_nivel_retorno, l_sinvstnum, l_sinvstano)
#------------------------------------------------------------------------#
 define l_nivel_retorno smallint
       ,l_sinvstnum     like datmpedvist.sinvstnum
       ,l_sinvstano     like datmpedvist.sinvstano

 define lr_retorno record
        resultado  smallint
       ,mensagem   char(60)
 end record

 define l_msg   char(80)

 if m_cts20g06_prep is null or
    m_cts20g06_prep <> true then
    call cts20g06_prepare()
 end if

 initialize lr_retorno to null

###
 if l_nivel_retorno = 1 then
    let lr_retorno.resultado = 1

    open c_cts20g06_001 using l_sinvstnum
                           ,l_sinvstano
    whenever error continue
       fetch c_cts20g06_001
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem = "Vistoria de sinistro nao encontrada"
       else
          let lr_retorno.resultado = 3
          let l_msg = " Erro de SELECT - c_cts20g06_001 ",sqlca.sqlcode," / ",sqlca.sqlerrd[2]
          call errorlog(l_msg)
          let l_msg = " cts20g06_obter_vstsin() / ",l_sinvstnum, " / "
                                                   ,l_sinvstano
          call errorlog(l_msg)
          let lr_retorno.mensagem = "Erro ", sqlca.sqlcode, " em datmpedvist "
       end if
    end if
    close c_cts20g06_001

    return lr_retorno.*

 end if

end function
