############################################################################
# Nome do Modulo: ctc93m06                                 Robson Ruas     #
# Cadastrar Codigo de retencao                             Abril/2013      #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_dominio record                         
       erro      smallint  ,                    
       mensagem  char(100) ,                    
       cpodes    like iddkdominio.cpodes        
end record                                      
         
define m_pcpatvcod     integer
define m_pestipcod     char(1)
#------------------------------------------------------------
 function ctc93m06()
#------------------------------------------------------------

define d_ctc93m06    record                      
        pcpatvcod            integer    
       ,pcpatvdes            char(100)
       ,pestipcod            char(1)             
       ,ipsdnccod            char(20)            
       ,icldat               date                
       ,cadusrtipcod         char(1)             
       ,cadusrempcod         decimal(2,0)        
       ,cadusrmatcod         decimal(6,0)        
       ,cadfunnom            char(100)           
       ,atldat               date                
       ,atlusrtipcod         char(1)             
       ,atlusrempcod         decimal(2,0)        
       ,atlusrmatcod         decimal(6,0)        
       ,atlfunnom            char(100)           
end record                                       

 let int_flag = false
 initialize d_ctc93m06.*  to null

 #if not get_niv_mod(g_issk.prgsgl, "ctc93m06") then
 #   error " Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 open window ctc93m06 at 4,2 with form "ctc93m06"

 menu "RETENCAO:"

  before menu
     #hide option all
     #if g_issk.acsnivcod >= g_issk.acsnivcns  then
     #   show option "Seleciona", "Proximo", "Anterior"
     #end if
     #if g_issk.acsnivcod >= g_issk.acsnivatl  then
     #   show option "Seleciona", "Proximo", "Anterior",
     #               "Modifica" , "Inclui" , "Remove"
     #end if
     #show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa eventos de analise conforme criterios"
          call ctc93m06_seleciona()  returning d_ctc93m06.*
          if d_ctc93m06.pcpatvcod    is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum evento de analise selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo evento de analise selecionado"
          message ""
          call ctc93m06_proximo(d_ctc93m06.pcpatvcod,d_ctc93m06.pestipcod)
               returning d_ctc93m06.*

 command key ("A") "Anterior"
                   "Mostra evento de analise anterior selecionado"
          message ""
          if d_ctc93m06.pcpatvcod is not null then
             call ctc93m06_anterior(d_ctc93m06.pcpatvcod,d_ctc93m06.pestipcod)
                  returning d_ctc93m06.*
          else
             error " Nenhum evento de analise nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica evento de analise corrente selecionado"
          message ""
          if d_ctc93m06.pcpatvcod  is not null then
             call ctc93m06_modifica(d_ctc93m06.*)
                  returning d_ctc93m06.*
             next option "Seleciona"
          else
             error " Nenhum evento de analise selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui evento de analise"
          message ""
          call ctc93m06_inclui()
          next option "Seleciona"

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc93m06

 end function  # ctc93m06


#------------------------------------------------------------
 function ctc93m06_seleciona()
#------------------------------------------------------------

define d_ctc93m06    record                        
        pcpatvcod            integer
       ,pcpatvdes            char(100)               
       ,pestipcod            char(1)               
       ,ipsdnccod            char(20)              
       ,icldat               date                  
       ,cadusrtipcod         char(1)               
       ,cadusrempcod         decimal(2,0)          
       ,cadusrmatcod         decimal(6,0)          
       ,cadfunnom            char(100)             
       ,atldat               date                  
       ,atlusrtipcod         char(1)               
       ,atlusrempcod         decimal(2,0)          
       ,atlusrmatcod         decimal(6,0)          
       ,atlfunnom            char(100)           
end record    

define lr_retorno     record      
       erro    smallint,          
       cpocod  integer ,          
       cpodes  char(50)           
end record 

