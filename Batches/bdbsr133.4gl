#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: BDBSR133.4GL                                              #
# ANALISTA RESP..: CELSO ISSAMU YAMAHAKI                                     #
# PSI/OSF........: PSI-2011-09700/EV                                         #
# OBJETIVO.......: AUTOMATIZACAO NO PROCESSO DE CONFECCAO DE RELATORIOS      #
#                  SERVICO DE ASSISTENCIA FUNERARIA                          #
#............................................................................#
# DESENVOLVIMENTO: CELSO YAMAHAKI                                            #
# LIBERACAO......: 26/07/2011                                                #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
#                                                                            #
# -------------------------------------------------------------------------- #


database porto

define  m_path         char(100),
        m_path2        char(100),
        m_path_txt     char(100),
        m_path2_txt    char(100),
        m_data_inicio  date,
        m_data_fim     date,
        m_data         date,
        m_hora         datetime hour to minute


define mr_bdbsr133   record
       atdsrvnum        like  datmservico.atdsrvnum       , # 1
       atdsrvano        like  datmservico.atdsrvano       , # 2
       succod           like  datrservapol.succod         , # 3
       ramcod           like  datrservapol.ramcod         , # 4
       aplnumdig        like  datrservapol.aplnumdig      , # 5
       itmnumdig        like  datrservapol.itmnumdig      , # 6
       edsnumref        like  datrservapol.edsnumref      , # 7
       c24solnom        like  datmservico.c24solnom       , # 8
       segdclprngracod  like  datmfnrsrv.segdclprngracod  , # 9
       cttteltxt        like  datmfnrsrv.cttteltxt        , # 10
       flcnom           like  datmfnrsrv.flcnom           , # 11
       flcidd           like  datmfnrsrv.flcidd           , # 12
       obtdat           like  datmfnrsrv.obtdat           , # 13
       mrtcaucod        like  datmfnrsrv.mrtcaucod        , # 14
       libcrpflg        like  datmfnrsrv.libcrpflg        , # 15
       segflcprngracod  like  datmfnrsrv.segflcprngracod  , # 16
       flcalt           like  datmfnrsrv.flcalt           , # 17
       flcpso           like  datmfnrsrv.flcpso           , # 18
       crpretlclcod     like  datmfnrsrv.crpretlclcod     , # 19
       lgdnom           like  datmlcl.lgdnom              , # 20
       lclbrrnom        like  datmlcl.lclbrrnom           , # 21
       cidnom           like  datmlcl.cidnom              , # 22
       ufdcod           like  datmlcl.ufdcod              , # 23
       endcmp           like  datmlcl.endcmp              , # 24
       lclrefptotxt     like  datmlcl.lclrefptotxt        , # 25
       endzon           like  datmlcl.endzon              , # 26
       velflg           like  datmfnrsrv.velflg           , # 27
       fnrtip           like  datmfnrsrv.fnrtip           , # 28
       jzgflg           like  datmfnrsrv.jzgflg           , # 29
       frnasivlr        like  datmfnrsrv.frnasivlr        , # 30
       atdlibflg        like  datmservico.atdlibflg       , # 31
       atdprscod        like  datmservico.atdprscod       , # 32
       atddat           like  datmservico.atddat          , # 33
       pgtdat           like  datmservico.pgtdat          , # 34
       atdcstvlr        like  datmservico.atdcstvlr       , # 35
       c24endtip        like  datmlcl.c24endtip
end record

define mr_iddkdominio record
       segdclprngrades  like iddkdominio.cpodes,  # 9
       mrtcaudes        like iddkdominio.cpodes,  # 14
       segflcprngrades  like iddkdominio.cpodes,  # 16
       crpretlcldes	    like iddkdominio.cpodes,  # 19
       fnrtipdes        like iddkdominio.cpodes,  # 28
       nomgrr           like dpaksocor.nomgrr     # 32
end record



