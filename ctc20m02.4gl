#############################################################################
# Nome do Modulo: CTC20M02                                    Sergio Burini #
#                                                                PSI 229784 #
# CADASTRO DE GRUPOS DE SERVIÇOS.                                  NOV/2008 #
#############################################################################
# ALTERACOES:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#

database porto

    globals "/homedsa/projetos/geral/globals/glct.4gl"

    define mr_entrada record
                          prtbnfgrpcod like dpaksrvgrp.prtbnfgrpcod,
                          prtbnfgrpdes like dpaksrvgrp.prtbnfgrpdes,
                          atldat       like dpaksrvgrp.atldat   ,
                          atlusr       like dpaksrvgrp.atlusr   ,
                          funnom       like isskfunc.funnom
                      end record
    
    define m_consulta_ativa smallint,
           m_confirma       char(01)

#---------------------------#
 function ctc20m02_prepare()
#---------------------------#
             
    define l_sql char(1000)
             
    let l_sql = "select 1 ",               
                 " from dpaksrvgrp ",   
                " where prtbnfgrpcod  = ? "   
    
    prepare pcctc20m02_01 from l_sql
    declare cqctc20m02_01 cursor for pcctc20m02_01    
      
    let l_sql = "select 1 ",
                 " from dpaksrvgrp ",
                " where prtbnfgrpdes = ? "
             
    prepare pcctc20m02_02 from l_sql
    declare cqctc20m02_02 cursor for pcctc20m02_02
    
    let l_sql = "insert into dpaksrvgrp values (?,?,?,?)"
    prepare pcctc20m02_03 from l_sql
    
    let l_sql = "select prtbnfgrpcod, ",
                      " prtbnfgrpdes, ",
                      " atldat, ",
                      " atlusr ",
                 " from dpaksrvgrp ",
                " where prtbnfgrpcod = ? "

    prepare pcctc20m02_04 from l_sql
    declare cqctc20m02_04 scroll cursor for pcctc20m02_04    

    let l_sql = "delete from dpaksrvgrp where prtbnfgrpcod = ? "
    prepare pcctc20m02_05 from l_sql
    
    let l_sql = "update dpaksrvgrp set prtbnfgrpdes = ?, atldat = ?, atlusr = ? where prtbnfgrpcod = ? "
    prepare pcctc20m02_06 from l_sql

    let l_sql = "select distinct 1 ", 
                 " from dpakprtbnfgrpcrt ",
                " where prtbnfgrpcod = ? "    
       
    prepare pcctc20m02_07 from l_sql
    declare cqctc20m02_07 scroll cursor for pcctc20m02_07   
    
    let l_sql = "delete from dpakprtbnfgrpcrt where prtbnfgrpcod = ? "
    
    prepare pcctc20m02_08 from l_sql    
    
    let l_sql = "select prtbnfgrpdes, ",
                      " atldat, ",
                      " atlusr ",
                 " from dpaksrvgrp ",
                " where prtbnfgrpcod = ? "
    
    prepare pcctc20m02_09 from l_sql
    declare cqctc20m02_09 scroll cursor for pcctc20m02_09  
    
    let l_sql = "delete from dpakbnfvlrfxa where prtbnfgrpcod = ? "
    
    prepare pcctc20m02_10 from l_sql
    
    let l_sql = "delete from dpakbnfgrppar where prtbnfgrpcod = ? "
    
    prepare pcctc20m02_11 from l_sql    

    let l_sql = "select distinct 1 ", 
                 " from dpakbnfvlrfxa ",
                " where prtbnfgrpcod = ? "    
       
    prepare pcctc20m02_12 from l_sql
    declare cqctc20m02_12 scroll cursor for pcctc20m02_12 

    let l_sql = "select distinct 1 ", 
                 " from dpakbnfgrppar ",
                " where prtbnfgrpcod = ? "    
       
    prepare pcctc20m02_13 from l_sql
    declare cqctc20m02_13 scroll cursor for pcctc20m02_13

    let l_sql = "select max(prtbnfgrpcod) ",
                 " from dpaksrvgrp "

    prepare pcctc20m02_14 from l_sql
    declare cqctc20m02_14 scroll cursor for pcctc20m02_14  


 end function
  
