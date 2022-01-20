#----------------------------------------------------------------------------#
# Sistema       :  SAPS                                                      #
# Modulo        :  bdbsr531.4gl                                             #
# Analista Resp.:  Marcia  Franzon                                           #
# PSI           :                                                            #
#                  Relatorio de clientes I                                   #
#                                                                            #
#                                                                            #
#                                                                            #
# Desenvolvimento: Marcia  Franzon                                           #
#----------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                           #
#   Data        Autor Fabrica  Origem    Alteracao                           #
# -------       ----- -------  ------    ---------                           #
#                                                                            #
#----------------------------------------------------------------------------#

  database porto

  globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"
  globals '/homedsa/projetos/dssqa/producao/I4GLParams.4gl'
  globals '/homedsa/projetos/geral/globals/glct.4gl'
  globals "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689

  define m_rel record
         clinom        like datkipecli.clinom
        ,celtelnum     like datkipecli.celtelnum
        ,telnum        like datkipecli.telnum
        ,cidnom        like datkipecli.cidnom
        ,ufdsgl        like datkipecli.ufdsgl
        ,clisitcod     char(10)
        ,srvnum        like datripeclisrv.srvnum
	,rlzsrvano     like datripeclisrv.rlzsrvano
        ,srvnom        like datripeclisrv.srvnom
        ,srvsoldat     like datripeclisrv.srvsoldat
        ,srvsitcod     char(10)
        ,srvaltobstxt  like datripeclisrv.srvaltobstxt
  end record

  define m_dataini     date
  define m_datafim     date
  define m_datchar     char(10)

  define mr_cliente record
         cpfcpjnum     like datkipecli.cpfcpjnum,
         cpjfilnum        like datkipecli.cpjfilnum,
         cpfcpjdig     like datkipecli.cpfcpjdig
  end record

  define lr_retorno record
         coderro         smallint
        ,msgerro         char(10000)
        ,pcapticrpcod    like fcomcaraut.pcapticrpcod
  end record

  define ws          record
     dirfisnom       like ibpkdirlog.dirfisnom,
     pathrel         char (60)
  end record

  define m_arqMensal char(50)
  define m_path   char(1000)

#---------------------------------------------------------
 main
#---------------------------------------------------------

    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read
    set lock mode to wait 10
    let m_datchar = TODAY
    let m_datchar = '01/' , m_datchar[4,10]
    let m_dataini = m_datchar
    let m_dataini = m_dataini - 1 units month
    let m_datafim = m_dataini + 1 units month  -1 units day


    initialize m_rel.*, mr_cliente.*, lr_retorno.* , ws.* , m_path to null

    call bdbsr531_prepare()

    call bdbsr531_processa()

    call bdbsr531_envia_email()

end main

#---------------------------------------------------------
  function bdbsr531_prepare()
#---------------------------------------------------------

    define l_cmd    char(1000)

#-----------------------------------------------------------------------------
# Dados de cliente e servicos
#-----------------------------------------------------------------------------
    let l_cmd = " select  a.clinom        ,a.cpfcpjnum, a.cpjfilnum ",
                "        ,a.cpfcpjdig     ",
                "        ,a.celtelnum     ,a.telnum  ",
                "        ,a.cidnom        ,a.ufdsgl  ",
                "        ,a.clisitcod     ,b.srvnum  ",
                "        ,b.rlzsrvano     ,b.srvnom  ",
		"        ,b.srvsoldat ",
                "        ,b.srvsitcod     ,b.srvaltobstxt ",
                " from   datkipecli a ",
                "       ,datripeclisrv b ",
                " where   a.ipeclinum = b.ipeclinum ",
                " and    (a.regiclhrrdat  between  ?  and ? ",
                " or      a.regalthrrdat  between  ?  and ?) ",
                " order by a.clinom ,b.srvsoldat "
    prepare pm_rel001 from l_cmd
    declare cm_rel001 cursor with hold for pm_rel001

  end function

#---------------------------------------------------------
  function bdbsr531_processa()
