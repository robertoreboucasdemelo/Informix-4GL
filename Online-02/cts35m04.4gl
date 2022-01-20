#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS35M04                                                   #
# FUNCAO.........: cts35m04_PesquisaApoliceAzul
# QUEM CHAMA?....: CTS35M00
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 209007                                                     #
#                  MODULO PARA PESQUISA DE APOLICES DA AZUL SEGUROS           #
#                  PARA A CONTINGENCIA.                                       #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR           ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 29/05/07   Ruiz            psi 209007 versao inicial                        #
#-----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

define mr_documento  record
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
       ramcod        like datrservapol.ramcod,     # Codigo aamo
       lignum        like datmligacao.lignum,      # Numero da Ligacao
       c24astcod     like datkassunto.c24astcod,   # Assunto da Ligacao
       ligcvntip     like datmligacao.ligcvntip,   # Convenio Operacional
       atdsrvnum     like datmservico.atdsrvnum,   # Numero do Servico
       atdsrvano     like datmservico.atdsrvano,   # Ano do Servico
       sinramcod     like ssamsin.ramcod,          # Prd Parcial - Ramo sinistro
       sinano        like ssamsin.sinano,          # Prd Parcial - Ano sinistro
       sinnum        like ssamsin.sinnum,          # Prd Parcial - Num sinistro
       sinitmseq     like ssamitem.sinitmseq,     # Prd Parcial - Item p/ramo 53
       acao          char (03),                    # ALT, REC ou CAN
       atdsrvorg     like datksrvtip.atdsrvorg,    # Origem do tipo de Servico
       cndslcflg     like datkassunto.cndslcflg,   # Flag solicita condutor
       lclnumseq     like rsdmlocal.lclnumseq,     # Local de Risco
       vstnumdig     like datmvistoria.vstnumdig,  # numero da vistoria
       flgIS096      char (01)                  ,  # flag cobertura claus.096
       flgtransp     char (01)                  ,  # flag averbacao transporte
       apoio         char (01)                  ,  # flag atend. pelo apoio(S/N)
       empcodatd     like datmligatd.apoemp     ,  # empresa do atendente
       funmatatd     like datmligatd.apomat     ,  # matricula do atendente
       usrtipatd     like datmligatd.apotip     ,  # tipo do atendente
       corsus        char(06)      ,  #
       dddcod        char(04)      ,  # codigo da area de discagem
       ctttel        char(20)      ,  # numero do telefone
       funmat        decimal(6,0)  ,  # matricula do funcionario
       cgccpfnum     decimal(12,0) ,  # numero do CGC(CNPJ)
       cgcord        decimal(4,0)  ,  # filial do CGC(CNPJ)
       cgccpfdig     decimal(2,0)  ,  # digito do CGC(CNPJ) ou CPF
       atdprscod     like datmservico.atdprscod ,
       atdvclsgl     like datkveiculo.atdvclsgl ,
       srrcoddig     like datmservico.srrcoddig ,
       socvclcod     like datkveiculo.socvclcod ,
       dstqtd        dec(8,4)                   ,
       prvcalc       interval hour(2) to minute ,
       lclltt        like datmlcl.lclltt        ,
       lcllgt        like datmlcl.lcllgt        ,
       rcuccsmtvcod  like datrligrcuccsmtv.rcuccsmtvcod,    ## Codigo do Motivo
       c24paxnum     like datmligacao.c24paxnum ,           # Numero da P.A.
       averbacao     like datrligtrpavb.trpavbnum,          # PSI183431 Daniel
       crtsaunum     like datksegsau.crtsaunum,
       bnfnum        like datksegsau.bnfnum,
       ramgrpcod     like gtakram.ramgrpcod
end record
define mr_segurado record
        nome        char(60),
        cgccpf      char(20),
        pessoa      char(01),
        dddfone     char(04),
        numfone     char(15),
        email       char(100)
end record

define mr_corretor record
        susep       char(06),
        nome        char(50),
        dddfone     char(04),
        numfone     char(15),
        dddfax      char(04),
        numfax      char(15),
        email       char(100)
end record

