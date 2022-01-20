#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR041                                                   #
# ANALISTA RESP..: RAFAEL MOREIRA GOMES                                       #
# PSI/OSF........: Servicos Atendidos                                         #
# ........................................................................... #
# DESENVOLVIMENTO: FORNAX TECNOLOGIA, RCP                                     #
# LIBERACAO......: 19/05/2015                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 08/06/2015 RCP, Fornax     RELTXT     Criar versao .txt dos relatorios.     #
#-----------------------------------------------------------------------------#
# 05/10/2015 Eliane,Fornax   Abort      Aumentar informacao de erro SQL e     #
#                                       consistir a consulta SQL para <> null #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_path           char(100)
     , m_path_txt       char(100) #--> RELTXT
     , m_data           date

define mr_datmservico   record
       atdsrvnum        like datmservico.atdsrvnum   #Numero do Servico
     , atdsrvano        like datmservico.atdsrvano   #Ano do Servico
     , atddat           like datmservico.atddat      #Data de Atendimento
     , atdhor           like datmservico.atdhor      #Hora de Atendimento
     , srvprsacndat     date
     , srvprsacnhor     datetime hour to minute
     , atdsrvorg        like datmservico.atdsrvorg   #Origem do Servico
     , ciaempcod        like datmservico.ciaempcod   #Empresa do Servico
     , atdprscod        like datmservico.atdprscod   #Prestador
     , srrcoddig        like datmservico.srrcoddig   #Socorrista
     , atdvclsgl        like datmservico.atdvclsgl   #Sigla do veiculo
     , socvclcod        like datmservico.socvclcod   #Codigo do veiculo
     , asitipcod        like datmservico.asitipcod   #Codigo Assistencia
     , vclcoddig        like datmservico.vclcoddig   #Codigo Modelo Veiculo
     , vclanomdl        like datmservico.vclanomdl   #Ano Modelo Veiculo
     , cornom           like datmservico.cornom      #Nome Corretor
     , corsus           like datmservico.corsus      #SUSEP Corretor
     , nom              like datmservico.nom         #Nome padrao
end    record

define mr_datmligacao record
       c24astcod       like datmligacao.c24astcod
     , socntzgrpdes    like datksocntzgrp.socntzgrpdes
     , c24pbmgrpcod    like datkpbmgrp.c24pbmgrpcod
end    record

define mr_datmatd6523   record
       cgccpfnum        like datmatd6523.cgccpfnum   #CPF
     , cgcord           like datmatd6523.cgcord      #Oridem
     , cgccpfdig        like datmatd6523.cgccpfdig   #Digito
end    record

define mr_datrservapol  record
       succod           like datrservapol.succod     #Sucursal
     , ramcod           like datrservapol.ramcod     #Ramo
     , aplnumdig        like datrservapol.aplnumdig  #Apolice
     , itmnumdig        like datrservapol.itmnumdig  #Item
end    record

define mr_datketapa     record
       atdetpdes        like datketapa.atdetpdes     #Descricao Etapa
end    record

define mr_dpaksocor     record
       pstcoddig        like dpaksocor.pstcoddig     #Codigo Prestador
     , pptnom           like dpaksocor.pptnom        #Nome Prestador
     , endcid           like dpaksocor.endcid        #Cidade Prestador
     , endufd           like dpaksocor.endufd        #UF Prestador
     , pcpatvcod        like dpaksocor.pcpatvcod     #Codigo Atividade Principal
end    record

define mr_datksrr       record
       srrnom           like datksrr.srrnom          #Nome Socorrista
end    record

define mr_datmlcl       record
       cidnom           like datmlcl.cidnom           #Cidade
     , ufdcod           like datmlcl.ufdcod           #UF
end    record

define mr_datrcidsed    record
       cidsedcodsrv     like glakcid.cidnom           #Cidade
     , cidsedcodpst     like glakcid.cidnom           #Cidade
end    record

define mr_datkpbm       record
       c24pbmdes        like datkpbm.c24pbmdes        #Descricao Problema
     , c24pbmgrpdes     like datkpbmgrp.c24pbmgrpdes  #Descricao Grupo Problerma
end    record

define mr_datksocntz    record
       socntzdes        like datksocntz.socntzdes     #Descricao Natureza
