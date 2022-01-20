############################################################################ #
# Nome do Modulo: CTS04M00                                         Marcelo   #
#                                                                  Gilberto  #
# Laudo - Sinistro Ramos Elementares                               Out/1998  #
############################################################################ #
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#--------------------------------------------------------------------------- #
# 21/10/1998  PSI 6955-8   Gilberto     Retirar aviso que informa sobre      #
#                                       informacoes complementares no        #
#                                       historico (funcao CTS11G00).         #
#--------------------------------------------------------------------------- #
# 11/11/1998  Probl.Ident  Gilberto     Corrigir retorno da funcao CTS21M04. #
#--------------------------------------------------------------------------- #
# 23/11/1998  PSI 7214-1   Gilberto     Alterar funcao de gravacao da liga-  #
#                                       cao (CTS10G00), passando parametros  #
#                                       de registro via formulario.          #
#--------------------------------------------------------------------------- #
# 24/03/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao do ende-   #
#                                       reco atraves do guia postal.         #
#--------------------------------------------------------------------------- #
# 29/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti-  #
#                                       ma etapa do servico.                 #
#--------------------------------------------------------------------------- #
# 11/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de endereco a    #
#                                       serem excluidos.                     #
#--------------------------------------------------------------------------- #
# 10/09/1999  PSI 9119-7   Wagner       Incluir Historico no modulo cts06g03 #
#                                       e padroniza gravacao do historico.   #
#--------------------------------------------------------------------------- #
# 23/09/1999  PSI 9164-2   Wagner       Bloqueia servico ate o retorno do    #
#                                       historico.(Inclusao)                 #
#--------------------------------------------------------------------------- #
# 20/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga-  #
#                                       cao (CTS10G00) para gravar as tabe-  #
#                                       las de relacionamento.               #
#--------------------------------------------------------------------------- #
# 12/11/1999  PSI 9118-9   Gilberto     Retirada do campo LIGREF.            #
#--------------------------------------------------------------------------- #
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de   #
#                                       ligacoes x propostas.                #
#--------------------------------------------------------------------------- #
# 04/02/2000  PSI 10206-7  Wagner       Incluir manutencao no campo nivel    #
#                                       prioridade atendimento.              #
#--------------------------------------------------------------------------- #
# 13/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de       #
#                                       solicitante.                         #
#--------------------------------------------------------------------------- #
# 05/06/2000  PSI 10865-0  Akio         Gravacao da tabela DATMSERVICO       #
#                                       via funcao                           #
#--------------------------------------------------------------------------- #
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03          #
#--------------------------------------------------------------------------- #
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg  #
#                                       Exibicao do atdsrvnum (dec 10,0)     #
#--------------------------------------------------------------------------- #
# 01/09/2000  PSI 11459-6  Wagner       Incluir acionamento do servico apos  #
#                                       retorno do historico p/atendentes.   #
#--------------------------------------------------------------------------- #
# 25/09/2000  PSI 11253-4  Ruiz         Grava oficina na datmlcl para o      #
#                                       relatorio bdata080.                  #
#--------------------------------------------------------------------------- #
# 29/11/2000               Raji         Inclusao do paramentro codigo da     #
#                                       oficina destino para laudos          #
#--------------------------------------------------------------------------- #
# 08/12/2000  PSI 11549-5  Raji         Inclusao do codigo do problema /     #
#                                       defeito.                             #
#--------------------------------------------------------------------------- #
# 14/02/2001               Raji         Atalho p/ visualizacao Pto Referecia #
#--------------------------------------------------------------------------- #
# 01/03/2002    Correio    Wagner       Incluir dptsgl psocor na pesquisa.   #
#--------------------------------------------------------------------------- #
# 10/10/2002  PSI 16258-2  Wagner       Incluir acesso a funcao informativo  #
#                                       convenio ctx17g00.                   #
#--------------------------------------------------------------------------- #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86                #
############################################################################ #
#                                                                            #
#                      * * * Alteracoes * * *                                #
#                                                                            #
# Data        Autor Fabrica  Origem    Alteracao                             #
# ----------  -------------- --------- --------------------------------------#
# 15/09/2003  Meta,Bruno     PSI172065 Inclusao na tela do campo Vist. Ref.  #
#                            OSF026166 e criacao da funcao (F8)Laudo.        #
# ---------------------------------------------------------------------------#
# 19/09/2003  Meta,Gustavo   PSI175552 Inibir a chamada da funcao I. Conv.   #
#                            OSF026077 "ctx17g00_assist".                    #
# ---------------------------------------------------------------------------#
# 24/10/2003  Meta,Bruno     PSI168890 Chamar funcao cts12g00 com 3 (tres)   #
#                            OSF027847 parametros.                           #
# ---------------------------------------------------------------------------#
# 17/11/2003  Meta,Paulo     PSI179345 Usar o atributo grlinf para controlar #
#                            OSF28851  se janela "confirma o acionamento do  #
#                                      servico" deve ou nao ser aberta       #
# ---------------------------------------------------------------------------#
# 18/05/2005  Solda,Meta     PSI191108 Implementar o codigo da via(emeviacod)#
# ---------------------------------------------------------------------------#
# 01/02/2006  Priscila      Zeladoria  Buscar data e hora do banco de dados  #
# ---------------------------------------------------------------------------#
# 19/07/2006  Adriano, Meta  Migracao  Migracao de versao do 4gl.            #
# ---------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta  Psi223689  Incluir tratamento de erro com a      #
#                                         global                             #
# ---------------------------------------------------------------------------#
# 20/02/2009 Nilo           Psi234311  Danos Eletricos                       #
# ---------------------------------------------------------------------------#
# 13/08/2009 Sergio Burini  PSI244236  Inclusão do Sub-Dairro                #
# ---------------------------------------------------------------------------#
# 04/01/2010 Amilton                   projeto sucursal smallint             #
#----------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo PSI 219444.Passar/receber em "ctf00m08_gera_p10" #
#                                      os parametros (lclnumseq / rmerscseq) #
#                                     .Trocar a funcao cts21m04 por framc215 #
#                                     .Trocar a funcao cts06g01 por framo240 #
#----------------------------------------------------------------------------#
#
##############################################################################
# 26/09/2012  Raul Biztalking          Retirar empresa 1 fixa p/ funcionario #
#----------------------------------------------------------------------------#
 globals "/homedsa/projetos/geral/globals/glct.4gl"
 globals "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689

 define d_cts04m00    record
    srvnum            char (13)                    ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (32)                    ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    cvnnom            char (20)                    ,
    lclrsccod         like datmsrvre.lclrsccod     ,
    lclrscflg         char (01)                    ,
    orrdat            like datmsrvre.orrdat        ,
    orrhor            like datmsrvre.orrhor        ,
    sinntzcod         like datmsrvre.sinntzcod     ,
    sinntzdes         like sgaknatur.sinntzdes     ,
    c24pbmcod         like datkpbm.c24pbmcod       ,
    atddfttxt         like datmservico.atddfttxt   ,
    socntzcod         like datmsrvre.socntzcod     ,  ---> Danos Eletricos
    socntzdes         like datksocntz.socntzdes    ,
    asitipcod         like datmservico.asitipcod   ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    atdprinvlcod      like datmservico.atdprinvlcod,
    atdprinvldes      char (06)                    ,
    prslocflg         char (01)                    ,
    imdsrvflg         char (01)                    ,
    atdlibflg         like datmservico.atdlibflg   ,
    frmflg            char (01)                    ,
    atdtxt            char (64)                    ,
    sinvstnum         like datmpedvist.sinvstnum   ,  ## PSI 172065
    sinvstano         like datmpedvist.sinvstano      ## PSI 172065
 end record

 define w_cts04m00    record
    ano               char (02)                    ,
    lignum            like datrligsrv.lignum       ,
    viginc            like rsdmdocto.viginc        ,
    vigfnl            like rsdmdocto.vigfnl        ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    funmat            like datmservico.funmat      ,
    ligcvntip         like datmligacao.ligcvntip,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    c24opemat         like datmservico.c24opemat   ,
    c24nomctt         like datmservico.c24nomctt   ,
    atdprscod         like datmservico.atdprscod   ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atdpvtretflg      like datmservico.atdpvtretflg,
    atdlibflg         like datmservico.atdlibflg   ,
    atdfnlflg         like datmservico.atdfnlflg   ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    atdvclsgl         like datmsrvacp.atdvclsgl    ,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    socvclcod         like datmservico.socvclcod
 end record

 define a_cts04m00    array[1] of record
    operacao     char (01)
   ,lclidttxt    like datmlcl.lclidttxt
   ,lgdtxt       char (65)
   ,lgdtip       like datmlcl.lgdtip
   ,lgdnom       like datmlcl.lgdnom
   ,lgdnum       like datmlcl.lgdnum
   ,brrnom       like datmlcl.brrnom
   ,lclbrrnom    like datmlcl.lclbrrnom
   ,endzon       like datmlcl.endzon
   ,cidnom       like datmlcl.cidnom
   ,ufdcod       like datmlcl.ufdcod
   ,lgdcep       like datmlcl.lgdcep
   ,lgdcepcmp    like datmlcl.lgdcepcmp
   ,lclltt       like datmlcl.lclltt
   ,lcllgt       like datmlcl.lcllgt
   ,dddcod       like datmlcl.dddcod
   ,lcltelnum    like datmlcl.lcltelnum
   ,lclcttnom    like datmlcl.lclcttnom
   ,lclrefptotxt like datmlcl.lclrefptotxt
   ,c24lclpdrcod like datmlcl.c24lclpdrcod
   ,ofnnumdig    like sgokofi.ofnnumdig
   ,emeviacod    like datmemeviadpt.emeviacod
   ,celteldddcod like datmlcl.celteldddcod
   ,celtelnum    like datmlcl.celtelnum
   ,endcmp       like datmlcl.endcmp
 end record

 -->  Endereco do Local de Risco - RE
 define mr_rsc_re    record
        rmeblcdes    like rsdmbloco.rmeblcdes
 end record


 define
    aux_today         char (10),
    aux_hora          char (05),
    w_retorno         smallint

 define m_atdsrvorg   like datmservico.atdsrvorg,
        m_acesso_ind  smallint


# PSI186406 - robson - inicio

 define m_atdorgsrvnum like datmsrvre.atdorgsrvnum
       ,m_atdorgsrvano like datmsrvre.atdorgsrvano
       ,m_acao_origem  char(03)
       ,m_acao         char(03)

 define mr_movimento record
    srvretmtvcod like datmsrvre.srvretmtvcod
   ,srvretmtvdes like datksrvret.srvretmtvdes
 end record

 define m_atdsrvnum   like datmservico.atdsrvnum
       ,m_atdsrvano   like datmservico.atdsrvano

# PSI186406 - robson - fim

## PSI 172065 - Inicio

  define m_prep_sql     smallint

  ---> Danos Eletricos
  define mr_retorno   record
         coderro      smallint
        ,deserro      char(70)
        ,cidsedcod    like datrcidsed.cidsedcod
        ,cidsednom    like glakcid.cidnom
  end record

  define m_subbairro array[03] of record
         lclbrrnom   like datmlcl.lclbrrnom
  end record

#-------------------------------------------------------------------------------
 function cts04m00_prepare()
#-------------------------------------------------------------------------------

  define l_sql          char(600)

      let l_sql = "select * from datmpedvist ",
                  " where sinvstnum = ? ",
                  "   and sinvstano = ? "
      prepare p_cts04m00_001   from l_sql
      declare c_cts04m00_001   cursor for p_cts04m00_001

      let l_sql = " select grlinf "
                 ,"   from igbkgeral "
                 ,"  where mducod = 'C24'"
                 ,"    and grlchv = 'RADIO-DEMRE'"

      prepare p_cts04m00_002 from l_sql
      declare c_cts04m00_002 cursor for p_cts04m00_002


 let l_sql = ' select lclrsccod '
                  ,' ,orrdat '
                  ,' ,orrhor '
                  ,' ,sinntzcod '
                  ,' ,socntzcod '      ---> Danos Eletricos
                  ,' ,sinvstnum '
                  ,' ,sinvstano '
                  ,' ,atdorgsrvnum '
                  ,' ,atdorgsrvano '
                  ,' ,srvretmtvcod '
              ,' from datmsrvre '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '

 prepare p_cts04m00_003 from l_sql
 declare c_cts04m00_003 cursor for p_cts04m00_003

 let l_sql = ' insert into datmsrvretexc (atdsrvnum '
                                      ,' ,atdsrvano '
                                      ,' ,srvretexcdes '
                                      ,' ,caddat '
                                      ,' ,cademp '
                                      ,' ,cadmat '
                                      ,' ,cadusrtip) '
            ,' values ( ?,?,?,?,?,?,?) '

 prepare p_cts04m00_004 from l_sql

 let l_sql = ' update datmsrvre set (lclrsccod '
                  ,' ,orrdat '
                  ,' ,orrhor '
                  ,' ,sinntzcod '
                  ,' ,socntzcod '     ---> Danos Eletricos
                  ,' ,sinvstnum '
                  ,' ,sinvstano '
                  ,' ,srvretmtvcod) '
                ,' = (? '
                  ,' ,? '
                  ,' ,? '
                  ,' ,? '
                  ,' ,? '
                  ,' ,? '
                  ,' ,? '
                  ,' ,?) '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '
 prepare p_cts04m00_005 from l_sql

 let l_sql = ' delete from datmsrvretexc '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '
 prepare p_cts04m00_006 from l_sql

 let l_sql = ' select srvretexcdes '
              ,' from datmsrvretexc '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '
 prepare p_cts04m00_007 from l_sql
 declare c_cts04m00_004 cursor for p_cts04m00_007

# PSI186406 - robson - fim

      let m_prep_sql = true

end function
## PSI 172065 - Final

#--------------------------------------------------------------------
 function cts04m00()
#--------------------------------------------------------------------

 define ws            record
    atdetpcod         like datmsrvacp.atdetpcod,
    confirma          char (01),
    grvflg            smallint ,
    vclcoddig         like datmservico.vclcoddig,
    vcldes            like datmservico.vcldes   ,
    vclanomdl         like datmservico.vclanomdl,
    vcllicnum         like datmservico.vcllicnum,
    vclcordes         char (11)
 end record

 define l_grlinf	     like igbkgeral.grlinf

#PSI186406 - robson - inicio

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,c24astcod like datmligacao.c24astcod
 end record

 define l_null        smallint
       ,l_char        char(01)
       ,l_data        datetime hour to minute
       ,l_acesso      smallint

  define l_data_banco   date,
         l_hora2        datetime hour to minute

 define lr_display record
    atdorgsrvnum char(20)
 end record

 initialize lr_retorno.*   to null
 initialize mr_movimento.* to null
 initialize m_subbairro    to null

 let m_acao        = null
 let m_acao_origem = null
 let l_null        = null
 let l_char        = 'N'

 call cts40g03_data_hora_banco(2)
     returning l_data_banco, l_hora2
 let l_data = l_hora2

 ## Inicializar m_atdorgsrvnum e m_atdorgsrvano com nulo

 let m_atdorgsrvnum = null
 let m_atdorgsrvano = null


  initialize  ws.*  to  null

  let g_documento.atdsrvorg = 13

 ## PSI 172065 - Inicio

 if m_prep_sql is null or m_prep_sql <> true then
    call cts04m00_prepare()
 end if

 ## PSI 172065 - Final

 let int_flag = false

 initialize a_cts04m00   to null
 initialize d_cts04m00.* to null
 initialize w_cts04m00.* to null
 initialize ws.*         to null
 initialize mr_rsc_re.*  to null

 let aux_hora          = l_hora2
 let aux_today         = l_data
 let w_cts04m00.ano    = aux_today[9,10]
 let w_cts04m00.atddat = l_data
 let w_cts04m00.atdhor = l_hora2
 let aux_today         = l_data
 let aux_hora          = l_hora2

