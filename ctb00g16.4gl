#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
# ........................................................................... #
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctb00g16                                                    #
# Analista Resp.: Beatriz Araujo                                              #
# PSI...........: PSI-2012-00287/EV                                           #
# Objetivo......: Interface de integracao do Porto Socorro com a Contabilidade#
#                 para envio do provisionamento de servico ao PEOPLE          #
#.............................................................................#
# Desenvolvimento: Beatriz Araujo                                             #
# Liberacao......: 13/02/2012                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica    PSI          Alteracao                          #
# --------   ---------------  -----------  ---------------------------------- # 
# 12/11/14   Rodolfo Massini  14-19758/PR  Alteracoes para o projeto "Entrada #
#                                          Camada Contabil"                   #
#-----------------------------------------------------------------------------#
database porto

 define m_ctb00g16_prep smallint
 
#-------------------------#
function ctb00g16_prepare()
#-------------------------#

  define l_sql char(1000)
  
   let l_sql = "select srvdcrcod, ",
               "       bemcod, ",
               "       atoflg ",
               "  from datkdcrorg",                  
               " where atdsrvorg = ?",
               "   and c24astcod = ?"
   prepare pctb00g16001 from l_sql                 
   declare cctb00g16001 cursor for pctb00g16001 
   
   let l_sql = "select srvdcrcod, ",
               "       bemcod, ",
               "       atoflg ",
               "  from datkalgmtv",                  
               " where atdsrvorg = ?",
               "   and ciaempcod = ?",
               "   and avialgmtv = ?"
   prepare pctb00g16002 from l_sql                 
   declare cctb00g16002 cursor for pctb00g16002
   
   
   let l_sql =   "select a.itaasstipcod,                    ",
                 "       a.c24astagp,                       ",
                 "       a.c24astcod,                       ",
                 "       a.c24astdes                        ",
                 "  from datkassunto a,                     ",
                 "       datmligacao b                      ",
                 " where a.c24astcod = b.c24astcod          ",
                 "   and b.lignum = (select min(d.lignum)   ",
                 "                     from datmligacao d   ",
                 "                    where d.atdsrvnum = ? ",
                 "                      and d.atdsrvano = ?)"
   prepare pctb00g16003 from l_sql                
   declare cctb00g16003 cursor for pctb00g16003 
   
   let l_sql = " select ciaempcod ",
               " from datmservico ",
               " where atdsrvnum = ? ",
               "   and atdsrvano = ? "
   prepare pctb00g16004 from l_sql
   declare cctb00g16004 cursor for pctb00g16004
   
   let l_sql = " select atdsrvorg ",
               " from datmservico ",
               " where atdsrvnum = ? ",
               "   and atdsrvano = ? "
   prepare pctb00g16005 from l_sql
   declare cctb00g16005 cursor for pctb00g16005
   
   
   let l_sql = "select a.avialgmtv,            ",
               "       b.ciaempcod             ",
               " from datmavisrent a,          ",
               "      datmservico b            ",
               "where a.atdsrvnum = b.atdsrvnum",
               "  and a.atdsrvano = b.atdsrvano",
               "  and a.atdsrvnum = ?          ",
               "  and a.atdsrvano = ?          "
   prepare pctb00g16006 from l_sql             
   declare cctb00g16006 cursor for pctb00g16006
   
   let l_sql = "select b.pgttipcodps   ",
               "  from dbscadtippgt b  ",
               " where b.nrosrv = ?    ",
               "   and b.anosrv = ?    " 
               
   prepare pctb00g16007 from l_sql             
   declare cctb00g16007 cursor for pctb00g16007
   
   let l_sql = " select 1                                                ",                            
                "   from datmservico srv,                                ", 
                "        datmcntsrv  ctg                                 ", 
                " where srv.atdsrvnum = ctg.atdsrvnum                    ", 
                "   and srv.atdsrvano = ctg.atdsrvano                    ", 
                "   and not exists ( select atdsrvnum                    ", 
                "                       from datrservapol doc            ", 
                "                    where doc.atdsrvnum = srv.atdsrvnum ", 
                "                      and doc.atdsrvano = srv.atdsrvano)", 
                "   and srv.atdsrvnum = ?                                ", 
                "   and srv.atdsrvano = ?                                "
   prepare pctb00g16008 from l_sql
   declare cctb00g16008 cursor for pctb00g16008 
   
   let l_sql = "select a.atdsrvorg,   ",                
                "      c.itaasstipcod, ",
                "      b.c24astcod    ",
                "  from datmservico a, ",
                "       datmligacao b, ",
                "       datkassunto c  ",
                " where a.atdsrvnum = b.atdsrvnum ",
                "   and a.atdsrvano = b.atdsrvano ",
                "   and b.lignum = (select min(lignum) ",
                "                     from datmligacao ",
                "                    where atdsrvnum = a.atdsrvnum  ",
                "                      and atdsrvano = a.atdsrvano) ",
                "   and c.c24astcod = b.c24astcod                   ",
                "   and a.atdsrvnum = ?                             ",
                "   and a.atdsrvano = ?                             "
    prepare pctb00g16009 from l_sql             
    declare cctb00g16009 cursor for pctb00g16009
    
    
    
    let l_sql = "insert into dbsmatdpovhst (atdsrvnum,atdsrvano,   ",
                "                           regiclhrrdat,evntipcod,",
                "                           ctbpezcod,srvvlr)      ",
                "                    values(?,?,?,?,?,?)           "                                     
    prepare pctb00g16010 from l_sql
    
    
    let l_sql = " select a.avivclcod,  ",
                "        b.lcvlojtip,  ",
                "        b.lcvregprccod,",
                "        b.lcvcod, ",
                "        a.aviprvent,",
                "        a.avivclvlr",
                "   from datmavisrent a,",
                "        datkavislocal b",
                "  where a.aviestcod = b.aviestcod",  
                "    and a.atdsrvnum = ?",
                "    and a.atdsrvano = ?"
    
    prepare pctb00g16011 from l_sql
    declare cctb00g16011 cursor for pctb00g16011
    
    let l_sql = "  select prtsgrvlr, ",
                "         diafxovlr "
               ,"    from  datklocaldiaria  "
               ,"   where avivclcod    = ? "
               ,"     and lcvlojtip    = ? "
               ,"     and lcvregprccod = ? "
               ,"     and lcvcod       = ? "
               ,"     and ? between viginc and vigfnl "
               ,"     and ? between fxainc and fxafnl "

    prepare pctb00g16012 from l_sql
    declare cctb00g16012 cursor for pctb00g16012
    
    ### // Selecionar dados do serviço //                             
    let l_sql = " select atdsrvorg,  ",
                "        atddat,     ",
                "        pgtdat,     ",
                "        atdprscod,  ",
                "        asitipcod,  ",
                "        vclcoddig,  ",
                "        socvclcod,  ",
                "        ciaempcod   ",
                "  from  datmservico ",                             
                "where atdsrvnum = ?",                             
                "  and atdsrvano = ?"                             
                                                                      
    prepare pctb00g16013 from l_sql                                   
    declare cctb00g16013 cursor for pctb00g16013
    
    
    ### // Seleciona o grupo tarifário do veículo acionado //  
    let l_sql = " select vclcoddig "                           
               ,"  from datkveiculo "                          
               ," where socvclcod = ? "                        
    prepare pctb00g16014 from l_sql                            
    declare cctb00g16014 cursor for pctb00g16014               
    
    
    let l_sql = "select ctbevnpamcod,     ",
                "       srvpovevncod,     ",
                "       srvajsevncod,     ",
                "       srvbxaevncod,     ",
                "       srvpgtevncod      ",
                "  from dbskctbevnpam     ",
                " where empcod       = ?  ",
                "   and pcpsgrramcod = ?  ",
                "   and pcpsgrmdlcod = ?  ",
                "   and ctbsgrramcod = ?  ",
                "   and ctbsgrmdlcod = ?  ",
                "   and pgoclsflg    = ?  ",
                "   and srvdcrcod    = ?  ",
                "   and itaasstipcod = ?  ",
                "   and bemcod       = ?  ",
                "   and srvatdctecod = ?  ",
                "   and c24astagp    = ?  ",
                "   and clscod       = ?  ",
                "   and c24astcod    = ?  ",
                "   and atopamflg    = 'A'"
    prepare pctb00g16015 from l_sql                            
    declare cctb00g16015 cursor for pctb00g16015
    
    
    #let l_sql = "select ctbevnpamcod,     ",
    #            "       srvpovevncod,     ",
    #            "       srvajsevncod,     ",
    #            "       srvbxaevncod      ",
    #            "  from dbskctbevnpam     ",
    #            " where empcod       = ?  ",
    #            "   and pcpsgrramcod = ?  ",
    #            "   and pcpsgrmdlcod = ?  ",
    #            "   and ctbsgrramcod = ?  ",
    #            "   and ctbsgrmdlcod = ?  ",
    #            "   and pgoclsflg    = ?  ",
    #            "   and srvdcrcod    = ?  ",
    #            "   and itaasstipcod = ?  ",
    #            "   and bemcod       = ?  ",
    #            "   and srvatdctecod = ?  ",
    #            "   and c24astagp    = 'ZZZ'",
    #            "   and atopamflg    = 'A'"
    #prepare pctb00g16016 from l_sql                            
    #declare cctb00g16016 cursor for pctb00g16016 
    
    
    let l_sql = "select a.ctbpezcod,    ",
                "       a.regiclhrrdat, ",
                "       a.srvvlr        ",
                "  from dbsmatdpovhst a ",
                " where a.atdsrvnum = ? ",
                "   and a.atdsrvano = ? ",
                "   and a.regiclhrrdat = ( select max(b.regiclhrrdat)  ",
                                            "from dbsmatdpovhst b ",
                                           "where b.atdsrvnum = a.atdsrvnum ", 
                                           "  and b.atdsrvano = a.atdsrvano ",
                                           "  and b.evntipcod = ?)"
    prepare pctb00g16017 from l_sql                            
    declare cctb00g16017 cursor for pctb00g16017
    
    
    let l_sql = "select sum(srvvlr)        ",
                "  from dbsmatdpovhst  ",
                " where atdsrvnum = ? ",
                "   and atdsrvano = ? ",
                "   and regiclhrrdat >= ?"
    prepare pctb00g16018 from l_sql                            
    declare cctb00g16018 cursor for pctb00g16018
    
    
    let l_sql = "select ctbevnpamcod, ",
                "       srvpovevncod, ",
                "       srvajsevncod, ",
                "       srvbxaevncod, ",
                "       empcod      , ",
                "       pcpsgrramcod, ",
                "       pcpsgrmdlcod, ",
                "       ctbsgrramcod, ",
                "       ctbsgrmdlcod, ",
                "       pgoclsflg   , ",
                "       srvdcrcod   , ",
                "       itaasstipcod, ",
                "       bemcod      , ",
                "       srvatdctecod, ",
                "       c24astagp   , ",
                "       atopamflg     ", 
                "  from dbskctbevnpam ",
                " where ctbevnpamcod = ? "
    prepare pctb00g16019 from l_sql                            
    declare cctb00g16019 cursor for pctb00g16019
    
    
    let l_sql = "select sum(srvvlr)   ", 
                "  from dbsmatdpovhst ",
                " where atdsrvnum = ? ",
                "   and atdsrvano = ? "
    prepare pctb00g16020 from l_sql              
    declare cctb00g16020 cursor for pctb00g16020 
    
    
    
    let l_sql = "select srvajsevncod,  ",
                "       srvpgtevncod,  ", 
                "       srvpovevncod,  ", 
                "       srvatdctecod   ", 
                "from  dbskctbevnpam   ",
                "where ctbevnpamcod =? "
    prepare pctb00g16021 from l_sql              
    declare cctb00g16021 cursor for pctb00g16021 
    
    
    let l_sql = "select cctcod,",
                "       succod ",
                "  from dbscadtippgt",       
                " where nrosrv = ?",       
                "   and anosrv = ?"        
                                                 
    prepare pctb00g16022 from l_sql              
    declare cctb00g16022 cursor for pctb00g16022 
     
    
    
    let l_sql = "update dbsmatdpovhst ",
                "set cctcod = ?" ,
                "where atdsrvnum = ?",                
                "and atdsrvano = ?"             
    
    prepare pctb00g16023 from l_sql  
     
  let m_ctb00g16_prep = true

end function


#-------------------------#  
 function ctb00g16_incprvdsp(param)  
