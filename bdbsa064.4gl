############################################################################
# Nome do Modulo: bdbsa064                                        Marcelo  #
#                                                                 Gilberto #
#                                                                 Wagner   #
# Atualizacao do status de bloqueio das lojas locadoras           Mar/1999 #
############################################################################
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

 define m_path        char(100)

 main
    call fun_dba_abre_banco("CT24HS") 

    set isolation to dirty read

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsa064.log"

    call startlog(m_path)
    # PSI 185035 - Final
        
    call bdbsa064()
 end main

#--------------------------------------------------------------------------
 function bdbsa064()
#--------------------------------------------------------------------------

 define d_bdbsa064  record
    lcvcod          like datklcvsit.lcvcod,
    aviestcod       like datklcvsit.aviestcod
 end record

 initialize d_bdbsa064.*  to null

 #-------------------------------------
 # Ler lojas com data final ja' vencida
 #-------------------------------------
 declare c_bdbsa064 cursor with hold for
    select lcvcod,
           aviestcod
      from datklcvsit
     where (datklcvsit.vigfnl > "01/01/1999" and
            datklcvsit.vigfnl < today)           # <---(data final ja' vencida)
       for update

 foreach c_bdbsa064 into d_bdbsa064.lcvcod,           # Nr.locadora
                         d_bdbsa064.aviestcod         # cod.loja

   begin work

     update datkavislocal set datkavislocal.vclalglojstt = 1
      where datkavislocal.lcvcod     = d_bdbsa064.lcvcod
        and datkavislocal.aviestcod  = d_bdbsa064.aviestcod

     if sqlca.sqlcode <>  0   then
        display "Erro (", sqlca.sqlcode, ") na alteracao da tabela DATKAVISLOCAL!"
        rollback work
        exit program (1)
     end if

     update datklcvsit set datklcvsit.viginc = 0 ,
                           datklcvsit.vigfnl = 0
      where datklcvsit.lcvcod     = d_bdbsa064.lcvcod
        and datklcvsit.aviestcod  = d_bdbsa064.aviestcod

     if sqlca.sqlcode <>  0   then
        display "Erro (", sqlca.sqlcode, ") na alteracao da tabela DATKLCVSIT!"
        rollback work
        exit program (1)
     end if

   commit work

 end foreach

end function  # bdbsa064
