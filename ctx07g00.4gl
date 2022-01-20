#---------------------------------------------------------------------------#
# Nome do Modulo: ctx07g00                                         Wagner   #
#                                                                  Gilberto #
# Cancelamento da OP                                               Mar/2000 #
#---------------------------------------------------------------------------#
# Observacao: A partir da implantacao do People os processos de update no   #
#             cancelamento serao feitos pela camada de retorno do People    #
#             e nao mais chamadas pelo online                               #
# Alteracoes:                                                               #
# DATA        SOLIC      RESPONSAVEL  DESCRICAO                             #
#---------------------------------------------------------------------------#
# 22/06/2009  PSI198404  Fabio Costa    Reestruturacao cancelamento e       #
#                                       adequacoes People                   #
# 27/07/2009  PSI198404  Fabio Costa    Revisao cancela OP antes do People  #
# 10/03/2010  CT 763527  Beatriz Araujo Cancelar a OP mesmo que não tenha   #
#                                       item/serviço, consertar o SQL       #
#---------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------
function ctx07g00(param)
#--------------------------------------------------------------------
  define param record
         socopgnum    like dbsmopg.socopgnum    ,
         socopgsitcod like dbsmopg.socopgsitcod ,
         ciaempcod    like datmservico.ciaempcod,
         funmat       like isskfunc.funmat,
         empcod       like isskusuario.empcod
  end record
  
  define a_bfpga_err  array[10] of record
         errcod       decimal(3,0)
  end record
  
  define l_msg      char(100) ,
         l_errdsc   char(100) ,
         l_sqlcode  smallint  , 
         l_sqlerrd  smallint  ,
         l_ret      integer   ,
         l_ct       smallint  ,
         l_arr      smallint
  
  #Fornax-Quantum
  define lr_ret record
          stt    integer
         ,msg    char(100)
  end record 
  
  define lr_sap record       
          erro    integer     
         ,msg    char(100)   
  end record                 
  #Fornax-Quantum
  
         
  initialize a_bfpga_err to null
  
  let l_msg     = null
  let l_errdsc  = null
  let l_sqlcode = null 
  let l_sqlerrd = null
  let l_ret     = null
  let l_ct      = null
  let l_arr     = null
  
  let l_ct  = 1
  let l_arr = 1     
  
  if param.socopgnum is not null
     then
     display "OP: ", param.socopgnum
     # cancelamento People/Informix OPs emitidas, todas empresas menos Azul e Itau
     if param.socopgsitcod = 7 and 
        param.ciaempcod != 35  and 
        param.ciaempcod != 84
        then
        #Fornax-Quantum - inicio  
        #Validar se o cancelamento e SAP ou People
        call ffpgc377_verificarIntegracaoAtivaEmpresaRamo("010PTSOC", today ,param.ciaempcod, 0)
             returning  lr_ret.stt
                       ,lr_ret.msg
        
        display "ffpgc377_verificarIntegracaoAtivaEmpresaRamo"
        display ",param.ciaempcod: ",param.ciaempcod
        display "lr_ret.stt: ",lr_ret.stt
        display "lr_ret.msg: ",lr_ret.msg
        
        # Solicitar cancelamento OP no SAP
        if lr_ret.stt = 1 then
           #Diretório do fonte - /projetos/fornax/D0609511/luisbarros/projetos/quantum/ctb00g17  - Fornax Quantum      
           call ctb00g17_cancela_op_sap( param.socopgnum    
                                        ,param.socopgsitcod 
                                        ,param.ciaempcod    
                                        ,param.funmat
                                        ,param.empcod)  
                        returning lr_sap.erro, lr_sap.msg 
           display "lr_sap.erro: ",lr_sap.erro
           display "lr_sap.msg: ",lr_sap.msg
           if  lr_sap.erro = 0 then
              display "Cancela informix"
              call ctx07g00_cancela_informix(param.socopgnum)  
                   returning lr_sap.erro, lr_sap.msg                      
           end if 
           
           return lr_sap.erro, lr_sap.msg
        else 
        #Fornax-Quantum - final
           # gravar status da OP aguardando retorno do cancelamento, feito antes
           # para nao enviar ao People com erro no update da OP
           begin work
           
           call ctd20g00_upd_opg(param.socopgnum, 11)
                returning l_sqlcode, l_sqlerrd
                
           if l_sqlerrd != 1
              then
              rollback work
              let l_msg = " Atualizacao da OP, sqlcode: ", l_sqlcode,
                          " | sqlerrd[3]: ", l_sqlerrd
              return 1, l_msg
           end if
           
           # solicitar cancelamento de OP no People
           if g_issk.funmat is null
              then
              let g_issk.funmat = 999999
           end if
           
           call bfpga018ps_cancela_peoplesoft(11, param.socopgnum, param.ciaempcod,
                                              '','', g_issk.funmat)
                returning a_bfpga_err[01].errcod,
                          a_bfpga_err[02].errcod,
                          a_bfpga_err[03].errcod,
                          a_bfpga_err[04].errcod,
                          a_bfpga_err[05].errcod,
                          a_bfpga_err[06].errcod,
                          a_bfpga_err[07].errcod,
                          a_bfpga_err[08].errcod,
                          a_bfpga_err[09].errcod,
                          a_bfpga_err[10].errcod
                          
           if a_bfpga_err[01].errcod is not null and
              a_bfpga_err[01].errcod = 0
              then
              commit work
              error " OP solicitada para cancelamento, aguardando retorno People "
              
              # aguarda o retorno por um minuto
              for l_ct = 1 to 20
                  initialize param.socopgsitcod to null
                  sleep 3
                  
                  call ctd20g00_sel_opg_chave(1, param.socopgnum)
                       returning l_ret, l_msg, param.socopgsitcod
                       
                  if param.socopgsitcod is not null and
                     param.socopgsitcod = 8
                     then
                     error ' Processo de cancelamento OP People finalizado '
                     exit for
                  end if
              end for
              if param.socopgsitcod is null or
                 param.socopgsitcod != 8
                 then
                 error ' Cancelamento não confirmado no People, tente verificar a OP em alguns minutos '
              end if
              return 0, ''
           else
              rollback work
              for l_arr = 1 to 10 
                 call g_erro_bfpga018(a_bfpga_err[l_arr].errcod) returning l_errdsc
                 if l_arr = 1
                    then
                    let l_msg = l_errdsc
                 end if
                 display l_errdsc
              end for
              return 1, l_msg
           end if
        end if #Fornax-Quantum 
     else
     
        if param.socopgsitcod = 8  or
           param.socopgsitcod = 10 or
           param.socopgsitcod = 11
           then
           let l_msg = " Ordem de pagamento cancelada ou aguardando retorno, não é possível cancelar "
           return 1, l_msg
        else
        
           begin work
           
           call ctx07g00_cancela_informix(param.socopgnum)
                returning l_ret, l_msg
           
           if l_ret = 0
              then
              commit work
              error ' Processo de cancelamento OP Informix finalizado '
              sleep 1
              return 0, ''
           else
              rollback work
              display 'Cancela OP: ROLLBACK'
              return 1, l_msg
           end if
           
        end if
        
     end if
     
  else
     
     let l_msg = "Número da ordem de pagamento não pode ser nulo"
     return 1, l_msg
     
  end if
  
