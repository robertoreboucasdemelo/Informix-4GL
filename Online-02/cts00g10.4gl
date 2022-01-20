#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........:                                                           #
# ANALISTA RESP..: JORGE MODENA                                              #
# PSI/OSF........:                                                           #
# OBJETIVO.......: ENVIAR COMUNICADO DE ACIONAMENTO SERVICO PARA CORRETOR    #
#............................................................................#
# DESENVOLVIMENTO: JORGE MODENA                                              #
# LIBERACAO......: 06/08/2013                                                #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
# 26/05/2014  Rodolfo Massini ------------  Alteracao na forma de envio de   #
#                                           e-mail (SENDMAIL para FIGRC009)  # 
##############################################################################


globals '/homedsa/projetos/geral/globals/glct.4gl'
globals "/homedsa/projetos/geral/globals/figrc072.4gl"  --> 223689
globals '/homedsa/projetos/geral/globals/gpvia021.4gl'  --> VEP - Vida

define m_prep         smallint
define m_msg          char(200)

#---------------------------------#
function cts00g10_prepare()
#---------------------------------#
 define l_sql   char(500)

 let l_sql = ' select c24pbmdes '
              ,' from datrsrvpbm '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '
               ,' and c24pbminforg = 1 '
               ,' and c24pbmseq = 1 '
 prepare p_cts00g10_001 from l_sql
 declare c_cts00g10_001 cursor for p_cts00g10_001

 let l_sql = 'select lgdtip, lgdnom, lgdnum, cidnom, ufdcod '
            ,'      ,lclcttnom, celteldddcod, celtelnum, lclidttxt '
            ,'      ,dddcod, lcltelnum' 
            ,'  from datmlcl '
            ,' where atdsrvnum = ? '
            ,'   and atdsrvano = ? '
            ,'   and c24endtip = ? '

 prepare p_cts00g10_002 from l_sql
 declare c_cts00g10_002 cursor for p_cts00g10_002

 let l_sql = ' select a.asitipabvdes '
            ,'   from datkasitip a, datmservico b '
            ,'  where b.atdsrvnum = ? '
            ,'    and b.atdsrvano = ? '
            ,'    and b.asitipcod = a.asitipcod '

 prepare p_cts00g10_003 from l_sql
 declare c_cts00g10_003 cursor for p_cts00g10_003
 
 let l_sql = ' select cpodes '
            ,'   from iddkdominio '
            ,'  where cponom = ? '
            ,'  order by cpocod '
 prepare pcts00g10005 from l_sql
 declare ccts00g10005 cursor for pcts00g10005
 
 
 let l_sql =   'select min (lignum)'
              ,'from datmligacao   '
              ,'where atdsrvnum = ?'
              ,'and atdsrvano = ?  '
 
 prepare pcts00g10006 from l_sql                 
 declare ccts00g10006 cursor for pcts00g10006    
 
 # Busca o valor de parametro               
  let l_sql =  ' select grlinf      '     
              ,'   from datkgeral   '     
              ,'  where grlchv = ?  '   
                 
 prepare pcts00g10007 from l_sql                 
 declare ccts00g10007 cursor for pcts00g10007
 
 #verifica informações apolice que abriu serviço 
 let l_sql =   'select succod,     '
              ,'       ramcod,     '
              ,'       aplnumdig,  '
              ,'      itmnumdig    '
              ,' from datrligapol  '
              ,'where lignum = ?   '
 prepare pcts00g10008 from l_sql                 
 declare ccts00g10008 cursor for pcts00g10008  
 
 #seleciona informações prestador que atendera serviço
 let l_sql =   'select nomrazsoc,      '
              ,'        endcid,        '
              ,'        endufd,        '
              ,'        dddcod,        '
              ,'        teltxt         '
              ,'  from dpaksocor       '
              ,'   where pstcoddig = ? '
  
 prepare pcts00g10009 from l_sql                 
 declare ccts00g10009 cursor for pcts00g10009    
 
 
 #busca distancia da base com base ao endereço de ocorrencia do cliente
 let l_sql =  'select dstqtd from datmsrvacp'
             ,'   where atdsrvnum = ?       '
             ,'   and atdsrvano =   ?       '
             ,'   and atdsrvseq =   ?       '
             
             
 prepare pcts00g10011 from l_sql              
 declare ccts00g10011 cursor for pcts00g10011 

 let l_sql = "select mpacidcod ",
                  " from datkmpacid ",
                 " where cidnom = ? ",
                   " and ufdcod = ? "

 prepare pcts00g10012 from l_sql
 declare ccts00g10012 cursor for pcts00g10012
 
 let l_sql = "select 1 ",
                  " from dbsmsmsalrcid ",
                 " where mpacidcod    = ? ",
                   " and envstt = ? "

 prepare pcts00g10013 from l_sql
 declare ccts00g10013 cursor for pcts00g10013
 
  let l_sql = "select 1 ",
                  " from datkgeral ",
                 " where grlchv in (?,?) "

 prepare pcts00g10014 from l_sql
 declare ccts00g10014 cursor for pcts00g10014
 
 #consultar grupo ramo
 let l_sql = "select ramgrpcod ",
             " from gtakram",
             " where empcod = ? ",                               
             " and ramcod = ?   " 
 prepare pcts00g10015 from l_sql                            
 declare ccts00g10015 cursor for pcts00g10015
 
 #consultar apolice saude
 let l_sql = "select succod,",   
             "ramcod,",   
             "aplnumdig,",
             "crtnum",    
             " from datrligsau ",
             "where lignum = ?"
             
 prepare pcts00g10016 from l_sql                            
 declare ccts00g10016 cursor for pcts00g10016
  
                           
 let m_prep = true
              
end function  

#--------------------------------------------------------------
 function cts00g10(param)
