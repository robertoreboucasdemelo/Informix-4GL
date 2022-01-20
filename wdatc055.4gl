###############################################################################
# Sistema........: Central 24 Horas                                           #
# Modulo.........: wdatc055                                                   #
# PSI............: 173436                                                     #
# Objetivo.......: Tela de consulta de serviços                               #
# Analista Resp..: Carlos Zyon                                                #
# Desenvolvimento: Rodrigo Santos - Fab. de Software                          #
# Data...........: 23/05/2003                                                 #
###############################################################################
# Alteracoes
# 31/07/2008  Fabio Costa  PSI227145 Buscar data/hora do acionamento do servico
#------------------------------------------------------------------------------

database porto

globals
    define g_ismqconn        smallint,
           g_servicoanterior smallint,
           g_meses           integer,
           w_hostname        char(03),
           g_isbigchar       smallint
end globals

define m_param     record
       usrtip      char (1),
       webusrcod   char (06),
       sesnum      char (10),
       macsissgl   char (10),
       acao        char (01),
       tipocons    char (01),
       de          date     ,
       ate         date     ,
       srvorg      smallint ,
       status      smallint  
end record

define m_ws2            record
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

   call wdatc055_versess()
   call wdatc055_mtapag()
   call wdatc055_atusess()

end main


