#############################################################################
# Nome do Modulo: CTS37M00                                          Alberto #
#                                                                           #
# Aviso de Sinistro ROUBO/FURTO Total                              Jul/2006 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 19/07/2006  PSI 1916965  Alberto      Funcao para SININVEM                #
#                                       Criar funcao cts37m00_msg_siniven   #
#                                       Envio de e-mail sinivem             #
#                                       Retirado do mod.cts05m00 para fazer #
#                                       a integracao com MQ                 #
#---------------------------------------------------------------------------#
# 22/12/2009  ??????????   Patricia W.  Envio de Informacoes SINISTRO,      #
#                                       Integracao EJB / 4GL                #
#---------------------------------------------------------------------------#
# 09/05/2012   Silvia        PSI 2012-07408  Anatel - DDD/Telefone          #
#---------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#############################################################################
database porto

globals '/homedsa/projetos/geral/globals/glct.4gl'
globals "/homedsa/projetos/geral/globals/figrc012.4gl"
##globals 'figrc012.4gl'

define m_prep smallint
define m_mens char(1000)

function cts37m00_prepare()

 define l_sql char(500)
 let l_sql = null
 let l_sql = 'select bocnum '
             ,'from datmservicocmp '
             ,'where atdsrvnum = ? and '
             ,'atdsrvano = ? '
 prepare pcts37m00001 from l_sql
 declare ccts37m00001 cursor for pcts37m00001

 let m_prep = true


end function

#------------------------------------------------------------------------------
function cts37m00_msg_siniven(lr_param)
#------------------------------------------------------------------------------

define lr_param       record
       vcllicnum      like datmservico.vcllicnum
      ,sindat         like datmservicocmp.sindat
      ,sinhor         like datmservicocmp.sinhor
      ,cidnom         like datmlcl.cidnom
      ,ufdcod         like datmlcl.ufdcod
      ,vclcordes      char (40)
      ,vclchsnum      char (40)
      ,vclmrc         char (30)
      ,vcltp          char (30)
      ,vclmdl         char (30)
      ,data           char (10)
      ,hora           char (05)
      ,succod         like datrligapol.succod
      ,aplnumdig      like datrligapol.aplnumdig
      ,itmnumdig      like datrligapol.itmnumdig
      ,ramcod         like datrligapol.ramcod
      ,avsrcprd       smallint
      ,lignum         like datmligacao.lignum

end record

define lr_retorno     record
       msg_sinivem    smallint
end record

define lr_mens        record
       sistema        char(10)
      ,remet          char(50)
      ,para           char(1000)
      ,msg            char(300)
      ,subject        char(300)
end record

## Alteracao
define d_cts37m00    record
   nom               like datmservico.nom          ,
   corsus            like datmservico.corsus       ,
   cornom            like datmservico.cornom       ,
   cvnnom            char (19)                     ,
   vclcoddig         like datmservico.vclcoddig    ,
   vcldes            like datmservico.vcldes       ,
   vclanomdl         like datmservico.vclanomdl    ,
   vcllicnum         like datmservico.vcllicnum    ,
   vclcordes         char (11)                     ,
   atdrsdflg         like datmservico.atdrsdflg    ,
   atddfttxt         like datmservico.atddfttxt    ,
   atdlclflg         like datmservico.atdlclflg    ,
   c24sintip         like datmservicocmp.c24sintip ,
   sintipdes         char (05)                     ,
   eqprgides         like ssakeqprgi.eqprgides     ,
   sindat            like datmservicocmp.sindat    ,
   sinhor            like datmservicocmp.sinhor    ,
   vclchsinc         like abbmveic.vclchsinc       ,
   vclchsfnl         like abbmveic.vclchsfnl
end record
## Alteracao

