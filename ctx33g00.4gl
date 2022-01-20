#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: ctx33g00                                                   #
# ANALISTA RESP..: Fabio Costa                                                #
# PSI/OSF........: 198404                                                     #
# DATA...........: 10/05/2008                                                 #
# OBJETIVO.......: Confirmacao da emissao da OP apos interface com o People,  #
#                  inserir tributacao, fase, observacao e atualizar OP        #
#                  Retorno da solicitacao de cancelamento no People, chamada  #
#                  pelo on-line do PS ou direto pelo People                   #
# Observacoes: Erros possiveis: retorno 1 = erro de sql (sel,ins,upd)         #
#                               retorno 2 = dados inconsistentes              #
# ........................................................................... #
# Alteracoes                                                                  #
# 22/06/2009  PSI198404  Fabio Costa  Tratar cancelamento People              #
# 23/07/2009  PSI198404  Fabio Costa  Nao utilizar fun_dba_abre_banco         #
#-----------------------------------------------------------------------------#
# Observacoes:                                                                #
# Nao gravar report em pastas padrao PS pois nao existem no servidor do listener
#-----------------------------------------------------------------------------#
database porto

define m_arq char(100)

#----------------------------------------------------------------
function ctx33g00_retpeople(l_retorno)
#----------------------------------------------------------------

  define l_retorno record
         pgtcmpnum        decimal(8,0),      # nro da op gerada
         pgtcmpdocnum     decimal(10,0),     # nro docto referencia legado
         ppsopgprvdadseq  integer,           # nro do protocolo
         cmporgcod        smallint,          # codigo origem
         empcod           decimal(2,0),      # codigo da empresa 
         gerdat           date,              # data geracao da op
         pgtliqvlr        decimal(15,5),     # valor liquido
         irfvlr           decimal(15,5),     # valor do ir
         insvlr           decimal(15,5),     # valor do inss
         issvlr           decimal(15,5),     # valor do iss
         pisvlr           decimal(15,5),     # valor do pis
         cofvlr           decimal(15,5),     # valor do cofins
         cslvlr           decimal(15,5),     # valor do csll
         bank_id_nbr      char(010),         # banco
         branch_id        char(010),         # agencia
         pymnt_method     char(005),         # metodo pagamento
         multa_tot        char(020),         # multa
         juros_tot        char(020),         # juros
         opgcanerrcod     smallint,          # codigo do erro
         errmsgtxt        char(200)          # mensagem de erro
  end record
  
  define l_opgitm record
         atdsrvnum  like dbsmopgitm.atdsrvnum ,
         atdsrvano  like dbsmopgitm.atdsrvano
  end record
  
  define l_socopgsitcod  like dbsmopg.socopgsitcod,
         l_succod        like dbsmopg.succod,
         l_socopgobsseq  like dbsmopgobs.socopgobsseq,
         l_obs           like dbsmopgobs.socopgobs
  
  define l_stt      smallint, 
         l_err      integer,
         l_msg      char(100),
         l_data     date,
         l_hora     datetime hour to minute,
         l_txt      char(250),
         l_html     char(32000),
         l_sqlcode  integer ,
         l_sqlerrd  integer
         
  initialize l_err, l_msg, l_socopgsitcod, l_socopgobsseq, l_succod, 
             l_obs, l_data, l_hora to null
             
             
  let m_arq = "./OPRET.txt"
  
  start report ctx33g00_resumo to m_arq
  
  let l_txt = 'OP.PS.....:' , l_retorno.pgtcmpdocnum
  output to report ctx33g00_resumo(l_txt)
  
  let l_txt = 'OP.People.:' , l_retorno.pgtcmpnum
  output to report ctx33g00_resumo(l_txt)
  
  let l_txt = '----------------------------------------------------------------------'
  output to report ctx33g00_resumo(l_txt)
  
  # tratar retorno codigo de erro nulo, nao e possivel tratar a OP
  if l_retorno.opgcanerrcod is null 
     then
     let l_err = 1
     let l_msg = "OP PS - Codigo de erro nulo | OP: ", l_retorno.pgtcmpdocnum
     output to report ctx33g00_resumo(l_msg)
     call ctx33g00_mail(l_retorno.pgtcmpdocnum, 'E')
     return l_err, l_msg
  end if
  
  let l_stt = 7
  let l_err = 0
  let l_msg = null
  
  set lock mode to wait
  
  # erro geracao OP no people
  if l_retorno.opgcanerrcod != 0 
     then
     
     # retorna status para ok p/emissao, emitir novamente
     let l_stt = 6
     let l_err = 0
     let l_msg = l_retorno.errmsgtxt clipped, " OP: ", 
                 l_retorno.pgtcmpnum using "<<<<<<<<<<"
                 
     # cancelamento da data de pagamento do servico
     whenever error continue
        declare c_opgitm_sel01 cursor with hold for
        select i.atdsrvnum, i.atdsrvano
        from dbsmopg o, dbsmopgitm i, datmservico s
        where o.socopgnum = i.socopgnum
          and i.atdsrvnum = s.atdsrvnum
          and i.atdsrvano = s.atdsrvano
          and i.socopgnum = l_retorno.pgtcmpdocnum
        order by i.socopgitmnum
     whenever error stop
     
     initialize l_opgitm.* to null
     
     foreach c_opgitm_sel01 into l_opgitm.*
        call ctd07g00_upd_srv_pgtdat('', l_opgitm.atdsrvnum, l_opgitm.atdsrvano)
             returning l_sqlcode, l_sqlerrd
     end foreach
     
  else
  
     # buscar dados da OP
     whenever error continue
     select socopgsitcod, succod into l_socopgsitcod, l_succod
     from dbsmopg 
     where socopgnum = l_retorno.pgtcmpdocnum
     whenever error stop
     
     if sqlca.sqlcode != 0 then
        let l_err = sqlca.sqlcode
        let l_stt = 6
        let l_msg =  "OP PS - Erro na consulta ao docto referencia legado: ",
                     l_err, " | OP: ", l_retorno.pgtcmpdocnum
     end if
     
     # verificar status retorno People
     if l_stt = 7
        then
        if l_socopgsitcod != 10 
           then
           let l_err = 1
           let l_stt = 6
           let l_msg = "OP PS - Docto nao esta na fase de aguardando retorno People, verifique",
                       " | OP: ", l_retorno.pgtcmpdocnum
        end if
     end if
     
     # inserir tributos da OP
     if l_stt = 7
        then
        if l_retorno.pgtliqvlr > 0 or l_retorno.irfvlr > 0 or
           l_retorno.issvlr    > 0 or l_retorno.insvlr > 0 or
           l_retorno.pisvlr    > 0 or l_retorno.cofvlr > 0 or
           l_retorno.cslvlr    > 0 
           then
           
           whenever error continue
           select * 
           from dbsmopgtrb
           where socopgnum = l_retorno.pgtcmpdocnum
           whenever error stop
           
           if sqlca.sqlcode = 100 
              then
              whenever error continue
              insert into dbsmopgtrb(socopgnum   , empcod   , succod   , prstip   ,
                                     soctrbbasvlr, socirfvlr, socissvlr, insretvlr,
                                     pisretvlr   , cofretvlr, cslretvlr)
                             values (l_retorno.pgtcmpdocnum,
                                     l_retorno.empcod,
                                     l_succod, "P",
                                     l_retorno.pgtliqvlr,
                                     l_retorno.irfvlr,
                                     l_retorno.issvlr,
                                     l_retorno.insvlr,
                                     l_retorno.pisvlr,
                                     l_retorno.cofvlr,
                                     l_retorno.cslvlr)
              whenever error stop
              
              if sqlca.sqlcode != 0
                 then
                 let l_err = sqlca.sqlcode
                 let l_stt = 6
                 let l_msg = "OP PS - Erro na insercao Tributos da OP: ", l_err,
                             " | OP: ", l_retorno.pgtcmpdocnum
              end if
              
           else
           
              whenever error continue
              update dbsmopgtrb set soctrbbasvlr = l_retorno.pgtliqvlr,
                                    socirfvlr    = l_retorno.irfvlr   ,
                                    socissvlr    = l_retorno.issvlr   ,
                                    insretvlr    = l_retorno.insvlr   ,
                                    pisretvlr    = l_retorno.pisvlr   ,
                                    cofretvlr    = l_retorno.cofvlr   ,
                                    cslretvlr    = l_retorno.cslvlr
                              where socopgnum = l_retorno.pgtcmpdocnum
              whenever error stop
              
              if sqlca.sqlerrd[3] != 1
                 then
                 let l_err = 1
                 let l_stt = 6
                 let l_msg = "OP PS - Erro na atualizacao Tributos da OP: ", l_err,
                             " | OP: ", l_retorno.pgtcmpdocnum
              end if
           end if
        end if
     end if
     
     # inserir Observacao da OP
     if l_stt = 7
        then
        whenever error continue
        select max(socopgobsseq) into l_socopgobsseq 
        from dbsmopgobs
        where socopgnum = l_retorno.pgtcmpdocnum
        whenever error stop
        
        if l_socopgobsseq is null then
           let l_socopgobsseq = 0
        end if
        
        let l_socopgobsseq = l_socopgobsseq + 1
        
        let l_obs = "OP emitida no People, numero: ", 
                    l_retorno.pgtcmpnum using "<<<<<<<<<<"
        
        whenever error continue
        insert into dbsmopgobs(socopgnum, 
                               socopgobsseq, 
                               socopgobs)
                        values(l_retorno.pgtcmpdocnum, 
                               l_socopgobsseq, 
                               l_obs)
        whenever error stop
        
        if sqlca.sqlcode != 0 
           then
           let l_err = sqlca.sqlcode
           let l_stt = 6
           let l_msg = "OP PS - Erro na insercao da Observacao da OP: ", l_err,
                       " | OP: ", l_retorno.pgtcmpdocnum
        end if
     end if
     
     # atualizar fase da OP
     if l_stt = 7
        then
        let l_hora = current
        let l_data = today
        
        whenever error continue
        insert into dbsmopgfas(socopgnum   , socopgfascod, socopgfasdat,
                               socopgfashor, funmat)
                       values (l_retorno.pgtcmpdocnum, 4, l_data,
                               l_hora, 999999)
        whenever error stop
        
        if sqlca.sqlcode != 0 
           then
           let l_err = sqlca.sqlcode
           let l_stt = 6
           let l_msg = "OP PS - Erro na insercao da fase da OP: ", 
                       l_err using "<<<<<<<<", " | OP: ", l_retorno.pgtcmpdocnum
        end if
     end if
     
     # todo o processo ok, OP em status EMITIDA
     let l_err = 0
     let l_stt = 7
     let l_msg = null 
     
  end if
  
  # atualizar OP
  whenever error continue
  update dbsmopg set socopgsitcod = l_stt
  where socopgnum = l_retorno.pgtcmpdocnum 
  whenever error stop
  
  if sqlca.sqlcode != 0 or
     sqlca.sqlerrd[3] != 1
     then
     let l_err = 1
     let l_msg = "OP PS - Erro na atualizacao da OP(emissao): ", sqlca.sqlcode,
                 "|", sqlca.sqlerrd[3] ,
                 " OP: ", l_retorno.pgtcmpdocnum
  end if
  
  # erro na atualizacao
  if l_err != 0 or
     l_msg is not null 
     then
     let l_txt = 'PEOPLE - Erro na emissao: ', l_retorno.opgcanerrcod
     output to report ctx33g00_resumo(l_txt)
     
     let l_txt = 'Descricao People.....: ', l_retorno.errmsgtxt
     output to report ctx33g00_resumo(l_txt)
     
     let l_msg = 'Descricao Informix PS: ', l_msg clipped
     output to report ctx33g00_resumo(l_msg)
     
     let l_txt = 'OP PS - Atualizada para status OK PARA EMISSAO'
     output to report ctx33g00_resumo(l_txt)
     
     call ctx33g00_mail(l_retorno.pgtcmpdocnum, 'E')
     return l_err, l_msg
  end if
  
  finish report ctx33g00_resumo
  return l_err, l_msg
  
