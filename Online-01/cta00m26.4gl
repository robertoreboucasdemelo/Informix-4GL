#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto - Porto Residencia                                   #
# Modulo.........: cta00m26                                                  #
# Objetivo.......: Pesquisa PSS                                              #
# Analista Resp. : Roberto Reboucas                                          #
# PSI            : 218545                                                    #
#............................................................................#
# Desenvolvimento:                                                           #
# Liberacao      :                                                           #
#............................................................................#
# Alteracoes                                                                 #
# 2013-07173  Guilherme      09/10/13  Cadastro de clientes SAPS             #
# 2013-07115  Fabio, Fornax  28/10/13  Identificacao cliente segurado SAPS   #
#............................................................................#
#                         * * * Alteracoes * * *                             #
#   Data     Autor Fabrica   Origem         Alteracao                        #
# ---------- --------------- -------------- ---------------------------------#
# 09/11/2015 INTERA,MarcosMP SPR-2015-22413 Alteracoes:                      #
#                                         1.Excluir 'Atendimento' da tela;   #
#                                         2.Incluir tecla de Funcao para     #
#                                           consulta de CPF do cliente;      #
#                                         3.Chamar funcao de consulta do CPF.#
#----------------------------------------------------------------------------#
# 25/11/2015 INTERA,MarcosMP SPR-2015-23591 Alteracoes:                      #
#----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"
globals "/fontes/controle_ct24h/ct24h_geral/sg_glob5.4gl"  # PSI-2013-07115

define mr_tela record
     solnom        like datmligacao.c24solnom
    ,c24soltipcod  like datmligacao.c24soltipcod
    ,c24soltipdes  char (40)
    ,cpocod        like datkdominio.cpocod
    ,cpodes        like datkdominio.cpodes
    ,pestip        like gsakpes.pestip
    ,tipnom        char(10)
    ,cgccpfnum     like gsakpes.cgccpfnum
    ,cgcord        like gsakpes.cgcord
    ,cgccpfdig     like gsakpes.cgccpfdig
    ,pesnom        like gsakpes.pesnom
    ,psscntcod     like kspmcntrsm.psscntcod
    ,semdocto      char(1)
    ,endlgd        like gsakpesend.endlgd
    ,endnum        like gsakpesend.endnum
    ,endcmp        like gsakpesend.endcmp
    ,endcep        like gsakpesend.endcep
    ,endcepcmp     like gsakpesend.endcepcmp
    ,endbrr        like gsakpesend.endbrr
    ,endcid        like gsakpesend.endcid
    ,endufd        like gsakpesend.endufd
    ,situacao      char(30)
    ,viginc        date
    ,vigfnl        date
    ,obs           char(70)
end record

# PSI 2013-07173
define mr_inad   RECORD
       ipeclinum   like datkipecli.ipeclinum,
       clinom      like datkipecli.clinom,
       celtelnum   like datkipecli.celtelnum,
       telnum      like datkipecli.telnum,
       srvnum      like datripeclisrv.srvnum,
       srvnom      like datripeclisrv.srvnom,
       srvsoldat   like datripeclisrv.srvsoldat,
       rlzsrvano   like datripeclisrv.rlzsrvano,
       continua    char(01),
       cpfcpjnum   char(19)
end record


# PSI 2013-07173

define mr_documento  record
    solnom        char (15),                    # Solicitante
    soltip        char (01),                    # Tipo Solicitante
    c24soltipcod  like datmligacao.c24soltipcod,# Tipo do Solicitante
    ligcvntip     like datmligacao.ligcvntip   ,# Convenio Operacional
    empcodatd     like datmligatd.apoemp       ,# empresa do atendente
    funmatatd     like datmligatd.apomat       ,# matricula do atendente
    usrtipatd     like datmligatd.apotip       ,# tipo do atendente
    corsus        char(06)                     ,#
    dddcod        char(04)                     ,# codigo da area de discagem
    ctttel        char(20)                     ,# numero do telefone
    funmat        decimal(6,0)                 ,# matricula do funcionario
    cgccpfnum     decimal(12,0)                ,# numero do CGC(CNPJ)
    cgcord        decimal(4,0)                 ,# filial do CGC(CNPJ)
    cgccpfdig     decimal(2,0)                 ,# digito do CGC(CNPJ) ou CPF
    c24paxnum     like datmligacao.c24paxnum   ,# Numero da P.A.
    psscntcod     like kspmcntrsm.psscntcod    ,# Numero do Contrato
    semdocto      smallint                      # Sem Documento
end record

define mr_atd record
     semdoctoempcodatd  like datmatd6523.semdoctoempcodatd
    ,semdoctopestip     like datmatd6523.semdoctopestip
    ,semdoctocgccpfnum  like datmatd6523.semdoctocgccpfnum
    ,semdoctocgcord     like datmatd6523.semdoctocgcord
    ,semdoctocgccpfdig  like datmatd6523.semdoctocgccpfdig
    ,semdoctocorsus     like datmatd6523.semdoctocorsus
    ,semdoctofunmat     like datmatd6523.semdoctofunmat
    ,semdoctoempcod     like datmatd6523.semdoctoempcod
    ,semdoctodddcod     like datmatd6523.semdoctodddcod
    ,semdoctoctttel     like datmatd6523.semdoctoctttel
    ,aplnumdig          char(09)
    ,gera               char(01)
    ,novo_nroatd        like datmatd6523.atdnum
end record

define mr_cta00m23 record
      cgccpf     like gsakpes.cgccpfnum ,
      cgcord     like gsakpes.cgcord    ,
      cgccpfdig  like gsakpes.cgccpfdig ,
      pesnom     like gsakpes.pesnom    ,
      pestip     like gsakpes.pestip    ,
      pesnum     like gsakpes.pesnum
end record

define mr_end_pss record
   endlgdtip  like gsakpesend.endlgdtip   ,
   endlgd     like gsakpesend.endlgd      ,
   endnum     like gsakpesend.endnum      ,
   endcmp     like gsakpesend.endcmp      ,
   endcep     like gsakpesend.endcep      ,
   endcepcmp  like gsakpesend.endcepcmp   ,
   endbrr     like gsakpesend.endbrr      ,
   endcid     like gsakpesend.endcid      ,
   endufd     like gsakpesend.endufd
end record

define mr_ant record
      solnom        like datmligacao.c24solnom    ,
      c24soltipcod  like datmligacao.c24soltipcod ,
      c24soltipdes  char (40)
end record

define m_prep_cta00m26 smallint

#----------------------------------#
 function cta00m26_prepare()
