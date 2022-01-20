############################################################################
# Nome do Modulo: GLCTE                                               Akio #
#                                                                     Ruiz #
# Definicao das variaveis globais do sistema CENTRAL 24 HORAS     Abr/2000 #
# para atendimento do CORRETOR                                             #
############################################################################

database porto

globals

#------------------------------------------------------------------------------
# Registro de seguranca do sistema (nao alterar)
#------------------------------------------------------------------------------

 define g_issk      record
    succod          like isskfunc.succod,         # Sucursal
    funmat          like isskfunc.funmat,         # Matricula Funcionario
    funnom          like isskfunc.funnom,         # Nome Funcionario
    dptsgl          like isskfunc.dptsgl,         # Departamento - Sigla
    dpttip          like isskdepto.dpttip,        # Departamento - Tipo
    dptcod          like isskdepto.dptcod,        # Departamento - Codigo
    sissgl          like ibpksist.sissgl,         # Nome do Sistema
    acsnivcod       like issmnivel.acsnivcod,     # Nivel Funcionario no Sistema
    prgsgl          like ibpkprog.prgsgl,         # Nome do Programa
    acsnivcns       like ibpmprogmod.acsnivcns,   # Nivel Consulta no Modulo
    acsnivatl       like ibpmprogmod.acsnivatl,   # Nivel Atualizacao no Modulo
    usrtip          like isskusuario.usrtip,      # Tipo do Usuario
    empcod          like isskusuario.empcod,      # Codigo da Empresa
    iptcod          like isskdepto.iptcod,        # Codigo da Inspetoria
    usrcod          like isskusuario.usrcod,      # Codigo do Usuario
    maqsgl          like ismkmaq.maqsgl           # Codigo da Maquina
 end record

 define g_hostname  char (20)
 define g_issparam  char (30)                     # Utilizada em PSEGSEGU2
 define g_simulacao smallint                      # Flag simulacao

 define g_c24paxnum like dacmlig.c24paxnum        # Numero da P.A.
 define g_c24solnom like dacmlig.c24solnom        # Nome do solicitante

 define g_atdcor record
        apoio       char(01),                     # Flag S apoio
        funmat      like isskfunc.funmat,         # matricula do atendente
        funnom      like isskfunc.funnom,         # nome do atendente
        empcod      like isskfunc.empcod,         # empresa do atendente
        usrtip      like isskfunc.usrtip          # codigo tipo do atendente
 end record
end globals
