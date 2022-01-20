#------------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                  #
#..............................................................................#
# Sistema.......: Porto Socorro                                                #
# Modulo........: ctx35g00                                                     #
# Analista Resp.: Beatriz Araujo                                               #
# PSI...........: PSI-2012-19571/PR                                            #
# Objetivo......: Inteface com os produtos para cadstrar as informacoes        #
#                 necessaria para a parametrizacao do ramo contabil circular395#
#..............................................................................#
# Desenvolvimento: Beatriz Araujo                                              #
# Liberacao......: 16/01/2012                                                  #
#..............................................................................#
#                                                                              #
#                        * * * Alteracoes * * *                                #
#                                                                              #
# Data       Autor Fabrica PSI       Alteracao                                 #
# --------   ------------- ------    ------------------------------------------#
#                                                                              #
#------------------------------------------------------------------------------#
database porto


globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"

define m_ctx35g00_prep smallint


define m_hostname   char(12)                                
define m_server     like ibpkdbspace.srvnom #Saymon ambnovo 

#-------------------------#
function ctx35g00_prepare()
#-------------------------#

  define l_sql char(300)
  
  
  let m_server   = fun_dba_servidor("CT24HS")
  let m_hostname = "porto@", m_server clipped , ":"
  
 
  
   let l_sql = "Select cpodes     ",                  
               "  from ",m_hostname clipped,"iddkdominio",                  
               " where cponom = ?",                   
               "   and cpocod =? "                    
   prepare pctx35g00001 from l_sql                 
   declare cctx35g00001 cursor for pctx35g00001 
   
   
 let l_sql =  '  SELECT itaasiplntipcod       '
             ,'       , itaasiplntipdes       '
             ,'    FROM ',m_hostname clipped,'datkasttip      '
             ,'  WHERE itaasiplntipcod IN (2,9,3)' # Apenas SERVICO SEGURADO, SERVICO TERCEIRO  E CORTESIA
             ,'  ORDER BY itaasiplntipcod     '
 prepare pctx35g00002 from l_sql
 declare cctx35g00002 cursor for pctx35g00002
 
 let l_sql =  '  SELECT itaasiplntipdes '
             ,'    FROM ',m_hostname clipped,'datkasttip      '
             ,'  WHERE itaasiplntipcod =? '
             ,'    AND itaasiplntipcod IN (2,9,3)'
 prepare pctx35g00003 from l_sql
 declare cctx35g00003 cursor for pctx35g00003
 
 
  let m_ctx35g00_prep = true

end function

#------------------------------------------------------------
 function ctx35g00_bem_atendido(param)
#------------------------------------------------------------

 define param record
    bemcod like datkdcrorg.bemcod
 end record


 define lr_ctx35g00 record    
    bemcod like datkdcrorg.bemcod,
    bemdes  char(50)
 end record                
 
 define l_cponom like iddkdominio.cponom                                   
 
 if m_ctx35g00_prep is null or
    m_ctx35g00_prep <> true then
    call ctx35g00_prepare()
 end if
 
 
 initialize lr_ctx35g00.*  to null
 
 # coloca o nome do dominio para o bem atendido
 let l_cponom = "bemAtendido"  
    
 if param.bemcod is null or param.bemcod = '' or param.bemcod = 0 then
    
    error "Escolha um Opcao para cadsatro!"
    
    call ctn36c00("Bem atendido do Servico", "bemAtendido")
                   returning  lr_ctx35g00.bemcod
    
    # Busca a descricao do dominio
    open cctx35g00001  using l_cponom,lr_ctx35g00.bemcod
    fetch cctx35g00001 into lr_ctx35g00.bemdes 
    
      if sqlca.sqlcode  =  notfound   then
          close cctx35g00001
      
         error " Bem atendido nao cadastrado!"
         
         call ctn36c00("Bem atendido do Servico", "bemAtendido")
              returning  lr_ctx35g00.bemcod
              
         # Busca a descricao do dominio     
         open cctx35g00001  using l_cponom,lr_ctx35g00.bemcod
         fetch cctx35g00001 into lr_ctx35g00.bemdes
         close cctx35g00001
      end if
     close cctx35g00001
 else
    # Busca a descricao do dominio
    
    let lr_ctx35g00.bemcod = param.bemcod    
    
    open cctx35g00001  using l_cponom,lr_ctx35g00.bemcod
    fetch cctx35g00001 into lr_ctx35g00.bemdes 
    
       if sqlca.sqlcode  =  notfound   then
          
           close cctx35g00001
         
          error " Bem atendido nao cadastrado!"
          
          call ctn36c00("Bem atendido do Servico", "bemAtendido")
               returning  lr_ctx35g00.bemcod
               
          # Busca a descricao do dominio
          open cctx35g00001  using l_cponom,lr_ctx35g00.bemcod
          fetch cctx35g00001 into lr_ctx35g00.bemdes 
          close cctx35g00001
          
       end if
    close cctx35g00001
    
 end if 
 
  return lr_ctx35g00.*
  
 end function  ###  ctx35g00_bem_atendido
 
 
 
#------------------------------------------------------------
 function ctx35g00_srvdcrdes(param)
