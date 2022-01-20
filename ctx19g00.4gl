#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CENTRAL 24 HS                                              #
# Modulo        : ctx19g00                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 182559                                                     #
# OSF           : 34371                                                      #
#                 Interface para o sistema SAC                               #
#............................................................................#
# Desenvolvimento: Paulo, META                                               #
# Liberacao      : 13/04/2004                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 30/08/2006 alberto            psi191965 F0 Servico Furto Roubo MQ          #
# 21/09/2006 Ligia Mattge       PSI 202720 Parametro na cts16g00_servicos    #
#----------------------------------------------------------------------------#
# 21/12/2006  Priscila         CT         Chamar funcao especifica para      #
#                                         insercao em datmlighist            #
#                                                                            #
# 01/10/2008 Amilton,Meta   PSI 223689  Incluir tratamento de erro com       #
#                                       global ( Isolamento U01 )            #
#----------------------------------------------------------------------------#
# 30/10/2008 Amilton,Meta   PSI 230669  Incluir atdnum no servico furto e    #
#                                       roubo F10                            #
#----------------------------------------------------------------------------#
# 13/03/2009 Carla Rampazzo PSI 235580 -Incluir tratamento p/ novos assuntos #
#                                       do Curso de Direcao Defensiva        #
#                                      -A funcao ctx19g00_lig_corr()  passou #
#                                       a receber mais dois argumetos        #
#                                       Nro/Status do Agedto.Dir.Defensiva   #
#----------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853      Implementacao do PSS             #
#----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Altera��o da utiliza��o do sendmail  #
##############################################################################

globals '/homedsa/projetos/dssqa/producao/I4GLParams.4gl'
globals '/homedsa/projetos/geral/globals/glct.4gl'
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689

define m_prep_sql    smallint

## PSI 191965

define m_historico   char(32766)
define m_hist_qtd    smallint
define m_conta       smallint
define m_conta_linha smallint

#---------------------------
function ctx19g00_prepare()
#---------------------------
 define l_sql     char(500)

 let l_sql = 'select c24evtcod '
            ,'  from datkevt '
           ,' where c24astcod = ? '

 prepare pctx19g00001 from l_sql
 declare cctx19g00001 cursor for pctx19g00001

 let l_sql = 'select atdsrvnum, atdsrvano '
            ,'  from datmreclam '
            ,' where lignum = ? '

 prepare pctx19g00002 from l_sql
 declare cctx19g00002 cursor for pctx19g00002

 let l_sql = 'select succod, ramcod, aplnumdig, itmnumdig '
            ,'  from datrligapol '
            ,' where lignum = ? '

 prepare pctx19g00003 from l_sql
 declare cctx19g00003 cursor for pctx19g00003

 let l_sql = 'update datmreclam set (atdsrvnum, atdsrvano) = (?, ?) '
            ,' where lignum = ? '

 prepare pctx19g00004 from l_sql

 let l_sql = 'update datmligacao set c24astcod = ? '
            ,' where lignum = ? '

 prepare pctx19g00005 from l_sql

 let l_sql = 'insert into datmsitrecl (lignum, c24rclsitcod, funmat, '
            ,'                         rclrlzdat, rclrlzhor, c24astcod, '
            ,'                         empcod, usrtip) '
            ,'                 values (?, ?, ?, ?, ?, ?, ?, ?)'

 prepare pctx19g00006 from l_sql

 let l_sql = 'select max(a.c24rclsitcod) '
            ,'  from datmsitrecl a '
            ,' where a.lignum = ? '
            ,'  and  a.rclrlzdat = (select max(b.rclrlzdat) from datmsitrecl b '
            ,'                       where b.lignum = a.lignum) '

 prepare pctx19g00007 from l_sql
 declare cctx19g00007 cursor for pctx19g00007

 let l_sql = 'select lignum ',
             '  from datratdlig ',
             ' where atdnum = ? '

 prepare pctx19g00008 from l_sql
 declare cctx19g00008 cursor for pctx19g00008

 let l_sql = 'select lignum,c24txtseq,c24ligdsc ',
             '  from datmlighist ',
             ' where lignum = ? '

 prepare pctx19g00009 from l_sql
 declare cctx19g00009 cursor for pctx19g00009

 let l_sql = " select lignum , c24astcod "
             , "      , ligdat , lighorinc "
             , " from datmligacao  "
             , " where lignum = ? "

 prepare pctx19g00010 from l_sql
 declare cctx19g00010 cursor for pctx19g00010

 let l_sql = " select c24astdes ",
             " from datkassunto ",
             " where c24astcod = ? "

 prepare pctx19g00011 from l_sql
 declare cctx19g00011 cursor for pctx19g00011

 let l_sql =  " select a.atdnum,a.atdtrnnum, ",
              " a.trnlignum,a.necgerlignum ",
              " from datmatdtrn a ",
              " where a.atdnum = ? ",
              " and a.atdsegfunmat is null ",
              " and a.atdtrnnum = (select max(b.atdtrnnum) ",
              " from datmatdtrn b ",
              " where b.atdnum = a.atdnum  )"

 prepare pctx19g00013 from l_sql
 declare cctx19g00013 cursor for pctx19g00013

 let l_sql =  " select ramcod,succod,aplnumdig, ",
              "itmnumdig,prporg,prpnumdig, ",
              "semdoctocgccpfnum,semdoctocgcord,semdoctocgccpfdig ",
              " from datmatd6523  ",
              " where atdnum = ? "

 prepare pctx19g00014 from l_sql
 declare cctx19g00014 cursor for pctx19g00014


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
   prepare pctx19g00015 from l_sql


 let m_prep_sql = true

end function

#----------------------------------
function executeService(l_servico)
#----------------------------------
 define l_servico       char(50)
       ,l_retorno       char(5000)

 define lr_param        record
        lignum          like datmreclam.lignum,
        c24astcod       like datkevt.c24astcod,
        atdsrvnum       like datmservico.atdsrvnum,
        atdsrvano       like datmservico.atdsrvano,
        funmat          like isskfunc.funmat,
        empcod          like isskfunc.empcod,
        situacao        smallint
 end record

 define l_ret_lig
        record
        erro      smallint,
        msgerro   char(80),
        lignum    like datmligacao.lignum
        end record

 define l_ret_tab
        record
        sqlcode         integer,
        tabname         like systables.tabname
        end record

 define l_mensagem_erro char(80)

 ## PSI191965

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctx19g00_prepare()
 end if

 initialize lr_param.*  to null
 let lr_param.situacao = 10

 let l_retorno = null
 display "**** <ctx19g00> Servico - l_servico = ", l_servico
 case l_servico
      when "LeServicos"
           let l_retorno =  ctx19g00_le_servicos()

      when "InterfacePS"
           let l_retorno = ctx19g00_interfaceps(lr_param.*)

      when "GravaHistorico"
           let l_retorno = ctx19g00_grava_historico()

      when "ConcluiReclamacao"
           let l_retorno = ctx19g00_conclui_reclamacao()

      when "RegistrarLigacaoAtendimentoCorretor"
           let l_retorno =
               ctx19g00_lig_corr("RegistrarLigacaoAtendimentoCorretor")

      when "RegistrarHistoricoAtendimento"
           let l_retorno =
               ctx19g00_grava_historico_atd("RegistrarHistoricoAtendimento")

      when "REGISTRARLIGACAOCENTRAL24H"
           display " cdr 001 - INICIO "
           let l_retorno = ctx19g00_reg_lig_ct24h()
           display " cdr 002 - FIM "

      when "REGISTRARENDERECOENVIOCARTAO"
           let l_retorno = ctx19g00_reg_end_env_crt()

      when  "REGISTRALIGACAOVISTSINISAUTO"
           let l_retorno = ctx19g00_reg_lig_vst_sin_auto()

      when  "REGISTRASERVICOFURTOROUBO"
           let l_retorno = ctx19g00_reg_ligsrv_furto_roubo()

      when  "REGISTRACANVISTSINISAUTO"
           let l_retorno = ctx19g00_can_vst_sin_auto()

      when  "REGISTRARETVISTSINISAUTO"
           let l_retorno = ctx19g00_ret_vst_sin_auto()

      when  "VISUALIZARLAUDOVIDROS"
           let l_retorno = ctq00m02(g_paramval[1],#ssamsin.ramcod
                                    g_paramval[2],#ssamsin.sinano
                                    g_paramval[3],#ssamsin.sinnum
                                    g_paramval[4])#ssamitem.sinitmseq
      when  "GERARATENDIMENTO"
             let l_retorno = ctx19g00_gera_atd()

      when "RECUPERARHISTORICOLIG"
            let l_retorno =  ctx19g00_rec_historico_lig()

      when "RECUPERALIGACOES"
            let l_retorno =  ctx19g00_rec_ligacoes()

      when "REGISTRATRANSFERENCIA"
           let l_retorno =  ctx19g00_reg_transf()

      when "CAPTURATRANSFERENCIA"
           let l_retorno =  ctx19g00_rec_trn()

      otherwise
           let l_retorno = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                          ,"<servicos>ERRO - Servico (", l_servico clipped,") Invalido</servicos>"
 end case

 return l_retorno

end function

#-------------------------------
function ctx19g00_le_servicos()
#-------------------------------
 define l_lista           char(5000)
       ,l_lignum          like datmreclam.lignum
       ,l_c24astcod       like datkevt.c24astcod
       ,l_funmat          like isskfunc.funmat
       ,l_empcod          like isskfunc.empcod
       ,l_c24evtcod       like datkevt.c24evtcod
       ,l_atdsrvnum       like datmreclam.atdsrvnum
       ,l_atdsrvano       like datmreclam.atdsrvano

 define lr_param          record
        lignum            like datmreclam.lignum,
        c24astcod         like datkevt.c24astcod,
        atdsrvnum         like datmservico.atdsrvnum,
        atdsrvano         like datmservico.atdsrvano,
        funmat            like isskfunc.funmat,
        empcod            like isskfunc.empcod
 end record

 define l_succod          like datrligapol.succod
       ,l_ramcod          like datrligapol.ramcod
       ,l_aplnumdig       like datrligapol.aplnumdig
       ,l_itmnumdig       like datrligapol.itmnumdig

 define lr_serv           record
        succod            like datrservapol.succod,
        ramcod            like datrservapol.ramcod,
        aplnumdig         like datrservapol.aplnumdig,
        itmnumdig         like datrservapol.itmnumdig,
        atdsrvorg         like datmservico.atdsrvorg,
        vcllicnum         like datmservico.vcllicnum,
        nrdias            integer,
        crtsaunum         like datrligsau.crtnum
 end record

 define lr_email record
        de       char(11),
        para     char(33),
        cc       char(32),
        assunto  char(25),
        data     date,
        hora     datetime hour to second,
        comando  char(1200),
        msg      char(700)
 end record

  define  l_mail             record
      de                 char(500)   # De
     ,para               char(5000)  # Para
     ,cc                 char(500)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
  end  record
  define l_coderro  smallint
  define msg_erro char(500)
 let l_lista     = null

 let l_lignum    = g_paramval[1]
 let l_c24astcod = g_paramval[2]
 let l_funmat    = g_paramval[3]
 let l_empcod    = g_paramval[4]

 open cctx19g00001 using l_c24astcod
 whenever error continue
 fetch cctx19g00001 into l_c24evtcod
 whenever error stop

 if sqlca.sqlcode = -404 then

    initialize lr_email to null

    let lr_email.de      = "Central-24h"
    let lr_email.para    = "Scheid_Lucas@correioporto"
    let lr_email.cc      = "Ruiz_Carlos@correioporto"
    let lr_email.assunto = "PROBLEMAS - INTERFACE SAC"
    let lr_email.data    = today
    let lr_email.hora    = current

    let lr_email.msg = "Erro: -404 no acesso ao cursor cctx19g00001.", " | ",
                       " Data - Hora: ", lr_email.data, " - ", lr_email.hora, " | ",
                       " l_lignum: ",    l_lignum,    " | ",
                       " l_c24astcod: ", l_c24astcod, " | ",
                       " l_funmat: ",    l_funmat,    " | ",
                       " l_empcod: ",    l_empcod

    #PSI-2013-23297 - Inicio
    let l_mail.de = lr_email.de
    let l_mail.para =  lr_email.para
    let l_mail.cc = lr_email.cc
    let l_mail.cco = ""
    let l_mail.assunto = lr_email.assunto
    let l_mail.mensagem = lr_email.msg
    let l_mail.id_remetente = "CT24H"
    let l_mail.tipo = "text"
    call figrc009_mail_send1 (l_mail.*)
     returning l_coderro,msg_erro
    #PSI-2013-23297 - Fim

 end if

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let l_c24evtcod = null
    else
       let l_lista = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                    ,"<servicos>ERRO - SELECT cctx19g00001 - ",sqlca.sqlcode
                    ," - ",sqlca.sqlerrd[2],"</servicos>"
       return l_lista
    end if
 end if

 if l_c24evtcod is not null then
    open cctx19g00002 using l_lignum
    whenever error continue
    fetch cctx19g00002 into l_atdsrvnum
                           ,l_atdsrvano
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_atdsrvnum = null
       else
          let l_lista = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                       ,"<servicos>ERRO - SELECT cctx19g00002 - ",sqlca.sqlcode
                       ," - ",sqlca.sqlerrd[2],"</servicos>"
          return l_lista
       end if
    end if

    if l_atdsrvnum is null or
       l_atdsrvnum = 0 then
       open cctx19g00003 using l_lignum
       whenever error continue
       fetch cctx19g00003 into l_succod, l_ramcod, l_aplnumdig, l_itmnumdig
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             let l_succod    = null
             let l_ramcod    = null
             let l_aplnumdig = null
             let l_itmnumdig = null
          else
             let l_lista = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                          ,"<servicos>ERRO - SELECT cctx19g00003 - ",sqlca.sqlcode
                          ," - ",sqlca.sqlerrd[2],"</servicos>"
             return l_lista
          end if
       end if
       if l_succod is not null    and
          l_ramcod is not null    and
          l_aplnumdig is not null then
          initialize lr_serv.*  to null
          let lr_serv.succod    = l_succod
          let lr_serv.ramcod    = l_ramcod
          let lr_serv.aplnumdig = l_aplnumdig
          let lr_serv.itmnumdig = l_itmnumdig
          let lr_serv.nrdias    = 90
          call cts16g00_servicos(lr_serv.*)
               returning l_lista, l_atdsrvnum, l_atdsrvano
          if l_atdsrvnum is not null and l_atdsrvnum <> 0 then
             initialize lr_param.*  to null
             let lr_param.lignum    = l_lignum
             let lr_param.c24astcod = l_c24astcod
             let lr_param.funmat    = l_funmat
             let lr_param.empcod    = l_empcod
             let lr_param.atdsrvnum = l_atdsrvnum
             let lr_param.atdsrvano = l_atdsrvano
             let l_lista = ctx19g00_interfaceps(lr_param.*,10)
          else
             if l_lista matches '*<servicoqtd></servicoqtd>*' then
                initialize lr_param.*  to null
                let lr_param.lignum    = l_lignum
                let lr_param.c24astcod = l_c24astcod
                let lr_param.funmat    = l_funmat
                let lr_param.empcod    = l_empcod
                let l_lista = ctx19g00_atualiza_bases(lr_param.*,10)
                let l_lista = ctx19g00_monta_retorno("S",0,0,0)
             end if
          end if
      else
          initialize lr_param.*  to null
          let lr_param.lignum    = l_lignum
          let lr_param.c24astcod = l_c24astcod
          let lr_param.funmat    = l_funmat
          let lr_param.empcod    = l_empcod
          let l_lista = ctx19g00_atualiza_bases(lr_param.*,10)
       end if
    else
       initialize lr_param.*  to null
       let lr_param.lignum    = l_lignum
       let lr_param.c24astcod = l_c24astcod
       let lr_param.funmat    = l_funmat
       let lr_param.empcod    = l_empcod
       let lr_param.atdsrvnum = l_atdsrvnum
       let lr_param.atdsrvano = l_atdsrvano
       let l_lista = ctx19g00_interfaceps(lr_param.*,10)
    end if
 else
    initialize lr_param.*  to null
    let lr_param.lignum    = l_lignum
    let lr_param.c24astcod = l_c24astcod
    let lr_param.funmat    = l_funmat
    let lr_param.empcod    = l_empcod
    let l_lista = ctx19g00_atualiza_bases(lr_param.*,10)
 end if

 return l_lista

end function

#----------------------------------------
function ctx19g00_monta_retorno(lr_param)
#----------------------------------------

 define lr_param        record
        flag            char(01),
        qtde            smallint,
        atdsrvnum       like datmreclam.atdsrvnum,
        atdsrvano       like datmreclam.atdsrvano
 end record

 define l_retorno       char(500)

 let l_retorno = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                ,"<servicos>"
                ,"<ServicoObrigatorio>", lr_param.flag, "</ServicoObrigatorio>"
                ,"<servicoqtd>", lr_param.qtde  using '<<<<<', "</servicoqtd>"
                ,"<servico1>"
                ,"<atdsrvnum>", lr_param.atdsrvnum  using '<<<<<<<<<<', "</atdsrvnum>"
                ,"<atdsrvano>", lr_param.atdsrvano  using '<<', "</atdsrvano>"
                ,"</servico1>"
                ,"</servicos>"

 return l_retorno

end function

#--------------------------------------
function ctx19g00_interfaceps(lr_param)
#--------------------------------------

 define lr_param        record
        lignum          like datmreclam.lignum,
        c24astcod       like datkevt.c24astcod,
        atdsrvnum       like datmservico.atdsrvnum,
        atdsrvano       like datmservico.atdsrvano,
        funmat          like isskfunc.funmat,
        empcod          like isskfunc.empcod,
        situacao        smallint
 end record

 define l_str           char(5000)

 define lr_aux          record
        c24evtcod       like datkevt.c24evtcod,
        c24fsecod       like datkfse.c24fsecod,
        atdsrvnum       like dbsmopgitm.atdsrvnum,
        atdsrvano       like dbsmopgitm.atdsrvano,
        funmat          like isskfunc.funmat
 end record

 if lr_param.lignum is null then
    let lr_param.lignum    = g_paramval[1]
    let lr_param.c24astcod = g_paramval[2]
    let lr_param.atdsrvnum = g_paramval[3]
    let lr_param.atdsrvano = g_paramval[4]
    let lr_param.funmat    = g_paramval[5]
    let lr_param.empcod    = g_paramval[6]
 end if

 let lr_param.situacao = 10

 if lr_param.atdsrvnum is null or
    lr_param.atdsrvano is null then
    let l_str = "<?xml version='1.0' encoding='ISO-8859-1'?>"
               ,"<servicos>ERRO</servicos>"
    return l_str
 end if

 initialize  lr_aux.*  to null
 let lr_aux.atdsrvnum = lr_param.atdsrvnum
 let lr_aux.atdsrvano = lr_param.atdsrvano
 let lr_aux.funmat    = lr_param.funmat

 open cctx19g00001 using lr_param.c24astcod
 whenever error continue
 fetch cctx19g00001 into lr_aux.c24evtcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_aux.c24evtcod = null
    else
       let l_str = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                  ,"<servicos>ERRO - SELECT cctx19g00001 - ",sqlca.sqlcode
                  ," - ",sqlca.sqlerrd[2],"</servicos>"
       return l_str
    end if
 end if

 call ctb00g01_anlsrv(lr_aux.*)

 let l_str = ctx19g00_atualiza_bases(lr_param.*)

 return l_str

end function

#-----------------------------------------
function ctx19g00_atualiza_bases(lr_param)
#-----------------------------------------

 define lr_param          record
        lignum            like datmreclam.lignum,
        c24astcod         like datkevt.c24astcod,
        atdsrvnum         like datmservico.atdsrvnum,
        atdsrvano         like datmservico.atdsrvano,
        funmat            like isskfunc.funmat,
        empcod            like isskfunc.empcod,
        situacao          smallint
 end record

 define l_flag            smallint,
        l_str             char(5000)

 let l_flag = ctx19g00_atualiza_assunto(lr_param.lignum, lr_param.c24astcod)

 if l_flag = 0 then
    let l_flag = ctx19g00_atualiza_situacao(lr_param.lignum,
                                            lr_param.c24astcod,
                                            lr_param.funmat,
                                            lr_param.empcod,
                                            lr_param.situacao)
    if l_flag = 0 and lr_param.atdsrvnum is not null then
       let l_flag = ctx19g00_atualiza_reclamacao(lr_param.lignum,
                                                 lr_param.atdsrvnum,
                                                 lr_param.atdsrvano)
    end if
 end if

 if l_flag = 0 then
    let l_str = "<?xml version='1.0' encoding='ISO-8859-1'?>"
               ,"<servicos>OK</servicos>"
 else
    let l_str = "<?xml version='1.0' encoding='ISO-8859-1'?>"
               ,"<servicos>ERRO ATUALIZACAO CENTRAL 24H</servicos>"
 end if

 return l_str

