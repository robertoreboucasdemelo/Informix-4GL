#-----------------------------------------------------------------------------#
# Sistema....: Porto Socorro                                                  #
# Modulo.....: bdbsr115                                                       #
# Analista Resp.: Beatriz Araujo                                              #
# PSI......: PSI-2010-02124-PR - Relatorio/Arquivo de pagamento Itau          #
#                     carga: Arquivo txt                                      #
#                     res  : Documento com resumo de pagamento                #
# --------------------------------------------------------------------------- #
# Desenvolvimento: Beatriz Araujo                                             #
# Liberacao...: 24/03/2011                                                    #
# --------------------------------------------------------------------------- #
#                                 Alteracoes                                  #
# --------------------------------------------------------------------------- #
# Data        Autor           Origem     Alteracao                            #
# ----------  --------------  ---------- -------------------------------------#
# 12/03/2013 Raul, BIZ         PSI-2012-23608  Alteracoes no End. do Prestador#
#-----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_data       char(10) ,
       m_patharq    char(100),
       m_pathres    char(100),
       m_pathresex  char(100),
       m_pathresumo char(100),
       m_datautil   char(10) ,
       m_socopgnum  like dbsmopg.socopgnum,
       m_valorOP    like dbsmopg.socfattotvlr,
       m_valorTotOP char(017),
       m_seqArq     like datkgeral.grlinf,
       m_path2      char(100),
       m_texto      char(400)

#------------------------------
main
#------------------------------
  define l_pathtxt    char(100),
         l_ciaempcod  smallint ,
         l_hostname   char(3)  ,
         l_comando    char(200),
         l_retorno    smallint

 #------------------------------------------------------------
 # inicializa as variaveis
 #------------------------------------------------------------
  initialize l_pathtxt,l_ciaempcod,l_hostname,l_comando,l_retorno  to null 
  
 #------------------------------------------------------------
 # Abre conexao com o banco de dados e pega o caminho do arquivo e log
 #------------------------------------------------------------
   call fun_dba_abre_banco("CT24HS")

   let m_path2 = f_path("DBS","LOG")
   if m_path2 is null then
      let m_path2 = "."
   end if

   let m_path2 = m_path2 clipped, "/bdbsr115.log"
   call startlog(m_path2)
   
   display "Log: ",m_path2
   
   let m_patharq = f_path("DBS", "ARQUIVO")
   if m_patharq is null then
      let m_patharq = "."
   end if

  #let m_patharq = "/adbs"
  let m_seqArq = null
  
 #------------------------------------------------------------      
 # verifica a data para o processamento
 #------------------------------------------------------------      
  let m_data = arg_val(1)
  let m_seqArq = arg_val(2)
  
  if m_data is null or m_data = " " then
     let m_data = today
  end if
 
  display 'Data atual.....: ', m_data
  
  #------------------------------------------------------------      
  # VERIFICA SE A DATA DE PROCESSAMENTO E DIA UTIL
  #------------------------------------------------------------      
  let m_datautil = dias_uteis(m_data, 0, "", "S", "S")
 
  display 'Dia util.......: ', m_datautil
 
  if m_datautil <> m_data then
     display "Nao executou pois para a Porto nao eh dia util"
     display "m_datautil: ",m_datautil
     display "m_data: ",m_data
     exit program
  end if
 
  let m_data = dias_uteis(m_data, 2, "", "S", "S")

  display 'Data referencia: ', m_data
 
  #------------------------------------------------------------      
  # Cria o caminho juntamente com o nome do arquivo
  #------------------------------------------------------------      
  let l_pathtxt = m_patharq clipped,"/ITAU.PGTO.", m_data[7,10], m_data[4,5], m_data[1,2], ".txt"
  let m_pathres = m_patharq clipped,"/ITAU.PGTO.", m_data[7,10], m_data[4,5], m_data[1,2], ".doc"
  let m_pathresex = m_patharq clipped,"/PGTO_ITAU_", m_data[7,10], m_data[4,5], m_data[1,2], ".xls"
  let m_pathresumo = m_patharq clipped,"/PGTO_ITAU_", m_data[7,10], m_data[4,5], m_data[1,2], ".txt"

  display 'Arquivos:'
  display 'l_pathtxt: ', l_pathtxt clipped
  display 'm_pathres: ', m_pathres clipped
  display "m_pathresex: ", m_pathresex clipped
  display "m_pathresumo: ", m_pathresumo clipped
 
  #------------------------------------------------------------ 
  # Cria o prepare
  #------------------------------------------------------------ 
     call bdbsr115_prepare()
   
  #------------------------------------------------------------ 
  # Abre o relatorio
  #------------------------------------------------------------ 

     start report bdbsr115_resumo to m_pathresumo  # abre o relatorio de erro que sera enviado
     
     call bdbsr115(l_pathtxt)
     
     finish report bdbsr115_resumo  # Fecha o relatorio de erro que sera enviado
     

  display 'Relatorio finalizado'
     
    #-----------------------------------------------------
    # Update para atualizar a ultima versão enviada
    #-----------------------------------------------------
    whenever error continue 
       execute pbdbsr115016 using m_seqArq
    whenever error stop
  
  #------------------------------------------------------------ 
  # Envia e-mail com os pagamentos
  #------------------------------------------------------------ 
  
  call bdbsr115_email(l_pathtxt,"Arquivo de pagamento ITAU AUTO E RESIDENCIA")
  call bdbsr115_email(m_pathres,"Resumo de pagamento ITAU AUTO E RESIDENCIA")
  call bdbsr115_email(m_pathresex,"Excel ITAU AUTO E RESIDENCIA")
  call bdbsr115_email_erro(m_pathresumo,"Erro no pagamento para o dia: ")
     
end main


#=============================================================================
function bdbsr115_prepare()
#=============================================================================

 define sql_comando  char(1000)
  
 let sql_comando =  "select dbsmopg.socopgnum,       ",
                    "       dbsmopg.socfatpgtdat,    ",
                    "       dbsmopg.socfattotvlr,    ",
                    "       dbsmopg.pstcoddig,       ",
                    "       dbsmopg.empcod,          ",
                    "       dbsmopg.socemsnfsdat,    ",
                    "       dbsmopg.soctip,          ",
                    "       dbsmopg.lcvcod,          ",
                    "       dbsmopg.aviestcod,       ",
                    "       dbsmopg.segnumdig,       ",
                    "       dbsmopg.succod,          ", 
                    "       dbsmopg.favtip,          ",
                    "       dbsmopg.infissalqvlr     ", 
                    "  from dbsmopg dbsmopg          ",
                    " where dbsmopg.socopgsitcod = 7 ",
                    "   and dbsmopg.socfatpgtdat = ? ",
                    "   and dbsmopg.empcod = 84      "
   prepare p_bdbsr115_princ from sql_comando             
   declare c_bdbsr115_princ cursor with hold for p_bdbsr115_princ 
  
  
  let sql_comando = "select socopgfavnom, ",
                    "       cgccpfnum   , ",
                    "       cgcord      , ",
                    "       cgccpfdig   , ",
                    "       pestip      , ",
                    "       bcocod      , ",
                    "       bcoagnnum   , ",
                    "       bcoagndig   , ",
                    "       bcoctanum   , ",
                    "       bcoctadig   , ",
                    "       socpgtopccod  ",
                    "  from dbsmopgfav    ",
                    " where socopgnum = ? "
  prepare sel_opgfav from sql_comando
  declare c_opgfav cursor with hold for sel_opgfav

  let sql_comando = " select endcmp      , ",
                           " mpacidcod   , ",
                           " maides      , ",
                           " muninsnum   , ",
                           " pcpatvcod   , ",
                           " pisnum      , ",
                           " succod      , ",
                           " simoptpstflg  ",
                      " from dpaksocor ",
                     " where pstcoddig = ? "
  prepare pbdbsr115006 from sql_comando
  declare cbdbsr115006 cursor with hold for pbdbsr115006

  #Raul Biz
  #let sql_comando = " select cidnom, ",
  #                         " ufdcod ",
  #                    " from glakcid ",
  #                   " where cidcod = ? "
  #prepare pbdbsr115007 from sql_comando
  #declare cbdbsr115007 cursor with hold for pbdbsr115007

  let sql_comando = "select apl.succod, ",
                    "       apl.ramcod, ",
                    "       apl.aplnumdig, ",
                    "       apl.itmnumdig, ",
                    "       itm.atdsrvnum, ",
                    "       itm.atdsrvano, ",
                    "       itm.socopgitmnum, ",
                    "       itm.socopgitmvlr, ", 
                    "       srv.vcllicnum,    ",
                    "       srv.asitipcod, ",
                    "       itm.nfsnum, ",
                    "       srv.atdsrvorg,",
                    "       srv.atddat,   ",                                    
                    "       srv.atddatprg,",                                    
                    "       srv.atdhor,   ",                                    
                    "       srv.atdhorprg,",
                    "       srv.cnldat,",
                    "       srv.atdfnlhor",
                    " from dbsmopgitm itm , outer datrservapol apl, ",
                    "      datmservico srv ",
                    "where itm.atdsrvnum = apl.atdsrvnum ",
                    "  and itm.atdsrvano = apl.atdsrvano ",
                    "  and itm.atdsrvnum = srv.atdsrvnum ",
                    "  and itm.atdsrvano = srv.atdsrvano ",
                    "  and socopgnum = ? "
  prepare pbdbsr1150011 from sql_comando
  declare cbdbsr1150011 cursor with hold for pbdbsr1150011

  let sql_comando = "select sum(socopgitmcst) ",
                    "  from dbsmopgcst ",
                    "where socopgnum    = ? ",
                    "  and socopgitmnum = ? "
  prepare pbdbsr1150012 from sql_comando
  declare cbdbsr1150012 cursor with hold for pbdbsr1150012

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
  prepare pbdbsr1150014 from sql_comando
  declare cbdbsr1150014 cursor with hold for pbdbsr1150014

  let sql_comando = " select a.atdetpdat,a.atdetphor "
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
  
  let sql_comando = "select grlinf                 ",  
                    "  from datkgeral              ",  
                    " where grlchv ='BDBDR115_SEQARQ'"  
              
  prepare pbdbsr115015 from sql_comando               
  declare cbdbsr115015 cursor with hold for pbdbsr115015 
  
  let sql_comando = "update datkgeral", 
                    "   set grlinf = ?",
                    " where grlchv ='BDBDR115_SEQARQ'"                
  prepare pbdbsr115016 from sql_comando  
  
  let sql_comando = " select nscdat,       ",  
                    "        sexcod        ",
                    "   from dpaksocorfav  ",
                    "  where pstcoddig = ? "
  prepare pbdbsr115017 from sql_comando
  declare cbdbsr115017 cursor with hold for pbdbsr115017
  
  
  let sql_comando = " select socntzcod+1000,nvl(socntzdes,'')  ",             
                    "   from datksocntz                        ",             
                    "  where socntzcod = (select socntzcod     ",             
                    "                       from datmsrvre     ", 
                    "                      where atdsrvnum = ? ",
                    "                        and atdsrvano = ?)"
  prepare pbdbsr115018 from sql_comando                   
  declare cbdbsr115018 cursor with hold for pbdbsr115018
  
  let sql_comando = " select cpocod||' - '||cpodes",  
                    "   from iddkdominio          ",  
                    "  where cponom = 'pcpatvcod' ",  
                    "    and cpocod = ? "
  prepare pbdbsr115019 from sql_comando                            
  declare cbdbsr115019 cursor with hold for pbdbsr115019          
  
  let sql_comando = "select cidnom,",            
                    "       ufdcod,",            
                    "       brrnom ",            
                    "  from datmlcl",            
                    " where atdsrvnum = ?",      
                    "   and atdsrvano = ?",      
                    "   and c24endtip = 1"       
  prepare pbdbsr115020 from sql_comando          
  declare cbdbsr115020 cursor for pbdbsr115020   
  
  let sql_comando = " select a.ligdat,          ",           
                    "        a.lighorinc        ",           
                    "   from datmligacao a      ",   
                    "  where a.lignum = (select min(lignum)  ",                
                    "                     from datmligacao  ",                
                    "                    where atdsrvnum = ?",                
                    "                      and atdsrvano = ?)"                 
  prepare pbdbsr115021 from sql_comando                     
  declare cbdbsr115021 cursor with hold for pbdbsr115021    
    
  let sql_comando = "select b.c24astagp    ",
                    "  from datmligacao a, ",
                    "       datkassunto b  ",
                    " where a.c24astcod = b.c24astcod       ",
                    "   and a.lignum = (select min(lignum)  ",
                                      "  from datmligacao   ",
                                      " where atdsrvnum = ? ",
                                      "   and atdsrvano = ?)" 
  prepare pbdbsr115022 from sql_comando                                                                               
  declare cbdbsr115022 cursor with hold for pbdbsr115022 
  
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
  prepare pbdbsr116022 from sql_comando
  declare cbdbsr116022 cursor with hold for pbdbsr116022 
  
  end function

#=============================================================================
function bdbsr115_email(param)
#=============================================================================
 
 define param record
    path        char(100),     
    descricao   char(50)
 end record
 
 define l_comando    char(200),
        l_retorno    smallint
 
 
 whenever error continue
    let l_comando = "gzip -c ", param.path clipped ," > ",param.path clipped, ".gz" 
    run l_comando
    let param.path = param.path clipped, ".gz"
     
    let l_retorno = ctx22g00_envia_email("BDBSR115", param.descricao, param.path)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro de envio de email(cx22g00)- ",param.path
       else
          display "Nao ha email cadastrado para o modulo bdbsr115 "
       end if
    end if
 whenever error stop 

end function 

#=============================================================================
function bdbsr115_email_erro(param)
#=============================================================================
 
 define param record
    path        char(100),     
    descricao   char(50)
 end record
 
 define l_comando    char(200),
        l_retorno    smallint
 
 
 whenever error continue
     
    let param.descricao = param.descricao clipped, m_data 
    let l_retorno = ctx22g00_mail_anexo_corpo("BDBSR115", param.descricao, param.path)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro de envio de email(cx22g00)- ",param.path
       else
          display "Nao ha email cadastrado para o modulo bdbsr115 "
       end if
    end if
 whenever error stop 

end function 


#=============================================================================
function bdbsr115(l_pathtxt)
#=============================================================================

define l_pathtxt    char(100)

  define d_bdbsr115   record
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
         ramcod           like datrservapol.ramcod    ,
         aplnumdig        like datrservapol.aplnumdig ,
         itmnumdig        like datrservapol.itmnumdig ,
         atdsrvnum        like datrservapol.atdsrvnum ,
         atdsrvano        like datrservapol.atdsrvano ,
         socopgitmnum     like dbsmopgitm.socopgitmnum,
         socopgitmvlr     like dbsmopgitm.socopgitmvlr,
         asitipcod        like datmservico.asitipcod  ,
         atdsrvorg        like datmservico.atdsrvorg  ,
         atdetpdat        like datmsrvacp.atdetpdat   ,
         asitipdes        like datkasitip.asitipdes   ,
         socopgitmcst     like dbsmopgcst.socopgitmcst,
         socopgitmtot     like dbsmopgitm.socopgitmvlr,
         vcllicnum        like datmservico.vcllicnum ,
         socntzcod        like datksocntz.socntzcod,
         socntzdes        like datksocntz.socntzdes,
         atddat           like datmservico.atddat,  
         atddatprg        like datmservico.atddatprg,
         atdhor           like datmservico.atdhor,  
         atdhorprg        like datmservico.atdhorprg,
         ligdat           like datmligacao.ligdat,    
         lighorinc        like datmligacao.lighorinc,
         cidnom           like datmlcl.cidnom,
         ufdcod           like datmlcl.ufdcod,
         brrnom           like datmlcl.brrnom,
         cnldat           like datmservico.cnldat,
         atdfnlhor        like datmservico.atdfnlhor,
         infissalqvlr     like dbsmopg.infissalqvlr,
         c24astagp     like datkassunto.c24astagp
  end record  
                                     
  define d_opg_dados record                            
         endlgd        like dpaksocor.endlgd       , 
         lgdnum        like dpakpstend.lgdnum       , 
         endbrr        like dpakpstend.endbrr       , 
         endcmp        like dpaksocor.endcmp       ,
         mpacidcod     like dpaksocor.mpacidcod    , 
         endcep        like dpakpstend.endcep       , 
         endcepcmp     like dpakpstend.endcepcmp, 
         maides        like dpaksocor.maides       , 
         muninsnum     like dpaksocor.muninsnum    , 
         endcid        like dpakpstend.endcid         , 
         ufdsgl        like dpakpstend.ufdsgl          , 
         pcpatvcod     like dpaksocor.pcpatvcod    , 
         pisnum        like dpaksocor.pisnum       , 
         corsus        like dbsmopg.corsus         , 
         prscootipcod  like dpaksocor.prscootipcod , 
         pstsuccod     like dpaksocor.succod       , 
         cpfcgctxt     char(015)                   , 
         cep           char(10)                    , 
         ntzrnd        decimal(5,0)                , 
         cbo           char(5)                     ,
         cidcod        like gabksuc.cidcod         ,
         simoptpstflg  like dpaksocor.simoptpstflg
  end record                                         

  define l_cts54g00 record
         errcod        smallint ,
         errdes        char(80) ,
         tpfornec      char(3)  ,
         retencod      like fpgkplprtcinf.ppsretcod ,
         socitmtrbflg  char(1)  ,
         retendes      char(50)
  end record  
  
  define l_ffpgc346 record
         flagIR            char(001),
         flagISS           char(001),
         flagINSS          char(001),
         flagPIS           char(001),
         flagCOF           char(001),
         flagCSLL          char(001),
         arrecadacaoIR     char(004),
         arrecadacaoISS    char(004),
         arrecadacaoINSS   char(004),
         arrecadacaoPIS    char(004),
         arrecadacaoCOFIN  char(004),
         arrecadacaoCSLL   char(004)
