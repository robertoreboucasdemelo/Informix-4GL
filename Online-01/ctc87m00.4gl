#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: CTC87M00.4GL                                              #
# ANALISTA RESP..: SERGIO BURINI                                             #
# PSI/OSF........:                                                           #
# OBJETIVO.......: CADASTRO DE ORIENTAÇÃO DE PREENCHIMENTO DE ENDEREÇO.      #
#............................................................................#
# DESENVOLVIMENTO: SERGIO BURINI                                             #
# LIBERACAO......: 18/06/2009                                                #
#............................................................................#
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
#                                                                            #
# -------------------------------------------------------------------------- #

 globals "/homedsa/projetos/geral/globals/glct.4gl"
 
 database porto
 
 define mr_entrada record
     cidnom like datkmpacid.cidnom,
     ufdcod like datkmpacid.ufdcod
 end record
 
 define ma_texto array[100] of record
     prnorntxt like datkprnorntxt.prnorntxt
 end record  
 
 define m_mpacidcod like datkmpacid.mpacidcod,
        m_prnorncod like datkprnorntxt.prnorncod,
        m_alterado  smallint,
        m_consulta  smallint,
        m_opcao     char(01),
        m_count     smallint,
        m_prepare   smallint
 
#---------------------------#
 function ctc87m00_prepare()
#---------------------------#

     define l_sql char(1000)
     
     let l_sql = " select mpacidcod ",
                   " from datkmpacid ",
                  " where cidnom = ? ",     
                    " and ufdcod = ? "            
     
     prepare pcctc87m00_01 from l_sql
     declare cqctc87m00_01 cursor for pcctc87m00_01
     
     let l_sql = " select prnorncod ",
                   " from datkprnorncid ",
                  " where mpacidcod = ? "
     
     prepare pcctc87m00_02 from l_sql
     declare cqctc87m00_02 cursor for pcctc87m00_02 
     
     let l_sql = " select prnorntxt ",
                   " from datkprnorntxt ", 
                  " where prnorncod = ? ",
                  " order by prnorntxtseq "
     
     prepare pcctc87m00_03 from l_sql
     declare cqctc87m00_03 cursor for pcctc87m00_03  
     
     let l_sql = " insert into datkprnorncid values (0,?,'S',?,?)"
     
     prepare pcctc87m00_04 from l_sql
     
     let l_sql = " delete from datkprnorntxt where prnorncod = ? " 
     
     prepare pcctc87m00_05 from l_sql 
     
     let l_sql = " delete from datkprnorncid where prnorncod = ? "
     
     prepare pcctc87m00_06 from l_sql 
     
     let l_sql = " insert into datkprnorntxt values (?,?,?)"
     
     prepare pcctc87m00_07 from l_sql   
     
     let m_prepare = true
 
 end function

#-------------------# 
 function ctc87m00()
#-------------------#
 
     define l_confirma char(01)
     
     if  not m_prepare then
         call ctc87m00_prepare()
     end if
     
     open window w_ctc87m00 at 4,2 with form 'ctc87m00'
       attribute(form line 1) 
     
     menu "ORIENTACAO"
     
         command key ("C") "Consultar" "Consultar uma orientação."
             if  ctc87m00_entrada_dados("C") then
                 let m_consulta = true
                 
                 case m_opcao
                      when "I"
                          error "Inclusão efetuada com sucesso."
                      when "C"
                          error "Consulta efetuada com sucesso."
                      otherwise
                          error "Exclusão efetuada com sucesso."
                 end case
             else
                 let m_consulta = false
                 clear form
                 
                 if  m_opcao = "I" then
                     error "Inclusão cancelada."
                 else
                     error "Consulta cancelada."
                 end if
             end if
             
         command key ("I") "Incluir" "Inclui uma orientação."
             if  ctc87m00_entrada_dados("I") then
                 if  ctc87m00_entrada_dado_array("I") then
                     let m_consulta = true
                     error "Inclusão efetuada com sucesso."
                 else
                     let m_consulta = false
                     error "Inclusão cancelada."
                 end if
             else
                 error "Inclusão cancelada."
             end if                
             
         command key ("X") "eXcluir" "Excluir uma orientação."
             if  m_consulta then
                     
                     call cts08g01("A","S","","CONFIRMA A EXCLUSÃO ",
                                  "DEFINITIVA DO CADASTRO DE .",
                                  "PROCEDIMENTOS?")
                         returning l_confirma
                     
                     if  l_confirma = "S" then
                         if  ctc87m00_excluir() then
                             error "Exclusao efetuada com sucesso."
                         else
                             error "Exclusao cancelada."
                         end if
                     end if           
             else
                 error "Nenhuma consulta ativa."
                 next option "Consultar" 
             end if
     
         command key ("E",interrupt) "Encerra" "Retorna ao menu anterior"
             exit menu    
     
     end menu
     
     close window w_ctc87m00
 
 end function
 
