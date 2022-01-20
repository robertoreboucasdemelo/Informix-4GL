############################################################################
# Nome do Modulo: bdbsa085                                        Marcus   #
#                                                                          #
# Carga de Novos Mapas do teste para Producao                     Set/2000 #
############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Marcio, Meta      PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#-----------------------------------------------------------------------------#
# 18/07/06   Junior, Meta   AS112372   Migracao de versao do 4gl.             # 
#-----------------------------------------------------------------------------# 


 database porto
 
 define m_path char(100)

 main
 
    call fun_dba_abre_banco("CT24HS") 

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsa085.log"

    call startlog(m_path)
    # PSI 185035 - Final
 
   call bdbsa085()
 end main


----------------------------------------------------------------------------
 function bdbsa085( )
----------------------------------------------------------------------------
 define ws   record
   comando   char(300),
   errflg    dec(1,0),
   atual     smallint,
   lgdcod    char(6),
   brrcod    char(4),
   cidcod    dec(3,0),
   data      date,
   pergt     char(1)
 end record

 define bdbsa085_cid   record
   mpacidcod           like datkmpacid.mpacidcod,
   cidnom              like datkmpacid.cidnom,
   ufdcod              like datkmpacid.ufdcod
 end record

 define bdbsa085_brr   record
   mpacidcod           like datkmpabrr.mpacidcod,
   mpabrrcod           like datkmpabrr.mpabrrcod,
   brrnom              like datkmpabrr.brrnom
 end record

 define bdbsa085_lgd      record
    mpalgdcod                like datkmpalgd.mpalgdcod,
    lgdtip                   like datkmpalgd.lgdtip,
    lgdnom                   like datkmpalgd.lgdnom,
    mpacidcod                like datkmpalgd.mpacidcod,
    prifoncod                like datkmpalgd.prifoncod,
    segfoncod                like datkmpalgd.segfoncod,
    terfoncod                like datkmpalgd.terfoncod
 end record

 define bdbsa085_lgdsgm   record
    mpalgdcod            like datkmpalgdsgm.mpalgdcod,
    mpalgdsgmseq         like datkmpalgdsgm.mpalgdsgmseq,
    mpalgdincnum         like datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum         like datkmpalgdsgm.mpalgdfnlnum,
    lclltt               like datkmpalgdsgm.lclltt,
    lcllgt               like datkmpalgdsgm.lcllgt,
    mpacidcod            like datkmpalgdsgm.mpacidcod,
    mpabrrcod            like datkmpalgdsgm.mpabrrcod
 end record

 define igbkgeral_tmp   char(30)

