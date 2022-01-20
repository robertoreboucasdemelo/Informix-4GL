#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                                          #
#.............................................................................#
#  Sistema        : Central 24 horas                                          #
#  Modulo         : cts39g00.4gl                                              #
#                   Atualizar informacoes para transferir ligacoes            #
#  Analista Resp. : Priscila                                                  #
#  PSI            : 199850                                                    #
#.............................................................................#
#  Desenvolvimento:                                                           #
#  Liberacao      : Set/2006                                                  #
#.............................................................................#
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

function cts39g00_transfere_ligacao(param)

  define param record
      pa_atendente   like sremligsnc.pnacod,
      chave          like sremligsnc.sncinftxt
  end record

  update sremligsnc
         set ligstt = 2,
             sncinftxt = param.chave
         where pnacod = param.pa_atendente
           and ligstt = 1
  if  sqlca.sqlcode <> 0  then
      error " Erro (", sqlca.sqlcode, ") na gravacao do",
            " reclamante. AVISE A INFORMATICA!"
      return false
  end if
  return true
end function