#--------------------------------------------------------------

 define param    record
   atdsrvnum     like datmservico.atdsrvnum, 
   atdsrvano     like datmservico.atdsrvano   
 end record
 
 define d_cts00g10 record
    c24astcod    like datmligacao.c24astcod ,  
    c24soltipcod like datmligacao.c24soltipcod ,
    ligdat       like datmligacao.ligdat    , 
    msgtxt       char (620)                 ,
    corsus       like gcaksusep.corsus      , 
    c24astpgrtxt char(200),
    ramcod       like datrservapol.ramcod   ,
    succod       like datrservapol.succod   ,
    aplnumdig    like datrservapol.aplnumdig,
    itmnumdig    like datrservapol.itmnumdig,
    lignum       like datmligacao.lignum, 
    nom          like datmservico.nom, 
    celteldddcod like datmlcl.celteldddcod ,
    celtelnum    like datmlcl.celtelnum,
    lcldddcod    like datmlcl.dddcod,
    lcltelnum    like datmlcl.lcltelnum,
    vcllicnum    like datmservico.vcllicnum,
    atdprscod    like datmservico.atdprscod,
    c24solnom    like datmligacao.c24solnom,
    c24funmat    like datmligacao.c24funmat,
    mstastdes    like htlmmst.mstastdes, 
    ciaempcod    like datmservico.ciaempcod, 
    atdsrvseq    like datmservico.atdsrvseq,
    empcod       like datmservico.empcod,
    usrtip       like datmservico.usrtip,
    funmat       like datmservico.funmat, 
    crtnum       like datrligsau.crtnum, 
    atdsrvorg    like datmservico.atdsrvorg
 end record      
    
 define ws      record  
    c24astdes    char (72)                ,    
    c24pbmdes    like datrsrvpbm.c24pbmdes,
    lgdtip	 like datmlcl.lgdtip,
    lgdnom	 like datmlcl.lgdnom,
    lgdnum	 like datmlcl.lgdnum,
    cidnom	 like datmlcl.cidnom,
    ufdcod       like datmlcl.ufdcod,
    lclcttnom	 like datmlcl.lclcttnom,   
    lclidttxt	 like datmlcl.lclidttxt,     
    nomrazsoc    like dpaksocor.nomrazsoc,
    endcid       like dpaksocor.endcid,
    endufd       like dpaksocor.endufd,
    dddcod       like dpaksocor.dddcod,
    teltxt       like dpaksocor.teltxt,
    dstqtd       like datmsrvacp.dstqtd,
    asitipabvdes like datkasitip.asitipabvdes
 end record
 
 define lr_pcc014     record             
        erro          smallint,           
        ddd           smallint,          
        telnum        char(10),          
        email         char(50),          
        mensagem      char(80),          
        cadtip        char(01),          
        tp_envio      smallint           
 end record
 
 define lr_cidade record
         retorno    smallint,
         mensagem   char(100)
 end record 
 
 define retorno record
    msgtxt      char (620)
   ,msgtxtsms   char(143)
 end record
 
 define lr_msgsms      record
      result             smallint
     ,status             integer
     ,msgnum             like pccmcorsms.corsmsnum
  end record
  
  define lr_cts29g00 record
         atdsrvnum    like datratdmltsrv.atdsrvnum,
         atdsrvano    like datratdmltsrv.atdsrvano,
         resultado    smallint,
         mensagem     char(100)
     end record
 
 define l_retorno      smallint
       ,l_msgtxtsms    char(143)     
       ,l_msg          char(20)      
       ,l_crtsaunum    char(25)
       ,l_chave        char(15)
       ,l_origens      char(40)
       ,l_sql          char(1000)
       ,l_apl          char(100)
       ,l_dptsgl       char(06)                     
       ,l_c24endtip    like datmlcl.c24endtip    
       ,l_dptmaicod    like pcckdptcomcor.dptmaicod                     
       ,l_sissgl       like pccmcorsms.sissgl             
       ,l_corcmndptcod like pccmcorsms.corcmndptcod
       ,l_hostname     char(20)
       ,l_tam          smallint
       ,l_parametro    char(15)
       ,l_data         char(10)
       ,l_datacorte    datetime year to day
       ,l_dia          char(02)
       ,l_mes          char(02)
       ,l_ano          char(04)  
 

 initialize  d_cts00g10.*  to  null
 initialize  ws.* to null
 initialize  lr_pcc014.* to null
 initialize  lr_cidade.* to null
 initialize retorno.* to null
 initialize lr_msgsms.* to null
 initialize lr_cts29g00.* to null
 
 let l_msgtxtsms = null      
 let l_crtsaunum = null      
 let l_retorno   = 0         
 let l_dia       = null      
 let l_mes       = null      
 let l_ano       = null
 let l_parametro = "PSODTAINITELPST"
 let l_datacorte = null  

 if m_prep is null or
    m_prep <> true then
    call cts00g10_prepare()
 end if 
  
 let l_chave = "PSOCRRACNMSGORG"
   
 whenever error continue 
 #verifica origens que devem enviar e-mail para corretor
 open ccts00g10007 using l_chave
 fetch ccts00g10007 into l_origens 
 whenever error stop   
    
 #se nao foi localizado origem nao envia msg corretor   
 if sqlca.sqlcode <> 0 then    
    close ccts00g10007 
    let m_msg = "Erro Módulo cts00g10: Nao existe origem cadastrado para envio de mensagem. Codigo: ",  sqlca.sqlcode, " Servico: ", param.atdsrvnum
    call errorlog(m_msg)
    return  false
 end if
 
 close ccts00g10007

 #verifica informações de servico se este tem origem cadastrada no parametro
 let l_sql =  ' select nom,                            '
             ,'       c24solnom,                       '
             ,'       vcllicnum,                       '
             ,'       corsus,                          '
             ,'       atdprscod,                       '
             ,'       ciaempcod,                       '
             ,'       atdsrvseq,                       '
             ,'       empcod,                          '
             ,'       usrtip,                          '
             ,'       funmat,                          '
             ,'       atdsrvorg                        '
             ,' from datmservico                       '
             ,'  where atdsrvnum = ?                   '
             ,'   and atdsrvano = ?                    '
             ,'   and atdsrvorg in (',l_origens,')     '
             
  
 prepare pcts00g10010 from l_sql                 
 declare ccts00g10010 cursor for pcts00g10010   
    
 whenever error continue
 open ccts00g10010 using param.atdsrvnum,
                         param.atdsrvano
 
 fetch ccts00g10010 into d_cts00g10.nom,
                         d_cts00g10.c24solnom,
                         d_cts00g10.vcllicnum,
                         d_cts00g10.corsus,
                         d_cts00g10.atdprscod,
                         d_cts00g10.ciaempcod, 
                         d_cts00g10.atdsrvseq,
                         d_cts00g10.empcod,
                         d_cts00g10.usrtip,
                         d_cts00g10.funmat,
                         d_cts00g10.atdsrvorg
                         
 whenever error stop                       
                         
 if sqlca.sqlcode <> 0 then    
    let m_msg = "Erro Módulo cts00g10: Origem de serviço nao envia mensagem de acionamento para corretor. Codigo: ",  sqlca.sqlcode, " Servico: ", param.atdsrvnum        
    call errorlog(m_msg)
    return  false  
 end if 
 
 close ccts00g10010
 
 #verifica se tem corretor associado ao serviço 
 if d_cts00g10.corsus is null or d_cts00g10.corsus = 0 then
    let m_msg = "Erro Módulo cts00g10: Nao existe corretor associado a este servico. Codigo: ",  sqlca.sqlcode, " Servico: ", param.atdsrvnum       
    call errorlog(m_msg)
    return  false  
 end if
 
 #verifica se susep e da Clara Rosemblatt   
 if d_cts00g10.corsus = "P5005J"  or      ###  Se for susep utilizada pela    
    d_cts00g10.corsus = "I5005J"  or      ###  Clara Rosemblatt               
    d_cts00g10.corsus = "M5005J"  or      ###  para seguro a funcionarios,    
    d_cts00g10.corsus = "G5005J"  then
    let m_msg = "Módulo cts00g10: Sucursal da Clara Rosemblatt nao envia msg corretor"     
    call errorlog(m_msg)
    return false    
 end if
 
 #se origem do servico 9 ou 13 (RE) só envia msg para servico original
 if d_cts00g10.atdsrvorg = 9 or d_cts00g10.atdsrvorg = 13 then
    call cts29g00_consistir_multiplo(param.atdsrvnum, param.atdsrvano)
                returning lr_cts29g00.resultado,
                          lr_cts29g00.mensagem,
                          lr_cts29g00.atdsrvnum,
                          lr_cts29g00.atdsrvano
                          
    
    if  lr_cts29g00.resultado = 1 then 
        let m_msg = "Servico Multiplo não e o original.", " Servico: ", param.atdsrvnum      
        call errorlog(m_msg)        
        return false  
    end if
 end if
  
 #busca endereco de origem da ocorrencia         
 let l_c24endtip = 1  
 whenever error continue                           
 open c_cts00g10_002 using param.atdsrvnum       
                          ,param.atdsrvano       
                          ,l_c24endtip           
                                                 
                                                 
 fetch c_cts00g10_002 into ws.lgdtip             
                       ,ws.lgdnom                
                       ,ws.lgdnum                
                       ,ws.cidnom
                       ,ws.ufdcod                
                       ,ws.lclcttnom             
                       ,d_cts00g10.celteldddcod          
                       ,d_cts00g10.celtelnum            
                       ,ws.lclidttxt 
                       ,d_cts00g10.lcldddcod
                       ,d_cts00g10.lcltelnum            
 whenever error stop
                                                
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro Módulo cts00g10: Nao foi possivel localizar endereco de ocorrencia do servico. Codigo: ",  sqlca.sqlcode, " Servico: ", param.atdsrvnum                                                                                                                                                                                                                                                                                                                                                                                   
    call errorlog(m_msg)
    close c_cts00g10_002                        
    return false
 end if
 
 close c_cts00g10_002                                           

 #verifica se cidade está cadastrada para receber e-mail e SMS
 
 call cts00g10_verifica_cidade(ws.cidnom,
                               ws.ufdcod,
                               8)
                returning lr_cidade.retorno,
                          lr_cidade.mensagem

 if  lr_cidade.retorno <> 0 then
    let m_msg = "Erro Módulo cts00g10: Cidade do servico nao esta cadastrada para envio de mensagem. Codigo: ",  sqlca.sqlcode, " Servico: ", param.atdsrvnum         
    call errorlog(m_msg)
    return false
 end if
 
 #verifica ligacao original do serviço
 whenever error continue
 open ccts00g10006 using param.atdsrvnum ,
                         param.atdsrvano
 
 fetch  ccts00g10006 into d_cts00g10.lignum
 whenever error stop
 
 if sqlca.sqlcode <> 0 then 
    close ccts00g10006   
    let m_msg = "Erro Módulo cts00g10: Problemas ao consultar ligacao original do servico. Codigo: ",  sqlca.sqlcode, " Servico: ", param.atdsrvnum      
    call errorlog(m_msg)
    return  false  
 end if 
 
 close ccts00g10006
                         
 #busca informações ligacao
 whenever error continue
 select c24astcod, c24soltipcod,
        ligdat   , c24solnom, c24funmat
   into d_cts00g10.c24astcod,
        d_cts00g10.c24soltipcod,
        d_cts00g10.ligdat   ,         
        d_cts00g10.c24solnom        ,
        d_cts00g10.c24funmat
   from datmligacao
  where lignum = d_cts00g10.lignum
 whenever error stop
 
 let d_cts00g10.mstastdes = "CENTRAL 24H INFORMA  -  SERVICO ACIONADO"
 
 #busca descricao do assunto
 call c24geral8(d_cts00g10.c24astcod) returning ws.c24astdes
 
 open c_cts00g10_001 using param.atdsrvnum
                          ,param.atdsrvano
 
 fetch c_cts00g10_001 into ws.c24pbmdes

 if sqlca.sqlcode <> 0 then    
    let ws.c24pbmdes = null    
 end if
 close c_cts00g10_001
 
 #busca informações de apolice que abriu serviços
 whenever error continue
 open ccts00g10008 using d_cts00g10.lignum
 
 fetch ccts00g10008 into  d_cts00g10.succod
                         ,d_cts00g10.ramcod
                         ,d_cts00g10.aplnumdig
                         ,d_cts00g10.itmnumdig
 whenever error stop
 
 if sqlca.sqlcode <> 0 then       
    #se nao identificou apolice na base datrligapol
    #verifica na tabela datrligsau   
    whenever error continue
    open ccts00g10016 using d_cts00g10.lignum                    
    
    fetch ccts00g10016  into d_cts00g10.succod    
                            ,d_cts00g10.ramcod    
                            ,d_cts00g10.aplnumdig 
                            ,d_cts00g10.crtnum 
    whenever error stop     
    close ccts00g10016
 end if  
 close ccts00g10008 
 
 #busca tipo de assistencia
 whenever error continue
 open c_cts00g10_003 using param.atdsrvnum
                          ,param.atdsrvano


 fetch c_cts00g10_003 into ws.asitipabvdes
 whenever error stop
 
 if sqlca.sqlcode <> 0 then   
    let ws.asitipabvdes = null   
 end if
 
 close c_cts00g10_003

 #busca informações prestador
 whenever error continue
 open ccts00g10009 using d_cts00g10.atdprscod
 
 fetch ccts00g10009 into  ws.nomrazsoc 
                         ,ws.endcid    
                         ,ws.endufd    
                         ,ws.dddcod 
                         ,ws.teltxt 
 whenever error stop                        
                         
 if sqlca.sqlcode <> 0 then 
    close ccts00g10009  
    let m_msg = "Erro Módulo cts00g10: Problemas ao consultar informações prestador. Codigo: ",  sqlca.sqlcode, " Servico: ", param.atdsrvnum         
    call errorlog(m_msg)
    return  l_retorno      
 end if                  
 close ccts00g10009
 
 #busca distancia da base com endereco de ocorrencia do serviço 
 whenever error continue
 open ccts00g10011 using param.atdsrvnum
                        ,param.atdsrvano 
                        ,d_cts00g10.atdsrvseq
                        
 fetch ccts00g10011 into  ws.dstqtd
 whenever error stop
 close ccts00g10011 
 
 
 #verifica se telefone prestador pode ser exibido
 whenever error continue 
 open ccts00g10007 using l_parametro
 fetch ccts00g10007 into l_data
 if sqlca.sqlcode = 0 then     
    let l_dia       = l_data[1,2]
    let l_mes       = l_data[4,5]
    let l_ano       = l_data[7,10]          
    let l_datacorte = mdy(l_mes,l_dia,l_ano)     
 end if
 close ccts00g10007 
 whenever error stop 
 
 
 #se possui data e for menor ou igual a corrente nao exibe tel prestador 
 if l_datacorte is not null and l_datacorte <= today then    
    let ws.dddcod = null
    let ws.teltxt = null
 end if            

 # Monta o Cabecalho da Mensagem
 call cts00g10_monta_cabecalho(d_cts00g10.c24funmat       ,
                               d_cts00g10.c24astcod       ,
                               d_cts00g10.ramcod          ,
                               d_cts00g10.succod          ,
                               d_cts00g10.aplnumdig       ,
                               d_cts00g10.itmnumdig       ,
                               d_cts00g10.crtnum          ,
                               d_cts00g10.ciaempcod       )
 returning l_apl
 #Monta o Corpo da Mensagem
 call cts00g10_monta_mensagem_html(l_apl           ,
                              param.atdsrvnum ,
                              param.atdsrvano ,
                              d_cts00g10.ciaempcod,
                              d_cts00g10.nom  ,
                              d_cts00g10.c24solnom,
                              d_cts00g10.vcllicnum,
                              d_cts00g10.celteldddcod ,
                              d_cts00g10.celtelnum    ,
                              d_cts00g10.lcldddcod,
                              d_cts00g10.lcltelnum,
                              ws.c24astdes    ,
                              ws.c24pbmdes    ,
                              ws.lgdtip       ,
                              ws.lgdnom       ,
                              ws.lgdnum       ,
                              ws.cidnom       ,
                              ws.lclcttnom    , 
                              ws.asitipabvdes ,
                              ws.lclidttxt,
                              d_cts00g10.atdprscod, 
                              ws.nomrazsoc ,
                              ws.dddcod, 
                              ws.teltxt,
                              ws.endcid,    
                              ws.endufd,
                              ws.dstqtd)
 returning retorno.msgtxt
  
 #Monta as Mensagens para SMS
 call cts00g10_monta_mensagem_sms(d_cts00g10.ciaempcod,
                                  d_cts00g10.nom     ,
                                  d_cts00g10.celteldddcod ,
                                  d_cts00g10.celtelnum    ,
                                  ws.nomrazsoc ,
                                  ws.dddcod, 
                                  ws.teltxt,
                                  ws.endcid,    
                                  ws.endufd,
                                  ws.dstqtd) 
 returning retorno.msgtxtsms
 
 
 #verifica informações corretor  
 call fpccc014_obterOpcaoMsgSusep( d_cts00g10.corsus
                                 , 1 ) #codigo departamento definido para central
 returning lr_pcc014.*
        
 let l_dptsgl = "ct24hs"
 let l_dptmaicod = "central.deoperacoes@portoseguro.com.br"
 let l_sissgl = "PSocorro"
 let l_corcmndptcod = 1 #codigo da ct24h
 
  
 #verifica qual o ambiente programa está rodando
 whenever error continue
 select sitename into l_hostname
 from porto:dual
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let l_hostname = null
 end if
 
 let l_hostname =  l_hostname clipped
 
 #envia email para corretor      
 if lr_pcc014.email    is not null  and
     lr_pcc014.email    <> " "       then 
     
    #trata e-mails no ambiente de teste e homologacao
    if l_hostname  = "dbu18wh" or l_hostname = "dbu18wt"    then
       display "email corretor", lr_pcc014.email
       let lr_pcc014.email = lr_pcc014.email  clipped
       let l_tam  = length(lr_pcc014.email)
       if lr_pcc014.email[l_tam-12,l_tam] <> "@correioporto"        and
          lr_pcc014.email[l_tam-18,l_tam] <> "@portoseguro.com.br"  then
          let lr_pcc014.email = "jorge.modena@portoseguro.com.br"
       end if
       display "email ambiente teste", lr_pcc014.email    
    end if 
        
    call fptlc037_email_corsus( d_cts00g10.corsus
                                  , d_cts00g10.mstastdes
                                  , retorno.msgtxt
                                  , l_dptsgl
                                  , l_dptmaicod
                                  , lr_pcc014.email)
             returning lr_msgsms.result            
     #avisa envio de email com sucesso
     if lr_msgsms.result = 0 then        
        call cts00g10_email_monitoramento(param.atdsrvnum
                                         ,param.atdsrvano
                                         ,retorno.msgtxt
                                         ,"")
     
     end if 
     
 end if
 
 if lr_pcc014.ddd  > 0 and lr_pcc014.telnum > 0  then  
    call fpcca001_regCorSms(     d_cts00g10.corsus
                               , lr_pcc014.ddd
                               , lr_pcc014.telnum
                               , l_corcmndptcod
                               , d_cts00g10.mstastdes
                               , l_sissgl
                               , d_cts00g10.empcod
                               , d_cts00g10.usrtip  
                               , d_cts00g10.funmat
                               , retorno.msgtxtsms
                               , ""
                               , ""   )
             returning lr_msgsms.result
                     , lr_msgsms.status
                     , lr_msgsms.msgnum 
                     
    #avisa envio de email com sucesso
    if lr_msgsms.result = 0 then        
       call cts00g10_email_monitoramento(param.atdsrvnum
                                        ,param.atdsrvano
                                        ,""
                                        ,retorno.msgtxtsms)
    
    end if                       
 end if 
 return true