end record  

define lr_relatorio record
       flagIR              char(003)
     , flagISS             char(001)
     , flagINSS            char(001)
     , arrecadacaoIR       char(005)
     , codtributacaoINSS   char(003)
     , pisnum              like dpaksocor.pisnum
     , muninsnum           like dpaksocor.muninsnum 
     , succod              like dbsmopg.succod
     , codeventoreembolso  smallint 
     , valorisentoIR       char(018)
     , valortributavelIR   char(018)
     , valorisentoISS      char(018)
     , valortributavelISS  char(018)
     , valorisentoINSS     char(018)
     , valortributavelINSS char(018)
     , valorisentoCCP      char(018)
     , valortributavelCCP  char(018)
     , valortributavelCSLL char(003)
     , valortributavelCOF  char(003)
     , valortributavelPIS  char(003) 
     , nscdat              like dpaksocorfav.nscdat
     , sexcod              char(002)
         
end record

define lr_retorno record                               
       itaciacod     like datmitaaplitm.itaciacod    , 
       itaramcod     like datmitaaplitm.itaramcod    , 
       itaaplnum     like datmitaaplitm.itaaplnum    , 
       aplseqnum     like datmitaaplitm.aplseqnum    , 
       itaaplitmnum  like datmitaaplitm.itaaplitmnum , 
       erro          integer                         , 
       mensagem      char(50)                        
end record                                             