end    record

define mr_datkassunto   record
       c24astdes        like datkassunto.c24astdes    #Descricao Assunto Ligacao
end    record

define mr_pcgksusep     record
       succod           like pcgksusep.succod         #Sucursal
end    record

define mr_abbmveic      record
       vcllicnum        like abbmveic.vcllicnum       #Placa
     , vclchsinc        like abbmveic.vclchsinc       #Chassi - inicio
     , vclchsfnl        like abbmveic.vclchsfnl       #Chassi - final
     , vclanofbc        like abbmveic.vclanofbc       #Ano Fabricacao Veiculo
end    record

define mr_datkasitip    record
       asitipdes        like datkasitip.asitipdes     #Descricao Assistencia
end    record

define mr_gabksuc       record
       sucnomapl        like gabksuc.sucnom           #Nome Sucursal
     , sucnomcor        like gabksuc.sucnom           #Nome Sucursal
end    record

define mr_datksrvtip    record
       srvtipdes        like datksrvtip.srvtipdes     #Descricao Tipo Servico
end    record

define mr_iddkdominio   record
       socvclcoddes     like iddkdominio.cpodes       #Descricao Campo
     , pcpatvcoddes     like iddkdominio.cpodes       #Descricao Campo
end    record


main

    call fun_dba_abre_banco("CT24HS")

    call bdbsr041_busca_path()

    call bdbsr041_prepare()

    call cts40g03_exibe_info("I","BDBSR041")

    set isolation to dirty read

    call bdbsr041_servicosAtendidos()

    call bdbsr041_envia_email()

    call cts40g03_exibe_info("F","BDBSR041")

end main


#------------------------------#
 function bdbsr041_busca_path()
#------------------------------#

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
    let m_path_txt = null #--> RELTXT

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr041.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_path_txt = m_path clipped, "/BDBSR041_", l_dataarq, ".txt"
    let m_path     = m_path clipped, "/BDBSR041_", l_dataarq, ".xls"

 end function


#---------------------------#
 function bdbsr041_prepare()
