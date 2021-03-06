#############################################################################
# Nome do Modulo: CTG2                                                Pedro #
#                                                                   Marcelo #
# Menu de Atendimento                                              Nov/1994 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 08/04/1999  ** ERRO **   Gilberto     Substituir nome do programa de con- #
#                                       sultas de propostas de PA_PACP1.4GI #
#                                       para OPACM200.4GI (Unicenter).      #
#---------------------------------------------------------------------------#
# 07/08/2000  Arnaldo      Ruiz         Inclusao da Lista de Ramais no menu #
#---------------------------------------------------------------------------#
# 23/05/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################
#                                                                           #
#                        * * * Alteracoes * * *                             #
#                                                                           #
# Data        Autor Fabrica  Origem      Alteracao                          #
# ---------- --------------- ---------- ----------------------------------- #
# 20/11/2003  Meta, Bruno    PSI179345  Criar uma nova opcao de menu e      #
#                            OSF28851   alterar chamada da funcao cts00m00. #
#                                                                           #
# 20/07/2004  Meta, Robson   PSI183431  Inibir ctg2_demanda e substituir    #
#                            OSF036439  cta00m00 por cta00m05.              #
#---------------------------------------------------------------------------#
# 11/01/2005  Julianna,Meta  PSI187887  Chamar o modulo ctx01g03            #
#---------------------------------------------------------------------------#
# 11/03/2005  Daniel , Meta  PSI191094  Chamar a funcao cta00m06 e cosistir #
#                                       retorno                             #
#---------------------------------------------------------------------------#
# 24/07/2006  Priscila       PSI 199850 Chamar funcao ctx26g00 quando foi   #
#                                       solicitado a visualizacao de todas  #
#                                       as ligacoes de uma apolice "CHist"  #
#                                       ou quando foi solicitado o preench. #
#                                       de um "Laudo"                       #
# 02/03/2007 Ligia Mattge               Chamar cta00m08_ver_contingencia    #
#---------------------------------------------------------------------------#
# 26/01/2009 Sergio Burini   PSI 235790 Tela Radio Cart�o Porto Seguro      #
#---------------------------------------------------------------------------#
#---------------------------------------------------------------------------#
# 30/03/2009 Amilton, Meta   CT 684023  Ajuste no retorno da fun��o         #
#                                       ctd24g00_valida_atd                 #
#---------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853      Implementacao do PSS            #
#---------------------------------------------------------------------------#
# 13/05/2010 Carla Rampazzo PSI 219444 -A partir do nro.Atendimento bsucar  #
#                                       lclnumseq/rmerscseq                 #
#---------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

 define l_servico    char(30) # CRM
 define l_ret_siebel smallint # CRM
 define w_log     char(60)

# --- PSI 179345 - Inicio

 define m_prep_sql      smallint

# --- PSI 179345 - Final
MAIN
   define w_data    date
   define w_ret     integer
   ---------------------[ alteracao para apoio - Ruiz ]-------------------
   define w_param   char(100)   # ruiz
   define w_apoio   char(01)
   define w_empcodatd like isskfunc.empcod
   define w_funmatatd like isskfunc.funmat
   define w_usrtipatd like isskfunc.usrtip
   -----------------------------------------------------------------------

# PSI 179345 - Inicio

   define l_demanda  char(15),
          l_contingencia  smallint,
          ret_hdk_funeral smallint

   define l_parm          record
          atdprscod       like datmservico.atdprscod,
          atdvclsgl       like datkveiculo.atdvclsgl,
          srrcoddig       like dattfrotalocal.srrcoddig,
          socvclcod       like dattfrotalocal.socvclcod,
          prvcalc         char(06),
          dstqtd          dec(8,4),
          flag_cts00m02   dec(1,0)
   end record

