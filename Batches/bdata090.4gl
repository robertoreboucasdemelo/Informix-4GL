############################################################################
# Nome do Modulo: BDATA090                                        Raji     #
#                                                                          #
# Limpeza 5 dias URA ATD CORRETOR                                 Nov/2000 #
############################################################################
#                                                                          #
# dacrligura        dacmligurastt     aoimurafax                           #
#                                                                          #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
#..........................................................................#
#                                                                          #
#                  * * * Alteracoes * * *                                  #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ------------------------------------#
# 10/09/2005  Julianna, Meta Melhorias Melhorias de performance            #
#--------------------------------------------------------------------------#

 database porto

 main
    call fun_dba_abre_banco('CT24HS')
    
    #set explain on
    set lock mode to wait
    call startlog("/ldat/ldata090")

    call bdata090()
    #set explain off
 end main

#--------------------------------------------------------------------------
 function bdata090()
#--------------------------------------------------------------------------

 define d_bdata090  record
    corlignum       like dacmlig.corlignum   ,
    corligano       like dacmlig.corligano   ,
    dctorg          like dacrligura.dctorg   ,
    dctnumdig       like dacrligura.dctnumdig
 end record

 define ws          record
    sql             char (500),
    srvexcflg       smallint  ,
    qtddct          smallint
 end record

 define a_bdata090  array[3] of record
    tabnom          char (20),
    qtdexc          integer
 end record

 define arr_aux     smallint

#--------------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------------

 initialize d_bdata090.*  to null
 initialize ws.*          to null

 let a_bdata090[01].tabnom = "dacrligura"
 let a_bdata090[02].tabnom = "dacmligurastt"
 let a_bdata090[03].tabnom = "aoimurafax"

 for arr_aux = 1 to 3
    let a_bdata090[arr_aux].qtdexc = 0
 end for

#--------------------------------------------------------------------------
# Preparacao dos comandos SQL
#--------------------------------------------------------------------------

 let ws.sql = "delete from dacrligura  ",
              " where corlignum    = ? ",
              "   and corligano    = ? "
 prepare del_dacrligura from ws.sql

 let ws.sql = "delete from dacmligurastt",
              " where dctorg    = ?     ",
              "   and dctnumdig = ?     "
 prepare del_dacmligurastt from ws.sql

 let ws.sql = "delete from aoimurafax",
              " where prporgpcp = ?  ",
              "   and prpnumpcp = ?  "
 prepare del_aoimurafax from ws.sql

 let ws.sql = "select dctorg,        ",
              "       dctnumdig      ",
              "  from dacrligura     ",
              " where corlignum = ?  ",
              "   and corligano = ?  "
 prepare sel_dacrligura from ws.sql
 declare c_dacrligura  cursor with hold for sel_dacrligura

 let ws.sql = "select COUNT(*)       ",
              "  from dacrligura     ",
              " where dctorg     = ? ",
              "   and dctnumdig  = ? ",
              "   and ((corlignum > ? and corligano = ?)",
              "      or corligano > ?)"
 prepare sel_c_dacrligura from ws.sql
 declare c_c_dacrligura  cursor with hold for sel_c_dacrligura

#--------------------------------------------------------------------------
# Le o arquivo DACMLIG para remover os dados gerados para ura ate 5 dias
#--------------------------------------------------------------------------

 declare c_bdata090 cursor with hold for
    select DISTINCT dacmlig.corlignum, dacmlig.corligano
      from dacmlig, dacrligura
     where dacmlig.corlignum = dacrligura.corlignum
       and dacmlig.ligdat    < (today - 5 units day)

 foreach c_bdata090 into d_bdata090.corlignum,
                         d_bdata090.corligano
    # begin work

       open    c_dacrligura using d_bdata090.corlignum,
                                  d_bdata090.corligano
       foreach c_dacrligura into  d_bdata090.dctorg,
                                  d_bdata090.dctnumdig

          open  c_c_dacrligura using d_bdata090.dctorg,
                                     d_bdata090.dctnumdig,
                                     d_bdata090.corlignum,
                                     d_bdata090.corligano,
                                     d_bdata090.corligano
          fetch c_c_dacrligura into ws.qtddct
          close c_c_dacrligura

          if ws.qtddct = 0 or
             ws.qtddct is null then

             let arr_aux = 2
             execute del_dacmligurastt using d_bdata090.dctorg,
                                             d_bdata090.dctnumdig
             if sqlca.sqlcode  <>  0   then
                display "Erro (", sqlca.sqlcode,
                        ") na delecao da tabela DACMLIGURASTT!"
                rollback work
                exit program (1)
             end if
             let a_bdata090[arr_aux].qtdexc =
                 a_bdata090[arr_aux].qtdexc + sqlca.sqlerrd[3]

             let arr_aux = 3
             execute del_aoimurafax using d_bdata090.dctorg,
                                          d_bdata090.dctnumdig
             if sqlca.sqlcode  <>  0   then
                display "Erro (", sqlca.sqlcode,
                        ") na delecao da tabela AOIMURAFAX!"
                rollback work
                exit program (1)
             end if
             let a_bdata090[arr_aux].qtdexc =
                 a_bdata090[arr_aux].qtdexc + sqlca.sqlerrd[3]
          end if
       end foreach

       let arr_aux = 1
       execute del_dacrligura  using  d_bdata090.corlignum,
                                      d_bdata090.corligano
       if sqlca.sqlcode  <>  0  then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DACMLIGURA !"
          rollback work
          exit program (1)
       end if
       let a_bdata090[arr_aux].qtdexc =
           a_bdata090[arr_aux].qtdexc + sqlca.sqlerrd[3]

    # commit work
 end foreach

#----------------------------------------------------------
# Atualiza STATISTICS
#----------------------------------------------------------
# update statistics for table  dacrligura
# update statistics for table  dacmligurastt
# update statistics for table  aoimurafax

#--------------------------------------------------------------------------
# Exibe total de registros removidos por tabela
#--------------------------------------------------------------------------

 display "                                 "
 display " <<< RESUMO DE PROCESSAMENTO >>> "
 display "                                 "
 display " TABELA               QUANTIDADE "
 display " ------------------------------- "
 for arr_aux = 1 to 3
    display " ", a_bdata090[arr_aux].tabnom, " ", a_bdata090[arr_aux].qtdexc using "##,###,##&"
 end for
 display " -----------------------fim----- "
 display " "

end function