#---------------------------#
  define l_sql char(1000)
  define l_data_inicio, l_data_fim date
  define l_data_atual date,
         l_hora_atual datetime hour to minute

  initialize m_data to null

  let l_data_atual = arg_val(1)

  # ---> OBTER A DATA E HORA DO BANCO
  if l_data_atual is null then
     call cts40g03_data_hora_banco(2)
          returning l_data_atual,
                    l_hora_atual

     let m_data = l_data_atual
  end if

  display "l_data_atual: ",l_data_atual

  let l_data_inicio = l_data_atual - 1 # ---> Programa de processamento diario
  let l_data_fim    = l_data_atual - 1 # ---> Programa de processamento diario
  let m_data = l_data_inicio

  # ---> OBTEM DADOS PARA O RELATORIO
  let l_sql = " select atdsrvnum       "
            , "      , atdsrvano       "
            , "      , atddat          "
            , "      , atdhor          "
            , "      , srvprsacnhordat "
            , "      , srvprsacnhordat "
            , "      , atdsrvorg       "
            , "      , ciaempcod       "
            , "      , atdprscod       "
            , "      , srrcoddig       "
            , "      , atdvclsgl       "
            , "      , socvclcod       "
            , "      , asitipcod       "
            , "      , vclcoddig       "
            , "      , vclanomdl       "
            , "      , cornom          "
            , "      , corsus          "
            , "      , nom             "
            , "  from datmservico      "
            , " where atddat between '", l_data_inicio, "' and '", l_data_fim, "'"
              prepare pbdbsr041001 from l_sql
  declare cbdbsr041001 cursor for pbdbsr041001

  let l_sql = " select cgccpfnum  "
            , "      , cgcord     "
            , "      , cgccpfdig  "
            , "  from datmatd6523 "
            , " where atdnum = ?  "
  prepare pbdbsr041002 from l_sql
  declare cbdbsr041002 cursor for pbdbsr041002

  let l_sql = " select succod        "
            , "      , ramcod        "
            , "      , aplnumdig     "
            , "      , itmnumdig     "
            , "   from datrservapol  "
            , "  where atdsrvnum = ? "
            , "    and atdsrvano = ? "
  prepare pbdbsr041003 from l_sql
  declare cbdbsr041003 cursor for pbdbsr041003

  let l_sql = " select b.atdetpdes               "
            , "   from datmsrvacp a, datketapa b "
            , "  where a.atdsrvnum = ?           "
            , "    and a.atdsrvano = ?           "
            , "    and b.atdetpcod = a.atdetpcod "
            , "  order by a.atdsrvseq desc       "
  prepare pbdbsr041004 from l_sql
  declare cbdbsr041004 cursor for pbdbsr041004

  let l_sql = " select pstcoddig "
            , "      , pptnom    "
            , "      , endcid    "
            , "      , endufd    "
            , "      , pcpatvcod "
            , "   from dpaksocor "
            , "  where pstcoddig = ? "
  prepare pbdbsr041005 from l_sql
  declare cbdbsr041005 cursor for pbdbsr041005

  let l_sql = " select srrnom  "
            , "   from datksrr srr "
            , "  where srrcoddig = ? "
  prepare pbdbsr041006 from l_sql
  declare cbdbsr041006 cursor for pbdbsr041006

  let l_sql = " select cidnom        "
            , "      , ufdcod        "
            , "   from datmlcl       "
            , "  where atdsrvnum = ? "
            , "    and atdsrvano = ? "
            , "    and c24endtip = 1 "
  prepare pbdbsr041008 from l_sql
  declare cbdbsr041008 cursor for pbdbsr041008

  let l_sql = " select srvtipdes     "
            , "   from datksrvtip    "
            , "  where atdsrvorg = ? "
  prepare pbdbsr041009 from l_sql
  declare cbdbsr041009 cursor for pbdbsr041009

  let l_sql = " select c.cidnom "
            , "   from glakcid a, datrcidsed b, glakcid c "
            , "  where a.cidnom = ? "
            , "    and a.ufdcod = ? "
            , "    and b.cidcod = a.cidcod "
            , "    and c.cidcod = a.cidcod "
  prepare pbdbsr041010 from l_sql
  declare cbdbsr041010 cursor for pbdbsr041010

  let l_sql = " select asitipdes     "
            , "   from datkasitip    "
            , "  where asitipcod = ? "
  prepare pbdbsr041011 from l_sql
  declare cbdbsr041011 cursor for pbdbsr041011

  let l_sql = " select b.c24pbmdes    "
            , "      , c.c24pbmgrpdes "
            , "   from datrsrvpbm a, datkpbm b, datkpbmgrp c "
            , "  where a.atdsrvnum    = ? "
            , "    and a.atdsrvano    = ? "
            , "    and b.c24pbmcod    = a.c24pbmcod    "
            , "    and c.c24pbmgrpcod = b.c24pbmgrpcod "
  prepare pbdbsr041012 from l_sql
  declare cbdbsr041012 cursor for pbdbsr041012

  let l_sql = " select b.c24astdes "
            , "   from datmligacao a, datkassunto b "
            , "  where a.atdsrvnum = ? "
            , "    and a.atdsrvano = ? "
            , "    and b.c24astcod = a.c24astcod "
  prepare pbdbsr041013 from l_sql
  declare cbdbsr041013 cursor for pbdbsr041013

  let l_sql = " select b.socntzdes               "
            , "   from datmsrvre a, datksocntz b "
            , "  where atdsrvnum   = ?           "
            , "    and atdsrvano   = ?           "
            , "    and b.socntzcod = a.socntzcod "
  prepare pbdbsr041014 from l_sql
  declare cbdbsr041014 cursor for pbdbsr041014

  let l_sql = " select succod     "
            , "   from pcgksusep  "
            , "  where corsus = ? "
  prepare pbdbsr041015 from l_sql
  declare cbdbsr041015 cursor for pbdbsr041015

  let l_sql = " select vcllicnum "
            , "      , vclchsinc "
            , "      , vclchsfnl "
            , "      , vclanofbc "
            , "   from abbmveic  "
            , "  where succod    = ? "
            , "    and aplnumdig = ? "
            , "    and itmnumdig = ? "
            , "  order by dctnumseq desc "
  prepare pbdbsr041016 from l_sql
  declare cbdbsr041016 cursor for pbdbsr041016

  let l_sql = " select sucnom     "
            , "   from gabksuc    "
            , "  where succod = ? "
  prepare pbdbsr041017 from l_sql
  declare cbdbsr041017 cursor for pbdbsr041017

  let l_sql = " select cpodes      "
            , "   from iddkdominio "
            , "  where cponom = ?  "
            , "    and cpocod = ?  "
  prepare pbdbsr041018 from l_sql
  declare cbdbsr041018 cursor for pbdbsr041018

  let l_sql = " select c24astcod      "
            , "   from datmligacao    "
            , "  where atdsrvnum = ?  "
            , "    and atdsrvano = ?  "
  prepare pbdbsr041019 from l_sql
  declare cbdbsr041019 cursor for pbdbsr041019

  let l_sql = " select c24pbmgrpcod   "
            , "   from datkpbm        "
            , "  where c24astcod = ?  "
  prepare pbdbsr041020 from l_sql
  declare cbdbsr041020 cursor for pbdbsr041020

  let l_sql = " select gntz.socntzgrpdes  "
            , "   from datksocntz ntz     "
            , "       ,datksocntzgrp gntz "
            , "  where ntz.socntzgrpcod = gntz.socntzgrpcod "
            , "    and ntz.c24pbmgrpcod = ?   "
  prepare pbdbsr041021 from l_sql
  declare cbdbsr041021 cursor for pbdbsr041021

