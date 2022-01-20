#############################################################################
# Nome do Modulo: CTS00M01                                         Pedro    #
#                                                                  Marcelo  #
# Mostra servicos conforme parametro                               Abr/1995 #
# ######################################################################### #
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 14/10/1998  PSI 6895-0   Gilberto     Incluir funcao RETORNOS MARCADOS.   #
#---------------------------------------------------------------------------#
# 27/10/1998  PSI 6966-3   Gilberto     Incluir novo codigo de status do    #
#                                       servidor VSI-Fax.                   #
#---------------------------------------------------------------------------#
# 05/04/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao do ende-  #
#                                       reco atraves do guia postal.        #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 28/09/1999  PSI 9164-2   Wagner       Alteracao na mensagem de aviso para #
#                                       os servicos com "*".                #
#---------------------------------------------------------------------------#
# 08/02/2000  PSI 10206-7  Wagner       Exibir nivel prioridade do servico. #
#---------------------------------------------------------------------------#
# 27/03/2000  PSI 10264-4  Wagner       SQL retorno por periodo.            #
#---------------------------------------------------------------------------#
# 09/06/2000  PSI 10866-9  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 17/10/2002  PSI 162884   Paula        Incluir atend. ct24h RADIO RE       #
#...........................................................................#
#                                                                           #
#                 * * * * Alteracoes * * * *                                #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
# 21/07/2004 James, Meta       PSI186414  Recebimento de novos parametros,e #
#                              OSF 37940  selecao de servicos de acordo com #
#                                         os novos parametros               #
# 04/08/2004 Marcio  Meta      PSI186414  Incluir novas consistencias para  #
#                                         pesquisa dos servicos programados #
#                                                                           #
# 27/01/2005 Daniel, Meta      PSI190489  Receber novos Parametros.         #
#                                         Selecionar os servicos de acordo  #
#                                         com o filtro selecionado na tela  #
#                                         cts00m37                          #
#                                         Selecionar os servicos de acordo  #
#                                         com o filtro selecionado na tela  #
#                                         cts00m38                          #
#                                         Obter o endereco do servico       #
#                                         Fazer o filtro pela ufdcod        #
#                                         Retirada a chamada do ctx04g00 e  #
#                                         colocado logo apos o inicio do    #
#                                         foreach                           #
# 14/06/05  Andrei, Meta       PSI189790  Incluir chamada da funcao         #
#                                         cts29g00_consistir_multiplo       #
# 21/06/2005 Alinne, Meta      PSI191990  Acionamento de servicos por Endere#
#                                         co Indexado                       #
# 07/11/2005 Ligia Mattge      PSI195138  Acionamento automatico            #
#---------------------------------------------------------------------------#
# 13/04/2006 Priscila Staingel PSI198714  Acionamento automatico Auto       #
#---------------------------------------------------------------------------#
# 07/12/2006 Priscila Staingel PSI205206  Incluir empresa do servico na tela#
#############################################################################
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica  PSI       Alteracao                              #
# ---------- -------------  --------- ---------------------------------------#
# 14/02/2007 Saulo,Meta     AS130087  Migracao para a versao 7.32            #
# 12/06/2007 Roberto        CT7061632 Aumento do limite de Pesquisa de 800   #
#                                     para 1600                              #
# 10/10/2007 Ligia Mattge   PSI211982 Nao exibir srv nao emergenciais da PortoSeg
# 14/11/2008 Ligia Mattge   PSI232700 Exibir os servicos de conveniencia     #
# 28/01/2009 Adriano Santos PSI235849 Considerar serviço SINISTRO RE         #
# 13/08/2009 Sergio Burini  PSI244236 Inclusão do Sub-Dairro                 #
# 30/03/2011 Fabio Costa    PSI260142 Interface reserva via sistema Localiza #
# 27/12/2012 Luiz, BRQ      PSI-2012-26565/EV                                #
#                                     Alteração validar mensagem             #
#                                     "AGUARDANDO CONFIRMACAO" para os       #
#                                     serviços que estão com a etapa de      #
#                                     servico corrente com a situação igual  #
#                                     1 - liberado e o tipo de acionamento   #
#                                     1 - internet                           #
#----------------------------------------------------------------------------#
# 23/10/2015 Eliane,Fornax Chamado 611101 - Tela de cancelados alteracao na  #
#                                           na consulta: etapa 5             #
#----------------------------------------------------------------------------#


## PSI 186414 - Inicio

globals '/homedsa/projetos/geral/globals/glct.4gl'

define m_prep_cts00m01 smallint

 define a_cts00m01_rsv  array[200] of record
        lcvcod          smallint ,
        lcvnom          char(40) ,
        servico         char(13) ,
        tipo_doc        char(08) ,
        sttdoc          char(22) ,
        localizador     char(15) ,
        ultitftipdes    char(20) ,
        ultitfsttdes    char(27) ,
        ultenvhordat    char(20) ,
        ultrethordat    char(20) ,
        ultsttcrides01  char(75) ,
        ultsttcrides02  char(75) ,
        qtditf          smallint ,
        acntip          like datklocadora.acntip,
        interfaces      array[30] of record
           itftipdes    char(20) ,
           itfenvhordat char(20) ,
           itfrethordat char(20) ,
           itfsttdes    char(27) 
        end record
 end record

#---------------------------#
function cts00m01_prepare()
#---------------------------#

   define l_sql char(500)

   let l_sql = " select lclltt, lcllgt, cidnom, ufdcod, c24lclpdrcod" #psi195138
              ,'   from datmlcl '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
              ,'    and c24endtip = 1 '

   prepare p_cts00m01_001 from l_sql
   declare c_cts00m01_001 cursor for p_cts00m01_001

    let l_sql = ' select funnom ',
                  ' from isskfunc ',
                 ' where funmat = ? ',
                   ' and empcod = 1 ',
                   ' and usrtip = "F" '

   prepare p_cts00m01_002 from l_sql
   declare c_cts00m01_002 cursor for p_cts00m01_002

# Inicio Alteração - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

   let l_sql = ' select t1.atdsrvnum, t1.atdsrvano, t2.acntip',
               ' from datmavisrent as t1 ',
               ' inner join datklocadora as t2 ',
               '    on t2.lcvcod = t1.lcvcod ',
               ' where t1.atdsrvano = ? ',
               '   and t1.atdsrvnum = ? ',
               '   and t2.acntip    = 1 ',
               '   and not exists ( ',
               '       select t3.atdsrvano, t3.atdsrvnum ',
               '         from datmrsvvcl as t3 ',
               '        where t3.atdsrvano = t1.atdsrvano ',
               '          and t3.atdsrvnum = t1.atdsrvnum )'
   prepare p_cts00m01_020 from l_sql
   declare c_cts00m01_020 cursor for p_cts00m01_020

# Fim Alteração - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

   let m_prep_cts00m01 = true

end function

#---------------------------#
 function cts00m01(lr_param)
#---------------------------#

 define l_sql   char(2000)
 define l_erro  smallint
 define l_em_uso          smallint
 define l_nome            like isskfunc.funnom
 define l_msgmat          char(40)

 define lr_param       record
        par_pesq       char(03),
        data_inicial   date,
        data_final     date,
        atdprscod      like datmservico.atdprscod,
        atdsrvorg      like datmservico.atdsrvorg,
        nome           like datmservico.nom,
        vcllicnum      like datmservico.vcllicnum,
        codigo_filtro  smallint,
        ufdcod         like glakest.ufdcod,
        filtro_resumo  char(1),
        cidnom         like glakcid.cidnom,
        flag_ac        smallint,
        in_empresas    char(30)
 end record

