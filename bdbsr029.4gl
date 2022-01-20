#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SEGURO FAZ                                           #
# MODULO.........: BDBSR029                                                   #
# ANALISTA RESP..: SERGIO BURINI                                              #
# PSI/OSF........:                                                            #
#                  RELATÓRIO DE VENDA COM PRESTADOR NO LOCAL.                 #
# ........................................................................... #
# DESENVOLVIMENTO: SERGIO BURINI                                              #
# LIBERACAO......: 03/11/2014                                                 #
#-----------------------------------------------------------------------------#

 database porto

 define mr_record record
     atdsrvnum  like datmservico.atdsrvnum,
     atdsrvano  like datmservico.atdsrvano,
     atddat     like datmservico.atddat   ,
     atdhor     like datmservico.atdhor   ,
     corsus     like datmservico.corsus   ,
     cornom     like datmservico.cornom   ,
     tippes     char(0001),
     cgccpfnum  like datrligcgccpf.cgccpfnum,
     cgcord     like datrligcgccpf.cgcord   ,
     cgccpfdig  like datrligcgccpf.cgccpfdig,
     nom        like datmservico.nom      ,
     atdsrvorg  like datmservico.atdsrvorg,
     asitipcod  like datmservico.asitipcod,
     lgdtip     like datmlcl.lgdtip   ,
     lgdnom     like datmlcl.lgdnom   ,
     lgdnum     like datmlcl.lgdnum   ,
     brrnom     like datmlcl.brrnom   ,
     cidnom     like datmlcl.cidnom   ,
     ufdcod     like datmlcl.ufdcod   ,
     lclltt     like datmlcl.lclltt   ,
     lcllgt     like datmlcl.lcllgt   ,
     socntzcod  like datmsrvre.socntzcod,
     socntzdes  like datksocntz.socntzdes,
     c24pbmcod  like datrsrvpbm.c24pbmcod,
     c24pbmdes  like datrsrvpbm.c24pbmdes,
     atdetpcod  like datmservico.atdetpcod,
     atdetpdes  like datketapa.atdetpdes,
     srvcbnhor  like datmservico.srvcbnhor,
     skucod     char(5),
     skunom     char(50),
     skuinvlr   char(10)
 end record

 define r_gcakfilial    record
        endlgd          like gcakfilial.endlgd
       ,endnum          integer
       ,endcmp          like gcakfilial.endcmp
       ,endbrr          like gcakfilial.endbrr
       ,endcid          like gcakfilial.endcid
       ,endcep          like gcakfilial.endcep
       ,endcepcmp       like gcakfilial.endcepcmp
       ,endufd          like gcakfilial.endufd
       ,dddcod          like gcakfilial.dddcod
       ,teltxt          like gcakfilial.teltxt
       ,dddfax          like gcakfilial.dddfax
       ,factxt          like gcakfilial.factxt
       ,maides          like gcakfilial.maides
       ,crrdstcod       like gcaksusep.crrdstcod
       ,crrdstnum       like gcaksusep.crrdstnum
       ,crrdstsuc       like gcaksusep.crrdstsuc
       ,status          smallint  # 0 OK / 1 SUSEP INEXIST / 2 END.NAO LOCALIZ
 end record


 define lr_produtor     record
      result  smallint              # 0 = OK
     ,inpcod  like gcbkinsp.inpcod
     ,inpnom  like gcbkinsp.inpnom
     ,pdtcod  like gcbkprod.pdtcod
     ,pdtnom  like gcbkprod.pdtnom
     ,succod  like gcbkprod.succod
     ,cdncod  like gcbkprod.cdncod
     ,msgerr  char(100)
 end record

 define m_data_atual  date,
        m_hora_atual  datetime hour to minute,
        m_path        char(300),
        m_dataini     date,
        m_datafim     date

 main

    # ABRE O BANCO UTILIZADO PELA CENTRAL 24 HORAS
    call fun_dba_abre_banco("CT24HS")

    call cts40g03_data_hora_banco(2)
         returning m_data_atual,
                   m_hora_atual

    # CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("SAPS","LOG")

    if m_path is null then
       let m_path = "."
    end if
    
    let m_path = m_path clipped,"/bdbsr029.log"

    call startlog(m_path)

    # CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("SAPS", "RELATO")

    if m_path is null then
       let m_path = "."
    end if
                   
    let m_path = m_path clipped , "/BDBSR029.xls"

    set isolation to dirty read

    call bdbsr029_prepare()

    call bdbsr029()

 end main