main

   initialize mr_bdbsr133.*,
              mr_iddkdominio.*,
              m_data,
              m_data_inicio,
              m_data_fim,
              m_hora        to null


   let m_data = arg_val(1)

   # ---> OBTER A DATA E HORA DO BANCO
   if m_data is null then
      call cts40g03_data_hora_banco(2)
      returning m_data,
                m_hora

      let m_data_fim = mdy(month(m_data),01,year(m_data)) - 1 units day
      let m_data_inicio = mdy(month(m_data_fim),01,year(m_data_fim))
   else
      let m_data_inicio = mdy(month(m_data),01,year(m_data))
      let m_data_fim = mdy(month(m_data),01,year(m_data)) + 1 units month - 1 units day
   end if


   call fun_dba_abre_banco("CT24HS")
   call cts40g03_exibe_info("I","BDBSR133")
   call bdbsr133_busca_path()
   call bdbsr133_prepare()
   display ""
   set isolation to dirty read
   call bdbsr133()
   call cts40g03_exibe_info("F","BDBSR133")



end main


#--------------------------
function bdbsr133_prepare()
#--------------------------

   define l_sql char(2000)
   # filtro por data de pagamento
   let l_sql =  "select a.atdsrvnum,          ", # 1
                "       a.atdsrvano,          ", # 2
                "       b.succod,             ", # 3
                "       b.ramcod,             ", # 4
                "       b.aplnumdig,          ", # 5
                "       b.itmnumdig,          ", # 6
                "       b.edsnumref,          ", # 7
                "       a.c24solnom,          ", # 8
                "       c.segdclprngracod,    ", # 9
                "       c.cttteltxt,          ", # 10
                "       c.flcnom,             ", # 11
                "       c.flcidd,             ", # 12
                "       c.obtdat,             ", # 13
                "       c.mrtcaucod,          ", # 14
                "       c.libcrpflg,          ", # 15
                "       c.segflcprngracod,    ", # 16
                "       c.flcalt,             ", # 17
                "       c.flcpso,             ", # 18
                "       c.crpretlclcod,       ", # 19
                "       d.lgdnom,             ", # 20
                "       d.lclbrrnom,          ", # 21
                "       d.cidnom,             ", # 22
                "       d.ufdcod,             ", # 23
                "       d.endcmp,             ", # 24
                "       d.lclrefptotxt,       ", # 25
                "       d.endzon,             ", # 26
                "       d.c24endtip,          ",
                "       c.velflg,             ", # 27
                "       c.fnrtip,             ", # 28
                "       c.jzgflg,             ", # 29
                "       c.frnasivlr,          ", # 30
                "       a.atdlibflg,          ", # 31
                "       a.atdprscod,          ", # 32
                "       a.atddat,             ", # 33
                "       a.pgtdat,             ", # 34
                "       a.atdcstvlr           ", # 35
                "  from datmservico a,        ",
                "       outer datrservapol b, ",
                "       datmfnrsrv c,         ",
                "       datmlcl d             ",
                "  where a.atdsrvnum = b.atdsrvnum ",
                "    and a.atdsrvano = b.atdsrvano ",
                "    and a.atdsrvnum = c.atdsrvnum ",
                "    and a.atdsrvano = c.atdsrvano ",
                "    and a.atdsrvnum = d.atdsrvnum ",
                "    and a.atdsrvano = d.atdsrvano ",
                "    and a.pgtdat between ? and ?  "
        prepare pbdbsr133_01 from l_sql
        declare cbdbsr133_01 cursor for pbdbsr133_01

   #Query para procurar descricao na tabela iddkdominio
   let l_sql = " select cpodes      ",
   	       "   from iddkdominio ",
   	       "  where cponom = ?  ",
   	       "    and cpocod = ?  "

   	prepare pbdbsr133_02 from l_sql
	declare cbdbsr133_02 cursor for pbdbsr133_02

   #Query para procurar o nome de guerra do prestador
   let l_sql = " select nomgrr        ",
               "   from dpaksocor     ",
               "  where pstcoddig = ? "

	prepare pbdbsr133_03 from l_sql
	declare cbdbsr133_03 cursor for pbdbsr133_03

   # Filtro por data de atendimento
   let l_sql =  "select a.atdsrvnum,          ", # 1
                "       a.atdsrvano,          ", # 2
                "       b.succod,             ", # 3
                "       b.ramcod,             ", # 4
                "       b.aplnumdig,          ", # 5
                "       b.itmnumdig,          ", # 6
                "       b.edsnumref,          ", # 7
                "       a.c24solnom,          ", # 8
                "       c.segdclprngracod,    ", # 9
                "       c.cttteltxt,          ", # 10
                "       c.flcnom,             ", # 11
                "       c.flcidd,             ", # 12
                "       c.obtdat,             ", # 13
                "       c.mrtcaucod,          ", # 14
                "       c.libcrpflg,          ", # 15
                "       c.segflcprngracod,    ", # 16
                "       c.flcalt,             ", # 17
                "       c.flcpso,             ", # 18
                "       c.crpretlclcod,       ", # 19
                "       d.lgdnom,             ", # 20
                "       d.lclbrrnom,          ", # 21
                "       d.cidnom,             ", # 22
                "       d.ufdcod,             ", # 23
                "       d.endcmp,             ", # 24
                "       d.lclrefptotxt,       ", # 25
                "       d.endzon,             ", # 26
                "       d.c24endtip,          ",
                "       c.velflg,             ", # 27
                "       c.fnrtip,             ", # 28
                "       c.jzgflg,             ", # 29
                "       c.frnasivlr,          ", # 30
                "       a.atdlibflg,          ", # 31
                "       a.atdprscod,          ", # 32
                "       a.atddat,             ", # 33
                "       a.pgtdat,             ", # 34
                "       a.atdcstvlr           ", # 35
                "  from datmservico a,        ",
                "       outer datrservapol b, ",
                "       datmfnrsrv c,         ",
                "       datmlcl d             ",
                "  where a.atdsrvnum = b.atdsrvnum ",
                "    and a.atdsrvano = b.atdsrvano ",
                "    and a.atdsrvnum = c.atdsrvnum ",
                "    and a.atdsrvano = c.atdsrvano ",
                "    and a.atdsrvnum = d.atdsrvnum ",
                "    and a.atdsrvano = d.atdsrvano ",
                "    and a.atddat between ? and ?  "
     prepare pbdbsr133_04 from l_sql
     declare cbdbsr133_04 cursor for pbdbsr133_04

