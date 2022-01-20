###############################################################################
# Nome do Modulo: CTS31M00                                            Roberto #
#                                                                             #
# Laudo - Funeral                                                    Mai/2007 #
###############################################################################
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# ........................................................................... #
#                                                                             #
#                          * * * ALTERACOES * * *                             #
#                                                                             #
# Data       Autor           Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 18/09/2007 Saulo, Meta     AS149675   Inclusao da popup cts31m00_popup() e  #
#                                       da funcao fvita008_beneficiario       #
#                                       Verificacao de carencia quando e      #
#                                       informado 1 no campo mrtcaucod        #
#-----------------------------------------------------------------------------#
# 07/07/2008 Andre Oliveira             Alteracao da chamada da funca  o      #
#                                       cts00m02_regulador para               #
#                                       ctc59m03_regulador                    #
# 13/08/2009 Sergio Burini  PSI 244236  Inclusão do Sub-Dairro                #
#-----------------------------------------------------------------------------#
# 05/01/2010 Amilton                    Projeto Sucursal smallint             #
# 21/10/2010 Alberto Rodrigues          Correcao de ^M                        #
#-----------------------------------------------------------------------------#
# 29/07/2013 Fabio, Fornax PSI-2013-06224/PR                                  #
#                          Identificacao no Acionamento do Laudo empresa SAPS #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
---> Previdencia - Funeral
globals "/homedsa/projetos/geral/globals/gpvia021.4gl"

define d_cts31m00 record
       servico         char (13)                       ,
       c24solnom       like datmligacao.c24solnom      ,
       nom             like datmservico.nom            ,
       doctxt          char (32)                       ,
       c24astcod       like datmligacao.c24astcod      ,
       c24astdes       char (45)                       ,
       sol             char (30)                       ,
       segdclprngracod like datmfnrsrv.segdclprngracod ,
       segdclprngrades char (12)                       ,
       cttteltxt       like datmfnrsrv.cttteltxt       ,
       flcnom          like datmfnrsrv.flcnom          ,
       flcidd          like datmfnrsrv.flcidd          ,
       obtdat          like datmfnrsrv.obtdat          ,
       mrtcaucod       like datmfnrsrv.mrtcaucod       ,
       mrtcaudes       char (12)                       ,
       libcrpflg       like datmfnrsrv.libcrpflg       ,
       segflcprngracod like datmfnrsrv.segflcprngracod ,
       segflcprngrades char (12)                       ,
       flcalt          like datmfnrsrv.flcalt          ,
       flcpso          like datmfnrsrv.flcpso          ,
       crpretlclcod    like datmfnrsrv.crpretlclcod    ,
       crpretlcldes    char (12)                       ,
       lgdnom          like datmlcl.lgdnom             ,
       lclbrrnom       like datmlcl.lclbrrnom          ,
       cidnom          like datmlcl.cidnom             ,
       ufdcod          like datmlcl.ufdcod             ,
       lclrefptotxt    like datmlcl.lclrefptotxt       ,
       endzon          like datmlcl.endzon             ,
       velflg          like datmfnrsrv.velflg          ,
       fnrtip          like datmfnrsrv.fnrtip          ,
       fnrdes          char (12)                       ,
       jzgflg          like datmfnrsrv.jzgflg          ,
       atdlibflg       like datmservico.atdlibflg      ,
       imdsrvflg       char (1)                        ,
       frmflg          char (1)                        ,
       frnasivlr       like datmfnrsrv.frnasivlr       ,
       endcmp          like datmlcl.endcmp
end record

define m_cts31m00end array[03] of record
    lclidttxt       like datmlcl.lclidttxt       ,
    cidnom          like datmlcl.cidnom          ,
    ufdcod          like datmlcl.ufdcod          ,
    brrnom          like datmlcl.brrnom          ,
    lclbrrnom       like datmlcl.lclbrrnom       ,
    endzon          like datmlcl.endzon          ,
    lgdtip          like datmlcl.lgdtip          ,
    lgdnom          like datmlcl.lgdnom          ,
    lgdnum          like datmlcl.lgdnum          ,
    lgdcep          like datmlcl.lgdcep          ,
    lgdcepcmp       like datmlcl.lgdcepcmp       ,
    lclltt          like datmlcl.lclltt          ,
    lcllgt          like datmlcl.lcllgt          ,
    lclrefptotxt    like datmlcl.lclrefptotxt    ,
    lclcttnom       like datmlcl.lclcttnom       ,
    dddcod          like datmlcl.dddcod          ,
    lcltelnum       like datmlcl.lcltelnum       ,
    c24lclpdrcod    like datmlcl.c24lclpdrcod    ,
    ofnnumdig       like sgokofi.ofnnumdig       ,
    celteldddcod    like datmlcl.celteldddcod    ,
    celtelnum       like datmlcl.celtelnum       ,
    endcmp          like datmlcl.endcmp
 end record

 define hist_cts31m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define m_cts31m00    record
    c24endtip         like datmlcl.c24endtip       ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    ligcvntip         like datmligacao.ligcvntip   ,
    atdvcltip         like datmservico.atdvcltip   ,
    vclcorcod         like datmservico.vclcorcod   ,
    vclcordes         char (11)                    ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    lignum            like datrligsrv.lignum       ,
    atdpvtretflg      like datmservico.atdpvtretflg,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdlibflg         like datmservico.atdlibflg   ,
    atdfnlflg         like datmservico.atdfnlflg   ,
    data              like datmservico.atddat      ,
    hora              like datmservico.atdhor      ,
    funmat            like datmservico.funmat      ,
    c24opemat         like datmservico.c24opemat   ,
    atdprscod         like datmservico.atdprscod   ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    c24nomctt         like datmservico.c24nomctt   ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    rglflg            smallint                     ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
    atdprinvlcod      like datmservico.atdprinvlcod,
    atdprinvldes      char (06)                    ,
    succod            like datrservapol.succod     ,
    ramcod            like datrservapol.ramcod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    empnom            like gabkemp.empnom          ,
    srvtipdes         like datksrvtip.srvtipdes    ,
    srvtipabvdes      like datksrvtip.srvtipabvdes ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    cortel            char(15)                     ,
    atdsrvseq         like datmsrvacp.atdsrvseq    ,
    asitipcod         like datmservico.asitipcod   ,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    srvprlflg         like datmservico.srvprlflg   ,
    atdrsdflg         like datmservico.atdrsdflg
 end record

 define mr_acnpst record
    atdetpdat   like datmsrvacp.atdetpdat,
    atdetphor   like datmsrvacp.atdetphor,
    empcod      like datmsrvacp.empcod,
    funmat      like datmsrvacp.funmat,
    funnom      like isskfunc.funnom,
    dptsgl      like isskfunc.dptsgl,
    pstcoddig   like datmsrvacp.pstcoddig,
    nomgrr      like dpaksocor.nomgrr,
    nomrazsoc   like dpaksocor.nomrazsoc,
    dddcod      like dpaksocor.dddcod,
    teltxt      like dpaksocor.teltxt,
    faxnum      like dpaksocor.faxnum,
    c24nomctt   like datmsrvacp.c24nomctt
 end record

 define m_emevia array[03] of record
        cod       like datmlcl.emeviacod
 end record

 define mr_fvita008 array[10] of record
           dpdnom       like vtamsegdpd.dpdnom       # Nome
          ,dpdnscdat    like vtamsegdpd.dpdnscdat    # data nascimento
          ,dpdprngracod like vtamsegdpd.dpdprngracod # codigo do grau de parentesco
          ,bnfprngrades like iddkdominio.cpodes      # Descricao do grau de parentesco
          ,cpfnum       like vtamsegdpd.cpfnum       # Numero do CPF do dependente
          ,cpfdig       like vtamsegdpd.cpfdig       # Numero do Digito do CPF
          ,doecrndiaqtd like vtamsegdpd.doecrndiaqtd # Quantidade dias carencia doenca
 end record


 define m_data         date                        ,
        m_hora         datetime hour to minute     ,
        m_traco        char(80)                    ,
        m_prompt_key   char(01)                    ,
        m_imptip       char(01)                    ,
        m_semdocto     smallint                    ,
        m_alterou      smallint                    ,
        m_prepare      smallint                    ,
        m_enviafax     smallint                    ,
        m_pageheader   smallint                    ,
        wsgpipe        char(80)

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define m_acesso_ind  smallint
 define m_psaerrcod smallint

#-----------------------------------------------------------------------------
function cts31m00_prepare()
#-----------------------------------------------------------------------------

define l_sql    char(500)

let l_sql = null

let l_sql =  "select srvtipdes,   "
            ,"       srvtipabvdes "
            ,"from datksrvtip     "
            ,"where atdsrvorg = ? "
prepare p_cts31m00_001 from l_sql
declare c_cts31m00_001 cursor for p_cts31m00_001

let l_sql =  "select c24astdes "
            ,"from datkassunto "
            ,"where c24astcod = ? "
prepare p_cts31m00_002 from l_sql
declare c_cts31m00_002 cursor for p_cts31m00_002

let l_sql =  "select "
            ,"atdsrvnum,"
            ,"atdsrvano,"
            ,"segdclprngracod,"
            ,"cttteltxt,"
            ,"flcnom,"
            ,"segflcprngracod,"
            ,"obtdat,"
            ,"mrtcaucod,"
            ,"fnrtip,"
            ,"libcrpflg,"
            ,"flcidd,"
            ,"crpretlclcod,"
            ,"velflg,"
            ,"jzgflg,"
            ,"frnasivlr,"
            ,"flcpso,"
            ,"flcalt "
            ,"from datmfnrsrv "
            ,"where atdsrvnum = ? "
            ,"and   atdsrvano = ? "
prepare p_cts31m00_003 from l_sql
declare c_cts31m00_003 cursor for p_cts31m00_003

let l_sql =  "select succod, "
            ," ramcod ,      "
            ," aplnumdig    "
            ,"from datrservapol "
            ,"where atdsrvnum = ? "
            ,"and   atdsrvano = ? "
prepare p_cts31m00_004 from l_sql
declare c_cts31m00_004 cursor for p_cts31m00_004

let l_sql = "select nom     , "
            ," c24solnom    , "
            ," corsus       , "
            ," cornom       , "
            ," atdlibflg    , "
            ," atdlibhor    , "
            ," atdlibdat    , "
            ," atdhorpvt    , "
            ," atddatprg    , "
            ," atdhorprg    , "
            ," atdpvtretflg , "
            ," atdvcltip    , "
            ,"atdprinvlcod  , "
            ,"asitipcod     , "
            ,"atdfnlflg       "
            ,"from datmservico "
            ,"where atdsrvnum = ? "
            ,"and   atdsrvano = ? "
prepare p_cts31m00_005 from l_sql
declare c_cts31m00_005 cursor for p_cts31m00_005


let l_sql = "select count(*)"
            ,"from datmlcl "
            ,"where atdsrvnum = ? "
            ,"and   atdsrvano = ? "
            ,"and   c24endtip = ? "
prepare p_cts31m00_006 from l_sql
declare c_cts31m00_006 cursor for p_cts31m00_006

let l_sql = "select lignum "
           ,"from datmligfrm  "
           ,"where lignum = ? "
prepare p_cts31m00_007 from l_sql
declare c_cts31m00_007 cursor for p_cts31m00_007

let l_sql = "select max(atdsrvseq) "
           ,"from datmsrvacp  "
           ,"where atdsrvnum = ? "
           ,"and   atdsrvano = ? "
prepare p_cts31m00_008 from l_sql
declare c_cts31m00_008 cursor for p_cts31m00_008

let l_sql = "select atdetpcod "
           ,"from datmsrvacp  "
           ,"where atdsrvnum = ? "
           ,"and   atdsrvano = ? "
           ,"and   atdsrvseq = ? "
prepare p_cts31m00_009 from l_sql
declare c_cts31m00_009 cursor for p_cts31m00_009

let l_sql =
    "select acp.atdetpdat,",
          " acp.atdetphor,",
          " acp.empcod,",
          " acp.funmat,",
          " acp.pstcoddig,",
          " acp.atdmotnom,",
          " acp.atdvclsgl,",
          " acp.c24nomctt,",
          " acp.socvclcod,",
          " acp.srrcoddig,",
          " acp.envtipcod",
     " from datmsrvacp acp",
    " where acp.atdsrvnum = ?",
      " and acp.atdsrvano = ?",
      " and acp.atdetpcod in (3,10)",
      " and acp.atdsrvseq = (select max(acpmax.atdsrvseq)",
                             " from datmsrvacp acpmax",
                            " where acpmax.atdsrvnum = acp.atdsrvnum",
                              " and acpmax.atdsrvano = acp.atdsrvano)"
prepare p_cts31m00_010 from l_sql
declare c_cts31m00_010 cursor for p_cts31m00_010

let l_sql = "select funnom,",
                  " dptsgl",
             " from isskfunc",
            " where empcod = ?",
              " and funmat = ?"
prepare p_cts31m00_011 from l_sql
declare c_cts31m00_011 cursor for p_cts31m00_011

let l_sql = "select nomgrr,",
                  " nomrazsoc,",
                  " teltxt,",
                  " faxnum",
             " from dpaksocor",
            " where pstcoddig = ?"
prepare p_cts31m00_012 from l_sql
declare c_cts31m00_012 cursor for p_cts31m00_012

let m_prepare = true

end function

#-----------------------------------------------------------------------------
function cts31m00()
#-----------------------------------------------------------------------------

define x smallint
define l_input  smallint
define l_con    smallint
define l_mod    smallint

for x=1 to 3
    initialize m_cts31m00end[x].* to null
    initialize m_emevia[x].*   to null
end for

initialize  d_cts31m00.*     to  null
initialize  m_cts31m00.*     to  null
initialize  hist_cts31m00.*  to  null
let l_input      = null
let l_mod        = null
let l_con        = 0


let m_cts31m00.atdsrvorg = 18
let m_cts31m00.ligcvntip = 0
let m_cts31m00.asitipcod = 57
let m_cts31m00.srvprlflg = "N"
let m_alterou            = 0
let g_documento.atdsrvorg = m_cts31m00.atdsrvorg

if m_prepare is null or
   m_prepare <> true then
   call cts31m00_prepare()
end if


call cts40g03_data_hora_banco(2)
     returning m_data,
               m_hora

       # Se for uma consulta ou alteracao Recupero os
       # dados do Laudo Funeral

       if g_documento.acao = "CON" or
          g_documento.acao = "ALT" then
          # Atribuir a Variavel global CRM
          if g_atd_siebel = 1 then
             let g_atd_siebel_num = null
          end if
          let  l_con = consulta_cts31m00(g_documento.atdsrvorg ,
                                         g_documento.atdsrvnum ,
                                         g_documento.atdsrvano)

          if g_documento.acao = "ALT" then
               if m_cts31m00.atdetpcod <> 1 and
                  m_cts31m00.atdetpcod <> 2 then
                     let g_documento.acao = "CON"
               end if
          else
               let m_alterou = 1
          end if

       end if

       # Chamo a Funcao para o Input dos Dados

       if l_con = 0 then

           let l_input = input_cts31m00()

       end if

       # Se for Alteracao atualizo os dados digitados

       if g_documento.acao = "ALT" then


           if l_input = 0 then
                  begin work
                  let l_mod = modifica_cts31m00( g_documento.atdsrvnum ,
                                                 g_documento.atdsrvano )

                  if l_mod <> 0 then
                      rollback work
                  else
                      commit work
                  end if

           end if
       end if

       # Chamo a Tela para a digitacao do Historico

       if g_documento.acao is not null or
          g_documento.acao <> "INC" then

          if l_input = 0 then
               call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                             g_issk.funmat        , m_data  , m_hora)
               let g_rec_his = true
          end if
       end if





     return
