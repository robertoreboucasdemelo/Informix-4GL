#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR042                                                   #
# ANALISTA RESP..: RAFAEL MOREIRA GOMES                                       #
# PSI/OSF........: Retorno de Servicos                                        #
# ........................................................................... #
# DESENVOLVIMENTO: FORNAX TECNOLOGIA, RCP                                     #
# LIBERACAO......: 19/05/2015                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 08/06/2015 RCP, Fornax     RELTXT     Criar versao .txt dos relatorios.     #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_path           char(100)
     , m_path_txt       char(100) #--> RELTXT
     , m_data           date 
 
define mr_datmservico   record                            
       atdsrvnum        like datmservico.atdsrvnum        
     , atdsrvano        like datmservico.atdsrvano        
     , atddat           like datmservico.atddat           
     , atdhor           like datmservico.atdhor           
     , srvprsacndat     date
     , srvprsacnhor     datetime hour to minute
     , atddatprg        like datmservico.atddatprg
     , atdhorprg        like datmservico.atdhorprg
     , atdsrvorg        like datmservico.atdsrvorg        
     , ciaempcod        like datmservico.ciaempcod        
     , atdprscod        like datmservico.atdprscod        
     , srrcoddig        like datmservico.srrcoddig        
     , atdvclsgl        like datmservico.atdvclsgl        
     , socvclcod        like datmservico.socvclcod         
     , asitipcod        like datmservico.asitipcod        
     , vclcoddig        like datmservico.vclcoddig        
     , vclanomdl        like datmservico.vclanomdl        
     , cornom           like datmservico.cornom           
     , corsus           like datmservico.corsus           
     , nom              like datmservico.nom              
end    record                                            
 
define mr_original      record                            
       atddat           like datmservico.atddat           
     , atdhor           like datmservico.atdhor           
     , srvprsacndat     date
     , srvprsacnhor     datetime hour to minute
     , atddatprg        like datmservico.atddatprg
     , atdhorprg        like datmservico.atdhorprg
     , atdprscod        like datmservico.atdprscod        
     , srrcoddig        like datmservico.srrcoddig        
     , srrnom           like datksrr.srrnom
     , pptnom           like dpaksocor.pptnom
     , pcpatvcod        like dpaksocor.pcpatvcod
end    record                                            

define mr_datmsrvre     record
       srvretmtvcod     like datmsrvre.srvretmtvcod 
     , retprsmsmflg     like datmsrvre.retprsmsmflg
     , atdorgsrvnum     like datmsrvre.atdorgsrvnum
     , atdorgsrvano     like datmsrvre.atdorgsrvano
end    record

define mr_datksrvret    record
       srvretmtvdes     like datksrvret.srvretmtvdes 
end    record

define mr_datmatd6523   record
       cgccpfnum        like datmatd6523.cgccpfnum
     , cgcord           like datmatd6523.cgcord
     , cgccpfdig        like datmatd6523.cgccpfdig
end    record

define mr_datrservapol  record
       succod           like datrservapol.succod
     , ramcod           like datrservapol.ramcod
     , aplnumdig        like datrservapol.aplnumdig
     , itmnumdig        like datrservapol.itmnumdig
end    record

define mr_datketapa     record
       atdetpdes        like datketapa.atdetpdes
end    record

define mr_dpaksocor     record
       pstcoddig        like dpaksocor.pstcoddig
     , pptnom           like dpaksocor.pptnom
     , endcid           like dpaksocor.endcid
     , endufd           like dpaksocor.endufd
     , pcpatvcod        like dpaksocor.pcpatvcod
     , qldgracod        like dpaksocor.qldgracod
end    record

define mr_datksrr       record
       srrnom           like datksrr.srrnom
end    record

define mr_datkitaclisgm record
       itaclisgmdes     like datkitaclisgm.itaclisgmdes
end    record

define mr_datmlcl       record
       cidnom           like datmlcl.cidnom
     , ufdcod           like datmlcl.ufdcod
end    record

define mr_datrcidsed    record
       cidsedcodsrv     like glakcid.cidnom
     , cidsedcodpst     like glakcid.cidnom 
end    record

define mr_datkpbm       record
       c24pbmdes        like datkpbm.c24pbmdes
     , c24pbmgrpdes     like datkpbmgrp.c24pbmgrpdes
end    record

define mr_datksocntz    record
       socntzdes        like datksocntz.socntzdes
end    record

define mr_datkassunto   record
       c24astdes        like datkassunto.c24astdes
end    record
       
define mr_pcgksusep     record
       succod           like pcgksusep.succod
end    record