end function



#-------------------------------------------------
function cts00g10_monta_cabecalho(lr_param)
#-------------------------------------------------

 define lr_param record
     c24funmat   like datmligacao.c24funmat   ,
     c24astcod   like datkassunto.c24astcod   ,
     ramcod      like datrservapol.ramcod     ,
     succod      like datrservapol.succod     ,
     aplnumdig   like datrservapol.aplnumdig  ,
     itmnumdig   like datrservapol.itmnumdig  , 
     crtnum      like datrligsau.crtnum       ,
     ciaempcod   like datmservico.ciaempcod  
 end record
 
 define lr_retorno record
     cabecalho char(100)
 end record
 
 define l_ramgrpcod like gtakram.ramgrpcod
 define l_novo_formato char(21)
 
 let l_ramgrpcod = null
 let l_novo_formato = null
 
 initialize lr_retorno.*  to null

 if lr_param.ciaempcod = 84 then

    let lr_retorno.cabecalho = "ITAU SEGUROS CT24H INFORMA: Apolice: "

    let lr_retorno.cabecalho = lr_retorno.cabecalho clipped                  ,                                 
                               lr_param.succod       using "<<<&&"     , "/" ,
                               lr_param.ramcod       using "<<&&"      , "/" ,
                               lr_param.aplnumdig    using "<<<<<<<&&" , "/" ,
                               lr_param.itmnumdig    using "<<<<<&&"
 else
    #consulta codigo grupo ramo
    whenever error continue
    open ccts00g10015 using  lr_param.ciaempcod
                            ,lr_param.ramcod
                            
    fetch ccts00g10015 into l_ramgrpcod
    whenever error stop
    close ccts00g10015

    if l_ramgrpcod = 5 then # Saude
       let l_novo_formato = cts20g16_formata_cartao(lr_param.crtnum)
       let lr_retorno.cabecalho = "PORTO SEGURO CT24H INFORMA: Cartao Saude: ",
                                  l_novo_formato clipped
    else        
       let lr_retorno.cabecalho = "PORTO SEGURO CT24H INFORMA: Apolice: "         
       let lr_retorno.cabecalho = lr_retorno.cabecalho clipped           ,
                                  lr_param.succod using "<<<&&", "/"           , #"&&", "/" , #projeto succod
                                  lr_param.ramcod using "##&&", "/"         ,
                                  lr_param.aplnumdig using "<<<<<<<&&"      
       
                                  
       # Se for diferente de RE incluo o Item da Apolice
       if l_ramgrpcod <>  2 and
          l_ramgrpcod <>  4 and
          l_ramgrpcod <>  6 then # RE
             let lr_retorno.cabecalho = lr_retorno.cabecalho clipped  , "/",
                                         lr_param.itmnumdig using "<<<<<&&"
       end if
    end if

 end if

 return lr_retorno.cabecalho

