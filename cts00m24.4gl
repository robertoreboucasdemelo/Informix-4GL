##############################################################################
# Nome do Modulo: cts00m24                                             Raji  #
#                                                                            #
# Direciona e imprime aviso de indicacao para oficinas              Fev/2001 #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
#17/11/2006		  Cristiane Silva   Incluir funcao de envio de email #
#					    ao Porto Socorro em casos de     #
#					    envio de fax para as Oficinas    #
#					    Credenciadas.	             #
#04/06/2010               Robert Lima       Alteração do envio de indicação  #
#                                           de serviço p/ oficina de Fax p/  #
#                                           E-mail                           #
#19/07/2011               Celso Yamahaki    Alteracao do remente e assinatu- #
#                                           ra do E-mail.                    #
#----------------------------------------------------------------------------#
#17/03/2016  936742       Alberto Rodrigues Alterar o Remente do E-Mail      #
#----------------------------------------------------------------------------#
#                                                                            #
##############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define wsgpipe  char(80)
 define wsgfax   char (03)

#--------------------------------------------------------------
 function cts00m24(param)
#--------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    ofnnumdig        like datmlcl.ofnnumdig     ,
    enviar           char (01)
 end record

 define d_cts00m24   record
    enviar           char (01)                  ,
    nomrazsoc        like gkpkpos.nomrazsoc     ,
    dddcod           like gkpkpos.dddcod        ,
    faxnum           like gkpkpos.faxnum        ,
    faxch1           like gfxmfax.faxch1        ,
    faxch2           like gfxmfax.faxch2
 end record

 define ws           record
    dddcodsva        smallint       ,
    faxnumsva        integer        ,
    faxtxt           char (12)      ,
    dddcod           like gkpkpos.dddcod        ,
    faxnum           like gkpkpos.faxnum        ,
    impflg           smallint       ,
    impnom           char (08)      ,
    envflg           dec (1,0)      ,
    confirma         char (01)
 end record
 define lr_email record
    rem char(50),
    des char(250),
    ccp char(250),
    cco char(250),
    ass char(150),
    msg char(32000),
    idr char(20),
    tip char(4)
 end record
 define lr_email_ofc record
    ofnmaides    like sgokofi.ofnmaides
 end record

 define l_cod_erro  integer,
        l_msg_erro  char(20)

 #---------------------------------------------------------------------------
 # Mensagem ao atendente
 #---------------------------------------------------------------------------


	initialize  d_cts00m24.*  to  null

	initialize  ws.*  to  null

 error "Aguarde Transmitindo informação p/ oficina credenciada ..."

 initialize d_cts00m24.*  to null
 initialize ws.*          to null

 let int_flag             =  false
 let d_cts00m24.enviar    =  param.enviar
 let ws.envflg            =  true


#---------------------------------------------------------------------------
# Define tipo do servidor de fax a ser utilizado (GSF)GS-Fax / (VSI) VSI-Fax
#---------------------------------------------------------------------------
 let wsgfax = "VSI"

 select nomrazsoc ,
        dddcod    ,
        faxnum
   into d_cts00m24.nomrazsoc,
        d_cts00m24.dddcod,
        d_cts00m24.faxnum
   from gkpkpos
  where pstcoddig = param.ofnnumdig

 ####################################
 # TESTE
 if g_hostname = "u07" or g_issk.funmat = 111089 then
    let d_cts00m24.dddcod = 11
    let d_cts00m24.faxnum = 33668630
 end if

 let ws.dddcodsva = d_cts00m24.dddcod
 let ws.faxnumsva = d_cts00m24.faxnum

 if ws.dddcodsva < 10 then
    error "Oficina com DDD invalido, fax de indicacao nao enviado!"
    return
 end if
 if ws.faxnumsva < 1000000 then
    error "Oficina com FAX invalido, fax de indicacao nao enviado!"
    return
 end if


 ####################################################
 # Fax so' pode ser enviado no ambiente de producao!
 ####################################################
 if g_hostname = "u07"  then
    let d_cts00m24.enviar    =  "I"
 end if
 if d_cts00m24.enviar = "I"  then
    ####################################################
    # Seleciona impressora
    ####################################################
    while true
       call fun_print_seleciona (g_issk.dptsgl, "")
            returning  ws.impflg, ws.impnom
       if ws.impflg = false  then
          error " Departamento/Impressora nao cadastrada!"
       end if
       if ws.impnom is null  then
          error " Uma impressora deve ser selecionada!"
       else
          exit while
       end if
    end while
 end if

