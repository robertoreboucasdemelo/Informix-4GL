#---------------------------------------------------------------------------#
# Nome do Modulo: cta00m07a                                                 #
# Localizacao de documentos da empresa Azul Seguros                         #
#---------------------------------------------------------------------------#
# Alteracoes:                                                               #
#---------------------------------------------------------------------------#
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 15/12/2006  psi205206    Sergio       Localizar doctos Azul Seguros       #
#                                                                           #
# 07/04/2008  psi221830    Amilton,Meta Criar replica do Cta00m07 e inibir  #
#                                       todos os laudos                     #
#                                                                           #
# 29/12/2009               Patricia W.  Projeto SUCCOD - Smallint           #
#---------------------------------------------------------------------------#

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

 define mr_entrada record
                       solnom       char(15),
                       c24soltipcod char(01),
                       c24soltipdes char(20),
                       ramcod       smallint,
                       ramnom       char(40),
                       succod       like datrligapol.succod,  #decimal(2,0),  #projeto succod
                       sucnom       char(40),
                       aplnumdig    decimal(9,0),
                       itmnumdig    decimal(7,0),
                       vcllicnum    char(7),
                       segnom       char(40),
                       pestip       char(01),
                       cgccpfnum    decimal(14,0),
                       cgcord       decimal(4,0),
                       cgccpfdig    decimal(2,0),
                       vclchsfnl    char(8),
                       semdocto     char(1),
                       obs          char(09)
                   end record

 define m_ramsgl    char(15),
        m_cgccpfdig decimal(2,0),
        m_tamanho   smallint,
	m_confirma  char(1)


#--------------------------------------------------------#
function cta00m07_principal(lr_param,lr_param2,lr_param3)
#--------------------------------------------------------#
    define lr_param  record
           apoio     char(01),
           empcodatd like isskfunc.empcod,
           funmatatd like isskfunc.funmat,
           usrtipatd like issmnivnovo.usrtip,
           c24paxnum integer
    end record
    define lr_param2 record
           solnom    char(15),
           segnom    like gsakseg.segnom,
           vcllicnum like abbmveic.vcllicnum,
           cgccpfnum dec(12,0),
           cgcord    dec(04,0),
           cgccpfdig dec(02,0),
           pestip    char(1)
    end record
    define lr_param3    record
           atdsrvorg    like datmservico.atdsrvorg
          ,atdsrvnum    like datmservico.atdsrvnum
          ,atdsrvano    like datmservico.atdsrvano
          ,prg          char (08)
    end record

    define l_cont      smallint,
           l_asterisco char(01),
           l_sem_doc   smallint,
           l_acsnivcod like issmnivnovo.acsnivcod

    define lr_apolice record
                           resultado       smallint,
                           mensagem        char(42),
                           xml             char(32000)
                       end record

    define lr_aux record
                      resultado  smallint,
                      mensagem   char(60),
                      acsnivcod like issmnivnovo.acsnivcod,
                      c24paxtxt  char (12)
                  end record

    initialize mr_entrada.*   ,
               mr_documento.* ,
               mr_documento2.*,
               g_ppt.*        ,
               lr_apolice.*   ,
               lr_aux.*       ,
               m_ramsgl       ,
               m_cgccpfdig    ,
               m_tamanho      ,
               m_confirma     ,
               m_resultado    ,
               l_acsnivcod to null
