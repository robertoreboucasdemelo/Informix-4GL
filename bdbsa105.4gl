#-----------------------------------------------------------------------------#
# Sistema....: Porto Socorro                                                  #
# Modulo.....: bdbsa105                                                       #
# Analista Resp.: Robert Lima                                                 #
# PSI......: 215627 - Relatorio/Arquivo de serivços acionados Azul            #
#                     carga: Arquivo txt                                      #
#                     res  : Documento com resumo de serivços acionados       #
# --------------------------------------------------------------------------- #
# Desenvolvimento: Robert Lima                                                #
# Liberacao...: 16/03/2011                                                    #
# --------------------------------------------------------------------------- #
#                                 Alteracoes                                  #
# --------------------------------------------------------------------------- #
# Data        Autor           Origem     Alteracao                            #
# ----------  --------------  ---------- -------------------------------------#
#-----------------------------------------------------------------------------#

database porto

define m_data      char(10)
      ,m_path      char(100)
      ,m_pathdoc   char(100)
      ,m_pathtxt   char(100)
      ,m_pathdoc2  char(100)
      ,m_pathtxt2  char(100)

main

 define l_sql      char(400)
       ,l_hostname char(8)
       ,l_count    smallint
       ,l_comando  char(200)
       ,l_retorno  smallint
       ,l_hora     datetime hour to fraction
       ,l_data     date

 define d_bdbsa105 record
     aplnumdig like datrservapol.aplnumdig
    ,succod    like datrservapol.succod
    ,ramcod    like datrservapol.ramcod
    ,atdetpdat like datmsrvacp.atdetpdat
    ,asitipcod like datmservico.asitipcod
    ,atdsrvnum like datmservico.atdsrvnum
    ,atdsrvano like datmservico.atdsrvano
    ,atdetpcod like datmsrvacp.atdetpcod
 end record

 define lr_qtdeetpquatro  smallint
 define lr_qtdeetpcinco   smallint
 define lr_setetpquatro   like datmsrvacp.atdsrvseq
 define lr_setetpcinco    like datmsrvacp.atdsrvseq

 call fun_dba_abre_banco("CT24HS")

 initialize m_data
           ,m_path
           ,m_pathdoc
           ,m_pathtxt
           ,m_pathdoc2
           ,m_pathtxt2 to null

 initialize  l_sql
            ,l_hostname
            ,l_count
            ,l_comando
            ,l_retorno
            ,l_hora
            ,l_data to null

 initialize d_bdbsa105.* to null

 initialize lr_qtdeetpquatro
           ,lr_qtdeetpcinco
           ,lr_setetpquatro
           ,lr_setetpcinco to null

 let m_path = f_path("DBS", "ARQUIVO")

 if m_path is null or m_path = ' ' then
    let m_path = '.'
 end if

 let m_data = arg_val(1)
 if m_data is null or m_data = " " then
     let m_data = today - 1 units day
     let m_data = m_data[9,10],"/",m_data[6,7],"/",m_data[1,4]
 end if

 let l_count = 0
 let lr_qtdeetpquatro = 0
 let lr_qtdeetpcinco = 0

 display 'Data processada.....: ', m_data

 let m_pathtxt  = m_path clipped,"/AZUL_ACN_", m_data[7,10], m_data[4,5], m_data[1,2],".txt"
 let m_pathdoc  = m_path clipped,"/AZUL_ACN_", m_data[7,10], m_data[4,5], m_data[1,2],".doc"
 let m_pathtxt2 = m_path clipped,"/AZUL_ACN_2_", m_data[7,10], m_data[4,5], m_data[1,2],".txt"
 let m_pathdoc2 = m_path clipped,"/AZUL_ACN_2_", m_data[7,10], m_data[4,5], m_data[1,2],".doc"

 display 'Arquivos:', m_path     clipped
 display '         ', m_pathtxt  clipped
 display '         ', m_pathdoc  clipped
 display '         ', m_pathtxt2 clipped
 display '         ', m_pathdoc2 clipped

 select sitename into l_hostname  from dual

 #-------------
 # Prepare
 #-------------

 let l_sql = " select asitipdes "
           , " from datkasitip  "
           , " where asitipcod = ? "
 prepare pbdbsa105001 from l_sql
 declare cbdbsa105001 cursor with hold for pbdbsa105001


 start report bdbsa105_carga_azul to m_pathtxt
 start report bdbsa105_res_azul   to m_pathdoc

 start report bdbsa105_carga_azulgz to m_pathtxt2
 start report bdbsa105_res_azulgz   to m_pathdoc2

  declare cbdbsa105002 cursor with hold for
		      select a.atdsrvnum
		            ,a.atdsrvano
					      ,b.aplnumdig
					      ,b.succod
					      ,b.ramcod
					      ,c.atdetpdat
					      ,a.asitipcod
					      ,c.atdetpcod
					  from datmservico a
					      ,datrservapol b
					      ,datmsrvacp c
					 where a.atdsrvnum = c.atdsrvnum
					   and a.atdsrvano = c.atdsrvano
					   and a.atdsrvnum = b.atdsrvnum
					   and a.atdsrvano = b.atdsrvano
					   and c.atdsrvseq = (select min(d.atdsrvseq)
					                        from datmsrvacp d
					                        where d.atdsrvnum = a.atdsrvnum
					                          and d.atdsrvano = a.atdsrvano
					                          and d.atdetpcod in (3,4,5))
					   and c.atdetpdat = m_data
					   and a.ciaempcod = 35
					 order by 1

 let l_hora = current
 display 'Hora do inicio do processamento: ', l_hora

 foreach cbdbsa105002 into d_bdbsa105.atdsrvnum,
                           d_bdbsa105.atdsrvano,
                           d_bdbsa105.aplnumdig,
                           d_bdbsa105.succod,
                           d_bdbsa105.ramcod,
                           d_bdbsa105.atdetpdat,
                           d_bdbsa105.asitipcod,
                           d_bdbsa105.atdetpcod

     let l_count = l_count + 1

             display '----------------------------------------------------------------'
             display 'd_bdbsa105.aplnumdig = ',d_bdbsa105.aplnumdig
             display 'd_bdbsa105.succod    = ',d_bdbsa105.succod
             display 'd_bdbsa105.ramcod    = ',d_bdbsa105.ramcod
             display 'd_bdbsa105.atdetpdat = ',d_bdbsa105.atdetpdat
             display 'd_bdbsa105.asitipcod = ',d_bdbsa105.asitipcod
             display 'd_bdbsa105.atdsrvnum = ',d_bdbsa105.atdsrvnum
             display 'd_bdbsa105.atdetpcod = ',d_bdbsa105.atdetpcod

             output to report bdbsa105_carga_azul(d_bdbsa105.aplnumdig,
                                                  d_bdbsa105.succod,
                                                  d_bdbsa105.ramcod,
                                                  d_bdbsa105.atdetpdat,
                                                  d_bdbsa105.asitipcod,
                                                  d_bdbsa105.atdsrvnum,
                                                  d_bdbsa105.atdetpcod,
                                                  l_count)

             output to report bdbsa105_res_azul(d_bdbsa105.aplnumdig,
                                                d_bdbsa105.succod,
                                                d_bdbsa105.ramcod,
                                                d_bdbsa105.atdetpdat,
                                                d_bdbsa105.asitipcod,
                                                d_bdbsa105.atdsrvnum,
                                                l_count)

             output to report bdbsa105_carga_azulgz(d_bdbsa105.aplnumdig,
                                                    d_bdbsa105.succod,
                                                    d_bdbsa105.ramcod,
                                                    d_bdbsa105.atdetpdat,
                                                    d_bdbsa105.asitipcod,
                                                    d_bdbsa105.atdsrvnum,
                                                    d_bdbsa105.atdetpcod,
                                                    l_count)

             output to report bdbsa105_res_azulgz(d_bdbsa105.aplnumdig,
                                                  d_bdbsa105.succod,
                                                  d_bdbsa105.ramcod,
                                                  d_bdbsa105.atdetpdat,
                                                  d_bdbsa105.asitipcod,
                                                  d_bdbsa105.atdsrvnum,
                                                  l_count)

     whenever error continue
       select count(*)
         into lr_qtdeetpcinco
         from datmsrvacp
        where atdsrvnum = d_bdbsa105.atdsrvnum
          and atdsrvano = d_bdbsa105.atdsrvano
          and atdetpcod = 5
          and atdetpdat = m_data
     whenever error stop

     if lr_qtdeetpcinco > 0 then

        display "Servico ", d_bdbsa105.atdsrvnum, "/", d_bdbsa105.atdsrvano
               ," possui ", lr_qtdeetpcinco, " etapas 5"

        select atdetpcod, atdetpdat, max(atdsrvseq)
          into d_bdbsa105.atdetpcod, d_bdbsa105.atdetpdat, lr_setetpcinco
          from datmsrvacp
         where atdsrvnum = d_bdbsa105.atdsrvnum
           and atdsrvano = d_bdbsa105.atdsrvano
           and atdetpcod = 5
           and atdetpdat = m_data
         group by 1,2

         display '----------------------------------------------------------------'
         display 'd_bdbsa105.aplnumdig = ',d_bdbsa105.aplnumdig
         display 'd_bdbsa105.succod    = ',d_bdbsa105.succod
         display 'd_bdbsa105.ramcod    = ',d_bdbsa105.ramcod
         display 'd_bdbsa105.atdetpdat = ',d_bdbsa105.atdetpdat
         display 'd_bdbsa105.asitipcod = ',d_bdbsa105.asitipcod
         display 'd_bdbsa105.atdsrvnum = ',d_bdbsa105.atdsrvnum
         display 'd_bdbsa105.atdetpcod = ',d_bdbsa105.atdetpcod

         output to report bdbsa105_carga_azul(d_bdbsa105.aplnumdig,
                                              d_bdbsa105.succod,
                                              d_bdbsa105.ramcod,
                                              d_bdbsa105.atdetpdat,
                                              d_bdbsa105.asitipcod,
                                              d_bdbsa105.atdsrvnum,
                                              d_bdbsa105.atdetpcod,
                                              l_count)

         output to report bdbsa105_res_azul(d_bdbsa105.aplnumdig,
                                            d_bdbsa105.succod,
                                            d_bdbsa105.ramcod,
                                            d_bdbsa105.atdetpdat,
                                            d_bdbsa105.asitipcod,
                                            d_bdbsa105.atdsrvnum,
                                            l_count)

         output to report bdbsa105_carga_azulgz(d_bdbsa105.aplnumdig,
                                                d_bdbsa105.succod,
                                                d_bdbsa105.ramcod,
                                                d_bdbsa105.atdetpdat,
                                                d_bdbsa105.asitipcod,
                                                d_bdbsa105.atdsrvnum,
                                                d_bdbsa105.atdetpcod,
                                                l_count)

         output to report bdbsa105_res_azulgz(d_bdbsa105.aplnumdig,
                                              d_bdbsa105.succod,
                                              d_bdbsa105.ramcod,
                                              d_bdbsa105.atdetpdat,
                                              d_bdbsa105.asitipcod,
                                              d_bdbsa105.atdsrvnum,
                                              l_count)


        select atdetpcod, atdetpdat, max(atdsrvseq)
          into d_bdbsa105.atdetpcod, d_bdbsa105.atdetpdat, lr_setetpquatro
          from datmsrvacp
         where atdsrvnum = d_bdbsa105.atdsrvnum
           and atdsrvano = d_bdbsa105.atdsrvano
           and atdetpcod = 4
           and atdetpdat = m_data
         group by 1,2

          if sqlca.sqlcode = 0 and
             lr_setetpquatro > lr_setetpcinco then

             display '----------------------------------------------------------------'
             display 'd_bdbsa105.aplnumdig = ',d_bdbsa105.aplnumdig
             display 'd_bdbsa105.succod    = ',d_bdbsa105.succod
             display 'd_bdbsa105.ramcod    = ',d_bdbsa105.ramcod
             display 'd_bdbsa105.atdetpdat = ',d_bdbsa105.atdetpdat
             display 'd_bdbsa105.asitipcod = ',d_bdbsa105.asitipcod
             display 'd_bdbsa105.atdsrvnum = ',d_bdbsa105.atdsrvnum
             display 'd_bdbsa105.atdetpcod = ',d_bdbsa105.atdetpcod

             output to report bdbsa105_carga_azul(d_bdbsa105.aplnumdig,
                                                  d_bdbsa105.succod,
                                                  d_bdbsa105.ramcod,
                                                  d_bdbsa105.atdetpdat,
                                                  d_bdbsa105.asitipcod,
                                                  d_bdbsa105.atdsrvnum,
                                                  d_bdbsa105.atdetpcod,
                                                  l_count)

             output to report bdbsa105_res_azul(d_bdbsa105.aplnumdig,
                                                d_bdbsa105.succod,
                                                d_bdbsa105.ramcod,
                                                d_bdbsa105.atdetpdat,
                                                d_bdbsa105.asitipcod,
                                                d_bdbsa105.atdsrvnum,
                                                l_count)

             output to report bdbsa105_carga_azulgz(d_bdbsa105.aplnumdig,
                                                    d_bdbsa105.succod,
                                                    d_bdbsa105.ramcod,
                                                    d_bdbsa105.atdetpdat,
                                                    d_bdbsa105.asitipcod,
                                                    d_bdbsa105.atdsrvnum,
                                                    d_bdbsa105.atdetpcod,
                                                    l_count)

             output to report bdbsa105_res_azulgz(d_bdbsa105.aplnumdig,
                                                  d_bdbsa105.succod,
                                                  d_bdbsa105.ramcod,
                                                  d_bdbsa105.atdetpdat,
                                                  d_bdbsa105.asitipcod,
                                                  d_bdbsa105.atdsrvnum,
                                                  l_count)
          end if
     end if

 end foreach

 finish report bdbsa105_carga_azul
 finish report bdbsa105_res_azul
 finish report bdbsa105_carga_azulgz
 finish report bdbsa105_res_azulgz

 display '----------------------------------------------------------------'
 display 'Quantidade de registros: ', l_count clipped
 display 'Relatorio finalizado'

 let l_hora = current
 display 'Hora do fim do processamento: ', l_hora

 whenever error continue

 let l_comando = "gzip -f ", m_pathtxt2
 run l_comando
 let m_pathtxt2 = m_pathtxt2 clipped, ".gz"

 let l_retorno = ctx22g00_envia_email("BDBSA105", "Arquivo de provisionamento AZUL", m_pathtxt2)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display "Erro de envio de email(cx22g00)- ",m_pathtxt2
    else
       display "Nao ha email cadastrado para o modulo BDBSA105 "
    end if
 end if

 let l_comando = "gzip -f ", m_pathdoc2
 run l_comando
 let m_pathdoc2 = m_pathdoc2 clipped, ".gz"

 let l_retorno = ctx22g00_envia_email("BDBSA105", "Resumo do provisionamento AZUL", m_pathdoc2)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display "Erro de envio de email(cx22g00)- ",m_pathdoc2
    else
       display "Nao ha email cadastrado para o modulo BDBSA105 "
    end if
 end if

 whenever error stop

