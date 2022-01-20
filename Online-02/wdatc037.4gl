#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : wdatc037.4gl                                              #
#                  Valida e atualiza sessao                                  #
# Analista Resp. : Carlos Pessoto                                            #
# PSI            : 163759 -                                                  #
# OSF            : 5289   -                                                  #
#............................................................................#
# Desenvolvimento: Fabrica de Software - Ronaldo Marques                     #
# Liberacao      : 26/06/2003                                                #
#............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Incluida funcao fun_dba_abre_banco. #
###############################################################################

database porto

main

    call fun_dba_abre_banco("CT24HS") 
    call wdatc037()
end main
-------------------------------------------------------------------------------
function wdatc037()
-------------------------------------------------------------------------------
 define param       record
    usrtip          char (1),
    webusrcod       char (06), 
    sesnum          char (10),
    macsissgl       char (10)
 end record

 define ws          record
   statusprc        dec  (1,0),
   sestblvardes1    char (256),
   sestblvardes2    char (256),
   sestblvardes3    char (256),
   sestblvardes4    char (256),
   sespcsprcnom     char (256),
   prgsgl           char (256),
   acsnivcod        dec  (1,0),
   webprscod        dec  (16,0)
 end record

 define	l_ret		smallint

 initialize param.* to null
 initialize ws.* to null
 initialize l_ret to null

 let param.usrtip    = arg_val(1)
 let param.webusrcod = arg_val(2)
 let param.sesnum    = arg_val(3)
 let param.macsissgl = arg_val(4)

 set isolation to dirty read

 call wdatc002(param.*) 
      returning ws.*

 if ws.statusprc then
      display "ERRO@@Por quest\365es de seguran\347a seu tempo de<BR> permanência nesta página atingiu seu limite máximo.@@LOGIN"
      exit program(0)
 end if

 if wdatc003(param.*, ws.*) then
      display "ERRO@@Não foi possivel atualizar a sessão.@@LOGIN"
      exit program(0)
 end if

end function
