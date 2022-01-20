###############################################################################
# Nome do Modulo: cts00m43                                           Kelly    #
#                                                                    Lima     #
# Recepção de cancelamentos realizados via WS                        Ago/2013 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
# --------------------------------------------------------------------------- #
###############################################################################

database porto

define m_cts00m43_prep       smallint
define m_wsgpipe             char(80)

#---->Serviço
define m_atdprscod           like datmservico.atdprscod
define m_c24nomctt           like datmservico.c24nomctt
define m_srrcoddig           like datmservico.srrcoddig
define m_srvcbnhor           like datmservico.srvcbnhor

#----->Etapa
define m_atdetpcod           like datmsrvacp.atdetpcod      
define m_envtipcod           like datmsrvacp.envtipcod  
define m_pstcoddig           like datmsrvacp.pstcoddig
define m_socvclcod           like datmsrvacp.socvclcod

define m_retornoSiebel       smallint #Kelly

#------------------------------------------#
function cts00m43_prepare()
#------------------------------------------#

define l_sql char(6000)

 #Consulta para buscar se o serviço está acionado
 let l_sql = "select  a.atdetpcod     "
             ,"      ,a.envtipcod     "  
             ,"      ,a.pstcoddig     "
             ,"      ,a.socvclcod     "     
             ,"  from datmsrvacp a    "
             ," where a.atdsrvnum = ? "
             ," and a.atdsrvano = ?   "
             ," and a.atdsrvseq = (select max(b.atdsrvseq) "
             ,                   "   from datmsrvacp b     "
             ,                   "  where b.atdsrvnum = ?  "
             ,                   "    and b.atdsrvano = ?) "

 prepare p_cts00m43_001 from l_sql
 declare c_cts00m43_001 cursor for p_cts00m43_001	
 
 #Consulta mensagem para cancelar transmissão GPS
 let l_sql = "select max(mdtmsgnum) "
            ,"  from datmmdtsrv     "      
            ," where atdsrvnum = ?  "
            ,"   and atdsrvano = ?  "

 prepare p_cts00m43_002 from l_sql
 declare c_cts00m43_002 cursor for p_cts00m43_002 	
   
 #Consulta para verificar a situação da transmissão FAX
 let l_sql = " select count(*)           "
            ,"   from datmfax            "        
            ,"  where faxsiscod = 'CT'   "
            ,"    and faxsubcod = ?      "  
            ,"    and faxch1    = ?      "
            ,"    and faxenvsit in (1,3) "
 prepare p_cts00m43_003 from l_sql
 declare c_cts00m43_003 cursor for p_cts00m43_003      

 #Consulta para verificar o maior faxch2 (??????)
 let l_sql = " select max(faxch2)        "
            ,"   from datmfax            "        
            ,"  where faxsiscod = 'CT'   "
            ,"    and faxsubcod = ?      "  
            ,"    and faxch1    = ?      "
 prepare p_cts00m43_004 from l_sql
 declare c_cts00m43_004 cursor for p_cts00m43_004     

 #Consulta número do FAX vinculado ao prestador
 let l_sql = " select  a.nomgrr          "
            ,"        ,a.dddcod          "
            ,"        ,a.faxnum          "
            ,"   from dpaksocor a        "        
            ,"  where a.pstcoddig = ?    "

 prepare p_cts00m43_005 from l_sql
 declare c_cts00m43_005 cursor for p_cts00m43_005  
 
 #Buscar o número da ligação
 let l_sql = " select a.lignum           "
            ,"   from datmligacao a      "        
            ,"  where a.atdsrvnum = ?    "
            ,"    and a.atdsrvano = ?    "

 prepare p_cts00m43_006 from l_sql
 declare c_cts00m43_006 cursor for p_cts00m43_006 
 
 #Busca informações para gravar a etapa
 let l_sql = " select a.c24nomctt        "
            ,"       ,a.socvclcod        " 
            ,"       ,a.srrcoddig        "  
            ,"       ,a.atdprscod        "
            ,"       ,a.srvcbnhor        "            
            ,"   from datmservico a      "        
            ,"  where a.atdsrvnum = ?    "
            ,"    and a.atdsrvano = ?    "

 prepare p_cts00m43_007 from l_sql
 declare c_cts00m43_007 cursor for p_cts00m43_007
 
 #Verifica tipo de indexação do serviço
 let l_sql = " select a.c24lclpdrcod     "
            ,"   from datmlcl a          "        
            ,"  where a.atdsrvnum = ?    "
            ,"    and a.atdsrvano = ?    "
            ,"    and a.c24endtip = 1    "      

 prepare p_cts00m43_008 from l_sql
 declare c_cts00m43_008 cursor for p_cts00m43_008 
 
 #Verifica botões do serviço
 let l_sql = " select m.mdtbotprgseq                "                                                            
            ,"       ,v.mdtcod                      "                                                            
            ,"       ,v.socvclcod                   "                                                            
            ,"   from datmmdtmvt m, datkveiculo v   "                                                            
            ,"  where m.mdtcod = v.mdtcod           "                                                            
            ,"    and m.mdtmvtseq in (select max(mdtmvtseq)                 "                                    
            ,"                         from datmmdtmvt m2                  "                                     
            ,"                        where m2.atdsrvnum = ?               "                                     
            ,"                          and m2.atdsrvano = ?               "                                     
            ,"                          and m2.mdtmvttipcod  = 2           "                                     
            ,"                          and m2.mdtbotprgseq in (1,2,3,14)) "                                     

 prepare p_cts00m43_009 from l_sql
 declare c_cts00m43_009 cursor for p_cts00m43_009              

 #Busca localização do prestador
 let l_sql = " select m.mdtmvtseq                           "
            ,"       ,m.caddat                              "
            ,"       ,m.cadhor                              "   
            ,"       ,m.lclltt                              "         
            ,"       ,m.lcllgt                              "
            ,"   from datmmdtmvt m , datkveiculo v          "        
            ,"  where m.mdtcod = v.mdtcod                   "
            ,"    and mdtmvtseq in (select max(mdtmvtseq)   "
            ,"                        from datmmdtmvt m2    "
            ,"                       where m2.mdtcod  = ?)  "


 prepare p_cts00m43_010 from l_sql
 declare c_cts00m43_010 cursor for p_cts00m43_010   
 
 #Busca coordenandas do serviço
 let l_sql = " select lclltt, lcllgt ",
             "   from datmlcl        ",
             "  where atdsrvnum = ?  ",     
             "    and atdsrvano = ?  ",
             "    and c24endtip = 1  " 
 prepare p_cts00m43_011 from l_sql               
 declare c_cts00m43_011 cursor for p_cts00m43_011
 
 #Busca dados do socorrista                
 let l_sql = " select srrabvnom ",          
             "   from datksrr        ",          
             "  where srrcoddig = ?  "                       
 prepare p_cts00m43_012 from l_sql               
 declare c_cts00m43_012 cursor for p_cts00m43_012

                      
 let m_cts00m43_prep = true
	       