# PSI186406 - robson - inicio

 call cts20g02(g_documento.atdsrvnum, g_documento.atdsrvano,"RET")
 returning lr_retorno.resultado
          ,lr_retorno.mensagem
          ,lr_retorno.c24astcod

 if lr_retorno.c24astcod = 'RET' then
    let m_acao = 'RET'
 end if

 let m_acao_origem = g_documento.acao

 if m_acao_origem = 'RET' or
    m_acao = 'RET' then
    open window w_cts04m00_ret at 04,02 with form "cts04m00"
       attribute(form line 1)
 else
    open window w_cts04m00_org at 04,02 with form "cts04m00"
       attribute(form line 1)
 end if

 if m_acao = 'RET' or
    m_acao_origem = 'RET' then
    error 'Aguarde, verificando procedimentos ' attribute (reverse)  sleep 1

    call cts14g00 (m_acao
                 , g_documento.ramcod
                 , g_documento.succod
                 , g_documento.aplnumdig
                 , g_documento.itmnumdig
                 , l_null
                 , l_null
                 , l_char
                 , l_data)
    error '' sleep 2

    display 'Nr/Ano Serv.Orig.:' at 7, 39
    display 'Mtv.Ret:' at 15,2
    display '(F1)Help (F2)Org (F3)Refer (F5)Espelho (F6)Hist (F7)Imp (F8)Laudo (F9)Conclui' at 19,2
 else
    if g_documento.atdsrvnum is not null then
       display '(F1)Help (F2)RET (F3)Refer (F5)Espelho (F6)Hist (F7)Imp (F8)Laudo (F9)Conclui|' at 19,2
    else
       display '(F1)Help, (F3)Refer, (F5)Espelho, (F6)Hist, (F7)Imprime,(F8)Laudo,(F9)Conclui' at 19,2
    end if
 end if

# PSI186406 - robson - fim

#--------------------------------------------------------------------
# Identificacao do CONVENIO
#--------------------------------------------------------------------

 let w_cts04m00.ligcvntip = g_documento.ligcvntip

 select cpodes into d_cts04m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"   and
        cpocod = w_cts04m00.ligcvntip

 if g_documento.atdsrvnum is not null  and
    g_documento.atdsrvano is not null  then
    call consulta_cts04m00()

    if m_acao_origem = 'RET' then
       let d_cts04m00.srvnum = null
       let d_cts04m00.c24solnom = g_documento.solnom
       let w_cts04m00.atdhorpvt = null
    end if

    display by name d_cts04m00.*
    display by name d_cts04m00.c24solnom attribute (reverse)
    display by name d_cts04m00.cvnnom    attribute (reverse)
    display by name a_cts04m00[1].lgdtxt,
                    a_cts04m00[1].lclbrrnom,
                    a_cts04m00[1].cidnom,
                    a_cts04m00[1].ufdcod,
                    a_cts04m00[1].lclrefptotxt,
                    a_cts04m00[1].endzon,
                    a_cts04m00[1].dddcod,
                    a_cts04m00[1].lcltelnum,
                    a_cts04m00[1].lclcttnom,
                    a_cts04m00[1].celteldddcod,
                    a_cts04m00[1].celtelnum,
                    a_cts04m00[1].endcmp

# PSI186406 - robson - inicio

    ##-- Se tiver servico origem, exibi-lo --##
    if m_atdorgsrvnum is not null and
       m_atdorgsrvnum <> 0 then
       let lr_display.atdorgsrvnum = g_documento.atdsrvorg  using "&&",
                                "/", m_atdorgsrvnum using "<<<<<<<<<<",
                                "-", m_atdorgsrvano using "&&"
       display by name lr_display.atdorgsrvnum
    else
       ##-- Exibir o serviço da global g_documento. --##
       if m_acao = "RET" or
          m_acao_origem = "RET" then
          let lr_display.atdorgsrvnum = g_documento.atdsrvorg using "&&",
                                   "/", g_documento.atdsrvnum using "<<<<<<<<<<",
                                   "-", g_documento.atdsrvano using "&&"
          display by name lr_display.atdorgsrvnum
       end if
    end if

    display by name mr_movimento.srvretmtvcod
    display by name mr_movimento.srvretmtvdes

    if m_acao_origem <> 'RET' or
       m_acao_origem is null then
# PSI186406 - robson - fim
       if w_cts04m00.atdfnlflg = "S"  then
          error " Atencao! Servico ja' acionado!"
       else
          if g_documento.succod    is not null  and
             g_documento.ramcod    is not null  and
             g_documento.aplnumdig is not null  then
             call cts03g00 (3, g_documento.ramcod    ,
                               g_documento.succod    ,
                               g_documento.aplnumdig ,
                               g_documento.itmnumdig ,
                               "",
                               g_documento.atdsrvnum ,
                               g_documento.atdsrvano )
          end if
       end if

       let ws.grvflg = modifica_cts04m00()

       if ws.grvflg = false  then
          initialize g_documento.acao to null
       end if

       call cts40g03_data_hora_banco(2)
            returning l_data_banco, l_hora2
       if g_documento.acao is not null  then
          call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                        g_issk.funmat, l_data_banco, l_hora2)
       end if
# PSI186406 - robson - inicio
    end if
 end if

 if m_acao_origem = "RET" then
     let m_atdorgsrvnum = g_documento.atdsrvnum
     let m_atdorgsrvano = g_documento.atdsrvano
     let g_documento.atdsrvnum = null
     let g_documento.atdsrvano = null
 end if

 if g_documento.atdsrvnum is null then
    if g_documento.ramcod is not null and
       g_documento.succod is not null and
       g_documento.aplnumdig is not null then
       let d_cts04m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                        " ", g_documento.ramcod    using "&&&&",
                                        " ", g_documento.aplnumdig using "<<<<<<<& &"

# PSI186406 - robson - fim
#--------------------------------------------------------------------
# Monta CABECALHO do laudo
#--------------------------------------------------------------------

       ## Chamar o cts05g01 somente e nao for RET
       if m_acao_origem <> "RET" or m_acao_origem is null then
          call cts05g01(g_documento.succod   ,
                        g_documento.ramcod   ,
                        g_documento.aplnumdig)
              returning d_cts04m00.nom,
                        d_cts04m00.cornom    ,
                        d_cts04m00.corsus    ,
                        d_cts04m00.cvnnom    ,
                        w_cts04m00.viginc    ,
                        w_cts04m00.vigfnl
       end if

    end if

    if g_documento.prporg    is not null  and
       g_documento.prpnumdig is not null  then

       if m_acao_origem <> "RET" or m_acao_origem is null then
           call figrc072_setTratarIsolamento()        --> 223689
           call cts05g04 (g_documento.prporg   ,
                          g_documento.prpnumdig)
                returning d_cts04m00.nom      ,
                          d_cts04m00.corsus   ,
                          d_cts04m00.cornom   ,
                          d_cts04m00.cvnnom   ,
                          ws.vclcoddig,
                          ws.vcldes   ,
                          ws.vclanomdl,
                          ws.vcllicnum,
                          ws.vclcordes
          if g_isoAuto.sqlCodErr <> 0 then --> 223689
             error "Função cts05g04 indisponivel no momento ! Avise a Informatica !" sleep 2
             return
          end if    --> 223689
        end if

       let d_cts04m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                        " ", g_documento.prpnumdig using "<<<<<<<& &"
    end if

    let d_cts04m00.c24solnom = g_documento.solnom
    let d_cts04m00.prslocflg   = "N"


    ---> Se houver conteudo a apolice eh do RE
    if g_rsc_re.lclrsccod is not null and
       g_rsc_re.lclrsccod <> 0       then


       let d_cts04m00.lclrsccod    = g_rsc_re.lclrsccod
       let a_cts04m00[1].lgdtxt    = g_rsc_re.lgdtip clipped, " ",
                                     g_rsc_re.lgdnom clipped, " ",
                                     g_rsc_re.lgdnum
       let a_cts04m00[1].brrnom    = g_rsc_re.lclbrrnom
       let a_cts04m00[1].cidnom    = g_rsc_re.cidnom
       let a_cts04m00[1].ufdcod    = g_rsc_re.ufdcod
       let a_cts04m00[1].lgdnum    = g_rsc_re.lgdnum
       let a_cts04m00[1].lgdcep    = g_rsc_re.lgdcep
       let a_cts04m00[1].lgdcepcmp = g_rsc_re.lgdcepcmp

    end if

    display by name d_cts04m00.*
    display by name d_cts04m00.c24solnom attribute (reverse)
    display by name d_cts04m00.cvnnom    attribute (reverse)

    open c_cts04m00_002

    whenever error continue
    fetch c_cts04m00_002 into l_grlinf
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_grlinf = '0'
       else
          error 'Erro SELECT ccts04m00003: ' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error ' cts04m00() / C24 / RADIO-DEMRE ' sleep 2
          let int_flag = false
          if m_acao_origem = 'RET' or
             m_acao = 'RET' then
             close window w_cts04m00_ret
          else
             close window w_cts04m00_org
          end if
          return
       end if
    end if
    ###
    ### Final PSI179345 - Paulo
    ###

    #--------------------------------------------------------------------
    # Verifica se ja' houve solicitacao de servico para apolice
    #--------------------------------------------------------------------
#    if m_acao is null or                              # PSI186406 - robson
#       m_acao <> 'RET' then                           # PSI186406 - robson
       ##-- Se assunto não for RET, chamar o cts03g00 --##
    if (m_acao is null or m_acao <> 'RET' ) and
       (m_acao_origem is null or m_acao_origem <> 'RET') then
       if g_documento.succod    is not null  and
          g_documento.ramcod    is not null  and
          g_documento.aplnumdig is not null  then
          call cts03g00 (3, g_documento.ramcod    ,
                            g_documento.succod    ,
                            g_documento.aplnumdig ,
                            g_documento.itmnumdig ,
                            "",
                            g_documento.atdsrvnum ,
                            g_documento.atdsrvano )
       end if
    end if                                            # PSI186406 - robson

    let ws.grvflg = inclui_cts04m00()

    if ws.grvflg = true  then
       call cts10n00(w_cts04m00.atdsrvnum, w_cts04m00.atdsrvano,
                     w_cts04m00.funmat   , w_cts04m00.atddat   ,
                     w_cts04m00.atdhor)

       if d_cts04m00.imdsrvflg =  "S"     and        # servico imediato
          d_cts04m00.atdlibflg =  "S"     and        # servico liberado
          d_cts04m00.prslocflg =  "N"     and        # prestador no local
          d_cts04m00.frmflg    =  "N"     then       # formulario
          call cta00m06_acionamento(g_issk.dptsgl)
          returning l_acesso
          if l_acesso = true then
                let ws.confirma = cts08g01("A","S","","","CONFIRMA ACIONAMENTO DO SERVICO ?","")
                if ws.confirma  =  "S"   then
                   call cts00m02(w_cts04m00.atdsrvnum, w_cts04m00.atdsrvano, 1 )
                end if
          end if
       end if
       #-----------------------------------------------
       # Verifica etapa para desbloqueio do servico
       #-----------------------------------------------
       select atdetpcod
         into ws.atdetpcod
         from datmsrvacp
        where atdsrvnum = w_cts04m00.atdsrvnum
          and atdsrvano = w_cts04m00.atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = w_cts04m00.atdsrvnum
                              and atdsrvano = w_cts04m00.atdsrvano)
       if ws.atdetpcod    <> 3   and    # servico etapa concluida RE
          ws.atdetpcod    <> 4   and    # servico etapa concluida
          ws.atdetpcod    <> 5   then   # servico etapa cancelado
          #--------------------------------------------
          # Desbloqueio do servico
          #--------------------------------------------
          update datmservico set c24opemat = null
                           where atdsrvnum = w_cts04m00.atdsrvnum
                             and atdsrvano = w_cts04m00.atdsrvano
          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") no desbloqueio do servico.",
                   " AVISE A INFORMATICA!"
             prompt "" for char ws.confirma
          else
            call cts00g07_apos_servdesbloqueia(w_cts04m00.atdsrvnum,w_cts04m00.atdsrvano)
          end if
       end if
    end if
 end if
 if m_acao_origem = 'RET' or
    m_acao = 'RET' then
    close window w_cts04m00_ret
 else
    close window w_cts04m00_org
 end if

 let int_flag = false
end function  ###  cts04m00

#--------------------------------------------------------------------
 function consulta_cts04m00()
#--------------------------------------------------------------------

 define ws            record
    funmat            like isskfunc.funmat         ,
    funnom            char (15)                    ,
    dptsgl            like isskfunc.dptsgl         ,
    endlgdtip         like rlaklocal.endlgdtip     ,
    endlgdnom         like rlaklocal.endlgdnom     ,
    endnum            like rlaklocal.endnum        ,
    endcmp            like rlaklocal.endcmp        ,
    endbrr            like rlaklocal.endbrr        ,
    endcid            like rlaklocal.endcid        ,
    ufdcod            like rlaklocal.ufdcod        ,
    endcep            like rlaklocal.endcep        ,
    endcepcmp         like rlaklocal.endcepcmp     ,
    codesql           integer                      ,
    atdprscod         like datmservico.atdprscod   ,
    succod            like datrservapol.succod     ,
    ramcod            like datrservapol.ramcod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,
    edsnumref         like datrservapol.edsnumref  ,
    prporg            like datrligprp.prporg       ,
    prpnumdig         like datrligprp.prpnumdig    ,
    fcapcorg          like datrligpac.fcapacorg    ,
    fcapacnum         like datrligpac.fcapacnum    ,
    empcod            like datmservico.empcod      ,
    lclltt            like datmlcl.lclltt          ,
    lcllgt            like datmlcl.lcllgt
 end record

# PSI186406 - robson - inicio

 define l_mensagem  char(60)
       ,l_resultado smallint
       ,l_atdetpseq like datmsrvacp.atdsrvseq

 define l_data_banco   date,
        l_hora2        datetime hour to minute

 let m_atdorgsrvnum = null
 let m_atdorgsrvano = null
 let mr_movimento.srvretmtvcod = null
 let mr_movimento.srvretmtvdes = null
 let l_mensagem     = null

