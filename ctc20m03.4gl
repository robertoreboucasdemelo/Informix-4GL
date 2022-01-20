#############################################################################
# Nome do Modulo: CTC20M03                                    Sergio Burini #
#                                                                PSI 229784 #
# CADASTRO DE ASSISTENCIA/NATUREZA DOS GRUPOS DE SERVIÇO.          NOV/2008 #
#############################################################################
# ALTERACOES:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#

database porto

    globals "/homedsa/projetos/geral/globals/glct.4gl"

    define ma_entrada array[500] of record
                          atdsrvorg like dpakbnfgrppar.atdsrvorg,
                          srvtipdes like datksrvtip.srvtipdes,
                          codpar    smallint,
                          despar    char(20),
                          atldat    like dpakbnfgrppar.atldat,
                          funnom    like isskfunc.funnom
                      end record
    
    define mr_entrada_aux record
                          atdsrvorg like dpakbnfgrppar.atdsrvorg,
                          srvtipdes like datksrvtip.srvtipdes,
                          codpar    smallint,
                          despar    char(20),
                          atldat    like dpakbnfgrppar.atldat,
                          funnom    like isskfunc.funnom
                      end record     
    
    define ma_aux array[500] of record
                      atlusr    like dpakbnfgrppar.atlusr,
                      asitipcod like dpakbnfgrppar.asitipcod,
                      socntzcod like dpakbnfgrppar.socntzcod
                  end record

     define mr_param record
                         prtbnfgrpcod like dpaksrvgrp.prtbnfgrpcod,
                         prtbnfgrpdes like dpaksrvgrp.prtbnfgrpdes
                     end record
                     
     
     define m_confirma char(01)
     
     define m_cur         smallint,
            m_src         smallint
            
#---------------------------#
 function ctc20m03_prepare()
#---------------------------#

    define l_sql char(1000)

    let l_sql = "select srvtipdes ",
                 " from datksrvtip ",
                " where atdsrvorg = ? "

    prepare pcctc20m03_02 from l_sql
    declare cqctc20m03_02 cursor for pcctc20m03_02

    let l_sql = "select 1 ",
                 " from datrasitipsrv ",
                " where atdsrvorg = ? ",
                  " and asitipcod = ? "

    prepare pcctc20m03_03 from l_sql
    declare cqctc20m03_03 cursor for pcctc20m03_03

    let l_sql = "select asitipdes ",
                 " from datkasitip ",
                " where asitipcod = ? ",
                "   and asitipstt = 'A'"
    prepare pcctc20m03_04 from l_sql
    declare cqctc20m03_04 cursor for pcctc20m03_04

    let l_sql = "delete from dpakbnfgrppar ",
                " where prtbnfgrpcod = ? "

    prepare pcctc20m03_05 from l_sql
    
    
    let l_sql = "insert into dpakbnfgrppar values (?,?,?,?,?,?,?)"

    prepare pcctc20m03_06 from l_sql

    let l_sql = "select socntzdes ",
                 " from datksocntz ",
                " where socntzcod = ? ",
                "   and socntzstt = 'A'"

    prepare pcctc20m03_07 from l_sql
    declare cqctc20m03_07 cursor for pcctc20m03_07

    let l_sql = "select sinntzdes ",
                 " from sgaknatur ",
                " where sinntzcod = ? "

    prepare pcctc20m03_08 from l_sql
    declare cqctc20m03_08 cursor for pcctc20m03_08

    let l_sql = "select max(grpparcod) ",
                 " from dpakbnfgrppar ",
                " where prtbnfgrpcod = ? "

    prepare pcctc20m03_09 from l_sql
    declare cqctc20m03_09 cursor for pcctc20m03_09

    let l_sql = "select atdsrvorg, ",
                      " asitipcod, ",
                      " atldat, ",
                      " atlusr, ",
                      " socntzcod ",
                 " from dpakbnfgrppar ",
                " where prtbnfgrpcod = ? ",
                " order by atdsrvorg, asitipcod, socntzcod"
                
    prepare pcctc20m03_10 from l_sql
    declare cqctc20m03_10 cursor for pcctc20m03_10

    let l_sql = "delete from dpakbnfgrppar ",
                " where prtbnfgrpcod = ? and ",
                "       atdsrvorg = ? and ",
                "      (asitipcod = ? or socntzcod = ?)"
    prepare pcctc20m03_11 from l_sql
    
    let l_sql = "select distinct 1 ",
                 " from dpakbnfgrppar ",
                " where prtbnfgrpcod = ? and ",
                "       atdsrvorg = ? and ",
                "      (asitipcod = ? or socntzcod = ?)"
                
    prepare pcctc20m03_12 from l_sql
    declare cqctc20m03_12 cursor for pcctc20m03_12
    
    let l_sql = "select max(grpparcod) ",
                  " from dpakbnfgrppar "

     prepare pcctc20m03_13 from l_sql
     declare cqctc20m03_13 cursor for pcctc20m03_13
    
    
 end function

