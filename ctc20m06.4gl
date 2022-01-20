#############################################################################
# Nome do Modulo: CTC20M06                                    Sergio Burini #
#                                                                PSI 237248 #
# CADASTRO DE PROCESSOS DE BONIFICAÇÃO.                            MAR/2008 #
#############################################################################
# ALTERACOES:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#

database porto

    globals "/homedsa/projetos/geral/globals/glct.4gl"

    define mr_entrada record
                          prtbnfprccod like dpakprtbnfprc.prtbnfprccod,
                          prtbnfprcdes like dpakprtbnfprc.prtbnfprcdes,
                          atldat       like dpakprtbnfprc.atldat,
                          atlusr       like dpakprtbnfprc.atlusr
                      end record

    define m_consulta_ativa smallint,           
           m_confirma       char(01)

#---------------------------# 
 function ctc20m06_prepare()
#---------------------------# 
     
     define l_sql char(1000)
     
     let l_sql = "select 1 ",
                  " from dpakprtbnfprc ",
                 " where prtbnfprccod = ? "
     
     prepare prctc20m06_01 from l_sql
     declare cqctc20m06_01 cursor for prctc20m06_01
     
     let l_sql = "select 1 ",
                  " from dpakprtbnfprc ",
                 " where prtbnfprcdes = ? "
     
     prepare prctc20m06_02 from l_sql
     declare cqctc20m06_02 cursor for prctc20m06_02     
     
     let l_sql = "insert into dpakprtbnfprc values (?,?,?,?)"
     prepare prctc20m06_03 from l_sql     
     
     let l_sql = "update dpakprtbnfprc ",              
                   " set prtbnfprccod   = ?,",             
                       " prtbnfprcdes   = ?,",  
                       " atldat         = ?,",          
                       " atlusr         = ? ",              
                   " where prtbnfprccod = ? "          
     
     prepare prctc20m06_04 from l_sql
     
     let l_sql = "delete from dpakprtbnfprc where prtbnfprccod = ?"
     
     prepare prctc20m06_06 from l_sql 
     
     let l_sql = "select 1 ",
                  " from dparbnfprt ",
                 " where prtbnfprccod = ? "
     
     prepare prctc20m06_07 from l_sql
     declare cqctc20m06_07 cursor for prctc20m06_07     
     
     

 end function

#-------------------#
 function ctc20m06()
#-------------------#
     
     define l_confirma char(01)

     open window w_ctc20m06 at 4,2 with form "ctc20m06"
          attribute(form line first)

     call ctc20m06_prepare()
     
     let m_consulta_ativa = false
     
     menu "PROCESSOS"

          command key ("C") "Consultar"
                       "Seleciona Processo da Bonificação."
            call ctc20m06_seleciona("")

          command key ("A") "Anterior"
                       "Processo da Bonificação anterior."
            if  m_consulta_ativa  then
                call ctc20m06_paginacao("A")            
            else
                error 'Nenhuma consulta ativa.'
                next option "Consultar"
            end if  
            
          command key ("S") "Seguinte"
                       "Processo da Bonificação seguinte."
            if  m_consulta_ativa  then
                call ctc20m06_paginacao("P")            
            else
                error 'Nenhuma consulta ativa.'
                next option "Consultar"
            end if                       

          command key ("I") "Incluir"
                       "Inclui Processo da Bonificação."
            call ctc20m06_entrada_dados("I")
            
          command key ("M") "Modificar"
                       "Modifica Processo da Bonificação."
            if  m_consulta_ativa  then
                call ctc20m06_entrada_dados("M")            
            else
                error 'Nenhuma consulta ativa.'
                next option "Consultar"
            end if
            
          command key ("X") "eXcluir"
                       "Exclui Processo da Bonificação."
            if  m_consulta_ativa  then
                
                if  mr_entrada.prtbnfprccod is not null and mr_entrada.prtbnfprccod <> " " then
                    call cts08g01("C", "S", "", "DESEJA REALMENTE EXLUIR '", "O PROCESSO SELECINADO?", "") 
                         returning l_confirma
                    
                    if  l_confirma then
                        call ctc20m06_exclui(mr_entrada.prtbnfprccod)
                    else
                        error 'Exclusão cancelada.'
                    end if
                else                                   
                     error 'Nenhum processo ativo.'    
                     next option "Consultar"           
                end if                                     
            else
                error 'Nenhuma consulta ativa.'
                next option "Consultar"
            end if            

          command key (interrupt,E) "Encerra"
                       "Retorna ao menu anterior"
            exit menu

     end menu
     
     close window w_ctc20m06

 end function

