#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: cts00g09                                                   #
# ANALISTA RESP..: BEATRIZ ARAUJO                                             #
# PSI/OSF........: PSI-2010-00003PR                                           #
#                  CIRCULAR 395 DA SUSEP - RAMO DE CONTABILIZACAO             #
#                  DAS CLAUSULAS                                              #
#............................................................................ #
# DESENVOLVIMENTO: BEATRIZ ARAUJO                                             #
# LIBERACAO......: **********                                                 #
#............................................................................ #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA    ORIGEM       ALTERACAO                          #
# ---------- ---------------  -----------  ---------------------------------- #
# 02/07/2013 Celso Yamahaki   13071551     Chamada da função re               #
#                                                                             #
# 12/11/2014 Rodolfo Massini  14-19758/PR  Alteracoes para o projeto "Entrada #
#                                          Camada Contabil"                   #
#-----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_cts00g09_prepare smallint
define m_display smallint

 define m_cts00g09 record
        succod      like datrservapol.succod,
        ramcod      like gtakram.ramcod,
        aplnumdig   like datrservapol.aplnumdig,
        prporg      like datrligprp.prporg,
        prpnumdig   like datrligprp.prpnumdig,
        prporgidv   like apbmitem.prporgidv,
        prpnumidv   like apbmitem.prpnumidv,
        modalidade  like rsamseguro.rmemdlcod
 end record

#============================================
function cts00g09_prepare()
#============================================

define l_sql char(6000)

  let l_sql  =  null

  let l_sql = "select succod,       ",
              "       ramcod,       ",
              "       aplnumdig     ",
              "  from datrservapol  ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "
  prepare pcts00g09_001 from l_sql
  declare ccts00g09_001 cursor for pcts00g09_001

  # Busca a proposta que o servico foi feito
  let l_sql = "select a.prporg,                       ",
              "       a.prpnumdig                     ",
              "  from datrligprp a                    ",
              "where a.lignum = (select min(lignum)   ",
              "                   from datmligacao    ",
              "                   where atdsrvnum = ? ",
              "                     and atdsrvano = ?)"

  prepare pcts00g09_002 from l_sql
  declare ccts00g09_002 cursor for pcts00g09_002

  # busca a empresa do servico
  let l_sql = "select ciaempcod    ",
              "  from datmservico   ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "

  prepare pcts00g09_003 from l_sql
  declare ccts00g09_003 cursor for pcts00g09_003


  # busca o sistema da proposta
  let l_sql = "select sisemscod ",
              "  from pgakorigem",
              " where prporg = ?"

  prepare pcts00g09_004 from l_sql
  declare ccts00g09_004 cursor for pcts00g09_004


  # busca o tipo da op
  let l_sql = "select soctip  ",
              "  from dbsmopg o, ",
              "       dbsmopgitm i ",
              " where o.socopgnum = i.socopgnum ",
              "   and i.atdsrvnum = ? ",
              "   and i.atdsrvano = ? "

  prepare pcts00g09_005 from l_sql
  declare ccts00g09_005 cursor for pcts00g09_005


  # busca o tipo da op
  let l_sql = "select ligdat,ligdat  ",
              "  from datmligacao a ",
              " where a.lignum = (select min(lignum) from datmligacao b ",
                                " where b.atdsrvnum = ? ",
                                "   and b.atdsrvano = ?)"

  prepare pcts00g09_006 from l_sql
  declare ccts00g09_006 cursor for pcts00g09_006


  let l_sql = " select corsus "
               ,"from  apamcor "
               ," where prporgpcp = ? "
               ," and prpnumpcp = ? "
               ," and corlidflg = 'S' "
   prepare pcts00g09_007 from l_sql
   declare ccts00g09_007 cursor for pcts00g09_007
   
    let l_sql = " select lclnumseq,     "
                 ,"      lclrsccod      "
                 ," from datmsrvre      "
                 ,"where atdsrvnum = ?  "
                 ,"  and atdsrvano = ?  "
   prepare pcts00g09_008 from l_sql              
   declare ccts00g09_008 cursor for pcts00g09_008
   
   let l_sql = " select clscod       ",
                  "from abbmclaus    ",  
                  "where succod  = ? ", 
                  "and aplnumdig = ? ", 
                  "and itmnumdig = ? ", 
                  "and dctnumseq = ? " 
   prepare pcts00g09_009 from l_sql                   
   declare ccts00g09_009 cursor for pcts00g09_009     
   
   
let m_cts00g09_prepare = true  
   
end function


#Verifica a qual a clausula que deu origem ao serviço 
#==========================================
function cts00g09_ramocontabil(param)
#==========================================
 define param     record 
     atdsrvnum    like datmservico.atdsrvnum,   
     atdsrvano    like datmservico.atdsrvano,
     modalidade   like rsamseguro.rmemdlcod,
     ramcod       like datrservapol.ramcod 
 end record

 define lr_retorno record 
        coderro    smallint, 
        mensagem   char(400),
        ramcod     like rsatdifctbramcvs.ramcod,
        ramgrpcod  like gtakram.ramgrpcod,
        ctbramcod  like rsatdifctbramcvs.ctbramcod, 
        ctbmdlcod  like rsatdifctbramcvs.ctbmdlcod,  
        clscod     like rsatdifctbramcvs.clscod,
        pgoclsflg  like dbskctbevnpam.pgoclsflg     
 end record  


 define l_cts00g09 record        
         clscod      like rsatdifctbramcvs.clscod   ,# codigo da clausula            
         ctbramcod   like rsatdifctbramcvs.ctbramcod,# codigo ramo contabil          
         ctbmdlcod   like rsatdifctbramcvs.ctbmdlcod, # codigo modalidade contabil
         ciaempcod   like datmservico.ciaempcod
 end record
         
 define l_retorno record        
      coderro     smallint, #0-OK, 1-nao encontrou, 2-ocorreu algum erro
      msgerro     char(200), # quando for codigo 2
      ctbramcod   like rsatdifctbramcvs.ctbramcod, # codigo ramo contabil          
      ctbmdlcod   like rsatdifctbramcvs.ctbmdlcod  # codigo modalidade contabil
 end record 
 
 define lr_ctb00g16 record
    erro         smallint,     # 0- Encontrou, 1 - nao encontrou, 3- cancelado/bloqueado , 4 erro
    msgerro      char(300),
    srvdcrcod    like datkdcrorg.srvdcrcod,
    bemcod       like datkdcrorg.bemcod   ,
    atoflg       like datkdcrorg.atoflg   ,
    itaasstipcod like datkassunto.itaasstipcod,
    c24astagp    like datkassunto.c24astagp,
    c24astcod    like datkassunto.c24astcod,
    c24astdes    like datkassunto.c24astdes,
    avialgmtv    like datmavisrent.avialgmtv
 end record
 

