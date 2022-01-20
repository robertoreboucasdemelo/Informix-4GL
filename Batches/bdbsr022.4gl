# --------------------------------------------------------------------------#
# Nome do Modulo: bdbsr022                                         Marcelo  #
#                                                                  Gilberto # 
# Relacao semanal de reservas                                      Ago/1995 #
# --------------------------------------------------------------------------#
# Alteracoes:                                                               # 
#                                                                           # 
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           # 
#---------------------------------------------------------------------------#   
# 18/09/2001  PSI 13552-6  Wagner       Modificacao total na estrutura do   #
#                                       modulo e envio por e-mail.          #
#---------------------------------------------------------------------------#   
# 01/10/2002  Correio      Wagner       Troca de e-mail Francisco Castro p/ #
#                                       Roberto Costa.                      #
# --------------------------------------------------------------------------#
# 16/03/2004 OSF 33367     Teresinha S. Inclusao de case ws.avialgmtv = 6   #
# --------------------------------------------------------------------------#
# 18/03/2010 CT764230      Beatriz A.   Tirar a verificação de primeira vez #
#                                       para resolucao do chamado           #
# --------------------------------------------------------------------------#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# --------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# ---------- --------------------- ------ ------------------------------------#
# 16/12/2006 Ruiz                  205206 Alteracao para azul seguros.        #
# ---------- --------------------- ------ ------------------------------------#
# 14/02/2007 Fabiano, Meta      AS 130087 Migracao para a versao 7.32         #
# ---------- --------------------- ------ ------------------------------------#
# 08/05/2015 Fornax, RCP           080515 Incluir coluna data no relatorio.   #
#                                                                             #
###############################################################################

database porto                               

 define ws_datade     date
 define ws_dataate    date
 define ws_auxdat     char (10)
 define ws_flgcab     smallint   
 define m_path        char(100)
 define m_path_txt1   char(100)
 define m_path_txt2   char(100)

 main

    call fun_dba_abre_banco("CT24HS") 

    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped,"/bdbsr022.log"

    call startlog(m_path)
                                                  # Marcio Meta - PSI185035
    call bdbsr022()
 end main

#---------------------------------------------------------------
 function bdbsr022()   
#---------------------------------------------------------------

 define d_bdbsr022    record
    lcvcod            like datklocadora.lcvcod    ,
    lcvnom            like datklocadora.lcvnom    ,
    lcvextcod         like datkavislocal.lcvextcod,
    aviestnom         like datkavislocal.aviestnom,
    atdsrvnum         like datmservico.atdsrvnum  ,  
    atdsrvano         like datmservico.atdsrvano  ,  
    empsgl            like gabkemp.empsgl         ,
    succod            like datrservapol.succod    ,
    aplnumdig         like datrservapol.aplnumdig ,
    itmnumdig         like datrservapol.itmnumdig ,
    atddat            like datmservico.atddat     , 
    avilocnom         like datmavisrent.avilocnom ,
    avivclgrp         like datkavisveic.avivclgrp ,
    avialgmtv         like datmavisrent.avialgmtv ,
    mtvdes            char (20)                   ,
    clscod            char (03)                   ,
    aviprvent2        like datmavisrent.aviprvent , # previsao utilizacao
    aviprodiaqtd      like datmprorrog.aviprodiaqtd, # somatoria das prorrogacoes
    aviprvent         like datmavisrent.aviprvent ,
    avidiaqtd         like datmavisrent.avidiaqtd ,
    socopgitmvlr      like dbsmopgitm.socopgitmvlr, 
    atdetpdes         like datketapa.atdetpdes    ,  
    endufd            like datklocadora.endufd    ,   # Franzon
    cidnom            like datklocadora.cidnom    ,   # Franzon
    ufdcod            like datmlcl.ufdcod         ,   # Franzon
    cidnom_oc         like datmlcl.cidnom         ,   # Franzon
    lcvregprccod      like datkavislocal.lcvregprccod,# Franzon
    lcvregprcdes      char(10),                       # Franzon
    socfatpgtdat      like dbsmopg.socfatpgtdat       #--> FX-080515
 end record

 define ws            record
    atdetpcod         like datmsrvacp.atdetpcod    ,
    edsnumref         like datrservapol.edsnumref  ,
    avivclcod         like datmavisrent.avivclcod  ,
    aviestcod         like datmavisrent.aviestcod  ,
    avialgmtv         like datmavisrent.avialgmtv  , 
    avioccdat         like datmavisrent.avioccdat  ,   
    atdfnlflg         like datmservico.atdfnlflg   ,   
    c24utidiaqtd      like dbsmopgitm.c24utidiaqtd , 
    c24pagdiaqtd      like dbsmopgitm.c24pagdiaqtd , 
    sql               char (500)                   ,
    privez            smallint                     ,
    sldprivez         smallint                     ,
    sldqtd            smallint                     ,
    viginc            like abbmclaus.viginc        ,
    vigfnl            like abbmclaus.vigfnl        ,
    aviprodiaqtd      like datmprorrog.aviprodiaqtd,
    dirfisnom         like ibpkdirlog.dirfisnom    ,
    contador          smallint                     ,
    datasaldo         date                         ,
    rodar             char (500)                   ,
    ciaempcod         like datmservico.ciaempcod   , 
    temcls            smallint
 end record

 define ws_pathrel01  char (60)   
 define ws_pathrel02  char (60)  
 define l_retorno     smallint
 define l_data        date
 define l_dataarq     char(8)

 let ws.sql  = " select sum(aviprodiaqtd) ",
               "   from datmprorrog       ",
               "  where atdsrvnum = ?     ",
               "    and atdsrvano = ?     ",
               "    and aviprostt = 'A'   "
 prepare select_prorrog   from ws.sql
 declare c_prorrog cursor for  select_prorrog

 let ws.sql  = " select lcvextcod, aviestnom ",
               "   from datkavislocal        ",
               "  where lcvcod = ? and aviestcod = ?"
 prepare select_local     from ws.sql
 declare c_local   cursor for  select_local  
 
 let ws.sql  = " select avivclgrp     ",
               "   from datkavisveic  ",
               "  where lcvcod    = ? ",
               "    and avivclcod = ? "
 prepare select_veic      from ws.sql
 declare c_veic    cursor for  select_veic   
 
 let ws.sql   = " select lcvnom       ",
                "       ,endufd       ", #Franzon
                "       ,cidnom       ", #Franzon
                "   from datklocadora ",
                "  where lcvcod = ?   "
 prepare select_locadora   from ws.sql
 declare c_locadora cursor for  select_locadora