#----------------------------------------#
 function ctc20m06_entrada_dados(l_opcao)
#----------------------------------------#

     define lr_retorno record
                           errcod smallint,
                           errmsg char(60)
                       end record

     define lr_prtbnfprccod like dpakprtbnfprc.prtbnfprccod,
            lr_prtbnfprcdes like dpakprtbnfprc.prtbnfprcdes,
            l_confirma      char(01)      

     define l_opcao char(01)
     
     if  l_opcao = 'I' then
         initialize mr_entrada.* to null
         clear form
     end if
     
     let int_flag = false
     
     input by name mr_entrada.prtbnfprccod,
                   mr_entrada.prtbnfprcdes without defaults

         before input
             let lr_prtbnfprccod = mr_entrada.prtbnfprccod
             let lr_prtbnfprcdes = mr_entrada.prtbnfprcdes

         before field prtbnfprccod
             display by name mr_entrada.prtbnfprccod attribute (reverse)

         after field prtbnfprccod
             display by name mr_entrada.prtbnfprccod

             if  mr_entrada.prtbnfprccod is null or
                 mr_entrada.prtbnfprccod = " " then
                 error "O campo do codigo do processo não pode ser nulo."
                 next field prtbnfprccod
             else
                 if  field_touched(prtbnfprccod) then
                     if  l_opcao = "I" then
                         if  ctc20m06_verifica_cod_existe(mr_entrada.prtbnfprccod) then
                             error "Código de processo já cadastrado."
                             
                             let mr_entrada.prtbnfprccod = ""
                             display by name mr_entrada.prtbnfprccod
                             
                             next field prtbnfprccod
                         end if
                     else
                         if  mr_entrada.prtbnfprccod <> lr_prtbnfprccod then
                             if  not ctc20m06_verifica_dependencia(lr_prtbnfprccod) then
                                 if  ctc20m06_verifica_cod_existe(mr_entrada.prtbnfprccod) then
                                     error "Código de processo já cadastrado."
                                     
                                     let mr_entrada.prtbnfprccod = lr_prtbnfprccod
                                     display by name mr_entrada.prtbnfprccod
                                     
                                     next field prtbnfprccod
                                 end if
                             else
                                 call cts08g01("A", "N", "O PROCESSO SELECIONADO NAO PODE", 
                                                         "SER MODIFICADO POIS POSSUI DEPENDENCIAS.", "", 
                                                         "CONSULTE O CADASTRO DE PRESTADORES") 
                                      returning l_confirma
                                 
                                 let mr_entrada.prtbnfprccod = lr_prtbnfprccod
                                 display by name mr_entrada.prtbnfprccod
                             end if
                         end if
                     end if
                 end if
             end if

         before field prtbnfprcdes
             display by name mr_entrada.prtbnfprcdes attribute (reverse)

         after field prtbnfprcdes
             display by name mr_entrada.prtbnfprcdes

             if  mr_entrada.prtbnfprcdes is null or
                 mr_entrada.prtbnfprcdes = " " then
                 error "O campo do codigo do processo não pode ser nulo."
                 next field prtbnfprcdes
             else
                 if  field_touched(prtbnfprcdes) then
                     if  l_opcao = "I" then
                         if  ctc20m06_verifica_des_existe(mr_entrada.prtbnfprcdes) then
                             error "Descrição de processo já cadastrado."
                             
                             let mr_entrada.prtbnfprcdes = "" 
                             display by name mr_entrada.prtbnfprcdes

                             next field prtbnfprcdes
                         end if
                     else
                         if  mr_entrada.prtbnfprcdes <> lr_prtbnfprcdes then
                             if  ctc20m06_verifica_des_existe(mr_entrada.prtbnfprcdes) then
                                 error "Descrição de processo já cadastrado."
                                 
                                 let mr_entrada.prtbnfprcdes = lr_prtbnfprcdes
                                 display by name mr_entrada.prtbnfprcdes

                                 next field prtbnfprcdes
                             end if
                         end if
                     end if
                 end if
             end if
     end input
     
     if  not int_flag then
         
         if  lr_prtbnfprccod is null then
             let lr_prtbnfprccod = " "
             let lr_prtbnfprcdes = " "
         end if

         if  lr_prtbnfprccod <> mr_entrada.prtbnfprccod or 
             lr_prtbnfprcdes <> mr_entrada.prtbnfprcdes then

             let mr_entrada.atldat = current
             let mr_entrada.atlusr = g_issk.funmat
             
             if  l_opcao = "I" then
                 call ctc20m06_insere_tabela(mr_entrada.prtbnfprccod,
                                             mr_entrada.prtbnfprcdes,
                                             mr_entrada.atldat,
                                             mr_entrada.atlusr)
                      returning lr_retorno.errcod,
                                lr_retorno.errmsg
             else
                 if  l_opcao = "M" then
                     call ctc20m06_altera_tabela(lr_prtbnfprccod,
                                                 mr_entrada.prtbnfprccod,
                                                 mr_entrada.prtbnfprcdes,
                                                 mr_entrada.atldat,
                                                 mr_entrada.atlusr)
                          returning lr_retorno.errcod,
                                    lr_retorno.errmsg
                 else
                     let lr_retorno.errmsg =  "Opcao de Menu invalida."
                 end if
             end if
             
             if  lr_retorno.errcod = 0 then
                 call ctc20m06_exibe_dados()
             else
                 display lr_retorno.errmsg
             end if

         end if
         
     end if

 end function

