#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema..: Porto Socorro                                                   #
# Modulo...: ctc68m00                                                        #
# Objetivo.: Obter endereco de cliente segurado na abertura do laudo SAPS    #
# Analista.: Fabio Costa, Fornax                                             #
# Desenv...: Marcia Franzon, Intera                                          #
# PSI      : PSI-2013-07115                                                  #
# Liberacao: 16/10/2013                                                      #
#............................................................................#
# Observacoes                                                                #
#............................................................................#
# Alteracoes                                                                 #
#                                                                            #
#----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"
globals "/fontes/controle_ct24h/ct24h_geral/sg_glob5.4gl"  # PSI-2013-07115

define m_dct          integer
     , m_txt_aux      char(60)
    
#-----------------------------------------------
function ctc68m00(lr_param)
#-----------------------------------------------

   define lr_param       record
          cgccpfnum      like gsakpes.cgccpfnum
         ,cgcord         like gsakpes.cgcord
         ,cgccpfdig      like gsakpes.cgccpfdig
         ,pestip         char(01)
   end record

   set isolation to dirty read

   if lr_param.cgcord is null then
      let lr_param.cgcord = 0
   end if

   initialize ga_dados_saps to null # (definido em sg_glob4)
   
   let ga_dct = 0                   # (definido em sg_glob4)
   let m_dct  = 0  # devera somar a cada docto incrementado

   call ctc68m00_prepares(lr_param.pestip)
   call ctc68m00_dados_porto(lr_param.*)
   call ctc68m00_dados_azul(lr_param.*)
   call ctc68m00_dados_itau_auto(lr_param.*)
   call ctc68m00_dados_itau_re(lr_param.*)
   call ctc68m00_dados_porto_saude(lr_param.*)
   call ctc68m00_dados_porto_cartoes(lr_param.*)
   call ctc68m00_dados_vist_prev(lr_param.*)

   let ga_dct = m_dct

   set isolation to committed read
   
end function

#-----------------------------------------------
function ctc68m00_prepares(l_pestip)
#-----------------------------------------------
        
   define l_pestip  char(01)
   define l_sql     char(2000)

   let l_sql = " select cpodes[3,50] "
              ," from iddkdominio "
              ," where cpocod = ? "
              ," and   cponom = 'codprod' "
   prepare pctc68m00001 from l_sql

   let l_sql = " select cornom "
              ," from gcakcorr "
              ," where corsuspcp =  ? "
   prepare pctc68m00002 from l_sql

   let l_sql = " select vcllicnum, vclcoddig, vclanomdl, vsttip  "
              ,"      , vstnumdig, max(dctnumseq) "
              ," from abbmveic "
              ," where succod  = ?  "  
              ," and aplnumdig = ?  "  
              ," and itmnumdig = ?  "  
              ," group by 1,2,3,4,5 "
   prepare pctc68m00003 from l_sql
   declare cctc68m00003 cursor with hold for pctc68m00003

   let l_sql = " select vclcorcod "
              ," from  avbmveic "
              ," where avbmveic.cbpnum = ? "
   prepare pctc68m00005 from l_sql

   let l_sql = " select first 1 vclcorcod "
              ," from  avlmveic "
              ," where avlmveic.vstnumdig = ?"
   prepare pctc68m00006 from l_sql

   let l_sql = " select cpodes "
              ," from iddkdominio "
              ," where cponom = 'vclcordoc' "
              ," and   cpocod =  ? " # l_vclcorcod
   prepare pctc68m00007 from l_sql

   let l_sql = " select succod, aplnumdig, itmnumdig, azlaplcod "
              ," from datkazlapl "
              ," where cgccpfnum   =  ? " # lr_param.cgccpfnum
              ," and   cgcord      =  ? " # lr_param.cgcord
              ," and   cgccpfdig   =  ? " # lr_param.cgccpfdig
   prepare pctc68m00008 from l_sql
   declare cctc68m00008 cursor with hold for pctc68m00008

   let  l_sql = "select a.succod        , a.itaaplnum    , a.segnom "
               ,"      ,a.seglgdnom     , a.seglgdnum    , a.segbrrnom "
               ,"      ,a.segcidnom     , a.segufdsgl    , a.segendcmpdes "
               ,"      ,a.segresteldddnum,a.segrestelnum , a.segcepnum "
               ,"      ,a.segcepcmpnum  , a.corsus       , i.itaaplitmnum "
               ,"      ,i.autfbrnom     , i.autlnhnom    , i.autmodnom "
               ,"      ,i.autmodano     , i.autplcnum    , i.autcornom "
               ,"      ,i.porvclcod     , a.itaramcod "
               ," from datmitaapl a, datmitaaplitm i "
               ," where a.itaciacod    = i.itaciacod "
               ," and   a.itaramcod    = i.itaramcod "
               ," and   a.itaaplnum    = i.itaaplnum "
               ," and   a.aplseqnum    = i.aplseqnum "
               ," and   a.segcgccpfnum =  ? " #lr_param.cgccpfnum
               ," and   a.segcgcordnum =  ? " #lr_param.cgcord
               ," and   a.segcgccpfdig =  ? " #lr_param.cgccpfdig
   prepare pctc68m00009 from l_sql
   declare cctc68m00009 cursor with hold for pctc68m00009

   let l_sql = " select  a.succod    ,a.aplnum      ,a.segnom  "
              ,"        ,a.dddcod    ,a.telnum      ,a.suscod  "
              ,"        ,i.aplitmnum ,i.rsclgdnom   ,i.rsclgdnum  "
              ,"        ,i.rsccpldes ,i.rscbrrnom   ,i.rsccidnom  "
              ,"        ,i.rscestsgl ,i.rsccepcod   ,i.rsccepcplcod "
              ,"        ,max(a.aplseqnum)  "
              ," from datmresitaapl a, datmresitaaplitm i "
              ," where a.itaciacod    = i.itaciacod "
              ," and a.itaramcod    = i.itaramcod "
              ," and a.aplnum       = i.aplnum    "
              ," and a.aplseqnum    = i.aplseqnum "
              ," and a.segcpjcpfnum = ? " # lr_param.cgccpfnum
              ," and a.cpjordnum    = ? " # lr_param.cgcord
              ," and a.cpjcpfdignum = ? " # lr_param.cgccpfdig
              ," group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 "
   prepare pctc68m00010 from l_sql
   declare cctc68m00010 cursor with hold for pctc68m00010

   let l_sql = " select first 1 succod, aplnumdig, segnom, lgdtip "
              ,"              , lgdnom, lgdnum, lclbrrnom, cidnom "
              ,"              , ufdcod, lclrefptotxt, lgdcep, lgdcepcmp "
              ,"              , dddcod, lcltelnum, corsus, cornom "
              ," from datksegsau a "
              ," where a.cgccpfnum   =  ? " # lr_param.cgccpfnum "
              ," and   a.cgcord      =  ? " # lr_param.cgcord   "
              ," and   a.cgccpfdig   =  ? " # lr_param.cgccpfdig "
              ," and   a.lgdnom is not null "
              ," order by incdat desc "
   prepare pctc68m00011 from l_sql

   let l_sql = " select first 1 succod, aplnumdig, segnom, lgdtip "
              ,"              , lgdnom, lgdnum, lclbrrnom, cidnom "
              ,"              , ufdcod, lclrefptotxt, lgdcep, lgdcepcmp "
              ,"              , dddcod, lcltelnum, corsus, cornom "
              ," from datksegsau a "
              ," where a.cgccpfnum   =  ? " # lr_param.cgccpfnum "
              ," and   a.cgccpfdig   =  ? " # lr_param.cgccpfdig "
              ," and   a.lgdnom is not null "
              ," order by incdat desc "
   prepare pctc68m00012 from l_sql

   let l_sql = "select c.crdprpnom, c.corsus, c.dddtel "
              ,"      ,c.telnum   , c.dddcel, c.celnum "
              ,"      ,e.endlgdtip, e.endlgd, e.endnum "
              ,"      ,e.endbrr   , e.endcid, e.endcep "
              ,"      ,e.endufd   , e.endcmp "
              ," from fsckprpcrd c, fscmcliend e "
              ," where c.cgccpfnumdig = e.cgccpfnumdig "
              ," and c.cgccpfnumdig   =  ? " # lr_param.cgccpfnumdig
   prepare pctc68m00013 from l_sql
   declare cctc68m00013 cursor with hold for pctc68m00013

   let l_sql = " select first 1 crdprpnum "
              ," from fsckprpdad  "
              ," where cgccpfnumdig =  ? " #lr_param.cgccpfnumdig
   prepare pctc68m00014 from l_sql

   let l_sql = " select vstnumdig , segnom   , lgdtip  "
              ,"      , segendlgd , lgdnum   , segendbrr "
              ,"      , endcid    , endufd   , endcep    "
              ,"      , endcepcmp , segtelddd, segteltxt "
              ,"      , corsus , endcmpl "
              ," from avlmlaudo a "
              ," where a.cgccpfnum =  ? "

   if l_pestip = 'J' then
      let l_sql = l_sql clipped ," and a.cgcord      =  ? "
                                ," and a.cgccpfdig   =  ? "
   else
      let l_sql = l_sql clipped ," and a.cgccpfdig   =  ? "
   end if
   
   prepare pctc68m00015 from l_sql
   declare cctc68m00015 cursor with hold for pctc68m00015

