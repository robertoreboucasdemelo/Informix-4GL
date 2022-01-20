#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CENTRAL 24 HORAS                                           #
# Modulo        : cty01g01                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 183431                                                     #
# OSF           : 036439                                                     #
#                 Chamada do metodo fsauc530.                                #
#............................................................................#
# Desenvolvimento: Robson, META                                              #
# Liberacao      : 19/07/2004                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

#---------------------------------------------------------------------------------#
function cty01g01_fsauc530(l_ramcod, l_sinano, l_sinnum, l_sinvstano, l_sinvstnum)
#---------------------------------------------------------------------------------#
 define l_ramcod    like ssamsin.ramcod
       ,l_sinano    like ssamsin.sinano
       ,l_sinnum    like ssamsin.sinnum
       ,l_sinvstano like ssamsin.sinvstano
       ,l_sinvstnum like ssamsin.sinvstnum
       ,l_erro      char(80)
 define lr_retorno record
    resultado smallint
   ,mensagem  char(30)
   ,sinramcod like ssamsin.ramcod
   ,sinano    like ssamsin.sinano
   ,sinnum    like ssamsin.sinnum
   ,sinitmseq like ssamitem.sinitmseq
 end record
 initialize lr_retorno to null
 let lr_retorno.resultado = 1
 let l_erro = null

 if (l_ramcod is null or
     l_sinano is null or
     l_sinnum is null) and
    (l_sinvstano is null or
     l_sinvstnum is null) then
    let l_erro = 'Sinistro recebido por parametro nao deve ser nulo'
    call errorlog(l_erro)
    let lr_retorno.mensagem = ' Sinistro nao deve ser nulo'
    let lr_retorno.resultado = 2
 else
    call fsauc530(l_ramcod, l_sinano, l_sinnum, l_sinvstano, l_sinvstnum)
    returning lr_retorno.sinramcod
             ,lr_retorno.sinano
             ,lr_retorno.sinnum
             ,lr_retorno.sinitmseq
 end if

 return lr_retorno.*
end function