#-------------------#
 function ctc20m02()
#-------------------#

     define l_status smallint,
            l_flag   smallint
     
     call ctc20m02_prepare()
     
     open window w_ctc20m02 at 4,2 with form "ctc20m02"
          attribute(form line first)          
     
     menu "GRUPO_SERVICO" 
          
          command key ("S") "Selecionar"
                       "Consulta Grupo de Servico."
            call ctc20m02_consulta()
          
          command key ("P") "Proximo"
                       "Grupo de Servico anterior."
            if  m_consulta_ativa then
                call ctc20m02_proximo()
            else
                error 'Nenhuma consulta ativa no momento.'
                next option "Selecionar"
            end if 
            
          command key ("A") "Anterior"
                       "Grupo de Servico anterior."
            if  m_consulta_ativa then
                call ctc20m02_anterior()  
            else
                error 'Nenhuma consulta ativa no momento.'
                next option "Selecionar"
            end if          
            
          command key ("R") "paRametros"
                       "Parametros do Grupo de Servico."
            if  m_consulta_ativa then
                if  mr_entrada.prtbnfgrpcod is not null and
                    mr_entrada.prtbnfgrpcod <> " " then
                    call ctc20m03(mr_entrada.*)
                end if
            else
                error 'Nenhuma consulta ativa no momento.'
                next option "Selecionar"
            end if  
            
          command key ("T") "criTerios"
                       "Criterios do Grupo de Servico."
            if  m_consulta_ativa then
                if  mr_entrada.prtbnfgrpcod is not null and
                    mr_entrada.prtbnfgrpcod <> " " then
                    call ctc20m04(mr_entrada.*)
                end if
            else
                error 'Nenhuma consulta ativa no momento.'
                next option "Selecionar"
            end if
            
            
          command key ("I") "Incluir"
                       "Inclui Grupo de Servico."
            call ctc20m02_incluir()  
            
          command key ("X") "eXcluir"
                       "Exclui Grupo de Servico."
            if  m_consulta_ativa then
                call cts08g01("C","F"                                                   
                              ,"","CONFIRMA A EXCLUSAO DO GRUPO DE SERVICO","SELECIONADO ?","") 
                returning m_confirma                                                    
                                                                                        
                if  m_confirma = "S" then                                               
                    
                    let l_flag = false
                    
                    open cqctc20m02_07 using mr_entrada.prtbnfgrpcod
                    fetch cqctc20m02_07 into l_status
            
                    if  sqlca.sqlcode = 0 then
                        let l_flag = true
                    end if
                    
                    open cqctc20m02_12 using mr_entrada.prtbnfgrpcod
                    fetch cqctc20m02_12 into l_status
                    
                    if  sqlca.sqlcode = 0 then
                        let l_flag = true
                    end if                    
                    
                    open cqctc20m02_13 using mr_entrada.prtbnfgrpcod
                    fetch cqctc20m02_13 into l_status
                    
                    if  sqlca.sqlcode = 0 then
                        let l_flag = true
                    end if                     
                    
                    
                    if  l_flag then
                        let m_confirma = "N"
                        call cts08g01("C","F",                                                  
                                      "EXISTEM RELACIONAMENTO PARA ESSE",
                                      "GRUPO. A EXCLUSAO CONSEQUENTEMENTE",
                                      "ELIMINARA ESSES REGISTROS.",
                                      "CONTINUAR ASSIM MESMO ?")
                        returning m_confirma 
                        
                        if  m_confirma = "S" then
                            execute pcctc20m02_08 using mr_entrada.prtbnfgrpcod
                            
                            if  sqlca.sqlcode <> 0 then
                                error "Erro execute pcctc20m01_09 : ", sqlca.sqlcode
                            end if
                            
                            execute pcctc20m02_10 using mr_entrada.prtbnfgrpcod
                            
                            if  sqlca.sqlcode <> 0 then
                                error "Erro execute pcctc20m02_10 : ", sqlca.sqlcode
                            end if
                            
                            execute pcctc20m02_11 using mr_entrada.prtbnfgrpcod
                            
                            if  sqlca.sqlcode <> 0 then
                                error "Erro execute pcctc20m02_11 : ", sqlca.sqlcode
                            end if
                        end if                                                                     
                    end if
                    
                    if  m_confirma = "S" then 
                        call ctc20m02_excluir() 
                    end if            
                end if
            else
                error 'Nenhuma consulta ativa no momento.'
                next option "Selecionar"
            end if      
            
          command key ("M") "Modificar"
                       "Exclui Grupo de Servico."
            if  m_consulta_ativa then
                call ctc20m02_modificar()
            else
                error 'Nenhuma consulta ativa no momento.'
                next option "Selecionar"
            end if             

                                 

          command key (interrupt,E) "Encerra"
                       "Retorna ao menu anterior"
            exit menu
     end menu              

     close window w_ctc20m02
     
 end function
 
