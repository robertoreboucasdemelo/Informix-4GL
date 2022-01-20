############################################################################
# Nome do Modulo: bdata085                                        Marcus   #
#                                                                          #
# Carga de Novos Mapas do teste para Producao                     Set/2000 #
############################################################################
#..........................................................................#
#                                                                          #
#                  * * * Alteracoes * * *                                  #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ------------------------------------#
# 10/09/2005  James, Meta    Melhorias Melhorias de performance            #
#--------------------------------------------------------------------------#
# 18/07/06   Junior, Meta    Migracao  Migracao de versao do 4gl.          #
#--------------------------------------------------------------------------#
# 17/08/2007  Saulo, Meta    AS146056  Maquina de teste substituida pela   #
#                                      maquina corrente                    #
#--------------------------------------------------------------------------#
# 16/06/2012 Johnny Alves    Segregacao Bases                              #
#            Biztalking                                                    #
#--------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/figrc012.4gl"

database porto
 define m_hostname   like ibpkdbspace.srvnom

 main
   if not figrc012_sitename('bdata085', '', '') then     #Johnny,Biz
     display 'Erro Selecionando Sitename da dual'
     exit program(1)
   end if
   call fun_dba_abre_banco("CT24HS")
   let m_hostname = fun_dba_servidor("CT24HS")           #Johnny,Biz
   call bdata085()
 end main


----------------------------------------------------------------------------
 function bdata085( )
----------------------------------------------------------------------------
 define ws   record
   comando   char(300),
   errflg    dec(1,0),
   atual     smallint,
   lgdcod    char(6),
   brrcod    char(4),
   cidcod    dec(3,0),
   data      date,
   pergunta  char(1)
 end record

 define bdata085_cid   record
   mpacidcod           like datkmpacid.mpacidcod,
   cidnom              like datkmpacid.cidnom,
   ufdcod              like datkmpacid.ufdcod
 end record

 define bdata085_brr   record
   mpacidcod           like datkmpabrr.mpacidcod,
   mpabrrcod           like datkmpabrr.mpabrrcod,
   brrnom              like datkmpabrr.brrnom
 end record

 define bdata085_lgd      record
    mpalgdcod                like datkmpalgd.mpalgdcod,
    lgdtip                   like datkmpalgd.lgdtip,
    lgdnom                   like datkmpalgd.lgdnom,
    mpacidcod                like datkmpalgd.mpacidcod,
    prifoncod                like datkmpalgd.prifoncod,
    segfoncod                like datkmpalgd.segfoncod,
    terfoncod                like datkmpalgd.terfoncod
 end record

 define bdata085_lgdsgm   record
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
                  "from porto@",m_hostname clipped,":datkmpabrr ",
                  "where mpacidcod = ? AND ",
                        "mpabrrcod > ? "

 prepare s_datkmpabrr from ws.comando
 declare c_datkmpabrr cursor with hold for s_datkmpabrr

 let ws.comando = "select mpalgdcod, lgdtip, ",
                  "lgdnom, mpacidcod, ",
                  "prifoncod, segfoncod, ",
                  "terfoncod ",
                  "from porto@",m_hostname clipped,":datkmpalgd ",
                  "where mpacidcod = ? AND ",
                        "mpalgdcod > ? "

 prepare s_datkmpalgd from ws.comando
 declare c_datkmpalgd cursor with hold for s_datkmpalgd


 let ws.comando = "select mpalgdcod, mpalgdsgmseq, ",
                  "mpalgdincnum, mpalgdfnlnum, ",
                  "lclltt, lcllgt, mpacidcod, ",
                  "mpabrrcod from porto@",m_hostname clipped,":datkmpalgdsgm ",
                  "where mpalgdcod= ? "

  prepare s_datkmpalgdsgm from ws.comando
  declare c_datkmpalgdsgm cursor for s_datkmpalgdsgm

  let ws.comando= "select mpacidcod, cidnom, ufdcod, caddat ",
                  "from porto@",m_hostname clipped,":datkmpacid where mpacidcod= ? "

  prepare s_datkmpacid from ws.comando

 let ws.comando = "insert into porto@",m_hostname clipped,":datkmpalgd (mpalgdcod, ",
                                                   "lgdtip, lgdnom, ",
                                                   "mpacidcod, prifoncod, ",
                                                 "segfoncod, terfoncod) ",
                                        "values (?,?,?,?,?,?,?) "

 prepare ins_datkmpalgd from ws.comando

