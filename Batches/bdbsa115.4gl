#============================================================================
# Sistema   : PORTO SOCORRO
# Modulo    : bdbsa115.4gl
# Objetivo  : Atualizar dados na tabela de ligacao da apolice com documento de
#             origem (proposta, vistoria previa ou cobertura provisoria)
# Projeto   : PSI 211214
# Analista  : Fabio Oliveira/Norton Nery (Meta)
# Liberacao : xx/12/2007
# Observacoes:
#===========================================================================
# Alteracoes:
#===========================================================================

database porto

define m_atddat  date
define m_saida   char(120)
define m_path	   char(100)
define m_msg     char(80)
define m_log        char(20)

define m_upd     integer
     , m_proc    integer
     , m_desp    integer
     , m_emi     integer
     , teste     char(1)

main
   call f_path("DBS", "LOG") returning m_saida

   if m_saida is null then
       let m_log = "bdbsa115.log"
   else
       let m_log = m_saida clipped, "/bdbsa115.log"
   end if

   call startlog (m_log)

   call fun_dba_abre_banco("CT24HS")
   
   set lock mode to wait 30

   #let m_path   = m_path clipped, "bdbsa115.xxx"
   let m_atddat = (today - 2 units month)

   display 'BDBSA115  - Atualizacao tabela datrligapol  e datrservapol'
   display "----------------------------------------------------"
   display 'Data referencia: ', m_atddat
   #display 'Arquivo: ', m_path clipped
   display "----------------------------------------------------"

   call bdbsa115_sql()

   call bdbsa115()

   display "BDBSA115_Termino"

end main

#----------------------------------------------------------------
function bdbsa115_sql()
#----------------------------------------------------------------
   define l_cmd char(400)

   # seleciona as ligacoes dos ultimos 2 meses
   let l_cmd = " select lignum, atdsrvnum, atdsrvano "
              ," from datmligacao  "
              ," where ligdat >= ? "
   prepare p_ligacao_sel from l_cmd
   declare c_ligacao_sel cursor with hold for  p_ligacao_sel

   # seleciona servicos da ligacao realizada
   let l_cmd = " select atdsrvnum,atdsrvano "
              ," from datmservico  "
              ," where atdsrvnum = ? "
             ,"  and  atdsrvano = ? "
   prepare p_servico_sel from l_cmd
   declare c_servico_sel cursor with hold for p_servico_sel

   # seleciona ligacao ligada a proposta
   let l_cmd = " select prporg, prpnumdig "
              ," from datrligprp "
              ," where lignum = ? "
   prepare p_proposta_sel from l_cmd
   declare c_proposta_sel cursor for p_proposta_sel

   # seleciona ligacao ligada a cobertura previa ou vistoria
   let l_cmd = " select ligdcttip, ligdctnum "
              ," from datrligsemapl  "
              ," where lignum = ? "
   prepare p_vistoria_sel from l_cmd
   declare c_vistoria_sel cursor for p_vistoria_sel

   # seleciona datrligapol
   let l_cmd = " select lignum  "
              ," from datrligapol    "
              ," where lignum = ? "
   prepare p_ligapol_sel from l_cmd
   declare c_ligapol_sel cursor for p_ligapol_sel

   # seleciona datrservapol
   let l_cmd = " select atdsrvnum,atdsrvano "
              ," from datrservapol   "
              ," where  atdsrvnum = ? "
              ,"    and atdsrvano = ? "
   prepare p_servapol_sel from l_cmd
   declare c_servapol_sel cursor for p_servapol_sel

   # seleciona ctimsocprv
   let l_cmd = " select count(*) "
              ," from ctimsocprv  "
              , " where  atdsrvnum = ? "
              ,  "    and atdsrvano = ? "
   prepare p_ctimsocprv_sel from l_cmd
   declare c_ctimsocprv_sel cursor for p_ctimsocprv_sel

   # inserir apolice X ligacao
   let l_cmd = " insert into datrligapol ( succod   , ramcod   , aplnumdig , ",
                                       "   itmnumdig, edsnumref, lignum , ",
                                       "   dcttxt   , atldat ) ",
                                " values ( ?,?,?,?,?,?,?,? ) "
   prepare p_ligapol_ins from l_cmd

   # inserir registro servico apolice
   let l_cmd = " insert into datrservapol ( succod   , ramcod   , aplnumdig, ",
                                        "   itmnumdig, edsnumref, atdsrvnum, ",
                                        "   atdsrvano ) ",
                                 " values ( ?,?,?,?,?,?,? ) "
   prepare p_servapol_ins from l_cmd

   # deletar registro de documento de ligacao datrligprp "
   let l_cmd = " delete from datrligprp "
             , " where lignum = ? "
   prepare p_ligprp_del from l_cmd

   # deletar registro de documento de ligacao
   let l_cmd = " delete from datrligsemapl "
             , " where lignum = ? "
   prepare p_ligsemapl_del from l_cmd