# PSI186406 - robson - fim


 initialize ws.*  to null

 select nom      ,
        cornom   ,
        corsus   ,
        atddfttxt,
        funmat   ,
        asitipcod,
        atddat   ,
        atdhor   ,
        atdlibflg,
        atdlibhor,
        atdlibdat,
        atdhorpvt,
        atdpvtretflg,
        atddatprg,
        atdhorprg,
        atdfnlflg,
        atdprinvlcod,
        atdprscod,
        prslocflg,
        ciaempcod,
        empcod                                                        #Raul, Biz
   into d_cts04m00.nom      ,
        d_cts04m00.cornom   ,
        d_cts04m00.corsus   ,
        d_cts04m00.atddfttxt,
        ws.funmat           ,
        d_cts04m00.asitipcod,
        w_cts04m00.atddat   ,
        w_cts04m00.atdhor   ,
        d_cts04m00.atdlibflg,
        w_cts04m00.atdlibhor,
        w_cts04m00.atdlibdat,
        w_cts04m00.atdhorpvt,
        w_cts04m00.atdpvtretflg,
        w_cts04m00.atddatprg,
        w_cts04m00.atdhorprg,
        w_cts04m00.atdfnlflg,
        d_cts04m00.atdprinvlcod,
        ws.atdprscod,
        d_cts04m00.prslocflg,
        g_documento.ciaempcod,
        ws.empcod                                                     #Raul, Biz
   from datmservico
  where atdsrvnum = g_documento.atdsrvnum  and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

# PSI186406 - robson - inicio

 open c_cts04m00_003 using g_documento.atdsrvnum
                        ,g_documento.atdsrvano

 whenever error continue
    fetch c_cts04m00_003 into d_cts04m00.lclrsccod
                           ,d_cts04m00.orrdat
                           ,d_cts04m00.orrhor
                           ,d_cts04m00.sinntzcod
                           ,d_cts04m00.socntzcod      ---> Danos Eletricos
                           ,d_cts04m00.sinvstnum
                           ,d_cts04m00.sinvstano
                           ,m_atdorgsrvnum
                           ,m_atdorgsrvano
                           ,mr_movimento.srvretmtvcod

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       error " Sinistro Ramos Elementares nao encontrado. AVISE A INFORMATICA!" sleep 2
    else
       error ' Erro no SELECT c_cts04m00_003 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
       error ' Funcao consulta_cts04m00() ', g_documento.atdsrvnum, '/'
                                           , g_documento.atdsrvano sleep 2
    end if
    return
 end if
 close c_cts04m00_003

 ## Obter o motivo do retorno
 ##-- Se não tiver o codigo do motivo do retorno, inicializar com nulo --##
 if mr_movimento.srvretmtvcod = 0 then
    let mr_movimento.srvretmtvcod = null
 end if

 if mr_movimento.srvretmtvcod is not null then
    call ctb24m01_desc_motivo(mr_movimento.srvretmtvcod)
    returning l_resultado, l_mensagem, mr_movimento.srvretmtvdes
    ## Não testar l_resultado por solicitacao da analista Ligia Mattge

    ##-- Para motivo retorno = 999 obter descricao e exibi-la --##
    if mr_movimento.srvretmtvcod  = 999 then
       open c_cts04m00_004 using g_documento.atdsrvnum
                              ,g_documento.atdsrvano
       whenever error continue
          fetch c_cts04m00_004 into mr_movimento.srvretmtvdes
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = 100 then
             let mr_movimento.srvretmtvdes = null
          else
             error ' Erro no SELECT c_cts04m00_004 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
             error ' Funcao consulta_cts04m00() ', g_documento.atdsrvnum, '/'
                                                 , g_documento.atdsrvano sleep 2
             return
          end if
       end if
       close c_cts04m00_004
       display by name mr_movimento.srvretmtvdes
    end if
 end if

 ## Obter informacoes da etapa do servico
 if m_acao_origem = 'RET' then
    call cts10g04_max_seq(g_documento.atdsrvnum, g_documento.atdsrvano, 3)
    returning l_resultado, l_mensagem, l_atdetpseq
    if l_resultado = 1 then
       call cts10g04_ultimo_pst(g_documento.atdsrvnum
                              , g_documento.atdsrvano
                              , l_atdetpseq)
       returning l_resultado
               , l_mensagem
               , w_cts04m00.atdetpcod
               , w_cts04m00.atdprscod
               , w_cts04m00.srrcoddig
               , w_cts04m00.socvclcod
       ## Não testar l_resultado

       if w_cts04m00.socvclcod is not null then
          call cts15g02_atdvclsgl(w_cts04m00.socvclcod)
          returning l_resultado
                  , l_mensagem
                  , w_cts04m00.atdvclsgl
          ## Nao testar l_resultado
       else
          let w_cts04m00.atdprscod = null
          let w_cts04m00.srrcoddig = null
          let w_cts04m00.socvclcod = null
          let w_cts04m00.atdvclsgl = null
       end if
    end if
 end if

# PSI186406 - robson - fim

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_gps(g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         1)
               returning a_cts04m00[1].lclidttxt
                        ,a_cts04m00[1].lgdtip
                        ,a_cts04m00[1].lgdnom
                        ,a_cts04m00[1].lgdnum
                        ,a_cts04m00[1].lclbrrnom
                        ,a_cts04m00[1].brrnom
                        ,a_cts04m00[1].cidnom
                        ,a_cts04m00[1].ufdcod
                        ,a_cts04m00[1].lclrefptotxt
                        ,a_cts04m00[1].endzon
                        ,a_cts04m00[1].lgdcep
                        ,a_cts04m00[1].lgdcepcmp
                        ,a_cts04m00[1].lclltt
                        ,a_cts04m00[1].lcllgt
                        ,a_cts04m00[1].dddcod
                        ,a_cts04m00[1].lcltelnum
                        ,a_cts04m00[1].lclcttnom
                        ,a_cts04m00[1].c24lclpdrcod
                        ,a_cts04m00[1].celteldddcod
                        ,a_cts04m00[1].celtelnum
                        ,a_cts04m00[1].endcmp
                        ,ws.codesql
                        ,a_cts04m00[1].emeviacod
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = a_cts04m00[1].lclbrrnom
 call cts06g10_monta_brr_subbrr(a_cts04m00[1].brrnom,
                                a_cts04m00[1].lclbrrnom)
      returning a_cts04m00[1].lclbrrnom

 select ofnnumdig into a_cts04m00[1].ofnnumdig
   from datmlcl
  where atdsrvano = g_documento.atdsrvano
    and atdsrvnum = g_documento.atdsrvnum
    and c24endtip = 1

 if ws.codesql <> 0  then
    error " Erro (", ws.codesql using "<<<<<&", ") na leitura do local de ocorrencia. AVISE A INFORMATICA!"
    return
 end if

 let a_cts04m00[1].lgdtxt = a_cts04m00[1].lgdtip clipped, " ",
                            a_cts04m00[1].lgdnom clipped, " ",
                            a_cts04m00[1].lgdnum using "<<<<#"

 if d_cts04m00.lclrsccod is not null  then

    ---> Buscar enderego do Local de Risco
    call framo240_dados_local_risco(d_cts04m00.lclrsccod)
                 returning l_resultado
		                      ,l_mensagem
		                      ,ws.endlgdtip
                          ,ws.endlgdnom
                          ,ws.endnum
                          ,ws.endcmp
                          ,ws.endbrr
                          ,ws.endcid
                          ,ws.ufdcod
                          ,ws.endcep
                          ,ws.endcepcmp
                          ,ws.lclltt
                          ,ws.lcllgt

    if a_cts04m00[1].lclrefptotxt is null  then
       let a_cts04m00[1].lclrefptotxt = ws.endcmp
    end if

    if a_cts04m00[1].lgdtip    = ws.endlgdtip  and
       a_cts04m00[1].lgdnom    = ws.endlgdnom  and
       a_cts04m00[1].lgdnum    = ws.endnum     and
       a_cts04m00[1].brrnom    = ws.endbrr     and
       a_cts04m00[1].cidnom    = ws.endcid     and
       a_cts04m00[1].ufdcod    = ws.ufdcod     then
       let d_cts04m00.lclrscflg = "S"
    else
       let d_cts04m00.lclrscflg = "N"
    end if
 else
    let d_cts04m00.lclrscflg = "N"
 end if

 let d_cts04m00.sinntzdes = "*** NAO CADASTRADA ***"

 select sinntzdes
   into d_cts04m00.sinntzdes
   from sgaknatur
  where sinramgrp = "4"  and
        sinntzcod = d_cts04m00.sinntzcod

 ---> Danos Eletricos
 select socntzdes
   into d_cts04m00.socntzdes
   from datksocntz
  where c24pbmgrpcod = "106"  and
        socntzcod = d_cts04m00.socntzcod

 let d_cts04m00.asitipabvdes = "NAO PREV"

 select asitipabvdes
   into d_cts04m00.asitipabvdes
   from datkasitip
  where asitipcod = d_cts04m00.asitipcod

 let w_cts04m00.lignum = cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

 call cts20g01_docto(w_cts04m00.lignum)
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

 if g_documento.succod    is not null  and
    g_documento.ramcod    is not null  and
    g_documento.aplnumdig is not null  then
    let d_cts04m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                     " ", g_documento.ramcod    using "&&&&",
                                     " ", g_documento.aplnumdig using "<<<<<<<& &"
 end if

 if g_documento.prporg    is not null  and
    g_documento.prpnumdig is not null  then
    let d_cts04m00.doctxt = "Proposta: ", g_documento.prporg    using "&&",
                                     " ", g_documento.prpnumdig using "<<<<<<<& &"
 end if

initialize  g_documento.lclnumseq, g_documento.rmerscseq to null

 ---> Sequencia do Local de Risco / Bloco
 select lclnumseq
       ,rmerscseq
   into g_documento.lclnumseq
       ,g_documento.rmerscseq
   from datmrsclcllig
  where lignum = w_cts04m00.lignum

#--------------------------------------------------------------------
# Identificacao do SOLICITANTE/CONVENIO
#--------------------------------------------------------------------

 select c24solnom,
        ligcvntip
   into d_cts04m00.c24solnom,
        w_cts04m00.ligcvntip
   from datmligacao
  where lignum = w_cts04m00.lignum

 ##-- Se assunto não é RET, guardar o solnom na global g_documento --##
 if m_acao_origem is null or
    m_acao_origem <> "RET" then
    let g_documento.solnom = d_cts04m00.c24solnom
 end if

 let g_documento.solnom = d_cts04m00.c24solnom

 select lignum
   from datmligfrm
  where lignum = w_cts04m00.lignum

 if sqlca.sqlcode = notfound  then
    let d_cts04m00.frmflg = "N"
 else
    let d_cts04m00.frmflg = "S"
 end if

 select cpodes
   into d_cts04m00.cvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = w_cts04m00.ligcvntip

#--------------------------------------------------------------------
# Obtem NOME DO FUNCIONARIO
#--------------------------------------------------------------------

 let ws.funnom = "** NAO CADASTRADO **"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where empcod = ws.empcod                                            #Raul, Biz
    and funmat = ws.funmat

 ##-- Obter data/hora para assunto origem RET
 if m_acao_origem = "RET" then
    call cts40g03_data_hora_banco(2)
        returning l_data_banco, l_hora2
    let w_cts04m00.atddat = l_data_banco
    let w_cts04m00.atdhor = l_hora2
    let d_cts04m00.atdlibflg = null
    let ws.funmat = g_issk.funmat
 else
    let d_cts04m00.atdtxt = w_cts04m00.atddat           , " ",
                            w_cts04m00.atdhor           , " ",
                            upshift(ws.dptsgl)   clipped, " ",
                            ws.funmat  using "&&&&&&"   , " ",
                            upshift(ws.funnom)   clipped, " ",
                            w_cts04m00.atdlibdat        , " ",
                            w_cts04m00.atdlibhor
 end if

 if w_cts04m00.atdhorpvt is not null  or
    w_cts04m00.atdhorpvt  = "00:00"   then
    let d_cts04m00.imdsrvflg = "S"
 end if

 if w_cts04m00.atddatprg is not null  then
    let d_cts04m00.imdsrvflg = "N"
 end if

 let w_cts04m00.atdlibflg = d_cts04m00.atdlibflg

 if d_cts04m00.atdlibflg = "N"  then
    let w_cts04m00.atdlibdat = w_cts04m00.atddat
    let w_cts04m00.atdlibhor = w_cts04m00.atdhor
 end if
 if ws.atdprscod = 5 then     # prestador no local
    let d_cts04m00.prslocflg = "S"
 end if
 let d_cts04m00.srvnum = g_documento.atdsrvorg using "&&",
                         "/", g_documento.atdsrvnum using "&&&&&&&",
                         "-", g_documento.atdsrvano using "&&"

 select cpodes
   into d_cts04m00.atdprinvldes
   from iddkdominio
  where cponom = "atdprinvlcod"
    and cpocod = d_cts04m00.atdprinvlcod

 select c24pbmcod
   into d_cts04m00.c24pbmcod
   from datrsrvpbm
  where atdsrvnum    = g_documento.atdsrvnum
    and atdsrvano    = g_documento.atdsrvano
    and c24pbminforg = 1
    and c24pbmseq    = 1

end function  ###  consulta_cts04m00

#--------------------------------------------------------------------
 function modifica_cts04m00()