#----------------------------------#

   define l_sql char(2000)


   let l_sql = "select a.atdsrvano,                             ",
               "       a.atdsrvnum                              ",
               "from datmligacao a,                             ",
               "     datrcntlig b                               ",
               "where a.lignum = b.lignum                       ",
               "and a.atdsrvano is not null                     ",
               "and a.atdsrvnum is not null                     ",
               "and b.psscntcod = ?                             ",
               "and a.c24astcod = ?                             ",
               "and a.ligdat between ? and ?                    "
   prepare p_cta00m26_001 from l_sql
   declare c_cta00m26_001 cursor for p_cta00m26_001

   let l_sql = "select cpodes    ",
               "from datkdominio ",
               "where cponom = ? "
   prepare pcta00m26003 from l_sql
   declare ccta00m26003 cursor for pcta00m26003

   LET l_sql = " SELECT ipeclinum,clinom , celtelnum , telnum "
              ," FROM   datkipecli "
              ," WHERE  cpfcpjnum = ? "
              ," AND    cpjfilnum = ? "
              ," AND    cpfcpjdig = ? "
	      ," AND    clisitcod = 'A' "
  prepare pcta00m26004 FROM l_sql

   LET l_sql = " SELECT ipeclinum,clinom , celtelnum , telnum "
              ," FROM   datkipecli "
              ," WHERE  cpfcpjnum = ? "
              ," AND    cpfcpjdig = ? "
	      ," AND    clisitcod = 'A' "
  prepare pcta00m26005 FROM l_sql

  LET l_sql = " SELECT max(srvsoldat) "
              ," FROM   datripeclisrv "
              ," WHERE  ipeclinum = ? "
	      ," AND    srvsitcod = ? "
  prepare pcta00m26006 FROM l_sql

  LET l_sql = " SELECT max(srvnum) "
              ," FROM   datripeclisrv "
              ," WHERE  ipeclinum = ? "
              ," AND    srvsoldat = ? "
	      ," AND    srvsitcod = ? "
  prepare pcta00m26007 FROM l_sql

  LET l_sql = " SELECT rlzsrvano,srvnom "
              ," FROM   datripeclisrv "
              ," WHERE  ipeclinum = ? "
              ," AND    srvnum    = ? "
              ," AND    srvsoldat = ? "
  prepare pcta00m26008 FROM l_sql

  let m_prep_cta00m26 = true

 end function

#----------------------------------#
 function cta00m26(lr_param)
#----------------------------------#

define lr_param  record
       apoio     char(01),
       empcodatd like isskfunc.empcod,
       funmatatd like isskfunc.funmat,
       usrtipatd like issmnivnovo.usrtip,
       c24paxnum integer
end record


   open window w_cta00m26 at 3,2 with form "cta00m26"
      attribute(menu line 1)
   call cta00m26_input(lr_param.apoio      ,
                       lr_param.empcodatd  ,
                       lr_param.funmatatd  ,
                       lr_param.usrtipatd  ,
                       lr_param.c24paxnum  )

   close window w_cta00m26

   let int_flag = false

   return mr_documento.*

 end function

#-------------------------------#
 function cta00m26_input(lr_param)
#-------------------------------#

define lr_param  record
       apoio     char(01),
       empcodatd like isskfunc.empcod,
       funmatatd like isskfunc.funmat,
       usrtipatd like issmnivnovo.usrtip,
       c24paxnum integer
end record

define lr_retorno record
   tamanho   integer                 ,
   cgccpfdig like gsakpes.cgccpfdig  ,
   resultado smallint                ,
   flag_atd  char(01)
end record

define lr_aux record
       resultado  smallint                  ,
       mensagem   char(60)                  ,
       acsnivcod  like issmnivnovo.acsnivcod,
       c24paxtxt  char(12)                  ,
       ciaempcod  like datmatd6523.ciaempcod
end record

#=> SPR-2015-22413 - RETORNO CPF/CNPJ
define lr_retcpf record
       errcod        smallint
      ,msg           char(80)
      ,cgccpfnum     like gsakpes.cgccpfnum
      ,cgcord        like gsakpes.cgcord
      ,cgccpfdig     like gsakpes.cgccpfdig
end record
#=> SPR-2015-22413 - POP-UP DE DOMINIOS DO TIPO DE SOLICITANTE
define lr_popup          record
       lin               smallint   # Nro da linha
      ,col               smallint   # Nro da coluna
      ,titulo            char (054) # Titulo do Formulario
      ,tit2              char (012) # Titulo da 1a.coluna
      ,tit3              char (040) # Titulo da 2a.coluna
      ,tipcod            char (001) # Tipo do Codigo a retornar ('N' ou 'A')
      ,cmd_sql           char (1999)# Comando SQL p/ pesquisa
      ,aux_sql           char (200) # Complemento SQL apos where
      ,tipo              char (001) # Tipo de Popup ('D', 'E', 'X', '1' ou '2')
end record
define lr_out            record
       erro              smallint   # 0 (ok) / 1 (notfound) / < 0 (erro)
      ,cod               char (011) # Codigo
      ,dsc               char (040) # Descricao
end record

 clear form
 initialize mr_ant.* ,
            mr_documento.* to null

 while true

 initialize lr_retorno.*   ,
            mr_atd.*       ,
            mr_tela.*      ,
            mr_cta00m23.*  ,
            lr_aux.*       ,
            mr_end_pss     ,
            g_pss.*        to null

 let mr_tela.semdocto       = "N"
 let lr_retorno.flag_atd    = "N"


   input by name mr_tela.* without defaults

      before input  #=> SPR-2015-22413 - RETIRAR 'ATDNUM' DA TELA

         if mr_ant.solnom       is not null and
            mr_ant.c24soltipcod is not null and
            mr_ant.c24soltipdes is not null then
            call cta00m26_carrega_anterior(1)
            initialize mr_ant.* to null
            call cta00m26_exibe_tela()
            next field cpocod
         end if

         # carrega global com flag sem docto           #PSI234915
         let g_documento.semdocto = mr_tela.semdocto

#--------------------------------------------------------------------------------------
# BEFORE SOLNOM
#--------------------------------------------------------------------------------------

      before field solnom

         let mr_documento.empcodatd = lr_param.empcodatd
         let mr_documento.funmatatd = lr_param.funmatatd
         let mr_documento.usrtipatd = lr_param.usrtipatd

         if lr_param.apoio = "S" then
            call cty08g00_nome_func(lr_param.empcodatd
                                   ,lr_param.funmatatd
                                   ,lr_param.usrtipatd)
               returning lr_aux.resultado
                        ,lr_aux.mensagem
                        ,mr_tela.solnom

          if lr_aux.resultado = 3 then
               call errorlog(lr_aux.mensagem)
               exit input
            else
             if lr_aux.resultado = 2 then
                  call errorlog(lr_aux.mensagem)
               end if
            end if

            let mr_tela.c24soltipcod      = 6
            let mr_tela.c24soltipdes      = "APOIO"
            let mr_documento.c24soltipcod = mr_tela.c24soltipcod
            let mr_documento.solnom       = mr_tela.solnom

            display by name mr_tela.c24soltipcod
            display by name mr_tela.c24soltipdes
            display by name mr_tela.solnom
            next field cpocod

         end if

         display by name mr_tela.solnom  attribute (reverse)

#--------------------------------------------------------------------------------------
# AFTER SOLNOM
#--------------------------------------------------------------------------------------
      after field solnom

         display by name mr_tela.solnom

       if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field solnom  #=> SPR-2015-22413
       end if

       if mr_tela.solnom is null then
          error 'Nome do solicitante deve ser informado!'
          next field solnom
       end if

       let mr_documento.solnom = mr_tela.solnom

#--------------------------------------------------------------------------------------
# BEFORE C24SOLTIPCOD
#--------------------------------------------------------------------------------------
      before field c24soltipcod
          display by name mr_tela.c24soltipcod attribute (reverse)

