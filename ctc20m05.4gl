#############################################################################
# Nome do Modulo: CTC20M05                                    Sergio Burini #
#                                                                PSI 229784 #
# CADASTRO DE VALORES DE FAIXAS.                                   NOV/2008 #
#############################################################################
# ALTERACOES:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#

database porto

     globals "/homedsa/projetos/geral/globals/glct.4gl"

     define mr_entrada record
                           prtbnfgrpcod like dpakbnfvlrfxa.prtbnfgrpcod,
                           bnffxacod    like dpakbnfvlrfxa.bnffxacod,
                           bnfcrtcod    like dpakbnfvlrfxa.bnfcrtcod,
                           minper       like dpakbnfvlrfxa.minper,
                           maxper       like dpakbnfvlrfxa.maxper,
                           fxavlr       like dpakbnfvlrfxa.fxavlr,
                           atldat       like dpakbnfvlrfxa.atldat,
                           atlusr       like dpakbnfvlrfxa.atlusr,
                           fxaseq       like dpakbnfvlrfxa.fxaseq,
                           prtbnfprccod like dpakbnfvlrfxa.prtbnfprccod,
                           funnom       like isskfunc.funnom
                       end record
                       
      define ma_entrada array[200] of record
                          minper like dpakbnfvlrfxa.minper,
                          maxper like dpakbnfvlrfxa.maxper,  
                          fxavlr like dpakbnfvlrfxa.fxavlr,
                          atldat like dpakbnfvlrfxa.atldat,
                          funnom like isskfunc.funnom 
                      end record 
      
      define mr_entrada_ant record
                          minper like dpakbnfvlrfxa.minper,
                          maxper like dpakbnfvlrfxa.maxper,  
                          fxavlr like dpakbnfvlrfxa.fxavlr,
                          atldat like dpakbnfvlrfxa.atldat,
                          funnom like isskfunc.funnom 
                      end record 
                                   
                      
     define mr_param record 
                          prtbnfgrpdes like dpaksrvgrp.prtbnfgrpdes,
                          bnfcrtdes like dpakprtbnfcrt.bnfcrtdes
                      end record
                            
     define m_crttip      char(01),
            m_flag_insert smallint,
            m_cur         smallint,
            m_src         smallint
     
     define m_confirma char(01)     

#---------------------------#
 function ctc20m05_prepare()