# PSI 179345 - Final

 define l_grlinf    like igbkgeral.grlinf             # PSI183431 - robson - inicio
       ,l_resultado smallint
       ,l_mensagem  char(60)

 define l_flag_acesso smallint,
        l_flag        smallint,
        l_aux         char(05),
        l_lignum      like datmligacao.lignum,
        l_ramgrpcod   like gtakram.ramgrpcod

 define l_texto  char(100)    #PSI199850

 ####################### psi 230.650
 define lr_documento  record
        succod        like datrligapol.succod,      # Codigo Sucursal
        aplnumdig     like datrligapol.aplnumdig,   # Numero Apolice
        itmnumdig     like datrligapol.itmnumdig,   # Numero do Item
        edsnumref     like datrligapol.edsnumref,   # Numero do Endosso
        prporg        like datrligprp.prporg,       # Origem da Proposta
        prpnumdig     like datrligprp.prpnumdig,    # Numero da Proposta
        fcapacorg     like datrligpac.fcapacorg,    # Origem PAC
        fcapacnum     like datrligpac.fcapacnum,    # Numero PAC
        pcacarnum     like eccmpti.pcapticod,       # No. Cartao PortoCard
        pcaprpitm     like epcmitem.pcaprpitm,      # Item (Veiculo) PortoCard
        solnom        char (15),                    # Solicitante
        soltip        char (01),                    # Tipo Solicitante
        c24soltipcod  like datmligacao.c24soltipcod,# Tipo do Solicitante
        ramcod        like datrservapol.ramcod,     # Codigo Ramo
        lignum        like datmligacao.lignum,      # Numero da Ligacao
        c24astcod     like datkassunto.c24astcod,   # Assunto da Ligacao
        ligcvntip     like datmligacao.ligcvntip,   # Convenio Operacional
        atdsrvnum     like datmservico.atdsrvnum,   # Numero do Servico
        atdsrvano     like datmservico.atdsrvano,   # Ano do Servico
        sinramcod     like ssamsin.ramcod,          # Prd Parcial-Ramo sinistro
        sinano        like ssamsin.sinano,          # Prd Parcial-Ano sinistro
        sinnum        like ssamsin.sinnum,          # Prd Parcial-Num sinistro
        sinitmseq     like ssamitem.sinitmseq,      # Prd Parcial-Itemp/ramo 53
        acao          char (03),                    # ALT, REC ou CAN
        atdsrvorg     like datksrvtip.atdsrvorg,    # Origem do tipo de Servico
        cndslcflg     like datkassunto.cndslcflg,   # Flag solicita condutor
        lclnumseq     like rsdmlocal.lclnumseq,     # Local de Risco
        vstnumdig     like datmvistoria.vstnumdig,  # numero da vistoria
        flgIS096      char (01)                  ,  # flag cobertura claus.096
        flgtransp     char (01)                  ,  # flag averbacao transporte
        apoio         char (01)                  ,  # flag atend.peloapoio(S/N)
        empcodatd     like datmligatd.apoemp     ,  # empresa do atendente
        funmatatd     like datmligatd.apomat     ,  # matricula do atendente
        usrtipatd     like datmligatd.apotip     ,  # tipo do atendente
        corsus        like gcaksusep.corsus      ,  # psi172413 eduardo - meta
        dddcod        like datmreclam.dddcod     ,  # cod da area de discagem
        ctttel        like datmreclam.ctttel     ,  # numero do telefone
        funmat        like isskfunc.funmat       ,  # matricula do funcionario
        cgccpfnum     like gsakseg.cgccpfnum     ,  # numero do CGC(CNPJ)
        cgcord        like gsakseg.cgcord        ,  # filial do CGC(CNPJ)
        cgccpfdig     like gsakseg.cgccpfdig     ,  # digito do CGC(CNPJ) ou CPF
        atdprscod     like datmservico.atdprscod ,
        atdvclsgl     like datkveiculo.atdvclsgl ,
        srrcoddig     like datmservico.srrcoddig ,
        socvclcod     like datkveiculo.socvclcod ,
        dstqtd        dec(8,4)                   ,
        prvcalc       interval hour(2) to minute ,
        lclltt        like datmlcl.lclltt        ,
        lcllgt        like datmlcl.lcllgt        ,
        rcuccsmtvcod  like datrligrcuccsmtv.rcuccsmtvcod, ## Codigo do Motivo
        c24paxnum     like datmligacao.c24paxnum ,        # Numero da P.A.
        averbacao     like datrligtrpavb.trpavbnum,       # PSI183431 Daniel
        crtsaunum     like datksegsau.crtsaunum,
        bnfnum        like datksegsau.bnfnum,
        ramgrpcod     like gtakram.ramgrpcod
 end record

 define lr_ppt        record
        segnumdig     like gsakseg.segnumdig,
        cmnnumdig     like pptmcmn.cmnnumdig,
        endlgdtip     like rlaklocal.endlgdtip,
        endlgdnom     like rlaklocal.endlgdnom,
        endnum        like rlaklocal.endnum,
        ufdcod        like rlaklocal.ufdcod,
        endcmp        like rlaklocal.endcmp,
        endbrr        like rlaklocal.endbrr,
        endcid        like rlaklocal.endcid,
        endcep        like rlaklocal.endcep,
        endcepcmp     like rlaklocal.endcepcmp,
        edsstt        like rsdmdocto.edsstt,
        viginc        like rsdmdocto.viginc,
        vigfnl        like rsdmdocto.vigfnl,
        emsdat        like rsdmdocto.emsdat,
        corsus        like rsampcorre.corsus,
        pgtfrm        like rsdmdadcob.pgtfrm,
        mdacod        like gfakmda.mdacod,
        lclrsccod     like rlaklocal.lclrsccod
 end record

 define lr_ret_ctd24g00            record
        resultado             smallint
       ,mensagem              char(60)
       ,ciaempcod             like datmatd6523.ciaempcod
       ,solnom                like datmatd6523.solnom
       ,flgavstransp          like datmatd6523.flgavstransp
       ,c24soltipcod          like datmatd6523.c24soltipcod
       ,ramcod                like datmatd6523.ramcod
       ,flgcar                like datmatd6523.flgcar
       ,vcllicnum             like datmatd6523.vcllicnum
       ,corsus                like datmatd6523.corsus
       ,succod                like datmatd6523.succod
       ,aplnumdig             like datmatd6523.aplnumdig
       ,itmnumdig             like datmatd6523.itmnumdig
       ,etpctrnum             like datmatd6523.etpctrnum
       ,segnom                like datmatd6523.segnom
       ,pestip                like datmatd6523.pestip
       ,cgccpfnum             like datmatd6523.cgccpfnum
       ,cgcord                like datmatd6523.cgcord
       ,cgccpfdig             like datmatd6523.cgccpfdig
       ,prporg                like datmatd6523.prporg
       ,prpnumdig             like datmatd6523.prpnumdig
       ,flgvp                 like datmatd6523.flgvp
       ,vstnumdig             like datmatd6523.vstnumdig
       ,vstdnumdig            like datmatd6523.vstdnumdig
       ,flgvd                 like datmatd6523.flgvd
       ,flgcp                 like datmatd6523.flgcp
       ,cpbnum                like datmatd6523.cpbnum
       ,semdcto               like datmatd6523.semdcto
       ,ies_ppt               like datmatd6523.ies_ppt
       ,ies_pss               like datmatd6523.ies_pss
       ,transp                like datmatd6523.transp
       ,trpavbnum             like datmatd6523.trpavbnum
       ,vclchsfnl             like datmatd6523.vclchsfnl
       ,sinramcod             like datmatd6523.sinramcod
       ,sinnum                like datmatd6523.sinnum
       ,sinano                like datmatd6523.sinano
       ,sinvstnum             like datmatd6523.sinvstnum
       ,sinvstano             like datmatd6523.sinvstano
       ,flgauto               like datmatd6523.flgauto
       ,sinautnum             like datmatd6523.sinautnum
       ,sinautano             like datmatd6523.sinautano
       ,flgre                 like datmatd6523.flgre
       ,sinrenum              like datmatd6523.sinrenum
       ,sinreano              like datmatd6523.sinreano
       ,flgavs                like datmatd6523.flgavs
       ,sinavsnum             like datmatd6523.sinavsnum
       ,sinavsano             like datmatd6523.sinavsano
       ,semdoctoempcodatd     like datmatd6523.semdoctoempcodatd
       ,semdoctopestip        like datmatd6523.semdoctopestip
       ,semdoctocgccpfnum     like datmatd6523.semdoctocgccpfnum
       ,semdoctocgcord        like datmatd6523.semdoctocgcord
       ,semdoctocgccpfdig     like datmatd6523.semdoctocgccpfdig
       ,semdoctocorsus        like datmatd6523.semdoctocorsus
       ,semdoctofunmat        like datmatd6523.semdoctofunmat
       ,semdoctoempcod        like datmatd6523.semdoctoempcod
       ,semdoctodddcod        like datmatd6523.semdoctodddcod
       ,semdoctoctttel        like datmatd6523.semdoctoctttel
       ,funmat                like datmatd6523.funmat
       ,empcod                like datmatd6523.empcod
       ,usrtip                like datmatd6523.usrtip
       ,caddat                like datmatd6523.caddat
       ,cadhor                like datmatd6523.cadhor
       ,ligcvntip             like datmatd6523.ligcvntip
 end record

  define lr_framc215    record
         resultado      smallint
        ,mensagem       char(60)
        ,lclrsccod      like rlaklocal.lclrsccod
        ,lgdtip         like datmlcl.lgdtip
        ,lgdnom         like datmlcl.lgdnom
        ,lgdnum         like datmlcl.lgdnum
        ,lclbrrnom      like datmlcl.lclbrrnom
        ,cidnom         like datmlcl.cidnom
        ,ufdcod         like datmlcl.ufdcod
        ,lgdcep         like datmlcl.lgdcep
        ,lgdcepcmp      like datmlcl.lgdcepcmp
        ,rmeblcdes      like rsdmbloco.rmeblcdes
        ,lclltt         like datmlcl.lclltt
        ,lcllgt         like datmlcl.lcllgt
  end record
 define lr_ret_cts14n00 record
        erro    integer,
        mens    char(300)
 end record

 ####################### psi 230.650

 # Integracao CRM HDK / Funeral
 define ctz00m02 record
        ifxsblitgseqnum  like datmifxsblitg.ifxsblitgseqnum
       ,sblitenum        like datmifxsblitg.sblitenum
       ,sblatdnum        like datmifxsblitg.sblatdnum
       ,atdclitipcod     like datmifxsblitg.atdclitipcod
       ,bcpclicod        like datmifxsblitg.bcpclicod
       ,clinom           like datmifxsblitg.clinom
       ,clicpfnum        like datmifxsblitg.clicpfnum
       ,clicnpnum        like datmifxsblitg.clicnpnum
       ,suscod           like datmifxsblitg.suscod
       ,prscod           like datmifxsblitg.prscod
       ,fncclimatcod     like datmifxsblitg.fncclimatcod
       ,sblatdgrpnom     like datmifxsblitg.sblatdgrpnom
       ,trtdcttipnom     like datmifxsblitg.trtdcttipnom
       ,trtdctcod        like datmifxsblitg.trtdctcod
       ,refdcttipnom     like datmifxsblitg.refdcttipnom
       ,refdctcod        like datmifxsblitg.refdctcod
       ,atdasttipnom     like datmifxsblitg.atdasttipnom
       ,atdastdes        like datmifxsblitg.atdastdes
       ,atdsatdes        like datmifxsblitg.atdsatdes
       ,atdusrmatcod     like datmifxsblitg.atdusrmatcod
       ,legsisnom        like datmifxsblitg.legsisnom
       ,envdat           like datmifxsblitg.envdat
       ,legsisltrflg     like datmifxsblitg.legsisltrflg
 end record
 define l_conf         char(1)
 define l_resposta     char(1)
 initialize g_atd_siebel to null # CRM
 initialize ctz00m02.*        to null
 initialize lr_documento.*    to null
 initialize lr_ppt.*          to null
 initialize lr_ret_ctd24g00.* to null
 initialize lr_ret_cts14n00.* to null

 let l_lignum        = null
 let l_grlinf        = null
 let l_resultado     = null
 let l_mensagem      = null                               # PSI183431 - robson - fim
 let l_texto         = null                               #PSI 199850
 let l_contingencia  = null
 let ret_hdk_funeral = null
 let g_senha_cnt     = null

   initialize g_c24paxnum   to null
   initialize g_documento.* to null
   initialize g_pss.*       to null

   initialize g_monitor.dataini   to null ## dataini   date,
   initialize g_monitor.horaini   to null ## horaini   datetime hour to fraction,
   initialize g_monitor.horafnl   to null ## horafnl   datetime hour to fraction,
   initialize g_monitor.intervalo to null ## intervalo datetime hour to fraction

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------
   call fun_dba_abre_banco("CT24HS")
   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg2.log"

   call startlog(w_log)


   select sitename into g_hostname from dual

   let g_hostname = g_hostname[1,3]

  defer interrupt
  # --CLAUSULA PARA EXECUTAR A "LEITURA SUJA" DOS REGISTROS
  set isolation to dirty read
  # --TEMPO PARA VERIFICAR SE O REGISTRO ESTA ALOCADO
  set lock mode to wait 180

   options
      prompt  line last,
      comment line last,
      message line last,
      accept  key  F40

   whenever error continue
   initialize g_ppt.* to null

   open window WIN_CAB at 2,2 with 22 rows,78 columns
        attribute (border)

   let w_data = today
   display "CENTRAL 24 HS" at 01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
   display w_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()

   let w_param = arg_val(15)

   if w_param[1,5] = "Apoio" then
      call cta09m00()
      if g_documento.apoio = "S"  then
         let w_apoio       = g_documento.apoio
         let w_empcodatd   = g_documento.empcodatd
         let w_funmatatd   = g_documento.funmatatd
         let w_usrtipatd   = g_documento.usrtipatd
         if  g_documento.atdnum  is not null and
             g_documento.atdnum <> 0        then
             call ctd24g00_valida_atd( g_documento.atdnum, g_documento.ciaempcod, 3 )
             returning  lr_ret_ctd24g00.resultado
                       ,lr_ret_ctd24g00.mensagem
                       ,lr_ret_ctd24g00.ciaempcod
                       ,lr_ret_ctd24g00.solnom
                       ,lr_ret_ctd24g00.flgavstransp
                       ,lr_ret_ctd24g00.c24soltipcod
                       ,lr_ret_ctd24g00.ramcod
                       ,lr_ret_ctd24g00.flgcar
                       ,lr_ret_ctd24g00.vcllicnum
                       ,lr_ret_ctd24g00.corsus
                       ,lr_ret_ctd24g00.succod
                       ,lr_ret_ctd24g00.aplnumdig
                       ,lr_ret_ctd24g00.itmnumdig
                       ,lr_ret_ctd24g00.etpctrnum
                       ,lr_ret_ctd24g00.segnom
                       ,lr_ret_ctd24g00.pestip
                       ,lr_ret_ctd24g00.cgccpfnum
                       ,lr_ret_ctd24g00.cgcord
                       ,lr_ret_ctd24g00.cgccpfdig
                       ,lr_ret_ctd24g00.prporg
                       ,lr_ret_ctd24g00.prpnumdig
                       ,lr_ret_ctd24g00.flgvp
                       ,lr_ret_ctd24g00.vstnumdig
                       ,lr_ret_ctd24g00.vstdnumdig
                       ,lr_ret_ctd24g00.flgvd
                       ,lr_ret_ctd24g00.flgcp
                       ,lr_ret_ctd24g00.cpbnum
                       ,lr_ret_ctd24g00.semdcto
                       ,lr_ret_ctd24g00.ies_ppt
                       ,lr_ret_ctd24g00.ies_pss
                       ,lr_ret_ctd24g00.transp
                       ,lr_ret_ctd24g00.trpavbnum
                       ,lr_ret_ctd24g00.vclchsfnl
                       ,lr_ret_ctd24g00.sinramcod
                       ,lr_ret_ctd24g00.sinnum
                       ,lr_ret_ctd24g00.sinano
                       ,lr_ret_ctd24g00.sinvstnum
                       ,lr_ret_ctd24g00.sinvstano
                       ,lr_ret_ctd24g00.flgauto
                       ,lr_ret_ctd24g00.sinautnum
                       ,lr_ret_ctd24g00.sinautano
                       ,lr_ret_ctd24g00.flgre
                       ,lr_ret_ctd24g00.sinrenum
                       ,lr_ret_ctd24g00.sinreano
                       ,lr_ret_ctd24g00.flgavs
                       ,lr_ret_ctd24g00.sinavsnum
                       ,lr_ret_ctd24g00.sinavsano
                       ,lr_ret_ctd24g00.semdoctoempcodatd
                       ,lr_ret_ctd24g00.semdoctopestip
                       ,lr_ret_ctd24g00.semdoctocgccpfnum
                       ,lr_ret_ctd24g00.semdoctocgcord
                       ,lr_ret_ctd24g00.semdoctocgccpfdig
                       ,lr_ret_ctd24g00.semdoctocorsus
                       ,lr_ret_ctd24g00.semdoctofunmat
                       ,lr_ret_ctd24g00.semdoctoempcod
                       ,lr_ret_ctd24g00.semdoctodddcod
                       ,lr_ret_ctd24g00.semdoctoctttel
                       ,lr_ret_ctd24g00.funmat
                       ,lr_ret_ctd24g00.empcod
                       ,lr_ret_ctd24g00.usrtip
                       ,lr_ret_ctd24g00.caddat
                       ,lr_ret_ctd24g00.cadhor
                       ,lr_ret_ctd24g00.ligcvntip
             ## ? #carregar a global    edsnumref
             let lr_documento.ligcvntip    = lr_ret_ctd24g00.ligcvntip
             let lr_documento.succod       = lr_ret_ctd24g00.succod
             let lr_documento.aplnumdig    = lr_ret_ctd24g00.aplnumdig
             let lr_documento.itmnumdig    = lr_ret_ctd24g00.itmnumdig
             let lr_documento.prporg       = lr_ret_ctd24g00.prporg
             let lr_documento.prpnumdig    = lr_ret_ctd24g00.prpnumdig
             let lr_documento.solnom       = lr_ret_ctd24g00.solnom
             let lr_documento.c24soltipcod = lr_ret_ctd24g00.c24soltipcod
             let lr_documento.ramcod       = lr_ret_ctd24g00.ramcod
             let lr_documento.sinramcod    = lr_ret_ctd24g00.sinramcod
             let lr_documento.sinano       = lr_ret_ctd24g00.sinnum
             let lr_documento.sinnum       = lr_ret_ctd24g00.sinano
             let lr_documento.vstnumdig    = lr_ret_ctd24g00.vstnumdig
             let lr_documento.empcodatd    = lr_ret_ctd24g00.semdoctoempcodatd
             let lr_documento.usrtipatd    = lr_ret_ctd24g00.semdoctopestip
             let lr_documento.corsus       = lr_ret_ctd24g00.corsus
             let lr_documento.dddcod       = lr_ret_ctd24g00.semdoctodddcod
             let lr_documento.ctttel       = lr_ret_ctd24g00.semdoctoctttel
             let lr_documento.funmat       = lr_ret_ctd24g00.funmat
             let lr_documento.cgccpfnum    = lr_ret_ctd24g00.cgccpfnum
             let lr_documento.cgcord       = lr_ret_ctd24g00.cgcord
             let lr_documento.cgccpfdig    = lr_ret_ctd24g00.cgccpfdig
             let g_documento.ligcvntip     = lr_documento.ligcvntip
             let g_documento.c24soltipcod  = lr_documento.c24soltipcod
             let g_documento.solnom        = lr_documento.solnom
             let g_documento.succod        = lr_documento.succod
             let g_documento.ramcod        = lr_documento.ramcod
             let g_documento.aplnumdig     = lr_documento.aplnumdig
             let g_documento.itmnumdig     = lr_documento.itmnumdig
             let g_documento.prporg        = lr_documento.prporg
             let g_documento.prpnumdig     = lr_documento.prpnumdig
             let g_documento.sinramcod     = lr_documento.sinramcod
             let g_documento.sinano        = lr_documento.sinano
             let g_documento.sinnum        = lr_documento.sinnum
             let g_documento.cgccpfnum     = lr_ret_ctd24g00.semdoctocgccpfnum
             let g_documento.cgcord        = lr_ret_ctd24g00.semdoctocgcord
             let g_documento.cgccpfdig     = lr_ret_ctd24g00.semdoctocgccpfdig
             let g_documento.corsus        = lr_ret_ctd24g00.semdoctocorsus
             let g_documento.funmat        = lr_ret_ctd24g00.semdoctofunmat

             ---> Verifica se Documento e do RE
             if g_documento.ramcod is not null  and
                g_documento.ramcod <> 0         then

                call cty10g00_grupo_ramo(g_documento.ciaempcod
                                        ,g_documento.ramcod)
                               returning l_resultado
                                        ,l_mensagem
                                        ,l_ramgrpcod

                --> Se for Ramo do RE Resgata Local de Risco / Bloco
                if l_ramgrpcod           = 4          and  ---> RE
                   g_documento.ramcod    is not null  and
                   g_documento.ramcod    <> 0         and
                   g_documento.aplnumdig is not null  and
                   g_documento.aplnumdig <> 0         then

                   ---> Recuperar Nro. Ligacao
                   select max (lignum)
                     into l_lignum
                     from datratdlig
                    where atdnum = g_documento.atdnum

                   ---> Recuperar Local de Risco
                   select lclrsccod
                     into g_rsc_re.lclrsccod
                     from datrligsrv a
                         ,datmsrvre  b
                    where a.lignum    = l_lignum
                      and a.atdsrvnum = b.atdsrvnum
                      and a.atdsrvano = b.atdsrvano


                   initialize g_documento.lclnumseq
                             ,g_documento.rmerscseq to null


                   ---> Recuperar Seq. Local de Risco / Bloco
                   select lclnumseq
                         ,rmerscseq
                     into g_documento.lclnumseq
                         ,g_documento.rmerscseq
                     from datmrsclcllig
                    where lignum = l_lignum

                   if g_documento.lclnumseq is null or
                      g_documento.rmerscseq is null then
                      call framc215(g_documento.succod
                                   ,g_documento.ramcod
                                   ,g_documento.aplnumdig)
                       returning lr_framc215.resultado
                                ,lr_framc215.mensagem
                                ,g_rsc_re.lclrsccod
                                ,lr_framc215.lgdtip
                                ,lr_framc215.lgdnom
                                ,lr_framc215.lgdnum
                                ,lr_framc215.lclbrrnom
                                ,lr_framc215.cidnom
                                ,lr_framc215.ufdcod
                                ,lr_framc215.lgdcep
                                ,lr_framc215.lgdcepcmp
                                ,g_documento.lclnumseq
                                ,g_documento.rmerscseq
                                ,lr_framc215.rmeblcdes
                                ,lr_framc215.lclltt
                                ,lr_framc215.lcllgt
                   end if
                end if
             end if

             if g_documento.ciaempcod = 84 then # Itau

                let g_documento.itaciacod = lr_ret_ctd24g00.etpctrnum

                if lr_documento.ramcod = 31 then

                     call cty22g00_rec_ult_sequencia(g_documento.itaciacod ,
                                                     lr_documento.ramcod   ,
                                                     lr_documento.aplnumdig)
                     returning g_documento.edsnumref,
                               l_resultado          ,
                               l_mensagem

                     if l_resultado <> 0 then
                          error l_mensagem sleep 5
                          exit program(-1)
                     else

                          call cty22g00_rec_dados_itau(g_documento.itaciacod ,
                                                       lr_documento.ramcod   ,
                                                       lr_documento.aplnumdig,
                                                       g_documento.edsnumref ,
                                                       lr_documento.itmnumdig)
                          returning l_resultado ,
                                    l_mensagem

                          if l_resultado <> 0 then
                               error l_mensagem sleep 5
                               exit program(-1)
                          end if

                     end if
               else

                  call cty25g00_rec_ult_sequencia(g_documento.itaciacod ,
                                                  lr_documento.ramcod   ,
                                                  lr_documento.aplnumdig )
                  returning g_documento.edsnumref,
                            l_resultado          ,
                            l_mensagem

                  if l_resultado <> 0 then
                       error l_mensagem sleep 5
                       exit program(-1)
                  else

                       call cty25g01_rec_dados_itau(g_documento.itaciacod ,
                                                    lr_documento.ramcod   ,
                                                    lr_documento.aplnumdig,
                                                    g_documento.edsnumref ,
                                                    lr_documento.itmnumdig)
                       returning l_resultado ,
                                 l_mensagem

                       if l_resultado <> 0 then
                            error l_mensagem sleep 5
                            exit program(-1)
                       end if

                  end if
               end if
             end if

             call cta00m05_mostra_empresa(g_documento.ciaempcod)

             #-- Solicitar Assunto --#
             call cta02m00_solicitar_assunto(lr_documento.*,lr_ppt.*)
         end if
      end if
   else
      if w_param[1,5] = "Benef" then
         let g_documento.succod    = w_param[06,07]
         let g_documento.ramcod    = w_param[08,11]
         let g_documento.aplnumdig = w_param[12,20]
         let g_documento.itmnumdig = w_param[21,27]


         call cta08m00()
         exit program(-1)
      else
         #PSI 199850 - Consultar Historico de servicos da apolice
         if w_param[1,5] = "CHist" or
            w_param[1,5] = "Laudo" then
            #chama funcao auxiliar passando o restante da string
            let l_texto = w_param[1,100]

            call ctx26g00(l_texto)
            exit program(-1)
         end if
         if g_issk.sissgl = 'CarroExtra' then
            call ctx01g03_solicitacoes()
            exit program(-1)
         end if
      end if
   end if

   display "---------------------------------------------------------------",
           "---------ctg2--" at 03,01

   let l_flag_acesso = cta00m06(g_issk.dptsgl)


   call cts14g02("N", "ctg2")

   menu "OPCOES"

   before menu
   let g_atd_siebel = 0
          hide option all
          if g_issk.prgsgl = "ctg2T" then
             let g_issk.prgsgl = "ctg2"
          end if

     # Modificado a pedido do Carlos Ruiz
     # Matricula da azul s� pode ver o menu azul seguros
     if g_issk.empcod <> 35 then
          if get_niv_mod(g_issk.prgsgl,"cta00m05") then   ## 6-TUDO       #PSI183431 - robson
             if g_issk.acsnivcod <= g_issk.acsnivcns or   ## 2-CONSULTA
                g_issk.acsnivcod >= g_issk.acsnivatl then ## 3-ATUALIZA
                show option "Atd_Porto"
                show option "Atd_aZul"
                show option "Atd_Itau"
                show option "Atd_CGC/CPF"
                show option "Atd_PSS"
                show option "Integracao_CRM"
             end if
          end if


          if get_niv_mod(g_issk.prgsgl,"cts16m00") then
             if g_issk.acsnivcod >= g_issk.acsnivcns then ## NIVEL 6
                show option "Servicos"
             end if
          end if

          if get_niv_mod("ctg9","cts06m00") then
             call acess_prog("Vpr_ct24h", "ctg9")  returning w_ret
             if w_ret  <>  -1   then
                show option "Vist_previa"
             end if
          end if

          if get_niv_mod(g_issk.prgsgl,"cts14n00") then
             if g_issk.acsnivcod >= g_issk.acsnivcns then ## NIVEL 6
                show option "sInistro"
             end if
          end if

          if get_niv_mod(g_issk.prgsgl,"cts00m00") then   ## NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Radio"
             end if
          end if

          show option "demaNda" # PSI 179345

          if get_niv_mod(g_issk.prgsgl,"cts00m00") then   ## NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "raDio_RE"
             end if
          end if
          # PSI 23597- Tela Cartao Porto Seguro
          if get_niv_mod(g_issk.prgsgl,"cts00m00") then   ## NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "radiO_cartao"
             end if
          end if

          if get_niv_mod(g_issk.prgsgl,"cts00m00") then   ## NIVEL 6
            if g_issk.acsnivcod >= g_issk.acsnivcns then
               show option "Reserva_Itau"
            end if
          end if

          if get_niv_mod(g_issk.prgsgl,"cts14n01") then   ## NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "Reguladores"
             end if
          end if

          if get_niv_mod(g_issk.prgsgl,"cts00m00") then   ## NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "JIT"
             end if
          end if


          call acess_prog("AcProposta", "opacm200")  returning w_ret
          if w_ret  <>  -1   then
             show option "acProposta"
          end if

          ## CallBack
          if get_niv_mod(g_issk.prgsgl,"cts50m00") then   ## NIVEL 6
             if g_issk.acsnivcod >= g_issk.acsnivcns then
                show option "aBandono"
             end if
          end if

          show option "semdocTo"
                     ,"transFerencia"
                     ,"Relatorio"
     else
          # Modificado a pedido do Carlos Ruiz.
          # Matricula da Azul so poder� ver o menu na Atd_aZul
          if get_niv_mod(g_issk.prgsgl,"cta00m05") then
             if g_issk.acsnivcod <= g_issk.acsnivcns or
                g_issk.acsnivcod >= g_issk.acsnivatl then
                show option "Atd_aZul"
             end if
          end if
          if ctc62m00_acessa_menu(g_issk.funmat,g_issk.empcod) then
                show option "Servicos"
          end if
     end if
          show option "Encerra"

          #-------------------------------------------------------------------
          # Alterado em 25/02/97, conforme PSI 2484-8 (Neusa-Sinistro)
          #-------------------------------------------------------------------
          if g_issk.dptsgl    = "cmpnas"  and
             g_issk.acsnivcod = 3         then
             hide option "Atendimento"
             show option "sInistro"
          end if


      command key ("A") "Atd_Porto"
                        "Atendimento telefonico Porto Seguros"
         initialize g_documento.* to null
         #-- Chamada da classe de controle de atendimento --#
         let g_documento.ciaempcod = '1'
         let l_flag = cta00m05_controle(w_apoio,
                                        w_empcodatd,
                                        w_funmatatd,
                                        w_usrtipatd,
                                        g_c24paxnum)  # PSI183431 - robson - fim

      command key ("Z") "Atd_aZul"
                        "Atendimento telefonico Azul Seguros"
         initialize g_documento.* to null
         let g_documento.ciaempcod = '35'
         let l_flag = cta00m05_controle(w_apoio,
                                        w_empcodatd,
                                        w_funmatatd,
                                        w_usrtipatd,
                                        g_c24paxnum)  # PSI183431 - robson - fim

      command key ("+") "Atd_Itau"
                       "Atendimento Itau Seguros Auto e Residencia"
        initialize g_documento.* to null

        let g_documento.ciaempcod = '84'

        let l_flag = cta00m05_controle(w_apoio,
                                       w_empcodatd,
                                       w_funmatatd,
                                       w_usrtipatd,
                                       g_c24paxnum)


      command key ("C") "Atd_CGC/CPF"
                      "Atendimento por CGC/CPF"
       initialize g_documento.* to null


       let l_flag = cta00m05_controle(w_apoio,
                                      w_empcodatd,
                                      w_funmatatd,
                                      w_usrtipatd,
                                      g_c24paxnum)  # PSI183431 - robson - fim

      command key ("U") "Atd_PSS"
                      "Atendimento Porto Seguro Servi�os"
       initialize g_documento.* to null
       let g_documento.ciaempcod = '43'
       let l_flag = cta00m05_controle(w_apoio,
                                      w_empcodatd,
                                      w_funmatatd,
                                      w_usrtipatd,
                                      g_c24paxnum)  # PSI183431 - robson - fim


      command key ("F") "transFerencia" "Transferencia do Atendimento"
         call cta02m22()
      command key ("Q") "Relatorio" "Relatorio Auto Premium"
         call cty44g00() 
         
      command key ("-") "Integracao_CRM" "Integracao CRM"
      call cta00m08_ver_contingencia(1) #
           returning l_contingencia

      if not l_contingencia then
         # Inicializar as globais para Laudos HDK/Funeral
         call ctz00m02_hdk_funeral()
         returning ret_hdk_funeral
      end if
      let g_atd_siebel = 0
      command key ("V") "Vist_previa"
                        "Vistoria Previa Domiciliar"
         initialize g_documento.*   to null
         initialize w_ret           to null

         call chama_prog("Vpr_ct24h", "ctg9", "")  returning w_ret
         if w_ret = -1  then
            error " Sistema nao disponivel no momento!"
         end if

         initialize g_documento.*   to null

      command key ("I") "sInistro"
                        "Vistoria e Aviso de Sinistro"
         initialize g_documento.*   to null
         call cts14n00()
         returning lr_ret_cts14n00.erro,lr_ret_cts14n00.mens

      command key ("S") "Servicos"
                        "Reclamacao, Alteracao, Cancelamento de Servicos"
         initialize g_documento.*   to null
         call cts16m00()

      command key ("R") "Radio"
                        "Controle de Servicos - Pendencias"
         initialize g_documento.*   to null

         # Verifica se a matricula esta habilitada para utilizar acionamento no informix
         if cts00m00_verifica_acesso_menu() then
            call cts00m00(0,"","","","","","","","")  # PSI 179345
         else
            call cts08g01("A","N","AS FUNCIONALIDADES DESTE MENU DEVEM SER","UTILIZADAS NO SISTEMA AW.",
                          "","EM CASO DE DUVIDA, CONTATE A COORDENACAO")
                 returning l_resposta         	
         end if

 # --- PSI 179345 -- Inicio -----

      command key ("N") "demaNda"
                        "Controle de Servicos - Demandas"
         initialize g_documento.*   to null
         #let g_senha_cnt = null