end function

#-------------------------------------------
function ctx19g00_atualiza_assunto(lr_param)
#-------------------------------------------

 define lr_param          record
        lignum            like datmreclam.lignum,
        c24astcod         like datkevt.c24astcod
 end record
 define ws                record
        succod            like datrservapol.succod,
        ramcod            like datrservapol.ramcod,
        aplnumdig         like datrservapol.aplnumdig,
        itmnumdig         like datrservapol.itmnumdig,
        c24astcod         like datmligacao.c24astcod,
        ligcvntip         like datmligacao.ligcvntip,
        atdsrvnum         like datmligacao.atdsrvnum,
        atdsrvano         like datmligacao.atdsrvano,
        c24solnom         like datmligacao.c24solnom,
        prporg            like datrligprp.prporg,
        prpnumdig         like datrligprp.prpnumdig,
        envio             smallint
 end record

 define l_ret             smallint

 initialize ws.*   to null


 whenever error continue
 execute pctx19g00005 using lr_param.c24astcod
                           ,lr_param.lignum
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let l_ret = 1
 else
    let l_ret = 0
 end if
 if l_ret              = 0    then
    select b.succod,b.ramcod,b.aplnumdig,b.itmnumdig,
	   a.c24astcod,a.ligcvntip,a.atdsrvnum,a.atdsrvano,
           a.c24solnom,c.prporg,c.prpnumdig
       into ws.succod,ws.ramcod,ws.aplnumdig,ws.itmnumdig,
            ws.c24astcod,ws.ligcvntip,ws.atdsrvnum,ws.atdsrvano,
            ws.c24solnom,ws.prporg,ws.prpnumdig
       from datmligacao  a,
            outer datrligapol  b,
            outer datrligprp   c
      where a.lignum = lr_param.lignum
        and b.lignum = a.lignum
        and c.lignum = a.lignum

    call figrc072_setTratarIsolamento() -- > psi 223689

    call cts30m00(ws.ramcod   ,    ws.c24astcod,
                  ws.ligcvntip,    ws.succod,
                  ws.aplnumdig,    ws.itmnumdig,
                  lr_param.lignum, ws.atdsrvnum,
                  ws.atdsrvano,    ws.prporg,
                  ws.prpnumdig,    ws.c24solnom)
              returning ws.envio
    if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
       error "Problemas na fun��o cts30m00 ! Avise a Informatica !" sleep 2
       return l_ret
    end if        -- > 223689


 display "** ctx19g00 - chamando cts30m00 - ws.envio = ",ws.envio," ws.*=",ws.*
 end if
 return l_ret

end function

#-------------------------------------------
function ctx19g00_atualiza_situacao(lr_param)
#-------------------------------------------

 define lr_param          record
        lignum            like datmreclam.lignum,
        c24astcod         like datkevt.c24astcod,
        funmat            like isskfunc.funmat,
        empcod            like isskfunc.empcod,
        c24rclsitcod      like datmsitrecl.c24rclsitcod
 end record

 define l_ret             smallint,
        l_aux             char(25),
        l_c24rclsitcod    like datmsitrecl.c24rclsitcod

 define lr_sitrecl        record
        lignum            like datmsitrecl.lignum,
        c24rclsitcod      like datmsitrecl.c24rclsitcod,
        funmat            like datmsitrecl.funmat,
        rclrlzdat         like datmsitrecl.rclrlzdat,
        rclrlzhor         like datmsitrecl.rclrlzhor,
        c24astcod         like datmsitrecl.c24astcod,
        empcod            like datmsitrecl.empcod,
        usrtip            like datmsitrecl.usrtip
 end record

 let l_aux = current

 initialize lr_sitrecl.*  to  null

 let lr_sitrecl.lignum       = lr_param.lignum
 let lr_sitrecl.c24rclsitcod = lr_param.c24rclsitcod
 let lr_sitrecl.funmat       = lr_param.funmat
 let lr_sitrecl.rclrlzdat    = today
 let lr_sitrecl.rclrlzhor    = l_aux[12,19]
 let lr_sitrecl.c24astcod    = lr_param.c24astcod
 let lr_sitrecl.empcod       = lr_param.empcod
 let lr_sitrecl.usrtip       = "F"

 open cctx19g00007 using lr_sitrecl.lignum
 whenever error continue
 fetch cctx19g00007 into l_c24rclsitcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let l_c24rclsitcod = null
    else
       let l_ret = 1
       return l_ret
    end if
 end if

 if l_c24rclsitcod is null or
    l_c24rclsitcod <> lr_sitrecl.c24rclsitcod then
    whenever error continue
    execute pctx19g00006 using lr_sitrecl.*
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_ret = 1
    else
       let l_ret = 0
    end if
 else
    let l_ret = 0
 end if

 return l_ret

end function

#-----------------------------------------------
function ctx19g00_atualiza_reclamacao(lr_param)
#-----------------------------------------------

 define lr_param          record
        lignum            like datmreclam.lignum,
        atdsrvnum         like datmservico.atdsrvnum,
        atdsrvano         like datmservico.atdsrvano
 end record

 define l_ret             smallint

 whenever error continue
 execute pctx19g00004 using lr_param.atdsrvnum
                           ,lr_param.atdsrvano
                           ,lr_param.lignum
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let l_ret = 1
 else
    let l_ret = 0
 end if

 return l_ret

end function

#----------------------------------
function ctx19g00_grava_historico()
#----------------------------------

 define lr_param          record
        lignum            like datmreclam.lignum,
        funmat            like isskfunc.funmat,
        empcod            like isskfunc.empcod,
        data              date,
        hora              char(08),
        qtdl              smallint
 end record

 define l_flag            smallint,
        l_str             char(5000),
        l_aux             char(25),
        l_ix1             smallint,
        l_ix2             smallint,
        l_texto           char(100),
        l_funnom          like isskfunc.funnom

 define al_texto          array[50] of record
        linha             char(50)
 end record

 define lr_hist           record
        #tipgrv            smallint,
        lignum            like datmlighist.lignum,
        c24funmat         like datmlighist.c24funmat,
        ligdat            like datmlighist.ligdat,
        lighorinc         like datmlighist.lighorinc,
        c24ligdsc         like datmlighist.c24ligdsc,
        c24empcod         like datmlighist.c24empcod,
        c24usrtip         like datmlighist.c24usrtip
 end record

 define lr_retorno        record
        tabname           like systables.tabname,
        sqlcode           integer
 end record

 initialize lr_param.* to null
 initialize al_texto   to null

 let lr_param.lignum = g_paramval[1]
 let lr_param.funmat = g_paramval[2]
 let lr_param.empcod = g_paramval[3]
 let lr_param.data   = g_paramval[4]
 let lr_param.hora   = g_paramval[5]
 let lr_param.qtdl   = g_paramval[6]

 let l_ix1 = 0

 for l_ix2 = 7 to 50
     let l_ix1 = l_ix1 + 1
     let al_texto[l_ix1].linha = g_paramval[l_ix2]
 end for

 let g_issk.usrtip = "F"
 let g_issk.empcod = 1

 let l_flag = 0

 let l_ix2 = lr_param.qtdl
 if l_ix2 is not null and l_ix2 > 0 then
    if l_ix2 > 50 then
       let l_ix2 = 50
    end if
    for l_ix1 = 1 to l_ix2
        initialize lr_hist.*    to null
        initialize lr_retorno.* to null
        #let lr_hist.tipgrv    = 1
        let lr_hist.lignum    = lr_param.lignum
        let lr_hist.c24funmat = lr_param.funmat
        let lr_hist.ligdat    = lr_param.data
        let lr_hist.lighorinc = lr_param.hora
        let lr_hist.c24ligdsc = al_texto[l_ix1].linha
        let lr_hist.c24empcod = lr_param.empcod
        #usrtip nao vem como parametro, e � necessario na insercao
        # da tabela datmlighist, por isso esta fixo
        let lr_hist.c24usrtip = "F"
        #call cts10g00_historico(lr_hist.*)
        #     returning lr_retorno.*
        call ctd06g01_ins_datmlighist(lr_hist.lignum,
                                      lr_hist.c24funmat,
                                      lr_hist.c24ligdsc,
                                      lr_hist.ligdat,
                                      lr_hist.lighorinc,
                                      lr_hist.c24usrtip,
                                      lr_hist.c24empcod  )
             returning lr_retorno.sqlcode,  #retorno
                       lr_retorno.tabname   #mensagem
        #if lr_retorno.sqlcode <> 0 then
        if lr_retorno.sqlcode <> 1 then
           let l_flag = 1
           exit for
        end if
    end for
 end if

 if l_flag = 0 then
    let l_str = "<?xml version='1.0' encoding='ISO-8859-1'?>"
               ,"<servicos>OK</servicos>"
 else
    let l_str = "<?xml version='1.0' encoding='ISO-8859-1'?>"
               ,"<servicos>ERRO ATUALIZACAO CENTRAL 24H</servicos>"
 end if

 return l_str

end function

#--------------------------------------
function ctx19g00_conclui_reclamacao()
#--------------------------------------

 define lr_param          record
        lignum            like datmreclam.lignum,
        c24astcod         like datkevt.c24astcod,
        atdsrvnum         like datmservico.atdsrvnum,
        atdsrvano         like datmservico.atdsrvano,
        funmat            like isskfunc.funmat,
        empcod            like isskfunc.empcod,
        situacao          smallint
 end record

 define l_str             char(5000)

 initialize lr_param.*  to null

 let lr_param.lignum    = g_paramval[1]
 let lr_param.c24astcod = g_paramval[2]
 let lr_param.funmat    = g_paramval[3]
 let lr_param.empcod    = g_paramval[4]
 let lr_param.situacao  = 20

 let l_str = ctx19g00_atualiza_bases(lr_param.*)

 return l_str

end function

--------------------------------------------------------------------------------
function ctx19g00Service_monta_xml_erro(l_param)
--------------------------------------------------------------------------------
define l_param record
       mensagem  char(100)
   end record

define l_xmlRetorno char(5000)

let l_xmlRetorno = "<?xml version='1.0' encoding='ISO-8859-1'?><IFX>",
                   "<mq>" , "<erro>" clipped, l_param.mensagem clipped,
                   "  </erro>" clipped, "</mq>","</IFX>"
return l_xmlRetorno

end function

-------------------------------------------------------------------------------
function ctx19g00Service_monta_xml_srv(l_param)
--------------------------------------------------------------------------------
define l_param
       record
       erro      smallint,
       msg       char(80),
       atdsrvnum like datmservico.atdsrvnum,
       atdsrvano like datmservico.atdsrvano
       end record

define l_xml_iface   char(5000)

let l_xml_iface = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><IFX>",
        "<codigoErro>"    clipped ,l_param.erro      clipped using '<<<<'       ,"</codigoErro>",
        "<mensagemErro>"  clipped ,l_param.msg       clipped                    ,"</mensagemErro>",
	"<atdsrvnum>"     clipped ,l_param.atdsrvnum clipped using '<<<<<<<<<<' ,"</atdsrvnum>",
	"<atdsrvano>"     clipped ,l_param.atdsrvano clipped using '<<'         ,"</atdsrvano>",
"</IFX>"

    return l_xml_iface

end function

--------------------------------------------------------------------------------
function ctx19g00Service_monta_xml_srvlig(l_param)
--------------------------------------------------------------------------------

define l_param
       record
       erro      smallint,
       msg       char(80),
       lignum    like datmligacao.lignum,
       atdsrvnum like datmservico.atdsrvnum,
       atdsrvano like datmservico.atdsrvano
       end record

define l_xml_iface   char(5000)

let l_xml_iface = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><IFX>",
        "<codigoErro>"    clipped ,l_param.erro   clipped using '<<<<'          ,"</codigoErro>" ,
        "<mensagemErro>"  clipped ,l_param.msg    clipped                       ,"</mensagemErro>" ,
        "<lignum>"        clipped ,l_param.lignum clipped using '<<<<<<<<<<'    ,"</lignum>",
        "<atdsrvnum>"     clipped ,l_param.atdsrvnum clipped using '<<<<<<<<<<' ,"</atdsrvnum>",
        "<atdsrvano>"     clipped ,l_param.atdsrvano clipped using '<<'         ,"</atdsrvano>",
        "</IFX>"

    return l_xml_iface

end function

#-----------------------------------#
function ctx19g00_lig_corr(l_servico)
#-----------------------------------#

  define l_corlignum    like dacmlig.corlignum,
         l_corligano    like dacmlig.corligano,
         l_servico      char(40),
         l_msg_erro     char(300)

  # ---> INICIALIZACAO DAS VARIAVEIS

  let l_corlignum = null
  let l_corligano = null
  let l_msg_erro  = null

  # ---> GERA O NUMERO DA LIGACAO DO CORRETOR
  ## display "** CHAMANDO CTE04M00_GERA_NUMLIG **" # ruiz
  call cte04m00_gera_numlig(g_paramval[8],  # --> MATRICULA
                            g_paramval[9],  # --> EMPRESA
                            l_servico)

       returning l_msg_erro,
                 l_corlignum,
                 l_corligano

 ## display "** NUMERO LIGACAO GERADA = ", l_corlignum," ",l_corligano #ruiz

  if l_corlignum is not null and
     l_corligano is not null then

     # ---> GERA A LIGACAO DO CORRETOR
     ## display "** CHAMANDO CTE04M00_GERA_LIG **" # ruiz
     let l_msg_erro = cte04m00_gera_lig(g_paramval[1],  # --> LIGDAT
                                        g_paramval[2],  # --> LIGASSHORINC
                                        g_paramval[3],  # --> LIGASSHORFNL
                                        g_paramval[4],  # --> C24SOLNOM
                                        g_paramval[5],  # --> CORSUS
                                        g_paramval[6],  # --> VSTAGNNUM
                                        g_paramval[7],  # --> VSTAGNSTT
                                        g_paramval[8],  # --> CADMAT
                                        g_paramval[9],  # --> CADEMP
                                        g_paramval[10], # --> CORASSCOD
                                        g_paramval[11], # --> DRSCRSAGDCOD
                                        g_paramval[12], # --> AGDLIGRELSTT
                                        l_corlignum,
                                        l_corligano,
                                        l_servico)
  end if

  ## display "** l_msg_erro = ", l_msg_erro  # ruiz

  return l_msg_erro

end function

#---------------------------------------------------#
function ctx19g00_reg_ligsrv_furto_roubo()
#---------------------------------------------------#

  define lr_ctq00m01	  record
        err       smallint,
        msg       char(80),
        lignum    like datmligacao.lignum,
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano
  end record

  define  l_mail             record
      de                 char(500)   # De
     ,para               char(5000)  # Para
     ,cc                 char(500)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
  end  record
  define l_coderro  smallint
  define msg_erro char(500)
  define l_aux        char(25)

  define l_remetente  char(50)
  define l_assunto    char(50)
  define l_para       char(1000)
  define l_comando    char(32766)
  define l_status     smallint
  define l_retorno    char(5000)

  let l_remetente   = null
  let l_assunto     = null
  let l_para        = null
  let l_comando     = null
  let l_status      = null
  let l_retorno     = null
  let l_aux         = current
  let m_hist_qtd    = 0
  let m_conta_linha = 0
  let m_conta       = 0
  let m_historico   = " "
  let m_hist_qtd = g_paramval[ 74]
  ## quando implementar ou publicar o modelo JAVA, retirar o comentario e tratar o Hist�rico
  ## com mais de uma linha.

  for m_conta_linha = 1 to m_hist_qtd
      let m_conta       = m_conta_linha + 74
      let m_historico   = m_historico clipped , g_paramval[m_conta]
  end for

  let l_aux = current   ## retirar

  display " "
  display "**** <ctx19g00> Chamando a funcao CTQ00M01 ****"
  display " cdr 003 - lignum (ctq00m01) " , g_paramval[  1]
  display " cdr 004 - c24astcod         " , g_paramval[  6]
  display " cdr 005 - atdnum            " , g_paramval[ 73]
  display " cdr 006 - suc/rm/apl        " , g_paramval[ 10], "/"
                                          , g_paramval[ 11], "/"
                                          , g_paramval[ 12]

  display " "

  call ctq00m01( g_paramval[  1],#datmligacao.lignum
                 g_paramval[  2],#datmligacao.ligdat
                 g_paramval[  3],#datmligacao.lighorinc
                 g_paramval[  4],#datksoltip.c24soltipcod
                 g_paramval[  5],#datmligacao.c24solnom
                 g_paramval[  6],#datmligacao.c24astcod
                 g_paramval[  7],#datmligacao.c24funmat
                 g_paramval[  8],#datmligacao.ligcvntip
                 g_paramval[  9],#datmligacao.c24paxnum
                 g_paramval[ 10],#datrligapol.succod
                 g_paramval[ 11],#datrligapol.ramcod
                 g_paramval[ 12],#datrligapol.aplnumdig
                 g_paramval[ 13],#datrligapol.itmnumdig
                 g_paramval[ 14],#datrligapol.edsnumref
                 g_paramval[ 15],#datrligprp.prporg
                 g_paramval[ 16],#datrligprp.prpnumdig
                 g_paramval[ 17],#datrligpac.fcapacorg
                 g_paramval[ 18],#datrligpac.fcapacnum
                 g_paramval[ 19],#datmvstsin.cornom
                 g_paramval[ 20],#datmvstsin.corsus
                 g_paramval[ 21],#datmvstsin.vcldes
                 g_paramval[ 22],#datmvstsin.vclanomdl
                 g_paramval[ 23],#datmvstsin.vcllicnum
                 g_paramval[ 24],#datmvstsin.sindat
                 g_paramval[ 25],#datmvstsin.sinavs
                 g_paramval[ 26],#datmservico.vclcorcod
                 g_paramval[ 27],#datmservico.atdlclflg
                 g_paramval[ 28],#datmservico.atdrsdflg
                 g_paramval[ 29],#datmservico.atddfttxt
                 g_paramval[ 30],#datmservico.atddoctxt
                 g_paramval[ 31],#datmservico.c24opemat
                 g_paramval[ 32],#datmservico.nom
                 g_paramval[ 33],#datmservico.cnldat
                 g_paramval[ 34],#datmservico.vclcoddig
                 g_paramval[ 35],#datmservico.atdsrvorg
                 g_paramval[ 36],#datmservicocmp.c24sintip
                 g_paramval[ 37],#datmservicocmp.c24sinhor
                 g_paramval[ 38],#datmservicocmp.bocflg
                 g_paramval[ 39],#datmservicocmp.bocnum
                 g_paramval[ 40],#datmservicocmp.bocemi
                 g_paramval[ 41],#datmservicocmp.vicsnh
                 g_paramval[ 42],#datmservicocmp.sinhor
                 g_paramval[ 43],#datmlcl.c24endtip
                 g_paramval[ 44],#datmlcl.lclidttxt
                 g_paramval[ 45],#datmlcl.lgdtip
                 g_paramval[ 46],#datmlcl.lgdnom
                 g_paramval[ 47],#datmlcl.lgdnum
                 g_paramval[ 48],#datmlcl.lclbrrnom
                 g_paramval[ 49],#datmlcl.brrnom
                 g_paramval[ 50],#datmlcl.cidnom
                 g_paramval[ 51],#datmlcl.ufdcod
                 g_paramval[ 52],#datmlcl.lclrefptotxt
                 g_paramval[ 53],#datmlcl.endzon
                 g_paramval[ 54],#datmlcl.lgdcep
                 g_paramval[ 55],#datmlcl.lgdcepcmp
                 g_paramval[ 56],#datmlcl.lclltt
                 g_paramval[ 57],#datmlcl.lcllgt
                 g_paramval[ 58],#datmlcl.dddcod
                 g_paramval[ 59],#datmlcl.lcltelnum
                 g_paramval[ 50],#datmlcl.lclcttnom
                 g_paramval[ 61],#datmlcl.c24lclpdrcod
                 g_paramval[ 62],#datmlcl.ofnnumdig
                 g_paramval[ 63],#datmlcl.emeviacod
                 g_paramval[ 64],#datmavssin.sinntzcod
                 g_paramval[ 65],#datmavssin.eqprgicod
                 g_paramval[ 66],#ctcdtnom
                 g_paramval[ 67],#ctcgccpfnum
                 g_paramval[ 68],#ctcgccpfdig
                 g_paramval[ 69],#ssamsin.ramcod
                 g_paramval[ 70],#ssamsin.sinano
                 g_paramval[ 71],#ssamsin.sinnum
                 g_paramval[ 72],#ssamitem.sinitmseq
                 g_paramval[ 73],#datmatd6523.atdnum
                 g_paramval[ 74],#Qtde de linhas do Historico
                 m_historico)#Historico


 returning lr_ctq00m01.err      ,
           lr_ctq00m01.msg      ,
           lr_ctq00m01.lignum   ,
           lr_ctq00m01.atdsrvnum,
           lr_ctq00m01.atdsrvano


 ------[ deleta registro de controle de sinistro pendente ]-------
  if lr_ctq00m01.err is null or
    lr_ctq00m01.err = 0 then
    select 1
        from datmpndsin
        where atdsrvnum = lr_ctq00m01.atdsrvnum
          and atdsrvano = lr_ctq00m01.atdsrvano
      # where succod    = g_paramval[ 10]
      #   and ramcod    = g_paramval[ 11]
      #   and aplnumdig = g_paramval[ 12]
      #   and itmnumdig = g_paramval[ 13]

    if sqlca.sqlcode = 0 then
       delete from datmpndsin
            where atdsrvnum = lr_ctq00m01.atdsrvnum
              and atdsrvano = lr_ctq00m01.atdsrvano
            #where succod    = g_paramval[ 10]
            #  and ramcod    = g_paramval[ 11]a
            #  and aplnumdig = g_paramval[ 12]
            #  and itmnumdig = g_paramval[ 13]
    end if
 end if
 if g_paramval[ 15] <> 0 and  # origem
    g_paramval[ 16] <> 0 and  # proposta
    g_paramval[  6] =  "F10" then
    let l_retorno  = lr_ctq00m01.err," ",
                     lr_ctq00m01.msg clipped," ",
                     lr_ctq00m01.lignum," ",
                     lr_ctq00m01.atdsrvnum," ",
                     lr_ctq00m01.atdsrvano
    let l_remetente = "EmailCorr.ct24hs@correioporto"
    let l_assunto   = "F10-Furto e Roubo Proposta"
    let l_para      = "carlos_ruiz@correioporto"
      #PSI-2013-23297 - Inicio
      let l_mail.de = l_remetente
      let l_mail.para =  l_para
      let l_mail.cc = ""
      let l_mail.cco = ""
      let l_mail.assunto = l_assunto
      let l_mail.mensagem = l_retorno
      let l_mail.id_remetente = "CT24H"
      let l_mail.tipo = "text"

      call figrc009_mail_send1 (l_mail.*)
       returning l_coderro,msg_erro
      #PSI-2013-23297 - Fim
 end if
 -------------------------------------------------------------------
 let l_aux = current   ## retirar
 display "(ctx19g00->ctq00m01 )<1039> Retornou do servico de F10 ", l_aux
 return ctx19g00Service_monta_xml_srvlig(lr_ctq00m01.*)