display lr_param2.*
    let mr_entrada.solnom    = lr_param2.solnom
    let mr_entrada.vcllicnum = lr_param2.vcllicnum
    let mr_entrada.segnom    = lr_param2.segnom
    let mr_entrada.cgccpfnum = lr_param2.cgccpfnum
    let mr_entrada.cgcord    = lr_param2.cgcord
    let mr_entrada.cgccpfdig = lr_param2.cgccpfdig
    let mr_entrada.pestip    = lr_param2.pestip

    ------[ verifica procedimentos para tela ]------
    call cts14g02("N", "cta00m07")

   { if lr_param3.atdsrvnum is not null then
       let mr_entrada.obs = "(F8)Laudo)"
    end if}

    open window cta00m07 at 04,02 with form "cta00m07"
                         attribute(form line 1, border)

    let int_flag  = false
    let l_sem_doc = false

    input by name mr_entrada.* without defaults

        before field solnom
            let mr_entrada.ramcod = 531
	    let mr_documento.empcodatd = lr_param.empcodatd
            let mr_documento.funmatatd = lr_param.funmatatd
	    let mr_documento.usrtipatd = lr_param.usrtipatd
	    if lr_param.apoio = "S" then
	       call cty08g00_nome_func(lr_param.empcodatd
				      ,lr_param.funmatatd
                                      ,lr_param.usrtipatd)
	                returning lr_apolice.resultado
	                         ,lr_apolice.mensagem
	                         ,mr_entrada.solnom
	        if lr_apolice.resultado = 3 then
                   call errorlog(lr_apolice.mensagem)
                   exit input
	        else
	           if lr_apolice.resultado = 2 then
		      call errorlog(lr_apolice.mensagem)
                   end if
                end if
		let mr_entrada.c24soltipcod = 6
		let mr_entrada.c24soltipdes = "APOIO"
		display by name mr_entrada.c24soltipcod
		display by name mr_entrada.c24soltipdes
		display by name mr_entrada.solnom
		let mr_documento.c24soltipcod = mr_entrada.c24soltipcod
		let mr_documento.solnom       = mr_entrada.solnom
		next field ramcod
            end if
            display by name mr_entrada.solnom  attribute (reverse)

        after field solnom

            display by name mr_entrada.solnom

            if  mr_entrada.solnom is null then
                error 'Nome do solicitante deve ser informado!'
                next field solnom
            end if
            let mr_documento.solnom = mr_entrada.solnom

        before field c24soltipcod

            display by name mr_entrada.c24soltipcod attribute (reverse)

        after field c24soltipcod

            display by name mr_entrada.c24soltipcod

            if  fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field solnom
            end if

            #-- Exibe popup dos tipos de solicitante --#
            if  mr_entrada.c24soltipcod is null then
                error "Tipo do solicitante deve ser informado!"
                let mr_entrada.c24soltipcod = cto00m00(1)
                display by name mr_entrada.c24soltipcod
            end if

            #-- Busca a Descrição do Tipo do Solicitante --#
            call cto00m00_nome_solicitante(mr_entrada.c24soltipcod, 1)
                 returning lr_aux.resultado
                          ,lr_aux.mensagem
                          ,mr_entrada.c24soltipdes

            if  lr_aux.resultado <> 1 then
                error lr_aux.mensagem
                next field c24soltipcod
            else
                display by name mr_entrada.c24soltipdes

                if mr_entrada.c24soltipcod < 3 then
                   let mr_documento.soltip = mr_entrada.c24soltipdes[1,1]
                else
                   let mr_documento.soltip = "O"
                end if
            end if
            let mr_documento.c24soltipcod = mr_entrada.c24soltipcod

            # Se nao tem nr. do pax e nivel 6
            #display ' lr_param.c24paxnum : ', lr_param.c24paxnum
            #display ' g_issk.acsnivcod   : ', g_issk.acsnivcod
            if lr_param.c24paxnum is null and g_issk.acsnivcod = 6 then

               #Obter nivel do funcionario
               call cty08g00_nivel_func(g_issk.usrtip
                                       ,g_issk.empcod
                                       ,g_issk.usrcod
                                       ,'pso_ct24h')
               returning mr_documento2.resultado
                        ,mr_documento2.mensagem
                        ,l_acsnivcod

               #display ' mr_documento2.resultado : ',mr_documento2.resultado
               #display ' mr_documento2.mensagem  : ',mr_documento2.mensagem
               #display ' l_acsnivcod             : ',l_acsnivcod

               if l_acsnivcod is null then
                  while lr_param.c24paxnum is null
                     #-- obter nr. do pax --#
                     let lr_param.c24paxnum = cta02m09()
                  end while
               end if
            end if

            if lr_param.c24paxnum is not null  and
               lr_param.c24paxnum <> 0 then
               let lr_aux.c24paxtxt = "P.A.: ", lr_param.c24paxnum using "######"
               display by name lr_aux.c24paxtxt  attribute (reverse)
            else
               let lr_param.c24paxnum = 0
            end if

            let mr_documento.c24paxnum = lr_param.c24paxnum

        before field ramcod

            display by name mr_entrada.ramcod  attribute (reverse)

        after field ramcod

            if  mr_entrada.ramcod is null then
                let mr_entrada.ramcod = 531
            end if

            if mr_entrada.ramcod = 80  or
               mr_entrada.ramcod = 81  or
               mr_entrada.ramcod = 981 or
               mr_entrada.ramcod = 982 then
               error " Consulta nao disponivel para este ramo!"
               next field ramcod
            end if

            #Obter a descricao do ramo
            call cty10g00_descricao_ramo(mr_entrada.ramcod,1)
            returning lr_aux.resultado
                     ,lr_aux.mensagem
                     ,mr_entrada.ramnom
                     ,m_ramsgl

            if lr_aux.resultado = 3 then
               #call errorlog(lr_aux.mensagem)
               exit input
            else
               if lr_aux.resultado = 2 then
                  #call errorlog(lr_aux.mensagem)
               end if
            end if

            #-- Exibir tela popup para escolha do ramo --#
            if mr_entrada.ramnom is null then
               error " Ramo nao cadastrado!" sleep 2
               call c24geral10()
                    returning mr_entrada.ramcod, mr_entrada.ramnom
               next field ramcod
            end if
            call cty10g00_grupo_ramo(g_issk.empcod
                                    ,mr_entrada.ramcod)
                 returning lr_aux.resultado,
                           lr_aux.mensagem,
                           mr_documento.ramgrpcod

            display by name mr_entrada.ramcod
            display by name mr_entrada.ramnom

        before field succod

            if  mr_entrada.succod is null  then
                let mr_entrada.succod = 02
            end if

            display by name mr_entrada.succod attribute (reverse)

        after field succod

            if  mr_entrada.succod is null  then
                let mr_entrada.succod = 02
            end if

            display by name mr_entrada.succod

            # Alteração Burini: Buscar código e nome da sucursal do XML
            # #-- Obter o nome da sucursal --#
            # call f_fungeral_sucursal(mr_entrada.succod)
            # returning mr_entrada.sucnom
            #
            # #-- Exibe tela popup para escolha da sucursal --#
            # if  mr_entrada.sucnom is null then
            #     error " Sucursal nao cadastrada!"
            #     call c24geral11()
            #          returning mr_entrada.succod, mr_entrada.sucnom
            #     next field succod
            # end if
            #
            # display by name mr_entrada.succod
            # display by name mr_entrada.sucnom

        before field aplnumdig

           display by name mr_entrada.aplnumdig attribute (reverse)

        after  field aplnumdig

           display by name mr_entrada.aplnumdig

           if  mr_entrada.aplnumdig = 0 then
               let mr_entrada.aplnumdig = null
               let mr_entrada.itmnumdig = null
               display by name mr_entrada.itmnumdig
               display by name mr_entrada.aplnumdig
           end if

           if  mr_entrada.ramcod  <>  31 and
               mr_entrada.ramcod  <> 531 then
               if  mr_entrada.ramcod  =  16 or
                   mr_entrada.ramcod  = 524 then
                   next field vcllicnum
               end if
           end if

           let mr_entrada.itmnumdig = null

           display by name mr_entrada.itmnumdig

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field succod
           else
               if  mr_entrada.aplnumdig is null then
                   next field vcllicnum
               else
                   next field itmnumdig
               end if
           end if

        before field itmnumdig

           display by name mr_entrada.itmnumdig attribute (reverse)

        after  field itmnumdig

           display by name mr_entrada.itmnumdig

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field aplnumdig
           end if

             if  mr_entrada.aplnumdig  is not null and
                 mr_entrada.itmnumdig  is not null then
                 call cts38m00_dados_apolice(mr_entrada.succod,
                                             mr_entrada.aplnumdig,
                                             mr_entrada.itmnumdig,
                                             mr_entrada.ramcod)
                                   returning mr_documento.aplnumdig,
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

                 if  mr_documento2.resultado <> 1 then
                     error 'Item nao encontrado para a Apólice'
                     next field aplnumdig
                 end if

                 call cta00m07_sit_apol(mr_documento2.vigfnl,
                                        mr_documento2.situacao)
                      returning m_resultado

                 if m_resultado = 1 then
                    exit input
                 else
                    next field aplnumdig
                 end if

             else
                 if  mr_entrada.itmnumdig  is not null   then
                     error " Numero da apolice deve ser informado!"
                     next field aplnumdig
                 end if

                 call cts38m00_busca_itens_apolice(mr_entrada.succod,
                                                   mr_entrada.aplnumdig)
                                         returning mr_documento.aplnumdig,
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

                 if  mr_documento2.resultado <> 1 then
                     error 'Nenhum Item selecionado'
                     next field itmnumdig
                 end if

                 call cta00m07_sit_apol(mr_documento2.vigfnl,
                                        mr_documento2.situacao)
                      returning m_resultado

                 if m_resultado = 1 then
                    exit input
                 else
                    next field itmnumdig
                 end if

             end if

             if  fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field aplnumdig
             else
                 next field vcllicnum
             end if

        before field vcllicnum

           display by name mr_entrada.vcllicnum attribute (reverse)

        after  field vcllicnum

           display by name mr_entrada.vcllicnum

           if  fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               let mr_entrada.vcllicnum = null
               display by name mr_entrada.vcllicnum
               next field aplnumdig
           end if

           if  mr_entrada.vcllicnum  is not null  and
               mr_entrada.ramcod     <> 16        and
               mr_entrada.ramcod     <> 31        and
               mr_entrada.ramcod     <> 524       and
               mr_entrada.ramcod     <> 531       then
               error " Localizacao por licenca somente ramo",
                     " Automovel/Garantia Estendida!"
               next field vcllicnum
           end if

           if  mr_entrada.vcllicnum  is not null then
               call cts38m00_dados_placa(mr_entrada.vcllicnum,"")
                              returning mr_documento.aplnumdig,
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

               if  mr_documento2.resultado <> 1 then
                   error 'Placa não encontrada'
                   next field vcllicnum
               end if

               call cta00m07_sit_apol(mr_documento2.vigfnl,
                                      mr_documento2.situacao)
                    returning m_resultado

               if m_resultado = 1 then
                  exit input
               else
                  next field vcllicnum
               end if
           end if

        before field segnom

           display by name mr_entrada.segnom attribute (reverse)

        after  field segnom

          display by name mr_entrada.segnom
          if  fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              let mr_entrada.segnom = null
              display by name mr_entrada.segnom
              next field vcllicnum
          end if

          if  mr_entrada.segnom is not null then

             let m_tamanho = (length (mr_entrada.segnom))

             if  m_tamanho < 10  then
                 error " Complemente o nome do segurado (minimo 10 caracteres)!"
                 next field segnom
             end if

              for l_cont  = 1 to m_tamanho

                  let l_asterisco = mr_entrada.segnom[l_cont ,l_cont ]

                  if  l_asterisco = " " then
                      continue for
                  end if

                  if  l_asterisco matches "[*]" then
                      error "Nome do segurado nao pode começar com(*)!" sleep 2
                      next field segnom
                  end if

                  exit for
              end for

              call cts38m00_dados_segurador(mr_entrada.segnom)
                                 returning mr_documento.aplnumdig,
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

              if  mr_documento2.resultado <> 1 then
                  error 'Nenhum segurador selecionado'
                  next field segnom
              end if

              call cta00m07_sit_apol(mr_documento2.vigfnl,
                                     mr_documento2.situacao)
                   returning m_resultado

              if m_resultado = 1 then
                 exit input
              else
                 next field segnom
              end if
          end if

        before field pestip

             display by name mr_entrada.pestip attribute (reverse)

        after field pestip

             display by name mr_entrada.pestip

             if  mr_entrada.pestip is not null  and
                 mr_entrada.pestip <>  "F"      and
                 mr_entrada.pestip <>  "J"      then
                 error " Tipo de pessoa invalido!"
                 next field pestip
             end if

             if  mr_entrada.segnom is null  then
                 if  fgl_lastkey() = fgl_keyval ("up")     or
                     fgl_lastkey() = fgl_keyval ("left")   then
                     next field segnom
                 else
                     next field cgccpfnum
                 end if
             end if

        before field cgccpfnum

           display by name mr_entrada.cgccpfnum   attribute(reverse)

        after  field cgccpfnum

           display by name mr_entrada.cgccpfnum

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field pestip
           end if

           if  mr_entrada.pestip is not null   then
               if  mr_entrada.cgccpfnum   is null   or
                   mr_entrada.cgccpfnum   =  0      then
                   error " Numero do CGC/CPF deve ser informado!"
                   next field cgccpfnum
               end if
           else
               if  mr_entrada.cgccpfnum   is not null   then
                   error " Tipo de pessoa deve ser informada!"
                   next field pestip
               else
                   initialize mr_entrada.cgcord     to null
                   initialize mr_entrada.cgccpfdig  to null
                   display by name mr_entrada.cgcord
                   display by name mr_entrada.cgccpfdig

                   if  fgl_lastkey() = fgl_keyval ("up")     or
                       fgl_lastkey() = fgl_keyval ("left")   then
                       next field pestip
                   else
                       next field vclchsfnl
                   end if
               end if
           end if

           if  mr_entrada.pestip =  "F"   then
               if  fgl_lastkey() = fgl_keyval ("up")     or
                   fgl_lastkey() = fgl_keyval ("left")   then
                   next field pestip
               else
                   next field cgccpfdig
               end if
           end if

        before field cgcord

           display by name mr_entrada.cgcord   attribute(reverse)

        after  field cgcord

           display by name mr_entrada.cgcord

           if  fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               next field cgccpfnum
           end if

           if  mr_entrada.cgcord   is null   or
               mr_entrada.cgcord   =  0      then
               error " Filial do CGC deve ser informada!"
               next field cgcord
           end if

        before field cgccpfdig

           display by name mr_entrada.cgccpfdig  attribute(reverse)

        after  field cgccpfdig

           display by name mr_entrada.cgccpfdig

           if  fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               next field cgccpfnum
           end if

           if  mr_entrada.cgccpfdig is null then
               error " Digito do CGC/CPF deve ser informado!"
               next field cgccpfdig
           end if

           if  mr_entrada.pestip =  "J" then
               call F_FUNDIGIT_DIGITOCGC(mr_entrada.cgccpfnum,
                                         mr_entrada.cgcord)
                    returning m_cgccpfdig
           else
               call F_FUNDIGIT_DIGITOCPF(mr_entrada.cgccpfnum)
                    returning m_cgccpfdig
           end if

           if  m_cgccpfdig is null or
               mr_entrada.cgccpfdig  <>  m_cgccpfdig   then
               error " Digito do CGC/CPF incorreto!"
               next field cgccpfdig
           end if

           call cts38m00_dados_cpfcgc(mr_entrada.pestip,
                                      mr_entrada.cgccpfnum,
                                      mr_entrada.cgcord,
                                      mr_entrada.cgccpfdig,"")
                           returning mr_documento.aplnumdig,
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

           if  mr_documento2.resultado <> 1 then
               if  fgl_lastkey() = fgl_keyval ("up")     or
                   fgl_lastkey() = fgl_keyval ("left")   then
                   if  mr_entrada.pestip =  "J"  then
                       next field cgcord
                   else
                       next field cgccpfnum
                   end if
                end if

                error 'Nenhum CPF/CGC encontrado'
                next field cgccpfnum

           end if

           call cta00m07_sit_apol(mr_documento2.vigfnl,
                                  mr_documento2.situacao)
                returning m_resultado

           if m_resultado = 1 then
              exit input
           else
              next field cgccpfnum
           end if

        before field vclchsfnl

           display by name mr_entrada.vclchsfnl attribute (reverse)

        after  field vclchsfnl

           display by name mr_entrada.vclchsfnl

           if  fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               next field cgccpfnum
           end if

           if  mr_entrada.vclchsfnl  is not null then
               if  mr_entrada.ramcod  <> 31  and
                   mr_entrada.ramcod  <> 531 then
                   error " Localizacao por chassi somente para ramo Automovel!"
                   next field vclchsfnl
               else
                   call cts38m00_dados_chassi(mr_entrada.vclchsfnl)
                                   returning mr_documento.aplnumdig,
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

                   if  mr_documento2.resultado <> 1 then
                       error 'Chassi nao encontrado'
                       next field vclchsfnl
                   end if

                   call cta00m07_sit_apol(mr_documento2.vigfnl,
                                          mr_documento2.situacao)
                        returning m_resultado

                   if m_resultado = 1 then
                      exit input
                   else
                      next field vclchsfnl
                   end if
               end if
           end if

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field cgccpfnum
           else
               next field semdocto
           end if

        before field semdocto
           display by name mr_entrada.semdocto  attribute (reverse)

        after field semdocto
           display by name mr_entrada.semdocto

           if  fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               next field vclchsfnl
           end if

            if mr_entrada.semdocto is null then
               next field semdocto
            else
               if mr_entrada.semdocto <> "S" then
                  error 'Opcao invalida, digite "S" para ligacao Sem Docto.' sleep 2
                  next field semdocto
               else
                  call cta10m00_entrada_dados()
                  let mr_documento.corsus    = g_documento.corsus
                  let mr_documento.dddcod    = g_documento.dddcod
                  let mr_documento.ctttel    = g_documento.ctttel
                  let mr_documento.funmat    = g_documento.funmat
                  let mr_documento.cgccpfnum = g_documento.cgccpfnum
                  let mr_documento.cgcord    = g_documento.cgcord
                  let mr_documento.cgccpfdig = g_documento.cgccpfdig

                  if  mr_documento.corsus    is null and
                      mr_documento.dddcod    is null and
                      mr_documento.ctttel    is null and
                      mr_documento.funmat    is null and
                      mr_documento.cgccpfnum is null and
                      mr_documento.cgcord    is null and
                      mr_documento.cgccpfdig is null then
                      error 'Falta informacoes para registrar Ligacao sem Docto.' sleep 2
                      next field semdocto
                  else
                      let l_sem_doc = true
                  end if
               end if
            end if


         # PSI221840 Inicio

         # Bloco comentado para inibir a consulta do laudo #
         {on key (F8)
           if lr_param3.atdsrvnum is not null and
              lr_param3.atdsrvnum <> 0 then
              let g_documento.atdsrvorg = lr_param3.atdsrvorg
              let g_documento.atdsrvnum = lr_param3.atdsrvnum
              let g_documento.atdsrvano = lr_param3.atdsrvano

              if not cts04g00("") then
                 error "Nao foi possivel apresentar laudo!"
             end if
           else
             error "Opcao valida para ligacao sem documento"
           end if}


           #if  mr_entrada.aplnumdig  is null   and
           #    mr_entrada.cgccpfnum  is null   and
           #    mr_entrada.vcllicnum  is null   and
           #    mr_entrada.vclchsfnl  is null   and
           #    mr_entrada.prpnumdig  is null   and
           #    mr_entrada.segnom     is null   then
           #    error " Informe uma das chaves de localizacao!"
           #    next field succod
           #end if

           # PSI221840 Fim

    end input

    if  not int_flag then
        if  l_sem_doc then
            let mr_documento2.doc_handle = 0
        end if

       #call cta00m07_guarda_globais()
    else
        let mr_documento2.doc_handle = null
    end if

    call cta00m07_guarda_globais()
    close window cta00m07

    return mr_documento.*,
           mr_documento2.doc_handle