end  function


#-------------------------------------#
 function bdbsr041_servicosAtendidos()
#-------------------------------------#

   define l_cponom like iddkdominio.cponom

   initialize mr_datmservico.*
            , mr_datmatd6523.*
            , mr_datrservapol.*
            , mr_datketapa.*
            , mr_dpaksocor.*
            , mr_datksrr.*
            , mr_datmlcl.*
            , mr_datrcidsed.*
            , mr_datkpbm.*
            , mr_datksocntz.*
            , mr_datkassunto.*
            , mr_pcgksusep.*
            , mr_abbmveic.*
            , mr_datmligacao.*
	          , mr_datkasitip.*
	          , mr_datksrvtip.*
	          , mr_gabksuc.*
	          , mr_iddkdominio to null

   start report bdbsr041_relatorio to m_path
   start report bdbsr041_relatorio_txt to m_path_txt #--> RELTXT

   whenever error continue

   open cbdbsr041001
   foreach cbdbsr041001 into mr_datmservico.*

      open cbdbsr041009  using mr_datmservico.atdsrvorg
      fetch cbdbsr041009 into mr_datksrvtip.srvtipdes
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041009 sqlcode: ", sqlca.sqlcode
         initialize mr_datksrvtip.srvtipdes to null
      end if
      close cbdbsr041009

      let l_cponom = "socvclcod"
      open cbdbsr041018 using l_cponom
                        ,mr_datmservico.socvclcod
      fetch cbdbsr041018 into mr_iddkdominio.socvclcoddes
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041018 sqlcode: ", sqlca.sqlcode
         initialize mr_iddkdominio.socvclcoddes to null
      end if
      close cbdbsr041018

      open cbdbsr041011 using mr_datmservico.asitipcod
      fetch cbdbsr041011 into mr_datkasitip.asitipdes
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041011 sqlcode: ", sqlca.sqlcode
         initialize mr_datkasitip.* to null
      end if
      close cbdbsr041011

      open cbdbsr041002 using mr_datmservico.atdsrvnum
      fetch cbdbsr041002 into mr_datmatd6523.*
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041002 sqlcode: ", sqlca.sqlcode
         initialize mr_datmatd6523.* to null
      end if
      close cbdbsr041002

      open cbdbsr041003 using mr_datmservico.atdsrvnum
                            , mr_datmservico.atdsrvano
      fetch cbdbsr041003 into mr_datrservapol.*
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041003 sqlcode: ", sqlca.sqlcode
         initialize mr_datrservapol.* to null
      end if
      close cbdbsr041003

      open cbdbsr041017 using mr_datrservapol.succod
      fetch cbdbsr041017 into mr_gabksuc.sucnomapl
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041017 sqlcode: ", sqlca.sqlcode
         initialize mr_gabksuc.sucnomapl to null
      end if
      close cbdbsr041017

      open cbdbsr041004 using mr_datmservico.atdsrvnum
                            , mr_datmservico.atdsrvano
      fetch cbdbsr041004 into mr_datketapa.*
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041004 sqlcode: ", sqlca.sqlcode
         initialize mr_datketapa.* to null
      end if
      close cbdbsr041004

      open cbdbsr041005 using mr_datmservico.atdprscod
      fetch cbdbsr041005 into mr_dpaksocor.*
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041005 sqlcode: ", sqlca.sqlcode
         initialize mr_dpaksocor.* to null
      end if
      close cbdbsr041005

      let l_cponom = "pcpatvcod"
      open cbdbsr041018 using l_cponom
			    , mr_dpaksocor.pcpatvcod
      fetch cbdbsr041018 into mr_iddkdominio.pcpatvcoddes
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041018 sqlcode: ", sqlca.sqlcode
         initialize mr_iddkdominio.pcpatvcoddes to null
      end if
      close cbdbsr041018

      open cbdbsr041010 using mr_dpaksocor.endcid
			    , mr_dpaksocor.endufd
      fetch cbdbsr041010 into mr_datrcidsed.cidsedcodpst
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041010 sqlcode: ", sqlca.sqlcode
         initialize mr_datrcidsed.cidsedcodpst to null
      end if
      close cbdbsr041010

      open cbdbsr041006 using mr_datmservico.srrcoddig
      fetch cbdbsr041006 into mr_datksrr.*
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041006 sqlcode: ", sqlca.sqlcode
         initialize mr_datksrr.* to null
      end if
      close cbdbsr041006

      open cbdbsr041008 using mr_datmservico.atdsrvnum
                            , mr_datmservico.atdsrvano
      fetch cbdbsr041008 into mr_datmlcl.*
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041008 sqlcode: ", sqlca.sqlcode
         initialize mr_datmlcl.* to null
      end if
      close cbdbsr041008

      open cbdbsr041010 using mr_datmlcl.cidnom
			    , mr_datmlcl.ufdcod
      fetch cbdbsr041010 into mr_datrcidsed.cidsedcodsrv
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041010 sqlcode: ", sqlca.sqlcode
         initialize mr_datrcidsed.cidsedcodsrv to null
      end if
      close cbdbsr041010

      open cbdbsr041012 using mr_datmservico.atdsrvnum
                            , mr_datmservico.atdsrvano
      fetch cbdbsr041012 into mr_datkpbm.*
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041012 sqlcode: ", sqlca.sqlcode
         initialize mr_datkpbm.* to null
      end if
      close cbdbsr041012

      open cbdbsr041013 using mr_datmservico.atdsrvnum
			    , mr_datmservico.atdsrvano
      fetch cbdbsr041013 into mr_datkassunto.*
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041013 sqlcode: ", sqlca.sqlcode
         initialize mr_datkassunto.* to null
      end if
      close cbdbsr041013

      open cbdbsr041014 using mr_datmservico.atdsrvnum
			    , mr_datmservico.atdsrvano
      fetch cbdbsr041014 into mr_datksocntz.*
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041014 sqlcode: ", sqlca.sqlcode
         initialize mr_datksocntz.* to null
      end if
      close cbdbsr041014

      open cbdbsr041015 using mr_datmservico.corsus
      fetch cbdbsr041015 into mr_pcgksusep.*
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041015 sqlcode: ", sqlca.sqlcode
         initialize mr_pcgksusep.* to null
      end if
      close cbdbsr041015

      open cbdbsr041017 using mr_pcgksusep.succod
      fetch cbdbsr041017 into mr_gabksuc.sucnomcor
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041017 sqlcode: ", sqlca.sqlcode
         initialize mr_gabksuc.sucnomcor to null
      end if
      close cbdbsr041017

      open cbdbsr041016 using mr_datrservapol.succod
			    , mr_datrservapol.aplnumdig
			    , mr_datrservapol.itmnumdig
      fetch cbdbsr041016 into mr_abbmveic.*
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041016 sqlcode: ", sqlca.sqlcode
         initialize mr_abbmveic.* to null
      end if
      close cbdbsr041016

      open cbdbsr041019 using mr_datmservico.atdsrvnum
			                      , mr_datmservico.atdsrvano
      fetch cbdbsr041019 into mr_datmligacao.c24astcod
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041019 sqlcode: ", sqlca.sqlcode
         initialize mr_datmligacao.* to null
      end if
      close cbdbsr041019

     if mr_datmligacao.c24astcod is not null then

      open cbdbsr041020 using mr_datmligacao.c24astcod
      fetch cbdbsr041020 into mr_datmligacao.c24pbmgrpcod
      if sqlca.sqlcode <> 0 then
         display "cbdbsr041020 sqlcode: ", sqlca.sqlcode
         initialize mr_datmligacao.* to null
         close cbdbsr041020
      else
	 close cbdbsr041020
         open cbdbsr041021 using mr_datmligacao.c24pbmgrpcod
         fetch cbdbsr041021 into mr_datmligacao.socntzgrpdes
         if sqlca.sqlcode <> 0 then
                  display "cbdbsr041021 sqlcode: ", sqlca.sqlcode
                  initialize mr_datmligacao.* to null
         end if
         close cbdbsr041021
      end if

     end if

      output to report bdbsr041_relatorio()
      output to report bdbsr041_relatorio_txt() #--> RELTXT

      initialize mr_datmservico.*
               , mr_datmatd6523.*
               , mr_datrservapol.*
               , mr_datketapa.*
               , mr_dpaksocor.*
               , mr_datksrr.*
               , mr_datmlcl.*
               , mr_datrcidsed.*
               , mr_datkpbm.*
               , mr_datksocntz.*
               , mr_datkassunto.*
               , mr_pcgksusep.*
               , mr_abbmveic.*
               , mr_datmligacao.*
	             , mr_datkasitip.*
	             , mr_datksrvtip.*
	             , mr_gabksuc.*
	             , mr_iddkdominio to null

   end foreach

   whenever error stop

   finish report bdbsr041_relatorio
   finish report bdbsr041_relatorio_txt #--> RELTXT

 end function