define mr_abbmveic      record
       vcllicnum        like abbmveic.vcllicnum
     , vclchsinc        like abbmveic.vclchsinc
     , vclchsfnl        like abbmveic.vclchsfnl
     , vclanofbc        like abbmveic.vclanofbc
end    record 
       
define mr_datkasitip    record
       asitipdes        like datkasitip.asitipdes
end    record

define mr_gabksuc       record
       sucnomapl        like gabksuc.sucnom
     , sucnomcor        like gabksuc.sucnom
end    record 

define mr_datksrvtip    record
       srvtipdes        like datksrvtip.srvtipdes
end    record
       
define mr_iddkdominio   record
       socvclcoddes     like iddkdominio.cpodes
     , pcpatvcoddes     like iddkdominio.cpodes
     , pcpatvcoddesorg  like iddkdominio.cpodes
     , qldgracoddes     like iddkdominio.cpodes
end    record
       
main

    call fun_dba_abre_banco("CT24HS")
   
    call bdbsr042_busca_path()

    call bdbsr042_prepare()

    call cts40g03_exibe_info("I","bdbsr042")

    set isolation to dirty read
 
    call bdbsr042_servicosAtendidos()

    call bdbsr042_envia_email()
    
    call cts40g03_exibe_info("F","bdbsr042")

end main

#------------------------------#
 function bdbsr042_busca_path()
#------------------------------#

    define l_dataarq char(8)
    define l_data    date
    
    let l_data = today
    display "l_data: ", l_data
    let l_dataarq = extend(l_data, year to year),
                    extend(l_data, month to month),
                    extend(l_data, day to day)
    display "l_dataarq: ", l_dataarq

    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_path = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr042.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if
    
    let m_path_txt = m_path clipped, "/BDBSR042_", l_dataarq, ".txt" 
    let m_path     = m_path clipped, "/BDBSR042.xls"
    
 end function

#---------------------------#
 function bdbsr042_prepare()
