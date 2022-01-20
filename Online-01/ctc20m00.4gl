{############################################################################
# Nome do Modulo: CTC20M00                                    Sergio Burini #
#                                                                PSI 229784 #
# CADASTRO DE BONIFICAÇÃO.                                         NOV/2008 #
#############################################################################
# ALTERACOES:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------}

database porto

     define mr_entrada record
                           prtbnfcod like dpakprtbnf.prtbnfcod,
                           pstcoddig like dpakprtbnf.pstcoddig,
                           nomgrr    like dpaksocor.nomgrr,
                           srvqtd    like dpakprtbnf.srvqtd,
                           bnfqtd    like dpakprtbnf.bnfqtd,
                           actbnfqtd like dpakprtbnf.actbnfqtd,
                           bnfvlr    like dpakprtbnf.bnfvlr
                       end record
                       
     define where_clause char(1000),
            m_consulta_ativa smallint

#---------------------------#
 function ctc20m00_prepare()
#---------------------------#

     define l_sql char(5000)
     
     let l_sql = "select nomgrr ",
                  " from dpaksocor ",
                 " where pstcoddig = ? "
                 
     prepare pcctc20m00_02 from l_sql              
     declare cqctc20m00_02 cursor for pcctc20m00_02                 

 end function

#-------------------#
 function ctc20m00()
#-------------------#
    
      
     open window w_ctc20m00 at 4,2 with form "ctc20m00"
          attribute(form line first, border)          
     
     options                
        help file "ctc20m00.hlp",
        help key f3           
     
     menu "BONIFICACAO"
     
      command key ("C") "Consultar"
                       "Consulta Bonificação"
        call ctc20m00_seleciona()  
        
     command key ("P") "Proximo"
                   "Bonificacao seguinte."
        if  m_consulta_ativa then
            call ctc20m00_paginacao("P")
        else
            error 'Nenhuma consulta ativa no momento.'
            next option "Consultar"
        end if    
        
      command key ("A") "Anterior"
                   "Bonificacao anterior."
        if  m_consulta_ativa then
            call ctc20m00_paginacao("A")  
        else
            error 'Nenhuma consulta ativa no momento.'
            next option "Consultar"
        end if          
        
           

      {command key ("R") "cRiterios"
                       "Manutencao do Cadastro de Criterios da Bonificacao"
        call ctc20m01()
        
      command key ("G") "Grupo_Servico"
                       "Manutencao do Cadastro de Grupos de Servico"
        call ctc20m02()        
       }
      command key (interrupt,E) "Encerra"
                       "Retorna ao menu anterior"
        exit menu
     end menu        
        
     close window w_ctc20m00
     
 end function
 
#-----------------------------# 
 function ctc20m00_seleciona()
#-----------------------------# 
 
     define where_clause char(1000),
            l_sql        char(5000)
     
     initialize mr_entrada.* to null
     
     let int_flag = false
     let m_consulta_ativa = false
     display by name mr_entrada.prtbnfcod
          attribute(reverse)
     construct by name where_clause on prtbnfcod,
                                       pstcoddig
     
        on key (f3)
           case
              when infield(prtbnfcod)               
                   call showhelp(101)
              when infield(pstcoddig)               
                   call showhelp(102)
           end case
           
     end construct
     
     if  not int_flag then
         
         let l_sql = "select prtbnfcod, ",
                           " pstcoddig, ", 
                           " srvqtd, ", 
                           " bnfqtd, ",
                           " actbnfqtd, ",
                           " bnfvlr ", 
                      " from dpakprtbnf ",
                     " where ", where_clause
         
         prepare pcctc20m00_01 from l_sql              
         declare cqctc20m00_01 scroll cursor for pcctc20m00_01
         
         open  cqctc20m00_01
         fetch cqctc20m00_01 into mr_entrada.prtbnfcod,
                                  mr_entrada.pstcoddig,
                                  mr_entrada.srvqtd,
                                  mr_entrada.bnfqtd,   
                                  mr_entrada.actbnfqtd,
                                  mr_entrada.bnfvlr   
         
         if  sqlca.sqlcode = 0 then
             let m_consulta_ativa = true
             call ctc20m00_exibe_dados()
         else
             if  sqlca.sqlcode = notfound then
                 let m_consulta_ativa = false
                 error "Nenhuma Bonificação selecionada."
                 clear form
             end if
         end if
     end if
 
 end function
 
#-------------------------------#
 function ctc20m00_exibe_dados()
#-------------------------------#
     
     display by name mr_entrada.prtbnfcod  
     display by name mr_entrada.pstcoddig 
     
     open cqctc20m00_02 using mr_entrada.pstcoddig 
     fetch cqctc20m00_02 into mr_entrada.nomgrr

     display by name mr_entrada.srvqtd     
     display by name mr_entrada.bnfqtd     
     display by name mr_entrada.actbnfqtd 
     display by name mr_entrada.bnfvlr     
     
 end function 
 
#----------------------------------# 
 function ctc20m00_paginacao(l_opcao) 
#----------------------------------#
    
    define l_opcao char(1) 
    
    define lr_retorno record
                         erro       smallint,
                         mensagem   char(60)
                      end record    
 
    if  l_opcao = "P" then
        whenever error continue
        fetch next cqctc20m00_01 into mr_entrada.prtbnfcod,                        
                                      mr_entrada.pstcoddig,                         
                                      mr_entrada.srvqtd,                            
                                      mr_entrada.bnfqtd,                            
                                      mr_entrada.actbnfqtd,                         
                                      mr_entrada.bnfvlr         
        whenever error stop
    else
        whenever error continue
        fetch previous cqctc20m00_01 into mr_entrada.prtbnfcod,  
                                          mr_entrada.pstcoddig,  
                                          mr_entrada.srvqtd,     
                                          mr_entrada.bnfqtd,   
                                          mr_entrada.actbnfqtd,
                                          mr_entrada.bnfvlr                       
        whenever error stop
    end if

    if  sqlca.sqlcode = 0 then                           
        call ctc20m00_exibe_dados()               
    else
        error 'Nao existem mais dados nessa direção.'
    end if                                               

 end function 