define mr_veiculo  record
        codigo      char(10),
        marca       char(30),
        tipo        char(30),
        modelo      char(30),
        chassi      char(20),
        placa       char(07),
        anofab      char(04),
        anomod      char(04),
        catgtar     char(10),
        automatico  char(03),
        vcldes      like datmservico.vcldes,
        vclchsinc   like abbmveic.vclchsinc,
        vclchsfnl   like abbmveic.vclchsfnl
end record

define mr_convenio record
        cvnnom      like iddkdominio.cpodes
end record

define m_resultado   smallint

define mr_documento2 record
       viginc        date,
       vigfnl        date,
       segcod        integer,
       segnom        char(50),
       vcldes        char(25),
       resultado     smallint,
       emsdat        date,
       doc_handle    integer,
       mensagem      char(50),
       situacao      char(10)
end record

define l_totg integer
define l_tot  integer

------------------------------------------------------------------------------#
function cts35m04_prepare()
------------------------------------------------------------------------------#

  define l_cmd char(5000)

  let l_cmd  =  null

  let l_cmd = "select seqreg "
             ," ,seqregcnt "
             ," ,atdsrvorg "
             ," ,atdsrvnum "
             ," ,atdsrvano "
             ," ,srvtipabvdes "
             ," ,atdnom "
             ," ,funmat "
             ," ,asitipabvdes "
             ," ,c24solnom "
             ," ,vcldes "
             ," ,vclanomdl "
             ," ,vclcor "
             ," ,vcllicnum "
             ," ,vclcamtip "
             ," ,vclcrgflg "
             ," ,vclcrgpso "
             ," ,atddfttxt "
             ," ,segnom "
             ," ,aplnumdig "
             ," ,cpfnum "
             ," ,ocrufdcod "
             ," ,ocrcidnom "
             ," ,ocrbrrnom "
             ," ,ocrlgdnom "
             ," ,ocrendcmp "
             ," ,ocrlclcttnom "
             ," ,ocrlcltelnum "
             ," ,ocrlclrefptotxt "
             ," ,dsttipflg "
             ," ,dstufdcod "
             ," ,dstcidnom "
             ," ,dstbrrnom "
             ," ,dstlgdnom "
             ," ,rmcacpflg "
             ," ,obstxt "
             ," ,srrcoddig "
             ," ,srrabvnom "
             ," ,atdvclsgl "
             ," ,atdprscod "
             ," ,nomgrr "
             ," ,atddat "
             ," ,atdhor "
             ," ,acndat "
             ," ,acnhor "
             ," ,acnprv "
             ," ,c24openom "
             ," ,c24opemat "
             ," ,pasnom1 "
             ," ,pasida1 "
             ," ,pasnom2 "
             ," ,pasida2 "
             ," ,pasnom3 "
             ," ,pasida3 "
             ," ,pasnom4 "
             ," ,pasida4 "
             ," ,pasnom5 "
             ," ,pasida5 "
             ," ,atldat "
             ," ,atlhor "
             ," ,atlmat "
             ," ,atlnom "
             ," ,cnlflg "
             ," ,cnldat "
             ," ,cnlhor "
             ," ,cnlmat "
             ," ,cnlnom "
             ," ,socntzcod "
             ," ,c24astcod "
             ," ,atdorgsrvnum "
             ," ,atdorgsrvano "
             ," ,srvtip "
             ," ,acnifmflg "
             ," ,dstsrvnum "
             ," ,dstsrvano "
             ," ,prcflg "
             ," ,ramcod "
             ," ,succod "
             ," ,itmnumdig "
             ," ,ocrlcldddcod "
             ," ,cpfdig "
             ," ,cgcord "
             ," ,ocrendzoncod "
             ," ,dstendzoncod "
             ," ,sindat "
             ," ,sinhor "
             ," ,bocnum "
             ," ,boclcldes "
             ," ,sinavstip "
             ," ,vclchscod "
             ," ,obscmptxt "
             ," ,crtsaunum "
             ," ,ciaempcod "
        ,"  from datmcntsrv "
       ,"  where seqreg = ?   "

  prepare p_cts35m04_001 from l_cmd
  declare c_cts35m04_001 cursor with hold for p_cts35m04_001

  let l_cmd = " select a.azlaplcod ",
                " from datkazlapl a" ,
               " where a.vcllicnum = ? ",
                "  and a.edsnumdig in (select max(edsnumdig) ",
                                       " from datkazlapl b ",
                                      " where a.succod    = b.succod ",
                                        " and a.aplnumdig = b.aplnumdig ",
                                        " and a.itmnumdig = b.itmnumdig ",
                                        " and a.ramcod    = b.ramcod) "

  prepare p_cts35m04_002 from l_cmd
  declare c_cts35m04_002 cursor for p_cts35m04_002
