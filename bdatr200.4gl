#----------------------------------------------------------------------------#
# Sistema       :  SAPS                                                      #
# Modulo        :  bdatr200.4GL                                              #
# Analista Resp.:  ALBERTO RODRIGUES                                         #
# PSI           :                                                            #
#                  Relatorio de Cartoes Diarios                              #
#                                                                            #
#                                                                            #
#                                                                            #
# Desenvolvimento: Alberto Rodrigues                                         #
#----------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                           #
#   Data        Autor Fabrica  Origem    Alteracao                           #
# -------       ----- -------  ------    ---------                           #
#                                                                            #
#----------------------------------------------------------------------------#

  database porto

  globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"
  globals "/homedsa/projetos/dssqa/producao/I4GLParams.4gl"
  globals '/homedsa/projetos/geral/globals/glct.4gl'
  globals "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689

  define b_rel record
         orgnum         like datmpgtinf.orgnum
        ,prpnum         like datmpgtinf.prpnum
        ,atdsrvnum      like datmpgtinf.atdsrvnum
        ,atdsrvano      like datmpgtinf.atdsrvano
        ,clinom         like datmcrdcrtinf.clinom
        ,atldat         like datmefutrn.atldat
        ,trnsttcod      like datmefutrn.trnsttcod
        ,bndcod         like datmcrdcrtinf.bndcod
        ,crtnum         like datmcrdcrtinf.crtnum
        ,carbndnom      like fcokcarbnd.carbndnom
        ,trnsttdes      like datktrnstt.trnsttdes
        ,cbrparqtd      like datmefutrn.cbrparqtd
        ,vnddat         like datmpgtinf.atldat
        ,cbrvlr         like datmefutrn.cbrvlr
        ,trnerrmsgtxt   like datmtrnerrmsg.trnerrmsgtxt
        #,nsunum        like datmtrnnsu.nsunum
        ,titnum         like datmtit.titnum
        ,titnum1        like datmtit.titnum
        ,titnum2        like datmtit.titnum
        ,titnum3        like datmtit.titnum
        ,titnum4        like datmtit.titnum
        ,titsitnom      like datktitsit.titsitnom
        ,n_tit          smallint
  end record

  define m_data datetime year to second
  define m_data1 datetime year to second

  define mr_cliente record
         cgccpfnum     like gsakseg.cgccpfnum,
         cgcord        like gsakseg.cgcord,
         cgccpfdig     like gsakseg.cgccpfdig
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

  define l_cartao char(100)
  define n_cartao decimal(19,0)

  define m_descripto char(01)

  define m_arqDiario char(50)
   define m_rel      smallint

#---------------------------------------------------------
 main
#---------------------------------------------------------

    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read
    set lock mode to wait 10
    let m_data = today - 1 units day


    initialize b_rel.*, mr_cliente.*, lr_retorno.* , ws.* , m_descripto to null

    call b_rel_prepare()

    call b_rel_processa()

    #Envia E-mail
    call rel_email()

    #call rel_apagar_arquivos()

end main

#---------------------------------------------------------
  function b_rel_prepare()
