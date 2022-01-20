#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: bdbsr127                                                   #
# ANALISTA RESP..: BEATRIZ ARAUJO                                             #
# PSI/OSF........: 249530                                                     #
#                  MELHORIAS NO CONTROLE DE SOCORRISTAS                       #
#                      Vencimento de CNH's                                    #
# ........................................................................... #
# DESENVOLVIMENTO: BEATRIZ ARAUJO                                             #
# LIBERACAO......: 30/10/2009                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 02/03/2011  Danilo Santos             Inclusao do dominio 'pstvinnaovldcnh' #
# 02/03/2011  Ueslei Santos 		Mudan a do texto do corpo do email            #
# 21/03/2011  Ueslei Santos		Mudan a nas queries, retornar apenas            #
#					dados de socorristas atrelados                                      #
#					prestadores Padrao Porto.                                           #
#-----------------------------------------------------------------------------#
# 06/04/2011  Ueslei Santos		Inclusao da validacao de vinculo e              #    
#					inclusao do vinculo no relatorio.                                   #
# 15/04/2011  Celso Yamahaki            Inclusao de Campos Cadeia de Gestao e #
#                                       Responsavel no relatorio              #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  globals "/homedsa/projetos/geral/globals/glct.4gl"
  
  define mr_bdbsr127      record
         exmvctdat        like datksrr.exmvctdat,     # Data de vencimento do exame m dico do socorrista
         srrabvnom        like datksrr.srrabvnom,     # Nome de Guerra do Socorrista
         srrcoddig        like datrsrrpst.srrcoddig,  # C digo do Socorrista
         cnhvncmes        char(9),                    # M s de vencimento da CNH do Socorrista
         srrnom           like datksrr.srrnom,        # Nome do Socorrista
         nomrazsoc        like dpaksocor.nomrazsoc,   # Nome do Prestador
         pstcoddig        like datrsrrpst.pstcoddig,  # Codigo do Prestador 
         avstip           char (50),                  # Tipo do Aviso
         maidespsr        like dpaksocor.maides,      # E-mail do Prestador      
         maidessrr        like datksrr.maides,        # E-mail do Socorrista
         maxvigfnl        like datrsrrpst.vigfnl,     # Ultima vigencia do Socorrista  
         pstvintip	  like datrsrrpst.pstvintip,  # Tipo de vinculo  
         cpodesvin        like iddkdominio.cpodes     # Descricao do vinculo
  end record 
  
  define m_data_ini       date,
         m_data_fim       date,
         l_data_atual     date,
         l_hora_atual     datetime hour to minute,
         m_mes_int        smallint,
         m_mes_nom        char(10),
         m_data_ini2      date
         
  define m_path           char(1000)
  define m_lidos          integer            # numero de e-mails lidos
  define m_cnh_venc       integer            # numero de e-mails lidos que a cnh's est o vencidas
  define m_cnh_nvenc      integer            # numero de e-mails lidos que as cnh's ir o vencer
    
  define mr_cda_gestao record            
    srrtip    like datksrr.srrtip,       # codigo do responsavel
    frtrpndes char(20),                  # nome do responsavel
    gstcdicod like dpaksocor.gstcdicod,  # codigo cadeia gestao
    sprnom    like dpakprsgstcdi.sprnom, # nome superintendente
    gernom    like dpakprsgstcdi.gernom, # nome gerente
    cdnnom    like dpakprsgstcdi.cdnnom, # nome coordenador
    anlnom    like dpakprsgstcdi.anlnom  # nome analista    
  end record
  
  