end function 
 
#-----------------------------------------------------------
 function cts00m43_cancela_acionamento(lr_param)
#-----------------------------------------------------------

 define lr_param              record
           atdsrvnum          like datmsrvacp.atdsrvnum,
           atdsrvano          like datmsrvacp.atdsrvano,    
           canmtvcod          like datmsrvacp.canmtvcod,
           funmat             like isskfunc.funmat,
           empcod             like isskfunc.empcod,
           usrtip             like isskfunc.usrtip
 end record

 #---->GPS
 define l_mdtmsgsttdes        char (26)
 define l_mdtmsgnum           like datmmdtsrv.mdtmsgnum
 define l_atldat                like datmmdtlog.atldat
 define l_atlhor                like datmmdtlog.atlhor
 define l_rcbpor                char (6)
 
 #---->FAX
 define l_faxch1              like gfxmfax.faxch1 
 define l_faxch2              like gfxmfax.faxch2
 define l_countFax            smallint
 define l_faxsubcod           like gfxmfax.faxsubcod
 define l_faxchx              char (10)                  

 #---->Controle de erro
 define l_retorno             char (01)
 
 if m_cts00m43_prep is null or
    m_cts00m43_prep <> true then
    call cts00m43_prepare()
 end if 
 
 initialize l_mdtmsgsttdes
           ,l_mdtmsgnum
           ,l_atldat
           ,l_atlhor
           ,l_rcbpor to null
  
 #Busca informações da etapa atual do serviço
 open c_cts00m43_001 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.atdsrvnum
                          ,lr_param.atdsrvano                            
 fetch c_cts00m43_001 into m_atdetpcod
                          ,m_envtipcod
                          ,m_pstcoddig  
                          ,m_socvclcod                        
                          
 #Busca informações do serviço                         
 open c_cts00m43_007 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano                          
 fetch c_cts00m43_007 into m_c24nomctt
                          ,m_socvclcod
                          ,m_srrcoddig
                          ,m_atdprscod
                          ,m_srvcbnhor 

 let l_retorno = "N"
 let m_retornoSiebel = 0 #Sucesso
 
 display "Kelly-  m_atdetpcod", m_atdetpcod
 #Verifica se o serviço está acionado (Etapa 3, 4 ou 10) 
 if m_atdetpcod = 3  OR 
    m_atdetpcod = 4  OR 
    m_atdetpcod = 10 then 
      
      
      
      #Verifica o tipo de transmissão do acionamento
       display "Kelly-  m_envtipcod", m_envtipcod
      case m_envtipcod
      #========================================================================#
         when 1  #GPS
      #========================================================================#
           #Consulta a situação da tranamissão
           call ctn43c00_alt_msg(lr_param.atdsrvnum, lr_param.atdsrvano)
                       returning l_mdtmsgsttdes
                                ,l_atldat
                                ,l_atlhor
                                ,l_rcbpor
                       
           display "Kelly - l_mdtmsgsttdes", l_mdtmsgsttdes
           display "Kelly - l_rcbpor", l_rcbpor
           
           
           if l_mdtmsgsttdes = "AGUARDANDO TRANSMISSAO" OR
              l_mdtmsgsttdes = "AGUARDANDO RETRANSMISSAO" OR
              l_mdtmsgsttdes = "ERRO NA TRANSMISSAO" then  #Transmissão pendente ou com erro 
                
                #Busca o número da mensagem do MDT
                open c_cts00m43_002 using lr_param.atdsrvnum
                                         ,lr_param.atdsrvano                           
                fetch c_cts00m43_002 into l_mdtmsgnum
                display "Kelly - l_mdtmsgnum", l_mdtmsgnum                
                
                #Cancela a transmissão pendente
                call cts00g03_sit_msg_mdt(l_mdtmsgnum, 5) 
                returning l_retorno
                display "Kelly - l_retorno", l_retorno
                
                #Chama o Processo de gravação da etapa, com o motivo
                call cts00m43_grava_etapa(lr_param.atdsrvnum     
                                         ,lr_param.atdsrvano     
                                         ,m_pstcoddig 
                                         ,m_c24nomctt
                                         ,m_socvclcod
                                         ,m_srrcoddig                                         
                                         ,lr_param.canmtvcod) #Código Motivo de Cancelamento
                                         returning m_retornoSiebel  
                                                   
           else #Transmissão ok
                #Chama o Processo de gravação da etapa, com o motivo
                call cts00m43_grava_etapa(lr_param.atdsrvnum     
                                         ,lr_param.atdsrvano     
                                         ,m_pstcoddig
                                         ,m_c24nomctt
                                         ,m_socvclcod
                                         ,m_srrcoddig 
                                         ,lr_param.canmtvcod) #Código Motivo de Cancelamento   
                                         returning m_retornoSiebel          
           
                #Gera transmissão de cancelamento
                call cts00g02_env_msg_mdt (1 
                                          ,lr_param.atdsrvnum     
                                          ,lr_param.atdsrvano
                                          ,""
                                          ,m_socvclcod)                                    
                                          returning l_retorno                                                                                         
           end if    
           
           #Verifica se ocorreu algum erro nas chamadas acima
           if l_retorno = "S" then
               error "Erro ao cancelar/gerar a transmissão pendente de GPS"
               let m_retornoSiebel = 2 #Retorna Erro de Infra
           end if 
           
      #========================================================================#         
         when 2  #Internet
      #========================================================================#
           #Chama o Processo de gravação da etapa, com o motivo
           call cts00m43_grava_etapa(lr_param.atdsrvnum     
                                    ,lr_param.atdsrvano     
                                    ,m_pstcoddig
                                    ,m_c24nomctt
                                    ,m_socvclcod
                                    ,m_srrcoddig
                                    ,lr_param.canmtvcod) #Código Motivo de Cancelamento
                                    returning m_retornoSiebel           
         
           #Cancelar transmissão internet
           call cts00m43_grava_etapa_internet(lr_param.atdsrvnum
                                             ,lr_param.atdsrvano
                                             ,lr_param.canmtvcod
                                             ,lr_param.usrtip
                                             ,lr_param.empcod
                                             ,lr_param.funmat)
                                             returning m_retornoSiebel                                                         
      #========================================================================#
         when 3  #Fax
      #========================================================================#
           let l_faxchx = lr_param.atdsrvnum  using "&&&&&&&&", 
               lr_param.atdsrvano  using "&&" 
                
           let l_faxch1 = l_faxchx  
           let l_faxsubcod = "PS" 
           
           open c_cts00m43_003 using l_faxsubcod 
                                    ,l_faxch1                       
           fetch c_cts00m43_003 into l_countFax  

           open c_cts00m43_004 using l_faxsubcod 
                                    ,l_faxch1                       
           fetch c_cts00m43_004 into l_faxch2           
                   
           #Verifica se existe transmissão pendente
           if l_countFax > 0 then #Pendente ou com erro         
               
               #Cancela transmissão existente
               display "Parametros enviados para a função cts10g01_sit_fax()"
               display "l_faxsubcod",l_faxsubcod
               display "l_faxch1", l_faxch1
               display "l_faxch2", l_faxch2
               
               call cts10g01_sit_fax (4,l_faxsubcod, l_faxch1,l_faxch2)       

               #Chama o Processo de gravação da etapa, com o motivo
               call cts00m43_grava_etapa(lr_param.atdsrvnum     
                                        ,lr_param.atdsrvano     
                                        ,m_pstcoddig 
                                        ,m_c24nomctt
                                        ,m_socvclcod
                                        ,m_srrcoddig 
                                        ,lr_param.canmtvcod) #Código Motivo de Cancelamento
                                        returning m_retornoSiebel              
           else #Sucesso
               #Chama o Processo de gravação da etapa, com o motivo
               call cts00m43_grava_etapa(lr_param.atdsrvnum     
                                        ,lr_param.atdsrvano     
                                        ,m_pstcoddig
                                        ,m_c24nomctt
                                        ,m_socvclcod
                                        ,m_srrcoddig                                                                                
                                        ,lr_param.canmtvcod) #Código Motivo de Cancelamento            
                                        returning m_retornoSiebel
               
               #Chama função para envio do FAX                              
               call cts00m43_envia_fax (lr_param.atdsrvnum
                                       ,lr_param.atdsrvano
                                       ,m_pstcoddig
                                       ,l_faxch1
                                       ,l_faxch2
                                       ,lr_param.funmat
                                       ,l_faxsubcod)
                                       returning m_retornoSiebel         
           end if
      end case  

 else #Servição NÃO acionado
     if m_atdetpcod <> 5 then #Serviço não cancelado
        #Chama o Processo de gravação da etapa, com o motivo
        call cts00m43_grava_etapa(lr_param.atdsrvnum     
                                 ,lr_param.atdsrvano     
                                 ,m_pstcoddig
                                 ,m_c24nomctt
                                 ,m_socvclcod
                                 ,m_srrcoddig 
                                 ,lr_param.canmtvcod) #Código Motivo de Cancelamento 
                                 returning m_retornoSiebel  
     end if
 end if
 
 #Código de retorno --> 0-Sucesso // 1 - Erro de Negocio // 2 - Erro de Infra
 return m_retornoSiebel

