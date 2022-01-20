#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: bdbsa131                                                   #
# ANALISTA RESP..: BEATRIZ ARAUJO                                             #
# PSI/OSF........: RELATORIO DE SOCORRISTA QUE NÃO POSSUEM SEGURO DE VIDA     #
#                  E BLOQUEIO DESTES                                          #
# ........................................................................... #
# DESENVOLVIMENTO: BEATRIZ ARAUJO                                             #
# LIBERACAO......: 22/06/2010                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
# 02/09/2010 Beatriz Araujo  Chamado    Inibir a gravacao no Historico do     #
#                                       socorrista quando ela não tem seguro  #
#                                       de vida e não foi bloqueado           #
#									      #
# 02/03/2011 Ueslei Oliveira  		Inclusão de coluna cadeia de gestão   #
# 21/03/2011 Ueslei Oliveira            Alteracao da query de socorristas,    #
#					trazer apenas srr com pst Padrao      #
# 01/04/2011 Robert Lima                Chave d bloqueio pela cidade sede     #
# 08/06/2015 RCP, Fornax     RELTXT     Criar versao .txt dos relatorios.     #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


define mr_bdbsa131      record
       srrabvnom        like datksrr.srrabvnom,             # Nome de Guerra do Socorrista
       srrcoddig        like datrsrrpst.srrcoddig,          # Código do Socorrista
       srrnom           like datksrr.srrnom,                # Nome do Socorrista
       nomgrr           like dpaksocor.nomgrr,              # Nome de guerra do Prestador
       pstcoddig        like datrsrrpst.pstcoddig,          # Codigo do Prestador
       viginc           like datrsrrpst.viginc,             # Vigencia inicial do Socorrista X Prestador
       vigfnl           like datrsrrpst.vigfnl,             # Vigencia final do Socorrista X Prestador
       cgccpfnum        like datksrr.cgccpfnum,             # Numero do CPF/CNPJ do Socorrista
       cgcord           like datksrr.cgcord,                # Ordem do CPF/CNPJ do Socorrista
       cgccpfdig        like datksrr.cgccpfdig,             # Digito do CPF/CNPJ do Socorrista
       pstvintip        like datrsrrpst.pstvintip,          # Tipo do vinculo do Socorrista X Prestador
       srrblqseq        like datmsegsemsrrblq.srrblqseq,    # Sequencia de bloqueios que o socorrista teve
       srrblqdat        like datmsegsemsrrblq.srrblqdat,    # Data do bloqueio do socorrista
       endcid           like dpaksocor.endcid,              # Cidade da base
       endufd           like dpaksocor.endufd               # UF da base
end record

define m_bdbsa131 record
       cponom         like iddkdominio.cponom,    # Nome para consulta
       cpodes_tipo    like iddkdominio.cpodes,    # Parametro de quais tipos de socorrista (1-Porto Socorro...)
       cpodes_vinc    like iddkdominio.cpodes,    # Parametro de quais tipos de vinculo pode bloquear
       cpodes_bloq    like iddkdominio.cpodes,    # Parametro para saber se eh para bloquear ou nao o socorrista
       avstip         char (50),                # Tipo do Aviso do bloqueio
       path_rel       char(200),                # Caminho do relatorio
       path_rel_txt   char(200),                # Caminho do relatorio TXT #--> RELTXT
       path           char(200),                # Caminho do log
       descvintip     like iddkdominio.cpodes   # Descricao do Tipo de vinculo do Socorrista X Prestador
end record

define mr_cda_gestao record
    gstcdicod like dpaksocor.gstcdicod,
    sprnom    like dpakprsgstcdi.sprnom,
    gernom    like dpakprsgstcdi.gernom,
    cdnnom    like dpakprsgstcdi.cdnnom,
    anlnom    like dpakprsgstcdi.anlnom
end record

define m_count  smallint
define datahora datetime hour to second