end function

#-----------------------------------------------------------------------------
function input_cts31m00()
#-----------------------------------------------------------------------------

define lr_retorno     record
       erro           smallint,
       mensagem       char(60),
       cpodes         like iddkdominio.cpodes
end record

define l_indice     smallint
define l_retorno    smallint
define l_volta      smallint
define l_gravou     smallint
define l_confirma   char(1)
define l_tmp_flg    smallint
define l_erro       smallint
define l_acesso     smallint

define lr_ret_popup record
          dpdnom       like vtamsegdpd.dpdnom
         ,doecrndiaqtd like vtamsegdpd.doecrndiaqtd
end record

define l_grauprt char(20)

define l_carencia     date
      ,l_cont         smallint
      ,l_flhqtd       like vtamsegurocmp.flhqtd
      ,l_doecrndiaqtd like vtamsegurocmp.doecrndiaqtd
      ,l_isbnf        smallint
      ,l_tipo         char(02)   ---> Funeral
      ,l_ramcod       smallint   ---> Funeral
      ,l_empcod       dec(2,0)   ---> Funeral

initialize lr_ret_popup, mr_fvita008 to null

let l_grauprt      = " "
let l_carencia     = null
let l_cont         = 1
let l_flhqtd       = null
let l_doecrndiaqtd = null
let l_isbnf        = false
let l_ramcod       = null  --->Funeral
let l_empcod       = null  --->Funeral

let l_retorno    = null
let l_confirma   = null
let l_tmp_flg    = null
let l_erro       = null
let l_volta      = 0
let l_gravou     = 0
let m_semdocto   = 0
let l_tipo       = null   ---> Funeral

open window cts31m00 at 04,02 with form "cts31m00"
                      attribute(border,form line 1)
display "(F1)Help(F3)Refer(F4)Enderecos(F5)Espelho(F6)Hist(F7)Imprime(F9)Conclui" to msgfun


     if g_documento.prporg    is not null  and
        g_documento.prpnumdig is not null  then
        let d_cts31m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                         " ", g_documento.prpnumdig using "<<<<<<<& &"
     end if


     if g_documento.succod    is not null  and
        g_documento.ramcod    is not null  and
        g_documento.aplnumdig is not null  then
          let d_cts31m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                           " ", g_documento.ramcod    using "&&&&",
                                           " ", g_documento.aplnumdig using "<<<<<<<& &"
     end if

     let d_cts31m00.c24solnom = g_documento.solnom

     if (g_documento.prporg     is null or g_documento.prporg    = 0 ) and
        (g_documento.prpnumdig  is null or g_documento.prpnumdig = 0 ) and
        (g_documento.aplnumdig  is null or g_documento.aplnumdig = 0 ) then
             let m_semdocto = 1
     else

         # Recupero os Dados do Segurado
         if g_documento.prporg     is null and
            g_documento.prpnumdig  is null then
            let g_documento.prporg    = g_prporg
            let g_documento.prpnumdig = g_prpnumdig
         end if


         call rec_dados_seg(g_documento.ramcod     ,
                            g_documento.succod     ,
                            g_documento.aplnumdig  ,
                            g_documento.prporg     ,
                            g_documento.prpnumdig  )
         returning d_cts31m00.nom   ,
                   m_cts31m00.corsus,
                   m_cts31m00.cornom,
                   m_cts31m00.cortel,
                   l_erro

         if l_erro <> 0 then
             error "Dados da Apolice nao encontrado!"
             close window cts31m00
             return 1
         end if

     end if

     # Recupero o Assunto e o Tipo de Servico

     open c_cts31m00_001 using m_cts31m00.atdsrvorg

     whenever error continue
     fetch c_cts31m00_001  into d_cts31m00.c24astdes  ,
                              d_cts31m00.c24astcod

     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           error "Tipo de Servico nao encontrado !"
        else
           error "Erro SELECT c_cts31m00_001 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
        end if
        close c_cts31m00_001
        close window cts31m00
        return 1
     end if

     close c_cts31m00_001