#---------------------------#
 function bdbsr029_prepare()
#---------------------------#

     define l_sql char(3000)

     initialize l_sql to null

     let l_sql = "select srv.atdsrvnum,  ",
                       " srv.atdsrvano,  ",
                       " srv.atddat,  ",
                       " srv.atdhor,  ",
                       " srv.corsus,  ",
                       " srv.cornom,  ",
                       " cpf.cgccpfnum,  ",
                       " cpf.cgcord,  ",
                       " cpf.cgccpfdig,  ",
                       " srv.nom,  ",
                       " srv.atdsrvorg,  ",
                       " srv.asitipcod , ",
                       " lcl.lgdtip,  ",
                       " lcl.lgdnom,  ",
                       " lcl.lgdnum,  ",
                       " lcl.brrnom,  ",
                       " lcl.cidnom,  ",
                       " lcl.ufdcod,  ",
                       " lcl.lclltt,  ",
                       " lcl.lcllgt,  ",
                       " res.socntzcod, ",
                       " c24pbmcod,  ",
                       " c24pbmdes, ",
                       " srv.atdetpcod, ",
                       " srv.srvcbnhor",
                  " from datmservico srv, ",
                       " datmlcl     lcl, ",
                       " datmligacao lig, ",
                       " datrligcgccpf cpf, ",
                       " outer datrsrvpbm pbm, ",
                       " outer datmsrvre res ",
                 " where srv.ciaempcod = 43 ",             # SOMENTE EMPRESA 43 - PORTO SEGURO FAZ
                   " and corsus is not null ",             # SERVIÇOS COM CORRETOR RELACIONAMENTO NO ATENDIMENTO
                   " and atddat between ? and ? ",
                   " and srv.atdsrvnum = lcl.atdsrvnum ",
                   " and srv.atdsrvano = lcl.atdsrvano ",
                   " and lcl.c24endtip = 1 ",              # APENAS INFORMAÇÕES DO ENDEREÇO DE ORIGEM
                   " and pbm.c24pbmseq = 1 ",              # APENAS 1 LINHA DE PROBLEMA
                   " and lig.atdsrvnum = srv.atdsrvnum ",
                   " and lig.atdsrvano = srv.atdsrvano ",
                   " and lig.atdsrvnum = pbm.atdsrvnum ",
                   " and lig.atdsrvano = pbm.atdsrvano ",
                   " and lig.atdsrvnum = res.atdsrvnum ",
                   " and lig.atdsrvano = res.atdsrvano ",
                   " and lig.lignum    = (select min(lignum) from datmligacao lig2 ",  # LIGAÇÃO INICIAL
                                          " where lig.atdsrvnum = lig2.atdsrvnum ",
                                            " and lig.atdsrvano = lig2.atdsrvano) ",
                   " and cpf.lignum = lig.lignum "

     prepare p_bdbsr029_01 from l_sql
     declare c_bdbsr029_01 cursor for p_bdbsr029_01

     let l_sql = "select socntzdes ",
                  " from datksocntz ",
                 " where socntzcod = ? "

     prepare p_bdbsr029_02 from l_sql
     declare c_bdbsr029_02 cursor for p_bdbsr029_02

     let l_sql = "select catcod, ",
                       " catnom, ",
                       " srvinccbrvlr ",
                       " from datksrvcat ",
                       " where c24pbmcod = ? "

     prepare p_bdbsr029_03 from l_sql
     declare c_bdbsr029_03 cursor for p_bdbsr029_03


     let l_sql = "select atdetpdes ",
                  " from datketapa ",
                 " where atdetpcod = ? "

     prepare p_bdbsr029_04 from l_sql
     declare c_bdbsr029_04 cursor for p_bdbsr029_04

     let l_sql = "select 1 ",
                  " from datmservico   srv, ",
                       " datrligcgccpf cpf, ",
                       " datmligacao   lig  ",
                 " where cpf.cgccpfnum = ? ",
                   " and cpf.cgcord    = ? ",
                   " and cpf.cgccpfdig = ? ",
                   " and srv.ciaempcod = 43 ",
                   " and ((srv.atddat    between '01/11/2014' and ?) or ",
                        " (srv.atddat    = ? and ",
                        "  srv.atdhor    < ?)) ",
                   " and lig.lignum    = (select min(lignum) ",
                                          " from datmligacao lig2 ",
                                         " where lig.atdsrvnum = lig2.atdsrvnum ",
                                           " and lig.atdsrvano = lig2.atdsrvano)",
                   " and cpf.lignum    = lig.lignum ",
                   " and srv.atdsrvnum = lig.atdsrvnum ",
                   " and srv.atdsrvano = lig.atdsrvano "

     prepare p_bdbsr029_05 from l_sql
     declare c_bdbsr029_05 cursor for p_bdbsr029_05

 end function