#----------------------------------------------------------------------------#
function wdatc055_versess()
#----------------------------------------------------------------------------#

   initialize m_param.* to null
   initialize m_ws2.* to null
   initialize m_sttsess to null
   let m_sttsess = 0

   let m_param.usrtip    = arg_val(1)
   let m_param.webusrcod = arg_val(2)
   let m_param.sesnum    = arg_val(3)
   let m_param.macsissgl = arg_val(4)
   let m_param.de        = arg_val(5)
   let m_param.ate       = arg_val(6)
   let m_param.tipocons  = arg_val(7)
   let m_param.srvorg    = arg_val(8)
   let m_param.status    = arg_val(9)
   let m_param.acao      = 0
 
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
function wdatc055_mtapag()
#-----------------------------------------------------------------------------#

   define  l_i   smallint
          ,l_sql char(1000)

   define  l_registro   record
           atdvclsgl    like   datmservico.atdvclsgl
          ,atdsrvnum    like   datmservico.atdsrvnum
          ,atdsrvano    like   datmservico.atdsrvano
          ,atdsrvorg    like   datmservico.atdsrvorg
          ,atddat       like   datmservico.atddat
          ,atdhor       like   datmservico.atdhor
          ,atdetpcod    like   datmsrvacp.atdetpcod
          ,atdetpdes    like   datketapa.atdetpdes
          ,srvtipabvdes like   datksrvtip.srvtipabvdes
          ,socvclcod    like   datmservico.socvclcod
   end record
   
   define l_acihor record
          atddat  like datmsrvacp.atdetpdat ,
          atdhor  like datmsrvacp.atdetphor
   end record
    
   initialize l_registro.* to null
   initialize l_acihor.* to null
   initialize l_i   to null
   initialize l_sql to null

   let l_i = 1
   if m_param.macsissgl = 'LCVONLINE' then
      let l_sql = "select ''                     "
                 ,"      ,a.atdsrvnum            "
                 ,"      ,a.atdsrvano            "
                 ,"      ,atdsrvorg              " 
                 ,"      ,atddat                 "
                 ,"      ,atdhor                 "
                 ,"      ,pstcoddig              "
                 ,"  from datmservico a, datmsrvacp b, datmavisrent c "
                 ," where b.pstcoddig = ?        "
                 ,"   and a.atddat between ? and ? "
                 ,"   and a.atdsrvnum = b.atdsrvnum "
                 ,"   and a.atdsrvano = b.atdsrvano "
                 ,"   and c.atdsrvnum = b.atdsrvnum "
                 ,"   and c.atdsrvano = b.atdsrvano "
                 ,"   and b.atdsrvseq in (select max(atdsrvseq) "
                 ," from datmsrvacp d "
                 ," where  a.atdsrvnum = d.atdsrvnum "
                 ," and a.atdsrvano = d.atdsrvano)   "  
                 ," order by atddat, atdhor, atdsrvnum"
   end if

   if m_param.macsissgl = 'RLCONLINE' then 
      let l_sql = "select ''                     "
                 ,"      ,atdsrvnum              "
                 ,"      ,atdsrvano              "
                 ,"      ,atdsrvorg              " 
                 ,"      ,atddat                 "
                 ,"      ,atdhor                 "
                 ,"      ,pstcoddig              "
                 ,"  from datmservico a, datmsrvacp, datmavisrent c "
                 ," where b.srrcoddig = ?        "
                 ,"   and a.atddat between ? and ? "
                 ,"   and a.atdsrvnum = b.atdsrvnum "
                 ,"   and a.atdsrvano = b.atdsrvano "
                 ,"   and c.atdsrvnum = b.atdsrvnum "
                 ,"   and c.atdsrvano = b.atdsrvano "
                 ,"   and b.atdsrvseq in (select max(atdsrvseq) "
                 ," from datmsrvacp d "
                 ," where  a.atdsrvnum = d.atdsrvnum "
                 ," and a.atdsrvano = d.atdsrvano)   "  
                 ," order by atddat, atdhor, atdsrvnum"
   end if

   if m_param.macsissgl <> 'LCVONLINE' and 
      m_param.macsissgl <> 'RLCONLINE' then

      let l_sql = "select atdvclsgl              "
                 ,"      ,atdsrvnum              "
                 ,"      ,atdsrvano              "
                 ,"      ,atdsrvorg              " 
                 ,"      ,atddat                 "
                 ,"      ,atdhor                 "
                 ,"      ,socvclcod              "
                 ,"  from datmservico            "
                 ," where atdprscod = ?          "
                 ,"   and atddat between ? and ? "
   
      if m_param.srvorg <> 999 then
         let l_sql =  l_sql clipped
                    ," and atdsrvorg = ? "
      end if
   
      if m_param.tipocons = "1" then
         let l_sql =  l_sql clipped
                    ,"order by atddat, atdhor, atdvclsgl, atdsrvnum"
      else
         let l_sql =  l_sql clipped
                    ,"order by atdvclsgl, socvclcod, atddat, atdhor, atdsrvnum"
      end if

   end if

   prepare pwdatc055001 from l_sql
   declare cwdatc055001 cursor for pwdatc055001

   let l_sql = null
   let l_sql = "select atdetpdes     "
              ,"  from datketapa     "
              ," where atdetpcod = ? "

   prepare pwdatc055002 from l_sql
   declare cwdatc055002 cursor for pwdatc055002

   let l_sql = null
   let l_sql = "select srvtipabvdes  "
              ,"  from datksrvtip    "
              ," where atdsrvorg = ? "

   prepare pwdatc055003 from l_sql
   declare cwdatc055003 cursor for pwdatc055003

   let l_sql = null
   let l_sql = "select atdvclsgl     "
              ,"  from datkveiculo   "
              ," where socvclcod = ? "

   prepare pwdatc055004 from l_sql
   declare cwdatc055004 cursor for pwdatc055004
   
   # buscar data/hora do acionamento do servico
   let l_sql = " select atdetpdat, atdetphor " ,
               " from datmsrvacp " ,
               " where atdsrvnum = ? " ,
               "   and atdsrvano = ? " ,
               "   and atdsrvseq = ( select max(atdsrvseq) " ,
                                   " from datmsrvacp " ,
                                   " where atdsrvnum = ? " ,
                                   "   and atdsrvano = ? " ,
                                   "   and atdetpcod in (4,3,10) ) "
   prepare pwdatc055005 from l_sql
   declare cwdatc055005 cursor for pwdatc055005
   
   if m_param.srvorg <> 999 then
      open cwdatc055001 using m_ws2.webprscod
                             ,m_param.de
                             ,m_param.ate
                             ,m_param.srvorg
   else
      open cwdatc055001 using m_ws2.webprscod
                             ,m_param.de
                             ,m_param.ate
   end if

   display "PADRAO@@1@@B@@C@@0@@Serviços Recebidos@@"

   foreach cwdatc055001 into l_registro.atdvclsgl
                            ,l_registro.atdsrvnum
                            ,l_registro.atdsrvano
                            ,l_registro.atdsrvorg
                            ,l_registro.atddat
                            ,l_registro.atdhor
                            ,l_registro.socvclcod

      call cts10g04_ultima_etapa(l_registro.atdsrvnum
                                ,l_registro.atdsrvano)
           returning l_registro.atdetpcod

      if m_param.status <> 999 then
         if m_param.status <> l_registro.atdetpcod then
            continue foreach
         end if
      end if

      if l_i = 1 then
         if m_param.macsissgl = 'LCVONLINE' or 
            m_param.macsissgl = 'RLCONLINE' then 
            display "PADRAO@@6@@5"
                   ,"@@N@@C@@0@@1@@19%@@Serviço@@"
                   ,"@@N@@C@@0@@1@@20%@@Tipo@@"
                   ,"@@N@@C@@0@@1@@18%@@Data@@"
                   ,"@@N@@C@@0@@1@@14%@@Hora@@"
                   ,"@@N@@C@@0@@1@@25%@@Status@@"
                   ,"@@"
         else
            display "PADRAO@@6@@6"
                   ,"@@N@@C@@0@@1@@11%@@Viatura@@"
                   ,"@@N@@C@@0@@1@@16%@@Serviço@@"
                   ,"@@N@@C@@0@@1@@18%@@Tipo@@"
                   ,"@@N@@C@@0@@1@@16%@@Data@@"
                   ,"@@N@@C@@0@@1@@12%@@Hora@@"
                   ,"@@N@@C@@0@@1@@23%@@Status@@"
                   ,"@@"
         end if
      end if

      open cwdatc055003 using l_registro.atdsrvorg         

      whenever error continue
         fetch cwdatc055003 into l_registro.srvtipabvdes
      whenever error continue

      if sqlca.sqlcode <> 0 then
         let l_registro.srvtipabvdes = "NÃO INFORMADO"
      end if

      open cwdatc055002 using l_registro.atdetpcod         

      whenever error continue
         fetch cwdatc055002 into l_registro.atdetpdes
      whenever error continue

      if sqlca.sqlcode <> 0 then
         let l_registro.atdetpdes = "NÃO INFORMADO"
      end if

      if m_param.macsissgl <> 'LCVONLINE' and
         m_param.macsissgl <> 'RLCONLINE' then 

         if l_registro.atdvclsgl is null or
            l_registro.atdvclsgl = " "   then
            if l_registro.socvclcod is not null then
   
               open cwdatc055004 using l_registro.socvclcod
       
               whenever error continue
                  fetch cwdatc055004 into l_registro.atdvclsgl
               whenever error stop
   
               if sqlca.sqlcode <> 0 then
                  let l_registro.atdvclsgl = null 
               end if
   
            end if
         end if
      end if
      
      initialize l_acihor.* to null
      
      # buscar data/hora do acionamento do servico
      open cwdatc055005 using l_registro.atdsrvnum, l_registro.atdsrvano,
                              l_registro.atdsrvnum, l_registro.atdsrvano
      
      whenever error continue
      fetch cwdatc055005 into l_acihor.atddat, l_acihor.atdhor
      whenever error stop
      
      if l_acihor.atddat is not null and
         l_acihor.atdhor is not null
         then
         let l_registro.atddat = l_acihor.atddat
         let l_registro.atdhor = l_acihor.atdhor
      end if
      
      if m_param.macsissgl = 'LCVONLINE' or
         m_param.macsissgl = 'RLCONLINE' then 
         display "PADRAO@@6@@5"
                ,"@@N@@C@@1@@1@@19%@@", l_registro.atdsrvnum using "&&&&&&&"
                , "/", l_registro.atdsrvano using "&&" 
                ,"@@wdatc016.pl"
                ,"?usrtip=", m_param.usrtip clipped
                ,"&webusrcod=", m_param.webusrcod clipped
                ,"&sesnum=", m_param.sesnum using "<<<<<<<<<&"
                ,"&macsissgl=", m_param.macsissgl clipped
                ,"&atdsrvnum=", l_registro.atdsrvnum using "&&&&&&&"
                ,"&atdsrvano=", l_registro.atdsrvano using "&&"
                ,"&acao=", m_param.acao clipped
                ,"@@N@@C@@1@@1@@20%@@", l_registro.srvtipabvdes, "@@"
                ,"@@N@@C@@1@@1@@18%@@", l_registro.atddat, "@@"
                ,"@@N@@C@@1@@1@@14%@@", l_registro.atdhor, "@@"
                ,"@@N@@C@@1@@1@@25%@@", l_registro.atdetpdes, "@@"
                ,"@@"
      else
         display "PADRAO@@6@@6"
                ,"@@N@@C@@1@@1@@11%@@", l_registro.atdvclsgl, "@@"
                ,"@@N@@C@@1@@1@@16%@@", l_registro.atdsrvnum using "&&&&&&&"
                , "/", l_registro.atdsrvano using "&&" 
                ,"@@wdatc016.pl"
                ,"?usrtip=", m_param.usrtip clipped
                ,"&webusrcod=", m_param.webusrcod clipped
                ,"&sesnum=", m_param.sesnum using "<<<<<<<<<&"
                ,"&macsissgl=", m_param.macsissgl clipped
                ,"&atdsrvnum=", l_registro.atdsrvnum using "&&&&&&&"
                ,"&atdsrvano=", l_registro.atdsrvano using "&&"
                ,"&acao=", m_param.acao clipped
                ,"@@N@@C@@1@@1@@18%@@", l_registro.srvtipabvdes, "@@"
                ,"@@N@@C@@1@@1@@16%@@", l_registro.atddat, "@@"
                ,"@@N@@C@@1@@1@@12%@@", l_registro.atdhor, "@@"
                ,"@@N@@C@@1@@1@@23%@@", l_registro.atdetpdes, "@@"
                ,"@@"
      end if

      let l_i = l_i + 1

   end foreach

   if l_i = 1 then
      display "ERRO@@N\343o foram encontrados registros em nosso banco de dados.@@BACK"
   end if

end function


#-----------------------------------------------------------------------------#
function wdatc055_atusess()
#-----------------------------------------------------------------------------#

   call wdatc003(m_param.usrtip,
                 m_param.webusrcod,
                 m_param.sesnum,
                 m_param.macsissgl,
                 m_ws2.*)
        returning m_sttsess

end function


 function fonetica2()

 end function
 
 function conqua59()

 end function