main

    set isolation to dirty read

    call fun_dba_abre_banco("CT24HS")
    let g_issk.empcod = 1
    let g_issk.funmat = 999999
    let g_issk.usrtip = 'F'

    call bdbsa131_path()
    call cts40g03_exibe_info("I","BDBSA131")

    call bdbsa131_prepare()
    call bdbsa131()

    call cts40g03_exibe_info("F","BDBSA131")

end main


#--------------------------------------------|
#BUSCA O CAMINHO DO RELATORIO e LOG          |
#--------------------------------------------|
 function bdbsa131_path()
#--------------------------------------------#

      define l_dataarq char(8)
      define l_data    date

      let l_data = today
      display "l_data: ", l_data
      let l_dataarq = extend(l_data, year to year),
                      extend(l_data, month to month),
                      extend(l_data, day to day)
      display "l_dataarq: ", l_dataarq

   # Caminho do relatorio
      let m_bdbsa131.path_rel = f_path("DBS","RELATO")
      if  m_bdbsa131.path_rel is null then
          let m_bdbsa131.path_rel = "."
      end if
      let m_bdbsa131.path_rel = m_bdbsa131.path_rel clipped, '/'
      let m_bdbsa131.path_rel_txt = m_bdbsa131.path_rel clipped, '/'

      let m_bdbsa131.path_rel  = m_bdbsa131.path_rel  clipped, "BDBSA131.xls"
      let m_bdbsa131.path_rel_txt  = m_bdbsa131.path_rel_txt  clipped, "BDBSA131_", l_dataarq, ".txt"

      display "m_bdbsa131.path_rel: ", m_bdbsa131.path_rel clipped
      display "m_bdbsa131.path_rel_txt: ", m_bdbsa131.path_rel_txt clipped
   #------------------------------------------------

   # Caminho do Log
      let m_bdbsa131.path = f_path("DBS","LOG")
      if m_bdbsa131.path is null then
         let m_bdbsa131.path = "."
      end if

      let m_bdbsa131.path = m_bdbsa131.path clipped, "/bdbsa131.log"
      call startlog(m_bdbsa131.path)
   #------------------------------------------------
end function


#--------------------------------------------|
#PREPARA AS CONSULTAS/INSERTS/UPDATES        |
#--------------------------------------------|
 function bdbsa131_prepare()
#--------------------------------------------#

     define l_sql char(5000)


     let l_sql = "select cpodes",
                 "  from iddkdominio",
                 " where cponom = ? "
     prepare pbdbsa131_02 from l_sql
     declare cbdbsa131_02 cursor for pbdbsa131_02

     let l_sql = "update datksrr      ",
                 "   set srrstt = 2   ",
                 " where srrcoddig = ?"
     prepare pbdbsa131_04 from l_sql


     let l_sql = "select cpodes              ",
                 " from iddkdominio          ",
                 " where cponom = 'pstvintip'",
                 "   and cpocod = ? "
     prepare pbdbsa131_05 from l_sql
     declare cbdbsa131_05 cursor for pbdbsa131_05


     let l_sql = "select max(srrblqseq)     ",
                 " from datmsegsemsrrblq ",
                 " where srrcoddig = ?      "
     prepare pbdbsa131_06 from l_sql
     declare cbdbsa131_06 cursor for pbdbsa131_06

     let l_sql = "insert into datmsegsemsrrblq     ",
                 "            (srrcoddig,srrblqseq,",
                 "              srrblqdat,funmat,  ",#funmat- Usuario que bloqueou o Socorrista
                 "              blqflg,blqobs)     ",
                 "     values (?,?,?,?,?,?)        "
     prepare pbdbsa131_07 from l_sql

     let l_sql = "select gstcdicod ",
                 "  from dpaksocor ",
                 " where pstcoddig = ? "

     prepare pbdbsa131_08 from l_sql
     declare cbdbsa131_08 cursor for pbdbsa131_08

     let l_sql = "select sprnom,   	",
      		 "      gernom,    	",
      		 "      cdnnom,  	",
      		 "      anlnom		",
      		 " from dpakprsgstcdi	",
      		 "where gstcdicod = ?	"

     prepare pbdbsa131_09 from l_sql
     declare cbdbsa131_09 cursor for pbdbsa131_09

     let l_sql = "select cidsedcod                   ",
                 "  from datrcidsed                  ",
                 " where cidcod = (select mpacidcod  ",
                 "                   from datkmpacid ",
                 "                  where cidnom = ? ",
                 "                    and ufdcod = ?)"
     prepare pbdbsa131_10 from l_sql
     declare cbdbsa131_10 cursor for pbdbsa131_10

     let l_sql = "select cpodes      ",
                 "  from datkdominio ",
                 " where cponom = ?  ",
                 "   and cpodes = ?  "
     prepare pbdbsa131_11 from l_sql
     declare cbdbsa131_11 cursor for pbdbsa131_11

