#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS40G04                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: 195138                                                     #
#                  MODULO RESPO. POR VERIFICAR SE O GPS ESTA ATIVO.           #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 04/11/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

#------------------------------------------#
function cts40g04_verifica_gps(lr_parametro)
#------------------------------------------#

  define lr_parametro  record
         cidnom        like datmlcl.cidnom,
         ufdcod        like datmlcl.ufdcod,
         atmacnprtcod  like datkatmacnprt.atmacnprtcod
  end record

  define l_cidcod       like glakcid.cidcod,
         l_cidsedcod    like datrcidsed.cidsedcod,
         l_resultado    smallint,
         l_ativo        smallint,
         l_mensagem     char(100),
         l_acnsttflg    like datracncid.acnsttflg

  # --INICIALIZACAO DAS VARIAVEIS

  let l_cidcod    = null
  let l_cidsedcod = null
  let l_resultado = null
  let l_mensagem  = null
  let l_acnsttflg = null
  let l_ativo     = null

  # --OBTER O CODIGO DA CIDADE
  call cty10g00_obter_cidcod(lr_parametro.cidnom,
                             lr_parametro.ufdcod)

       returning l_resultado,
                 l_mensagem,
                 l_cidcod

  if l_resultado = 0 then

     # --OBTER O CODIGO DA CIDADE SEDE
     call ctd01g00_obter_cidsedcod(1, l_cidcod)

          returning l_resultado,
                    l_mensagem,
                    l_cidsedcod

     if l_resultado = 1 then

        # --OBTER O FLAG DE ACIONAMENTO DA TABELA DE PARAMETRIZACAO
        call cts40g00_obter_flg_acio(lr_parametro.atmacnprtcod,
                                     l_cidsedcod)

             returning l_resultado,
                       l_mensagem,
                       l_acnsttflg
     end if

  end if

  if l_acnsttflg is not null then
     if l_acnsttflg = "I" then
        # --GPS INATIVO
        let l_ativo = 1
     else
        # --GPS ATIVO
        let l_ativo = 2
     end if
  else
     # --ACIONAMENTO VIA INTERNET, POIS A CIDADE TEM GPS MAS NAO ATENDE RE
     let l_ativo = 3
  end if

  return l_ativo

end function