end main

#-------------------------------------#
report bdbsa105_carga_azul(l_param,l_count)
#-------------------------------------#

  define l_param record
     aplnumdig like datrservapol.aplnumdig,
     succod    like datrservapol.succod,
     ramcod    like datrservapol.ramcod,
     atdetpdat like datmsrvacp.atdetpdat,
     asitipcod like datmservico.asitipcod,
     atdsrvnum like datmservico.atdsrvnum,
     atdetpcod like datmsrvacp.atdetpcod
  end record

  define l_count smallint,
         l_aux   char(060)

  define l_asitipdes  like datkasitip.asitipdes

  output
    page length    01
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format

     on every row

           #--------[Busca descrição da assistencia]--------------------------------------------------------
           whenever error continue
             if l_param.asitipcod is null then
                let l_asitipdes = "SEM ASSISTENCIA"
             else
                open cbdbsa105001 using l_param.asitipcod
                fetch cbdbsa105001 into l_asitipdes
                close cbdbsa105001
             end if
           whenever error stop

           # formatar valores para o arquivo
           print column 0001, "000"                                , # 01 CÓDIGO DA INTERFACE
                 column 0004, l_count using '&&&&&&&&&&'           , # 02 NO SEQUENCIAL DO REGISTRO
                 column 0014, ' '                                  , # 03 TIPO DE PESSOA
                 column 0015, "000"                                , # 04 CLASSE
                 column 0018, l_aux                                , # 05 NOME
                 column 0078, "              "                     , # 06 CPF OU CNPJ
                 column 0092, l_aux[1,30]                          , # 07 ENDEREÇO
                 column 0122, "     "                              , # 08 NO
                 column 0127, "          "                         , # 09 COMPLEMENTO
                 column 0137, l_aux[1,30]                          , # 10 BAIRRO
                 column 0167, "  "                                 , # 11 ESTADO
                 column 0169, l_aux[1,30]                          , # 12 CIDADE
                 column 0199, "0000000000"                         , # 13 CEP
                 column 0209, l_aux                                , # 14 E-MAIL
                 column 0269, "00000"                              , # 15 CÓDIGO DO BANCO
                 column 0274, "0000000000"                         , # 16 NO DA AGÊNCIA
                 column 0284, " "                                  , # 17 DV DA AGÊNCIA
                 column 0285, "0000000000"                         , # 18 NO DA CONTA CORRENTE
                 column 0295, l_aux[1,2]                           , # 19 DV DA CONTA CORRENTE
                 column 0297, "000"                                , # 20 CÓD TRIBUTAÇÃO IRRF
                 column 0300, "00000"                              , # 21 NATUREZA DO RENDIMENTO
                 column 0305, "0"                                  , # 22 CALCULA ISS ?
                 column 0306, "0"                                  , # 23 CALCULA INSS ?
                 column 0307, "000"                                , # 24 CÓD TRIBUTAÇÃO INSS
                 column 0310, "00"                                 , # 25 NO DE DEPENDENTES
                 column 0312, "00000000000"                        , # 26 NO PIS
                 column 0323, "00000000000"                        , # 27 INSCRICAO MUNICIPAL
                 column 0334, "0000000000"                         , # 28 NÚMERO INTERNO DO CORRETOR
                 column 0344, l_aux[1,5]                           , # 29  CBO (CLASSIFIC BRASILEIRA OCUPAÇÃO)
                 column 0349, "00000000000000"                     , # 30 CÓDIGO SUSEP
                 column 0363, "0000000000"                         , # 31 NO DO FUNCIONÁRIO
                 column 0373, "               "                    , # 32 CÓD DA FILIAL
                 column 0388, "               "                    , # 33 CÓD DO CENTRO DE CUSTO
                 column 0403, "0000000000"                         , # 34 NO CARTEIRA DE SAUDE
                 column 0413, "00000000"                           , # 35 DATA DE NASCIMENTO
                 column 0421, " "                                  , # 36 TIPO DE PESSOA
                 column 0422, "000"                                , # 37 CLASSE
                 column 0425, l_aux                                , # 38 NOME
                 column 0485, "              "                     , # 39 CPF OU CNPJ
                 column 0499, "00000"                              , # 40 CÓDIGO DO BANCO
                 column 0504, "0000000000"                         , # 41 NO DA AGÊNCIA
                 column 0514, " "                                  , # 42 DV DA AGÊNCIA
                 column 0515, "0000000000"                         , # 43 NO DA CONTA CORRENTE
                 column 0525, l_aux[1,2]                           , # 44 DV DA CONTA CORRENTE
                 column 0527, l_aux[1,11],
                              l_param.atdsrvnum using "&&&&&&&"    , # 45 IDENTIFICAÇÃO DO PAGAMENTO
                 column 0552, "00000"                              , # 46 CÓD DA EMPRESA
                 column 0557, "00000"                              , # 47 CÓD DA FILIAL
                 column 0562, "00000"                              , # 48 CODIGO DO EVENTO
                 column 0567, "000"                                , # 49 TIPO DE OPERACAO
                 column 0570, "000"                                , # 50  FORMA DE PAGAMENTO
                 column 0573, "00000000000000000000"               , # 51  NO DO DOCUMENTO
                 column 0593, "00000000"                           , # 52 DATA DE EMISSAO
                 column 0601, "00000000"                           , # 53 DATA DE VENCIMENTO
                 column 0609, " "                                  , # 54 SINAL DO VALOR BRUTO
                 column 0610, "000000000000000000"                 , # 55 VALOR BRUTO
                 column 0628, " "                                  , # 56 SINAL DO VALOR ISENTO IR
                 column 0629, "000000000000000000"                 , # 57 VALOR ISENTO IR
                 column 0647, " "                                  , # 58 SINAL DO VALOR TRIBUTÁVEL IR
                 column 0648, "000000000000000000"                 , # 59 VALOR TRIBUTÁVEL IR
                 column 0666, " "                                  , # 60 SINAL DO VALOR ISENTO ISS
                 column 0667, "000000000000000000"                 , # 61 VALOR ISENTO ISS
                 column 0685, " "                                  , # 62 SINAL DO VALOR TRIBUTÁVEL ISS
                 column 0686, "000000000000000000"                 , # 63 VALOR TRIBUTÁVEL ISS
                 column 0704, " "                                  , # 64 SINAL DO VALOR ISENTO INSS
                 column 0705, "000000000000000000"                 , # 65 VALOR ISENTO INSS
                 column 0723, " "                                  , # 66 SINAL DO VALOR TRIBUTÁVEL INSS
                 column 0724, "000000000000000000"                 , # 67 VALOR TRIBUTÁVEL INSS
                 column 0742, " "                                  , # 68 SINAL DO VALOR ISS
                 column 0743, "000000000000000000"                 , # 69 VALOR ISS
                 column 0761, " "                                  , # 70 SINAL DO VALOR JUROS
                 column 0762, "000000000000000000"                 , # 71 VALOR JUROS
                 column 0780, " "                                  , # 72 SINAL DO VALOR MULTA
                 column 0781, "000000000000000000"                 , # 73 VALOR MULTA
                 column 0799, l_aux                                , # 74 DESCRIÇÃO
                 column 0859, " "                                  , # 75 SINAL DO VALOR CPMF
                 column 0860, "000000000000000000"                 , # 76 VALOR CPMF
                 column 0878, " "                                  , # 77 SINAL DO VALOR BASE DA MP 2222
                 column 0879, "000000000000000000"                 , # 78 VALOR BASE DA MP 2222
                 column 0897, " "                                  , # 79 SINAL DO VALOR IR MP 2222
                 column 0898, "000000000000000000"                 , # 80 VALOR IR MP 2222
                 column 0916, "00000"                              , # 81 COD DA RECEITA

                 column 0921, l_param.succod    using '&&'         , # 82 SUCURSAL (CÓDIGO SUNSYSTEMS)
                              l_aux[1,13]                          ,
                 column 0936, "               "                    , # 83 RAMO (CÓDIGO SUNSYSTEMS)
                 column 0951, "               "                    , # 84 A DEFINIR
                 column 0966, "               "                    , # 85 A DEFINIR
                 column 0981, "               "                    , # 86 A DEFINIR
                 column 0996, "               "                    , # 87 A DEFINIR

                 column 1011, l_param.succod    using "&&"         ,
                         " ", l_param.ramcod    using "&&&"        , # 88 APOLICE
                         " ", l_param.aplnumdig using "&&&&&&&&"   ,

                 column 1026, "               "                    , # 89 A DEFINIR
                 column 1041, "               "                    , # 90 A DEFINIR

                 column 1056, l_param.atdetpdat using "ddmmyyyy"   , # 91 DATA DE ACIONAMENTO
                              l_aux[1,07],

                 column 1071, l_asitipdes,l_aux[1,10]              , # 92 TIPO DE ASSISTENCIA

                 column 1101, "                         "          , # 93 REF_BANCO
                 column 1126, "     "                              , # 94 BRANCOS
                 column 1131, "             "                      , # 95 RESERVADO
                 column 1144, " "                                  , # 96 SINAL DO VALOR ISENTO CCP
                 column 1145, "                  "                 , # 97 VALOR ISENTO CCP
                 column 1163, " "                                  , # 98 SINAL DO VALOR TRIBUTÁVEL CCP
                 column 1164, "                  "                 , # 99 VALOR TRIBUTÁVEL CCP
                 column 1182, "000"                                , # 100 CODIGO TRIBUTACAO CSLL
                 column 1185, "000"                                , # 101 CODIGO TRIBUTACAO COFINS
                 column 1188, "000"                                , # 102 CODIGO TRIBUTACAO PIS
                 column 1191, "               "                    , # 103 USO AXA
                 column 1206, "               "                    , # 104 USO AXA
                 column 1221, "               "                    , # 105 USO AXA
                 column 1236, " "                                  , # 106 TIPO DE MOVIMENTO
                 column 1237, "00000000"                           , # 107 DATA DO PAGAMENTO
                 column 1245, " "                                  , # 108 SINAL DO VALOR PAGO
                 column 1246, "000000000000000000"                 , # 109 VALOR PAGO
                 column 1264, "00000"                              , # 110 CÓDIGO DO BANCO
                 column 1269, "0000000000"                         , # 111 NO DA AGÊNCIA
                 column 1279, "0000000000"                         , # 112 NO DA CONTA CORRENTE
                 column 1289, "000000000000000"                    , # 113 NO DO CHEQUE
                 column 1304, " "                                  , # 114 SINAL DO VALOR IRRF
                 column 1305, "000000000000000000"                 , # 115 VALOR IRRF
                 column 1323, " "                                  , # 116 SINAL DO VALOR ISS
                 column 1324, "000000000000000000"                 , # 117 VALOR ISS
                 column 1342, " "                                  , # 118 SINAL DO VALOR INSS
                 column 1343, "000000000000000000"                 , # 119 VALOR INSS
                 column 1361, " "                                  , # 120 SINAL DO VALOR CSLL
                 column 1362, "000000000000000000"                 , # 121 VALOR CSLL
                 column 1380, " "                                  , # 122 SINAL DO VALOR COFINS
                 column 1381, "000000000000000000"                 , # 123 VALOR COFINS
                 column 1399, " "                                  , # 124 SINAL DO VALOR PIS
                 column 1400, "000000000000000000"                 , # 125 VALOR PIS
                 column 1418, "000"                                , # 126 COD OCORRÊNCIA
                 column 1421, ""                                   , # 127 DESCRIÇÃO DA OCORRÊNCIA
                 column 1481, "000"                                , # 128 FORMA DE PAGAMENTO EFETIVA
                 column 1484, l_param.atdetpcod using "&&"            # 129 ETAPA DO SERVICO
 end report