#---------------------------------------------------------

    define l_cmd    char(1000)

    let l_cmd = " select  b.orgnum        ,b.prpnum     ",
                "        ,b.atdsrvnum     ,b.atdsrvano  ",
                "        ,c.clinom        ,a.atldat     ",
                "        ,a.trnsttcod     ,c.bndcod     ",
                "        ,c.crtnum        ,d.carbndnom  ",
                "        ,e.trnsttdes     ,a.cbrparqtd  ",
                "        ,b.atldat        ,a.cbrvlr     ",
                " from    datmefutrn a    ,datmpgtinf b ",
                "        ,datmcrdcrtinf c ,fcokcarbnd d ",
                "        ,datktrnstt e                  ",
                " where   a.atdsrvnum = b.atdsrvnum     ",
                " and     a.atdsrvano = b.atdsrvano     ",
                " and     b.orgnum    = c.orgnum        ",
                " and     b.prpnum    = c.prpnum        ",
                " and     c.bndcod    = d.carbndcod     ",
                " and     a.trnsttcod = e.trnsttcod     ",
                " and     a.pgtfrmcod = 1               ",
                " and     a.atldat    = ?               ",
                " and     c.pgtseqnum = (select max(d.pgtseqnum) from datmcrdcrtinf d ",
                "                         where b.prpnum = d.prpnum ) " ,
                " order by b.orgnum ,b.prpnum "
                #" order by a.atldat "
    prepare pb_rel001 from l_cmd
    declare cb_rel001 cursor with hold for pb_rel001

    let l_cmd = "select b.cgccpfnum, b.cgcord,    b.cgccpfdig ",
                "from   datmligacao a, datrligcgccpf b        ",
                "where  a.lignum  = b.lignum                  ",
                "and    atdsrvnum = ?                         ",
                "and    atdsrvano = ?                         "
    prepare pb_rel002 from l_cmd
    declare cb_rel002 cursor with hold for pb_rel002

    let l_cmd = ' select cpodes '
               ,'   from iddkdominio '
               ,'  where cponom = ? '
               ,'  order by cpodes '
    prepare pb_rel003 from l_cmd
    declare cb_rel003 cursor for pb_rel003

    let l_cmd = ' select trnerrmsgtxt '
               ,' from datmtrnerrmsg '
               ,' where atdsrvnum = ? '
               ,' and atdsrvano = ?  '
    prepare pb_rel004 from l_cmd
    declare cb_rel004 cursor for pb_rel004

    #let l_cmd = ' select nsunum '
    #           ,' from datmtrnnsu  '
    #           ,' where atdsrvnum = ? '
    #           ,' and atdsrvano = ?  '
    #prepare pb_rel005 from l_cmd
    #declare cb_rel005 cursor for pb_rel005

    let l_cmd = ' select a.titnum, b.titsitnom '
               ,' from datmtit a,  datktitsit b '
               ,' where a.atdsrvnum = ? '
               ,' and a.atdsrvano = ?  '
               ,' and b.titsitnum = a.titsitnum '
    prepare pb_rel006 from l_cmd
    declare cb_rel006 cursor for pb_rel006

    let l_cmd = ' select count(titnum) '
               ,' from datmtit a'
               ,' where a.atdsrvnum = ? '
               ,' and a.atdsrvano = ?  '
    prepare pb_rel007 from l_cmd
    declare cb_rel007 cursor for pb_rel007

  end function

#---------------------------------------------------------
  function b_rel_processa()
#---------------------------------------------------------

    #Arquivos de extração

    #define l_arqDiario char(50)

    #Quantidade titulos
    define l_titqtd      smallint

    #---------------------------------------------------------------
    # Define diretorios para relatorios e arquivos
    #---------------------------------------------------------------
    call f_path("DAT", "RELATO")
         returning ws.dirfisnom
    display "<193> bdatr200-> Diretorio-> <", ws.dirfisnom,">"
    if ws.dirfisnom = "." then
       let ws.dirfisnom = "/projetos/usuar"
    end if

    let ws.pathrel = ws.dirfisnom clipped, "/SAPS_Relatorio_Diario.xls"
    #let ws.pathrel = ws.dirfisnom clipped, "/SAPS.xls"


    #Diretorio dos arquivos
    #let l_arqDiario   = '/asheeve/SAPS_Relatorio_Diario.xls'

    let m_arqDiario   =  ws.pathrel
    display "<206> bdatr200-> Aarquivo gerado em:- ", ws.dirfisnom
    #Start Relatorios
    let m_descripto = "S"

    start report b_rel_Diario to m_arqDiario

    open cb_rel001 using m_data

    foreach cb_rel001 into b_rel.orgnum
                          ,b_rel.prpnum
                          ,b_rel.atdsrvnum
                          ,b_rel.atdsrvano
                          ,b_rel.clinom
                          ,b_rel.atldat
                          ,b_rel.trnsttcod
                          ,b_rel.bndcod
                          ,b_rel.crtnum
                          ,b_rel.carbndnom
                          ,b_rel.trnsttdes
                          ,b_rel.cbrparqtd
                          ,b_rel.vnddat
                          ,b_rel.cbrvlr
          display "<228> b_rel.crtnum >> ", b_rel.crtnum,"<",m_descripto, ">"
          let m_descripto = "S"
          #Obter informações do CPF do Cliente
          open  cb_rel002 using b_rel.atdsrvnum, b_rel.atdsrvano
          fetch cb_rel002 into  mr_cliente.cgccpfnum
                               ,mr_cliente.cgcord
                               ,mr_cliente.cgccpfdig
          display "<235> b_rel.trnsttcod >> ", b_rel.trnsttcod
          if b_rel.trnsttcod = 1 then
             let b_rel.trnerrmsgtxt = "Cartão Aprovado"
          else
             #Obter motivo de recusa
             whenever error continue
             open  cb_rel004 using b_rel.atdsrvnum, b_rel.atdsrvano
             fetch cb_rel004 into  b_rel.trnerrmsgtxt
             whenever error stop
             if sqlca.sqlcode = 100 then
                let b_rel.trnerrmsgtxt = "Nao gerou Titulo"
             else
                if b_rel.trnerrmsgtxt[1,5] = "Erro" then
                   let b_rel.trnerrmsgtxt = "Autorizacao negada - NÃO ENCONTROU A CONSULTA BIN"
                end if
             end if
          end if

          open cb_rel007 using b_rel.atdsrvnum, b_rel.atdsrvano
          fetch cb_rel007 into l_titqtd
          display "<251> l_titqtd >> <", l_titqtd,"><m_descripto = ",m_descripto,">"
          let b_rel.n_tit = 0
          if l_titqtd > 0 then
             display "<254> l_titqtd >> ", l_titqtd
             let b_rel.titnum1 = null
             let b_rel.titnum2 = null
             let b_rel.titnum3 = null
             let b_rel.titnum4 = null

             open cb_rel006 using b_rel.atdsrvnum, b_rel.atdsrvano
             foreach cb_rel006 into b_rel.titnum,
                                    b_rel.titsitnom

             let b_rel.n_tit = b_rel.n_tit + 1
             case b_rel.n_tit
                  when 1
                       let b_rel.titnum1 = b_rel.titnum
                  when 2
                       let b_rel.titnum2 = b_rel.titnum
                  when 3
                       let b_rel.titnum3 = b_rel.titnum
                  when 4
                       let b_rel.titnum4 = b_rel.titnum
                  otherwise
                       let b_rel.titnum1 = b_rel.titnum
                       #Imprimir Diario
                       #output to report b_rel_Diario()
                       #let m_descripto = "N"
             end case

             display "<281> Titulos <",b_rel.titnum1,"><",b_rel.titnum2,"><",b_rel.titnum3,"><",b_rel.titnum4,">"
             end foreach
             #let m_descripto = "S"
          else
             let m_descripto = "S"
             display "<286> l_titqtd >> <", l_titqtd,"><m_descripto = ",m_descripto,">"
             let b_rel.titnum1   = null
             let b_rel.titnum2   = null
             let b_rel.titnum3   = null
             let b_rel.titnum4   = null
             let b_rel.titsitnom = null
             #output to report b_rel_Diario()
          end if
          let m_rel = true
          output to report b_rel_Diario()

    end foreach

  finish report b_rel_Diario

  end function