#----------------------------# 
 function ctc20m02_incluir()
#----------------------------# 
     
     define lr_retorno record
                           erro       smallint,
                           mensagem   char(60)
                       end record

     let int_flag = false
     
     initialize mr_entrada.* to null
     clear form
     
     let m_consulta_ativa = false
     
     input by name mr_entrada.prtbnfgrpcod,
                   mr_entrada.prtbnfgrpdes without defaults
     
         before field prtbnfgrpcod
            next field prtbnfgrpdes
          
         before field prtbnfgrpdes                                                
            display by name mr_entrada.prtbnfgrpdes attribute(reverse)            
            
         after field  prtbnfgrpdes
            display by name mr_entrada.prtbnfgrpdes
            
            if  mr_entrada.prtbnfgrpdes is null or
                mr_entrada.prtbnfgrpdes = " " then
                error "Descricao do Grupo deve ser informado."
                next field prtbnfgrpdes
            else            
                if  ctc20m02_existe_desc(mr_entrada.prtbnfgrpdes) then
                    error "Descrição do Grupo já cadastrado"
                    next field prtbnfgrpdes
                else
                    open cqctc20m02_14
                    fetch cqctc20m02_14 into mr_entrada.prtbnfgrpcod
                    
                    if  sqlca.sqlcode = notfound or
                        mr_entrada.prtbnfgrpcod  is null or
                        mr_entrada.prtbnfgrpcod  = " " then
                        let mr_entrada.prtbnfgrpcod  = 0
                    end if
     
                    let  mr_entrada.prtbnfgrpcod = mr_entrada.prtbnfgrpcod  + 1
                    display by name mr_entrada.prtbnfgrpcod
                end if
            end if

     end input
     
     if  not int_flag then
         let mr_entrada.atldat = current
         let mr_entrada.atlusr = g_issk.funmat
         
         execute pcctc20m02_03 using mr_entrada.prtbnfgrpcod,
                                     mr_entrada.prtbnfgrpdes,
                                     mr_entrada.atldat,
                                     mr_entrada.atlusr
                                     
         if  sqlca.sqlcode = 0 then
             call ctc20m02_exibe_dados() 
             let m_consulta_ativa = true                   
         end if
     else
         error "Inclusão Grupo de Servico cancelada."
         clear form
     end if     

 end function 
 
#---------------------------# 
 function ctc20m02_excluir()
#---------------------------# 
 
     execute pcctc20m02_05 using mr_entrada.prtbnfgrpcod
     
     if  sqlca.sqlcode <> 0 then
         error 'Problema no DELETE da tabela dpakprtbnfcrt : ', sqlca.sqlcode
     else
         let m_consulta_ativa = false
         initialize mr_entrada.* to null
         clear form
     end if

 end function
 
#----------------------------# 
 function ctc20m02_modificar()
