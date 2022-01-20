#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Teleatendimento                                           #
# Modulo.........: cta02m22                                                  #
# Objetivo.......: Modulo responsavel pela transferencio-> datmatdtrn        #
# Analista Resp. : Alberto Rodrigues                                         #
# PSI            : 230650                                                    #
#............................................................................#
# Desenvolvimento: Ana Raquel, META                                          #
# Liberacao      : 27/10/2008                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_lignum like datmligacao.lignum
      ,m_prep_sql            smallint
      ,m_flg_assunto         char(01)

define mr_cta02m22           record
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

define mr_cta02m22a           record
       resultado              smallint
      ,mensagem               char(60)
      ,atdnum                 like datmatdtrn.atdnum
      ,atdtrnnum              like datmatdtrn.atdtrnnum
      ,trnlignum              like datmatdtrn.trnlignum
      ,necgerlignum           like datmatdtrn.necgerlignum
      ,atdpripanum            like datmatdtrn.atdpripanum
      ,atdpridptsgl           like datmatdtrn.atdpridptsgl
      ,atdprifunmat           like datmatdtrn.atdprifunmat
      ,atdpriusrtip           like datmatdtrn.atdpriusrtip
      ,atdpriempcod           like datmatdtrn.atdpriempcod
      ,trndat                 like datmatdtrn.trndat
      ,trnhor                 like datmatdtrn.trnhor
      ,atdsegpanum            like datmatdtrn.atdsegpanum
      ,atdsegdptsgl           like datmatdtrn.atdsegdptsgl
      ,atdsegfunmat           like datmatdtrn.atdsegfunmat
      ,atdsegusrtip           like datmatdtrn.atdsegusrtip
      ,atdsegempcod           like datmatdtrn.atdsegempcod
      ,trncapdat              like datmatdtrn.trncapdat
      ,trncaphor              like datmatdtrn.trncaphor
      ,c24astcod              like datmligacao.c24astcod
      ,c24astdes              like datkassunto.c24astdes
      ,ramcod                 like datmatd6523.ramcod ##globais de datmatd6523
      ,succod                 like datmatd6523.succod
      ,aplnumdig              like datmatd6523.aplnumdig
      ,solnom                 like datmatd6523.solnom
      ,itmnumdig              like datmatd6523.itmnumdig
end record

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

#------------------------------------------------------------------------------#
function cta02m22_prepare()
#------------------------------------------------------------------------------#

   define l_sql  char(2000)
         ,l_ok   smallint

   let l_ok = true

   whenever error continue
      create temp table temp_cta02m22
             (ligdat   date
             ,lighor   datetime hour to minute
             ,seqhist  decimal(3,0)
             ,funmat   decimal(6,0)
             ,descrhist char(70)
             ,c24empcod smallint) with no log
   whenever error stop

   if sqlca.sqlcode != 0 then
      if sqlca.sqlcode = -310 or
         sqlca.sqlcode = -958 then
         delete from temp_cta02m22
      else
         error "ERRO CreateTempTable temp_cta02m22 -> ",sqlca.sqlcode
         let l_ok = false
      end if
   else
      create index temp_cta02m22_idx
      on temp_cta02m22 (ligdat, lighor, seqhist)
                  MESSAGE "" # By Robi
   end if

   let l_sql = ' update datmatdtrn '
                 ,' set atdsegpanum  = ? '
                    ,' ,atdsegdptsgl = ? '
                    ,' ,atdsegfunmat = ? '
                    ,' ,atdsegusrtip = ? '
                    ,' ,atdsegempcod = ? '
                    ,' ,trncapdat = ?'
                    ,' ,trncaphor = ? '
               ,' where atdnum = ? '
                 ,' and atdtrnnum = ? '

   prepare p_cta02m22_001 from l_sql

   let l_sql = 'select ramcod '
                   ,' ,sinano '
                   ,' ,sinnum '
                   ,' ,sinitmseq '
                   ,' ,sintfacod '
               ,' from datrligsin '
              ,' where lignum = ? '

   prepare p_cta02m22_002 from l_sql
   declare c_cta02m22_001 cursor for p_cta02m22_002

   let l_sql = 'select ligdat '
                   ,' ,lighorinc '
                   ,' ,c24txtseq '
                   ,' ,c24funmat '
                   ,' ,c24ligdsc '
                   ,' ,c24empcod '
               ,' from datmlighist '
              ,' where lignum = ? '

   prepare p_cta02m22_003 from l_sql
   declare c_cta02m22_002 cursor for p_cta02m22_003

   let l_sql = ' insert into temp_cta02m22 '
                    ,' (ligdat '
                    ,' ,lighor '
                    ,' ,seqhist '
                    ,' ,funmat '
                    ,' ,descrhist '
                    ,' ,c24empcod) '
               ,' values (?,?,?,?,?,?) '

   prepare p_cta02m22_004 from l_sql

   let l_sql = 'select nsinum '
               ,' from sinrnsipnd '
              ,' where ramcod    = ? '
                ,' and sinano    = ? '
                ,' and sinnum    = ? '
                ,' and sinitmseq = ? '
                ,' and sintfacod = ? '

   prepare p_cta02m22_005 from l_sql
   declare c_cta02m22_003 cursor for p_cta02m22_005

   let l_sql = 'select funmat '
                   ,' ,caddat '
                   ,' ,cadhor '
               ,' from sinknota '
              ,' where ramcod    = ? '
                ,' and sinano    = ? '
                ,' and sinnum    = ? '
                ,' and sinitmseq = ? '
                ,' and nsinum    = ? '

   prepare p_cta02m22_006 from l_sql
   declare c_cta02m22_004 cursor for p_cta02m22_006

   let l_sql = 'select lsiseq '
                   ,' ,lsides '
               ,' from sinmlinhanota '
              ,' where ramcod    = ? '
                ,' and sinano    = ? '
                ,' and sinnum    = ? '
                ,' and sinitmseq = ? '
                ,' and nsinum    = ? '

   prepare p_cta02m22_007 from l_sql
   declare c_cta02m22_005 cursor for p_cta02m22_007

   let l_sql = 'select ligdat '
                   ,' ,lighor '
                   ,' ,seqhist '
                   ,' ,funmat '
                   ,' ,descrhist '
                   ,' ,c24empcod '
               ,' from temp_cta02m22 '
           ,' order by ligdat, lighor, seqhist '

   prepare p_cta02m22_008 from l_sql
   declare c_cta02m22_006 cursor for p_cta02m22_008

   let l_sql = 'select c24empcod '
                    ,' ,atdsrvnum '
                    ,' ,c24astcod '
               ,' from datmligacao '
              ,' where lignum    = ? '

   prepare p_cta02m22_009 from l_sql
   declare c_cta02m22_007 cursor for p_cta02m22_009

   let l_sql = 'select funnom '
                   ,' ,dptsgl '
               ,' from isskfunc '
              ,' where empcod = ? '
                ,' and funmat = ? '

   prepare p_cta02m22_010 from l_sql
   declare c_cta02m22_008 cursor for p_cta02m22_010

   let l_sql = 'select ligdat '
                   ,' ,lighorinc '
                   ,' ,c24txtseq '
                   ,' ,c24funmat '
                   ,' ,c24srvdsc '
                   ,' ,c24empcod '
               ,' from datmservhist '
              ,' where atdsrvnum = ? '

   prepare p_cta02m22_011 from l_sql
   declare c_cta02m22_009 cursor for p_cta02m22_011

   let m_prep_sql = true

   return l_ok

