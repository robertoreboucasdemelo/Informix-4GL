################################################################################
# Nome do Modulo: bdata133.4gl                           Humberto - F0112435   #
#                                                                              #
# Relatório diário de Acesso Seguro JUN/2011                                   #
################################################################################
# 30/10/2013  PSI-2013-23297            Alteração da utilização do sendmail    #
################################################################################

database porto

globals  '/homedsa/projetos/geral/globals/sg_glob3.4gl'

globals
   define g_ismqconn smallint
end globals

 define m_bdata133_prep smallint
 define w_log     		  char(60)


#==========================================-Main================================================#

main

   call fun_dba_abre_banco("CT24HS")

 let w_log = f_path("DAT","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/bdata133.log"



 call startlog(w_log)

   defer interrupt
   set lock mode to wait
   options
      prompt  line last,
      comment line last - 1,
      message line last,
      accept  key  F40
   call bdata133()
end main

#===========================Prepara comandos SQL==============================#
function bdata133_prepare()
#=============================================================================#

  define l_sql char(5000)

  #--Seleciona os dados de atendimento conforme periodo
  let l_sql =   " select a.ciaempcod            "
  					,"       ,a.ramcod               "
  					,"       ,a.empcod               "
  		         ,"       ,a.funmat               "
  		         ,"       ,a.usrtip               "
  		         ,"       ,a.caddat               "
               ,"       ,a.atdnum               "
               ,"       ,a.aplnumdig            "
               ,"       ,a.succod               "
               ,"       ,a.itmnumdig            "
               ,"       ,a.cadhor               "
               ,"  from  datmatd6523 a          "
               ,"       ,isskfunc b             "
               ," where a.aplnumdig is not null "
               ," and   a.caddat = ?            "
               ," and   a.funmat = b.funmat     "
               ," and   b.dptsgl = ?            "
               ," and   a.empcod = 1            "
               ," and   a.atdnum not in (select atdnum from datratdlig) "
               ," order by a.funmat             "
  prepare pbdata133001 from l_sql
  declare cbdata133001 cursor for pbdata133001

  #--buscar no banco emails de envio do relatorio
  let l_sql =  "select cpodes from datkdominio ",
             	 " where cponom = ? "
  prepare pbdata133002 from l_sql
  declare cbdata133002 cursor for pbdata133002

  #--buscar nome do funcionario
  let l_sql =  "select a.funnom "
                    ,",b.dptnom "
                ,"from isskfunc a "
                    ,",isskdepto b "
               ,"where a.empcod = ? "
                 ,"and a.funmat = ? "
                 ,"and a.dptsgl = ? "
                 ,"and a.dptsgl = b.dptsgl "
 prepare pbdata133003 from l_sql
 declare cbdata133003 cursor for pbdata133003

 #--buscar descricao do ramo
 let l_sql = " select ramnom,ramsgl "
             ,"   from gtakram    "
             ,"   where ramcod = ? "
             ,"   and empcod = ? "
  prepare pbdata133004  from l_sql
  declare cbdata133004  cursor for pbdata133004

  #--buscar apolice da Azul
  let l_sql = " select a.cgccpfnum, ",
             "        a.cgcord   , ",
             "        a.cgccpfdig, ",
             "        a.segnom   , ",
             "        a.pestip     ",
             " from datkazlapl a   ",
             " where a.succod = ?  ",
             " and a.aplnumdig = ? ",
             " and a.itmnumdig = ? ",
             " and a.edsnumdig in (select max(edsnumdig) "             ,
                                      " from datkazlapl b "            ,
                                      " where a.succod    = b.succod " ,
                                      " and a.aplnumdig = b.aplnumdig ",
                                      " and a.itmnumdig = b.itmnumdig ",
                                      " and a.ramcod    = b.ramcod) "
 prepare pbdata133005 from l_sql
 declare cbdata133005 cursor for pbdata133005

 #--buscar nivel de acesso do funcionario
 let l_sql = "select acsnivcod "
 						,"from   issmnivnovo "
 						,"where  usrcod = ? "
 						,"and    sissgl = ? "
 prepare pbdata133006 from l_sql
 declare cbdata133006 cursor for pbdata133006

 #--buscar departamento do funcionario
# let l_sql = "select a.dptnom "
#							,"from isskdepto a "
#             ,"where a.dptsgl = ? "
# prepare pbdata133007 from l_sql
# declare cbdata133007 cursor for pbdata133007

  #--buscar no banco emails de envio do relatorio
  let l_sql =  "select cpodes from datkdominio ",
             	 " where cponom = ? "
  prepare pbdata133008 from l_sql
  declare cbdata133008 cursor for pbdata133008

 let m_bdata133_prep = 1

end function

#============================Função Principal=================================#
function bdata133()
#========================Define as variaveis locais===========================#

  define    dados_bdata133      	record
  					ciaempcod							like datmatd6523.ciaempcod,   #Codigo da companhia
  					ramcod								like datmatd6523.ramcod,			#Codigo do ramo
  	        empcod	          		like datmatd6523.empcod,      #Codigo da empresa
            funmat            		like datmatd6523.funmat,      #Matricula do funcionario
            usrtip								like datmatd6523.usrtip,			##Tp do antendete
            caddat            		like datmatd6523.caddat,      #Data de registro
            atdnum           			like datmatd6523.atdnum,      #Numero do atendimento
            aplnumdig         		like datmatd6523.aplnumdig,   #Numero da apolice
            succod								like datmatd6523.succod, 			#Codigo da sucursal
            itmnumdig							like datmatd6523.itmnumdig,   #Numero do digito do item
            cadhor                like datmatd6523.cadhor       #Hora de cadastro
  end record

  define    relatorio_bdata133    record
            matricula           	char(10),		                  #Matricula do funcionario
            nomefuncionario   		char(50),		                  #Nome do funcionario
            caddat              	like datmatd6523.caddat,      #Data de registro
            atdnum           	  	like datmatd6523.atdnum,      #Numero do atendimento
            aplnumdig           	like datmatd6523.aplnumdig,   #Numero da apolice
            nomesegurado					char(50),											#Nome do segurado
            cadhor                like datmatd6523.cadhor,      #Hora de cadastro
            dptnom                like isskdepto.dptnom         #Nome do depto do funcionario
  end record



  define lr_bdata133							record
  	 				erro     						  smallint,
					  mens     						  char(70),
					  emsdat   						  like abamdoc.emsdat,					#Data de emissão
					  aplstt   						  like abamapol.aplstt,					#Status da apolice
					  vigfnl   						  like abamapol.vigfnl,					#Data final de Vigência
					  segnumdig						  like abbmdoc.segnumdig,				#Numero/Digito do segurado
					  pesnum   						  like gsakpes.pesnum,					#Numero da pessoa
					  sgrorg   						  like rsamseguro.sgrorg,				#Origem de proposta de seguro
					  sgrnumdig						  like rsamseguro.sgrnumdig,		#Numero/digito de proposta de seguro
					  prporg   						  like rsdmdocto.prporg,				#Codigo da origem da Proposta
					  prpnumdig						  like rsdmdocto.prpnumdig,			#Numero e digito da proposta
					  edsnumref						  like rsdmdocto.edsnumdig,  		#Numero/Digito do endosso
					  dptsgl                like isskfunc.dptsgl          #Sigla do departamento
  end record

   define 	lr_retorno    				record
          	resultado     				smallint
         	 ,mensagem      				char(60)
         	 ,ramnom        				like gtakram.ramnom						#Nome do ramo
         	 ,ramsgl        				char(15)											#Sigla do ramo
         	 ,acsnivcod							like issmnivnovo.acsnivcod		#Codigo do nivel de acesso
         	 ,dptnom								like isskdepto.dptnom         #Nome do depto do funcionario
         	 ,funnom                like isskfunc.funnom          #Nome do funcionario
   end record

  define lr_retorno1 							record
			      erro      						smallint,
			      mens      						char(50),
			      cgccpf    						like gsakpes.cgccpfnum,
			      cgcord    						like gsakpes.cgcord,
			      cgccpfdig 						like gsakpes.cgccpfdig,
			      pestip    						like gsakpes.pestip,
			      pesnom    						like gsakpes.pesnom
	end record

  define lr_mens        					record
		        para           				char(10000)
		       ,cc             				char(10000)
		       ,anexo          				char(500)
		       ,assunto        				char(100)
		       ,msg            				char(400)
  end record

  define 		param_caddat        	like datmatd6523.caddat       #Data de registro
  define 		dirfisnom             char(32000)                   #Diretorio
  define 		ws_aux                char(50)                      #variavel auxiliar
  define 		emails                array[50] of char(200)
  define 		l_cont                smallint
  define 		l_tam_matricula       integer
  define 		l_matricula           char(10)
  define    param_cponom					like datkdominio.cponom				#Nome do campo
  define    param_sissgl					like issmnivnovo.sissgl				#Sigla do Sistema
  define    param_dptsgl          like datkdominio.cponom
  define    l_tam_email           integer
  define    l_cont2               smallint
#=========================Inicializa variaveis================================#
  initialize  dados_bdata133.* ,relatorio_bdata133.*
             ,lr_retorno1.* ,lr_bdata133.* ,lr_retorno.*  to null

  let param_caddat = today - 1
  let param_cponom = "acesso_seguro"
  let param_sissgl = "Atd_ct24h"
  let param_dptsgl = "bdata133_depto"
  let l_tam_email = 0

#==============Define diretorios para relatorios e arquivos===================#
  call f_path("DAT", "RELATO")
  returning dirfisnom

  let dirfisnom = dirfisnom clipped, "/rel_acessoseguro.xls"


#let dirfisnom = "/asheeve/rel_acessoseguro.xls"
 display 'dirfisnom 3: ',dirfisnom

  #Inicializa Prepare
        call bdata133_prepare()

#======================Inicia criação do relatorio============================#

  start report  rep_bdata133  to dirfisnom

  open cbdata133008 using param_dptsgl
    foreach cbdata133008 into lr_bdata133.dptsgl
    display 'departamento: ',lr_bdata133.dptsgl sleep 2
	    open cbdata133001 using param_caddat
	                           ,lr_bdata133.dptsgl

		    display "Criando relatório..."
		    foreach cbdata133001 into  dados_bdata133.*


       #=====================Recupera a descricao do ramo=================#
		      call bdata133_descricao_ramo(dados_bdata133.ramcod,dados_bdata133.ciaempcod)
			        returning lr_retorno.resultado
			                 ,lr_retorno.mensagem
			                 ,lr_retorno.ramnom
			                 ,lr_retorno.ramsgl
	  if lr_retorno.resultado = 1 then

			  if dados_bdata133.ramcod = 31  or
			     dados_bdata133.ramcod = 531 then


		     #=================Obter Dados da Apolice de Auto================#
		      call cty05g00_dados_apolice(dados_bdata133.succod
		                                 ,dados_bdata133.aplnumdig)
				      returning lr_bdata133.erro        ,
				                lr_bdata133.mens        ,
				                lr_bdata133.emsdat      ,
				                lr_bdata133.aplstt      ,
				                lr_bdata133.vigfnl      ,
				                lr_bdata133.segnumdig
		        if lr_bdata133.erro = 1 then
		              call osgtf550_busca_pesnum_por_unfclisegcod(lr_bdata133.segnumdig)
				              returning lr_retorno1.erro,
				                        lr_bdata133.pesnum
		              if lr_retorno1.erro = 0     then
		                   call osgtf550_busca_cliente_por_pesnum(lr_bdata133.pesnum)
		                   		returning lr_retorno1.erro
		              end if
		              if lr_retorno1.erro = 0 then
		                  let lr_retorno1.cgccpf    = gr_gsakpes.cgccpfnum
		                  let lr_retorno1.cgcord    = gr_gsakpes.cgcord
		                  let lr_retorno1.cgccpfdig = gr_gsakpes.cgccpfdig
		                  let lr_retorno1.pesnom    = gr_gsakpes.pesnom
		                  let lr_retorno1.pestip    = gr_gsakpes.pestip
		              end if
		        end if
		   else
		    #====================Obter dados apolice RE========================#
		       call cty06g00_dados_apolice(dados_bdata133.succod
		                                  ,dados_bdata133.ramcod
		                                  ,dados_bdata133.aplnumdig
		                                  ,lr_retorno.ramsgl)
				       returning lr_bdata133.erro      ,
				                 lr_bdata133.mens      ,
				                 lr_bdata133.sgrorg    ,
				                 lr_bdata133.sgrnumdig ,
				                 lr_bdata133.vigfnl    ,
				                 lr_bdata133.aplstt    ,
				                 lr_bdata133.prporg    ,
				                 lr_bdata133.prpnumdig ,
				                 lr_bdata133.segnumdig ,
				                 lr_bdata133.edsnumref
		        if lr_bdata133.erro = 1 then
		              call osgtf550_busca_pesnum_por_unfclisegcod(lr_bdata133.segnumdig)
				              returning lr_retorno1.erro,
				                        lr_bdata133.pesnum
		              if lr_retorno1.erro = 0     then
		                   call osgtf550_busca_cliente_por_pesnum(lr_bdata133.pesnum)
		                   		returning lr_retorno1.erro
		              end if
		              if lr_retorno1.erro = 0 then
		                  let lr_retorno1.cgccpf    = gr_gsakpes.cgccpfnum
		                  let lr_retorno1.cgcord    = gr_gsakpes.cgcord
		                  let lr_retorno1.cgccpfdig = gr_gsakpes.cgccpfdig
		                  let lr_retorno1.pesnom    = gr_gsakpes.pesnom
		                  let lr_retorno1.pestip    = gr_gsakpes.pestip
		              end if
		         end if
		   end if
		   #=======================Recupero as Apolices da Azul=====================#
		   if lr_retorno1.cgccpf is null then
		        call bdata133_rec_apolice_azul(dados_bdata133.succod   ,
		                                       dados_bdata133.aplnumdig,
		                                       dados_bdata133.itmnumdig)
				        returning lr_retorno1.erro,
				                  lr_retorno1.cgccpf,
				                  lr_retorno1.cgcord,
				                  lr_retorno1.cgccpfdig,
				                  lr_retorno1.pesnom,
				                  lr_retorno1.pestip
		   end if
		   if lr_retorno1.cgccpf is null then
		      let lr_retorno1.mens = "Dados da Apolice nao Encontrada"
		      let lr_retorno1.erro = 1
		   else
		      let lr_retorno1.erro = 0
		   end if


		   	#=================busca nivel de acesso de funcionario====================#
		  			call bdata133_busca_nivel_acesso(dados_bdata133.funmat,
		  																			 param_sissgl)
		  					returning lr_retorno.acsnivcod

					if lr_retorno.acsnivcod = 6 then

					   call bdata133_func(dados_bdata133.empcod
					                     ,dados_bdata133.funmat
					                     ,lr_bdata133.dptsgl)
					         returning lr_retorno.funnom,
					                   lr_retorno.dptnom

#					   call bdata133_busca_depto (lr_bdata133.dptsgl)
#					   					returning lr_retorno.dptnom

				#========================inicializa o relatorio===========================#
				      Initialize relatorio_bdata133.* to null

				      let relatorio_bdata133.caddat           = dados_bdata133.caddat
				      let relatorio_bdata133.nomefuncionario  = lr_retorno.funnom
#				      let relatorio_bdata133.nomefuncionario  = relatorio_bdata133.nomefuncionario clipped
				      let relatorio_bdata133.atdnum           = dados_bdata133.atdnum
				      let relatorio_bdata133.aplnumdig        = dados_bdata133.aplnumdig
				      let relatorio_bdata133.nomesegurado     = lr_retorno1.pesnom
				      let l_matricula                         = dados_bdata133.funmat
				      let relatorio_bdata133.cadhor           = dados_bdata133.cadhor
				      let relatorio_bdata133.dptnom           = lr_retorno.dptnom

				      let l_tam_matricula = length(l_matricula)

				      if l_tam_matricula <=5 then
				        let ws_aux = dados_bdata133.usrtip
				        						,dados_bdata133.empcod using "&&"
				                    ,dados_bdata133.funmat using "&&&&&"
				      else
				        let ws_aux = dados_bdata133.usrtip
				        						,"0"
				                    ,dados_bdata133.funmat using "&&&&&&"
				      end if

				      let relatorio_bdata133.matricula   =  ws_aux

				      output to report rep_bdata133(relatorio_bdata133.*)
				   end if
				      initialize lr_retorno1.* to null
		   end if
	   end foreach
	 end foreach
finish report  rep_bdata133
#-=========================prepara envio de e-mail=============================#
  display "Criando e-mail..."
  let l_cont = 1

  open cbdata133002 using param_cponom
   foreach cbdata133002 into emails[l_cont]

    {if l_cont = 1 then
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

  display 'anexo: ',lr_mens.anexo

  let lr_mens.assunto = "Relatório Acesso Seguro - "
                       ,param_caddat
                       ,"."
  let lr_mens.msg =  "<html><body><font face = Times New Roman> Prezado(s) <br><br>"
                    ,"Segue anexo Relat&oacute;rio de Acesso Seguro.  <br><br>"
                    ,"Refer&ecirc;ncia: " , param_caddat,  ". <br><br>"
                    ,"Atenciosamente, <br><br>"
                    ,"Corpora&ccedil;&atilde;o Porto Seguro - http://www.portoseguro.com.br"
                    ," <br><br> "

  call send_email(lr_mens.*)
end function

#============================Envia e-mail=====================================#
function send_email(lr_mens)
#============================Define variaveis=================================#

  define 	 lr_mens        record
         	 para           char(10000)
        	,cc             char(10000)
        	,anexo          char(400)
        	,assunto        char(100)
        	,msg            char(400)
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

  define  l_sistema   		char(10)
         ,l_remet     		char(50)
         ,l_cmd     			char(32000)
         ,l_ret     			smallint
         ,l_assunto 			char(200)


#=====================Inicia Variaveis=======================================#
  let l_sistema  = "CT24HS"
  let l_remet = "ct24hs.email@correioporto"
  initialize l_cmd to null
  let l_ret = null
#========================Executa comando shel================================#


  display "Enviando e-mail para: ", lr_mens.para clipped

  #PSI-2013-23297 - Inicio
  let l_mail.de = l_remet
  let l_mail.para = lr_mens.para
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto = lr_mens.assunto
  let l_mail.mensagem = lr_mens.msg
  let l_mail.id_remetente = "CT24HS"
  let l_mail.tipo = "html"
  display "Arquivo: ",lr_mens.anexo

  call figrc009_attach_file(lr_mens.anexo)

  display "Arquivo anexado com sucesso"
  call figrc009_mail_send1 (l_mail.*)
     returning l_coderro,msg_erro

  #PSI-2013-23297 - Fim

  display 'l_ret: ',l_coderro
#=======================Confirma envio de e-mail============================#

  if l_coderro = 0  then
    let l_assunto = '### ATENÇãO ### - Email enviado com sucesso! ',
                     current
  else
    let l_assunto = '### ATENÇãO ### - Email nao enviado!', current
  end if

  display l_assunto
end function
#========================Montar relatorio=====================================#
	report rep_bdata133(relatorio_bdata133)

	define    relatorio_bdata133    record
            matricula           	char(10),		                  #Matricula do funcionario
            nomefuncionario   		char(50),		                  #Nome do funcionario
            caddat              	like datmatd6523.caddat,      #Data de registro
            atdnum           	  	like datmatd6523.atdnum,      #Numero do atendimento
            aplnumdig           	like datmatd6523.aplnumdig,   #Numero da apolice
            nomesegurado					char(50),											#Nome do segurado
            cadhor                like datmatd6523.cadhor,      #Hora de cadastro
            dptnom                like isskdepto.dptnom         #Nome do depto do funcionario
  end record

		 output
		    left   margin 000
		    top    margin 000
		    bottom margin 000

		 format
		    first page header
		       print  "<html><table border=1>"
		       			 ,"<tr>"
		       			 ,"<td colspan=8 align='center'>RELATORIO DIÁRIO DE ATENDIMENTO SEM REGISTRO DE LIGAÇÃO - (",today,") </td></tr>"
		             ,"<tr>"
		             ,"<th align='center' bgcolor='gray'>MATRICULA</th>"
		             ,"<th align='center' bgcolor='gray'>FUNCIONARIO</th>"
		             ,"<th align='center' bgcolor='gray'>DEPTO FUNCIONARIO</th> "
		             ,"<th align='center' bgcolor='gray'>DATA DA CONSULTA</th>"
		             ,"<th align='center' bgcolor='gray'>HORA DA CONSULTA</th>"
		             ,"<th align='center' bgcolor='gray'>Nº DO ATENDIMENTO</th>"
		             ,"<th align='center' bgcolor='gray'>APOLICE</th>"
		             ,"<th align='center' bgcolor='gray'>SEGURADO</th>"

		    on every row
		       print  "<tr>"
		       			  ,"<td width=85  align='center'>",relatorio_bdata133.matricula , "</td>"
		              ,"<td width=200 align='center'>",relatorio_bdata133.nomefuncionario, "</td>"
		              ,"<td width=250 align='center'>",relatorio_bdata133.dptnom, "</td>"
		              ,"<td width=90  align='center'>",relatorio_bdata133.caddat, "</td>"
		              ,"<td width=90  align='center'>",relatorio_bdata133.cadhor,"</td>"
		              ,"<td width=100 align='center'>",relatorio_bdata133.atdnum, "</td>"
		              ,"<td width=90  align='center'>",relatorio_bdata133.aplnumdig, "</td>"
		              ,"<td width=300 align='center'>",relatorio_bdata133.nomesegurado, "</td></tr>"
		end report

#======================================================#
 function bdata133_func(l_empcod, l_funmat, l_dptsgl)
#======================================================#
 define  l_empcod      like   isskfunc.empcod
 define  l_funmat      like   isskfunc.funmat
 define  l_funnom      like   isskfunc.funnom
 define  l_dptsgl      like   isskfunc.dptsgl
 define  l_dptnom      like   isskdepto.dptnom


 if m_bdata133_prep <> 1 then
    call bdata133_prepare()
 end if
 whenever error continue
 open cbdata133003 using l_empcod,
                         l_funmat,
                         l_dptsgl

 fetch cbdata133003 into l_funnom,
                         l_dptnom
 whenever error stop
  if sqlca.sqlcode = notfound then
    let l_funnom = '    '
  else
    if sqlca.sqlcode <> 0 then
       error 'Erro (',sqlca.sqlcode,') na Busca do nome do funcionario. Avise a Informatica!'
    end if
  end if
 close cbdata133003

 let l_funnom = upshift(l_funnom)
 let l_dptnom = upshift(l_dptnom)

 return l_funnom,
        l_dptnom

end function

#=======================================================#
function bdata133_descricao_ramo(l_ramcod, l_ciaempcod)
#=======================================================#
   define  l_ramcod	     like gtakram.ramcod
          ,l_ciaempcod   like gtakram.empcod
          ,l_msg         char(60)

    define lr_retorno    record
           resultado     smallint
          ,mensagem      char(60)
          ,ramnom        like gtakram.ramnom
          ,ramsgl        char(15)
   end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_msg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

   initialize  lr_retorno.*  to  null

   #initialize lr_retorno to null

   if m_bdata133_prep is null or m_bdata133_prep <> true then
      call bdata133_prepare()
   end if

   open cbdata133004 using l_ramcod
                          ,l_ciaempcod
   whenever error continue
   fetch cbdata133004 into lr_retorno.ramnom,
                           lr_retorno.ramsgl


   whenever error stop
   if sqlca.sqlcode = 0 then
      let lr_retorno.resultado = 1
   else
      if sqlca.sqlcode = notfound then
         let lr_retorno.resultado = 2
         let lr_retorno.mensagem  = "Ramo nao cadastrado"
         let l_msg = "Ramo nao cadastrado"
      else
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em gtakram"
         let l_msg = " Erro de SELECT - cbdata133004 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
         call errorlog(l_msg)
         let l_msg = " bdata133_descricao_ramo() / ",l_ramcod
         call errorlog(l_msg)
      end if
   end if
   close cbdata133004
   return lr_retorno.*
end function

#==============================================#
function bdata133_rec_apolice_azul(lr_param)
#==============================================#
define lr_param record
   succod     like datkazlapl.succod,
   aplnumdig  like datkazlapl.aplnumdig,
   itmnumdig  like datkazlapl.itmnumdig
end record

define lr_retorno1 record
  erro      integer,
  cgccpf    like gsakpes.cgccpfnum,
  cgcord    like gsakpes.cgcord,
  cgccpfdig like gsakpes.cgccpfdig,
  pesnom    like gsakpes.pesnom,
  pestip    like gsakpes.pestip
end record

initialize lr_retorno1.* to null
if m_bdata133_prep is null or
   m_bdata133_prep <> true then
    call bdata133_prepare()
end if
     open cbdata133005 using lr_param.*
     whenever error continue
     fetch cbdata133005 into  lr_retorno1.cgccpf,
                              lr_retorno1.cgcord,
                              lr_retorno1.cgccpfdig,
                              lr_retorno1.pesnom,
                              lr_retorno1.pestip
     whenever error stop
     if sqlca.sqlcode <> 0  then
         let lr_retorno1.erro = 1
     else
         let lr_retorno1.erro = 0
     end if
     close cbdata133005
     return lr_retorno1.*
end function

#========================================================#
 function bdata133_busca_nivel_acesso(l_usrcod, l_sissgl)
#========================================================#
 define  l_usrcod        like   issmnivnovo.usrcod
 define  l_sissgl        like   issmnivnovo.sissgl
 define  l_acsnivcod     like   issmnivnovo.acsnivcod
 define  l_tam_matricula integer
 define  ws_aux					 char(50)

 let l_tam_matricula = length(l_usrcod)

		      if l_tam_matricula = 5 then
		         let ws_aux = "0" ,l_usrcod using "&&&&&"
		      else
		         if l_tam_matricula = 4 then
               let ws_aux = "0","0",l_usrcod
          else
          	  let ws_aux = l_usrcod using "&&&&&&"
             end if
		      end if
		      let l_usrcod   =  ws_aux

 if m_bdata133_prep <> 1 then
    call bdata133_prepare()
 end if

 whenever error continue
 open cbdata133006 using l_usrcod,
                         l_sissgl

 fetch cbdata133006 into l_acsnivcod
 whenever error stop
  if sqlca.sqlcode = notfound then
    let l_acsnivcod = '    '
  else
    if sqlca.sqlcode <> 0 then
       error 'Erro (',sqlca.sqlcode,') na Busca do nome do funcionario. Avise a Informatica!'
    end if
  end if

 close cbdata133006

 return l_acsnivcod

end function

##==================================================#
# function bdata133_busca_depto(l_dptsgl)
##==================================================#
# define  l_dptsgl     like   isskfunc.dptsgl
# define  l_dptnom     like   isskdepto.dptnom
#
#
# if m_bdata133_prep <> 1 then
#    call bdata133_prepare()
# end if
# whenever error continue
# open cbdata133007 using l_dptsgl
#
#
# fetch cbdata133007 into l_dptnom
# whenever error stop
#  if sqlca.sqlcode = notfound then
#    let l_dptnom = '    '
#  else
#    if sqlca.sqlcode <> 0 then
#       error 'Erro (',sqlca.sqlcode,') na Busca do depto do funcionario. Avise a Informatica!'
#    end if
#  end if
# close cbdata133007
#
# let l_dptnom = upshift(l_dptnom)
#
# return l_dptnom
#
#end function