#Franzon inicio - ocorrencia
 let ws.sql   = " select ufdcod       ", #Franzon
                "       ,cidnom       ", #Franzon
                "   from datmlcl ",
                "  where c24endtip = 1  "
 prepare select_ocorrencia   from ws.sql
 declare c_ocorrencia cursor for  select_ocorrencia

# - motivo  itau

 let ws.sql   = " select itarsrcaomtvdes ", 
                "   from datkitarsrcaomtv ",
                "  where itarsrcaomtvcod = ? "
 prepare select_motivoItau   from ws.sql
 declare c_motivoItau cursor for  select_motivoItau

# - tarifa 

 let ws.sql   = " select lcvregprccod  ", 
                "   from datkavislocal ",
                "  where lcvcod    = ? ",
                "  and   aviestcod = ? "
 prepare select_tarifa   from ws.sql
 declare c_tarifa cursor for  select_tarifa

#Franzon  fim

 let ws.sql   = "select atdetpcod    ",
                "  from datmsrvacp   ",
                " where atdsrvnum = ?",
                "   and atdsrvano = ?",
                "   and atdsrvseq = (select max(atdsrvseq)", 
                                    "  from datmsrvacp    ", 
                                    " where atdsrvnum = ? ", 
                                    "   and atdsrvano = ?)" 
 prepare sel_datmsrvacp from ws.sql 
 declare c_datmsrvacp cursor for sel_datmsrvacp

 let ws.sql   = "select atdetpdes    ",
                "  from datketapa    ",
                " where atdetpcod = ?"
 prepare sel_datketapa from ws.sql      
 declare c_datketapa cursor for sel_datketapa
 
 let ws.sql   = "select empsgl    ",
                "  from datmservico a, ",
                "       gabkemp b",
                " where a.atdsrvnum = ? ",
                "   and a.atdsrvano = ? ",
                "   and a.ciaempcod = b.empcod"
                
 prepare sel_datmservico from ws.sql      
 declare c_datmservico cursor for sel_datmservico
 
 let ws.sql = ' select cpodes ',              
              '   from iddkdominio ',         
              '  where cponom = "avialgmtv" ',
              '    and cpocod = ? '           
                                                 
 prepare sel_iddkdominio from ws.sql             
 declare c_iddkdominio cursor for sel_iddkdominio    
 
 
 
 
 
#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------
 initialize d_bdbsr022.*  to null
 initialize ws.*          to null
 
 let ws.privez    = true 
 let ws.sldprivez = true 
 let ws_flgcab    = 0
 
#---------------------------------------------------------------
# Data para execucao
#---------------------------------------------------------------
 let ws_auxdat = arg_val(1)       

 if ws_auxdat is null  or  
    ws_auxdat =  "  "  then
    let ws_auxdat = today 
 else
    if length(ws_auxdat) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws_auxdat   = "01","/", ws_auxdat[4,5],"/", ws_auxdat[7,10]   
 let ws_dataate = ws_auxdat
 let ws_dataate = ws_dataate - 1 units day  

 let ws_auxdat   = ws_dataate
 let ws_auxdat   = "01","/", ws_auxdat[4,5],"/", ws_auxdat[7,10]   
 let ws_datade  = ws_auxdat

 let l_data = today
 let l_dataarq = extend(l_data, year to year),
                 extend(l_data, month to month),
                 extend(l_data, day to day)  
  

#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DBS", "ARQUIVO")                            # Marcio Meta - PSI185035
    returning ws.dirfisnom
 
 if ws.dirfisnom is null then
   let ws.dirfisnom = "."
 end if 
 
  let m_path_txt1 =  ws.dirfisnom clipped, "/RDBS022_0104_", l_dataarq, ".txt"  
  let m_path_txt2 =  ws.dirfisnom clipped, "/RDBS022_0204_", l_dataarq, ".txt"  
                                                           
  let ws_pathrel01 = ws.dirfisnom clipped, "/RDBS02201", ws_auxdat[4,5],".TXT"
  let ws_pathrel02 = ws.dirfisnom clipped, "/RDBS02202", ws_auxdat[4,5],".TXT"
#WWW let ws_pathrel01 = "/rdat/RDAT02201", ws_auxdat[4,5],".TXT"
#WWW let ws_pathrel02 = "/rdat/RDAT02202", ws_auxdat[4,5],".TXT"
                                                          # Marcio Meta - PSI185035