#---------------------------# 
 function ctc87m00_excluir()
#---------------------------#
 
     if  ctc87m00_exclui_tabela_princ() then
         if  ctc87m00_exclui_tabela_texto() then
             clear form
             let m_consulta = false
             let m_opcao    = "E"
             return true
         end if
     end if
     
     return false
 
 end function
 
#----------------------------------------# 
 function ctc87m00_carrega_array(l_opcao)
#----------------------------------------# 
     
     define l_ind    smallint,
            l_opcao  char(01),
            l_status smallint,
            l_cab    char(75)
     
     let l_ind = 1
     initialize ma_texto to null

     open cqctc87m00_03 using m_prnorncod
     
     foreach cqctc87m00_03 into ma_texto[l_ind].prnorntxt
         let l_ind = l_ind + 1
     end foreach 
     
     call set_count(l_ind)
     
     if  l_opcao = "V" then
     
         open window w_ctc87m00a at 08,03 with form 'ctc87m00a'
              attribute(border, form line 1) 
         
         let l_cab = "                 ORIENTAÇÃO DE PREENCHIMENTO DE ENDEREÇO"
         display l_cab to cab attribute (reverse)
         
         call ctc87m00_exibe_teclas("S","S")
         
         display array ma_texto to s_ctc87m00a.*
         
             on key(interrupt,f17,control-c)
                let int_flag = false
                exit display
         
         end display
         
         close window w_ctc87m00a
     else
         call ctc87m00_exibe_teclas("A","S")
         
         display array ma_texto to s_ctc87m00.*
                    
             on key (f3)
                if  l_opcao = "C" then
                    call ctc87m00_entrada_dado_array(l_opcao) 
                      returning l_status
                      exit display
                end if
             
             on key(interrupt,f17,control-c)
                let int_flag = false
                exit display
         
         end display 
     end if

 end function

#----------------------------------------# 
 function ctc87m00_entrada_dados(l_opcao)
#----------------------------------------#

     define lr_retorno record
         erro smallint,
         msg  char(75)
     end record

     define l_confirma char(01),
            l_opcao    char(01),
            l_status   smallint
     
     let m_opcao = l_opcao
     
     let int_flag = false
     initialize ma_texto, mr_entrada.*, lr_retorno.* to null
     clear form
     
     input by name mr_entrada.cidnom,
                   mr_entrada.ufdcod
     
         before input
            call ctc87m00_exibe_teclas("S","S")
         
         before field cidnom
            display by name mr_entrada.cidnom attribute (reverse)
            
         after field cidnom
            display by name mr_entrada.cidnom
            
            if  mr_entrada.cidnom is null or 
                mr_entrada.cidnom = " " then
                error "O campo cidade nao pode ser nulo."
                next field cidnom
            end if
            
         before field ufdcod
            display by name mr_entrada.ufdcod attribute (reverse)
            
         after field ufdcod
            display by name mr_entrada.ufdcod 
            
            if  mr_entrada.ufdcod is null or 
                mr_entrada.ufdcod = " " then
                error "O campo UF nao pode ser nulo."
                next field ufdcod
            end if            
      
            call ctc87m00_verifica_cidade_cadastrada(mr_entrada.cidnom,
                                                     mr_entrada.ufdcod)
                 returning lr_retorno.erro,
                           lr_retorno.msg

            if  lr_retorno.erro = 5 then
                error lr_retorno.msg
                
                call cts06g04(mr_entrada.cidnom, mr_entrada.ufdcod)
                     returning m_mpacidcod, mr_entrada.cidnom, mr_entrada.ufdcod

                next field cidnom
            else
                if  lr_retorno.erro = 0 then
                    if  m_opcao = "I" then
                        call cts08g01("A","S",""," PROCEDIMENTO DE PREENCHIMENTO",
                                      "JÁ CADASTRADO.",
                                      "GOSTARIA DE EXIBI-LO?")
                             returning l_confirma
                        
                        if  l_confirma = "S" then
                            call ctc87m00_carrega_array("C")
                        else
                            let int_flag = true
                            exit input
                        end if
                    else
                        call ctc87m00_carrega_array(l_opcao)
                    end if
                else
                    if  lr_retorno.erro = 100 then
                        let m_prnorncod = ""
                        
                        if  m_opcao = "C" then
                            call cts08g01("A","S","","O PROCEDIMENTO DE PREENCHIMENTO",
                                          "PARA ESTA CIDADE NÃO ESTÁ CADASTRADO.",
                                          "GOSTARIA DE CADASTRA-LA?")
                                 returning l_confirma
                            
                            if  l_confirma = 'S' then
                                if ctc87m00_entrada_dado_array(l_opcao) then
                                   error "Inclusão efetuada com sucesso."
                                end if
                                exit input
                            else
                                next field cidnom
                            end if
                        end if
                    end if
                end if
            end if
            
     end input
     
     call ctc87m00_exibe_teclas("L","N")
      
     if  int_flag then
         return false
     else
         return true
     end if
 
 end function
 