while true

     initialize lr_retorno.* to null

     display by name d_cts31m00.*
     display by name d_cts31m00.c24solnom attribute (reverse)


     input by name d_cts31m00.sol              ,
                   d_cts31m00.segdclprngracod   ,
                   d_cts31m00.segdclprngrades   ,
                   d_cts31m00.cttteltxt         ,
                   d_cts31m00.flcnom            ,
                   d_cts31m00.flcidd            ,
                   d_cts31m00.obtdat            ,
                   d_cts31m00.mrtcaucod         ,
                   d_cts31m00.mrtcaudes         ,
                   d_cts31m00.libcrpflg         ,
                   d_cts31m00.segflcprngracod   ,
                   d_cts31m00.segflcprngrades   ,
                   d_cts31m00.flcalt            ,
                   d_cts31m00.flcpso            ,
                   d_cts31m00.crpretlclcod      ,
                   d_cts31m00.crpretlcldes      ,
                   d_cts31m00.lgdnom            ,
                   d_cts31m00.lclbrrnom         ,
                   d_cts31m00.cidnom            ,
                   d_cts31m00.ufdcod            ,
                   d_cts31m00.lclrefptotxt      ,
                   d_cts31m00.endzon            ,
                   d_cts31m00.velflg            ,
                   d_cts31m00.fnrtip            ,
                   d_cts31m00.fnrdes            ,
                   d_cts31m00.jzgflg            ,
                   d_cts31m00.atdlibflg         ,
                   d_cts31m00.imdsrvflg         ,
                   d_cts31m00.frmflg            ,
                   d_cts31m00.frnasivlr
      without defaults


      before field sol
         display by name d_cts31m00.sol        attribute (reverse)

      after field sol
          display by name d_cts31m00.sol

          # Se for Consulta nao deixo o usuario alterar os dados
          # do Laudo Funeral

          if g_documento.acao = "CON" then


             let l_confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                        " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                        "E INFORME AO  ** CONTROLE DE TRAFEGO **")


              call cts02m03(m_cts31m00.atdfnlflg,
                            d_cts31m00.imdsrvflg,
                            m_cts31m00.atdhorpvt,
                            m_cts31m00.atddatprg,
                            m_cts31m00.atdhorprg,
                            m_cts31m00.atdpvtretflg)
                  returning m_cts31m00.atdhorpvt,
                            m_cts31m00.atddatprg,
                            m_cts31m00.atdhorprg,
                            m_cts31m00.atdpvtretflg

              if d_cts31m00.frmflg = "S" then
                 call cts11g00(m_cts31m00.lignum)
              end if

             let l_volta = 1
             exit while
          end if

          if d_cts31m00.sol is null then
              error "Nome Solicitante deve ser Informado!"
              next field sol
          end if

      before field segdclprngracod
         display by name d_cts31m00.segdclprngracod   attribute (reverse)


      after field segdclprngracod
          display by name d_cts31m00.segdclprngracod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sol
          end if

           # Chamo o popup ou carrego os dados automaticamente

          if d_cts31m00.segdclprngracod is null then
               call cto00m07("datmfuneral")
               returning  d_cts31m00.segdclprngracod ,
                          d_cts31m00.segdclprngrades

               if d_cts31m00.segdclprngracod is null then
                  next field segdclprngracod
               end if

          else
               call cto00m07_busca_descricao(d_cts31m00.segdclprngracod,
                                             "'datmfuneral'")
               returning lr_retorno.*

               if lr_retorno.erro <> 1 then
                  error lr_retorno.mensagem
                  next field segdclprngracod
               else
                  let d_cts31m00.segdclprngrades = lr_retorno.cpodes
               end if

          end if

         display by name d_cts31m00.segdclprngracod
         display by name d_cts31m00.segdclprngrades


      before field cttteltxt
      display by name d_cts31m00.cttteltxt        attribute (reverse)

      after field cttteltxt
          display by name d_cts31m00.cttteltxt

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field segdclprngracod
          end if

     before field flcnom
     display by name d_cts31m00.flcnom        attribute (reverse)

     after field flcnom
         display by name d_cts31m00.flcnom
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field cttteltxt
         end if
         let g_saf_diascarencia = ""
         ## Beneficiario esta somente na proposta Alberto
         if g_documento.prpnumdig is null then
            let g_documento.prpnumdig = g_prpnumdig
            let g_documento.prporg    = g_prporg
         end if

         call fvita008_beneficiario(g_documento.ramcod
                                   ,g_documento.succod
                                   ,g_documento.aplnumdig
                                   ,g_documento.prporg
                                   ,g_documento.prpnumdig
                                   ,g_segnumdig
                                   ,g_cgccpfnum
                                   ,g_cgccpfdig )
            returning l_erro
                     ,l_tipo ---> Funeral
                     ,l_flhqtd
                     ,l_doecrndiaqtd
                     ,l_empcod   ---> Funeral
                     ,l_ramcod   ---> Funeral
                     ,mr_fvita008[1].*
                     ,mr_fvita008[2].*
                     ,mr_fvita008[3].*
                     ,mr_fvita008[4].*
                     ,mr_fvita008[5].*
                     ,mr_fvita008[6].*
                     ,mr_fvita008[7].*
                     ,mr_fvita008[8].*
                     ,mr_fvita008[9].*
                     ,mr_fvita008[10].*

         if (d_cts31m00.flcnom is null or
             d_cts31m00.flcnom = " " ) then
             if g_parceira = 1 then
                error 'Informe um nome.'
                next field flcnom
             end if
             if mr_fvita008[1].dpdnom is null or
                mr_fvita008[1].dpdnom = " " then
                error 'Informe um nome.'
                next field flcnom
             else
                call cts31m00_popup()
                   returning lr_ret_popup.dpdnom
                            ,lr_ret_popup.doecrndiaqtd

                if lr_ret_popup.dpdnom is null or
                   lr_ret_popup.dpdnom = ' '   then
                   error 'Informe um nome.'
                   next field flcnom
                else
                   let d_cts31m00.flcnom  = lr_ret_popup.dpdnom
                   let g_saf_diascarencia = lr_ret_popup.doecrndiaqtd
                end if
             end if
         else

            ##let l_isbnf = false

            ##for l_cont = 1 to 10
            ##   if d_cts31m00.flcnom = mr_fvita008[l_cont].dpdnom then
            ##      let l_isbnf = true
            ##      exit for
            ##   end if
            ##end for
            ##if not l_isbnf then
            ##   error 'Informe um nome valido.'
            ##   next field flcnom
            ##else
            ##   let g_saf_diascarencia = mr_fvita008[l_cont].doecrndiaqtd
            ##end if
         end if

         display by name d_cts31m00.flcnom

     before field flcidd
     display by name d_cts31m00.flcidd         attribute (reverse)

     after field flcidd
         display by name d_cts31m00.flcidd

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field flcnom
         end if

         if d_cts31m00.flcidd  is null then
             error "Idade deve ser Informada!"
             next field flcidd
         end if

         if d_cts31m00.flcidd  > 150 then
             error "Idade nao pode ser Maior que 150"
             next field flcidd
         end if



     before field obtdat
     display by name d_cts31m00.obtdat         attribute (reverse)

     after field obtdat
         display by name d_cts31m00.obtdat

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field flcidd
         end if

         if d_cts31m00.obtdat  is null then
             error "Data do Obito deve ser Informada!"
             next field obtdat
         end if

         if d_cts31m00.obtdat  > m_data then
             error "Data do Obito nao pode ser Maior que a Data Atual!"
             next field obtdat
         end if




     before field mrtcaucod
        display by name d_cts31m00.mrtcaucod    attribute (reverse)

     after field mrtcaucod
         display by name d_cts31m00.mrtcaucod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field obtdat
         end if


          # Chamo o popup ou carrego os dados automaticamente

         if d_cts31m00.mrtcaucod  is null then
              call cto00m07("c24caumrt")
              returning  d_cts31m00.mrtcaucod  ,
                         d_cts31m00.mrtcaudes

              if d_cts31m00.mrtcaucod is null then
                 next field mrtcaucod
              end if

         else
              call cto00m07_busca_descricao(d_cts31m00.mrtcaucod ,
                                            "'c24caumrt'")
              returning lr_retorno.*

              if lr_retorno.erro <> 1 then
                 error lr_retorno.mensagem
                 next field mrtcaucod
              else
                 let d_cts31m00.mrtcaudes  = lr_retorno.cpodes
              end if

         end if
         ## Funeral funcionario
         if g_documento.cgccpfnum is not null or
            g_documento.funmat    is not null then
            let g_saf_diascarencia = 0
         end if
         if g_saf_diascarencia is null and
            m_semdocto         <> 1    then
            if g_parceira = 1 then
               let g_saf_diascarencia = 30
            else
               let g_saf_diascarencia = 180
            end if
         end if

         if d_cts31m00.mrtcaucod = 1 then
            let l_carencia = d_cts31m00.obtdat - g_saf_diascarencia
            if l_carencia < g_emsdat then
               error 'Apolice encontra-se em periodo de carencia'
               next field mrtcaucod
            end if
         end if

        display by name d_cts31m00.mrtcaucod
        display by name d_cts31m00.mrtcaudes

     before field libcrpflg
     display by name d_cts31m00.libcrpflg         attribute (reverse)

     after field libcrpflg
         display by name d_cts31m00.libcrpflg

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field mrtcaucod
         end if

         if d_cts31m00.libcrpflg  is null or
            d_cts31m00.libcrpflg  <> 'S'  and
            d_cts31m00.libcrpflg  <> 'N'  then
             error "Informe <S>im ou <N>ao!"
             next field libcrpflg
         end if

     before field segflcprngracod
        display by name d_cts31m00.segflcprngracod    attribute (reverse)
        ##let d_cts31m00.segflcprngracod = 0
     after field segflcprngracod
         display by name d_cts31m00.segflcprngracod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field libcrpflg
         end if
         if g_parceira = 1 then
            let l_grauprt = "c24depsafRENNER"
         else
            let l_grauprt = "c24depsaf"
         end if


         # Chamo o popup ou carrego os dados automaticamente
         if d_cts31m00.segflcprngracod is null then
            ##call cto00m07("c24depsaf")
            ##returning  d_cts31m00.segflcprngracod ,
            ##           d_cts31m00.segflcprngrades


            call cto00m07( l_grauprt )
            returning  d_cts31m00.segflcprngracod ,
                       d_cts31m00.segflcprngrades

            if d_cts31m00.segflcprngracod is null then
               next field segflcprngracod
            end if
            if d_cts31m00.segflcprngrades is null then
               let d_cts31m00.segflcprngrades = "O PROPRIO"
            end if
         else
              ##call cto00m07_busca_descricao(d_cts31m00.segflcprngracod ,
              ##                              "'c24depsaf'")

              let l_grauprt = "'", l_grauprt clipped , "'"

              call cto00m07_busca_descricao( d_cts31m00.segflcprngracod ,
                                             l_grauprt)
              returning lr_retorno.*

              if lr_retorno.erro <> 1 then
                 error lr_retorno.mensagem
                 next field segflcprngracod
              else
                 let d_cts31m00.segflcprngrades  = lr_retorno.cpodes
              end if
         end if

         display by name d_cts31m00.segflcprngracod
         display by name d_cts31m00.segflcprngrades

      before field flcalt
      display by name d_cts31m00.flcalt         attribute (reverse)

      after field flcalt
          display by name d_cts31m00.flcalt

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field segflcprngracod
          end if

          if d_cts31m00.flcalt  is null then
              error "Altura do Falecido deve ser Informada!"
              next field flcalt
          end if

      before field flcpso
      display by name d_cts31m00.flcpso          attribute (reverse)

      after field flcpso
          display by name d_cts31m00.flcpso

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field flcalt
          end if

          if d_cts31m00.flcpso   is null then
              error "Peso do Falecido deve ser Informado!"
              next field flcpso
          end if

      before field crpretlclcod
         display by name d_cts31m00.crpretlclcod    attribute (reverse)

      after field crpretlclcod
          display by name d_cts31m00.crpretlclcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field flcpso
          end if

          # Chamo o popup ou carrego os dados automaticamente

          if d_cts31m00.crpretlclcod  is null then
               call cto00m07("c24lclret")
               returning  d_cts31m00.crpretlclcod  ,
                          d_cts31m00.crpretlcldes

               if d_cts31m00.crpretlclcod is null then
                  next field crpretlclcod
               end if


          else
               call cto00m07_busca_descricao(d_cts31m00.crpretlclcod ,
                                             "'c24lclret'")
               returning lr_retorno.*

               if lr_retorno.erro <> 1 then
                  error lr_retorno.mensagem
                  next field crpretlclcod
               else
                  let d_cts31m00.crpretlcldes  = lr_retorno.cpodes
               end if

          end if

          display by name d_cts31m00.crpretlclcod
          display by name d_cts31m00.crpretlcldes

          # Chamo a funcao para a digitacao do endereco

         let m_cts31m00.c24endtip = 1
         let l_indice = 1
         let l_retorno = cts31m00_chama_end(l_indice)

         #------------------------------------------------------------------------------
         # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
         #------------------------------------------------------------------------------
         if g_documento.lclocodesres = "S" then
            let m_cts31m00.atdrsdflg = "S"
         else
            let m_cts31m00.atdrsdflg = "N"
         end if
         # Carrego as variaveis



         let d_cts31m00.lgdnom        =  m_cts31m00end[l_indice].lgdnom clipped,',',m_cts31m00end[l_indice].lgdnum clipped
         let d_cts31m00.lclbrrnom     =  m_cts31m00end[l_indice].lclbrrnom
         let d_cts31m00.cidnom        =  m_cts31m00end[l_indice].cidnom
         let d_cts31m00.ufdcod        =  m_cts31m00end[l_indice].ufdcod
         let d_cts31m00.endzon        =  m_cts31m00end[l_indice].endzon
         let d_cts31m00.lclrefptotxt  =  m_cts31m00end[l_indice].lclrefptotxt
         let d_cts31m00.endcmp        =  m_cts31m00end[l_indice].endcmp

         # Carrego os dados na tela

         display by name d_cts31m00.lgdnom
         display by name d_cts31m00.lclbrrnom
         display by name d_cts31m00.cidnom
         display by name d_cts31m00.ufdcod
         display by name d_cts31m00.endzon
         display by name d_cts31m00.lclrefptotxt
         display by name d_cts31m00.endcmp

         # Se algum dado do endereco estiver nulo nao prossigo com o fluxo normal

         if l_retorno = 1 then
            next field crpretlclcod
         end if



      before field velflg
         let d_cts31m00.velflg = "N"
         display by name d_cts31m00.velflg        attribute (reverse)


      after field velflg
          display by name d_cts31m00.velflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field crpretlclcod
          end if

          if d_cts31m00.velflg  is null or
             d_cts31m00.velflg  <> 'S'  and
             d_cts31m00.velflg  <> 'N'  then
              error "Informe <S>im ou <N>ao!"
              next field velflg
          end if

          # Se for velorio chamo a funcao para a digitacao de endereco

          if d_cts31m00.velflg = 'S' then
             let m_cts31m00.c24endtip = 2
             let l_indice = 2
             let l_retorno = cts31m00_chama_end(l_indice)

            # Se algum dado do endereco estiver nulo nao prossigo com o fluxo normal

             if l_retorno = 1 then
                next field velflg
             end if

          else

             # Se o atendente mudar o valor da flag limpo as variaveis

             if m_cts31m00end[2].cidnom is not null then
                initialize m_cts31m00end[2].* to null
                initialize m_emevia[2].*   to null
             end if
          end if

       before field fnrtip
       display by name d_cts31m00.fnrtip        attribute (reverse)

       after field fnrtip
           display by name d_cts31m00.fnrtip

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field velflg
           end if

           if d_cts31m00.fnrtip  is null then
                call cto00m07("c24fnrtip")
                returning  d_cts31m00.fnrtip  ,
                           d_cts31m00.fnrdes

               if d_cts31m00.fnrtip is null then
                  next field fnrtip
               end if


           else
                call cto00m07_busca_descricao(d_cts31m00.fnrtip ,
                                              "'c24fnrtip'")
                returning lr_retorno.*

                if lr_retorno.erro <> 1 then
                   error lr_retorno.mensagem
                   next field fnrtip
                else
                   let d_cts31m00.fnrdes  = lr_retorno.cpodes
                end if

           end if

          display by name d_cts31m00.fnrtip
          display by name d_cts31m00.fnrdes

          # Se for tipo 1 (Cremacao) chamo a funcao para a digitacao de endereco

          if d_cts31m00.fnrtip = 1 then

             let m_cts31m00.c24endtip = 3
             let l_indice = 3
             let l_retorno = cts31m00_chama_end(l_indice)

            # Se algum dado do endereco estiver nulo nao prossigo com o fluxo normal

             if l_retorno = 1 then
                next field fnrtip
             end if

             if d_cts31m00.velflg = "N" then
                  let m_cts31m00end[2].* = m_cts31m00end[3].*
                  let m_emevia[2].*   = m_emevia[3].*
             end if

          else

             # Se o atendente mudar o valor do tipo limpo as variaveis

             if m_cts31m00end[3].cidnom is not null then
                initialize m_cts31m00end[3].* to null
                initialize m_emevia[3].*   to null
             end if
          end if

          # Se for Sepultamento carrego o mesmo

          if d_cts31m00.fnrtip = 2 then

              # Se for Sepultamento carrego o mesmo endereco do velorio

              if d_cts31m00.velflg = "S" then

                       if m_cts31m00end[2].cidnom is not null then
                             let m_cts31m00end[3].* = m_cts31m00end[2].*
                             let m_emevia[3].*   = m_emevia[2].*
                       end if
               else

                         let m_cts31m00.c24endtip = 3
                         let l_indice = 3
                         let l_retorno = cts31m00_chama_end(l_indice)

                        # Se algum dado do endereco estiver nulo nao prossigo com o fluxo normal

                         if l_retorno = 1 then
                            next field fnrtip
                         end if

                         let m_cts31m00end[2].* = m_cts31m00end[3].*
                         let m_emevia[2].*   = m_emevia[3].*
              end if

          end if

      before field jzgflg

          display by name d_cts31m00.jzgflg         attribute (reverse)

          if d_cts31m00.fnrtip = 1 then
             let d_cts31m00.jzgflg = "N"
             display by name d_cts31m00.jzgflg
             next field atdlibflg
          end if


      after field jzgflg
         display by name d_cts31m00.jzgflg

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field fnrtip
         end if


         if d_cts31m00.jzgflg   is null or
            d_cts31m00.jzgflg   <> 'S'  and
            d_cts31m00.jzgflg   <> 'N'  then
             error "Informe <S>im ou <N>ao!"
             next field jzgflg
         end if

      before field atdlibflg
          let d_cts31m00.atdlibflg = "S"
          display by name d_cts31m00.atdlibflg         attribute (reverse)

      after field atdlibflg
          display by name d_cts31m00.atdlibflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then

             if d_cts31m00.fnrtip = 1 then
                next field fnrtip
             else
                next field jzgflg
             end if
          end if

          if d_cts31m00.atdlibflg  is null or
             d_cts31m00.atdlibflg  <> 'S'  and
             d_cts31m00.atdlibflg  <> 'N'  then
              error "Informe <S>im ou <N>ao!"
              next field atdlibflg
          end if


          if d_cts31m00.atdlibflg  =  "S"  then
             call cts40g03_data_hora_banco(2)
                 returning m_data, m_hora
             let m_cts31m00.atdlibhor = m_hora
             let m_cts31m00.atdlibdat = m_data
          else
             initialize m_cts31m00.atdlibhor to null
             initialize m_cts31m00.atdlibdat to null
          end if


      before field imdsrvflg
          let d_cts31m00.imdsrvflg = "S"
          display by name d_cts31m00.imdsrvflg         attribute (reverse)

      after field imdsrvflg
          display by name d_cts31m00.imdsrvflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdlibflg
          end if

          if d_cts31m00.imdsrvflg   is null or
             d_cts31m00.imdsrvflg   <> 'S'  and
             d_cts31m00.imdsrvflg   <> 'N'  then
              error "Informe <S>im ou <N>ao!"
              next field imdsrvflg
          end if

          # Chamo a funcao para o Preenchimento do Servico
          # programado ou previsto

           call cts02m03(m_cts31m00.atdfnlflg,
                         d_cts31m00.imdsrvflg,
                         m_cts31m00.atdhorpvt,
                         m_cts31m00.atddatprg,
                         m_cts31m00.atdhorprg,
                         m_cts31m00.atdpvtretflg)
               returning m_cts31m00.atdhorpvt,
                         m_cts31m00.atddatprg,
                         m_cts31m00.atdhorprg,
                         m_cts31m00.atdpvtretflg

           if d_cts31m00.imdsrvflg = "S"     then
              if m_cts31m00.atdhorpvt is null        then
                 error " Previsao de Horas nao Informada para Servico Imediato!"
                 next field imdsrvflg
              end if
           else
              if m_cts31m00.atddatprg   is null        or
                 m_cts31m00.atddatprg   = " "          or
                 m_cts31m00.atdhorprg   is null        then
                 error " Faltam Dados para Servico Programado!"
                 next field imdsrvflg
              else
                 let m_cts31m00.atdprinvlcod  = 3
                 select cpodes
                 into m_cts31m00.atdprinvldes
                 from iddkdominio
                 where cponom = "atdprinvlcod"
                 and cpocod = m_cts31m00.atdprinvlcod
              end if
          end if

          # Se tiver agenda aciono a reguladora

           if d_cts31m00.imdsrvflg = "S"  then
              let m_cts31m00.rglflg = ctc59m02 ( m_cts31m00end[1].cidnom  ,
                                                 m_cts31m00end[1].ufdcod  ,
                                                 m_cts31m00.atdsrvorg     ,
                                                 m_cts31m00.asitipcod     ,
                                                 m_data                   ,
                                                 m_hora                   ,
                                                 false)
           else
              let m_cts31m00.rglflg = ctc59m02( m_cts31m00end[1].cidnom  ,
                                                m_cts31m00end[1].ufdcod  ,
                                                m_cts31m00.atdsrvorg     ,
                                                m_cts31m00.asitipcod     ,
                                                m_cts31m00.atddatprg     ,
                                                m_cts31m00.atdhorprg     ,
                                                false)
           end if

           if m_cts31m00.rglflg <> 0 then
              let d_cts31m00.imdsrvflg = "N"
              call ctc59m03 ( m_cts31m00end[1].cidnom            ,
                              m_cts31m00end[1].ufdcod            ,
                              m_cts31m00.atdsrvorg               ,
                              m_cts31m00.asitipcod               ,
                              m_data                             ,
                              m_hora)
                   returning  m_cts31m00.atddatprg               ,
                              m_cts31m00.atdhorprg
              next field imdsrvflg
           end if

           if g_documento.atdsrvnum is not null  and
              g_documento.atdsrvano is not null  then

              # Para abater regulador
              let m_cts31m00.rglflg = ctc59m03_regulador( g_documento.atdsrvnum,
                                                          g_documento.atdsrvano)
           end if


       before field frmflg
           let d_cts31m00.frmflg  = "N"
           display by name d_cts31m00.frmflg         attribute (reverse)

       after field frmflg
           display by name d_cts31m00.frmflg

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field imdsrvflg
           end if

           if d_cts31m00.frmflg   is null or
              d_cts31m00.frmflg   <> 'S'  and
              d_cts31m00.frmflg   <> 'N'  then
               error "Informe <S>im ou <N>ao!"
               next field frmflg
           end if

           if d_cts31m00.frmflg = "S" then
              if d_cts31m00.atdlibflg = "N"  then
                 error " Nao e Possivel Registrar Servico nao Liberado via Formulario!"
                 next field atdlibflg
              end if

              # Chamo o formulario

              call cts02m05(m_cts31m00.atdsrvorg) returning m_cts31m00.data     ,
                                                            m_cts31m00.hora     ,
                                                            m_cts31m00.funmat   ,
                                                            m_cts31m00.cnldat   ,
                                                            m_cts31m00.atdfnlhor,
                                                            m_cts31m00.c24opemat,
                                                            m_cts31m00.atdprscod

              if m_cts31m00.hora      is null  or
                 m_cts31m00.data      is null  or
                 m_cts31m00.funmat    is null  or
                 m_cts31m00.cnldat    is null  or
                 m_cts31m00.atdfnlhor is null  or
                 m_cts31m00.c24opemat is null  or
                 m_cts31m00.atdprscod is null  then
                 error " Faltam Dados para Entrada via Formulario!"
                 next field frmflg
              end if

              let m_cts31m00.atdlibhor    = m_cts31m00.hora
              let m_cts31m00.atdlibdat    = m_cts31m00.data
              let m_cts31m00.atdfnlflg    = "S"
              let m_cts31m00.atdetpcod    =  4
              let d_cts31m00.imdsrvflg    = "S"
              let m_cts31m00.atdhorpvt    = "00:00"
              let m_cts31m00.atdpvtretflg = "N"
              let m_cts31m00.atdprinvlcod =  3
              let d_cts31m00.atdlibflg    = 'S'

              display by name d_cts31m00.imdsrvflg
              display by name d_cts31m00.atdlibflg
           else
              initialize m_cts31m00.hora     ,
                         m_cts31m00.data     ,
                         m_cts31m00.funmat   ,
                         m_cts31m00.cnldat   ,
                         m_cts31m00.atdfnlhor,
                         m_cts31m00.c24opemat,
                         m_cts31m00.atdfnlflg,
                         m_cts31m00.atdetpcod,
                         m_cts31m00.atdprscod to null
           end if

       # Se for Sem Documento abro para a digitacao do valor

       if m_semdocto = 1  then
            next field frnasivlr
       else
            exit input
       end if


       before field frnasivlr
           display by name d_cts31m00.frnasivlr         attribute (reverse)

       after field frnasivlr
           display by name d_cts31m00.frnasivlr
           ## Funeral funcionario
           if g_documento.cgccpfnum is not null or
              g_documento.funmat    is not null then
              let l_confirma = cts08g01("A","N","" ,
                                         "Para este atendimento, comunique a ",
                                         "coordenação para o acionamento da ",
                                         "assistente social da Porto Seguro."
                                        )
           end if
           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field frmflg
           end if

      on key (interrupt)

      if g_documento.atdsrvnum is null  or
         g_documento.atdsrvano is null  then
         let l_confirma = cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")

         if l_confirma  =  "S"   then
            let g_atd_siebel_num = null
            let l_tmp_flg = ctc61m02_criatmp(2,
                                             g_documento.atdsrvnum,
                                             g_documento.atdsrvano)
            if l_tmp_flg = 1 then
               error "Problemas na tabela temporaria!"
            end if

            let l_volta = 1
            exit while

         end if
      else
           exit while
      end if

      on key (F1)
         if d_cts31m00.c24astcod is not null then
            call ctc58m00_vis(d_cts31m00.c24astcod)
         end if

     on key (F3)
        call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

     on key (F4)

        call cts31m00b()

     on key (F5)

        # Exibir espelho da apolice
        let g_monitor.horaini = current ## Flexvision
        call cta01m12_espelho(g_documento.ramcod
                             ,g_documento.succod
                             ,g_documento.aplnumdig
                             ,""
                             ,g_documento.prporg
                             ,g_documento.prpnumdig
                             ,"","","","","","",""
                             ,g_documento.ciaempcod)

     on key (F6)
        if g_documento.atdsrvnum is null then
           call cts10m02 (hist_cts31m00.*) returning hist_cts31m00.*
        else
           call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                         g_issk.funmat        , m_data  ,m_hora)
        end if

     on key (F7)

         if g_documento.atdsrvnum is null  then
            error " Impressao somente com cadastramento do servico!"
         else
            call imprime_cts31m00(g_documento.atdsrvorg ,
                                  g_documento.atdsrvnum ,
                                  g_documento.atdsrvano )
         end if


      on key (F9)

        if g_documento.atdsrvnum is not null and
           g_documento.atdsrvano is not null then

             if m_alterou = 1  then

                  let l_confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                             " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                             "E INFORME AO  ** CONTROLE DE TRAFEGO **")

             else


                 if d_cts31m00.atdlibflg = "N" then
                       error " Servico nao liberado!"
                 else
                    call cta00m06_acionamento(g_issk.dptsgl)
                    returning l_acesso

                    if l_acesso = true then

                       call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 0 )

                        let l_retorno = rec_etapa_cts31m00(m_cts31m00.atdsrvnum ,
                                                           m_cts31m00.atdsrvano )


                        if l_retorno = 0 then
                              if m_cts31m00.atdetpcod <> 1 and
                                 m_cts31m00.atdetpcod <> 2 then
                                    let g_documento.acao = "CON"
                              else
                                    let g_documento.acao = "ALT"
                              end if
                              next field sol
                        end if
                      else
                         call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 2 )
                    end if
                 end if
            end if
        end if


   end input

   # Gero o Laudo Funeral

   if g_documento.acao = "INC"  then

       let l_gravou = inclui_cts31m00()

       if l_gravou = 1 then
          let l_volta = 1
          exit while
       else
          exit while
       end if

   else
       exit while
   end if

  end while
  # Atribuir a Variavel global CRM
  if g_documento.acao = 'INC' and g_atd_siebel = 1 then
     if g_documento.atdsrvnum is not null or
        g_documento.atdsrvnum <> 0 then
        let g_atd_siebel_num = g_documento.atdsrvorg using "&&",
                               "/", g_documento.atdsrvnum using "&&&&&&&",
                               "-", g_documento.atdsrvano using "&&"
     end if
  end if