end function

#------------------------------------------#
function cts00m43_grava_etapa(lr_param)
#------------------------------------------#

 define lr_param              record
           atdsrvnum          like datmsrvacp.atdsrvnum,
           atdsrvano          like datmsrvacp.atdsrvano,
           pstcoddig          like datmsrvacp.pstcoddig,
           c24nomctt          like datmservico.c24nomctt,
           socvclcod          like datmservico.socvclcod,
           srrcoddig          like datmservico.srrcoddig,
           canmtvcod          like datmsrvacp.canmtvcod          
 end record

 define l_etapaCancelamento   like datmsrvacp.atdetpcod
 define l_resultado           smallint
 
 let l_etapaCancelamento = 5
 let m_retornoSiebel = 0 #Sucesso

 #Chama o Processo de gravação da etapa, com o motivo
 call cts10g04_insere_etapa_motivo(lr_param.atdsrvnum     
                                  ,lr_param.atdsrvano       
                                  ,l_etapaCancelamento
                                  ,lr_param.pstcoddig 
                                  ,lr_param.c24nomctt
                                  ,lr_param.socvclcod 
                                  ,lr_param.srrcoddig 
                                  ,lr_param.canmtvcod) #Código Motivo de Cancelamento
                                  returning l_resultado                          
 
 if  l_resultado  <>  0  then
     error " Erro (", l_resultado, ") na gravação da etapa do serviço."
     let m_retornoSiebel = 2 #Erro de Infra
 end if                  

 #Código de retorno --> 0-Sucesso // 1 - Erro de Negocio // 2 - Erro de Infra
 return m_retornoSiebel