end function
---------------------------------------------------------------------------#
function cts35m04_PesquisaApoliceAzul(param)
---------------------------------------------------------------------------#
   define param           record
          seqreg          like datmcntsrv.seqreg,
          funmat          like datmcntsrv.funmat,
          c24opemat       like datmcntsrv.c24opemat
   end record
   define l_datmcntsrv    record
          seqreg          like datmcntsrv.seqreg,
          seqregcnt       like datmcntsrv.seqregcnt,
          atdsrvorg       like datmcntsrv.atdsrvorg,
          atdsrvnum       like datmcntsrv.atdsrvnum,
          atdsrvano       like datmcntsrv.atdsrvano,
          srvtipabvdes    like datmcntsrv.srvtipabvdes,
          atdnom          like datmcntsrv.atdnom,
          funmat          like datmcntsrv.funmat,
          asitipabvdes    like datmcntsrv.asitipabvdes,
          c24solnom       like datmcntsrv.c24solnom,
          vcldes          like datmcntsrv.vcldes,
          vclanomdl       like datmcntsrv.vclanomdl,
          vclcor          like datmcntsrv.vclcor,
          vcllicnum       like datmcntsrv.vcllicnum,
          vclcamtip       like datmcntsrv.vclcamtip,
          vclcrgflg       like datmcntsrv.vclcrgflg,
          vclcrgpso       like datmcntsrv.vclcrgpso,
          atddfttxt       like datmcntsrv.atddfttxt,
          segnom          like datmcntsrv.segnom,
          aplnumdig       like datmcntsrv.aplnumdig,
          cpfnum          like datmcntsrv.cpfnum,
          ocrufdcod       like datmcntsrv.ocrufdcod,
          ocrcidnom       like datmcntsrv.ocrcidnom,
          ocrbrrnom       like datmcntsrv.ocrbrrnom,
          ocrlgdnom       like datmcntsrv.ocrlgdnom,
          ocrendcmp       like datmcntsrv.ocrendcmp,
          ocrlclcttnom    like datmcntsrv.ocrlclcttnom,
          ocrlcltelnum    like datmcntsrv.ocrlcltelnum,
          ocrlclrefptotxt like datmcntsrv.ocrlclrefptotxt,
          dsttipflg       like datmcntsrv.dsttipflg,
          dstufdcod       like datmcntsrv.dstufdcod,
          dstcidnom       like datmcntsrv.dstcidnom,
          dstbrrnom       like datmcntsrv.dstbrrnom,
          dstlgdnom       like datmcntsrv.dstlgdnom,
          rmcacpflg       like datmcntsrv.rmcacpflg,
          obstxt          like datmcntsrv.obstxt,
          srrcoddig       like datmcntsrv.srrcoddig,
          srrabvnom       like datmcntsrv.srrabvnom,
          atdvclsgl       like datmcntsrv.atdvclsgl,
          atdprscod       like datmcntsrv.atdprscod,
          nomgrr          like datmcntsrv.nomgrr,
          atddat          like datmcntsrv.atddat,
          atdhor          like datmcntsrv.atdhor,
          acndat          like datmcntsrv.acndat,
          acnhor          like datmcntsrv.acnhor,
          acnprv          like datmcntsrv.acnprv,
          c24openom       like datmcntsrv.c24openom,
          c24opemat       like datmcntsrv.c24opemat,
          pasnom1         like datmcntsrv.pasnom1,
          pasida1         like datmcntsrv.pasida1,
          pasnom2         like datmcntsrv.pasnom2,
          pasida2         like datmcntsrv.pasida2,
          pasnom3         like datmcntsrv.pasnom3,
          pasida3         like datmcntsrv.pasida3,
          pasnom4         like datmcntsrv.pasnom4,
          pasida4         like datmcntsrv.pasida4,
          pasnom5         like datmcntsrv.pasnom5,
          pasida5         like datmcntsrv.pasida5,
          atldat          like datmcntsrv.atldat,
          atlhor          like datmcntsrv.atlhor,
          atlmat          like datmcntsrv.atlmat,
          atlnom          like datmcntsrv.atlnom,
          cnlflg          like datmcntsrv.cnlflg,
          cnldat          like datmcntsrv.cnldat,
          cnlhor          like datmcntsrv.cnlhor,
          cnlmat          like datmcntsrv.cnlmat,
          cnlnom          like datmcntsrv.cnlnom,
          socntzcod       like datmcntsrv.socntzcod,
          c24astcod       like datmcntsrv.c24astcod,
          atdorgsrvnum    like datmcntsrv.atdorgsrvnum,
          atdorgsrvano    like datmcntsrv.atdorgsrvano,
          srvtip          like datmcntsrv.srvtip,
          acnifmflg       like datmcntsrv.acnifmflg,
          dstsrvnum       like datmcntsrv.dstsrvnum,
          dstsrvano       like datmcntsrv.dstsrvano,
          prcflg          like datmcntsrv.prcflg,
          ramcod          like datmcntsrv.ramcod,
          succod          like datmcntsrv.succod,
          itmnumdig       like datmcntsrv.itmnumdig,
          ocrlcldddcod    like datmcntsrv.ocrlcldddcod,
          cpfdig          like datmcntsrv.cpfdig,
          cgcord          like datmcntsrv.cgcord,
          ocrendzoncod    like datmcntsrv.ocrendzoncod,
          dstendzoncod    like datmcntsrv.dstendzoncod,
          sindat          like datmcntsrv.sindat,
          sinhor          like datmcntsrv.sinhor,
          bocnum          like datmcntsrv.bocnum ,
          boclcldes       like datmcntsrv.boclcldes,
          sinavstip       like datmcntsrv.sinavstip,
          vclchscod       like datmcntsrv.vclchscod,
          obscmptxt       like datmcntsrv.obscmptxt,
          crtsaunum       like datmcntsrv.crtsaunum,
          ciaempcod       like datmcntsrv.ciaempcod
   end record
   define ws              record
          lignum          like datmligacao.lignum   ,
          atdsrvnum       like datmservico.atdsrvnum,
          atdsrvano       like datmservico.atdsrvano,
          sqlcode         integer                   ,
          msgerro         char (300)                ,
          sinvstnum       like datmpedvist.sinvstnum,
          tabname         like systables.tabname    ,
          sinntzcod       like datmavssin.sinntzcod ,
          eqprgicod       like datmavssin.eqprgicod ,
          cidcod          like glakcid.cidcod       ,
          vclanofbc       like abbmveic.vclanofbc   ,
          vigfnl          like abbmdoc.vigfnl       ,
          viginc          like abbmdoc.viginc       ,
          hist            like datmservhist.c24srvdsc,
          histerr         smallint                   ,
          acheidocto      char (01)                  ,
          pestip          char (01)
   end record

   initialize ws.*            to null
   initialize l_datmcntsrv.*  to null
   initialize mr_veiculo.*    to null
   initialize mr_segurado.*   to null
   initialize mr_corretor.*   to null
   initialize mr_documento.*  to null
   initialize mr_documento2.* to null
   initialize l_tot           to null
   initialize l_totg          to null

   call cts35m04_prepare()

   open c_cts35m04_001 using param.seqreg
   foreach c_cts35m04_001 into l_datmcntsrv.seqreg
                            ,l_datmcntsrv.seqregcnt
                            ,l_datmcntsrv.atdsrvorg
                            ,l_datmcntsrv.atdsrvnum
                            ,l_datmcntsrv.atdsrvano
                            ,l_datmcntsrv.srvtipabvdes
                            ,l_datmcntsrv.atdnom
                            ,l_datmcntsrv.funmat
                            ,l_datmcntsrv.asitipabvdes
                            ,l_datmcntsrv.c24solnom
                            ,l_datmcntsrv.vcldes
                            ,l_datmcntsrv.vclanomdl
                            ,l_datmcntsrv.vclcor
                            ,l_datmcntsrv.vcllicnum
                            ,l_datmcntsrv.vclcamtip
                            ,l_datmcntsrv.vclcrgflg
                            ,l_datmcntsrv.vclcrgpso
                            ,l_datmcntsrv.atddfttxt
                            ,l_datmcntsrv.segnom
                            ,l_datmcntsrv.aplnumdig
                            ,l_datmcntsrv.cpfnum
                            ,l_datmcntsrv.ocrufdcod
                            ,l_datmcntsrv.ocrcidnom
                            ,l_datmcntsrv.ocrbrrnom
                            ,l_datmcntsrv.ocrlgdnom
                            ,l_datmcntsrv.ocrendcmp
                            ,l_datmcntsrv.ocrlclcttnom
                            ,l_datmcntsrv.ocrlcltelnum
                            ,l_datmcntsrv.ocrlclrefptotxt
                            ,l_datmcntsrv.dsttipflg
                            ,l_datmcntsrv.dstufdcod
                            ,l_datmcntsrv.dstcidnom
                            ,l_datmcntsrv.dstbrrnom
                            ,l_datmcntsrv.dstlgdnom
                            ,l_datmcntsrv.rmcacpflg
                            ,l_datmcntsrv.obstxt
                            ,l_datmcntsrv.srrcoddig
                            ,l_datmcntsrv.srrabvnom
                            ,l_datmcntsrv.atdvclsgl
                            ,l_datmcntsrv.atdprscod
                            ,l_datmcntsrv.nomgrr
                            ,l_datmcntsrv.atddat
                            ,l_datmcntsrv.atdhor
                            ,l_datmcntsrv.acndat
                            ,l_datmcntsrv.acnhor
                            ,l_datmcntsrv.acnprv
                            ,l_datmcntsrv.c24openom
                            ,l_datmcntsrv.c24opemat
                            ,l_datmcntsrv.pasnom1
                            ,l_datmcntsrv.pasida1
                            ,l_datmcntsrv.pasnom2
                            ,l_datmcntsrv.pasida2
                            ,l_datmcntsrv.pasnom3
                            ,l_datmcntsrv.pasida3
                            ,l_datmcntsrv.pasnom4
                            ,l_datmcntsrv.pasida4
                            ,l_datmcntsrv.pasnom5
                            ,l_datmcntsrv.pasida5
                            ,l_datmcntsrv.atldat
                            ,l_datmcntsrv.atlhor
                            ,l_datmcntsrv.atlmat
                            ,l_datmcntsrv.atlnom
                            ,l_datmcntsrv.cnlflg
                            ,l_datmcntsrv.cnldat
                            ,l_datmcntsrv.cnlhor
                            ,l_datmcntsrv.cnlmat
                            ,l_datmcntsrv.cnlnom
                            ,l_datmcntsrv.socntzcod
                            ,l_datmcntsrv.c24astcod
                            ,l_datmcntsrv.atdorgsrvnum
                            ,l_datmcntsrv.atdorgsrvano
                            ,l_datmcntsrv.srvtip
                            ,l_datmcntsrv.acnifmflg
                            ,l_datmcntsrv.dstsrvnum
                            ,l_datmcntsrv.dstsrvano
                            ,l_datmcntsrv.prcflg
                            ,l_datmcntsrv.ramcod
                            ,l_datmcntsrv.succod
                            ,l_datmcntsrv.itmnumdig
                            ,l_datmcntsrv.ocrlcldddcod
                            ,l_datmcntsrv.cpfdig
                            ,l_datmcntsrv.cgcord
                            ,l_datmcntsrv.ocrendzoncod
                            ,l_datmcntsrv.dstendzoncod
                            ,l_datmcntsrv.sindat
                            ,l_datmcntsrv.sinhor
                            ,l_datmcntsrv.bocnum
                            ,l_datmcntsrv.boclcldes
                            ,l_datmcntsrv.sinavstip
                            ,l_datmcntsrv.vclchscod
                            ,l_datmcntsrv.obscmptxt
                            ,l_datmcntsrv.crtsaunum
                            ,l_datmcntsrv.ciaempcod
      let l_datmcntsrv.c24opemat = param.c24opemat
      let l_datmcntsrv.funmat    = param.funmat

      let ws.acheidocto         = "N"
      let g_documento.edsnumref = 0
      let g_documento.ciaempcod = l_datmcntsrv.ciaempcod
      --[ apolice ]--
      if l_datmcntsrv.succod is not null    and
         l_datmcntsrv.succod <> 0           and
         l_datmcntsrv.aplnumdig is not null and
         l_datmcntsrv.aplnumdig <> 0        and
         l_datmcntsrv.itmnumdig is not null then