#-------------------------------------------------------------------------------# Prepara SQL's
#-------------------------------------------------------------------------------

 let ws.comando = "select mpacidcod, mpabrrcod, brrnom ",
                  "from porto@u07:datkmpabrr ",
                  "where mpacidcod = ? AND ",
                        "mpabrrcod > ? "

 prepare s_datkmpabrr from ws.comando
 declare c_datkmpabrr cursor with hold for s_datkmpabrr

 let ws.comando = "select mpalgdcod, lgdtip, ",
                  "lgdnom, mpacidcod, ",
                  "prifoncod, segfoncod, ",
                  "terfoncod ",
                  "from porto@u07:datkmpalgd ",
                  "where mpacidcod = ? AND ",
                        "mpalgdcod > ? "

 prepare s_datkmpalgd from ws.comando
 declare c_datkmpalgd cursor with hold for s_datkmpalgd


 let ws.comando = "select mpalgdcod, mpalgdsgmseq, ",
                  "mpalgdincnum, mpalgdfnlnum, ",
                  "lclltt, lcllgt, mpacidcod, ",
                  "mpabrrcod from porto@u07:datkmpalgdsgm ",
                  "where mpalgdcod= ? "

  prepare s_datkmpalgdsgm from ws.comando
  declare c_datkmpalgdsgm cursor for s_datkmpalgdsgm

  let ws.comando= "select mpacidcod, cidnom, ufdcod, caddat ",
                  "from porto@u07:datkmpacid where mpacidcod= ? "

  prepare s_datkmpacid from ws.comando

 let ws.comando = "insert into porto@u18:datkmpalgd (mpalgdcod, ",
                                                   "lgdtip, lgdnom, ",
                                                   "mpacidcod, prifoncod, ",
                                                 "segfoncod, terfoncod) ",
                                        "values (?,?,?,?,?,?,?) "

 prepare ins_datkmpalgd from ws.comando

 let ws.comando = "insert into porto@u18:datkmpalgdsgm (mpalgdcod, ",
                                                       "mpalgdsgmseq, ",
                                                       "mpalgdincnum , ",
                                                       "mpalgdfnlnum, ",
                                                       "lclltt, lcllgt, ",
                                                       "mpacidcod, mpabrrcod)",                                          " values (?,?,?,?,?,?,?,?) "

 prepare ins_datkmpalgdsgm from ws.comando

 let ws.comando = "insert into porto@u18:datkmpacid (mpacidcod, ",
                                                    "cidnom, ",
                                                    "ufdcod, ",
                                                    "caddat) ",
                                        "values (?,?,?,?) "

 prepare ins_datkmpacid from ws.comando

 let ws.comando = "insert into porto@u18:datkmpabrr (mpacidcod, ",
                                                    "mpabrrcod, ",
                                                    "brrnom) ",
                                        "values (?,?,?) "

 prepare ins_datkmpabrr from ws.comando


  initialize ws.*              to null
  initialize bdbsa085_lgd.*    to null
  initialize bdbsa085_lgdsgm.* to null
  initialize bdbsa085_cid.*    to null
  initialize bdbsa085_brr.*    to null

  let ws.data   =  today
  let ws.cidcod = 41

#------------------------------------------------------------------------------
# Verifica onde a transferencia parou
#------------------------------------------------------------------------------

  select grlinf into igbkgeral_tmp from porto@u07:igbkgeral
         where mducod = "CTH" AND grlchv = "maptransf"

  if sqlca.sqlcode  =  notfound   then
     display "Nao existe a chave"    # inicio do programa
     insert into porto@u07:igbkgeral (mducod,grlchv,grlinf,atlult)
                    values ("CTH","maptransf","","")
  else
     let ws.brrcod = igbkgeral_tmp[1,4]
     let ws.lgdcod = igbkgeral_tmp[5,10]
  end if

#------------------------------------------------------------------------------
# Transfere Bairros
#------------------------------------------------------------------------------

  display "Transferindo Bairros"

  if ws.brrcod is NULL or ws.brrcod = "    "  then
     let ws.brrcod = 0
  end if

  open c_datkmpabrr using ws.cidcod, ws.brrcod
  fetch c_datkmpabrr

  foreach c_datkmpabrr into bdbsa085_brr.mpacidcod,
                             bdbsa085_brr.mpabrrcod,
                             bdbsa085_brr.brrnom

#    display bdbsa085_brr.mpacidcod
#    display bdbsa085_brr.mpabrrcod
#    display bdbsa085_brr.brrnom

    execute ins_datkmpabrr using bdbsa085_brr.mpacidcod,
                                 bdbsa085_brr.mpabrrcod,
                                 bdbsa085_brr.brrnom

    if sqlca.sqlcode  <>  0   then
       display "Erro (",sqlca.sqlcode,") inclusao DATKMPABRR!"
       exit program (1)
    end if

     let ws.brrcod = bdbsa085_brr.mpabrrcod
     let igbkgeral_tmp[1,4]=ws.brrcod
     update porto@u07:igbkgeral set grlinf = igbkgeral_tmp
            where mducod = "CTH" AND
                  grlchv = "maptransf"

  end foreach

  close c_datkmpabrr