main
        
        initialize mr_bdbsr127.*,
                   m_path,
                   m_lidos,
                   m_data_ini,
                   m_data_fim,
                   l_data_atual,
                   m_cnh_venc,
                   m_cnh_nvenc,
                   l_hora_atual,
                   mr_cda_gestao.* to null
                   
                   
         # Calculo do mes para execucao ou recebido como parametro 
         #caso nao seja executado no ultima dia do mes         
         let l_data_atual = arg_val(1)
         
         # ---> OBTER A DATA E HORA DO BANCO 
         if l_data_atual is null then
            call cts40g03_data_hora_banco(2)
            returning l_data_atual,
                      l_hora_atual
         end if

         # Calculo do mes para execucao ou recebido como parametro 
         #caso nao seja executado no ultima dia do mes
         #let m_data_ini = arg_val(1)
         #let m_data_fim = arg_val(2)


         # PARAMETRIZADO PARA EXECUCAO NO ULTIMO DIA DO MES
        if m_data_ini is null or m_data_fim is null then
               let m_data_ini = mdy(month(l_data_atual),01,year(l_data_atual))
                let m_data_ini = m_data_ini + 1 units month
                let m_data_fim = m_data_ini + 1 units month - 1 units day
         end if 
	 
	# inibido por se perder nos calculos 
	#if m_data_ini is null or m_data_fim is null then
        #    let m_data_ini = l_data_atual + 1 units month 
        #    let m_data_ini = m_data_ini - day(today) + 1 
        #    let m_data_fim = m_data_ini + 1 units month - 1 units day
        # end if   
    # ---> OBTEM O MES DE GERACAO DO RELATORIO
    let m_mes_int = month(m_data_ini)


        call fun_dba_abre_banco("CT24HS")
        call bdbsr127_busca_path()
        call cts40g03_exibe_info("I","BDBSR127")
        display "Arg_val: ",l_data_atual
        display "Data inicial: ",m_data_ini  
        display "Data final..: ",m_data_fim  
        call bdbsr127_prepare()
        call bdbsr127_cnh_vencimento()
        display " "
        display "QTD.REGISTROS LIDOS......: ", m_lidos       
        display " "
        display "QTD.REGISTROS CHN VENCIDAS......: ", m_cnh_venc       
        display " "
        display "QTD.REGISTROS CHN VENCENDO......: ", m_cnh_nvenc       
        display " "

        call cts40g03_exibe_info("F","BDBSR127")

end main  


#---------------------------#
 function bdbsr127_prepare()