end function


#----------------------------------------------------------------
function ctx33g00_retpeople_canopg(lr_param)
#----------------------------------------------------------------

  define lr_param record
         empcod            decimal(2,0),   # codigo da empresa
         cmporgcod         smallint,       # codigo origem
         pgtcmpdocnum      decimal(10,0),  # nro docto referencia legado
         pgtcmpnum         integer,        # nro da op gerada
         ppsopgcanmtvcod   smallint,       # codigo motivo cancelamento OP PeopleSoft
         atlmat            dec(6,0),
         atlemp            dec(2,0),
         errcod            smallint        # status cancelamento People
  end record
  
  define l_opgitm record
         socopgnum  like dbsmopg.socopgnum    ,
         soctip     like dbsmopg.soctip       ,
         atdsrvnum  like dbsmopgitm.atdsrvnum ,
         atdsrvano  like dbsmopgitm.atdsrvano ,
         ciaempcod  like datmservico.ciaempcod,
         atdsrvorg  like datmservico.atdsrvorg,
         atdcstvlr  like datmservico.atdcstvlr
  end record
  
  define l_ctt      smallint ,
         l_stt      smallint ,
         l_err      integer  ,
         l_msg      char(100),
         l_txt      char(250),
         l_sqlcode  integer  ,
         l_sqlerrd  integer  ,
         l_qtdsrv   integer
         
  initialize l_opgitm.* to null
  
  let l_ctt = null
  let l_stt = 8
  let l_err = 0
  let l_msg = null
  let l_txt = null
  let l_sqlcode = 0
  let l_sqlerrd = 1
  let l_qtdsrv  = 0

  let m_arq = "./OPRET.txt"
  
  start report ctx33g00_resumo to m_arq
  
  let l_txt = 'OP.PS.....:' , lr_param.pgtcmpdocnum
  output to report ctx33g00_resumo(l_txt)
  
  let l_txt = 'OP.People.:' , lr_param.pgtcmpnum
  output to report ctx33g00_resumo(l_txt)
  
  let l_txt = '----------------------------------------------------------------------'
  output to report ctx33g00_resumo(l_txt)
  
  
  display 'CTX33G00: OP ', lr_param.pgtcmpdocnum
  display '  chamada PEOPLE:'
  display '  lr_param.empcod         : (', lr_param.empcod         ,')'
  display '  lr_param.cmporgcod      : (', lr_param.cmporgcod      ,')'
  display '  lr_param.pgtcmpdocnum   : (', lr_param.pgtcmpdocnum   ,')'
  display '  lr_param.pgtcmpnum      : (', lr_param.pgtcmpnum      ,')'
  display '  lr_param.ppsopgcanmtvcod: (', lr_param.ppsopgcanmtvcod,')'
  display '  lr_param.atlmat         : (', lr_param.atlmat         ,')'
  display '  lr_param.atlemp         : (', lr_param.atlemp         ,')'
  display '  lr_param.errcod         : (', lr_param.errcod         ,')'
  
       
  set lock mode to wait
  
  if lr_param.errcod = 0   # cancelamento realizado no People
     then
     
     #----------------------------------------------------------------
     # cancelamento do pagamento do servico
     whenever error continue
        declare c_opgitm_sel02 cursor with hold for
        select o.socopgnum, o.soctip
             , i.atdsrvnum, i.atdsrvano
             , s.ciaempcod, s.atdsrvorg, s.atdcstvlr
        from dbsmopg o, dbsmopgitm i, datmservico s
        where o.socopgnum = i.socopgnum
          and i.atdsrvnum = s.atdsrvnum
          and i.atdsrvano = s.atdsrvano
          and i.socopgnum = lr_param.pgtcmpdocnum
        order by i.socopgitmnum
     whenever error stop
     
     foreach c_opgitm_sel02 into l_opgitm.*
        
        let l_qtdsrv = l_qtdsrv + 1
        
        if l_opgitm.atdsrvorg != 2
           then
           initialize l_opgitm.atdcstvlr to null
        end if
        
        call ctd07g00_upd_srv_opg('', 
                                  l_opgitm.atdcstvlr,
                                  l_opgitm.atdsrvnum,
                                  l_opgitm.atdsrvano)
                        returning l_sqlcode, l_sqlerrd
                        
        if l_sqlerrd != 1
           then
           let l_err = 1
           let l_stt = 7
           let l_msg = "OP PS - Erro (", sqlca.sqlcode, ") no cancelamento pagamento do servico ", 
                       l_opgitm.atdsrvnum using "&&&&&&&&", "-",
                       l_opgitm.atdsrvano using "&&",
                       " | OP: ", lr_param.pgtcmpdocnum
                       
           display 'CTX33G00: ', l_msg clipped
        end if
     end foreach
     
     # nao achou itens
     if l_opgitm.atdsrvnum is null
        then
        let l_err = 1
        let l_stt = 7
        let l_msg =  "OP PS - Erro na consulta aos itens da OP: ",
                     l_err, " | OP: ", lr_param.pgtcmpdocnum
        display 'CTX33G00: ', l_msg clipped
     end if
     
     display 'CTX33G00: Qtd servicos: ', l_qtdsrv
     
     #----------------------------------------------------------------
     # cancelamento contabil
     if l_stt = 8
        then
        if lr_param.empcod = 1  # so empresa 1 provisiona
           then
           if l_opgitm.soctip = 1
              then
              # OP PORTO SOCORRO
              whenever error continue
              select count(*) into l_ctt
              from ctimsocor
              where socopgnum = lr_param.pgtcmpdocnum
              whenever error stop
              
              if l_ctt is not null and
                 l_ctt > 0
                 then
                 whenever error continue
                 update ctimsocor set atldat = today, canflg = "C"
                 where socopgnum = lr_param.pgtcmpdocnum
                 whenever error stop
                 
                 if sqlca.sqlcode != 0
                    then
                    let l_err = sqlca.sqlcode
                    let l_stt = 7
                    let l_msg = "OP PS: ", lr_param.pgtcmpdocnum,
                                " | Erro (", sqlca.sqlcode,
                                ") no cancelamento do lancamento contabil!"
                    display 'CTX33G00: ', l_msg clipped
                 else
                    display 'CTX33G00: Update provisao OK'
                 end if
              end if
           else
              # OP CARRO EXTRA
              select count(*) into l_ctt
              from ctimextcrrprv
              where opgnum = lr_param.pgtcmpdocnum
              
              if l_ctt is not null and
                 l_ctt > 0
                 then
                 whenever error continue
                 update ctimextcrrprv set atldat = today, opgcncflg = "S"
                 where opgnum = lr_param.pgtcmpdocnum
                 whenever error stop
                 
                 if sqlca.sqlcode != 0
                    then
                    let l_err = sqlca.sqlcode
                    let l_stt = 7
                    let l_msg = "OP CARRO EXTRA: ", lr_param.pgtcmpdocnum,
                                " | Erro (", sqlca.sqlcode, 
                                ") no cancelamento do lancamento contabil!"
                    display 'CTX33G00: ', l_msg clipped
                 else
                    display 'CTX33G00: Update provisao OK'
                 end if
              end if
           end if
        end if
     end if
     
     #----------------------------------------------------------------
     # inserir etapa
     if l_stt = 8
        then
        call cts50g00_insere_etapa(l_opgitm.socopgnum, 5, 999999)
             returning l_err, l_msg
             
        if l_err != 1
           then
           let l_err = 1
           let l_stt = 7
           let l_msg =  "OP: ", lr_param.pgtcmpdocnum, " | ", l_msg clipped
           display 'CTX33G00: ', l_msg clipped
        else
           display 'CTX33G00: etapa OK'
        end if
     end if
     
     # cancelamento ok
     let l_stt = 8
     let l_err = 0
     let l_msg = null
     
  else
  
     # cancelamento nao foi possivel no People, atualizar OP para status EMITIDA
     let l_stt = 7
     let l_err = 0
     let l_msg = ' Nao foi possivel cancelamento no People, contate o Contas a Pagar '
     
  end if
  
  #----------------------------------------------------------------
  # atualiza status OP
  whenever error continue
  update dbsmopg set socopgsitcod = l_stt
  where socopgnum = lr_param.pgtcmpdocnum
  whenever error stop
  
  if sqlca.sqlcode != 0 or
     sqlca.sqlerrd[3] != 1
     then
     let l_err = 1
     let l_msg = "Erro na atualizacao da OP(emissao): ", sqlca.sqlcode,
                 "|", sqlca.sqlerrd[3] , " OP: ", lr_param.pgtcmpdocnum
     display 'CTX33G00: ', l_msg clipped
  else
     display 'CTX33G00: Update OP OK'
  end if
  
  # erro na atualizacao
  if l_err != 0 or
     l_msg is not null 
     then
     let l_txt = 'PEOPLE - Erro no cancelamento: ', lr_param.errcod
     output to report ctx33g00_resumo(l_txt)
     
     error l_msg   # quando estimulo pelo online, mostrar na tela
     
     display 'CTX33G00: msg erro: ', l_msg clipped
     
     let l_msg = 'Descricao Informix PS: ', l_msg clipped
     output to report ctx33g00_resumo(l_msg)
     
     call ctx33g00_mail(lr_param.pgtcmpdocnum, 'E')
     return l_err, l_msg
     display 'CTX33G00: envio email: ', l_err, ' | ', l_msg
  end if
  
  display 'CTX33G00: Procedimento Informix finalizado ', l_msg clipped
  
  error ' OP cancelada com sucesso ' # quando estimulo pelo online, mostrar na tela
  
  finish report ctx33g00_resumo
  
  return l_err, l_msg
  