close window cts31m00

   return l_volta

end function

#---------------------------------------------------------------------------
function cts31m00_chama_end(l_param)
#---------------------------------------------------------------------------

define l_param    smallint
define l_retorno  char(1)
define l_retorno2 smallint

let l_retorno2 = 0

         # Chamo a tela de enderecos

         let m_cts31m00end[l_param].lclbrrnom = m_subbairro[l_param].lclbrrnom
         let m_acesso_ind = false
         call cta00m06_acesso_indexacao_aut(m_cts31m00.atdsrvorg)
              returning m_acesso_ind
         if m_acesso_ind = false then
            call cts06g03(m_cts31m00.c24endtip          ,
                          m_cts31m00.atdsrvorg          ,
                          m_cts31m00.ligcvntip          ,
                          m_data                        ,
                          m_hora                        ,
                          m_cts31m00end[l_param].*      ,
                          hist_cts31m00.*               ,
                          m_emevia[l_param].cod         )
               returning  m_cts31m00end[l_param].*      ,
                          l_retorno                     ,
                          hist_cts31m00.*               ,
                          m_emevia[l_param].cod
         else
             call cts06g11(m_cts31m00.c24endtip          ,
                           m_cts31m00.atdsrvorg          ,
                           m_cts31m00.ligcvntip          ,
                           m_data                        ,
                           m_hora                        ,
                           m_cts31m00end[l_param].*      ,
                           hist_cts31m00.*               ,
                           m_emevia[l_param].cod         )
                returning  m_cts31m00end[l_param].*      ,
                           l_retorno                     ,
                           hist_cts31m00.*               ,
                           m_emevia[l_param].cod
         end if

         let m_subbairro[l_param].lclbrrnom = m_cts31m00end[l_param].lclbrrnom

         call cts06g10_monta_brr_subbrr(m_cts31m00end[l_param].brrnom,
                                        m_cts31m00end[l_param].lclbrrnom)
              returning m_cts31m00end[l_param].lclbrrnom

         if m_cts31m00end[l_param].lgdnom    is null or
            m_cts31m00end[l_param].lclbrrnom is null or
            m_cts31m00end[l_param].cidnom    is null or
            m_cts31m00end[l_param].ufdcod    is null then
                 error "Dados Completo do Endereço nao Informado!"
                 initialize m_cts31m00end[l_param].* to null
                 let l_retorno2 = 1
         end if

return l_retorno2


end function

#---------------------------------------------------------------------------
function inclui_cts31m00()
#---------------------------------------------------------------------------

define ws record
       lignum      like datmligacao.lignum        ,
       atdsrvnum   like datmservico.atdsrvnum     ,
       atdsrvano   like datmservico.atdsrvano     ,
       codigosql   integer                        ,
       msg         char(80)                    ,
       tabname     like systables.tabname         ,
       caddat      like datmligfrm.caddat         ,
       cadhor      like datmligfrm.cadhor         ,
       cademp      like datmligfrm.cademp         ,
       cadmat      like datmligfrm.cadmat         ,
       etpfunmat   like datmsrvacp.funmat         ,
       atdetpdat   like datmsrvacp.atdetpdat      ,
       atdetphor   like datmsrvacp.atdetphor
end record

define x integer

initialize  ws.* to null


         if  m_cts31m00.data is null  then
             let m_cts31m00.data   = m_data
             let m_cts31m00.hora   = m_hora
             let m_cts31m00.funmat = g_issk.funmat
         end if

        if  d_cts31m00.frmflg = "S"  then
            call cts40g03_data_hora_banco(2)
                 returning ws.caddat, ws.cadhor
            let ws.cademp = g_issk.empcod
            let ws.cadmat = g_issk.funmat
        else
            initialize ws.caddat to null
            initialize ws.cadhor to null
            initialize ws.cademp to null
            initialize ws.cadmat to null
        end if

        if  m_cts31m00.atdfnlflg is null  then
            let m_cts31m00.atdfnlflg = "N"
        end if

        if m_cts31m00.atdprinvlcod is null then
           let m_cts31m00.atdprinvlcod = 3
        end if

       #------------------------------------------------------------------------------
       # Busca numeracao ligacao / servico
       #------------------------------------------------------------------------------

       begin work

       call cts10g03_numeracao( 2,"" )
            returning ws.lignum   ,
                      ws.atdsrvnum,
                      ws.atdsrvano,
                      ws.codigosql,
                      ws.msg

       if  ws.codigosql <> 0  then
           let ws.msg = "CTS31M00 - ",ws.msg
           call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
           prompt "" for char m_prompt_key
           rollback work
           return 1
       else
           commit work
       end if

       let g_documento.lignum = ws.lignum

   ## zerar proposta caso tenha achado a apolice
   if g_documento.aplnumdig <> 0 and
      g_documento.aplnumdig is not null then
      let g_documento.prporg    = null
      let g_documento.prpnumdig = null
   end if

   # Grava ligacao e servico
   if g_documento.c24soltipcod is null or
      g_documento.solnom       is null then
      let g_documento.solnom       = d_cts31m00.sol
      let g_documento.c24soltipcod = 3
   end if
   begin work

   call cts10g00_ligacao ( g_documento.lignum      ,
                           m_cts31m00.data         ,
                           m_cts31m00.hora         ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           g_issk.funmat           ,
                           m_cts31m00.ligcvntip    ,
                           g_c24paxnum             ,
                           ws.atdsrvnum            ,
                           ws.atdsrvano            ,
                           "","","",""             ,
                           g_documento.succod      ,
                           g_documento.ramcod      ,
                           g_documento.aplnumdig   ,
                           0,0                     ,
                           g_documento.prporg      ,
                           g_documento.prpnumdig   ,
                           "","","","","",""       ,
                           ws.caddat               ,
                           ws.cadhor               ,
                           ws.cademp               ,
                           ws.cadmat               )

        returning ws.tabname,
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"

       prompt "" for char m_prompt_key
       rollback work
       return 1
   end if

   call cts10g02_grava_servico( ws.atdsrvnum             ,
                                ws.atdsrvano             ,
                                g_documento.soltip       ,
                                g_documento.solnom       ,
                                " "                      ,
                                g_issk.funmat            ,
                                d_cts31m00.atdlibflg     ,
                                m_cts31m00.atdlibhor     ,
                                m_cts31m00.atdlibdat     ,
                                m_cts31m00.data          ,
                                m_cts31m00.hora          ,
                                ""                       ,
                                m_cts31m00.atdhorpvt     ,
                                m_cts31m00.atddatprg     ,
                                m_cts31m00.atdhorprg     ,
                                0                        ,
                                ""                       ,
                                ""                       ,
                                m_cts31m00.atdprscod     ,
                                ""                       ,
                                m_cts31m00.atdfnlflg     ,
                                m_cts31m00.atdfnlhor     ,
                                m_cts31m00.atdrsdflg     ,
                                ""                       ,
                                ""                       ,
                                m_cts31m00.c24opemat     ,
                                d_cts31m00.sol           ,
                                "","",""                 ,
                                m_cts31m00.corsus        ,
                                m_cts31m00.cornom        ,
                                m_cts31m00.cnldat        ,
                                ""                       ,
                                ""                       ,
                                m_cts31m00.atdpvtretflg  ,
                                ""                       ,
                                m_cts31m00.asitipcod     ,
                                ""                       ,
                                ""                       ,
                                m_cts31m00.srvprlflg     ,
                                ""                       ,
                                m_cts31m00.atdprinvlcod  ,
                                m_cts31m00.atdsrvorg    )
        returning ws.tabname,
                  ws.codigosql

   if  ws.codigosql  <>  0  then
       error " Erro (", ws.codigosql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char m_prompt_key
       return 1
   end if



   # Grava locais de (1) Local de Retirada do Corpo  / (2) Velorio / (3) Funeral

      for x = 1 to 3

          if m_cts31m00end[x].cidnom is not null then

                let ws.codigosql = processa_local_cts31m00('I'         ,
                                                           ws.atdsrvnum,
                                                           ws.atdsrvano,
                                                           x           )

                if  ws.codigosql <> 0  then
                  rollback work
                  return 1
                end if

         end if
      end for



      # Grava Etapas do Acompanhamento


        if  m_cts31m00.atdetpcod is null  then
            if  d_cts31m00.atdlibflg = "S"  then
                let m_cts31m00.atdetpcod = 1
                let ws.etpfunmat = m_cts31m00.funmat
                let ws.atdetpdat = m_cts31m00.atdlibdat
                let ws.atdetphor = m_cts31m00.atdlibhor
            else
                let m_cts31m00.atdetpcod = 2
                let ws.etpfunmat = m_cts31m00.funmat
                let ws.atdetpdat = m_cts31m00.data
                let ws.atdetphor = m_cts31m00.hora
            end if
        else
           let ws.codigosql = cts10g04_insere_etapa( ws.atdsrvnum    ,
                                                     ws.atdsrvano    ,
                                                     1               ,
                                                     " "             ,
                                                     " "             ,
                                                     " "             ,
                                                     m_cts31m00.srrcoddig )

            if  ws.codigosql <> 0  then
                error " Erro (", sqlca.sqlcode, ") na gravacao da",
                      " etapa de acompanhamento (1). AVISE A INFORMATICA!"
                rollback work
                prompt "" for char m_prompt_key
                return 1
            end if

            let ws.atdetpdat = m_cts31m00.cnldat
            let ws.atdetphor = m_cts31m00.atdfnlhor
            let ws.etpfunmat = m_cts31m00.c24opemat
        end if

        let ws.codigosql = cts10g04_insere_etapa( ws.atdsrvnum        ,
                                                  ws.atdsrvano        ,
                                                  m_cts31m00.atdetpcod,
                                                  m_cts31m00.atdprscod,
                                                  m_cts31m00.c24nomctt,
                                                  " "                 ,
                                                  m_cts31m00.srrcoddig )

        if ws.codigosql <>  0  then
            error " Erro (", sqlca.sqlcode, ") na gravacao da",
                  " etapa de acompanhamento (2). AVISE A INFORMATICA!"
            rollback work
            prompt "" for char m_prompt_key
            return 1

        end if


        # Grava Relacionamento Servico / Apolice


        if  g_documento.aplnumdig is not null  and
            g_documento.aplnumdig <> 0         then

            call cts10g02_grava_servico_apolice(ws.atdsrvnum         ,
                                                ws.atdsrvano         ,
                                                g_documento.succod   ,
                                                g_documento.ramcod   ,
                                                g_documento.aplnumdig,
                                                0,
                                                0)
            returning ws.tabname,
                      ws.codigosql
            if  ws.codigosql <> 0  then
                error " Erro (", ws.codigosql, ") na gravacao do",
                      " relacionamento servico x apolice. AVISE A INFORMATICA!"
                rollback work
                prompt "" for char m_prompt_key
                return 1

            end if
        end if



      # Grava historico do servico


      let ws.codigosql = cts10g02_historico( ws.atdsrvnum     ,
                                             ws.atdsrvano     ,
                                             m_cts31m00.data  ,
                                             m_cts31m00.hora  ,
                                             m_cts31m00.funmat,
                                             hist_cts31m00.*   )

      if ws.codigosql <>  0  then
          error " Erro (", sqlca.sqlcode, ") na gravacao do",
                " historico do servico. AVISE A INFORMATICA!"
          rollback work
          prompt "" for char m_prompt_key
          return 1

      end if


      # Grava os dados do Funeral

      let ws.codigosql = cts31m00_grava_fun(ws.atdsrvnum     ,
                                            ws.atdsrvano     )

      if ws.codigosql <>  0  then
          error " Erro (", sqlca.sqlcode, ") na gravacao dos",
                " dados do funeral. AVISE A INFORMATICA!"
          rollback work
          prompt "" for char m_prompt_key
          return 1

      end if


      # Exibe o numero do servico

      let d_cts31m00.servico = m_cts31m00.atdsrvorg using "&&",
                               "/", ws.atdsrvnum   using "&&&&&&&",
                               "-", ws.atdsrvano   using "&&"

      display d_cts31m00.servico to servico attribute (reverse)

      let g_documento.atdsrvnum = ws.atdsrvnum
      let g_documento.atdsrvano = ws.atdsrvano
      call cts40g03_data_hora_banco(2)
           returning m_data,
                     m_hora


      error  " Verifique o numero do servico e tecle ENTER! "
      prompt "" for char m_prompt_key
      error " Inclusao efetuada com sucesso! "

      commit work
      # Ponto de acesso apos a gravacao do laudo
      call cts00g07_apos_grvlaudo(ws.atdsrvnum,
                                  ws.atdsrvano)


    return 0