end function

#---------------------------------------------------#
function ctx19g00_grava_historico_atd(l_servico)
#---------------------------------------------------#
  define l_msg_erro char(300),
         l_servico  char(40)

  define l_historico char(32766)

  let l_msg_erro  = null
  let l_historico = null

  call ctx19g00_junta_historico( g_paramval[7] )
  returning l_historico
##display "** CHAMANDO CTE04M00_GRAVA_HIST, corligano = ",g_paramval[6] # ruiz
  let l_msg_erro = cte04m00_grava_hist(g_paramval[1], # --> CADDAT
                                       g_paramval[2], # --> CADHOR
                                       g_paramval[3], # --> empcod
                                       g_paramval[4], # --> CADMAT
                                       g_paramval[5], # --> CORLIGNUM
                                       g_paramval[6], # --> CORLIGANO
                                       l_historico  , # --> HISTORICO
                                       l_servico)
  return l_msg_erro

end function

#---------------------------------------#
function ctx19g00_reg_lig_vst_sin_auto()
#---------------------------------------#

  define l_ret_srvlig
         record
         erro      smallint,
         msgerro   char(80),
         lignum    like datmligacao.lignum,
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
         end record

  define l_ret_tab
         record
         sqlcode         integer,
         tabname         like systables.tabname
         end record

  define l_mensagem_erro char(80)

  define l_cts14m00_ano4 char(04)

  define argumentos    record
         lignum           like datmligacao.lignum      ,
         ligdat           like datmligacao.ligdat      ,
         lighorinc        like datmligacao.lighorinc   ,
         c24soltipcod     like datksoltip.c24soltipcod ,
         c24solnom        like datmligacao.c24solnom   ,
         c24astcod        like datmligacao.c24astcod   ,
         c24funmat        like datmligacao.c24funmat   ,
         ligcvntip        like datmligacao.ligcvntip   ,
         c24paxnum        like datmligacao.c24paxnum   ,
         atdsrvnum        like datrligsrv.atdsrvnum    ,
         atdsrvano        like datrligsrv.atdsrvano    ,
         sinvstnum        like datrligsinvst.sinvstnum ,
         sinvstano        like datrligsinvst.sinvstano ,
         sinavsnum        like datrligsinavs.sinavsnum ,
         sinavsano        like datrligsinavs.sinavsano ,
         succod           like datrligapol.succod      ,
         ramcod           like datrligapol.ramcod      ,
         aplnumdig        like datrligapol.aplnumdig   ,
         itmnumdig        like datrligapol.itmnumdig   ,
         edsnumref        like datrligapol.edsnumref   ,
         prporg           like datrligprp.prporg       ,
         prpnumdig        like datrligprp.prpnumdig    ,
         fcapacorg        like datrligpac.fcapacorg    ,
         fcapacnum        like datrligpac.fcapacnum    ,
         sinramcod        like ssamsin.ramcod          ,
         sinano           like ssamsin.sinano          ,
         sinnum           like ssamsin.sinnum          ,
         sinitmseq        like ssamitem.sinitmseq      ,
         caddat           like datmligfrm.caddat       ,
         cadhor           like datmligfrm.cadhor       ,
         cademp           like datmligfrm.cademp       ,
         cadmat           like datmligfrm.cadmat
         ,vstsolnom       like datmvstsin.vstsolnom
         ,vstsoltip       like datmvstsin.vstsoltip
         ,vstsoltipcod    like datmvstsin.vstsoltipcod
         ,segnom          like datmvstsin.segnom
         ,subcod          like datmvstsin.subcod
         ,dddcod          like datmvstsin.dddcod
         ,teltxt          like datmvstsin.teltxt
         ,cornom          like datmvstsin.cornom
         ,corsus          like datmvstsin.corsus
         ,vcldes          like datmvstsin.vcldes
         ,vclanomdl       like datmvstsin.vclanomdl
         ,vcllicnum       like datmvstsin.vcllicnum
         ,vclchsfnl       like datmvstsin.vclchsfnl
         ,sindat          like datmvstsin.sindat
         ,sinavs          like datmvstsin.sinavs
         ,orcvlr          like datmvstsin.orcvlr
         ,ofnnumdig       like datmvstsin.ofnnumdig
         ,vstdat          like datmvstsin.vstdat
         ,vstretdat       like datmvstsin.vstretdat
         ,vstretflg       like datmvstsin.vstretflg
         ,funmat          like datmvstsin.funmat
         ,atddat          like datmvstsin.atddat
         ,atdhor          like datmvstsin.atdhor
         ,sinvstorgnum    like datmvstsin.sinvstorgnum
         ,sinvstorgano    like datmvstsin.sinvstorgano
         ,sinvstsolsit    like datmvstsin.sinvstsolsit
         ,vclchsinc       like datmvstsin.vclchsinc
  end record
  ## Variaveis globais
  let g_issk.funmat         = null
  ## Se for Portal (WEB)
  select grlinf
  into   g_issk.funmat
  from   datkgeral
  where  grlchv = "USRCT24HPORTAL"
  let g_issk.empcod         = 1
  let g_issk.usrtip         = "F"
  let g_documento.empcodatd = null
  let g_documento.funmatatd = null
  let g_documento.usrtipatd = null

 begin work
 call cts10g03_numeracao( 2, "5" )

      returning l_ret_srvlig.lignum    ,
                l_ret_srvlig.atdsrvnum ,
                l_ret_srvlig.atdsrvano ,
                l_ret_srvlig.erro      ,
                l_ret_srvlig.msgerro

  let l_cts14m00_ano4 =  '20', l_ret_srvlig.atdsrvano using "&&"

  let argumentos.lignum       = l_ret_srvlig.lignum
  let argumentos.ligdat       = formata_data(g_paramval[ 1]) ## formata g_paramval[ 1]
  let argumentos.lighorinc    = g_paramval[ 2]
  let argumentos.c24soltipcod = g_paramval[ 3]
  let argumentos.c24solnom    = g_paramval[ 4]
  let argumentos.c24astcod    = g_paramval[ 5]
  let argumentos.c24funmat    = g_paramval[ 6]
  let argumentos.ligcvntip    = 0
  let argumentos.c24paxnum    = 9999
  let argumentos.atdsrvnum    = ""
  let argumentos.atdsrvano    = ""
##  let argumentos.sinvstnum    = g_paramval[ 7]
##  let argumentos.sinvstano    = g_paramval[ 8]
  let argumentos.sinvstnum    = l_ret_srvlig.atdsrvnum
  let argumentos.sinvstano    = l_cts14m00_ano4 ## l_ret_srvlig.atdsrvano
  let argumentos.sinavsnum    = ""
  let argumentos.sinavsano    = ""
  let argumentos.succod       = g_paramval[ 9]
  let argumentos.ramcod       = g_paramval[10]
  let argumentos.aplnumdig    = g_paramval[11]
  let argumentos.itmnumdig    = g_paramval[12]
  let argumentos.edsnumref    = g_paramval[13]
  let argumentos.prporg       = g_paramval[14]
  let argumentos.prpnumdig    = g_paramval[15]
  let argumentos.fcapacorg    = ""
  let argumentos.fcapacnum    = ""
  let argumentos.sinramcod    = g_paramval[16]
  let argumentos.sinano       = g_paramval[17]
  let argumentos.sinnum       = g_paramval[18]
  let argumentos.sinitmseq    = g_paramval[19]
  let argumentos.caddat       = ""
  let argumentos.cadhor       = ""
  let argumentos.cademp       = ""
  let argumentos.cadmat       = ""

  let argumentos.vstsolnom    = g_paramval[20]
  let argumentos.vstsoltip    = g_paramval[21]
  let argumentos.vstsoltipcod = g_paramval[22]
  let argumentos.segnom       = g_paramval[23]
  let argumentos.subcod       = g_paramval[24]
  let argumentos.dddcod       = g_paramval[25]
  let argumentos.teltxt       = g_paramval[26]
  let argumentos.cornom       = g_paramval[27]
  let argumentos.corsus       = g_paramval[28]
  let argumentos.vcldes       = g_paramval[29]
  let argumentos.vclanomdl    = g_paramval[30]
  let argumentos.vcllicnum    = g_paramval[31]
  let argumentos.vclchsfnl    = g_paramval[32]
  let argumentos.sindat       = formata_data(g_paramval[33])
  let argumentos.sinavs       = g_paramval[34]
  let argumentos.orcvlr       = g_paramval[35]
  let argumentos.ofnnumdig    = g_paramval[36]
  let argumentos.vstdat       = formata_data(g_paramval[37])
  let argumentos.vstretdat    = formata_data(g_paramval[38])
  let argumentos.vstretflg    = g_paramval[39]
  let argumentos.funmat       = g_paramval[40]
  let argumentos.atddat       = formata_data(g_paramval[41])
  let argumentos.atdhor       = g_paramval[42]
  let argumentos.sinvstorgnum = g_paramval[43]
  let argumentos.sinvstorgano = g_paramval[44]
  let argumentos.sinvstsolsit = g_paramval[45]
  let argumentos.vclchsinc    = g_paramval[46]

  if argumentos.funmat is null or
     argumentos.funmat = " " then
     let argumentos.funmat = 0
  end if

  if l_ret_srvlig.erro <> 0 then
     rollback work
     return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)
  else
     commit work
  end if

  begin work
  call cts10g00_ligacao( argumentos.lignum       , ## g_paramval[ 1],
                         argumentos.ligdat       , ## g_paramval[ 2],
                         argumentos.lighorinc    , ## g_paramval[ 3],
                         argumentos.c24soltipcod , ## g_paramval[ 4],
                         argumentos.c24solnom    , ## g_paramval[ 5],
                         argumentos.c24astcod    , ## g_paramval[ 6],
                         argumentos.c24funmat    , ## g_paramval[ 7],
                         argumentos.ligcvntip    , ## g_paramval[ 8],
                         argumentos.c24paxnum    , ## g_paramval[ 9],
                         argumentos.atdsrvnum    , ## g_paramval[10],
                         argumentos.atdsrvano    , ## g_paramval[11],
                         argumentos.sinvstnum    , ## g_paramval[12],
                         argumentos.sinvstano    , ## g_paramval[13],
                         argumentos.sinavsnum    , ## g_paramval[14],
                         argumentos.sinavsano    , ## g_paramval[15],
                         argumentos.succod       , ## g_paramval[16],
                         argumentos.ramcod       , ## g_paramval[17],
                         argumentos.aplnumdig    , ## g_paramval[18],
                         argumentos.itmnumdig    , ## g_paramval[19],
                         argumentos.edsnumref    , ## g_paramval[20],
                         argumentos.prporg       , ## g_paramval[21],
                         argumentos.prpnumdig    , ## g_paramval[22],
                         argumentos.fcapacorg    , ## g_paramval[23],
                         argumentos.fcapacnum    , ## g_paramval[24],
                         argumentos.sinramcod    , ## g_paramval[25],
                         argumentos.sinano       , ## g_paramval[26],
                         argumentos.sinnum       , ## g_paramval[27],
                         argumentos.sinitmseq    , ## g_paramval[28],
                         argumentos.caddat       , ## g_paramval[29],
                         argumentos.cadhor       , ## g_paramval[30],
                         argumentos.cademp       , ## g_paramval[31],
                         argumentos.cadmat         ## g_paramval[32]
                         )
  returning l_ret_tab.tabname,
            l_ret_tab.sqlcode

  let l_mensagem_erro = " "
  if l_ret_tab.sqlcode <> 0 then
     rollback work
     let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-Gravacao na Tabela " ,l_ret_tab.tabname
     let l_ret_srvlig.erro    = l_ret_tab.sqlcode
     let l_ret_srvlig.msgerro = l_mensagem_erro
     return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)
  else
     commit work
  end if
 if argumentos.c24astcod = "V11" then
    let argumentos.ramcod = 553
 end if

 if l_ret_tab.sqlcode = 0 then
    begin work
    #--------------------------------------------------------------------------
    # Grava vistoria de sinistro
    #---------------------------------------------------------------------------
    insert into DATMVSTSIN ( sinvstnum   ,
                             sinvstano   ,
                             vstsolnom   ,
                             vstsoltip   ,
                             vstsoltipcod,
                             segnom      ,
                             aplnumdig   ,
                             itmnumdig   ,
                             succod      ,
                             ramcod      ,
                             subcod      ,
                             dddcod      ,
                             teltxt      ,
                             cornom      ,
                             corsus      ,
                             vcldes      ,
                             vclanomdl   ,
                             vcllicnum   ,
                             vclchsfnl   ,
                             sindat      ,
                             sinavs      ,
                             orcvlr      ,
                             ofnnumdig   ,
                             vstdat      ,
                             vstretdat   ,
                             vstretflg   ,
                             funmat      ,
                             atddat      ,
                             atdhor      ,
                             sinvstorgnum,
                             sinvstorgano,
                             sinvstsolsit,
                             prporg      ,
                             prpnumdig
                             ,vclchsinc
                             )
                    values ( argumentos.sinvstnum    ,
                             l_cts14m00_ano4         ,
                             argumentos.vstsolnom    ,
                             argumentos.vstsoltip    ,
                             argumentos.vstsoltipcod ,
                             argumentos.segnom       ,
                             argumentos.aplnumdig    ,
                             argumentos.itmnumdig    ,
                             argumentos.succod       ,
                             argumentos.ramcod       ,
                             argumentos.subcod       ,
                             argumentos.dddcod       ,
                             argumentos.teltxt       ,
                             argumentos.cornom       ,
                             argumentos.corsus       ,
                             argumentos.vcldes       ,
                             argumentos.vclanomdl    ,
                             argumentos.vcllicnum    ,
                             argumentos.vclchsfnl    ,
                             argumentos.sindat       ,
                             argumentos.sinavs       ,
                             argumentos.orcvlr       ,
                             argumentos.ofnnumdig    ,
                             argumentos.vstdat       ,
                             argumentos.vstretdat    ,
                             argumentos.vstretflg    ,
                             argumentos.funmat       ,
                             argumentos.atddat       ,
                             argumentos.atdhor       ,
                             argumentos.sinvstorgnum ,
                             argumentos.sinvstorgano ,
                             argumentos.sinvstsolsit ,
                             argumentos.prporg       ,
                             argumentos.prpnumdig
                            ,argumentos.vclchsinc
                            )
    if  sqlca.sqlcode  <>  0  then
        error " Erro (", sqlca.sqlcode, ") na gravacao da",
              " vistoria de sinistro. AVISE A INFORMATICA!"
        rollback work
    end if
    commit work
 end if

 return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)

 end function

#---------------------------------------------#
function ctx19g00_junta_historico(l_qtd_linhas)
#---------------------------------------------#

  # -> FUNCAO PARA JUNTAR AS LINHAS DO HISTORICO

  define l_qtd_linhas smallint,    # -> QUANTIADE DE LINHAS DO HISTORICO
         l_contador   smallint,
         l_historico  char(32000)  # -> HISTORICO FINAL

  let l_contador  = null
  let l_historico = null
##display "* ctx19g00 - l_qtd_linhas = ", l_qtd_linhas
  for l_contador = 1 to l_qtd_linhas

     # -> O TEXTO DO HISTORICO, COMECA A PARTIR DA OITAVA POSICAO
     let l_historico = l_historico clipped, g_paramval[l_contador + 7]

  end for

  return l_historico
end function

#---------------------------------------#
function ctx19g00_can_vst_sin_auto()
#---------------------------------------#

  define l_ret_srvlig
         record
         erro      smallint,
         msgerro   char(80),
         lignum    like datmligacao.lignum,
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
         end record

  define l_ret_tab
         record
         sqlcode         integer,
         tabname         like systables.tabname
         end record

  define l_mensagem_erro char(80)

  define l_cts14m00_ano4 char(04)

  ## Alberto
  define ws          record
    funmat          like isskfunc.funmat             ,
    atddat          like datmvstsin.atddat           ,
    atdhor          like datmvstsin.atdhor           ,
    sinvstsit       like datmvstsin.sinvstsolsit     ,
    operacao        char (01)                        ,
    soltip          like datmvstsincanc.soltip       ,
    canmtvdes       like datmvstsincanc.canmtvdes    ,
    c24solnom       like datmligacao.c24solnom       ,
    c24soltipcod    like datmligacao.c24soltipcod
  end record
  ## Alberto

  define argumentos    record
         lignum           like datmligacao.lignum      ,
         ligdat           like datmligacao.ligdat      ,
         lighorinc        like datmligacao.lighorinc   ,
         c24soltipcod     like datksoltip.c24soltipcod ,
         c24solnom        like datmligacao.c24solnom   ,
         c24astcod        like datmligacao.c24astcod   ,
         c24funmat        like datmligacao.c24funmat   ,
         ligcvntip        like datmligacao.ligcvntip   ,
         c24paxnum        like datmligacao.c24paxnum   ,
         atdsrvnum        like datrligsrv.atdsrvnum    ,
         atdsrvano        like datrligsrv.atdsrvano    ,
         sinvstnum        like datrligsinvst.sinvstnum ,
         sinvstano        like datrligsinvst.sinvstano ,
         sinavsnum        like datrligsinavs.sinavsnum ,
         sinavsano        like datrligsinavs.sinavsano ,
         succod           like datrligapol.succod      ,
         ramcod           like datrligapol.ramcod      ,
         aplnumdig        like datrligapol.aplnumdig   ,
         itmnumdig        like datrligapol.itmnumdig   ,
         edsnumref        like datrligapol.edsnumref   ,
         prporg           like datrligprp.prporg       ,
         prpnumdig        like datrligprp.prpnumdig    ,
         fcapacorg        like datrligpac.fcapacorg    ,
         fcapacnum        like datrligpac.fcapacnum    ,
         sinramcod        like ssamsin.ramcod          ,
         sinano           like ssamsin.sinano          ,
         sinnum           like ssamsin.sinnum          ,
         sinitmseq        like ssamitem.sinitmseq      ,
         caddat           like datmligfrm.caddat       ,
         cadhor           like datmligfrm.cadhor       ,
         cademp           like datmligfrm.cademp       ,
         cadmat           like datmligfrm.cadmat
  end record