#---------------------------------------------------------------
# Cursor principal ATENDIDOS
#---------------------------------------------------------------

 declare  c_bdbsr022a  cursor for 
    select datmavisrent.lcvcod   , datmavisrent.aviestcod, 
           datmservico.atdsrvnum , datmservico.atdsrvano ,
           datmservico.ciaempcod ,
           datrservapol.succod   , datrservapol.aplnumdig, 
           datrservapol.itmnumdig, datrservapol.edsnumref, 
           datmservico.atddat    , datmavisrent.avilocnom, 
           datmavisrent.aviprvent, datmavisrent.avidiaqtd, 
           datmavisrent.avialgmtv, datmavisrent.avivclcod,  
           datmavisrent.avioccdat, datmservico.atdfnlflg
      from datmservico, outer datrservapol, outer datmavisrent
     where datmservico.atddat between ws_datade and ws_dataate 
       and datmservico.atdsrvorg  = 8                         
       and datrservapol.atdsrvnum = datmservico.atdsrvnum    
       and datrservapol.atdsrvano = datmservico.atdsrvano   
       and datmavisrent.atdsrvnum = datmservico.atdsrvnum  
       and datmavisrent.atdsrvano = datmservico.atdsrvano

 start report  rel_bdbsr022  to  ws_pathrel01
 start report  rel_bdbsr022_txt  to  m_path_txt1

 foreach c_bdbsr022a into  d_bdbsr022.lcvcod   , ws.aviestcod        , 
                           d_bdbsr022.atdsrvnum, d_bdbsr022.atdsrvano,
                           ws.ciaempcod        ,
                           d_bdbsr022.succod   , d_bdbsr022.aplnumdig, 
                           d_bdbsr022.itmnumdig, ws.edsnumref        , 
                           d_bdbsr022.atddat   , d_bdbsr022.avilocnom,
                           d_bdbsr022.aviprvent, d_bdbsr022.avidiaqtd, 
                           #ws.avialgmtv        , ws.avivclcod        ,
                           d_bdbsr022.avialgmtv        , ws.avivclcod        ,
                           ws.avioccdat        , ws.atdfnlflg

    #--------------------------------------------------------
    # Previsao de utilizacao
    #--------------------------------------------------------
    let d_bdbsr022.aviprvent2 = d_bdbsr022.aviprvent
      
    #--------------------------------------------------------
    # Etapa
    #--------------------------------------------------------
    if ws.atdfnlflg = "N"  then
       continue foreach
    end if
    open  c_datmsrvacp using d_bdbsr022.atdsrvnum, d_bdbsr022.atdsrvano,
                             d_bdbsr022.atdsrvnum, d_bdbsr022.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if sqlca.sqlcode = 0  then
       open  c_datketapa using ws.atdetpcod
       fetch c_datketapa into  d_bdbsr022.atdetpdes 
       close c_datketapa
      else
       let d_bdbsr022.atdetpdes = "N/PREVISTO"  
    end if

    #--------------------------------------------------------
    # Quantidade de prorrogacoes / somatoria das reservas
    #--------------------------------------------------------
    let ws.aviprodiaqtd = 0
    let d_bdbsr022.aviprodiaqtd = 0
    
    open  c_prorrog using d_bdbsr022.atdsrvnum,
                          d_bdbsr022.atdsrvano
    fetch c_prorrog into  ws.aviprodiaqtd
    close c_prorrog

    if ws.aviprodiaqtd is not null  then
       let d_bdbsr022.aviprvent = d_bdbsr022.aviprvent + ws.aviprodiaqtd
       let d_bdbsr022.aviprodiaqtd = ws.aviprodiaqtd
    end if

    #--------------------------------------------------------
    # Dados da locadora
    #--------------------------------------------------------
    open  c_locadora using d_bdbsr022.lcvcod
    fetch c_locadora into  d_bdbsr022.lcvnom
       if sqlca.sqlcode = notfound  then
          let d_bdbsr022.lcvnom = "*** LOCADORA NAO CADASTRADA! ***"
       end if 
    close c_locadora

    #--------------------------------------------------------
    # Dados da loja
    #--------------------------------------------------------
    open  c_local using d_bdbsr022.lcvcod   , ws.aviestcod 
    fetch c_local into  d_bdbsr022.lcvextcod, d_bdbsr022.aviestnom
       if sqlca.sqlcode = notfound  then
          let d_bdbsr022.aviestnom = "*** LOJA NAO CADASTRADA! ***"
       end if 
    close c_local 

    #--------------------------------------------------------
    # Dados grupo do veiculo
    #--------------------------------------------------------
    open  c_veic using d_bdbsr022.lcvcod, ws.avivclcod
    fetch c_veic into  d_bdbsr022.avivclgrp
       if sqlca.sqlcode = notfound  then
          let d_bdbsr022.avivclgrp = "-"                      
       end if 
    close c_veic
    
    
    #--------------------------------------------------------
    # Dados Empresa
    #--------------------------------------------------------
    open c_datmservico using d_bdbsr022.atdsrvnum,
                             d_bdbsr022.atdsrvano
    fetch c_datmservico into d_bdbsr022.empsgl
       if sqlca.sqlcode = notfound  then
          let d_bdbsr022.empsgl = "-"                      
       end if 
    close c_datmservico
    
    #--------------------------------------------------------
    # Definicao do motivo
    #--------------------------------------------------------
    open c_iddkdominio using d_bdbsr022.avialgmtv #ws.avialgmtv
   
    whenever error continue
    fetch c_iddkdominio into d_bdbsr022.mtvdes
    whenever error stop
   
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          let d_bdbsr022.mtvdes = null
       else
          error 'Erro SELECT c_iddkdominio:',sqlca.sqlcode
       end if
    end if  # PSI 999999 Adriano Santos
    close c_iddkdominio # PSI 999999 Adriano Santos
    
    #case ws.avialgmtv
    #   when 1   let d_bdbsr022.mtvdes = "SINISTRO"
    #   when 2   let d_bdbsr022.mtvdes = "SOCORRO"
    #   when 3   let d_bdbsr022.mtvdes = "OFICINA"
    #            if ws.ciaempcod = 35 then
    #               let d_bdbsr022.mtvdes = "BENEFICIO"
    #            end if
    #   when 4   let d_bdbsr022.mtvdes = "DEPTOS."
    #   when 5   let d_bdbsr022.mtvdes = "PARTICUL"
    #   when 6   let d_bdbsr022.mtvdes = "TERC.SEG" -- OSF 33367
    #   when 9   let d_bdbsr022.mtvdes = "IND.INTEGRAL"
    #end case # PSI 999999 Adriano Santos
    
    
    #--------------------------------------------------
    # Verificacao da existencia de clausula Carro Extra
    #--------------------------------------------------
    let ws.datasaldo = d_bdbsr022.atddat  
    if d_bdbsr022.avialgmtv = 1 then #ws.avialgmtv = 1 then
       let ws.datasaldo = ws.avioccdat        
    end if     
    if d_bdbsr022.succod     is not null    and
       d_bdbsr022.aplnumdig  is not null    and
       d_bdbsr022.itmnumdig  is not null    then
       if ws.ciaempcod =  35 then
          call cts44g01_claus_azul(d_bdbsr022.succod   ,
                                   531                 ,
                                   d_bdbsr022.aplnumdig,
                                   d_bdbsr022.itmnumdig)
                 returning ws.temcls,d_bdbsr022.clscod
       else   
          call ctx01g01_claus_novo (d_bdbsr022.succod   , 
                                    d_bdbsr022.aplnumdig, 
                                    d_bdbsr022.itmnumdig,   
                                    ws.datasaldo        , 
                                    ws.privez,
                                    "") #alterado jair - verificar o porque em producao pede mais um parametro
                         returning  d_bdbsr022.clscod,
                                    ws.viginc, ws.vigfnl
       end if 
       ## inibido pelo CT764230- Beatriz Araujo
       ##if ws.privez = true  then
       ##   let ws.privez = false
       ##end if
       ##fim
    end if 

    #if d_bdbsr022.clscod is not null and 
    #   d_bdbsr022.avivclgrp = "A"    and   
    #   ws.avialgmtv         =  1     then
    #   call ctx01g00_saldo (d_bdbsr022.succod   ,
    #                        d_bdbsr022.aplnumdig,
    #                        d_bdbsr022.itmnumdig,
    #                        d_bdbsr022.atdsrvnum,
    #                        d_bdbsr022.atdsrvano,
    #                        ws.datasaldo, 2,
    #                        ws.sldprivez,
    #                        ws.ciaempcod)
    #             returning  ws.sldqtd
    #
    #   if ws.sldqtd > 0  then
    #      let d_bdbsr022.mtvdes = "CLAUSULA"
    #   end if 
    #end if # PSI 999999 Adriano Santos

    let d_bdbsr022.socopgitmvlr = 0  
    let d_bdbsr022.mtvdes = d_bdbsr022.avialgmtv using '<&', '-', d_bdbsr022.mtvdes

  # output to report rel_bdbsr022(d_bdbsr022.*)    #--> FX-080515
    output to report rel_bdbsr022(d_bdbsr022.*,"") #--> FX-080515
    output to report rel_bdbsr022_txt(d_bdbsr022.*,"")
    
    initialize d_bdbsr022.*       to null

 end foreach

 finish report  rel_bdbsr022 
 finish report  rel_bdbsr022_txt
 #------------------------------------------------------------------
 # E-MAIL PORTO SOCORRO
 #------------------------------------------------------------------
                                                             # Marcio Meta - PSI185035
  let ws.rodar = 'Carro-Extra mensal atendidos - ', ws_datade, ' a ', ws_dataate
  
  let l_retorno = ctx22g00_envia_email('BDBSR022',
                                       ws.rodar,
                                       ws_pathrel01)
  if l_retorno <> 0 then
     if l_retorno <> 99 then
        display " Erro ao enviar email(ctx22g00)-",ws_pathrel01
     else
        display " Email nao encontrado para este modulo BDBSR022 "
     end if
  end if                                       
                                                            # Marcio Meta - PSI185035
