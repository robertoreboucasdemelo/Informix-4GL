#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : POC SMS CENTRAL                                     #
# Modulo        : Batch                                               #
# Analista Resp.: Moises Gabel                                        #
# PSI           : 2013-09166                                          #
# Objetivo      : Batch para gerar relatorio da CENTRAL e PORTO SOC.  #
#                 para utilizacao na POC de satisfacao por SMS.       #
#.....................................................................#
# Desenvolvimento: Gabriel Rodrigues, Fornax                          #
# Liberacao      : 20/04/2013                                         #
#.....................................................................#
#---------------------------------------------------------------------#
database Porto

#Declara Variaveis Modulares.
define m_path char(100)


#------------------------------------------------------------------------------#
main

   #--- Abre banco de dados
   call fun_dba_abre_banco("CT24HS")

   create temp table tabela_heirct (funmatpes  integer,
  	                                funmat     char(30),
  	                                atdnom     char(100),
  	                                matspv     char(30),
  	                                spvnom     char(100),
  	                                matcood    char(30),
  	                                coodnom    char(100),
  	                                oprnom     char(100),
  	                                matger     char(30),
  	                                gernom     char(100) ) with no log
   create index fmat1 on tabela_heirct (funmatpes)

   call bdatr150_prepare()

   call bdatr150()



end main
#------------------------------------------------------------------------------#
function bdatr150_prepare()

  define l_sql          char(1000)


  let l_sql =  " select a.atdsrvnum, a.atdsrvano, a.atdetpdat           "
              ,"   from datmsrvacp a,                                   "
              ,"        datmservico c                                   "
              ,"   where a.atdetpcod = 4                                "
              ,"    and a.atdetpdat = ?                                 "
              ,"    and a.atdsrvseq in (select max(b.atdsrvseq)         "
              ,"                        from datmsrvacp b               "
              ,"                       where a.atdsrvnum = b.atdsrvnum  "
              ,"                         and a.atdsrvano = b.atdsrvano) "
              ,"    and a.atdsrvnum = c.atdsrvnum                       "
              ,"    and a.atdsrvano = c.atdsrvano                       "
              ,"    and c.asitipcod in (1,86)                           "
  prepare pbatch002 from l_sql
  declare cbatch002 cursor for pbatch002

  let l_sql = " select c24astdes"
             ,"   from datkassunto "
             ,"  where c24astcod = ? "
  prepare pbatch004 from l_sql
  declare cbatch004 cursor for pbatch004

  let l_sql = " select ufdcod,cidnom "
             ,"  from datmlcl "
             ," where atdsrvnum = ? "
             ,"   and atdsrvano = ? "
  prepare pbatch005 from l_sql
  declare cbatch005 cursor for pbatch005

  let l_sql = " select celteldddcod, "
             ,"        celtelnum "
             ,"   from datmlcl "
             ,"  where atdsrvnum = ? "
             ,"    and atdsrvano = ? "
  prepare pbatch006 from l_sql
  declare cbatch006 cursor for pbatch006

  let l_sql = " select a.c24solnom, "
             ,"        a.ciaempcod  "
             ,"   from datmservico a "
             ,"  where a.atdsrvnum = ? "
             ,"    and a.atdsrvano = ? "
  prepare pbatch007 from l_sql
  declare cbatch007 cursor for pbatch007

  let l_sql = " select srrcoddig,                                      "
             ,"        atdetpdat,                                      "
             ,"        atdetphor,                                      "
             ,"        pstcoddig                                       "
             ,"   from datmsrvacp a                                    "
             ,"  where atdsrvnum = ?                                   "
             ,"    and atdsrvano = ?                                   "
             ,"    and atdetpcod = 4                                   "
             #,"    and atdetpcod in (3,4) "
             ,"    and atdsrvseq in (select max(atdsrvseq)             "
             ,"                        from datmsrvacp b               "
             ,"                       where a.atdsrvnum = b.atdsrvnum  "
             ,"                         and a.atdsrvano = b.atdsrvano) "
   prepare pbatch008 from l_sql
   declare cbatch008 cursor for pbatch008

   let l_sql = " select c24astcod "
   	           ,"   from datmligacao a, "
   	           ,"        datmservico b  "
               ,"  where b.atdsrvnum = ? "
               ,"    and b.atdsrvano = ? "
               ,"    and b.c24solnom = ? "
               ,"    and b.atdsrvnum = a.atdsrvnum "
               ,"    and b.atdsrvano = a.atdsrvano "
   prepare pbatch009 from l_sql
   declare cbatch009 cursor for pbatch009

   let l_sql = " select b.srrabvnom, "
              ,"        a.gernom, "
              ,"        a.cdnnom, "
              ,"        a.anlnom  "
              ,"   from dpakprsgstcdi a, "
              ,"        datksrr b, "
              ,"        datrsrrpst c, "
              ,"        dpaksocor d "
              ,"  where b.srrcoddig = c.srrcoddig "
              ,"    and d.pstcoddig = c.pstcoddig "
              ,"    and a.gstcdicod = d.gstcdicod "
              ,"    and b.srrcoddig = ? "
              ,"    and d.pstcoddig = ? "
   prepare pbatch010 from l_sql
   declare cbatch010 cursor for pbatch010


   let l_sql = " select smsenvflg "
              ,"   from datmservicocmp "
              ,"  where atdsrvnum = ? "
              ,"    and atdsrvano = ? "
              ,"    and smsenvflg = 'N' "
   prepare pbatch012 from l_sql
   declare cbatch012 cursor for pbatch012

