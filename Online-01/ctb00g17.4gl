#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: Ponto Socorro                                              #
# Modulo.........: ctb00g17                                                   #
# Analista Resp..: Beatriz Araujo                                             #
# Descricao......: Interface de operacoes das OP recebedis no listener        #
# ........................................................................... #
# Desenvolvimento: Robson Ruas                                                #
# Liberacao......: 31/01/2013                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto
globals "/homedsa/projetos/geral/globals/ffpgc361.4gl" 
globals "/homedsa/projetos/geral/globals/ffpgc367.4gl"  

define m_arq    char(100)
define m_prep   smallint 

#--------------------------------------------------------------------------------------------
function ctb00g17_prepare()
#--------------------------------------------------------------------------------------------

   define l_sql char(3000)
                                                      
   let l_sql =  "select    pstcoddig,     " 
                ,"         segnumdig,     " 
                ,"         lcvcod,        " 
                ,"         dscpgtordnum   " 
                ,"from dbsmopg            " 
                ,"where  socopgnum    = ? " 
   prepare pctb00g17001 from l_sql                
   declare cctb00g17001 cursor for pctb00g17001
   
   let l_sql =  " select socopgsitcod     "
               ,"       ,socopgnum        "
               ,"   from dbsmopg          "          
               ,"  where dscpgtordnum = ? "  
   prepare pctb00g17002 from l_sql                   
   declare cctb00g17002 cursor for pctb00g17002
   
   let l_sql =  "select socopgsitcod,  "
                      ,"dscpgtordnum   "          
                ,"from  dbsmopg        "          
                ,"where socopgnum = ?  "  
   prepare pctb00g17003 from l_sql                   
   declare cctb00g17003 cursor for pctb00g17003
   
   let l_sql =  " select 1                "    
               ,"   from dbsmopg          "    
               ,"  where socopgnum = ? "    
   prepare pctb00g17004 from l_sql             
   declare cctb00g17004 cursor for pctb00g17004
   
    #Matricula Responsavel pela Requisitante - Fornax-Quantum  
    let l_sql =  "select grlinf     "                          
                ,"  from datkgeral  "                          
                ," where grlchv = ? "                          
    prepare pctb00g17005 from l_sql                           
    declare cctb00g17005 cursor for pctb00g17005  
    #Matricula Responsavel pela Requisitante - Fornax-Quantum  
    
    
    let l_sql =  " select trbpgtordpcmflg,   ",
                         "trbnaopgtordpcmflg ",    
                   "from dbsmopg ",    
                   "where socopgnum = ? "    
   prepare pctb00g17006 from l_sql             
   declare cctb00g17006 cursor for pctb00g17006
    
   let m_prep = true      

end function 

#Cancelar um OP no sistema do Porto Socorro - Inicio 
#--------------------------------------------------------------------------------------------
function ctb00g17_cancela_op_sap(lr_param)
#--------------------------------------------------------------------------------------------
define lr_param record                                  
       socopgnum    like dbsmopg.socopgnum    ,      
       socopgsitcod like dbsmopg.socopgsitcod ,      
       ciaempcod    char(5),      
       funmat       like isskfunc.funmat,
       empcod       like isskusuario.empcod            
end record

define lr_opsit record  
        pstcoddig    like dbsmopg.pstcoddig
       ,segnumdig    like dbsmopg.segnumdig
       ,lcvcod       like dbsmopg.lcvcod
       ,dscpgtordnum like dbsmopg.dscpgtordnum
       ,favtip       integer      
end record 

define l_dscfinsispgtordnum  like dbsmopg.dscfinsispgtordnum

define lr_canc_op   char(1),
       l_chave      char(50),
       l_desc       char(1)

    initialize gr_010_request.*            
              ,gr_010_response.*           
              ,gr_aci_req_head.*
              ,ga_010_msg_rs           
              ,gr_aci_res_head.*
              ,l_dscfinsispgtordnum to null  
    
    
    if m_prep is null or m_prep = false then
       call ctb00g17_prepare()
    end if 
    
    let lr_opsit.favtip = 0
    let lr_canc_op      = 'N' 
 
    display "OP: ",  lr_param.socopgnum
 
    
    if lr_param.funmat is null or lr_param.funmat = " "  then                       
    
       let l_chave  = "PSOMATRICULASAP"        
       open cctb00g17005 using  l_chave    
       fetch cctb00g17005 into  lr_param.funmat  
       close cctb00g17005               
       
    end if 
    if lr_param.empcod is null or lr_param.empcod = " "  then                       
       let lr_param.empcod = 01
    end if                         
   
    open  cctb00g17004 using   lr_param.socopgnum
    fetch cctb00g17004 
    
    if sqlca.sqlcode = 0 then 
        let l_desc = 'N'  
    else 
        let l_desc = 'S'  
    end if
    
   #Verica se existe nota com desconto para OP   
   open  cctb00g17001 using  lr_param.socopgnum                    
   fetch cctb00g17001 into   lr_opsit.pstcoddig   
                             ,lr_opsit.segnumdig   
                             ,lr_opsit.lcvcod      
                             ,lr_opsit.dscpgtordnum 
 
      #Verificar o tipo de Favorecido 
      if lr_opsit.pstcoddig is not null and                                   
         lr_opsit.segnumdig is null                                           
         then                                                                   
         
         if lr_opsit.pstcoddig <> 3 then
            let lr_opsit.favtip = 1    # Prestador    
         else
            let lr_opsit.favtip = 3    # # Reembolso(segurado, prest, loja)   
         end if                            
      else                                                                      
         if lr_opsit.lcvcod is not null and                                   
            lr_opsit.segnumdig is null                                        
            then                                                                
            let lr_opsit.favtip = 4   # Locadora                              
         else                                                                   
            if lr_opsit.segnumdig is not null or lr_opsit.pstcoddig = 3     
               then                                                             
               let lr_opsit.favtip = 3    # Reembolso(segurado, prest, loja)  
            end if                                                              
         end if                                                                 
      end if       
      
      let gr_aci_req_head.id_integracao   = "010PTSOC"                            
      let gr_aci_req_head.usuario         = lr_param.funmat  #Nao requerido    
      
      if lr_opsit.favtip = 3 or l_desc = 'S' then
         let gr_010_request.flag_tributavel     = 'N' 
         let gr_010_request.tipo_documento      = "11"     #Codigo Origem 
         
         let gr_010_request.empresa             = lr_param.ciaempcod using '<&&&&'    # Codigo da empresa.              
         let gr_010_request.num_doc_refer       = lr_param.socopgnum     # Numero de referencia do doc.    
         let gr_010_request.motivo_cancel       = "05"                   # Motivo do cancelamento.         
         let gr_010_request.matricula           = "F",lr_param.empcod using "&&",lr_param.funmat using "<<&&&&&" # Usuario SAP.                    
         
         let lr_canc_op = 'S' 
         
      else 
        
         let gr_010_request.flag_tributavel     = 'S'                                                      
         let gr_010_request.tipo_documento      = "Z011"                                                     
                                                                                                           
         let gr_010_request.empresa          = lr_param.ciaempcod using '<&&&&'       # Codigo da empresa.                 
         let gr_010_request.num_doc_refer    = lr_param.socopgnum       # Numero de referencia do doc.       
         let gr_010_request.motivo_cancel    = "02"                     # Motivo do cancelamento.            
         let gr_010_request.matricula        = "F",lr_param.empcod using "&&",lr_param.funmat using "<<&&&&&" # Usuario SAP.     
         let lr_canc_op = 'S'                    
      
     end if    
     
     #Cancela a OP de todos os Favorecidos 
     if lr_canc_op = 'S' then

       
        call ffpgc372_canc_op_ref()                                                                                               
         
        call ctb00g17_log_cancelamento()                                                                                                                          
                                                                                                                                   
       if gr_aci_res_head.codigo_retorno <> 0 and gr_aci_res_head.codigo_retorno <> 3 then                                                                                
          return gr_aci_res_head.codigo_retorno,  gr_aci_res_head.mensagem 
       else
            whenever error continue
               select dscfinsispgtordnum
                 into l_dscfinsispgtordnum
                 from dbsmopg
                where socopgnum = lr_param.socopgnum
            
            if sqlca.sqlcode = 0 then             
        
                if gr_010_request.flag_tributavel = 'S' and  
                   lr_opsit.dscpgtordnum is not null    and 
                   lr_opsit.dscpgtordnum <> 0           and
                   l_dscfinsispgtordnum is not null     and
                   l_dscfinsispgtordnum <> 0            then
                   
                   let gr_010_request.flag_tributavel     = 'N' 
                   let gr_010_request.tipo_documento      = "11"     #Codigo Origem 
                   let gr_010_request.empresa             = lr_param.ciaempcod using '<&&&&'    # Codigo da empresa.              
                   let gr_010_request.num_doc_refer       = lr_opsit.dscpgtordnum  # Numero de referencia do doc.    
                   let gr_010_request.motivo_cancel       = "05"                   # Motivo do cancelamento.         
                   let gr_010_request.matricula           = "F",lr_param.empcod using "&&",lr_param.funmat using "<<&&&&&" # Usuario SAP.                    
                
                   call ffpgc372_canc_op_ref()  
                
                   call ctb00g17_log_cancelamento()      
                   
                end if 
            else
               display "OP: ", lr_param.socopgnum
               display "dscfinsispgtordnum: ", l_dscfinsispgtordnum
               display "Erro:  ", sqlca.sqlcode
            end if
            whenever error stop
        end if                                                                                                                     
    end if 
      
   return gr_aci_res_head.codigo_retorno,  gr_aci_res_head.mensagem     
     