end function

#-----------------------------------------------
function ctc68m00_dados_porto(lr_param)
#-----------------------------------------------

   define lr_param     record
          cgccpfnum    like gsakpes.cgccpfnum
         ,cgcord       like gsakpes.cgcord
         ,cgccpfdig    like gsakpes.cgccpfdig
         ,pestip       char(01)
   end record
   
   define lr_ret_neg     record
          prod           smallint
         ,situacao       char(30)
         ,documento      char(110)
         ,resultado      smallint
   end record

   define lr_ret_cli     record
          sqlcode        integer
         ,qtd            smallint
         ,prod           smallint
         ,pesnum         like gsakpes.pesnum
         ,cgccpf         like gsakpes.cgccpfnum
         ,cgcord         like gsakpes.cgcord
         ,cgccpfdig      like gsakpes.cgccpfdig
         ,pesnom         like gsakpes.pesnom
         ,pestip         like gsakpes.pestip
   end record

   define l_arr        smallint
        , l_vclcorcod  like iddkdominio.cpocod
        , l_vsttip     like abbmveic.vsttip
        , l_vstnumdig  like abbmveic.vstnumdig
        , l_aux        smallint
        , l_qtd        integer
        , l_status     integer
        , l_retorno    smallint
        , l_mensagem   char(70)
        , l_qtd2       smallint
     
   initialize lr_ret_neg.* to null
   initialize lr_ret_cli.* to null
         
   # obter negocios Porto Seguro do segurado na base unificada

   call osgtf550_pesquisa_negocios_cpfcnpj(lr_param.cgccpfnum,
                                           lr_param.cgcord   ,
                                           lr_param.cgccpfdig,
                                           lr_param.pestip )
        returning lr_ret_neg.resultado, l_qtd

   if l_qtd is null or
      l_qtd = 0     then
      return
   end if

   for l_arr = 1 to l_qtd
   
       let m_dct = m_dct + 1
       
       if m_dct > 20 then
          exit for
       end if
       
       whenever error continue
       if g_a_gsakdocngcseg[l_arr].doc1 is not null and g_a_gsakdocngcseg[l_arr].doc1 != ' '
          then
          let m_txt_aux = g_a_gsakdocngcseg[l_arr].doc1 clipped
       end if
       
       if g_a_gsakdocngcseg[l_arr].doc3 is not null and g_a_gsakdocngcseg[l_arr].doc3 != ' '
          then
          let m_txt_aux = m_txt_aux clipped, '-', g_a_gsakdocngcseg[l_arr].doc3 clipped
       end if
       
       if g_a_gsakdocngcseg[l_arr].doc4 is not null and g_a_gsakdocngcseg[l_arr].doc4 != ' '
          then
          let m_txt_aux = m_txt_aux clipped, '-', g_a_gsakdocngcseg[l_arr].doc4 clipped
       end if
       whenever error stop
       
       let ga_dados_saps[m_dct].docnum = m_txt_aux clipped
       
       # obter nome do segurado
       call osgtf550_busca_cliente_cgccpf(lr_param.cgccpfnum ,
                                          lr_param.cgcord    ,
                                          lr_param.cgccpfdig ,
                                          lr_param.pestip )
            returning lr_ret_cli.sqlcode, lr_ret_cli.qtd

       if lr_ret_cli.qtd is null or
          lr_ret_cli.qtd = 0     then
          continue for
       end if
       
       # obter enderecos de cada documento
       call osgtf550_pesquisa_pesnum_endereco(g_a_gsakdocngcseg[l_arr].pesnum)
            returning l_status

       if  g_r_endereco.endlgd is null or g_r_endereco.endlgd = ' ' or l_status != 0  # endereco nulo, ignora
          then
          let m_dct = m_dct - 1  # retira do array e passa pra o proximo
          continue for
       end if
       
       whenever error continue
       
       let ga_dados_saps[m_dct].segnom = g_a_cliente[1].pesnom
       let ga_dados_saps[m_dct].lgdtip = g_r_endereco.endlgdtip
       let ga_dados_saps[m_dct].lgdnom = g_r_endereco.endlgd   
       let ga_dados_saps[m_dct].lgdtxt = g_r_endereco.endlgdtip clipped, " ", g_r_endereco.endlgd clipped
       let ga_dados_saps[m_dct].lgdnum = g_r_endereco.endnum                                      
                       
       if ga_dados_saps[m_dct].lgdnum is not null and ga_dados_saps[m_dct].lgdnum > 0
          then
          let ga_dados_saps[m_dct].lgdtxt = ga_dados_saps[m_dct].lgdtxt clipped, ", ", ga_dados_saps[m_dct].lgdnum using "<<<<<<<<<<"
       end if
                                             
       let ga_dados_saps[m_dct].brrnom = g_r_endereco.endbrr
       let ga_dados_saps[m_dct].cidnom = g_r_endereco.endcid
       let ga_dados_saps[m_dct].ufdcod = g_r_endereco.endufd
       
       let ga_dados_saps[m_dct].endcmp       = g_r_endereco.endcmp
       let ga_dados_saps[m_dct].lclrefptotxt = null
       let ga_dados_saps[m_dct].lgdcep       = g_r_endereco.endcep using "&&&&&"
       let ga_dados_saps[m_dct].lgdcepcmp    = g_r_endereco.endcepcmp using "&&&"
       
       let ga_dados_saps[m_dct].dddcod       = g_r_endereco.dddtel using "&&&"
       let ga_dados_saps[m_dct].lcltelnum    = g_r_endereco.telnum
       let ga_dados_saps[m_dct].celteldddcod = g_r_endereco.dddcel using "&&&"
       let ga_dados_saps[m_dct].celtelnum    = g_r_endereco.celnum
       
       let ga_dados_saps[m_dct].corsus       = g_a_gsakdocngcseg[l_arr].corsus
       
       whenever error stop

       #obter descricao dos negocios
       execute pctc68m00001 into ga_dados_saps[m_dct].prdnom using g_a_gsakdocngcseg[l_arr].unfprdcod

       # nome do corretor
       execute pctc68m00002 into ga_dados_saps[m_dct].cornom using ga_dados_saps[m_dct].corsus

       # localizar dados do veiculo
       if g_a_gsakdocngcseg[l_arr].unfprdcod  = 1  then # - Apolice AUTO
       
          open cctc68m00003  using g_a_gsakdocngcseg[l_arr].doc1
                                 , g_a_gsakdocngcseg[l_arr].doc3
                                 , g_a_gsakdocngcseg[l_arr].doc4
                                  
          fetch cctc68m00003 into ga_dados_saps[m_dct].vcllicnum
                                , ga_dados_saps[m_dct].vclcoddig
                                , ga_dados_saps[m_dct].vclanomdl
                                , l_vsttip
                                , l_vstnumdig
                                , l_aux
                                
          # descricao do veiculo
          let ga_dados_saps[m_dct].vcldes = cts15g00(ga_dados_saps[m_dct].vclcoddig)
          
          # corretor da apolice
          call cty05g00_abamcor(1,g_a_gsakdocngcseg[l_arr].doc1, g_a_gsakdocngcseg[l_arr].doc3)
               returning l_retorno, l_mensagem, ga_dados_saps[m_dct].corsus
          
          # condicao para obter cor do veiculo
          if l_vsttip = "C" then
             execute pctc68m00005 into l_vclcorcod using l_vstnumdig
          else
             execute pctc68m00006 into l_vclcorcod using l_vstnumdig
          end if

          execute pctc68m00007 into ga_dados_saps[m_dct].vclcordes using l_vclcorcod
  
          close cctc68m00003
       end if # - apolice auto

   end for