if g_issk.funmat = 601566 then
   display "* cts35m04 - pesquisa pela apol. = ",l_datmcntsrv.aplnumdig
end if
         call cts38m00_dados_apolice (l_datmcntsrv.succod,
                                      l_datmcntsrv.aplnumdig,
                                      l_datmcntsrv.itmnumdig,
                                      l_datmcntsrv.ramcod)
                        returning     mr_documento.aplnumdig,
                                      mr_documento.itmnumdig,
                                      mr_documento.edsnumref,
                                      mr_documento.succod,
                                      mr_documento.ramcod,
                                      mr_documento2.emsdat,
                                      mr_documento2.viginc,
                                      mr_documento2.vigfnl,
                                      mr_documento2.segcod,
                                      mr_documento2.segnom,
                                      mr_documento2.vcldes,
                                      mr_documento.corsus,
                                      mr_documento2.doc_handle,
                                      mr_documento2.resultado,
                                      mr_documento2.mensagem,
                                      mr_documento2.situacao
         if  mr_documento2.resultado = 1 then
             let ws.acheidocto = "S"
         end if
      end if
if g_issk.funmat = 601566 then
   display "* cts35m04 - pesquisa pela apol. = ",ws.acheidocto
end if
      if ws.acheidocto = "N" then
         --[ placa ]
         if l_datmcntsrv.vcllicnum is not null  and
            l_datmcntsrv.vcllicnum <> "       " then # 7p. campo tabela
