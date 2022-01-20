###############################################################################
# Nome do Modulo: CTB11M01                                         Marcelo    #
#                                                                  Gilberto   #
# Ordem de pagamento - Porto Socorro                               Dez/1996   #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------# 
# 13/07/1999  CI  01013-8  Gilberto     Alterar critica que impedia que des-  #
#                                       conto fosse menor que R$53,00.        #
#-----------------------------------------------------------------------------#
# 29/10/1999  Edu Oriente  Gilberto     Permitir cancelamento quando AD jah   #
#                                       foi cancelada pelo Financeiro.        #
#-----------------------------------------------------------------------------#
# 09/03/2000  PSI 10181-8  Wagner       Tratamento das cooperativas de TAXI   #
#-----------------------------------------------------------------------------#
# 21/03/2000  PSI 10027-7  Wagner       Acesso a funcao ctx07g00 para o       #
#                                       cancelamento da OP.                   #
#-----------------------------------------------------------------------------#
# 23/05/2000  CORREIO      Wagner       Limitar valor minimo para pagamento   #
#                                       a R$ 10,00.                           #
#-----------------------------------------------------------------------------#
# 10/11/2000  PSI 10631-3  Wagner       Pesquisar somente OP de P.Socorro.    #
#.............................................................................#
#                                                                             #
#                * * * * Alteracoes * * * *                                   #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- ------------------------------         #
# 06/10/2004  Mariana,Meta   PSI187801 Expandir dominio do campo              #
#                                      socpgtdsctip(5-Desconto,               #
#                                                   6-Adiantamentos,          #
#                                                   7-Comercial,              #
#                                                   8-Financiamentos,         #
#                                                   9-Outros)                 #
# 13/04/2005  Helio (Meta)  PSI 191167 Unificacao do acesso as tabelas de     #
#                                      centro de custos.                      #
#-----------------------------------------------------------------------------#
# 20/07/2006 Cristiane Silva PSI197858 Chamada de tela de Descontos via menu  #
#                                      e retirada do tipo e valor de des-     #
#                                      conto da tela.                         #
#-----------------------------------------------------------------------------#
# 07/12/2006 Priscila Staingel PSI205206 Exibir se a OP é da Azul ou Porto    #
#                                        sendo q todos os itens da OP devem   #
#                                        ser da mesma empresa                 #
#-----------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel    #
#-----------------------------------------------------------------------------#
# 27/05/2008  Chamado: 80511944         Implementado regra de bloqueio de     #
#                       Andre Oliveira		cancelamento apos data de Pagamento #
# 23/06/2008  PSI 198404 Ligia Mattge   Retirado o Centro de custo incluido   #
#                                       a sucursal                            #
# 09/02/2009  PSI 236292  Fabio Costa   Mostrar QRAs ligados a OP na pop-up   #
# 27/05/2009  PSI 198404  Fabio Costa   Impedir edicao de OP com status 10 e  #
#                                       11, digitar NF e gravar nos itens,    #
#                                       cancelamento de OP People, retirar    #
#                                       tributacao Informix                   #
# 29/07/2009  PSI 198404  Fabio Costa   Permitir digitacao de sucursal para   #
#                                       OP de reembolso                       #
# 08/02/2010  PSI198404  Fabio Costa  Validacoes do relatorio bdbsr116 na OP  #
#                                     Azul antes de status "Ok para emissao"  #
# 26/04/2010  PSI198404  Fabio Costa  Tratar reembolso segurado Azul, tipo    #
#                                     favorecido, NFS na OP, verific. NFS     #
# 28/05/2012  PSI-11-19199PR Jose Kurihara Incluir campo Optante Simples e    #
#                                          aliquota do ISS                    #
#                                          registrar mudanca ISS historico    #
# 22/01/2016  Solicitacao Eliane K. Fx Incluir matricula 12644 - Lincoln      #
#                                      para Atualizar Status 7                #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_dominio record
       erro      smallint  ,
       mensagem  char(100) ,
       cpodes    like iddkdominio.cpodes
end record

define m_opg record
       pstcoddig  like dbsmopg.pstcoddig ,
       soctip     like dbsmopg.soctip    ,
       pestip     like dbsmopg.pestip
end record


define mr_retSAP record                                       
        stt    integer                                     
       ,msg    char(100)                                   
end record 

#------------------------------------------------------------
function ctb11m01()
#------------------------------------------------------------

 define ctb11m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),      #PSI 205206
    favtip           smallint,
    favtipcab        char (14),
    favtipcod        char (08),
    favtipnom        char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    cctcod           like dbsmopg.cctcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
#PSI197858 - inicio
#    socpgtdsctip     like dbsmopg.socpgtdsctip,
#    socpgtdscdes     char (15),
    socopgdscvlr     like dbsmopg.socopgdscvlr,
#PSI197858 - fim
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    pstcoddig        like dbsmopg.pstcoddig,
    soctip           like dbsmopg.soctip,
    segnumdig        like dbsmopg.segnumdig,
    ciaempcod        like datmservico.ciaempcod,
    corsus           like dbsmopg.corsus,
    infissalqvlr     like dbsmopg.infissalqvlr,    # PSI-11-19199PR
    simoptpstflg     like dpaksocor.simoptpstflg   # PSI-11-19199PR
 end record

 define k_ctb11m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

 define l_pstcoddig like dbsmopg.pstcoddig
 define l_qldgracod like dpaksocor.qldgracod
 define l_flag      char(1)
 

 let l_pstcoddig = null
 let l_qldgracod = null
 let l_flag = 'S'

 if not get_niv_mod(g_issk.prgsgl, "ctb11m01") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 let int_flag = false

 initialize ctb11m01.*   to  null
 initialize k_ctb11m01.* to  null
 initialize m_opg.* to null
 
 open window ctb11m01 at 04,02 with form "ctb11m01"

 menu "O.P."

    before menu
       hide option all
       if g_issk.acsnivcod >= g_issk.acsnivcns  then          # NIVEL 1
          show option "Seleciona", "Proximo", "Anterior", "Fases", "enVia OP"
       end if
       if g_issk.acsnivcod  =  3   then                       # NIVEL 3
          show option "Seleciona", "Proximo", "Anterior",
                      "Itens", "Fases" , "enVia OP"
       end if
       if g_issk.acsnivcod >=  5   then                       # NIVEL 5
          show option "Seleciona", "Proximo", "Anterior", "Modifica",
                      "Itens", "Descontos", "Fases", "Obs", "Totais", "coNtribuinte",
                      "contaBil" , "enVia OP"
       end if
       if g_issk.acsnivcod  =  8   then                       # NIVEL 8
          show option "Cancela"
          
          ### TEMPORARIO PARA REDUZIR A UTILIZACAO DE SHELL EVENTUAL ATE A CORRECAO NO SAP
          show option "AguardandoSAP"
          
          if g_issk.funmat = 6299 then
             show option "AtualizaStt7"
             
             show option "CancelaOP"
          end if
  
       end if

       if g_issk.funmat = 12644 then
		    show option "AtualizaStt7"
       end if

#      if g_issk.acsnivcod  =  8   then                       # NIVEL 8
#         show option "Remove"
#      end if
       show option "Encerra"

   command key ("S") "Seleciona"
                     "Pesquisa ordem de pagamento conforme criterios"
       call seleciona_ctb11m01() returning k_ctb11m01.*, ctb11m01.*
       if k_ctb11m01.socopgnum is not null  then
          message ""
          next option "Proximo"
       else
          error " Nenhuma ordem de pagamento selecionada!"
          message ""
          next option "Seleciona"
       end if

   command key ("P") "Proximo"
                     "Mostra proxima ordem de pagamento"
       message ""
       if k_ctb11m01.socopgnum is not null then
          call proximo_ctb11m01(k_ctb11m01.*)
               returning k_ctb11m01.*, ctb11m01.*
       else
          error " Nenhuma ordem de pagamento nesta direcao!"
          next option "Seleciona"
       end if

   command key ("A") "Anterior"
                     "Mostra ordem de pagamento anterior"
       message ""
       if k_ctb11m01.socopgnum is not null then
          call anterior_ctb11m01(k_ctb11m01.*)
               returning k_ctb11m01.*, ctb11m01.*
       else
          error " Nenhuma ordem de pagamento nesta direcao!"
          next option "Seleciona"
       end if

   command key ("M") "Modifica"
                     "Modifica ordem de pagamento selecionada"
       message ""
       if k_ctb11m01.socopgnum is not null
          then
          case ctb11m01.socopgsitcod
             when 7
                error " Ordem de pagamento emitida nao deve ser alterada!" 
             when 8
                error " Ordem de pagamento cancelada nao deve ser alterada!"
             when 10
                error " Ordem de pagamento nao deve ser alterada, aguardando emissão PEOPLE!"
             when 11
                error " Ordem de pagamento nao deve ser alterada, aguardando cancelamento PEOPLE! "
             otherwise
                call modifica_ctb11m01(k_ctb11m01.*, ctb11m01.*)
                     returning k_ctb11m01.*
                initialize ctb11m01.*     to null
                initialize k_ctb11m01.*   to null
                clear form
                next option "Seleciona"
          end case
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("I") "Itens"
                     "Itens da ordem de pagamento selecionada"
       message ""
       if k_ctb11m01.socopgnum is not null then
          if ctb11m01.socopgsitcod  >  1 then
             if ctb11m01.socopgsitcod  <>  7  and
                ctb11m01.socopgsitcod  <>  8  and
                ctb11m01.socopgsitcod  <>  10
                then
                if dias_uteis(ctb11m01.socfatpgtdat, 0, "", "S", "S") = ctb11m01.socfatpgtdat
                   then
                else
                   if ctb11m01.socfatpgtdat  <>  "18/10/1999"  
                      then
                      error " Pagamento nao deve ser programado para FERIADO!"
                      initialize ctb11m01.*     to null
                      initialize k_ctb11m01.*   to null
                      next option "Seleciona"
                   end if
                end if

                if dias_entre_datas (today, ctb11m01.socfatpgtdat, "", "S", "S") <= 4 
                   then
                   error " Pagamento deve ser programado c/ 4 DIAS DE ANTECEDENCIA!"
                   initialize ctb11m01.*     to null
                   initialize k_ctb11m01.*   to null
                   next option "Seleciona"
                else
                   clear form
                   call ctb11m06(k_ctb11m01.*)        #-> Manutencao itens
                   initialize ctb11m01.*     to null
                   initialize k_ctb11m01.*   to null
                   next option "Seleciona"
                end if
             else
                call ctb11m10(k_ctb11m01.*,"")         #-> Consulta itens
             end if
          else
             error " Ordem de pagamento nao analisada!"
          end if
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if
       
   #PSI197858 - inicio
   command key ("D") "Descontos" "Descontos da ordem de pagamento selecionada"
       message ""
       if k_ctb11m01.socopgnum is not null then
          call ctc81m00(k_ctb11m01.*)
          next option "Seleciona"
       else
          error "Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if
   #PSI197858 - fim
   
   command key ("O") "Obs"
                     "Observacoes da ordem de pagamento selecionada"
       message ""
       if k_ctb11m01.socopgnum is not null then
          call ctb11m03(k_ctb11m01.*)
          next option "Seleciona"
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("F") "Fases"
                     "Fases da ordem de pagamento selecionada"
       message ""
       if k_ctb11m01.socopgnum is not null then
          call ctb11m02(k_ctb11m01.*)
          next option "Seleciona"
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("T") "Totais"
                     "Totaliza itens da ordem de pagamento selecionada por tipo de servico"
       message ""

       if k_ctb11m01.socopgnum is not null then
          if ctb11m01.socopgsitcod  =  7  or
             ctb11m01.socopgsitcod  =  8  then
             #Remover critica que bloqueia a consulta de OP com data de pagamento inferior a 60 dias:

             #if ctb11m01.socfatpgtdat  <  today - 60 units day   and
             #   g_issk.funmat <> 7574 then
             #   error " Consulta nao disponivel para O.P. emitida a mais de 60 dias"
             #   next option "Seleciona"
             #else
                call ctb11m11(k_ctb11m01.*)
                next option "Seleciona"
             #end if
          else
             call ctb11m11(k_ctb11m01.*)
             next option "Seleciona"
          end if
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("B") "contaBil"
                     "Contabilizacao da ordem de pagamento selecionada"
       message ""
       if k_ctb11m01.socopgnum is not null then
          if ctb11m01.socfatpgtdat  >  "04/01/1998"   then
             if ctb11m01.socopgsitcod  =  7   then
                call ctb11m14(k_ctb11m01.*)
                next option "Seleciona"
             else
                error " Ordem de pagamento nao emitida!"
                next option "Seleciona"
             end if
          else
             error " Ordem de pagamento contabilizada pelo micro!"
             next option "Seleciona"
          end if
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("N") "coNtribuinte"
                     "Consulta contribuinte da ordem de pagamento selecionada"
       message ""
       error " Consulta desabilitada após a implantação PeopleSoft "
       
       # PSI 198404 People, dados nao estao mais no tributos
       # if k_ctb11m01.socopgnum is not null then
       #    call ctb11m12("C",
       #                  ctb11m01.opgcgccpfnum,
       #                  ctb11m01.opgcgcord,
       #                  ctb11m01.trbempcod,
       #                  ctb11m01.trbsuccod,
       #                  ctb11m01.trbprstip)
       #        returning ctb11m01.opgcgccpfnum,
       #                  ctb11m01.opgcgcord,
       #                  ctb11m01.trbempcod,
       #                  ctb11m01.trbsuccod,
       #                  ctb11m01.trbprstip
       #    next option "Seleciona"
       # else
       #    error " Nenhuma ordem de pagamento selecionada!"
       #    next option "Seleciona"
       # end if
       
   command key ("C") "Cancela"
                     "Cancela ordem de pagamento selecionada"
       message ""
       if k_ctb11m01.socopgnum is not null then
          if ctb11m01.socopgsitcod  <>  8  then
             call cancela_ctb11m01(k_ctb11m01.*)
                  returning k_ctb11m01.*
             next option "Seleciona"
          else
             error " Ordem de pagamento ja' cancelada!"
          end if
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   #  command key ("R") "Remove"
   #                    "Remove ordem de pagamento selecionada"
   #      message ""
   #      if k_ctb11m01.socopgnum is not null then
   #         if ctb11m01.socopgsitcod  <>  7  then
   #            call remove_ctb11m01(k_ctb11m01.*)
   #                 returning k_ctb11m01.*
   #            next option "Seleciona"
   #         else
   #            error " Ordem de pagamento ja' emitida nao deve ser removida!"
   #         end if
   #      else
   #         error " Nenhuma ordem de pagamento selecionada!"
   #         next option "Seleciona"
   #      end if

  command key ("V") "enVia OP" "Envia OP para Prestador"
      message ""
      if k_ctb11m01.socopgnum is not null then
        
         whenever error continue
           
            select pstcoddig into l_pstcoddig
            from dbsmopg
            where socopgnum = k_ctb11m01.socopgnum
   
            select qldgracod into l_qldgracod
            from dpaksocor      
            where pstcoddig = l_pstcoddig	    
            
         whenever error stop
         
         if l_qldgracod <> 1 then
            call ctb11m17(k_ctb11m01.socopgnum,l_pstcoddig,'E','O')
         else
            error " Nao e possivel enviar a OP!"
            next option "Seleciona"
         end if
      else
         error " Nenhuma ordem de pagamento selecionada!"
         next option "Seleciona"
      end if

  ### TEMPORARIO PARA REDUZIR A UTILIZACAO DE SHELL EVENTUAL ATE A CORRECAO NO SAP
  command key ("g") "AguardandoSAP"
                    "Reverte ordens de pagamento aguardando retorno SAP"
                    
      message "Aguarde atualizado a situacao das OPs aguardando o SAP..."
      sleep 1
      # Atualiza a situacao das OPs
      update dbsmopg                        
         set socopgsitcod = 6,              
             trbpgtordpcmflg = 'N',         
             trbnaopgtordpcmflg = 'N'       
       where socopgsitcod = 11
                         
      message "OPs atualizadas com sucesso!"
      sleep 2
      message ""
      
  command key ("j") "AtualizaStt7"
                    "Atualiza status das OPs para 7"
         
       if k_ctb11m01.socopgnum is not null then  
                    
          select 1
           from dbsmopg
          where socopgnum = k_ctb11m01.socopgnum
            and socopgsitcod in (6,11)
            and empcod in (1,43,50)
            and finsispgtordnum is not null and finsispgtordnum > 0
            and (( dscpgtordnum = 0 and dscfinsispgtordnum is null )
                  or ( dscpgtordnum is not null and dscfinsispgtordnum is not null ))
                  
          if sqlca.sqlcode = 0 then
             update dbsmopg                 
                set socopgsitcod = 7,         
                    trbpgtordpcmflg = 'S',      
                    trbnaopgtordpcmflg = 'S'       
              where socopgnum = k_ctb11m01.socopgnum  
               
              if sqlca.sqlcode = 0 then
                 error "OP Atualizada"
              else
                error "Erro ao Atualizar status. Erro: ", sqlca.sqlcode
              end if
          else
              let l_flag = cts08g01("A","S","O NUMERO DA OP ESTA CORRETO?",
                                    '',"APOS A CONFIRMACAO NAO SERA POSSIVEL REVERTER",'')
              if l_flag = 'S' then
                 update dbsmopg                 
                    set socopgsitcod = 7,         
                        trbpgtordpcmflg = 'S',      
                        trbnaopgtordpcmflg = 'S'       
                  where socopgnum = k_ctb11m01.socopgnum
                  
                  if sqlca.sqlcode = 0 then
                     error "OP Atualizada"
                  else
                    error "Erro ao Atualizar status. Erro: ", sqlca.sqlcode
                  end if
              else 
                 error "Favor confirmar dados da OP e repetir operacao"
              end if
          end if 
       else
          error " Nenhuma ordem de pagamento selecionada!"
          message ""
          next option "Seleciona"
       end if 
       
   command key ("L") "CancelaOP"
   
      if k_ctb11m01.socopgnum is not null then
         
         let l_flag = null
         let l_flag = cts08g01("A","S","O NUMERO DA OP ESTA CORRETO?",
                                    '',"APOS A CONFIRMACAO NAO SERA POSSIVEL REVERTER",'')
         if l_flag = 'S' then  
                       
             update dbsmopg                        
                set socopgsitcod = 8              
                   ,trbpgtordpcmflg = 'N'         
                   ,trbnaopgtordpcmflg = 'N'       
              where socopgnum = k_ctb11m01.socopgnum 
              
              if sqlca.sqlcode = 0 then
                 error "OP Cancelada"                   
              
                 update datmservico 
                    set pgtdat = null, 
                        atdcstvlr = null
                  where atdsrvnum in (
                        (select atdsrvnum from dbsmopgitm where socopgnum = k_ctb11m01.socopgnum))
                    and atdsrvano in (
                        (select atdsrvano from dbsmopgitm where socopgnum = k_ctb11m01.socopgnum))
                  
                  if sqlca.sqlcode = 0 then
                     error "Servicos Atualizados"
                  else
                    error "Erro ao Atualizar Servicos. Erro: ", sqlca.sqlcode
                  end if
                 
              else
                error "Erro ao Cancelar OP. Erro: ", sqlca.sqlcode
              end if

         end if  
      else
         error " Nenhuma ordem de pagamento selecionada!"
         message ""
         next option "Seleciona"
      end if 

  command key (interrupt,"E") "Encerra" "Retorna ao menu anterior"
      exit menu
      
 end menu

 close window ctb11m01

