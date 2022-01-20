#  bdbsa300.4gl  - carga codigo mapa cidade na tabela de prestadores
#...........................................................................#
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
###############################################################################

database porto

define ws     record
   totnao     integer,
   totsim     integer,
   rowid      integer,
   mpacidcod  like datkmpacid.mpacidcod,
   endcid     like dpaksocor.endcid,
   endufd     like dpaksocor.endufd
end record

define m_path   char(100)

main

    call fun_dba_abre_banco("CT24HS") 

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsa300.log"

    call startlog(m_path)
    # PSI 185035 - Final   

   let ws.totnao = 0
   let ws.totsim = 0

   declare c_cid cursor for
    select rowid, endcid, endufd
      from dpaksocor

   foreach c_cid into ws.rowid, ws.endcid, ws.endufd

      select mpacidcod
        into ws.mpacidcod
        from porto@u07:datkmpacid
       where cidnom = ws.endcid
         and ufdcod = ws.endufd

      if sqlca.sqlcode = notfound then
         let ws.totnao = ws.totnao + 1
      else
         let ws.totsim = ws.totsim + 1
         update dpaksocor set mpacidcod = ws.mpacidcod
                where rowid = ws.rowid
      end if


   end foreach

   display " Cidades nao encontradas = ", ws.totnao
   display " Cidades encontradas     = ", ws.totsim

end main
