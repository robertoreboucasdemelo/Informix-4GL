#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SEGURO FAZ                                           #
# MODULO.........: BDBSR025                                                   #
# ANALISTA RESP..: CELSO ISSAMU YAMAHAKI                                      #
# PSI/OSF........: PSI-2014-24273/EV                                          #
#                  RELATORIO DE VENDA COM PRESTADOR NO LOCAL.                 #
# ........................................................................... #
# DESENVOLVIMENTO: JOSIANE APARECIDA DE ALMEIDA                               #
# LIBERACAO......: 29/10/2014                                                 #
#-----------------------------------------------------------------------------#
#                         * * * Alteracoes * * *                              #
#   Data     Autor Fabrica     Origem    Alteracao                            #
# ---------- --------------- -------------- ----------------------------------#
# 21/03/2016 INTERA,MarcosMP SPR-2016-03565 Processamento Diario e Mensal.    #
#-----------------------------------------------------------------------------#
database porto

define m_path      char(300)
define mr_psf record
       cgccpfnum         like datmatd6523.cgccpfnum
      ,cgcord            like datmatd6523.cgcord
      ,cgccpfdig         like datmatd6523.cgccpfdig
      ,semdoctocgccpfnum like datmatd6523.semdoctocgccpfnum
      ,semdoctocgcord    like datmatd6523.semdoctocgcord
      ,semdoctocgccpfdig like datmatd6523.semdoctocgccpfdig
      ,atdsrvnum         like datmservico.atdsrvnum
      ,atdsrvano         like datmservico.atdsrvano
      ,atddat            like datmservico.atddat
      ,corsus            like datmservico.corsus
      ,cornom            like datmservico.cornom
      ,nom               like datmservico.nom
      ,lignum            like datratdlig.lignum
      ,atdnum            like datratdlig.atdnum
      ,c24pbmcod         like datkpbm.c24pbmcod
      ,c24pbmdes         like datkpbm.c24pbmdes
      ,socntzcod         like datksocntz.socntzcod
      ,socntzdes         like datksocntz.socntzdes
      ,cpf               char(25)
      ,cpf2              char(25)
      ,prslocflg         like datmservico.prslocflg
      ,atdsrvseq         like datmservico.atdsrvseq
      ,srrcoddig         like datmsrvacp.srrcoddig
      ,pstcoddig         like datmsrvacp.pstcoddig
      ,ufdcod            like datmlcl.ufdcod
      ,cidnom            like datmlcl.cidnom
      ,nomgrr            like dpaksocor.nomgrr
      ,srrnom            like datksrr.srrnom
      ,diadasemana       char(18)
      ,ehferiado         char(03)
      ,diautil           date
      ,atdetpcod         like datketapa.atdetpcod
      ,atdetpdes         like datketapa.atdetpdes
      ,asitipcod         like datkasitip.asitipcod
      ,asitipdes         like datkasitip.asitipdes
      ,atdetpdat         like datmsrvacp.atdetpdat
      ,atdetphor         like datmsrvacp.atdetphor
      ,socopgitmvlr      like dbsmopgitm.socopgitmvlr
      ,atdhor            like datmservico.atdhor
      ,c24astcod         like datmligacao.c24astcod
      ,aux               char(50)
end record

define l_data_atual      date,
       l_hora_atual      datetime hour to minute,
       l_data_inicio     date,
       l_data_fim        date

define l_path char(300),
       l_sql  char(3000)

define m_proc            char(01)  #=> SPR-2016-03565
       
#-----------------------------------------#
main
#-----------------------------------------#
   define l_dtaux        char(10)  #=> SPR-2016-03565

    # -> ABRE O BANCO UTILIZADO PELA CENTRAL 24 HORAS
    call fun_dba_abre_banco("CT24HS")
   
    #=> SPR-2016-03565: OBTEM O PROCESSAMENTO ('D'IARIO / 'M'ENSAL)
    let m_proc = arg_val(1)
   
    # ---> OBTER A DATA E HORA DO BANCO
    call cts40g03_data_hora_banco(2)
         returning l_data_atual,
                   l_hora_atual

    # ---> DATA DE EXTRACAO DAS INFORMACOES
    if m_proc = "D" then                   #=> SPR-2016-03565: DIA ANTERIOR
       let l_data_inicio = l_data_atual - 1 units day
       let l_data_fim =    l_data_atual - 1 units day
    else
       if m_proc = "M" then                #=> SPR-2016-03565: MES ANTERIOR
          let l_dtaux = l_data_atual
          let l_dtaux = "01", l_dtaux[3,10]
          let l_data_inicio = l_dtaux
          let l_data_fim =    l_data_inicio - 1 units day
          let l_data_inicio = l_data_inicio - 1 units month
       else
          display "TIPO DE PROCESSAMENTO INVALIDO (", m_proc, ")!!!"
          exit program(1)
       end if
    end if
    
    call bdbsr025_busca_path()
   
    call bdbsr025_prepare()
   
    set isolation to dirty read
   
    call bdbsr025()