end function  ###  ctb11m01

#------------------------------------------------------------
function seleciona_ctb11m01()
#------------------------------------------------------------

 define ctb11m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),      #PSI 205206
    favtip           smallint,
    favtipcab        char (14),
    favtipcod        char (08),
    favtipnom        char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    cctcod           like dbsmopg.cctcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
    socopgdscvlr     like dbsmopg.socopgdscvlr,
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    pstcoddig        like dbsmopg.pstcoddig,
    soctip           like dbsmopg.soctip,
    segnumdig        like dbsmopg.segnumdig,
    ciaempcod        like datmservico.ciaempcod,   
    corsus           like dbsmopg.corsus,
    infissalqvlr     like dbsmopg.infissalqvlr,    # PSI-11-19199PR
    simoptpstflg     like dpaksocor.simoptpstflg   # PSI-11-19199PR
 end record

 define k_ctb11m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

   clear form
   let int_flag = false
   initialize  ctb11m01.*  to null

   input by name k_ctb11m01.socopgnum

      before field socopgnum
          display by name k_ctb11m01.socopgnum attribute (reverse)

          if k_ctb11m01.socopgnum is null then
             let k_ctb11m01.socopgnum = 0
          end if

      after  field socopgnum
          display by name k_ctb11m01.socopgnum

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctb11m01.*   to null
      initialize k_ctb11m01.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctb11m01.*, ctb11m01.*
   end if

   if k_ctb11m01.socopgnum  =  0   then
      select min (socopgnum)
        into k_ctb11m01.socopgnum
        from dbsmopg
       where socopgnum > k_ctb11m01.socopgnum
         and soctip    = 1

      display by name k_ctb11m01.socopgnum
   end if

   call ler_ctb11m01(k_ctb11m01.*)  returning  ctb11m01.*

   if ctb11m01.socopgnum  is not null    then
      display by name ctb11m01.socopgnum,
                      ctb11m01.socopgsitcod,
                      ctb11m01.socopgsitdes,
                      ctb11m01.empresa     ,
                      ctb11m01.favtipcab   ,
                      ctb11m01.favtipcod   ,
                      ctb11m01.favtipnom   ,
                      ctb11m01.socfatentdat,
                      ctb11m01.socfatpgtdat,
                      ctb11m01.socfatrelqtd,
                      ctb11m01.socfatitmqtd,
                      ctb11m01.socfattotvlr,
                      ctb11m01.soctrfcod   ,
                      ctb11m01.socpgtdoctip,
                      ctb11m01.socpgtdocdes,
                      ctb11m01.succod      ,
                      ctb11m01.sucnom      ,
                      ctb11m01.socemsnfsdat,
                      ctb11m01.socpgtopccod,
                      ctb11m01.socpgtopcdes,
                      ctb11m01.pgtdstcod   ,
                      ctb11m01.pgtdstdes   ,
                      ctb11m01.socopgfavnom,
                      ctb11m01.pestip      ,
                      ctb11m01.cgccpfnum   ,
                      ctb11m01.cgcord      ,
                      ctb11m01.cgccpfdig   ,
                      ctb11m01.bcoctatip   ,
                      ctb11m01.bcoctatipdes,
                      ctb11m01.bcocod      ,
                      ctb11m01.bcosgl      ,
                      ctb11m01.bcoagnnum   ,
                      ctb11m01.bcoagndig   ,
                      ctb11m01.bcoagnnom   ,
                      ctb11m01.bcoctanum   ,
                      ctb11m01.bcoctadig   ,
                      ctb11m01.socopgdscvlr,
                      ctb11m01.nfsnum      ,
                      ctb11m01.fisnotsrenum    ,  #Fornax - Quantum
                      ctb11m01.infissalqvlr,         # PSI-11-19199PR
                      ctb11m01.simoptpstflg
                      
      display by name ctb11m01.empresa attribute (reverse)
   else
      error " Ordem de pagamento nao cadastrada!"
      initialize ctb11m01.*    to null
      initialize k_ctb11m01.*  to null
   end if

   return k_ctb11m01.*, ctb11m01.*

end function  ###  seleciona_ctb11m01

#------------------------------------------------------------
function proximo_ctb11m01(k_ctb11m01)
#------------------------------------------------------------

 define ctb11m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),    #PSI 205206
    favtip           smallint,
    favtipcab        char (14),
    favtipcod        char (08),
    favtipnom        char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    cctcod           like dbsmopg.cctcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
    socopgdscvlr     like dbsmopg.socopgdscvlr,
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    pstcoddig        like dbsmopg.pstcoddig,
    soctip           like dbsmopg.soctip,
    segnumdig        like dbsmopg.segnumdig,
    ciaempcod        like datmservico.ciaempcod,  
    corsus           like dbsmopg.corsus,
    infissalqvlr     like dbsmopg.infissalqvlr,    # PSI-11-19199PR
    simoptpstflg     like dpaksocor.simoptpstflg   # PSI-11-19199PR
 end record

 define k_ctb11m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

   initialize ctb11m01.*   to null

   select min (socopgnum)
     into ctb11m01.socopgnum
     from dbsmopg
    where socopgnum > k_ctb11m01.socopgnum
      and soctip    = 1

   if ctb11m01.socopgnum  is not null   then
      let k_ctb11m01.socopgnum = ctb11m01.socopgnum
      call ler_ctb11m01(k_ctb11m01.*)  returning  ctb11m01.*
      if ctb11m01.socopgnum  is not null    then
         display by name ctb11m01.socopgnum,
                      ctb11m01.socopgsitcod,
                      ctb11m01.socopgsitdes,
                      ctb11m01.empresa     ,
                      ctb11m01.favtipcab   ,
                      ctb11m01.favtipcod   ,
                      ctb11m01.favtipnom   ,
                      ctb11m01.socfatentdat,
                      ctb11m01.socfatpgtdat,
                      ctb11m01.socfatrelqtd,
                      ctb11m01.socfatitmqtd,
                      ctb11m01.socfattotvlr,
                      ctb11m01.soctrfcod   ,
                      ctb11m01.socpgtdoctip,
                      ctb11m01.socpgtdocdes,
                      ctb11m01.succod      ,
                      ctb11m01.sucnom      ,
                      ctb11m01.socemsnfsdat,
                      ctb11m01.socpgtopccod,
                      ctb11m01.socpgtopcdes,
                      ctb11m01.pgtdstcod   ,
                      ctb11m01.pgtdstdes   ,
                      ctb11m01.socopgfavnom,
                      ctb11m01.pestip      ,
                      ctb11m01.cgccpfnum   ,
                      ctb11m01.cgcord      ,
                      ctb11m01.cgccpfdig   ,
                      ctb11m01.bcoctatip   ,
                      ctb11m01.bcoctatipdes,
                      ctb11m01.bcocod      ,
                      ctb11m01.bcosgl      ,
                      ctb11m01.bcoagnnum   ,
                      ctb11m01.bcoagndig   ,
                      ctb11m01.bcoagnnom   ,
                      ctb11m01.bcoctanum   ,
                      ctb11m01.bcoctadig   ,
                      ctb11m01.socopgdscvlr,
                      ctb11m01.nfsnum      ,
                      ctb11m01.fisnotsrenum,  #Fornax - Quantum
                      ctb11m01.infissalqvlr,          # PSI-11-19199PR
                      ctb11m01.simoptpstflg
                      
         display by name ctb11m01.empresa attribute (reverse)      #PSI 205206
      else
         error " Nao ha' ordem de pagamento nesta direcao!"
         initialize ctb11m01.*    to null
         initialize k_ctb11m01.*  to null
      end if
   else
      error " Nao ha' ordem de pagamento nesta direcao!"
      initialize ctb11m01.*    to null
      initialize k_ctb11m01.*  to null
   end if
   return k_ctb11m01.*, ctb11m01.*

end function  ###  proximo_ctb11m01

#------------------------------------------------------------
function anterior_ctb11m01(k_ctb11m01)
#------------------------------------------------------------

 define ctb11m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),    #PSI 205206
    favtip           smallint,
    favtipcab        char (14),
    favtipcod        char (08),
    favtipnom        char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    cctcod           like dbsmopg.cctcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
#PSI197858 - inicio
#    socpgtdsctip     like dbsmopg.socpgtdsctip,
#    socpgtdscdes     char (15),
    socopgdscvlr     like dbsmopg.socopgdscvlr,
