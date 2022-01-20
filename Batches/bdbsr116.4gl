#-----------------------------------------------------------------------------#
# Sistema....: Porto Socorro                                                  #
# Modulo.....: bdbsr116                                                       #
# Analista Resp.: Raji Jahchan                                                #
# PSI......: 215627 - Relatorio/Arquivo de pagamento Azul                     #
#                     carga: Arquivo txt                                      #
#                     res  : Documento com resumo de pagamento                #
# --------------------------------------------------------------------------- #
# Desenvolvimento: Raji Jahchan                                               #
# Liberacao...: 10/01/2008                                                    #
# --------------------------------------------------------------------------- #
#                                 Alteracoes                                  #
# --------------------------------------------------------------------------- #
# Data        Autor           Origem     Alteracao                            #
# ----------  --------------  ---------- -------------------------------------#
# 25/03/2009  Adriano Santos  CT-681105  Busca de tributos na tabela da Porto #
#                                        Socorro caso não na tabela de        #
#                                        tributações                          #
# 07/04/2009  Fabio Costa     PSI238880  Inclusao das informacoes data de     #
#                                        acionamento do servico e tipo de     #
#                                        assistencia (srvorg = 8 fixo)        #
# 10/08/2009  Kevellin        PSI198404  Utilizacao funcao People ffpgc346,   #
#                                        buscar codigo de atividade           #
# 25/01/2010  Fabio Costa     PSI198404  Revisao campo a campo, acerto flags  #
#                                        retencao impostos, reestruturacao    #
# 05/03/2010  PSI198404  Fabio Costa  Não permitir cod. cidade nulo na chamada#
#                                     a dados de tributos, tratar retorno de  #
#                                     flags tributacao                        #
# 13/04/2010  PSI198404  Fabio Costa  Incluir codigo de evento 11366          #
# 07/12/2010  CT10123102 Fabio Costa  Tratar erro 2033 na chamada a ffpgc346  #
# --------------------------------------------------------------------------- #
# 26/04/2011  Celso Yamahaki             Correcao no cep de acordo com layout #
#-----------------------------------------------------------------------------#
# 12/03/2013 Raul, BIZ         PSI-2012-23608  Alteracoes no End. do Prestador#
#-----------------------------------------------------------------------------#
database porto

define m_data       char(10) ,
       m_patharq    char(100),
       m_pathres    char(100),
       m_datautil   char(10) ,
       m_socopgnum  like dbsmopg.socopgnum

define m_opg_aux record
       endlgd        like dpakpstend.endlgd       ,
       lgdnum        like dpakpstend.lgdnum       ,
       endbrr        like dpakpstend.endbrr       ,
       mpacidcod     like dpaksocor.mpacidcod    ,
       endcep        like dpakpstend.endcep       ,
       endcepcmp     like dpakpstend.endcepcmp,
       maides        like dpaksocor.maides       ,
       muninsnum     like dpaksocor.muninsnum    ,
       endcid        like dpakpstend.endcid         ,
       ufdsgl        like dpakpstend.ufdsgl         ,
       pcpatvcod     like dpaksocor.pcpatvcod    ,
       pisnum        like dpaksocor.pisnum       ,
       corsus        like dbsmopg.corsus         ,
       prscootipcod  like dpaksocor.prscootipcod ,
       pstsuccod     like dpaksocor.succod       ,
       cpfcgctxt     char(015)                   ,
       cep           char(10)                    ,
       ntzrnd        decimal(5,0)                ,
       cbo           char(5) 
end record

define m_ffpgc346 record
       empresa           decimal(2,0)
     , cmporgcod         smallint
     , pestip            char(1)
     , ppsretcod         like fpgkplprtcinf.ppsretcod
     , atividade         char(050)
     , errcod            smallint
     , errdes            char(060)
     , flagIR            char(001)
     , flagISS           char(001)
     , flagINSS          char(001)
     , flagPIS           char(001)
     , flagCOF           char(001)
     , flagCSLL          char(001)
     , arrecadacaoIR     char(004)
     , arrecadacaoISS    char(004)
     , arrecadacaoINSS   char(004)
     , arrecadacaoPIS    char(004)
     , arrecadacaoCOFIN  char(004)
     , arrecadacaoCSLL   char(004)
end record
 