# inicializa as variaveis
initialize l_cts00g09.* to null   
initialize lr_retorno.* to null 
initialize l_retorno.* to null 

   display "PARAMETROS"
   display "param.atdsrvnum : ",param.atdsrvnum    
   display "param.atdsrvano : ",param.atdsrvano 
   display "param.modalidade: ",param.modalidade
   display "param.ramcod    : ",param.ramcod    

let m_display = true 

   # prepara os cursores  
   if m_cts00g09_prepare is null or
      m_cts00g09_prepare <> true then
      call cts00g09_prepare()
   end if    
    
   #---------------------------------------|               
   # TRAZ A APOLICE DO SERVICO OU PROPOSTA |               
   #---------------------------------------|     
   call cts00g09_apolprop(param.atdsrvnum,param.atdsrvano)
   
   
   #-------------------------------------------------------------------------------|  
   # TRAZ A DECORRENCIA DO SERVICO, BEM ATENDIDO E PARA QUEM O SERVICO FOI PRESTADO|  
   #-------------------------------------------------------------------------------|  
   call ctb00g16_info_serv(param.atdsrvnum,param.atdsrvano)                                    
      returning lr_ctb00g16.erro         ,                                                
                lr_ctb00g16.msgerro      ,                                                
                lr_ctb00g16.srvdcrcod    ,                                                
                lr_ctb00g16.bemcod       ,                                                
                lr_ctb00g16.atoflg       ,                                                
                lr_ctb00g16.itaasstipcod ,                                                
                lr_ctb00g16.c24astagp    ,
                lr_ctb00g16.c24astcod    , 
                lr_ctb00g16.c24astdes    ,
                lr_ctb00g16.avialgmtv    
                                                                    
   
   #-----------------------------------------------|
   # TRAZ A CLAUSULA QUE DEU DIREITO AO SERVICO    |
   #-----------------------------------------------|
   call cts20g00_clausula(param.atdsrvnum,param.atdsrvano)
        returning lr_retorno.coderro,
                  lr_retorno.mensagem,
                  l_cts00g09.clscod,
                  lr_retorno.ramcod 
                  
       display "coderro: ", lr_retorno.coderro  
       display "mensagem: ", lr_retorno.mensagem clipped 
       display "clscod: ", l_cts00g09.clscod 
       display "ramcod: ", lr_retorno.ramcod  
        
   if l_cts00g09.clscod is not null and
      l_cts00g09.clscod <> " " then
      
       #------------------------------------|
       # TRAZ O GRUPO DO RAMO DA APOLICE    |
       #------------------------------------|
   display "cts00g09_grupo_ramo"
   display "Servico ", param.atdsrvnum, "/", param.atdsrvano

       call cts00g09_grupo_ramo(param.atdsrvnum,param.atdsrvano,lr_retorno.ramcod)
            returning lr_retorno.coderro,lr_retorno.ramgrpcod 
            
       display "ramgrpcod: ", lr_retorno.ramgrpcod      
              
       if lr_retorno.coderro = 1 then
       
          case lr_retorno.ramgrpcod
          	when 1 # AUTO
          	        display "AUTO"
          		call cts00g09_contabil_auto(param.atdsrvnum,
          		                            param.atdsrvano,
          		                            l_cts00g09.clscod,
          		                            lr_ctb00g16.srvdcrcod    ,
          		                            lr_ctb00g16.bemcod       ,
          		                            lr_ctb00g16.itaasstipcod)
          		     returning l_retorno.coderro,  
          		               lr_retorno.ctbramcod,
          		               lr_retorno.ctbmdlcod,
          		               lr_retorno.pgoclsflg
          		if l_retorno.coderro <> 0 then
          		   display "Erro ao locaziar ramo contabil do servico AUTO :",param.atdsrvnum,"-",
          		            param.atdsrvano," codigo: ",l_retorno.coderro
          		   display "Ramo contabil sera o ramo principal: ",m_cts00g09.ramcod, " modalidade: ",m_cts00g09.modalidade
          		   let lr_retorno.ctbramcod = m_cts00g09.ramcod
          		   let lr_retorno.ctbmdlcod = m_cts00g09.modalidade
          		end if
          	when 4 #RE
          	        display "RE"
          		call cts00g09_contabil_re(param.atdsrvnum, 
          		                          param.atdsrvano, 
          		                          l_cts00g09.clscod)
          		returning l_retorno.coderro,  
          		          l_retorno.msgerro,  
          		          lr_retorno.ctbramcod,
          		          lr_retorno.ctbmdlcod,
          		          lr_retorno.pgoclsflg
          		          
          		if l_retorno.coderro <> 0 then
          		   display "Erro ao locaziar ramo contabil do servico RE :",param.atdsrvnum,"-",param.atdsrvano, 
          		           " codigo: ",l_retorno.coderro, "Mensagem: ",l_retorno.msgerro clipped
          		   display "Ramo contabil sera o ramo principal: ",m_cts00g09.ramcod, " modalidade: ",m_cts00g09.modalidade
          		   let lr_retorno.ctbramcod = m_cts00g09.ramcod
          		   let lr_retorno.ctbmdlcod = m_cts00g09.modalidade
          		end if
          end case 
          #display "Erro: ",l_retorno.coderro
          let lr_retorno.clscod    = l_cts00g09.clscod
          #let lr_retorno.pgoclsflg = "G"
          
       else
          let lr_retorno.ctbramcod = m_cts00g09.ramcod      
          let lr_retorno.ctbmdlcod = m_cts00g09.modalidade 
          let lr_retorno.clscod    = l_cts00g09.clscod 
          #let lr_retorno.pgoclsflg = "G" 
       end if 
          
   else 
         call cts00g09_semRamo(param.atdsrvnum, 
          		       param.atdsrvano, 
          		       l_cts00g09.clscod)
              returning  lr_retorno.ctbramcod,
                         lr_retorno.ctbmdlcod          
         display "VARIAVEIS DE RETORNO DO SERVICO SEM CLAUSULA"
         display "lr_retorno.ctbramcod: ",lr_retorno.ctbramcod     
         display "lr_retorno.ctbmdlcod: ",lr_retorno.ctbmdlcod
         display "l_cts00g09.clscod:    ",l_cts00g09.clscod
         
         let lr_retorno.clscod    = 0
         let lr_retorno.pgoclsflg = "N"                                  
   end if 
   
   display "return cts00g09_ramocontabil"
   display "ctbramcod: ", lr_retorno.ctbramcod
   display "ctbmdlcod: ", lr_retorno.ctbmdlcod
   display "clscod: ", lr_retorno.clscod
   display "pgoclsflg: ", lr_retorno.pgoclsflg
   
