#-----------------------------------------------------------------------------#
# Sistema....: Porto Socorro                                                  #
# Modulo.....: ctx15g02                                                       #
# Analista Resp.: Beatriz Araujo                                              #
# PSI......: Apura valores para servicos AUTO                                 #
# --------------------------------------------------------------------------- #
# Desenvolvimento: Beatriz Araujo                                             #
# Liberacao...: 01/08/2011                                                    #
# --------------------------------------------------------------------------- #
#                                 Alteracoes                                  #
# --------------------------------------------------------------------------- #
# Data        Autor           Origem     Alteracao                            #
# ----------  --------------  ---------- -------------------------------------#
#-----------------------------------------------------------------------------#

 database porto
 
 define m_prepare smallint

#---------------------------------------------------------------
 function ctx15g02_prepare()
#---------------------------------------------------------------
 define sql_comando  char(600)
   
   let m_prepare = true           
        
   let sql_comando = "select atdprscod,   ",
                     "       ciaempcod,   ",
                     "       atdsrvorg,   ",
                     "       asitipcod,   ",
                     "       atddat       ",
                     "  from datmservico  ",
                     " where atdsrvnum = ?",
                     "   and atdsrvano = ?"   
  prepare p_ctx15g02_001 from sql_comando                     
  declare c_ctx15g02_001 cursor for p_ctx15g02_001 
  
  
  ### // Seleciona valores iniciais dos serviços //      
  let sql_comando = " select cpodes                  ",                  
                    "   from iddkdominio             ",   
                    "  where cponom = 'valor_padrao' ",   
                    "    and cpocod = ?              "
  prepare p_ctx15g02_002 from sql_comando                             
  declare c_ctx15g02_002 cursor for p_ctx15g02_002 
  
  
  let sql_comando = "select vclcoddig,",
                     "      socvclcod",
                     "  from datmservico  ",
                     " where atdsrvnum = ?",
                     "   and atdsrvano = ?"   
  prepare p_ctx15g02_003 from sql_comando                     
  declare c_ctx15g02_003 cursor for p_ctx15g02_003
  
  
  
   ### // Seleciona o grupo tarifário do veículo acionado //      
    let sql_comando = " select vclcoddig "                               
               ,"  from datkveiculo "                              
               ," where socvclcod = ? "                           
    prepare p_ctx15g02_004 from sql_comando                                
    declare c_ctx15g02_004 cursor for p_ctx15g02_004                   
                                                                   
    ### // Compara o grupo tarifário do veículo acionado //        
    let sql_comando = " select socgtfcod "                               
               ,"  from  dbsrvclgtf "                              
               ," where vclcoddig = ? "                            
    prepare p_ctx15g02_005 from sql_comando                                
    declare c_ctx15g02_005 cursor for p_ctx15g02_005                   
                                                                   
    ### // Verifica o preço de tabela da faixa 1=valor inicial //  
    let sql_comando = " select socgtfcstvlr "                            
               ,"  from  dbstgtfcst "                              
               ," where soctrfvignum = ? "                         
               ,"   and socgtfcod    = ? "                         
               ,"   and soccstcod    = 1   "                        
    prepare p_ctx15g02_006 from sql_comando                                
    declare c_ctx15g02_006 cursor for p_ctx15g02_006                   

                  
end function




#---------------------------------------------------------------
 function ctx15g02_vlrauto(param)
#---------------------------------------------------------------
 define param       record
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano
 end record

 define lr_servico record
    atdprscod    like datmservico.atdprscod,  
    ciaempcod    like datmservico.ciaempcod,   
    atdsrvorg    like datmservico.atdsrvorg,    
    asitipcod    like datmservico.asitipcod,
    atddat       like datmservico.atddat
 end record
 
 
 define lr_prestador record
    soctrfcod       like dpaksocor.soctrfcod,
    soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum
 end record
 
 define lr_retorno record
     err    smallint,
     msgerr char(200),
     valor  decimal(16,2)
 end record
 
if m_prepare is null or
   m_prepare <> true then
    call ctx15g02_prepare()
