#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CENTRAL 24 HS                                              #
# Modulo        : bdatm001                                                   #
# Analista Resp.: Ruiz                                                       #
# PSI           : 209392                                                     #
#                 Interface para o sistema AverbTransWeb                     #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 08/01/2009 Amilton, Meta     PSI234788  Incluir servicos para registro de  #
#                                         cancelamento e reclamacao pelo     #
#                                         Portal CSU                         #
# 13/08/2009 Sergio Burini     PSI244236  Inclusão do Sub-Dairro             #
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/dssqa/producao/I4GLParams.4gl'
globals '/homedsa/projetos/geral/globals/glct.4gl'

define m_prep_sql    smallint

define m_erro record 
       servico char(300),
       coderro smallint, 
       mens    char(4000)
end record

define m_servico    char(100)

 define param_xml     record
        succod        like datrligapol.succod     ,
        ramcod        like datrservapol.ramcod    ,
        aplnumdig     like datrligapol.aplnumdig  ,
        itmnumdig     like abbmdoc.itmnumdig      ,
        edsnumdig     like abamdoc.edsnumdig      ,
        rmemdlcod     like rsamseguro.rmemdlcod   ,
        grp_natz      char(12)                    ,
        c24astcod     like datmligacao.c24astcod  ,
        cidnom        like glakcid.cidnom         ,
        ufdcod        like glakcid.ufdcod         ,
        socntzcod     like datksocntz.socntzcod   ,
        rgldat        like datmsrvrgl.rgldat      ,
        rglhor        char(5)                     ,
        socntzdes     like datksocntz.socntzdes   ,
        atdsrvnum     like datmservico.atdsrvnum  ,
        atdsrvano     like datmservico.atdsrvano  ,
        atdfnlflg     like datmservico.atdfnlflg  ,
        logtip        char(10)                    ,
        lognom        char(50)                    ,
        lognum        integer                     ,
        bairro        char(50)                    ,
        operacao      char (01)                   ,
        endzon        like datmlcl.endzon         ,
        lgdcep        like datmlcl.lgdcep         ,
        lgdcepcmp     like datmlcl.lgdcepcmp      ,
        dddcod        like datmlcl.dddcod         ,
        lcltelnum     like datmlcl.lcltelnum      ,
        lclcttnom     like datmlcl.lclcttnom      ,
        lclrefptotxt  like datmlcl.lclrefptotxt   ,
        data          date                        ,
        hora          datetime hour to minute     ,
        acao          char (03)                   ,
        srvretmtvcod  like datksrvret.srvretmtvcod,
        srvretmtvdes  like datksrvret.srvretmtvdes,
        retprsmsmflg  like datmsrvre.retprsmsmflg ,
        orrdat        like datmsrvre.orrdat       ,
        srvrglcod     like datmsrvrgl.srvrglcod   ,
        retorno       char(11)                    ,
        msmprest      char(03),
        filtro        smallint,
        placa         like abbmveic.vcllicnum ,
        cpf           char(15),
        cgccpfnum     like gsakpes.cgccpfnum,
        cgcord        like gsakpes.cgcord   ,
        cgccpfdig     like gsakpes.cgccpfdig,        
        pestip        char(1),
        tp_retorno    char(20)
 end record
 
 define param_xml_multiplos array[10] of record
        socntzcod      like datmsrvre.socntzcod
       ,espcod         like datmsrvre.espcod
       ,c24pbmgrpcod   like datkpbmgrp.c24pbmgrpcod
 end record

 define lr_aux        record
        lignum        like datmligacao.lignum
       ,c24astcod     like datmligacao.c24astcod
 end record


# Psi234788 inicio
#---------------------------
function bdatm001_prepare()
#---------------------------
 define l_sql     char(500)

   let l_sql = " select c24astdes ",
             " from datkassunto ",
             " where c24astcod = ? "
             
   prepare pbdatm001001 from l_sql
   declare cbdatm001001 cursor for pbdatm001001
      
   let l_sql =  " select lignum "
                ," from datrligcgccpf  "
                ," where cgccpfnum = ? "
                ," and cgcord = ? "
                ," and cgccpfdig = ? "
                              
   prepare pbdatm001002 from l_sql 
   declare cbdatm001002 cursor for pbdatm001002
                                   
             
   let l_sql = " select a.lignum , a.c24astcod " 
               ," , a.ligdat , a.lighorinc "
               ," , a.atdsrvnum , a.atdsrvano "
               ," from datmligacao a, datkassunto b "
               ," where a.c24astcod = b.c24astcod " 
               ," and a.lignum = ? " 
               ," and a.ciaempcod = 40  "
               ," and (b.c24astagp = 'O' or a.c24astcod = 'RET') " 
                          
                                       
             
   prepare pbdatm001003 from l_sql
   declare cbdatm001003 cursor for pbdatm001003
   
   let l_sql = " select atdnum"
             , " from datratdlig  "
             , " where lignum = ? "             
             
   prepare pbdatm001004 from l_sql
   declare cbdatm001004 cursor for pbdatm001004
   
   let l_sql = "select a.socntzcod , b.socntzdes,      "
               ,"       a.atdsrvnum,a.atdsrvano         "
               ,"  from datmsrvre a, datksocntz b       "
               ,"  where a.socntzcod = b.socntzcod and  "               
               ,"        a.atdsrvnum = ? and      "
               ,"        a.atdsrvano = ?                "
                                   
   prepare pbdatm001005 from l_sql
   declare cbdatm001005 cursor for pbdatm001005
   
   let l_sql = " select b.atdetpcod,b.atdetpdes " 
              ," from datmservico a,datketapa b "
              ," where a.atdetpcod = b.atdetpcod "
              ," and a.atdsrvnum = ? "
              ," and a.atdsrvano = ? "          
             
   prepare pbdatm001006 from l_sql
   declare cbdatm001006 cursor for pbdatm001006
   
   let l_sql = " select a.lignum , a.c24astcod  "
             , "  , a.ligdat , a.lighorinc, a.c24solnom   "
             , "  , a.atdsrvnum , a.atdsrvano,a.c24funmat "  
             , " from datmligacao a, datkassunto b "
             , " where a.c24astcod = b.c24astcod "
             , " and a.lignum = ? "
             , " and a.ciaempcod = 40 "
             , " and b.c24astagp = 'O' "             
             
             
   prepare pbdatm001007 from l_sql
   declare cbdatm001007 cursor for pbdatm001007
   
   let l_sql = " select b.rcuccsmtvdes "
              ," from datrligrcuccsmtv a,datkrcuccsmtv b " 
              ," where a.rcuccsmtvcod = b.rcuccsmtvcod and "                                
              ," b.c24astcod = 'O00' and "                                            
              ," a.lignum = ? "                                                
             
   prepare pbdatm001008 from l_sql
   declare cbdatm001008 cursor for pbdatm001008
   
   let l_sql = 'select lignum,c24txtseq,c24ligdsc ',
             '  from datmlighist ',
             ' where lignum = ? '

   prepare pbdatm001009 from l_sql
   declare cbdatm001009 cursor for pbdatm001009
   
   
   let l_sql = " select a.lignum , a.c24astcod  "
             , "  , a.ligdat , a.lighorinc, a.c24solnom   "
             , "  , a.c24funmat "  
             , " from datmligacao a, datkassunto b "
             , " where a.c24astcod = b.c24astcod "
             , " and atdsrvnum = ? "
             , " and atdsrvano = ? "
             , " and ciaempcod = 40 "
             , " and b.c24astagp = 'O' "            
             
             
   prepare pbdatm001010 from l_sql
   declare cbdatm001010 cursor for pbdatm001010
   
   let l_sql = " select lclrsccod ,"                  
             , " socntzcod , orrdat , "                              
             , " atdorgsrvnum,atdorgsrvano, "                      
             , " espcod, srvretmtvcod "                            
             , " from datmsrvre  "                                 
             , " where atdsrvnum = ? "                             
             , " and atdsrvano = ? "                               
             
   prepare pbdatm001011 from l_sql
   declare cbdatm001011 cursor for pbdatm001011
   
   let l_sql = " select socntzdes "
              ," from datksocntz "
              ," where socntzcod = ? "
              
   prepare pbdatm001012 from l_sql                           
   declare cbdatm001012 cursor for pbdatm001012
              
   
   let l_sql = " select espdes "            
              ," from dbskesp "             
              ," where espcod = ? "         
                                               
   prepare pbdatm001013 from l_sql             
   declare cbdatm001013 cursor for pbdatm001013
   
   
   let l_sql = " select srvretmtvdes "            
              ," from datksrvret "             
              ," where srvretmtvcod = ? "         
                                               
   prepare pbdatm001014 from l_sql             
   declare cbdatm001014 cursor for pbdatm001014
   
   let l_sql = " select asitipabvdes "            
              ," from datkasitip "             
              ," where asitipcod = ? "         
                                               
   prepare pbdatm001015 from l_sql             
   declare cbdatm001015 cursor for pbdatm001015
                                                  
                                                  
   let l_sql = " select asitipcod,atdprinvlcod, "
              ," atdlibflg,prslocflg,atdhorpvt, "
              ," atddatprg,atdpvtretflg, "
              ," atdhorprg "
              ," from datmservico "                   
              ," where atdsrvnum = ? "               
              ," and   atdsrvano = ? "  
                                                     
   prepare pbdatm001016 from l_sql                   
   declare cbdatm001016 cursor for pbdatm001016
   
   let l_sql = " select a.c24pbmcod, b.c24pbmdes " 
              ," from datrsrvpbm a,datkpbm b "
              ," where a.c24pbmcod = b.c24pbmcod "
              ," and a.atdsrvnum = ? "
              ," and a.atdsrvano = ? "
               
                                                     
   prepare pbdatm001017 from l_sql                   
   declare cbdatm001017 cursor for pbdatm001017
   

   let l_sql = " select cpodes "
              ," from iddkdominio "
              ," where cponom = 'atdprinvlcod' "
              ," and cpocod = ? "
              
   prepare pbdatm001018 from l_sql                   
   declare cbdatm001018 cursor for pbdatm001018  
   
   
   let l_sql = "select c24srvdsc "
              ," from datmservhist " 
              ," where atdsrvnum = ? "
              ," and atdsrvano = ? "
              ," order by  c24txtseq "
              
   prepare pbdatm001019 from l_sql                   
   declare cbdatm001019 cursor for pbdatm001019
   

   let l_sql = " select  cnldat,atdsrvorg, "                       
              ," socvclcod,atdprscod,"
              ," c24nomctt,srrcoddig "
              ," from datmservico    "                  
              ," where atdsrvnum = ? "
              ," and atdsrvano = ?   "

   prepare pbdatm001022 from l_sql                   
   declare cbdatm001022 cursor for pbdatm001022
   
   
    let l_sql = "select cnslignum     ",      
                 "  from datrligcnslig ",      
                 " where lignum = ?    "                     
   prepare pbdatm001024 from l_sql                   
   declare cbdatm001024 cursor for pbdatm001024
   
   let l_sql = " select a.lignum , a.c24astcod  "
             , "  , a.ligdat , a.lighorinc, a.c24solnom   "
             , "  , a.c24funmat "  
             , " from datmligacao a, datkassunto b "
             , " where a.c24astcod = b.c24astcod "
             , " and atdsrvnum = ? "
             , " and atdsrvano = ? "
             , " and ciaempcod = 40 "             
             
             
   prepare pbdatm001025 from l_sql
   declare cbdatm001025 cursor for pbdatm001025
   
   
   
  let m_prep_sql = true

end function
# Psi234788 Fim