#[ALTERADO ROBERT LIMA]###########################################

#Verifica se a opção veio como fax
#Para não ter que alterar todas as chmadas do modulo passado de F(fax) para E(e-mail)
#Continuei com o F, pois o fax somente será utilizado em caso de a oficina não ter email
#O sistema ira verificar se existe um email cadastrado, se não ele envia o fax.

 initialize lr_email.rem to null 

 if d_cts00m24.enviar  =  "F"  then
     whenever error continue
        select ofnmaides
         into lr_email_ofc.ofnmaides
         from sgokofi
        where ofnnumdig = param.ofnnumdig
        
    whenever error stop
    let l_cod_erro = 0
    if lr_email_ofc.ofnmaides is not null then
    	
       # Solicitacao Cibeli 17/03/2016 936742
       #select cpodes into lr_email.rem  
       #from   datkdominio 
       #where  cponom = 'oficina_ref'
       
       if lr_email.rem is null or lr_email.rem = "" then 
          #let lr_email.rem = "marcelo.mesquita@portoseguro.com.br"
          let lr_email.rem = "ailton.ribeiro@portoseguro.com.br"
       end if    
       
       let lr_email.des = lr_email_ofc.ofnmaides
       let lr_email.ccp = ""
       let lr_email.cco = ""
       let lr_email.ass = "Porto Seguro - Indicacao de Servico"
       let lr_email.idr = "F0110413"
       let lr_email.tip = "html"
       call cts00m24_corpoemail_html(d_cts00m24.nomrazsoc,param.atdsrvnum,param.atdsrvano)
            returning lr_email.msg
       call figrc009_mail_send1(lr_email.*)
            returning l_cod_erro, l_msg_erro      
       let d_cts00m24.enviar = "E"  #Modo de envio alterado para E, para envio de email ao
    end if                          #porto socorro com o Modo de envio Correto.
    if lr_email_ofc.ofnmaides is null or l_cod_erro <> 0 then
         let d_cts00m24.enviar = "F"
	 call cts10g01_enviofax(param.atdsrvnum, param.atdsrvano,
	                           "", "OF", g_issk.funmat)
	         returning ws.envflg, d_cts00m24.faxch1, d_cts00m24.faxch2



        if wsgfax = "GSF"  then
	    if g_hostname = "u07"  then
	      let ws.impnom = "tstclfax"
	    else
	      let ws.impnom = "ptsocfax"
	    end if
	    let wsgpipe = "lp -sd ", ws.impnom
        else
	    call cts02g01_fax(d_cts00m24.dddcod, d_cts00m24.faxnum)
	         returning ws.faxtxt
	    let wsgpipe = "vfxCTOF ", ws.faxtxt clipped, " ",
	        ascii 34, d_cts00m24.nomrazsoc clipped, ascii 34, " ",
	        d_cts00m24.faxch1 using "&&&&&&&&&&", " ",
	        d_cts00m24.faxch2 using "&&&&&&&&&&"
        end if
         start report  rep_cts00m24
         output to report rep_cts00m24(param.atdsrvnum  , param.atdsrvano  ,
                                       d_cts00m24.dddcod, d_cts00m24.faxnum,
                                       d_cts00m24.enviar, d_cts00m24.nomrazsoc,
                                       d_cts00m24.faxch1, d_cts00m24.faxch2)
         finish report  rep_cts00m24
    end if
 else
    let wsgpipe = "lp -sd ", ws.impnom
 end if

   call cts00m24_envia_email(d_cts00m24.nomrazsoc,
				d_cts00m24.dddcod,
				d_cts00m24.faxnum,
				param.atdsrvnum,
			   	param.atdsrvano,
			   	d_cts00m24.enviar,
			   	lr_email_ofc.ofnmaides)
 let int_flag = false

end function  ###  cts00m24


#---------------------------------------------------------------------------
 report rep_cts00m24 (r_cts00m24)