#--------------------------------------------------------------------------------------
# AFTER C24SOLTIPCOD
#--------------------------------------------------------------------------------------
      after field c24soltipcod

         display by name mr_tela.c24soltipcod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field solnom
         end if

         #-- Exibe popup dos tipos de solicitante --#
         if mr_tela.c24soltipcod is null then
            error "Tipo do solicitante deve ser informado!"

            #=> SPR-2015-23591: SUGERIR TIPOS CADASTRADOS NO DOMINIO
            let lr_popup.lin     = 10
            let lr_popup.col     = 23
            let lr_popup.titulo  = "Selecione o TIPO DE SOLICITANTE"
            let lr_popup.tit2    = "Codigo"
            let lr_popup.tit3    = "Descricao"
            let lr_popup.tipcod  = "A"
            let lr_popup.cmd_sql = "select cpocod, cpodes[1,20]",
                                   "  from iddkdominio",
                                   " where cponom = 'vnd.c24soltipcod'",
                                   " order by 2"
            let lr_popup.aux_sql = ""
            let lr_popup.tipo    = "D"
            call ofgrc001_popup (lr_popup.*)
                 returning lr_out.*
            if lr_out.erro <> 0 then
               if lr_out.erro < 0 then
                  let lr_aux.mensagem = "ERRO ", lr_out.erro,
                                        " NO POP-UP DE TIPOS DE SOLICITANTE"
                  error lr_aux.mensagem clipped
                  sleep 2
                  call errorlog(lr_aux.mensagem)
                  exit input
               end if
               error "Nenhum Tipo de Solicitante selecionado..."
               next field c24soltipcod
            end if
            let mr_tela.c24soltipcod = lr_out.cod
            display by name mr_tela.c24soltipcod
         end if

         #-- Busca a Descrição do Tipo do Solicitante --#
         call cto00m00_nome_solicitante(mr_tela.c24soltipcod, 1)
              returning lr_aux.resultado
                       ,lr_aux.mensagem
                       ,mr_tela.c24soltipdes

         if lr_aux.resultado <> 1 then
            error lr_aux.mensagem
            next field c24soltipcod
         else
            display by name mr_tela.c24soltipdes
            if mr_tela.c24soltipcod < 3 then
               let mr_documento.soltip = mr_tela.c24soltipdes[1,1]
            else
               let mr_documento.soltip = "O"
            end if
         end if

         let mr_documento.c24soltipcod = mr_tela.c24soltipcod

         if lr_param.c24paxnum is null and g_issk.acsnivcod = 6 then
            #Obter nivel do funcionario
            call cty08g00_nivel_func(g_issk.usrtip
                                    ,g_issk.empcod
                                    ,g_issk.usrcod
                                    ,'pso_ct24h')
                 returning lr_aux.resultado
                          ,lr_aux.mensagem
                          ,lr_aux.acsnivcod
            if lr_aux.acsnivcod is null then
                while lr_param.c24paxnum is null
                   # Obter nr. do pax
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

          # Se carregou dados pelo Nro Atendimento sai do Input
          # apos entrar na tela de sem Doctos, pois ja confirmou nela
         if mr_tela.semdocto = "S" then

            let g_documento.atdnum     = null
            let g_documento.empcodmat  = mr_atd.semdoctoempcodatd
            let g_documento.corsus     = mr_atd.semdoctocorsus
            let g_documento.dddcod     = mr_atd.semdoctodddcod
            let g_documento.ctttel     = mr_atd.semdoctoctttel
            let g_documento.funmat     = mr_atd.semdoctofunmat
            let g_documento.cgccpfnum  = mr_atd.semdoctocgccpfnum
            let g_documento.cgcord     = mr_atd.semdoctocgcord
            let g_documento.cgccpfdig  = mr_atd.semdoctocgccpfdig

            call cta10m00_entrada_dados()
            call cta00m26_carrega_modular()

            if mr_documento.corsus    is null and
               mr_documento.dddcod    is null and
               mr_documento.ctttel    is null and
               mr_documento.funmat    is null and
               mr_documento.cgccpfnum is null and
               mr_documento.cgcord    is null and
               mr_documento.cgccpfdig is null then
               error 'Faltam informacoes para registrar Ligacao sem Docto.'
               sleep 2
               next field solnom  #=> SPR-2015-22413
            else
               exit input
            end if
         end if

#--------------------------------------------------------------------------------------
# BEFORE CPOCOD
#--------------------------------------------------------------------------------------
     before field cpocod

        #=> SPR-2015-22413 - SUGERIR '0' P/ CPOCOD
        if mr_tela.cpocod is null then
           let mr_tela.cpocod = 0
        end if
        display by name mr_tela.cpocod attribute (reverse)

#--------------------------------------------------------------------------------------
# AFTER CPOCOD
#--------------------------------------------------------------------------------------
    after field cpocod
       display by name mr_tela.cpocod

       if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field c24soltipcod
       end if


       if mr_tela.cpocod is null then
          let mr_tela.cpocod = cta00m00_convenios()

          if mr_tela.cpocod is null then
             error "Por favor Informe o Convenio!"
             next field cpocod
          end if

       end if

       call cta00m00_recupera_convenio(mr_tela.cpocod)
       returning mr_tela.cpodes

       if mr_tela.cpodes is null then
          error "Convenio Inexistente!" sleep 1

          let mr_tela.cpocod = cta00m00_convenios()

          if mr_tela.cpocod is null then
             next field cpocod
          end if

          call cta00m00_recupera_convenio(mr_tela.cpocod)
          returning mr_tela.cpodes

       end if

       let g_documento.ligcvntip  = mr_tela.cpocod
       let mr_documento.ligcvntip = mr_tela.cpocod

       display by name mr_tela.cpocod
       display by name mr_tela.cpodes


#--------------------------------------------------------------------------------------
# BEFORE PESTIP
#--------------------------------------------------------------------------------------
      before field pestip

         if mr_tela.pestip is null then
            let mr_tela.pestip = "F"
         end if

         display by name mr_tela.pestip attribute(reverse)

#--------------------------------------------------------------------------------------
# AFTER PESTIP
#--------------------------------------------------------------------------------------
      after field pestip
         display by name mr_tela.pestip

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize mr_tela.cgccpfnum  to null
            initialize mr_tela.cgcord     to null
            initialize mr_tela.cgccpfdig  to null
            display by name mr_tela.cgccpfnum
            display by name mr_tela.cgcord
            display by name mr_tela.cgccpfdig
            next field cpocod
         end if

         if (mr_tela.pestip <>  "F"      and
             mr_tela.pestip <>  "J" )    or
             mr_tela.pestip is null      then
            error " Tipo de Pessoa Invalido!"
            next field pestip
         end if

         case  mr_tela.pestip
            when "J"
                let mr_tela.tipnom = "JURIDICA"
            when "F"
                let mr_tela.tipnom = "FISICA"
         end case

         display by name mr_tela.tipnom

#--------------------------------------------------------------------------------------
# BEFORE CGCCPFNUM
#--------------------------------------------------------------------------------------
      before field cgccpfnum
         display by name mr_tela.cgccpfnum  attribute(reverse)

         #=> SPR-2015-22413 - DISPONIBILIZAR TECLA DE FUNCAO P/ ENCONTRAR CPF
      let mr_tela.obs = "                               (F6) Localiza Protocolo"
         display by name mr_tela.obs

#--------------------------------------------------------------------------------------
# AFTER CGCCPFNUM
#--------------------------------------------------------------------------------------
      after field cgccpfnum
         display by name mr_tela.cgccpfnum

         #=> SPR-2015-22413 - DISPONIBILIZAR TECLA DE FUNCAO P/ ENCONTRAR CPF
         let mr_tela.obs = " "
         display by name mr_tela.obs

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field pestip
         end if

         if mr_tela.cgccpfnum is null then
            initialize mr_tela.cgcord     to null
            initialize mr_tela.cgccpfdig  to null
            display by name mr_tela.cgcord
            display by name mr_tela.cgccpfdig

            # Convenio Venda de Servico e Jac Motors
            if mr_tela.cpocod = 0 or
               mr_tela.cpocod = 2 or
               mr_tela.cpocod = 3 or
               mr_tela.cpocod = 4 then
               error "CPF/CNPJ Obrigatorio!"
               next field cgccpfnum
            else
               next field pesnom
            end if
         end if

         if mr_tela.pestip =  "F"   then
            next field cgccpfdig
         end if

