#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: BDBSR131.4GL                                              #
# ANALISTA RESP..: CELSO ISSAMU YAMAHAKI                                     #
# PSI/OSF........: PSI-2011-09700/EV                                         #
# OBJETIVO.......: AUTOMATIZACAO NO PROCESSO DE CONFECCAO DE RELATORIOS      #
#                  ANALISE DE FUNCIONARIOS                                   #
#............................................................................#
# DESENVOLVIMENTO: CELSO YAMAHAKI                                            #
# LIBERACAO......: 26/07/2011                                                #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
# 15/02/2012  Celso Yamahaki  PSI-03847-EV  Mudanca para data diária.        #
# 01/03/2012  Celso Yamahaki  PSI-03847-EV  Inclusao de novos campos, criacao#
#                                           do Relatório 'Analise Manual'    #
# 21/03/2012  Celso Yamahaki  PSI-03847-EV  Mudanca do nome e inclusão de 3  #
#                                           novas colunas para o relatório   #
# -------------------------------------------------------------------------- #

database porto

define  m_path              char(100),
        m_path_txt          char(100),
        m_data_inicio       date,
        m_data_fim          date,
        m_data              date,
        m_hora              datetime hour to minute,
        m_prepare           smallint,
        m_path_manual       char(150),
        m_path_web          char(150),
        m_path_manual_txt   char(150),
        m_path_web_txt      char(150)


define mr_bdbsr131   record 
       anlokadat     like dbsmsrvacr.anlokadat,  # Data
       anlmat        like dbsmsrvacr.anlmat   ,  # Matricula
       funnom        like isskfunc.funnom     ,  # Nome Funcionario
       total         integer                     # Quantidade total do Dia
end record 

define mr_analise    record
       anlokadat     like dbsmsrvacr.anlokadat, # Data
       anlmat        like dbsmsrvacr.anlmat   , # Matricula
       funnom        like isskfunc.funnom     , # Nome Funcionario
       atdsrvnum     like dbsmsrvacr.atdsrvnum, # Servico
       atdsrvano     like dbsmsrvacr.atdsrvano, # Ano
       incvlr        like dbsmsrvacr.incvlr,    # Valor Inicial
       fnlvlr        like dbsmsrvacr.fnlvlr,    # Valor Final
       anlokaflg     like dbsmsrvacr.anlokaflg, # Status da Analise
       anlinidat     like dbsmsrvacr.anlinidat, # Data e Hora do Inicio da Analise
       prsvlr        like dbsmsrvacr.prsvlr,    # Valor informado pelo Prestador
       anlokahor     like dbsmsrvacr.anlokahor  # Horario de Inicio
end record

define mr_servico    record
       pstcoddig     like datmsrvacp.pstcoddig,  # Prestador
       atdsrvorg     like datmservico.atdsrvorg, # Origem 
       atdcstvlr     like datmservico.atdcstvlr  # Valor Final Servico
end record

define mr_prestador  record
       nomrazsoc     like dpaksocor.nomrazsoc,   # Razao Social
       pcpatvcod     like dpaksocor.pcpatvcod,   # Atividade Principal
       pcpatvdes     char (25),                  # Descricao Atividade Principal
       pstcidsedcod  like datrcidsed.cidsedcod,  # Codigo Cidade Sede Prestador
       pstcidsednom  like glakcid.cidnom,        # Nome Cidade Sede Prestador
       pstufsed      like glakcid.ufdcod,        # UF Sede Prestador
       endcidcod     like glakcid.cidcod,        # Codigo Cidade Prestador
       endcid        like dpaksocor.endcid,      # Cidade Prestador
       endufd        like dpaksocor.endufd       # UF Prestador
end record

define mr_manual   record #record para analise manual
       caddat        like datmpreacp.caddat   , # Data
       cadmat        like datmpreacp.cadmat   , # Matricula
       funnom        like isskfunc.funnom     , # Nome Funcionario
       atdsrvnum     like datmpreacp.atdsrvnum, # Servico
       atdsrvano     like datmpreacp.atdsrvano, # Ano
       srvinccst     like datmpreacp.srvinccst, # Custo Inicial
       atdcstvlr     like datmservico.atdcstvlr,# Custo Final
       socopgitmcst  like dbsmopgcst.socopgitmcst # Custos adicionais para SRV RE
end record