## PSI 186414 - Final

 define a_motivo  array[1600] of like datmservico.acnnaomtv
 define a_cidade  array[1600] of record
        atdfnlflg like datmservico.atdfnlflg,
        cidnom    like datmlcl.cidnom,
        ufdcod    like datmlcl.ufdcod
        end record

 define a_cts00m01  array[1600] of record
    servico         char (13)                   ,
    atdlibdat       char (05)                   ,
    atdlibhor       like datmservico.atdlibhor  ,
    atddatprg       char (05)                   ,
    atdhorprg       like datmservico.atdhorprg  ,
    atdlibflg       like datmservico.atdlibflg  ,
    atdhorpvt       like datmservico.atdhorpvt  ,
    espera          char (06)                   ,
    asitipabvdes    like datkasitip.asitipabvdes,
    prioridade      char (05)                   ,
    atdetpdes       like datketapa.atdetpdes    ,
    srvtipabvdes    char (13)                   ,
    local           char (40)                   ,
    historico       char (30)                   ,
    sindex          char (7)                    ,
    empresa         char (6)                    ,
    rsdflg          char (9)                    ,
    gentxt          char (40)
 end record

 define w_cts00m01   record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    lclbrrnom        like datmlcl.lclbrrnom,
    brrnom           like datmlcl.brrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    endzon           like datmlcl.endzon,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    codigosql        integer
 end record

 define ws          record
    cabec           char (64)                    ,
    remqtd          dec (3,0)                    ,
    assqtd          dec (3,0)                    ,
    nlbqtd          dec (3,0)                    ,
    prgqtd          dec (6,0)                    , #ligia 31/07/08
    vstqtd          dec (3,0)                    ,
    resqtd          dec (3,0)                    ,
    sprqtd          dec (3,0)                    ,
    canqtd          dec (3,0)                    ,
    retqtd          dec (3,0)                    ,
    tempo            char (08)                    ,
    h24             datetime hour to minute      ,
    horaatu         datetime hour to minute      ,
    horaprg         datetime hour to minute      ,
    succod          like datmvistoria.succod     ,
    atdsrvnum       like datmservico.atdsrvnum   ,
    atdsrvano       like datmservico.atdsrvano   ,
    atdsrvseq       like datmsrvacp.atdsrvseq    ,
    atdsrvorg       like datmservico.atdsrvorg   ,
    atdpvtretflg    like datmservico.atdpvtretflg,
    asitipcod       like datmservico.asitipcod   ,
    faxchr          char (10)                    ,
    faxch1          like gfxmfax.faxch1          ,
    faxch2          like gfxmfax.faxch2          ,
    faxsttcod       like gfxmfax.faxsttcod       ,
    atdlibdat       char (10)                    ,
    atddatprg       char (10)                    ,
    lighorinc       char (05)                    ,
    ligastcod       like datmligacao.c24astcod   ,
    c24opemat       like datmservico.c24opemat   ,
    c24openom       like isskfunc.funnom         ,
    atdvcltip       like datmservico.atdvcltip   ,
    lcvnom          like datklocadora.lcvnom     ,
    cidnom          like datklocadora.cidnom     ,
    endufd          like datklocadora.endufd     ,
    lockk           char (01)                    ,
    canpsqdat       date                         ,
    canpsqdatini    date                         ,
    atdsrvnumsv     like datmservico.atdsrvnum   ,
    atdprinvlcod    like datmservico.atdprinvlcod,
    atdprinvldes    char (05)                    ,
    refatdsrvnum    like datmservico.atdsrvnum   ,
    refatdsrvano    like datmservico.atdsrvano   ,
    atdetpcodrem    like datketapa.atdetpcod     ,
    socntzcod       like datksocntz.socntzcod    ,
    socntzdes       like datksocntz.socntzdes    ,
    lignumjre       like datrligsinvst.lignum    ,
    c24astcodjre    like datmligacao.c24astcod   ,
    acnsttflg       like datmservico.acnsttflg   ,
    atdfnlflg       like datmservico.atdfnlflg   ,
    resp            char(1)                      ,
    msg             char(50)                     ,
    ciaempcod       like datmservico.ciaempcod   ,     #PSI 205206
    atdetpcod       like datmsrvacp.atdetpcod    ,     #PSI 232700 ligia 14/11/08
    atdrsdflg       like datmservico.atdrsdflg   ,
    lcvcod          like datklocadora.lcvcod     ,
    acntip          like datklocadora.acntip
 end record

 define ws2          array[4] of record
    des              char (05)
 end record

 define l_rsvloc record
        itftipcod     like datmvclrsvitf.itftipcod    ,
        itfsttcod     like datmvclrsvitf.itfsttcod    ,
        itfgrvhordat  like datmvclrsvitf.itfgrvhordat ,
        vclitfseq     like datmvclrsvitf.vclitfseq    ,
        atzdianum     like datmrsvvcl.atzdianum       ,
        rsvsttcod     like datmrsvvcl.rsvsttcod       ,
        rsvlclcod     like datmrsvvcl.rsvlclcod       ,
        intsttcrides  like datmvclrsvitf.intsttcrides ,
        itfenvhordat  like datmvclrsvitf.itfenvhordat ,
        itfrethordat  like datmvclrsvitf.itfrethordat
 end record

 define l_dominio record
        erro     smallint
       ,mensagem char(100)
       ,cpodes   like iddkdominio.cpodes
 end record

 define ws_pricod    smallint
 define arr_aux      smallint
 define scr_aux      smallint
 define l_etapa      like datmsrvacp.atdetpcod

 define sql_select   char (1000)
 define sql_condicao char (900)
 define sql_comando  char (2000)

 define ws_privez    smallint

 define aux_ano4     char(04)
 define aux_jitre    char(01)

 define w_pf1        integer

 define lr_ret       record
        resultado    smallint,
        mensagem     char(80),
        asitipdes    like datkasitip.asitipdes
 end record

 define l_atdetpcodint  like datmsrvintseqult.atdetpcod

 define l_lclltt like datmlcl.lclltt
 define l_lcllgt like datmlcl.lcllgt
 define l_c24lclpdrcod like datmlcl.c24lclpdrcod

 define l_resultado      smallint
       ,l_mensagem       char(100)
       ,l_atdsrvnum_orig like datratdmltsrv.atdsrvnum
       ,l_atdsrvano_orig like datratdmltsrv.atdsrvano
       ,l_exibe_srv      smallint

 define l_arrrsv  integer
      , l_arritf, l_pri, l_valida  smallint

#PSI 2011-15763 - Integracao Locadora Unidas
#retorno da funcao ctx28g00_stt_listener_locadora nao e validado na funcao
# define l_srvitf record
#        stt     smallint ,
#        errmsg  char(80)
# end record


# Inicio Alteração - Fabrica BRQ - Luiz Gustavo - PSI
 define  lr_atdsrvnum like datmavisrent.atdsrvnum
        ,lr_atdsrvano like datmavisrent.atdsrvano
        ,lr_acntip    like datklocadora.acntip

 let lr_atdsrvnum = null
 let lr_atdsrvano = null
 let lr_acntip    = null

# Fim Alteração - Fabrica BRQ - Luiz Gustavo - PSI

 let l_atdsrvnum_orig = null
 let l_atdsrvano_orig = null
 let l_resultado = 1
 let l_mensagem  = null
 let l_etapa     = null
 let ws_pricod   = null
 let arr_aux     = null
 let scr_aux     = null
 let sql_select  = null
 let sql_condicao = null
 let sql_comando  = null
 let l_sql       = null
 let ws_privez   = null
 let l_nome      = null
 let l_msgmat    = null
 let aux_jitre   = "N"
 let l_exibe_srv = false
 let l_arrrsv    = null
 let l_arritf    = null
 let l_pri       = null
 let l_valida    = null

 for w_pf1  =  1  to  1600
     initialize  a_cts00m01[w_pf1].*  to  null
     initialize  a_motivo[w_pf1]  to  null
     initialize  a_cidade[w_pf1]  to  null
 end for

 for w_pf1  =  1  to  4
     initialize  ws2[w_pf1].*  to  null
 end for

 initialize  w_cts00m01.*  to  null

 initialize  ws.*  to  null

 let l_erro = false

 initialize l_rsvloc.* to null
 initialize a_cts00m01_rsv to null

 if m_prep_cts00m01 is null or
    m_prep_cts00m01 <> true then
    call cts00m01_prepare()
 end if

 let ws_privez = true

 #--------------------------------------------------------------
 # Prepara comandos SQL de acordo conforme parametro
 #--------------------------------------------------------------

 let sql_comando  = "select succod       ",
                    "  from datmvistoria ",
                    " where atdsrvnum = ?",
                    "   and atdsrvano = ?"
 prepare p_cts00m01_003 from sql_comando
 declare c_cts00m01_003 cursor for p_cts00m01_003

 let sql_select = " select datmservico.atdsrvnum   , ",
                         " datmservico.atdsrvano   , ",
                         " datmservico.atdsrvorg   , ",
                         " datmservico.asitipcod   , ",
                         " datmservico.atdlibdat   , ",
                         " datmservico.atdlibhor   , ",
                         " datmservico.atddatprg   , ",
                         " datmservico.atdhorprg   , ",
                         " datmservico.atdlibflg   , ",
                         " datmservico.atdhorpvt   , ",
                         " datmservico.atdpvtretflg, ",
                         " datmservico.atdvcltip   , ",
                         " datmservico.c24opemat   , ",
                         " datmservico.atdprinvlcod,  ",
                         " acnsttflg, acnnaomtv, datmservico.atdfnlflg, ",
                         " datmservico.ciaempcod, ",           #PSI 205206
                         " datmservico.atdetpcod, ",           ##PSI232700 ligia 14/11/08
                         " datmservico.atdrsdflg "

 if lr_param.par_pesq = "vst"   then     #--- servicos vistorias ---
    let sql_condicao = " from datmservico ",
                       " where ",
                       " datmservico.atdlibflg = 'S'  and ",
                       " datmservico.atdfnlflg = 'N'  and ",
                       " datmservico.atdsrvorg =  10    ",
                       " order by atdlibdat, atdlibhor "
 end if

 if lr_param.par_pesq = "nli"   then     #--- servicos nao liberados ---
    let sql_condicao = " from datmservico ",
                       " where ",
                       " datmservico.atdlibflg = 'N' and ",
                       " datmservico.atdfnlflg = 'N' and atdetpcod not in (3,4) ",
                       " order by atdlibdat, atdlibhor   "
 end if

## PSI 186414 - Inicio

 if lr_param.par_pesq = "prg"   then     #--- servicos programados ---    # Marcio Meta PSI186414
    let sql_condicao = "  from datmservico "
    if lr_param.atdprscod is not null then
       let sql_condicao = sql_condicao clipped, ", datmsrvre b "
    end if
    let sql_condicao = sql_condicao clipped,
                       " where datmservico.atdlibflg = 'S' ",
                       "   and datmservico.atdfnlflg in ('N','A') and atdetpcod not in (3,4) ",
                       "   and datmservico.atdsrvorg <> 10 "

    ##-- Definicoes da pesquisa
    if lr_param.data_inicial is not null and lr_param.data_final is not null then
       let sql_condicao = sql_condicao clipped,
                          " and datmservico.atddatprg >= '", lr_param.data_inicial, "'",
                          " and datmservico.atddatprg <= '", lr_param.data_final, "'"
    else
       let sql_condicao = sql_condicao clipped,
                          " and datmservico.atddatprg >= today   "
    end if

    if lr_param.atdsrvorg is not null then
       let sql_condicao = sql_condicao clipped,
                          " and datmservico.atdsrvorg = ", lr_param.atdsrvorg
    end if
    if lr_param.vcllicnum is not null then
       let sql_condicao = sql_condicao clipped,
                          " and datmservico.vcllicnum = '", lr_param.vcllicnum, "'"
    end if
    if lr_param.nome is not null then
       let sql_condicao = sql_condicao clipped,
                          " and datmservico.nom matches '", lr_param.nome, "'"
    end if
    if lr_param.in_empresas is not null then
       let sql_condicao = sql_condicao clipped,
                          " and datmservico.ciaempcod in (", lr_param.in_empresas clipped, ")"
    end if
    if lr_param.atdprscod is not null then
       let sql_condicao = sql_condicao clipped,
                          " and datmservico.atdsrvorg  in (9,13) ",
                          " and datmservico.atdsrvnum  = b.atdsrvnum ",
                          " and datmservico.atdsrvano  = b.atdsrvano ",
                          " and b.atdorgsrvnum in ",
                          " (select c.atdsrvnum   ",
                          "  from datmservico c ",
                          " where c.atdsrvano = b.atdorgsrvano ",
                          "   and c.atdprscod = ",lr_param.atdprscod,")"
    end if
    ##-- Ordenar
    let sql_condicao = sql_condicao clipped,
                       " order by datmservico.atdsrvorg, datmservico.atddatprg, ",
                       "          datmservico.atdhorprg "
 end if                                                            # Marcio Meta PSI186414