end function

#------------------------------------------#
function cts00m43_grava_etapa_internet(lr_param)
#------------------------------------------#

 define lr_param              record
           atdsrvnum          like datmsrvacp.atdsrvnum,
           atdsrvano          like datmsrvacp.atdsrvano,    
           canmtvcod          like datmsrvacp.canmtvcod,
           usrtip             like isskfunc.usrtip,
           empcod             like isskfunc.empcod,
           funmat             like isskfunc.funmat
 end record

 define l_resultado           smallint
 define l_mensagem            char(100)
 define l_atdetpseq           like datmsrvint.atdetpseq  
 define m_atdetpcod           like datmsrvacp.atdetpcod  
 

 # --OBTER SEQUENCIA/ETAPA DO SERVICO PARA INTERNET-- #
 call cts33g00_inf_internet(lr_param.atdsrvnum,
                            lr_param.atdsrvano)

        returning l_resultado,
                  l_mensagem,
                  l_atdetpseq,
                  m_atdetpcod                     

 let m_atdetpcod = 3 #Cancelamento Internet

 #Busca informações do serviço                         
 open c_cts00m43_007 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano                          
 fetch c_cts00m43_007 into m_c24nomctt
                          ,m_socvclcod
                          ,m_srrcoddig
                          ,m_atdprscod
                          ,m_srvcbnhor

 call cts33g00_registrar_para_internet(lr_param.atdsrvano
                                      ,lr_param.atdsrvnum
                                      ,l_atdetpseq
                                      ,m_atdetpcod #Etapa cancelamento
                                      ,m_atdprscod #DATMSERVICO
                                      ,lr_param.usrtip
                                      ,lr_param.empcod
                                      ,lr_param.funmat
                                      ,lr_param.canmtvcod)
                                      returning l_resultado
                                               ,l_mensagem

