#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Central Itau                                               #
# Modulo.........: cts52m00                                                   #
# Objetivo.......: Batch Para Carregar os Enderecos Indexados do Itau         #
# Analista Resp. : Carlos Ruiz                                                #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 27/09/2014                                                 #
#.............................................................................#
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR     ORIGEM     ALTERACAO                                   #
# ---------- --------  ---------- ------------------------------------------- #
# 10/04/2015 Luiz      CT324042   1 - Criacao de controle de horario para     #
#                                 processamento.                              #
#                                 2 - Criacao de controle de restart por      #
#                                 apolice no arquivo.                         #
#-----------------------------------------------------------------------------#


database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"



define m_path_log        char(100)
define m_cts52m00_prep   smallint
define m_arquivo         char(100)
define m_mensagem        char(150)
define m_contador        smallint
define m_cont            smallint
define m_rowid           integer

define mr_total record
   lidos         integer ,
   gravados      integer ,
   desprezados   integer ,
   ja_existentes integer ,
   mapas         integer ,
   processados   integer ,
   flag_mapa     char(03)
end record

define mr_param record
	  ini date                                                      ,
	  fim date                                                      ,
	  hour_ini datetime hour to second                              ,
	  hour_fim datetime hour to second                              ,
	  hour_sta datetime hour to second                              ,
	  hour_end datetime hour to second                              ,
	  hour_avg interval hour to second                              ,
    itaasiarqvrsnum         like datmdetitaasiarq.itaasiarqvrsnum ,
    itaasiarqvrsnum_ultimo  like datmdetitaasiarq.itaasiarqvrsnum
end record

define mr_processo record
  itaciacod      like datmitaapl.itaciacod  ,
  itaramcod      like datmitaapl.itaramcod  ,
  itaaplnum      like datmitaapl.itaaplnum  ,
  aplseqnum      like datmitaapl.aplseqnum  ,
  lgdtip         like datmlcl.lgdtip        ,
  seglgdnom      like datmitaapl.seglgdnom  ,
  seglgdnum      like datmitaapl.seglgdnum  ,
  segbrrnom      like datmitaapl.segbrrnom  ,
  segcidnom      like datmitaapl.segcidnom  ,
  segufdsgl      like datmitaapl.segufdsgl  ,
  segcepnum      like datmitaapl.segcepnum  ,
  segcepcmpnum	 like datmitaapl.segcepcmpnum
end record


define mr_data record
  inicio date ,
  fim    date
end record

#========================================================================
function cts52m00()
#========================================================================

  define l_continue smallint
   # Funcao responsavel por preparar o programa para a execucao
   # - Prepara as instrucoes SQL
   # - Obtem os caminhos de processamento
   # - Cria o arquivo de log
   #

   initialize mr_param.* to null

   let g_indexado.batch = true

   call cts52m00_exibe_inicio()
   let mr_param.hour_sta = current

   call fun_dba_abre_banco("CT24HS")

   set lock mode to wait 10
   set isolation to dirty read

   let m_cts52m00_prep = false


   let mr_total.lidos         = 0
   let mr_total.gravados      = 0
   let mr_total.desprezados   = 0
   let mr_total.ja_existentes = 0
   let mr_total.mapas         = 0
   let m_cont                 = 0
   let mr_total.flag_mapa     = null


   display "##################################"
   display " PREPARANDO... "
   display "##################################"

   call cts52m00_prepare()

   call cts52m00_recupera_contador()

   initialize mr_data.* to null

   call cts52m00_carga_diaria()

   display "##################################"
   display " CARREGANDO APOLICES DIARIAS... "
   display "##################################"


   call cts52m00_carrega_endereco_diario()

   if cts52m00_valida_carga() then

   	    initialize mr_data.* to null
   	    let mr_param.hour_sta = current

   	    let mr_total.lidos         = 0
   	    let mr_total.gravados      = 0
        let mr_total.desprezados   = 0
        let mr_total.ja_existentes = 0
        let mr_total.mapas         = 0
        let m_cont                 = 0
        let mr_total.flag_mapa     = null

        display "##################################"
        display " CARREGANDO APOLICES FULL... "
        display "##################################"

        if not cts52m00_carga_full() then
           exit program
        end if

        call cts52m00_exibe_final()

        call cts52m00_dispara_email()


   end if




#========================================================================
end function
#========================================================================

#===============================================================================
 function cts52m00_prepare()
#===============================================================================