define l_rep          char(100),
       l_cmd          char(500),
       l_ret          smallint,
       l_rel          char(100),
       l_hora1        datetime year to second,
       l_data_banco   date,
       l_aux          char(20)

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
   let l_rep = ""
   let l_cmd = ""
   let l_ret = 0
   let l_rel = ""

   initialize lr_mens.*    to null
   initialize lr_retorno.* to null

   call cts40g03_data_hora_banco(1)
       returning l_data_banco, l_hora1
   let l_aux = l_hora1

 ## Buscar dados do Veiculo

 if lr_param.vclchsnum is null or lr_param.vclchsnum = ' ' then
    call cts05g00 ( lr_param.succod         ,
                    lr_param.ramcod         ,
                    lr_param.aplnumdig      ,
                    lr_param.itmnumdig )
        returning   d_cts37m00.nom          ,
                    d_cts37m00.corsus       ,
                    d_cts37m00.cornom       ,
                    d_cts37m00.cvnnom       ,
                    d_cts37m00.vclcoddig    ,
                    d_cts37m00.vcldes       ,
                    d_cts37m00.vclanomdl    ,
                    d_cts37m00.vcllicnum    ,
                    d_cts37m00.vclchsinc    ,
                    d_cts37m00.vclchsfnl    ,
                    d_cts37m00.vclcordes
 end if

 if lr_param.vclchsnum is null then
    let lr_param.vclchsnum = d_cts37m00.vclchsinc clipped, d_cts37m00.vclchsfnl clipped
 end if

 if d_cts37m00.vclcordes is null or
    d_cts37m00.vclcordes = " " then
    let d_cts37m00.vclcordes = lr_param.vclcordes
 end if

## Alteracao
 ## RETIRAR "DESCONSIDERAR-AVISO"
   if lr_param.avsrcprd = 0 then
      let l_rel = "AVISO_RF_5886_" clipped,
                  l_aux[9,10], l_aux[6,7], l_aux[1,4], "_",
                  l_aux[12,13], l_aux[15,16], l_aux[18,19], ".xml"
   else
      let l_rel = "AVISO_RECUPERADO_5886_" clipped,
                  l_aux[9,10], l_aux[6,7], l_aux[1,4], "_",
                  l_aux[12,13], l_aux[15,16], l_aux[18,19], ".xml"
   end if

   let l_rep = "./", l_rel clipped

  #-- Obtem marca e modelo do veiculo

  select vclmrcnom,
         vcltipnom,
         vclmdlnom
  into lr_param.vclmrc, lr_param.vcltp, lr_param.vclmdl
  from agbkveic, outer agbkmarca, outer agbktip
 where agbkveic.vclcoddig  = d_cts37m00.vclcoddig
   and agbkmarca.vclmrccod = agbkveic.vclmrccod
   and agbktip.vclmrccod   = agbkveic.vclmrccod
   and agbktip.vcltipcod   = agbkveic.vcltipcod

   start report rcts37m0001 to l_rep
   output to report rcts37m0001(lr_param.*)
   finish report rcts37m0001

   ## let lr_mens.para  = "roberto.denis@portoseguro.com.br" ##"luiz.fonseca@correioporto"

   if  not figrc012_sitename("cts37m00","","") then
       display "ERRO NO SITENAME !"
   end if

   if  g_outFigrc012.Is_Teste or
       g_outFigrc012.Is_Homolog then
       ##let lr_mens.para  = "roberto.denis@portoseguro.com.br"
       let lr_mens.para  = "roberto.denis@correioporto"
   else
      let lr_mens.para = "gerson.tierno@correioporto,",
                         "joel.francisco@correioporto,",
                         "teotonio.carlos@correioporto"
   end if

   if lr_param.vcllicnum is null or
      lr_param.vcllicnum = ""    then
      if lr_param.avsrcprd = 0 then ## -mensagem sem placa Para furto e roubo
         ##let lr_mens.msg = "Comunicado de Furto/Roubo para Apolice.: ", Retirar
         let lr_mens.msg = "Comunicado de Furto/Roubo para Apolice.: ",
                                   " ", g_documento.succod    using "&&",
                                   " ", g_documento.ramcod    using "&&&&",
                                   " ", g_documento.aplnumdig using "<<<<<<<& &",
                          "   Item.: ",g_documento.itmnumdig  using "&&"
      else ##- mensagem se placa Para veiculos recuperados
         ##let lr_mens.msg = "Comunicado de Localização de veículo para Apolice.: ",
         let lr_mens.msg = "Comunicado de Furto/Roubo para Apolice.: ",
                                   " ", g_documento.succod    using "&&",
                                   " ", g_documento.ramcod    using "&&&&",
                                   " ", g_documento.aplnumdig using "<<<<<<<& &",
                          "   Item.: ",g_documento.itmnumdig  using "&&"
      end if

   else
      if g_outFigrc012.Is_Teste or
         g_outFigrc012.Is_Homolog then
         let lr_mens.para  = "roberto.denis@correioporto"
      else
         if lr_param.avsrcprd = 0 then ##- Com placa Para Furto e Roubo
            let lr_mens.para =  "alertavermelho@sinivem.com.br"
         else ## - Com placa Para veículos recuperados
            let lr_mens.para =  "recuperacao@sinivem.com.br"
         end if
      end if
   end if

   let lr_mens.subject = l_rel
   let lr_mens.sistema = "CT24HS"

   ##let lr_mens.remet = "EmailCorr.ct24hs@correioporto"

   let lr_mens.remet = "EmailCorr.ct24hs@portoseguro.com.br"

   #PSI-2013-23297 - Inicio
   let l_mail.de = lr_mens.remet
   #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
   let l_mail.para =  lr_mens.para
   let l_mail.cc = ""
   let l_mail.cco = ""
   let l_mail.assunto = lr_mens.subject
   let l_mail.mensagem = lr_mens.msg
   let l_mail.id_remetente = lr_mens.sistema
   let l_mail.tipo = "html"
   call figrc009_attach_file(l_rep)

   call figrc009_mail_send1 (l_mail.*)
    returning l_coderro,msg_erro
   #PSI-2013-23297 - Fim

   if l_coderro = 0  then
      let l_cmd = "rm ", l_rep clipped
      run l_cmd
      let lr_retorno.msg_sinivem = 0
   else
      let lr_retorno.msg_sinivem = 1
   end if

   return lr_retorno.*