end function

#----------------------------------------------------------------
function bdbsa115()
#----------------------------------------------------------------
   define l_ligacao record
          lignum     like datmligacao.lignum,
          atdsrvnum  like datmligacao.atdsrvnum ,
          atdsrvano  like datmligacao.atdsrvano           
   end record

   define l_aux record
          msg        char(80)                   ,
          lignum     like datmligacao.lignum    ,
          resultado  smallint                   ,
          mensagem   char(60)                   ,
          succod     like abamapol.succod       ,
          aplnumdig  like abamapol.aplnumdig    ,
          itmnumdig  like abbmitem.itmnumdig    ,
          ramcodret  like gtakram.ramcod        ,
          prporg     like datrligprp.prporg     ,
          prpnumdig  like datrligprp.prpnumdig  ,
          doctip     char(3)                    ,
          docorg     like datrligprp.prporg     ,
          docnum     dec(10,0)                  ,
          doctxt     char(20)                   ,
          atldat     like datrligapol.atldat    ,
          errcod     smallint                   ,
          ramcod     like gtakram.ramcod        ,
          corsus     like gcaksusep.corsus      ,
          ramdsc     char(4)                    ,
          edsnumdig  like abamdoc.edsnumdig     ,
          ligdcttip  like datrligsemapl.ligdcttip,
          ligdctnum  like datrligsemapl.ligdctnum
   end record
   
    
   define lr_erro record         
       err    smallint,          
       msgerr char(2000)          
   end record  
   
   
   define lr_ctimsocprv record                  
         evento                  char(06),                
         empresa                 char(50),
         dt_movto                date,
         chave_primaria          char(50),
         op                      char(50),
         apolice                 char(50),
         sucursal                char(50),
         projeto                 char(50),
         dt_chamado              date,
         fvrcod                  char(50),
         fvrnom                  char(50),
         nfnum                   char(50),
         corsus                  char(50),
         cctnum                  char(50),
         modalidade              char(50),
         ramo                    char(50),
         opgvlr                  char(50),
         dt_vencto               date,
         dt_ocorrencia           date
   end record
   
  define l_errcod      smallint ,
          l_lignum_tmp  dec(10,0),
          l_erro        smallint,
          l_mens_erro   char(100),
          l_lignum      like datmligacao.lignum,
          l_atdsrvnum   like datmligacao.atdsrvnum ,
          l_atdsrvano   like datmligacao.atdsrvano,
          l_atddat      like datmservico.atddat,    # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
          l_lidos       integer,
          l_status      smallint,
          l_param_tip   char(1),
	  l_ctr         smallint

   let m_upd  = 0
   let m_proc = 0
   let m_desp = 0
   let m_emi  = 0
   let l_ctr  = 1

   initialize l_aux.* to null
   
   open c_ligacao_sel using m_atddat

   foreach c_ligacao_sel into l_ligacao.*

      let m_proc = m_proc + 1
      INitialize l_aux.* to null

      let l_aux.atldat = today
      let l_aux.lignum = l_ligacao.lignum

      # identificar documento gerador do servico
      call ctb00g11(l_aux.lignum) returning l_aux.doctip ,
                                            l_aux.docorg ,
                                            l_aux.docnum ,
                                            l_aux.doctxt ,
                                            l_aux.errcod

      if l_aux.doctip is null then
        -- let m_desp = m_desp + 1
         continue foreach
      end if

      # verifica  se tem proposta para a ligacao
      open c_proposta_sel using l_aux.lignum
      fetch c_proposta_sel   into l_aux.prporg, l_aux.prpnumdig

      begin work

      if (l_aux.prporg   is not null and
          l_aux.prporg   <> 0        and
          l_aux.prporg   <> ' ' )    then


         call faemc696_proposta(l_aux.prporg,l_aux.prpnumdig )
                 returning l_aux.succod,l_aux.ramcod,l_aux.aplnumdig,
                           l_aux.itmnumdig, l_aux.edsnumdig, l_status

         let l_ctr = 0

         if l_status = 1 then
            let l_mens_erro = 'Nao Realizou a Pesquisa da Proposta : ',
                        l_aux.prporg,'-',l_aux.prpnumdig,'-',sqlca.sqlcode
            call errorlog(l_mens_erro)
	   let l_ctr = 1
        end if

        if (l_aux.succod    is null and
	    l_aux.ramcod    is null and
	    l_aux.aplnumdig is null and
            l_aux.itmnumdig is null and
	    l_aux.edsnumdig is null) and
	    l_ctr           = 0     then
            let l_mens_erro = 'Nao Realizou a Pesquisa da Proposta : ',
                        l_aux.prporg,'-',l_aux.prpnumdig,'-',sqlca.sqlcode
            call errorlog(l_mens_erro)
	   let l_ctr = 1
	end if

	if l_ctr = 0   then
           # deletar docto na tabela datrliprp
            execute p_ligprp_del using l_aux.lignum

           if sqlca.sqlerrd[3] = 0 then  #TODO: usar mesmo sqlca.sqlerrd[3] ?
              let l_mens_erro = 'Erro na atualizacao da tab datrliprp, erro: ',
                                l_aux.lignum,'-',sqlca.sqlcode
               call errorlog(l_mens_erro)
   	      let l_ctr = 1
           end if
        end if
      else
        # verificar se tem vistoria ou cobertura provisoria para a ligacao
        open c_vistoria_sel using l_aux.lignum
        fetch c_vistoria_sel   into l_aux.ligdcttip, l_aux.ligdctnum

        if l_aux.ligdcttip = 1 Then
           let l_param_tip = "V"
         else
           let l_param_tip = "C"
        end if

        if (l_aux.ligdcttip is not null  and
            l_aux.ligdcttip <> 0         and
            l_aux.ligdcttip <> ' ') then

           call faemc696_vistoria(l_aux.ligdctnum,l_param_tip)
                   returning l_aux.succod,l_aux.ramcod,l_aux.aplnumdig,
                             l_aux.itmnumdig, l_aux.edsnumdig, l_status

	  let l_ctr = 0

          if l_status = 1 then
              let l_mens_erro = 'Nao Realizou a Pesquisa da vistoria : ',
                               l_aux.ligdctnum,'-',l_status
              call errorlog(l_mens_erro)
	      let l_ctr = 1
          end if

          if (l_aux.succod    is null and
	      l_aux.ramcod    is null and
	      l_aux.aplnumdig is null and
              l_aux.itmnumdig is null and
	      l_aux.edsnumdig is null) then
              let l_mens_erro = 'Retorno da Vistoria em branco : ',
                                l_aux.ligdctnum
              call errorlog(l_mens_erro)
	      let l_ctr = 1
          end if

          if l_ctr = 0 then
             # deletar docto na tabela datrligsemapl
             execute p_ligsemapl_del using l_aux.lignum

             if sqlca.sqlerrd[3] = 0 then  #TODO: usar mesmo sqlca.sqlerrd[3] ?
                let l_mens_erro =
                'Erro na atualizacao da tab datrligsemapl,erro: ',l_aux.lignum,
		'-',sqlca.sqlcode
                 call errorlog(l_mens_erro)
   	        let l_ctr = 1
             end if
          end if
        end if
      end if

      if l_ctr    =  0   then
         # verifica a existencia na datrligapol

         open c_ligapol_sel using l_aux.lignum
         fetch c_ligapol_sel   into l_lignum

         if sqlca.sqlcode = 100 then

            # Incluir na tabela datrligapol
             execute p_ligapol_ins using l_aux.succod,
                                        l_aux.ramcod,
                                        l_aux.aplnumdig,
                                        l_aux.itmnumdig,
                                        l_aux.edsnumdig,
                                        l_aux.lignum,
                                        l_aux.doctxt,
                                        l_aux.atldat

            if sqlca.sqlcode != 0 then
               if sqlca.sqlcode = -239 or
                  sqlca.sqlcode = -268 then
                  let l_mens_erro = "datrligapol  ja existe, continuando...",
                                    l_aux.lignum
                  call errorlog(l_mens_erro)
               else
                  let l_mens_erro = 'Erro na atualizacao datrligapol, erro: ',
                                    l_aux.lignum,'-',sqlca.sqlcode
                  call errorlog(l_mens_erro)
	                let l_ctr = 1
               end if
            end if
         end if
         
	       if l_ctr = 0 then
            let l_lignum_tmp = 0
            let l_erro       = 0
            
            # verifica se tem servicos para a ligacao
            open c_servico_sel using l_ligacao.atdsrvnum,
                                     l_ligacao.atdsrvano
            
            fetch c_servico_sel into l_atdsrvnum,
                                  l_atdsrvano
            
            if sqlca.sqlcode = 0 then
            
              # verifica a existenca na servapol
              open c_servapol_sel using l_ligacao.atdsrvnum,
                                        l_ligacao.atdsrvano
            
              fetch c_servapol_sel   into l_atdsrvnum,
                                          l_atdsrvano
            
              if sqlca.sqlcode = 100 then
            
                 #TODO: buscar parametros
                 # inserir docto na na tabela servicos com apolice
                 execute p_servapol_ins using l_aux.succod,
                                              l_aux.ramcod,
                                              l_aux.aplnumdig,
                                              l_aux.itmnumdig ,
                                              l_aux.edsnumdig,
                                              l_ligacao.atdsrvnum,
                                              l_ligacao.atdsrvano
            
                 if sqlca.sqlcode != 0 then
                   if sqlca.sqlcode = -239 or
                      sqlca.sqlcode = -268 then
                      let l_mens_erro =
                      "datrservapol ja existe, continuando...",l_aux.aplnumdig
                      call errorlog(l_mens_erro)
                   else
                      let l_mens_erro = 'Erro na atualizacao datrservapol, erro: ',
                         l_aux.aplnumdig,'-',sqlca.sqlcode
                      call errorlog(l_mens_erro)
	                    let l_ctr = 1
                   end if
                 end if
              end if
            end if
         
	          if l_ctr = 0 then
               # verifica se existe na ctimsocprv
               let l_lidos = 0
               open c_ctimsocprv_sel using l_ligacao.atdsrvnum,
                                           l_ligacao.atdsrvano
               
               fetch c_ctimsocprv_sel into l_lidos
               
               if l_lidos > 0 then
                
                 display "chamei a baixa do provisionamento ctb00g03_bxaprvdsp : ",l_ligacao.atdsrvnum,"-",l_ligacao.atdsrvano
                 call ctb00g03_bxaprvdsp(l_ligacao.atdsrvnum,
                                         l_ligacao.atdsrvano)
                     returning l_errcod, lr_ctimsocprv.*
                 if l_errcod <> 0 then
                     let lr_erro.msgerr = "ERRO ao realizar a baixa do servico: ",
                                       l_ligacao.atdsrvnum,"-",l_ligacao.atdsrvano
                     display "Erro na Baixa: ",lr_erro.msgerr clipped
                     let l_ctr = 1
                 else
                 
                    display "Chamei o provisionamento ctb00g03_incprvdsp: ",l_ligacao.atdsrvnum,"-",l_ligacao.atdsrvano
                    call ctb00g03_incprvdsp(l_ligacao.atdsrvnum,
                                            l_ligacao.atdsrvano)
                         returning l_errcod, lr_ctimsocprv.*
                         
                    if l_errcod <> 0 then
                       let lr_erro.msgerr = "ERRO ao realizar o provisionamento do servico: ",
                                         l_ligacao.atdsrvnum,"-",l_ligacao.atdsrvano
                       display "Erro na Provisao: ",lr_erro.msgerr clipped
                       let l_ctr = 1
                    else
                       let l_ctr = 0
                    end if     
                 end if
               end if  
                
               call bdbsa115_camada(l_ligacao.atdsrvnum,
                                    l_ligacao.atdsrvano)  
                    returning lr_erro.err,lr_erro.msgerr
                    
               if lr_erro.err <> 0 then
                 display "Erro na Provisao: ",lr_erro.msgerr clipped
                 let l_ctr = 1
               else
                  let l_ctr = 0
               end if 
            end if
         end if 
      end if 
      if l_ctr = 0 then
         commit work
         let m_upd = m_upd + 1
       else
        let m_desp = m_desp + 1
        rollback work
      end if

      let l_ctr = 1

      initialize l_aux.* to null

   end foreach

   if m_proc = 0 then
      let l_mens_erro = 'Nenhum servico encontrado desde ', m_atddat
      call errorlog(l_mens_erro)
   end if

   let l_mens_erro = "RESUMO: "
   call errorlog(l_mens_erro)
   let l_mens_erro = "----------------------------------------------------"
   call errorlog(l_mens_erro)
   let l_mens_erro = " Servicos processados...: ", m_proc using "&&&&&&"
   call errorlog(l_mens_erro)
   let l_mens_erro = "    Atualizados.........: ", m_upd  using "&&&&&&"
   call errorlog(l_mens_erro)
   let l_mens_erro = "    Desprezados.........: ", m_desp using "&&&&&&"
   call errorlog(l_mens_erro)
   let l_mens_erro = "    Apolice nao emitida.: ", m_emi  using "&&&&&&"
   call errorlog(l_mens_erro)
   let l_mens_erro = "----------------------------------------------------"
   call errorlog(l_mens_erro)