end function


#----------------------
function bdbsr133()
#----------------------

   define l_mdtbotprgseq char (100),
          l_sql          char(1000),
          l_indice       smallint



   start report bdbsr133_relatorio to m_path2
   start report bdbsr133_relatorio_txt to m_path2_txt
      whenever error continue

      open cbdbsr133_01  using m_data_inicio,
                              m_data_fim
   
      foreach cbdbsr133_01 into mr_bdbsr133.atdsrvnum       , # 1
                                mr_bdbsr133.atdsrvano       , # 2
                                mr_bdbsr133.succod          , # 3
                                mr_bdbsr133.ramcod          , # 4
                                mr_bdbsr133.aplnumdig       , # 5
                                mr_bdbsr133.itmnumdig       , # 6
                                mr_bdbsr133.edsnumref       , # 7
                                mr_bdbsr133.c24solnom       , # 8
                                mr_bdbsr133.segdclprngracod , # 9
                                mr_bdbsr133.cttteltxt       , # 10
                                mr_bdbsr133.flcnom          , # 11
                                mr_bdbsr133.flcidd          , # 12
                                mr_bdbsr133.obtdat          , # 13
                                mr_bdbsr133.mrtcaucod       , # 14
                                mr_bdbsr133.libcrpflg       , # 15
                                mr_bdbsr133.segflcprngracod , # 16
                                mr_bdbsr133.flcalt          , # 17
                                mr_bdbsr133.flcpso          , # 18
                                mr_bdbsr133.crpretlclcod    , # 19
                                mr_bdbsr133.lgdnom          , # 20
                                mr_bdbsr133.lclbrrnom       , # 21
                                mr_bdbsr133.cidnom          , # 22
                                mr_bdbsr133.ufdcod          , # 23
                                mr_bdbsr133.endcmp          , # 24
                                mr_bdbsr133.lclrefptotxt    , # 25
                                mr_bdbsr133.endzon          , # 26
                                mr_bdbsr133.velflg          , # 27
                                mr_bdbsr133.fnrtip          , # 28
                                mr_bdbsr133.jzgflg          , # 29
                                mr_bdbsr133.frnasivlr       , # 30
                                mr_bdbsr133.atdlibflg       , # 31
                                mr_bdbsr133.atdprscod       , # 32
                                mr_bdbsr133.atddat          , # 33
                                mr_bdbsr133.pgtdat          , # 34
                                mr_bdbsr133.atdcstvlr         # 35
   
         call bdbsr133_busca_dominio()
   
   
         output to report bdbsr133_relatorio()
         output to report bdbsr133_relatorio_txt()
   
   
         initialize mr_bdbsr133.*,
                    mr_iddkdominio.* to null
   
   
      end foreach
   
   
      whenever error stop
   
   finish report bdbsr133_relatorio
   finish report bdbsr133_relatorio_txt
   
   call bdbsr133_envia_email(m_data_inicio, m_data_fim, 2, m_path2) #pagamento

   #
   start report bdbsr133_relatorio to m_path
   start report bdbsr133_relatorio_txt to m_path_txt
      whenever error continue

      open cbdbsr133_04  using m_data_inicio,
                              m_data_fim

      foreach cbdbsr133_04 into mr_bdbsr133.atdsrvnum       , # 1
                                mr_bdbsr133.atdsrvano       , # 2
                                mr_bdbsr133.succod          , # 3
                                mr_bdbsr133.ramcod          , # 4
                                mr_bdbsr133.aplnumdig       , # 5
                                mr_bdbsr133.itmnumdig       , # 6
                                mr_bdbsr133.edsnumref       , # 7
                                mr_bdbsr133.c24solnom       , # 8
                                mr_bdbsr133.segdclprngracod , # 9
                                mr_bdbsr133.cttteltxt       , # 10
                                mr_bdbsr133.flcnom          , # 11
                                mr_bdbsr133.flcidd          , # 12
                                mr_bdbsr133.obtdat          , # 13
                                mr_bdbsr133.mrtcaucod       , # 14
                                mr_bdbsr133.libcrpflg       , # 15
                                mr_bdbsr133.segflcprngracod , # 16
                                mr_bdbsr133.flcalt          , # 17
                                mr_bdbsr133.flcpso          , # 18
                                mr_bdbsr133.crpretlclcod    , # 19
                                mr_bdbsr133.lgdnom          , # 20
                                mr_bdbsr133.lclbrrnom       , # 21
                                mr_bdbsr133.cidnom          , # 22
                                mr_bdbsr133.ufdcod          , # 23
                                mr_bdbsr133.endcmp          , # 24
                                mr_bdbsr133.lclrefptotxt    , # 25
                                mr_bdbsr133.endzon          , # 26
                                mr_bdbsr133.c24endtip       ,
                                mr_bdbsr133.velflg          , # 27
                                mr_bdbsr133.fnrtip          , # 28
                                mr_bdbsr133.jzgflg          , # 29
                                mr_bdbsr133.frnasivlr       , # 30
                                mr_bdbsr133.atdlibflg       , # 31
                                mr_bdbsr133.atdprscod       , # 32
                                mr_bdbsr133.atddat          , # 33
                                mr_bdbsr133.pgtdat          , # 34
                                mr_bdbsr133.atdcstvlr         # 35

         call bdbsr133_busca_dominio()


         output to report bdbsr133_relatorio()
         output to report bdbsr133_relatorio_txt()


         initialize mr_bdbsr133.*,
                    mr_iddkdominio.* to null


      end foreach


      whenever error stop

   finish report bdbsr133_relatorio
   finish report bdbsr133_relatorio_txt

   call bdbsr133_envia_email(m_data_inicio, m_data_fim, 1, m_path)