#-------------------------------------#
 report bdbsa105_res_azul(l_res)
#-------------------------------------#

  define l_res record
         aplnumdig like datrservapol.aplnumdig,
         succod    like datrservapol.succod,
         ramcod    like datrservapol.ramcod,
         atdetpdat like datmsrvacp.atdetpdat,
         asitipcod like datmservico.asitipcod,
         atdsrvnum like datmservico.atdsrvnum,
         l_count      integer
  end record

  define l_srvtot     integer,
         l_vlrtot     like dbsmopg.socfattotvlr

  output
    page length    60
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format

     first page header

        let l_srvtot = 0
        let l_vlrtot  = 0

        print "Resumo de serviços acionados para Azul Seguro no dia ", m_data
        print ""
        print "Sucursal  Sucursal/Ramo/Apolice  Data do acionamento  Tipo assistência  Serviço"

     on last row
        print ""
        print "                        Total de serviço acionados: ",
              l_res.l_count using "########"

     on every row
        print column 0001, l_res.succod using "&&&&&&&&" clipped            , # 1 SUCURSAL
              column 0012, l_res.succod using "&&"   ,"/"                   ,
                           l_res.ramcod using "&&&&&","/"                   , # 2 SUCURSAL/RAMO/APOLICE
                           l_res.aplnumdig using "&&&&&&&&&"                ,
              column 0038, l_res.atdetpdat using "dd/mm/yyyy" clipped       , # 3 DATA DO ACIONAMENTO
              column 0061, l_res.asitipcod using "&&&" clipped   , # 4 ASSISTENCIA
              column 0073, l_res.atdsrvnum using "&&&&&&&" clipped            # 5 SERVIÇO
 end report