#-----------------------------------------------------#
 function ctc20m06_verifica_cod_existe(l_prtbnfprccod)
#-----------------------------------------------------#

     define l_prtbnfprccod like dpakprtbnfprc.prtbnfprccod,
            l_status       smallint

     open cqctc20m06_01 using l_prtbnfprccod
     fetch cqctc20m06_01 into l_status  

     if  sqlca.sqlcode = 0 then
         return true
     else
         return false
     end if

 end function

#-----------------------------------------------------#
 function ctc20m06_verifica_des_existe(l_prtbnfprcdes)
#-----------------------------------------------------#

     define l_prtbnfprcdes like dpakprtbnfprc.prtbnfprcdes,
            l_status       smallint

     open cqctc20m06_02 using l_prtbnfprcdes
     fetch cqctc20m06_02 into l_status  
     whenever error stop

     if  sqlca.sqlcode = 0 then
         return true
     else
         return false
     end if

 end function
 
#-----------------------------------------# 
 function ctc20m06_insere_tabela(lr_param)
#-----------------------------------------# 
     
     define lr_retorno record
                           errcod smallint,
                           errmsg char(60)
                       end record     

     define lr_param record
                         prtbnfprccod like dpakprtbnfprc.prtbnfprccod,
                         prtbnfprcdes like dpakprtbnfprc.prtbnfprcdes,
                         atldat       like dpakprtbnfprc.atldat,
                         atlusr       like dpakprtbnfprc.atlusr
                     end record
     
     if  lr_param.prtbnfprccod is not null and lr_param.prtbnfprccod <> " " and
         lr_param.prtbnfprcdes is not null and lr_param.prtbnfprcdes <> " " and
         lr_param.atldat       is not null and lr_param.atldat       <> " " and
         lr_param.atlusr       is not null and lr_param.atlusr       <> " " then
         
         execute prctc20m06_03 using lr_param.prtbnfprccod,
                                     lr_param.prtbnfprcdes,
                                     lr_param.atldat,      
                                     lr_param.atlusr
         if  sqlca.sqlcode = 0 then
             let lr_retorno.errcod = 0
             let lr_retorno.errmsg = "Inclusao efetuada com sucesso."
             #let m_consulta_ativa = false
         else
             let lr_retorno.errcod = sqlca.sqlcode                                
             let lr_retorno.errmsg = "Problema na INCLUSAO. ERRO: ", sqlca.sqlcode 
         end if
     else
         let lr_retorno.errcod = 4
         let lr_retorno.errmsg = "Parametros para inclusao invalidos."
     end if

     return lr_retorno.errcod,
            lr_retorno.errmsg     
     
 end function
 
