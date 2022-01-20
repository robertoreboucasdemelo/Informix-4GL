#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema..: Porto Socorro                                                     #
# Modulo...: ctb11m20                                                          #
# Objetivo.: Validacao de regra tributaria para emissao de OP e obter dados    #
#            tributarios para OP Azul Seguros                                  #
#                                                                              #
# Analista.: Fabio Costa                                                       #
# PSI      : 198404 - People                                                   #
# Liberacao: 11/02/2010                                                        #
#..............................................................................#
# Observacoes:                                                                 #
# Regras nao foram feitas no People, sob a alegacao de que se OPs Azul nao     #
# sao pagas na Porto, as regras devem estar na area de negocio.                #
#..............................................................................#
# Alteracoes                                                                   #
# 04/03/2010  PSI198404  Fabio Costa  Não permitir cod. cidade nulo na chamada #
#                                     a dados de tributos, tratar retorno de   #
#                                     flags tributacao                         #
#------------------------------------------------------------------------------#
database porto

define m_ctb11m20_prep smallint

define m_opgfav record
       socopgfavnom  like dbsmopgfav.socopgfavnom ,
       cgccpfnum     like dbsmopgfav.cgccpfnum    ,
       cgcord        like dbsmopgfav.cgcord       ,
       cgccpfdig     like dbsmopgfav.cgccpfdig    ,
       pestip        like dbsmopgfav.pestip       ,
       bcocod        like dbsmopgfav.bcocod       ,
       bcoagnnum     like dbsmopgfav.bcoagnnum    ,
       bcoagndig     like dbsmopgfav.bcoagndig    ,
       bcoctanum     like dbsmopgfav.bcoctanum    ,
       bcoctadig     like dbsmopgfav.bcoctadig    ,
       socpgtopccod  like dbsmopgfav.socpgtopccod
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

define m_opg_aux record
       favnom        like datklcvfav.favnom      ,
       endlgd        like dpaksocor.endlgd       ,
       lgdnum        like dpaksocor.lgdnum       ,
       endbrr        like dpaksocor.endbrr       ,
       mpacidcod     like dpaksocor.mpacidcod    ,
       endcep        like dpaksocor.endcep       ,
       endcepcmp     like datkavislocal.endcepcmp,
       maides        like dpaksocor.maides       ,
       muninsnum     like dpaksocor.muninsnum    ,
       cidnom        like glakcid.cidnom         ,
       ufdcod        like glakcid.ufdcod         ,
       dddcod        like datkavislocal.dddcod   ,
       teltxt        like datkavislocal.teltxt   ,
       pcpatvcod     like dpaksocor.pcpatvcod    ,
       pisnum        like dpaksocor.pisnum       ,
       corsus        like dbsmopg.corsus         ,
       prscootipcod  like dpaksocor.prscootipcod ,
       pstsuccod     like dpaksocor.succod       ,
       cpfcgctxt     char(015)                   ,
       cep           char(10) 
end record

#----------------------------------------------------------------
function ctb11m20_prepare()
#----------------------------------------------------------------

  define l_sql char(800)
  
  initialize m_ctb11m20_prep, l_sql to null
  
  let l_sql = "select a.succod, ",
              "       a.ramcod, ",
              "       a.aplnumdig, ",
              "       a.itmnumdig  ",
              " from dbsmopgitm i , outer datrservapol a, ",
              "      datmservico s ",
              "where i.atdsrvnum = a.atdsrvnum ",
              "  and i.atdsrvano = a.atdsrvano ",
              "  and i.atdsrvnum = s.atdsrvnum ",
              "  and i.atdsrvano = s.atdsrvano ",         
              "  and i.socopgnum = ? "             
  prepare p_aplitm_sel from l_sql
  declare c_aplitm_sel cursor with hold for p_aplitm_sel
  
   let l_sql = "select a.pstcoddig   , ",
               "       a.segnumdig   , ",
               "       a.lcvcod      , ",
               "       a.aviestcod   , ",
               "       a.succod      , ",
               "       a.soctip      , ",
               "       a.favtip      , ",
               "       b.socopgfavnom, ",
               "       b.cgccpfnum   , ",
               "       b.cgcord      , ",
               "       b.cgccpfdig   , ",
               "       b.pestip      , ",
               "       b.bcocod      , ",
               "       b.bcoagnnum   , ",
               "       b.bcoagndig   , ",
               "       b.bcoctanum   , ",
               "       b.bcoctadig   , ",
               "       b.socpgtopccod  ",
               "  from dbsmopg a,      ",
               "       dbsmopgfav b    ",
               " where a.socopgnum = b.socopgnum ",
               "   and a.socopgnum = ?" 
  prepare p_ctb11m20_001 from l_sql                        
  declare c_ctb11m20_001 cursor with hold for p_ctb11m20_001 
  
  
  # busca apólice Itau
  let l_sql = "select itaciacod   , ",
              "       itaramcod   , ",
              "       itaaplnum   , ",
              "       aplseqnum   , ",  
              "       seglgdnom   , ",
              "       segendcmpdes, ",
              "       seglgdnum   , ",         
              "       segbrrnom   , ",         
              "       segufdsgl   , ",         
              "       segcidnom   , ",         
              "       segcepnum   , ",
              "       segcepcmpnum, ",
              "       segmaiend    ", 
              "  from datmitaapl a  ",                                      
              " where a.segcgccpfnum = ?  ",                                
              "   and a.segcgcordnum = ?  ",                                
              "   and a.segcgccpfdig = ?  ",                                
              "   and aplseqnum = (select max(b.aplseqnum) ",               
              "                      from datmitaapl b ",                   
              "                      where a.itaciacod = b.itaciacod    ",  
              "                        and   a.itaramcod = b.itaramcod  ",  
              "                        and   a.itaaplnum = b.itaaplnum) ",  
              "  order by segnom"                                           
  prepare p_ctb11m20_002  from l_sql                                        
  declare c_ctb11m20_002  cursor for p_ctb11m20_002                         
  
   
  let m_ctb11m20_prep = true
  
end function

#----------------------------------------------------------------
function ctb11m20(l_nivel_retorno, l_socopgnum, l_tipochamada)
#----------------------------------------------------------------

  define l_res            integer
       , l_msg            char(80)
       , l_socopgnum      like dbsmopg.socopgnum
       , l_nivel_retorno  smallint
       , l_tipochamada    char(01)
       
  if l_nivel_retorno is null or l_nivel_retorno <= 0
     then
     return 999, 'Erro na chamada CTB11M20, nivel retorno'
  end if
  
  call ctb11m20_regra(l_socopgnum, l_tipochamada)
       returning l_res, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
  
  if l_nivel_retorno = 1
     then
     return l_res, l_msg
  end if
  
  if l_nivel_retorno = 2
     then
     return l_res, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
  end if
  
end function


