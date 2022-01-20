#############################################################################
# Nome do Modulo: CTC20M01                                    Sergio Burini #
#                                                                PSI 229784 #
# CADASTRO DE CRITERIOS DA BONIFICAÇÃO.                            NOV/2008 #
#############################################################################
# ALTERACOES:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#

database porto

    globals "/homedsa/projetos/geral/globals/glct.4gl"

    define mr_entrada record
                          bnfcrtcod like dpakprtbnfcrt.bnfcrtcod,
                          crttip    like dpakprtbnfcrt.crttip,
                          crttipdes char(20),
                          bnfcrtdes like dpakprtbnfcrt.bnfcrtdes,
                          atldat    like dpakprtbnfcrt.atldat,
                          atlusr    like dpakprtbnfcrt.atlusr,
                          funnom    like isskfunc.funnom
                      end record
    
    define m_consulta_ativa smallint,
           m_confirma       char(01)

#---------------------------#
 function ctc20m01_prepare()
#---------------------------#
             
    define l_sql char(1000)
             
    let l_sql = "select 1 ",               
                 " from dpakprtbnfcrt ",   
                " where bnfcrtcod  = ? "   
    
    prepare pcctc20m01_01 from l_sql
    declare cqctc20m01_01 cursor for pcctc20m01_01    
      
    let l_sql = "select 1 ",
                 " from dpakprtbnfcrt ",
                " where bnfcrtdes = ? "
             
    prepare pcctc20m01_02 from l_sql
    declare cqctc20m01_02 cursor for pcctc20m01_02
    
    let l_sql = "insert into dpakprtbnfcrt values (?,?,?,?,?)"
    prepare pcctc20m01_03 from l_sql
    
    let l_sql = "select bnfcrtcod, ",
                      " bnfcrtdes, ",
                      " crttip, ",
                      " atldat, ",
                      " atlusr ",
                 " from dpakprtbnfcrt ",
                " where bnfcrtcod = ? "

    prepare pcctc20m01_04 from l_sql
    declare cqctc20m01_04 scroll cursor for pcctc20m01_04    
    
    let l_sql = "delete from dpakprtbnfcrt where bnfcrtcod = ? "
    prepare pcctc20m01_05 from l_sql
    
    let l_sql = "update dpakprtbnfcrt set bnfcrtdes = ?, atldat = ?, atlusr = ?, crttip = ? where bnfcrtcod = ? "
    prepare pcctc20m01_06 from l_sql
    
    let l_sql = "select bnfcrtdes, ",
                      " crttip, ",
                      " atldat, ",
                      " atlusr ",
                 " from dpakprtbnfcrt ",
                " where bnfcrtcod = ? "
    
    prepare pcctc20m01_07 from l_sql
    declare cqctc20m01_07 cursor for pcctc20m01_07  
    
    let l_sql = "select distinct 1 ", 
                 " from dpakprtbnfgrpcrt ",
                " where bnfcrtcod = ? "
    
    prepare pcctc20m01_08 from l_sql
    declare cqctc20m01_08 cursor for pcctc20m01_08    
    
    let l_sql = "delete from dpakprtbnfgrpcrt where bnfcrtcod = ? "
    
    prepare pcctc20m01_09 from l_sql
    
    let l_sql = "delete from dpakbnfvlrfxa where bnfcrtcod = ? "
    
    prepare pcctc20m01_10 from l_sql    

    let l_sql = "select max(bnfcrtcod) ",
                 " from dpakprtbnfcrt "

    prepare pcctc20m01_11 from l_sql
    declare cqctc20m01_11 scroll cursor for pcctc20m01_11  

 end function

#-------------------#
 function ctc20m01()
