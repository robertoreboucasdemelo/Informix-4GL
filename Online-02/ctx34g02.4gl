
#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: ctx34g02                                                   #
# ANALISTA RESP..: Beatriz Araujo                                             #
# PSI/OSF........: PSI-2011-0258628/PR                                        #
# DATA...........: 21/07/2011                                                 #
# OBJETIVO.......: Criar uma inferface unica de atualizacao dos serviços na   #
#                  base do Oracle do Novo Acionamento                         #
# Observacoes:                                                                #
# ........................................................................... #
#                        * * * Alteracoes * * *                               #
#                                                                             #
#    Data      Autor Fabrica    Origem      Alteracao                         #
#  ----------  -------------    ---------   --------------------------------  #
#  18/01/2012	UESLEI                      Inclusão do retorno da observação   #
#                                           quando a origem é SAF-Atendimento #
#					    Funerário.                                                      #
#-----------------------------------------------------------------------------#
# 17/01/2014 Rodolfo        PSI-2013    Alteracao no comando de envio de      #
#            Massini        -23333EV    e-mail de send_email para ctx22g00    #
#                                                                             #
# 27/10/2014 Rodolfo                    Inserir envio de endereco e dados da  #
#            Massini                    reserva para carro-extra              #
#-----------------------------------------------------------------------------#
# 09/04/2014 CDS Egeu     PSI-2014-02085   Situação Local de Ocorrência       #
#-----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define  m_ctx34g02_prep  smallint

#------------------------------------------#
function ctx34g02_prepare()
#------------------------------------------#

define l_sql char(6000)

 let l_sql = "select serv.atdlibdat,  ",
                    "serv.atdlibhor,  ",
                    "serv.atddatprg,  ",
                    "serv.atdhorprg,  ",
                    "serv.atdhorpvt,  ",
                    "serv.ciaempcod,  ",
                    "serv.c24opemat,  ",
                    "nvl(serv.c24opeempcod, 1) c24opeempcod,   ",
                    "c24opeusrtip,    ",
                    "serv.atdsrvorg,  ",
                    "serv.atdsrvnum,  ",
                    "serv.atdsrvano,  ",
                    "serv.atddfttxt,  ",
                    "serv.cnldat,     ",
                    "serv.nom,        ",
                    "serv.atdsoltip,  ",
                    "serv.c24solnom,  ",
                    "serv.asitipcod,  ",
                    "serv.atdrsdflg,  ",
                    "serv.funmat,     ",
                    "serv.empcod,     ",
                    "serv.usrtip,     ",
                    "serv.atdfnlflg,  ",
                    "serv.atdetpcod,  ",
                    "serv.sblintcod   ", ##PSI 2013-11843 - Pomar (Carga)
              " from datmservico serv ",
              "where serv.atdsrvnum = ?    ",
              "  and serv.atdsrvano = ?    "

   prepare p_ctx34g02_001 from l_sql
   declare c_ctx34g02_001 cursor for p_ctx34g02_001

    let l_sql = "select c24astcod,",
                      " lignum    ",
                 " from datmligacao                     ",
                 " where lignum = (select min(lignum)   ",
                                   " from datmligacao   ",
                                   "where atdsrvnum = ? ",
                                   "  and atdsrvano = ?)"

   prepare p_ctx34g02_002 from l_sql
   declare c_ctx34g02_002 cursor for p_ctx34g02_002

   let l_sql = "select prporg,   ",
               "       prpnumdig ",
               "  from datrligprp",
               " where lignum = ?"
   prepare p_ctx34g02_003 from l_sql
   declare c_ctx34g02_003 cursor for p_ctx34g02_003


   let l_sql = "select ligdctnum,   ",
               "       ligdcttip    ",
               "  from datrligsemapl",
               " where lignum = ?   "
   prepare p_ctx34g02_004 from l_sql
   declare c_ctx34g02_004 cursor for p_ctx34g02_004


   let l_sql = "select corsus    ",
               "  from datrligcor",
               " where lignum = ?"
   prepare p_ctx34g02_005 from l_sql
   declare c_ctx34g02_005 cursor for p_ctx34g02_005

   let l_sql = "select cgccpfnum,  ",
               "       cgccpfdig   ",
               " from datrligcgccpf",
               " where lignum = ?  "
   prepare p_ctx34g02_006 from l_sql
   declare c_ctx34g02_006 cursor for p_ctx34g02_006


   let l_sql = "select funmat,  ",
               "       empcod,  ",
               "       usrtip   ",
               " from datrligmat",
               " where lignum = ?"
   prepare p_ctx34g02_007 from l_sql
   declare c_ctx34g02_007 cursor for p_ctx34g02_007


   let l_sql = "select dddcod,   ",
               "       teltxt    ",
               " from datrligtel ",
               " where lignum = ? "
   prepare p_ctx34g02_008 from l_sql
   declare c_ctx34g02_008 cursor for p_ctx34g02_008


   let l_sql = "select vclcamtip,      ",
               "       vclcrgpso,      ",
               "       vclcrcdsc       ",
               "  from datmservicocmp  ",
               " where atdsrvnum = ?   ",
               "   and atdsrvano= ?    "
   prepare p_ctx34g02_009 from l_sql
   declare c_ctx34g02_009 cursor for p_ctx34g02_009

   let l_sql = "select socntzcod,    ",
               "       atdorgsrvnum, ",
               "       atdorgsrvano, ",
               "       srvretmtvcod, ",
               "       retprsmsmflg  ",
               "  from datmsrvre     ",
               " where atdsrvnum = ? ",
               "   and atdsrvano= ?  "
   prepare p_ctx34g02_010 from l_sql
   declare c_ctx34g02_010 cursor for p_ctx34g02_010


   let l_sql = "select hpddiapvsqtd, ",
               "       hpdqrtqtd,    ",
               "       hsphotnom,    ",
               "       hsphotend,    ",
               "       hsphotbrr,    ",
               "       hsphotcid,    ",
               "       hsphottelnum, ",
               "       hsphotcttnom, ",
               "       hsphotrefpnt, ",
               "       hsphotuf,     ",
               "       hspsegsit,    ",
               "       cid.mpacidcod ",
               "  from datmhosped,   ",
               "       outer datkmpacid cid ",
               " where atdsrvnum = ? ",
               "   and atdsrvano = ? ",
               "   and cid.ufdcod = hsphotuf ",
               "   and cid.cidnom = hsphotcid "
   prepare p_ctx34g02_011 from l_sql
   declare c_ctx34g02_011 cursor for p_ctx34g02_011

   let l_sql = "select succod,       ",
               "       ramcod,       ",
               "       aplnumdig,    ",
               "       itmnumdig     ",
               "  from datrservapol  ",
               " where atdsrvnum = ? ",
               "   and atdsrvano= ?  "
   prepare p_ctx34g02_012 from l_sql
   declare c_ctx34g02_012 cursor for p_ctx34g02_012



   let l_sql = "select avivclgrp,   ",
               "       frqvlr,      ",
               "       isnvlr       ",
               "  from datkavisveic ",
               " where avivclcod = ?"
   prepare p_ctx34g02_013 from l_sql
   declare c_ctx34g02_013 cursor for p_ctx34g02_013


   let l_sql = "select a.aviprvent,             ",
               "       a.aviestcod,             ",
               "       a.lcvcod,                ",
               "       a.avivclcod,             ",
               "       b.loccautip,             ",
               "       c.cdtsegtaxvlr           ",
               "  from datmavisrent a,          ",
               "       datmrsvvcl b ,           ",
               "       datklocadora c           ",
               " where a.atdsrvnum = b.atdsrvnum",
               "   and a.atdsrvano = b.atdsrvano",
               "   and a.lcvcod = c.lcvcod      ",
               "   and a.atdsrvnum = ?          ",
               "   and a.atdsrvano = ?          "
    prepare p_ctx34g02_014 from l_sql
    declare c_ctx34g02_014 cursor for p_ctx34g02_014


    #SELECT PARA RETORNAR OS ENDERECOS DO SERVICO
      let l_sql = "select lcl.c24endtip   ,",
    	          "       lcl.lclidttxt   ,",
    	          "       lcl.lgdtip      ,",
    	          "       lcl.lgdnom      ,",
    	          "       lcl.lgdnum      ,",
    	          "       lcl.lclbrrnom   ,",
    	          "       lcl.brrnom      ,",
    	          "       lcl.cidnom      ,",
    	          "       lcl.ufdcod      ,",
    	          "       lcl.lclrefptotxt,",
    	          "       lcl.lgdcep      ,",
    	          "       lcl.lgdcepcmp   ,",
    	          "       lcl.c24lclpdrcod,",
    	          "       lcl.dddcod      ,",
    	          "       lcl.lcltelnum   ,",
    	          "       lcl.lclcttnom   ,",
    	          "       lcl.lclltt      ,",
    	          "       lcl.lcllgt      ,",
    	          "       lcl.endcmp      ,",
    	          "       lcl.celteldddcod,",
    	          "       lcl.celtelnum   ,",
    	          "       lcl.cmlteldddcod,",
    	          "       lcl.cmltelnum   ,",
    	          "       cid.mpacidcod    ",
    	          "  from datmlcl lcl, ",
    	          "       outer datkmpacid cid ",
    	          " where lcl.ufdcod = cid.ufdcod ",
    	          "   and lcl.cidnom = cid.cidnom ",
    	          "   and lcl.atdsrvnum = ?",
    	          "   and lcl.atdsrvano = ?"
       prepare p_ctx34g02_015 from l_sql
       declare c_ctx34g02_015 cursor for p_ctx34g02_015

        #PESSOAS DOS SERVICOS
       let l_sql =    "select passeq,",
	              "       pasnom,",
	              "       pasidd",
	              " from  datmpassageiro",
	              " where atdsrvnum = ? ",
	      	      "   and atdsrvano = ? "
       prepare p_ctx34g02_016 from l_sql
       declare c_ctx34g02_016 cursor for p_ctx34g02_016


       #CONDIÇÃO DO VEICULO DO SERVICO
        let l_sql = "select vclcndlclcod",
	      	     " from datrcndlclsrv ",
	      	    " where atdsrvnum = ? ",
	      	      " and atdsrvano = ? "
        prepare p_ctx34g02_017 from l_sql
        declare c_ctx34g02_017 cursor for p_ctx34g02_017


       #dados de priorizacao
       let l_sql =    "select atdrsdflg, ",
	              "       emeviacod, ",
	              "       c24endtip  ",
	              " from  datmservico,",
	              "       datmlcl    ",
	              " where datmservico.atdsrvnum = datmlcl.atdsrvnum ",
	              "   and datmservico.atdsrvano = datmlcl.atdsrvano ",
	              "   and datmservico.atdsrvnum = ? ",
	      	      "   and datmservico.atdsrvano = ? ",
	      	      "   and datmlcl.c24endtip =1 "
       prepare p_ctx34g02_018 from l_sql
       declare c_ctx34g02_018 cursor for p_ctx34g02_018

       #SERVICO TRANSPORTE
       let l_sql = "select bagflg,        ",
       		         " trppfrdat,     ",
       		         " trppfrhor,     ",
       		         " refatdsrvnum,  ",
                         " refatdsrvano,  ",
                         " asimtvdes      ",
       		    " from datmassistpassag, ",
       		         " outer datkasimtv  ",
       		    " where atdsrvnum =?  ",
       		      " and atdsrvano =?  ",
       		      " and datkasimtv.asimtvcod = datmassistpassag.asimtvcod"

       prepare p_ctx34g02_019 from l_sql
       declare c_ctx34g02_019 cursor for p_ctx34g02_019

       let l_sql = "select vcllicnum, ",
                          "vclanomdl, ",
                          "vcldes   , ",
                          "vclcoddig, ",
                          "vclcorcod, ",
                          "ciaempcod, ",
                          "succod,    ",
                          "aplnumdig, ",
                          "itmnumdig  ",
                    " from datmservico serv, ",
                    "      outer datrservapol apl ",
                    "where serv.atdsrvnum = apl.atdsrvnum ",
                    "  and serv.atdsrvano = apl.atdsrvano ",
                    "  and serv.atdsrvnum = ? ",
                    "  and serv.atdsrvano = ? "
         prepare p_ctx34g02_020 from l_sql
         declare c_ctx34g02_020 cursor for p_ctx34g02_020


      let l_sql = "select re.atdorgsrvnum,",
                  "       re.atdorgsrvano,",
                  "       lig.c24astcod,  ",
                  "       srv.atdsrvorg,  ",
                  "       re.retprsmsmflg,",
                  "       re.srvretmtvcod ",
                  "  from datmsrvre re,   ",
                  "       datmservico srv,",
                  "       datmligacao lig ",
                  " where srv.atdsrvnum = re.atdsrvnum    ",
                  "   and srv.atdsrvano = re.atdsrvano    ",
                  "   and lig.lignum = (select min(lignum)",
                  "                       from datmligacao",
                  "                      where atdsrvnum = srv.atdsrvnum  ",
                  "                        and atdsrvano = srv.atdsrvano) ",
                  "   and srv.atdsrvnum = ?",
                  "   and srv.atdsrvano = ?"
        prepare p_ctx34g02_021 from l_sql
        declare c_ctx34g02_021 cursor for p_ctx34g02_021


        #SERVICO MULTIPLO
        let l_sql = "select a.atdsrvnum, ",
                          " a.atdsrvano, ",
                          " b.atdsrvorg, ",
                          " c.c24astcod ",
                     " from datratdmltsrv a, ",
                          " datmservico b, ",
                          " datmligacao c ",
                    " where a.atdmltsrvnum = b.atdsrvnum ",
                      " and a.atdmltsrvano = b.atdsrvano ",
                      " and c.lignum = (select min(ligmin.lignum) ",
                                       " from datmligacao ligmin ",
                                      " where ligmin.atdsrvnum = a.atdsrvnum ",
                                        " and ligmin.atdsrvano = a.atdsrvano) ",
                      " and b.atdsrvnum = ? ",
                      " and b.atdsrvano = ? "
        prepare p_ctx34g02_022 from l_sql
        declare c_ctx34g02_022 cursor for p_ctx34g02_022

        #SERVICO Auxiliar
        let l_sql =  "select a.atdsrvorg, ",
	             "       a.asitipcod, ",
	             "       re.socntzcod, ",
                     "       re.espcod     ",
	             "  from datmservico a, ",
	             "       outer datmsrvre re ",
	             " where a.atdsrvnum = re.atdsrvnum ",
	             "   and a.atdsrvano = re.atdsrvano ",
	             "   and a.atdsrvnum = ? ",
	             "   and a.atdsrvano = ? "
        prepare p_ctx34g02_023 from l_sql
        declare c_ctx34g02_023 cursor for p_ctx34g02_023

        let l_sql = "select a.ramcod,    ",
                  "       a.aplnumdig, ",
                  "       a.itmnumdig, ",
                  "       a.edsnumref, ",
                  "       b.itaciacod  ",
                  " from datrligapol a,",
                  "      datrligitaaplitm b ",
                  "where a.lignum = (select MIN(lignum)",
                  "                    from datmligacao",
                  "                   where atdsrvnum = ?",
                  "                     and atdsrvano = ? )",
                  "   and a.lignum = b.lignum"

        prepare p_ctx34g02_024 from l_sql
        declare c_ctx34g02_024 cursor for p_ctx34g02_024

        let l_sql = "select c24opemat, ",
                          " c24opeempcod, ",
                          " c24opeusrtip, ",
                          " atdfnlflg ",
                     " from datmservico ",
                     "where atdsrvnum = ?",
                     "  and atdsrvano = ? "
        prepare p_ctx34g02_025 from l_sql
        declare c_ctx34g02_025 cursor for p_ctx34g02_025

        let l_sql = " select relpamtxt ",
                      " from igbmparam ",
                     " where relsgl    = ? ",
                       " and relpamtip = ? "
        prepare p_ctx34g02_026 from l_sql
        declare c_ctx34g02_026 cursor for p_ctx34g02_026

        let l_sql = " select cpodes ",
              		" from iddkdominio ",
                      " where cponom = ? ",
                      " and cpocod = ?"
        prepare p_ctx34g02_027 from l_sql
        declare c_ctx34g02_027 cursor for p_ctx34g02_027

        let l_sql = "select seqregcnt, ",
                          " c24astcod ",
                     " from datmcntsrv ",
                    " where dstsrvnum = ? ",
                      " and dstsrvano = ?"
        prepare p_ctx34g02_028 from l_sql
        declare c_ctx34g02_028 cursor for p_ctx34g02_028

        let l_sql = "select srv.atdsrvorg, ",
                          " lig.c24astcod ",
                     " from datmservico srv,",
                         "  datmligacao lig ",
                    " where lig.lignum = (select min(ligmin.lignum) ",
                                          " from datmligacao ligmin ",
                                         " where ligmin.atdsrvnum = srv.atdsrvnum ",
                                           " and ligmin.atdsrvano = srv.atdsrvano) ",
                      " and srv.atdsrvnum = ? ",
                      " and srv.atdsrvano = ? "
        prepare p_ctx34g02_029 from l_sql
        declare c_ctx34g02_029 cursor for p_ctx34g02_029

       #SERVICO TRANSPORTE AVIAO LOCAL DESTINO
       let l_sql = "select atddstufdcod, ",
       		               " atddstcidnom, ",
       		               " cid.mpacidcod, ",
       		               " cid.lclltt, ",
                         " cid.lcllgt ",
       		    " from datmassistpassag pas, ",
       		         " outer datkmpacid cid ",
    	          " where pas.atddstufdcod = cid.ufdcod ",
    	            " and pas.atddstcidnom = cid.cidnom ",
       		        " and pas.atdsrvnum = ? ",
       		        " and pas.atdsrvano = ? ",
       		        " and not exists (select 1 from datmlcl lcl where lcl.atdsrvnum = pas.atdsrvnum and lcl.atdsrvano = pas.atdsrvano and c24endtip = 2)"

       prepare p_ctx34g02_030 from l_sql
       declare c_ctx34g02_030 cursor for p_ctx34g02_030
       
       # Rodolfo Massini - Alteracao Carro Extra - Inicio
       #SERVICO CARRO-EXTRA LOCAL ORIGEM
       let l_sql = "select rsvvcl.vclretufdcod "
                        ,",rsvvcl.vclretcidnom "
                        ,",avisrent.cttdddcod "
                        ,",avisrent.ctttelnum "  
                        ,",avisrent.smsenvdddnum "
                        ,",avisrent.smsenvcelnum "
                    ,"from datmavisrent avisrent left outer join "  
                         ,"datmrsvvcl rsvvcl "
                      ,"on rsvvcl.atdsrvnum = avisrent.atdsrvnum and "
                         ,"rsvvcl.atdsrvano = avisrent.atdsrvano " 
                   ,"where avisrent.atdsrvnum = ? and "
                         ,"avisrent.atdsrvano = ? "
                         
       prepare p_ctx34g02_031 from l_sql
       declare c_ctx34g02_031 cursor for p_ctx34g02_031
       # Rodolfo Massini - Alteracao Carro Extra - Fim
       
 # Busca as data de retirada
  let l_sql = " select vclrethordat  ",
              "   from datmrsvvcl    ",
              "  where atdsrvnum = ? ",
              "    and atdsrvano = ? " 
    
    prepare p_ctx34g02_032 from l_sql
    declare c_ctx34g02_032 cursor for p_ctx34g02_032  
    
  let l_sql = " select aviretdat, avirethor  ",
              "   from datmavisrent          ",
              "  where atdsrvnum = ?         ",
              "    and atdsrvano = ?         " 
    
    prepare p_ctx34g02_033 from l_sql
    declare c_ctx34g02_033 cursor for p_ctx34g02_033
    
 let l_sql = ' select count(mpacidcod) '
            ,' from datkmpacid  '
            ,' where ufdcod    = ? '
            ,'   and cidnom like ? '
 prepare p_ctx34g02_034 from l_sql
 declare c_ctx34g02_034 cursor for p_ctx34g02_034

 let l_sql = ' select cidnom, mpacidcod '
            ,' from datkmpacid  '
            ,' where ufdcod    = ? '
            ,'   and cidnom like ? '
 prepare p_ctx34g02_035 from l_sql
 declare c_ctx34g02_035 cursor for p_ctx34g02_035


let m_ctx34g02_prep = true

end function