define l_srvop       integer,                   
       l_vlrop       like dbsmopg.socfattotvlr, 
       l_assistencia char(60),
       l_codigo      integer,
       l_atividade   char(60),
       l_infissalqvlr char(014)
     
     
  define l_favtip          smallint,
         l_socpgtopccod    like dbsmopgfav.socpgtopccod,
         l_seq             integer,
         l_dataEmissao     char(008),                          
         l_dataVencimento  char(008),
         l_dataPagamento   char(008),                       
         l_txtitmtot       char(018),
         dataNasc          char(8),
         l_dataLigacao     char(014),                          
         l_dataPrestacao   char(014),
         l_dataAcionamento char(014)
         
   initialize d_bdbsr115.* to null   
   initialize d_opg_dados.* to null
   initialize lr_retorno.* to null
   initialize l_ffpgc346.* to null  
   initialize l_socpgtopccod to null
   
   let l_favtip = 0  
   let l_seq = 1 
   let l_srvop = 0
   let l_vlrop = 0
   let l_assistencia = 30 space
   let l_codigo = 00000
   let l_atividade = 60 space 
   let m_valorOP    = 0
   let m_valorTotOP = 00000000000000000
   let m_socopgnum = null
  
  #------------------------------------------------------------ 
  # Verifica qual foi a ultima sequencia do arquivo enviado para a Itau
  #------------------------------------------------------------ 
  
  display "m_seqArq: ",m_seqArq
  if m_seqArq is null or m_seqArq = " " then
     display "m_seqArq: ",m_seqArq
     whenever error continue
        open cbdbsr115015  
        fetch cbdbsr115015 into m_seqArq 
        if sqlca.sqlcode <> 0 then   
           display "sqlca.sqlcode para sequencia: ",sqlca.sqlcode
           let m_seqArq = 0        
        end if  
        close cbdbsr115015  
     whenever error stop
  end if 
  let m_seqArq = m_seqArq + 1  
  display "m_seqArq2: ",m_seqArq
  #------------------------------------------------------------
  # Cursor principal para buscar todas as OPS da ISAR          
  #------------------------------------------------------------
  
  start report bdbsr115_TXT_itau to l_pathtxt # Abre o relatorio do TXT
  start report bdbsr115_DOC_itau to m_pathres   # Abre o relatorio do DOC
  start report bdbsr115_EXE_itau to m_pathresex   # Abre o relatorio do EXE   
   
  open c_bdbsr115_princ using m_data
  
  foreach c_bdbsr115_princ into  d_bdbsr115.socopgnum   ,
                                 d_bdbsr115.socfatpgtdat,
                                 d_bdbsr115.socfattotvlr,
                                 d_bdbsr115.pstcoddig   ,
                                 d_bdbsr115.empcod      ,
                                 d_bdbsr115.socemsnfsdat,
                                 d_bdbsr115.soctip,
                                 d_bdbsr115.lcvcod,
                                 d_bdbsr115.aviestcod,
                                 d_bdbsr115.segnumdig,
                                 d_bdbsr115.succod,
                                 l_favtip,
                                 d_bdbsr115.infissalqvlr
                                 
     let m_socopgnum = d_bdbsr115.socopgnum
     
     display '----------------------------------------------------------------'
     display "OP: ", d_bdbsr115.socopgnum
     display "lcvcod: ",d_bdbsr115.lcvcod
    
     #---------------------------------------------------------------
     # Obtem dados do favorecido da ordem de pagamento
     #---------------------------------------------------------------     
     whenever error continue
     open  c_opgfav using d_bdbsr115.socopgnum
     fetch c_opgfav into  d_bdbsr115.socopgfavnom,
                          d_bdbsr115.cgccpfnum,
                          d_bdbsr115.cgcord,
                          d_bdbsr115.cgccpfdig,
                          d_bdbsr115.pestip,
                          d_bdbsr115.bcocod,
                          d_bdbsr115.bcoagnnum,
                          d_bdbsr115.bcoagndig,
                          d_bdbsr115.bcoctanum,
                          d_bdbsr115.bcoctadig,
                          d_bdbsr115.socpgtopccod
     whenever error stop

     if d_bdbsr115.cgcord is null  then
        let d_bdbsr115.cgcord = 0
     end if

     close c_opgfav

     #---------------------------------------------------------------
     # CPF/CGC do favorecido
     #---------------------------------------------------------------
     case d_bdbsr115.pestip
        when "F"
             let d_opg_dados.cpfcgctxt = d_bdbsr115.cgccpfnum using '&&&&&&&&&',
                                         d_bdbsr115.cgccpfdig using '&&','   '
        when "J"
             let d_opg_dados.cpfcgctxt = d_bdbsr115.cgccpfnum using '&&&&&&&&',
                                         d_bdbsr115.cgcord    using '&&&&'    ,
                                         d_bdbsr115.cgccpfdig using '&&'
        when "G"
             let d_opg_dados.cpfcgctxt = "              "
     end case



     #---------------------------------------------------------------
     # dados dos servicos/itens da OP                    
     #---------------------------------------------------------------
     open cbdbsr1150011 using d_bdbsr115.socopgnum          
     foreach cbdbsr1150011 into d_bdbsr115.succod,        
                                d_bdbsr115.ramcod,        
                                d_bdbsr115.aplnumdig,     
                                d_bdbsr115.itmnumdig,     
                                d_bdbsr115.atdsrvnum,     
                                d_bdbsr115.atdsrvano,     
                                d_bdbsr115.socopgitmnum,  
                                d_bdbsr115.socopgitmvlr,  
                                d_bdbsr115.vcllicnum,     
                                d_bdbsr115.asitipcod,     
                                d_bdbsr115.nfsnum,        
                                d_bdbsr115.atdsrvorg,
                                d_bdbsr115.atddat,   
                                d_bdbsr115.atddatprg,
                                d_bdbsr115.atdhor,   
                                d_bdbsr115.atdhorprg,
                                d_bdbsr115.cnldat,
                                d_bdbsr115.atdfnlhor
                                
        if d_bdbsr115.succod is null then     
           let d_bdbsr115.succod = 0          
        end if                               
                                             
        if d_bdbsr115.ramcod is null then     
           
           open cbdbsr115022 using d_bdbsr115.atdsrvnum,       
                                   d_bdbsr115.atdsrvano
           fetch cbdbsr115022 into d_bdbsr115.c24astagp
           close cbdbsr115022
           
           if d_bdbsr115.c24astagp = 'IRE' then
              let d_bdbsr115.ramcod = 14
           else
              let d_bdbsr115.ramcod = 31
           end if 
        end if                               
                                             
        if d_bdbsr115.aplnumdig is null then  
           let d_bdbsr115.aplnumdig = 0       
        end if  
        
        let l_socpgtopccod = d_bdbsr115.socpgtopccod
        
        #---------------------------------------------------------------
        # REEMBOLSO BUSCA ENDERECO DO SEGURADO ITAU                               
        # reembolso PF nao precisa de PIS, conforme regra utilizada no People     
        # somente um reembolso por OP, por isso pega dados do cliente com         
        # apólice do item de OP. pendente a alterar, reembolso nao deve ser feito com prestador fixo
        #---------------------------------------------------------------
        if (d_bdbsr115.pstcoddig = 3 or d_bdbsr115.lcvcod = 33 or l_favtip = 3) then  
            let l_socpgtopccod = 0 # colocado para identificar no codigo abaixo que eh reembolso
        else
           if d_bdbsr115.soctip = 2 then
             let l_socpgtopccod = 2
           end if 
        end if  

        call bdbsr115_endereco_fornecedor(l_socpgtopccod,              
                                          d_bdbsr115.vcllicnum,         
                                          d_bdbsr115.lcvcod,            
                                          d_bdbsr115.aviestcod,     
                                          d_bdbsr115.pestip,             
                                          d_bdbsr115.pstcoddig,          
                                          d_opg_dados.pcpatvcod,
                                          d_bdbsr115.empcod)  #Raul BIZ
             
             returning d_opg_dados.endlgd    ,     
                       d_opg_dados.lgdnum    ,   
                       d_opg_dados.endbrr    , 
                       d_opg_dados.endcmp    ,
                       d_opg_dados.mpacidcod ,   
                       d_opg_dados.endcep    ,   
                       d_opg_dados.endcepcmp ,   
                       d_opg_dados.maides    ,   
                       d_opg_dados.muninsnum ,   
                       d_opg_dados.endcid    ,   
                       d_opg_dados.ufdsgl    ,   
                       d_opg_dados.pcpatvcod ,   
                       d_opg_dados.pisnum    ,   
                       d_opg_dados.pstsuccod ,   
                       d_opg_dados.cbo       ,
                       l_favtip              ,
                       d_opg_dados.cidcod    ,
                       d_opg_dados.cep       ,
                       d_opg_dados.simoptpstflg
                         
        #--------------------------------------------------------------- 
        # FLAG OPTANTE SIMPLES NAO PODE ESTAR EM BRANCO 
        #--------------------------------------------------------------- 
        display "d_opg_dados.simoptpstflg: ",d_opg_dados.simoptpstflg
        if d_opg_dados.simoptpstflg is null or 
           d_opg_dados.simoptpstflg = ' ' then
            let d_opg_dados.simoptpstflg = 'N'
        end if 
              
        
        #---------------------------------------------------------------
        # buscar descricao da atividade principal
        #---------------------------------------------------------------
        initialize l_cts54g00.* to null

        call cts54g00_inftrb(84,  # codigo da empresa
                             d_bdbsr115.pstcoddig,
                             d_bdbsr115.soctip,
                             d_bdbsr115.segnumdig,
                             d_opg_dados.corsus,
                             d_bdbsr115.pestip,
                             d_opg_dados.prscootipcod,
                             d_opg_dados.pcpatvcod)
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
         
         
                
        #---------------------------------------------------------------
        # Verifica os impostos que devem ser cobrados
        #---------------------------------------------------------------
        call bdbsr115_verifica_imposto(l_cts54g00.retendes, 
                                       d_opg_dados.cidcod,   
                                       d_opg_dados.mpacidcod,
                                       d_bdbsr115.pestip,   
                                       l_cts54g00.retencod)
             returning l_ffpgc346.flagIR,          
                       l_ffpgc346.flagISS,         
                       l_ffpgc346.flagINSS,        
                       l_ffpgc346.flagPIS,         
                       l_ffpgc346.flagCOF,         
                       l_ffpgc346.flagCSLL,        
                       l_ffpgc346.arrecadacaoIR,   
                       l_ffpgc346.arrecadacaoISS,  
                       l_ffpgc346.arrecadacaoINSS, 
                       l_ffpgc346.arrecadacaoPIS,  
                       l_ffpgc346.arrecadacaoCOFIN,
                       l_ffpgc346.arrecadacaoCSLL 
          
        
        
        #---------------------------------------------------------------
        # custo do item
        #---------------------------------------------------------------
        whenever error continue
        open cbdbsr1150012 using d_bdbsr115.socopgnum,
                                 d_bdbsr115.socopgitmnum
        fetch cbdbsr1150012 into d_bdbsr115.socopgitmcst
        whenever error stop

        if d_bdbsr115.socopgitmcst is null then
           let d_bdbsr115.socopgitmcst = 0
        end if

        if  d_bdbsr115.socpgtopccod = 2 then
            let d_bdbsr115.socpgtopccod = 5
            let d_bdbsr115.bcocod     = "00000"       # CÓDIGO DO BANCO
            let d_bdbsr115.bcoagnnum  = "0000000000"  # NO DA AGÊNCIA
            let d_bdbsr115.bcoagndig  = " "           # DV DA AGÊNCIA
            let d_bdbsr115.bcoctanum  = "0000000000"  # NO DA CONTA CORRENTE
            let d_bdbsr115.bcoctadig  = "  "          # DV DA CONTA CORRENTE
        else
            let d_bdbsr115.socpgtopccod = 1
        end if

           let d_bdbsr115.socopgitmtot = d_bdbsr115.socopgitmvlr + d_bdbsr115.socopgitmcst

           let d_bdbsr115.atdetpdat = ''
           let d_bdbsr115.asitipdes = ''
           
           #---------------------------------------------------------------   
           # Verifica a assintencia/natureza do servico                
           #---------------------------------------------------------------               
           call bdbsr115_assitencia(d_bdbsr115.asitipcod,
                                    d_bdbsr115.atdsrvorg,
                                    d_bdbsr115.atdsrvnum,
                                    d_bdbsr115.atdsrvano)
             returning l_assistencia,
                       l_codigo
                 
           if l_assistencia is null or l_assistencia = ' ' then
              let m_texto = 'Nao foi encontrado assistencia para o servico: ',
                             d_bdbsr115.atdsrvnum,'-',d_bdbsr115.atdsrvano
              output to report bdbsr115_resumo(m_texto clipped) 
           end if 
           
           #--------------------------------------------------------------- 
           # Verifica a principal atividade do prestador
           #---------------------------------------------------------------   
           whenever error continue
              open cbdbsr115019 using d_opg_dados.pcpatvcod
              fetch cbdbsr115019 into l_atividade
           whenever error stop 
           
           #--------------------------------------------------------------- 
           # Verifica o cidade do servico
           #--------------------------------------------------------------- 
           whenever error continue
              open cbdbsr115020 using d_bdbsr115.atdsrvnum,d_bdbsr115.atdsrvano
              fetch cbdbsr115020 into d_bdbsr115.cidnom,
                                      d_bdbsr115.ufdcod,
                                      d_bdbsr115.brrnom
              
           whenever error stop 
           
           call bdbsr115_data_servico(d_bdbsr115.atdsrvnum   ,
                                      d_bdbsr115.atdsrvano   ,
                                      d_bdbsr115.atddat      ,
                                      d_bdbsr115.atdhor      ,
                                      d_bdbsr115.atddatprg   ,
                                      d_bdbsr115.atdhorprg   ,
                                      d_bdbsr115.socemsnfsdat,
                                      d_bdbsr115.socfatpgtdat,
                                      d_bdbsr115.cnldat      ,
                                      d_bdbsr115.atdfnlhor )
                   returning l_dataLigacao    ,
                             l_dataAcionamento,
                             l_dataPrestacao  ,
                             l_dataEmissao    ,
                             l_dataVencimento ,
                             l_dataPagamento
            
           let l_txtitmtot = bdbsr115_valor(d_bdbsr115.socopgitmtot,001) 
            
            display "d_bdbsr115.atdsrvnum: ",d_bdbsr115.atdsrvnum
            display "l_txtitmtot: ",l_txtitmtot
           
           call bdbsr115_formata_dados(l_ffpgc346.flagIR,        
                                       l_ffpgc346.flagISS,       
                                       l_ffpgc346.flagINSS,
                                       l_ffpgc346.flagPIS,       
                                       l_ffpgc346.flagCOF,       
                                       l_ffpgc346.flagCSLL,      
                                       l_ffpgc346.arrecadacaoIR, 
                                       d_bdbsr115.pestip,        
                                       d_bdbsr115.soctip,        
                                       d_opg_dados.pisnum,        
                                       d_opg_dados.muninsnum,
                                       d_bdbsr115.succod,
                                       d_bdbsr115.pstcoddig, 
                                       d_bdbsr115.lcvcod,    
                                       l_favtip,
                                       l_txtitmtot,
                                       d_bdbsr115.segnumdig)
                returning lr_relatorio.flagIR,            
                          lr_relatorio.flagISS,           
                          lr_relatorio.flagINSS,          
                          lr_relatorio.arrecadacaoIR,     
                          lr_relatorio.codtributacaoINSS, 
                          lr_relatorio.pisnum,            
                          lr_relatorio.muninsnum,
                          lr_relatorio.succod,
                          lr_relatorio.codeventoreembolso,
                          lr_relatorio.valorisentoIR,       
                          lr_relatorio.valortributavelIR,   
                          lr_relatorio.valorisentoISS,      
                          lr_relatorio.valortributavelISS,  
                          lr_relatorio.valorisentoINSS,     
                          lr_relatorio.valortributavelINSS,
                          lr_relatorio.valorisentoCCP,     
                          lr_relatorio.valortributavelCCP, 
                          lr_relatorio.valortributavelCSLL,
                          lr_relatorio.valortributavelCOF, 
                          lr_relatorio.valortributavelPIS,
                          lr_relatorio.nscdat,              
                          lr_relatorio.sexcod                          
           let l_seq = l_seq + 1           
            
           let dataNasc = bdbsr115_data(lr_relatorio.nscdat)
            
           if  dataNasc is null or dataNasc = " " then
              let dataNasc = "00000000"
           end if 
             
                                       
           #------------------------------------------------------------ 
           # Monta a linha do relatorio  do TXT    
           #------------------------------------------------------------   
          
           let d_bdbsr115.socopgfavnom  = ctx14g00_TiraAcentos(d_bdbsr115.socopgfavnom)
           let d_opg_dados.endlgd       = ctx14g00_TiraAcentos(d_opg_dados.endlgd)
           let d_opg_dados.endbrr       = ctx14g00_TiraAcentos(d_opg_dados.endbrr)
           let d_opg_dados.endcid       = ctx14g00_TiraAcentos(d_opg_dados.endcid)
           let l_atividade              = ctx14g00_TiraAcentos(l_atividade)
           let l_assistencia            = ctx14g00_TiraAcentos(l_assistencia)
           
           if d_opg_dados.pcpatvcod is null or
              d_opg_dados.pcpatvcod = 0     or
              d_opg_dados.pcpatvcod = ' ' then
              
              let d_opg_dados.pcpatvcod = 00000
              let d_opg_dados.simoptpstflg = 'N' 
              let d_bdbsr115.infissalqvlr = 0000.00
           else
              if d_opg_dados.simoptpstflg is null or 
                 d_opg_dados.simoptpstflg = ' ' then
                  let d_opg_dados.simoptpstflg = 'N'
                  let d_bdbsr115.infissalqvlr = 0000.00
              end if
              
              if d_bdbsr115.infissalqvlr <> 0.00 and
                 d_bdbsr115.infissalqvlr is not null and
                 d_bdbsr115.infissalqvlr <> ' ' then
                 display "d_bdbsr115.infissalqvlr4: ",d_bdbsr115.infissalqvlr
                 let d_opg_dados.simoptpstflg = 'S' 
              else
                 let d_opg_dados.simoptpstflg = 'N' 
              end if 
           end if 
           
           
           display "d_bdbsr115.infissalqvlr: ",d_bdbsr115.infissalqvlr
           if  d_bdbsr115.infissalqvlr is null or d_bdbsr115.infissalqvlr = ' ' then
              let d_bdbsr115.infissalqvlr = 0000.00
           end if 
           let l_infissalqvlr = bdbsr115_valor(d_bdbsr115.infissalqvlr,998)
           
            
           output to report bdbsr115_TXT_itau(l_seq                           ,
                                                d_bdbsr115.pestip               ,
                                                d_bdbsr115.socopgfavnom         ,
                                                d_opg_dados.cpfcgctxt           ,
                                                d_opg_dados.endlgd              ,
                                                d_opg_dados.lgdnum              ,
                                                d_opg_dados.endcmp              ,
                                                d_opg_dados.endbrr              ,
                                                d_opg_dados.ufdsgl              ,
                                                d_opg_dados.endcid              ,
                                                d_opg_dados.cep                 ,
                                                d_opg_dados.maides              ,
                                                d_bdbsr115.bcocod               ,
                                                d_bdbsr115.bcoagnnum            ,
                                                d_bdbsr115.bcoagndig            ,
                                                d_bdbsr115.bcoctanum            ,
                                                d_bdbsr115.bcoctadig            ,
                                                lr_relatorio.flagIR             ,
                                                lr_relatorio.flagISS            ,
                                                lr_relatorio.flagINSS           ,
                                                lr_relatorio.arrecadacaoIR      ,
                                                lr_relatorio.codtributacaoINSS  ,
                                                lr_relatorio.sexcod             ,
                                                lr_relatorio.pisnum             ,
                                                lr_relatorio.muninsnum          ,
                                                d_opg_dados.cbo                 ,
                                                dataNasc                        ,
                                                d_bdbsr115.socopgnum            ,
                                                d_bdbsr115.atdsrvnum            ,
                                                d_bdbsr115.atdsrvano            ,
                                                lr_relatorio.codeventoreembolso ,
                                                d_bdbsr115.socpgtopccod         ,
                                                d_bdbsr115.nfsnum               ,
                                                d_bdbsr115.socemsnfsdat         ,
                                                d_bdbsr115.socfatpgtdat         ,
                                                d_bdbsr115.socopgitmtot         ,
                                                l_txtitmtot                     ,
                                                l_dataEmissao                   ,
                                                l_dataVencimento                ,
                                                lr_relatorio.valorisentoIR      ,
                                                lr_relatorio.valortributavelIR  ,
                                                lr_relatorio.valorisentoISS     ,
                                                lr_relatorio.valortributavelISS ,
                                                lr_relatorio.valorisentoINSS    ,
                                                lr_relatorio.valortributavelINSS,
                                                l_atividade                     ,
                                                lr_relatorio.succod             ,
                                                d_bdbsr115.ramcod               ,
                                                d_bdbsr115.aplnumdig            ,
                                                d_bdbsr115.itmnumdig            ,
                                                l_dataAcionamento               ,
                                                l_assistencia                   ,
                                                l_codigo                        ,
                                                lr_relatorio.valorisentoCCP     ,
                                                lr_relatorio.valortributavelCCP ,
                                                lr_relatorio.valortributavelCSLL,
                                                lr_relatorio.valortributavelCOF ,
                                                lr_relatorio.valortributavelPIS ,
                                                l_dataPagamento                 ,
                                                l_dataLigacao                   ,
                                                l_dataPrestacao                 ,
                                                d_bdbsr115.cidnom               ,
                                                d_bdbsr115.ufdcod               ,
                                                d_bdbsr115.brrnom               ,
                                                d_opg_dados.pcpatvcod           ,
                                                d_opg_dados.simoptpstflg        ,
                                                l_infissalqvlr)
              
               #------------------------------------------------------------ 
               # Monta a linha do relatorio  do EXE                           
               #------------------------------------------------------------ 
               output to report bdbsr115_EXE_itau(l_seq                      ,
                                                d_bdbsr115.pestip               ,
                                                d_bdbsr115.socopgfavnom         ,
                                                d_opg_dados.cpfcgctxt           ,
                                                d_opg_dados.endlgd              ,
                                                d_opg_dados.lgdnum              ,
                                                d_opg_dados.endcmp              ,
                                                d_opg_dados.endbrr              ,
                                                d_opg_dados.ufdsgl              ,
                                                d_opg_dados.endcid              ,
                                                d_opg_dados.cep                 ,
                                                d_opg_dados.maides              ,
                                                d_bdbsr115.bcocod               ,
                                                d_bdbsr115.bcoagnnum            ,
                                                d_bdbsr115.bcoagndig            ,
                                                d_bdbsr115.bcoctanum            ,
                                                d_bdbsr115.bcoctadig            ,
                                                lr_relatorio.flagIR             ,
                                                lr_relatorio.flagISS            ,
                                                lr_relatorio.flagINSS           ,
                                                lr_relatorio.arrecadacaoIR      ,
                                                lr_relatorio.codtributacaoINSS  ,
                                                lr_relatorio.sexcod             ,
                                                lr_relatorio.pisnum             ,
                                                lr_relatorio.muninsnum          ,
                                                d_opg_dados.cbo                 ,
                                                dataNasc                        ,
                                                d_bdbsr115.socopgnum            ,
                                                d_bdbsr115.atdsrvnum            ,
                                                d_bdbsr115.atdsrvano            ,
                                                lr_relatorio.codeventoreembolso ,
                                                d_bdbsr115.socpgtopccod         ,
                                                d_bdbsr115.nfsnum               ,
                                                d_bdbsr115.socemsnfsdat         ,
                                                d_bdbsr115.socfatpgtdat         ,
                                                d_bdbsr115.socopgitmtot         ,
                                                l_txtitmtot                     ,
                                                l_dataEmissao                   ,
                                                l_dataVencimento                ,
                                                lr_relatorio.valorisentoIR      ,
                                                lr_relatorio.valortributavelIR  ,
                                                lr_relatorio.valorisentoISS     ,
                                                lr_relatorio.valortributavelISS ,
                                                lr_relatorio.valorisentoINSS    ,
                                                lr_relatorio.valortributavelINSS,
                                                l_atividade                     ,
                                                lr_relatorio.succod             ,
                                                d_bdbsr115.ramcod               ,
                                                d_bdbsr115.aplnumdig            ,
                                                d_bdbsr115.itmnumdig            ,
                                                l_dataAcionamento               ,
                                                l_assistencia                   ,
                                                l_codigo                        ,
                                                lr_relatorio.valorisentoCCP     ,
                                                lr_relatorio.valortributavelCCP ,
                                                lr_relatorio.valortributavelCSLL,
                                                lr_relatorio.valortributavelCOF ,
                                                lr_relatorio.valortributavelPIS ,
                                                l_dataPagamento                 ,
                                                l_dataLigacao                   ,
                                                l_dataPrestacao                 ,
                                                d_bdbsr115.cidnom               ,
                                                d_bdbsr115.ufdcod               ,
                                                d_bdbsr115.brrnom               ,
                                                d_opg_dados.pcpatvcod           ,
                                                d_opg_dados.simoptpstflg        ,
                                                l_infissalqvlr)
               
                 let l_srvop = l_srvop + 1                     
                 let m_valorOP = m_valorOP + d_bdbsr115.socopgitmtot 
                 display "m_valorOP: ",m_valorOP
                 let m_valorTotOP = bdbsr115_valor(m_valorOP,999)
                  display "m_valorTotOP: ",m_valorTotOP
                 let l_vlrop =  l_vlrop + d_bdbsr115.socopgitmtot                             
                      initialize lr_relatorio.succod,       
                                 d_bdbsr115.ramcod,       
                                 d_bdbsr115.aplnumdig,    
                                 d_bdbsr115.atdsrvnum,    
                                 d_bdbsr115.atdsrvano,    
                                 d_bdbsr115.socopgitmnum, 
                                 d_bdbsr115.socopgitmvlr, 
                                 d_bdbsr115.asitipcod,    
                                 d_bdbsr115.nfsnum ,      
                                 d_bdbsr115.atdsrvorg,    
                                 d_bdbsr115.atdetpdat,    
                                 d_bdbsr115.asitipdes,    
                                 d_bdbsr115.socopgitmcst, 
                                 d_bdbsr115.socopgitmtot,
                                 d_bdbsr115.itmnumdig to null    
     end foreach 
     #------------------------------------------------------------ 
     # Monta a linha do relatorio  do DOC                         
     #------------------------------------------------------------                                 
     output to report bdbsr115_DOC_itau(d_bdbsr115.socopgnum,
                                        d_bdbsr115.socopgfavnom,
                                        l_srvop, 
                                        l_vlrop)
       let l_srvop  = 0
       let l_vlrop  = 0
       
         
  end foreach
   
   if l_seq = 1 then
      start report bdbsr115_TXT_branco to l_pathtxt       # Abre o relatorio do TXT
      start report bdbsr115_DOC_branco to m_pathres   # Abre o relatorio do DOC
      
           output to report bdbsr115_TXT_branco(l_seq)
           output to report bdbsr115_DOC_branco()
           
      finish report bdbsr115_DOC_branco    # Fecha o relatorio do DOC   
      finish report bdbsr115_TXT_branco        # Fecha o relatorio do TXT
   end if 
  
  
  
 finish report bdbsr115_DOC_itau    # Fecha o relatorio do DOC   
 finish report bdbsr115_TXT_itau  # Fecha o relatorio do TXT
 finish report bdbsr115_EXE_itau # Fecha o relatorio do EXE
 
    #-----------------------------------------------------
    # Update para atualizar a ultima versão enviada
    #-----------------------------------------------------
    whenever error continue 
       execute pbdbsr115016 using m_seqArq
    whenever error stop
          
end function
          
#============================================================================= 
function bdbsr115_endereco_fornecedor(param)
#============================================================================= 
   
define param record
   socpgtopccod  like dbsmopgfav.socpgtopccod,
   vcllicnum     like datmservico.vcllicnum,   
   lcvcod        like dbsmopg.lcvcod,
   aviestcod     like dbsmopg.aviestcod,
   pestip        like dbsmopgfav.pestip,
   pstcoddig     like dbsmopg.pstcoddig,
   pcpatvcod     like dpaksocor.pcpatvcod,
   empcod        like gabkemp.empcod       #Raul BIZ
end record 

define l_cty10g00_out record     
    res     smallint,            
    msg     char(100),           
    endufd  like gabksuc.endufd, 
    endcid  like gabksuc.endcid, 
    cidcod  like gabksuc.cidcod  
end record