main
   define l_week integer

   initialize mr_bdbsr131.*,
              m_data,
              m_data_inicio,
              m_data_fim,
              m_hora,
              l_week,
              mr_analise.*,
              mr_servico.*,
              mr_prestador.*   to null

   let m_data = arg_val(1)

   # ---> OBTER A DATA E HORA DO BANCO 
   if m_data is null then
      call cts40g03_data_hora_banco(2)
      returning m_data,
                m_hora

      let m_data_fim = mdy(month(m_data),01,year(m_data)) - 1 units day
      let m_data_inicio = mdy(month(m_data_fim),01,year(m_data_fim))

   end if

   let l_week = weekday(m_data)
   
   if l_week = 1 then
      let m_data = m_data - 2 units day
   else 
      let m_data = m_data - 1 units day
   end if                     

   display "Data base: ", m_data

   call fun_dba_abre_banco("CT24HS")
   call cts40g03_exibe_info("I","BDBSR131")

   if not m_prepare then 
      call bdbsr131_prepare()
   end if

   call bdbsr131_busca_path()

   set isolation to dirty read
   call bdbsr131_anlweb()
   call bdbsr131_anlmanual()

   call cts40g03_exibe_info("F","BDBSR131")

end main

#-------------------------------
function bdbsr131_prepare()
#-------------------------------

   define l_sql char(3000),
          l_mat char(1000)

   let l_mat = bdbsr131_dominio('anlmat_func') 
   let l_mat = l_mat clipped

   let l_sql =  " select  anlokadat,                 ",
                "         anlmat,                    ",
                "         funnom,                    ",
                "         count(*)                   ",
                "    from dbsmsrvacr,                ",
                "         isskfunc                   ",
                "  where anlmat = funmat             ",
                "    and anlusrtip = usrtip          ",
                "    and anlemp = empcod             ",
             #  "    and anlokaflg = 'S'             ",
                "    and anlokadat ='",  m_data ,  "'",
                "    and autokaflg = 'N'             ",
                "    and anlmat in (",l_mat,")       ",
                "  group by anlokadat,anlmat,funnom  ",
                "  order by anlokadat, anlmat        "

   prepare pbdbsr131_01 from l_sql
   declare cbdbsr131_01 cursor for pbdbsr131_01

   let l_sql = " select anlokadat, anlmat,      ",
               "        funnom, atdsrvnum,      ",
               "        atdsrvano, incvlr,      ",
               "        fnlvlr,anlokaflg,       ",
               "        anlinidat, prsvlr,      ",
               "        anlokahor               ",
               "   from dbsmsrvacr ,            ",
               "        isskfunc                ",
               "  where anlmat = funmat         ",
               "    and anlusrtip = usrtip      ",
               "    and anlemp = empcod         ", 
             # "    and anlokaflg = 'S'         ", #FASE IV PSI03847
               "    and anlokadat ='", m_data,"'",
               "    and autokaflg = 'N'         ",
               "    and anlmat in (",l_mat,")   ",
               "   group by anlokadat, anlmat,  ",
               "            funnom,atdsrvnum,   ",
               "            atdsrvano, incvlr,  ",
               "            fnlvlr,anlokaflg,   ",
               "            anlinidat, prsvlr,  ",
               "            anlokahor           ",
               "   order by anlokadat, anlmat   "

   prepare pbdbsr131_02 from l_sql
   declare cbdbsr131_02 cursor for pbdbsr131_02

   let l_sql = " select srv.atdsrvorg, acp.pstcoddig, srv.atdcstvlr ",
               "   from datmservico srv, datmsrvacp acp              ",
               "  where srv.atdsrvnum = acp.atdsrvnum                ",
               "    and srv.atdsrvano = acp.atdsrvano                ",
               "    and srv.atdsrvnum = ?                            ",
               "    and srv.atdsrvano = ?                            ",
               "    and acp.atdsrvseq = (select max(atdsrvseq)       ",
               "                           from datmsrvacp           ",
               "                          where atdsrvnum = ?        ",
               "                            and atdsrvano = ?)       "

   prepare pbdbsr131_03 from l_sql
   declare cbdbsr131_03 cursor for pbdbsr131_03
   
   let l_sql = " select nomrazsoc, pcpatvcod, endcid, endufd ",
               "    from dpaksocor where pstcoddig = ?       "

   prepare pbdbsr131_04 from l_sql
   declare cbdbsr131_04 cursor for pbdbsr131_04

   let l_sql = " select cidcod, cidnom, ufdcod ",
               "   from glakcid                ",
               "   where cidnom = ?            ",
               "     and ufdcod = ?            "

   prepare pbdbsr131_05 from l_sql
   declare cbdbsr131_05 cursor for pbdbsr131_05

   let l_sql = " select cidcod, cidnom, ufdcod ",
               "   from glakcid                ",
               "   where cidcod = ?            "

   prepare pbdbsr131_06 from l_sql
   declare cbdbsr131_06 cursor for pbdbsr131_06

   let l_sql = " select cidsedcod  ",
               "   from datrcidsed ",
               "  where cidcod = ? "

   prepare pbdbsr131_07 from l_sql
   declare cbdbsr131_07 cursor for pbdbsr131_07

   let l_sql = " select cpodes                ",
               "   from iddkdominio           ",
               "  where cponom = 'pcpatvcod'  ",
               "    and cpocod = ?            "

   prepare pbdbsr131_08 from l_sql
   declare cbdbsr131_08 cursor for pbdbsr131_08

   let l_sql = " select srv.caddat, srv.cadmat,     ",
               "       fun.funnom, srv.atdsrvnum,   ",
               "       srv.atdsrvano, srv.srvinccst ",
               "  from datmpreacp srv,              ",
               "       isskfunc  fun                ",
               " where srv.cadmat = fun.funmat      ",
               "   and srv.usrtip = fun.usrtip      ",
               "   and srv.cademp = fun.empcod      ",
               "   and srv.caddat = '", m_data,   "'",
               "   and srv.cadmat in (",l_mat,")    ",
               " group by  srv.caddat, srv.cadmat,  ",
               "       fun.funnom, srv.atdsrvnum,   ",
               "       srv.atdsrvano, srv.srvinccst ",
               " order by srv.caddat, srv.cadmat,   ",
               "       fun.funnom                   "

   prepare pbdbsr131_09 from l_sql
   declare cbdbsr131_09 cursor for pbdbsr131_09

   let l_sql = " select socopgnum    ",
               "   from dbsmopgitm   ",
               "  where atdsrvnum = ?",
               "    and atdsrvano = ?"
   prepare pbdbsr131_10 from l_sql
   declare cbdbsr131_10 cursor for pbdbsr131_10

   let l_sql = " select sum(socopgitmcst) ",
               "   from dbsmopgcst        ",
               "  where socopgnum = ?     ",
               "    and atdsrvnum = ?     ",
               "    and atdsrvano = ?     "

   prepare pbdbsr131_11 from l_sql
   declare cbdbsr131_11 cursor for pbdbsr131_11

   let l_sql = " select srv.caddat, srv.cadmat,     ",
               "       fun.funnom, count(*)         ",
               "  from datmpreacp srv,              ",
               "       isskfunc  fun                ",
               " where srv.cadmat = fun.funmat      ",
               "   and srv.usrtip = fun.usrtip      ",
               "   and srv.cademp = fun.empcod      ",
               "   and srv.caddat = '", m_data,   "'",
               "   and srv.cadmat in (",l_mat,")    ",
               " group by  srv.caddat, srv.cadmat,  ",
               "       fun.funnom                   ",
               " order by srv.caddat, srv.cadmat    "
   prepare pbdbsr131_12 from l_sql
   declare cbdbsr131_12 cursor for pbdbsr131_12

   let m_prepare = true