end function

#---------------------------------#
function cta00m07_guarda_globais()
#---------------------------------#

  initialize g_documento.solnom,
             g_documento.c24soltipcod,
             g_documento.soltip,
             g_documento.ramcod,
             g_documento.succod,
             g_documento.aplnumdig,
             g_documento.empcodatd,
             g_documento.funmatatd,
             g_documento.usrtipatd,
             g_documento.itmnumdig,
             g_documento.corsus,
             g_documento.dddcod,
             g_documento.ctttel,
             g_documento.funmat,
             g_documento.cgccpfnum,
             g_documento.cgcord,
             g_documento.cgccpfdig,
             g_documento.prpnumdig,
             g_documento.edsnumref,
             g_documento.ramgrpcod to null

 let g_c24paxnum              = mr_documento.c24paxnum
 let g_documento.solnom       = mr_documento.solnom
 let g_documento.c24soltipcod = mr_documento.c24soltipcod
 let g_documento.soltip       = mr_documento.soltip
 let g_documento.ramcod       = mr_documento.ramcod
 let g_documento.succod       = mr_documento.succod
 let g_documento.aplnumdig    = mr_documento.aplnumdig
 let g_documento.empcodatd    = mr_documento.empcodatd
 let g_documento.funmatatd    = mr_documento.funmatatd
 let g_documento.usrtipatd    = mr_documento.usrtipatd
 let g_documento.ligcvntip    = 0

 if  mr_documento.itmnumdig is null then
     let mr_documento.itmnumdig = 0
     let g_documento.itmnumdig  = 0
 else
     let g_documento.itmnumdig = mr_documento.itmnumdig
 end if

 ---[nao existe, para Azul, atendimento sem docto pela susep ]----
 initialize mr_documento.corsus to null

 let g_documento.itmnumdig    = mr_documento.itmnumdig
 let g_documento.corsus       = mr_documento.corsus
 let g_documento.dddcod       = mr_documento.dddcod
 let g_documento.ctttel       = mr_documento.ctttel
 let g_documento.funmat       = mr_documento.funmat
 let g_documento.cgccpfnum    = mr_documento.cgccpfnum
 let g_documento.cgcord       = mr_documento.cgcord
 let g_documento.cgccpfdig    = mr_documento.cgccpfdig
 let g_documento.edsnumref    = mr_documento.edsnumref
 let g_documento.ramgrpcod    = mr_documento.ramgrpcod