#----------------------------------------------------------------
function ctb11m20_regra(l_socopgnum, l_tipochamada)
#----------------------------------------------------------------
  
  define l_socopgnum like dbsmopg.socopgnum
       , l_tipochamada    char(01)
  
  define l_dbsmopg record
         pstcoddig     like dbsmopg.pstcoddig ,
         segnumdig     like dbsmopg.segnumdig ,
         lcvcod        like dbsmopg.lcvcod    ,
         aviestcod     like dbsmopg.aviestcod ,
         succod        like dbsmopg.succod    ,
         soctip        like dbsmopg.soctip
  end record
  
  define l_aplitm record
         succod        like datrservapol.succod    ,
         ramcod        like datrservapol.ramcod    ,
         aplnumdig     like datrservapol.aplnumdig ,
         itmnumdig     like datkazlapl.itmnumdig   ,
         azlaplcod     like datkazlapl.itmnumdig
  end record
  
  define l_cty10g00_out record
         res     smallint,
         msg     char(40),
         endufd  like gabksuc.endufd,
         endcid  like gabksuc.endcid,
         cidcod  like gabksuc.cidcod
  end record
  
  define l_cts54g00 record
         errcod        smallint ,
         errdes        char(80) ,
         tpfornec      char(3)  ,
         retencod      like fpgkplprtcinf.ppsretcod ,
         socitmtrbflg  char(1)  ,
         retendes      char(50)
  end record

  define l_ctb00g14 record
         titulo   char(60),
         linha01  char(60),
         linha02  char(60),
         linha03  char(60),
         linha04  char(60),
         linha05  char(60),
         linha06  char(60),
         linha07  char(60),
         linha08  char(60),
         linha09  char(60)
  end record
  
  define l_arr_msg array[100] of char(80) 
  
  define l_msg  char(80)
  
  define l_res         integer
       , l_doc_handle  integer
       , l_pro         char(1)
       , l_ct          smallint
       , l_favtip      smallint
       
  initialize l_dbsmopg.*, l_aplitm.*, l_ctb00g14.* to null
  initialize m_opgfav.* to null
  initialize m_ffpgc346.* to null
  initialize m_opg_aux.* to null
  initialize l_res, l_msg, l_doc_handle, l_ct, l_favtip to null
  initialize l_arr_msg to null
  
  if m_ctb11m20_prep is null or
     m_ctb11m20_prep != true 
     then
     call ctb11m20_prepare()
  end if
  
  let l_favtip = 0
  
  # dados da OP
  call ctd20g00_sel_opg_chave(2, l_socopgnum)
       returning l_res, l_msg ,
                 l_dbsmopg.pstcoddig,
                 l_dbsmopg.segnumdig,
                 l_dbsmopg.lcvcod   ,
                 l_dbsmopg.aviestcod,
                 l_dbsmopg.succod   ,
                 l_dbsmopg.soctip   

  if l_res != 0 or l_res is null
     then
     display 'Erro na selecao da OP:'
     display 'OP: ', l_socopgnum
     let l_msg = "Erro na selecao da OP: ", l_res
     return l_res, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
  end if
  
  # dados favorecido da OP
  call ctd20g04_dados_favop(1, l_socopgnum)
       returning l_res, l_msg         ,
                 m_opgfav.socopgfavnom,
                 m_opgfav.cgccpfnum   ,
                 m_opgfav.cgcord      ,
                 m_opgfav.cgccpfdig   ,
                 m_opgfav.pestip      ,
                 m_opgfav.bcocod      ,
                 m_opgfav.bcoagnnum   ,
                 m_opgfav.bcoagndig   ,
                 m_opgfav.bcoctanum   ,
                 m_opgfav.bcoctadig   ,
                 m_opgfav.socpgtopccod

  if l_res != 0 or l_res is null
     then
     display 'Favorecido nao identificado:'
     display 'OP: ', l_socopgnum
     let l_msg = "Favorecido nao identificado[1]"
     return l_res, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
  end if
  
  if l_dbsmopg.pstcoddig is null and 
     l_dbsmopg.segnumdig is null and
     l_dbsmopg.lcvcod is null
     then
     display 'Favorecido nao identificado:'
     display 'OP: ', l_socopgnum
     display 'l_dbsmopg.pstcoddig: ', l_dbsmopg.pstcoddig
     display 'l_dbsmopg.segnumdig: ', l_dbsmopg.segnumdig
     display 'l_dbsmopg.lcvcod   : ', l_dbsmopg.lcvcod  
     let l_msg = "Favorecido nao identificado, verifique cadastro"
     return 999, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
  end if
  
  if m_opgfav.pestip != 0 or m_opgfav.pestip is null
     then
     display 'm_opgfav.pestip: ', m_opgfav.pestip
     display 'OP: ', l_socopgnum
     let l_msg = "Tipo da pessoa nao identificado"
     return 999, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
  end if
  
  # reembolso
  if (l_dbsmopg.pstcoddig = 3 or l_dbsmopg.lcvcod = 33) or
      l_dbsmopg.segnumdig is not null
     then
     
     let l_favtip = 3  # Segurado
     
     # para buscar codigo de retencao o segnumdig nao pode ser nulo
     # para reembolso
     if l_dbsmopg.segnumdig is null
        then
        let l_dbsmopg.segnumdig = 1
     end if
     
     let m_opg_aux.pstsuccod = l_dbsmopg.succod
     
     whenever error continue
     open c_aplitm_sel using l_socopgnum
     fetch c_aplitm_sel into l_aplitm.succod   , l_aplitm.ramcod   ,
                             l_aplitm.aplnumdig, l_aplitm.itmnumdig
     whenever error stop
     
     let l_res = sqlca.sqlcode
     
     close c_aplitm_sel
     
     if l_res != 0 or l_res is null
        then
        display 'Erro na selecao da apolice:'
        display 'OP: ', l_socopgnum
        let l_msg = "Erro na selecao da apólice para reembolso "
        return l_res, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
     end if
     
     call ctd02g01_azlaplcod(l_aplitm.succod   , l_aplitm.ramcod,
                             l_aplitm.aplnumdig, l_aplitm.itmnumdig, "")
          returning l_res, l_msg, l_aplitm.azlaplcod
     
     if l_res != 1 or l_res is null
        then
        display 'Erro na selecao da apolice Azul: '
        display 'l_aplitm.succod   : ', l_aplitm.succod   
        display 'l_aplitm.ramcod   : ', l_aplitm.ramcod   
        display 'l_aplitm.aplnumdig: ', l_aplitm.aplnumdig
        display 'l_aplitm.itmnumdig: ', l_aplitm.itmnumdig
        let l_msg = "Erro na selecao da apolice Azul Seguros para reembolso "
        return l_res, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
     end if
     
     call figrc011_inicio_parse()
     
     let l_doc_handle = ctd02g00_agrupaXML(l_aplitm.azlaplcod)
     
     let m_opg_aux.endlgd = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/LOGRADOURO")
     let m_opg_aux.lgdnum = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/NUMERO")
     let m_opg_aux.endbrr = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/BAIRRO")
     let m_opg_aux.ufdcod = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/UF")
     let m_opg_aux.cidnom = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/CIDADE")
     let m_opg_aux.endcep = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/CEP")
     let m_opg_aux.maides = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/EMAIL")
     
     call figrc011_fim_parse()
     
     call cty10g00_obter_cidcod(m_opg_aux.cidnom, m_opg_aux.ufdcod)
          returning l_res, l_msg, m_opg_aux.mpacidcod
          
     if l_res != 0 or l_res is null or
        m_opg_aux.mpacidcod is null
        then
        display 'Cidade sede do segurado nao identificada, considerando padrao Sao Paulo'
        display 'm_opg_aux.endlgd: ', m_opg_aux.endlgd
        display 'm_opg_aux.lgdnum: ', m_opg_aux.lgdnum
        display 'm_opg_aux.endbrr: ', m_opg_aux.endbrr
        display 'm_opg_aux.ufdcod: ', m_opg_aux.ufdcod
        display 'm_opg_aux.cidnom: ', m_opg_aux.cidnom
        let m_opg_aux.mpacidcod = 9668
     end if
     
  else
     
     if l_dbsmopg.soctip = 2     # CARRO EXTRA BUSCA LOCADORA
        then
        
        let l_favtip = 4  # Locadora
        
        call ctd19g00_ender_fav_loja(l_dbsmopg.lcvcod, l_dbsmopg.aviestcod)
             returning l_res,
                       m_opg_aux.favnom   ,
                       m_opg_aux.endlgd   ,
                       m_opg_aux.endbrr   ,
                       m_opg_aux.endcep   ,
                       m_opg_aux.endcepcmp,
                       m_opg_aux.cidnom   ,
                       m_opg_aux.ufdcod   ,
                       m_opg_aux.dddcod   ,
                       m_opg_aux.teltxt   ,
                       m_opg_aux.maides   ,
                       m_opg_aux.muninsnum,
                       m_opg_aux.pstsuccod 
        
        if l_res != 0 or l_res is null
           then
           let l_msg = "Erro na selecao de dados da locadora: ", l_res
           return 999, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
        end if
        
        let m_opg_aux.lgdnum = 0
        
        call cty10g00_obter_cidcod(m_opg_aux.cidnom, m_opg_aux.ufdcod)
             returning l_res, l_msg, m_opg_aux.mpacidcod
              
        if l_res != 0 or l_res is null or 
           m_opg_aux.mpacidcod is null
           then
           display 'Cidade sede do segurado nao identificada:'
           display 'm_opg_aux.endlgd: ', m_opg_aux.endlgd
           display 'm_opg_aux.lgdnum: ', m_opg_aux.lgdnum
           display 'm_opg_aux.endbrr: ', m_opg_aux.endbrr
           display 'm_opg_aux.ufdcod: ', m_opg_aux.ufdcod
           display 'm_opg_aux.cidnom: ', m_opg_aux.cidnom
           let l_msg = "Cidade sede da locadora nao identificada"
           return l_res, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
        end if
        
     else    # DADOS PRESTADOR
     
        let l_favtip = 1  # Prestador
        
        call ctd12g00_dados_pst2(6, l_dbsmopg.pstcoddig)
             returning l_res, l_msg,
                       m_opg_aux.endlgd   , m_opg_aux.lgdnum   ,
                       m_opg_aux.endbrr   , m_opg_aux.mpacidcod,
                       m_opg_aux.endcep   , m_opg_aux.maides   ,
                       m_opg_aux.muninsnum, m_opg_aux.pcpatvcod,
                       m_opg_aux.pisnum   , m_opg_aux.pstsuccod,
                       m_opg_aux.cidnom   , m_opg_aux.ufdcod
                       
        if l_res != 0 or l_res is null or 
           m_opg_aux.mpacidcod is null
           then
           display 'Cidade sede do segurado nao identificada:'
           display 'm_opg_aux.endlgd: ', m_opg_aux.endlgd
           display 'm_opg_aux.lgdnum: ', m_opg_aux.lgdnum
           display 'm_opg_aux.endbrr: ', m_opg_aux.endbrr
           display 'm_opg_aux.ufdcod: ', m_opg_aux.ufdcod
           display 'm_opg_aux.cidnom: ', m_opg_aux.cidnom
           let l_msg = "Cidade sede do prestador nao identificada"
           return l_res, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
        end if
     end if
     
  end if
  
  # obter cidade ligada a sucursal do fornecedor (tributacao)
  initialize l_cty10g00_out.* to null
  
  let l_arr_msg[01] = '######################################################################'
  let l_arr_msg[02] = '##################  INICIO DE LOG DE ERRO  ###########################'
  let l_arr_msg[03] = '######################################################################'
  let l_arr_msg[04] = ''
  let l_arr_msg[05] = 'Verificacao de dados tributarios para OPs Azul Seguros'
  let l_arr_msg[06] = 'Dados do favorecido: '
  let l_arr_msg[07] = 'Sucursal..: ', m_opg_aux.pstsuccod
  let l_arr_msg[08] = 'Cidade:...: ', m_opg_aux.cidnom
  let l_arr_msg[09] = 'UF........: ', m_opg_aux.ufdcod
  
  # buscar sucursal da OP ligada ao prestador
  if m_opg_aux.pstsuccod is not null
     then
     call cty10g00_dados_sucursal(1, m_opg_aux.pstsuccod)
     returning l_cty10g00_out.res   ,
               l_cty10g00_out.msg   ,
               l_cty10g00_out.endufd,
               l_cty10g00_out.endcid,
               l_cty10g00_out.cidcod
  end if
  
  if l_cty10g00_out.cidcod is null or
     l_cty10g00_out.cidcod <= 0
     then
     call cty10g00_obter_cidcod(l_cty10g00_out.endcid, l_cty10g00_out.endufd)
          returning l_cty10g00_out.res,
                    l_cty10g00_out.msg,
                    l_cty10g00_out.cidcod
  end if

  # buscar descricao da atividade principal
  #----------------------------------------------------------------
  initialize l_cts54g00.* to null
  
  call cts54g00_inftrb(35,
                       l_dbsmopg.pstcoddig,
                       l_dbsmopg.soctip,
                       l_dbsmopg.segnumdig,
                       m_opg_aux.corsus,
                       m_opgfav.pestip ,
                       m_opg_aux.prscootipcod,
                       m_opg_aux.pcpatvcod)
             returning l_cts54g00.errcod      ,
                       l_cts54g00.errdes      ,
                       l_cts54g00.tpfornec    ,
                       l_cts54g00.retencod    ,
                       l_cts54g00.socitmtrbflg,
                       l_cts54g00.retendes

  let l_arr_msg[10] = '------------------------------------------------------'
  let l_arr_msg[11] = "Retorno codigo de retencao: "
  let l_arr_msg[12] = 'Cod. erro..............: ', l_cts54g00.errcod
  let l_arr_msg[13] = 'Erro...................: ', l_cts54g00.errdes
  let l_arr_msg[14] = 'Tipo fornecedor........: ', l_cts54g00.tpfornec
  let l_arr_msg[15] = 'Cod. retencao People...: ', l_cts54g00.retencod
  let l_arr_msg[16] = 'Descr retencao.........: ', l_cts54g00.retendes
  let l_arr_msg[17] = 'Flag tributa...........: ', l_cts54g00.socitmtrbflg

  let l_res = 0
  
  if l_cts54g00.errcod != 0 or
     l_cts54g00.retencod is null or
     l_cts54g00.retendes is null
     then
     let l_res = 999
     let l_msg = 'Erro na consulta a codigo de retencao People: ', 
                 m_ffpgc346.errcod, ' | ', m_ffpgc346.errdes clipped
     let l_arr_msg[18] = l_msg clipped
  end if
  
  if (l_cty10g00_out.cidcod is null or l_cty10g00_out.cidcod <= 0) and 
     l_favtip != 3
     then
     let l_res = 999
     let l_msg = "Cidade de prestacao de servico nao identificada"
     return l_res, l_msg, m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
  end if
  
  # obter flag's de tributacao e codigos de arrecadacao da receita
  #----------------------------------------------------------------
  let l_arr_msg[19] = '------------------------------------------------------'
  let l_arr_msg[20] = 'Busca flag tributacao:parametros'
  let l_arr_msg[21] = 'Tipo pessoa............: ', m_opgfav.pestip
  let l_arr_msg[22] = 'Cod. retencao People...: ', l_cts54g00.retencod
  let l_arr_msg[23] = 'Descr retencao.........: ', l_cts54g00.retendes
  let l_arr_msg[24] = 'Cidade prestacao serv..: ', l_cty10g00_out.cidcod
  let l_arr_msg[25] = 'Cidade sede prestador..: ', m_opg_aux.mpacidcod
  
  call ffpgc346(35, 11, m_opgfav.pestip,
                l_cts54g00.retencod,
                l_cts54g00.retendes, 
                l_cty10g00_out.cidcod,
                m_opg_aux.mpacidcod)
      returning m_ffpgc346.empresa         ,
                m_ffpgc346.cmporgcod       ,
                m_ffpgc346.pestip          ,
                m_ffpgc346.ppsretcod       ,
                m_ffpgc346.atividade       ,
                m_ffpgc346.errcod          ,
                m_ffpgc346.errdes          ,
                m_ffpgc346.flagIR          ,
                m_ffpgc346.flagISS         ,
                m_ffpgc346.flagINSS        ,
                m_ffpgc346.flagPIS         ,
                m_ffpgc346.flagCOF         ,
                m_ffpgc346.flagCSLL        ,
                m_ffpgc346.arrecadacaoIR   ,
                m_ffpgc346.arrecadacaoISS  ,
                m_ffpgc346.arrecadacaoINSS ,
                m_ffpgc346.arrecadacaoPIS  ,
                m_ffpgc346.arrecadacaoCOFIN,
                m_ffpgc346.arrecadacaoCSLL

  let l_arr_msg[26] = '------------------------------------------------------'
  let l_arr_msg[27] = 'Busca flag tributacao:retorno'
  let l_arr_msg[28] = 'Empresa..............: ', m_ffpgc346.empresa
  let l_arr_msg[29] = 'Origem...............: ', m_ffpgc346.cmporgcod
  let l_arr_msg[30] = 'Tipo pessoa..........: ', m_ffpgc346.pestip
  let l_arr_msg[31] = 'Atividade............: ', m_ffpgc346.atividade
  let l_arr_msg[32] = 'Cod. erro............: ', m_ffpgc346.errcod
  let l_arr_msg[33] = 'Erro.................: ', m_ffpgc346.errdes
  let l_arr_msg[34] = 'Flag tributa IR......: ', m_ffpgc346.flagIR
  let l_arr_msg[35] = 'Flag tributa ISS.....: ', m_ffpgc346.flagISS
  let l_arr_msg[36] = 'Flag tributa INSS....: ', m_ffpgc346.flagINSS
  let l_arr_msg[37] = 'Flag tributa PIS.....: ', m_ffpgc346.flagPIS
  let l_arr_msg[38] = 'Flag tributa COF.....: ', m_ffpgc346.flagCOF
  let l_arr_msg[39] = 'Flag tributa CSLL....: ', m_ffpgc346.flagCSLL
  let l_arr_msg[40] = '------------------------------------------------------'
  let l_arr_msg[41] = 'Cod arrecadacao IR...: ', m_ffpgc346.arrecadacaoIR
  let l_arr_msg[42] = 'Cod arrecadacao ISS..: ', m_ffpgc346.arrecadacaoISS
  let l_arr_msg[43] = 'Cod arrecadacao INSS.: ', m_ffpgc346.arrecadacaoINSS
  let l_arr_msg[44] = 'Cod arrecadacao PIS..: ', m_ffpgc346.arrecadacaoPIS
  let l_arr_msg[45] = 'Cod arrecadacao COFIN: ', m_ffpgc346.arrecadacaoCOFIN
  let l_arr_msg[46] = 'Cod arrecadacao CSLL.: ', m_ffpgc346.arrecadacaoCSLL
  let l_arr_msg[47] = '------------------------------------------------------'
  
  if m_ffpgc346.errcod is null or m_ffpgc346.errcod != 0
     then
     let l_res = 999
     let l_msg = 'Erro na consulta a tributacao do favorecido: ', 
                 m_ffpgc346.errcod, ' | ', m_ffpgc346.errdes clipped
     let l_arr_msg[48] = l_msg clipped
  end if
  
  if m_ffpgc346.atividade is null
     then
     let l_res = 999
     let l_msg = 'Atividade nao identificada, entre em contato com tributos'
     let l_arr_msg[49] = l_msg clipped
  end if
  
  if m_ffpgc346.flagISS is null
     then
     let l_res = 999
     let l_msg = 'Tributacao ISS invalida, entre em contato com tributos'
     let l_arr_msg[50] = l_msg clipped
  else
     if m_ffpgc346.flagISS = "N"
        then
        let m_ffpgc346.arrecadacaoISS = null
     end if
  end if
  
  if m_ffpgc346.flagINSS is null
     then
     let l_res = 999
     let l_msg = 'Tributacao INSS invalida, entre em contato com tributos'
     let l_arr_msg[51] = l_msg clipped
  else
     if m_ffpgc346.flagINSS = "N"
        then
        let m_ffpgc346.arrecadacaoINSS = null
     end if
  end if
  
  if m_ffpgc346.flagPIS is null
     then
     let l_res = 999
     let l_msg = 'Tributacao PIS invalida, entre em contato com tributos'
     let l_arr_msg[52] = l_msg clipped
  else
     if m_ffpgc346.flagPIS = "N"
        then
        let m_ffpgc346.arrecadacaoPIS = null
     end if
  end if
  
  if m_ffpgc346.flagCOF is null
     then
     let l_res = 999
     let l_msg = 'Tributacao COFINS invalida, entre em contato com tributos'
     let l_arr_msg[53] = l_msg clipped
  else
     if m_ffpgc346.flagCOF = "N"
        then
        let m_ffpgc346.arrecadacaoCOFIN = null
     end if
  end if
  
  if m_ffpgc346.flagCSLL is null
     then
     let l_res = 999
     let l_msg = 'Tributacao CSLL invalida, entre em contato com tributos'
     let l_arr_msg[54] = l_msg clipped
  else
     if m_ffpgc346.flagCSLL = "N"
        then
        let m_ffpgc346.arrecadacaoCSLL = null
     end if
  end if
  
  if m_ffpgc346.flagIR is null
     then
     let l_res = 999
     let l_msg = 'Tributacao IR invalida, entre em contato com tributos'
     let l_arr_msg[55] = l_msg clipped
  else
     # regra de consistir flag = N, desconsidera cod arrecadacao. 05/03/10
     # if m_ffpgc346.flagIR = "N" and
     #    m_ffpgc346.arrecadacaoIR > 0
     #    then
     #    let l_res = 999
     #    let l_msg = 'Regra de tributacao IR divergente, não tributa IR mas possui codigo arrecadacao'
     #    let l_arr_msg[56] = l_msg clipped
     # end if
     if m_ffpgc346.flagIR = "S" and
        m_ffpgc346.arrecadacaoIR is null 
        then
        let l_res = 999
        let l_msg = 'Regra de tributacao IR divergente, tributa IR mas não possui codigo arrecadacao'
        let l_arr_msg[57] = l_msg clipped
     end if
     if m_ffpgc346.flagIR = "N"
        then
        let m_ffpgc346.arrecadacaoIR = null
     end if
  end if
  
  let l_arr_msg[58] = ''
  let l_arr_msg[59] = '######################################################################'
  let l_arr_msg[60] = '###################  FINAL DE LOG DE ERRO  ###########################'
  let l_arr_msg[61] = '######################################################################'
  let l_arr_msg[62] = ''
  
  # algum erro na consulta a tributos
  if l_res != 0
     then
     
     # se for online, mostra pop-up de aviso na tela
     if l_tipochamada = "o"
        then
        
        let l_msg = "ATENCAO!!!"
        let l_ctb00g14.titulo  = ctb11m20_centraliza(l_msg, 60)
        
        let l_msg = "Esta OP nao será emitida"
        let l_ctb00g14.linha01 = ctb11m20_centraliza(l_msg, 60)
        
        let l_msg = "Erro: falta cadastro no tributos"
        let l_ctb00g14.linha03 = ctb11m20_centraliza(l_msg, 60)
        
        let l_msg = "Entre em contato com a area de Tributos"
        let l_ctb00g14.linha06 = ctb11m20_centraliza(l_msg, 60)
        
        let l_msg = "Se necessário, consulte o log de erro na tela acima"
        let l_ctb00g14.linha08 = ctb11m20_centraliza(l_msg, 60)
   
        let int_flag = false
        
        open window w_ctb00g14 at 10,11 with form "ctb00g14"
             attribute(form line 1, border)
             
        let l_pro = null
        
        whenever error continue
        while true
        
           # mostrar displays armazenados
           let l_ct = 1
           
           for l_ct = 1 to 100
              if l_arr_msg[l_ct] is not null
                 then
                 display l_arr_msg[l_ct] clipped
              end if
           end for
           
           display by name l_ctb00g14.titulo  attribute(reverse)
           display by name l_ctb00g14.linha01
           display by name l_ctb00g14.linha03
           display by name l_ctb00g14.linha06
           display by name l_ctb00g14.linha08
           
           error 'Erro na validacao tributos Azul. Lista de erros na tela acima'
           
           prompt "<Enter> ou <CTRL + C> para sair" for l_pro
              on key(interrupt, return)
                 exit while
           end prompt
           
           if int_flag then
              exit while
           end if
           
        end while
        whenever error stop
        
        initialize l_ctb00g14.* to null
        let int_flag = false
        close window w_ctb00g14
        
     end if
     
     return l_res, '', m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
     
  else
  
     return 0, '', m_opgfav.*, m_ffpgc346.*, m_opg_aux.*
     
  end if
  