end function 
#Cancelar um OP no sistema do Porto Socorro - Fim 

#Receber o estímulo do Cancelamento da OP pelo SAP - Incio 
#--------------------------------------------------------------------------------------------
function ctb00g17_recebe_canc_op_sap(lr_param)
#--------------------------------------------------------------------------------------------

                                                                                            
  define lr_param        record                                                            
          empcod          decimal(02,00)  ## empresa                                        
         ,docReferencia   decimal(16,00)  ## doc referencia                                 
         ,docSAP          char(16)        ## op people                                      
         ,ppsopgcanmtvcod smallint        ## codigo motivo                                  
         ,atlmat          dec(06,00)      ## matricula resp. pelo cancelamento              
         ,atlemp          dec(02,00)      ## empresa do resp. pelo cancelamento             
         ,desccancelamento char(100)      ## descricao do cancelamento                      
         ,datcancelamento  date           ## data do cancelamento                           
         ,tipmatricula     char(10)       ## tipo matricula                                 
         ,cpfcnpj          char(16)       ## CPF/CNPF                                       
  end    record                         
                                                      
  define l_opgitm record
         socopgnum  like dbsmopg.socopgnum    ,
         soctip     like dbsmopg.soctip       ,
         atdsrvnum  like dbsmopgitm.atdsrvnum ,
         atdsrvano  like dbsmopgitm.atdsrvano ,
         ciaempcod  like datmservico.ciaempcod,
         atdsrvorg  like datmservico.atdsrvorg,
         atdcstvlr  like datmservico.atdcstvlr
  end record
  
  define l_ctt           smallint ,
         l_stt           smallint ,
         l_err           integer  ,
         l_msg           char(3000),
         l_txt           char(250),
         l_sqlcode       integer  ,
         l_sqlerrd       integer  ,
         l_qtdsrv        integer  ,
         l_socopgsitcod  like dbsmopg.socopgsitcod, 
         l_op_desc       char(1),
         l_opaux         char(16),
         l_socopgnum     like dbsmopg.socopgnum,
         l_dscpgtordnum  like dbsmopg.dscpgtordnum
         
  initialize l_opgitm.* to null
  
  if m_prep is null then 
     call ctb00g17_prepare()                
  end if                 
  
  if m_prep = false then  
     call ctb00g17_prepare()
  end if                                       
  
  let l_ctt = null
  let l_stt = 8
  let l_err = 0
  let l_msg = null
  let l_txt = null
  let l_sqlcode = 0
  let l_sqlerrd = 1
  let l_qtdsrv  = 0
  let l_op_desc = 'S' # OP EH DE DESCONTO
  
  
  #---------------------------------------------------------------------#
  # VERIFICA SE A OP QUE ESTA SENDO CANCELADA EH A DESCONTO OU NAO      #
  #---------------------------------------------------------------------#
  
  #whenever error continue
     open  cctb00g17003 using   lr_param.docReferencia  
     fetch cctb00g17003 into    l_socopgsitcod,
                                l_dscpgtordnum
     
     if sqlca.sqlcode <>  0 then 
         
        #fornax marco/2016 - ajustar nr OP, retirando o tipo desconto
        let l_opaux =  lr_param.docReferencia
        let l_opaux =  l_opaux[1,8]
        let lr_param.docReferencia =  lr_param.docReferencia - 90000000
         
        open  cctb00g17003 using   lr_param.docReferencia  
        fetch cctb00g17003 into    l_socopgsitcod,
                                   l_dscpgtordnum
        
        let l_op_desc = 'S' # OP EH DE DESCONTO
     else
        let l_op_desc = 'N' # OP NAO EH DE DESCONTO
     end if 
  #whenever error stop
  
  
  #-------------------------------------------------------------#
  # VERIFICA O TIPO DE OP E O PROCEDIMENTO A SER REALIZADO      #
  #-------------------------------------------------------------#
         
  if l_op_desc =  'N' then  
     
     if l_socopgsitcod  <> 8 then 
        #------------------------------------------------------------------------------------------#
        # VERIFICA SE A OP NORMAL TEM UMA OP DE DESCONTO ATRELADA PARA REALIZAR O CANCELAMENTO     #
        # PARA SAP AS OPS SAO DOIS DOCUMENTOS ENTAO TEMOS QUE CONTROLAR O CANCELAMENTO DAS DUAS OPS#
        #------------------------------------------------------------------------------------------#
        if l_dscpgtordnum is not null and l_dscpgtordnum <> 0 then
           Display "SAP chamou o cancelamento"
           call ctb00g17_cancela_op_sap(l_dscpgtordnum    
                                        ,l_socopgsitcod 
                                        ,lr_param.empcod
                                        ," ", " ")  
                           returning l_err, l_msg
       end if 
        
        #whenever error continue
           declare c_opgitm_sel02 cursor with hold for
           select o.socopgnum, o.soctip
                , i.atdsrvnum, i.atdsrvano
                , s.ciaempcod, s.atdsrvorg, s.atdcstvlr
           from dbsmopg o, dbsmopgitm i, datmservico s
           where o.socopgnum = i.socopgnum
             and i.atdsrvnum = s.atdsrvnum
             and i.atdsrvano = s.atdsrvano
             and i.socopgnum = lr_param.docReferencia
           order by i.socopgitmnum
        
           foreach c_opgitm_sel02 into l_opgitm.*
              
              let l_qtdsrv = l_qtdsrv + 1
              
              if l_opgitm.atdsrvorg != 2
                 then
                 initialize l_opgitm.atdcstvlr to null
              end if
              
              call ctd07g00_upd_srv_opg('', 
                                        l_opgitm.atdcstvlr,
                                        l_opgitm.atdsrvnum,
                                        l_opgitm.atdsrvano)
                              returning l_sqlcode, l_sqlerrd
              if l_sqlerrd != 1
                 then
                 let l_err = 1
                 let l_stt = 7
                 let l_msg = "OP PS - Erro (", sqlca.sqlcode, ") no cancelamento pagamento do servico ", 
                             l_opgitm.atdsrvnum using "&&&&&&&&", "-",
                             l_opgitm.atdsrvano using "&&",
                             " | OP: ", lr_param.docReferencia
                             
                 display 'CTX33G00: ', l_msg clipped
              end if
           end foreach
        #whenever error stop
        
        # nao achou itens
        if l_opgitm.atdsrvnum is null
           then
           let l_err = 1
           let l_stt = 7
           let l_msg =  "OP PS - Erro na consulta aos itens da OP: ",
                        l_err, " | OP: ", lr_param.docReferencia
           display 'CTX33G00: ', l_msg clipped
        end if
        
        display 'CTX33G00: Qtd servicos: ', l_qtdsrv
        
        #----------------------------------------------------------------
        # cancelamento contabil
        if l_stt = 8 then
           if lr_param.empcod = 1 then # so empresa 1 provisiona
           
              # fazer o cancelamento na camada da contabilidade
              
           end if
        end if
        
        #----------------------------------------------------------------
        # inserir etapa
        if l_stt = 8
           then
           call cts50g00_insere_etapa(l_opgitm.socopgnum, 5, 999999)
                returning l_err, l_msg
                
           if l_err != 1
              then
              let l_err = 1
              let l_stt = 7
              let l_msg =  "OP: ", lr_param.docReferencia, " | ", l_msg clipped
              display 'CTX33G00: ', l_msg clipped
           else
              display 'CTX33G00: etapa OK'
           end if
        end if
        # cancelamento ok
        let l_stt = 8
        let l_err = 0
        let l_msg = null
     end if 
  else
     if l_socopgsitcod  <> 8 then
        
        #-------------------------------------------------------------------------------------#
        # QUANDO RECEBER O CANCELAMENTO DA OP DE DESCONTO TEMOS QUE CANCELAR A OP NORMAL      #
        #-------------------------------------------------------------------------------------#
        call ctb00g17_cancela_op_sap(l_socopgnum    
                                     ,l_socopgsitcod 
                                     ,lr_param.empcod
                                     ," ", " ")  
                        returning l_err, l_msg
      
        let lr_param.docReferencia  = l_socopgnum 
     else 
       # cancelamento nao foi possivel no People, atualizar OP para status EMITIDA
       let l_stt = l_socopgsitcod
       let l_err = 0                                                
       let l_msg = 'OP :',l_socopgnum , " com o status de cancelado"   
       return l_err, l_msg                                          
     end if 
  end if
  
  #---------------------------------------------------------------------#
  # VERIFICA SE DEVE ATUALIZAR A OP PELA NORMAL OU PELO DESCONTO        #
  #---------------------------------------------------------------------#
  #whenever error continue
     
     if l_op_desc = 'N' then
        update dbsmopg set socopgsitcod = l_stt
         where socopgnum = lr_param.docReferencia 
     else
        
        let lr_param.docReferencia = lr_param.docReferencia - 90000000
        
        update dbsmopg set socopgsitcod = l_stt
         where socopgnum = lr_param.docReferencia  
	 
	 let lr_param.docReferencia = lr_param.docReferencia + 90000000
	 
	 
	 
     end if 

  #whenever error stop
  
  if sqlca.sqlcode != 0 or
     sqlca.sqlerrd[3] != 1
     then
     let l_err = 1
     let l_msg = "Erro na atualizacao da OP(emissao): ", sqlca.sqlcode,
                 "|", sqlca.sqlerrd[3] , " OP: ", lr_param.docReferencia
     display 'CTX33G00: ', l_msg clipped
  else
     display 'CTX33G00: Update OP OK'
  end if
  
  error ' OP cancelada com sucesso '
  
  return l_err, l_msg

