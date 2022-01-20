#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR106                                                   #
# ANALISTA RESP..: CRISTIANE BARBOSA DA SILVA                                 #
# PSI/OSF........: 197602 - CADASTRO CELULAR FROTA PORTO SOCORRO.             #
#                  EMITE UM RELATORIO DAS VISTORIAS E REVISTORIAS MARCADAS P/ #
#                  O PROXIMO DIA.                                             #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 03/03/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
# ---------- --------------  ---------- ------------------------------------- #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
#-----------------------------------------------------------------------------#

database porto

  define m_path char(100)

main

  call fun_dba_abre_banco("CT24HS")

  call bdbsr106_busca_path()

  call bdbsr106_prepare()

  call cts40g03_exibe_info("I", "BDBSR106")

  set isolation to dirty read
  set lock mode to wait 10

  call bdbsr106()

  call cts40g03_exibe_info("F", "BDBSR106")

end main

#-------------------------#
function bdbsr106_prepare()
#-------------------------#

  define l_sql char(400)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select vstsitcod, ",
                     " vstsitdat, ",
                     " socvclcod, ",
                     " revdat, ",
                     " vstpbmcod, ",
                     " atldat, ",
                     " atlmat, ",
                     " caddat, ",
                     " cadmat, ",
                     " cademp, ",
                     " atlemp, ",
                     " cadusrtip, ",
                     " atlusrtip ",
                " from dpakvst ",
               " where vstsitdat = ? ",
                  " or revdat = ? "

  prepare pbdbsr106001 from l_sql
  declare cbdbsr106001 cursor for pbdbsr106001

  let l_sql = " select nomgrr ",
                " from dpaksocor ",
               " where pstcoddig = ? "

  prepare pbdbsr106002 from l_sql
  declare cbdbsr106002 cursor for pbdbsr106002

  let l_sql = " select vstpbmdes ",
                " from dpakpbmvst ",
               " where vstpbmcod = ? "

  prepare pbdbsr106003 from l_sql
  declare cbdbsr106003 cursor for pbdbsr106003

  let l_sql = " select vstsitdes ",
                " from dpaksitvst ",
               " where vstsitcod = ? "

  prepare pbdbsr106004 from l_sql
  declare cbdbsr106004 cursor for pbdbsr106004

  let l_sql = " select pstcoddig, ",
                     " atdvclsgl ",
                " from datkveiculo ",
               " where socvclcod = ? "

  prepare pbdbsr106005 from l_sql
  declare cbdbsr106005 cursor for pbdbsr106005

  let l_sql = " select funnom ",
                " from isskfunc ",
               " where empcod = ? ",
                 " and funmat = ? ",
                 " and usrtip = ? "

  prepare pbdbsr106006 from l_sql
  declare cbdbsr106006 cursor for pbdbsr106006

end function

#--------------------------------------------#
function bdbsr106_envia_email(l_data_extracao)
#--------------------------------------------#

  define l_assunto       char(100),
         l_erro_envio    integer,
         l_comando       char(200),
         l_data_extracao date

  # ---> INICIALIZACAO DAS VARIAVEIS

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_assunto  =  null
        let     l_erro_envio  =  null
        let     l_comando  =  null

  let l_comando    = null
  let l_erro_envio = null
  let l_assunto    = "Relacao das Vistorias e Revistorias marcadas para o dia: ",
                      l_data_extracao using "dd/mm/yyyy"

  # ---> COMPACTA O ARQUIVO DO RELATORIO
  let l_comando = "gzip -f ", m_path

  run l_comando

  let m_path = m_path clipped, ".gz"

  let l_erro_envio = ctx22g00_envia_email("BDBSR106", l_assunto, m_path)

  if l_erro_envio <> 0 then
     if l_erro_envio <> 99 then
        display "Erro ao enviar email(ctx22g00) - ", m_path
     else
        display "Nao existe email cadastrado para o modulo - bdbsr106"
     end if
  end if

end function

#----------------------------#
function bdbsr106_busca_path()
#----------------------------#

  # ---> INICIALIZACAO DAS VARIAVEIS
  let m_path = null

  # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
  let m_path = f_path("DBS","LOG")

  if m_path is null then
     let m_path = "."
  end if

  let m_path = m_path clipped,"/bdbsr106.log"

  call startlog(m_path)

  # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
  let m_path = f_path("DBS", "RELATO")

  if m_path is null then
     let m_path = "."
  end if

  let m_path = m_path clipped, "/bdbsr106.xls"

end function