#-------------------#
 function bdbsr029()
#-------------------#

     define l_dataini   date,
            l_datafim   date 

     initialize l_dataini, 
                l_datafim to null
     let m_datafim = m_data_atual - 1 units day            
     let m_dataini = m_data_atual - 7 units day

     open c_bdbsr029_01 using m_dataini,
                              m_datafim
     fetch c_bdbsr029_01 into mr_record.atdsrvnum,
                              mr_record.atdsrvano,
                              mr_record.atddat,
                              mr_record.atdhor,
                              mr_record.corsus,
                              mr_record.cornom,
                              mr_record.cgccpfnum,
                              mr_record.cgcord,
                              mr_record.cgccpfdig,
                              mr_record.nom,
                              mr_record.atdsrvorg,
                              mr_record.asitipcod,
                              mr_record.lgdtip,
                              mr_record.lgdnom,
                              mr_record.lgdnum,
                              mr_record.brrnom,
                              mr_record.cidnom,
                              mr_record.ufdcod,
                              mr_record.lclltt,
                              mr_record.lcllgt,
                              mr_record.socntzcod,
                              mr_record.c24pbmcod,
                              mr_record.c24pbmdes,
                              mr_record.atdetpcod,
                              mr_record.srvcbnhor

     if  sqlca.sqlcode = 0 then

         start report bdbsr029_relatorio to m_path

         foreach c_bdbsr029_01 into  mr_record.atdsrvnum,
                                     mr_record.atdsrvano,
                                     mr_record.atddat,
                                     mr_record.atdhor,
                                     mr_record.corsus,
                                     mr_record.cornom,
                                     mr_record.cgccpfnum,
                                     mr_record.cgcord,
                                     mr_record.cgccpfdig,
                                     mr_record.nom,
                                     mr_record.atdsrvorg,
                                     mr_record.asitipcod,
                                     mr_record.lgdtip,
                                     mr_record.lgdnom,
                                     mr_record.lgdnum,
                                     mr_record.brrnom,
                                     mr_record.cidnom,
                                     mr_record.ufdcod,
                                     mr_record.lclltt,
                                     mr_record.lcllgt,
                                     mr_record.socntzcod,
                                     mr_record.c24pbmcod,
                                     mr_record.c24pbmdes,
                                     mr_record.atdetpcod,
                                     mr_record.srvcbnhor

              output to report bdbsr029_relatorio()

              initialize mr_record.*, r_gcakfilial.*, lr_produtor.* to null

         end foreach

         finish report bdbsr029_relatorio
         call bdbsr029_envia_email()

     else
         display "NENHUMA VENDA REALIZADA NO PERIODO"
     end if

 end function