end function

#-----------------------------------------------
function ctc68m00_dados_azul(lr_param)
#-----------------------------------------------
    define lr_param   record
           cgccpfnum  like gsakpes.cgccpfnum
          ,cgcord     like gsakpes.cgcord
          ,cgccpfdig  like gsakpes.cgccpfdig
          ,pestip     char(01)
    end record
    
    define l_apl_azul record
           succod     like datkazlapl.succod
          ,aplnumdig  like datkazlapl.aplnumdig
          ,itmnumdig  like datkazlapl.itmnumdig
          ,azlaplcod  like datkazlapl.azlaplcod
          ,ramcod     like datkazlapl.ramcod
    end record

    define l_doc_handle   integer
    
    initialize l_apl_azul.* to null
    
    if lr_param.pestip = 'F' then
       let lr_param.cgcord = 0
    end if

    open cctc68m00008 using lr_param.cgccpfnum, lr_param.cgcord, lr_param.cgccpfdig
                           
    foreach cctc68m00008 into l_apl_azul.succod
                             ,l_apl_azul.aplnumdig
                             ,l_apl_azul.itmnumdig
                             ,l_apl_azul.azlaplcod
                             ,l_apl_azul.ramcod

       let m_dct = m_dct + 1
       
       if m_dct > 20 then
         exit foreach
       end if

       initialize m_txt_aux to null
      
       whenever error continue
       if l_apl_azul.succod is not null
          then
          let m_txt_aux = l_apl_azul.succod using "&&"
       end if
       
       if l_apl_azul.aplnumdig is not null
          then
          let m_txt_aux = m_txt_aux clipped, '-', l_apl_azul.aplnumdig using "&&&&&&&&&"
       end if
       
       if l_apl_azul.itmnumdig is not null
          then
          let m_txt_aux = m_txt_aux clipped, '-', l_apl_azul.itmnumdig using "&&"
       end if
       whenever error stop
       
       let ga_dados_saps[m_dct].docnum = m_txt_aux clipped
                                       
       # Obter endereco de cada apolice
       call figrc011_inicio_parse()
   
       let l_doc_handle = ctd02g00_agrupaXML(l_apl_azul.azlaplcod)
    
       whenever error continue
       let ga_dados_saps[m_dct].segnom = figrc011_xpath(l_doc_handle,"/APOLICE/SEGURADO/NOME")
       
       let ga_dados_saps[m_dct].lgdtip = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/TIPO")
       let ga_dados_saps[m_dct].lgdnom = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/LOGRADOURO")
       let ga_dados_saps[m_dct].lgdnum = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/NUMERO")
       
       if ga_dados_saps[m_dct].lgdnom is null or ga_dados_saps[m_dct].lgdnom = ' '
          then
          let m_dct = m_dct - 1
          continue foreach
       end if
       
       let ga_dados_saps[m_dct].lgdtxt = ga_dados_saps[m_dct].lgdtip clipped, ' ', ga_dados_saps[m_dct].lgdnom clipped
       
       initialize m_txt_aux to null
       let m_txt_aux = figrc011_xpath(l_doc_handle,"/APOLICE/SEGURADO/ENDERECO/NUMERO")
       
       if m_txt_aux is not null and m_txt_aux > 0
          then
          let ga_dados_saps[m_dct].lgdtxt = ga_dados_saps[m_dct].lgdtxt clipped, ", ", m_txt_aux using "<<<<<<"
       end if

       let ga_dados_saps[m_dct].brrnom       = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/BAIRRO")
       let ga_dados_saps[m_dct].cidnom       = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/CIDADE")
       let ga_dados_saps[m_dct].ufdcod       = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/UF")
       
       let ga_dados_saps[m_dct].endcmp       = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/COMPLEMENTO")
       let ga_dados_saps[m_dct].lclrefptotxt = null
       let ga_dados_saps[m_dct].lgdcep       = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/CEP") ##### [1,5]
       let ga_dados_saps[m_dct].lgdcepcmp    = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/CEP") ### [6,8]
       
       let ga_dados_saps[m_dct].dddcod       = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/FONES/FONE/DDD")
       let ga_dados_saps[m_dct].lcltelnum    = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/FONES/FONE/NUMERO")
       let ga_dados_saps[m_dct].celteldddcod = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/FONES/FONE/DDD")
       let ga_dados_saps[m_dct].celtelnum    = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/FONES/FONE/NUMERO")
       
       let ga_dados_saps[m_dct].corsus       = figrc011_xpath(l_doc_handle, "/APOLICE/CORRETOR/SUSEP")
       let ga_dados_saps[m_dct].cornom       = figrc011_xpath(l_doc_handle, "/APOLICE/CORRETOR/NOME")
       let l_apl_azul.ramcod                 = figrc011_xpath(l_doc_handle, "/APOLICE/RAMO")
       
       whenever error stop
   
       # Localizar dados do veiclulo se for apolice AUTO
       if l_apl_azul.ramcod = 531 then
          let ga_dados_saps[m_dct].prdnom    = "AZUL SEGUROS AUTO"
          let ga_dados_saps[m_dct].vclcoddig = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/CODIGO")
          let ga_dados_saps[m_dct].vcldes    = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/MARCA") , " " , 
                                               figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/MODELO")
          let ga_dados_saps[m_dct].vclanomdl = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/ANO/MODELO")
          let ga_dados_saps[m_dct].vcllicnum = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/PLACA")
          let ga_dados_saps[m_dct].vclcordes = null
       else
          let ga_dados_saps[m_dct].prdnom    = "AZUL SEGUROS RE"
       end if
   
       call figrc011_fim_parse()

    end foreach