#-----------------#
function bdbsr106()
#-----------------#

  define lr_dados        record
         vstsitcod       like dpakvst.vstsitcod,
         vstsitdat       like dpakvst.vstsitdat,
         socvclcod       like dpakvst.socvclcod,
         revdat          like dpakvst.revdat,
         vstpbmcod       like dpakvst.vstpbmcod,
         atldat          like dpakvst.atldat,
         atlmat          like dpakvst.atlmat,
         caddat          like dpakvst.caddat,
         cadmat          like dpakvst.cadmat,
         cademp          like dpakvst.cademp,
         atlemp          like dpakvst.atlemp,
         cadusrtip       like dpakvst.cadusrtip,
         atlusrtip       like dpakvst.atlusrtip,
         nomgrr          like dpaksocor.nomgrr,
         vstpbmdes       like dpakpbmvst.vstpbmdes,
         vstsitdes       like dpaksitvst.vstsitdes,
         pstcoddig       like datkveiculo.pstcoddig,
         nome_inclusao   like isskfunc.funnom,
         nome_alteracao  like isskfunc.funnom,
         atdvclsgl       like datkveiculo.atdvclsgl
  end record

  define l_data_atual    date,
         l_data_extracao date,
         l_hora_atual    datetime hour to minute,
         l_lidos         smallint

  # ---> INICIALIZACAO DAS VARIAVEIS

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_data_atual  =  null
        let     l_data_extracao  =  null
        let     l_hora_atual  =  null
        let     l_lidos  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize lr_dados to null

  let l_data_atual    = null
  let l_data_extracao = null
  let l_hora_atual    = null
  let l_lidos         = 0

  # ---> OBTER A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)
       returning l_data_atual, l_hora_atual

  if l_hora_atual > "08:00" and
     l_hora_atual < "23:59" then
     # ---> ANTES DAS "00:00"
     let l_data_extracao = (l_data_atual + 1 units day)
  else
     # ---> PASSOU DAS "00:00"
     let l_data_extracao = l_data_atual
  end if

  display " "
  display "Iniciando extracao vistorias e revistorias do dia: ", l_data_extracao

  start report bdbsr106_rel to m_path

  open cbdbsr106001 using l_data_extracao, l_data_extracao

  foreach cbdbsr106001 into lr_dados.vstsitcod,
                            lr_dados.vstsitdat,
                            lr_dados.socvclcod,
                            lr_dados.revdat,
                            lr_dados.vstpbmcod,
                            lr_dados.atldat,
                            lr_dados.atlmat,
                            lr_dados.caddat,
                            lr_dados.cadmat,
                            lr_dados.cademp,
                            lr_dados.atlemp,
                            lr_dados.cadusrtip,
                            lr_dados.atlusrtip

     let l_lidos = l_lidos + 1

     # ---> BUSCA O CODIGO DO PRESTADOR
     open cbdbsr106005 using lr_dados.socvclcod
     whenever error continue
     fetch cbdbsr106005 into lr_dados.pstcoddig,
                             lr_dados.atdvclsgl
     whenever error stop

     if sqlca.sqlcode <> 0 then
        display "Erro SELECT cbdbsr106005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        exit program(1)
     end if

     close cbdbsr106005

     # ---> BUSCA O NOME DE GUERRA DO SOCORRISTA
     open cbdbsr106002 using lr_dados.pstcoddig
     whenever error continue
     fetch cbdbsr106002 into lr_dados.nomgrr
     whenever error stop

     if sqlca.sqlcode <> 0 then
        display "Erro SELECT cbdbsr106002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        exit program(1)
     end if

     close cbdbsr106002

     # ---> BUSCA A DESCRICAO DA SITUACAO DA VISTORIA
     open cbdbsr106004 using lr_dados.vstsitcod
     whenever error continue
     fetch cbdbsr106004 into lr_dados.vstsitdes
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           let lr_dados.vstsitdes = null
        else
           display "Erro SELECT cbdbsr106004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr106004

     # ---> BUSCA A DESCRICAO DO PROBLEMA DA VISTORIA
     open cbdbsr106003 using lr_dados.vstpbmcod
     whenever error continue
     fetch cbdbsr106003 into lr_dados.vstpbmdes
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           let lr_dados.vstpbmdes = null
        else
           display "Erro SELECT cbdbsr106003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr106003

     # ---> BUSCA O NOME DO FUNCIONARIO QUE REALIZOU A INCLUSAO
     open cbdbsr106006 using lr_dados.cademp,
                             lr_dados.cadmat,
                             lr_dados.cadusrtip

     whenever error continue
     fetch cbdbsr106006 into lr_dados.nome_inclusao
     whenever error stop

     if sqlca.sqlcode <> 0 then
        display "Erro SELECT cbdbsr106006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        exit program(1)
     end if


     # ---> BUSCA O NOME DO FUNCIONARIO QUE REALIZOU A ALTERACAO
     open cbdbsr106006 using lr_dados.atlemp,
                             lr_dados.atlmat,
                             lr_dados.atlusrtip

     whenever error continue
     fetch cbdbsr106006 into lr_dados.nome_alteracao
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           let lr_dados.nome_alteracao = null
        else
           display "Erro SELECT cbdbsr106006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     output to report bdbsr106_rel(lr_dados.socvclcod,
                                   lr_dados.pstcoddig,
                                   lr_dados.nomgrr,
                                   lr_dados.vstsitdat,
                                   lr_dados.revdat,
                                   lr_dados.vstsitdes,
                                   lr_dados.vstpbmdes,
                                   lr_dados.caddat,
                                   lr_dados.cadmat,
                                   lr_dados.nome_inclusao,
                                   lr_dados.atldat,
                                   lr_dados.atlmat,
                                   lr_dados.nome_alteracao,
                                   lr_dados.atdvclsgl)

      # ---> INICIALIZACAO DAS VARIAVEIS
      initialize lr_dados to null

  end foreach

  close cbdbsr106001

  finish report bdbsr106_rel

  if l_lidos > 0 then
     call bdbsr106_envia_email(l_data_extracao)
  end if

  display "Extracao vistorias e revistorias realizada com sucesso !"

  display " "
  display "QTD.REGISTROS LIDOS......: ", l_lidos using "<<<<<<<<&"
  display " "