#         let l_demanda = ctg2_demanda()              # PSI183431 - robson - inicio
         call cty11g00_igbkgeral('C24'
                                ,'RADIO-DEM*')
         returning l_resultado
                  ,l_mensagem
                  ,l_grlinf

#         if l_demanda is null then
         if l_resultado = 1 then
            if l_grlinf is null then
               error 'Nao existe demanda ativa !!!' sleep 2
            else
               call cta00m08_ver_contingencia(3)
                    returning l_contingencia

               if l_contingencia = false then

                  # Verifica ambiente de ROTERIZACAO
                  if ctx25g05_rota_ativa() then
                     call ctx25g04("","","",l_grlinf)  returning l_parm.*
                  else
                     call cts00m20("","","",l_grlinf)  returning l_parm.*
                  end if

               end if
            end if
         else
            call errorlog(l_mensagem)
         end if                                       # PSI183431 - robson - fim

 # --- PSI 179345 -- Final -----

      command key ("D") "raDio_RE"
                        "Controle de Servicos - Radio RE"
         initialize g_documento.*   to null
         # Verifica se a matricula esta habilitada para utilizar acionamento no informix
         if cts00m00_verifica_acesso_menu() then
            call cts00m00(9,"","","","","","","","")  # PSI 179345
         else
            call cts08g01("A","N","AS FUNCIONALIDADES DESTE MENU DEVEM SER","UTILIZADAS NO SISTEMA AW.",
                          "","EM CASO DE DUVIDA, CONTATE A COORDENACAO")
                 returning l_resposta         	
         end if

      # PSI 235970 - Tela Cartao Porto Seguro
      command key ("O") "radiO_cartao"
                        "Controle de Servicos - Cartao Porto Seguro"
         initialize g_documento.*   to null
         # Verifica se a matricula esta habilitada para utilizar acionamento no informix
         if cts00m00_verifica_acesso_menu() then
            call cts00m00("",40,"","","","","","","")
         else
            call cts08g01("A","N","AS FUNCIONALIDADES DESTE MENU DEVEM SER","UTILIZADAS NO SISTEMA AW.",
                          "","EM CASO DE DUVIDA, CONTATE A COORDENACAO")
                 returning l_resposta         	
         end if

      command key ("Y") "Reserva_Itau"
                        "Gestao Carro Reserva Itau"
         initialize g_documento.*   to null
         call cts64m10()


      command key ("G") "reGuladores"
                        "Reguladores RE"
         initialize g_documento.*   to null
         call cts14n01()


      command key ("J") "JIT"
                        "Controle de Servicos - JIT"
         initialize g_documento.*   to null
         # Verifica se a matricula esta habilitada para utilizar acionamento no informix
         if cts00m00_verifica_acesso_menu() then
            call cts00m00(15,"","","","","","","","")  # PSI 179345
         else
            call cts08g01("A","N","AS FUNCIONALIDADES DESTE MENU DEVEM SER","UTILIZADAS NO SISTEMA AW.",
                          "","EM CASO DE DUVIDA, CONTATE A COORDENACAO")
                 returning l_resposta         	
         end if

      command key ("P") "acProposta"
                        "Acompanhamento de propostas"
         initialize g_documento.*   to null
         initialize w_ret           to null

         call chama_prog("AcProposta", "opacm200", "")  returning w_ret
         if w_ret = -1  then
            error " Sistema nao disponivel no momento!"
         end if

      command key ("B") "aBandono" "Ligacoes em abandono"
         call cts50m00()

      command key ("T") "semdocTo" "Atendimentos sem Documento"
         call cts35m02()

      command key (interrupt,E) "Encerra" "Fim de servico"
         exit menu
   end menu

   close window win_cab
   close window win_menu

   let int_flag = false                               #PSI183431 - robson