#---------------------------#

        define l_sql   char(5000)

        create temp table t_temp (pstcoddig decimal(6,0) not null) with no log
        create unique index idx_bdbsr127 on t_temp (pstcoddig)
        
        # para encontrar o prestador
        let l_sql ="select k.nomrazsoc, ",      
                          "p.pstcoddig, ",
                          "k.maides,    ",  
                          "p.pstvintip  ",       
                     "from dpaksocor k, ",          
                          "datrsrrpst p ",
                    "where p.pstcoddig = k.pstcoddig ",
                      "and p.srrcoddig = ? ",
                      "and p.vigfnl = ? ",
                      "and exists (select 1 ",
		                 "   from iddkdominio ",
		                 "  where cponom = 'PSTQLDCNH' ",
				 "   and cpocod =  k.qldgracod) "
        
        prepare pbdbsr127_01 from l_sql
        declare cbdbsr127_01 cursor for pbdbsr127_01

        # para CNH's que já venceram
        let l_sql = "select s.srrcoddig,                                 ", 
                    "       max(p.vigfnl),                               ", 
                    "       s.exmvctdat,                                 ", 
                    "       s.srrabvnom,                                 ", 
                    "       s.srrnom,                                    ", 
                    "       s.maides,                                    ", 
                    "       s1.gstcdicod,                                ", 
                    "       s.srrtip	                             	 ", 
                    "from datrsrrpst p,                                  ", 
                    "     datksrr s,                                     ", 
                    "     dpaksocor s1                                   ", 
                    "where s.srrcoddig = p.srrcoddig                     ", 
                    "and  s1.pstcoddig = p.pstcoddig                     ", 
                    "and not exists (select 1                            ", 
                    "                  from iddkdominio i2               ", 
                    "                 where i2.cponom = 'pstvinnaovldcnh'", 
                    "                   and i2.cpocod = p.pstvintip)     ", 
                    "and today between p.viginc and p.vigfnl             ", 
                    "and s.exmvctdat <= ?			         ", 
                    "and s.srrstt = 1			             	 ", 
                    "and exists (select 1                                ", 
                    "              from iddkdominio                      ", 
                    "              where cponom = 'PSTQLDCNH'            ", 
        	    "                and cpocod =  s1.qldgracod)         ",    
		    "group by s.srrcoddig,s.exmvctdat,s.srrabvnom,       ", 
		    "         s.srrnom,s.maides, s1.gstcdicod, s.srrtip  " 
                       
                                   
        prepare pbdbsr127_02 from l_sql
        declare cbdbsr127_02 cursor for pbdbsr127_02
        
        
        # Para CNH's que irao vencer
        let l_sql = 	"select s.srrcoddig,                                  ",                                                    
			"      max(p.vigfnl),                                 ",       
			"      s.exmvctdat,                                   ",         
			"      s.srrabvnom,                                   ",         
			"      s.srrnom,                                      ",      
			"      s.maides,                                      ", 
			"      b.gstcdicod,                                   ", #Cod Cadeia de Gestao   
			"      s.srrtip					      ", #Cod Tipo de Socorrista     
			"from datrsrrpst p, datksrr s, dpaksocor b            ",                   
			"where s.srrcoddig = p.srrcoddig                      ", 
			"and  b.pstcoddig = p.pstcoddig                       ",     
			"and  not exists (select cpocod                       ",        
			"                      from iddkdominio               ",            
			"                     where cponom = 'pstvinnaovldcnh'",         
			"                       and cpocod = p.pstvintip)     ", 
			"and today between p.viginc and p.vigfnl	      ",        
			"and s.exmvctdat between ? and ?		      ",        
			"and s.srrstt = 1			              ",
			"and b.qldgracod = (select cpocod                     ",
			"                     from iddkdominio                ",
			"                    where cponom = 'PSTQLDCNH'       ",
			"                      and cpocod =  b.qldgracod)     ",
			"group by s.srrcoddig,s.exmvctdat,s.srrabvnom,        ",
			"         s.srrnom,s.maides, b.gstcdicod, s.srrtip    "             
                     
        prepare pbdbsr127_03 from l_sql
        declare cbdbsr127_03 cursor for pbdbsr127_03    
        
        {let l_sql = "select distinct k.nomrazsoc, ",   
                           "k.maides ",
                      "from datrsrrpst p, dpaksocor k ",
                     "where p.pstcoddig = k.pstcoddig ", 
                       "and p.srrcoddig = ? ",
                       "and p.vigfnl = ? "
                       "and k.qldgracod = 1"
        prepare pbdbsr127_04 from l_sql
        declare cbdbsr127_04 cursor for pbdbsr127_04  } 
        
     	
 	# Para buscar a descricao da Cadeia de Gestao
     	
     	let l_sql = "   select sprnom,       ",
      		 "      gernom,    	     ",
      		 "      cdnnom,  	     ",
      		 "      anlnom		     ",      		 
      		 "      from dpakprsgstcdi   ",
      		 "      where gstcdicod = ?  "
      		 
     	prepare pbdbsr127_04 from l_sql
     	declare cbdbsr127_04 cursor for pbdbsr127_04     	
     	
     	# Para buscar a descricao do setor responsavel
     	
     	let l_sql = "   select cpodes                          ",
      		 "      from iddkdominio                       ",
      		 "      where iddkdominio.cponom = 'srrtip' ",
      		 "      and iddkdominio.cpocod = ?             "      		 
      		
     	prepare pbdbsr127_05 from l_sql
     	declare cbdbsr127_05 cursor for pbdbsr127_05  
     	
     	
     	      
end function
#-----------------------------#
 function bdbsr127_busca_path()
#-----------------------------#

        let m_path = null
        let m_path = f_path("DBS","LOG")
        if  m_path is null then
           let m_path = "."
        end if
        
        # ---> Cria o relatorio (CNH's dos Socorristas ,o tipo que irá dizer se 
        #irão vencer ou se já estão vencidas)
        
        let m_path = m_path clipped,"/bdbsr127.log"
        call startlog(m_path)

        let m_path = f_path("DBS", "RELATO")
        if  m_path is null then
           let m_path = "."
         end if

         let m_path = m_path clipped, "/bdbsr1271.xls"
         
 end function
 
#---------------------------------#
 function bdbsr127_cnh_vencimento()
#---------------------------------#


define l_erro_envio  integer 
                       
let m_mes_int = month(today+ 1 units day)
let m_lidos = 0
let m_cnh_venc = 0
let m_cnh_nvenc = 0

