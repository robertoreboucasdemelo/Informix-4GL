#---------------------------------------------------------------------------#
#                     PORTO SEGURO CIA DE SEGUROS GERAIS                    #
#...........................................................................#
#  Sistema        : Central 24hs                                            #
#  Modulo         : wdatc059.4gl                                            #
#                   Extracao de dados de servicos bloqueados                #
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
       macsissgl       char (10),
       datainicial     char (10),
       datafinal       char (10),
       fase            char (01),
       evento          char (02) 
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

   initialize param.* to null
   initialize ws2.* to null

   call wdatc059_validausuario()
   call wdatc059_preparasql()
   call wdatc059_montapagina()

end main


#---------------------------------------------------------------------------#
function wdatc059_validausuario()
#---------------------------------------------------------------------------#

  #------------------------------------------
  #  ABRE BANCO   (TESTE ou PRODUCAO)
  #------------------------------------------
  call fun_dba_abre_banco("CT24HS")
  set isolation to dirty read

  let param.usrtip      = arg_val(1)
  let param.webusrcod   = arg_val(2)
  let param.sesnum      = arg_val(3)
  let param.macsissgl   = arg_val(4)
  let param.datainicial = arg_val(5)
  let param.datafinal   = arg_val(6)
  let param.fase        = arg_val(7)
  let param.evento      = arg_val(8)

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
end function  # wdatc059_validausuario()
#---------------------------------------------------------------------------#


#---------------------------------------------------------------------------#
function wdatc059_preparasql()
#---------------------------------------------------------------------------#

   define   l_sql   char(5000)
   initialize l_sql to null

   let l_sql = " select datmservico.atdsrvnum,"
              ,"        datmservico.atdsrvano,"
              ,"        datksrvtip.srvtipabvdes,"
              ,"        datmservico.atddat,"
              ,"        datmservico.atdhor,"
              ,"        datkevt.c24evtrdzdes,"
              ,"        datkfse.c24fsedes"
              ,"   from datmservico,"
              ,"        datmsrvanlhst,"
              ,"        datksrvtip,"
              ,"        datkevt,"
              ,"        datkfse"
              ,"  where datmservico.atddat between ? and ?"
              ,"    and datmservico.atdprscod = ?"
              ,"    and datksrvtip.atdsrvorg = datmservico.atdsrvorg"
              ,"    and datmsrvanlhst.atdsrvnum = datmservico.atdsrvnum"
              ,"    and datmsrvanlhst.atdsrvano = datmservico.atdsrvano"
              ,"    and datmsrvanlhst.c24fsecod <> 2"
              ,"    and datkfse.c24fsecod = datmsrvanlhst.c24fsecod"
              ,"    and datmsrvanlhst.c24evtcod <> 0"
              ,"    and datkevt.c24evtcod = datmsrvanlhst.c24evtcod"
              ,"    and datmsrvanlhst.srvanlhstseq = (select max(srvanlhstseq)"
              ,"   from datmsrvanlhst"
              ,"  where atdsrvnum = datmservico.atdsrvnum"
              ,"    and atdsrvano = datmservico.atdsrvano)"

   if param.fase <> "0" then
      let l_sql = l_sql clipped
                 ," and datmsrvanlhst.c24fsecod = ? "
   end if

   if param.evento <> "0" then
      let l_sql = l_sql clipped
                 ," and datmsrvanlhst.c24evtcod = ? "
   end if

   prepare pwdatc059001 from l_sql
   declare cwdatc059001 cursor for pwdatc059001

#---------------------------------------------------------------------------#
end function  # wdatc059_preparasql()
#---------------------------------------------------------------------------#


#---------------------------------------------------------------------------#
function wdatc059_montapagina()
#---------------------------------------------------------------------------#

   define   l_valores        record
            atdsrvnum        like   datmservico.atdsrvnum
           ,atdsrvano        like   datmservico.atdsrvano
           ,srvtipabvdes     like   datksrvtip.srvtipabvdes
           ,atddat           like   datmservico.atddat
           ,atdhor           like   datmservico.atdhor
           ,c24evtrdzdes     like   datkevt.c24evtrdzdes
           ,c24fsedes        like   datkfse.c24fsedes
   end record

   define   l_flag           smallint

   initialize l_valores to null
   initialize l_flag to null

   let l_flag = 0

   display "PADRAO@@1@@B@@C@@0@@Serviços Bloqueados@@"

   display "PADRAO@@6@@6@@",
           "N@@C@@0@@1@@13%@@Serviço@@@@",
           "N@@C@@0@@1@@13%@@Tipo@@@@",
           "N@@C@@0@@1@@13%@@Data@@@@",
           "N@@C@@0@@1@@10%@@Hora@@@@",
           "N@@C@@0@@1@@27%@@Evento@@@@",
           "N@@C@@0@@1@@20%@@Fase@@@@"

   if param.fase <> 0   and
      param.evento <> 0 then
      open cwdatc059001 using param.datainicial
                             ,param.datafinal
                             ,ws2.webprscod
                             ,param.fase
                             ,param.evento
   end if

   if param.fase <> 0  and
      param.evento = 0 then
      open cwdatc059001 using param.datainicial
                             ,param.datafinal
                             ,ws2.webprscod
                             ,param.fase
   end if

   if param.fase = 0 and
      param.evento <> 0 then
      open cwdatc059001 using param.datainicial
                             ,param.datafinal
                             ,ws2.webprscod
                             ,param.evento
   end if

   if param.fase = 0   and
      param.evento = 0 then
      open cwdatc059001 using param.datainicial
                             ,param.datafinal
                             ,ws2.webprscod
   end if

   foreach cwdatc059001 into l_valores.*

     let l_flag = 1

     display "PADRAO@@6@@6@@",
             "N@@C@@1@@1@@13%@@", l_valores.atdsrvnum using "<<<<<<<<<<", "/", l_valores.atdsrvano using "&&", "@@",
             "wdatc016.pl?usrtip=", param.usrtip, 
             "&webusrcod=", param.webusrcod clipped, 
             "&sesnum=", param.sesnum clipped,
             "&macsissgl=", param.macsissgl clipped, 
             "&atdsrvnum=", l_valores.atdsrvnum using "<<<<<<<<<<",
             "&atdsrvano=", l_valores.atdsrvano using "<<",
             "&acao=0", "@@",
             "N@@C@@1@@1@@13%@@", l_valores.srvtipabvdes, "@@@@",
             "N@@C@@1@@1@@13%@@", l_valores.atddat, "@@@@",
             "N@@C@@1@@1@@10%@@", l_valores.atdhor, "@@@@",
             "N@@C@@1@@1@@27%@@", l_valores.c24evtrdzdes, "@@@@",
             "N@@C@@1@@1@@20%@@", l_valores.c24fsedes, "@@@@"

   end foreach

   if l_flag = 0 then
      display "ERRO@@Não existem registros com a condição informada!@@BACK"
   end if

#---------------------------------------------------------------------------#
end function  # wdatc059_montapagina()
#---------------------------------------------------------------------------#