display "Retorna da função cts33g00_registrar_para_internet"
display "l_resultado", l_resultado
display "l_mensagem", l_mensagem
  
 if l_resultado = 2 then #Erro de Negocio
    error "Erro gravar etapa internet. Erro: ", l_mensagem
    let m_retornoSiebel = 1 #Erro Negocio
 else
    if l_resultado = 3 then #Erro geral
      error "Erro gravar etapa internet. Erro: ", l_mensagem
      let m_retornoSiebel = 2 #Erro Infra
    else
      let m_retornoSiebel = 0 #Sucesso
    end if
 end if
 
 #Código de retorno --> 0-Sucesso // 1 - Erro de Negocio // 2 - Erro de Infra
 return m_retornoSiebel                                 
                                               
end function

#------------------------------------------#
function cts00m43_envia_fax (lr_param)
#------------------------------------------#

 define lr_param    record
        atdsrvnum   like datmservico.atdsrvnum,
        atdsrvano   like datmservico.atdsrvano,
        pstcoddig   like datmsrvacp.pstcoddig,
        faxch1      like gfxmfax.faxch1, 
        faxch2      like gfxmfax.faxch2,
        funmat      like isskfunc.funmat,
        faxsubcod   like datmfax.faxsubcod  
 end record
 
 define l_faxtxt    char (12)   
 define l_nomgrr    like dpaksocor.nomgrr  
 define l_dddcod    like dpaksocor.dddcod
 define l_faxnum    like dpaksocor.faxnum 
 define l_lignum    like datmligacao.lignum
 define l_envflg    dec(1,0)
 
 let m_retornoSiebel = 0 #Sucesso
 
 #Verifica informações do FAX do Prestador
 open c_cts00m43_005 using lr_param.pstcoddig
 fetch c_cts00m43_005 into l_nomgrr
                          ,l_dddcod
                          ,l_faxnum
                          
 display "Kelly - l_nomgrr", l_nomgrr
 display "Kelly - l_dddcod", l_dddcod
 display "Kelly - l_faxnum", l_faxnum                          
 display "Kelly - Chamei a função cts02g01_fax"
 call cts02g01_fax(l_dddcod, l_faxnum)
        returning l_faxtxt 
 display "Kelly - l_faxtxt", l_faxtxt
 let m_wsgpipe = "vfxCTPS ", l_faxtxt clipped,
               " ", ascii 34, l_nomgrr clipped,
               ascii 34, " ", lr_param.faxch1 using "&&&&&&&&&&",
               " ", lr_param.faxch2 using "&&&&&&&&&&"
   
 display "Kelly - m_wsgpipe", m_wsgpipe              
 open c_cts00m43_006 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
 fetch c_cts00m43_006 into l_lignum         
 display "Kelly - l_lignum", l_lignum
 
 display "Vou chamar a função cts10g01_enviofax passando:"
 display "lr_param.atdsrvnum", lr_param.atdsrvnum
 display "lr_param.atdsrvano", lr_param.atdsrvano
 display "l_lignum", l_lignum
 display "lr_param.faxsubcod", lr_param.faxsubcod
 display "lr_param.funmat", lr_param.funmat
 
 #Chama função para envio do FAX
 call cts10g01_enviofax(lr_param.atdsrvnum, lr_param.atdsrvano, l_lignum, lr_param.faxsubcod, lr_param.funmat)
      returning l_envflg  
  
 display "Kelly - retorno da função de enviar fax:", lr_param.funmat     
 if l_envflg = false then
     error "Erro no envio do FAX na função cts10g01_enviofax"
     let m_retornoSiebel = 2 #Erro de Infra
 end if
 
 start report  rep_laudo
 output to report rep_laudo(lr_param.atdsrvnum  , lr_param.atdsrvano  ,
                            l_dddcod, l_faxnum, "F", l_nomgrr,
                            lr_param.faxch1, lr_param.faxch2)
 finish report  rep_laudo
 #Código de retorno --> 0-Sucesso // 1 - Erro de Negocio // 2 - Erro de Infra
 return m_retornoSiebel
 
