#--------------------------------------------------------------------
# bdbsr015.4gl - extracao de dados para P.Socorro
# 29/08/2002
#--------------------------------------------------------------------
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 28/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################

database porto

define m_path  char(100)

main
   
   call fun_dba_abre_banco("CT24HS") 

   let m_path = f_path("DBS","ARQUIVO")
   if m_path is null then
      let m_path = "."
   end if
   let m_path = m_path clipped,"/mdtlist.txt"

   unload to m_path
   select datkmdt.mdtcod  mdt,
          datkveiculo.atdvclsgl sigla,
          datkmdt.mdtctrcod controladora,
          datkmdtctr.mdtfqcnum frequencia,
          datkveiculo.pstcoddig cod_base, 
          dpaksocor.nomrazsoc razao
     from datkveiculo, datkmdt, dpaksocor, datkmdtctr
    where socvclcod > 1
      and datkmdt.mdtcod      = datkveiculo.mdtcod
      and dpaksocor.pstcoddig = datkveiculo.pstcoddig
      and datkmdtctr.mdtctrcod = datkmdt.mdtctrcod 

end main
