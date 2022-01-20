# --------------------------------------------------------------------------- #
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: bdbsr521                                                   #
# ANALISTA RESP..: Vinicius Morais (CDS BALTICO)                              #
# PSI/OSF........: PSI-2011-21476                                             #
# OBJETIVO.......: Analisar e bloquear veiculos com irregularidades           #
#                  no Seguro + envio de e-mail com relatorio                  #
# ........................................................................... #
# DESENVOLVIMENTO: Vinicius Morais                                            #
# LIBERACAO......: xx/xx/2012                                                 #
# ........................................................................... #
#                                                                             #
#                         * * * * ALTERACOES * * * *                          #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
#                                                                             #
# --------------------------------------------------------------------------- #

globals "/homedsa/projetos/geral/globals/figrc012.4gl"

   define m_horatu    char(24)
   define m_lidos     smallint
   define m_blqs      smallint

   define mr_totais   array [50] of record
          vcltip      char(30)
         ,blqtlt      smallint
   end record


main

   define l_time_begin      datetime day  to fraction
   define l_time_end        datetime day  to fraction
   define l_elapstime       interval hour to fraction

   #---> Abertura do banco de dados: Porto Socorro
   #-----------------------------------------
   call fun_dba_abre_banco ("CT24HS")

   set isolation to dirty read

   let l_time_begin = extend(current, day to fraction)

   #-- funcoes
   call bdbsr521_cria_log()
   call bdbsr521_criaTemp()
   call bdbsr521_montarQueries()
   call bdbsr521_analiseVeiculos()
   call bdbsr521_emitirRelatorio()

   #-- finalizando
   let l_time_end = extend(current, day to fraction)
   let l_elapstime = l_time_end - l_time_begin
   display " "
   display "* Tempo Processo: ", l_elapstime
   display " "
   let m_horatu = current
   display m_horatu, "bdbsr521 - fim"

end main


#------------------------------------------------------#
function bdbsr521_montarQueries()
# Objetivo: montar os prepares com os selects necessarios ao processamento
#------------------------------------------------------#

   define l_sql char(300)

   let l_sql = "select a.vclchsinc, a.vclchsfnl, a.vcllicnum, ",
               "       a.socvcltip, a.socoprsitcod, a.socvclcod, ",
               "       a.atdvclsgl, a.pstcoddig, a.vclcoddig ",
               "  from datkveiculo a, datksgrirrblqpam b ",
               " where a.socoprsitcod = 1", #ATIVO
               "   and a.socvcltip = b.socvcltip" #Que possua parametro
   prepare pbdbsr521001 from l_sql
   declare cbdbsr521001 cursor for pbdbsr521001

   let l_sql = "update datkveiculo set socoprsitcod = 2 ",
               " where socvclcod = ?"
   prepare pbdbsr521002 from l_sql

   let l_sql = "insert into blqvclrel(seguro, acao, vclcod, sigla, placa, ",
               " chassi, prtcod, vigfnl, cobert, blqmtv, gstcda, vcltip,  ",
               " vclmdl, uf, cidade, cidsed) ",
               "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
   prepare pbdbsr521003 from l_sql

   let l_sql = "select b.sprnom || ' / ' || b.gernom || ",
               " ' / ' || b.cdnnom || ' / ' || b.anlnom ",
               " from dpaksocor a, dpakprsgstcdi b ",
               "  where a.gstcdicod = b.gstcdicod ",
               "    and a.pstcoddig = ?"
   prepare pbdbsr521005 from l_sql
   declare cbdbsr521005 cursor for pbdbsr521005

   let l_sql = "select cpodes from iddkdominio ",
               " where cponom = 'socvcltip' ",
               "   and cpocod = ? "
   prepare pbdbsr521006 from l_sql
   declare cbdbsr521006 cursor for pbdbsr521006

   let l_sql = "select vcldes from agbkvcldes ",
               " where vclcoddig = ? "
   prepare pbdbsr521007 from l_sql
   declare cbdbsr521007 cursor for pbdbsr521007

   let l_sql = "select endufd, endcid from dpaksocor ",
               " where pstcoddig = ? "
   prepare pbdbsr521008 from l_sql
   declare cbdbsr521008 cursor for pbdbsr521008

   let l_sql = "select csccbtflg, dmavlr, dcpvlr, appvlr, rbcvclensflg ",
               "  from datksgrirrblqpam ",
               " where socvcltip = ?"
   prepare pbdbsr521009 from l_sql
   declare cbdbsr521009 cursor for pbdbsr521009

   let l_sql = "select * from blqvclrel"
   prepare pbdbsr521010 from l_sql
   declare cbdbsr521010 cursor for pbdbsr521010

   let l_sql = "select vcltip, count(*) from blqvclrel ",
               " where acao = 'Bloqueado' ",
               " group by 1"
   prepare pbdbsr521011 from l_sql
   declare cbdbsr521011 cursor for pbdbsr521011

   let l_sql = "select relpamtxt from igbmparam "
              ," where relsgl = 'bdbsr521'"
   prepare pbdbsr521012 from l_sql
   declare cbdbsr521012 cursor for pbdbsr521012