#-----------------------------------------# 
 function ctc20m06_altera_tabela(lr_param)
#-----------------------------------------# 
 
     define lr_retorno record
                           errcod smallint,
                           errmsg char(60)
                       end record      

     define lr_param record
                        prtbnfprccodant like dpakprtbnfprc.prtbnfprccod,
                        prtbnfprccod    like dpakprtbnfprc.prtbnfprccod,
                        prtbnfprcdes    like dpakprtbnfprc.prtbnfprcdes,
                        atldat          like dpakprtbnfprc.atldat,
                        atlusr          like dpakprtbnfprc.atlusr
                    end record
     
     if  lr_param.prtbnfprccodant is not null and lr_param.prtbnfprccodant <> " " and
         lr_param.prtbnfprccod    is not null and lr_param.prtbnfprccod <> " " and
         lr_param.prtbnfprcdes    is not null and lr_param.prtbnfprcdes <> " " and
         lr_param.atldat          is not null and lr_param.atldat       <> " " and
         lr_param.atlusr          is not null and lr_param.atlusr       <> " " then
         
         execute prctc20m06_04 using lr_param.prtbnfprccod,
                                     lr_param.prtbnfprcdes,
                                     lr_param.atldat,      
                                     lr_param.atlusr,
                                     lr_param.prtbnfprccodant
                                     
         if  sqlca.sqlerrd[3] > 0 then
             let lr_retorno.errcod = 0
             let lr_retorno.errmsg = "Alteracao efetuada com sucesso."
             let m_consulta_ativa  = false
         else
             let lr_retorno.errcod = sqlca.sqlcode                                
             let lr_retorno.errmsg = "Problema na ALTERACAO. ERRO: ", sqlca.sqlcode 
         end if
     else
         let lr_retorno.errcod = 4
         let lr_retorno.errmsg = "Parametros para alteracao invalidos."
     end if
     
     return lr_retorno.errcod,
            lr_retorno.errmsg
     
 end function
 
#----------------------------------# 
 function ctc20m06_seleciona(param)
#----------------------------------# 
     
     define param record
                      prtbnfprccod like dpakprtbnfprc.prtbnfprccod
                  end record
     
     define l_clause char(500),
            l_sql    char(1000)
     
     initialize mr_entrada.* to null
     clear form
     
     let int_flag = false
     
     if  param.prtbnfprccod is null then
         construct by name l_clause on prtbnfprccod
     else
         let l_clause = "prtbnfprccod = ", param.prtbnfprccod
     end if
     
     if  not int_flag then
     
         let l_sql = " select prtbnfprccod, ",
                            " prtbnfprcdes, ",
                            " atldat, ",
                            " atlusr ",
                       " from dpakprtbnfprc ", 
                       " where ", l_clause clipped,
                       " order by prtbnfprccod "
                       
         prepare prctc20m06_05 from l_sql                             
         declare cqctc20m06_05 scroll cursor for prctc20m06_05              
                       
         open cqctc20m06_05
         fetch cqctc20m06_05 into mr_entrada.prtbnfprccod, 
                                  mr_entrada.prtbnfprcdes, 
                                  mr_entrada.atldat,       
                                  mr_entrada.atlusr        

         case sqlca.sqlcode 
              when 0
                   call ctc20m06_exibe_dados()
                   let m_consulta_ativa = true
              when 100
                   error 'Nenhum argumento encontrado.'
                   clear form
              otherwise
                   error "Problema na SELECAO. ERRO: ", sqlca.sqlcode 
         end  case       
     else
         error 'Seleção cancelada.'
     end if
     
 end function
 
#-------------------------------#
 function ctc20m06_exibe_dados()
