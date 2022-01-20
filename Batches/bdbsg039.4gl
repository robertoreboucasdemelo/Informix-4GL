{ SCRIPT .........: bdbsg039.sql     
  EQUIPE .........: Central 24 Horas 
  DATA ...........: Dezembro/1999    
  ULTIMA ALTERACAO: 
}
#...........................................................................#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################

database porto

define m_path char(200)

main

    call fun_dba_abre_banco("CT24HS") 
    
    set isolation to dirty read

    let m_path = f_path("DBS","LOG")
    if m_path is null then
        let m_path = "."
    end if
    
    let m_path = m_path clipped,"/bdbsg039.log"
    call startlog(m_path)
    
    let m_path = f_path("DBS","ARQUIVO")
    if m_path is null then
        let m_path = "."
    end if
    
    let m_path = m_path clipped,"/datmmdterr.unl"
    
    unload to m_path
    select datmmdterr.*
      from datmmdtmvt, datmmdterr
     where datmmdtmvt.caddat   >= today - 7 units day  and
           datmmdterr.mdtmvtseq = datmmdtmvt.mdtmvtseq

end main
