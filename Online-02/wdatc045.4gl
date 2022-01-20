#############################################################################
# Nome do Modulo: wdatc045                                             Zyon #
#                                                                           #
#                                                                  Mar/2003 #
# Tela de acerto de valores de serviço                                      #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 04/06/03    PSI 163759   R. Santos    Troca de query para extracao.       #
#...........................................................................#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- ------------------------------       #
# 06/10/2004  Mariana,Meta   PSI187801 Incluir condicao de flag de pendencia#
#                                      (anlokaflg = 'P' no select principal #
#                                      Chamar wdatc048.pl qdo flag = P      #
#---------------------------------------------------------------------------#
# 16/03/2005  META, MarcosMP PSI188751 Preencher laudo RIS no Portal de     #
#                                      Negocios.                            #
#---------------------------------------------------------------------------#
# 22/06/2005  Helio (Meta)  PSI 188751 Incluir indicador para RIS preenchido#
# 30/07/2008  Fabio Costa   PSI 227145 Buscar data/hora do acionamento do   #
#                                      servico                              #
#---------------------------------------------------------------------------#

database porto

main
 
 define ws record
     sttsess             dec     (1,0),
     comando             char    (1000),
     servico             char    (13),
     srvtipabvdes        like    datksrvtip.srvtipabvdes,
     ciaempcodant        like    datmservico.ciaempcod,
     ciaempsgl           char    (40)
 end record
 
 define param record
     usrtip              char    (1),
     webusrcod           char    (6),
     sesnum              char    (10),
     macsissgl           char    (10)
 end record
 
 define ws2 record
     statusprc           dec     (1,0),
     sestblvardes1       char    (256),
     sestblvardes2       char    (256),
     sestblvardes3       char    (256),
     sestblvardes4       char    (256),
     sespcsprcnom        char    (256),
     prgsgl              char    (256),
     acsnivcod           dec     (1,0),
     webprscod           dec     (16,0)
 end record
 
 define d_wdatc045 record
     atdsrvorg           like    datmservico.atdsrvorg,
     atdsrvnum           char    (8),
     atdsrvano           char    (2),
     atddat              like    datmservico.atddat,
     atdhor              like    datmservico.atdhor,
     ciaempcod           like    datmservico.ciaempcod
 end record
 
 define l_acihor record
        atddat  like datmsrvacp.atdetpdat ,
        atdhor  like datmsrvacp.atdetphor
 end record
   
 define l_anlokaflg     like dbsmsrvacr.anlokaflg
 define l_risldostt     like dpamris.risldostt #=> PSI.188751
 define l_solicris      char(21)                #=> PSI.188751
 define l_link          char(300)              #=> PSI.188751
 
 define l_ret           smallint                                   
 define l_mensagem      char(100)
 define m_psaerrcod     integer

 initialize ws.*         to null
 initialize param.*      to null
 initialize ws2.*        to null
 initialize d_wdatc045   to null
 initialize l_acihor     to null

 initialize l_anlokaflg     to null
 initialize l_risldostt     to null
 initialize l_solicris      to null
 initialize l_link          to null
 
 initialize l_ret           to null
 initialize l_mensagem      to null
 initialize m_psaerrcod  to null
 
 let param.usrtip        = arg_val(1)
 let param.webusrcod     = arg_val(2)
 let param.sesnum        = arg_val(3)
 let param.macsissgl     = arg_val(4)
 
 #------------------------------------------
 #  ABRE BANCO   (TESTE ou PRODUCAO)
 #------------------------------------------
 call fun_dba_abre_banco("CT24HS")
 set isolation to dirty read
 
 #---------------------------------------------
 #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
 #---------------------------------------------
 
 call wdatc002(param.usrtip,
               param.webusrcod,
               param.sesnum,
               param.macsissgl)
               returning ws2.*
 
 if ws2.statusprc <> 0 then
     display "NOSESS@@Por quest\365es de seguran\347a seu tempo de<BR> permanência nesta p\341gina atingiu o limite m\341ximo.@@"
     exit program(0)
 end if
 
 #----------------------------------------------
 #  Prepara comandos SQL
 #----------------------------------------------
 let ws.comando = "select datmservico.atdsrvorg,     ",
                  "       dbsmsrvacr.atdsrvnum,     ",
                  "       dbsmsrvacr.atdsrvano,     ",
                  "       datmservico.atddat,        ",
                  "       datmservico.atdhor,        ",
                  "       dbsmsrvacr.anlokaflg,      ",
                  "       datmservico.ciaempcod      ",
                  "  from dbsmsrvacr,                ",
                  "       datmservico                ",
                  " where dbsmsrvacr.pstcoddig = ?   ",
                  "   and (dbsmsrvacr.prsokaflg = 'N'",
                  "     or dbsmsrvacr.anlokaflg = 'P')",
                  "   and dbsmsrvacr.atdsrvnum = datmservico.atdsrvnum",
                  "   and dbsmsrvacr.atdsrvano = datmservico.atdsrvano",
                  "   and dbsmsrvacr.pstcoddig = datmservico.atdprscod",
                  " order by ciaempcod, dbsmsrvacr.atdsrvano, dbsmsrvacr.atdsrvnum"
 prepare sel_servicos from ws.comando
 declare c_servicos cursor for sel_servicos
 
 #=> PSI.188751 - PREPARA ACESSO A 'DPAMRIS'
 let ws.comando = "select risldostt",
                  "  from dpamris",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?"
 prepare pwdatc0450101 from ws.comando
 declare cwdatc0450101 cursor for pwdatc0450101

 let ws.comando = "select srvtipabvdes ",
                  "  from datksrvtip ",
                  " where atdsrvorg = ? "
 prepare pwdatc0450102 from ws.comando
 declare cwdatc0450102 cursor for pwdatc0450102
 
 # buscar data/hora do acionamento do servico
 let ws.comando = " select atdetpdat, atdetphor " ,
                  " from datmsrvacp " ,
                  " where atdsrvnum = ? " ,
                  "   and atdsrvano = ? " ,
                  "   and atdsrvseq = ( select max(atdsrvseq) " ,
                                      " from datmsrvacp " ,
                                      " where atdsrvnum = ? " ,
                                      "   and atdsrvano = ? " ,
                                      "   and atdetpcod in (4,3,10) ) "
 prepare pwdatc0450103 from ws.comando
 declare cwdatc0450103 cursor for pwdatc0450103
 
 let ws.ciaempcodant = 0
 open c_servicos using ws2.webprscod
 foreach c_servicos
     into d_wdatc045.atdsrvorg,
          d_wdatc045.atdsrvnum,
          d_wdatc045.atdsrvano,
          d_wdatc045.atddat,
          d_wdatc045.atdhor,
          l_anlokaflg,
          d_wdatc045.ciaempcod

     initialize m_psaerrcod  to null
     
     if d_wdatc045.ciaempcod <> ws.ciaempcodant then 
        initialize ws.ciaempsgl to null                         
        # Pesquisa a empresa do servico para exibir no cabecalho
        call cty14g00_empresa(1, d_wdatc045.ciaempcod)                  
             returning l_ret,                                   
                       l_mensagem,                              
                       ws.ciaempsgl     
                       
        call cts59g00_idt_srv_saps(1, d_wdatc045.atdsrvnum, d_wdatc045.atdsrvano) returning m_psaerrcod
    
        if m_psaerrcod = 0
           then
           let ws.ciaempsgl = 'SERVIÇOS AVULSOS PORTO SEGURO' 
        end if
        
        if l_ret <> 1 then                                      
           let ws.ciaempsgl = ""                                
        else                                                    
           let ws.ciaempsgl = " - ", ws.ciaempsgl               
        end if
                                                        
        display "PADRAO@@1@@B@@C@@0@@Serviços Pendentes de Acerto", ws.ciaempsgl clipped, "@@"
        display "PADRAO@@6@@5",
                "@@N@@C@@0@@1@@20%@@Serviço@@",
                "@@N@@C@@0@@1@@20%@@Tipo@@",
                "@@N@@C@@0@@1@@20%@@Data@@",
                "@@N@@C@@0@@1@@20%@@Hora@@",
                "@@N@@C@@0@@1@@20%@@Solicita RIS@@",
                "@@"
        let ws.ciaempcodant = d_wdatc045.ciaempcod
     end if  
      
     let ws.servico = F_FUNDIGIT_INTTOSTR(d_wdatc045.atdsrvnum,7),
                      "/",
                      F_FUNDIGIT_INTTOSTR(d_wdatc045.atdsrvano,2)

     open  cwdatc0450102 using d_wdatc045.atdsrvorg
     fetch cwdatc0450102  into ws.srvtipabvdes
     close cwdatc0450102

     #=> PSI.188751 - ACESSAR 'DPAMRIS'
     whenever error continue
     open  cwdatc0450101 using d_wdatc045.atdsrvnum,
                               d_wdatc045.atdsrvano
     fetch cwdatc0450101  into l_risldostt
     whenever error stop
     if sqlca.sqlcode = 0 then
     if l_risldostt <> 0 then     #PSI 188751 
        let l_solicris = "SIM *" 
     else
        let l_solicris = "SIM&nbsp;&nbsp;&nbsp;" 
     end if 
     else
        if sqlca.sqlcode = notfound then
           let l_risldostt = 9
           let l_solicris  = "NÃO&nbsp;&nbsp;&nbsp;"
        else
           display "ERRO@@Problemas no acesso ao Laudo RIS...",
                   sqlca.sqlcode, " ", sqlca.sqlerrd[2]
           exit program(0)
        end if
     end if
     
     initialize l_acihor.* to null
     
     # buscar data/hora do acionamento do servico
     whenever error continue
     open cwdatc0450103 using d_wdatc045.atdsrvnum, d_wdatc045.atdsrvano,
                              d_wdatc045.atdsrvnum, d_wdatc045.atdsrvano
     fetch cwdatc0450103 into l_acihor.atddat, l_acihor.atdhor
     whenever error stop
     
     if l_acihor.atddat is not null and
        l_acihor.atdhor is not null
        then
        let d_wdatc045.atddat = l_acihor.atddat
        let d_wdatc045.atdhor = l_acihor.atdhor
     end if
     
     #=> PSI.188751 - MONTA 'LINK' CONFORME O CASO
     if l_risldostt = 0 then
        let l_link =  "/ris/preencherlaudoris.do",
                         "?usrtip=",    param.usrtip clipped,
                         "&webusrcod=", param.webusrcod clipped,
                         "&sesnum=",    param.sesnum using "<<<<<<<<&",
                         "&macsissgl=", param.macsissgl clipped,
                         "&atdsrvnum=", d_wdatc045.atdsrvnum using "<<<<<<<<&",
                         "&atdsrvano=", d_wdatc045.atdsrvano clipped,
                         "&atdsrvorg=", d_wdatc045.atdsrvorg using "<<<<<<<<&",
                         "&atddat=",   d_wdatc045.atddat clipped
     else
         if l_anlokaflg = 'N' then
            let l_link = "wdatc046.pl",
                         "?usrtip=",    param.usrtip clipped,
                         "&webusrcod=", param.webusrcod clipped,
                         "&sesnum=",    param.sesnum clipped,
                         "&macsissgl=", param.macsissgl clipped,
                         "&atdsrvnum=", d_wdatc045.atdsrvnum clipped,
                         "&atdsrvano=", d_wdatc045.atdsrvano clipped
         else
             let l_link = "wdatc048.pl",
                          "?usrtip=",    param.usrtip clipped,
                          "&webusrcod=", param.webusrcod clipped,
                          "&sesnum=",    param.sesnum clipped,
                          "&macsissgl=", param.macsissgl clipped,
                          "&atdsrvnum=", d_wdatc045.atdsrvnum clipped,
                          "&atdsrvano=", d_wdatc045.atdsrvano clipped,
                          "&c24pbmgrpcod=0",
                          "&ufdcod=XR"
         end if
     end if

     #=> PSI.188751 - MONTA LINHA DA TABELA A SER EXIBIDA
     display "PADRAO@@6@@5",
             "@@N@@C@@1@@1@@20%@@", ws.servico, "@@", l_link clipped,
             "@@N@@C@@1@@1@@20%@@", ws.srvtipabvdes, "@@",
             "@@N@@C@@1@@1@@20%@@", d_wdatc045.atddat, "@@",
             "@@N@@C@@1@@1@@20%@@", d_wdatc045.atdhor, "@@",
             "@@N@@C@@1@@1@@20%@@", l_solicris, "@@",
             "@@"
 end foreach
 
 if ws.ciaempcodant = 0 then
     display "PADRAO@@1@@B@@C@@1@@Nenhum serviço pendente de acerto@@"
 end if
 
 #------------------------------------
 # ATUALIZA TEMPO DE SESSAO DO USUARIO
 #------------------------------------
 call wdatc003(param.usrtip,
               param.webusrcod,
               param.sesnum,
               param.macsissgl,
               ws2.*)
     returning ws.sttsess
 
end main