define l_sql char(10000)



 let l_sql =  ' insert into dattitasrvatdidxend   '
           ,  '   (itaciacod                      '
           ,  '   ,itaramcod                      '
           ,  '   ,itaaplnum                      '
           ,  '   ,aplseqnum                      '
           ,  '   ,lgdtipnom                      '
           ,  '   ,lgdnom                         '
           ,  '   ,brrnom                         '
           ,  '   ,brrcplnom                      '
           ,  '   ,cepnum                         '
           ,  '   ,cepcplnum                      '
           ,  '   ,lttnum                         '
           ,  '   ,lgnnum                         '
           ,  '   ,lcacod)                        '
           ,  ' values(?,?,?,?,?,?,?,?,?,?,?,?,?) '
 prepare p_cts52m00_001 from l_sql


  let l_sql =  ' select itaciacod    ,           '
              ,'        itaramcod    ,           '
              ,'        itaaplnum    ,           '
              ,'        aplseqnum    ,           '
              ,'        seglgdnom    ,           '
              ,'        seglgdnum    ,           '
              ,'        segbrrnom    ,           '
              ,'        segcidnom    ,           '
              ,'        segufdsgl    ,           '
              ,'        segcepnum    ,           '
              ,'        segcepcmpnum	           '
              ,' from datmitaapl                 '
              ,' where itaaplvigincdat = ?       '
  prepare p_cts52m00_002 from l_sql
  declare c_cts52m00_002 cursor for p_cts52m00_002


  let l_sql = ' select cpodes        '
             ,' from datkdominio     '
             ,' where cponom =  ?    '
             ,' and   cpocod =  ?    '
  prepare p_cts52m00_003 from l_sql
  declare c_cts52m00_003 cursor for p_cts52m00_003


  let l_sql =  ' update datkdominio    '
             , ' set   cpodes =  ?     '
             , ' where cponom =  ?     '
             , ' and   cpocod =  ?     '
  prepare p_cts52m00_004 from l_sql


  let l_sql = ' select cpodes        '
             ,' from datkdominio     '
             ,' where cponom =  ?    '
  prepare p_cts52m00_005 from l_sql
  declare c_cts52m00_005 cursor for p_cts52m00_005


  let l_sql = ' select count(*)                '
           , '   from datkdominio              '
           , '  where cponom = "tipo_endereco" '
           , '    and cpodes = ?               '
  prepare p_cts52m00_006 from l_sql
  declare c_cts52m00_006 cursor for p_cts52m00_006

  let l_sql = ' select count(*)                '
           , '   from dattitasrvatdidxend      '
           , '  where itaciacod = ?            '
           , '    and itaramcod = ?            '
           , '    and itaaplnum = ?            '
           , '    and aplseqnum = ?            '
  prepare p_cts52m00_007 from l_sql
  declare c_cts52m00_007 cursor for p_cts52m00_007


  let l_sql =  ' update dattitasrvatdidxend    '
           ,  '   set lgdtipnom  = ?           '
           ,  '  ,    lgdnom     = ?           '
           ,  '  ,    brrnom     = ?           '
           ,  '  ,    brrcplnom  = ?           '
           ,  '  ,    cepnum     = ?           '
           ,  '  ,    cepcplnum  = ?           '
           ,  '  ,    lttnum     = ?           '
           ,  '  ,    lgnnum     = ?           '
           ,  '  ,    lcacod     = ?           '
           , '  where itaciacod = ?            '
           , '    and itaramcod = ?            '
           , '    and itaaplnum = ?            '
           , '    and aplseqnum = ?            '
 prepare p_cts52m00_008 from l_sql


 let l_sql = ' select max(itaasiarqvrsnum)    '
          , '  from datmdetitaasiarq          '
 prepare p_cts52m00_009 from l_sql
 declare c_cts52m00_009 cursor for p_cts52m00_009

 let l_sql =  ' select itaciacod    ,           '
             ,'        itaramcod    ,           '
             ,'        itaaplnum    ,           '
             ,'        aplseqnum    ,           '
             ,'        seglgdnom    ,           '
             ,'        seglgdnum    ,           '
             ,'        segbrrnom    ,           '
             ,'        segcidnom    ,           '
             ,'        segufdsgl    ,           '
             ,'        segcepnum    ,           '
             ,'        segcepcmpnum ,	        '
             ,'        rowid                    '
             ,' from datmitaapl                 '
             ,' where itaasiarqvrsnum = ?       '
             ,'   and rowid          >= ?       '
             ,' order by rowid                  '
 prepare p_cts52m00_010 from l_sql
 declare c_cts52m00_010 cursor for p_cts52m00_010

 let l_sql =  ' select lgdtipnom          '
           ,  '       ,lgdnom             '
           ,  '       ,brrnom             '
           ,  '       ,brrcplnom          '
           ,  '       ,cepnum             '
           ,  '       ,lttnum             '
           ,  '       ,lgnnum             '
           ,  '       ,lcacod             '
           ,  ' from dattitasrvatdidxend  '
           ,  '  where itaciacod = ?      '
           ,  '    and itaramcod = ?      '
           ,  '    and itaaplnum = ?      '
           ,  '    and aplseqnum = ?      '
 prepare p_cts52m00_011 from l_sql
 declare c_cts52m00_011 cursor for p_cts52m00_011

 let l_sql =  ' select lgdtip       '
           ,  '       ,lgdnom       '
           ,  ' from glaklgd        '
           ,  '  where lgdcep  = ?  '
           ,  '  and lgdcepcmp = ?  '
 prepare p_cts52m00_012 from l_sql
 declare c_cts52m00_012 cursor for p_cts52m00_012
 let l_sql =  ' select count(*)                         '
             ,' from datmitaapl                         '
             ,' where itaasiarqvrsnum between ? and ?   '
 prepare p_cts52m00_013 from l_sql
 declare c_cts52m00_013 cursor for p_cts52m00_013

 let l_sql =  ' select count(*)                         '
              ,' from datmitaapl                        '
              ,' where itaaplvigincdat between ? and ?  '
  prepare p_cts52m00_014 from l_sql
  declare c_cts52m00_014 cursor for p_cts52m00_014

 let m_cts52m00_prep = true

#========================================================================
end function
#========================================================================





#========================================================================
 function cts52m00_carrega_endereco_full()
#========================================================================

define lr_retorno record
	erro            smallint                  ,
	lclltt          like datmlcl.lclltt       ,
	lcllgt          like datmlcl.lcllgt       ,
	lgdtip          like datmlcl.lgdtip       ,
	lgdnom          like datmlcl.lgdnom       ,
	brrnom          like datmlcl.brrnom       ,
	lclbrrnom       like datmlcl.lclbrrnom    ,
	lgdcep          like datmlcl.lgdcep       ,
	lgdcepcmp       like datmlcl.lgdcepcmp    ,
	c24lclpdrcod    like datmlcl.c24lclpdrcod
end record

define lr_mapa record
	lgdtip    like datmlcl.lgdtip ,
	lgdnom    like datmlcl.lgdnom
end record

define l_data date
define l_hora datetime hour to second

initialize mr_processo.*, lr_retorno.*, lr_mapa.* to null

let l_data = null
let l_hora = null



    #--------------------------------------------------------
    # Recupera os Dados da Apolice Itau
    #--------------------------------------------------------

    open c_cts52m00_002 using mr_data.inicio

    foreach c_cts52m00_002 into mr_processo.itaciacod
    	                        , mr_processo.itaramcod
    	                        , mr_processo.itaaplnum
    	                        , mr_processo.aplseqnum
    	                        , mr_processo.seglgdnom
    	                        , mr_processo.seglgdnum
    	                        , mr_processo.segbrrnom
    	                        , mr_processo.segcidnom
    	                        , mr_processo.segufdsgl
                              , mr_processo.segcepnum
                              , mr_processo.segcepcmpnum




          if m_cont = m_contador then
          	   call cts52m00_exibe_dados_totais()
          	   let m_cont = 0
          end if

          let m_cont = m_cont + 1


          #--------------------------------------------------------
          # Recupera Logradouro da Tabela de Mapas
          #--------------------------------------------------------

          call cts52m00_recupera_endereco_mapa(mr_processo.segcepnum   ,
                                               mr_processo.segcepcmpnum)
          returning lr_mapa.lgdtip,
                    lr_mapa.lgdnom


          if lr_mapa.lgdtip is null   or
             lr_mapa.lgdnom is null   then

             call cts52m00_retira_tipo_lougradouro(mr_processo.seglgdnom)
             returning mr_processo.lgdtip
                      ,mr_processo.seglgdnom
             let mr_total.flag_mapa     = "Nao"
          else

          	  let mr_total.mapas = mr_total.mapas + 1
          	  let mr_processo.lgdtip    = lr_mapa.lgdtip
          	  let mr_processo.seglgdnom = lr_mapa.lgdnom
              let mr_total.flag_mapa     = "Sim"

          end if

          # Tipo de Lougradouro
          call cts52m00_retira_acentos(mr_processo.lgdtip)
          returning mr_processo.lgdtip

          let mr_processo.lgdtip = upshift(mr_processo.lgdtip)

          # Lougradouro
          call cts52m00_retira_acentos(mr_processo.seglgdnom)
          returning mr_processo.seglgdnom

          let mr_processo.seglgdnom = upshift(mr_processo.seglgdnom)

          # Bairro
          call cts52m00_retira_acentos(mr_processo.segbrrnom)
          returning mr_processo.segbrrnom

          let mr_processo.segbrrnom = upshift(mr_processo.segbrrnom)

          # Cidade
          call cts52m00_retira_acentos( mr_processo.segcidnom)
          returning  mr_processo.segcidnom

   	      let  mr_processo.segcidnom = upshift( mr_processo.segcidnom)


    	    #--------------------------------------------------------
    	    # Chama a Roteirizacao Automatica
    	    #--------------------------------------------------------

    	    call ctx25g05_pesq_auto(mr_processo.lgdtip      ,
                                  mr_processo.seglgdnom   ,
                                  mr_processo.seglgdnum   ,
                                  mr_processo.segbrrnom   ,
                                  mr_processo.segbrrnom   ,
                                  mr_processo.segufdsgl   ,
                                  mr_processo.segcidnom   )

          returning lr_retorno.erro        ,
                    lr_retorno.lclltt      ,
                    lr_retorno.lcllgt      ,
                    lr_retorno.lgdtip      ,
                    lr_retorno.lgdnom      ,
                    lr_retorno.brrnom      ,
                    lr_retorno.lclbrrnom   ,
                    lr_retorno.lgdcep      ,
                    lr_retorno.c24lclpdrcod




    	     let mr_total.lidos  = mr_total.lidos + 1

    	     if lr_retorno.erro   <> 0    or
    	     	  lr_retorno.lcllgt is null or
    	     	  lr_retorno.lclltt is null then

    	     	  output to report cts52m00_report()

    	     	  let mr_total.desprezados  = mr_total.desprezados + 1
    	        continue foreach
    	     end if

    	     if lr_retorno.lgdtip is null or
         	 	  lr_retorno.lgdtip = ""    then
         	 	  	let lr_retorno.lgdtip = mr_processo.lgdtip
         	 end if

         	 if lr_retorno.lgdnom is null or
         	 	  lr_retorno.lgdnom = ""    then
         	 	  	let lr_retorno.lgdnom = mr_processo.seglgdnom
         	 end if

         	 if lr_retorno.brrnom is null or
         	 	  lr_retorno.brrnom = ""    then
         	 	  	let lr_retorno.brrnom = mr_processo.segbrrnom
         	 end if

         	 if lr_retorno.lclbrrnom is null or
         	 	  lr_retorno.lclbrrnom = ""    then
         	 	  	let lr_retorno.lclbrrnom = mr_processo.segbrrnom
         	 end if


    	     if not cts52m00_verifica_endereco(mr_processo.itaciacod,
    	                                       mr_processo.itaramcod,
    	                                       mr_processo.itaaplnum,
    	                                       mr_processo.aplseqnum) then



    	         #--------------------------------------------------------
    	         # Inclui o Endereco Indexado
    	         #--------------------------------------------------------

    	         call cts52m00_inclui_endereco(mr_processo.itaciacod
    	                                      ,mr_processo.itaramcod
    	                                      ,mr_processo.itaaplnum
    	                                      ,mr_processo.aplseqnum
    	                                      ,lr_retorno.lclltt
    	                                      ,lr_retorno.lcllgt
    	                                      ,lr_retorno.lgdtip
    	                                      ,lr_retorno.lgdnom
    	                                      ,lr_retorno.brrnom
    	                                      ,lr_retorno.lclbrrnom
    	                                      ,lr_retorno.lgdcep
    	                                      ,lr_retorno.lgdcepcmp
    	                                      ,lr_retorno.c24lclpdrcod)
    	          returning lr_retorno.erro

    	          if lr_retorno.erro = 0 then
    	             let mr_total.gravados  = mr_total.gravados + 1
    	          else
    	          	 let mr_total.desprezados  = mr_total.desprezados + 1
    	          end if
         else
         	  let mr_total.ja_existentes  = mr_total.ja_existentes + 1
         end if


    end foreach