end function

#------------------------------------------------------------------------------#
function cta02m22()
#------------------------------------------------------------------------------#

   -->  Endereco do Local de Risco - RE
   define l_aux        record
          lclrsccod    like rlaklocal.lclrsccod
         ,lclnumseq    like datmsrvre.lclnumseq
         ,rmerscseq    like datmsrvre.rmerscseq
         ,rmeblcdes    like rsdmbloco.rmeblcdes
         ,sgrorg       like rsamseguro.sgrorg
         ,sgrnumdig    like rsamseguro.sgrnumdig
         ,edsnumdig    like rsdmdocto.edsnumdig
   end record


   define l_retorno   char(03)
         ,l_ok        smallint
         ,l_c24astcod like datmligacao.c24astcod
         ,l_c24empcod like datmligacao.c24empcod
         ,l_atdsrvnum like datmligacao.atdsrvnum
         ,l_resultado smallint
         ,l_mensagem  char(60)
         ,l_ramgrpcod like gtakram.ramgrpcod


   let l_resultado = null
   let l_mensagem  = null
   let l_ramgrpcod = null
   let l_retorno   = null

   initialize mr_cta02m22a.*   to null
   initialize mr_cta02m22.*    to null
   initialize mr_documento.*   to null
   initialize m_flg_assunto    to null
   initialize lr_ppt.*         to null
   initialize l_aux.*          to null

   let m_flg_assunto = "N"

   if m_prep_sql is null or
      m_prep_sql <> true then
      let l_ok = cta02m22_prepare()

      if l_ok = false then
         return
      end if
   end if

   ########### Entra com atendimento
   open window cta02m22 at 03,02 with form "cta02m22"
               attribute (form line first)

   let int_flag   = false

   while TRUE

      input by name mr_cta02m22a.atdnum without defaults

         before field atdnum
            display by name mr_cta02m22a.atdnum attribute (reverse)

         after  field atdnum
            display by name mr_cta02m22a.atdnum

            if mr_cta02m22a.atdnum is null then
               error " Informe o Numero de Atendimento. "
               next field atdnum
            end if


            if mr_cta02m22a.atdnum = 0 then
               error " Numero de Atendimento invalido. "
               next field atdnum
            end if

            ---> Se informou Nro.Atendimento
            if mr_cta02m22a.atdnum is not null and
               mr_cta02m22a.atdnum <> 0        then

               ---> Verifica se existe o Atendimento Informado
               call ctd24g00_valida_atd(mr_cta02m22a.atdnum
                                       ,""  --> ciaempcod
                                       ,5 ) --> tp retorno dos parametros
               returning mr_cta02m22a.resultado
                        ,mr_cta02m22a.mensagem
                        ,g_documento.ciaempcod

               if mr_cta02m22a.resultado <> 1 then
                  error mr_cta02m22a.mensagem
                  next field atdnum
               end if
            end if

            # carregar as globais
            call ctd24g00_valida_atd(mr_cta02m22a.atdnum
                                    ,g_documento.ciaempcod
                                    ,3 )
            returning  mr_cta02m22.resultado
                      ,mr_cta02m22.mensagem
                      ,mr_cta02m22.ciaempcod
                      ,mr_cta02m22.solnom
                      ,mr_cta02m22.flgavstransp
                      ,mr_cta02m22.c24soltipcod
                      ,mr_cta02m22.ramcod
                      ,mr_cta02m22.flgcar
                      ,mr_cta02m22.vcllicnum
                      ,mr_cta02m22.corsus
                      ,mr_cta02m22.succod
                      ,mr_cta02m22.aplnumdig
                      ,mr_cta02m22.itmnumdig
                      ,mr_cta02m22.etpctrnum
                      ,mr_cta02m22.segnom
                      ,mr_cta02m22.pestip
                      ,mr_cta02m22.cgccpfnum
                      ,mr_cta02m22.cgcord
                      ,mr_cta02m22.cgccpfdig
                      ,mr_cta02m22.prporg
                      ,mr_cta02m22.prpnumdig
                      ,mr_cta02m22.flgvp
                      ,mr_cta02m22.vstnumdig
                      ,mr_cta02m22.vstdnumdig
                      ,mr_cta02m22.flgvd
                      ,mr_cta02m22.flgcp
                      ,mr_cta02m22.cpbnum
                      ,mr_cta02m22.semdcto
                      ,mr_cta02m22.ies_ppt
                      ,mr_cta02m22.ies_pss
                      ,mr_cta02m22.transp
                      ,mr_cta02m22.trpavbnum
                      ,mr_cta02m22.vclchsfnl
                      ,mr_cta02m22.sinramcod
                      ,mr_cta02m22.sinnum
                      ,mr_cta02m22.sinano
                      ,mr_cta02m22.sinvstnum
                      ,mr_cta02m22.sinvstano
                      ,mr_cta02m22.flgauto
                      ,mr_cta02m22.sinautnum
                      ,mr_cta02m22.sinautano
                      ,mr_cta02m22.flgre
                      ,mr_cta02m22.sinrenum
                      ,mr_cta02m22.sinreano
                      ,mr_cta02m22.flgavs
                      ,mr_cta02m22.sinavsnum
                      ,mr_cta02m22.sinavsano
                      ,mr_cta02m22.semdoctoempcodatd
                      ,mr_cta02m22.semdoctopestip
                      ,mr_cta02m22.semdoctocgccpfnum
                      ,mr_cta02m22.semdoctocgcord
                      ,mr_cta02m22.semdoctocgccpfdig
                      ,mr_cta02m22.semdoctocorsus
                      ,mr_cta02m22.semdoctofunmat
                      ,mr_cta02m22.semdoctoempcod
                      ,mr_cta02m22.semdoctodddcod
                      ,mr_cta02m22.semdoctoctttel
                      ,mr_cta02m22.funmat
                      ,mr_cta02m22.empcod
                      ,mr_cta02m22.usrtip
                      ,mr_cta02m22.caddat
                      ,mr_cta02m22.cadhor
                      ,mr_cta02m22.ligcvntip


            let mr_cta02m22a.resultado = mr_cta02m22.resultado

            if mr_cta02m22a.resultado  <> 1 then
               error mr_cta02m22a.mensagem
               next field atdnum
            end if

            ## busca a data/hora
            call cts40g03_data_hora_banco(1)
               returning mr_cta02m22.caddat
                        ,mr_cta02m22.cadhor

            let mr_cta02m22a.ramcod    = mr_cta02m22.ramcod
            let mr_cta02m22a.succod    = mr_cta02m22.succod
            let mr_cta02m22a.aplnumdig = mr_cta02m22.aplnumdig
            let mr_cta02m22a.solnom    = mr_cta02m22.solnom
            let mr_cta02m22a.itmnumdig = mr_cta02m22.itmnumdig

            ---> Consulta de Atendimento foi Transferido
            call ctd02g02( mr_cta02m22a.atdnum )
            returning mr_cta02m22a.resultado
                     ,mr_cta02m22a.mensagem
                     ,mr_cta02m22a.atdnum
                     ,mr_cta02m22a.atdtrnnum
                     ,mr_cta02m22a.trnlignum
                     ,mr_cta02m22a.necgerlignum
                     ,mr_cta02m22a.atdpripanum
                     ,mr_cta02m22a.atdpridptsgl
                     ,mr_cta02m22a.atdprifunmat
                     ,mr_cta02m22a.atdpriusrtip
                     ,mr_cta02m22a.atdpriempcod
                     ,mr_cta02m22a.trndat
                     ,mr_cta02m22a.trnhor
                     ,mr_cta02m22a.atdsegpanum
                     ,mr_cta02m22a.atdsegdptsgl
                     ,mr_cta02m22a.atdsegfunmat
                     ,mr_cta02m22a.atdsegusrtip
                     ,mr_cta02m22a.atdsegempcod
                     ,mr_cta02m22a.trncapdat
                     ,mr_cta02m22a.trncaphor
                     ,mr_cta02m22a.c24astcod

            if mr_cta02m22a.resultado = 2 then
               error mr_cta02m22a.mensagem
               next field atdnum
            end if

            initialize l_c24empcod, l_atdsrvnum, l_c24astcod to null

            ---> Seleciona Assunto da Ligacao
            open c_cta02m22_007 using mr_cta02m22a.necgerlignum
            whenever error continue
            fetch c_cta02m22_007 into l_c24empcod
                                     ,l_atdsrvnum
                                     ,l_c24astcod
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  error 'Erro SELECT c_cta02m22_007 / ', sqlca.sqlcode, ' / '
                        , sqlca.sqlerrd[2] sleep 3
                  error 'cta02m22 / cta02m22() / '
                        ,mr_cta02m22a.necgerlignum  sleep 3
                  let l_ok = false
               end if
            end if


            ### busca a descricao do atendimento
            call c24geral8(l_c24astcod)
                 returning mr_cta02m22a.c24astdes


            if mr_cta02m22a.c24astcod = "HDT" then
               initialize g_rsc_re.lclrsccod    to null
               initialize g_documento.crtsaunum to null
            end if


            #----------------------------------------
            ---> Verifica a que grupo o Ramo pertence
            #----------------------------------------
            if mr_cta02m22a.ramcod is not null  and
               mr_cta02m22a.ramcod <> 0         then

               call cty10g00_grupo_ramo(mr_cta02m22.ciaempcod
                                       ,mr_cta02m22a.ramcod)
                              returning l_resultado
                                       ,l_mensagem
                                       ,l_ramgrpcod

               #--------
	       ---> AUTO
               #--------
               if l_ramgrpcod = 1 then ---> Auto

                  #------------------------------
	          ---> Ultima Situacao da Apolice
                  #------------------------------
                  call f_funapol_ultima_situacao(mr_cta02m22a.succod
                                                ,mr_cta02m22a.aplnumdig
                                                ,mr_cta02m22a.itmnumdig)
                                       returning g_funapol.*

                  if g_funapol.dctnumseq is null  then

                     select min(dctnumseq)
                       into g_funapol.dctnumseq
                       from abbmdoc
                      where succod    = mr_cta02m22a.succod
                        and aplnumdig = mr_cta02m22a.aplnumdig
                        and itmnumdig = mr_cta02m22a.itmnumdig
                  end if

                  #------------------
                  ---> Busca Segurado
                  #------------------
                  select segnumdig
                    into g_ppt.segnumdig
                    from abbmdoc a
                   where a.succod    = mr_cta02m22a.succod
                     and a.aplnumdig = mr_cta02m22a.aplnumdig
                     and a.itmnumdig = mr_cta02m22a.itmnumdig
                     and a.dctnumseq = g_funapol.dctnumseq


                  #---------------------------
                  ---> Busca dados do Corretor
                  #---------------------------
                  select corsus
                    into g_documento.corsus
                    from abamcor a
                   where a.succod    = mr_cta02m22a.succod
                     and a.aplnumdig = mr_cta02m22a.aplnumdig
                     and a.corlidflg = "S"
               end if



               #--------
	       ---> R.E.
               #--------
               if l_ramgrpcod = 4 then ---> RE

                  #---------------------------
                  ---> Busca Proposta Original
                  #---------------------------
                  select sgrorg
                        ,sgrnumdig
                    into l_aux.sgrorg
                        ,l_aux.sgrnumdig
                    from rsamseguro
                   where succod    = mr_cta02m22a.succod
                     and ramcod    = mr_cta02m22a.ramcod
                     and aplnumdig = mr_cta02m22a.aplnumdig



                  #------------------
                  ---> Busca Segurado
                  #------------------
                  select segnumdig
                        ,dctnumseq
                        ,edsnumdig
                    into g_ppt.segnumdig
                        ,g_funapol.dctnumseq
                        ,g_documento.edsnumref
                    from rsdmdocto
                   where sgrorg    = l_aux.sgrorg
                     and sgrnumdig = l_aux.sgrnumdig
                     and dctnumseq = (select max(dctnumseq)
                                        from rsdmdocto
                                       where sgrorg     = l_aux.sgrorg
                                         and sgrnumdig  = l_aux.sgrnumdig
                                         and prpstt     in (19,65,66,88))

                  #---------------------------
                  ---> Busca dados do Corretor
                  #---------------------------
                  select corsus
                    into g_documento.corsus
                    from rsampcorre a
                   where a.sgrorg    = l_aux.sgrorg
                     and a.sgrnumdig = l_aux.sgrnumdig
                     and a.corlidflg = "S"

               end if


               --> Se for Ramo do RE Resgata Local de Risco / Bloco
               if l_ramgrpcod            = 4          and  ---> RE
                  mr_cta02m22a.ramcod    is not null  and
                  mr_cta02m22a.ramcod    <> 0         and
                  mr_cta02m22a.aplnumdig is not null  and
                  mr_cta02m22a.aplnumdig <> 0         then


                  initialize g_documento.lclnumseq
                            ,g_documento.rmerscseq to null

                  ---> Recuperar Local de Risco
                  select lclrsccod
                    into l_aux.lclrsccod
                    from datrligsrv a
                        ,datmsrvre  b
                   where a.lignum    = mr_cta02m22a.trnlignum
                     and a.atdsrvnum = b.atdsrvnum
                     and a.atdsrvano = b.atdsrvano


                  if l_aux.lclrsccod is null or
                     l_aux.lclrsccod =  0    then

                     ---> O Local de Risco so fica gravado quando gera o Servico
                     ---> no caso do Help Desk nao tenho ainda o servico gerado
                     call framc215(mr_cta02m22a.succod
	                                ,mr_cta02m22a.ramcod
			                            ,mr_cta02m22a.aplnumdig)
                         returning l_resultado
	                                ,l_mensagem
                                  ,l_aux.lclrsccod
                                  ,g_rsc_re.lgdtip
                                  ,g_rsc_re.lgdnom
                                  ,g_rsc_re.lgdnum
                                  ,g_rsc_re.lclbrrnom
                                  ,g_rsc_re.cidnom
                                  ,g_rsc_re.ufdcod
                                  ,g_rsc_re.lgdcep
                                  ,g_rsc_re.lgdcepcmp
                                  ,l_aux.lclnumseq
                                  ,l_aux.rmerscseq
                                  ,l_aux.rmeblcdes
                                  ,g_rsc_re.lclltt
                                  ,g_rsc_re.lcllgt

                     if l_aux.lclrsccod is null or
                        l_aux.lclrsccod =  0    then
                        error " Local de Risco nao Localizado. "
                     else
                        let g_rsc_re.lclrsccod = l_aux.lclrsccod
                     end if
                  else
                     let g_rsc_re.lclrsccod = l_aux.lclrsccod
                  end if


                  ---> Recuperar Seq. Local de Risco / Bloco
                  select lclnumseq
                        ,rmerscseq
                    into g_documento.lclnumseq
                        ,g_documento.rmerscseq
                    from datmrsclcllig
                   where lignum = mr_cta02m22a.trnlignum

               end if
            end if


            display by name mr_cta02m22a.atdnum
            display by name mr_cta02m22a.succod
            display by name mr_cta02m22a.ramcod
            display by name mr_cta02m22a.aplnumdig
            display by name mr_cta02m22a.itmnumdig
            display by name mr_cta02m22a.solnom

            ## historico da transferencia

            call cta02m22_historico(mr_cta02m22a.trnlignum,'LI1',1)
            returning l_retorno
                     ,l_ok


            # busca o historico da transferencia
            # Verifica se a ligacao foi registrada
            if l_retorno <> "SAI" then
               if mr_cta02m22a.atdsegfunmat is null then

                  let mr_cta02m22a.c24astcod = l_c24astcod
                  display by name mr_cta02m22a.c24astcod
                  display by name mr_cta02m22a.c24astdes
                  display by name mr_cta02m22a.necgerlignum

                  while l_retorno <> "SAI"

                     if l_retorno = "LIG" then
                        call cta02m22_historico(mr_cta02m22a.trnlignum,'LIG',2)
                             returning l_retorno
                                      ,l_ok
                     else
                        if l_retorno = "TRN" then
                           if l_atdsrvnum is not null then
                              call cta02m22_historico(l_atdsrvnum,'SRV',2)
                                   returning l_retorno
                                            ,l_ok
                           else
                              call cta02m22_historico(mr_cta02m22a.necgerlignum,'TRN',2)
                                 returning l_retorno
                                          ,l_ok
                           end if
                        end if
                     end if
                  end while
               else
                  error ' A ligacao esta sendo atendida por : '
                        , mr_cta02m22a.atdsegfunmat
                  next field atdnum
               end if
            end if
            if m_flg_assunto = "S" then
               let int_flag = true
               exit input
            else
               clear form
               next field atdnum
            end if


         on key(control-c,interrupt)
            let int_flag = true
            exit input

      end input

      if int_flag = true then
         exit while
      end if

   end while

   close window cta02m22

   let int_flag = false

   whenever error continue
      delete from temp_cta02m22
   whenever error stop

   if sqlca.sqlcode <> 0 then
      error "Erro DropTable - temp_cta02m22 -> ",sqlca.sqlcode
   end if