#------------------------#
 function ctc20m03(param)
#------------------------#

     define param record
                      prtbnfgrpcod like dpaksrvgrp.prtbnfgrpcod,
                      prtbnfgrpdes like dpaksrvgrp.prtbnfgrpdes,
                      atldat       like dpaksrvgrp.atldat   ,
                      atlusr       like dpaksrvgrp.atlusr   ,
                      funnom       like isskfunc.funnom
                  end record
     
     define lr_retorno record
                           erro       smallint,
                           mensagem   char(60)
                       end record

     define l_status      smallint,
            l_flag_insert smallint,
            l_flag_novo   smallint,
            l_arr_count smallint,
            l_sql         char(500)

     initialize ma_entrada, ma_aux to null

     let mr_param.prtbnfgrpcod = param.prtbnfgrpcod
     let mr_param.prtbnfgrpdes = param.prtbnfgrpdes
     
     let l_flag_insert = false

     call ctc20m03_prepare()

     open window w_ctc20m03 at 4,2 with form "ctc20m03"
          attribute(form line first)

     let int_flag = false


     while true
     
     call ctc20m03_carrega_array()

     input array ma_entrada without defaults from s_ctc20m03.*

         before input 
          display mr_param.prtbnfgrpdes to titulo
          
         
         before row
            let l_arr_count = arr_count()
            let m_cur = arr_curr()
            let m_src = scr_line() 
            
        
         before insert
            let l_arr_count = arr_count()
                 if l_arr_count > 500 then
                     error "O numero de registros ultrapassou o tamanho do array. Favor contatar a informatica"
                 end if
            if fgl_lastkey() = 2014 then
                let l_flag_insert = true
            end if
         
         before delete
            call cts08g01("C","F"                                                   
                         ,"","CONFIRMA A EXCLUSAO DO PARAMETRO DO GRUPO DE SERVICO","SELECIONADO ?","") 
            returning m_confirma                                                    
            let l_flag_insert = false                                                                        
            if  m_confirma = "S" then 
                execute pcctc20m03_11 using mr_param.prtbnfgrpcod,
                                            ma_entrada[m_cur].atdsrvorg,
                                            ma_entrada[m_cur].codpar,
                                            ma_entrada[m_cur].codpar
                if  sqlca.sqlcode <> 0 then
                     error 'Problema no DELETE da tabela dpakprtbnfgrpcrt : ', sqlca.sqlcode
                end if
            else
                display ma_entrada[m_cur].atdsrvorg to s_ctc20m03[m_src].atdsrvorg  
                exit input   
            end if
         
         before field atdsrvorg
            display ma_entrada[m_cur].atdsrvorg to s_ctc20m03[m_src].atdsrvorg
               attribute(reverse)
            let l_flag_novo = true
            if  (ma_entrada[m_cur].atdsrvorg is not null and
                ma_entrada[m_cur].atdsrvorg <> " ") or
                l_flag_insert then
                let l_flag_novo = false
                let mr_entrada_aux.* = ma_entrada[m_cur].*
            end if
                    
         before field codpar 
            if l_flag_novo or l_flag_insert then
               display ma_entrada[m_cur].codpar to s_ctc20m03[m_src].codpar 
                    attribute(reverse)
            else
               next field atdsrvorg
            end if
        
         after field atdsrvorg
            if l_flag_novo = false and 
               (mr_entrada_aux.atdsrvorg <> ma_entrada[m_cur].atdsrvorg or
               (ma_entrada[m_cur].atdsrvorg is null or
                ma_entrada[m_cur].atdsrvorg = " ")) and
                l_flag_insert = false then
                
                error "Para inserir Pressione <F1>"
                let ma_entrada[m_cur].* = mr_entrada_aux.*
                next field atdsrvorg
            end if
            display ma_entrada[m_cur].atdsrvorg to s_ctc20m03[m_src].atdsrvorg 
            if  ma_entrada[m_cur].atdsrvorg is not null and
                ma_entrada[m_cur].atdsrvorg <> " " then
                open cqctc20m03_02 using ma_entrada[m_cur].atdsrvorg
                fetch cqctc20m03_02 into ma_entrada[m_cur].srvtipdes
                
                if  sqlca.sqlcode = notfound then
                    error 'Origem nao encotrada.'
                    let ma_entrada[m_cur].atdsrvorg = ""
                    let ma_entrada[m_cur].srvtipdes = ""
                    next field atdsrvorg
                else
                    display ma_entrada[m_cur].srvtipdes to s_ctc20m03[m_src].srvtipdes
                    if l_flag_novo then
                       next field codpar
                    end if
                end if
            else
                if l_flag_insert = false and fgl_lastkey() = fgl_keyval("UP")  then
                      
                else
                     if  fgl_lastkey() = fgl_keyval("DOWN")   or
                         fgl_lastkey() = fgl_keyval("RIGHT")  or
                         fgl_lastkey() = fgl_keyval("RETURN") or l_flag_insert then
                         call ofgrc001_popup(10,
                                             2,
                                             "ORIGENS DE SERVIÇO",
                                             "CODIGO",
                                             "DESCRICAO",
                                             "N",
                                             "SELECT atdsrvorg, srvtipdes FROM datksrvtip order by atdsrvorg",
                                             "",
                                             "X")
                         returning lr_retorno.erro,
                                   ma_entrada[m_cur].atdsrvorg,
                                   ma_entrada[m_cur].srvtipdes
                         
                         display ma_entrada[m_cur].atdsrvorg to s_ctc20m03[m_src].atdsrvorg
                         display ma_entrada[m_cur].srvtipdes to s_ctc20m03[m_src].srvtipdes
                         if  ma_entrada[m_cur].atdsrvorg is not null and
                             ma_entrada[m_cur].atdsrvorg <> " " then
                            let l_flag_insert = true
                         end if
                         next field atdsrvorg
                     end if
                 end if
            end if
            
            if  ma_entrada[m_cur].atdsrvorg is null or 
                ma_entrada[m_cur].atdsrvorg = " " then
                if  (fgl_lastkey() = fgl_keyval("DOWN")   or
                    fgl_lastkey() = fgl_keyval("RIGHT")  or
                    fgl_lastkey() = fgl_keyval("RETURN")) or l_flag_insert then
                    error 'Codigo de Origem deve ser informado.'
                    next field atdsrvorg
                end if
            end if

         after field codpar
            display ma_entrada[m_cur].codpar to s_ctc20m03[m_src].codpar 
            if  ma_entrada[m_cur].codpar is not null and
                ma_entrada[m_cur].codpar <> " " then
                if  fgl_lastkey() = fgl_keyval("LEFT") then
                    let l_flag_insert = true
                    next field atdsrvorg
                end if
                call ctc20m03_verific_array(m_cur,
                                            ma_entrada[m_cur].atdsrvorg,
                                            ma_entrada[m_cur].codpar)
                     returning l_status

                if  not l_status then
                    if  ma_entrada[m_cur].atdsrvorg = 9 then
                        # VERIFICA SE ENCONTRA A NATUREZA
                        open cqctc20m03_07 using ma_entrada[m_cur].codpar
                        fetch cqctc20m03_07 into ma_entrada[m_cur].despar

                        if  sqlca.sqlcode = 0 then
                            let ma_entrada[m_cur].atldat = current
                            let ma_aux[m_cur].atlusr     = g_issk.usrcod

                            call cty08g00_nome_func(1, ma_aux[m_cur].atlusr, 'F')
                                 returning lr_retorno.erro,
                                           lr_retorno.mensagem,
                                           ma_entrada[m_cur].funnom

                            let ma_aux[m_cur].asitipcod = 6
                            let ma_aux[m_cur].socntzcod = ma_entrada[m_cur].codpar

                            display ma_entrada[m_cur].funnom to s_ctc20m03[m_src].funnom
                            display ma_entrada[m_cur].atldat to s_ctc20m03[m_src].atldat
                            display ma_entrada[m_cur].despar to s_ctc20m03[m_src].despar
                            call ctc20m03_incluir()
                            let l_flag_insert = false
                        else
                            if  sqlca.sqlcode = notfound then
                                error 'Codigo de Assistencia nao encontrada.'
                                next field codpar
                            end if
                        end if
                    else
                        if  ma_entrada[m_cur].atdsrvorg = 13 then
                            # VERIFICA SE ENCONTRA A NATUREZA
                            open cqctc20m03_08 using ma_entrada[m_cur].codpar
                            fetch cqctc20m03_08 into ma_entrada[m_cur].despar

                            if  sqlca.sqlcode = 0 then
                                let ma_entrada[m_cur].atldat = current 
                                let ma_aux[m_cur].atlusr = g_issk.usrcod

                                call cty08g00_nome_func(1, ma_aux[m_cur].atlusr, 'F')
                                     returning lr_retorno.erro,
                                               lr_retorno.mensagem,
                                               ma_entrada[m_cur].funnom

                                let ma_aux[m_cur].asitipcod = 6
                                let ma_aux[m_cur].socntzcod = ma_entrada[m_cur].codpar

                                display ma_entrada[m_cur].funnom to s_ctc20m03[m_src].funnom
                                display ma_entrada[m_cur].atldat to s_ctc20m03[m_src].atldat
                                display ma_entrada[m_cur].despar to s_ctc20m03[m_src].despar
                                call ctc20m03_incluir()
                                let l_flag_insert = false
                            else
                                if  sqlca.sqlcode = notfound then
                                    error 'Codigo de Assistencia nao encontrada.'
                                    next field codpar
                                end if
                            end if
                        else
                            # VERIFICA SE ENCONTRA A ASSISTENCIA
                            open cqctc20m03_04 using ma_entrada[m_cur].codpar
                            fetch cqctc20m03_04 into ma_entrada[m_cur].despar

                            if  sqlca.sqlcode = 0 then
                                # VERIFICA SE ENCONTROU O RELACIONAMENTO DA
                                # ASSISTENCIA COM A ORIGEM DO SERVIÇO
                                open cqctc20m03_03 using ma_entrada[m_cur].atdsrvorg,
                                                         ma_entrada[m_cur].codpar
                                fetch cqctc20m03_03 into l_status

                                if  sqlca.sqlcode = 0 then

                                    let ma_entrada[m_cur].atldat = current 
                                    let ma_aux[m_cur].atlusr = g_issk.usrcod

                                    call cty08g00_nome_func(1, ma_aux[m_cur].atlusr, 'F')
                                         returning lr_retorno.erro,
                                                   lr_retorno.mensagem,
                                                   ma_entrada[m_cur].funnom

                                    let ma_aux[m_cur].asitipcod = ma_entrada[m_cur].codpar
                                    let ma_aux[m_cur].socntzcod = 0

                                    display ma_entrada[m_cur].funnom to s_ctc20m03[m_src].funnom
                                    display ma_entrada[m_cur].atldat to s_ctc20m03[m_src].atldat
                                    display ma_entrada[m_cur].despar to s_ctc20m03[m_src].despar
                                    call ctc20m03_incluir()
                                    let l_flag_insert = false
                                    
                                else
                                    if  sqlca.sqlcode = notfound then
                                        error 'Nao existe relacionamento entre a Origem e a Assistencia.'
                                        let l_flag_insert = true
                                        next field atdsrvorg
                                    else
                                        error 'MENSAGEM DE ERRO'
                                        next field codpar
                                    end if
                                end if
                            else
                                if  sqlca.sqlcode = notfound then
                                    error 'Codigo de Assistencia nao encontrada.'
                                    next field codpar
                                else
                                    error 'MENSAGEM DE ERRO'
                                    next field codpar
                                end if
                            end if
                        end if
                    end if
                else
                    error 'Parametro já pertencente a esse grupo.'
                    let ma_entrada[m_cur].atdsrvorg = ""
                    let ma_entrada[m_cur].srvtipdes = ""
                    let ma_entrada[m_cur].codpar    = ""
                    let ma_entrada[m_cur].despar    = ""
                    display ma_entrada[m_cur].atdsrvorg to s_ctc20m03[m_src].atdsrvorg
                    display ma_entrada[m_cur].srvtipdes to s_ctc20m03[m_src].srvtipdes
                    display ma_entrada[m_cur].codpar    to s_ctc20m03[m_src].codpar
                    display ma_entrada[m_cur].despar    to s_ctc20m03[m_src].despar
                    next field atdsrvorg
                end if
            else
                if  fgl_lastkey() <> fgl_keyval("LEFT") then
                
                    #error 'Codigo de Assistencia/Natureza deve ser informado.'
                    if  ma_entrada[m_cur].atdsrvorg = 9 then
                        call ofgrc001_popup(10,
                                            2,
                                            "NATUREZAS DE SERVIÇO",
                                            "CODIGO",
                                            "DESCRICAO",
                                            "N",
                                            "SELECT socntzcod, socntzdes FROM datksocntz WHERE socntzstt = 'A' order by socntzcod",
                                            "",
                                            "X")
                        returning lr_retorno.erro,
                                  ma_entrada[m_cur].codpar,
                                  ma_entrada[m_cur].despar
                        
                        display ma_entrada[m_cur].codpar to s_ctc20m03[m_src].codpar
                        display ma_entrada[m_cur].despar to s_ctc20m03[m_src].despar
                        next field codpar
                    else
                        if  ma_entrada[m_cur].atdsrvorg = 13 then
                            call ofgrc001_popup(10,
                                                2,
                                                "NATUREZAS DE SERVIÇO SINISTRO",
                                                "CODIGO",
                                                "DESCRICAO",
                                                "N",
                                                "select sinntzcod, sinntzdes from sgaknatur order by sinntzcod",
                                                "",
                                                "X")
                            returning lr_retorno.erro,
                                      ma_entrada[m_cur].codpar,
                                      ma_entrada[m_cur].despar
                        
                            display ma_entrada[m_cur].codpar to s_ctc20m03[m_src].codpar
                            display ma_entrada[m_cur].despar to s_ctc20m03[m_src].despar 
                            next field codpar               
                        else
                        
                            let l_sql = "select a.asitipcod, asitipdes from datrasitipsrv a, datkasitip b where a.asitipcod = b.asitipcod and asitipstt = 'A' and  atdsrvorg = ", ma_entrada[m_cur].atdsrvorg
                        
                            call ofgrc001_popup(10,
                                                2,
                                                "ASSISTENCIAS DE SERVICO",
                                                "CODIGO",
                                                "DESCRICAO",
                                                "N",
                                                l_sql,
                                                "",
                                                "X")
                            returning lr_retorno.erro,
                                      ma_entrada[m_cur].codpar,
                                      ma_entrada[m_cur].despar
                            
                            display ma_entrada[m_cur].codpar to s_ctc20m03[m_src].codpar
                            display ma_entrada[m_cur].despar to s_ctc20m03[m_src].despar 
                            next field codpar
                        end if
                    end if   
                
                else
                    let l_flag_insert = true
                    next field atdsrvorg
                end if
                
            end if
            
            if  ma_entrada[m_cur].codpar is null or 
                ma_entrada[m_cur].codpar = " " then
                error 'Codigo de Assistencia/Natureza deve ser informado.'
                next field codpar
            end if

        

     end input
     
     if int_flag then
          let int_flag = false
          exit while     
     end if
     
     end while

     close window w_ctc20m03

 end function