#========================================================================
end function
#========================================================================



#========================================================================
function cts52m00_exibe_inicio()
#========================================================================
define l_data  date,
       l_hora  datetime hour to second

let l_data            = today
let l_hora            = current
let mr_param.ini      = today
let mr_param.hour_ini = current

   display " "
   display "-----------------------------------------------------------"
   display " INICIO cts52m00 - CARGA DE ENDERECOS INDEXADOS ITAU       "
   display "-----------------------------------------------------------"
   display " "
   display " INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog("------------------------------------------------------")
   let m_mensagem = "INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog(m_mensagem)


#========================================================================
end function
#========================================================================

#========================================================================
function cts52m00_exibe_final()
#========================================================================
   define l_data  date,
          l_hora  datetime hour to second


   let l_data            = today
   let l_hora            = current
   let mr_param.fim      = today
   let mr_param.hour_fim = current
   display " "
   display " TERMINO DO PROCESSAMENTO...: ", l_data, " ", l_hora
   let m_mensagem = " TERMINO DO PROCESSAMENTO...: ", l_data, " ", l_hora
   call errorlog(m_mensagem)
   call errorlog("------------------------------------------------------")

#========================================================================
end function
#========================================================================


#========================================================================
 function cts52m00_carga_diaria()
#========================================================================

  let mr_data.inicio = today

  display ""
  display "======================================="
  display "PROCESSANDO DATA...", mr_data.inicio
  display "======================================="
#========================================================================
end function
#========================================================================



#========================================================================
 function cts52m00_recupera_data_inicio()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata002_inicio"
let lr_retorno.cpocod = 1


  open c_cts52m00_003 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_cts52m00_003 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes is not null  then
     let mr_data.inicio =  lr_retorno.cpodes
  end if


#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_recupera_data_fim()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata002_fim"
let lr_retorno.cpocod = 1


  open c_cts52m00_003 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_cts52m00_003 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes is not null  then
     let mr_data.fim =  lr_retorno.cpodes
  end if


#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_carga_full()
#========================================================================

define lr_param record
	dia  integer,
  mes  integer,
  ano  integer,
  data char(08)
end record


initialize mr_data.*, lr_param.* to null


  call cts52m00_recupera_data_inicio()

  call cts52m00_recupera_data_fim()

  if mr_data.inicio is null or
  	 mr_data.fim    is null then
  	  let m_mensagem = "Datas Invalidas!"
  	  call errorlog(m_mensagem);
  	  display m_mensagem
  	  return false
  end if

  display 'Inicio: ',mr_data.inicio
  display 'Fim: ',mr_data.fim

  if mr_data.fim	< mr_data.inicio then
  	  let m_mensagem = "Data Final Maior Que a Inicial"
      call errorlog(m_mensagem);
      display m_mensagem
      return false
  end if

  let lr_param.dia = day(mr_data.inicio)
  let lr_param.mes = month(mr_data.inicio)
  let lr_param.ano = year(mr_data.inicio)

  let lr_param.data = lr_param.dia using "&&", lr_param.mes using "&&", lr_param.ano using "&&&&"

  let m_arquivo  = "naoIndexadosItau_", lr_param.data, ".xls"

  start report cts52m00_report to m_arquivo

  call cts52m00_recupera_processar_full()
  while mr_data.inicio <=  mr_data.fim

     call cts52m00_carrega_endereco_full()

     let mr_data.inicio = mr_data.inicio + 1 units day

     call cts52m00_atualiza_data()

  end while

  finish report cts52m00_report

  call cts52m00_exibe_dados_totais()

  call cts52m00_atualiza_data()

  return true
#========================================================================
end function
#========================================================================