#---------------------------#
 report bdbsr029_relatorio()
#---------------------------#

     define l_aux      smallint,
            l_data_ant date

     output

        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    02

     format

     first page header

        print "SERVIÇO",                 ASCII(09),
              "ANO",                     ASCII(09),
              "DATA ATENDIMENTO",        ASCII(09),
              "HORA ATENDIMENTO",        ASCII(09),
              "DATA / HORA CONBINADA",   ASCII(09),
              "PRIMEIRO SERVIÇO",        ASCII(09),
              "SUSEP",                   ASCII(09),
              "NOME DO CORRETOR",        ASCII(09),
              "LOGRADOURO DO CORRETOR",  ASCII(09),
              "NUMERO DO LOGRADOURO",    ASCII(09),
              "COMPLEMENTO DE ENDEREÇO", ASCII(09),
              "BAIRRO",                  ASCII(09),
              "CEP CORRETOR",            ASCII(09),
              "COMPLEMENTO DE CEP",      ASCII(09),
              "CIDADE CORRETOR",         ASCII(09),
              "UF CORRETOR",             ASCII(09),
              "DDD TELEFONE",            ASCII(09),
              "NUMERO TELEFONE",         ASCII(09),
              "E-MAIL CORRETOR",         ASCII(09),
              "SUCURSAL",                ASCII(09),
              "CODIGO PRODUTOR",         ASCII(09),
              "DESCRIÇÃO PRODUTOR",      ASCII(09),
              "TIPO PESSOA",             ASCII(09),
              "CGC/CPF",                 ASCII(09),
              "ORDEM CGC",               ASCII(09),
              "DIGITO CGC/CPF",          ASCII(09),
              "NOME DO CLIENTE",         ASCII(09),
              "ORIGEM DO SERVIÇO",       ASCII(09),
              "ASSISTENCIA DO SERVIÇO",  ASCII(09),
              "TIPO DO LOGRADOURO",      ASCII(09),
              "NOME DO LOGRADOURO",      ASCII(09),
              "NUMERO DO LOGRADOURO",    ASCII(09),
              "BAIRRO",                  ASCII(09),
              "CIDADE",                  ASCII(09),
              "UF",                      ASCII(09),
              "LATITUDE",                ASCII(09),
              "LONGITUDE",               ASCII(09),
              "CODIGO NATUREZA",         ASCII(09),
              "DESCRIÇÃO DA NATUREZA",   ASCII(09),
              "CODIGO PROBLEMA",         ASCII(09),
              "DESCRIÇÃO DO PROBLEMA",   ASCII(09),
              "CODIGO DA ETAPA",         ASCII(09),
              "DESCRIÇÃO DA ETAPA",      ASCII(09),
              "SKU",                     ASCII(09),
              "DESCRIÇÃO DO SKU",        ASCII(09),
              "VALOR INCIAL DO SERVIÇO"

     on every row

        initialize l_aux,
                   l_data_ant to null

        print mr_record.atdsrvnum,   ASCII(09),
              mr_record.atdsrvano,   ASCII(09),
              mr_record.atddat,      ASCII(09),
              mr_record.atdhor,      ASCII(09),
              mr_record.srvcbnhor,   ASCII(09);


        let l_data_ant = mr_record.atddat - 1 units day


        open c_bdbsr029_05 using mr_record.cgccpfnum,
                                 mr_record.cgcord,
                                 mr_record.cgccpfdig,
                                 l_data_ant,
                                 mr_record.atddat,
                                 mr_record.atdhor
        fetch c_bdbsr029_05 into l_aux

        if  l_aux = 1 then
            print "N",   ASCII(09);
        else
            print "S",   ASCII(09);
        end if

        print mr_record.corsus,      ASCII(09),
              mr_record.cornom,      ASCII(09);

        call fgckc811(mr_record.corsus)
             returning r_gcakfilial.*

        call fpcgccor_obterProdSusep(mr_record.corsus)
             returning lr_produtor.*

        print r_gcakfilial.endlgd,    ASCII(09),
              r_gcakfilial.endnum,    ASCII(09),
              r_gcakfilial.endcmp,    ASCII(09),
              r_gcakfilial.endbrr,    ASCII(09),
              r_gcakfilial.endcep,    ASCII(09),
              r_gcakfilial.endcepcmp, ASCII(09),
              r_gcakfilial.endcid,    ASCII(09),
              r_gcakfilial.endufd,    ASCII(09),
              r_gcakfilial.dddcod,    ASCII(09),
              r_gcakfilial.teltxt,    ASCII(09),
              r_gcakfilial.maides,    ASCII(09),
              lr_produtor.succod,     ASCII(09);

        print lr_produtor.pdtcod,     ASCII(09),
              lr_produtor.pdtnom,     ASCII(09);

        if  mr_record.cgcord = 0 or
            mr_record.cgcord is null then
            print "F", ASCII(09);
        else
            print "J", ASCII(09);
        end if

        print mr_record.cgccpfnum,    ASCII(09),
              mr_record.cgcord,       ASCII(09),
              mr_record.cgccpfdig,    ASCII(09),
              mr_record.nom,          ASCII(09),
              mr_record.atdsrvorg,    ASCII(09),
              mr_record.asitipcod,    ASCII(09),
              mr_record.lgdtip,       ASCII(09),
              mr_record.lgdnom,       ASCII(09),
              mr_record.lgdnum,       ASCII(09),
              mr_record.brrnom,       ASCII(09),
              mr_record.cidnom,       ASCII(09),
              mr_record.ufdcod,       ASCII(09),
              mr_record.lclltt,       ASCII(09),
              mr_record.lcllgt,       ASCII(09),
              mr_record.socntzcod,    ASCII(09);

       open c_bdbsr029_02  using  mr_record.socntzcod
       fetch c_bdbsr029_02 into mr_record.socntzdes

       print mr_record.socntzdes,   ASCII(09),
             mr_record.c24pbmcod,   ASCII(09),
             mr_record.c24pbmdes,   ASCII(09);


       open c_bdbsr029_04 using mr_record.atdetpcod
       fetch c_bdbsr029_04 into mr_record.atdetpdes

       print mr_record.atdetpcod   ,   ASCII(09),
             mr_record.atdetpdes   ,   ASCII(09);

       open c_bdbsr029_03  using  mr_record.c24pbmcod
       fetch c_bdbsr029_03 into mr_record.skucod,
                                mr_record.skunom,
                                mr_record.skuinvlr

       display "SQLCA", sqlca.sqlcode

       if  sqlca.sqlcode = 0 then
            print mr_record.skucod   ,   ASCII(09),
                  mr_record.skunom   ,   ASCII(09),
                  mr_record.skuinvlr ,   ASCII(09)
       else
           print "SKU NAO LOCALIZADO", ASCII(09),
                 "SKU NAO LOCALIZADO", ASCII(09),
                 "SKU NAO LOCALIZADO", ASCII(09)
       end if

 end report

#-------------------------------------------#
 function bdbsr029_envia_email()
#-------------------------------------------#

     define l_assunto     char(100),
            l_erro_envio  integer,
            l_comando     char(200)

     # ---> INICIALIZACAO DAS VARIAVEIS
     let l_comando    = null
     let l_erro_envio = null
     let l_assunto    = "RELATORIOS VENDAS CORRETORES: ", m_dataini  ," a ",  m_datafim

  # ---> COMPACTA O ARQUIVO DO RELATORIO
  let l_comando = "gzip -f ", m_path

  run l_comando
  let m_path = m_path clipped, ".gz"

  let l_erro_envio = ctx22g00_envia_email("BDBSR029", l_assunto, m_path)

  if l_erro_envio <> 0 then
     if l_erro_envio <> 99 then
        display "Erro ao enviar email(ctx22g00) - ", m_path
     else
        display "Nao existe email cadastrado para o modulo - BDBSR025"
     end if
  end if

 end function