#----------------------------------
function executeService(l_servico)
#----------------------------------
 define l_servico       char(50)
       ,l_retorno       char(5000)

 define lr_param        record
        lignum          like datmreclam.lignum,
        c24astcod       like datkevt.c24astcod,
        atdsrvnum       like datmservico.atdsrvnum,
        atdsrvano       like datmservico.atdsrvano,
        funmat          like isskfunc.funmat,
        empcod          like isskfunc.empcod,
        situacao        smallint
 end record

 define l_msgerro varchar(80)
 
 define l_ret_lig record
        erro      smallint,
        msgerro   varchar(80),
        lignum    like datmligacao.lignum
        end record

 define l_ret_tab record
        sqlcode         integer,
        tabname         like systables.tabname
 end record


 # Psi234788 
 if m_prep_sql is null or
    m_prep_sql <> true then
    call bdatm001_prepare()
 end if



 ## PSI191965
 initialize lr_param.*  to null
 let l_retorno = null
 
 display "**** <bdatm001> Servico - l_servico = ", l_servico
 let m_servico = l_servico
 case l_servico
      when "REGISTRALIGACAOCENTRALAVERBTRANSWEB"
           let l_retorno =  bdatm001_RegistraLigacaoAverbTransWeb()
      
      when "LIGACAOCARTAO"                              # Psi234788            
           let l_retorno =  bdatm001_lista_lig_cartao()           
      
      when "SERVICOCARTAO"                              # Psi234788            
           let l_retorno =  bdatm001_lista_srv_cartao()           
      
      when "DETALHESLIGACAO"                            # Psi234788   
           let l_retorno =  bdatm001_rec_lig_cartao()       
           
      when "DETALHESERVICO"                             # Psi234788  
           let l_retorno =  bdatm001_rec_srv_cartao()  
           
      when "CANCELAR_SERVICO"                           # Psi234788 
           let l_retorno =  bdatm001_can_srv()   
           
      when "REGISTRARECLAMACAO"                         # Psi234788 
           let l_retorno =  bdatm001_reg_lig_rcl()  
      
      when "MOTIVOSRECLAMACAO"                          # Psi234788  
             let l_retorno =  bdatm001_motivos_rcl()   
      when "GravaHistorico"                             # Psi234788  
             let l_retorno =  bdatm001_grava_historico()        
      when "IDENTIFICA_CLIENTE"
             display "399 - chama a bdatm001 - "
             call bdatm001_identifica_cliente()
             returning l_retorno             
             display "402 l_retorno = ",l_retorno clipped
     when "REGISTRAR_RETORNO_SERVICO"        
          
          display "400 l_retorno = ",l_retorno clipped       
          call bdatm001_registra_retorno()
             returning l_retorno
             
             display "408 l_retorno = ",l_retorno clipped       
     
     when "LISTAR_AGENDA_DISPONIVEL"
         
         call bdatm001_lista_agenda()         
            returning l_retorno
         
         display "415 l_retorno = ",l_retorno clipped                   
                                                                                    
      otherwise
           let l_msgerro = "Erro na chamada do servico - ", l_servico clipped
           return bdatm001_montaxmlerro(l_msgerro) 
 end case

 return l_retorno

end function

#-------------------------------------------------
function bdatm001_RegistraLigacaoAverbTransWeb()
#-------------------------------------------------
  
  define param         record
         ligdat        like datmligacao.ligdat      , 
         lighorinc     like datmligacao.lighorinc   , 
         lighorfnl     like datmligacao.lighorfnl   , 
         c24soltipcod  like datksoltip.c24soltipcod , 
         c24solnom     like datmligacao.c24solnom   ,
         c24funmat     like datmligacao.c24funmat   , 
         empcod        like isskfunc.empcod         ,
         usrtip        like isskfunc.usrtip         , 
         ligcvntip     like datmligacao.ligcvntip   , 
         c24paxnum     like datmligacao.c24paxnum   , 
         succod        like datrligapol.succod      , 
         ramcod        like datrligapol.ramcod      , 
         aplnumdig     like datrligapol.aplnumdig   ,
         protocolo     dec(10,0)                    , 
         c24astcod     like datmligacao.c24astcod   
  end record
  
  define l_data      date,
         l_hora      datetime hour to minute
  
  define l_retorno   record
         msgerro     char(1000)                ,
         lignum      like datmligacao.lignum   ,
         atdsrvnum   like datmservico.atdsrvnum,
         atdsrvano   like datmservico.atdsrvano,
         sqlcode     integer                   ,                   
         msg         varchar(80)               ,
         tabname     like systables.tabname
  end record              
  
  initialize param.*     to null
  initialize l_retorno.* to null
   
  let param.ligdat       = g_paramval[ 1]
  let param.lighorinc    = g_paramval[ 2]
  let param.lighorfnl    = g_paramval[ 3]
  let param.c24soltipcod = g_paramval[ 4]
  let param.c24solnom    = g_paramval[ 5]
  let param.c24funmat    = g_paramval[ 6] 
  let param.empcod       = g_paramval[ 7]
  let param.usrtip       = g_paramval[ 8]
  let param.ligcvntip    = g_paramval[ 9] 
  let param.c24paxnum    = g_paramval[10] 
  let param.succod       = g_paramval[11]
  let param.ramcod       = g_paramval[12]
  let param.aplnumdig    = g_paramval[13]
  let param.protocolo    = g_paramval[14]
  let param.c24astcod    = g_paramval[15]

  call bdatm001_validaparametros(param.*)
       returning param.*,
                 l_retorno.msgerro
       
  if l_retorno.msgerro is not null and
     l_retorno.msgerro <> "  "     then
     return bdatm001_montaxmlerro(l_retorno.msgerro)
  end if
  
  ## INICIALIZAR GLOBAIS PARA REGISTRAR LIGAÇÃO
  let g_documento.funmatatd = null
  let g_documento.corsus    = null
  let g_documento.dddcod    = null
  let g_documento.ctttel    = null
  let g_documento.funmat    = null
  let g_documento.cgccpfnum = null
  let g_issk.empcod         = param.empcod
  let g_issk.usrtip         = param.usrtip
  let g_issk.funmat         = param.c24funmat
  
  ## Gera Nº Ligação
  begin work
  call cts10g03_numeracao(1, "" )
       returning l_retorno.lignum    ,
                 l_retorno.atdsrvnum ,
                 l_retorno.atdsrvano ,
                 l_retorno.msgerro
  
  if l_retorno.msgerro <> 0 then
     rollback work 
     return bdatm001_montaxmlerro(l_retorno.msgerro)
  else
    commit work
  end if
   
  begin work
  call cts10g00_ligacao( l_retorno.lignum   ,
                         param.ligdat       ,
                         param.lighorinc    ,
                         param.c24soltipcod ,
                         param.c24solnom    ,
                         param.c24astcod    ,
                         param.c24funmat       ,
                         param.ligcvntip    ,
                         param.c24paxnum    ,
                         ""                 , #atdsrvnum 
                         ""                 , #atdsrvano 
                         ""                 , #sinvstnum 
                         ""                 , #sinvstano 
                         ""                 , #sinavsnum 
                         ""                 , #sinavsano 
                         param.succod       ,
                         param.ramcod       ,
                         param.aplnumdig    ,
                         0                  , #itmnumdig    
                         ""                 , #edsnumref    
                         ""                 , #prporg       
                         ""                 , #prpnumdig    
                         ""                 , #fcapacorg    
                         ""                 , #fcapacnum    
                         ""                 , #sinramcod    
                         ""                 , #sinano       
                         ""                 , #sinnum       
                         ""                 , #sinitmseq    
                         ""                 , #caddat       
                         ""                 , #cadhor       
                         ""                 , #cademp       
                         ""                 ) #cadmat
  returning l_retorno.tabname,
            l_retorno.sqlcode
  
    
  if l_retorno.sqlcode <> 0 then
     let l_retorno.msgerro = l_retorno.msgerro clipped , 
                             l_retorno.sqlcode clipped using '<<<<' clipped, 
                             "-Gravacao na Tabela " ,l_retorno.tabname
     rollback work 
     return bdatm001_montaxmlerro(l_retorno.msgerro)                             
  else   
     if param.lighorfnl is not null then
        update datmligacao
           set lighorfnl = param.lighorfnl
         where lignum    = l_retorno.lignum   
     end if
    commit work 
  end if
  
  if l_retorno.msgerro is null then
     insert into datrligtrpavb                             
              (lignum, trpavbnum)                           
       values (l_retorno.lignum, param.protocolo)                   
     if sqlca.sqlcode <> 0 then                            
        let l_retorno.msgerro = l_retorno.msgerro clipped ,                    
                                sqlca.sqlcode clipped using '<<<<' clipped,
                                "-Gravacao na Tabela - datrligtrpavb"     
     end if                                                
  end if   
     
  return bdatm001_montaxmlerro(l_retorno.msgerro)

end function

#------------------------------------------------------------------------------
function bdatm001_validaparametros(param)
#------------------------------------------------------------------------------
   define param         record                         
          ligdat        like datmligacao.ligdat     , 
          lighorinc     like datmligacao.lighorinc  , 
          lighorfnl     like datmligacao.lighorfnl  , 
          c24soltipcod  like datksoltip.c24soltipcod, 
          c24solnom     like datmligacao.c24solnom  , 
          c24funmat     like datmligacao.c24funmat  , 
          empcod        like isskfunc.empcod        , 
          usrtip        like isskfunc.usrtip        , 
          ligcvntip     like datmligacao.ligcvntip  , 
          c24paxnum     like datmligacao.c24paxnum  , 
          succod        like datrligapol.succod     , 
          ramcod        like datrligapol.ramcod     , 
          aplnumdig     like datrligapol.aplnumdig  , 
          protocolo     dec(10,0)                   , 
          c24astcod     like datmligacao.c24astcod     
   end record                                          
   define lr_retorno    record
          ligdat        like datmligacao.ligdat     ,
          lighorinc     like datmligacao.lighorinc  ,
          lighorfnl     like datmligacao.lighorfnl  ,
          c24soltipcod  like datksoltip.c24soltipcod,
          c24solnom     like datmligacao.c24solnom  ,
          c24funmat     like datmligacao.c24funmat  ,
          empcod        like isskfunc.empcod        ,
          usrtip        like isskfunc.usrtip        ,
          ligcvntip     like datmligacao.ligcvntip  ,
          c24paxnum     like datmligacao.c24paxnum  ,
          succod        like datrligapol.succod     ,
          ramcod        like datrligapol.ramcod     ,
          aplnumdig     like datrligapol.aplnumdig  ,
          protocolo     dec(10,0)                   ,
          c24astcod     like datmligacao.c24astcod   
   end record       
   define l_retorno     record
          msgerro       char(500)
   end record
   let l_retorno.msgerro = null
   
   if param.ligdat is null then
      let param.ligdat = today
   end if
   if param.lighorinc is null then
      let param.lighorinc = current
   end if
   if param.lighorfnl is null then
      let param.lighorfnl = current
   end if
   let lr_retorno.*   =   param.*
   
   return  lr_retorno.*,
           l_retorno.msgerro
end function

#-----------------------------------------------------------------------------
function bdatm001_montaxmlerro(param)
#-----------------------------------------------------------------------------
  define param   record
         msgerro char (1000)
  end record
   
  define l_xml   char(5000)
  define l_erro  dec(1,0)
  
  let l_xml  = null
  let l_erro = null
  
  let l_erro = 0
  if param.msgerro is not null then
     let l_erro = 1
  end if
   
  let l_xml =
   "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><IFX>",
   "<codigoErro>"   clipped ,l_erro        clipped using '<<<<',"</codigoErro>" ,
   "<mensagemErro>" clipped ,param.msgerro clipped,"</mensagemErro>","</IFX>"
 
  return l_xml
  
end function


# Psi234788 inicio