## Alberto cancelamento
 define l_data      date,
        l_hora      datetime hour to minute


 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora

## Alberto cancelamento

  let g_issk.funmat         = null

  begin work
  call cts10g03_numeracao( 1, "5" )

       returning l_ret_srvlig.lignum    ,
                 l_ret_srvlig.atdsrvnum ,
                 l_ret_srvlig.atdsrvano ,
                 l_ret_srvlig.erro      ,
                 l_ret_srvlig.msgerro

  ## let l_cts14m00_ano4 =  '20', argumentos.atdsrvano using "&&"

  let argumentos.lignum       = l_ret_srvlig.lignum
  let argumentos.ligdat       = formata_data(g_paramval[ 1])
  let argumentos.lighorinc    = g_paramval[ 2]
  let argumentos.c24soltipcod = g_paramval[ 3]
  let argumentos.c24solnom    = g_paramval[ 4]
  let argumentos.c24astcod    = g_paramval[ 5]
  let argumentos.c24funmat    = g_paramval[ 6]
  let argumentos.ligcvntip    = 0
  let argumentos.c24paxnum    = 9999
  let argumentos.atdsrvnum    = ""
  let argumentos.atdsrvano    = ""
  let argumentos.sinvstnum    = g_paramval[ 7]
  let argumentos.sinvstano    = g_paramval[ 8]
  let argumentos.sinavsnum    = ""
  let argumentos.sinavsano    = ""
  let argumentos.succod       = g_paramval[ 9]
  let argumentos.ramcod       = g_paramval[10]
  let argumentos.aplnumdig    = g_paramval[11]
  let argumentos.itmnumdig    = g_paramval[12]
  let argumentos.edsnumref    = g_paramval[13]
  let argumentos.prporg       = g_paramval[14]
  let argumentos.prpnumdig    = g_paramval[15]
  let argumentos.fcapacorg    = ""
  let argumentos.fcapacnum    = ""
  let argumentos.sinramcod    = g_paramval[16]
  let argumentos.sinano       = g_paramval[17]
  let argumentos.sinnum       = g_paramval[18]
  let argumentos.sinitmseq    = g_paramval[19]
  let argumentos.caddat       = ""
  let argumentos.cadhor       = ""
  let argumentos.cademp       = ""
  let argumentos.cadmat       = ""

  if l_ret_srvlig.erro <> 0 then
     rollback work
     return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)
  else
     commit work
  end if


 ## INICIALIZAR GLOBAIS
  let g_documento.funmatatd = null
  let g_documento.corsus    = null
  let g_documento.dddcod    = null
  let g_documento.ctttel    = null
  let g_documento.funmat    = null
  let g_documento.cgccpfnum = null
  let g_issk.empcod         = 1
  let g_issk.usrtip         = "F"
  let g_documento.empcodatd = null
  let g_documento.usrtipatd = null
  let l_ret_tab.sqlcode = 0

  begin work
  call cts10g00_ligacao( argumentos.lignum       , ## g_paramval[ 1]
                         argumentos.ligdat       , ## g_paramval[ 2]
                         argumentos.lighorinc    , ## g_paramval[ 3]
                         argumentos.c24soltipcod , ## g_paramval[ 4]
                         argumentos.c24solnom    , ## g_paramval[ 5]
                         argumentos.c24astcod    , ## g_paramval[ 6]
                         argumentos.c24funmat    , ## g_paramval[ 7]
                         argumentos.ligcvntip    , ## g_paramval[ 8]
                         argumentos.c24paxnum    , ## g_paramval[ 9]
                         argumentos.atdsrvnum    , ## g_paramval[10]
                         argumentos.atdsrvano    , ## g_paramval[11]
                         argumentos.sinvstnum    , ## g_paramval[12]
                         argumentos.sinvstano    , ## g_paramval[13]
                         argumentos.sinavsnum    , ## g_paramval[14]
                         argumentos.sinavsano    , ## g_paramval[15]
                         argumentos.succod       , ## g_paramval[16]
                         argumentos.ramcod       , ## g_paramval[17]
                         argumentos.aplnumdig    , ## g_paramval[18]
                         argumentos.itmnumdig    , ## g_paramval[19]
                         argumentos.edsnumref    , ## g_paramval[20]
                         argumentos.prporg       , ## g_paramval[21]
                         argumentos.prpnumdig    , ## g_paramval[22]
                         argumentos.fcapacorg    , ## g_paramval[23]
                         argumentos.fcapacnum    , ## g_paramval[24]
                         argumentos.sinramcod    , ## g_paramval[25]
                         argumentos.sinano       , ## g_paramval[26]
                         argumentos.sinnum       , ## g_paramval[27]
                         argumentos.sinitmseq    , ## g_paramval[28]
                         argumentos.caddat       , ## g_paramval[29]
                         argumentos.cadhor       , ## g_paramval[30]
                         argumentos.cademp       , ## g_paramval[31]
                         argumentos.cadmat         ## g_paramval[32]
                         )
  returning l_ret_tab.tabname,
            l_ret_tab.sqlcode

  let l_mensagem_erro = " "
  if l_ret_tab.sqlcode <> 0 then
     rollback work
     let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-Gravacao na Tabela " ,l_ret_tab.tabname
     let l_ret_srvlig.erro    = l_ret_tab.sqlcode
     let l_ret_srvlig.msgerro = l_mensagem_erro
  else
    commit work
  end if

 if l_ret_tab.sqlcode = 0 then

    ################################# cancelamentos
    #--------------------------------------
    # VERIFICA SE JA' EXISTE O CANCELAMENTO
    #--------------------------------------

    select canmtvdes,    solnom,                vstsoltipcod,
           atdhor   ,    atddat,                funmat
     into  ws.canmtvdes, ws.c24solnom,          ws.c24soltipcod,
           ws.atdhor,    ws.atddat            , ws.funmat
     from  datmvstsincanc
     where sinvstnum = argumentos.sinvstnum    and
           sinvstano = argumentos.sinvstano

    if sqlca.sqlcode   = 100 then
       let ws.operacao = "I"
       let ws.funmat   = argumentos.c24funmat
       let ws.soltip   = "O"
    else
       let ws.operacao = "M"
       select c24soltipdes[1,1]
         into ws.soltip
         from datksoltip
        where c24soltipcod = argumentos.c24soltipcod
    end if

    ## ??? verificar
       let ws.atddat    = l_data
       let ws.atdhor    = l_hora
       let ws.canmtvdes = "CANCELADO PELA MARCACAO DE VISTORIA"

    #-------------------------------------------------------
    #   INCLUSAO/ALTERACAO DO CANCELAMENTO
    #-------------------------------------------------------
    if ws.operacao  =  "I"   then
       begin work
       insert into datmvstsincanc
                 ( sinvstnum,                sinvstano            , canmtvdes,
                   solnom   ,                soltip               , vstsoltipcod,
                   atdhor   ,                atddat               , funmat,
                   empcod,                   usrtip        )
          values ( argumentos.sinvstnum,     argumentos.sinvstano , ws.canmtvdes,
                   argumentos.c24solnom,     ws.soltip            , argumentos.c24soltipcod,
                   ws.atdhor,                ws.atddat            , argumentos.c24funmat,
                   g_issk.empcod,            g_issk.usrtip )

       if sqlca.sqlcode <> 0  then
          ## error " Erro (", sqlca.sqlcode, ") na inclusao do cancelamento. AVISE A INFORMATICA!"
          rollback work
       end if

       select sinvstsolsit
         into ws.sinvstsit
         from datmvstsin
        where sinvstnum = argumentos.sinvstnum and
              sinvstano = argumentos.sinvstano

       if ws.sinvstsit = "S"   then  ### SE LAUDO JA IMPRESSO
          let ws.sinvstsit = "N"     ### REATIVA NA TELA DO SINISTRO
       else
          let ws.sinvstsit = "S"     ### SE LAUDO NAO FOI IMPRESSO
       end if                        ### DESATIVA NA TELA DO SINISTRO

       update datmvstsin set
              sinvstsolsit = ws.sinvstsit
        where sinvstnum = argumentos.sinvstnum and
              sinvstano = argumentos.sinvstano

       if sqlca.sqlcode <> 0  then
          ## error " Erro (", sqlca.sqlcode, ") no flag de cancelamento. AVISE A INFORMATICA!"
          rollback work
       end if
       commit work
    end if

    if ws.operacao  =  "M"   then
       update datmvstsincanc set
             (canmtvdes               , solnom                , soltip    ,
              vstsoltipcod            , atdhor                , atddat    ,
              funmat                  , empcod                , usrtip        )
           = (ws.canmtvdes            , argumentos.c24solnom  , ws.soltip ,
              argumentos.c24soltipcod , ws.atdhor             , ws.atddat ,
              argumentos.c24funmat    , g_issk.empcod         , g_issk.usrtip )
        where sinvstnum = argumentos.sinvstnum    and
              sinvstano = argumentos.sinvstano

       if sqlca.sqlcode <> 0  then
          ## error " Erro (", sqlca.sqlcode, ") na alteracao do cancelamento. AVISE A INFORMATICA!"
       end if
    end if
    ################################# cancelamentos
 end if

 return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)

end function


## Retorno de Marcacao de vistoria.
#---------------------------------------#
function ctx19g00_ret_vst_sin_auto()
#---------------------------------------#

  define l_ret_srvlig
         record
         erro      smallint,
         msgerro   char(80),
         lignum    like datmligacao.lignum,
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
         end record

  define l_ret_tab
         record
         sqlcode         integer,
         tabname         like systables.tabname
         end record

  define l_mensagem_erro char(80)

  define l_cts14m00_ano4 char(04)

  ## Alberto
  define ws          record
    funmat          like isskfunc.funmat             ,
    atddat          like datmvstsin.atddat           ,
    atdhor          like datmvstsin.atdhor           ,
    sinvstsit       like datmvstsin.sinvstsolsit     ,
    operacao        char (01)                        ,
    soltip          like datmvstsincanc.soltip       ,
    canmtvdes       like datmvstsincanc.canmtvdes    ,
    c24solnom       like datmligacao.c24solnom       ,
    c24soltipcod    like datmligacao.c24soltipcod
  end record
  ## Alberto

  define argumentos    record
         lignum           like datmligacao.lignum      ,
         ligdat           like datmligacao.ligdat      ,
         lighorinc        like datmligacao.lighorinc   ,
         c24soltipcod     like datksoltip.c24soltipcod ,
         c24solnom        like datmligacao.c24solnom   ,
         c24astcod        like datmligacao.c24astcod   ,
         c24funmat        like datmligacao.c24funmat   ,
         ligcvntip        like datmligacao.ligcvntip   ,
         c24paxnum        like datmligacao.c24paxnum   ,
         atdsrvnum        like datrligsrv.atdsrvnum    ,
         atdsrvano        like datrligsrv.atdsrvano    ,
         sinvstnum        like datrligsinvst.sinvstnum ,
         sinvstano        like datrligsinvst.sinvstano ,
         sinavsnum        like datrligsinavs.sinavsnum ,
         sinavsano        like datrligsinavs.sinavsano ,
         succod           like datrligapol.succod      ,
         ramcod           like datrligapol.ramcod      ,
         aplnumdig        like datrligapol.aplnumdig   ,
         itmnumdig        like datrligapol.itmnumdig   ,
         edsnumref        like datrligapol.edsnumref   ,
         prporg           like datrligprp.prporg       ,
         prpnumdig        like datrligprp.prpnumdig    ,
         fcapacorg        like datrligpac.fcapacorg    ,
         fcapacnum        like datrligpac.fcapacnum    ,
         sinramcod        like ssamsin.ramcod          ,
         sinano           like ssamsin.sinano          ,
         sinnum           like ssamsin.sinnum          ,
         sinitmseq        like ssamitem.sinitmseq      ,
         caddat           like datmligfrm.caddat       ,
         cadhor           like datmligfrm.cadhor       ,
         cademp           like datmligfrm.cademp       ,
         cadmat           like datmligfrm.cadmat       ,
         vstretdat        like datmvstsin.vstretdat
  end record

 define l_data      date,
        l_hora      datetime hour to minute

 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora

  let g_issk.funmat         = null

  begin work
  call cts10g03_numeracao( 1, "5" )

       returning l_ret_srvlig.lignum    ,
                 l_ret_srvlig.atdsrvnum ,
                 l_ret_srvlig.atdsrvano ,
                 l_ret_srvlig.erro      ,
                 l_ret_srvlig.msgerro

  let argumentos.lignum       = l_ret_srvlig.lignum
  let argumentos.ligdat       = formata_data(g_paramval[ 1])
  let argumentos.lighorinc    = g_paramval[ 2]
  let argumentos.c24soltipcod = g_paramval[ 3]
  let argumentos.c24solnom    = g_paramval[ 4]
  let argumentos.c24astcod    = g_paramval[ 5]
  let argumentos.c24funmat    = g_paramval[ 6]
  let argumentos.ligcvntip    = 0
  let argumentos.c24paxnum    = 9999
  let argumentos.atdsrvnum    = ""
  let argumentos.atdsrvano    = ""
  let argumentos.sinvstnum    = g_paramval[ 7]
  let argumentos.sinvstano    = g_paramval[ 8]
  let argumentos.sinavsnum    = ""
  let argumentos.sinavsano    = ""
  let argumentos.succod       = g_paramval[ 9]
  let argumentos.ramcod       = g_paramval[10]
  let argumentos.aplnumdig    = g_paramval[11]
  let argumentos.itmnumdig    = g_paramval[12]
  let argumentos.edsnumref    = g_paramval[13]
  let argumentos.prporg       = g_paramval[14]
  let argumentos.prpnumdig    = g_paramval[15]
  let argumentos.fcapacorg    = ""
  let argumentos.fcapacnum    = ""
  let argumentos.sinramcod    = g_paramval[16]
  let argumentos.sinano       = g_paramval[17]
  let argumentos.sinnum       = g_paramval[18]
  let argumentos.sinitmseq    = g_paramval[19]
  let argumentos.caddat       = ""
  let argumentos.cadhor       = ""
  let argumentos.cademp       = ""
  let argumentos.cadmat       = ""
  let argumentos.vstretdat    = formata_data(g_paramval[20])

  if l_ret_srvlig.erro <> 0 then
     rollback work
     return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)
  else
     commit work
  end if

  ## INICIALIZAR GLOBAIS
  let g_documento.funmatatd = null
  let g_documento.corsus    = null
  let g_documento.dddcod    = null
  let g_documento.ctttel    = null
  let g_documento.funmat    = null
  let g_documento.cgccpfnum = null
  let g_issk.empcod         = 1
  let g_issk.usrtip         = "F"
  let g_documento.empcodatd = null
  let g_documento.usrtipatd = null
  let l_ret_tab.sqlcode = 0

  begin work
  call cts10g00_ligacao( argumentos.lignum       , ## g_paramval[ 1]
                         argumentos.ligdat       , ## g_paramval[ 2]
                         argumentos.lighorinc    , ## g_paramval[ 3]
                         argumentos.c24soltipcod , ## g_paramval[ 4]
                         argumentos.c24solnom    , ## g_paramval[ 5]
                         argumentos.c24astcod    , ## g_paramval[ 6]
                         argumentos.c24funmat    , ## g_paramval[ 7]
                         argumentos.ligcvntip    , ## g_paramval[ 8]
                         argumentos.c24paxnum    , ## g_paramval[ 9]
                         argumentos.atdsrvnum    , ## g_paramval[10]
                         argumentos.atdsrvano    , ## g_paramval[11]
                         argumentos.sinvstnum    , ## g_paramval[12]
                         argumentos.sinvstano    , ## g_paramval[13]
                         argumentos.sinavsnum    , ## g_paramval[14]
                         argumentos.sinavsano    , ## g_paramval[15]
                         argumentos.succod       , ## g_paramval[16]
                         argumentos.ramcod       , ## g_paramval[17]
                         argumentos.aplnumdig    , ## g_paramval[18]
                         argumentos.itmnumdig    , ## g_paramval[19]
                         argumentos.edsnumref    , ## g_paramval[20]
                         argumentos.prporg       , ## g_paramval[21]
                         argumentos.prpnumdig    , ## g_paramval[22]
                         argumentos.fcapacorg    , ## g_paramval[23]
                         argumentos.fcapacnum    , ## g_paramval[24]
                         argumentos.sinramcod    , ## g_paramval[25]
                         argumentos.sinano       , ## g_paramval[26]
                         argumentos.sinnum       , ## g_paramval[27]
                         argumentos.sinitmseq    , ## g_paramval[28]
                         argumentos.caddat       , ## g_paramval[29]
                         argumentos.cadhor       , ## g_paramval[30]
                         argumentos.cademp       , ## g_paramval[31]
                         argumentos.cadmat         ## g_paramval[32]
                         )
  returning l_ret_tab.tabname,
            l_ret_tab.sqlcode

  let l_mensagem_erro = " "
  if l_ret_tab.sqlcode <> 0 then
     rollback work
     let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-Gravacao na Tabela " ,l_ret_tab.tabname
     let l_ret_srvlig.erro    = l_ret_tab.sqlcode
     let l_ret_srvlig.msgerro = l_mensagem_erro
     return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)
  else
     commit work
  end if

  if l_ret_tab.sqlcode = 0 then
     begin work
        update datmvstsin
        set    vstretdat = argumentos.vstretdat,
               vstretflg = 'S'
         where sinvstnum = argumentos.sinvstnum and
               sinvstano = argumentos.sinvstano

        if sqlca.sqlcode <> 0  then
           let l_mensagem_erro = "Erro na atualizacao da tabela datmvstsin"  clipped , sqlca.sqlcode
           let l_ret_srvlig.erro    = l_ret_tab.sqlcode
           let l_ret_srvlig.msgerro = l_mensagem_erro
           rollback work
        else
           commit work
        end if
  end if

 return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)

end function

#--------------------------------#
function formata_data(l_argumento)
#--------------------------------#

  define l_argumento  char(10),
         l_dt_char    char(10),
         l_dt_final   date

  let l_dt_final   = null

  # -> FORMATA A DATA com Dia, Mes e Ano
  let l_dt_char  = l_argumento[1,2], "/" ,l_argumento[4,5], "/" ,l_argumento[7,10]

  let l_dt_final = l_dt_char

  if l_dt_final is null then ## Se a data estier no formato Mes, Dia e Ano MM/DD/AAAA
     # -> FORMATA A DATA para Dia, Mes e Ano
     let l_dt_char  = l_argumento[4,5],"/",l_argumento[1,2],"/",l_argumento[7,10]
     let l_dt_final = l_dt_char
     display "DATA DO PARAMETRO INVALIDA (DATA INVALIDA)!"
     display "DATA CORRIGIDA DE -> ",l_argumento, " PARA ", l_dt_final
  end if

  return l_dt_final

end function