end function

#------------------------------------------------------------------------------ #Patricia
function cts37m00_envia_localizacao(lr_param)
#------------------------------------------------------------------------------
   define lr_param  record
      c24astcod     like datkassunto.c24astcod,
      atdsrvnum     like datmservico.atdsrvnum,
      atdsrvano     like datmservico.atdsrvano,
      vcllicnum     like datmservico.vcllicnum,
      vclchsnum     char (20),
      funmat        like isskfunc.funmat,
      vclpdrseg     char (01),
      lcldat        like datmservico.atddat,
      delegacia     char (07)
   end record
   define l_avaria char (01)
   define l_xml    char(32766)
   define l_num_bo like datmservicocmp.bocnum
   define lr_local record
         lclidttxt         like datmlcl.lclidttxt
        ,lgdtxt            char (65)
        ,lgdtip            like datmlcl.lgdtip
        ,lgdnom            like datmlcl.lgdnom
        ,lgdnum            like datmlcl.lgdnum
        ,brrnom            like datmlcl.brrnom
        ,lclbrrnom         like datmlcl.lclbrrnom
        ,endzon            like datmlcl.endzon
        ,cidnom            like datmlcl.cidnom
        ,ufdcod            like datmlcl.ufdcod
        ,lgdcep            like datmlcl.lgdcep
        ,lgdcepcmp         like datmlcl.lgdcepcmp
        ,lclltt            like datmlcl.lclltt
        ,lcllgt            like datmlcl.lcllgt
        ,dddcod            like datmlcl.dddcod
        ,lcltelnum         like datmlcl.lcltelnum
        ,lclcttnom         like datmlcl.lclcttnom
        ,lclrefptotxt      like datmlcl.lclrefptotxt
        ,c24lclpdrcod      like datmlcl.c24lclpdrcod
        ,ofnnumdig         like sgokofi.ofnnumdig
        ,emeviacod         like datmemeviadpt.emeviacod
        ,celteldddcod      like datmlcl.celteldddcod
        ,celtelnum         like datmlcl.celtelnum
        ,endcmp            like datmlcl.endcmp
        ,codigosql         integer
        ,tellocal          char(16)
   end record
   define lr_erro record
        coderro  smallint
       ,mens     char(500)
   end record
   initialize lr_local.* to null
   initialize lr_erro.*  to null
   let l_xml = null
   let l_avaria = "N"
   let l_num_bo = null
   if (lr_param.c24astcod = "L11") then
      let l_avaria = "S"
   end if
   if lr_param.c24astcod <> "L11" and
      lr_param.c24astcod <> "L12" then
      let lr_param.vclpdrseg =  "N"
   end if
   sleep 2
   if lr_param.c24astcod = "L10" then
       call ctx04g00_local_gps(lr_param.atdsrvnum,
                               lr_param.atdsrvano,
                               1)
                     returning lr_local.lclidttxt
                              ,lr_local.lgdtip
                              ,lr_local.lgdnom
                              ,lr_local.lgdnum
                              ,lr_local.lclbrrnom
                              ,lr_local.brrnom
                              ,lr_local.cidnom
                              ,lr_local.ufdcod
                              ,lr_local.lclrefptotxt
                              ,lr_local.endzon
                              ,lr_local.lgdcep
                              ,lr_local.lgdcepcmp
                              ,lr_local.lclltt
                              ,lr_local.lcllgt
                              ,lr_local.dddcod
                              ,lr_local.lcltelnum
                              ,lr_local.lclcttnom
                              ,lr_local.c24lclpdrcod
                              ,lr_local.celteldddcod
                              ,lr_local.celtelnum
                              ,lr_local.endcmp
                              ,lr_local.codigosql
                              ,lr_local.emeviacod
         # Monta Lougradouro
         let lr_local.lgdtxt = lr_local.lgdtip clipped, " ",
                               lr_local.lgdnom clipped, " ",
                               lr_local.lgdnum using "<<<<#"
         # Monta Bairro - Subbairro
         call cts06g10_monta_brr_subbrr(lr_local.brrnom,
                                        lr_local.lclbrrnom)
              returning lr_local.lclbrrnom
         # Monta Telefone - Dddcod - telefone
         let lr_local.tellocal = "(", lr_local.dddcod using "&&&&" , ")",  ## Anatel ( &&& )
                                 lr_local.lcltelnum
   end if
   # Busca numero de BO
   if m_prep = false or
      m_prep = " " then
      call cts37m00_prepare()
   end if
   whenever error continue
     open ccts37m00001 using lr_param.atdsrvnum
                            ,lr_param.atdsrvano
     fetch ccts37m00001 into l_num_bo
   whenever error stop
   if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode <> 100 then
        let lr_erro.mens = "Erro (", sqlca.sqlcode clipped ,") ao recuperar numero de BO"
         call errorlog(lr_erro.mens)
     end if
   end if
   # Monta XML
   let l_xml = '<?xml version="1.0" encoding="ISO-8859-1" ?>'
              ,'<InformacaoLocalizacaoVO>'
	        ,'<placa>' , lr_param.vcllicnum clipped   ,'</placa>'
	        ,'<chassi>', lr_param.vclchsnum clipped   ,'</chassi>'
	        ,'<possuiAvarias>',l_avaria clipped       ,'</possuiAvarias>'
	        ,'<dp>',lr_param.delegacia clipped        ,'</dp>'
	        ,'<seguradoPosseVeic>', lr_param.vclpdrseg clipped ,'</seguradoPosseVeic>'
	        ,'<dataLocalizacao>',lr_param.lcldat clipped ,'</dataLocalizacao>'
	        ,'<endereco>',   lr_local.lgdtxt     clipped , '</endereco>'
	        ,'<bairro>',     lr_local.lclbrrnom  clipped , '</bairro>'
	        ,'<cidade>',     lr_local.cidnom     clipped , '</cidade>'
	        ,'<uf>',         lr_local.ufdcod     clipped , '</uf>'
	        ,'<complemento>',lr_local.endcmp     clipped , '</complemento>'
	        ,'<telLocal>',   lr_local.tellocal   clipped , '</telLocal>'
	        ,'<codigoUsuario>', lr_param.funmat  clipped ,'</codigoUsuario>'
	        ,'<origemInformacao>0</origemInformacao>'
	        ,'<numeroBO>',l_num_bo clipped,'</numeroBO>'
              ,'</InformacaoLocalizacaoVO>'
   call errorlog("Antes de chamar a funcao de envia xml")
   call errorlog(g_documento.c24astcod)
   call errorlog(l_xml)
   # Envia XML Para a Fila
   call cts37m00_enviaxml(l_xml)
        returning lr_erro.coderro
   call errorlog("volta do Envio do xml")
   let m_mens = "Codigo de Erro de envio = ",lr_erro.coderro
   call errorlog(m_mens)
   if lr_erro.coderro <> 0 then
      let lr_erro.mens = "Erro (",lr_erro.coderro clipped ," ao enviar XML InformacaoLocalizacaoVO "
      call errorlog(lr_erro.mens)
   end if