end function

#------------------------------------------------------------------------------#
 function cta02m22_historico(lr_cta02m22)
#------------------------------------------------------------------------------#

 define lr_cta02m22 record
        lignum      like datmlighist.lignum
       ,sit         char(03)
       ,controle    smallint
 end record

 define lr_hist         record
        ligdat          like datmlighist.ligdat
       ,lighor          like datmlighist.lighorinc
       ,c24txtseq       like datmlighist.c24txtseq
       ,c24funmat       like datmlighist.c24funmat
       ,descr_hist      like datmlighist.c24ligdsc
       ,c24empcod       like datmlighist.c24empcod
 end record

 define l_ramcod    like datrligsin.ramcod
       ,l_sinano    like sinrnsipnd.sinano
       ,l_sinnum    like datrligsin.sinnum
       ,l_sinitmseq like datrligsin.sinitmseq
       ,l_sintfacod like datrligsin.sintfacod
       ,l_nsinum    like sinrnsipnd.nsinum
       ,l_funmat    like sinknota.funmat
       ,l_caddat    like sinknota.caddat
       ,l_cadhor    like sinknota.cadhor
       ,l_lsiseq    like sinmlinhanota.lsiseq
       ,l_lsides    like sinmlinhanota.lsides
       ,l_retorno   char(03)

   define l_ok      smallint
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

   let l_ramcod     =  null
   let l_sinano     =  null
   let l_sinnum     =  null
   let l_sinitmseq  =  null
   let l_sintfacod  =  null
   let l_nsinum     =  null
   let l_funmat     =  null
   let l_caddat     =  null
   let l_cadhor     =  null
   let l_lsiseq     =  null
   let l_lsides     =  null
   let m_lignum     = null

   initialize  lr_hist.*  to  null

   let l_ramcod     =  null
   let l_sinano     =  null
   let l_sinnum     =  null
   let l_sinitmseq  =  null
   let l_sintfacod  =  null
   let l_nsinum     =  null
   let l_funmat     =  null
   let l_caddat     =  null
   let l_cadhor     =  null
   let l_lsiseq     =  null
   let l_lsides     =  null

   initialize  lr_hist.*  to  null

   let l_ok = true
   let m_lignum = lr_cta02m22.lignum

   if lr_cta02m22.sit = 'SRV' then
      open c_cta02m22_009 using lr_cta02m22.lignum
      foreach c_cta02m22_009 into lr_hist.ligdat
                               ,lr_hist.lighor
                               ,lr_hist.c24txtseq
                               ,lr_hist.c24funmat
                               ,lr_hist.descr_hist
                               ,lr_hist.c24empcod

         whenever error continue
         execute p_cta02m22_004 using lr_hist.ligdat
                                   ,lr_hist.lighor
                                   ,lr_hist.c24txtseq
                                   ,lr_hist.c24funmat
                                   ,lr_hist.descr_hist
                                   ,lr_hist.c24empcod
         whenever error stop
         if sqlca.sqlcode <> 0 then
            error "Erro de insert na tabela temporaria: " ,sqlca.sqlcode sleep 3
            let l_ok = false
            exit foreach
         end if

      end foreach
   else
      open c_cta02m22_002 using lr_cta02m22.lignum
      foreach c_cta02m22_002 into lr_hist.ligdat
                               ,lr_hist.lighor
                               ,lr_hist.c24txtseq
                               ,lr_hist.c24funmat
                               ,lr_hist.descr_hist
                               ,lr_hist.c24empcod

         whenever error continue
         execute p_cta02m22_004 using lr_hist.ligdat
                                   ,lr_hist.lighor
                                   ,lr_hist.c24txtseq
                                   ,lr_hist.c24funmat
                                   ,lr_hist.descr_hist
                                   ,lr_hist.c24empcod
         whenever error stop
         if sqlca.sqlcode <> 0 then
            error "Erro de insert na tabela temporaria: " ,sqlca.sqlcode sleep 3
            let l_ok = false
            exit foreach
         end if

      end foreach
   end if

   open c_cta02m22_001 using lr_cta02m22.lignum
   whenever error continue
   fetch c_cta02m22_001 into l_ramcod
                          ,l_sinano
                          ,l_sinnum
                          ,l_sinitmseq
                          ,l_sintfacod

   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode <> notfound then
         error 'Erro SELECT c_cta02m22_001 / ', sqlca.sqlcode, ' / '
              , sqlca.sqlerrd[2] sleep 3
         error 'cta02m22 / cta02m22_historico() / ',lr_cta02m22.lignum sleep 3
         let l_ok = false
      end if
   end if

   if l_sintfacod is not null then

      open c_cta02m22_003 using l_ramcod
                             ,l_sinano
                             ,l_sinnum
                             ,l_sinitmseq
                             ,l_sintfacod
      foreach c_cta02m22_003 into l_nsinum

         open c_cta02m22_004 using l_ramcod
                                ,l_sinano
                                ,l_sinnum
                                ,l_sinitmseq
                                ,l_nsinum

         whenever error continue
         fetch c_cta02m22_004 into l_funmat
                                ,l_caddat
                                ,l_cadhor

         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode <> notfound then
               error 'Erro SELECT c_cta02m22_004 / ', sqlca.sqlcode, ' / '
                   , sqlca.sqlerrd[2] sleep 3
               error 'cta02m22 / cta02m22_historico() / '
                     ,lr_cta02m22.lignum sleep 2
               let l_ok = false
            end if
         end if

         open c_cta02m22_005 using l_ramcod
                                ,l_sinano
                                ,l_sinnum
                                ,l_sinitmseq
                                ,l_nsinum

         foreach c_cta02m22_005 into l_lsiseq
                                  ,l_lsides

            if sqlca.sqlcode = 0 then

               if l_lsides[1] = "*" then
                  continue foreach
               end if

               let lr_hist.c24empcod = null
               whenever error continue
               execute p_cta02m22_004 using l_caddat
                                         ,l_cadhor
                                         ,l_lsiseq
                                         ,l_funmat
                                         ,l_lsides
                                         ,lr_hist.c24empcod
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  error "Erro de insert na tabela temporaria: "
                        ,sqlca.sqlcode  sleep 3
                  let l_ok = false
                  exit foreach
               end if
            end if
         end foreach

         if l_ok = false then
            exit foreach
         end if

      end foreach

   end if

   let l_retorno = cta02m22_f_carrega(lr_cta02m22.*)

   whenever error continue
      delete from temp_cta02m22
   whenever error stop

   if sqlca.sqlcode <> 0 then
      error "Erro DropTable - temp_cta02m22 -> ",sqlca.sqlcode
   end if


   return l_retorno
         ,l_ok

