#############################################################################
# Nome do Modulo: CTB04M01                                         Wagner   #
#                                                                           #
# Ordem de pagamento - Ramos Elementares                           Nov/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#...........................................................................#
#                                                                           #
#                * * * * Alteracoes * * * *                                 #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            # 
# ----------  -------------- --------- ------------------------------       #
# 06/10/2004  Mariana,Meta   PSI187801 Expandir dominio do campo            #
#                                      socpgtdsctip(5-Desconto,             #
#                                                   6-Adiantamentos,        #
#                                                   7-Comercial,            #
#                                                   8-Financiamentos,       #
#                                                   9-Outros)               #
# 12/04/2005  Helio (Meta)  PSI 191167 Unificacao do acesso as tabelas de   #
#                                      centro de custos                     #
# 18/07/2006 Cristiane Silva PSI197858 Chamada de tela de Descontos via menu#
#                                      e retirada do tipo e valor de des-   #
#                                      conto da tela.			                  #
#---------------------------------------------------------------------------#
# 12/12/2006 Priscila Staingel PSI205206 Exibir se a OP é da Azul ou Porto  #
#                                        sendo q todos os itens da OP devem #
#                                        ser da mesma empresa               #
#---------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel  #
#---------------------------------------------------------------------------#
# 27/05/2008  Chamado: 80511944         Implementado regra de bloqueio de   #
#             Andre Oliveira            cancelamento apos data de Pagamento #
# 24/06/2008  PSI 198404 Ligia Mattge   Retirado o Centro de custo incluido #
#                                       a sucursal                          #
# 26/01/2009             Raji           Tratativa NFE                       #
# 09/02/2009  PSI 236292  Fabio Costa   Mostrar QRAs ligados a OP na pop-up #
# 27/05/2009  PSI 198404  Fabio Costa   Impedir edicao de OP com status 10 e#
#                                       11, digitar NF e gravar nos itens,  #
#                                       cancelamento de OP People, retirar  #
#                                       tributacao Informix                 #
# 29/07/2009  PSI 198404  Fabio Costa   Permitir digitacao de sucursal para #
#                                       OP de reembolso                     #
# 08/02/2010  PSI198404  Fabio Costa  Validacoes do relatorio bdbsr116 na OP#
#                                     Azul antes de status "Ok para emissao"#
# 26/04/2010  PSI198404  Fabio Costa  Tratar reembolso segurado Azul, tipo  #
#                                     favorecido, NFS na OP, verific. NFS   #
# 01/06/2010             Robert Allan Implementação da opção de Envio OP    #
# 14/10/2010  PGP_2010_00274 Robert lima Foi tratado o problema de inserção #
#                                       de mais de duas casas decimais.     #
# 28/05/2012  PSI-11-19199PR Jose Kurihara Incluir campo Optante Simples e  #
#                                          aliquota do ISS                  #
#                                          registrar mudanca ISS historico  #
# 22/01/2016  Solicitacao Eliane K. Fx Incluir matricula 12644 - Lincoln    #
#                                      para Atualizar Status 7              #
#---------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

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
function ctb04m01()
#------------------------------------------------------------

 define ctb04m01     record
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

 define k_ctb04m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

 define l_pstcoddig like dbsmopg.pstcoddig
 define l_qldgracod like dpaksocor.qldgracod  
 define l_flag      char(1)

#WWWX if not get_niv_mod(g_issk.prgsgl, "ctb04m01") then
#WWWX    error " Modulo sem nivel de consulta e atualizacao!"
#WWWX    return
#WWWX end if

 let int_flag = false  
 let l_flag = 'N'

 initialize ctb04m01.*   to  null
 initialize k_ctb04m01.* to  null
 initialize m_opg.* to null
 
 open window ctb04m01 at 04,02 with form "ctb04m01"

 menu "O.P."

    before menu
       hide option all
#WWWX  if g_issk.acsnivcod >= g_issk.acsnivcns  then          # NIVEL 1
#WWWX     show option "Seleciona", "Proximo", "Anterior", "Fases"
#WWWX  end if
#WWWX  if g_issk.acsnivcod  =  3   then                       # NIVEL 3
#WWWX     show option "Seleciona", "Proximo", "Anterior",
#WWWX                 "Itens", "Fases"
#WWWX  end if
#WWWX  if g_issk.acsnivcod >=  5   then                       # NIVEL 5
          show option "Seleciona", "Proximo", "Anterior", "Modifica",
                      "Itens", "Descontos", "Fases", "Obs", "Totais",
                      "coNtribuinte", "contaBil", "enVia OP"
#WWWX  end if
       if g_issk.acsnivcod  =  8   then                       # NIVEL 8
          show option "Cancela"
          
          if g_issk.funmat = 6299 then
             show option "AtualizaStt7"
             
             show option "CancelaOP"
          end if
         
       end if

       if g_issk.funmat = 12644 then
	      show option "AtualizaStt7"
       end if

       show option "Encerra"

   command key ("S") "Seleciona"
                     "Pesquisa ordem de pagamento conforme criterios"
       call seleciona_ctb04m01() returning k_ctb04m01.*, ctb04m01.*
       if k_ctb04m01.socopgnum is not null  then
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
       if k_ctb04m01.socopgnum is not null then
          call proximo_ctb04m01(k_ctb04m01.*)
               returning k_ctb04m01.*, ctb04m01.*
       else
          error " Nenhuma ordem de pagamento nesta direcao!"
          next option "Seleciona"
       end if

   command key ("A") "Anterior"
                     "Mostra ordem de pagamento anterior"
       message ""
       if k_ctb04m01.socopgnum is not null then
          call anterior_ctb04m01(k_ctb04m01.*)
               returning k_ctb04m01.*, ctb04m01.*
       else
          error " Nenhuma ordem de pagamento nesta direcao!"
          next option "Seleciona"
       end if

   command key ("M") "Modifica"
                     "Modifica ordem de pagamento selecionada"
       message ""
       if k_ctb04m01.socopgnum is not null
          then
          case ctb04m01.socopgsitcod
             when 7
                error " Ordem de pagamento emitida nao deve ser alterada!" 
             when 8
                error " Ordem de pagamento cancelada nao deve ser alterada!"
             when 10
                error " Ordem de pagamento nao deve ser alterada, aguardando emissão PEOPLE!"
             when 11
                error " Ordem de pagamento nao deve ser alterada, aguardando cancelamento PEOPLE! "
             otherwise
                call modifica_ctb04m01(k_ctb04m01.*, ctb04m01.*)
                     returning k_ctb04m01.*
                initialize ctb04m01.*     to null
                initialize k_ctb04m01.*   to null
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
       if k_ctb04m01.socopgnum is not null then
          if ctb04m01.socopgsitcod  >  1 then
             if ctb04m01.socopgsitcod <>  7  and
                ctb04m01.socopgsitcod <>  8  and
                ctb04m01.socopgsitcod <>  10
                then
                if dias_uteis(ctb04m01.socfatpgtdat, 0, "", "S", "S") = ctb04m01.socfatpgtdat 
                   then
                else
                   if ctb04m01.socfatpgtdat  <>  "18/10/1999"   
                      then
                      error " Pagamento nao deve ser programado para FERIADO!"
                      initialize ctb04m01.*     to null
                      initialize k_ctb04m01.*   to null
                      next option "Seleciona"
                   end if
                end if
                
                if dias_entre_datas(today, ctb04m01.socfatpgtdat, "", "S", "S") <= 4 
                   then
                   error " Pagamento deve ser programado c/ 4 DIAS DE ANTECEDENCIA!"
                   initialize ctb04m01.*     to null
                   initialize k_ctb04m01.*   to null
                   next option "Seleciona"
                else
                   clear form
                   call ctb04m06(k_ctb04m01.*)        #-> Manutencao itens
                   initialize ctb04m01.*     to null
                   initialize k_ctb04m01.*   to null
                   next option "Seleciona"
                end if
             else
                call ctb04m10(k_ctb04m01.*,"")         #-> Consulta itens
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
       
       if k_ctb04m01.socopgnum is not null then
          call ctc81m00(k_ctb04m01.*)
          next option "Seleciona"
       else
          error "Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if
   #PSI197858 - fim

   command key ("O") "Obs"
                    "Observacoes da ordem de pagamento selecionada"
       message ""
       if k_ctb04m01.socopgnum is not null then
          call ctb11m03(k_ctb04m01.*)
          next option "Seleciona"
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("F") "Fases"
                     "Fases da ordem de pagamento selecionada"
       message ""
       if k_ctb04m01.socopgnum is not null then
          call ctb11m02(k_ctb04m01.*)
          next option "Seleciona"
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("T") "Totais"
                     "Totaliza itens da ordem de pagamento selecionada por tipo de servico"
       message ""

       if k_ctb04m01.socopgnum is not null then
          if ctb04m01.socopgsitcod  =  7  or
             ctb04m01.socopgsitcod  =  8  then
             #Remover critica que bloqueia a consulta de OP com data de pagamento inferior a 60 dias:

             #if ctb04m01.socfatpgtdat  <  today - 60 units day   and
             #   g_issk.funmat <> 7574 then
             #   error " Consulta nao disponivel para O.P. emitida a mais de 60 dias"
             #   next option "Seleciona"
             #else
                call ctb04m11(k_ctb04m01.*)
                next option "Seleciona"
             #end if
          else
             call ctb04m11(k_ctb04m01.*)
             next option "Seleciona"
          end if
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("B") "contaBil"
                     "Contabilizacao da ordem de pagamento selecionada"
       message ""
       if k_ctb04m01.socopgnum is not null then
          if ctb04m01.socfatpgtdat  >  "04/01/1998"   then
             if ctb04m01.socopgsitcod  =  7   then
                call ctb11m14(k_ctb04m01.*)
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
       # if k_ctb04m01.socopgnum is not null then
       #   call ctb11m12("C",
       #                  ctb04m01.opgcgccpfnum,
       #                  ctb04m01.opgcgcord,
       #                  ctb04m01.trbempcod,
       #                  ctb04m01.trbsuccod,
       #                  ctb04m01.trbprstip)
       #        returning ctb04m01.opgcgccpfnum,
       #                  ctb04m01.opgcgcord,
       #                  ctb04m01.trbempcod,
       #                  ctb04m01.trbsuccod,
       #                  ctb04m01.trbprstip
       #    next option "Seleciona"
       # else
       #    error " Nenhuma ordem de pagamento selecionada!"
       #    next option "Seleciona"
       # end if
       
   command key ("C") "Cancela"
                     "Cancela ordem de pagamento selecionada"
       message ""
       if k_ctb04m01.socopgnum is not null then
          if ctb04m01.socopgsitcod  <>  8  then
             call cancela_ctb04m01(k_ctb04m01.*)
                  returning k_ctb04m01.*
             next option "Seleciona"
          else
             error " Ordem de pagamento ja' cancelada!"
          end if
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if
   ################[Alterado Robert]#
     command key ("V") "enVia OP" "Envia OP para Prestador"
      message ""
      if k_ctb04m01.socopgnum is not null then
        
         whenever error continue
           
            select pstcoddig into l_pstcoddig
            from dbsmopg
            where socopgnum = k_ctb04m01.socopgnum
   
            select qldgracod into l_qldgracod
            from dpaksocor      
            where pstcoddig = l_pstcoddig	    
            
         whenever error stop
         
         if l_qldgracod <> 1 then
            call ctb11m17(k_ctb04m01.socopgnum,l_pstcoddig,'E','O')
         else
            error " Nao e possivel enviar a OP!"
            next option "Seleciona"
         end if
      else
         error " Nenhuma ordem de pagamento selecionada!"
         next option "Seleciona"
      end if
   #################################  
   
  command key ("Z") "AtualizaStt7"
                    "Atualiza status das OPs para 7"
         
       if k_ctb04m01.socopgnum is not null then  
                    
          select 1
           from dbsmopg
          where socopgnum = k_ctb04m01.socopgnum
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
              where socopgnum = k_ctb04m01.socopgnum  
               
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
                  where socopgnum = k_ctb04m01.socopgnum
                  
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
   
      if k_ctb04m01.socopgnum is not null then
         
         let l_flag = null
         let l_flag = cts08g01("A","S","O NUMERO DA OP ESTA CORRETO?",
                                    '',"APOS A CONFIRMACAO NAO SERA POSSIVEL REVERTER",'')
         if l_flag = 'S' then  
                       
              update dbsmopg                        
                 set socopgsitcod = 8              
                    ,trbpgtordpcmflg = 'N'         
                    ,trbnaopgtordpcmflg = 'N'       
               where socopgnum = k_ctb04m01.socopgnum 
               
               if sqlca.sqlcode = 0 then
                  error "OP Cancelada"
               
                   update datmservico 
                      set pgtdat = null, 
                          atdcstvlr = null
                    where atdsrvnum in (
                          (select atdsrvnum from dbsmopgitm where socopgnum = k_ctb04m01.socopgnum))
                      and atdsrvano in (
                          (select atdsrvano from dbsmopgitm where socopgnum = k_ctb04m01.socopgnum))
                    
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

 close window ctb04m01