end function

#-------------------------------------------------
function cts00g10_monta_mensagem(lr_param)
#-------------------------------------------------

 define lr_param record
        cabecalho    char(100),
        atdsrvnum    like datmservico.atdsrvnum   ,
        atdsrvano    like datmservico.atdsrvano   ,
        ciaempcod    like datmservico.ciaempcod   ,
        nom          like datmservico.nom         ,
        c24solnom    like datmligacao.c24solnom   ,
        vcllicnum    like datmservico.vcllicnum   ,
        celteldddcod like datmlcl.celteldddcod ,    
        celtelnum    like datmlcl.celtelnum ,
        lcldddcod    like datmlcl.dddcod,
        lcltelnum    like datmlcl.lcltelnum,       
        c24astdes    char (72)                    ,
        c24pbmdes    like datrsrvpbm.c24pbmdes    ,
        lgdtip	     like datmlcl.lgdtip          ,
        lgdnom	     like datmlcl.lgdnom          ,
        lgdnum	     like datmlcl.lgdnum          ,
        cidnom	     like datmlcl.cidnom          ,
        lclcttnom    like datmlcl.lclcttnom       ,             
        asitipabvdes like datkasitip.asitipabvdes ,
        lclidttxt    like datmlcl.lclidttxt, 
        atdprscod    like datmservico.atdprscod,
        nomrazsoc    like dpaksocor.nomrazsoc,
        dddcod       like dpaksocor.dddcod,
        teltxt       like dpaksocor.teltxt,
        endcid       like dpaksocor.endcid,
        endufd       like dpaksocor.endufd,
        dstqtd       like datmsrvacp.dstqtd             
 end record

 define lr_retorno record
     mensagem char (620)
 end record
 initialize lr_retorno.*  to null
     let lr_retorno.mensagem =                  lr_param.cabecalho clipped, "\n",
                               "Segurado: "   , lr_param.nom       clipped, "\n",
                               "Solicitante: ", lr_param.c24solnom clipped, "\n"
     if lr_param.vcllicnum is not null and
        lr_param.vcllicnum <> " "      then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Placa   : ", lr_param.vcllicnum  clipped, "\n"
     end if
     if lr_param.celtelnum is not null and
        lr_param.celtelnum <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Celular : "   , lr_param.celteldddcod       clipped, " ",
                                                   lr_param.celtelnum          using "<<<<<<<<&&", "\n"
     end if
     
     if lr_param.lcltelnum is not null and
        lr_param.lcltelnum <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Telefone Fixo : "   , lr_param.lcldddcod       clipped, " ",
                                                         lr_param.lcltelnum       using "<<<<<<<<&&", "\n"
     end if
     
     
     if lr_param.c24astdes is not null and
        lr_param.c24astdes <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Ocorrencia: " , lr_param.c24astdes clipped, "\n"
     end if
     if lr_param.c24pbmdes is not null and
        lr_param.c24pbmdes <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Tipo do Problema: ", lr_param.c24pbmdes clipped, "\n"
     end if
     if lr_param.lgdnom is not null and
        lr_param.lgdnom <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Local da Ocorrencia: ", lr_param.lgdtip clipped, " " ,
                                                           lr_param.lgdnom clipped, " " ,
                                                           lr_param.lgdnum clipped, "\n"
     end if
     if lr_param.cidnom is not null and
        lr_param.cidnom <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Cidade: ", lr_param.cidnom clipped, "\n"
     end if
     if lr_param.lclcttnom is not null and
        lr_param.lclcttnom <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Contato: ", lr_param.lclcttnom clipped, "\n"
     end if    
     
     let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Servico: ", lr_param.atdsrvnum using "<<<<<&&"  , "-", lr_param.atdsrvano using "&&", "\n"
     
     let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Dados do Acionamento do Serviço: ", "\n"
     
     if lr_param.nomrazsoc is not null and
        lr_param.nomrazsoc <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Prestador: ", lr_param.atdprscod  using "<<<<&&", " ",lr_param.nomrazsoc clipped , "\n"
     end if
     
     if lr_param.endcid is not null and
        lr_param.endcid <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Cidade: ", lr_param.endcid clipped, " - ", lr_param.endufd clipped, "\n"
     end if
     
     if lr_param.teltxt is not null and
        lr_param.teltxt <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Telefone: ", lr_param.dddcod clipped , " ", lr_param.teltxt[1,9] clipped , "\n"
     end if
     
     if lr_param.dstqtd is not null and
        lr_param.dstqtd <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Distancia: ", lr_param.dstqtd, " KM", "\n"
     end if
       
 
     if lr_param.ciaempcod = 84 then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Informacoes: ligue (11) 3003-1010" clipped
     else
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Informacoes: ligue (11) 3366-3155" clipped
     end if
     
     return   lr_retorno.mensagem
