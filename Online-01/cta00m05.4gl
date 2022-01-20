
#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta00m05.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Controle de atendimento ao Segurado                        #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 19/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor   Fabrica     Origem     Alteracao                        #
# ---------- ----------------- ---------- -----------------------------------#
# 20/08/2004 Daniel, Meta       PSI183431   Alterar definicao da variavel    #
#                                           averbacao                        #
#                                           Alterar condicao de chamada para #
#                                           a funcao cts27m00()              #
#----------------------------------------------------------------------------#
# 14/09/2004 Katiucia           CT 244716   Inicialiar variavel antes funcao #
#----------------------------------------------------------------------------#
# 24/01/2005 Robson, Meta       PSI190080   Alterar  a  chamada  da  funcao  #
#                                           cta02m00() para                  #
#                                           cta02m00_solicitar_assunto().    #
#----------------------------------------------------------------------------#
# 11/03/2005 Daniel, Meta       PSI191094   Chamar a funcao cta00m06 e tratar#
#                                           seu retorno                      #
#----------------------------------------------------------------------------#
# 15/09/2005 Andrei, Meta       AS87408     Chamar a funcao cts01g01_        #
#                                                           setexplain       #
# 23/11/2006 Sergio/Ruiz        psi205206   Implementacao Azul Seguros.      #
# 14/02/2007 Ligia Mattge                   Chamar cta00m08_ver_contingencia #
# 06/06/2007 Ruiz               psi209007   Inclusao de parametros na funcao #
#                                           cta00m07_princial.(ctg Azul)     #
# 29/02/2008 Amilton, Meta      psi219967   incluir retorno na chamada da    #
#                                            função cta00m16_chama_prog e    #
#                                            validar o retorno               #
#----------------------------------------------------------------------------#
#18/10/2008 Carla Rampazzo  PSI 230650      Passar p/ "ctg18" o campo atdnum #
#----------------------------------------------------------------------------#
#18/03/2010 Carla Rampazzo  PSI 219444      Passar p/ "ctg18" os campos      #
#                                           lclnumseq / rmerscseq (RE)       #
#----------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853      Implementacao do PSS             #
#----------------------------------------------------------------------------#
# 26/01/2016 Alberto        CoreDump                                         #
#----------------------------------------------------------------------------#
globals '/homedsa/projetos/geral/globals/glct.4gl'

#-----------------------------------#
 function cta00m05_controle(lr_parm)