#PSI197858 - fim
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    pstcoddig        like dbsmopg.pstcoddig,
    soctip           like dbsmopg.soctip,
    segnumdig        like dbsmopg.segnumdig,
    ciaempcod        like datmservico.ciaempcod,   
    corsus           like dbsmopg.corsus,
    infissalqvlr     like dbsmopg.infissalqvlr,    # PSI-11-19199PR
    simoptpstflg     like dpaksocor.simoptpstflg   # PSI-11-19199PR
 end record

 define k_ctb11m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

   let int_flag = false
   initialize ctb11m01.*  to null

   select max (socopgnum)
     into ctb11m01.socopgnum
     from dbsmopg
    where socopgnum < k_ctb11m01.socopgnum
      and soctip    = 1

   if ctb11m01.socopgnum  is  not  null  then
      let k_ctb11m01.socopgnum = ctb11m01.socopgnum
      call ler_ctb11m01(k_ctb11m01.*)  returning  ctb11m01.*
      if ctb11m01.socopgnum  is not null    then
         display by name ctb11m01.socopgnum,
                      ctb11m01.socopgsitcod,
                      ctb11m01.socopgsitdes,
                      ctb11m01.empresa     ,
                      ctb11m01.favtipcab   ,
                      ctb11m01.favtipcod   ,
                      ctb11m01.favtipnom   ,
                      ctb11m01.socfatentdat,
                      ctb11m01.socfatpgtdat,
                      ctb11m01.socfatrelqtd,
                      ctb11m01.socfatitmqtd,
                      ctb11m01.socfattotvlr,
                      ctb11m01.soctrfcod   ,
                      ctb11m01.socpgtdoctip,
                      ctb11m01.socpgtdocdes,
                      ctb11m01.succod      ,
                      ctb11m01.sucnom      ,
                      ctb11m01.socemsnfsdat,
                      ctb11m01.socpgtopccod,
                      ctb11m01.socpgtopcdes,
                      ctb11m01.pgtdstcod   ,
                      ctb11m01.pgtdstdes   ,
                      ctb11m01.socopgfavnom,
                      ctb11m01.pestip      ,
                      ctb11m01.cgccpfnum   ,
                      ctb11m01.cgcord      ,
                      ctb11m01.cgccpfdig   ,
                      ctb11m01.bcoctatip   ,
                      ctb11m01.bcoctatipdes,
                      ctb11m01.bcocod      ,
                      ctb11m01.bcosgl      ,
                      ctb11m01.bcoagnnum   ,
                      ctb11m01.bcoagndig   ,
                      ctb11m01.bcoagnnom   ,
                      ctb11m01.bcoctanum   ,
                      ctb11m01.bcoctadig   ,
                      ctb11m01.socopgdscvlr,
                      ctb11m01.nfsnum      ,
                      ctb11m01.fisnotsrenum, #Fornax - Quantum
                      ctb11m01.infissalqvlr,         # PSI-11-19199PR
                      ctb11m01.simoptpstflg
                      
         display by name ctb11m01.empresa attribute (reverse)      #PSI 205206
      else
         error " Nao ha' ordem de pagamento nesta direcao!"
         initialize ctb11m01.*    to null
         initialize k_ctb11m01.*  to null
      end if
   else
      error " Nao ha' ordem de pagamento nesta direcao!"
      initialize ctb11m01.*    to null
      initialize k_ctb11m01.*  to null
   end if
   return k_ctb11m01.*, ctb11m01.*

end function  ###  anterior_ctb11m01

#------------------------------------------------------------
function modifica_ctb11m01(k_ctb11m01, ctb11m01)
#------------------------------------------------------------

 define ctb11m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),       #PSI 205206
    favtip           smallint,
    favtipcab        char (14),
    favtipcod        char (08),
    favtipnom        char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    cctcod           like dbsmopg.cctcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
#PSI197858 - inicio
#    socpgtdsctip     like dbsmopg.socpgtdsctip,
#    socpgtdscdes     char (15),
    socopgdscvlr     like dbsmopg.socopgdscvlr,
#PSI197858 - fim
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    pstcoddig        like dbsmopg.pstcoddig,
    soctip           like dbsmopg.soctip,
    segnumdig        like dbsmopg.segnumdig,
    ciaempcod        like datmservico.ciaempcod,    
    corsus           like dbsmopg.corsus,
    infissalqvlr     like dbsmopg.infissalqvlr,    # PSI-11-19199PR
    simoptpstflg     like dpaksocor.simoptpstflg   # PSI-11-19199PR
 end record

 define k_ctb11m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

 define ws           record
    achfavflg        char (01),
    achtrbflg        char (01),
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
 end record

 define lr_retorno record
     retorno   smallint,
     mensagem  char(60)
 end record

 define l_sqlca   integer , 
        l_sqlerr  integer ,
        l_historico char(300),
        l_codaux    smallint
        
   let l_historico     = null
   let l_codaux        = null
   let ws.infissalqvlr = ctb11m01.infissalqvlr          # PSI-11-19199PR

   call input_ctb11m01("a", k_ctb11m01.* , ctb11m01.*) returning ctb11m01.*

   if int_flag  then
      let int_flag = false
      initialize k_ctb11m01.*  to null
      initialize ctb11m01.*    to null
      error " Operacao cancelada!"
      clear form
      return k_ctb11m01.*
   end if

   let ws.achfavflg = "N"
   let ws.achtrbflg = "N"

   select socopgnum from dbsmopgfav
    where socopgnum = k_ctb11m01.socopgnum

   if sqlca.sqlcode = 0  then
      let ws.achfavflg = "S"
   end if

   select socopgnum from dbsmopgtrb
    where socopgnum = k_ctb11m01.socopgnum

   if sqlca.sqlcode = 0  then
      let ws.achtrbflg = "S"
   end if

   if ws.achfavflg = "N"  then
      let ctb11m01.socopgsitcod = 2
   end if

   whenever error continue
   
   begin work
   
      # empcod retirado do update, empresa da OP deve ser definida no protocolo
      # ou na geracao automatica
      update dbsmopg  set (empcod,
                           succod,
                           cctcod,
                           socemsnfsdat,
                           socfatpgtdat,
                           socpgtdoctip,
                           pgtdstcod,
                           socopgsitcod,
                           atldat,
                           funmat,
                           nfsnum,
                           fisnotsrenum, #Fornax - Quantum
                           favtip,
                           infissalqvlr )
                       =  (ctb11m01.empcod,
                           ctb11m01.succod,     
                           12243,              # ctb11m01.cctcod,
                           ctb11m01.socemsnfsdat,
                           ctb11m01.socfatpgtdat,
                           ctb11m01.socpgtdoctip,
                           ctb11m01.pgtdstcod,
                           ctb11m01.socopgsitcod,
                           today,
                           g_issk.funmat,
                           ctb11m01.nfsnum,
                           ctb11m01.fisnotsrenum,  #Fornax - Quantum
                           ctb11m01.favtip,
                           ctb11m01.infissalqvlr )       # PSI-11-19199PR
      where dbsmopg.socopgnum  =  k_ctb11m01.socopgnum

      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteracao da ordem de pagamento!"
         rollback work
         initialize ctb11m01.*   to null
         initialize k_ctb11m01.* to null
         return k_ctb11m01.*
      end if

      if ws.achfavflg = "S"  then
         update dbsmopgfav  set (socopgfavnom,
                                 socpgtopccod,
                                 pestip,
                                 cgccpfnum,
                                 cgcord,
                                 cgccpfdig,
                                 bcoctatip,
                                 bcocod,
                                 bcoagnnum,
                                 bcoagndig,
                                 bcoctanum,
                                 bcoctadig)
                             =  (ctb11m01.socopgfavnom,
                                 ctb11m01.socpgtopccod,
                                 ctb11m01.pestip,
                                 ctb11m01.cgccpfnum,
                                 ctb11m01.cgcord,
                                 ctb11m01.cgccpfdig,
                                 ctb11m01.bcoctatip,
                                 ctb11m01.bcocod,
                                 ctb11m01.bcoagnnum,
                                 ctb11m01.bcoagndig,
                                 ctb11m01.bcoctanum,
                                 ctb11m01.bcoctadig)
            where dbsmopgfav.socopgnum  =  k_ctb11m01.socopgnum

         if sqlca.sqlcode <>  0  then
            error " Erro (",sqlca.sqlcode,") na alteracao do favorecido!"
            rollback work
            initialize ctb11m01.*   to null
            initialize k_ctb11m01.* to null
            return k_ctb11m01.*
         end if
      else
         insert into dbsmopgfav (socopgnum,
                                 socopgfavnom,
                                 socpgtopccod,
                                 pestip,
                                 cgccpfnum,
                                 cgcord,
                                 cgccpfdig,
                                 bcoctatip,
                                 bcocod,
                                 bcoagnnum,
                                 bcoagndig,
                                 bcoctanum,
                                 bcoctadig)
                        values  (ctb11m01.socopgnum,
                                 ctb11m01.socopgfavnom,
                                 ctb11m01.socpgtopccod,
                                 ctb11m01.pestip,
                                 ctb11m01.cgccpfnum,
                                 ctb11m01.cgcord,
                                 ctb11m01.cgccpfdig,
                                 ctb11m01.bcoctatip,
                                 ctb11m01.bcocod,
                                 ctb11m01.bcoagnnum,
                                 ctb11m01.bcoagndig,
                                 ctb11m01.bcoctanum,
                                 ctb11m01.bcoctadig)

         if sqlca.sqlcode <>  0  then
            error " Erro (",sqlca.sqlcode,") na inclusao do favorecido!"
            rollback work
            initialize ctb11m01.*   to null
            initialize k_ctb11m01.* to null
            return k_ctb11m01.*
         end if

         # PSI 221074 - BURINI
         call cts50g00_insere_etapa(ctb11m01.socopgnum, 2, g_issk.funmat)
              returning lr_retorno.retorno, lr_retorno.mensagem

         if sqlca.sqlcode <>  0   then
            error " Erro (",sqlca.sqlcode,") na inclusao da fase!"
            rollback work
            initialize ctb11m01.*   to null
            initialize k_ctb11m01.* to null
            return k_ctb11m01.*
         end if
      end if

      if ws.achtrbflg = "S"  then
         if ctb11m01.opgcgccpfnum is null  or
            ctb11m01.trbempcod    is null  or
            ctb11m01.trbsuccod    is null  or
            ctb11m01.trbprstip    is null  then
            # delete from dbsmopgtrb
            # where socopgnum = k_ctb11m01.socopgnum
         else
            update dbsmopgtrb set (empcod,
                                   succod,
                                   prstip)
                                = (ctb11m01.trbempcod,
                                   ctb11m01.trbsuccod,
                                   ctb11m01.trbprstip)
             where dbsmopgtrb.socopgnum = k_ctb11m01.socopgnum
         end if

         if sqlca.sqlcode <>  0   then
            error " Erro (",sqlca.sqlcode,") na alteracao do contribuinte!"
            rollback work
            initialize ctb11m01.*   to null
            initialize k_ctb11m01.* to null
            return k_ctb11m01.*
         end if
      else
         if ctb11m01.opgcgccpfnum is not null  and
            ctb11m01.trbempcod    is not null  and
            ctb11m01.trbsuccod    is not null  and
            ctb11m01.trbprstip    is not null  then
            insert into dbsmopgtrb (socopgnum,
                                    empcod,
                                    succod,
                                    prstip)
                           values  (ctb11m01.socopgnum,
                                    ctb11m01.trbempcod,
                                    ctb11m01.trbsuccod,
                                    ctb11m01.trbprstip)

            if sqlca.sqlcode <>  0   then
               error " Erro (",sqlca.sqlcode,") na inclusao do contribuinte!"
               rollback work
               initialize ctb11m01.*   to null
               initialize k_ctb11m01.* to null
               return k_ctb11m01.*
            end if
         end if
      end if
      
      # update NFSNUM nos itens das OP
      if ctb11m01.nfsnum is not null and
         ctb11m01.nfsnum > 0
         then
         
         call ctd20g01_upd_nfs_opgitm(k_ctb11m01.socopgnum, 
                                      ctb11m01.socopgsitcod,
                                      ctb11m01.nfsnum)
              returning l_sqlca, l_sqlerr
              
         if l_sqlca != 0
            then
            if l_sqlca != 100
               then
               if l_sqlca = 99
                  then
                  error " Não permitido alterar Documento Fiscal nesta OP "
                  sleep 2
               else
                  error " Erro na atualização da Nota Fiscal: ", l_sqlca
                  rollback work
                  initialize ctb11m01.*   to null
                  initialize k_ctb11m01.* to null
                  return k_ctb11m01.*
               end if
            end if
         else
            if sqlca.sqlerrd[3] = 0
               then
               error " OP ainda não possui itens, Documento Fiscal não gravado "
               sleep 1
            else
               error " Atualização do Documento Fiscal ok em ", l_sqlerr, " itens"
               sleep 1
               
               # num de NF gravado nos itens, atualiza etapa para "Digitada"
               call cts50g00_atualiza_etapa(k_ctb11m01.socopgnum, 3, 
                                            g_issk.funmat)
                                  returning lr_retorno.retorno,
                                            lr_retorno.mensagem
                                            
               if lr_retorno.retorno != 1
                  then
                  error lr_retorno.mensagem
                  sleep 2
                  rollback work
                  initialize ctb11m01.*   to null
                  initialize k_ctb11m01.* to null
                  return k_ctb11m01.*
               end if
            end if
            
         end if
      end if
      
      #--> ini PSI-11-19199PR Registrar historico alteracao aliquota ISS
      #
      if (ws.infissalqvlr is null and ctb11m01.infissalqvlr is not null) then