end function #bdbsr521_montarQueries()


#------------------------------------------------------#
function bdbsr521_criaTemp()
# Objetivo criar tabela temporaria para emissao do relatorio
#------------------------------------------------------#

   whenever error continue
   create temp table blqvclrel(seguro char(11),
                               acao   char(60),
                               vclcod decimal(6,0),
                               sigla  char(5),
                               placa  char(7),
                               chassi char(20),
                               prtcod decimal(6,0),
                               vigfnl date,
                               cobert char(200),
                               blqmtv char(200),
                               gstcda char(200),
                               vcltip char(50),
                               vclmdl char(80),
                               uf     char(2),
                               cidade char(45),
                               cidsed char(45)) with no log;

   whenever error stop
   if sqlca.sqlcode <> 0 then
      display "-----------------------------------"
      display "ERRO AO CRIAR TEMP TABLE."
      display "ABRIR CHAMADO PARA EQUIPE ARAGUAIA"
      display "-----------------------------------"
      exit program(1)
   end if

end function #bdbsr521_criaTemp()


#------------------------------------------------------#
function bdbsr521_analiseVeiculos()
# Objetivo: analisar, bloquear, se for o caso, e enviar dados p/ relatorio
#------------------------------------------------------#

   define lr_veiculo record
          vclchsinc    like datkveiculo.vclchsinc
         ,vclchsfnl    like datkveiculo.vclchsfnl
         ,vcllicnum    like datkveiculo.vcllicnum
         ,socvcltip    like datkveiculo.socvcltip
         ,socoprsitcod like datkveiculo.socoprsitcod
         ,socvclcod    like datkveiculo.socvclcod
         ,atdvclsgl    like datkveiculo.atdvclsgl
         ,pstcoddig    like datkveiculo.pstcoddig
         ,vclcoddig    like datkveiculo.vclcoddig
   end record

   define lr_seguro record
          codres        smallint # 0-Ok / 1-Erro / 2-Notfound
         ,msgerr        char(80)
         ,doctip        char(03) #APL / PRP / RS
         ,prporg        like apamcapa.prporgpcp
         ,prpnumdig     like apamcapa.prpnumpcp
         ,dvlflg        char(1) # Para prp, S=Devolvido e N=OK (pendente)
         ,succod        like abbmitem.succod
         ,aplnumdig     like abbmitem.aplnumdig
         ,itmnumdig     like abbmitem.itmnumdig
         ,aplstt        char(1) #(A)tivo / (C)ancelado
         ,viginc        like abbmitem.viginc
         ,vigfnl        like abbmitem.vigfnl
         ,cscimsvlr     like abbmcasco.imsvlr
         ,rdmimsvlr     like abbmcasco.imsvlr
         ,rdpimsvlr     like abbmcasco.imsvlr
         ,appimsinvvlr  like apbmcasco.imsvlr
         ,appimsmorvlr  like apbmcasco.imsvlr
         ,clsflg        char(01)
   end record

   define lr_vistoria record
          tipo       char(1)
         ,vstnumdig  decimal(9,0)
         ,vstdat     date
         ,vsthor     datetime hour to minute
         ,situacao   char(1)
   end record

   define l_sedcidblq decimal(1,0)
   define l_chassi    char(20)
   define l_cobert    char(200)
   define l_gstcdi    char(120)
   define l_vcltipdes char(80)
   define l_vcldes    char(80)
   define l_uf        char(2)
   define l_cid       char(35)
   define l_motivo    char(200)
   define l_retcod    decimal(1,0)
   define l_rpvcob    char(120)
   define l_casco     char(3)
   define l_cont      smallint
   define l_cidsed    char(45)

   initialize lr_veiculo.* to null
   initialize lr_seguro.* to null
   initialize lr_vistoria.* to null
   display "*** INICIANDO ANALISE DOS VEICULOS ****"
   foreach cbdbsr521001 into lr_veiculo.*

      let m_lidos = m_lidos + 1

      #Popula campos e realiza validacoes antes
      #de mandar para o relatorio
      let l_chassi = lr_veiculo.vclchsinc, lr_veiculo.vclchsfnl

      let l_gstcdi = ""
      whenever error continue
      open cbdbsr521005 using lr_veiculo.pstcoddig
      fetch cbdbsr521005 into l_gstcdi
      close cbdbsr521005
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let l_gstcdi = "CADEIA DE GESTAO NAO LOCALIZADA"
      end if

      let l_gstcdi = l_gstcdi clipped

      let l_vcltipdes = ""
      whenever error continue
      open cbdbsr521006 using lr_veiculo.socvcltip
      fetch cbdbsr521006 into l_vcltipdes
      close cbdbsr521006
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let l_vcltipdes = "TIPO NAO ENCONTRADO"
      end if

      let l_vcltipdes = l_vcltipdes clipped

      let l_vcldes = ""
      whenever error continue
      open cbdbsr521007 using lr_veiculo.vclcoddig
      fetch cbdbsr521007 into l_vcldes
      close cbdbsr521007
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let l_vcldes = "MODELO NAO ENCONTRADO"
      end if

      let l_vcldes = l_vcldes clipped

      let l_uf = ""
      let l_cid = ""

      whenever error continue
      open cbdbsr521008 using lr_veiculo.pstcoddig
      fetch cbdbsr521008 into l_uf, l_cid
      close cbdbsr521008
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let l_uf = "XX"
         let l_cid = "CIDADE NAO ENCONTRADA"
      end if

      let l_uf = l_uf clipped
      let l_cid = l_cid clipped

      #Busca nome da cidade-sede
      call buscacidsed(lr_veiculo.socvclcod)
      returning l_cidsed

      call faemc923_checarSeguroVeiculo(lr_veiculo.vclchsinc,
                                        lr_veiculo.vclchsfnl,
                                        lr_veiculo.vcllicnum,
                                        "111")
      returning lr_seguro.*

      if (lr_seguro.doctip = "PRP" and lr_seguro.dvlflg = "S") then
         let lr_seguro.codres = 2 #Se proposta devolvida,
                                  #Considerar como "Sem Seguro"
         display "VEICULO: ", lr_veiculo.socvclcod ,
                 " | PROP DEVOLVIDA: ",
                 lr_seguro.prporg, "-", lr_seguro.prpnumdig
      end if

      #TRATAR RETORNO
      if lr_seguro.codres = 0 then #Encontrou

         call validaCoberturas(lr_veiculo.socvcltip,
                               lr_seguro.cscimsvlr,
                               lr_seguro.rdmimsvlr,
                               lr_seguro.rdpimsvlr,
                               lr_seguro.appimsinvvlr,
                               lr_seguro.appimsmorvlr,
                               lr_seguro.clsflg,
                               lr_seguro.vigfnl,
                               1)
               returning l_retcod, l_rpvcob

         if lr_seguro.cscimsvlr > 0 then
            let l_casco = "Sim"
         else
            let l_casco = "Nao"
         end if

         let l_cobert = "Casco: ", l_casco, " / Danos Materiais: ",
                        lr_seguro.rdmimsvlr, "/ Danos Pessoais: ",
                        lr_seguro.rdpimsvlr, "/ APP Morte: ",
                        lr_seguro.appimsmorvlr, "/ APP Invalidez: ",
                        lr_seguro.appimsinvvlr, "/ Clausula 111: ",
                        lr_seguro.clsflg
        display "VEICULO: ", lr_veiculo.socvclcod, " | APOLICE: ", lr_seguro.aplnumdig,
                 " | PROPSOTA: ", lr_seguro.prporg, "-", lr_seguro.prpnumdig

         let l_cobert = l_cobert clipped

         if l_retcod = 0 then #Coberturas OK

            #Registra também no relatorio
            execute pbdbsr521003 using "Sim",
                                 "Nenhuma",
                                 lr_veiculo.socvclcod,
                                 lr_veiculo.atdvclsgl,
                                 lr_veiculo.vcllicnum, l_chassi,
                                 lr_veiculo.pstcoddig,  lr_seguro.vigfnl,
                                 l_cobert, "", l_gstcdi,
                                 l_vcltipdes, l_vcldes, l_uf, l_cid,
                                 l_cidsed
         else

            #Verifica se existe bloqueio ativo para cidade-sede
            let l_sedcidblq = 0
            call verificablqcidsed(lr_veiculo.socvclcod)
            returning l_sedcidblq

            if l_sedcidblq = 0 then

               let l_motivo = l_rpvcob clipped
               #Registra no relatorio sem bloquear
               execute pbdbsr521003 using "Sim",
                                    "Bloqueio Por Cidade-Sede Inativo",
                                    lr_veiculo.socvclcod,
                                    lr_veiculo.atdvclsgl,
                                    lr_veiculo.vcllicnum, l_chassi,
                                    lr_veiculo.pstcoddig,  lr_seguro.vigfnl,
                                    l_cobert, l_motivo, l_gstcdi,
                                    l_vcltipdes, l_vcldes, l_uf, l_cid,
                                    l_cidsed

            else
               #Executa o Bloqueio
               whenever error continue
               execute pbdbsr521002 using lr_veiculo.socvclcod
               whenever error stop
               if sqlca.sqlcode    = 0 and
                  sqlca.sqlerrd[3] > 0 then

                  #Envia para o relatorio informando o bloqueio
                  let m_blqs = m_blqs + 1
                  let l_motivo = l_rpvcob
                  execute pbdbsr521003 using "Sim","Bloqueado",
                                       lr_veiculo.socvclcod,lr_veiculo.atdvclsgl,
                                       lr_veiculo.vcllicnum, l_chassi,
                                       lr_veiculo.pstcoddig,
                                       lr_seguro.vigfnl, l_cobert, l_motivo,
                                       l_gstcdi, l_vcltipdes, l_vcldes,
                                       l_uf, l_cid, l_cidsed
               else
                  #Envia para o relatorio informando que nao efetuou o bloqueio
                  let l_motivo = ""
                  execute pbdbsr521003 using "Sim",
                                       "ERRO AO TENTAR BLOQUEAR VEICULO",
                                       lr_veiculo.socvclcod,
                                       lr_veiculo.atdvclsgl,
                                       lr_veiculo.vcllicnum, l_chassi,
                                       lr_veiculo.pstcoddig,  lr_seguro.vigfnl,
                                       l_cobert, l_motivo, l_gstcdi,
                                       l_vcltipdes, l_vcldes, l_uf, l_cid,
                                       l_cidsed
               end if
            end if
         end if
      else
         if lr_seguro.codres <> 2 then
            display "*** ERRO NA FUNCAO AUTO COD VEICULO: ",
                    lr_veiculo.socvclcod, " | COD RETORNO: ",
                    lr_seguro.codres, " | MENSAGEM: ",
                    lr_seguro.msgerr, " ***"
         end if
         # Pesquisa por Vistoria Previa / Cobertura Provisoria
         call fvpic006_vcllicnum(lr_veiculo.vclchsfnl, lr_veiculo.vclchsinc,
                                 lr_veiculo.vcllicnum)
              returning lr_vistoria.*

         #Se Nao encontrar ou se for Devolvida
         if lr_vistoria.tipo = 'N' or
            lr_vistoria.situacao = 'D' then
            #Forca a reprovacao da validacao de cobertura
            let lr_vistoria.vstdat = today - 7 units day
         end if

         call validaCoberturas(lr_veiculo.socvcltip,0,0,0,0,0,
                               "", lr_vistoria.vstdat,2)
              returning l_retcod, l_rpvcob

           display "VEICULO: ", lr_veiculo.socvclcod, "| VISTORIA / COB PROV: "
                    , lr_vistoria.vstnumdig, " | TIPO: ", lr_vistoria.tipo
         if l_retcod = 0 then  #VP/CP OK

            execute pbdbsr521003 using "Sim","Nenhuma", lr_veiculo.socvclcod,
                                 lr_veiculo.atdvclsgl, lr_veiculo.vcllicnum,
                                 l_chassi, lr_veiculo.pstcoddig,  "",
                                 "", "", l_gstcdi,
                                 l_vcltipdes, l_vcldes, l_uf, l_cid, l_cidsed

         else
            #Verifica se existe bloqueio ativo para cidade-sede
            let l_sedcidblq = 0
            call verificablqcidsed(lr_veiculo.socvclcod)
            returning l_sedcidblq

            if l_sedcidblq = 0 then #Nao Bloqueia

               let l_motivo = l_rpvcob clipped
               #Registra no relatorio sem bloquear

               execute pbdbsr521003 using "Nao",
                                    "Bloqueio Por Cidade-Sede Inativo",
                                    lr_veiculo.socvclcod,
                                    lr_veiculo.atdvclsgl, lr_veiculo.vcllicnum,
                                    l_chassi, lr_veiculo.pstcoddig,  "",
                                    "", l_motivo, l_gstcdi,
                                    l_vcltipdes, l_vcldes, l_uf, l_cid, l_cidsed

            else
               #Executa o Bloqueio
               whenever error continue
               execute pbdbsr521002 using lr_veiculo.socvclcod
               whenever error stop
               if sqlca.sqlcode    = 0 and
                  sqlca.sqlerrd[3] > 0 then

                  #Envia para o relatorio informando o bloqueio
                  let m_blqs = m_blqs + 1
                  let l_motivo = l_rpvcob

                  execute pbdbsr521003 using "Nao","Bloqueado",
                                       lr_veiculo.socvclcod,
                                       lr_veiculo.atdvclsgl,
                                       lr_veiculo.vcllicnum, l_chassi,
                                       lr_veiculo.pstcoddig,
                                       "", "", l_motivo,
                                       l_gstcdi, l_vcltipdes, l_vcldes,
                                       l_uf, l_cid, l_cidsed

               else
                  #Envia para o relatorio informando que nao efetuou o bloqueio
                  let l_motivo = l_rpvcob clipped

                  execute pbdbsr521003 using "Nao",
                                       "ERRO AO TENTAR BLOQUEAR VEICULO",
                                       lr_veiculo.socvclcod,
                                       lr_veiculo.atdvclsgl,
                                       lr_veiculo.vcllicnum, l_chassi,
                                       lr_veiculo.pstcoddig,
                                       "", "", l_motivo,
                                       l_gstcdi, l_vcltipdes, l_vcldes,
                                       l_uf, l_cid, l_cidsed
               end if
            end if
         end if
      end if
   end foreach
   let l_cont = 1
   foreach cbdbsr521011 into mr_totais[l_cont].vcltip
                         ,mr_totais[l_cont].blqtlt

      if l_cont > 50 then
         display "* * * QUANTIDADE DE TIPOS DE VEICULO MAIOR QUE O ARRAY"
         display " ABRIR CHAMADO PARA SISTEMAS ARAGUAIA * * *"
         exit program(1)
      else
         let l_cont = l_cont + 1
      end if
   end foreach