#-------------------------------#
 function bdbsr041_envia_email()
#-------------------------------#

   define l_assunto     char(100),
          l_comando     char(200),
          l_anexo       char(200),
          l_erro_envio  integer

   # ---> INICIALIZACAO DAS VARIAVEIS
   let l_comando    = null
   let l_erro_envio = null
   let l_assunto    = "Relatorio Servicos Atendidos - ", m_data, " - BDBSR041"

   # Colocamos o whenever para que o programa nao aborte quando ocorrer erro no envio de email
   # pois a nova funcao nao retorna o erro, ela aborta o programa
   whenever error continue

   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path
   run l_comando
   let m_path = m_path clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("BDBSR041", l_assunto, m_path)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path clipped
       else
           display "Nao existe email cadastrado para o modulo - BDBSR041"
       end if
   end if

   whenever error stop

end function


#---------------------------#
 report bdbsr041_relatorio()
#---------------------------#

  output

  left   margin 00
  right  margin 00
  top    margin 00
  bottom margin 00
  page   length 02

  format

  first page header

  print "Numero do Servico"                              , ASCII(09) ,
        "Ano do Servico"		                             , ASCII(09) ,
        "Data abertura do Servico"                       , ASCII(09) ,
        "Hora Abertura do Servico"	                     , ASCII(09) ,
        "Data Acionamento do Servico"                    , ASCII(09) ,
        "Hora do Acionamento do Servico"                 , ASCII(09) ,
        "Etapa"			                                     , ASCII(09) ,
        "Origem"		                                     , ASCII(09) ,
        "Empresa"		                                     , ASCII(09) ,
        "Cod.Prestador"		                               , ASCII(09) ,
        "Prestador"                                      , ASCII(09) ,
        "Cod.Socorrista"	                               , ASCII(09) ,
        "Socorrista"		                                 , ASCII(09) ,
        "Sucursal Documento"	                           , ASCII(09) ,
        "Cidade Servico"	                               , ASCII(09) ,
        "UF Servico"		                                 , ASCII(09) ,
        "Cidade do Prestador"	                           , ASCII(09) ,
        "UF Prestador"		                               , ASCII(09) ,
        "Cidade Sede Servico"	                           , ASCII(09) ,
        "Cidade Sede Prestador"	                         , ASCII(09) ,
        "Sigla"			                                     , ASCII(09) ,
        "Tipo Veiculo"                                   , ASCII(09) ,
        "Problema"  		                                 , ASCII(09) ,
        "Assistencia"		 	                               , ASCII(09) ,
        "Natureza"  		 	                               , ASCII(09) ,
        "Atividade"		 	                                 , ASCII(09) ,
        "Assunto"			                                   , ASCII(09) ,
        "Grupo de Assunto"	 	                           , ASCII(09) ,
        "Segmento        "                               , ASCII(09) ,
        "Ramo"				                                   , ASCII(09) ,
        "Apolice"			                                   , ASCII(09) ,
        "Item"				                                   , ASCII(09) ,
        "Sucursal Corretor"		                           , ASCII(09) ,
        "Segurado"  			                               , ASCII(09) ,
        "Numero CPF"			 	                             , ASCII(09) ,
        "Ordem CPF"			 	                               , ASCII(09) ,
        "Digito CPF"			 	                             , ASCII(09) ,
        "Veiculo Atendido"             	                 , ASCII(09) ,
        "Placa"                                          , ASCII(09) ,
        "Chassi Inicio"                                  , ASCII(09) ,
        "Chassi Fim   "                                  , ASCII(09) ,
        "Ano Fabricacao"	 	                             , ASCII(09) ,
        "Ano Modelo"   			                             , ASCII(09) ,
        "Corretor"  		 	                               , ASCII(09) ,
        "SUSEP"                                          , ASCII(09)

  on every row

  print mr_datmservico.atdsrvnum                        , ASCII(09) ,
        mr_datmservico.atdsrvano                        , ASCII(09) ,
        mr_datmservico.atddat                           , ASCII(09) ,
        mr_datmservico.atdhor                           , ASCII(09) ,
        mr_datmservico.srvprsacndat                     , ASCII(09) ,
        mr_datmservico.srvprsacnhor                     , ASCII(09) ,
        mr_datketapa.atdetpdes                          , ASCII(09) ,
        mr_datksrvtip.srvtipdes                         , ASCII(09) ,
        mr_datmservico.ciaempcod                        , ASCII(09) ,
        mr_datmservico.atdprscod                        , ASCII(09) ,
        mr_dpaksocor.pptnom                             , ASCII(09) ,
        mr_datmservico.srrcoddig			                  , ASCII(09) ,
        mr_datksrr.srrnom                               , ASCII(09) ,
        mr_gabksuc.sucnomapl  		                      , ASCII(09) ,
        mr_datmlcl.cidnom                               , ASCII(09) ,
        mr_datmlcl.ufdcod                               , ASCII(09) ,
        mr_dpaksocor.endcid                             , ASCII(09) ,
        mr_dpaksocor.endufd                             , ASCII(09) ,
        mr_datrcidsed.cidsedcodsrv                      , ASCII(09) ,
        mr_datrcidsed.cidsedcodpst                      , ASCII(09) ,
        mr_datmservico.atdvclsgl                        , ASCII(09) ,
        mr_iddkdominio.socvclcoddes                     , ASCII(09) ,
        mr_datkpbm.c24pbmdes                            , ASCII(09) ,
        mr_datkasitip.asitipdes                         , ASCII(09) ,
        mr_datksocntz.socntzdes                         , ASCII(09) ,
        mr_iddkdominio.pcpatvcoddes                     , ASCII(09) ,
        mr_datkassunto.c24astdes                        , ASCII(09) ,
        mr_datkpbm.c24pbmgrpdes                         , ASCII(09) ,
        mr_datmligacao.socntzgrpdes                     , ASCII(09) ,
        mr_datrservapol.ramcod                          , ASCII(09) ,
        mr_datrservapol.aplnumdig                       , ASCII(09) ,
        mr_datrservapol.itmnumdig                       , ASCII(09) ,
        mr_gabksuc.sucnomcor                            , ASCII(09) ,
        mr_datmservico.nom                              , ASCII(09) ,
        mr_datmatd6523.cgccpfnum                        , ASCII(09) ,
        mr_datmatd6523.cgcord                           , ASCII(09) ,
        mr_datmatd6523.cgccpfdig                        , ASCII(09) ,
        mr_datmservico.vclcoddig                        , ASCII(09) ,
        mr_abbmveic.vcllicnum                           , ASCII(09) ,
        mr_abbmveic.vclchsinc                           , ASCII(09) ,
        mr_abbmveic.vclchsfnl                           , ASCII(09) ,
        mr_abbmveic.vclanofbc                           , ASCII(09) ,
        mr_datmservico.vclanomdl                        , ASCII(09) ,
        mr_datmservico.cornom                           , ASCII(09) ,
        mr_datmservico.corsus                           , ASCII(09)

 end report