#---------------------------------------------------------

    #Arquivos de extração

    #Quantidade titulos

    #---------------------------------------------------------------
    # Define diretorios para relatorios e arquivos
    #---------------------------------------------------------------
    call f_path("DBS", "RELATO")
         returning m_path
    display "<187> relatorio-> Diretorio-> <", m_path,">"

    if m_path is null then
       let  m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr531.xls"

    #Diretorio dos arquivos

    let m_arqMensal   =  m_path
    display "<205> relatorio-> Aarquivo gerado em:- ", m_path
    #Start Relatorios

    start report bdbsr531_rel_Mensal to  m_arqMensal

    open cm_rel001 using m_dataini , m_datafim , m_dataini , m_datafim

    foreach cm_rel001 into m_rel.clinom
                          ,mr_cliente.*
                          ,m_rel.celtelnum
                          ,m_rel.telnum
                          ,m_rel.cidnom
                          ,m_rel.ufdsgl
                          ,m_rel.clisitcod
                          ,m_rel.srvnum
			  ,m_rel.rlzsrvano
                          ,m_rel.srvnom
                          ,m_rel.srvsoldat
                          ,m_rel.srvsitcod
                          ,m_rel.srvaltobstxt

          output to report bdbsr531_rel_Mensal()

    end foreach

  finish report bdbsr531_rel_Mensal

  end function

#---------------------------------------------------------
  report bdbsr531_rel_Mensal()
#---------------------------------------------------------

   define l_cgccpf    char(19)

   output
    left   margin    00
    right  margin    00
    top    margin    00
    bottom margin    00
    page   length    07


   format



   first page header
         print column 001,"Nome Completo",
                 ascii(9),"CPF/CNPJ",
                 ascii(9),"Tel Celular",
                 ascii(9),"Tel Residencial",
                 ascii(9),"Cidade",
                 ascii(9),"UF",
                 ascii(9),"Situaçao",
                 ascii(9),"Número do servico",
                 ascii(9),"Nome do Servico",
                 ascii(9),"Data do serviço ",
                 ascii(9),"Status do serviço",
                 ascii(9),"Observacao"

   on every row
      # Formata CPF
      if mr_cliente.cpjfilnum is null or
         mr_cliente.cpjfilnum  = 0    then
         let l_cgccpf = mr_cliente.cpfcpjnum using '&&&&&&&&&','-',
                        mr_cliente.cpfcpjdig using '&&'
      else
         let l_cgccpf = mr_cliente.cpfcpjnum using '&&&&&&&&&','/',
                        mr_cliente.cpjfilnum    using '&&&&','-',
                        mr_cliente.cpfcpjdig using '&&'
      end if

      IF m_rel.srvsitcod = 'I' THEN
	 LET m_rel.srvsitcod  = 'Pendente'
      ELSE
	 LET m_rel.srvsitcod  = 'Pago'
      END IF
      IF m_rel.clisitcod = 'C' THEN
	 LET m_rel.clisitcod = 'Cancelado'
      ELSE
	 LET m_rel.clisitcod = 'Ativo'
      END IF

      print column 001,m_rel.clinom ,
                       ascii(9),l_cgccpf ,
                       ascii(9),m_rel.celtelnum using '##&&&&&&&&&&',
                       ascii(9),m_rel.telnum using '##&&&&&&&&&&',
                       ascii(9),m_rel.cidnom ,
                       ascii(9),m_rel.ufdsgl,
                       ascii(9),m_rel.clisitcod ,
                       ascii(9),m_rel.srvnum using '######&&&&','/'
			       ,m_rel.rlzsrvano using "&&",
                       ascii(9),m_rel.srvnom ,
                       ascii(9),m_rel.srvsoldat,
                       ascii(9),m_rel.srvsitcod,
                       ascii(9),m_rel.srvaltobstxt

  end report

 #----------------------------------------------------------------------------
 function bdbsr531_envia_email()
 #----------------------------------------------------------------------------

    #Arquivos de extração

    define l_chave  like iddkdominio.cponom


    define l_assunto    char(100)

    define l_cmd        char(5000)
          ,l_log        char(300)
          ,l_erro_envio smallint

    let l_cmd   = null
    let l_log   = null
    let l_chave = "bdbsr531"

    # COMPACTA ARQUIVO GERADO

    let l_cmd = "gzip -f " , m_arqMensal
    run l_cmd

    let m_arqMensal = m_arqMensal  clipped, ".gz "

    initialize l_cmd to null

    display ''
    let l_log = 'Inicio do envio do email: ',today,' as: ',time
    display l_log

    #Diretorio dos arquivos

    let l_assunto = "Relatorio Mensal Clientes I "

    let l_erro_envio = ctx22g00_envia_email("BDBSR531",l_assunto,m_arqMensal)

     if  l_erro_envio <> 0 then
	 if  l_erro_envio <> 99 then
	     display "Erro ao enviar email(ctx22g00) - ", l_erro_envio
	 else
	     display "Nao existe email cadastrado para o modulo - BDBSR531"
         end if
     end if

end function