end function

#----------------------------------------------------------------
function ctb11m20_centraliza(l_char, l_tam)
#----------------------------------------------------------------

   define l_char  char(80)
        , l_len   smallint
        , l_tam   smallint
        , l_ctt   smallint
        , l_spc   smallint
   
   let l_len = 0
   let l_spc = 0
   let l_ctt = 1

   let l_char = l_char clipped
   
   let l_len = length(l_char)
   
   if (l_len mod 2) != 0
      then
      let l_len = l_len + 1
   end if
   
   let l_spc = (l_tam - l_len) / 2
   
   for l_ctt = 1 to l_spc
      let l_char = " ", l_char
   end for
   
   return l_char

end function

#----------------------------------------------------------------
function ctb11m20_valida_optante_simples()
#----------------------------------------------------------------

  display 'Funcao ctb11m20_valida_optante_simples nao implementada ainda '
  
  # validar favorecido conforme regra do simples e tratar dados de m_ffpgc346
  
end function


#----------------------------------------------------------------
function ctb11m20_valida_tributos(param)
#----------------------------------------------------------------

  define param record
      socopgnum   like dbsmopg.socopgnum,
      ciaempcod   like datmservico.ciaempcod,
      cmporgcod   smallint,
      tipochamada char(01)  
  end record
  
  define l_dbsmopg record
         pstcoddig     like dbsmopg.pstcoddig ,
         segnumdig     like dbsmopg.segnumdig ,
         lcvcod        like dbsmopg.lcvcod    ,
         aviestcod     like dbsmopg.aviestcod ,
         succod        like dbsmopg.succod    ,
         soctip        like dbsmopg.soctip    ,
         favtip        like dbsmopg.favtip    ,
         endlgd        like dpaksocor.endlgd       ,  
         lgdnum        like dpaksocor.lgdnum       ,  
         endbrr        like dpaksocor.endbrr       ,  
         mpacidcod     like dpaksocor.mpacidcod    ,  
         endcep        like dpaksocor.endcep       ,  
         endcepcmp     like datkavislocal.endcepcmp,  
         maides        like dpaksocor.maides       ,  
         muninsnum     like dpaksocor.muninsnum    ,  
         cidnom        like glakcid.cidnom         ,  
         ufdcod        like glakcid.ufdcod         ,  
         dddcod        like datkavislocal.dddcod   ,  
         teltxt        like datkavislocal.teltxt   ,  
         pcpatvcod     like dpaksocor.pcpatvcod    ,  
         pisnum        like dpaksocor.pisnum       ,  
         corsus        like dbsmopg.corsus         ,  
         prscootipcod  like dpaksocor.prscootipcod ,  
         pstsuccod     like dpaksocor.succod       
  end record
  
  define l_opgfav record
         socopgfavnom  like dbsmopgfav.socopgfavnom ,
         cgccpfnum     like dbsmopgfav.cgccpfnum    ,
         cgcord        like dbsmopgfav.cgcord       ,
         cgccpfdig     like dbsmopgfav.cgccpfdig    ,
         pestip        like dbsmopgfav.pestip       ,
         bcocod        like dbsmopgfav.bcocod       ,
         bcoagnnum     like dbsmopgfav.bcoagnnum    ,
         bcoagndig     like dbsmopgfav.bcoagndig    ,
         bcoctanum     like dbsmopgfav.bcoctanum    ,
         bcoctadig     like dbsmopgfav.bcoctadig    ,
         socpgtopccod  like dbsmopgfav.socpgtopccod 
  end record
  
  define lr_segurado record
      itaciacod     like datmitaapl.itaciacod    ,  
      itaramcod     like datmitaapl.itaramcod    ,
      itaaplnum     like datmitaapl.itaaplnum    ,
      aplseqnum     like datmitaapl.aplseqnum    ,
      seglgdnom     like datmitaapl.seglgdnom    ,
      segendcmpdes  like datmitaapl.segendcmpdes ,
      seglgdnum     like datmitaapl.seglgdnum    ,
      segbrrnom     like datmitaapl.segbrrnom    ,
      segufdsgl     like datmitaapl.segufdsgl    ,
      segcidnom     like datmitaapl.segcidnom    ,
      segcepnum     like datmitaapl.segcepnum    ,
      segcepcmpnum  like datmitaapl.segcepcmpnum ,
      segmaiend     like datmitaapl.segmaiend    
  end record
  
  define l_cty10g00_out record
         res     smallint,
         msg     char(40),
         endufd  like gabksuc.endufd,
         endcid  like gabksuc.endcid,
         cidcod  like gabksuc.cidcod
  end record
  
  
   define l_coderr integer  
       , l_msg    char(80)    
  
   initialize l_dbsmopg.* to null
   initialize l_opgfav.* to null
   initialize lr_segurado.* to null
   initialize l_cty10g00_out.* to null
  
  
  if m_ctb11m20_prep is null or
     m_ctb11m20_prep != true 
     then
     call ctb11m20_prepare()
  end if
  
  open c_ctb11m20_001 using param.socopgnum
  fetch c_ctb11m20_001 into l_dbsmopg.pstcoddig  ,
                            l_dbsmopg.segnumdig  , 
                            l_dbsmopg.lcvcod     ,
                            l_dbsmopg.aviestcod  ,
                            l_dbsmopg.succod     ,
                            l_dbsmopg.soctip     ,
                            l_dbsmopg.favtip     ,
                            l_opgfav.socopgfavnom,
                            l_opgfav.cgccpfnum   ,
                            l_opgfav.cgcord      ,
                            l_opgfav.cgccpfdig   ,
                            l_opgfav.pestip      ,
                            l_opgfav.bcocod      ,
                            l_opgfav.bcoagnnum   ,
                            l_opgfav.bcoagndig   ,
                            l_opgfav.bcoctanum   ,
                            l_opgfav.bcoctadig   ,
                            l_opgfav.socpgtopccod
  
   
  if l_dbsmopg.pstcoddig is null and 
     l_dbsmopg.segnumdig is null and
     l_dbsmopg.lcvcod is null
     then
     display 'Favorecido nao identificado:'
     display 'OP: ', param.socopgnum
     display 'l_dbsmopg.pstcoddig: ', l_dbsmopg.pstcoddig
     display 'l_dbsmopg.segnumdig: ', l_dbsmopg.segnumdig
     display 'l_dbsmopg.lcvcod   : ', l_dbsmopg.lcvcod  
     let l_msg = "Favorecido nao identificado, verifique cadastro"
     return 999, l_msg
  end if
  
  if l_opgfav.pestip != 0 or l_opgfav.pestip is null
     then
     display 'l_opgfav.pestip: ', l_opgfav.pestip
     display 'OP: ', param.socopgnum
     let l_msg = "Tipo da pessoa nao identificado"
     return 999, l_msg
  end if
  
  
  if (l_dbsmopg.pstcoddig = 3 or l_dbsmopg.lcvcod = 33) or   
     l_dbsmopg.segnumdig is not null    then
      let l_dbsmopg.favtip = 3
  else
     if l_dbsmopg.soctip = 2 then
        let l_dbsmopg.favtip = 4
     else
        let  l_dbsmopg.favtip = 1  
     end if 
  end if 
  
  case l_dbsmopg.favtip 
     when 3
        if param.ciaempcod = 84 then
           call ctb11m20_seg_itau(l_opgfav.cgccpfnum,
                                  l_opgfav.cgcord,
                                  l_opgfav.cgccpfdig)
                returning lr_segurado.itaciacod   ,  
                          lr_segurado.itaramcod   ,
                          lr_segurado.itaaplnum   ,
                          lr_segurado.aplseqnum   ,
                          lr_segurado.seglgdnom   ,
                          lr_segurado.segendcmpdes,
                          lr_segurado.seglgdnum   ,
                          lr_segurado.segbrrnom   ,
                          lr_segurado.segufdsgl   ,
                          lr_segurado.segcidnom   ,
                          lr_segurado.segcepnum   ,
                          lr_segurado.segcepcmpnum,
                          lr_segurado.segmaiend   ,
                          l_coderr                ,
                          l_msg     
           if l_dbsmopg.segnumdig is null
              then
              let l_dbsmopg.segnumdig = 84848484
           end if
           
           call cty10g00_obter_cidcod(lr_segurado.segcidnom, lr_segurado.segufdsgl)
                returning l_coderr, l_msg, l_dbsmopg.mpacidcod
                
           if l_coderr != 0 or l_coderr is null or
              l_dbsmopg.mpacidcod is null
              then
              display 'Cidade sede do segurado nao identificada, considerando padrao Sao Paulo'
              display 'lr_segurado.seglgdnom: ', lr_segurado.seglgdnom
              display 'lr_segurado.seglgdnum: ', lr_segurado.seglgdnum
              display 'lr_segurado.segbrrnom: ', lr_segurado.segbrrnom
              display 'lr_segurado.segufdsgl: ', lr_segurado.segufdsgl
              display 'lr_segurado.segcidnom: ', lr_segurado.segcidnom
              let l_dbsmopg.mpacidcod = 9668
           end if
        end if 
     when 4
           call ctd19g00_ender_fav_loja(l_dbsmopg.lcvcod, l_dbsmopg.aviestcod)
                  returning l_coderr,
                            l_opgfav.socopgfavnom   ,
                            l_dbsmopg.endlgd   ,
                            l_dbsmopg.endbrr   ,
                            l_dbsmopg.endcep   ,
                            l_dbsmopg.endcepcmp,
                            l_dbsmopg.cidnom   ,
                            l_dbsmopg.ufdcod   ,
                            l_dbsmopg.dddcod   ,
                            l_dbsmopg.teltxt   ,
                            l_dbsmopg.maides   ,
                            l_dbsmopg.muninsnum,
                            l_dbsmopg.pstsuccod 
             
             if l_coderr != 0 or l_coderr is null
                then
                let l_msg = "Erro na selecao de dados da locadora: ", l_coderr
                return 999, l_msg
             end if
             
             let m_opg_aux.lgdnum = 0
             
             call cty10g00_obter_cidcod(l_dbsmopg.cidnom, l_dbsmopg.ufdcod)
                  returning l_coderr, l_msg, l_dbsmopg.mpacidcod
                   
             if l_coderr != 0 or l_coderr is null or 
                l_dbsmopg.mpacidcod is null
                then
                display 'Cidade sede do segurado nao identificada:'
                display 'l_dbsmopg.endlgd: ', l_dbsmopg.endlgd
                display 'l_dbsmopg.lgdnum: ', l_dbsmopg.lgdnum
                display 'l_dbsmopg.endbrr: ', l_dbsmopg.endbrr
                display 'l_dbsmopg.ufdcod: ', l_dbsmopg.ufdcod
                display 'l_dbsmopg.cidnom: ', l_dbsmopg.cidnom
                let l_msg = "Cidade sede da locadora nao identificada"
                return l_coderr, l_msg
             end if
     otherwise
        call ctd12g00_dados_pst2(6, l_dbsmopg.pstcoddig)
             returning l_coderr, l_msg,
                       l_dbsmopg.endlgd   , l_dbsmopg.lgdnum   ,
                       l_dbsmopg.endbrr   , l_dbsmopg.mpacidcod,
                       l_dbsmopg.endcep   , l_dbsmopg.maides   ,
                       l_dbsmopg.muninsnum, l_dbsmopg.pcpatvcod,
                       l_dbsmopg.pisnum   , l_dbsmopg.pstsuccod,
                       l_dbsmopg.cidnom   , l_dbsmopg.ufdcod
                       
        if l_coderr != 0 or l_coderr is null or 
           l_dbsmopg.mpacidcod is null
           then
           display 'Cidade sede do segurado nao identificada:'
           display 'l_dbsmopg.endlgd: ', l_dbsmopg.endlgd
           display 'l_dbsmopg.lgdnum: ', l_dbsmopg.lgdnum
           display 'l_dbsmopg.endbrr: ', l_dbsmopg.endbrr
           display 'l_dbsmopg.ufdcod: ', l_dbsmopg.ufdcod
           display 'l_dbsmopg.cidnom: ', l_dbsmopg.cidnom
           let l_msg = "Cidade sede do prestador nao identificada"
           return l_coderr, l_msg
        end if   
  end case
   
  
  # obter cidade ligada a sucursal do fornecedor (tributacao)
  
  # buscar sucursal da OP ligada ao prestador
  if m_opg_aux.pstsuccod is not null
     then
     call cty10g00_dados_sucursal(1, l_dbsmopg.pstsuccod)
     returning l_cty10g00_out.res   ,
               l_cty10g00_out.msg   ,
               l_cty10g00_out.endufd,
               l_cty10g00_out.endcid,
               l_cty10g00_out.cidcod
  end if
  
  if l_cty10g00_out.cidcod is null or
     l_cty10g00_out.cidcod <= 0
     then
     call cty10g00_obter_cidcod(l_cty10g00_out.endcid, l_cty10g00_out.endufd)
          returning l_cty10g00_out.res,
                    l_cty10g00_out.msg,
                    l_cty10g00_out.cidcod
  end if

  
  call ctb11m20_tributo(param.tipochamada,
                        param.ciaempcod,
                        param.cmporgcod,
                        l_dbsmopg.pstcoddig,
                        l_dbsmopg.soctip,
                        l_dbsmopg.segnumdig,
                        l_dbsmopg.corsus,
                        l_opgfav.pestip ,
                        l_dbsmopg.prscootipcod,
                        l_dbsmopg.pcpatvcod,
                        l_cty10g00_out.cidcod,
                        l_dbsmopg.mpacidcod,
                        l_dbsmopg.favtip,
                        l_dbsmopg.pstsuccod,
                        l_dbsmopg.cidnom,   
                        l_dbsmopg.ufdcod)  
    returning l_coderr, l_msg
  
   return l_coderr, l_msg 
    
