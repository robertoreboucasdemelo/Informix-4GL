###############################################################################
# PORTO SEGURO CIA DE SEGUROS GERAIS                                          #
#.............................................................................#
# Sistema        : Porto Socorro                                              #
# Modulo         : WDATC077                                                   #
#                  Obter as informacoes para o laudo da reserva do carro extra#
#                  para o Portal de Negocios.                                 #
# Analista Resp. : Ligia Mattge                                               #
# PSI            : 196878                                                     #
#.............................................................................#
# Desenvolvimento: Helio (Meta)                                               #
# Liberacao      :                                                            #
#-----------------------------------------------------------------------------#
#                 * * *  A L T E R A C A O  * * *                             #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 23/08/2007 Saulo, Meta     AS146056   fun_dba movida para o inicio do modulo#
###############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"

define param record
   usrtip              char (001)
  ,webusrcod           char (006)
  ,sesnum              dec  (010)
  ,macsissgl           char (010)
  ,atdsrvnum           like datmservico.atdsrvnum
  ,atdsrvano           like datmservico.atdsrvano
  ,acao                char (1)
end record

main

define ws1 record
   statusprc           dec  (01,0)
  ,sestblvardes1       char (0256)
  ,sestblvardes2       char (0256)
  ,sestblvardes3       char (0256)
  ,sestblvardes4       char (0256)
  ,sespcsprcnom        char (0256)
  ,prgsgl              char (0256)
  ,acsnivcod           dec  (01,0)
  ,webprscod           dec  (16,0)
end record

   initialize param.* to null
   initialize ws1.* to null


   #---------------------------------
   # Le parametros recebidos do PERL
   #---------------------------------
   let param.usrtip       = arg_val(1)
   let param.webusrcod    = arg_val(2)
   let param.sesnum       = arg_val(3)
   let param.macsissgl    = arg_val(4)
   let param.atdsrvnum    = arg_val(5)
   let param.atdsrvano    = arg_val(6)
   let param.acao         = arg_val(7)

   initialize ws1 to null

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------
   call fun_dba_abre_banco("CT24HS")
   set isolation to dirty read

   #---------------------------------------------
   #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
   #---------------------------------------------
   call wdatc002(param.usrtip,
                 param.webusrcod,
                 param.sesnum,
                 param.macsissgl)
                 returning ws1.*

   if ws1.statusprc <> 0 then
       display "NOSESS@@Por questões de segurança seu tempo de<BR> permanência nesta página atingiu o limite máximo.@@"
       exit program(0)
   end if

   let ws1.prgsgl = "wdatc0017"


   call wdatc077()

end main

#-----------------------------------------------------------------------------
function wdatc077()
#-----------------------------------------------------------------------------

define l_null          char(01)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

   initialize l_null  to  null

   let l_null = ""


   call cts15m14_carro_extra(param.atdsrvnum
                            ,param.atdsrvano, l_null, l_null
                            ,l_null, l_null, l_null,"T",l_null
                            ,l_null, l_null, l_null, param.acao)

end function #wdatc077