let ws.comando = "insert into porto@",m_hostname clipped,":datkmpalgdsgm (mpalgdcod,",
                                                       "mpalgdsgmseq, ",
                                                       "mpalgdincnum , ",
                                                       "mpalgdfnlnum, ",
                                                       "lclltt, lcllgt, ",
                                                       "mpacidcod, mpabrrcod)",                                          " values (?,?,?,?,?,?,?,?) "

 prepare ins_datkmpalgdsgm from ws.comando

 let ws.comando = "insert into porto@",m_hostname clipped,":datkmpacid (mpacidcod, ",
                                                    "cidnom, ",
                                                    "ufdcod, ",
                                                    "caddat) ",
                                        "values (?,?,?,?) "

 prepare ins_datkmpacid from ws.comando

 let ws.comando = "insert into porto@",m_hostname clipped,":datkmpabrr (mpacidcod, ",
                                                    "mpabrrcod, ",
                                                    "brrnom) ",
                                        "values (?,?,?) "

 prepare ins_datkmpabrr from ws.comando
                                                         #Johnny-Inicio,Biz
 let ws.comando = "select grlinf from porto@",m_hostname clipped,":igbkgeral"
                 ,"  where mducod = 'CTH'       "
                 ,"    AND grlchv = 'maptransf' "

 prepare pbdata085001 from ws.comando
 declare cbdata085001 cursor with hold for pbdata085001

 let ws.comando = " insert into porto@",m_hostname clipped
                 ,":igbkgeral (mducod,grlchv,grlinf,atlult) "
                 ," values ('CTH','maptransf','','') "
 prepare pbdata085002 from ws.comando
 let ws.comando = " update porto@",m_hostname clipped
                 ,":igbkgeral set grlinf = 'igbkgeral_tmp' "
                 ,"     where mducod = 'CTH'               "
                 ,"       AND grlchv = 'maptransf'         "
 prepare pbdata085003 from ws.comando
 let ws.comando = " select mpacidcod, cidnom, ufdcod "
                 ,"   from porto@",m_hostname clipped,":datkmpacid"
                 ,"  where mpacidcod = ? "
 prepare p_datkmpacid from ws.comando
 declare c_datkmpacid cursor with hold for p_datkmpacid
                                                          #Johnny-Fim,Biz
  initialize ws.*              to null
  initialize bdata085_lgd.*    to null
  initialize bdata085_lgdsgm.* to null
  initialize bdata085_cid.*    to null
  initialize bdata085_brr.*    to null

  let ws.data   =  today
  let ws.cidcod = 41

#------------------------------------------------------------------------------
# Verifica onde a transferencia parou
#------------------------------------------------------------------------------

open cbdata085001                             #Johnny,Biz
whenever error continue
fetch cbdata085001 into igbkgeral_tmp
whenever error stop
if sqlca.sqlcode = 100 then
	 display "Nao existe a chave"
	 whenever error continue
	 execute pbdata085002
	 whenever error stop
	 if sqlca.sqlcode <> 0 then
	 	  display "Problemas ao insert do prepare pbdata085002.Erro:"
	 end if
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

  foreach c_datkmpabrr into bdata085_brr.mpacidcod,
                             bdata085_brr.mpabrrcod,
                             bdata085_brr.brrnom

#    display bdata085_brr.mpacidcod
#    display bdata085_brr.mpabrrcod
#    display bdata085_brr.brrnom

    execute ins_datkmpabrr using bdata085_brr.mpacidcod,
                                 bdata085_brr.mpabrrcod,
                                 bdata085_brr.brrnom

    if sqlca.sqlcode  <>  0   then
       display "Erro (",sqlca.sqlcode,") inclusao DATKMPABRR!"
       exit program (1)
    end if

     let ws.brrcod = bdata085_brr.mpabrrcod
     let igbkgeral_tmp[1,4]=ws.brrcod
     whenever error continue
     execute pbdata085003
     whenever error stop
     if sqlca.sqlcode <> 0 then
     	  display"Problemas ao insert do prepare pbdata085003.Erro:"
     end if
