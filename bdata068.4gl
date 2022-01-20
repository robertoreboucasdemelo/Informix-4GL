#############################################################################
# Nome do Modulo: bdata068                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Limpeza da interface de comunicacao com Nucleus CarGlass         Ago/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 07/01/2000               Gilberto     Aumentar o prazo para remocao para  #
#                                       cinco dias.                         #
#---------------------------------------------------------------------------#
# 16/01/2009               Amilton/Meta Alterado o database para porto e    #                                                                          #
#                                       e colocado o abre banco             #
#                                                                           #
#############################################################################

#############################################################################
# 19/01/2009               Carlos Ruiz  A Tabela correta e datmsrvext1      #
#                                       programa suspenso,sera estudado     #
#                                       a deleção dessa tabela junto com    #
#                                       as apolices.                        #
#                                                                           #             
#############################################################################





 database porto

 main    
    call fun_dba_abre_banco("CT24HS")           
    
    call bdata068()
 end main

#--------------------------------------------------------------
 function bdata068()
#--------------------------------------------------------------

 define ws           record
    lignum           like datmsrvext.lignum,
    ligqtd           integer,
    wrkqtd           integer,
    sql              char (200)
 end record

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------
 initialize ws.*  to null

 let ws.ligqtd = 0
 let ws.wrkqtd = 0

#---------------------------------------------------------------
# Preparacao dos comandos SQL
#---------------------------------------------------------------
 let ws.sql = "delete from datmsrvext1",
              " where lignum = ?     "
 prepare del_datmsrvext from ws.sql

#---------------------------------------------------------------
# Leitura das ligacoes
#---------------------------------------------------------------
 declare c_bdata068 cursor with hold for
    select lignum
      from datmsrvext1
     where atldat < today - 5 units day
#    where atldat is not null

 begin work

 foreach c_bdata068 into ws.lignum

    execute del_datmsrvext using ws.lignum

    if sqlca.sqlcode <> 0  then
       display " Erro (", sqlca.sqlcode using "<<<<<&", ") na delecao da ligacao ", ws.lignum using "<<<<<<<<<&", "!"
       rollback work
       exit program (1)
    end if

    let ws.wrkqtd = ws.wrkqtd + 1

    if ws.wrkqtd >= 500  then
       commit work
       begin work

       let ws.ligqtd = ws.ligqtd + ws.wrkqtd
       let ws.wrkqtd = 0
    end if

 end foreach

 commit work

 let ws.ligqtd = ws.ligqtd + ws.wrkqtd

 display " Foram removidas ", ws.ligqtd using "<<<<<<<<<&", " ligacoes!"

end function  ###  bdata068