#---------------------------------------------#
 function ctc20m03_verific_array(l_ind, param)
#---------------------------------------------#

    define param record
                     atdsrvorg like dpakbnfgrppar.atdsrvorg,
                     codpar    smallint
                 end record

    define l_ind   smallint,
           l_ind2  smallint,
           l_count smallint,
           l_find  smallint

    let l_count = arr_count()
    let l_find = false

    for l_ind2 = 1 to l_count
        if  l_ind2 <> l_ind then
            if  ma_entrada[l_ind2].atdsrvorg = ma_entrada[l_ind].atdsrvorg and
                ma_entrada[l_ind2].codpar    = ma_entrada[l_ind].codpar then
                let l_find = true
            end if
        else
            continue for
        end if
    end for

    if  l_find then
        return true
    else
        return false
    end if

 end function

#---------------------------#
 function ctc20m03_incluir()
#---------------------------#
     
     define l_status smallint,
            l_flag smallint,
            l_grpparcod smallint
     let l_flag = false
     open cqctc20m03_12 using mr_param.prtbnfgrpcod,
                              ma_entrada[m_cur].atdsrvorg,
                              ma_entrada[m_cur].codpar,
                              ma_entrada[m_cur].codpar
     fetch cqctc20m03_12 into l_status
     
     if  sqlca.sqlcode = 0 then
         let l_flag = true
     end if
     if  not l_flag then
         open cqctc20m03_13
         fetch cqctc20m03_13 into l_grpparcod
         if  sqlca.sqlcode = notfound or
             l_grpparcod is null or
             l_grpparcod = " " then
             let l_grpparcod = 0
         end if
     
         let  l_grpparcod = l_grpparcod + 1  
         execute pcctc20m03_06 using l_grpparcod,
                                     mr_param.prtbnfgrpcod,
                                     ma_entrada[m_cur].atdsrvorg,
                                     ma_aux[m_cur].asitipcod,
                                     ma_entrada[m_cur].atldat,
                                     ma_aux[m_cur].atlusr,
                                     ma_aux[m_cur].socntzcod
         if  sqlca.sqlcode <> 0 then
             error "Problema na inclusao dos parametros", sqlca.sqlcode
         end if
     
     else
         error "Registro nao encontrado"
     end if
     
     

 end function