end if 
 
 whenever error continue
    open c_ctx15g02_001 using param.atdsrvnum,param.atdsrvano
    
    fetch c_ctx15g02_001 into lr_servico.atdprscod,
                              lr_servico.ciaempcod,
                              lr_servico.atdsrvorg,
                              lr_servico.asitipcod,
                              lr_servico.atddat
 whenever error stop
 
 ### // Seleciona o código da tabela de vigência //
    call ctc00m15_rettrfvig(lr_servico.atdprscod,
                            lr_servico.ciaempcod,
                            lr_servico.atdsrvorg,
                            lr_servico.asitipcod,
                            lr_servico.atddat)
                            
                            
         returning lr_prestador.soctrfcod,
                   lr_prestador.soctrfvignum,
                   lr_retorno.err,
                   lr_retorno.msgerr
        display "lr_retorno.err: ",lr_retorno.err
    
    case lr_retorno.err
    
     when 0 
        display "lr_servico.atdsrvorg: ",lr_servico.atdsrvorg
        call ctx15g02_valor(param.atdsrvnum,
                            param.atdsrvano,
                            lr_prestador.soctrfvignum,
                            lr_servico.atddat,
                            lr_servico.atdsrvorg)
             returning lr_retorno.err,    
                       lr_retorno.msgerr, 
                       lr_retorno.valor 
                         
     when notfound
        call ctx15g02_valor_padrao(lr_servico.atdsrvorg,1.99)   
             returning lr_retorno.err,   
                       lr_retorno.msgerr,
                       lr_retorno.valor  
      
     otherwise
        let lr_retorno.valor = 0
        
        return lr_retorno.err,
               lr_retorno.msgerr,
               lr_retorno.valor
    
    end case
  
  return lr_retorno.err,     
         lr_retorno.msgerr,  
         lr_retorno.valor    
   
end function


#---------------------------------------------------------------
 function ctx15g02_valor_padrao(param)
#---------------------------------------------------------------
 define param  record
    atdsrvorg     like datmservico.atdsrvorg,
    vpadrao       decimal(16,2)
 end record
 
 define lr_retorno record
     err    smallint,
     msgerr char(200),
     valor  decimal(16,2)
 end record
  
  define l_valor decimal(16,2)
  
 if m_prepare is null or
   m_prepare <> true then
    call ctx15g02_prepare()
end if 
  
      display "param.atdsrvorg4: ",param.atdsrvorg 
 open c_ctx15g02_002 using param.atdsrvorg
 
 whenever error continue 
    fetch c_ctx15g02_002 into l_valor
    
    if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> 100 then
            let lr_retorno.valor = 0
            let lr_retorno.err  = sqlca.sqlcode  
            let lr_retorno.msgerr = "Erro(",sqlca.sqlcode clipped,")ao consultar valor padrao(ctx15g02) origem: ",param.atdsrvorg
            return lr_retorno.err   ,
                   lr_retorno.msgerr,
                   lr_retorno.valor 
        else
            let lr_retorno.valor = param.vpadrao        
            let lr_retorno.err  = 0  
            let lr_retorno.msgerr = "Erro(",sqlca.sqlcode clipped,")ao consultar valor padrao(ctx15g02) origem: ",param.atdsrvorg
            return lr_retorno.err   ,
                   lr_retorno.msgerr,
                   lr_retorno.valor 
        end if
    end if
 whenever error stop      
 
 let lr_retorno.valor = l_valor
 let lr_retorno.err  = 0  
 let lr_retorno.msgerr = " "
 return lr_retorno.err   ,
        lr_retorno.msgerr,
        lr_retorno.valor 
 
end function


#---------------------------------------------------------------
 function ctx15g02_valor(param)