#-------------------------------# 
     
     define lr_retorno record
                           erro     smallint,
                           mensagem char(60),
                           funnom   like isskfunc.funnom
                       end record

     call cty08g00_nome_func(1, mr_entrada.atlusr, 'F')
          returning lr_retorno.erro,    
                    lr_retorno.mensagem,
                    lr_retorno.funnom  
     
     display by name mr_entrada.prtbnfprccod  
     display by name mr_entrada.prtbnfprcdes  
     display by name mr_entrada.atldat        
     display lr_retorno.funnom to funnom
     
     #let m_consulta_ativa = true

 end function
 
#---------------------------------# 
 function ctc20m06_exclui(l_param)
#---------------------------------# 
 
     define l_param    like dpakprtbnfprc.prtbnfprccod
     define l_confirma char(01)
     
     
     if  not ctc20m06_verifica_dependencia(l_param) then
     
         execute prctc20m06_06 using l_param
         
         if  sqlca.sqlcode = 0 then
             error 'Exclusão efetuada com sucesso.'
             clear form
             let m_consulta_ativa = false
             #initialize mr_entrada.* to null
         else
             error "Problema na EXCLUSAO. ERRO: ", sqlca.sqlcode  
         end if
     else
         call cts08g01("A", "N", "O PROCESSO SELECIONADO NAO PODE", 
                                 "SER EXCLUIDO POIS POSSUI DEPENDENCIAS.", "", 
                                 "CONSULTE O CADASTRO DE PRESTADORES") 
              returning l_confirma
     
     end if
          
 end function
 
#----------------------------------# 
 function ctc20m06_paginacao(l_opcao) 
#----------------------------------#
    
    define l_opcao        char(1),
           l_prtbnfprccod like dpakprtbnfprc.prtbnfprccod
    
    define lr_retorno record
                         erro       smallint,
                         mensagem   char(60)
                      end record    
 
    if  l_opcao = "P" then
        #whenever error continue
        #fetch next cqctc20m06_05 into mr_entrada.prtbnfprccod, 
        #                              mr_entrada.prtbnfprcdes, 
        #                              mr_entrada.atldat,       
        #                              mr_entrada.atlusr            
        #whenever error stop
        
        select min (prtbnfprccod)
          into l_prtbnfprccod
          from dpakprtbnfprc
         where prtbnfprccod > mr_entrada.prtbnfprccod

        if  l_prtbnfprccod is null or sqlca.sqlcode = notfound then
            error " Nao ha' mais registros nesta direcao!"
        else
            let  mr_entrada.prtbnfprccod = l_prtbnfprccod
            call ctc20m06_seleciona(mr_entrada.prtbnfprccod)
            call ctc20m06_exibe_dados()
        end if

    else
        #whenever error continue
        #fetch previous cqctc20m06_05 into mr_entrada.prtbnfprccod, 
        #                                  mr_entrada.prtbnfprcdes, 
        #                                  mr_entrada.atldat,       
        #                                  mr_entrada.atlusr                      
        #whenever error stop
        
        select max (prtbnfprccod)                 
          into l_prtbnfprccod                   
          from dpakprtbnfprc                   
         where prtbnfprccod < mr_entrada.prtbnfprccod
        
        if  l_prtbnfprccod is null or sqlca.sqlcode = notfound then
            error " Nao ha' mais registros nesta direcao!"
        else
            let  mr_entrada.prtbnfprccod = l_prtbnfprccod
            call ctc20m06_seleciona(mr_entrada.prtbnfprccod)
            call ctc20m06_exibe_dados()
        end if

    end if

    #if  sqlca.sqlcode = 0 then                           
    #    call ctc20m06_exibe_dados()               
    #else
    #    error 'Nao existem mais dados nessa direção.'
    #end if                                               

 end function  
 
#-----------------------------------------------# 
 function ctc20m06_verifica_dependencia(l_param)
#-----------------------------------------------#

     define l_param  like dpakprtbnfprc.prtbnfprccod,
            l_status smallint
     
     open cqctc20m06_07 using l_param
     fetch cqctc20m06_07 into l_status
     
     if  sqlca.sqlcode = 0 then
         return true
     end if 
     
     return false
     
 end function 
 
 
 
 
 
 
 
 
 
 
 