main

  define sql_comando  char(700),
         l_pathtxt    char(100),
         l_ciaempcod  smallint ,
         l_hostname   char(3)  ,
         l_comando    char(200),
         l_retorno    smallint

  define d_bdbsr116   record
         socopgnum        like dbsmopg.socopgnum      ,
         socfatpgtdat     like dbsmopg.socfatpgtdat   ,
         socfattotvlr     like dbsmopg.socfattotvlr   ,
         empcod           like dbsmopg.empcod         ,
         pstcoddig        like dbsmopg.pstcoddig      ,
         pestip           like dbsmopgfav.pestip      ,
         cgccpfnum        like dbsmopgfav.cgccpfnum   ,
         cgcord           like dbsmopgfav.cgcord      ,
         cgccpfdig        like dbsmopgfav.cgccpfdig   ,
         socopgfavnom     like dbsmopgfav.socopgfavnom,
         bcocod           like dbsmopgfav.bcocod      ,
         bcoagnnum        like dbsmopgfav.bcoagnnum   ,
         bcoagndig        like dbsmopgfav.bcoagndig   ,
         bcoctanum        like dbsmopgfav.bcoctanum   ,
         bcoctadig        like dbsmopgfav.bcoctadig   ,
         socpgtopccod     like dbsmopgfav.socpgtopccod,
         socemsnfsdat     like dbsmopg.socemsnfsdat   ,
         nfsnum           like dbsmopgitm.nfsnum      ,
         soctip           like dbsmopg.soctip         ,
         lcvcod           like dbsmopg.lcvcod         ,
         aviestcod        like dbsmopg.aviestcod      ,
         segnumdig        like dbsmopg.segnumdig      ,
         succod           like dbsmopg.succod         ,
         infissalqvlr     like dbsmopg.infissalqvlr   
  end record
  
  define l_infissalqvlr char(09)

  call fun_dba_abre_banco("CT24HS")

  let m_patharq = f_path("DBS", "ARQUIVO")

  let m_data = arg_val(1)
  if m_data is null or m_data = " " then
     let m_data = today
  end if

  display 'Data atual.....: ', m_data

  ### VERIFICA SE A DATA DE PROCESSAMENTO E DIA UTIL
  let m_datautil = dias_uteis(m_data, 0, "", "S", "S")
 
  display 'Dia util.......: ', m_datautil
 
  if m_datautil <> m_data then
     exit program
  end if
 
  let m_data = dias_uteis(m_data, 2, "", "S", "S")

  display 'Data referencia: ', m_data
 
  let l_pathtxt = m_patharq clipped,"/AZUL_PGTO_", m_data[7,10], m_data[4,5], m_data[1,2], ".txt"
  let m_pathres = m_patharq clipped,"/AZUL_PGTO_", m_data[7,10], m_data[4,5], m_data[1,2], ".doc"

  display 'Arquivos:'
  display 'l_pathtxt: ', l_pathtxt clipped
  display 'm_pathres: ', m_pathres clipped
 
  select sitename into l_hostname  from dual

  #----------------------------------------------------------------
  # prepares
  
  
  #procura por Favorecido da Ordem de Pagamento
  let sql_comando = "select socopgfavnom, ",  # Nome do favorecido
                    "       cgccpfnum   , ",  # Numero do CGC ou CPF 
                    "       cgcord      , ",  # Ordem do CGC
                    "       cgccpfdig   , ",  # Digito do CGC ou CPF
                    "       pestip      , ",  # Tipo de pessoa para a Receita Federal  
                    "       bcocod      , ",  # Codigo do Banco
                    "       bcoagnnum   , ",  # Numero da agencia de pagamento          
                    "       bcoagndig   , ",  # Digito de Controle do Numero da Agencia 
                    "       bcoctanum   , ",  # Numero da conta bancaria de pagamento   
                    "       bcoctadig   , ",  # Digito da Conta Corrente no Banco
                    "       socpgtopccod  ",  # Codigo da opcao de pagamento 
                    "  from dbsmopgfav    ",  # Favorecido da O.P
                    " where socopgnum = ? "   # Numero da Ordem de Pagamento
                   
  
  prepare sel_opgfav from sql_comando       
  declare c_opgfav cursor with hold for sel_opgfav
  
  
  let sql_comando = " select ", #endlgd   ,   ", # Logradouro do Endereco
                    #"        lgdnum   ,   ", # Numero do logradouro
                    #"        endbrr   ,   ", # Nome do Bairro
                    "        mpacidcod,   ", # codigo da cidade no mapa
                    #"        endcep   ,   ", # Cep do Endereco
                    #"        endcepcmp,   ", # complemento do cep
                    "        maides   ,   ", # descricao do endereco e-mail
                    "        muninsnum,   ", # Numero da Inscricao Municipal
                    "        pcpatvcod,   ", # codigo atividade principal
                    "        pisnum   ,   ", # numero do PIS
                    "        succod   ,   ", # codigo sucursal
                    "       simoptpstflg  ", # Flag optante simples
                    " from dpaksocor      ", # Postos do Porto Socorro
                    " where pstcoddig = ? "  # codigo e digito de posto
  prepare pbdbsr116006 from sql_comando
  declare cbdbsr116006 cursor with hold for pbdbsr116006

  # Procura pelas cidades no Guia Postal
  
  #Raul Biz
  #let sql_comando = " select cidnom, 	", # Nome da cidade no guia postal
  #                  "        ufdcod 	", # Codigo da Unidade de Federacao
  #                  " from   glakcid 	", # Cadastro de cidades - Guia Postal
  #                  " where  cidcod = ? "  # Codigo cidade/localidade do guia postal
  #prepare pbdbsr116007 from sql_comando
  #declare cbdbsr116007 cursor with hold for pbdbsr116007


  let sql_comando = "select apl.succod,   			   ",
                    "       apl.ramcod,   			   ",
                    "       apl.aplnumdig,    			   ",
                    "       apl.itmnumdig,    			   ",
                    "       itm.atdsrvnum,    			   ",
                    "       itm.atdsrvano,    			   ",
                    "       itm.socopgitmnum, 			   ",
                    "       itm.socopgitmvlr, 			   ",
                    "       srv.asitipcod, 			   ",
                    "       itm.nfsnum, 			   ",
                    "       srv.atdsrvorg,			   ",
                    "       srv.vcllicnum 			   ",
                    " from dbsmopgitm itm , outer datrservapol apl,", # Itens da O.P, servicos com apolice
                    "      datmservico srv 		 	   ", # Servicos das chamadas c24 horas 
                    "where itm.atdsrvnum = apl.atdsrvnum 	   ",
                    "  and itm.atdsrvano = apl.atdsrvano 	   ",
                    "  and itm.atdsrvnum = srv.atdsrvnum 	   ",
                    "  and itm.atdsrvano = srv.atdsrvano 	   ",
                    "  and socopgnum = ? "
  prepare pbdbsr1160011 from sql_comando
  declare cbdbsr1160011 cursor with hold for pbdbsr1160011

  let sql_comando = "select sum(socopgitmcst) ",
                    "  from dbsmopgcst ",
                    "where socopgnum    = ? ",
                    "  and socopgitmnum = ? "
  prepare pbdbsr1160012 from sql_comando
  declare cbdbsr1160012 cursor with hold for pbdbsr1160012

  let sql_comando = "select d.endlgd   , ",
                    "       d.endbrr   , ",
                    "       d.endufd   , ",
                    "       d.endcid   , ",
                    "       d.endcep   , ",
                    "       d.endcepcmp, ",
                    "       d.maides   , ",
                    "       d.succod   , ",
                    "       f.mncinscod  ",
                    " from datkavislocal d, outer datklcvfav f ",
                    " where d.lcvcod    = f.lcvcod ",
                    "   and d.aviestcod = f.aviestcod ",
                    "   and d.lcvcod    = ? ",
                    "   and d.aviestcod = ? "
  prepare pbdbsr1160014 from sql_comando
  declare cbdbsr1160014 cursor with hold for pbdbsr1160014

  let sql_comando = " select a.atdetpdat, a.socvclcod "
                  , " from datmsrvacp a "
                  , " where a.atdetpcod in (3,4) "   -- acionado
                  , "   and a.atdsrvnum = ? "
                  , "   and a.atdsrvano = ? "
                  , " order by a.atdetpcod desc, a.atdetpdat desc "
  prepare p_srvacp_sel from sql_comando
  declare c_srvacp_sel cursor with hold for p_srvacp_sel

  let sql_comando = " select asitipdes "
                  , " from datkasitip "
                  , " where asitipcod = ? "
  prepare p_datkasitip_sel from sql_comando
  declare c_datkasitip_sel cursor with hold for p_datkasitip_sel

  #Raul BIZ
  let sql_comando = " select ufdsgl   ,   ",  
                    "        endcid   ,   ",  
                    "        endlgd   ,   ",  
                    "        endcep   ,   ",
                    "        endbrr   ,   ",
                    "        lgdnum   ,   ",  
                    "        endcepcmp,   ",  
                    "        endtipcod    ",                   
                    "   from dpakpstend   ", # Postos do Porto Socorro
                    "  where pstcoddig = ?", # codigo e digito de posto
                    "   and endtipcod  = 2 "  
  prepare pbdbsr116015 from sql_comando
  declare cbdbsr116015 cursor with hold for pbdbsr116015
  #----------------------------------------------------------------

  ### Inclusao de Campos - Ligia - maio/2016
  let sql_comando = " select a.c24astcod, b.c24astdes   ",  
                    "    from datmligacao a, datkassunto b   ",  
                    "    where a.atdsrvnum = ? ",
                    "      and a.atdsrvano = ? ",
                    "      and a.c24astcod = b.c24astcod ",
                    "      and a.lignum in ",
                           " (select min(lignum) from datmligacao c " ,
                           "    where c.atdsrvnum = ? ",
                           "      and c.atdsrvano = ?) "
  prepare pbdbsr116016 from sql_comando
  declare cbdbsr116016 cursor with hold for pbdbsr116016

  let sql_comando = " select clscod from datrsrvcls ",
                    "    where atdsrvnum = ? ",
                    "      and atdsrvano = ? "
  prepare pbdbsr116017 from sql_comando
  declare cbdbsr116017 cursor with hold for pbdbsr116017

  let sql_comando = " select atdvclsgl from datkveiculo ",
                    "    where socvclcod = ? "
  prepare pbdbsr116018 from sql_comando
  declare cbdbsr116018 cursor with hold for pbdbsr116018

  let m_socopgnum = 0

  start report bdbsr017_carga_azul to l_pathtxt

  declare c_bdbsr116 cursor with hold for
  select dbsmopg.socopgnum,
         dbsmopg.socfatpgtdat,
         dbsmopg.socfattotvlr,
         dbsmopg.pstcoddig,
         dbsmopg.empcod,
         dbsmopg.socemsnfsdat,
         dbsmopg.soctip,
         dbsmopg.lcvcod,
         dbsmopg.aviestcod,
         dbsmopg.segnumdig,
         dbsmopg.succod,
         dbsmopg.infissalqvlr
    from dbsmopg dbsmopg
   where dbsmopg.socopgsitcod = 7
     and dbsmopg.socfatpgtdat = m_data 

  foreach c_bdbsr116 into  d_bdbsr116.socopgnum   ,
                           d_bdbsr116.socfatpgtdat,
                           d_bdbsr116.socfattotvlr,
                           d_bdbsr116.pstcoddig   ,
                           d_bdbsr116.empcod      ,
                           d_bdbsr116.socemsnfsdat,
                           d_bdbsr116.soctip,
                           d_bdbsr116.lcvcod,
                           d_bdbsr116.aviestcod,
                           d_bdbsr116.segnumdig,
                           d_bdbsr116.succod,
                           d_bdbsr116.infissalqvlr

     display '----------------------------------------------------------------'
     display "OP: ", d_bdbsr116.socopgnum
     
     display "d_bdbsr116.infissalqvlr: ",d_bdbsr116.infissalqvlr
     if  d_bdbsr116.infissalqvlr is null or d_bdbsr116.infissalqvlr = ' ' then
        let d_bdbsr116.infissalqvlr = 0000.00
     end if 
     
     let l_infissalqvlr = bdbsr116_valor_aliquota(d_bdbsr116.infissalqvlr)   
     
     
     
     
     #---------------------------------------------------------------
     # Filtra OPs da Azul
     #---------------------------------------------------------------
     initialize l_ciaempcod to null

     select srv.ciaempcod into l_ciaempcod
     from dbsmopgitm itm, datmservico srv
     where itm.socopgnum = d_bdbsr116.socopgnum
       and itm.socopgitmnum  = (select min(socopgitmnum)
                                from dbsmopgitm itmmin
                                where itmmin.socopgnum = d_bdbsr116.socopgnum)
       and itm.atdsrvnum = srv.atdsrvnum
       and itm.atdsrvano = srv.atdsrvano

     if l_ciaempcod <> 35
        then
        display 'OP empresa ', l_ciaempcod
        continue foreach
     end if
    
     #---------------------------------------------------------------
     # Obtem dados do favorecido da ordem de pagamento
     #---------------------------------------------------------------
     initialize d_bdbsr116.socopgfavnom, d_bdbsr116.bcocod   ,
                d_bdbsr116.bcoagnnum   , d_bdbsr116.bcoagndig, d_bdbsr116.bcoctanum,
                d_bdbsr116.bcoctadig   , d_bdbsr116.socpgtopccod to null

     whenever error continue
     open  c_opgfav using d_bdbsr116.socopgnum
     fetch c_opgfav into  d_bdbsr116.socopgfavnom,
                          d_bdbsr116.cgccpfnum,
                          d_bdbsr116.cgcord,
                          d_bdbsr116.cgccpfdig,
                          d_bdbsr116.pestip,
                          d_bdbsr116.bcocod,
                          d_bdbsr116.bcoagnnum,
                          d_bdbsr116.bcoagndig,
                          d_bdbsr116.bcoctanum,
                          d_bdbsr116.bcoctadig,
                          d_bdbsr116.socpgtopccod
     whenever error stop

     if d_bdbsr116.cgcord is null  then
        let d_bdbsr116.cgcord = 0
     end if

     close c_opgfav

     output to report bdbsr017_carga_azul(d_bdbsr116.socopgnum,
                                          d_bdbsr116.pstcoddig,
                                          d_bdbsr116.pestip,
                                          d_bdbsr116.socopgfavnom,
                                          d_bdbsr116.cgccpfnum,
                                          d_bdbsr116.cgcord,
                                          d_bdbsr116.cgccpfdig,
                                          d_bdbsr116.socemsnfsdat,
                                          d_bdbsr116.socfatpgtdat,
                                          d_bdbsr116.socfattotvlr,
                                          d_bdbsr116.empcod,
                                          d_bdbsr116.socpgtopccod,
                                          d_bdbsr116.bcocod,
                                          d_bdbsr116.bcoagnnum,
                                          d_bdbsr116.bcoagndig,
                                          d_bdbsr116.bcoctanum,
                                          d_bdbsr116.bcoctadig,
                                          d_bdbsr116.soctip,
                                          d_bdbsr116.lcvcod,
                                          d_bdbsr116.aviestcod,
                                          d_bdbsr116.segnumdig,
                                          d_bdbsr116.succod,
                                          l_infissalqvlr)

     initialize d_bdbsr116.* to null

  end foreach

  finish report bdbsr017_carga_azul

  display 'Relatorio finalizado'
 
  #Transferencia dos arquivos passarao a seer realizados pela Producao TI
  # 
  #if l_hostname <> "u07" then # Ambiente de producao
  #   let l_comando = "rcp ", l_pathtxt clipped, " u146:/transm/azulseguros"
  #   display l_comando clipped
  #   run l_comando
  #
  #   let l_comando = "rcp ", m_pathres clipped, " u146:/transm/azulseguros"
  #   display l_comando clipped
  #   run l_comando
  #end if

   #############################################################
  # Envia e-mail com os pagamentos
  #############################################################
  whenever error continue
  
  let l_comando = "gzip -f ", l_pathtxt
  run l_comando
  let l_pathtxt = l_pathtxt clipped, ".gz" 
 
  let l_retorno = ctx22g00_envia_email("BDBSR116", "Arquivo de pagamento AZUL", l_pathtxt)
  if l_retorno <> 0 then
     if l_retorno <> 99 then
        display "Erro de envio de email(cx22g00)- ",l_pathtxt
     else
        display "Nao ha email cadastrado para o modulo BDBSR116 "
     end if
  end if
 
  let l_comando = "gzip -f ", m_pathres
  run l_comando
  let m_pathres = m_pathres clipped, ".gz"
   
  let l_retorno = ctx22g00_envia_email("BDBSR116", "Resumo de pagamento AZUL", m_pathres)
  if l_retorno <> 0 then
     if l_retorno <> 99 then
        display "Erro de envio de email(cx22g00)- ",m_pathres
     else
        display "Nao ha email cadastrado para o modulo BDBSR116 "
     end if
  end if

  whenever error stop
  