#---------------------------#

     define l_sql char(1000)

     let l_sql = "select * ",
                  " from dpakbnfvlrfxa ",
                 " where prtbnfgrpcod = ? ",
                   " and bnfcrtcod    = ? "

     prepare pctc20m05_01 from l_sql
     declare cctc20m05_01 cursor for pctc20m05_01

     let l_sql = "select crttip ",
                  " from dpakprtbnfcrt ",
                 " where bnfcrtcod = ? "

     prepare pctc20m05_02 from l_sql
     declare cctc20m05_02 cursor for pctc20m05_02

     let l_sql = "insert into dpakbnfvlrfxa values(?,?,?,?,?,?,?,?,?,?)"

     prepare pctc20m05_03 from l_sql

     let l_sql = "select bnffxacod ",
                  " from dpakbnfvlrfxa ",
                 " where prtbnfgrpcod = ? ",
                   " and bnfcrtcod    = ? "

     prepare pctc20m05_04 from l_sql
     declare cctc20m05_04 cursor for pctc20m05_04

     let l_sql = "select max(bnffxacod) ",
                  " from dpakbnfvlrfxa "

     prepare pctc20m05_05 from l_sql
     declare cctc20m05_05 cursor for pctc20m05_05

     let l_sql = "select max(fxaseq) ",
                  " from dpakbnfvlrfxa ",
                 " where prtbnfgrpcod = ? ",
                   " and bnfcrtcod    = ? "

     prepare pctc20m05_06 from l_sql
     declare cctc20m05_06 cursor for pctc20m05_06

     let l_sql = "select minper, ",
                       " maxper ",
                  " from dpakbnfvlrfxa ",
                 " where bnfcrtcod    = ? ",
                   " and prtbnfgrpcod = ? ",
                   " and ( ? between minper and maxper ",
                   "  or ? between minper and maxper) "
                   
     prepare pctc20m05_07 from l_sql
     declare cctc20m05_07 cursor for pctc20m05_07

     let l_sql = "select minper, ",
                       " maxper, ",
                       " fxavlr, ",
                       " atlusr, ",
                       " atldat ",
                  " from dpakbnfvlrfxa ",
                 " where prtbnfgrpcod  = ? ",
                   " and bnfcrtcod     = ? ",
                 "order by minper"
                 
     prepare pctc20m05_08 from l_sql
     declare cctc20m05_08 scroll cursor for pctc20m05_08

     let l_sql = "delete from dpakbnfvlrfxa where bnffxacod = ? and fxaseq = ? "
     prepare pctc20m05_09 from l_sql
     
         
      let l_sql = "select distinct 1 ",
                  "  from dpakbnfvlrfxa ",
                  "where prtbnfgrpcod  = ? ",
                   " and bnfcrtcod     = ? ",
                   " and minper     = ? ",
                   " and maxper        = ? ",
                   " and fxavlr        = ? "
      prepare pctc20m05_10 from l_sql
      declare cctc20m05_10 scroll cursor for pctc20m05_10
      
      let l_sql = "update dpakbnfvlrfxa ",
		        "set minper = ?, ",
                  "    maxper = ?, ",
                  "    fxavlr = ?, ",
                  "    atlusr = ?, ",
                  "    atldat = ? ",
		        "where prtbnfgrpcod  = ? ",
                  "  and bnfcrtcod     = ? ",
                  "  and bnffxacod     = ? ",
                  "  and fxaseq        = ? "
		
      prepare pctc20m05_11 from l_sql
      
      let l_sql = "delete from dpakbnfvlrfxa ",
                  "where prtbnfgrpcod  = ? ",
                   " and bnfcrtcod     = ? ",
                   " and minper     = ? ",
                   " and maxper        = ? ",
                   " and fxavlr        = ? "
      prepare pcctc20m05_12 from l_sql
      
      let l_sql = "select bnffxacod, ",
                       " fxaseq ",
                  "  from dpakbnfvlrfxa ",
                  "where prtbnfgrpcod  = ? ",
                   " and bnfcrtcod     = ? ",
                   " and minper     = ? ",
                   " and maxper        = ? ",
                   " and fxavlr        = ? "
      prepare pctc20m05_13 from l_sql
      declare cctc20m05_13 scroll cursor for pctc20m05_13
      
 end function

#------------------------#
 function ctc20m05(param)