#========================================================================
function cts52m00_exibe_dados_totais()
#========================================================================

   let mr_param.hour_end = current
   let mr_param.hour_avg = mr_param.hour_end - mr_param.hour_sta
   let mr_param.hour_sta = mr_param.hour_end
   display " "
   display "-----------------------------------------------------------"
   display " DADOS TOTAIS "
   display "-----------------------------------------------------------"
   display " "
   display " TOTAIS LIDOS APOLICE................: ", mr_total.lidos
   display " TOTAIS ENCONTRADOS NO MAPA..........: ", mr_total.mapas
   display " TOTAIS GRAVADOS NO ENDERECO.........: ", mr_total.gravados
   display " TOTAIS JA EXISTENTES................: ", mr_total.ja_existentes
   display " TOTAIS DESPREZADOS..................: ", mr_total.desprezados
   display " TEMPO DE PROCESSAMENTO ATE O MOMENTO: ", mr_param.hour_avg
   let m_mensagem = "-----------------------------------------------------------"
   call errorlog(m_mensagem)
   let m_mensagem = " DADOS TOTAIS "
   call errorlog(m_mensagem)
   let m_mensagem = "-----------------------------------------------------------"
   call errorlog(m_mensagem)
   let m_mensagem = " TOTAIS LIDOS APOLICE................: ", mr_total.lidos
   call errorlog(m_mensagem)
   let m_mensagem = " TOTAIS ENCONTRADOS NO MAPA..........: ", mr_total.mapas
   call errorlog(m_mensagem)
   let m_mensagem = " TOTAIS GRAVADOS NO ENDERECO.........: ", mr_total.gravados
   call errorlog(m_mensagem)
   let m_mensagem = " TOTAIS JA EXISTENTES................: ", mr_total.ja_existentes
   call errorlog(m_mensagem)
   let m_mensagem = " TOTAIS DESPREZADOS..................: ", mr_total.desprezados
   call errorlog(m_mensagem)
   let m_mensagem = " TEMPO DE PROCESSAMENTO ATE O MOMENTO: ", mr_param.hour_avg
   call errorlog(m_mensagem)
   let m_mensagem = "-----------------------------------------------------------"
   call errorlog(m_mensagem)
#========================================================================
end function
#========================================================================

#========================================================================
function cts52m00_dispara_email()
#========================================================================
define lr_mail      record
       de           char(500)   # De
      ,para         char(5000)  # Para
      ,cc           char(500)   # cc
      ,cco          char(500)   # cco
      ,assunto      char(500)   # Assunto do e-mail
      ,mensagem     char(32766) # Nome do Anexo
      ,id_remetente char(20)
      ,tipo         char(4)     #
  end  record

define l_erro  smallint

define msg_erro char(500)

initialize lr_mail.* to null

    let lr_mail.de      = "ct24hs.email@portoseguro.com.br"
    let lr_mail.para    = cts52m00_recupera_email()
    let lr_mail.cc      = ""
    let lr_mail.cco     = ""
    let lr_mail.assunto = "DADOS PROCESSADOS CARGA ENDERECO ITAU"
    let lr_mail.mensagem  = cts52m00_monta_mensagem()
    let lr_mail.id_remetente = "CT24HS"
    let lr_mail.tipo = "html"

    #-----------------------------------------------
    # Dispara o E-mail
    #-----------------------------------------------

     call figrc009_attach_file(m_arquivo)

     call figrc009_mail_send1 (lr_mail.*)
     returning l_erro
              ,msg_erro

#========================================================================
end function
#========================================================================
#========================================================================
 function cts52m00_recupera_email()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes,
	email   char(32766)            ,
	flag    smallint
end record

initialize lr_retorno.* to null

let lr_retorno.flag = true

let lr_retorno.cponom = "bdata002_email"

  open c_cts52m00_005 using  lr_retorno.cponom

  foreach c_cts52m00_005 into lr_retorno.cpodes

    if lr_retorno.flag then
      let lr_retorno.email = lr_retorno.cpodes clipped
      let lr_retorno.flag  = false
    else
      let lr_retorno.email = lr_retorno.email clipped, ";", lr_retorno.cpodes clipped
    end if

  end foreach

  return lr_retorno.email

#========================================================================
end function
#========================================================================

#========================================================================
function cts52m00_monta_mensagem()
#========================================================================

define lr_retorno record
	mensagem  char(30000)
end record

initialize lr_retorno.* to null

          #-----------------------------------------------
          # Monta a Mensagem
          #-----------------------------------------------
          let lr_retorno.mensagem = " INICIO DO PROCESSAMENTO: "            , mr_param.ini, " - "   , mr_param.hour_ini , "<br><br>",
                                    " FINAL DO PROCESSAMENTO: "             , mr_param.fim, " - "   , mr_param.hour_fim , "<br><br>",
                                    " TOTAIS LIDOS APOLICE : "              , mr_total.lidos        , "<br>" ,
                                    " TOTAIS ENCONTRADOS NO MAPA :"         , mr_total.mapas        , "<br>" ,
                                    " TOTAIS GRAVADOS NO RELATORIO : "      , mr_total.gravados     , "<br>" ,
                                    " TOTAIS JA EXISTENTES : "              , mr_total.ja_existentes, "<br>" ,
                                    " TOTAIS DESPREZADOS : "                , mr_total.desprezados  , "<br>"
          return lr_retorno.mensagem
#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_valida_carga()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata002_full"
let lr_retorno.cpocod = 1


  open c_cts52m00_003 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_cts52m00_003 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes =  "S"  then
     return true
  end if


  return false


#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_atualiza_data()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata002_inicio"
let lr_retorno.cpocod = 1
let lr_retorno.cpodes = mr_data.inicio

   whenever error continue
   execute p_cts52m00_004 using lr_retorno.cpodes,
                                lr_retorno.cponom,
                                lr_retorno.cpocod
   whenever error continue

   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA ATUALIZACAO DA DATA! '
      call errorlog(m_mensagem);
      display m_mensagem
   end if


#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_inclui_endereco(lr_param)
#========================================================================

define lr_param record
	itaciacod       like datmitaapl.itaciacod ,
	itaramcod       like datmitaapl.itaramcod ,
	itaaplnum       like datmitaapl.itaaplnum ,
  aplseqnum       like datmitaapl.aplseqnum ,
	lclltt          like datmlcl.lclltt       ,
	lcllgt          like datmlcl.lcllgt       ,
	lgdtip          like datmlcl.lgdtip       ,
	lgdnom          like datmlcl.lgdnom       ,
	brrnom          like datmlcl.brrnom       ,
	lclbrrnom       like datmlcl.lclbrrnom    ,
	lgdcep          like datmlcl.lgdcep       ,
	lgdcepcmp       like datmlcl.lgdcepcmp    ,
	c24lclpdrcod    like datmlcl.c24lclpdrcod
end record


  whenever error continue
   execute p_cts52m00_001 using  lr_param.itaciacod
                                ,lr_param.itaramcod
                                ,lr_param.itaaplnum
                                ,lr_param.aplseqnum
                                ,lr_param.lgdtip
                                ,lr_param.lgdnom
                                ,lr_param.brrnom
                                ,lr_param.lclbrrnom
                                ,lr_param.lgdcep
                                ,lr_param.lgdcepcmp
                                ,lr_param.lclltt
                                ,lr_param.lcllgt
                                ,lr_param.c24lclpdrcod



   whenever error continue

   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA INCLUSAO DA ENDERECO! ', lr_param.itaaplnum, '-', lr_param.aplseqnum
      call errorlog(m_mensagem);
      display m_mensagem
   end if

   return sqlca.sqlcode

#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_atualiza_endereco(lr_param)
#========================================================================

define lr_param record
	itaciacod       like datmitaapl.itaciacod ,
	itaramcod       like datmitaapl.itaramcod ,
	itaaplnum       like datmitaapl.itaaplnum ,
  aplseqnum       like datmitaapl.aplseqnum ,
	lclltt          like datmlcl.lclltt       ,
	lcllgt          like datmlcl.lcllgt       ,
	lgdtip          like datmlcl.lgdtip       ,
	lgdnom          like datmlcl.lgdnom       ,
	brrnom          like datmlcl.brrnom       ,
	lclbrrnom       like datmlcl.lclbrrnom    ,
	lgdcep          like datmlcl.lgdcep       ,
	lgdcepcmp       like datmlcl.lgdcepcmp    ,
	c24lclpdrcod    like datmlcl.c24lclpdrcod