define lr_retorno record
       itaciacod     like datmitaaplitm.itaciacod    ,
       itaramcod     like datmitaaplitm.itaramcod    ,
       itaaplnum     like datmitaaplitm.itaaplnum    ,
       aplseqnum     like datmitaaplitm.aplseqnum    ,
       itaaplitmnum  like datmitaaplitm.itaaplitmnum ,
       erro          integer                         ,
       mensagem      char(50)                        ,
       endlgd        like dpakpstend.endlgd           ,
       lgdnum        like dpakpstend.lgdnum           ,
       endbrr        like dpakpstend.endbrr           ,
       endcmp        like dpaksocor.endcmp           ,
       mpacidcod     like dpaksocor.mpacidcod        ,
       endcep        like dpakpstend.endcep           ,
       endcepcmp     like dpakpstend.endcepcmp    ,
       maides        like dpaksocor.maides           ,
       muninsnum     like dpaksocor.muninsnum        ,
       endcid        like dpakpstend.endcid             ,
       ufdsgl        like dpakpstend.ufdsgl             ,
       pstsuccod     like dpaksocor.succod           ,
       pcpatvcod     like dpaksocor.pcpatvcod        ,
       pisnum        like dpaksocor.pisnum           ,
       cbo           char(5)                         ,
       l_favtip      smallint                        ,
       cep           char(10)                        ,
       succod        like datmitaapl.succod          ,
       simoptpstflg  like dpaksocor.simoptpstflg     ,
       endtipcod     like dpakpstend.endtipcod        #Raul BIZ
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
   
  define lr_aviso   record  
         assunto    char(150)   
        ,texto      char(32000) 
  end record 
  
  define l_mail     integer     
  
  initialize lr_retorno.*,lr_saida_801.*, lr_aviso.*, l_mail  to null   
   
   display "param.socpgtopccod: ",param.socpgtopccod
   case param.socpgtopccod
    
      when 0
         let lr_retorno.l_favtip = 3  # Segurado
         display "param.vcllicnum: ",param.vcllicnum
         if param.vcllicnum <> " " and param.vcllicnum is not null then
            call cty22g00_rec_apolice_por_placa(param.vcllicnum)
                 returning lr_retorno.itaciacod    ,         
                           lr_retorno.itaramcod    ,         
                           lr_retorno.itaaplnum    ,         
                           lr_retorno.aplseqnum    ,         
                           lr_retorno.itaaplitmnum , 
                           lr_retorno.succod       ,     
                           lr_retorno.erro         ,         
                           lr_retorno.mensagem               
            display "lr_retorno.erro_placa: ",lr_retorno.erro
            if lr_retorno.erro = 0 then
               call cty22g00_rec_dados_itau(lr_retorno.itaciacod, 
                                            lr_retorno.itaramcod, 
                                            lr_retorno.itaaplnum, 
                                            lr_retorno.aplseqnum, 
                                            lr_retorno.itaaplitmnum)    
               returning lr_retorno.erro,
                         lr_retorno.mensagem 
                
               let lr_retorno.endlgd    =  g_doc_itau[1].seglgdnom  
               let lr_retorno.lgdnum    =  g_doc_itau[1].seglgdnum 
               let lr_retorno.endbrr    =  g_doc_itau[1].segbrrnom  
               let lr_retorno.ufdsgl    =  g_doc_itau[1].segufdsgl  
               let lr_retorno.endcid    =  g_doc_itau[1].segcidnom 
               let lr_retorno.endcep    =  g_doc_itau[1].segcepnum 
               let lr_retorno.endcepcmp =  g_doc_itau[1].segcepcmpnum  
               let lr_retorno.maides    =  g_doc_itau[1].segmaiend
               
                      
               if lr_retorno.erro <> 0 then
                 display "Erro ao busca apolice : ",lr_retorno.erro, " - ",lr_retorno.mensagem clipped                                         
               end if                                                       
            else
               display "Erro ao busca apolice por placa: ",lr_retorno.erro, " - ",lr_retorno.mensagem clipped   
            end if         
         end if  
         
         if lr_retorno.lgdnum is null then
            let lr_retorno.lgdnum = 0
         end if
              
         if lr_retorno.endcep is not null then
            let lr_retorno.cep = "00", lr_retorno.endcep using "&&&&&" , lr_retorno.endcepcmp using "&&&"
         else
            let lr_retorno.cep = "0000000000"
         end if      
         
         call cty10g00_obter_cidcod(lr_retorno.endcid, lr_retorno.ufdsgl)
              returning l_cty10g00_out.res, l_cty10g00_out.msg, lr_retorno.mpacidcod
          
          display "lr_retorno.mpacidcod: ",lr_retorno.mpacidcod
                         
      when 2
         let lr_retorno.l_favtip = 4  # Locadora
              
         whenever error continue
         open cbdbsr1150014 using param.lcvcod,
                                  param.aviestcod
         fetch cbdbsr1150014 into lr_retorno.endlgd   ,
                                  lr_retorno.endbrr   ,
                                  lr_retorno.ufdsgl   ,
                                  lr_retorno.endcid   ,
                                  lr_retorno.endcep   ,
                                  lr_retorno.endcepcmp,
                                  lr_retorno.maides   ,
                                  lr_retorno.pstsuccod,
                                  lr_retorno.muninsnum
         whenever error stop
         
         if lr_retorno.endcep is not null then
            let lr_retorno.cep = "00", lr_retorno.endcep using "&&&&&" , lr_retorno.endcepcmp using "&&&"
         else
            let lr_retorno.cep = "0000000000"
         end if 
         
         call cty10g00_obter_cidcod(lr_retorno.endcid, lr_retorno.ufdsgl)
              returning l_cty10g00_out.res, l_cty10g00_out.msg, lr_retorno.mpacidcod
              
      otherwise
         # DADOS PRESTADOR
    
         let lr_retorno.l_favtip = 1  # Prestador
         
         whenever error continue
         open cbdbsr115006 using param.pstcoddig
         fetch cbdbsr115006 into #lr_retorno.endlgd,
                                 #lr_retorno.lgdnum,
                                 #lr_retorno.endbrr, 
                                 lr_retorno.endcmp,
                                 lr_retorno.mpacidcod,
                                 #lr_retorno.endcep,
                                 #lr_retorno.endcepcmp,
                                 lr_retorno.maides,
                                 lr_retorno.muninsnum,
                                 lr_retorno.pcpatvcod,
                                 lr_retorno.pisnum,
                                 lr_retorno.pstsuccod,
                                 lr_retorno.simoptpstflg
         whenever error stop
         
         display "PRESTADOR TRIBUTOS: ", param.pstcoddig
         
         #Raul BIZ
         open cbdbsr116022 using param.pstcoddig
         whenever error continue
         fetch cbdbsr116022 into  lr_retorno.ufdsgl   
                                 ,lr_retorno.endcid   
                                 ,lr_retorno.endlgd   
                                 ,lr_retorno.endcep   
                                 ,lr_retorno.endcmp   
                                 ,lr_retorno.endbrr
                                 ,lr_retorno.lgdnum   
                                 ,lr_retorno.endcepcmp
                                 ,lr_retorno.endtipcod
         
         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode <> 100 then
               display "Erro SELECT (cbdbsr116022). SQLCODE: "
                                                ,sqlca.sqlcode
               display "lr_retorno.ufdsgl: ",lr_retorno.ufdsgl
                      ,"/","lr_retorno.endcid: ",lr_retorno.endcid   
                      ,"/","lr_retorno.endlgd: ",lr_retorno.endlgd   
                      ,"/","lr_retorno.endcep: ",lr_retorno.endcep   
                      ,"/","lr_retorno.endcmp: ",lr_retorno.endcmp   
                      ,"/","lr_retorno.endbrr: ",lr_retorno.endbrr
                      ,"/","lr_retorno.lgdnum: ",lr_retorno.lgdnum   
                      ,"/","lr_retorno.endcepcmp: ",lr_retorno.endcepcmp
                      ,"/","lr_retorno.endtipcod: ",lr_retorno.endtipcod
            else

               #PSI-2012-23608, Biz
               let lr_aviso.assunto = "PRESTADOR ",param.pstcoddig clipped, " - OP ", m_socopgnum, 
                                      " - SEM ENDEREÇO FISCAL CADASTRADO"
               let lr_aviso.texto   = " - SEM ENDEREÇO FISCAL CADASTRADO"
                       
               display lr_aviso.assunto 
               let l_mail = ctx22g00_mail_corpo("ANLPGTPS"
                                                ,lr_aviso.assunto
                                                ,lr_aviso.texto) 
               
            end if
         	
         end if
         #Raul BIZ

          if lr_retorno.endcep is not null then
            let lr_retorno.cep = "00", lr_retorno.endcep using "&&&&&", lr_retorno.endcepcmp using "&&&"
          else
             let lr_retorno.cep = "0000000000"
          end if 
                   
         #Raul Biz
         #whenever error continue
         #open cbdbsr115007 using lr_retorno.mpacidcod
         #fetch cbdbsr115007 into lr_retorno.cidnom,
         #                        lr_retorno.ufdcod
         #whenever error stop          
      
   end case
   
   #---------------------------------------------------------------
   # obter cidade ligada a sucursal do fornecedor (tributacao)
   #---------------------------------------------------------------
   
   display "BUSCANDO O ENDERECO DO TRIBUTOS"
   display "lr_retorno.endcid = ", lr_retorno.endcid
   display "lr_retorno.ufdsgl = ", lr_retorno.ufdsgl
   
   
   initialize l_cty10g00_out.* to null
   call cty10g00_obter_cidcod(lr_retorno.endcid, lr_retorno.ufdsgl)
   returning l_cty10g00_out.res,
             l_cty10g00_out.msg,
             lr_retorno.mpacidcod
    
    display "VOLTA CIDADE CODIGO"
    display "l_cty10g00_out.res   = ", l_cty10g00_out.res          
    display "l_cty10g00_out.msg   = ", l_cty10g00_out.msg         
    display "lr_retorno.mpacidcod = ", lr_retorno.mpacidcod        
      
   if l_cty10g00_out.res = 0 then
      call fcgtc801(param.empcod, lr_retorno.mpacidcod)
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
      
      display "RETORNO - TRIBUTOS"
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
         let l_cty10g00_out.cidcod = lr_retorno.mpacidcod
        
         display "lr_saida_801.ppssucnum = ", lr_saida_801.ppssucnum 
         display "m_socopgnum   = ", m_socopgnum   
         
         #Grava a sucursal na op                   
	 whenever error continue
	   update dbsmopg set succod = lr_saida_801.ppssucnum
	   where socopgnum = m_socopgnum
	 whenever error stop 
      else
         display lr_saida_801.msgerr
      end if
      
   else
      display l_cty10g00_out.msg 
   end if
   #Raul BIZ

   #---------------------------------------------------------------
   # buscar sucursal da OP ligada ao prestador
   #---------------------------------------------------------------
   call cty10g00_dados_sucursal(1, lr_retorno.pstsuccod)
        returning l_cty10g00_out.res,    
                  l_cty10g00_out.msg,    
                  l_cty10g00_out.endufd, 
                  l_cty10g00_out.endcid, 
                  l_cty10g00_out.cidcod 

   if l_cty10g00_out.cidcod is null or
      l_cty10g00_out.cidcod <= 0
      then
      call cty10g00_obter_cidcod(l_cty10g00_out.endcid, l_cty10g00_out.endufd)
           returning l_cty10g00_out.res,
                     l_cty10g00_out.msg,
                     l_cty10g00_out.cidcod
   end if
   
   #---------------------------------------------------------------
   # definir o CBO
   #---------------------------------------------------------------
   if param.pestip = "F" and
      param.pstcoddig <> 3 then
      case lr_retorno.pcpatvcod
          when  3    # TAXI
              let lr_retorno.cbo = "7823"
          when  2    # CHAVEIRO
              let lr_retorno.cbo = "5231"
          otherwise
              let lr_retorno.cbo = "7825"
      end case
   else
      let lr_retorno.cbo = "     "
   end if 
   
   #---------------------------------------------------------------
   # Verifica se cidade sede esta nulla e coloca padrao sao paulo
   #---------------------------------------------------------------
   display "lr_retorno.l_favtip: ",lr_retorno.l_favtip
   if lr_retorno.mpacidcod is null
      then
      if lr_retorno.l_favtip = 3 then
         display 'Considerando padrao Sao Paulo'
         let lr_retorno.mpacidcod = 9668
      end if
      display 'Cidade sede do segurado nao identificada:'
      display 'lr_retorno.endlgd   : ', lr_retorno.endlgd
      display 'lr_retorno.lgdnum   : ', lr_retorno.lgdnum
      display 'lr_retorno.endbrr   : ', lr_retorno.endbrr
      display 'lr_retorno.ufdcod   : ', lr_retorno.ufdsgl
      display 'lr_retorno.cidnom   : ', lr_retorno.endcid
      display 'lr_retorno.mpacidcod: ', lr_retorno.mpacidcod
   end if
   
   
   
   return lr_retorno.endlgd      ,      
          lr_retorno.lgdnum      , 
          lr_retorno.endbrr      , 
          lr_retorno.endcmp      ,
          lr_retorno.mpacidcod   , 
          lr_retorno.endcep      , 
          lr_retorno.endcepcmp   , 
          lr_retorno.maides      , 
          lr_retorno.muninsnum   , 
          lr_retorno.endcid      , 
          lr_retorno.ufdsgl      , 
          lr_retorno.pcpatvcod   , 
          lr_retorno.pisnum      , 
          lr_retorno.pstsuccod   , 
          lr_retorno.cbo         ,
          lr_retorno.l_favtip    ,
          l_cty10g00_out.cidcod  ,
          lr_retorno.cep         ,
          lr_retorno.simoptpstflg
   
end function




#============================================================================= 
function bdbsr115_verifica_imposto(param)
#============================================================================= 

define param record
   retendes   char(50), 
   cidcod     like gabksuc.cidcod,   
   mpacidcod  like dpaksocor.mpacidcod,
   pestip     like dbsmopgfav.pestip,  
   retencod   like fpgkplprtcinf.ppsretcod  
end record                                          
                                                    
define l_ffpgc346 record
       empresa             decimal(2,0)
     , cmporgcod           smallint
     , pestip              char(1)
     , ppsretcod           like fpgkplprtcinf.ppsretcod
     , atividade           char(050)
     , errcod              smallint
     , errdes              char(060)
     , flagIR              char(001)
     , flagISS             char(001)
     , flagINSS            char(001)
     , flagPIS             char(001)
     , flagCOF             char(001)
     , flagCSLL            char(001)
     , arrecadacaoIR       char(004)
     , arrecadacaoISS      char(004)
     , arrecadacaoINSS     char(004)
     , arrecadacaoPIS      char(004)
     , arrecadacaoCOFIN    char(004)
     , arrecadacaoCSLL     char(004)
end record

define l_try  smallint

initialize l_ffpgc346.* to null
   
let l_try = 0
   
   if param.retendes is not null and
      param.cidcod is not null and
      param.cidcod > 0 and
      param.mpacidcod is not null and
      param.mpacidcod > 0
      then
      
      display 'ffpgc346 parametros:'
      display 'l_param.pestip.........................: ', param.pestip
      display 'l_cts54g00.retencod....................: ', param.retencod
      display 'l_cts54g00.retendes....................: ', param.retendes clipped
      display 'l_cty10g00_out.cidcod(cidade prestacao): ', param.cidcod
      display 'd_opg_dados.mpacidcod(cidade sede).......: ', param.mpacidcod
      
          display "param.pestip,  : ",param.pestip  
          display "param.retencod,: ",param.retencod
          display "param.retendes,: ",param.retendes
          display "param.cidcod,  : ",param.cidcod  
          display "param.mpacidcod: ",param.mpacidcod
          
         call ffpgc346(84, # codigo da empresa
                       11, # codigo do porto socorro
                       param.pestip,
                       param.retencod,
                       param.retendes,
                       param.cidcod,
                       param.mpacidcod)
             returning l_ffpgc346.empresa         ,
                       l_ffpgc346.cmporgcod       ,
                       l_ffpgc346.pestip          ,
                       l_ffpgc346.ppsretcod       ,
                       l_ffpgc346.atividade       ,
                       l_ffpgc346.errcod          ,
                       l_ffpgc346.errdes          ,
                       l_ffpgc346.flagIR          ,
                       l_ffpgc346.flagISS         ,
                       l_ffpgc346.flagINSS        ,
                       l_ffpgc346.flagPIS         ,
                       l_ffpgc346.flagCOF         ,
                       l_ffpgc346.flagCSLL        ,
                       l_ffpgc346.arrecadacaoIR   ,
                       l_ffpgc346.arrecadacaoISS  ,
                       l_ffpgc346.arrecadacaoINSS ,
                       l_ffpgc346.arrecadacaoPIS  ,
                       l_ffpgc346.arrecadacaoCOFIN,
                       l_ffpgc346.arrecadacaoCSLL
   
         
      display 'FFPGC346 retorno:'
      display 'l_ffpgc346.empresa         : ', l_ffpgc346.empresa
      display 'l_ffpgc346.cmporgcod       : ', l_ffpgc346.cmporgcod
      display 'l_ffpgc346.pestip          : ', l_ffpgc346.pestip
      display 'l_ffpgc346.ppsretcod       : ', l_ffpgc346.ppsretcod
      display 'l_ffpgc346.atividade       : ', l_ffpgc346.atividade
      display 'l_ffpgc346.errcod          : ', l_ffpgc346.errcod
      display 'l_ffpgc346.errdes          : ', l_ffpgc346.errdes
      display 'l_ffpgc346.flagIR          : ', l_ffpgc346.flagIR
      display 'l_ffpgc346.flagISS         : ', l_ffpgc346.flagISS
      display 'l_ffpgc346.flagINSS        : ', l_ffpgc346.flagINSS
      display 'l_ffpgc346.flagPIS         : ', l_ffpgc346.flagPIS
      display 'l_ffpgc346.flagCOF         : ', l_ffpgc346.flagCOF
      display 'l_ffpgc346.flagCSLL        : ', l_ffpgc346.flagCSLL
      display 'l_ffpgc346.arrecadacaoIR   : ', l_ffpgc346.arrecadacaoIR
      display 'l_ffpgc346.arrecadacaoISS  : ', l_ffpgc346.arrecadacaoISS
      display 'l_ffpgc346.arrecadacaoINSS : ', l_ffpgc346.arrecadacaoINSS
      display 'l_ffpgc346.arrecadacaoPIS  : ', l_ffpgc346.arrecadacaoPIS
      display 'l_ffpgc346.arrecadacaoCOFIN: ', l_ffpgc346.arrecadacaoCOFIN
      display 'l_ffpgc346.arrecadacaoCSLL : ', l_ffpgc346.arrecadacaoCSLL
   end if
   
   # regra de consistir flag = N, desconsidera cod arrecadacao. 05/03/10
   if l_ffpgc346.flagIR is null or l_ffpgc346.flagIR = "N"
      then
      let l_ffpgc346.arrecadacaoIR = null
   end if
   
   if l_ffpgc346.flagISS is null or l_ffpgc346.flagISS = "N"
      then
      let l_ffpgc346.arrecadacaoISS = null
   end if
   
   if l_ffpgc346.flagINSS is null or l_ffpgc346.flagINSS = "N"
      then
      let l_ffpgc346.arrecadacaoINSS = null
   end if
   
   if l_ffpgc346.flagPIS is null or l_ffpgc346.flagPIS = "N"
      then
      let l_ffpgc346.arrecadacaoPIS = null
   end if
   
   if l_ffpgc346.flagCOF is null or l_ffpgc346.flagCOF = "N"
      then
      let l_ffpgc346.arrecadacaoCOFIN = null
   end if
   
   if l_ffpgc346.flagCSLL is null or l_ffpgc346.flagCSLL = "N"
      then
      let l_ffpgc346.arrecadacaoCSLL = null
   end if

  