end function

#----------------------
function bdbsr131_anlweb()
#----------------------

   if not m_prepare then 
      call bdbsr131_prepare()
   end if
   
    start report bdbsr131_relat_anlweb to m_path_web
    start report bdbsr131_relat_anlweb_txt to m_path_web_txt

   whenever error continue
      open cbdbsr131_02
      foreach cbdbsr131_02 into  mr_analise.anlokadat #01
                                ,mr_analise.anlmat    #02
                                ,mr_analise.funnom    #03
                                ,mr_analise.atdsrvnum #05
                                ,mr_analise.atdsrvano #06
                                ,mr_analise.incvlr    #07
                                ,mr_analise.fnlvlr    #08
                                ,mr_analise.anlokaflg #15
                                ,mr_analise.anlinidat #16
                                ,mr_analise.prsvlr    #14
                                ,mr_analise.anlokahor #17

                                

         #Busca a Origem e o Prestador do Servico
         open cbdbsr131_03 using  mr_analise.atdsrvnum, mr_analise.atdsrvano
                                 ,mr_analise.atdsrvnum, mr_analise.atdsrvano

         fetch cbdbsr131_03 into mr_servico.atdsrvorg #04
                                ,mr_servico.pstcoddig #09
                                ,mr_servico.atdcstvlr
         close cbdbsr131_03

         #Busca os Dados do Prestador
         open cbdbsr131_04 using mr_servico.pstcoddig

         fetch cbdbsr131_04 into  mr_prestador.nomrazsoc #10
                                 ,mr_prestador.pcpatvcod
                                 ,mr_prestador.endcid   
                                 ,mr_prestador.endufd   

         #Busca pela Descricao da Atividade Principal
         open cbdbsr131_08 using mr_prestador.pcpatvcod

         fetch cbdbsr131_08 into mr_prestador.pcpatvdes #11
         close cbdbsr131_08


         #Busca pela Cidade Sede
         open cbdbsr131_05 using mr_prestador.endcid, mr_prestador.endufd

         fetch cbdbsr131_05 into  mr_prestador.endcidcod
                                 ,mr_prestador.endcid
                                 ,mr_prestador.endufd
         close cbdbsr131_05

         open cbdbsr131_07 using mr_prestador.endcidcod

         fetch cbdbsr131_07 into mr_prestador.pstcidsedcod
         close cbdbsr131_07

         open cbdbsr131_06 using mr_prestador.pstcidsedcod
         
         fetch cbdbsr131_06 into  mr_prestador.pstcidsedcod
                                 ,mr_prestador.pstcidsednom #12
                                 ,mr_prestador.pstufsed     #13

         close cbdbsr131_06

         output to report bdbsr131_relat_anlweb()
         output to report bdbsr131_relat_anlweb_txt() 

         initialize mr_analise.*, mr_servico.*, mr_prestador.* to null

      end foreach

   whenever error stop
   
   finish report bdbsr131_relat_anlweb
   finish report bdbsr131_relat_anlweb_txt

   call bdbsr131_envia_email(2)