#--------------------------------------------------------------------------------------
# BEFORE CGCORD
#--------------------------------------------------------------------------------------
      before field cgcord
         display by name mr_tela.cgcord attribute(reverse)

#--------------------------------------------------------------------------------------
# AFTER CGCORD
#--------------------------------------------------------------------------------------

      after field cgcord

         display by name mr_tela.cgcord

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            next field cgccpfnum
         end if

         if mr_tela.cgcord   is null   or
            mr_tela.cgcord   =  0      then
            error " Filial do CGC deve ser informada!"
            next field cgcord
         end if

#--------------------------------------------------------------------------------------
# BEFORE CGCCPFDIG
#--------------------------------------------------------------------------------------
      before field cgccpfdig
         display by name mr_tela.cgccpfdig attribute(reverse)

#--------------------------------------------------------------------------------------
# AFTER CGCCPFDIG
#--------------------------------------------------------------------------------------
      after field cgccpfdig

         display by name mr_tela.cgccpfdig

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            if mr_tela.pestip =  "J"  then
               next field cgcord
            else
               next field cgccpfnum
            end if
         end if

         if mr_tela.cgccpfdig   is null   then
            error " Digito do CGC/CPF Deve ser Informado!"
            next field cgccpfdig
         end if

         if mr_tela.pestip =  "J"    then
            call F_FUNDIGIT_DIGITOCGC(mr_tela.cgccpfnum,
                                      mr_tela.cgcord)
                 returning lr_retorno.cgccpfdig
         else
            call F_FUNDIGIT_DIGITOCPF(mr_tela.cgccpfnum)
                 returning lr_retorno.cgccpfdig
         end if

         if lr_retorno.cgccpfdig  is null                  or
            mr_tela.cgccpfdig     <>  lr_retorno.cgccpfdig then
            error " Digito do CGC/CPF Incorreto!"
            next field cgccpfdig
         else
            # PSI 2013-07173
            # verificar se cliente esta inadimplente
            if mr_tela.cpocod = 0 then
               if m_prep_cta00m26 is null or
                  m_prep_cta00m26 <> true then
                  call cta00m26_prepare()
               end if
               call cta00m26_cliinad()
               if mr_inad.continua = 'N' then
                  clear form
                  error "Atendimento Cancelado"
                  initialize mr_tela.*, mr_documento.* to null
                  exit while
               end if
            end if

            # PSI 2013-07115
            # na inclusao de servico SAPS verificar se o cliente ja é cliente da cia e entao obter dados cadastrais
            if mr_tela.cpocod = 0 then
               call ctc68m00(mr_tela.cgccpfnum ,
                             mr_tela.cgcord    ,
                             mr_tela.cgccpfdig ,
                             mr_tela.pestip)
            end if

            # Convenio Venda de Servico E Jac Motors
            if mr_tela.cpocod = 0 or
               mr_tela.cpocod = 2 or
               mr_tela.cpocod = 3 or
               mr_tela.cpocod = 4 then

               if mr_tela.pestip = "F" then
                  let mr_tela.cgcord = 0
               end if

               let g_documento.cgccpfnum  = mr_tela.cgccpfnum
               let g_documento.cgccpfdig  = mr_tela.cgccpfdig
               let g_documento.cgcord     = mr_tela.cgcord


               let g_documento.semdocto   = "S"
               let mr_tela.semdocto       = "S"
               call cta00m26_carrega_modular()
            end if

            exit input
         end if

#--------------------------------------------------------------------------------------
# BEFORE PESNOM
#--------------------------------------------------------------------------------------
      before field pesnom
         display by name mr_tela.pesnom attribute(reverse)

#--------------------------------------------------------------------------------------
# AFTER PESNOM
#--------------------------------------------------------------------------------------

      after field pesnom
         display by name mr_tela.pesnom

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            if mr_tela.cgccpfdig is not null then
                next field cgccpfdig
            else
                next field cgccpfnum
            end if
         end if

         if mr_tela.pesnom is not null then
            let lr_retorno.tamanho = (length (mr_tela.pesnom))
            if  lr_retorno.tamanho < 10  then
                error " Complemente o nome do segurado (minimo 10 caracteres)!"
                next field pesnom
            else
                exit input
            end if
         end if

#--------------------------------------------------------------------------------------
# BEFORE PSSCNTCOD
#--------------------------------------------------------------------------------------
      before field psscntcod
         display by name mr_tela.psscntcod attribute(reverse)


#--------------------------------------------------------------------------------------
# AFTER PSSCNTCOD
#--------------------------------------------------------------------------------------
      after field psscntcod
         display by name mr_tela.psscntcod

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field pesnom
         end if

         if mr_tela.psscntcod is not null then

             call pss01g00_consulta_CNPJ(mr_tela.psscntcod)
             returning mr_tela.cgccpfnum,
                       mr_tela.cgcord   ,
                       mr_tela.cgccpfdig,
                       lr_aux.resultado ,
                       lr_aux.mensagem

             if lr_aux.resultado = 2 then
                error lr_aux.mensagem
                next field psscntcod
             else
                exit input
             end if

         end if

#--------------------------------------------------------------------------------------
# BEFORE SEMDOCTO
#--------------------------------------------------------------------------------------
      before field semdocto
         display by name mr_tela.semdocto  attribute (reverse)