#-------------------------#  
define param record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    tipo           smallint # tipo do retorno
end record

 define lr_servico record
    srvdcrcod    like datkdcrorg.srvdcrcod,
    bemcod       like datkdcrorg.bemcod   ,
    atoflg       like datkdcrorg.atoflg   ,
    itaasstipcod like datkassunto.itaasstipcod, 
    ciaempcod    like datmservico.ciaempcod,
    avialgmtv    like datmavisrent.avialgmtv
  end record
 
  define lr_apolice record
    succod       like datrservapol.succod    , 
    ramcod       like datrservapol.ramcod    , 
    modalidade   like rsamseguro.rmemdlcod   , 
    aplnumdig    like datrservapol.aplnumdig , 
    itmnumdig    like datrservapol.itmnumdig ,
    edsnumref    like datrservapol.edsnumref ,            
    prporg       like datrligprp.prporg      ,  
    prpnumdig    like datrligprp.prpnumdig   ,
    corsus       like abamcor.corsus     
  end record
 
 define lr_ctb00g16_info record
    erro         smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
    msgerro      char(10000),
    srvdcrcod    like datkdcrorg.srvdcrcod,
    bemcod       like datkdcrorg.bemcod   ,
    atoflg       like datkdcrorg.atoflg   ,
    itaasstipcod like datkassunto.itaasstipcod,
    c24astagp    like datkassunto.c24astagp,
    c24astcod    like datkassunto.c24astcod,
    c24astdes    like datkassunto.c24astdes
 end record
 
 define lr_cts00g09_ramo record 
    ctbramcod  like rsatdifctbramcvs.ctbramcod, 
    ctbmdlcod  like rsatdifctbramcvs.ctbmdlcod,  
    clscod     like rsatdifctbramcvs.clscod,
    pgoclsflg  like dbskctbevnpam.pgoclsflg     
 end record  
 
 define lr_carteira record
    erro          smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
    msgerro       char(300),
    srvatdctecod  like dbskctbevnpam.srvatdctecod,
    pgoclsflg     like dbskctbevnpam.pgoclsflg
  end record
 
 define lr_retorno record
    erro         smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
    msgerro      char(20000)
 end record
 
 define lr_ctb00g16_evento record
     srvpovevncod  like dbskctbevnpam.srvpovevncod,
     srvajsevncod  like dbskctbevnpam.srvajsevncod,
     srvbxaevncod  like dbskctbevnpam.srvbxaevncod,
     srvpgtevncod  like dbskctbevnpam.srvpgtevncod,
     ctbevnpamcod  like dbskctbevnpam.ctbevnpamcod
  end record  
 
 
 define l_srvvlr like dbsmatdpovhst.srvvlr
 
 define l_msgerro char(20000)   
 
 initialize lr_apolice.* to null
 initialize lr_servico.* to null 
 initialize lr_carteira.* to null   
 initialize lr_retorno.* to null  
 initialize lr_ctb00g16_info.* to null 
 initialize lr_cts00g09_ramo.* to null 
 initialize lr_ctb00g16_evento.* to null
 
 let l_srvvlr = null
 let l_msgerro = null  
 
 if m_ctb00g16_prep is null or
    m_ctb00g16_prep <> true then
    call ctb00g16_prepare()
 end if
 
   
   # Busca empresa do servico
   whenever error continue
      open cctb00g16004 using param.atdsrvnum, 
                              param.atdsrvano
      
      fetch cctb00g16004 into lr_servico.ciaempcod
      
      close cctb00g16004
   whenever error stop
   
   # Busca Apólice do Servico
   display "Verifica ramo contabil do servico"
   call cts00g09_apolice(param.atdsrvnum, 
                         param.atdsrvano,
                         4, # tipo de retorno
                         lr_servico.ciaempcod,
                         0) # tipo da OP - Como nao tem coloca zero
     returning lr_apolice.succod,    
               lr_apolice.ramcod,    
               lr_apolice.modalidade,
               lr_apolice.aplnumdig, 
               lr_apolice.itmnumdig, 
               lr_apolice.edsnumref, 
               lr_apolice.prporg,    
               lr_apolice.prpnumdig,
               lr_apolice.corsus
                 

   # busca a informacao de decorrencia do servico, bem atendido e para quem o servico foi prestado
   call ctb00g16_info_serv(param.atdsrvnum,param.atdsrvano)
      returning lr_ctb00g16_info.erro         ,
                lr_ctb00g16_info.msgerro      ,
                lr_ctb00g16_info.srvdcrcod    ,
                lr_ctb00g16_info.bemcod       ,
                lr_ctb00g16_info.atoflg       ,
                lr_ctb00g16_info.itaasstipcod ,
                lr_ctb00g16_info.c24astagp    ,
                lr_ctb00g16_info.c24astcod    ,
                lr_ctb00g16_info.c24astdes    ,
                lr_servico.avialgmtv
                
    display "info.erro: ", lr_ctb00g16_info.erro
      
   
    if lr_ctb00g16_info.erro <> 0 then
         if lr_retorno.msgerro is null then
            let lr_retorno.msgerro = "Foram encontrados os seguintes erros para o servico ",
                                     param.atdsrvnum,'-',param.atdsrvano,": ",ASCII(13),
                                     ASCII(09),lr_ctb00g16_info.msgerro clipped,ASCII(13)
         else
            let lr_retorno.msgerro = lr_retorno.msgerro clipped,
                                     ASCII(09),lr_ctb00g16_info.msgerro clipped,ASCII(13)
         end if 
    end if
    
     #busca o ramo contabil para o servico
    call cts00g09_ramocontabil(param.atdsrvnum,param.atdsrvano,lr_apolice.modalidade,lr_apolice.ramcod)
       returning lr_cts00g09_ramo.ctbramcod,
                 lr_cts00g09_ramo.ctbmdlcod,
                 lr_cts00g09_ramo.clscod,
                 lr_cts00g09_ramo.pgoclsflg   
                 
    display "ramo.pgoclsflg: ", lr_cts00g09_ramo.pgoclsflg
    display "return cts00g09_ramocontabil: ", lr_cts00g09_ramo.clscod
       
       
       if lr_cts00g09_ramo.pgoclsflg <> 'N' and
          lr_cts00g09_ramo.pgoclsflg <> 'S' and
          lr_cts00g09_ramo.pgoclsflg <> 'B' then
          if lr_retorno.msgerro is null then
            let lr_retorno.msgerro = "Foram encontrados os seguintes erros para o servico ",
                                     param.atdsrvnum,'-',param.atdsrvano,": ",ASCII(13),
                                     ASCII(09),"Nao foi identifica se a clausula eh gratuita ou nao, colocamos N!",ASCII(13)
         else
            let lr_retorno.msgerro = lr_retorno.msgerro clipped,
                                     ASCII(09),"Nao foi identifica se a clausula eh gratuita ou nao, colocamos N!",ASCII(13)
         end if 
         let lr_cts00g09_ramo.pgoclsflg = 'N'
       end if 
       
    display "ramo.clscod: ", lr_cts00g09_ramo.clscod
    display "msgerro: ", lr_retorno.msgerro
       
       if lr_cts00g09_ramo.clscod is null or lr_cts00g09_ramo.clscod = ' ' then
          if lr_retorno.msgerro is null then
            let lr_retorno.msgerro = "Foram encontrados os seguintes erros para o servico ",
                                     param.atdsrvnum,'-',param.atdsrvano,": ",ASCII(13),
                                     ASCII(09),"Nao foi identifica a clausula do atendimento!",ASCII(13)
         else
            let lr_retorno.msgerro = lr_retorno.msgerro clipped,
                                     ASCII(09),"Nao foi identifica a clausula do atendimento!",ASCII(13)
         end if 
         let lr_cts00g09_ramo.clscod = 0
       end if 
       
    call  ctb00g16_srvcarteira(param.atdsrvnum,
                               param.atdsrvano,
                               lr_servico.ciaempcod,
                               lr_apolice.aplnumdig,
                               lr_apolice.prpnumdig)
        returning lr_carteira.erro   ,     
                  lr_carteira.msgerro, 
                  lr_carteira.srvatdctecod
                  
    display "msgerro: ", lr_carteira.msgerro
        
        if lr_carteira.erro <> 0 then
           if lr_retorno.msgerro is null then
              let lr_retorno.msgerro = "Foram encontrados os seguintes erros para o servico ",
                                       param.atdsrvnum,'-',param.atdsrvano,": ",ASCII(13),
                                       ASCII(09),lr_carteira.msgerro clipped,ASCII(13)
           else
              let lr_retorno.msgerro = lr_retorno.msgerro clipped, 
                                       ASCII(09),lr_carteira.msgerro clipped,ASCII(13)
           end if 
        end if     
        
        display "entrada ctb00g16_contabilizacao"
        display "ciaempcod: ", lr_servico.ciaempcod
        display "ramcod: ", lr_apolice.ramcod
        display "modalidade: ", lr_apolice.modalidade
        display "ctbramcod: ", lr_cts00g09_ramo.ctbramcod
        display "ctbmdlcod: ", lr_cts00g09_ramo.ctbmdlcod
        display "pgoclsflg: ", lr_cts00g09_ramo.pgoclsflg
        display "srvdcrcod: ", lr_ctb00g16_info.srvdcrcod
        display "itaasstipcod: ", lr_ctb00g16_info.itaasstipcod
        display "bemcod: ", lr_ctb00g16_info.bemcod
        display "srvatdctecod: ", lr_carteira.srvatdctecod
        display "c24astagp: ", lr_ctb00g16_info.c24astagp
        display "c24astcod: ", lr_ctb00g16_info.c24astcod
        display "clscod: ", lr_cts00g09_ramo.clscod
        
        
    call ctb00g16_contabilizacao(lr_servico.ciaempcod,
                                 lr_apolice.ramcod,
                                 lr_apolice.modalidade,
                                 lr_cts00g09_ramo.ctbramcod, 
                                 lr_cts00g09_ramo.ctbmdlcod,
                                 lr_cts00g09_ramo.pgoclsflg,
                                 lr_ctb00g16_info.srvdcrcod,
                                 lr_ctb00g16_info.itaasstipcod,
                                 lr_ctb00g16_info.bemcod,
                                 lr_carteira.srvatdctecod,
                                 lr_ctb00g16_info.c24astagp,
                                 lr_ctb00g16_info.c24astcod,
                                 lr_cts00g09_ramo.clscod)
      returning l_msgerro,
                lr_ctb00g16_evento.ctbevnpamcod,
                lr_ctb00g16_evento.srvpovevncod,
                lr_ctb00g16_evento.srvajsevncod,
                lr_ctb00g16_evento.srvbxaevncod,
                lr_ctb00g16_evento.srvpgtevncod
                
    display "l_msgerro: ", l_msgerro
    display "return ctb00g16_contabilizacao" 
    display "ctbevnpamcod: ", lr_ctb00g16_evento.ctbevnpamcod
    display "srvpovevncod: ", lr_ctb00g16_evento.srvpovevncod
    display "srvajsevncod: ", lr_ctb00g16_evento.srvajsevncod
    display "srvbxaevncod: ", lr_ctb00g16_evento.srvbxaevncod
    display "srvpgtevncod: ", lr_ctb00g16_evento.srvpgtevncod
      
    if l_msgerro is not null then
        
        if lr_retorno.msgerro is null then
           let lr_retorno.msgerro = "Foram encontrados os seguintes erros para o servico ",
                                    param.atdsrvnum,'-',param.atdsrvano,": ",ASCII(13),
                                    ASCII(09),l_msgerro clipped,ASCII(13)
        else
           let lr_retorno.msgerro = lr_retorno.msgerro clipped, 
                                    ASCII(09),l_msgerro clipped,ASCII(13)
        end if 
    end if  
    
    call ctb00g16_srvvlrprv(param.atdsrvnum, param.atdsrvano)
           returning l_srvvlr
       display "l_srvvlr: ",l_srvvlr
        
    if lr_retorno.msgerro is null then 
       call ctb00g16_incsrvtipprv(param.atdsrvnum,
                                  param.atdsrvano,
                                  1,lr_ctb00g16_evento.ctbevnpamcod,l_srvvlr)
    end if 
    
    display "Numero servico               : ",param.atdsrvnum,'-',param.atdsrvano
    display "lr_ctb00g16_info.srvdcrcod   : ",lr_ctb00g16_info.srvdcrcod    
    display "lr_ctb00g16_info.bemcod      : ",lr_ctb00g16_info.bemcod       
    display "lr_ctb00g16_info.atoflg      : ",lr_ctb00g16_info.atoflg       
    display "lr_ctb00g16_info.itaasstipcod: ",lr_ctb00g16_info.itaasstipcod 
    display "lr_ctb00g16_info.c24astagp   : ",lr_ctb00g16_info.c24astagp
    display "lr_ctb00g16_info.c24astcod   : ",lr_ctb00g16_info.c24astcod
    display "lr_carteira.srvatdctecod     : ",lr_carteira.srvatdctecod          
    display "lr_cts00g09_ramo.ctbramcod   : ",lr_cts00g09_ramo.ctbramcod    
    display "lr_cts00g09_ramo.ctbmdlcod   : ",lr_cts00g09_ramo.ctbmdlcod    
    display "lr_cts00g09_ramo.clscod      : ",lr_cts00g09_ramo.clscod       
    
    case param.tipo
    
       when 1
          return lr_ctb00g16_info.srvdcrcod     ,              
                 lr_ctb00g16_info.bemcod        ,              
                 lr_ctb00g16_info.atoflg        ,          
                 lr_ctb00g16_info.itaasstipcod  ,          
                 lr_ctb00g16_info.c24astagp     ,          
                 lr_ctb00g16_info.c24astcod     ,
                 lr_ctb00g16_info.c24astdes     ,        
                 lr_carteira.srvatdctecod       ,            
                 lr_cts00g09_ramo.ctbramcod     ,          
                 lr_cts00g09_ramo.ctbmdlcod     ,          
                 lr_cts00g09_ramo.clscod        , 
                 lr_cts00g09_ramo.pgoclsflg     ,          
                 lr_ctb00g16_evento.ctbevnpamcod,           
                 lr_ctb00g16_evento.srvpovevncod,          
                 lr_ctb00g16_evento.srvajsevncod,              
                 lr_ctb00g16_evento.srvbxaevncod,
                 lr_ctb00g16_evento.srvpgtevncod,              
                 lr_apolice.succod              ,              
                 lr_apolice.ramcod              ,              
                 lr_apolice.modalidade          ,          
                 lr_apolice.aplnumdig           ,           
                 lr_apolice.itmnumdig           ,           
                 lr_apolice.edsnumref           ,           
                 lr_apolice.prporg              ,           
                 lr_apolice.prpnumdig           ,          
                 lr_retorno.msgerro             ,          
                 l_srvvlr                       ,
                 lr_servico.avialgmtv           ,
                 lr_apolice.corsus
       
       otherwise        
          return lr_retorno.msgerro,
                 l_srvvlr
            
    end case 
                