#---------------------------#
  define l_sql char(1000)
  define l_data_inicio, l_data_fim date
  define l_data_atual date,
         l_hora_atual datetime hour to minute

  let l_data_atual = arg_val(1)
   
  # ---> OBTER A DATA E HORA DO BANCO
  if l_data_atual is null then
     call cts40g03_data_hora_banco(2)
          returning l_data_atual,
                    l_hora_atual
                    
     let m_data = l_data_atual
   
  end if 
    
  # Programa de processamento diario
  let l_data_inicio = l_data_atual - 1
  let l_data_fim    = l_data_atual - 1 

  display "l_data_inicio: ",l_data_inicio

  let m_data = l_data_inicio

  # ---> OBTEM DADOS PARA O RELATORIO
  let l_sql = " select srv.atdsrvnum       "
            , "      , srv.atdsrvano       "
            , "      , srv.atddat          "
            , "      , srv.atdhor          "
            , "      , srv.srvprsacnhordat "
            , "      , srv.srvprsacnhordat "
            , "      , srv.atddatprg       "
            , "      , srv.atdhorprg       "
            , "      , srv.atdsrvorg       "
            , "      , srv.ciaempcod       "
            , "      , srv.atdprscod       "
            , "      , srv.srrcoddig       "
            , "      , srv.atdvclsgl       "
            , "      , srv.socvclcod       "
            , "      , srv.asitipcod       "
            , "      , srv.vclcoddig       "
            , "      , srv.vclanomdl       "
            , "      , srv.cornom          "
            , "      , srv.corsus          "
            , "      , srv.nom             "
            , "      , ret.srvretmtvcod    "
            , "      , ret.retprsmsmflg    "
            , "      , ret.atdorgsrvnum    "
            , "      , ret.atdorgsrvano    "
            , "  from datmservico srv, datmsrvre ret, datmservico org "
            , " where srv.atddat between'", l_data_inicio, "' and '", l_data_fim, "'" 
            , "   and ret.atdsrvnum = srv.atdsrvnum    "
            , "   and ret.atdsrvano = srv.atdsrvano    "
            , "   and org.atdsrvnum = ret.atdorgsrvnum "
            , "   and org.atdsrvano = ret.atdorgsrvano "
  prepare pbdbsr042001 from l_sql            
  declare cbdbsr042001 cursor for pbdbsr042001    
                  
  let l_sql = " select cgccpfnum  "
            , "      , cgcord     "
            , "      , cgccpfdig  "
            , "  from datmatd6523 "
            , " where atdnum = ?  "
  prepare pbdbsr042002 from l_sql            
  declare cbdbsr042002 cursor for pbdbsr042002    
   
  let l_sql = " select succod        "
            , "      , ramcod        "
            , "      , aplnumdig     "
            , "      , itmnumdig     "
            , "   from datrservapol  "
            , "  where atdsrvnum = ? "
            , "    and atdsrvano = ? "  
  prepare pbdbsr042003 from l_sql            
  declare cbdbsr042003 cursor for pbdbsr042003    
                  
  let l_sql = " select b.atdetpdes               "
            , "   from datmsrvacp a, datketapa b "
            , "  where a.atdsrvnum = ?           "
            , "    and a.atdsrvano = ?           "  
            , "    and b.atdetpcod = a.atdetpcod "
            , "  order by a.atdsrvseq desc       "
  prepare pbdbsr042004 from l_sql            
  declare cbdbsr042004 cursor for pbdbsr042004   
                   
  let l_sql = " select pstcoddig "
            , "      , pptnom    "
            , "      , endcid    "
            , "      , endufd    "
            , "      , pcpatvcod "
            , "      , qldgracod "
            , "   from dpaksocor "
            , "  where pstcoddig = ? "
  prepare pbdbsr042005 from l_sql            
  declare cbdbsr042005 cursor for pbdbsr042005   

  let l_sql = " select srrnom  "
            , "   from datksrr srr "
            , "  where srrcoddig = ? "
  prepare pbdbsr042006 from l_sql            
  declare cbdbsr042006 cursor for pbdbsr042006   

  let l_sql = " select cidnom        "
            , "      , ufdcod        "
            , "   from datmlcl       "
            , "  where atdsrvnum = ? "
            , "    and atdsrvano = ? "  
            , "    and c24endtip = 1 "  
  prepare pbdbsr042008 from l_sql            
  declare cbdbsr042008 cursor for pbdbsr042008   

  let l_sql = " select srvtipdes     "
            , "   from datksrvtip    "
            , "  where atdsrvorg = ? "
  prepare pbdbsr042009 from l_sql            
  declare cbdbsr042009 cursor for pbdbsr042009    
                    
  let l_sql = " select c.cidnom "
            , "   from glakcid a, datrcidsed b, glakcid c "
            , "  where a.cidnom = ? "
            , "    and a.ufdcod = ? "
            , "    and b.cidcod = a.cidcod "
            , "    and c.cidcod = a.cidcod "
  prepare pbdbsr042010 from l_sql            
  declare cbdbsr042010 cursor for pbdbsr042010    
                    
  let l_sql = " select asitipdes     "
            , "   from datkasitip    "
            , "  where asitipcod = ? "
  prepare pbdbsr042011 from l_sql            
  declare cbdbsr042011 cursor for pbdbsr042011    

  let l_sql = " select b.c24pbmdes    "
            , "      , c.c24pbmgrpdes "
            , "   from datrsrvpbm a, datkpbm b, datkpbmgrp c "
            , "  where a.atdsrvnum    = ? "
            , "    and a.atdsrvano    = ? "  
            , "    and b.c24pbmcod    = a.c24pbmcod    "
            , "    and c.c24pbmgrpcod = b.c24pbmgrpcod "
  prepare pbdbsr042012 from l_sql            
  declare cbdbsr042012 cursor for pbdbsr042012    

  let l_sql = " select b.c24astdes "
            , "   from datmligacao a, datkassunto b "
            , "  where a.atdsrvnum = ? "
            , "    and a.atdsrvano = ? "  
            , "    and b.c24astcod = a.c24astcod "  
  prepare pbdbsr042013 from l_sql            
  declare cbdbsr042013 cursor for pbdbsr042013    

  let l_sql = " select b.socntzdes               "
            , "   from datmsrvre a, datksocntz b "
            , "  where atdsrvnum   = ?           "
            , "    and atdsrvano   = ?           "  
            , "    and b.socntzcod = a.socntzcod "
  prepare pbdbsr042014 from l_sql            
  declare cbdbsr042014 cursor for pbdbsr042014    
                    
  let l_sql = " select succod     "
            , "   from pcgksusep  "
            , "  where corsus = ? " 
  prepare pbdbsr042015 from l_sql            
  declare cbdbsr042015 cursor for pbdbsr042015    
                    
  let l_sql = " select vcllicnum "
            , "      , vclchsinc "
            , "      , vclchsfnl "
            , "      , vclanofbc "
            , "   from abbmveic  "
            , "  where succod    = ? " 
            , "    and aplnumdig = ? "
            , "    and itmnumdig = ? "
            , "  order by dctnumseq desc "
  prepare pbdbsr042016 from l_sql            
  declare cbdbsr042016 cursor for pbdbsr042016    
                 
  let l_sql = " select sucnom     "
            , "   from gabksuc    "
            , "  where succod = ? " 
  prepare pbdbsr042017 from l_sql            
  declare cbdbsr042017 cursor for pbdbsr042017   
                 
  let l_sql = " select cpodes      "
            , "   from iddkdominio "
            , "  where cponom = ?  " 
            , "    and cpocod = ?  " 
  prepare pbdbsr042018 from l_sql            
  declare cbdbsr042018 cursor for pbdbsr042018   
                 
  let l_sql = " select srvretmtvdes     "
            , "   from datksrvret       "
            , "  where srvretmtvcod = ? "
  prepare pbdbsr042019 from l_sql            
  declare cbdbsr042019 cursor for pbdbsr042019   
                 
  let l_sql = " select org.atddat          "
            , "      , org.atdhor          "
            , "      , org.srvprsacnhordat "
            , "      , org.srvprsacnhordat "
            , "      , org.atddatprg       "
            , "      , org.atdhorprg       "
            , "      , org.atdprscod       "
            , "      , org.srrcoddig       "
            , "      , srr.srrnom          "
            , "      , pst.pptnom          "
            , "      , pst.pcpatvcod       "
            , "   from datmservico org     "
            , "      , dpaksocor   pst     "
            , "      , datksrr     srr     "
            , "  where org.atdsrvnum = ?   "
            , "    and org.atdsrvano = ?   "
            , "    and pst.pstcoddig = org.atdprscod "
            , "    and srr.srrcoddig = org.srrcoddig "
  prepare pbdbsr042020 from l_sql            
  declare cbdbsr042020 cursor for pbdbsr042020    