# let ws.rodar =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'Carro-Extra mensal atendidos: ",ws_auxdat[4,5],"/", 
#                ws_auxdat[7,10], "' ",
#               "costa_roberto/spaulo_psocorro_qualidade@u23 < ",
#               ws_pathrel01 clipped
# run ws.rodar
#
# let ws.rodar =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'Carro-Extra mensal atendidos: ",ws_auxdat[4,5],"/", 
#                ws_auxdat[7,10], "' ",
#               "agostinho_wagner/spaulo_info_sistemas@u55 < ",
#               ws_pathrel01 clipped
# run ws.rodar
#
#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------
 initialize d_bdbsr022.*  to null
 initialize ws.*          to null
 
 let ws.privez    = true 
 let ws.sldprivez = true 
 let ws_flgcab    = 0   

#---------------------------------------------------------------
# Cursor principal PAGOS      
#---------------------------------------------------------------

 declare  c_bdbsr022b  cursor for 
    select datmavisrent.lcvcod    , datmavisrent.aviestcod , 
           datmservico.atdsrvnum  , datmservico.atdsrvano  ,
           datmservico.ciaempcod  ,
           datmservico.atddat     , datmavisrent.avilocnom , 
           datmavisrent.aviprvent , datmavisrent.avidiaqtd , 
           datmavisrent.avialgmtv , datmavisrent.avivclcod ,    
           dbsmopgitm.socopgitmvlr, dbsmopgitm.c24utidiaqtd,
           dbsmopgitm.c24pagdiaqtd, datmavisrent.avioccdat ,  
	   dbsmopg.socfatpgtdat #--> FX-080515
      from dbsmopg, dbsmopgitm, datmservico, datmavisrent
     where dbsmopg.socfatpgtdat between ws_datade and ws_dataate 
       and dbsmopg.socopgsitcod   =   7                  
       and dbsmopg.soctip         =   2                  
       and dbsmopgitm.socopgnum   = dbsmopg.socopgnum     
       and datmservico.atdsrvnum  = dbsmopgitm.atdsrvnum  
       and datmservico.atdsrvano  = dbsmopgitm.atdsrvano  
       and datmavisrent.atdsrvnum = dbsmopgitm.atdsrvnum  
       and datmavisrent.atdsrvano = dbsmopgitm.atdsrvano        

 start report  rel_bdbsr022  to  ws_pathrel02
 start report  rel_bdbsr022_txt  to  m_path_txt2

 foreach c_bdbsr022b into  d_bdbsr022.lcvcod      , ws.aviestcod        , 
                           d_bdbsr022.atdsrvnum   , d_bdbsr022.atdsrvano,
                           ws.ciaempcod           ,
                           d_bdbsr022.atddat      , d_bdbsr022.avilocnom,
                           d_bdbsr022.aviprvent   , d_bdbsr022.avidiaqtd, 
                           #ws.avialgmtv           , ws.avivclcod        ,
                           d_bdbsr022.avialgmtv   , ws.avivclcod        ,
                           d_bdbsr022.socopgitmvlr, ws.c24utidiaqtd     ,
                           ws.c24pagdiaqtd        , ws.avioccdat        ,
                           d_bdbsr022.socfatpgtdat #--> FX-080515
    #--------------------------------------------------------
    # Dados da apolice                       
    #--------------------------------------------------------
    select datrservapol.succod   , datrservapol.aplnumdig, 
           datrservapol.itmnumdig, datrservapol.edsnumref 
      into d_bdbsr022.succod     , d_bdbsr022.aplnumdig, 
           d_bdbsr022.itmnumdig  , ws.edsnumref    
      from datrservapol
     where datrservapol.atdsrvnum = d_bdbsr022.atdsrvnum 
       and datrservapol.atdsrvano = d_bdbsr022.atdsrvano

    if sqlca.sqlcode = notfound then
       initialize d_bdbsr022.succod   , d_bdbsr022.aplnumdig, 
                  d_bdbsr022.itmnumdig, ws.edsnumref  to null   
    end if

    
    #--------------------------------------------------------
    # Previsao de utilizacao
    #--------------------------------------------------------
    let d_bdbsr022.aviprvent2 = d_bdbsr022.aviprvent

    #--------------------------------------------------------
    # Etapa
    #--------------------------------------------------------
    open  c_datmsrvacp using d_bdbsr022.atdsrvnum, d_bdbsr022.atdsrvano,
                             d_bdbsr022.atdsrvnum, d_bdbsr022.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if sqlca.sqlcode = 0  then
       open  c_datketapa using ws.atdetpcod
       fetch c_datketapa into  d_bdbsr022.atdetpdes 
       close c_datketapa
      else
       let d_bdbsr022.atdetpdes = "N/PREVISTO"  
    end if

    #--------------------------------------------------------
    # Quantidade de prorrogacoes / somatoria das reservas
    #--------------------------------------------------------
    let d_bdbsr022.aviprodiaqtd = 0
    
    open  c_prorrog using d_bdbsr022.atdsrvnum,
                          d_bdbsr022.atdsrvano
    fetch c_prorrog into  ws.aviprodiaqtd
    close c_prorrog

    if ws.aviprodiaqtd is not null  then
       let d_bdbsr022.aviprodiaqtd = ws.aviprodiaqtd
    end if

    #--------------------------------------------------------
    # Dados da locadora
    #--------------------------------------------------------
    open  c_locadora using d_bdbsr022.lcvcod
    fetch c_locadora into  d_bdbsr022.lcvnom   
                          ,d_bdbsr022.endufd    #Franzon
                          ,d_bdbsr022.cidnom    #Franzon
       if sqlca.sqlcode = notfound  then
          let d_bdbsr022.lcvnom = "*** LOCADORA NAO CADASTRADA! ***"
       end if 
    close c_locadora