end function                                         
                                                     
#-------------------------#
function ctb00g16_info_serv(param)
#-------------------------#
 define param record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano 
  end record
 
 define lr_retorno record
    erro         smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
    msgerro      char(10000),
    srvdcrcod    like datkdcrorg.srvdcrcod,
    bemcod       like datkdcrorg.bemcod   ,
    atoflg       like datkdcrorg.atoflg   ,
    itaasstipcod like datkassunto.itaasstipcod,
    c24astagp    like datkassunto.c24astagp,
    c24astcod    like datkassunto.c24astcod,
    c24astdes    like datkassunto.c24astdes
 end record
 
 define l_motivo record
   avialgmtv like datmavisrent.avialgmtv, 
   ciaempcod like datmservico.ciaempcod
 end record
 
 define l_atdsrvorg like datmservico.atdsrvorg
 
 define l_mensagem char(10000)
 
 if m_ctb00g16_prep is null or
     m_ctb00g16_prep <> true then
     call ctb00g16_prepare()
  end if
 
 
 initialize lr_retorno.* to null
 initialize l_motivo.*   to null
 initialize l_atdsrvorg  to null 
 
 let l_mensagem = null
 
 # Busca origem do servico
 whenever error continue
 
    open cctb00g16005 using param.atdsrvnum,
                            param.atdsrvano 
                            
    fetch cctb00g16005 into l_atdsrvorg
    
    display "Servico: ", l_atdsrvorg, "-", param.atdsrvnum, "/", param.atdsrvano
    
    if sqlca.sqlcode  =  notfound   then
        let lr_retorno.msgerro =  "Nao foi encontrada origem do servico"
        let lr_retorno.erro = 1
        #return lr_retorno.*
     else
        if sqlca.sqlcode <> 0 then
           let lr_retorno.msgerro =  "Erro(",sqlca.sqlcode using "<<<<<",") ao procurar origem do servico"
           let lr_retorno.erro = 4
           #return lr_retorno.*
        end if 
     end if 
    
    close cctb00g16005  
 whenever error continue
 
 # busca para quem o servico foi prestado
  call ctb00g16_srvprestado(param.atdsrvnum,param.atdsrvano)
     returning lr_retorno.erro     ,
               lr_retorno.msgerro  ,
               lr_retorno.itaasstipcod,
               lr_retorno.c24astagp,
               lr_retorno.c24astcod,
               lr_retorno.c24astdes
               
    display "erro ", lr_retorno.erro
               
     if lr_retorno.erro <> 0 then
        if l_mensagem is null then
          let l_mensagem = lr_retorno.msgerro clipped      
        else
          let l_mensagem = l_mensagem clipped,ASCII(13),lr_retorno.msgerro clipped 
        end if 
     end if     
  display "l_mensagem: ",l_mensagem clipped   
  let lr_retorno.msgerro = l_mensagem clipped
 
 # verifica se eh servico de Carro-Extra
 if l_atdsrvorg = 8 then
    
    # Busca motivo da locacao e empresa do servico
    whenever error continue
 
    open cctb00g16006 using param.atdsrvnum,
                            param.atdsrvano 
                            
    fetch cctb00g16006 into l_motivo.avialgmtv,
                            l_motivo.ciaempcod
    
    close cctb00g16006
    whenever error continue
    
    # busca a decorrencia do servico e o bem atendido do servico de locacao
    call ctb00g16_srvmotivo(l_atdsrvorg,l_motivo.ciaempcod,l_motivo.avialgmtv)
      returning lr_retorno.erro     ,
                lr_retorno.msgerro  ,
                lr_retorno.srvdcrcod,
                lr_retorno.bemcod   ,
                lr_retorno.atoflg
                
    display "erro ", lr_retorno.erro
                
    if lr_retorno.erro <> 0 then
      display "ERRO MOTIVO: ",lr_retorno.msgerro clipped
      if l_mensagem is null then
         let l_mensagem = lr_retorno.msgerro clipped      
       else                                                       
         let l_mensagem = l_mensagem clipped,ASCII(13),lr_retorno.msgerro clipped 
       end if
       #display "l_mensagem1: ",l_mensagem clipped 
    end if 
    
 else # outras origens
 
 display "c24astcod: ", lr_retorno.c24astcod
 display "l_atdsrvorg; ", l_atdsrvorg
 
    # busca a decorrencia do servico e o bem atendido dos outros servicos
    call ctb00g16_srvorigem(l_atdsrvorg,lr_retorno.c24astcod)
      returning lr_retorno.erro     ,
                lr_retorno.msgerro  ,
                lr_retorno.srvdcrcod,
                lr_retorno.bemcod   ,
                lr_retorno.atoflg
                
    display "erro ", lr_retorno.erro
                
    if lr_retorno.erro <> 0 then
      if l_mensagem is null then
         let l_mensagem = lr_retorno.msgerro clipped      
       else
         let l_mensagem = l_mensagem clipped,ASCII(13),lr_retorno.msgerro clipped 
       end if 
    end if 
    
 end if 
 
                      
 return lr_retorno.erro        ,
        lr_retorno.msgerro     ,
        lr_retorno.srvdcrcod   ,
        lr_retorno.bemcod      ,
        lr_retorno.atoflg      ,
        lr_retorno.itaasstipcod,
        lr_retorno.c24astagp,
        lr_retorno.c24astcod,
        lr_retorno.c24astdes,
        l_motivo.avialgmtv


end function


#------------------------------------------------------------
 function ctb00g16_srvorigem(param)
#------------------------------------------------------------
  define param record
    atdsrvorg      like datkdcrorg.atdsrvorg,
    c24astcod      like datkassunto.c24astcod
  end record
  
  define lr_retorno record
    erro      smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
    msgerro   char(300),
    srvdcrcod like datkdcrorg.srvdcrcod,
    bemcod    like datkdcrorg.bemcod   ,
    atoflg    like datkdcrorg.atoflg
  end record
  
  initialize lr_retorno.* to null

  if m_ctb00g16_prep is null or
     m_ctb00g16_prep <> true then
     call ctb00g16_prepare()
  end if

  let lr_retorno.msgerro =  ""
  let lr_retorno.erro = 0
  
  display "ctb00g16_srvorigem(param)"
  
  whenever error continue
   open cctb00g16001 using param.atdsrvorg,param.c24astcod
   
   fetch cctb00g16001 into lr_retorno.srvdcrcod,
                           lr_retorno.bemcod   ,
                           lr_retorno.atoflg   
                           
      display "srvdcrcod: ", lr_retorno.srvdcrcod
      display "bemcod: ", lr_retorno.bemcod
      display "atoflg: ", lr_retorno.atoflg
    
     if sqlca.sqlcode  =  notfound   then 
        let param.c24astcod = 'ZZZ'
        open cctb00g16001 using param.atdsrvorg,param.c24astcod
                                                               
        fetch cctb00g16001 into lr_retorno.srvdcrcod,          
                                lr_retorno.bemcod   ,          
                                lr_retorno.atoflg              
                                                               
        if sqlca.sqlcode  =  notfound   then   
           let lr_retorno.msgerro =  "Nao foi encontrada parametrizacao para a origem : ",param.atdsrvorg
           let lr_retorno.erro = 1
        else
           if sqlca.sqlcode <> 0 then
              let lr_retorno.msgerro =  "Erro(",sqlca.sqlcode using "<<<<<",") ao procurar parametrizacao para a origem : ",param.atdsrvorg
              let lr_retorno.erro = 4
           end if 
        end if 
        close cctb00g16001
     else
        if sqlca.sqlcode <> 0 then
           let lr_retorno.msgerro =  "Erro(",sqlca.sqlcode using "<<<<<",") ao procurar parametrizacao para a origem : ",param.atdsrvorg
           let lr_retorno.erro = 4
        end if 
     end if  
                           
   close cctb00g16001
  whenever error stop
  
  
  if lr_retorno.atoflg <> 1 then
      let lr_retorno.msgerro =  "Parametrizacao cancelada/bloqueada para a origem : ",param.atdsrvorg
      let lr_retorno.erro = 3
  end if 
  
  display "erro: ", lr_retorno.erro 
  display "msgerro: ", lr_retorno.msgerro 

 return lr_retorno.erro     ,
        lr_retorno.msgerro  ,
        lr_retorno.srvdcrcod,
        lr_retorno.bemcod   ,
        lr_retorno.atoflg   
 
end function


#------------------------------------------------------------
 function ctb00g16_srvmotivo(param)
#------------------------------------------------------------
  define param record
    atdsrvorg      like datkalgmtv.atdsrvorg,
    ciaempcod      like datkalgmtv.ciaempcod,
    avialgmtv      like datkalgmtv.avialgmtv
  end record
  
  define lr_retorno record
    erro      smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
    msgerro   char(300),
    srvdcrcod like datkalgmtv.srvdcrcod,
    bemcod    like datkalgmtv.bemcod   ,
    atoflg    like datkalgmtv.atoflg
  end record
  
  initialize lr_retorno.* to null

  if m_ctb00g16_prep is null or
     m_ctb00g16_prep <> true then
     call ctb00g16_prepare()
  end if

  let lr_retorno.msgerro = null
  let lr_retorno.erro = 0
  
  whenever error continue
   
   display "param.atdsrvorg: ",param.atdsrvorg
   display "param.ciaempcod: ",param.ciaempcod
   display "param.avialgmtv: ",param.avialgmtv
   
   open cctb00g16002 using param.atdsrvorg,
                           param.ciaempcod,
                           param.avialgmtv
                           
                           
   fetch cctb00g16002 into lr_retorno.srvdcrcod,
                           lr_retorno.bemcod   ,
                           lr_retorno.atoflg   
    
     if sqlca.sqlcode  =  notfound   then
        let lr_retorno.msgerro =  "Nao foi encontrada parametrizacao para a org/emp/mot : ",param.atdsrvorg using '<<<<<&',
                                  "/",param.ciaempcod using '<<<<<&',"/",param.avialgmtv using '<<<<<&'
        let lr_retorno.erro = 1
     else
        if sqlca.sqlcode <> 0 then
           let lr_retorno.msgerro =  "Erro(",sqlca.sqlcode using "<<<<<",") ao procurar parametrizacao para a org/emp/mot : ",param.atdsrvorg using '<<<<<&',
                                  "/",param.ciaempcod using '<<<<<&',"/",param.avialgmtv using '<<<<<&'         
           let lr_retorno.erro = 4
        end if 
     end if  
                           
   close cctb00g16001
  whenever error stop
  
  
  if lr_retorno.atoflg <> 1 then
      let lr_retorno.msgerro =  "Parametrizacao cancelada/bloqueada para a org/emp/mot : ",param.atdsrvorg using '<<<<<&',
                                  "/",param.ciaempcod using '<<<<<&',"/",param.avialgmtv using '<<<<<&'             
      let lr_retorno.erro = 3
  end if 

 return lr_retorno.erro     ,
        lr_retorno.msgerro  ,
        lr_retorno.srvdcrcod,
        lr_retorno.bemcod   ,
        lr_retorno.atoflg   
 
end function


#------------------------------------------------------------
 function ctb00g16_srvprestado(param)
#------------------------------------------------------------
  define param record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano
  end record
  
  define lr_retorno record
    erro         smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
    msgerro      char(300),
    itaasstipcod like datkassunto.itaasstipcod,
    c24astagp    like datkassunto.c24astagp,
    c24astcod    like datkassunto.c24astcod,
    c24astdes    like datkassunto.c24astdes
  end record
  
  initialize lr_retorno.* to null

  if m_ctb00g16_prep is null or
     m_ctb00g16_prep <> true then
     call ctb00g16_prepare()
  end if
  
  let lr_retorno.msgerro =  ""
  let lr_retorno.erro = 0
  
  
  whenever error continue
   open cctb00g16003 using param.atdsrvnum,
                           param.atdsrvano
                           
   fetch cctb00g16003 into lr_retorno.itaasstipcod,
                           lr_retorno.c24astagp,
                           lr_retorno.c24astcod,
                           lr_retorno.c24astdes
    
     if sqlca.sqlcode  =  notfound   then
        let lr_retorno.msgerro =  "Nao foi encontrado para quem o servico foi prestado "
        let lr_retorno.erro = 1
     else
        if sqlca.sqlcode <> 0 then
           let lr_retorno.msgerro =  "Erro(",sqlca.sqlcode using "<<<<<",") ao procurar para quem o servico foi prestado"
           let lr_retorno.erro = 4
        end if 
     end if  
                           
   close cctb00g16001
  whenever error stop
  
 if lr_retorno.itaasstipcod is null or 
    lr_retorno.itaasstipcod = '' or 
    lr_retorno.itaasstipcod = 0 then
    
    let lr_retorno.msgerro =  "Para quem o servico foi prestado esta em branco"
    let lr_retorno.erro = 1
    
 end if 
  
 return lr_retorno.erro     ,
        lr_retorno.msgerro  ,
        lr_retorno.itaasstipcod,
        lr_retorno.c24astagp,
        lr_retorno.c24astcod,
        lr_retorno.c24astdes
 