#-------------------------------------------------------
function bdatm001_lista_lig_cartao()
#-------------------------------------------------------

  define lr_param record 
     cgccpfnum   like datrligcgccpf.cgccpfnum,
     cgcord      like datrligcgccpf.cgcord,
     cgccpfdig   like datrligcgccpf.cgccpfdig
  end record 
  
  define l_lignum like datmligacao.lignum,
         l_exist  smallint,
         l_erro   integer,
         l_atdnum like datmatd6523.atdnum,         
         l_sql         char(800),                 
         l_c24astdes   like datkassunto.c24astdes,
         l_msg         char(500),                 
         l_xml         char(32766),
         l_qtd         integer                    
         
  define lr_lig record
         lignum    like datmligacao.lignum,
         c24astcod like datmligacao.c24astcod,         
         ligdat    like datmligacao.ligdat,
         lighorinc like datmligacao.lighorinc,
         c24solnom like datmligacao.c24solnom,         
         cnslignum like datrligcnslig.cnslignum
  end record 
  
  define lr_ret record
         atdnum     like datmatd6523.atdnum, 
         lignum     like datmligacao.lignum,
         c24astcod  like datmligacao.c24astcod,    
         c24astdes  like datkassunto.c24astdes,              
         ligdat     like datmligacao.ligdat,
         lighorinc  like datmligacao.lighorinc,
         c24solnom  like datmligacao.c24solnom,
         cnslignum  like datrligcnslig.cnslignum
  end record   
      
  initialize lr_lig.* to null
  let l_lignum    = null 
  let l_atdnum    = null 
  let l_erro      = null
  let l_sql       = null
  let l_c24astdes = null 
  let l_msg       = null 
  let l_xml       = null
  let l_qtd       = 0
      
  let lr_param.cgccpfnum  = g_paramval[1]
  let lr_param.cgcord     = g_paramval[2]
  let lr_param.cgccpfdig  = g_paramval[3]   

  
  if lr_param.cgccpfnum is null or 
     lr_param.cgccpfdig is null then      
     let l_erro = 999 
     let l_msg  = "Parametros de Entrada invalidos "
     return bdatm001_erro_lista_lig(l_erro,l_msg)     
  end if    
  
  
  if lr_param.cgcord is null then 
     let lr_param.cgcord = 0 
  end if    
  
  whenever error continue  
  drop table bdatm001_tmp_ligacao
  whenever error stop
   
  whenever error continue
      create temp table bdatm001_tmp_ligacao
         (lignum      dec(10,0),
          c24astcod   char(4)  ,
          c24astdes   char(40) ,
          ligdat      date     ,
          lighorinc   datetime hour to minute,
          atdnum      decimal(10,0),
          c24solnom   char(15),
          cnslignum   decimal(10,0))  with no log
   whenever error stop   
   let l_erro = sqlca.sqlcode   
   if sqlca.sqlcode  = 0 then
      create unique index tmp_ind2 on bdatm001_tmp_ligacao
              (lignum,ligdat,lighorinc)
   end if
   
   if sqlca.sqlcode   != 0 then
      if sqlca.sqlcode = -310 or
         sqlca.sqlcode = -958 then  # tabela ja existe
         delete from bdatm001_tmp_ligacao
      end if    
   end if
   
          
  let l_sql = " select atdnum,lignum , c24astcod, c24astdes "                     
           , "      , ligdat , lighorinc,c24solnom,cnslignum "                    
           , " from bdatm001_tmp_ligacao  "
           , " where c24astcod not in ('O60','O61','O63','O58')"                            
           , " order by ligdat desc,lighorinc desc "          
                                                
  prepare pbdatm001020 from l_sql             
  declare cbdatm001020 cursor for pbdatm001020    
      
 if l_erro = 0 then        
    let l_exist = false 
     open cbdatm001002 using lr_param.cgccpfnum,
                             lr_param.cgcord ,  
                             lr_param.cgccpfdig
       
     foreach cbdatm001002 into l_lignum
      
        
        open cbdatm001007 using l_lignum 
        whenever error continue
        foreach cbdatm001007 into lr_lig.lignum   
                                 ,lr_lig.c24astcod
                                 ,lr_lig.ligdat   
                                 ,lr_lig.lighorinc
                                 ,lr_lig.c24solnom
          let l_exist = true     
          whenever error continue                   
          let l_c24astdes = null 
          open cbdatm001001 using lr_lig.c24astcod
          fetch cbdatm001001 into l_c24astdes 
          whenever error stop
            if sqlca.sqlcode = 100 then              
                let l_c24astdes = null 
            end if                                          
            
 
            if lr_lig.c24astcod = "CON" then 
               let lr_lig.cnslignum = null 
               whenever error continue 
               open cbdatm001024 using lr_lig.lignum 
               fetch cbdatm001024 into lr_lig.cnslignum
               whenever error stop 
               if sqlca.sqlcode = notfound then 
                  let lr_lig.cnslignum = null 
               end if 
            else
               let lr_lig.cnslignum = null 
            end if   
            
                 
 
             whenever error continue
             open cbdatm001004 using l_lignum 
             fetch cbdatm001004 into l_atdnum 
             whenever error stop                             
             if sqlca.sqlcode = notfound then 
                let l_atdnum = null 
             end if                                    
      
              insert into bdatm001_tmp_ligacao values (lr_lig.lignum
                                                      ,lr_lig.c24astcod
                                                      ,l_c24astdes
                                                      ,lr_lig.ligdat
                                                      ,lr_lig.lighorinc
                                                      ,l_atdnum
                                                      ,lr_lig.c24solnom
                                                      ,lr_lig.cnslignum) 
            
        end foreach
     end foreach
     whenever error stop
      
     if l_exist = false then         
        let l_erro = 100 
        let l_msg  = "Nenhuma ligacao para este CPF"     
        display  "Nenhuma ligacao para este CPF"             
       return bdatm001_erro_lista_lig(l_erro,l_msg)
     end if 
          
     if sqlca.sqlcode <> 0 then 
         display "Erro < ",sqlca.sqlcode ," > ao localizar as Ligações "
         let l_erro = sqlca.sqlcode
         let l_msg = "Erro < ",l_erro ," > ao localizar as Ligações "
         return 
     end if    
     close cbdatm001002
      
      
     let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>",
                 "<RESPONSE>"                                  
     
     open cbdatm001020  
     foreach cbdatm001020 into lr_ret.*
            
            let l_qtd = l_qtd + 1                 
            
            
            # Limitando a 19 ligacoes 
            if l_qtd <= 20 then 
                let l_xml = l_xml clipped, "<LIGACAO>"   clipped                                     
                                         , "<atdnum>"    clipped  , lr_ret.atdnum    clipped ,"</atdnum>"
                                         , "<lignum>"    clipped  , lr_ret.lignum    clipped ,"</lignum>"
                                         , "<c24astcod>" clipped  , lr_ret.c24astcod clipped ,"</c24astcod>"
                                         , "<c24astdes>" clipped  , lr_ret.c24astdes clipped ,"</c24astdes>"
                                         , "<ligdat>"    clipped  , lr_ret.ligdat    clipped ,"</ligdat>"
                                         , "<lighorinc>" clipped  , lr_ret.lighorinc clipped ,"</lighorinc>"                       
                                         , "<c24solnom>" clipped  , lr_ret.c24solnom clipped ,"</c24solnom>"                                   
                                         #, "<ligorigem>" clipped  , lr_ret.cnslignum clipped ,"</ligorigem>"                                   
                                         , "</LIGACAO>"  clipped        
            else 
              exit foreach
            end if                       
     end foreach     
      
     let l_xml = l_xml clipped,                
                      "</RESPONSE>"            
     
     close cbdatm001020
      
 else 
     let l_msg = "Erro <", l_erro ," ao Criar tabela Temporaria"
     return bdatm001_erro_lista_lig(l_erro,l_msg)
 end if     
        
 return l_xml               


#------------------------------------------------------
end function # bdatm001_lista_lig_cartao
#------------------------------------------------------

#--------------------------------------------------
function bdatm001_erro_lista_lig(lr_param)
#--------------------------------------------------

  define lr_param record
         erro smallint,
         mensagem  char(80)
  end record

  define l_xmlRetorno char(5000)
  
  let l_xmlRetorno = null

  let l_xmlRetorno = "<?xml version='1.0' encoding='ISO-8859-1'?>",
                     "<mq>" , 
                     "<cod_erro>" clipped, lr_param.erro clipped,"  </cod_erro>" clipped,
                     "<erro>" clipped, lr_param.mensagem clipped,"  </erro>" clipped,
                     "</mq>"  
  return l_xmlRetorno

#-----------------------------------
end function # bdatm001_erro lista_lig
#-----------------------------------


#-----------------------------------
function bdatm001_lista_srv_cartao()
#-----------------------------------
  define lr_param record 
     cgccpfnum   like datrligcgccpf.cgccpfnum,
     cgcord      like datrligcgccpf.cgcord,
     cgccpfdig   like datrligcgccpf.cgccpfdig
  end record 
  
  define l_lignum like datmligacao.lignum,
         l_exist  smallint,
         l_erro   integer,
         l_atdnum like datmatd6523.atdnum,         
         l_sql         char(500),                 
         l_c24astdes   like datkassunto.c24astdes,
         l_msg         char(500),                 
         l_xml         char(32766),               
         l_qtd         integer                    
         
  define lr_lig record
         lignum    like datmligacao.lignum,
         c24astcod like datmligacao.c24astcod,         
         ligdat    like datmligacao.ligdat,
         lighorinc like datmligacao.lighorinc,
         atdsrvnum  like datmservico.atdsrvnum,
         atdsrvano  like datmservico.atdsrvano         
  end record 
  
  define lr_ret record         
         lignum     like datmligacao.lignum,
         c24astcod  like datmligacao.c24astcod,    
         c24astdes  like datkassunto.c24astdes,              
         ligdat     like datmligacao.ligdat,
         lighorinc  like datmligacao.lighorinc,
         atdsrvnum  like datmservico.atdsrvnum,
         atdsrvano  like datmservico.atdsrvano,
         atdetpcod  like datketapa.atdetpcod,
         atdetpdes  like datketapa.atdetpdes,
         socntzdes  like datksocntz.socntzdes         
  end record 
  
  define l_socntzcod like datksocntz.socntzcod
        ,l_socntzdes like datksocntz.socntzdes
        ,l_atdetpdes like datketapa.atdetpdes
        ,l_atdetpcod like datketapa.atdetpcod
        
        
        
define lr_retorno record      
     lignum         like datmligacao.lignum,          
     ligdat         like datmligacao.ligdat,          
     lighorinc      like datmligacao.lighorinc,            
     c24solnom      like datmligacao.c24solnom,       
     c24astcod      like datmligacao.c24astcod,            
     c24funmat      like datmligacao.c24funmat,     
     lclrsccod      like datmsrvre.lclrsccod, 
     orrdat         like datmsrvre.orrdat,   
     atdorgsrvnum   like datmsrvre.atdorgsrvnum,
     atdorgsrvano   like datmsrvre.atdorgsrvnum,      
     socntzcod      like datmsrvre.socntzcod,     
     espcod         like datmsrvre.espcod,           
     srvretmtvcod   like datksrvret.srvretmtvcod     
 end record         
        
  
  
    
      
  initialize lr_lig.* to null
  initialize lr_ret.* to null
  initialize lr_retorno.* to null 
  let l_lignum    = null 
  let l_atdnum    = null 
  let l_erro      = null
  let l_sql       = null
  let l_c24astdes = null 
  let l_msg       = null 
  let l_xml       = null
  let l_qtd       = 0
  let l_socntzcod = null
  let l_socntzdes = null
  let l_atdetpdes = null
  let l_atdetpcod = null
  
  
    
  
  let lr_param.cgccpfnum  = g_paramval[1]
  let lr_param.cgcord     = g_paramval[2]
  let lr_param.cgccpfdig  = g_paramval[3]   
  
  if lr_param.cgccpfnum is null or 
     lr_param.cgccpfdig is null then      
     let l_erro = 999 
     let l_msg  = "Parametros de Entrada invalidos "
     return bdatm001_erro_lista_lig(l_erro,l_msg)     
  end if    
  
  if lr_param.cgcord is null or 
     lr_param.cgcord = " " then 
     let lr_param.cgcord = 0 
  end if    

  whenever error continue
  drop table bdatm001_tmp_ligacao
  whenever error stop
  
  # Cria tabela Temp para servico
    whenever error continue
      create temp table bdatm001_tmp_ligacao
         (lignum      dec(10,0),
          c24astcod   char(4)  ,
          c24astdes   char(40) ,
          ligdat      date     ,
          lighorinc   datetime hour to minute,
          atdsrvnum   decimal(10,0),
          atdsrvano   decimal(2,0),          
          atdetpcod   smallint,
          atdetpdes   char(15), 
          socntzcod   smallint,
          socntzdes   char(30)   )  with no log
   whenever error stop
   
   let l_erro = sqlca.sqlcode   
   if sqlca.sqlcode  = 0 then
      create unique index tmp_ind2 on bdatm001_tmp_ligacao
              (lignum,ligdat,lighorinc)
   end if
   
   if sqlca.sqlcode   != 0 then
      if sqlca.sqlcode = -310 or
         sqlca.sqlcode = -958 then  # tabela ja existe         
         delete from bdatm001_tmp_ligacao
      end if    
   end if
  
     
  let l_sql = " select lignum , c24astcod, c24astdes "                     
           , " , ligdat , lighorinc, atdsrvnum "                    
           , " , atdsrvano , atdetpcod, atdetpdes  "  
           , " , socntzdes "
           , " from bdatm001_tmp_ligacao  "
           , " where c24astcod in ('O60','O61','O63','O58','RET')"                            
           , " order by ligdat desc,lighorinc desc "          
                                                
  prepare pbdatm001021 from l_sql             
  declare cbdatm001021 cursor for pbdatm001021
     
       
 if l_erro = 0 then        
    let l_exist = false 
     open cbdatm001002 using lr_param.cgccpfnum,
                             lr_param.cgcord ,  
                             lr_param.cgccpfdig
       
     foreach cbdatm001002 into l_lignum
              
        open cbdatm001003 using l_lignum 
        whenever error continue
        foreach cbdatm001003 into lr_lig.*
                       
          if lr_lig.c24astcod = "RET" then              
             open cbdatm001011 using lr_lig.atdsrvnum,lr_lig.atdsrvano
             fetch cbdatm001011 into lr_retorno.lclrsccod,  
                                     lr_retorno.socntzcod,  
                                     lr_retorno.orrdat,     
                                     lr_retorno.atdorgsrvnum,
                                     lr_retorno.atdorgsrvano,
                                     lr_retorno.espcod,     
                                     lr_retorno.srvretmtvcod                                                                     
                
                open cbdatm001010 using lr_retorno.atdorgsrvnum,
                                        lr_retorno.atdorgsrvano
                whenever error continue
                fetch cbdatm001010 into lr_retorno.lignum   
                                       ,lr_retorno.c24astcod
                                       ,lr_retorno.ligdat   
                                       ,lr_retorno.lighorinc
                                       ,lr_retorno.c24solnom                         
                                       ,lr_retorno.c24funmat
                whenever error stop 
                if sqlca.sqlcode = notfound then                    
                   exit foreach 
                end if  
          end if                            
                                               
          let l_exist = true
          whenever error continue 
          let l_c24astdes = null
          open cbdatm001001 using lr_lig.c24astcod
          fetch cbdatm001001 into l_c24astdes 
          whenever error stop
            if sqlca.sqlcode = notfound then 
              let l_c24astdes = null 
            end if              
                whenever error continue 
                open cbdatm001006 using lr_lig.atdsrvnum,lr_lig.atdsrvano
                fetch cbdatm001006 into l_atdetpcod,l_atdetpdes
                whenever error stop
                  if sqlca.sqlcode = notfound then 
                     let l_atdetpdes = null 
                  end if                              
                    whenever error continue
                    open cbdatm001005 using lr_lig.atdsrvnum,lr_lig.atdsrvano
                    fetch cbdatm001005 into l_socntzcod,l_socntzdes
                    whenever error stop  
                    if sqlca.sqlcode = notfound then 
                       let l_socntzcod = null 
                       let l_socntzdes = null 
                    end if    
                                                                  
                       insert into bdatm001_tmp_ligacao values (lr_lig.lignum
                                                               ,lr_lig.c24astcod
                                                               ,l_c24astdes
                                                               ,lr_lig.ligdat
                                                               ,lr_lig.lighorinc
                                                               ,lr_lig.atdsrvnum
                                                               ,lr_lig.atdsrvano                                                               
                                                               ,l_atdetpcod
                                                               ,l_atdetpdes
                                                               ,l_socntzcod
                                                               ,l_socntzdes) 
            
        end foreach
     end foreach
     whenever error stop
           
     if l_exist = false then         
        let l_erro = 100 
        let l_msg  = "Nenhuma servico para este CPF"     
        display  "Nenhuma servico para este CPF"             
       return bdatm001_erro_lista_lig(l_erro,l_msg)
     end if 
          
     if sqlca.sqlcode <> 0 then 
         display "Erro < ",sqlca.sqlcode ," > ao localizar os servico "
         let l_erro = sqlca.sqlcode
         let l_msg = "Erro < ",l_erro ," > ao localizar os servico "
         return 
     end if    
     close cbdatm001002
      
      
     let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>",
                 "<RESPONSE>"                                  
     
     open cbdatm001021  
     foreach cbdatm001021 into lr_ret.*            
            let l_qtd = l_qtd + 1                 
            
                        
            # Limitando a 15 Serviços            
            if l_qtd <= 13 then 
                let l_xml = l_xml clipped,
                                   "<LIGACAO>"   ,
                                   "<lignum>"    , lr_ret.lignum    clipped ,"</lignum>",
                                   "<atdsrvnum>" , lr_ret.atdsrvnum clipped ,"</atdsrvnum>",
                                   "<atdsrvano>" , lr_ret.atdsrvano clipped ,"</atdsrvano>",                                   
                                   "<ligdat>"    , lr_ret.ligdat    clipped ,"</ligdat>",
                                   "<lighorinc>" , lr_ret.lighorinc clipped ,"</lighorinc>",                       
                                   "<c24astcod>" , lr_ret.c24astcod clipped ,"</c24astcod>",
                                   "<c24astdes>" , lr_ret.c24astdes clipped ,"</c24astdes>",                                                                           
                                   "<tpsrv>"     , lr_ret.socntzdes clipped ,"</tpsrv>",                                   
                                   "<codetapa>"  , lr_ret.atdetpcod clipped ,"</codetapa>",
                                   "<etapa>"     , lr_ret.atdetpdes clipped ,"</etapa>",                                   
                                   "</LIGACAO>"          
            else 
              exit foreach
            end if                       
     end foreach
     
      
     let l_xml = l_xml clipped,                
                      "</RESPONSE>"            
     
     close cbdatm001021
      
 else  
     let l_msg = "Erro <", l_erro ," ao Criar tabela Temporaria"
     return bdatm001_erro_lista_lig(l_erro,l_msg)
 end if      
 return l_xml               