#--------------------------------------------------------------------

 define ws           record
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor,
    codesql          integer,
    tabname          like systables.tabname
 end record

 define hist_cts04m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define prompt_key    char (01)

 #PSI186406 -Robson -inicio
 define l_hoje date

 define l_hora2          datetime hour to minute,
        l_data_banco     date

 call cts40g03_data_hora_banco(2)
     returning l_hoje, l_hora2

	let	prompt_key  =  null

	initialize  ws.*  to  null

	initialize  hist_cts04m00.*  to  null

 initialize ws.*  to null

 ## PSI 172065 - Inicio

 if m_prep_sql is null or m_prep_sql <> true then
    call cts04m00_prepare()
 end if

 ## PSI 172065 - Final

 call input_cts04m00() returning hist_cts04m00.*

 if int_flag  then
    let int_flag = false
    error " Operacao cancelada!"
    initialize a_cts04m00      to null
    initialize d_cts04m00.*    to null
    initialize w_cts04m00.*    to null
    clear form
    return false
 end if

 whenever error continue

 begin work

 update datmservico set ( nom          ,
                          cornom       ,
                          corsus       ,
                          atddfttxt    ,
                          atdlibflg    ,
                          atdlibhor    ,
                          atdlibdat    ,
                          atdhorpvt    ,
                          atdpvtretflg ,
                          atddatprg    ,
                          atdhorprg    ,
                          asitipcod    ,
                          atdprinvlcod ,
                          prslocflg)
                      = ( d_cts04m00.nom,
                          d_cts04m00.cornom,
                          d_cts04m00.corsus,
                          d_cts04m00.atddfttxt,
                          d_cts04m00.atdlibflg,
                          w_cts04m00.atdlibhor,
                          w_cts04m00.atdlibdat,
                          w_cts04m00.atdhorpvt,
                          w_cts04m00.atdpvtretflg,
                          w_cts04m00.atddatprg,
                          w_cts04m00.atdhorprg,
                          d_cts04m00.asitipcod,
                          d_cts04m00.atdprinvlcod,
                          d_cts04m00.prslocflg)
                    where atdsrvnum = g_documento.atdsrvnum  and
                          atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na alteracao do servico. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 #------------------------------------------------------------------------------
 # Modifica problemas do servico
 #------------------------------------------------------------------------------
   call ctx09g02_altera(g_documento.atdsrvnum ,
                        g_documento.atdsrvano ,
                        1                   , # sequencia
                        1                   , # Org. informacao 1-Segurado 2-Pst
                        d_cts04m00.c24pbmcod,
                        d_cts04m00.atddfttxt,
                        ""                  ) # Codigo prestador
        returning ws.codesql,
                  ws.tabname
   if ws.codesql <> 0 then
      error "ctx09g02_altera", ws.codesql, ws.tabname
      rollback work
      prompt "" for char prompt_key
      return false
   end if
 #PSI186406 -Robson -inicio
 whenever error continue
    execute p_cts04m00_005 using d_cts04m00.lclrsccod
                              ,d_cts04m00.orrdat
                              ,d_cts04m00.orrhor
                              ,d_cts04m00.sinntzcod
                              ,d_cts04m00.socntzcod       ---> Danos Eletricos
                              ,d_cts04m00.sinvstnum
                              ,d_cts04m00.sinvstano
                              ,mr_movimento.srvretmtvcod
                              ,g_documento.atdsrvnum
                              ,g_documento.atdsrvano
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error " Erro (", sqlca.sqlcode, ") na alteracao do servico Ramos Elementares. AVISE A INFORMATICA!"
    error 'Erro UPDATE pcts04m00006: ' , sqlca.sqlcode, " | ",sqlca.sqlerrd[2]
    error 'cts04m00_modifica() ',g_documento.atdsrvnum
                                ,g_documento.atdsrvano
    rollback work
    prompt "" for char prompt_key
    return false
 end if
 #PSI186406 -Robson -fim
 if a_cts04m00[1].operacao is null  then
    let a_cts04m00[1].operacao = "M"
 end if
 #PSI186406 -Robson -inicio
 whenever error continue
    execute p_cts04m00_006 using g_documento.atdsrvnum
                              ,g_documento.atdsrvano
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro DELETE pcts04m00007: ' , sqlca.sqlcode, " | ",sqlca.sqlerrd[2]
    error 'cts04m00_modifica() ',g_documento.atdsrvnum
                                ,g_documento.atdsrvano
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 if mr_movimento.srvretmtvcod = 999 then
    whenever error continue
       execute p_cts04m00_004 using g_documento.atdsrvnum
                                 ,g_documento.atdsrvano
                                 ,mr_movimento.srvretmtvdes
                                 ,l_hoje
                                 ,g_issk.empcod
                                 ,g_issk.funmat
                                 ,g_issk.usrtip
    whenever error stop
 end if
 if sqlca.sqlcode <> 0 then
    error 'Erro INSERT pcts04m00005: ' , sqlca.sqlcode, " | ",sqlca.sqlerrd[2]
    error 'cts04m00_modifica() ',g_documento.atdsrvnum
                                ,g_documento.atdsrvano
    rollback work
    prompt "" for char prompt_key
    return false
 end if
 #PSI186406 -Robson -fim
 let a_cts04m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
 let ws.codesql = cts06g07_local( a_cts04m00[1].operacao
                                 ,g_documento.atdsrvnum
                                 ,g_documento.atdsrvano
                                 ,1
                                 ,a_cts04m00[1].lclidttxt
                                 ,a_cts04m00[1].lgdtip
                                 ,a_cts04m00[1].lgdnom
                                 ,a_cts04m00[1].lgdnum
                                 ,a_cts04m00[1].lclbrrnom
                                 ,a_cts04m00[1].brrnom
                                 ,a_cts04m00[1].cidnom
                                 ,a_cts04m00[1].ufdcod
                                 ,a_cts04m00[1].lclrefptotxt
                                 ,a_cts04m00[1].endzon
                                 ,a_cts04m00[1].lgdcep
                                 ,a_cts04m00[1].lgdcepcmp
                                 ,a_cts04m00[1].lclltt
                                 ,a_cts04m00[1].lcllgt
                                 ,a_cts04m00[1].dddcod
                                 ,a_cts04m00[1].lcltelnum
                                 ,a_cts04m00[1].lclcttnom
                                 ,a_cts04m00[1].c24lclpdrcod
                                 ,a_cts04m00[1].ofnnumdig
                                 ,a_cts04m00[1].emeviacod
                                 ,a_cts04m00[1].celteldddcod
                                 ,a_cts04m00[1].celtelnum
                                 ,a_cts04m00[1].endcmp)
 if ws.codesql is null   or
    ws.codesql <> 0      then
    error " Erro (", ws.codesql, ") na alteracao do local de ocorrencia. AVISE A INFORMATICA!"
    rollback work
    prompt "" for char prompt_key
    return false
 end if

 if w_cts04m00.atdlibflg <> d_cts04m00.atdlibflg  then
    if d_cts04m00.atdlibflg = "S"  then
       let w_cts04m00.atdetpcod = 1
       let ws.atdetpdat = w_cts04m00.atdlibdat
       let ws.atdetphor = w_cts04m00.atdlibhor
    else
       call cts40g03_data_hora_banco(2)
           returning l_data_banco, l_hora2
       let w_cts04m00.atdetpcod = 2
       let ws.atdetpdat = l_data_banco
       let ws.atdetphor = l_hora2
    end if

    let w_retorno = cts10g04_insere_etapa(g_documento.atdsrvnum,
                                          g_documento.atdsrvano,
                                          w_cts04m00.atdetpcod,
                                          w_cts04m00.atdprscod ,
                                          " ",
                                          " ",
                                          w_cts04m00.srrcoddig)

    if w_retorno <> 0  then
       error " Erro (", sqlca.sqlcode, ") na inclusao da etapa de acompanhamento. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char prompt_key
       return false
    end if
 end if

 whenever error stop

 commit work
 # Ponto de acesso apos a gravacao do laudo
 call cts00g07_apos_grvlaudo(g_documento.atdsrvnum,
                             g_documento.atdsrvano)

 return true

end function  ###  modifica_cts04m00


#-------------------------------------------------------------------------------
 function inclui_cts04m00()
#-------------------------------------------------------------------------------

 define ws              record
        char_prompt     char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codesql         integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,

        caddat          like datmligfrm.caddat     ,
        cadhor          like datmligfrm.cadhor     ,
        cademp          like datmligfrm.cademp     ,
        cadmat          like datmligfrm.cadmat     ,
        atdsrvseq       like datmsrvacp.atdsrvseq  ,
        etpfunmat       like datmsrvacp.funmat     ,
        atdetpdat       like datmsrvacp.atdetpdat  ,
        atdetphor       like datmsrvacp.atdetphor  ,
        histerr         smallint
 end record
 define hist_cts04m00   record
        hist1           like datmservhist.c24srvdsc,
        hist2           like datmservhist.c24srvdsc,
        hist3           like datmservhist.c24srvdsc,
        hist4           like datmservhist.c24srvdsc,
        hist5           like datmservhist.c24srvdsc
 end record

 # PSI186406 - robson - inicio

 define l_data_hoje date

 define l_data_banco  date,
        l_hora2       datetime hour to minute
       ,l_lclnumseq   like datmsrvre.lclnumseq
       ,l_rmerscseq   like datmsrvre.rmerscseq


 ## PSI 172065 - Inicio

 if m_prep_sql is null or m_prep_sql <> true then
    call cts04m00_prepare()
 end if

 initialize  ws.*  to  null

 initialize  hist_cts04m00.*  to  null

 let l_lclnumseq = null
 let l_rmerscseq = null



## Para servicos RET, inicializar campos com nulos.
    if m_acao_origem = 'RET' then
       ##let mr_movimento.srvretmtvcod       = null
       ##let mr_movimento.srvretmtvdes       = null
       let d_cts04m00.prslocflg = null
       let d_cts04m00.imdsrvflg = null
       let d_cts04m00.atdlibflg = null
       let w_cts04m00.atdfnlflg = null
    end if

# PSI186406 - robson - fim

   let g_documento.acao = "INC"

   call input_cts04m00() returning hist_cts04m00.*

   if  int_flag  then
       let int_flag  =  false
       initialize a_cts04m00      to null
       initialize d_cts04m00.*    to null
       initialize w_cts04m00.*    to null
       initialize ws.*            to null
       error " Operacao cancelada!"
       clear form
       let ws.retorno = false
       return false
       #exit while
   end if
   if  w_cts04m00.atddat is null  then
       call cts40g03_data_hora_banco(2)
           returning l_data_banco, l_hora2
       let w_cts04m00.atddat = l_data_banco
       let w_cts04m00.atdhor = l_hora2
   end if
   if  w_cts04m00.funmat is null  then
       let w_cts04m00.funmat = g_issk.funmat
   end if
   if  d_cts04m00.frmflg = "S"  then
       call cts40g03_data_hora_banco(2)
            returning l_data_banco, l_hora2
       let ws.caddat = l_data_banco
       let ws.cadhor = l_hora2
       let ws.cademp = g_issk.empcod
       let ws.cadmat = g_issk.funmat
   else
       initialize ws.caddat to null
       initialize ws.cadhor to null
       initialize ws.cademp to null
       initialize ws.cadmat to null
   end if
   if  w_cts04m00.atdfnlflg is null  then
       let w_cts04m00.atdfnlflg = "N"
       let w_cts04m00.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if
   let a_cts04m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
   #---> Danos Eletricos
   call ctf00m08_gera_p10(g_documento.c24astcod          --"P10"
                      ,g_documento.atdsrvorg
                      ,w_cts04m00.atdsrvnum
                      ,w_cts04m00.atdsrvano
                      ,d_cts04m00.srvnum
                      ,w_cts04m00.atddat
                      ,w_cts04m00.atdhor
                      ,w_cts04m00.funmat
                      ,d_cts04m00.frmflg
                      ,w_cts04m00.atdfnlflg
                      ,m_acao_origem
                      ,d_cts04m00.prslocflg
                      ,a_cts04m00[1].operacao
                      ,a_cts04m00[1].lclidttxt
                      ,a_cts04m00[1].lgdtxt
                      ,a_cts04m00[1].lgdtip
                      ,a_cts04m00[1].lgdnom
                      ,a_cts04m00[1].lgdnum
                      ,a_cts04m00[1].brrnom
                      ,a_cts04m00[1].lclbrrnom
                      ,a_cts04m00[1].endzon
                      ,a_cts04m00[1].cidnom
                      ,a_cts04m00[1].ufdcod
                      ,a_cts04m00[1].lgdcep
                      ,a_cts04m00[1].lgdcepcmp
                      ,a_cts04m00[1].lclltt
                      ,a_cts04m00[1].lcllgt
                      ,a_cts04m00[1].dddcod
                      ,a_cts04m00[1].lcltelnum
                      ,a_cts04m00[1].lclcttnom
                      ,a_cts04m00[1].lclrefptotxt
                      ,a_cts04m00[1].c24lclpdrcod
                      ,a_cts04m00[1].ofnnumdig
                      ,a_cts04m00[1].emeviacod
                      ,a_cts04m00[1].celteldddcod
                      ,a_cts04m00[1].celtelnum
                      ,a_cts04m00[1].endcmp
                      ,w_cts04m00.atdetpcod
                      ,d_cts04m00.atdlibflg
                      ,w_cts04m00.srrcoddig
                      ,w_cts04m00.cnldat
                      ,w_cts04m00.atdfnlhor
                      ,w_cts04m00.c24opemat
                      ,w_cts04m00.atdprscod
                      ,w_cts04m00.c24nomctt
                      ,d_cts04m00.lclrsccod
                      ,d_cts04m00.orrdat
                      ,d_cts04m00.orrhor
                      ,d_cts04m00.sinntzcod
                      ,d_cts04m00.socntzcod     ---> Danos Eletricos
                      ,g_documento.lclnumseq
                      ,g_documento.rmerscseq
                      ,d_cts04m00.sinvstnum
                      ,d_cts04m00.sinvstano
                      ,m_atdorgsrvnum
                      ,m_atdorgsrvano
                      ,mr_movimento.srvretmtvcod
                      ,mr_movimento.srvretmtvdes
                      ,d_cts04m00.c24pbmcod
                      ,d_cts04m00.atddfttxt
                      ,d_cts04m00.nom
                      ,d_cts04m00.corsus
                      ,d_cts04m00.cornom
                      ,d_cts04m00.asitipcod
                      ,d_cts04m00.atdprinvlcod
                      ,d_cts04m00.imdsrvflg
                      ,w_cts04m00.atdlibhor
                      ,w_cts04m00.atdlibdat
                      ,w_cts04m00.atdhorpvt
                      ,w_cts04m00.atdhorprg
                      ,w_cts04m00.atddatprg
                      ,w_cts04m00.atdpvtretflg
                      ,w_cts04m00.socvclcod
                      ,hist_cts04m00.*)
        returning ws.retorno
                 ,g_documento.c24astcod
                 ,g_documento.atdsrvorg
                 ,w_cts04m00.atdsrvnum
                 ,w_cts04m00.atdsrvano
                 ,d_cts04m00.srvnum
                 ,w_cts04m00.atddat
                 ,w_cts04m00.atdhor
                 ,w_cts04m00.funmat
                 ,d_cts04m00.frmflg
                 ,w_cts04m00.atdfnlflg
                 ,m_acao_origem
                 ,d_cts04m00.prslocflg
                 ,a_cts04m00[1].operacao
                 ,a_cts04m00[1].lclidttxt
                 ,a_cts04m00[1].lgdtxt
                 ,a_cts04m00[1].lgdtip
                 ,a_cts04m00[1].lgdnom
                 ,a_cts04m00[1].lgdnum
                 ,a_cts04m00[1].brrnom
                 ,a_cts04m00[1].lclbrrnom
                 ,a_cts04m00[1].endzon
                 ,a_cts04m00[1].cidnom
                 ,a_cts04m00[1].ufdcod
                 ,a_cts04m00[1].lgdcep
                 ,a_cts04m00[1].lgdcepcmp
                 ,a_cts04m00[1].lclltt
                 ,a_cts04m00[1].lcllgt
                 ,a_cts04m00[1].dddcod
                 ,a_cts04m00[1].lcltelnum
                 ,a_cts04m00[1].lclcttnom
                 ,a_cts04m00[1].lclrefptotxt
                 ,a_cts04m00[1].c24lclpdrcod
                 ,a_cts04m00[1].ofnnumdig
                 ,a_cts04m00[1].emeviacod
                 ,a_cts04m00[1].celteldddcod
                 ,a_cts04m00[1].celtelnum
                 ,a_cts04m00[1].endcmp
                 ,w_cts04m00.atdetpcod
                 ,d_cts04m00.atdlibflg
                 ,w_cts04m00.srrcoddig
                 ,w_cts04m00.cnldat
                 ,w_cts04m00.atdfnlhor
                 ,w_cts04m00.c24opemat
                 ,w_cts04m00.atdprscod
                 ,w_cts04m00.c24nomctt
                 ,d_cts04m00.lclrsccod
                 ,d_cts04m00.orrdat
                 ,d_cts04m00.orrhor
                 ,d_cts04m00.sinntzcod
                 ,d_cts04m00.socntzcod          ---> Danos Eletricos
                 ,l_lclnumseq
                 ,l_rmerscseq
                 ,d_cts04m00.sinvstnum
                 ,d_cts04m00.sinvstano
                 ,m_atdorgsrvnum
                 ,m_atdorgsrvano
                 ,mr_movimento.srvretmtvcod
                 ,mr_movimento.srvretmtvdes
                 ,d_cts04m00.c24pbmcod
                 ,d_cts04m00.atddfttxt
                 ,d_cts04m00.nom
                 ,d_cts04m00.corsus
                 ,d_cts04m00.cornom
                 ,d_cts04m00.asitipcod
                 ,d_cts04m00.atdprinvlcod
                 ,d_cts04m00.imdsrvflg
                 ,w_cts04m00.atdlibhor
                 ,w_cts04m00.atdlibdat
                 ,w_cts04m00.atdhorpvt
                 ,w_cts04m00.atdhorprg
                 ,w_cts04m00.atddatprg
                 ,w_cts04m00.atdpvtretflg
                 ,w_cts04m00.socvclcod

 return ws.retorno