end function


#--------------------------------------------|
#FAZ A EXECUÇÃO DO PROGRAMA                  |
#--------------------------------------------|
 function bdbsa131()
#--------------------------------------------#

# Verificar seguro de Vida
define lr_bdbsa131Vida record
       critica1 smallint, # segundo o vida quando =   7, possuiu Vital
       critica2 smallint, # segundo o vida quando =  83, possuiu VG
       critica3 smallint, # segundo o vida quando =   6, possui Vital
       critica4 smallint, # segundo o vida quando =  82, possui VG
       critica5 smallint, # segundo o vida quando =  85, possuiu API
       critica6 smallint, # segundo o vida quando =  86, possui API
       critica7 smallint  # segundo o vida quando = 321, possui VN
end record

define lr_retorno record
       stt smallint ,
       msg char(50),
       cod smallint
end record

define mensagem    char(2000)
define mensagem2   char(2000)
define l_socvidseg char(1)
define l_sql       char(5000),
       l_cidsedcod like datrcidsed.cidsedcod


initialize lr_bdbsa131Vida.* to null
initialize mr_bdbsa131.* to null
let lr_retorno.stt = 0
let m_count = 0
let mr_bdbsa131.srrblqdat = today

let datahora = current

    #-----------------|
    # ABRE RELATORIO  |
    #-----------------|
     start report bdbsa131_relat to m_bdbsa131.path_rel
     start report bdbsa131_relat_txt to m_bdbsa131.path_rel_txt #--> RELTXT

    #---------------------------------

    #---------------------------------------------------------------|
    # VERIFICA OS TIPOS DE SOCORRISTAS DEVE PROCESSAR               |
    #---------------------------------------------------------------|
    whenever error continue
       let m_bdbsa131.cponom = 'PSOTIPOSRR'
       open cbdbsa131_02  using m_bdbsa131.cponom
       fetch cbdbsa131_02 into m_bdbsa131.cpodes_tipo
       if sqlca.sqlcode <> 0 then
          display "Erro ao busca tipo de vinculo para bloquear! SqlCode: ",sqlca.sqlcode
       end if
    whenever error stop
     display "m_bdbsa131.cpodes_tipo: ",m_bdbsa131.cpodes_tipo

    #---------------------------------------------------------------|
    # VERIFICA OS VINCULOS QUE SAO PARA BLOQUEAR                    |
    #---------------------------------------------------------------|
    whenever error continue
       let m_bdbsa131.cponom = 'VINBLOQSRR'
       open cbdbsa131_02  using m_bdbsa131.cponom
       fetch cbdbsa131_02 into m_bdbsa131.cpodes_vinc
       if sqlca.sqlcode <> 0 then
          display "Erro ao busca tipo de vinculo para bloquear! SqlCode: ",sqlca.sqlcode
       end if
    whenever error stop
     display "m_bdbsa131.cpodes_vinc: ",m_bdbsa131.cpodes_vinc

   #---------------------------------------------------------------|
   # BUSCA PARAMETRO PARA VER SE BLOQUEAI OU NÃO OS SOCORRISTAS    |
   #---------------------------------------------------------------|
   whenever error continue
      let m_bdbsa131.cponom = 'PSOBLOQSRR'
      open cbdbsa131_02  using m_bdbsa131.cponom
      fetch cbdbsa131_02 into m_bdbsa131.cpodes_bloq
      if sqlca.sqlcode <> 0 then
         display "Erro ao buscar parametro se bloqueia ou não! SqlCode: ",sqlca.sqlcode
      end if
      close cbdbsa131_02
   whenever error stop
   display "m_bdbsa131.cpodes_bloq: ",m_bdbsa131.cpodes_bloq


   #--------------------------------------------------------------------------------------------|
   # MONTA E ABRE O CURSOR PARA TRAZER TODOS OS SOCORRISTAS ATIVOS, COM O VINCULO E PADRAO PORTO|
   #--------------------------------------------------------------------------------------------|
      whenever error continue
        let l_sql ="select a.srrabvnom,", # Nome de Guerra do Socorrista
                   "       b.srrcoddig,", # Código do Socorrista
                   "       a.srrnom,",    # Nome do Socorrista
                   "       c.nomgrr,",    # Nome de guerra do Prestador
                   "       b.pstcoddig,", # Codigo do Prestador
                   "       b.viginc,",    # Vigencia inicial do Socorrista X Prestador
                   "       b.vigfnl,",    # Vigencia final do Socorrista X Prestador
                   "       a.cgccpfnum,", # Numero do CPF/CNPJ do Socorrista
                   "       a.cgcord,",    # Ordem do CPF/CNPJ do Socorrista
                   "       a.cgccpfdig,", # Digito do CPF/CNPJ do Socorrista
                   "       b.pstvintip,", # Tipo do vinculo do Socorrista X Prestador
                   "       c.endcid,",    # Cidade da base
                   "       c.endufd ",    # UF da base
                   "  from datksrr a,",
                   "       datrsrrpst b,",
                   "       dpaksocor  c",
                   " where a.srrcoddig = b.srrcoddig",
                   "   and b.pstcoddig = c.pstcoddig",
                   "   and a.srrstt = 1     ",
                   "   and b.pstvintip in (",m_bdbsa131.cpodes_vinc clipped,") ",
                   "   and a.srrtip    in (",m_bdbsa131.cpodes_tipo clipped,") ",
                   "   and b.vigfnl = (select max(vigfnl)   ",
                   "                      from datrsrrpst e ",
                   "                     where e.srrcoddig = b.srrcoddig)",
                   "   and a.cgccpfnum is not null ",
                   "   and exists (select 1 ",
		                  "  from iddkdominio ",
		                 "  where cponom = 'PSTQLDVID' ",
				    " and cpocod =  c.qldgracod) ",
                   "order by srrcoddig "

        prepare pbdbsa131_01 from l_sql
        declare cbdbsa131_01 cursor for pbdbsa131_01
         display "l_sql: ",l_sql clipped

         open cbdbsa131_01  using  m_bdbsa131.cpodes_vinc
         foreach cbdbsa131_01 into mr_bdbsa131.srrabvnom,
                                   mr_bdbsa131.srrcoddig,
                                   mr_bdbsa131.srrnom   ,
                                   mr_bdbsa131.nomgrr,
                                   mr_bdbsa131.pstcoddig,
                                   mr_bdbsa131.viginc   ,
                                   mr_bdbsa131.vigfnl   ,
                                   mr_bdbsa131.cgccpfnum,
                                   mr_bdbsa131.cgcord   ,
                                   mr_bdbsa131.cgccpfdig,
                                   mr_bdbsa131.pstvintip,
                                   mr_bdbsa131.endcid,
                                   mr_bdbsa131.endufd

               # Verifica a ordem para nao mandar nulo
               if mr_bdbsa131.cgcord is null or
                  mr_bdbsa131.cgcord = "" then
                     let mr_bdbsa131.cgcord = 0
               end if
                display "=================================================================="
                display "mr_bdbsa131.srrcoddig: ",mr_bdbsa131.srrcoddig
               #---------------------------------------------------------------|
               # VERIFICA SE SOCORRISTA TEM SEGURO DE VIDA                     |
               #---------------------------------------------------------------|

               initialize lr_bdbsa131Vida.* to null
               call ovgea017(0,
                             0,
                             mr_bdbsa131.cgccpfnum,
                             mr_bdbsa131.cgcord,
                             mr_bdbsa131.cgccpfdig,
                             6)
                   returning lr_bdbsa131Vida.critica1,
                             lr_bdbsa131Vida.critica2,
                             lr_bdbsa131Vida.critica3,
                             lr_bdbsa131Vida.critica4,
                             lr_bdbsa131Vida.critica5,
                             lr_bdbsa131Vida.critica6,
                             lr_bdbsa131Vida.critica7

               if lr_bdbsa131Vida.critica1 is null and
                  lr_bdbsa131Vida.critica2 is null and
                  lr_bdbsa131Vida.critica3 is null and
                  lr_bdbsa131Vida.critica4 is null and
                  lr_bdbsa131Vida.critica5 is null and
                  lr_bdbsa131Vida.critica6 is null and
                  lr_bdbsa131Vida.critica7 is null then
                  let l_socvidseg = 'N'
               else
                  let l_socvidseg = 'S'
               end if

              if l_socvidseg = 'N' then

                  let m_bdbsa131.avstip = "Não Bloqueado"
                  #--------------------------------------------|
                  # VERIFICA SE BLOQUEIA OU NÃO OS SOCORRISTAS |
                  #--------------------------------------------|
                  if m_bdbsa131.cpodes_bloq = 'S' or
                     m_bdbsa131.cpodes_bloq = 's' then

                     let l_cidsedcod = null
                     open cbdbsa131_10 using mr_bdbsa131.endcid,
                                             mr_bdbsa131.endufd
                     fetch cbdbsa131_10 into l_cidsedcod
                     close cbdbsa131_10

                     display "mr_bdbsa131.endcid = ",mr_bdbsa131.endcid
                     display "mr_bdbsa131.endufd = ",mr_bdbsa131.endufd
                     display "l_cidsedcod        = ",l_cidsedcod

                     if bdbsa131_validade_bql(l_cidsedcod) then
                        #---------------------|
                        # BLOQUEIA SOCORRISTA |
                        #---------------------|
                        whenever error continue
                           execute pbdbsa131_04 using mr_bdbsa131.srrcoddig
                        whenever error continue
                        let m_bdbsa131.avstip = "Bloqueado"

                        display "m_bdbsa131.avstip = ",m_bdbsa131.avstip
                        #----------------------------------------------------|
                        # BUSCA A ULTIMA SEQUENCIA DO BLOQUEIO DO SOCORRISTA |
                        #----------------------------------------------------|

                        whenever error continue
                           open cbdbsa131_06 using mr_bdbsa131.srrcoddig
                           fetch cbdbsa131_06 into mr_bdbsa131.srrblqseq
                           display "sqlca.sqlcode: ",sqlca.sqlcode
                           if sqlca.sqlcode <> 0 then
                              display "Erro ao buscar a sequencia do bloqueio do socorrista! SqlCode: ",sqlca.sqlcode
                           else
                              if sqlca.sqlcode = notfound      or
                                 sqlca.sqlcode = 100           or
                                 mr_bdbsa131.srrblqseq is null or
                                 mr_bdbsa131.srrblqseq = ''    or
                                 mr_bdbsa131.srrblqseq = 0     then

                                 let mr_bdbsa131.srrblqseq = 1
                              else
                                 let mr_bdbsa131.srrblqseq = mr_bdbsa131.srrblqseq + 1
                              end if
                           end if
                           display "mr_bdbsa131.srrblqseq: ",mr_bdbsa131.srrblqseq
                           close cbdbsa131_06
                        whenever error stop

                        #-----------------------------------------------------|
                        # INSERIR NA TABELA OS DADOS DO BLOQUEIO DO SOCORRISTA |
                        #-----------------------------------------------------|
                          whenever error continue
                           execute pbdbsa131_07 using mr_bdbsa131.srrcoddig,
                                                      mr_bdbsa131.srrblqseq,
                                                      mr_bdbsa131.srrblqdat,
                                                      g_issk.funmat,
                                                      'B',
                                                      ' '
                           display "Inserir sqlca.sqlcode: ",sqlca.sqlcode
                          whenever error continue


                        let mensagem = 'Analise do sistema de controle de seguro de vida:', mr_bdbsa131.srrblqdat,' ',datahora
                        let mensagem2 =  'Este socorrista foi bloqueado por nao possuir seguro de vida'

                             #-------------------------------------------------------|
                             # GRAVA NO HISTORICO DO SOCORRISTA O PORQUE DO BLOQUEIO |
                             #-------------------------------------------------------|
                             call ctd18g01_grava_hist(mr_bdbsa131.srrcoddig ,
                                                      mensagem,
                                                      today,
                                                      g_issk.empcod,
                                                      g_issk.funmat,
                                                      'F')
                             returning lr_retorno.stt
                                      ,lr_retorno.msg

                             if lr_retorno.stt <> 1 then
                                display "Erro ao gravar o historico do Socorrista: ",lr_retorno.stt
                                display "Mensagem: ",lr_retorno.msg
                             end if

                            #----------------------------------------------------------|
                            # GRAVA NO HISTORICO DO SOCORRISTA para quebrar a mensagem |
                            #----------------------------------------------------------|
                             call ctd18g01_grava_hist(mr_bdbsa131.srrcoddig ,
                                                      mensagem2,
                                                      today,
                                                      g_issk.empcod,
                                                      g_issk.funmat,
                                                      'F')
                             returning lr_retorno.stt
                                     ,lr_retorno.msg

                             if lr_retorno.stt <> 1 then
                               display "Erro ao gravar o historico do Socorrista: ",lr_retorno.stt
                               display "Mensagem: ",lr_retorno.msg
                             end if

                     else
                         display "PARA CIDADE SEDE NÃO HAVERA BLOQUEIO"
                     end if
                     #-------------------------------------------|
                     # NUMERO DE SOCORRISTAS SEM SEGURO DE VIDA  |
                     #-------------------------------------------|
                     let m_count = m_count +1

                  else
                    # 02/09/2010 Beatriz Araujo
                    #  let mensagem = 'Analise do sistema de controle de seguro de vida:', mr_bdbsa131.srrblqdat,' ',datahora
                    #  let mensagem2= 'Este socorrista nao possui seguro de vida, mas nao foi bloqueado'
                    #
                    # #-----------------------------------------------------------|
                    # # GRAVA NO HISTORICO DO SOCORRISTA O PORQUE DO NAO BLOQUEIO |
                    # #-----------------------------------------------------------|
                    # call ctd18g01_grava_hist(mr_bdbsa131.srrcoddig ,
                    #                          mensagem,
                    #                          today,
                    #                          g_issk.empcod,
                    #                          g_issk.funmat,
                    #                          'F')
                    # returning lr_retorno.stt
                    #         ,lr_retorno.msg
                    #
                    # if lr_retorno.stt <> 1 then
                    #   display "Erro ao gravar o historico do Socorrista: ",lr_retorno.stt
                    #   display "Mensagem: ",lr_retorno.msg
                    # end if
                    #
                    #
                    # #-----------------------------------------------------------|
                    # # GRAVA NO HISTORICO DO SOCORRISTA para quebrar a mensagem  |
                    # #-----------------------------------------------------------|
                    # call ctd18g01_grava_hist(mr_bdbsa131.srrcoddig ,
                    #                          mensagem2,
                    #                          today,
                    #                          g_issk.empcod,
                    #                          g_issk.funmat,
                    #                          'F')
                    # returning lr_retorno.stt
                    #         ,lr_retorno.msg
                    #
                    # if lr_retorno.stt <> 1 then
                    #   display "Erro ao gravar o historico do Socorrista: ",lr_retorno.stt
                    #   display "Mensagem: ",lr_retorno.msg
                    # end if
                    #


                      #-------------------------------------------|
                      # NUMERO DE SOCORRISTAS SEM SEGURO DE VIDA  |
                      #-------------------------------------------|
                      let m_count = m_count +1

                  end if

                  #------------------------------------------|
                  # BUSCA DESCRICAO DO VINCULO DO SOCORRISTA |
                  #------------------------------------------|
                  whenever error continue
                     open cbdbsa131_05 using mr_bdbsa131.pstvintip
                     fetch cbdbsa131_05 into m_bdbsa131.descvintip
                     if sqlca.sqlcode <> 0 then
                        display "Erro ao buscar descricao do vinculo! SqlCode: ",sqlca.sqlcode
                     end if
                     close cbdbsa131_05
                  whenever error stop


		  #------------------------------------------------|
                  # BUSCA CODIGO DA CADEIA DE GESTAO DO SOCORRISTA |
                  #------------------------------------------------|
		  open cbdbsa131_08 using mr_bdbsa131.pstcoddig
                  fetch cbdbsa131_08 into mr_cda_gestao.gstcdicod

	          open cbdbsa131_09 using mr_cda_gestao.gstcdicod

	          fetch cbdbsa131_09 into mr_cda_gestao.sprnom,
	     		                  mr_cda_gestao.gernom,
	     			          mr_cda_gestao.cdnnom,
	     			          mr_cda_gestao.anlnom

		  if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
		     initialize mr_cda_gestao.* to null
		     return  0
		  end if


                  #----------------------------------|
                  # ADICIONA SOCORRISTA NO RELATORIO |
                  #----------------------------------|
                  output to report bdbsa131_relat()
                  output to report bdbsa131_relat_txt() #--> RELTXT

              end if
         end foreach

               if m_count = 0 then
                  start report bdbsa131_relat_sem to m_bdbsa131.path_rel
                  output to report bdbsa131_relat_sem()
                  finish report bdbsa131_relat_sem
               end if
              #-----------------------------------|
              # FIM DO RELATORIO E ENVIO DE EMAIL |
              #-----------------------------------|
             finish report bdbsa131_relat
             finish report bdbsa131_relat_txt #--> RELTXT

            display "m_bdbsa131.path_rel: ",m_bdbsa131.path_rel
            call ctx22g00_envia_email("BDBSA131",
                                      "Relatorio de socorristas sem seguro de vida",
                                      m_bdbsa131.path_rel)
                 returning lr_retorno.cod
            display "lr_retorno.cod: ",lr_retorno.cod


      whenever error stop