end function #bdbsr521_analiseVeiculos()


#------------------------------------------------------#
function validaCoberturas(lr_par_in)
# Objetivo: validar se as coberturas contratadas estao de acordo com a regra
#           para o tipo de veiculo informado.
#------------------------------------------------------#

   define lr_par_in record
          socvcltip     like datkveiculo.socvcltip
         ,cscimsvlr     like abbmcasco.imsvlr
         ,rdmimsvlr     like abbmcasco.imsvlr
         ,rdpimsvlr     like abbmcasco.imsvlr
         ,appimsinvvlr  like apbmcasco.imsvlr
         ,appimsmorvlr  like apbmcasco.imsvlr
         ,clsflg        char(01)
         ,vigdat        date
         ,cbttip        decimal(1,0) # 1-Seguro/Proposta/RS 2-Vistoria/CPS
   end record

   define lr_par_out record
          retcod       decimal(1,0)
         ,rpvcob       char(120)
   end record

   define lr_par_blq record
          csccbtflg      like datksgrirrblqpam.csccbtflg
         ,dmavlr         like datksgrirrblqpam.dmavlr
         ,dcpvlr         like datksgrirrblqpam.dcpvlr
         ,appvlr         like datksgrirrblqpam.appvlr
         ,rbcvclensflg   like datksgrirrblqpam.rbcvclensflg
   end record

   initialize lr_par_blq.* to null
   initialize lr_par_out.* to null
   let lr_par_out.retcod = 0
   let lr_par_out.rpvcob = ""

   case lr_par_in.cbttip
   when 1

      open cbdbsr521009 using lr_par_in.socvcltip
      fetch cbdbsr521009 into lr_par_blq.*
      close cbdbsr521009

      if lr_par_in.cscimsvlr is null then
         let lr_par_in.cscimsvlr = 0
      end if

      if lr_par_blq.csccbtflg = 1    then
         if lr_par_in.cscimsvlr = 0 then
            let lr_par_out.retcod = 1
            let lr_par_out.rpvcob = "CASCO"
         end if
      end if

      if lr_par_in.rdmimsvlr is null then
         let lr_par_in.rdmimsvlr = 0
      end if

      if lr_par_in.rdmimsvlr < lr_par_blq.dmavlr then
         let lr_par_out.retcod = 1
         let lr_par_out.rpvcob = lr_par_out.rpvcob clipped, " DANOS_MATERIAIS"
      end if

      if lr_par_in.rdpimsvlr is null then
         let lr_par_in.rdpimsvlr = 0
      end if

      if lr_par_in.rdpimsvlr < lr_par_blq.dcpvlr then
         let lr_par_out.retcod = 1
         let lr_par_out.rpvcob = lr_par_out.rpvcob clipped, " DANOS_CORPORAIS"
      end if

      if lr_par_in.appimsinvvlr is null then
         let lr_par_in.appimsinvvlr = 0
      end if

      if lr_par_in.appimsinvvlr   < lr_par_blq.appvlr then
         let lr_par_out.retcod = 1
         let lr_par_out.rpvcob = lr_par_out.rpvcob clipped, " APP_Invalidez"
      end if

      if lr_par_in.appimsmorvlr is null then
         let lr_par_in.appimsmorvlr = 0
      end if

      if lr_par_in.appimsmorvlr     < lr_par_blq.appvlr then
         let lr_par_out.retcod = 1
         let lr_par_out.rpvcob = lr_par_out.rpvcob clipped, " APP_Morte"
      end if

      if lr_par_in.clsflg is null then
         let lr_par_in.clsflg = "N"
      end if

      if lr_par_blq.rbcvclensflg = 1 and lr_par_in.clsflg = "N" then
         let lr_par_out.retcod = 1
         let lr_par_out.rpvcob = lr_par_out.rpvcob clipped, " CLAUSULA_111"
      end if

   when 2
      if lr_par_in.vigdat < today - 5 units day then
         let lr_par_out.retcod = 1
         let lr_par_out.rpvcob = "VISTORIA PREVIA / COBERTURA PROVISORIA"
      end if

   end case

   return lr_par_out.*