#------------------------------------------#
function ctx34g02_apos_grvservico(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
end record

 define l_xml record
    response char(32766),
    request  char(32766)
 end record

 define lr_retorno record
    cod_erro  smallint,
    mensagem  char(100)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint
 define l_atdlibflg like datmservico.atdlibflg
 define l_relpamtxt  like igbmparam.relpamtxt
 

 initialize l_xml.* to null

 if not m_ctx34g02_prep then
    call ctx34g02_prepare()
 end if

  

 if ctx34g00_NovoAcionamento() and
    ctx34g00_origem(param.atdsrvnum,param.atdsrvano) and
    param.atdsrvnum is not null then

    select atdlibflg into l_atdlibflg
      from datmservico
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano

    # Envia apenas os serviços liberados
    if l_atdlibflg = 'S' then
       let l_xml.request = ctx34g02_Servico(param.atdsrvnum,param.atdsrvano)

       call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                        returning l_status,
                                  l_msg,
                                  l_xml.response

          if l_status <> 0 then
             call ctx34g02_email_erro(l_xml.request,
                                      l_xml.response,
                                      "ERRO NO MQ - ctx34g02_apos_grvservico",
                                      l_msg)

             # Grava informacao para reprocessamento batch
             let l_relpamtxt = param.atdsrvnum using "#######", "|", param.atdsrvano using "##"
             call ctx34g00_grava_mq_AW_batch(1, l_relpamtxt)

          else
             if l_xml.response like "%<retorno><codigo>1</codigo>%" then
                call ctx34g02_email_erro(l_xml.request,
                                         l_xml.response,
                                         "ERRO NO SERVICO - ctx34g02_apos_grvservico",
                                         "")

                # Grava informacao para reprocessamento batch
                let l_relpamtxt = param.atdsrvnum using "#######", "|", param.atdsrvano using "##"
                call ctx34g00_grava_mq_AW_batch(1, l_relpamtxt)

          end if
       end if

       #Envia matricula bloqueio do servico
       call ctx34g02_bloq_desbloq(param.atdsrvnum, param.atdsrvano)

    end if

 end if

end function


# busca todos os dados para realizar a inclusao e monta o XML
#------------------------------------------#
function ctx34g02_Servico(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
end record

 define l_xml record
      request         char(32766),
      response        char(32766),
      servico         char(6000),
      veiculo         char(6000),
      hospedagem      char(6000),
      locacao         char(6000),
      endereco        char(6000),
      priorizacao     char(6000),
      passageiro      char(6000),
      transporte      char(6000),
      retorno         char(6000),
      LaudoMultiplo   char(6000),
      servicoAuxiliar char(6000),
      observacoes     char(6000),
      principal       char(6000),
      etapa           char(15000),
      historico       char(15000)
  end record

 define l_status char(500)
 define l_msg    char(500)
 define l_online smallint

 define l_vcldes like datmservico.vcldes
 initialize l_xml.* to null


  # Busca os dados do servico
    call ctx34g02_busca_servico(param.atdsrvnum,
                                param.atdsrvano)
         returning l_xml.servico

  # Busca os dados do veiculo
   call ctx34g02_busca_veiculo(param.atdsrvnum,
                               param.atdsrvano)
        returning l_xml.veiculo,l_vcldes

  # Busca os dados da hospedagem
    call ctx34g02_busca_hospedagem(param.atdsrvnum,
                                    param.atdsrvano)

        returning l_xml.hospedagem


    # Busca os dados da locacao
     call ctx34g02_busca_locacao(param.atdsrvnum,
                                 param.atdsrvano,
                                 l_vcldes)
        returning l_xml.locacao

    # Busca os dados do endereco
    call ctx34g02_busca_endereco(param.atdsrvnum,
                                 param.atdsrvano)
         returning l_xml.endereco

    # Busca os dados dos passageiros
    call ctx34g02_busca_passageiros(param.atdsrvnum,
                                    param.atdsrvano)
         returning l_xml.passageiro

    #Busca o tipo de priorizacao
    call ctx34g02_busca_priorizacao(param.atdsrvnum,
                                    param.atdsrvano)
         returning l_xml.priorizacao

    #Busca o trasporte do servico
    call ctx34g02_busca_transporte(param.atdsrvnum,
                                   param.atdsrvano)
         returning l_xml.transporte

    #Busca o servico original quando for retorno
    call ctx34g02_busca_retorno(param.atdsrvnum,
                                param.atdsrvano)
         returning l_xml.retorno

    #Busca os servicos do laudo multiplo
    call ctx34g02_busca_LaudoMultiplo(param.atdsrvnum,
                                      param.atdsrvano)
         returning l_xml.LaudoMultiplo

   #Busca principal
   call ctx34g02_busca_principal(param.atdsrvnum,
                               	 param.atdsrvano)
         returning l_xml.principal

   #Busca os dados das observacoes
    call ctx34g02_busca_observacoes(param.atdsrvnum,
                                      param.atdsrvano)
         returning l_xml.observacoes

   #Busca os dados do servico
    call ctx34g02_busca_servicoAuxiliar(param.atdsrvnum,
                                      param.atdsrvano)
         returning l_xml.servicoAuxiliar

   #Busca os dados das etapas
    call ctx34g00_xmlEtapas(param.atdsrvnum,
                            param.atdsrvano)
         returning l_xml.etapa

   #Busca os dados do historico
    call ctx34g01_xmlhistoricos(param.atdsrvnum,
                                param.atdsrvano)
         returning l_xml.historico


  let l_xml.request = ctx34g02_geraXML(l_xml.servico    ,
                                       l_xml.veiculo    ,
                                       l_xml.hospedagem ,
                                       l_xml.locacao    ,
                                       l_xml.endereco   ,
                                       l_xml.priorizacao,
                                       l_xml.passageiro ,
                                       l_xml.transporte ,
                                       l_xml.retorno    ,
                                       l_xml.LaudoMultiplo,
                                       l_xml.observacoes,
                                       l_xml.principal,
                                       l_xml.servicoAuxiliar,
                                       l_xml.etapa,
                                       l_xml.historico)

  return l_xml.request

end function

#------------------------------------------#
function ctx34g02_busca_servico(param)
#------------------------------------------#
define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
end record

define ctx34g02_servico record
   atdlibdat     like datmservico.atdlibdat   ,
   atdlibhor     like datmservico.atdlibhor   ,
   atddatprg     like datmservico.atddatprg   ,
   atdhorprg     like datmservico.atdhorprg   ,
   atdhorpvt     like datmservico.atdhorpvt   ,
   ciaempcod     like datmservico.ciaempcod   ,
   c24opemat     like datmservico.c24opemat   ,
   c24opeempcod  like datmservico.c24opeempcod,
   c24opeusrtip  like datmservico.c24opeusrtip,
   atdsrvorg     like datmservico.atdsrvorg   ,
   atdsrvnum     like datmservico.atdsrvnum   ,
   atdsrvano     like datmservico.atdsrvano   ,
   atddfttxt     like datmservico.atddfttxt   ,
   cnldat        like datmservico.cnldat      ,
   nom           like datmservico.nom         ,
   atdsoltip     like datmservico.atdsoltip   ,
   c24solnom     like datmservico.c24solnom   ,
   asitipcod     like datmservico.asitipcod   ,
   atdrsdflg     like datmservico.atdrsdflg   ,
   vclcndlclcod  like datrcndlclsrv.vclcndlclcod ,
   vclcamtip     like datmservicocmp.vclcamtip,
   vclcrgpso     like datmservicocmp.vclcrgpso,
   funmat        like datmservico.funmat   ,
   empcod        like datmservico.empcod   ,
   usrtip        like datmservico.usrtip   ,
   atdfnlflg     like datmservico.atdfnlflg,
   atdetpcod     like datmservico.atdetpcod,
   sblintcod     like datmservico.sblintcod #PSI 2013-11843 - Pomar (Carga)
  end record

  define ctx34g02_transporte record
   bagflg    like datmassistpassag.bagflg   ,
   trppfrdat like datmassistpassag.trppfrdat,
   trppfrhor like datmassistpassag.trppfrhor,
   refatdsrvnum  like datmassistpassag.refatdsrvnum,
   refatdsrvano  like datmassistpassag.refatdsrvano,
   asimtvdes like datkasimtv.asimtvdes
  end record

  define ctx34g02_contigencia record
     seqregcnt  like datmcntsrv.seqregcnt,
     c24astcod  like datmcntsrv.c24astcod
  end record

  define lr_tipoDoc record
     doctip     smallint,
     documento  char(200),
     c24astcod  like    datmligacao.c24astcod
  end record


  define servico char(6000)
        ,l_faseacionamento smallint
        ,l_dtrtdvcl datetime year to second
        ,l_aviretdat  like datmavisrent.aviretdat
        ,l_avirethor  like datmavisrent.avirethor

  initialize ctx34g02_servico.* to null
  initialize ctx34g02_transporte.* to null
  initialize ctx34g02_contigencia.* to null
  let servico = ''

whenever error continue

  #-------------------------------------------------------------#
  # CURSOR PARA TRAZER TODOS OS DADOS DO SERVICO                #
  #-------------------------------------------------------------#
  open c_ctx34g02_001 using param.atdsrvnum,
                            param.atdsrvano

  fetch c_ctx34g02_001  into  ctx34g02_servico.atdlibdat    ,
                              ctx34g02_servico.atdlibhor    ,
                              ctx34g02_servico.atddatprg    ,
                              ctx34g02_servico.atdhorprg    ,
                              ctx34g02_servico.atdhorpvt    ,
                              ctx34g02_servico.ciaempcod    ,
                              ctx34g02_servico.c24opemat    ,
                              ctx34g02_servico.c24opeempcod ,
                              ctx34g02_servico.c24opeusrtip ,
                              ctx34g02_servico.atdsrvorg    ,
                              ctx34g02_servico.atdsrvnum    ,
                              ctx34g02_servico.atdsrvano    ,
                              ctx34g02_servico.atddfttxt    ,
                              ctx34g02_servico.cnldat       ,
                              ctx34g02_servico.nom          ,
                              ctx34g02_servico.atdsoltip    ,
                              ctx34g02_servico.c24solnom    ,
                              ctx34g02_servico.asitipcod    ,
                              ctx34g02_servico.atdrsdflg    ,
                              ctx34g02_servico.funmat       ,
                              ctx34g02_servico.empcod       ,
                              ctx34g02_servico.usrtip       ,
                              ctx34g02_servico.atdfnlflg    ,
                              ctx34g02_servico.atdetpcod    ,
                              ctx34g02_servico.sblintcod    #PSI 2013-11843 - Pomar (Carga)

     case ctx34g02_servico.atdsoltip
       when 'S'
          let ctx34g02_servico.atdsoltip = 1
       when 'C'
          let ctx34g02_servico.atdsoltip = 2
       when 'O'
          let ctx34g02_servico.atdsoltip = 3
       otherwise
          let ctx34g02_servico.atdsoltip = 3
     end case
 whenever error stop


   # Busca os dados do tipo de documento que deve ser enviado
    call ctx34g02_busca_tipoDocumento(param.atdsrvnum,
                                      param.atdsrvano)
        returning lr_tipoDoc.doctip   ,
                  lr_tipoDoc.documento,
                  lr_tipoDoc.c24astcod

   if ctx34g02_servico.atdfnlflg = "A" or ctx34g02_servico.atdfnlflg = "N" then
      let l_faseacionamento = 1
   else

      # Nao envia matricula de bloqueio quando o servico estiver finalizado
      let ctx34g02_servico.c24opemat = 0
      let ctx34g02_servico.c24opeempcod = 0
      let ctx34g02_servico.c24opeusrtip = ''

      if ctx34g02_servico.atdetpcod = 5 then # CANCELADO
         let l_faseacionamento = 4
      else
         let l_faseacionamento = 3
      end if
   end if

   if ctx34g02_servico.nom is null or ctx34g02_servico.nom = ' ' then
      let ctx34g02_servico.nom = "NAO INFORMADO"
   end if

   if ctx34g02_servico.c24solnom is null or ctx34g02_servico.c24solnom = ' ' then
      let ctx34g02_servico.c24solnom = "NAO INFORMADO"
   end if

   if ctx34g02_servico.c24opeusrtip is null or ctx34g02_servico.c24opeusrtip = ' ' then
      let ctx34g02_servico.c24opeusrtip = "F"
   end if

   # Busca motivo da assitencia a passageiros
   if ctx34g02_servico.atdsrvorg = 2 or
      ctx34g02_servico.atdsrvorg = 3 then
      open c_ctx34g02_019 using param.atdsrvnum,
                                param.atdsrvano
      fetch c_ctx34g02_019 into ctx34g02_transporte.bagflg,
                                ctx34g02_transporte.trppfrdat,
                                ctx34g02_transporte.trppfrhor,
                                ctx34g02_transporte.refatdsrvnum,
                                ctx34g02_transporte.refatdsrvano,
                                ctx34g02_transporte.asimtvdes
      let ctx34g02_servico.atddfttxt = ctx34g02_transporte.asimtvdes
      close c_ctx34g02_019
   end if
   
   if ctx34g02_servico.atdsrvorg = 8 then
         open c_ctx34g02_033 using param.atdsrvnum,
                                           param.atdsrvano
                 fetch c_ctx34g02_033 into l_aviretdat, l_avirethor
	               close c_ctx34g02_033
            
                 let ctx34g02_servico.atddatprg = l_aviretdat
	               let ctx34g02_servico.atdhorprg = l_avirethor                 
   end if

   # Busca dados da contingencia quando servico for aberto por la
   open c_ctx34g02_028 using param.atdsrvnum,
                             param.atdsrvano
   fetch c_ctx34g02_028 into ctx34g02_contigencia.seqregcnt,
                             ctx34g02_contigencia.c24astcod

   close c_ctx34g02_019

   let servico = servico clipped,
       '<CodigoSistemaOrigem>1</CodigoSistemaOrigem>',
       '<DataAbertura>',ctx34g02_servico.atdlibdat clipped,' ',ctx34g02_servico.atdlibhor clipped,'</DataAbertura>',
       '<DataProgramacao>',ctx34g02_servico.atddatprg clipped,' ',ctx34g02_servico.atdhorprg clipped,'</DataProgramacao>',
       '<QuantidadeScorePrioridade/>',
       '<CodigoFaixaPrioridade/>',
       '<DescricaoMotivoServico><![CDATA[',ctx34g02_servico.atddfttxt clipped,']]></DescricaoMotivoServico>',
       '<FlagFaseAcionamento>', l_faseacionamento using "<<<&" ,'</FlagFaseAcionamento>',
       '<DataBloqueio/>',
       '<DataPrevisaoAtendimentoCliente>',ctx34g02_servico.atdhorpvt clipped,'</DataPrevisaoAtendimentoCliente>',
       '<DataPrevistaInicioAtendimento>',ctx34g02_servico.atddatprg clipped,' ',ctx34g02_servico.atdhorprg clipped,'</DataPrevistaInicioAtendimento>',
       '<DataAtualizacao>',ctx34g02_servico.atdlibdat clipped,' ',ctx34g02_servico.atdlibhor clipped,'</DataAtualizacao>',
       '<Empresa>',
            '<CodigoEmpresa>',ctx34g02_servico.ciaempcod using "<<&", '</CodigoEmpresa>',
       '</Empresa>',
       '<Especialidade>',
            '<CodigoEspecialidade>0</CodigoEspecialidade>',
       '</Especialidade>',
       '<UsuarioBloqueio>',
            '<Matricula>',ctx34g02_servico.c24opemat using "<<<<<&", '</Matricula>',
            '<Empresa>',ctx34g02_servico.c24opeempcod using "<&", '</Empresa>',
            '<TipoUsuario>',ctx34g02_servico.c24opeusrtip, '</TipoUsuario>',
       '</UsuarioBloqueio>',
       '<UsuarioAtualizacao>',
            '<Matricula>',ctx34g02_servico.funmat using "<<<<<&", '</Matricula>',
            '<Empresa>',ctx34g02_servico.empcod using "<&", '</Empresa>',
            '<TipoUsuario>',ctx34g02_servico.usrtip, '</TipoUsuario>',
       '</UsuarioAtualizacao>',
       '<Central>',
            '<CodigoOrigemServico>',ctx34g02_servico.atdsrvorg using "<&", '</CodigoOrigemServico>',
            '<NumeroServicoAtendimento>',ctx34g02_servico.atdsrvnum using "<<<<<<&", '</NumeroServicoAtendimento>',
            '<AnoServicoAtendimento>',ctx34g02_servico.atdsrvano using "<&", '</AnoServicoAtendimento>',
            '<CodigoAssuntoCentral>',lr_tipoDoc.c24astcod clipped,'</CodigoAssuntoCentral>',
       '</Central>',
       #PSI 2013-11843 - Pomar (Carga) - Inicio
       '<Siebel>',
            '<CodigoServicoSiebel>',ctx34g02_servico.sblintcod clipped,'</CodigoServicoSiebel>',
       '</Siebel>'
       #PSI 2013-11843 - Pomar (Carga) - Fim

       # Envia dados da contigencia quando existir informacao
       if ctx34g02_contigencia.seqregcnt > 0 then
          let servico = servico clipped,
                        '<Contingencia>',
                            '<NumeroServicoContingencia>',ctx34g02_contigencia.seqregcnt,'</NumeroServicoContingencia>',
                            '<CodigoAssuntoCentral>',ctx34g02_contigencia.c24astcod,'</CodigoAssuntoCentral>',
                        '</Contingencia>'
       end if

   let servico = servico clipped,
       '<Solicitante>',
            '<NomeSolicitante><![CDATA[',ctx34g02_servico.c24solnom clipped,']]></NomeSolicitante>',
            '<NomeCliente><![CDATA[',ctx34g02_servico.nom clipped,']]></NomeCliente>',
            '<TipoSolicitante>',ctx34g02_servico.atdsoltip,'</TipoSolicitante>',
            '<TipoDocumento>',lr_tipoDoc.doctip,'</TipoDocumento>',
            '<NumeroDocumento>',lr_tipoDoc.documento clipped,'</NumeroDocumento>'
            
             if ctx34g02_servico.ciaempcod = 1 and lr_tipoDoc.doctip = 1 then
               
               
               open c_ctx34g02_012 using param.atdsrvnum,
                                         param.atdsrvano
               fetch c_ctx34g02_012  into g_documento.succod,
                                          g_documento.ramcod,
                                          g_documento.aplnumdig,
                                          g_documento.itmnumdig
               close c_ctx34g02_012
               
               #-------------------------------------------- 
               # Recupera o Segmento   
               #-------------------------------------------- 
               call cty31g00_recupera_perfil(g_documento.succod
                                            ,g_documento.aplnumdig
                                            ,g_documento.itmnumdig)
               returning g_nova.perfil    ,
                         g_nova.clscod    ,
                         g_nova.dt_cal    ,
                         g_nova.vcl0kmflg ,
                         g_nova.imsvlr    ,
                         g_nova.ctgtrfcod ,    
                         g_nova.clalclcod ,
                         g_nova.dctsgmcod ,
                         g_nova.clisgmcod
    
               if g_nova.dctsgmcod is not null and g_nova.clisgmcod is not null then
               	  if g_nova.dctsgmcod > 0 or g_nova.clisgmcod > 0 then
                     let servico = servico clipped,
                                '<CodigoSegmentoDocumento>', g_nova.dctsgmcod, '</CodigoSegmentoDocumento>',
                                '<CodigoSegmentoCliente>', g_nova.clisgmcod, '</CodigoSegmentoCliente>'
                  end if
               end if
            end if   
            
            if ctx34g02_servico.ciaempcod = 43 then 
               if g_novapss.dctsgmcod is null or
                  g_novapss.clisgmcod is null then
                  whenever error continue
                     if param.atdsrvnum is not null then
                        select clisgmnum, prdsgmnum
                          into g_novapss.clisgmcod, g_novapss.dctsgmcod
                          from datmsrvped
                         where srvpedcod = (select srvpedcod
                                              from datrsrvitm
                                             where atdsrvnum = param.atdsrvnum
                                               and atdsrvano = param.atdsrvano)
                        if sqlca.sqlcode = 100 then
                           display '[Porto FAZ] - Parametros nao encontrados: '
                                  ,param.atdsrvnum, '-', param.atdsrvano 
                           let g_novapss.dctsgmcod = null
                           let g_novapss.clisgmcod = null
                        end if 
                     end if
                  whenever error stop
               end if
               
               if g_novapss.dctsgmcod is not null and g_novapss.clisgmcod is not null then
               	  if g_novapss.dctsgmcod > 0 or g_novapss.clisgmcod > 0 then
                     let servico = servico clipped,
                                '<CodigoSegmentoDocumento>', g_novapss.dctsgmcod, '</CodigoSegmentoDocumento>',
                                '<CodigoSegmentoCliente>', g_novapss.clisgmcod, '</CodigoSegmentoCliente>'
                  end if
               end if
               
            end if
   let servico = servico clipped,
                 '</Solicitante>'

 return servico

end function


#------------------------------------------#
function ctx34g02_busca_veiculo(param)
#------------------------------------------#
define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
end record

define ctx34g02_veiculo record
   vcllicnum     like datmservico.vcllicnum      ,
   vclanomdl     like datmservico.vclanomdl      ,
   vcldes        like datmservico.vcldes         ,
   vclcoddig     like datmservico.vclcoddig      ,
   vclcorcod     like datmservico.vclcorcod      ,
   vclcndlclcod  like datrcndlclsrv.vclcndlclcod ,
   vclcamtip     like datmservicocmp.vclcamtip   ,
   vclcrgpso     like datmservicocmp.vclcrgpso   ,
   vclcrcdsc     like datmservicocmp.vclcrcdsc
  end record

  define veiculo char(6000)
  define condicoes char(6000)
  define l_blidado smallint,
         l_ciaempcod like datmservico.ciaempcod,
         l_succod    like datrservapol.succod,
         l_aplnumdig like datrservapol.aplnumdig,
         l_itmnumdig like datrservapol.itmnumdig,
         l_resultado integer,
         l_mensagem  char(100),
         l_imsvlr    like abbmcasco.imsvlr,
         l_carroceriaccod smallint

  initialize ctx34g02_veiculo.* to null
  let veiculo = ''
  let condicoes = ''
  let l_blidado = 0
  let l_carroceriaccod = 0

whenever error continue

  #-------------------------------------------------------------#
  # CURSOR PARA TRAZER TODOS OS DADOS DO SERVICO                #
  #-------------------------------------------------------------#
  open c_ctx34g02_020 using param.atdsrvnum,
                            param.atdsrvano

  fetch c_ctx34g02_020  into  ctx34g02_veiculo.vcllicnum    ,
                              ctx34g02_veiculo.vclanomdl    ,
                              ctx34g02_veiculo.vcldes       ,
                              ctx34g02_veiculo.vclcoddig    ,
                              ctx34g02_veiculo.vclcorcod    ,
                              l_ciaempcod,
                              l_succod,
                              l_aplnumdig,
                              l_itmnumdig

 whenever error stop

  whenever error continue
   open c_ctx34g02_017 using param.atdsrvnum,
                             param.atdsrvano


   foreach c_ctx34g02_017 into ctx34g02_veiculo.vclcndlclcod

  	let condicoes = condicoes clipped,'<ServicoVeiculoCondicao>'
                                            ,'<VeiculoCondicao>'
                                               ,'<CodigoVeiculoCondicao>',ctx34g02_veiculo.vclcndlclcod using "<<<<<<&",'</CodigoVeiculoCondicao>'
                                            ,'</VeiculoCondicao>'
                                         ,'</ServicoVeiculoCondicao>'





   end foreach
 whenever error stop

  whenever error continue
   open c_ctx34g02_009 using param.atdsrvnum,
                             param.atdsrvano


   fetch c_ctx34g02_009 into ctx34g02_veiculo.vclcamtip,
                             ctx34g02_veiculo.vclcrgpso,
                             ctx34g02_veiculo.vclcrcdsc

   close  c_ctx34g02_009
 whenever error stop

 #--------------------------------------------------------------
 # Verifica se veiculo e BLINDADO.
 #--------------------------------------------------------------
 if l_ciaempcod = 1 then
    call f_funapol_ultima_situacao (l_succod,
                                    l_aplnumdig,
                                    l_itmnumdig)
        returning g_funapol.*
    let l_imsvlr = 0
    select imsvlr
      into l_imsvlr
      from abbmbli
     where succod    = l_succod    and
           aplnumdig = l_aplnumdig and
           itmnumdig = l_itmnumdig and
           dctnumseq = g_funapol.autsitatu

    if l_imsvlr > 0 then
       let l_blidado = 1
    end if
 end if
 
 #--------------------------------------------------------------
 # OBTER IS DA APOLICE
 #--------------------------------------------------------------
 let l_imsvlr = 0
 call cts40g26_obter_is_apol(param.atdsrvnum,
                             param.atdsrvano,
                             l_ciaempcod)
      returning l_resultado, l_mensagem, l_imsvlr


  let veiculo = veiculo clipped,
          '<VeiculoModelo>',
               '<CodigoVeiculo>',ctx34g02_veiculo.vclcoddig using "<<<<<<&",'</CodigoVeiculo>',
          '</VeiculoModelo>',
          '<NumeroPlacaVeiculo>',ctx34g02_veiculo.vcllicnum clipped,'</NumeroPlacaVeiculo>',
          '<AnoPlacaVeiculo>',ctx34g02_veiculo.vclanomdl clipped,'</AnoPlacaVeiculo>',
          '<VeiculoCor>',
               '<CodigoVeiculoCor>',ctx34g02_veiculo.vclcorcod using "<<<&",'</CodigoVeiculoCor>',
          '</VeiculoCor>',
          '<ValorVeiculo>', l_imsvlr,'</ValorVeiculo>',
          '<FlagBlindado>', l_blidado using "&", '</FlagBlindado>'

  if ctx34g02_veiculo.vclcamtip > 0 then
     case ctx34g02_veiculo.vclcrcdsc
        when 'BAU'
           let l_carroceriaccod = 1
        when 'TANQUE'
           let l_carroceriaccod = 2
        when 'CACAMBA'
           let l_carroceriaccod = 3
        when 'ABERTO'
           let l_carroceriaccod = 4
        otherwise
           let l_carroceriaccod = 5 # Outros
     end case

     if ctx34g02_veiculo.vclcrgpso > 99999 then
        let ctx34g02_veiculo.vclcrgpso = 99999
     end if

     let veiculo = veiculo clipped,
          '<VeiculoCaminhao>',
               '<TipoCarroceria>',l_carroceriaccod, '</TipoCarroceria>',
               '<TipoCaminhao>', ctx34g02_veiculo.vclcamtip, '</TipoCaminhao>',
               '<QuantidadePesoVeiculo>',ctx34g02_veiculo.vclcrgpso,'</QuantidadePesoVeiculo>',
               '<QuantidadeVolumeVeiculo/>',
          '</VeiculoCaminhao>'
  end if

  let veiculo = veiculo clipped,
          '<VeiculosCondicao>',condicoes clipped,'</VeiculosCondicao>'

 return veiculo,ctx34g02_veiculo.vcldes

end function

#------------------------------------------#
function ctx34g02_busca_tipoDocumento(param)
#------------------------------------------#

 define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
 end record


 define ctx34g02_ligacao record
     lignum       like    datmligacao.lignum     ,
     prporg       like    datrligprp.prporg      ,
     prpnumdig    like    datrligprp.prpnumdig   ,
     ligdctnum    like    datrligsemapl.ligdctnum,
     ligdcttip    like    datrligsemapl.ligdcttip,
     corsus       like    datrligcor.corsus      ,
     cgccpfnum    like    datrligcgccpf.cgccpfnum,
     cgccpfdig    like    datrligcgccpf.cgccpfdig,
     funmat       like    datrligmat.funmat      ,
     empcod       like    datrligmat.empcod      ,
     usrtip       like    datrligmat.usrtip      ,
     dddcod       like    datrligtel.dddcod      ,
     teltxt       like    datrligtel.teltxt      ,
     doctip       smallint                       ,
     docnum       char(80)
  end record

  define ctx34g02_apolice record
     succod     like datrservapol.succod,
     ramcod     like datrservapol.ramcod,
     aplnumdig  like datrservapol.aplnumdig,
     itmnumdig  like datrservapol.itmnumdig
  end record

   define lr_retorno record
     doctip    smallint,
     documento char(200),
     c24astcod    like    datmligacao.c24astcod
  end record

 initialize ctx34g02_ligacao.* to null
 initialize ctx34g02_apolice.* to null
 initialize lr_retorno.* to null

 let lr_retorno.doctip = 0
 let lr_retorno.documento = "NAO INFORMADO"
 let lr_retorno.c24astcod = "NSI"

  #-----------------------------------------------------#
  # CURSOR PARA TRAZER O CODIO DO ASSUNTO E LIGACAO     #
  #-----------------------------------------------------#
  whenever error continue
    open c_ctx34g02_002 using param.atdsrvnum,
                              param.atdsrvano
    fetch c_ctx34g02_002  into  lr_retorno.c24astcod,
                                ctx34g02_ligacao.lignum
  whenever error stop


  #-----------------------------------------------------#
  # CURSOR PARA TRAZER O CODIO DO ASSUNTO E LIGACAO     #
  #-----------------------------------------------------#
  whenever error continue
    open c_ctx34g02_012 using param.atdsrvnum,
                              param.atdsrvano
    fetch c_ctx34g02_012  into  ctx34g02_apolice.succod,
                                ctx34g02_apolice.ramcod,
                                ctx34g02_apolice.aplnumdig,
                                ctx34g02_apolice.itmnumdig
     if sqlca.sqlcode = 0 then

        let lr_retorno.doctip    = 1
        let lr_retorno.documento = ctx34g02_apolice.succod using "<<<&",'-',
                                   ctx34g02_apolice.ramcod using "<<<<&",'-',
                                   ctx34g02_apolice.aplnumdig using "<<<<<<<<<<&",'-',
                                   ctx34g02_apolice.itmnumdig using "<<<<&"

        return lr_retorno.doctip,
               lr_retorno.documento,
               lr_retorno.c24astcod
     end if
  whenever error stop


  #----------------------------------------------#
  # CURSOR PARA TRAZER A PROPOSTA DO SERVICO     #
  #----------------------------------------------#
  whenever error continue
    open c_ctx34g02_003 using ctx34g02_ligacao.lignum
    fetch c_ctx34g02_003  into  ctx34g02_ligacao.prporg,
                                ctx34g02_ligacao.prpnumdig

    if sqlca.sqlcode = 0 then

        let lr_retorno.doctip    = 2
        let lr_retorno.documento = ctx34g02_ligacao.prporg using "<<<&",'-',ctx34g02_ligacao.prpnumdig using "<<<<<<<<<&"

        return lr_retorno.doctip,
               lr_retorno.documento,
               lr_retorno.c24astcod
     end if
  whenever error stop


  #--------------------------------------------------------#
  # CURSOR PARA TRAZER O NUMERO DO DOCUMENTO DA LIGACAO    #
  #--------------------------------------------------------#
  whenever error continue
    open c_ctx34g02_004 using ctx34g02_ligacao.lignum
    fetch c_ctx34g02_004  into  ctx34g02_ligacao.ligdctnum,
                                ctx34g02_ligacao.ligdcttip

    if sqlca.sqlcode = 0 then
        if ctx34g02_ligacao.ligdcttip = 1 then
           let lr_retorno.doctip    = 3
           let lr_retorno.documento = ctx34g02_ligacao.ligdctnum using "<<<<<<<<<<<&"

           return lr_retorno.doctip,
                  lr_retorno.documento,
                  lr_retorno.c24astcod
        else
           if ctx34g02_ligacao.ligdcttip = 3 then
              let lr_retorno.doctip    = 4
              let lr_retorno.documento = ctx34g02_ligacao.ligdctnum using "<<<<<<<<<<<<&"

              return lr_retorno.doctip,
                     lr_retorno.documento,
                     lr_retorno.c24astcod
           end if
        end if
     end if

  whenever error stop


  #--------------------------------------------------------#
  # CURSOR PARA TRAZER O CODIGO DA SUSEP DO CORRETOR       #
  #--------------------------------------------------------#
  whenever error continue
    open c_ctx34g02_005 using ctx34g02_ligacao.lignum
    fetch c_ctx34g02_005  into  ctx34g02_ligacao.corsus

    if sqlca.sqlcode = 0 then

        let lr_retorno.doctip    = 5
        let lr_retorno.documento = ctx34g02_ligacao.corsus clipped

        return lr_retorno.doctip,
               lr_retorno.documento,
               lr_retorno.c24astcod
     end if
  whenever error stop


  #-----------------------------------------#
  # CURSOR PARA TRAZER O NUMERO DO CPF      #
  #-----------------------------------------#
  whenever error continue
    open c_ctx34g02_006 using ctx34g02_ligacao.lignum
    fetch c_ctx34g02_006  into  ctx34g02_ligacao.cgccpfnum,
                                ctx34g02_ligacao.cgccpfdig

    if sqlca.sqlcode = 0 then

        let lr_retorno.doctip    = 6
        let lr_retorno.documento = ctx34g02_ligacao.cgccpfnum using "<<<<<<<<<&",'-',ctx34g02_ligacao.cgccpfdig using "<&"

        return lr_retorno.doctip,
               lr_retorno.documento,
               lr_retorno.c24astcod
     end if
  whenever error stop

  #-------------------------------------#
  # CURSOR PARA TRAZER A MATRICULA      #
  #-------------------------------------#
  whenever error continue
    open c_ctx34g02_007 using ctx34g02_ligacao.lignum
    fetch c_ctx34g02_007  into  ctx34g02_ligacao.funmat,
                                ctx34g02_ligacao.empcod,
                                ctx34g02_ligacao.usrtip
    if sqlca.sqlcode = 0 then

        let lr_retorno.doctip    = 7
        let lr_retorno.documento = ctx34g02_ligacao.usrtip clipped,
                                   ctx34g02_ligacao.empcod using "&&",
                                   ctx34g02_ligacao.funmat using "&&&&&"

        return lr_retorno.doctip,
               lr_retorno.documento,
               lr_retorno.c24astcod
     end if
  whenever error stop

  #------------------------------------#
  # CURSOR PARA TRAZER O TELEFONE      #
  #------------------------------------#
  whenever error continue
    open c_ctx34g02_008 using ctx34g02_ligacao.lignum
    fetch c_ctx34g02_008  into  ctx34g02_ligacao.dddcod,
                                ctx34g02_ligacao.teltxt
    if sqlca.sqlcode = 0 then

        let lr_retorno.doctip    = 8
        let lr_retorno.documento = ctx34g02_ligacao.dddcod clipped,'-',ctx34g02_ligacao.teltxt clipped

        return lr_retorno.doctip,
               lr_retorno.documento,
               lr_retorno.c24astcod
     end if
  whenever error stop

  return lr_retorno.doctip,
         lr_retorno.documento,
         lr_retorno.c24astcod

end function

#------------------------------------------#
function ctx34g02_busca_hospedagem(param)
#------------------------------------------#
define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
end record

define ctx34g02_hospedagem record
   hpddiapvsqtd  like datmhosped.hpddiapvsqtd ,
   hpdqrtqtd     like datmhosped.hpdqrtqtd    ,
   hsphotnom     like datmhosped.hsphotnom    ,
   hsphotend     like datmhosped.hsphotend    ,
   hsphotbrr     like datmhosped.hsphotbrr    ,
   hsphotcid     like datmhosped.hsphotcid    ,
   hsphottelnum  like datmhosped.hsphottelnum ,
   hsphotcttnom  like datmhosped.hsphotcttnom ,
   hsphotrefpnt  like datmhosped.hsphotrefpnt ,
   hsphotuf      like datmhosped.hsphotuf     ,
   hspsegsit     like datmhosped.hspsegsit    ,
   mpacidcod     like datkmpacid.mpacidcod
  end record

  define telefone      char(200),
         hospedagem    char(6000),
         l_telefone    integer

  initialize ctx34g02_hospedagem.* to null
  let hospedagem  = ''
  let telefone = ''
  let l_telefone = 0


whenever error continue

  #-----------------------------------------------------------#
  # CURSOR PARA TRAZER TODOS OS DADOS DA HOSPEDAGEM           #
  #-----------------------------------------------------------#
  open c_ctx34g02_011 using param.atdsrvnum,
                            param.atdsrvano

  fetch c_ctx34g02_011  into  ctx34g02_hospedagem.hpddiapvsqtd,
                              ctx34g02_hospedagem.hpdqrtqtd   ,
                              ctx34g02_hospedagem.hsphotnom   ,
                              ctx34g02_hospedagem.hsphotend   ,
                              ctx34g02_hospedagem.hsphotbrr   ,
                              ctx34g02_hospedagem.hsphotcid   ,
                              ctx34g02_hospedagem.hsphottelnum,
                              ctx34g02_hospedagem.hsphotcttnom,
                              ctx34g02_hospedagem.hsphotrefpnt,
                              ctx34g02_hospedagem.hsphotuf    ,
                              ctx34g02_hospedagem.hspsegsit   ,
                              ctx34g02_hospedagem.mpacidcod

  if sqlca.sqlcode = 0 then
     if ctx34g02_hospedagem.hsphottelnum is not null or ctx34g02_hospedagem.hsphottelnum <> ' ' then
     	  let l_telefone = ctx34g02_hospedagem.hsphottelnum
        let telefone = '<Telefone>',
                           '<NumeroTelefone>', l_telefone using "<<<&" ,'</NumeroTelefone>',
                           '<NomeContato><![CDATA[',ctx34g02_hospedagem.hsphotcttnom clipped,']]></NomeContato>',
                           '<TipoTelefone>1</TipoTelefone>',
                       '</Telefone>'
     else
        let telefone =''
     end if

     let hospedagem = hospedagem clipped,
     '<QuantidadeDia>',ctx34g02_hospedagem.hpddiapvsqtd clipped,'</QuantidadeDia>',
     '<QuantidadeQuarto>',ctx34g02_hospedagem.hpdqrtqtd clipped,'</QuantidadeQuarto>',
     '<FlagClienteHospedado>',ctx34g02_hospedagem.hspsegsit clipped,'</FlagClienteHospedado>',
     '<Endereco>',
          '<DescricaoLocal>', ctx34g02_hospedagem.hsphotnom clipped, '</DescricaoLocal>',
          '<Cidade>',
               '<CodigoCidade>',ctx34g02_hospedagem.mpacidcod clipped,'</CodigoCidade>',
               '<SiglaUF>',ctx34g02_hospedagem.hsphotuf clipped,'</SiglaUF>',
               '<NomeCidade><![CDATA[',ctx34g02_hospedagem.hsphotcid  clipped,']]></NomeCidade>',
          '</Cidade>',
          '<NomeBairro><![CDATA[',ctx34g02_hospedagem.hsphotbrr clipped,']]></NomeBairro>',
          '<NomeSubBairro />',
          '<NomeLogradouro><![CDATA[',ctx34g02_hospedagem.hsphotend clipped,']]></NomeLogradouro>',
          '<NumeroLogradouro/>',
          '<DescricaoEnderecoComplemento />',
          '<CodigoCEP />',
          '<NumeroLatitude />',
          '<NumeroLongitude />',
          '<TipoIndexacao />',
          '<DescricaoPontoReferencia><![CDATA[',ctx34g02_hospedagem.hsphotrefpnt clipped,']]></DescricaoPontoReferencia>',
          '<Telefones>',telefone clipped,'</Telefones>',
     '</Endereco>'
  end if

 whenever error stop
 return hospedagem


end function



#------------------------------------------#
function ctx34g02_busca_locacao(param)
#------------------------------------------#
define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano,
   vcldes    like datmservico.vcldes
end record

 define ctx34g02_locacao record
   aviprvent     like datmavisrent.aviprvent  ,
   aviestcod     like datmavisrent.aviestcod  ,
   lcvcod        like datmavisrent.lcvcod     ,
   avivclcod     like datmavisrent.avivclcod  ,
   loccautip     like datmrsvvcl.loccautip    ,
   cdtsegtaxvlr  like datklocadora.cdtsegtaxvlr,
   avivclgrp     like datkavisveic.avivclgrp  ,
   frqvlr        like datkavisveic.frqvlr     ,
   isnvlr        like datkavisveic.isnvlr
 end record

 define locacao char(6000)

  initialize ctx34g02_locacao.* to null
  initialize locacao to null

 whenever error continue
    open c_ctx34g02_014 using param.atdsrvnum,
                              param.atdsrvano
    fetch c_ctx34g02_014  into  ctx34g02_locacao.aviprvent,
                                ctx34g02_locacao.aviestcod,
                                ctx34g02_locacao.lcvcod   ,
                                ctx34g02_locacao.avivclcod,
                                ctx34g02_locacao.loccautip,
                                ctx34g02_locacao.cdtsegtaxvlr
  
  if sqlca.sqlcode = 0 then

  whenever error continue
     open c_ctx34g02_013 using ctx34g02_locacao.avivclcod

     fetch c_ctx34g02_013  into  ctx34g02_locacao.avivclgrp,
                                 ctx34g02_locacao.frqvlr   ,
                                 ctx34g02_locacao.isnvlr
  whenever error stop

  let locacao = locacao clipped,
                '<LojaLocadora>',
                      '<CodigoLojaLocadora>',ctx34g02_locacao.aviestcod clipped,'</CodigoLojaLocadora>',
                      '<Locadora>',
                           '<CodigoLocadora>',ctx34g02_locacao.lcvcod clipped,'</CodigoLocadora>',
                      '</Locadora>',
                 '</LojaLocadora>',
                 '<FlagCalcaoCartao>',ctx34g02_locacao.loccautip,'</FlagCalcaoCartao>',
                 '<QuantidadeDia>',ctx34g02_locacao.aviprvent clipped,'</QuantidadeDia>',
                 '<ValorTaxaSegundoCondutor>',ctx34g02_locacao.cdtsegtaxvlr clipped,'</ValorTaxaSegundoCondutor>',
                 '<DescricaoVeiculoPreferencia><![CDATA[',param.vcldes  clipped,']]></DescricaoVeiculoPreferencia>',
                 '<CodigoGrupoVeiculo>',ctx34g02_locacao.avivclgrp clipped,'</CodigoGrupoVeiculo>',
                 '<ValorParticipacaoFranquia>',ctx34g02_locacao.frqvlr clipped,'</ValorParticipacaoFranquia>',
                 '<ValorTaxaIsencaoSinistro>',ctx34g02_locacao.isnvlr clipped,'</ValorTaxaIsencaoSinistro>',
                 '<Prorrogacoes />',
                 '<Condutores />'


     whenever error stop
  end if
     
  return locacao

end function


#------------------------------------------#
function ctx34g02_busca_endereco(param)
#------------------------------------------#
 define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define ctx34g02_endereco record
   c24endtip     like datmlcl.c24endtip   ,
   lclidttxt     like datmlcl.lclidttxt   ,
   lgdtip        like datmlcl.lgdtip      ,
   lgdnom        like datmlcl.lgdnom      ,
   lgdnum        like datmlcl.lgdnum      ,
   lclbrrnom     like datmlcl.lclbrrnom   ,
   brrnom        like datmlcl.brrnom      ,
   cidnom        like datmlcl.cidnom      ,
   ufdcod        like datmlcl.ufdcod      ,
   lclrefptotxt  like datmlcl.lclrefptotxt,
   lgdcep        like datmlcl.lgdcep      ,
   lgdcepcmp     like datmlcl.lgdcepcmp   ,
   c24lclpdrcod  like datmlcl.c24lclpdrcod,
   dddcod        like datmlcl.dddcod      ,
   lcltelnum     like datmlcl.lcltelnum   ,
   lclcttnom     like datmlcl.lclcttnom   ,
   lclltt        like datmlcl.lclltt      ,
   lcllgt        like datmlcl.lcllgt      ,
   endcmp        like datmlcl.endcmp      ,
   celteldddcod  like datmlcl.celteldddcod,
   celtelnum     like datmlcl.celtelnum   ,
   cmlteldddcod  like datmlcl.cmlteldddcod,
   cmltelnum     like datmlcl.cmltelnum   ,
   mpacidcod     like datkmpacid.mpacidcod
 end record

 define endereco char(6000),
        telefone char(6000),
        priorizacao char(6000),
        l_atdsrvorg like datmservico.atdsrvorg,
        l_dddcod smallint
 
 # Rodolfo Massini - Alteracao Carro Extra - Inicio
 define lr_retorno   record
        resultado    smallint,  # (0) = Ok   (1) = Not Found   (2) = Erro de acesso
        mensagem     char(100),
        cidcod       like glakcid.cidcod
 end record
 
 define l_nomcid     like datmlcl.cidnom
 define l_totcid     smallint

  initialize lr_retorno.* to null
 # Rodolfo Massini - Alteracao Carro Extra - Fim
 
  initialize ctx34g02_endereco.* to null
  initialize l_nomcid to null
  initialize l_totcid to null
  let endereco = ''
  let telefone = ''
  let priorizacao = ''
  let l_dddcod = 0

 select atdsrvorg
   into l_atdsrvorg
  from datmservico
   where atdsrvnum = param.atdsrvnum
  and  atdsrvano = param.atdsrvano

 whenever error continue
    open c_ctx34g02_015 using param.atdsrvnum,
                              param.atdsrvano
    foreach c_ctx34g02_015  into ctx34g02_endereco.c24endtip   ,
                                 ctx34g02_endereco.lclidttxt   ,
                                 ctx34g02_endereco.lgdtip      ,
                                 ctx34g02_endereco.lgdnom      ,
                                 ctx34g02_endereco.lgdnum      ,
                                 ctx34g02_endereco.lclbrrnom   ,
                                 ctx34g02_endereco.brrnom      ,
                                 ctx34g02_endereco.cidnom      ,
                                 ctx34g02_endereco.ufdcod      ,
                                 ctx34g02_endereco.lclrefptotxt,
                                 ctx34g02_endereco.lgdcep      ,
                                 ctx34g02_endereco.lgdcepcmp   ,
                                 ctx34g02_endereco.c24lclpdrcod,
                                 ctx34g02_endereco.dddcod      ,
                                 ctx34g02_endereco.lcltelnum   ,
                                 ctx34g02_endereco.lclcttnom   ,
                                 ctx34g02_endereco.lclltt      ,
                                 ctx34g02_endereco.lcllgt      ,
                                 ctx34g02_endereco.endcmp      ,
                                 ctx34g02_endereco.celteldddcod,
                                 ctx34g02_endereco.celtelnum   ,
                                 ctx34g02_endereco.cmlteldddcod,
                                 ctx34g02_endereco.cmltelnum   ,
                                 ctx34g02_endereco.mpacidcod
                                 
    # Ajusta nome da cidade
    let l_nomcid = ctx34g02_endereco.cidnom clipped, '%'
    open  c_ctx34g02_034 using ctx34g02_endereco.ufdcod,
                               l_nomcid
    fetch c_ctx34g02_034 into l_totcid

    if l_totcid = 1 then    
       open  c_ctx34g02_035 using ctx34g02_endereco.ufdcod,
                                l_nomcid
       fetch c_ctx34g02_035 into ctx34g02_endereco.cidnom, ctx34g02_endereco.mpacidcod
       close c_ctx34g02_035
    end if
    close c_ctx34g02_034

      let telefone = '<Telefones>'
      if ctx34g02_endereco.lcltelnum is not null or ctx34g02_endereco.lcltelnum <> ' ' then
         let l_dddcod = ctx34g02_endereco.dddcod
         let telefone = telefone clipped,'<Telefone>',
                                   '<CodigoDDD>', l_dddcod using "<<<&", '</CodigoDDD>',
                                   '<NumeroTelefone>',ctx34g02_endereco.lcltelnum using "<<<<<<<<<&",'</NumeroTelefone>',
                                   '<NomeContato><![CDATA[',ctx34g02_endereco.lclcttnom clipped,']]></NomeContato>',
                                   '<TipoTelefone>1</TipoTelefone>',
                                 '</Telefone>'
      end if

      if ctx34g02_endereco.celtelnum is not null or ctx34g02_endereco.celtelnum <> ' ' then
         let l_dddcod = ctx34g02_endereco.celteldddcod
         let telefone = telefone clipped,'<Telefone>',
                                   '<CodigoDDD>', l_dddcod using "<<<&", '</CodigoDDD>',
                                   '<NumeroTelefone>',ctx34g02_endereco.celtelnum using "<<<<<<<<<&",'</NumeroTelefone>',
                                   '<NomeContato><![CDATA[',ctx34g02_endereco.lclcttnom clipped,']]></NomeContato>',
                                   '<TipoTelefone>3</TipoTelefone>',
                                 '</Telefone>'
      end if

      if ctx34g02_endereco.cmltelnum is not null or ctx34g02_endereco.cmltelnum <> ' ' then
         let l_dddcod = ctx34g02_endereco.cmlteldddcod
         let telefone = telefone clipped,'<Telefone>',
                                   '<CodigoDDD>', l_dddcod using "<<<&", '</CodigoDDD>',
                                   '<NumeroTelefone>',ctx34g02_endereco.cmltelnum using "<<<<<<<<<&",'</NumeroTelefone>',
                                   '<NomeContato><![CDATA[',ctx34g02_endereco.lclcttnom clipped,']]></NomeContato>',
                                   '<TipoTelefone>1</TipoTelefone>',
                                 '</Telefone>'
      end if

      let telefone = telefone clipped, '</Telefones>'

      let endereco = endereco clipped ,'<ServicoEndereco>',
                                  '<TipoEndereco>',ctx34g02_endereco.c24endtip using "<&",'</TipoEndereco>',
              		          '<Endereco>',
                   	             '<DescricaoLocal><![CDATA[',ctx34g02_endereco.lclidttxt clipped,']]></DescricaoLocal>',
                   	             '<NomeLogradouro>',ctx34g02_endereco.lgdtip clipped," ", ctx34g02_endereco.lgdnom clipped,'</NomeLogradouro>',
                   	             '<NumeroLogradouro>',ctx34g02_endereco.lgdnum clipped,'</NumeroLogradouro>',
                   	             '<NomeSubBairro><![CDATA[',ctx34g02_endereco.lclbrrnom clipped,']]></NomeSubBairro>',
                   	             '<NomeBairro><![CDATA[',ctx34g02_endereco.brrnom clipped,']]></NomeBairro>',
                   	             '<Cidade>',
                                        '<CodigoCidade>',ctx34g02_endereco.mpacidcod using "<<<<<&",'</CodigoCidade>',
                                        '<SiglaUF>',ctx34g02_endereco.ufdcod clipped,'</SiglaUF>',
                                        '<NomeCidade>',ctx34g02_endereco.cidnom clipped,'</NomeCidade>',
                                     '</Cidade>',
                   	             '<DescricaoPontoReferencia><![CDATA[',ctx34g02_endereco.lclrefptotxt clipped,']]></DescricaoPontoReferencia>',
                   	             '<CodigoCEP>',ctx34g02_endereco.lgdcep using "&&&&&",ctx34g02_endereco.lgdcepcmp using "&&&",'</CodigoCEP>',
                   	             '<DescricaoEnderecoComplemento><![CDATA[',ctx34g02_endereco.endcmp clipped,']]></DescricaoEnderecoComplemento>',
                	             '<TipoIndexacao>',ctx34g02_endereco.c24lclpdrcod using "<&",'</TipoIndexacao>',
                    	             '<NumeroLatitude>',ctx34g02_endereco.lclltt clipped,'</NumeroLatitude>',
               	                     '<NumeroLongitude>',ctx34g02_endereco.lcllgt clipped,'</NumeroLongitude>',
               	                     telefone clipped,
               	                  '</Endereco>',
              		       '</ServicoEndereco>'
    end foreach

    # ASSITENCIA A PASSAGEIRO AVIAO NAO GRAVA DESTINO NA TABELA DATMLCL
    open c_ctx34g02_030 using param.atdsrvnum,
                              param.atdsrvano
    fetch c_ctx34g02_030  into   ctx34g02_endereco.ufdcod      ,
                                 ctx34g02_endereco.cidnom      ,
                                 ctx34g02_endereco.mpacidcod   ,
                                 ctx34g02_endereco.lclltt      ,
                                 ctx34g02_endereco.lcllgt
                                 
    if sqlca.sqlcode = 0 then
      let endereco = endereco clipped ,
                         '<ServicoEndereco>',
                                  '<TipoEndereco>2</TipoEndereco>',
              		          '<Endereco>',
                   	             '<DescricaoLocal></DescricaoLocal>',
                   	             '<NomeLogradouro>AC</NomeLogradouro>',
                   	             '<NumeroLogradouro></NumeroLogradouro>',
                   	             '<NomeSubBairro>AC</NomeSubBairro>',
                   	             '<NomeBairro>AC</NomeBairro>',
                   	             '<Cidade>',
                                        '<CodigoCidade>',ctx34g02_endereco.mpacidcod using "<<<<<&",'</CodigoCidade>',
                                        '<SiglaUF>',ctx34g02_endereco.ufdcod clipped,'</SiglaUF>',
                                        '<NomeCidade>',ctx34g02_endereco.cidnom clipped,'</NomeCidade>',
                                     '</Cidade>',
                   	             '<DescricaoPontoReferencia></DescricaoPontoReferencia>',
                   	             '<CodigoCEP></CodigoCEP>',
                   	             '<DescricaoEnderecoComplemento></DescricaoEnderecoComplemento>',
                	               '<TipoIndexacao>1</TipoIndexacao>',
                    	             '<NumeroLatitude>',ctx34g02_endereco.lclltt clipped,'</NumeroLatitude>',
               	                   '<NumeroLongitude>',ctx34g02_endereco.lcllgt clipped,'</NumeroLongitude>',
         	                  '</Endereco>',
              		       '</ServicoEndereco>'

    end if
    close c_ctx34g02_030
    
    # Rodolfo Massini - Alteracao Carro Extra - Inicio
    # CARRO-EXTRA NAO GRAVA DESTINO NA TABELA DATMLCL
    open c_ctx34g02_031 using param.atdsrvnum,
                              param.atdsrvano
    fetch c_ctx34g02_031 into ctx34g02_endereco.ufdcod      ,
                              ctx34g02_endereco.cidnom      ,
                              ctx34g02_endereco.dddcod      ,
                              ctx34g02_endereco.lcltelnum   ,
                              ctx34g02_endereco.celteldddcod,
                              ctx34g02_endereco.celtelnum   
                                 
    if sqlca.sqlcode = 0 then
    

      if (ctx34g02_endereco.ufdcod is not null and ctx34g02_endereco.ufdcod <> ' ') and
         (ctx34g02_endereco.cidnom is not null and ctx34g02_endereco.cidnom <> ' ') then
           
          call cty10g00_obter_cidcod(ctx34g02_endereco.cidnom
                                    ,ctx34g02_endereco.ufdcod)
                           returning lr_retorno.resultado
                                    ,lr_retorno.mensagem
                                    ,lr_retorno.cidcod
      else 
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = ''
          let lr_retorno.cidcod = 0
      end if
      
      let telefone = '<Telefones>'
      
      if ctx34g02_endereco.lcltelnum is not null or ctx34g02_endereco.lcltelnum <> ' ' then
         let l_dddcod = ctx34g02_endereco.dddcod
         let telefone = telefone clipped,'<Telefone>',
                                   '<CodigoDDD>', l_dddcod using "<<<&", '</CodigoDDD>',
                                   '<NumeroTelefone>',ctx34g02_endereco.lcltelnum using "<<<<<<<<<&",'</NumeroTelefone>',
                                   '<NomeContato></NomeContato>',
                                   '<TipoTelefone>1</TipoTelefone>',
                                 '</Telefone>'
      end if

      if ctx34g02_endereco.celtelnum is not null or ctx34g02_endereco.celtelnum <> ' ' then
         let l_dddcod = ctx34g02_endereco.celteldddcod
         let telefone = telefone clipped,'<Telefone>',
                                   '<CodigoDDD>', l_dddcod using "<<<&", '</CodigoDDD>',
                                   '<NumeroTelefone>',ctx34g02_endereco.celtelnum using "<<<<<<<<<&",'</NumeroTelefone>',
                                   '<NomeContato></NomeContato>',
                                   '<TipoTelefone>3</TipoTelefone>',
                                 '</Telefone>'
      end if
      
      let telefone = telefone clipped, '</Telefones>'
            
      let endereco = endereco clipped ,
                         '<ServicoEndereco>',
                                  '<TipoEndereco>1</TipoEndereco>',
              		          '<Endereco>',
                   	             '<DescricaoLocal></DescricaoLocal>',
                   	             '<NomeLogradouro>AC</NomeLogradouro>',
                   	             '<NumeroLogradouro></NumeroLogradouro>',
                   	             '<NomeSubBairro>AC</NomeSubBairro>',
                   	             '<NomeBairro>AC</NomeBairro>',
                   	               '<Cidade>'
                                        
                                        if (lr_retorno.cidcod is not null and lr_retorno.cidcod <> 0) then
                                          let endereco = endereco clipped,
                                          '<CodigoCidade>',lr_retorno.cidcod using "<<<<<<<<",'</CodigoCidade>'
                                        else
                                          let endereco = endereco clipped,
                                          '<CodigoCidade></CodigoCidade>'
                                        end if
                                        
                                        let endereco = endereco clipped,
                                        '<SiglaUF>',ctx34g02_endereco.ufdcod clipped,'</SiglaUF>',
                                        '<NomeCidade>',ctx34g02_endereco.cidnom clipped,'</NomeCidade>',
                                   '</Cidade>',
                   	             '<DescricaoPontoReferencia></DescricaoPontoReferencia>',
                   	             '<CodigoCEP></CodigoCEP>',
                   	             '<DescricaoEnderecoComplemento></DescricaoEnderecoComplemento>',
                	             '<TipoIndexacao></TipoIndexacao>',
                    	        '<NumeroLatitude></NumeroLatitude>',
               	             '<NumeroLongitude></NumeroLongitude>',
               	             telefone clipped,
         	                  '</Endereco>',
              		       '</ServicoEndereco>'

    end if
    close c_ctx34g02_031   

  # Rodolfo Massini - Alteracao Carro Extra - Fim
  
  whenever error stop
  
  return endereco

end function

#------------------------------------------#
function ctx34g02_busca_passageiros(param)
#------------------------------------------#
 define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define ctx34g02_passageiros record
   passeq like datmpassageiro.passeq,
   pasnom like datmpassageiro.pasnom,
   pasidd like datmpassageiro.pasidd
 end record

 define passageiro char(6000)

  initialize ctx34g02_passageiros.* to null
  let passageiro = ''

 whenever error continue
    open c_ctx34g02_016 using param.atdsrvnum,
                              param.atdsrvano
    foreach c_ctx34g02_016  into ctx34g02_passageiros.passeq,
                                 ctx34g02_passageiros.pasnom,
                                 ctx34g02_passageiros.pasidd

        let passageiro = passageiro clipped,'<ServicoPessoa>',
                         '<SequenciaServicoPessoa>',ctx34g02_passageiros.passeq clipped,'</SequenciaServicoPessoa>',
          		     '<NomePessoa><![CDATA[',ctx34g02_passageiros.pasnom clipped,']]></NomePessoa>',
          		     '<QuantidadeIdadePessoa>',ctx34g02_passageiros.pasidd clipped,'</QuantidadeIdadePessoa>',
          		 '</ServicoPessoa>'   
    	
    end foreach

  whenever error stop

  return passageiro

end function


#------------------------------------------#
function ctx34g02_busca_priorizacao(param)
#------------------------------------------#
 define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define ctx34g02_priorizacao record
   atdrsdflg like datmservico.atdrsdflg,
   emeviacod like datmlcl.emeviacod,
   c24endtip like datmlcl.c24endtip
 end record

 define priorizacao char(6000)

  initialize ctx34g02_priorizacao.* to null
  let priorizacao = ''

 whenever error continue
    open c_ctx34g02_018 using param.atdsrvnum,
                              param.atdsrvano
    foreach c_ctx34g02_018  into ctx34g02_priorizacao.atdrsdflg,
                                 ctx34g02_priorizacao.emeviacod,
                                 ctx34g02_priorizacao.c24endtip

        #Verifica se o cliente está em local de risco
        if ctx34g02_priorizacao.emeviacod = 1 then         #Situação local de ocorrência
           let priorizacao = priorizacao clipped,
                          '<ServicoEventoPriorizacao>',
                              '<DataAtualizacao>',current,'</DataAtualizacao>',
                              '<EventoPrioridade>',
                                   '<CodigoEventoPrioridade>9</CodigoEventoPrioridade>', 
                              '</EventoPrioridade>',
                              '<SequenciaEvento>1</SequenciaEvento>',
                              '<UsuarioAtualizacao>',
                                   '<Matricula>999999</Matricula>',
                                   '<TipoUsuario>F</TipoUsuario>',
                                   '<Empresa>1</Empresa>',
                              '</UsuarioAtualizacao>',
                          '</ServicoEventoPriorizacao>'
        end if

        if ctx34g02_priorizacao.atdrsdflg <> 'S' then
           let priorizacao = priorizacao clipped,
                          '<ServicoEventoPriorizacao>',
                              '<DataAtualizacao>',current,'</DataAtualizacao>',
                              '<EventoPrioridade>',
                                   '<CodigoEventoPrioridade>10</CodigoEventoPrioridade>',
                              '</EventoPrioridade>',
                              '<SequenciaEvento>2</SequenciaEvento>',
                              '<UsuarioAtualizacao>',
                                   '<Matricula>999999</Matricula>',
                                   '<TipoUsuario>F</TipoUsuario>',
                                   '<Empresa>1</Empresa>',
                              '</UsuarioAtualizacao>',
                          '</ServicoEventoPriorizacao>'
        end if
    end foreach

  whenever error stop

  return priorizacao

end function


#------------------------------------------#
function ctx34g02_busca_transporte(param)
#------------------------------------------#
 define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define ctx34g02_transporte record
   bagflg    like datmassistpassag.bagflg   ,
   trppfrdat like datmassistpassag.trppfrdat,
   trppfrhor like datmassistpassag.trppfrhor,
   refatdsrvnum  like datmassistpassag.refatdsrvnum,
   refatdsrvano  like datmassistpassag.refatdsrvano,
   asimtvdes like datkasimtv.asimtvdes
 end record

 define transporte char(6000)

  initialize ctx34g02_transporte.* to null
  let transporte = ''

 whenever error continue
    open c_ctx34g02_019 using param.atdsrvnum,
                              param.atdsrvano
    foreach c_ctx34g02_019  into ctx34g02_transporte.bagflg,
                                 ctx34g02_transporte.trppfrdat,
                                 ctx34g02_transporte.trppfrhor,
                                 ctx34g02_transporte.refatdsrvnum,
                                 ctx34g02_transporte.refatdsrvano,
                                 ctx34g02_transporte.asimtvdes

        if ctx34g02_transporte.bagflg = 'S' then
          let transporte = transporte clipped,
              '<QuantidadeBagagem>1</QuantidadeBagagem>'
        end if

        let transporte = transporte clipped,
            '<DataViagem>',ctx34g02_transporte.trppfrdat clipped,' ',ctx34g02_transporte.trppfrhor clipped,'</DataViagem>'

    end foreach

  whenever error stop

  return transporte

end function


#------------------------------------------#
function ctx34g02_busca_retorno(param)
#------------------------------------------#
 define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define ctx34g02_retorno record
    atdorgsrvnum   like datmsrvre.atdorgsrvnum,
    atdorgsrvano   like datmsrvre.atdorgsrvano,
    atdsrvorg      like datmservico.atdsrvorg,
    c24astcod      like datmligacao.c24astcod,
    retprsmsmflg   like datmsrvre.retprsmsmflg,
    srvretmtvcod   like datmsrvre.srvretmtvcod
 end record

 define retorno char(6000),
        mesmoprs smallint

  initialize ctx34g02_retorno.* to null
  let retorno = ''

 whenever error continue
    open c_ctx34g02_021 using param.atdsrvnum,
                              param.atdsrvano
    fetch c_ctx34g02_021  into ctx34g02_retorno.atdorgsrvnum,
                               ctx34g02_retorno.atdorgsrvano,
                               ctx34g02_retorno.c24astcod,
                               ctx34g02_retorno.atdsrvorg,
                               ctx34g02_retorno.retprsmsmflg,
                               ctx34g02_retorno.srvretmtvcod
    if sqlca.sqlcode = 0 then
      if ctx34g02_retorno.atdorgsrvnum is not null then
            if ctx34g02_retorno.retprsmsmflg = 'S' then
               let mesmoprs = 1
            else
               let mesmoprs = 2
            end if

            # ENVIA O SERVICO ORIGINAL PRIMEIRO
            call ctx34g02_apos_grvservico(ctx34g02_retorno.atdorgsrvnum,
                                          ctx34g02_retorno.atdorgsrvano)

            let retorno = retorno clipped,
                	'<ServicoOriginal>',
		                '<Central>',
		                    '<CodigoOrigemServico>',ctx34g02_retorno.atdsrvorg clipped,'</CodigoOrigemServico>',
		                    '<NumeroServicoAtendimento>',ctx34g02_retorno.atdorgsrvnum,'</NumeroServicoAtendimento>',
		                    '<AnoServicoAtendimento>',ctx34g02_retorno.atdorgsrvano,'</AnoServicoAtendimento>',
		                    '<CodigoAssuntoCentral>',ctx34g02_retorno.c24astcod clipped,'</CodigoAssuntoCentral>',
		               '</Central>',
	               '</ServicoOriginal>',
	               '<MotivoRetorno>',
	                    '<CodigoMotivoRetorno>',ctx34g02_retorno.srvretmtvcod clipped,'</CodigoMotivoRetorno>',
	               '</MotivoRetorno>',
	               '<FlagAcionaMesmoPrestador>', mesmoprs, '</FlagAcionaMesmoPrestador>'
      end if
    end if
    close c_ctx34g02_021

  whenever error stop

  return retorno

end function


#------------------------------------------#
function ctx34g02_busca_LaudoMultiplo(param)
#------------------------------------------#
 define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define ctx34g02_LaudoMultiplo record
    atdmltsrvnum    like datratdmltsrv.atdmltsrvnum,
    atdmltsrvano    like datratdmltsrv.atdmltsrvano,
    atdsrvorg       like datmservico.atdsrvorg,
    c24astcod		    like datmligacao.c24astcod
 end record

 define LaudoMultiplo char(6000)

  initialize ctx34g02_LaudoMultiplo.* to null
  let LaudoMultiplo = ''

 whenever error continue
    open c_ctx34g02_022 using param.atdsrvnum,
                              param.atdsrvano
    fetch c_ctx34g02_022  into ctx34g02_LaudoMultiplo.atdmltsrvnum,
                               ctx34g02_LaudoMultiplo.atdmltsrvano,
                               ctx34g02_LaudoMultiplo.atdsrvorg,
                               ctx34g02_LaudoMultiplo.c24astcod
    if sqlca.sqlcode = 0 then
      # ENVIA O SERVICO MULTIPLO PRIMEIRO
      call ctx34g02_apos_grvservico(ctx34g02_LaudoMultiplo.atdmltsrvnum,
                                    ctx34g02_LaudoMultiplo.atdmltsrvano)

      let LaudoMultiplo = LaudoMultiplo clipped,
		                '<Central>',
		                    '<CodigoOrigemServico>',ctx34g02_LaudoMultiplo.atdsrvorg clipped,'</CodigoOrigemServico>',
		                    '<NumeroServicoAtendimento>',ctx34g02_LaudoMultiplo.atdmltsrvnum clipped,'</NumeroServicoAtendimento>',
		                    '<AnoServicoAtendimento>',ctx34g02_LaudoMultiplo.atdmltsrvano clipped,'</AnoServicoAtendimento>',
		                    '<CodigoAssuntoCentral>',ctx34g02_LaudoMultiplo.c24astcod clipped,'</CodigoAssuntoCentral>',
		               '</Central>'

     end if

  whenever error stop

  return LaudoMultiplo

end function

#------------------------------------------#
function ctx34g02_busca_servicoAuxiliar(param)
#------------------------------------------#
 define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define ctx34g02_servicoAuxiliar record
    atdsrvorg       like datmservico.atdsrvorg,
    asitipcod	    like datmservico.asitipcod,
    socntzcod	    like datksocntz.socntzcod,
    espcod          like datmsrvre.espcod
 end record

 define servicoAuxiliar char(6000)

  initialize ctx34g02_servicoAuxiliar.* to null
  let servicoAuxiliar = ''
  
  
 whenever error continue
    open c_ctx34g02_023 using param.atdsrvnum,
                              param.atdsrvano
    foreach c_ctx34g02_023  into ctx34g02_servicoAuxiliar.atdsrvorg,
                                 ctx34g02_servicoAuxiliar.asitipcod,
                                 ctx34g02_servicoAuxiliar.socntzcod,
                                 ctx34g02_servicoAuxiliar.espcod

      if ctx34g02_servicoAuxiliar.espcod is null then
         let ctx34g02_servicoAuxiliar.espcod = 0
      end if

      let servicoAuxiliar = servicoAuxiliar clipped,
                       '<OrigemServico>',ctx34g02_servicoAuxiliar.atdsrvorg using "<<&", '</OrigemServico>',
                       '<CodigoTipoAssistencia>',ctx34g02_servicoAuxiliar.asitipcod using "<<<&", '</CodigoTipoAssistencia>',
                       '<CodigoNatureza>',ctx34g02_servicoAuxiliar.socntzcod using "<<<&", '</CodigoNatureza>',
                       '<CodigoSubnatureza>',ctx34g02_servicoAuxiliar.espcod using "<<&", '</CodigoSubnatureza>'

     end foreach
  whenever error stop

  return servicoAuxiliar

end function


#------------------------------------------#
function ctx34g02_busca_observacoes(param)
#------------------------------------------#
 define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define observacoes char(8000)

 define lr_retorno record
     pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
     socqlmqtd     like datkitaasipln.socqlmqtd    ,
     erro          integer,
     mensagem      char(50)
 end record

 define  l_rptvclsitdsmflg   like datmrpt.rptvclsitdsmflg,
         l_rptvclsitestflg   like datmrpt.rptvclsitestflg,
         l_dddcod            like datmrpt.dddcod,
         l_telnum            like datmrpt.telnum

 define l_ris smallint,
        l_ciaempcod like datmservico.ciaempcod,
        l_rmcacpflg like datmservicocmp.rmcacpflg,
        l_succod    like datrservapol.succod,
        l_ramcod    like datrservapol.ramcod,
        l_aplnumdig like datrservapol.aplnumdig,
        l_itmnumdig like datrservapol.itmnumdig,
        l_edsnumref like datrservapol.edsnumref,
        l_km        char(10),
        l_qtd       char(10),
        l_kmint     integer,
        l_resultado   smallint,
        l_mensagem    char(100),
        l_param       char(50),
        l_doc_handle  integer,
        l_atdsrvorg  like datmservico.atdsrvorg,
        l_libcrpflgchar char(3),
        l_velflgchar char(3),
        l_jzgflgchar char(3),
        l_rptvclsitdsmflgchar char(3),
     	l_rptvclsitestflgchar char(3),
     	l_sinvitflgchar char(3),
 	l_vcllibflgchar char(3)

 define l_flcnom	   like datmfnrsrv.flcnom
	,l_obtdat	   like datmfnrsrv.obtdat
	,l_mrtcaucod       like datmfnrsrv.mrtcaucod
	,l_libcrpflg       like datmfnrsrv.libcrpflg
	,l_segdclprngracod like datmfnrsrv.segdclprngracod
	,l_flcalt          like datmfnrsrv.flcalt
	,l_flcpso          like datmfnrsrv.flcpso
	,l_velflg          like datmfnrsrv.velflg
	,l_fnrtip          like datmfnrsrv.fnrtip
	,l_jzgflg          like datmfnrsrv.jzgflg
	,l_frnasivlr       like datmfnrsrv.frnasivlr
 	,l_cttteltxt 	   like datmfnrsrv.cttteltxt
 	,l_crpretlclcod	   like datmfnrsrv.crpretlclcod
 	,l_segdclprngrades like iddkdominio.cpodes
 	,l_fnrtipdes 	   like iddkdominio.cpodes
 	,l_mrtcaudes       like iddkdominio.cpodes
 	,l_crpretlcldes	   like iddkdominio.cpodes
 	,l_sindat          like datmservicocmp.sindat
 	,l_sinhor          like datmservicocmp.sinhor
 	,l_sinvitflg       like datmservicocmp.sinvitflg
 	,l_bocflg          like datmservicocmp.bocflg
 	,l_bocnum	   like datmservicocmp.bocnum
	,l_bocemi	   like datmservicocmp.bocemi
	,l_vcllibflg	   like datmservicocmp.vcllibflg


 define l_socntzcod like datmsrvre.socntzcod
 define l_limpecas  char(300)

 define lr_hd record
     codigo smallint,
     texto  char(140)
 end record
 
 define lr_cty28g00 record
    senha    char(04)
   ,coderro  smallint
   ,msgerro  char(40) 
 end record
  
 let observacoes = ''

 initialize l_bocnum to null
 initialize l_ciaempcod to null
 initialize l_rmcacpflg to null
 initialize l_atdsrvorg to null
 initialize l_sindat to null
 initialize l_sinhor to null
 initialize l_sinvitflg to null
 initialize l_bocflg to null
 initialize l_bocnum to null
 initialize l_bocemi to null
 initialize l_vcllibflg to null
 initialize l_socntzcod to null
 initialize l_limpecas  to null
 initialize lr_hd to null
 
 ## Obtem dados do servico
 select ciaempcod,
        rmcacpflg,
        atdsrvorg,
        datmservicocmp.sindat,
        datmservicocmp.sinhor,
        datmservicocmp.sinvitflg,
        datmservicocmp.bocflg,
        datmservicocmp.bocnum,
        datmservicocmp.bocemi,
        datmservicocmp.vcllibflg
        into l_ciaempcod,
             l_rmcacpflg,
             l_atdsrvorg,
             l_sindat,
             l_sinhor,
             l_sinvitflg,
             l_bocflg,
             l_bocnum,
             l_bocemi,
             l_vcllibflg
   from datmservico, OUTER datmservicocmp
  where datmservico.atdsrvnum = datmservicocmp.atdsrvnum
    and datmservico.atdsrvano = datmservicocmp.atdsrvano
    and datmservico.atdsrvnum = param.atdsrvnum
    and datmservico.atdsrvano = param.atdsrvano

### ## VERIFICA SE SOLICITA PREENCHIMENTO DE RIS
### call ctb28g00_com_ris(param.atdsrvnum,
###                       param.atdsrvano,
###                       "WEB")
###      returning l_ris
### if l_ris then
###    let observacoes = observacoes clipped,
###                        '<ServicoObservacaoAcionamento>',
###                            '<CodigoServico>',param.atdsrvnum clipped,'</CodigoServico>',
###                            '<SequenciaObservacaoAcionamento>1</SequenciaObservacaoAcionamento>',
###                            '<DescricaoObservacaoAcionamento><![CDATA[SERVICO COMPREENCHIMENTO DE RIS]]></DescricaoObservacaoAcionamento>',
###                        '</ServicoObservacaoAcionamento>'
### end if

 ## VERIFICA SE O CLIENTE ACOMPANHA REMOCAO
 if l_rmcacpflg = "S" then
    let observacoes = observacoes clipped,
                        '<ServicoObservacaoAcionamento>',
                            '<SequenciaObservacaoAcionamento>2</SequenciaObservacaoAcionamento>',
                            '<DescricaoObservacaoAcionamento><![CDATA[CLIENTE ACOMPANHA REMOCAO]]></DescricaoObservacaoAcionamento>',
                        '</ServicoObservacaoAcionamento>'
 end if


 ## LIMITACAO POR KM
 case l_ciaempcod
    when 35
          select succod,
                 ramcod,
                 aplnumdig,
                 itmnumdig,
                 edsnumref
                 into l_succod,
                      l_ramcod,
                      l_aplnumdig,
                      l_itmnumdig,
                      l_edsnumref
           from datrservapol
          where atdsrvnum = param.atdsrvnum
            and atdsrvano = param.atdsrvano

          if l_aplnumdig is not null then
              call cts42g00_doc_handle(l_succod, l_ramcod,
                                       l_aplnumdig, l_itmnumdig,
                                       l_edsnumref)
                   returning l_resultado, l_mensagem, l_doc_handle

              ---> Busca Limites da Azul
              call cts49g00_clausulas(l_doc_handle)
                   returning l_km, l_qtd

              let l_kmint = l_km
              let l_kmint = l_kmint * 2

              let observacoes = observacoes clipped,
                        '<ServicoObservacaoAcionamento>',
                            '<SequenciaObservacaoAcionamento>3</SequenciaObservacaoAcionamento>',
                            '<DescricaoObservacaoAcionamento><![CDATA[EM CASO DE VIAGEM AUTORIZADA PELA CT, LIMITE DE ', l_kmint using '<<<#', 'KM TOTAIS. COBRAR KM EXCEDENTE DO SEGURADO]]></DescricaoObservacaoAcionamento>',
                        '</ServicoObservacaoAcionamento>'
          end if

    when 84
          open c_ctx34g02_024 using param.atdsrvnum, param.atdsrvano
          whenever error continue
          fetch c_ctx34g02_024 into g_documento.ramcod,
                                    g_documento.aplnumdig,
                                    g_documento.itmnumdig,
                                    g_documento.edsnumref,
                                    g_documento.itaciacod

          close c_ctx34g02_024
          whenever error stop

          if g_documento.ramcod = 531 or g_documento.ramcod = 31 then
                call cty22g00_rec_dados_itau(g_documento.itaciacod,
		          	               g_documento.ramcod   ,
		             	               g_documento.aplnumdig,
		                       g_documento.edsnumref,
		                       g_documento.itmnumdig)
	             returning lr_retorno.erro,
	                       lr_retorno.mensagem

	              if lr_retorno.erro = 0 then

	                  call cty22g00_rec_plano_assistencia(g_doc_itau[1].itaasiplncod)
                                       returning lr_retorno.pansoclmtqtd,
                                                 lr_retorno.socqlmqtd,
                                                 lr_retorno.erro,
                                                 lr_retorno.mensagem

	                  let l_kmint = lr_retorno.socqlmqtd
	                  let l_kmint = l_kmint * 2

                    let observacoes = observacoes clipped,
                               '<ServicoObservacaoAcionamento>',
                                   '<SequenciaObservacaoAcionamento>3</SequenciaObservacaoAcionamento>',
                                   '<DescricaoObservacaoAcionamento><![CDATA[EM CASO DE VIAGEM AUTORIZADA PELA CT, LIMITE DE ', l_kmint using '<<<#', 'KM TOTAIS. COBRAR KM EXCEDENTE DO SEGURADO]]></DescricaoObservacaoAcionamento>',
                               '</ServicoObservacaoAcionamento>'
	              end if

	        else

	           call cty25g01_rec_dados_itau (g_documento.itaciacod,
	                                         g_documento.ramcod   ,
	                                         g_documento.aplnumdig,
	                                         g_documento.edsnumref,
	                                         g_documento.itmnumdig)

	                returning lr_retorno.erro,
	                          lr_retorno.mensagem

	           if lr_retorno.erro = 0 then

	              let l_limpecas = cts29g00_texto_itau_limite_multiplo(param.atdsrvnum,param.atdsrvano)

	              if l_limpecas is not null then
	                 let observacoes = observacoes clipped,
                           '<ServicoObservacaoAcionamento>',
                               '<SequenciaObservacaoAcionamento>3</SequenciaObservacaoAcionamento>',
                               '<DescricaoObservacaoAcionamento><![CDATA[EM CASO DE FORNECIMENTO DE PECAS, COBRAR ** ATE ', l_limpecas clipped,' **.]]></DescricaoObservacaoAcionamento>',
                           '</ServicoObservacaoAcionamento>' ,
                           '<ServicoObservacaoAcionamento>',
                               '<SequenciaObservacaoAcionamento>4</SequenciaObservacaoAcionamento>',
                               '<DescricaoObservacaoAcionamento><![CDATA[ CASO HAJA EXCEDENTE ENTRAR EM CONTATO COM A CT]]></DescricaoObservacaoAcionamento>',
                           '</ServicoObservacaoAcionamento>'
	              end if

             end if
          end if
 end case

 case l_atdsrvorg
    when 18 ## VERIFICA SE E SAF PELA ORIGEM DO SERVIÇO - SERVICO ATENDIMENTO FUNERARIO
    	# PEGANDO O SERVICO ATENDIMENTO FUNERARIO
 	select  flcnom
		,obtdat
		,mrtcaucod
		,libcrpflg
		,segdclprngracod
		,flcalt
		,flcpso
		,velflg
		,fnrtip
		,jzgflg
		,frnasivlr
		,cttteltxt
	   into
		l_flcnom
		,l_obtdat
		,l_mrtcaucod
		,l_libcrpflg
		,l_segdclprngracod
		,l_flcalt
		,l_flcpso
		,l_velflg
		,l_fnrtip
		,l_jzgflg
		,l_frnasivlr
		,l_cttteltxt
	from datmfnrsrv
	WHERE atdsrvnum = param.atdsrvnum
              and atdsrvano = param.atdsrvano

	if sqlca.sqlcode != 0 THEN
		return observacoes
	ELSE
		#populando a descricao do campo 'causa da morte'
                let l_param = 'c24caumrt'
                open c_ctx34g02_027  using l_param,
                			   l_mrtcaucod
     			fetch c_ctx34g02_027 into l_mrtcaudes
  		close c_ctx34g02_027


  		#populando a descricao do campo 'parentesco com segurado'
                let l_param = 'datmfuneral'
                open c_ctx34g02_027  using l_param ,l_segdclprngracod
     			fetch c_ctx34g02_027 into l_segdclprngrades
  		close c_ctx34g02_027

  		#populando a descricao do campo 'tipo de funeral'
                let l_param = 'c24fnrtip'
                open c_ctx34g02_027  using l_param,l_fnrtip
     			fetch c_ctx34g02_027 into l_fnrtipdes
  		close c_ctx34g02_027

		#populando a descricao do campo 'Local retirada do corpo'
		let l_param = 'c24lclret'
                open c_ctx34g02_027  using l_param,l_fnrtip
     			fetch c_ctx34g02_027 into l_crpretlcldes
  		close c_ctx34g02_027

  		#l_libcrpflg - Corpo liberado
  		IF l_libcrpflg = 'S'THEN
	  	   LET l_libcrpflgchar='SIM'
	  	ELSE
  		   LET l_libcrpflgchar='NAO'
  		END IF

		#l_velflg - Havera velorio
		IF l_velflg = 'S' THEN
  		   LET l_velflgchar = 'SIM'
  		ELSE
  		   LET l_velflgchar = 'NAO'
  		END IF

  		#l_jzgflg - Possui jazigo
  		IF l_jzgflg THEN
  		   LET l_jzgflgchar = 'SIM'
  		ELSE
  		   LET l_jzgflgchar = 'NAO'
  		END IF

		let observacoes = observacoes clipped,
	               '<ServicoObservacaoAcionamento>',
	                   '<SequenciaObservacaoAcionamento>5</SequenciaObservacaoAcionamento>',
	                   '<DescricaoObservacaoAcionamento><![CDATA[',
	                   	'Falecido:',l_flcnom clipped, ', Data do Obito:',l_obtdat clipped,
	                   ']]></DescricaoObservacaoAcionamento>',
	               '</ServicoObservacaoAcionamento>'

		let observacoes = observacoes clipped,
	               '<ServicoObservacaoAcionamento>',
	                   '<SequenciaObservacaoAcionamento>6</SequenciaObservacaoAcionamento>',
	                   '<DescricaoObservacaoAcionamento><![CDATA[',
	                   	'Contato:',l_cttteltxt clipped, ', Local Retirada do Corpo:',l_crpretlcldes clipped,
	                   ']]></DescricaoObservacaoAcionamento>',
	               '</ServicoObservacaoAcionamento>'

		let observacoes = observacoes clipped,
	               '<ServicoObservacaoAcionamento>',
	                   '<SequenciaObservacaoAcionamento>7</SequenciaObservacaoAcionamento>',
	                   '<DescricaoObservacaoAcionamento><![CDATA[',
				'Causa da Morte:', l_mrtcaudes clipped, ', Corpo Liberado:', l_libcrpflgchar clipped,', Parentesco com o Segurado:', l_segdclprngrades clipped,
	                   ']]></DescricaoObservacaoAcionamento>',
	               '</ServicoObservacaoAcionamento>'

		let observacoes = observacoes clipped,
	               '<ServicoObservacaoAcionamento>',
	                   '<SequenciaObservacaoAcionamento>8</SequenciaObservacaoAcionamento>',
	                   '<DescricaoObservacaoAcionamento><![CDATA[',
				'Altura:', l_flcalt clipped, ', Peso:', l_flcpso clipped, ', Havera Velorio:', l_velflgchar clipped,
	                   ']]></DescricaoObservacaoAcionamento>',
	               '</ServicoObservacaoAcionamento>'

		let observacoes = observacoes clipped,
	               '<ServicoObservacaoAcionamento>',
	                   '<SequenciaObservacaoAcionamento>9</SequenciaObservacaoAcionamento>',
	                   '<DescricaoObservacaoAcionamento><![CDATA[',
				'Funeral:', l_fnrtipdes clipped, ', Possui Jazigo:', l_jzgflgchar clipped, ', Valor:', l_frnasivlr clipped,
	                   ']]></DescricaoObservacaoAcionamento>',
	               '</ServicoObservacaoAcionamento>'
	end if
	EXIT CASE
     when 5 #SERVICO DO TIPO RPT
     	#PEGANDO O SERVICO RPT

     	SELECT rptvclsitdsmflg
     	       ,rptvclsitestflg
     	       ,dddcod
     	       ,telnum
     	 INTO
     	       l_rptvclsitdsmflg
     	       ,l_rptvclsitestflg
     	       ,l_dddcod
     	       ,l_telnum
     	 FROM datmrpt
     	   WHERE atdsrvnum = param.atdsrvnum
             AND atdsrvano = param.atdsrvano

	#l_rptvclsitdsmflg - Veiculo desmontado
  	IF l_rptvclsitdsmflg ='S' THEN
  	   LET l_rptvclsitdsmflgchar = 'SIM'
  	ELSE
  	   LET l_rptvclsitdsmflgchar = 'NAO'
  	END IF

  	#l_rptvclsitestflg - Estadia
  	IF l_rptvclsitestflg ='S' THEN
  	   LET l_rptvclsitestflgchar = 'SIM'
  	ELSE
  	   LET l_rptvclsitestflgchar = 'NAO'
  	END IF

        let observacoes = observacoes clipped,
	               '<ServicoObservacaoAcionamento>',
	                   '<SequenciaObservacaoAcionamento>5</SequenciaObservacaoAcionamento>',
	                   '<DescricaoObservacaoAcionamento><![CDATA[',
	                   	'Veiculo desmontado:',l_rptvclsitdsmflgchar clipped,', Estadia:',l_rptvclsitestflgchar clipped,', Tel. Solicitante:(',l_dddcod clipped,') ',l_telnum clipped,
	                   ']]></DescricaoObservacaoAcionamento>',
	               '</ServicoObservacaoAcionamento>'

     when 4
     	#Origem Guincho(GOR)

  	#l_vcllibflg - Flag veiculo liberado
  	IF l_vcllibflg ='S' THEN
  	   LET l_vcllibflgchar = 'SIM'
  	ELSE
  	   LET l_vcllibflgchar = 'NAO'
  	END IF

  	#l_sinvitflg - Vitima sinistro
  	IF l_sinvitflg ='S' THEN
  	   LET l_sinvitflgchar = 'SIM'
  	ELSE
  	   LET l_sinvitflgchar = 'NAO'
  	END IF

     	let observacoes = observacoes clipped,
                       '<ServicoObservacaoAcionamento>',
                           '<SequenciaObservacaoAcionamento>5</SequenciaObservacaoAcionamento>',
                           '<DescricaoObservacaoAcionamento><![CDATA[',
                           	'Sinistro: ',l_sindat clipped,'-',l_sinhor clipped,', Vitimas: ',l_sinvitflgchar clipped

        if l_bocflg ='S' then
           let observacoes = observacoes clipped,
           	', B.O: ',l_bocnum clipped, ', Emissor: ',l_bocemi clipped, ', Veiculo Liberado: ',l_vcllibflgchar clipped
        end if

        let observacoes = observacoes clipped,
                           ']]></DescricaoObservacaoAcionamento>',
                       '</ServicoObservacaoAcionamento>'

     when 9 # RE

      select socntzcod into l_socntzcod
        from datmsrvre
       where atdsrvnum = param.atdsrvnum
         and atdsrvano = param.atdsrvano

      if l_socntzcod = 45 then #   MANUT MICRO RESIDENCIA 
      	
         call ctf00m10_hst_prt(param.atdsrvnum,
                               param.atdsrvano)
              returning lr_hd.codigo,
                        lr_hd.texto

         if lr_hd.codigo = 0 then
            let observacoes = observacoes clipped,
                '<ServicoObservacaoAcionamento>',
                  '<SequenciaObservacaoAcionamento>10</SequenciaObservacaoAcionamento>',
                      '<DescricaoObservacaoAcionamento><![CDATA[',
                         lr_hd.texto  clipped,
                      ']]></DescricaoObservacaoAcionamento>',
                '</ServicoObservacaoAcionamento>'
         end if
      end if
      
 end case
 
 
   if l_atdsrvorg = 1  or 
      l_atdsrvorg = 2  or
      l_atdsrvorg = 4  or
      l_atdsrvorg = 6  or
      l_atdsrvorg = 7  or
      l_atdsrvorg = 9  or
      l_atdsrvorg = 12 or
      l_atdsrvorg = 13 then
          
          call cty28g00_consulta_senha(param.atdsrvnum, param.atdsrvano)
                returning  lr_cty28g00.senha,
                           lr_cty28g00.coderro,
                           lr_cty28g00.msgerro 
                           
          if  lr_cty28g00.coderro <> 0 then 
             error lr_cty28g00.msgerro clipped  
          else
             let observacoes = observacoes clipped,
                             '<ServicoObservacaoAcionamento>',
                               '<SequenciaObservacaoAcionamento>11</SequenciaObservacaoAcionamento>',
                                   '<DescricaoObservacaoAcionamento><![CDATA[Senha de Atendimento: ',
                                      lr_cty28g00.senha clipped,
                                   ']]></DescricaoObservacaoAcionamento>',
                             '</ServicoObservacaoAcionamento>'
          end if
          
   end if 

 return observacoes

end function


#---------------------------------------#
function ctx34g02_busca_principal(param)
#---------------------------------------#

 define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define ctx34g02_principal record
   bagflg        like datmassistpassag.bagflg,
   trppfrdat     like datmassistpassag.trppfrdat,
   trppfrhor     like datmassistpassag.trppfrhor,
   refatdsrvnum  like datmassistpassag.refatdsrvnum,
   refatdsrvano  like datmassistpassag.refatdsrvano,
   asimtvdes like datkasimtv.asimtvdes
 end record

 define principal char(6000)

 define ctx34g02_servico record
   atdlibdat     like datmservico.atdlibdat   ,
   atdlibhor     like datmservico.atdlibhor   ,
   atddatprg     like datmservico.atddatprg   ,
   atdhorprg     like datmservico.atdhorprg   ,
   atdhorpvt     like datmservico.atdhorpvt   ,
   ciaempcod     like datmservico.ciaempcod   ,
   c24opemat     like datmservico.c24opemat   ,
   c24opeempcod  like datmservico.c24opeempcod,
   c24opeusrtip  like datmservico.c24opeusrtip,
   atdsrvorg     like datmservico.atdsrvorg   ,
   atdsrvnum     like datmservico.atdsrvnum   ,
   atdsrvano     like datmservico.atdsrvano   ,
   atddfttxt     like datmservico.atddfttxt   ,
   cnldat        like datmservico.cnldat      ,
   nom           like datmservico.nom         ,
   atdsoltip     like datmservico.atdsoltip   ,
   c24solnom     like datmservico.c24solnom   ,
   asitipcod     like datmservico.asitipcod   ,
   atdrsdflg     like datmservico.atdrsdflg   ,
   vclcndlclcod  like datrcndlclsrv.vclcndlclcod ,
   vclcamtip     like datmservicocmp.vclcamtip,
   vclcrgpso     like datmservicocmp.vclcrgpso,
   funmat        like datmservico.funmat   ,
   empcod        like datmservico.empcod   ,
   usrtip        like datmservico.usrtip   ,
   atdfnlflg     like datmservico.atdfnlflg,
   atdetpcod     like datmservico.atdetpcod
  end record

  initialize ctx34g02_servico.* to null
  initialize ctx34g02_principal.* to null

  let principal = ''

  #-------------------------------------------------------------#
  # CURSOR PARA TRAZER TODOS OS DADOS DO SERVICO                #
  #-------------------------------------------------------------#
  open c_ctx34g02_001 using param.atdsrvnum,
                            param.atdsrvano

  fetch c_ctx34g02_001  into  ctx34g02_servico.atdlibdat    ,
                              ctx34g02_servico.atdlibhor    ,
                              ctx34g02_servico.atddatprg    ,
                              ctx34g02_servico.atdhorprg    ,
                              ctx34g02_servico.atdhorpvt    ,
                              ctx34g02_servico.ciaempcod    ,
                              ctx34g02_servico.c24opemat    ,
                              ctx34g02_servico.c24opeempcod ,
                              ctx34g02_servico.c24opeusrtip ,
                              ctx34g02_servico.atdsrvorg    ,
                              ctx34g02_servico.atdsrvnum    ,
                              ctx34g02_servico.atdsrvano    ,
                              ctx34g02_servico.atddfttxt    ,
                              ctx34g02_servico.cnldat       ,
                              ctx34g02_servico.nom          ,
                              ctx34g02_servico.atdsoltip    ,
                              ctx34g02_servico.c24solnom    ,
                              ctx34g02_servico.asitipcod    ,
                              ctx34g02_servico.atdrsdflg    ,
                              ctx34g02_servico.funmat       ,
                              ctx34g02_servico.empcod       ,
                              ctx34g02_servico.usrtip       ,
                              ctx34g02_servico.atdfnlflg    ,
                              ctx34g02_servico.atdetpcod

 whenever error STOP

 # Busca motivo da assitencia a passageiros
 IF ctx34g02_servico.atdsrvorg = 2 or
     ctx34g02_servico.atdsrvorg = 3 then
      open c_ctx34g02_019 using param.atdsrvnum,
                                param.atdsrvano
      fetch c_ctx34g02_019 into ctx34g02_principal.bagflg,
                                ctx34g02_principal.trppfrdat,
                                ctx34g02_principal.trppfrhor,
                                ctx34g02_principal.refatdsrvnum,
                                ctx34g02_principal.refatdsrvano,
                                ctx34g02_principal.asimtvdes
      close c_ctx34g02_019
  END if

  if ctx34g02_principal.refatdsrvnum is not null and ctx34g02_principal.refatdsrvnum <> param.atdsrvnum then

     # ENVIA O SERVICO PRINCIPAL PRIMEIRO
     call ctx34g02_apos_grvservico(ctx34g02_principal.refatdsrvnum,
                                   ctx34g02_principal.refatdsrvano)

     let principal = principal clipped,
	       '<ServicoOriginal>',
	           '<Central>',
	           	'<CodigoOrigemServico>',ctx34g02_servico.atdsrvorg,'</CodigoOrigemServico>',
			'<NumeroServicoAtendimento>',ctx34g02_principal.refatdsrvnum,'</NumeroServicoAtendimento>',
			'<AnoServicoAtendimento>',ctx34g02_principal.refatdsrvano,'</AnoServicoAtendimento>',
	           '</Central>',
	       '</ServicoOriginal>'
  end if

 return principal

end function


#------------------------------------------#
function ctx34g02_geraXML(param)
#------------------------------------------#

define param record
   servico         char(6000),
   veiculo         char(6000),
   hospedagem      char(6000),
   locacao         char(6000),
   endereco        char(6000),
   priorizacao     char(6000),
   passageiro      char(6000),
   transporte      char(6000),
   retorno         char(6000),
   LaudoMultiplo   char(6000),
   observacoes     char(6000),
   principal       char(6000),
   servicoAuxiliar char(6000),
   etapa           char(15000),
   historico       char(15000)
end record


define l_xml record
    request char(32766)
 end record
 
 initialize l_xml.request to null


let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                    '<REQUEST>',
                    '<SERVICO>ATUALIZACAO_SERVICO</SERVICO>',
                    '<OBJETOS>',
                       '<Servico>',param.servico clipped,
                          '<Hospedagem>',param.hospedagem clipped,'</Hospedagem>',
                          '<Reserva>',param.locacao clipped,'</Reserva>',
                          '<Enderecos>',param.endereco clipped,'</Enderecos>',
                          '<Pessoas>',param.passageiro clipped,'</Pessoas>',
                          '<Veiculo>',param.veiculo clipped,'</Veiculo>',
                          '<EventosPriorizacao>',param.priorizacao clipped,'</EventosPriorizacao>',
                          '<Transporte>',param.transporte clipped,'</Transporte>',
                          '<Principal>',param.principal clipped,'</Principal>',
                          '<Retorno>',param.retorno clipped,'</Retorno>',
                          '<ServicoPai>',param.LaudoMultiplo clipped,'</ServicoPai>',
                          '<ObservacaoAcionamento>',param.observacoes clipped,'</ObservacaoAcionamento>',
                          '<Etapas>',param.etapa clipped,'</Etapas>',
                          '<Historico>',param.historico clipped,'</Historico>',
                       '</Servico>',
                       '<Servico_Auxiliar>',param.servicoAuxiliar clipped,'</Servico_Auxiliar>',
                    '</OBJETOS>',
                    '</REQUEST>'

    return l_xml.request
end function


#######################################################
# Envia todos os servico ao novo acionamento
#######################################################
function ctx34g02_sincro_servico()

 define ws record
    atdsrvnum  like datmservico.atdsrvnum,
    atdsrvano  like datmservico.atdsrvano,
    atdsrvseq  like datmservico.atdsrvseq
 end record

 define i integer,
        l_c24txtseq integer,
        l_acninihor integer,
        l_acnfimhor integer,
        l_datahora  datetime year to fraction 
        
 initialize ws.* to null       

 # Obtem filtro para data/hora inicial de servico
 select grlinf into l_acninihor
   from datkgeral
  where grlchv = "PSOHORARADIOINI"
 if sqlca.sqlcode <> 0 then
    let l_acninihor = 24
 end if

 # Obtem filtro para data/hora final de servico
 select grlinf into l_acnfimhor
   from datkgeral
  where grlchv = "PSOHORARADIO"
 if sqlca.sqlcode <> 0 then
    let l_acnfimhor = 12
 end if

 let l_datahora = current
 display l_datahora, " - INICIO DO PROCESSO DE SINCRONIZACAO"

 declare c_ctx34g02_srv cursor for
    select datmservico.atdsrvnum,
           datmservico.atdsrvano,
           datmservico.atdsrvseq,
           srvprsacnhordat, atdetpcod
      from datmservico
     where datmservico.atdsrvorg in (select cpocod
                                       from iddkdominio
                                      where cponom = 'srvorg_aciona')
       and datmservico.atdfnlflg in ('N', 'A')
       and datmservico.atdetpcod not in (3,4,5,10)
       and datmservico.atdlibflg = 'S'
       and datmservico.ciaempcod in (1, 27, 35, 40, 43, 50, 84)
       and (srvprsacnhordat is null or (srvprsacnhordat > (current - l_acninihor units hour) or (ciaempcod = 40 and atdetpcod < 7) ) )
       and (srvprsacnhordat is null or (srvprsacnhordat < (current + l_acnfimhor units hour) ) )
     order by srvprsacnhordat, datmservico.atdsrvano, datmservico.atdsrvnum

 foreach c_ctx34g02_srv into ws.atdsrvnum,
                             ws.atdsrvano,
                             ws.atdsrvseq

    let l_datahora = current
    display l_datahora, " - Servico: ", ws.atdsrvnum using "&&&&&&&", "-", ws.atdsrvano using "&&"

    call ctx34g02_apos_grvservico(ws.atdsrvnum,
                                  ws.atdsrvano)

    let l_datahora = current
    display l_datahora, " - Servico carregado"

 end foreach

 let l_datahora = current
 display l_datahora, " - FIM DO PROCESSO DE SINCRONIZACAO"

end function

#######################################################
# Envia os servicos que nao existam no novo acionamento
#######################################################
function ctx34g02_valida_servico()

 define ws record
    atdsrvnum  like datmservico.atdsrvnum,
    atdsrvano  like datmservico.atdsrvano,
    atdsrvseq  like datmservico.atdsrvseq
 end record

 define l_xml record
    response char(10000),
    request  char(10000)
 end record

 define lr_retorno record
    cod_erro  smallint,
    mensagem  char(100)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint

 define i integer,
        l_c24txtseq integer,
        l_acninihor integer,
        l_acnfimhor integer,
        l_datahora  datetime year to fraction,
        l_cont      smallint

 initialize l_xml.* to null   
 initialize ws.* to null 

 # Cria tabela temporaria validar se o serviço ja enviado ao AW sem chamar o MQ novamente
 # Esta tabela não deve ser dropada, pois é acumulativa a tadas as chamadas da funcao
 whenever error continue
      create temp table tmp_ctx34g02_valsrv
         (atdsrvnum   dec (7,0),
          atdsrvano   dec (2,0)) with no log
          
      create unique index ind_ctx34g02_valsrv on tmp_ctx34g02_valsrv
              (atdsrvnum,atdsrvano)
              
 whenever error stop

 # Obtem filtro para data/hora inicial de servico
 select grlinf into l_acninihor
   from datkgeral
  where grlchv = "PSOHORARADIOINI"
 if sqlca.sqlcode <> 0 then
    let l_acninihor = 24
 end if

 # Obtem filtro para data/hora final de servico
 select grlinf into l_acnfimhor
   from datkgeral
  where grlchv = "PSOHORARADIOSIN"
 if sqlca.sqlcode <> 0 then
    let l_acnfimhor = 2
 end if

 let l_datahora = current
 display l_datahora, " - INICIO DO PROCESSO DE SINCRONIZACAO"

 declare c_ctx34g02_srvval cursor for
    select datmservico.atdsrvnum,
           datmservico.atdsrvano,
           datmservico.atdsrvseq,
           srvprsacnhordat, atdetpcod
      from datmservico
     where datmservico.atdsrvorg in (select cpocod
                                       from iddkdominio
                                      where cponom = 'srvorg_aciona')
       and datmservico.atdfnlflg in ('N', 'A')
       and datmservico.atdetpcod not in (3,4,5,10)
       and datmservico.atdlibflg = 'S'
       and datmservico.ciaempcod in (1, 27, 35, 40, 43, 50, 84)
       and (srvprsacnhordat is null or (srvprsacnhordat > (current - l_acninihor units hour) or (ciaempcod = 40 and atdetpcod < 7) ) )
       and (srvprsacnhordat is null or (srvprsacnhordat < (current + l_acnfimhor units hour) ) )
     order by srvprsacnhordat, datmservico.atdsrvano, datmservico.atdsrvnum

 let l_cont = 0
 foreach c_ctx34g02_srvval into ws.atdsrvnum,
                             ws.atdsrvano,
                             ws.atdsrvseq

    let l_datahora = current
    display l_datahora, " - Servico: ", ws.atdsrvnum using "&&&&&&&", "-", ws.atdsrvano using "&&"
    
    # Valida se o servico ja foi enviado ao AW em processamento anterior
    select 1
      from tmp_ctx34g02_valsrv
     where atdsrvnum = ws.atdsrvnum
       and atdsrvano = ws.atdsrvano
    if sqlca.sqlcode = 0 then
       let l_datahora = current
       display l_datahora, " - Ignorado: Já foi processado"
       continue foreach
    end if

    # Verifica se o servico ja esta no novo acionamento
    let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                        '<REQUEST><SERVICO>EXISTE_SERVICO</SERVICO><OBJETOS>',
                        '<ServicoCentral><NumeroServicoAtendimento>', ws.atdsrvnum, '</NumeroServicoAtendimento>',
                        '<AnoServicoAtendimento>', ws.atdsrvano, '</AnoServicoAtendimento></ServicoCentral>',
                        '</OBJETOS></REQUEST>'

    call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                     returning l_status,
                               l_msg,
                               l_xml.response

    if l_status <> 0 then
       call ctx34g02_email_erro(l_xml.request,
                                l_xml.response,
                                "ERRO NO MQ - ctx34g02_valida_servico",
                                l_msg)
       continue foreach
    else
       if l_xml.response like "%<retorno><codigo>1</codigo>%" then
          call ctx34g02_email_erro(l_xml.request,
                                   l_xml.response,
                                   "ERRO NO SERVICO - ctx34g02_valida_servico",
                                   "")
          continue foreach
       end if
    end if

    if l_xml.response like "%<retorno><codigo>0</codigo><mensagem>S</mensagem></retorno>%" then
       # Servico ja existe
       let l_datahora = current
       display l_datahora, " - Ja carregado"
       insert into tmp_ctx34g02_valsrv values (ws.atdsrvnum,ws.atdsrvano)
    else
       # Servico nao existe
       call ctx34g02_apos_grvservico(ws.atdsrvnum,
                                     ws.atdsrvano)

       let l_datahora = current
       display l_datahora, " - Servico carregado"

    end if
    
    # Espera 1 segunda a cada 4 requisição para nao sobrecarregar WS do AW
    let l_cont = l_cont + 1
    if l_cont >= 4 then
       sleep 1
       let l_cont = 0
    end if
    
 end foreach

 let l_datahora = current
 display l_datahora, " - FIM DO PROCESSO DE SINCRONIZACAO"

end function

#------------------------------------------#
function ctx34g02_bloq_desbloq(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
end record

 define l_xml record
    response char(10000),
    request  char(10000)
 end record

 define ws record
     c24opemat     like datmservico.c24opemat,
     c24opeempcod  like datmservico.c24opeempcod,
     c24opeusrtip  like datmservico.c24opeusrtip,
     atdfnlflg     like datmservico.atdfnlflg
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint

 initialize l_xml.* to null
 initialize ws.* to null

 if not m_ctx34g02_prep then
    call ctx34g02_prepare()
 end if

 if ctx34g00_NovoAcionamento() and ctx34g00_origem(param.atdsrvnum,param.atdsrvano) then

    open c_ctx34g02_025 using param.atdsrvnum,
                              param.atdsrvano
    fetch c_ctx34g02_025  into ws.c24opemat,
                               ws.c24opeempcod,
                               ws.c24opeusrtip,
                               ws.atdfnlflg
    close c_ctx34g02_025

    # Envia para AcionamentoWeb apenas bloqueios/desbloquio de serviço em aberto
    #                        ou desbloqueio de serviço acionado
    if (ws.atdfnlflg <> 'S') or
       (ws.atdfnlflg  = 'S'  and ws.c24opemat = 0 ) then

       if ws.c24opeusrtip is null or ws.c24opeusrtip = ' ' then
          let ws.c24opeusrtip = "F"
       end if

       if ws.c24opeempcod is null or ws.c24opeempcod = 0  then
          let ws.c24opeempcod = 1
       end if

       let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                           '<REQUEST>',
                           '  <SERVICO>ATUALIZACAO_BLOQUEIO_DESBLOQUEIO</SERVICO>',
                           '  <OBJETOS>',
                           '      <Usuario>',
                           '        <Matricula>', ws.c24opemat ,'</Matricula>',
                           '        <Empresa>', ws.c24opeempcod ,'</Empresa>',
                           '        <TipoUsuario>', ws.c24opeusrtip ,'</TipoUsuario>',
                           '      </Usuario>',
                           '      <ServicoCentral>',
                           '        <NumeroServicoAtendimento>', param.atdsrvnum ,'</NumeroServicoAtendimento>',
                           '        <AnoServicoAtendimento>',param.atdsrvano ,'</AnoServicoAtendimento>',
                           '      </ServicoCentral>',
                           '  </OBJETOS>',
                           '</REQUEST>'

       call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                        returning l_status,
                                  l_msg,
                                  l_xml.response

    end if
 end if

end function


#----------------------------------------#
function ctx34g02_andamento(param)
#----------------------------------------#
define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
end record

 define l_xml record
    response char(10000),
    request  char(10000)
 end record

 define l_retorno record
     srvidxflg char(1),
     recatddes char(50),
     srrnom    char(40),
     gpsatldat date,
     gpsatlhor datetime hour to second,
     recatdsgl char(3),
     lgdnom    char(50),
     lgdnum    integer,
     brrnom    char(30),
     cidnom    char(40),
     ufdsgl    char(2),
     lttnum    decimal(8,6),
     lgtnum    decimal(9,6),
     dstrot    integer,
     dstret    integer,
     tmprot    integer,
     telnumtxt char(20),
     nxtidt    char(20),
     nxtnumtxt char(20)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint
 define l_doc_handle integer

 define l_datahoratxt char(20)

    initialize l_retorno.* to null

    let l_doc_handle  =  null

    let l_datahoratxt = ''

    let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                        '<REQUEST>',
                            '<SERVICO>POSICAO_RECURSO</SERVICO>',
                            '<OBJETOS>',
                               '<ServicoCentral>',
                                  '<NumeroServicoAtendimento>', param.atdsrvnum, '</NumeroServicoAtendimento>',
                                  '<AnoServicoAtendimento>',  param.atdsrvano, '</AnoServicoAtendimento>',
                               '</ServicoCentral>',
                            '</OBJETOS>',
                        '</REQUEST>'

     call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                      returning l_status,
                                l_msg,
                                l_xml.response

     call figrc011_fim_parse()
     call figrc011_inicio_parse()
     let l_doc_handle  = figrc011_parse(l_xml.response)

     let l_retorno.srvidxflg = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/ServicoIndexado")
     let l_retorno.recatddes = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/DescricaoRecurso")
     let l_retorno.srrnom    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/NomeAbreviadoSocorrista")

     let l_datahoratxt       = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/DataPosicao")
     let l_retorno.gpsatldat = l_datahoratxt[1,10]
     let l_retorno.gpsatlhor = l_datahoratxt[12,20]

     let l_retorno.recatdsgl = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/SiglaAtividade")
     let l_retorno.lgdnom    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/NomeLogradouro")
     let l_retorno.lgdnum    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/NumeroLogradouro")
     let l_retorno.brrnom    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/NomeBairro")
     let l_retorno.cidnom    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/NomeCidade")
     let l_retorno.ufdsgl    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/SiglaUF")
     let l_retorno.lttnum    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/NumeroLatitude")
     let l_retorno.lgtnum    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/NumeroLongitude")
     let l_retorno.dstrot    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/QuantidadeDistanciaMetrosCalculada")
     let l_retorno.dstret    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/QuantidadeDistanciaMetrosLinhaReta")
     let l_retorno.tmprot    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/QuantidadeDistanciaMinutosCalculada")
     let l_retorno.telnumtxt = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/NumeroTelefoneCelular")
     let l_retorno.nxtidt    = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/NumeroIdentificacaoNextel")
     let l_retorno.nxtnumtxt = figrc011_xpath(l_doc_handle, "/retorno/mensagem/RecursoPosicao/NumeroTelefoneNextel")

     call figrc011_fim_parse()

     return l_retorno.*

end function

#-----------------------------------------------#
function ctx34g02_validaservicoimediato(lr_param)
#-----------------------------------------------#
 define lr_param     record
    cidnom       like datmlcl.cidnom,
    ufdcod       like datmlcl.ufdcod,
    mpacidcod    like datkmpacid.mpacidcod,
    lclltt       like datmlcl.lclltt,
    lcllgt       like datmlcl.lcllgt,
    c24lclpdrcod like datmlcl.c24lclpdrcod,
    ciaempcod    like datmservico.ciaempcod,
    atdsrvorg    like datmservico.atdsrvorg,
    socntzcod    like datmsrvre.socntzcod,
    espcod       like datmsrvre.espcod,
    asitipcod    like datmservico.asitipcod,
    vclcoddig    like datmservico.vclcoddig,
    vclvlr       decimal (10,2)
 end record

 define l_xml record
    response char(10000),
    request  char(10000)
 end record

 define lr_retorno record
    cod_erro  smallint,
    mensagem  char(100)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint

 initialize l_xml.* to null

   if lr_param.espcod is null then
      let lr_param.espcod = 0
   end if

   let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                       '<REQUEST><SERVICO>LIBERAR_SERVICO_IMEDIATO</SERVICO>',
                       '<OBJETOS>',
	                        '<Servico_Auxiliar>',
	  	                       '<OrigemServico>', lr_param.atdsrvorg ,'</OrigemServico>',
	  	                       '<CodigoTipoAssistencia>', lr_param.asitipcod ,'</CodigoTipoAssistencia>',
	  	                       '<CodigoNatureza>', lr_param.socntzcod ,'</CodigoNatureza>',
	  	                       '<CodigoSubnatureza>', lr_param.espcod ,'</CodigoSubnatureza>',
	                        '</Servico_Auxiliar>',
                          '<Servico>',
                             '<CodigoSistemaOrigem>1</CodigoSistemaOrigem>',
                             '<Empresa><CodigoEmpresa>', lr_param.ciaempcod, '</CodigoEmpresa></Empresa>',
                             '<Central>',
	  			                      '<CodigoOrigemServico>', lr_param.atdsrvorg ,'</CodigoOrigemServico>',
                             '</Central>',
	                           '<Enderecos>',
                                '<ServicoEndereco>',
                                     '<TipoEndereco>1</TipoEndereco>',
                                     '<Endereco>',
                      	                 '<Cidade>',
                                           '<CodigoCidade>',lr_param.mpacidcod clipped,'</CodigoCidade>',
                                           '<SiglaUF>',lr_param.ufdcod clipped,'</SiglaUF>',
                                           '<NomeCidade><![CDATA[',lr_param.cidnom clipped,']]></NomeCidade>',
                                        '</Cidade>',
                   	                   '<TipoIndexacao>',lr_param.c24lclpdrcod ,'</TipoIndexacao>',
                       	               '<NumeroLatitude>',lr_param.lclltt ,'</NumeroLatitude>',
                  	                     '<NumeroLongitude>',lr_param.lcllgt ,'</NumeroLongitude>',
                  	                  '</Endereco>',
                 		           '</ServicoEndereco>',
	                           '</Enderecos>',
	                           '<Veiculo>',
	                              '<VeiculoModelo>',
                                   '<CodigoVeiculo>',lr_param.vclcoddig clipped,'</CodigoVeiculo>',
                                '</VeiculoModelo>',
                                '<ValorVeiculo>',lr_param.vclvlr,'</ValorVeiculo>',
                             '</Veiculo>',
                          '</Servico>',
                       '</OBJETOS></REQUEST>'

   call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                    returning l_status,
                              l_msg,
                              l_xml.response

   if l_status <> 0 then
      call ctx34g02_email_erro(l_xml.request,
                               l_xml.response,
                               "ERRO NO MQ - ctx34g02_validaservicoimediato",
                               l_msg)
      return 'NAO'
   end if

   if l_xml.response like "%<retorno><codigo>1</codigo>%" then
      call ctx34g02_email_erro(l_xml.request,
                               l_xml.response,
                               "ERRO NO SERVICO - ctx34g02_validaservicoimediato",
                               "")
      return 'NAO'
   end if

   if l_xml.response = "<?xml version='1.0' encoding='ISO-8859-1' ?><retorno><codigo>0</codigo><mensagem>SIM</mensagem></retorno>" then
      # Servico pode ser aberto como imediato
      return 'SIM'
   end if

   if l_xml.response = "<?xml version='1.0' encoding='ISO-8859-1' ?><retorno><codigo>0</codigo><mensagem>SEMREGRAGPS</mensagem></retorno>" then
      # Nao ha regra de acionamento por GPS para o Servico
      return 'SEMREGRAGPS'
   end if

   if l_xml.response = "<?xml version='1.0' encoding='ISO-8859-1' ?><retorno><codigo>0</codigo><mensagem>NAO</mensagem></retorno>" then
      # Servico NAO pode ser aberto como imediato
      return 'NAO'
   end if

   return 'NAO'

end function


#----------------------------------------------------#
function ctx34g02_atualizacaoservico(lr_param)
#----------------------------------------------------#
 define lr_param     record
    atdsrvnum    like datmservico.atdsrvnum,
    atdsrvano    like datmservico.atdsrvano
 end record

 define l_xml record
    response char(10000),
    request  char(10000)
 end record

 define lr_retorno record
    cod_erro  smallint,
    mensagem  char(100)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint

 initialize l_xml.* to null

 let lr_retorno.cod_erro = 0

   let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                       '<REQUEST>',
                          '<SERVICO>REENVIAR_SERVICO</SERVICO>',
                          '<OBJETOS>',
                             '<Servico>',
                                '<Central>',
                                   '<CodigoOrigemServico>1</CodigoOrigemServico>',
                                   '<NumeroServicoAtendimento>', lr_param.atdsrvnum, '</NumeroServicoAtendimento>',
                                   '<AnoServicoAtendimento>', lr_param.atdsrvano, '</AnoServicoAtendimento>',
                                '</Central>',
                             '</Servico>',
                          '</OBJETOS>',
                       '</REQUEST>'

   call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                    returning l_status,
                              l_msg,
                              l_xml.response

   if l_status <> 0 then
      call ctx34g02_email_erro(l_xml.request,
                               l_xml.response,
                               "ERRO NO MQ - ctx34g02_atualizacaoservico",
                               l_msg)
   end if

   if l_xml.response like "%<retorno><codigo>1</codigo>%" then
      call ctx34g02_email_erro(l_xml.request,
                               l_xml.response,
                               "ERRO NO SERVICO - ctx34g02_atualizacaoservico",
                               "")
   end if

   return

end function


#----------------------------------------------------#
function ctx34g02_enviar_msg_gps(lr_param)
#----------------------------------------------------#
 define lr_param     record
    pstcoddig    like dpaksocor.pstcoddig,
    socvclcod    like datkveiculo.socvclcod,
    srrcoddig    like datksrr.srrcoddig,
    mdtmsgtxt    like datmmdtmsgtxt.mdtmsgtxt
 end record

 define l_xml record
    response char(10000),
    request  char(10000)
 end record

 define lr_retorno record
    cod_erro  smallint,
    mensagem  char(100)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint

 initialize l_xml.* to null

   let l_xml.request = '<?xml version="1.0" encoding="utf-8" ?>',
                       '<REQUEST>',
                          '<SERVICO>ENVIAR_MENSAGEM_RECURSO</SERVICO>',
                          '<OBJETOS>',
                             '<RecursoAtendimento>',
                                '<DescricaoRecurso></DescricaoRecurso>',
                                '<Prestador>',
                                   '<CodigoPrestador>', lr_param.pstcoddig, '</CodigoPrestador>',
                                '</Prestador>',
                                '<Socorrista>',
                                   '<CodigoSocorrista>', lr_param.srrcoddig, '</CodigoSocorrista>',
                                '</Socorrista>',
                                '<VeiculoSocorro>',
                                   '<CodigoVeiculo>', lr_param.socvclcod, '</CodigoVeiculo>',
                                '</VeiculoSocorro>',
                             '</RecursoAtendimento>',
                             '<Transmissao>',
                               '<TransmissaoTipo>',
                                   '<DescricaoAbreviadaTransmissaoTipo>GPS</DescricaoAbreviadaTransmissaoTipo>',
                               '</TransmissaoTipo>',
                                '<NomeTituloTransmissao>Mensagem Recurso Informix</NomeTituloTransmissao>',
                                '<TextoTransmissao><![CDATA[', lr_param.mdtmsgtxt clipped, ']]></TextoTransmissao>',
                               '</Transmissao>',
                          '</OBJETOS>',
                       '</REQUEST>'

   call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                    returning l_status,
                              l_msg,
                              l_xml.response

   if l_status <> 0 then
      call ctx34g02_email_erro(l_xml.request,
                               l_xml.response,
                               "ERRO NO MQ - ctx34g02_enviar_msg_gps",
                               l_msg)
      let lr_retorno.cod_erro = l_status
   end if

   if l_xml.response like "%<retorno><codigo>1</codigo>%" then
      call ctx34g02_email_erro(l_xml.request,
                               l_xml.response,
                               "ERRO NO SERVICO - ctx34g02_enviar_msg_gps",
                               "")
      let lr_retorno.cod_erro = 1
   end if

   return lr_retorno.cod_erro, 0

end function


#------------------------------------------#
function ctx34g02_conclusao_servico(param)
#------------------------------------------#

define param record
   atdsrvnum      like datmservico.atdsrvnum,
   atdsrvano      like datmservico.atdsrvano,
   atdetpcod      like datmsrvacp.atdetpcod,
   pstcoddig      like dpaksocor.pstcoddig,
   vclcoddig      like datkveiculo.vclcoddig,
   srrcoddig      like datksrr.srrcoddig,
   txttiptrx      char(10),
   usrtip         like isskfunc.usrtip,
   empcod         like isskfunc.empcod,
   funmat         like isskfunc.funmat,
   TodosMultiplos char(1)
end record

 define l_xml record
    response char(32766),
    request  char(32766)
 end record

 define lr_retorno record
    cod_erro  smallint,
    mensagem  char(100)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint
 define l_atdlibflg like datmservico.atdlibflg
 define l_etpcod smallint
 define l_doc_handle  integer

 initialize l_xml.* to null
 initialize lr_retorno.* to null
 initialize l_status, l_msg, l_online, l_atdlibflg, l_etpcod, l_doc_handle to null

 if not m_ctx34g02_prep then
    call ctx34g02_prepare()
 end if

 if ctx34g00_NovoAcionamento() and
    ctx34g00_origem(param.atdsrvnum,param.atdsrvano) and
    param.atdsrvnum is not null then

    if param.atdetpcod = 3 then
       let l_etpcod = 4
    else
       let l_etpcod = param.atdetpcod
    end if

    # XML para conclusao do servico no AcionamentoWeb
    let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                        '<REQUEST><SERVICO>CONCLUSAO_SERVICO</SERVICO><OBJETOS>',
                        '<ServicoCentral><NumeroServicoAtendimento>', param.atdsrvnum, '</NumeroServicoAtendimento>',
                        '<AnoServicoAtendimento>', param.atdsrvano, '</AnoServicoAtendimento></ServicoCentral>',
                        '<EtapaAcompanhamento><CodigoEtapa>',l_etpcod , '</CodigoEtapa></EtapaAcompanhamento>',
                        '<RecursoAtendimento><Prestador><CodigoPrestador>', param.pstcoddig, '</CodigoPrestador></Prestador><Socorrista><CodigoSocorrista>', param.srrcoddig, '</CodigoSocorrista></Socorrista><VeiculoSocorro><CodigoVeiculo>', param.vclcoddig, '</CodigoVeiculo></VeiculoSocorro></RecursoAtendimento>',
                        '<TransmissaoTipo><DescricaoAbreviadaTransmissaoTipo>', param.txttiptrx clipped, '</DescricaoAbreviadaTransmissaoTipo> </TransmissaoTipo>',
                        '<Usuario><Matricula>', param.funmat, '</Matricula><Empresa>', param.empcod, '</Empresa><TipoUsuario>', param.usrtip, '</TipoUsuario> </Usuario>',
	                      '<Auxiliar><TodosMultiplos>', param.TodosMultiplos ,'</TodosMultiplos></Auxiliar>',
                        '</OBJETOS></REQUEST>'

    call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                     returning l_status,
                               l_msg,
                               l_xml.response

    if l_status <> 0 then
       call ctx34g02_email_erro(l_xml.request,
                                l_xml.response,
                                "ERRO NO MQ - ctx34g02_conclusao_servico",
                                l_msg)
       let lr_retorno.cod_erro = 1
       let lr_retorno.mensagem = "ERRO NO MQ - ctx34g02_conclusao_servico"
    else
       call figrc011_fim_parse()
       call figrc011_inicio_parse()
       let l_doc_handle  = figrc011_parse(l_xml.response)
       let lr_retorno.mensagem = figrc011_xpath(l_doc_handle, "/retorno/mensagem")
       call figrc011_fim_parse()

       if l_xml.response like "%<retorno><codigo>1</codigo>%" then
          #call ctx34g02_email_erro(l_xml.request,
          #                         l_xml.response,
          #                         "ERRO NO SERVICO - ctx34g02_conclusao_servico",
          #                         "")
          let lr_retorno.cod_erro = 1
       end if
    end if

    return lr_retorno.cod_erro,
           lr_retorno.mensagem

 end if

end function


#------------------------------------------#
function ctx34g02_atualizacao_recurso(param)
#------------------------------------------#

define param record
   pstcoddig like dpaksocor.pstcoddig,
   vclcoddig like datkveiculo.vclcoddig,
   srrcoddig like datksrr.srrcoddig,
   c24atvcod like dattfrotalocal.c24atvcod,
   atvdat    like dattfrotalocal.cttdat,
   atvhor    like dattfrotalocal.ctthor,
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano,
   ufdcod_gps like datmfrtpos.ufdcod,
   cidnom_gps like datmfrtpos.cidnom,
   brrnom_gps like datmfrtpos.brrnom,
   obspostxt like dattfrotalocal.obspostxt,
   usrtip    like isskfunc.usrtip,
   empcod    like isskfunc.empcod,
   funmat    like isskfunc.funmat
end record

 define l_xml record
    response char(32766),
    request  char(32766)
 end record

 define lr_retorno record
    cod_erro  smallint,
    mensagem  char(100)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint

 initialize l_xml.* to null

 if not m_ctx34g02_prep then
    call ctx34g02_prepare()
 end if

 if ctx34g00_NovoAcionamento() then
    # XML para conclusao do servico no AcionamentoWeb
    let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                        '<REQUEST><SERVICO>ATUALIZACAO_RECURSO</SERVICO><OBJETOS>',
                        '<RecursoAtendimento>',
                           '<Prestador><CodigoPrestador>', param.pstcoddig, '</CodigoPrestador></Prestador>',
                           '<Socorrista><CodigoSocorrista>', param.srrcoddig, '</CodigoSocorrista></Socorrista>',
                           '<VeiculoSocorro><CodigoVeiculo>', param.vclcoddig, '</CodigoVeiculo></VeiculoSocorro>',
                           '<DataAtividade>', param.atvdat clipped,' ',param.atvhor clipped, '</DataAtividade>',
                           '<SiglaAtividade><Sigla>', param.c24atvcod, '</Sigla></SiglaAtividade>',
                           '<SiglaComplementarAtividade></SiglaComplementarAtividade>',
                           '<LocalGPS><Cidade><SiglaUF>', param.ufdcod_gps, '</SiglaUF><NomeCidade>', param.cidnom_gps, '</NomeCidade></Cidade><NomeBairro>', param.brrnom_gps, '</NomeBairro></LocalGPS>',
                           '<TextoObservacao><![CDATA[', param.obspostxt clipped, ']]></TextoObservacao>',
                        '</RecursoAtendimento>',
                         '<ServicoCentral><NumeroServicoAtendimento>', param.atdsrvnum, '</NumeroServicoAtendimento>',
                        '<AnoServicoAtendimento>', param.atdsrvano, '</AnoServicoAtendimento></ServicoCentral>',
                        '<Usuario><Matricula>', param.funmat, '</Matricula><Empresa>', param.empcod, '</Empresa><TipoUsuario>', param.usrtip, '</TipoUsuario> </Usuario>',
                        '</OBJETOS></REQUEST>'

    call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                     returning l_status,
                               l_msg,
                               l_xml.response

    if l_status <> 0 then
       call ctx34g02_email_erro(l_xml.request,
                                l_xml.response,
                                "ERRO NO MQ - ctx34g02_atualizacao_recurso",
                                l_msg)
       let lr_retorno.cod_erro = 1
       let lr_retorno.mensagem = "ERRO NO MQ - ctx34g02_atualizacao_recurso"
    else
       if l_xml.response like "%<retorno><codigo>1</codigo>%" then
          call ctx34g02_email_erro(l_xml.request,
                                   l_xml.response,
                                   "ERRO NO SERVICO - ctx34g02_atualizacao_recurso",
                                   "")
          let lr_retorno.cod_erro = 1
          let lr_retorno.mensagem = "ERRO NO SERVICO - ctx34g02_atualizacao_recurso"
       end if
    end if

    return lr_retorno.cod_erro,
           lr_retorno.mensagem

 end if

end function

#------------------------------------------#
function ctx34g02_reenviar_conclusao(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano,
   atdsrvseq like datmsrvacp.atdsrvseq,
   txttiptrx char(10),
   usrtip    like isskfunc.usrtip,
   empcod    like isskfunc.empcod,
   funmat    like isskfunc.funmat
end record

 define l_xml record
    response char(32766),
    request  char(32766)
 end record

 define lr_retorno record
    cod_erro  smallint,
    mensagem  char(100)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint
 define l_atdlibflg like datmservico.atdlibflg
 define l_doc_handle  integer

 initialize l_xml.* to null
 initialize lr_retorno.* to null
 initialize l_status, l_msg, l_online, l_atdlibflg, l_doc_handle to null

 if not m_ctx34g02_prep then
    call ctx34g02_prepare()
 end if

 if ctx34g00_NovoAcionamento() and
    ctx34g00_origem(param.atdsrvnum,param.atdsrvano) and
    param.atdsrvnum is not null then

    # XML para reeenvio da transmissao de conclusao do servico no AcionamentoWeb
    let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                        '<REQUEST><SERVICO>REENVIAR_TRANSMISSAO</SERVICO><OBJETOS>',
                        '<ServicoCentral><NumeroServicoAtendimento>', param.atdsrvnum, '</NumeroServicoAtendimento>',
                        '<AnoServicoAtendimento>', param.atdsrvano, '</AnoServicoAtendimento></ServicoCentral>',
                        '<ServicoEtapa><SequenciaEtapaServico>',param.atdsrvseq , '</SequenciaEtapaServico></ServicoEtapa>',
                        '<TransmissaoTipo><DescricaoAbreviadaTransmissaoTipo>', param.txttiptrx clipped, '</DescricaoAbreviadaTransmissaoTipo> </TransmissaoTipo>',
                        '<Usuario><Matricula>', param.funmat, '</Matricula><Empresa>', param.empcod, '</Empresa><TipoUsuario>', param.usrtip, '</TipoUsuario> </Usuario>',
                        '</OBJETOS></REQUEST>'

    call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                     returning l_status,
                               l_msg,
                               l_xml.response

    if l_status <> 0 then
       call ctx34g02_email_erro(l_xml.request,
                                l_xml.response,
                                "ERRO NO MQ - ctx34g02_reenviar_conclusao",
                                l_msg)
       let lr_retorno.cod_erro = 1
       let lr_retorno.mensagem = "ERRO NO MQ - ctx34g02_reenviar_conclusao"
    else
       call figrc011_fim_parse()
       call figrc011_inicio_parse()
       let l_doc_handle  = figrc011_parse(l_xml.response)
       let lr_retorno.mensagem = figrc011_xpath(l_doc_handle, "/retorno/mensagem")
       call figrc011_fim_parse()

       if l_xml.response like "%<retorno><codigo>1</codigo>%" then
          #call ctx34g02_email_erro(l_xml.request,
          #                         l_xml.response,
          #                         "ERRO NO SERVICO - ctx34g02_conclusao_servico",
          #                         "")
          let lr_retorno.cod_erro = 1

       end if
    end if

    return lr_retorno.cod_erro,
           lr_retorno.mensagem

 end if

end function


#------------------------------------------#
function ctx34g02_situacao_transmissao(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano,
   atdsrvseq like datmsrvacp.atdsrvseq
end record

 define l_xml record
    response char(32766),
    request  char(32766)
 end record

 define lr_retorno record
    cod_erro     smallint,
    mensagem     char(200),
    mdtmsgsttdes char (26),
    atldat       like datmmdtlog.atldat,
    atlhor       like datmmdtlog.atlhor,
    rcbpor       char (6)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint
 define l_atdlibflg like datmservico.atdlibflg
 define l_doc_handle  integer

 initialize l_xml.* to null
 initialize lr_retorno.* to null
 initialize l_status, l_msg, l_online, l_atdlibflg, l_doc_handle to null

 if not m_ctx34g02_prep then
    call ctx34g02_prepare()
 end if

 if ctx34g00_NovoAcionamento() and
    ctx34g00_origem(param.atdsrvnum,param.atdsrvano) and
    param.atdsrvnum is not null then

    # XML para reeenvio da transmissao de conclusao do servico no AcionamentoWeb
    let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                        '<REQUEST><SERVICO>SITUACAO_TRANSMISSAO</SERVICO><OBJETOS>',
                        '<ServicoCentral><NumeroServicoAtendimento>', param.atdsrvnum, '</NumeroServicoAtendimento>',
                        '<AnoServicoAtendimento>', param.atdsrvano, '</AnoServicoAtendimento></ServicoCentral>',
                        '<ServicoEtapa><SequenciaEtapaServico>',param.atdsrvseq , '</SequenciaEtapaServico></ServicoEtapa>',
                        '</OBJETOS></REQUEST>'

    call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                     returning l_status,
                               l_msg,
                               l_xml.response

    if l_status <> 0 then
       call ctx34g02_email_erro(l_xml.request,
                                l_xml.response,
                                "ERRO NO MQ - ctx34g02_situacao_transmissao",
                                l_msg)
       let lr_retorno.cod_erro = 1
       let lr_retorno.mensagem = "ERRO NO MQ - ctx34g02_situacao_transmissao"
    else
       call figrc011_fim_parse()
       call figrc011_inicio_parse()
       let l_doc_handle  = figrc011_parse(l_xml.response)
       let lr_retorno.mensagem = figrc011_xpath(l_doc_handle, "/retorno/mensagem")
       call figrc011_fim_parse()

       if l_xml.response like "%<retorno><codigo>1</codigo>%" then
          #call ctx34g02_email_erro(l_xml.request,
          #                         l_xml.response,
          #                         "ERRO NO SERVICO - ctx34g02_situacao_transmissao",
          #                         "")
          let lr_retorno.cod_erro = 1
       else
          let lr_retorno.mdtmsgsttdes = lr_retorno.mensagem[26,48]
          let lr_retorno.atldat       = lr_retorno.mensagem[73,83]
          let lr_retorno.atlhor       = lr_retorno.mensagem[83,92]
          let lr_retorno.rcbpor       = lr_retorno.mensagem[119,125]
       end if
    end if

    return lr_retorno.cod_erro,
           lr_retorno.mensagem,
           lr_retorno.mdtmsgsttdes,
           lr_retorno.atldat,
           lr_retorno.atlhor,
           lr_retorno.rcbpor

 end if

end function

#------------------------------------------#
function ctx34g02_carga_contingencia(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
end record

 define l_xml record
    response char(10000),
    request  char(10000)
 end record

 define ws record
 	   atdsrvorg     like datmservico.atdsrvorg,
     seqregcnt     like datmcntsrv.seqregcnt,
     c24astcod     like datmligacao.c24astcod
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint

 initialize l_xml.* to null
 initialize ws.* to null

 if not m_ctx34g02_prep then
    call ctx34g02_prepare()
 end if

 if ctx34g00_NovoAcionamento() and ctx34g00_origem(param.atdsrvnum,param.atdsrvano) then

    open c_ctx34g02_028 using param.atdsrvnum,
                              param.atdsrvano
    fetch c_ctx34g02_028 into ws.seqregcnt

    if sqlca.sqlcode <> 0 then
    	 return
    end if
    close c_ctx34g02_028

    open c_ctx34g02_029 using param.atdsrvnum,
                              param.atdsrvano
    fetch c_ctx34g02_029 into ws.atdsrvorg,
                              ws.c24astcod

    if sqlca.sqlcode <> 0 then
    	 return
    end if
    close c_ctx34g02_029

    let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                        '<REQUEST>',
                        '  <SERVICO>CARGA_CONTINGENCIA</SERVICO>',
                        '  <OBJETOS>',
                        '      <ServicoCentral>',
                        '        <CodigoOrigemServico>', ws.atdsrvorg using "<<&", '</CodigoOrigemServico>',
                        '        <NumeroServicoAtendimento>', param.atdsrvnum using "<<<<<<&", '</NumeroServicoAtendimento>',
                        '        <AnoServicoAtendimento>',param.atdsrvano using "<&", '</AnoServicoAtendimento>',
                        '        <CodigoAssuntoCentral>', ws.c24astcod clipped, '</CodigoAssuntoCentral>',
                        '      </ServicoCentral>',
                        '      <ServicoContingencia>',
                        '        <NumeroServicoContingencia>', ws.seqregcnt using "<<<<<<<<<&", '</NumeroServicoContingencia>',
                        '      </ServicoContingencia>',
                        '  </OBJETOS>',
                        '</REQUEST>'

    call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                     returning l_status,
                               l_msg,
                               l_xml.response

 end if

end function

#----------------------------------------#
function ctx34g02_email_erro(lr_parametro)
#----------------------------------------#

  define lr_parametro   record
         xml_request    char(32766),
         xml_response   char(32766),
         assunto        char(100),
         msg_erro       char(100)
  end record

  define l_destinatario char(300),
         l_modulo       char(10),
         l_comando      char(2000),
         l_arquivo      char(100),
         l_relsgl       like igbmparam.relsgl,
         l_relpamtip    like igbmparam.relpamtip,
         l_relpamtxt    like igbmparam.relpamtxt

  ### PSI-2013-23333/EV - INICIO
  #---> Variaves para:
  #     remover (comentar) forma de envio de e-mails anterior e inserir
  #     novo componente para envio de e-mails.
  #---> feito por Rodolfo Massini (F0113761) em jan/2014

  define lr_mail record
         rem char(50),
         des char(250),
         ccp char(250),
         cco char(250),
         ass char(500),
         msg char(32000),
         idr char(20),
         tip char(4)
  end record

  define l_retorno smallint
        ,l_matr  like isskfunc.funmat
        ,l_matr_desc    char(6)
        
 define lr_anexo record
       anexo1    char (300)
      ,anexo2    char (300)
      ,anexo3    char (300)
 end record

  define l_servidor char(20)

  initialize lr_mail
            ,l_retorno
			      ,l_servidor
			      ,l_matr
                              ,l_matr_desc     to null
			      
  initialize lr_anexo.* to null

  ### PSI-2013-23333/EV - FIM

  if not m_ctx34g02_prep then
     call ctx34g02_prepare()
  end if

  if g_issk.funmat > 0  and g_issk.funmat < 999999 then
     let l_matr = g_issk.funmat
  else
     let l_matr = 999999
  end if

   let l_matr_desc = l_matr clipped

  let l_destinatario = null
  let l_comando      = null
  let l_modulo       = "ctx34g02"
  let l_arquivo      = "./mqacnweb", l_matr_desc clipped, ".txt" #Ver se isso existe
  let l_relsgl       = null
  let l_relpamtip    = null
  let l_relpamtxt    = null


  start report ctx34g02_rel_erro to l_arquivo
  output to report ctx34g02_rel_erro(lr_parametro.xml_request,
                                     lr_parametro.xml_response,
                                     lr_parametro.msg_erro)
  finish report ctx34g02_rel_erro

  # CARREGA DESTINATARIOS PARA RECEBER EMAIL
  let l_relsgl = "CTX34G02"
  let l_relpamtip = 1  # ERRO GENERICO
  let l_destinatario = null
  open c_ctx34g02_026 using l_relsgl,
                            l_relpamtip
  foreach c_ctx34g02_026 into l_relpamtxt
     if l_destinatario is null then
        let l_destinatario = l_relpamtxt
     else
        let l_destinatario = l_destinatario clipped, ",", l_relpamtxt
     end if
  end foreach
  close c_ctx34g02_026

  if l_destinatario is not null and l_destinatario <> " "  then

     let l_servidor  = fgl_getenv("HOSTNAME")
     let lr_mail.rem = 'porto.socorro@portoseguro.com.br'
     let lr_mail.des = l_destinatario   clipped
     let lr_mail.ass = lr_parametro.assunto clipped, ' ', l_servidor clipped, ' ', lr_parametro.msg_erro[1,22] clipped
     let lr_mail.tip = "text"
     let lr_mail.idr = "P0603000"

     let lr_anexo.anexo1 = l_arquivo clipped;

     call ctx22g00_envia_email_anexos(lr_mail.*, lr_anexo.*)
     returning l_retorno


     ### PSI-2013-23333/EV - FIM

  end if

  sleep 1
  let l_comando = "rm -f ", l_arquivo
  run l_comando

end function


#------------------------------------#
report ctx34g02_rel_erro(lr_parametro)
#------------------------------------#

  define lr_parametro  record
         xml_request   char(32766),
         xml_response  char(32766),
         msg_erro      char(100)
  end record

  define l_data        date,
         l_hora        datetime hour to minute

  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        let l_data = today
        let l_hora = current

     on every row

        print "DATA/HORA...: ", l_data, "/", l_hora

        skip 1 line

        print "SERVICO.....: DPCNVACIONAJAVA01R "

        skip 1 line

        print "ERRO........: ", lr_parametro.msg_erro clipped

        skip 2 lines

        print "XML REQUEST.: ", lr_parametro.xml_request  clipped

        skip 2 lines

        print "XML RESPONSE: ", lr_parametro.xml_response clipped

end report