#        let l_historico = "nao gravar"     # conf. Sergio Burini
      else
         if (ws.infissalqvlr is not null and ctb11m01.infissalqvlr is null) then
            let l_historico = "Alteração aliquota ISS de ", ws.infissalqvlr using "-<<<<<<<<&.&&", " para 0.00"
         else
            if ws.infissalqvlr <> ctb11m01.infissalqvlr then
               let l_historico = "Alteração aliquota ISS de ", ws.infissalqvlr using "-<<<<<<<<&.&&", " para ", ctb11m01.infissalqvlr using "-<<<<<<<<&.&&"
            end if
         end if
      end if

      if l_historico is not null then
         call ctc00m24_logarHistoricoOrdPg( k_ctb11m01.socopgnum
                                          , l_historico
                                          , g_issk.empcod
                                          , g_issk.usrtip
                                          , g_issk.funmat
                                          , g_issk.funnom        )
            returning lr_retorno.retorno
                    , lr_retorno.mensagem
                    , l_codaux

         if lr_retorno.mensagem is not null then
            error lr_retorno.mensagem; sleep 2
            rollback work
            initialize ctb11m01.*   to null
            initialize k_ctb11m01.* to null
            return k_ctb11m01.*
         end if
      end if #--> fim PSI-11-19199PR

      error " Alteracao efetuada com sucesso!"
      sleep 1
      
   commit work
   
   call ctb11m09(ctb11m01.socopgnum, "ctb11m01", 
                 m_opg.pstcoddig, ctb11m01.pestip, ctb11m01.segnumdig)
   whenever error stop

   return k_ctb11m01.*

end function  ###  modifica_ctb11m01

#--------------------------------------------------------------------
function input_ctb11m01(operacao_aux, k_ctb11m01, ctb11m01)
#--------------------------------------------------------------------

 define operacao_aux char (01)
       ,l_i    smallint
       ,l_tam  smallint

 define ctb11m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),        #PSI 205206
    favtip           smallint,
    favtipcab        char (14),
    favtipcod        char (08),
    favtipnom        char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    cctcod           like dbsmopg.cctcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
#PSI197858 - inicio
#    socpgtdsctip     like dbsmopg.socpgtdsctip,
#    socpgtdscdes     char (15),
    socopgdscvlr     like dbsmopg.socopgdscvlr,