########### Esse report será o relatório enviado para os e-mail's cadastrados no BDBSR127
start report rep_bdbsr127_1 to m_path



# CNH's que irão vencer
if m_data_ini is null or m_data_fim is null then
    let m_data_ini = today
    let m_data_fim = m_data_ini + 1 units month - 1 units day
    display "m_data_ini: ",m_data_ini
    display "m_data_fim: ",m_data_fim
end if 
open cbdbsr127_03 using m_data_ini,
                        m_data_fim

foreach cbdbsr127_03 into mr_bdbsr127.srrcoddig,
                          mr_bdbsr127.maxvigfnl,
                          mr_bdbsr127.exmvctdat, 
                          mr_bdbsr127.srrabvnom,
                          mr_bdbsr127.srrnom, 
                          mr_bdbsr127.maidessrr,
                          mr_cda_gestao.gstcdicod,
                          mr_cda_gestao.srrtip,
                          mr_bdbsr127.srrcoddig,
                          mr_bdbsr127.maxvigfnl
       
         case sqlca.sqlcode

             when 0   
                   let mr_bdbsr127.avstip = "Vencimento da CNH"
                   open cbdbsr127_01 using mr_bdbsr127.srrcoddig,mr_bdbsr127.maxvigfnl
                   fetch cbdbsr127_01 into mr_bdbsr127.nomrazsoc,
                                           mr_bdbsr127.pstcoddig,
                                           mr_bdbsr127.maidespsr,
                                           mr_bdbsr127.pstvintip 
                   close cbdbsr127_01                        
                   
                   call  bdbsr127_busca_cadGest_Respon()                  
                  
                   output to report rep_bdbsr127_1()
             end case
        if(m_lidos mod 100 = 0)then
             display  "JA´ FORAM LIDOS ",m_lidos," REGISTROS"
        end if       
end foreach

let m_data_ini = m_data_ini -1 units month - 1 units day
display "Data inicial: ",m_data_ini

open cbdbsr127_02 using m_data_ini
                                    
  foreach cbdbsr127_02 into mr_bdbsr127.srrcoddig,
                            mr_bdbsr127.maxvigfnl,
                            mr_bdbsr127.exmvctdat, 
                            mr_bdbsr127.srrabvnom,
                            mr_bdbsr127.srrnom, 
                            mr_bdbsr127.maidessrr,
                            mr_cda_gestao.gstcdicod,
                            mr_cda_gestao.srrtip,
                            mr_bdbsr127.srrcoddig, 
                            mr_bdbsr127.maxvigfnl 
     case sqlca.sqlcode
        when 0  
           let mr_bdbsr127.avstip = "CNH vencida no sistema"
           open cbdbsr127_01 using mr_bdbsr127.srrcoddig,mr_bdbsr127.maxvigfnl
           fetch cbdbsr127_01 into mr_bdbsr127.nomrazsoc,
                                   mr_bdbsr127.pstcoddig,
                                   mr_bdbsr127.maidespsr,
                                   mr_bdbsr127.pstvintip 
           close cbdbsr127_01 
           
           call  bdbsr127_busca_cadGest_Respon() 
          
           output to report rep_bdbsr127_1()       
     end case
     if(m_lidos mod 100 = 0)then
              display  "JA´ FORAM LIDOS ",m_lidos," REGISTROS"
     end if     
  end foreach      
finish report rep_bdbsr127_1
let l_erro_envio = ctx22g00_envia_email("BDBSR127", "Vencimento das CNH's ", m_path)
if  l_erro_envio <> 0 then
         display "Erro no envio do email no ctx22g00: ",
                 l_erro_envio using "<<<<<<&", " - "
end if                 
end function

#-----------------------#
 report rep_bdbsr127_1()