end function

#----------------------
function bdbsr131_anlmanual()
#----------------------
   define l_socopgnum like dbsmopg.socopgnum

   if not m_prepare then
      call bdbsr131_prepare()
   end if
   let l_socopgnum = null

   start report bdbsr131_relat_anlmanual to m_path_manual
   start report bdbsr131_relat_anlmanual_txt to m_path_manual_txt

      whenever error continue
         open cbdbsr131_09
         foreach cbdbsr131_09 into  mr_manual.caddat    # 01
                                   ,mr_manual.cadmat    # 02
                                   ,mr_manual.funnom    # 03
                                   ,mr_manual.atdsrvnum # 05
                                   ,mr_manual.atdsrvano # 06
                                   ,mr_manual.srvinccst # 07


         #Busca a Origem e o Prestador do Servico
         open cbdbsr131_03 using  mr_manual.atdsrvnum, mr_manual.atdsrvano
                                 ,mr_manual.atdsrvnum, mr_manual.atdsrvano

         fetch cbdbsr131_03 into mr_servico.atdsrvorg #04
                                ,mr_servico.pstcoddig #09
                                ,mr_servico.atdcstvlr #08
         close cbdbsr131_03


         #Se for Origem RE procura pela OP e os custos Adicionais
         if mr_servico.atdsrvorg = 9 or
            mr_servico.atdsrvorg = 13 then

            #Busca o numero da OP
            open cbdbsr131_10 using mr_manual.atdsrvnum
                                   ,mr_manual.atdsrvano

            fetch cbdbsr131_10 into l_socopgnum

            if sqlca.sqlcode = 0 then
               open cbdbsr131_11 using l_socopgnum
                                       ,mr_manual.atdsrvnum
                                       ,mr_manual.atdsrvano
               fetch cbdbsr131_11 into mr_manual.socopgitmcst # 08
               close cbdbsr131_11
            end if

            close cbdbsr131_10

         end if

         #Busca os Dados do Prestador
         open cbdbsr131_04 using mr_servico.pstcoddig

         fetch cbdbsr131_04 into  mr_prestador.nomrazsoc #10
                                 ,mr_prestador.pcpatvcod
                                 ,mr_prestador.endcid   
                                 ,mr_prestador.endufd   

         #Busca pela Descricao da Atividade Principal
         open cbdbsr131_08 using mr_prestador.pcpatvcod

         fetch cbdbsr131_08 into mr_prestador.pcpatvdes #11
         close cbdbsr131_08


         #Busca pela Cidade Sede
         open cbdbsr131_05 using mr_prestador.endcid, mr_prestador.endufd

         fetch cbdbsr131_05 into  mr_prestador.endcidcod
                                 ,mr_prestador.endcid
                                 ,mr_prestador.endufd
         close cbdbsr131_05

         open cbdbsr131_07 using mr_prestador.endcidcod

         fetch cbdbsr131_07 into mr_prestador.pstcidsedcod
         close cbdbsr131_07

         open cbdbsr131_06 using mr_prestador.pstcidsedcod

         fetch cbdbsr131_06 into  mr_prestador.pstcidsedcod
                                 ,mr_prestador.pstcidsednom #12
                                 ,mr_prestador.pstufsed     #13

         close cbdbsr131_06

         output to report bdbsr131_relat_anlmanual()
         output to report bdbsr131_relat_anlmanual_txt()  

         initialize mr_servico.*, mr_prestador.*, mr_manual to null
      end foreach

      whenever error stop

   finish report bdbsr131_relat_anlmanual
   finish report bdbsr131_relat_anlmanual_txt

   call bdbsr131_envia_email(1)