end function            
  
#----------------------------------------------------------------
function ctb11m20_seg_itau(param)
#----------------------------------------------------------------

 define param record
    cgccpfnum     like dbsmopgfav.cgccpfnum    ,
    cgcord        like dbsmopgfav.cgcord       ,
    cgccpfdig     like dbsmopgfav.cgccpfdig             
  end record

   define errocod  smallint,
          erromsg  char(80)

  define lr_segurado record
      itaciacod     like datmitaapl.itaciacod    ,  
      itaramcod     like datmitaapl.itaramcod    ,
      itaaplnum     like datmitaapl.itaaplnum    ,
      aplseqnum     like datmitaapl.aplseqnum    ,
      seglgdnom     like datmitaapl.seglgdnom    ,
      segendcmpdes  like datmitaapl.segendcmpdes ,
      seglgdnum     like datmitaapl.seglgdnum    ,
      segbrrnom     like datmitaapl.segbrrnom    ,
      segufdsgl     like datmitaapl.segufdsgl    ,
      segcidnom     like datmitaapl.segcidnom    ,
      segcepnum     like datmitaapl.segcepnum    ,
      segcepcmpnum  like datmitaapl.segcepcmpnum ,
      segmaiend     like datmitaapl.segmaiend 
  end record

  initialize lr_segurado.* to null
  
  
  
  open c_ctb11m20_002 using param.cgccpfnum,
                            param.cgcord,
                            param.cgccpfdig 
  
  fetch c_ctb11m20_002 into  lr_segurado.itaciacod   , 
                             lr_segurado.itaramcod   ,
                             lr_segurado.itaaplnum   ,
                             lr_segurado.aplseqnum   ,
                             lr_segurado.seglgdnom   ,
                             lr_segurado.segendcmpdes,
                             lr_segurado.seglgdnum   ,
                             lr_segurado.segbrrnom   ,
                             lr_segurado.segufdsgl   ,
                             lr_segurado.segcidnom   ,
                             lr_segurado.segcepnum   ,
                             lr_segurado.segcepcmpnum,
                             lr_segurado.segmaiend   
  
   if sqlca.sqlcode <> 0 then
      let errocod = sqlca.sqlcode
      let erromsg = 'Erro(',sqlca.sqlcode,') ao localizar os dados do segurado - ',
                    param.cgccpfnum,param.cgcord,'-',param.cgccpfdig
   else
      let errocod = sqlca.sqlcode
      let erromsg = ' '
   end if 
   close c_ctb11m20_002 
   