if g_issk.funmat = 601566 then
   display "* cts35m04 - pesquisa pela placa = ",l_datmcntsrv.vcllicnum
end if
            call cts38m00_dados_placa(l_datmcntsrv.vcllicnum,"B")
                        returning     mr_documento.aplnumdig,
                                      mr_documento.itmnumdig,
                                      mr_documento.edsnumref,
                                      mr_documento.succod,
                                      mr_documento.ramcod,
                                      mr_documento2.emsdat,
                                      mr_documento2.viginc,
                                      mr_documento2.vigfnl,
                                      mr_documento2.segcod,
                                      mr_documento2.segnom,
                                      mr_documento2.vcldes,
                                      mr_documento.corsus,
                                      mr_documento2.doc_handle,
                                      mr_documento2.resultado,
                                      mr_documento2.mensagem,
                                      mr_documento2.situacao
            if mr_documento2.resultado = 1 then
               let ws.acheidocto = "S"
            end if
         end if
if g_issk.funmat = 601566 then
   display "* cts35m04 - pesquisa por placa  = ",ws.acheidocto
end if
         if ws.acheidocto = "N" then
            if l_datmcntsrv.cpfnum is not null and
               l_datmcntsrv.cpfnum <> 0        then
               if l_datmcntsrv.cgcord > 0 then
                  let ws.pestip = "J"
               else
                  let ws.pestip = "F"
               end if
