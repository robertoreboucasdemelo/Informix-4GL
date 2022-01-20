################################################################################
# Nome do Modulo: bdata136.4gl                           Humberto - F0112435   #
#                                                                              #
# Relatório diário de Prorrogação JUN/2011                                     #
################################################################################
# DATA        AUTOR           DEMANDA       DESCRICAO                          #
# 08/06/2015  RCP, Fornax     RELTXT        Criar versao .txt dos relatorios.  #
################################################################################
# 30/09/2015 Luiz Fornax      Solicitaçãio Cibeli                              #
#------------------------------------------------------------------------------#
database porto

globals  "/homedsa/projetos/geral/globals/sg_glob3.4gl"
globals  '/homedsa/projetos/geral/globals/glct.4gl'

globals
   define g_ismqconn smallint
end globals

 define m_bdata136_prep smallint
 define w_log     	    char(100)
 define m_rel           smallint

#==========================================-Main================================================#

main

  let m_rel = false
  call fun_dba_abre_banco("CT24HS")

 let w_log = f_path("DAT","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/bdata136.log"

 call startlog(w_log)

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last - 1,
      message line last,
      accept  key  F40
   
   call bdata136()
   call bdata136_relatorio_remocoes()
      
end main

#=========================================Prepara comandos SQL=====================================#
function bdata136_prepare()
#==================================================================================================#

  define l_sql char(8000)

  #--buscar dados da ligação
  let l_sql =  "select d.succod "
								    ,",d.aplnumdig "
								    ,",d.itmnumdig "
								    ,",b.aviproseq "
								    ,",a.atdsrvnum "
								    ,",a.atdsrvano "
								    ,",b.aviprosoldat "
								    ,",b.aviprodiaqtd "
								    ,",a.aviprvent "
								    ,",e.aviestcod "
								    ,",e.aviestnom "
								    ,",e.endlgd "
							  ,"from datmavisrent a "
								    ,",datmprorrog b  "
								    ,",datmligacao c  "
								    ,",datrligapol d  "
								    ,",datkavislocal e "
							 ,"where a.atdsrvano = b.atdsrvano "
								 ,"and a.atdsrvnum = b.atdsrvnum "
								 ,"and b.atdsrvano = c.atdsrvano "
								 ,"and b.atdsrvnum = c.atdsrvnum "
								 ,"and a.aviestcod = e.aviestcod "
								 ,"and c.lignum = d.lignum "
								 ,"and c.c24astcod in ('H10', 'H12') "
								 ,"and a.avialgmtv in (0,14) "
							   ,"and b.aviprosoldat = ? "
								 ,"and b.aviproseq = ? "
								 ,"order by 1, 2 "
      prepare pbdata136001 from l_sql
      declare cbdata136001 cursor for pbdata136001

      #--buscar no banco a descrição
      let l_sql = " SELECT  cpodes "
					    		  ,"FROM  datkdominio "
					    		  ,"WHERE cponom = ? "
      prepare pbdata136002 from l_sql
      declare cbdata136002 cursor with hold for pbdata136002

		  #--buscar no banco emails de envio do relatorio
      let l_sql = " SELECT cpodes      "
                    ,"FROM datkdominio "
                   ,"WHERE cponom = ?  "
      prepare pbdata136004 from l_sql
      declare cbdata136004 cursor with hold for pbdata136004

 let m_bdata136_prep = 1

end function

#=====================================Função Principal=================================================#
function bdata136()
#=============================Define as variaveis locais===============================================#

define dados_bdata136      	    record
			 succod										like datrligapol.succod,
			 aplnumdig 							  like datrligapol.aplnumdig,
			 itmnumdig								like datrligapol.itmnumdig,
			 aviproseq								like datmprorrog.aviproseq,
			 atdsrvnum								like datmprorrog.atdsrvnum,
			 atdsrvano								like datmprorrog.atdsrvano,
			 aviprosoldat							like datmprorrog.aviprosoldat,
			 aviprodiaqtd							like datmprorrog.aviprodiaqtd,
			 aviprvent                like datmavisrent.aviprvent,
			 aviestcod								like datkavislocal.aviestcod,
			 aviestnom			 			    like datkavislocal.aviestnom,
			 endlgd										like datkavislocal.endlgd
end record


define relatorio_bdata136 		  record
       succod                   like datrligapol.succod,      		#Código da sucursal
	     aplnumdig     		  			like datrligapol.aplnumdig,   		#Numero da apolice
	     itmnumdig    		    		like datrligapol.itmnumdig,   		#Numero do item
	     aviproseq					  		like datmprorrog.aviproseq,				#Sequencia de prorrogacao
	     reserva             			char(25),                     		#Numero da reserva
	     aviprosoldat							like datmprorrog.aviprosoldat,		#Data de solicitação da prorrogacao
	     aviprvent								like datmavisrent.aviprvent,			#Quantidade de Diarias da ultima prorrogacao
			 total                    integer,      										#Total de diarias
	     vclmrcnom          			like agbkmarca.vclmrcnom, 				#Nome marca do veiculo
			 vcltipnom          			like agbktip.vcltipnom  , 				#Nome do tipo do veiculo
			 vclmdlnom          			like agbkveic.vclmdlnom , 				#Nome do modelo
			 vclchs             			char (20)               , 				#Chassi
			 vcllicnum          			like abbmveic.vcllicnum , 				#Numero da licença
			 vclanofbc          			like abbmveic.vclanofbc , 				#Ano de Fabricacao
			 vclanomdl          			like abbmveic.vclanomdl , 				#Ano do Modelo
			 vclcoddig          			like agbkveic.vclcoddig , 				#Codigo do veiculo
			 vclmrccod          			like agbkmarca.vclmrccod, 				#Codigo da marca
			 vcltipcod          			like agbktip.vcltipcod,    				#Codigo do tipo
			 aviestcod								like datkavislocal.aviestcod,     #Codigo da estacao
			 aviestnom			 			    like datkavislocal.aviestnom,			#Nome da estaca
			 endlgd										like datkavislocal.endlgd         #Endereco
end record

define lr_bdata136							record
  	 	 vclmrcnom          			like agbkmarca.vclmrcnom, 		#Nome marca do veiculo
			 vcltipnom          			like agbktip.vcltipnom  , 		#Nome do tipo do veiculo
			 vclmdlnom          			like agbkveic.vclmdlnom , 		#Nome do modelo
			 vclchs             			char (20)               , 		#Chassi
			 vcllicnum          			like abbmveic.vcllicnum , 		#Numero da licença
			 vclanofbc          			like abbmveic.vclanofbc , 		#Ano de Fabricacao
			 vclanomdl          			like abbmveic.vclanomdl , 		#Ano do Modelo
			 vclcoddig          			like agbkveic.vclcoddig , 		#Codigo do veiculo
			 vclmrccod          			like agbkmarca.vclmrccod, 		#Codigo da marca
			 vcltipcod          			like agbktip.vcltipcod  , 		#Codigo do tipo
			 vclchsinc          			like abbmveic.vclchsinc , 		#Parte inicial chassi
			 vclchsfnl          			like abbmveic.vclchsfnl, 	    #Parte final chassi
			 totaldias                integer
end record

define lr_param                 record
			 cpodes										like datkdominio.cpodes
end record

define lr_mens        					record
       para             				char(10000)
      ,cc             				  char(10000)
      ,anexo          				  char(32000)
      ,assunto        				  char(500)
      ,msg            				  char(500)
end record

define dirfisnom		            char(32000)                   #Diretorio
define dirfisnom_txt                        char(32000)                   #--> RELTXT
define param_email							like datkdominio.cponom       #Nome do campo para email
define l_cont                   integer
define emails                   array[40] of char(70)
define l_totalgeral             integer
define param_cponom	  					like datkdominio.cponom				#Nome do campo
define dataini                  date
define contador                 smallint
define l_tam_email              integer
define l_cont2                  smallint
define l_dataarq char(8)
define l_data    date

let l_data = today
display "l_data: ", l_data
let l_dataarq = extend(l_data, year to year),
                extend(l_data, month to month),
                extend(l_data, day to day)
display "l_dataarq: ", l_dataarq

#===============================Inicializa variaveis==================================================#
  initialize  dados_bdata136.* ,relatorio_bdata136.*  ,lr_bdata136.* ,lr_param.*  to null

	let param_cponom = "seq_prorrogacao"
  let param_email  = "email_prorrogacao"
  let l_totalgeral = 0
  let l_tam_email = 0

  let dataini = today - 1

#====================Define diretorios para relatorios e arquivos=====================================#
  call f_path("DAT", "RELATO")
     returning dirfisnom

   display 'Diretorio do arquivo: ',dirfisnom
  let dirfisnom_txt = dirfisnom clipped, "/rel_prorrogacao_", l_dataarq, ".txt" 
  let dirfisnom = dirfisnom clipped, "/rel_prorrogacao.xls"

  display 'Arquivo: ',dirfisnom

#let dirfisnom = "/asheeve/rel_prorrogacao.xls"

  #Inicializa Prepare
        call bdata136_prepare()
#==============================Inicia criação do relatorio==============================================#
start report  rep_bdata136  to dirfisnom
start report  rep_bdata136_txt to dirfisnom_txt #--> RELTXT
     open cbdata136002 using param_cponom

       display "Criando relatório..."
	foreach cbdata136002 into  lr_param.cpodes
#==================================Buscar dados da apolice=============================================#
     display 'cpodes: ',lr_param.cpodes sleep 1

		open cbdata136001 using dataini,
		                        lr_param.cpodes
				foreach cbdata136001 into dados_bdata136.*

				 select sum(aviprodiaqtd)
		    			into lr_bdata136.totaldias
  					  from datmprorrog
  					 where atdsrvnum = dados_bdata136.atdsrvnum
  					 	 and atdsrvano = dados_bdata136.atdsrvano


			  let l_totalgeral = lr_bdata136.totaldias + dados_bdata136.aviprvent

#==============================Ultima situacao da apolice===============================================#
				call f_funapol_ultima_situacao (dados_bdata136.succod,
				                                dados_bdata136.aplnumdig,
				                                dados_bdata136.itmnumdig)
                      returning g_funapol.*
            if g_funapol.dctnumseq is null  then
		           select min(dctnumseq)
		             into g_funapol.dctnumseq
		             from abbmdoc
		            where succod    = dados_bdata136.succod
		              and aplnumdig = dados_bdata136.aplnumdig
		              and itmnumdig = dados_bdata136.itmnumdig
		        end if

#======================================Dados da Veículo==============================================#

		      select vclcoddig, vclanofbc, vclanomdl,
					       vcllicnum, vclchsinc, vclchsfnl
					  into lr_bdata136.vclcoddig, lr_bdata136.vclanofbc,
					       lr_bdata136.vclanomdl, lr_bdata136.vcllicnum,
					       lr_bdata136.vclchsinc, lr_bdata136.vclchsfnl
					  from abbmveic
					 where abbmveic.succod     = dados_bdata136.succod     and
					       abbmveic.aplnumdig  = dados_bdata136.aplnumdig  and
					       abbmveic.itmnumdig  = dados_bdata136.itmnumdig  and
					       abbmveic.dctnumseq  = g_funapol.vclsitatu


			 if sqlca.sqlcode = notfound  then
			    select vclcoddig, vclanofbc, vclanomdl,
			           vcllicnum, vclchsinc, vclchsfnl
			      into lr_bdata136.vclcoddig, lr_bdata136.vclanofbc,
			           lr_bdata136.vclanomdl, lr_bdata136.vcllicnum,
			           lr_bdata136.vclchsinc, lr_bdata136.vclchsfnl
			      from abbmveic
			     where succod    = dados_bdata136.succod       and
			           aplnumdig = dados_bdata136.aplnumdig    and
			           itmnumdig = dados_bdata136.itmnumdig    and
			           dctnumseq = (select max(dctnumseq)
			                          from abbmveic
			                         where succod    = dados_bdata136.succod     and
			                               aplnumdig = dados_bdata136.aplnumdig  and
			                               itmnumdig = dados_bdata136.itmnumdig)
			  end if


			 if sqlca.sqlcode <> notfound  then
			    select vclmrccod, vcltipcod, vclmdlnom
			      into lr_bdata136.vclmrccod, lr_bdata136.vcltipcod, lr_bdata136.vclmdlnom
			      from agbkveic
			     where agbkveic.vclcoddig = lr_bdata136.vclcoddig

			    select vclmrcnom
			      into lr_bdata136.vclmrcnom
			      from agbkmarca
			     where vclmrccod = lr_bdata136.vclmrccod

			    select vcltipnom
			      into lr_bdata136.vcltipnom
			      from agbktip
			     where vclmrccod = lr_bdata136.vclmrccod    and
			           vcltipcod = lr_bdata136.vcltipcod

			    let lr_bdata136.vclchs  =  lr_bdata136.vclchsinc clipped, lr_bdata136.vclchsfnl clipped
			 else
			    error "Dados do veiculo nao encontrado!"
			 end if

#======================================================================================================#

      Initialize relatorio_bdata136.* to null

				      let relatorio_bdata136.succod         = dados_bdata136.succod
				      let relatorio_bdata136.aplnumdig      = dados_bdata136.aplnumdig
				      let relatorio_bdata136.itmnumdig      = dados_bdata136.itmnumdig
				      let relatorio_bdata136.aviproseq			= dados_bdata136.aviproseq
				      let relatorio_bdata136.reserva        = dados_bdata136.atdsrvnum using '<<&&&&&&&&', "-",dados_bdata136.atdsrvano using '&&'
				      let relatorio_bdata136.aviprosoldat   = dados_bdata136.aviprosoldat
				      let relatorio_bdata136.aviprvent      = dados_bdata136.aviprvent
				      let relatorio_bdata136.total					= l_totalgeral
				      let relatorio_bdata136.vclmrcnom			= lr_bdata136.vclmrcnom
				      let relatorio_bdata136.vcltipnom			= lr_bdata136.vcltipnom
				      let relatorio_bdata136.vclanomdl			= lr_bdata136.vclanomdl
				      let relatorio_bdata136.vclmdlnom			= lr_bdata136.vclmdlnom
				      let relatorio_bdata136.vclchs				  = lr_bdata136.vclchs
				      let relatorio_bdata136.vcllicnum			= lr_bdata136.vcllicnum
				      let relatorio_bdata136.vclanofbc			= lr_bdata136.vclanofbc
				      let relatorio_bdata136.aviestcod      = dados_bdata136.aviestcod
				      let relatorio_bdata136.aviestnom      = dados_bdata136.aviestnom
				      let relatorio_bdata136.endlgd         = dados_bdata136.endlgd


				 output to report rep_bdata136(relatorio_bdata136.*)
				 output to report rep_bdata136_txt(relatorio_bdata136.*) #--> RELTXT
				 let m_rel = true
			end foreach
	 end foreach
finish report  rep_bdata136
finish report  rep_bdata136_txt #--> RELTXT

#-===========================================prepara envio de e-mail========================================#
 display "Criando e-mail..."
  let l_cont = 1
  let l_cont2 = 1

  open cbdata136004 using param_email
  foreach cbdata136004 into emails[l_cont]

   { if l_cont = 1 then
      let lr_mens.para = emails[l_cont] clipped
    else
      let l_tam_email = length(lr_mens.para)
      if l_tam_email <= 500 then
        let lr_mens.para =lr_mens.para clipped
                          ,","
                          ,emails[l_cont] clipped
      else
        if l_cont2 = 1 then
          let lr_mens.cc = emails[l_cont] clipped
        else
          let lr_mens.cc = lr_mens.cc clipped
                           ,","
                           ,emails[l_cont] clipped
        end if
        let l_cont2 = l_cont2 + 1
      end if
    end if}
    if l_cont = 1 then
      let lr_mens.para = emails[l_cont] clipped
    else
      let lr_mens.para =lr_mens.para clipped
                        ,","
                        ,emails[l_cont] clipped
    end if
    let l_cont = l_cont + 1
  end foreach

  let lr_mens.anexo = dirfisnom

  let lr_mens.assunto = "Relatorio Controle de Prorrogacao - "
                       ,dataini
  let lr_mens.msg =  "<html><body><font face = Times New Roman> Prezado(s), <br><br>"
                    ,"Segue anexo Relat&oacute;rio Controle de Prorroga&ccedil;&atilde;o. <br><br>"
                    ,"Refer&ecirc;ncia: " , dataini ,  ". <br><br>"
                    ,"Atenciosamente, <br><br>"
                    ,"Corpora&ccedil;&atilde;o Porto Seguro - http://www.portoseguro.com.br"
                    ,"<br><br> "


   call send_email_prorrogacao(lr_mens.*)

end function

#===============================================Envia e-mail====================================================#
 function send_email_prorrogacao(lr_mens)
#===========================================Define variaveis====================================================#

  define 	lr_mens        record
          para           char(1000)
        	,cc            char(1000)
        	,anexo         char(32000)
        	,assunto       char(500)
        	,msg           char(400)
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
  define  l_sistema   		char(10)
         ,l_remet     		char(50)
         ,l_cmd     			char(8000)
         ,l_ret     			smallint
         ,l_assunto 			char(200)

#===========================================Inicia Variaveis====================================================#
  let l_sistema  = "CT24HS"
  let l_remet = "ct24hs.email@portoseguro.com.br"
  initialize l_cmd to null
  let l_ret = null
#========================================Executa comando shel====================================================#

 display 'Enviando e-mail para: ', lr_mens.para clipped

  #PSI-2013-23297 - Inicio
  let l_mail.de = l_remet
  let l_mail.para =  lr_mens.para
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto =  lr_mens.assunto
  let l_mail.mensagem = lr_mens.msg
  let l_mail.id_remetente = l_sistema
  let l_mail.tipo = "html"
  if m_rel = true then
     call figrc009_attach_file(lr_mens.anexo)
     display "Arquivo anexado com sucesso"
  else
     let l_mail.mensagem = "Nao existem registros a serem processados."
  end if

  call figrc009_mail_send1 (l_mail.*)
       returning l_coderro,msg_erro
 #PSI-2013-23297 - Fim

  display 'l_ret: ',l_coderro

#============================================Confirma envio de e-mail===========================================#

  if l_coderro = 0  then
    let l_assunto = '### ATENÇãO ### - Email enviado com sucesso! ',
                     current
  else
    let l_assunto = '### ATENÇãO ### - Email nao enviado!', current
  end if

  display l_assunto

end function

#==============================================Montar relatorio====================================================#
report rep_bdata136(relatorio_bdata136)

define relatorio_bdata136 		  record
       succod                   like datrligapol.succod,      		#Código da sucursal
	     aplnumdig     		  			like datrligapol.aplnumdig,   		#Numero da apolice
	     itmnumdig    		    		like datrligapol.itmnumdig,   		#Numero do item
	     aviproseq					  		like datmprorrog.aviproseq,				#Sequencia de prorrogacao
	     reserva             			char(25),                     		#Numero da reserva
	     aviprosoldat							like datmprorrog.aviprosoldat,		#Data de solicitação da prorrogacao
	     aviprvent								like datmavisrent.aviprvent,			#Quantidade de Diarias da ultima prorrogacao
			 total                    integer,      										#Total de diarias
	     vclmrcnom          			like agbkmarca.vclmrcnom, 				#Nome marca do veiculo
			 vcltipnom          			like agbktip.vcltipnom  , 				#Nome do tipo do veiculo
			 vclmdlnom          			like agbkveic.vclmdlnom , 				#Nome do modelo
			 vclchs             			char (20)               , 				#Chassi
			 vcllicnum          			like abbmveic.vcllicnum , 				#Numero da licença
			 vclanofbc          			like abbmveic.vclanofbc , 				#Ano de Fabricacao
			 vclanomdl          			like abbmveic.vclanomdl , 				#Ano do Modelo
			 vclcoddig          			like agbkveic.vclcoddig , 				#Codigo do veiculo
			 vclmrccod          			like agbkmarca.vclmrccod, 				#Codigo da marca
			 vcltipcod          			like agbktip.vcltipcod,    				#Codigo do tipo
			 aviestcod								like datkavislocal.aviestcod,     #Codigo da estacao
			 aviestnom			 			    like datkavislocal.aviestnom,			#Nome da estaca
			 endlgd										like datkavislocal.endlgd
end record

		 output
		    left   margin 000
		    top    margin 000
		    bottom margin 000

		 format
		    first page header
		       print  "<html><table border=1>"
		       			 ,"<tr>"
		       			 ,"<td colspan=17 align='center'>RELATORIO CONTROLE DE PRORROGAÇÃO - REFERENTE A DATA DE (",today,") </td></tr>"
		             ,"<tr>"
		             ,"<th align='center' bgcolor='gray'>SUCURSAL</th>"
		             ,"<th align='center' bgcolor='gray'>APOLICE</th>"
		             ,"<th align='center' bgcolor='gray'>ITEM</th>"
                 ,"<th align='center' bgcolor='gray'>Nº DA PRORROGAÇÃO</th>"
                 ,"<th align='center' bgcolor='gray'>RESERVA</th>"
                 ,"<th align='center' bgcolor='gray'>1ª RESERVA</th>"
                 ,"<th align='center' bgcolor='gray'>TOTAL DE DIARIAS</th>"
                 ,"<th align='center' bgcolor='gray'>MARCA</th>"
                 ,"<th align='center' bgcolor='gray'>TIPO</th>"
                 ,"<th align='center' bgcolor='gray'>ANO</th>"
                 ,"<th align='center' bgcolor='gray'>MODELO</th>"
                 ,"<th align='center' bgcolor='gray'>CHASSI</th>"
                 ,"<th align='center' bgcolor='gray'>LICENÇA</th>"
                 ,"<th align='center' bgcolor='gray'>FABRICAÇAO</th>"
                 ,"<th align='center' bgcolor='gray'>CODIGO LOJA</th>"
                 ,"<th align='center' bgcolor='gray'>NOME DA LOJA</th>"
                 ,"<th align='center' bgcolor='gray'>ENDEREÇO</th>"
                 ,"</tr>"
		    on every row
		       print  "<tr>"
		       				,"<td width=80 align='center'>",relatorio_bdata136.succod , "</td>"
		              ,"<td width=85 align='center'>",relatorio_bdata136.aplnumdig, "</td>"
		              ,"<td width=65 align='center'>",relatorio_bdata136.itmnumdig, "</td>"
		              ,"<td width=150 align='center'>",relatorio_bdata136.aviproseq, "</td>"
		              ,"<td width=95 align='center'>",relatorio_bdata136.reserva clipped, "</td>"
		              ,"<td width=90 align='center'>",relatorio_bdata136.aviprosoldat, "</td>"
		              ,"<td width=130 align='center'>",relatorio_bdata136.total, "</td>"
		              ,"<td width=130 align='center'>",relatorio_bdata136.vclmrcnom, "</td>"
		              ,"<td width=130 align='center'>",relatorio_bdata136.vcltipnom, "</td>"
		              ,"<td width=50 align='center'>",relatorio_bdata136.vclanomdl, "</td>"
		              ,"<td width=240 align='center'>",relatorio_bdata136.vclmdlnom, "</td>"
		              ,"<td width=150 align='center'>",relatorio_bdata136.vclchs, "</td>"
		              ,"<td width=85 align='center'>",relatorio_bdata136.vcllicnum, "</td>"
		              ,"<td width=85 align='center'>",relatorio_bdata136.vclanofbc, "</td> "
		              ,"<td width=100 align='center'>",relatorio_bdata136.aviestcod, "</td> "
		              ,"<td width=300 align='center'>",relatorio_bdata136.aviestnom, "</td> "
		              ,"<td width=300 align='center'>",relatorio_bdata136.endlgd, "</td></tr>"
end report

#------------------------------------------------------#
report rep_bdata136_txt(relatorio_bdata136) #--> RELTXT
#------------------------------------------------------#

define relatorio_bdata136 record
       succod       like datrligapol.succod,      #Código da sucursal
       aplnumdig    like datrligapol.aplnumdig,   #Numero da apolice
       itmnumdig    like datrligapol.itmnumdig,   #Numero do item
       aviproseq    like datmprorrog.aviproseq,	  #Sequencia de prorrogacao
       reserva      char(25),                     #Numero da reserva
       aviprosoldat like datmprorrog.aviprosoldat,#Data de solicitação da prorrogacao
       aviprvent    like datmavisrent.aviprvent,  #Quantidade de Diarias da ultima prorrogacao
       total        integer,			  #Total de diarias
       vclmrcnom    like agbkmarca.vclmrcnom,     #Nome marca do veiculo
       vcltipnom    like agbktip.vcltipnom,	  #Nome do tipo do veiculo
       vclmdlnom    like agbkveic.vclmdlnom,	  #Nome do modelo
       vclchs       char (20),		          #Chassi
       vcllicnum    like abbmveic.vcllicnum,      #Numero da licença
       vclanofbc    like abbmveic.vclanofbc,      #Ano de Fabricacao
       vclanomdl    like abbmveic.vclanomdl,      #Ano do Modelo
       vclcoddig    like agbkveic.vclcoddig,      #Codigo do veiculo
       vclmrccod    like agbkmarca.vclmrccod,     #Codigo da marca
       vcltipcod    like agbktip.vcltipcod,       #Codigo do tipo
       aviestcod    like datkavislocal.aviestcod, #Codigo da estacao
       aviestnom    like datkavislocal.aviestnom, #Nome da estaca
       endlgd       like datkavislocal.endlgd
end    record

		 output
		    left   margin 000
		    top    margin 000
		    bottom margin 000
                    page   length 001

		 format
		    on every row
		       print relatorio_bdata136.succod,          ASCII(09),
		             relatorio_bdata136.aplnumdig,       ASCII(09),
		             relatorio_bdata136.itmnumdig,       ASCII(09),
		             relatorio_bdata136.aviproseq,       ASCII(09),
		             relatorio_bdata136.reserva clipped, ASCII(09),
		             relatorio_bdata136.aviprosoldat,    ASCII(09),
		             relatorio_bdata136.total,           ASCII(09),
		             relatorio_bdata136.vclmrcnom,       ASCII(09),
		             relatorio_bdata136.vcltipnom,       ASCII(09),
		             relatorio_bdata136.vclanomdl,       ASCII(09),
		             relatorio_bdata136.vclmdlnom,       ASCII(09),
		             relatorio_bdata136.vclchs,          ASCII(09),
		             relatorio_bdata136.vcllicnum,       ASCII(09),
		             relatorio_bdata136.vclanofbc,       ASCII(09),
		             relatorio_bdata136.aviestcod,       ASCII(09),
		             relatorio_bdata136.aviestnom,       ASCII(09),
		             relatorio_bdata136.endlgd 

end report

#----------------------------------------#
 function bdata136_relatorio_remocoes()
#----------------------------------------#
  define l_atdsrvnum   like datmligacao.atdsrvnum,
        l_atdsrvano    like datmligacao.atdsrvano,
        l_ligdat       like datmligacao.ligdat,
        l_ufdcod_1     like datmlcl.ufdcod,
        l_cidnom_1     like datmlcl.cidnom,
        l_lgdnom_1     like datmlcl.lgdnom,
        l_lclltt_1     like datmlcl.lclltt,
        l_lcllgt_1     like datmlcl.lcllgt,
        l_ufdcod_2     like datmlcl.ufdcod,
        l_cidnom_2     like datmlcl.cidnom,
        l_lgdnom_2     like datmlcl.lgdnom,
        l_lclltt_2     like datmlcl.lclltt,
        l_lcllgt_2     like datmlcl.lcllgt,
        l_c24astcod    like datmligacao.c24astcod,
        
        l_dstqtd         decimal(8,3),
        l_arquivo        char(100),
        l_cont           smallint,
        l_param_email    like datkdominio.cponom,
        emails           array[40] of char(70)

  define lr_mens        record
         para            char(10000)
        ,cc              char(10000)
        ,anexo           char(32000)
        ,assunto         char(500)
        ,msg             char(500)
  end record

  define l_dia        char(02),
         l_data       char(10),
         l_data_ini   date,
         l_data_fim   date
         
  let l_data = today
  display "l_data: ", l_data
  let l_dia  = l_data[01,02]
  display "l_dia: ", l_dia
  
  if l_dia <> '01' then
     return
  end if
  
 let l_data_ini = l_data
 display "l_data_ini: ", l_data_ini
 let l_data_ini = l_data_ini - 1 units month
 display "l_data_ini: ", l_data_ini
 let l_data_fim = l_data_ini + 1 units month
 display "l_data_fim: ", l_data_fim

 call bdata136_prepare()
 
 whenever error continue
 declare cq_cursor cursor for
 select a.atdsrvnum,
        a.atdsrvano,
        a.ligdat,
        b.ufdcod,
        b.cidnom,
        b.lgdnom,
        b.lclltt,
        b.lcllgt,
        a.c24astcod
   from datmligacao a, datmlcl b
  where a.c24astcod in ('E10','E12','G10','G13','GOF',
                        'I10','L10','F13','RPT','REP')
    and a.ligdat   >= l_data_ini
    and a.ligdat   <  l_data_fim
    and a.atdsrvnum is not null
    and a.atdsrvano is not null
    and a.atdsrvnum = b.atdsrvnum
    and a.atdsrvano = b.atdsrvano
    and b.c24endtip = 2
  order by a.ligdat
    
 whenever error stop
 if sqlca.sqlcode <> 0 then
    display "Erro declare cq_cursor: ", sqlca.sqlcode
    return
 end if

 call f_path("DAT", "RELATO")
    returning l_arquivo

 display 'Diretorio do arquivo: ',l_arquivo

 let l_arquivo = l_arquivo clipped, "/bdata136_remocoes.xls"
 
 start report rep_bdata136_remocoes to l_arquivo
 
 let m_rel = false
 whenever error continue
 foreach cq_cursor into l_atdsrvnum,
                        l_atdsrvano,
                        l_ligdat,
                        l_ufdcod_2,
                        l_cidnom_2,
                        l_lgdnom_2,
                        l_lclltt_2,
                        l_lcllgt_2,
                        l_c24astcod

    whenever error continue
    select ufdcod,
           cidnom,
           lgdnom,
           lclltt,
           lcllgt
      into l_ufdcod_1,
           l_cidnom_1,
           l_lgdnom_1,
           l_lclltt_1,
           l_lcllgt_1
      from datmlcl
     where atdsrvnum = l_atdsrvnum
       and atdsrvano = l_atdsrvano
       and c24endtip = 1
    
    whenever error stop
    if sqlca.sqlcode <> 0 then
       display "Erro ao buscar c24endtip 1 para: ", l_atdsrvnum, sqlca.sqlcode 
       continue foreach
    end if
    	
    if l_lclltt_1 is null or 
       l_lcllgt_1 is null or
       l_lclltt_2 is null or
       l_lcllgt_2 is null then
       display "Erro LatLong null para servico: ", l_atdsrvnum
       continue foreach
    else

       call cts18g00(l_lclltt_1,
                     l_lcllgt_1,
                     l_lclltt_2,
                     l_lcllgt_2)
          returning l_dstqtd


       let m_rel = true
       output to report rep_bdata136_remocoes(l_atdsrvnum,
                                              l_atdsrvano,
                                              l_c24astcod,
                                              l_ligdat,
                                              l_ufdcod_1, 
                                              l_cidnom_1, 
                                              l_lgdnom_1, 
                                              l_ufdcod_2, 
                                              l_cidnom_2, 
                                              l_lgdnom_2, 
                                              l_dstqtd)

    end if
 end foreach

 finish report rep_bdata136_remocoes

 display "Criando e-mail remocoes..."
 let l_cont = 1
 let l_param_email = 'relatorio_remocoes'

 open cbdata136004 using l_param_email    
 foreach cbdata136004 into emails[l_cont]

    if l_cont = 1 then
       let lr_mens.para = emails[l_cont] clipped
    else
       let lr_mens.para = lr_mens.para clipped
                         ,","
                         ,emails[l_cont] clipped
    end if
    let l_cont = l_cont + 1
 end foreach

 let lr_mens.anexo = l_arquivo

 let lr_mens.assunto = "Relatorio de Remocoes - "
                       ,l_data_ini, " a ", l_data_fim
 let lr_mens.msg =  "<html><body><font face = Times New Roman> Prezado(s), <br><br>"
                    ,"Segue anexo Relat&oacute;rio Controle de Remo&ccedil;&atilde;o. <br><br>"
                    ,"Refer&ecirc;ncia: " , l_data_ini, " a ", l_data_fim ,  ". <br><br>"
                    ,"Atenciosamente, <br><br>"
                    ,"Corpora&ccedil;&atilde;o Porto Seguro - http://www.portoseguro.com.br"
                    ,"<br><br> "

 call send_email_prorrogacao(lr_mens.*) 

 end function

#------------------------------------------------------------------------------#
report rep_bdata136_remocoes(lr_param)
#------------------------------------------------------------------------------#

 define lr_param     record
        atdsrvnum    like datmligacao.atdsrvnum,
        atdsrvano    like datmligacao.atdsrvano,
        c24astcod    like datmligacao.c24astcod,
        ligdat       like datmligacao.ligdat,
        ufdcod_1     like datmlcl.ufdcod,
        cidnom_1     like datmlcl.cidnom,
        lgdnom_1     like datmlcl.lgdnom,
        ufdcod_2     like datmlcl.ufdcod,
        cidnom_2     like datmlcl.cidnom,
        lgdnom_2     like datmlcl.lgdnom,
        dstqtd       decimal(8,3)
 end record           
                      
   output
      left      margin  00
      top       margin  00
      bottom    margin  00
      page      length  04

   format
      first page header
         print "Servico"                   , ascii(9)
              ,"Ano"                       , ascii(9)
              ,"Assunto"                   , ascii(9)
              ,"Data"                      , ascii(9)
              ,"Uf Origem"                 , ascii(9)
              ,"Cidade Origem"             , ascii(9)
              ,"Logradouro Origem"         , ascii(9)
              ,"Uf Destino"                , ascii(9)
              ,"Cidade Destino"            , ascii(9)
              ,"Logradouro Destino"        , ascii(9)
              ,"Distancia"                 , ascii(9)

      on every row
         print lr_param.atdsrvnum                   , ascii(9)
              ,lr_param.atdsrvano                   , ascii(9)
              ,lr_param.c24astcod                   , ascii(9)
              ,lr_param.ligdat                      , ascii(9)
              ,lr_param.ufdcod_1                    , ascii(9)
              ,lr_param.cidnom_1 clipped            , ascii(9)
              ,lr_param.lgdnom_1 clipped            , ascii(9)
              ,lr_param.ufdcod_2                    , ascii(9)
              ,lr_param.cidnom_2 clipped            , ascii(9)
              ,lr_param.lgdnom_2 clipped            , ascii(9)
              ,lr_param.dstqtd   using '<<<&&.&&'   , ascii(9)

end report