# Franzon inicio 

    #--------------------------------------------------------
    # Dados do local da ocorrencia
    #--------------------------------------------------------
    open  c_ocorrencia 
    fetch c_ocorrencia into  d_bdbsr022.ufdcod   
                            ,d_bdbsr022.cidnom_oc 
       if sqlca.sqlcode = notfound  then
          let d_bdbsr022.lcvnom = "*** OCORRENCIA NAO CADASTRADA! ***"
       end if 
    close c_ocorrencia

    #--------------------------------------------------------
    # Dados da tarifa
    #--------------------------------------------------------
    open  c_tarifa  using d_bdbsr022.lcvcod
                         ,ws.aviestcod
    fetch c_tarifa into  d_bdbsr022.lcvregprccod   
       if sqlca.sqlcode = notfound  then
          let d_bdbsr022.lcvnom = "*** TARIFA NAO CADASTRADA! ***"
       end if 
    close c_tarifa

    case d_bdbsr022.lcvregprccod
         when 1    let d_bdbsr022.lcvregprcdes = "PADRAO     "
         when 2    let d_bdbsr022.lcvregprcdes = "REGIAO II  "
         when 3    let d_bdbsr022.lcvregprcdes = "** LIVRE **"
         otherwise let d_bdbsr022.lcvregprcdes = d_bdbsr022.lcvregprccod
    end case