#------------------------#

     define param record
                     prtbnfgrpcod like dpakbnfvlrfxa.prtbnfgrpcod,
                     prtbnfgrpdes like dpaksrvgrp.prtbnfgrpdes,
                     bnfcrtcod    like dpakbnfvlrfxa.bnfcrtcod,
                     bnfcrtdes like dpakprtbnfcrt.bnfcrtdes
                  end record
     
     define lr_retorno record
                           erro       smallint,
                           mensagem   char(60)
                       end record
     
     define l_minper decimal,
            l_maxper decimal
            
     define l_flag_minper smallint,
            l_flag_novo   smallint, 
            l_flag_insert smallint,
            l_flag_maxper smallint,
            l_arr_count   smallint
     
     define l_tecla   smallint
     
     initialize mr_entrada.*, ma_entrada to null

     let mr_entrada.prtbnfgrpcod = param.prtbnfgrpcod
     let mr_entrada.bnfcrtcod    = param.bnfcrtcod

     let mr_param.prtbnfgrpdes = param.prtbnfgrpdes
     let mr_param.bnfcrtdes    = param.bnfcrtdes

     call ctc20m05_prepare()

     open window w_ctc20m05 at 4,2 with form "ctc20m05"
          attribute(form line first)
     
		
     let int_flag = false
     let l_flag_insert = false
     while true
         call ctc20m05_carrega_array() 
         
         input array ma_entrada without defaults from s_ctc20m05.*
         
             before input 
                  display mr_param.prtbnfgrpdes to grupo 
                  display mr_param.bnfcrtdes to criterio 
             
             before row 
                let m_cur = arr_curr()
                let m_src = scr_line()
                
                let l_flag_minper = false
                let l_flag_maxper = false
             
             before insert 
                 let l_arr_count = arr_count()
                 if l_arr_count > 200 then
                     error "O numero de registros ultrapassou o tamanho do array. Favor contatar a informatica"
                 end if
                 if fgl_lastkey() = 2014 then
                     let l_flag_insert = true
                 end if
             
             before delete
                let l_flag_insert = false    
                call cts08g01("C","F"                                                   
                         ,"","CONFIRMA A EXCLUSAO DO VALOR","SELECIONADO ?","") 
                   returning m_confirma                                                                              
                if  m_confirma = "S" then 
                   call ctc20m05_excluir()
                   next field minper
                else    
                   exit input
                end if
                
             before field minper
                let l_flag_minper = false
                let l_flag_maxper = false
                let l_flag_novo = true
                initialize mr_entrada_ant.* to null
                if  (ma_entrada[m_cur].minper is not null and
                     ma_entrada[m_cur].minper <> " " ) or
                     l_flag_insert then
                     let l_flag_novo = false
                     let mr_entrada_ant.* = ma_entrada[m_cur].*
                     
                end if
            
             after field minper
                    if fgl_lastkey() == fgl_keyval("LEFT") and
                       l_flag_novo = false then
                         next field minper
                    end if
                    if l_flag_novo = false and 
                      (mr_entrada_ant.minper <> ma_entrada[m_cur].minper or
                      (ma_entrada[m_cur].minper is null or
                       ma_entrada[m_cur].minper = " ")) and
                       l_flag_insert = false then
                     
                       error "Para inserir Pressione <F1>"
                       let ma_entrada[m_cur].* = mr_entrada_ant.*
                       next field minper
                    end if
                    
                    if  ma_entrada[m_cur].minper is not null and
                        ma_entrada[m_cur].minper <> " " then
                        if  field_touched(minper) then
                            let l_flag_minper = true
                            if fgl_lastkey() == fgl_keyval("UP") or
                               fgl_lastkey() == fgl_keyval("DOWN") or
                               fgl_lastkey() == fgl_keyval("LEFT") and
                               l_flag_novo then
                               let l_flag_insert = true
                               next field maxper
                            end if 
                            if  ma_entrada[m_cur].minper > 100 or ma_entrada[m_cur].minper < 0 then
                                let ma_entrada[m_cur].minper = ""
                                display ma_entrada[m_cur].minper to s_ctc20m05[m_src].minper
                                error "Percentual inválido"
                                next field minper
                            end if
                        end if
                    else
                        if  fgl_lastkey() == fgl_keyval("up") and l_flag_insert = false then   
                        else
                            error "O percentual minimo deve ser informado."
                            next field minper
                        end if
                    end if          
             
             before field maxper
                 if l_flag_novo = false and l_flag_insert = false then
                     next field fxavlr
                 end if
             
             after field maxper                                                                              
                    let l_flag_insert = true
                    if  ma_entrada[m_cur].maxper is not null and                                                        
                        ma_entrada[m_cur].maxper <> " " then                                                            
                        
                        if  field_touched(maxper) then
                            let l_flag_maxper = true
                            if  ma_entrada[m_cur].maxper > 100 or ma_entrada[m_cur].maxper < 0 then                                
                                let ma_entrada[m_cur].maxper = ""                                                           
                                display ma_entrada[m_cur].maxper to s_ctc20m05[m_src].maxper                                                  
                                error "Percentual inválido"                                                          
                                next field maxper                                                                    
                            else                                                                                     
                                if  ma_entrada[m_cur].minper > ma_entrada[m_cur].maxper then                                       
                                    error "O valor minimo nao deve ser maior do que o valor maximo."                 
                                    next field minper                                                                
                                end if                                                                               
                            end if                                                                                   
                                                                                                                     
                            open cctc20m05_07 using mr_entrada.bnfcrtcod,                                            
                                                    mr_entrada.prtbnfgrpcod,                                         
                                                    ma_entrada[m_cur].minper,                                               
                                                    ma_entrada[m_cur].maxper                                                
                            fetch cctc20m05_07 into l_minper,                                                        
                                                    l_maxper                                                         
                                                                                                                     
                            if  sqlca.sqlcode = 0 then                                                               
                                error "Faixa já existente: ", l_minper, " a ", l_maxper                           
                                next field minper                                                                    
                            end if    
                        end if                                                                               
                                                                                                                 
                    else  
                        if  fgl_lastkey() == fgl_keyval("LEFT") then
                            next field minper  
                        else                                                                                       
                            error "O percentual minimo deve ser informado."                                          
                            next field maxper  
                            
                        end if                                                                      
                    end if 
                
             after field fxavlr  
                    if  fgl_lastkey() == fgl_keyval("LEFT") then
                        if l_flag_insert or l_flag_novo then
                             let l_flag_insert = true
                             next field maxper
                        else
                             let l_flag_insert = false
                             next field minper 
                        end if
                    else
                        if fgl_lastkey() == fgl_keyval("UP") or
                           fgl_lastkey() == fgl_keyval("DOWN") then
                           next field fxavlr
                        end if 
                    end if        
                    if  ma_entrada[m_cur].fxavlr is not null and
                        ma_entrada[m_cur].fxavlr <> " " then
                        if  ma_entrada[m_cur].fxavlr < 0 then
                            error 'O campo valor deve ser maior que zero.' 
                            next field fxavlr
                        else
                            if  l_flag_minper or
                                l_flag_maxper or 
                                field_touched(fxavlr) then
                                if l_flag_novo or l_flag_insert then
                                    call ctc20m05_incluir()
                                else
                                    call ctc20m05_alterar()
                                end if 
                                call cty08g00_nome_func(1, g_issk.usrcod, 'F')
                                      returning lr_retorno.erro,
                                                lr_retorno.mensagem,
                                                ma_entrada[m_cur].funnom
                                display ma_entrada[m_cur].fxavlr to s_ctc20m05[m_src].fxavlr
                                display ma_entrada[m_cur].atldat to s_ctc20m05[m_src].atldat
                                display ma_entrada[m_cur].funnom to s_ctc20m05[m_src].funnom
                                let l_flag_insert = false
                            end if
                        end if 
                        
                    else
                        error 'O campo valor deve ser informado.'
                        next field fxavlr
                    end if

         end input
         
         if  int_flag then
             let int_flag = false
             exit while
         end if
                  
     end while

     
     close window w_ctc20m05

 end function