return lr_retorno.ctbramcod,
       lr_retorno.ctbmdlcod,
       lr_retorno.clscod,
       lr_retorno.pgoclsflg    
   
   
end function


# Funcao que busca o numero da apolice do servico
# e se nao tiver pega a proposta
#========================================== 
function cts00g09_apolprop(param)
#========================================== 
 define param     record 
     atdsrvnum    like datmservico.atdsrvnum,   
     atdsrvano    like datmservico.atdsrvano
 end record

define cts00g09_documento    record                                                
      succod      like datrservapol.succod,                                        
      ramcod      like datrservapol.ramcod,                                        
      aplnumdig   like datrservapol.aplnumdig,                                     
      prporg      like datrligprp.prporg,    #Origem de Proposta de Seguro         
      prpnumdig   like datrligprp.prpnumdig, #Numero/digito de proposta de seguro 
      modalidade  like rsamseguro.rmemdlcod   
end record                                      

define lr_retorno record
      ciaempcod   like datmservico.ciaempcod,
      soctip      like dbsmopg.soctip
end record


initialize lr_retorno.* to null
initialize cts00g09_documento.* to null

   
   call cts00g09_semDocumento(param.atdsrvnum,param.atdsrvano)
              returning lr_retorno.ciaempcod,
                        lr_retorno.soctip  
   
   
   
   call cts00g09_apolice(param.atdsrvnum,
                         param.atdsrvano,
                         1,# para retorno dos parametros da circular395
                         lr_retorno.ciaempcod,  
                         lr_retorno.soctip)                         
        returning cts00g09_documento.succod,
                  cts00g09_documento.ramcod,    
                  cts00g09_documento.aplnumdig,
                  cts00g09_documento.prporg,   
                  cts00g09_documento.prpnumdig,
                  cts00g09_documento.modalidade
               
   if cts00g09_documento.succod is null or
      cts00g09_documento.succod = " " 
      then     
      let cts00g09_documento.succod = 0  
   end if 
   
   if cts00g09_documento.ramcod is null or
      cts00g09_documento.ramcod = " " 
      then     
      let cts00g09_documento.ramcod = 0  
   end if 
   
   if cts00g09_documento.aplnumdig is null or
      cts00g09_documento.aplnumdig = " " 
      then     
      let cts00g09_documento.aplnumdig = 0  
   end if
   
   if cts00g09_documento.prporg is null or
      cts00g09_documento.prporg = " " 
      then     
      let cts00g09_documento.prporg = 0  
   end if
   
   if cts00g09_documento.prpnumdig is null or
      cts00g09_documento.prpnumdig = " " 
      then     
      let cts00g09_documento.prpnumdig = 0  
   end if
   
   if cts00g09_documento.modalidade is null or
      cts00g09_documento.modalidade = " " 
      then     
      let cts00g09_documento.modalidade = 0  
   end if
 
   let m_cts00g09.succod    = cts00g09_documento.succod  
   let m_cts00g09.ramcod    = cts00g09_documento.ramcod  
   let m_cts00g09.aplnumdig = cts00g09_documento.aplnumdig
   let m_cts00g09.prporg    = cts00g09_documento.prporg 
   let m_cts00g09.prpnumdig = cts00g09_documento.prpnumdig
   let m_cts00g09.modalidade = cts00g09_documento.modalidade
   
end function



# Funcao que busca o grupo do ramo
#========================================== 
function cts00g09_grupo_ramo(param)
#========================================== 

 define param     record 
     atdsrvnum    like datmservico.atdsrvnum,   
     atdsrvano    like datmservico.atdsrvano,
     ramcod       like datrservapol.ramcod
 end record
 
 
 define lr_retorno    record
        resultado     smallint,
        mensagem      char(60),
        ramgrpcod     like gtakram.ramgrpcod,
        ciaempcod     like datmservico.ciaempcod
 end record
  
  initialize lr_retorno.* to null
  
  
  whenever error continue                                                        
	  open ccts00g09_003 using param.atdsrvnum,                              
	                           param.atdsrvano                               
	  fetch ccts00g09_003 into lr_retorno.ciaempcod
	                           
	  close ccts00g09_003                                                    
  whenever error stop  
    
   call cty10g00_grupo_ramo(lr_retorno.ciaempcod,param.ramcod)                 
       returning lr_retorno.resultado, # 1- Achou , 2- não encontrou, 3- deu erro  
                 lr_retorno.mensagem ,                                             
                 lr_retorno.ramgrpcod  # 4- RE , 1- AUTO                                    
   return lr_retorno.resultado,lr_retorno.ramgrpcod
   
