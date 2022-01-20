###########################################################################
# Nome do Modulo: ctc94m00                                           Jose #
#                                                                Kurihara #
#                                                                         #
# Objetivo: Menu de bloqueios do Porto Socorro                   Fev/2012 #
# Anl Resp: Joseli Oliveira                                               #
# Projeto : PSI-2011-21476-PR - 09/02/2012                                #
###########################################################################
#                 * * * Alteracoes Ordem Decrescente * * *                #
#                                                                         #
# Data        Autor          PSI / CT  Alteracao                          #
# ----------  -------------- --------- -----------------------------------#
#                                                                         #
#                                                                         #
#-------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctc94m00()
#-----------------------------------------------------------

   open window w_ctc94m00 at 04,02 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctc94m00--" at 3,1

   menu "BLOQUEIOS"

      command key ("T") "bloq_Tipo_veiculo"
                        "Manutencao parametro bloqueio frota irregular por tipo veiculo (ctc34m17)"
        call ctc94m01_manterParamBloqTipoVeic()
        
      command key (interrupt,E) "Encerra"
                        "Retorna ao menu anterior"
        exit menu
   end menu

   close window w_ctc94m00

   let int_flag = false

end function   ##-- ctc94m00


#---------------------------------------------------------
 function ctc94m00_getFunc(lr_par_in)
#---------------------------------------------------------

 define lr_par_in     record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record

 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = lr_par_in.empcod
    and isskfunc.funmat = lr_par_in.funmat

 return ws.funnom

 end function   # ctc94m00_getFunc()