#---------------------------#
 function ctc20m05_excluir()
#---------------------------#
     define l_status smallint,
            l_flag smallint
     let l_flag = false
     open cctc20m05_10 using mr_entrada.prtbnfgrpcod,
                             mr_entrada.bnfcrtcod,
                             mr_entrada_ant.minper,
                             mr_entrada_ant.maxper,
                             mr_entrada_ant.fxavlr
                             
     fetch cctc20m05_10 into l_status
     
     if  sqlca.sqlcode = 0 then
         let l_flag = true
     end if
     if  l_flag then
         execute pcctc20m05_12 using mr_entrada.prtbnfgrpcod,
                                     mr_entrada.bnfcrtcod,
                                     mr_entrada_ant.minper,
                                     mr_entrada_ant.maxper,
                                     mr_entrada_ant.fxavlr
     else 
         error "Registro nao encontrado para a exclusao!"
     end if
 end function

#---------------------------#
 function ctc20m05_alterar()
#---------------------------#
     define l_status smallint,
            l_flag smallint,
            l_bnffxacod smallint,
            l_fxaseq smallint
     let l_flag = false
     
     open cctc20m05_13 using mr_entrada.prtbnfgrpcod,
                             mr_entrada.bnfcrtcod,
                             mr_entrada_ant.minper,
                             mr_entrada_ant.maxper,
                             mr_entrada_ant.fxavlr
     fetch cctc20m05_13 into l_bnffxacod,
                             l_fxaseq
     
     if  sqlca.sqlcode = 0 then
         let l_flag = true
     end if
     if  l_flag then
        
         execute pctc20m05_11 using  ma_entrada[m_cur].minper,
                                     ma_entrada[m_cur].maxper,
                                     ma_entrada[m_cur].fxavlr,
                                     g_issk.usrcod,
                                     ma_entrada[m_cur].atldat,
                                     mr_entrada.prtbnfgrpcod,
                                     mr_entrada.bnfcrtcod,
                                     l_bnffxacod,
                                     l_fxaseq
         if  sqlca.sqlcode = 0 then
         end if
     else
         error "Registro nao encontrado"
     end if
     
 end function


#---------------------------#
 function ctc20m05_incluir()