end function

#-----------------------------------------------
function ctc68m00_dados_itau_auto(lr_param)
#-----------------------------------------------
   define lr_param   record
          cgccpfnum  like gsakpes.cgccpfnum
         ,cgcord     like gsakpes.cgcord
         ,cgccpfdig  like gsakpes.cgccpfdig
         ,pestip     char(01)
   end record
   
   define l_dados_itau  record
          succod          like datmitaapl.succod
         ,itaaplnum       like datmitaapl.itaaplnum
         ,segnom          like datmitaapl.segnom
         ,seglgdnom       like datmitaapl.seglgdnom
         ,seglgdnum       like datmitaapl.seglgdnum
         ,segbrrnom       like datmitaapl.segbrrnom
         ,segcidnom       like datmitaapl.segcidnom
         ,segufdsgl       like datmitaapl.segufdsgl
         ,segendcmpdes    like datmitaapl.segendcmpdes
         ,segresteldddnum like datmitaapl.segresteldddnum
         ,segrestelnum    like datmitaapl.segrestelnum
         ,segcepnum       like datmitaapl.segcepnum
         ,segcepcmpnum    like datmitaapl.segcepcmpnum
         ,corsus          like datmitaapl.corsus
         ,itaaplitmnum    like datmitaaplitm.itaaplitmnum
         ,autfbrnom       like datmitaaplitm.autfbrnom
         ,autlnhnom       like datmitaaplitm.autlnhnom
         ,autmodnom       like datmitaaplitm.autmodnom
         ,autmodano       like datmitaaplitm.autmodano
         ,autplcnum       like datmitaaplitm.autplcnum
         ,autcornom       like datmitaaplitm.autcornom
         ,porvclcod       like datmitaaplitm.porvclcod
         ,itaramcod       like datmitaapl.itaramcod
   end record

   open cctc68m00009 using lr_param.cgccpfnum, lr_param.cgcord, lr_param.cgccpfdig
          
   foreach cctc68m00009 into l_dados_itau.*
   
      if l_dados_itau.seglgdnom is null or l_dados_itau.seglgdnom = ' '
         then
         continue foreach
      end if
      
      let m_dct = m_dct + 1
      
      if m_dct > 20 then
        exit foreach
      end if
      
      whenever error continue
      
      initialize m_txt_aux to null
      
      if l_dados_itau.succod is not null
         then
         let m_txt_aux = l_dados_itau.succod using "<<<<<"
      end if
      
      if l_dados_itau.itaaplnum is not null
         then
         let m_txt_aux = m_txt_aux clipped, '-', l_dados_itau.itaaplnum using "&&&&&&&&&"
      end if
      
      if l_dados_itau.itaaplitmnum is not null
         then
         let m_txt_aux = m_txt_aux clipped, '-', l_dados_itau.itaaplitmnum using "<<<<<"
      end if
      
      let ga_dados_saps[m_dct].docnum = m_txt_aux clipped
      
      let ga_dados_saps[m_dct].segnom = l_dados_itau.segnom clipped   
      let ga_dados_saps[m_dct].lgdtip = null
      let ga_dados_saps[m_dct].lgdnom = l_dados_itau.seglgdnom clipped
      let ga_dados_saps[m_dct].lgdtxt = l_dados_itau.seglgdnom clipped
      let ga_dados_saps[m_dct].lgdnum = l_dados_itau.seglgdnum
      
      if ga_dados_saps[m_dct].lgdnum is not null and ga_dados_saps[m_dct].lgdnum > 0
         then
         let ga_dados_saps[m_dct].lgdtxt = ga_dados_saps[m_dct].lgdnom clipped, ", ", ga_dados_saps[m_dct].lgdnum using "<<<<<<<<<<"
      end if
      
      let ga_dados_saps[m_dct].brrnom       = l_dados_itau.segbrrnom
      let ga_dados_saps[m_dct].cidnom       = l_dados_itau.segcidnom
      let ga_dados_saps[m_dct].ufdcod       = l_dados_itau.segufdsgl
      
      let ga_dados_saps[m_dct].endcmp       = l_dados_itau.segendcmpdes
      let ga_dados_saps[m_dct].lclrefptotxt = null
      let ga_dados_saps[m_dct].lgdcep       = l_dados_itau.segcepnum using "&&&&&"
      let ga_dados_saps[m_dct].lgdcepcmp    = l_dados_itau.segcepcmpnum using "&&&"
      
      let ga_dados_saps[m_dct].dddcod       = l_dados_itau.segresteldddnum
      let ga_dados_saps[m_dct].lcltelnum    = l_dados_itau.segrestelnum
      let ga_dados_saps[m_dct].celteldddcod = null
      let ga_dados_saps[m_dct].celtelnum    = null
      
      let ga_dados_saps[m_dct].corsus       = l_dados_itau.corsus
      let ga_dados_saps[m_dct].prdnom       = 'ITAU SEGUROS AUTO'
      
      if l_dados_itau.itaramcod = 531 or l_dados_itau.itaramcod = 31
         then
         let ga_dados_saps[m_dct].vclcoddig = l_dados_itau.porvclcod
         let ga_dados_saps[m_dct].vcldes    = l_dados_itau.autfbrnom clipped , " "
                                             ,l_dados_itau.autlnhnom clipped , " "
                                             ,l_dados_itau.autmodnom
         let ga_dados_saps[m_dct].vclanomdl = l_dados_itau.autmodano
         let ga_dados_saps[m_dct].vcllicnum = l_dados_itau.autplcnum
         let ga_dados_saps[m_dct].vclcordes = l_dados_itau.autcornom
      end if
      
      whenever error stop
      
      # localizar corretor
      execute pctc68m00002 into ga_dados_saps[m_dct].cornom using ga_dados_saps[m_dct].corsus

   end foreach