end function      



#-------------------------------------
function bdbsa115_camada(param) 
#-------------------------------------
# Funcao para realizar a interface com a camada do Porto Socorro

define param record
      atdsrvnum  like datmligacao.atdsrvnum ,
      atdsrvano  like datmligacao.atdsrvano  
   end record

define lr_ctb00g16 record    
      ctbpezcod    like dbsmatdpovhst.ctbpezcod   ,
      ctbevnpamcod like dbskctbevnpam.ctbevnpamcod, 
      srvpovevncod like dbskctbevnpam.srvpovevncod, 
      srvajsevncod like dbskctbevnpam.srvajsevncod, 
      srvbxaevncod like dbskctbevnpam.srvbxaevncod, 
      empcod       like dbskctbevnpam.empcod      , 
      pcpsgrramcod like dbskctbevnpam.pcpsgrramcod, 
      pcpsgrmdlcod like dbskctbevnpam.pcpsgrmdlcod, 
      ctbsgrramcod like dbskctbevnpam.ctbsgrramcod, 
      ctbsgrmdlcod like dbskctbevnpam.ctbsgrmdlcod, 
      pgoclsflg    like dbskctbevnpam.pgoclsflg   , 
      srvdcrcod    like dbskctbevnpam.srvdcrcod   , 
      itaasstipcod like dbskctbevnpam.itaasstipcod, 
      bemcod       like dbskctbevnpam.bemcod      , 
      srvatdctecod like dbskctbevnpam.srvatdctecod, 
      c24astagp    like dbskctbevnpam.c24astagp   , 
      atopamflg    like dbskctbevnpam.atopamflg   ,
      srvvlr       like dbsmatdpovhst.srvvlr      ,
      regiclhrrdat like dbsmatdpovhst.regiclhrrdat, 
      sel_srvvlr   like dbsmatdpovhst.srvvlr      ,
      atldat       like datrligapol.atldat        , 
      atoflg       like datkdcrorg.atoflg         , 
      c24astcod    like datkassunto.c24astcod     ,
      c24astdes    like datkassunto.c24astdes     ,
      carteira     smallint                       ,
      ctbramcod    like rsatdifctbramcvs.ctbramcod,     
      ctbmdlcod    like rsatdifctbramcvs.ctbmdlcod,     
      clscod       like rsatdifctbramcvs.clscod   ,    
      avialgmtv    like datmavisrent.avialgmtv    ,
      srvpgtevncod like dbskctbevnpam.srvpgtevncod
   end record
   
   # Inicio - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
   define lr_apolice record
         succod       like datrservapol.succod    , 
         ramcod       like datrservapol.ramcod    , 
         modalidade   like rsamseguro.rmemdlcod   , 
         aplnumdig    like datrservapol.aplnumdig , 
         itmnumdig    like datrservapol.itmnumdig ,
         edsnumref    like datrservapol.edsnumref ,            
         prporg       like datrligprp.prporg      ,  
         prpnumdig    like datrligprp.prpnumdig   ,
         corsus       like abamcor.corsus     
   end record
   # Fim - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
 
   define lr_erro record         
       err    smallint,          
       msgerr char(2000)          
   end record  


   initialize lr_apolice.* to null # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil

   let lr_ctb00g16.atldat = today
   
        ## // Verifica se ja foi provisionado //                                
     call ctb00g16_selsrvprv(param.atdsrvnum, param.atdsrvano)
                   returning lr_erro.err   ,                        
                             lr_erro.msgerr,                        
                             lr_ctb00g16.ctbpezcod,                     
                             lr_ctb00g16.regiclhrrdat,                  
                             lr_ctb00g16.sel_srvvlr     
      
      if lr_erro.err = 0 then
          
          
          call ctb00g16_bxaprvdsp(param.atdsrvnum, param.atdsrvano)
                   returning lr_erro.err,
                             lr_erro.msgerr,
                             lr_ctb00g16.ctbevnpamcod,
                             lr_ctb00g16.srvpovevncod,
                             lr_ctb00g16.srvajsevncod,
                             lr_ctb00g16.srvbxaevncod,
                             lr_ctb00g16.empcod      ,
                             lr_ctb00g16.pcpsgrramcod,
                             lr_ctb00g16.pcpsgrmdlcod,
                             lr_ctb00g16.ctbsgrramcod,
                             lr_ctb00g16.ctbsgrmdlcod,
                             lr_ctb00g16.pgoclsflg   ,
                             lr_ctb00g16.srvdcrcod   ,
                             lr_ctb00g16.itaasstipcod,
                             lr_ctb00g16.bemcod      ,
                             lr_ctb00g16.srvatdctecod,
                             lr_ctb00g16.c24astagp   ,		
                             lr_ctb00g16.atopamflg   ,
                             lr_ctb00g16.srvvlr  
          
          if lr_erro.err = 0 then 
              
              call cts00g09_apolice(param.atdsrvnum, 
                                    param.atdsrvano,
                                    4,                     # Tipo de Retorno
                                    lr_ctb00g16.empcod,
                                    0)                     # Tipo da OP (0 = N/A)
              returning lr_apolice.succod,    
                        lr_apolice.ramcod,    
                        lr_apolice.modalidade,
                        lr_apolice.aplnumdig, 
                        lr_apolice.itmnumdig, 
                        lr_apolice.edsnumref, 
                        lr_apolice.prporg,    
                        lr_apolice.prpnumdig,
                        lr_apolice.corsus
       
               call ctb00g16_envio_contabil(lr_ctb00g16.srvbxaevncod,
                                           lr_ctb00g16.empcod      ,   
                                           lr_apolice.succod       ,
                                           lr_ctb00g16.ctbsgrramcod,  
                                           lr_ctb00g16.ctbsgrmdlcod,  
                                           lr_apolice.aplnumdig    ,                                       
                                           lr_apolice.itmnumdig    , 
                                           lr_apolice.edsnumref    , 
                                           lr_apolice.prporg       , 
                                           lr_apolice.prpnumdig    , 
                                           lr_apolice.corsus       , 
                                           lr_ctb00g16.srvvlr      ,    
                                           param.atdsrvnum         , 
                                           param.atdsrvano         ,  
                                           0                       , 
                                           lr_ctb00g16.srvatdctecod, 
                                           lr_ctb00g16.atldat)  
              
              call ctb00g16_incprvdsp(param.atdsrvnum,param.atdsrvano, 1)
                         returning lr_ctb00g16.srvdcrcod   ,
                                   lr_ctb00g16.bemcod      ,
                                   lr_ctb00g16.atoflg      ,
                                   lr_ctb00g16.itaasstipcod,
                                   lr_ctb00g16.c24astagp   ,
                                   lr_ctb00g16.c24astcod   , 
                                   lr_ctb00g16.c24astdes   ,
                                   lr_ctb00g16.carteira    ,
                                   lr_ctb00g16.ctbramcod   ,
                                   lr_ctb00g16.ctbmdlcod   ,
                                   lr_ctb00g16.clscod      ,
                                   lr_ctb00g16.pgoclsflg   ,
                                   lr_ctb00g16.ctbevnpamcod,
                                   lr_ctb00g16.srvpovevncod,
                                   lr_ctb00g16.srvajsevncod,
                                   lr_ctb00g16.srvbxaevncod,
                                   lr_ctb00g16.srvpgtevncod,
                                   lr_apolice.succod       ,
                                   lr_apolice.ramcod       ,
                                   lr_apolice.modalidade   ,
                                   lr_apolice.aplnumdig    ,
                                   lr_apolice.itmnumdig    ,
                                   lr_apolice.edsnumref    ,
                                   lr_apolice.prporg       ,
                                   lr_apolice.prpnumdig    ,
                                   lr_erro.msgerr          ,
                                   lr_ctb00g16.srvvlr      ,
                                   lr_ctb00g16.avialgmtv   ,
                                   lr_apolice.corsus      
         
                     
              if lr_erro.msgerr is not null then
                 let lr_erro.err = 1 
              else  
                 
                  call ctb00g16_envio_contabil(lr_ctb00g16.srvpovevncod,  
                                               lr_ctb00g16.empcod      ,
                                               lr_apolice.succod       ,
                                               lr_ctb00g16.ctbramcod   ,   
                                               lr_ctb00g16.ctbmdlcod   ,   
                                               lr_apolice.aplnumdig    ,
                                               lr_apolice.itmnumdig    ,
                                               lr_apolice.edsnumref    ,
                                               lr_apolice.prporg       ,
                                               lr_apolice.prpnumdig    ,
                                               lr_apolice.corsus       ,
                                               lr_ctb00g16.srvvlr      ,
                                               param.atdsrvnum         ,
                                               param.atdsrvano         ,
                                               0                       ,
                                               lr_ctb00g16.srvatdctecod,
                                               lr_ctb00g16.atldat)
                                               
                 let lr_erro.err = 0
              end if                    
          end if 
      else
         let lr_erro.msgerr = "Nao foi encontrado provisionamento para o servico: ",param.atdsrvnum,"-",param.atdsrvano
      end if 
      
   return lr_erro.err,lr_erro.msgerr   
      
      
end function