end function 
#Receber o estímulo do Cancelamento da OP pelo SAP - Fim 

#Receber o retorno de OP emitida - Inicio
#--------------------------------------------------------------------------------------------
function ctb00g17_retorno_op_emitida(lr_retorno)   
#--------------------------------------------------------------------------------------------
   define lr_retorno       record                                   
           orgporto         decimal(10,0)    ## origem porto               
          ,codempresa       char(5)          ## codigo empresa             
          ,pedidosap        decimal(10,0)    ## pedido SAP                 
          ,docReferencia    decimal(16,0)    ## nro docto ref legado       
          ,datgeracao       date             ## data Geração               
          ,docSAP           char(16)          ## nro da op gerada  SAP        
          ,montante         char(100)        ## montante                   
          ,codigo_retorno   smallint         ## codigo do erro             
          ,mensagem_retorno char(3000)       ## mensagem de erro           
   end    record 
   
   define l_txt             char(250)
         ,l_nro_desconto    char(1) 
         ,l_err             integer       
         ,l_msg             char(3000) 
         ,l_trbpgtordpcmflg    like dbsmopg.trbpgtordpcmflg   
         ,l_trbnaopgtordpcmflg like dbsmopg.trbnaopgtordpcmflg
         ,l_opaux              like dbsmopg.socopgnum
         ,l_opauxc             char(16)
         ,l_cont            smallint
         
  initialize  l_txt,l_nro_desconto    
             ,l_msg,l_trbpgtordpcmflg 
             ,l_trbnaopgtordpcmflg
             ,l_opaux to null
             
   let l_err = 0          
             
  if m_prep is null or m_prep = false then   
     call ctb00g17_prepare()                 
  end if                                     
             
  let m_arq = "./OP",lr_retorno.docReferencia using '<<<<<<<<<<<<<<<<<<',"RETSAP.txt"
  
  start report ctb00g17_resumo to m_arq
  
  let l_txt = 'OP.PS.....:' , lr_retorno.docReferencia
  output to report ctb00g17_resumo(l_txt)
  
  let l_txt = 'OP.SAP.:' , lr_retorno.docSAP
  output to report ctb00g17_resumo(l_txt)
  
  let l_txt = '----------------------------------------------------------------------'
  output to report ctb00g17_resumo(l_txt)
  
  
  display "Processadno a OP: ",lr_retorno.docReferencia
  
  whenever error continue
  
    set lock mode to not wait # estamos retirando o wait pois fazemos o controle manual
    
    open  cctb00g17004 using   lr_retorno.docReferencia  
    fetch cctb00g17004 
    
    if sqlca.sqlcode = 0 then 
        let l_nro_desconto = 'N' 
        
        let l_cont = 0
        while true
           let l_cont = l_cont + 1
        
           open  cctb00g17006 using lr_retorno.docReferencia
           fetch cctb00g17006 into  l_trbpgtordpcmflg,      
                                    l_trbnaopgtordpcmflg    
           close cctb00g17006                               
           
           if sqlca.sqlcode = -243 or
              sqlca.sqlcode = -244 or
              sqlca.sqlcode = -245 or
              sqlca.sqlcode = -246 then
              if l_cont < 11  then
                 sleep 1
                 continue while
              end if
           end if
           exit while
        end while
        
    else 
        let l_nro_desconto = 'S'
        
	#fornax marco/2016 - ajustando o nr da OP, retirando o cod tip desc
        let l_opauxc = lr_retorno.docReferencia
        let l_opauxc = l_opauxc[1,8]
        let lr_retorno.docReferencia = l_opauxc
        let l_opaux = lr_retorno.docReferencia - 90000000 
        
        let l_cont = 0
        while true
           let l_cont = l_cont + 1
        
           open  cctb00g17006 using l_opaux 
           fetch cctb00g17006 into  l_trbpgtordpcmflg,                                   
                                    l_trbnaopgtordpcmflg
           close cctb00g17006                              
           
           if sqlca.sqlcode = -243 or
              sqlca.sqlcode = -244 or
              sqlca.sqlcode = -245 or
              sqlca.sqlcode = -246 then
              if l_cont < 11  then
                 sleep 1
                 continue while
              end if
           end if
           exit while
        end while
    end if 
   
   set lock mode to wait 20 # estamos colocando, pois terminamos o controle manual
  
  whenever error stop
   
   display "l_nro_desconto             : ",l_nro_desconto 
   display "lr_retorno.docReferencia   : ",lr_retorno.docReferencia   
   display "lr_retorno.docSAP          : ",lr_retorno.docSAP          
   display "lr_retorno.codempresa      : ",lr_retorno.codempresa      
   display "lr_retorno.codigo_retorno  : ",lr_retorno.codigo_retorno  
   display "lr_retorno.mensagem_retorno: ",lr_retorno.mensagem_retorno
   display "l_trbpgtordpcmflg          : ",l_trbpgtordpcmflg 
   display "l_trbnaopgtordpcmflg       : ",l_trbnaopgtordpcmflg
   display ""
   
   if l_nro_desconto = 'S' then 
      
      if l_trbnaopgtordpcmflg = 'N' then
         display "Entrei para processar: ", lr_retorno.docReferencia
         call ctb00g17_opdesc( lr_retorno.docReferencia
                              ,lr_retorno.docSAP
                              ,lr_retorno.codempresa
                              ,lr_retorno.codigo_retorno
                              ,lr_retorno.mensagem_retorno)
         returning l_err, l_msg   
      else
         display "Processamento duplicado: ",lr_retorno.docReferencia
         let l_err = 0
         let l_msg = ''
      end if    
   else   
      
      if l_trbpgtordpcmflg = 'N' then 
         display "Entrei para processar: ", lr_retorno.docReferencia
         call ctb00g17_op( lr_retorno.docReferencia 
                          ,lr_retorno.docSAP    
                          ,lr_retorno.codempresa
                          ,lr_retorno.codigo_retorno
                          ,lr_retorno.mensagem_retorno)
         returning l_err, l_msg
      else
          display "Processamento duplicado: ",lr_retorno.docReferencia
          let l_err = 0
          let l_msg = ''
       end if 
   end if 
   display "l_msg1: ",l_msg clipped
  #Erro na atualizacao
  if l_err != 0 then
     let l_txt = 'SAP - Erro na emissao: ', l_err, ' - ',l_msg clipped
     output to report ctb00g17_resumo(l_txt)
     
     let l_txt = 'Descricao SAP.....: ', l_msg
     output to report ctb00g17_resumo(l_txt)
     
     let l_msg = 'Descricao Informix PS: ', l_msg clipped
     output to report ctb00g17_resumo(l_msg)
     
     let l_txt = 'OP PS - Atualizada para status OK PARA EMISSAO'
     output to report ctb00g17_resumo(l_txt)
     
     finish report ctb00g17_resumo
     
     call ctb00g17_mail(lr_retorno.docReferencia)
     #return l_err, l_msg
     
     let l_err = 1
     
  end if
  
  return l_err, l_msg clipped