end function #validaCoberturas()


#------------------------------------------------------#
function bdbsr521_cria_log()
#------------------------------------------------------#

  # -> FUNCAO P/CRIAR O ARQUIVO DE LOG DO PROGRAMA

  define l_path char(80)

  let l_path = null
  let l_path = f_path("DBS","LOG")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdbsr521.log"

  call startlog(l_path)

end function


#------------------------------------------------------#
function bdbsr521_emitirRelatorio()
#Objetivo: Gerar e enviar o relatorio por e-mail
#------------------------------------------------------#
   define lr_rel record
          seguro  char(11)
         ,acao    char(60)
         ,vclcod  decimal(6,0)
         ,sigla   char(5)
         ,placa   char(7)
         ,chassi  char(20)
         ,prtcod  decimal(6,0)
         ,vigfnl  date
         ,cobert  char(200)
         ,blqmtv  char(200)
         ,gstcda  char(200)
         ,vcltip  char(50)
         ,vclmdl  char(80)
         ,uf      char(2)
         ,cidade  char(45)
         ,cidsed  char(45)
         ,dtgrarq date
   end record

   define l_arq      char(50)
   define l_arq_txt  char(50)
   define l_ret_mail smallint

   define l_dataarq char(8)
   define l_data    date
   let l_data = today
   let l_dataarq = extend(l_data, year to year),
                   extend(l_data, month to month),
                   extend(l_data, day to day)

   initialize lr_rel.* to null

   display " "
   display "*** INICIANDO EMISSAO DO RELATORIO ***"

   let l_arq = f_path("DAT", "ARQUIVO") clipped, "/ABDBSR521I01.xls"
   let l_arq_txt = f_path("DAT", "ARQUIVO") clipped, "/ABDBSR521I01_", l_dataarq, ".txt"

   let lr_rel.dtgrarq = today

   start report bdbsr521_rep to l_arq
   start report bdbsr521_rep_txt to l_arq_txt

   foreach cbdbsr521010 into lr_rel.*
      output to report bdbsr521_rep(lr_rel.*)
      output to report bdbsr521_rep_txt(lr_rel.*)
   end foreach
   finish report bdbsr521_rep
   finish report bdbsr521_rep_txt

 ###Enviar Relatorio p/ e-mails selecionados
   display "*** ENVIANDO RELATORIO POR EMAIL ***"
   call ctx22g00_envia_email("BDBSR521", "VEICULOS BLOQUEADOS - SEGURO", l_arq)
   returning l_ret_mail

   if l_ret_mail <> 0 then
      if l_ret_mail <> 99 then
         display "Erro ao enviar email(ctx22g00) - ", l_arq
      else
         display "Nao existe email cadastrado para este modulo - bdbsr521"
      end if
   end if