end record


  whenever error continue
   execute p_cts52m00_008 using  lr_param.lgdtip
                                ,lr_param.lgdnom
                                ,lr_param.brrnom
                                ,lr_param.lclbrrnom
                                ,lr_param.lgdcep
                                ,lr_param.lgdcepcmp
                                ,lr_param.lclltt
                                ,lr_param.lcllgt
                                ,lr_param.c24lclpdrcod
                                ,lr_param.itaciacod
                                ,lr_param.itaramcod
                                ,lr_param.itaaplnum
                                ,lr_param.aplseqnum



   whenever error continue

   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA ALTERACAO DA ENDERECO! ', lr_param.itaaplnum, '-', lr_param.aplseqnum
      call errorlog(m_mensagem);
      display m_mensagem
   end if

   return sqlca.sqlcode

#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_verifica_endereco(lr_param)
#========================================================================

define lr_param record
	itaciacod  like datmitaapl.itaciacod ,
	itaramcod  like datmitaapl.itaramcod ,
	itaaplnum  like datmitaapl.itaaplnum ,
  aplseqnum  like datmitaapl.aplseqnum
end record

define lr_retorno record
	cont smallint
end record

  let lr_retorno.cont = 0

  whenever error continue
     open c_cts52m00_007 using lr_param.itaciacod,
                               lr_param.itaramcod,
                               lr_param.itaaplnum,
                               lr_param.aplseqnum

     fetch c_cts52m00_007 into lr_retorno.cont
  whenever error stop

  close c_cts52m00_007

  if lr_retorno.cont > 0 then
  	return true
  else
  	return false
  end if


#========================================================================
end function
#========================================================================

#========================================================================
function cts52m00_retira_tipo_lougradouro(l_string)
#========================================================================

 define l_string          char(100)
 define l_j               smallint
 define l_i               smallint
 define l_tamanho         smallint
 define l_rua             char(100)
 define l_tipo_logradouro char(30)
 define l_count           smallint

 let l_i = 1
 let l_tamanho = 0
 let l_rua = ''
 let l_tipo_logradouro = ''

 #REMOVE ESPACOS DO INICIO DO LOGRADOURO
 let l_string = cts52m00_ltrim(l_string)

 let l_tamanho = length(l_string)


 for l_i = 1 to l_tamanho
     if l_string[l_i] = ' ' then
        let l_tipo_logradouro = l_string[1,l_i-1]

        whenever error continue
          open c_cts52m00_006 using l_tipo_logradouro
          fetch c_cts52m00_006 into l_count
        whenever error stop

        if l_count > 0 then
           let l_rua = l_string[l_i+1,l_tamanho]
        end if

        exit for
     end if
 end for
 close c_cts52m00_006

 let l_tamanho = length(l_tipo_logradouro)
 for l_j = 1 to l_tamanho
     if l_tipo_logradouro[l_j] = '.' then
        let l_tipo_logradouro[l_j] = ' '
     end if
 end for

 let l_tipo_logradouro = l_tipo_logradouro clipped

 if l_rua = ''  or
    l_rua = ' ' or
    l_rua is null then
    return ' ', l_string
 else
    return l_tipo_logradouro
         , l_rua

 end if

end function

#========================================================================
function cts52m00_ltrim(l_string)
#========================================================================

# RETINA ESPACOS DO INICIO DO TEXTO
 define l_string          char(100)

 while l_string[1] = ' '
    let l_string = l_string[2,99]
 end while

 return l_string

end function

#========================================================================
function cts52m00_retira_acentos(l_param)
#========================================================================
   define l_param char(100)
   define l_posi  smallint

   let l_posi = 1
   while l_posi <= 100
      case l_param[l_posi]
         when 'á' let l_param[l_posi] = 'a'
         when 'é' let l_param[l_posi] = 'e'
         when 'í' let l_param[l_posi] = 'i'
         when 'ó' let l_param[l_posi] = 'o'
         when 'ú' let l_param[l_posi] = 'u'
         when 'à' let l_param[l_posi] = 'a'
         when 'è' let l_param[l_posi] = 'e'
         when 'ì' let l_param[l_posi] = 'i'
         when 'ò' let l_param[l_posi] = 'o'
         when 'ù' let l_param[l_posi] = 'u'
         when 'â' let l_param[l_posi] = 'a'
         when 'ê' let l_param[l_posi] = 'e'
         when 'î' let l_param[l_posi] = 'i'
         when 'ô' let l_param[l_posi] = 'o'
         when 'û' let l_param[l_posi] = 'u'
         when 'ä' let l_param[l_posi] = 'a'
         when 'ë' let l_param[l_posi] = 'e'
         when 'ï' let l_param[l_posi] = 'i'
         when 'ö' let l_param[l_posi] = 'o'
         when 'ü' let l_param[l_posi] = 'u'
         when 'ã' let l_param[l_posi] = 'a'
         when 'õ' let l_param[l_posi] = 'o'
         when 'ñ' let l_param[l_posi] = 'n'
         when 'ç' let l_param[l_posi] = 'c'
         when 'Á' let l_param[l_posi] = 'A'
         when 'É' let l_param[l_posi] = 'E'
         when 'Í' let l_param[l_posi] = 'I'
         when 'Ó' let l_param[l_posi] = 'O'
         when 'Ú' let l_param[l_posi] = 'U'
         when 'À' let l_param[l_posi] = 'A'
         when 'È' let l_param[l_posi] = 'E'
         when 'Ì' let l_param[l_posi] = 'I'
         when 'Ò' let l_param[l_posi] = 'O'
         when 'Ù' let l_param[l_posi] = 'U'
         when 'Â' let l_param[l_posi] = 'A'
         when 'Ê' let l_param[l_posi] = 'E'
         when 'Î' let l_param[l_posi] = 'I'
         when 'Ô' let l_param[l_posi] = 'O'
         when 'Û' let l_param[l_posi] = 'U'
         when 'Ä' let l_param[l_posi] = 'A'
         when 'Ë' let l_param[l_posi] = 'E'
         when 'Ï' let l_param[l_posi] = 'I'
         when 'Ö' let l_param[l_posi] = 'O'
         when 'Ü' let l_param[l_posi] = 'U'
         when 'Ã' let l_param[l_posi] = 'A'
         when 'Õ' let l_param[l_posi] = 'O'
         when 'Ñ' let l_param[l_posi] = 'N'
         when 'Ç' let l_param[l_posi] = 'C'
         otherwise call cts52m00_retira_simbolos(l_param[l_posi])
                   returning l_param[l_posi]
      end case
      let l_posi = l_posi + 1
   end while

   return l_param clipped

#========================================================================
end function
#========================================================================

#========================================================================
function cts52m00_retira_simbolos(l_param)
#========================================================================

define l_param    char(100)
define l_pos_ini  smallint
define l_pos_fim  smallint

   let l_pos_ini = 128
   let l_pos_fim = 254

   while l_pos_ini <= l_pos_fim

   	  if l_param = ascii(l_pos_ini) then
   	      initialize l_param to null
   	  end if

   	  let l_pos_ini = l_pos_ini + 1

   end while

   return l_param
end function

#========================================================================
 function cts52m00_carrega_endereco_diario()
#========================================================================