end function


#---------------------------------------
function bdbsr133_busca_dominio()
#---------------------------------------
  define l_dominio  record
          datmfuneral   like iddkdominio.cpodes,
          c24caumrt     like iddkdominio.cpodes,
          c24lclret     like iddkdominio.cpodes,
          c24fnrtip     like iddkdominio.cpodes
   end record

   let l_dominio.datmfuneral = "datmfuneral"
   let l_dominio.c24caumrt   = "c24caumrt"
   let l_dominio.c24lclret   = "c24lclret"
   let l_dominio.c24fnrtip   = "c24fnrtip"

  #9 -Grau de Paretesco com o declarante
  open cbdbsr133_02 using l_dominio.datmfuneral,
                          mr_bdbsr133.segdclprngracod

    fetch cbdbsr133_02 into mr_iddkdominio.segdclprngrades
  close cbdbsr133_02

  #14 - Causa da Morte
  open cbdbsr133_02 using l_dominio.c24caumrt,
                          mr_bdbsr133.mrtcaucod

    fetch cbdbsr133_02 into mr_iddkdominio.mrtcaudes
  close cbdbsr133_02

  #16 - Grau de Parentesco com o Segurado
  open cbdbsr133_02 using l_dominio.datmfuneral,
                          mr_bdbsr133.segflcprngracod

    fetch cbdbsr133_02 into mr_iddkdominio.segflcprngrades
  close cbdbsr133_02

  #19 - Local de retirada do corpo
  open cbdbsr133_02 using l_dominio.c24lclret,
                          mr_bdbsr133.crpretlclcod

    fetch cbdbsr133_02 into mr_iddkdominio.crpretlcldes
  close cbdbsr133_02

  #28 - Tipo de Funeral
  open cbdbsr133_02 using l_dominio.c24fnrtip,
                          mr_bdbsr133.fnrtip

    fetch cbdbsr133_02 into mr_iddkdominio.fnrtipdes
  close cbdbsr133_02

  #32 - Prestador
  open cbdbsr133_03 using mr_bdbsr133.atdprscod

    fetch cbdbsr133_03 into mr_iddkdominio.nomgrr
  close cbdbsr133_03