end function

#-------------------------------------------------
function cts00g10_monta_mensagem_sms(lr_param)
#-------------------------------------------------

 define lr_param   record
     ciaempcod     like datmservico.ciaempcod,
     nom           like datmservico.nom,
     celteldddcod  like datmlcl.celteldddcod ,
     celtelnum     like datmlcl.celtelnum ,
     nomrazsoc     like dpaksocor.nomrazsoc,
     dddcod        like dpaksocor.dddcod,
     teltxt        like dpaksocor.teltxt,
     endcid        like dpaksocor.endcid,
     endufd        like dpaksocor.endufd,
     dstqtd        like datmsrvacp.dstqtd
 end record    
 
 define l_dstqtd   decimal(3,0)
 
 define lr_retorno record
     mensagem char (143)
 end record
 
 initialize lr_retorno.*  to null

 #arredondar valor pra inteiro
 let l_dstqtd = lr_param.dstqtd

      if lr_param.ciaempcod = 84 then

          let lr_retorno.mensagem = "ITAU SEGUROS inf: Seg:"                                 
      else
         let lr_retorno.mensagem = "PORTO SEGURO inf: Seg:"                                 
      end if

      let lr_retorno.mensagem = lr_retorno.mensagem clipped          ,
                                 lr_param.nom[1,20] clipped       ,
                                 " Cel:", lr_param.celteldddcod clipped, "-"   ,
                                 lr_param.celtelnum using "<<<<<<<<&&",  
                                 " Acionado:", lr_param.nomrazsoc[1,18] clipped
                                 
                                 if lr_param.teltxt is not null and lr_param.teltxt <> " " then
                                    let lr_retorno.mensagem = lr_retorno.mensagem clipped          ,  
                                                              " Tel:", lr_param.dddcod clipped, "-"   ,  
                                                                        lr_param.teltxt[1,9] clipped    
                                 end if
       let lr_retorno.mensagem = lr_retorno.mensagem clipped          ,
                                 " Cid:", lr_param.endcid[1,18] clipped, "-", 
                                           lr_param.endufd[1,2] clipped 
                                           
                                           
      if lr_param.dstqtd is not null and lr_param.dstqtd <> " "       then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 " Dist:", l_dstqtd using "<<&", " Km"
       end if
            
                                 

      return  lr_retorno.mensagem