#-----------------------#

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

        format

            first page header

                print "CODIGO QRA",             ASCII(09),
                      "NOME DO SOCORRISTA",     ASCII(09),
                      "CODIGO DO PRESTADOR",    ASCII(09),
                      "NOME DO PRESTADOR",      ASCII(09),
                      "DATA DO VENC DA CNH",    ASCII(09),
                      "TIPO DO AVISO",          ASCII(09),
                      "TIPO DE VINCULO", 	ASCII(09),
                      "CADEIA DE GESTAO",       ASCII(09),
                      "RESPONSAVEL"
            
            on every row

                print mr_bdbsr127.srrcoddig     clipped,ASCII(09);
                print mr_bdbsr127.srrnom         clipped,ASCII(09);
                print mr_bdbsr127.pstcoddig,      ASCII(09);
                print mr_bdbsr127.nomrazsoc      clipped,ASCII(09);
                print mr_bdbsr127.exmvctdat,      ASCII(09);
                print mr_bdbsr127.avstip         clipped,ASCII(09);
                
                select cpodes
                  into mr_bdbsr127.cpodesvin 
                  from iddkdominio 
                 where cponom = 'pstvintip' and cpocod = mr_bdbsr127.pstvintip
                
                if sqlca.sqlcode = 0 then
                	print mr_bdbsr127.cpodesvin   clipped,ASCII(09);
                else
                	print "NAO CADASTRADO"        clipped,ASCII(09);
                end if 
                
                print mr_cda_gestao.sprnom,"/",
             	      mr_cda_gestao.gernom,"/",
             	      mr_cda_gestao.cdnnom,"/",
             	      mr_cda_gestao.anlnom  clipped,ASCII(09);
             	print mr_cda_gestao.frtrpndes
                 
                call bdbsr127_envia_email(mr_bdbsr127.*)
                
            on last row
                  print " "
                  print "-------------------------------------------------------------------"
                  print "Total de e-mails enviados....................: ", m_lidos
                  print "Total de e-mails com cnh's vencidas.....: ", m_cnh_venc
                  print "Total de e-mails com cnh's que vencerao: ", m_cnh_nvenc    
               
end report              
                         

#----------------------------------------#
 function  bdbsr127_envia_email(lr_param)
#----------------------------------------#

     define lr_param record
         exmvctdat        like datksrr.exmvctdat,     # Data de vencimento do exame m dico do socorrista
         srrabvnom        like datksrr.srrabvnom,     # Nome de Guerra do Socorrista
         srrcoddig        like datrsrrpst.srrcoddig,  # C digo do Socorrista
         cnhvncmes        char(9),                    # M s de vencimento da CNH do Socorrista
         srrnom           like datksrr.srrnom,        # Nome do Socorrista
         nomrazsoc        like dpaksocor.nomrazsoc,   # Nome do Prestador
         pstcoddig        like datrsrrpst.pstcoddig,  # Codigo do Prestador 
         avstip           char (50),                  # Tipo do Aviso
         maidespsr        like dpaksocor.maides,      # E-mail do Prestador      
         maidessrr        like datksrr.maides,        # E-mail do Socorrista
         maxvigfnl        like datrsrrpst.vigfnl,     # Ultima vigencia do Socorrista     
         pstvintip	  like datrsrrpst.pstvintip,  # Tipo de vinculo  
         cpodesvin        like iddkdominio.cpodes     # Descricao do vinculo
  end record      
     
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

     define l_cod_erro integer,
            l_msg_erro char(20),
            l_data     date,
            l_hora     datetime hour to second                    

case month(lr_param.exmvctdat)
       when 1
              let m_mes_nom = "Janeiro"
       when 2
              let m_mes_nom = "Fevereiro"
       when 3
              let m_mes_nom = "Marco"
       when 4
              let m_mes_nom = "Abril"
       when 5
              let m_mes_nom = "Maio"
       when 6
              let m_mes_nom = "Junho"
       when 7
              let m_mes_nom = "Julho"
       when 8
              let m_mes_nom = "Agosto"
       when 9
              let m_mes_nom = "Setembro"
       when 10
              let m_mes_nom = "Outubro"
       when 11
              let m_mes_nom = "Novembro"
       when 12
              let m_mes_nom = "Dezembro"