end function 
#Receber o retorno de OP emitida - Fim 

#--------------------------------------------------------------------------------------------
report ctb00g17_resumo(l_linha)
#--------------------------------------------------------------------------------------------
  define l_linha char(250)
  
  output
  
     left margin     0
     bottom margin   0
     top margin      0
     right margin  202
     page length    20
    
  format
  
     on every row
        print column 01, l_linha clipped
        
end report

#--------------------------------------------------------------------------------------------
function ctb00g17_mail(l_docReferencia)
#--------------------------------------------------------------------------------------------

  define l_ret           integer  ,
         l_assunto       char(80) ,
         l_docReferencia  decimal(10,0),
         l_tipo          char(1)
         
  let l_assunto = 'Resumo de emissão da OP: ', l_docReferencia using "<<<<<<<<<<"
  
  call ctx22g00_mail_anexo_corpo("CTB00G17", l_assunto, m_arq) returning l_ret
  
  if l_ret != 0 then
     if l_ret != 99 then
        display "Erro ao enviar email(CTB00G17) - ", m_arq
     else
        display "Nao ha email cadastrado para o modulo "
     end if
  end if
  
end function

#--------------------------------------------------------------------------------------------
function ctb00g17_opdesc(lr_param)
#--------------------------------------------------------------------------------------------
   define lr_param record                                                                    
           docReferencia    decimal(10,0) 
          ,docSAP           char(16)                                                            
          ,codempresa       char(5)                                                     
          ,codigo_retorno   smallint                                                     
          ,mensagem_retorno char(3000)                                                     
   end record                                                                     
                                                                                  
   define l_opgitm record                                                         
          atdsrvnum  like dbsmopgitm.atdsrvnum ,                                  
          atdsrvano  like dbsmopgitm.atdsrvano                                               
   end record                                                                                
                                                                                             
   define l_socopgsitcod  like dbsmopg.socopgsitcod,                                         
          l_succod        like dbsmopg.succod,                                               
          l_socopgobsseq  like dbsmopgobs.socopgobsseq,                                      
          l_obs           like dbsmopgobs.socopgobs                                          
                                                                                             
   define  l_stt           smallint
         , l_err           integer                                                           
         , l_msg           char(3000)
         , l_data          date
         , l_hora          datetime hour to minute
         , l_sqlcode       integer 
         , l_sqlerrd       integer                                                            
         , l_opdesc        like dbsmopg.dscpgtordnum                                          
         , l_opdessap      like dbsmopg.dscfinsispgtordnum                                    
         , l_opsap         like dbsmopg.finsispgtordnum   
         , l_flgop         like dbsmopg.trbpgtordpcmflg
         , l_opps          like dbsmopg.socopgnum  
                                                                                             
   initialize l_err                                                                          
            , l_msg                                                                          
            , l_socopgsitcod                                                                 
            , l_socopgobsseq                                                                 
            , l_succod                                                                       
            , l_obs                                                                          
            , l_data                                                                         
            , l_hora                                                                         
            , l_opdesc                                                                       
            , l_opdessap  to null                                                                                                                               
                                                                                             
   let l_stt = 7                                                                             
   let l_err = 0                                                                             
   let l_msg = null                                                                          


   if lr_param.codigo_retorno != 0 then                                                                       
      
      let lr_param.docReferencia  = lr_param.docReferencia  - 90000000
      display "Atualizar flag: ",lr_param.codigo_retorno
      update dbsmopg                                                                  
         set trbnaopgtordpcmflg = 'E',
              socopgsitcod = 6                                                  
      where socopgnum = lr_param.docReferencia 
       
      let lr_param.docReferencia  = lr_param.docReferencia  + 90000000
                                                                                  
      if sqlca.sqlcode != 0 or                                                        
         sqlca.sqlerrd[3] != 1                                                        
         then                                                                         
         let l_err = 1                                                                
         let l_msg = "OP PS - Erro na atualizacao da  Flag OP1: ", sqlca.sqlcode,      
                     "|", sqlca.sqlerrd[3] ,                                          
                     " OP: ", lr_param.docReferencia  
         return  l_err, l_msg                                
      end if
      display "Atualizei OP"
      #whenever error continue                                              
       
       let lr_param.docReferencia  = lr_param.docReferencia  - 90000000
       
       select socopgnum, finsispgtordnum, trbpgtordpcmflg  
        into l_opps   , l_opsap        , l_flgop                      
        from dbsmopg                                                                   
       where socopgnum = lr_param.docReferencia                                      
      
       let lr_param.docReferencia  = lr_param.docReferencia  + 90000000                                                                    
       
       display "Busquei informacoes"     
      #whenever error stop                         
      
      if sqlca.sqlcode != 0 then                                           
         let l_err = 1                                        
         let l_stt = 6                                                     
         let l_msg =  "OP PS - Erro na consulta da OP de Desconto: ",      
                      sqlca.sqlcode, " | OP: ", lr_param.docReferencia              
      end if                                                               
      
      if l_opsap is null and l_flgop = 'N' then 
        
         display "l_opsap: ",l_opsap
         display "l_flgop: ",l_flgop
         display ""
         return 0, "OK"
      end if 
      
      if l_flgop = 'S' then 
         display "Cancela a OP: ",l_opps
         display "OP sap normal: ",l_opsap
         display "flag da OP: ",l_flgop
         call ctb00g17_cancela_op_sap(l_opps
                                     ,8
                                     ,lr_param.codempresa
                                     ," ", " ")
               returning l_err, l_msg 
               
               #Enviar email 
               if l_err != 0 then
                  return l_err, l_msg 
               end if 
               
               #whenever error continue                                                       
               
               let lr_param.docReferencia  = lr_param.docReferencia  - 90000000
               
               update dbsmopg                                                                
                  set trbnaopgtordpcmflg   = 'N'                                                 
                     ,trbpgtordpcmflg      = 'N'
                     ,dscfinsispgtordnum   = null 
               where socopgnum = lr_param.docReferencia                                     
               
               let lr_param.docReferencia  = lr_param.docReferencia  + 90000000
               
               #whenever error stop                                                           
                                                                                             
               if sqlca.sqlcode != 0 or                                                      
                  sqlca.sqlerrd[3] != 1                                                      
                  then                                                                       
                  let l_err = 1                                                              
                  let l_msg = "OP PS - Erro na atualizacao da  Flag OP2: ", sqlca.sqlcode,    
                              "|", sqlca.sqlerrd[3] ,                                        
                              " OP: ", lr_param.docReferencia                                 
               end if                                                                        
        
        return 0, "OK"
      end if 
         
      #Retorna status para ok p/emissao, emitir novamente
      let l_stt = 6
      let l_err = 1
      let l_msg = lr_param.mensagem_retorno clipped, " OP: ",
                  lr_param.docReferencia using "<<<<<<<<<<"         
                  
      #Cancelamento da data de pagamento do servico
      #whenever error continue
         declare c_opgitm_sel04 cursor with hold for
         select i.atdsrvnum, i.atdsrvano
         from dbsmopg o, dbsmopgitm i, datmservico s
         where o.socopgnum = i.socopgnum
           and i.atdsrvnum = s.atdsrvnum
           and i.atdsrvano = s.atdsrvano
           and i.socopgnum = l_opps
         order by i.socopgitmnum
      #whenever error stop
      
      initialize l_opgitm.* to null
      
      foreach c_opgitm_sel04 into l_opgitm.*
         call ctd07g00_upd_srv_pgtdat('', l_opgitm.atdsrvnum, l_opgitm.atdsrvano)
              returning l_sqlcode, l_sqlerrd
      end foreach
      
      display "busquei servico e atualizei para ",l_stt,'|',l_opps
      
      # atualizar OP                                                                  
      #whenever error continue                                                         
      update dbsmopg                                                                  
         set socopgsitcod  = l_stt                                                    
      where socopgnum = l_opps                                         
      #whenever error stop 
      
      
      let l_msg = l_msg clipped, " passei na atualizacao2"
                                                                  
      if sqlca.sqlcode != 0 or                                                        
         sqlca.sqlerrd[3] != 1                                                        
         then                                                                         
         let l_err = 1                                                                
         let l_msg = "OP PS - Erro na atualizacao da OP(emissao): ", sqlca.sqlcode,   
                     "|", sqlca.sqlerrd[3] ,                                          
                     " OP: ", lr_param.docReferencia                                   
      end if
      
      #Email  #Fornax-Quantum 
      return l_err, l_msg                                                             
                                                                                                    
   else                                                                                                         
      #whenever error continue                                                                
      
      let lr_param.docReferencia  = lr_param.docReferencia  - 90000000

      update dbsmopg                                                                         
         set trbnaopgtordpcmflg  = 'S'
            ,dscfinsispgtordnum  = lr_param.docSAP
      where socopgnum = lr_param.docReferencia                                              
      
      let lr_param.docReferencia  = lr_param.docReferencia  + 90000000
      
      #whenever error stop                                                                    
                                                                                             
      if sqlca.sqlcode != 0 or                                                               
         sqlca.sqlerrd[3] != 1                                                               
         then                                                                                
         let l_err = 1                                                                       
         let l_msg = "OP PS - Erro na atualizacao da  Flag OP3: ", sqlca.sqlcode,          
                     "|", sqlca.sqlerrd[3] ,                                                 
                     " OP: ", lr_param.docReferencia                                        
      end if 
      
      #whenever error continue                                                        
      
      let lr_param.docReferencia  = lr_param.docReferencia  - 90000000
      
      select socopgnum, finsispgtordnum, trbpgtordpcmflg  
        into l_opps   , l_opsap        , l_flgop                      
        from dbsmopg                                                                   
       where socopgnum = lr_param.docReferencia                                      
      
      let lr_param.docReferencia  = lr_param.docReferencia  + 90000000
      
       #whenever error stop                                                            
                                                                                     
      if sqlca.sqlcode != 0 then                                                     
         let l_err = 1                                                 
         let l_stt = 6                                                               
         let l_msg =  "OP PS - Erro na consulta da OP de Desconto: ",       
                      sqlca.sqlcode, " | OP: ", lr_param.docReferencia                      
      end if                                                     
      
      if l_opsap is null and l_flgop = 'N' then
         display "l_opsap: ",l_opsap
         display "l_flgop: ",l_flgop
         return 0, "OK"
      end if
      
      if l_flgop = "E" then 
          display "Cancela a OP: ",lr_param.docReferencia
          display "OP sap normal: ",l_opsap
          display "flag da OP: ",l_flgop
      
         call ctb00g17_cancela_op_sap(lr_param.docReferencia
                                     ,8
                                     ,lr_param.codempresa
                                     ," ", " ")
               returning l_err, l_msg 
               
               #Enviar email 
               if l_err != 0 then     
                  return l_err, l_msg 
               end if                 
               
               #whenever error continue                                                       
               
               let lr_param.docReferencia  = lr_param.docReferencia  - 90000000
               
               update dbsmopg                                                                
                  set trbnaopgtordpcmflg   = 'N'                                                 
                     ,trbpgtordpcmflg      = 'N'
                     ,dscfinsispgtordnum   = null 
               where socopgnum = lr_param.docReferencia                                     
               
               let lr_param.docReferencia  = lr_param.docReferencia  + 90000000
               
               #whenever error stop                                                           
                                                                                             
               if sqlca.sqlcode != 0 or                                                      
                  sqlca.sqlerrd[3] != 1                                                      
                  then                                                                       
                  let l_err = 1                                                              
                  let l_msg = "OP PS - Erro na atualizacao da  Flag OP4: ", sqlca.sqlcode,    
                              "|", sqlca.sqlerrd[3] ,                                        
                              " OP: ", lr_param.docReferencia                                 
               end if                                                                        
        
        return 0, "OK"
      end if 
   
      #Buscar dados da OP
      #whenever error continue
      
      let lr_param.docReferencia  = lr_param.docReferencia  - 90000000
      
      select socopgsitcod, succod into l_socopgsitcod, l_succod
      from dbsmopg 
      where socopgnum = lr_param.docReferencia
      
      let lr_param.docReferencia  = lr_param.docReferencia  + 90000000
      
      #whenever error stop
      
      if sqlca.sqlcode != 0 then
         let l_err = 1
         let l_stt = 6
         let l_msg =  "OP PS - Erro na consulta ao docto referencia legado: ",
                      sqlca.sqlcode, " | OP: ", lr_param.docReferencia
      end if
      
      
      #Inserir Observacao da OP
      if l_stt = 7  then
         whenever error continue
         select max(socopgobsseq) into l_socopgobsseq 
         from dbsmopgobs
         where socopgnum = l_opps
         whenever error stop
         
         if l_socopgobsseq is null or
            l_socopgobsseq = ' ' or
            l_socopgobsseq = '' then
            let l_socopgobsseq = 0
         end if
         
         let l_socopgobsseq = l_socopgobsseq + 1
         
         let l_obs = "OP emitida no SAP, numero: ", 
                     lr_param.docSAP using "<<<<<<<<<<<<<<<<<<<" 
         
         display "l_opps        : ",l_opps         
         display "l_socopgobsseq: ",l_socopgobsseq 
         display "l_obs         : ",l_obs          
         display ""
         
         whenever error continue
         insert into dbsmopgobs(socopgnum, 
                                socopgobsseq, 
                                socopgobs)
                         values(l_opps, 
                                l_socopgobsseq, 
                                l_obs)
         
         if sqlca.sqlcode != 0 
            then
            let l_err = 1
            let l_stt = 6
            let l_msg = "OP PS - Erro na insercao da Observacao da OP SAP: ", sqlca.sqlcode,
                        " | OP: ", lr_param.docSAP
         end if
         
         whenever error stop
          
         
         # OP de desconto
         if l_opdessap  is not null or l_opdessap <> 0 then 
         
            let l_socopgobsseq = l_socopgobsseq + 1 
         
            let l_obs = "OP emitida SAP desconto : ",                                   
                        lr_param.docSAP using "<<<<<<<<<<<<<<<<<<<"                          
                                                                                         
            #whenever error continue                                                      
            insert into dbsmopgobs(socopgnum,                                            
                                   socopgobsseq,                                         
                                   socopgobs)                                            
                            values(l_opps,                                   
                                   l_socopgobsseq,                                       
                                   l_obs)                                                
            #whenever error stop                                                          
                                                                                         
            if sqlca.sqlcode != 0                                                        
               then                                                                      
               let l_err = 1                                                 
               let l_stt = 6                                                             
               let l_msg = "OP PS - Erro na insercao da Observacao da OP: ", sqlca.sqlcode,  
                           " | OP: ", lr_param.docReferencia                              
            end if                                                                       
         end if 
      end if
      
      #Atualizar fase da OP
      if l_stt = 7
         then
         let l_hora = current
         let l_data = today
         
         
         #whenever error continue
         insert into dbsmopgfas(socopgnum   , socopgfascod, socopgfasdat,
                                socopgfashor, funmat)
                        values (lr_param.docReferencia, 4, l_data,
                                l_hora, 999999)
         #whenever error stop
         
         if sqlca.sqlcode != 0 and sqlca.sqlcode != 268
            then
            let l_err = 1
            let l_stt = 6
            let l_msg = "OP PS - Erro na insercao da fase da OP1: ", 
                        sqlca.sqlcode using "<<<<<<<<", " | OP: ", lr_param.docReferencia
         end if
      end if
   
      # atualizar OP
      #whenever error continue
      
      display "busquei servico e atualizei para ",l_stt,'|',lr_param.docReferencia
      
      let lr_param.docReferencia  = lr_param.docReferencia  - 90000000
      
      update dbsmopg 
         set socopgsitcod  = l_stt
            ,dscfinsispgtordnum = lr_param.docSAP
      where socopgnum = lr_param.docReferencia 
      
      let lr_param.docReferencia  = lr_param.docReferencia  + 90000000
      
      #whenever error stop
      
      if sqlca.sqlcode != 0 or
         sqlca.sqlerrd[3] != 1
         then
         let l_err = 1
         let l_msg = "OP PS - Erro na atualizacao da OP(emissao): ", sqlca.sqlcode,
                     "|", sqlca.sqlerrd[3] ,
                     " OP: ", lr_param.docReferencia
      end if
      return l_err, l_msg
   end if                                                                                                       