end function


#------------------------------------------------------------
 function ctb00g16_srvcarteira(param)
#------------------------------------------------------------
  define param record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    ciaempcod      like datkalgmtv.ciaempcod,
    aplnumdig      like datrservapol.aplnumdig , 
    prpnumdig      like datrligprp.prpnumdig       
  end record
  
  define lr_retorno record
    erro          smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
    msgerro       char(300),
    srvatdctecod  like dbskctbevnpam.srvatdctecod   
  end record
  
   define lr_servico   record
       atdsrvorg       like datmservico.atdsrvorg,                  
       itaasstipcod    like datkassunto.itaasstipcod,
       c24astcod       like datkassunto.c24astcod           
   end record
    
  define l_pgttipcodps  like dbscadtippgt.pgttipcodps
  define l_contingecia  smallint
  define l_chave        like datkgeral.grlchv
  define l_opgmvttip    like ctimsocprv.opgmvttip
  
  initialize lr_retorno.* to null   
  initialize l_pgttipcodps,l_contingecia,l_chave,l_opgmvttip to null   

  if m_ctb00g16_prep is null or
     m_ctb00g16_prep <> true then
     call ctb00g16_prepare()
  end if
  
  whenever error continue
       open cctb00g16007 using param.atdsrvnum,
                               param.atdsrvano 
       fetch cctb00g16007 into l_pgttipcodps
       
       close cctb00g16007
  whenever error stop  
  
  whenever error continue
    open cctb00g16009 using param.atdsrvnum,
                            param.atdsrvano
                            
    fetch cctb00g16009 into lr_servico.atdsrvorg,   
                            lr_servico.itaasstipcod,
                            lr_servico.c24astcod
    close cctb00g16009      
  whenever error stop
  
  # Verificar o tipo de Cortesia de Assitência que eh o servico
  if lr_servico.itaasstipcod = 3 then
     let l_chave = 'PSOORG',lr_servico.atdsrvorg using '<&','ASSUNT',lr_servico.itaasstipcod using '<&'   
  end if 
       
  if  l_chave is not null then
     select grlinf 
       into l_opgmvttip
       from datkgeral
      where grlchv = l_chave
     
     if sqlca.sqlcode = notfound then
        let l_chave = 'PSOORG0ASSUNT',lr_servico.itaasstipcod using '<&'
        select grlinf 
          into l_opgmvttip
          from datkgeral
         where grlchv = l_chave 
     end if
  end if 
  
  let lr_retorno.erro = 0
  
  #----------------------------------------------------------------#
  #        Codigo para identificar a carteira                      #
  #         do servico para contabilizacao                         # 
  #----------------------------------------------------------------#
  #      1  - SERVICO ATENDIDO PELA APOLICE                        #
  #      2  - SERVICO ATENDIDO PELA PROPOSTA                       #
  #      3  - SERVICO ATENDIDO PELO CENTRO DE CUSTO COM APOLICE    # 
  #      4  - SERVICO ATENDIDO PELO CENTRO DE CUSTO SEM APOLICE    # 
  #      5  - SERVICO ATENDIDO PELA CONTIGENCIA SEM CARGA          # 
  #      6  - SERVICO ATENDIDO SEM DOCUMENTO                       #
  #      7  - SERVICO ATENDIDO POR CORTESIA ASSISTÊNCIA AUTOMOVEL  #
  #      8  - SERVICO ATENDIDO POR CORTESIA ASSISTÊNCIA RESIDENCIA #
  #      9  - SERVICO ATENDIDO POR CORTESIA ASSISTÊNCIA PASSAGEIRO #
  #      10 - SERVICO ATENDIDO POR CORTESIA RESSARSIVEL(COR/FUNC)  #
  #      11 - SERVICO ATENDIDO PSS(SERVICO AVULSO - EMP.43 )       #
  #----------------------------------------------------------------#    
  
  # 1- SERVICO ATENDIDO PELA APOLICE
  if param.aplnumdig <> 0  and 
     param.aplnumdig <> ' ' and
     param.aplnumdig is not null then
     let lr_retorno.srvatdctecod = 1
     
     # 3- SERVICO ATENDIDO PELO CENTRO DE CUSTO COM APOLICE 
     if l_pgttipcodps = 3 then
        let lr_retorno.srvatdctecod = 3
     end if
  else
  
     # 4- SERVICO ATENDIDO PELO CENTRO DE CUSTO SEM APOLICE 
     if l_pgttipcodps = 3 then
        let lr_retorno.srvatdctecod = 4
     end if
     
  end if 
   
  # 2- SERVICO ATENDIDO PELA PROPOSTA
  if param.prpnumdig <> 0  and 
     #param.prpnumdig <> '' and
     param.prpnumdig is not null then
     
     let lr_retorno.srvatdctecod = 2
     
  end if 
   
  # 5- SERVICO ATENDIDO PELA CONTIGENCIA SEM CARGA  
  whenever error continue
       open cctb00g16008 using param.atdsrvnum,
                               param.atdsrvano 
       fetch cctb00g16008 into l_contingecia
       
       if sqlca.sqlcode = 0 then   
             let lr_retorno.srvatdctecod = 5
       end if 
       
       close cctb00g16008
  whenever error stop  
  
  
  # 6- SERVICO ATENDIDO SEM DOCUMENTO
  if (param.aplnumdig = 0 or param.aplnumdig = '' or param.aplnumdig is null ) and 
     (param.prpnumdig = 0 or param.prpnumdig = '' or param.prpnumdig is null ) and 
     (lr_retorno.srvatdctecod is null or lr_retorno.srvatdctecod = 0 ) then
     
     let lr_retorno.srvatdctecod = 6
     
  end if 
  
  if l_pgttipcodps <> 3 or l_pgttipcodps is null then
     #  7  - SERVICO ATENDIDO POR CORTESIA ASSISTÊNCIA AUTOMOVEL
     if l_opgmvttip = 31 then
        let lr_retorno.srvatdctecod = 7  
     else
        #  8  - SERVICO ATENDIDO POR CORTESIA ASSISTÊNCIA RESIDENCIA    
        if l_opgmvttip = 32 then
           let lr_retorno.srvatdctecod = 8  
        else
           #  9  - SERVICO ATENDIDO POR CORTESIA ASSISTÊNCIA PASSAGEIRO 
           if l_opgmvttip = 33 then       
              let lr_retorno.srvatdctecod = 9 
           end if   
        end if 
     end if 
     
     #10 - SERVICO ATENDIDO POR CORTESIA RESSARSIVEL(COR/FUNC)
     if l_pgttipcodps = 1 or l_pgttipcodps = 2  then
            let lr_retorno.srvatdctecod = 10
     end if 
  end if 
  
 #11 - SERVICO ATENDIDO PSS(SERVICO AVULSO - EMP.43 ) 
  if param.ciaempcod = 43 then
     let lr_retorno.srvatdctecod = 11
  end if 
  
  if lr_retorno.srvatdctecod is null then
     let lr_retorno.erro    = 100
     let lr_retorno.msgerro = "Nao foi encontrada carteira para o servico"
  end if 
   
 return lr_retorno.erro     ,
        lr_retorno.msgerro  ,
        lr_retorno.srvatdctecod
 
end function   


#------------------------------------------------------------  
 function ctb00g16_contabilizacao(param)                          