return l_ffpgc346.flagIR          ,
       l_ffpgc346.flagISS         ,
       l_ffpgc346.flagINSS        ,
       l_ffpgc346.flagPIS         ,
       l_ffpgc346.flagCOF         ,
       l_ffpgc346.flagCSLL        ,
       l_ffpgc346.arrecadacaoIR   ,
       l_ffpgc346.arrecadacaoISS  ,
       l_ffpgc346.arrecadacaoINSS ,
       l_ffpgc346.arrecadacaoPIS  ,
       l_ffpgc346.arrecadacaoCOFIN,
       l_ffpgc346.arrecadacaoCSLL 

end function


#============================================================================= 
function bdbsr115_formata_dados(param)
#============================================================================= 
   
define param record
     flagIR              char(001)
   , flagISS             char(001)
   , flagINSS            char(001)
   , flagPIS             char(001)
   , flagCOF             char(001)
   , flagCSLL            char(001)   
   , arrecadacaoIR       char(004)
   , pestip              char(1)
   , soctip              like dbsmopg.soctip
   , pisnum              like dpaksocor.pisnum
   , muninsnum           like dpaksocor.muninsnum
   , succod              like dbsmopg.succod 
   , pstcoddig           like dbsmopg.pstcoddig  
   , lcvcod              like dbsmopg.lcvcod 
   , favtip              smallint 
   , txtitmtot           char(018) 
   , segnumdig           like dbsmopg.segnumdig   
end record

define lr_retorno record
     flagIR              char(003)
   , flagISS             char(001)
   , flagINSS            char(001)
   , arrecadacaoIR       char(005)
   , codtributacaoINSS   char(003)
   , pisnum              like dpaksocor.pisnum
   , muninsnum           like dpaksocor.muninsnum 
   , succod              char(005) 
   , codeventoreembolso  smallint
   , valorisentoIR       char(018)
   , valortributavelIR   char(018)
   , valorisentoISS      char(018)
   , valortributavelISS  char(018)
   , valorisentoINSS     char(018)
   , valortributavelINSS char(018)
   , valorisentoCCP      char(018)
   , valortributavelCCP  char(018)
   , valortributavelCSLL char(003)
   , valortributavelCOF  char(003)
   , valortributavelPIS  char(003) 
   , nscdat              like dpaksocorfav.nscdat
   , sexcod              char(002)
         
end record
   
   initialize lr_retorno.* to null
   
   # FLAG INCIDÊNCIA IR
   if param.flagIR is null then
      let lr_retorno.flagIR =  "   " 
   else
      if param.flagIR = 'S' then
         let lr_retorno.flagIR = "001"
      else
         let lr_retorno.flagIR = "000"
      end if
   end if
   
   # NATUREZA DO RENDIMENTO (codigo arrecadacao IR) 
   if param.arrecadacaoIR is null   
      then
      let lr_retorno.arrecadacaoIR = "00000"
   else
      let lr_retorno.arrecadacaoIR = param.arrecadacaoIR
   end if
   
   # FLAG INCIDÊNCIA ISS
   if param.flagISS is null then
     let lr_retorno.flagISS = " ";
   else
      if param.flagISS = 'S' then
         let lr_retorno.flagISS = "1"
      else
         let lr_retorno.flagISS = "0"
      end if
   end if
   
   # FLAG INCIDÊNCIA INSS
   if param.flagINSS is null then
      let lr_retorno.flagINSS = " "
   else
      if param.flagINSS = 'S' then
         let lr_retorno.flagINSS = "1"   
      else
         let lr_retorno.flagINSS = "0"
      end if
   end if
   
   
   if param.flagINSS is null then
      let lr_retorno.codtributacaoINSS = "   "
   else
      if param.flagINSS = 'S' then
         if param.pestip = 'F' then
            let lr_retorno.codtributacaoINSS = "004"
         else
            let lr_retorno.codtributacaoINSS = "003"
         end if
      else
         let lr_retorno.codtributacaoINSS = "000"
      end if
   end if
       
   # reembolso PF nao precisa de PIS
   if param.pestip = "F" and (param.soctip = 1 or param.soctip = 3) and
      param.pisnum is not null  then
      let lr_retorno.pisnum = param.pisnum
   else
      let lr_retorno.pisnum = 00000000000
   end if
   
   # inscricao somente PJ      
   if param.pestip = "J" and param.muninsnum is not null  then
      let lr_retorno.muninsnum = bdbsr115_pontuacao(param.muninsnum)
   else
      let lr_retorno.muninsnum = 00000000000
   end if
    
    if param.succod = 0 then                                                      
       let lr_retorno.succod = "00099"                               
    else                                                         
       let lr_retorno.succod = param.succod
    end if                                                        
    
    
    # codigo do evento, reembolso(nao prestador) ou prestador
    display "param.favtip: ",param.favtip
    display "param.lcvcod: ",param.lcvcod
    if param.favtip = 3 or param.lcvcod = 33 or 
       param.segnumdig = 84848484 or param.segnumdig = 35353535  then                           
       let lr_retorno.codeventoreembolso = 11363
    else
       if param.favtip = 4 then
          let lr_retorno.codeventoreembolso = 11366
       else
          let lr_retorno.codeventoreembolso = 11364
       end if
    end if
    
    if param.flagIR is null then
       let lr_retorno.valorisentoIR =  "                  "
    else
       if param.flagIR = "S" then
          let lr_retorno.valorisentoIR ="*0000000000000*00*"
       else
         let lr_retorno.valorisentoIR = param.txtitmtot 
       end if
    end if
    
    if param.flagIR is null then
      let lr_retorno.valortributavelIR = "                  "
    else
       if param.flagIR = "S" then
          let lr_retorno.valortributavelIR = param.txtitmtot
       else
          let lr_retorno.valortributavelIR = "*0000000000000*00*"
       end if
    end if

    if param.flagISS is null then
       let lr_retorno.valorisentoISS = "                  "
    else
       if param.flagISS = "S" then
          let lr_retorno.valorisentoISS = "*0000000000000*00*"
       else
          let lr_retorno.valorisentoISS = param.txtitmtot
       end if
    end if
    
    if param.flagISS is null then
       let lr_retorno.valortributavelISS = "                  "
    else
       if param.flagISS = "S" then
          let lr_retorno.valortributavelISS = param.txtitmtot
       else
          let lr_retorno.valortributavelISS = "*0000000000000*00*" 
       end if
    end if

   
   if param.flagINSS is null then
       let lr_retorno.valorisentoINSS = "                  "
    else
       if param.flagINSS = "S" then
          let lr_retorno.valorisentoINSS = "*0000000000000*00*"
       else
          let lr_retorno.valorisentoINSS = param.txtitmtot 
       end if
    end if
    
    if param.flagINSS is null then
       let lr_retorno.valortributavelINSS = "                  "
    else
       if param.flagINSS = "S" then
          let lr_retorno.valortributavelINSS = param.txtitmtot
       else
          let lr_retorno.valortributavelINSS = "*0000000000000*00*" 
       end if
    end if
    
      if param.flagPIS  is null or
         param.flagCOF  is null or
         param.flagCSLL is null then
         let lr_retorno.valorisentoCCP = "                  "
      else
         if param.flagPIS  = "N" and
            param.flagCOF  = "N" and
            param.flagCSLL = "N" then
            let lr_retorno.valorisentoCCP = param.txtitmtot
         else
            let lr_retorno.valorisentoCCP = "*0000000000000*00*"
         end if
      end if

     
      if param.flagPIS  is null or
         param.flagCOF  is null or
         param.flagCSLL is null then
         let lr_retorno.valortributavelCCP ="                  ";
      else
         if param.flagPIS  = "N" and
            param.flagCOF  = "N" and
            param.flagCSLL = "N"
            then
            let lr_retorno.valortributavelCCP ="*0000000000000*00*";
         else
            let lr_retorno.valortributavelCCP = param.txtitmtot;
         end if
      end if

      if param.flagCSLL is null then
         let lr_retorno.valortributavelCSLL ="   "
      else
         if param.flagCSLL = "S" then
            let lr_retorno.valortributavelCSLL ="001"
         else
            let lr_retorno.valortributavelCSLL ="000"
         end if
      end if

      if param.flagCOF is null then
         let lr_retorno.valortributavelCOF  ="   "
      else
         if param.flagCOF = "S" then
            let lr_retorno.valortributavelCOF  ="001"
         else
            let lr_retorno.valortributavelCOF  ="000"
         end if
      end if

      if param.flagPIS is null then
         let lr_retorno.valortributavelPIS  = "   "
      else
         if param.flagPIS = "S" then
            let lr_retorno.valortributavelPIS  = "001"
         else
            let lr_retorno.valortributavelPIS  = "000"
         end if
      end if
    
     open cbdbsr115017 using param.pstcoddig                
     fetch cbdbsr115017 into lr_retorno.nscdat,
                             lr_retorno.sexcod
    
     case lr_retorno.sexcod
        when "M"
           let lr_retorno.sexcod = "MA"
        when "F"
           let lr_retorno.sexcod = "FE"
        otherwise
           let lr_retorno.sexcod = "  "
     end case
     
     if lr_retorno.nscdat is null or lr_retorno.nscdat = " " then
        let lr_retorno.nscdat = "00000000"
     end if     
        
  return lr_retorno.flagIR,            
         lr_retorno.flagISS,           
         lr_retorno.flagINSS,          
         lr_retorno.arrecadacaoIR,     
         lr_retorno.codtributacaoINSS, 
         lr_retorno.pisnum,            
         lr_retorno.muninsnum,
         lr_retorno.succod,
         lr_retorno.codeventoreembolso, 
         lr_retorno.valorisentoIR,      
         lr_retorno.valortributavelIR,  
         lr_retorno.valorisentoISS,     
         lr_retorno.valortributavelISS, 
         lr_retorno.valorisentoINSS,    
         lr_retorno.valortributavelINSS,
         lr_retorno.valorisentoCCP,     
         lr_retorno.valortributavelCCP, 
         lr_retorno.valortributavelCSLL,
         lr_retorno.valortributavelCOF, 
         lr_retorno.valortributavelPIS,
         lr_retorno.nscdat,
         lr_retorno.sexcod      
         
end function


#-------------------------------------#
report bdbsr115_TXT_itau(l_param)
#-------------------------------------#

define l_param record
       seq                 integer 
     , pestip              char(1)
     , socopgfavnom        char(60)
     , cpfcgctxt           char(14)
     , endlgd              char(30)
     , lgdnum              like dpaksocor.lgdnum 
     , endcmp              char(10)
     , endbrr              char(30) 
     , ufdcod              char(2)   
     , cidnom              char(30)
     , cep                 char(10)
     , maides              char(60)
     , bcocod              like dbsmopgfav.bcocod     
     , bcoagnnum           like dbsmopgfav.bcoagnnum
     , bcoagndig           char(1)
     , bcoctanum           like dbsmopgfav.bcoctanum
     , bcoctadig           char(2)
     , flagIR              char(3)                 
     , flagISS             char(1)                 
     , flagINSS            char(1)                 
     , arrecadacaoIR       char(5)                 
     , codtributacaoINSS   char(3)
     , sexcod              char(2) 
     , pisnum              like dpaksocor.pisnum     
     , muninsnum           like dpaksocor.muninsnum 
     , cbo                 char(5) 
     , dataNasc            char(8)
     , socopgnum           like dbsmopg.socopgnum  
     , atdsrvnum           like datrservapol.atdsrvnum
     , atdsrvano           like datrservapol.atdsrvano
     , codeventoreembolso  smallint
     , socpgtopccod        like dbsmopgfav.socpgtopccod
     , nfsnum              like dbsmopgitm.nfsnum
     , socemsnfsdat        like dbsmopg.socemsnfsdat
     , socfatpgtdat        like dbsmopg.socfatpgtdat
     , socopgitmtot        like dbsmopgitm.socopgitmvlr
     , txtitmtot           char(18) 
     , l_dataEmissao       char(8) 
     , l_dataVencimento    char(8)
     , valorisentoIR       char(18)
     , valortributavelIR   char(18)
     , valorisentoISS      char(18)
     , valortributavelISS  char(18)
     , valorisentoINSS     char(18)
     , valortributavelINSS char(18)
     , atividade           char(60) 
     , succod              char(15)       
     , ramcod              char(15) 
     , aplnumdig           char(15) 
     , itmnumdig           char(15) 
     , l_dataAcionamento   char(14)
     , asitipdes           char(30)
     , asitipcod           integer
     , valorisentoCCP      char(18)
     , valortributavelCCP  char(18)
     , valortributavelCSLL char(3)
     , valortributavelCOF  char(3)
     , valortributavelPIS  char(3)
     , l_dataPagamento     char(8) 
     , l_dataLigacao       char(14)
     , l_dataPrestacao     char(14)
     , l_cidnom            char(60)
     , l_ufdcod            like datmlcl.ufdcod
     , l_brrnom            char(60)
     , l_pcpatvcod         like dpaksocor.pcpatvcod 
     , simoptpstflg        like dpaksocor.simoptpstflg
     , infissalqvlr        char(014)
end record

define l_header record
       dataEnvio char(14)