## PSI 186414 - Final

 if lr_param.par_pesq = "rsv"   then     #--- reservas locacao ---
    let sql_condicao = " from datmservico ",
                       " where ",
                       " datmservico.atdlibflg  =  'S'  and ",
                       " datmservico.atdfnlflg  =  'N'  and atdetpcod not in (3,4) and ",
                       " datmservico.atdsrvorg  =   8       ",
                       " order by atdlibdat, atdlibhor "
 end if

 if lr_param.par_pesq = "spr"   then     #--- servicos sem previsao ---
    let sql_condicao = " from datmservico ",
                       " where ",
                       " datmservico.atdlibflg  =  'S'  and ",
                       " datmservico.atdfnlflg  =  'N'  and atdetpcod not in (3,4) and ",
                       " datmservico.atdsrvorg  <>  10   and ",
                       " datmservico.atdsrvorg  <>  8   and ",
                       " datmservico.atdhorpvt  = '00:00'   ",
                       " order by atdlibdat, atdlibhor "
 end if

 if lr_param.par_pesq = "can"   then     #--- servicos cancelados pelos atendentes ---#
    let sql_condicao = "  from datmligacao, datmservico, datmsrvacp ",
                       " where datmligacao.ligdat   >= ?            ",
                       "   and datmligacao.c24astcod = 'CAN'        ",
                       "   and datmservico.atdsrvnum = datmligacao.atdsrvnum ",
                       "   and datmservico.atdsrvano = datmligacao.atdsrvano ",
                       "   and datmservico.atdsrvorg  in (1,2,3,4,5,6,7,9,13,17)",
                       "   and datmservico.atdfnlflg = 'S'                   ",
                       "   and datmsrvacp.atdsrvnum  = datmservico.atdsrvnum ",
                       "   and datmsrvacp.atdsrvano  = datmservico.atdsrvano ",
                       "   and datmsrvacp.atdsrvseq  = (select max(atdsrvseq)",
                                                       "  from datmsrvacp    ",
                                                       " where atdsrvnum = datmservico.atdsrvnum ",
                                                       "   and atdsrvano = datmservico.atdsrvano)",
                       "  and datmsrvacp.atdetpcod  <> 5  "
 end if

 if lr_param.par_pesq = "caj"   then     #--- servicos cancelados pelos atendentes ---#
    let sql_condicao = "  from datmservico, datmsrvacp, datmligacao ",
                       " where datmservico.atddat   >= ?            ",
                       "   and datmligacao.c24astcod = 'CAN'        ",
                       "   and datmservico.atdsrvorg = 15",
                       "   and datmservico.atdsrvnum = datmligacao.atdsrvnum ",
                       "   and datmservico.atdsrvano = datmligacao.atdsrvano ",
                       "   and datmsrvacp.atdsrvnum  = datmservico.atdsrvnum ",
                       "   and datmsrvacp.atdsrvano  = datmservico.atdsrvano ",
                       "   and datmsrvacp.atdsrvseq  = (select max(atdsrvseq)",
                                                       "  from datmsrvacp    ",
                                                       " where atdsrvnum = datmservico.atdsrvnum ",
                                                       "   and atdsrvano = datmservico.atdsrvano)",
                       "   and datmsrvacp.atdetpcod  < 5                    "
 end if
  -- CT 4095583
 if lr_param.par_pesq = "car"   then     #--- servicos cancelados pelos atendentes ---#
    let sql_condicao = "  from datmservico, datmsrvacp , datmligacao   ",
                       " where datmservico.atddat   >= ? ",
                       "   and datmservico.atdsrvorg in (9,13) ", # PSI 235849 Adriano Santos 28/01/2009
                       "   and datmligacao.c24astcod = 'CAN'        ",
                       "   and datmservico.atdsrvnum = datmligacao.atdsrvnum ",
                       "   and datmservico.atdsrvano = datmligacao.atdsrvano ",
                       "   and datmsrvacp.atdsrvnum  = datmservico.atdsrvnum ",
                       "   and datmsrvacp.atdsrvano  = datmservico.atdsrvano ",
                       "   and datmsrvacp.atdsrvseq  = (select max(atdsrvseq)",
                                                       "  from datmsrvacp    ",
                                                       " where atdsrvnum = datmservico.atdsrvnum ",
                                                       "   and atdsrvano = datmservico.atdsrvano)",
                       "   and datmsrvacp.atdetpcod  < 5                    "
 end if

 if lr_param.par_pesq = "ret"   then
    let sql_condicao =   " from datmsrvre, datmservico, datmligacao ",
                        " where datmservico.atdsrvnum = datmsrvre.atdsrvnum ",
                          " and datmservico.atdsrvano = datmsrvre.atdsrvano ",
                          " and datmligacao.lignum = (select min(ligmin.lignum) ",
                                                      " from datmligacao ligmin ",
                                                     " where atdsrvnum = datmservico.atdsrvnum ",
                                                       " and atdsrvano = datmservico.atdsrvano) ",
                          " and datmservico.atdfnlflg  in ('N', 'A') ",
                          " and datmservico.atdlibflg = 'S' ",
                          " and datmsrvre.atdorgsrvnum is not null ",
                          " and datmservico.atddatprg > today - 1 units day"
 end if

 if lr_param.par_pesq = "tpa"    or
    lr_param.par_pesq = "grp"    then
    if lr_param.filtro_resumo = "N" then
       if lr_param.par_pesq = "tpa" then
          let l_sql = " select atdsrvnum, "
                     ," atdsrvano, "
                     ," atdsrvorg, "
                     ," asitipcod, "
                     ," atdlibdat, "
                     ," atdlibhor, "
                     ," atddatprg, "
                     ," atdhorprg, "
                     ," atdlibflg, "
                     ," atdhorpvt, "
                     ," atdpvtretflg, "
                     ," atdvcltip, "
                     ," c24opemat, "
                     ," atdprinvlcod, "
                     ," acnsttflg, "  #psi 195138
                     ," acnnaomtv, "  #psi 195138
                     ," atdfnlflg, "  #psi 195138
                     ," ciaempcod, "  #psi 205206
                     ," atdetpcod, "  #psi 205206
                     ," atdrsdflg, "
                     ," case when atddatprg is null then atdlibdat else atddatprg end, "
                     ," case when atddatprg is null then atdlibhor else atdhorprg end "
                  ," from datmservico "
                  ," where atdlibflg = 'S' "
                  ###," and atdfnlflg = 'N' " ##PSI 198714
                  ," and atdsrvorg not in (8,10,9,13) "
          if lr_param.codigo_filtro is not null then
             let l_sql = l_sql clipped , " and asitipcod = ",
                                               lr_param.codigo_filtro
          end if
          if lr_param.flag_ac = 1 then #psi 198714 #Em processo automatico
             let l_sql = l_sql clipped," and atdfnlflg = 'A' and atdetpcod not in (3,4)"
          end if

          if lr_param.flag_ac = 2 then #psi 198714 #Em processo manual
             let l_sql = l_sql clipped," and atdfnlflg = 'N' and atdetpcod not in (3,4)"
          end if

           if lr_param.flag_ac = 3 then # FORA DA RESIDENCIA
             let l_sql = l_sql clipped," and atdfnlflg = 'N' and atdrsdflg <> 'S' and atdetpcod not in (3,4)"
          end if

          if lr_param.flag_ac = 4 then #psi 198714 #Todos pendentes
             let l_sql = l_sql clipped," and atdfnlflg in('A', 'N') and atdetpcod not in (3,4)"
          end if

          let sql_select   =  null
          let sql_condicao =  null
          let sql_comando  =  null
       else
          let l_sql = " select  a.atdsrvnum , "
                             ," a.atdsrvano , "
                             ," a.atdsrvorg , "
                             ," a.asitipcod , "
                             ," a.atdlibdat , "
                             ," a.atdlibhor , "
                             ," a.atddatprg , "
                             ," a.atdhorprg , "
                             ," a.atdlibflg , "
                             ," a.atdhorpvt , "
                             ," a.atdpvtretflg, "
                             ," a.atdvcltip, "
                             ," a.c24opemat, "
                             ," a.atdprinvlcod, "
                             ," a.acnsttflg, "  #psi 195138
                             ," a.acnnaomtv, "  #psi 195138
                             ," a.atdfnlflg, "  #psi 195138
                             ," a.ciaempcod, "  #psi 205206
                             ," a.atdetpcod, "  #psi 205206
                             ," atdrsdflg, "
                             ," case when a.atddatprg is null then a.atdlibdat "
                             ," else a.atddatprg end,"
                             ," case when a.atddatprg is null then a.atdlibhor "
                             ," else a.atdhorprg end"
           if lr_param.codigo_filtro is null then
              let l_sql = l_sql clipped
                         ," from  datmservico a, datmsrvre b "
           else
              let l_sql = l_sql clipped
                         ," from  datmservico a, datmsrvre b, datksocntz c "
           end if

           if lr_param.flag_ac = 1 then #psi 195138 #Em processo automatico
              let l_sql = l_sql clipped
                         ," where a.atdfnlflg = 'A' and atdetpcod not in (3,4)"
           end if

           if lr_param.flag_ac = 2 then #psi 195138 #Em processo manual
              let l_sql = l_sql clipped
                         ," where a.atdfnlflg = 'N' and atdetpcod not in (3,4)"
           end if

           if lr_param.flag_ac = 3 then # FORA DA RESIDENCIA
              let l_sql = l_sql clipped
                         ," where a.atdfnlflg = 'N' and a.atdrsdflg <> 'S' and atdetpcod not in (3,4)"
           end if

           if lr_param.flag_ac = 4 then #psi 195138 #Todos pendentes
              let l_sql = l_sql clipped
                         ," where a.atdfnlflg in('A', 'N') and atdetpcod not in (3,4)"
           end if

           if lr_param.codigo_filtro is null then
              let l_sql = l_sql clipped
                         ,"   and a.atdlibflg = 'S' "
                         ,"   and a.atdsrvnum = b.atdsrvnum "
                         ,"   and a.atdsrvano = b.atdsrvano "
           else
              let l_sql = l_sql clipped
                         ,"   and a.atdlibflg = 'S' "
                         ,"   and a.atdsrvnum = b.atdsrvnum "
                         ,"   and a.atdsrvano = b.atdsrvano "
                         ,"   and b.socntzcod = c.socntzcod "
                         ,"   and c.socntzgrpcod = ", lr_param.codigo_filtro
           end if
       end if
       let l_sql = l_sql clipped," order by 21,22 "  #PSI 205206
       let sql_select   =  null
       let sql_condicao =  null
       let sql_comando  =  null
    end if

    #Selecionar os servicos de acordo com o filtro selecionado na tela cts00m38, onde
    #foi criado e carregado a tabela temporaria.

    if lr_param.filtro_resumo = 'S' then
          let l_sql = " select  a.atdsrvnum, "
                             ," a.atdsrvano, "
                             ," a.atdsrvorg, "
                             ," a.asitipcod, "
                             ," a.atdlibdat, "
                             ," a.atdlibhor, "
                             ," a.atddatprg, "
                             ," a.atdhorprg, "
                             ," a.atdlibflg, "
                             ," a.atdhorpvt, "
                             ," a.atdpvtretflg, "
                             ," a.atdvcltip, "
                             ," a.c24opemat, "
                             ," a.atdprinvlcod, "
                             ," a.acnsttflg, "  #psi 195138
                             ," a.acnnaomtv, "  #psi 195138
                             ," a.atdfnlflg, "   #psi 195138
                             ," a.ciaempcod, "   #psi 205206
                             ," a.atdetpcod, "   #psi 205206
                             ," atdrsdflg, "
                             ," case when a.atddatprg is null then a.atdlibdat "
                             ," else a.atddatprg end,"
                             ," case when a.atddatprg is null then a.atdlibhor "
                             ," else a.atdhorprg end "
         ," from datmservico a ,cts00m38_temp b "
         ," where atdlibflg = 'S' "
         ," and atdfnlflg in('N','A') and atdetpcod not in (3,4)"  #psi 195138
         ," and a.atdsrvnum = b.atdsrvnum "
         ," and a.atdsrvano = b.atdsrvano "
         ," and b.codigo_filtro = ", lr_param.codigo_filtro
         ," order by 21,22 "
       let sql_select   =  null
       let sql_condicao =  null
       let sql_comando  =  null
    end if
 end if

 let sql_comando = sql_select clipped, sql_condicao clipped, l_sql clipped

 prepare p_cts00m01_004 from  sql_comando
 declare c_cts00m01_004  cursor  for p_cts00m01_004

 if lr_param.par_pesq = "caj"   then     #--- servicos cancelados pelos atendentes ---#
    let sql_condicao = "  from datmservico, datmsrvacp ",
                       " where datmservico.atddat   >= ?            ",
                       "   and datmservico.atdsrvorg = 15",
                       "   and datmsrvacp.atdsrvnum  = datmservico.atdsrvnum ",
                       "   and datmsrvacp.atdsrvano  = datmservico.atdsrvano ",
                       "   and datmsrvacp.atdsrvseq  = (select max(atdsrvseq)",
                                                       "  from datmsrvacp    ",
                                                       " where atdsrvnum = datmservico.atdsrvnum ",
                                                       "   and atdsrvano = datmservico.atdsrvano)",
                       "   and datmsrvacp.atdetpcod  = 5                    "
    let sql_comando = sql_select clipped, sql_condicao clipped
    prepare p_cts00m01_005 from  sql_comando
    declare c_cts00m01_005  cursor  for p_cts00m01_005
 end if