define lr_retorno record
	erro            smallint                  ,
	lclltt          like datmlcl.lclltt       ,
	lcllgt          like datmlcl.lcllgt       ,
	lgdtip          like datmlcl.lgdtip       ,
	lgdnom          like datmlcl.lgdnom       ,
	brrnom          like datmlcl.brrnom       ,
	lclbrrnom       like datmlcl.lclbrrnom    ,
	lgdcep          like datmlcl.lgdcep       ,
	lgdcepcmp       like datmlcl.lgdcepcmp    ,
	c24lclpdrcod    like datmlcl.c24lclpdrcod
end record

define lr_mapa record
	lgdtip    like datmlcl.lgdtip ,
	lgdnom    like datmlcl.lgdnom
end record

define l_data date
define l_hora datetime hour to second
define l_continue smallint
define l_rowid    integer

initialize mr_processo.*, lr_retorno.*, lr_mapa.* to null

let l_data = null
let l_hora = null

    call  cts52m00_recupera_arquivo_atual()
    call  cts52m00_recupera_arquivo_ultimo()

     if mr_param.itaasiarqvrsnum_ultimo <> mr_param.itaasiarqvrsnum then
     	  let mr_param.itaasiarqvrsnum_ultimo = mr_param.itaasiarqvrsnum_ultimo + 1
     end if
     call cts52m00_recupera_processar_diario()

     while mr_param.itaasiarqvrsnum_ultimo <=  mr_param.itaasiarqvrsnum


         let m_arquivo  = "naoIndexadosItau_", mr_param.itaasiarqvrsnum_ultimo using "&&&&&&&&&&", ".xls"

         start report cts52m00_report to m_arquivo


         #--------------------------------------------------------
         # Recupera os Dados da Apolice Itau
         #--------------------------------------------------------

         open c_cts52m00_010 using mr_param.itaasiarqvrsnum_ultimo
                                  ,m_rowid

         foreach c_cts52m00_010 into mr_processo.itaciacod
         	                   , mr_processo.itaramcod
         	                   , mr_processo.itaaplnum
         	                   , mr_processo.aplseqnum
         	                   , mr_processo.seglgdnom
         	                   , mr_processo.seglgdnum
         	                   , mr_processo.segbrrnom
         	                   , mr_processo.segcidnom
         	                   , mr_processo.segufdsgl
          	                   , mr_processo.segcepnum
                                   , mr_processo.segcepcmpnum
                                   , l_rowid



               if m_cont = m_contador then
                  call cts52m00_exibe_dados_totais()
                  let m_cont = 0
                  #CT324042 - Inicio
                  let l_continue = true
                  let l_continue = cts52m00_verifica_janela_processamento(l_rowid)
                  if l_continue = false then
                     return
                  end if
                  #CT324042 - Fim
               end if

               let m_cont = m_cont + 1

               #--------------------------------------------------------
               # Recupera Logradouro da Tabela de Mapas
               #--------------------------------------------------------

               call cts52m00_recupera_endereco_mapa(mr_processo.segcepnum   ,
                                                    mr_processo.segcepcmpnum)
               returning lr_mapa.lgdtip,
                         lr_mapa.lgdnom


               if lr_mapa.lgdtip is null or
                  lr_mapa.lgdnom is null then

                  call cts52m00_retira_tipo_lougradouro(mr_processo.seglgdnom)
                  returning mr_processo.lgdtip
                           ,mr_processo.seglgdnom
                  let mr_total.flag_mapa     = "Nao"
               else

                  let mr_total.mapas = mr_total.mapas + 1
               	  let mr_processo.lgdtip    = lr_mapa.lgdtip
               	  let mr_processo.seglgdnom = lr_mapa.lgdnom
               	  let mr_total.flag_mapa     = "Sim"

               end if


               # Tipo de Lougradouro
               call cts52m00_retira_acentos(mr_processo.lgdtip)
               returning mr_processo.lgdtip

               let mr_processo.lgdtip = upshift(mr_processo.lgdtip)

               # Lougradouro
               call cts52m00_retira_acentos(mr_processo.seglgdnom)
               returning mr_processo.seglgdnom

               let mr_processo.seglgdnom = upshift(mr_processo.seglgdnom)

               # Bairro
               call cts52m00_retira_acentos(mr_processo.segbrrnom)
               returning mr_processo.segbrrnom

               let mr_processo.segbrrnom = upshift(mr_processo.segbrrnom)

               # Cidade
               call cts52m00_retira_acentos( mr_processo.segcidnom)
               returning  mr_processo.segcidnom

   	           let  mr_processo.segcidnom = upshift( mr_processo.segcidnom)


         	    #--------------------------------------------------------
         	    # Chama a Roteirizacao Automatica
         	    #--------------------------------------------------------

         	    call ctx25g05_pesq_auto(mr_processo.lgdtip      ,
                                      mr_processo.seglgdnom   ,
                                      mr_processo.seglgdnum   ,
                                      mr_processo.segbrrnom   ,
                                      mr_processo.segbrrnom   ,
                                      mr_processo.segufdsgl   ,
                                      mr_processo.segcidnom   )

               returning lr_retorno.erro        ,
                         lr_retorno.lclltt      ,
                         lr_retorno.lcllgt      ,
                         lr_retorno.lgdtip      ,
                         lr_retorno.lgdnom      ,
                         lr_retorno.brrnom      ,
                         lr_retorno.lclbrrnom   ,
                         lr_retorno.lgdcep      ,
                         lr_retorno.c24lclpdrcod

         	     let mr_total.lidos  = mr_total.lidos + 1

         	     if lr_retorno.erro   <> 0    or
         	     	  lr_retorno.lcllgt is null or
         	     	  lr_retorno.lclltt is null then

         	     	  output to report cts52m00_report()

         	     	  let mr_total.desprezados  = mr_total.desprezados + 1
         	        continue foreach
         	     end if

         	     if lr_retorno.lgdtip is null or
         	     	  lr_retorno.lgdtip = ""    then
         	     	  	let lr_retorno.lgdtip = mr_processo.lgdtip
         	     end if

         	     if lr_retorno.lgdnom is null or
         	     	  lr_retorno.lgdnom = ""    then
         	     	  	let lr_retorno.lgdnom = mr_processo.seglgdnom
         	     end if

         	     if lr_retorno.brrnom is null or
         	     	  lr_retorno.brrnom = ""    then
         	     	  	let lr_retorno.brrnom = mr_processo.segbrrnom
         	     end if

         	     if lr_retorno.lclbrrnom is null or
         	     	  lr_retorno.lclbrrnom = ""    then
         	     	  	let lr_retorno.lclbrrnom = mr_processo.segbrrnom
         	     end if


         	     if not cts52m00_verifica_endereco(mr_processo.itaciacod,
         	                                       mr_processo.itaramcod,
         	                                       mr_processo.itaaplnum,
         	                                       mr_processo.aplseqnum) then



         	         #--------------------------------------------------------
         	         # Inclui o Endereco Indexado
         	         #--------------------------------------------------------

         	         call cts52m00_inclui_endereco(mr_processo.itaciacod
         	                                      ,mr_processo.itaramcod
         	                                      ,mr_processo.itaaplnum
         	                                      ,mr_processo.aplseqnum
         	                                      ,lr_retorno.lclltt
         	                                      ,lr_retorno.lcllgt
         	                                      ,lr_retorno.lgdtip
         	                                      ,lr_retorno.lgdnom
         	                                      ,lr_retorno.brrnom
         	                                      ,lr_retorno.lclbrrnom
         	                                      ,lr_retorno.lgdcep
                                                ,lr_retorno.lgdcepcmp
         	                                      ,lr_retorno.c24lclpdrcod)
         	          returning lr_retorno.erro

         	          if lr_retorno.erro = 0 then
         	             let mr_total.gravados  = mr_total.gravados + 1
         	          else
         	          	 let mr_total.desprezados  = mr_total.desprezados + 1
         	          end if
               else
               	 let mr_total.ja_existentes  = mr_total.ja_existentes + 1
               end if


         end foreach


         finish report cts52m00_report

         call cts52m00_atualiza_arquivo()

         call cts52m00_exibe_dados_totais()

         call cts52m00_exibe_final()

         call cts52m00_dispara_email()

         let mr_param.itaasiarqvrsnum_ultimo = mr_param.itaasiarqvrsnum_ultimo + 1

     end while