#------------------------------------------------------------  
     
 define param record
     empcod        like dbskctbevnpam.empcod      ,
     pcpsgrramcod  like dbskctbevnpam.pcpsgrramcod,
     pcpsgrmdlcod  like dbskctbevnpam.pcpsgrmdlcod,
     ctbsgrramcod  like dbskctbevnpam.ctbsgrramcod,
     ctbsgrmdlcod  like dbskctbevnpam.ctbsgrmdlcod,
     pgoclsflg     like dbskctbevnpam.pgoclsflg   ,
     srvdcrcod     like dbskctbevnpam.srvdcrcod   ,
     itaasstipcod  like dbskctbevnpam.itaasstipcod,
     bemcod        like dbskctbevnpam.bemcod      ,
     srvatdctecod  like dbskctbevnpam.srvatdctecod,
     c24astagp     like dbskctbevnpam.c24astagp,
     c24astcod     like datkassunto.c24astcod,
     clscod        like dbskctbevnpam.clscod  
  end record       
    
  define lr_ctb00g16 record
     srvpovevncod  like dbskctbevnpam.srvpovevncod,
     srvajsevncod  like dbskctbevnpam.srvajsevncod,
     srvbxaevncod  like dbskctbevnpam.srvbxaevncod,
     srvpgtevncod  like dbskctbevnpam.srvpgtevncod,
     ctbevnpamcod  like dbskctbevnpam.ctbevnpamcod,
     c24astagp     like dbskctbevnpam.c24astagp   ,
     clscod        like dbskctbevnpam.clscod      ,
     c24astcod     like dbskctbevnpam.c24astcod
  end record  
  
   define l_msgerro char(10000)  
  
  initialize lr_ctb00g16.* to null
     
   let l_msgerro = null
   
   display "ctb00g16_contabilizacao"
   display "srvatdctecod: ", param.srvatdctecod
   
   if param.srvatdctecod = 4  or 
     #param.srvatdctecod = 11 or # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
      param.srvatdctecod = 5  or 
      param.srvatdctecod = 6  then 
      
         let param.pcpsgrramcod = 0
         let param.pcpsgrmdlcod = 0
         let param.ctbsgrramcod = 0
         let param.ctbsgrmdlcod = 0
         
   end if 
   
   
   
   whenever error continue
      open cctb00g16015 using  param.empcod      , 
                               param.pcpsgrramcod, 
                               param.pcpsgrmdlcod, 
                               param.ctbsgrramcod, 
                               param.ctbsgrmdlcod, 
                               param.pgoclsflg   , 
                               param.srvdcrcod   , 
                               param.itaasstipcod, 
                               param.bemcod      , 
                               param.srvatdctecod, 
                               param.c24astagp   ,
                               param.clscod      ,
                               param.c24astcod
       
      fetch cctb00g16015 into  lr_ctb00g16.ctbevnpamcod,
                               lr_ctb00g16.srvpovevncod,
                               lr_ctb00g16.srvajsevncod,
                               lr_ctb00g16.srvbxaevncod,
                               lr_ctb00g16.srvpgtevncod
                               
      display "sqlcode cctb00g16015_1: ", sqlca.sqlcode                               
      
      if sqlca.sqlcode <> 0 then
          
         let lr_ctb00g16.clscod   = 0
         
         open cctb00g16015 using  param.empcod      , 
                                  param.pcpsgrramcod, 
                                  param.pcpsgrmdlcod, 
                                  param.ctbsgrramcod, 
                                  param.ctbsgrmdlcod, 
                                  param.pgoclsflg   , 
                                  param.srvdcrcod   , 
                                  param.itaasstipcod, 
                                  param.bemcod      , 
                                  param.srvatdctecod, 
                                  param.c24astagp   ,
                                  lr_ctb00g16.clscod,
                                  param.c24astcod
          
         fetch cctb00g16015 into  lr_ctb00g16.ctbevnpamcod,
                                  lr_ctb00g16.srvpovevncod,
                                  lr_ctb00g16.srvajsevncod,
                                  lr_ctb00g16.srvbxaevncod,
                                  lr_ctb00g16.srvpgtevncod  
                                  
      display "sqlcode cctb00g16015_2: ", sqlca.sqlcode    
         
         if sqlca.sqlcode <> 0 then
            
            let lr_ctb00g16.c24astagp   = "ZZZ" 
         
            open cctb00g16015 using  param.empcod      , 
                                     param.pcpsgrramcod, 
                                     param.pcpsgrmdlcod, 
                                     param.ctbsgrramcod, 
                                     param.ctbsgrmdlcod, 
                                     param.pgoclsflg   , 
                                     param.srvdcrcod   , 
                                     param.itaasstipcod, 
                                     param.bemcod      , 
                                     param.srvatdctecod, 
                                     lr_ctb00g16.c24astagp,
                                     param.clscod      ,
                                     param.c24astcod
             
            fetch cctb00g16015 into  lr_ctb00g16.ctbevnpamcod,
                                     lr_ctb00g16.srvpovevncod,
                                     lr_ctb00g16.srvajsevncod,
                                     lr_ctb00g16.srvbxaevncod,
                                     lr_ctb00g16.srvpgtevncod  
                                     
      display "sqlcode cctb00g16015_3: ", sqlca.sqlcode  
            
            if sqlca.sqlcode <> 0 then
               
               let lr_ctb00g16.c24astcod = "ZZZ" 
               
               open cctb00g16015 using  param.empcod      , 
                                        param.pcpsgrramcod, 
                                        param.pcpsgrmdlcod, 
                                        param.ctbsgrramcod, 
                                        param.ctbsgrmdlcod, 
                                        param.pgoclsflg   , 
                                        param.srvdcrcod   , 
                                        param.itaasstipcod, 
                                        param.bemcod      , 
                                        param.srvatdctecod, 
                                        param.c24astagp   ,
                                        param.clscod      ,
                                        lr_ctb00g16.c24astcod
                
               fetch cctb00g16015 into  lr_ctb00g16.ctbevnpamcod,
                                        lr_ctb00g16.srvpovevncod,
                                        lr_ctb00g16.srvajsevncod,
                                        lr_ctb00g16.srvbxaevncod,
                                        lr_ctb00g16.srvpgtevncod  
                                        
      display "sqlcode cctb00g16015_4: ", sqlca.sqlcode  
               
               if sqlca.sqlcode <> 0 then
                  
                  let lr_ctb00g16.c24astcod = "ZZZ" 
                  let lr_ctb00g16.c24astagp = "ZZZ" 
               
                  open cctb00g16015 using  param.empcod      , 
                                           param.pcpsgrramcod, 
                                           param.pcpsgrmdlcod, 
                                           param.ctbsgrramcod, 
                                           param.ctbsgrmdlcod, 
                                           param.pgoclsflg   , 
                                           param.srvdcrcod   , 
                                           param.itaasstipcod, 
                                           param.bemcod      , 
                                           param.srvatdctecod, 
                                           lr_ctb00g16.c24astagp,
                                           param.clscod      ,
                                           lr_ctb00g16.c24astcod
                   
                  fetch cctb00g16015 into  lr_ctb00g16.ctbevnpamcod,
                                           lr_ctb00g16.srvpovevncod,
                                           lr_ctb00g16.srvajsevncod,
                                           lr_ctb00g16.srvbxaevncod,
                                           lr_ctb00g16.srvpgtevncod  
                                           
      display "sqlcode cctb00g16015_5: ", sqlca.sqlcode  
                  
                  if sqlca.sqlcode <> 0 then
                     let lr_ctb00g16.clscod    = 0
                     let lr_ctb00g16.c24astagp = "ZZZ" 
                     
                     open cctb00g16015 using  param.empcod      , 
                                              param.pcpsgrramcod, 
                                              param.pcpsgrmdlcod, 
                                              param.ctbsgrramcod, 
                                              param.ctbsgrmdlcod, 
                                              param.pgoclsflg   , 
                                              param.srvdcrcod   , 
                                              param.itaasstipcod, 
                                              param.bemcod      , 
                                              param.srvatdctecod, 
                                              lr_ctb00g16.c24astagp,
                                              lr_ctb00g16.clscod,
                                              param.c24astcod
                      
                     fetch cctb00g16015 into  lr_ctb00g16.ctbevnpamcod,
                                              lr_ctb00g16.srvpovevncod,
                                              lr_ctb00g16.srvajsevncod,
                                              lr_ctb00g16.srvbxaevncod,
                                              lr_ctb00g16.srvpgtevncod   
                                              
      display "sqlcode cctb00g16015_6: ", sqlca.sqlcode 
                     
                     if sqlca.sqlcode <> 0 then
                        let lr_ctb00g16.clscod    = 0
                        let lr_ctb00g16.c24astcod = "ZZZ" 
                        
                        open cctb00g16015 using  param.empcod      , 
                                                 param.pcpsgrramcod, 
                                                 param.pcpsgrmdlcod, 
                                                 param.ctbsgrramcod, 
                                                 param.ctbsgrmdlcod, 
                                                 param.pgoclsflg   , 
                                                 param.srvdcrcod   , 
                                                 param.itaasstipcod, 
                                                 param.bemcod      , 
                                                 param.srvatdctecod, 
                                                 param.c24astagp   ,
                                                 lr_ctb00g16.clscod,
                                                 lr_ctb00g16.c24astcod
                         
                        fetch cctb00g16015 into  lr_ctb00g16.ctbevnpamcod,
                                                 lr_ctb00g16.srvpovevncod,
                                                 lr_ctb00g16.srvajsevncod,
                                                 lr_ctb00g16.srvbxaevncod,
                                                 lr_ctb00g16.srvpgtevncod   
                                                 
      display "sqlcode cctb00g16015_7: ", sqlca.sqlcode 
                        
                        if sqlca.sqlcode <> 0 then
                           let lr_ctb00g16.clscod    = 0
                           let lr_ctb00g16.c24astcod = "ZZZ"
                           let lr_ctb00g16.c24astagp = "ZZZ" 
                           
                           open cctb00g16015 using  param.empcod      , 
                                                    param.pcpsgrramcod, 
                                                    param.pcpsgrmdlcod, 
                                                    param.ctbsgrramcod, 
                                                    param.ctbsgrmdlcod, 
                                                    param.pgoclsflg   , 
                                                    param.srvdcrcod   , 
                                                    param.itaasstipcod, 
                                                    param.bemcod      , 
                                                    param.srvatdctecod, 
                                                    lr_ctb00g16.c24astagp,
                                                    lr_ctb00g16.clscod,
                                                    lr_ctb00g16.c24astcod
                            
                           fetch cctb00g16015 into  lr_ctb00g16.ctbevnpamcod,
                                                    lr_ctb00g16.srvpovevncod,
                                                    lr_ctb00g16.srvajsevncod,
                                                    lr_ctb00g16.srvbxaevncod,
                                                    lr_ctb00g16.srvpgtevncod 
                                                    
      display "sqlcode cctb00g16015_8: ", sqlca.sqlcode   
                           
                           if sqlca.sqlcode <> 0 then
                              display "Erro ao busca parametrizacao: ",sqlca.sqlcode 
                              let l_msgerro = "Nao foi encontrado cadastro contabil para as seguintes informacoes: ",ASCII(13),
                                              ASCII(9),ASCII(9),"empresa.........................:",param.empcod       using '&<<<<<',ASCII(13),
                                              ASCII(9),ASCII(9),"ramo............................:",param.pcpsgrramcod using '&<<<<<',ASCII(13),
                                              ASCII(9),ASCII(9),"modalidade......................:",param.pcpsgrmdlcod using '&<<<<<',ASCII(13),
                                              ASCII(9),ASCII(9),"ramo contabil...................:",param.ctbsgrramcod using '&<<<<<',ASCII(13),
                                              ASCII(9),ASCII(9),"modalidade contabil.............:",param.ctbsgrmdlcod using '&<<<<<',ASCII(13),
                                              ASCII(9),ASCII(9),"clausula paga...................:",param.pgoclsflg    ,ASCII(13),   
                                              ASCII(9),ASCII(9),"decorrencia do servico..........:",param.srvdcrcod    using '&<<<<<',ASCII(13),
                                              ASCII(9),ASCII(9),"para quem o servico foi prestado:",param.itaasstipcod using '&<<<<<',ASCII(13),
                                              ASCII(9),ASCII(9),"bem atendido....................:",param.bemcod       using '&<<<<<',ASCII(13),
                                              ASCII(9),ASCII(9),"carteira........................:",param.srvatdctecod using '&<<<<<',ASCII(13),
                                              ASCII(9),ASCII(9),"grupo de assunto................:",param.c24astcod    clipped ,"|",lr_ctb00g16.c24astagp clipped,ASCII(13),   
                                              ASCII(9),ASCII(9),"Clausula do atendimento.........:",param.clscod       clipped ,"|",lr_ctb00g16.clscod    clipped,ASCII(13), 
                                              ASCII(9),ASCII(9),"assunto.........................:",param.c24astcod    clipped ,"|",lr_ctb00g16.c24astcod clipped,ASCII(13)
                           else
                              let l_msgerro = null   
                           end if  
                        else
                           let l_msgerro = null   
                        end if
                     else                   
                        let l_msgerro = null
                     end if
                  else                   
                     let l_msgerro = null
                  end if
               else                   
                  let l_msgerro = null
               end if
            else                   
               let l_msgerro = null
            end if
         else                   
            let l_msgerro = null
         end if 
      else                   
         let l_msgerro = null
      end if       
                   
   whenever error stop                       
      
 return l_msgerro,
        lr_ctb00g16.ctbevnpamcod,
        lr_ctb00g16.srvpovevncod,
        lr_ctb00g16.srvajsevncod,
        lr_ctb00g16.srvbxaevncod,
        lr_ctb00g16.srvpgtevncod
                             
end function 

#------------------------------------------------------------  
 function ctb00g16_srvvlrprv(param)                          
#------------------------------------------------------------  
     
 define param record
     atdsrvnum  like dbsmatdpovhst.atdsrvnum,    
     atdsrvano  like dbsmatdpovhst.atdsrvano
 end record  
 
 define lr_valorRE record
    socntzcod   smallint,
    vlrmaximo   dec(12,2),
    vlrdiferenc dec(12,2),
    vlrmltdesc  dec(12,2),
    nrsrvs      smallint,
    flgtab      smallint,
    valor       like ctimsocprv.opgvlr
 end record
 
 define lr_valorCE record
     valor         like ctimsocprv.opgvlr
 end record
 
 define lr_valorAUTO record
     valor         like ctimsocprv.opgvlr
 end record
 
 define l_atdsrvorg  like datkalgmtv.atdsrvorg
 
 
 define l_buscaValor smallint
 define l_Valor like ctimsocprv.opgvlr
 
 initialize lr_valorRE.* to null  
 initialize lr_valorCE.* to null
 initialize lr_valorAUTO.* to null
 initialize l_atdsrvorg to null
 
 let l_buscaValor = false
 let l_Valor = 0
 
 open cctb00g16005 using param.atdsrvnum, param.atdsrvano
 
 fetch cctb00g16005 into l_atdsrvorg
 
 case l_atdsrvorg
    when 8
      
     call ctb00g16_trsrvce(param.atdsrvnum, param.atdsrvano)
          returning lr_valorCE.valor
     
     if lr_valorCE.valor is null or lr_valorCE.valor = ' ' then
        let l_buscaValor = true
     else
        let l_Valor = lr_valorCE.valor
     end if      
        
    when 9
       call ctx15g00_vlrre(param.atdsrvnum, param.atdsrvano)
            returning lr_valorRE.socntzcod, 
                      lr_valorRE.valor, 
                      lr_valorRE.vlrmaximo,
                      lr_valorRE.vlrdiferenc, 
                      lr_valorRE.vlrmltdesc, 
                      lr_valorRE.nrsrvs, 
                      lr_valorRE.flgtab
                      
       if lr_valorRE.valor is null or lr_valorRE.valor = ' ' then
          let l_buscaValor = true
       else
          let l_Valor = lr_valorRE.valor
       end if   
        
    when 13
       call ctx15g00_vlrre(param.atdsrvnum, param.atdsrvano)
              returning lr_valorRE.socntzcod, 
                        lr_valorRE.valor, 
                        lr_valorRE.vlrmaximo,
                        lr_valorRE.vlrdiferenc, 
                        lr_valorRE.vlrmltdesc, 
                        lr_valorRE.nrsrvs, 
                        lr_valorRE.flgtab 
       
       if lr_valorRE.valor is null or lr_valorRE.valor <> '' then
          let l_buscaValor = true
       else
          let l_Valor = lr_valorRE.valor
       end if  
                        
    otherwise
       call ctb00g16_trsrvauto(param.atdsrvnum, param.atdsrvano)
              returning lr_valorAUTO.valor 
       
       if lr_valorAUTO.valor is null or 
          lr_valorAUTO.valor = ' '   or 
          lr_valorAUTO.valor = 0 then
          display "lr_valorAUTO.valor: ",lr_valorAUTO.valor
          let l_buscaValor = true
       else
          let l_Valor = lr_valorAUTO.valor
       end if 
    
 end case                  
 
 
 if l_buscaValor then
#     display "Valor Padrao"
    select cpodes                     
      into l_Valor          
      from iddkdominio                
     where cponom = 'valor_padrao'    
       and cpocod = l_atdsrvorg 
       display "l_valor: ",l_Valor 
       
 end if                          
 
 return  l_Valor                       
                             
end function #ctb00g16_srvvlrprv

#------------------------------------------------------------  
function ctb00g16_trsrvce(param)
#------------------------------------------------------------  
 
 define param record
     atdsrvnum  like dbsmatdpovhst.atdsrvnum,    
     atdsrvano  like dbsmatdpovhst.atdsrvano
 end record
 
 define lr_valorCE record
    avivclcod     like datmavisrent.avivclcod,
    lcvlojtip     like datkavislocal.lcvlojtip,
    lcvregprccod  like datkavislocal.lcvregprccod,
    lcvcod        like datkavislocal.lcvcod,
    aviprvent     like datmavisrent.aviprvent,
    avivclvlr     like datmavisrent.avivclvlr,
    viginc        like datklocaldiaria.viginc,
    prtsgrvlr     like datklocaldiaria.prtsgrvlr,
    diafxovlr     like datklocaldiaria.diafxovlr,
    valor         like ctimsocprv.opgvlr
 end record

  initialize lr_valorCE.* to null  

  whenever error continue
     open cctb00g16011 using param.atdsrvnum, param.atdsrvano   
                               
     fetch cctb00g16011 into lr_valorCE.avivclcod,   
                             lr_valorCE.lcvlojtip,   
                             lr_valorCE.lcvregprccod,
                             lr_valorCE.lcvcod,      
                             lr_valorCE.aviprvent,
                             lr_valorCE.avivclvlr
                             
     if sqlca.sqlcode = 0 then 
     
        let lr_valorCE.viginc = today
        
        open cctb00g16012 using lr_valorCE.avivclcod,   
                                lr_valorCE.lcvlojtip,   
                                lr_valorCE.lcvregprccod,
                                lr_valorCE.lcvcod,
                                lr_valorCE.viginc,
                                lr_valorCE.aviprvent    
        
        fetch cctb00g16012 into lr_valorCE.prtsgrvlr,   
                                lr_valorCE.diafxovlr 
        
        if sqlca.sqlcode <> 0 then
           let lr_valorCE.prtsgrvlr = 0 ### // Valor da diária p/ Porto  //  
           let lr_valorCE.diafxovlr = 0 ### // Valor fixo p/ faixa Porto // 
        end if
        
        ### // Calcula o valor do provisionamento //
        
        if lr_valorCE.diafxovlr > 0 then
            ### // Valor fixo (não multiplica) //
            
            let lr_valorCE.valor = (lr_valorCE.diafxovlr * lr_valorCE.aviprvent)
        else
            if lr_valorCE.prtsgrvlr > 0 then
                ### // Valor da diária para a Porto //
                
                let lr_valorCE.valor = (lr_valorCE.prtsgrvlr * lr_valorCE.aviprvent) 
            else
                ### // Se não encontrou tabela tarifa, utiliza valor do laudo //
                
                let lr_valorCE.valor = (lr_valorCE.avivclvlr * lr_valorCE.aviprvent)
            end if
        end if
    end if
    
  whenever error stop   

  return lr_valorCE.valor
  