end function

#---------------------------------------------------------------------------
function cts31m00_grava_fun(l_param)
#---------------------------------------------------------------------------

define l_param record
  atdsrvnum   like datmservico.atdsrvnum     ,
  atdsrvano   like datmservico.atdsrvano
end record


      insert into datmfnrsrv (atdsrvnum            ,
                              atdsrvano            ,
                              segdclprngracod      ,
                              cttteltxt            ,
                              flcnom               ,
                              segflcprngracod      ,
                              obtdat               ,
                              mrtcaucod            ,
                              fnrtip               ,
                              libcrpflg            ,
                              flcidd               ,
                              crpretlclcod         ,
                              velflg               ,
                              jzgflg               ,
                              frnasivlr            ,
                              flcpso               ,
                              flcalt               ,
                              fnrenddgtflg         )
       values (l_param.atdsrvnum             ,
               l_param.atdsrvano             ,
               d_cts31m00.segdclprngracod    ,
               d_cts31m00.cttteltxt          ,
               d_cts31m00.flcnom             ,
               d_cts31m00.segflcprngracod    ,
               d_cts31m00.obtdat             ,
               d_cts31m00.mrtcaucod          ,
               d_cts31m00.fnrtip             ,
               d_cts31m00.libcrpflg          ,
               d_cts31m00.flcidd             ,
               d_cts31m00.crpretlclcod       ,
               d_cts31m00.velflg             ,
               d_cts31m00.jzgflg             ,
               d_cts31m00.frnasivlr          ,
               d_cts31m00.flcpso             ,
               d_cts31m00.flcalt             ,
               "N"                           )


         if  sqlca.sqlcode <> 0  then
             return sqlca.sqlcode
         end if

   return 0


end function

#---------------------------------------------------------------------------
function rec_cts31m00(l_param)
#---------------------------------------------------------------------------

define l_param record
   atdsrvorg like datmservico.atdsrvorg   ,
   atdsrvnum like datmservico.atdsrvnum   ,
   atdsrvano like datmservico.atdsrvano
end record

define ret record
      lignum     like datrligsrv.lignum       ,
      c24endtip  like datmlcl.c24endtip
end record

define lr_retorno     record
       erro           smallint,
       mensagem       char(60),
       cpodes         like iddkdominio.cpodes
end record

define idx smallint


initialize d_cts31m00.* to null
initialize ret.*        to null
initialize lr_retorno.* to null

let m_cts31m00.atdsrvnum = l_param.atdsrvnum
let m_cts31m00.atdsrvano = l_param.atdsrvano

 # Recupero a Empresa

 call cty14g00_empresa(1,1)
      returning lr_retorno.erro    ,
                lr_retorno.mensagem,
                m_cts31m00.empnom

 # Recupero o Assunto e o Tipo de Servico

 open c_cts31m00_001 using l_param.atdsrvorg

 whenever error continue
 fetch c_cts31m00_001  into  d_cts31m00.c24astdes  ,
                           d_cts31m00.c24astcod
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       error "Tipo de Servico nao encontrado !"
    else
       error "Erro SELECT c_cts31m00_001 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
    end if
    close c_cts31m00_001
    return 1
 end if

 close c_cts31m00_001

 let m_cts31m00.srvtipabvdes = d_cts31m00.c24astcod

 # Recupero a Descricao do Produto

 open c_cts31m00_002 using d_cts31m00.c24astcod

 whenever error continue
 fetch c_cts31m00_002  into m_cts31m00.srvtipdes

 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       error "Assunto nao encontrado !"
    else
       error "Erro SELECT c_cts31m00_002 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
    end if
    close c_cts31m00_002
    return 1
 end if

 close c_cts31m00_002

 # Recupero os Dados do Laudo Funeral


 open c_cts31m00_003 using l_param.atdsrvnum ,
                         l_param.atdsrvano

 whenever error continue
 fetch c_cts31m00_003  into l_param.atdsrvnum           ,
                          l_param.atdsrvano           ,
                          d_cts31m00.segdclprngracod  ,
                          d_cts31m00.cttteltxt        ,
                          d_cts31m00.flcnom           ,
                          d_cts31m00.segflcprngracod  ,
                          d_cts31m00.obtdat           ,
                          d_cts31m00.mrtcaucod        ,
                          d_cts31m00.fnrtip           ,
                          d_cts31m00.libcrpflg        ,
                          d_cts31m00.flcidd           ,
                          d_cts31m00.crpretlclcod     ,
                          d_cts31m00.velflg           ,
                          d_cts31m00.jzgflg           ,
                          d_cts31m00.frnasivlr        ,
                          d_cts31m00.flcpso           ,
                          d_cts31m00.flcalt

 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       error "Laudo do Funeral nao encontrado !"
    else
       error "Erro SELECT c_cts31m00_003 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
    end if
    close c_cts31m00_003
    return 1
 end if

 close c_cts31m00_003

 # Recupero o numero da Ligacao

 let m_cts31m00.lignum = cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

 call cts20g01_docto(m_cts31m00.lignum)
       returning g_documento.succod,
                 g_documento.ramcod,
                 g_documento.aplnumdig,
                 g_documento.itmnumdig,
                 g_documento.edsnumref,
                 g_documento.prporg,
                 g_documento.prpnumdig,
                 g_documento.fcapacorg,
                 g_documento.fcapacnum,
                 g_documento.itaciacod

 if (g_documento.prporg     is  null or g_documento.prporg = 0 )     and
    (g_documento.prpnumdig  is  null or g_documento.prpnumdig = 0 )  and
    (g_documento.aplnumdig   is  null or g_documento.aplnumdig = 0 ) then
    let m_semdocto = 1
 else

    # Recupero os dados do Segurado

    call rec_dados_seg(g_documento.ramcod     ,
                       g_documento.succod     ,
                       g_documento.aplnumdig  ,
                       g_documento.prporg     ,
                       g_documento.prpnumdig  )
    returning d_cts31m00.nom   ,
              m_cts31m00.corsus,
              m_cts31m00.cornom,
              m_cts31m00.cortel,
              lr_retorno.erro
    if  lr_retorno.erro <> 0 then
        error "Dados da Apolice nao encontrado!" sleep 2
        return 1
    end if
 end if


 # Verifico se essa Ligacao foi digitada no Formulario

 open c_cts31m00_007 using m_cts31m00.lignum

 whenever error continue
 fetch c_cts31m00_007  into ret.lignum

 whenever error stop


 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
          let d_cts31m00.frmflg = "N"
    else
       error "Erro SELECT c_cts31m00_007 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
       close c_cts31m00_007
       return 1
    end if
 else
      let d_cts31m00.frmflg = "S"
 end if

 close c_cts31m00_007

 # Recupero a Etapa do Servico

 let lr_retorno.erro = rec_etapa_cts31m00(l_param.atdsrvnum , l_param.atdsrvano )


 if lr_retorno.erro <> 0 then
    return 1
 end if


 # Recupero a Relacao de Parantesco com o Segurado

 call cto00m07_busca_descricao(d_cts31m00.segdclprngracod,
                               "'datmfuneral'")
 returning lr_retorno.*

 if lr_retorno.erro <> 1 then
    error lr_retorno.mensagem
    return 1
 else
    let d_cts31m00.segdclprngrades = lr_retorno.cpodes
 end if

  # Recupero o Grau de Parentesco

  call cto00m07_busca_descricao(d_cts31m00.segflcprngracod ,
                                "'c24depsaf'")
  returning lr_retorno.*

  if lr_retorno.erro <> 1 then
     error lr_retorno.mensagem
     return 1
  else
     let d_cts31m00.segflcprngrades  = lr_retorno.cpodes
  end if

  # Recupero a Causa da Morte

  call cto00m07_busca_descricao(d_cts31m00.mrtcaucod ,
                                "'c24caumrt'")
  returning lr_retorno.*

  if lr_retorno.erro <> 1 then
     error lr_retorno.mensagem
     return 1
  else
     let d_cts31m00.mrtcaudes   = lr_retorno.cpodes
  end if

  # Recupero o Tipo de Funeral

  call cto00m07_busca_descricao(d_cts31m00.fnrtip ,
                                "'c24fnrtip'" )
  returning lr_retorno.*

  if lr_retorno.erro <> 1 then
     error lr_retorno.mensagem
     return 1
  else
     let d_cts31m00.fnrdes   = lr_retorno.cpodes
  end if

  # Recupero o Local de Retirada do Corpo

  call cto00m07_busca_descricao(d_cts31m00.crpretlclcod ,
                                "'c24lclret'" )
  returning lr_retorno.*

  if lr_retorno.erro <> 1 then
     error lr_retorno.mensagem
     return 1
  else
     let d_cts31m00.crpretlcldes   = lr_retorno.cpodes
  end if


  # Recupero a Apolice

  if m_semdocto = 0 then

     let m_cts31m00.succod    = g_documento.succod
     let m_cts31m00.ramcod    = g_documento.ramcod
     let m_cts31m00.aplnumdig = g_documento.aplnumdig

     #    open c_cts31m00_004 using l_param.atdsrvnum ,
     #                            l_param.atdsrvano
     #
     #    whenever error continue
     #    fetch c_cts31m00_004  into m_cts31m00.succod   ,
     #                             m_cts31m00.ramcod   ,
     #                             m_cts31m00.aplnumdig
     #
     #    whenever error stop
     #
     #    if sqlca.sqlcode <> 0 then
     #       if sqlca.sqlcode = notfound then
     #          error "Apolice nao encontrada !"
     #       else
     #          error "Erro SELECT c_cts31m00_004 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
     #       end if
     #       close c_cts31m00_004
     #       return 1
     #    end if
     #
     #    close c_cts31m00_004

  end if

  # Recupero os Dados do Servico

  open c_cts31m00_005 using l_param.atdsrvnum ,
                          l_param.atdsrvano

  whenever error continue
  fetch c_cts31m00_005  into d_cts31m00.sol           ,
                           d_cts31m00.c24solnom     ,
                           m_cts31m00.corsus        ,
                           m_cts31m00.cornom        ,
                           d_cts31m00.atdlibflg     ,
                           m_cts31m00.atdlibhor     ,
                           m_cts31m00.atdlibdat     ,
                           m_cts31m00.atdhorpvt     ,
                           m_cts31m00.atddatprg     ,
                           m_cts31m00.atdhorprg     ,
                           m_cts31m00.atdpvtretflg  ,
                           m_cts31m00.atdvcltip     ,
                           m_cts31m00.atdprinvlcod  ,
                           m_cts31m00.asitipcod     ,
                           m_cts31m00.atdfnlflg


  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        error "Nome do Solicitante nao encontrado !"
     else
        error "Erro SELECT c_cts31m00_005 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
     end if
     close c_cts31m00_005
     return 1
  end if

  close c_cts31m00_005

  # Recupero os Enderecos


  for idx = 1 to 3

         let ret.c24endtip = idx

         call ctx04g00_local_completo(l_param.atdsrvnum  ,
                                      l_param.atdsrvano  ,
                                      ret.c24endtip)
                            returning m_cts31m00end[idx].lclidttxt    ,
                                      m_cts31m00end[idx].lgdtip       ,
                                      m_cts31m00end[idx].lgdnom       ,
                                      m_cts31m00end[idx].lgdnum       ,
                                      m_cts31m00end[idx].brrnom       ,
                                      m_cts31m00end[idx].lclbrrnom    ,
                                      m_cts31m00end[idx].cidnom       ,
                                      m_cts31m00end[idx].ufdcod       ,
                                      m_cts31m00end[idx].lclrefptotxt ,
                                      m_cts31m00end[idx].endzon       ,
                                      m_cts31m00end[idx].lgdcep       ,
                                      m_cts31m00end[idx].lgdcepcmp    ,
                                      m_cts31m00end[idx].dddcod       ,
                                      m_cts31m00end[idx].lcltelnum    ,
                                      m_cts31m00end[idx].lclcttnom    ,
                                      m_cts31m00end[idx].c24lclpdrcod ,
                                      lr_retorno.erro,
                                      m_cts31m00end[idx].endcmp
         # PSI 244589 - Inclusão de Sub-Bairro - Burini
         let m_subbairro[idx].lclbrrnom = m_cts31m00end[idx].lclbrrnom
         call cts06g10_monta_brr_subbrr(m_cts31m00end[idx].brrnom,
                                        m_cts31m00end[idx].lclbrrnom)
              returning m_cts31m00end[idx].lclbrrnom

  end for


  let d_cts31m00.lgdnom        = m_cts31m00end[1].lgdnom clipped , ',',m_cts31m00end[1].lgdnum clipped
  let d_cts31m00.lclbrrnom     = m_cts31m00end[1].lclbrrnom
  let d_cts31m00.cidnom        = m_cts31m00end[1].cidnom
  let d_cts31m00.ufdcod        = m_cts31m00end[1].ufdcod
  let d_cts31m00.lclrefptotxt  = m_cts31m00end[1].lclrefptotxt
  let d_cts31m00.endzon        = m_cts31m00end[1].endzon

   if m_cts31m00.atdhorpvt is not null  or
      m_cts31m00.atdhorpvt =  "00:00"   then
      let d_cts31m00.imdsrvflg = "S"
   end if

   if m_cts31m00.atddatprg is not null  then
      let d_cts31m00.imdsrvflg = "N"
   end if

  let d_cts31m00.servico = l_param.atdsrvorg using "&&",
                           "/", l_param.atdsrvnum   using "&&&&&&&",
                           "-", l_param.atdsrvano   using "&&"

  return 0

end function