end main

#-------------------------------------#
report bdbsr017_carga_azul(l_param)
#-------------------------------------#

  define l_param record
         socopgnum     like dbsmopg.socopgnum      ,
         pstcoddig     like dpaksocor.pstcoddig    ,
         pestip        like dbsmopgfav.pestip      ,
         socopgfavnom  like dbsmopgfav.socopgfavnom,
         cgccpfnum     like dbsmopgfav.cgccpfnum   ,
         cgcord        like dbsmopgfav.cgcord      ,
         cgccpfdig     like dbsmopgfav.cgccpfdig   ,
         socemsnfsdat  like dbsmopg.socemsnfsdat   ,
         socfatpgtdat  like dbsmopg.socfatpgtdat   ,
         socfattotvlr  like dbsmopg.socfattotvlr   ,
         empcod        like dbsmopg.empcod         ,
         socpgtopccod  like dbsmopgfav.socpgtopccod,
         bcocod        like dbsmopgfav.bcocod      ,
         bcoagnnum     like dbsmopgfav.bcoagnnum   ,
         bcoagndig     like dbsmopgfav.bcoagndig   ,
         bcoctanum     like dbsmopgfav.bcoctanum   ,
         bcoctadig     like dbsmopgfav.bcoctadig   ,
         soctip        like dbsmopg.soctip         ,
         lcvcod        like dbsmopg.lcvcod         ,
         aviestcod     like dbsmopg.aviestcod      ,
         segnumdig     like dbsmopg.segnumdig      ,
         succod        like dbsmopg.succod         ,
         infissalqvlr  char(09) 
  end record

  define l_itm_aux record
         succod        like datrservapol.succod    ,
         ramcod        like datrservapol.ramcod    ,
         aplnumdig     like datrservapol.aplnumdig ,
         atdsrvnum     like datrservapol.atdsrvnum ,
         atdsrvano     like datrservapol.atdsrvano ,
         socopgitmnum  like dbsmopgitm.socopgitmnum,
         socopgitmvlr  like dbsmopgitm.socopgitmvlr,
         asitipcod     like datmservico.asitipcod  ,
         nfsnum        like dbsmopgitm.nfsnum      ,
         atdsrvorg     like datmservico.atdsrvorg  ,
         atdetpdat     like datmsrvacp.atdetpdat   ,
         asitipdes     like datkasitip.asitipdes   ,
         socopgitmcst  like dbsmopgcst.socopgitmcst,
         socopgitmtot  like dbsmopgitm.socopgitmvlr,
         azlaplcod     integer                     ,
         itmnumdig     like datkazlapl.itmnumdig   ,
         vcllicnum     like datmservico.vcllicnum 
  end record

  define l_aux        char(008),
         l_aux2       char(018),
         l_aux3       char(011),
         l_txtitmtot  char(018),
         l_mail       smallint

  define l_doc_handle    integer,
         m_seq           integer,
         l_srvop         integer,
         l_vlrop         like dbsmopg.socfattotvlr,
         l_simoptpstflg  like dpaksocor.simoptpstflg 
         

  define l_cts54g00 record
         errcod        smallint ,
         errdes        char(80) ,
         tpfornec      char(3)  ,
         retencod      like fpgkplprtcinf.ppsretcod ,
         socitmtrbflg  char(1)  ,
         retendes      char(50)
  end record

  define l_cty10g00_out record
         res     smallint,
         msg     char(40),
         endufd  like gabksuc.endufd,
         endcid  like gabksuc.endcid,
         cidcod  like gabksuc.cidcod
  end record

   define lr_saida_801 record   
  	      coderr       smallint
  	     ,msgerr       char(050)
  	     ,ppssucnum    like cglktrbetb.ppssucnum  
  	     ,etbnom       like cglktrbetb.etbnom     
  	     ,etbcpjnum    like cglktrbetb.etbcpjnum  
  	     ,etblgddes    like cglktrbetb.etblgddes  
  	     ,etblgdnum    like cglktrbetb.etblgdnum  
  	     ,etbcpldes    like cglktrbetb.etbcpldes  
  	     ,etbbrrnom    like cglktrbetb.etbbrrnom  
  	     ,etbcepnum    like cglktrbetb.etbcepnum  
  	     ,etbcidnom    like cglktrbetb.etbcidnom  
  	     ,etbufdsgl    like cglktrbetb.etbufdsgl  
  	     ,etbiesnum    like cglktrbetb.etbiesnum  
  	     ,etbmuninsnum like cglktrbetb.etbmuninsnum
   end record
  
  define lr_aviso record
      assunto   char(250),
      texto     char(500)
  end record
  
  define lr_azul        record
         vcllicnum      like datkazlapl.vcllicnum,
         cgccpfnum      like datkazlapl.cgccpfnum,
         cgcord         like datkazlapl.cgcord   ,
         cgccpfdig      like datkazlapl.cgccpfdig
  end record
  
  define l_res  integer  ,
         l_msg  char(70) ,
         l_favtip  smallint,
         l_try  smallint,
         l_cnpj_cpf char(14),
         l_cod_ass char(03),
         l_des_ass char(24),
         l_clscod  char(3),
         l_socvclcod like datmsrvacp.socvclcod,
         l_atdvclsgl like datkveiculo.atdvclsgl 

  output
    page length    01
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format

     first page header

        let l_srvop  = 0
        let l_vlrop  = 0
        let m_seq    = 1
        let l_mail   = 0

        start report bdbsr017_res_azul to m_pathres

     on last row
        finish report bdbsr017_res_azul

     on every row

        initialize l_itm_aux.* to null
        initialize l_doc_handle, l_aux, l_aux2, l_aux3, l_txtitmtot to null

        display 'socopgnum    = ', l_param.socopgnum
        display 'pstcoddig    = ', l_param.pstcoddig
        display 'pestip       = ', l_param.pestip
        display 'socopgfavnom = ', l_param.socopgfavnom
        display 'cgccpfnum    = ', l_param.cgccpfnum
        display 'cgcord       = ', l_param.cgcord
        display 'cgccpfdig    = ', l_param.cgccpfdig
        # display 'socemsnfsdat = ', l_param.socemsnfsdat
        # display 'socfatpgtdat = ', l_param.socfatpgtdat
        # display 'socfattotvlr = ', l_param.socfattotvlr
        # display 'empcod       = ', l_param.empcod
        # display 'socpgtopccod = ', l_param.socpgtopccod
        # display 'bcocod       = ', l_param.bcocod
        # display 'bcoagnnum    = ', l_param.bcoagnnum
        # display 'bcoagndig    = ', l_param.bcoagndig
        # display 'bcoctanum    = ', l_param.bcoctanum
        # display 'bcoctadig    = ', l_param.bcoctadig
        display 'soctip       = ', l_param.soctip
        display 'lcvcod       = ', l_param.lcvcod
        display 'aviestcod    = ', l_param.aviestcod

        # dados dos servicos/itens da OP
        open cbdbsr1160011 using l_param.socopgnum
        foreach cbdbsr1160011 into l_itm_aux.succod,
                                   l_itm_aux.ramcod,
                                   l_itm_aux.aplnumdig,
                                   l_itm_aux.itmnumdig,
                                   l_itm_aux.atdsrvnum,
                                   l_itm_aux.atdsrvano,
                                   l_itm_aux.socopgitmnum,
                                   l_itm_aux.socopgitmvlr,
                                   l_itm_aux.asitipcod,
                                   l_itm_aux.nfsnum,
                                   l_itm_aux.atdsrvorg,
                                   l_itm_aux.vcllicnum

           if l_itm_aux.succod is null then
              let l_itm_aux.succod = 0
           end if

           if l_itm_aux.ramcod is null then
              let l_itm_aux.ramcod = 0
           end if

           if l_itm_aux.aplnumdig is null then
              let l_itm_aux.aplnumdig = 0
           end if

           initialize lr_azul.* to null
           let l_cnpj_cpf = null

           # busca dados somente uma vez por OP
           if m_socopgnum != l_param.socopgnum
              then
              let m_socopgnum = l_param.socopgnum
             
              initialize m_opg_aux.* to null
              initialize l_res, l_msg, l_favtip to null
             
              let l_favtip = 0
             
              # CPF/CGC do favorecido
              case l_param.pestip
                 when "F"
                      let m_opg_aux.cpfcgctxt = l_param.cgccpfnum using '&&&&&&&&&',
                                                l_param.cgccpfdig using '&&'
                 when "J"
                      let m_opg_aux.cpfcgctxt = l_param.cgccpfnum using '&&&&&&&&',
                                                l_param.cgcord    using '&&&&'    ,
                                                l_param.cgccpfdig using '&&'
                 when "G"
                      let m_opg_aux.cpfcgctxt = "00000000000000"
              end case
             
              # REEMBOLSO BUSCA ENDERECO DO SEGURADO AZUL
              # reembolso PF nao precisa de PIS, conforme regra utilizada no People
              # somente um reembolso por OP, por isso pega dados do cliente com
              # apólice do item de OP
              #TODO: pendente a alterar, reembolso nao deve ser feito com prestador fixo
              if (l_param.pstcoddig = 3 or l_param.lcvcod = 33) or
                 l_param.segnumdig is not null
                 then
                 
                 let l_favtip = 3  # Segurado
                
                 if l_itm_aux.aplnumdig <> 0 and
                    l_itm_aux.succod    <> 0
                    then
                    # para buscar codigo de retencao o segnumdig nao pode ser nulo
                    # para reembolso
                    if l_param.segnumdig is null
                       then
                       let l_param.segnumdig = 1
                    end if

                    let m_opg_aux.pstsuccod = l_param.succod

                    call ctd02g01_azlaplcod(l_itm_aux.succod,
                                            l_itm_aux.ramcod,
                                            l_itm_aux.aplnumdig,
                                            l_itm_aux.itmnumdig, "")
                         returning l_res, l_msg, l_itm_aux.azlaplcod
                   
                    call figrc011_inicio_parse()
                   
                    let l_doc_handle = ctd02g00_agrupaXML(l_itm_aux.azlaplcod)
                   
                    let m_opg_aux.endlgd = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/LOGRADOURO")
                    let m_opg_aux.lgdnum = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/NUMERO")
                    let m_opg_aux.endbrr = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/BAIRRO")
                    let m_opg_aux.ufdsgl = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/UF")
                    let m_opg_aux.endcid = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/CIDADE")
                    let m_opg_aux.endcep = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/CEP")
                    let m_opg_aux.maides = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/EMAIL")
                   
                    call figrc011_fim_parse()
                   
                    if m_opg_aux.lgdnum is null then
                       let m_opg_aux.lgdnum = 0
                    end if
                   
                    let m_opg_aux.cep = "00", m_opg_aux.endcep
                   
                    call cty10g00_obter_cidcod(m_opg_aux.endcid, m_opg_aux.ufdsgl)
                         returning l_res, l_msg, m_opg_aux.mpacidcod
                        
                 else
                    display 'OP reembolso, apolice nao localizada'
                 end if

              else

                 if l_param.soctip = 2     # CARRO EXTRA BUSCA LOCADORA
                    then
                   
                    let l_favtip = 4  # Locadora
                   
                    whenever error continue
                    open cbdbsr1160014 using l_param.lcvcod,
                                             l_param.aviestcod
                    fetch cbdbsr1160014 into m_opg_aux.endlgd   ,
                                             m_opg_aux.endbrr   ,
                                             m_opg_aux.ufdsgl   ,
                                             m_opg_aux.endcid   ,
                                             m_opg_aux.endcep   ,
                                             m_opg_aux.endcepcmp,
                                             m_opg_aux.maides   ,
                                             m_opg_aux.pstsuccod,
                                             m_opg_aux.muninsnum
                    whenever error stop
                   
                    if m_opg_aux.endcepcmp is null or m_opg_aux.endcepcmp = " "  then
                    	let m_opg_aux.cep = "00", m_opg_aux.endcep, "000"
                    else
                    	let m_opg_aux.cep = "00", m_opg_aux.endcep, m_opg_aux.endcepcmp
                    end if
                    
                    let m_opg_aux.lgdnum = 0
                   
                    call cty10g00_obter_cidcod(m_opg_aux.endcid, m_opg_aux.ufdsgl)
                         returning l_res, l_msg, m_opg_aux.mpacidcod
                        
                 else    # DADOS PRESTADOR

                    let l_favtip = 1  # Prestador
                
                    whenever error continue
                    open cbdbsr116006 using l_param.pstcoddig
                    fetch cbdbsr116006 into #m_opg_aux.endlgd,
                                            #m_opg_aux.lgdnum,
                                            #m_opg_aux.endbrr,
                                            m_opg_aux.mpacidcod,
                                            #m_opg_aux.endcep,
                                            #m_opg_aux.endcepcmp,  #Complemento do Cep
                                            m_opg_aux.maides,
                                            m_opg_aux.muninsnum,
                                            m_opg_aux.pcpatvcod,
                                            m_opg_aux.pisnum,
                                            m_opg_aux.pstsuccod,
                                            l_simoptpstflg
                    whenever error stop
                    
                    #Raul BIZ
                    
                    whenever error continue
                    open cbdbsr116015 using l_param.pstcoddig
                    fetch cbdbsr116015 into m_opg_aux.ufdsgl   
                                           ,m_opg_aux.endcid   
                                           ,m_opg_aux.endlgd   
                                           ,m_opg_aux.endcep   
                                           ,m_opg_aux.endbrr   
                                           ,m_opg_aux.lgdnum   
                                           ,m_opg_aux.endcepcmp
                   
                    whenever error stop
                    if sqlca.sqlcode <> 0 then
                       if sqlca.sqlcode <> 100 then
                          display "Erro SELECT (cbdbsr116015). SQLCODE: "
                                                           ,sqlca.sqlcode
                          display "m_opg_aux.ufdsgl: ",m_opg_aux.ufdsgl
                                 ,"/","m_opg_aux.endcid: ",m_opg_aux.endcid   
                                 ,"/","m_opg_aux.endlgd: ",m_opg_aux.endlgd   
                                 ,"/","m_opg_aux.endcep: ",m_opg_aux.endcep   
                                 ,"/","m_opg_aux.endbrr: ",m_opg_aux.endbrr
                                 ,"/","m_opg_aux.lgdnum: ",m_opg_aux.lgdnum   
                                 ,"/","m_opg_aux.endcepcmp: ",m_opg_aux.endcepcmp
                       
                       else
                       
                          #PSI-2012-23608, Biz
                          let lr_aviso.assunto = "PRESTADOR ",l_param.pstcoddig clipped, " - OP ", m_socopgnum, 
                                                 " - SEM ENDEREÇO FISCAL CADASTRADO"
                          let lr_aviso.texto   = " - SEM ENDEREÇO FISCAL CADASTRADO"
                          
                                         
                          display lr_aviso.assunto 
                          let l_mail = ctx22g00_mail_corpo("ANLPGTPS"
                                                           ,lr_aviso.assunto
                                                           ,lr_aviso.texto)                        

                       end if
                    	
                    end if
                    #Raul BIZ

                    if m_opg_aux.endcepcmp is null or m_opg_aux.endcepcmp = " " then 
                       let m_opg_aux.cep =  "00", m_opg_aux.endcep, "000"
                    else
                       let m_opg_aux.cep =  "00", m_opg_aux.endcep, m_opg_aux.endcepcmp
                    end if
                    
	            
                    #Raul BIZ
                    #whenever error continue
                    #open cbdbsr116007 using m_opg_aux.mpacidcod
                    #fetch cbdbsr116007 into m_opg_aux.cidnom,
                    #                        m_opg_aux.ufdcod
                    #whenever error stop
                 end if
              end if

              ### Inclusao de Campos - Ligia - maio/2016
              if l_itm_aux.azlaplcod is null or
                 l_itm_aux.azlaplcod = 0 then 
                 call ctd02g01_azlaplcod(l_itm_aux.succod,
                                         l_itm_aux.ramcod,
                                         l_itm_aux.aplnumdig,
                                         l_itm_aux.itmnumdig, "")
                      returning l_res, l_msg, l_itm_aux.azlaplcod

                 call ctd02g01_dados_azul(1,l_itm_aux.azlaplcod)
                      returning l_res, l_msg, lr_azul.*

                 if lr_azul.cgcord <> 0 then
                    let l_cnpj_cpf = lr_azul.cgccpfnum using "&&&&&&&&",
                                     lr_azul.cgcord using "&&&&",
                                     lr_azul.cgccpfdig using "&&"
                 else
                    let l_cnpj_cpf = lr_azul.cgccpfnum using "&&&&&&&&&",
                                     lr_azul.cgccpfdig using "&&"
                 end if
              end if
              ################################################

              # obter cidade ligada a sucursal do fornecedor (tributacao)
              initialize l_cty10g00_out.* to null
              call cty10g00_obter_cidcod(m_opg_aux.endcid, m_opg_aux.ufdsgl)
              returning l_res,
                        l_msg,
                        m_opg_aux.mpacidcod

              if l_res = 0 then
              	 initialize lr_saida_801.*  to null 
                 
                 display "ENTRDA DA TRIBUTOS"
                 display "l_param.empcod      = ", l_param.empcod     
                 display "m_opg_aux.mpacidcod = ", m_opg_aux.mpacidcod
                 
                 
                 call fcgtc801(l_param.empcod, m_opg_aux.mpacidcod)
                 returning lr_saida_801.coderr      
                          ,lr_saida_801.msgerr      
                          ,lr_saida_801.ppssucnum   
                          ,lr_saida_801.etbnom      
                          ,lr_saida_801.etbcpjnum   
                          ,lr_saida_801.etblgddes   
                          ,lr_saida_801.etblgdnum   
                          ,lr_saida_801.etbcpldes   
                          ,lr_saida_801.etbbrrnom   
                          ,lr_saida_801.etbcepnum   
                          ,lr_saida_801.etbcidnom   
                          ,lr_saida_801.etbufdsgl   
                          ,lr_saida_801.etbiesnum   
                          ,lr_saida_801.etbmuninsnum
                 
                 display "RETORNO DO TRIBUTOS"
                 display "lr_saida_801.coderr       = ", lr_saida_801.coderr      
                 display "lr_saida_801.msgerr       = ", lr_saida_801.msgerr      
                 display "lr_saida_801.ppssucnum    = ", lr_saida_801.ppssucnum   
                 display "lr_saida_801.etbnom       = ", lr_saida_801.etbnom      
                 display "lr_saida_801.etbcpjnum    = ", lr_saida_801.etbcpjnum   
                 display "lr_saida_801.etblgddes    = ", lr_saida_801.etblgddes   
                 display "lr_saida_801.etblgdnum    = ", lr_saida_801.etblgdnum   
                 display "lr_saida_801.etbcpldes    = ", lr_saida_801.etbcpldes   
                 display "lr_saida_801.etbbrrnom    = ", lr_saida_801.etbbrrnom   
                 display "lr_saida_801.etbcepnum    = ", lr_saida_801.etbcepnum   
                 display "lr_saida_801.etbcidnom    = ", lr_saida_801.etbcidnom   
                 display "lr_saida_801.etbufdsgl    = ", lr_saida_801.etbufdsgl   
                 display "lr_saida_801.etbiesnum    = ", lr_saida_801.etbiesnum   
                 display "lr_saida_801.etbmuninsnum = ", lr_saida_801.etbmuninsnum

                 if lr_saida_801.coderr = 0 then
                    let l_cty10g00_out.endcid = lr_saida_801.etbcidnom
                    let l_cty10g00_out.cidcod = m_opg_aux.mpacidcod
                    
                    #Grava a sucursal na op                   
                    whenever error continue
                      update dbsmopg set succod = lr_saida_801.ppssucnum
                      where socopgnum = l_param.socopgnum                
                    whenever error stop 
                 else
                    display lr_saida_801.msgerr
                 end if
              
              else
                 display l_msg 
              end if
              
	      display 'Dados do favorecido: '
              display 'Sucursal..: ', m_opg_aux.pstsuccod
              display 'Cidade:...: ', m_opg_aux.endcid
              display 'UF........: ', m_opg_aux.ufdsgl
              display 'mpacidcod.: ', m_opg_aux.mpacidcod
	      
	      
              # buscar sucursal da OP ligada ao prestador
              call cty10g00_dados_sucursal(1, m_opg_aux.pstsuccod)
                   returning l_cty10g00_out.*

              if l_cty10g00_out.cidcod is null or
                 l_cty10g00_out.cidcod <= 0
                 then
                 call cty10g00_obter_cidcod(l_cty10g00_out.endcid, l_cty10g00_out.endufd)
                      returning l_cty10g00_out.res,
                                l_cty10g00_out.msg,
                                l_cty10g00_out.cidcod
              end if

              # buscar descricao da atividade principal
              initialize l_cts54g00.* to null

              call cts54g00_inftrb(35,
                                   l_param.pstcoddig,
                                   l_param.soctip,
                                   l_param.segnumdig,
                                   m_opg_aux.corsus,
                                   l_param.pestip,
                                   m_opg_aux.prscootipcod,
                                   m_opg_aux.pcpatvcod)
                         returning l_cts54g00.errcod      ,
                                   l_cts54g00.errdes      ,
                                   l_cts54g00.tpfornec    ,
                                   l_cts54g00.retencod    ,
                                   l_cts54g00.socitmtrbflg,
                                   l_cts54g00.retendes

              if l_cts54g00.errcod != 0
                 then
                 display "cts54g00_inftrb nao foi possivel ID do codigo de retencao: ",
                         l_cts54g00.errcod, " | ", l_cts54g00.errdes
              end if

              display "Retorno cts54g00_inftrb: "
              display 'l_cts54g00.errcod      : ', l_cts54g00.errcod
              display 'l_cts54g00.errdes      : ', l_cts54g00.errdes clipped
              display 'l_cts54g00.tpfornec    : ', l_cts54g00.tpfornec
              display 'l_cts54g00.retencod    : ', l_cts54g00.retencod
              display 'l_cts54g00.socitmtrbflg: ', l_cts54g00.socitmtrbflg
              display 'l_cts54g00.retendes    : ', l_cts54g00.retendes clipped

              # revisar favorecido reembolso sem cidade sede por conta de erro
              # no cadastro da Azul, considera padrao Sao Paulo
              if m_opg_aux.mpacidcod is null
                 then
                 if l_favtip = 3
                    then
                    display 'Considerando padrao Sao Paulo'
                    let m_opg_aux.mpacidcod = 9668
                 end if
                 display 'Cidade sede do segurado nao identificada:'
                 display 'm_opg_aux.endlgd   : ', m_opg_aux.endlgd
                 display 'm_opg_aux.lgdnum   : ', m_opg_aux.lgdnum
                 display 'm_opg_aux.endbrr   : ', m_opg_aux.endbrr
                 display 'm_opg_aux.ufdcod   : ', m_opg_aux.ufdsgl
                 display 'm_opg_aux.cidnom   : ', m_opg_aux.endcid
                 display 'm_opg_aux.mpacidcod: ', m_opg_aux.mpacidcod
              end if
             
              #Fornax-Quantum - Inicio 
              # obter flag's de tributacao e codigos de arrecadacao da receita
              initialize m_ffpgc346.* to null

              #let l_try = 0
              
              #if l_cts54g00.retendes is not null and
              #   l_cty10g00_out.cidcod is not null and
              #   l_cty10g00_out.cidcod > 0 and
              #   m_opg_aux.mpacidcod is not null and
              #   m_opg_aux.mpacidcod > 0
              #   then
              #   
              #   display 'ffpgc346 parametros:'
              #   display 'l_param.pestip.........................: ', l_param.pestip
              #   display 'l_cts54g00.retencod....................: ', l_cts54g00.retencod
              #   display 'l_cts54g00.retendes....................: ', l_cts54g00.retendes clipped
              #   display 'l_cty10g00_out.cidcod(cidade prestacao): ', l_cty10g00_out.cidcod
              #   display 'm_opg_aux.mpacidcod(cidade sede).......: ', m_opg_aux.mpacidcod
              #   
              #   # tentar chamar funcao mais de uma vez para nao evitar erro 2033
              #   while true
              #      
              #      let l_try = l_try + 1
              #      
              #      call ffpgc346(35, 11, l_param.pestip,
              #                    l_cts54g00.retencod,
              #                    l_cts54g00.retendes,
              #                    l_cty10g00_out.cidcod,
              #                    m_opg_aux.mpacidcod)
              #          returning m_ffpgc346.empresa         ,
              #                    m_ffpgc346.cmporgcod       ,
              #                    m_ffpgc346.pestip          ,
              #                    m_ffpgc346.ppsretcod       ,
              #                    m_ffpgc346.atividade       ,
              #                    m_ffpgc346.errcod          ,
              #                    m_ffpgc346.errdes          ,
              #                    m_ffpgc346.flagIR          ,
              #                    m_ffpgc346.flagISS         ,
              #                    m_ffpgc346.flagINSS        ,
              #                    m_ffpgc346.flagPIS         ,
              #                    m_ffpgc346.flagCOF         ,
              #                    m_ffpgc346.flagCSLL        ,
              #                    m_ffpgc346.arrecadacaoIR   ,
              #                    m_ffpgc346.arrecadacaoISS  ,
              #                    m_ffpgc346.arrecadacaoINSS ,
              #                    m_ffpgc346.arrecadacaoPIS  ,
              #                    m_ffpgc346.arrecadacaoCOFIN,
              #                    m_ffpgc346.arrecadacaoCSLL
              #
              #      if m_ffpgc346.errcod = 0
              #         then
              #         display 'Retorno FFPGC346 com sucesso'
              #         exit while
              #      else
              #         if l_try < 10
              #            then
              #            display 'Tentativa: ', l_try
              #            display 'm_ffpgc346.errcod: ', m_ffpgc346.errcod
              #            display 'm_ffpgc346.errdes: ', m_ffpgc346.errdes
              #            sleep 2
              #         else
              #            display 'Tentativas excedidas'
              #            display 'm_ffpgc346.errcod: ', m_ffpgc346.errcod
              #            display 'm_ffpgc346.errdes: ', m_ffpgc346.errdes
              #            exit while
              #         end if
              #      end if
              #   end while
              #   
              #   display 'FFPGC346 retorno:'
              #   display 'm_ffpgc346.empresa         : ', m_ffpgc346.empresa
              #   display 'm_ffpgc346.cmporgcod       : ', m_ffpgc346.cmporgcod
              #   display 'm_ffpgc346.pestip          : ', m_ffpgc346.pestip
              #   display 'm_ffpgc346.ppsretcod       : ', m_ffpgc346.ppsretcod
              #   display 'm_ffpgc346.atividade       : ', m_ffpgc346.atividade
              #   display 'm_ffpgc346.errcod          : ', m_ffpgc346.errcod
              #   display 'm_ffpgc346.errdes          : ', m_ffpgc346.errdes
              #   display 'm_ffpgc346.flagIR          : ', m_ffpgc346.flagIR
              #   display 'm_ffpgc346.flagISS         : ', m_ffpgc346.flagISS
              #   display 'm_ffpgc346.flagINSS        : ', m_ffpgc346.flagINSS
              #   display 'm_ffpgc346.flagPIS         : ', m_ffpgc346.flagPIS
              #   display 'm_ffpgc346.flagCOF         : ', m_ffpgc346.flagCOF
              #   display 'm_ffpgc346.flagCSLL        : ', m_ffpgc346.flagCSLL
              #   display 'm_ffpgc346.arrecadacaoIR   : ', m_ffpgc346.arrecadacaoIR
              #   display 'm_ffpgc346.arrecadacaoISS  : ', m_ffpgc346.arrecadacaoISS
              #   display 'm_ffpgc346.arrecadacaoINSS : ', m_ffpgc346.arrecadacaoINSS
              #   display 'm_ffpgc346.arrecadacaoPIS  : ', m_ffpgc346.arrecadacaoPIS
              #   display 'm_ffpgc346.arrecadacaoCOFIN: ', m_ffpgc346.arrecadacaoCOFIN
              #   display 'm_ffpgc346.arrecadacaoCSLL : ', m_ffpgc346.arrecadacaoCSLL
              #end if  
              #Fornax-Quantum - Fim 
              
              
              
              # regra de consistir flag = N, desconsidera cod arrecadacao. 05/03/10
              if m_ffpgc346.flagIR is null or m_ffpgc346.flagIR = "N"
                 then
                 let m_ffpgc346.arrecadacaoIR = null
              end if
              
              if m_ffpgc346.flagISS is null or m_ffpgc346.flagISS = "N"
                 then
                 let m_ffpgc346.arrecadacaoISS = null
              end if
              
              if m_ffpgc346.flagINSS is null or m_ffpgc346.flagINSS = "N"
                 then
                 let m_ffpgc346.arrecadacaoINSS = null
              end if
              
              if m_ffpgc346.flagPIS is null or m_ffpgc346.flagPIS = "N"
                 then
                 let m_ffpgc346.arrecadacaoPIS = null
              end if
              
              if m_ffpgc346.flagCOF is null or m_ffpgc346.flagCOF = "N"
                 then
                 let m_ffpgc346.arrecadacaoCOFIN = null
              end if
              
              if m_ffpgc346.flagCSLL is null or m_ffpgc346.flagCSLL = "N"
                 then
                 let m_ffpgc346.arrecadacaoCSLL = null
              end if
                            
              # definir o CBO
              if l_param.pestip = "F" and
                 l_param.pstcoddig <> 3
                 then
                 case m_opg_aux.pcpatvcod
                     when  3    # TAXI
                         let m_opg_aux.cbo = "7823"
                     when  2    # CHAVEIRO
                         let m_opg_aux.cbo = "5231"
                     otherwise
                         let m_opg_aux.cbo = "7825"
                 end case
              else
                 let m_opg_aux.cbo = ""
              end if
                            
              if m_opg_aux.pcpatvcod is null or m_opg_aux.pcpatvcod = ' ' then
                 let m_opg_aux.pcpatvcod = 0000
              end if
              
           end if  # busca dados OP

           # custo do item
           whenever error continue
           open cbdbsr1160012 using l_param.socopgnum,
                                    l_itm_aux.socopgitmnum
           fetch cbdbsr1160012 into l_itm_aux.socopgitmcst
           whenever error stop

           if l_itm_aux.socopgitmcst is null then
              let l_itm_aux.socopgitmcst = 0
           end if

           if  l_param.socpgtopccod = 2 then
               let l_param.socpgtopccod = 5
               let l_param.bcocod     = "00000"       # CÓDIGO DO BANCO
               let l_param.bcoagnnum  = "0000000000"  # NO DA AGÊNCIA
               let l_param.bcoagndig  = " "           # DV DA AGÊNCIA
               let l_param.bcoctanum  = "0000000000"  # NO DA CONTA CORRENTE
               let l_param.bcoctadig  = "  "          # DV DA CONTA CORRENTE
           else
               let l_param.socpgtopccod = 1
           end if

           let l_itm_aux.socopgitmtot = l_itm_aux.socopgitmvlr + l_itm_aux.socopgitmcst

           let l_itm_aux.atdetpdat = ''
           let l_itm_aux.asitipdes = ''
           let l_socvclcod = ""

           # buscar data de acionamento do servico
           whenever error continue
           open c_srvacp_sel using l_itm_aux.atdsrvnum,
                                   l_itm_aux.atdsrvano
           fetch c_srvacp_sel into l_itm_aux.atdetpdat,
                                   l_socvclcod
           whenever error stop

           # buscar tipo de assistencia
           if l_itm_aux.asitipcod is null or
              l_itm_aux.asitipcod <= 0
              then
              # origem 8 forcado porque asitipcod nao e gravado no servico
              if l_itm_aux.atdsrvorg = 8
                 then
                 let l_itm_aux.asitipdes = 'LOCACAO DE VEICULO'
              end if
           else
              whenever error continue
              open c_datkasitip_sel using l_itm_aux.asitipcod
              fetch c_datkasitip_sel into l_itm_aux.asitipdes
              whenever error stop
           end if

		  
	   ### Inclusao de Campos - Ligia - maio/2016
           let l_cod_ass = ""
           let l_des_ass = ""
           open cbdbsr116016 using l_itm_aux.atdsrvnum, l_itm_aux.atdsrvano,
                                   l_itm_aux.atdsrvnum, l_itm_aux.atdsrvano
           fetch cbdbsr116016 into l_cod_ass, l_des_ass
           close cbdbsr116016

           let l_clscod = ""
           open cbdbsr116017 using l_itm_aux.atdsrvnum, l_itm_aux.atdsrvano
           fetch cbdbsr116017 into l_clscod
           close cbdbsr116017

           let l_atdvclsgl = ""
           open cbdbsr116018 using l_socvclcod
           fetch cbdbsr116018 into l_atdvclsgl
           close cbdbsr116018

           #----------------------------------------------------------------

           # formatar valores para o arquivo
           print column 0001, "007"                                , # 01 CÓDIGO DA INTERFACE
                 column 0004, m_seq  using '&&&&&&&&&&'            , # 02 NO SEQUENCIAL DO REGISTRO
                 column 0014, l_param.pestip        clipped        , # 03 TIPO DE PESSOA
                 column 0015, "001"                                , # 04 CLASSE
                 column 0018, l_param.socopgfavnom  clipped        , # 05 NOME
                 column 0078, m_opg_aux.cpfcgctxt clipped          , # 06 CPF OU CNPJ
                 column 0092, m_opg_aux.endlgd[1,30]               , # 07 ENDEREÇO
                 column 0122, m_opg_aux.lgdnum    using '&&&&&'    , # 08 NO
                 column 0127, "          "                         , # 09 COMPLEMENTO
                 column 0137, m_opg_aux.endbrr[1,20]               , # 10 BAIRRO
                 column 0167, m_opg_aux.ufdsgl                     , # 11 ESTADO
                 column 0169, m_opg_aux.endcid[1,20]               , # 12 CIDADE
                 column 0199, m_opg_aux.cep                        , # 13 CEP
                 column 0209, m_opg_aux.maides clipped             , # 14 E-MAIL
                 column 0269, l_param.bcocod     using "&&&&&"     , # 15 CÓDIGO DO BANCO
                 column 0274, l_param.bcoagnnum  using "&&&&&&&&&&", # 16 NO DA AGÊNCIA
                 column 0284, l_param.bcoagndig                    , # 17 DV DA AGÊNCIA
                 column 0285, l_param.bcoctanum  using "&&&&&&&&&&", # 18 NO DA CONTA CORRENTE
                 column 0295, l_param.bcoctadig;                     # 19 DV DA CONTA CORRENTE

           # mostrar flags e valores conforme retorno do tributos
           # quando nao houver informacao, manda codigo de erro 999

           # FLAG INCIDÊNCIA IR
           if m_ffpgc346.flagIR is null
              then
              print column 0297, "   ";
           else
              if m_ffpgc346.flagIR = 'S'     # 20  CÓD TRIBUTAÇÃO IRRF
                 then
                 print column 0297, "001";
              else
                 print column 0297, "000";
              end if
           end if

           # NATUREZA DO RENDIMENTO (codigo arrecadacao IR)
           let m_opg_aux.ntzrnd = m_ffpgc346.arrecadacaoIR

           if m_opg_aux.ntzrnd is null    # 21 NATUREZA DO RENDIMENTO
              then
              print column 0300, "00000";
           else
              print column 0300, m_opg_aux.ntzrnd using "&&&&&";
           end if

           # FLAG INCIDÊNCIA ISS
           if m_ffpgc346.flagISS is null
              then
              print column 0305, " ";
           else
              if m_ffpgc346.flagISS = 'S'
                 then
                 print column 0305, "1";     # 22 CALCULA ISS ?
              else
                 print column 0305, "0";
              end if
           end if

           # FLAG INCIDÊNCIA INSS
           if m_ffpgc346.flagINSS is null
              then
              print column 0306, " ";
           else
              if m_ffpgc346.flagINSS = 'S'
                 then
                 print column 0306, "1";     # 23 CALCULA INSS ?
              else
                 print column 0306, "0";
              end if
           end if

           if m_ffpgc346.flagINSS is null
              then
              print column 0307, "   ";      # 24 CÓD TRIBUTAÇÃO INSS
           else
              if m_ffpgc346.flagINSS = 'S'
                 then
                 if l_param.pestip = "F"
                    then
                    print column 0307, "004";
                 else
                    print column 0307, "003";
                 end if
              else
                 print column 0307, "000";
              end if
           end if

           print column 0310, "00";          # 25 NO DE DEPENDENTES

           # reembolso PF nao precisa de PIS
           if l_param.pestip = "F" and           #26 NO PIS
              (l_param.soctip = 1 or l_param.soctip = 3) and
              m_opg_aux.pisnum is not null
              then
              print column 0312, m_opg_aux.pisnum using "&&&&&&&&&&&";
           else
              print column 0312, "00000000000";
           end if

           # inscricao somente PJ            # 27 INSCRICAO MUNICIPAL
           if l_param.pestip = "J" and
              m_opg_aux.muninsnum is not null
              then
              let l_aux3 = bdbsr116_pontuacao(m_opg_aux.muninsnum)
              print column 0323, l_aux3;
           else
              print column 0323, "00000000000";
           end if

           print column 0334, "0000000000";  # 28 NÚMERO INTERNO DO CORRETOR

           print column 0344, m_opg_aux.cbo clipped;     # 29  CBO (CLASSIFIC BRASILEIRA OCUPAÇÃO)

           print column 0349, "00000000000000"                          , # 30 CÓDIGO SUSEP
                 column 0363, "0000000000"                              , # 31 NO DO FUNCIONÁRIO
                 column 0373, "               "                         , # 32 CÓD DA FILIAL
                 column 0388, "               "                         , # 33 CÓD DO CENTRO DE CUSTO
                 column 0403, "0000000000"                              , # 34 NO CARTEIRA DE SAUDE
                 column 0413, "00000000"                                , # 35 DATA DE NASCIMENTO
                 column 0421, l_param.pestip       clipped              , # 36 TIPO DE PESSOA
                 column 0422, "001"                                     , # 37 CLASSE
                 column 0425, l_param.socopgfavnom clipped              , # 38 NOME
                 column 0485, m_opg_aux.cpfcgctxt clipped               , # 39 CPF OU CNPJ
                 column 0499, l_param.bcocod     using "&&&&&"          , # 40 CÓDIGO DO BANCO
                 column 0504, l_param.bcoagnnum  using "&&&&&&&&&&"     , # 41 NO DA AGÊNCIA
                 column 0514, l_param.bcoagndig                         , # 42 DV DA AGÊNCIA
                 column 0515, l_param.bcoctanum  using "&&&&&&&&&&"     , # 43 NO DA CONTA CORRENTE
                 column 0525, l_param.bcoctadig                         , # 44 DV DA CONTA CORRENTE
                 column 0527, l_param.socopgnum  clipped                , # 45 IDENTIFICAÇÃO DO PAGAMENTO
                              " ", l_itm_aux.atdsrvnum using "&&&&&&&",
                              "-", l_itm_aux.atdsrvano using "&&",
                 column 0552, "00001";                                    # 46 CÓD DA EMPRESA

           if l_itm_aux.succod = 0           # 47  CÓD DA FILIAL
              then
              print column 0557, "00099";
           else
              print column 0557, l_itm_aux.succod using "&&&&&";
           end if

           # codigo do evento, reembolso(nao prestador) ou prestador
           if (l_param.pstcoddig = 3 or l_param.lcvcod = 33) or
              l_param.segnumdig is not null
              then                           # 48 CODIGO DO EVENTO
              print column 0562, "11363";
           else
              if l_favtip = 4
                 then
                 print column 0562, "11366";
              else
                 print column 0562, "11364";
              end if
           end if

           print column 0567, "114";         # 49 TIPO DE OPERACAO

           print column 0570, l_param.socpgtopccod using '&&&';                  # 50  FORMA DE PAGAMENTO
           print column 0573, l_itm_aux.nfsnum     using '<<<<<<<<<<<<<<<<<<<&'; # 51  NO DO DOCUMENTO

           let l_aux = bdbsr116_data(l_param.socemsnfsdat)
           print column 0593, l_aux;         # 52 DATA DE EMISSAO

           let l_aux = bdbsr116_data(l_param.socfatpgtdat)
           print column 0601, l_aux;         # 53 DATA DE VENCIMENTO

           print column 0609, " ";           # 54 SINAL DO VALOR BRUTO

           let l_txtitmtot = bdbsr116_valor(l_itm_aux.socopgitmtot)
           print column 0610, l_txtitmtot;   # 55 VALOR BRUTO

           print column 0628, " ";           # 56 SINAL DO VALOR ISENTO IR

           if m_ffpgc346.flagIR is null      # 57 VALOR ISENTO IR
              then
              print column 0629, "                  ";
           else
              #Fornax - Quantum - inicio
              #if m_ffpgc346.flagIR = "S"
              #   then
              #   print column 0629, "000000000000000000";
              #else
              #   print column 0629, l_txtitmtot;
              #end if
              
              print column 0629, "000000000000000000";
              #Fornax - Quantum - final
           end if

           print column 0647, " ";           # 58 SINAL DO VALOR TRIBUTÁVEL IR

           if m_ffpgc346.flagIR is null      # 59 VALOR TRIBUTÁVEL IR
              then
              print column 0648, "                  ";
           else
              #Fornax - Quantum - inicio
              #if m_ffpgc346.flagIR = "S"
              #   then
              #   print column 0648, l_txtitmtot;
              #else
              #   print column 0648, "000000000000000000";
              #end if
              
              print column 0648, "000000000000000000";
              #Fornax - Quantum - final
           end if

           print column 0666, " ";           # 60 SINAL DO VALOR ISENTO ISS

           if m_ffpgc346.flagISS is null     # 61 VALOR ISENTO ISS
              then
              print column 0667, "                  ";
           else
              #Fornax - Quantum - inicio
              #if m_ffpgc346.flagISS = "S"
              #   then
              #   print column 0667, "000000000000000000";
              #else
              #   print column 0667, l_txtitmtot;
              #end if
              
              print column 0667, "000000000000000000";
              #Fornax - Quantum - final
           end if

           print column 0685, " ";           # 62 SINAL DO VALOR TRIBUTÁVEL ISS

           if m_ffpgc346.flagISS is null     # 63 VALOR TRIBUTÁVEL ISS
              then
              print column 0686, "                  ";
           else
              #Fornax - Quantum - inicio
              #if m_ffpgc346.flagISS = "S"
              #   then
              #   print column 0686, l_txtitmtot;
              #else
              #   print column 0686, "000000000000000000";
              #end if
              
              print column 0686, "000000000000000000";
              #Fornax - Quantum - final
           end if

           print column 0704, " "   ;        # 64 SINAL DO VALOR ISENTO INSS

           if m_ffpgc346.flagINSS is null    # 65 VALOR ISENTO INSS
              then
              print column 0705, "                  ";
           else
              #Fornax - Quantum - inicio
              #if m_ffpgc346.flagINSS = "S"
              #   then
              #   print column 0705, "000000000000000000";
              #else
              #   print column 0705, l_txtitmtot;
              #end if
              
              print column 0705, "000000000000000000";
              #Fornax - Quantum - final
           end if

           print column 0723, " ";           # 66 SINAL DO VALOR TRIBUTÁVEL INSS

           if m_ffpgc346.flagINSS is null    # 67 VALOR TRIBUTÁVEL INSS
              then
              print column 0724, "                  ";
           else
              #Fornax - Quantum - inicio
              #if m_ffpgc346.flagINSS = "S"
              #   then
              #   print column 0724, l_txtitmtot;
              #else
              #   print column 0724, "000000000000000000";
              #end if
              
              print column 0724, "000000000000000000";
              #Fornax - Quantum - final
           end if

           print column 0742, " ";                                        # 68 SINAL DO VALOR ISS
           print column 0743, "000000000000000000";                       # 69 VALOR ISS
           print column 0761, " "                                       , # 70 SINAL DO VALOR JUROS
                 column 0762, "000000000000000000"                      , # 71 VALOR JUROS
                 column 0780, " "                                       , # 72 SINAL DO VALOR MULTA
                 column 0781, "000000000000000000"                      , # 73 VALOR MULTA
                 column 0799, "PAGAMENTO DE PRESTADORES PORTO SOCORRO." , # 74 DESCRIÇÃO
                 column 0859, " "                                       , # 75 SINAL DO VALOR CPMF
                 column 0860, "000000000000000000"                      , # 76 VALOR CPMF
                 column 0878, " "                                       , # 77 SINAL DO VALOR BASE DA MP 2222
                 column 0879, "000000000000000000"                      , # 78 VALOR BASE DA MP 2222
                 column 0897, " "                                       , # 79 SINAL DO VALOR IR MP 2222
                 column 0898, "000000000000000000"                      , # 80 VALOR IR MP 2222
                 column 0916, "00000"                                   , # 81 COD DA RECEITA
                 column 0921, l_itm_aux.succod   using '&&', '48'       , # 82 SUCURSAL (CÓDIGO SUNSYSTEMS)

                 ### Inclusao de Campos - Ligia - maio/2016
                 column 0940, " "                         , # 86 BRANCO
                 column 0941, lr_azul.vcllicnum           , # 87 PLACA SEGURADO
                 column 0948, " "                         , # 88 BRANCO    
                 column 0949, l_itm_aux.vcllicnum         , # 89 PLACA VEICULO
                 column 0956, " "                         , # 90 BRANCO   
                 column 0957, l_cnpj_cpf                  , # 91 CNPJ CPF SEGURADO
                 column 0971, " "                         , # 92 BRANCO
                 column 0972, l_cod_ass                   , # 93 COD ASSUNTO
                 column 0975, " "                         , # 94 BRANCO     
                 column 0976, l_des_ass                   , # 95 DES ASSUNTO
                 column 1000, " "                         , # 96 BRANCO     
                 column 1001, l_itm_aux.atdsrvorg using "<" , # 97 TIPO SERVICO
                 column 1002, " "                         , # 98 BRANCO      
                 column 1003, l_clscod                    , # 99 CLAUSULA    
                 column 1006, " "                         , #100 BRANCO      
                 column 1010, " "                         , #102 BRANCO      

                 column 1011, l_itm_aux.succod using "&&"               , # 88 APOLICE
                              " ", l_itm_aux.ramcod using "&&&"         ,
                              " ", l_itm_aux.aplnumdig using "&&&&&&&&" ,
                 column 1026, " "                         , #  A DEFINIR
                 column 1027, l_atdvclsgl                 , #101 COD VIATURA 
                 column 1041, "               "                         , # 90 A DEFINIR

                 column 1056, l_itm_aux.atdetpdat using "ddmmyyyy"      , # 91 DATA DE ACIONAMENTO

                 column 1071, l_itm_aux.asitipdes[1,15]                 , # 92 TIPO DE ASSISTENCIA

                 column 1101, "                         "               , # 93 REF_BANCO
                 column 1126, "     "                                   , # 94 BRANCOS
                 column 1131, "             "                           ; # 95 RESERVADO

           print column 1144, " ";           # 96 SINAL DO VALOR ISENTO CCP

           if m_ffpgc346.flagPIS  is null or
              m_ffpgc346.flagCOF  is null or
              m_ffpgc346.flagCSLL is null    # 97 VALOR ISENTO CCP
              then
              print column 1145, "                  ";
           else
              if m_ffpgc346.flagPIS  = "N" and
                 m_ffpgc346.flagCOF  = "N" and
                 m_ffpgc346.flagCSLL = "N"
                 then
                 print column 1145, l_txtitmtot;
              else
                 print column 1145, "000000000000000000";
              end if
           end if

           print column 1163, " ";           # 98 SINAL DO VALOR TRIBUTÁVEL CCP

           if m_ffpgc346.flagPIS  is null or
              m_ffpgc346.flagCOF  is null or
              m_ffpgc346.flagCSLL is null    # 99 VALOR TRIBUTÁVEL CCP
              then
              print column 1164, "                  ";
           else
              if m_ffpgc346.flagPIS  = "N" and
                 m_ffpgc346.flagCOF  = "N" and
                 m_ffpgc346.flagCSLL = "N"
                 then
                 print column 1164, "000000000000000000";
              else
                 print column 1164, l_txtitmtot;
              end if
           end if

           if m_ffpgc346.flagCSLL is null    # 100 CODIGO TRIBUTACAO CSLL
              then
              print column 1182, "   ";
           else
              if m_ffpgc346.flagCSLL = "S"
                 then
                 print column 1182, "001";
              else
                 print column 1182, "000";
              end if
           end if

           if m_ffpgc346.flagCOF is null    # 101 CODIGO TRIBUTACAO COFINS
              then
              print column 1185, "   ";
           else
              if m_ffpgc346.flagCOF = "S"
                 then
                 print column 1185, "001";
              else
                 print column 1185, "000";
              end if
           end if

           if m_ffpgc346.flagPIS is null    # 102 CODIGO TRIBUTACAO PIS
              then
              print column 1188, "   ";
           else
              if m_ffpgc346.flagPIS = "S"
                 then
                 print column 1188, "001";
              else
                 print column 1188, "000";
              end if
           end if

           print column 1191, "               "    , # 103 USO AXA
                 column 1206, "               "    , # 104 USO AXA
                 column 1221, "               "    , # 105 USO AXA
                 column 1236, "P"                  ; # 106 TIPO DE MOVIMENTO

           let l_aux = bdbsr116_data(l_param.socfatpgtdat)

           print column 1237, l_aux                              , # 107 DATA DO PAGAMENTO
                 column 1245, " "                                , # 108 SINAL DO VALOR PAGO
                 column 1246, "000000000000000000"               , # 109 VALOR PAGO
                 column 1264, "00000"                            , # 110 CÓDIGO DO BANCO
                 column 1269, "0000000000"                       , # 111 NO DA AGÊNCIA
                 column 1279, "0000000000"                       , # 112 NO DA CONTA CORRENTE
                 column 1289, "000000000000000"                  , # 113 NO DO CHEQUE
                 column 1304, " "                                , # 114 SINAL DO VALOR IRRF
                 column 1305, "000000000000000000"               , # 115 VALOR IRRF
                 column 1323, " "                                , # 116 SINAL DO VALOR ISS
                 column 1324, "000000000000000000"               , # 117 VALOR ISS
                 column 1342, " "                                , # 118 SINAL DO VALOR INSS
                 column 1343, "000000000000000000"               , # 119 VALOR INSS
                 column 1361, " "                                , # 120 SINAL DO VALOR CSLL
                 column 1362, "000000000000000000"               , # 121 VALOR CSLL
                 column 1380, " "                                , # 122 SINAL DO VALOR COFINS
                 column 1381, "000000000000000000"               , # 123 VALOR COFINS
                 column 1399, " "                                , # 124 SINAL DO VALOR PIS
                 column 1400, "000000000000000000"               , # 125 VALOR PIS
                 column 1418, "000"                              , # 126 COD OCORRÊNCIA
                 column 1421, ""                                 , # 127 DESCRIÇÃO DA OCORRÊNCIA
                 column 1481, "000"                              , # 128 FORMA DE PAGAMENTO EFETIVA
                 column 1484, m_opg_aux.pcpatvcod  using "&&&&";   # 129 CODIGO DA ATIVIDADE PRINCIPAL 
                 
                 display "l_simoptpstflg: ",l_simoptpstflg
                    if m_opg_aux.pcpatvcod is null or
                       m_opg_aux.pcpatvcod = 0     or
                       m_opg_aux.pcpatvcod = ' ' then
                       
                       let l_simoptpstflg = 'N' 
                       let l_param.infissalqvlr = '*0000*00*'
                    else
                       if l_simoptpstflg is null or 
                          l_simoptpstflg = ' ' then
                           let l_simoptpstflg = 'N'
                       end if
                       
                       if l_param.infissalqvlr <> '*0000*00*' then
                          let l_simoptpstflg = 'S' 
                       else
                          let l_simoptpstflg = 'N' 
                       end if 
                    end if 
                    
                    
                                                
           print column 1488, l_simoptpstflg                     , # 130 FLAG OPTANTE PELO SIMPLES
                 column 1489, l_param.infissalqvlr                 # 131 ALIQUOTA DA OP

           let m_seq = m_seq + 1
           let l_srvop = l_srvop + 1
           let l_vlrop = l_vlrop + l_itm_aux.socopgitmtot

           initialize l_itm_aux.* to null

        end foreach

        output to report bdbsr017_res_azul(l_param.socopgnum,
                                           l_param.socopgfavnom,
                                           l_srvop,
                                           l_vlrop)
        let l_srvop  = 0
        let l_vlrop  = 0

 end report