#---------------------------------------------------------------
 define param       record
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum,
    atddat          like datmservico.atddat,
    atdsrvorg       like datmservico.atdsrvorg
 end record
 
 
 define lr_veiculo record
    vclcoddig     like datmservico.vclcoddig,
    vclcoddig_acn like datmservico.vclcoddig,
    socgtfcod     like dbstgtfcst.socgtfcod,  
    socgtfcod_acn like dbstgtfcst.socgtfcod,
    socvclcod     like datmservico.socvclcod,
    vlrprm        like dbsmopgitm.socopgitmvlr
 end record
 
 define lr_retorno record
     err    smallint,
     msgerr char(200),
     valor  decimal(16,2)
 end record
 
 define l_valor          decimal(16,2)
 
 whenever error continue
    open c_ctx15g02_003 using param.atdsrvnum, param.atdsrvano 
    fetch c_ctx15g02_003 into lr_veiculo.vclcoddig,lr_veiculo.socvclcod
 whenever error continue
 
 ### // Verifica o grupo tarifário do veículo //
 call ctc00m15_retsocgtfcod(lr_veiculo.vclcoddig)
      returning lr_veiculo.socgtfcod, 
                lr_retorno.err, 
                lr_retorno.msgerr  

 ### // Se não encontrou, assume grupo 1=Passeio Nacional //
 if lr_retorno.err <> 0 then
     let lr_veiculo.socgtfcod = 1
 end if

 ### // Verifica o grupo tarifário do veículo acionado //
 whenever error continue
   open c_ctx15g02_004 using lr_veiculo.socvclcod
   fetch c_ctx15g02_004 into lr_veiculo.vclcoddig_acn
 whenever error stop
 if sqlca.sqlcode < 0 then
     
     let lr_retorno.valor  = 0
     let lr_retorno.err    = sqlca.sqlcode
     let lr_retorno.msgerr = "Erro ao buscar o gurpo tarifario do veiculo acionado(ctx15g02_valor): ",lr_veiculo.socvclcod

     return lr_retorno.err,   
            lr_retorno.msgerr,
            lr_retorno.valor 
            
 end if

 if lr_veiculo.vclcoddig_acn is not null then
     
     # Busca a categoria tariafaria do veiculo acionado
     call ctc00m15_retsocgtfcod(lr_veiculo.vclcoddig_acn)
         returning lr_veiculo.socgtfcod_acn,  
                   lr_retorno.err, 
                   lr_retorno.msgerr 

     if lr_retorno.err <> 0 then
         let lr_retorno.valor  = 0
         let lr_retorno.err    = sqlca.sqlcode
         let lr_retorno.msgerr = "Erro(",sqlca.sqlcode clipped clipped,")ctx15g02_valor: ",lr_retorno.msgerr clipped
        
         return lr_retorno.err,   
                lr_retorno.msgerr,
                lr_retorno.valor 
     end if

     if lr_veiculo.socgtfcod = 5 and
        lr_veiculo.socgtfcod > lr_veiculo.socgtfcod_acn then
         let lr_veiculo.socgtfcod = lr_veiculo.socgtfcod_acn
         if  lr_veiculo.socgtfcod is null then
             let lr_veiculo.socgtfcod = 1
         end if
     end if
 end if
 
  ### // Verifica o preço de tabela da faixa 1=valor inicial //
  call ctc00m15_retvlrvig(param.soctrfvignum,
                          lr_veiculo.socgtfcod,
                          1) #Custo Faixa 1 = Valor Inicial
       returning l_valor, 
                 lr_retorno.err,  
 	               lr_retorno.msgerr
 	               
  call ctd00g00_vlrprmpgm(param.atdsrvnum, 
                          param.atdsrvano,
                          "INI")
   returning lr_veiculo.vlrprm,
             lr_retorno.err  
   
  let l_valor = ctd00g00_compvlr(l_valor, lr_veiculo.vlrprm)
 
  if  lr_retorno.err <> 0 then
      if lr_retorno.err <> 100 then
         let lr_retorno.valor  = l_valor
         let lr_retorno.err    = sqlca.sqlcode
         let lr_retorno.msgerr = "Erro(",sqlca.sqlcode clipped,") provisionado valor(",l_valor,"): ",lr_retorno.msgerr clipped
         
         return lr_retorno.err,   
                lr_retorno.msgerr,
                lr_retorno.valor
      else
         let l_valor = null
      end if            
  end if
 
 if l_valor is null then
         display "param.atdsrvorg2: ",param.atdsrvorg
     call ctx15g02_valor_padrao(param.atdsrvorg,53.00)   
      returning lr_retorno.err,   
                lr_retorno.msgerr,
                lr_retorno.valor 
                
      return lr_retorno.err,   
             lr_retorno.msgerr,
             lr_retorno.valor 
      
 end if

  let lr_retorno.valor  = l_valor
  let lr_retorno.err    = 0
  let lr_retorno.msgerr = " "
  
  return lr_retorno.err,   
         lr_retorno.msgerr,
         lr_retorno.valor 
 
 
end function