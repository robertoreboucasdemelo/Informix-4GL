###############################################################################
# Sistema........: Central 24 Horas                                           #
# Modulo.........: wdatc053                                                   #
# PSI............: 173436                                                     #
# Objetivo.......: Tela de consulta de serviços                               #
# Analista Resp..: Carlos Zyon                                                #
# Desenvolvimento: Rodrigo Santos - Fab. de Software                          #
# Data...........: 23/05/2003                                                 #
###############################################################################

database porto


define m_param       record
       usrtip      char (1),
       webusrcod   char (06),
       sesnum      char (10),
       macsissgl   char (10)
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

define m_sttsess   dec  (1,0)


main

   call wdatc053_versess()
   call wdatc053_mtacursor()
   call wdatc053_mtapag()
   call wdatc053_atusess()
   call wdatc053_libcursor()

end main


#-----------------------------------------------------------------------------#
function wdatc053_mtacursor()
#-----------------------------------------------------------------------------#

   declare cwdatc053001 cursor for
    select srvtipabvdes, atdsrvorg
      from datksrvtip
     order by 1

   declare cwdatc053002 cursor for
    select atdetpcod,atdetpdes
      from datketapa
     order by 2

end function


#-----------------------------------------------------------------------------#
function wdatc053_libcursor()
#-----------------------------------------------------------------------------#

   free cwdatc053001
   free cwdatc053002

end function


#-----------------------------------------------------------------------------#
function wdatc053_versess()
#-----------------------------------------------------------------------------#

   initialize m_param.* to null
   initialize m_ws2.* to null
   initialize m_sttsess to null
   let m_sttsess = 0

   let m_param.usrtip = arg_val(1)
   let m_param.webusrcod = arg_val(2)
   let m_param.sesnum    = arg_val(3)
   let m_param.macsissgl = arg_val(4)

   call fun_dba_abre_banco("CT24HS")
   set isolation to dirty read

   call wdatc002(m_param.usrtip,
                 m_param.webusrcod,
                 m_param.sesnum,
                 m_param.macsissgl)
       returning m_ws2.*

   if m_ws2.statusprc <> 0 then
      display "NOSESS@@Por quest\365es de seguran\347a seu tempo de<BR> permanência nesta p\341gina atingiu o limite m\341ximo.@@"
      exit program(0)
   end if            

end function


#-----------------------------------------------------------------------------#
function wdatc053_mtapag()
#-----------------------------------------------------------------------------#

   define l_data              date
         ,l_tag               char(2000)

   define l_orgsrv            record
          srvtipabvdes like   datksrvtip.srvtipabvdes
         ,atdsrvorg    like   datksrvtip.atdsrvorg
   end record

   define l_status            record
          atdetpcod    like   datketapa.atdetpcod
         ,atdetpdes    like   datketapa.atdetpdes
   end record

   let l_tag  = null
   let l_data = current
   initialize l_orgsrv.* to null
   initialize l_status.* to null

   display "PADRAO@@4@@2@@Consulta@@0@@"
          ,"@@consulta@@1@@Por período@@1@@0@@@@"
          ,"@@consulta@@2@@Por viatura@@0@@0@@@@@@"

   display "PADRAO@@5"
          ,"@@De@@0@@@@(dd/mm/aaaa)@@10@@10"
          ,"@@text@@de@@", l_data, "@@"

   display "PADRAO@@5"
          ,"@@Até@@0@@@@(dd/mm/aaaa)@@10@@10"
          ,"@@text@@ate@@", l_data, "@@"

   let l_tag = "PADRAO@@2@@srvorg@@Origem do Serviço@@0@@"
              ,"@@TODOS@@1@@999"
   foreach cwdatc053001 into l_orgsrv.*
      let l_tag = l_tag clipped
                 , "@@", l_orgsrv.srvtipabvdes clipped
                 , "@@0@@", l_orgsrv.atdsrvorg
   end foreach

   display l_tag
   let l_tag = null

   let l_tag = "PADRAO@@2@@status@@Status@@0@@"
              ,"@@TODOS@@1@@999"

   foreach cwdatc053002 into l_status.*
      let l_tag = l_tag clipped
                 , "@@", l_status.atdetpdes clipped
                 , "@@0@@", l_status.atdetpcod
   end foreach

   display l_tag
   let l_tag = null

end function


#-----------------------------------------------------------------------------#
function wdatc053_atusess()
#-----------------------------------------------------------------------------#

   call wdatc003(m_param.usrtip,
                 m_param.webusrcod,
                 m_param.sesnum,
                 m_param.macsissgl,
                 m_ws2.*)
        returning m_sttsess

end function