end function

#----------------------------------------------------------------
function ctx33g00_mail(l_pgtcmpdocnum, l_tipo)
#----------------------------------------------------------------

  define l_ret           integer  ,
         l_assunto       char(80) ,
         l_pgtcmpdocnum  decimal(10,0),
         l_tipo          char(1)
         
  finish report ctx33g00_resumo
  
  if l_tipo = 'C'
     then
     let l_assunto = 'Resumo de cancelamento da OP: ', 
                     l_pgtcmpdocnum using "<<<<<<<<<<"
  else
     let l_assunto = 'Resumo de emissão da OP: ', l_pgtcmpdocnum using "<<<<<<<<<<"
  end if
  
  call ctx22g00_mail_anexo_corpo("CTX33G00", l_assunto, m_arq) returning l_ret
  
  if l_ret != 0 then
     if l_ret != 99 then
        display "Erro ao enviar email(ctx22g00) - ", m_arq
     else
        display "Nao ha email cadastrado para o modulo "
     end if
  end if
  
end function

#--------------------------------------------------------------------------
report ctx33g00_resumo(l_linha)
#--------------------------------------------------------------------------
  define l_linha char(250)
  
  output
  
     left margin     0
     bottom margin   0
     top margin      0
     right margin  202
     page length    20
    
  format
  
     on every row
        print column 01, l_linha clipped
        
end report