end function
#--------------------------------------------------#
report rcts37m0001(lr_param)
#--------------------------------------------------#

define lr_param        record
       vcllicnum       like datmservico.vcllicnum
      ,sindat          like datmservicocmp.sindat
      ,sinhor          like datmservicocmp.sinhor
      ,cidnom          like datmlcl.cidnom
      ,ufcod           like datmlcl.ufdcod
      ,vclcordes       char (40)
      ,vclchsnum       char (40)
      ,vclmrc          char (30)
      ,vcltp           char (10)
      ,vclmdl          char (40)
      ,data            char (10)
      ,hora            char (05)
      ,succod          like datrligapol.succod
      ,aplnumdig       like datrligapol.aplnumdig
      ,itmnumdig       like datrligapol.itmnumdig
      ,ramcod          like datrligapol.ramcod
      ,avsrcprd        smallint
      ,lignum          like datmligacao.lignum
end record

define w_vclchsnum  char (21)
define w_lignum     char (10)
define i smallint
define j smallint

   output top    margin 0
          left   margin 0
          bottom margin 0
          page   length 1

   format
      on every row
      let w_lignum = lr_param.lignum

      if lr_param.avsrcprd <> 0 then
         print column 001,"<?xml version=""1.0"" encoding=""ISO-8859-1""?>"
         print column 001,"<ROOT>"
         print column 001,"<COD_INFORMANTE>5886</COD_INFORMANTE>"
         print column 001,"<PLACA>",lr_param.vcllicnum clipped,"</PLACA>"
         print column 001,"<OBS>",w_lignum clipped,"</OBS>"
         print column 001,"</ROOT>"
     else
         let i = null
         for i = 1 to length(lr_param.vclchsnum)
            case lr_param.vclchsnum[i]
               when " "
               otherwise
               let w_vclchsnum = w_vclchsnum clipped, lr_param.vclchsnum[i]
            end case
         end for
         print column 001,"<?xml version=""1.0"" encoding=""ISO-8859-1""?>"
         print column 001,"<ROOT>"
         print column 001,"<COD_INFORMANTE>5886</COD_INFORMANTE>"
         print column 001,"<PLACA>",lr_param.vcllicnum clipped,"</PLACA>"
         print column 001,"<DATA_OCORRENCIA>",lr_param.sindat,"</DATA_OCORRENCIA>"
         print column 001,"<HORA_OCORRENCIA>",lr_param.sinhor,"</HORA_OCORRENCIA>"
         print column 001,"<CIDADE>",lr_param.cidnom clipped,"</CIDADE>"
         print column 001,"<ESTADO>",lr_param.ufcod clipped,"</ESTADO>"
         print column 001,"<MARCA>",lr_param.vclmrc clipped,"</MARCA>"
         print column 001,"<MODELO>", lr_param.vcltp clipped, "-" clipped, lr_param.vclmdl clipped,"</MODELO>"
         print column 001,"<COR>",lr_param.vclcordes clipped,"</COR>"
         print column 001,"<CHASSI>",w_vclchsnum clipped,"</CHASSI>"
         print column 001,"<RENAVAM></RENAVAM>"
         print column 001,"<DATA_INFO_SEGURADORA>",lr_param.data clipped,"</DATA_INFO_SEGURADORA>"
         print column 001,"<HORA_INFO_SEGURADORA>",lr_param.hora clipped,"</HORA_INFO_SEGURADORA>"
         print column 001,"<OBS>",w_lignum clipped,"</OBS>"
         print column 001,"</ROOT>"
     end if