end function  ###  ctx07g00


#----------------------------------------------------------------
function ctx07g00_cancela_informix(l_socopgnum)
#----------------------------------------------------------------
# OBS: nao cancela provisionamento de caixa porque ainda nao foi emitida

  define l_socopgnum decimal(8,0) ,
         l_sqlcode   integer      ,
         l_sqlerrd   integer      ,
         l_msg       char(100)    ,
         l_sql       char(600)
         
  define l_opgitm record
         socopgnum  like dbsmopg.socopgnum     ,
         soctip     like dbsmopg.soctip        ,
         atdsrvnum  like dbsmopgitm.atdsrvnum  ,
         atdsrvano  like dbsmopgitm.atdsrvano  ,
         ciaempcod  like datmservico.ciaempcod ,
         atdsrvorg  like datmservico.atdsrvorg ,
         atdcstvlr  like datmservico.atdcstvlr
  end record
  
  initialize l_opgitm.* to null
  
  let l_sqlcode = null
  let l_sqlerrd = null
  let l_msg     = null
  let l_sql     = null
  
  ##### Chamado para cancelar OP CT 763527  Beatriz Araujo
  ##### não irá trazer nada, se não tiver serviço ou item.
  ####let l_sql = ' select o.socopgnum, o.soctip,    ',
  ####            '        i.atdsrvnum, i.atdsrvano, ',
  ####            '        s.ciaempcod, s.atdsrvorg, s.atdcstvlr ',
  ####            ' from dbsmopg o, dbsmopgitm i, datmservico s ',
  ####            ' where o.socopgnum = i.socopgnum ',
  ####            '   and i.atdsrvnum = s.atdsrvnum ',
  ####            '   and i.atdsrvano = s.atdsrvano ',
  ####            '   and i.socopgnum = ? ',
  ####            ' order by i.socopgitmnum '
  ####  
  #### Fim do Chamado
  
  
  ### Mesmo que não tenha serviço ou item ele traz o OP
  # selecionar servicos da OP             
  let l_sql = ' select o.socopgnum, o.soctip,    ',                   
            '        i.atdsrvnum, i.atdsrvano, ',                   
            '        s.ciaempcod, s.atdsrvorg, s.atdcstvlr ',       
            ' from dbsmopg o, outer(dbsmopgitm i, datmservico s) ', 
            ' where o.socopgnum = i.socopgnum ',                    
            '   and i.atdsrvnum = s.atdsrvnum ',                    
            '   and i.atdsrvano = s.atdsrvano ',                    
            '   and o.socopgnum = ? ',                              
            ' order by i.socopgitmnum '                             

  prepare p_opgitm_sel from l_sql
  declare c_opgitm_sel cursor with hold for p_opgitm_sel
  
  display "l_socopgnum: ",l_socopgnum
  
  # cancelamento do pagamento do servico
  whenever error continue
  open c_opgitm_sel using l_socopgnum
  whenever error stop
  
  foreach c_opgitm_sel into l_opgitm.*
    if l_opgitm.atdsrvnum is not null   and  
       l_opgitm.atdsrvano is not null then
       
        if l_opgitm.atdsrvorg != 2
           then
           initialize l_opgitm.atdcstvlr to null
        end if
        display "Update servico"
        call ctd07g00_upd_srv_opg('', 
                                  l_opgitm.atdcstvlr,
                                  l_opgitm.atdsrvnum,
                                  l_opgitm.atdsrvano)
                        returning l_sqlcode, l_sqlerrd
                        
        if l_sqlerrd != 1
           then
           let l_msg = " Erro (", sqlca.sqlcode,
                       ") no cancelamento pagamento do servico ", 
                       l_opgitm.atdsrvnum using "&&&&&&", "-",
                       l_opgitm.atdsrvano using "&&"
           close c_opgitm_sel
           return 1, l_msg
        end if 
    end if 
  end foreach
  
  #### Chamado para cancelar OP CT 763527  Beatriz Araujo
  #### ela pode ser cancelada sem Itens
  ##### nao achou itens
  ####if l_opgitm.atdsrvnum is null
  ####   then
  ####   let l_msg =  " Erro na consulta aos itens da OP: ",
  ####                l_sqlcode, " | OP: ", l_socopgnum
  ####   return 1, l_msg
  ####else
  ####   display 'Cancela OP: update servicos OK'
  ####end if
  #### Fim do Chamado
  
  
  
  # inserir etapa
  whenever error continue
  call cts50g00_insere_etapa(l_opgitm.socopgnum, 5,g_issk.funmat)
       returning l_sqlcode, l_msg
  whenever error stop
       
  if l_sqlcode != 1
     then
     let l_msg =  "OP: ", l_socopgnum,
                  " | Erro (", l_sqlcode, ") na gravacao da fase da OP"
     return 1, l_msg
  else
     display 'Cancela OP: etapa OK'
  end if
  
  # atualiza status OP
  whenever error continue
  update dbsmopg set socopgsitcod = 8
  where socopgnum = l_socopgnum
  whenever error stop
 
  if sqlca.sqlcode != 0 or
     sqlca.sqlerrd[3] != 1
     then
     let l_msg = " Erro na atualizacao da OP(emissao): ", sqlca.sqlcode,
                 "|", sqlca.sqlerrd[3] , " OP: ", l_socopgnum
     return 1, l_msg
  else
     display 'Cancela OP: OP OK'
     return 0, ''
  end if
  
end function