end function
         
# Funcao busca o ramo contabil de servico AUTO
#========================================== 
function cts00g09_contabil_auto(param)
#==========================================

define param     record 
     atdsrvnum    like datmservico.atdsrvnum,   
     atdsrvano    like datmservico.atdsrvano,
     clscod       like rsatdifctbramcvs.clscod,
     srvdcrcod    like datkdcrorg.srvdcrcod,
     bemcod       like datkdcrorg.bemcod   ,
     itaasstipcod like datkassunto.itaasstipcod
 end record

 define l_retorno record        
     coderro     smallint,  # 0-OK , nao eh 0 ocorreu erro
     ctbramcod   like rsatdifctbramcvs.ctbramcod,# codigo ramo contabil          
     ctbmdlcod   like rsatdifctbramcvs.ctbmdlcod, # codigo modalidade contabil
     pgoclsflg   like dbskctbevnpam.pgoclsflg    # Clausula gratuita ou paga
 end record
 
                                                         
  if m_cts00g09.aplnumdig <> 0 and
     m_cts00g09.prpnumdig = 0 then
    
    #---------------------------------------|               
    # TRAZ O RAMO CONTABIL QUANDO E APOLICE |               
    #---------------------------------------|
    display "Parametros passados para o AUTO" 
    display "m_cts00g09.succod   : ",m_cts00g09.succod   
    display "m_cts00g09.aplnumdig: ",m_cts00g09.aplnumdig
    display "param.clscod        : ",param.clscod  
    display "param.srvdcrcod     : ",param.srvdcrcod  
    display "param.bemcod        : ",param.bemcod     
    display "param.itaasstipcod  : ",param.itaasstipcod          
    
    call faemc395_ramo_cls_apl(m_cts00g09.succod,     #Sucursal
                               m_cts00g09.aplnumdig,  #Apolice
                               param.clscod,          #Clausula
                               param.srvdcrcod,       #Decorrencia do servico
                               param.bemcod,          #Bem atendido
                               param.itaasstipcod)    #Para quem os ervico foi prestado
          returning l_retorno.coderro,      #Codigo de erro
                    l_retorno.ctbramcod,    #ramo contabil
                    l_retorno.ctbmdlcod,    #modalidade contabil
                    l_retorno.pgoclsflg     #Clausula gratuita ou paga
  else
     
     #----------------------------------------|               
     # TRAZ O RAMO CONTABIL QUANDO E PROPOSTA |               
     #----------------------------------------|
     
     let m_cts00g09.prporgidv = 0
     let m_cts00g09.prpnumidv = 0
     
     
     display "Parametros passados para o AUTO"             
     display "m_cts00g09.prporg   : ",m_cts00g09.prporg    
     display "m_cts00g09.prpnumdig: ",m_cts00g09.prpnumdig 
     display "m_cts00g09.prporgidv: ",m_cts00g09.prporgidv
     display "m_cts00g09.prpnumidv: ",m_cts00g09.prpnumidv 
     display "param.clscod        : ",param.clscod
     display "param.srvdcrcod     : ",param.srvdcrcod     
     display "param.bemcod        : ",param.bemcod        
     display "param.itaasstipcod  : ",param.itaasstipcod   
             
     call faemc395_ramo_cls_prp(m_cts00g09.prporg,        #Origem proposta                         
                                m_cts00g09.prpnumdig,     #Numero proposta                  
                                m_cts00g09.prporgidv,     #Origem proposta individual
                                m_cts00g09.prpnumidv,     #Numero proposta individual
                                param.clscod,             #Clausula                         
                                param.srvdcrcod,          #Decorrencia do servico           
                                param.bemcod,             #Bem atendido                    
                                param.itaasstipcod)       #Para quem os ervico foi prestado
          returning l_retorno.coderro,      #Codigo de erro       
                    l_retorno.ctbramcod,    #ramo contabil        
                    l_retorno.ctbmdlcod,    #modalidade contabil  
                    l_retorno.pgoclsflg     #Clausula gratuita ou paga             
  end if 
  
  display "Retorno da funcao AUTO"
  display "l_retorno.coderro  : ",l_retorno.coderro  
  display "l_retorno.ctbramcod: ",l_retorno.ctbramcod
  display "l_retorno.ctbmdlcod: ",l_retorno.ctbmdlcod 
  display "l_retorno.coderro: ",l_retorno.coderro
  display "l_retorno.pgoclsflg: ",l_retorno.pgoclsflg
  
  if l_retorno.coderro <> 0 then
     let l_retorno.ctbramcod = m_cts00g09.ramcod
     let l_retorno.ctbmdlcod = m_cts00g09.modalidade 
     let l_retorno.pgoclsflg = 'N'   
  end if  
   
   
   #if l_retorno.ctbramcod = 531 then
   #   let l_retorno.pgoclsflg = 'N'
   #else
   #   let l_retorno.pgoclsflg = 'S'
   #end if
   
      
 return l_retorno.coderro,l_retorno.ctbramcod,
        l_retorno.ctbmdlcod,l_retorno.pgoclsflg
      
        
end function



# Funcao busca o ramo contabil de servico RE
#========================================== 
function cts00g09_contabil_re(param)
#==========================================