END MAIN

#----------------------------------------------------------
function p_reg_logo()
#----------------------------------------------------------
     define ba char(01)


	let	ba  =  null

     open form reg from "apelogo2"
     display form reg
     let ba = ascii(92)
     display ba at 15,23
     display ba at 14,22
     display "PORTO SEGURO" AT 16,52
     display "                                  Seguros" at 17,23
             attribute (reverse)
end function

# --- PSI 179345 --- Inicio -----

#-----------------------------------------------------------
  function ctg2_prepare()
#-----------------------------------------------------------

  define l_sql       char(300)

     let l_sql = " select grlinf, grlchv ",
                 "   from igbkgeral      ",
                 "  where mducod = 'C24' ",
                 "    and grlchv matches 'RADIO-DEM*'"
     prepare p_ctg2_001          from l_sql
     declare c_ctg2_001          cursor for p_ctg2_001

   let m_prep_sql = true

  end function
#-----------------------------------------------------------
  function ctg2_demanda()
#-----------------------------------------------------------

  define l_grlinf     like igbkgeral.grlinf
  define l_grlchv     like igbkgeral.grlchv
  define l_achou      smallint

  if m_prep_sql is null or
     m_prep_sql <> true then
       call ctg2_prepare()
  end if

  let   l_grlchv = null

  open  c_ctg2_001
  whenever error continue
  fetch c_ctg2_001      into l_grlinf,
                           l_grlchv
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode <> notfound then
        error 'Problemas de acesso a tabela IGBKGERAL, ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
        error 'ctg2_demanda()' sleep 2
     end if
  end if

  return l_grlchv

  end function

 # --- PSI 179345 --- Final -----