#---------------------------------------------------------
  report b_rel_Diario()
#---------------------------------------------------------

   define l_cgccpf    char(15)
   define l_transacao char(25)

   output
   report to pipe "SAPS_Relatorio_Diario.xls"
   page   length  01
   left   margin  00
   right  margin  80
   bottom margin  00
   top    margin  00

   format

   on every row

      if pageno = 1 then
         print column 001,"Numero Serviço",
                 ascii(9),"Ano Serviço",
                 ascii(9),"Nome Cliente",
                 ascii(9),"CPF Cliente",
                 ascii(9),"Status Transação",
                 ascii(9),"Data e Hora Transação",
                 ascii(9),"Bandeira Cartão",
                 ascii(9),"Número Cartão",
                 ascii(9),"Motivo Recusa",
                 ascii(9),"Quantidade Parcelas",
                 ascii(9),"Origem",
                 ascii(9),"Proposta",
                 ascii(9),"Data Venda",
                 ascii(9),"Data Aprovacao",
                 ascii(9),"Valor",
                 ascii(9),"Numero Titulo 1",
                 ascii(9),"Numero Titulo 2",
                 ascii(9),"Numero Titulo 3",
                 ascii(9),"Numero Titulo 4",
                 ascii(9),"Situacao Titulo"
      end if

      if m_descripto = "S" then
         let l_cartao = ""
         let n_cartao = 0
         # Descriptografa o numero do cartao
         display "<348> b_rel.crtnum >> ", b_rel.crtnum
          call ffctc890("D",b_rel.crtnum)
               returning lr_retorno.*
         display "<351> lr_retorno.pcapticrpcod >> ", lr_retorno.pcapticrpcod
         let n_cartao = lr_retorno.pcapticrpcod
         let l_cartao = n_cartao
      end if

      let b_rel.crtnum = "XXXX XXXX XXXX ", l_cartao[13,16] using '&&&&'

      # Formata CPF
      if mr_cliente.cgcord is null or
         mr_cliente.cgcord  = 0    then
         let l_cgccpf = mr_cliente.cgccpfnum using '&&&&&&&&&',
                        mr_cliente.cgccpfdig using '&&'
      else
         let l_cgccpf = mr_cliente.cgccpfnum using '&&&&&&&&&',
                        mr_cliente.cgcord    using '&&&&',
                        mr_cliente.cgccpfdig using '&&'
      end if

      let l_transacao = b_rel.trnsttcod using "&&","-",b_rel.trnsttdes

         print column 001,b_rel.atdsrvnum using '&&&&&&&',
                 ascii(9),b_rel.atdsrvano using '&&',
                 ascii(9),b_rel.clinom,
                 ascii(9),l_cgccpf,
                 ascii(9),l_transacao,
                 ascii(9),b_rel.atldat,
                 ascii(9),b_rel.bndcod using "&&","-", b_rel.carbndnom,
                 ascii(9),b_rel.crtnum,
                 ascii(9),b_rel.trnerrmsgtxt clipped,
                 ascii(9),b_rel.cbrparqtd using "&&",
                 ascii(9),b_rel.orgnum using '&&&&&&&' ,
                 ascii(9),b_rel.prpnum using '&&&&&&&' ,
                 ascii(9),b_rel.vnddat,
                 ascii(9),b_rel.atldat,
                 ascii(9),b_rel.cbrvlr,
                 ascii(9),b_rel.titnum1,
                 ascii(9),b_rel.titnum2,
                 ascii(9),b_rel.titnum3,
                 ascii(9),b_rel.titnum4,
                 ascii(9),b_rel.titsitnom

  end report

 #----------------------------------------------------------------------------
 function rel_email()
 #----------------------------------------------------------------------------

    #Arquivos de extração
    #define l_arqDiario char(50)

    define w_maqfin like ibpkdbspace.srvnom

    define l_chave  like iddkdominio.cponom


    define lr_mensagem  record
           sistema      char(010)
          ,remetente    char(050)
          ,para         char(10000)
          ,cc           char(10000)
          ,bcc          char(3000)
          ,subject      char(200)
          ,msg          char(300)
          ,arquivo      char(300)
          end record
    define  l_mail             record
      de                 char(500)   # De
     ,para               char(10000)  # Para
     ,cc                 char(10000)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
    end  record
    define l_coderro  smallint
    define msg_erro char(500)

    define l_cmd        char(5000)
          ,l_sql        char(200)
          ,l_email      char(200)
          ,l_log        char(300)
          ,l_cont       integer
          ,l_ret        integer

    let l_cmd   = null
    let l_ret   = null
    let l_sql   = null
    let l_email = null
    let l_cont  = 0
    let l_log   = null
    let l_chave = "email_saps"
    initialize lr_mensagem.* to null

    #--------------------------------------
    # BUSCA OS E-MAILS
    #--------------------------------------
    whenever error continue
    open cb_rel003 using l_chave
    foreach cb_rel003 into lr_mensagem.cc
    whenever error stop

       if sqlca.sqlcode <> 0 then
          let lr_mensagem.para = "marcosSilva.araujo@portoseguro.com.br" clipped
          display "<443> E-mails nao cadastrado. Sera enviado para Marcos<cobrança>"
       else
           if lr_mensagem.para is null then
              let lr_mensagem.para = lr_mensagem.cc clipped
           else
              let lr_mensagem.para = lr_mensagem.para clipped, ",",lr_mensagem.cc
           end if
       end if
    end foreach
    close cb_rel003


    display ''
    let l_log = 'Inicio do envio do email: ',today,' as: ',time
    display l_log


    let lr_mensagem.sistema = "Diario"
    let lr_mensagem.subject = "Cartoes Diario - Data: ",m_data

     #PSI-2013-23297 - Inicio
     let l_mail.de = "Central24H"
     let l_mail.para =  lr_mensagem.para
     let l_mail.cc = ""
     let l_mail.cco = ""
     let l_mail.assunto =  lr_mensagem.subject
     let l_mail.mensagem = "<html><body><font face = Times New Roman>Cart&otilde;es Di&aacute;rio - Data: ",m_data
                          ,"<br><br></font></body></html>"
     let l_mail.id_remetente = "Central24H"
     let l_mail.tipo = "html"
     if m_rel = true then
          call figrc009_attach_file(m_arqDiario)
          display "Arquivo anexado com sucesso"
     else
          let l_mail.mensagem = "Nao existem registros a serem processados."
     end if

     call figrc009_mail_send1 (l_mail.*)
       returning l_coderro,msg_erro
     #PSI-2013-23297 - Fim
    let l_log =  'Envio de email: '
    if l_coderro <> 0 then
       let l_log =  'Erro ', l_ret, ' ao enviar email'
       display l_log
    else
       let l_log =  'Email enviado com sucesso ',l_ret
       display l_log
       let l_log =  'Email enviado para: ',lr_mensagem.para clipped
    end if

    display ''
    let l_log = 'Fim do envio do email: ',today,' as: ',time

    display l_log

    if l_ret = 0 then
       let l_cmd = 'rm -f ', m_arqDiario
       run l_cmd
    else
       display "<494> Arquivo nao sera apagado-> ", m_arqDiario
    end if

end function