#---------------------------------------#
function ctx19g00_reg_lig_ct24h()
#---------------------------------------#
# esta funcao atende os assuntos:
#	. B01     - INFORMACOES GERAIS SOBRE APOLICES - RE/AUTO
#	. B02     - PREVIDENCIA - ALTERACAO CADASTRAL
#	. B05     - PREVIDENCIA - INFORME DE RENDIMENTOS
#   	. B12     - INFORMACOES GERAIS SOLICITACAO 2A VIA CARTAO PROTECAO
#       . B21     - CONSULTA DE ENDERECOS DE POSTOS VISTORIA PREVIA
#       . U10     - CONSULTA A PROCESSOS DE SINISTRO PSI 211753
#       . N10/N11 - Laudo - Aviso de Sinistro

 define l_ret_srvlig
        record
        erro           smallint,
        msgerro        char(80),
        lignum         like datmligacao.lignum,
        atdsrvnum      like datmservico.atdsrvnum,
        atdsrvano      like datmservico.atdsrvano
        end record

 define l_ret_tab
        record
        sqlcode        integer,
        tabname        like systables.tabname
        end record

 define l_mensagem_erro char(80)

 define l_linha_hist    char(80)

 define l_cts14m00_ano4 char(04)

 define l_historico record
        cep         char(09)
       ,endereco    char(80)
       ,complemento char(50)
       ,bairro      char(30)
       ,cidade      char(40)
 end record

 define l_aux  record
        flag        smallint
 end record

 define argumentos    record
  lignum           like datmligacao.lignum      ,
  ligdat           like datmligacao.ligdat      ,
  lighorinc        like datmligacao.lighorinc   ,
  lighorfnl        like datmligacao.lighorfnl   ,
  c24soltipcod     like datksoltip.c24soltipcod ,
  c24solnom        like datmligacao.c24solnom   ,
  c24astcod        like datmligacao.c24astcod   ,
  c24funmat        like datmligacao.c24funmat   ,
  ligcvntip        like datmligacao.ligcvntip   ,
  c24paxnum        like datmligacao.c24paxnum   ,
  atdsrvnum        like datrligsrv.atdsrvnum    ,
  atdsrvano        like datrligsrv.atdsrvano    ,
  sinvstnum        like datrligsinvst.sinvstnum ,
  sinvstano        like datrligsinvst.sinvstano ,
  sinavsnum        like datrligsinavs.sinavsnum ,
  sinavsano        like datrligsinavs.sinavsano ,
  succod           like datrligapol.succod      ,
  ramcod           like datrligapol.ramcod      ,
  aplnumdig        like datrligapol.aplnumdig   ,
  itmnumdig        like datrligapol.itmnumdig   ,
  edsnumref        like datrligapol.edsnumref   ,
  prporg           like datrligprp.prporg       ,
  prpnumdig        like datrligprp.prpnumdig    ,
  fcapacorg        like datrligpac.fcapacorg    ,
  fcapacnum        like datrligpac.fcapacnum    ,
  sinramcod        like ssamsin.ramcod          ,
  sinano           like ssamsin.sinano          ,
  sinnum           like ssamsin.sinnum          ,
  sinitmseq        like ssamitem.sinitmseq      ,
  caddat           like datmligfrm.caddat       ,
  cadhor           like datmligfrm.cadhor       ,
  cademp           like datmligfrm.cademp       ,
  cadmat           like datmligfrm.cadmat       ,
  # Parametros para registrar ligacao Sem Documento
  # Se for enviado apolice ou proposta estes campos dever�o ser nulo.
  corsus	   like datrligcor.corsus       ,#susep que esta ligando
  dddcod	   like datrligtel.dddcod       ,#telefone de quem est� ligando
  ctttel	   like datrligtel.teltxt       ,#telefone de quem est� ligando
  funmat	   like datrligmat.funmat       ,#matricula de quem esta ligando
  empcod 	   like datrligmat.empcod       ,#empresa da matricula que ligou
  usrtip	   like datrligmat.usrtip       ,#tipo da matricula que ligou
  cgccpfnum        like datrligcgccpf.cgccpfnum ,#cgc/cpf de quem esta ligando
  cgcord           like datrligcgccpf.cgcord    ,#cgc/cpf de quem esta ligando
  cgccpfdig        like datrligcgccpf.cgccpfdig ,#cgc/cpf de quem esta ligando
  # Para registro do agendamento de servicos via Portal
  vstagnnum        like datrligagn.vstagnnum    ,#nro agendto.VP ou Curso Direc
  atdnum           like datmatd6523.atdnum       #numero de atendimento
 ,qtd_historico    smallint
 ,historico        char(32766)
 end record

 define l_data      date,
        l_hora      datetime hour to minute

 define l_grava smallint
 define l_vstagnstt like datrligagn.vstagnstt
 define l_erro  smallint
 define l_msg_erro char(200)
 define l_ret       smallint,
        l_mensagem  char(60)
 ## Historico da WEB
 define n_posicao_inc smallint
 define n_posicao_fin smallint
 define n_conta       smallint
 define ln10_historico   char(70)

 initialize argumentos.*   to null
 initialize l_grava        to null
 initialize l_vstagnstt    to null
 initialize l_linha_hist   to null
 initialize l_ret_srvlig.* to null
 initialize l_aux.*        to null


 let l_erro                  = 0
 let l_msg_erro              = null
 let l_ret                   = 0
 let l_mensagem              = null
 let l_grava                 = false
 let argumentos.ligdat       = formata_data(g_paramval[ 1])
 let argumentos.lighorinc    = g_paramval[ 2]
 let argumentos.lighorfnl    = g_paramval[ 3]
 let argumentos.c24soltipcod = g_paramval[ 4]
 let argumentos.c24solnom    = g_paramval[ 5]
 let argumentos.c24astcod    = g_paramval[ 6]
 let argumentos.c24funmat    = g_paramval[ 7] # 999999
 let argumentos.ligcvntip    = g_paramval[ 8] # 0
 let argumentos.c24paxnum    = g_paramval[ 9] # 9999
 let argumentos.succod       = g_paramval[10]
 let argumentos.ramcod       = g_paramval[11]
 let argumentos.aplnumdig    = g_paramval[12]
 let argumentos.itmnumdig    = g_paramval[13]
 let argumentos.edsnumref    = g_paramval[14]
 let argumentos.prporg       = g_paramval[15]
 let argumentos.prpnumdig    = g_paramval[16]

 # Parametros para registrar ligacao Sem Documento
 let argumentos.corsus	     = g_paramval[17]
 let argumentos.dddcod	     = g_paramval[18]
 let argumentos.ctttel	     = g_paramval[19]
 let argumentos.funmat	     = g_paramval[20]
 let argumentos.empcod 	     = g_paramval[21]
 let argumentos.usrtip	     = g_paramval[22]
 let argumentos.cgccpfnum    = g_paramval[23]
 let argumentos.cgcord       = g_paramval[24]
 let argumentos.cgccpfdig    = g_paramval[25]

 # parametros para registrar ligacao de U10
 # para esta alteracao nao ha mais a necessidade de gravar os campos
 # (ligsinpndflg,sintfacod) esta informacao era atualizada no modulo cta06m00
 # de acordo com Ana Paula e Michel.
 let argumentos.sinramcod    = g_paramval[26]
 let argumentos.sinano       = g_paramval[27]
 let argumentos.sinnum       = g_paramval[28]
 let argumentos.sinitmseq    = g_paramval[29]

 # para registrar numero da agendamento de servicos (VP ou Curso Direcao Def.)
 let argumentos.vstagnnum    = g_paramval[30]

 # Para registrar o numero do atedimento
 let argumentos.atdnum       = g_paramval[31]

 # PSI 206.938 Para registrar o numero do atedimento
 let argumentos.lignum       = g_paramval[32]
 let argumentos.sinavsnum    = g_paramval[33]
 let argumentos.sinavsano    = g_paramval[34]

 ---> Estes argval sao utilizados, mas nao se sabe quem passa e o que passa
 ---> Deixar os argumentos reservados e nas novas chamadas passar sempre nulo
 --->                        = g_paramval[35]
 --->                        = g_paramval[36]
 --->                        = g_paramval[37]
 --->                        = g_paramval[38]
 --->                        = g_paramval[39]
 --->                        = g_paramval[40]
 --->                        = g_paramval[41]
 --->                        = g_paramval[42]
 --->                        = g_paramval[43]
 --->                        = g_paramval[44]

 ---> O argumento 45 recebe a quantidade de linhas do Historico, que deve ficar
 ---> sempre na ultima posicao, caso seja acrescentado novos argumentos alterar
 ---> o "let m_hist_qtd = g_paramval[ 45]" que se encontra mais abaixo
 --->                        = g_paramval[45]


 ## INICIALIZAR GLOBAIS
 let g_documento.funmatatd = null
 let g_documento.dddcod    = null
 let g_documento.ctttel    = null
 let g_documento.funmat    = null
 let g_documento.cgccpfnum = null
 let g_issk.empcod         = 1
 let g_issk.usrtip         = "F"
 let g_documento.empcodatd = null
 let g_documento.usrtipatd = null
 let g_issk.funmat         = null
 let l_ret_tab.sqlcode     = 0
 let l_ret_srvlig.msgerro  = null
 let g_documento.atdnum    = null

 if  argumentos.itmnumdig  is null or
     argumentos.itmnumdig  = "  "  then
     let argumentos.itmnumdig = 0
 end if
 if  argumentos.edsnumref  is null or
     argumentos.edsnumref  = "   " then
     let argumentos.edsnumref = 0
 end if
 if argumentos.prporg = 0 then
    let argumentos.prporg = null
 end if
 if argumentos.prpnumdig = 0 then
    let argumentos.prpnumdig = null
 end if

display " argumentos.ligdat       ", argumentos.ligdat
display " argumentos.lighorinc    ", argumentos.lighorinc
display " argumentos.lighorfnl    ", argumentos.lighorfnl
display " argumentos.c24soltipcod ", argumentos.c24soltipcod
display " argumentos.c24solnom    ", argumentos.c24solnom
display " argumentos.c24astcod    ", argumentos.c24astcod
display " argumentos.c24funmat    ", argumentos.c24funmat
display " argumentos.ligcvntip    ", argumentos.ligcvntip
display " argumentos.c24paxnum    ", argumentos.c24paxnum
display " argumentos.succod       ", argumentos.succod
display " argumentos.ramcod       ", argumentos.ramcod
display " argumentos.aplnumdig    ", argumentos.aplnumdig
display " argumentos.itmnumdig    ", argumentos.itmnumdig
display " argumentos.edsnumref    ", argumentos.edsnumref
display " argumentos.prporg       ", argumentos.prporg
display " argumentos.prpnumdig    ", argumentos.prpnumdig


 ## Consiste sem Documento
 let l_ret_srvlig.msgerro = ctx19g00_cons_sem_doc( argumentos.aplnumdig,
                                                   argumentos.prpnumdig,
                                                   argumentos.corsus,
                                                   argumentos.dddcod,
                                                   argumentos.ctttel,
                                                   argumentos.funmat,
                                                   argumentos.empcod,
                                                   argumentos.usrtip,
                                                   argumentos.cgccpfnum,
                                                   argumentos.cgcord,
                                                   argumentos.cgccpfdig )
 if l_ret_srvlig.msgerro is not null and
    l_ret_srvlig.msgerro <> " "  then
    let l_ret_srvlig.erro = 999
    return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)
 end if

 ----[ carrega as globais para registro da ligacao ]-----
 if argumentos.corsus is not null then
    let g_documento.corsus = argumentos.corsus
 end if
 if argumentos.dddcod is not null then
    let g_documento.dddcod = argumentos.dddcod
    let g_documento.ctttel = argumentos.ctttel
 end if
 if argumentos.funmat is not null then
    let g_documento.funmat = argumentos.funmat
 end if
 if argumentos.cgccpfnum is not null then
    let g_documento.cgccpfnum = argumentos.cgccpfnum
    if argumentos.cgcord is null then
       let argumentos.cgcord = 0
    end if
    let g_documento.cgcord    = argumentos.cgcord
    let g_documento.cgccpfdig = argumentos.cgccpfdig
 end if

 let l_ret_srvlig.msgerro = null

 let l_ret_srvlig.msgerro = ctx19g00_consiste( argumentos.c24soltipcod ,
                                               argumentos.c24solnom    ,
                                               argumentos.c24astcod    ,
                                               argumentos.c24funmat    ,
                                               argumentos.succod       ,
                                               argumentos.ramcod       ,
                                               argumentos.aplnumdig    ,
                                               argumentos.itmnumdig    ,
                                               argumentos.edsnumref    ,
                                               argumentos.prpnumdig    ,
                                               argumentos.sinramcod    ,
                                               argumentos.sinano       ,
                                               argumentos.sinnum       ,
                                               argumentos.sinitmseq    ,
                                               argumentos.vstagnnum    ,
                                               0 )
 if l_ret_srvlig.msgerro is not null and
    l_ret_srvlig.msgerro <> " "  then
    let l_ret_srvlig.erro = 999
    return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)
 end if

 if argumentos.c24astcod = "B01"  and   # consulta apolice RE/AUTO
    argumentos.c24funmat = 999999 then  # portal
    # registrar somente o ultimo atendimento do dia para o assunto e apolice
    declare c_ctx19g00001 cursor for
       select max(b.lignum)
          from datrligapol a,
               datmligacao b
           where b.ligdat    = argumentos.ligdat
             and b.c24astcod = argumentos.c24astcod
             and b.lignum    = a.lignum
             and a.succod    = argumentos.succod
             and a.ramcod    = argumentos.ramcod
             and a.aplnumdig = argumentos.aplnumdig
             and a.itmnumdig = argumentos.itmnumdig

    foreach c_ctx19g00001 into l_ret_srvlig.lignum

     if l_ret_srvlig.lignum is not null then
       update datmligacao
           set (lighorinc,
                lighorfnl) =
               (argumentos.lighorinc,
                argumentos.lighorfnl)
           where lignum = l_ret_srvlig.lignum
       if sqlca.sqlcode <> 0  then
          let l_ret_srvlig.msgerro = "Erro na ATZ. Datmligacao - ctx19g00001"
          let l_ret_srvlig.erro    = sqlca.sqlcode
       else
          display "* ATZ.LIGACAO = ",l_ret_srvlig.lignum,",",
                  argumentos.lighorinc,",", argumentos.lighorfnl
       end if
       return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)
     end if
     exit foreach
    end foreach
 end if

 display "<2249> Ligacao ->> ", argumentos.lignum

 if argumentos.lignum is null then


    begin work
    ## Gera N� Liga��o
    call cts10g03_numeracao( 1, "" )
         returning l_ret_srvlig.lignum    ,
                   l_ret_srvlig.atdsrvnum ,
                   l_ret_srvlig.atdsrvano ,
                   l_ret_srvlig.erro      ,
                   l_ret_srvlig.msgerro


     if l_ret_srvlig.erro <> 0 then
        rollback work
        return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)
     else
        commit work
     end if
 end if


 if argumentos.lignum is null then
    let argumentos.lignum       = l_ret_srvlig.lignum
 end if

 ## Grava Liga��o
 display "* ctx19g00-gerar ligacao = ", argumentos.lignum
 display "  g_documento.dddcod    = ", g_documento.dddcod
 display "  g_documento.ctttel    = ", g_documento.ctttel
 display "  g_documento.funmat    = ", g_documento.funmat
 display "  g_documento.cgccpfnum = ", g_documento.cgccpfnum

 if argumentos.c24astcod        = "N10" or
    argumentos.c24astcod        = "N11" then
    if argumentos.sinramcod     is not null and
       argumentos.sinano        is not null and
       argumentos.sinnum        is not null and
       argumentos.sinitmseq     is not null then
       let argumentos.sinavsnum = null
       let argumentos.sinavsano = null

       let argumentos.atdsrvnum = null
       let argumentos.atdsrvano = null
       let argumentos.sinvstnum = null
       let argumentos.sinvstano = null


    end if
 end if

 begin work
 call cts10g00_ligacao( argumentos.lignum       ,
                        argumentos.ligdat       ,
                        argumentos.lighorinc    ,
                        argumentos.c24soltipcod ,
                        argumentos.c24solnom    ,
                        argumentos.c24astcod    ,
                        argumentos.c24funmat    ,
                        argumentos.ligcvntip    ,
                        argumentos.c24paxnum    ,
                        argumentos.atdsrvnum    ,
                        argumentos.atdsrvano    ,
                        argumentos.sinvstnum    ,
                        argumentos.sinvstano    ,
                        argumentos.sinavsnum    ,
                        argumentos.sinavsano    ,
                        argumentos.succod       ,
                        argumentos.ramcod       ,
                        argumentos.aplnumdig    ,
                        argumentos.itmnumdig    ,
                        argumentos.edsnumref    ,
                        argumentos.prporg       ,
                        argumentos.prpnumdig    ,
                        argumentos.fcapacorg    ,
                        argumentos.fcapacnum    ,
                        argumentos.sinramcod    ,
                        argumentos.sinano       ,
                        argumentos.sinnum       ,
                        argumentos.sinitmseq    ,
                        argumentos.caddat       ,
                        argumentos.cadhor       ,
                        argumentos.cademp       ,
                        argumentos.cadmat
                        )
 returning l_ret_tab.tabname,
           l_ret_tab.sqlcode

 let l_mensagem_erro = " "

 if l_ret_tab.sqlcode <> 0 then
    let l_mensagem_erro = l_mensagem_erro clipped ,
                          l_ret_tab.sqlcode clipped using '<<<<' clipped,
                          "-Gravacao na Tabela " ,l_ret_tab.tabname
    let l_ret_srvlig.erro    = l_ret_tab.sqlcode
    let l_ret_srvlig.msgerro = l_mensagem_erro
    rollback work
    return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)
 else
    # a funcao cts10g00_ligacao nao grava a hora final da ligacao
    if argumentos.lighorfnl is not null then
       update datmligacao
         set lighorfnl = argumentos.lighorfnl
       where lignum = argumentos.lignum
    end if
  commit work
 end if

 # quando entrar outro assunto tem que alterar o cta04m00_msg #
 if (argumentos.c24astcod = "B01"  or    # consulta apolice RE/AUTO
     argumentos.c24astcod = "B12"  or    # solicitacao de 2.o via cartao
     argumentos.c24astcod = "B21") and   # Consulta end. postos vistoria
     argumentos.c24funmat = 999999 then  # portal
     # envia email para o corretor
     if argumentos.ramcod  <> 31  and
        argumentos.ramcod  <> 531 then
        let g_documento.ramgrpcod = 2
     else
        let g_documento.ramgrpcod = 1
     end if
     let g_issk.funmat = 999999
     let g_issk.empcod = 1
     let g_issk.usrtip = "F"
     let g_issk.maqsgl = "u87"
     let g_issk.sissgl = "ct24hs"


     call cta04m00(argumentos.ramcod,
                   argumentos.succod,
                   argumentos.aplnumdig,
                   argumentos.itmnumdig,
                   argumentos.lignum,
                   2)  # envia pager e email
           returning l_aux.flag

 end if

 ----[registrar o agendamento via portal - 30/10/07]---
 ---> Agendamento de VP
 if argumentos.c24astcod = "D15"  or  # cancelar
    argumentos.c24astcod = "D18"  or  # consultar
    argumentos.c24astcod = "D68"  then# agendar

    if argumentos.vstagnnum is not null then
       case argumentos.c24astcod
          when "D15" let l_vstagnstt = "C"
          when "D68" let l_vstagnstt = "I"
          otherwise  let l_vstagnstt = null
       end case


       call cts40g20_grava_agend("S",  # --> "S" = ATD. SEGURADO
                                 "",   # l_orgvstagnnum,
                                 "",   # --> CORLIGNUM
                                 "",   # --> CORLIGITMSEQ
                                 argumentos.vstagnnum,
                                 l_vstagnstt,
                                 "",   # --> CORLIGANO
                                 argumentos.lignum)
            returning l_aux.flag
    end if
 end if

 ---> Agendamento do Curso de Direcao defensiva
 if argumentos.c24astcod = "D00"  or  # agendar
    argumentos.c24astcod = "D10"  or  # consultar
    argumentos.c24astcod = "D11"  or  # alterar
    argumentos.c24astcod = "D12"  then# cancelar

    if argumentos.vstagnnum is not null then
       case argumentos.c24astcod
          when "D12" let l_vstagnstt = "C"
          when "D00" let l_vstagnstt = "A"
          when "D11" let l_vstagnstt = "A"
          otherwise  let l_vstagnstt = null
       end case

       call cts40g20_grava_dir_def("S",  # --> "S" = ATD. SEGURADO
                                   "",   # l_orgvstagnnum,
                                   "",   # --> CORLIGNUM
                                   "",   # --> CORLIGITMSEQ
                                   argumentos.vstagnnum,
                                   l_vstagnstt,
                                   "",   # --> CORLIGANO
                                   argumentos.lignum)
            returning l_aux.flag
    end if
 end if

 --> Psi 230669
 if argumentos.atdnum is not null     and
    argumentos.atdnum <>  0           and
    argumentos.atdnum <> -0           then

  begin work
    call ctd25g00_insere_atendimento(argumentos.atdnum,argumentos.lignum)
         returning l_erro,l_msg_erro
  commit work

    if l_erro = 1 then
       display l_msg_erro
    end if
 end if

 --> Psi 230669

 #   Historico de N10/N11
 ## let argumentos.qtd_historico = g_paramval[45]  # Qtde de linhas do Historico
 ## let argumentos.historico     = g_paramval[46]  # Historico
 let m_hist_qtd    = 0
 let m_conta_linha = 0
 let m_conta       = 0
 let m_historico   = " "
 let m_hist_qtd = g_paramval[ 45]
 ## quando implementar ou publicar o modelo JAVA, retirar o comentario e tratar o Hist�rico
 ## com mais de uma linha.
 ## let argumentos.atendimento   = g_paramval[44]  # Numero do Atendimento Decreto 6.523
 for m_conta_linha = 1 to m_hist_qtd
     let m_conta       = m_conta_linha + 45
     let m_historico   = m_historico clipped , g_paramval[m_conta]
 end for

 if argumentos.c24astcod = "N10" or
    argumentos.c24astcod = "N11" then
    display "<ctx19g00> **** Gravando Hist�rico da Liga��o"
    #---------------------------------------------------------------------------
    # Grava tabela de Historico da Ligacao
    #---------------------------------------------------------------------------
    display "<2523> ctx19g00-> Gravando Datmlighist "
    let l_mensagem_erro = "**** GRAVOU OK ****"
    let n_posicao_fin   = 0
    let n_conta         = 0
    let ln10_historico  = " "
    let n_posicao_inc   = 1
    for n_conta = 1 to m_hist_qtd
        let n_posicao_fin = n_conta * 70
        let ln10_historico = m_historico[n_posicao_inc,n_posicao_fin]

        call ctd06g01_ins_datmlighist(argumentos.lignum         ,
                                      argumentos.c24funmat      ,
                                      ln10_historico            ,
                                      argumentos.ligdat         ,
                                      argumentos.lighorinc      ,
                                      g_issk.empcod             ,
                                      g_issk.usrtip)

        returning l_ret,
                  l_mensagem

        if l_ret <> 1  then
           let l_mensagem_erro = l_mensagem," ","ctx19g00-Avise Info!"
           exit for
        end if
        let n_posicao_inc = n_posicao_fin + 1
    end for
    display "<ctx19g00> ",l_mensagem
 end if
 #   Historico

 return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)