end record

  output
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00
    page length    01
    

  format
       
      on every row
        
        # Nao foi utilizado o first page header, pois ele completa com enter o que sobra da pagina
        # e a Itau soh estah esperando receber um enter apos o ultimo registro, favor nao alterar
        # para que nao ocorra problemas no envio dos arquivos
        if l_param.seq = 2 then
           let l_header.dataEnvio = bdbsr115_data_hora(" "," ")
           print column 0001, "000",
                 column 0004, "0000000001"  ,
                 column 0014, "ITAU PGTO PORTO SOCORRO  " ,
                 column 0039, m_seqArq using '&&&&&&&',
                 column 0046, l_header.dataEnvio,
                 column 0060, "1",1423 space
        end if 
        
        
        print column 0001, "001"                                        , # 01 CÓDIGO DA INTERFACE                                      
              column 0004, l_param.seq  using '&&&&&&&&&&'              , # 02 NO SEQUENCIAL DO REGISTRO                       
              column 0014, l_param.pestip                               , # 03 TIPO DE PESSOA                                  
              column 0015, "000"                                        , # 04 VAGO                                            
              column 0018, l_param.socopgfavnom                         , # 05 NOME                                            
              column 0078, l_param.cpfcgctxt                            , # 06 CPF OU CNPJ                                     
              column 0092, l_param.endlgd[1,30]                         , # 07 ENDEREÇO                                        
              column 0122, l_param.lgdnum    using '&&&&&'              , # 08 NO                                              
              column 0127, l_param.endcmp[1,10]                         , # 09 COMPLEMENTO                                     
              column 0137, l_param.endbrr[1,30]                         , # 10 BAIRRO                                          
              column 0167, l_param.ufdcod                               , # 11 ESTADO                                          
              column 0169, l_param.cidnom[1,30]                         , # 12 CIDADE                                          
              column 0199, l_param.cep                                  , # 13 CEP                                             
              column 0209, l_param.maides                               , # 14 E-MAIL                                          
              column 0269, l_param.bcocod     using "&&&&&"             , # 15 CÓDIGO DO BANCO                                 
              column 0274, l_param.bcoagnnum  using "&&&&&&&&&&"        , # 16 NO DA AGÊNCIA                                   
              column 0284, l_param.bcoagndig                            , # 17 DV DA AGÊNCIA                                   
              column 0285, l_param.bcoctanum  using "&&&&&&&&&&"        , # 18 NO DA CONTA CORRENTE                            
              column 0295, l_param.bcoctadig                            , # 19 DV DA CONTA CORRENTE                            
              column 0297, l_param.flagIR                               , # 20 CÓD TRIBUTAÇÃO IRRF                            
              column 0300, l_param.arrecadacaoIR using "&&&&&"          , # 21 NATUREZA DO RENDIMENTO                          
              column 0305, l_param.flagISS                              , # 22 CALCULA ISS ?                                   
              column 0306, l_param.flagINSS                             , # 23 CALCULA INSS ?                                  
              column 0307, l_param.codtributacaoINSS                    , # 24 CÓD TRIBUTAÇÃO INSS                             
              column 0310, l_param.sexcod                               , # 25 SEXO DO FAVORECIDO                
              column 0312, l_param.pisnum using "&&&&&&&&&&&"           , # 26 NO PIS                                     
              column 0323, l_param.muninsnum using "&&&&&&&&&&&"        , # 27 INSCRICAO MUNICIPAL                        
              column 0334, "0000000000"                                 , # 28 VAGO                                       
              column 0344, l_param.cbo                                  , # 29  CBO (CLASSIFIC BRASILEIRA OCUPAÇÃO)       
              column 0349, "00000000000000"                             , # 30 VAGO                                       
              column 0363, "0000000000"                                 , # 31 VAGO                                       
              column 0373, 15 space                                     , # 32 VAGO                                       
              column 0388, 15 space                                     , # 33 VAGO                                       
              column 0403, "0000000000"                                 , # 34 VAGO                                       
              column 0413, l_param.dataNasc                             , # 35 DATA DE NASCIMENTO                         
              column 0421, " "                                          , # 36 VAGO                                       
              column 0422, "000"                                        , # 37 VAGO                                       
              column 0425, l_param.l_cidnom                             , # 38 CIDADE DO SERVICO
              column 0485, l_param.infissalqvlr                         , # 39 ALIQUOTA OP                                       
              column 0499, l_param.l_pcpatvcod using "&&&&&"            , # 40 CODIGO ATIVIDADE PRINCIPAL DO PRESTADOR                                       
              column 0504, "0000000000"                                 , # 41 VAGO                                       
              column 0514, l_param.simoptpstflg                         , # 42 OPTANTE SIMPLES                                       
              column 0515, "0000000000"                                 , # 43 VAGO                                       
              column 0525, l_param.l_ufdcod                             , # 44 UF DO SERVICO                                       
              column 0527, "    ",l_param.socopgnum  clipped            , # 45 IDENTIFICAÇÃO DO PAGAMENTO OP mais Servico 
                           " ", l_param.atdsrvnum using "&&&&&&&",                                                      
                           "-", l_param.atdsrvano using "&&",                                                           
              column 0552, "00001"                                      , # 46 CÓD DA EMPRESA                                   
              column 0557, "00000"                                      , # 47 VAGO                                             
              column 0562, l_param.codeventoreembolso using "&&&&&"     , # 48 CODIGO DO EVENTO                                 
              column 0567, l_param.atdsrvano using "&&&"                , # 49 ANO DO SERVICO                                   
              column 0570, l_param.socpgtopccod using '&&&'             , # 50  FORMA DE PAGAMENTO                              
              column 0573, l_param.nfsnum  using '&&&&&&&&&&&&&&&&&&&&' , # 51  NO DO DOCUMENTO                          
              column 0593, l_param.l_dataEmissao                        , # 52 DATA DE EMISSAO                                  
              column 0601, l_param.l_dataPagamento                      , # 53 DATA DO PAGAMENTO                                
              column 0609, " "                                          , # 54 VAGO                                             
              column 0610, l_param.txtitmtot                            , # 55 VALOR BRUTO DO ITEM                        
              column 0628, " "                                          , # 56 VAGO                                       
              column 0629, l_param.valorisentoIR                        , # 57 VALOR ISENTO IR                            
              column 0647, " "                                          , # 58 VAGO                                       
              column 0648, l_param.valortributavelIR                    , # 59 VALOR TRIBUTÁVEL IR                        
              column 0666, " "                                          , # 60 VAGO                                       
              column 0667, l_param.valorisentoISS                       , # 61 VALOR ISENTO ISS                           
              column 0685, " "                                          , # 62 VAGO                                       
              column 0686, l_param.valortributavelISS                   , # 63 VALOR TRIBUTÁVEL ISS                       
              column 0704, " "                                          , # 64 VAGO                                       
              column 0705, l_param.valorisentoINSS                      , # 65 VALOR ISENTO INSS                          
              column 0723, " "                                          , # 66 VAGO                                       
              column 0724, l_param.valortributavelINSS                  , # 67 VALOR TRIBUTÁVEL INSS                      
              column 0742, " "                                          , # 68 VAGO                                       
              column 0743, l_param.socopgnum using "&&&&&&&&&&&&&&&&&&" , # 69 NUMERO DA ORDEM DE PAGAMENTO       
              column 0761, " "                                          , # 70 VAGO                                  
              column 0762, l_param.atdsrvnum using "&&&&&&&&&&&&&&&&&&" , # 71 NUMERO DO SERVICO                  
              column 0780, " "                                          , # 72  VAGO                                  
              column 0781, "000000000000000000"                         , # 73  VAGO                                  
              column 0799, l_param.atividade                            , # 74  DESCRICAO ATIVIDADE PRINCIPAL DO PRESTADOR  
              column 0859, " "                                          , # 75  VAGO                                          
              column 0860, "000000000000000000"                         , # 76  VAGO                                          
              column 0878, " "                                          , # 77  VAGO                                          
              column 0879, "000000000000000000"                         , # 78  VAGO                                          
              column 0897, " "                                          , # 79  VAGO                                          
              column 0898, "000000000000000000"                         , # 80  VAGO                                          
              column 0916, "00000"                                      , # 81  VAGO                                          
              column 0921, l_param.succod                               , # 82  SUCURSAL                                      
              column 0936, l_param.ramcod                               , # 83  RAMO                                          
              column 0951, l_param.aplnumdig                            , # 84  NUMERO DA APOLICE                             
              column 0966, l_param.itmnumdig                            , # 85  ITEM DA APOLICE                               
              column 0981, l_param.l_dataLigacao," "                    , # 86  DATA DA LIGACAO                                          
              column 0996, l_param.l_dataPrestacao," "                  , # 87  DATA DA PRESTACAO DO SERVICO                                          
              column 1011, "               "                            , # 88  VAGO                                          
              column 1026, "               "                            , # 89  VAGO                                          
              column 1041, "               "                            , # 90  VAGO                                          
              column 1056, l_param.l_dataAcionamento," "                , # 91  DATA DE ACIONAMENTO                           
              column 1071, l_param.asitipdes[1,30]                      , # 92  DESCRICAO DA ASSISTENCIA                      
              column 1101, "                         "                  , # 93  VAGO                                          
              column 1126, l_param.asitipcod using '&&&&&'              , # 94  CODIGO DA ASSISTENCIA                         
              column 1131, "             "                              , # 95  VAGO                                          
              column 1144, " "                                          , # 96  VAGO                                         
              column 1145, l_param.valorisentoCCP                       , # 97  VALOR ISENTO CCP                              
              column 1163, " "                                          , # 98  VAGO                                          
              column 1164, l_param.valortributavelCCP                   , # 99  VALOR TRIBUTÁVEL CCP                          
              column 1182, l_param.valortributavelCSLL                  , # 100 CODIGO TRIBUTACAO CSLL                       
              column 1185, l_param.valortributavelCOF                   , # 101 CODIGO TRIBUTACAO COFINS                     
              column 1188, l_param.valortributavelPIS                   , # 102 CODIGO TRIBUTACAO PIS                        
              column 1191, "               "                            , # 103 VAGO                                         
              column 1206, "               "                            , # 104 VAGO                                         
              column 1221, "               "                            , # 105 VAGO                                         
              column 1236, " "                                          , # 106 VAGO                                         
              column 1237, "00000000"                                   , # 107 VAGO                                         
              column 1245, " "                                          , # 108 VAGO                                         
              column 1246, "000000000000000000"                         , # 109 VAGO                                         
              column 1264, "00000"                                      , # 110 VAGO                                         
              column 1269, "0000000000"                                 , # 111 VAGO                                         
              column 1279, "0000000000"                                 , # 112 VAGO                                         
              column 1289, "000000000000000"                            , # 113 VAGO                                         
              column 1304, " "                                          , # 114 VAGO                                         
              column 1305, "000000000000000000"                         , # 115 VAGO                                         
              column 1323, " "                                          , # 116 VAGO                                         
              column 1324, "000000000000000000"                         , # 117 VAGO                                         
              column 1342, " "                                          , # 118 VAGO                                         
              column 1343, "000000000000000000"                         , # 119 VAGO                                         
              column 1361, " "                                          , # 120 VAGO                                         
              column 1362, "000000000000000000"                         , # 121 VAGO                                         
              column 1380, " "                                          , # 122 VAGO                                         
              column 1381, "000000000000000000"                         , # 123 VAGO                                         
              column 1399, " "                                          , # 124 VAGO                                         
              column 1400, "000000000000000000"                         , # 125 VAGO                                         
              column 1418, "000"                                        , # 126 VAGO                                         
              column 1421, l_param.l_brrnom                             , # 127 BAIRRO DO SERVICO                                   
              column 1481, "000"                                          # 128 VAGO                                    
                                                                            
      on last row
         print column 0001, "999",
               column 0004, l_param.seq+1 using '&&&&&&&&&&',
               column 0014, l_param.seq+1 using '&&&&&&&&&&',
               column 0024, m_valorTotOP ,
               column 0041,1443 space
 
 
 end report  


#-------------------------------------#
report bdbsr115_EXE_itau(l_param)
#-------------------------------------#

define l_param record
       seq                 integer 
     , pestip              char(1)
     , socopgfavnom        char(60)
     , cpfcgctxt           char(14)
     , endlgd              char(30)
     , lgdnum              like dpaksocor.lgdnum 
     , endcmp              char(10)
     , endbrr              char(30) 
     , ufdcod              char(2)   
     , cidnom              char(30)
     , cep                 char(10)
     , maides              char(60)
     , bcocod              like dbsmopgfav.bcocod     
     , bcoagnnum           like dbsmopgfav.bcoagnnum
     , bcoagndig           char(1)
     , bcoctanum           like dbsmopgfav.bcoctanum
     , bcoctadig           char(2)
     , flagIR              char(3)                 
     , flagISS             char(1)                 
     , flagINSS            char(1)                 
     , arrecadacaoIR       char(5)                 
     , codtributacaoINSS   char(3)
     , sexcod              char(2) 
     , pisnum              like dpaksocor.pisnum     
     , muninsnum           like dpaksocor.muninsnum 
     , cbo                 char(5) 
     , dataNasc            char(8)
     , socopgnum           like dbsmopg.socopgnum  
     , atdsrvnum           like datrservapol.atdsrvnum
     , atdsrvano           like datrservapol.atdsrvano
     , codeventoreembolso  smallint
     , socpgtopccod        like dbsmopgfav.socpgtopccod
     , nfsnum              like dbsmopgitm.nfsnum
     , socemsnfsdat        like dbsmopg.socemsnfsdat
     , socfatpgtdat        like dbsmopg.socfatpgtdat
     , socopgitmtot        like dbsmopgitm.socopgitmvlr
     , txtitmtot           char(18) 
     , l_dataEmissao       char(8) 
     , l_dataVencimento    char(8)
     , valorisentoIR       char(18)
     , valortributavelIR   char(18)
     , valorisentoISS      char(18)
     , valortributavelISS  char(18)
     , valorisentoINSS     char(18)
     , valortributavelINSS char(18)
     , atividade           char(60) 
     , succod              char(15)       
     , ramcod              char(15) 
     , aplnumdig           char(15) 
     , itmnumdig           char(15) 
     , l_dataAcionamento   char(14)
     , asitipdes           char(30)
     , asitipcod           integer
     , valorisentoCCP      char(18)
     , valortributavelCCP  char(18)
     , valortributavelCSLL char(3)
     , valortributavelCOF  char(3)
     , valortributavelPIS  char(3)
     , l_dataPagamento     char(8)
     , l_dataLigacao       char(14)
     , l_dataPrestacao     char(14)
     , l_cidnom            char(60)
     , l_ufdcod            like datmlcl.ufdcod
     , l_brrnom            char(60)  
     , l_pcpatvcod         like dpaksocor.pcpatvcod
     , simoptpstflg        like dpaksocor.simoptpstflg  
     , infissalqvlr        char(014)   
end record

define l_header record
       dataEnvio date