end  function

#-------------------------------------#
 function bdbsr042_servicosAtendidos()
#-------------------------------------#

   define l_cponom like iddkdominio.cponom

   initialize mr_datmservico.*
            , mr_datrservapol.*
            , mr_datmatd6523.*
            , mr_datketapa.*
            , mr_dpaksocor.*
            , mr_datksrr.*
            , mr_datkitaclisgm.*
            , mr_datmlcl.*
            , mr_datrcidsed.*
            , mr_datkpbm.*
            , mr_datksocntz.*
            , mr_datkassunto.*
            , mr_pcgksusep.*
            , mr_abbmveic.*
	          , mr_datkasitip.*
	          , mr_datksrvtip.*
	          , mr_gabksuc.*
	          , mr_datmsrvre.*
	          , mr_datksrvret.*
	          , mr_original.*  
	          , mr_iddkdominio.* to null

   start report bdbsr042_relatorio to m_path
   start report bdbsr042_relatorio_txt to m_path_txt #--> RELTXT

   whenever error continue

   open cbdbsr042001
   foreach cbdbsr042001 into mr_datmservico.* 
			                      ,mr_datmsrvre.*

      open cbdbsr042009 using mr_datmservico.atdsrvorg
      fetch cbdbsr042009 into mr_datksrvtip.srvtipdes
      if sqlca.sqlcode <> 0 then
         initialize mr_datksrvtip.srvtipdes to null
      end if  
      close cbdbsr042009

      let l_cponom = "socvclcod"
      open cbdbsr042018 using l_cponom
			    , mr_datmservico.socvclcod
      fetch cbdbsr042018 into mr_iddkdominio.socvclcoddes
      if sqlca.sqlcode <> 0 then
         initialize mr_iddkdominio.socvclcoddes to null
      end if  
      close cbdbsr042018

      open cbdbsr042011 using mr_datmservico.asitipcod
      fetch cbdbsr042011 into mr_datkasitip.asitipdes
      if sqlca.sqlcode <> 0 then
         initialize mr_datkasitip.* to null
      end if  
      close cbdbsr042011

      open cbdbsr042019 using mr_datmsrvre.srvretmtvcod 
      fetch cbdbsr042019 into mr_datksrvret.srvretmtvdes
      if sqlca.sqlcode <> 0 then
         initialize mr_datksrvret.* to null
      end if  
      close cbdbsr042019

      open cbdbsr042003 using mr_datmservico.atdsrvnum
                            , mr_datmservico.atdsrvano
      fetch cbdbsr042003 into mr_datrservapol.*
      if sqlca.sqlcode <> 0 then
         initialize mr_datrservapol.* to null 
      end if  
      close cbdbsr042003

      open cbdbsr042017 using mr_datrservapol.succod
      fetch cbdbsr042017 into mr_gabksuc.sucnomapl
      if sqlca.sqlcode <> 0 then
         initialize mr_gabksuc.sucnomapl to null 
      end if  
      close cbdbsr042017

      open cbdbsr042004 using mr_datmservico.atdsrvnum
                            , mr_datmservico.atdsrvano
      fetch cbdbsr042004 into mr_datketapa.*
      if sqlca.sqlcode <> 0 then
         initialize mr_datketapa.* to null 
      end if  
      close cbdbsr042004

      open cbdbsr042005 using mr_datmservico.atdprscod
      fetch cbdbsr042005 into mr_dpaksocor.*
      if sqlca.sqlcode <> 0 then
         initialize mr_dpaksocor.* to null 
      end if  
      close cbdbsr042005

      let l_cponom = "pcpatvcod"
      open cbdbsr042018 using l_cponom
			    , mr_dpaksocor.pcpatvcod
      fetch cbdbsr042018 into mr_iddkdominio.pcpatvcoddes
      if sqlca.sqlcode <> 0 then
         initialize mr_iddkdominio.pcpatvcoddes to null
      end if  
      close cbdbsr042018

      let l_cponom = "qldgracod"
      open cbdbsr042018 using l_cponom
			    , mr_dpaksocor.qldgracod
      fetch cbdbsr042018 into mr_iddkdominio.qldgracoddes
      if sqlca.sqlcode <> 0 then
         initialize mr_iddkdominio.qldgracoddes to null
      end if  
      close cbdbsr042018

      open cbdbsr042010 using mr_dpaksocor.endcid
			    , mr_dpaksocor.endufd
      fetch cbdbsr042010 into mr_datrcidsed.cidsedcodpst
      if sqlca.sqlcode <> 0 then
         initialize mr_datrcidsed.cidsedcodpst to null 
      end if  
      close cbdbsr042010

      open cbdbsr042006 using mr_datmservico.srrcoddig
      fetch cbdbsr042006 into mr_datksrr.*
      if sqlca.sqlcode <> 0 then
         initialize mr_datksrr.* to null 
      end if  
      close cbdbsr042006

      open cbdbsr042008 using mr_datmservico.atdsrvnum
                            , mr_datmservico.atdsrvano
      fetch cbdbsr042008 into mr_datmlcl.*
      if sqlca.sqlcode <> 0 then
         initialize mr_datmlcl.* to null 
      end if  
      close cbdbsr042008

      open cbdbsr042010 using mr_datmlcl.cidnom
			    , mr_datmlcl.ufdcod
      fetch cbdbsr042010 into mr_datrcidsed.cidsedcodsrv
      if sqlca.sqlcode <> 0 then
         initialize mr_datrcidsed.cidsedcodsrv to null 
      end if  
      close cbdbsr042010

      open cbdbsr042012 using mr_datmservico.atdsrvnum
                            , mr_datmservico.atdsrvano
      fetch cbdbsr042012 into mr_datkpbm.*
      if sqlca.sqlcode <> 0 then
         initialize mr_datkpbm.* to null 
      end if  
      close cbdbsr042012

      open cbdbsr042013 using mr_datmservico.atdsrvnum
			    , mr_datmservico.atdsrvano
      fetch cbdbsr042013 into mr_datkassunto.*
      if sqlca.sqlcode <> 0 then
         initialize mr_datkassunto.* to null 
      end if  
      close cbdbsr042013

      open cbdbsr042014 using mr_datmservico.atdsrvnum
			    , mr_datmservico.atdsrvano
      fetch cbdbsr042014 into mr_datksocntz.*
      if sqlca.sqlcode <> 0 then
         initialize mr_datksocntz.* to null 
      end if  
      close cbdbsr042014

      open cbdbsr042015 using mr_datmservico.corsus
      fetch cbdbsr042015 into mr_pcgksusep.*
      if sqlca.sqlcode <> 0 then
         initialize mr_pcgksusep.* to null 
      end if  
      close cbdbsr042015

      open cbdbsr042017 using mr_pcgksusep.succod
      fetch cbdbsr042017 into mr_gabksuc.sucnomcor
      if sqlca.sqlcode <> 0 then
         initialize mr_gabksuc.sucnomcor to null 
      end if  
      close cbdbsr042017

      open cbdbsr042016 using mr_datrservapol.succod
			    , mr_datrservapol.aplnumdig
			    , mr_datrservapol.itmnumdig
      fetch cbdbsr042016 into mr_abbmveic.*
      if sqlca.sqlcode <> 0 then
         initialize mr_abbmveic.* to null 
      end if  
      close cbdbsr042016

      open cbdbsr042020 using mr_datmsrvre.atdorgsrvnum
			    , mr_datmsrvre.atdorgsrvano
      fetch cbdbsr042020 into mr_original.*
      if sqlca.sqlcode <> 0 then
         initialize mr_original.* to null 
      end if  
      close cbdbsr042020

      let l_cponom = "pcpatvcod"
      open cbdbsr042018 using l_cponom
			    , mr_original.pcpatvcod
      fetch cbdbsr042018 into mr_iddkdominio.pcpatvcoddesorg
      if sqlca.sqlcode <> 0 then
         initialize mr_iddkdominio.pcpatvcoddesorg to null
      end if  
      close cbdbsr042018

      output to report bdbsr042_relatorio() 
      output to report bdbsr042_relatorio_txt() #--> RELTXT
                       
      initialize mr_datmservico.*
               , mr_datrservapol.*
               , mr_datmatd6523.*
               , mr_datketapa.*
               , mr_dpaksocor.*
               , mr_datksrr.*
               , mr_datkitaclisgm.*
               , mr_datmlcl.*
               , mr_datrcidsed.*
               , mr_datkpbm.*
               , mr_datksocntz.*
               , mr_datkassunto.*
               , mr_pcgksusep.*
               , mr_abbmveic.*
	       , mr_datkasitip.*
	       , mr_datksrvtip.*
	       , mr_gabksuc.* 
	       , mr_datmsrvre.*
	       , mr_datksrvret.*
	       , mr_original.*  
	       , mr_iddkdominio.* to null
    
   end foreach

   whenever error stop

   finish report bdbsr042_relatorio       
   finish report bdbsr042_relatorio_txt #--> RELTXT       
                                          
 end function                             