#---------------------------------------------------------------------------

 define r_cts00m24    record
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    dddcod            like gkpkpos.dddcod          ,
    faxnum            dec(8,0)                     ,
    enviar            char (01)                    ,
    nomrazsoc         like gkpkpos.nomrazsoc       ,
    faxch1            like gfxmfax.faxch1          ,
    faxch2            like gfxmfax.faxch2
 end record

 define ws            record
    atdsrvorg         like datmservico.atdsrvorg   ,
    asitipcod         like datmservico.asitipcod   ,
    asimtvcod         like datkasimtv.asimtvcod    ,
    asimtvdes         like datkasimtv.asimtvdes    ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    nom               like datmservico.nom         ,
    ramcod            like datrservapol.ramcod     ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,
    vcldes            like datmservico.vcldes      ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    vclcorcod         like datmservico.vclcorcod   ,
    vclcordes         char (20)                    ,

    dia               char (2)                     ,
    mes               char (10)                    ,
    ano               char (4)                     ,
    traco             char (80)                    ,
    sqlcode           integer,
    num               smallint
 end record

 define arr_aux       smallint

 output report to pipe  wsgpipe
   left   margin  00
   right  margin  80
   top    margin  00
   bottom margin  00
   page   length  58


 format
   on every row
        initialize  ws.*        to null
        let ws.traco = "--------------------------------------------------------------------------------"
        let ws.dia   = day (today)
        let ws.ano   = year(today)
        case month(today)
           when 1
              let ws.mes = "Janeiro"
           when 2
              let ws.mes = "Fevereiro"
           when 3
              let ws.mes = "Marco"
           when 4
              let ws.mes = "Abril"
           when 5
              let ws.mes = "Maio"
           when 6
              let ws.mes = "Junho"
           when 7
              let ws.mes = "Julho"
           when 8
              let ws.mes = "Agosto"
           when 9
              let ws.mes = "Setembro"
           when 10
              let ws.mes = "Outubro"
           when 11
              let ws.mes = "Novembro"
           when 12
              let ws.mes = "Dezembro"
        end case

        let ws.dia   = day(today)

        if r_cts00m24.enviar = "F"  then
           if wsgfax = "GSF"  then
              #----------------------------------------
              # Checa caracteres invalidos para o GSFAX
              #----------------------------------------
              call cts02g00(r_cts00m24.nomrazsoc)  returning r_cts00m24.nomrazsoc

              if r_cts00m24.dddcod     >  0099  then
                 print column 001, r_cts00m24.dddcod using "&&&&"; #
              else                                                 # Codigo DDD
                 print column 001, r_cts00m24.dddcod using "&&&";  #
              end if

              if r_cts00m24.faxnum > 99999999  then
                 print column 001, r_cts00m24.faxnum using "&&&&&&&&&";  #
              else                                                      #
                 if r_cts00m24.faxnum > 9999999  then                    # Numero
                    print column 001, r_cts00m24.faxnum using "&&&&&&&&";#  Fax
                 else                                                   #
                    print column 001, r_cts00m24.faxnum using "&&&&&&&"; #
                 end if
              end if

              print column 001                        ,
              "@"                                     , #--> Delimitador
              r_cts00m24.nomrazsoc                         , #--> Destinatario Cx pos
              "*CTOF"                                 , #--> Sistema/Subsistema
              r_cts00m24.faxch1    using "&&&&&&&&&&" , #--> No./Ano Servico
              r_cts00m24.faxch2    using "&&&&&&&&&&" , #--> Sequencia
              "@"                                     , #--> Delimitador
              r_cts00m24.nomrazsoc                         , #--> Destinat.(Informix)
              "@"                                     , #--> Delimitador
              "CENTRAL 24 HORAS"                      , #--> Quem esta enviando
              "@"                                     , #--> Delimitador
              "132PORTO.TIF"                          , #--> Arquivo Logotipo
              "@"                                     , #--> Delimitador
              "semcapa"                                 #--> Nao tem cover page
           end if

           if wsgfax = "VSI"  then
              print column 001, ascii 27, "&k2S";        #--> Caracteres
              print             ascii 27, "(s7b";        #--> de controle
              print             ascii 27, "(s4102T";     #--> para 132
              print             ascii 27, "&l08D";       #--> colunas
              print             ascii 27, "&l00E";       #--> Logo no topo
              print column 001, "@+IMAGE[porto.tif;x=0cm;y=0cm]"
              skip 8 lines
           end if
        end if

        #--------------------------------------------------------------
        # Busca informacoes do servico
        #--------------------------------------------------------------
        select datmservico.atdsrvorg   , datmservico.asitipcod   ,
               datmservico.atddat      , datmservico.atdhor      ,
               datmservico.nom         , datrservapol.ramcod     ,
               datrservapol.succod     , datrservapol.aplnumdig  ,
               datrservapol.itmnumdig  , datmservico.vcldes      ,
               datmservico.vclanomdl   , datmservico.vcllicnum   ,
               datmservico.vclcorcod
          into ws.atdsrvorg    , ws.asitipcod    ,
               ws.atddat       , ws.atdhor       ,
               ws.nom          , ws.ramcod       ,
               ws.succod       , ws.aplnumdig    ,
               ws.itmnumdig    , ws.vcldes       ,
               ws.vclanomdl    , ws.vcllicnum    ,
               ws.vclcorcod
          from datmservico, outer datmservicocmp, outer datrservapol
         where datmservico.atdsrvnum    = r_cts00m24.atdsrvnum
           and datmservico.atdsrvano    = r_cts00m24.atdsrvano

           and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
           and datmservicocmp.atdsrvano = datmservico.atdsrvano

           and datrservapol.atdsrvnum   = datmservico.atdsrvnum
           and datrservapol.atdsrvano   = datmservico.atdsrvano

        if ws.vclcorcod   is not null    then
           select cpodes
             into ws.vclcordes
             from iddkdominio
            where cponom = "vclcorcod"    and
                  cpocod = ws.vclcorcod
        end if

        skip 1 line
        if r_cts00m24.enviar  =  "I"   then
           print column 001, "Enviar para: ", r_cts00m24.nomrazsoc,
             "    Fax: ", "(",r_cts00m24.dddcod, ")", r_cts00m24.faxnum
        end if

        skip 1 line
        print column 001, "São Paulo, ", ws.dia, " de ", ws.mes, " de ", ws.ano
        skip 2 line
        print column 001, ascii(195)
        print column 001, r_cts00m24.nomrazsoc
        skip 2 line
        print column 001, "Ac Gerente de oficina ou Responsável por reparos"
        skip 2 line
        print column 001, "A Central de Atendimento Porto Seguro acaba de " ,
                          "fazer mais uma indicação dos serviços de"
        print column 001, "sua oficina ao segurado ", ws.nom clipped, ", proprietário do veículo"
        print column 001, ws.vcldes clipped, " Ano: ", ws.vclanomdl, " Placa: ", ws.vcllicnum, " Cor: ", ws.vclcordes clipped, "."
        skip 1 line
        print column 001, "Para nos certificarmos do efetivo cumprimento do envio do automóvel aos seus cuidados,"
        print column 001, "solicitamos seu contato caso o veículo não tenha sido entregue a oficina em até tr", ascii(235), "s"
        print column 001, "horas da recepção deste fax - Central 24 Horas."
        #skip 2 line
        #print column 003, "Nos dias uteis em horario comercial,"
        #print column 003, "A noite e aos finais de semana, ligar na manha do primeiro dia util."
        skip 2 line
        print column 001, "Contamos com sua colaboração e nos dispomos a maiores esclarecimentos."
        skip 2 line
        print column 001, "Atenciosamente"
        skip 2 line
        print column 001, "Ailton Ribeiro"
        print column 001, "Sinistro Auto"
        print column 001, "e-mail ailton.ribeiro@portoseguro.com.br"