#---------------------------#
     define l_status smallint,
            l_flag smallint
     let l_flag = false
     open cctc20m05_10 using mr_entrada.prtbnfgrpcod,
                             mr_entrada.bnfcrtcod,
                             ma_entrada[m_cur].minper,
                             ma_entrada[m_cur].maxper,
                             ma_entrada[m_cur].fxavlr
     fetch cctc20m05_10 into l_status
     
     if  sqlca.sqlcode = 0 then
         let l_flag = true
     end if
     if  l_flag then
         error "Este registro ja existe!"
     else
            # BUSCA O CODIGO DA FAIXA
            open cctc20m05_04 using mr_entrada.prtbnfgrpcod,
                                    mr_entrada.bnfcrtcod
            fetch cctc20m05_04 into mr_entrada.bnffxacod
     
            if  sqlca.sqlcode = notfound or
                mr_entrada.bnffxacod is null or
                mr_entrada.bnffxacod = " " then
     
                open cctc20m05_05
                fetch cctc20m05_05 into mr_entrada.bnffxacod
     
                if  sqlca.sqlcode = notfound or
                mr_entrada.bnffxacod is null or
                mr_entrada.bnffxacod = " " then
                    let mr_entrada.bnffxacod = 0
                end if
     
                let  mr_entrada.bnffxacod = mr_entrada.bnffxacod + 1
     
            end if
            # BUSCA O NUMERO DA SEQUENCIA DA FAIXA
            open cctc20m05_06 using mr_entrada.prtbnfgrpcod,
                                    mr_entrada.bnfcrtcod
                                    
                                    
            fetch cctc20m05_06 into mr_entrada.fxaseq
     
            if  sqlca.sqlcode = notfound or
                mr_entrada.fxaseq is null or
                mr_entrada.fxaseq = " " then
                let mr_entrada.fxaseq = 0
            end if
     
            let mr_entrada.fxaseq = mr_entrada.fxaseq + 1
            
            if  ma_entrada[m_cur].atldat is null or 
                ma_entrada[m_cur].atldat = " " then
                let ma_entrada[m_cur].atldat = today
            end if  
            
            if  ma_entrada[m_cur].funnom is null or 
                ma_entrada[m_cur].funnom = " " then
                let ma_entrada[m_cur].funnom = g_issk.usrcod
            end if  

                let mr_entrada.minper = ma_entrada[m_cur].minper
                let mr_entrada.maxper = ma_entrada[m_cur].maxper
                let mr_entrada.fxavlr = ma_entrada[m_cur].fxavlr
                let mr_entrada.atldat = ma_entrada[m_cur].atldat
    
                   
                execute pctc20m05_03 using mr_entrada.prtbnfgrpcod,
                                           mr_entrada.bnffxacod,
                                           mr_entrada.bnfcrtcod,
                                           ma_entrada[m_cur].minper,
                                           ma_entrada[m_cur].maxper,
                                           ma_entrada[m_cur].fxavlr,
                                           ma_entrada[m_cur].atldat,
                                           g_issk.usrcod,
                                           mr_entrada.fxaseq,
                                           '0'
     end if
 end function

 
#---------------------------------#
 function ctc20m05_carrega_array()
#---------------------------------# 
     
    define lr_retorno record
                         erro       smallint,
                         mensagem   char(60)
                      end record     

     define l_ind    smallint,
            m_atlusr like dpakbnfvlrfxa.atlusr
 
     open cctc20m05_08 using mr_entrada.prtbnfgrpcod,
                             mr_entrada.bnfcrtcod    
     
     initialize ma_entrada to null
     
     let l_ind = 1
     
     foreach  cctc20m05_08 into ma_entrada[l_ind].minper,      
                                ma_entrada[l_ind].maxper,      
                                ma_entrada[l_ind].fxavlr,           
                                m_atlusr,      
                                ma_entrada[l_ind].atldat

         call cty08g00_nome_func(1,m_atlusr,'F')
              returning lr_retorno.erro,
                        lr_retorno.mensagem,
                        ma_entrada[l_ind].funnom

         let l_ind = l_ind + 1
         if l_ind > 200 then
             error "O numero de registros ultrapassou o tamanho do array. Favor contatar a informatica"
             exit foreach
         end if
     end foreach 
     
     call set_count(l_ind)
     
 end function