#-------------------------------#
 function bdbsr042_envia_email()
#-------------------------------#

   define l_assunto     char(100),
          l_comando     char(200),
          l_anexo       char(200),
          l_erro_envio  integer

   # ---> INICIALIZACAO DAS VARIAVEIS
   let l_comando    = null
   let l_erro_envio = null
   let l_assunto    = "Relatorio Servicos Atendidos - ", m_data, " - BDBSR042"

   # Colocamos o whenever para que o programa nao aborte quando ocorrer erro no envio de email
   # pois a nova funcao nao retorna o erro, ela aborta o programa
   whenever error continue
    
   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path
   run l_comando
   let m_path = m_path clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("bdbsr042", l_assunto, m_path)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path clipped
       else
           display "Nao existe email cadastrado para o modulo - BDBSR042"
       end if
   end if

   whenever error stop

end function

#---------------------------#
 report bdbsr042_relatorio()
#---------------------------#

  output

  left   margin 00
  right  margin 00
  top    margin 00
  bottom margin 00
  page   length 02

  format

  first page header

  print "Numero do Servico"                        , ASCII(09) , 
        "Ano do Servico"		                       , ASCII(09) ,
        "Etapa"			                               , ASCII(09) ,
        "Data da Abertura do Servico"              , ASCII(09) ,
        "Hora da Abertura do Servico"	             , ASCII(09) ,
        "Data do Acionamento do Servico"           , ASCII(09) ,
        "Hora do Acionamento do Servico"           , ASCII(09) ,
        "Data da Programacao do Servico"           , ASCII(09) ,
        "Hora da Programacao do Servico"           , ASCII(09) ,
        "Origem"		                               , ASCII(09) ,
        "Empresa"		                               , ASCII(09) ,
        "Cod.Prestador"		                         , ASCII(09) ,
        "Prestador"                                , ASCII(09) ,
        "Atividade Principal"                      , ASCII(09) ,
        "Cod.Socorrista"	                         , ASCII(09) ,
        "Socorrista"		                           , ASCII(09) ,
        "Sucursal Documento"	                     , ASCII(09) ,
	      "Data do Servico"                          , ASCII(09) ,
        "Cidade Servico"	                         , ASCII(09) ,
        "UF Servico"		                           , ASCII(09) ,
        "Cidade Sede Servico"	                     , ASCII(09) ,
        "Cidade do Prestador"	                     , ASCII(09) ,
        "UF Prestador"		                         , ASCII(09) ,
        "Cidade Sede Prestador"	                   , ASCII(09) ,
        "Sigla"			                               , ASCII(09) ,
        "Tipo Veiculo"                             , ASCII(09) ,
        "Problema"  		                           , ASCII(09) ,
        "Assistencia"		 	                         , ASCII(09) ,
        "Natureza"  		 	                         , ASCII(09) ,
        "Padrao de Qualidade"                      , ASCII(09) ,
        "Assunto"			                             , ASCII(09) ,
        "Grupo de Assunto"	 	                     , ASCII(09) ,
        "Ramo"				                             , ASCII(09) ,
        "Apolice"			                             , ASCII(09) ,
        "Item"				                             , ASCII(09) ,
        "Sucursal Corretor"		                     , ASCII(09) ,
        "Segurado"  			                         , ASCII(09) ,
        "Corretor"  		 	                         , ASCII(09) ,
        "SUSEP"                                    , ASCII(09) ,
        "Motivo do Retorno"                        , ASCII(09) ,
        "Solicitou a mesma base ? (SIM/NAO)"       , ASCII(09) ,
        "Servico Original"                         , ASCII(09) ,
        "Ano do Servico Original"                  , ASCII(09) ,
        "Data Abertura Servico Original"           , ASCII(09) ,
        "Hora Abertura Servico Original"           , ASCII(09) ,
        "Data Acionamento Servico Original"        , ASCII(09) ,
        "Hora Acionamento Servico Original"        , ASCII(09) ,
        "Data Programacao Servico Original"        , ASCII(09) ,
        "Hora Programacao Servico Original"        , ASCII(09) ,
        "Cod. Socorrista Servico Original"         , ASCII(09) ,
        "Nome Socorrista Servico Original"         , ASCII(09) ,
        "Cod.Prestador Servico Original"           , ASCII(09) ,
        "Nome Prestador Servico Original"          , ASCII(09) ,
        "Atividade Principal Servico Original"     , ASCII(09) 
                                                   
  on every row                                     
                                                   
  print mr_datmservico.atdsrvnum                   , ASCII(09) ,
        mr_datmservico.atdsrvano                   , ASCII(09) ,
        mr_datketapa.atdetpdes                     , ASCII(09) ,
        mr_datmservico.atddat                      , ASCII(09) ,
        mr_datmservico.atdhor                      , ASCII(09) ,
        mr_datmservico.srvprsacndat                , ASCII(09) ,
        mr_datmservico.srvprsacnhor                , ASCII(09) ,
        mr_datmservico.atddatprg                   , ASCII(09) ,
        mr_datmservico.atdhorprg                   , ASCII(09) ,
        mr_datksrvtip.srvtipdes                    , ASCII(09) ,
        mr_datmservico.ciaempcod                   , ASCII(09) ,
        mr_datmservico.atdprscod                   , ASCII(09) ,
        mr_dpaksocor.pptnom                        , ASCII(09) ,
        mr_iddkdominio.pcpatvcoddes                , ASCII(09) ,
        mr_datmservico.srrcoddig	                 , ASCII(09) ,
        mr_datksrr.srrnom                          , ASCII(09) ,
        mr_gabksuc.sucnomapl  		                 , ASCII(09) ,
        mr_datmservico.atddat                      , ASCII(09) ,
        mr_datmlcl.cidnom                          , ASCII(09) ,
        mr_datmlcl.ufdcod                          , ASCII(09) ,
        mr_datrcidsed.cidsedcodsrv                 , ASCII(09) ,
        mr_dpaksocor.endcid                        , ASCII(09) ,
        mr_dpaksocor.endufd                        , ASCII(09) ,
        mr_datrcidsed.cidsedcodpst                 , ASCII(09) ,
        mr_datmservico.atdvclsgl                   , ASCII(09) ,
        mr_iddkdominio.socvclcoddes                , ASCII(09) ,
        mr_datkpbm.c24pbmdes                       , ASCII(09) ,
        mr_datkasitip.asitipdes                    , ASCII(09) ,
        mr_datksocntz.socntzdes                    , ASCII(09) ,
	      mr_iddkdominio.qldgracoddes                , ASCII(09) ,
        mr_datkassunto.c24astdes                   , ASCII(09) ,
        mr_datkpbm.c24pbmgrpdes                    , ASCII(09) ,
        mr_datrservapol.ramcod                     , ASCII(09) ,
        mr_datrservapol.aplnumdig                  , ASCII(09) ,
        mr_datrservapol.itmnumdig                  , ASCII(09) ,
        mr_gabksuc.sucnomcor                       , ASCII(09) ,
        mr_datmservico.nom                         , ASCII(09) ,
        mr_datmservico.cornom                      , ASCII(09) ,
        mr_datmservico.corsus                      , ASCII(09) ,
        mr_datksrvret.srvretmtvdes                 , ASCII(09) ,
        mr_datmsrvre.retprsmsmflg                  , ASCII(09) ,
        mr_datmsrvre.atdorgsrvnum                  , ASCII(09) ,
        mr_datmsrvre.atdorgsrvano                  , ASCII(09) ,
        mr_original.atddat                         , ASCII(09) ,
        mr_original.atdhor                         , ASCII(09) ,
        mr_original.srvprsacndat                   , ASCII(09) ,
        mr_original.srvprsacnhor                   , ASCII(09) ,
        mr_original.atddatprg                      , ASCII(09) ,
        mr_original.atdhorprg                      , ASCII(09) ,
        mr_original.srrcoddig		                   , ASCII(09) ,
        mr_original.srrnom                         , ASCII(09) ,
        mr_original.atdprscod                      , ASCII(09) ,
        mr_original.pptnom                         , ASCII(09) ,
        mr_iddkdominio.pcpatvcoddesorg             , ASCII(09) 
  
 end report

