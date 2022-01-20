#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Atendimento Segurado                                       #
# Modulo        : cta02m21                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 190772                                                     #
#                 Chamada para alteracao, reclamacao, cancelamento, consulta #
#                 ou indicacao.                                              #
#............................................................................#
# Desenvolvimento: Robson Inocencio, META                                    #
# Liberacao      : 03/03/2005                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 07/03/06   Priscila          Zeladoria  Buscar data e hora do banco de dado#
#----------------------------------------------------------------------------#

database porto

#----------------------------------#
function cta02m21_chamada(lr_param)
#----------------------------------#
 define lr_param record
    atdetpdes    char(09)
   ,lignum       like datmligacao.lignum
   ,atdsrvnum    like datmlimpeza.atdsrvnum
   ,atdsrvano    like datmlimpeza.atdsrvano
   ,sinvstnum    like datrligsinvst.sinvstnum
   ,sinvstano    like datrligsinvst.sinvstano
   ,sinavsnum    like datrligsinavs.sinavsnum
   ,sinavsano    like datrligsinavs.sinavsano
   ,c24astcod    like datmligacao.c24astcod
   ,cnslignum    like datrligcnslig.cnslignum
   ,solnom       like datmligacao.c24solnom
   ,c24soltipcod like datmligacao.c24soltipcod
   ,ramcod       like datrligapol.ramcod
 end record

 define lr_cts10g08_servico record
    resultado smallint
   ,mensagem  char(60)
 end record

 define l_resultado smallint
       ,l_mensagem  char(60)
       ,l_trpavbnum like datrligtrpavb.trpavbnum

 define l_data          date,
        l_hora2         datetime hour to minute

 initialize lr_cts10g08_servico to null

 let l_resultado = 1
 let l_mensagem  = null
 let l_trpavbnum = null

 if lr_param.atdetpdes = "AVERBACAO" then
    ##-- Obter numero da averbacao
    call cts20g03_avb_ligacao(lr_param.lignum)
    returning l_resultado
             ,l_mensagem
             ,l_trpavbnum

    if l_resultado = 1 then
       call cts27m00(l_trpavbnum,"cta02m02")
       error ""
    else
       error "Ligacao nao tem numero de embarque! " sleep 2
    end if
 else
     if lr_param.atdsrvnum is null and
        lr_param.atdsrvano is null and
        lr_param.sinvstnum is null and
        lr_param.sinvstano is null and
        lr_param.sinavsnum is null and
        lr_param.sinavsano is null then

        call cts40g03_data_hora_banco(2)
             returning l_data, l_hora2
        if lr_param.c24astcod = "CON" then
           if lr_param.cnslignum is not null and
              lr_param.cnslignum <> 0 then
              call cts16m03(lr_param.cnslignum
                           ,l_data
                           ,l_hora2
                           ,lr_param.solnom
                           ,lr_param.c24soltipcod)
           end if
        else
           call cts16m03(lr_param.lignum
                        ,l_data
                        ,l_hora2
                        ,lr_param.solnom
                        ,lr_param.c24soltipcod)
        end if
     end if
 end if

 if lr_param.atdsrvnum is not null and
    lr_param.atdsrvano is not null then
    call cts10g08_servico(lr_param.atdsrvnum
                         ,lr_param.atdsrvano)
    returning lr_cts10g08_servico.*

    if lr_cts10g08_servico.resultado = 2 then
       call cts16m01(lr_param.solnom
                    ,lr_param.c24soltipcod
                    ,lr_param.atdsrvnum
                    ,lr_param.atdsrvano
                    ,lr_param.c24astcod)
       error ""
    else
       error "Servico ja  foi removido pelo sistema!" sleep 2
    end if
 end if

 if lr_param.sinvstnum is not null and
    lr_param.sinvstano is not null then
    if lr_param.ramcod = 31  or
       lr_param.ramcod = 531 then
       call cts16m02(lr_param.solnom
                    ,lr_param.c24soltipcod
                    ,lr_param.sinvstnum
                    ,lr_param.sinvstano
                    ,""
                    ,""
                    ,lr_param.c24astcod)
       error ""
    else
       call cts16m02(lr_param.solnom
                    ,lr_param.c24soltipcod
                    ,lr_param.sinvstnum
                    ,lr_param.sinvstano
                    ,""
                    ,""
                    ,lr_param.c24astcod)
       error ""
    end if
 end if

 if lr_param.sinavsnum is not null and
    lr_param.sinavsano is not null then
    call cts16m02(lr_param.solnom
                 ,lr_param.c24soltipcod
                 ,""
                 ,""
                 ,lr_param.sinavsnum
                 ,lr_param.sinavsano
                 ,lr_param.c24astcod)
    error ""
 end if

end function