#----------------------------------------------------
end function # bdatm001_lista_srv_cartao
#----------------------------------------------------



#------------------------------------------------------
function bdatm001_rec_lig_cartao()
#------------------------------------------------------

  define l_lignum        like datmligacao.lignum,
         l_rcuccsmtvdes  like datkrcuccsmtv.rcuccsmtvdes,
         l_c24astdes     like datkassunto.c24astdes,
         l_erro          integer,
         l_msg           char(500),
         l_atdnum        like datmatd6523.atdnum,         
         l_xml           char(32766)         
  
  define lr_lig record
         lignum     like datmligacao.lignum,
         c24astcod  like datmligacao.c24astcod,         
         ligdat     like datmligacao.ligdat,
         lighorinc  like datmligacao.lighorinc,
         c24solnom  like datmligacao.c24solnom,
         atdsrvnum  like datmservico.atdsrvnum,
         atdsrvano  like datmservico.atdsrvano,
         c24funmat  like datmligacao.c24funmat         
  end record 
  
  define lr_hist record
        lignum            like datmlighist.lignum,
        c24txtseq         like datmlighist.c24txtseq,
        c24ligdsc         like datmlighist.c24ligdsc
  end record
  
  
  
  initialize lr_lig.* to null
  initialize lr_hist.* to null
  let l_lignum       = null 
  let l_rcuccsmtvdes = null
  let l_c24astdes    = null
  let l_erro         = 0
  let l_msg          = null  
  let l_xml          = null  
  
  
  
  let l_lignum = g_paramval[1]   
  
  if l_lignum is null or 
     l_lignum = 0 then      
     let l_erro = 999 
     let l_msg  = "Parametro de Entrada lignum = ",l_lignum clipped  ," invalido "
     return bdatm001_erro_lista_lig(l_erro,l_msg)     
  end if    

  
  open cbdatm001007 using l_lignum 
  whenever error continue
  fetch cbdatm001007 into lr_lig.lignum   
                         ,lr_lig.c24astcod
                         ,lr_lig.ligdat   
                         ,lr_lig.lighorinc
                         ,lr_lig.c24solnom
                         ,lr_lig.atdsrvnum
                         ,lr_lig.atdsrvano
                         ,lr_lig.c24funmat
  whenever error stop   

  
  if sqlca.sqlcode <> 0 then 
     let l_erro = sqlca.sqlcode
     let l_msg  = "Erro ", l_erro ," ao Localizar a ligacao"
  end if                           
      
      
      
  whenever error continue   
  open cbdatm001001 using lr_lig.c24astcod
  fetch cbdatm001001 into l_c24astdes 
  whenever error stop
  
  if sqlca.sqlcode <> 0 then 
     if sqlca.sqlcode = notfound then 
        let l_c24astdes = null
     else 
        let l_erro = sqlca.sqlcode
        let l_msg  = "Erro ", l_erro ," ao Localizar a descricao do assunto"
     end if
  end if                     
    
  if lr_lig.c24funmat <> 999999 then   
     whenever error continue
     open cbdatm001004 using l_lignum 
     fetch cbdatm001004 into l_atdnum 
     whenever error stop                      
     
     if sqlca.sqlcode <> 0 then 
       if sqlca.sqlcode = notfound then 
          let l_atdnum = null 
       else                
        let l_erro = sqlca.sqlcode
        let l_msg  = "Erro ", l_erro ," ao Localizar atendimento"
       end if   
     end if                     
  end if    
  
  whenever error continue
  open cbdatm001008 using l_lignum 
  fetch cbdatm001008 into l_rcuccsmtvdes
  whenever error stop    
  
  if sqlca.sqlcode <> 0 then 
     if sqlca.sqlcode <> 100 then
        let l_erro = sqlca.sqlcode
        let l_msg  = "Erro ", l_erro ," ao Localizar Motivo"
     end if    
  end if                     
  

   let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>",
               "<RESPONSE>",                                                                
                      "<LIGACAO>",
                      "<atdnum>"    , l_atdnum         clipped ,"</atdnum>",
                      "<lignum>"    , lr_lig.lignum    clipped ,"</lignum>",
                      "<ligdat>"    , lr_lig.ligdat    clipped ,"</ligdat>",
                      "<lighorinc>" , lr_lig.lighorinc clipped ,"</lighorinc>",                       
                      "<c24astcod>" , lr_lig.c24astcod clipped ,"</c24astcod>",
                      "<c24astdes>" , l_c24astdes      clipped ,"</c24astdes>",
                      "<c24solnom>" , lr_lig.c24solnom clipped ,"</c24solnom>" 
                                                
    if lr_lig.c24astcod = "O00" then 
       let l_xml = l_xml clipped, "<motivo>" , l_rcuccsmtvdes clipped, "</motivo>"
    else 
       let l_xml = l_xml clipped, "<motivo></motivo>"
    end if    

  
  let l_xml = l_xml clipped, "<HISTORICO>"
  
  whenever error continue
  open cbdatm001009 using l_lignum 
  
  foreach cbdatm001009 into lr_hist.*
  
  
         let l_xml = l_xml clipped,"<c24ligdsc>", lr_hist.c24ligdsc clipped, "</c24ligdsc>"                                   
  
  end foreach
  whenever error stop        
  
  let l_xml = l_xml clipped, "</HISTORICO>",
                             "</LIGACAO>",
                             "</RESPONSE>"
  
          
  if l_erro <> 0 then 
     return bdatm001_erro_lista_lig(l_erro,l_msg)          
  end if 
  
  return l_xml   
          
#---------------------------------------------
end function # bdatm001_rec_lig_cartao
#---------------------------------------------