#Franzon fim
    #--------------------------------------------------------
    # Dados da loja
    #--------------------------------------------------------
    open  c_local using d_bdbsr022.lcvcod   , ws.aviestcod 
    fetch c_local into  d_bdbsr022.lcvextcod, d_bdbsr022.aviestnom
       if sqlca.sqlcode = notfound  then
          let d_bdbsr022.aviestnom = "*** LOJA NAO CADASTRADA! ***"
       end if 
    close c_local 

    #--------------------------------------------------------
    # Dados grupo do veiculo
    #--------------------------------------------------------
    open  c_veic using d_bdbsr022.lcvcod, ws.avivclcod
    fetch c_veic into  d_bdbsr022.avivclgrp
       if sqlca.sqlcode = notfound  then
          let d_bdbsr022.avivclgrp = "-"                      
       end if 
    close c_veic
    
    #--------------------------------------------------------
    # Dados Empresa
    #--------------------------------------------------------
    open c_datmservico using d_bdbsr022.atdsrvnum,
                             d_bdbsr022.atdsrvano
    fetch c_datmservico into d_bdbsr022.empsgl
       if sqlca.sqlcode = notfound  then
          let d_bdbsr022.empsgl = "-"                      
       end if 
    close c_datmservico

    #--------------------------------------------------------
    # Definicao do motivo
    #--------------------------------------------------------

# Franzon inicio
    # identificar empresa Itau
    if ws.ciaempcod = 84 then
        open c_motivoItau using d_bdbsr022.avialgmtv
        
        whenever error continue
        fetch c_motivoItau into d_bdbsr022.mtvdes
        whenever error stop
   
        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = 100 then
              let d_bdbsr022.mtvdes = null
           else
              error 'Erro SELECT c_motivoItau:',sqlca.sqlcode
           end if
        end if  
        close c_motivoItau 
    else # Franzon fim
        open c_iddkdominio using d_bdbsr022.avialgmtv #ws.avialgmtv
   
        whenever error continue
        fetch c_iddkdominio into d_bdbsr022.mtvdes
        whenever error stop
   
        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = 100 then
              let d_bdbsr022.mtvdes = null
           else
              error 'Erro SELECT c_iddkdominio:',sqlca.sqlcode
           end if
        end if  
        close c_iddkdominio # PSI 999999 Adriano Santos
   end if
    #case ws.avialgmtv
    #   when 1   let d_bdbsr022.mtvdes = "SINISTRO"
    #   when 2   let d_bdbsr022.mtvdes = "SOCORRO"
    #   when 3   let d_bdbsr022.mtvdes = "OFICINA"
    #            if ws.ciaempcod = 35 then
    #               let d_bdbsr022.mtvdes = "BENEFICIO"
    #            end if
    #   when 4   let d_bdbsr022.mtvdes = "DEPTOS."
    #   when 5   let d_bdbsr022.mtvdes = "PARTICUL"
    #   when 9   let d_bdbsr022.mtvdes = "REVERSIV"
    #end case # PSI 999999 Adriano Santos     

    #--------------------------------------------------
    # Verificacao da existencia de clausula Carro Extra
    #--------------------------------------------------
    let ws.datasaldo = d_bdbsr022.atddat  
    if d_bdbsr022.avialgmtv = 1 then #if ws.avialgmtv = 1 then
       let ws.datasaldo = ws.avioccdat        
    end if     
    if d_bdbsr022.succod     is not null    and
       d_bdbsr022.aplnumdig  is not null    and
       d_bdbsr022.itmnumdig  is not null    then
       if ws.ciaempcod =  35 then
          call cts44g01_claus_azul(d_bdbsr022.succod   ,
                                   531                 ,
                                   d_bdbsr022.aplnumdig,
                                   d_bdbsr022.itmnumdig)
                 returning ws.temcls,d_bdbsr022.clscod
       else
          call ctx01g01_claus_novo (d_bdbsr022.succod   , 
                                    d_bdbsr022.aplnumdig, 
                                    d_bdbsr022.itmnumdig,   
                                    ws.datasaldo        , 
                                    ws.privez,
                                    "") #alterado jair - verificar o porque em producao pede mais um parametro
                         returning  d_bdbsr022.clscod,
                                    ws.viginc, ws.vigfnl
       end if
       ## inibido pelo CT764230- Beatriz Araujo
       ##if ws.privez = true  then
       ##   let ws.privez = false
       ##end if
       ##fim
    end if 

    #if d_bdbsr022.clscod is not null and 
    #   d_bdbsr022.avivclgrp = "A"    and   
    #   ws.avialgmtv         =  1     then
    #   call ctx01g00_saldo (d_bdbsr022.succod   ,
    #                        d_bdbsr022.aplnumdig,
    #                        d_bdbsr022.itmnumdig,
    #                        d_bdbsr022.atdsrvnum,
    #                        d_bdbsr022.atdsrvano,
    #                        ws.datasaldo, 2,
    #                        ws.sldprivez,
    #                        ws.ciaempcod)
    #             returning  ws.sldqtd
    #
    #   if ws.sldqtd > 0  then
    #      let d_bdbsr022.mtvdes = "CLAUSULA"
    #   end if 
    #end if # PSI 999999 Adriano Santos     

    let d_bdbsr022.aviprvent = ws.c24utidiaqtd  # Qtde.diarias utilizadas
    let d_bdbsr022.avidiaqtd = ws.c24pagdiaqtd  # Qtde.diarias pagas
    let d_bdbsr022.mtvdes = d_bdbsr022.avialgmtv using '<&', '-', d_bdbsr022.mtvdes

  # output to report rel_bdbsr022(d_bdbsr022.*)             #--> FX-080515
    output to report rel_bdbsr022(d_bdbsr022.*,"Data Pag.") #--> FX-080515
    output to report rel_bdbsr022_txt(d_bdbsr022.*,"Data Pag.")

    initialize d_bdbsr022.*       to null

 end foreach

 finish report  rel_bdbsr022
 finish report  rel_bdbsr022_txt
 
 #------------------------------------------------------------------
 # E-MAIL PORTO SOCORRO
 #------------------------------------------------------------------
                                                                # Marcio Meta - PSI185035
  let ws.rodar = 'Carro-Extra mensal pagos - ', ws_datade, ' a ', ws_dataate
 
  let l_retorno = ctx22g00_envia_email('BDBSR022',
                                       ws.rodar,
                                       ws_pathrel02)
  if l_retorno <> 0 then
     if l_retorno <> 99 then
        display " Erro ao enviar email(ctx22g00)-",ws_pathrel02
     else
        display " Email nao encontrado para este modulo BDBSR022 "
     end if
  end if                                       
                                                                # Marcio Meta - PSI185035