#----------------------------# 
 
     define lr_retorno record
                           erro       smallint,
                           mensagem   char(60)
                        end record

     define l_prtbnfgrpdes like dpaksrvgrp.prtbnfgrpdes

     let l_prtbnfgrpdes = mr_entrada.prtbnfgrpdes
     let int_flag = false
     
     if  mr_entrada.prtbnfgrpcod is not null or           
         mr_entrada.prtbnfgrpcod <> " " or not m_consulta_ativa then 
     
         input by name mr_entrada.prtbnfgrpdes without defaults
     
             before field prtbnfgrpdes
                display by name mr_entrada.prtbnfgrpdes attribute (reverse)
         
             after field prtbnfgrpdes
                display by name mr_entrada.prtbnfgrpdes
            
                if  not int_flag then
                    if  l_prtbnfgrpdes <> mr_entrada.prtbnfgrpdes then
                        let mr_entrada.atldat = current
                        let mr_entrada.atlusr = g_issk.funmat
                        
                        execute pcctc20m02_06 using mr_entrada.prtbnfgrpdes,
                                                    mr_entrada.atldat,
                                                    mr_entrada.atlusr,
                                                    mr_entrada.prtbnfgrpcod
                
                        call ctc20m02_exibe_dados()                
                    end if
                else
                    error "Modificação Grupo de Servico cancelada."
                    clear form
                end if
     
         end input
     else
         error ""
     end if
 end function 
 
#-----------------------------# 
 function ctc20m02_consulta() 
#-----------------------------# 
     
      define lr_retorno record
                           erro       smallint,
                           mensagem   char(60)
                        end record

     define where_clause char(1000),
            l_sql        char(1000)
     
     initialize where_clause,
                l_sql to null
     
     let int_flag = false
     
     initialize mr_entrada.* to null
     
     clear form
     
     input by name mr_entrada.prtbnfgrpcod
     
         after field prtbnfgrpcod                             
                                                           
             if  mr_entrada.prtbnfgrpcod is null or           
                 mr_entrada.prtbnfgrpcod = " " then           
                                                           
                 select min(prtbnfgrpcod)                     
                   into mr_entrada.prtbnfgrpcod               
                   from dpaksrvgrp                      
                                                           
                 if  sqlca.sqlcode = notfound then         
                     error 'Nenhum grupo selecionado.'  
                 end if                                    
                 exit input                                
             end if                                        
     
     end input
         
     if not int_flag then    
         
         open cqctc20m02_04 using mr_entrada.prtbnfgrpcod
         fetch cqctc20m02_04 into mr_entrada.prtbnfgrpcod, 
                                  mr_entrada.prtbnfgrpdes,
                                  mr_entrada.atldat,    
                                  mr_entrada.atlusr
         
         if  sqlca.sqlcode = 0 then
             call ctc20m02_exibe_dados()
             let m_consulta_ativa = true
         else
             error 'Nenhum Grupo de Servico encontrado.'
             let m_consulta_ativa = false
             clear form
         end if
     else    
         error "Consulta Grupo de Servico cancelada."
         clear form                                           
     end if
     
 end function
 
#----------------------------------# 
 function ctc20m02_paginacao(l_opcao) 
#----------------------------------#
    
    define l_opcao char(1) 
    
    define lr_retorno record
                         erro       smallint,
                         mensagem   char(60)
                      end record    
 
    if  l_opcao = "S" then
        whenever error continue
        fetch next cqctc20m02_04 into mr_entrada.prtbnfgrpcod, 
                                      mr_entrada.prtbnfgrpdes,
                                      mr_entrada.atldat,    
                                      mr_entrada.atlusr
        whenever error stop
    else
        whenever error continue
        fetch previous cqctc20m02_04 into mr_entrada.prtbnfgrpcod,  
                                          mr_entrada.prtbnfgrpdes,  
                                          mr_entrada.atldat,     
                                          mr_entrada.atlusr
        whenever error stop
    end if

    if  sqlca.sqlcode = 0 then                           
        call ctc20m02_exibe_dados()               
    else
        error 'Nao existem mais dados nessa direção.'
    end if                                               

 end function
     