end function

#---------------------------------------#
function ctx19g00_reg_end_env_crt()
#---------------------------------------#
# Registrar solicitacao e 2� Via Cart�o

 define l_ret_srvlig
        record
        erro           smallint,
        msgerro        char(80),
        lignum         like datmligacao.lignum,
        atdsrvnum      like datmservico.atdsrvnum,
        atdsrvano      like datmservico.atdsrvano
        end record

 define l_ret_tab
        record
        sqlcode        integer,
        tabname        like systables.tabname
        end record

 define l_mensagem_erro char(80)

 define argumentos    record
        segnumdig     like datmsegviaend.segnumdig ,
        endlgdtip     like datmsegviaend.endlgdtip ,
        endlgd        like datmsegviaend.endlgd    ,
        endnum        like datmsegviaend.endnum    ,
        endcmp        like datmsegviaend.endcmp    ,
        endcep        like datmsegviaend.endcep    ,
        endcepcmp     like datmsegviaend.endcepcmp ,
        endcid        like datmsegviaend.endcid    ,
        endufd        like datmsegviaend.endufd    ,
        endbrr        like datmsegviaend.endbrr    ,
        lignum        like datmligacao.lignum
 end record

 define l_data      date,
        l_hora      datetime hour to minute

 define l_historico record
        cep         char(09)
       ,endereco    char(80)
       ,complemento char(50)
       ,bairro      char(30)
       ,cidade      char(40)
 end record

 define l_grava smallint


 initialize argumentos.*    to null
 initialize l_ret_tab.*     to null
 initialize l_ret_srvlig.*  to null
 initialize l_historico.*   to null

 let l_grava = false

 let argumentos.segnumdig  = g_paramval[ 1]
 let argumentos.endlgdtip  = g_paramval[ 2]
 let argumentos.endlgd     = g_paramval[ 3]
 let argumentos.endnum     = g_paramval[ 4]
 let argumentos.endcmp     = g_paramval[ 5] ##
 let argumentos.endcep     = g_paramval[ 6]
 let argumentos.endcepcmp  = g_paramval[ 7]
 let argumentos.endcid     = g_paramval[ 8]
 let argumentos.endufd     = g_paramval[ 9]
 let argumentos.endbrr     = g_paramval[10] ##
 let argumentos.lignum     = g_paramval[11] ## Ligacao

 ## INICIALIZAR GLOBAIS
 let g_documento.funmatatd = null
 let g_documento.corsus    = null
 let g_documento.dddcod    = null
 let g_documento.ctttel    = null
 let g_documento.funmat    = null
 let g_documento.cgccpfnum = null
 let g_issk.empcod         = 1
 let g_issk.funmat         = 999999
 let g_issk.usrtip         = "F"
 let g_documento.empcodatd = null
 let g_documento.usrtipatd = null
 let l_ret_tab.sqlcode     = 0
 let l_ret_srvlig.erro     = 0

 ## Se algum parametro for nulo retorna critica
 let l_ret_srvlig.msgerro = " "
 let l_ret_srvlig.msgerro = ctx19g00_consiste_env(argumentos.segnumdig ,
                                                  argumentos.endlgdtip ,
                                                  argumentos.endlgd    ,
                                                  argumentos.endnum    ,
                                                  argumentos.endcep    ,
                                                  argumentos.endcepcmp ,
                                                  argumentos.endcid    ,
                                                  argumentos.endufd    ,
                                                  0)

 if l_ret_srvlig.msgerro is not null and
    l_ret_srvlig.msgerro <> " "  then
    let l_ret_srvlig.erro = 999
    return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)
 end if

 ## Grava solicitacao datmsegviaend
 begin work
   #-- Verifica se existe na tabela datmsegviaend o codigo segnumdig
   whenever error continue
      select * from datmsegviaend
       where segnumdig = argumentos.segnumdig
   whenever error stop

   if sqlca.sqlcode < 0 then
      let l_mensagem_erro = " Erro (", sqlca.sqlcode, ") na selecao da tab.datmsegviaend. AVISE A INFORMATICA!"
      rollback work
   end  if

   #-- Se nao encontrou, incluir dados
   if sqlca.sqlcode = 100 then
      # RSantos - OSF 28983
      whenever error continue
      insert into datmsegviaend (segnumdig
                                ,endlgdtip
                                ,endlgd
                                ,endnum
                                ,endcmp
                                ,endcep
                                ,endcepcmp
                                ,endcid
                                ,endufd
                                ,endbrr)
                      values (   argumentos.segnumdig
                                ,argumentos.endlgdtip
                                ,argumentos.endlgd
                                ,argumentos.endnum
                                ,argumentos.endcmp
                                ,argumentos.endcep
                                ,argumentos.endcepcmp
                                ,argumentos.endcid
                                ,argumentos.endufd
                                ,argumentos.endbrr)
      whenever error stop
      if sqlca.sqlcode <> 0 then
         let l_ret_tab.sqlcode = sqlca.sqlcode
         let l_ret_tab.tabname = " datmsegviaend (Insert)"
         rollback work
      else
         commit work
      end if
   #-- Se encontrou, alterar os dados
   else

      whenever error continue
         update datmsegviaend set
                endlgdtip = argumentos.endlgdtip
               ,endlgd    = argumentos.endlgd
               ,endnum    = argumentos.endnum
               ,endcmp    = argumentos.endcmp
               ,endcep    = argumentos.endcep
               ,endcepcmp = argumentos.endcepcmp
               ,endcid    = argumentos.endcid
               ,endufd    = argumentos.endufd
               ,endbrr    = argumentos.endbrr
          where segnumdig = argumentos.segnumdig
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let l_ret_tab.sqlcode = sqlca.sqlcode
         let l_ret_tab.tabname = " datmsegviaend (Update)"
         rollback work
         ## return
      else
         commit work
      end if
   end if
   let l_mensagem_erro = " "

 ## Pegar data e hora do banco para atualizar datmligacao
 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora

 ## Historico da ligacao
 let l_historico.cep = argumentos.endcep ,"-", argumentos.endcepcmp
 let l_grava = true
 begin work
   call ctd06g01_ins_datmlighist(argumentos.lignum,
                                 g_issk.funmat,
                                 l_historico.cep,
                                 l_data,
                                 l_hora,
                                 g_issk.usrtip,
                                 g_issk.empcod  )
   returning l_ret_tab.sqlcode,  #retorno
             l_ret_tab.tabname   #mensagem

   if l_ret_tab.sqlcode <> 1 then
      let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-1 Gravacao na Tabela " ,l_ret_tab.tabname
      let l_ret_srvlig.erro    = l_ret_tab.sqlcode
      let l_ret_srvlig.msgerro = l_mensagem_erro
      let l_grava = false
   else
      let l_mensagem_erro   = " "
      let l_ret_tab.sqlcode = null
      let l_ret_tab.tabname = null
   end if

   let l_historico.endereco = argumentos.endlgdtip clipped
                             ," "
                             ,argumentos.endlgd  clipped
                             ," "
                             ,argumentos.endnum clipped
   call ctd06g01_ins_datmlighist(argumentos.lignum,
                                 g_issk.funmat,
                                 l_historico.endereco,
                                 l_data,
                                 l_hora,
                                 g_issk.usrtip,
                                 g_issk.empcod  )
      returning l_ret_tab.sqlcode,  #retorno
                l_ret_tab.tabname   #mensagem

   if l_ret_tab.sqlcode <> 1 then
      let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-2 Gravacao na Tabela " ,l_ret_tab.tabname
      let l_ret_srvlig.erro    = l_ret_tab.sqlcode
      let l_ret_srvlig.msgerro = l_mensagem_erro
      let l_grava = false
   else
      let l_mensagem_erro   = " "
      let l_ret_tab.sqlcode = null
      let l_ret_tab.tabname = null
   end if

   let l_historico.complemento = argumentos.endcmp clipped

   call ctd06g01_ins_datmlighist(argumentos.lignum,
                                 g_issk.funmat,
                                 l_historico.complemento,
                                 l_data,
                                 l_hora,
                                 g_issk.usrtip,
                                 g_issk.empcod  )
        returning l_ret_tab.sqlcode,  #retorno
                  l_ret_tab.tabname   #mensagem

   if l_ret_tab.sqlcode <> 1 then
      let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-3 Gravacao na Tabela " ,l_ret_tab.tabname
      let l_ret_srvlig.erro    = l_ret_tab.sqlcode
      let l_ret_srvlig.msgerro = l_mensagem_erro
      let l_grava = false
   else
      let l_mensagem_erro   = " "
      let l_ret_tab.sqlcode = null
      let l_ret_tab.tabname = null
   end if

   let l_historico.bairro = argumentos.endbrr clipped
   call ctd06g01_ins_datmlighist(argumentos.lignum,
                                 g_issk.funmat,
                                 l_historico.bairro,
                                 l_data,
                                 l_hora,
                                 g_issk.usrtip,
                                 g_issk.empcod  )
        returning l_ret_tab.sqlcode,  #retorno
                  l_ret_tab.tabname   #mensagem
   if l_ret_tab.sqlcode <> 1 then
      let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-4 Gravacao na Tabela " ,l_ret_tab.tabname
      let l_ret_srvlig.erro    = l_ret_tab.sqlcode
      let l_ret_srvlig.msgerro = l_mensagem_erro
      let l_grava = false
   else
      let l_mensagem_erro   = " "
      let l_ret_tab.sqlcode = null
      let l_ret_tab.tabname = null
   end if

   let l_historico.cidade = argumentos.endcid clipped," - ",argumentos.endufd clipped

   call ctd06g01_ins_datmlighist(argumentos.lignum,
                                 g_issk.funmat,
                                 l_historico.cidade,
                                 l_data,
                                 l_hora,
                                 g_issk.usrtip,
                                 g_issk.empcod  )
        returning l_ret_tab.sqlcode,  #retorno
                  l_ret_tab.tabname   #mensagem
   if l_ret_tab.sqlcode <> 1 then
      let l_mensagem_erro = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-5 Gravacao na Tabela " ,l_ret_tab.tabname
      let l_ret_srvlig.erro    = l_ret_tab.sqlcode
      let l_ret_srvlig.msgerro = l_mensagem_erro
      let l_grava = false
   else
      let l_mensagem_erro   = " "
      let l_ret_tab.sqlcode = null
      let l_ret_tab.tabname = null
   end if

   update datmligacao
   set    lighorfnl = l_hora
   where  lignum = argumentos.lignum
   let l_mensagem_erro = " "
   let l_ret_tab.sqlcode = sqlca.sqlcode
   if  sqlca.sqlerrd[3] <> 1 then
       let l_mensagem_erro      = l_mensagem_erro clipped , l_ret_tab.sqlcode clipped using '<<<<' clipped, "-6 Gravacao na Tabela Datmligacao"
       let l_ret_srvlig.erro    = l_ret_tab.sqlcode
       let l_ret_srvlig.msgerro = l_mensagem_erro
       let l_grava = false
   end if

 if l_grava then
    commit work
 else
    rollback work
 end if

 ######################### Hist�rico da ligacao ##############################

 return ctx19g00Service_monta_xml_srvlig(l_ret_srvlig.*)

end function

#-------------------------------------------------------------------------------
function ctx19g00_consiste_env(l_par_cons) ## Consistir parametros obrigat�rios
#-------------------------------------------------------------------------------

 define msg_erro  char(80)

 define l_par_cons record
         segnumdig     like datmsegviaend.segnumdig ,
         endlgdtip     like datmsegviaend.endlgdtip ,
         endlgd        like datmsegviaend.endlgd    ,
         endnum        like datmsegviaend.endnum    ,
         endcep        like datmsegviaend.endcep    ,
         endcepcmp     like datmsegviaend.endcepcmp ,
         endcid        like datmsegviaend.endcid    ,
         endufd        like datmsegviaend.endufd    ,
         tipo          smallint
 end record

 let msg_erro = " "

 while l_par_cons.tipo <= 8
       let l_par_cons.tipo = l_par_cons.tipo + 1

       case l_par_cons.tipo
            when 1
                if l_par_cons.segnumdig is null or
                   l_par_cons.segnumdig = " " then
                   let msg_erro = "Parametro segurado Nulo "
                end if
            when 2
                if l_par_cons.endlgdtip is null or
                   l_par_cons.endlgdtip = " " then
                   let msg_erro = "Parametro Tipo Logrdouro Nulo "
                end if
            when 3
                if l_par_cons.endlgd is null or
                   l_par_cons.endlgd = " " then
                   let msg_erro = "Parametro Logradouro Nulo "
                end if
            when 4
                if l_par_cons.endnum is null or
                   l_par_cons.endnum = " " then
                   let msg_erro = "Parametro Numero do Logradouro Nulo "
                end if
            when 5
                if l_par_cons.endcep is null or
                   l_par_cons.endcep = " " then
                   let msg_erro = "Parametro CEP Nulo "
                end if
            when 6
                if l_par_cons.endcepcmp is null or
                   l_par_cons.endcepcmp = " " then
                   let msg_erro = "Parametro Compl. CEP Nulo "
                end if
            when 7
                if l_par_cons.endcid is null or
                   l_par_cons.endcid = " " then
                   let msg_erro = "Parametro Cidade Nulo "
                end if
            when 8
                if l_par_cons.endufd is null or
                   l_par_cons.endufd = " " then
                   let msg_erro = "Parametro Estado Nulo "
                end if
            otherwise
                   let msg_erro = " "
                   let l_par_cons.tipo = 9
       end case

     if msg_erro <> " " then
        exit while
     end if
 end while

return msg_erro

end function

#---------------------------------------------------------------------------
function ctx19g00_cons_sem_doc(l_par_cons) ## Consistir parametros sem documento
#---------------------------------------------------------------------------
## Teste do Marcio deLima 18/09/2008
## <?xml version='1.0' encoding='ISO-8859-1'?><mq><servico>REGISTRARLIGACAOCENTRAL24H</servico><param>18/09/2008</param><param>14:48:45</param><param>14:48:45</param><param>1</param><param>Prest Serv Infor - A</param><param>N00</param><param>605446</param><param>0</param><param>788</param><param>1</param><param>531</param><param>139101280</param><param>19</param><param>2</param><param></param><param></param><param></param><param></param><param></param><param>605446</param><param></param><param></param><param></param><param></param><param></param><param>531</param><param></param><param></param><param></param><param></param><param>15132101</param><param>701005</param><param>8</param><param></param><param></param><param></param><param></param><param></param><param></param><param></param><param></param><param></param><param></param></mq>
 define l_par_cons record
        aplnumdig      like datrligapol.aplnumdig   ,
        prpnumdig      like datrligprp.prpnumdig    ,
        corsus         like datrligcor.corsus       ,
        dddcod         like datrligtel.dddcod       ,
        ctttel         like datrligtel.teltxt       ,
        funmat         like datrligmat.funmat       ,
        empcod         like datrligmat.empcod       ,
        usrtip         like datrligmat.usrtip       ,
        cgccpfnum      like datrligcgccpf.cgccpfnum ,
        cgcord         like datrligcgccpf.cgcord    ,
        cgccpfdig      like datrligcgccpf.cgccpfdig
 end record

 define msg_erro     char(80)
 define l_erro       smallint
 define l_param      char(80)
 define l_contem     char(80)
 define l_erro_param smallint
 define ind          smallint

 initialize msg_erro     to null
 initialize l_param      to null
 initialize l_contem     to null
 initialize l_erro_param to null
 initialize ind          to null
 initialize l_erro       to null

 let msg_erro     = " "
 let l_param      = " "
 let l_erro_param = true


 while l_erro_param
    ## consiste se parametros de apolice e proposta foram passados
    ## somente podera ser passado Apolice ou Proposta
    ## se um desses parametros forem passados, os demais deverao serem nulos.

    if l_par_cons.aplnumdig is not null and
       l_par_cons.prpnumdig is not null then
       let msg_erro = "0-Parametros Apolice e proposta Invalidos"
       exit while
    end if

    let l_erro = 0
    if l_par_cons.corsus     is not null then
       let l_param = l_param clipped ,"1-SUSEP"
       let l_erro = l_erro + 1
    end if
    if l_par_cons.dddcod    is not null or
       l_par_cons.ctttel    is not null then
       let l_param = l_param clipped ,",2-TELEFONE "
       let l_erro = l_erro + 1
    end if
    if l_par_cons.funmat     is not null then
       let l_param = l_param clipped , ",3-MATRICULA"
       let l_erro = l_erro + 1
    end if
   #if l_par_cons.empcod     is not null then
   #   let l_param = l_param clipped , ",4-EMPRESA"
   #   let l_erro = l_erro + 1
   #end if
   #if l_par_cons.usrtip    is not null then
   #   let l_param = l_param clipped , ",5-TIPO USUARIO"
   #   let l_erro = l_erro + 1
   #end if
    if l_par_cons.cgccpfnum is not null then
       let l_param = l_param clipped , ",6-CPF/CGC"
       let l_erro = l_erro + 1
    end if

    if l_par_cons.aplnumdig is not null and ## or
       l_par_cons.prpnumdig is not null then
       if l_erro > 0 then
          let msg_erro="0-Parametros Invalidos para Ligacao para Sem documento"
          let msg_erro = msg_erro clipped," ",l_param
          exit while
       end if
    else
       if l_erro > 1 then
          let msg_erro="0-Parametros Invalidos para Ligacao para Sem documento"
          let msg_erro = msg_erro clipped," ",l_param
          exit while
       end if
    end if
    if l_par_cons.aplnumdig is null and
       l_par_cons.prpnumdig is null and
       l_erro               =  0    then
       let msg_erro="0-Parametros Invalidos (nulos)"
       let msg_erro = msg_erro clipped," ",l_param
    end if
    exit while
 end while
 return msg_erro

