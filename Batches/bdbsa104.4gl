#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h  - Porto Socorro                        #
# Modulo        : bdbsa104.4gl                                        #
# Analista Resp.: Carlos Zyon                                         #
# PSI           : 188220                                              #
# Objetivo      : Carregar tabela dpakmedkmt com as medias das quanti #
#                 dades de km extra pagas nos ultimos 180 dias        #
#.....................................................................#
# Desenvolvimento: Mariana , META                                     #
# Liberacao      : 03/12/2004                                         #
#.....................................................................#

#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# 09/01/2006 Cristiane Silva    PSI197467 Refactoring                         #
###############################################################################
database porto

define m_path                 char(100)

main
   call fun_dba_abre_banco("CT24HS")

   set isolation to dirty read

   let m_path = f_path("DBS","LOG")

   if m_path is null then
      let m_path = "bdbsa104.log"
   else
      let m_path = m_path clipped, "/bdbsa104.log"
   end if

   call startlog(m_path)

   call bdbsa104_prepare()
   call bdbsa104()

end main

#----------------------------#
function bdbsa104_prepare()
#----------------------------#
define l_comando           char(800)


   let l_comando = "select a.ufdcod, a.cidnom, ",
       		   " b.ufdcod, b.cidnom, ",
       		   " avg(cstqtd) ",
  		   " from datmlcl a   ,datmlcl b, ",
       		   " dbsmopgcst c,dbsmopg e, dbsmopgitm d ",
 		   " where e.socfatpgtdat >= ? ",
   		   " and e.socopgsitcod  = 7 ",
   		   " and e.socopgnum     = d.socopgnum ",
   		   " and d.socopgnum     = c.socopgnum ",
   		   " and d.socopgitmnum  = c.socopgitmnum ",
   		   " and c.soccstcod    in (select soccstcod ",
                   " from dbskcustosocorro ",
                   " where soccstclccod = 3) ",
   		   " and c.cstqtd       > 0 ",
   		   " and d.atdsrvnum    = b.atdsrvnum ",
   		   " and d.atdsrvano    = b.atdsrvano ",
   		   " and a.c24endtip    = 1 ",
   		   " and b.c24endtip    = 2 ",
   		   " and a.atdsrvnum    = b.atdsrvnum ",
   		   " and a.atdsrvano    = b.atdsrvano ",
   		   " group by 1,2,3,4 "
   prepare pbdbsa104001 from l_comando
   declare cbdbsa104001 cursor for pbdbsa104001

   let l_comando = "select medkmtqtd     "
                  ,"  from dpakmedkmt    "
                  ," where ufdorgcod = ? "
                  ,"   and cidorgnom = ? "
                  ,"   and ufddstcod = ? "
                  ,"   and ciddstnom = ? "

   prepare pbdbsa104002 from l_comando
   declare cbdbsa104002 cursor for pbdbsa104002

   let l_comando = "insert into dpakmedkmt "
                  ,"      (medkmtcod, ufdorgcod, "
                  ,"       cidorgnom, ufddstcod, "
                  ,"       ciddstnom, medkmtqtd) "
                  ,"values(0,?,?,?,?,?)          "

   prepare pbdbsa104003 from l_comando

   let l_comando = "update dpakmedkmt      "
                  ,"   set medkmtqtd = ?   "
                  ," where ufdorgcod = ?   "
                  ,"   and cidorgnom = ?   "
                  ,"   and ufddstcod = ?   "
                  ,"   and ciddstnom = ?   "

   prepare pbdbsa104004 from l_comando

end function

#---------------------------#
function bdbsa104()
#---------------------------#

define lr_bdbsa104           record
       ufdorgcod             like dpakmedkmt.ufdorgcod
      ,cidorgnom             like dpakmedkmt.cidorgnom
      ,ufddstcod             like dpakmedkmt.ufddstcod
      ,ciddstnom             like dpakmedkmt.ciddstnom
      ,medkmtqtd             like dpakmedkmt.medkmtqtd
                             end record

define l_medkmtqtd           like dpakmedkmt.medkmtqtd


define l_data                date

   let l_data = today - 180 units day

   open cbdbsa104001 using l_data

   foreach cbdbsa104001 into lr_bdbsa104.*

      whenever error continue
      open cbdbsa104002 using lr_bdbsa104.ufdorgcod
                             ,lr_bdbsa104.cidorgnom
                             ,lr_bdbsa104.ufddstcod
                             ,lr_bdbsa104.ciddstnom
      fetch cbdbsa104002 into l_medkmtqtd
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            display "Erro SELECT cbdbsa104002 ", sqlca.sqlcode, '/'
                                               , sqlca.sqlerrd[2]
            display "bdbsa104(), ",lr_bdbsa104.ufdorgcod,'/'
                                  ,lr_bdbsa104.cidorgnom,'/'
                                  ,lr_bdbsa104.ufddstcod,'/'
                                  ,lr_bdbsa104.ciddstnom
            exit program(1)
         else             #---> Se nao encontrou, inclui o atual
            whenever error continue
            execute pbdbsa104003 using lr_bdbsa104.*
            whenever error stop
            if sqlca.sqlcode <> 0 then
               display "Erro INSERT pbdbsa104003 ", sqlca.sqlcode, '/'
                                                  , sqlca.sqlerrd[2]
               display "bdbsa104(), ",lr_bdbsa104.ufdorgcod,'/'
                                     ,lr_bdbsa104.cidorgnom,'/'
                                     ,lr_bdbsa104.ufddstcod,'/'
                                     ,lr_bdbsa104.ciddstnom,'/'
                                     ,lr_bdbsa104.medkmtqtd
               exit program(1)
            end if
         end if
      else               #---> Se encontrou, atualiza km
         whenever error continue
         execute pbdbsa104004 using lr_bdbsa104.medkmtqtd
                                   ,lr_bdbsa104.ufdorgcod
                                   ,lr_bdbsa104.cidorgnom
                                   ,lr_bdbsa104.ufddstcod
                                   ,lr_bdbsa104.ciddstnom
         whenever error stop
         if sqlca.sqlcode <> 0 then
            display "Erro UPDATE pbdbsa104004 ", sqlca.sqlcode, '/'
                                               , sqlca.sqlerrd[2]
            display "bdbsa104(), " ,lr_bdbsa104.medkmtqtd,'/'
                                   ,lr_bdbsa104.ufdorgcod,'/'
                                   ,lr_bdbsa104.cidorgnom,'/'
                                   ,lr_bdbsa104.ufddstcod,'/'
                                   ,lr_bdbsa104.ciddstnom,'/'
            exit program(1)
         end if
      end if

   end foreach

end function