end function

#-----------------------------------
function bdbsr133_troca_ponto(param)
#-----------------------------------
   define param record
     valor like datmservico.atdcstvlr
   end record

   define l_char char(15),
          l_i    smallint

   let l_char = param.valor

   for l_i = 1 to 15 step 1

     if l_char[l_i] = "." then
        let l_char[l_i] = ","
     end if

   end for

   return l_char

end function




#-------------------------------------#
report bdbsr133_relatorio()
#-------------------------------------#


  define l_char char(15),
         l_peso char(9),
         l_altu char(6),
         l_i    smallint


  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header


        print "SERVI�O"                                 , ASCII(09), # 1
              "ANO"                                     , ASCII(09), # 2
              "SUCURSAL"                                , ASCII(09), # 3
              "RAMO"                                    , ASCII(09), # 4
              "AP�LICE"                                 , ASCII(09), # 5
              "ITEM"                                    , ASCII(09), # 6
              "ENDOSSO"                                 , ASCII(09), # 7
              "SOLICITANTE"                             , ASCII(09), # 8
              "PARENTESCO_DO_DECLARANTE_COM_O_SEGURADO" , ASCII(09), # 9
              "TELEFONE"                                , ASCII(09), # 10
              "FALECIDO"                                , ASCII(09), # 11
              "IDADE"                                   , ASCII(09), # 12
              "DATA DO �BITO"                           , ASCII(09), # 13
              "CAUSA_DA_MORTE"                          , ASCII(09), # 14
              "CORPO_LIBERADO?"                         , ASCII(09), # 15
              "PARENTESCO COM O SEGURADO"               , ASCII(09), # 16
              "ALTURA"                                  , ASCII(09), # 17
              "PESO"                                    , ASCII(09), # 18
              "LOCAL_DE_RETIRADA_DO_CORPO"              , ASCII(09), # 19
              "LOGRADOURO"                              , ASCII(09), # 20
              "BAIRRO"                                  , ASCII(09), # 21
              "CIDADE"                                  , ASCII(09), # 22
              "UF"                                      , ASCII(09), # 23
              "COMPLEMENTO"                             , ASCII(09), # 24
              "PONTO_DE_REFERENCIA"                     , ASCII(09), # 25
              "ZONA"                                    , ASCII(09), # 26
              "HAVER�_VEL�RIO?"                         , ASCII(09), # 27
              "FUNERAL"                                 , ASCII(09), # 28
              "POSSUI_JAZIGO?"                          , ASCII(09), # 29
              "VALOR DA ASSISTENCIA"                    , ASCII(09), # 30
              "SERV,LIB"                                , ASCII(09), # 31
              "PRESTADOR"                               , ASCII(09), # 32
              "DATA_DO_ATENDIMENTO"                     , ASCII(09), # 33
              "DATA_DO_PAGAMENTO"                       , ASCII(09), # 34
              "CUSTO_DO_SERVI�O"                                     # 35


  on every row


     print mr_bdbsr133.atdsrvnum                        , ASCII(09);  # 1
     print mr_bdbsr133.atdsrvano                        , ASCII(09);  # 2
     print mr_bdbsr133.succod                           , ASCII(09);  # 3
     print mr_bdbsr133.ramcod                           , ASCII(09);  # 4
     print mr_bdbsr133.aplnumdig                        , ASCII(09);  # 5
     print mr_bdbsr133.itmnumdig                        , ASCII(09);  # 6
     print mr_bdbsr133.edsnumref                        , ASCII(09);  # 7
     print mr_bdbsr133.c24solnom                        , ASCII(09);  # 8
     print mr_bdbsr133.segdclprngracod using "<<<" clipped,
           "-", mr_iddkdominio.segdclprngrades  clipped , ASCII(09);  # 9
     print mr_bdbsr133.cttteltxt                        , ASCII(09);  # 10
     print mr_bdbsr133.flcnom                           , ASCII(09);  # 11
     print mr_bdbsr133.flcidd                           , ASCII(09);  # 12
     print mr_bdbsr133.obtdat                           , ASCII(09);  # 13
     print mr_bdbsr133.mrtcaucod using "<<<" clipped, "-",
           mr_iddkdominio.mrtcaudes clipped             , ASCII(09);  # 14
     print mr_bdbsr133.libcrpflg                        , ASCII(09);  # 15
     print mr_bdbsr133.segflcprngracod using "<<<" clipped, "-",
           mr_iddkdominio.segflcprngrades clipped       , ASCII(09);  # 16

     let l_altu = mr_bdbsr133.flcalt
     for l_i = 1 to 6 step 1
       if l_altu[l_i] = "." then
         let l_altu[l_i] = ","
         exit for
       end if

     end for

     let l_peso = mr_bdbsr133.flcpso
     for l_i = 1 to 9 step 1
       if l_peso[l_i] = "." then
         let l_peso[l_i] = ","
         exit for
       end if

     end for

     print l_altu clipped                               , ASCII(09);  # 17
     print l_peso clipped                               , ASCII(09);  # 18


     print mr_bdbsr133.crpretlclcod using "<<<" clipped, "-",
           mr_iddkdominio.crpretlcldes clipped          , ASCII(09);  # 19
     print mr_bdbsr133.lgdnom                           , ASCII(09);  # 20
     print mr_bdbsr133.lclbrrnom                        , ASCII(09);  # 21
     print mr_bdbsr133.cidnom                           , ASCII(09);  # 22
     print mr_bdbsr133.ufdcod                           , ASCII(09);  # 23
     print mr_bdbsr133.endcmp                           , ASCII(09);  # 24
     print mr_bdbsr133.lclrefptotxt                     , ASCII(09);  # 25
     print mr_bdbsr133.endzon                           , ASCII(09);  # 26
     print mr_bdbsr133.velflg                           , ASCII(09);  # 27
     print mr_bdbsr133.fnrtip using "<<<"clipped, "-",
           mr_iddkdominio.fnrtipdes clipped             , ASCII(09);  # 28
     print mr_bdbsr133.jzgflg                           , ASCII(09);  # 29
     print mr_bdbsr133.frnasivlr                        , ASCII(09);  # 30
     print mr_bdbsr133.atdlibflg                        , ASCII(09);  # 31
     print mr_bdbsr133.atdprscod using "<<<<<<" clipped,"-",
           mr_iddkdominio.nomgrr clipped                , ASCII(09);  # 32
     print mr_bdbsr133.atddat                           , ASCII(09);  # 33
     print mr_bdbsr133.pgtdat                           , ASCII(09);  # 34

     call bdbsr133_troca_ponto(mr_bdbsr133.atdcstvlr)
       returning l_char
     print l_char clipped                                     # 35