end function
#------------------------------------------------------------------------------#
function bdatr150 ()

  define l_param_ct record
  	     touchpoint  char(30),
  	     atdsrvnum    like datmligacao.atdsrvnum,
  	     atdsrvano    like datmligacao.atdsrvano,
         lignum       like datmligacao.lignum   ,
         ligdat       like datmligacao.ligdat   ,
         lighorinc    like datmligacao.lighorinc,
         c24funmat    like datmligacao.c24funmat,
         ciaempcod    like datmligacao.ciaempcod,
         c24astcod    like datmligacao.c24astcod,
         c24solnom    like datmligacao.c24solnom,
         smsenvflg    like datmservicocmp.smsenvflg,
         c24astdes    like datkassunto.c24astdes,
         ufdcod       like datmlcl.ufdcod,
         cidnom       like datmlcl.cidnom,
         celteldddcod like datmlcl.celteldddcod,
         celtelnum    like datmlcl.celtelnum,
         cianom       char(50) , #Empresa
         hierlvl1     char(100), #Atendente Central
         hierlvl2     char(100), #Supervisor Central
         hierlvl3     char(100), #Cordenador Central
         hierlvl4     char(100), #Gerente Central
         alert        char(200)
  end record

  define dirfisnom    char(100)
  define ws_pipe      char(100)
  define l_srvaux     char(100)
  define l_comando    char(200)
  define l_erro       smallint
  define l_celaux     char(100)
  define l_aux        char(2)
  define l_hoje_data  datetime year to minute
  define l_nome_rel   char(30)
  define l_data_aux   char(30)
  define l_data_teste date
  define l_nome_novo  char(30)
  define cont_total       smallint
  define cont_solnom      smallint
  define cont_flag_sms    smallint
  define cont_sem_cel     smallint
  define cont_nao_cel     smallint
  define cont_data        smallint
  define cont_hierarquia  smallint
  define cont_geral       smallint
  define l_msg            char(10000)

  define l_param_ps record
  	     touchpoint  char(30)                ,
  	     atdsrvnum    like datmservico.atdsrvnum,
  	     atdsrvano    like datmservico.atdsrvano,
  	     atddat       like datmservico.atddat,
  	     c24solnom    like datmservico.c24solnom,
  	     c24astcod    like datmligacao.c24astcod,
  	     c24astdes    like datkassunto.c24astdes,
  	     ciaempcod    like datmservico.ciaempcod,
  	     smsenvflg    like datmservicocmp.smsenvflg,
  	     celteldddcod like datmlcl.celteldddcod,
         celtelnum    like datmlcl.celtelnum,
         srrcoddig    like datmsrvacp.srrcoddig,
         atdetpdat    like datmsrvacp.atdetpdat,
         atdetphor    like datmsrvacp.atdetphor,
         pstcoddig    like datmsrvacp.pstcoddig,
         ufdcod       like datmlcl.ufdcod,
         cidnom       like datmlcl.cidnom,
         srrabvnom    like datksrr.srrabvnom,
         gernom       like dpakprsgstcdi.gernom,
         cdnnom       like dpakprsgstcdi.cdnnom,
         anlnom       like dpakprsgstcdi.anlnom,
  	     cianom       char(50),  #Empresa
  	     alert        char(50)   #Alerta
  end record


  let l_srvaux = null
  let l_aux    = null
  let l_hoje_data = null
  let l_nome_rel = null
  let l_data_aux = null
  initialize l_param_ct.* to null
  initialize l_param_ps.* to null

  let cont_total      = 0
  let cont_solnom     = 0
  let cont_flag_sms   = 0
  let cont_sem_cel    = 0
  let cont_nao_cel    = 0
  let cont_data       = 0
  let cont_hierarquia = 0
  let cont_geral      = 0
  let l_msg = null

  call f_path("DAT", "ARQUIVO")
      returning dirfisnom

  let l_data_teste = today - 1
  let l_hoje_data  = today
  let l_nome_rel  = 'porto_seguro_',
		     extend(l_hoje_data, year to year)  ,
		     extend(l_hoje_data, month to month)  ,
		     extend(l_hoje_data, day to day)  ,
		     extend(current, hour to hour),
		     extend(current, minute to minute)    ,
		      '.csv'


  let ws_pipe = dirfisnom clipped, "/",l_nome_rel

  display 'arquivo: ',ws_pipe sleep 2
  start report bdatr150_relatorio to ws_pipe
  output to report bdatr150_relatorio (  l_param_ct.touchpoint ,#TOUCHPOINT
                           l_celaux              ,#MOBILE NUMBER
                           l_aux                 ,#EMAIL
                           l_param_ct.cianom     ,#CUSTOMER TITLE
                           l_param_ct.c24solnom  ,#CUSTOMER NAME
                           l_srvaux              ,#CUSTOMER ID
                           l_param_ct.ligdat     ,#TRANSACTION DATE
                           l_param_ct.hierlvl1   ,#HIERARCHY LEVEL 1
                           l_param_ct.hierlvl2   ,#HIERARCHY LEVEL 2
                           l_param_ct.hierlvl3   ,#HIERARCHY LEVEL 3
                           l_param_ct.hierlvl4   ,#HIERARCHY LEVEL 4
                           l_aux                 ,#LEVEL 1 NAME
                           l_aux                 ,#LEVEL 2 NAME
                           l_param_ct.alert      ,#ALERT EMAIL
                           l_param_ct.cianom     ,#FIELD FILTER 1 EMPRESA
                           l_param_ct.c24astdes  ,#FIELD FILTER 2 TIPO DE SERVICO
                           l_param_ct.ufdcod     ,#FIELD FILTER 3 ESTADO
                           l_param_ct.cidnom     ,#FIELD FILTER 4 CIDADE
                           l_param_ct.ligdat     )#FIELD FILTER 5 HORA INICIAL


  #Seleciona Servicos PORTO SOCORRO
  display "PORTOSOCORRO"
  whenever error continue
  foreach cbatch002 using l_data_teste
     into l_param_ps.atdsrvnum
         ,l_param_ps.atdsrvano
         ,l_param_ps.atdetpdat
  whenever error stop
  if sqlca.sqlcode <> 0 then
  	 display "Erro SELECT CBATCH002 /", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
  	 display "NAO SERVICOS CADASTRADOS PARA DATA SELECIONADA"
  end if

  let cont_geral = cont_geral + 1
  whenever error continue
  open cbatch007 using  l_param_ps.atdsrvnum, l_param_ps.atdsrvano
  fetch cbatch007 into  l_param_ps.c24solnom, l_param_ps.ciaempcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
  	display "SERVICO: ", l_param_ps.atdsrvano using '<<', '-', l_param_ps.atdsrvnum using '<<<<<<<<<&'
  	       ," Erro ao buscar dados de nome solicitante e codigo empresa ",l_param_ps.ciaempcod
  	  let cont_solnom = cont_solnom + 1
  	continue foreach
  end if

  #Valida Flag de SMS - APENAS SE EMPRESA = ITAU
  if l_param_ps.ciaempcod = 84 then #ITAU
	  whenever error continue
	  open cbatch012 using l_param_ps.atdsrvnum, l_param_ps.atdsrvano
	   fetch cbatch012 into l_param_ps.smsenvflg
	  whenever error stop
	  if sqlca.sqlcode = 0 then
	  	display "SERVICO: ", l_param_ps.atdsrvano using '<<', '-', l_param_ps.atdsrvnum using '<<<<<<<<<&'
	  	       ," Servico com flag N - Empresa: ",l_param_ps.ciaempcod
	  	  let cont_flag_sms = cont_flag_sms + 1
	  	continue foreach
	  end if
	end if


  #Define TouchPoint
  let l_param_ps.touchpoint = 'Field'

  #Seleciona Celular
  whenever error continue
  open cbatch006 using l_param_ps.atdsrvnum, l_param_ps.atdsrvano
  fetch cbatch006 into l_param_ps.celteldddcod, l_param_ps.celtelnum
  whenever error stop
  	  if sqlca.sqlcode <> 0 then
  		   display "Erro SELECT CBATCH006 /", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
  	  end if
  	  if l_param_ps.celteldddcod is null or
  		   l_param_ps.celtelnum is null then
  		   display "SERVICO: ", l_param_ps.atdsrvano using '<<', '-', l_param_ps.atdsrvnum using '<<<<<<<<<&'
  		 	        ," Num. Celular Nao Informado - Empresa: ",l_param_ps.ciaempcod
  		 	    let cont_sem_cel = cont_sem_cel + 1
  		 	 continue foreach
  	  end if

  	  if l_param_ps.celtelnum < 50000000 or
  		 l_param_ps.celtelnum > 999999999 then
  		 	display "SERVICO: ", l_param_ps.atdsrvano using '<<', '-', l_param_ps.atdsrvnum using '<<<<<<<<<&'
  		 	       ," Num. Informado nao e Num. Celular - Empresa: ",l_param_ps.ciaempcod
  		 	     let cont_nao_cel = cont_nao_cel + 1
  		 	continue foreach
      end if

  	  let l_celaux = null
  	  let l_celaux = l_param_ps.celteldddcod clipped,
			 l_param_ps.celtelnum  using '<<<<<<<<<&'

  	  #Seleciona CustomerTitle, e CustomerId
  	  if l_param_ps.ciaempcod = 1 then
  		   let l_param_ps.cianom = 'PORTO SEGURO'
  	  else if l_param_ps.ciaempcod = 35 then
  		        let l_param_ps.cianom = 'AZUL SEGUROS'
  	       else if l_param_ps.ciaempcod = 43 then
  			           let l_param_ps.cianom = 'PORTO SEGURO SERVICOS'
  		          else
  			           let l_param_ps.cianom = 'ITAU SEGUROS'
  		          end if
  	       end if
      end if

      let l_srvaux = null
      let l_srvaux =  l_param_ps.atdsrvnum using '<<<<<<<<<&',"-", l_param_ps.atdsrvano using '<<'

      #Seleciona Transaction Date
      whenever error continue
      open cbatch008 using l_param_ps.atdsrvnum, l_param_ps.atdsrvano
      fetch cbatch008 into l_param_ps.srrcoddig, l_param_ps.atdetpdat, l_param_ps.atdetphor, l_param_ps.pstcoddig
      whenever error continue
      if sqlca.sqlcode <> 0 then
      	 display "Erro SELECT cbatch008 /", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
      end if
      if l_param_ps.atdetpdat is null then
      	 display "SERVICO: ", l_param_ps.atdsrvano using '<<', '-', l_param_ps.atdsrvnum using '<<<<<<<<<&'
      	        , " Data nao informada - Empresa: ",l_param_ps.ciaempcod
      	     let cont_data = cont_data + 1
      	 continue foreach
      end if

      #Formata Transaction Date
      let l_data_aux = null
      if l_param_ps.atdetpdat is not null and
      	 l_param_ps.atdetphor is not null then

      	 let l_data_aux = l_param_ps.atdetpdat, " ", l_param_ps.atdetphor, ":00"
      end if

      #Seleciona Hierarquia PS
      whenever error continue
      open cbatch010 using l_param_ps.srrcoddig, l_param_ps.pstcoddig
      fetch cbatch010 into l_param_ps.srrabvnom, #Socorrista
                           l_param_ps.gernom,    #Gerente
                           l_param_ps.cdnnom,    #Coordenador
                           l_param_ps.anlnom     #Analista
      whenever error stop
      {if sqlca.sqlcode <> 0 then
      	display "ERRO SELECT cbatch010 /", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
      	display "SERVICO: ", l_param_ps.atdsrvano using '<<', '-', l_param_ps.atdsrvnum using '<<<<<<<<<&'
      	       ," Nao Consta Hierarquia"
      	     let cont_hierarquia = cont_hierarquia + 1
      	continue foreach
      end if}

      if l_param_ps.srrabvnom is null or
      	 l_param_ps.gernom    is null or
      	 l_param_ps.cdnnom    is null or
      	 l_param_ps.anlnom    is null then
      	 display "SERVICO: ", l_param_ps.atdsrvano using '<<', '-', l_param_ps.atdsrvnum using '<<<<<<<<<&'
      	       ," Nao Consta Hierarquia - Empresa: ",l_param_ps.ciaempcod
      	     let cont_hierarquia = cont_hierarquia + 1
      	 	continue foreach
      end if

      #Define Alert_Email
      let l_param_ps.alert = "Alerta.PortoSocorro@portoseguro.com.br"

      #Define Filtros 2 e 5
      whenever error continue
      open cbatch009 using l_param_ps.atdsrvnum, l_param_ps.atdsrvano, l_param_ps.c24solnom
      fetch cbatch009 into l_param_ps.c24astcod
      whenever error stop
      if sqlca.sqlcode <> 0 then
       	display "Erro SELECT cbatch009 /", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
      end if

     whenever error continue
  	 open cbatch004 using l_param_ps.c24astcod
  	 fetch cbatch004 into l_param_ps.c24astdes
  	 whenever error stop
  	 if sqlca.sqlcode <> 0 then
  		display "Erro SELECT CBATCH004 /", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
  		let l_param_ps.c24astdes = null
  	 end if

  	 whenever error continue
  	 open cbatch005 using l_param_ps.atdsrvnum, l_param_ps.atdsrvano
  	 fetch cbatch005 into l_param_ps.ufdcod, l_param_ps.cidnom
  	 whenever error stop
  	 if sqlca.sqlcode <> 0 then
  		 display "Erro SELECT CBATCH005 /", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
  		 let l_param_ps.ufdcod = null
  		 let l_param_ps.cidnom = null
  	 end if

  	 output to report bdatr150_relatorio (l_param_ps.touchpoint ,#TOUCHPOINT
                            l_celaux              ,#MOBILE NUMBER
                            l_aux                 ,#EMAIL
                            l_param_ps.cianom     ,#CUSTOMER TITLE
                            l_param_ps.c24solnom  ,#CUSTOMER NAME
                            l_srvaux              ,#CUSTOMER ID
                            l_data_aux            ,#TRANSACTION DATE
                            l_param_ps.srrabvnom  ,#HIERARCHY LEVEL 1
                            l_param_ps.anlnom     ,#HIERARCHY LEVEL 2
                            l_param_ps.cdnnom     ,#HIERARCHY LEVEL 3
                            l_param_ps.gernom     ,#HIERARCHY LEVEL 4
                            l_aux                 ,#LEVEL 1 NAME
                            l_aux                 ,#LEVEL 2 NAME
                            l_param_ps.alert      ,#ALERT EMAIL
                            l_param_ps.cianom     ,#FIELD FILTER 1 EMPRESA
                            l_param_ps.c24astdes  ,#FIELD FILTER 2 TIPO DE SERVICO
                            l_param_ps.ufdcod     ,#FIELD FILTER 3 ESTADO
                            l_param_ps.cidnom     ,#FIELD FILTER 4 CIDADE
                            l_param_ps.atdetphor  )#FIELD FILTER 5 HORA INICIAL
     let cont_total = cont_total + 1

  end foreach

  finish report bdatr150_relatorio

  let l_msg = "\n",
               "---------------| RESUMO MOVIMENTO DO DIA ",l_data_teste  clipped,"|--------------------- ","\n",
               "Arquivo...................: ", l_nome_rel                      clipped, "\n",
               "Busca de solicitante......: ",cont_solnom                using "<<#####&", "\n",
               "Servico com flag N........: ",cont_flag_sms              using "<<#####&", "\n",
               "Celular Nao Informado.....: ",cont_sem_cel               using "<<#####&", "\n",
               "Nao e Num. Celular........: ",cont_nao_cel               using "<<#####&", "\n",
               "Data nao informada........: ",cont_data                  using "<<#####&", "\n",
               "Nao Consta Hierarquia.....: ",cont_hierarquia            using "<<#####&", "\n",
               "Total do Arquivo..........: ",cont_total                 using "<<#####&", "\n",
               "Total Geral...............: ",cont_geral                 using "<<#####&", "\n"
    display l_msg
