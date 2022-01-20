#############################################################################
# Nome do Modulo: CTX12G00                                         Raji     #
#                                                                  Ruiz     #
# Grava Marcacao de Vistoria - Ramos Elementares (INTERNET)        Abr/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Incluida funcao fun_dba_abre_banco. #
# ---------- --------------------- ------ ------------------------------------#
# 07/02/2006 Priscila           Zeladoria Buscar data e hora do banco de dados#
#-----------------------------------------------------------------------------#
# 15/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32          #
#                                                                             #
###############################################################################
# 16/06/2012 Humberto Santos       Segregacao Ambientes                       #
#                                                                             #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

main
 define i smallint
 define v char(40)
 define resp record
    sinnum            like datmpedvist.sinvstnum,
    sinano            like datmpedvist.sinvstano
 end record

 define argumentos    record
    solnom            char (15),                    # Solicitante
    soltip            char (01),                    # Tipo Solicitante
    c24soltipcod      like datmligacao.c24soltipcod,# Tipo do Solicitante
    succod            like datrligapol.succod,      # Codigo Sucursal
    ramcod            like datrservapol.ramcod,     # Codigo Ramo
    aplnumdig         like datrligapol.aplnumdig,   # Numero Apolice
    itmnumdig         like datrligapol.itmnumdig,   # Numero do Item
    edsnumref         like datrligapol.edsnumref,   # Numero do Endosso
    ligcvntip         like datmligacao.ligcvntip,   # Codigo convenio
    segnom            like datmpedvist.segnom   ,   # Nome do Segurado
    cornom            like datmpedvist.cornom   ,   # Nome do Corretor
    dddcod            like datmpedvist.dddcod   ,   # DDD Segurado Apol.
    teltxt            like datmpedvist.teltxt   ,   # Tel Segurado Apol.
    lclrsccod         like datmpedvist.lclrsccod,   # Local de Risco
    lclendflg         char (01)                 ,   # Local de Risco?
    lgdtip            like datmpedvist.lgdtip   ,   # Logadoro Tipo
    lgdnom            like datmpedvist.lgdnom   ,   # Logadoro Nome
    lgdnum            like datmpedvist.lgdnum   ,   # Logadoro Numero
    lgdnomcmp         like datmpedvist.lgdnomcmp,   # Logadoro Complemento
    endbrr            like datmpedvist.endbrr   ,   # Bairro
    endcep            like datmpedvist.endcep   ,   # CEP
    endcepcmp         like datmpedvist.endcepcmp,   # CEP Complemento
    endcid            like datmpedvist.endcid   ,   # Cidade
    endufd            like datmpedvist.endufd   ,   # UF
    endddd            like datmpedvist.endddd   ,   # DDD Local
    teldes            like datmpedvist.teldes   ,   # Tel Local
    lclcttnom         like datmpedvist.lclcttnom,   # Contato Local
    endrefpto         like datmpedvist.endrefpto,   # Ponto de Ref. Local
    #sinntzcod         like datmpedvist.sinntzcod,   # Natureza sinistro
    sindat            like datmpedvist.sindat   ,   # Data do Sinistro
    sinhor            like datmpedvist.sinhor   ,   # Hora do Sinistro
    #orcvlr            like datmpedvist.orcvlr   ,   # Valor estipulado
    sinhst            like datmpedvist.sinhst   ,   # Historico
    sinobs            like datmpedvist.sinobs   ,   # Rel. Bens
    rglvstflg         like datmpedvist.rglvstflg    # Utilizacao regulador?
 end record

 call fun_dba_abre_banco("CT24HS")

 let argumentos.solnom      = arg_val(1)
 let argumentos.soltip      = arg_val(2)
 let argumentos.c24soltipcod= arg_val(3)
 let argumentos.succod      = arg_val(4)
 let argumentos.ramcod      = arg_val(5)
 let argumentos.aplnumdig   = arg_val(6)
 let argumentos.itmnumdig   = arg_val(7)
 let argumentos.edsnumref   = arg_val(8)
 let argumentos.ligcvntip   = arg_val(9)
 let argumentos.segnom      = arg_val(10)
 let argumentos.cornom      = arg_val(11)
 let argumentos.dddcod      = arg_val(12)
 let argumentos.teltxt      = arg_val(13)
 let argumentos.lclrsccod   = arg_val(14)
 let argumentos.lclendflg   = arg_val(15)
 let argumentos.lgdtip      = arg_val(16)
 let argumentos.lgdnom      = arg_val(17)
 let argumentos.lgdnum      = arg_val(18)
 let argumentos.lgdnomcmp   = arg_val(19)
 let argumentos.endbrr      = arg_val(20)
 let argumentos.endcep      = arg_val(21)
 let argumentos.endcepcmp   = arg_val(22)
 let argumentos.endcid      = arg_val(23)
 let argumentos.endufd      = arg_val(24)
 let argumentos.endddd      = arg_val(25)
 let argumentos.teldes      = arg_val(26)
 let argumentos.lclcttnom   = arg_val(27)
 let argumentos.endrefpto   = arg_val(28)
 #let argumentos.sinntzcod   = arg_val(29)
 let argumentos.sindat      = arg_val(30)
 let argumentos.sinhor      = arg_val(31)
 #let argumentos.orcvlr      = arg_val(32)
 let argumentos.sinhst      = arg_val(33)
 let argumentos.sinobs      = arg_val(34)
 let argumentos.rglvstflg   = arg_val(35)

  if g_issk.funmat is null then
     let g_issk.usrtip = 'F'
     let g_issk.empcod = 1
     let g_issk.funmat = 999999
  end if

  #PSI200140 - Priscila Staingel 12/06/06
  #Os campos sinntzcod, sinramgrp e orcvlr da tabela datmpedvist
  # nao sao mais utilizados, pois o laudo podera ter mais de uma natureza.
  #IMPORTANTE:
  #Conforme informado pela Eliane Lopes do RE, o sistema deles nao utiliza
  # sistema internet, esta desativado.
  #Logo, nao ha necessidade de se atualizar esse fonte, para receber todas
  # as coberturas, naturezas e valores como parametro e inserir na tabela
  # datrpedvistnatcob.
  #Caso o sistema RE volte a utilizar esse programa devemos adapta-lo para
  # receber até 10 coberturas/naturezas/valor e inserir em datrpedvistnatcob

  call ctx12g00(argumentos.solnom      ,
                argumentos.soltip      ,
                argumentos.c24soltipcod,
                argumentos.succod      ,
                argumentos.ramcod      ,
                argumentos.aplnumdig   ,
                argumentos.itmnumdig   ,
                argumentos.edsnumref   ,
                argumentos.ligcvntip   ,
                argumentos.segnom      ,
                argumentos.cornom      ,
                argumentos.dddcod      ,
                argumentos.teltxt      ,
                argumentos.lclrsccod   ,
                argumentos.lclendflg   ,
                argumentos.lgdtip      ,
                argumentos.lgdnom      ,
                argumentos.lgdnum      ,
                argumentos.lgdnomcmp   ,
                argumentos.endbrr      ,
                argumentos.endcep      ,
                argumentos.endcepcmp   ,
                argumentos.endcid      ,
                argumentos.endufd      ,
                argumentos.endddd      ,
                argumentos.teldes      ,
                argumentos.lclcttnom   ,
                argumentos.endrefpto   ,
                #argumentos.sinntzcod   ,
                argumentos.sindat      ,
                argumentos.sinhor      ,
                #argumentos.orcvlr      ,
                argumentos.sinhst      ,
                argumentos.sinobs      ,
                argumentos.rglvstflg
                )
     returning resp.*

     display resp.sinnum using "######", "/", resp.sinano