end function

#-----------------------#
 report bdbsa131_relat()
#-----------------------#

     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    07

     format

         first page header

             print "RELATORIO DE SOCORRISTAS QUE NÃO POSSUEM SEGURO DE VIDA E SERAO BLOQUEADOS."
             print ""
             print "CODIGO DO SOCORRISTA", ASCII(09),
                   "NOME SOCORRISTA", ASCII(09),
                   "CODIGO DO PRESTADOR", ASCII(09),
                   "NOME DE GUERRA DO PRESTADOR", ASCII(09),
                   #"VIGENCIA INCIAL", ASCII(09),
                   #"VIGENCIA FINAL ", ASCII(09),
                   "CPF/CNPJ DO SOCORRISTA", ASCII(09),
                   "VINCULO ", ASCII(09),
                   "BLOQUEADO", ASCII(09),
                   "CADEIA DE GESTAO", ASCII(09),
                   "DATA" #--> FX-080515

        on every row

             print mr_bdbsa131.srrcoddig,ASCII(09),
                   mr_bdbsa131.srrnom,ASCII(09),
                   mr_bdbsa131.pstcoddig,ASCII(09),
                   mr_bdbsa131.nomgrr,ASCII(09);
                   #mr_bdbsa131.viginc,ASCII(09),
                   #mr_bdbsa131.vigfnl,ASCII(09);

                   if mr_bdbsa131.cgcord <> 0 then
                      print mr_bdbsa131.cgccpfnum,'/',mr_bdbsa131.cgcord,'-',
                      mr_bdbsa131.cgccpfdig,ASCII(09);
                   else
                      print mr_bdbsa131.cgccpfnum,'-',
                      mr_bdbsa131.cgccpfdig,ASCII(09);
                   end if
                   print m_bdbsa131.descvintip,ASCII(09),
                         m_bdbsa131.avstip,ASCII(09);

                   print mr_cda_gestao.sprnom,"/",
             	   	       mr_cda_gestao.gernom,"/",
             	   	       mr_cda_gestao.cdnnom,"/",
             	   	       mr_cda_gestao.anlnom,ASCII(09);
                   print today #--> FX-080515

        on last row
                  print " "
                  print "-------------------------------------------------------------------"
                  print "Total de Socorristas sem seguro de vida ...: ", m_count