define l_pestipcod          char(1)
define l_pcpatvcod          integer 

 let int_flag     = false
 let l_pestipcod  = "F"
 initialize d_ctc93m06.* to null
 display by name   d_ctc93m06.pcpatvcod     
                  ,d_ctc93m06.pcpatvdes     
                  ,d_ctc93m06.pestipcod     
                  ,d_ctc93m06.ipsdnccod     
                  ,d_ctc93m06.icldat        
                  ,d_ctc93m06.cadfunnom     
                  ,d_ctc93m06.atldat        
                  ,d_ctc93m06.atlfunnom     

 input by name d_ctc93m06.pcpatvcod

    before field pcpatvcod                                                                
           display by name d_ctc93m06.pcpatvcod attribute(reverse)                        
                                                                                          
    after  field pcpatvcod                                                                
       display by name d_ctc93m06.pcpatvcod                                           
                                                                                         
       if fgl_lastkey() = fgl_keyval("up")    or                                      
          fgl_lastkey() = fgl_keyval("left")  then                                    
          next field pcpatvcod                                                        
       end if                                                                         
                                                                                         
       initialize lr_retorno.* to null                                                
       initialize m_dominio.* to null                                                 
                                                                                         
       if d_ctc93m06.pcpatvcod is null  or  d_ctc93m06.pcpatvcod  = " " then                                              
          
          let d_ctc93m06.pcpatvcod = 0 
          
       else                                                                           
          call cty11g00_iddkdominio('pcpatvcod', d_ctc93m06.pcpatvcod)                
               returning m_dominio.*                                                  
                                                                                      
          if m_dominio.erro != 1                                                      
             then                                                                     
             if m_dominio.cpodes is null                                              
                then                                                                  
                error ' Atividade não encontrada '                                    
             else                                                                     
                error m_dominio.mensagem                                              
             end if                                                                   
             initialize d_ctc93m06.pcpatvdes to null                                  
             display by name d_ctc93m06.pcpatvdes                                     
                                                                                      
             call cty09g00_popup_iddkdominio("pcpatvcod")                             
                  returning lr_retorno.erro, d_ctc93m06.pcpatvcod,                    
                            d_ctc93m06.pcpatvdes                                      
                                                                                      
          else                                                                        
             let d_ctc93m06.pcpatvdes = m_dominio.cpodes                              
          end if                                                                      
       end if                                                                         
                                                                                         
       if d_ctc93m06.pcpatvcod is null                                                
          then                                                                        
          next field pcpatvcod                                                        
       end if                                                                         
                                                                                      
       display by name d_ctc93m06.pcpatvdes, d_ctc93m06.pcpatvdes    
    
    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc93m06.*   to null
    display by name   d_ctc93m06.pcpatvcod     
                     ,d_ctc93m06.pcpatvdes     
                     ,d_ctc93m06.pestipcod     
                     ,d_ctc93m06.ipsdnccod     
                     ,d_ctc93m06.icldat        
                     ,d_ctc93m06.cadfunnom      
                     ,d_ctc93m06.atldat        
                     ,d_ctc93m06.atlfunnom     
    
    error " Operacao cancelada!"
    clear form
    return d_ctc93m06.*
 end if

 if d_ctc93m06.pcpatvcod = 0 then 
   select min(pcpatvcod)
      into l_pcpatvcod
      from dbsmprsatvipsdnc
     where pcpatvcod > d_ctc93m06.pcpatvcod
 
    whenever error continue   
    select  1
      from dbsmprsatvipsdnc
     where pcpatvcod = l_pcpatvcod
     and   pestipcod = l_pestipcod 
    whenever error stop                                                 
                                                                           
    if sqlca.sqlcode != 0 then
       let l_pestipcod = "J"
    end if 
 else 
    let l_pcpatvcod = d_ctc93m06.pcpatvcod
    
    whenever error continue                          
    select 1
      from dbsmprsatvipsdnc                          
     where pcpatvcod = l_pcpatvcod
     and   pestipcod = l_pestipcod                   
    whenever error stop                             
                                                     
    if sqlca.sqlcode != 0 then                      
       let l_pestipcod = "J"                        
    end if                                          
 end if 
 
 call ctc93m06_ler(l_pcpatvcod, l_pestipcod)
                   
      returning d_ctc93m06.*
                   
 if d_ctc93m06.pcpatvcod  is not null   then
    display by name   d_ctc93m06.pcpatvcod     
                     ,d_ctc93m06.pcpatvdes     
                     ,d_ctc93m06.pestipcod     
                     ,d_ctc93m06.ipsdnccod     
                     ,d_ctc93m06.icldat        
                     ,d_ctc93m06.cadfunnom     
                     ,d_ctc93m06.atldat        
                     ,d_ctc93m06.atlfunnom     
   else
    error " Evento de analise nao cadastrado!"
    initialize d_ctc93m06.*    to null
 end if

 return d_ctc93m06.*

 end function  # ctc93m06_seleciona


