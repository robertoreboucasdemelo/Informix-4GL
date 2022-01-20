#_----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTS20G16                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 202720 - SAUDE + CASA                                      #
#                  FORMATACAO DO CARTAO - COM 16 OU 18 CARACTERES.            #
# ........................................................................... #
# DESENVOLVIMENTO: PRISCILA STAINGEL                                          #
# LIBERACAO......: 03/10/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM          ALTERACAO                        #
# ---------- --------------  --------------  -------------------------------- #
# 13/11/2006 Lucas Scheid    Solic. Interna  Se o tamanho do cartao for dife- #
#                                            rente de 16 e 18 digitos, retor- #
#                                            na o numero do cartao passado co-#
#                                            mo parametro. Esta alteracao e p/#
#                                            atender os cartoes c/menos de 16 #
#                                            digitos.                         #
#-----------------------------------------------------------------------------#

database porto

#-------------------------------------------#
function cts20g16_formata_cartao(l_crtsaunum)
#-------------------------------------------#

  # -> FORMATA A EXIBICAO DO CARTAO NO FOMATO xxx.xxxx.xxxx.xxxx
  #  quando cartao de 16 posicoes

  # -> FORMATAR A EXIBICAO DO CARTAO NO FOMATO xxxxx.xxxxxxxx.xxx.xx
  #  quando cartao de 18 posicoes

  # -> SE CARTAO MENOR QUE 16 POSICOES
  #  retorna o cartao passado como parametro

  define l_crtsaunum    like datksegsau.crtsaunum,
         l_novo_formato char(21),
         l_tam          smallint

  let l_novo_formato = null
  let l_novo_formato = l_crtsaunum

  let l_tam = length(l_crtsaunum)

  if l_tam = 16 then
     let l_novo_formato = l_crtsaunum[1,4]   clipped, ".",
                          l_crtsaunum[5,8]   clipped, ".",
                          l_crtsaunum[9,12]  clipped, ".",
                          l_crtsaunum[13,16]
  else
     if l_tam = 18 then
        let l_novo_formato = l_crtsaunum[1,5]   clipped, ".",
                             l_crtsaunum[6,13]  clipped, ".",
                             l_crtsaunum[14,16] clipped, ".",
                             l_crtsaunum[17,18]
     end if
  end if

  #SE TAMANHO DIFERENTE DE 16 E 18 - RETORNA O CARTAO PASSADO COMO PARAMETRO
  return l_novo_formato

end function