end report

#---------------------------------------#
 report bdbsa131_relat_txt() #--> RELTXT
#---------------------------------------#

     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    01

     format

        on every row

             print mr_bdbsa131.srrcoddig,ASCII(09),
                   mr_bdbsa131.srrnom,   ASCII(09),
                   mr_bdbsa131.pstcoddig,ASCII(09),
                   mr_bdbsa131.nomgrr,   ASCII(09);
                  #mr_bdbsa131.viginc,   ASCII(09),
                  #mr_bdbsa131.vigfnl,   ASCII(09);

                   if mr_bdbsa131.cgcord <> 0 then
                      print mr_bdbsa131.cgccpfnum,'/',mr_bdbsa131.cgcord,'-',
                      mr_bdbsa131.cgccpfdig,ASCII(09);
                   else
                      print mr_bdbsa131.cgccpfnum clipped,'-',
                      mr_bdbsa131.cgccpfdig,ASCII(09);
                   end if

                   print m_bdbsa131.descvintip clipped,ASCII(09),
                         m_bdbsa131.avstip clipped,ASCII(09);

                   print mr_cda_gestao.sprnom,"/",
             	   	 mr_cda_gestao.gernom,"/",
             	   	 mr_cda_gestao.cdnnom,"/",
             	   	 mr_cda_gestao.anlnom, ASCII(09);
                   print today #--> FX-080515