end report

#-----------------------------
function bdbsr133_calcula_datafim(l_data)
#-----------------------------
   define l_data date

   let l_data = l_data + 1 units month - 1 units day

   return l_data

end function

#-----------------------------
function bdbsr133_busca_path()
#-----------------------------

   define l_dataarq char(8)
   define l_data    date
   
   let l_data = today
   display "l_data: ", l_data
   let l_dataarq = extend(l_data, year to year),
                   extend(l_data, month to month),
                   extend(l_data, day to day)
   display "l_dataarq: ", l_dataarq

   # ---> INICIALIZACAO DAS VARIAVEIS
   let m_path = null

   # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
   let m_path = f_path("DBS","LOG") 
   
   let m_path2 = f_path("DBS","LOG")

   if m_path is null then
      let m_path = "."
   end if

   if m_path2 is null then
      let m_path2 = "."
   end if

   let m_path = m_path clipped, "/BDBSR133_Atendimento.log"  #cursor 04
   call startlog(m_path)

   
   let m_path2 = m_path2 clipped, "/BDBSR133_Pagamento.log"   #cursor 01
   call startlog(m_path2)                                     

   # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
   let m_path = f_path("DBS", "RELATO")

   let m_path2 = f_path("DBS", "RELATO")

   if m_path is null then
      let m_path = "."
   end if

   if m_path2 is null then
      let m_path2 = "."
   end if
   
   let m_path_txt = m_path clipped, "/BDBSR133_Atendimento_", l_dataarq, ".txt"   
   let m_path2_txt = m_path2 clipped, "/BDBSR133_Pagamento_", l_dataarq, ".txt"   

   let m_path = m_path clipped, "/BDBSR133_Atendimento.xls"
   let m_path2 = m_path2 clipped, "/BDBSR133_Pagamento.xls"