end function # bdbsr521_emitirRelatorio

report bdbsr521_rep(lr_rel)

   define lr_rel record
          seguro char(11)
         ,acao   char(60)
         ,vclcod decimal(6,0)
         ,sigla  char(5)
         ,placa  char(7)
         ,chassi char(20)
         ,prtcod decimal(6,0)
         ,vigfnl date
         ,cobert char(200)
         ,blqmtv char(200)
         ,gstcda char(200)
         ,vcltip char(50)
         ,vclmdl char(80)
         ,uf     char(2)
         ,cidade char(45)
         ,cidsed char(45)
         ,dtgrarq date
   end record

   define l_i smallint

   output
      right  margin 0
      left   margin 0
      bottom margin 0
      top    margin 0

   format
      first page header
         print column 45, "RELATORIO DE VEICULOS BLOQUEADOS COM IRREGULARIDADES "
                        ,"NAS COBERTURAS DO SEGURO"
         print "SEGURO/VIST PREVIA/COB PROVISORIA", ascii(9)
              ,"ACAO"                             , ascii(9)
              ,"CODIGO DO VEICULO"                , ascii(9)
              ,"SIGLA"                            , ascii(9)
              ,"PLACA"                            , ascii(9)
              ,"CHASSI"                           , ascii(9)
              ,"PRESTADOR"                        , ascii(9)
              ,"VIGENCIA DO SEGURO"               , ascii(9)
              ,"COBERTURAS CONTRATADAS"           , ascii(9)
              ,"MOTIVO BLOQUEIO"                  , ascii(9)
              ,"CADEIA DE GESTAO"                 , ascii(9)
              ,"TIPO DE VEICULO"                  , ascii(9)
              ,"MODELO DE VEICULO"                , ascii(9)
              ,"UF"                               , ascii(9)
              ,"CIDADE"                           , ascii(9)
              ,"CIDADE-SEDE"                      , ascii(9)
              ,"DATA_GERACAO_LOG"                 , ascii(9)

      on every row
         print lr_rel.seguro clipped   ,ascii(9)
              ,lr_rel.acao   clipped   ,ascii(9)
              ,lr_rel.vclcod clipped   ,ascii(9)
              ,lr_rel.sigla  clipped   ,ascii(9)
              ,lr_rel.placa  clipped   ,ascii(9)
              ,lr_rel.chassi clipped   ,ascii(9)
              ,lr_rel.prtcod clipped   ,ascii(9)
              ,lr_rel.vigfnl clipped   ,ascii(9)
              ,lr_rel.cobert clipped   ,ascii(9)
              ,lr_rel.blqmtv clipped   ,ascii(9)
              ,lr_rel.gstcda clipped   ,ascii(9)
              ,lr_rel.vcltip clipped   ,ascii(9)
              ,lr_rel.vclmdl clipped   ,ascii(9)
              ,lr_rel.uf     clipped   ,ascii(9)
              ,lr_rel.cidade clipped   ,ascii(9)
              ,lr_rel.cidsed clipped   ,ascii(9)
              ,lr_rel.dtgrarq

      on last row
         print "Total de Veiculos Analisados: ", ascii(9)
              ,m_lidos, ascii(9)
         print "Total de Veiculos Bloqueados: ", ascii(9)
              ,m_blqs, ascii(9)

         for l_i = 1 to 50
            if mr_totais[l_i].vcltip is null then
               exit for
            else
               print mr_totais[l_i].vcltip clipped, ": ", ascii(9),
                     mr_totais[l_i].blqtlt, ascii(9)
            end if
         end for