#-------------------#

     define l_status smallint
     
     call ctc20m01_prepare()
     
     open window w_ctc20m01 at 4,2 with form "ctc20m01"
          attribute(form line first, border)          
     
     initialize mr_entrada.* to null
     let m_confirma = "N"
     let m_consulta_ativa = false

     menu "CRITERIOS" 
          
          command key ("S") "Selecionar"
                       "Consulta Criterios da Bonificacao."
            call ctc20m01_consulta()
           
          command key ("P") "Proximo"
                       "Proximo Criterio da Bonificacao."
            if  m_consulta_ativa then
                call ctc20m01_proximo()
            else
                error 'Nenhuma consulta ativa no momento.'
                next option "Selecionar"
            end if   
            
          command key ("A") "Anterior"
                       "Criterios da Bonificacao anterior."
            if  m_consulta_ativa then
                call ctc20m01_anterior()  
            else
                error 'Nenhuma consulta ativa no momento.'
                next option "Selecionar"
            end if          
            
          command key ("I") "Incluir"
                       "Inclui Criterios da Bonificacao."
            call ctc20m01_incluir()  
            
          command key ("X") "eXcluir"
                       "Exclui Criterios da Bonificacao."
            if  m_consulta_ativa then
                call cts08g01("C","F"                               
                              ,"","CONFIRMA A EXCLUSAO DO CRITERIO","SELECIONADO ?","")     
                returning m_confirma                             
                                                                  
                if  m_confirma = "S" then                         
                    
                    open cqctc20m01_08 using mr_entrada.bnfcrtcod 
                    fetch cqctc20m01_08 into l_status
                    
                    if  sqlca.sqlcode = 0 then
                        let m_confirma = "N"
                        call cts08g01("C","F",                                                  
                                      "EXISTEM RELACIONAMENTO PARA ESSE",
                                      "CRITERIO. A EXCLUSAO CONSEQUENTEMENTE",
                                      "ELIMINARA ESSES REGISTROS.",
                                      "CONTINUAR ASSIM MESMO ?")
                        returning m_confirma 
                        
                        if  m_confirma = "S" then
                            execute pcctc20m01_09 using mr_entrada.bnfcrtcod
                            
                            if  sqlca.sqlcode <> 0 then
                                error "Erro execute pcctc20m01_09 : ", sqlca.sqlcode
                            end if
                            
                            execute pcctc20m01_10 using mr_entrada.bnfcrtcod
                            
                            if  sqlca.sqlcode <> 0 then
                                error "Erro execute pcctc20m01_10 : ", sqlca.sqlcode
                            end if

                        end if                                                                     
                    end if
                    
                    if  m_confirma = "S" then 
                        call ctc20m01_excluir()
                    end if                                    
                end if 
            else
                error 'Nenhuma consulta ativa no momento.'
                next option "Selecionar"
            end if      
            
          command key ("M") "Modificar"
                       "Exclui Criterios da Bonificacao."
            if  m_consulta_ativa then
                call ctc20m01_modificar()
            else
                error 'Nenhuma consulta ativa no momento.'
                next option "Selecionar"
            end if             
           
          command key (interrupt,E) "Encerra"
                       "Retorna ao menu anterior"
            exit menu
     end menu              

     close window w_ctc20m01
     
 end function
 
#----------------------------# 
 function ctc20m01_incluir()
#----------------------------# 
     
     define lr_retorno record
                           erro       smallint,
                           mensagem   char(60)
                       end record

     let int_flag = false
     
     initialize mr_entrada.* to null
     clear form
     
     let m_consulta_ativa = false
     
     input by name mr_entrada.bnfcrtcod,
                   mr_entrada.crttip,
                   mr_entrada.bnfcrtdes without defaults
     
         before field bnfcrtcod
            next field crttip
         
         
         before field crttip
            display by name mr_entrada.crttip attribute(reverse)
         
         after field  crttip
            display by name mr_entrada.crttip         
            if  mr_entrada.crttip is not null and
                mr_entrada.crttip <> " " then
                display by name mr_entrada.crttip
            else
                    call ctc20m01_popup_tipos()
                         returning mr_entrada.crttip, mr_entrada.crttipdes
                    display by name mr_entrada.crttipdes 
                    next field crttip   
            end if
            case mr_entrada.crttip
                when 'A'
                     let mr_entrada.crttipdes = 'ADICIONAL'
                when 'P'
                     let mr_entrada.crttipdes = 'PERCENTUAL'
                when 'C'
                     let mr_entrada.crttipdes = 'CREDENCIAL'                     
                otherwise
                     let mr_entrada.crttipdes = ""
                     let mr_entrada.crttip    = ""
                     error 'Tipo de criterio invalido.'
                     next field crttip
            end case
            
            display by name mr_entrada.crttipdes
            
         before field bnfcrtdes                                                
            display by name mr_entrada.bnfcrtdes attribute(reverse)            
            
         after field  bnfcrtdes
            display by name mr_entrada.bnfcrtdes
            
            if  mr_entrada.bnfcrtdes is null or
                mr_entrada.bnfcrtdes = " " then
                error "Descricao do Criterio deve ser informado."
                next field bnfcrtdes
            else            
                if  ctc20m01_existe_desc(mr_entrada.bnfcrtdes) then
                    error "Descrição do Criterio já cadastrado"
                    next field bnfcrtdes
                else
                    open cqctc20m01_11
                    fetch cqctc20m01_11 into mr_entrada.bnfcrtcod
                    
                    if  sqlca.sqlcode = notfound or
                        mr_entrada.bnfcrtcod  is null or
                        mr_entrada.bnfcrtcod  = " " then
                        let mr_entrada.bnfcrtcod  = 0
                    end if
     
                    let  mr_entrada.bnfcrtcod = mr_entrada.bnfcrtcod  + 1
                    display by name mr_entrada.bnfcrtcod 
                end if
            end if

            
     end input
     
     if  not int_flag then
         let mr_entrada.atldat = current
         let mr_entrada.atlusr = g_issk.funmat
         
         execute pcctc20m01_03 using mr_entrada.bnfcrtcod,
                                     mr_entrada.bnfcrtdes,
                                     mr_entrada.atldat,
                                     mr_entrada.atlusr,
                                     mr_entrada.crttipdes
                                     
         if  sqlca.sqlcode = 0 then
             call ctc20m01_exibe_dados()  
             let m_consulta_ativa = true             
         end if
     else
         error "Inclusão Criterio de Bonificação cancelada."
         clear form
     end if     

 end function 
 