end function

#-----------------------------------------------
function ctc68m00_dados_itau_re(lr_param)
#-----------------------------------------------
   define lr_param          record
          cgccpfnum         like gsakpes.cgccpfnum
         ,cgcord            like gsakpes.cgcord
         ,cgccpfdig         like gsakpes.cgccpfdig
         ,pestip            char(01)
   end record
   
   define l_dados_itau_RE   record
          succod            like datmresitaapl.succod
         ,aplnum            like datmresitaapl.aplnum
         ,segnom            like datmresitaapl.segnom
         ,dddcod            like datmresitaapl.dddcod
         ,telnum            like datmresitaapl.telnum
         ,suscod            like datmresitaapl.suscod
         ,aplitmnum         like datmresitaaplitm.aplitmnum
         ,rsclgdnom         like datmresitaaplitm.rsclgdnom
         ,rsclgdnum         like datmresitaaplitm.rsclgdnum
         ,rsccpldes         like datmresitaaplitm.rsccpldes
         ,rscbrrnom         like datmresitaaplitm.rscbrrnom
         ,rsccidnom         like datmresitaaplitm.rsccidnom
         ,rscestsgl         like datmresitaaplitm.rscestsgl
         ,rsccepcod         like datmresitaaplitm.rsccepcod
         ,rsccepcplcod      like datmresitaaplitm.rsccepcplcod
         ,aplseqnum         like datmresitaapl.aplseqnum
   end record

   open cctc68m00010  using lr_param.cgccpfnum
                           ,lr_param.cgcord
                           ,lr_param.cgccpfdig
                           
   foreach cctc68m00010 into l_dados_itau_RE.*
   
      if l_dados_itau_RE.rsclgdnom is null or l_dados_itau_RE.rsclgdnom = ' '
         then
         continue foreach
      end if
      
      let m_dct = m_dct + 1
      
      if m_dct > 20 then
        exit foreach
      end if
      
      whenever error continue
      
      initialize m_txt_aux to null
      
      if l_dados_itau_RE.succod is not null
         then
         let m_txt_aux = l_dados_itau_RE.succod using "&&"
      end if
      
      if l_dados_itau_RE.aplnum is not null
         then
         let m_txt_aux = m_txt_aux clipped, '-', l_dados_itau_RE.aplnum using "&&&&&&&&&"
      end if
      
      if l_dados_itau_RE.aplitmnum is not null
         then
         let m_txt_aux = m_txt_aux clipped, '-', l_dados_itau_RE.aplitmnum using "&&"
      end if
      
      let ga_dados_saps[m_dct].docnum = m_txt_aux clipped
      
      let ga_dados_saps[m_dct].segnom = l_dados_itau_RE.segnom
      let ga_dados_saps[m_dct].lgdtip = null
      let ga_dados_saps[m_dct].lgdnom = l_dados_itau_RE.rsclgdnom
      let ga_dados_saps[m_dct].lgdtxt = l_dados_itau_RE.rsclgdnom
      let ga_dados_saps[m_dct].lgdnum = l_dados_itau_RE.rsclgdnum
      
      if ga_dados_saps[m_dct].lgdnum is not null and ga_dados_saps[m_dct].lgdnum > 0
         then
         let ga_dados_saps[m_dct].lgdtxt = ga_dados_saps[m_dct].lgdtxt clipped, ", ", ga_dados_saps[m_dct].lgdnum using "<<<<<<<<<<"
      end if
      
      let ga_dados_saps[m_dct].brrnom       = l_dados_itau_RE.rscbrrnom
      let ga_dados_saps[m_dct].cidnom       = l_dados_itau_RE.rsccidnom
      let ga_dados_saps[m_dct].ufdcod       = l_dados_itau_RE.rscestsgl
      
      let ga_dados_saps[m_dct].endcmp       = l_dados_itau_RE.rsccpldes
      let ga_dados_saps[m_dct].lclrefptotxt = null
      let ga_dados_saps[m_dct].lgdcep       = l_dados_itau_RE.rsccepcod using "&&&&&"
      let ga_dados_saps[m_dct].lgdcepcmp    = l_dados_itau_RE.rsccepcplcod using "&&&"
      
      let ga_dados_saps[m_dct].dddcod       = l_dados_itau_RE.dddcod
      let ga_dados_saps[m_dct].lcltelnum    = l_dados_itau_RE.telnum
      let ga_dados_saps[m_dct].celteldddcod = null
      let ga_dados_saps[m_dct].celtelnum    = null

      let ga_dados_saps[m_dct].corsus       = l_dados_itau_RE.suscod
      let ga_dados_saps[m_dct].prdnom       = "ITAU SEGUROS RE"

      whenever error stop
      
      # localizar corretor
      execute pctc68m00002 into ga_dados_saps[m_dct].cornom using ga_dados_saps[m_dct].corsus

   end foreach
   