#------------------------------------------------------------
 function ctc93m06_proximo(param)
#------------------------------------------------------------

define param         record
   pcpatvcod         like dbsmprsatvipsdnc.pcpatvcod
  ,pestipcod         like dbsmprsatvipsdnc.pestipcod
end record

define d_ctc93m06    record                            
        pcpatvcod            integer
       ,pcpatvdes            char(100)                   
       ,pestipcod            char(1)                   
       ,ipsdnccod            char(20)                  
       ,icldat               date                      
       ,cadusrtipcod         char(1)                   
       ,cadusrempcod         decimal(2,0)              
       ,cadusrmatcod         decimal(6,0)              
       ,cadfunnom            char(100)                 
       ,atldat               date                      
       ,atlusrtipcod         char(1)                   
       ,atlusrempcod         decimal(2,0)              
       ,atlusrmatcod         decimal(6,0)              
       ,atlfunnom            char(100)           
end record 

define lr_verid              integer
define l_pestip              like dbsmprsatvipsdnc.pestipcod
define l_pcpatvcod           like dbsmprsatvipsdnc.pcpatvcod 
                                     
 let int_flag = false     
 initialize d_ctc93m06.*   to null  

 if param.pcpatvcod  is null   then
    let param.pcpatvcod = 0
 end if
 
 
 select min(pcpatvcod)      
   into l_pcpatvcod     
   from dbsmprsatvipsdnc
  where pcpatvcod > param.pcpatvcod
  
 select count(*)                      
  into  lr_verid                      
  from  dbsmprsatvipsdnc              
  where pcpatvcod = param.pcpatvcod   
  
  if lr_verid > 1 then
     if param.pestipcod = "F" then         
        let l_pestip    = "J"              
        let l_pcpatvcod = param.pcpatvcod  
     else 
        let l_pestip = "F" 
        whenever error continue               
        select  1                             
          from dbsmprsatvipsdnc               
         where pcpatvcod = l_pcpatvcod        
         and   pestipcod = l_pestip        
        whenever error stop                   
                                              
        if sqlca.sqlcode != 0 then            
           let l_pestip = "J"              
        end if                                
     end if 
  else
     let l_pestip = "F"
     whenever error continue 
     select  1                              
       from dbsmprsatvipsdnc                
      where pcpatvcod = l_pcpatvcod         
      and   pestipcod = l_pestip         
     whenever error stop                    
                                            
     if sqlca.sqlcode != 0 then             
        let l_pestip = "J"               
     end if                                 
  end if 
 
 if l_pcpatvcod is not null or l_pcpatvcod <> 0 then 
    call ctc93m06_ler(l_pcpatvcod,l_pestip)  
         returning d_ctc93m06.*

         let m_pcpatvcod = d_ctc93m06.pcpatvcod
         let m_pestipcod = d_ctc93m06.pestipcod

    if d_ctc93m06.pcpatvcod  is not null   then
       display by name   d_ctc93m06.pcpatvcod     
                        ,d_ctc93m06.pcpatvdes     
                        ,d_ctc93m06.pestipcod     
                        ,d_ctc93m06.ipsdnccod     
                        ,d_ctc93m06.icldat        
                        ,d_ctc93m06.cadfunnom     
                        ,d_ctc93m06.atldat        
                        ,d_ctc93m06.atlfunnom     
    else
       error " Nao ha' evento de analise nesta direcao!"
       initialize d_ctc93m06.*    to null
       let d_ctc93m06.pcpatvcod  = m_pcpatvcod
       let d_ctc93m06.pestipcod  = m_pestipcod
       return d_ctc93m06.*
    end if
 else
    error " Nao ha' evento de analise nesta direcao!"
    initialize d_ctc93m06.*    to null
    let d_ctc93m06.pcpatvcod  = m_pcpatvcod
    let d_ctc93m06.pestipcod  = m_pestipcod
    return d_ctc93m06.*                     
 end if

 return d_ctc93m06.*

 end function    # ctc93m06_proximo