define param     record 
     atdsrvnum    like datmservico.atdsrvnum,   
     atdsrvano    like datmservico.atdsrvano,
     clscod       like rsatdifctbramcvs.clscod
 end record

 define l_retorno record        
     coderro     smallint, #0-OK, 1-nao encontrou, 2-ocorreu algum erro
     msgerro     char(200), # quando for codigo 2
     ctbramcod   like rsatdifctbramcvs.ctbramcod,# codigo ramo contabil          
     ctbmdlcod   like rsatdifctbramcvs.ctbmdlcod, # codigo modalidade contabil
     pgoclsflg   like dbskctbevnpam.pgoclsflg    # Clausula gratuita ou paga
 end record
   
 define l_lclnumseq like datmsrvre.lclnumseq
 define l_lclrsccod like datmsrvre.lclrsccod
   
    # prepara os cursores  
   if m_cts00g09_prepare is null or
      m_cts00g09_prepare <> true then
      call cts00g09_prepare()
   end if   
   
   open ccts00g09_008 using param.atdsrvnum,
                            param.atdsrvano
   
   fetch  ccts00g09_008 into l_lclnumseq,
                             l_lclrsccod
   
   close ccts00g09_008
   
   display 'PRAMETROS PASSADOS PARA O RE'
   display 'm_cts00g09.succod:' ,m_cts00g09.succod
   display 'm_cts00g09.ramcod: ',m_cts00g09.ramcod
   display 'm_cts00g09.aplnumdig: ',m_cts00g09.aplnumdig
   display 'm_cts00g09.prporg: ',m_cts00g09.prporg
   display 'm_cts00g09.prpnumdig: ',m_cts00g09.prpnumdig
   display 'param.clscod: ',param.clscod  
   display 'l_lclnumseq: ',l_lclnumseq
   display 'l_lclrsccod: ',l_lclrsccod
   
   call framo605(m_cts00g09.succod,         #Sucursal
                 m_cts00g09.ramcod,         #Ramo
                 m_cts00g09.aplnumdig,      #Apolice
                 m_cts00g09.prporg,         #Origem proposta
                 m_cts00g09.prpnumdig,      #Numero proposta
                 param.clscod,              #Clausula
                 0           ,              #Codigo da cobertura
                 l_lclrsccod ,              #Codigo do local de risco
                 0)                         #Bloco do condominio
       returning l_retorno.coderro,         #Codigo de erro                         
                 l_retorno.msgerro,         #Mensagem de erro
                 l_retorno.ctbramcod,       #ramo contabil            
                 l_retorno.ctbmdlcod,       #modalidade contabil      
                 l_retorno.pgoclsflg        #Clausula gratuita ou paga
 
   display 'RETORNO DO RE'
   display 'l_retorno.coderro: ',l_retorno.coderro
   display 'l_retorno.msgerro: ',l_retorno.msgerro clipped
   display 'l_retorno.ctbramcod: ',l_retorno.ctbramcod
   display 'l_retorno.ctbmdlcod: ',l_retorno.ctbmdlcod 
   display "l_retorno.pgoclsflg: ",l_retorno.pgoclsflg
  
 if l_retorno.coderro <> 0 then
     let l_retorno.ctbramcod = m_cts00g09.ramcod
     let l_retorno.ctbmdlcod = m_cts00g09.modalidade
  end if     
      
 return l_retorno.coderro,l_retorno.msgerro,
        l_retorno.ctbramcod,l_retorno.ctbmdlcod,
        l_retorno.pgoclsflg 
       
        
end function



# FUNCAO FEITA PARA CASOS EM QUE O SERVICO NAO TEM CLAUSULA
#========================================== 
function cts00g09_semRamo(param)
#========================================== 

define param     record 
     atdsrvnum    like datmservico.atdsrvnum,   
     atdsrvano    like datmservico.atdsrvano,
     clscod       like rsatdifctbramcvs.clscod
 end record

define l_retorno record        
      coderro     smallint, #0-OK, 1-nao encontrou, 2-ocorreu algum erro
      msgerro     char(200), # quando for codigo 2
      ctbramcod   like rsatdifctbramcvs.ctbramcod, # codigo ramo contabil          
      ctbmdlcod   like rsatdifctbramcvs.ctbmdlcod, # codigo modalidade contabil
      sisemscod   like pgakorigem.sisemscod,
      pgoclsflg   like dbskctbevnpam.pgoclsflg    # Clausula gratuita ou paga   
 end record

initialize l_retorno.* to null

display "cts00g09_semRamo"
display "aplnumdig: ", m_cts00g09.aplnumdig

  
   if m_cts00g09.aplnumdig <> 0 and 
      m_cts00g09.prpnumdig = 0 then   
          
      let l_retorno.ctbramcod = m_cts00g09.ramcod
      let l_retorno.ctbmdlcod = m_cts00g09.modalidade
      
   else         
      display "prporg: ", m_cts00g09.prporg    
      call cts00g09_sisProposta(m_cts00g09.prporg)
        returning l_retorno.sisemscod 
      display "sisemscod : ", l_retorno.sisemscod 
      
      case l_retorno.sisemscod
         
         when "RE"  
             display "Chamei o RE cts00g09_contabil_re "
             display "param.atdsrvnum: ",param.atdsrvnum
             display "param.atdsrvano: ",param.atdsrvano
             display "param.clscod   : ",param.clscod   
             call cts00g09_contabil_re(param.atdsrvnum,param.atdsrvano,param.clscod)
                             returning l_retorno.coderro,  
                                       l_retorno.msgerro,  
                                       l_retorno.ctbramcod,
                                       l_retorno.ctbmdlcod,
                                       l_retorno.pgoclsflg
          otherwise
              let l_retorno.ctbramcod = m_cts00g09.ramcod     
              let l_retorno.ctbmdlcod = m_cts00g09.modalidade       
                                                     
      end case
   end if         

display "sisemscod: ", l_retorno.sisemscod
display "ctbramcod: ", l_retorno.ctbramcod
display "ctbmdlcod: ", l_retorno.ctbmdlcod