end function

#-----------------------------------------------
function ctc68m00_dados_porto_saude(lr_param)
#-----------------------------------------------
   define lr_param            record
          cgccpfnum           like gsakpes.cgccpfnum
         ,cgcord              like gsakpes.cgcord
         ,cgccpfdig           like gsakpes.cgccpfdig
         ,pestip              char(01)
   end record
   
   define l_dados_porto_saude record
          succod              like datksegsau.succod
         ,aplnumdig           like datksegsau.aplnumdig
         ,segnom              like datksegsau.segnom
         ,lgdtip              like datksegsau.lgdtip
         ,lgdnom              like datksegsau.lgdnom
         ,lgdnum              like datksegsau.lgdnum
         ,lclbrrnom           like datksegsau.lclbrrnom
         ,cidnom              like datksegsau.cidnom
         ,ufdcod              like datksegsau.ufdcod
         ,lclrefptotxt        like datksegsau.lclrefptotxt
         ,lgdcep              like datksegsau.lgdcep
         ,lgdcepcmp           like datksegsau.lgdcepcmp
         ,dddcod              like datksegsau.dddcod
         ,lcltelnum           like datksegsau.lcltelnum
         ,corsus              like datksegsau.corsus
         ,cornom              like datksegsau.cornom
   end record

   if lr_param.pestip = 'J' then
      execute pctc68m00011 into  l_dados_porto_saude.*
      using lr_param.cgccpfnum
           ,lr_param.cgcord
           ,lr_param.cgccpfdig
   else
      execute pctc68m00012 into  l_dados_porto_saude.*
      using lr_param.cgccpfnum
           ,lr_param.cgccpfdig
   end if

   if sqlca.sqlcode = 100 then
      return
   end if

   if l_dados_porto_saude.lgdnom is null or l_dados_porto_saude.lgdnom = ' '
      then
      return
   end if
   
   let m_dct = m_dct + 1

   if m_dct > 20 then
      return
   end if

   whenever error continue
   
   initialize m_txt_aux to null
      
   if l_dados_porto_saude.succod is not null
      then
      let m_txt_aux = l_dados_porto_saude.succod using "&&"
   end if
   
   if l_dados_porto_saude.aplnumdig is not null
      then
      let m_txt_aux = m_txt_aux clipped, '-', l_dados_porto_saude.aplnumdig using "&&&&&&&&&"
   end if
   
   let ga_dados_saps[m_dct].docnum = m_txt_aux clipped
   
   let ga_dados_saps[m_dct].segnom = l_dados_porto_saude.segnom
   let ga_dados_saps[m_dct].lgdtip = l_dados_porto_saude.lgdtip
   let ga_dados_saps[m_dct].lgdnom = l_dados_porto_saude.lgdnom clipped
   let ga_dados_saps[m_dct].lgdtxt = l_dados_porto_saude.lgdtip clipped, " ", l_dados_porto_saude.lgdnom clipped
   let ga_dados_saps[m_dct].lgdnum = l_dados_porto_saude.lgdnum

   if ga_dados_saps[m_dct].lgdnum is not null and ga_dados_saps[m_dct].lgdnum > 0
      then
      let ga_dados_saps[m_dct].lgdtxt = ga_dados_saps[m_dct].lgdtxt clipped, ", ", ga_dados_saps[m_dct].lgdnum using "<<<<<<<<<<"
   end if
   
   let ga_dados_saps[m_dct].brrnom       = l_dados_porto_saude.lclbrrnom
   let ga_dados_saps[m_dct].cidnom       = l_dados_porto_saude.cidnom
   let ga_dados_saps[m_dct].ufdcod       = l_dados_porto_saude.ufdcod
   
   let ga_dados_saps[m_dct].endcmp       = null
   let ga_dados_saps[m_dct].lclrefptotxt = l_dados_porto_saude.lclrefptotxt
   let ga_dados_saps[m_dct].lgdcep       = l_dados_porto_saude.lgdcep using "&&&&&"
   let ga_dados_saps[m_dct].lgdcepcmp    = l_dados_porto_saude.lgdcepcmp using "&&&"
   
   let ga_dados_saps[m_dct].dddcod       = l_dados_porto_saude.dddcod
   let ga_dados_saps[m_dct].lcltelnum    = l_dados_porto_saude.lcltelnum
   let ga_dados_saps[m_dct].celteldddcod = null
   let ga_dados_saps[m_dct].celtelnum    = null
   
   let ga_dados_saps[m_dct].corsus       = l_dados_porto_saude.corsus
   let ga_dados_saps[m_dct].cornom       = l_dados_porto_saude.cornom
   let ga_dados_saps[m_dct].prdnom       = "SAUDE"
   
   whenever error stop

end function