end function #ctb00g16_trsrvce


#------------------------------------------------------------  
function ctb00g16_trsrvauto(param)
#------------------------------------------------------------  
 
 define param record
     atdsrvnum  like dbsmatdpovhst.atdsrvnum,    
     atdsrvano  like dbsmatdpovhst.atdsrvano
 end record
 
 define lr_valorAUTO record
    atdsrvorg     like datmservico.atdsrvorg, 
    atddat        like datmservico.atddat,    
    pgtdat        like datmservico.pgtdat,    
    atdprscod     like datmservico.atdprscod, 
    asitipcod     like datmservico.asitipcod, 
    vclcoddig     like datmservico.vclcoddig, 
    socvclcod     like datmservico.socvclcod, 
    ciaempcod     like datmservico.ciaempcod,  
    valor         like ctimsocprv.opgvlr,
    soctrfcod     like dpaksocor.soctrfcod,           
    soctrfvignum  like dbsmvigtrfsocorro.soctrfvignum,
    vclcoddig_acn like datmservico.vclcoddig,
    socgtfcod     like dbstgtfcst.socgtfcod,
    socgtfcod_acn like dbstgtfcst.socgtfcod,
    vlrprm        like dbsmopgitm.socopgitmvlr
    
    
 end record
 
 define lr_erro record         
     err    smallint,          
     msgerr char(100)          
 end record                    
                               
 initialize lr_erro.* to null  
 initialize lr_valorAUTO.* to null  
   
  
  whenever error continue
     open cctb00g16013 using param.atdsrvnum,
                             param.atdsrvano
     fetch cctb00g16013 into lr_valorAUTO.atdsrvorg, 
                             lr_valorAUTO.atddat   , 
                             lr_valorAUTO.pgtdat   , 
                             lr_valorAUTO.atdprscod, 
                             lr_valorAUTO.asitipcod, 
                             lr_valorAUTO.vclcoddig, 
                             lr_valorAUTO.socvclcod, 
                             lr_valorAUTO.ciaempcod 
  whenever error stop
  
   ### // Seleciona o código da tabela de vigência // 
   call ctc00m15_rettrfvig(lr_valorAUTO.atdprscod,      
                           lr_valorAUTO.ciaempcod,      
                           lr_valorAUTO.atdsrvorg,      
                           lr_valorAUTO.asitipcod,      
                           lr_valorAUTO.atddat)   
        returning lr_valorAUTO.soctrfcod,               
                  lr_valorAUTO.soctrfvignum,            
                  lr_erro.*   
    
    
   if lr_erro.err <> 0 then
      let lr_valorAUTO.valor = null
#      display "Mensagem Tabela: ",lr_erro.msgerr clipped
   else
      
      ### // Verifica o grupo tarifário do veículo //
      
      call ctc00m15_retsocgtfcod(lr_valorAUTO.vclcoddig)
           returning lr_valorAUTO.socgtfcod, lr_erro.*
      
      if lr_erro.err <> 0 then
          let lr_valorAUTO.socgtfcod = 1 ### // Se não encontrou, assume grupo 1=Passeio Nacional //
          display "Mensagem Grupo Tarifario: ",lr_erro.msgerr clipped
      end if
      
      
      ### // Verifica o grupo tarifário do veículo acionado //
      whenever error continue
          open cctb00g16014 using lr_valorAUTO.socvclcod
          fetch cctb00g16014 into lr_valorAUTO.vclcoddig_acn
          
          if sqlca.sqlcode <> 0 then
              let lr_valorAUTO.valor = null
          else
             
             call ctc00m15_retsocgtfcod(lr_valorAUTO.vclcoddig_acn)
                    returning lr_valorAUTO.socgtfcod_acn, lr_erro.*
          
                if lr_erro.err <> 0 then
                    let lr_valorAUTO.valor = null 
                    display "Mensagem Grupo Tarifario ACN: ",lr_erro.msgerr clipped
                end if
          
                if lr_valorAUTO.socgtfcod = 5 and
                   lr_valorAUTO.socgtfcod > lr_valorAUTO.socgtfcod_acn then
                    let lr_valorAUTO.socgtfcod = lr_valorAUTO.socgtfcod_acn
                    if  lr_valorAUTO.socgtfcod is null then
                        let lr_valorAUTO.socgtfcod = 1
                    end if
                end if
          end if
      whenever error stop
      
      
      ### // Verifica o preço de tabela da faixa 1=valor inicial //
            call ctc00m15_retvlrvig(lr_valorAUTO.soctrfvignum,
                                    lr_valorAUTO.socgtfcod,
                                    1) #Custo Faixa 1 = Valor Inicial
                 returning lr_valorAUTO.valor, lr_erro.*
	             
	             display "Mensagem Tabela Faixa: ",lr_erro.msgerr clipped 
	             
	          call ctd00g00_vlrprmpgm(param.atdsrvnum, 
                                    param.atdsrvano,
                                    "INI")
                       returning lr_valorAUTO.vlrprm,
                                 lr_erro.err  
            
            if  lr_erro.err = 0 then
                let lr_valorAUTO.valor = ctd00g00_compvlr(lr_valorAUTO.valor, lr_valorAUTO.vlrprm) 
            else
               let lr_valorAUTO.valor = null
               display "ERRO: ",lr_erro.err              
            end if   
   end if  
  
  return lr_valorAUTO.valor
  
end function #ctb00g16_trsrvauto

#------------------------------------------------------------  
 function ctb00g16_incsrvtipprv(param)                          
#------------------------------------------------------------  
     
 define param record
     atdsrvnum  like dbsmatdpovhst.atdsrvnum,    
     atdsrvano  like dbsmatdpovhst.atdsrvano,
     evntipcod  like dbsmatdpovhst.evntipcod,
     ctbpezcod  like dbsmatdpovhst.ctbpezcod,
     srvvlr     like dbsmatdpovhst.srvvlr
  end record  
  
  define lr_ctb00g16 record
     regiclhrrdat  like dbsmatdpovhst.regiclhrrdat
  end record 
  
  initialize lr_ctb00g16.* to null
  
  let lr_ctb00g16.regiclhrrdat = current   
  
  display "Insere"
  display "param.atdsrvnum         : ",param.atdsrvnum         
  display "param.atdsrvano         : ",param.atdsrvano         
  display "lr_ctb00g16.regiclhrrdat: ",lr_ctb00g16.regiclhrrdat
  display "param.evntipcod         : ",param.evntipcod         
  display "param.ctbpezcod         : ",param.ctbpezcod         
  display "param.srvvlr            : ",param.srvvlr            
  
  whenever error continue
     execute pctb00g16010 using param.atdsrvnum,
                                param.atdsrvano,
                                lr_ctb00g16.regiclhrrdat,
                                param.evntipcod,
                                param.ctbpezcod,
                                param.srvvlr
                                
      if sqlca.sqlcode <> 0 then                          
         let lr_ctb00g16.regiclhrrdat = current + 1 units second
         execute pctb00g16010 using param.atdsrvnum,
                                param.atdsrvano,
                                lr_ctb00g16.regiclhrrdat,
                                param.evntipcod,
                                param.ctbpezcod,
                                param.srvvlr
         if sqlca.sqlcode <> 0 then 
            if sqlca.sqlcode <> 0 then                          
               let lr_ctb00g16.regiclhrrdat = current + 2 units second
               execute pctb00g16010 using param.atdsrvnum,
                                      param.atdsrvano,
                                      lr_ctb00g16.regiclhrrdat,
                                      param.evntipcod,
                                      param.ctbpezcod,
                                      param.srvvlr
               if sqlca.sqlcode <> 0 then 
                  display "Erro(",sqlca.sqlcode using"<<<<<&",") ao inserir historico do provisionamento: ",param.atdsrvnum,param.atdsrvano
               end if
            end if
         end if
      end if 
   whenever error stop  
   
   
   #return lr_ctb00g16.srvvlr
                             
end function #ctb00g16_incsrvtipprv


#------------------------------------------------------------  
 function ctb00g16_selsrvprv(param)                          
#------------------------------------------------------------  
     
 define param record
     atdsrvnum  like dbsmatdpovhst.atdsrvnum,    
     atdsrvano  like dbsmatdpovhst.atdsrvano
  end record  
  
  define lr_ctb00g16 record
     regiclhrrdat  like dbsmatdpovhst.regiclhrrdat,    
     ctbpezcod     like dbsmatdpovhst.ctbpezcod,
     srvvlr        like dbsmatdpovhst.srvvlr
  end record 
  
 define lr_erro record         
     err    smallint,          
     msgerr char(300)          
 end record  
   
 define lr_retorno record
   erro         smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
   msgerro      char(20000)
 end record
 
 define l_tipoenvio smallint
 
  if m_ctb00g16_prep is null or
     m_ctb00g16_prep <> true then
     call ctb00g16_prepare()
  end if
  
  initialize lr_ctb00g16.* to null
  initialize lr_erro.* to null
  initialize lr_retorno.* to null
  
  let l_tipoenvio = 1
  
  open cctb00g16017 using param.atdsrvnum,
                          param.atdsrvano,
                          l_tipoenvio
  
  fetch cctb00g16017 into lr_ctb00g16.ctbpezcod,
                          lr_ctb00g16.regiclhrrdat,
                          lr_ctb00g16.srvvlr
          
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         
         let lr_erro.err = 100
         let lr_erro.msgerr = "Nao foi encontrado provisionamento",
                              " para o servico: ",param.atdsrvnum using "<<<<<<<<<<&",
                              "-",param.atdsrvano using "<&"
      else
         let lr_erro.err = sqlca.sqlcode
         let lr_erro.msgerr = "Erro(",sqlca.sqlcode using "<<<<<&",") ao busca provisionamento",
                              " para o servico: ",param.atdsrvnum using "<<<<<<<<<<&",
                              "-",param.atdsrvano using "<&"
      end if 
   else
      let lr_erro.err = 0
   end if  
  
  close cctb00g16017 
  
  return lr_erro.err   ,
         lr_erro.msgerr,
         lr_ctb00g16.ctbpezcod,   
         lr_ctb00g16.regiclhrrdat,
         lr_ctb00g16.srvvlr 
                          
end function #ctb00g16_selsrvprv