#------------------------------------------------------------

 define param record
    srvdcrcod like datkdcrorg.srvdcrcod
 end record


 define lr_ctx35g00 record    
    srvdcrcod like datkdcrorg.srvdcrcod,
    srvdcrdes  char(50)
 end record                
 
 define l_cponom like iddkdominio.cponom                                   
 
  if m_ctx35g00_prep is null or
    m_ctx35g00_prep <> true then
    call ctx35g00_prepare()
 end if
 
 
 initialize lr_ctx35g00.*  to null
 
 # coloca o nome do dominio para a Decorrencia
 let l_cponom = "decservico"  
    
 if param.srvdcrcod is null or param.srvdcrcod = ' ' or param.srvdcrcod = 0 then
    
    error "Escolha um Opcao para cadsatro!"
    
    call ctn36c00("Decorrencia do Servico", "decservico")
                   returning  lr_ctx35g00.srvdcrcod
    
    # Busca a descricao do dominio
    open cctx35g00001  using l_cponom,lr_ctx35g00.srvdcrcod
    fetch cctx35g00001 into lr_ctx35g00.srvdcrdes 
    
      if sqlca.sqlcode  =  notfound   then
         close cctx35g00001
         error "Decorrencia do Servico nao cadastrada1!" sleep 2
         
         call ctn36c00("Decorrencia do Servico", "decservico")
              returning  lr_ctx35g00.srvdcrcod
              
         # Busca a descricao do dominio     
         open cctx35g00001  using l_cponom,lr_ctx35g00.srvdcrcod
         fetch cctx35g00001 into lr_ctx35g00.srvdcrdes
         close cctx35g00001
         
      end if
    close cctx35g00001
    
 else
    # Busca a descricao do dominio
    
    let lr_ctx35g00.srvdcrcod = param.srvdcrcod    
    
    open cctx35g00001  using l_cponom,lr_ctx35g00.srvdcrcod
    fetch cctx35g00001 into lr_ctx35g00.srvdcrdes 
    
    
      if sqlca.sqlcode  =  notfound   then
         close cctx35g00001
         error "Decorrencia do Servico nao cadastrada!" sleep 2
         
         call ctn36c00("Decorrencia do Servico", "decservico")
              returning  lr_ctx35g00.srvdcrcod
              
         # Busca a descricao do dominio
         open cctx35g00001  using l_cponom,lr_ctx35g00.srvdcrcod
         fetch cctx35g00001 into lr_ctx35g00.srvdcrdes 
         close cctx35g00001
         
      end if
    close cctx35g00001
 end if 
 
 return lr_ctx35g00.*
 
 end function  ###  ctx35g00_srvdcrdes
 
 
 #------------------------------------------------------------
 function ctx35g00_quemsrvpst(param)
#------------------------------------------------------------

 define param record
    itaasiplntipcod like datkasttip.itaasiplntipcod
 end record


 define lr_ctx35g00 record    
    itaasiplntipcod  like datkasttip.itaasiplntipcod,
    itaasiplntipdes  like datkasttip.itaasiplntipdes
 end record                
 
 if m_ctx35g00_prep is null or
    m_ctx35g00_prep <> true then
    call ctx35g00_prepare()
 end if
 
 
 initialize lr_ctx35g00.*  to null
 
 if param.itaasiplntipcod is null or param.itaasiplntipcod = ' ' or param.itaasiplntipcod = 0 then
    
    error "Escolha um Opcao para cadastro!"
    
    call ctx35g00_popup()
      returning  lr_ctx35g00.itaasiplntipcod,
                 lr_ctx35g00.itaasiplntipdes
      
    
    if lr_ctx35g00.itaasiplntipcod is null or 
       lr_ctx35g00.itaasiplntipcod = '' or 
       lr_ctx35g00.itaasiplntipcod = 0  then
    
       error "Para quem o servico foi prestado nao cadastrada1!"
       
       call ctx35g00_popup()
       returning  lr_ctx35g00.itaasiplntipcod,
                  lr_ctx35g00.itaasiplntipdes
       
       
    end if
 else
    
    let lr_ctx35g00.itaasiplntipcod = param.itaasiplntipcod
    # Busca a descricao do dominio
    open cctx35g00003  using lr_ctx35g00.itaasiplntipcod
    fetch cctx35g00003 into lr_ctx35g00.itaasiplntipdes 
    if sqlca.sqlcode  =  notfound   then
    
       error "Para quem o servico foi prestado nao cadastrada!"
       
       call ctx35g00_popup()
       returning  lr_ctx35g00.itaasiplntipcod,
                  lr_ctx35g00.itaasiplntipdes
                  
    close cctx35g00003
    end if
 end if 
 
 return lr_ctx35g00.*
 
 end function  ###  ctx35g00_quemsrvpst
 
 
#========================================================================
 function ctx35g00_popup() #tipo_assunto
#========================================================================
 define a_ctx35g00 array[500] of record
        itaasiplntipcod     like datkasttip.itaasiplntipcod
       ,itaasiplntipdes     like datkasttip.itaasiplntipdes
 end record
 
 define l_pi    smallint
 define arr_pop smallint

 if m_ctx35g00_prep is null or
    m_ctx35g00_prep <> true then
    call ctx35g00_prepare()
 end if
 
 initialize a_ctx35g00 to null
 
 
 let l_pi = 1
 
   whenever error continue
     open cctx35g00002
   whenever error stop
  
   foreach cctx35g00002 into a_ctx35g00[l_pi].itaasiplntipcod
                           , a_ctx35g00[l_pi].itaasiplntipdes
     let l_pi = l_pi + 1 
   end foreach
  
  open window w_ctx35g00 at 9,17 with form "ctx35g00" attribute(form line first, border)

  call set_count(l_pi - 1)
  display array a_ctx35g00 to s_ctx35g00.*
        
        #-----------------------------
          on key (F8)
        #-----------------------------
             let arr_pop = arr_curr()
             exit display 
                     
        #-----------------------------
         on key (interrupt)
        #-----------------------------
             error 'Tecle F8 para escolher um opcao'
      
  end display 
  
  close window w_ctx35g00
  
  return a_ctx35g00[arr_pop].itaasiplntipcod
       , a_ctx35g00[arr_pop].itaasiplntipdes 

#========================================================================
 end function  # Fim da funcao ctc92m05_popup
#========================================================================
 