end report  ###  rep_laudo

#-----------------------------------------#
function cts00m24_envia_email(lr_parametro,l_envio,l_email)
#-----------------------------------------#

  define lr_parametro record
         nome_oficina 	like gkpkpos.nomrazsoc,
         ddd_fax 	like gkpkpos.dddcod,
         numero_fax 	like gkpkpos.faxnum,
         atdsrvnum 	like datmservico.atdsrvnum,
         atdsrvano 	like datmservico.atdsrvano
  end record
  define l_envio char(1),
         l_email char(250)
  define l_assunto     char(300),
         l_erro_envio  integer

define m_path char(100)
let m_path = null

  # ---> INICIALIZACAO DAS VARIAVEIS

  let l_erro_envio = null
  # ---> Beatriz Araujo
        # CT752398 - limpar "*" do nome das oficinas
                call figrc005_troca1byte(lr_parametro.nome_oficina, "*"," ")
                returning   lr_parametro.nome_oficina
        # fim CT - Beatriz
  if l_envio = "E" then
     let l_assunto    = "Envio de e-mail Oficina Credenciada ", lr_parametro.nome_oficina,
                        " , E-mail ", l_email, " Serviço ",
                        lr_parametro.atdsrvnum, "/", lr_parametro.atdsrvano
  else
     let l_assunto    = "Envio de FAX à Oficina Credenciada ", lr_parametro.nome_oficina,
  		        " , Fax(DDD e Numero) (", lr_parametro.ddd_fax, ")", lr_parametro.numero_fax,
  		        " Serviço ", lr_parametro.atdsrvnum, "/", lr_parametro.atdsrvano
  end if
  let l_erro_envio = ctx22g00_envia_email("CTS00M24", l_assunto, m_path)
  if l_erro_envio <> 0 then
       if l_erro_envio <> 99 then
        display "Erro ao enviar email(ctx22g00) - "
     else
        display "Nao existe email cadastrado para o modulo - CTS00M24"
     end if
  end if