end report
function cts37m00_enviaxml(l_xml)

    define l_xml char(32766)

    define lr_retorno       record
          coderro         integer,
          menserro        char(30),
          mensagemRet     char(1),
          msgid           char(24),
          correlid        char(24)
    end    record
   define l_mens char(200)
    initialize lr_retorno.* to null
    let l_mens = null


 # Fila da RECUPERACAO DE VEICULO SINISTRO
 # SIRECUPVEICJAVA01D
  call errorlog("<535> antes de Chamar o figrc006")
  call errorlog(l_xml)
  call figrc006_enviar_datagrama_mq_rq('SIRECUPVEICJAVA01D', l_xml, '', online())
       returning lr_retorno.coderro,
                lr_retorno.menserro,
                lr_retorno.msgid,
                lr_retorno.correlid
  let m_mens = "codigo de erro retornado pelo figrc006 = ", lr_retorno.coderro
  call errorlog(m_mens)
  if lr_retorno.coderro <> 0 then
     if lr_retorno.coderro = 2033  then
       let l_mens = "ERRO MQ - Aplicacao Java fora do ar."
       call errorlog(l_mens)
     else
       let l_mens = "ERRO MQ - Envio de xml para o listener: " ,lr_retorno.coderro
                   ," mensagem = ",lr_retorno.menserro
       call errorlog(l_mens)
     end if
  end if
  return lr_retorno.coderro
end function