#------------------------------------------------------------
 function ctc93m06_anterior(param)
#------------------------------------------------------------

 define param         record
    pcpatvcod         like dbsmprsatvipsdnc.pcpatvcod
   ,pestipcod         like dbsmprsatvipsdnc.pestipcod
 end record

define d_ctc93m06    record                              
        pcpatvcod            integer 
       ,pcpatvdes            char(100)                    
       ,pestipcod            char(1)                     
       ,ipsdnccod            char(20)                    
       ,icldat               date                        
       ,cadusrtipcod         char(1)                     
       ,cadusrempcod         decimal(2,0)                
       ,cadusrmatcod         decimal(6,0)                
       ,cadfunnom            char(100)                   
       ,atldat               date                        
       ,atlusrtipcod         char(1)                     
       ,atlusrempcod         decimal(2,0)                
       ,atlusrmatcod         decimal(6,0)        
       ,atlfunnom            char(100)           
end record   

define lr_verid              integer
define l_pestip              like dbsmprsatvipsdnc.pestipcod
define l_pcpatvcod           like dbsmprsatvipsdnc.pcpatvcod 

 let int_flag = false
 initialize d_ctc93m06.*  to null

 if param.pcpatvcod  is null   then
    let param.pcpatvcod = 0
 end if
 
  select max(pcpatvcod)      
   into l_pcpatvcod     
   from dbsmprsatvipsdnc
  where pcpatvcod < param.pcpatvcod
  
 select count(*)                      
  into  lr_verid                      
  from  dbsmprsatvipsdnc              
  where pcpatvcod = param.pcpatvcod   
  
  if lr_verid > 1 then
     if param.pestipcod = "J" then         
        let l_pestip    = "F"              
        let l_pcpatvcod = param.pcpatvcod  
     else 
        let l_pestip = "J" 
        whenever error continue               
        select  1                             
          from dbsmprsatvipsdnc               
         where pcpatvcod = l_pcpatvcod        
         and   pestipcod = l_pestip        
        whenever error stop                   
                                              
        if sqlca.sqlcode != 0 then            
           let l_pestip = "F"              
        end if                                
     end if 
  else
     let l_pestip = "J"
     whenever error continue 
     select  1                              
       from dbsmprsatvipsdnc                
      where pcpatvcod = l_pcpatvcod         
      and   pestipcod = l_pestip         
     whenever error stop                    
                                            
     if sqlca.sqlcode != 0 then             
        let l_pestip = "F"               
     end if                                 
  end if 
  
 if l_pcpatvcod is not null or l_pcpatvcod <> 0 then 
    call ctc93m06_ler(l_pcpatvcod, l_pestip)  
    
         returning d_ctc93m06.*
         
         let m_pcpatvcod = d_ctc93m06.pcpatvcod
    
    if d_ctc93m06.pcpatvcod  is not null   then
       display by name   d_ctc93m06.pcpatvcod    
                        ,d_ctc93m06.pcpatvdes    
                        ,d_ctc93m06.pestipcod    
                        ,d_ctc93m06.ipsdnccod    
                        ,d_ctc93m06.icldat       
                        ,d_ctc93m06.cadfunnom    
                        ,d_ctc93m06.atldat       
                        ,d_ctc93m06.atlfunnom    
    else
       error " Nao ha' evento de analise nesta direcao!"
       initialize d_ctc93m06.*    to null    
       let  d_ctc93m06.pcpatvcod = m_pcpatvcod 
       let d_ctc93m06.pestipcod  = m_pestipcod
       return d_ctc93m06.*   
    end if
 else
    error " Nao ha' evento de analise nesta direcao!"
    initialize d_ctc93m06.*    to null
    let  d_ctc93m06.pcpatvcod = m_pcpatvcod 
    let d_ctc93m06.pestipcod  = m_pestipcod
    return d_ctc93m06.*
 end if

 return d_ctc93m06.*

 end function    # ctc93m06_anterior