#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_recupera_arquivo_atual()
#========================================================================

  open c_cts52m00_009
  whenever error continue
  fetch c_cts52m00_009 into mr_param.itaasiarqvrsnum
  whenever error stop


#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_recupera_arquivo_ultimo()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata002_ultimo"
let lr_retorno.cpocod = 1


  open c_cts52m00_003 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_cts52m00_003 into mr_param.itaasiarqvrsnum_ultimo
  whenever error stop


#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_atualiza_arquivo()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

   initialize lr_retorno.* to null

   let lr_retorno.cponom = "bdata002_ultimo"
   let lr_retorno.cpocod = 1
   let lr_retorno.cpodes = mr_param.itaasiarqvrsnum_ultimo

   whenever error continue
   execute p_cts52m00_004 using lr_retorno.cpodes,
                                lr_retorno.cponom,
                                lr_retorno.cpocod
   whenever error continue

   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA ATUALIZACAO DO ARQUIVO! '
      call errorlog(m_mensagem);
      display m_mensagem
   end if

   #Atualiza rowid para zero CT324042
   initialize lr_retorno.* to null
   let lr_retorno.cponom = "bdata002_ult_rowid"
   let lr_retorno.cpocod = 1
   let lr_retorno.cpodes = 0
   whenever error continue
   execute p_cts52m00_004 using lr_retorno.cpodes,
                                lr_retorno.cponom,
                                lr_retorno.cpocod
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA ATUALIZACAO DO ROWID! '
      call errorlog(m_mensagem);
      display m_mensagem
   end if
   let m_rowid = 0

#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_acessa_endereco_itau(lr_param)
#========================================================================

define lr_param record
	ciaempcod  like datmligacao.ciaempcod,
	itaciacod  like datmitaapl.itaciacod ,
	itaramcod  like datmitaapl.itaramcod ,
	itaaplnum  like datmitaapl.itaaplnum ,
	aplseqnum  like datmitaapl.aplseqnum
end record

  if m_cts52m00_prep = false or
     m_cts52m00_prep is null then
       call cts52m00_prepare()
  end if

  if lr_param.ciaempcod = 84 then


      if cts52m00_verifica_endereco(lr_param.itaciacod,
                                    lr_param.itaramcod,
                                    lr_param.itaaplnum,
                                    lr_param.aplseqnum) then

         return true

      end if

  end if

  return false

#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_recupera_endereco_itau(lr_param)
#========================================================================

define lr_param record
	itaciacod  like datmitaapl.itaciacod ,
	itaramcod  like datmitaapl.itaramcod ,
	itaaplnum  like datmitaapl.itaaplnum ,
	aplseqnum  like datmitaapl.aplseqnum
end record

define lr_retorno record
	lclltt          like datmlcl.lclltt       ,
	lcllgt          like datmlcl.lcllgt       ,
	lgdtip          like datmlcl.lgdtip       ,
	lgdnom          like datmlcl.lgdnom       ,
	brrnom          like datmlcl.brrnom       ,
	lclbrrnom       like datmlcl.lclbrrnom    ,
	lgdcep          like datmlcl.lgdcep       ,
	lgdcepcmp       like datmlcl.lgdcepcmp    ,
	c24lclpdrcod    like datmlcl.c24lclpdrcod
end record

   if m_cts52m00_prep = false or
      m_cts52m00_prep is null then
        call cts52m00_prepare()
   end if

   open c_cts52m00_011 using lr_param.itaciacod,
                             lr_param.itaramcod,
                             lr_param.itaaplnum,
                             lr_param.aplseqnum

   whenever error continue
   fetch c_cts52m00_011 into lr_retorno.lgdtip       ,
                             lr_retorno.lgdnom       ,
                             lr_retorno.brrnom       ,
                             lr_retorno.lclbrrnom    ,
                             lr_retorno.lgdcep       ,
                             lr_retorno.lclltt       ,
                             lr_retorno.lcllgt       ,
                             lr_retorno.c24lclpdrcod
   whenever error stop

   close c_cts52m00_011

   return lr_retorno.lclltt        ,
          lr_retorno.lcllgt        ,
          lr_retorno.lgdtip        ,
          lr_retorno.lgdnom        ,
          lr_retorno.brrnom        ,
          lr_retorno.lclbrrnom     ,
          lr_retorno.lgdcep        ,
          lr_retorno.c24lclpdrcod

#========================================================================
end function
#========================================================================

#========================================================================
 report cts52m00_report()
#========================================================================

 output

  report to printer

  page      length  66
  left      margin  00
  top       margin  00
  bottom    margin  00

   format

   first page header

        print column 001, "Codigo da Companhia"              , ascii(09)
                        , "Ramo"                             , ascii(09)
                        , "Apolice"                          , ascii(09)
                        , "Sequencia"                        , ascii(09)
                        , "Tipo de Logradouro"               , ascii(09)
                        , "Logradouro"                       , ascii(09)
                        , "Numero"                           , ascii(09)
                        , "Bairro"                           , ascii(09)
                        , "Cidade"                           , ascii(09)
                        , "UF"                               , ascii(09)
                        , "CEP"                              , ascii(09)
                        , "Encontrado no Mapa"               , ascii(09)


        skip 1 line


   on every row



        print column 001    , mr_processo.itaciacod   using "<<&&"                                    ,ascii(9)
                            , mr_processo.itaramcod   using "<<&&&"                                   ,ascii(9)
                            , mr_processo.itaaplnum   using "<<&&&&&&&"                               ,ascii(9)
                            , mr_processo.aplseqnum   using "<<&&"                                    ,ascii(9)
                            , mr_processo.lgdtip      clipped                                         ,ascii(9)
                            , mr_processo.seglgdnom   clipped                                         ,ascii(9)
                            , mr_processo.seglgdnum   clipped                                         ,ascii(9)
                            , mr_processo.segbrrnom   clipped                                         ,ascii(9)
                            , mr_processo.segcidnom   clipped                                         ,ascii(9)
                            , mr_processo.segufdsgl   clipped                                         ,ascii(9)
                            , mr_processo.segcepnum   using "&&&&&", "-", mr_processo.segcepcmpnum  using "&&&" ,ascii(9)
                            , mr_total.flag_mapa      clipped                                         ,ascii(9)


#========================================================================
end report
#========================================================================

#========================================================================
 function cts52m00_grava_endereco_itau(lr_param)
#========================================================================