#-----------------------------------------------
function ctc68m00_dados_porto_cartoes(lr_param)
#-----------------------------------------------
   define lr_param        record
          cgccpfnum       like gsakpes.cgccpfnum
         ,cgcord          like gsakpes.cgcord
         ,cgccpfdig       like gsakpes.cgccpfdig
         ,pestip          char(01)
   end record
   
   define lr_cgccpfnumdig like fsckprpcrd.cgccpfnumdig
   
   define l_dados_cartoes record
          crdprpnom       like fsckprpcrd.crdprpnom
         ,corsus          like fsckprpcrd.corsus
         ,dddtel          like fsckprpcrd.dddtel
         ,telnum          like fsckprpcrd.dddtel
         ,dddcel          like fsckprpcrd.dddcel
         ,celnum          like fsckprpcrd.celnum
         ,endlgdtip       like fscmcliend.endlgdtip
         ,endlgd          like fscmcliend.endlgd
         ,endnum          like fscmcliend.endnum
         ,endbrr          like fscmcliend.endbrr
         ,endcid          like fscmcliend.endcid
         ,endcep          like fscmcliend.endcep
         ,endufd          like fscmcliend.endufd
         ,endcmp          like fscmcliend.endcmp
         ,docnum          like fsckprpdad.crdprpnum
   end record

   let lr_cgccpfnumdig = ffpfc073_formata_cgccpf(lr_param.cgccpfnum
                                                ,lr_param.cgcord
                                                ,lr_param.cgccpfdig)

   open cctc68m00013 using lr_cgccpfnumdig
   
   foreach cctc68m00013 into l_dados_cartoes.*
 
      if l_dados_cartoes.endlgd is null or l_dados_cartoes.endlgd = ' '
         then
         continue foreach
      end if
      
      let m_dct = m_dct + 1
      
      if m_dct > 20 then
         exit foreach
      end if
 
      execute pctc68m00014 into l_dados_cartoes.docnum using lr_cgccpfnumdig
 
      whenever error continue
   
      initialize m_txt_aux to null
      
      let ga_dados_saps[m_dct].docnum = l_dados_cartoes.docnum clipped
      let ga_dados_saps[m_dct].segnom = l_dados_cartoes.crdprpnom clipped
      let ga_dados_saps[m_dct].lgdtip = l_dados_cartoes.endlgdtip
      let ga_dados_saps[m_dct].lgdnom = l_dados_cartoes.endlgd
      let ga_dados_saps[m_dct].lgdtxt = l_dados_cartoes.endlgdtip clipped, " ", l_dados_cartoes.endlgd clipped
      let ga_dados_saps[m_dct].lgdnum = l_dados_cartoes.endnum

      if ga_dados_saps[m_dct].lgdnum is not null and ga_dados_saps[m_dct].lgdnum > 0
         then
         let ga_dados_saps[m_dct].lgdtxt = ga_dados_saps[m_dct].lgdtxt clipped, ", ", ga_dados_saps[m_dct].lgdnum using "<<<<<<<<<<"
      end if
      
      let ga_dados_saps[m_dct].brrnom       = l_dados_cartoes.endbrr
      let ga_dados_saps[m_dct].cidnom       = l_dados_cartoes.endcid
      let ga_dados_saps[m_dct].ufdcod       = l_dados_cartoes.endufd
      
      let ga_dados_saps[m_dct].endcmp       = l_dados_cartoes.endcmp
      let ga_dados_saps[m_dct].lclrefptotxt = null
      let ga_dados_saps[m_dct].lgdcep       = l_dados_cartoes.endcep[1,5] using "&&&&&"
      let ga_dados_saps[m_dct].lgdcepcmp    = l_dados_cartoes.endcep[6,8] using "&&&"
      
      let ga_dados_saps[m_dct].dddcod       = l_dados_cartoes.dddtel
      let ga_dados_saps[m_dct].lcltelnum    = l_dados_cartoes.telnum
      let ga_dados_saps[m_dct].celteldddcod = l_dados_cartoes.dddcel
      let ga_dados_saps[m_dct].celtelnum    = l_dados_cartoes.celnum
 
      let ga_dados_saps[m_dct].corsus       = l_dados_cartoes.corsus
      
      execute pctc68m00002 into ga_dados_saps[m_dct].cornom using ga_dados_saps[m_dct].corsus
      
      let ga_dados_saps[m_dct].prdnom = "CARTAO VISA"
      
      whenever error stop
      
    end foreach
    
    close cctc68m00013

end function

#-----------------------------------------------
function ctc68m00_dados_vist_prev(lr_param)
#-----------------------------------------------
   define lr_param   record
          cgccpfnum  like gsakpes.cgccpfnum
         ,cgcord     like gsakpes.cgcord
         ,cgccpfdig  like gsakpes.cgccpfdig
         ,pestip     char(01)
   end record
   
   define l_dados_VP record
          vstnumdig  like avlmlaudo.vstnumdig
         ,segnom     like avlmlaudo.segnom
         ,lgdtip     like avlmlaudo.lgdtip
         ,segendlgd  like avlmlaudo.segendlgd
         ,lgdnum     like avlmlaudo.lgdnum
         ,segendbrr  like avlmlaudo.segendbrr
         ,endcid     like avlmlaudo.endcid
         ,endufd     like avlmlaudo.endufd
         ,endcep     like avlmlaudo.endcep
         ,endcepcmp  like avlmlaudo.endcepcmp
         ,segtelddd  like avlmlaudo.segtelddd
         ,segteltxt  like avlmlaudo.segteltxt
         ,corsus     like avlmlaudo.corsus
         ,endcmpl    like avlmlaudo.endcmpl
   end record

   if lr_param.pestip = 'J' then
      open cctc68m00015 using lr_param.cgccpfnum, lr_param.cgcord, lr_param.cgccpfdig
   else
      open cctc68m00015 using lr_param.cgccpfnum, lr_param.cgccpfdig
   end if

   foreach cctc68m00015 into l_dados_VP.*

      if l_dados_VP.segendlgd is null or l_dados_VP.segendlgd = ' '
         then
         continue foreach
      end if
      
      let m_dct = m_dct + 1
      
      if m_dct > 20 then
         exit foreach
      end if
 
      whenever error continue
   
      initialize m_txt_aux to null
      
      let ga_dados_saps[m_dct].docnum = l_dados_VP.vstnumdig
      let ga_dados_saps[m_dct].segnom = l_dados_VP.segnom clipped
      let ga_dados_saps[m_dct].lgdtip = l_dados_VP.lgdtip
      let ga_dados_saps[m_dct].lgdnom = l_dados_VP.segendlgd
      let ga_dados_saps[m_dct].lgdtxt = l_dados_VP.lgdtip clipped, " ", l_dados_VP.segendlgd clipped
      let ga_dados_saps[m_dct].lgdnum = l_dados_VP.lgdnum
      
      if ga_dados_saps[m_dct].lgdnum is not null and ga_dados_saps[m_dct].lgdnum > 0
         then
         let ga_dados_saps[m_dct].lgdtxt = ga_dados_saps[m_dct].lgdtxt clipped, ", ", ga_dados_saps[m_dct].lgdnum using "<<<<<<<<<<"
      end if
      
      let ga_dados_saps[m_dct].brrnom       = l_dados_VP.segendbrr
      let ga_dados_saps[m_dct].cidnom       = l_dados_VP.endcid
      let ga_dados_saps[m_dct].ufdcod       = l_dados_VP.endufd
      
      let ga_dados_saps[m_dct].endcmp       = l_dados_VP.endcmpl
      let ga_dados_saps[m_dct].lclrefptotxt = null
      let ga_dados_saps[m_dct].lgdcep       = l_dados_VP.endcep    using "&&&&&"
      let ga_dados_saps[m_dct].lgdcepcmp    = l_dados_VP.endcepcmp using "&&&"
      
      let ga_dados_saps[m_dct].celteldddcod = null
      let ga_dados_saps[m_dct].celtelnum    = null
      let ga_dados_saps[m_dct].dddcod       = l_dados_VP.segtelddd
      let ga_dados_saps[m_dct].lcltelnum    = l_dados_VP.segteltxt
 
      let ga_dados_saps[m_dct].corsus       = l_dados_VP.corsus
      
      execute pctc68m00002 into ga_dados_saps[m_dct].cornom using ga_dados_saps[m_dct].corsus
      
      let ga_dados_saps[m_dct].prdnom = 'VISTORIA PREVIA'
      
      whenever error stop
      
   end foreach