end main


#-----------------------------------------#
function bdbsr025_busca_path()
#-----------------------------------------#
    define l_dia char(02),
           l_mes char(02),
           l_ano char(04)
   
    # ---> INICIALIZACAO DAS VARIAVEIS
     let m_path = null
     let l_dia  = null
     let l_mes  = null
     let l_ano  = null
   
    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("SAPS","LOG")
   
    if m_path is null then
       let m_path = "."
    end if
   
    let m_path = m_path clipped,"/bdbsr025.log"
   
    call startlog(m_path)
   
    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("SAPS", "RELATO")
   
    if m_path is null then
       let m_path = "."
    end if
    
    let l_dia = day(l_data_inicio)
    let l_mes = month(l_data_inicio)clipped
    let l_ano = year(l_data_inicio)
   
    if l_mes < 10 then 
        let l_mes = "0",l_mes
    end if
     
    let m_path = m_path clipped , '/' 
    
    let m_path = m_path clipped, l_dia clipped, l_mes clipped , l_ano ,"BDBSR025.xls"
   
    display 'm_path: ', m_path clipped

end function


#-----------------------------------------#
function bdbsr025_prepare()
#-----------------------------------------#
    let l_sql = 'select srv.atdsrvnum, srv.atdsrvano, srv.atddat, srv.atdhor '
              ,'      ,srv.corsus   , srv.cornom, srv.nom          '
              ,'      ,sre.socntzcod, srv.prslocflg, srv.atdsrvseq '
              ,'      ,srv.asitipcod                '
              ,'  from datmservico srv ,            '
              ,'       outer datmsrvre sre          '
              ,' where srv.atdsrvnum = sre.atdsrvnum'
              ,'   and srv.atdsrvano = sre.atdsrvano'
              ,'   and atddat between ? and ?       '
              ,'   and ciaempcod = 43               '
   prepare p_psf00 from l_sql
   declare c_psf00 cursor for p_psf00


   let l_sql = 'select min(lignum) '
              ,'  from datmligacao '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '
   prepare p_psf01 from l_sql
   declare c_psf01 cursor for p_psf01

   let l_sql = 'select cgccpfnum         '
              ,'      ,cgcord            '
              ,'      ,cgccpfdig         '
              ,'      ,semdoctocgccpfnum '
              ,'      ,semdoctocgcord    '
              ,'      ,semdoctocgccpfdig '
              ,'  from datmatd6523       '
              ,' where atdnum = ?        '
   prepare p_psf02 from l_sql
   declare c_psf02 cursor for p_psf02

   let l_sql = 'select atdnum     '
              ,'  from datratdlig '
              ,' where lignum = ? '
   prepare p_psf03 from l_sql
   declare c_psf03 cursor for p_psf03

   let l_sql = 'select c24astcod   '
              ,'  from datmligacao '
              ,' where lignum = ?  '
   prepare p_psf04 from l_sql
   declare c_psf04 cursor for p_psf04

   let l_sql = 'select socntzdes     '
              ,'  from datksocntz    '
              ,' where socntzcod = ? '
   prepare p_psf05 from l_sql
   declare c_psf05 cursor for p_psf05


   let l_sql = 'select srrcoddig, pstcoddig           '
              ,'      ,atdetpdat, atdetphor, atdetpcod'
              ,'  from datmsrvacp    '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '
              ,'   and atdsrvseq = ? '
   prepare p_psf07 from l_sql
   declare c_psf07 cursor for p_psf07

   let l_sql = 'select ufdcod, cidnom '
              ,'  from datmlcl        '
              ,' where atdsrvnum = ?  '
              ,'   and atdsrvano = ?  '
              ,'   and c24endtip = 1  '
   prepare p_psf08 from l_sql
   declare c_psf08 cursor for p_psf08	
   
   
   let l_sql = 'select srrnom        ' 
              ,'  from datksrr       '
              ,' where srrcoddig = ? '

   prepare p_psf09 from l_sql
   declare c_psf09 cursor for p_psf09	
   
   let l_sql = 'select nomgrr       '
              ,'  from dpaksocor    '
              ,' where pstcoddig =? '
              
   prepare p_psf10 from l_sql
   declare c_psf10 cursor for p_psf10	
   
   let l_sql = 'select asitipdes     '
              ,'  from datkasitip    '
              ,' where asitipcod = ? '
              
   prepare p_psf11 from l_sql
   declare c_psf11 cursor for p_psf11
   
   let l_sql = 'select atdetpdes     '
              ,'  from datketapa     '
              ,' where atdetpcod = ? '
              
   prepare p_psf12 from l_sql
   declare c_psf12 cursor for p_psf12
   
   let l_sql = 'select socopgitmvlr '
              ,'  from dbsmopgitm   '
              ,' where atdsrvnum = ?'
              ,'   and atdsrvano = ?'

   prepare p_psf13 from l_sql
   declare c_psf13 cursor for p_psf13
   
   let l_sql = 'select 1 from datkassunto  '
              ,'  where c24astcod = ?      '
              ,"    and c24astagp = 'PSA'  "
              
   prepare p_psf14 from l_sql
   declare c_psf14 cursor for p_psf14
     