#---------------------------------------------------------
function bdatm001_rec_srv_cartao()
#---------------------------------------------------------

  define l_atdsrvnum     like datmservico.atdsrvnum,
         l_atdsrvano     like datmservico.atdsrvano,         
         l_erro          integer,
         l_msg           char(500),
         l_atdnum        like datmatd6523.atdnum,         
         l_xml           char(32766)         
  
  
  
  define lr_hist record
        lignum            like datmlighist.lignum,
        c24txtseq         like datmlighist.c24txtseq,
        c24ligdsc         like datmlighist.c24ligdsc
  end record
  
 define lr_ret_loc   record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    lclbrrnom        like datmlcl.lclbrrnom,
    brrnom           like datmlcl.brrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    endzon           like datmlcl.endzon,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    lclltt           like datmlcl.lclltt,
    lcllgt           like datmlcl.lcllgt,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    celteldddcod     like datmlcl.celteldddcod,
    celtelnum        like datmlcl.celtelnum,            
    endcmp           like datmlcl.endcmp,
    coderro          integer    
 end record
                                                     
 
 define ws            record    
    endlgdtip         like rlaklocal.endlgdtip     ,
    endlgdnom         like rlaklocal.endlgdnom     ,
    endnum            like rlaklocal.endnum        ,
    endcmp            like rlaklocal.endcmp        ,
    endbrr            like rlaklocal.endbrr        ,
    endcid            like rlaklocal.endcid        ,
    ufdcod            like rlaklocal.ufdcod        ,
    endcep            like rlaklocal.endcep        ,
    endcepcmp         like rlaklocal.endcepcmp         
 end record
 
 define lr_retorno record 
     atdnum         like datmatd6523.atdnum,          
     lignum         like datmligacao.lignum,     
     ligdat         like datmligacao.ligdat,
     lighorinc      like datmligacao.lighorinc,
     atdsrvnum      like datmservico.atdsrvnum,
     atdsrvano      like datmservico.atdsrvano,     
     c24solnom      like datmligacao.c24solnom,
     c24astcod      like datmligacao.c24astcod,
     c24astdes      like datkassunto.c24astdes,
     lclrsccod      like datmsrvre.lclrsccod,
     lclrscflg      char(1),
     lgdnom         like datmlcl.lgdnom,
     lgdnum         like datmlcl.lgdnum, 
     brrnom         like datmlcl.brrnom,
     cidnom         like datmlcl.cidnom,
     ufdcod         like datmlcl.ufdcod,
     lclrefptotxt   like datmlcl.lclrefptotxt,     
     endzon         like datmlcl.endzon,
     dddcod         like datmlcl.dddcod,
     lcltelnum      like datmlcl.lcltelnum,          
     lclcttnom      like datmlcl.lclcttnom,
     orrdat         like datmsrvre.orrdat,   
     atdorgsrvnum   like datmsrvre.atdorgsrvnum,
     atdorgsrvano   like datmsrvre.atdorgsrvnum,      
     socntzcod      like datmsrvre.socntzcod,
     socntzdes      like datksocntz.socntzdes,
     espcod         like datmsrvre.espcod, 
     espdes         like dbskesp.espdes,   
     c24pbmcod      like datkpbm.c24pbmcod,
     c24pbmdes      like datkpbm.c24pbmdes,
     srvretmtvcod   like datksrvret.srvretmtvcod,
     srvretmtvdes   like datksrvret.srvretmtvdes,
     asitipcod      like datmservico.asitipcod,
     asitipabvdes   like datkasitip.asitipabvdes,
     atdprinvlcod   like datmservico.atdprinvlcod,
     atdprinvldes   char(06),
     atdlibflg      like datmservico.atdlibflg,
     prslocflg      like datmservico.prslocflg,
     frmflg         char(1),
     atdhorpvt      like datmservico.atdhorpvt,
     atddatprg      like datmservico.atddatprg,
     imdsrvflg      char(1),
     atdpvtretflg   like datmservico.atdpvtretflg,
     atdhorprg      like datmservico.atdhorprg,
     c24srvdsc      like datmservhist.c24srvdsc,
     lgdtip         like datmlcl.lgdtip     
 end record 
  
  
  define l_emeviacod  like datmlcl.emeviacod
  define l_c24funmat  like datmligacao.c24funmat
  
    
  initialize lr_hist.*    to null  
  initialize ws.*         to null
  initialize lr_retorno.* to null 
  let l_erro         = 0
  let l_msg          = null  
  let l_xml          = null  
  let l_c24funmat    = null
  
  
  
  let l_atdsrvnum = g_paramval[1]   
  let l_atdsrvano = g_paramval[2]   
  
  if l_atdsrvnum is null or 
     l_atdsrvnum = 0 then       
     let l_erro = 999 
     let l_msg  = "Parametro de Entrada atdsrvnum = ", l_atdsrvnum clipped ," invalidos. "
     return bdatm001_erro_lista_lig(l_erro,l_msg)     
  else 
    if l_atdsrvano is null or 
       l_atdsrvano = 0 then   
       let l_erro = 999 
       let l_msg  = "Parametro de Entrada atdsrvano = ", l_atdsrvano clipped ," invalidos. "
       return bdatm001_erro_lista_lig(l_erro,l_msg)     
    end if    
  end if    
  
  
  #-----------------------------------
  # Busca dados do atendimento
  #-----------------------------------
  
  open cbdatm001025 using l_atdsrvnum,l_atdsrvano
  whenever error continue
  fetch cbdatm001025 into lr_retorno.lignum   
                         ,lr_retorno.c24astcod
                         ,lr_retorno.ligdat   
                         ,lr_retorno.lighorinc
                         ,lr_retorno.c24solnom                         
                         ,l_c24funmat
  whenever error stop 
  
  if sqlca.sqlcode <> 0 then 
     let l_erro = sqlca.sqlcode
     let l_msg  = "Erro ", l_erro ," ao Localizar a ligacao"
  end if                           
  close cbdatm001010    
      
  #-----------------------------------
  # Busca Descrição do Assunto
  #-----------------------------------
  
  whenever error continue   
  open cbdatm001001 using lr_retorno.c24astcod
  fetch cbdatm001001 into lr_retorno.c24astdes 
  whenever error stop
  
  if sqlca.sqlcode <> 0 then 
     if sqlca.sqlcode = notfound then 
       let lr_retorno.c24astdes  = null
     else 
       let l_erro = sqlca.sqlcode
       let l_msg  = "Erro ", l_erro ," ao Localizar a descricao do assunto"
     end if
  end if                     
  
  #------------------------------------
  # Busca dados do servico
  #------------------------------------
   
  
  
  open cbdatm001016 using l_atdsrvnum,l_atdsrvano
  whenever error continue
  fetch cbdatm001016 into lr_retorno.asitipcod,
                          lr_retorno.atdprinvlcod,
                          lr_retorno.atdlibflg,
                          lr_retorno.prslocflg,
                          lr_retorno.atdhorpvt,
                          lr_retorno.atddatprg,
                          lr_retorno.atdpvtretflg,
                          lr_retorno.atdhorprg
                          
                          
  whenever error stop 
  
  if sqlca.sqlcode <> 0 then 
     let l_erro = sqlca.sqlcode
     let l_msg  = "Erro ", l_erro ," ao Localizar dados do serviço"
  end if                     
    
  
  
  #--------------------------------------
  # Busca Numero de atendimento
  #--------------------------------------
  
  if l_c24funmat <> 999999 then 
     whenever error continue
     open cbdatm001004 using lr_retorno.lignum 
     fetch cbdatm001004 into lr_retorno.atdnum 
     whenever error stop                           
     
     if sqlca.sqlcode <> 0 then 
        if sqlca.sqlcode = notfound then 
          let lr_retorno.atdnum = null
        else         
          let l_erro = sqlca.sqlcode
          let l_msg  = "Erro ", l_erro ," ao Localizar atendimento"
        end if 
     end if                     
  end if    
  
  #-------------------------------------------------------
  # Busca dados do servico na tabela datmsrvre
  #-------------------------------------------------------
  
  whenever error continue 
  open cbdatm001011 using l_atdsrvnum,l_atdsrvano
  fetch cbdatm001011 into lr_retorno.lclrsccod,  
                          lr_retorno.socntzcod, 
                          lr_retorno.orrdat,                              
                          lr_retorno.atdorgsrvnum,
                          lr_retorno.atdorgsrvano,
                          lr_retorno.espcod,
                          lr_retorno.srvretmtvcod         
  whenever error stop 
  
  if sqlca.sqlcode <> 0 then 
     let l_erro = sqlca.sqlcode
     let l_msg  = "Erro ", l_erro ," ao Localizar dados da tabela datmsrvre"
  end if                     
  
  
  #---------------------------
  # Busca Dados do Local
  #---------------------------
  
  call ctx04g00_local_gps(l_atdsrvnum,l_atdsrvano,1)
       returning lr_ret_loc.*,l_emeviacod  
       
  
  let lr_retorno.lgdnom        = lr_ret_loc.lgdnom      
  let lr_retorno.lgdnum        = lr_ret_loc.lgdnum      
  let lr_retorno.brrnom        = lr_ret_loc.brrnom   
  let lr_retorno.cidnom        = lr_ret_loc.cidnom      
  let lr_retorno.ufdcod        = lr_ret_loc.ufdcod       
  let lr_retorno.lclrefptotxt  = lr_ret_loc.lclrefptotxt 
  let lr_retorno.endzon        = lr_ret_loc.endzon       
  let lr_retorno.dddcod        = lr_ret_loc.dddcod       
  let lr_retorno.lcltelnum     = lr_ret_loc.lcltelnum    
  let lr_retorno.lclcttnom     = lr_ret_loc.lclcttnom   
  let lr_retorno.lgdtip        = lr_ret_loc.lgdtip
    
  
     
  #------------------------------
  # Regra da Flag lclrscflg
  #------------------------------
  
  if lr_retorno.lclrsccod is not null  or 
     lr_retorno.lclrsccod <> " " then
      select endlgdtip,
             endlgdnom,
             endnum   ,
             endcmp   ,
             endbrr   ,
             endcid   ,
             ufdcod   ,
             endcep   ,
             endcepcmp
        into ws.endlgdtip,  
             ws.endlgdnom,  
             ws.endnum   ,  
             ws.endcmp   ,  
             ws.endbrr   ,  
             ws.endcid   ,  
             ws.ufdcod   ,  
             ws.endcep   ,  
             ws.endcepcmp   
        from rlaklocal
       where lclrsccod = lr_retorno.lclrsccod

      if lr_retorno.lclrefptotxt is null  then
         let lr_retorno.lclrefptotxt = ws.endcmp
      end if      
      if lr_ret_loc.lgdtip    = ws.endlgdtip  and
         lr_ret_loc.lgdnom    = ws.endlgdnom  and
         lr_ret_loc.lgdnum    = ws.endnum     and
         lr_ret_loc.brrnom    = ws.endbrr     and
         lr_ret_loc.cidnom    = ws.endcid     and
         lr_ret_loc.ufdcod    = ws.ufdcod     then
         let lr_retorno.lclrscflg = "S"         
      else
         let lr_retorno.lclrscflg = "N"         
      end if
  else
    let lr_retorno.lclrscflg = "N"    
  end if
  
  
  #--------------------------------
  #Busca descricao da natureza 
  #--------------------------------
  
  whenever error continue
  open  cbdatm001012 using lr_retorno.socntzcod
  fetch cbdatm001012 into  lr_retorno.socntzdes
  whenever error stop    
  
  if sqlca.sqlcode <> 0 then 
     let l_erro = sqlca.sqlcode
     let l_msg  = "Erro ", l_erro ," ao Localizar descricao da natureza"
  end if                     
  
  
  #--------------------------------------
  #Busca descricao da especialidade
  #--------------------------------------
  
  if lr_retorno.espcod is not null then 
     whenever error continue
     open  cbdatm001013 using lr_retorno.espcod
     fetch cbdatm001013 into  lr_retorno.espdes
     whenever error stop    
     
     if sqlca.sqlcode <> 0 then 
        let l_erro = sqlca.sqlcode
        let l_msg  = "Erro ", l_erro ," ao Localizar descricao da especialidade"
     end if                     
  end if        

  #------------------------------------------
  #Busca descricao do motivo do retorno
  #------------------------------------------
  
  if lr_retorno.srvretmtvcod is not null then   
     whenever error continue
     open  cbdatm001014 using lr_retorno.srvretmtvcod
     fetch cbdatm001014 into  lr_retorno.srvretmtvdes
     whenever error stop    
     
     if sqlca.sqlcode <> 0 then 
        let l_erro = sqlca.sqlcode
        let l_msg  = "Erro ", l_erro ," ao Localizar descricao do motivo do retorno"
     end if                     
  end if     
  
  #-----------------------------------------
  #Busca descricao do tipo de assistencia
  #-----------------------------------------
  
  whenever error continue
  open  cbdatm001015 using lr_retorno.asitipcod
  fetch cbdatm001015 into  lr_retorno.asitipabvdes
  whenever error stop    
  
  if sqlca.sqlcode <> 0 then 
     let l_erro = sqlca.sqlcode
     let l_msg  = "Erro ", l_erro ," ao Localizar descricao do tipo de assistencia"
  end if                     
  
  #-----------------------------------  
  # Busca descrição do problema 
  #-----------------------------------  
  whenever error continue
  open  cbdatm001017 using l_atdsrvnum,l_atdsrvano
  fetch cbdatm001017 into  lr_retorno.c24pbmcod,lr_retorno.c24pbmdes
  whenever error stop    
  
  if sqlca.sqlcode <> 0 then 
     let l_erro = sqlca.sqlcode
     let l_msg  = "Erro ", l_erro ," ao Localizar descricao do problema"
  end if                     

  #-----------------------------
  #Busca Descricao prioridade
  #-----------------------------  
  whenever error continue 
  open  cbdatm001018 using lr_retorno.atdprinvlcod
  fetch cbdatm001018 into  lr_retorno.atdprinvldes
  whenever error stop    
  
  if sqlca.sqlcode <> 0 then 
     let l_erro = sqlca.sqlcode
     let l_msg  = "Erro ", l_erro ," ao Localizar descricao da prioridade"
  end if                     
  
  
  #---------------------------  
  # Busca Flag Formulario
  #---------------------------
  
  select lignum from datmligfrm
  where lignum = lr_retorno.lignum
  
  if sqlca.sqlcode = notfound  then
     let lr_retorno.frmflg = "N"
  else
     let lr_retorno.frmflg = "S"
  end if
  
  #------------------------------------
  #Busca Flag de servico imediato
  #------------------------------------
  
  if lr_retorno.atdhorpvt is not null  or
    lr_retorno.atdhorpvt  = "00:00"   then
    let lr_retorno.imdsrvflg = "S"
  end if

  if lr_retorno.atddatprg is not null  then
     let lr_retorno.imdsrvflg = "N"
  end if
  
  let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>",
              "<RESPONSE>",                                                                 
                 "<atdnum>"          , lr_retorno.atdnum        clipped , "</atdnum>",      
                 "<lignum>"          , lr_retorno.lignum        clipped , "</lignum>",      
                 "<ligdat>"          , lr_retorno.ligdat        clipped , "</ligdat>",      
                 "<lighorinc>"       , lr_retorno.lighorinc     clipped , "</lighorinc>",   
                 "<atdsrvnum>"       , l_atdsrvnum              clipped , "</atdsrvnum>",                       
                 "<atdsrvano>"       , l_atdsrvano              clipped , "</atdsrvano>",   
                 "<c24solnom>"       , lr_retorno.c24solnom     clipped , "</c24solnom>",                         
                 "<c24astcod>"       , lr_retorno.c24astcod     clipped , "</c24astcod>",   
                 "<c24astdes>"       , lr_retorno.c24astdes     clipped , "</c24astdes>",   
                 "<lclrsccod>"       , lr_retorno.lclrsccod     clipped , "</lclrsccod>",   
                 "<lclrscflg>"       , lr_retorno.lclrscflg     clipped , "</lclrscflg>",                                       
                 "<lgdnom>"          , lr_retorno.lgdnom        clipped , "</lgdnom>",      
                 "<lgdnum>"          , lr_retorno.lgdnum        clipped , "</lgdnum>",      
                 "<lclbrrnom>"       , lr_retorno.brrnom        clipped , "</lclbrrnom>",   
                 "<cidnom>"          , lr_retorno.cidnom        clipped , "</cidnom>",      
                 "<ufdcod>"          , lr_retorno.ufdcod        clipped , "</ufdcod>",      
                 "<lclrefptotxt>"    , lr_retorno.lclrefptotxt  clipped , "</lclrefptotxt>",
                 "<endzon>"          , lr_retorno.endzon        clipped , "</endzon>",      
                 "<dddcod>"          , lr_retorno.dddcod        clipped , "</dddcod>",      
                 "<lcltelnum>"       , lr_retorno.lcltelnum     clipped , "</lcltelnum>",   
                 "<lclcttnom>"       , lr_retorno.lclcttnom     clipped , "</lclcttnom>",   
                 "<orrdat>"          , lr_retorno.orrdat        clipped , "</orrdat>",      
                 "<atdorgsrvnum>"    , lr_retorno.atdorgsrvnum  clipped , "</atdorgsrvnum>",
                 "<atdorgsrvano>"    , lr_retorno.atdorgsrvano  clipped , "</atdorgsrvano>",
                 "<socntzcod>"       , lr_retorno.socntzcod     clipped , "</socntzcod>",   
                 "<socntzdes>"       , lr_retorno.socntzdes     clipped , "</socntzdes>",   
                 "<espcod>"          , lr_retorno.espcod        clipped , "</espcod>",      
                 "<espdes>"          , lr_retorno.espdes        clipped , "</espdes>",      
                 "<c24pbmcod>"       , lr_retorno.c24pbmcod     clipped , "</c24pbmcod>",   
                 "<c24pbmdes>"       , lr_retorno.c24pbmdes     clipped , "</c24pbmdes>",   
                 "<srvretmtvcod>"    , lr_retorno.srvretmtvcod  clipped , "</srvretmtvcod>",
                 "<srvretmtvdes>"    , lr_retorno.srvretmtvdes  clipped , "</srvretmtvdes>",
                 "<asitipcod>"       , lr_retorno.asitipcod     clipped , "</asitipcod>",   
                 "<asitipabvdes>"    , lr_retorno.asitipabvdes  clipped , "</asitipabvdes>",
                 "<atdprinvlcod>"    , lr_retorno.atdprinvlcod  clipped , "</atdprinvlcod>",
                 "<atdprinvldes>"    , lr_retorno.atdprinvldes  clipped , "</atdprinvldes>",
                 "<atdlibflg>"       , lr_retorno.atdlibflg     clipped , "</atdlibflg>",
                 "<prslocflg>"       , lr_retorno.prslocflg     clipped , "</prslocflg>",
                 "<frmflg>"          , lr_retorno.frmflg        clipped , "</frmflg>",
                 "<atdhorpvt>"       , lr_retorno.atdhorpvt     clipped , "</atdhorpvt>",
                 "<atddatprg>"       , lr_retorno.atddatprg     clipped , "</atddatprg>",
                 "<imdsrvflg>"       , lr_retorno.imdsrvflg     clipped , "</imdsrvflg>",
                 "<atdpvtretflg>"    , lr_retorno.atdpvtretflg  clipped , "</atdpvtretflg>",
                 "<atdhorprg>"       , lr_retorno.atdhorprg     clipped , "</atdhorprg>",
                 "<lgdtip>"          , lr_retorno.lgdtip        clipped , "</lgdtip>"
                                  
  let l_xml = l_xml clipped, "<HISTORICO>"
  
  whenever error continue
  open cbdatm001019 using l_atdsrvnum,l_atdsrvano  
  foreach cbdatm001019 into lr_retorno.c24srvdsc
  
  
         let l_xml = l_xml clipped,"<c24srvdsc>", lr_retorno.c24srvdsc clipped, "</c24srvdsc>"
  
  end foreach
  whenever error stop        
  
  let l_xml = l_xml clipped, "</HISTORICO>",
                             "</RESPONSE>"
                                              
  if l_erro <> 0 then 
     return bdatm001_erro_lista_lig(l_erro,l_msg)          
  end if         
                 
  return l_xml   
  
  