#--------------------------------#
 report bdbsr042_relatorio_txt() #--> RELTXT
#--------------------------------#

  output

  left   margin 00
  right  margin 00
  top    margin 00
  bottom margin 00
  page   length 01

  format

  on every row

  print mr_datmservico.atdsrvnum               , ASCII(09) ,
        mr_datmservico.atdsrvano               , ASCII(09) ,
        mr_datketapa.atdetpdes                 , ASCII(09) ,
        mr_datmservico.atddat                  , ASCII(09) ,
        mr_datmservico.atdhor                  , ASCII(09) ,
        mr_datmservico.srvprsacndat            , ASCII(09) ,
        mr_datmservico.srvprsacnhor            , ASCII(09) ,
        mr_datmservico.atddatprg               , ASCII(09) ,
        mr_datmservico.atdhorprg               , ASCII(09) ,
        mr_datksrvtip.srvtipdes                , ASCII(09) ,
        mr_datmservico.ciaempcod               , ASCII(09) ,
        mr_datmservico.atdprscod               , ASCII(09) ,
        mr_dpaksocor.pptnom                    , ASCII(09) ,
        mr_iddkdominio.pcpatvcoddes            , ASCII(09) ,
        mr_datmservico.srrcoddig	             , ASCII(09) ,
        mr_datksrr.srrnom                      , ASCII(09) ,
        mr_gabksuc.sucnomapl  		             , ASCII(09) ,
        mr_datmservico.atddat                  , ASCII(09) ,
        mr_datmlcl.cidnom                      , ASCII(09) ,
        mr_datmlcl.ufdcod                      , ASCII(09) ,
        mr_datrcidsed.cidsedcodsrv             , ASCII(09) ,
        mr_dpaksocor.endcid                    , ASCII(09) ,
        mr_dpaksocor.endufd                    , ASCII(09) ,
        mr_datrcidsed.cidsedcodpst             , ASCII(09) ,
        mr_datmservico.atdvclsgl               , ASCII(09) ,
        mr_iddkdominio.socvclcoddes            , ASCII(09) ,
        mr_datkpbm.c24pbmdes                   , ASCII(09) ,
        mr_datkasitip.asitipdes                , ASCII(09) ,
        mr_datksocntz.socntzdes                , ASCII(09) ,
	      mr_iddkdominio.qldgracoddes            , ASCII(09) ,
        mr_datkassunto.c24astdes               , ASCII(09) ,
        mr_datkpbm.c24pbmgrpdes                , ASCII(09) ,
        mr_datrservapol.ramcod                 , ASCII(09) ,
        mr_datrservapol.aplnumdig              , ASCII(09) ,
        mr_datrservapol.itmnumdig              , ASCII(09) ,
        mr_gabksuc.sucnomcor                   , ASCII(09) ,
        mr_datmservico.nom                     , ASCII(09) ,
        mr_datmservico.cornom                  , ASCII(09) ,
        mr_datmservico.corsus                  , ASCII(09) ,
        mr_datksrvret.srvretmtvdes             , ASCII(09) ,
        mr_datmsrvre.retprsmsmflg              , ASCII(09) ,
        mr_datmsrvre.atdorgsrvnum              , ASCII(09) ,
        mr_datmsrvre.atdorgsrvano              , ASCII(09) ,
        mr_original.atddat                     , ASCII(09) ,
        mr_original.atdhor                     , ASCII(09) ,
        mr_original.srvprsacndat               , ASCII(09) ,
        mr_original.srvprsacnhor               , ASCII(09) ,
        mr_original.atddatprg                  , ASCII(09) ,
        mr_original.atdhorprg                  , ASCII(09) ,
        mr_original.srrcoddig		               , ASCII(09) ,
        mr_original.srrnom                     , ASCII(09) ,
        mr_original.atdprscod                  , ASCII(09) ,
        mr_original.pptnom                     , ASCII(09) ,
        mr_iddkdominio.pcpatvcoddesorg 
  
 end report