#-------------------------------------#
 report bdbsa105_res_azulgz(l_res)
#-------------------------------------#

  define l_res record
         aplnumdig like datrservapol.aplnumdig,
         succod    like datrservapol.succod,
         ramcod    like datrservapol.ramcod,
         atdetpdat like datmsrvacp.atdetpdat,
         asitipcod like datmservico.asitipcod,
         atdsrvnum like datmservico.atdsrvnum,
         l_count      integer
  end record

  define l_srvtot     integer,
         l_vlrtot     like dbsmopg.socfattotvlr

  output
    page length    60
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format

     first page header

        let l_srvtot = 0
        let l_vlrtot  = 0

        print "Resumo de serviços acionados para Azul Seguro no dia ", m_data
        print ""
        print "Sucursal  Sucursal/Ramo/Apolice  Data do acionamento  Tipo assistência  Serviço"

     on last row
        print ""
        print "                        Total de serviço acionados: ",
              l_res.l_count using "########"

     on every row
        print column 0001, l_res.succod using "&&&&&&&&" clipped            , # 1 SUCURSAL
              column 0012, l_res.succod using "&&"   ,"/"                   ,
                           l_res.ramcod using "&&&&&","/"                   , # 2 SUCURSAL/RAMO/APOLICE
                           l_res.aplnumdig using "&&&&&&&&&"                ,
              column 0038, l_res.atdetpdat using "dd/mm/yyyy" clipped       , # 3 DATA DO ACIONAMENTO
              column 0061, l_res.asitipcod using "&&&" clipped   , # 4 ASSISTENCIA
              column 0073, l_res.atdsrvnum using "&&&&&&&" clipped            # 5 SERVIÇO
 end report

