#----------------------------------------------------------------------------#
# Porto seguro Cia seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Atendimento segurado                                       #
# Modulo        : cta02m19                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 190772                                                     #
#                 Consultar historico de acordo com os parametros recebidos. #
#                 Pode ser consultado o historico do servico, da vistoria de #
#                 sinistro, do aviso de sinistro ou da ligacao.              #
#............................................................................#
# Desenvolvimento: Robson Inocencio, META                                    #
# Liberacao      : 03/03/2005                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 03/03/2006 Priscila          Zeladoria  Buscar data e hora do banco de dado#
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

#------------------------------------#
function cta02m19_historico(lr_param)
#------------------------------------#
 define lr_param record
    atdsrvnum like datmlimpeza.atdsrvnum
   ,atdsrvano like datmlimpeza.atdsrvano
   ,sinvstnum like datmvstsin.sinvstnum
   ,sinvstano like datmvstsin.sinvstano
   ,sinavsnum like ssamavsdes.sinavsnum
   ,sinavsano like ssamavsdes.sinavsano
   ,cnslignum like datmlighist.lignum
   ,lignum    like datmlighist.lignum
 end record

 define lr_cts10g08_servico record
    resultado smallint
   ,mensagem  char(60)
 end record

 define l_data          date,
        l_hora2         datetime hour to minute

 initialize lr_cts10g08_servico to null

 if lr_param.atdsrvnum is not null and
    lr_param.atdsrvano is not null then
    call cts10g08_servico(lr_param.atdsrvnum
                         ,lr_param.atdsrvano)
    returning lr_cts10g08_servico.*

    call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2

    if lr_cts10g08_servico.resultado <> 1 then
       call cts10n00(lr_param.atdsrvnum
                    ,lr_param.atdsrvano
                    ,g_issk.funmat
                    ,l_data
                    ,l_hora2)
    else
       error " Servico ja  foi removido pelo sistema!" sleep 2
    end if
 end if
 if lr_param.sinvstnum is not null and
    lr_param.sinvstano is not null then

    call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2

    call cts14m10(lr_param.sinvstnum
                 ,lr_param.sinvstano
                 ,g_issk.funmat
                 ,l_data
                 ,l_hora2)
 end if
 if lr_param.sinavsnum is not null and
    lr_param.sinavsano is not null then
    call cts18n04(lr_param.sinavsnum
                 ,lr_param.sinavsano)
 end if
 if lr_param.cnslignum is not null then
    call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
    call cta03n00(lr_param.cnslignum
                 ,g_issk.funmat
                 ,l_data
                 ,l_hora2)
 else
    if lr_param.atdsrvnum is null and
       lr_param.atdsrvano is null and
       lr_param.sinvstnum is null and
       lr_param.sinvstano is null and
       lr_param.sinavsnum is null and
       lr_param.sinavsano is null then
       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       call cta03n00(lr_param.lignum
                    ,g_issk.funmat
                    ,l_data
                    ,l_hora2)
    end if
 end if

end function