end function

#------------------------------------------#
function cts00g10_verifica_cidade(lr_param)
#------------------------------------------#

 define lr_param record
     cidnom like datmlcl.cidnom,
     ufdcod like datmlcl.ufdcod,
     tipo   char(2)
 end record
 
 define lr_retorno record
     retorno    smallint,
     mensagem   char(100)
 end record
 define lr_ctd01g00 record
     retorno    smallint,
     mensagem   char(100),
     cidsedcod  like datrcidsed.cidsedcod
 end record
 
 define l_ind    smallint,
        l_opcao  integer,
        l_status integer,
        l_char1  char(15),
        l_char2  char(15)
 
 define l_mpacidcod like datkmpacid.mpacidcod
 
 initialize lr_ctd01g00.* to null
 
 let l_opcao = lr_param.tipo
 let l_mpacidcod = null
 
 whenever error continue
 open ccts00g10012 using lr_param.cidnom,
                          lr_param.ufdcod
 fetch ccts00g10012 into l_mpacidcod
 whenever error stop
 if sqlca.sqlcode <> 0 and
    sqlca.sqlcode <> 100 then
    let lr_retorno.retorno  = 2
    let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor ccts00g10012'
    return lr_retorno.retorno,
           lr_retorno.mensagem
 end if
 close ccts00g10012
 
 call ctd01g00_obter_cidsedcod(1,l_mpacidcod)
     returning lr_ctd01g00.retorno,
               lr_ctd01g00.mensagem,
               lr_ctd01g00.cidsedcod
 if lr_ctd01g00.retorno = 1 then
     whenever error continue
     open ccts00g10013 using lr_ctd01g00.cidsedcod,
                              l_opcao
     fetch ccts00g10013 into l_status
     whenever error stop
     if  sqlca.sqlcode = 0 then
         let lr_retorno.retorno  = 0
         let lr_retorno.mensagem = ''
         return lr_retorno.retorno,
                lr_retorno.mensagem
     else
         if sqlca.sqlcode <> 100 then
            let lr_retorno.retorno  = 2
            let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor ccts00g10013'
            return lr_retorno.retorno,
                   lr_retorno.mensagem
         end if
     end if
     close ccts00g10013
 
 end if
 
 let l_char1 = "CIDXSMS", lr_param.ufdcod, l_opcao using '<<<'
 let l_char2 = "CIDXSMSTD", l_opcao using '<<<'
 
 whenever error continue
 open ccts00g10014 using l_char1,
                          l_char2
 fetch ccts00g10014 into l_status
 whenever error stop
 
 if  sqlca.sqlcode = 0 then
     let lr_retorno.retorno  = 0
     let lr_retorno.mensagem = ''
     return lr_retorno.retorno,
            lr_retorno.mensagem
 else
     if sqlca.sqlcode <> 100 then
        let lr_retorno.retorno  = 2
        let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor ccts00g10014'
        return lr_retorno.retorno,
               lr_retorno.mensagem
     end if
 end if
 
 close ccts00g10014
 
 let lr_retorno.retorno  = 1
 let lr_retorno.mensagem = "NAO ACHOU A CIDADE: ", lr_param.cidnom
 return lr_retorno.retorno,
        lr_retorno.mensagem