end function

#----------------------
function bdbsr131()
#----------------------

   if not m_prepare then
      call bdbsr131_prepare()
   end if

   start report bdbsr131_relatorio to m_path
   start report bdbsr131_relatorio_txt to m_path_txt  
      whenever error continue

      open cbdbsr131_01
      
      foreach cbdbsr131_01 into mr_bdbsr131.anlokadat,
                                mr_bdbsr131.anlmat   ,
                                mr_bdbsr131.funnom   ,
                                mr_bdbsr131.total

         output to report bdbsr131_relatorio()
         output to report bdbsr131_relatorio_txt() 

         initialize mr_bdbsr131.* to null

      end foreach

      close cbdbsr131_01
      whenever error stop

   finish report bdbsr131_relatorio
   finish report bdbsr131_relatorio_txt

   call bdbsr131_envia_email(0)

end function

#---------------------------
report bdbsr131_relat_anlweb()
#---------------------------
   define l_valor char(25),
          l_anlinidat char(25)

   output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

   format

     first page header

        print "DATA",                 ASCII(09), # 01
              "MATRICULA",            ASCII(09), # 02
              "NOME",                 ASCII(09), # 03
              "ORIGEM",               ASCII(09), # 04
              "SERVICO",              ASCII(09), # 05
              "ANO",                  ASCII(09), # 06
              "VALOR_INICIAL",        ASCII(09), # 07
              "VALOR_INFORMADO",      ASCII(09), # 14
              "VALOR_TOTAL",          ASCII(09), # 08
              "CODIGO_PRESTADOR",     ASCII(09), # 09
              "RAZAO_SOCIAL",         ASCII(09), # 10
              "ATIVIDADE_PRINCIPAL",  ASCII(09), # 11
              "CIDADE_SEDE_PRESTADOR",ASCII(09), # 12
              "UF_SEDE_PRESTADOR",    ASCII(09), # 13
              "STATUS_ANALISE",       ASCII(09), # 15
              "HORARIO_INICIO_ANL",   ASCII(09), # 16
              "HORARIO_FINAL_ANL"                # 17

   on every row

      print mr_analise.anlokadat      ,ASCII(09); # 01
      print mr_analise.anlmat         ,ASCII(09); # 02
      print mr_analise.funnom         ,ASCII(09); # 03
      print mr_servico.atdsrvorg      ,ASCII(09); # 04
      print mr_analise.atdsrvnum      ,ASCII(09); # 05
      print mr_analise.atdsrvano      ,ASCII(09); # 06
      let l_valor = null

      call bdbsr131_troca_ponto(mr_analise.incvlr)
           returning l_valor
      print l_valor clipped           ,ASCII(09); # 07

      let l_valor = null

      call bdbsr131_troca_ponto(mr_analise.prsvlr)
           returning l_valor
      print l_valor clipped           ,ASCII(09); # 14

      let l_valor = null
       call bdbsr131_troca_ponto(mr_analise.fnlvlr)
           returning l_valor

      print l_valor clipped            ,ASCII(09); # 08
      print mr_servico.pstcoddig       ,ASCII(09); # 09
      print mr_prestador.nomrazsoc     ,ASCII(09); # 10
      print mr_prestador.pcpatvdes     ,ASCII(09); # 11
      print mr_prestador.pstcidsednom  ,ASCII(09); # 12
      print mr_prestador.pstufsed      ,ASCII(09); # 13
      print mr_analise.anlokaflg       ,ASCII(09); # 15
      let l_anlinidat = null
      let l_anlinidat = mr_analise.anlinidat
      print l_anlinidat[12,19]         ,ASCII(09); # 16
      print mr_analise.anlokahor       ,ASCII(09)  # 17

   on last row

   if not m_prepare then
     call bdbsr131_prepare()
   end if

   initialize mr_bdbsr131.* to null

   skip 3 line
   print "NOME",ASCII(09),"QUANTIDADE";

   skip 1 line
   open cbdbsr131_01
   foreach cbdbsr131_01 into mr_bdbsr131.anlokadat,
                             mr_bdbsr131.anlmat   ,
                             mr_bdbsr131.funnom   ,
                             mr_bdbsr131.total

      print mr_bdbsr131.funnom, ASCII(09);
      print mr_bdbsr131.total
      initialize mr_bdbsr131.* to null

   end foreach