end report

#---------------------------#
 report bdbsa131_relat_sem()
#---------------------------#

        output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    07

     format

         first page header

             print "RELATORIO DE SOCORRISTAS QUE NÃO POSSUEM SEGURO DE VIDA E SERAO BLOQUEADOS."
             print ""
             print "CODIGO DO SOCORRISTA                      ", ASCII(09),
                   "NOME DE GUERRA DO SOCORRISTA              ", ASCII(09),
                   "CODIGO DO PRESTADOR                       ", ASCII(09),
                   "NOME DE GUERRA DO PRESTADOR               ", ASCII(09),
                   "VIGENCIA INCIAL DO SOCORRISTA X PRESTADOR ", ASCII(09),
                   "VIGENCIA FINAL DO SOCORRISTA X PRESTADOR  ", ASCII(09),
                   "NUMERO DO CPF/CNPJ DO SOCORRISTA          ", ASCII(09),
                   "ORDEM DO CPF/CNPJ DO SOCORRISTA           ", ASCII(09),
                   "DIGITO DO CPF/CNPJ DO SOCORRISTA          ", ASCII(09),
                   "VINCULO DO SOCORRISTA X PRESTADOR         ", ASCII(09),
                   "BLOQUEADO                                 "
        on every row

             print "Nao existe socorrista sem seguro de vida ", ASCII(09);

        on last row
                  print " "
                  print "-------------------------------------------------------------------"
                  print "Total de Socorristas sem seguro de vida ...: ", m_count

end report

#--------------------------------#
function bdbsa131_validade_bql(l_cidsedcod)
#--------------------------------#

     define l_param  char(25),
            l_cpodes like datkdominio.cpodes,
            l_cidsedcod like datrcidsed.cidsedcod

     let l_param = 'blqcidsedqra'

     whenever error continue
     open cbdbsa131_11 using l_param, l_cidsedcod
     fetch cbdbsa131_11 into l_cpodes

     if  sqlca.sqlcode = notfound then
         close cbdbsa131_11
         whenever error stop
         return true
     end if

     close cbdbsa131_11
     whenever error stop

     if l_cpodes is null or l_cpodes = '' then
         return true
     end if

     return false

end function