end function

#---------------------------------------------------------------------------
function ctx19g00_consiste(l_par_cons) ## Consistir parametros obrigat�rios
#---------------------------------------------------------------------------

 define msg_erro  char(80)

 define l_par_cons record
        c24soltipcod     like datksoltip.c24soltipcod ,
        c24solnom        like datmligacao.c24solnom   ,
        c24astcod        like datmligacao.c24astcod   ,
        c24funmat        like datmligacao.c24funmat   ,
        succod           like datrligapol.succod      ,
        ramcod           like datrligapol.ramcod      ,
        aplnumdig        like datrligapol.aplnumdig   ,
        itmnumdig        like datrligapol.itmnumdig   ,
        edsnumref        like datrligapol.edsnumref   ,
        prpnumdig        like datrligprp.prpnumdig    ,
        sinramcod        like datrligsin.ramcod       ,
        sinano           like datrligsin.sinano       ,
        sinnum           like datrligsin.sinnum       ,
        sinitmseq        like datrligsin.sinitmseq    ,
        vstagnnum        like datrligagn.vstagnnum    ,
        tipo             smallint
 end record

 let msg_erro = " "

 while l_par_cons.tipo <= 10
       let l_par_cons.tipo = l_par_cons.tipo + 1

       case l_par_cons.tipo
            when 1
             ## consiste se parametros de apolice e proposta foram passados
             ## somente podera ser passado Apolice ou Proposta
             ## se um desses parametros forem passados,os demais
             ## deverao serem nulos.
                if l_par_cons.aplnumdig is not null and
                   l_par_cons.prpnumdig is not null then
                   let msg_erro = "Parametros Apolice e proposta Invalidos"
                end if
            when 2
                if l_par_cons.c24soltipcod is null or
                   l_par_cons.c24soltipcod = " " then
                   let msg_erro = "Parametro Tipo Solicitante Nulo "
                end if
            when 3
                if l_par_cons.c24solnom is null or
                   l_par_cons.c24solnom = " " then
                   let msg_erro = "Parametro Nome Solicitante Nulo "
                end if
            when 4
                if l_par_cons.c24astcod is null or
                   l_par_cons.c24astcod = " " then
                   let msg_erro = "Parametro Assunto Nulo "
                end if
            when 5
                if l_par_cons.c24funmat is null or
                   l_par_cons.c24funmat = " " then
                   let msg_erro = "Parametro Matricula Nulo "
                end if
            when 6
                if l_par_cons.aplnumdig is not null and
                   (l_par_cons.succod is null or
                    l_par_cons.succod = " " ) then
                   let msg_erro = "Parametro Sucursal Nulo "
                end if
            when 7
                if l_par_cons.aplnumdig is not null and
                   (l_par_cons.ramcod is null or
                    l_par_cons.ramcod = " ")  then
                   let msg_erro = "Parametro Ramo Nulo "
                end if
            when 8
                if l_par_cons.aplnumdig is not null and
                   (l_par_cons.itmnumdig is null or
                    l_par_cons.itmnumdig = " ")  then
                   let msg_erro = "Parametro Item Nulo "
                end if
            when 9
                if l_par_cons.c24astcod = "U10" then
                   if l_par_cons.sinramcod is null or
                      l_par_cons.sinano    is null or
                      l_par_cons.sinnum    is null or
                      l_par_cons.sinitmseq is null then
                      let msg_erro = "PARAMETRO PROCESSO SINISTRO NULOS "
                   end if
                end if
            when 10
                if l_par_cons.c24astcod = "D15" or
                   l_par_cons.c24astcod = "D18" or
                   l_par_cons.c24astcod = "D68" or
                   l_par_cons.c24astcod = "D00" or
                   l_par_cons.c24astcod = "D10" or
                   l_par_cons.c24astcod = "D11" or
                   l_par_cons.c24astcod = "D12" then

                   if l_par_cons.vstagnnum is null then
                      let msg_erro = "PARAMETRO NUMERO AGENDAMENTO NULO "
                   end if
                end if
            otherwise
                let msg_erro = " "
                let l_par_cons.tipo = 11
       end case
       if msg_erro <> " " then
          exit while
       end if
 end while
 return msg_erro

end function

#---------------------------------------------------------------------------
function ctx19g00_gera_atd()
#---------------------------------------------------------------------------

   define lr_param              record
          ciaempcod             like datmatd6523.ciaempcod
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
         ,ligcvntip             like datmatd6523.ligcvntip
   end record


   define l_trans  char(1)
   define l_msg    char(500)



   define lr_retorno record
          atdnum like datmatd6523.atdnum,
          sqlcod smallint,
          msg    char(100)
   end record



   initialize lr_param.* to null
   initialize lr_retorno.* to null

   let lr_param.ciaempcod          = g_paramval[1]
   let lr_param.solnom             = g_paramval[2]
   let lr_param.flgavstransp       = g_paramval[3]
   let lr_param.c24soltipcod       = g_paramval[4]
   let lr_param.ramcod             = g_paramval[5]
   let lr_param.flgcar             = g_paramval[6]
   let lr_param.vcllicnum          = g_paramval[7]
   let lr_param.corsus             = g_paramval[8]
   let lr_param.succod             = g_paramval[9]
   let lr_param.aplnumdig          = g_paramval[10]
   let lr_param.itmnumdig          = g_paramval[11]
   let lr_param.etpctrnum          = g_paramval[12]
   let lr_param.segnom             = g_paramval[13]
   let lr_param.pestip             = g_paramval[14]
   let lr_param.cgccpfnum          = g_paramval[15]
   let lr_param.cgcord             = g_paramval[16]
   let lr_param.cgccpfdig          = g_paramval[17]
   let lr_param.prporg             = g_paramval[18]
   let lr_param.prpnumdig          = g_paramval[19]
   let lr_param.flgvp              = g_paramval[20]
   let lr_param.vstnumdig          = g_paramval[21]
   let lr_param.vstdnumdig         = g_paramval[22]
   let lr_param.flgvd              = g_paramval[23]
   let lr_param.flgcp              = g_paramval[24]
   let lr_param.cpbnum             = g_paramval[25]
   let lr_param.semdcto            = g_paramval[26]
   let lr_param.ies_ppt            = g_paramval[27]
   let lr_param.ies_pss            = g_paramval[28]
   let lr_param.transp             = g_paramval[29]
   let lr_param.trpavbnum          = g_paramval[30]
   let lr_param.vclchsfnl          = g_paramval[31]
   let lr_param.sinramcod          = g_paramval[32]
   let lr_param.sinnum             = g_paramval[33]
   let lr_param.sinano             = g_paramval[34]
   let lr_param.sinvstnum          = g_paramval[35]
   let lr_param.sinvstano          = g_paramval[36]
   let lr_param.flgauto            = g_paramval[37]
   let lr_param.sinautnum          = g_paramval[38]
   let lr_param.sinautano          = g_paramval[39]
   let lr_param.flgre              = g_paramval[40]
   let lr_param.sinrenum           = g_paramval[41]
   let lr_param.sinreano           = g_paramval[42]
   let lr_param.flgavs             = g_paramval[43]
   let lr_param.sinavsnum          = g_paramval[44]
   let lr_param.sinavsano          = g_paramval[45]
   let lr_param.semdoctoempcodatd  = g_paramval[46]
   let lr_param.semdoctopestip     = g_paramval[47]
   let lr_param.semdoctocgccpfnum  = g_paramval[48]
   let lr_param.semdoctocgcord     = g_paramval[49]
   let lr_param.semdoctocgccpfdig  = g_paramval[50]
   let lr_param.semdoctocorsus     = g_paramval[51]
   let lr_param.semdoctofunmat     = g_paramval[52]
   let lr_param.semdoctoempcod     = g_paramval[53]
   let lr_param.semdoctodddcod     = g_paramval[54]
   let lr_param.semdoctoctttel     = g_paramval[55]
   let lr_param.funmat             = g_paramval[56]
   let lr_param.empcod             = g_paramval[57]
   let lr_param.usrtip             = g_paramval[58]
   let lr_param.ligcvntip          = g_paramval[59]
   let l_trans                     = g_paramval[60]

   call ctx19g00_consiste_parametros(lr_param.*)
       returning l_msg

   if l_msg is null or
      l_msg = " " then
        if l_trans = "S" then
             begin work
             call ctd24g00_ins_atd(0,lr_param.*)
               returning lr_retorno.atdnum,
                         lr_retorno.sqlcod,
                         lr_retorno.msg

             if lr_retorno.sqlcod <> 0 then
                rollback work
                display lr_retorno.msg
                return ctx19g00_atdnum_xml_erro(lr_retorno.sqlcod,lr_retorno.msg)
             else
               commit work
             end if
        else
           call ctd24g00_ins_atd(0,lr_param.*)
                  returning lr_retorno.atdnum,
                            lr_retorno.sqlcod,
                            lr_retorno.msg

                if lr_retorno.sqlcod <> 0 then
                   display lr_retorno.msg
                   return ctx19g00_atdnum_xml_erro(lr_retorno.sqlcod,lr_retorno.msg)
                end if
        end if
   else
      return ctx19g00_atdnum_xml_erro(999,l_msg)
   end if

  return ctx19g00_retorno_gera_atd(lr_retorno.*)


end function

#---------------------------------------------------------------------------
function ctx19g00_consiste_parametros(lr_param)
#---------------------------------------------------------------------------

 define l_erro smallint
 define l_msg char(300)



 define lr_param              record
          ciaempcod             like datmatd6523.ciaempcod
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
         ,ligcvntip             like datmatd6523.ligcvntip
   end record

 let l_msg = " "
 let l_erro = false


 if lr_param.semdcto = "N" or
    lr_param.semdcto is null then

        if lr_param.aplnumdig is not null and
           lr_param.prpnumdig is not null then
           let l_msg = "Parametros Apolice e proposta Invalidos"
           return l_msg
        end if

        if lr_param.aplnumdig is null and
           lr_param.prpnumdig is null then
           let l_msg = "Parametro Apolice e proposta Nulo "
           return l_msg
        end if

        if lr_param.aplnumdig is not null and
           (lr_param.succod is null or
            lr_param.succod = " " ) then
           let l_msg = "Parametro Sucursal Nulo "
           return l_msg
        end if

        if  lr_param.aplnumdig is not null and
           (lr_param.ramcod is null or
            lr_param.ramcod = " ")  then
           let l_msg = "Parametro Ramo Nulo "
           return l_msg
        end if

        if lr_param.prpnumdig is not null and
           (lr_param.prporg is null or
            lr_param.prporg = " ")  then
           let l_msg = "Parametro origem da proposta Nulo "
           return l_msg
        end if

        if  lr_param.prpnumdig is not null and
           (lr_param.prpnumdig = 0 or
            lr_param.prporg = 0)  then
           let l_msg = "Parametro Proposta est� com 0 "
           return l_msg
        end if
 else

    call ctx19g00_cons_sem_doc(lr_param.aplnumdig
                              ,lr_param.prpnumdig
                              ,lr_param.semdoctocorsus
                              ,lr_param.semdoctodddcod
                              ,lr_param.semdoctoctttel
                              ,lr_param.semdoctofunmat
                              ,lr_param.semdoctoempcod
                              ," "
                              ,lr_param.semdoctocgccpfnum
                              ,lr_param.semdoctocgcord
                              ,lr_param.semdoctocgccpfdig
                               )
    returning l_msg

 end if

 return l_msg

end function

function ctx19g00_atdnum_xml_erro(l_param)

  define l_param record
         erro smallint,
         mensagem  char(80)
  end record

  define l_xmlRetorno char(5000)

  let l_xmlRetorno = "<?xml version='1.0' encoding='ISO-8859-1'?><IFX>",
                     "<mq>" , "<cod_erro>" clipped, l_param.erro clipped,"  </cod_erro>" clipped,
                     "<erro>" clipped, l_param.mensagem clipped,"  </erro>" clipped,
                     "</mq>","</IFX>"
  return l_xmlRetorno

end function

#---------------------------------------------------------------------------
function ctx19g00_retorno_gera_atd(l_param)
#---------------------------------------------------------------------------
  define l_param record
         atdnum    like datmatd6523.atdnum,
         erro      smallint,
         msg       char(80)
  end record

  define l_xmlretorno char(5000)

  let l_xmlretorno = null

  let l_xmlretorno = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><IFX>",
                     "<codigoErro>"  ,l_param.erro clipped ,"</codigoErro>",
                     "<mensagemErro>",l_param.msg clipped ,"</mensagemErro>",
                     "<atdnum>"      ,l_param.atdnum clipped,"</atdnum>",
                     "</IFX>"

 return l_xmlretorno

end function

#---------------------------------------------------------------------------
function ctx19g00_rec_historico_lig()
#---------------------------------------------------------------------------
   define l_atdnum like datmatd6523.atdnum
   define l_lignum like datmligacao.lignum

   define lr_retorno record
        lignum            like datmlighist.lignum,
        c24txtseq         like datmlighist.c24txtseq,
        c24ligdsc         like datmlighist.c24ligdsc
   end record

   define l_xml char(32000)

   initialize lr_retorno.* to null

   let l_atdnum = g_paramval[1]

   display "l_atdnum = ",l_atdnum

  let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>",
               "<RESPONSE>"

   open cctx19g00008 using l_atdnum
   foreach cctx19g00008 into l_lignum

       display "l_lignum = ",l_lignum

       open cctx19g00009 using l_lignum
       whenever error continue
       foreach cctx19g00009 into lr_retorno.lignum,
                                 lr_retorno.c24txtseq,
                                 lr_retorno.c24ligdsc

       let l_xml = l_xml clipped,
                       "<LIGACAO>",
                       "<lignum>",     lr_retorno.lignum    clipped ,"</lignum>",
                       "<c24txtseq>",  lr_retorno.c24txtseq clipped ,"</c24txtseq>",
                       "<c24ligdsc>" , lr_retorno.c24ligdsc clipped ,"</c24ligdsc>",
                       "</LIGACAO>"
       end foreach
   whenever error stop
   end foreach
   let l_xml = l_xml clipped,
                    "</RESPONSE>"
   if sqlca.sqlcode <> 0 then
      display "erro ao localizar a liga��o "
   end if
   close cctx19g00008

   return l_xml

end function