end function


#-----------------------------------------#
function bdbsr025()
#-----------------------------------------#

  display " "
  display "******Parametros do Relatório******"
  display "Data Início: ", l_data_inicio
  display "Data Fim: ", l_data_fim
  display " "
  
  start report bdbsr025_relatorio to m_path
  
  
  open c_psf00 using l_data_inicio
                    ,l_data_fim

   foreach c_psf00 into mr_psf.atdsrvnum
                       ,mr_psf.atdsrvano
                       ,mr_psf.atddat
                       ,mr_psf.atdhor
                       ,mr_psf.corsus
                       ,mr_psf.cornom
                       ,mr_psf.nom
                       ,mr_psf.socntzcod
                       ,mr_psf.prslocflg
                       ,mr_psf.atdsrvseq
                       ,mr_psf.asitipcod

      open c_psf07 using mr_psf.atdsrvnum
                        ,mr_psf.atdsrvano
                        ,mr_psf.atdsrvseq


      fetch c_psf07 into mr_psf.srrcoddig
                        ,mr_psf.pstcoddig
                        ,mr_psf.atdetpdat
                        ,mr_psf.atdetphor
                        ,mr_psf.atdetpcod



      open c_psf08 using mr_psf.atdsrvnum
                        ,mr_psf.atdsrvano

      fetch c_psf08 into mr_psf.ufdcod
                        ,mr_psf.cidnom
            


      whenever error continue

				 open c_psf09 using mr_psf.srrcoddig
         fetch c_psf09 into mr_psf.srrnom


				 open c_psf10 using mr_psf.pstcoddig
         fetch c_psf10 into mr_psf.nomgrr
         
         
				 open c_psf11 using mr_psf.asitipcod
         fetch c_psf11 into mr_psf.asitipdes


				 open c_psf12 using mr_psf.atdetpcod
         fetch c_psf12 into mr_psf.atdetpdes
          

         let mr_psf.diautil = dias_uteis(mr_psf.atdetpdat,0, "", "S", "S")
         
         let mr_psf.diadasemana = funferia_Dia_Semana(mr_psf.atdetpdat)
         
         if mr_psf.diautil = mr_psf.atdetpdat then
            let mr_psf.ehferiado = 'NÃO'
         else
            let mr_psf.ehferiado = 'SIM'
         end if
         

				 open c_psf13 using mr_psf.atdsrvnum
				                   ,mr_psf.atdsrvano
         fetch c_psf13 into mr_psf.socopgitmvlr
                  


      whenever error stop

      open c_psf01 using  mr_psf.atdsrvnum
                         ,mr_psf.atdsrvano
      fetch c_psf01 into mr_psf.lignum
      
   

      if mr_psf.lignum is null then
         let mr_psf.cpf = 'SEM LIGACAO'
         output to report bdbsr025_relatorio()
         initialize mr_psf.* to null
         continue foreach
      end if
      
      whenever error continue
         open c_psf04 using mr_psf.lignum
         fetch c_psf04 into mr_psf.c24astcod


         open c_psf14 using mr_psf.c24astcod
				 fetch c_psf14 into mr_psf.aux
         
         if sqlca.sqlcode = 100 then
            initialize mr_psf.* to null
            continue foreach
         end if
      
      whenever error stop

      open c_psf03 using mr_psf.lignum
      fetch c_psf03 into mr_psf.atdnum

      open c_psf02 using mr_psf.atdnum
      fetch c_psf02 into mr_psf.cgccpfnum
                        ,mr_psf.cgcord
                        ,mr_psf.cgccpfdig
                        ,mr_psf.semdoctocgccpfnum
                        ,mr_psf.semdoctocgcord
                        ,mr_psf.semdoctocgccpfdig

      let mr_psf.cpf = mr_psf.cgccpfnum, '/',
                        mr_psf.cgcord , '-', mr_psf.cgccpfdig

      let mr_psf.cpf2 = mr_psf.semdoctocgccpfnum
                         ,'/', mr_psf.semdoctocgcord
                         ,'-', mr_psf.semdoctocgccpfdig

      if mr_psf.socntzcod is not null then
         open c_psf05 using mr_psf.socntzcod
         fetch c_psf05 into mr_psf.socntzdes
         close c_psf05
      end if

      output to report bdbsr025_relatorio()
      initialize mr_psf.* to null

   end foreach
   
   close c_psf00
   close c_psf01
   close c_psf02
   close c_psf03
   close c_psf04
   close c_psf07
   close c_psf08
   close c_psf09
   close c_psf10
   close c_psf11
   close c_psf12
   close c_psf13
   close c_psf14
  
   
   finish report bdbsr025_relatorio

   call bdbsr025_envia_email(l_data_inicio, l_data_fim)

   display "Relatório extraído! "