end report

#-------------------------------------#
report bdbsr131_relat_anlmanual()
#-------------------------------------#
   define l_valor char(25),
          l_total like dbsmopgcst.socopgitmcst

   output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

   format

     first page header

        print "DATA",                 ASCII(09), # 01
              "MATRICULA",            ASCII(09), # 02
              "NOME",                 ASCII(09), # 03
              "ORIGEM",               ASCII(09), # 04
              "SERVICO",              ASCII(09), # 05
              "ANO",                  ASCII(09), # 06
              "VALOR_INICIAL",        ASCII(09), # 07
              "CUSTO_TOTAL",          ASCII(09), # 08
              "CODIGO_PRESTADOR",     ASCII(09), # 09
              "RAZAO_SOCIAL",         ASCII(09), # 10
              "ATIVIDADE_PRINCIPAL",  ASCII(09), # 11
              "CIDADE_SEDE_PRESTADOR",ASCII(09), # 12
              "UF_SEDE_PRESTADOR"                # 13

   on every row

      print mr_manual.caddat         ,ASCII(09); # 01
      print mr_manual.cadmat         ,ASCII(09); # 02
      print mr_manual.funnom         ,ASCII(09); # 03
      print mr_servico.atdsrvorg     ,ASCII(09); # 04
      print mr_manual.atdsrvnum      ,ASCII(09); # 05
      print mr_manual.atdsrvano      ,ASCII(09); # 06

      if mr_manual.socopgitmcst is null then 
         let mr_manual.socopgitmcst= 0
      end if

      if mr_manual.srvinccst is null then
         let mr_manual.srvinccst = 0
      end if

      let l_total = 0

      let l_total = mr_manual.socopgitmcst + mr_servico.atdcstvlr 
      let l_valor = null

      call bdbsr131_troca_ponto(mr_manual.srvinccst)
           returning l_valor
      print l_valor clipped           ,ASCII(09); # 07

      let l_valor = null
      call bdbsr131_troca_ponto(l_total)
           returning l_valor

      print l_valor clipped           ,ASCII(09); # 08
      print mr_servico.pstcoddig      ,ASCII(09); # 09
      print mr_prestador.nomrazsoc    ,ASCII(09); # 10
      print mr_prestador.pcpatvdes    ,ASCII(09); # 11
      print mr_prestador.pstcidsednom ,ASCII(09); # 12
      print mr_prestador.pstufsed     ,ASCII(09)  # 13

   on last row

   if not m_prepare then
     call bdbsr131_prepare()
   end if

   initialize mr_bdbsr131.* to null

   skip 3 line
   print "NOME",ASCII(09),"QUANTIDADE";

   skip 1 line
   open cbdbsr131_12
   foreach cbdbsr131_12 into mr_bdbsr131.anlokadat,
                             mr_bdbsr131.anlmat   ,
                             mr_bdbsr131.funnom   ,
                             mr_bdbsr131.total

      print mr_bdbsr131.funnom, ASCII(09);
      print mr_bdbsr131.total
      initialize mr_bdbsr131.* to null

   end foreach

end report

#-------------------------------------#
report bdbsr131_relatorio()
#-------------------------------------#


  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        print "DATA",       ASCII(09),  # 1
              "MATRICULA",  ASCII(09),  # 2
              "NOME",       ASCII(09),  # 3
              "QUANTIDADE"              # 4

  on every row


     print mr_bdbsr131.anlokadat,  ASCII(09);  #1
     print mr_bdbsr131.anlmat,     ASCII(09);  #2
     print mr_bdbsr131.funnom,     ASCII(09);  #3
     print mr_bdbsr131.total                   #4


end report