#---------------------------------------------------------------------------------
function imprime_cts31m00(l_param)
#---------------------------------------------------------------------------------

  define l_param record
     atdsrvorg like datmservico.atdsrvorg   ,
     atdsrvnum like datmservico.atdsrvnum   ,
     atdsrvano like datmservico.atdsrvano
  end record
  
  define ws record
         srv     char(30),
         doc     char(30),
         arq     char(10),
         impflg  smallint,
         impnom  char(08),
         comando char(100)
  end record
  
  define idx          smallint
  define l_c24enddes  char(30)
  define l_con        smallint
  define l_libcrpdes  char(3)
  define l_lograd     char(55)
  
  initialize ws.*         to null
  initialize m_cts31m00.* to null
  initialize m_psaerrcod to null
  
  let l_con       = null
  let l_c24enddes = null
  let l_libcrpdes = null
  let l_lograd    = null
  let m_traco     = "--------------------------------------------------------------------------------"
  let m_imptip    = null
  let m_enviafax  = false
  let m_pageheader = false
  
  for idx=1 to 3
      initialize m_cts31m00end[idx].* to null
      initialize m_emevia[idx].*   to null
  end for

  let l_con = consulta_cts31m00(l_param.atdsrvorg ,
                                l_param.atdsrvnum ,
                                l_param.atdsrvano)

  if l_con = 0 then

     # Selecao da impressora
     call fun_print_seleciona (g_issk.dptsgl, "")
          returning ws.impflg, ws.impnom
     
     if ws.impflg = 0  then
        error " Departamento/impressora nao cadastrada!"
        return
     else
        if ws.impnom is null  then
           error " Uma impressora deve ser selecionada!"
           return
        else
           call fun_print_tipo (ws.impnom)
           returning m_imptip
        end if
     end if
     
     let ws.srv =  l_param.atdsrvorg using "<<#","/",
                   l_param.atdsrvnum using "<<<<<<<<#" ,"-",
                   l_param.atdsrvano using "<<<#"
     
     let ws.doc = m_cts31m00.succod using "<<<<#", "/", #"<<<#","/", projeto succod
                  m_cts31m00.ramcod using "<<<#"clipped,"/",
                  m_cts31m00.aplnumdig using "<<<<<<<<#"
     
     #let ws.arq = "cts31m00.txt"
     let wsgpipe = "lp -sd ", ws.impnom
     
     call dadossrv_cts31m00(l_param.atdsrvnum,
                            l_param.atdsrvano)
     
     call cts59g00_idt_srv_saps(1, l_param.atdsrvnum, l_param.atdsrvano) returning m_psaerrcod
     
     start report rep_servico_cts31m00 #to ws.arq
     
     for idx = 1 to 3
     
        if m_cts31m00end[idx].cidnom is not null then
     
           case idx
              when 1
                  let l_c24enddes = "LOCAL DO RETIRADA DO CORPO"
     
              when 2
                  let l_c24enddes = "ENDERECO DO VELORIO"
     
              when 3
                  let l_c24enddes = "ENDERECO DO SEPULTAMENTO"
     
           end case
     
           if d_cts31m00.libcrpflg = "S" then
                let l_libcrpdes = "SIM"
           else
                let l_libcrpdes = "NAO"
           end if
           
           let l_lograd = m_cts31m00end[idx].lgdnom clipped ,',',m_cts31m00end[idx].lgdnum clipped
           
           output to report rep_servico_cts31m00(m_cts31m00.empnom               ,
                                                 m_cts31m00.srvtipdes            ,
                                                 m_cts31m00.srvtipabvdes         ,
                                                 d_cts31m00.c24astdes            ,
                                                 ws.srv                          ,
                                                 ws.doc                          ,
                                                 d_cts31m00.sol                  ,
                                                 d_cts31m00.cttteltxt            ,
                                                 d_cts31m00.segdclprngrades      ,
                                                 d_cts31m00.segflcprngrades      ,
                                                 d_cts31m00.mrtcaudes            ,
                                                 m_cts31m00.corsus               ,
                                                 m_cts31m00.cornom               ,
                                                 m_cts31m00.cortel               ,
                                                 d_cts31m00.flcnom               ,
                                                 d_cts31m00.flcidd               ,
                                                 d_cts31m00.obtdat               ,
                                                 l_libcrpdes                     ,
                                                 d_cts31m00.flcpso               ,
                                                 d_cts31m00.flcalt               ,
                                                 l_lograd                        ,
                                                 m_cts31m00end[idx].brrnom       ,
                                                 m_cts31m00end[idx].cidnom       ,
                                                 m_cts31m00end[idx].ufdcod       ,
                                                 m_cts31m00end[idx].lclrefptotxt ,
                                                 m_cts31m00end[idx].endzon       ,
                                                 l_c24enddes                     ,
                                                 idx)

        end if

     end for
  
     finish report rep_servico_cts31m00
  
     #let ws.comando = "lp -sd ", ws.impnom , " ", ws.arq
     #run ws.comando
     #let ws.comando = "rm ", ws.arq
     #run ws.comando

  end if

  return

end function

#---------------------------------------------------------------------------------
function enviafax_cts31m00(lr_param)
#---------------------------------------------------------------------------------

 define lr_param record
    atdsrvorg like datmservico.atdsrvorg,
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano,
    wsgpipe   char(100)
 end record

 define ws           record
    srv         char(30),
    doc         char(30),
    arq         char(50),
    dddcod      like dpaksocor.dddcod,
    faxnum      like dpaksocor.faxnum,
    faxtxt      char(12),
    dddcodsva   like dpaksocor.dddcod,
    faxnumsva   like dpaksocor.faxnum
 end record

 define idx          smallint
 define l_c24enddes  char(30)
 define l_con        smallint
 define l_libcrpdes  char(3)
 define l_lograd     char(55)
 define l_comando    char(1000)

 if m_prepare is null or
    m_prepare <> true then
    call cts31m00_prepare()
 end if

 initialize ws.*         to null
 initialize m_cts31m00.* to null
 initialize mr_acnpst.*  to null
 initialize m_psaerrcod to null
 
 let l_con       = null
 let l_c24enddes = null
 let l_libcrpdes = null
 let l_lograd    = null
 let m_traco     = "--------------------------------------------------------------------------------"
 let m_imptip    = null
 let m_enviafax  = true
 let m_pageheader = false
 let l_comando   = null

 let g_documento.atdsrvorg = lr_param.atdsrvorg
 let g_documento.atdsrvnum = lr_param.atdsrvnum
 let g_documento.atdsrvano = lr_param.atdsrvano
 let m_semdocto = 0

 for idx = 1 to 3
     initialize m_cts31m00end[idx].* to null
     initialize m_emevia[idx].*   to null
 end for

 let  l_con = consulta_cts31m00(lr_param.atdsrvorg ,
                                lr_param.atdsrvnum ,
                                lr_param.atdsrvano)

 if  l_con = 0 then
     let ws.srv =  lr_param.atdsrvorg using "<<#","/",
                   lr_param.atdsrvnum using "<<<<<<<<#" ,"-",
                   lr_param.atdsrvano using "<<<#"

     let ws.doc = m_cts31m00.succod using "<<<<#", #"<<<#","/", projeto succod
                  m_cts31m00.ramcod using "<<<#"clipped,"/",
                  m_cts31m00.aplnumdig using "<<<<<<<<#"

     call dadossrv_cts31m00(lr_param.atdsrvnum,
                            lr_param.atdsrvano)

     let wsgpipe = lr_param.wsgpipe

     call cts59g00_idt_srv_saps(1, lr_param.atdsrvnum, lr_param.atdsrvano) returning m_psaerrcod
     
     start report rep_servico_cts31m00

     for idx = 1 to 3

        if m_cts31m00end[idx].cidnom is not null then
           case idx
              when 1 let l_c24enddes = "LOCAL DA RETIRADA DO CORPO"
              when 2 let l_c24enddes = "ENDERECO DO VELORIO"
              when 3 let l_c24enddes = "ENDERECO DO SEPULTAMENTO"
           end case

           if d_cts31m00.libcrpflg = "S" then
                let l_libcrpdes = "SIM"
           else
                let l_libcrpdes = "NAO"
           end if

           let l_lograd = m_cts31m00end[idx].lgdnom clipped ,',',m_cts31m00end[idx].lgdnum clipped

           output to report rep_servico_cts31m00(m_cts31m00.empnom              ,
                                                 m_cts31m00.srvtipdes           ,
                                                 m_cts31m00.srvtipabvdes        ,
                                                 d_cts31m00.c24astdes           ,
                                                 ws.srv                         ,
                                                 ws.doc                         ,
                                                 d_cts31m00.sol                 ,
                                                 d_cts31m00.cttteltxt           ,
                                                 d_cts31m00.segdclprngrades     ,
                                                 d_cts31m00.segflcprngrades     ,
                                                 d_cts31m00.mrtcaudes           ,
                                                 m_cts31m00.corsus              ,
                                                 m_cts31m00.cornom              ,
                                                 m_cts31m00.cortel              ,
                                                 d_cts31m00.flcnom              ,
                                                 d_cts31m00.flcidd              ,
                                                 d_cts31m00.obtdat              ,
                                                 l_libcrpdes                    ,
                                                 d_cts31m00.flcpso              ,
                                                 d_cts31m00.flcalt              ,
                                                 l_lograd                       ,
                                                 m_cts31m00end[idx].brrnom      ,
                                                 m_cts31m00end[idx].cidnom      ,
                                                 m_cts31m00end[idx].ufdcod      ,
                                                 m_cts31m00end[idx].lclrefptotxt,
                                                 m_cts31m00end[idx].endzon      ,
                                                 l_c24enddes                    ,
                                                 idx)

        end if

     end for

     finish report rep_servico_cts31m00

     #let l_comando = "cat ", ws.arq clipped, "|",
     #                lr_param.wsgpipe
     #run l_comando
     #let l_comando = "rm ", ws.arq
     #run l_comando

 end if

end function

#---------------------------------------------------------------------------------
function dadossrv_cts31m00(l_param)
#---------------------------------------------------------------------------------
 define l_param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 open c_cts31m00_010 using l_param.atdsrvnum,
                         l_param.atdsrvano
 fetch c_cts31m00_010 into mr_acnpst.atdetpdat,
                         mr_acnpst.atdetphor,
                         mr_acnpst.empcod,
                         mr_acnpst.funmat,
                         mr_acnpst.pstcoddig,
                         mr_acnpst.c24nomctt

 if  sqlca.sqlcode = 0 then
     open c_cts31m00_011 using mr_acnpst.empcod,
                             mr_acnpst.funmat
     fetch c_cts31m00_011 into mr_acnpst.funnom, mr_acnpst.dptsgl
     if  sqlca.sqlcode <> 0 then
         let mr_acnpst.funnom = null
         let mr_acnpst.dptsgl = null
     end if

     open c_cts31m00_012 using mr_acnpst.pstcoddig
     fetch c_cts31m00_012 into mr_acnpst.nomgrr,
                             mr_acnpst.nomrazsoc,
                             mr_acnpst.dddcod,
                             mr_acnpst.teltxt,
                             mr_acnpst.faxnum
     if  sqlca.sqlcode <> 0 then
         let mr_acnpst.nomgrr = null
         let mr_acnpst.nomrazsoc = null
         let mr_acnpst.teltxt = null
         let mr_acnpst.faxnum = null
     end if
 else
     initialize mr_acnpst.* to null
 end if

end function

#---------------------------------------------------------------------------------
function modifica_cts31m00(l_param)
#---------------------------------------------------------------------------------

define l_param record
       atdsrvnum like datmservico.atdsrvnum ,
       atdsrvano like datmservico.atdsrvano
end record


define l_cont      integer
define x           smallint
define l_codigosql integer
define l_c24endtip like datmlcl.c24endtip

let l_cont      =  null
let x           =  null
let l_codigosql =  null


      # Atualizo o Servico

      update datmservico set ( nom           ,
                               atdlibflg     ,
                               atdlibhor     ,
                               atdlibdat     ,
                               atdhorpvt     ,
                               atddatprg     ,
                               atdhorprg     ,
                               asitipcod     ,
                               atdpvtretflg  ,
                               atdvcltip     ,
                               atdprinvlcod)
                           = ( d_cts31m00.sol         ,
                               d_cts31m00.atdlibflg   ,
                               m_cts31m00.atdlibhor   ,
                               m_cts31m00.atdlibdat   ,
                               m_cts31m00.atdhorpvt   ,
                               m_cts31m00.atddatprg   ,
                               m_cts31m00.atdhorprg   ,
                               m_cts31m00.asitipcod   ,
                               m_cts31m00.atdpvtretflg,
                               m_cts31m00.atdvcltip   ,
                               m_cts31m00.atdprinvlcod)
                         where atdsrvnum = l_param.atdsrvnum  and
                               atdsrvano = l_param.atdsrvano

      if sqlca.sqlcode <> 0  then
         error " Erro (", sqlca.sqlcode, ") na alteracao do servico. AVISE A INFORMATICA!"
         prompt "" for char m_prompt_key
         return 1
      end if


    # Atualiza o endereco do Local de Retirada do Corpo

     let l_c24endtip = 1

     let l_codigosql = processa_local_cts31m00('M'               ,
                                                l_param.atdsrvnum,
                                                l_param.atdsrvano,
                                                l_c24endtip      )

     # Atualizo as Localidades

     for x = 2 to 3


             let l_c24endtip = x

             if m_cts31m00end[x].cidnom is not null then

                         open c_cts31m00_006 using l_param.atdsrvnum ,
                                                 l_param.atdsrvano ,
                                                 l_c24endtip

                         whenever error continue
                         fetch c_cts31m00_006  into l_cont
                         whenever error stop

                         if sqlca.sqlcode <> 0 then
                            if sqlca.sqlcode = notfound then
                               error "Contador Inoperante !"
                            else
                               error "Erro SELECT c_cts31m00_006 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
                            end if
                            close c_cts31m00_006
                            return 1
                         end if

                         close c_cts31m00_006

                         # Se tiver local ja definido atualizo senao insiro

                         if l_cont > 0 then
                               let l_codigosql = processa_local_cts31m00('M'               ,
                                                                          l_param.atdsrvnum,
                                                                          l_param.atdsrvano,
                                                                          l_c24endtip      )

                               if  l_codigosql <> 0  then
                                 return 1
                               end if
                         else
                             let l_codigosql = processa_local_cts31m00('I'               ,
                                                                        l_param.atdsrvnum,
                                                                        l_param.atdsrvano,
                                                                        l_c24endtip      )

                             if  l_codigosql <> 0  then
                               return 1
                             end if
                         end if
             else

                       open c_cts31m00_006 using l_param.atdsrvnum ,
                                               l_param.atdsrvano ,
                                               l_c24endtip

                       whenever error continue
                       fetch c_cts31m00_006  into l_cont
                       whenever error stop

                       if sqlca.sqlcode <> 0 then
                          if sqlca.sqlcode = notfound then
                             error "Contador Inoperante !"
                          else
                             error "Erro SELECT c_cts31m00_006 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
                          end if
                          close c_cts31m00_006
                          return 1
                       end if

                       close c_cts31m00_006

                       # Deleto a Localizacao
                       if l_cont > 0 then

                             delete from datmlcl
                             where atdsrvnum = l_param.atdsrvnum
                             and   atdsrvano = l_param.atdsrvano
                             and   c24endtip = l_c24endtip

                             if sqlca.sqlcode <> 0 then
                                  error "Erro ao Deletar a Localizacao (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
                                  return 1
                             end if

                       end if

             end if

     end for

     # Atualizo o Laudo Funeral

     update  datmfnrsrv set (segdclprngracod  ,
                             cttteltxt        ,
                             flcnom           ,
                             segflcprngracod  ,
                             obtdat           ,
                             mrtcaucod        ,
                             fnrtip           ,
                             libcrpflg        ,
                             flcidd           ,
                             crpretlclcod     ,
                             velflg           ,
                             jzgflg           ,
                             frnasivlr        ,
                             flcpso           ,
                             flcalt           )
                    =       (d_cts31m00.segdclprngracod  ,
                             d_cts31m00.cttteltxt        ,
                             d_cts31m00.flcnom           ,
                             d_cts31m00.segflcprngracod  ,
                             d_cts31m00.obtdat           ,
                             d_cts31m00.mrtcaucod        ,
                             d_cts31m00.fnrtip           ,
                             d_cts31m00.libcrpflg        ,
                             d_cts31m00.flcidd           ,
                             d_cts31m00.crpretlclcod     ,
                             d_cts31m00.velflg           ,
                             d_cts31m00.jzgflg           ,
                             d_cts31m00.frnasivlr        ,
                             d_cts31m00.flcpso           ,
                             d_cts31m00.flcalt           )
                      where atdsrvnum = l_param.atdsrvnum  and
                            atdsrvano = l_param.atdsrvano

        if sqlca.sqlcode <> 0  then
           error " Erro (", sqlca.sqlcode, ") na alteracao do laudo funeral. AVISE A INFORMATICA!"
           prompt "" for char m_prompt_key
           return 1
        end if

        # Ponto de acesso apos a gravacao do laudo
        call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                                    g_documento.atdsrvano)

  return 0