#let ws.rodar =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#              " -s 'Carro-Extra mensal pagos: ",ws_auxdat[4,5],"/", 
#               ws_auxdat[7,10], "' ",
#              "costa_roberto/spaulo_psocorro_qualidade@u23 < ",
#              ws_pathrel02 clipped
#run ws.rodar
#
#let ws.rodar =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#              " -s 'Carro-Extra mensal pagos: ",ws_auxdat[4,5],"/", 
#               ws_auxdat[7,10], "' ",
#              "agostinho_wagner/spaulo_info_sistemas@u55 < ",
#              ws_pathrel02 clipped
#run ws.rodar
#
end function  ###  bdbsr022

#---------------------------------------------------------------------------
 report rel_bdbsr022(r_bdbsr022)
#---------------------------------------------------------------------------

 define r_bdbsr022    record
    lcvcod            like datklocadora.lcvcod      ,
    lcvnom            like datklocadora.lcvnom      ,
    lcvextcod         like datkavislocal.lcvextcod  ,
    aviestnom         like datkavislocal.aviestnom  ,
    atdsrvnum         like datmservico.atdsrvnum    ,  
    atdsrvano         like datmservico.atdsrvano    ,
    empsgl            like gabkemp.empsgl           , 
    succod            like datrservapol.succod      ,
    aplnumdig         like datrservapol.aplnumdig   ,
    itmnumdig         like datrservapol.itmnumdig   ,
    atddat            like datmservico.atddat       , 
    avilocnom         like datmavisrent.avilocnom   ,
    avivclgrp         like datkavisveic.avivclgrp   ,
    avialgmtv         like datmavisrent.avialgmtv   ,
    mtvdes            char (20)                     ,
    clscod            char (03)                     ,
    aviprvent2        like datmavisrent.aviprvent   , # previsao utilizacao
    aviprodiaqtd2     like datmprorrog.aviprodiaqtd , # somatoria das prorrogacoes
    aviprvent         like datmavisrent.aviprvent   ,
    avidiaqtd         like datmavisrent.avidiaqtd   ,
    socopgitmvlr      decimal(15,2)                 , 
    atdetpdes         like datketapa.atdetpdes      ,   
    endufd            like datklocadora.endufd      , # Franzon
    cidnom            like datklocadora.cidnom      , # Franzon
    ufdcod            like datmlcl.ufdcod           , # Franzon
    cidnom_oc         like datmlcl.cidnom           , # Franzon
    lcvregprccod      like datkavislocal.lcvregprccod,# Franzon
    lcvregprcdes      char(10)                      , # Franzon
    data              date                          , #--> FX-080515
    data_cabec        char(50)                        #--> FX-080515
 end record

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

    order by  r_bdbsr022.lcvcod   ,
              r_bdbsr022.lcvextcod

 format

    on every row
       if  ws_flgcab = 0 then   
           let ws_flgcab = 1  
           print column 001, "Cod_locadora",   "|" 
                           , "Nome_locadora",  "|" 
                           , "Cod_loja",       "|" 
                           , "Nome_loja",      "|" 
                           , "N._Reserva",     "|" 
                           , "Ano",            "|" 
                           , "Empresa",        "|"
                           , "Sucursal",       "|" 
                           , "Apolice",        "|" 
                           , "item",           "|" 
                           , "Data",           "|" 
                           , "Usuario",        "|" 
                           , "Grupo",          "|" 
                           , "Motivo",         "|" 
                           , "Clausulas",      "|" 
                           , "Prev. Util.",    "|" 
                           , "Soma prorrog.",  "|" 
                           , "Diar.Utl.",      "|" 
                           , "Diar.Pag.",      "|" 
                           , "Valor",          "|"
                           , "Etapa",          "|" 
                           , "UF Loja",        "|"
                           , "Cidade Ocorrencia" , "|"  
                           , "UF ocorrencia",  "|"  # Franzon
                           , "Cidade Loja",    "|"  # Franzon
                           , "Tarifa Loja",    "|"  # Franzon
                           , "OBS              ", "|"  # Franzon
                           , r_bdbsr022.data_cabec clipped, "|" #--> FX-080515
                           , ascii(13)
       end if

       print r_bdbsr022.lcvcod,                             "|", #cod locadora
             r_bdbsr022.lcvnom clipped,                     "|", #Nome locadora
             r_bdbsr022.lcvextcod,                          "|", #Loja
             r_bdbsr022.aviestnom clipped,                  "|", #Nome Loja 
             r_bdbsr022.atdsrvnum,                          "|", #Reserva
             r_bdbsr022.atdsrvano using "&&",               "|", #ano
             r_bdbsr022.empsgl,                             "|", #Sigla Empresa
             r_bdbsr022.succod    using "<<<<<<<<<<&",      "|", #Sucursal
             r_bdbsr022.aplnumdig using "<<<<<<<<<<&",      "|", #Apolice
             r_bdbsr022.itmnumdig using "<<<<<<<<<<&",      "|", #Item
             r_bdbsr022.atddat,                             "|", #Dt solicitacao 
             r_bdbsr022.avilocnom clipped,                  "|", #Usuario
             r_bdbsr022.avivclgrp,                          "|", #Grupo Veiculo
             r_bdbsr022.mtvdes clipped,                     "|", #Motivo
             r_bdbsr022.clscod,                             "|", #Clausula
             r_bdbsr022.aviprvent2 using "<<<<<<&",         "|", #Previsao 
             r_bdbsr022.aviprodiaqtd2 using "<<<<<<&",      "|", #Prorrogacoes
             r_bdbsr022.aviprvent using "<<<<<<&",          "|", #Diarias 
             r_bdbsr022.avidiaqtd using "<<<<<<&",          "|", #Diarias 
             r_bdbsr022.socopgitmvlr using "<<<<<<<<<&.&&", "|",
             r_bdbsr022.atdetpdes,                          "|", #Situacao 
             r_bdbsr022.endufd,                             "|", 
             r_bdbsr022.cidnom_oc,                          "|",
             r_bdbsr022.ufdcod,                             "|",
             r_bdbsr022.cidnom,                             "|",                        
           # r_bdbsr022.lcvregprccod,                       "|",
             r_bdbsr022.lcvregprccod,                       "|",#--> FX-080515
             r_bdbsr022.lcvregprcdes,                       "|",
             r_bdbsr022.data,                               "|", #--> FX-080515
             ascii(13)