end function

#------------------------------------------#
function cts00m43_localizar_prestador(lr_param)
#------------------------------------------#

 define lr_param           record
        atdsrvnum          like datmservico.atdsrvnum,
        atdsrvano          like datmservico.atdsrvano
 end record
 
 define lr_retorno         record
        codigoErro         smallint,      
        mensagemErro       char(100),
        lgdnom             like datmlcl.lgdnom,
        lgdnum             like datmlcl.lgdnum,   
        ufdcod             like datmlcl.ufdcod,
        cidnom             like datmlcl.cidnom,   
        brrnom             like datmlcl.brrnom,
        lgdtip             like datmlcl.lgdtip,          
        lclltt             like datmmdtmvt.lclltt,
        lcllgt             like datmmdtmvt.lcllgt,
        distancia          decimal(8,4) 
 end record

 define l_c24lclpdrcod     like datmlcl.c24lclpdrcod
 define l_mdtbotprgseq     like datmmdtmvt.mdtbotprgseq
 define l_mdtcod           like datkveiculo.mdtcod
 define l_mdtmvtseq        like datmmdtmvt.mdtmvtseq
 define l_caddat           like datmmdtmvt.caddat
 define l_cadhor           like datmmdtmvt.cadhor  
 define l_retorno          smallint
 define l_mensagemPst      char(32000)
 define l_erroflg          char (01)
 define l_srrltt           like datmservico.srrltt
 define l_srrlgt           like datmservico.srrlgt 
 define l_rota_final       char(32000) 
 define m_resumoHora       datetime hour to fraction 
 define l_roter_ativa      smallint
  
 initialize l_c24lclpdrcod,
            l_mdtbotprgseq,
            l_mdtcod      ,
            l_mdtmvtseq   ,
            l_caddat      ,
            l_cadhor      ,
            l_retorno     ,
            l_mensagemPst ,
            l_erroflg     ,
            l_srrltt      ,
            l_srrlgt      ,
            l_rota_final  ,
            m_resumoHora       ,
            lr_retorno.* to null 
 
 let lr_retorno.codigoErro = 0 #Sucesso
 
 if m_cts00m43_prep is null or
    m_cts00m43_prep <> true then
    call cts00m43_prepare()
 end if 
 
 #Busca informações da etapa atual do serviço
 open c_cts00m43_001 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.atdsrvnum
                          ,lr_param.atdsrvano                            
 fetch c_cts00m43_001 into m_atdetpcod
                          ,m_envtipcod
                          ,m_pstcoddig  
                          ,m_socvclcod  

 #Verifica se o serviço está acionado (Etapa 3, 4 ou 10) 
 if m_atdetpcod = 3  OR 
    m_atdetpcod = 4  OR 
    m_atdetpcod = 10 then  
    
    #Verifica se o tipo de envio é GPS
    if m_envtipcod = 1 then 
       
       open c_cts00m43_008 using lr_param.atdsrvnum
                                ,lr_param.atdsrvano                           
       fetch c_cts00m43_008 into l_c24lclpdrcod      
       
       #Verifica se o serviço está indexado por rua
       if l_c24lclpdrcod = 3 then
          open c_cts00m43_009 using lr_param.atdsrvnum
                                   ,lr_param.atdsrvano                          
          fetch c_cts00m43_009 into l_mdtbotprgseq
                                   ,l_mdtcod         
                                   ,m_socvclcod  
          
          #Verifica se o serviço possui botões 
          if l_mdtbotprgseq is not null then #Possui
             #Verifica se o atendimento está encerrado
             if l_mdtbotprgseq <> 3 then
                open c_cts00m43_010 using l_mdtcod                          
                fetch c_cts00m43_010 into l_mdtmvtseq
                                         ,l_caddat         
                                         ,l_cadhor
                                         ,lr_retorno.lclltt
                                         ,lr_retorno.lcllgt                                 
                
                #Busca dados do endereço com a latitude e longitude
                #Invertido Latitude e Longitude para teste da função
                call figrc011_inicio_parse()                
                call ctx25g01_endereco_comp(lr_retorno.lcllgt, lr_retorno.lclltt, "0") #Online
                     returning l_retorno 
                              ,lr_retorno.ufdcod
                              ,lr_retorno.cidnom
                              ,lr_retorno.lgdtip
                              ,lr_retorno.lgdnom
                              ,lr_retorno.brrnom
                              ,lr_retorno.lgdnum    
                                                                                     
                call figrc011_fim_parse()                
                     display "lr_retorno.codigoErr: ", lr_retorno.codigoErro
                     display "lr_retorno.mensagemErro: ", lr_retorno.mensagemErro    
                     display "lr_retorno.lgdnom: ", lr_retorno.lgdnom    
                     display "lr_retorno.lgdnum: ", lr_retorno.lgdnum
                     display "lr_retorno.ufdcod: ", lr_retorno.ufdcod    
                     display "lr_retorno.cidnom: ", lr_retorno.cidnom         
                     display "lr_retorno.brrnom: ", lr_retorno.brrnom
                     display "lr_retorno.lclltt: ", lr_retorno.lclltt    
                     display "lr_retorno.lcllgt: ", lr_retorno.lcllgt

                
                if l_retorno <> 0 then
                   let lr_retorno.codigoErro = 2 #Erro Infra
                   let lr_retorno.mensagemErro =  "ERRO AO CONSULTAR OS DADOS DO ENDEREÇO" 
                else
                   #Busca informações do serviço                         
                   open c_cts00m43_007 using lr_param.atdsrvnum
                                            ,lr_param.atdsrvano                          
                   fetch c_cts00m43_007 into m_c24nomctt
                                            ,m_socvclcod
                                            ,m_srrcoddig
                                            ,m_atdprscod
                                            ,m_srvcbnhor
                  
                    
                  #Busca as coordenadas do Serviço           
                  open c_cts00m43_011 using lr_param.atdsrvnum
                                           ,lr_param.atdsrvano         
                  fetch c_cts00m43_011 into l_srrltt
                                           ,l_srrlgt                           
                  close c_cts00m43_011 
                  
                  open c_cts00m43_012 using m_srrcoddig   
                  fetch c_cts00m43_012 into l_mensagemPst
                  close c_cts00m43_012
                  
                  display "m_c24nomctt", m_c24nomctt
                  display "m_socvclcod", m_socvclcod
                  display "m_srrcoddig", m_srrcoddig
                  display "m_atdprscod", m_atdprscod
                  display "m_srvcbnhor", m_srvcbnhor
                  display "l_srrltt", l_srrltt
                  display "l_srrlgt", l_srrlgt                  

                   #Verifica roteirização do serviço
                   display "Latitude do serviço:",l_srrltt
                   display "Longitute do serviço:", l_srrlgt
                   display "Latitude prestador:", lr_retorno.lclltt
                   display "Longitute prestador:", lr_retorno.lcllgt 
                   
                   let l_roter_ativa = ctx25g05_rota_ativa()     
                   
                   if l_roter_ativa = true then
                      call cts00m02_dist(l_srrltt,l_srrlgt,lr_retorno.lclltt, lr_retorno.lcllgt)
                         returning lr_retorno.distancia
                                  ,l_rota_final
                   else
                      call cts18g00(l_srrltt,
		                    l_srrlgt,
		                    lr_retorno.lclltt,
		                    lr_retorno.lcllgt)
		          returning lr_retorno.distancia
                   end if
                      
                   display "lr_retorno.distancia", lr_retorno.distancia
                   display "l_rota_final", l_rota_final            
                   
                   #Verifica se o serviço está no prazo
                   
                   
                   if m_srvcbnhor >= current then  
                     let l_mensagemPst = l_mensagemPst clipped,
                                         ', o cliente entrou em contato solicitando a sua localização. ',    
                                         'Favor cumprir a previsão. Se não for possível, entre em contato ', 
                                         'com a Central de Operações para novo posicionamento.'                  
                   else                   
                     let l_mensagemPst = l_mensagemPst clipped,
                     	                 ', este serviço esta atrasado. Entre em contato com a Central ',
                                         'de Operações para novo posicionamento.'
                   end if
                   
                   display 'Mensagem ao prestador: ', l_mensagemPst             
                   	   		   
                    #Enviar mensagem ao Prestador   
                    initialize lr_param.atdsrvnum, lr_param.atdsrvano to null 
                    
                    call cts00g02_env_msg_mdt(1
                                             ,lr_param.atdsrvnum
                                             ,lr_param.atdsrvano
                                             ,l_mensagemPst
                                             ,m_socvclcod)
                    returning l_erroflg
		    
                    #Kelly - Comentado código, pois se o prestador não receber a mensagem,
                    #não deve interferir no fluxo do programa 
                    #if l_erroflg = "N" then
                    #   let lr_retorno.codigoErro = 1 #Erro Negócio
                    #   let lr_retorno.mensagemErro =  "ERRO AO ENVIAR MENSAGEM AO PRESTADOR"                    
                    #end if                   
                end if
             else #Serviço encerrado
                  let lr_retorno.codigoErro = 1 #Erro Negócio
                  let lr_retorno.mensagemErro =  "ATENDIMENTO JÁ ENCERRADO" 
             end if 
          else #Serviço não possui botões
              let lr_retorno.codigoErro = 1 #Erro Negócio
              let lr_retorno.mensagemErro =  "NENHUMA COORDENADA DO SERVIÇO RECEBIDA"          
          end if
       else #Não inedexado por rua
           let lr_retorno.codigoErro = 1 #Erro Negócio
           let lr_retorno.mensagemErro =  "DISTANCIA NÃO DISPONIVEL. SERVIÇO NÃO INDEXADO"
       end if   
    else #Acionamento diferente de GPS
        let lr_retorno.codigoErro = 1 #Erro Negócio
        let lr_retorno.mensagemErro =  "SERVIÇO NÃO ACIONADO VIA GPS"
    end if    
 else #Serviço não acionado
     let lr_retorno.codigoErro = 1 #Erro Negócio
     let lr_retorno.mensagemErro =  "SERVIÇO NÃO ACIONADO" 
 end if   
 
 let m_resumoHora = current
		    
 display "Fim: ", m_resumoHora 
 
 return lr_retorno.codigoErro
       ,lr_retorno.mensagemErro
       ,lr_retorno.lgdtip
       ,lr_retorno.lgdnom
       ,lr_retorno.lgdnum
       ,lr_retorno.ufdcod
       ,lr_retorno.cidnom
       ,lr_retorno.brrnom
       ,lr_retorno.lclltt
       ,lr_retorno.lcllgt
       ,lr_retorno.distancia
 
end function 