#---------------------------# 
 function ctc20m01_excluir()
#---------------------------# 
 
     execute pcctc20m01_05 using mr_entrada.bnfcrtcod
     
     if  sqlca.sqlcode <> 0 then
         error 'Problema no DELETE da tabela dpakprtbnfcrt : ', sqlca.sqlcode
     else
         let m_consulta_ativa = false
         initialize mr_entrada.* to null
         clear form
     end if

 end function
 
#----------------------------# 
 function ctc20m01_modificar()
#----------------------------# 
 
     define lr_retorno record
                           erro       smallint,
                           mensagem   char(60)
                        end record

     define l_bnfcrtdes like dpakprtbnfcrt.bnfcrtdes,
            l_crttip    like dpakprtbnfcrt.crttip

     let l_bnfcrtdes = mr_entrada.bnfcrtdes
     let l_crttip    = mr_entrada.crttip
     let int_flag = false
     
     if  mr_entrada.bnfcrtcod is not null or           
         mr_entrada.bnfcrtcod <> " " or not m_consulta_ativa then 
     
         input by name mr_entrada.crttip, 
                       mr_entrada.bnfcrtdes without defaults
     
             before field crttip
                display by name mr_entrada.crttip attribute (reverse)
         
             after field crttip
                display by name mr_entrada.crttip         
                if  mr_entrada.crttip is not null and
                    mr_entrada.crttip <> " " then
                    display by name mr_entrada.crttip
                else
                    call ctc20m01_popup_tipos()
                        returning mr_entrada.crttip, mr_entrada.crttipdes
                    display by name mr_entrada.crttipdes 
                    next field crttip   
                end if 
                case mr_entrada.crttip
                    when 'A'
                         let mr_entrada.crttipdes = 'ADICIONAL'
                    when 'P'
                         let mr_entrada.crttipdes = 'PERCENTUAL'
                    when 'C'
                         let mr_entrada.crttipdes = 'CREDENCIAL'                     
                    otherwise
                         let mr_entrada.crttipdes = ""
                         let mr_entrada.crttip    = ""
                         display by name mr_entrada.crttipdes
                         display by name mr_entrada.crttip   
                         error 'Tipo de criterio invalido.'
                         next field crttip
                end case
            
                display by name mr_entrada.crttipdes

             before field bnfcrtdes
                display by name mr_entrada.bnfcrtdes attribute (reverse)
         
             after field bnfcrtdes
                display by name mr_entrada.bnfcrtdes
                
                if  not int_flag then
                    if  l_bnfcrtdes <> mr_entrada.bnfcrtdes or
                        l_crttip    <> mr_entrada.crttip then
                        let mr_entrada.atldat = current
                        let mr_entrada.atlusr = g_issk.funmat
                    
                        execute pcctc20m01_06 using mr_entrada.bnfcrtdes,
                                                    mr_entrada.atldat,
                                                    mr_entrada.atlusr, 
                                                    mr_entrada.crttip,
                                                    mr_entrada.bnfcrtcod
                
                        call ctc20m01_exibe_dados()                
                    end if
                else
                    error "Modificação Criterio de Bonificação cancelada."
                    clear form
                end if
     
         end input
     end if
 end function 
 
