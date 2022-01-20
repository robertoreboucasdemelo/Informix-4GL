#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : cts41g03.4gl                                        #
# Analista Resp.: Priscila Staingel                                   #
# OSF/PSI       : 202363                                              #
#                Trata cotas para serviço imediato                    #
#                                                                     #
# Desenvolvedor  : Priscila Staingel                                  #
# DATA           : 28/08/2006                                         #
#                                                                     #
# Objetivo: Funcoes de "controle" para verificar se existe veiculo    #
#           disponivel para atender o servico imediato                #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
#---------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


#-----------------------------------------------------#
function cts41g03_tipo_acion_cidade (param)
#-----------------------------------------------------#
    define param record
           cidnom       like datmlcl.cidnom,
           ufdcod       like datmlcl.ufdcod,
           atmacnprtcod like datkatmacnprt.atmacnprtcod,
           atdsrvorg    like datrorgcidacntip.atdsrvorg
    end record

    define l_result     smallint,
           l_msg        char(80),
           l_situacao_gps smallint,
           l_cidcod     like glakcid.cidcod,
           l_cidsedcod  like glakcid.cidcod,
           l_cidsednom  like datmlcl.cidnom,
           l_cidseduf   like datmlcl.ufdcod,
           l_gpsacngrpcod  like datkmpacid.gpsacngrpcod

   define lr_cts23g00   record
          resultado     integer,
          mpacidcod     like datkmpacid.mpacidcod,
          lclltt        like datkmpacid.lclltt,
          lcllgt        like datkmpacid.lcllgt,
          mpacrglgdflg  like datkmpacid.mpacrglgdflg,
          gpsacngrpcod  like datkmpacid.gpsacngrpcod
  end record  

  let l_msg = null
  let l_situacao_gps = null
  initialize lr_cts23g00.* to null
  let l_gpsacngrpcod = null
  

  #obter codigo da cidade
  call cty10g00_obter_cidcod(param.cidnom, param.ufdcod)
       returning l_result,
                 l_msg,
                 l_cidcod

  if l_result <> 0 then
     ##call errorlog(l_msg)
     return 2, l_msg, 0,0
  end if

  #obter código da cidade sede
  call ctd01g00_obter_cidsedcod(1, l_cidcod)
       returning l_result,
                 l_msg,
                 l_cidsedcod

  ## Se nao achou cidade sede, deixar acionar p/internet
  ## pois existem cidades que nao tem cidade sede e controle de cota.
  if l_result <> 1 then
     return 1, l_msg, 0, l_cidcod
  end if

  # -> BUSCA INFORMACOES SOBRE A CIDADE SEDE DO SERVICO
  initialize lr_cts23g00.* to null
  call cts23g00_inf_cidade(2,
                           l_cidsedcod,
                           "",
                           "")
       returning lr_cts23g00.resultado,
                 lr_cts23g00.mpacidcod,
                 lr_cts23g00.lclltt,
                 lr_cts23g00.lcllgt,
                 lr_cts23g00.mpacrglgdflg,
                 lr_cts23g00.gpsacngrpcod

  if lr_cts23g00.resultado <> 0 then
     if lr_cts23g00.resultado = 100 then
        let l_msg =  "Nao encontrou informacoes sobre a cidade: ",
                     param.cidnom clipped, ' - ' , param.ufdcod
     else
        let l_msg = "Erro na funcao cts23g00_inf_cidade()"
     end if
     return 2, l_msg, 0,0
  end if
  
  # verifica Tipo Acionamento por origem do serviço e cidade
  
  whenever error continue 
  
     select gpsacngrpcod into l_gpsacngrpcod
       from datrorgcidacntip
         where mpacidcod = lr_cts23g00.mpacidcod
           and atdsrvorg = param.atdsrvorg
     
     #Sistema considera Tipo de Acioanamento se tiver cadastro para origem informada
     if sqlca.sqlcode == 0   then 
        if l_gpsacngrpcod is not null then                          
           let lr_cts23g00.gpsacngrpcod = l_gpsacngrpcod
        end if
     end if
  whenever error stop
           
  

  if lr_cts23g00.gpsacngrpcod > 0 then
     # -> CHAMA A FUNCAO P/VERIFICAR A SITUACAO DO GPS
     let l_situacao_gps = cts40g04_verifica_gps(param.cidnom,
                                                param.ufdcod,
                                                param.atmacnprtcod)
     if l_situacao_gps <> 2 then
        if l_situacao_gps = 1 then
           # -> SE O ACIONAMENTO GPS ESTIVER INATIVO PARA A CIDADE,
           ##   DESPREZA O S ERVICO
           let l_msg = "Acionamento GPS inativo"
           return 2, l_msg,0,0
        else
           # -> GPS ATIVO, MAS O SERVICO SERA ENVIADO VIA INTERNET
           # -> POIS A CIDADE NAO ATENDE SERVICOS RE VIA GPS
           let lr_cts23g00.gpsacngrpcod = 0
        end if
     end if
  end if
  
  #display 'l_msg                   ',l_msg                   
  #display 'lr_cts23g00.gpsacngrpcod',lr_cts23g00.gpsacngrpcod
  #display 'lr_cts23g00.mpacidcod   ',lr_cts23g00.mpacidcod   
 
  return 1, l_msg, lr_cts23g00.gpsacngrpcod, lr_cts23g00.mpacidcod

end function