end function  ###  inclui_cts04m00

#--------------------------------------------------------------------
 function input_cts04m00()
#--------------------------------------------------------------------

 define ws            record
    lclflg            smallint,
    retflg            char (01),
    prpflg            char (01),
    lclrscflg         char (01),
    endcmp            like rlaklocal.endcmp,
    dddcod            like gsakend.dddcod,
    teltxt            like gsakend.teltxt,
    atdlibflg         like datmservico.atdlibflg,
    confirma          char (01),
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes
 end record

 define hist_cts04m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define l_clscod      like rsdmclaus.clscod        ## PSI 168890

# PSI186406 - robson - inicio

 define lr_movimento record
    srvretmtvcod like datmsrvre.srvretmtvcod
   ,srvretmtvdes like datksrvret.srvretmtvdes
 end record

 define lr_d_ant_cts04m00 record
    srvnum            char (13)                    ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (32)                    ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    cvnnom            char (20)                    ,
    lclrsccod         like datmsrvre.lclrsccod     ,
    lclrscflg         char (01)                    ,
    orrdat            like datmsrvre.orrdat        ,
    orrhor            like datmsrvre.orrhor        ,
    sinntzcod         like datmsrvre.sinntzcod     ,
    sinntzdes         like sgaknatur.sinntzdes     ,
    c24pbmcod         like datkpbm.c24pbmcod       ,
    atddfttxt         like datmservico.atddfttxt   ,
    socntzcod         like datmsrvre.socntzcod     ,  ---> Danos Eletricos
    socntzdes         like datksocntz.socntzdes    ,
    asitipcod         like datmservico.asitipcod   ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    atdprinvlcod      like datmservico.atdprinvlcod,
    atdprinvldes      char (06)                    ,
    prslocflg         char (01)                    ,
    imdsrvflg         char (01)                    ,
    atdlibflg         like datmservico.atdlibflg   ,
    frmflg            char (01)                    ,
    atdtxt            char (64)                    ,
    sinvstnum         like datmpedvist.sinvstnum   ,  ## PSI 172065
    sinvstano         like datmpedvist.sinvstano      ## PSI 172065
 end record

 define lr_w_ant_cts04m00 record
    ano               char (02)                    ,
    lignum            like datrligsrv.lignum       ,
    viginc            like rsdmdocto.viginc        ,
    vigfnl            like rsdmdocto.vigfnl        ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    funmat            like datmservico.funmat      ,
    ligcvntip         like datmligacao.ligcvntip,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    c24opemat         like datmservico.c24opemat   ,
    c24nomctt         like datmservico.c24nomctt   ,
    atdprscod         like datmservico.atdprscod   ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atdpvtretflg      like datmservico.atdpvtretflg,
    atdlibflg         like datmservico.atdlibflg   ,
    atdfnlflg         like datmservico.atdfnlflg   ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    atdvclsgl         like datmsrvacp.atdvclsgl    ,
    srrcoddig         like datmsrvacp.srrcoddig    ,
    socvclcod         like datmservico.socvclcod
 end record

 define al_a_ant_cts04m00 array[1] of record
    operacao      char (01)
   ,lclidttxt     like datmlcl.lclidttxt
   ,lgdtxt        char (65)
   ,lgdtip        like datmlcl.lgdtip
   ,lgdnom        like datmlcl.lgdnom
   ,lgdnum        like datmlcl.lgdnum
   ,brrnom        like datmlcl.brrnom
   ,lclbrrnom     like datmlcl.lclbrrnom
   ,endzon        like datmlcl.endzon
   ,cidnom        like datmlcl.cidnom
   ,ufdcod        like datmlcl.ufdcod
   ,lgdcep        like datmlcl.lgdcep
   ,lgdcepcmp     like datmlcl.lgdcepcmp
   ,lclltt        like datmlcl.lclltt
   ,lcllgt        like datmlcl.lcllgt
   ,dddcod        like datmlcl.dddcod
   ,lcltelnum     like datmlcl.lcltelnum
   ,lclcttnom     like datmlcl.lclcttnom
   ,lclrefptotxt  like datmlcl.lclrefptotxt
   ,c24lclpdrcod  like datmlcl.c24lclpdrcod
   ,ofnnumdig     like sgokofi.ofnnumdig
   ,emeviacod     like datmemeviadpt.emeviacod
   ,celteldddcod  like datmlcl.celteldddcod
   ,celtelnum     like datmlcl.celtelnum
   ,endcmp        like datmlcl.endcmp
 end record

 define l_mensagem     char(100)
       ,l_resultado    smallint
       ,l_confirma     char(01)
       ,l_acao_origem  char(03)
       ,l_acao         char(03)
       ,l_atdsrvnum    like datmservico.atdsrvnum
       ,l_atdsrvano    like datmservico.atdsrvano
       ,l_flag         smallint
       ,l_acesso       smallint
       ,l_lclnumseq    like datmsrvre.lclnumseq
       ,l_rmerscseq    like datmsrvre.rmerscseq

 define lr_fantasmas record
    lclcttnom like datmlcl.lclcttnom
 end record

 define l_data_banco   date,
        l_hora2        datetime hour to minute,
        l_erro         smallint

# PSI186406 - robson - fim

## PSI 172065 - Inicio

 define lr_datmpedvist record like datmpedvist.*

 let l_erro = null

 if m_prep_sql is null or m_prep_sql = false then
     call cts04m00_prepare()
 end if

 initialize  ws.*  to  null
 initialize  hist_cts04m00.*  to  null
 initialize mr_retorno.* to null


 let lr_fantasmas.lclcttnom = a_cts04m00[1].lclcttnom
 let l_lclnumseq = null
 let l_rmerscseq = null
 let l_resultado = null
 let l_mensagem  = null


 let ws.lclrscflg = d_cts04m00.lclrscflg

 input by name d_cts04m00.nom      ,
               d_cts04m00.corsus   ,
               d_cts04m00.cornom   ,
               d_cts04m00.sinvstnum,            ## PSI 172065
               d_cts04m00.sinvstano,            ## PSI 172065
               d_cts04m00.lclrsccod,
               d_cts04m00.lclrscflg,
               lr_fantasmas.lclcttnom,          # PSI186147 - robson
               d_cts04m00.orrdat   ,
               d_cts04m00.orrhor   ,
               d_cts04m00.sinntzcod,
               d_cts04m00.c24pbmcod,
               d_cts04m00.atddfttxt,
               d_cts04m00.socntzcod,            ---> Danos Eletricos
               d_cts04m00.asitipcod,
               mr_movimento.srvretmtvcod,       # PSI186147 - robson
               mr_movimento.srvretmtvdes,       # PSI186147 - robson
               d_cts04m00.atdprinvlcod,
               d_cts04m00.prslocflg,
               d_cts04m00.imdsrvflg,
               d_cts04m00.atdlibflg,
               d_cts04m00.frmflg       without defaults

   before field nom

          if m_acao = 'RET' or
             m_acao_origem = 'RET' then
             next field lclcttnom
          end if

          display by name d_cts04m00.nom        attribute (reverse)

   after  field nom
          display by name d_cts04m00.nom

          if d_cts04m00.nom is null  or
             d_cts04m00.nom =  "  "  then
             error " Nome deve ser informado!"
             next field nom
          end if

          if w_cts04m00.atdfnlflg = "S"  then
             error " Servico ja' acionado nao pode ser alterado!"
             let ws.confirma = cts08g01( "A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                         " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                         "E INFORME AO  ** CONTROLE DE TRAFEGO **" )

             call cts02m03(w_cts04m00.atdfnlflg, d_cts04m00.imdsrvflg,
                           w_cts04m00.atdhorpvt, w_cts04m00.atddatprg,
                           w_cts04m00.atdhorprg, w_cts04m00.atdpvtretflg)
                 returning w_cts04m00.atdhorpvt, w_cts04m00.atddatprg,
                           w_cts04m00.atdhorprg, w_cts04m00.atdpvtretflg

             next field frmflg
          end if

   before field corsus
          display by name d_cts04m00.corsus     attribute (reverse)

   after  field corsus
          display by name d_cts04m00.corsus

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts04m00.corsus is not null  then
                select cornom
                  into d_cts04m00.cornom
                  from gcaksusep, gcakcorr
                 where gcaksusep.corsus   = d_cts04m00.corsus  and
                       gcakcorr.corsuspcp = gcaksusep.corsuspcp

                if sqlca.sqlcode = notfound  then
                   error " Susep do corretor nao cadastrada!"
                   next field corsus
                else
                   display by name d_cts04m00.cornom
                   next field sinvstnum         ## PSI 175269
                end if
             end if
          end if

   before field cornom
          display by name d_cts04m00.cornom     attribute (reverse)

   after  field cornom
          display by name d_cts04m00.cornom

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if g_documento.atdsrvnum is not null  and
                g_documento.atdsrvano is not null  then
                next field sinvstnum        ## PSI 175269
             end if
          end if


   before field sinvstnum

## PSI 172065 - Inicio

          if g_documento.succod    is null and
             g_documento.ramcod    is null and
             g_documento.aplnumdig is null then
             next field lclrscflg
          end if

          call cts04m01(g_documento.succod,
                        g_documento.ramcod,
                        g_documento.aplnumdig,
                        g_documento.itmnumdig)
              returning d_cts04m00.sinvstnum,
                        d_cts04m00.sinvstano

          display by name d_cts04m00.sinvstnum
          display by name d_cts04m00.sinvstano

          if d_cts04m00.sinvstnum is null and
             d_cts04m00.sinvstano is null then
             error "Nao existe vistoria de RE aberta para esta apolice!!"
             if d_cts04m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          end if

          open c_cts04m00_001   using d_cts04m00.sinvstnum,
                                    d_cts04m00.sinvstano
          whenever error continue
          fetch c_cts04m00_001     into  lr_datmpedvist.*
          whenever error stop
          if  sqlca.sqlcode <> 0 then
              if sqlca.sqlcode <> notfound then
                 error 'Erro SELECT lclrsccod ',sqlca.sqlcode, '|',sqlca.sqlerrd[2]
                 let int_flag = true
                 exit input
              end if
          else
              let d_cts04m00.orrdat    = lr_datmpedvist.sindat
              let d_cts04m00.orrhor    = lr_datmpedvist.sinhor
              display by name d_cts04m00.orrdat
              display by name d_cts04m00.orrhor
          end if
          close c_cts04m00_001

   after field sinvstnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts04m00.corsus is not null  then
                next field corsus
             else
                next field cornom
             end if
          end if

          if g_documento.ramcod <>  31 and
             g_documento.ramcod <> 531 then
             open c_cts04m00_001   using d_cts04m00.sinvstnum,
                                       d_cts04m00.sinvstano
             whenever error continue
             fetch c_cts04m00_001     into  lr_datmpedvist.*
             whenever error stop
             if  sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode <> notfound then
                    error 'Erro SELECT lclrsccod ',sqlca.sqlcode, '|',sqlca.sqlerrd[2]
                    let int_flag = true
                    exit input
                 end if
             else
                 let d_cts04m00.lclrsccod = lr_datmpedvist.lclrsccod
                 let d_cts04m00.orrdat    = lr_datmpedvist.sindat
                 let d_cts04m00.orrhor    = lr_datmpedvist.sinhor
                 display by name d_cts04m00.orrdat
                 display by name d_cts04m00.orrhor
             end if
             close c_cts04m00_001
          end if

          if g_documento.ramcod =  31 or
             g_documento.ramcod = 531 then
             open c_cts04m00_001   using d_cts04m00.sinvstnum,
                                       d_cts04m00.sinvstano
             whenever error continue
             fetch c_cts04m00_001     into  lr_datmpedvist.*
             whenever error stop
             if  sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode = notfound then
                    next field lclrscflg
                 else
                    error 'Erro SELECT datmpedvist ',sqlca.sqlcode, '|',sqlca.sqlerrd[2]
                    let int_flag = true
                    exit input
                 end if
             end if
             close c_cts04m00_001

             let a_cts04m00[1].lgdtip       = lr_datmpedvist.lgdtip
             let a_cts04m00[1].lgdnom       = lr_datmpedvist.lgdnom
             let a_cts04m00[1].lgdnum       = lr_datmpedvist.lgdnum
             let a_cts04m00[1].lclbrrnom    = lr_datmpedvist.endbrr
             let a_cts04m00[1].cidnom       = lr_datmpedvist.endcid
             let a_cts04m00[1].ufdcod       = lr_datmpedvist.endufd
             let a_cts04m00[1].lclrefptotxt = lr_datmpedvist.lgdnomcmp
             let a_cts04m00[1].dddcod       = lr_datmpedvist.endddd
             let a_cts04m00[1].lcltelnum    = lr_datmpedvist.teldes
             let a_cts04m00[1].lclcttnom    = lr_datmpedvist.lclcttnom
             let a_cts04m00[1].lgdtxt       = lr_datmpedvist.lgdtip clipped, " ",
                                              lr_datmpedvist.lgdnom clipped, " ",
                                              lr_datmpedvist.lgdtip using "<<<<#"
             let d_cts04m00.lclrscflg       = "S"
             let d_cts04m00.orrdat          = lr_datmpedvist.sindat
             let d_cts04m00.orrhor          = lr_datmpedvist.sinhor
             let lr_fantasmas.lclcttnom     = a_cts04m00[1].lclcttnom   #PSI186406 - robson

             display by name d_cts04m00.orrdat
             display by name d_cts04m00.orrhor

             next field lclrscflg
          end if