function ctx19g00_rec_ligacoes()
     define lr_param              record
          ciaempcod             like datmatd6523.ciaempcod
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
         ,ligcvntip             like datmatd6523.ligcvntip
   end record

  define lr_lig record
         lignum    like datmligacao.lignum,
         c24astcod like datmligacao.c24astcod,
         ligdat    like datmligacao.ligdat,
         lighorinc like datmligacao.lighorinc
  end record


  define lr_ret record
         lignum     like datmligacao.lignum,
         c24astcod  like datmligacao.c24astcod,
         c24astdes  like datkassunto.c24astdes,
         ligdat     like datmligacao.ligdat,
         lighorinc  like datmligacao.lighorinc
  end record


  define l_xml         char(32000),
         l_sql_comando char(1000),
         l_cornom      char(40),
         l_funnom      char(20),
         l_lignum      like datmligacao.lignum,
         l_c24astdes   like datkassunto.c24astdes,
         l_qtd         integer,
         l_sql         char(200)


   initialize lr_param.* to null
   initialize lr_lig.* to null
   let l_sql_comando = null
   let l_cornom = null
   let l_funnom = null
   let l_lignum = null
   let l_c24astdes = null
   let l_qtd = 0




   let l_sql_comando = ' select a.cornom '
              ,' from gcakcorr a, gcaksusep b '
             ,' where b.corsus = ? '
               ,' and a.corsuspcp = b.corsuspcp '
   prepare pctx19g00030 from l_sql_comando
   declare cctx19g00030 cursor for pctx19g00030

   let l_sql_comando = " select funnom "
                ," from isskfunc "
               ," where funmat = ? "
                 ," and empcod = ? "
                 ," and usrtip = 'F' "
   prepare pctx19g00031 from l_sql_comando
   declare cctx19g00031 cursor for pctx19g00031

   let l_sql_comando = " select c24usrtip, ",
                      " c24empcod ",
                 " from datmligacao ",
                " where lignum = ? "

   prepare pctx19g00032 from l_sql_comando
   declare cctx19g00032 cursor for pctx19g00032

   let lr_param.ciaempcod          = g_paramval[1]
   let lr_param.solnom             = g_paramval[2]
   let lr_param.flgavstransp       = g_paramval[3]
   let lr_param.c24soltipcod       = g_paramval[4]
   let lr_param.ramcod             = g_paramval[5]
   let lr_param.flgcar             = g_paramval[6]
   let lr_param.vcllicnum          = g_paramval[7]
   let lr_param.corsus             = g_paramval[8]
   let lr_param.succod             = g_paramval[9]
   let lr_param.aplnumdig          = g_paramval[10]
   let lr_param.itmnumdig          = g_paramval[11]
   let lr_param.etpctrnum          = g_paramval[12]
   let lr_param.segnom             = g_paramval[13]
   let lr_param.pestip             = g_paramval[14]
   let lr_param.cgccpfnum          = g_paramval[15]
   let lr_param.cgcord             = g_paramval[16]
   let lr_param.cgccpfdig          = g_paramval[17]
   let lr_param.prporg             = g_paramval[18]
   let lr_param.prpnumdig          = g_paramval[19]
   let lr_param.flgvp              = g_paramval[20]
   let lr_param.vstnumdig          = g_paramval[21]
   let lr_param.vstdnumdig         = g_paramval[22]
   let lr_param.flgvd              = g_paramval[23]
   let lr_param.flgcp              = g_paramval[24]
   let lr_param.cpbnum             = g_paramval[25]
   let lr_param.semdcto            = g_paramval[26]
   let lr_param.ies_ppt            = g_paramval[27]
   let lr_param.ies_pss            = g_paramval[28]
   let lr_param.transp             = g_paramval[29]
   let lr_param.trpavbnum          = g_paramval[30]
   let lr_param.vclchsfnl          = g_paramval[31]
   let lr_param.sinramcod          = g_paramval[32]
   let lr_param.sinnum             = g_paramval[33]
   let lr_param.sinano             = g_paramval[34]
   let lr_param.sinvstnum          = g_paramval[35]
   let lr_param.sinvstano          = g_paramval[36]
   let lr_param.flgauto            = g_paramval[37]
   let lr_param.sinautnum          = g_paramval[38]
   let lr_param.sinautano          = g_paramval[39]
   let lr_param.flgre              = g_paramval[40]
   let lr_param.sinrenum           = g_paramval[41]
   let lr_param.sinreano           = g_paramval[42]
   let lr_param.flgavs             = g_paramval[43]
   let lr_param.sinavsnum          = g_paramval[44]
   let lr_param.sinavsano          = g_paramval[45]
   let lr_param.semdoctoempcodatd  = g_paramval[46]
   let lr_param.semdoctopestip     = g_paramval[47]
   let lr_param.semdoctocgccpfnum  = g_paramval[48]
   let lr_param.semdoctocgcord     = g_paramval[49]
   let lr_param.semdoctocgccpfdig  = g_paramval[50]
   let lr_param.semdoctocorsus     = g_paramval[51]
   let lr_param.semdoctofunmat     = g_paramval[52]
   let lr_param.semdoctoempcod     = g_paramval[53]
   let lr_param.semdoctodddcod     = g_paramval[54]
   let lr_param.semdoctoctttel     = g_paramval[55]
   let lr_param.funmat             = g_paramval[56]
   let lr_param.empcod             = g_paramval[57]
   let lr_param.usrtip             = g_paramval[58]
   let lr_param.ligcvntip          = g_paramval[59]


   whenever error continue
      create temp table ctx19g00_tmp_ligacao
         (lignum      dec(10,0),
          c24astcod   char(4)  ,
          c24astdes   char(40) ,
          ligdat      date     ,
          lighorinc   datetime hour to minute)  with no log
   whenever error stop
   if sqlca.sqlcode  = 0 then
      create unique index tmp_ind2 on ctx19g00_tmp_ligacao
              (lignum,ligdat,lighorinc)
   end if
   if sqlca.sqlcode   != 0 then
      if sqlca.sqlcode = -310 or
         sqlca.sqlcode = -958 then  # tabela ja existe
         delete from ctx19g00_tmp_ligacao
      end if
   end if


   let l_sql = " select lignum , c24astcod, c24astdes "
           , "      , ligdat , lighorinc "
           , " from ctx19g00_tmp_ligacao  "
           , " order by ligdat desc,lighorinc desc "


   prepare pctx19g00012 from l_sql
   declare cctx19g00012 cursor for pctx19g00012


   # Preparando os comandos
   while true

             # Bloco 1

             if lr_param.succod    is not null  and
                lr_param.ramcod    is not null  and
                lr_param.aplnumdig is not null  then

                let l_sql_comando = " select lignum ",
                                      " from datrligapol ",
                                     " where succod    = ? ",
                                       " and ramcod    = ? ",
                                       " and aplnumdig = ? ",
                                       " and itmnumdig = ? ",
                                     " order by lignum "
                display "PREP = ENTREI BLOCO 1"
                exit while

             end if

             # Bloco 2

             if lr_param.ciaempcod = 43 then # PSI 247936 Empresas 27

                let l_sql_comando = "select lignum              ",
                                    "  from datrcntlig          ",
                                    " where psscntcod = ?       ",
                                    " order by lignum desc      "
                 display "PREP = ENTREI BLOCO 2"
                exit while

             end if

             # Bloco 3

             if lr_param.prporg is not null and
                lr_param.prpnumdig is not null then
                #let l_cabec = "Proposta: ", lr_param.prporg    using "&&", " ",
                 #                           lr_param.prpnumdig using "<<<<<<<<&"
                let l_sql_comando = " select lignum "
                                     ," from datrligprp "
                                    ," where prporg    = ? "
                                      ," and prpnumdig = ? "
                                    ," order by lignum "
                display "PREP = ENTREI BLOCO 3"
                exit while

             end if

             # Bloco 4

             if lr_param.semdoctocorsus is not null then
                open cctx19g00030 using lr_param.semdoctocorsus
                whenever error continue
                   fetch cctx19g00030 into l_cornom
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                      let l_cornom = "Corretor nao cadastrado na Porto "
                   else
                      error "ERRO SELECT GCAKCORR. ", sqlca.sqlcode, ' - ',sqlca.sqlerrd[2] sleep 2
                      error "ctx19g00_prepare() / ", lr_param.semdoctocorsus sleep 2
                      return false
                   end if
                end if
                #let l_cabec = "SUSEP.: ",lr_param.corsus," ",l_cornom
                let l_sql_comando = " select lignum "
                                     ," from datrligcor "
                                    ," where corsus = ? "
                display "PREP = ENTREI BLOCO 4"
                exit while

             end if

             # Bloco 5

             if lr_param.semdoctocgccpfnum is not null then
                {let l_cabec = 'CGC/CPF.: ',lr_param.cgccpfnum,
                                       ' ',lr_param.cgcord,
                                       ' ',lr_param.cgccpfdig}

                let l_sql_comando = 'select a.lignum        ',
                                    '  from datrligcgccpf a,',
                                    '       datmligacao b   ',
                                    ' where a.lignum = b.lignum ',
                                    '   and a.cgccpfnum = ? ',
                                    '   and a.cgcord    = ? ',
                                    '   and a.cgccpfdig = ? ',
                                    '   and b.ciaempcod = ', lr_param.ciaempcod ,
                                    ' order by a.lignum desc '
                display "PREP = ENTREI BLOCO 5"
                exit while

             end if

             # Bloco 6

             if lr_param.semdoctofunmat is not null then
                open cctx19g00031 using lr_param.semdoctofunmat, lr_param.semdoctoempcodatd
                whenever error continue
                fetch cctx19g00031 into l_funnom
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                      let l_funnom = "Funcionario nao cadastrado "
                   else
                      error "ERRO SELECT DATRLIGCGCCPF. ", sqlca.sqlcode, ' - ',sqlca.sqlerrd[2] sleep 2
                      error "ctx19g00_prepare() / ", lr_param.semdoctofunmat sleep 2
                      return false
                   end if
                end if
                #let l_cabec = "FUNCION.: ",lr_param.funmat," ",l_funnom
                let l_sql_comando = " select lignum ",
                                      " from datrligmat ",
                                     " where funmat = ? "
                display "PREP = ENTREI BLOCO 6"
                exit while

             end if

             # Bloco 7
             if lr_param.semdoctoctttel is not null then
               #  let l_cabec = 'TELEFONE.: ',lr_param.ctttel
               let l_sql_comando = " select lignum "
                                  ," from datrligtel "
                                 ," where teltxt = ? "

               exit while
             end if

         exit while

    end while

    prepare pctx19g00034 from l_sql_comando
    declare cctx19g00034 cursor for pctx19g00034



    while true


         # Bloco 1

         if lr_param.succod is not null  and
            lr_param.ramcod is not null  and
            lr_param.aplnumdig is not null then

               open cctx19g00034 using lr_param.succod   ,
                                     lr_param.ramcod   ,
                                     lr_param.aplnumdig,
                                     lr_param.itmnumdig

               exit while
         end if



         # Bloco 2

         if lr_param.ciaempcod = 43 then # PSI 247936 Empresas 27
            open cctx19g00034 using g_pss.psscntcod

            exit while

         end if

         # Bloco 3

         if lr_param.prporg    is not null  and
            lr_param.prpnumdig is not null  then
            open cctx19g00034 using lr_param.prporg,
                                    lr_param.prpnumdig

            exit while

         end if

         # Bloco 4

         if lr_param.semdoctocorsus is not null then
            open cctx19g00034 using lr_param.semdoctocorsus

            exit while

         end if

         # Bloco 5


         if lr_param.semdoctocgccpfnum is not null then
            open cctx19g00034 using lr_param.semdoctocgccpfnum,
                                    lr_param.semdoctocgcord,
                                    lr_param.semdoctocgccpfdig

            exit while

         end if

         # Bloco 6

         if lr_param.semdoctofunmat is not null then
            open cctx19g00034 using lr_param.semdoctofunmat

            exit while

         end if

         if lr_param.semdoctoctttel is not null then
            open cctx19g00034 using lr_param.semdoctoctttel

            exit while
         end if



         exit while

  end while


 foreach cctx19g00034 into l_lignum

   open cctx19g00010 using l_lignum
   whenever error continue
   foreach cctx19g00010 into lr_lig.*

     whenever error continue
     open cctx19g00011 using lr_lig.c24astcod
     fetch cctx19g00011 into l_c24astdes
     whenever error stop

       insert into ctx19g00_tmp_ligacao values (lr_lig.lignum
                                               ,lr_lig.c24astcod
                                               ,l_c24astdes
                                               ,lr_lig.ligdat
                                               ,lr_lig.lighorinc)

   end foreach
 end foreach
 whenever error stop

 if sqlca.sqlcode <> 0 then
    display "Erro < ",sqlca.sqlcode ," > ao localizar as Liga��es "
 end if
 close cctx19g00034


 let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>",
             "<RESPONSE>"

 open cctx19g00012
 foreach cctx19g00012 into lr_ret.*

        let l_qtd = l_qtd + 1

        # Limitando a 25 ligacoes
        if l_qtd <= 25 then
            let l_xml = l_xml clipped,
                               "<LIGACAO>"   ,
                               "<lignum>"    , lr_ret.lignum    clipped ,"</lignum>",
                               "<c24astcod>" , lr_ret.c24astcod clipped ,"</c24astcod>",
                               "<c24astdes>" , lr_ret.c24astdes clipped ,"</c24astdes>",
                               "<ligdat>"    , lr_ret.ligdat    clipped ,"</ligdat>",
                               "<lighorinc>" , lr_ret.lighorinc clipped ,"</lighorinc>",
                               "</LIGACAO>"
        else
          exit foreach
        end if
 end foreach


 let l_xml = l_xml clipped,
                  "</RESPONSE>"

 close cctx19g00012

 return l_xml

end function

function ctx19g00_reg_transf()

   define l_erro integer
   define l_msg  char(200)
   define l_xml  char(32000)

   define lr_param     record
          atdnum       like datmatdtrn.atdnum,
          trnlignum    like datmatdtrn.trnlignum,
          necgerlignum like datmatdtrn.necgerlignum,
          atdpripanum  like datmatdtrn.atdpripanum,
          atdpridptsgl like datmatdtrn.atdpridptsgl,
          atdprifunmat like datmatdtrn.atdprifunmat,
          atdpriusrtip like datmatdtrn.atdpriusrtip,
          atdpriempcod like datmatdtrn.atdpriempcod
   end record

   initialize lr_param.* to null
   let l_msg  = null
   let l_erro = null
   let l_msg  = null


   let lr_param.atdnum             = g_paramval[1]
   let lr_param.trnlignum          = g_paramval[2]
   let lr_param.necgerlignum       = g_paramval[3]
   let lr_param.atdpripanum        = g_paramval[4]
   let lr_param.atdpridptsgl       = g_paramval[5]
   let lr_param.atdprifunmat       = g_paramval[6]
   let lr_param.atdpriusrtip       = g_paramval[7]
   let lr_param.atdpriempcod       = g_paramval[8]


   display "<lr_param.atdnum>       = ",lr_param.atdnum
   display "<lr_param.trnlignum>    = ",lr_param.trnlignum
   display "<lr_param.necgerlignum> = ",lr_param.necgerlignum
   display "<lr_param.atdpripanum>  = ",lr_param.atdpripanum
   display "<lr_param.atdpridptsgl> = ",lr_param.atdpridptsgl
   display "<lr_param.atdprifunmat> = ",lr_param.atdprifunmat
   display "<lr_param.atdpriusrtip> = ",lr_param.atdpriusrtip
   display "<lr_param.atdpriempcod> = ",lr_param.atdpriempcod


   call ctd26g00_insere_tranferencia(lr_param.*)
        returning l_erro,l_msg


   if l_erro = 1 then
          return ctx19g00_atdnum_xml_erro(l_erro,l_msg)
   end if

   let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                  ,"<servicos>OK</servicos>"

   return l_xml

end function

function ctx19g00_rec_trn()

  define l_atdnum like datmatd6523.atdnum

  define lr_param record
         atdsegpanum  like datmatdtrn.atdsegpanum,
         atdsegdptsgl like datmatdtrn.atdsegdptsgl,
         atdsegfunmat like datmatdtrn.atdsegfunmat,
         atdsegusrtip like datmatdtrn.atdsegusrtip,
         atdsegempcod like datmatdtrn.atdsegempcod
  end record


  define lr_ret record
       ramcod      like datmatd6523.ramcod,
       succod      like datmatd6523.succod,
       aplnumdig   like datmatd6523.aplnumdig,
       itmnumdig   like datmatd6523.itmnumdig,
       prporg      like datmatd6523.prporg,
       prpnumdig   like datmatd6523.prpnumdig,
       cgccpfnum   like datmatd6523.semdoctocgccpfnum,
       cgcord      like datmatd6523.semdoctocgcord,
       cgccpfdig   like datmatd6523.semdoctocgccpfdig
  end record

   define lr_trn     record
          atdnum       like datmatdtrn.atdnum,
          atdtrnnum    like datmatdtrn.atdtrnnum,
          trnlignum    like datmatdtrn.trnlignum,
          necgerlignum like datmatdtrn.necgerlignum,
          atdpripanum  like datmatdtrn.atdpripanum,
          atdpridptsgl like datmatdtrn.atdpridptsgl,
          atdprifunmat like datmatdtrn.atdprifunmat,
          atdpriusrtip like datmatdtrn.atdpriusrtip,
          atdpriempcod like datmatdtrn.atdpriempcod
   end record

   define lr_histb16 record
        lignum            like datmlighist.lignum,
        c24txtseq         like datmlighist.c24txtseq,
        c24ligdsc         like datmlighist.c24ligdsc
   end record

   define lr_histtrn record
        lignum            like datmlighist.lignum,
        c24txtseq         like datmlighist.c24txtseq,
        c24ligdsc         like datmlighist.c24ligdsc
   end record



   define l_erro integer
   define l_msg  char(100)
   define l_xml  char(32000)
   define l_exist  smallint




  initialize lr_trn.* to null
  initialize lr_ret.* to null
  initialize lr_param.* to null
  let l_erro   = 0
  let l_msg    = null
  let l_atdnum = null
  let l_xml    = null
  let l_exist = false




  let l_atdnum                = g_paramval[1]
  let lr_param.atdsegpanum    = g_paramval[2]
  let lr_param.atdsegdptsgl   = g_paramval[3]
  let lr_param.atdsegfunmat   = g_paramval[4]
  let lr_param.atdsegusrtip   = g_paramval[5]
  let lr_param.atdsegempcod   = g_paramval[6]

  call ctx19g00_valida_atd_trn(l_atdnum)
    returning lr_trn.*,l_erro,l_msg

  if l_erro <> 0 then
     display l_msg
     return ctx19g00_atdnum_xml_erro(l_erro,l_msg)
  else

        #busca Cliente
        whenever error continue
        open cctx19g00014 using l_atdnum
        fetch cctx19g00014 into lr_ret.*
        whenever error stop

       if sqlca.sqlcode <> 0 then
          let l_erro = sqlca.sqlcode
          display "Erro ao selecionar dados do Cliente < DATMATD6523 > "
       end if

       if l_erro = 0 then
              let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>",
                          "<RESPONSE>",
                          "<ramcod>"    , lr_ret.ramcod      clipped , "</ramcod>",
                          "<succod>"    , lr_ret.succod      clipped , "</succod>",
                          "<aplnumdig>" , lr_ret.aplnumdig   clipped , "</aplnumdig>",
                          "<itmnumdig>" , lr_ret.itmnumdig   clipped , "</itmnumdig>",
                          "<prporg>"    , lr_ret.prporg      clipped , "</prporg>",
                          "<prpnumdig>" , lr_ret.prpnumdig   clipped , "</prpnumdig>",
                          "<cgccpfnum>" , lr_ret.cgccpfnum   clipped , "</cgccpfnum>",
                          "<cgcord>"    , lr_ret.cgcord      clipped , "</cgcord>",
                          "<cgccpfdig>" , lr_ret.cgccpfdig   clipped , "</cgccpfdig>"


           whenever error continue
           let l_exist = false
           open cctx19g00009 using lr_trn.trnlignum
           foreach cctx19g00009 into lr_histb16.*
           whenever error stop
                  let l_exist = true
                  let l_xml = l_xml clipped, "<LIGACAOB16>"   ,
                                             "<lignum>"       , lr_histb16.lignum    clipped ,"</lignum>",
                                             "<c24txtseq>"    , lr_histb16.c24txtseq clipped ,"</c24txtseq>",
                                             "<c24ligdsc>"    , lr_histb16.c24ligdsc clipped ,"</c24ligdsc>",
                                             "</LIGACAOB16>"
           end foreach
             if l_exist = false then
                  let l_xml = l_xml clipped , "<LIGACAOB16>",
                                              "<msg>ligacao sem historico</msg>",
                                              "</LIGACAOB16>"
             else
                if sqlca.sqlcode <> 0 then
                   let l_erro = sqlca.sqlcode
                   let l_msg = " Erro ao selecionar liga��o de B16  < ",l_erro , "> ",lr_trn.trnlignum , " > "
                   display " Erro ao selecionar liga��o de B16  < ",l_erro , "> ",lr_trn.trnlignum , " > "
                end if

             end if

           close cctx19g00009
           if l_erro = 0 then
              if lr_trn.necgerlignum is not null then
                 whenever error continue
                 open cctx19g00009 using lr_trn.necgerlignum
                 let l_exist = false
                 foreach cctx19g00009 into lr_histtrn.*
                       let l_exist = true
                       let l_xml = l_xml clipped ,"<LIGACAOTRN>"   ,
                                                  "<lignum>"       , lr_histtrn.lignum    clipped ,"</lignum>",
                                                  "<c24txtseq>"    , lr_histtrn.c24txtseq clipped ,"</c24txtseq>",
                                                  "<c24ligdsc>"    , lr_histtrn.c24ligdsc clipped ,"</c24ligdsc>",
                                                  "</LIGACAOTRN>"
                 end foreach
                 whenever error stop
                 if l_exist = false then
                    let l_xml = l_xml clipped , "<LIGACAOTRN>",
                                                "<msg>ligacao sem historico</msg>",
                                                "</LIGACAOTRN>"
                 else
                    if sqlca.sqlcode <> 0 then
                       let l_erro = sqlca.sqlcode
                       let l_msg = " Erro ao selecionar liga��o de Transferencia  < ",l_erro, ">" ,lr_trn.necgerlignum , " > "
                       display " Erro ao selecionar liga��o de Transferencia  < ",l_erro, ">" ,lr_trn.necgerlignum , " > "
                    end if

                 end if

                 close  cctx19g00009
              end if
           end if
         let l_xml = l_xml clipped , "</RESPONSE>"

       end if
  end if

  call ctx19g00_altera_trn(lr_param.*,l_atdnum,lr_trn.atdtrnnum)
      returning l_erro,l_msg


  if l_erro <> 0 then
     return ctx19g00_atdnum_xml_erro(l_erro,l_msg)
  end if

  return l_xml

end function

function ctx19g00_valida_atd_trn(lr_atdnum)

   define lr_atdnum like datmatd6523.atdnum

   define lr_param     record
          atdnum       like datmatdtrn.atdnum,
          atdtrnnum    like datmatdtrn.atdtrnnum,
          trnlignum    like datmatdtrn.trnlignum,
          necgerlignum like datmatdtrn.necgerlignum,
          atdpripanum  like datmatdtrn.atdpripanum,
          atdpridptsgl like datmatdtrn.atdpridptsgl,
          atdprifunmat like datmatdtrn.atdprifunmat,
          atdpriusrtip like datmatdtrn.atdpriusrtip,
          atdpriempcod like datmatdtrn.atdpriempcod
   end record

   define l_msg  char(300)
   define l_erro integer



   initialize lr_param.* to null
   let l_msg = null
   let l_erro = null


   whenever error continue
   open cctx19g00013 using lr_atdnum
   fetch cctx19g00013 into lr_param.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = 100 then
        let l_msg = "Atendimento n�o disponivel para transferencia"
        return lr_param.*,sqlca.sqlcode, l_msg
      else
        let l_erro = sqlca.sqlcode
        let l_msg = "Erro < ",l_erro ," > Ao selecionar atendimento."
        return lr_param.*,l_erro, l_msg
      end if
   end if

   return lr_param.*,sqlca.sqlcode, l_msg

end function

function ctx19g00_altera_trn(lr_param)

  define lr_param record
         atdsegpanum  like datmatdtrn.atdsegpanum,
         atdsegdptsgl like datmatdtrn.atdsegdptsgl,
         atdsegfunmat like datmatdtrn.atdsegfunmat,
         atdsegusrtip like datmatdtrn.atdsegusrtip,
         atdsegempcod like datmatdtrn.atdsegempcod,
         atdnum       like datmatdtrn.atdnum,
         atdtrnnum    like datmatdtrn.atdtrnnum
  end record

  define l_trndat                 like datmatdtrn.trndat,
         l_trnhor                 like datmatdtrn.trnhor,
         l_erro                   smallint,
         l_msg                    char(200)




  let l_trndat = null
  let l_trnhor = null
  let l_erro   = null
  let l_msg    = null

  call cts40g03_data_hora_banco(2)
      returning l_trndat, l_trnhor

 whenever error continue
 execute pctx19g00015 using lr_param.atdsegpanum
                           ,lr_param.atdsegdptsgl
                           ,lr_param.atdsegfunmat
                           ,lr_param.atdsegusrtip
                           ,lr_param.atdsegempcod
                           ,l_trndat
                           ,l_trnhor
                           ,lr_param.atdnum
                           ,lr_param.atdtrnnum
 whenever error stop

 if sqlca.sqlcode <> 0 then
    let l_erro = sqlca.sqlcode
    let l_msg = "Erro < ", sqlca.sqlcode , " > ao tentar atualizar a tabela <DATMATDTRN>"
    return l_erro,l_msg
 end if


return l_erro,l_msg

end function