#------------------------------------------               
end function # bdatm001_rec_srv_cartao
#------------------------------------------

               
#-----------------------------------------
function bdatm001_can_srv()          
#-----------------------------------------
   define lr_param record 
       atdsrvnum like datmservico.atdsrvnum,
       atdsrvano like datmservico.atdsrvano,
       c24solnom like datmligacao.c24solnom 
   end record         
   
   define l_retorno     char(5000)
         ,l_msg         char(200)
         ,l_atdfnlflg   like datmservico.atdfnlflg
         ,l_atdetpcod   like datmservico.atdetpcod
         ,l_can         char(10)
         ,l_lignum      like datmligacao.lignum
         ,l_qtd         integer
         ,l_docHandle  integer
         
   define l_erro integer            
      
   
   initialize lr_param.* to null 
   let l_retorno   = null 
   let l_atdfnlflg = null 
   let l_lignum    = null
   let l_erro      = null 
   let l_msg       = null 
   
   let lr_param.atdsrvnum = g_paramval[1]
   let lr_param.atdsrvano = g_paramval[2]
   let lr_param.c24solnom = g_paramval[3]
   
   if lr_param.atdsrvnum is null or 
      lr_param.atdsrvnum = 0 then       
     let l_erro = 999 
     let l_msg  = "Parametro de Entrada atdsrvnum = ", lr_param.atdsrvnum clipped ," invalidos. "
     return bdatm001_erro_lista_lig(l_erro,l_msg)     
   else 
     if lr_param.atdsrvano is null or 
        lr_param.atdsrvano = 0 then   
        let l_erro = 999 
        let l_msg  = "Parametro de Entrada atdsrvano = ", lr_param.atdsrvano clipped ," invalidos. "
        return bdatm001_erro_lista_lig(l_erro,l_msg)     
     end if    
   end if   
   
   
      
   call bdatm001_carregaVariaveisGlobais(lr_param.atdsrvnum
                                        ,lr_param.atdsrvano
                                        ,lr_param.c24solnom)
        returning l_atdfnlflg,l_atdetpcod

   if l_atdfnlflg is null or
      l_atdfnlflg =  " "  then      
          call ctf00m06_xmlerro ("CANCELAR_SERVICO"
                                         ,3
                                         ,"Servico/Ano nao Cadastrado ou Nao Informado")
                   returning  l_retorno
   
   else          
     if l_atdetpcod = 3 or l_atdetpcod = 5 then        
       if  l_atdetpcod = 3 then 
         let l_retorno = "<?xml version='1.0' encoding='ISO-8859-1'?>",
                              "<mq>" , 
                              "<cod_erro>999</cod_erro>" clipped,
                              "<erro>Servico ja' acionado !</erro>" clipped,
                              "</mq>"                      
       else         
         let l_retorno = "<?xml version='1.0' encoding='ISO-8859-1'?>",
                              "<mq>" , 
                              "<cod_erro>999</cod_erro>" clipped,
                              "<erro>Servico ja' Cancelado !</erro>" clipped,
                              "</mq>"                      
       end if                             
     else         
        call ctf00m03(lr_param.atdsrvnum
                     ,lr_param.atdsrvano
                     ,l_atdfnlflg)
             returning l_retorno
             
           call figrc011_inicio_parse()
           
           let l_docHandle = figrc011_parse(l_retorno)
                                                                                   
           let l_qtd =  figrc011_xpath(l_docHandle,"count(/RESPONSE/CANCELADO)")
                           
           if l_qtd > 0 then                                         
                 call bdatm001_busca_lig(lr_param.atdsrvnum,
                                         lr_param.atdsrvano)
                      returning l_lignum                         
                 let l_retorno = "<?xml version='1.0' encoding='ISO-8859-1'?>",
                                 "<RESPONSE>" , 
                                 "<lignum>" , l_lignum clipped,"  </lignum>" clipped,
                                 "</RESPONSE>"                                 
           end if   
     end if       
                            
   end if
    
   call figrc011_fim_parse()
   return l_retorno

#--------------------------------------------
end function # bdatm001_can_srv
#--------------------------------------------


#-----------------------------------------------------------------------------
function bdatm001_carregaVariaveisGlobais(l_param)
#-----------------------------------------------------------------------------

   define l_param         record
          atdsrvnum       like datmservico.atdsrvnum
         ,atdsrvano       like datmservico.atdsrvano
         ,c24solnom       like datmligacao.c24solnom
   end record

   define l_lignum        like datmligacao.lignum
	 ,l_atdfnlflg     like datmservico.atdfnlflg
	 ,l_atdetpcod     like datmservico.atdetpcod


   initialize l_lignum , l_atdfnlflg to null

   
   let g_origem                 = "WEB"  
   let g_documento.solnom       = l_param.c24solnom
   let g_issk.funmat            = 999999
   let g_issk.empcod            = 1
   let g_issk.usrtip            = "F"

   #-----------------------------
   # Carrega variaveis globais
   #-----------------------------
   
   
   select a.ciaempcod
         ,a.atdfnlflg
         ,c.cgccpfnum
         ,c.cgcord
         ,c.cgccpfdig
         ,c.crtdvgflg
         ,a.atdetpcod         
     into g_documento.ciaempcod
	 ,l_atdfnlflg
	 ,g_documento.cgccpfnum
	 ,g_documento.cgcord   
	 ,g_documento.cgccpfdig
	 ,g_crtdvgflg
	 ,l_atdetpcod           	                   
     from datmservico a
         ,datmligacao b 
         ,datrligcgccpf c 
    where a.atdsrvnum = l_param.atdsrvnum
      and a.atdsrvano = l_param.atdsrvano
      and a.atdsrvnum = b.atdsrvnum
      and a.atdsrvano = b.atdsrvano
      and a.atdsrvorg = 9 
      and b.lignum = c.lignum 
      and b.c24astcod in ("O58","O60","O61","O63")
   

   #----------------------------
   # Ligacao do servico
   #----------------------------
   
   select min (lignum)
     into l_lignum
     from datrligsrv
    where atdsrvnum = l_param.atdsrvnum
      and atdsrvano = l_param.atdsrvano

   #------------------------
   # Assunto da Ligacao
   #------------------------
   
   select c24astcod
     into g_documento.c24astcod
     from datmligacao
    where lignum = l_lignum

   return l_atdfnlflg,l_atdetpcod

#------------------------------------------------
end function #bdatm001_carregaVariaveisGlobais
#------------------------------------------------

#--------------------------------------------------
function bdatm001_busca_lig(lr_param)
#--------------------------------------------------
   define lr_param record 
          atdsrvnum like datmservico.atdsrvnum,
          atdsrvano like datmservico.atdsrvano
   end record 
   
   define l_lignum like datmligacao.lignum 
   
   let l_lignum = null 
      
   select c.lignum                    
        into l_lignum         
        from datmservico  a                   
            ,datmligacao b            
            ,datrligcgccpf c          
       where a.atdsrvnum = lr_param.atdsrvnum    
         and a.atdsrvano = lr_param.atdsrvano
         and a.atdsrvnum = b.atdsrvnum
         and a.atdsrvano = b.atdsrvano
         and a.atdsrvorg = 9          
         and b.lignum = c.lignum      
         and b.c24astcod in ("CAN")            
      
 return l_lignum 
   
#-------------------------------------
end function # bdatm001_busca_lig   
#-------------------------------------