end function

#-----------------------------------------------
function ctc68m00_dados_tela()
#-----------------------------------------------
   define l_arr  smallint
        , l_sel  integer
   
   define l_ctc68m00   array[30] of record
          prdnom       char(16)
         ,docnum       char(15)
         ,lgdtxt       char(65)
         ,cidnom       char(45)
         ,ufdcod       char(02)
   end record

   initialize l_ctc68m00 to null

   if ga_dct <= 0 then
      return 0
   end if

   let l_sel = 0
   
         display 'Endereços do CPF:'
   
   
   for l_arr = 1 to ga_dct
       let l_ctc68m00[l_arr].prdnom = ga_dados_saps[l_arr].prdnom
       let l_ctc68m00[l_arr].docnum = ga_dados_saps[l_arr].docnum
       let l_ctc68m00[l_arr].lgdtxt = ga_dados_saps[l_arr].lgdtxt
       let l_ctc68m00[l_arr].cidnom = ga_dados_saps[l_arr].cidnom
       let l_ctc68m00[l_arr].ufdcod = ga_dados_saps[l_arr].ufdcod
          
       # display 'ga_dados_saps[m_sel].segnom       :', ga_dados_saps[l_arr].segnom       
       # display 'ga_dados_saps[m_sel].lgdtip       :', ga_dados_saps[l_arr].lgdtip       
       # display 'ga_dados_saps[m_sel].lgdnom       :', ga_dados_saps[l_arr].lgdnom       
       # display 'ga_dados_saps[m_sel].lgdtxt       :', ga_dados_saps[l_arr].lgdtxt       
       # display 'ga_dados_saps[m_sel].lgdnum       :', ga_dados_saps[l_arr].lgdnum       
       # display 'ga_dados_saps[m_sel].brrnom       :', ga_dados_saps[l_arr].brrnom       
       # display 'ga_dados_saps[m_sel].cidnom       :', ga_dados_saps[l_arr].cidnom       
       # display 'ga_dados_saps[m_sel].ufdcod       :', ga_dados_saps[l_arr].ufdcod       
       # display 'ga_dados_saps[m_sel].endcmp       :', ga_dados_saps[l_arr].endcmp       
       # display 'ga_dados_saps[m_sel].lclrefptotxt :', ga_dados_saps[l_arr].lclrefptotxt 
       # display 'ga_dados_saps[m_sel].lgdcep       :', ga_dados_saps[l_arr].lgdcep       
       # display 'ga_dados_saps[m_sel].lgdcepcmp    :', ga_dados_saps[l_arr].lgdcepcmp    
       # display 'ga_dados_saps[m_sel].celteldddcod :', ga_dados_saps[l_arr].celteldddcod 
       # display 'ga_dados_saps[m_sel].celtelnum    :', ga_dados_saps[l_arr].celtelnum    
       # display 'ga_dados_saps[m_sel].dddcod       :', ga_dados_saps[l_arr].dddcod       
       # display 'ga_dados_saps[m_sel].lcltelnum    :', ga_dados_saps[l_arr].lcltelnum    
       # display 'ga_dados_saps[m_sel].segnom       :', ga_dados_saps[l_arr].segnom       
       # display 'ga_dados_saps[m_sel].corsus       :', ga_dados_saps[l_arr].corsus       
       # display 'ga_dados_saps[m_sel].cornom       :', ga_dados_saps[l_arr].cornom       
       # display 'ga_dados_saps[m_sel].vcllicnum    :', ga_dados_saps[l_arr].vcllicnum    
       # display 'ga_dados_saps[m_sel].vclcoddig    :', ga_dados_saps[l_arr].vclcoddig    
       # display 'ga_dados_saps[m_sel].vclanomdl    :', ga_dados_saps[l_arr].vclanomdl    
       # display 'ga_dados_saps[m_sel].vclcordes    :', ga_dados_saps[l_arr].vclcordes    
       # display 'ga_dados_saps[m_sel].vcldes       :', ga_dados_saps[l_arr].vcldes       
       
   end for

   open window w_ctc68m00 at 07,02 with form "ctc68m00"  attribute(form line 1, border)

   call set_count(ga_dct)

   display array  l_ctc68m00 TO s_ctc68m00.*

      on key(f17, control-c, interrupt)
         initialize ga_dados_saps to null
         let l_sel = 1
         error 'Selecao de endereco cancelada'
         exit display
   
      on key(f8)
         let l_sel = arr_curr()
         
      exit display
      
   end display

   let int_flag = false

   close window w_ctc68m00
   
   return l_sel

end function

#-----------------------------------------
function  ctc68m00_grava_sugest(lr_param)
#-----------------------------------------
   define lr_param     record
          atdsrvnum    like datrasitipsug.atdsrvnum
         ,atdsrvano    like datrasitipsug.atdsrvano
         ,asitipcod    like datrasitipsug.asitipcod
         ,usrtip       like datrasitipsug.atlusrtipcod
         ,empcod       like datrasitipsug.atlempcod
         ,funmat       like datrasitipsug.atlfunmatnum
   end record
   
   define l_msg_erro       char(200)
   
   whenever error continue
   insert into datrasitipsug ( asitipsugnum,atdsrvnum
                              ,atdsrvano   ,asitipcod
                              ,atddat      ,atlusrtipcod
                              ,atlempcod   ,atlfunmatnum)
                       VALUES (0           ,lr_param.atdsrvnum
                              ,lr_param.atdsrvano,lr_param.asitipcod
                              ,TODAY             ,lr_param.usrtip
                              ,lr_param.empcod   ,lr_param.funmat)
   whenever error stop
   
   if sqlca.sqlcode <> 0 then
      let l_msg_erro = 'Erro INSERT datrasitipsug / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
      call errorlog(l_msg_erro)
   end if
   
end function