end function


#-----------------------------------------#
function bdbsr133_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         data_inicial date,
         data_final   date,
         tipo         smallint,
         path         char(100)
  end record

  define l_assunto     char(100),
         l_erro_envio  integer,
         l_comando     char(200),
         l_tipo        char(15)

  # ---> INICIALIZACAO DAS VARIAVEIS
  if lr_parametro.tipo = 1 then
    let l_tipo = 'Atendimento'
  else
    let l_tipo = 'Pagamento'
  end if

  let l_comando    = null
  let l_erro_envio = null
  let l_assunto    = "Relatorio de Servico de Assistencia Funeraria  - ",
                     "Filtro por data de ",
                     l_tipo clipped,
                     " do mes: ",
                     month(lr_parametro.data_inicial),
                     "/", year(lr_parametro.data_inicial)

  # ---> COMPACTA O ARQUIVO DO RELATORIO
  let l_comando = "gzip -f ", lr_parametro.path

  run l_comando
  let lr_parametro.path = lr_parametro.path clipped, ".gz"

  let l_erro_envio = ctx22g00_envia_email("BDBSR133", l_assunto, lr_parametro.path)

  if l_erro_envio <> 0 then
     if l_erro_envio <> 99 then
        display "Erro ao enviar email(ctx22g00) - ", m_path
     else
        display "Nao existe email cadastrado para o modulo - BDBSR133"
     end if
  end if

end function