#if lr_param.par_pesq = "rsv"  then
    let sql_comando = "select faxch2  from datmfax",
                      " where faxsiscod = 'CT' and",
                      "       faxsubcod = 'RS' and",
                      "       faxch1    = ?       ",
                      " order by faxch2           "
    prepare p_cts00m01_006  from sql_comando
    declare c_cts00m01_006 cursor  for p_cts00m01_006

    let sql_comando = "select faxsttcod from gfxmfax",
                      " where faxsiscod = 'CT'   and",
                      "       faxsubcod = 'RS'   and",
                      "       faxch1    = ?      and",
                      "       faxch2    = ?         "
    prepare p_cts00m01_007  from sql_comando
    declare c_cts00m01_007 cursor  for p_cts00m01_007

    let sql_comando = "select datklocadora.lcvnom ,",
                      "       datklocadora.lcvcod ,",
                      "       datkavislocal.endcid,",
                      "       datkavislocal.endufd,",
                      "       datklocadora.acntip  ",
                      "  from datmavisrent, datklocadora, datkavislocal",
                      " where ",
                      " datmavisrent.atdsrvnum  = ?                      and",
                      " datmavisrent.atdsrvano  = ?                      and",
                      " datkavislocal.aviestcod = datmavisrent.aviestcod and",
                      " datklocadora.lcvcod     = datkavislocal.lcvcod"
    prepare p_cts00m01_008 from sql_comando
    declare c_cts00m01_008 cursor for p_cts00m01_008