#-------------------------------------#
report bdbsa105_carga_azulgz(l_param,l_count)
#-------------------------------------#

  define l_param record
     aplnumdig like datrservapol.aplnumdig,
     succod    like datrservapol.succod,
     ramcod    like datrservapol.ramcod,
     atdetpdat like datmsrvacp.atdetpdat,
     asitipcod like datmservico.asitipcod,
     atdsrvnum like datmservico.atdsrvnum,
     atdetpcod like datmsrvacp.atdetpcod
  end record

  define l_count smallint,
         l_aux   char(060)

  define l_asitipdes  like datkasitip.asitipdes

  output
    page length    01
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format

     on every row

           #--------[Busca descrição da assistencia]--------------------------------------------------------
           whenever error continue
             if l_param.asitipcod is null then
                let l_asitipdes = "SEM ASSISTENCIA"
             else
                open cbdbsa105001 using l_param.asitipcod
                fetch cbdbsa105001 into l_asitipdes
                close cbdbsa105001
             end if
           whenever error stop

           # formatar valores para o arquivo
           print column 0001, "000"                                , # 01 CÓDIGO DA INTERFACE
                 column 0004, l_count using '&&&&&&&&&&'           , # 02 NO SEQUENCIAL DO REGISTRO
                 column 0014, ' '                                  , # 03 TIPO DE PESSOA
                 column 0015, "000"                                , # 04 CLASSE
                 column 0018, l_aux                                , # 05 NOME
                 column 0078, "              "                     , # 06 CPF OU CNPJ
                 column 0092, l_aux[1,30]                          , # 07 ENDEREÇO
                 column 0122, "     "                              , # 08 NO
                 column 0127, "          "                         , # 09 COMPLEMENTO
                 column 0137, l_aux[1,30]                          , # 10 BAIRRO
                 column 0167, "  "                                 , # 11 ESTADO
                 column 0169, l_aux[1,30]                          , # 12 CIDADE
                 column 0199, "0000000000"                         , # 13 CEP
                 column 0209, l_aux                                , # 14 E-MAIL
                 column 0269, "00000"                              , # 15 CÓDIGO DO BANCO
                 column 0274, "0000000000"                         , # 16 NO DA AGÊNCIA
                 column 0284, " "                                  , # 17 DV DA AGÊNCIA
                 column 0285, "0000000000"                         , # 18 NO DA CONTA CORRENTE
                 column 0295, l_aux[1,2]                           , # 19 DV DA CONTA CORRENTE
                 column 0297, "000"                                , # 20 CÓD TRIBUTAÇÃO IRRF
                 column 0300, "00000"                              , # 21 NATUREZA DO RENDIMENTO
                 column 0305, "0"                                  , # 22 CALCULA ISS ?
                 column 0306, "0"                                  , # 23 CALCULA INSS ?
                 column 0307, "000"                                , # 24 CÓD TRIBUTAÇÃO INSS
                 column 0310, "00"                                 , # 25 NO DE DEPENDENTES
                 column 0312, "00000000000"                        , # 26 NO PIS
                 column 0323, "00000000000"                        , # 27 INSCRICAO MUNICIPAL
                 column 0334, "0000000000"                         , # 28 NÚMERO INTERNO DO CORRETOR
                 column 0344, l_aux[1,5]                           , # 29  CBO (CLASSIFIC BRASILEIRA OCUPAÇÃO)
                 column 0349, "00000000000000"                     , # 30 CÓDIGO SUSEP
                 column 0363, "0000000000"                         , # 31 NO DO FUNCIONÁRIO
                 column 0373, "               "                    , # 32 CÓD DA FILIAL
                 column 0388, "               "                    , # 33 CÓD DO CENTRO DE CUSTO
                 column 0403, "0000000000"                         , # 34 NO CARTEIRA DE SAUDE
                 column 0413, "00000000"                           , # 35 DATA DE NASCIMENTO
                 column 0421, " "                                  , # 36 TIPO DE PESSOA
                 column 0422, "000"                                , # 37 CLASSE
                 column 0425, l_aux                                , # 38 NOME
                 column 0485, "              "                     , # 39 CPF OU CNPJ
                 column 0499, "00000"                              , # 40 CÓDIGO DO BANCO
                 column 0504, "0000000000"                         , # 41 NO DA AGÊNCIA
                 column 0514, " "                                  , # 42 DV DA AGÊNCIA
                 column 0515, "0000000000"                         , # 43 NO DA CONTA CORRENTE
                 column 0525, l_aux[1,2]                           , # 44 DV DA CONTA CORRENTE
                 column 0527, l_aux[1,11],
                              l_param.atdsrvnum using "&&&&&&&"    , # 45 IDENTIFICAÇÃO DO PAGAMENTO
                 column 0552, "00000"                              , # 46 CÓD DA EMPRESA
                 column 0557, "00000"                              , # 47 CÓD DA FILIAL
                 column 0562, "00000"                              , # 48 CODIGO DO EVENTO
                 column 0567, "000"                                , # 49 TIPO DE OPERACAO
                 column 0570, "000"                                , # 50  FORMA DE PAGAMENTO
                 column 0573, "00000000000000000000"               , # 51  NO DO DOCUMENTO
                 column 0593, "00000000"                           , # 52 DATA DE EMISSAO
                 column 0601, "00000000"                           , # 53 DATA DE VENCIMENTO
                 column 0609, " "                                  , # 54 SINAL DO VALOR BRUTO
                 column 0610, "000000000000000000"                 , # 55 VALOR BRUTO
                 column 0628, " "                                  , # 56 SINAL DO VALOR ISENTO IR
                 column 0629, "000000000000000000"                 , # 57 VALOR ISENTO IR
                 column 0647, " "                                  , # 58 SINAL DO VALOR TRIBUTÁVEL IR
                 column 0648, "000000000000000000"                 , # 59 VALOR TRIBUTÁVEL IR
                 column 0666, " "                                  , # 60 SINAL DO VALOR ISENTO ISS
                 column 0667, "000000000000000000"                 , # 61 VALOR ISENTO ISS
                 column 0685, " "                                  , # 62 SINAL DO VALOR TRIBUTÁVEL ISS
                 column 0686, "000000000000000000"                 , # 63 VALOR TRIBUTÁVEL ISS
                 column 0704, " "                                  , # 64 SINAL DO VALOR ISENTO INSS
                 column 0705, "000000000000000000"                 , # 65 VALOR ISENTO INSS
                 column 0723, " "                                  , # 66 SINAL DO VALOR TRIBUTÁVEL INSS
                 column 0724, "000000000000000000"                 , # 67 VALOR TRIBUTÁVEL INSS
                 column 0742, " "                                  , # 68 SINAL DO VALOR ISS
                 column 0743, "000000000000000000"                 , # 69 VALOR ISS
                 column 0761, " "                                  , # 70 SINAL DO VALOR JUROS
                 column 0762, "000000000000000000"                 , # 71 VALOR JUROS
                 column 0780, " "                                  , # 72 SINAL DO VALOR MULTA
                 column 0781, "000000000000000000"                 , # 73 VALOR MULTA
                 column 0799, l_aux                                , # 74 DESCRIÇÃO
                 column 0859, " "                                  , # 75 SINAL DO VALOR CPMF
                 column 0860, "000000000000000000"                 , # 76 VALOR CPMF
                 column 0878, " "                                  , # 77 SINAL DO VALOR BASE DA MP 2222
                 column 0879, "000000000000000000"                 , # 78 VALOR BASE DA MP 2222
                 column 0897, " "                                  , # 79 SINAL DO VALOR IR MP 2222
                 column 0898, "000000000000000000"                 , # 80 VALOR IR MP 2222
                 column 0916, "00000"                              , # 81 COD DA RECEITA

                 column 0921, l_param.succod    using '&&'         , # 82 SUCURSAL (CÓDIGO SUNSYSTEMS)
                              l_aux[1,13]                          ,
                 column 0936, "               "                    , # 83 RAMO (CÓDIGO SUNSYSTEMS)
                 column 0951, "               "                    , # 84 A DEFINIR
                 column 0966, "               "                    , # 85 A DEFINIR
                 column 0981, "               "                    , # 86 A DEFINIR
                 column 0996, "               "                    , # 87 A DEFINIR

                 column 1011, l_param.succod    using "&&"         ,
                         " ", l_param.ramcod    using "&&&"        , # 88 APOLICE
                         " ", l_param.aplnumdig using "&&&&&&&&"   ,

                 column 1026, "               "                    , # 89 A DEFINIR
                 column 1041, "               "                    , # 90 A DEFINIR

                 column 1056, l_param.atdetpdat using "ddmmyyyy"   , # 91 DATA DE ACIONAMENTO
                              l_aux[1,07],

                 column 1071, l_asitipdes,l_aux[1,10]              , # 92 TIPO DE ASSISTENCIA

                 column 1101, "                         "          , # 93 REF_BANCO
                 column 1126, "     "                              , # 94 BRANCOS
                 column 1131, "             "                      , # 95 RESERVADO
                 column 1144, " "                                  , # 96 SINAL DO VALOR ISENTO CCP
                 column 1145, "                  "                 , # 97 VALOR ISENTO CCP
                 column 1163, " "                                  , # 98 SINAL DO VALOR TRIBUTÁVEL CCP
                 column 1164, "                  "                 , # 99 VALOR TRIBUTÁVEL CCP
                 column 1182, "000"                                , # 100 CODIGO TRIBUTACAO CSLL
                 column 1185, "000"                                , # 101 CODIGO TRIBUTACAO COFINS
                 column 1188, "000"                                , # 102 CODIGO TRIBUTACAO PIS
                 column 1191, "               "                    , # 103 USO AXA
                 column 1206, "               "                    , # 104 USO AXA
                 column 1221, "               "                    , # 105 USO AXA
                 column 1236, " "                                  , # 106 TIPO DE MOVIMENTO
                 column 1237, "00000000"                           , # 107 DATA DO PAGAMENTO
                 column 1245, " "                                  , # 108 SINAL DO VALOR PAGO
                 column 1246, "000000000000000000"                 , # 109 VALOR PAGO
                 column 1264, "00000"                              , # 110 CÓDIGO DO BANCO
                 column 1269, "0000000000"                         , # 111 NO DA AGÊNCIA
                 column 1279, "0000000000"                         , # 112 NO DA CONTA CORRENTE
                 column 1289, "000000000000000"                    , # 113 NO DO CHEQUE
                 column 1304, " "                                  , # 114 SINAL DO VALOR IRRF
                 column 1305, "000000000000000000"                 , # 115 VALOR IRRF
                 column 1323, " "                                  , # 116 SINAL DO VALOR ISS
                 column 1324, "000000000000000000"                 , # 117 VALOR ISS
                 column 1342, " "                                  , # 118 SINAL DO VALOR INSS
                 column 1343, "000000000000000000"                 , # 119 VALOR INSS
                 column 1361, " "                                  , # 120 SINAL DO VALOR CSLL
                 column 1362, "000000000000000000"                 , # 121 VALOR CSLL
                 column 1380, " "                                  , # 122 SINAL DO VALOR COFINS
                 column 1381, "000000000000000000"                 , # 123 VALOR COFINS
                 column 1399, " "                                  , # 124 SINAL DO VALOR PIS
                 column 1400, "000000000000000000"                 , # 125 VALOR PIS
                 column 1418, "000"                                , # 126 COD OCORRÊNCIA
                 column 1421, ""                                   , # 127 DESCRIÇÃO DA OCORRÊNCIA
                 column 1481, "000"                                , # 128 FORMA DE PAGAMENTO EFETIVA
                 column 1484, l_param.atdetpcod using "&&"            # 129 ETAPA DO SERVICO
 end report