end function  ###  ctb04m01

#------------------------------------------------------------
function seleciona_ctb04m01()
#------------------------------------------------------------

 define ctb04m01     record
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

 define k_ctb04m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

   clear form
   let int_flag = false
   initialize  ctb04m01.*  to null

   input by name k_ctb04m01.socopgnum

      before field socopgnum
          display by name k_ctb04m01.socopgnum attribute (reverse)

          if k_ctb04m01.socopgnum is null then
             let k_ctb04m01.socopgnum = 0
          end if

      after  field socopgnum
          display by name k_ctb04m01.socopgnum

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctb04m01.*   to null
      initialize k_ctb04m01.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctb04m01.*, ctb04m01.*
   end if

   if k_ctb04m01.socopgnum  =  0   then
      select min (socopgnum)
        into k_ctb04m01.socopgnum
        from dbsmopg
       where socopgnum > k_ctb04m01.socopgnum
         and soctip    = 3

      display by name k_ctb04m01.socopgnum
   end if

   call ler_ctb04m01(k_ctb04m01.*)  returning  ctb04m01.*
   #PSI197858 - inicio
   if ctb04m01.socopgnum  is not null    then
      display by name ctb04m01.socopgnum   ,
                      ctb04m01.socopgsitcod,
                      ctb04m01.socopgsitdes,
                      ctb04m01.favtipcab   ,
                      ctb04m01.favtipcod   ,
                      ctb04m01.favtipnom   ,
                      ctb04m01.socfatentdat,
                      ctb04m01.socfatpgtdat,
                      ctb04m01.socfatrelqtd,
                      ctb04m01.socfatitmqtd,
                      ctb04m01.socfattotvlr,
                      ctb04m01.soctrfcod   ,
                      ctb04m01.socpgtdoctip,
                      ctb04m01.socpgtdocdes,
                      ctb04m01.succod      ,
                      ctb04m01.sucnom      ,
                      ctb04m01.socemsnfsdat,
                      ctb04m01.socpgtopccod,
                      ctb04m01.socpgtopcdes,
                      ctb04m01.pgtdstcod   ,
                      ctb04m01.pgtdstdes   ,
                      ctb04m01.socopgfavnom,
                      ctb04m01.pestip      ,
                      ctb04m01.cgccpfnum   ,
                      ctb04m01.cgcord      ,
                      ctb04m01.cgccpfdig   ,
                      ctb04m01.bcoctatip   ,
                      ctb04m01.bcoctatipdes,
                      ctb04m01.bcocod      ,
                      ctb04m01.bcosgl      ,
                      ctb04m01.bcoagnnum   ,
                      ctb04m01.bcoagndig   ,
                      ctb04m01.bcoagnnom   ,
                      ctb04m01.bcoctanum   ,
                      ctb04m01.bcoctadig   ,
                      ctb04m01.socopgdscvlr,
                      ctb04m01.nfsnum      ,
                      ctb04m01.fisnotsrenum,  #Fornax - Quantum
                      ctb04m01.infissalqvlr,          # PSI-11-19199PR
                      ctb04m01.simoptpstflg

      display by name ctb04m01.empresa attribute (reverse)      #PSI 205206
   else
      error " Ordem de pagamento nao cadastrada!"
      initialize ctb04m01.*    to null
      initialize k_ctb04m01.*  to null
   end if
   #PSI197858 - fim
   return k_ctb04m01.*, ctb04m01.*

end function  ###  seleciona_ctb04m01

#------------------------------------------------------------
function proximo_ctb04m01(k_ctb04m01)
#------------------------------------------------------------

 define ctb04m01     record
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

 define k_ctb04m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

   initialize ctb04m01.*   to null

   select min (socopgnum)
     into ctb04m01.socopgnum
     from dbsmopg
    where socopgnum > k_ctb04m01.socopgnum
      and soctip    = 3

   if ctb04m01.socopgnum  is not null   then
      let k_ctb04m01.socopgnum = ctb04m01.socopgnum
      call ler_ctb04m01(k_ctb04m01.*)  returning  ctb04m01.*
      if ctb04m01.socopgnum  is not null    then
         display by name ctb04m01.socopgnum   ,
                      ctb04m01.socopgsitcod,
                      ctb04m01.socopgsitdes,
                      ctb04m01.favtipcab   ,
                      ctb04m01.favtipcod   ,
                      ctb04m01.favtipnom   ,
                      ctb04m01.socfatentdat,
                      ctb04m01.socfatpgtdat,
                      ctb04m01.socfatrelqtd,
                      ctb04m01.socfatitmqtd,
                      ctb04m01.socfattotvlr,
                      ctb04m01.soctrfcod   ,
                      ctb04m01.socpgtdoctip,
                      ctb04m01.socpgtdocdes,
                      ctb04m01.succod      ,
                      ctb04m01.sucnom      ,
                      ctb04m01.socemsnfsdat,
                      ctb04m01.socpgtopccod,
                      ctb04m01.socpgtopcdes,
                      ctb04m01.pgtdstcod   ,
                      ctb04m01.pgtdstdes   ,
                      ctb04m01.socopgfavnom,
                      ctb04m01.pestip      ,
                      ctb04m01.cgccpfnum   ,
                      ctb04m01.cgcord      ,
                      ctb04m01.cgccpfdig   ,
                      ctb04m01.bcoctatip   ,
                      ctb04m01.bcoctatipdes,
                      ctb04m01.bcocod      ,
                      ctb04m01.bcosgl      ,
                      ctb04m01.bcoagnnum   ,
                      ctb04m01.bcoagndig   ,
                      ctb04m01.bcoagnnom   ,
                      ctb04m01.bcoctanum   ,
                      ctb04m01.bcoctadig   ,
                      ctb04m01.socopgdscvlr,
                      ctb04m01.nfsnum      ,
                      ctb04m01.fisnotsrenum,  #Fornax - Quantum
                      ctb04m01.infissalqvlr,         # PSI-11-19199PR
                      ctb04m01.simoptpstflg
                      
      	display by name ctb04m01.empresa attribute (reverse)      #PSI 205206
      else
         error " Nao ha' ordem de pagamento nesta direcao!"
         initialize ctb04m01.*    to null
         initialize k_ctb04m01.*  to null
      end if
   else
      error " Nao ha' ordem de pagamento nesta direcao!"
      initialize ctb04m01.*    to null
      initialize k_ctb04m01.*  to null
   end if
   return k_ctb04m01.*, ctb04m01.*

end function  ###  proximo_ctb04m01

#------------------------------------------------------------
function anterior_ctb04m01(k_ctb04m01)
#------------------------------------------------------------

 define ctb04m01     record
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

 define k_ctb04m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

   let int_flag = false
   initialize ctb04m01.*  to null

   select max (socopgnum)
     into ctb04m01.socopgnum
     from dbsmopg
    where socopgnum < k_ctb04m01.socopgnum
      and soctip    = 3

   if ctb04m01.socopgnum  is  not  null  then
      let k_ctb04m01.socopgnum = ctb04m01.socopgnum
      call ler_ctb04m01(k_ctb04m01.*)  returning  ctb04m01.*
      if ctb04m01.socopgnum  is not null    then
         display by name ctb04m01.socopgnum   ,
                      ctb04m01.socopgsitcod,
                      ctb04m01.socopgsitdes,
                      ctb04m01.favtipcab   ,
                      ctb04m01.favtipcod   ,
                      ctb04m01.favtipnom   ,
                      ctb04m01.socfatentdat,
                      ctb04m01.socfatpgtdat,
                      ctb04m01.socfatrelqtd,
                      ctb04m01.socfatitmqtd,
                      ctb04m01.socfattotvlr,
                      ctb04m01.soctrfcod   ,
                      ctb04m01.socpgtdoctip,
                      ctb04m01.socpgtdocdes,
                      ctb04m01.succod      ,
                      ctb04m01.sucnom      ,
                      ctb04m01.socemsnfsdat,
                      ctb04m01.socpgtopccod,
                      ctb04m01.socpgtopcdes,
                      ctb04m01.pgtdstcod   ,
                      ctb04m01.pgtdstdes   ,
                      ctb04m01.socopgfavnom,
                      ctb04m01.pestip      ,
                      ctb04m01.cgccpfnum   ,
                      ctb04m01.cgcord      ,
                      ctb04m01.cgccpfdig   ,
                      ctb04m01.bcoctatip   ,
                      ctb04m01.bcoctatipdes,
                      ctb04m01.bcocod      ,
                      ctb04m01.bcosgl      ,
                      ctb04m01.bcoagnnum   ,
                      ctb04m01.bcoagndig   ,
                      ctb04m01.bcoagnnom   ,
                      ctb04m01.bcoctanum   ,
                      ctb04m01.bcoctadig   ,
                      ctb04m01.socopgdscvlr,
                      ctb04m01.nfsnum      ,
                      ctb04m01.fisnotsrenum,  #Fornax - Quantum
                      ctb04m01.infissalqvlr,         # PSI-11-19199PR
                      ctb04m01.simoptpstflg
                      
         display by name ctb04m01.empresa attribute (reverse)      #PSI 205206
      else
         error " Nao ha' ordem de pagamento nesta direcao!"
         initialize ctb04m01.*    to null
         initialize k_ctb04m01.*  to null
      end if
   else
      error " Nao ha' ordem de pagamento nesta direcao!"
      initialize ctb04m01.*    to null
      initialize k_ctb04m01.*  to null
   end if
   return k_ctb04m01.*, ctb04m01.*