end function

#-------------------------------#
report bdbsr106_rel(lr_parametro)
#-------------------------------#

  define lr_parametro       record
         socvclcod          like dpakvst.socvclcod,
         pstcoddig          like datkveiculo.pstcoddig,
         nomgrr             like dpaksocor.nomgrr,
         vstsitdat          like dpakvst.vstsitdat,
         revdat             like dpakvst.revdat,
         vstsitdes          like dpaksitvst.vstsitdes,
         vstpbmdes          like dpakpbmvst.vstpbmdes,
         caddat             like dpakvst.caddat,
         cadmat             like dpakvst.cadmat,
         nome_inclusao      like isskfunc.funnom,
         atldat             like dpakvst.atldat,
         atlmat             like dpakvst.atlmat,
         nome_alteracao     like isskfunc.funnom,
         atdvclsgl          like datkveiculo.atdvclsgl
  end record

  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        print "CODIGO DO VEICULO",             ASCII(09), # ---> ASCII(09) = TAB
              "SIGLA",                         ASCII(09),
              "PRESTADOR",                     ASCII(09),
              "DATA DA VISTORIA",              ASCII(09),
              "DATA DA REVISTORIA",            ASCII(09),
              "DESCRICAO DA SITUACAO",         ASCII(09),
              "DESCRICAO DO PROBLEMA",         ASCII(09),
              "DATA INCLUSAO",                 ASCII(09),
              "RESPONSAVEL PELA INCLUSAO",     ASCII(09),
              "DATA ALTERACAO",                ASCII(09),
              "RESPONSAVEL PELA ALTERACAO"

  on every row

     print  lr_parametro.socvclcod      using "&&&&",           ASCII(09), # ---> ASCII(09) = TAB
            lr_parametro.atdvclsgl      clipped,                ASCII(09),
            lr_parametro.pstcoddig      using "&&&&&&", " - ",
            lr_parametro.nomgrr         clipped,                ASCII(09),
            lr_parametro.vstsitdat      using "yyyy-mm-dd",     ASCII(09),
            lr_parametro.revdat         using "yyyy-mm-dd",     ASCII(09),
            lr_parametro.vstsitdes      clipped,                ASCII(09),
            lr_parametro.vstpbmdes      clipped,                ASCII(09),
            lr_parametro.caddat         using "yyyy-mm-dd",     ASCII(09),
            lr_parametro.cadmat         using "&&&&&&", " ",
            lr_parametro.nome_inclusao  clipped,                ASCII(09),

            lr_parametro.atldat         using "yyyy-mm-dd",     ASCII(09),
            lr_parametro.atlmat         using "&&&&&&", " " clipped,
            lr_parametro.nome_alteracao clipped

end report