end report


#------------------------------------------------------#
function verificablqcidsed(lr_socvclcod)
#Objetivo: Pesquisar se a regra de bloqueio esta ativa para cidade sede
#          Retirado do prepare por erro no informix
# Mais informacoes: https://www-304.ibm.com/support/docview.wss?uid=swg1IC64881
#------------------------------------------------------#
   define lr_socvclcod like datkveiculo.socvclcod
   define lr_ret smallint

   let lr_ret = 0

   select 1 into lr_ret from datkveiculo vcl,   dpaksocor  pst,
                             datkmpacid cidmap, datrcidsed rcid,
                             datkdominio dom
                where vcl.pstcoddig = pst.pstcoddig
                  and pst.endcid = cidmap.cidnom
                  and pst.endufd = cidmap.ufdcod
                  and rcid.cidcod = cidmap.mpacidcod
                  and dom.cponom = 'blqcidsedsegvtr'
                  and rcid.cidsedcod = dom.cpodes
                  and socvclcod = lr_socvclcod

   return lr_ret

end function #verificablqcidsed

function buscacidsed(l_socvclcod)

   define l_socvclcod   smallint
   define l_ret char(45)


   select lcid.cidnom into l_ret
     from datkveiculo vcl,
          dpaksocor pst,
          datkmpacid cidmap,
          datrcidsed rcid,
          glakcid lcid
    where vcl.pstcoddig = pst.pstcoddig
      and pst.endcid = cidmap.cidnom
      and pst.endufd = cidmap.ufdcod
      and rcid.cidcod = cidmap.mpacidcod
      and rcid.cidsedcod = lcid.cidcod
      and socvclcod = l_socvclcod

   return l_ret