#-------------------------#  
function ctb00g16_vlrbxaprvdsp(param)  
#-------------------------#  
define param record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano 
end record

 define lr_ctb00g16_sel record
     regiclhrrdat  like dbsmatdpovhst.regiclhrrdat,
     ctbpezcod     like dbsmatdpovhst.ctbpezcod,
     srvvlr        like dbsmatdpovhst.srvvlr,
     msgerr        char(300),
     srvvlrprv     like dbsmatdpovhst.srvvlr 
  end record
   
  define lr_erro record         
     err    smallint,          
     msgerr char(300)          
  end record  
  
  define l_mensagem char(1000)

  let l_mensagem = null
  
   # verifica qual a sequencia do provisionamento 
   # para verificar o valor e realizar a baixa
   call ctb00g16_selsrvprv(param.atdsrvnum,param.atdsrvano)
      returning lr_erro.err   ,
                lr_erro.msgerr,
                lr_ctb00g16_sel.ctbpezcod, 
                lr_ctb00g16_sel.regiclhrrdat,
                lr_ctb00g16_sel.srvvlr
   
   if lr_erro.err <> 0 then
      display "Nao achou provisao"
      #call ctb00g16_incprvdsp(param.atdsrvnum,param.atdsrvano,3)  
      #  returning lr_ctb00g16_sel.msgerr, 
      #            lr_ctb00g16_sel.srvvlrprv
      #            
      #display "lr_ctb00g16_sel.msgerr:", lr_ctb00g16_sel.msgerr clipped  
      #
      #if lr_ctb00g16_sel.msgerr is not null then
         if l_mensagem is null then
            let l_mensagem = "Foram encontrados os seguintes erros para o servico ",
                                     param.atdsrvnum,'-',param.atdsrvano,": ",ASCII(13),
                                     ASCII(09),lr_erro.msgerr clipped,ASCII(13)
         else
            let l_mensagem = l_mensagem clipped,
                                     ASCII(09),lr_erro.msgerr clipped,ASCII(13)
         end if 
      #end if
      
      
      #call ctb00g16_selsrvprv(param.atdsrvnum,param.atdsrvano)
      #returning lr_erro.err   ,
      #          lr_erro.msgerr,
      #          lr_ctb00g16_sel.ctbpezcod, 
      #          lr_ctb00g16_sel.regiclhrrdat,
      #          lr_ctb00g16_sel.srvvlr
   end if
   
   
   display "lr_erro.err                 : ",lr_erro.err                  
   display "lr_erro.msgerr              : ",lr_erro.msgerr               
   display "lr_ctb00g16_sel.ctbpezcod   : ",lr_ctb00g16_sel.ctbpezcod    
   display "lr_ctb00g16_sel.regiclhrrdat: ",lr_ctb00g16_sel.regiclhrrdat 
   display "lr_ctb00g16_sel.srvvlr      : ",lr_ctb00g16_sel.srvvlr      
   
      
   # verifica qual o valor que deve ser realizada a baixa
   open cctb00g16018 using param.atdsrvnum,
                           param.atdsrvano,
                           lr_ctb00g16_sel.regiclhrrdat
   
   fetch cctb00g16018 into lr_ctb00g16_sel.srvvlr                
    
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_erro.err = 100
         let lr_erro.msgerr = "Nao foi encontrado provisionamento",
                              " para o servico: ",param.atdsrvnum using "<<<<<<<<<<&",
                              "-",param.atdsrvano using "<&"
      else
         let lr_erro.err = sqlca.sqlcode
         let lr_erro.msgerr = "Erro(",sqlca.sqlcode using "<<<<<&",") ao busca provisionamento",
                              " para o servico: ",param.atdsrvnum using "<<<<<<<<<<&",
                              "-",param.atdsrvano using "<&"
      end if 
      
      if l_mensagem is null then
         let l_mensagem = "Foram encontrados os seguintes erros para o servico ",
                                  param.atdsrvnum,'-',param.atdsrvano,": ",ASCII(13),
                                  ASCII(09),lr_erro.msgerr clipped,ASCII(13)
      else
         let l_mensagem = l_mensagem clipped,
                                  ASCII(09),lr_erro.msgerr clipped,ASCII(13)
      end if 
   else
      let lr_erro.err = 0
   end if 
   
   close cctb00g16018 
   
   return lr_erro.err,
          l_mensagem,
          lr_ctb00g16_sel.ctbpezcod,
          lr_ctb00g16_sel.srvvlr 
          
          
   
end function #ctb00g16_vlrbxaprvdsp

#-------------------------#  
function ctb00g16_bxaprvdsp(param)  
#-------------------------#  
define param record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano 
end record

 define lr_ctb00g16_sel record
     srvvlr        like dbsmatdpovhst.srvvlr,    
     ctbpezcod     like dbsmatdpovhst.ctbpezcod
  end record
 
 define lr_ctb00g16 record    
    ctbevnpamcod like dbskctbevnpam.ctbevnpamcod, 
    srvpovevncod like dbskctbevnpam.srvpovevncod, 
    srvajsevncod like dbskctbevnpam.srvajsevncod, 
    srvbxaevncod like dbskctbevnpam.srvbxaevncod, 
    empcod       like dbskctbevnpam.empcod      , 
    pcpsgrramcod like dbskctbevnpam.pcpsgrramcod, 
    pcpsgrmdlcod like dbskctbevnpam.pcpsgrmdlcod, 
    ctbsgrramcod like dbskctbevnpam.ctbsgrramcod, 
    ctbsgrmdlcod like dbskctbevnpam.ctbsgrmdlcod, 
    pgoclsflg    like dbskctbevnpam.pgoclsflg   , 
    srvdcrcod    like dbskctbevnpam.srvdcrcod   , 
    itaasstipcod like dbskctbevnpam.itaasstipcod, 
    bemcod       like dbskctbevnpam.bemcod      , 
    srvatdctecod like dbskctbevnpam.srvatdctecod, 
    c24astagp    like dbskctbevnpam.c24astagp   , 
    atopamflg    like dbskctbevnpam.atopamflg   
 end record
 
 define lr_erro record         
     err    smallint,          
     msgerr char(1000)          
  end record  
 
 define l_mensagem char(300)
 
 if m_ctb00g16_prep is null or
    m_ctb00g16_prep <> true then
    call ctb00g16_prepare()
 end if
 
 initialize lr_ctb00g16.* to null
 
 let l_mensagem = null
    # verifica qual o valor da baixa e qual a sequencia do evento de baixa
   display "param.atdsrvnum: ",param.atdsrvnum
   display "param.atdsrvano: ",param.atdsrvano
   call ctb00g16_vlrbxaprvdsp(param.atdsrvnum,param.atdsrvano)
     
     returning lr_erro.err,
               lr_erro.msgerr,
               lr_ctb00g16_sel.ctbpezcod, 
               lr_ctb00g16_sel.srvvlr
  
   display "lr_erro.err              : ",lr_erro.err             
   display "lr_erro.msgerr           : ",lr_erro.msgerr clipped          
   display "lr_ctb00g16_sel.ctbpezcod: ",lr_ctb00g16_sel.ctbpezcod
   display "lr_ctb00g16_sel.srvvlr   : ",lr_ctb00g16_sel.srvvlr   
    
    
    let lr_ctb00g16_sel.srvvlr = lr_ctb00g16_sel.srvvlr * (-1)
    
    open cctb00g16019 using lr_ctb00g16_sel.ctbpezcod
    fetch cctb00g16019 into lr_ctb00g16.ctbevnpamcod,  
                            lr_ctb00g16.srvpovevncod,
                            lr_ctb00g16.srvajsevncod,
                            lr_ctb00g16.srvbxaevncod,
                            lr_ctb00g16.empcod      ,
                            lr_ctb00g16.pcpsgrramcod,
                            lr_ctb00g16.pcpsgrmdlcod,
                            lr_ctb00g16.ctbsgrramcod,
                            lr_ctb00g16.ctbsgrmdlcod,
                            lr_ctb00g16.pgoclsflg   ,
                            lr_ctb00g16.srvdcrcod   ,
                            lr_ctb00g16.itaasstipcod,
                            lr_ctb00g16.bemcod      ,
                            lr_ctb00g16.srvatdctecod,
                            lr_ctb00g16.c24astagp   ,
                            lr_ctb00g16.atopamflg  
                             
     if sqlca.sqlcode <> 0 then    
         if sqlca.sqlcode = notfound then
            let lr_erro.err = 100
            let l_mensagem = "Nao foi encontrado registro na sequencia",
                                 " do servico: ",param.atdsrvnum using "<<<<<<<<<<&",
                                 "-",param.atdsrvano using "<&"
         else
            let lr_erro.err = sqlca.sqlcode
            let l_mensagem = "Erro(",sqlca.sqlcode using "<<<<<&",") ao buscar registro na sequencia",
                                 " do servico: ",param.atdsrvnum using "<<<<<<<<<<&",
                                 "-",param.atdsrvano using "<&"
         end if 
         
         if lr_erro.msgerr is null then
            let lr_erro.msgerr = "Foram encontrados os seguintes erros para o servico ",
                                     param.atdsrvnum,'-',param.atdsrvano,": ",ASCII(13),
                                     ASCII(09),l_mensagem clipped,ASCII(13)
         else
            let lr_erro.msgerr = lr_erro.msgerr clipped,
                                     ASCII(09),l_mensagem clipped,ASCII(13)
         end if 
         
     else
         call ctb00g16_incsrvtipprv (param.atdsrvnum,
                                     param.atdsrvano,
                                     4,
                                     lr_ctb00g16_sel.ctbpezcod,
                                     lr_ctb00g16_sel.srvvlr)
     end if  
        
    close cctb00g16019
    
    
   return lr_erro.err,
          lr_erro.msgerr,
          lr_ctb00g16.ctbevnpamcod,
          lr_ctb00g16.srvpovevncod,
          lr_ctb00g16.srvajsevncod,
          lr_ctb00g16.srvbxaevncod,
          lr_ctb00g16.empcod      ,
          lr_ctb00g16.pcpsgrramcod,
          lr_ctb00g16.pcpsgrmdlcod,
          lr_ctb00g16.ctbsgrramcod,
          lr_ctb00g16.ctbsgrmdlcod,
          lr_ctb00g16.pgoclsflg   ,
          lr_ctb00g16.srvdcrcod   ,
          lr_ctb00g16.itaasstipcod,
          lr_ctb00g16.bemcod      ,
          lr_ctb00g16.srvatdctecod,
          lr_ctb00g16.c24astagp   ,
          lr_ctb00g16.atopamflg   ,
          lr_ctb00g16_sel.srvvlr  

end function #ctb00g16_bxaprvdsp