#------------------------------
function bdbsr131_busca_path()
#------------------------------

   define l_dia char(02),
          l_mes char(02),
          l_ano char(04)
          
   define l_dataarq char(8)
   define l_data    date
   
   let l_data = today
   display "l_data: ", l_data
   let l_dataarq = extend(l_data, year to year),
                   extend(l_data, month to month),
                   extend(l_data, day to day)
   display "l_dataarq: ", l_dataarq
          
   # ---> INICIALIZACAO DAS VARIAVEIS
   let m_path             = null
   let m_path_manual      = null
   let m_path_web         = null
   let l_dia              = null
   let l_mes              = null
   let l_ano              = null 
   let m_path_txt         = null
   let m_path_manual_txt  = null 
   let m_path_web_txt     = null

   # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
   let m_path = f_path("DBS","LOG")

   if m_path is null then
      let m_path = "."
   end if
   let m_path = m_path clipped, "/BDBSR131.log" 
   call startlog(m_path)

   # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
   let m_path = f_path("DBS", "RELATO")


   if m_path is null then
      let m_path = "."
   end if

   let l_dia = day(m_data)
   let l_mes = month(m_data)clipped
   let l_ano = year(m_data)

   if l_mes < 10 then 
      let l_mes = "0",l_mes
   end if

   let m_path = m_path clipped , '/'

   #Utilizar para gerar eventual
   #let m_path = '/asheeve/'

   let m_path_manual = m_path
   let m_path_web = m_path
   let m_path_txt = m_path
   let m_path_manual_txt = m_path 
   let m_path_web_txt = m_path   
   
   display "m_path: ", m_path

   let m_path = m_path clipped,l_dia, l_mes clipped , l_ano ,"BDBSR131.xls"
   let m_path_manual = m_path_manual clipped, l_dia clipped, l_mes clipped, l_ano , "BDBSR131Manual.xls"
   let m_path_web = m_path_web clipped, l_dia clipped, l_mes clipped, l_ano , "BDBSR131Web.xls"
   let m_path_txt = m_path_txt clipped,"BDBSR131_", l_dataarq, ".txt" 
   let m_path_manual_txt = m_path_manual_txt clipped, "BDBSR131_MANUAL_", l_dataarq, ".txt" 
   let m_path_web_txt = m_path_web_txt clipped, "BDBSR131_WEB_", l_dataarq, ".txt" 

   display "m_path: ", m_path
   display "m_path_manual: ", m_path_manual clipped
   display "m_path_web: ", m_path_web clipped

end function



#Funcao que retorna todos os dominios concatenados separados por ','
#---------------------------------
function bdbsr131_dominio(l_cponom)
#---------------------------------
   
         
   define l_cponom     like iddkdominio.cponom,
          l_cponom_aux like iddkdominio.cponom,
          l_retorno    char(500),
          l_qtd        smallint,
          l_cont       smallint

   initialize l_cponom_aux, l_retorno to null

   select count(cpodes)
   into   l_qtd
   from   iddkdominio
   where  cponom = l_cponom


   let l_cont = 0
   declare cdominio cursor for

      select cpodes
      from   iddkdominio
      where  cponom = l_cponom

      foreach cdominio into l_cponom_aux  

         let l_cont = l_cont + 1
         if l_qtd = 1 then
            let l_retorno = l_retorno clipped, l_cponom_aux clipped
            return l_retorno clipped
         else
            if l_cont = 1 then
               let l_retorno = l_retorno clipped, l_cponom_aux clipped
            else
               let l_retorno = l_retorno clipped, ',', l_cponom_aux clipped
            end if
         end if
         
         initialize l_cponom_aux to null

      end foreach

   return l_retorno clipped


end function


#-----------------------------------------#
function bdbsr131_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         tipo smallint # 0 - Padrão, 1 - manual, 2 - Web
  end record

  define l_assunto     char(100),
         l_erro_envio  integer,
         l_comando     char(200),
         l_path        char(200),
         l_modo        char(20)

  # ---> INICIALIZACAO DAS VARIAVEIS
  let l_comando    = null
  let l_erro_envio = null
  let l_path = null
  let l_modo = null

  case lr_parametro.tipo
     when 0
        let l_path = m_path
        let l_modo = null
     when 1
        let l_path = m_path_manual
        let l_modo = 'Manual'
     when 2
        let l_path = m_path_web
        let l_modo = 'Web' #Descomentar na Fase IV
  end case

  let l_assunto    = "Relatório de Analise de Funcionarios "
                     , l_modo clipped 
                     ," - ",
                     " do dia: ",
                     m_data

  # ---> COMPACTA O ARQUIVO DO RELATORIO
  let l_comando = "gzip -f ", l_path

  run l_comando
  let l_path = l_path clipped, ".gz"

  let l_erro_envio = ctx22g00_envia_email("BDBSR131", l_assunto, l_path)

  if l_erro_envio <> 0 then
     if l_erro_envio <> 99 then
        display "Erro ao enviar email(ctx22g00) - ", l_path
     else
        display "Nao existe email cadastrado para o modulo - BDBSR131"
     end if
  end if