end function


report bdbsr521_rep_txt(lr_rel)

   define lr_rel record
          seguro char(11)
         ,acao   char(60)
         ,vclcod decimal(6,0)
         ,sigla  char(5)
         ,placa  char(7)
         ,chassi char(20)
         ,prtcod decimal(6,0)
         ,vigfnl date
         ,cobert char(200)
         ,blqmtv char(200)
         ,gstcda char(200)
         ,vcltip char(50)
         ,vclmdl char(80)
         ,uf     char(2)
         ,cidade char(45)
         ,cidsed char(45)
         ,dtgrarq date
   end record

   define l_i smallint

   output
      right  margin 0
      left   margin 0
      bottom margin 0
      top    margin 0
      page   length 1

   format

      on every row
         print lr_rel.seguro clipped   ,ascii(9)
              ,lr_rel.acao   clipped   ,ascii(9)
              ,lr_rel.vclcod clipped   ,ascii(9)
              ,lr_rel.sigla  clipped   ,ascii(9)
              ,lr_rel.placa  clipped   ,ascii(9)
              ,lr_rel.chassi clipped   ,ascii(9)
              ,lr_rel.prtcod clipped   ,ascii(9)
              ,lr_rel.vigfnl clipped   ,ascii(9)
              ,lr_rel.cobert clipped   ,ascii(9)
              ,lr_rel.blqmtv clipped   ,ascii(9)
              ,lr_rel.gstcda clipped   ,ascii(9)
              ,lr_rel.vcltip clipped   ,ascii(9)
              ,lr_rel.vclmdl clipped   ,ascii(9)
              ,lr_rel.uf     clipped   ,ascii(9)
              ,lr_rel.cidade clipped   ,ascii(9)
              ,lr_rel.cidsed clipped   ,ascii(9)
              ,lr_rel.dtgrarq

end report