return l_retorno.ctbramcod,   
       l_retorno.ctbmdlcod
end function


# Funcao que busca o sistema da proposta       
#==========================================    
function cts00g09_sisProposta(param)           
#==========================================    
                                               
define param record                            
       prporg like pgakorigem.prporg           
end record                                     
                                               
define cts00g09_sisemscod like pgakorigem.sisemscod
                                               
                                               
 open ccts00g09_004 using param.prporg         
 fetch ccts00g09_004 into cts00g09_sisemscod   
 close ccts00g09_004                           
                                               
return cts00g09_sisemscod                      
                                               
end function                                   
                                               
                                               
                                               
# Funcao que busca o ramo e modalidade quando nao tem apolice e nem proposta  
#==========================================  
function cts00g09_semDocumento(param)         
#==========================================  
define param     record 
     atdsrvnum    like datmservico.atdsrvnum,   
     atdsrvano    like datmservico.atdsrvano
end record


define lr_retorno record
      ctbramcod   like rsatdifctbramcvs.ctbramcod, # codigo ramo contabil          
      ctbmdlcod   like rsatdifctbramcvs.ctbmdlcod, # codigo modalidade contabil
      ciaempcod   like datmservico.ciaempcod,
      soctip      like dbsmopg.soctip
end record


  whenever error continue                                                        
	  open ccts00g09_003 using param.atdsrvnum,                              
	                           param.atdsrvano                               
	  fetch ccts00g09_003 into lr_retorno.ciaempcod
	                           
	  close ccts00g09_003                                                    
  whenever error stop  
  
  whenever error continue                                                        
	  open ccts00g09_005 using param.atdsrvnum,                              
	                           param.atdsrvano                               
	  fetch ccts00g09_005 into lr_retorno.soctip
	                           
	  close ccts00g09_005                                                    
  whenever error stop      

return lr_retorno.ciaempcod ,
       lr_retorno.soctip     

end function  


#---------------------------------------------------------------
function cts00g09_apolcircular(l_atdsrvnum, l_atdsrvano)
#---------------------------------------------------------------
   define l_atdsrvnum        like datmservico.atdsrvnum  ,
          l_atdsrvano        like datmservico.atdsrvano  
          
   
   define lr_retorno record
      succod           like datrservapol.succod    ,
      ramcod           like datrservapol.ramcod    ,
      modalidade       like rsamseguro.rmemdlcod   ,
      aplnumdig        like datrservapol.aplnumdig ,
      itmnumdig        like datrservapol.itmnumdig ,
      edsnumref        like datrservapol.edsnumref ,
      prporg           like datrligprp.prporg      ,  
      prpnumdig        like datrligprp.prpnumdig   ,
      dataaviso        like datmligacao.ligdat     ,
      dataocorre       like datmligacao.ligdat     ,
      erro             smallint                    ,
      msg              char(60)
   end record
   
initialize lr_retorno.* to null
   
   let m_display = false
   
   if l_atdsrvnum is null or l_atdsrvnum = ' ' or
      l_atdsrvano is null or l_atdsrvano = ' ' then
      
      let lr_retorno.erro = 1
      let lr_retorno.msg  = 'Numero do servico eh nulo ou esta em branco'
   else
      
      call cts00g09_apolice(l_atdsrvnum, l_atdsrvano, 3,1,0)  
         returning  lr_retorno.succod    ,   
                    lr_retorno.ramcod    ,   
                    lr_retorno.modalidade,   
                    lr_retorno.aplnumdig ,   
                    lr_retorno.itmnumdig ,   
                    lr_retorno.edsnumref ,   
                    lr_retorno.prporg    ,   
                    lr_retorno.prpnumdig    
   end if 
   
   # prepara os cursores                
   if m_cts00g09_prepare is null or     
      m_cts00g09_prepare <> true then   
      call cts00g09_prepare()           
   end if    
   
   open ccts00g09_006 using l_atdsrvnum, l_atdsrvano   
   
   fetch ccts00g09_006 into lr_retorno.dataaviso,lr_retorno.dataocorre 
   
   close ccts00g09_006                      

   return lr_retorno.succod    ,   
          lr_retorno.ramcod    ,   
          lr_retorno.modalidade,   
          lr_retorno.aplnumdig ,   
          lr_retorno.itmnumdig ,   
          lr_retorno.edsnumref ,   
          lr_retorno.dataaviso ,   
          lr_retorno.dataocorre,
          lr_retorno.prporg    ,   
          lr_retorno.prpnumdig  
end function