define lr_param record
	itaciacod     like datmitaapl.itaciacod ,
	itaramcod     like datmitaapl.itaramcod ,
	itaaplnum     like datmitaapl.itaaplnum ,
	aplseqnum     like datmitaapl.aplseqnum ,
	lclltt        like datmlcl.lclltt       ,
	lcllgt        like datmlcl.lcllgt       ,
	lgdtip        like datmlcl.lgdtip       ,
	lgdnom        like datmlcl.lgdnom       ,
	brrnom        like datmlcl.brrnom       ,
	lclbrrnom     like datmlcl.lclbrrnom    ,
	lgdcep        like datmlcl.lgdcep       ,
	lgdcepcmp     like datmlcl.lgdcepcmp    ,
	c24lclpdrcod  like datmlcl.c24lclpdrcod
end record

define lr_retorno record
	erro integer
end record

initialize lr_retorno.* to null

  if m_cts52m00_prep = false or
     m_cts52m00_prep is null then
       call cts52m00_prepare()
  end if


  if lr_param.itaciacod is not null and
     lr_param.itaramcod is not null and
     lr_param.itaaplnum is not null and
     lr_param.aplseqnum is not null then

     if not cts52m00_verifica_endereco(lr_param.itaciacod,
                                       lr_param.itaramcod,
                                       lr_param.itaaplnum,
                                       lr_param.aplseqnum) then


         if g_indexado.endnum1 = g_indexado.endnum2 and
            g_indexado.endcid1 = g_indexado.endcid2 then

            #--------------------------------------------------------
            # Inclui o Endereco Indexado
            #--------------------------------------------------------

            call cts52m00_inclui_endereco(lr_param.itaciacod
                                         ,lr_param.itaramcod
                                         ,lr_param.itaaplnum
                                         ,lr_param.aplseqnum
                                         ,lr_param.lclltt
                                         ,lr_param.lcllgt
                                         ,lr_param.lgdtip
                                         ,lr_param.lgdnom
                                         ,lr_param.brrnom
                                         ,lr_param.lclbrrnom
                                         ,lr_param.lgdcep
                                         ,lr_param.lgdcepcmp
                                         ,lr_param.c24lclpdrcod)
            returning lr_retorno.erro

         end if


     end if
  end if

#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_recupera_endereco_mapa(lr_param)
#========================================================================

define lr_param record
	segcepnum      like datmitaapl.segcepnum  ,
  segcepcmpnum	 like datmitaapl.segcepcmpnum
end record

define lr_retorno record
	lgdtip  like datkmpalgd.lgdtip    ,
	lgdnom  like datkmpalgd.lgdnom
end record

initialize lr_retorno.* to null

  if m_cts52m00_prep = false or
     m_cts52m00_prep is null then
       call cts52m00_prepare()
  end if


  open c_cts52m00_012 using lr_param.segcepnum    ,
                            lr_param.segcepcmpnum

  whenever error continue
  fetch c_cts52m00_012 into lr_retorno.lgdtip ,
                            lr_retorno.lgdnom

  whenever error stop

  close c_cts52m00_012


  return lr_retorno.lgdtip,
    	   lr_retorno.lgdnom


#========================================================================
end function
#========================================================================

#========================================================================
 function cts52m00_recupera_contador()
#========================================================================

define lr_retorno record
	cponom  like datkdominio.cponom,
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

  initialize lr_retorno.* to null

  let lr_retorno.cponom = "bdata002_cont"
  let lr_retorno.cpocod = 1


  open c_cts52m00_003 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_cts52m00_003 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes is not null  then
     let  m_contador =  lr_retorno.cpodes
  else
  	 let  m_contador =  1000
  end if

  #CT324042 - Inicio
  initialize lr_retorno.* to null
  let lr_retorno.cponom = "bdata002_ult_rowid"
  let lr_retorno.cpocod = 1
  open c_cts52m00_003 using  lr_retorno.cponom,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_cts52m00_003 into lr_retorno.cpodes
  whenever error stop
  if sqlca.sqlcode = 0 then
     let m_rowid =  lr_retorno.cpodes
  else
     let m_rowid = 0
     whenever error continue
     insert into datkdominio
           (cponom,
            cpocod,
            cpodes,
            atlult)
        values ("bdata002_ult_rowid",
                1,
                0,
                today)
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let m_mensagem = 'ERRO(',sqlca.sqlcode,') NO INSERT DO ROWID! '
        call errorlog(m_mensagem);
        display m_mensagem
     end if
  end if
  #CT324042 - Fim

#========================================================================
end function
#========================================================================
#========================================================================
function cts52m00_exibe_total_processar()
#========================================================================
   display " "
   display "-----------------------------------------------------------"
   display "TOTAL A SEREM PROCESSADOS..: ", mr_total.processados
   display "-----------------------------------------------------------"
   display " "
   let m_mensagem = "-----------------------------------------------------------"
   call errorlog(m_mensagem)
   let m_mensagem = "TOTAL A SEREM PROCESSADOS..: ", mr_total.processados
   call errorlog(m_mensagem)
   let m_mensagem = "-----------------------------------------------------------"
   call errorlog(m_mensagem)
#========================================================================
end function
#========================================================================
#========================================================================
 function cts52m00_recupera_processar_diario()
#========================================================================
  let mr_total.processados = 0
  whenever error continue
     open c_cts52m00_013 using mr_param.itaasiarqvrsnum_ultimo,
                               mr_param.itaasiarqvrsnum
     fetch c_cts52m00_013 into mr_total.processados
  whenever error stop
  close c_cts52m00_013
  call cts52m00_exibe_total_processar()
#========================================================================
end function
#========================================================================
#========================================================================
 function cts52m00_recupera_processar_full()
#========================================================================
  let mr_total.processados = 0
  whenever error continue
     open c_cts52m00_014 using mr_data.inicio,
                               mr_data.fim
     fetch c_cts52m00_014 into mr_total.processados
  whenever error stop
  close c_cts52m00_014
  call cts52m00_exibe_total_processar()
#========================================================================
end function
#========================================================================
#-------------------------------------------------------------------#
 function cts52m00_verifica_janela_processamento(l_rowid)
#-------------------------------------------------------------------#
 define l_rowid       integer
 define l_continue    smallint,
        l_hora        datetime hour to minute,
        l_dia         integer
 define lr_retorno record
 	cponom  like datkdominio.cponom,
 	cpocod  like datkdominio.cpocod,
 	cpodes  like datkdominio.cpodes
 end record
 let l_continue =  true
 let l_hora     = current
 if l_hora >= '07:00' and
    l_hora <= '08:00' then
    let l_continue = false
 end if
 display 'l_hora: ', l_hora
 display 'l_continue: ', l_continue
 if l_continue = false then
    initialize l_dia to null
    let l_dia = weekday(today)
    display 'l_dia: ', l_dia
    if l_dia = 6 or
       l_dia = 0 then #Sabado ou Domingo
       let l_continue = true
    else
       initialize lr_retorno.* to null
       let lr_retorno.cpodes = l_rowid
       let lr_retorno.cponom = "bdata002_ult_rowid"
       let lr_retorno.cpocod = 1
       whenever error continue
       execute p_cts52m00_004 using lr_retorno.cpodes,
                                    lr_retorno.cponom,
                                    lr_retorno.cpocod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA ATUALIZACAO DO ROWID! '
          call errorlog(m_mensagem);
          display m_mensagem
       end if
    end if
 end if
 return l_continue
 end function
