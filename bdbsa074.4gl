 ############################################################################
 # Nome do Modulo: bdbsa074                                        Marcelo  #
 #                                                                 Gilberto #
 # Gera tabelas para carga dos arquivo de mapas da MultiSpectral   Abr/1999 #
 ############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 20/07/2000  PSI 111481   Marcus          Adaptar Modulo para carga RJ     #
 #                                                                           #
 #############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# --------------------------------------------------------------------------#

 database work      
 
 define m_path    char(100)

 main
                                                  # Marcio Meta - PSI185035
    let m_path = f_path("DBS","LOG")
    
    if m_path is null then
       let m_path = "."
    end if
    
    let m_path = m_path clipped,"/bdbsa074.log"

    call startlog(m_path)
                                                  # Marcio Meta - PSI185035
    call bdbsa074()
    
 end main

#---------------------------------------------------------------------------
 function bdbsa074()
#---------------------------------------------------------------------------

 define ws          record
    param           dec (1,0),
    sqlcode         integer
 end record


 initialize ws.*   to null
 let ws.param   =  arg_val(1)

 if ws.param   is null   then
    display  "  *** Parametro nao informado para criacao da tabela *** "
    exit program (1)
 end if

 if ws.param   <>  1   and
    ws.param   <>  2   then
    display "  *** Parametro incorreto para criacao da tabela ", ws.param," ***"
    exit program (1)
 end if

 #--------------------------------------------------------------------------
 # Cria tabela DATMMAPLGD no banco WORK para carga de logradouros
 #--------------------------------------------------------------------------
 if ws.param  =  1   then

    select tabname
      from systables
     where systables.tabname  =  "datmmaplgd"

    if sqlca.sqlcode  =  notfound   then
       call bdbsa074_create_lgd()  returning ws.sqlcode
       if ws.sqlcode  <>  0   then
          exit program (1)
       end if

       call bdbsa074_index_lgd()   returning ws.sqlcode
       if ws.sqlcode  <>  0   then
          exit program (1)
       end if
    else

       if sqlca.sqlcode  <>  0   then
          display "*** ERRO (",sqlca.sqlcode,") verificando criacao tabela ***"
          return
       else
          display "*** Tabela ja estava criada no banco WORK ***"
       end if
    end if
 end if

 #--------------------------------------------------------------------------
 # Cria tabela DATMMAPCID no banco WORK para carga de cidades/estados
 #--------------------------------------------------------------------------
 if ws.param  =  2   then

    select tabname
      from systables
     where systables.tabname  =  "datmmapcid"

    if sqlca.sqlcode  =  notfound   then
       call bdbsa074_create_cid()  returning ws.sqlcode
       if ws.sqlcode  <>  0   then
          exit program (1)
       end if

       call bdbsa074_index_cid()   returning ws.sqlcode
       if ws.sqlcode  <>  0   then
          exit program (1)
       end if
    else

       if sqlca.sqlcode  <>  0   then
          display "*** ERRO (",sqlca.sqlcode,") verificando criacao tabela ***"
          return
       else
          display "*** Tabela ja estava criada no banco WORK ***"
       end if
    end if
 end if

end function  ###  bdbsa074


#---------------------------------------------------------------------------
 function bdbsa074_create_lgd()
#---------------------------------------------------------------------------

 create table datmmaplgd  (
                           lgdnum        serial   not null,
                           cidcod        smallint not null,
                           rua           char(45),
                           fromleft      integer,
                           toleft        integer,
                           fromright     integer,
                           toright       integer,
                           obs           char(3),
                           bairro        char(40),
                           latitude      decimal(8,6),
                           longitude     decimal(9,6),
                           cep           char(8),
                           consitcod     decimal(1,0) not null,
                           crgsitcod     decimal(1,0) not null,
                           consitcepcod  decimal(1,0)
                           );

 if sqlca.sqlcode  <>  0   then
    display "*** ERRO (",sqlca.sqlcode,") na criacao da tabela DATMMAPLGD! ***"
 end if

 return sqlca.sqlcode

end function  ###  bdbsa074_create_lgd


#---------------------------------------------------------------------------
 function bdbsa074_index_lgd()
#---------------------------------------------------------------------------

 create unique index datmmaplgd_lgdnum on datmmaplgd (lgdnum)

 if sqlca.sqlcode  <>  0   then
   display "*** ERRO (",sqlca.sqlcode,") na criacao do indice-1 DATMMAPLGD! ***"
   return sqlca.sqlcode
 end if

 create index datmmaplgd_crgsit  on datmmaplgd (crgsitcod, consitcod)

 if sqlca.sqlcode  <>  0   then
   display "*** ERRO (",sqlca.sqlcode,") na criacao do indice-2 DATMMAPLGD! ***"
 end if

 return sqlca.sqlcode

end function  ###  bdbsa074_index_lgd


#---------------------------------------------------------------------------
 function bdbsa074_create_cid()
#---------------------------------------------------------------------------

 create table datmmapcid  (
                           cidnum        serial   not null,
                           cidnom        char(64) not null,
                           ufdcod        char(02) not null,
                           ufdnom        char(40) not null,
                           latitude      decimal(11,6),
                           longitude     decimal(11,6),
                           consitcod     decimal(1,0) not null,
                           crgsitcod     decimal(1,0) not null
                           );

 if sqlca.sqlcode  <>  0   then
    display "*** ERRO (",sqlca.sqlcode,") na criacao da tabela DATMMAPCID! ***"
 end if

 return sqlca.sqlcode

end function  ###  bdbsa074_create_cid


#---------------------------------------------------------------------------
 function bdbsa074_index_cid()
#---------------------------------------------------------------------------

 create unique index datmmapcid_cidnum on datmmapcid (cidnum)

 if sqlca.sqlcode  <>  0   then
   display "*** ERRO (",sqlca.sqlcode,") na criacao do indice-1 DATMMAPCID! ***"
   return sqlca.sqlcode
 end if

 create index datmmapcid_crgsit  on datmmapcid (crgsitcod, consitcod)

 if sqlca.sqlcode  <>  0   then
   display "*** ERRO (",sqlca.sqlcode,") na criacao do indice-2 DATMMAPCID! ***"
 end if

 create index datmmapcid_ufdcod  on datmmapcid (ufdcod, cidnom)

 if sqlca.sqlcode  <>  0   then
   display "*** ERRO (",sqlca.sqlcode,") na criacao do indice-3 DATMMAPCID! ***"
 end if

 return sqlca.sqlcode

end function  ###  bdbsa074_index_cid