#PSI197858 - fim
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    pstcoddig        like dbsmopg.pstcoddig,
    soctip           like dbsmopg.soctip,
    segnumdig        like dbsmopg.segnumdig,
    ciaempcod        like datmservico.ciaempcod,  
    corsus           like dbsmopg.corsus,
    infissalqvlr     like dbsmopg.infissalqvlr,    # PSI-11-19199PR
    simoptpstflg     like dpaksocor.simoptpstflg   # PSI-11-19199PR
 end record

 define k_ctb11m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

 define ws           record
    confirma         char (01),
    bcoagnnum        like gcdkbancoage.bcoagnnum,
    bcoagndig        like gcdkbancoage.bcoagndig,
    cgccpfdig        like dbsmopg.cgccpfdig,
    pstsrvtip        like dpatserv.pstsrvtip,
    psttaxflg        smallint,
    pestip           like dpaksocor.pestip,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socfavnomcad     like dpaksocorfav.socfavnom,
    pestipcad        like dpaksocorfav.pestip,
    cgccpfnumcad     like dpaksocorfav.cgccpfnum,
    cgcordcad        like dpaksocorfav.cgcord,
    cgccpfdigcad     like dpaksocorfav.cgccpfdig,
    confirma2        char (01),
    prscootipcod     like dpaksocor.prscootipcod,
    segnumdig        like dbsmopg.segnumdig,
    infissalqvlr     like dbsmopg.infissalqvlr       # PSI-11-19199PR
 end record

 define lr_param     record     #PSI 191167
    empcod           like ctgklcl.empcod       #Empresa
   ,succod           like ctgklcl.succod       #Sucursal
   ,cctlclcod        like ctgklcl.cctlclcod    #Local
   ,cctdptcod        like ctgrlcldpt.cctdptcod #Departamento
 end record

 define lr_ret       record     #PSI 191167
    erro             smallint                     #0-Ok,1-erro
   ,mens             char(40)
   ,cctlclnom        like ctgklcl.cctlclnom       #Nome do local
   ,cctdptnom        like ctgkdpt.cctdptnom       #Nome do dep.(antigo cctnom)
   ,cctdptrspnom     like ctgrlcldpt.cctdptrspnom #Responsavel pelo departamento
   ,cctdptlclsit     like ctgrlcldpt.cctdptlclsit #Sit do dep (A)tivo,(I)nativo
   ,cctdpttip        like ctgkdpt.cctdpttip       #Tipo de departamento
 end record

 define sql_select  char (200),
        l_res       smallint,
        l_msg       char(80),
        l_ret       char(1) ,
        l_sql       char(200),
        l_vlr       char(10),
        l_codaux    smallint
        
 define lr_opsap    integer #Fornax-Quantum

 let l_res = null
 let l_msg = null
 let l_vlr = null
 let l_codaux = null
 let l_i = 0
 let l_tam = 0

 let int_flag = false
 initialize ws.*   to null

 if operacao_aux = "a"  then
    if dias_uteis(ctb11m01.socfatpgtdat, 0, "", "S", "S") = ctb11m01.socfatpgtdat  then
    else
       if ctb11m01.socfatpgtdat  <>  "18/10/1999"   then
          call cts08g01("A","N","","DATA DE PAGAMENTO NAO","PODE SER FERIADO!","")
           returning ws.confirma2
           let int_flag = true
           initialize ctb11m01.*  to null
           return ctb11m01.*
       end if
    end if
    
    # if dias_entre_datas (today, ctb11m01.socfatpgtdat, "", "S", "S") <= 4  then
    #    call cts08g01("A", "N", "",
    #                  "PAGAMENTO DEVE SER PROGRAMADO COM",
    #                  "PELO MENOS QUATRO DIAS DE ANTECEDENCIA!","")
    #         returning ws.confirma2
    # 
    #    let int_flag = true
    #    initialize ctb11m01.*  to null
    #    return ctb11m01.*
    # end if
    
 end if
 
 input by name # ctb11m01.socopgnum,
               ctb11m01.socfatpgtdat,
               # ctb11m01.socopgsitcod,
               ctb11m01.infissalqvlr,              # PSI-11-19199PR
               ctb11m01.socpgtdoctip,
               ctb11m01.nfsnum,
               ctb11m01.fisnotsrenum,  #Fornax - Quantum
               ctb11m01.socemsnfsdat,
               ctb11m01.succod,
               ctb11m01.socpgtopccod,
               ctb11m01.pgtdstcod,
               ctb11m01.socopgfavnom,
               ctb11m01.pestip,
               ctb11m01.cgccpfnum,
               ctb11m01.cgcord,
               ctb11m01.cgccpfdig,
               ctb11m01.bcoctatip,
               ctb11m01.bcocod,
               ctb11m01.bcoagnnum,
               ctb11m01.bcoagndig,
               ctb11m01.bcoctanum,
               ctb11m01.bcoctadig,
               ctb11m01.simoptpstflg without defaults
               #PSI197858 - inicio
               #                 ctb11m01.socpgtdsctip,
               #                 ctb11m01.socopgdscvlr
               #PSI197858 - fim
               
    # before field socopgnum
    #        let ctb11m01.empcod = 01
    #        let ctb11m01.cctcod = 12243 #PSI 191167
    #        
    #        # ligia 21/08/08 - PSI 198404
    #        # #PSI 191167
    #        # let lr_param.empcod    = 01 ###ctb11m01.empcod
    #        # let lr_param.succod    = 01 
    #        # let lr_param.cctlclcod = (12243 / 10000)
    #        # let lr_param.cctdptcod = (12243 mod 10000)
    #        # 
    #        # call fctgc102_vld_dep(lr_param.*) returning lr_ret.*
    #        # 
    #        # if lr_ret.erro <>  0  
    #        #    then
    #        #    error "Erro",lr_ret.erro," na leitura do centro de custo!"
    #        #    sleep 3
    #        #    error lr_ret.mens
    #        # end if
    #        ###let ctb11m01.cctnom = lr_ret.cctdptnom
    #        #Fim PSI 191167
    #        
    #        display by name ctb11m01.socopgnum   attribute(reverse)

    # after  field socopgnum
    #        display by name ctb11m01.socopgnum

    before field socfatpgtdat
           display by name ctb11m01.socfatpgtdat attribute(reverse)

    after  field socfatpgtdat
           display by name ctb11m01.socfatpgtdat

           call ctb01g00(operacao_aux, ctb11m01.favtip, 
                         ctb11m01.favtipcod, ctb11m01.socfatpgtdat)
                returning l_res, l_msg

           if l_res = 2 then
              if l_msg is not null then
                 error l_msg
              end if
              next field socfatpgtdat
           else
              next field infissalqvlr                  # PSI-11-19199PR
           end if

    # before field socopgsitcod
    #        display by name ctb11m01.socopgsitcod  attribute(reverse)
    
    # after  field socopgsitcod
    #        display by name ctb11m01.socopgsitcod

    before field infissalqvlr                           # ini PSI-11-19199PR
           if ctb11m01.simoptpstflg = "N" then
              next field socpgtdoctip
           end if
           let ws.infissalqvlr = ctb11m01.infissalqvlr
           display by name ctb11m01.infissalqvlr attribute(reverse)

    after  field infissalqvlr
           display by name ctb11m01.infissalqvlr

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socfatpgtdat
           end if

           if ctb11m01.simoptpstflg = "S" then
              if ctb11m01.infissalqvlr is null or
                 ctb11m01.infissalqvlr <= 0.0  then
                 error " Aliquota ISS obrigatorio para Optante pelo Simples!"
                 next field infissalqvlr
              else
                 
                 let l_vlr = ctb11m01.infissalqvlr 
                 let l_tam = length(l_vlr)
                 #display 'l_tam: ', l_tam
                 for l_i = 1 to l_tam 
                 
                    #display "l_vlr[l_i]", l_i
                    if l_vlr[l_i] = '.' then
                       #display 'entrei no if'
                       let  l_vlr[l_i] = ','
                    end if                 
                                
                 end for
                 

                 display "l_vlr: ", l_vlr
                 call ctc00m24_obterCodIddkDominio( "psoaliquotasiss" # cponom
                                                  , l_vlr           ) # cpodes
                      returning l_res
                              , l_msg
                              , l_codaux

                 if l_res <> 0 then
                    if l_res = 2 then
                       error " Aliquota ISS invalida para Optante pelo Simples!"
                    else
                       error l_msg
                    end if
                    next field infissalqvlr
                 end if
              end if
           end if                                       # fim PSI-11-19199PR
           
    before field socpgtdoctip
           let ws.socpgtdoctip = ctb11m01.socpgtdoctip
           display by name ctb11m01.socpgtdoctip attribute(reverse)

    after  field socpgtdoctip
           display by name ctb11m01.socpgtdoctip

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  infissalqvlr
           end if

           if ctb11m01.socpgtdoctip is null
              then
              error " Tipo de documento deve ser informado!"
              next field socpgtdoctip
           end if
           
           if ctb11m01.socpgtdoctip <> 1 and
              ctb11m01.socpgtdoctip <> 2 and
              ctb11m01.socpgtdoctip <> 3 and
              ctb11m01.socpgtdoctip <> 4 
              then
              error " Informe o Tipo de Docto: 1-Nota Fiscal, 2-Recibo, 3-R.P.A., 4-NF Eletrônica"
              next field socpgtdoctip
           end if
           
           if ctb11m01.socpgtdoctip is not null and
              ctb11m01.socpgtdoctip > 0
              then
              initialize m_dominio.* to null
              
              call cty11g00_iddkdominio('socpgtdoctip', ctb11m01.socpgtdoctip)
                   returning m_dominio.*
                   
              if m_dominio.erro = 1
                 then
                 let ctb11m01.socpgtdocdes = m_dominio.cpodes clipped
              else
                 initialize ctb11m01.socpgtdocdes to null
                 error "Tipo documento fiscal: ", m_dominio.mensagem
              end if
           end if
           
           display by name ctb11m01.socpgtdoctip, ctb11m01.socpgtdocdes
           
           if operacao_aux = "a"         and
              ctb11m01.socpgtdoctip = 1  and           # NOTA FISCAL
              ws.socpgtdoctip <> ctb11m01.socpgtdoctip then
              
              declare c_ctb11m01nfs cursor for
                 select nfsnum from dbsmopgitm
                  where socopgnum = ctb11m01.socopgnum

              open  c_ctb11m01nfs
              fetch c_ctb11m01nfs
              if sqlca.sqlcode = 0  then
                 let ctb11m01.socpgtdoctip = ws.socpgtdoctip
                 display by name ctb11m01.socpgtdoctip
                 error " Nao e' possivel alterar tipo de documento! Ja' existem itens digitados!"
                 next field socpgtdoctip
              end if
              close c_ctb11m01nfs
           end if

           # nao é preciso selecionar novamente, dados vem da funcao LER
           # initialize m_opg.pstcoddig to null
           # 
           # select pstcoddig, cgccpfnum,
           #        cgcord   , cgccpfdig,
           #        pestip   , soctip
           #   into m_opg.pstcoddig,
           #        ctb11m01.opgcgccpfnum,
           #        ctb11m01.opgcgcord,
           #        ctb11m01.opgcgccpfdig,
           #        ws.pestip,
           #        m_opg.soctip
           #   from dbsmopg
           #  where socopgnum = ctb11m01.socopgnum

           if m_opg.pstcoddig is not null  and
              m_opg.pstcoddig >  11        then

              #------------------------------
              # Obtem tipo de cooperativa
              #------------------------------
              select prscootipcod
                into ws.prscootipcod
                from dpaksocor
               where pstcoddig = m_opg.pstcoddig

              if m_opg.pestip  =  "J"   then
                 declare c_dpatserv cursor for
                    select pstsrvtip
                      from dpatserv
                     where pstcoddig = m_opg.pstcoddig

                 initialize ws.pstsrvtip to null
                 let ws.psttaxflg = false

                 foreach c_dpatserv into ws.pstsrvtip
                    if ws.pstsrvtip = 16  then  ###  Tipo Servico TAXI
                       let ws.psttaxflg = true
                    else
                       let ws.psttaxflg = false
                       exit foreach
                    end if
                 end foreach

                 #-----------------------------------------------------------
                 # Prestadores de TAXI (pessoa juridica) podem emitir recibo
                 #-----------------------------------------------------------
                 if ws.psttaxflg = false  then
                    if ctb11m01.socpgtdoctip = 2   or
                       ctb11m01.socpgtdoctip = 3   then
                       initialize ctb11m01.opgcgccpfnum thru ctb11m01.trbprstip to null
                       error " Pessoa juridica nao pode utilizar Recibo/R.P.A!"
                       next field socpgtdoctip
                    end if
                 end if
              end if
              
              # PSI 198404 People, dados nao estao mais no tributos
              # if ws.pestip    = "F"   or   ###  Pessoa FISICA
              #    # m_opg.pstcoddig = 3377  or   ###  Coop. Mista Trab. Autonomos
              #    # m_opg.pstcoddig = 3484  or   ###  A Coop. Center Taxi Jacarei
              #    # m_opg.pstcoddig = 3613  or   ###  Bel Taxi Coop. Taxi
              #    # m_opg.pstcoddig = 3614  or   ###  Coop. Mista Duque de Caxias
              #    # m_opg.pstcoddig = 3616  or   ###  Cooprataf
              #    # m_opg.pstcoddig = 3618  or   ###  Cooptri
              #    # m_opg.pstcoddig = 3696  or   ###  Coop. radio taxi de Resende
              #    # m_opg.pstcoddig = 4088  or   ###  Coop. Mista Radio Taxi Maceio
              #    # m_opg.pstcoddig = 4093  or   ###  Coop. Uniao Serv Taxi Auton.
              #    # m_opg.pstcoddig = 4257  or   ###  Coop. Mista Motoristas S.Luis
              #    (ws.prscootipcod is not null and ### COOPERATIVA TAXI
              #     ws.prscootipcod     = 1        )
              #    then
              #    call ctb11m12("A",
              #                    ctb11m01.opgcgccpfnum,
              #                    ctb11m01.opgcgcord,
              #                    ctb11m01.trbempcod,
              #                    ctb11m01.trbsuccod,
              #                    ctb11m01.trbprstip)
              #          returning ctb11m01.opgcgccpfnum,
              #                    ctb11m01.opgcgcord,
              #                    ctb11m01.trbempcod,
              #                    ctb11m01.trbsuccod,
              #                    ctb11m01.trbprstip
              #                    
              #    if ctb11m01.opgcgccpfnum is null  or
              #       ctb11m01.trbempcod    is null  or
              #       ctb11m01.trbsuccod    is null  or
              #       ctb11m01.trbprstip    is null  then
              #       initialize ctb11m01.trbempcod thru ctb11m01.trbprstip to null
              #       error " Contribuinte para tributacao deve ser informado!"
              #       next field socpgtdoctip
              #    end if
              # else
              #    initialize ctb11m01.trbempcod thru ctb11m01.trbprstip to null
              # end if
              
           end if
           
           # PSI 236292, acompanhar recolhimento de impostos
           call ctn55g00(ctb11m01.socopgnum)
           
    before field nfsnum
           display by name ctb11m01.nfsnum attribute (reverse)
           
    after field nfsnum
    
           # Retirado a pedido do PS em 22/06/2009
           # if ctb11m01.socpgtdoctip = 1  or  # NF
           #    ctb11m01.socpgtdoctip = 4      # NFE
           #    then
           #    if ctb11m01.nfsnum is null or
           #       ctb11m01.nfsnum <= 0
           #       then
           #       error " Número da nota fiscal deve ser informado!"
           #       next field nfsnum
           #    end if
           # end if
           
           if ctb11m01.nfsnum is not null and
              ctb11m01.nfsnum > 0
              then
              let l_ret = null
              
              call ctb00g01_vernfs(m_opg.soctip          ,
                                   m_opg.pestip          ,
                                   ctb11m01.cgccpfnum    ,
                                   ctb11m01.cgcord       ,
                                   ctb11m01.cgccpfdig    ,
                                   ctb11m01.socopgnum    ,
                                   ctb11m01.socpgtdoctip ,
                                   ctb11m01.nfsnum )
                         returning l_ret
                         
              if l_ret = "S" then
                 error " Documento já informado para o prestador, verifique "
                 next field nfsnum
              end if
           end if
           
           display by name ctb11m01.nfsnum

    #Fornax - Quantum - inicio
    before field fisnotsrenum
           display by name ctb11m01.fisnotsrenum attribute (reverse)

    after  field fisnotsrenum
           display by name ctb11m01.fisnotsrenum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field nfsnum
           end if
    #Fornax - Quantum - final       
               
    before field socemsnfsdat
           display by name ctb11m01.socemsnfsdat attribute (reverse)

    after  field socemsnfsdat
           display by name ctb11m01.socemsnfsdat

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
             #next field nfsnum  #Fornax - Quantum
              next field fisnotsrenum
           end if

           if ctb11m01.socemsnfsdat is null  then
              error " Data de emissao da nota fiscal deve ser informada!"
              next field socemsnfsdat
           end if

           if ctb11m01.socemsnfsdat > today  then
              error " Data de emissao da nota fiscal nao pode ser maior que a data atual!"
              next field socemsnfsdat
           end if

           if ctb11m01.socemsnfsdat < today - 90 units day  and
              g_issk.acsnivcod      < 8                     then
              error " Data de emissao da nota fiscal nao pode ser anterior a noventa dias!"
              next field socemsnfsdat
           end if
           
           if ctb11m01.socemsnfsdat < today - 1 units year  then
              error " Data de emissao da nota fiscal nao pode ser anterior a um ano!"
              next field socemsnfsdat
           end if
           
           if ctb11m01.socemsnfsdat > today + 1 units year  then
              error " Data de emissao da nota fiscal nao pode ser posterior a um ano!"
              next field socemsnfsdat
           end if
           
           

           call ctd20g01_tem_item_nf(ctb11m01.socopgnum)
                returning l_res, l_msg

           # PSI 198404, NF digitada na capa da OP e nao nos itens
           # if l_res = 1 then
           #    call ctb11m16(ctb11m01.socopgnum) returning l_msg
           # end if
           
           if l_res = 3 then
              error l_msg
              next field socemsnfsdat
           end if
           
    before field succod
           if ctb11m01.favtip != 3
              then
              if ctb11m01.succod is null
                 then
                 call ctd12g00_dados_pst(3, ctb11m01.favtipcod)
                      returning l_res, l_msg, ctb11m01.succod
              end if
              
              if ctb11m01.succod is not null
                 then
                 call cty10g00_nome_sucursal(ctb11m01.succod)
                      returning l_res, l_msg, ctb11m01.sucnom
              end if
              
              display by name ctb11m01.succod, ctb11m01.sucnom
              next field socpgtopccod
           end if
           
    after field succod
           if ctb11m01.favtip = 3  # Segurado
              then
              if ctb11m01.succod is null or
                 ctb11m01.succod <= 0
                 then
                 let l_sql = " select succod, sucnom from gabksuc ",
                             " order by 2 "                       
                 call ofgrc001_popup(08, 13, 'SUCURSAL DE REEMBOLSO',
                                     'Codigo', 'Descricao', 'N', l_sql, '', 'D')
                      returning l_res, ctb11m01.succod, ctb11m01.sucnom
                 next field succod
              end if
              
              if ctb11m01.succod is not null
                 then
                 call cty10g00_nome_sucursal(ctb11m01.succod)
                      returning l_res, l_msg, ctb11m01.sucnom
     
                 if l_res != 1 then
                    error l_msg
                    next field succod
                 end if
              end if
              display by name ctb11m01.succod, ctb11m01.sucnom
           else
              next field socpgtopccod
           end if
           
    before field socpgtopccod
           display by name ctb11m01.socpgtopccod attribute (reverse)

    after  field socpgtopccod
           display by name ctb11m01.socpgtopccod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socemsnfsdat
           end if
           
           #Fornax - Quantum - inicio
           #Informar o numero da OP SAP, qdo pagto cheque
           if ctb11m01.socpgtopccod = 2 then
           
              #Verifica se a OP e People ou SAP  Inicio  #Fornax-Quantum  
              call ffpgc377_verificarIntegracaoAtivaEmpresaRamo("038PTSOCTRIB",today,ctb11m01.empcod, 0)  
                   returning  mr_retSAP.stt                                                                 
                             ,mr_retSAP.msg     
                     
              display "mr_retSAP.stt ", mr_retSAP.stt
              display "mr_retSAP.msg ", mr_retSAP.msg                                                             
              
              if mr_retSAP.stt <> 0 then    
                call ctb11m01a(ctb11m01.socopgnum)
                returning lr_opsap          
                                            
                if lr_opsap = 0 then        
                   next field socpgtopccod  
                end if 
              end if                       
           end if
           #Fornax - Quantum - final

           #------------------------------------------------------------------
           # Pagamento a prestadores sem cadastro e Reembolsos
           #------------------------------------------------------------------
           if ctb11m01.socpgtopccod   is null   then
              error " Opcao de pagamento deve ser informada!"
              next field socpgtopccod
           end if
           
           initialize m_dominio.* to null
           
           call cty11g00_iddkdominio('socpgtopccod', ctb11m01.socpgtopccod)
                returning m_dominio.*
                
           if m_dominio.erro = 1
              then
              let ctb11m01.socpgtopcdes = m_dominio.cpodes clipped
           else
              initialize ctb11m01.socpgtopcdes to null
              error " Opcao de pagamento nao cadastrada!"
              next field socpgtopccod
           end if
           
           display by name ctb11m01.socpgtopcdes
           
           if ctb11m01.socpgtopccod  =  2    then
              initialize ctb11m01.bcoctatip,
                         ctb11m01.bcoctatipdes,
                         ctb11m01.bcocod,
                         ctb11m01.bcosgl,
                         ctb11m01.bcoagnnum,
                         ctb11m01.bcoagndig,
                         ctb11m01.bcoagnnom,
                         ctb11m01.bcoctanum,
                         ctb11m01.bcoctadig  to null

              display by name ctb11m01.bcoctatip,
                              ctb11m01.bcoctatipdes,
                              ctb11m01.bcocod,
                              ctb11m01.bcosgl,
                              ctb11m01.bcoagnnum,
                              ctb11m01.bcoagndig,
                              ctb11m01.bcoagnnom,
                              ctb11m01.bcoctanum,
                              ctb11m01.bcoctadig
           end if
           
           #------------------------------------------------------------
           # Dia do securitario so' pagto com boleto bancario
           #------------------------------------------------------------
           if ctb11m01.socfatpgtdat  =  "18/10/1999"   then
              if ctb11m01.socpgtopccod  <>  3          then
                 error " Nesta data somente pagamentos com boleto bancario!"
                 next field socpgtopccod
              end if
           end if

           #-----------------------------------------------------------------
           # Nos casos de pagamento a prestadores cadastrados, os dados para
           # pagamento devem ser iguais ao cadastro
           #-----------------------------------------------------------------
           initialize ws.pestipcad   , ws.cgccpfnumcad, ws.cgcordcad,
                      ws.cgccpfdigcad, ws.socfavnomcad  to null

           if m_opg.pstcoddig  is not null   and
              m_opg.pstcoddig  >  11         then

              select pestip   , cgccpfnum,
                     cgcord   , cgccpfdig,
                     socfavnom
                into ws.pestipcad   , ws.cgccpfnumcad,
                     ws.cgcordcad   , ws.cgccpfdigcad,
                     ws.socfavnomcad
                from dpaksocorfav
               where pstcoddig = m_opg.pstcoddig

              if sqlca.sqlcode != 0
                 then
                 if sqlca.sqlcode = 100
                    then
                    error " Favorecido nao cadastrado. Atualize o cadastro do Prestador "
                 else
                    error " Erro (",sqlca.sqlcode,") na leitura do cadastro do favorecido! "
                 end if
                 sleep 1
                 next field socpgtopccod
              end if

              error " Confirme dados para pagamento com o cadastro! "
              call ctb11m05(m_opg.pstcoddig)
                   returning ctb11m01.pestip      , ctb11m01.cgccpfnum,
                             ctb11m01.cgcord      , ctb11m01.cgccpfdig,
                             ctb11m01.socopgfavnom, ctb11m01.bcocod,
                             ctb11m01.bcosgl      , ctb11m01.bcoagnnum,
                             ctb11m01.bcoagndig   , ctb11m01.bcoagnnom,
                             ctb11m01.bcoctanum   , ctb11m01.bcoctadig,
                             ctb11m01.socpgtopccod, ctb11m01.socpgtopcdes,
                             ctb11m01.bcoctatip   , ctb11m01.bcoctatipdes,
                             ws.confirma

              if ws.confirma  is null    or
                 ws.confirma  = "N"      then
                 error " Informacoes do cadastro nao foram confirmadas!"
                 next field socpgtopccod
              end if

              display by name ctb11m01.pestip      , ctb11m01.cgccpfnum,
                              ctb11m01.cgcord      , ctb11m01.cgccpfdig,
                              ctb11m01.socopgfavnom, ctb11m01.bcocod,
                              ctb11m01.bcosgl      , ctb11m01.bcoagnnum,
                              ctb11m01.bcoagndig   , ctb11m01.bcoagnnom,
                              ctb11m01.bcoctanum   , ctb11m01.bcoctadig,
                              ctb11m01.socpgtopccod, ctb11m01.socpgtopcdes,
                              ctb11m01.bcoctatip   , ctb11m01.bcoctatipdes

              if ctb11m01.pestip     is null    or
                 ctb11m01.cgccpfnum  is null    or
                 ctb11m01.cgccpfdig  is null    then
                 error " Prestador nao possui Cgc/Cpf favorecido cadastrado!"
                 next field socpgtopccod
              end if

              if ctb11m01.socopgfavnom  is null    then
                 error " Prestador nao possui nome do favorecido cadastrado!"
                 next field socpgtopccod
              end if

              if ctb11m01.socpgtopccod  =  2    then
                 next field pgtdstcod
              else
                 next field socopgfavnom
              end if
           else
              # Nao sugerir dados para o reembolso, devem vir do protocolo da OP
              # Revisao reembolso, Abril/2010
              # if ctb11m01.favtip = 3  and   # Segurado
              #    ctb1m01.socopgsitcod = 1   # Nao analisada
              #    then
              #    call ctd20g07_dados_cli(ctb11m01.segnumdig)
              #         returning l_res, l_msg,  
              #                   ctb11m01.socopgfavnom, 
              #                   ctb11m01.cgccpfnum   ,
              #                   ctb11m01.cgcord      , 
              #                   ctb11m01.cgccpfdig   ,
              #                   ctb11m01.pestip
              #                   
              #    display by name ctb11m01.socopgfavnom, ctb11m01.cgccpfnum,
              #                    ctb11m01.cgcord      , ctb11m01.cgccpfdig,
              #                    ctb11m01.pestip
              #                    
              #    error ' Foram sugeridos os dados do cliente para favorecido da OP'
              #    sleep 1
              # end if
           end if

    before field pgtdstcod
           if ctb11m01.socpgtopccod  =  1   or    #--> Deposito em conta
              ctb11m01.socpgtopccod  =  3   then  #--> Boleto bancario
              initialize ctb11m01.pgtdstcod, ctb11m01.pgtdstdes   to null
              display by name ctb11m01.pgtdstcod, ctb11m01.pgtdstdes
              next field socopgfavnom
           end if
           display by name ctb11m01.pgtdstcod   attribute(reverse)

    after  field pgtdstcod
           display by name ctb11m01.pgtdstcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socpgtopccod
           end if

           if ctb11m01.pgtdstcod   is null   then
              error " Destino deve ser informado!"
              call ctb11m04() returning  ctb11m01.pgtdstcod
              next field pgtdstcod
           end if

           select pgtdstdes
             into ctb11m01.pgtdstdes
             from fpgkpgtdst
            where fpgkpgtdst.pgtdstcod = ctb11m01.pgtdstcod

           if sqlca.sqlcode <> 0    then
              error " Destino nao cadastrado!"
              call ctb11m04() returning  ctb11m01.pgtdstcod
              next field pgtdstcod
           else
              display by name ctb11m01.pgtdstdes
           end if

    before field socopgfavnom
           display by name ctb11m01.socopgfavnom   attribute(reverse)

    after  field socopgfavnom
           display by name ctb11m01.socopgfavnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if ctb11m01.socpgtopccod  =  1   or    #--> Deposito em conta
                 ctb11m01.socpgtopccod  =  3   then  #--> Boleto bancario
                 next field socpgtopccod
              end if
              next field  pgtdstcod
           end if

           if ctb11m01.socopgfavnom   is null   then
              error " Nome do favorecido deve ser informado!"
              next field socopgfavnom
           end if

           if m_opg.pstcoddig  is not null   and
              m_opg.pstcoddig  >  11         then
              if ctb11m01.socopgfavnom  <>  ws.socfavnomcad   then
                 error " Nome do favorecido diferente do cadastro!"
                 next field socopgfavnom
              end if
           end if

    before field pestip
           display by name ctb11m01.pestip   attribute(reverse)

    after  field pestip
           display by name ctb11m01.pestip

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socopgfavnom
           end if

           if ctb11m01.pestip   is null   then
              error " Tipo de pessoa deve ser informado!"
              next field pestip
           end if

           if ctb11m01.pestip  <>  "F"   and
              ctb11m01.pestip  <>  "J"   then
              error " Tipo de pessoa invalido!"
              next field pestip
           end if

           if ctb11m01.pestip  =  "F"   then
              initialize ctb11m01.cgcord  to null
              display by name ctb11m01.cgcord
           end if

    before field cgccpfnum
           display by name ctb11m01.cgccpfnum   attribute(reverse)

    after  field cgccpfnum
           display by name ctb11m01.cgccpfnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field pestip
           end if

           if ctb11m01.cgccpfnum   is null   or
              ctb11m01.cgccpfnum   =  0      then
              error " Numero do Cgc/Cpf deve ser informado!"
              next field cgccpfnum
           end if

           if ctb11m01.pestip  =  "F"   then
              next field cgccpfdig
           end if

    before field cgcord
           display by name ctb11m01.cgcord   attribute(reverse)

    after  field cgcord
           display by name ctb11m01.cgcord

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field cgccpfnum
           end if

           if ctb11m01.cgcord   is null   or
              ctb11m01.cgcord   =  0      then
              error " Filial do Cgc/Cpf deve ser informada!"
              next field cgcord
           end if

    before field cgccpfdig
           display by name ctb11m01.cgccpfdig  attribute(reverse)

    after  field cgccpfdig
           display by name ctb11m01.cgccpfdig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if ctb11m01.pestip  =  "J"  then
                 next field cgcord
              else
                 next field cgccpfnum
              end if
           end if

           if ctb11m01.cgccpfdig   is null   then
              error " Digito do Cgc/Cpf deve ser informado!"
              next field cgccpfdig
           end if

           if ctb11m01.pestip  =  "J"    then
              call F_FUNDIGIT_DIGITOCGC(ctb11m01.cgccpfnum, ctb11m01.cgcord)
                   returning ws.cgccpfdig
           else
              call F_FUNDIGIT_DIGITOCPF(ctb11m01.cgccpfnum)
                   returning ws.cgccpfdig
           end if

           if ws.cgccpfdig       is null           or
              ctb11m01.cgccpfdig <> ws.cgccpfdig   then
              error "Digito Cgc/Cpf incorreto!"
              next field cgccpfdig
           end if

           if m_opg.pstcoddig  is not null   and
              m_opg.pstcoddig  >  11         then
              if ctb11m01.pestip     <>  ws.pestipcad      or
                 ctb11m01.cgccpfnum  <>  ws.cgccpfnumcad   or
                 ctb11m01.cgccpfdig  <>  ws.cgccpfdigcad   then
                 error " Cgc/Cpf diferente do cadastro!"
                 next field cgccpfdig
                 #PSI197858 - inicio
                 # else
                 #    next field socpgtdsctip
                 #PSI197858 - fim
              end if
           end if

           if ctb11m01.nfsnum is not null and
              ctb11m01.nfsnum > 0
              then
              let l_ret = null
              
              call ctb00g01_vernfs(m_opg.soctip          ,
                                   ctb11m01.pestip       ,
                                   ctb11m01.cgccpfnum    ,
                                   ctb11m01.cgcord       ,
                                   ctb11m01.cgccpfdig    ,
                                   ctb11m01.socopgnum    ,
                                   ctb11m01.socpgtdoctip ,
                                   ctb11m01.nfsnum )
                         returning l_ret
                 
              if l_ret = "S" then
                 error " Documento ", ctb11m01.nfsnum ," já informado para o prestador, verifique "
                 next field cgccpfdig
              end if
           end if
              
           if ctb11m01.socpgtopccod = 2
              then
              let int_flag = false
              exit input
           end if

    before field bcoctatip
       display by name ctb11m01.bcoctatip attribute (reverse)

    after  field bcoctatip
       display by name ctb11m01.bcoctatip

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field cgccpfdig
         end if

         if ctb11m01.bcoctatip  is null   then
            error " Tipo de conta deve ser informado!"
            next field bcoctatip
         end if

         case ctb11m01.bcoctatip
            when  1   let ctb11m01.bcoctatipdes = "C.CORRENTE"
            when  2   let ctb11m01.bcoctatipdes = "POUPANCA"
            otherwise error " Tipo Conta: 1-Conta Corrente, 2-Poupanca!"
                      next field bcoctatip
         end case
         display by name ctb11m01.bcoctatipdes

    before field bcocod
           display by name ctb11m01.bcocod   attribute(reverse)

    after  field bcocod
           display by name ctb11m01.bcocod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoctatip
           end if

           if ctb11m01.bcocod   is null   then
              error " Codigo do banco deve ser informado!"
              next field bcocod
           end if

           select bcosgl
             into ctb11m01.bcosgl
             from gcdkbanco
            where gcdkbanco.bcocod = ctb11m01.bcocod

           if sqlca.sqlcode <> 0    then
              error " Banco nao cadastrado!"
              next field bcocod
           else
              display by name ctb11m01.bcosgl
           end if

    before field bcoagnnum
           display by name ctb11m01.bcoagnnum   attribute(reverse)

    after  field bcoagnnum
           display by name ctb11m01.bcoagnnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcocod
           end if

           if ctb11m01.bcoagnnum   is null   then
              error " Codigo da agencia deve ser informada!"
              next field bcoagnnum
           end if

           initialize ws.bcoagndig        to null
           initialize ctb11m01.bcoagnnom  to null
           display by name ctb11m01.bcoagnnom

           let ws.bcoagnnum = ctb11m01.bcoagnnum

           select bcoagnnom, bcoagndig
             into ctb11m01.bcoagnnom, ws.bcoagndig
             from gcdkbancoage
            where gcdkbancoage.bcocod    = ctb11m01.bcocod      and
                  gcdkbancoage.bcoagnnum = ws.bcoagnnum

           if sqlca.sqlcode  =  0   then
              display by name ctb11m01.bcoagnnom
           end if

    before field bcoagndig
           display by name ctb11m01.bcoagndig   attribute(reverse)

    after  field bcoagndig
           display by name ctb11m01.bcoagndig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoagnnum
           end if

           # inibir conforme solicitacao projeto People 10/08/2009
           # if ctb11m01.bcocod  <>  424   and    #-> Noroeste
           #    ctb11m01.bcocod  <>  399   and    #-> Bamerindus
           #    ctb11m01.bcocod  <>  320   and    #-> Bicbanco
           #    ctb11m01.bcocod  <>  409   and    #-> Unibanco
           #    ctb11m01.bcocod  <>  231   and    #-> Boa Vista
           #    ctb11m01.bcocod  <>  347   and    #-> Sudameris
           #    ctb11m01.bcocod  <>  8     and    #-> Meridional
           #    ctb11m01.bcocod  <>  33    and    #-> Banespa
           #    ctb11m01.bcocod  <>  388   and    #-> B.M.D.
           #    ctb11m01.bcocod  <>  21    and    #-> Banco do Espirito Santo
           #    ctb11m01.bcocod  <>  230   and    #-> Bandeirantes
           #    ctb11m01.bcocod  <>  31    and    #-> Banco do Estado de Goias
           #    ctb11m01.bcocod  <>  479   and    #-> Banco de Boston
           #    ctb11m01.bcocod  <>  745   then   #-> Citibank
           #    if g_issk.acsnivcod  <  8         and
           #       ctb11m01.bcoagndig   is null   then
           #       error " Digito da agencia deve ser informado!"
           #       next field bcoagndig
           #    end if
           # end if

    before field bcoctanum
           display by name ctb11m01.bcoctanum   attribute(reverse)

    after  field bcoctanum
           display by name ctb11m01.bcoctanum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoagndig
           end if

           if ctb11m01.bcoctanum   is null   or
              ctb11m01.bcoctanum   =  0      then
              error " Numero da conta corrente deve ser informado!"
              next field bcoctanum
           end if

           if ctb11m01.socpgtopccod  =  1      or
              ctb11m01.socpgtopccod  =  3      then
              if ctb11m01.bcocod     is null   or
                 ctb11m01.bcoagnnum  is null   or
                 ctb11m01.bcoctanum  is null   then
                 error " Dados para pagamento em conta incompletos!"
                 next field socpgtopccod
              end if
           else
              if ctb11m01.bcocod     is not null   or
                 ctb11m01.bcoagnnum  is not null   or
                 ctb11m01.bcoagndig  is not null   or
                 ctb11m01.bcoctanum  is not null   or
                 ctb11m01.bcoctadig  is not null   then
                 error " Dados nao conferem com opcao de pagamento!"
                 next field socpgtopccod
              end if
           end if
           
    before field bcoctadig
           display by name ctb11m01.bcoctadig   attribute(reverse)

    after  field bcoctadig
           display by name ctb11m01.bcoctadig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoctanum
           end if

           if ctb11m01.bcoctadig   is null   then
              error " Digito da conta corrente deve ser informado!"
              next field bcoctadig
           end if