#     update porto@u07:igbkgeral set grlinf = igbkgeral_tmp    #Johnny,Biz
#            where mducod = "CTH" AND
#                  grlchv = "maptransf"

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

  foreach c_datkmpalgd into bdata085_lgd.mpalgdcod,
                            bdata085_lgd.lgdtip,
                            bdata085_lgd.lgdnom,
                            bdata085_lgd.mpacidcod,
                            bdata085_lgd.prifoncod,
                            bdata085_lgd.segfoncod,
                            bdata085_lgd.terfoncod

     display bdata085_lgd.mpalgdcod

     begin work
     execute ins_datkmpalgd using bdata085_lgd.mpalgdcod,
                                  bdata085_lgd.lgdtip,
                                  bdata085_lgd.lgdnom,
                                  bdata085_lgd.mpacidcod,
                                  bdata085_lgd.prifoncod,
                                  bdata085_lgd.segfoncod,
                                  bdata085_lgd.terfoncod

       if sqlca.sqlcode  <>  0   then
          display "Erro (",sqlca.sqlcode,") inclusao DATKMPALGD!"
          rollback work
          exit program (1)
       end if


     let ws.lgdcod = bdata085_lgd.mpalgdcod
     let igbkgeral_tmp[5,10]=ws.lgdcod

     open c_datkmpalgdsgm using bdata085_lgd.mpalgdcod
     fetch c_datkmpalgdsgm

     foreach c_datkmpalgdsgm into bdata085_lgdsgm.mpalgdcod,
                                  bdata085_lgdsgm.mpalgdsgmseq,
                                  bdata085_lgdsgm.mpalgdincnum,
                                  bdata085_lgdsgm.mpalgdfnlnum,
                                  bdata085_lgdsgm.lclltt,
                                  bdata085_lgdsgm.lcllgt,
                                  bdata085_lgdsgm.mpacidcod,
                                  bdata085_lgdsgm.mpabrrcod

#       display bdata085_lgdsgm.mpalgdsgmseq

       execute ins_datkmpalgdsgm using bdata085_lgdsgm.mpalgdcod,
                                       bdata085_lgdsgm.mpalgdsgmseq,
                                       bdata085_lgdsgm.mpalgdincnum,
                                       bdata085_lgdsgm.mpalgdfnlnum,
                                       bdata085_lgdsgm.lclltt,
                                       bdata085_lgdsgm.lcllgt,
                                       bdata085_lgdsgm.mpacidcod,
                                       bdata085_lgdsgm.mpabrrcod

       if sqlca.sqlcode  <>  0   then
          display "Erro (",sqlca.sqlcode,") inclusao DATKMPALGDSGM!"
          rollback work
          exit program (1)
       end if

     end foreach
     close c_datkmpalgdsgm

     whenever error continue
     execute pbdata085003
     whenever error stop
     if sqlca.sqlcode <> 0 then
     	  display"Problemas ao insert do prepare pbdata085003.Erro:"
     end if
#     update porto@u07:igbkgeral set grlinf = igbkgeral_tmp      #Johnny,Biz
#            where mducod = "CTH" AND
#                  grlchv = "maptransf"

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

#  declare c_datkmpacid cursor for                             #Johnny,Biz
#                 select mpacidcod, cidnom, ufdcod
#                 from porto@u07:datkmpacid where mpacidcod= ws.cidcod

  open c_datkmpacid using ws.cidcod
  whenever error continue
  fetch c_datkmpacid into bdata085_cid.mpacidcod,
                          bdata085_cid.cidnom,
                          bdata085_cid.ufdcod
  whenever error stop
  if sqlca.sqlcode  =  notfound   then
     display "Cidade nao encontrada"
     exit program(1)
  end if

#    display bdata085_cid.mpacidcod
#    display bdata085_cid.cidnom
#    display bdata085_cid.ufdcod

 execute ins_datkmpacid using bdata085_cid.mpacidcod,
                              bdata085_cid.cidnom,
                              bdata085_cid.ufdcod,
                              ws.data

       if sqlca.sqlcode  <>  0   then
          display "Erro (",sqlca.sqlcode,") inclusao DATKMPALCID!"
          exit program (1)
       end if


  close c_datkmpacid

 end function