#-------------------------------------#
 report bdbsr017_res_azul(l_res)
#-------------------------------------#
  define l_res record
         socopgnum    like dbsmopg.socopgnum,
         socopgfavnom like dbsmopgfav.socopgfavnom,
         l_srvop      integer,
         l_vlrop      like dbsmopg.socfattotvlr
  end record

  define l_srvtot     integer,
         l_vlrtot     like dbsmopg.socfattotvlr

  output
    page length    60
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format

     first page header

        let l_srvtot = 0
        let l_vlrtot  = 0

        print "Resumo de pagamentos de serviços para Azul Seguro com vencimento em ", m_data
        print ""
        print "OP       Prestador                                  Servicos          Valor"

     on last row
        print "                                                    --------   ------------"
        print "                                                    ", 
              l_srvtot using "########", "   ", l_vlrtot using "########&.&&"

     on every row
        print l_res.socopgnum using "&&&&&&", "   ", l_res.socopgfavnom, "   ",
              l_res.l_srvop using "########", "  ", l_res.l_vlrop using "########&.&&"
        let l_srvtot = l_srvtot + l_res.l_srvop
        let l_vlrtot = l_vlrtot + l_res.l_vlrop

 end report


#------------------------------------#
 function bdbsr116_pontuacao(l_valor)