#-----------------------------# 
 function ctc20m01_consulta() 
#-----------------------------# 
     
      define lr_retorno record
                           erro       smallint,
                           mensagem   char(60)
                        end record

     
                
     let int_flag = false
     
     initialize mr_entrada.* to null
     
     clear form
     
     input by name mr_entrada.bnfcrtcod without defaults

         after field bnfcrtcod 
         
             if  mr_entrada.bnfcrtcod is null or  
                 mr_entrada.bnfcrtcod = " " then
                 
                 select min(bnfcrtcod)
                   into mr_entrada.bnfcrtcod
                   from dpakprtbnfcrt
                   
                 if  sqlca.sqlcode = notfound then
                     error 'Nenhum criterio selecionado.'
                 end if 
                 exit input
             end if
     end input
     
     if  not int_flag   then
         
         open cqctc20m01_04 using mr_entrada.bnfcrtcod
         fetch cqctc20m01_04 into mr_entrada.bnfcrtcod, 
                                  mr_entrada.bnfcrtdes,
                                  mr_entrada.crttip,
                                  mr_entrada.atldat,    
                                  mr_entrada.atlusr
         
         if  sqlca.sqlcode = 0 then
             call ctc20m01_exibe_dados()
             let m_consulta_ativa = true
         else
             error 'Nenhum Criterio de bonificação encontrado.'
             let m_consulta_ativa = false
             clear form
         end if
     else    
         error "Consulta Criterio de Bonificação cancelada."
         clear form                                           
     end if
     
 end function
 
#----------------------------# 
 function ctc20m01_anterior()
#----------------------------#

    define l_bnfcrtcod like dpakprtbnfcrt.bnfcrtcod
    
    select max (bnfcrtcod)
      into l_bnfcrtcod
      from dpakprtbnfcrt
     where bnfcrtcod < mr_entrada.bnfcrtcod

    if  l_bnfcrtcod is not null then
        let mr_entrada.bnfcrtcod = l_bnfcrtcod
        
        open cqctc20m01_07 using mr_entrada.bnfcrtcod
        fetch cqctc20m01_07 into mr_entrada.bnfcrtdes,
                                 mr_entrada.crttip,
                                 mr_entrada.atldat,
                                 mr_entrada.atlusr
        
        call ctc20m01_exibe_dados()
    end if
    
    if  l_bnfcrtcod is null or sqlca.sqlcode = notfound then
        error " Nao ha' mais registros nesta direcao!"
    end if    
    
 end function
 
#---------------------------#
 function ctc20m01_proximo()
#---------------------------#

    define l_bnfcrtcod like dpakprtbnfcrt.bnfcrtcod
    
    select min (bnfcrtcod)
      into l_bnfcrtcod
      from dpakprtbnfcrt
     where bnfcrtcod > mr_entrada.bnfcrtcod
     
     if l_bnfcrtcod is not null then
        let mr_entrada.bnfcrtcod = l_bnfcrtcod
        
        open cqctc20m01_07 using mr_entrada.bnfcrtcod
        fetch cqctc20m01_07 into mr_entrada.bnfcrtdes,
                                 mr_entrada.crttip,
                                 mr_entrada.atldat,
                                 mr_entrada.atlusr

       call ctc20m01_exibe_dados()
     end if
     
     if l_bnfcrtcod is null or sqlca.sqlcode = notfound then
        error " Nao ha' mais registros nesta direcao!"
     end if

 end function 
 

     
#-----------------------------------#
 function ctc20m01_existe_desc(lr_param)    
#-----------------------------------#     
 
     define lr_param record
                         bnfcrtdes like dpakprtbnfcrt.bnfcrtdes
                     end record
                     
     define l_aux smallint
 
     open cqctc20m01_02 using lr_param.bnfcrtdes
     fetch cqctc20m01_02 into l_aux
     
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
 function ctc20m01_existe_cod(lr_param)    