## PSI 172065 - Final

   before field lclrsccod
          if g_documento.succod    is null  or
             g_documento.ramcod    is null  or
             g_documento.aplnumdig is null  then

             let d_cts04m00.lclrscflg = "N"
             display by name d_cts04m00.lclrscflg
             next field lclrscflg
          else
             display by name d_cts04m00.lclrsccod  attribute (reverse)
          end if

   after  field lclrsccod
          display by name d_cts04m00.lclrsccod

          if d_cts04m00.lclrsccod is null  then

             ---> Permite alterar Local de Risco somente na abertura do Laudo
             if m_acao_origem is not null and
                m_acao_origem <> "   "    then

                let d_cts04m00.lclrsccod = g_rsc_re.lclrsccod
                error " Alteracao do Local de Risco nao permitida."
                display by name d_cts04m00.lclrsccod
                next field lclrsccod
             end if

             error " Codigo do local de risco deve ser informado!"

             initialize l_lclnumseq
                       ,l_rmerscseq  to null

             while l_lclnumseq is null or
                   l_rmerscseq is null

                   initialize l_resultado
                             ,l_mensagem
                             ,l_lclnumseq
                             ,l_rmerscseq  to null

                ---> Retorna Local de Risco
                call framc215(g_documento.succod
                             ,g_documento.ramcod
                             ,g_documento.aplnumdig)
                    returning l_resultado
                             ,l_mensagem
                             ,d_cts04m00.lclrsccod
                             ,a_cts04m00[1].lgdtip
                             ,a_cts04m00[1].lgdnom
                             ,a_cts04m00[1].lgdnum
                             ,a_cts04m00[1].lclbrrnom
                             ,a_cts04m00[1].cidnom
                             ,a_cts04m00[1].ufdcod
                             ,a_cts04m00[1].lgdcep
                             ,a_cts04m00[1].lgdcepcmp
                             ,l_lclnumseq
                             ,l_rmerscseq
                             ,mr_rsc_re.rmeblcdes
                             ,a_cts04m00[1].lclltt
                             ,a_cts04m00[1].lcllgt


                if l_lclnumseq is null or
                   l_rmerscseq is null then

                   call cts08g01 ("A","N",""
                                 ,"PARA PROSSEGUIR NO ATENDIMENTO, "
                                 ,"SELECIONE UMA DAS OPCOES DA LISTA. ", " " )
                       returning ws.confirma
                end if
             end while

             let g_documento.lclnumseq = l_lclnumseq
             let g_documento.rmerscseq = l_rmerscseq

	     next field lclrsccod

          else

             ---> Permite alterar Local de Risco somente na abertura do Laudo
             if m_acao_origem is not null                  and
                m_acao_origem <> "   "                     and
                d_cts04m00.lclrsccod <> g_rsc_re.lclrsccod then

                let d_cts04m00.lclrsccod = g_rsc_re.lclrsccod
                error " Alteracao do Local de Risco nao permitida."
                display by name d_cts04m00.lclrsccod
                next field lclrsccod
             end if

             --->Verifica se o Local de Risco e valido
             call framo240_valida_local(g_documento.succod    ,
                                        g_documento.ramcod    ,
                                        g_documento.aplnumdig ,
                                        d_cts04m00.lclrsccod  )
                              returning ws.lclflg
                                       ,l_mensagem

             if ws.lclflg = false  then
                error " Local de risco nao cadastrado!"
                next field lclrsccod
             else
                if g_documento.atdsrvnum is null  and
                   g_documento.atdsrvano is null  then

                   let l_resultado = null
                   let l_mensagem  = null

                   ---> Buscar enderego do Local de Risco
                   call framo240_dados_local_risco(d_cts04m00.lclrsccod)
                                returning l_resultado
                                         ,l_mensagem
                                         ,a_cts04m00[1].lgdtip
                                         ,a_cts04m00[1].lgdnom
                                         ,a_cts04m00[1].lgdnum
                                         ,a_cts04m00[1].endcmp
                                         ,a_cts04m00[1].lclbrrnom
                                         ,a_cts04m00[1].cidnom
                                         ,a_cts04m00[1].ufdcod
                                         ,a_cts04m00[1].lgdcep
                                         ,a_cts04m00[1].lgdcepcmp
                                         ,a_cts04m00[1].lclltt
                                         ,a_cts04m00[1].lcllgt

                   let a_cts04m00[1].lgdtxt = a_cts04m00[1].lgdtip clipped, " ",
                                              a_cts04m00[1].lgdnom clipped, " ",
                                              a_cts04m00[1].lgdnum using "<<<<#"
                end if
             end if
          end if

          display by name a_cts04m00[1].lgdtxt,
                          a_cts04m00[1].lclbrrnom,
                          a_cts04m00[1].cidnom,
                          a_cts04m00[1].ufdcod,
                          a_cts04m00[1].lclrefptotxt,
                          a_cts04m00[1].endzon,
                          a_cts04m00[1].dddcod,
                          a_cts04m00[1].lcltelnum,
                          a_cts04m00[1].lclcttnom,
                          a_cts04m00[1].celteldddcod,
                          a_cts04m00[1].celtelnum,
                          a_cts04m00[1].endcmp
                         ,d_cts04m00.lclrsccod

          let lr_fantasmas.lclcttnom     = a_cts04m00[1].lclcttnom

   before field lclrscflg
          if g_documento.atdsrvnum is null      and
             g_documento.atdsrvano is null      and
             d_cts04m00.lclrsccod  is not null  then
             let d_cts04m00.lclrscflg = "S"
          end if

          display by name d_cts04m00.lclrscflg  attribute (reverse)

   after  field lclrscflg
          display by name d_cts04m00.lclrscflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cts04m00.lclrsccod is not null  then
                next field lclrsccod
             else
                next field sinvstnum
             end if
          end if

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts04m00.lclrscflg is null  then
                error " Atendimento no local de risco deve ser informado!"
                next field lclrscflg
             else
                if d_cts04m00.lclrscflg <> "S"  and
                   d_cts04m00.lclrscflg <> "N"  then
                   error " Atendimento no local de risco deve ser (S)im ou (N)ao!"
                   next field lclrscflg
                end if
             end if

             if d_cts04m00.lclrscflg = "S"  then
                if g_documento.atdsrvnum is not null  and
                   g_documento.atdsrvano is not null  and
                   ws.lclrscflg           = "N"       then

                   ---> Buscar enderego do Local de Risco
                   call framo240_dados_local_risco(d_cts04m00.lclrsccod)
                                returning l_resultado
                                         ,l_mensagem
                                         ,a_cts04m00[1].lgdtip
                                         ,a_cts04m00[1].lgdnom
                                         ,a_cts04m00[1].lgdnum
                                         ,a_cts04m00[1].lclrefptotxt
                                         ,a_cts04m00[1].lclbrrnom
                                         ,a_cts04m00[1].cidnom
                                         ,a_cts04m00[1].ufdcod
                                         ,a_cts04m00[1].lgdcep
                                         ,a_cts04m00[1].lgdcepcmp
                                         ,a_cts04m00[1].lclltt
                                         ,a_cts04m00[1].lcllgt

                   let a_cts04m00[1].lgdtxt = a_cts04m00[1].lgdtip clipped, " ",
                                              a_cts04m00[1].lgdnom clipped, " ",
                                              a_cts04m00[1].lgdnum using "<<<<#"
                end if

                display by name a_cts04m00[1].lgdtxt,
                                a_cts04m00[1].lclbrrnom,
                                a_cts04m00[1].cidnom,
                                a_cts04m00[1].ufdcod,
                                a_cts04m00[1].lclrefptotxt,
                                a_cts04m00[1].endzon,
                                a_cts04m00[1].dddcod,
                                a_cts04m00[1].lcltelnum,
                                a_cts04m00[1].lclcttnom,
                                a_cts04m00[1].celteldddcod,
                                a_cts04m00[1].celtelnum,
                                a_cts04m00[1].endcmp
                let lr_fantasmas.lclcttnom     = a_cts04m00[1].lclcttnom   #PSI186406 - robson
             end if

             let a_cts04m00[1].lclbrrnom = m_subbairro[1].lclbrrnom
             let m_acesso_ind = false
             let m_atdsrvorg = 13
             call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
                  returning m_acesso_ind
             if m_acesso_ind = false then
                call cts06g03(1
                             ,m_atdsrvorg
                             ,w_cts04m00.ligcvntip
                             ,aux_today
                             ,aux_hora
                             ,a_cts04m00[1].lclidttxt
                             ,a_cts04m00[1].cidnom
                             ,a_cts04m00[1].ufdcod
                             ,a_cts04m00[1].brrnom
                             ,a_cts04m00[1].lclbrrnom
                             ,a_cts04m00[1].endzon
                             ,a_cts04m00[1].lgdtip
                             ,a_cts04m00[1].lgdnom
                             ,a_cts04m00[1].lgdnum
                             ,a_cts04m00[1].lgdcep
                             ,a_cts04m00[1].lgdcepcmp
                             ,a_cts04m00[1].lclltt
                             ,a_cts04m00[1].lcllgt
                             ,a_cts04m00[1].lclrefptotxt
                             ,a_cts04m00[1].lclcttnom
                             ,a_cts04m00[1].dddcod
                             ,a_cts04m00[1].lcltelnum
                             ,a_cts04m00[1].c24lclpdrcod
                             ,a_cts04m00[1].ofnnumdig
                             ,a_cts04m00[1].celteldddcod
                             ,a_cts04m00[1].celtelnum
                             ,a_cts04m00[1].endcmp
                             ,hist_cts04m00.*
                             ,a_cts04m00[1].emeviacod )
                    returning a_cts04m00[1].lclidttxt
                             ,a_cts04m00[1].cidnom
                             ,a_cts04m00[1].ufdcod
                             ,a_cts04m00[1].brrnom
                             ,a_cts04m00[1].lclbrrnom
                             ,a_cts04m00[1].endzon
                             ,a_cts04m00[1].lgdtip
                             ,a_cts04m00[1].lgdnom
                             ,a_cts04m00[1].lgdnum
                             ,a_cts04m00[1].lgdcep
                             ,a_cts04m00[1].lgdcepcmp
                             ,a_cts04m00[1].lclltt
                             ,a_cts04m00[1].lcllgt
                             ,a_cts04m00[1].lclrefptotxt
                             ,a_cts04m00[1].lclcttnom
                             ,a_cts04m00[1].dddcod
                             ,a_cts04m00[1].lcltelnum
                             ,a_cts04m00[1].c24lclpdrcod
                             ,a_cts04m00[1].ofnnumdig
                             ,a_cts04m00[1].celteldddcod
                             ,a_cts04m00[1].celtelnum
                             ,a_cts04m00[1].endcmp
                             ,ws.retflg
                             ,hist_cts04m00.*
                             ,a_cts04m00[1].emeviacod
             else
                call cts06g11(1
                             ,m_atdsrvorg
                             ,w_cts04m00.ligcvntip
                             ,aux_today
                             ,aux_hora
                             ,a_cts04m00[1].lclidttxt
                             ,a_cts04m00[1].cidnom
                             ,a_cts04m00[1].ufdcod
                             ,a_cts04m00[1].brrnom
                             ,a_cts04m00[1].lclbrrnom
                             ,a_cts04m00[1].endzon
                             ,a_cts04m00[1].lgdtip
                             ,a_cts04m00[1].lgdnom
                             ,a_cts04m00[1].lgdnum
                             ,a_cts04m00[1].lgdcep
                             ,a_cts04m00[1].lgdcepcmp
                             ,a_cts04m00[1].lclltt
                             ,a_cts04m00[1].lcllgt
                             ,a_cts04m00[1].lclrefptotxt
                             ,a_cts04m00[1].lclcttnom
                             ,a_cts04m00[1].dddcod
                             ,a_cts04m00[1].lcltelnum
                             ,a_cts04m00[1].c24lclpdrcod
                             ,a_cts04m00[1].ofnnumdig
                             ,a_cts04m00[1].celteldddcod
                             ,a_cts04m00[1].celtelnum
                             ,a_cts04m00[1].endcmp
                             ,hist_cts04m00.*
                             ,a_cts04m00[1].emeviacod )
                    returning a_cts04m00[1].lclidttxt
                             ,a_cts04m00[1].cidnom
                             ,a_cts04m00[1].ufdcod
                             ,a_cts04m00[1].brrnom
                             ,a_cts04m00[1].lclbrrnom
                             ,a_cts04m00[1].endzon
                             ,a_cts04m00[1].lgdtip
                             ,a_cts04m00[1].lgdnom
                             ,a_cts04m00[1].lgdnum
                             ,a_cts04m00[1].lgdcep
                             ,a_cts04m00[1].lgdcepcmp
                             ,a_cts04m00[1].lclltt
                             ,a_cts04m00[1].lcllgt
                             ,a_cts04m00[1].lclrefptotxt
                             ,a_cts04m00[1].lclcttnom
                             ,a_cts04m00[1].dddcod
                             ,a_cts04m00[1].lcltelnum
                             ,a_cts04m00[1].c24lclpdrcod
                             ,a_cts04m00[1].ofnnumdig
                             ,a_cts04m00[1].celteldddcod
                             ,a_cts04m00[1].celtelnum
                             ,a_cts04m00[1].endcmp
                             ,ws.retflg
                             ,hist_cts04m00.*
                             ,a_cts04m00[1].emeviacod
             end if

             # PSI 244589 - Inclusão de Sub-Bairro - Burini
             let m_subbairro[1].lclbrrnom = a_cts04m00[1].lclbrrnom
             call cts06g10_monta_brr_subbrr(a_cts04m00[1].brrnom,
                                            a_cts04m00[1].lclbrrnom)
                  returning a_cts04m00[1].lclbrrnom

             let a_cts04m00[1].lgdtxt = a_cts04m00[1].lgdtip clipped, " ",
                                        a_cts04m00[1].lgdnom clipped, " ",
                                        a_cts04m00[1].lgdnum using "<<<<#"

             display by name a_cts04m00[1].lgdtxt
             display by name a_cts04m00[1].lclbrrnom
             display by name a_cts04m00[1].endzon
             display by name a_cts04m00[1].cidnom
             display by name a_cts04m00[1].ufdcod
             display by name a_cts04m00[1].lclrefptotxt
             display by name a_cts04m00[1].lclcttnom
             display by name a_cts04m00[1].dddcod
             display by name a_cts04m00[1].lcltelnum
             display by name a_cts04m00[1].celteldddcod
             display by name a_cts04m00[1].celtelnum
             display by name a_cts04m00[1].endcmp

             let lr_fantasmas.lclcttnom = a_cts04m00[1].lclcttnom    # PSI186406 - robson

             if ws.retflg = "N"  then
               error " Dados referentes ao local incorretos ou nao preenchidos!"
                next field lclrscflg
             end if
          end if

          #---> Danos Eletricos - Verifica Cidade Sede
          initialize mr_retorno.* to null


# PSI186147 - robson - inicio

   before field lclcttnom
         let lr_fantasmas.lclcttnom = a_cts04m00[1].lclcttnom
         display by name lr_fantasmas.lclcttnom attribute(reverse)

   after field lclcttnom
         display by name lr_fantasmas.lclcttnom
         ## O campo pode aceitar nulo.
         if fgl_lastkey() = fgl_keyval("up") or
            fgl_lastkey() = fgl_keyval("left") then
            next field lclrscflg
         end if

         if m_acao_origem <> 'RET' then
            if w_cts04m00.atdfnlflg = "S" or g_documento.acao = 'CON' then
               if w_cts04m00.atdfnlflg = "S"  then
                  error  " Servico ja acionado nao pode ser alterado!" sleep 2
                  let l_confirma = cts08g01("A"
                                           ,"N"
                                           ,"*** LAUDO NAO PODE SER ALTERADO ***"
                                           ," "
                                           ,"NOVAS INFORMACOES REGISTRE NO HISTORICO"
                                           ,"E INFORME AO  ** CONTROLE DE TRAFEGO **")
               else
                  error  " Servico sendo consultado, nao pode ser alterado!" sleep 2
                  let l_confirma = cts08g01("A"
                                           ,"N"
                                           ,"*** LAUDO NAO PODE SER ALTERADO ***"
                                           ," "
                                           ,"FOI SOLICITADO UMA (CON)CONSULTA"
                                           ,"" )
               end if

               call cts02m03(w_cts04m00.atdfnlflg
                           , d_cts04m00.imdsrvflg
                           , w_cts04m00.atdhorpvt
                           , w_cts04m00.atddatprg
                           , w_cts04m00.atdhorprg
                           , w_cts04m00.atdpvtretflg)
               returning w_cts04m00.atdhorpvt
                       , w_cts04m00.atddatprg
                       , w_cts04m00.atdhorprg
                       , w_cts04m00.atdpvtretflg

               ##-- Não testar int_flag, e sim, apenas atribui-la --##
               ##if int_flag then
                  let int_flag = true
                  exit input
               ##end if
            else
             next field orrdat
            end if
         end if
         ##-- Guardar no array, o lclcttnom carregado --##
         let a_cts04m00[1].lclcttnom = lr_fantasmas.lclcttnom