#--------------------------------#
 report bdbsr041_relatorio_txt() #--> RELTXT
#--------------------------------#

  output

  left   margin 00
  right  margin 00
  top    margin 00
  bottom margin 00
  page   length 01

  format

  on every row

  print mr_datmservico.atdsrvnum                        , ASCII(09) ,
        mr_datmservico.atdsrvano                        , ASCII(09) ,
        mr_datmservico.atddat                           , ASCII(09) ,
        mr_datmservico.atdhor                           , ASCII(09) ,
        mr_datmservico.srvprsacndat                     , ASCII(09) ,
        mr_datmservico.srvprsacnhor                     , ASCII(09) ,
        mr_datketapa.atdetpdes clipped                  , ASCII(09) ,
        mr_datksrvtip.srvtipdes clipped                 , ASCII(09) ,
        mr_datmservico.ciaempcod                        , ASCII(09) ,
        mr_datmservico.atdprscod                        , ASCII(09) ,
        mr_dpaksocor.pptnom clipped                     , ASCII(09) ,
        mr_datmservico.srrcoddig			                  , ASCII(09) ,
        mr_datksrr.srrnom clipped                       , ASCII(09) ,
        mr_gabksuc.sucnomapl  		                      , ASCII(09) ,
        mr_datmlcl.cidnom clipped                       , ASCII(09) ,
        mr_datmlcl.ufdcod clipped                       , ASCII(09) ,
        mr_dpaksocor.endcid                             , ASCII(09) ,
        mr_dpaksocor.endufd                             , ASCII(09) ,
        mr_datrcidsed.cidsedcodsrv                      , ASCII(09) ,
        mr_datrcidsed.cidsedcodpst                      , ASCII(09) ,
        mr_datmservico.atdvclsgl                        , ASCII(09) ,
        mr_iddkdominio.socvclcoddes clipped             , ASCII(09) ,
        mr_datkpbm.c24pbmdes clipped                    , ASCII(09) ,
        mr_datkasitip.asitipdes clipped                 , ASCII(09) ,
        mr_datksocntz.socntzdes clipped                 , ASCII(09) ,
        mr_iddkdominio.pcpatvcoddes  clipped            , ASCII(09) ,
        mr_datkassunto.c24astdes clipped                , ASCII(09) ,
        mr_datkpbm.c24pbmgrpdes clipped                 , ASCII(09) ;

        if mr_datmligacao.socntzgrpdes is null or
           mr_datmligacao.socntzgrpdes = " " then
              print "SEM DADOS socntzgrpdes"            , ASCII(09);
        else
           print mr_datmligacao.socntzgrpdes clipped    , ASCII(09);
        end if

  print mr_datrservapol.ramcod                          , ASCII(09) ,
        mr_datrservapol.aplnumdig                       , ASCII(09) ,
        mr_datrservapol.itmnumdig                       , ASCII(09) ,
        mr_gabksuc.sucnomcor                            , ASCII(09) ,
        mr_datmservico.nom clipped                      , ASCII(09) ,
        mr_datmatd6523.cgccpfnum                        , ASCII(09) ,
        mr_datmatd6523.cgcord                           , ASCII(09) ,
        mr_datmatd6523.cgccpfdig                        , ASCII(09) ,
        mr_datmservico.vclcoddig                        , ASCII(09) ,
        mr_abbmveic.vcllicnum                           , ASCII(09) ,
        mr_abbmveic.vclchsinc                           , ASCII(09) ,
        mr_abbmveic.vclchsfnl                           , ASCII(09) ,
        mr_abbmveic.vclanofbc                           , ASCII(09) ,
        mr_datmservico.vclanomdl                        , ASCII(09) ,
        mr_datmservico.cornom clipped                   , ASCII(09) ,
        mr_datmservico.corsus

 end report