#-----------------------------------#

  define lr_parm       record
         apoio         char(01),
         empcodatd     like isskfunc.empcod,
         funmatatd     like isskfunc.funmat,
         usrtipatd     like issmnivnovo.usrtip,
	 c24paxnum     like datmligacao.c24paxnum
  end record

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
         cgccpfdig     like gsakseg.cgccpfdig     ,  # digito do CGC(CNPJ) ou CPF /fim psi172413 eduardo - meta
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

  define lr_aux record
                    segcod     integer,
                    segnom     char(50),
                    vcldes     char(50),
                    resultado  smallint
                end record

  define la_ppt        array[05] of record
         clscod        like aackcls.clscod,
         carencia      date
  end record

  define l_msg          char(60)
  define l_status       smallint # PSI219967  Amilton Fim

  define l_ligcvntip like datkdominio.cpocod
        ,l_resultado smallint
        ,l_mensagem  char(60)


  define l_nullo record
         param1 smallint ,
         param2 char(50) ,
         param3 smallint
  end record
   define l_origem  char(5)
   define l_desc    char(30)

  define l_flag_acesso  smallint,
         l_doc_handle   integer,
         l_contingencia smallint,
         l_cod_produto  smallint,
         l_semdocto     smallint,
         l_acesso_esp   smallint,
         l_psscntcod    integer ,
         l_itaciacod    integer

 initialize lr_documento.*   to null
 initialize lr_ppt.*         to null
 initialize la_ppt           to null
 initialize l_nullo.*        to null
 initialize l_status         to null
 initialize g_pss.*          to null
 initialize g_pss_endereco.* to null
 initialize g_monitor.*      to null

 let l_doc_handle   = null
 let l_ligcvntip    = null
 let l_resultado    = null
 let l_mensagem     = null
 let l_contingencia = null
 let l_cod_produto  = null
 let l_semdocto     = null
 let l_acesso_esp   = true
 let l_psscntcod    = null
 let l_itaciacod    = null

 call cts01g01_setexplain(g_issk.empcod, g_issk.funmat, 1)

 call cta00m05_mostra_empresa(g_documento.ciaempcod)

 call cta00m08_ver_contingencia(1)
      returning l_contingencia

 if l_contingencia then
    return 0
 end if

 if  g_documento.ciaempcod = 1  or
     g_documento.ciaempcod = 50 or   ---> Saude
     g_documento.ciaempcod = 14 then ---> Previdencia - Funeral

     #-- Selecionar o convenio --#
     if g_cgccpf.acesso = 1 then
         if g_documento.ligcvntip is not null then
               let l_ligcvntip = g_documento.ligcvntip
         else
               let l_ligcvntip = 0
         end if

         let g_cgccpf.acesso = null

         let l_nullo.param2 = g_documento.solnom
         let l_nullo.param3 = g_documento.c24soltipcod

         let g_documento.solnom       = null
         let g_documento.c24soltipcod = null
     else
         let l_ligcvntip = 0
     end if
     let g_documento.ligcvntip = l_ligcvntip

     let l_flag_acesso = cta00m06(g_issk.dptsgl)

     #-- Consultar Porto Card --#
     if l_ligcvntip = 80 and g_issk.acsnivcod > 6 then
        call cta00m50()
     else


        #-- Localizar Apolice --#
        call cta00m01(lr_parm.apoio
                     ,lr_parm.empcodatd
                     ,lr_parm.funmatatd
                     ,lr_parm.usrtipatd
                     ,l_nullo.param1
                     ,l_nullo.param2
                     ,l_nullo.param3
                   # ,lr_parm.c24paxnum)
                     ,g_c24paxnum)
        returning lr_documento.*
                 ,lr_ppt.*
                 ,la_ppt[1].*
                 ,la_ppt[2].*
                 ,la_ppt[3].*
                 ,la_ppt[4].*
                 ,la_ppt[5].*

        ## Flexvision - Pegar hora com segundos
        let g_monitor.dataini = today
        let g_monitor.horafnl = current
        let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini
        if  g_monitor.intervalo is null or
            g_monitor.intervalo = ""    or
            g_monitor.intervalo = " "   or
            g_monitor.intervalo < "0:00:00.000" then
            let g_monitor.intervalo = "0:00:00.999"
        end if

        let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                                  "|CTA00M05-> ", g_issk.funmat,
                                  " ->", g_documento.ciaempcod

        let g_monitor.horaini   = g_monitor.horafnl
        call errorlog (g_monitor.txt)
        let g_monitor.txt = " "

        let  lr_documento.apoio = lr_parm.apoio  ## chamado 5024107

        if lr_documento.ramcod is null then
           return 0
        end if

        let lr_documento.ligcvntip = l_ligcvntip

        if l_flag_acesso = 1 then

           #-- Obter grupo do ramo da apolice --#
          call cty10g00_grupo_ramo(g_issk.empcod
                                  ,lr_documento.ramcod)
          returning l_resultado, l_mensagem, g_documento.ramgrpcod

           #-- Consultar Apolice Transporte --#
           if  lr_documento.flgtransp = 'S' then
               # -- CT 244716 - Katiucia -- #
               let g_documento.c24astcod = null
               call cts27m00(lr_documento.averbacao,"cta00m01" )# PSI183431Daniel
               if g_documento.aplnumdig is null then #global carregadanocts27m00
                  return 0
               end if                 # PSI183431  Daniel FIM
           else

               if (lr_documento.aplnumdig is not null or
                   lr_ppt.cmnnumdig       is not null or
                   lr_documento.prpnumdig is not null) and   #PSI 260479
                  (lr_documento.ramcod <> 991  or
                   lr_documento.ramcod <> 1391 ) then

                  ## Flexvision - Pegar hora com segundos
                  let g_monitor.horafnl = current
                  if  g_monitor.intervalo is null or
                      g_monitor.intervalo = ""    or
                      g_monitor.intervalo = " "   or
                      g_monitor.intervalo < "0:00:00.000" then
                      let g_monitor.intervalo = "0:00:00.999"
                  end if

                  let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini
                  let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                                            "|CTA00M05-> ", g_issk.funmat,
                                            " ->", g_documento.ciaempcod

                  let g_monitor.horaini   = g_monitor.horafnl
                  call errorlog (g_monitor.txt)
                  let g_monitor.txt = " "

                  call cta00m16_chama_prog("ctg18", lr_documento.ramcod,
                                                    lr_documento.succod,
                                                    lr_documento.aplnumdig,
                                                    lr_documento.itmnumdig,
                                                    lr_documento.edsnumref,
                                                    lr_documento.ligcvntip,
                                                    lr_documento.prporg,
                                                    lr_documento.prpnumdig,
                                                    lr_documento.solnom,
                                                    g_documento.ciaempcod,
                                                    g_documento.ramgrpcod,
                                                    g_documento.c24soltipcod,
                                                    g_documento.corsus,
                                                    g_documento.atdnum,
                                                    g_documento.lclnumseq,
                                                    g_documento.rmerscseq,
                                                    g_documento.itaciacod)

                               returning l_status #PSI219967  Amilton Inicio
                  if l_status = -1 then
                       error "Espelho da apolice nao disponivel no momento"
                       sleep 2
                  end if      # PSI219967  Amilton Fim

               end if
           end if

        end if
     end if
     if  l_flag_acesso = 0 and lr_documento.aplnumdig is null then
         return 0
     end if
 else
        ## Flexvision - Pegar hora com segundos Azul
        let g_monitor.dataini = today
        let g_monitor.horafnl = current
        let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini

        if  g_monitor.intervalo is null or
            g_monitor.intervalo = ""    or
            g_monitor.intervalo = " "   or
            g_monitor.intervalo < "0:00:00.000" then
            let g_monitor.intervalo = "0:00:00.999"
        end if


        let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                                  "|CTA00M05-> ", g_issk.funmat,
                                  " ->", g_documento.ciaempcod

        let g_monitor.horaini   = g_monitor.horafnl
        call errorlog (g_monitor.txt)
        let g_monitor.txt = " "

     if  g_documento.ciaempcod = '35' then
          let l_flag_acesso = cta00m06(g_issk.dptsgl)

          if  l_flag_acesso = 1 then
             --[ inclusao de parametros psi209007-contingencia da Azul ]---
             let g_monitor.horaini = current
             call cta00m07_principal(lr_parm.apoio
                                    ,lr_parm.empcodatd
                                    ,lr_parm.funmatatd
                                    ,lr_parm.usrtipatd
                                    ,g_c24paxnum,"","","","","","","","","","","")
                   returning lr_documento.*,
                             l_doc_handle

              let lr_documento.apoio     = lr_parm.apoio
              if l_doc_handle is not null and
                 l_doc_handle <> ' ' then
                 	
                 call cts38m00_extrai_origemcalculo(l_doc_handle)
                 returning l_origem,l_desc
              end if
              if l_origem = '02' then
                 let lr_documento.ligcvntip = 105
                 let g_documento.ligcvntip = 105
              else
                 let lr_documento.ligcvntip = 0     #convenio Porto, p/ Azul nao tem convenio se origem <> 2
              end if

              ## Flexvision - Pegar hora com segundos
              let g_monitor.horafnl = current

              let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini

              if  g_monitor.intervalo is null or
                  g_monitor.intervalo = ""    or
                  g_monitor.intervalo = " "   or
                  g_monitor.intervalo < "0:00:00.000" then
                  let g_monitor.intervalo = "0:00:00.999"
              end if

              let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                                        "|CTA00M05-> ", g_issk.funmat,
                                        " ->", g_documento.ciaempcod

              let g_monitor.horaini   = g_monitor.horafnl
              call errorlog (g_monitor.txt)
              let g_monitor.txt = " "

              if  l_doc_handle is not null then

                  call cta00m16_chama_prog("ctg18", lr_documento.ramcod,
                                                    lr_documento.succod,
                                                    lr_documento.aplnumdig,
                                                    lr_documento.itmnumdig,
                                                    lr_documento.edsnumref,
                                                    lr_documento.ligcvntip,
                                                    lr_documento.prporg,
                                                    lr_documento.prpnumdig,
                                                    lr_documento.solnom,
                                                    g_documento.ciaempcod,
                                                    g_documento.ramgrpcod,
                                                    g_documento.c24soltipcod,
                                                    g_documento.corsus,
                                                    g_documento.atdnum,
                                                    g_documento.lclnumseq,
                                                    g_documento.rmerscseq,
                                                    g_documento.itaciacod)
                               returning l_status #PSI219967  Amilton Inicio
                  if l_status = -1 then
                       error "Espelho da apolice nao disponivel no momento"
                       sleep 2
                  end if      # PSI219967  Amilton Fim

              else
                  return  0
              end if
          else
              return 0
          end if
      else


         # Atendimento Itau

        if  g_documento.ciaempcod = 84 then

            call cta00m05_mostra_empresa(g_documento.ciaempcod)

            call cta00m27(lr_parm.apoio      ,
                          lr_parm.empcodatd  ,
                          lr_parm.funmatatd  ,
                          lr_parm.usrtipatd  ,
                          g_c24paxnum        )
            returning  lr_documento.solnom
                      ,lr_documento.soltip
                      ,lr_documento.c24soltipcod
                      ,lr_documento.ligcvntip
                      ,l_itaciacod
                      ,lr_documento.succod
                      ,lr_documento.ramcod
                      ,lr_documento.aplnumdig
                      ,lr_documento.itmnumdig
                      ,lr_documento.edsnumref
                      ,lr_documento.empcodatd
                      ,lr_documento.funmatatd
                      ,lr_documento.usrtipatd
                      ,lr_documento.corsus
                      ,lr_documento.dddcod
                      ,lr_documento.ctttel
                      ,lr_documento.funmat
                      ,lr_documento.cgccpfnum
                      ,lr_documento.cgcord
                      ,lr_documento.cgccpfdig
                      ,lr_documento.c24paxnum
                      ,l_semdocto


             let lr_documento.apoio = lr_parm.apoio


             if  lr_documento.aplnumdig is not null then

                 call cta00m16_chama_prog("ctg18", lr_documento.ramcod,
                                                   lr_documento.succod,
                                                   lr_documento.aplnumdig,
                                                   lr_documento.itmnumdig,
                                                   lr_documento.edsnumref,
                                                   lr_documento.ligcvntip,
                                                   lr_documento.prporg,
                                                   lr_documento.prpnumdig,
                                                   lr_documento.solnom,
                                                   g_documento.ciaempcod,
                                                   g_documento.ramgrpcod,
                                                   g_documento.c24soltipcod,
                                                   g_documento.corsus,
                                                   g_documento.atdnum,
                                                   g_documento.lclnumseq,
                                                   g_documento.rmerscseq,
                                                   g_documento.itaciacod)
                              returning l_status #PSI219967  Amilton Inicio
                 if l_status = -1 then
                      error "Espelho da apolice nao disponivel no momento"
                      sleep 2
                 end if

		 if lr_documento.ramcod = 14 then #fornax
                    call cty25g01_rec_dados_itau(g_documento.itaciacod ,
                                              lr_documento.ramcod   ,
                                              lr_documento.aplnumdig,
                                              lr_documento.edsnumref,
                                              lr_documento.itmnumdig)
                         returning l_status,
                                   l_msg
		 else
                    call cty22g00_rec_dados_itau(g_documento.itaciacod ,
                                              lr_documento.ramcod   ,
                                              lr_documento.aplnumdig,
                                              lr_documento.edsnumref,
                                              lr_documento.itmnumdig)
                         returning l_status,
                                   l_msg
		 end if

                 if l_status <> 0 then
                      error l_msg sleep 2
                 end if

             else
                if l_semdocto is null then
                   return  0
                end if
             end if

        else
            # Atendimento PSS

            if  g_documento.ciaempcod = 43 then

                call cta00m05_mostra_empresa(g_documento.ciaempcod)

                call cta00m26(lr_parm.apoio      ,
                              lr_parm.empcodatd  ,
                              lr_parm.funmatatd  ,
                              lr_parm.usrtipatd  ,
                              g_c24paxnum        )
                returning lr_documento.solnom       ,
                          lr_documento.soltip       ,
                          lr_documento.c24soltipcod ,
                          lr_documento.ligcvntip    ,
                          lr_documento.empcodatd    ,
                          lr_documento.funmatatd    ,
                          lr_documento.usrtipatd    ,
                          lr_documento.corsus       ,
                          lr_documento.dddcod       ,
                          lr_documento.ctttel       ,
                          lr_documento.funmat       ,
                          lr_documento.cgccpfnum    ,
                          lr_documento.cgcord       ,
                          lr_documento.cgccpfdig    ,
                          lr_documento.c24paxnum    ,
                          l_psscntcod               ,
                          l_semdocto
                          #--------------------------------------------------------
                          # Chama o Processo da Contigencia Online
                          #--------------------------------------------------------
                          call cty42g00(g_documento.ciaempcod ,
                                        "",
                                        "",
                                        "",
                                        "",
                                        lr_documento.cgccpfnum  ,
                                        lr_documento.cgcord     ,
                                        lr_documento.cgccpfdig  ,
                                        "" )

                if l_semdocto is null then
                   if l_psscntcod is null or
                      l_psscntcod = 0     then
                      return 0
                   end if
                end if
             else

                ## Recupero o Convenio

                # Atendimento CGC/CPF

                let g_documento.ligcvntip  = 0

                call cta00m18(lr_parm.apoio      ,
                              lr_parm.empcodatd  ,
                              lr_parm.funmatatd  ,
                              lr_parm.usrtipatd  ,
                              g_c24paxnum        )
                returning lr_documento.*,
                          l_doc_handle  ,
                          l_cod_produto ,
                          l_semdocto

                # Verifico se o Produto tem acesso ao espelho

                if l_cod_produto = 97 or  # Cartao
                   l_cod_produto = 96 or  #Proposta
                   l_cod_produto = 95 or  # Vistoria
                   l_cod_produto = 94 or  # Cobertura
                   l_cod_produto = 25 or  # PSS
                   l_semdocto    = 1  then
                      let l_acesso_esp = false
                end if

                if l_semdocto is null then
                   let l_semdocto = 0
                end if

                let lr_documento.ligcvntip = g_documento.ligcvntip

                if l_acesso_esp = false then
                     case l_cod_produto
                       when 97
                           let g_documento.ciaempcod = 40
                     end case
                else
                     if lr_documento.ramcod is null and
                        l_semdocto          =  0    then
                           return 0
                     end if
                end if


               # Auto , RE, Transporte ou Fianca

               if l_cod_produto = 1  or
                  l_cod_produto = 2  or
                  l_cod_produto = 12 or
                  l_cod_produto = 13 then

                  let g_documento.ciaempcod = 1

                  call cta00m05_mostra_empresa(g_documento.ciaempcod)

                  ## Flexvision - Pegar hora com segundos
                  let g_monitor.horafnl = current
                  let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini
                  if  g_monitor.intervalo is null or
                      g_monitor.intervalo = ""    or
                      g_monitor.intervalo = " "   or
                      g_monitor.intervalo < "0:00:00.000" then
                      let g_monitor.intervalo = "0:00:00.999"
                  end if

                  let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                                            "|CTA00M05-> ", g_issk.funmat,
                                            " ->", g_documento.ciaempcod

                  let g_monitor.horaini   = g_monitor.horafnl
                  call errorlog (g_monitor.txt)
                  let g_monitor.txt = " "

                  call cta00m16_chama_prog("ctg18", lr_documento.ramcod,
                                                    lr_documento.succod,
                                                    lr_documento.aplnumdig,
                                                    lr_documento.itmnumdig,
                                                    lr_documento.edsnumref,
                                                    lr_documento.ligcvntip,
                                                    lr_documento.prporg,
                                                    lr_documento.prpnumdig,
                                                    lr_documento.solnom,
                                                    g_documento.ciaempcod,
                                                    g_documento.ramgrpcod,
                                                    g_documento.c24soltipcod,
                                                    g_documento.corsus,
                                                    g_documento.atdnum,
                                                    g_documento.lclnumseq,
                                                    g_documento.rmerscseq,
                                                    g_documento.itaciacod)
                               returning l_status #PSI219967  Amilton Inicio
                  if l_status = -1 then
                       error "Espelho da apolice nao disponivel no momento"
                       sleep 2
                  end if      # PSI219967  Amilton Fim


               end if


               # Azul

               if l_cod_produto = 99 then
                    let g_documento.ciaempcod = 35

                    call cta00m05_mostra_empresa(g_documento.ciaempcod)

                    let lr_documento.ligcvntip = 0 #convenio Porto, p/ Azul nao tem convenio

                    ## Flexvision - Pegar hora com segundos
                    let g_monitor.horafnl = current
                    let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini
                    if  g_monitor.intervalo is null or
                        g_monitor.intervalo = ""    or
                        g_monitor.intervalo = " "   or
                        g_monitor.intervalo < "0:00:00.000" then
                        let g_monitor.intervalo = "0:00:00.999"
                    end if

                    let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                                              "|CTA00M05-> ", g_issk.funmat,
                                              " ->", g_documento.ciaempcod

                    let g_monitor.horaini   = g_monitor.horafnl
                    call errorlog (g_monitor.txt)
                    let g_monitor.txt = " "


                    call cta00m16_chama_prog("ctg18", lr_documento.ramcod,
                                                      lr_documento.succod,
                                                      lr_documento.aplnumdig,
                                                      lr_documento.itmnumdig,
                                                      lr_documento.edsnumref,
                                                      lr_documento.ligcvntip,
                                                      lr_documento.prporg,
                                                      lr_documento.prpnumdig,
                                                      lr_documento.solnom,
                                                      g_documento.ciaempcod,
                                                      g_documento.ramgrpcod,
                                                      g_documento.c24soltipcod,
                                                      g_documento.corsus,
                                                      g_documento.atdnum,
                                                      g_documento.lclnumseq,
                                                      g_documento.rmerscseq,
                                                      g_documento.itaciacod)
                                 returning l_status #PSI219967  Amilton Inicio
                    if l_status = -1 then
                         error "Espelho da apolice nao disponivel no momento"
                         sleep 2
                    end if      # PSI219967  Amilton Fim

               end if


               # Itau

               if l_cod_produto = 93 then
                    let g_documento.ciaempcod = 84

                    call cta00m05_mostra_empresa(g_documento.ciaempcod)

                    let lr_documento.ligcvntip = 0

                    if  lr_documento.aplnumdig is not null then

                        call cta00m16_chama_prog("ctg18", lr_documento.ramcod,
                                                          lr_documento.succod,
                                                          lr_documento.aplnumdig,
                                                          lr_documento.itmnumdig,
                                                          lr_documento.edsnumref,
                                                          lr_documento.ligcvntip,
                                                          lr_documento.prporg,
                                                          lr_documento.prpnumdig,
                                                          lr_documento.solnom,
                                                          g_documento.ciaempcod,
                                                          g_documento.ramgrpcod,
                                                          g_documento.c24soltipcod,
                                                          g_documento.corsus,
                                                          g_documento.atdnum,
                                                          g_documento.lclnumseq,
                                                          g_documento.rmerscseq,
                                                          g_documento.itaciacod)
                                     returning l_status #PSI219967  Amilton Inicio
                        if l_status = -1 then
                             error "Espelho da apolice nao disponivel no momento"
                             sleep 2
                        end if
			if lr_documento.ramcod = 14 then

                           call cty25g01_rec_dados_itau(g_documento.itaciacod ,
			                                lr_documento.ramcod   ,
						        lr_documento.aplnumdig,
						        lr_documento.edsnumref,
					      	        lr_documento.itmnumdig)
				 returning l_status, l_msg
                        else

                           call cty22g00_rec_dados_itau(g_documento.itaciacod ,
                                                     lr_documento.ramcod   ,
                                                     lr_documento.aplnumdig,
                                                     lr_documento.edsnumref,
                                                     lr_documento.itmnumdig)
                                 returning l_status,
                                           l_msg
	                end if

                        if l_status <> 0 then
                             error l_msg sleep 2
                        end if

                    else
                       if l_semdocto is null then
                          return  0
                       end if
                    end if

               end if

               if l_acesso_esp = true then
                  if  l_flag_acesso = 0 and lr_documento.aplnumdig is null then
                      return 0
                  end if
               end if
            end if
        end if
   end if
 end if

  call cta00m05_mostra_empresa(g_documento.ciaempcod)

 #-- Solicitar Servico --#
 call cta02m00_solicitar_assunto(lr_documento.*,lr_ppt.*)

 # Setar o g_setexplain
  if g_setexplain = 1 then

     call cts01g01_setexplain(g_issk.empcod, g_issk.funmat, 2)
  end if

 return 0