#-----------------------------------#     
 
     define lr_param record
                         bnfcrtcod like dpakprtbnfcrt.bnfcrtcod
                     end record
                     
     define l_aux smallint
 
     open cqctc20m01_01 using lr_param.bnfcrtcod
     fetch cqctc20m01_01 into l_aux
     
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
 function ctc20m01_exibe_dados()    
#-------------------------------#     
  
     define lr_retorno record
                          erro       smallint,
                          mensagem   char(60)
                       end record        

     display by name mr_entrada.bnfcrtcod             
     display by name mr_entrada.bnfcrtdes             
     display by name mr_entrada.atldat                
                                                      
     call cty08g00_nome_func(1,mr_entrada.atlusr,'F') 
          returning lr_retorno.erro,                  
                    lr_retorno.mensagem,              
                    mr_entrada.funnom                 
                                                      
     display by name mr_entrada.funnom  
     
     case mr_entrada.crttip                            
         when 'A'                                      
              let mr_entrada.crttipdes = 'ADICIONAL'   
         when 'P'                                      
              let mr_entrada.crttipdes = 'PERCENTUAL'  
         when 'C'                                      
              let mr_entrada.crttipdes = 'CREDENCIAL'                    
     end case                                          
                                                       
     display by name mr_entrada.crttip
     display by name mr_entrada.crttipdes

 end function
     

#-------------------------------#
 function ctc20m01_popup_tipos()    
#-------------------------------# 

     define ag_tipos array[3] of record
            campo     char(1), 
            crttip    like dpakprtbnfcrt.crttip,
            crttipdes char(20)
     end record
     
     define l_ind, l_cur, l_src, l_aux, l_i smallint
     define l_titulo char(50)
     
     let  l_titulo   = 'TIPOS DE CRITERIO'
     let  l_aux      = length(l_titulo)
     let  l_aux      = (52 - l_aux) / 02

     for  l_i = 1 to l_aux
          let  l_titulo = ' ', l_titulo clipped
     end  for
     

     open window w_popup_t at 9,2 with form "ctc20m01_p"   
          attribute(border,
                    white,
                    form    line 01,
                    message line last,
                    comment line last - 01)
          
          let l_ind = 0
          initialize ag_tipos to null
     
          let ag_tipos[1].campo = ' '
          let ag_tipos[1].crttip = 'A'
          let ag_tipos[1].crttipdes = 'ADICIONAL'
          let ag_tipos[2].campo = ' '
          let ag_tipos[2].crttip = 'C'
          let ag_tipos[2].crttipdes = 'CREDENCIAL'
          let ag_tipos[3].campo = ' '
          let ag_tipos[3].crttip = 'P'
          let ag_tipos[3].crttipdes = 'PERCENTUAL'
          {call set_count(3)
          display array ag_tipos to s_p_tipos.*
               
               on key(f8)
                    let l_ind = arr_curr()
                    display 'l_ind = ', l_ind
                    exit display
          end display
          
    
          
          if int_flag then
               let int_flag = false
          end if}
          
          
         call set_count(3)
               input array ag_tipos without defaults from s_p_tipos.*
         
                  before input
                       display l_titulo to titulo
                           attribute(reverse) 
                       display 'CODIGO' to codigo 
                       display 'DESCRICAO' to descricao 
                           
                  before row 
                       let l_cur = arr_curr()
                       let l_src = scr_line()
                       let l_aux = l_src + 04
                       
                  before field crttip
                       next field campo
                  
                  before field crttipdes
                       next field campo
                       
                  before field campo
                       display ag_tipos[l_cur].* to s_p_tipos[l_src].* 
                           attribute(reverse) 
                       display " " at l_aux,03 attribute(reverse)
                       display " " at l_aux,15 attribute(reverse)
                  
                  after field campo
                       display ag_tipos[l_cur].* to s_p_tipos[l_src].* 
                       display " " at l_aux,03
                       display " " at l_aux,15
                       
                  on key (f8)
                       let l_ind = arr_curr()
                       exit input
                     
               end input
               
          
     close window w_popup_t
     
     if int_flag then
          let int_flag = false
          return "",""
     else
          return ag_tipos[l_ind].crttip, ag_tipos[l_ind].crttipdes
     end if

end function    