#      before field socpgtdsctip
#             if m_opg.pstcoddig  is null    then
#                exit input
#             end if
#             display by name ctb11m01.socpgtdsctip   attribute(reverse)

#      after  field socpgtdsctip
#             display by name ctb11m01.socpgtdsctip

#             if fgl_lastkey() = fgl_keyval ("up")     or
#                fgl_lastkey() = fgl_keyval ("left")   then
#                if m_opg.pstcoddig   is not null   and
#                   m_opg.pstcoddig   >  11         then
#                   next field cgccpfdig
#                end if
#                if ctb11m01.socpgtopccod  =  2   then
#                   next field socopgfavnom
#                end if
#                next field bcoctadig
#             end if

#             initialize ctb11m01.socpgtdscdes   to null

#             if ctb11m01.socpgtdsctip  is not null   then
#                case ctb11m01.socpgtdsctip
#                     when  1
#                           let ctb11m01.socpgtdscdes = "AVARIAS"
#                     when  2
#                           let ctb11m01.socpgtdscdes = "EMPRESTIMO"
#                           display by name ctb11m01.socpgtdscdes
#                           error " Valor do emprestimo nao pode ser descontado do pagamento!"
#                           next field socpgtdsctip
#                     when  5
#                           let ctb11m01.socpgtdscdes = "DESCONTO"
#                     when  6
#                           let ctb11m01.socpgtdscdes = "ADIANTAMENTOS"
#                     when  7
#                           let ctb11m01.socpgtdscdes = "COMERCIAL"
#                     when  8
#                           let ctb11m01.socpgtdscdes = "FINANCIAMENTOS"
#                     when  9
#                           let ctb11m01.socpgtdscdes = "OUTROS"
#                     otherwise
#                           error "1-Avarias, 2-Emprestimo, 5-Desc., 6-Adiant., 7-Comerc., 8-Financ., 9-Outros";
#                           next field socpgtdsctip
#                end case
 #            end if
 #            display by name ctb11m01.socpgtdscdes

#             if ctb11m01.socpgtdsctip  is null   then
#                initialize ctb11m01.socopgdscvlr   to null
#                display by name ctb11m01.socopgdscvlr
#                exit input
#             end if

#      before field socopgdscvlr
#             display by name ctb11m01.socopgdscvlr   attribute(reverse)

#      after  field socopgdscvlr
#             display by name ctb11m01.socopgdscvlr

#             if fgl_lastkey() = fgl_keyval ("up")     or
#                fgl_lastkey() = fgl_keyval ("left")   then
#                next field socpgtdsctip
#             end if