end case

   
     let l_data = today
     let l_hora = current

     let lr_mail.des = lr_param.maidessrr
     let lr_mail.rem = "cadastro.portosocorro@portoseguro.com.br"
     let lr_mail.ccp = lr_param.maidespsr
     let lr_mail.cco = ""
     let lr_mail.ass = lr_param.avstip
     let lr_mail.idr = "F0110413"
     let lr_mail.tip = "html"   
     if (lr_mail.ass = "Vencimento da CNH")then
                let lr_mail.msg = "<html>",
                                      "<body>",
                                           "<br>Prezado Prestador,<br><br> ",
                                           "Informamos que a CNH do socorrista <b>",upshift(lr_param.srrabvnom) clipped,
                                           " - ", upshift(lr_param.srrcoddig) clipped,
                                           " </b>esta com data de validade programada para o mes de ",m_mes_nom clipped,
                                           " em nosso cadastro.<br>Providencie a renovacao e encaminhe uma copia simples deste ",
                                           "documento renovado para o Porto Socorro, aos cuidados do Desenvolvimento da Rede de Prestadores ou ",
                                           "pelo e-mail <a href='mailto:cadastro.portosocorro@portoseguro.com.br' target='_blank'>cadastro.portosocorro@portoseguro.com.br</a><br><br>",
                                           "Atenciosamente,<br>Porto Socorro",
                                      "</body>",
                                   "</html>" 
                let m_cnh_nvenc = m_cnh_nvenc +1                   
     else 
               let lr_mail.msg = "<html>",
                                      "<body>",
                                           "<br>Prezado Prestador,<br><br> ",
                                           "Informamos que a CNH do socorrista <b>",upshift(lr_param.srrabvnom) clipped,
                                           " - ", upshift(lr_param.srrcoddig) clipped,
                                           " </b>esta com data de validade vencida em nosso cadastro. ", 
                                           "Sendo assim, encaminhe uma copia simples deste documento regularizado para o Porto Socorro,",
                                           "aos cuidados do Desenvolvimento da Rede de Prestadores ou pelo e-mail ",
                                           "<a href='mailto:cadastro.portosocorro@portoseguro.com.br' target='_blank'>cadastro.portosocorro@portoseguro.com.br</a>, evitando bloqueio do QRA.<br><br>",
                                           "Atenciosamente,<br>Porto Socorro",
                                      "</body>",
                                   "</html>"
               let m_cnh_venc = m_cnh_venc+1                     
    end if                                                      

     call figrc009_mail_send1(lr_mail.*)
          returning l_cod_erro, l_msg_erro
          
     if  l_cod_erro <> 0 then
         display "Erro no envio do email: ",
                 l_cod_erro using "<<<<<<&", " - ",
                 l_msg_erro clipped
     else 
          let m_lidos = m_lidos + 1 
          display "=======================================================" 
          display "Envie e-mail para: ",lr_mail.des clipped
          display "Com copia para: ",lr_mail.ccp  clipped
          display "Lidos: ",m_lidos
          display "Assunto: ",lr_mail.ass clipped 
          display "Data exame: ",mr_bdbsr127.exmvctdat
          display "=======================================================" 
     end if                          
                                       
 end function     
 
#----------------------------------------#
function  bdbsr127_busca_cadGest_Respon()
#----------------------------------------#        
   
   
   # BUSCA PELA DESCRICAO DA CADEIA DE GESTAO DO SOCORRISTA
   open cbdbsr127_04 using mr_cda_gestao.gstcdicod     
   fetch cbdbsr127_04 into mr_cda_gestao.sprnom, 
	                   mr_cda_gestao.gernom,
		           mr_cda_gestao.cdnnom,
		           mr_cda_gestao.anlnom 
		          
   if sqlca.sqlcode = 100 then
   	initialize mr_cda_gestao.sprnom,  
	           mr_cda_gestao.gernom,  
	           mr_cda_gestao.cdnnom,   
	           mr_cda_gestao.anlnom to null 
   end if

                        
   if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
      initialize mr_cda_gestao.* to null
      return  0 
   end if
   
   close cbdbsr127_04 
   
   # BUSCA PELA DESCRICAO DO SETOR 
   
   open cbdbsr127_05 using mr_cda_gestao.srrtip
   fetch cbdbsr127_05 into mr_cda_gestao.frtrpndes
   close cbdbsr127_05 
   
   initialize mr_cda_gestao.gstcdicod,
           mr_cda_gestao.srrtip to null	
end function
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            