end function

#-----------------------------------
function bdbsr131_troca_ponto(param)
#-----------------------------------
   define param record
     valor like datmservico.atdcstvlr  
   end record
   
   define l_char char(25),
          l_i    smallint
   
   let l_char = param.valor
          
   for l_i = 1 to 15 step 1
     
     if l_char[l_i] = "." then
        let l_char[l_i] = ","
     end if
     
   end for 
   
   return l_char
   
end function


#---------------------------
report bdbsr131_relat_anlweb_txt()
#---------------------------
   define l_valor char(25),
          l_anlinidat char(25)

   output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    01

   format

      on every row

      print mr_analise.anlokadat      ,ASCII(09); # 01
      print mr_analise.anlmat         ,ASCII(09); # 02
      print mr_analise.funnom         ,ASCII(09); # 03
      print mr_servico.atdsrvorg      ,ASCII(09); # 04
      print mr_analise.atdsrvnum      ,ASCII(09); # 05
      print mr_analise.atdsrvano      ,ASCII(09); # 06
      let l_valor = null

      call bdbsr131_troca_ponto(mr_analise.incvlr)
           returning l_valor
      print l_valor clipped           ,ASCII(09); # 07

      let l_valor = null

      call bdbsr131_troca_ponto(mr_analise.prsvlr)
           returning l_valor
      print l_valor clipped           ,ASCII(09); # 14

      let l_valor = null
       call bdbsr131_troca_ponto(mr_analise.fnlvlr)
           returning l_valor

      print l_valor clipped            ,ASCII(09); # 08
      print mr_servico.pstcoddig       ,ASCII(09); # 09
      print mr_prestador.nomrazsoc     ,ASCII(09); # 10
      print mr_prestador.pcpatvdes     ,ASCII(09); # 11
      print mr_prestador.pstcidsednom  ,ASCII(09); # 12
      print mr_prestador.pstufsed      ,ASCII(09); # 13
      print mr_analise.anlokaflg       ,ASCII(09); # 15
      let l_anlinidat = null
      let l_anlinidat = mr_analise.anlinidat
      print l_anlinidat[12,19]         ,ASCII(09); # 16
      print mr_analise.anlokahor                   # 17

   

end report

#-------------------------------------#
report bdbsr131_relat_anlmanual_txt()
#-------------------------------------#
   define l_valor char(25),
          l_total like dbsmopgcst.socopgitmcst

   output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    01

   format

      on every row

      print mr_manual.caddat         ,ASCII(09); # 01
      print mr_manual.cadmat         ,ASCII(09); # 02
      print mr_manual.funnom         ,ASCII(09); # 03
      print mr_servico.atdsrvorg     ,ASCII(09); # 04
      print mr_manual.atdsrvnum      ,ASCII(09); # 05
      print mr_manual.atdsrvano      ,ASCII(09); # 06

      if mr_manual.socopgitmcst is null then 
         let mr_manual.socopgitmcst= 0
      end if

      if mr_manual.srvinccst is null then
         let mr_manual.srvinccst = 0
      end if

      let l_total = 0

      let l_total = mr_manual.socopgitmcst + mr_servico.atdcstvlr 
      let l_valor = null

      call bdbsr131_troca_ponto(mr_manual.srvinccst)
           returning l_valor
      print l_valor clipped           ,ASCII(09); # 07

      let l_valor = null
      call bdbsr131_troca_ponto(l_total)
           returning l_valor

      print l_valor clipped           ,ASCII(09); # 08
      print mr_servico.pstcoddig      ,ASCII(09); # 09
      print mr_prestador.nomrazsoc    ,ASCII(09); # 10
      print mr_prestador.pcpatvdes    ,ASCII(09); # 11
      print mr_prestador.pstcidsednom ,ASCII(09); # 12
      print mr_prestador.pstufsed                 # 13

   

end report

#-------------------------------------#
report bdbsr131_relatorio_txt()
#-------------------------------------#


  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    01

  format

     on every row


     print mr_bdbsr131.anlokadat,  ASCII(09);  #1
     print mr_bdbsr131.anlmat,     ASCII(09);  #2
     print mr_bdbsr131.funnom,     ASCII(09);  #3
     print mr_bdbsr131.total                   #4


end report