# PSI186147 - robson - fim

   before field orrdat
          display by name d_cts04m00.orrdat attribute (reverse)

   after  field orrdat
          display by name d_cts04m00.orrdat

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts04m00.orrdat is null        then
                error " Data da ocorrencia deve ser informada!"
                next field orrdat
             end if

             call cts40g03_data_hora_banco(2)
                  returning l_data_banco, l_hora2
             ##if d_cts04m00.orrdat > today   then
             if d_cts04m00.orrdat > l_data_banco   then
                error " Data da ocorrencia nao deve ser maior que hoje!"
                next field orrdat
             end if

             ##if d_cts04m00.orrdat < today - 180 units day  then
             if d_cts04m00.orrdat < l_data_banco - 180 units day  then
                error " Data da ocorrencia nao deve ser anterior a SEIS meses!"
                next field orrdat
             end if

             if d_cts04m00.orrdat < w_cts04m00.viginc  or
                d_cts04m00.orrdat > w_cts04m00.vigfnl  then
                error " Data da ocorrencia esta' fora da vigencia da apolice!"
                let ws.confirma = cts08g01("A","N","","DATA DA OCORRENCIA ESTA' FORA",
                                           "DA VIGENCIA DA APOLICE !", "")
             end if
          end if

   before field orrhor
          display by name d_cts04m00.orrhor attribute (reverse)

   after  field orrhor
          display by name d_cts04m00.orrhor

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts04m00.orrhor is null  then
                error " Hora da ocorrencia deve ser informada!"
                next field orrhor
             end if

             call cts40g03_data_hora_banco(2)
                 returning l_data_banco, l_hora2
             if d_cts04m00.orrdat =  l_data_banco                   and
                d_cts04m00.orrhor >  l_hora2  then
                error " Hora da ocorrencia nao deve ser maior que hora atual!"
                next field orrhor
             end if

          ##-- Volta o campo com as teclas de direção --##
          else
              next field orrdat
          end if

# PSI186406 - robson - inicio
          ##-- Se assunto e RET vai para o motivo --##
          if m_acao_origem = 'RET' or
             m_acao = 'RET' then
             next field srvretmtvcod
          end if
# PSI186406 - robson - fim

   before field sinntzcod
          display by name d_cts04m00.sinntzcod attribute (reverse)

   after  field sinntzcod
          display by name d_cts04m00.sinntzcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts04m00.sinntzcod is null  then
                error " Codigo de natureza do sinistro deve ser informada!"
                call cts12g00(2,"","","","","","","")             ## PSI 168890
                     returning d_cts04m00.sinntzcod, l_clscod  ## PSI 168890
                next field sinntzcod
             end if

             select sinntzdes
               into d_cts04m00.sinntzdes
               from sgaknatur
              where sinramgrp = "4"  and
                    sinntzcod = d_cts04m00.sinntzcod

             if sqlca.sqlcode = notfound  then
                initialize d_cts04m00.sinntzcod  to null
                error " Codigo de natureza invalido!"
                next field sinntzcod
             else
                display by name d_cts04m00.sinntzdes
             end if
          end if

    before field c24pbmcod
        display by name d_cts04m00.c24pbmcod attribute (reverse)

        ---> Danos Eletricos
        if d_cts04m00.sinntzcod  = 5      then

           let d_cts04m00.c24pbmcod = 352

           let d_cts04m00.atddfttxt = null

           select c24pbmdes into d_cts04m00.atddfttxt
             from datkpbm
            where c24pbmcod = d_cts04m00.c24pbmcod

            display by name d_cts04m00.c24pbmcod
            display by name d_cts04m00.atddfttxt

            next field socntzcod

        end if

    after  field c24pbmcod
        display by name d_cts04m00.c24pbmcod

        if d_cts04m00.c24pbmcod  is null  or
           d_cts04m00.c24pbmcod  =  0     then
           call ctc48m02(g_documento.atdsrvorg) returning ws.c24pbmgrpcod,
                                                          ws.c24pbmgrpdes
           if ws.c24pbmgrpcod  is null  then
              error " Codigo de problema deve ser informado!"
              next field c24pbmcod
           else
               call ctc48m01(ws.c24pbmgrpcod,"")
                               returning d_cts04m00.c24pbmcod,
                                         d_cts04m00.atddfttxt
               if d_cts04m00.c24pbmcod is null  then
                  error " Codigo de problema deve ser informado!"
                  next field c24pbmcod
               end if
           end if
        else
           if d_cts04m00.c24pbmcod <> 999 then
              select c24pbmdes into d_cts04m00.atddfttxt
                from datkpbm
               where c24pbmcod = d_cts04m00.c24pbmcod
              if status = notfound then
                 error " Codigo de problema invalido !"
                 call ctc48m02(g_documento.atdsrvorg) returning ws.c24pbmgrpcod,
                                                               ws.c24pbmgrpdes
                 if ws.c24pbmgrpcod  is null  then
                    error " Codigo de problema deve ser informado!"
                    next field c24pbmcod
                 else
                     call ctc48m01(ws.c24pbmgrpcod,"")
                                     returning d_cts04m00.c24pbmcod,
                                               d_cts04m00.atddfttxt
                     if d_cts04m00.c24pbmcod is null  then
                        error " Codigo de problema deve ser informado!"
                        next field c24pbmcod
                     end if
                 end if
              end if
           end if
        end if
        display by name d_cts04m00.c24pbmcod
        display by name d_cts04m00.atddfttxt

   before field atddfttxt
          display by name d_cts04m00.atddfttxt attribute (reverse)
          if d_cts04m00.c24pbmcod <> 999 then
# Neia       next field sinntzcod   ---> Danos Eletricos
          end if

   after  field atddfttxt
          display by name d_cts04m00.atddfttxt

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts04m00.atddfttxt  is null   then
                error " Problema apresentado deve ser informado!"
                next field atddfttxt
             end if
          end if

   ---> Danos Eletricos
   before field socntzcod
          if d_cts04m00.c24pbmcod <> 352 then

             initialize d_cts04m00.socntzcod to null
             initialize d_cts04m00.socntzdes to null
             display by name d_cts04m00.socntzcod
             display by name d_cts04m00.socntzdes

             next field asitipcod
          end if

          display by name d_cts04m00.socntzcod attribute (reverse)

   after  field socntzcod
          display by name d_cts04m00.socntzcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts04m00.socntzcod  is null   then
                error " Codigo de natureza do Porto Socorro deve ser informada!"

                let l_erro = null
                call cts04m00_natureza() ## PSI 168890
                     returning l_erro
                              ,d_cts04m00.socntzcod
                              ,d_cts04m00.socntzdes

                display by name d_cts04m00.socntzcod
                display by name d_cts04m00.socntzdes

                next field socntzcod
             end if
          end if

          select socntzdes
            into d_cts04m00.socntzdes
            from datksocntz
           where socntzcod    = d_cts04m00.socntzcod
             and c24pbmgrpcod = 106

          if sqlca.sqlcode = 100 then
             error " Codigo de natureza invalido para o Laudo de P10."
             let d_cts04m00.socntzdes = null
             display by name d_cts04m00.socntzdes
             next field socntzcod
          end if

          display by name d_cts04m00.socntzdes

   before field asitipcod
          display by name d_cts04m00.asitipcod attribute (reverse)

   after  field asitipcod
          display by name d_cts04m00.asitipcod

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts04m00.asitipcod is null  then
                let d_cts04m00.asitipcod = ctn25c00(13)

                if d_cts04m00.asitipcod is not null  then
                   select asitipabvdes
                     into d_cts04m00.asitipabvdes
                     from datkasitip
                    where asitipcod = d_cts04m00.asitipcod  and
                          asitipstt = "A"

                   display by name d_cts04m00.asitipcod
                   display by name d_cts04m00.asitipabvdes
                   next field atdprinvlcod
                else
                   next field asitipcod
                end if
             else
                select asitipabvdes
                  into d_cts04m00.asitipabvdes
                  from datkasitip
                 where asitipcod = d_cts04m00.asitipcod  and
                       asitipstt = "A"

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia invalido!"
                   let d_cts04m00.asitipcod = ctn25c00(13)
                   next field asitipcod
                else
                   display by name d_cts04m00.asitipcod
                end if
                select asitipcod
                  from datrasitipsrv
                 where atdsrvorg = g_documento.atdsrvorg
                   and asitipcod = d_cts04m00.asitipcod

                if sqlca.sqlcode = notfound  then
                   error " Tipo de assistencia nao pode ser enviada",
                         " para este servico!"
                   next field asitipcod
                end if
             end if

             display by name d_cts04m00.asitipabvdes
          else
             if d_cts04m00.c24pbmcod = 352 then
                next field c24pbmcod
             else
                next field atddfttxt
             end if
          end if

# PSI186406 - robson - inicio
          ##-- Ir direto para o campo nivel de prioridade --##
          ##if l_acao <> 'RET' then
             next field atdprinvlcod
          ##end if

   before field srvretmtvcod

          if m_acao_origem <> 'RET' and
             m_acao <> 'RET' then
             next field atdlibflg
          end if

          display by name mr_movimento.srvretmtvcod attribute(reverse)

    after field srvretmtvcod

          ##-- Se voltou o campo com as teclas de direcao, volta para o orrhor --##
          if fgl_lastkey() = fgl_keyval("up") or
             fgl_lastkey() = fgl_keyval("left") then
             next field orrhor
          end if

          if mr_movimento.srvretmtvcod is null or
             mr_movimento.srvretmtvcod = 0 then
             let mr_movimento.srvretmtvcod = ctb24m01()
             ##-- Exibir o motivo obtido de ctb24m01 e manter-se em srvretmtvcod --##
             display by name mr_movimento.srvretmtvcod
             next field srvretmtvcod
          else
             if mr_movimento.srvretmtvcod <> 999 then
                call ctb24m01_desc_motivo(mr_movimento.srvretmtvcod)
                returning l_resultado, l_mensagem, mr_movimento.srvretmtvdes

                if l_resultado <> 1 then
                   error  l_mensagem sleep 2
                   let mr_movimento.srvretmtvcod = ctb24m01()
                end if
                ##-- Exibir codigo e descricao do motivo e manter-se no campo prslocflg --##
                display by name mr_movimento.srvretmtvcod
                display by name mr_movimento.srvretmtvdes
                next field prslocflg
             end if
          end if

          display by name mr_movimento.srvretmtvcod

  before field srvretmtvdes
         display by name mr_movimento.srvretmtvdes attribute(reverse)

   after field srvretmtvdes
         display by name mr_movimento.srvretmtvdes

          ##-- Se voltou com as teclas de direcao --##
          if fgl_lastkey() = fgl_keyval("up") or
             fgl_lastkey() = fgl_keyval("left") then
             next field srvretmtvcod
          end if

         if mr_movimento.srvretmtvdes is null then
            error ' Motivo apresentado deve ser informado! ' sleep 2
            next field srvretmtvdes
         end if

         if m_acao = 'RET' or
            m_acao_origem = 'RET' then
            next field prslocflg
         end if