#             if ctb11m01.socopgdscvlr  is not null   and
#                ctb11m01.socpgtdsctip  is null       then
#                error " Tipo do desconto deve ser informado!"
#                next field socopgdscvlr
#             end if

#             if ctb11m01.socopgdscvlr  is null       and
#                ctb11m01.socpgtdsctip  is not null   then
#                error " Valor do desconto deve ser informado!"
#                next field socopgdscvlr
#             end if

#             if ctb11m01.socopgdscvlr   =  0      then
#                error " Valor de desconto nao deve ser zero!"
#                next field socopgdscvlr
#             end if

#             if ctb11m01.socopgdscvlr  >=  ctb11m01.socfattotvlr   then
#                error " Valor desconto nao deve ser maior ou igual ao valor total da O.P.!"
#                next field socopgdscvlr
#             end if

#             if ctb11m01.pestip = "F"  and
#                (ctb11m01.socfattotvlr - ctb11m01.socopgdscvlr) < 10.00  then
#                error " Valor final do pagamento nao deve ser menor que 10.00!"
#                next field socopgdscvlr
#             end if

    on key (interrupt)
       exit input

 end input
 
 if int_flag
    then
    initialize ctb11m01.*  to null
    return ctb11m01.*
 end if
 
 return ctb11m01.*
 
end function  ###  input_ctb11m01

#--------------------------------------------------------------------
function cancela_ctb11m01(k_ctb11m01)
#--------------------------------------------------------------------

  define ctb11m01     record
         socopgnum        like dbsmopg.socopgnum,
         socopgsitcod     like dbsmopg.socopgsitcod,
         socopgsitdes     char (30),
         empresa          char (5),        #PSI 205206
         favtip           smallint,
         favtipcab        char (14),
         favtipcod        char (08),
         favtipnom        char (40),
         socfatentdat     like dbsmopg.socfatentdat,
         socfatpgtdat     like dbsmopg.socfatpgtdat,
         socfatrelqtd     like dbsmopg.socfatrelqtd,
         socfatitmqtd     like dbsmopg.socfatitmqtd,
         socfattotvlr     like dbsmopg.socfattotvlr,
         soctrfcod        like dbsmopg.soctrfcod,
         socpgtdoctip     like dbsmopg.socpgtdoctip,
         socpgtdocdes     char (15),
         empcod           like dbsmopg.empcod,
         cctcod           like dbsmopg.cctcod,
         succod           like dbsmopg.succod,
         sucnom           like gabksuc.sucnom,
         socemsnfsdat     like dbsmopg.socemsnfsdat,
         socpgtopccod     like dbsmopgfav.socpgtopccod,
         socpgtopcdes     char (10),
         pgtdstcod        like dbsmopg.pgtdstcod,
         pgtdstdes        like fpgkpgtdst.pgtdstdes,
         socopgfavnom     like dbsmopgfav.socopgfavnom,
         pestip           like dbsmopgfav.pestip,
         cgccpfnum        like dbsmopgfav.cgccpfnum,
         cgcord           like dbsmopgfav.cgcord,
         cgccpfdig        like dbsmopgfav.cgccpfdig,
         bcoctatip        like dbsmopgfav.bcoctatip,
         bcoctatipdes     char (10),
         bcocod           like dbsmopgfav.bcocod,
         bcosgl           like gcdkbanco.bcosgl,
         bcoagnnum        like dbsmopgfav.bcoagnnum,
         bcoagndig        like dbsmopgfav.bcoagndig,
         bcoagnnom        like gcdkbancoage.bcoagnnom,
         bcoctanum        like dbsmopgfav.bcoctanum,
         bcoctadig        like dbsmopgfav.bcoctadig,
         #    socpgtdsctip     like dbsmopg.socpgtdsctip,
         #    socpgtdscdes     char (15),
         socopgdscvlr     like dbsmopg.socopgdscvlr,
         opgcgccpfnum     like dbsmopg.cgccpfnum,
         opgcgcord        like dbsmopg.cgcord,
         opgcgccpfdig     like dbsmopg.cgccpfdig,
         trbempcod        like dbsmopgtrb.empcod,
         trbsuccod        like dbsmopgtrb.succod,
         trbprstip        like dbsmopgtrb.prstip,
         nfsnum           like dbsmopgitm.nfsnum,
         fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
         pstcoddig        like dbsmopg.pstcoddig,
         soctip           like dbsmopg.soctip,
         segnumdig        like dbsmopg.segnumdig,
         ciaempcod        like datmservico.ciaempcod,  
         corsus           like dbsmopg.corsus,
         infissalqvlr     like dbsmopg.infissalqvlr,    # PSI-11-19199PR
         simoptpstflg     like dpaksocor.simoptpstflg   # PSI-11-19199PR
  end record
  
  define k_ctb11m01   record
         socopgnum        like dbsmopg.socopgnum
  end record
  
  define l_res  smallint,
         l_msg  char (80)
 
  # Carrega o record ctb11m01 antes de entrar no menu para poder testar
  # a data de pagamento, e nao ter que carregar novamente se a data para
  # cancelamento for valida.
  call ler_ctb11m01(k_ctb11m01.*) returning ctb11m01.*
  
  if ctb11m01.socfatpgtdat < today 
     then
     clear form
     initialize ctb11m01.*   to null
     initialize k_ctb11m01.* to null
     error "Nao foi possivel cancelar OP, Data de pagamento menor que data atual!"
  else
  
     menu "Confirma cancelamento ?"
  
        command "Nao" "Nao cancela ordem de pagamento"
           clear form
           initialize ctb11m01.*   to null
           initialize k_ctb11m01.* to null
           error " Operacao cancelada!"
           exit menu
           
        command "Sim" "Cancela ordem de pagamento"

           if ctb11m01.socopgnum is null
              then
              initialize ctb11m01.*   to null
              initialize k_ctb11m01.* to null
              error " Ordem de pagamento nao localizada!"
           else
              
              message " Aguarde, processando cancelamento... " attribute (reverse)
              
              call ctx07g00(k_ctb11m01.socopgnum, ctb11m01.socopgsitcod,
                            ctb11m01.ciaempcod, g_issk.funmat, g_issk.empcod)
                  returning l_res, l_msg
                  
             if l_res != 0
                then
                let l_msg = ' Erro:', l_msg clipped
                message "Erro no canelamento!" attribute (reverse)
                error l_msg
             else
                initialize ctb11m01.*   to null
                initialize k_ctb11m01.* to null
                message "Cancelamento efetuado com sucesso!" attribute (reverse)
                #clear form
             end if
           end if
           
           exit menu
           
     end menu
  end if
  
  return k_ctb11m01.*

end function  ###  cancela_ctb11m01

#--------------------------------------------------------------------
function remove_ctb11m01(k_ctb11m01)
#--------------------------------------------------------------------

 define ctb11m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),         #PSI 205206
    favtip           smallint,
    favtipcab        char (14),
    favtipcod        char (08),
    favtipnom        char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
#    socpgtdsctip     like dbsmopg.socpgtdsctip,
#    socpgtdscdes     char (15),
    socopgdscvlr     like dbsmopg.socopgdscvlr,
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    pstcoddig        like dbsmopg.pstcoddig,
    soctip           like dbsmopg.soctip,
    segnumdig        like dbsmopg.segnumdig,
    ciaempcod        like datmservico.ciaempcod,
    corsus           like dbsmopg.corsus,
    infissalqvlr     like dbsmopg.infissalqvlr,    # PSI-11-19199PR
    simoptpstflg     like dpaksocor.simoptpstflg   # PSI-11-19199PR
 end record

 define k_ctb11m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

 define lr_retorno record
                       retorno   smallint,
                       mensagem  char(60)
                   end record

   menu "Confirma exclusao ?"

      command "Nao" "Nao exclui ordem de pagamento"
              clear form
              initialize ctb11m01.*   to null
              initialize k_ctb11m01.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui ordem de pagamento"
              call ler_ctb11m01(k_ctb11m01.*) returning ctb11m01.*

              if ctb11m01.socopgnum  is null   then
                 initialize ctb11m01.*   to null
                 initialize k_ctb11m01.* to null
                 error " Ordem de pagamento nao localizada!"
              else

                 begin work

                    delete from dbsmopg
                     where socopgnum = k_ctb11m01.socopgnum

                    # PSI 221074 - BURINI
                    call cts50g00_delete_etapa(k_ctb11m01.socopgnum)
                         returning lr_retorno.retorno, lr_retorno.mensagem

                    delete from dbsmopgobs
                     where socopgnum = k_ctb11m01.socopgnum

                    delete from dbsmopgfav
                     where socopgnum = k_ctb11m01.socopgnum

                    delete from dbsmopgitm
                     where socopgnum = k_ctb11m01.socopgnum

                    delete from dbsmopgcst
                     where socopgnum = k_ctb11m01.socopgnum

                    delete from dbsropgdsc
                     where socopgnum = k_ctb11m01.socopgnum

                    delete from dbsmopgtrb
                     where socopgnum = k_ctb11m01.socopgnum

                 commit work

                 if sqlca.sqlcode <> 0   then
                    initialize ctb11m01.*   to null
                    initialize k_ctb11m01.* to null
                    error " Erro (",sqlca.sqlcode,") na exlusao da ordem de pagamento!"
                 else
                    initialize ctb11m01.*   to null
                    initialize k_ctb11m01.* to null
                    error   " Ordem de pagamento excluida!"
                    message ""
                    clear form
                 end if
              end if

              exit menu
   end menu

   return k_ctb11m01.*

end function  ###  remove_ctb11m01