#---------------------------------------------# 
 function ctc87m00_entrada_dado_array(l_opcao)
#---------------------------------------------# 
 
     define l_confirma char(01),
            l_opcao    char(01),
            l_sair     smallint
     
     let m_opcao = l_opcao
     
     if  m_opcao <> "C" then
         initialize ma_texto to null
     end if

     let l_sair = false
     
     while true

         input array ma_texto without defaults from s_ctc87m00.*

             after row
                 let m_count = arr_count()
                 call set_count(m_count)

             before input
                 call ctc87m00_exibe_teclas("C","S")
             
             on key (f8)
                
                if  ctc87m00_verifica_array_vazio() then
                    if  m_opcao = "C" then
                        call cts08g01("A","S","","O PRENCHIMENTO ESTÁ VAZIO.",
                                      " ISSO ELIMINARÁ O REGISTRO DO CADASTRO.",
                                      " CONTINUAR ASSIM MESMO?")
                             returning l_confirma
                             
                        if  l_confirma = "S" then    
                            if  ctc87m00_excluir() then
                                error "Exclusao efetuada com sucesso."
                            end if
                        else
                            continue input
                        end if     
                    else
                        call cts08g01("A","S","","O PROCEDIMENTO DE PREENCHIMENTO ESTÁ VAZIO.",
                                      " ISSO IMPEDE O CADASTRO DO PROCEDIMENTO.",
                                      " CONTINUAR ASSIM MESMO?")
                             returning l_confirma
                    end if
                else
                    call ctc87m00_inclui_tabelas(l_opcao)
                    let m_opcao = "I"
                    call ctc87m00_exibe_teclas("L","N")
                    exit while
                end if
                
                exit while
                
             on key (f5)
                initialize ma_texto to null
                exit input
                
             on key(interrupt,f17,control-c)
                exit while

         end input
         
     end while

     call ctc87m00_exibe_teclas("L","N")
     
     if  not int_flag then
         return true
     else
         return false
     end if
 
 end function
 
#----------------------------------------# 
 function ctc87m00_verifica_array_vazio()
#----------------------------------------#  

     define l_count smallint,
            l_ind   smallint

     let l_count = arr_count()
     
     for l_ind = 1 to l_count 
         if  ma_texto[l_ind].prnorntxt is not null and 
             ma_texto[l_ind].prnorntxt <> " " then
             return false
         end if
     end for
     
     return true

 end function
 
#-----------------------------------------# 
 function ctc87m00_inclui_tabelas(l_opcao)
#-----------------------------------------#

     define l_ind   smallint,
            l_seq   smallint,
            l_count smallint,
            l_curr  like datkprnorncid.atldat,
            l_opcao char(01),
            l_status smallint,
            l_aux     char(75)
     
     let m_opcao = l_opcao

     if  m_prnorncod is null or m_prnorncod = " " then
         
         let l_curr = current
         
         execute pcctc87m00_04 using m_mpacidcod,
                                     g_issk.funmat,
                                     l_curr
         
         if  sqlca.sqlcode = 0 then
             let m_prnorncod = sqlca.sqlerrd[2]
         else
             error "Problema na inclusão do procedimento. pcctc87m00_04 ERRO: ", sqlca.sqlcode
             return false
         end if
         
     end if
     
     if  m_opcao = "C" then
         call ctc87m00_exclui_tabela_texto()
              returning l_status
     end if
     
     let l_seq   = 1
     let m_count = m_count + 1
     
     for l_ind = 1 to m_count
         let l_aux = ma_texto[l_ind].prnorntxt

         if  ma_texto[l_ind].prnorntxt is not null and 
             ma_texto[l_ind].prnorntxt <> " " then

             execute pcctc87m00_07 using m_prnorncod,
                                         l_seq,
                                         ma_texto[l_ind].prnorntxt
             let l_seq = l_seq + 1     
         end if
     end for

 end function
 