#------------------------------------------------------------
 function ctc93m06_modifica(d_ctc93m06)
#------------------------------------------------------------

define d_ctc93m06    record                          
        pcpatvcod            integer
       ,pcpatvdes            char(100)                 
       ,pestipcod            char(1)                 
       ,ipsdnccod            char(20)                
       ,icldat               date                    
       ,cadusrtipcod         char(1)                 
       ,cadusrempcod         decimal(2,0)            
       ,cadusrmatcod         decimal(6,0)            
       ,cadfunnom            char(100)               
       ,atldat               date                    
       ,atlusrtipcod         char(1)                 
       ,atlusrempcod         decimal(2,0)            
       ,atlusrmatcod         decimal(6,0)        
       ,atlfunnom            char(100)           
end record                                       

define d_ctc93m06_ant    record                             
        pcpatvcod            integer
       ,pcpatvdes            char(100)                                 
       ,pestipcod            char(1)                
       ,ipsdnccod            char(20)               
       ,icldat               date                   
       ,cadusrtipcod         char(1)                
       ,cadusrempcod         decimal(2,0)           
       ,cadusrmatcod         decimal(6,0)           
       ,cadfunnom            char(100)              
       ,atldat               date                   
       ,atlusrtipcod         char(1)                
       ,atlusrempcod         decimal(2,0)           
       ,atlusrmatcod         decimal(6,0)        
       ,atlfunnom            char(100)           
end record                                       


 let d_ctc93m06_ant.pcpatvcod = d_ctc93m06.pcpatvcod
 let d_ctc93m06_ant.ipsdnccod = d_ctc93m06.ipsdnccod
 let d_ctc93m06_ant.pestipcod = d_ctc93m06.pestipcod

 call ctc93m06_input(d_ctc93m06.*) returning d_ctc93m06.*
 
 if d_ctc93m06_ant.pcpatvcod = d_ctc93m06.pcpatvcod then 
    if d_ctc93m06_ant.ipsdnccod  =  d_ctc93m06.ipsdnccod then
       if d_ctc93m06_ant.pestipcod =  d_ctc93m06.pestipcod then
          error "Informacoes do Codigo de Retencao nao teve alteracao!"  
          return d_ctc93m06.*           
       end if 
    end if 
 end if 

 if int_flag  then
    let int_flag = false
    initialize d_ctc93m06.*  to null
    display by name   d_ctc93m06.pcpatvcod    
                     ,d_ctc93m06.pcpatvdes    
                     ,d_ctc93m06.pestipcod    
                     ,d_ctc93m06.ipsdnccod    
                     ,d_ctc93m06.icldat       
                     ,d_ctc93m06.cadfunnom    
                     ,d_ctc93m06.atldat       
                     ,d_ctc93m06.atlfunnom    
    error " Operacao cancelada!"
    return d_ctc93m06.*
 end if

 whenever error continue

 let d_ctc93m06.atldat = today

 begin work
 
   update dbsmprsatvipsdnc set (pcpatvcod     
                               ,pestipcod        
                               ,ipsdnccod     
                               ,atldat        
                               ,atlusrtipcod  
                               ,atlusrempcod  
                               ,atlusrmatcod  )
                          =    (d_ctc93m06.pcpatvcod  
                               ,d_ctc93m06.pestipcod  
                               ,d_ctc93m06.ipsdnccod  
                               ,d_ctc93m06.atldat
                               ,g_issk.usrtip      
                               ,g_issk.empcod
                               ,g_issk.funmat)
   where pcpatvcod  = d_ctc93m06_ant.pcpatvcod 
   and   pestipcod  = d_ctc93m06_ant.pestipcod 
   and   ipsdnccod  = d_ctc93m06_ant.ipsdnccod 

   if sqlca.sqlcode <>  0  then
      error " Erro (",sqlca.sqlcode,") na alteracao do evento de analise!"
      rollback work
      initialize d_ctc93m06.*   to null
      return d_ctc93m06.*
   else
      error " Alteracao efetuada com sucesso!"
   end if

 commit work

 whenever error stop

 initialize d_ctc93m06.*  to null
 display by name   d_ctc93m06.pcpatvcod    
                  ,d_ctc93m06.pcpatvdes    
                  ,d_ctc93m06.pestipcod    
                  ,d_ctc93m06.ipsdnccod    
                  ,d_ctc93m06.icldat       
                  ,d_ctc93m06.cadfunnom    
                  ,d_ctc93m06.atldat       
                  ,d_ctc93m06.atlfunnom    
 message ""
 return d_ctc93m06.*

 end function   #  ctc93m06_modifica