#-----------------------------------#
 function ctc20m02_existe_desc(lr_param)    
#-----------------------------------#     
 
     define lr_param record
                         prtbnfgrpdes like dpaksrvgrp.prtbnfgrpdes
                     end record
                     
     define l_aux smallint
 
     open cqctc20m02_02 using lr_param.prtbnfgrpdes
     fetch cqctc20m02_02 into l_aux
     
     case sqlca.sqlcode 
          when 100
               return false
          when 0 
               return true
          otherwise
               error "Erro ao encontrar descrição do criterio. Erro ", sqlca.sqlcode
               return false
     end case
 
 end function 
 
#-----------------------------------#
 function ctc20m02_existe_cod(lr_param)    
#-----------------------------------#     
 
     define lr_param record
                         prtbnfgrpcod like dpaksrvgrp.prtbnfgrpcod
                     end record
                     
     define l_aux smallint
 
     open cqctc20m02_01 using lr_param.prtbnfgrpcod
     fetch cqctc20m02_01 into l_aux
     
     case sqlca.sqlcode 
          when 100
               return false
          when 0 
               return true
          otherwise
               error "Erro ao encontrar codigo do criterio. Erro ", sqlca.sqlcode
               return false
     end case
 
 end function 
 
#-------------------------------#
 function ctc20m02_exibe_dados()    
#-------------------------------#     
  
     define lr_retorno record
                          erro       smallint,
                          mensagem   char(60)
                       end record        

     display by name mr_entrada.prtbnfgrpcod										             
     display by name mr_entrada.prtbnfgrpdes										             
     display by name mr_entrada.atldat                
                                                      
     call cty08g00_nome_func(1,mr_entrada.atlusr,'F') 
          returning lr_retorno.erro,                  
                    lr_retorno.mensagem,              
                    mr_entrada.funnom                 
                                                      
     display by name mr_entrada.funnom     
     
 end function 
 
 #----------------------------# 
 function ctc20m02_anterior()
#----------------------------#

    define l_prtbnfgrpcod like dpaksrvgrp.prtbnfgrpcod
    
    select max (prtbnfgrpcod)
      into l_prtbnfgrpcod
      from dpaksrvgrp
     where prtbnfgrpcod < mr_entrada.prtbnfgrpcod

    if  l_prtbnfgrpcod is not null then
        let mr_entrada.prtbnfgrpcod = l_prtbnfgrpcod
        
        open cqctc20m02_09 using mr_entrada.prtbnfgrpcod
        fetch cqctc20m02_09 into mr_entrada.prtbnfgrpdes,
                                 mr_entrada.atldat,
                                 mr_entrada.atlusr
        
        call ctc20m02_exibe_dados()
    end if
    
    if  l_prtbnfgrpcod is null or sqlca.sqlcode = notfound then
        error " Nao ha' mais registros nesta direcao!"
    end if    
    
 end function
   
#---------------------------#
 function ctc20m02_proximo()
#---------------------------#

    define l_prtbnfgrpcod like dpaksrvgrp.prtbnfgrpcod
    
    select min (prtbnfgrpcod)
      into l_prtbnfgrpcod
      from dpaksrvgrp
     where prtbnfgrpcod > mr_entrada.prtbnfgrpcod
     
     if l_prtbnfgrpcod is not null then
        let mr_entrada.prtbnfgrpcod = l_prtbnfgrpcod
        
        open cqctc20m02_09 using mr_entrada.prtbnfgrpcod
        fetch cqctc20m02_09 into mr_entrada.prtbnfgrpdes,
                                 mr_entrada.atldat,
                                 mr_entrada.atlusr

       call ctc20m02_exibe_dados()
     end if
     
     if l_prtbnfgrpcod is null or sqlca.sqlcode = notfound then
        error " Nao ha' mais registros nesta direcao!"
     end if

 end function   