#--------------------------------------------------------------------------------------
# AFTER SEMDOCTO
#--------------------------------------------------------------------------------------
      after field semdocto
         display by name mr_tela.semdocto

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field psscntcod
         end if

         if mr_tela.semdocto is null then
            next field semdocto
         else
            if mr_tela.semdocto <> "S" then
               error 'Opcao invalida, digite "S" para ligacao Sem Docto.'
               sleep 2
               next field semdocto
            else
               let g_documento.atdnum = null  #=> SPR-2015-22413
               call cta10m00_entrada_dados()
               call cta00m26_carrega_modular()

               if mr_documento.corsus    is null and
                  mr_documento.dddcod    is null and
                  mr_documento.ctttel    is null and
                  mr_documento.funmat    is null and
                  mr_documento.cgccpfnum is null and
                  mr_documento.cgcord    is null and
                  mr_documento.cgccpfdig is null then
                  error 'Faltam informacoes para registrar Ligacao sem Docto.' sleep 2
                  next field semdocto
               else
                  let g_documento.semdocto = mr_tela.semdocto
                  exit input
               end if
            end if
         end if

      on key(control-c,f17,interrupt)
         clear form
         initialize mr_tela.*, mr_documento.* to null
         exit while

      #=> SPR-2015-22413 - F6 PARA ABRIR TELA DE PESQUISA DE CPF/CNPJ
      on key(f6)
         if infield(cgccpfnum) then
            call opsfc040()
                 returning lr_retcpf.*
            if lr_retcpf.errcod <> 0 then
               error lr_retcpf.msg clipped
               next field cgccpfnum
            end if
            if lr_retcpf.cgccpfnum is not null and
               lr_retcpf.cgccpfnum <> 0        then
               let mr_tela.cgccpfnum = lr_retcpf.cgccpfnum
               let mr_tela.cgcord    = lr_retcpf.cgcord
               let mr_tela.cgccpfdig = lr_retcpf.cgccpfdig
               display by name mr_tela.cgccpfnum
               display by name mr_tela.cgcord
               display by name mr_tela.cgccpfdig
            end if
         end if

   end input

     if lr_retorno.flag_atd = "N" then

       if g_documento.semdocto = "S" then

          let mr_documento.semdocto = 1
          call cta00m26_guarda_globais()
          call cta00m26_gera_atendimento()

          exit while
       else
           call cta00m23_rec_cliente(mr_tela.pesnom    ,
                                     mr_tela.pestip    ,
                                     mr_tela.cgccpfnum ,
                                     mr_tela.cgcord    ,
                                     mr_tela.cgccpfdig )
           returning mr_cta00m23.cgccpf     ,
                     mr_cta00m23.cgcord     ,
                     mr_cta00m23.cgccpfdig  ,
                     mr_cta00m23.pesnom     ,
                     mr_cta00m23.pestip     ,
                     mr_documento.psscntcod ,
                     mr_cta00m23.pesnum     ,
                     lr_retorno.resultado
       end if
     else
        let lr_retorno.flag_atd = "N"
     end if

   case lr_retorno.resultado
      when 0
           # Recupera o Endereco do Cliente
           call cta00m25_endereco_pss(mr_cta00m23.pesnum)
           returning  mr_end_pss.endlgdtip  ,
                      mr_end_pss.endlgd     ,
                      mr_end_pss.endnum     ,
                      mr_end_pss.endcmp     ,
                      mr_end_pss.endufd     ,
                      mr_end_pss.endbrr     ,
                      mr_end_pss.endcid     ,
                      mr_end_pss.endcep     ,
                      mr_end_pss.endcepcmp

           call cta00m25_carrega_global( mr_end_pss.endlgdtip
                                        ,mr_end_pss.endlgd
                                        ,mr_end_pss.endnum
                                        ,mr_end_pss.endcmp
                                        ,mr_end_pss.endufd
                                        ,mr_end_pss.endbrr
                                        ,mr_end_pss.endcid
                                        ,mr_end_pss.endcep
                                        ,mr_end_pss.endcepcmp)
           call cta00m26_carrega_tela()
           call cta00m26_exibe_tela()
           call cta00m26_espera()
           call cta00m26_guarda_globais()
           call cta00m26_gera_atendimento()
           exit while
      when 1
           clear form
           call cta00m26_carrega_anterior(2)
           continue while
      when 2
           clear form
           call cta00m26_carrega_anterior(2)
           continue while
      when 3
           error "Nenhum Cliente Foi Localizado!"
           clear form
           call cta00m26_carrega_anterior(2)
           continue while
   end case
 end while

 let int_flag = false

end function

#INICIO  PSI  2013-07173
#---------------------------
function cta00m26_cliinad()
#---------------------------
    IF  mr_tela.pestip =  "J" then
        EXECUTE pcta00m26004 INTO mr_inad.ipeclinum,
			          mr_inad.clinom ,
				  mr_inad.celtelnum ,
				  mr_inad.telnum
			     USING mr_tela.cgccpfnum,
	                           mr_tela.cgcord,
			           mr_tela.cgccpfdig
        LET mr_inad.cpfcpjnum = mr_tela.cgccpfnum using "&&&&&&&&&","/",
				mr_tela.cgcord    using "&&&&","-",
				mr_tela.cgccpfdig using "&&"
    ELSE
        EXECUTE pcta00m26005 INTO mr_inad.ipeclinum,
			          mr_inad.clinom ,
			          mr_inad.celtelnum ,
			          mr_inad.telnum
			     USING  mr_tela.cgccpfnum,
			            mr_tela.cgccpfdig
        LET mr_inad.cpfcpjnum[6,19] = mr_tela.cgccpfnum using "&&&&&&&&&","-",
			              mr_tela.cgccpfdig using "&&"
    END IF
    if sqlca.sqlcode  = 100 then
       LET mr_inad.continua = "S"
       RETURN
    end if

    execute pcta00m26006 INTO  mr_inad.srvsoldat
		         USING mr_inad.ipeclinum, "I"

    IF STATUS = NOTFOUND OR
      (mr_inad.srvsoldat IS NULL OR
       mr_inad.srvsoldat = ' ' )  THEN
       execute pcta00m26006 INTO  mr_inad.srvsoldat
	                    USING mr_inad.ipeclinum, "P"
    END IF

    execute pcta00m26007 INTO  mr_inad.srvnum
	                 USING mr_inad.ipeclinum,
		               mr_inad.srvsoldat, "I"
    IF status = notfound OR
      (mr_inad.srvnum IS NULL OR
       mr_inad.srvnum = ' '   OR
       mr_inad.srvnum = 0)    THEN
       execute pcta00m26007 INTO  mr_inad.srvnum
	                    USING mr_inad.ipeclinum,
		                  mr_inad.srvsoldat, "P"
    END IF


    execute pcta00m26008 INTO  mr_inad.rlzsrvano,
		               mr_inad.srvnom
	                 USING mr_inad.ipeclinum,
		               mr_inad.srvnum,
		               mr_inad.srvsoldat

    open window w_ctc67m04 at 09,04 with form "ctc67m04"
         attribute(border, form line first, message line last - 1)
         display by name  mr_inad.clinom
         display by name  mr_inad.cpfcpjnum
         display by name  mr_inad.celtelnum
         display by name  mr_inad.telnum
         display by name  mr_inad.srvnum
         display by name  mr_inad.rlzsrvano
         display by name  mr_inad.srvnom

    open window m_ctc67m04 at 20,32 with 02 rows, 20 columns
         menu ""


            command key ("N", interrupt) "NAO"
	               error " Confirmacao cancelada!"
		       initialize mr_inad.* to null
		       LET mr_inad.continua = 'N'
	               exit menu
	    command key ("S")            "SIM"
	               let mr_inad.continua = "S"
	               exit menu
	 end menu
	 close window m_ctc67m04
	 close window w_ctc67m04

end function
# FIM PSI 2013-07173

#-----------------------------------------------------------------------------
function cta00m26_carrega_modular()
#-----------------------------------------------------------------------------

  let mr_documento.corsus      = g_documento.corsus
  let mr_documento.dddcod      = g_documento.dddcod
  let mr_documento.ctttel      = g_documento.ctttel
  let mr_documento.funmat      = g_documento.funmat
  let mr_documento.cgccpfnum   = g_documento.cgccpfnum
  let mr_documento.cgcord      = g_documento.cgcord
  let mr_documento.cgccpfdig   = g_documento.cgccpfdig
  let mr_atd.semdoctocorsus    = g_documento.corsus
  let mr_atd.semdoctodddcod    = g_documento.dddcod
  let mr_atd.semdoctoctttel    = g_documento.ctttel
  let mr_atd.semdoctofunmat    = g_documento.funmat
  let mr_atd.semdoctocgccpfnum = g_documento.cgccpfnum
  let mr_atd.semdoctocgcord    = g_documento.cgcord
  let mr_atd.semdoctocgccpfdig = g_documento.cgccpfdig
  let mr_atd.semdoctofunmat    = g_documento.funmat
  let mr_atd.semdoctoempcod    = g_documento.empcodmat
  let mr_atd.semdoctoempcodatd = g_documento.empcodatd

end function