end function  ###  anterior_ctb04m01

#------------------------------------------------------------
function modifica_ctb04m01(k_ctb04m01, ctb04m01)
#------------------------------------------------------------

 define ctb04m01     record
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

 define k_ctb04m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

 define ws           record
    achfavflg        char (01),
    achtrbflg        char (01),
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
 end record

 define lr_retorno record
     retorno   smallint,
     mensagem  char(80)
 end record
 
 define l_sqlca   integer , 
        l_sqlerr  integer ,
        l_historico char(300),
        l_codaux    smallint
        
   let l_historico     = null
   let l_codaux        = null
   let ws.infissalqvlr = ctb04m01.infissalqvlr          # PSI-11-19199PR

   call input_ctb04m01("a", k_ctb04m01.* , ctb04m01.*) returning ctb04m01.*

   if int_flag  then
      let int_flag = false
      initialize k_ctb04m01.*  to null
      initialize ctb04m01.*    to null
      error " Operacao cancelada!"
      clear form
      return k_ctb04m01.*
   end if

   let ws.achfavflg = "N"
   let ws.achtrbflg = "N"

   select socopgnum from dbsmopgfav
    where socopgnum = k_ctb04m01.socopgnum

   if sqlca.sqlcode = 0  then
      let ws.achfavflg = "S"
   end if

   select socopgnum from dbsmopgtrb
    where socopgnum = k_ctb04m01.socopgnum

   if sqlca.sqlcode = 0  then
      let ws.achtrbflg = "S"
   end if

   if ws.achfavflg = "N"  then
      let ctb04m01.socopgsitcod = 2
   end if

   whenever error continue

   begin work
   
      # empcod retirado do update, empresa da OP deve ser definida no protocolo
      # ou na geracao automatica
      let ctb04m01.socfattotvlr = ctb04m01.socfattotvlr using "&&&&&&&&&&&&&&&.&&"
      update dbsmopg  set (empcod,
                           succod,
                           cctcod,
                           socemsnfsdat,
                           socfatpgtdat,
                           socfatitmqtd,
                           socfattotvlr,
                           socpgtdoctip,
                           pgtdstcod,
                           socopgsitcod,
                           atldat,
                           funmat,
                           nfsnum,
			   fisnotsrenum,  #Fornax - Quantum
                           favtip,
                           infissalqvlr)             # PSI-11-19199PR
                       =  (ctb04m01.empcod,
                           ctb04m01.succod,
                           12246,            # ctb04m01.cctcod,
                           ctb04m01.socemsnfsdat,
                           ctb04m01.socfatpgtdat,
                           ctb04m01.socfatitmqtd,
                           ctb04m01.socfattotvlr,
                           ctb04m01.socpgtdoctip,
                           ctb04m01.pgtdstcod,
                           ctb04m01.socopgsitcod,
                           today,
                           g_issk.funmat,
                           ctb04m01.nfsnum,
                           ctb04m01.fisnotsrenum,  #Fornax - Quantum
                           ctb04m01.favtip,
                           ctb04m01.infissalqvlr)   # PSI-11-19199PR
      where dbsmopg.socopgnum  =  k_ctb04m01.socopgnum

      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteracao da ordem de pagamento!"
         rollback work
         initialize ctb04m01.*   to null
         initialize k_ctb04m01.* to null
         return k_ctb04m01.*
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
                             =  (ctb04m01.socopgfavnom,
                                 ctb04m01.socpgtopccod,
                                 ctb04m01.pestip,
                                 ctb04m01.cgccpfnum,
                                 ctb04m01.cgcord,
                                 ctb04m01.cgccpfdig,
                                 ctb04m01.bcoctatip,
                                 ctb04m01.bcocod,
                                 ctb04m01.bcoagnnum,
                                 ctb04m01.bcoagndig,
                                 ctb04m01.bcoctanum,
                                 ctb04m01.bcoctadig)
            where dbsmopgfav.socopgnum  =  k_ctb04m01.socopgnum

         if sqlca.sqlcode <>  0  then
            error " Erro (",sqlca.sqlcode,") na alteracao do favorecido!"
            rollback work
            initialize ctb04m01.*   to null
            initialize k_ctb04m01.* to null
            return k_ctb04m01.*
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
                        values  (ctb04m01.socopgnum,
                                 ctb04m01.socopgfavnom,
                                 ctb04m01.socpgtopccod,
                                 ctb04m01.pestip,
                                 ctb04m01.cgccpfnum,
                                 ctb04m01.cgcord,
                                 ctb04m01.cgccpfdig,
                                 ctb04m01.bcoctatip,
                                 ctb04m01.bcocod,
                                 ctb04m01.bcoagnnum,
                                 ctb04m01.bcoagndig,
                                 ctb04m01.bcoctanum,
                                 ctb04m01.bcoctadig)

         if sqlca.sqlcode <>  0  then
            error " Erro (",sqlca.sqlcode,") na inclusao do favorecido!"
            rollback work
            initialize ctb04m01.*   to null
            initialize k_ctb04m01.* to null
            return k_ctb04m01.*
         end if

         # PSI 221074 - BURINI
         call cts50g00_insere_etapa(ctb04m01.socopgnum, 2, g_issk.funmat)
              returning lr_retorno.retorno , lr_retorno.mensagem

         if lr_retorno.retorno <>  1   then
            error lr_retorno.mensagem
            rollback work
            initialize ctb04m01.*   to null
            initialize k_ctb04m01.* to null
            return k_ctb04m01.*
         end if
      end if

      if ws.achtrbflg = "S"  then
         if ctb04m01.opgcgccpfnum is null  or
            ctb04m01.trbempcod    is null  or
            ctb04m01.trbsuccod    is null  or
            ctb04m01.trbprstip    is null  then
            # delete from dbsmopgtrb
            # where socopgnum = k_ctb04m01.socopgnum
         else
            update dbsmopgtrb set (empcod,
                                   succod,
                                   prstip)
                                = (ctb04m01.trbempcod,
                                   ctb04m01.trbsuccod,
                                   ctb04m01.trbprstip)
             where dbsmopgtrb.socopgnum = k_ctb04m01.socopgnum
         end if

         if sqlca.sqlcode <>  0   then
            error " Erro (",sqlca.sqlcode,") na alteracao do contribuinte!"
            rollback work
            initialize ctb04m01.*   to null
            initialize k_ctb04m01.* to null
            return k_ctb04m01.*
         end if
      else
         if ctb04m01.opgcgccpfnum is not null  and
            ctb04m01.trbempcod    is not null  and
            ctb04m01.trbsuccod    is not null  and
            ctb04m01.trbprstip    is not null  then
            insert into dbsmopgtrb (socopgnum,
                                    empcod,
                                    succod,
                                    prstip)
                           values  (ctb04m01.socopgnum,
                                    ctb04m01.trbempcod,
                                    ctb04m01.trbsuccod,
                                    ctb04m01.trbprstip)

            if sqlca.sqlcode <>  0   then
               error " Erro (",sqlca.sqlcode,") na inclusao do contribuinte!"
               rollback work
               initialize ctb04m01.*   to null
               initialize k_ctb04m01.* to null
               return k_ctb04m01.*
            end if
         end if
      end if
      
      # update NFSNUM nos itens das OP
      if ctb04m01.nfsnum is not null and
         ctb04m01.nfsnum > 0
         then
         
         call ctd20g01_upd_nfs_opgitm(k_ctb04m01.socopgnum, 
                                      ctb04m01.socopgsitcod,
                                      ctb04m01.nfsnum)
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
                  initialize ctb04m01.*   to null
                  initialize k_ctb04m01.* to null
                  return k_ctb04m01.*
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
               call cts50g00_atualiza_etapa(k_ctb04m01.socopgnum, 3, 
                                            g_issk.funmat)
                                  returning lr_retorno.retorno,
                                            lr_retorno.mensagem
                                            
               if lr_retorno.retorno != 1
                  then
                  error lr_retorno.mensagem
                  sleep 2
                  rollback work
                  initialize ctb04m01.*   to null
                  initialize k_ctb04m01.* to null
                  return k_ctb04m01.*
               end if
            end if
            
         end if
      end if
      
      #--> ini PSI-11-19199PR Registrar historico alteracao aliquota ISS
      #
      if (ws.infissalqvlr is null and ctb04m01.infissalqvlr is not null) then