if g_issk.funmat = 601566 then
   display "* cts35m04 - pesquisa por cgc/cpf = ",l_datmcntsrv.cpfnum," ",ws.pestip
end if
               call cts38m00_dados_cpfcgc(ws.pestip,
                                          l_datmcntsrv.cpfnum,
                                          l_datmcntsrv.cgcord,
                                          l_datmcntsrv.cpfdig,
                                          "B")
                        returning     mr_documento.aplnumdig,
                                      mr_documento.itmnumdig,
                                      mr_documento.edsnumref,
                                      mr_documento.succod,
                                      mr_documento.ramcod,
                                      mr_documento2.emsdat,
                                      mr_documento2.viginc,
                                      mr_documento2.vigfnl,
                                      mr_documento2.segcod,
                                      mr_documento2.segnom,
                                      mr_documento2.vcldes,
                                      mr_documento.corsus,
                                      mr_documento2.doc_handle,
                                      mr_documento2.resultado,
                                      mr_documento2.mensagem,
                                      mr_documento2.situacao
               if mr_documento2.resultado = 1 then
                  let ws.acheidocto = "S"
               end if
            end if
         end if
      end if
if g_issk.funmat = 601566 then
   display "* cts35m04 - pesquisa por cgc/cpf = ",ws.acheidocto