#-----------------------------------------------------------------------------
function cta00m26_guarda_globais()
#-----------------------------------------------------------------------------
   initialize g_documento.solnom       ,
              g_documento.atdnum       ,
              g_documento.c24soltipcod ,
              g_documento.soltip       ,
              g_documento.empcodatd    ,
              g_documento.funmatatd    ,
              g_documento.usrtipatd    ,
              g_documento.corsus       ,
              g_documento.dddcod       ,
              g_documento.ctttel       ,
              g_documento.funmat       ,
              g_documento.cgccpfnum    ,
              g_documento.cgcord       ,
              g_documento.cgccpfdig    ,
              g_pss.psscntcod          ,
              g_pss.nom                to null

   let g_c24paxnum              = mr_documento.c24paxnum
   let g_documento.solnom       = mr_documento.solnom
   let g_documento.atdnum       = null  #=> SPR-2015-22413
   let g_documento.c24soltipcod = mr_documento.c24soltipcod
   let g_documento.soltip       = mr_documento.soltip
   let g_documento.empcodatd    = mr_documento.empcodatd
   let g_documento.funmatatd    = mr_documento.funmatatd
   let g_documento.usrtipatd    = mr_documento.usrtipatd
   let g_documento.ligcvntip    = mr_documento.ligcvntip
   let g_documento.corsus       = mr_documento.corsus
   let g_documento.dddcod       = mr_documento.dddcod
   let g_documento.ctttel       = mr_documento.ctttel
   let g_documento.funmat       = mr_documento.funmat
   let g_documento.cgccpfnum    = mr_documento.cgccpfnum
   let g_documento.cgcord       = mr_documento.cgcord
   let g_documento.cgccpfdig    = mr_documento.cgccpfdig
   let g_pss.psscntcod          = mr_documento.psscntcod
   let g_pss.nom                = mr_tela.pesnom

end function

#-----------------------------------------------------------------------------
function cta00m26_carrega_tela()
#-----------------------------------------------------------------------------

   let mr_tela.cgccpfnum   =  mr_cta00m23.cgccpf
   let mr_tela.cgcord      =  mr_cta00m23.cgcord
   let mr_tela.cgccpfdig   =  mr_cta00m23.cgccpfdig
   let mr_tela.pesnom      =  mr_cta00m23.pesnom
   let mr_tela.pestip      =  mr_cta00m23.pestip
   let mr_tela.psscntcod   =  mr_documento.psscntcod
   let mr_tela.endlgd      =  mr_end_pss.endlgdtip clipped, " ", mr_end_pss.endlgd
   let mr_tela.endnum      =  mr_end_pss.endnum
   let mr_tela.endcmp      =  mr_end_pss.endcmp
   let mr_tela.endcep      =  mr_end_pss.endcep
   let mr_tela.endcepcmp   =  mr_end_pss.endcepcmp
   let mr_tela.endbrr      =  mr_end_pss.endbrr
   let mr_tela.endcid      =  mr_end_pss.endcid
   let mr_tela.endufd      =  mr_end_pss.endufd
   let mr_tela.situacao    =  g_pss.situacao
   let mr_tela.viginc      =  g_pss.viginc
   let mr_tela.vigfnl      =  g_pss.vigfnl
   let mr_tela.obs         =  "                               (F17) Prosseguir"

end function

#-----------------------------------------------------------------------------
function cta00m26_exibe_tela()
#-----------------------------------------------------------------------------
   display by name mr_tela.c24soltipcod
   display by name mr_tela.c24soltipdes
   display by name mr_tela.solnom
   display by name mr_tela.cgccpfnum
   display by name mr_tela.cgcord
   display by name mr_tela.cgccpfdig
   display by name mr_tela.pesnom
   display by name mr_tela.pestip
   display by name mr_tela.tipnom
   display by name mr_tela.psscntcod
   display by name mr_tela.endlgd
   display by name mr_tela.endnum
   display by name mr_tela.endcmp
   display by name mr_tela.endcep
   display by name mr_tela.endcepcmp
   display by name mr_tela.endbrr
   display by name mr_tela.endcid
   display by name mr_tela.endufd
   display by name mr_tela.situacao
   display by name mr_tela.viginc
   display by name mr_tela.vigfnl
   display by name mr_tela.obs

end function

#-----------------------------------------------------------------------------
function cta00m26_espera()
#-----------------------------------------------------------------------------
define lr_retorno record
   espera char(01)
end record

  # -> FUNCAO PARA AGUARDAR UMA ACAO DO USUARIO
  initialize lr_retorno.* to null
  input lr_retorno.espera without defaults from espera
     after field espera
        next field espera
     on key(f17, control-c, interrupt)
        exit input
  end input

end function

#-----------------------------------------------------------------------------
function cta00m26_gera_atendimento()
#-----------------------------------------------------------------------------

define lr_aux record
   gera      char(01) ,
   confirma  char(01) ,
   resultado smallint ,
   mensagem  char(70) ,
   linha1    char(40) ,
   linha2    char(40) ,
   linha3    char(40) ,
   atdnum    like datmatd6523.atdnum,
   premium   char(01)
end record