#---------------------------------------------------------------
function cts00g09_apolice(l_atdsrvnum, l_atdsrvano, l_acao,l_empcod,l_soctip)
#---------------------------------------------------------------

   define l_atdsrvnum        like datmservico.atdsrvnum  ,
          l_atdsrvano        like datmservico.atdsrvano  ,
          l_acao             smallint                     ,
          l_empcod           like dbsmopg.empcod         , # empresa da OP
          l_soctip           like dbsmopg.soctip         ,
          l_retorno          smallint                    ,
          l_mensagem         char(70)                    ,
          l_succod           like datrservapol.succod    ,
          l_ramcod           like datrservapol.ramcod    ,
          l_modalidade       like rsamseguro.rmemdlcod   ,
          l_aplnumdig        like datrservapol.aplnumdig ,
          l_itmnumdig        like datrservapol.itmnumdig ,
          l_crtnum           like datrsrvsau.crtnum      ,
          l_corsus           like abamcor.corsus         ,
          l_atdsrvorg        like datmservico.atdsrvorg  ,
          l_tpdocto          char(15)                    ,
          l_cornom           like datksegsau.cornom      ,
          l_status           integer                     ,
          l_ramcod2          like datrservapol.ramcod    ,
          l_edsnumref        like datrservapol.edsnumref ,
          l_prporg           like datrligprp.prporg      ,  
          l_prpnumdig        like datrligprp.prpnumdig   ,
          l_itaciacod        like datrligitaaplitm.itaciacod,
          l_clscod           like rsatdifctbramcvs.clscod
          
          
   define lr_cty05g00     record
          resultado       smallint
         ,mensagem        char(42)
         ,emsdat          like abamdoc.emsdat
         ,aplstt          like abamapol.aplstt
         ,vigfnl          like abamapol.vigfnl
         ,etpnumdig       like abamapol.etpnumdig
   end record
   
    define lr_retorno    record
           resultado     smallint,
           ramgrpcod     like gtakram.ramgrpcod,
           erro          integer, 
           mensagem      char(50)
    end record
   
   # Inicio - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
   define lr_retorno_portofaz record
          resultado           smallint
         ,ramcod              like datrmdlramast.ramcod
         ,rmemdlcod           like datrmdlramast.rmemdlcod
         ,mensagem_erro       char(150)
   end record
   # Fim - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
   
   let   l_modalidade  =  null

   initialize lr_cty05g00.* to null
   initialize lr_retorno.* to null
   initialize lr_retorno_portofaz.* to null # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
    
   let l_retorno    = null
   let l_mensagem   = null
   let l_succod     = null
   let l_ramcod     = null
   let l_modalidade = 0
   let l_aplnumdig  = null
   let l_itmnumdig  = null
   let l_crtnum     = null
   let l_corsus     = null
   let l_atdsrvorg  = null
   let l_tpdocto    = null
   let l_cornom     = null
   let l_status     = null
   let l_ramcod2    = null
   let l_edsnumref  = 0
   let l_prporg     = 0
   let l_prpnumdig  = 0
    
   # prepara os cursores  
   if m_cts00g09_prepare is null or
      m_cts00g09_prepare <> true then
      call cts00g09_prepare()
   end if       
   
   #--------------------------|               
   # BUSCA APOLICE DO SERVICO |               
   #--------------------------|
   
   call ctd07g02_busca_apolice_servico(1, l_atdsrvnum, l_atdsrvano)
        returning l_retorno,   l_mensagem,
                  l_succod,    l_ramcod ,
                  l_aplnumdig, l_itmnumdig,l_edsnumref
   
   
   # Inicio - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
   case l_empcod
      
      when 84
         select b.itaciacod,       
                b.itaramcod,       
                b.itaaplnum,       
                b.itaaplitmnum
           into l_itaciacod,
                l_ramcod,
                l_aplnumdig,
                l_itmnumdig             
           from datrligitaaplitm b
          where b.lignum = (select min(lignum) 
                              from datmligacao
                             where atdsrvnum = l_atdsrvnum
                               and atdsrvano = l_atdsrvano)       
         
         select edsnumref
           into l_edsnumref
           from datrservapol
          where atdsrvnum = l_atdsrvnum
            and atdsrvano = l_atdsrvano
         
          call cty22g00_rec_dados_itau(l_itaciacod,
		                       l_ramcod   ,
		                       l_aplnumdig,
		                       l_edsnumref,
		                       l_itmnumdig)
               returning lr_retorno.erro,           
	                 lr_retorno.mensagem 
	                 
          let l_succod           = g_doc_itau[1].succod
          let l_ramcod           = g_doc_itau[1].itaramcod
          let l_modalidade       = 0
          let l_aplnumdig        = g_doc_itau[1].itaaplnum
          let l_itmnumdig        = g_doc_itau[1].itaaplitmnum
          let l_corsus           = g_doc_itau[1].corsus      
          let lr_cty05g00.emsdat = 0
      
      
      when 43
         let l_ramcod     = 0
         let l_modalidade = 0
         display "***************** Chamei Porto Faz"
         call ctb90g00_consula_srv(l_atdsrvnum, l_atdsrvano)
              returning lr_retorno_portofaz.resultado
                       ,lr_retorno_portofaz.ramcod
                       ,lr_retorno_portofaz.rmemdlcod
                       ,lr_retorno_portofaz.mensagem_erro
         
         if lr_retorno_portofaz.resultado = 0 then
            let l_ramcod      = lr_retorno_portofaz.ramcod
            let l_modalidade  = lr_retorno_portofaz.rmemdlcod
         end if
      
      otherwise
         
         if l_ramcod = 31 then
            let l_ramcod = 531
         end if
         
         if l_ramcod = 53 then
            let l_ramcod = 553
         end if
         if m_display then  
            display 'Ramo do servico   : ', l_ramcod 
         end if
         
         if l_ramcod is not null and
            l_ramcod <> " " then
            
            #------------------------------------|                                        
            # TRAZ O GRUPO DO RAMO DA APOLICE    |                                        
            #------------------------------------|                                        
            call cts00g09_grupo_ramo(l_atdsrvnum,l_atdsrvano,l_ramcod)   
                 returning lr_retorno.resultado,lr_retorno.ramgrpcod 
                 
            case lr_retorno.ramgrpcod 
            
               when 1 # AUTO
                  call cty05g00_abamcor(1,l_succod, l_aplnumdig)
                       returning l_retorno, l_mensagem, l_corsus
         
                  # MODALIDADE INCLUIDA PELA FUNCAO DA EMISSAO PSI 249050,
                  # buscar modalidade da apolice Isar
                  call faemc070(l_succod,
                                l_aplnumdig,
                                "","")
                      returning l_ramcod2,
                                l_modalidade,
                                l_status
         
                  call cty05g00_dados_apolice(l_succod, l_aplnumdig)
                       returning lr_cty05g00.*  
                       
                  call f_funapol_ultima_situacao_nova(l_succod,  
                                                      l_aplnumdig,
                                                      l_itmnumdig) 
                       returning g_funapol.*                            
                  
                  
                  
               when 4 # RE
                  call cty06g00_modal_re(1, l_succod, l_ramcod, l_aplnumdig)
                       returning l_retorno, l_mensagem, l_modalidade 
                  
                  call cts00g09_proposta(l_atdsrvnum, l_atdsrvano)   
                       returning l_prporg,                           
                                 l_prpnumdig,                        
                                 l_corsus                            
            end case   
         
         else
         
            if l_acao <> 2 then
               call cts00g09_proposta(l_atdsrvnum, l_atdsrvano)     
                    returning l_prporg,                             
                              l_prpnumdig,
                              l_corsus                          
            else
               let l_prpnumdig  = 0  
            end if 
            
            if l_prpnumdig = 0 then
               if m_display then 
                  display "Buscou SAUDE"
               end if 
               call cts20g10_cartao(2,
                                    l_atdsrvnum,
                                    l_atdsrvano)
                          returning l_retorno,
                                    l_mensagem,
                                    l_succod,
                                    l_ramcod ,
                                    l_aplnumdig,
                                    l_crtnum
                                    
                if l_retorno = 1 then                          
                  if l_ramcod is null or 
                     l_ramcod = " " or
                     l_ramcod = 0 then
                     let l_ramcod = 87    
                     let l_modalidade = 0 
                  end if 
                  # Obter corsus da tabela do saúde           
                  call cta01m15_sel_datksegsau(2, l_crtnum, "", "", "" )
                       returning l_retorno,                   
                                 l_mensagem,                  
                                 l_corsus,                    
                                 l_cornom                                 
               end if
            end if    
         end if
   end case
      
   # Fim - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
   
   if l_ramcod is null or
      l_ramcod = " " or
      l_ramcod = 0 then
      
      let l_succod    = 1                                        
      let l_aplnumdig = 0                                        
                                                                 
      case l_empcod                                              
                                                                 
         when 14   # definido pela contabilidade                 
            let l_ramcod = 991                                   
            let l_modalidade = 0                                 
                                                                 
         when 27   # definido pela controladoria                 
            let l_ramcod = 10                                    
            let l_modalidade = 1                                 
                                                                 
         when 43   # definido pela Porto FAZ 26/11/2014     
            let l_ramcod = 5009                                    
            let l_modalidade = 1                                 
                                                                 
         when 50   # definido pela contabilidade 21/07/2009      
            let l_ramcod = 87                                    
            let l_modalidade = 0                                 
         
         when 84
            let l_ramcod = 31   
            let l_modalidade = 0 
                                                                   
         otherwise                                               
            if l_soctip = 3                                      
               then                                              
               let l_ramcod = 114                                
               let l_modalidade = 1                              
            else                                                 
               let l_ramcod = 531                                
               let l_modalidade = 0                              
            end if                                               
      end case                                                   

   end if 
   if m_display then  
      display "l_acao: ",l_acao
   end if    
   case l_acao
      when 1 # Tipo de retorno para a circular 395
         return l_succod,    
                l_ramcod,    
                l_aplnumdig,
                l_prporg,   
                l_prpnumdig,
                l_modalidade
      
      when 2 # Tipo de Retorno para o bdbsa017
         return l_succod, 
                l_ramcod, 
                l_modalidade, 
                l_aplnumdig, 
                l_itmnumdig,
                l_corsus, 
                lr_cty05g00.emsdat,
                l_edsnumref, 
                l_prporg,    
                l_prpnumdig 
      
      when 3 # Tipo de retorno para a circular 360
         return l_succod,    
                l_ramcod,    
                l_modalidade,
                l_aplnumdig, 
                l_itmnumdig, 
                l_edsnumref, 
                l_prporg,    
                l_prpnumdig 
                
      when 4 # Tipo de retorno para a CAMADA PEOPLE
         return l_succod,    
                l_ramcod,    
                l_modalidade,
                l_aplnumdig, 
                l_itmnumdig, 
                l_edsnumref, 
                l_prporg,    
                l_prpnumdig,
                l_corsus   
   end case
         
