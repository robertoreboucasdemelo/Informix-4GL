#---------------------------------------------------------------------------#
#                     PORTO SEGURO CIA DE SEGUROS GERAIS                    #
#...........................................................................#
#  Sistema        : Central 24hs                                            #
#  Modulo         : wdatc063.4gl                                            #
#                   Extracao de dados de servicos bloqueados                #
#  Analista Resp. : Carlos Zyon                                             #
#  PSI            : 177890/ OSF 29106                                       #
#...........................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE - Alexandre Figueiredo - OSF 29106  #
#  Liberacao      :                                                         #
#...........................................................................#
#                     * * * A L T E R A C A O * * *                         #
#                                                                           #
#  Data         Autor Fabrica  Observacao                                   #
#  ----------   -------------  -------------------------------------------  #
#                                                                           #
#---------------------------------------------------------------------------#

database porto

define m_param           record
       usrtip          char (1),
       webusrcod       char (06),
       sesnum          char (10),
       macsissgl       char (10)
end record

define m_ws2              record
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
  call wdatc063_validausuario()
  call wdatc063_preparasql()
  call wdatc063_montapagina()
end main


#---------------------------------------------------------------------------#
function wdatc063_validausuario()
#---------------------------------------------------------------------------#

  initialize m_param.* to null
  initialize m_ws2.* to null

  #------------------------------------------
  #  ABRE BANCO   (TESTE ou PRODUCAO)
  #------------------------------------------
  call fun_dba_abre_banco("CT24HS")
  set isolation to dirty read

  let m_param.usrtip    = arg_val(1)
  let m_param.webusrcod = arg_val(2)
  let m_param.sesnum    = arg_val(3)
  let m_param.macsissgl = arg_val(4)

  #---------------------------------------------
  #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
  #---------------------------------------------

  call wdatc002(m_param.*)
       returning m_ws2.*

  if m_ws2.statusprc <> 0 then
     display "NOSESS"
            ,"@@"
            ,"Por quest\365es de seguran\347a seu tempo de<BR> permanência "
            ,"nesta p\341gina atingiu o limite m\341ximo.@@"
     exit program(0)
  end if

#---------------------------------------------------------------------------#
end function  # wdatc063_validausuario()
#---------------------------------------------------------------------------#


#---------------------------------------------------------------------------#
function wdatc063_preparasql()
#---------------------------------------------------------------------------#

   define   l_sql   char(1000)

   initialize l_sql to null

   let l_sql = "select datmservico.atdsrvnum,     ",
               "       datmservico.atdsrvano,     ",
               "       datksrvtip.srvtipabvdes,   ", 
               "       datmservico.atddat,        ",
               "       datmservico.atdhor         ",
               "  from datmservico, dbsmsrvacr,   ",
               "       datksrvtip                 ",
               " where dbsmsrvacr.pstcoddig = ?   ",
               "   and dbsmsrvacr.prsokaflg = 'S' ",
               "   and dbsmsrvacr.anlokaflg = 'S' ",
               "   and dbsmsrvacr.autokaflg = 'N' ",
 
               ###teste retirar...
               ##"   and datksrvtip.srvtipabvdes = 'APOIO'"

               "   and dbsmsrvacr.atdsrvnum = datmservico.atdsrvnum ",
               "   and dbsmsrvacr.atdsrvano = datmservico.atdsrvano ",
               "   and dbsmsrvacr.pstcoddig = datmservico.atdprscod ",
               "   and datksrvtip.atdsrvorg = datmservico.atdsrvorg "

   prepare pwdatc063001 from l_sql
   declare cwdatc063001 cursor for pwdatc063001

   let l_sql = " select dbsmopg.socopgnum ",
               "   from dbsmopgitm, dbsmopg ",
               "  where dbsmopgitm.atdsrvnum = ? ",
               "    and dbsmopgitm.atdsrvano = ? ",
               "    and dbsmopg.socopgnum    = dbsmopgitm.socopgnum  ",
               "    and dbsmopg.socopgsitcod <> 8 "

   prepare pwdatc063002 from l_sql
   declare cwdatc063002 cursor for pwdatc063002

#---------------------------------------------------------------------------#
end function  # wdatc063_preparasql()
#---------------------------------------------------------------------------#


#---------------------------------------------------------------------------#
function wdatc063_montapagina()
#---------------------------------------------------------------------------#

   define   l_servanalisados record
            atdsrvnum      like   datmservico.atdsrvnum,
            atdsrvano      like   datmservico.atdsrvano,
            srvtipabvdes   like   datksrvtip.srvtipabvdes,
            atddat         like   datmservico.atddat,
            atdhor         like   datmservico.atdhor
   end record

   define   l_verservicos record
            socopgnum      like   dbsmopg.socopgnum 
   end record

   define l_link  char(250),
          l_sqlca smallint

   initialize l_servanalisados.* to null
   initialize l_verservicos.* to null
   initialize l_link  to null
   initialize l_sqlca to null

   display "PADRAO@@1"
          ,"@@B@@C@@0@@Serviços Analisados@@"

   display "PADRAO@@6"
          ,"@@4"
          ,"@@N@@C@@0@@1@@25%@@Servico@@"
          ,"@@N@@C@@0@@1@@25%@@Tipo@@"
          ,"@@N@@C@@0@@1@@25%@@Data@@"
          ,"@@N@@C@@0@@1@@25%@@Hora@@@@"


   let l_sqlca = 0
   open cwdatc063001 using m_ws2.webprscod
   foreach cwdatc063001 into l_servanalisados.*

      open cwdatc063002 using l_servanalisados.atdsrvnum,
                              l_servanalisados.atdsrvano
      whenever error continue
      fetch cwdatc063002 into l_verservicos.*
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
           display "ERRO@@Erro (", sqlca.sqlcode using'<<<<<&', ") acesso banco de Dados. AVISE A INFORMATICA!@@BACK"
           exit program
         else
            let l_sqlca = 1
            let l_link = "wdatc064.pl",
                   "?usrtip=",    m_param.usrtip,
                   "&webusrcod=", m_param.webusrcod using "<<<<<<<",
                   "&sesnum=",    m_param.sesnum    using "<<<<<<<<<<<<<<",
                   "&macsissgl=", m_param.macsissgl clipped,
                   "&atdsrvnum=", l_servanalisados.atdsrvnum using "<<<<<<<<<<",
                   "&atdsrvano=", l_servanalisados.atdsrvano using "<<",
                   "&acao=0",
                   "&modulo=wdatc063"

            display "PADRAO@@6"
                   ,"@@4"
                   ,"@@N@@C@@1@@1@@25%@@"
                   , l_servanalisados.atdsrvnum, "/"
                   , l_servanalisados.atdsrvano using "&&"   
                   ,"@@", l_link 
                   ,"@@N@@C@@1@@1@@25%@@"
                   , l_servanalisados.srvtipabvdes clipped , "@@" 
                   ,"@@N@@C@@1@@1@@25%@@"
                   , l_servanalisados.atddat , "@@" 
                   ,"@@N@@C@@1@@1@@25%@@"
                   , l_servanalisados.atdhor, "@@@@" 
         end if
      end if
   end foreach

   if l_sqlca = 0 then
      display "ERRO@@ Nao existem registros !@@BACK" 
      exit program
   end if   


#---------------------------------------------------------------------------#
end function  # wdatc063_montapagina()
#---------------------------------------------------------------------------#