end function



#--------------------------------------------------------------
function cts00g10_email_monitoramento(param)
#--------------------------------------------------------------

 define param    record
   atdsrvnum     like datmservico.atdsrvnum, 
   atdsrvano     like datmservico.atdsrvano, 
   msgtxt        char (620),
   msgtxtsms     char(143)
 end record
 
 define l_msg        char(700)
 define l_assunto    char(60)
 define l_chave      like datkdominio.cponom     
 define l_email      char(50)  
 define l_remetentes char(5000)
 define l_comando     char(15000) 
 
 ### RODOLFO MASSINI - INICIO 
 #---> Variaves para:
 #     remover (comentar) forma de envio de e-mails anterior e inserir
 #     novo componente para envio de e-mails.
 #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
 define lr_mail record       
        rem char(50),        
        des char(250),       
        ccp char(250),       
        cco char(250),       
        ass char(500),       
        msg char(32000),     
        idr char(20),        
        tip char(4)          
 end record 
 
 define l_anexo   char (300)
       ,l_retorno smallint

 initialize lr_mail
           ,l_anexo
           ,l_retorno
 to null
 
 ### RODOLFO MASSINI - FIM  
  
 let l_msg        = null
 let l_assunto    = null
 let l_chave      = "mail_aviso_correto"
 let l_email      = null
 let l_remetentes = null 
 let l_comando    = null
 
  
 if  param.msgtxt is not null and param.msgtxt != " " then
    let l_msg = "Conteudo e-mail enviado: ", param.msgtxt clipped 
 else
    if param.msgtxtsms is not null and param.msgtxtsms != " " then
       let l_msg = "Conteudo SMS enviado: ", param.msgtxtsms clipped     
    end if 
 end if
 
 let l_assunto = "Aviso Acionamento Corretor. Servico: ", param.atdsrvnum using "<<<<<&&", "/", param.atdsrvano

 
 open ccts00g10005 using l_chave
      foreach ccts00g10005 into l_email

         if l_remetentes is null then
            let l_remetentes = l_email
         else
            let l_remetentes = l_remetentes clipped, ",", l_email
         end if
      end foreach
  close ccts00g10005 
   
 ### RODOLFO MASSINI - INICIO 
 #---> remover (comentar) forma de envio de e-mails anterior e inserir
 #     novo componente para envio de e-mails.
 #---> feito por Rodolfo Massini (F0113761) em maio/2013

 #let   l_comando = ' echo "', l_msg   clipped, '" | send_email.sh ',
 #                  ' -a    ', l_remetentes         clipped,
 #                  ' -s   "', l_assunto clipped, '" '
 #  run   l_comando   
     
 let lr_mail.ass = l_assunto clipped
 let lr_mail.msg = l_msg clipped     
 let lr_mail.des = l_remetentes
 let lr_mail.tip = "text"
 
 call ctx22g00_envia_email_overload(lr_mail.*
                                   ,l_anexo)
 returning l_retorno                                        
                                                
 ### RODOLFO MASSINI - FIM 
   
 