initialize lr_aux.* to null
   let lr_aux.gera = "S" ---> Gera novo Atendimento
   #Gera atendimento para todos os níveis
   {if g_issk.acsnivcod >= 7   then
      call cts08g01 ("A","S","",
                     "DESEJA GERAR UM NOVO ATENDIMENTO ? ","","")
           returning lr_aux.confirma
      if lr_aux.confirma = "N" then
         let lr_aux.gera   = "N" ---> Nao quer gerar novo Atendimento
         let g_gera_atd = "N"
         initialize g_documento.atdnum  to null
      end if
   end if}

   ---> Gera Numero de Atendimento
   if lr_aux.gera = "S" then
      ---> Se nao ha docto trata variaveis p/ nao gravar em campos indevidos
      if mr_tela.semdocto = "S" then
         let g_documento.cgccpfnum = null
         let g_documento.cgcord    = null
         let g_documento.cgccpfdig = null
         let g_documento.corsus    = null
         let mr_cta00m23.cgccpf     = null
         let mr_cta00m23.cgcord     = null
         let mr_cta00m23.cgccpfdig  = null
      end if
      begin work
      call ctd24g00_ins_atd(""                      ---> atdnum
                           ,g_documento.ciaempcod
                           ,g_documento.solnom
                           ,""
                           ,g_documento.c24soltipcod
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,mr_tela.pesnom
                           ,mr_tela.pestip
                           ,mr_cta00m23.cgccpf
                           ,mr_cta00m23.cgcord
                           ,mr_cta00m23.cgccpfdig
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,g_documento.semdocto
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,""
                           ,mr_atd.semdoctoempcodatd
                           ,mr_atd.semdoctopestip
                           ,mr_atd.semdoctocgccpfnum
                           ,mr_atd.semdoctocgcord
                           ,mr_atd.semdoctocgccpfdig
                           ,mr_atd.semdoctocorsus
                           ,mr_atd.semdoctofunmat
                           ,mr_atd.semdoctoempcod
                           ,mr_atd.semdoctodddcod
                           ,mr_atd.semdoctoctttel
                           ,g_issk.funmat
                           ,g_issk.empcod
                           ,g_issk.usrtip
                           ,g_documento.ligcvntip)
           returning lr_aux.atdnum
                    ,lr_aux.resultado
                    ,lr_aux.mensagem

      if lr_aux.resultado <> 0 then

         error  lr_aux.mensagem sleep 3
         let g_documento.ligcvntip = null
         let g_documento.atdnum    = null
         let g_documento.corsus    = null
         let g_documento.dddcod    = null
         let g_documento.ctttel    = null
         let g_documento.funmat    = null
         let g_documento.cgccpfnum = null
         let g_documento.cgcord    = null
         let g_documento.cgccpfdig = null
         rollback work

      else

         commit work

         initialize lr_aux.confirma
                   ,lr_aux.linha1
                   ,lr_aux.linha2
                   ,lr_aux.linha3 to null

         while lr_aux.confirma is null or lr_aux.confirma = "N"
            let lr_aux.linha1 = "INFORME AO CLIENTE O"
            let lr_aux.linha2 = "NUMERO DE ATENDIMENTO : "
            let lr_aux.linha3 = "< " , lr_aux.atdnum using "<<<<<<<&&&", " >"
            call cts08g01 ("A","N","",lr_aux.linha1, lr_aux.linha2 , lr_aux.linha3)
                 returning lr_aux.confirma
            initialize lr_aux.linha1
                      ,lr_aux.linha2
                      ,lr_aux.linha3 to null
            let lr_aux.linha1 = "NUMERO DE ATENDIMENTO < "
                             ,lr_aux.atdnum using "<<<<<<<&&&" ," >"
            let lr_aux.linha2 = "FOI INFORMADO AO CLIENTE?"
            call cts08g01 ("A","S","",lr_aux.linha1, lr_aux.linha2, "")
                 returning lr_aux.confirma
         end while
         
         initialize lr_aux.premium
                   ,lr_aux.linha1
                   ,lr_aux.linha2
                   ,lr_aux.linha3 to null
                   
                   
         while lr_aux.premium is null
            let lr_aux.linha2 = "CLIENTE PREMIUM?"
            call cts08g01 ("C","S","","", lr_aux.linha2, "")
                 returning lr_aux.premium
         end while
                    

         ---> Atribui O Novo Numero de Atendimento a Global
         let g_documento.atdnum = lr_aux.atdnum
         ---> Se gerou Atendimento aqui nao gera na tela do Assunto
         let g_gera_atd = "N"
         ---> Se nao ha docto volta valor para variaveis

         if mr_tela.semdocto = "S" then
            let g_documento.cgccpfnum = mr_atd.semdoctocgccpfnum
            let g_documento.cgcord    = mr_atd.semdoctocgcord
            let g_documento.cgccpfdig = mr_atd.semdoctocgccpfdig
            let g_documento.corsus    = mr_atd.semdoctocorsus
         end if
         
         
         ---> Carrega Globais caso o cliente seja Premium
         initialize g_novapss.* to null
         
         if lr_aux.premium = "S" then
            let g_novapss.dctsgmcod = 1 #Segmento do documento
            let g_novapss.clisgmcod = 2 #Segmento do cliente
         end if
         
        # display "g_novapss.dctsgmcod: ", g_novapss.dctsgmcod
        # display "g_novapss.clisgmcod: ", g_novapss.clisgmcod

         
      end if
    else
        initialize g_documento.atdnum to null
   end if
end function