#---------------------------------#
 function ctc20m03_carrega_array()
#---------------------------------#

     define lr_retorno record
                           erro       smallint,
                           mensagem   char(60)
                       end record

     define l_ind    smallint

     let l_ind = 1

     open cqctc20m03_10 using mr_param.prtbnfgrpcod
     fetch cqctc20m03_10 into ma_entrada[l_ind].atdsrvorg,
                              ma_aux[l_ind].asitipcod,
                              ma_entrada[l_ind].atldat,
                              ma_aux[l_ind].atlusr,
                              ma_aux[l_ind].socntzcod

     foreach cqctc20m03_10 into ma_entrada[l_ind].atdsrvorg,
                                ma_aux[l_ind].asitipcod,
                                ma_entrada[l_ind].atldat,
                                ma_aux[l_ind].atlusr,
                                ma_aux[l_ind].socntzcod

         open cqctc20m03_02 using ma_entrada[l_ind].atdsrvorg
         fetch cqctc20m03_02 into ma_entrada[l_ind].srvtipdes

         if  ma_entrada[l_ind].atdsrvorg = 9 then
             let ma_entrada[l_ind].codpar = ma_aux[l_ind].socntzcod

             open cqctc20m03_07 using ma_entrada[l_ind].codpar
             fetch cqctc20m03_07 into ma_entrada[l_ind].despar
         else
             if  ma_entrada[l_ind].atdsrvorg = 13 then
                 let ma_entrada[l_ind].codpar = ma_aux[l_ind].socntzcod
                 open cqctc20m03_08 using ma_entrada[l_ind].codpar
                 fetch cqctc20m03_08 into ma_entrada[l_ind].despar
             else
                 let ma_entrada[l_ind].codpar = ma_aux[l_ind].asitipcod
                 open cqctc20m03_04 using ma_entrada[l_ind].codpar
                 fetch cqctc20m03_04 into ma_entrada[l_ind].despar
             end if
         end if

         call cty08g00_nome_func(1, ma_aux[l_ind].atlusr, 'F')
              returning lr_retorno.erro,
                        lr_retorno.mensagem,
                        ma_entrada[l_ind].funnom

         let l_ind = l_ind + 1
         if l_ind > 500 then
             error "O numero de registros ultrapassou o tamanho do array. Favor contatar a informatica"
             exit foreach
         end if
     end foreach

     call set_count(l_ind - 1)

 end function