end function


# Funcao que busca o numero da proposta do servico
#========================================== 
function cts00g09_proposta(param)
#========================================== 
 define param     record 
     atdsrvnum    like datmservico.atdsrvnum,   
     atdsrvano    like datmservico.atdsrvano
 end record


define l_documento    record                                                
      prporg      like datrligprp.prporg,    #Origem de Proposta de Seguro         
      prpnumdig   like datrligprp.prpnumdig, #Numero/digito de proposta de seguro   
      corsus      like abamcor.corsus 
end record                                                                         

initialize l_documento.* to null

whenever error continue 
open ccts00g09_002 using param.atdsrvnum,            
                         param.atdsrvano             
                                                     
fetch ccts00g09_002 into l_documento.prporg,    
                         l_documento.prpnumdig 
                         
   if sqlca.sqlcode <> 0 then
      #display "Foi encontrado o erro(",sqlca.sqlcode using '<<<<<<<<<&',") ao buscar proposta do servico: ",param.atdsrvnum,"-",param.atdsrvano
      let l_documento.prpnumdig = 0
      let l_documento.prporg = 0
   end if 
      
close ccts00g09_002
whenever error stop                            
   
whenever error continue 
open ccts00g09_007 using l_documento.prporg,    
                         l_documento.prpnumdig             
                                                     
fetch ccts00g09_007 into l_documento.corsus 
                         
   if sqlca.sqlcode <> 0 then
      #display "Foi encontrado o erro(",sqlca.sqlcode using '<<<<<<<<<&',") ao buscar SUSEP do servico: ",param.atdsrvnum,"-",param.atdsrvano
      let l_documento.prpnumdig = 0
      let l_documento.prporg = 0
      let l_documento.corsus = 0
   end if 
      
close ccts00g09_007
whenever error stop  
 
   return l_documento.prporg,
          l_documento.prpnumdig,
          l_documento.corsus 
            

end function
                                             