end function 

#-------------------------------------------------
function cts00g10_monta_mensagem_html(lr_param)
#-------------------------------------------------

 define lr_param record
        cabecalho    char(100),
        atdsrvnum    like datmservico.atdsrvnum   ,
        atdsrvano    like datmservico.atdsrvano   ,
        ciaempcod    like datmservico.ciaempcod   ,
        nom          like datmservico.nom         ,
        c24solnom    like datmligacao.c24solnom   ,
        vcllicnum    like datmservico.vcllicnum   ,
        celteldddcod like datmlcl.celteldddcod    ,    
        celtelnum    like datmlcl.celtelnum       ,
        lcldddcod    like datmlcl.dddcod          ,
        lcltelnum    like datmlcl.lcltelnum       ,       
        c24astdes    char (72)                    ,
        c24pbmdes    like datrsrvpbm.c24pbmdes    ,
        lgdtip	     like datmlcl.lgdtip          ,
        lgdnom	     like datmlcl.lgdnom          ,
        lgdnum	     like datmlcl.lgdnum          ,
        cidnom	     like datmlcl.cidnom          ,
        lclcttnom    like datmlcl.lclcttnom       ,             
        asitipabvdes like datkasitip.asitipabvdes ,
        lclidttxt    like datmlcl.lclidttxt       , 
        atdprscod    like datmservico.atdprscod,
        nomrazsoc    like dpaksocor.nomrazsoc,
        dddcod       like dpaksocor.dddcod,
        teltxt       like dpaksocor.teltxt,
        endcid       like dpaksocor.endcid,
        endufd       like dpaksocor.endufd,
        dstqtd       like datmsrvacp.dstqtd             
 end record

 define lr_retorno record
     mensagem char (620)
 end record
 initialize lr_retorno.*  to null
     let lr_retorno.mensagem = "<html>",
                               "<body>",
                               "<br>",
                               "<font size=2 face=Verdana color=white>",
                               "<center>",
                               "<b>",
                               lr_param.cabecalho clipped, "<br>",
                               "</b>",
                               "</center>",
                               "</font>",
                               "<br>", "<br>", 
                               "<font size =2 face = Verdana>" 

     let lr_retorno.mensagem = lr_retorno.mensagem clipped, "<br>",
                            "Segurado: "   , lr_param.nom       clipped, "<br>",
                            "Solicitante: ", lr_param.c24solnom clipped, "<br>"

     if lr_param.vcllicnum is not null and
        lr_param.vcllicnum <> " "      then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                          "Placa   : ", lr_param.vcllicnum  clipped, "<br>"
     end if

     if lr_param.celtelnum is not null and
        lr_param.celtelnum <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                "Celular : "   , lr_param.celteldddcod       clipped, " ",
                  lr_param.celtelnum          using "<<<<<<<<&&", "<br>"
     end if
     
     if lr_param.lcltelnum is not null and
        lr_param.lcltelnum <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                  "Telefone Fixo : "   , lr_param.lcldddcod       clipped, " ",
                   lr_param.lcltelnum       using "<<<<<<<<&&", "<br>"
     end if
     
     
     if lr_param.c24astdes is not null and
        lr_param.c24astdes <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                    "Ocorrencia: " , lr_param.c24astdes clipped, "<br>"
     end if
     if lr_param.c24pbmdes is not null and
        lr_param.c24pbmdes <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                    "Tipo do Problema: ", lr_param.c24pbmdes clipped, "<br>"
     end if
     if lr_param.lgdnom is not null and
        lr_param.lgdnom <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                        "Local da Ocorrencia: ", lr_param.lgdtip clipped, " " ,
                                              lr_param.lgdnom clipped, " " ,
                                              lr_param.lgdnum clipped, "<br>"
     end if
     if lr_param.cidnom is not null and
        lr_param.cidnom <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Cidade: ", lr_param.cidnom clipped, "<br>"
     end if
     if lr_param.lclcttnom is not null and
        lr_param.lclcttnom <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                  "Contato: ", lr_param.lclcttnom clipped, "<br>"
     end if    
     
     let lr_retorno.mensagem = lr_retorno.mensagem clipped,
            "Servico: ", lr_param.atdsrvnum using "<<<<<&&"  , "-", lr_param.atdsrvano using "&&", "<br>"
     
     let lr_retorno.mensagem = lr_retorno.mensagem clipped,
             "Dados do Acionamento do Serviço: ", "<br>"
     
     if lr_param.nomrazsoc is not null and
        lr_param.nomrazsoc <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
            "Prestador: ", lr_param.atdprscod  using "<<<<&&", " ",lr_param.nomrazsoc clipped , "<br>"
     end if
     
     if lr_param.endcid is not null and
        lr_param.endcid <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
    "Cidade: ", lr_param.endcid clipped, " - ", lr_param.endufd clipped, "<br>"
     end if
     
     if lr_param.teltxt is not null and
        lr_param.teltxt <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
       "Telefone: ", lr_param.dddcod clipped , " ", lr_param.teltxt[1,9] clipped , "<br>"
     end if
     
     if lr_param.dstqtd is not null and
        lr_param.dstqtd <> " "       then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                       "Distancia: ", lr_param.dstqtd, " KM", "<br>"
     end if
       
 
     if lr_param.ciaempcod = 84 then
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                            "Informacoes: ligue (11) 3003-1010" clipped, "<br>"
     else
        let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                            "Informacoes: ligue (11) 3366-3155" clipped, "<br>"
     end if
    

    let lr_retorno.mensagem = lr_retorno.mensagem clipped, 
                               "</font>",
                               "<br><br>",
                               "</body>",
                               "</html>" 
 
    return   lr_retorno.mensagem clipped

end function