end function

#------------------------------------------------------------------------------#
report bdatr150_relatorio(l_imp)

   define l_imp record
   	      touchpoint    char(30) ,                  #TOUCHPOINT
          mobilenumber  char(100),                  #MOBILE NUMBER
          email         char(10) ,                  #EMAIL
          customertitle char(50) ,                  #CUSTOMER TITLE
          customername  like datmligacao.c24solnom, #CUSTOMER NAME
          customerid    char(100),                  #CUSTOMER ID
          transdat      char(30),                   #TRANSACTION DATE
          hierlvl1      char(100),                  #HIERARCHY LEVEL 1
          hierlvl2      char(100),                  #HIERARCHY LEVEL 2
          hierlvl3      char(100),                  #HIERARCHY LEVEL 3
          hierlvl4      char(100),                  #HIERARCHY LEVEL 4
          lvl1name      char(10),                   #LEVEL 1 NAME
          lvl2name      char(10),                   #LEVEL 2 NAME
          alertemail    char(200),                  #ALERT EMAIL
          field1        char(50) ,                  #FIELD FILTER 1 EMPRESA
          field2        like datkassunto.c24astdes, #FIELD FILTER 2 TIPO DE SERVICO
          field3        like datmlcl.ufdcod,        #FIELD FILTER 3 ESTADO
          field4        like datmlcl.cidnom,        #FIELD FILTER 4 CIDADE
          field5        like datmligacao.lighorinc  #FIELD FILTER 5 HORA INICIAL
   end record

   define l_imp_aux record
          touchpoint    char(30) ,                  #TOUCHPOINT
          mobilenumber  char(100),                  #MOBILE NUMBER
          email         char(10) ,                  #EMAIL
          customertitle char(50) ,                  #CUSTOMER TITLE
          customername  char(100),                  #CUSTOMER NAME
          customerid    char(100),                  #CUSTOMER ID
          transdat      char(30) ,                  #TRANSACTION DATE
          hierlvl1      char(100),                  #HIERARCHY LEVEL 1
          hierlvl2      char(100),                  #HIERARCHY LEVEL 2
          hierlvl3      char(100),                  #HIERARCHY LEVEL 3
          hierlvl4      char(100),                  #HIERARCHY LEVEL 4
          lvl1name      char(10) ,                  #LEVEL 1 NAME
          lvl2name      char(10) ,                  #LEVEL 2 NAME
          alertemail    char(200),                  #ALERT EMAIL
          field1        char(50) ,                  #FIELD FILTER 1 EMPRESA
          field2        char(100),                  #FIELD FILTER 2 TIPO DE SERVICO
          field3        char(100),                  #FIELD FILTER 3 ESTADO
          field4        char(100),                  #FIELD FILTER 4 CIDADE
          field5        char(10)                     #FIEDL FILTER 5 HORA INICIAL
   end record

   define l_hora_cheia char(10)

   output
     top    margin 00
     bottom margin 00
     left   margin 00
     right  margin 00
     page   length 01

   format
      on every row

      if l_imp.touchpoint is null then
      	 print '"TOUCHPOINT"'        ,",",
               '"MOBILE NUMBER"'     ,",",
               '"EMAIL"'             ,",",
               '"CUSTOMER TITLE"'    ,",",
               '"CUSTOMER NAME"'     ,",",
               '"CUSTOMER ID"'       ,",",
               '"TRANSACTION DATE"'  ,",",
               '"HIERARCHY LEVEL 1"' ,",",
               '"HIERARCHY LEVEL 2"' ,",",
               '"HIERARCHY LEVEL 3"' ,",",
               '"HIERARCHY LEVEL 4"' ,",",
               '"LEVEL 1 NAME"'      ,",",
               '"LEVEL 2 NAME"'      ,",",
               '"ALERT EMAIL"'       ,",",
               '"FIELD FILTER 1"'    ,",",
               '"FIELD FILTER 2"'    ,",",
               '"FIELD FILTER 3"'    ,",",
               '"FIELD FILTER 4"'    ,",",
               '"FIELD FILTER 5"'
      else

   initialize l_imp_aux.* to null

   #Coloca aspas
   let l_imp_aux.touchpoint    = '"', l_imp.touchpoint clipped, '"'
   let l_imp_aux.mobilenumber  = '"', l_imp.mobilenumber clipped, '"'
   let l_imp_aux.email         = '"', l_imp.email clipped, '"'
   let l_imp_aux.customertitle = '"', l_imp.customertitle clipped, '"'
   let l_imp_aux.customername  = '"', l_imp.customername clipped, '"'
   let l_imp_aux.customerid    = '"', l_imp.customerid clipped, '"'
   let l_imp_aux.transdat      = '"', l_imp.transdat clipped, '"'
   let l_imp_aux.hierlvl1      = '"', l_imp.hierlvl1 clipped, '"'
   let l_imp_aux.hierlvl2      = '"', l_imp.hierlvl2 clipped, '"'
   let l_imp_aux.hierlvl3      = '"', l_imp.hierlvl3 clipped, '"'
   let l_imp_aux.hierlvl4      = '"', l_imp.hierlvl4 clipped, '"'
   let l_imp_aux.lvl1name      = '"', l_imp.lvl1name clipped, '"'
   let l_imp_aux.lvl2name      = '"', l_imp.lvl2name clipped, '"'
   let l_imp_aux.alertemail    = '"', l_imp.alertemail clipped, '"'
   let l_imp_aux.field1        = '"', l_imp.field1 clipped, '"'
   let l_imp_aux.field2        = '"', l_imp.field2 clipped, '"'
   let l_imp_aux.field3        = '"', l_imp.field3 clipped, '"'
   let l_imp_aux.field4        = '"', l_imp.field4 clipped, '"'

	 let l_hora_cheia = l_imp.field5
	 let l_hora_cheia = '"', l_hora_cheia[1,2], ':00"'
         print l_imp_aux.touchpoint   clipped  ,",",
               l_imp_aux.mobilenumber clipped  ,",",
               l_imp_aux.email        clipped  ,",",
               l_imp_aux.customertitle clipped ,",",
               l_imp_aux.customername  clipped ,",",
               l_imp_aux.customerid   clipped  ,",",
               l_imp_aux.transdat clipped      ,",",
               l_imp_aux.hierlvl1 clipped      ,",",
               l_imp_aux.hierlvl2 clipped      ,",",
               l_imp_aux.hierlvl3 clipped      ,",",
               l_imp_aux.hierlvl4 clipped      ,",",
               l_imp_aux.lvl1name clipped      ,",",
               l_imp_aux.lvl2name clipped      ,",",
               l_imp_aux.alertemail clipped    ,",",
               l_imp_aux.field1 clipped        ,",",
               l_imp_aux.field2 clipped        ,",",
               l_imp_aux.field3 clipped        ,",",
               l_imp_aux.field4 clipped        ,",",
               l_hora_cheia
      end if

end report
#------------------------------------------------------------------------------#