end function

#------------------------------------------------------------------------------
function processa_local_cts31m00(param)
#------------------------------------------------------------------------------

define param record
       operacao     char (01)                  ,
       atdsrvnum    like datmservico.atdsrvnum ,
       atdsrvano    like datmservico.atdsrvano ,
       indice       smallint
end record

define ret_codigosql   integer
define arr_aux         integer
let ret_codigosql      = null
let arr_aux            = null

         let arr_aux = param.indice

         let m_cts31m00end[arr_aux].lclbrrnom = m_subbairro[arr_aux].lclbrrnom

         let ret_codigosql = cts06g07_local( param.operacao
                                            ,param.atdsrvnum
                                            ,param.atdsrvano
                                            ,param.indice
                                            ,m_cts31m00end[arr_aux].lclidttxt
                                            ,m_cts31m00end[arr_aux].lgdtip
                                            ,m_cts31m00end[arr_aux].lgdnom
                                            ,m_cts31m00end[arr_aux].lgdnum
                                            ,m_cts31m00end[arr_aux].lclbrrnom
                                            ,m_cts31m00end[arr_aux].brrnom
                                            ,m_cts31m00end[arr_aux].cidnom
                                            ,m_cts31m00end[arr_aux].ufdcod
                                            ,m_cts31m00end[arr_aux].lclrefptotxt
                                            ,m_cts31m00end[arr_aux].endzon
                                            ,m_cts31m00end[arr_aux].lgdcep
                                            ,m_cts31m00end[arr_aux].lgdcepcmp
                                            ,m_cts31m00end[arr_aux].lclltt
                                            ,m_cts31m00end[arr_aux].lcllgt
                                            ,m_cts31m00end[arr_aux].dddcod
                                            ,m_cts31m00end[arr_aux].lcltelnum
                                            ,m_cts31m00end[arr_aux].lclcttnom
                                            ,m_cts31m00end[arr_aux].c24lclpdrcod
                                            ,m_cts31m00end[arr_aux].ofnnumdig
                                            ,m_emevia[arr_aux].cod
                                            ,m_cts31m00end[arr_aux].celteldddcod
                                            ,m_cts31m00end[arr_aux].celtelnum
                                            ,m_cts31m00end[arr_aux].endcmp)

         if  ret_codigosql is null  or
             ret_codigosql <> 0     then

             case param.indice
              when 1
                 error " Erro (", ret_codigosql, ") na gravacao do",
                       " local da retirada do corpo. AVISE A INFORMATICA!"
              when 2
                 error " Erro (", ret_codigosql, ") na gravacao do",
                       " local do velorio. AVISE A INFORMATICA!"
              when 3
                     error " Erro (", ret_codigosql, ") na gravacao do",
                           " local do funeral. AVISE A INFORMATICA!"

             end case
             prompt "" for char m_prompt_key
             return 1

         end if


         return 0

end function

#------------------------------------------------------------------------------
function consulta_cts31m00(l_param)
#------------------------------------------------------------------------------

define l_param record
   atdsrvorg like datmservico.atdsrvorg   ,
   atdsrvnum like datmservico.atdsrvnum   ,
   atdsrvano like datmservico.atdsrvano
end record

define l_rec        smallint
define l_input      smallint


let l_rec        = null
let l_input      = null

     call rec_cts31m00(l_param.*)
     returning l_rec


     if l_rec <> 0 then
        return 1
     end if

  return 0

end function

#------------------------------------------------------------------------------
function rec_dados_seg(l_param)
#------------------------------------------------------------------------------

define l_param record
         ramcod      like datrservapol.ramcod   ,
         succod      like datrligapol.succod    ,
         aplnumdig   like datrligapol.aplnumdig ,
         prporg      like datrligprp.prporg     ,
         prpnumdig   like datrligprp.prpnumdig
end record

define ret record
       msg         char(80),   ---> Funeral
       tipo        char(02),   ---> Funeral
       existe_massa smallint,  ---> Funeral
       succod      like  vtamdoc.succod        ,
       empcod      dec(2,0)                    ,  ---> Funeral
       ramcod      smallint                    ,  ---> Funeral
       aplnumdig   like  vtamdoc.aplnumdig     ,
       vdapdtcod   like  vtamseguro.vdapdtcod  ,
       vdapdtdes   like  vgpkprod.vdapdtdes    ,
       prporg      like  vtamdoc.prporg        ,
       prpnumdig   like  vtamdoc.prpnumdig     ,
       emsdat      like  vtamdoc.emsdat        ,
       viginc      like  vtamdoc.viginc        ,
       vigfnl      like  vtamdoc.vigfnl        ,
       prpstt      like  vtamdoc.prpstt        ,
       cpodes      like iddkdominio.cpodes     ,
       segnumdig   like  gsakseg.segnumdig     ,
       segnom      like  gsakseg.segnom        ,
       nscdat      like  gsakseg.nscdat        ,
       segsex      like  gsakseg.segsex        ,
       endlgdtip   like  gsakend.endlgdtip     ,
       endlgd      like  gsakend.endlgd        ,
       endnum      like  gsakend.endnum        ,
       endbrr      like  gsakend.endbrr        ,
       endcid      like  gsakend.endcid        ,
       endufd      like  gsakend.endufd        ,
       endcep      like  gsakend.endcep        ,
       corsuspcp   like  gcakcorr.corsuspcp    ,
       cornom      like  gcakcorr.cornom
end record

define r_gcakfilial    record
        endlgd          like gcakfilial.endlgd
       ,endnum          like gcakfilial.endnum
       ,endcmp          like gcakfilial.endcmp
       ,endbrr          like gcakfilial.endbrr
       ,endcid          like gcakfilial.endcid
       ,endcep          like gcakfilial.endcep
       ,endcepcmp       like gcakfilial.endcepcmp
       ,endufd          like gcakfilial.endufd
       ,dddcod          like gcakfilial.dddcod
       ,teltxt          like gcakfilial.teltxt
       ,dddfax          like gcakfilial.dddfax
       ,factxt          like gcakfilial.factxt
       ,maides          like gcakfilial.maides
       ,crrdstcod       like gcaksusep.crrdstcod
       ,crrdstnum       like gcaksusep.crrdstnum
       ,crrdstsuc       like gcaksusep.crrdstsuc
       ,status          smallint
end record

---> Previdencia - Funeral
define l_retornofnc record
       coderro         integer,
       menserro        char(30),
       qtdlinhas       integer
end record

define l_erro       smallint
define l_corteltxt  like  gcakfilial.teltxt

---> Previdencia - Funeral
initialize l_retornofnc.* to null

initialize ret.*             to null
initialize r_gcakfilial.*    to null
let l_erro      = null
let l_corteltxt = null

         # Chamo a Funcao do vida para recuperar as informacoes
         # do segurado

#        call fvita008_vida(l_param.ramcod     ,
#                           l_param.succod     ,
#                           l_param.aplnumdig  ,

         ---> VEP - Vida
         call fvita008_vida(l_param.*,"","","")
              returning l_erro,ret.*
         #call fvita008_vida(''     ,
         #                   ''     ,
         #                   ''  ,
         #                   l_param.prporg     ,
         #                   l_param.prpnumdig  ,
         #                   "","","")
         #    returning l_erro,ret.*

        let l_param.ramcod = ret.ramcod   ---> Funeral

        ---> alberto / nilo
        let g_prporg    = ret.prporg
        let g_prpnumdig = ret.prpnumdig
        let g_emsdat = ret.emsdat

             if l_erro <> 0 then
                ---> Previdencia - Funeral
                call fpvia21_pesquisa_dados_segurado(l_param.succod     ,
                                                     l_param.ramcod     ,
                                                     l_param.aplnumdig  )
                                           returning l_retornofnc.*
                                           ---> carrega array g_a_psqdadseg

###             if l_retornofnc.coderro   = 0 or
###                l_retornofnc.qtdlinhas > 0 then
                if g_a_psqdadseg[1].prporg is null or
                   g_a_psqdadseg[1].prporg =  0    then
                   return  ret.segnom    ,
                           ret.corsuspcp ,
                           ret.cornom    ,
                           l_corteltxt   ,
                           1
                end if

                let g_prporg      = g_a_psqdadseg[1].prporg
                let g_prpnumdig   = g_a_psqdadseg[1].prpnumdig
                let g_emsdat      = g_a_psqdadseg[1].dtemsprp
                let ret.segnom    = g_a_psqdadseg[1].segnom
                let ret.corsuspcp = g_a_psqdadseg[1].corsus
                let ret.cornom    = g_a_psqdadseg[1].cornom
                let l_erro        = 0

             end if



         call fgckc811(ret.corsuspcp)
              returning r_gcakfilial.*

        let l_corteltxt = "(", r_gcakfilial.dddcod  , ") ", r_gcakfilial.teltxt



 return  ret.segnom    ,
         ret.corsuspcp ,
         ret.cornom    ,
         l_corteltxt   ,
         l_erro

end function

#---------------------------------------------------------------------------
 report rep_servico_cts31m00(r_cts31m00)
#---------------------------------------------------------------------------


define r_cts31m00 record
  empnom          like gabkemp.empnom          ,
  srvtipdes       like datksrvtip.srvtipdes    ,
  srvtipabvdes    like datksrvtip.srvtipabvdes ,
  c24astdes       char(45)                     ,
  srv             char(30)                     ,
  doc             char(30)                     ,
  sol             char(30)                     ,
  cttteltxt       like datmfnrsrv.cttteltxt    ,
  segdclprngrades char(12)                     ,
  segflcprngrades char(12)                     ,
  mrtcaudes       char(12)                     ,
  corsus          like datmservico.corsus      ,
  cornom          like datmservico.cornom      ,
  cortel          char(15)                     ,
  flcnom          like datmfnrsrv.flcnom       ,
  flcidd          like datmfnrsrv.flcidd       ,
  obtdat          like datmfnrsrv.obtdat       ,
  libcrpdes       char(03)                     ,
  flcpso          like datmfnrsrv.flcpso       ,
  flcalt          like datmfnrsrv.flcalt       ,
  lgdnom          char(55)                     ,
  brrnom          like datmlcl.brrnom          ,
  cidnom          like datmlcl.cidnom          ,
  ufdcod          like datmlcl.ufdcod          ,
  lclrefptotxt    char(55)                     ,
  endzon          like datmlcl.endzon          ,
  c24enddes       char(30)                     ,
  idx             smallint
  ###atdetpdat       like datmsrvacp.atdetpdat    ,
  ###atdetphor       like datmsrvacp.atdetphor    ,
  ###empcod          like datmsrvacp.empcod       ,
  ###funmat          like datmsrvacp.funmat       ,
  ###funnom          like isskfunc.funnom         ,
  ###dptsgl          like isskfunc.dptsgl         ,
  ###pstcoddig       like datmsrvacp.pstcoddig    ,
  ###nomgrr          like dpaksocor.nomgrr        ,
  ###nomrazsoc       like dpaksocor.nomrazsoc     ,
  ###dddcod          like dpaksocor.dddcod        ,
  ###teltxt          like dpaksocor.teltxt        ,
  ###faxnum          like dpaksocor.faxnum        ,
  ###c24nomctt       like datmsrvacp.c24nomctt

end record

output report to pipe wsgpipe
   left   margin  00
   right  margin  80
   top    margin  00
   bottom margin  00
   page   length  66

format

on every row
   if  m_pageheader = false then
       let m_pageheader = true

       if  m_enviafax then
           case mr_acnpst.empcod
              when 1
                 #print column 001, ascii 27, "&k2S";    # Caracteres
                 #print             ascii 27, "(s7b";    # de controle
                 #print             ascii 27, "(s4102T"; # para 132
                 #print             ascii 27, "&l08D";   # colunas
                 print             ascii 27, "&l00E";   # Logo no topo
                 print column 001, "@+IMAGE[porto.tif;x=0cm;y=0cm]"
                 skip 7 lines
              when 50 ---> Saude
                 print             ascii 27, "&l00E";   # Logo no topo
                 print column 001, "@+IMAGE[porto.tif;x=0cm;y=0cm]"
                 skip 7 lines
              when 35
                 #print column 001, ascii 27, "&k2S";    # Caracteres
                 #print             ascii 27, "(s7b";    # de controle
                 #print             ascii 27, "(s4102T"; # para 132
                 #print             ascii 27, "&l08D";   # colunas
                 print             ascii 27, "&l00E";   # Logo no topo
                 print column 001, "@+IMAGE[azul.tif;x=0cm;y=0cm]"
                 skip 6 lines
                 
              when 43   #--> PSI-2013-06224/PR
                 if m_psaerrcod = 0 and m_psaerrcod is not null  # serviço SAPS
                    then
                    print ascii 27, "&l00E";  # Logo no topo
                    # compilacao do TIF para fax nao disponivel, sera disponibilizado projeto substituição do VSIfax
                    # print column 001, "@+IMAGE[saps.tif;x=0cm;y=0cm]"
                    print column 001, "@+IMAGE[porto.tif;x=0cm;y=0cm]"
                    skip 8 lines
                 end if
           end case
       else
           if  m_imptip = "L"  then
               print column 001, ascii(027),"E",
                                 ascii(027),"(s0p13h0s0b4099T",
                                 ascii(027),"&l0O",
                                 ascii(027),"&a06L",
                                 ascii(027),"&24E",
                                 ascii(027),"&l7C",
                                 ascii(027),"&f1y4X"
           else
               print column 001, ""
           end if
       end if

       print column 001, r_cts31m00.empnom clipped             ,
             column 036, "CTS31M00"                            ,
             column 065, "PAG.:    ", pageno using "###,##&"
       print column 065, "DATA: "   , today
       print column 029, "CONTROLE DE SERVICOS"                ,
             column 065, "HORA:   " , time
       skip 1 line
       print column 001, m_traco
       #skip 1 line
       print column 001, "TIPO.......:"                       ,
             column 014, r_cts31m00.c24astdes        clipped
       print column 001, "ASSUNTO....:"                       ,
             column 014, r_cts31m00.srvtipabvdes     clipped  ,
             column 018, "-"                                  ,
             column 020, r_cts31m00.srvtipdes        clipped
       print column 001, "SERVICO....:"                       ,
             column 014, r_cts31m00.srv              clipped
       #skip 1 line
       print column 001, m_traco
       #skip 1 line
       print column 001, "DOCUMENTO..:"                       ,
             column 014, r_cts31m00.doc              clipped  ,
             column 052, "TEL.CONTATO:"                       ,
             column 065, r_cts31m00.cttteltxt        clipped
       print column 001, "SOLICIT....:"                       ,
             column 014, r_cts31m00.sol              clipped  ,
             column 052, "RELACAO C/SEGURADO:"                ,
             column 072, r_cts31m00.segdclprngrades  clipped
       print column 001, "CORRETOR...:"                       ,
             column 014, r_cts31m00.corsus                    ,
             column 021, "-"                                  ,
             column 023, r_cts31m00.cornom           clipped
       print column 001, "TELEFONE...:"                       ,
             column 014, r_cts31m00.cortel           clipped
       #skip 1 line
       print column 001, m_traco
       print column 030, "DADOS DO FALECIDO(A)"
       #skip 1 line
       print column 001, "FALECIDO(A):"                       ,
             column 014, r_cts31m00.flcnom           clipped  ,
             column 052, "PARENTESCO C/SEG:"                  ,
             column 065, r_cts31m00.segflcprngrades  clipped
       print column 001, "IDADE......:"                       ,
             column 014, r_cts31m00.flcidd                    ,
             column 052, "DATA DO OBITO...:"                  ,
             column 065, r_cts31m00.obtdat
       print column 001, "CAUSA MORTE:"                       ,
             column 014, r_cts31m00.mrtcaudes        clipped  ,
             column 052, "CORPO LIBERADO..:"                  ,
             column 065, r_cts31m00.libcrpdes        clipped
       print column 001, "ALTURA.....:"                       ,
             column 014, r_cts31m00.flcalt                    ,
             column 052, "PESO............:"                  ,
             column 065, r_cts31m00.flcpso using "##&.&"
       #skip 1 line
       print column 001, m_traco
   end if

   if r_cts31m00.idx  = 1 then
       print column 028, r_cts31m00.c24enddes    clipped
   else
       print column 030, r_cts31m00.c24enddes    clipped
   end if

   #skip 1 line

   print column 001, "ENDERECO...:"                       ,
         column 014, r_cts31m00.lgdnom           clipped
   print column 001, "BAIRRO.....:"                       ,
         column 014, r_cts31m00.brrnom           clipped  ,
         column 044, "CIDADE.:"                           ,
         column 053, r_cts31m00.cidnom           clipped  ,
         column 074, "UF:"                                ,
         column 077, r_cts31m00. ufdcod          clipped
  print  column 001, "PONTO REF..:"                       ,
         column 014, r_cts31m00.lclrefptotxt     clipped  ,
         column 072, "ZONA:"                              ,
         column 077, r_cts31m00. endzon          clipped

  print column 001, m_traco