#########let l_historico = "nao gravar"     # conf. Sergio Burini
      else
         if (ws.infissalqvlr is not null and ctb04m01.infissalqvlr is null) then
            let l_historico = "Alteração aliquota ISS de ", ws.infissalqvlr using "-<<<<<<<<&.&&", " para 0.00"
         else
            if ws.infissalqvlr <> ctb04m01.infissalqvlr then
               let l_historico = "Alteração aliquota ISS de ", ws.infissalqvlr using "-<<<<<<<<&.&&", " para ", ctb04m01.infissalqvlr using "-<<<<<<<<&.&&"
            end if
         end if
      end if

      if l_historico is not null then
         call ctc00m24_logarHistoricoOrdPg( k_ctb04m01.socopgnum
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
            initialize ctb04m01.*   to null
            initialize k_ctb04m01.* to null
            return k_ctb04m01.*
         end if
      end if #--> fim PSI-11-19199PR

      error " Alteracao efetuada com sucesso!"
      sleep 1
      
   commit work
   
   call ctb11m09(ctb04m01.socopgnum, "ctb04m01",
                 m_opg.pstcoddig, ctb04m01.pestip, ctb04m01.segnumdig)
   whenever error stop
   
   return k_ctb04m01.*
   
end function  ###  modifica_ctb04m01

#--------------------------------------------------------------------
function input_ctb04m01(operacao_aux, k_ctb04m01, ctb04m01)
#--------------------------------------------------------------------

 define operacao_aux char (01)
       ,l_i    smallint
       ,l_tam  smallint

 define ctb04m01     record
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

 define k_ctb04m01   record
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
    socopgdscvlr     like dbsmopg.socopgdscvlr,
    segnumdig        like dbsmopg.segnumdig,
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
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
 
 define lr_opsap    integer #Fornax-Quantum 

 define sql_select  char (200),
        l_res       smallint  ,
        l_msg       char(80)  ,
        l_ret       char(1)   ,
        l_sql       char(200) ,
        l_vlr       char(10)  ,
        l_codaux    smallint

 let l_res = null
 let l_msg = null 
 let l_vlr = null 
 let l_codaux = null 
 let l_i = 0
 let l_tam = 0

 let int_flag = false
 initialize ws.*   to null

 # ligia psi 227498 - 21/08/08
 # if operacao_aux = "a"  then
 #    if dias_uteis(ctb04m01.socfatpgtdat, 0, "", "S", "S") = ctb04m01.socfatpgtdat  then
 #    else
 #       if ctb04m01.socfatpgtdat  <>  "18/10/1999"   then
 # 
 #          call cts08g01("A","N","","DATA DE PAGAMENTO NAO","PODE SER FERIADO!","")
 #           returning ws.confirma2
 # 
 # 
 #           let int_flag = true
 #           initialize ctb04m01.*  to null
 #           return ctb04m01.*
 #       end if
 #    end if
 # 
 #    if dias_entre_datas (today, ctb04m01.socfatpgtdat, "", "S", "S") <= 4  then
 # 
 #       call cts08g01("A", "N", "",
 #                     "PAGAMENTO DEVE SER PROGRAMADO COM",
 #                     "PELO MENOS QUATRO DIAS DE ANTECEDENCIA!","")
 #            returning ws.confirma2
 # 
 # 
 #       let int_flag = true
 #       initialize ctb04m01.*  to null
 #       return ctb04m01.*
 #    end if
 # end if

 input by name # ctb04m01.socopgnum,
               # ctb04m01.socopgsitcod,
               ctb04m01.socfatpgtdat,
               ctb04m01.socfatitmqtd,
               ctb04m01.socfattotvlr,
               ctb04m01.infissalqvlr,              # PSI-11-19199PR
               ctb04m01.socpgtdoctip,
               ctb04m01.nfsnum,
               ctb04m01.fisnotsrenum,  #Fornax - Quantum
               ctb04m01.socemsnfsdat,
               ctb04m01.succod,
               ctb04m01.socpgtopccod,
               ctb04m01.pgtdstcod,
               ctb04m01.socopgfavnom,
               ctb04m01.pestip,
               ctb04m01.cgccpfnum,
               ctb04m01.cgcord,
               ctb04m01.cgccpfdig,
               ctb04m01.bcoctatip,
               ctb04m01.bcocod,
               ctb04m01.bcoagnnum,
               ctb04m01.bcoagndig,
               ctb04m01.bcoctanum,
               ctb04m01.bcoctadig,
               ctb04m01.simoptpstflg without defaults        # PSI-11-19199PR
               #PSI197858 - inicio
               # ctb04m01.socpgtdsctip,
               # ctb04m01.socopgdscvlr   without defaults
               #PSI197858 - fim
               
    # before field socopgnum
    #        # let ctb04m01.empcod = 01    # empresa devera ser a do 1o servico
    #        
    #        # ligia 21/08/08 - psi 198404
    #        # #PSI 191167
    #        # let lr_param.empcod    = ctb04m01.empcod
    #        # let lr_param.succod    = ctb04m01.succod
    #        # let lr_param.cctlclcod = (12246 / 10000)
    #        # let lr_param.cctdptcod = (12246 mod 10000)
    #        # 
    #        # call fctgc102_vld_dep(lr_param.*) returning lr_ret.*
    #        # 
    #        # if lr_ret.erro  <>  0 
    #        #    then
    #        #    error "Erro",lr_ret.erro ," na leitura do centro de custo!"
    #        #    sleep 3
    #        #    error lr_ret.mens
    #        # end if
    #        
    #        display by name ctb04m01.socopgnum   attribute(reverse)

    # after  field socopgnum
    #        display by name ctb04m01.socopgnum

    # before field socopgsitcod
    #        display by name ctb04m01.socopgsitcod  attribute(reverse)
    
    # after  field socopgsitcod
    #        display by name ctb04m01.socopgsitcod

    before field socfatpgtdat
           display by name ctb04m01.socfatpgtdat attribute(reverse)

    after  field socfatpgtdat
           display by name ctb04m01.socfatpgtdat

           call ctb01g00(operacao_aux, 1, ctb04m01.favtipcod, 
                         ctb04m01.socfatpgtdat)
                returning l_res, l_msg

           if l_res = 2 then
              if l_msg is not null then
                 error l_msg
              end if
              next field socfatpgtdat
           end if

    before field socfatitmqtd
           display by name ctb04m01.socfatitmqtd    attribute (reverse)

    after  field socfatitmqtd
           display by name ctb04m01.socfatitmqtd

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socfatpgtdat
           end if

           if ctb04m01.socfatitmqtd   is null    or
              ctb04m01.socfatitmqtd   =  0       then
              error " Quantidade total de servicos deve ser informada!"
              next field socfatitmqtd
           end if

    before field socfattotvlr
           display by name ctb04m01.socfattotvlr    attribute (reverse)

    after  field socfattotvlr
           display by name ctb04m01.socfattotvlr

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socfatitmqtd
           end if

           if ctb04m01.socfattotvlr   is null    or
              ctb04m01.socfattotvlr   =  0       then
              error " Valor total dos servicos deve ser informado!"
              next field socfattotvlr
           end if

           if operacao_aux = "a"  then
              initialize ws.socopgdscvlr to null

              select socopgdscvlr
                into ws.socopgdscvlr
                from dbsmopg
               where socopgnum = k_ctb04m01.socopgnum

              if ws.socopgdscvlr is not null  then
                 if ws.socopgdscvlr  >=  ctb04m01.socfattotvlr   then
                    error " Valor desconto nao deve ser maior ou igual ao valor total da O.P.!"
                    next field socfattotvlr
                 end if

                 if ctb04m01.pestip   =  "F"                           and
                    ws.socopgdscvlr  >=  ctb04m01.socfattotvlr * 0.90  then
                    error " Valor desconto nao deve ser maior ou igual a 90% do valor total da O.P.!"
                    next field socfattotvlr
                 end if
              end if
           end if
           let ctb04m01.socfattotvlr = ctb04m01.socfattotvlr using "&&&&&&&&&&&&&&&.&&"

    before field infissalqvlr                           # ini PSI-11-19199PR
           if ctb04m01.simoptpstflg = "N" then
              next field socpgtdoctip
           end if 
           let ws.infissalqvlr = ctb04m01.infissalqvlr
           display by name ctb04m01.infissalqvlr attribute(reverse)

    after  field infissalqvlr
           display by name ctb04m01.infissalqvlr

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socfattotvlr
           end if

           if ctb04m01.simoptpstflg = "S" then
              if ctb04m01.infissalqvlr is null or
                 ctb04m01.infissalqvlr <= 0.0  then
                 error " Aliquota ISS obrigatorio para Optante pelo Simples!"
                 next field infissalqvlr
              else
                 let l_vlr = ctb04m01.infissalqvlr 
                 let l_tam = length(l_vlr)
                 #display 'l_tam: ', l_tam
                 for l_i = 1 to l_tam 
                 
                    #display "l_vlr[l_i]", l_i
                    if l_vlr[l_i] = '.' then
                     #  display 'entrei no if'
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
           let ws.socpgtdoctip = ctb04m01.socpgtdoctip
           display by name ctb04m01.socpgtdoctip attribute(reverse)

    after  field socpgtdoctip
           display by name ctb04m01.socpgtdoctip

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socpgtdoctip
           end if

           if ctb04m01.socpgtdoctip is null
              then
              error " Tipo de documento deve ser informado!"
              next field socpgtdoctip
           end if

           if ctb04m01.socpgtdoctip <> 1 and
              ctb04m01.socpgtdoctip <> 2 and
              ctb04m01.socpgtdoctip <> 3 and
              ctb04m01.socpgtdoctip <> 4 
              then
              error " Informe o Tipo de Docto: 1-Nota Fiscal, 2-Recibo, 3-R.P.A., 4-NF Eletrônica"
              next field socpgtdoctip
           end if
           
           if ctb04m01.socpgtdoctip is not null and
              ctb04m01.socpgtdoctip > 0
              then
              initialize m_dominio.* to null
              
              call cty11g00_iddkdominio('socpgtdoctip', ctb04m01.socpgtdoctip)
                   returning m_dominio.*
                   
              if m_dominio.erro = 1
                 then
                 let ctb04m01.socpgtdocdes = m_dominio.cpodes clipped
              else
                 initialize ctb04m01.socpgtdocdes to null
                 error "Tipo documento fiscal: ", m_dominio.mensagem
              end if
           end if
           
           display by name ctb04m01.socpgtdoctip, ctb04m01.socpgtdocdes

           if operacao_aux = "a"         and
              ctb04m01.socpgtdoctip = 1  and  # NOTA FISCAL
              ws.socpgtdoctip <> ctb04m01.socpgtdoctip
              then
              declare c_ctb04m01nfs cursor for
                 select nfsnum from dbsmopgitm
                  where socopgnum = ctb04m01.socopgnum

              open  c_ctb04m01nfs
              fetch c_ctb04m01nfs
              
              if sqlca.sqlcode = 0  then
                 let ctb04m01.socpgtdoctip = ws.socpgtdoctip
                 display by name ctb04m01.socpgtdoctip
                 error " Nao e' possivel alterar tipo de documento! Ja' existem itens digitados!"
                 next field socpgtdoctip
              end if
              close c_ctb04m01nfs
           end if
           
           # nao é preciso selecionar novamente, dados vem da funcao LER
           # initialize m_opg.pstcoddig to null
           # 
           # select pstcoddig, cgccpfnum,
           #        cgcord   , cgccpfdig,
           #        pestip   , soctip
           #   into m_opg.pstcoddig,
           #        ctb04m01.opgcgccpfnum,
           #        ctb04m01.opgcgcord,
           #        ctb04m01.opgcgccpfdig,
           #        ws.pestip,
           #        m_opg.soctip
           #   from dbsmopg
           #  where socopgnum = ctb04m01.socopgnum

           if m_opg.pstcoddig is not null  and
              m_opg.pstcoddig >  11
              then

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
                    if ctb04m01.socpgtdoctip = 2   or
                       ctb04m01.socpgtdoctip = 3   then
                       initialize ctb04m01.opgcgccpfnum thru ctb04m01.trbprstip to null
                       error " Pessoa juridica nao pode utilizar Recibo/R.P.A!"
                       next field socpgtdoctip
                    end if
                 end if
              end if
              
              # PSI 198404 People, dados nao estao mais no tributos
              # if ws.pestip    = "F"   or   ###  Pessoa FISICA
              #    (ws.prscootipcod is not null and ### COOPERATIVA TAXI
              #     ws.prscootipcod = 1 )
              #    then
              #    call ctb11m12 ("A",
              #                   ctb04m01.opgcgccpfnum,
              #                   ctb04m01.opgcgcord,
              #                   ctb04m01.trbempcod,
              #                   ctb04m01.trbsuccod,
              #                   ctb04m01.trbprstip)
              #         returning ctb04m01.opgcgccpfnum,
              #                   ctb04m01.opgcgcord,
              #                   ctb04m01.trbempcod,
              #                   ctb04m01.trbsuccod,
              #                   ctb04m01.trbprstip
              # 
              #    if ctb04m01.opgcgccpfnum is null  or
              #       ctb04m01.trbempcod    is null  or
              #       ctb04m01.trbsuccod    is null  or
              #       ctb04m01.trbprstip    is null  then
              #       initialize ctb04m01.trbempcod thru ctb04m01.trbprstip to null
              #       error " Contribuinte para tributacao deve ser informado!"
              #       next field socpgtdoctip
              #    end if
              # else
              #    initialize ctb04m01.trbempcod thru ctb04m01.trbprstip to null
              # end if
              
           end if
           
           # PSI 236292, acompanhar recolhimento de impostos
           call ctn55g00(ctb04m01.socopgnum)
           
    before field nfsnum
           display by name ctb04m01.nfsnum attribute (reverse)
           
    after field nfsnum
    
           # Retirado a pedido do PS em 22/06/2009
           # if ctb04m01.socpgtdoctip = 1  or  # NF
           #    ctb04m01.socpgtdoctip = 4      # NFE
           #    then
           #    if ctb04m01.nfsnum is null or
           #       ctb04m01.nfsnum <= 0
           #       then
           #       error " Número da nota fiscal deve ser informado!"
           #       next field nfsnum
           #    end if
           # end if
           
           if ctb04m01.nfsnum is not null and
              ctb04m01.nfsnum > 0
              then
              let l_ret = null
              
              call ctb00g01_vernfs(m_opg.soctip          ,
                                   m_opg.pestip          ,
                                   ctb04m01.cgccpfnum    ,
                                   ctb04m01.cgcord       ,
                                   ctb04m01.cgccpfdig    ,
                                   ctb04m01.socopgnum    ,
                                   ctb04m01.socpgtdoctip ,
                                   ctb04m01.nfsnum )
                         returning l_ret
                 
              if l_ret = "S" then
                 error " Documento já informado para o prestador, verifique "
                 next field nfsnum
              end if
           end if
           
           display by name ctb04m01.nfsnum
           
    #Fornax - Quantum - inicio
    before field fisnotsrenum
           display by name ctb04m01.fisnotsrenum attribute (reverse)

    after  field fisnotsrenum
           display by name ctb04m01.fisnotsrenum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field nfsnum
           end if
    #Fornax - Quantum - final   
    
    before field socemsnfsdat
           display by name ctb04m01.socemsnfsdat attribute (reverse)

    after  field socemsnfsdat
           display by name ctb04m01.socemsnfsdat

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field nfsnum
           end if

           if ctb04m01.socemsnfsdat is null  then
              error " Data de emissao da nota fiscal deve ser informada!"
              next field socemsnfsdat
           end if

           if ctb04m01.socemsnfsdat > today  then
              error " Data de emissao da nota fiscal nao pode ser maior que a data atual!"
              next field socemsnfsdat
           end if

           if ctb04m01.socemsnfsdat < today - 90 units day  and
              g_issk.acsnivcod      < 8                     then
              error " Data de emissao da nota fiscal nao pode ser anterior a noventa dias!"
              next field socemsnfsdat
           end if
           
           if ctb04m01.socemsnfsdat < today - 1 units year  then
              error " Data de emissao da nota fiscal nao pode ser anterior a um ano!"
              next field socemsnfsdat
           end if
           
           if ctb04m01.socemsnfsdat > today + 1 units year  then
              error " Data de emissao da nota fiscal nao pode ser posterior a um ano!"
              next field socemsnfsdat
           end if
           
           call ctd20g01_tem_item_nf(ctb04m01.socopgnum)
                returning l_res, l_msg
                
           # PSI 198404, NF digitada na capa da OP e nao nos itens
           # if l_res = 1 then
           #    call ctb11m16(ctb04m01.socopgnum) returning l_msg
           # end if
           
           if l_res = 3 then
              error l_msg
              next field socemsnfsdat
           end if

           
    before field succod
           if ctb04m01.favtip != 3
              then
              if ctb04m01.succod is null
                 then
                 call ctd12g00_dados_pst(3, m_opg.pstcoddig)
                      returning l_res, l_msg, ctb04m01.succod
              end if
              
              if ctb04m01.succod is not null
                 then
                 call cty10g00_nome_sucursal(ctb04m01.succod)
                      returning l_res, l_msg, ctb04m01.sucnom
              end if
              
              display by name ctb04m01.succod, ctb04m01.sucnom
              next field socpgtopccod
           end if
           
    after field succod
           if ctb04m01.favtip = 3  # Segurado
              then
              if ctb04m01.succod is null or
                 ctb04m01.succod <= 0
                 then
                 let l_sql = " select succod, sucnom from gabksuc ",
                             " order by 2 "                       
                 call ofgrc001_popup(08, 13, 'SUCURSAL DE REEMBOLSO',
                                     'Codigo', 'Descricao', 'N', l_sql, '', 'D')
                      returning l_res, ctb04m01.succod, ctb04m01.sucnom
                 next field succod
              end if
              
              if ctb04m01.succod is not null
                 then
                 call cty10g00_nome_sucursal(ctb04m01.succod)
                      returning l_res, l_msg, ctb04m01.sucnom
     
                 if l_res != 1 then
                    error l_msg
                    next field succod
                 end if
              end if
              display by name ctb04m01.succod, ctb04m01.sucnom
           else
              next field socpgtopccod
           end if
           
    before field socpgtopccod
           display by name ctb04m01.socpgtopccod attribute (reverse)

    after  field socpgtopccod
           display by name ctb04m01.socpgtopccod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socemsnfsdat
           end if
           
           #Fornax - Quantum - inicio
           #Informar o numero da OP SAP, qdo pagto cheque
           if ctb04m01.socpgtopccod = 2 then
              
              #Verifica se a OP e People ou SAP  Inicio  #Fornax-Quantum  
              call ffpgc377_verificarIntegracaoAtivaEmpresaRamo("038PTSOCTRIB",today,ctb04m01.empcod, 0)  
                   returning  mr_retSAP.stt                                                                 
                             ,mr_retSAP.msg     
                     
              display "mr_retSAP.stt ", mr_retSAP.stt
              display "mr_retSAP.msg ", mr_retSAP.msg                                                             
              
              if mr_retSAP.stt <> 0 then    
               
                call ctb11m01a(ctb04m01.socopgnum)
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
           if ctb04m01.socpgtopccod   is null   then
              error " Opcao de pagamento deve ser informada!"
              next field socpgtopccod
           end if
           
           initialize m_dominio.* to null
           
           call cty11g00_iddkdominio('socpgtopccod', ctb04m01.socpgtopccod)
                returning m_dominio.*
                
           if m_dominio.erro = 1
              then
              let ctb04m01.socpgtopcdes = m_dominio.cpodes clipped
           else
              initialize ctb04m01.socpgtopcdes to null
              error " Opcao de pagamento nao cadastrada!"
              next field socpgtopccod
           end if
           
           display by name ctb04m01.socpgtopcdes
           
           if ctb04m01.socpgtopccod  =  2    then
              initialize ctb04m01.bcoctatip,
                         ctb04m01.bcoctatipdes,
                         ctb04m01.bcocod,
                         ctb04m01.bcosgl,
                         ctb04m01.bcoagnnum,
                         ctb04m01.bcoagndig,
                         ctb04m01.bcoagnnom,
                         ctb04m01.bcoctanum,
                         ctb04m01.bcoctadig  to null

              display by name ctb04m01.bcoctatip,
                              ctb04m01.bcoctatipdes,
                              ctb04m01.bcocod,
                              ctb04m01.bcosgl,
                              ctb04m01.bcoagnnum,
                              ctb04m01.bcoagndig,
                              ctb04m01.bcoagnnom,
                              ctb04m01.bcoctanum,
                              ctb04m01.bcoctadig
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
                   returning ctb04m01.pestip      , ctb04m01.cgccpfnum,
                             ctb04m01.cgcord      , ctb04m01.cgccpfdig,
                             ctb04m01.socopgfavnom, ctb04m01.bcocod,
                             ctb04m01.bcosgl      , ctb04m01.bcoagnnum,
                             ctb04m01.bcoagndig   , ctb04m01.bcoagnnom,
                             ctb04m01.bcoctanum   , ctb04m01.bcoctadig,
                             ctb04m01.socpgtopccod, ctb04m01.socpgtopcdes,
                             ctb04m01.bcoctatip   , ctb04m01.bcoctatipdes, 
                             ws.confirma
              if ws.confirma  is null    or
                 ws.confirma  = "N"      then
                 error " Informacoes do cadastro nao foram confirmadas!"
                 next field socpgtopccod
              end if

              display by name ctb04m01.pestip      , ctb04m01.cgccpfnum,
                              ctb04m01.cgcord      , ctb04m01.cgccpfdig,
                              ctb04m01.socopgfavnom, ctb04m01.bcocod,
                              ctb04m01.bcosgl      , ctb04m01.bcoagnnum,
                              ctb04m01.bcoagndig   , ctb04m01.bcoagnnom,
                              ctb04m01.bcoctanum   , ctb04m01.bcoctadig,
                              ctb04m01.socpgtopccod, ctb04m01.socpgtopcdes,
                              ctb04m01.bcoctatip   , ctb04m01.bcoctatipdes

              if ctb04m01.pestip     is null    or
                 ctb04m01.cgccpfnum  is null    or
                 ctb04m01.cgccpfdig  is null    then
                 error " Prestador nao possui Cgc/Cpf favorecido cadastrado!"
                 next field socpgtopccod
              end if

              if ctb04m01.socopgfavnom  is null    then
                 error " Prestador nao possui nome do favorecido cadastrado!"
                 next field socpgtopccod
              end if

              if ctb04m01.socpgtopccod = 2
                 then
                 next field pgtdstcod
              else
                 next field socopgfavnom
              end if
           else
              # Nao sugerir dados para o reembolso, devem vir do protocolo da OP
              # Revisao reembolso, Abril/2010
              # if ctb04m01.favtip = 3   and    # Segurado
              #    ctb04m01.socopgsitcod = 1    # Nao analisada
              #    then
              #    call ctd20g07_dados_cli(ctb04m01.segnumdig)
              #         returning l_res, l_msg,  
              #                   ctb04m01.socopgfavnom, 
              #                   ctb04m01.cgccpfnum   ,
              #                   ctb04m01.cgcord      , 
              #                   ctb04m01.cgccpfdig   ,
              #                   ctb04m01.pestip
              #                   
              #    display by name ctb04m01.socopgfavnom, ctb04m01.cgccpfnum,
              #                    ctb04m01.cgcord      , ctb04m01.cgccpfdig,
              #                    ctb04m01.pestip
              #                    
              #    error ' Foram sugeridos os dados do cliente para favorecido da OP'
              #    sleep 1
              # end if
           end if

    before field pgtdstcod
           if ctb04m01.socpgtopccod  =  1   or    #--> Deposito em conta
              ctb04m01.socpgtopccod  =  3   then  #--> Boleto bancario
              initialize ctb04m01.pgtdstcod, ctb04m01.pgtdstdes   to null
              display by name ctb04m01.pgtdstcod, ctb04m01.pgtdstdes
              next field socopgfavnom
           end if
           display by name ctb04m01.pgtdstcod   attribute(reverse)

    after  field pgtdstcod
           display by name ctb04m01.pgtdstcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socpgtopccod
           end if

           if ctb04m01.pgtdstcod   is null   then
              error " Destino deve ser informado!"
              call ctb11m04() returning  ctb04m01.pgtdstcod
              next field pgtdstcod
           end if
           select pgtdstdes
             into ctb04m01.pgtdstdes
             from fpgkpgtdst
            where fpgkpgtdst.pgtdstcod = ctb04m01.pgtdstcod

           if sqlca.sqlcode <> 0    then
              error " Destino nao cadastrado!"
              call ctb11m04() returning  ctb04m01.pgtdstcod
              next field pgtdstcod
           else
              display by name ctb04m01.pgtdstdes
           end if
           
    before field socopgfavnom
           display by name ctb04m01.socopgfavnom   attribute(reverse)

    after  field socopgfavnom
           display by name ctb04m01.socopgfavnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if ctb04m01.socpgtopccod  =  1   or    #--> Deposito em conta
                 ctb04m01.socpgtopccod  =  3   then  #--> Boleto bancario
                 next field socpgtopccod
              end if
              next field  pgtdstcod
           end if

           if ctb04m01.socopgfavnom   is null   then
              error " Nome do favorecido deve ser informado!"
              next field socopgfavnom
           end if

           if m_opg.pstcoddig  is not null   and
              m_opg.pstcoddig  >  11         then
              if ctb04m01.socopgfavnom  <>  ws.socfavnomcad   then
                 error " Nome do favorecido diferente do cadastro!"
                 next field socopgfavnom
              end if
           end if

    before field pestip
           display by name ctb04m01.pestip   attribute(reverse)

    after  field pestip
           display by name ctb04m01.pestip

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socopgfavnom
           end if

           if ctb04m01.pestip   is null   then
              error " Tipo de pessoa deve ser informado!"
              next field pestip
           end if

           if ctb04m01.pestip  <>  "F"   and
              ctb04m01.pestip  <>  "J"   then
              error " Tipo de pessoa invalido!"
              next field pestip
           end if

           if ctb04m01.pestip  =  "F"   then
              initialize ctb04m01.cgcord  to null
              display by name ctb04m01.cgcord
           end if

    before field cgccpfnum
           display by name ctb04m01.cgccpfnum   attribute(reverse)

    after  field cgccpfnum
           display by name ctb04m01.cgccpfnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field pestip
           end if

           if ctb04m01.cgccpfnum   is null   or
              ctb04m01.cgccpfnum   =  0      then
              error " Numero do Cgc/Cpf deve ser informado!"
              next field cgccpfnum
           end if

           if ctb04m01.pestip  =  "F"   then
              next field cgccpfdig
           end if

    before field cgcord
           display by name ctb04m01.cgcord   attribute(reverse)

    after  field cgcord
           display by name ctb04m01.cgcord

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field cgccpfnum
           end if

           if ctb04m01.cgcord   is null   or
              ctb04m01.cgcord   =  0      then
              error " Filial do Cgc/Cpf deve ser informada!"
              next field cgcord
           end if

    before field cgccpfdig
           display by name ctb04m01.cgccpfdig  attribute(reverse)

    after  field cgccpfdig
           display by name ctb04m01.cgccpfdig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if ctb04m01.pestip  =  "J"  then
                 next field cgcord
              else
                 next field cgccpfnum
              end if
           end if

           if ctb04m01.cgccpfdig   is null   then
              error " Digito do Cgc/Cpf deve ser informado!"
              next field cgccpfdig
           end if

           if ctb04m01.pestip  =  "J"    then
              call F_FUNDIGIT_DIGITOCGC(ctb04m01.cgccpfnum, ctb04m01.cgcord)
                   returning ws.cgccpfdig
           else
              call F_FUNDIGIT_DIGITOCPF(ctb04m01.cgccpfnum)
                   returning ws.cgccpfdig
           end if
           if ws.cgccpfdig       is null           or
              ctb04m01.cgccpfdig <> ws.cgccpfdig   then
              error "Digito Cgc/Cpf incorreto!"
              next field cgccpfdig
           end if

           if m_opg.pstcoddig  is not null   and
              m_opg.pstcoddig  >  11         then
              if ctb04m01.pestip     <>  ws.pestipcad      or
                 ctb04m01.cgccpfnum  <>  ws.cgccpfnumcad   or
                 ctb04m01.cgccpfdig  <>  ws.cgccpfdigcad   then
                 error " Cgc/Cpf diferente do cadastro!"
                 next field cgccpfdig
                 #PSI197858 - inicio
              # else
              #     next field socpgtdsctip
              #PSI197858 - fim
             end if
           end if
           
           if ctb04m01.nfsnum is not null and
              ctb04m01.nfsnum > 0
              then
              let l_ret = null
              
              call ctb00g01_vernfs(m_opg.soctip          ,
                                   ctb04m01.pestip       ,
                                   ctb04m01.cgccpfnum    ,
                                   ctb04m01.cgcord       ,
                                   ctb04m01.cgccpfdig    ,
                                   ctb04m01.socopgnum    ,
                                   ctb04m01.socpgtdoctip ,
                                   ctb04m01.nfsnum )
                         returning l_ret
                 
              if l_ret = "S" then
                 error " Documento ", ctb04m01.nfsnum ," já informado para o prestador, verifique "
                 next field cgccpfdig
              end if
           end if
           
           if ctb04m01.socpgtopccod = 2
              then
              exit input
           end if
           
    before field bcoctatip
       display by name ctb04m01.bcoctatip attribute (reverse)

    after  field bcoctatip
       display by name ctb04m01.bcoctatip

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field cgccpfdig
         end if

         if ctb04m01.bcoctatip  is null   then
            error " Tipo de conta deve ser informado!"
            next field bcoctatip
         end if

         case ctb04m01.bcoctatip
            when  1   let ctb04m01.bcoctatipdes = "C.CORRENTE"
            when  2   let ctb04m01.bcoctatipdes = "POUPANCA"
            otherwise error " Tipo Conta: 1-Conta Corrente, 2-Poupanca!"
                      next field bcoctatip
         end case
         display by name ctb04m01.bcoctatipdes

    before field bcocod
           display by name ctb04m01.bcocod   attribute(reverse)

    after  field bcocod
           display by name ctb04m01.bcocod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoctatip
           end if

           if ctb04m01.bcocod   is null   then
              error " Codigo do banco deve ser informado!"
              next field bcocod
           end if

           select bcosgl
             into ctb04m01.bcosgl
             from gcdkbanco
            where gcdkbanco.bcocod = ctb04m01.bcocod

           if sqlca.sqlcode <> 0    then
              error " Banco nao cadastrado!"
              next field bcocod
           else
              display by name ctb04m01.bcosgl
           end if

    before field bcoagnnum
           display by name ctb04m01.bcoagnnum   attribute(reverse)

    after  field bcoagnnum
           display by name ctb04m01.bcoagnnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcocod
           end if

           if ctb04m01.bcoagnnum   is null   then
              error " Codigo da agencia deve ser informada!"
              next field bcoagnnum
           end if

           initialize ws.bcoagndig        to null
           initialize ctb04m01.bcoagnnom  to null
           display by name ctb04m01.bcoagnnom

           let ws.bcoagnnum = ctb04m01.bcoagnnum

           select bcoagnnom, bcoagndig
             into ctb04m01.bcoagnnom, ws.bcoagndig
             from gcdkbancoage
            where gcdkbancoage.bcocod    = ctb04m01.bcocod      and
                  gcdkbancoage.bcoagnnum = ws.bcoagnnum

           if sqlca.sqlcode  =  0   then
              display by name ctb04m01.bcoagnnom
           end if

    before field bcoagndig
           display by name ctb04m01.bcoagndig   attribute(reverse)

    after  field bcoagndig
           display by name ctb04m01.bcoagndig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoagnnum
           end if
           
           # inibir conforme solicitacao projeto People 10/08/2009
           # if ctb04m01.bcocod  <>  424   and    #-> Noroeste
           #    ctb04m01.bcocod  <>  399   and    #-> Bamerindus
           #    ctb04m01.bcocod  <>  320   and    #-> Bicbanco
           #    ctb04m01.bcocod  <>  409   and    #-> Unibanco
           #    ctb04m01.bcocod  <>  231   and    #-> Boa Vista
           #    ctb04m01.bcocod  <>  347   and    #-> Sudameris
           #    ctb04m01.bcocod  <>  8     and    #-> Meridional
           #    ctb04m01.bcocod  <>  33    and    #-> Banespa
           #    ctb04m01.bcocod  <>  388   and    #-> B.M.D.
           #    ctb04m01.bcocod  <>  21    and    #-> Banco do Espirito Santo
           #    ctb04m01.bcocod  <>  230   and    #-> Bandeirantes
           #    ctb04m01.bcocod  <>  31    and    #-> Banco do Estado de Goias
           #    ctb04m01.bcocod  <>  479   and    #-> Banco de Boston
           #    ctb04m01.bcocod  <>  745   then   #-> Citibank
           #    if g_issk.acsnivcod  <  8         and
           #       ctb04m01.bcoagndig   is null   then
           #       error " Digito da agencia deve ser informado!"
           #       next field bcoagndig
           #    end if
           # end if

    before field bcoctanum
           display by name ctb04m01.bcoctanum   attribute(reverse)

    after  field bcoctanum
           display by name ctb04m01.bcoctanum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoagndig
           end if

           if ctb04m01.bcoctanum   is null   or
              ctb04m01.bcoctanum   =  0      then
              error " Numero da conta corrente deve ser informado!"
              next field bcoctanum
           end if
           
           if ctb04m01.socpgtopccod  =  1      or
              ctb04m01.socpgtopccod  =  3      then
              if ctb04m01.bcocod     is null   or
                 ctb04m01.bcoagnnum  is null   or
                 ctb04m01.bcoctanum  is null   then
                 error " Dados para pagamento em conta incompletos!"
                 next field socpgtopccod
              end if
           else
              if ctb04m01.bcocod     is not null   or
                 ctb04m01.bcoagnnum  is not null   or
                 ctb04m01.bcoagndig  is not null   or
                 ctb04m01.bcoctanum  is not null   or
                 ctb04m01.bcoctadig  is not null   then
                 error " Dados nao conferem com opcao de pagamento!"
                 next field socpgtopccod
              end if
           end if
           
    before field bcoctadig
           display by name ctb04m01.bcoctadig   attribute(reverse)

    after  field bcoctadig
           display by name ctb04m01.bcoctadig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoctanum
           end if

           if ctb04m01.bcoctadig   is null   then
              error " Digito da conta corrente deve ser informado!"
              next field bcoctadig
           end if

#      before field socpgtdsctip
#             if m_opg.pstcoddig  is null    then
#                exit input
#             end if
#             display by name ctb04m01.socpgtdsctip   attribute(reverse)

#      after  field socpgtdsctip
#             display by name ctb04m01.socpgtdsctip

#             if fgl_lastkey() = fgl_keyval ("up")     or
#                fgl_lastkey() = fgl_keyval ("left")   then
#                if m_opg.pstcoddig   is not null   and
#                   m_opg.pstcoddig   >  11         then
#                   next field cgccpfdig
#                end if
#                if ctb04m01.socpgtopccod  =  2   then
#                   next field socopgfavnom
#                end if
#                next field bcoctadig
#             end if

#             initialize ctb04m01.socpgtdscdes   to null

#             if ctb04m01.socpgtdsctip  is not null   then
#                case ctb04m01.socpgtdsctip
#                     when  1
#                           let ctb04m01.socpgtdscdes = "AVARIAS"
#                     when  2
#                           let ctb04m01.socpgtdscdes = "EMPRESTIMO"
#                           display by name ctb04m01.socpgtdscdes
#                           error " Valor do emprestimo nao pode ser descontado do pagamento!"
#                           next field socpgtdsctip
#                     when  5
#                           let ctb04m01.socpgtdscdes = "DESCONTO"
#                     when  6
#                           let ctb04m01.socpgtdscdes = "ADIANTAMENTOS"
#                     when  7
#                           let ctb04m01.socpgtdscdes = "COMERCIAL"
#                     when  8
#                           let ctb04m01.socpgtdscdes = "FINANCIAMENTOS"
#                     when  9
#                           let ctb04m01.socpgtdscdes = "OUTROS"

#                     otherwise
#                           error "1-Avarias, 2-Emprestimo, 5-Desc., 6-Adiant., 7-Comerc., 8-Financ., 9-Outros";
#                           next field socpgtdsctip
#                end case
#             end if
#             display by name ctb04m01.socpgtdscdes

#             if ctb04m01.socpgtdsctip  is null   then
#                initialize ctb04m01.socopgdscvlr   to null
#                display by name ctb04m01.socopgdscvlr
#                exit input
#             end if

#      before field socopgdscvlr
#             display by name ctb04m01.socopgdscvlr   attribute(reverse)

#      after  field socopgdscvlr
#             display by name ctb04m01.socopgdscvlr

#             if fgl_lastkey() = fgl_keyval ("up")     or
#                fgl_lastkey() = fgl_keyval ("left")   then
#                next field socpgtdsctip
#             end if

#             if ctb04m01.socopgdscvlr  is not null   and
#                ctb04m01.socpgtdsctip  is null       then
#                error " Tipo do desconto deve ser informado!"
#                next field socopgdscvlr
#             end if

#             if ctb04m01.socopgdscvlr  is null       and
#                ctb04m01.socpgtdsctip  is not null   then
#                error " Valor do desconto deve ser informado!"
#                next field socopgdscvlr
#             end if

#             if ctb04m01.socopgdscvlr   =  0      then
#                error " Valor de desconto nao deve ser zero!"
#                next field socopgdscvlr
#             end if

#             if ctb04m01.socopgdscvlr  >=  ctb04m01.socfattotvlr   then
#                error " Valor desconto nao deve ser maior ou igual ao valor total da O.P.!"
#                next field socopgdscvlr
#             end if

#             if ctb04m01.pestip = "F"  and
#                (ctb04m01.socfattotvlr - ctb04m01.socopgdscvlr) < 10.00  then
#                error " Valor final do pagamento nao deve ser menor que 10.00!"
#                next field socopgdscvlr
#             end if

    on key (interrupt)
       exit input

 end input
 
 if int_flag
    then
    initialize ctb04m01.*  to null
    return ctb04m01.*
 end if

 return ctb04m01.*

end function  ###  input_ctb04m01

#--------------------------------------------------------------------
function cancela_ctb04m01(k_ctb04m01)
#--------------------------------------------------------------------

  define ctb04m01     record
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
     #PSI197858 - fim
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
 
  define k_ctb04m01   record
     socopgnum        like dbsmopg.socopgnum
  end record
 
  define ws           record
     atdsrvnum        like dbsmopgitm.atdsrvnum,
     atdsrvano        like dbsmopgitm.atdsrvano,
     atdcstvlr        like datmservico.atdcstvlr,
     errcod           smallint ,
     pgtautprpdat     like fpgmpgtaut.pgtautprpdat,
     pgtdat           like fpgmpgt.pgtdat,
     pgtfrmcod        like fpgmpgt.pgtfrmcod,
     pgtbcocod        like fpgmpgt.pgtbcocod,
     pgtbcoagnnum     like fpgmpgt.pgtbcoagnnum,
     bcoctanum        dec  (12,0),
     bcoctadig        char (02),
     pgtdocnum        like fpgmpgt.pgtdocnum,
     pgtautvlr        like fpgmpgtaut.pgtautvlr,
     errdsc           char (50),
     confirma         char (01),
     flgok            smallint,
     msg              char (75)
  end record
 
  define a_bfpga_err  array[10] of record
     errcod           smallint
  end record
  
  define l_res  smallint,
         l_msg  char (80)
         
  define arr_aux      smallint
 
  define sql_comando  char (200)
 
  initialize a_bfpga_err  to null
  initialize ws.*         to null

  #Carrega o record ctb04m01 antes de entrar no menu para poder testar
  # a data de pagamento, e nao ter que carregar novamente se a data para
  # cancelamento for valida.
  call ler_ctb04m01(k_ctb04m01.*) returning ctb04m01.*
  
  if ctb04m01.socfatpgtdat < today then
     clear form
     initialize ctb04m01.*   to null
     initialize k_ctb04m01.* to null
     error "Nao foi possivel cancelar OP, Data de pagamento menor que data atual!"
  
  else

     menu "Confirma cancelamento ?"

        command "Nao" "Nao cancela ordem de pagamento"
           clear form
           initialize ctb04m01.*   to null
           initialize k_ctb04m01.* to null
           error " Operacao cancelada!"
           exit menu

      	command "Sim" "Cancela ordem de pagamento"

          if ctb04m01.socopgnum  is null   then
             initialize ctb04m01.*   to null
             initialize k_ctb04m01.* to null
             error " Ordem de pagamento nao localizada!"
          else
             message " Aguarde, processando cancelamento... " attribute (reverse)
             
             call ctx07g00(k_ctb04m01.socopgnum, ctb04m01.socopgsitcod,
                           ctb04m01.ciaempcod, g_issk.funmat, g_issk.empcod)
                 returning l_res, l_msg
                 
             if l_res != 0
                then
                let l_msg = ' Erro:', l_msg clipped
                message "Erro no canelamento!" attribute (reverse)
                error l_msg
             else
                initialize ctb04m01.*   to null
                initialize k_ctb04m01.* to null
                message "Cancelamento efetuado com sucesso!" attribute (reverse)
                #clear form
             end if
          end if
          
          exit menu
          
     end menu
  end if
  
  return k_ctb04m01.*
  
end function  ###  cancela_ctb04m01

#---------------------------------------------------------
function ler_ctb04m01(k_ctb04m01)
#---------------------------------------------------------

  define ctb04m01     record
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
 
  define k_ctb04m01   record
     socopgnum        like dbsmopg.socopgnum
  end record
 
  define ws           record
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

  initialize ctb04m01.*   to null
  initialize ws.*         to null
  initialize lr_param.*   to null
  initialize lr_ret.*     to null
  initialize l_fav.* to null
  initialize m_opg.* to null
  
  initialize l_nfsnum, l_ciaempcod, l_ciaempcodOP to null

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
         pgtdstcod,
         socopgdscvlr,
         soctip,
         segnumdig,
         pestip,
         favtip,
         nfsnum,
         fisnotsrenum,  #Fornax - Quantum
         infissalqvlr                          # PSI-11-19199PR
    into ctb04m01.socopgnum,
         ctb04m01.socopgsitcod,
         m_opg.pstcoddig,
         ctb04m01.corsus,
         ctb04m01.opgcgccpfnum,
         ctb04m01.opgcgcord,
         ctb04m01.opgcgccpfdig,
         ctb04m01.socfatentdat,
         ctb04m01.socfatpgtdat,
         ctb04m01.socfatitmqtd,
         ctb04m01.socfattotvlr,
         ctb04m01.soctrfcod,
         ctb04m01.socfatrelqtd,
         ctb04m01.socpgtdoctip,
         ctb04m01.socemsnfsdat,
         ctb04m01.empcod,
         ctb04m01.succod,
         ctb04m01.pgtdstcod,
         ctb04m01.socopgdscvlr,
         m_opg.soctip,
         ctb04m01.segnumdig,
         m_opg.pestip,
         ctb04m01.favtip,
         ctb04m01.nfsnum,
         ctb04m01.fisnotsrenum,  #Fornax - Quantum
         ctb04m01.infissalqvlr                      # PSI-11-19199PR
    from dbsmopg
   where socopgnum = k_ctb04m01.socopgnum

  if sqlca.sqlcode = notfound   then
     error " Ordem de pagamento nao cadastrada!"
     goto fim_erro
  end if
  
  # buscar dados do favorecido conforme tipo
  if m_opg.soctip != 3
     then
     error " Este numero de OP nao pertence ao Ramos Elementares (RE)! "
     goto fim_erro
  end if
  
  call cty10g00_nome_sucursal(ctb04m01.succod)
       returning l_res, l_msg, ctb04m01.sucnom
       
  display by name ctb04m01.sucnom
  
  #PSI197858 - inicio
  select sum(dscvlr) into ws.desconto
  from dbsropgdsc
  where socopgnum = k_ctb04m01.socopgnum
  
  # if ws.desconto <> 0 and ws.desconto is not null then
  # 	let ctb04m01.socfattotvlr = ctb04m01.socfattotvlr - ws.desconto
  # else
  # 	if ctb04m01.socopgdscvlr is not null and ctb04m01.socopgdscvlr > 0.00 then
  # 		let ctb04m01.socfattotvlr = ctb04m01.socfattotvlr - ctb04m01.socopgdscvlr
  # 	end if
  # end if
  
  if ctb04m01.socopgdscvlr is null or ctb04m01.socopgdscvlr = 0.00 then
     if ws.desconto is not null or ws.desconto > 0.00 then
        let ctb04m01.socopgdscvlr = ws.desconto
     else
        let ctb04m01.socopgdscvlr = 0.00
     end if
  end if
  #PSI197858 - fim
  
  initialize m_dominio.* to null
  
  call cty11g00_iddkdominio('socopgsitcod', ctb04m01.socopgsitcod)
       returning m_dominio.*
       
  if m_dominio.erro = 1
     then
     let ctb04m01.socopgsitdes = m_dominio.cpodes clipped
  else
     initialize ctb04m01.socopgsitdes to null
     error "Situacao da OP: ", m_dominio.mensagem
     goto fim_erro
  end if
  
  if ctb04m01.socopgsitcod  <>  1   then   #--->  Nao analisada
     
     # ligia 21/08/08 - psi 198404
     # #if ctb04m01.cctcod is not null  then
     # 
     # #PSI 191167
     # let lr_param.empcod    = ctb04m01.empcod
     # let lr_param.succod    = 01 ##ctb04m01.succod
     # let lr_param.cctlclcod = (12246 / 10000)
     # let lr_param.cctdptcod = (12246 mod 10000)
     # 
     # call fctgc102_vld_dep(lr_param.*) returning lr_ret.*
     # 
     # if lr_ret.erro  <>  0 
     #    then
     #    error "Erro (",lr_ret.erro,") na leitura do centro de custo!"
     #    sleep 3
     #    error lr_ret.mens
     #    goto fim_erro
     # end if
     # ##let ctb04m01.cctnom = lr_ret.cctdptnom
     # ##end if
     
     if ctb04m01.pgtdstcod is not null  then
        select pgtdstdes
          into ctb04m01.pgtdstdes
          from fpgkpgtdst
         where pgtdstcod = ctb04m01.pgtdstcod

        if sqlca.sqlcode  <>  0   then
           error " Erro (", sqlca.sqlcode,") na leitura do destino!"
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
       into ctb04m01.socopgfavnom,
            ctb04m01.socpgtopccod,
            ctb04m01.pestip,
            ctb04m01.cgccpfnum,
            ctb04m01.cgcord,
            ctb04m01.cgccpfdig,
            ctb04m01.bcoctatip,
            ctb04m01.bcocod,
            ctb04m01.bcoagnnum,
            ctb04m01.bcoagndig,
            ctb04m01.bcoctanum,
            ctb04m01.bcoctadig
       from dbsmopgfav
      where socopgnum  =  k_ctb04m01.socopgnum

     if ctb04m01.socopgsitcod  <>  8   and    #--->  Cancelada
        sqlca.sqlcode          <>  0   then
        error " Erro (",sqlca.sqlcode,") na leitura do favorecido!"
        goto fim_erro
     end if

     #--------------------------------------------------------------------
     # Descricao da opcao de pagamento
     #--------------------------------------------------------------------
     if ctb04m01.socpgtopccod is not null and
        ctb04m01.socpgtopccod > 0
        then
        initialize m_dominio.* to null
        
        call cty11g00_iddkdominio('socpgtopccod', ctb04m01.socpgtopccod)
             returning m_dominio.*
             
        if m_dominio.erro = 1
           then
           let ctb04m01.socpgtopcdes = m_dominio.cpodes clipped
        else
           initialize ctb04m01.socpgtopcdes to null
           error "Opção de pagamento: ", m_dominio.mensagem
           goto fim_erro
        end if
     end if
     
     if ctb04m01.socpgtopccod  is not null  and
        ctb04m01.socpgtopccod  <>  2        then  #--> Opcao pagto cheque

        case ctb04m01.bcoctatip
           when 1  let ctb04m01.bcoctatipdes = "C.CORRENTE"
           when 2  let ctb04m01.bcoctatipdes = "POUPANCA"
        end case

        select bcosgl
          into ctb04m01.bcosgl
          from gcdkbanco
         where gcdkbanco.bcocod = ctb04m01.bcocod

        if sqlca.sqlcode  <>  0   then
           error " Erro (",sqlca.sqlcode,") na leitura do nome do banco!"
           goto fim_erro
        end if

        let ws.bcoagnnum = ctb04m01.bcoagnnum

        select bcoagnnom
          into ctb04m01.bcoagnnom
          from gcdkbancoage
         where gcdkbancoage.bcocod    = ctb04m01.bcocod     and
               gcdkbancoage.bcoagnnum = ws.bcoagnnum

        if sqlca.sqlcode  <>  0     and
           sqlca.sqlcode  <>  100   then
           error " Erro (",sqlca.sqlcode,") na leitura do nome da agencia!"
           goto fim_erro
        end if
     end if
  else
     # fase 'Nao analisada' ainda nao possui favorecido, sugerir valores da OP
     let ctb04m01.cgccpfnum = ctb04m01.opgcgccpfnum
     let ctb04m01.cgcord    = ctb04m01.opgcgcord
     let ctb04m01.cgccpfdig = ctb04m01.opgcgccpfdig
     let ctb04m01.pestip    = m_opg.pestip
  end if
  
  select empcod, succod, prstip
    into ctb04m01.trbempcod,
         ctb04m01.trbsuccod,
         ctb04m01.trbprstip
  from dbsmopgtrb
  where socopgnum = k_ctb04m01.socopgnum
  
  #PSI 205206
  #verificar qual a empresa dos itens da OP - caso exista
  declare cctb04m01001 cursor for
     select b.ciaempcod, a.nfsnum
        from dbsmopgitm a, outer datmservico b
        where a.socopgnum = k_ctb04m01.socopgnum
          and a.atdsrvnum = b.atdsrvnum
          and a.atdsrvano = b.atdsrvano
          
  foreach cctb04m01001 into l_ciaempcod, l_nfsnum
  
      #se empresa da OP é nula
      if l_ciaempcodOP is null   # primeiro servico
         then
         let ctb04m01.ciaempcod = l_ciaempcod
         
         #empresa da OP recebe empresa do item
         let l_ciaempcodOP = l_ciaempcod
         
         #busca descricao da empresa
         # call cty14g00_empresa(1, l_ciaempcodOP)
         #      returning lr_ret.erro,
         #                lr_ret.mens,
         #                ctb04m01.empresa
         
      else
         #verificar se empresa da OP e empresa do item são iguais
         if l_ciaempcodOP <> l_ciaempcod then
            error "Itens da OP com empresas diferentes!"
         end if
      end if
  end foreach
  
  # atribuir numero da NFS do item
  if ctb04m01.nfsnum is null and l_nfsnum is not null
     then
     let ctb04m01.nfsnum = l_nfsnum
  end if
  
  # empresa nao gravada na OP ou gravada errada na OP automatica, corrige no modifica
  if (ctb04m01.empcod is null and l_ciaempcod is not null) or
     (ctb04m01.empcod != l_ciaempcodOP)
     then
     let ctb04m01.empcod = l_ciaempcodOP
  end if

  # obter dados do favorecido com CPF/CNPJ gravado na tab favorecido
  call ctb00g01_dados_favtip(7, m_opg.pstcoddig, ctb04m01.segnumdig,
                             '', '', ctb04m01.corsus,
                             ctb04m01.empcod,
                             ctb04m01.cgccpfnum,
                             ctb04m01.cgcord,
                             ctb04m01.cgccpfdig,
                             ctb04m01.favtip) 
                   returning l_fav.errcod, 
                             l_fav.msg, 
                             ctb04m01.favtip,
                             ctb04m01.favtipcod,
                             ctb04m01.favtipcab,
                             ctb04m01.favtipnom,
                             ctb04m01.simoptpstflg     # PSI-11-19199PR
  
  if l_fav.errcod != 0 
     then
     error l_fav.msg
     sleep 1
     goto fim_erro
  end if
  
  # sugerir nome do CPF da OP no favorecido antes da analise
  if ctb04m01.socopgsitcod = 1  #  Nao analisada
     then
     let ctb04m01.socopgfavnom = ctb04m01.favtipnom
  end if
  
  #   case ctb04m01.socpgtdsctip
  #      when 1  let ctb04m01.socpgtdscdes = "AVARIAS"
  #      when 2  let ctb04m01.socpgtdscdes = "EMPRESTIMO"
  #      when 5  let ctb04m01.socpgtdscdes = "DESCONTO"
  #      when 6  let ctb04m01.socpgtdscdes = "ADIANTAMENTOS"
  #      when 7  let ctb04m01.socpgtdscdes = "COMERCIAL"
  #      when 8  let ctb04m01.socpgtdscdes = "FINANCIAMENTOS"
  #      when 9  let ctb04m01.socpgtdscdes = "OUTROS"
  #   end case
  
  if ctb04m01.socpgtdoctip is not null and
     ctb04m01.socpgtdoctip > 0
     then
     initialize m_dominio.* to null
     
     call cty11g00_iddkdominio('socpgtdoctip', ctb04m01.socpgtdoctip)
          returning m_dominio.*
          
     if m_dominio.erro = 1
        then
        let ctb04m01.socpgtdocdes = m_dominio.cpodes clipped
     else
        initialize ctb04m01.socpgtdocdes to null
        error "Tipo documento fiscal: ", m_dominio.mensagem
     end if
  end if
  
  # busca descricao da empresa, se nao houver itens mostra N/D
  call cty14g00_empresa_abv(ctb04m01.empcod)
       returning lr_ret.erro, lr_ret.mens, ctb04m01.empresa
       
  return ctb04m01.*
  
  #--------------------------------------------------------------------
  label fim_erro :
  #--------------------------------------------------------------------
  sleep 2
  initialize ctb04m01.*    to null
  initialize k_ctb04m01.*  to null
  return ctb04m01.*

end function  ###  ler_ctb04m01