#---------------------------------------# 
 function ctc87m00_exclui_tabela_texto()
#---------------------------------------# 
     
     execute pcctc87m00_05 using m_prnorncod
     
     if  sqlca.sqlerrd[3] > 0 then
         return true
     end if
     
     return false
       
 end function
 
#---------------------------------------# 
 function ctc87m00_exclui_tabela_princ()
#---------------------------------------# 
     
     execute pcctc87m00_06 using m_prnorncod
     
     if  sqlca.sqlerrd[3] > 0 then
         return true
     end if
     
     return false
       
 end function 
 
#----------------------------------------------# 
 function ctc87m00_exibe_teclas(l_opcao, l_rev)
#----------------------------------------------#
 
     define l_opcao char(01),
            l_rev   char(01),
            l_obs   char(75)
     
     case l_opcao
          when "C"
               let l_obs = "(F1)Inc. Linha - (F2)Exc. Linha - (F5)Limpa Tela - (F8) Salva - (F17) Sair"
          when "S"
               let l_obs = "(F17) Sair"
          when "A"
               let l_obs = "(F17) Sair - (F3) Alterar"
          otherwise
               let l_obs = ""
     end case
         
     if  l_rev = "S" then
         display l_obs to obs attribute (reverse)
     else
         display l_obs to obs
     end if
 
 end function
 
#---------------------------------------------------#
 function ctc87m00_verifica_cidade_cadastrada(param)
#---------------------------------------------------# 
 
     define param record
         cidnom like datkmpacid.cidnom,
         ufdcod like datkmpacid.ufdcod
     end record
     
     define lr_retorno record
         erro smallint,
         msg  char(75)
     end record

     if  not m_prepare then
         call ctc87m00_prepare()
     end if

     if  (param.cidnom is not null and param.cidnom <> " ") and
         (param.ufdcod is not null and param.ufdcod <> " ") then
     
         open cqctc87m00_01 using param.cidnom,
                                  param.ufdcod
         fetch cqctc87m00_01 into m_mpacidcod
         
         if  sqlca.sqlcode = 0 then
     
             open cqctc87m00_02 using m_mpacidcod
             fetch cqctc87m00_02 into m_prnorncod
             
             case sqlca.sqlcode 
                  when 0                 
                      let lr_retorno.msg = "Orientação encontrada."
                  when 100                    
                      let lr_retorno.msg = "Orientação não encontrada."
                  otherwise                    
                      let lr_retorno.msg = "ERRO ctc87m00 - cqctc87m00_02 : ", sqlca.sqlcode
             end case
             
             let lr_retorno.erro = sqlca.sqlcode
             
         else
             if  sqlca.sqlcode = 100 then
                 let lr_retorno.msg = "Cidade não encontrada."
             else
                 let lr_retorno.msg = "ERRO ctc87m00 - cqctc87m00_01 : ", sqlca.sqlcode
             end if 
             
             let lr_retorno.erro = 5
         end if
     else
         let lr_retorno.erro = 4
         and lr_retorno.msg  = "Parametros invalidos."
     end if
     
     return lr_retorno.erro,
            lr_retorno.msg 
 
 end function
 
#-------------------------------------------------#
 function ctc87m00_orientacao_preenchimento(param)
#-------------------------------------------------#
     
     define param record
         cidnom like datkmpacid.cidnom,
         ufdcod like datkmpacid.ufdcod
     end record
     
     define lr_retorno record
         erro smallint,
         msg  char(75)
     end record     

     call ctc87m00_verifica_cidade_cadastrada(param.cidnom,
                                              param.ufdcod)
          returning lr_retorno.erro,
                    lr_retorno.msg

     if  lr_retorno.erro = 0 then
         call ctc87m00_carrega_array("V")
     end if
    
 end function