end function

#---------------------------------------#
 function cta00m05_mostra_empresa(l_emp)
#---------------------------------------#

     define l_emp  smallint,
            l_data date

     let l_data = current

     current window is WIN_CAB

     case l_emp
           when 1
             display "CENTRAL 24 HS" at 01,01
             display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
             display l_data       at 01,69
           ---> Funeral - Previdencia
           when 14
             display "CENTRAL 24 HS" at 01,01
             display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
             display l_data       at 01,69
           when 35
             display "CENTRAL 24 HS" at 01,01
             display "        A Z U L  -  S E G U R O S        " AT 1,20
             display l_data       at 01,69
           when 40
             display "CENTRAL 24 HS" at 01,01
             display "      P O R T O S E G  -  C A R T A O    " AT 1,20 attribute(reverse)
             display l_data       at 01,69
           when 43
             display "CENTRAL 24 HS" at 01,01
             display "P O R T O   S E G U R O   S E R V I C O S" AT 1,20 attribute(reverse)
             display l_data       at 01,69
           ---> Saude
           when 50
             display "CENTRAL 24 HS" at 01,01
             display "P O R T O   S E G U R O  -  S A U D E    " AT 1,20
             display l_data       at 01,69
           when 84
             display "CENTRAL 24 HS" at 01,01
             display "         I T A U   S E G U R O S         " AT 1,20 attribute(reverse)
             display l_data       at 01,69
     end case

     current window is WIN_MENU

 end function
