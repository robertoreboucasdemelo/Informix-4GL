#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                                          #
#.............................................................................#
#  Sistema        : Central 24 horas                                          #
#  Modulo         : cts38g00.4gl                                              #
#                   Gravar reclamacao em datmreclam                           #
#  Analista Resp. : Priscila                                                  #
#  PSI            : 199850                                                    #
#.............................................................................#
#  Desenvolvimento:                                                           #
#  Liberacao      : Ago/2006                                                  #
#.............................................................................#
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

function cts38g00_ins_datmreclam(param)
     define param record
        lignum          like datmreclam.lignum     ,
        dddcod          like datmreclam.dddcod     ,
        ctttel          like datmreclam.ctttel     ,
        faxnum          like datmreclam.faxnum     ,
        cttnom          like datmreclam.cttnom     ,
        atdsrvnum_rcl   like datmservico.atdsrvnum ,
        atdsrvano_rcl   like datmservico.atdsrvano
     end record
     insert into datmreclam ( lignum,
                              dddcod,
                              ctttel,
                              faxnum,
                              cttnom,
                              atdsrvnum,
                              atdsrvano)
                     values ( param.lignum,
                              param.dddcod,
                              param.ctttel,
                              param.faxnum,
                              param.cttnom,
                              param.atdsrvnum_rcl,
                              param.atdsrvano_rcl)
     if  sqlca.sqlcode <> 0  then
         error " Erro (", sqlca.sqlcode, ") na gravacao do",
               " reclamante. AVISE A INFORMATICA!"
         return false
     end if
     return true
end function