#---------------------------------------------------------
function ler_ctb11m01(k_ctb11m01)
#---------------------------------------------------------

   define ctb11m01     record
      socopgnum        like dbsmopg.socopgnum,
      socopgsitcod     like dbsmopg.socopgsitcod,
      socopgsitdes     char (30),
      empresa          char (5),        #PSI 205206
      favtip           smallint,
      favtipcab        char (14),
      favtipcod        char (08),
      favtipnom        char (40),
      socfatentdat     like dbsmopg.socfatentdat,
      socfatpgtdat     like dbsmopg.socfatpgtdat,
      socfatrelqtd     like dbsmopg.socfatrelqtd,
      socfatitmqtd     like dbsmopg.socfatitmqtd,
      socfattotvlr     like dbsmopg.socfattotvlr,
      soctrfcod        like dbsmopg.soctrfcod,
      socpgtdoctip     like dbsmopg.socpgtdoctip,
      socpgtdocdes     char (15),
      empcod           like dbsmopg.empcod,
      cctcod           like dbsmopg.cctcod,
      succod           like dbsmopg.succod,
      sucnom           like gabksuc.sucnom,
      socemsnfsdat     like dbsmopg.socemsnfsdat,
      socpgtopccod     like dbsmopgfav.socpgtopccod,
      socpgtopcdes     char (10),
      pgtdstcod        like dbsmopg.pgtdstcod,
      pgtdstdes        like fpgkpgtdst.pgtdstdes,
      socopgfavnom     like dbsmopgfav.socopgfavnom,
      pestip           like dbsmopgfav.pestip,
      cgccpfnum        like dbsmopgfav.cgccpfnum,
      cgcord           like dbsmopgfav.cgcord,
      cgccpfdig        like dbsmopgfav.cgccpfdig,
      bcoctatip        like dbsmopgfav.bcoctatip,
      bcoctatipdes     char (10),
      bcocod           like dbsmopgfav.bcocod,
      bcosgl           like gcdkbanco.bcosgl,
      bcoagnnum        like dbsmopgfav.bcoagnnum,
      bcoagndig        like dbsmopgfav.bcoagndig,
      bcoagnnom        like gcdkbancoage.bcoagnnom,
      bcoctanum        like dbsmopgfav.bcoctanum,
      bcoctadig        like dbsmopgfav.bcoctadig,
      #PSI197858 - inicio
      #    socpgtdsctip     like dbsmopg.socpgtdsctip,
      #    socpgtdscdes     char (15),
      socopgdscvlr     like dbsmopg.socopgdscvlr,
      #PSI197858 - fim
      opgcgccpfnum     like dbsmopg.cgccpfnum,
      opgcgcord        like dbsmopg.cgcord,
      opgcgccpfdig     like dbsmopg.cgccpfdig,
      trbempcod        like dbsmopgtrb.empcod,
      trbsuccod        like dbsmopgtrb.succod,
      trbprstip        like dbsmopgtrb.prstip,
      nfsnum           like dbsmopgitm.nfsnum,
      fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
      pstcoddig        like dbsmopg.pstcoddig,
      soctip           like dbsmopg.soctip,
      segnumdig        like dbsmopg.segnumdig,
      ciaempcod        like datmservico.ciaempcod,    
      corsus           like dbsmopg.corsus,
      infissalqvlr     like dbsmopg.infissalqvlr,    # PSI-11-19199PR
      simoptpstflg     like dpaksocor.simoptpstflg   # PSI-11-19199PR
   end record
  
   define k_ctb11m01   record
      socopgnum        like dbsmopg.socopgnum
   end record
  
   define ws           record
      corsus           like dbsmopg.corsus,
      segnumdig        like dbsmopg.segnumdig,
      pstcoddig        like dbsmopg.pstcoddig,
      soctip           like dbsmopg.soctip,
      bcoagnnum        like gcdkbancoage.bcoagnnum,
      desconto	     like dbsropgdsc.dscvlr
   end record
  
   define lr_param     record     #PSI 191167
      empcod           like ctgklcl.empcod       #Empresa
     ,succod           like ctgklcl.succod       #Sucursal
     ,cctlclcod        like ctgklcl.cctlclcod    #Local
     ,cctdptcod        like ctgrlcldpt.cctdptcod #Departamento
   end record
  
   define lr_ret       record     #PSI 191167
      erro             smallint                     #0-Ok,1-erro
     ,mens             char(40)
     ,cctlclnom        like ctgklcl.cctlclnom       #Nome do local
     ,cctdptnom        like ctgkdpt.cctdptnom       #Nome do dep.(antigo cctnom)
     ,cctdptrspnom     like ctgrlcldpt.cctdptrspnom #Responsavel pelo departamento
     ,cctdptlclsit     like ctgrlcldpt.cctdptlclsit #Sit do dep (A)tivo,(I)nativo
     ,cctdpttip        like ctgkdpt.cctdpttip       #Tipo de departamento
   end record
   
   define l_fav record
          errcod     smallint ,
          msg        char(80)
   end record
   
   define l_ciaempcod   like datmservico.ciaempcod,      #PSI 205206
          l_ciaempcodOP like datmservico.ciaempcod,
          l_nfsnum      like dbsmopg.nfsnum
          
   define l_res smallint,
          l_msg char(70)

   let l_res = null
   let l_msg = null
   initialize ctb11m01.*   to null
   initialize ws.*         to null
   initialize lr_param.*   to null
   initialize lr_ret.*     to null
   initialize l_nfsnum, l_ciaempcod, l_ciaempcodOP to null
   initialize l_fav.* to null
   initialize m_opg.* to null
   
   #--------------------------------------------------------------------
   # Obtem dados da O.P.
   #--------------------------------------------------------------------
   select socopgnum,
          socopgsitcod,
          pstcoddig,
          corsus,
          cgccpfnum,
          cgcord,
          cgccpfdig,
          socfatentdat,
          socfatpgtdat,
          socfatitmqtd,
          socfattotvlr,
          soctrfcod,
          socfatrelqtd,
          socpgtdoctip,
          socemsnfsdat,
          empcod,
          succod,
          cctcod,
          pgtdstcod,
          socopgdscvlr,
          soctip,
          segnumdig,
          pestip,
          favtip,
          nfsnum,
          fisnotsrenum, #Fornax - Quantum
          infissalqvlr                         # PSI-11-19199PR
     into ctb11m01.socopgnum,
          ctb11m01.socopgsitcod,
          m_opg.pstcoddig,
          ctb11m01.corsus,
          ctb11m01.opgcgccpfnum,
          ctb11m01.opgcgcord,
          ctb11m01.opgcgccpfdig,
          ctb11m01.socfatentdat,
          ctb11m01.socfatpgtdat,
          ctb11m01.socfatitmqtd,
          ctb11m01.socfattotvlr,
          ctb11m01.soctrfcod,
          ctb11m01.socfatrelqtd,
          ctb11m01.socpgtdoctip,
          ctb11m01.socemsnfsdat,
          ctb11m01.empcod,
          ctb11m01.succod,
          ctb11m01.cctcod,
          ctb11m01.pgtdstcod,
          ctb11m01.socopgdscvlr,
          m_opg.soctip,
          ctb11m01.segnumdig,
          m_opg.pestip,
          ctb11m01.favtip,
          ctb11m01.nfsnum,
          ctb11m01.fisnotsrenum,  #Fornax - Quantum
          ctb11m01.infissalqvlr                # PSI-11-19199PR
     from dbsmopg
    where socopgnum = k_ctb11m01.socopgnum

   if sqlca.sqlcode = notfound   then
      error " Ordem de pagamento nao cadastrada!"
      goto fim_erro
   end if

   # buscar dados do favorecido conforme tipo
   if m_opg.soctip != 1
      then
      error " Este numero de OP nao pertence ao Porto Socorro!"
      goto fim_erro
   end if
   
   call cty10g00_nome_sucursal(ctb11m01.succod)
        returning l_res, l_msg, ctb11m01.sucnom

   display by name ctb11m01.sucnom
   
   #PSI197858 - inicio
   select sum(dscvlr) into ws.desconto
   from dbsropgdsc
   where socopgnum = k_ctb11m01.socopgnum

   #   if ws.desconto <> 0 and ws.desconto is not null then
   #   	let ctb11m01.socfattotvlr = ctb11m01.socfattotvlr - ws.desconto
   #   else
   #   	if ctb11m01.socopgdscvlr is not null and ctb11m01.socopgdscvlr > 0.00 then
   #   		let ctb11m01.socfattotvlr = ctb11m01.socfattotvlr - ctb11m01.socopgdscvlr
   #   	end if
   #   end if

   if ctb11m01.socopgdscvlr is null or ctb11m01.socopgdscvlr = 0.00 
      then
      if ws.desconto is not null or ws.desconto > 0.00 
         then
         let ctb11m01.socopgdscvlr = ws.desconto
      else
       		let ctb11m01.socopgdscvlr = 0.00
      end if
   end if
   #PSI197858 - fim
   
   initialize m_dominio.* to null
   
   call cty11g00_iddkdominio('socopgsitcod', ctb11m01.socopgsitcod)
        returning m_dominio.*
        
   if m_dominio.erro = 1
      then
      let ctb11m01.socopgsitdes = m_dominio.cpodes clipped
   else
      initialize ctb11m01.socopgsitdes to null
      error "Situacao da OP: ", m_dominio.mensagem
      goto fim_erro
   end if
   
   if ctb11m01.socopgsitcod  <>  1   then   #--->  Nao analisada

      # ligia 21/08/08 psi 198404
      # if ctb11m01.cctcod is not null 
      #    then
      # 
      #    #PSI 191167
      #    let lr_param.empcod    = ctb11m01.empcod
      #    let lr_param.succod    = 01
      #    let lr_param.cctlclcod = (ctb11m01.cctcod / 10000)
      #    let lr_param.cctdptcod = (ctb11m01.cctcod mod 10000)
      #  
      #    call fctgc102_vld_dep(lr_param.*) returning lr_ret.*
      #  
      #    if lr_ret.erro <>  0  
      #    then
      #    error "Erro (",lr_ret.erro,") na leitura do centro de custo!"
      #    sleep 3
      #    error lr_ret.mens
      #    goto fim_erro
      #    end if
      # end if
      ###let ctb11m01.cctnom = lr_ret.cctdptnom
      
      if ctb11m01.pgtdstcod is not null  then
         select pgtdstdes
           into ctb11m01.pgtdstdes
           from fpgkpgtdst
          where pgtdstcod = ctb11m01.pgtdstcod

         if sqlca.sqlcode  <>  0   then
            error " Erro (",sqlca.sqlcode,") na leitura do destino!"
            goto fim_erro
         end if
      end if

      #--------------------------------------------------------------------
      # Obtem dados do favorecido
      #--------------------------------------------------------------------
      select socopgfavnom,
             socpgtopccod,
             pestip,
             cgccpfnum,
             cgcord,
             cgccpfdig,
             bcoctatip,
             bcocod,
             bcoagnnum,
             bcoagndig,
             bcoctanum,
             bcoctadig
        into ctb11m01.socopgfavnom,
             ctb11m01.socpgtopccod,
             ctb11m01.pestip,
             ctb11m01.cgccpfnum,
             ctb11m01.cgcord,
             ctb11m01.cgccpfdig,
             ctb11m01.bcoctatip,
             ctb11m01.bcocod,
             ctb11m01.bcoagnnum,
             ctb11m01.bcoagndig,
             ctb11m01.bcoctanum,
             ctb11m01.bcoctadig
        from dbsmopgfav
       where socopgnum  =  k_ctb11m01.socopgnum

       if ctb11m01.socopgsitcod  <>  8   and    #--->  Cancelada
          sqlca.sqlcode          <>  0   then
          error " Erro (",sqlca.sqlcode,") na leitura do favorecido!"
          goto fim_erro
       end if

      #--------------------------------------------------------------------
      # Descricao da opcao de pagamento
      #--------------------------------------------------------------------
      if ctb11m01.socpgtopccod is not null and
         ctb11m01.socpgtopccod > 0
         then
         initialize m_dominio.* to null
         
         call cty11g00_iddkdominio('socpgtopccod', ctb11m01.socpgtopccod)
              returning m_dominio.*
              
         if m_dominio.erro = 1
            then
            let ctb11m01.socpgtopcdes = m_dominio.cpodes clipped
         else
            initialize ctb11m01.socpgtopcdes to null
            error "Opção de pagamento: ", m_dominio.mensagem
            goto fim_erro
         end if
      end if
      
      if ctb11m01.socpgtopccod  is not null  and
         ctb11m01.socpgtopccod  <>  2        then  #--> Opcao pagto cheque

         case ctb11m01.bcoctatip
            when 1  let ctb11m01.bcoctatipdes = "C.CORRENTE"
            when 2  let ctb11m01.bcoctatipdes = "POUPANCA"
         end case

         select bcosgl
           into ctb11m01.bcosgl
           from gcdkbanco
          where gcdkbanco.bcocod = ctb11m01.bcocod

         if sqlca.sqlcode  <>  0   then
            error " Erro (",sqlca.sqlcode,") na leitura do nome do banco!"
            goto fim_erro
         end if

         let ws.bcoagnnum = ctb11m01.bcoagnnum

         select bcoagnnom
           into ctb11m01.bcoagnnom
           from gcdkbancoage
          where gcdkbancoage.bcocod    = ctb11m01.bcocod     and
                gcdkbancoage.bcoagnnum = ws.bcoagnnum

         if sqlca.sqlcode  <>  0     and
            sqlca.sqlcode  <>  100   then
            error " Erro (",sqlca.sqlcode,") na leitura do nome da agencia!"
            goto fim_erro
         end if
      end if
   else
      # fase 'Nao analisada' ainda nao possui favorecido, sugerir valores da OP
      let ctb11m01.cgccpfnum = ctb11m01.opgcgccpfnum
      let ctb11m01.cgcord    = ctb11m01.opgcgcord
      let ctb11m01.cgccpfdig = ctb11m01.opgcgccpfdig
      let ctb11m01.pestip    = m_opg.pestip
   end if

   select empcod, succod, prstip
     into ctb11m01.trbempcod,
          ctb11m01.trbsuccod,
          ctb11m01.trbprstip
     from dbsmopgtrb
    where socopgnum = k_ctb11m01.socopgnum

   #PSI 205206
   #verificar qual a empresa dos itens da OP - caso exista
   declare cctb11m01001 cursor for
      select b.ciaempcod, a.nfsnum
         from dbsmopgitm a, outer datmservico b
         where a.socopgnum = k_ctb11m01.socopgnum
           and a.atdsrvnum = b.atdsrvnum
           and a.atdsrvano = b.atdsrvano
           
   foreach cctb11m01001 into l_ciaempcod, l_nfsnum
   
       #se empresa da OP é nula
       if l_ciaempcodOP is null  # primeiro servico
          then
          let ctb11m01.ciaempcod = l_ciaempcod
          
          #empresa da OP recebe empresa do item
          let l_ciaempcodOP = l_ciaempcod
          
          #busca descricao da empresa
          # call cty14g00_empresa(1, l_ciaempcodOP)
          #      returning lr_ret.erro,
          #                lr_ret.mens,
          #                ctb11m01.empresa
       else
          #verificar se empresa da OP e empresa do item são iguais
          if l_ciaempcodOP <> l_ciaempcod then
             error "Itens da OP com empresas diferentes!"
          end if
       end if
   end foreach
   
   # atribuir numero da NFS do item
   if ctb11m01.nfsnum is null and l_nfsnum is not null
      then
      let ctb11m01.nfsnum = l_nfsnum
   end if
   
   # empresa nao gravada na OP ou gravada errada na OP automatica, corrige no modifica
   if (ctb11m01.empcod is null and l_ciaempcod is not null) or
      (ctb11m01.empcod != l_ciaempcodOP)
      then
      let ctb11m01.empcod = l_ciaempcodOP
   end if
   
   # obter dados do favorecido com CPF/CNPJ gravado na tab favorecido
   call ctb00g01_dados_favtip(7, m_opg.pstcoddig, ctb11m01.segnumdig,
                              '', '', ctb11m01.corsus,
                              ctb11m01.empcod,
                              ctb11m01.cgccpfnum,
                              ctb11m01.cgcord,
                              ctb11m01.cgccpfdig,
                              ctb11m01.favtip)
                    returning l_fav.errcod, 
                              l_fav.msg, 
                              ctb11m01.favtip,
                              ctb11m01.favtipcod,
                              ctb11m01.favtipcab,
                              ctb11m01.favtipnom,
                              ctb11m01.simoptpstflg     # PSI-11-19199PR
   
   if l_fav.errcod != 0 
      then
      error l_fav.msg
      sleep 1
      goto fim_erro
   end if
   
   # sugerir nome do CPF da OP no favorecido antes da analise
   if ctb11m01.socopgsitcod = 1  #  Nao analisada
      then
      let ctb11m01.socopgfavnom = ctb11m01.favtipnom
   end if
   
   #   case ctb11m01.socpgtdsctip
   #      when 1  let ctb11m01.socpgtdscdes = "AVARIAS"
   #      when 2  let ctb11m01.socpgtdscdes = "EMPRESTIMO"
   #      when 5  let ctb11m01.socpgtdscdes = "DESCONTO"
   #      when 6  let ctb11m01.socpgtdscdes = "ADIANTAMENTOS"
   #      when 7  let ctb11m01.socpgtdscdes = "COMERCIAL"
   #      when 8  let ctb11m01.socpgtdscdes = "FINANCIAMENTOS"
   #      when 9  let ctb11m01.socpgtdscdes = "OUTROS"
   #   end case
   
   if ctb11m01.socpgtdoctip is not null and
      ctb11m01.socpgtdoctip > 0
      then
      initialize m_dominio.* to null
      
      call cty11g00_iddkdominio('socpgtdoctip', ctb11m01.socpgtdoctip)
           returning m_dominio.*
           
      if m_dominio.erro = 1
         then
         let ctb11m01.socpgtdocdes = m_dominio.cpodes clipped
      else
         initialize ctb11m01.socpgtdocdes to null
         error "Tipo documento fiscal: ", m_dominio.mensagem
      end if
   end if
   
   # busca descricao da empresa, se nao houver itens mostra N/D
   call cty14g00_empresa_abv(ctb11m01.empcod)
        returning lr_ret.erro, lr_ret.mens, ctb11m01.empresa
        
   return ctb11m01.*
   
   #--------------------------------------------------------------------
   label fim_erro :
   #--------------------------------------------------------------------
   sleep 4
   initialize ctb11m01.*    to null
   initialize k_ctb11m01.*  to null
   return ctb11m01.*

end function  ###  ler_ctb11m01
