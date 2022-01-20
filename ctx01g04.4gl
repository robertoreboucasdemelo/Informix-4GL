#------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                        #
#........................................................................#
# Sistema        : CT24H                                                 #
# Modulo         : ctx01g04.4gl                                          #
# Analista.Resp  : Ligia Mattge                                          #
# PSI            : 187887                                                #
# Objetivo       : Liberar o beneficio de concessao de carro extra.      #
#                  Reverte o motivo da locacao, desmarca a solicitacao   #
#                  e inclui historico do servico.                        #
# Obs            : Funcao ctx01g04_liberar  vai ser usada para BATCH E   #
#                  ON-LINE                                               #
#........................................................................#
# Desenvolvimento: Adriana Schneider - Fabrica de Software - Meta        #
# Liberacao      : 20/12/2004                                            #
#........................................................................#
#                    * * * Alteracoes * * *                              #
#                                                                        #
#    Data      Autor Fabrica Origem    Alteracao                         #
#  ----------  ------------- --------- ----------------------------------#
#  28/12/2004  Marcio - Meta PSI       Excluir as funcoes                #
#                            187887    ctx01g04_liberar() e              #
#                                      ctx01g04_excluir() e adicionar a  #
#                                      funcao ctx01g04_ver_sinistro().   #
#------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------#
function ctx01g04_ver_sinistro(lr_param)
#------------------------------------------#
  define lr_param record
     atdsrvnum     like datmvclapltrc.atdsrvnum,
     atdsrvano     like datmvclapltrc.atdsrvano,
     succod        like datmvclapltrc.succod,
     aplnumdig     like datmvclapltrc.aplnumdig,
     itmnumdig     like datmvclapltrc.itmnumdig
  end record

  define lr_retorno record
     result        smallint,
     mensagem      char(80),
     motivo        like datmavisrent.avialgmtv
  end record

  define lr_ctx01g05 record
     succod_ter    like datmvclapltrc.succod,
     aplnumdig_ter like datmvclapltrc.aplnumdig,
     itmnumdig_ter like datmvclapltrc.itmnumdig
  end record

  define lr_cty05g01 record
     resultado     char(01),
     dctnumseg     dec(04),
     vclsitatu     dec(04),
     autsitatu     dec(04),
     dmtsitatu     dec(04),
     dpssitatu     dec(04),
     appsitatu     dec(04),
     vidsitatu     dec(04)
  end record

  define lr_cty05g00 record
     vcllicnum_ter  like abbmveic.vcllicnum,
     chassi_ini_ter like abbmveic.vclchsinc,
     chassi_fim_ter like abbmveic.vclchsfnl,
     vclanofbc      like abbmveic.vclanofbc,
     vclcoddig      like abbmveic.vclcoddig
  end record

  define lr_ossaa009 record
     data_ocorrencia date,
     telefone        char(10),
     data_prevista   date,
     confirma        char(01)
  end record

  define l_c24astcod  like datmligacao.c24astcod,
         l_c24funmat  like datmligacao.c24funmat,
         l_c24empcod  like datmligacao.c24empcod

 define l_sinvstano    like ssamsin.sinvstano,
        l_sinvstnum    like ssamsin.sinvstnum         

  initialize lr_retorno.*  to null
  initialize lr_ctx01g05.* to null
  initialize lr_cty05g01.* to null
  initialize lr_cty05g00.* to null
  initialize lr_ossaa009.* to null

  let lr_retorno.result = 0
  let l_c24astcod       = null
  let l_c24funmat       = null
  let l_c24empcod       = null

  ## Obter o assunto do servico de locacao carro extra
  call cts10g06_assunto_servico(lr_param.atdsrvnum,
                                lr_param.atdsrvano)
     returning lr_retorno.result,
               lr_retorno.mensagem,
               l_c24astcod,
               l_c24funmat,
               l_c24empcod

  if lr_retorno.result <> 1 then
     let lr_retorno.motivo = null
     return lr_retorno.*
  end if

  if g_issk.funmat is null then
     let g_issk.funmat = l_c24funmat
     let g_issk.dptsgl = "ct24hs"
     let g_issk.empcod = l_c24empcod
  end if

  ## Locacao de carro extra para segurado-terceiro Porto
  if l_c24astcod = "H11" or
     l_c24astcod = "H13" then

     ## Obter apolide do segurado terceiro
     call ctx01g05_obter_apol_ter(lr_param.atdsrvnum,lr_param.atdsrvano)
                    returning lr_retorno.result,
                              lr_retorno.mensagem,
                              lr_ctx01g05.succod_ter,
                              lr_ctx01g05.aplnumdig_ter,
                              lr_ctx01g05.itmnumdig_ter

     if lr_retorno.result <> 1 then
        let lr_retorno.result = 2
        let lr_retorno.motivo = null
        return lr_retorno.*
     end if

     ## Obter a ultima situacao da apolice do segurado-terceiro
     call cty05g01_ultsit_apolice(lr_ctx01g05.succod_ter,
                                  lr_ctx01g05.aplnumdig_ter,
                                  lr_ctx01g05.itmnumdig_ter)
                    returning lr_cty05g01.*

     if lr_cty05g01.resultado <> "O" then
        let lr_retorno.result = 2
        let lr_retorno.mensagem = "Ultima situacao da apolice nao encontrada. AVISE A INFORMATICA !"
        let lr_retorno.motivo = null
        return lr_retorno.*
     end if

     ## Obter chassi e placa do veiculo do segurado-terceiro
     call cty05g00_dados_veic(lr_ctx01g05.succod_ter,
                              lr_ctx01g05.aplnumdig_ter,
                              lr_ctx01g05.itmnumdig_ter,
                              lr_cty05g01.vclsitatu)
                 returning lr_retorno.result,
                           lr_retorno.mensagem,
                           lr_cty05g00.vcllicnum_ter,
                           lr_cty05g00.chassi_ini_ter,
                           lr_cty05g00.chassi_fim_ter,
                           lr_cty05g00.vclanofbc     ,
                           lr_cty05g00.vclcoddig

     if lr_retorno.result <> 1 then
        let lr_retorno.result = 2
        let lr_retorno.motivo = null
        return lr_retorno.*
     end if
  end if

  if lr_cty05g00.vcllicnum_ter is null or
     lr_cty05g00.vcllicnum_ter = "" then
     let lr_retorno.motivo = 3
  else
     let lr_retorno.motivo = 6
  end if


  ## Locacao de carro extra para segurado
  if l_c24astcod = "H10" or
     l_c24astcod = "H12" then
     let lr_retorno.motivo = 3
  end if

  ## Locacao de carro extra para segurado-terceiro Porto
  if l_c24astcod = "H11" or
     l_c24astcod = "H13" then
     let lr_retorno.motivo = 6
  end if

  ## Verificar as consistencias na base do sinistro
  call ossaa009_vistorias(lr_param.succod,
                          lr_param.aplnumdig,
                          lr_param.itmnumdig,
                          lr_ctx01g05.succod_ter,
                          lr_ctx01g05.aplnumdig_ter,
                          lr_ctx01g05.itmnumdig_ter,
                          lr_cty05g00.chassi_ini_ter,
                          lr_cty05g00.chassi_fim_ter,
                          lr_cty05g00.vcllicnum_ter,
                          lr_retorno.motivo,"A")
             returning  lr_ossaa009.data_ocorrencia,
                        lr_retorno.mensagem ,
                        lr_ossaa009.telefone,
                        lr_ossaa009.data_prevista ,
                        lr_ossaa009.confirma,
                        l_sinvstano,
                        l_sinvstnum                        

  if lr_ossaa009.confirma = 1 then
     let lr_retorno.result = 2
  else
     let lr_retorno.result = 1
  end if

  return lr_retorno.*

end function