on last row
  print column 020, "*** CONTROLE DE ACIONAMENTO DE PRESTADORES ***"
  print column 001, m_traco

  print column 001, "CONCLUIDO EM ", mr_acnpst.atdetpdat, " AS ", mr_acnpst.atdetphor, " POR ",
                    mr_acnpst.funmat, "-", mr_acnpst.funnom clipped,
        column 070, "DPTO:", mr_acnpst.dptsgl clipped
  skip 1 line
  print column 001, "PRESTADOR:", mr_acnpst.pstcoddig, " - ", mr_acnpst.nomgrr clipped
  print column 001, "R. SOCIAL:", mr_acnpst.nomrazsoc clipped
  print column 001, "TELEFONE.: (", mr_acnpst.dddcod clipped, ") ", mr_acnpst.teltxt clipped;

  if  mr_acnpst.faxnum is null or
      mr_acnpst.faxnum = 0 then
      print column 060, "FAX: (", mr_acnpst.dddcod clipped, ") ", mr_acnpst.faxnum
  else
      print column 060, "FAX:"
  end if

  print column 001, "CONTATO..:", mr_acnpst.c24nomctt
  print column 001, m_traco
  print ascii(12)

end report
#------------------------------------------------------------------------------
function cts31m00b()
#------------------------------------------------------------------------------
define d_cts31m00b record
        opc1          smallint ,
        crpretlcldes  char(40) ,
        opc2          smallint ,
        veldes        char(40) ,
        opc3          smallint ,
        fnrdes        char(40) ,
        opcf          smallint
end record

define l_cts31m00bend array[03] of record
    lclidttxt       like datmlcl.lclidttxt       ,
    cidnom          like datmlcl.cidnom          ,
    ufdcod          like datmlcl.ufdcod          ,
    brrnom          like datmlcl.brrnom          ,
    lclbrrnom       like datmlcl.lclbrrnom       ,
    endzon          like datmlcl.endzon          ,
    lgdtip          like datmlcl.lgdtip          ,
    lgdnom          like datmlcl.lgdnom          ,
    lgdnum          like datmlcl.lgdnum          ,
    lgdcep          like datmlcl.lgdcep          ,
    lgdcepcmp       like datmlcl.lgdcepcmp       ,
    lclltt          like datmlcl.lclltt          ,
    lcllgt          like datmlcl.lcllgt          ,
    lclrefptotxt    like datmlcl.lclrefptotxt    ,
    lclcttnom       like datmlcl.lclcttnom       ,
    dddcod          like datmlcl.dddcod          ,
    lcltelnum       like datmlcl.lcltelnum       ,
    c24lclpdrcod    like datmlcl.c24lclpdrcod    ,
    ofnnumdig       like sgokofi.ofnnumdig       ,
    celteldddcod    like datmlcl.celteldddcod    ,
    celtelnum       like datmlcl.celtelnum       ,
    endcmp          like datmlcl.endcmp
end record

define l_emevia array[03] of record
       cod       like datmlcl.emeviacod
end record

define ret record
       dtparam char(16)  ,
       retflg  smallint
end record

 define hist_cts31m00b record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

define x smallint

initialize d_cts31m00b.*    to null
initialize ret.*            to null
initialize hist_cts31m00b.* to null

for x=1 to 3
  initialize l_cts31m00bend[x].* to null
  initialize l_emevia[x].*   to null
end for

 let d_cts31m00b.opc1 = 1
 let d_cts31m00b.opc2 = 2
 let d_cts31m00b.opc3 = 3

 let d_cts31m00b.crpretlcldes = "Local de Retirada do Corpo"
 let d_cts31m00b.veldes       = "Local do Velorio"
 let d_cts31m00b.fnrdes       = "Local do Sepultamento/Cremacao"

open window cts31m00b at 13,14 with form "cts31m00b"
                      attribute (form line 1, border, comment line last - 1)

 message " (F17)Abandona "

display by name d_cts31m00b.*

        input by name d_cts31m00b.opcf without defaults

             before field opcf
                       display by name d_cts31m00b.opcf attribute (reverse)

             after  field opcf

             if d_cts31m00b.opcf is null then
                 error "Digite uma opcao"
                 next field opcf
             end if

             if d_cts31m00b.opcf > 3 then
                 error "Opcao Incorreta"
                 next field opcf
             end if

             let x = d_cts31m00b.opcf

              let m_cts31m00end[x].lclbrrnom = m_subbairro[x].lclbrrnom
              let m_acesso_ind = false
              call cta00m06_acesso_indexacao_aut(m_cts31m00.atdsrvorg)
                   returning m_acesso_ind
              if m_acesso_ind = false then
                 call cts06g03(d_cts31m00b.opcf
                              ,m_cts31m00.atdsrvorg
                              ,0
                              ,m_data
                              ,m_hora
                              ,m_cts31m00end[x].lclidttxt
                              ,m_cts31m00end[x].cidnom
                              ,m_cts31m00end[x].ufdcod
                              ,m_cts31m00end[x].brrnom
                              ,m_cts31m00end[x].lclbrrnom
                              ,m_cts31m00end[x].endzon
                              ,m_cts31m00end[x].lgdtip
                              ,m_cts31m00end[x].lgdnom
                              ,m_cts31m00end[x].lgdnum
                              ,m_cts31m00end[x].lgdcep
                              ,m_cts31m00end[x].lgdcepcmp
                              ,m_cts31m00end[x].lclltt
                              ,m_cts31m00end[x].lcllgt
                              ,m_cts31m00end[x].lclrefptotxt
                              ,m_cts31m00end[x].lclcttnom
                              ,m_cts31m00end[x].dddcod
                              ,m_cts31m00end[x].lcltelnum
                              ,m_cts31m00end[x].c24lclpdrcod
                              ,m_cts31m00end[x].ofnnumdig
                              ,m_cts31m00end[x].celteldddcod
                              ,m_cts31m00end[x].celtelnum
                              ,m_cts31m00end[x].endcmp
                              ,hist_cts31m00.*
                              ,l_emevia[x].*             )
                    returning l_cts31m00bend[x].lclidttxt
                             ,l_cts31m00bend[x].cidnom
                             ,l_cts31m00bend[x].ufdcod
                             ,l_cts31m00bend[x].brrnom
                             ,l_cts31m00bend[x].lclbrrnom
                             ,l_cts31m00bend[x].endzon
                             ,l_cts31m00bend[x].lgdtip
                             ,l_cts31m00bend[x].lgdnom
                             ,l_cts31m00bend[x].lgdnum
                             ,l_cts31m00bend[x].lgdcep
                             ,l_cts31m00bend[x].lgdcepcmp
                             ,l_cts31m00bend[x].lclltt
                             ,l_cts31m00bend[x].lcllgt
                             ,l_cts31m00bend[x].lclrefptotxt
                             ,l_cts31m00bend[x].lclcttnom
                             ,l_cts31m00bend[x].dddcod
                             ,l_cts31m00bend[x].lcltelnum
                             ,l_cts31m00bend[x].c24lclpdrcod
                             ,l_cts31m00bend[x].ofnnumdig
                             ,l_cts31m00bend[x].celteldddcod
                             ,l_cts31m00bend[x].celtelnum
                             ,l_cts31m00bend[x].endcmp
                             ,ret.retflg
                             ,hist_cts31m00b.*
                             ,l_emevia[x].*
             else
                 call cts06g11(d_cts31m00b.opcf
                              ,m_cts31m00.atdsrvorg
                              ,0
                              ,m_data
                              ,m_hora
                              ,m_cts31m00end[x].lclidttxt
                              ,m_cts31m00end[x].cidnom
                              ,m_cts31m00end[x].ufdcod
                              ,m_cts31m00end[x].brrnom
                              ,m_cts31m00end[x].lclbrrnom
                              ,m_cts31m00end[x].endzon
                              ,m_cts31m00end[x].lgdtip
                              ,m_cts31m00end[x].lgdnom
                              ,m_cts31m00end[x].lgdnum
                              ,m_cts31m00end[x].lgdcep
                              ,m_cts31m00end[x].lgdcepcmp
                              ,m_cts31m00end[x].lclltt
                              ,m_cts31m00end[x].lcllgt
                              ,m_cts31m00end[x].lclrefptotxt
                              ,m_cts31m00end[x].lclcttnom
                              ,m_cts31m00end[x].dddcod
                              ,m_cts31m00end[x].lcltelnum
                              ,m_cts31m00end[x].c24lclpdrcod
                              ,m_cts31m00end[x].ofnnumdig
                              ,m_cts31m00end[x].celteldddcod
                              ,m_cts31m00end[x].celtelnum
                              ,m_cts31m00end[x].endcmp
                              ,hist_cts31m00.*
                              ,l_emevia[x].*             )
                    returning l_cts31m00bend[x].lclidttxt
                             ,l_cts31m00bend[x].cidnom
                             ,l_cts31m00bend[x].ufdcod
                             ,l_cts31m00bend[x].brrnom
                             ,l_cts31m00bend[x].lclbrrnom
                             ,l_cts31m00bend[x].endzon
                             ,l_cts31m00bend[x].lgdtip
                             ,l_cts31m00bend[x].lgdnom
                             ,l_cts31m00bend[x].lgdnum
                             ,l_cts31m00bend[x].lgdcep
                             ,l_cts31m00bend[x].lgdcepcmp
                             ,l_cts31m00bend[x].lclltt
                             ,l_cts31m00bend[x].lcllgt
                             ,l_cts31m00bend[x].lclrefptotxt
                             ,l_cts31m00bend[x].lclcttnom
                             ,l_cts31m00bend[x].dddcod
                             ,l_cts31m00bend[x].lcltelnum
                             ,l_cts31m00bend[x].c24lclpdrcod
                             ,l_cts31m00bend[x].ofnnumdig
                             ,l_cts31m00bend[x].celteldddcod
                             ,l_cts31m00bend[x].celtelnum
                             ,l_cts31m00bend[x].endcmp
                             ,ret.retflg
                             ,hist_cts31m00b.*
                             ,l_emevia[x].*
             end if
             if m_cts31m00end[x].cidnom is not null and
                m_cts31m00end[x].ufdcod is not null then
                call cts14g00 (d_cts31m00.c24astcod,
                               "","","","",
                               m_cts31m00end[x].cidnom,
                               m_cts31m00end[x].ufdcod,
                               "S",
                               ret.dtparam)
             end if


             on key (interrupt)

             exit input

         end input

 close window cts31m00b

return

end function

function rec_etapa_cts31m00(l_param)

define l_param record
       atdsrvnum like datmservico.atdsrvnum     ,
       atdsrvano like datmservico.atdsrvano
end record


  # Recupero a ultima sequencia da etapa do Servico

  open c_cts31m00_008 using l_param.atdsrvnum ,
                          l_param.atdsrvano

  whenever error continue
  fetch c_cts31m00_008  into m_cts31m00.atdsrvseq

  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
          error "Sequencia da etapa nao encontrada!"
     else
        error "Erro SELECT c_cts31m00_008 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
     end if
     close c_cts31m00_008
     return 1
  end if

  close c_cts31m00_008

  # Recupero a Etapa do Servico

  open c_cts31m00_009 using l_param.atdsrvnum ,
                          l_param.atdsrvano ,
                          m_cts31m00.atdsrvseq

  whenever error continue
  fetch c_cts31m00_009  into m_cts31m00.atdetpcod

  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
          error "Etapa nao encontrada!"
     else
        error "Erro SELECT c_cts31m00_009 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
     end if
     close c_cts31m00_009
     return 1
  end if

  close c_cts31m00_009

  return 0

end function

#------------------------------------------------------------------------------
 function cts31m00_popup()
#------------------------------------------------------------------------------

   define al_popup array[10] of record
             dpdnom       like vtamsegdpd.dpdnom
   end record

   define al_popup_aux array[10] of record
             doecrndiaqtd like vtamsegdpd.doecrndiaqtd
   end record

   define lr_retorno record
             dpdnom       like vtamsegdpd.dpdnom
            ,doecrndiaqtd like vtamsegdpd.doecrndiaqtd
   end record

   define l_curr smallint
         ,l_i    smallint

   initialize al_popup, al_popup_aux, lr_retorno to null

   let l_curr = null

   for l_i = 1 to 10
       initialize al_popup[l_i].* to null
       initialize al_popup_aux[l_i].* to null
   end for

   for l_i = 1 to 10
       let al_popup[l_i].dpdnom           = mr_fvita008[l_i].dpdnom
       let al_popup_aux[l_i].doecrndiaqtd = mr_fvita008[l_i].doecrndiaqtd
   end for

   open window cts31m00c at 11,25 with form "cts31m00c"
      attribute (border)

   ##call set_count(10)
   call set_count(l_i)
   display array al_popup to s_cst31m00.*

      on key(f8)
         let l_i = arr_curr()
         let lr_retorno.dpdnom       = al_popup[l_i].dpdnom
         let lr_retorno.doecrndiaqtd = al_popup_aux[l_i].doecrndiaqtd
         exit display

      on key(interrupt, control-c, f17)
         initialize lr_retorno to null
         let int_flag = false
         exit display

   end display

   close window cts31m00c
   let int_flag = false
   return lr_retorno.dpdnom
         ,lr_retorno.doecrndiaqtd

end function