#-----------------------------------------------------------------------------
function cta00m26_recupera_atendimento(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
  psscntcod     like kspmcntrsm.psscntcod ,
  c24astcod     like datmligacao.c24astcod,
  ligdatini     like datmligacao.ligdat   ,
  ligdatfim     like datmligacao.ligdat
end record

define lr_retorno record
  sql integer ,
  msg char(70),
  qtd integer
end record

define l_index integer

initialize lr_retorno.* to null

for  l_index  =  1  to  500
     initialize  g_pss_servico[l_index].*   to  null
end  for

let lr_retorno.qtd = 0
let lr_retorno.sql = 0
let l_index        = 1

if m_prep_cta00m26 is null or
   m_prep_cta00m26 <> true then
   call cta00m26_prepare()
end if

 whenever error continue
 open c_cta00m26_001 using lr_param.psscntcod  ,
                         lr_param.c24astcod  ,
                         lr_param.ligdatini  ,
                         lr_param.ligdatfim
 whenever error stop

 foreach c_cta00m26_001 into g_pss_servico[l_index].atdsrvano,
                           g_pss_servico[l_index].atdsrvnum

    let lr_retorno.qtd = lr_retorno.qtd + 1
    let l_index = l_index + 1
 end foreach

 if l_index > 500 then
    let lr_retorno.sql = 1
    let lr_retorno.msg = "Limite de Atendimentos Excedido!"
 end if
 return lr_retorno.sql,
        lr_retorno.msg,
        lr_retorno.qtd


end function

#-----------------------------------------------------------------------------
function cta00m26_recupera_pesnum(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
 cgccpfnum  like gsakpes.cgccpfnum  ,
 cgcord     like gsakpes.cgcord     ,
 cgccpfdig  like gsakpes.cgccpfdig  ,
 pestip     like gsakpes.pestip
end record

define lr_retorno record
       sqlcode   integer                ,
       qtd       smallint               ,
       prod      smallint               ,
       pesnum    like gsakpes.pesnum    ,
       cgccpf    like gsakpes.cgccpfnum ,
       cgcord    like gsakpes.cgcord    ,
       cgccpfdig like gsakpes.cgccpfdig ,
       pesnom    like gsakpes.pesnom    ,
       pestip    like gsakpes.pestip
end record

define lr_aux record
       sqlcode integer             ,
       aux_qtd smallint
end record

define l_index smallint

initialize lr_retorno.* ,
           lr_aux.*      to null

let l_index = null
let lr_retorno.prod = 25 # PSS

 if lr_param.cgcord is null then
    let lr_param.cgcord = 0
 end if

  # Recupera pela gsakpes
  call osgtf550_busca_cliente_cgccpf (lr_param.cgccpfnum ,
                                      lr_param.cgcord    ,
                                      lr_param.cgccpfdig ,
                                      lr_param.pestip    )
  returning lr_retorno.sqlcode, lr_retorno.qtd

  for l_index  =  1  to lr_retorno.qtd

        call osgtf550_lista_unfclisegcod_por_pesnum(g_a_cliente[l_index].pesnum,lr_retorno.prod)
        returning lr_aux.sqlcode,lr_aux.aux_qtd

        if lr_aux.aux_qtd > 0 then
           let lr_retorno.cgccpf    = g_a_cliente[1].cgccpfnum
           let lr_retorno.cgcord    = g_a_cliente[1].cgcord
           let lr_retorno.cgccpfdig = g_a_cliente[1].cgccpfdig
           let lr_retorno.pesnom    = g_a_cliente[1].pesnom
           let lr_retorno.pestip    = g_a_cliente[1].pestip
           let lr_retorno.pesnum    = g_a_cliente[1].pesnum
        end if
  end for

  return lr_retorno.cgccpf     ,
         lr_retorno.cgcord     ,
         lr_retorno.cgccpfdig  ,
         lr_retorno.pesnom     ,
         lr_retorno.pestip     ,
         lr_retorno.pesnum
end function

#-----------------------------------------------------------------------------
function cta00m26_espelho(lr_param)
#-----------------------------------------------------------------------------
define lr_param record
   psscntcod like kspmcntrsm.psscntcod
end record

define lr_retorno record
   pesnum    like gsakpes.pesnum        ,
   endlgdtip like gsakpesend.endlgdtip  ,
   resultado smallint                   ,
   mensagem  char(70)
end record

initialize mr_tela.*    ,
           lr_retorno.* to null

      # Recupera o CGC/CPF atrave do Numero do Contrato
      call pss01g00_consulta_CNPJ(lr_param.psscntcod)
      returning mr_tela.cgccpfnum    ,
                mr_tela.cgcord       ,
                mr_tela.cgccpfdig    ,
                lr_retorno.resultado ,
                lr_retorno.mensagem

      if lr_retorno.resultado = 2 then
         error lr_retorno.mensagem
         return
      end if

      if mr_tela.cgcord is null or
         mr_tela.cgcord = 0     then
           let mr_tela.pestip = "F"
           let mr_tela.cgcord = 0
      else
           let mr_tela.pestip = "J"
      end if

      # Recupera os Dados do Cliente
      call cta00m26_recupera_pesnum(mr_tela.cgccpfnum ,
                                    mr_tela.cgcord    ,
                                    mr_tela.cgccpfdig ,
                                    mr_tela.pestip)
      returning mr_tela.cgccpfnum ,
                mr_tela.cgcord    ,
                mr_tela.cgccpfdig ,
                mr_tela.pesnom    ,
                mr_tela.pestip    ,
                lr_retorno.pesnum

      case  mr_tela.pestip
         when "J"
             let mr_tela.tipnom = "JURIDICA"
         when "F"
             let mr_tela.tipnom = "FISICA"
      end case

      # Recupera Situacao e Vigencia do Documento
      call cta00m24_rec_dados(mr_tela.cgccpfnum ,
                              mr_tela.cgcord    ,
                              mr_tela.cgccpfdig ,
                              mr_tela.pestip    ,
                              lr_param.psscntcod )

      let mr_tela.psscntcod = lr_param.psscntcod
      let mr_tela.situacao  = g_pss.situacao
      let mr_tela.viginc    = g_pss.viginc
      let mr_tela.vigfnl    = g_pss.vigfnl
      let mr_tela.obs       = "                               (F17) Prosseguir"

      if lr_retorno.pesnum is not null then
         # Recupera o Endereco do Cliente
         call cta00m25_endereco_pss(lr_retorno.pesnum)
         returning  lr_retorno.endlgdtip  ,
                    mr_tela.endlgd        ,
                    mr_tela.endnum        ,
                    mr_tela.endcmp        ,
                    mr_tela.endufd        ,
                    mr_tela.endbrr        ,
                    mr_tela.endcid        ,
                    mr_tela.endcep        ,
                    mr_tela.endcepcmp

         call cta00m25_carrega_global(lr_retorno.endlgdtip  ,
                                      mr_tela.endlgd        ,
                                      mr_tela.endnum        ,
                                      mr_tela.endcmp        ,
                                      mr_tela.endufd        ,
                                      mr_tela.endbrr        ,
                                      mr_tela.endcid        ,
                                      mr_tela.endcep        ,
                                      mr_tela.endcepcmp)
      end if

      let mr_tela.endlgd = lr_retorno.endlgdtip clipped, " ", mr_tela.endlgd

      open window w_cta00m26 at 3,2 with form "cta00m26"
         attribute(menu line 1)

       call cta00m26_exibe_tela()

       call cta00m26_espera()

      close window w_cta00m26
end function

#-----------------------------------------------------------------------------
function cta00m26_carrega_anterior(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   tipo smallint
end record


  case lr_param.tipo
    when 1
      let mr_tela.solnom       = mr_ant.solnom
      let mr_tela.c24soltipcod = mr_ant.c24soltipcod
      let mr_tela.c24soltipdes = mr_ant.c24soltipdes
    when 2
      let mr_ant.solnom        = mr_tela.solnom
      let mr_ant.c24soltipcod  = mr_tela.c24soltipcod
      let mr_ant.c24soltipdes  = mr_tela.c24soltipdes
  end case


end function

#-----------------------------------------------------------------------------
function cta00m26_verifica_saldo(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   c24astcod like datmligacao.c24astcod
end record

define lr_retorno record
   cponom    like datkdominio.cponom ,
   cpodes    like datkdominio.cpodes ,
   saldo     integer                 ,
   resultado integer                 ,
   mensagem  char(200)               ,
   erro      smallint
end record

initialize lr_retorno.* to null

let lr_retorno.erro = 0

if m_prep_cta00m26 is null or
   m_prep_cta00m26 <> true then
   call cta00m26_prepare()
end if

let lr_retorno.cponom = "assunto_pss_cc"

  if g_pss.situacao = "ATIVO" then
      whenever error continue
      open ccta00m26003 using lr_retorno.cponom
      whenever error stop
      foreach ccta00m26003 into lr_retorno.cpodes
         if lr_param.c24astcod = lr_retorno.cpodes then
            call pss03g00_consulta_saldo(g_pss.psscntcod   ,
                                         lr_param.c24astcod)
            returning lr_retorno.saldo      ,
                      lr_retorno.resultado  ,
                      lr_retorno.mensagem
            if lr_retorno.resultado = 0 or
               lr_retorno.resultado = 3 then
                  error lr_retorno.mensagem sleep 2
            else
                  error lr_retorno.mensagem sleep 2
                  let lr_retorno.erro = 1
            end if
            exit foreach
         end if
      end foreach
  else
      error "Não e Possivel Prestar o Atendimento, Contrato Não Ativo!"
      let lr_retorno.erro = 1
  end if

  return lr_retorno.saldo     ,
         lr_retorno.resultado ,
         lr_retorno.erro

end function

#-----------------------------------------------------------------------------
function cta00m26_grava_cortesia(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
  atdsrvnum like datmservico.atdsrvnum ,
  atdsrvano like datmservico.atdsrvano
end record

define lr_retorno array[10] of record
  atdmltsrvnum like datratdmltsrv.atdmltsrvnum  ,
  atdmltsrvano like datratdmltsrv.atdmltsrvano  ,
  socntzdes    like datksocntz.socntzdes        ,
  espdes       like dbskesp.espdes              ,
  atddfttxt    like datmservico.atddfttxt
end record

define lr_aux record
  resultado    smallint ,
  mensagem     char(100)
end record

define l_index smallint

for l_index  =  1  to  10
       initialize  lr_retorno[l_index].*  to  null
end for

initialize lr_aux.* to null

    # Verifica se Serviço Tem Laudo Multiplo
    call cts29g00_obter_multiplo
         (1, lr_param.atdsrvnum,
             lr_param.atdsrvano)
          returning lr_aux.resultado,
                    lr_aux.mensagem ,
                    lr_retorno[1].* ,
                    lr_retorno[2].* ,
                    lr_retorno[3].* ,
                    lr_retorno[4].* ,
                    lr_retorno[5].* ,
                    lr_retorno[6].* ,
                    lr_retorno[7].* ,
                    lr_retorno[8].* ,
                    lr_retorno[9].* ,
                    lr_retorno[10].*

     if lr_aux.resultado = 1 then
         for l_index  =  1  to  10
            if lr_retorno[l_index].atdmltsrvnum is not null and
               lr_retorno[l_index].atdmltsrvano is not null then
                 call pss03g00_grava_saldoNegativo(g_pss.psscntcod                  ,
                                                   lr_retorno[l_index].atdmltsrvnum ,
                                                   lr_retorno[l_index].atdmltsrvano )
                 returning lr_aux.resultado,
                           lr_aux.mensagem
                 if lr_aux.resultado <> 0 then
                    error lr_aux.mensagem
                 end if
            end if
         end for
     end if

     # Gravo o Serviço Original
     call pss03g00_grava_saldoNegativo(g_pss.psscntcod    ,
                                       lr_param.atdsrvnum ,
                                       lr_param.atdsrvano )
     returning lr_aux.resultado,
               lr_aux.mensagem
     if lr_aux.resultado <> 0 then
        error lr_aux.mensagem
     end if

end function
