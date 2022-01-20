#---------------------------------------------------------------------------#
#                     PORTO SEGURO CIA DE SEGUROS GERAIS                    #
#...........................................................................#
#  Sistema        : Central 24hs                                            #
#  Modulo         : wdatc061.4gl                                            #
#                   Extracao de dados de servicos em analise                #
#  Analista Resp. : Carlos Zyon                                             #
#  PSI            : 177890                                                  #
#...........................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE - Rodrigo Santos - OSF 29106        #
#  Liberacao      :                                                         #
#...........................................................................#
#                     * * * A L T E R A C A O * * *                         #
#                                                                           #
#  Data         Autor Fabrica  Observacao                                   #
#  ----------   -------------  -------------------------------------------  #
#                                                                           #
#---------------------------------------------------------------------------#

database porto

define param           record
       usrtip          char (01),
       webusrcod       char (06),
       sesnum          char (10),
       macsissgl       char (10)
end record

define ws2              record
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

main

   call wdatc061_validausuario()
   call wdatc061_preparasql()
   call wdatc061_montapagina()

end main


#---------------------------------------------------------------------------#
function wdatc061_validausuario()
#---------------------------------------------------------------------------#

  initialize param.* to null
  initialize ws2.* to null

  #------------------------------------------
  #  ABRE BANCO   (TESTE ou PRODUCAO)
  #------------------------------------------
  call fun_dba_abre_banco("CT24HS")
  set isolation to dirty read

  let param.usrtip      = arg_val(1)
  let param.webusrcod   = arg_val(2)
  let param.sesnum      = arg_val(3)
  let param.macsissgl   = arg_val(4)

  #---------------------------------------------
  #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
  #---------------------------------------------
 
  call wdatc002(param.usrtip
               ,param.webusrcod
               ,param.sesnum
               ,param.macsissgl)
       returning ws2.*

  if ws2.statusprc <> 0 then
     display "NOSESS"
            ,"@@"
            ,"Por quest\365es de seguran\347a seu tempo de<BR> permanência "
            ,"nesta p\341gina atingiu o limite m\341ximo.@@"
     exit program(0)
  end if
 

#---------------------------------------------------------------------------#
end function  # wdatc061_validausuario()
#---------------------------------------------------------------------------#


#---------------------------------------------------------------------------#
function wdatc061_preparasql()
#---------------------------------------------------------------------------#

   declare cwdatc061001 cursor for 
    select datmservico.atdsrvnum,
           datmservico.atdsrvano,
           datksrvtip.srvtipabvdes,
           datmservico.atddat,
           datmservico.atdhor
      from dbsmsrvacr,
           datmservico,
           datksrvtip
     where dbsmsrvacr.pstcoddig = ws2.webprscod
       and dbsmsrvacr.prsokaflg = 'S'
       and dbsmsrvacr.anlokaflg = 'N'
       and dbsmsrvacr.autokaflg = 'N'
       and dbsmsrvacr.atdsrvnum = datmservico.atdsrvnum
       and dbsmsrvacr.atdsrvano = datmservico.atdsrvano
       and dbsmsrvacr.pstcoddig = datmservico.atdprscod
       and datksrvtip.atdsrvorg = datmservico.atdsrvorg

#---------------------------------------------------------------------------#
end function  # wdatc061_preparasql()
#---------------------------------------------------------------------------#


#---------------------------------------------------------------------------#
function wdatc061_montapagina()
#---------------------------------------------------------------------------#

   define   l_valores        record
            atdsrvnum        like   datmservico.atdsrvnum
           ,atdsrvano        like   datmservico.atdsrvano
           ,srvtipabvdes     like   datksrvtip.srvtipabvdes
           ,atddat           like   datmservico.atddat
           ,atdhor           like   datmservico.atdhor
   end record

   define   l_flag           smallint

   initialize   l_valores.* to null
   let l_flag = 0

   display "PADRAO@@1@@B@@C@@0@@Serviços em análise@@"

   display "PADRAO@@6@@4@@",
           "N@@C@@0@@1@@25%@@Serviço@@@@",
           "N@@C@@0@@1@@25%@@Tipo@@@@",
           "N@@C@@0@@1@@25%@@Data@@@@",
           "N@@C@@0@@1@@25%@@Hora@@@@"

   foreach cwdatc061001 into l_valores.*

     let l_flag = 1

     display "PADRAO@@6@@4@@",
             "N@@C@@1@@1@@25%@@", l_valores.atdsrvnum using "<<<<<<<<<<", "/", l_valores.atdsrvano using "&&", "@@",
             "wdatc064.pl?usrtip=", param.usrtip, 
             "&webusrcod=", param.webusrcod clipped, 
             "&sesnum=", param.sesnum clipped,
             "&macsissgl=", param.macsissgl clipped, 
             "&atdsrvnum=", l_valores.atdsrvnum using "<<<<<<<<<<",
             "&atdsrvano=", l_valores.atdsrvano using "<<",
             "&acao=0", 
             "&modulo=wdatc061",
             "@@",
             "N@@C@@1@@1@@25%@@", l_valores.srvtipabvdes, "@@@@",
             "N@@C@@1@@1@@25%@@", l_valores.atddat, "@@@@",
             "N@@C@@1@@1@@25%@@", l_valores.atdhor, "@@@@"

   end foreach

   if l_flag = 0 then
      display "ERRO@@Não existem registros!@@BACK"
   end if

#---------------------------------------------------------------------------#
end function  # wdatc061_montapagina()
#---------------------------------------------------------------------------#