end function

function cta00m07_sit_apol(lr_param)

   define l_msg record
          linha1      char(40),
          linha2      char(40),
          linha3      char(40),
          linha4      char(40)
   end record

   define l_confirma  char(1),
          l_resultado smallint

   define lr_param    record
          vigfnl      date,
          situacao    char(10)
   end record

   initialize l_msg.* to null
   let l_confirma = null
   let l_resultado = 0

   if  lr_param.vigfnl < today or
       lr_param.situacao = "VENCIDA" then
       let l_msg.linha1 = "Esta apolice esta vencida"
       let l_msg.linha2 = "Procure uma apolice vigente"
       let l_msg.linha3 = "Ou consulte a supervisao."
       let l_msg.linha4 = "Deseja prosseguir?"
   else
      case lr_param.situacao
           when "PROPOSTA"
                let l_msg.linha1 = "Esta apolice ainda nao foi emitida"
                let l_msg.linha2 = "Consulte a supervisao"
                let l_msg.linha3 = ""
                let l_msg.linha4 = "Deseja prosseguir?"
           when "RECUSADA"
                let l_msg.linha1 = "Esta apolice foi recusada"
                let l_msg.linha2 = "Consulte a supervisao"
                let l_msg.linha3 = ""
                let l_msg.linha4 = "Deseja prosseguir?"
           when "CANCELADA"
                let l_msg.linha1 = "Esta apolice esta cancelada"
                let l_msg.linha2 = "Procure uma apolice ativa"
                let l_msg.linha3 = "Ou consulte a supervisao."
                let l_msg.linha4 = "Deseja prosseguir?"
           otherwise
                let l_resultado = 1
        end case

   end if

   if l_resultado = 0 then

      call cts08g01("C","S", l_msg.linha1, l_msg.linha2,
                    l_msg.linha3, l_msg.linha4)
           returning l_confirma

      if l_confirma  = "S" then
         let l_resultado = 1
      end if

   end if

   return l_resultado

end function