#---------------------------------------
function bdatm001_reg_lig_rcl()
#---------------------------------------

 define lr_param record 
     cgccpfnum        like datrligcgccpf.cgccpfnum,
     cgcord           like datrligcgccpf.cgcord,
     cgccpfdig        like datrligcgccpf.cgccpfdig,
     c24solnom        like datmligacao.c24solnom,
     motivo           like datkrcuccsmtv.rcuccsmtvcod,     
     dddcod            like datmreclam.dddcod,
     ctttel            like datmreclam.ctttel,
     faxnum            like datmreclam.faxnum,
     cttnom            like datmreclam.cttnom
      
 end record 
 
 define ws              record
        msgn            char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        ret             smallint,
        msg             varchar(80)                ,
        dddcod          like datmreclam.dddcod     ,
        ctttel          like datmreclam.ctttel     ,
        faxnum          like datmreclam.faxnum     ,
        cttnom          like datmreclam.cttnom     ,
        c24evtcod_rcl   like datkevt.c24evtcod     ,
        atdsrvnum_rcl   like datmservico.atdsrvnum ,
        atdsrvano_rcl   like datmservico.atdsrvano ,
        atdsrvorg_rcl   like datmservico.atdsrvorg ,
        c24txtseq       like datmlighist.c24txtseq ,
        confirma        char (01),
        funnom          like isskfunc.funnom       ,
        lintxt          like dammtrxtxt.c24trxtxt  ,
        lintxt1         like dammtrxtxt.c24trxtxt  ,
        hora            char (05)                  ,
        titulo          char (40)                  ,
        segnumdig       like gsakseg.segnumdig     ,
        segnom          like gsakseg.segnom        ,
        c24astdes       like datkassunto.c24astdes ,
        c24astcodslv    like datkassunto.c24astcod
 end record

 define l_xml char(32766) 
        ,l_data       date                                      
        ,l_hora1      datetime hour to second                     
        ,l_hora2      datetime hour to minute                            
  
  
  
  #----------------------------
  # Recebe Parametros do Xml 
  #----------------------------
  
  let lr_param.cgccpfnum    = g_paramval[1]
  let lr_param.cgcord       = g_paramval[2]
  let lr_param.cgccpfdig    = g_paramval[3]
  let lr_param.c24solnom    = g_paramval[4]
  let lr_param.motivo       = g_paramval[5]
  let lr_param.dddcod       = g_paramval[6]
  let lr_param.ctttel       = g_paramval[7]
  let lr_param.faxnum       = g_paramval[8]
  let lr_param.cttnom       = g_paramval[9]
  
  
  
  
  
  
  #-------------------------------
  # Setar paramentros fixos
  #-------------------------------
  
  if lr_param.cgcord is null then 
     let lr_param.cgcord = 0 
  end if   
  
  let g_documento.cgccpfnum     = lr_param.cgccpfnum
  let g_documento.cgcord        = lr_param.cgcord  
  let g_documento.cgccpfdig     = lr_param.cgccpfdig
  let g_crtdvgflg               = "S"
  let g_documento.c24astcod     = "O00"
  let g_documento.solnom        = lr_param.c24solnom  
  let g_issk.funmat             = 999999
  let g_issk.empcod             = 1
  let g_issk.usrtip             = "F"
  let g_documento.ciaempcod     = 40
  let g_documento.c24soltipcod  = 1
  let g_documento.rcuccsmtvcod  = lr_param.motivo
  
  
  
  
  
  
  
     
     while true 
     
      # -----------------------------------
      # Busca numeracao ligacao
      #------------------------------------
               
        begin work
      
        call cts10g03_numeracao( 1, "" ) # 1 - gera so ligacao
             returning ws.lignum   ,
                       ws.atdsrvnum,
                       ws.atdsrvano,
                       ws.codigosql,
                       ws.msg
      
        if  ws.codigosql = 0  then
            commit work
        else            
            rollback work                                 
            exit while
        end if
      
      let g_documento.lignum = ws.lignum 

      #--------------------------------------------------------------------------
      # Grava dados da ligacao
      #--------------------------------------------------------------------------
        call cts40g03_data_hora_banco(2)
             returning l_data, l_hora2
        let ws.hora  =  l_hora2                                                                   
  
        begin work
        call cts10g00_ligacao ( g_documento.lignum      ,
                                l_data                  ,
                                ws.hora                 ,
                                g_documento.c24soltipcod,
                                g_documento.solnom      ,
                                g_documento.c24astcod   ,
                                g_issk.funmat           ,
                                g_documento.ligcvntip   ,
                                g_c24paxnum             ,
                                "","", "","", "",""     ,
                                "",#g_documento.succod      ,
                                "",#g_documento.ramcod      ,
                                "",#g_documento.aplnumdig   ,
                                "",#g_documento.itmnumdig   ,
                                "",#g_documento.edsnumref   ,
                                "",#g_documento.prporg      ,
                                "",#g_documento.prpnumdig   ,
                                "",#g_documento.fcapacorg   ,
                                "",#g_documento.fcapacnum   ,
                                "",#g_documento.sinramcod   ,
                                "",#g_documento.sinano      ,
                                "",#g_documento.sinnum      ,
                                "",#g_documento.sinitmseq   ,
                                "","","",""             )
             returning ws.tabname,
                       ws.codigosql
        if  ws.codigosql <> 0  then
            rollback work
            exit while            
        end if
                
        #--------------------------------------------------------------------------
        # Grava dados do reclamante para contato futuro
        #--------------------------------------------------------------------------             
             insert into datmreclam ( lignum,
                               dddcod,
                               ctttel,
                               faxnum,
                               cttnom,
                               atdsrvnum,
                               atdsrvano)
                      values ( g_documento.lignum,
                               lr_param.dddcod,
                               lr_param.ctttel,
                               lr_param.faxnum,
                               lr_param.cttnom,
                               ws.atdsrvnum_rcl,
                               ws.atdsrvano_rcl)
             
             let ws.codigosql = sqlca.sqlcode
             let ws.tabname   = upshift(sqlca.sqlerrm)
                           
             if  ws.codigosql <> 0  then               
                 rollback work               
                 exit while
             end if  
          
             call cts40g03_data_hora_banco(1)
                  returning l_data, l_hora1
             insert into datmsitrecl ( lignum      ,
                                       c24rclsitcod,
                                       funmat      ,
                                       rclrlzdat   ,
                                       rclrlzhor    ,
                                       c24astcod    )
                              values ( g_documento.lignum    ,
                                       0            ,
                                       g_issk.funmat,
                                       l_data       ,
                                       l_hora1      ,
                                       g_documento.c24astcod)
             
             let ws.codigosql = sqlca.sqlcode
             let ws.tabname   = upshift(sqlca.sqlerrm)
             
             if  ws.codigosql <> 0  then               
                 rollback work               
                 exit while
             end if                      
          commit work
          exit while
    end while

     
    if ws.codigosql <> 0 then     
       return bdatm001_erro_lista_lig(ws.codigosql,ws.tabname)
    else 
      let l_xml =  "<?xml version='1.0' encoding='ISO-8859-1'?>",
                   "<RESPONSE>" , 
                   "<lignum>" , g_documento.lignum clipped,"  </lignum>" clipped,
                   "</RESPONSE>"       
    end if
    
    
    return l_xml                          

#-------------------------------------------
end function  #bdatm001_lig_rcl
#-------------------------------------------   
#-------------------------------------------
function bdatm001_motivos_rcl()
#--------------------------------------------
   
   
   define l_c24astcod     like datkassunto.c24astcod
         ,l_rcuccsmtvcod  like datkrcuccsmtv.rcuccsmtvcod
         ,l_rcuccsmtvdes  like datkrcuccsmtv.rcuccsmtvdes
         ,l_sql           char(500) 
         ,l_xml           char(5000)
         ,l_exist         smallint
         ,l_erro          integer
         ,l_msg           char(200)

    

    #-------------------------------------
    # inicializa Variaveis
    #-------------------------------------
    
    let l_c24astcod     = "O00" 
    let l_rcuccsmtvcod  = null 
    let l_rcuccsmtvdes  = null 
    let l_sql           = null 
    let l_exist         = false
    let l_erro          = null 
    let l_msg           = null 
   

    let l_sql = " select rcuccsmtvcod,      ",     
                "        rcuccsmtvdes       ",     
                "   from datkrcuccsmtv      ",     
                "  where rcuccsmtvstt = 'A' ",     
                "  and   c24astcod = ?      ",     
                "  order by 2,1             "      
    prepare pbdatm001023    from l_sql             
    declare cbdatm001023    cursor for pbdatm001023


    let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>",
                "<RESPONSE>"                                  
    
    open    cbdatm001023  using l_c24astcod             
    foreach cbdatm001023   into l_rcuccsmtvcod,
                                l_rcuccsmtvdes
    let l_exist = true 

           let l_xml = l_xml clipped, "<MOTIVOS>",
                                      "<rcuccsmtvcod>", l_rcuccsmtvcod clipped, "</rcuccsmtvcod>",   
                                      "<rcuccsmtvdes>", l_rcuccsmtvdes clipped, "</rcuccsmtvdes>",   
                                      "</MOTIVOS>"    
    
    end foreach
    
    let l_xml = l_xml clipped,                
                      "</RESPONSE>"
    
    
    if sqlca.sqlcode <> 0 then 
       let l_erro = sqlca.sqlcode 
       let l_msg  = upshift(sqlca.sqlerrm)
    end if    
    
    if l_exist = false then 
       let l_erro = 100 
       let l_msg  = "Assunto nao tem motivos cadastrados"
    end if    
    
    if l_erro is not null or 
       l_erro <> 0     then
       return bdatm001_erro_lista_lig(l_erro,l_msg)
    end if    
                     
     
return l_xml                                    

#----------------------------------------
end function   # bdatm001_motivos_rcl()
#----------------------------------------   
# Psi234788 Fim

#----------------------------------
function bdatm001_grava_historico()
#----------------------------------

 define lr_param          record
        lignum            like datmreclam.lignum,
        funmat            like isskfunc.funmat,
        empcod            like isskfunc.empcod,
        data              date,
        hora              char(08),
        atdsrvnum         like datmligacao.atdsrvnum,
        atdsrvano         like datmligacao.atdsrvano,
        qtdl              smallint
 end record

 define l_flag            smallint,
        l_str             char(5000),
        l_aux             char(25),
        l_ix1             smallint,
        l_ix2             smallint,
        l_texto           char(100),
        l_funnom          like isskfunc.funnom

 define al_texto          array[50] of record
        linha             char(50)
 end record

 define lr_hist           record
        #tipgrv            smallint,
        lignum            like datmlighist.lignum,
        c24funmat         like datmlighist.c24funmat,
        ligdat            like datmlighist.ligdat,
        lighorinc         like datmlighist.lighorinc,
        c24ligdsc         like datmlighist.c24ligdsc,
        c24empcod         like datmlighist.c24empcod,
        c24usrtip         like datmlighist.c24usrtip,
        atdsrvnum         like datmservhist.atdsrvnum,
        atdsrvano         like datmservhist.atdsrvano        
 end record

 define lr_retorno        record
        tabname           like systables.tabname,
        sqlcode           integer
 end record

 initialize lr_param.* to null
 initialize al_texto   to null

 let lr_param.lignum    = g_paramval[1]
 let lr_param.funmat    = g_paramval[2]
 let lr_param.empcod    = g_paramval[3]
 let lr_param.data      = g_paramval[4]
 let lr_param.hora      = g_paramval[5]
 let lr_param.atdsrvnum = g_paramval[6]
 let lr_param.atdsrvano = g_paramval[7] 
 let lr_param.qtdl      = g_paramval[8]

 let l_ix1 = 0

 for l_ix2 = 9 to 50
     let l_ix1 = l_ix1 + 1
     let al_texto[l_ix1].linha = g_paramval[l_ix2]
 end for

 let g_issk.usrtip = "F"
 let g_issk.empcod = 1

 let l_flag = 0

 let l_ix2 = lr_param.qtdl
 if l_ix2 is not null and l_ix2 > 0 then
    if l_ix2 > 50 then
       let l_ix2 = 50
    end if
    for l_ix1 = 1 to l_ix2
        initialize lr_hist.*    to null
        initialize lr_retorno.* to null
        #let lr_hist.tipgrv    = 1
        let lr_hist.lignum    = lr_param.lignum
        let lr_hist.c24funmat = lr_param.funmat
        let lr_hist.ligdat    = lr_param.data
        let lr_hist.lighorinc = lr_param.hora
        let lr_hist.atdsrvnum = lr_param.atdsrvnum
        let lr_hist.atdsrvano = lr_param.atdsrvano
        let lr_hist.c24ligdsc = al_texto[l_ix1].linha
        let lr_hist.c24empcod = lr_param.empcod
        #usrtip nao vem como parametro, e é necessario na insercao
        # da tabela datmlighist, por isso esta fixo
        let lr_hist.c24usrtip = "F"
        #call cts10g00_historico(lr_hist.*)
        #     returning lr_retorno.*
        
              
       if lr_hist.atdsrvnum is not null then                    
            call ctd07g01_ins_datmservhist(lr_hist.atdsrvnum,
                                           lr_hist.atdsrvano,
                                           lr_hist.c24funmat,
                                           lr_hist.c24ligdsc,
                                           lr_hist.ligdat,
                                           lr_hist.lighorinc,
                                           lr_hist.c24empcod,
                                           lr_hist.c24usrtip)
                             returning lr_retorno.sqlcode,
                                       lr_retorno.tabname
       else                                                   
          call ctd06g01_ins_datmlighist(lr_hist.lignum,
                                      lr_hist.c24funmat,
                                      lr_hist.c24ligdsc,
                                      lr_hist.ligdat,
                                      lr_hist.lighorinc,
                                      lr_hist.c24usrtip,
                                      lr_hist.c24empcod  )
             returning lr_retorno.sqlcode,  #retorno
                       lr_retorno.tabname   #mensagem
        end if                 
        #if lr_retorno.sqlcode <> 0 then
        if lr_retorno.sqlcode <> 1 then
           let l_flag = 1
           exit for
        end if
    end for
 end if

 if l_flag = 0 then
    let l_str = "<?xml version='1.0' encoding='ISO-8859-1'?>"
               ,"<servicos>OK</servicos>"
 else
    let l_str = "<?xml version='1.0' encoding='ISO-8859-1'?>"
               ,"<servicos>ERRO ATUALIZACAO CENTRAL 24H</servicos>"
 end if

 return l_str

end function