end if
      if ws.acheidocto = "S" then
          # -> DADOS DO SEGURADO
         call cts40g02_extraiDoXML(mr_documento2.doc_handle,
                                   "SEGURADO")
              returning mr_segurado.nome,
                        mr_segurado.cgccpf,
                        mr_segurado.pessoa,
                        mr_segurado.dddfone,
                        mr_segurado.numfone,
                        mr_segurado.email

         # -> DADOS DO VEICULO
         call cts40g02_extraiDoXML(mr_documento2.doc_handle,
                                   "VEICULO")
              returning mr_veiculo.codigo,
                        mr_veiculo.marca,
                        mr_veiculo.tipo,
                        mr_veiculo.modelo,
                        mr_veiculo.chassi,
                        mr_veiculo.placa,
                        mr_veiculo.anofab,
                        mr_veiculo.anomod,
                        mr_veiculo.catgtar,
                        mr_veiculo.automatico
         if mr_veiculo.codigo is not null then
            call cts15g00(mr_veiculo.codigo)
                 returning mr_veiculo.vcldes
         end if
         if mr_veiculo.chassi is not null then
            let l_totg = length(mr_veiculo.chassi)
            let l_tot  = (l_totg - 8)
            let mr_veiculo.vclchsinc = mr_veiculo.chassi[1,l_tot]
            let mr_veiculo.vclchsfnl = mr_veiculo.chassi[l_tot+1,l_totg]
         end if

         # -> DADOS DO CORRETOR
         call cts40g02_extraiDoXML(mr_documento2.doc_handle,
                                   "CORRETOR")
              returning mr_corretor.susep,
                        mr_corretor.nome,
                        mr_corretor.dddfone,
                        mr_corretor.numfone,
                        mr_corretor.dddfax,
                        mr_corretor.numfax,
                        mr_corretor.email

         ---[ busca nome do convenio - para Azul o convenio e Porto Seguro ]--
         select cpodes
            into mr_convenio.cvnnom
            from datkdominio
           where cponom = "ligcvntip" and
                 cpocod = 0

         let g_documento.succod    = mr_documento.succod
         let g_documento.ramcod    = mr_documento.ramcod
         let g_documento.aplnumdig = mr_documento.aplnumdig
         let g_documento.itmnumdig = mr_documento.itmnumdig
      end if
   end foreach
   if mr_documento2.resultado <> 1 then
      let mr_segurado.nome       = l_datmcntsrv.c24solnom
      let mr_veiculo.vcldes      = l_datmcntsrv.vcldes
      let mr_veiculo.anomod      = l_datmcntsrv.vclanomdl
      let mr_veiculo.placa       = l_datmcntsrv.vcllicnum
   end if
if g_issk.funmat = 601566 then
   display "* cts35m04 - retorno "
   display " mr_documento2.mensagem = ",mr_documento2.mensagem
   display " mr_documento2.resultado = ",mr_documento2.resultado
   display " mr_segurado.nome        = ",mr_segurado.nome
   display " mr_corretor.susep       = ",mr_corretor.susep
   display " mr_corretor.nome        = ",mr_corretor.nome
   display " mr_convenio.cvnnom      = ",mr_convenio.cvnnom
   display " mr_veiculo.codigo       = ",mr_veiculo.codigo
   display " mr_veiculo.vclchsinc    = ",mr_veiculo.vclchsinc
   display " mr_veiculo.vclchsfnl    = ",mr_veiculo.vclchsfnl
   display " mr_veiculo.vcldes       = ",mr_veiculo.vcldes
   display " mr_veiculo.anomod       = ",mr_veiculo.anomod
   display " mr_veiculo.placa        = ",mr_veiculo.placa
end if
   return mr_documento2.mensagem,
          mr_documento2.resultado,
          mr_segurado.nome,
          mr_corretor.susep,
          mr_corretor.nome,
          mr_convenio.cvnnom,
          mr_veiculo.codigo,
          mr_veiculo.vclchsinc,
          mr_veiculo.vclchsfnl,
          mr_veiculo.vcldes,
          mr_veiculo.anomod,
          mr_veiculo.placa
end function