end function


#-----------------------------------------#
function bdbsr025_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         data_inicial date,
         data_final   date
  end record

  define l_assunto     char(100),
         l_erro_envio  integer,
         l_comando     char(200)

  # ---> INICIALIZACAO DAS VARIAVEIS
  let l_comando    = null
  let l_erro_envio = null
  let l_assunto    = "Servicos prestador no local do periodo: ",
                     lr_parametro.data_inicial using "dd/mm/yyyy",
                     " a ",
                     lr_parametro.data_final using "dd/mm/yyyy"

  # ---> COMPACTA O ARQUIVO DO RELATORIO
  let l_comando = "gzip -f ", m_path

  run l_comando
  let m_path = m_path clipped, ".gz"

  let l_erro_envio = ctx22g00_envia_email("BDBSR025", l_assunto, m_path)

  if l_erro_envio <> 0 then
     if l_erro_envio <> 99 then
        display "Erro ao enviar email(ctx22g00) - ", m_path
     else
        display "Nao existe email cadastrado para o modulo - BDBSR025"
     end if
  end if

end function   


#-------------------------------------#
report bdbsr025_relatorio()
#-------------------------------------#


  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

  first page header

   print "SERVICO",            ASCII(09),
         "ANO",                ASCII(09),
         "ASSUNTO",            ASCII(09),
         "COD.ETAPA",          ASCII(09),
         "DES.ETAPA",          ASCII(09),
         "DATA.ABERTURA",      ASCII(09),
         "HORA.ABERTURA",      ASCII(09),
         "SUSEP",              ASCII(09),
         "CORRETOR",           ASCII(09),
         "DATA.ETAPA",         ASCII(09), 
         "HORA.ETAPA",         ASCII(09),
         "FERIADO?",           ASCII(09),
         "DIA SEMANA",         ASCII(09),
         "COD.ASSISTENCIA",    ASCII(09),
         "DES.ASSISTENCIA",    ASCII(09),
         "VALOR PAGO",         ASCII(09),
         "NOME",               ASCII(09),
         "CPF",                ASCII(09),
         "CPF_SEM_DOCT",       ASCII(09),
         "NATUREZA",           ASCII(09),
         "PROBLEMA",           ASCII(09),
         "PRESTADOR_NO_LOCAL", ASCII(09),
         "QRA",                ASCII(09),
         "NOME",               ASCII(09),
         "BASE_QRA",           ASCII(09),
         "NOME",               ASCII(09),
         "UF",                 ASCII(09),
         "CIDADE"


     on every row

        print mr_psf.atdsrvnum                        ,ascii(09);
        print mr_psf.atdsrvano                        ,ascii(09);
        print mr_psf.c24astcod                        ,ascii(09);
        print mr_psf.atdetpcod                        ,ascii(09);        
        print mr_psf.atdetpdes                        ,ascii(09);
        print mr_psf.atddat                           ,ascii(09);
        print mr_psf.atdhor                           ,ascii(09);
        print mr_psf.corsus                           ,ascii(09);
        print mr_psf.cornom                   clipped ,ascii(09);
        print mr_psf.atdetpdat                        ,ascii(09);
        print mr_psf.atdetphor                        ,ascii(09);
        print mr_psf.ehferiado                        ,ascii(09);
        print mr_psf.diadasemana              clipped ,ascii(09);
        print mr_psf.asitipcod                        ,ascii(09);
        print mr_psf.asitipdes                        ,ascii(09);
        print mr_psf.socopgitmvlr using "#######&.&&" ,ascii(09);
        print mr_psf.nom                      clipped ,ascii(09);
        print mr_psf.cpf                              ,ascii(09);
        print mr_psf.cpf2                             ,ascii(09);
        print mr_psf.socntzdes                clipped ,ascii(09);
        print mr_psf.c24pbmdes                clipped ,ascii(09);
        print mr_psf.prslocflg                        ,ascii(09);
        print mr_psf.srrcoddig                        ,ascii(09);
        print mr_psf.srrnom                   clipped ,ascii(09);
        print mr_psf.pstcoddig                        ,ascii(09);
        print mr_psf.nomgrr                   clipped ,ascii(09);
        print mr_psf.ufdcod                           ,ascii(09);
        print mr_psf.cidnom

end report