end function  ###  cta02m22

#------------------------------------------------------------------------------#
 function cta02m22_f_carrega(lr_cta02m22)
#------------------------------------------------------------------------------#

   define lr_cta02m22  record
          lignum       like datmlighist.lignum
         ,sit          char(03)
         ,controle     smallint
   end record

   define lr_dados    record
          ligdat      like datmlighist.ligdat
         ,lighor      like datmlighist.lighorinc
         ,seqhist     like datmlighist.c24txtseq
         ,funmat      like datmlighist.c24funmat
         ,descrhist   like datmlighist.c24ligdsc
         ,ligdatant   like datmlighist.ligdat
         ,lighorant   like datmlighist.lighorinc
         ,funmatant   like isskfunc.funmat
         ,funnom      like isskfunc.funnom
         ,dptsgl      like isskfunc.dptsgl
         ,privez      smallint
         ,prpflg      char(1)
         ,c24empcod   smallint
   end record

   define ar_cta02m22 array[300] of record
          descr_hist  like datmlighist.c24ligdsc
   end record

   define ar_cta02m22a array[300] of record
          c24ligdsc    like datmlighist.c24ligdsc
   end record

   define l_retorno   char(03)
         ,l_ok        smallint
         ,l_atdsrvnum like datmligacao.atdsrvnum
         ,l_c24astcod like datmligacao.c24astcod
         ,l_i         smallint

   define arr_aux    smallint
   define scr_aux    smallint


   define  l_pf    integer

   define l_confirma char(01)
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


   define  l_pf1   integer

   let arr_aux  =  null
   let scr_aux  =  null
   let l_pf     =  null

   let l_confirma = null

   for l_pf1  =  1  to  300
       initialize  ar_cta02m22[l_pf1].*  to  null
       initialize  ar_cta02m22a[l_pf1].*  to  null
   end for

   initialize  lr_dados.*  to  null

   let arr_aux  =  null
   let scr_aux  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

   for l_pf =  1  to  300
       initialize  ar_cta02m22[l_pf].*  to  null
       initialize  ar_cta02m22a[l_pf].*  to  null
   end for

   initialize lr_dados.* to null

   let arr_aux      = 1
   let lr_dados.privez    = true

   let lr_dados.ligdatant = "31/12/1899"
   let lr_dados.lighorant = "00:00"
   let lr_dados.funmatant = 999999

   initialize ar_cta02m22  to null
   initialize ar_cta02m22a  to null

   open c_cta02m22_006
   foreach c_cta02m22_006 into lr_dados.ligdat
                            ,lr_dados.lighor
                            ,lr_dados.seqhist
                            ,lr_dados.funmat
                            ,lr_dados.descrhist
                            ,lr_dados.c24empcod

      if lr_dados.ligdatant <> lr_dados.ligdat or
         lr_dados.lighorant <> lr_dados.lighor or
         lr_dados.funmatant <> lr_dados.funmat then

         if lr_dados.privez  =  true  then
            let lr_dados.privez = false
         else
            let arr_aux = arr_aux + 2
         end if

         if lr_dados.c24empcod is null then

            open c_cta02m22_007 using m_lignum
            whenever error continue
            fetch c_cta02m22_007 into lr_dados.c24empcod
                                   ,l_atdsrvnum
                                   ,l_c24astcod
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode <> notfound then
                  error 'Erro SELECT c_cta02m22_007 / ', sqlca.sqlcode, ' / '
                       , sqlca.sqlerrd[2] sleep 3
                  error 'cta02m22 / cta02m22_f_carrega() / ',m_lignum sleep 3
                  let l_ok = false
               end if
            end if

         end if

         open c_cta02m22_008 using lr_dados.c24empcod
                                ,lr_dados.funmat
         whenever error continue
         fetch c_cta02m22_008 into lr_dados.funnom
                                ,lr_dados.dptsgl
         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode <> notfound then
               error 'Erro SELECT c_cta02m22_008 / ', sqlca.sqlcode, ' / '
                    , sqlca.sqlerrd[2] sleep 3
               error 'cta02m22 / cta02m22_f_carrega() / ',m_lignum sleep 3
               let l_ok = false
            end if
         end if

         ## Portal WEB
         if  lr_dados.funmat = 999999 or
             lr_dados.funmat = 0 then
             if lr_cta02m22.sit = "LIG" or
                lr_cta02m22.sit = "LI1" then
                let ar_cta02m22[arr_aux].descr_hist =
                       "Em: ",  lr_dados.ligdat clipped, "  ",
                       "As: ",  lr_dados.lighor clipped, "  ",
                       "Por: PORTAL-WEB"
             else
                let ar_cta02m22a[arr_aux].c24ligdsc =
                       "Em: ",  lr_dados.ligdat clipped, "  ",
                       "As: ",  lr_dados.lighor clipped, "  ",
                       "Por: PORTAL-WEB"
             end if
         else
             if lr_cta02m22.sit = "LIG" or
                lr_cta02m22.sit = "LI1" then
                let ar_cta02m22[arr_aux].descr_hist =
                       "Em: ",  lr_dados.ligdat clipped, "  ",
                       "As: ",  lr_dados.lighor clipped, "  ",
                       "Por: ", upshift(lr_dados.funnom clipped)," - ",lr_dados.dptsgl
             else
                let ar_cta02m22a[arr_aux].c24ligdsc =
                       "Em: ",  lr_dados.ligdat clipped, "  ",
                       "As: ",  lr_dados.lighor clipped, "  ",
                       "Por: ", upshift(lr_dados.funnom clipped)," - ",lr_dados.dptsgl

             end if
         end if
         let lr_dados.ligdatant = lr_dados.ligdat
         let lr_dados.lighorant = lr_dados.lighor
         let lr_dados.funmatant = lr_dados.funmat
         let arr_aux      = arr_aux + 1
      end if

      let arr_aux = arr_aux + 1

      if lr_cta02m22.sit = "LIG" or
         lr_cta02m22.sit = "LI1" then
         let ar_cta02m22[arr_aux].descr_hist = lr_dados.descrhist
      else
         let ar_cta02m22a[arr_aux].c24ligdsc = lr_dados.descrhist
      end if

      if arr_aux > 300  then
         error " Limite excedido, historico com mais de 300 linhas. AVISE A INFORMATICA!"
         sleep 5
         exit foreach
      end if

   end foreach

   if arr_aux  >  1  then

      if lr_cta02m22.sit = "LI1" then
         call set_count(arr_aux)
         for l_i = 1 to 5
             display ar_cta02m22[l_i].descr_hist to s_cta02m22[l_i].*
         end for

        let l_retorno = "TRN"
      else
         if lr_cta02m22.sit = "LIG" then
            call set_count(arr_aux)
            display array ar_cta02m22 to s_cta02m22.*
              on key(control-c,interrupt)
                 let l_retorno = "SAI"
                 exit display
               on key (F1)
                  let l_confirma = cts08g01('A','S', '' ,"CONFIRMA TRANSFERENCIA ?", '', '')
                  if l_confirma = 'N' then
                     exit display
                  end if
                  if mr_cta02m22a.atdsegfunmat is null then
                     let mr_cta02m22a.trncapdat = today
                     let mr_cta02m22a.trncaphor = current
                     whenever error continue
                     execute p_cta02m22_001 using mr_cta02m22a.atdsegpanum   ## verificar as globais origens
                                               ,g_issk.dptsgl
                                               ,g_issk.funmat
                                               ,g_issk.usrtip
                                               ,g_issk.empcod
                                               ,mr_cta02m22a.trncapdat
                                               ,mr_cta02m22a.trncaphor
                                               ,mr_cta02m22a.atdnum
                                               ,mr_cta02m22a.atdtrnnum
                     whenever error stop
                     if sqlca.sqlcode <> 0 then
                        error "Erro na alteracao de datmatdtrn: "
                              ,sqlca.sqlcode  sleep 3
                        let int_flag = true
                        exit display
                     else
                        error " Ligacao travada "
                     end if

                     let mr_documento.ligcvntip    = mr_cta02m22.ligcvntip
                     let mr_documento.succod       = mr_cta02m22.succod
                     let mr_documento.aplnumdig    = mr_cta02m22.aplnumdig
                     let mr_documento.itmnumdig    = mr_cta02m22.itmnumdig
                     let mr_documento.prporg       = mr_cta02m22.prporg
                     let mr_documento.prpnumdig    = mr_cta02m22.prpnumdig
                     let mr_documento.solnom       = mr_cta02m22.solnom
                     let mr_documento.c24soltipcod = mr_cta02m22.c24soltipcod
                     let mr_documento.ramcod       = mr_cta02m22.ramcod
                     let mr_documento.sinramcod    = mr_cta02m22.sinramcod
                     let mr_documento.sinano       = mr_cta02m22.sinnum
                     let mr_documento.sinnum       = mr_cta02m22.sinano
                     let mr_documento.vstnumdig    = mr_cta02m22.vstnumdig
                     let mr_documento.dddcod       = mr_cta02m22.semdoctodddcod
                     let mr_documento.ctttel       = mr_cta02m22.semdoctoctttel
                     let mr_documento.funmat       = mr_cta02m22.funmat
                     let mr_documento.cgccpfnum    = mr_cta02m22.cgccpfnum
                     let mr_documento.cgcord       = mr_cta02m22.cgcord
                     let mr_documento.cgccpfdig    = mr_cta02m22.cgccpfdig
                     let mr_documento.corsus       = mr_cta02m22.corsus
                     let g_documento.ligcvntip     = mr_documento.ligcvntip
                     let g_documento.c24soltipcod  = mr_documento.c24soltipcod
                     let g_documento.solnom        = mr_documento.solnom
                     let g_documento.succod        = mr_documento.succod
                     let g_documento.ramcod        = mr_documento.sinramcod
                     let g_documento.aplnumdig     = mr_documento.aplnumdig
                     let g_documento.itmnumdig     = mr_documento.itmnumdig
                     let g_documento.prporg        = mr_documento.prporg
                     let g_documento.prpnumdig     = mr_documento.prpnumdig
                     let g_documento.sinramcod     = mr_documento.sinramcod
                     let g_documento.sinano        = mr_documento.sinano
                     let g_documento.sinnum        = mr_documento.sinnum

                     if mr_cta02m22.semdcto = "S" then
                        let mr_documento.corsus    = mr_cta02m22.semdoctocorsus
                        let mr_documento.cgccpfnum = mr_cta02m22.semdoctocgccpfnum
                        let mr_documento.cgcord    = mr_cta02m22.semdoctocgcord
                        let mr_documento.cgccpfdig = mr_cta02m22.semdoctocgccpfdig
                        let mr_documento.funmat    = mr_cta02m22.semdoctofunmat
                        let g_documento.funmat     = mr_cta02m22.semdoctofunmat
                        let g_documento.empcodmat  = mr_cta02m22.semdoctoempcod
                     end if

                     -->P/ nao gerar outro Nro.Atendimento da tela de Assunto
                     let g_gera_atd         = "N"
                     let g_documento.atdnum = mr_cta02m22a.atdnum


                     #-- Solicitar Assunto --#
                     call cta02m00_solicitar_assunto(mr_documento.*,lr_ppt.*)

                     let l_retorno          = "SAI"
                     let g_documento.atdnum = null
                     let m_flg_assunto      = "S"

                     exit display
                  else
                     error ' A ligacao esta sendo atendida por : ', mr_cta02m22a.atdsegfunmat
                     exit display
                  end if
                  ##
                  #-----------------------------------------------------------
                  # Chama espelho da apolice ou cartao
                  #-----------------------------------------------------------
               on key (F5)
                  ##-- Exibir espelho da apolice --##
                   let g_documento.atdnum  = mr_cta02m22a.atdnum
                   call cta01m12_espelho(mr_cta02m22a.ramcod
                                        ,mr_cta02m22a.succod
                                        ,mr_cta02m22a.aplnumdig
                                        ,mr_cta02m22a.itmnumdig
                                        ,mr_cta02m22.prporg
                                        ,mr_cta02m22.prpnumdig
                                        ,''   ##mr_documento.fcapacorg
                                        ,''   ##mr_documento.fcapacnum
                                        ,''   ##mr_documento.pcacarnum
                                        ,''   ##mr_documento.pcaprpitm
                                        ,0    ##lr_ppt.cmnnumdig
                                        ,0    ##mr_documento.crtsaunum
                                        ,0    ##mr_documento.bnfnum
                                        ,mr_cta02m22.ciaempcod)
              on key(tab)
                 let l_retorno = "TRN"
                 exit display
            end display
         else
            call set_count(arr_aux)
            display array ar_cta02m22a to s_cta02m22a.*

               on key(control-c,interrupt)
                  let l_retorno = "SAI"
                  exit display
               on key (F1)
                  let l_confirma = cts08g01('A','S', '' ,"CONFIRMA TRANSFERENCIA ?", '', '')
                  if l_confirma = 'N' then
                     exit display
                  end if
                  if mr_cta02m22a.atdsegfunmat is null then
                     let mr_cta02m22a.trncapdat = today
                     let mr_cta02m22a.trncaphor = current
                     whenever error continue
                     execute p_cta02m22_001 using mr_cta02m22a.atdsegpanum   ## verificar as globais origens
                                               ,g_issk.dptsgl
                                               ,g_issk.funmat
                                               ,g_issk.usrtip
                                               ,g_issk.empcod
                                               ,mr_cta02m22a.trncapdat
                                               ,mr_cta02m22a.trncaphor
                                               ,mr_cta02m22a.atdnum
                                               ,mr_cta02m22a.atdtrnnum
                     whenever error stop
                     if sqlca.sqlcode <> 0 then
                        error "Erro na alteracao de datmatdtrn: "
                              ,sqlca.sqlcode  sleep 3
                        let int_flag = true
                        exit display
                     else
                        error " Ligacao travada "
                     end if

                     let mr_documento.ligcvntip    = mr_cta02m22.ligcvntip
                     let mr_documento.succod       = mr_cta02m22.succod
                     let mr_documento.aplnumdig    = mr_cta02m22.aplnumdig
                     let mr_documento.itmnumdig    = mr_cta02m22.itmnumdig
                     let mr_documento.prporg       = mr_cta02m22.prporg
                     let mr_documento.prpnumdig    = mr_cta02m22.prpnumdig
                     let mr_documento.solnom       = mr_cta02m22.solnom
                     let mr_documento.c24soltipcod = mr_cta02m22.c24soltipcod
                     let mr_documento.ramcod       = mr_cta02m22.ramcod
                     let mr_documento.sinramcod    = mr_cta02m22.sinramcod
                     let mr_documento.sinano       = mr_cta02m22.sinnum
                     let mr_documento.sinnum       = mr_cta02m22.sinano
                     let mr_documento.vstnumdig    = mr_cta02m22.vstnumdig
                     let mr_documento.corsus       = mr_cta02m22.corsus
                     let mr_documento.dddcod       = mr_cta02m22.semdoctodddcod
                     let mr_documento.ctttel       = mr_cta02m22.semdoctoctttel
                     let mr_documento.funmat       = mr_cta02m22.funmat
                     let mr_documento.cgccpfnum    = mr_cta02m22.cgccpfnum
                     let mr_documento.cgcord       = mr_cta02m22.cgcord
                     let mr_documento.cgccpfdig    = mr_cta02m22.cgccpfdig
                     let g_documento.atdnum        = mr_cta02m22a.atdnum
                     let g_documento.ligcvntip     = mr_documento.ligcvntip
                     let g_documento.c24soltipcod  = mr_documento.c24soltipcod
                     let g_documento.solnom        = mr_documento.solnom
                     let g_documento.succod        = mr_documento.succod
                     let g_documento.ramcod        = mr_documento.sinramcod
                     let g_documento.aplnumdig     = mr_documento.aplnumdig
                     let g_documento.itmnumdig     = mr_documento.itmnumdig
                     let g_documento.prporg        = mr_documento.prporg
                     let g_documento.prpnumdig     = mr_documento.prpnumdig
                     let g_documento.sinramcod     = mr_documento.sinramcod
                     let g_documento.sinano        = mr_documento.sinano
                     let g_documento.sinnum        = mr_documento.sinnum

                     if mr_cta02m22.semdcto = "S" then
                        let mr_documento.corsus    = mr_cta02m22.semdoctocorsus
                        let mr_documento.cgccpfnum = mr_cta02m22.semdoctocgccpfnum
                        let mr_documento.cgcord    = mr_cta02m22.semdoctocgcord
                        let mr_documento.cgccpfdig = mr_cta02m22.semdoctocgccpfdig
                        let mr_documento.funmat    = mr_cta02m22.semdoctofunmat
                        let g_documento.funmat     = mr_cta02m22.semdoctofunmat
                        let g_documento.empcodmat  = mr_cta02m22.semdoctoempcod
                     end if

                     -->P/ nao gerar outro Nro.Atendimento da tela de Assunto
                     let g_gera_atd         = "N"
                     let g_documento.atdnum = mr_cta02m22a.atdnum
                     #-- Solicitar Assunto --#
                     call cta02m00_solicitar_assunto(mr_documento.*,lr_ppt.*)

                     let l_retorno          = "SAI"
                     let g_documento.atdnum = null
                     let m_flg_assunto      = "S"

                     exit display
                  else
                     error ' A ligacao esta sendo atendida por : ', mr_cta02m22a.atdsegfunmat
                     exit display
                  end if
                  #-------------------------------------------------------------
                  # Chama espelho da apolice ou cartao
                  #-------------------------------------------------------------
               on key (F5)
                  ##-- Exibir espelho da apolice --##
                   let g_documento.atdnum  = mr_cta02m22a.atdnum
                   call cta01m12_espelho(mr_cta02m22a.ramcod
                                        ,mr_cta02m22a.succod
                                        ,mr_cta02m22a.aplnumdig
                                        ,mr_cta02m22a.itmnumdig
                                        ,mr_cta02m22.prporg
                                        ,mr_cta02m22.prpnumdig
                                        ,''   ##mr_documento.fcapacorg
                                        ,''   ##mr_documento.fcapacnum
                                        ,''   ##mr_documento.pcacarnum
                                        ,''   ##mr_documento.pcaprpitm
                                        ,0    ##lr_ppt.cmnnumdig
                                        ,0    ##mr_documento.crtsaunum
                                        ,0    ##mr_documento.bnfnum
                                        ,mr_cta02m22.ciaempcod)
               on key(tab)
                  let l_retorno = "LIG"
                  exit display
            end display
         end if
      end if
   else
      error " Nenhum historico foi cadastrado para esta ligacao!"
      let int_flag =  true
      let l_retorno = "LIG"
   end if

   return l_retorno

 end function