end record

 output                  
                         
    left   margin    00  
    right  margin    00  
    top    margin    00  
    bottom margin    00  
    page   length    100  
                         
 format                             
                     
     first page header  
       let l_header.dataEnvio = bdbsr115_data_hora(" "," ")
       print column 0001, "000",
             column 0004, "0000000001"  ,
             column 0014, "ITAU PGTO PORTO SOCORRO  " ,
             column 0039, m_seqArq using '&&&&&&&',
             column 0046, l_header.dataEnvio,
             column 0060, "1",1423 space
             
       print "1  CÓDIGO DA INTERFACE                       ", ASCII(9); 
       print "2  NO SEQUENCIAL DO REGISTRO                 ", ASCII(9); 
       print "3  TIPO DE PESSOA                            ", ASCII(9); 
       print "4  VAGO                                      ", ASCII(9); 
       print "5  NOME                                      ", ASCII(9); 
       print "6  CPF OU CNPJ                               ", ASCII(9); 
       print "7  ENDEREÇO                                  ", ASCII(9); 
       print "8  NO                                        ", ASCII(9); 
       print "9  COMPLEMENTO                               ", ASCII(9); 
       print "10 BAIRRO                                    ", ASCII(9); 
       print "11 ESTADO                                    ", ASCII(9); 
       print "12 CIDADE                                    ", ASCII(9); 
       print "13 CEP                                       ", ASCII(9); 
       print "14 E-MAIL                                    ", ASCII(9); 
       print "15 CÓDIGO DO BANCO                           ", ASCII(9); 
       print "16 NO DA AGÊNCIA                             ", ASCII(9); 
       print "17 DV DA AGÊNCIA                             ", ASCII(9); 
       print "18 NO DA CONTA CORRENTE                      ", ASCII(9); 
       print "19 DV DA CONTA CORRENTE                      ", ASCII(9); 
       print "20 CÓD TRIBUTAÇÃO IRRF                       ", ASCII(9); 
       print "21 NATUREZA DO RENDIMENTO                    ", ASCII(9); 
       print "22 CALCULA ISS ?                             ", ASCII(9); 
       print "23 CALCULA INSS ?                            ", ASCII(9); 
       print "24 CÓD TRIBUTAÇÃO INSS                       ", ASCII(9); 
       print "25 SEXO DO FAVORECIDO                        ", ASCII(9); 
       print "26 NO PIS                                    ", ASCII(9); 
       print "27 INSCRICAO MUNICIPAL                       ", ASCII(9); 
       print "28 VAGO                                      ", ASCII(9); 
       print "29 CBO (CLASSIFIC BRASILEIRA OCUPAÇÃO)       ", ASCII(9); 
       print "30 VAGO                                      ", ASCII(9); 
       print "31 VAGO                                      ", ASCII(9); 
       print "32 VAGO                                      ", ASCII(9); 
       print "33 VAGO                                      ", ASCII(9); 
       print "34 VAGO                                      ", ASCII(9); 
       print "35 DATA DE NASCIMENTO                        ", ASCII(9); 
       print "36 VAGO                                      ", ASCII(9); 
       print "37 VAGO                                      ", ASCII(9); 
       print "38 CIDADE DO SERVICO                         ", ASCII(9); 
       print "39 ALIQUOTA OP                               ", ASCII(9); 
       print "40 CODIGO ATIVIDADE PRINCIPAL DO PRESTADOR   ", ASCII(9); 
       print "41 VAGO                                      ", ASCII(9); 
       print "42 OPTANTE SIMPLES                           ", ASCII(9); 
       print "43 VAGO                                      ", ASCII(9); 
       print "44 UF DO SERVICO                             ", ASCII(9); 
       print "45 IDENTIFICAÇÃO DO PAGAMENTO OP mais Servico", ASCII(9); 
       print "46 CÓD DA EMPRESA                            ", ASCII(9); 
       print "47 VAGO                                      ", ASCII(9); 
       print "48 CODIGO DO EVENTO                          ", ASCII(9); 
       print "49 ANO DO SERVICO                            ", ASCII(9); 
       print "50 FORMA DE PAGAMENTO                        ", ASCII(9); 
       print "51 NO DO DOCUMENTO                           ", ASCII(9); 
       print "52 DATA DE EMISSAO                           ", ASCII(9); 
       print "53 DATA DO PAGAMENTO                         ", ASCII(9); 
       print "54 VAGO                                      ", ASCII(9); 
       print "55 VALOR BRUTO DO ITEM                       ", ASCII(9); 
       print "56 VAGO                                      ", ASCII(9); 
       print "57 VALOR ISENTO IR                           ", ASCII(9); 
       print "58 VAGO                                      ", ASCII(9); 
       print "59 VALOR TRIBUTÁVEL IR                       ", ASCII(9); 
       print "60 VAGO                                      ", ASCII(9); 
       print "61 VALOR ISENTO ISS                          ", ASCII(9); 
       print "62 VAGO                                      ", ASCII(9); 
       print "63 VALOR TRIBUTÁVEL ISS                      ", ASCII(9); 
       print "64 VAGO                                      ", ASCII(9); 
       print "65 VALOR ISENTO INSS                         ", ASCII(9); 
       print "66 VAGO                                      ", ASCII(9); 
       print "67 VALOR TRIBUTÁVEL INSS                     ", ASCII(9); 
       print "68 VAGO                                      ", ASCII(9); 
       print "69 NUMERO DA ORDEM DE PAGAMENTO              ", ASCII(9); 
       print "70 VAGO                                      ", ASCII(9); 
       print "71 NUMERO DO SERVICO                         ", ASCII(9); 
       print "72 VAGO                                      ", ASCII(9); 
       print "73 VAGO                                      ", ASCII(9); 
       print "74 DESCRICAO ATIVIDADE PRINCIPAL DO PRESTADOR", ASCII(9); 
       print "75 VAGO                                      ", ASCII(9); 
       print "76 VAGO                                      ", ASCII(9); 
       print "77 VAGO                                      ", ASCII(9); 
       print "78 VAGO                                      ", ASCII(9); 
       print "79 VAGO                                      ", ASCII(9); 
       print "80 VAGO                                      ", ASCII(9); 
       print "81 VAGO                                      ", ASCII(9); 
       print "82 SUCURSAL                                  ", ASCII(9); 
       print "83 RAMO                                      ", ASCII(9); 
       print "84 NUMERO DA APOLICE                         ", ASCII(9); 
       print "85 ITEM DA APOLICE                           ", ASCII(9); 
       print "86 DATA DA LIGACAO                           ", ASCII(9); 
       print "87 DATA DA PRESTACAO DO SERVICO              ", ASCII(9); 
       print "88 VAGO                                      ", ASCII(9); 
       print "89 VAGO                                      ", ASCII(9); 
       print "90 VAGO                                      ", ASCII(9); 
       print "91 DATA DE ACIONAMENTO                       ", ASCII(9); 
       print "92 DESCRICAO DA ASSISTENCIA                  ", ASCII(9); 
       print "93 VAGO                                      ", ASCII(9); 
       print "94 CODIGO DA ASSISTENCIA                     ", ASCII(9); 
       print "95 VAGO                                      ", ASCII(9); 
       print "96  VAGO                                     ", ASCII(9); 
       print "97 VALOR ISENTO CCP                          ", ASCII(9); 
       print "98 VAGO                                      ", ASCII(9); 
       print "99 VALOR TRIBUTÁVEL CCP                      ", ASCII(9); 
       print "100 CODIGO TRIBUTACAO CSLL                   ", ASCII(9); 
       print "101 CODIGO TRIBUTACAO COFINS                 ", ASCII(9); 
       print "102 CODIGO TRIBUTACAO PIS                    ", ASCII(9); 
       print "103 VAGO                                     ", ASCII(9); 
       print "104 VAGO                                     ", ASCII(9); 
       print "105 VAGO                                     ", ASCII(9); 
       print "106 VAGO                                     ", ASCII(9); 
       print "107 VAGO                                     ", ASCII(9); 
       print "108 VAGO                                     ", ASCII(9); 
       print "109 VAGO                                     ", ASCII(9); 
       print "110 VAGO                                     ", ASCII(9); 
       print "111 VAGO                                     ", ASCII(9); 
       print "112 VAGO                                     ", ASCII(9); 
       print "113 VAGO                                     ", ASCII(9); 
       print "114 VAGO                                     ", ASCII(9); 
       print "115 VAGO                                     ", ASCII(9); 
       print "116 VAGO                                     ", ASCII(9); 
       print "117 VAGO                                     ", ASCII(9); 
       print "118 VAGO                                     ", ASCII(9); 
       print "119 VAGO                                     ", ASCII(9); 
       print "120 VAGO                                     ", ASCII(9); 
       print "121 VAGO                                     ", ASCII(9); 
       print "122 VAGO                                     ", ASCII(9); 
       print "123 VAGO                                     ", ASCII(9); 
       print "124 VAGO                                     ", ASCII(9); 
       print "125 VAGO                                     ", ASCII(9); 
       print "126 VAGO                                     ", ASCII(9); 
       print "127 BAIRRO DO SERVICO                        ", ASCII(9); 
       print "128 VAGO                                     ", ASCII(9); 
                                                                     
      on last row                                                    
         print column 0001, "999",
               column 0004, l_param.seq+1 using '&&&&&&&&&&',
               column 0014, l_param.seq+1 using '&&&&&&&&&&',
               column 0024, m_valorTotOP ,
               column 0041, 1443 space;
     
      on every row
        
        print column 0001, "001"                                ,  ASCII(9);# 01 CÓDIGO DA INTERFACE                                      
        print column 0004, l_param.seq  using '&&&&&&&&&&'      ,  ASCII(9);# 02 NO SEQUENCIAL DO REGISTRO                       
        print column 0014, l_param.pestip                       ,  ASCII(9);# 03 TIPO DE PESSOA                                  
        print column 0015, "000"                                ,  ASCII(9);# 04 VAGO                                            
        print column 0018, l_param.socopgfavnom                 ,  ASCII(9);# 05 NOME                                            
        print column 0078, l_param.cpfcgctxt                    ,  ASCII(9);# 06 CPF OU CNPJ                                     
        print column 0092, l_param.endlgd[1,30]                 ,  ASCII(9);# 07 ENDEREÇO                                        
        print column 0122, l_param.lgdnum    using '&&&&&'      ,  ASCII(9);# 08 NO                                              
        print column 0127, l_param.endcmp[1,10]                 ,  ASCII(9);# 09 COMPLEMENTO                                     
        print column 0137, l_param.endbrr[1,30]                 ,  ASCII(9);# 10 BAIRRO                                          
        print column 0167, l_param.ufdcod                       ,  ASCII(9);# 11 ESTADO                                          
        print column 0169, l_param.cidnom[1,30]                 ,  ASCII(9);# 12 CIDADE                                          
        print column 0199, l_param.cep                          ,  ASCII(9);# 13 CEP                                             
        print column 0209, l_param.maides                       ,  ASCII(9);# 14 E-MAIL                                          
        print column 0269, l_param.bcocod     using "&&&&&"     ,  ASCII(9);# 15 CÓDIGO DO BANCO                                 
        print column 0274, l_param.bcoagnnum  using "&&&&&&&&&&",  ASCII(9);# 16 NO DA AGÊNCIA                                   
        print column 0284, l_param.bcoagndig                    ,  ASCII(9);# 17 DV DA AGÊNCIA                                   
        print column 0285, l_param.bcoctanum  using "&&&&&&&&&&",  ASCII(9);# 18 NO DA CONTA CORRENTE                            
        print column 0295, l_param.bcoctadig,                      ASCII(9);# 19 DV DA CONTA CORRENTE                            
        print column 0297, l_param.flagIR,                         ASCII(9);# 20 CÓD TRIBUTAÇÃO IRRF                            
        print column 0300, l_param.arrecadacaoIR using "&&&&&",    ASCII(9);# 21 NATUREZA DO RENDIMENTO                          
        print column 0305, l_param.flagISS,                        ASCII(9);# 22 CALCULA ISS ?                                   
        print column 0306, l_param.flagINSS,                       ASCII(9);# 23 CALCULA INSS ?                                  
        print column 0307, l_param.codtributacaoINSS,              ASCII(9);# 24 CÓD TRIBUTAÇÃO INSS                             
        print column 0310, l_param.sexcod,                         ASCII(9);# 25 SEXO DO FAVORECIDO                
        print column 0312, l_param.pisnum using "&&&&&&&&&&&",     ASCII(9);# 26 NO PIS                                     
        print column 0323, l_param.muninsnum using "&&&&&&&&&&&",  ASCII(9);# 27 INSCRICAO MUNICIPAL                        
        print column 0334, "0000000000",                           ASCII(9);# 28 VAGO                                       
        print column 0344, l_param.cbo,                            ASCII(9);# 29  CBO (CLASSIFIC BRASILEIRA OCUPAÇÃO)       
        print column 0349, "00000000000000",                       ASCII(9);# 30 VAGO                                       
        print column 0363, "0000000000" ,                          ASCII(9);# 31 VAGO                                       
        print column 0373, 15 space,                               ASCII(9);# 32 VAGO                                       
        print column 0388, 15 space,                               ASCII(9);# 33 VAGO                                       
        print column 0403, "0000000000",                           ASCII(9);# 34 VAGO                                       
        print column 0413, l_param.dataNasc,                       ASCII(9);# 35 DATA DE NASCIMENTO                         
        print column 0421, " ",                                    ASCII(9);# 36 VAGO                                       
        print column 0422, "000",                                  ASCII(9);# 37 VAGO                                       
        print column 0425, l_param.l_cidnom ,                      ASCII(9);# 38 CIDADE DO SERVICO                                       
        print column 0485, l_param.infissalqvlr,                   ASCII(9);# 39 Aliquota OP                                       
        print column 0499, l_param.l_pcpatvcod using "&&&&&",      ASCII(9);# 40 CODIGO ATIVIDADE PRINCIPAL DO PRESTADOR                                       
        print column 0504, "0000000000",                           ASCII(9);# 41 VAGO                                       
        print column 0514, l_param.simoptpstflg,                   ASCII(9);# 42 Optante Simples                                       
        print column 0515, "0000000000",                           ASCII(9);# 43 VAGO                                       
        print column 0525, l_param.l_ufdcod,                       ASCII(9);# 44 UF DO SERVICO                                       
        print column 0527, "    ",l_param.socopgnum  clipped,       # 45 IDENTIFICAÇÃO DO PAGAMENTO OP mais Servico 
                           " ", l_param.atdsrvnum using "&&&&&&&",                                                        
                           "-", l_param.atdsrvano using "&&",      ASCII(9);                                                      
        print column 0552, "00001",                                ASCII(9);# 46 CÓD DA EMPRESA                                   
        print column 0557, "00000",                                ASCII(9);# 47 VAGO                                             
        print column 0562, l_param.codeventoreembolso using "&&&&&", ASCII(9); # 48 CODIGO DO EVENTO                                 
        print column 0567, l_param.atdsrvano using "&&&",         ASCII(9);# 49  ANO DO SERVICO                                   
        print column 0570, l_param.socpgtopccod using '&&&',      ASCII(9);# 50  FORMA DE PAGAMENTO                              
        print column 0573, l_param.nfsnum  using '&&&&&&&&&&&&&&&&&&&&', ASCII(9);# 51  NO DO DOCUMENTO                          
        print column 0593, l_param.l_dataEmissao,                 ASCII(9);# 52 DATA DE EMISSAO                                  
        print column 0601, l_param.l_dataPagamento,               ASCII(9);# 53 DATA DO PAGAMENTO                                
        print column 0609, " ",                                   ASCII(9);# 54 VAGO                                             
        print column 0610, l_param.txtitmtot,                     ASCII(9);# 55 VALOR BRUTO DO ITEM                        
        print column 0628, " ",                                   ASCII(9);# 56 VAGO                                       
        print column 0629, l_param.valorisentoIR,                 ASCII(9);# 57 VALOR ISENTO IR                            
        print column 0647, " ",                                   ASCII(9);# 58 VAGO                                       
        print column 0648, l_param.valortributavelIR,             ASCII(9);# 59 VALOR TRIBUTÁVEL IR                        
        print column 0666, " ",                                   ASCII(9);# 60 VAGO                                       
        print column 0667, l_param.valorisentoISS,                ASCII(9);# 61 VALOR ISENTO ISS                           
        print column 0685, " ",                                   ASCII(9);# 62 VAGO                                       
        print column 0686, l_param.valortributavelISS,            ASCII(9);# 63 VALOR TRIBUTÁVEL ISS                       
        print column 0704, " "   ,                                ASCII(9);# 64 VAGO                                       
        print column 0705, l_param.valorisentoINSS,               ASCII(9);# 65 VALOR ISENTO INSS                          
        print column 0723, " ",                                   ASCII(9);# 66 VAGO                                       
        print column 0724, l_param.valortributavelINSS,           ASCII(9);# 67 VALOR TRIBUTÁVEL INSS                      
        print column 0742, " ",                                   ASCII(9);# 68 VAGO                                       
        print column 0743, l_param.socopgnum using "&&&&&&&&&&&&&&&&&&" ,ASCII(9); # 69 NUMERO DA ORDEM DE PAGAMENTO       
        print column 0761, " "                                       ,ASCII(9); # 70 VAGO                                  
        print column 0762, l_param.atdsrvnum using "&&&&&&&&&&&&&&&&&&" , ASCII(9);# 71 NUMERO DO SERVICO                  
        print column 0780, " "                                       , ASCII(9);# 72 VAGO                                  
        print column 0781, "000000000000000000"                      , ASCII(9);# 73 VAGO                                  
        print column 0799, l_param.atividade                         , ASCII(9);# 74 DESCRICAO ATIVIDADE PRINCIPAL DO PRESTADOR  
        print column 0859, " "                                       , ASCII(9);# 75 VAGO                                          
        print column 0860, "000000000000000000"                      , ASCII(9);# 76 VAGO                                          
        print column 0878, " "                                       , ASCII(9);# 77 VAGO                                          
        print column 0879, "000000000000000000"                      , ASCII(9);# 78 VAGO                                          
        print column 0897, " "                                       , ASCII(9);# 79 VAGO                                          
        print column 0898, "000000000000000000"                      , ASCII(9);# 80 VAGO                                          
        print column 0916, "00000"                                   , ASCII(9);# 81 VAGO                                          
        print column 0921, l_param.succod                            , ASCII(9);# 82 SUCURSAL                                      
        print column 0936, l_param.ramcod                            , ASCII(9);# 83 RAMO                                          
        print column 0951, l_param.aplnumdig                         , ASCII(9);# 84 NUMERO DA APOLICE                             
        print column 0966, l_param.itmnumdig                         , ASCII(9);# 85 ITEM DA APOLICE                               
        print column 0981, l_param.l_dataLigacao," "                 , ASCII(9);# 86 DATA DA LIGACAO                                         
        print column 0996, l_param.l_dataPrestacao," "               , ASCII(9);# 87 DATA DA PRESTACAO DO SERVICO                                          
        print column 1011, "               "                         , ASCII(9);# 88 VAGO                                          
        print column 1026, "               "                         , ASCII(9);# 89 VAGO                                          
        print column 1041, "               "                         , ASCII(9);# 90 VAGO                                          
        print column 1056, l_param.l_dataAcionamento," "             , ASCII(9);# 91 DATA DE ACIONAMENTO                           
        print column 1071, l_param.asitipdes[1,30]                   , ASCII(9);# 92 DESCRICAO DA ASSISTENCIA                      
        print column 1101, "                         "               , ASCII(9);# 93 VAGO                                          
        print column 1126, l_param.asitipcod using '&&&&&'           , ASCII(9);# 94 CODIGO DA ASSISTENCIA                         
        print column 1131, "             "                           , ASCII(9);# 95 VAGO                                          
        print column 1144, " "                                       , ASCII(9);# 96  VAGO                                         
        print column 1145, l_param.valorisentoCCP                    , ASCII(9);# 97 VALOR ISENTO CCP                              
        print column 1163, " "                                       , ASCII(9);# 98 VAGO                                          
        print column 1164, l_param.valortributavelCCP                , ASCII(9);# 99 VALOR TRIBUTÁVEL CCP                          
        print column 1182, l_param.valortributavelCSLL               , ASCII(9);# 100 CODIGO TRIBUTACAO CSLL                       
        print column 1185, l_param.valortributavelCOF                , ASCII(9);# 101 CODIGO TRIBUTACAO COFINS                     
        print column 1188, l_param.valortributavelPIS                , ASCII(9);# 102 CODIGO TRIBUTACAO PIS                        
        print column 1191, "               "                         , ASCII(9);# 103 VAGO                                         
        print column 1206, "               "                         , ASCII(9);# 104 VAGO                                         
        print column 1221, "               "                         , ASCII(9);# 105 VAGO                                         
        print column 1236, " "                                       , ASCII(9);# 106 VAGO                                         
        print column 1237, "00000000"                                , ASCII(9);# 107 VAGO                                         
        print column 1245, " "                                       , ASCII(9);# 108 VAGO                                         
        print column 1246, "000000000000000000"                      , ASCII(9);# 109 VAGO                                         
        print column 1264, "00000"                                   , ASCII(9);# 110 VAGO                                         
        print column 1269, "0000000000"                              , ASCII(9);# 111 VAGO                                         
        print column 1279, "0000000000"                              , ASCII(9);# 112 VAGO                                         
        print column 1289, "000000000000000"                         , ASCII(9);# 113 VAGO                                         
        print column 1304, " "                                       , ASCII(9);# 114 VAGO                                         
        print column 1305, "000000000000000000"                      , ASCII(9);# 115 VAGO                                         
        print column 1323, " "                                       , ASCII(9);# 116 VAGO                                         
        print column 1324, "000000000000000000"                      , ASCII(9);# 117 VAGO                                         
        print column 1342, " "                                       , ASCII(9);# 118 VAGO                                         
        print column 1343, "000000000000000000"                      , ASCII(9);# 119 VAGO                                         
        print column 1361, " "                                       , ASCII(9);# 120 VAGO                                         
        print column 1362, "000000000000000000"                      , ASCII(9);# 121 VAGO                                         
        print column 1380, " "                                       , ASCII(9);# 122 VAGO                                         
        print column 1381, "000000000000000000"                      , ASCII(9);# 123 VAGO                                         
        print column 1399, " "                                       , ASCII(9);# 124 VAGO                                         
        print column 1400, "000000000000000000"                      , ASCII(9);# 125 VAGO                                         
        print column 1418, "000"                                     , ASCII(9);# 126 VAGO                                         
        print column 1421, l_param.l_brrnom                          , ASCII(9);# 127 BAIRRO DO SERVICO                                
        print column 1481, "000"                                      # 128 VAGO                                    
                                                                                                                                                        
 end report 
 
