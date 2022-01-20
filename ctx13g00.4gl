#############################################################################
# Nome do Modulo: CTX13G00                                         Raji     #
#                                                                           #
# Mostra error p/ o usuario e grava no log                         Abr/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

function ctx13g00(param)

  define param record
     sqlcode       integer,
     tabname       char(18),
     modref        char(80)
  end record

  define ws record
     msgerr        char(300),
     deserr        char(100)
  end record



	initialize  ws.*  to  null

  let ws.deserr = err_get(param.sqlcode)
  let ws.msgerr = "Programa: ", param.modref clipped, ascii(10),
                  "Tabela: ", param.tabname, ascii(10),
                  "Erro: (", param.sqlcode using "<<<<<&", ") ",
                  ws.deserr clipped

  error " Erro (",param.sqlcode,") na tabela ",
        param.tabname clipped," AVISE A INFORMATICA"
  call errorlog(ws.msgerr)

end function # erros