return  lr_segurado.*, errocod, erromsg

end function



#----------------------------------------------------------------
function ctb11m20_tributo(param)
#----------------------------------------------------------------

 define param record
    tipochamada  char(01),
    ciaempcod    like   datmservico.ciaempcod   , 
    cmporgcod    smallint                       ,
    pstcoddig    like   dpaksocor.pstcoddig     ,
    soctip       like   dbsmopg.soctip          ,
    segnumdig    like   dbsmopg.segnumdig       ,
    corsus       like   dbsmopg.corsus          ,
    pestip       like   dbsmopgfav.pestip       ,
    prscootipcod like   dpaksocor.prscootipcod  ,
    pcpatvcod    like   dpaksocor.pcpatvcod     ,
    cidcod       like   gabksuc.cidcod          ,
    mpacidcod    like   dpaksocor.mpacidcod     ,
    favtip       like   dbsmopg.favtip          ,
    pstsuccod    like   dpaksocor.succod        ,
    cidnom       like   glakcid.cidnom          ,
    ufdcod       like   glakcid.ufdcod          
 end record
 
 define l_arr_msg array[100] of char(80) 
 
 define l_cts54g00 record
         errcod        smallint ,
         errdes        char(80) ,
         tpfornec      char(3)  ,
         retencod      like fpgkplprtcinf.ppsretcod ,
         socitmtrbflg  char(1)  ,
         retendes      char(50)
  end record
  
  define l_ffpgc346 record
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
  
  define l_ctb00g14 record
         titulo   char(60),
         linha01  char(60),
         linha02  char(60),
         linha03  char(60),
         linha04  char(60),
         linha05  char(60),
         linha06  char(60),
         linha07  char(60),
         linha08  char(60),
         linha09  char(60)
  end record
  
  define l_res integer  
       , l_msg char(80)
       , l_pro char(1)
       , l_ct  smallint

  initialize l_cts54g00.* to null
  initialize l_ffpgc346.* to null

  let l_arr_msg[01] = '######################################################################'
  let l_arr_msg[02] = '##################  INICIO DE LOG DE ERRO  ###########################'
  let l_arr_msg[03] = '######################################################################'
  let l_arr_msg[04] = ''
  let l_arr_msg[05] = 'Verificacao de dados tributarios para OPs da empresa = ',param.ciaempcod
  let l_arr_msg[06] = 'Dados do favorecido: '
  let l_arr_msg[07] = 'Sucursal..: ', param.pstsuccod
  let l_arr_msg[08] = 'Cidade:...: ', param.cidnom
  let l_arr_msg[09] = 'UF........: ', param.ufdcod
   
    
    # buscar descricao da atividade principal
    #---------------------------------------------
    call cts54g00_inftrb(param.ciaempcod,
                         param.pstcoddig,
                         param.soctip,
                         param.segnumdig,
                         param.corsus,
                         param.pestip ,
                         param.prscootipcod,
                         param.pcpatvcod)
             returning l_cts54g00.errcod      ,
                       l_cts54g00.errdes      ,
                       l_cts54g00.tpfornec    ,
                       l_cts54g00.retencod    ,
                       l_cts54g00.socitmtrbflg,
                       l_cts54g00.retendes
  
  let l_arr_msg[10] = '------------------------------------------------------'
  let l_arr_msg[11] = "Retorno codigo de retencao: "
  let l_arr_msg[12] = 'Cod. erro..............: ', l_cts54g00.errcod
  let l_arr_msg[13] = 'Erro...................: ', l_cts54g00.errdes
  let l_arr_msg[14] = 'Tipo fornecedor........: ', l_cts54g00.tpfornec
  let l_arr_msg[15] = 'Cod. retencao People...: ', l_cts54g00.retencod
  let l_arr_msg[16] = 'Descr retencao.........: ', l_cts54g00.retendes
  let l_arr_msg[17] = 'Flag tributa...........: ', l_cts54g00.socitmtrbflg
  
  
  if l_cts54g00.socitmtrbflg = 'N' or param.ciaempcod = 84 then
     let l_res = 0
     let l_msg = ""
     return  l_res,l_msg
  end if 
  
  if l_cts54g00.errcod != 0 or
     l_cts54g00.retencod is null or
     l_cts54g00.retendes is null
     then
     let l_res = 999
     let l_msg = 'Erro na consulta a codigo de retencao People: ', 
                  l_cts54g00.errcod, ' | ', l_cts54g00.errdes clipped
     return l_res,l_msg
  end if
  
  if (param.cidcod is null or param.cidcod <= 0) and param.favtip != 3  then
     let l_res = 999
     let l_msg = "Cidade de prestacao de servico nao identificada"
     return l_res,l_msg    
  end if
  
  # obter flag's de tributacao e codigos de arrecadacao da receita
  #---------------------------------------------
  let l_arr_msg[19] = '------------------------------------------------------'
  let l_arr_msg[20] = 'Busca flag tributacao:parametros'
  let l_arr_msg[21] = 'Tipo pessoa............: ', param.pestip
  let l_arr_msg[22] = 'Cod. retencao People...: ', l_cts54g00.retencod
  let l_arr_msg[23] = 'Descr retencao.........: ', l_cts54g00.retendes
  let l_arr_msg[24] = 'Cidade prestacao serv..: ', param.cidcod
  let l_arr_msg[25] = 'Cidade sede prestador..: ', param.mpacidcod
  
  call ffpgc346(param.ciaempcod, 
                param.cmporgcod, # Codigo para identificar o Porto Socorro
                param.pestip,
                l_cts54g00.retencod,
                l_cts54g00.retendes, 
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

  let l_arr_msg[26] = '------------------------------------------------------'
  let l_arr_msg[27] = 'Busca flag tributacao:retorno'
  let l_arr_msg[28] = 'Empresa..............: ', m_ffpgc346.empresa
  let l_arr_msg[29] = 'Origem...............: ', m_ffpgc346.cmporgcod
  let l_arr_msg[30] = 'Tipo pessoa..........: ', m_ffpgc346.pestip
  let l_arr_msg[31] = 'Atividade............: ', m_ffpgc346.atividade
  let l_arr_msg[32] = 'Cod. erro............: ', m_ffpgc346.errcod
  let l_arr_msg[33] = 'Erro.................: ', m_ffpgc346.errdes
  let l_arr_msg[34] = 'Flag tributa IR......: ', m_ffpgc346.flagIR
  let l_arr_msg[35] = 'Flag tributa ISS.....: ', m_ffpgc346.flagISS
  let l_arr_msg[36] = 'Flag tributa INSS....: ', m_ffpgc346.flagINSS
  let l_arr_msg[37] = 'Flag tributa PIS.....: ', m_ffpgc346.flagPIS
  let l_arr_msg[38] = 'Flag tributa COF.....: ', m_ffpgc346.flagCOF
  let l_arr_msg[39] = 'Flag tributa CSLL....: ', m_ffpgc346.flagCSLL
  let l_arr_msg[40] = '------------------------------------------------------'
  let l_arr_msg[41] = 'Cod arrecadacao IR...: ', m_ffpgc346.arrecadacaoIR
  let l_arr_msg[42] = 'Cod arrecadacao ISS..: ', m_ffpgc346.arrecadacaoISS
  let l_arr_msg[43] = 'Cod arrecadacao INSS.: ', m_ffpgc346.arrecadacaoINSS
  let l_arr_msg[44] = 'Cod arrecadacao PIS..: ', m_ffpgc346.arrecadacaoPIS
  let l_arr_msg[45] = 'Cod arrecadacao COFIN: ', m_ffpgc346.arrecadacaoCOFIN
  let l_arr_msg[46] = 'Cod arrecadacao CSLL.: ', m_ffpgc346.arrecadacaoCSLL
  let l_arr_msg[47] = '------------------------------------------------------'
  
  if l_ffpgc346.errcod is null or l_ffpgc346.errcod != 0
     then
     let l_res = 999
     let l_msg = 'Erro na consulta a tributacao do favorecido: ', 
                 l_ffpgc346.errcod, ' | ', l_ffpgc346.errdes clipped
     let l_arr_msg[48] = l_msg clipped
  end if
  
  if l_ffpgc346.atividade is null
     then
     let l_res = 999
     let l_msg = 'Atividade nao identificada, entre em contato com tributos'
     let l_arr_msg[49] = l_msg clipped
  end if
  
  if l_ffpgc346.flagISS is null
     then
     let l_res = 999
     let l_msg = 'Tributacao ISS invalida, entre em contato com tributos'
     let l_arr_msg[50] = l_msg clipped
  else
     if l_ffpgc346.flagISS = "N"
        then
        let l_ffpgc346.arrecadacaoISS = null
     end if
  end if
  
  if l_ffpgc346.flagINSS is null
     then
     let l_res = 999
     let l_msg = 'Tributacao INSS invalida, entre em contato com tributos'
     let l_arr_msg[51] = l_msg clipped
  else
     if l_ffpgc346.flagINSS = "N"
        then
        let l_ffpgc346.arrecadacaoINSS = null
     end if
  end if
  
  if l_ffpgc346.flagPIS is null
     then
     let l_res = 999
     let l_msg = 'Tributacao PIS invalida, entre em contato com tributos'
     let l_arr_msg[52] = l_msg clipped
  else
     if l_ffpgc346.flagPIS = "N"
        then
        let l_ffpgc346.arrecadacaoPIS = null
     end if
  end if
  
  if l_ffpgc346.flagCOF is null
     then
     let l_res = 999
     let l_msg = 'Tributacao COFINS invalida, entre em contato com tributos'
     let l_arr_msg[53] = l_msg clipped
  else
     if l_ffpgc346.flagCOF = "N"
        then
        let l_ffpgc346.arrecadacaoCOFIN = null
     end if
  end if
  
  if l_ffpgc346.flagCSLL is null
     then
     let l_res = 999
     let l_msg = 'Tributacao CSLL invalida, entre em contato com tributos'
     let l_arr_msg[54] = l_msg clipped
  else
     if l_ffpgc346.flagCSLL = "N"
        then
        let l_ffpgc346.arrecadacaoCSLL = null
     end if
  end if
  
  if l_ffpgc346.flagIR is null
     then
     let l_res = 999
     let l_msg = 'Tributacao IR invalida, entre em contato com tributos'
     let l_arr_msg[55] = l_msg clipped
  else
     if l_ffpgc346.flagIR = "S" and
        l_ffpgc346.arrecadacaoIR is null 
        then
        let l_res = 999
        let l_msg = 'Regra de tributacao IR divergente, tributa IR mas não possui codigo arrecadacao'
        let l_arr_msg[57] = l_msg clipped
     end if
     if l_ffpgc346.flagIR = "N"
        then
        let l_ffpgc346.arrecadacaoIR = null
     end if
  end if
  
  let l_arr_msg[58] = ''
  let l_arr_msg[59] = '######################################################################'
  let l_arr_msg[60] = '###################  FINAL DE LOG DE ERRO  ###########################'
  let l_arr_msg[61] = '######################################################################'
  let l_arr_msg[62] = ''
  
  
  # algum erro na consulta a tributos
  if l_res != 0
     then
     
     # se for online, mostra pop-up de aviso na tela
     if param.tipochamada = "o"
        then
        
        let l_msg = "ATENCAO!!!"
        let l_ctb00g14.titulo  = ctb11m20_centraliza(l_msg, 60)
        
        let l_msg = "Esta OP nao será emitida"
        let l_ctb00g14.linha01 = ctb11m20_centraliza(l_msg, 60)
        
        let l_msg = "Erro: falta cadastro no tributos"
        let l_ctb00g14.linha03 = ctb11m20_centraliza(l_msg, 60)
        
        let l_msg = "Entre em contato com a area de Tributos"
        let l_ctb00g14.linha06 = ctb11m20_centraliza(l_msg, 60)
        
        let l_msg = "Se necessário, consulte o log de erro na tela acima"
        let l_ctb00g14.linha08 = ctb11m20_centraliza(l_msg, 60)
   
        let int_flag = false
        
        open window w_ctb00g14 at 10,11 with form "ctb00g14"
             attribute(form line 1, border)
             
        let l_pro = null
        
        whenever error continue
        while true
        
           # mostrar displays armazenados
           let l_ct = 1
           
           for l_ct = 1 to 100
              if l_arr_msg[l_ct] is not null
                 then
                 display l_arr_msg[l_ct] clipped
              end if
           end for
           
           display by name l_ctb00g14.titulo  attribute(reverse)
           display by name l_ctb00g14.linha01
           display by name l_ctb00g14.linha03
           display by name l_ctb00g14.linha06
           display by name l_ctb00g14.linha08
           
           error 'Erro na validacao tributos da empresa = ',param.ciaempcod,'. Lista de erros na tela acima'
           
           prompt "<Enter> ou <CTRL + C> para sair" for l_pro
              on key(interrupt, return)
                 exit while
           end prompt
           
           if int_flag then
              exit while
           end if
           
        end while
        whenever error stop
        
        initialize l_ctb00g14.* to null
        let int_flag = false
        close window w_ctb00g14
        
     end if
  end if
 
 return  l_res,l_msg
 
end function