#-------------------------------------#
report bdbsr133_relatorio_txt()
#-------------------------------------#


  define l_char char(15),
         l_peso char(9),
         l_altu char(6),
         l_i    smallint


  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    01

  format

     on every row


     print mr_bdbsr133.atdsrvnum                        , ASCII(09);  # 1
     print mr_bdbsr133.atdsrvano                        , ASCII(09);  # 2
     print mr_bdbsr133.succod                           , ASCII(09);  # 3
     print mr_bdbsr133.ramcod                           , ASCII(09);  # 4
     print mr_bdbsr133.aplnumdig                        , ASCII(09);  # 5
     print mr_bdbsr133.itmnumdig                        , ASCII(09);  # 6
     print mr_bdbsr133.edsnumref                        , ASCII(09);  # 7
     print mr_bdbsr133.c24solnom                        , ASCII(09);  # 8
     print mr_bdbsr133.segdclprngracod using "<<<" clipped,
           "-", mr_iddkdominio.segdclprngrades  clipped , ASCII(09);  # 9
     print mr_bdbsr133.cttteltxt                        , ASCII(09);  # 10
     print mr_bdbsr133.flcnom                           , ASCII(09);  # 11
     print mr_bdbsr133.flcidd                           , ASCII(09);  # 12
     print mr_bdbsr133.obtdat                           , ASCII(09);  # 13
     print mr_bdbsr133.mrtcaucod using "<<<" clipped, "-",
           mr_iddkdominio.mrtcaudes clipped             , ASCII(09);  # 14
     print mr_bdbsr133.libcrpflg                        , ASCII(09);  # 15
     print mr_bdbsr133.segflcprngracod using "<<<" clipped, "-",
           mr_iddkdominio.segflcprngrades clipped       , ASCII(09);  # 16

     let l_altu = mr_bdbsr133.flcalt
     for l_i = 1 to 6 step 1
       if l_altu[l_i] = "." then
         let l_altu[l_i] = ","
         exit for
       end if

     end for

     let l_peso = mr_bdbsr133.flcpso
     for l_i = 1 to 9 step 1
       if l_peso[l_i] = "." then
         let l_peso[l_i] = ","
         exit for
       end if

     end for

     print l_altu clipped                               , ASCII(09);  # 17
     print l_peso clipped                               , ASCII(09);  # 18


     print mr_bdbsr133.crpretlclcod using "<<<" clipped, "-",
           mr_iddkdominio.crpretlcldes clipped          , ASCII(09);  # 19
     print mr_bdbsr133.lgdnom                           , ASCII(09);  # 20
     print mr_bdbsr133.lclbrrnom                        , ASCII(09);  # 21
     print mr_bdbsr133.cidnom                           , ASCII(09);  # 22
     print mr_bdbsr133.ufdcod                           , ASCII(09);  # 23
     print mr_bdbsr133.endcmp                           , ASCII(09);  # 24
     print mr_bdbsr133.lclrefptotxt                     , ASCII(09);  # 25
     print mr_bdbsr133.endzon                           , ASCII(09);  # 26
     print mr_bdbsr133.c24endtip                        , ASCII(09);
     print mr_bdbsr133.velflg                           , ASCII(09);  # 27
     print mr_bdbsr133.fnrtip using "<<<"clipped, "-",
           mr_iddkdominio.fnrtipdes clipped             , ASCII(09);  # 28
     print mr_bdbsr133.jzgflg                           , ASCII(09);  # 29
     print mr_bdbsr133.frnasivlr                        , ASCII(09);  # 30
     print mr_bdbsr133.atdlibflg                        , ASCII(09);  # 31
     print mr_bdbsr133.atdprscod using "<<<<<<" clipped,"-",
           mr_iddkdominio.nomgrr clipped                , ASCII(09);  # 32
     print mr_bdbsr133.atddat                           , ASCII(09);  # 33
     print mr_bdbsr133.pgtdat                           , ASCII(09);  # 34

     call bdbsr133_troca_ponto(mr_bdbsr133.atdcstvlr)
       returning l_char
     print l_char clipped                                             # 35
     display mr_bdbsr133.atdsrvnum, "/",mr_bdbsr133.atdsrvano
     display "mr_bdbsr133.atdcstvlr: ", mr_bdbsr133.atdcstvlr
     display "l_char: ", l_char

end report