end report  ###  rel_bdbsr022



#---------------------------------------------------------------------------
 report rel_bdbsr022_txt(r_bdbsr022)
#---------------------------------------------------------------------------

 define r_bdbsr022    record
    lcvcod            like datklocadora.lcvcod      ,
    lcvnom            like datklocadora.lcvnom      ,
    lcvextcod         like datkavislocal.lcvextcod  ,
    aviestnom         like datkavislocal.aviestnom  ,
    atdsrvnum         like datmservico.atdsrvnum    ,  
    atdsrvano         like datmservico.atdsrvano    ,
    empsgl            like gabkemp.empsgl           , 
    succod            like datrservapol.succod      ,
    aplnumdig         like datrservapol.aplnumdig   ,
    itmnumdig         like datrservapol.itmnumdig   ,
    atddat            like datmservico.atddat       , 
    avilocnom         like datmavisrent.avilocnom   ,
    avivclgrp         like datkavisveic.avivclgrp   ,
    avialgmtv         like datmavisrent.avialgmtv   ,
    mtvdes            char (20)                     ,
    clscod            char (03)                     ,
    aviprvent2        like datmavisrent.aviprvent   , # previsao utilizacao
    aviprodiaqtd2     like datmprorrog.aviprodiaqtd , # somatoria das prorrogacoes
    aviprvent         like datmavisrent.aviprvent   ,
    avidiaqtd         like datmavisrent.avidiaqtd   ,
    socopgitmvlr      decimal(15,2)                 , 
    atdetpdes         like datketapa.atdetpdes      ,   
    endufd            like datklocadora.endufd      , # Franzon
    cidnom            like datklocadora.cidnom      , # Franzon
    ufdcod            like datmlcl.ufdcod           , # Franzon
    cidnom_oc         like datmlcl.cidnom           , # Franzon
    lcvregprccod      like datkavislocal.lcvregprccod,# Franzon
    lcvregprcdes      char(10)                      , # Franzon
    data              date                          , #--> FX-080515
    data_cabec        char(50)                        #--> FX-080515
 end record

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format

    on every row
       
       print r_bdbsr022.lcvcod,                             ASCII(09), #cod locadora
             r_bdbsr022.lcvnom clipped,                     ASCII(09), #Nome locadora
             r_bdbsr022.lcvextcod,                          ASCII(09), #Loja
             r_bdbsr022.aviestnom clipped,                  ASCII(09), #Nome Loja 
             r_bdbsr022.atdsrvnum,                          ASCII(09), #Reserva
             r_bdbsr022.atdsrvano using "&&",               ASCII(09), #ano
             r_bdbsr022.empsgl,                             ASCII(09), #Sigla Empresa
             r_bdbsr022.succod    using "<<<<<<<<<<&",      ASCII(09), #Sucursal
             r_bdbsr022.aplnumdig using "<<<<<<<<<<&",      ASCII(09), #Apolice
             r_bdbsr022.itmnumdig using "<<<<<<<<<<&",      ASCII(09), #Item
             r_bdbsr022.atddat,                             ASCII(09), #Dt solicitacao 
             r_bdbsr022.avilocnom clipped,                  ASCII(09), #Usuario
             r_bdbsr022.avivclgrp,                          ASCII(09),#Grupo Veiculo
             r_bdbsr022.mtvdes clipped,                     ASCII(09),#Motivo
             r_bdbsr022.clscod,                             ASCII(09),#Clausula
             r_bdbsr022.aviprvent2 using "<<<<<<&",         ASCII(09),#Previsao 
             r_bdbsr022.aviprodiaqtd2 using "<<<<<<&",      ASCII(09),#Prorrogacoes
             r_bdbsr022.aviprvent using "<<<<<<&",          ASCII(09),#Diarias 
             r_bdbsr022.avidiaqtd using "<<<<<<&",          ASCII(09),#Diarias 
             r_bdbsr022.socopgitmvlr using "<<<<<<<<<&.&&", ASCII(09),
             r_bdbsr022.atdetpdes,                          ASCII(09),#Situacao 
             r_bdbsr022.endufd,                             ASCII(09),
             r_bdbsr022.cidnom_oc,                          ASCII(09),
             r_bdbsr022.ufdcod,                             ASCII(09),
             r_bdbsr022.cidnom,                             ASCII(09),                       
             r_bdbsr022.lcvregprccod,                       ASCII(09),#--> FX-080515 
             r_bdbsr022.lcvregprcdes,                       ASCII(09),
             r_bdbsr022.data

end report  ###  rel_bdbsr022