end function



#-----------------------------------------#
function cts00m24_corpoemail_html(param)
#-----------------------------------------#

define param record
    nomrazsoc like gkpkpos.nomrazsoc,
    atdsrvnum like datmservico.atdsrvnum ,
    atdsrvano like datmservico.atdsrvano
end record

define ws record
    nom        like datmservico.nom  ,
    vcldes     like datmservico.vcldes      ,
    vclanomdl  like datmservico.vclanomdl   ,
    vcllicnum  like datmservico.vcllicnum   ,
    vclcorcod  like datmservico.vclcorcod   ,
    vclcordes  char (20)
end record

define l_html   char(32000),
       l_mes    char(10)

        select
               datmservico.nom         ,
               datmservico.vcldes      ,
               datmservico.vclanomdl   ,
               datmservico.vcllicnum   ,
               datmservico.vclcorcod
          into ws.nom          ,
               ws.vcldes       ,
               ws.vclanomdl    ,
               ws.vcllicnum    ,
               ws.vclcorcod
          from datmservico, outer datmservicocmp, outer datrservapol
         where datmservico.atdsrvnum    = param.atdsrvnum
           and datmservico.atdsrvano    = param.atdsrvano

           and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
           and datmservicocmp.atdsrvano = datmservico.atdsrvano

           and datrservapol.atdsrvnum   = datmservico.atdsrvnum
           and datrservapol.atdsrvano   = datmservico.atdsrvano

         if ws.vclcorcod   is not null    then
           select cpodes
             into ws.vclcordes
             from iddkdominio
            where cponom = "vclcorcod"    and
                  cpocod = ws.vclcorcod
        end if
        case month(today)
           when 1
              let l_mes = "Janeiro"
           when 2
              let l_mes = "Fevereiro"
           when 3
              let l_mes = "Marco"
           when 4
              let l_mes = "Abril"
           when 5
              let l_mes = "Maio"
           when 6
              let l_mes = "Junho"
           when 7
              let l_mes = "Julho"
           when 8
              let l_mes = "Agosto"
           when 9
              let l_mes = "Setembro"
           when 10
              let l_mes = "Outubro"
           when 11
              let l_mes = "Novembro"
           when 12
              let l_mes = "Dezembro"
        end case
   let l_html = "<html><body>",
	        "<p>Sao Paulo, ",day(today), " de ", l_mes clipped, " de ", year(today),"</p>",
	        "<br>",
	        "A ",
	        param.nomrazsoc, #[RAZAO SOCIAL]
	        "<br>",
	        "<p>Ac Gerente de oficina ou Responsavel por reparos</p>",
	        "<br><br>",
	        "A Central de Atendimento Porto Seguro acaba de " ,
	        "fazer mais uma indicacao dos servicos de ",
	        "sua oficina ao segurado <b>", ws.nom clipped, #[NOME DO SEGURADO]
	        "</b>,<br> proprietario do veiculo <b>",
	        ws.vcldes clipped, #[DESCRIÇÃO DO VEICULO]
	        "</b> Ano: ", ws.vclanomdl #[ANO DO VEICULO]
	        if ws.vcllicnum is not null then
	           let l_html = l_html clipped, " Placa: ", ws.vcllicnum #[PLACA DO VEICULO]
	        end if
	        if ws.vclcordes is not null then
	           let l_html = l_html clipped, " Cor: ", ws.vclcordes clipped, "." #[COR DO VEICULO]
	        end if
   let l_html = l_html clipped, "<br>",
	        "Para nos certificarmos do efetivo cumprimento do envio do automovel aos seus cuidados, ",
	        "solicitamos seu contato caso o veiculo ",
	        "<br>nao tenha sido entregue a oficina em ate tres ",
	        "horas da recepcao deste email - Central 24 Horas.",
	        "<br><br>",
	        "Contamos com sua colaboracao e nos dispomos a maiores esclarecimentos.",
	        "<br><br>",
	        "Atenciosamente",
	        "<br><br>",
	        "Ailton Ribeiro<br>",
	        "Sinistro Auto<br>",
	        "e-mail ailton.ribeiro@portoseguro.com.br",
                "</body></html>"
    return l_html
end function