#----------------------------------------------------------------
function ctg2_crm(lr_param)
#----------------------------------------------------------------
 define lr_param record
        trtdcttipnom     like datmifxsblitg.trtdcttipnom
       ,trtdctcod        like datmifxsblitg.trtdctcod
 end record
 define l_pipe char(01)
 define l_cont      integer
 define l_cont1     integer
 define l_contorg   integer
 define l_contprp   integer
 define l_contramo  integer
 define l_contapol  integer
 define l_contitem  integer
 define l_lclrsccod integer
 define l_lclnumseq integer
 define l_rmerscseq integer
 define l_org       like datrligprp.prporg
 define l_prp       like datrligprp.prpnumdig
 define l_suc       like datrligapol.succod
 define l_ramo      like datrservapol.ramcod
 define l_apol      like datrligapol.aplnumdig
 define l_item      like datrligapol.itmnumdig
 define l_ret_out   record                           # Parametros Saida
    result              smallint                   , # 0   - OK
    msg_erro            char(100)                    # 1   - Erro
 end record                                          # 100 - Notfound
  initialize l_pipe,       l_cont,       l_cont1      , l_ramo,
             l_suc,        l_apol,       l_item       , l_lclrsccod,
             l_lclnumseq,  l_rmerscseq,  l_org        , l_prp,
             l_ret_out to null
 if lr_param.trtdcttipnom <> "APOLICE"  and
    lr_param.trtdcttipnom <> "Proposta" then
    initialize l_pipe,       l_cont,       l_cont1      , l_ramo,
               l_suc,        l_apol,       l_item       , l_lclrsccod,
               l_lclnumseq,  l_rmerscseq,  l_org        , l_prp  to null
    return l_suc      , l_ramo     , l_apol   , l_item
          ,l_lclrsccod, l_lclnumseq, l_rmerscseq
          ,l_org      , l_prp
 end if
 # Trata Documento recebido pelo CRM-Siebel
 if lr_param.trtdcttipnom = "APOLICE" then # 1 -AP�LICE, "Apolice"
                                           # 2 -CONTRATO,
                                           # 3 -OR�AMENTO,
                                           # 4 -VISTORIA PR�VIA,
                                           # 5 -ORDEM DE PAGAMENTO,
                                           # 6 -ORDEM DE SERVI�O,
                                           # 7 -COBERTURA PROVIS�RIA,
                                           # 8 -PROPOSTA,
                                           # 9 -ESTUDO ACEITA��O,
                                           # 10-SINISTRO
    let l_cont  = 0
    let l_cont1 = 0
    let lr_param.trtdctcod = lr_param.trtdctcod clipped, "."
    for l_cont  = 1 to length(lr_param.trtdctcod) + 1
        let l_pipe = lr_param.trtdctcod[l_cont ,l_cont ]
        if l_pipe <> "-" then
           continue for
        else
           let l_cont1 = l_cont1 + 1
           # Sucursal
           if l_cont1 = 1 then
              let l_suc      = lr_param.trtdctcod[1,l_cont-1]
              let l_contramo = l_cont + 1
           end if
           # Ramo
           if l_cont1 = 2 then
              let l_ramo     = lr_param.trtdctcod[l_contramo,l_cont-1]
              let l_contapol =  l_cont + 1
           end if
           # Apolice
           if l_cont1 = 3 then
              let l_apol      = lr_param.trtdctcod[l_contapol,l_cont-1]
              let l_contitem  =  l_cont + 1
           end if
           # Definido que item para RE ser� o Local de Risco(Priscila)
           # Item
           if l_cont1 = 4 then
              let l_item = lr_param.trtdctcod[l_contitem,l_cont-1]
              let l_contorg = l_cont + 1
           end if
           if l_cont1 = 5 then
              let l_org     = lr_param.trtdctcod[l_contorg,l_cont-1]
              let l_contprp = l_cont + 1
           end if
           if l_cont1 = 6 then
                 let l_prp = lr_param.trtdctcod[l_contprp,l_cont-1]
                 # Buscar local de Risco vindo do Item do Siebel
                 call framc403_seleciona_local(l_org,l_prp,l_item )
                 returning  l_ret_out.result ,l_ret_out.msg_erro,
                            l_lclrsccod, l_lclnumseq
                 if l_ret_out.result = 1 then
                    error l_ret_out.msg_erro sleep 3
                    initialize l_pipe,       l_cont,       l_cont1      , l_ramo,
                               l_suc,        l_apol,       l_item       , l_lclrsccod,
                               l_lclnumseq,  l_rmerscseq,  l_org        , l_prp to null
                    exit for
                 else
                    let l_rmerscseq = 0
                 end if
           end if
           if l_pipe = "" then
              let l_cont1 = l_cont1 + 1
           end if
        end if
    end for
 end if
 if lr_param.trtdcttipnom = "Proposta" then # 1 -AP�LICE,
                                            # 2 -CONTRATO,
                                            # 3 -OR�AMENTO,
                                            # 4 -VISTORIA PR�VIA,
                                            # 5 -ORDEM DE PAGAMENTO,
                                            # 6 -ORDEM DE SERVI�O,
                                            # 7 -COBERTURA PROVIS�RIA,
                                            # 8 -PROPOSTA,
                                            # 9 -ESTUDO ACEITA��O,
                                            # 10-SINISTRO
    let l_cont  = 0
    let l_cont1 = 0
    let lr_param.trtdctcod = lr_param.trtdctcod clipped, "."
    for l_cont  = 1 to length(lr_param.trtdctcod) + 1
        let l_pipe = lr_param.trtdctcod[l_cont ,l_cont ]
        if l_pipe <> "-" then
           continue for
        else
           let l_cont1 = l_cont1 + 1
           # Origem
           if l_cont1 = 1 then
              let l_org      = lr_param.trtdctcod[1,l_cont-1]
              let l_contprp = l_cont + 1
           end if
           # Proposta
           if l_cont1 = 2 then
              let l_prp = lr_param.trtdctcod[l_contprp,l_cont-1]
           end if
        end if
    end for
 end if
 return l_suc      , l_ramo     , l_apol     , l_item
       ,l_lclrsccod, l_lclnumseq, l_rmerscseq
       ,l_org      , l_prp
end function