end function 

#--------------------------------------------------------------------------------------------
function ctb00g17_op(lr_param)
#--------------------------------------------------------------------------------------------
   define lr_param record 
           docReferencia      decimal(10,0) 
          ,docSAP             char(16)       
          ,codempresa         char(5)       
          ,codigo_retorno     smallint      
          ,mensagem_retorno   char(3000)     
   end record 
   
   define l_opgitm record                             
          atdsrvnum  like dbsmopgitm.atdsrvnum ,      
          atdsrvano  like dbsmopgitm.atdsrvano        
   end record                                         
   
   define l_socopgsitcod  like dbsmopg.socopgsitcod,         
          l_succod        like dbsmopg.succod,               
          l_socopgobsseq  like dbsmopgobs.socopgobsseq,      
          l_obs           like dbsmopgobs.socopgobs          
                                                             
   define  l_stt           smallint                          
         , l_err           integer                           
         , l_msg           char(3000)                         
         , l_data          date                              
         , l_hora          datetime hour to minute
         , l_sqlcode       integer
         , l_sqlerrd       integer
         , l_opdesc        like dbsmopg.dscpgtordnum
         , l_opdessap      like dbsmopg.dscfinsispgtordnum     
         , l_flgopdes      like dbsmopg.trbnaopgtordpcmflg
         
   
   initialize l_err
            , l_msg
            , l_socopgsitcod
            , l_socopgobsseq
            , l_succod
            , l_obs
            , l_data
            , l_hora
            , l_opdesc  
            , l_opdessap
            , l_flgopdes  to null  

   let l_stt = 7     
   let l_err = 0     
   let l_msg = null                           
   
   if lr_param.codigo_retorno != 0 then
        display "OP: ", lr_param.docReferencia
        display "Codigo de erro SAP: ",lr_param.codigo_retorno
      #whenever error continue                                                         
         update dbsmopg                                                                  
            set trbpgtordpcmflg = "E",
                socopgsitcod = 6                                                   
         where socopgnum = lr_param.docReferencia                                       
                                                                                         
         if sqlca.sqlcode != 0 or                                                        
            sqlca.sqlerrd[3] != 1                                                       
            then                                                                         
            let l_err = 1                                                                
            let l_msg = "OP PS - Erro na atualizacao da  Flag OP5: ", sqlca.sqlcode,      
                        "|", sqlca.sqlerrd[3] ,                                          
                        " OP: ", lr_param.docReferencia  
            return  l_err, l_msg                                
         end if
      #whenever error stop                                                             
      
      #whenever error continue                                              
      select dscpgtordnum, dscfinsispgtordnum, trbnaopgtordpcmflg                    
        into l_opdesc    , l_opdessap        , l_flgopdes                  
        from dbsmopg                                                       
       where socopgnum = lr_param.docReferencia                             
       #whenever error stop 
                                                                           
      if sqlca.sqlcode != 0 then                                           
         let l_err = 1                                         
         let l_stt = 6                                                     
         let l_msg =  "OP PS - Erro na consulta da OP de Desconto: ",      
                      sqlca.sqlcode, " | OP: ", lr_param.docReferencia              
      end if                                                               
      
       if l_opdesc is not null and l_opdesc <> 0 and l_flgopdes = 'N' then     
         display "l_opdesc1: ",l_opdesc
         display "l_opdesc1: ",l_opdesc
         display "l_flgopdes1: ",l_flgopdes
         display ""
         return 0, "OK"
      end if   
      
      if l_flgopdes = 'S' then
      
         display "Cancela a OP: ",l_opdesc
          display "OP sap desconto: ",l_opdessap
          display "flag da OP desc: ",l_flgopdes

          call ctb00g17_cancela_op_sap(l_opdesc                                  
                                     ,8                                                      
                                     ,lr_param.codempresa                                    
                                     ," ", " ")                                                   
               returning l_err, l_msg                                                           
                
                if l_err != 0 then     
                  return l_err, l_msg 
               end if
                                                                                             
            #whenever error continue                                                       
            update dbsmopg                                                                
               set trbnaopgtordpcmflg  = 'N'                                                 
                  ,trbpgtordpcmflg     = 'N'                                                 
                  ,dscfinsispgtordnum  = null                                                
            where socopgnum = lr_param.docReferencia                                     
            #whenever error stop                                                           
                                                                                          
            if sqlca.sqlcode != 0 or                                                      
               sqlca.sqlerrd[3] != 1                                                      
               then                                                                       
               let l_err = 1                                                              
               let l_msg = "OP PS - Erro na atualizacao da  Flag OP6: ", sqlca.sqlcode,    
                           "|", sqlca.sqlerrd[3] ,                                        
                           " OP: ", lr_param.docReferencia                                 
            end if                                                                        
      end if                                                                                 
   
      #Retorna status para ok p/emissao, emitir novamente
      let l_stt = 6
      let l_err = 1
      let l_msg = lr_param.mensagem_retorno clipped, " OP: ",
                  lr_param.docReferencia using "<<<<<<<<<<"         
                  
      #Cancelamento da data de pagamento do servico
      #whenever error continue
         declare c_opgitm_sel03 cursor with hold for
         select i.atdsrvnum, i.atdsrvano
         from dbsmopg o, dbsmopgitm i, datmservico s
         where o.socopgnum = i.socopgnum
           and i.atdsrvnum = s.atdsrvnum
           and i.atdsrvano = s.atdsrvano
           and i.socopgnum = lr_param.docReferencia
         order by i.socopgitmnum
      #whenever error stop
      
      initialize l_opgitm.* to null
      
      foreach c_opgitm_sel03 into l_opgitm.*
         call ctd07g00_upd_srv_pgtdat('', l_opgitm.atdsrvnum, l_opgitm.atdsrvano)
              returning l_sqlcode, l_sqlerrd
      end foreach
      
      display "busquei servico e atualizei para ",l_stt,'|',lr_param.docReferencia
       
      # atualizar OP                                                                  
      #whenever error continue                                                         
      update dbsmopg                                                                  
         set socopgsitcod  = l_stt                                                    
      where socopgnum = lr_param.docReferencia                                         
      #whenever error stop                                                             
      
       let l_msg = l_msg clipped, " passei na atualizacao: ",sqlca.sqlcode, " ", sqlca.sqlerrd[3]
      
      if sqlca.sqlcode != 0 or                                                        
         sqlca.sqlerrd[3] != 1                                                        
         then 
          let l_msg = l_msg clipped, " passei"                                                                  
         let l_err = 1                                                                
         let l_msg = "OP PS - Erro na atualizacao da OP(emissao): ", sqlca.sqlcode,   
                     "|", sqlca.sqlerrd[3] ,                                          
                     " OP: ", lr_param.docReferencia                                   
      end if
      display "l_msg: ",l_msg clipped
      #Email  #Fornax-Quantum
      return l_err, l_msg                                                             
   else
      #whenever error continue                                                                
         update dbsmopg                                                                         
            set trbpgtordpcmflg  = 'S'
               ,finsispgtordnum  = lr_param.docSAP
         where socopgnum = lr_param.docReferencia                                              
                                                                                                
         if sqlca.sqlcode != 0 or                                                               
            sqlca.sqlerrd[3] != 1                                                              
            then                                                                                
            let l_err = 1                                                                       
            let l_msg = "OP PS - Erro na atualizacao da  Flag OP7: ", sqlca.sqlcode,          
                        "|", sqlca.sqlerrd[3] ,                                                 
                        " OP: ", lr_param.docReferencia                                        
         end if 
         display "msg primeiro: ",l_msg clipped
      #whenever error stop                                                                    
       
      #whenever error continue                                                        
      select dscpgtordnum, dscfinsispgtordnum, trbnaopgtordpcmflg 
        into l_opdesc    , l_opdessap        , l_flgopdes                      
        from dbsmopg                                                                   
       where socopgnum = lr_param.docReferencia                                      
       #whenever error stop                                                            
                                                                                     
      if sqlca.sqlcode != 0 then                                                     
         let l_err = 1                                                  
         let l_stt = 6                                                               
         let l_msg =  "OP PS - Erro na consulta da OP de Desconto: ",       
                      sqlca.sqlcode, " | OP: ", lr_param.docReferencia                      
      end if                                                     
      display "l_msg2: ",l_msg clipped
      if l_opdesc is not null and l_opdesc <> 0 and l_flgopdes = 'N' then 
         display "l_opdesc2: ",l_opdesc
         display "l_flgopdes2: ",l_flgopdes
         display ""
         return 0, "OK"
      end if 
      
      if l_flgopdes = "E" then  
      
        display "Cancela a OP1: ",lr_param.docReferencia
        display "OP sap desconto: ",l_opdessap
        display "flag da OP desc: ",l_flgopdes
      
      
         call ctb00g17_cancela_op_sap(lr_param.docReferencia
                                     ,8
                                     ,lr_param.codempresa
                                     ," ", " ")
               returning l_err, l_msg 
               
               #Enviar email 
               if l_err != 0 then     
                  return l_err, l_msg 
               end if
               
               #whenever error continue                                                       
               update dbsmopg                                                                
                  set trbnaopgtordpcmflg   = 'N'                                                 
                     ,trbpgtordpcmflg      = 'N'
                     ,finsispgtordnum  = null 
               where socopgnum = lr_param.docReferencia                                     
               #whenever error stop                                                           
                                                                                             
               if sqlca.sqlcode != 0 or                                                      
                  sqlca.sqlerrd[3] != 1                                                      
                  then                                                                       
                  let l_err = 1                                                              
                  let l_msg = "OP PS - Erro na atualizacao da  Flag OP8: ", sqlca.sqlcode,    
                              "|", sqlca.sqlerrd[3] ,                                        
                              " OP: ", lr_param.docReferencia                                 
               end if                                                                        
        
        return 0, "OK"
      end if 
   
      #Buscar dados da OP
      #whenever error continue
      select socopgsitcod, succod into l_socopgsitcod, l_succod
      from dbsmopg 
      where socopgnum = lr_param.docReferencia
      #whenever error stop
      
      if sqlca.sqlcode != 0 then
         let l_err = 1
         let l_stt = 6
         let l_msg =  "OP PS - Erro na consulta ao docto referencia legado: ",
                      sqlca.sqlcode, " | OP: ", lr_param.docReferencia
      end if
      
      #Inserir Observacao da OP  
      display "l_stt: ",l_stt
      if l_stt = 7  then
         #whenever error continue
         select max(socopgobsseq) into l_socopgobsseq 
         from dbsmopgobs
         where socopgnum = lr_param.docReferencia
         #whenever error stop
         
         if l_socopgobsseq is null or
            l_socopgobsseq = ' ' or
            l_socopgobsseq = '' then
            let l_socopgobsseq = 0
         end if
         
         let l_socopgobsseq = l_socopgobsseq + 1
         
         let l_obs = "OP emitida no SAP,numero:", 
                     lr_param.docSAP using "<<<<<<<<<<<<<<<<<<<<<" 
         
         whenever error continue
         insert into dbsmopgobs(socopgnum, 
                                socopgobsseq, 
                                socopgobs)
                         values(lr_param.docReferencia, 
                                l_socopgobsseq, 
                                l_obs)
         
         
         if sqlca.sqlcode != 0 
            then
            let l_err = 1
            let l_stt = 6
            let l_msg = "OP PS - Erro na insercao da Observacao da OP SAP: ", sqlca.sqlcode,
                        " | OP: ", lr_param.docSAP
         end if
         
         whenever error stop 
         
         # OP de desconto
         if l_opdessap  is not null or l_opdessap <> 0 then
         
            let l_socopgobsseq = l_socopgobsseq + 1 
         
            let l_obs = "OP emitida SAP desconto:",                                   
                        l_opdessap using "<<<<<<<<<<<<<<<<<<<<<"                        
                                                                                         
            #whenever error continue                                                      
            insert into dbsmopgobs(socopgnum,                                            
                                   socopgobsseq,                                         
                                   socopgobs)                                            
                            values(lr_param.docReferencia,                                   
                                   l_socopgobsseq,                                       
                                   l_obs)                                                
            #whenever error stop                                                          
                                                                                         
            if sqlca.sqlcode != 0                                                     
               then                                                                      
               let l_err = 1                                                
               let l_stt = 6                                                             
               let l_msg = "OP PS - Erro na insercao da Observacao da OP: ", sqlca.sqlcode,  
                           " | OP: ", lr_param.docReferencia                              
            end if                                                                       
         end if 
      end if
      display "l_msg3: ",l_msg clipped
      #Atualizar fase da OP
      if l_stt = 7
         then
         let l_hora = current
         let l_data = today
         
         #whenever error continue
         insert into dbsmopgfas(socopgnum   , socopgfascod, socopgfasdat,
                                socopgfashor, funmat)
                        values (lr_param.docReferencia, 4, l_data,
                                l_hora, 999999)
         #whenever error stop
         
         if sqlca.sqlcode != 0 and sqlca.sqlcode != 268 
            then
            let l_err = 1
            let l_stt = 6
            let l_msg = "OP PS - Erro na insercao da fase da OP2: ", 
                        sqlca.sqlcode using "<<<<<<<<", " | OP: ", lr_param.docReferencia
         end if
      end if
        
      display "busquei servico e atualizei para ",l_stt,'|',lr_param.docReferencia  
        
      # atualizar OP
      #whenever error continue
      update dbsmopg 
         set socopgsitcod  = l_stt
            ,finsispgtordnum = lr_param.docSAP
      where socopgnum = lr_param.docReferencia 
      #whenever error stop
      
      if sqlca.sqlcode != 0 or
         sqlca.sqlerrd[3] != 1
         then
         let l_err = 1
         let l_msg = "OP PS - Erro na atualizacao da OP(emissao): ", sqlca.sqlcode,
                     "|", sqlca.sqlerrd[3] ,
                     " OP: ", lr_param.docReferencia
      end if
      display "l_msg: ",l_msg clipped
      return l_err, l_msg
   end if 

end function  



#--------------------------------------------------------------------------------------------
function ctb00g17_log_cancelamento()
#--------------------------------------------------------------------------------------------


display "Entrada - OP"                                                     
display "gr_010_request.flag_tributavel ",gr_010_request.flag_tributavel   
display "gr_010_request.tipo_documento  ",gr_010_request.tipo_documento    
display "gr_010_request.empresa         ",gr_010_request.empresa           
display "gr_010_request.num_doc_refer   ",gr_010_request.num_doc_refer     
display "gr_010_request.motivo_cancel   ",gr_010_request.motivo_cancel     
display "gr_010_request.matricula       ",gr_010_request.matricula         
display ""   
display "Retorno da global header - OP"                                                                                        
display "gr_aci_res_head.codigo_retorno ",gr_aci_res_head.codigo_retorno  # Codigo de retorno da integracao.               
display "gr_aci_res_head.mensagem       ",gr_aci_res_head.mensagem        # Mensagem de retorno da integracao.             
display "gr_aci_res_head.tipo_erro      ",gr_aci_res_head.tipo_erro       # Tipo de erro, caso ocorra.                     
display "gr_aci_res_head.track_number   ",gr_aci_res_head.track_number    # Numero de rastreio para integr assincronas.    
             


end function