#-------------------------------------#  
report bdbsr115_TXT_branco(l_param)     
#-------------------------------------#  

define l_param record 
    seq  integer 
end record


define l_header record
       dataEnvio char(14)
end record

 output                  
                         
    page length    02 
    left margin    00 
    right margin   00 
    top margin     00 
    bottom margin  00 
                         
 format                             
                     
     first page header  
       let l_header.dataEnvio = bdbsr115_data_hora(" "," ")
       print column 0001, "000",
             column 0004, "0000000001"  ,
             column 0014, "ITAU PGTO PORTO SOCORRO  " ,
             column 0039, m_seqArq using '&&&&&&&',
             column 0046, l_header.dataEnvio,
             column 0060, "1",1423 space
      
      on every row
      print ""
                         
      on last row
         print column 0001, "999",
               column 0004, l_param.seq+1 using '&&&&&&&&&&',
               column 0014, l_param.seq+1 using '&&&&&&&&&&',
               column 0024, m_valorTotOP using '&&&&&&&&&&&&&&&&&' ,
               column 0041, 1443 space


end report                                                                                                                                             
                                                                                                                                                        
#-------------------------------------#                                                                                                                 
 report bdbsr115_DOC_itau(l_res)
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

        print "Resumo de pagamentos de serviços para Itaú Auto e Residência  com vencimento em ", m_data
        print ""
        print "OP       Prestador                                  Servicos          Valor"

     on last row
        print "                                                    --------   ------------"
        print "                                                    ", 
              l_srvtot using "########", "   ", m_valorOP using "########&.&&"

     on every row
        print l_res.socopgnum using "&&&&&&", "   ", l_res.socopgfavnom, "   ",
              l_res.l_srvop using "########", "  ", l_res.l_vlrop using "########&.&&"
        let l_srvtot = l_srvtot + l_res.l_srvop
        let l_vlrtot = l_vlrtot + l_res.l_vlrop

 end report
 
 #-------------------------------------#                                                                                                                 
 report bdbsr115_DOC_branco()
#-------------------------------------#
  
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

        print "Resumo de pagamentos de serviços para Itaú Auto e Residência  com vencimento em ", m_data
        print ""
        print "OP       Prestador                                  Servicos          Valor"

     on last row
        print "                                                    --------   ------------"
        print "                                                    ", 
              l_srvtot using "########", "   ", m_valorOP using "########&.&&"

 end report


#------------------------------------#
 function bdbsr115_pontuacao(l_valor)
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
 function bdbsr115_valor(l_param,l_seq)
#--------------------------------#

     define l_param  decimal(15,5),
            l_seq    integer,
            l_valor  char(018),
            l_return char(018),
            l_valorInt  char(13),
            l_valorInt2  char(9),
            l_valorDec  char(2),
            l_ind    smallint

     display "l_param: ",l_param
     let l_valor = l_param using "<<<<<<<<<<<<<<&.&&"
     let l_return = " "

     for l_ind = 1 to length(l_valor)
         if  l_valor[l_ind] <> ',' and l_valor[l_ind] <> '.' then
             let l_return = l_return clipped, l_valor[l_ind]
         else
            let l_valorInt = l_return clipped 
            let l_return   = null
         end if
     end for
     if l_seq = 999 then
        let l_return = l_valorInt clipped,l_return clipped
        let l_return = l_return using "&&&&&&&&&&&&&&&&&"
     else 
        if l_seq = 998 then
           let l_valorDec = l_return clipped
           let l_valorInt2 = l_valorInt clipped
           let l_return = "*",l_valorInt2 using "&&&&&&&&&","*",l_valorDec using "&&","*"
        else
           let l_valorDec = l_return clipped 
           let l_return = "*",l_valorInt using "&&&&&&&&&&&&&","*",l_valorDec using "&&","*"
        end if
     end if 
     display "l_return: ",l_return
     return l_return

 end function

#------------------------------#
 function bdbsr115_data(m_data)
#------------------------------#

     define m_data date,
            l_return char(08)

     let l_return = " "

     if  m_data is not null and m_data <> " " then
         let l_return = extend(m_data, year to year) clipped,
                        extend(m_data, month to month) clipped,
                        extend(m_data, day to day)
     else
         let l_return = extend(current, year to year) clipped,  
                        extend(current, month to month) clipped,
                        extend(current, day to day)             
     end if

     return l_return

 end function
 
 
#------------------------------#
 function bdbsr115_data_hora(m_data,m_hora)
#------------------------------#

     define m_data date,
            m_hora datetime hour to second,
            l_return char(14)

     let l_return = " "

     if  m_data is not null and m_data <> " " and 
         m_hora is not null and m_hora <> " " then
         let l_return = extend(m_data, day to day)clipped,
                        extend(m_data, month to month) clipped,
                        extend(m_data, year to year) clipped,
                        extend(m_hora, hour to hour) clipped,
                        extend(m_hora, minute to minute) clipped,
                        extend(m_hora,  second to second)
     else
        let l_return = extend(current, day to day)clipped,
                       extend(current, month to month) clipped,
                       extend(current, year to year) clipped,
                       extend(current, hour to hour) clipped,
                       extend(current, minute to minute) clipped,
                       extend(current, second to second)   
     end if

     return l_return

 end function

#------------------------------#
 function bdbsr115_valida_data(l_data,l_atdsrvnum,l_atdsrvano,l_desc)
#------------------------------#

     define l_data      date,
            l_atdsrvnum like datmservico.atdsrvnum,
            l_atdsrvano like datmservico.atdsrvano,
            l_desc      char(50)

     if  l_data is not null and l_data <> " " then
         if l_data < today - 1 units year or 
            l_data > today + 1 units year then
               let m_texto = "Data(",l_desc clipped,") invalida:",l_data," do servico: ",l_atdsrvnum,'-',l_atdsrvano
               output to report bdbsr115_resumo(m_texto clipped)  
               return false    
         end if 
     else
        let m_texto = "Data(",l_desc clipped,") em branco do servico: ",l_atdsrvnum,'-',l_atdsrvano
        output to report bdbsr115_resumo(m_texto clipped)    
        return false  
     end if

     return true

 end function
 
#--------------------------------------------------------------------------
report bdbsr115_resumo(l_linha)
#--------------------------------------------------------------------------
  define l_linha char(400)

  output
     left margin     0
     bottom margin   0
     top margin      0
     right margin  125
     page length    60

  format
     on every row
        print column 1, l_linha clipped

end report

#--------------------------------------------------------------------------
function bdbsr115_assitencia(param)
#--------------------------------------------------------------------------
  
  define param record
     asitipcod  like datmservico.asitipcod,
     atdsrvorg  like datmservico.atdsrvorg,
     atdsrvnum  like datmservico.atdsrvnum,
     atdsrvano  like datmservico.atdsrvano
  end record  
  
  define l_asitipdes   like datkasitip.asitipdes,
         l_socntzcod   like datksocntz.socntzcod,
         l_socntzdes   like datksocntz.socntzdes, 
         l_assistencia char(30),
         l_codigo      integer 
  
    
  let l_assistencia = null
    
  #--------------------------------------------------------------- 
 # buscar tipo de assistencia
 #--------------------------------------------------------------- 
 if param.asitipcod is null or
    param.asitipcod <= 0
    then
    #--------------------------------------------------------------- 
    # origem 8 forcado porque asitipcod nao e gravado no servico
    #--------------------------------------------------------------- 
    if param.atdsrvorg = 8
       then
       let l_asitipdes = 'LOCACAO DE VEICULO'
       let l_assistencia = l_asitipdes
       let l_codigo = 26
    end if 
 else
    whenever error continue
    open c_datkasitip_sel using param.asitipcod
    fetch c_datkasitip_sel into l_asitipdes
    whenever error stop
    
    let l_assistencia = l_asitipdes    
    let l_codigo = param.asitipcod
 end if
 
 if param.atdsrvorg = 9 or param.atdsrvorg = 13 then
    
    open cbdbsr115018 using param.atdsrvnum,param.atdsrvano
    fetch cbdbsr115018 into l_socntzcod,
                            l_socntzdes  
    
    let l_assistencia = l_socntzdes  
    let l_codigo = l_socntzcod
                
 end if  
  
  let l_assistencia = ctx14g00_TiraAcentos(l_assistencia)
  
  return l_assistencia,
         l_codigo     
         
end function

#--------------------------------------------------------------------------
function bdbsr115_data_servico(param)
#--------------------------------------------------------------------------
  
  define param record
     atdsrvnum    like datmservico.atdsrvnum,
     atdsrvano    like datmservico.atdsrvano,
     atddat       like datmservico.atddat,   
     atdhor       like datmservico.atdhor,   
     atddatprg    like datmservico.atddatprg,
     atdhorprg    like datmservico.atdhorprg,
     socemsnfsdat like dbsmopg.socemsnfsdat, 
     socfatpgtdat like dbsmopg.socfatpgtdat,
     cnldat       like datmservico.cnldat,
     atdfnlhor    like datmservico.atdfnlhor
  end record  
  
  define l_data_valida     smallint,
         l_dataEmissao     char(008),                          
         l_dataVencimento  char(008),
         l_dataPagamento   char(008),                       
         l_dataLigacao     char(014),                          
         l_dataPrestacao   char(014),
         l_dataAcionamento char(014), 
         l_atdetpdat       like datmsrvacp.atdetpdat,
         l_atdetphor       like datmsrvacp.atdetphor,
         l_ligdat          like datmligacao.ligdat,                            
         l_lighorinc       like datmligacao.lighorinc
  
  #--------------------------------------------------------------- 
  # Verifica a data da ligacao
  #--------------------------------------------------------------- 
  whenever error continue
     open cbdbsr115021 using param.atdsrvnum,param.atdsrvano
     fetch cbdbsr115021 into l_ligdat,l_lighorinc
  whenever error stop 
           
    
  #---------------------------------------------------------------   
  # Verifica se a data da ligacao eh valida para envia para o itau
  #---------------------------------------------------------------  
  let l_data_valida =  bdbsr115_valida_data(l_ligdat,
                                            param.atdsrvnum,
                                            param.atdsrvano,"Ligacao") 
  
  if l_data_valida then
     let l_dataLigacao = bdbsr115_data_hora(l_ligdat,l_lighorinc)    
  else
     let l_dataLigacao = bdbsr115_data_hora(" "," ")
  end if 
  
  let l_data_valida = false
  
  #--------------------------------------------------------------- 
  # buscar data de acionamento do servico
  #--------------------------------------------------------------- 
  whenever error continue
  open c_srvacp_sel using param.atdsrvnum,
                          param.atdsrvano
  fetch c_srvacp_sel into l_atdetpdat,l_atdetphor
  whenever error stop
    
  #---------------------------------------------------------------   
  # Verifica se a data do acionamento eh valida para envia para o itau
  #--------------------------------------------------------------- 
  let l_data_valida =  bdbsr115_valida_data(l_atdetpdat,
                                            param.atdsrvnum,
                                            param.atdsrvano,"Acionamento F6") 
  if l_data_valida = false then
     #---------------------------------------------------------------   
     # Verifica se a data do acionamento eh valida para envia para o itau
     #--------------------------------------------------------------- 
     let l_data_valida =  bdbsr115_valida_data(param.cnldat,
                                               param.atdsrvnum,
                                               param.atdsrvano,"Acionamento F9") 
     if l_data_valida then
        let l_dataAcionamento =  bdbsr115_data_hora(param.cnldat,param.atdfnlhor)
     else
        let l_dataAcionamento = bdbsr115_data_hora(" "," ")  
     end if 
  else
     let l_dataAcionamento = bdbsr115_data_hora(l_atdetpdat,l_atdetphor)
  end if 
   
  let l_data_valida = false
  
  
  #---------------------------------------------------------------   
  # Verifica se a data da prestacao do servico eh valida para envia para o itau
  #--------------------------------------------------------------- 
  if param.atddatprg is null or param.atddatprg = ' ' then
     let l_data_valida =  bdbsr115_valida_data(param.atddat,
                                            param.atdsrvnum,
                                            param.atdsrvano,"Programada") 
     if l_data_valida then
        let l_dataPrestacao   = bdbsr115_data_hora(param.atddat,param.atdhor) 
     else
        let l_dataPrestacao = bdbsr115_data_hora(" "," ")
     end if 
  else
     let l_data_valida =  bdbsr115_valida_data(param.atddatprg,
                                            param.atdsrvnum,
                                            param.atdsrvano,"Atendimento") 
     if l_data_valida then                                                                           
        let l_dataPrestacao   = bdbsr115_data_hora(param.atddatprg,param.atdhorprg)
     else                                                                                        
        let l_dataPrestacao = bdbsr115_data_hora(" "," ")                                                 
     end if                                                                                      
  end if   
  
  #---------------------------------------------------------------   
  # Verifica se a data da Emissao da nota eh valida para envia para o itau
  #---------------------------------------------------------------  
  let l_data_valida =  bdbsr115_valida_data(param.socemsnfsdat,
                                            param.atdsrvnum,
                                            param.atdsrvano,"Nota Fiscal") 
  
  if l_data_valida then
     let l_dataEmissao = bdbsr115_data(param.socemsnfsdat) 
  else
     let l_dataEmissao = bdbsr115_data(" ")
  end if 
  
  let l_data_valida = false
  
  #---------------------------------------------------------------   
  # Verifica se a data da do pagamento e vencimento do documento eh valida para envia para o itau
  #---------------------------------------------------------------  
  let l_data_valida =  bdbsr115_valida_data(param.socfatpgtdat,
                                            param.atdsrvnum,
                                            param.atdsrvano,"Pagamento") 
  
  if l_data_valida then
     let l_dataVencimento = bdbsr115_data(param.socfatpgtdat)
     let l_dataPagamento  = bdbsr115_data(param.socfatpgtdat) 
  else
     let l_dataVencimento = "        "
     let l_dataPagamento  = "        "
  end if 
  
  
  return l_dataLigacao   ,
         l_dataAcionamento,
         l_dataPrestacao ,
         l_dataEmissao   ,
         l_dataVencimento,
         l_dataPagamento 

end function
 

