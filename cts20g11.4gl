#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS20G11                                                   #
# ANALISTA RESP..: CARLOS RUIZ                                                #
# PSI/OSF........: 202720                                                     #
#                  MOD. RESPONSAVEL POR IDENTIFICAR O TIPO DE DOCUMENTO DE    #
#                  UM SERVICO - APOLICE, SAUDE, PROPOSTA, CONTRATO, SEMDOCTO  #
# ........................................................................... #
# DESENVOLVIMENTO: PRISCILA                                                   #
# LIBERACAO......: 29/09/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------#
function cts20g11_identifica_tpdocto(lr_parametro)
#----------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record
 
  define l_tpdocto  char(15)

  define l_resultado  smallint,
         l_mensagem   char(80)
  define l_aplnumdig  like datrservapol.aplnumdig,
         l_succod     like datrservapol.succod,
         l_ramcod     like datrservapol.ramcod,
         l_itmnumdig  like datrservapol.itmnumdig
  define l_crtnum     like datrsrvsau.crtnum
  define l_lignum     like datmligacao.lignum
  define l_prporg     like datrligprp.prporg,
         l_prpnumdig  like datrligprp.prpnumdig
  define l_cmnnumdig  like datrligppt.cmnnumdig
  
  let l_tpdocto = null 
  let l_resultado = 0
  let l_mensagem = null
  let l_aplnumdig = null
  let l_succod = null
  let l_ramcod = null
  let l_itmnumdig = null
  let l_crtnum = null
  let l_lignum = null
  let l_prporg = null
  let l_prpnumdig = null

  #caso nao veio num e ano servico, identificar tipo de documento utilizando
  # as variaveis globais
  if lr_parametro.atdsrvnum is null or
     lr_parametro.atdsrvano is null then

     if g_documento.succod    is not null  and
        g_documento.ramcod    is not null  and
        g_documento.aplnumdig is not null  and
        g_documento.itmnumdig is not null  then 
        #caso tenha sucrsal, ramo, apolice e item preenchidos
        # documento é apolice
        let l_tpdocto = "APOLICE"
        return l_tpdocto
     end if

     if g_documento.prporg    is not null  and
        g_documento.prpnumdig is not null  then
        #caso tenha numero e ano proposta - documento e proposta
        let l_tpdocto = "PROPOSTA"
        return l_tpdocto
     end if

     if g_documento.crtsaunum is not null then
        #caso tenha numero do cartao - documento e tipo saude
        let l_tpdocto = "SAUDE"
        return l_tpdocto
     end if

     if g_ppt.cmnnumdig is not null   then
        #tipo documento e Contrato
        let l_tpdocto = "CONTRATO"
        return l_tpdocto
     end if
      
     #caso nao tenha nenhum documento preenchido e servico sem documento    
     let l_tpdocto = "SEMDOCTO"
     return l_tpdocto

  end if


  #caso numero e ano do servico estao preenchidos, buscar o tipo de documento
  # conforme gravado em tabelas
  
  #verifica se documento e do tipo apolice
  call cts20g13_obter_apolice(lr_parametro.atdsrvnum,
                              lr_parametro.atdsrvano)
       returning l_resultado,
                 l_mensagem,
                 l_aplnumdig,
                 l_succod,
                 l_ramcod,
                 l_itmnumdig 
  if l_resultado = 1 then
     #encontrou dados da apolice para o servico - logo tipo documento e apolice
     let l_tpdocto = "APOLICE"
     return l_tpdocto
  end if

  #verifica se documento e do tipo saude
  call cts20g10_cartao(1, 
                       lr_parametro.atdsrvnum, 
                       lr_parametro.atdsrvano)
       returning l_resultado,
                 l_mensagem,
                 l_crtnum

  if l_resultado = 1 then
     #encontrou informacoes do cartao saude
     let l_tpdocto = "SAUDE"
     return l_tpdocto
  end if
 
  #busca numero da ligacao do servico
  call cts20g00_servico(lr_parametro.atdsrvnum,
                        lr_parametro.atdsrvano)
       returning l_lignum

  #verifica se documento e propsta
  call cts20g00_proposta(l_lignum)
       returning l_resultado
                ,l_mensagem
                ,l_prporg 
                ,l_prpnumdig
  if l_resultado = 1 then
     #encontrou informacoes da proposta - logo tipo documento e proposta
     let l_tpdocto = "PROPOSTA"
     return l_tpdocto
  end if
 
  #verifica se documento e contrato
  call cts20g12_contrato(l_lignum)
       returning l_resultado,
                 l_mensagem,
                 l_cmnnumdig
  if l_resultado = 1 then
     #encontrou dados do contrato para servico , logo documento e contrato
     let l_tpdocto = "CONTRATO"
     return l_tpdocto
  end if
  
  #caso chegou até aqui e pq nao encontrou nenhum documento
  # entao o servico e sem documento
  let l_tpdocto = "SEMDOCTO"
  return l_tpdocto 

end function