#end if

  let sql_comando = "select max(atdsrvseq)",
                    "  from datmsrvacp    ",
                    " where atdsrvnum = ? ",
                    "   and atdsrvano = ? "
  prepare p_cts00m01_009 from sql_comando
  declare c_cts00m01_009 cursor for p_cts00m01_009

  let sql_comando = "select datketapa.atdetpdes     ",
                    "  from datmsrvacp, datketapa   ",
                    " where datmsrvacp.atdsrvnum = ?",
                    "   and datmsrvacp.atdsrvano = ?",
                    "   and datmsrvacp.atdsrvseq = ?",
                    "   and datketapa.atdetpcod = datmsrvacp.atdetpcod"
  prepare p_cts00m01_010 from sql_comando
  declare c_cts00m01_010 cursor for p_cts00m01_010

 let sql_comando = "select srvtipabvdes ",
                   "  from datksrvtip   ",
                   " where atdsrvorg = ?   "

 prepare p_cts00m01_011 from sql_comando
 declare c_cts00m01_011 cursor for p_cts00m01_011

 let sql_comando = "select asitipabvdes ",
                   "  from datkasitip   ",
                   " where asitipcod = ?"

 prepare p_cts00m01_012 from sql_comando
 declare c_cts00m01_012 cursor for p_cts00m01_012

 let sql_comando = "select lignum ",
                   "  from datrligsinvst ",
                   " where sinvstnum = ? ",
                   "   and sinvstano = ? "
 prepare p_cts00m01_013 from sql_comando
 declare c_cts00m01_013 cursor for p_cts00m01_013

 let sql_comando = "select c24astcod ",
                   "  from datmligacao ",
                   " where lignum = ? "
 prepare p_cts00m01_014 from sql_comando
 declare c_cts00m01_014 cursor for p_cts00m01_014

 let sql_comando = "select max(atdetpcod) ",
                   "  from datmsrvintseqult ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? "
 prepare p_cts00m01_015 from sql_comando
 declare c_cts00m01_015 cursor for p_cts00m01_015

 let l_sql = ' select i.itftipcod   , i.itfsttcod   , i.itfgrvhordat '
           , '      , i.vclitfseq   , d.atzdianum   , d.rsvsttcod    '
           , '      , d.rsvlclcod   , i.intsttcrides, i.itfenvhordat '
           , '      , i.itfrethordat '
           , ' from datmrsvvcl d, datmvclrsvitf i '
           , ' where d.atdsrvnum = i.atdsrvnum    '
           , '   and d.atdsrvano = i.atdsrvano    '
           , '   and d.atdsrvnum = ? '
           , '   and d.atdsrvano = ? '
           , ' order by i.vclitfseq desc '
 prepare p_cts00m01_019 from l_sql
 declare c_cts00m01_019 cursor for p_cts00m01_019

 #--------------------------------------------------------------------
 # Cursor para obter a DESCRICAO DA PRIORIDADE DO SERVICO
 #--------------------------------------------------------------------
 declare c_cts00m01_016 cursor for
  select cpocod, cpodes[1,5]
    from iddkdominio
   where cponom = "atdprinvlcod"

 foreach c_cts00m01_016 into ws.atdprinvlcod, ws.atdprinvldes
    if ws.atdprinvlcod = 2 then
       let ws.atdprinvldes[5,5] = "."
    end if
    let ws_pricod = ws.atdprinvlcod
    let ws2[ws_pricod].des = ws.atdprinvldes
 end foreach


 open window cts00m01 at 03,02 with form "cts00m01"
            attribute(form line 1)

 if lr_param.par_pesq = "rsv"  then
    display "Fax"    to envfax
 else
    display "Enviar" to envfax
 end if

 while TRUE

   initialize a_cts00m01    to null
   initialize ws.*          to null
   initialize g_documento.* to null
   let ws.remqtd   =  0
   let ws.assqtd   =  0
   let ws.nlbqtd   =  0
   let ws.prgqtd   =  0
   let ws.vstqtd   =  0
   let ws.resqtd   =  0
   let ws.sprqtd   =  0
   let ws.canqtd   =  0
   let ws.retqtd   =  0
   let int_flag    =  false
   let ws.tempo    =  time
   let ws.horaatu  =  ws.tempo[1,5]

   display ws.tempo to horaatu
   message " Aguarde, pesquisando..."  attribute(reverse)

   # PSI260142 interface via sistema com Localiza, verificar se o servico de
   # interface esta no ar e avisar ao coordenador em caso negativo

   #PSI 2011-15763 - Integracao Locadora Unidas
   #retorno da funcao ctx28g00_stt_listener_locadora nao e validado na funcao
   #call ctx28g00_stt_listener_locadora()
   #     returning l_srvitf.stt, l_srvitf.errmsg

   let arr_aux = 1

   if lr_param.par_pesq  =  "can"   or
      lr_param.par_pesq  =  "caj"   or
      lr_param.par_pesq  =  "car"   or
      lr_param.par_pesq  =  "ret"   then
      let ws.canpsqdat = today
      if ws.horaatu  <  "01:00"   then
         let ws.canpsqdat = today - 1
      end if
      if lr_param.par_pesq  =  "can"   or
         lr_param.par_pesq  =  "caj"   or
         lr_param.par_pesq  =  "car"   then
         open c_cts00m01_004 using ws.canpsqdat
      end if
   end if

   let l_arrrsv = 0

   foreach c_cts00m01_004 into  ws.atdsrvnum                 ,
                                ws.atdsrvano                 ,
                                ws.atdsrvorg                 ,
                                ws.asitipcod                 ,
                                ws.atdlibdat                 ,
                                a_cts00m01[arr_aux].atdlibhor,
                                ws.atddatprg                 ,
                                a_cts00m01[arr_aux].atdhorprg,
                                a_cts00m01[arr_aux].atdlibflg,
                                a_cts00m01[arr_aux].atdhorpvt,
                                ws.atdpvtretflg              ,
                                ws.atdvcltip                 ,
                                ws.c24opemat                 ,
                                ws.atdprinvlcod,
                                ws.acnsttflg, a_motivo[arr_aux],
                                a_cidade[arr_aux].atdfnlflg  , #psi 195138
                                ws.ciaempcod,                  #psi 205206
                                ws.atdetpcod,                  ##PSI 232700 ligia 14/11/08
                                ws.atdrsdflg

      ##PSI 232700 - ligia - 14/11/08
      ##desprezar srv conveniencia em orcamento
      if ws.ciaempcod = 40 and ws.atdetpcod >= 7 then
         continue foreach
      end if

      # desprezar laudo multiplo apenas para RE
      if ws.atdsrvorg = 9 then
         call cts29g00_consistir_multiplo(ws.atdsrvnum, ws.atdsrvano)
            returning l_resultado,l_mensagem
                     ,l_atdsrvnum_orig,l_atdsrvano_orig

         # Se o servico for multiplo de outro servico, despreza-se
          if lr_param.par_pesq <> "can" and lr_param.par_pesq <>  "car" and
             l_resultado = 1 then ##ligia
            continue foreach
         end if
      end if

      #PSI 232700 - ligia - 14/11/08
      ##PortoSeg - exibir somente os servicos emergenciais p/o Radio
      #if ws.ciaempcod = 40 then

      #   let l_exibe_srv = false
      #   call cts00m00_exibe_srv(ws.atdsrvnum,ws.atdsrvano)
      #        returning l_exibe_srv

      #   if l_exibe_srv = false then
      #      continue foreach
      #   end if

      #end if

      #Buscar empresa
      if ws.ciaempcod is not null then
         call cty14g00_empresa(1, ws.ciaempcod)
              returning l_resultado,
                        l_mensagem,
                        a_cts00m01[arr_aux].empresa

         if  ws.ciaempcod = 40 then
             let a_cts00m01[arr_aux].empresa = 'CARTAO'
         else
             if  ws.ciaempcod = 43 then # PSI 247936 Empresas 27
                 let a_cts00m01[arr_aux].empresa = 'PSS'
             end if
         end if
      else
         let a_cts00m01[arr_aux].empresa = "S EMP"
      end if

      # Obter o endereco do servico
      initialize w_cts00m01.* to null

      call ctx04g00_local_prepare(ws.atdsrvnum,ws.atdsrvano,1,ws_privez)
         returning w_cts00m01.*

      # PSI 244589 - Inclusão de Sub-Bairro - Burini
      call cts06g10_monta_brr_subbrr(w_cts00m01.brrnom,
                                     w_cts00m01.lclbrrnom)
           returning w_cts00m01.lclbrrnom

      if w_cts00m01.codigosql < 0  then
         error " Erro (", w_cts00m01.codigosql using "<<<<<&", ") na localizacao do endereco. AVISE A INFORMATICA!"
         close window cts00m01
         let int_flag = false
         let l_erro = true
         exit foreach
      end if

      #Fazer o filtro pela ufdcod
      if lr_param.ufdcod is not null then
         if lr_param.ufdcod <> w_cts00m01.ufdcod  then
            continue foreach
         end if
      end if

      #Fazer o filtro pela cidade ##psi 195138
      if lr_param.cidnom is not null then
         if lr_param.cidnom <> w_cts00m01.cidnom then
            continue foreach
         end if
      end if

      if ws_privez then
         let ws_privez = false
      end if

      let a_cts00m01[arr_aux].local = w_cts00m01.ufdcod clipped, "/",
                                      w_cts00m01.cidnom clipped, "/",
                                      w_cts00m01.lclbrrnom

      if lr_param.par_pesq  = "caj"    then
         select refatdsrvnum,
                refatdsrvano
                into ws.refatdsrvnum,
                     ws.refatdsrvano
           from datmsrvjit
          where atdsrvnum = ws.atdsrvnum
            and atdsrvano = ws.atdsrvano

         if sqlca.sqlcode = 0 then
            select datmsrvacp.atdetpcod
              into ws.atdetpcodrem
              from datmsrvacp
             where atdsrvnum = ws.refatdsrvnum
               and atdsrvano = ws.refatdsrvano
               and atdsrvseq = (select max(atdsrvseq)
                                  from datmsrvacp
                                 where atdsrvnum = ws.refatdsrvnum
                                   and atdsrvano = ws.refatdsrvano)

            if ws.atdetpcodrem <> 5 then
               continue foreach
            end if

            #---------------------------------------------------#
            # VERIFICA SE JIT-RE                                #
            #---------------------------------------------------#
            let aux_ano4 = "20", ws.refatdsrvano using "&&"
            open c_cts00m01_013 using ws.refatdsrvnum, aux_ano4
            fetch c_cts00m01_013 into ws.lignumjre

            if status <> notfound then
               open c_cts00m01_014 using ws.lignumjre
               fetch c_cts00m01_014 into ws.c24astcodjre

               if ws.c24astcodjre = "V12" then
                  continue foreach
               end if
            end if


         else
            continue foreach
         end if
      end if

      if lr_param.par_pesq  =  "ret"   then
         if ws.atdsrvnumsv is not null then
            if ws.atdsrvnumsv = ws.atdsrvnum then
               continue foreach
            end if
         end if
         let ws.atdsrvnumsv = ws.atdsrvnum
      end if

      if lr_param.par_pesq  =  "spr"   then
         if ws.c24opemat  is null   then
            let ws.lockk  = "-"      #--->  nao esta sendo acionado
         else
            let ws.lockk  = "*"      #--->  ja esta sendo acionado
         end if
      else
         let ws.lockk  = "-"
      end if

      let a_cts00m01[arr_aux].servico =  F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),
                                "/"    , F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,7),
                                ws.lockk, F_FUNDIGIT_INTTOSTR(ws.atdsrvano,2)

      let a_cts00m01[arr_aux].srvtipabvdes = "NAO PREV."

      open  c_cts00m01_011 using ws.atdsrvorg
      fetch c_cts00m01_011 into  a_cts00m01[arr_aux].srvtipabvdes
      close c_cts00m01_011

      if ws.atdsrvorg = 9 or
         ws.atdsrvorg = 13 then # PSI 235849 Adriano Santos 28/01/2009
         select socntzcod
              into ws.socntzcod
              from datmsrvre
             where atdsrvnum = ws.atdsrvnum
               and atdsrvano = ws.atdsrvano
         select socntzdes
              into ws.socntzdes
              from datksocntz
             where socntzcod = ws.socntzcod
         let a_cts00m01[arr_aux].srvtipabvdes =
               F_FUNDIGIT_INTTOSTR(ws.socntzcod,3),"-",ws.socntzdes clipped
      end if

      if ws.atdsrvorg = 15   then
         whenever error continue
           select refatdsrvnum,
                  refatdsrvano
                into ws.refatdsrvnum,
                     ws.refatdsrvano
                from datmsrvjit
             where atdsrvnum = ws.atdsrvnum
               and atdsrvano = ws.atdsrvano

            let aux_ano4 = "20" clipped , ws.refatdsrvano using "&&"
            select * from datmpedvist
             where sinvstnum = ws.refatdsrvnum
               and sinvstano = aux_ano4
         whenever error stop
         if sqlca.sqlcode <> notfound then
            let a_cts00m01[arr_aux].srvtipabvdes = "JIT-RE"
         end if
      end if

      if ws.atdpvtretflg = "S"   then
         let a_cts00m01[arr_aux].historico = "RET "
      end if

      if ws.atdsrvorg =  10   then
         if lr_param.par_pesq  =  "prg"   then
            continue foreach
         end if
         initialize ws.lighorinc  to null

         open  c_cts00m01_003 using ws.atdsrvnum, ws.atdsrvano
         fetch c_cts00m01_003 into  ws.succod
         close c_cts00m01_003

         if ws.succod <> g_issk.succod  then
            continue foreach
         end if

         select atdhor into ws.lighorinc
           from datmvstcanc
          where atdsrvnum = ws.atdsrvnum   and
                atdsrvano = ws.atdsrvano

         if ws.lighorinc  is not null   then
            let a_cts00m01[arr_aux].historico =
                a_cts00m01[arr_aux].historico clipped, " ",
                ws.lighorinc,"-","CAN"
         end if
      end if

      if ws.atdsrvorg =  8   then
         initialize ws.lcvnom, ws.cidnom, ws.endufd to null

         open  c_cts00m01_008 using ws.atdsrvnum, ws.atdsrvano
         fetch c_cts00m01_008 into  ws.lcvnom, ws.lcvcod, ws.cidnom, ws.endufd
                                   ,ws.acntip 
         close c_cts00m01_008

         call C24GERAL_TRATBRC(ws.lcvnom) returning ws.lcvnom

         let ws.faxchr = ws.atdsrvnum using "&&&&&&&&",
                         ws.atdsrvano using "&&"
         let ws.faxch1 = ws.faxchr

         initialize ws.faxch2 to null

         open    c_cts00m01_006 using ws.faxch1
         foreach c_cts00m01_006 into  ws.faxch2
         end foreach

         if ws.faxch2 is null  then
            let a_cts00m01[arr_aux].asitipabvdes = "NAO ENV."
         else
            initialize ws.faxsttcod to null

            open  c_cts00m01_007 using ws.faxch1, ws.faxch2
            fetch c_cts00m01_007 into  ws.faxsttcod
            close c_cts00m01_007

            if ws.faxsttcod = 0     or   ###  Transmissao OK (GS-Fax)
               ws.faxsttcod = 5000  then ###  Transmissao OK (VSI-Fax)
               let a_cts00m01[arr_aux].asitipabvdes = "ENVIADO"
            else
               if ws.faxsttcod > 0  then
                  let a_cts00m01[arr_aux].asitipabvdes = "**ERRO**"
               end if
            end if

            if ws.faxsttcod is null  then
               let a_cts00m01[arr_aux].asitipabvdes = "AGUARD."
            end if
         end if
         let ws.resqtd = ws.resqtd + 1

         # dados da interface via web com a Localiza
         initialize l_rsvloc.* to null

         let l_pri = 0
         let l_arritf = 0
         
         let l_arrrsv = l_arrrsv + 1
         
         if l_arrrsv  >  200   then
            error " Limite excedido, mais de 200 reservas"
            continue foreach
         end if

         let a_cts00m01_rsv[l_arrrsv].lcvcod = ws.lcvcod
         let a_cts00m01_rsv[l_arrrsv].lcvnom = ws.lcvnom
         let a_cts00m01_rsv[l_arrrsv].acntip = ws.acntip

         # interface integrada somente para tipo de acionamento online
         if ws.acntip is not null and ws.acntip = 3
            then
            whenever error continue
            open  c_cts00m01_019 using ws.atdsrvnum, ws.atdsrvano
            foreach c_cts00m01_019 into l_rsvloc.itftipcod   , l_rsvloc.itfsttcod ,
                                        l_rsvloc.itfgrvhordat, l_rsvloc.vclitfseq ,
                                        l_rsvloc.atzdianum   , l_rsvloc.rsvsttcod ,
                                        l_rsvloc.rsvlclcod   , l_rsvloc.intsttcrides,
                                        l_rsvloc.itfenvhordat, l_rsvloc.itfrethordat

               if l_pri = 0
                  then
                  let a_cts00m01_rsv[l_arrrsv].servico  = a_cts00m01[arr_aux].servico
                  let a_cts00m01_rsv[l_arrrsv].tipo_doc = 'reserva'   #TODO: na fase 2 alterar para variavel

                  call cty11g00_iddkdominio('rsvsttcod', l_rsvloc.rsvsttcod)
                       returning l_dominio.*

                  let a_cts00m01_rsv[l_arrrsv].sttdoc = l_dominio.cpodes
                  let a_cts00m01_rsv[l_arrrsv].localizador  = l_rsvloc.rsvlclcod

                  call cty11g00_iddkdominio('itftipcod', l_rsvloc.itftipcod)
                       returning l_dominio.*

                  let a_cts00m01_rsv[l_arrrsv].ultitftipdes = l_dominio.cpodes

                  call cty11g00_iddkdominio('itfsttcod', l_rsvloc.itfsttcod)
                       returning l_dominio.*

                  let a_cts00m01_rsv[l_arrrsv].ultitfsttdes = l_dominio.cpodes

                  # display do status da reserva
                  let a_cts00m01[arr_aux].gentxt = a_cts00m01_rsv[l_arrrsv].sttdoc

                  # somente FASE 1, reenvio via fax segue o fluxo do FAX
                  if l_rsvloc.rsvsttcod = 10
                     then
                     let a_cts00m01[arr_aux].gentxt = ""
                  else
                     let a_cts00m01[arr_aux].asitipabvdes = ""
                  end if

                  let a_cts00m01_rsv[l_arrrsv].ultenvhordat = cts00m01_formata_datetime(l_rsvloc.itfenvhordat)
                  let a_cts00m01_rsv[l_arrrsv].ultrethordat = cts00m01_formata_datetime(l_rsvloc.itfrethordat)

                  let a_cts00m01_rsv[l_arrrsv].ultsttcrides01 = l_rsvloc.intsttcrides[01,075]
                  let a_cts00m01_rsv[l_arrrsv].ultsttcrides02 = l_rsvloc.intsttcrides[76,150]

                  let l_pri = 1
               end if

               let l_arritf = l_arritf + 1

               if l_arritf > 30
                  then
                  display 'Numero de interfaces ultrapassou o tamanho do array'
                  exit foreach
               end if

               let a_cts00m01_rsv[l_arrrsv].qtditf = l_arritf

               call cty11g00_iddkdominio('itftipcod', l_rsvloc.itftipcod)
                    returning l_dominio.*

               let a_cts00m01_rsv[l_arrrsv].interfaces[l_arritf].itftipdes = l_dominio.cpodes

               call cty11g00_iddkdominio('itfsttcod', l_rsvloc.itfsttcod)
                    returning l_dominio.*

               let a_cts00m01_rsv[l_arrrsv].interfaces[l_arritf].itfsttdes = l_dominio.cpodes

               let a_cts00m01_rsv[l_arrrsv].interfaces[l_arritf].itfenvhordat = cts00m01_formata_datetime(l_rsvloc.itfenvhordat)
               let a_cts00m01_rsv[l_arrrsv].interfaces[l_arritf].itfrethordat = cts00m01_formata_datetime(l_rsvloc.itfrethordat)

            end foreach

            whenever error stop
         end if

         # Inicio Alteração - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

         if a_cts00m01[arr_aux].gentxt is null or
            a_cts00m01[arr_aux].gentxt = " " then
         	  whenever error continue
         	    open c_cts00m01_020 using  ws.atdsrvano
         	                              ,ws.atdsrvnum

         	    fetch c_cts00m01_020 into  lr_atdsrvnum
                                        ,lr_atdsrvano
                                        ,lr_acntip
         	  whenever error stop


         	  if sqlca.sqlcode = notfound then
         	  	 let a_cts00m01[arr_aux].gentxt = ""
         	  else
         	  	 let a_cts00m01[arr_aux].gentxt = "AGUARDANDO CONFIRMACAO"
         	  end if
         end if
         # Fiim Alteração - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

      end if

      if a_cts00m01[arr_aux].atdhorpvt  =  "00:00"   then
         let ws.sprqtd = ws.sprqtd + 1
      end if

      if a_cts00m01[arr_aux].atdlibflg = "S"   then
         if ws.atddatprg  is null   then
            if ws.atdsrvorg = 4    or
               ws.atdsrvorg = 5    or
               ws.atdsrvorg = 7    or
               ws.atdsrvorg = 17   then
               let ws.remqtd = ws.remqtd + 1
            else
               if ws.atdsrvorg = 6    or
                  ws.atdsrvorg = 1    or
                  ws.atdsrvorg = 2    then
                  if ws.asitipcod = 1  or    ### Guincho
                     ws.asitipcod = 3  then  ### Guincho/Tecnico
                     let ws.remqtd = ws.remqtd + 1
                  else
                     let ws.assqtd = ws.assqtd + 1
                  end if
               else
                  if ws.atdsrvorg = 10   then
                     let ws.vstqtd = ws.vstqtd + 1
                  end if
               end if
            end if
         else
            if (lr_param.par_pesq = "tpa" or
                lr_param.par_pesq = "grp") and
               ws.atddatprg > today then
               continue foreach
            end if

            let ws.prgqtd = ws.prgqtd + 1
         end if
      else
         let ws.nlbqtd = ws.nlbqtd + 1
      end if

      if lr_param.par_pesq  =  "can"  then
         let ws.canqtd = ws.canqtd + 1
      end if

      if lr_param.par_pesq  =  "ret"  then
         let ws.retqtd = ws.retqtd + 1
      end if

      if ws.asitipcod is not null  then
         let a_cts00m01[arr_aux].asitipabvdes = "NAO PREV"

         open  c_cts00m01_012 using ws.asitipcod
         fetch c_cts00m01_012 into a_cts00m01[arr_aux].asitipabvdes
         close c_cts00m01_012
      end if

      if ws.atdvcltip = 1  then
         let a_cts00m01[arr_aux].asitipabvdes = "PLATAF"
      else
         if ws.atdvcltip = 2  then
            let a_cts00m01[arr_aux].asitipabvdes =
                a_cts00m01[arr_aux].asitipabvdes[1,3], " PEQ"
         end if
      end if

      if ws.atdprinvlcod is null then
         let ws.atdprinvlcod = 2         # 2-NORMAL
      end if
      let ws_pricod =  ws.atdprinvlcod
      let a_cts00m01[arr_aux].prioridade = ws2[ws_pricod].des

      open  c_cts00m01_009 using ws.atdsrvnum,
                               ws.atdsrvano
      fetch c_cts00m01_009 into  ws.atdsrvseq
      if sqlca.sqlcode = 0  then
         open  c_cts00m01_010 using ws.atdsrvnum,
                                 ws.atdsrvano,
                                 ws.atdsrvseq
         fetch c_cts00m01_010 into  a_cts00m01[arr_aux].atdetpdes
         close c_cts00m01_010
         let l_atdetpcodint = null
         open c_cts00m01_015 using ws.atdsrvnum,
                                 ws.atdsrvano
         fetch c_cts00m01_015 into l_atdetpcodint
         if l_atdetpcodint  = 2   then
            let a_cts00m01[arr_aux].atdetpdes = "LIB/RECU"
         end if
         if l_atdetpcodint  = 4   then
            let a_cts00m01[arr_aux].atdetpdes = "LIB/EXED"
         end if

         # Inicio Alteração - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

         if a_cts00m01[arr_aux].gentxt = "AGUARDANDO CONFIRMACAO" and
            a_cts00m01[arr_aux].atdetpdes <> "LIBERADO" then
            let a_cts00m01[arr_aux].gentxt = " "
         end if
         
         # Inicio Alteração - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

      end if
      close c_cts00m01_009

      let a_cts00m01[arr_aux].atdlibdat = ws.atdlibdat[1,5]
      let a_cts00m01[arr_aux].atddatprg = ws.atddatprg[1,5]

      if ws_privez = true  then
         let ws_privez = false
      end if

      let a_cts00m01[arr_aux].local = w_cts00m01.ufdcod    clipped, "/",
                                      w_cts00m01.cidnom    clipped, "/",
                                      w_cts00m01.lclbrrnom clipped

      if lr_param.par_pesq = "rsv"  then
         let a_cts00m01[arr_aux].local = ws.lcvnom  clipped, "/",
                                         ws.endufd  clipped, "/",
                                         ws.cidnom  clipped
      end if

      #--------------------------------------------------------------------
      # Verifica se houve reclamacao, alteracao, cancelamento,
      #                   Consulta oficina indicada ou consulta do servico
      #--------------------------------------------------------------------
      declare c_cts00m01_017  cursor for
         select lighorinc, c24astcod
           from datmligacao
          where atdsrvnum = ws.atdsrvnum            and
                atdsrvano = ws.atdsrvano            and
                c24astcod   in ("ALT","CAN","REC","RET","CON","IND")

      foreach c_cts00m01_017  into  ws.lighorinc,
                                   ws.ligastcod

         let a_cts00m01[arr_aux].historico =
             a_cts00m01[arr_aux].historico clipped, " ",
             ws.lighorinc, "-", ws.ligastcod

      end foreach

      # --> VERIFICA SE O SERVICO ESTA NA RESIDENCIA
      if ws.atdrsdflg <> "S" then
         let a_cts00m01[arr_aux].rsdflg = "PRIORIZAR"
      else
         let a_cts00m01[arr_aux].rsdflg = null
      end if

      #-----------------------------------------
      # Calcula Tempo de Espera
      #-----------------------------------------
      if ws.atddatprg  is null     or
         ws.atddatprg  <=  today   then
         if a_cts00m01[arr_aux].atdhorprg  is null   then
            let a_cts00m01[arr_aux].atddatprg = "IMED."
            if ws.atdlibdat  =  today   then
               let a_cts00m01[arr_aux].espera  =
                   ws.horaatu - a_cts00m01[arr_aux].atdlibhor
            else
              let ws.h24       =  "23:59"
              let a_cts00m01[arr_aux].espera = ws.h24 - a_cts00m01[arr_aux].atdlibhor
              let ws.h24       =  "00:00"
              let a_cts00m01[arr_aux].espera  =
              a_cts00m01[arr_aux].espera + (ws.horaatu - ws.h24) + "00:01"
            end if
         else
           if ws.atddatprg = today                       and
              a_cts00m01[arr_aux].atdhorprg <> "00:00"   then
              let a_cts00m01[arr_aux].espera =
                  ws.horaatu - a_cts00m01[arr_aux].atdhorprg
           end if
         end if
      end if

      open c_cts00m01_001 using ws.atdsrvnum, ws.atdsrvano
      let l_lclltt = ''
      let l_lcllgt = ''
      let l_c24lclpdrcod = 0

      whenever error continue
      fetch c_cts00m01_001 into l_lclltt, l_lcllgt,
                              a_cidade[arr_aux].cidnom,
                              a_cidade[arr_aux].ufdcod,
                              l_c24lclpdrcod
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let l_lclltt = null
            let l_lcllgt = null
         else
            error 'Erro SELECT ccts00m01002:', sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
            error 'cts00m01/ ', ws.atdsrvnum,' / ', ws.atdsrvano sleep 2
            let l_erro = true
            exit foreach
         end if
      end if

      let a_cts00m01[arr_aux].sindex = ''

      if ws.atdsrvorg <> 8  and
         ws.atdsrvorg <> 11 and
         ws.atdsrvorg <> 12 and
         ws.atdsrvorg <> 16 then

         call cts00m00_sindex
              (a_cidade[arr_aux].ufdcod, a_cidade[arr_aux].cidnom,
               ws.atdsrvorg, l_lclltt, l_lcllgt, l_c24lclpdrcod)
              returning a_cts00m01[arr_aux].sindex

      end if

      if (a_cidade[arr_aux].atdfnlflg = "N" and ws.acnsttflg = "N")
          then ## psi 195138
         let a_cts00m01[arr_aux].historico ='NAO ACIONADO AUTOMATICO'
      end if

      if (a_cidade[arr_aux].atdfnlflg = "A" and a_motivo[arr_aux] is not null)
          then ##  ligia 21/12/2006
         let a_cts00m01[arr_aux].historico ='EM ACIONAMENTO AUTOMATICO'
      end if

      let arr_aux = arr_aux + 1
      if arr_aux  >  1600   then
         error " Limite excedido, tabela de servicos com mais de 1600 itens!"
         exit foreach
      end if

   end foreach

   close c_cts00m01_004

   if l_erro then
      exit while
   end if

   #hpnnovo
   if lr_param.par_pesq  =  "caj"   then

      open c_cts00m01_005 using ws.canpsqdat
      foreach c_cts00m01_005 into  ws.atdsrvnum                 ,
                                   ws.atdsrvano                 ,
                                   ws.atdsrvorg                 ,
                                   ws.asitipcod                 ,
                                   ws.atdlibdat                 ,
                                   a_cts00m01[arr_aux].atdlibhor,
                                   ws.atddatprg                 ,
                                   a_cts00m01[arr_aux].atdhorprg,
                                   a_cts00m01[arr_aux].atdlibflg,
                                   a_cts00m01[arr_aux].atdhorpvt,
                                   ws.atdpvtretflg              ,
                                   ws.atdvcltip                 ,
                                   ws.c24opemat                 ,
                                   ws.atdprinvlcod              ,
                                   ws.ciaempcod                 ,    #PSI 205206
                                   ws.atdrsdflg

         select refatdsrvnum, refatdsrvano
           into ws.refatdsrvnum, ws.refatdsrvano
           from datmsrvjit
          where atdsrvnum = ws.atdsrvnum
            and atdsrvano = ws.atdsrvano

         if sqlca.sqlcode <> 0 then
            continue foreach
         end if

         #---------------------------------------------------#
         # VERIFICA SE JIT-RE                                #
         #---------------------------------------------------#
         let aux_ano4 = "20", ws.refatdsrvano using "&&"
         open c_cts00m01_013 using ws.refatdsrvnum, aux_ano4
         fetch c_cts00m01_013 into ws.lignumjre

         if status = notfound then
            continue foreach
         end if

         open c_cts00m01_014 using ws.lignumjre
         fetch c_cts00m01_014 into ws.c24astcodjre

         if ws.c24astcodjre <> "V12" then
            continue foreach
         end if

         let ws.lockk  = "-"

         let a_cts00m01[arr_aux].servico =  F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),
                                   "/"    , F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,7),
                                   ws.lockk, F_FUNDIGIT_INTTOSTR(ws.atdsrvano,2)

         let a_cts00m01[arr_aux].srvtipabvdes = "NAO PREV."

         open  c_cts00m01_011 using ws.atdsrvorg
         fetch c_cts00m01_011 into  a_cts00m01[arr_aux].srvtipabvdes
         close c_cts00m01_011

         if ws.atdsrvorg = 15   then
            whenever error continue
              select refatdsrvnum,
                     refatdsrvano
                   into ws.refatdsrvnum,
                        ws.refatdsrvano
                   from datmsrvjit
                where atdsrvnum = ws.atdsrvnum
                  and atdsrvano = ws.atdsrvano

               let aux_ano4 = "20" clipped , ws.refatdsrvano using "&&"
               select * from datmpedvist
                where sinvstnum = ws.refatdsrvnum
                  and sinvstano = aux_ano4
            whenever error stop
            if sqlca.sqlcode <> notfound then
               let a_cts00m01[arr_aux].srvtipabvdes = "JIT-RE"
            end if
         end if

         if a_cts00m01[arr_aux].atdhorpvt  =  "00:00"   then
            let ws.sprqtd = ws.sprqtd + 1
         end if

         let ws.canqtd = ws.canqtd + 1

         open  c_cts00m01_009 using ws.atdsrvnum,
                                  ws.atdsrvano
         fetch c_cts00m01_009 into  ws.atdsrvseq
         if sqlca.sqlcode = 0  then
            open  c_cts00m01_010 using ws.atdsrvnum,
                                    ws.atdsrvano,
                                    ws.atdsrvseq
            fetch c_cts00m01_010 into  a_cts00m01[arr_aux].atdetpdes
            close c_cts00m01_010
         end if
         close c_cts00m01_009

         let a_cts00m01[arr_aux].atdlibdat = ws.atdlibdat[1,5]
         let a_cts00m01[arr_aux].atddatprg = ws.atddatprg[1,5]

         initialize w_cts00m01.*  to null

         call ctx04g00_local_prepare(ws.atdsrvnum, ws.atdsrvano, 1, ws_privez)
                           returning w_cts00m01.*

         # PSI 244589 - Inclusão de Sub-Bairro - Burini
         call cts06g10_monta_brr_subbrr(w_cts00m01.brrnom,
                                        w_cts00m01.lclbrrnom)
              returning w_cts00m01.lclbrrnom

         if w_cts00m01.codigosql < 0  then
            error " Erro (", w_cts00m01.codigosql using "<<<<<&", ") na localizacao do endereco. AVISE A INFORMATICA!"
            close window cts00m01
            return
         end if

         if ws_privez = true  then
            let ws_privez = false
         end if

         let a_cts00m01[arr_aux].local = w_cts00m01.ufdcod    clipped, "/",
                                         w_cts00m01.cidnom    clipped, "/",
                                         w_cts00m01.lclbrrnom clipped

         #--------------------------------------------------------------------
         # Verifica se houve reclamacao, alteracao, cancelamento,
         #                   Consulta oficina indicada ou consulta do servico
         #--------------------------------------------------------------------
         declare c_cts00m01_018 cursor for
            select lighorinc, c24astcod
              from datmligacao
             where atdsrvnum = ws.atdsrvnum            and
                   atdsrvano = ws.atdsrvano            and
                   c24astcod   in ("ALT","CAN","REC","RET","CON","IND")

         foreach c_cts00m01_018 into ws.lighorinc,
                                      ws.ligastcod

            let a_cts00m01[arr_aux].historico =
                a_cts00m01[arr_aux].historico clipped, " ",
                ws.lighorinc, "-", ws.ligastcod

         end foreach

         #-----------------------------------------
         # Calcula Tempo de Espera
         #-----------------------------------------
         if ws.atddatprg  is null     or
            ws.atddatprg  <=  today   then
            if a_cts00m01[arr_aux].atdhorprg  is null   then
               let a_cts00m01[arr_aux].atddatprg = "IMED."
               if ws.atdlibdat  =  today   then
                  let a_cts00m01[arr_aux].espera  =
                      ws.horaatu - a_cts00m01[arr_aux].atdlibhor
               else
                 let ws.h24       =  "23:59"
                 let a_cts00m01[arr_aux].espera = ws.h24 - a_cts00m01[arr_aux].atdlibhor
                 let ws.h24       =  "00:00"
                 let a_cts00m01[arr_aux].espera  =
                 a_cts00m01[arr_aux].espera + (ws.horaatu - ws.h24) + "00:01"
               end if
            else
              if ws.atddatprg = today                       and
                 a_cts00m01[arr_aux].atdhorprg <> "00:00"   then
                 let a_cts00m01[arr_aux].espera =
                     ws.horaatu - a_cts00m01[arr_aux].atdhorprg
              end if
            end if
         end if

         open c_cts00m01_001 using ws.atdsrvnum, ws.atdsrvano

         whenever error continue
         fetch c_cts00m01_001 into l_lclltt, l_lcllgt,
                                 a_cidade[arr_aux].cidnom,
                                 a_cidade[arr_aux].ufdcod,
                                 l_c24lclpdrcod
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               let l_lclltt = null
               let l_lcllgt = null
            else
               error 'Erro SELECT ccts00m01002:', sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
               error 'cts00m01/ ', ws.atdsrvnum,' / ', ws.atdsrvano sleep 2
               let l_erro = true
               exit foreach
            end if
         end if

         let a_cts00m01[arr_aux].sindex = ''

         if ws.atdsrvorg <> 8  and
            ws.atdsrvorg <> 11 and
            ws.atdsrvorg <> 12 and
            ws.atdsrvorg <> 16 then

            call cts00m00_sindex
                 (a_cidade[arr_aux].ufdcod, a_cidade[arr_aux].cidnom,
                  ws.atdsrvorg, l_lclltt, l_lcllgt, l_c24lclpdrcod)
                 returning a_cts00m01[arr_aux].sindex

         end if

         #PSI 205206
         #Descrever empresa
         if ws.ciaempcod is not null then
            call cty14g00_empresa(1, ws.ciaempcod)
                 returning l_resultado,
                           l_mensagem,
                           a_cts00m01[arr_aux].empresa

            if  a_cts00m01[arr_aux].empresa = 'PORTOSEG S/A' then
                let a_cts00m01[arr_aux].empresa = 'CARTAO'
            end if
         else
            let a_cts00m01[arr_aux].empresa = "S EMP"
         end if

         let arr_aux = arr_aux + 1
         if arr_aux  >  1600   then
            error " Limite excedido, tabela de servicos com mais de 1600 itens!"
            exit foreach
         end if

      end foreach

      if l_erro then
         exit while
      end if

   end if

   if lr_param.par_pesq  =  "rem"   then
      if arr_aux = 1   then
         error " Nao existem remocoes pendentes!"
      end if
      let ws.cabec = "Remocoes: ",  ws.remqtd   using "&&&"
   end if

   if lr_param.par_pesq  =  "ass"   then
      if arr_aux = 1   then
         error " Nao existem assistencias pendentes!"
      end if
     let ws.cabec = "Assistencias: ",  ws.assqtd   using "&&&"
   end if

   if lr_param.par_pesq  =  "vst"   then
      if arr_aux = 1   then
         error " Nao existem vistorias pendentes!"
      end if
     let ws.cabec = "Vistorias: ",  ws.vstqtd  using "&&&"
   end if

   if lr_param.par_pesq  =  "nli"   then
      if arr_aux = 1   then
         error " Nao existem servicos nao liberados pendentes!"
      end if
     let ws.cabec = "Nao Liberados: ",  ws.nlbqtd   using "&&&"
   end if

   if lr_param.par_pesq  =  "prg"   then
      if arr_aux = 1   then
         error " Nao existem servicos programados pendentes!"
      end if
     let ws.cabec = "Programados: ", ws.prgqtd using "<<<&&&" #ligia 31/07/08
   end if

   if lr_param.par_pesq  =  "rsv"   then
      if arr_aux = 1   then
         error " Nao existem reservas de locacao pendentes!"
      end if
     let ws.cabec = "Reservas: ",  ws.resqtd   using "&&&"
   end if

   if lr_param.par_pesq  =  "spr"   then
      if arr_aux = 1   then
         error " Nao existem servicos sem previsao pendentes!"
      end if
     let ws.cabec = "Sem Previsao: ",  ws.sprqtd  using "&&&"
   end if

   if lr_param.par_pesq  =  "can"   then
      if arr_aux = 1   then
         error " Nao existem servicos cancelados!"
      end if
     let ws.cabec = "Cancelados: ",  ws.canqtd  using "&&&"
   end if

   if lr_param.par_pesq  =  "ret"   then
      if arr_aux = 1   then
         error " Nao existem servicos com retorno marcado!"
      end if
     let ws.cabec = "Retornos: ",  ws.retqtd  using "&&&"
   end if

   #Exibir Total de servicos selecionados pelo filtro
   if lr_param.par_pesq  =  'tpa' or lr_param.par_pesq  = 'grp' then
      if arr_aux = 1  then
         error " Nao existem servicos por este filtro"
      end if
      if lr_param.codigo_filtro is not null then
         if lr_param.par_pesq  =  "tpa"  then
            #Obter a descricao do tipo de assistencia
            call ctn25c00_descricao(lr_param.codigo_filtro)
                 returning lr_ret.resultado
                          ,lr_ret.mensagem
                          ,lr_ret.asitipdes
         else
            #Obter a descricao do grupo da natureza
            call ctx24g00_descricao(lr_param.codigo_filtro)
                 returning lr_ret.resultado
                          ,lr_ret.mensagem
                          ,lr_ret.asitipdes
         end if
         let ws.cabec = lr_ret.asitipdes clipped,': ',(arr_aux - 1) using "&&&"
      else
         ## Exibir total servicos na UF
         let ws.cabec = "TODOS EM ", lr_param.ufdcod clipped,': ',(arr_aux - 1) using "&&&"
      end if
   end if

   display ws.cabec  to  cabec

   call set_count(arr_aux-1)

   if lr_param.par_pesq = "rsv"
      then
      message " (F5)Motivo, (F6)Nova consulta, (F8)Laudo (F9)Detalhe reserva "
   else
      message " (F5)Motivo, (F6)Nova consulta, (F8)Laudo" # psi195138
   end if

   display array a_cts00m01 to s_cts00m01.*

      on key (interrupt,control-c)
         let int_flag = true
         exit display

      on key (F5) # psi195138
         let arr_aux = arr_curr()
         call cts00m00_exibe_motivo(a_motivo[arr_aux])
      #-----------------------------------------
      # Nova Consulta
      #-----------------------------------------
      on key (F6)
         exit display

      #-----------------------------------------
      # Laudos de Servico
      #-----------------------------------------
      on key (F8)
         let arr_aux = arr_curr()

         if a_cts00m01[arr_aux].servico is null  then
            exit display
         end if

         let g_documento.atdsrvnum = a_cts00m01[arr_aux].servico[4,10]
         let g_documento.atdsrvano = a_cts00m01[arr_aux].servico[12,13]

         if a_cidade[arr_aux].atdfnlflg <> "S" then
            #Caso o servico nao foi acionado/concluido

            #Verifica se o servico esta em uso
            call cts40g18_srv_em_uso(g_documento.atdsrvnum,
                                     g_documento.atdsrvano)
                 returning l_em_uso,
                           ws.c24opemat

            if l_em_uso then
               # Se o servico estiver em acionamento, Exibe mensagem de critica
               open c_cts00m01_002 using ws.c24opemat
               fetch c_cts00m01_002 into l_nome
               close c_cts00m01_002

               let l_msgmat = "Nome: ", l_nome clipped
               let ws.msg   = "Matricula: ", ws.c24opemat using "<<<<<&"

               call cts08g01("A", "",
                             "Servico em uso",
                             ws.msg,
                             l_msgmat,
                             "")
                 returning ws.resp
            end if
         else
            let l_em_uso = false
         end if


         if l_em_uso = false then

            if a_cts00m01[arr_aux].srvtipabvdes = "JIT-RE" then
               select refatdsrvnum,
                      refatdsrvano
                 into ws.refatdsrvnum,
                      ws.refatdsrvano
                 from datmsrvjit
                where atdsrvnum = g_documento.atdsrvnum
                  and atdsrvano = g_documento.atdsrvano

               if sqlca.sqlcode = 0 then
                  let aux_ano4 = "20" clipped, ws.refatdsrvano using "&&"

                  select * from datmpedvist
                   where sinvstnum = ws.refatdsrvnum
                     and sinvstano = aux_ano4

                  if sqlca.sqlcode = 0 then
                     call cts21m03(ws.refatdsrvnum, aux_ano4)
                     exit display
                  end if
               end if
            else

               if lr_param.par_pesq  =  "spr"    then
                  if cts04g00('cts00m01') = true  then
                     exit display
                  end if
               else
                  if cts04g00('cts00m01') = true  then
                     exit display
                  end if
               end if
            end if

         end if

      # exibir detalhes da reserva (somente Localiza)
      on key (F9)

         let l_valida = 0
         let arr_aux = arr_curr()

         # display 'ws.lcvcod(05): ', ws.lcvcod
         # display 'a_cts00m01_rsv[arr_aux].lcvcod(01): ', a_cts00m01_rsv[arr_aux].lcvcod
         # display 'arr_aux                             : ', arr_aux
         # display 'a_cts00m01_rsv[arr_aux].servico     : ', a_cts00m01_rsv[arr_aux].servico
         # display 'a_cts00m01_rsv[arr_aux].lcvcod      : ', a_cts00m01_rsv[arr_aux].lcvcod
         # display 'a_cts00m01_rsv[arr_aux].tipo_doc    : ', a_cts00m01_rsv[arr_aux].tipo_doc
         # display 'a_cts00m01_rsv[arr_aux].sttdoc      : ', a_cts00m01_rsv[arr_aux].sttdoc
         # display 'a_cts00m01_rsv[arr_aux].localizador : ', a_cts00m01_rsv[arr_aux].localizador
         # display 'a_cts00m01_rsv[arr_aux].ultitftipdes: ', a_cts00m01_rsv[arr_aux].ultitftipdes
         # display 'a_cts00m01_rsv[arr_aux].ultitfsttdes: ', a_cts00m01_rsv[arr_aux].ultitfsttdes
         # display 'a_cts00m01_rsv[arr_aux].servico(2): ', a_cts00m01_rsv[arr_aux].servico
         # display 'a_cts00m01_rsv[arr_aux].qtditf (2): ', a_cts00m01_rsv[arr_aux].qtditf

         while true

            if a_cts00m01_rsv[arr_aux].lcvcod is null
               then
               error ' Locadora nao identificada, contate informatica '
               exit while
            end if

            if a_cts00m01_rsv[arr_aux].acntip != 3
               then
               error ' Detalhe da reserva disponivel somente para tipo de acionamento online '
               exit while
            end if

            if a_cts00m01_rsv[arr_aux].servico is null
               then
               error ' Nao foi localizada solicitacao via sistema para esta reserva '
               exit while
            end if

            whenever error continue

            if l_valida = 0
               then
               open window cts00m41 at 06,02 with form "cts00m41"
                    attribute(form line first, message line last)

               message " (Ctrl+C)Sair "

               display a_cts00m01_rsv[arr_aux].servico        to servico
               display a_cts00m01_rsv[arr_aux].lcvnom         to lcvnom
               display a_cts00m01_rsv[arr_aux].tipo_doc       to tipo_doc
               display a_cts00m01_rsv[arr_aux].sttdoc         to sttdoc
               display a_cts00m01_rsv[arr_aux].localizador    to localizador
               display a_cts00m01_rsv[arr_aux].ultitftipdes   to ultitftipdes
               display a_cts00m01_rsv[arr_aux].ultitfsttdes   to ultitfsttdes
               display a_cts00m01_rsv[arr_aux].ultenvhordat   to ultenvhordat
               display a_cts00m01_rsv[arr_aux].ultrethordat   to ultrethordat
               display a_cts00m01_rsv[arr_aux].ultsttcrides01 to ultsttcrides01
               display a_cts00m01_rsv[arr_aux].ultsttcrides02 to ultsttcrides02

               call set_count(a_cts00m01_rsv[arr_aux].qtditf)

               display array a_cts00m01_rsv[arr_aux].interfaces to s_cts00m41.*

                  on key (interrupt,control-c)
                     let int_flag = true
                     exit display

               end display

               let int_flag = false
               close window cts00m41
               exit while
            end if

            whenever error stop

         end while

   end display

   if int_flag   then
      exit while
   end if

end while

initialize g_documento.* to null
close window  cts00m01
let int_flag = false

end function  ## cts00m01

#----------------------------------------------------------------
function cts00m01_formata_datetime(l_dyts)
#----------------------------------------------------------------
  define l_dyts datetime year to second
  define l_txt  char(19)
  define l_dat  date

  initialize l_txt, l_dat to null

  let l_txt = l_dyts
  let l_dat = l_dyts
  let l_txt = l_dat using "dd/mm/yyyy", " ", l_txt[12,19]

  return l_txt

end function