end main


#---------------------------------------------------------------
 function ctx12g00(d_ctx12g00)
#---------------------------------------------------------------

 define d_ctx12g00    record
    solnom            char (15),                    # Solicitante
    soltip            char (01),                    # Tipo Solicitante
    c24soltipcod      like datmligacao.c24soltipcod,# Tipo do Solicitante
    succod            like datrligapol.succod,      # Codigo Sucursal
    ramcod            like datrservapol.ramcod,     # Codigo Ramo
    aplnumdig         like datrligapol.aplnumdig,   # Numero Apolice
    itmnumdig         like datrligapol.itmnumdig,   # Numero do Item
    edsnumref         like datrligapol.edsnumref,   # Numero do Endosso
    ligcvntip         like datmligacao.ligcvntip,   # Codigo convenio
    segnom            like datmpedvist.segnom   ,   # Nome do Segurado
    cornom            like datmpedvist.cornom   ,   # Nome do Corretor
    dddcod            like datmpedvist.dddcod   ,   # DDD Segurado Apol.
    teltxt            like datmpedvist.teltxt   ,   # Tel Segurado Apol.
    lclrsccod         like datmpedvist.lclrsccod,   # Local de Risco
    lclendflg         char (01)                 ,   # Local de Risco?
    lgdtip            like datmpedvist.lgdtip   ,   # Logadoro Tipo
    lgdnom            like datmpedvist.lgdnom   ,   # Logadoro Nome
    lgdnum            like datmpedvist.lgdnum   ,   # Logadoro Numero
    lgdnomcmp         like datmpedvist.lgdnomcmp,   # Logadoro Complemento
    endbrr            like datmpedvist.endbrr   ,   # Bairro
    endcep            like datmpedvist.endcep   ,   # CEP
    endcepcmp         like datmpedvist.endcepcmp,   # CEP Complemento
    endcid            like datmpedvist.endcid   ,   # Cidade
    endufd            like datmpedvist.endufd   ,   # UF
    endddd            like datmpedvist.endddd   ,   # DDD Local
    teldes            like datmpedvist.teldes   ,   # Tel Local
    lclcttnom         like datmpedvist.lclcttnom,   # Contato Local
    endrefpto         like datmpedvist.endrefpto,   # Ponto de Ref. Local
    #sinntzcod         like datmpedvist.sinntzcod,   # Natureza sinistro
    sindat            like datmpedvist.sindat   ,   # Data do Sinistro
    sinhor            like datmpedvist.sinhor   ,   # Hora do Sinistro
    #orcvlr            like datmpedvist.orcvlr   ,   # Valor estipulado
    sinhst            like datmpedvist.sinhst   ,   # Historico
    sinobs            like datmpedvist.sinobs   ,   # Rel. Bens
    rglvstflg         like datmpedvist.rglvstflg    # Utilizacao regulador?
 end record
 define m_host        like ibpkdbspace.srvnom #Humberto
 define ws            record
    promptq           char(01)                   ,
    retorno           smallint                   ,
    lignum            like datmligacao.lignum    ,
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    codigosql         integer                    ,
    tabname           like systables.tabname     ,
    msg               char(80)                ,

    sinramgrp         like gtakram.sinramgrp,
    confirma          char (01)
 end record

 define aux_today     char (10),
        aux_hora      char (05),
        aux_ano4      char (04),
        aux_ano2      char (02),
        aux_grlchv    like igbkgeral.grlchv     ,
        aux_grlinf    like igbkgeral.grlinf     ,
        aux_sinvstnum like datmpedvist.sinvstnum,
        aux_vistoria  char (09)                 ,
        aux_atdsrvnum like datmservico.atdsrvnum,
        aux_atdsrvano like datmservico.atdsrvano
 define prompt_key    char (01)

 define l_sql    char (500)
 define l_data      date,
        l_hora2     datetime hour to minute

	let	aux_today  =  null
	let	aux_hora  =  null
	let	aux_ano4  =  null
	let	aux_ano2  =  null
	let	aux_grlchv  =  null
	let	aux_grlinf  =  null
	let	aux_sinvstnum  =  null
	let	aux_vistoria  =  null
	let	aux_atdsrvnum  =  null
	let	aux_atdsrvano  =  null
	let	prompt_key  =  null

	initialize  ws.*  to  null

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
 let aux_vistoria = ""
 let int_flag  = false
 let aux_today = l_data
 let aux_hora  = l_hora2
 let aux_ano4  = aux_today[7,10]
 let aux_ano2  = aux_today[9,10]

 #------------------------------------------------------------------------------
 # Busca numeracao
 #------------------------------------------------------------------------------
 begin work

 call cts10g03_numeracao( 1, "" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

 if  ws.codigosql = 0  then
     commit work
 else
     display ws.msg
     rollback work
     prompt "" for char ws.promptq
     return 0,0
 end if

 if d_ctx12g00.ramcod is not null then
    select sinramgrp
      into ws.sinramgrp                 # Grupo do ramo
      from gtakram
     where ramcod = d_ctx12g00.ramcod
       and empcod = 1

 end if

 let aux_grlchv = aux_ano2,"VSTSINRE"

#---------------------------------------------------------------
# Obtencao do numero da ultima vistoria de sinistro de R.E.
#---------------------------------------------------------------


 let m_host = fun_dba_servidor("EMISAUTO")
 let l_sql = "select grlinf [1,6]"
              ,"from porto@",m_host clipped,":igbkgeral"
             ,"where mducod = 'C24'"
               ,"and grlchv = ?"

 prepare s_geral from l_sql
 declare c_geral cursor with hold for s_geral

 open c_geral using aux_grlchv
 foreach c_geral into aux_vistoria
    exit foreach
 end foreach

 if aux_vistoria is null then

    let aux_grlinf    = 400000     -- 700000 PSI 189685
    let aux_sinvstnum = 400000     -- 700000 PSI 189685

    begin work
    let l_sql =  "insert into porto@",m_host clipped,":igbkgeral ",
                       "(mducod, grlchv, grlinf, atlult) ",
                       "values ",
                       "( 'C24', ? , ? , ? ) "
    prepare comando_aux1 from l_sql
    whenever error continue
    execute comando_aux1 using aux_grlinf,
    							             aux_grlchv ,
                               l_data
    whenever error continue

    if sqlca.sqlcode <> 0 then
       display " Erro (", sqlca.sqlcode, ") na criacao do numero de vistoria. AVISE A INFORMATICA!"
       let ws.msg = err_get(sqlca.sqlcode)
       display ws.msg
       rollback work
       return 0,0
    end if
 else
    begin work
		 let l_sql = "select grlinf [1,6]"
		              ,"from porto@",m_host clipped,":igbkgeral"
		             ,"where mducod = 'C24'"
		               ,"and grlchv = ?"

		 prepare s_geral1 from l_sql
     declare i_geral cursor with hold for s_geral1
    open i_geral using aux_grlchv
    foreach i_geral  into aux_vistoria
       let aux_sinvstnum = aux_vistoria[1,6]
       let aux_sinvstnum = aux_sinvstnum + 1
       if aux_ano2 <> "04" then
          if aux_sinvstnum  > 499999 then    -- 749999 PSI 189685
            display "Faixa de vistoria de sinistro para R.E. esgotada. AVISE A INFORMATICA!"
             rollback work
             return
          end if
       else
          if aux_sinvstnum  > 749999 then    -- 749999 PSI 189685
	    display "Faixa de vistoria de sinistro para R.E. esgotada. AVISE A INFORMATICA!"
             rollback work
             return
	 end if
       end if
       call cts40g03_data_hora_banco(2)
         returning l_data, l_hora2

       let l_sql =  "update into porto@",m_host clipped,":igbkgeral "
                       ,"set (grlinf, atlult) = (?, ?)"
                       ,"where mducod = 'C24'"
                       ,"and grlchv = ? "

		    prepare comando_aux2 from l_sql
		    whenever error continue
		    execute comando_aux2 using aux_sinvstnum,
		    							             l_data ,
		                               aux_grlchv
        whenever error continue
       if sqlca.sqlcode <>  0  then
          display " Erro (", sqlca.sqlcode, ") na gravacao da ultima vistoria de sinistro de R.E. AVISE A INFORMATICA!"
          let ws.msg = err_get(sqlca.sqlcode)
          display ws.msg
          rollback work
          return 0,0
       end if

    end foreach
 end if

#---------------------------------------------------------------
# Grava tabela de pedido de vistoria de sinistro
#---------------------------------------------------------------

 call cts10g00_ligacao ( ws.lignum,
                         aux_today,
                         aux_hora,
                         d_ctx12g00.c24soltipcod,
                         d_ctx12g00.solnom,
                         "V12",                    # Assunto Vistoria R.E.
                         "999999",                 # Matricula Internet
                         d_ctx12g00.ligcvntip,
                         0,                        # Numero da PA
                         "",""        ,
                         aux_sinvstnum,
                         aux_ano4,
                         "","",
                         d_ctx12g00.succod,
                         d_ctx12g00.ramcod,
                         d_ctx12g00.aplnumdig,
                         d_ctx12g00.itmnumdig,
                         d_ctx12g00.edsnumref,
                         "", "", "", "",
                         "", "", "", "",
                         "", "", "", "" )
               returning ws.tabname, ws.codigosql

 if ws.codigosql  <>  0  then
    display " Erro (", ws.codigosql, ") na gravacao da tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
    let ws.msg = err_get(sqlca.sqlcode)
    display ws.msg
    rollback work
    return 0,0
 end if

 insert into datmpedvist ( sinvstnum,
                           sinvstano,
                           vstsolnom,
                           vstsoltip,
                           vstsoltipcod,
                           sindat   ,
                           sinhor   ,
                           segnom   ,
                           cornom   ,
                           dddcod   ,
                           teltxt   ,
                           #orcvlr   ,
                           funmat   ,
                           #sinntzcod,
                           lclrsccod,
                           lclendflg,
                           lgdtip   ,
                           lgdnom   ,
                           lgdnum   ,
                           endufd   ,
                           lgdnomcmp,
                           endbrr   ,
                           endcid   ,
                           endcep   ,
                           endcepcmp,
                           endddd   ,
                           teldes   ,
                           lclcttnom,
                           endrefpto,
                           sinhst   ,
                           sinobs   ,
                           vstsolstt,
                           sinvstdat,
                           sinvsthor,
                           rglvstflg)
                           #sinramgrp)
                values ( aux_sinvstnum        ,
                         aux_ano4             ,
                         d_ctx12g00.solnom   ,
                         d_ctx12g00.soltip   ,
                         d_ctx12g00.c24soltipcod,
                         d_ctx12g00.sindat    ,
                         d_ctx12g00.sinhor    ,
                         d_ctx12g00.segnom    ,
                         d_ctx12g00.cornom    ,
                         d_ctx12g00.dddcod    ,
                         d_ctx12g00.teltxt    ,
                         #d_ctx12g00.orcvlr    ,
                         "999999"             , # Matricula Internet
                         #d_ctx12g00.sinntzcod ,
                         d_ctx12g00.lclrsccod ,
                         d_ctx12g00.lclendflg ,
                         d_ctx12g00.lgdtip    ,
                         d_ctx12g00.lgdnom    ,
                         d_ctx12g00.lgdnum    ,
                         d_ctx12g00.endufd    ,
                         d_ctx12g00.lgdnomcmp ,
                         d_ctx12g00.endbrr    ,
                         d_ctx12g00.endcid    ,
                         d_ctx12g00.endcep    ,
                         d_ctx12g00.endcepcmp ,
                         d_ctx12g00.endddd    ,
                         d_ctx12g00.teldes    ,
                         d_ctx12g00.lclcttnom ,
                         d_ctx12g00.endrefpto ,
                         d_ctx12g00.sinhst    ,
                         d_ctx12g00.sinobs    ,
                         1                    ,
                         aux_today            ,
                         aux_hora             ,
                         d_ctx12g00.rglvstflg )
                         #ws.sinramgrp)

 if sqlca.sqlcode <> 0 then
    display " Erro (", sqlca.sqlcode, ") na inclusao do pedido de vistoria de sinistro. AVISE A INFORMATICA!"
    let ws.msg = err_get(sqlca.sqlcode)
    display ws.msg
    rollback work
    return 0,0
 end if

#--------------------------------------------------------------------
# Grava dados da ligacao
#--------------------------------------------------------------------

#if d_ctx12g00.succod    is not null   and
#   d_ctx12g00.aplnumdig is not null   then
#   call osrea140 (1,                      ###  Codigo da Central
#                  3,                      ###  Tipo Documento: Apolice
#                  d_ctx12g00.aplnumdig,
#                  d_ctx12g00.succod,
#                  d_ctx12g00.ramcod,
#                  6936,                   ###  Matricula ROSIMEIRE SILVA
#                  5178,                   ###  Ramal para contato
#                  aux_ano4,               ###  Ano Vistoria Sinistro R.E.
#                  aux_sinvstnum,          ###  Numero Vistoria Sinistro R.E.
#                  aux_today,
#                  1)                      ###  Codigo da Empresa
#        returning ws.codigosql
#   if ws.codigosql <> 0  then
#      display " Erro (", ws.codigosql, ") na interface CEDOC x Sinistro de R.E. AVISE A INFORMATICA!"
#      rollback work
#      return 0,0
#   end if
#end if

 commit work
 whenever error stop

 return aux_sinvstnum,
        aux_ano4

end function  ###  ctx12g00