#------------------------------------------------------------
 function ctc93m06_inclui()
#------------------------------------------------------------

define d_ctc93m06    record                           
        pcpatvcod            integer 
       ,pcpatvdes            char(100)                 
       ,pestipcod            char(1)                  
       ,ipsdnccod            char(20)                 
       ,icldat               date                     
       ,cadusrtipcod         char(1)                  
       ,cadusrempcod         decimal(2,0)             
       ,cadusrmatcod         decimal(6,0)             
       ,cadfunnom            char(100)                
       ,atldat               date                     
       ,atlusrtipcod         char(1)                  
       ,atlusrempcod         decimal(2,0)             
       ,atlusrmatcod         decimal(6,0)        
       ,atlfunnom            char(100)           
end record                                       

                                           

 define  ws           record
    c24evtdes         char(150),
    resp              char(01)
 end record


 initialize d_ctc93m06.*   to null
 display by name   d_ctc93m06.pcpatvcod    
                  ,d_ctc93m06.pcpatvdes    
                  ,d_ctc93m06.pestipcod    
                  ,d_ctc93m06.ipsdnccod    
                  ,d_ctc93m06.icldat       
                  ,d_ctc93m06.cadfunnom    
                  ,d_ctc93m06.atldat       
                  ,d_ctc93m06.atlfunnom    

 call ctc93m06_input(d_ctc93m06.*) returning d_ctc93m06.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc93m06.*  to null
    display by name   d_ctc93m06.pcpatvcod    
                     ,d_ctc93m06.pcpatvdes    
                     ,d_ctc93m06.pestipcod    
                     ,d_ctc93m06.ipsdnccod    
                     ,d_ctc93m06.icldat       
                     ,d_ctc93m06.cadfunnom    
                     ,d_ctc93m06.atldat       
                     ,d_ctc93m06.atlfunnom    
    error " Operacao cancelada!"
    return
 end if
 
 let d_ctc93m06.atldat = today 
 let d_ctc93m06.icldat = today 

 whenever error continue

 begin work

 insert into  dbsmprsatvipsdnc  (pcpatvcod     
                                ,pestipcod     
                                ,ipsdnccod     
                                ,icldat        
                                ,cadusrtipcod  
                                ,cadusrempcod  
                                ,cadusrmatcod  
                                ,atldat        
                                ,atlusrtipcod  
                                ,atlusrempcod  
                                ,atlusrmatcod )
                  values       (d_ctc93m06.pcpatvcod
                                ,d_ctc93m06.pestipcod
                                ,d_ctc93m06.ipsdnccod
                                ,d_ctc93m06.atldat 
                                ,g_issk.usrtip
                                ,g_issk.empcod
                                ,g_issk.funmat 
                                ,d_ctc93m06.icldat 
                                ,g_issk.usrtip 
                                ,g_issk.empcod
                                ,g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao na tabela dbsmprsatvipsdnc"
       rollback work
       return
    end if

 commit work

 whenever error stop
 
 call ctc93m06_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc93m06.cadfunnom

 call ctc93m06_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc93m06.atlfunnom
 display by name   d_ctc93m06.pcpatvcod    
                  ,d_ctc93m06.pcpatvdes    
                  ,d_ctc93m06.pestipcod    
                  ,d_ctc93m06.ipsdnccod    
                  ,d_ctc93m06.icldat       
                  ,d_ctc93m06.cadfunnom    
                  ,d_ctc93m06.atldat       
                  ,d_ctc93m06.atlfunnom    
                  
 display by name d_ctc93m06.ipsdnccod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws.resp

 initialize d_ctc93m06.*  to null
 display by name   d_ctc93m06.pcpatvcod     
                  ,d_ctc93m06.pcpatvdes     
                  ,d_ctc93m06.pestipcod     
                  ,d_ctc93m06.ipsdnccod     
                  ,d_ctc93m06.icldat        
                  ,d_ctc93m06.cadfunnom     
                  ,d_ctc93m06.atldat        
                  ,d_ctc93m06.atlfunnom     

 end function   #  ctc93m06_inclui


#--------------------------------------------------------------------
 function ctc93m06_input(d_ctc93m06)
#--------------------------------------------------------------------

define d_ctc93m06    record                       
        pcpatvcod            integer  
       ,pcpatvdes            char(100)            
       ,pestipcod            char(1)              
       ,ipsdnccod            char(20)             
       ,icldat               date                 
       ,cadusrtipcod         char(1)              
       ,cadusrempcod         decimal(2,0)         
       ,cadusrmatcod         decimal(6,0)         
       ,cadfunnom            char(100)            
       ,atldat               date                 
       ,atlusrtipcod         char(1)              
       ,atlusrempcod         decimal(2,0)         
       ,atlusrmatcod         decimal(6,0)        
       ,atlfunnom            char(100)           
end record  

define lr_retorno     record    
       erro    smallint,        
       cpocod  integer ,        
       cpodes  char(50)         
end record                      

 let int_flag = false

 input by name  d_ctc93m06.pcpatvcod     
               ,d_ctc93m06.pestipcod     
               ,d_ctc93m06.ipsdnccod  without defaults

    before field pcpatvcod                                                                
           display by name d_ctc93m06.pcpatvcod attribute(reverse)                        
                                                                                          
    after  field pcpatvcod                                                                
       display by name d_ctc93m06.pcpatvcod                                           
                                                                                         
       if fgl_lastkey() = fgl_keyval("up")    or                                      
          fgl_lastkey() = fgl_keyval("left")  then                                    
          next field pcpatvcod                                                        
       end if                                                                         
                                                                                         
       initialize lr_retorno.* to null                                                
       initialize m_dominio.* to null                                                 
                                                                                         
       if d_ctc93m06.pcpatvcod is null  or d_ctc93m06.pcpatvcod  = " " then                                               
          error " Informe a atividade principal do prestador "                        
          call cty09g00_popup_iddkdominio("pcpatvcod")                                
               returning lr_retorno.erro, d_ctc93m06.pcpatvcod,                       
                         d_ctc93m06.pcpatvdes                                         
       else                                                                           
          call cty11g00_iddkdominio('pcpatvcod', d_ctc93m06.pcpatvcod)                
               returning m_dominio.*                                                  
                                                                                      
          if m_dominio.erro != 1                                                      
             then                                                                     
             if m_dominio.cpodes is null                                              
                then                                                                  
                error ' Atividade não encontrada '                                    
             else                                                                     
                error m_dominio.mensagem                                              
             end if                                                                   
             initialize d_ctc93m06.pcpatvdes to null                                  
             display by name d_ctc93m06.pcpatvdes                                     
                                                                                      
             call cty09g00_popup_iddkdominio("pcpatvcod")                             
                  returning lr_retorno.erro, d_ctc93m06.pcpatvcod,                    
                            d_ctc93m06.pcpatvdes                                      
                                                                                      
          else                                                                        
             let d_ctc93m06.pcpatvdes = m_dominio.cpodes                              
          end if                                                                      
       end if                                                                         
                                                                                         
       if d_ctc93m06.pcpatvcod is null                                                
          then                                                                        
          next field pcpatvcod                                                        
       end if                                                                         
                                                                                      
       display by name d_ctc93m06.pcpatvdes, d_ctc93m06.pcpatvdes    
    
    
    before field pestipcod
           display by name d_ctc93m06.pestipcod attribute (reverse)
    
    after  field pestipcod
           display by name d_ctc93m06.pestipcod
    
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  pestipcod
           end if
    
          if d_ctc93m06.pestipcod   is null   then             
             error " Tipo de pessoa deve ser informado!"    
             next field pestipcod                              
          end if                                            
                                                            
          if d_ctc93m06.pestipcod  <>  "F"   and               
             d_ctc93m06.pestipcod  <>  "J"   then              
             error " Tipo de pessoa invalido!"              
             next field pestipcod                              
          end if                                            
    
    before field ipsdnccod
           display by name d_ctc93m06.ipsdnccod attribute (reverse)
    
    after  field ipsdnccod
           display by name d_ctc93m06.ipsdnccod
    
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  ipsdnccod
           end if
           
           if d_ctc93m06.ipsdnccod   is null   then             
              error "Codigo de retencao deve ser informado!"       
              next field ipsdnccod                              
           end if                                               
    
    on key (interrupt)
       exit input
    
 end input

 if int_flag   then
    initialize d_ctc93m06.*  to null
 end if

 return d_ctc93m06.*

 end function   # ctc93m06_input

#---------------------------------------------------------
 function ctc93m06_ler(param)
#---------------------------------------------------------

 define param         record
     pcpatvcod         like dbsmprsatvipsdnc.pcpatvcod
     #rowid             integer
     ,pestipcod         like dbsmprsatvipsdnc.pestipcod
 end record

define d_ctc93m06    record                           
        pcpatvcod            integer   
       ,pcpatvdes            char(100)               
       ,pestipcod            char(1)                  
       ,ipsdnccod            char(20)                 
       ,icldat               date                     
       ,cadusrtipcod         char(1)                  
       ,cadusrempcod         decimal(2,0)             
       ,cadusrmatcod         decimal(6,0) 
       ,cadfunnom            char(100)
       ,atldat               date                     
       ,atlusrtipcod         char(1)                  
       ,atlusrempcod         decimal(2,0)             
       ,atlusrmatcod         decimal(6,0) 
       ,atlfunnom            char(100)
end record                                            

 initialize d_ctc93m06.*   to null

 select pcpatvcod      
       ,pestipcod      
       ,ipsdnccod      
       ,icldat         
       ,cadusrtipcod   
       ,cadusrempcod   
       ,cadusrmatcod   
       ,atldat         
       ,atlusrtipcod   
       ,atlusrempcod   
       ,atlusrmatcod   
   into d_ctc93m06.pcpatvcod      
       ,d_ctc93m06.pestipcod      
       ,d_ctc93m06.ipsdnccod      
       ,d_ctc93m06.icldat         
       ,d_ctc93m06.cadusrtipcod   
       ,d_ctc93m06.cadusrempcod   
       ,d_ctc93m06.cadusrmatcod   
       ,d_ctc93m06.atldat         
       ,d_ctc93m06.atlusrtipcod   
       ,d_ctc93m06.atlusrempcod   
       ,d_ctc93m06.atlusrmatcod   
  from  dbsmprsatvipsdnc
   where  pcpatvcod = param.pcpatvcod
   #where  rowid     = param.rowid
   and    pestipcod = param.pestipcod

 if sqlca.sqlcode = notfound   then
    error " Evento de analise nao cadastrado!"
    initialize d_ctc93m06.*    to null
    return d_ctc93m06.*
 end if
 
 call cty11g00_iddkdominio('pcpatvcod', d_ctc93m06.pcpatvcod)  
      returning m_dominio.*                                    
 
 let d_ctc93m06.pcpatvdes = m_dominio.cpodes


 call ctc93m06_func(d_ctc93m06.cadusrempcod, d_ctc93m06.cadusrmatcod)
      returning d_ctc93m06.cadfunnom

 call ctc93m06_func(d_ctc93m06.atlusrempcod, d_ctc93m06.atlusrmatcod)
      returning d_ctc93m06.atlfunnom


 return d_ctc93m06.*

 end function   # ctc93m06_ler


#---------------------------------------------------------
 function ctc93m06_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = param.empcod
    and isskfunc.funmat = param.funmat

 return ws.funnom

 end function   # ctc93m06_func