#--------------------------------------------------------------------------#
function ctb00g16_ajusteprv(param)
#--------------------------------------------------------------------------#

    define param record
      atdsrvnum      like datmservico.atdsrvnum,
      atdsrvano      like datmservico.atdsrvano,
      vlrajuste      like dbsmopgitm.socopgitmvlr
    end record
    
    define lr_ctb00g16 record
       err           smallint, 
       msgerr        char(20000)
    end record 
    
    define lr_retorno record
      err           smallint,  # Codigo 2 quer dizer que devemos realizar a provisao do servico         
      msgerr        char(1000),
      srvvlrajst    like dbsmatdpovhst.srvvlr,
      vlrapgt       like dbsmopgitm.socopgitmvlr, 
      srvvlrprv     like dbsmatdpovhst.srvvlr,
      srvajsevncod  like dbskctbevnpam.srvajsevncod,
      srvpgtevncod  like dbskctbevnpam.srvpgtevncod,
      srvpovevncod  like dbskctbevnpam.srvpovevncod,
      srvatdctecod  like dbskctbevnpam.srvatdctecod,
      ctbpezcod     like dbsmatdpovhst.ctbpezcod   ,
      regiclhrrdat  like dbsmatdpovhst.regiclhrrdat
    end record
    
    define lr_busca record
      srvvlr        like dbsmatdpovhst.srvvlr,
      ctbpezcod     like dbsmatdpovhst.ctbpezcod,
      regiclhrrdat  like dbsmatdpovhst.regiclhrrdat 
    end record
    
    define l_tipoenvio smallint
    
    initialize lr_ctb00g16.*,lr_retorno.*,lr_busca.* to null 
    
    if m_ctb00g16_prep is null or
       m_ctb00g16_prep <> true then
       call ctb00g16_prepare()
    end if
    
    call ctb00g16_selsrvprv(param.atdsrvnum,param.atdsrvano)  
      returning lr_ctb00g16.err        ,
                lr_ctb00g16.msgerr     ,
                lr_retorno.ctbpezcod   ,
                lr_retorno.regiclhrrdat,
                lr_busca.srvvlr   
                
                
      display "lr_ctb00g16.err         : ",lr_ctb00g16.err         
      display "lr_ctb00g16.msgerr      : ",lr_ctb00g16.msgerr clipped 
      display "lr_retorno.ctbpezcod   : ",lr_retorno.ctbpezcod   
      display "lr_retorno.regiclhrrdat: ",lr_retorno.regiclhrrdat
      display "lr_busca.srvvlr      : ",lr_busca.srvvlr      
      
    # Não encontrou provisionamento para o servico, então temos que provisionar
    if  lr_ctb00g16.err = 100 or lr_ctb00g16.msgerr is not null then
    
      call ctb00g16_incprvdsp(param.atdsrvnum,param.atdsrvano,2)  
           returning lr_ctb00g16.msgerr, lr_retorno.srvvlrprv                       
       
       display "lr_ctb00g16.msgerr: ",lr_ctb00g16.msgerr clipped
       display "lr_retorno.srvvlrprv: ",lr_retorno.srvvlrprv
                                                                  
      # Conseguiu provisionar o servico, entao temos que pesquisar as informacoes
      if lr_ctb00g16.msgerr is null then             
         display "Provisionei o servico no momento do ajuste e pesquisei os valores"
         let l_tipoenvio = 1
         open cctb00g16017 using param.atdsrvnum,
                                 param.atdsrvano,
                                 l_tipoenvio 
         
         fetch cctb00g16017 into lr_retorno.ctbpezcod,
                                 lr_retorno.regiclhrrdat,
                                 lr_busca.srvvlr
         
         display "lr_retorno.ctbpezcod   : ",lr_retorno.ctbpezcod  
         display "lr_retorno.regiclhrrdat: ",lr_retorno.regiclhrrdat
         display "lr_busca.srvvlr     : ",lr_busca.srvvlr      
         
         let lr_ctb00g16.err = 2 # tipo de retorno para realizar a chamada contabil para a provisao do servico  
      else
         let lr_ctb00g16.err = 100     
      end if                                                              
    end if 
    
    display "Depois de verificar se precisa provisionar"
    display "param.atdsrvnum      : ",param.atdsrvnum
    display "param.atdsrvano      : ",param.atdsrvano
    display "lr_busca.srvvlr      : ",lr_busca.srvvlr  
    display "param.vlrajuste      : ",param.vlrajuste      
    display "lr_retorno.srvvlrprv : ",lr_retorno.srvvlrprv
    
    if lr_busca.srvvlr <> param.vlrajuste then
          let lr_retorno.srvvlrajst = param.vlrajuste - lr_busca.srvvlr
    else
       let lr_retorno.srvvlrajst = 0
    end if
    
    display "Valor final lr_ctb00g16.err: ",lr_ctb00g16.err
    display "Valor final lr_retorno.srvvlrajst: ",lr_retorno.srvvlrajst
    
    if lr_ctb00g16.err <> 0 and lr_ctb00g16.err <> 2 then    
       if lr_ctb00g16.err = 100 then
          let lr_retorno.err = 100
          let lr_retorno.msgerr = "Nao foi encontrado registro na sequencia",
                               " do servico: ",param.atdsrvnum using "<<<<<<<<<<&",
                               "-",param.atdsrvano using "<&"
       else
          let lr_retorno.err = sqlca.sqlcode
          let lr_retorno.msgerr = "Erro(",sqlca.sqlcode using "<<<<<&",") ao buscar registro na sequencia",
                               " do servico: ",param.atdsrvnum using "<<<<<<<<<<&",
                               "-",param.atdsrvano using "<&"
       end if 
       
    else
       
       if lr_retorno.srvvlrajst = 0 then
       else
          let l_tipoenvio = 2   
          
          initialize lr_busca.* to null 
          
          open cctb00g16017 using param.atdsrvnum,
                                  param.atdsrvano,
                                  l_tipoenvio 
          
          fetch cctb00g16017 into lr_busca.ctbpezcod,
                                  lr_busca.regiclhrrdat,
                                  lr_busca.srvvlr
          
          display "Ajuste ll_tipoenvio   : ",l_tipoenvio
          display "Ajuste lr_busca.ctbpezcod   : ",lr_busca.ctbpezcod  
          display "Ajuste lr_busca.regiclhrrdat: ",lr_busca.regiclhrrdat
          display "Ajuste lr_busca.srvvlr      : ",lr_busca.srvvlr      
          
          if sqlca.sqlcode = 100 then
             display "Gravar o evento de ajuste"
             call ctb00g16_incsrvtipprv(param.atdsrvnum,
                                        param.atdsrvano,
                                        2,lr_retorno.ctbpezcod,lr_retorno.srvvlrajst)
                                        
             let lr_retorno.err = 0
             let lr_retorno.msgerr = null
             
          else
             display "Ajuste ja existe: ",sqlca.sqlcode 
             let lr_retorno.srvvlrajst = 0
	           let lr_retorno.err = 1
          end if
          close cctb00g16017    
          
       end if
       
       open cctb00g16020 using param.atdsrvnum,           
                               param.atdsrvano            
                                                          
       fetch cctb00g16020 into lr_retorno.vlrapgt         
       
       close cctb00g16020
       
       # O valor deve ser negativo para gravar em nossa tabela e
       # facilitar o calculo no momento do relatorio
       let lr_retorno.vlrapgt = lr_retorno.vlrapgt*(-1)
       
       let l_tipoenvio = 5
       
       initialize lr_busca.* to null
       
       open cctb00g16017 using param.atdsrvnum,
                               param.atdsrvano,
                               l_tipoenvio 
       
       fetch cctb00g16017 into lr_busca.ctbpezcod,
                               lr_busca.regiclhrrdat,
                               lr_busca.srvvlr
       
       display "Pagamento lr_busca.ctbpezcod   : ",lr_busca.ctbpezcod  
       display "Pagamento lr_busca.regiclhrrdat: ",lr_busca.regiclhrrdat
       display "Pagamento lr_busca.srvvlr      : ",lr_busca.srvvlr      
       
       
       if sqlca.sqlcode = 100 then
          display "Gravar o evento de pagamento"
          call ctb00g16_incsrvtipprv(param.atdsrvnum,                                                      
                                     param.atdsrvano,                                                      
                                     5,lr_retorno.ctbpezcod,lr_retorno.vlrapgt)                           
        
        let lr_retorno.err = 0
        let lr_retorno.msgerr = null 
       else
          let lr_retorno.vlrapgt = 0
	        let lr_retorno.err = 1
       end if           
       close cctb00g16017  
    end if
    
    open cctb00g16021 using lr_retorno.ctbpezcod           
                                                       
    fetch cctb00g16021 into lr_retorno.srvajsevncod,  
                            lr_retorno.srvpgtevncod,
                            lr_retorno.srvpovevncod,
                            lr_retorno.srvatdctecod  
    close cctb00g16021
    
    display "lr_retorno.err ,           : ",lr_retorno.err           
    display "lr_retorno.msgerr,         : ",lr_retorno.msgerr        
    display "lr_retorno.srvvlrajst, : ",lr_retorno.srvvlrajst    
    display "lr_retorno.vlrapgt,    : ",lr_retorno.vlrapgt    
    display "lr_retorno.srvvlrprv   : ",lr_retorno.srvvlrprv
    display "param.vlrajuste         : ",param.vlrajuste
    display "lr_retorno.srvajsevncod: ",lr_retorno.srvajsevncod
    display "lr_retorno.srvpgtevncod: ",lr_retorno.srvpgtevncod
    display "lr_retorno.srvpovevncod: ",lr_retorno.srvpovevncod
    display "lr_retorno.srvatdctecod: ",lr_retorno.srvatdctecod
     
    if lr_ctb00g16.err = 2 then
       let lr_retorno.err = 2
    end if 
    
    
   return  lr_retorno.err ,
           lr_retorno.msgerr,
           lr_retorno.srvvlrajst,
           lr_retorno.vlrapgt,
           lr_retorno.srvvlrprv,
           lr_retorno.srvajsevncod,
           lr_retorno.srvpgtevncod,
           lr_retorno.srvpovevncod,
           lr_retorno.srvatdctecod
    
end function




#=============================================================================
function ctb00g16_envio_contabil(param)
#=============================================================================
   define param record
      srvpovevncod like dbskctbevnpam.srvpovevncod,
      ciaempcod    like datmservico.ciaempcod     ,
      succod       like datrservapol.succod       ,
      ramcod       like datrservapol.ramcod       ,
      modalidade   like rsamseguro.rmemdlcod      ,
      aplnumdig    like datrservapol.aplnumdig    ,
      itmnumdig    like datrservapol.itmnumdig    ,
      edsnumref    like datrservapol.edsnumref    ,  
      prporg       like datrligprp.prporg         ,
      prpnumdig    like datrligprp.prpnumdig      ,
      corsus       like abamcor.corsus            ,
      srvvlr       like dbsmatdpovhst.srvvlr      ,
      atdsrvnum    like datmservico.atdsrvnum     ,
      atdsrvano    like datmservico.atdsrvano     ,
      socopgnum    like dbsmopg.socopgnum         ,
      carteira     smallint                       ,
      atddat       like datmservico.atddat
   end record
   
   define lr_figrc006 record
          coderro     integer,
          menserro    char(30),
          msgid       char(24),
          correlid    char(24)
   end record
   
   define l_servico   char(50)
   define l_porposta  char(50)
   define l_cctcod    like dbscadtippgt.cctcod
   define l_succod    like dbscadtippgt.succod 
   define l_cctlclcod like ctgklcl.cctlclcod   
   define l_cctdptcod like ctgrlcldpt.cctdptcod 
   
   define l_xml          char(32766),
          l_docHandle    integer,
          l_sist_origem  char(3), # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
          l_caract_valor char(3)  # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil    
      
   
   initialize lr_figrc006.* to null
   initialize l_xml, l_docHandle to null
   let l_servico      = null
   let l_porposta     = null
   let l_cctcod       = null
   let l_succod       = null
   let l_cctlclcod    = null
   let l_cctdptcod    = null
   let l_sist_origem  = null # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
   let l_caract_valor = null # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
   let l_servico  = param.atdsrvnum using "<<<<<<<<<<<<&",param.atdsrvano using "<<<<<<<<&&"
   let l_porposta = param.prporg    using "<<<<<<<<<<<<&","/",param.prpnumdig using "<<<<<<<<&&"
   
   
   #Nao utilizamos a data passada como parametro, pois a contabilidade nao pode receber 
   #data como final de semana e se quebrar o mês não podemos enviar, por isso eles
   # estao montando uma funcao que nos retorne a data que devemosenviar de acordo com
   # a data que foi executado o serviço ou pago. Ate la iremos utilizar uma funcao nossa, utilizando o today
   let param.atddat = ctb00g16_datacompetencia()
   
   
   if param.carteira = 3 or param.carteira = 4 then
        
     open cctb00g16022 using param.atdsrvnum,   
                             param.atdsrvano
     fetch cctb00g16022 into l_cctcod,
                             l_succod
     
     
     let param.succod = l_succod
     let l_cctlclcod  = (l_cctcod / 10000)
     let l_cctdptcod  = (l_cctcod mod 10000)
     
     if l_cctcod is not null then
        whenever error continue
         execute pctb00g16023 using l_cctcod,
                                    param.atdsrvnum,   
                                    param.atdsrvano
        whenever error stop                           
     end if 
   else
     
     let l_cctlclcod = null
     let l_cctdptcod = null
     
   end if  
   
   # Inicio - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
   case param.ciaempcod
     
     when 43
        let l_sist_origem  = 443
        let l_caract_valor = 443
        
     otherwise
        let l_sist_origem  = 29
        let l_caract_valor = 29
    
   end case
   # Fim - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
   
   
   call fgl_inicia_protocolo_camada()
   
   call fgl_novo_documento("Eventos") RETURNING l_docHandle   
   
   display "param.srvpovevncod: ",param.srvpovevncod
   
   if param.succod is null or 
      param.succod = ' ' or 
      param.succod = '' or
      param.succod = 0  then
     let param.succod = 1
   end if 
   
   display "l_servico: ", l_servico
   display "l_sist_origem: ", l_sist_origem
    
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/SistemaOrigem", l_sist_origem clipped) # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/CodigoEvento",param.srvpovevncod)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Empresa/Codigo", param.ciaempcod)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Empresa/Sucursal/Codigo", param.succod)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Empresa/Local/Codigo", l_cctlclcod)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Empresa/Departamento/Codigo", l_cctdptcod)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Empresa/ModalidadeRamo/Codigo", param.modalidade)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Empresa/Ramo/Codigo", param.ramcod)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Entidades/Corretor/SUSEP", param.corsus)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/DataCompetencia/Dia", DAY(param.atddat))
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/DataCompetencia/Mes", MONTH(param.atddat))
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/DataCompetencia/Ano", YEAR(param.atddat))
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Valores/Valor/Valor", param.srvvlr)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Valores/Valor/CaracteristicaValor", l_caract_valor clipped) # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/ChavePrimariaOrigem", l_servico)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Documentos/Proposta/Numero", l_porposta)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Documentos/Apolice/Numero", param.aplnumdig)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Documentos/Endosso/Numero", param.edsnumref)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Documentos/DocumentodePagamento/Numero", param.socopgnum)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Documentos/OrdemPagamento/Numero", param.socopgnum)
   call fgl_atualiza_documento(l_docHandle, "Eventos/Evento/Documentos/Sinistro/Numero", l_servico)
   
   
   let l_xml = fgl_retorna_documento(l_docHandle)
   
   display "l_xml: ", l_xml clipped
   
   call fgl_finaliza_protocolo_camada()
  
   if param.srvpovevncod <> '443.000' then # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
        
        display "Entrei no evento <> 443.000."
        
        call figrc006_enviar_datagrama_mq_rq("CONTABIL.ENV", l_xml, l_sist_origem, loop())
               returning lr_figrc006.*
       
        if lr_figrc006.coderro <> 0 then
          if lr_figrc006.coderro = 2009 then
            
             call MQ4GL_Init() returning lr_figrc006.coderro,lr_figrc006.menserro
            
             initialize lr_figrc006.* to null
            
             call figrc006_enviar_datagrama_mq_rq("CONTABIL.ENV", l_xml, "29", loop())
                returning lr_figrc006.*
              
             if lr_figrc006.coderro <> 0 then
                display "l_xml", l_xml clipped                                      
                display "retorno lr_figrc006.coderro", lr_figrc006.coderro          
                display "retorno lr_figrc006.menserro", lr_figrc006.menserro clipped
             else
                display "Sucesso"     
             end if
          else
             display "l_xml", l_xml clipped
             display "retorno lr_figrc006.coderro", lr_figrc006.coderro 
             display "retorno lr_figrc006.menserro", lr_figrc006.menserro clipped    
          end if 
        else
          display "Sucesso"
        end if
   else # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
        
        display "Nao entrei no evento <> 443.000."
   
   end if # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
  
  initialize l_xml, l_docHandle to null

end function


#=============================================================================
function ctb00g16_datacompetencia()
#=============================================================================
  
  define l_data_ref  date
  define l_dia       smallint
  define l_data_aux  date 
  define l_data_mes  date
  define l_data_comp date
  
  initialize  l_data_ref,   
              l_dia     , 
              l_data_aux, 
              l_data_mes, 
              l_data_comp to null
  
  let l_data_ref = today
  
  # retorna um dia util para a data passada, podendo retornar a propria data ou o proximo dia
  call dias_uteis(l_data_ref, 0, "", "N", "N") 
       returning l_data_aux
         
  display "Dia passado: ",l_data_ref
  display "dia util: ",l_data_aux       
         
  #--- TRATA ULTIMO DIA DO MES------------->>>>>   se o último dia do mês for feriado, a data deve ser a do último dia útil do mês
  
  if (month(l_data_aux) <> month(l_data_ref)) then
     let l_data_mes = l_data_ref - 3 units day
     
  call dias_uteis(l_data_mes, 0, "", "N", "N") 
  returning l_data_aux  
          
  end if

  return l_data_aux
  
end function