#------------------------------------------------------------------------------
# Transfere Logradouros
#------------------------------------------------------------------------------

  display "Transferindo Logradouros"

  if ws.lgdcod is null or ws.lgdcod = "      "  then
     let ws.lgdcod = 0
  end if

  open c_datkmpalgd using ws.cidcod , ws.lgdcod
  fetch c_datkmpalgd

  foreach c_datkmpalgd into bdbsa085_lgd.mpalgdcod,
                            bdbsa085_lgd.lgdtip,
                            bdbsa085_lgd.lgdnom,
                            bdbsa085_lgd.mpacidcod,
                            bdbsa085_lgd.prifoncod,
                            bdbsa085_lgd.segfoncod,
                            bdbsa085_lgd.terfoncod

     display bdbsa085_lgd.mpalgdcod

     begin work
     execute ins_datkmpalgd using bdbsa085_lgd.mpalgdcod,
                                  bdbsa085_lgd.lgdtip,
                                  bdbsa085_lgd.lgdnom,
                                  bdbsa085_lgd.mpacidcod,
                                  bdbsa085_lgd.prifoncod,
                                  bdbsa085_lgd.segfoncod,
                                  bdbsa085_lgd.terfoncod

       if sqlca.sqlcode  <>  0   then
          display "Erro (",sqlca.sqlcode,") inclusao DATKMPALGD!"
          rollback work
          exit program (1)
       end if


     let ws.lgdcod = bdbsa085_lgd.mpalgdcod
     let igbkgeral_tmp[5,10]=ws.lgdcod

     open c_datkmpalgdsgm using bdbsa085_lgd.mpalgdcod
     fetch c_datkmpalgdsgm

     foreach c_datkmpalgdsgm into bdbsa085_lgdsgm.mpalgdcod,
                                  bdbsa085_lgdsgm.mpalgdsgmseq,
                                  bdbsa085_lgdsgm.mpalgdincnum,
                                  bdbsa085_lgdsgm.mpalgdfnlnum,
                                  bdbsa085_lgdsgm.lclltt,
                                  bdbsa085_lgdsgm.lcllgt,
                                  bdbsa085_lgdsgm.mpacidcod,
                                  bdbsa085_lgdsgm.mpabrrcod

#       display bdbsa085_lgdsgm.mpalgdsgmseq

       execute ins_datkmpalgdsgm using bdbsa085_lgdsgm.mpalgdcod,
                                       bdbsa085_lgdsgm.mpalgdsgmseq,
                                       bdbsa085_lgdsgm.mpalgdincnum,
                                       bdbsa085_lgdsgm.mpalgdfnlnum,
                                       bdbsa085_lgdsgm.lclltt,
                                       bdbsa085_lgdsgm.lcllgt,
                                       bdbsa085_lgdsgm.mpacidcod,
                                       bdbsa085_lgdsgm.mpabrrcod

       if sqlca.sqlcode  <>  0   then
          display "Erro (",sqlca.sqlcode,") inclusao DATKMPALGDSGM!"
          rollback work
          exit program (1)
       end if

     end foreach
     close c_datkmpalgdsgm

     update porto@u07:igbkgeral set grlinf = igbkgeral_tmp
            where mducod = "CTH" AND
                  grlchv = "maptransf"

     if sqlca.sqlcode  <>  0   then
        display "Erro (",sqlca.sqlcode,") inclusao IGBKGERAL!"
        rollback work
        exit program (1)
     end if

    commit work

  end foreach
  close c_datkmpalgd

#------------------------------------------------------------------------------
# Transfere Cidade
#------------------------------------------------------------------------------

  declare c_datkmpacid cursor for
                 select mpacidcod, cidnom, ufdcod
                 from porto@u07:datkmpacid where mpacidcod= ws.cidcod

  open c_datkmpacid

  fetch c_datkmpacid into bdbsa085_cid.mpacidcod,
                          bdbsa085_cid.cidnom,
                          bdbsa085_cid.ufdcod

  if sqlca.sqlcode  =  notfound   then
     display "Cidade nao encontrada"
     exit program(1)
  end if

#    display bdbsa085_cid.mpacidcod
#    display bdbsa085_cid.cidnom
#    display bdbsa085_cid.ufdcod

 execute ins_datkmpacid using bdbsa085_cid.mpacidcod,
                              bdbsa085_cid.cidnom,
                              bdbsa085_cid.ufdcod,
                              ws.data

       if sqlca.sqlcode  <>  0   then
          display "Erro (",sqlca.sqlcode,") inclusao DATKMPALCID!"
          exit program (1)
       end if


  close c_datkmpacid

 end function