#------------------------------------#

     define l_valor  char(018),
            l_return char(011),
            l_ind    smallint

     let l_return = " "

     for l_ind = 1 to length(l_valor)
         if  l_valor[l_ind] <> '.' and l_valor[l_ind] <> ',' and l_valor[l_ind] <> '-' then
             let l_return = l_return clipped, l_valor[l_ind]
         end if
     end for

     let l_return = l_return using "&&&&&&&&&&&"

     return l_return

 end function

#--------------------------------#
 function bdbsr116_valor(l_param)
#--------------------------------#

     define l_param  decimal(15,5),
            l_valor  char(018),
            l_return char(018),
            l_ind    smallint

     let l_valor = l_param using "<<<<<<<<<<<<<<&.&&"
     let l_return = " "

     for l_ind = 1 to length(l_valor)
         if  l_valor[l_ind] <> ',' and l_valor[l_ind] <> '.' then
             let l_return = l_return clipped, l_valor[l_ind]
         end if
     end for

     let l_return = l_return using "&&&&&&&&&&&&&&&&&&"

     return l_return

 end function

#------------------------------#
 function bdbsr116_data(m_data)
#------------------------------#

     define m_data date,
            l_return char(08)

     let l_return = " "

     if  m_data is not null and m_data <> " " then
         let l_return = extend(m_data, year to year) clipped,
                        extend(m_data, month to month) clipped,
                        extend(m_data, day to day)
     end if

     return l_return

 end function
 
 
 #--------------------------------#
 function bdbsr116_valor_aliquota(l_param)
#--------------------------------#

     define l_param     decimal(4,2),
            l_return    char(09),
            l_valor   char(09),
            l_valorInt  char(4),
            l_valorDec  char(2),
            l_ind       smallint

     display "l_param: ",l_param
     let l_valor = l_param using "<<<&.&&"
     let l_return = " "

     for l_ind = 1 to length(l_valor)
         if  l_valor[l_ind] <> ',' and l_valor[l_ind] <> '.' then
             let l_return = l_return clipped, l_valor[l_ind]
         else
            let l_valorInt = l_return clipped 
            let l_return   = null
         end if
     end for
     
     let l_valorDec = l_return clipped
     let l_return = "*",l_valorInt using "&&&&","*",l_valorDec using "&&","*"
     
     display "l_return: ",l_return
     return l_return

 end function