function bdatm001_identifica_cliente()


 
 define l_msgerro varchar(80)
       ,l_tpretorno  smallint
       ,l_retorno    char(32766)
 
 
 initialize param_xml.* to null 
 let l_msgerro = null 
 let l_tpretorno = null 
 let l_retorno = null 
 
 
  let param_xml.atdsrvnum   =  g_paramval[1] #"NUMERO"
  let param_xml.atdsrvano   =  g_paramval[2] #"ANO"
  let param_xml.placa       =  g_paramval[3] #"PLACA"
  let param_xml.cgccpfnum   =  g_paramval[4] #"CGCCPFNUM"
  let param_xml.cgcord      =  g_paramval[5] #"CGCORD"
  let param_xml.cgccpfdig   =  g_paramval[6] #"CGCCPFDIG"
  let param_xml.pestip      =  g_paramval[7] #"TIPOPESSOA"
  let param_xml.tp_retorno  =  g_paramval[8] #"RETORNO"
  
  display "2563 - param_xml.atdsrvnum  = ",param_xml.atdsrvnum 
  display "2564 - param_xml.atdsrvano  = ",param_xml.atdsrvano 
  display "2565 - param_xml.placa      = ",param_xml.placa     
  display "param_xml.cgccpfnum  = ",param_xml.cgccpfnum 
  display "param_xml.cgcord     = ",param_xml.cgcord    
  display "param_xml.cgccpfdig  = ",param_xml.cgccpfdig 
  display "param_xml.cpf        = ",param_xml.cpf       
  display "param_xml.pestip     = ",param_xml.pestip    
  display "param_xml.tp_retorno = ",param_xml.tp_retorno
  
 
  
  
  if param_xml.tp_retorno is null then
     if l_msgerro is not null then
        let l_msgerro = l_msgerro clipped ,', (RETORNO)'
     else
        let l_msgerro = 'PARAMETRO DE ENTRADA (RETORNO)'
     end if
  end if
        
  if l_msgerro is not null then
     let l_msgerro = l_msgerro clipped ,' NAO INFORMADO(S).'
     return ctf00m06_xmlerro(m_servico,1,l_msgerro)
  end if
      
      
  if param_xml.tp_retorno = "GARANTIA" then 
     let l_tpretorno = 90 
  else 
     let l_tpretorno = 30
  end if                     
                            
  if param_xml.atdsrvnum is not null then                            
          
     call cty05g08_busca_servico(param_xml.atdsrvnum,
                                 param_xml.atdsrvano,
                                 l_tpretorno)
          returning l_retorno                                                                        
   end if          
   
   if param_xml.placa is not null then 
      
      display "Placa"
      call cty05g08_busca_servico_por_placa(param_xml.placa,
                                            l_tpretorno)
           returning l_retorno
                      
   end if 
   
   if param_xml.cgccpfnum is not null then       
      
      display "CPF"
      
      if param_xml.pestip = 'F' then 
         let param_xml.cgcord = null
      end if 
      
      if param_xml.pestip is null or
         (param_xml.pestip <> 'F' and 
         param_xml.pestip <> 'J' ) then                                          
         
         let m_erro.servico = "IDENTIFICA CLIENTE"
         let m_erro.coderro = 2
         let m_erro.mens    = "PARAMETRO TIPO DE PESSOA INVALIDO"             
         call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
              returning l_retorno         
      else
            
          call cty05g08_busca_servico_por_cpf(param_xml.cgccpfnum,
                                          param_xml.cgcord,   
                                          param_xml.cgccpfdig,         
                                          param_xml.pestip,
                                          l_tpretorno)
              returning l_retorno                       
      end if         
   end if                          
   
   display "chamei retorno"   
   
   if l_retorno is null then 
       let m_erro.servico = "IDENTIFICA CLIENTE"                       
       let m_erro.coderro = 100                                        
       let m_erro.mens    = "NAO LOCALIZOU NENHUM SERVICO"             
       call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
            returning l_retorno
   end if                                            
      
   return l_retorno
   
end function 
   
   
function bdatm001_registra_retorno()

         
   define l_msgerro    varchar(80)
         ,l_tpretorno  smallint
         ,l_retorno    char(32766)
         ,l_index      integer
         ,l_grupo      integer
         ,l_grp_des    char(60) 
 
 
      initialize param_xml.* to null 
      let l_grupo   = null
      let l_grp_des = null
      
      for l_index = 1 to 10 
          initialize param_xml_multiplos[l_index].* to null 
      end for          
               
         let param_xml.atdsrvnum = g_paramval[1]#NUMERO
         let param_xml.atdsrvano = g_paramval[2]#ANO
         let param_xml.data      = g_paramval[3]#DATA
         let param_xml.hora      = g_paramval[4]#HORA
         let param_xml.retorno   = g_paramval[5]#RETORNO
         let param_xml.msmprest  = g_paramval[6]#MESMOPRESTADOR
         
         
         display "param_xml.atdsrvnum = ",param_xml.atdsrvnum
         display "param_xml.atdsrvano = ",param_xml.atdsrvano
         display "param_xml.data      = ",param_xml.data     
         display "param_xml.hora      = ",param_xml.hora     
         display "param_xml.retorno   = ",param_xml.retorno  
         display "param_xml.msmprest  = ",param_xml.msmprest 
         
         
         
         
         
         
             
         let l_msgerro = null
         if param_xml.atdsrvnum is null then
           let l_msgerro = 'PARAMETRO DE ENTRADA (/IDENTIFICACAOSERVICO/NUMERO)'
         end if
             
         if param_xml.atdsrvano is null then
            if l_msgerro is not null then
             let l_msgerro = l_msgerro clipped, ', (/IDENTIFICACAOSERVICO/ANO)'
            else
              let l_msgerro ='PARAMETRO DE ENTRADA (/IDENTIFICACAOSERVICO/ANO)'
            end if
         end if
             
         if param_xml.data is null then
            if l_msgerro is not null then
               let l_msgerro = l_msgerro clipped ,', (DATA)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (DATA)'
            end if
         end if
             
         if param_xml.hora is null then
            if l_msgerro is not null then
               let l_msgerro = l_msgerro clipped ,', (HORA)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (HORA)'
            end if
         end if
             
         if param_xml.retorno is null then
            if l_msgerro is not null then
               let l_msgerro = l_msgerro clipped ,', (RETORNO)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (RETORNO)'
            end if
         end if
             
         if param_xml.msmprest is null then
            if l_msgerro is not null then
               let l_msgerro = l_msgerro clipped ,', (MESMOPRESTADOR)'
            else
               let l_msgerro = 'PARAMETRO DE ENTRADA (MESMOPRESTADOR)'
            end if
         end if
             
         if l_msgerro is not null then
            let l_msgerro = l_msgerro clipped ,' NAO INFORMADO(S).'
            return ctf00m06_xmlerro(m_servico,1,l_msgerro)
         end if
             
         let g_documento.atdsrvnum = param_xml.atdsrvnum
         let g_documento.atdsrvano = param_xml.atdsrvano
         let g_documento.acao      = 'RET'
         let g_origem                 = "WEB"         # Portal do Segurado
         let g_documento.solnom       = "PORTAL VOZ"
         let g_issk.funmat            = 999999
         let g_issk.empcod            = 1
         let g_issk.usrtip            = "F"
         let g_documento.ligcvntip    = 0
         let g_c24paxnum              = 0
         let g_documento.c24soltipcod = 1             # Segurado
         let g_documento.soltip       = "S"           # Segurado
         let g_documento.atdsrvorg    = 9
         let g_documento.crtsaunum    = null
         let g_documento.prporg       = null
         let g_documento.prpnumdig    = null
         let g_documento.fcapacorg    = null
         let g_documento.fcapacnum    = null
             
         call ctf00m01_copia()
              returning l_retorno
                       ,param_xml.logtip
                       ,param_xml.lognom
                       ,param_xml.lognum
                       ,param_xml.bairro
                       ,param_xml.cidnom
                       ,param_xml.ufdcod
                       ,param_xml.lclrefptotxt
                       ,param_xml.endzon
                       ,param_xml.lgdcep
                       ,param_xml.lgdcepcmp
                       ,param_xml.lclcttnom
                       ,param_xml.dddcod
                       ,param_xml.lcltelnum
                       ,param_xml.orrdat
                       ,param_xml_multiplos[1].socntzcod
                       ,param_xml_multiplos[1].espcod
                       ,param_xml_multiplos[1].c24pbmgrpcod
             
         display "param_xml_multiplos[1].socntzcod    ",param_xml_multiplos[1].socntzcod   
         display "param_xml_multiplos[1].espcod       ",param_xml_multiplos[1].espcod      
         display "param_xml_multiplos[1].c24pbmgrpcod ",param_xml_multiplos[1].c24pbmgrpcod
         
         if l_retorno is null then
             
            if param_xml.retorno = 'COMPLEMENTO' then
               let param_xml.srvretmtvcod = 1
               let param_xml.srvretmtvdes ='COMPLEMENTO DO ATENDIMENTO ORIGINAL'
            else
               if param_xml.retorno = 'GARANTIA' then
                  let param_xml.srvretmtvcod = 2
                  let param_xml.srvretmtvdes='PROBLEMAS NO ATENDIMENTO ORIGINAL'
               end if
            end if
             
            if param_xml.msmprest = 'SIM' then
               let param_xml.retprsmsmflg = 'S'
            else
               if param_xml.msmprest = 'NAO' then
                  let param_xml.retprsmsmflg = 'N'
               end if
            end if
             
            let lr_aux.lignum = cts20g00_servico(g_documento.atdsrvnum
                                                ,g_documento.atdsrvano)
             
            display "1757"
            select c24astcod
              into lr_aux.c24astcod
              from datmligacao
             where lignum     = lr_aux.lignum
               and c24astcod in ('S60','S63','S62','S64')
             
            
           call cty05g08_busca_grupo(param_xml.atdsrvnum,
                                     param_xml.atdsrvano)
                returning l_grp_des,l_grupo                                     
            
            if l_grupo is not null then 
               let param_xml.srvrglcod = l_grupo 
            end if    
            
            
            #if lr_aux.c24astcod = 'S62' or 
            #   lr_aux.c24astcod = 'S64' then 
            #   
            #   
            #   
            #   
            #else    
            #   if lr_aux.c24astcod = 'S63' then
            #      let param_xml.srvrglcod =  1
            #   else
            #      if lr_aux.c24astcod = 'S60' then                                         
            #         let param_xml.srvrglcod = 2
            #      end if
            #   end if
            #end if    
            
            
            
             
            display "Chamei cty05g10 "
            let l_retorno = cty05g10_grava_dados("RET"            # c24astcod
                                                ,param_xml.data
                                                ,param_xml.hora
                                                ,param_xml.logtip
                                                ,param_xml.lognom
                                                ,param_xml.lognum
                                                ,param_xml.bairro
                                                ,param_xml.cidnom
                                                ,param_xml.ufdcod
                                                ,param_xml.lclrefptotxt
                                                ,param_xml.endzon
                                                ,param_xml.lgdcep
                                                ,param_xml.lgdcepcmp
                                                ,param_xml.lclcttnom
                                                ,param_xml.dddcod
                                                ,param_xml.lcltelnum
                                                ,param_xml.srvrglcod
                                                ,param_xml.atdsrvnum #Retorno (inicio)
                                                ,param_xml.atdsrvano #atdsrvano
                                                ,"RET" --> param_xml.acao
                                                ,param_xml.srvretmtvcod
                                                ,param_xml.srvretmtvdes
                                                ,param_xml.retprsmsmflg
                                                ,param_xml.orrdat    #Retorno (fim)
                                                ,param_xml_multiplos[1].*
                                                ,param_xml_multiplos[2].*
                                                ,param_xml_multiplos[3].*
                                                ,param_xml_multiplos[4].*
                                                ,param_xml_multiplos[5].*
                                                ,param_xml_multiplos[6].*
                                                ,param_xml_multiplos[7].*
                                                ,param_xml_multiplos[8].*
                                                ,param_xml_multiplos[9].*
                                                ,param_xml_multiplos[10].*)
                                                
          display "l_retorno = ",l_retorno clipped                                                
                                                
                                                
         end if   
         
 return l_retorno         
         
end function                

function bdatm001_lista_agenda()
           
      define l_retorno    char(32766),
             l_socntzgrpcod  like datksocntzgrp.socntzgrpcod
       
            
      let l_retorno = null       
     
           let param_xml.atdsrvnum = g_paramval[1] #NUMERO
           let param_xml.atdsrvano = g_paramval[2] #ANO
           let param_xml.cidnom    = g_paramval[3] #CIDADE/NOME
           let param_xml.ufdcod    = g_paramval[4] #CIDADE/UF
           let param_xml.socntzdes = g_paramval[5] #GRUPOTIPOSERVICO
           
           
           display "param_xml.atdsrvnum = ",param_xml.atdsrvnum
           display "param_xml.atdsrvano = ",param_xml.atdsrvano
           display "param_xml.cidnom    = ",param_xml.cidnom   
           display "param_xml.ufdcod    = ",param_xml.ufdcod   
           display "param_xml.socntzdes = ",param_xml.socntzdes
           
           
                                   
           if param_xml.socntzdes is null then 
              call cty05g08_busca_grupo(param_xml.atdsrvnum,
                                        param_xml.atdsrvano)
                   returning param_xml.socntzdes,l_socntzgrpcod  
           end if                                 
                                 
           display "param_xml.socntzdes = ",param_xml.socntzdes
           
           
           let l_retorno =  cty05g09_ListarAgenda(param_xml.cidnom   ,
                                                  param_xml.ufdcod   ,
                                                  param_xml.socntzdes,
                                                  param_xml.atdsrvnum,
                                                  param_xml.atdsrvano)                  
      

return l_retorno

end function 
  
  
  
  
  
         
         
         