# PSI186406 - robson - fim

   before field atdprinvlcod
          display by name d_cts04m00.atdprinvlcod attribute (reverse)

   after  field atdprinvlcod
          display by name d_cts04m00.atdprinvlcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts04m00.atdprinvlcod is null then
                error " Nivel de prioridade deve ser informado!"
                next field atdprinvlcod
             end if

             select cpodes
               into d_cts04m00.atdprinvldes
               from iddkdominio
              where cponom = "atdprinvlcod"
                and cpocod = d_cts04m00.atdprinvlcod

             if sqlca.sqlcode = notfound then
                error " Nivel de prioridade pode ser (1)-Baixa, (2)-Normal ou (3)-Urgente"
                next field atdprinvlcod
             end if

             display by name d_cts04m00.atdprinvldes
          else
             ##-- Se voltou com as teclas de direcao, testar campo para voltar --##
             if (l_acao is null or l_acao <> "RET") and
                l_acao_origem <> "RET" then
                next field asitipcod
             end if
          end if

   before field prslocflg
          if g_documento.atdsrvnum  is not null   or
             g_documento.atdsrvano  is not null   then
             initialize d_cts04m00.prslocflg  to null
             next field atdlibflg
          end if

          if d_cts04m00.imdsrvflg   = "N"         then
             initialize w_cts04m00.c24nomctt  to null
             let d_cts04m00.prslocflg = "N"
             display by name d_cts04m00.prslocflg
             next field atdlibflg
          end if

          display by name d_cts04m00.prslocflg attribute (reverse)

   after  field prslocflg
          display by name d_cts04m00.prslocflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             ##-- Se voltou com as teclas de direcao --##
             if m_acao_origem = 'RET' or
                m_acao = 'RET' then
                next field srvretmtvcod
             else
               next field atdprinvlcod
             end if
          end if

          if ((d_cts04m00.prslocflg  is null)  or
              (d_cts04m00.prslocflg  <> "S"    and
             d_cts04m00.prslocflg    <> "N"))  then
             error " Prestador no local: (S)im ou (N)ao!"
             next field prslocflg
          end if

          if d_cts04m00.prslocflg = "S"   then
             if w_cts04m00.atdprscod is null then     # PSI186406 - robson - inicio
                call ctn24c01()
                  returning w_cts04m00.atdprscod, w_cts04m00.srrcoddig,
                            w_cts04m00.atdvclsgl, w_cts04m00.socvclcod

                if w_cts04m00.atdprscod  is null then
                   error " Faltam dados para prestador no local!" sleep 2
                   next field prslocflg
                end if
             end if                                   # PSI186406 - robson - fim

             let w_cts04m00.atdlibhor = w_cts04m00.atdhor
             let w_cts04m00.atdlibdat = w_cts04m00.atddat
             call cts40g03_data_hora_banco(2)
                  returning l_data_banco, l_hora2
             let w_cts04m00.cnldat    = l_data_banco
             let w_cts04m00.atdfnlhor = l_hora2
             let w_cts04m00.c24opemat = g_issk.funmat
             let w_cts04m00.atdfnlflg = "S"
             let w_cts04m00.atdetpcod =  3
             let d_cts04m00.frmflg = "N"
             display by name d_cts04m00.frmflg
             let d_cts04m00.imdsrvflg = "S"
             display by name d_cts04m00.imdsrvflg
             let w_cts04m00.atdhorpvt = "00:00"
             let d_cts04m00.atdlibflg = "S"
             display by name d_cts04m00.atdlibflg
             exit input
          else
             initialize w_cts04m00.funmat   ,
                        w_cts04m00.cnldat   ,
                        w_cts04m00.atdfnlhor,
                        w_cts04m00.c24opemat,
                        w_cts04m00.atdfnlflg,
                        w_cts04m00.atdetpcod,
                        w_cts04m00.atdprscod,
                        w_cts04m00.c24nomctt  to null
          end if

   before field imdsrvflg
          display by name d_cts04m00.imdsrvflg attribute (reverse)

   after  field imdsrvflg
          display by name d_cts04m00.imdsrvflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts04m00.imdsrvflg is null   or
                d_cts04m00.imdsrvflg =  " "    then
                error " Informacao sobre servico imediato deve ser informado!"
                next field imdsrvflg
             end if

             if d_cts04m00.imdsrvflg <> "S"    and
                d_cts04m00.imdsrvflg <> "N"    then
                error " Servico imediato deve ser (S)im ou (N)ao!"
                next field imdsrvflg
             end if

             call cts02m03(w_cts04m00.atdfnlflg, d_cts04m00.imdsrvflg,
                           w_cts04m00.atdhorpvt, w_cts04m00.atddatprg,
                           w_cts04m00.atdhorprg, w_cts04m00.atdpvtretflg)
                 returning w_cts04m00.atdhorpvt, w_cts04m00.atddatprg,
                           w_cts04m00.atdhorprg, w_cts04m00.atdpvtretflg

             if d_cts04m00.imdsrvflg = "S"  then
                if w_cts04m00.atdhorpvt is null        then
                   error " Previsao de horas nao informada para",
                         " servico imediato!"
                   next field imdsrvflg
                end if
             else
                if w_cts04m00.atddatprg is null  or
                   w_cts04m00.atddatprg  = " "   or
                   w_cts04m00.atdhorprg is null  then
                   error " Faltam dados para servico programado!"
                   next field imdsrvflg
                else
                   let d_cts04m00.atdprinvlcod  = 2
                   select cpodes
                     into d_cts04m00.atdprinvldes
                     from iddkdominio
                    where cponom = "atdprinvlcod"
                      and cpocod = d_cts04m00.atdprinvlcod

                    display by name d_cts04m00.atdprinvlcod
                    display by name d_cts04m00.atdprinvldes

                    next field atdlibflg
                end if
             end if
          end if

   before field atdlibflg
          display by name d_cts04m00.atdlibflg attribute (reverse)

          if g_documento.atdsrvnum is not null  and
             w_cts04m00.atdfnlflg  =  "S"       then
             exit input
          end if

          if d_cts04m00.atdlibflg  is null  and
             g_documento.c24soltipcod  = 1   then  # Tipo Solic = Segurado
          end if

   after  field atdlibflg
          display by name d_cts04m00.atdlibflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts04m00.atdlibflg is null then
                error " Envio liberado deve ser informado!"
                next field atdlibflg
             end if

             if d_cts04m00.atdlibflg <> "S"  and
                d_cts04m00.atdlibflg <> "N"  then
                error " Envio liberado deve ser (S)im ou (N)ao!"
                next field atdlibflg
             end if
             if d_cts04m00.atdlibflg = "N"  and
                d_cts04m00.prslocflg = "S"  then
                error " Servico com prestador no local deve ser liberado!"
                next field atdlibflg
             end if


             let ws.atdlibflg         = d_cts04m00.atdlibflg
             display by name d_cts04m00.atdlibflg

             if w_cts04m00.atdlibflg is null  then
                if ws.atdlibflg = "S"  then
                   call cts40g03_data_hora_banco(2)
                       returning l_data_banco, l_hora2
                   let w_cts04m00.atdlibdat = l_data_banco
                   let w_cts04m00.atdlibhor = l_hora2
                else
                   let d_cts04m00.atdlibflg = "N"
                   display by name d_cts04m00.atdlibflg
                   initialize w_cts04m00.atdlibhor to null
                   initialize w_cts04m00.atdlibdat to null
                end if
             else
                select atdfnlflg
                  from datmservico
                 where atdsrvnum = g_documento.atdsrvnum  and
                       atdsrvano = g_documento.atdsrvano  and
                       atdfnlflg = "N"

                   if m_acao_origem <> 'RET' then  #PSI186406 - ROBSON
                      if sqlca.sqlcode = notfound  then
                         error " Servico ja' acionado nao pode ser alterado!"
                         let ws.confirma = cts08g01("A","N","*** LAUDO NAO PODE SER ALTERADO ***",
                                                    " ","NOVAS INFORMACOES REGISTRE NO HISTORICO",
                                                    "E INFORME AO  ** CONTROLE DE TRAFEGO **")
                         next field atdlibflg
                      end if
                   end if              #PSI186406 - ROBSON

                if w_cts04m00.atdlibflg = "S"  then
                   if ws.atdlibflg = "S" then
                      exit input
                   else
                      error " A liberacao do servico nao pode ser cancelada!"
                      next field atdlibflg
                      let d_cts04m00.atdlibflg = "N"
                      display by name d_cts04m00.atdlibflg
                      initialize w_cts04m00.atdlibhor to null
                      initialize w_cts04m00.atdlibdat to null
                      error " Liberacao cancelada!"
                      sleep 1
                      exit input
                   end if
                else
                   if w_cts04m00.atdlibflg = "N"   then
                      if ws.atdlibflg = "N" then
                         exit input
                      else
                         call cts40g03_data_hora_banco(2)
                             returning l_data_banco, l_hora2
                         let w_cts04m00.atdlibdat = l_data_banco
                         let w_cts04m00.atdlibhor = l_hora2
                         exit input
                      end if
                   end if
                end if
             end if
          else

             ##-- Se voltou com as teclas de direcao, testar assunto --##
             if m_acao_origem = "RET" or
                m_acao = "RET" then
                next field imdsrvflg
             else
                next field atdprinvlcod
             end if
          end if

   before field frmflg
          ##-- Se assunto e RET, sair do input --##
          if m_acao_origem = "RET" or m_acao = "RET" then
             exit input
          end if

          if g_documento.atdsrvnum is null  and
             g_documento.atdsrvano is null  then
             let d_cts04m00.frmflg = "N"
             display by name d_cts04m00.frmflg attribute (reverse)
          else
             if w_cts04m00.atdfnlflg = "S"  then
                call cts11g00(w_cts04m00.lignum)
                let int_flag = true
             end if
             exit input
          end if

   after  field frmflg
          display by name d_cts04m00.frmflg

          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if d_cts04m00.frmflg = "S" then
                if d_cts04m00.atdlibflg = "N"  then
                   error " Nao e' possivel registrar servico nao",
                         " liberado via formulario!"
                   next field atdlibflg
                end if
                call cts02m05(4) returning w_cts04m00.atddat,
                                           w_cts04m00.atdhor,
                                           w_cts04m00.funmat,
                                           w_cts04m00.cnldat,
                                           w_cts04m00.atdfnlhor,
                                           w_cts04m00.c24opemat,
                                           w_cts04m00.atdprscod

                if w_cts04m00.atddat    is null  or
                   w_cts04m00.atdhor    is null  or
                   w_cts04m00.funmat    is null  or
                   w_cts04m00.cnldat    is null  or
                   w_cts04m00.atdfnlhor is null  or
                   w_cts04m00.c24opemat is null  or
                   w_cts04m00.atdprscod is null  then
                   error " Faltam dados para entrada via formulario!"
                   next field frmflg
                end if

                let w_cts04m00.atdlibdat = w_cts04m00.atddat
                let w_cts04m00.atdlibhor = w_cts04m00.atdhor
                let w_cts04m00.atdfnlflg = "S"
                let w_cts04m00.atdetpcod =  3
             else
                if d_cts04m00.prslocflg = "N" then
                   initialize w_cts04m00.atddat   ,
                              w_cts04m00.atdhor   ,
                              w_cts04m00.funmat   ,
                              w_cts04m00.cnldat   ,
                              w_cts04m00.atdfnlhor,
                              w_cts04m00.c24opemat,
                              w_cts04m00.atdfnlflg,
                              w_cts04m00.atdprscod  to null
                end if
             end if
          end if

   on key (interrupt)
      if g_documento.atdsrvnum is null  and
         g_documento.atdsrvano is null  then
         if cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","") = "S"  then
            let int_flag = true
            exit input
         end if
      else
         exit input
      end if

   on key (F1)
      if g_documento.c24astcod is not null then
         call ctc58m00_vis(g_documento.c24astcod)
      end if

#PSI186406 -Robson -Inicio
   on key (F2)

      if m_acao_origem = "RET" or
         m_acao = 'RET' then
         let lr_d_ant_cts04m00.* = d_cts04m00.*
         let lr_movimento.* = mr_movimento.*
         let lr_w_ant_cts04m00.* = w_cts04m00.*
         let al_a_ant_cts04m00[1].* = a_cts04m00[1].*
         let l_acao        = m_acao
         let l_acao_origem = m_acao_origem
         let g_documento.atdsrvnum = m_atdorgsrvnum
         let g_documento.atdsrvano = m_atdorgsrvano
         let g_documento.acao      = "CON"

         let l_flag = cts04g00("cts04m00")

         let m_atdorgsrvnum = g_documento.atdsrvnum
         let m_atdorgsrvano = g_documento.atdsrvano
         let g_documento.acao      = "RET"
         let m_acao                = l_acao
         let m_acao_origem         = l_acao_origem
         let d_cts04m00.*          = lr_d_ant_cts04m00.*
         let mr_movimento.*        = lr_movimento.*
         let w_cts04m00.*          = lr_w_ant_cts04m00.*
         let a_cts04m00[1].*       = al_a_ant_cts04m00[1].*

         if m_acao_origem = "RET" then
            let g_documento.atdsrvnum = null
            let g_documento.atdsrvano = null
         else
            let g_documento.atdsrvnum = m_atdorgsrvnum
            let g_documento.atdsrvano = m_atdorgsrvano
         end if
      else

         call cts17m01(g_documento.atdsrvnum
                      ,g_documento.atdsrvano)
         returning l_atdsrvnum
                  ,l_atdsrvano
         if l_atdsrvnum is not null and
            l_atdsrvnum <> 0 then
            let m_atdsrvnum           = g_documento.atdsrvnum
            let m_atdsrvano           = g_documento.atdsrvano
            let g_documento.atdsrvnum = l_atdsrvnum
            let g_documento.atdsrvano = l_atdsrvano
            let g_documento.acao      = "CON"
            let lr_d_ant_cts04m00.*      = d_cts04m00.*
            let lr_movimento.* = mr_movimento.*
            let lr_w_ant_cts04m00.*      = w_cts04m00.*
            let al_a_ant_cts04m00[1].*   = a_cts04m00[1].*

            let l_flag = cts04g00("cts04m00")

            let g_documento.atdsrvnum = m_atdsrvnum
            let g_documento.atdsrvano = m_atdsrvano
            let g_documento.acao      = l_acao
            let m_acao                = l_acao
            let m_acao_origem         = l_acao_origem
            let d_cts04m00.*          = lr_d_ant_cts04m00.*
            let mr_movimento.*        = lr_movimento.*
            let w_cts04m00.*          = lr_w_ant_cts04m00.*
            let a_cts04m00[1].*       = al_a_ant_cts04m00[1].*
         end if
      end if

#PSI186406 -Robson -Fim

   on key (F5)
       let g_monitor.horaini = current ## Flexvision
       call cta01m12_espelho(g_documento.ramcod,
                            g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            g_documento.pcacarnum,
                            g_documento.pcaprpitm,
                            g_ppt.cmnnumdig,
                            g_documento.crtsaunum,
                            g_documento.bnfnum,
                            g_documento.ciaempcod)

   on key (F6)
      if g_documento.atdsrvnum is null  and
         g_documento.atdsrvano is null  then
         call cts10m02(hist_cts04m00.*) returning hist_cts04m00.*
      else
         call cts10n00(g_documento.atdsrvnum, g_documento.atdsrvano,
                       g_issk.funmat, aux_today, aux_hora)
      end if

   on key (F7)
      if g_documento.atdsrvnum is null  and
         g_documento.atdsrvano is null  then
         error " Impressao somente com preenchimento do servico!"
      else
         call ctr03m02(g_documento.atdsrvnum, g_documento.atdsrvano)
      end if
## PSI 172065 - Inicio

   on key (F8)
      call cts21m03(d_cts04m00.sinvstnum,
                    d_cts04m00.sinvstano)

## PSI 172065 - Final

   on key (F9)
      if g_documento.atdsrvnum is null  and
         g_documento.atdsrvano is null  then
         error " Servico nao cadastrado!"
      else
         if d_cts04m00.atdlibflg = "N"   then
            error " Servico nao liberado!"
         else
            call cta00m06_acionamento(g_issk.dptsgl)
            returning l_acesso
            if l_acesso = true then
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 0 )
            else
               call cts00m02(g_documento.atdsrvnum, g_documento.atdsrvano, 2 )
            end if
         end if
      end if

   on key (F3)
      call cts00m23(g_documento.atdsrvnum, g_documento.atdsrvano)

 end input

 if int_flag  then
    error " Operacao cancelada!"
    initialize hist_cts04m00.* to null
 end if

return hist_cts04m00.*

end function  ###  input_cts04m00

---> Danos Eletricos
#------------------------------------------------------------------------
function cts04m00_natureza()
#------------------------------------------------------------------------

 define lr_popup       record
        lin            smallint   # Nro da linha
       ,col            smallint   # Nro da coluna
       ,titulo         char (054) # Titulo do Formulario
       ,tit2           char (012) # Titulo da 1a.coluna
       ,tit3           char (040) # Titulo da 2a.coluna
       ,tipcod         char (001) # Tipo do Codigo a retornar
                                  # 'N' - Numerico
                                  # 'A' - Alfanumerico
       ,cmd_sql        char (1999)# Comando SQL p/ pesquisa
       ,aux_sql        char (200) # Complemento SQL apos where
       ,tipo           char (001) # Tipo de Popup
                                  # 'D' Direto
                                  # 'E' Com entrada
 end  record

 define lr_retorno     record
        erro           smallint,
        socntzcod      like datmsrvre.socntzcod,
        socntzdes      like datksocntz.socntzdes
 end record

 initialize lr_retorno.*  to  null
 initialize lr_popup.*  to  null

 let lr_popup.lin    = 10
 let lr_popup.col    = 10
 let lr_popup.titulo = "Naturezas Porto Socorro"
 let lr_popup.tit2   = "Codigo"
 let lr_popup.tit3   = "Descricao"
 let lr_popup.tipcod = "N"
 let lr_popup.cmd_sql = " select socntzcod ,socntzdes ",
                          " from datksocntz ",
                         " where c24pbmgrpcod = 106 " clipped
                        ##" order by socntzcod "
 let lr_popup.tipo   = "D"

 call ofgrc001_popup(lr_popup.*)
      returning lr_retorno.*

 let int_flag = false

 return lr_retorno.erro
       ,lr_retorno.socntzcod
       ,lr_retorno.socntzdes

end function
#-----------------------------------------------------   fim.
