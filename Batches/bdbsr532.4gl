#------------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                              #
# ...........................................................................  #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                            #
# MODULO.........: BDBSR532                                                    #
# ANALISTA RESP..: BEATRIZ ARAUJO                                              #
# PSI/OSF........: PSI-2014-21950/PR                                           #
# DESCRICAO......: RELATORIO DE SOCORRISTAs BLOQUEADOS E DESBLOQUEADOS         #
#                  AUTOMATICAMENTE.                                            #
# ...........................................................................  #
# DESENVOLVIMENTO: FORNAX TECNOLOGIA (RCP)                                     #
# LIBERACAO......: 01/10/2014                                                  #
# ...........................................................................  #
#                                                                              #
#                           * * * ALTERACOES * * *                             #
#                                                                              #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                              #
# --------   --------------  ---------- -------------------------------------  #
#                                                                              #
#------------------------------------------------------------------------------#

database porto

define m_data_ini date 
define m_data_fin date 
 
define mr_relat record
       pstcoddig       like dpaksocor.pstcoddig        ,
       nomgrr          like dpaksocor.nomgrr           ,
       srrtip          like datksrr.srrtip             ,
       srrtipdes       char(20)                        ,
       prssitcod       like dpaksocor.prssitcod        ,
       pestip          like dpaksocor.pestip           ,
       cgcord          like dpaksocorfav.cgcord        ,
       cgccpfdig       like dpaksocorfav.cgccpfdig     ,
       cgccpfnum       char(030)                       ,
       cgcord2         like dpaksocorfav.cgcord        ,
       cgccpfdig2      like dpaksocorfav.cgccpfdig     ,
       cgccpfnum2      char(030)                       ,
       vcldes          char(058)                       ,
       prssitdes       char(030)                       ,
       vclaqstipdes    char(030)                       ,
       socoprsitdes    char(030)                       ,
       prsitdes        char(030)                       ,
       muninsnum       like dpaksocor.muninsnum        ,
       endtiplgd       like datksrrend.lgdtip          ,
       endlgd          like dpaksocor.endlgd           ,
       endcmp          like dpaksocor.endcmp           ,
       lgdnum          like dpaksocor.lgdnum           ,
       endbrr          like dpaksocor.endbrr           ,
       endcid          like dpaksocor.endcid           ,
       endufd          like dpaksocor.endufd           ,
       endufdcod       like dpaksocor.endufd           ,
       endcep          like dpaksocor.endcep           ,
       endcepcmp       like dpaksocor.endcepcmp        ,
       dddcod          like dpaksocor.dddcod           ,
       telnum          like datksrrend.telnum          ,
       teltxt          like dpaksocor.teltxt           ,
       faxnum          like dpaksocor.faxnum           ,
       celdddnum       like dpaksocor.celdddnum        ,
       celtelnum       like dpaksocor.celtelnum        ,
       nxtdddcod       like datksrr.nxtdddcod          ,
       nxtide          like datksrr.nxtide             ,
       nxtnum          like datksrr.nxtnum             ,
       maides          like dpaksocor.maides           ,
       pptnom          like dpaksocor.pptnom           ,
       rspnom          like dpaksocor.rspnom           ,
       socfavnom       like dpaksocorfav.socfavnom     ,
       pestip2         like dpaksocorfav.pestip        ,
       vclpntdes       char(030)                       ,
       vclcmbdes       char(030)                       ,
       vclctfnom       like datkveiculo.vclctfnom      ,
       vclaqstipcod    like datkveiculo.vclaqstipcod   ,
       vclaqsnom       like datkveiculo.vclaqsnom      ,
       socvclcod       like datkveiculo.socvclcod      ,
       vclcoddig       like datkveiculo.vclcoddig      ,
       celdddcod       like datkveiculo.celdddcod      ,
       eqptip          like datkveiculo.eqptip         ,
       vclchs          char(25)                        ,
       socvstlcldes    char(50)                        ,
       bcoctatip       like dpaksocorfav.bcoctatip     ,
       bcocod          like dpaksocorfav.bcocod        ,
       bcoagnnum       like dpaksocorfav.bcoagnnum     ,
       bcoagndig       like dpaksocorfav.bcoagndig     ,
       bcoctanum       like dpaksocorfav.bcoctanum     ,
       bcoctadig       like dpaksocorfav.bcoctadig     ,
       socpgtopccod2   like dpaksocorfav.socpgtopccod  ,
       patpprflg       like dpaksocor.patpprflg        ,
       srvnteflg       like dpaksocor.srvnteflg        ,
       qldgracod       like dpaksocor.qldgracod        ,
       prscootipcod    like dpaksocor.prscootipcod     ,
       vlrtabflg       like dpaksocor.vlrtabflg        ,
       soctrfcod       like dpaksocor.soctrfcod        ,
       rmesoctrfcod    like dpaksocor.rmesoctrfcod     ,
       pstobs          like dpaksocor.pstobs           ,
       intsrvrcbflg    like dpaksocor.intsrvrcbflg     ,
       risprcflg       like dpaksocor.risprcflg        ,
       cmtdat          like dpaksocor.cmtdat           ,
       atldat          like dpaksocor.atldat           ,
       atldat2         like dpaksocor.atldat           ,
       cntvigincdat    like dpakprscntvigctr.cntvigincdat , # Inicio da Vigencia
       cntvigfnldat    like dpakprscntvigctr.cntvigfnldat , # Fim da Vigencia
       nomrazsoc       like dpaksocor.nomrazsoc        ,
       cnhautctg       like datksrr.cnhautctg          ,
       srrcoddig       like datksrr.srrcoddig          ,
       sexcod          like datksrr.sexcod             ,
       nscdat          like datksrr.nscdat             ,
       painom          like datksrr.painom             ,
       maenom          like datksrr.maenom             ,
       nacdes          like datksrr.nacdes             ,
       vcllicnum       like datkveiculo.vcllicnum      ,
       vclanofbc       like datkveiculo.vclanofbc      ,
       vclanomdl       like datkveiculo.vclanomdl      ,
       vclcorcod       like datkveiculo.vclcorcod      ,
       vclcordes       char(030)                       ,
       socctrposflg    like datkveiculo.socctrposflg   ,
       vclpnttip       like datkveiculo.vclpnttip      ,
       vclcmbcod       like datkveiculo.vclcmbcod      ,
       atdvclsgl       like datkveiculo.atdvclsgl      ,
       pgrnum          like datkveiculo.pgrnum         ,
       mdtcod          like datkveiculo.mdtcod         ,
       mdtcfgcod       like datkmdt.mdtcfgcod          ,
       mdtdes          like iddkdominio.cpodes         ,
       socvstdiaqtd    like datkveiculo.socvstdiaqtd   ,
       socvstlclcod    like datkveiculo.socvstlclcod   ,
       socvstlautipcod like datkveiculo.socvstlautipcod,
       socoprsitcod    like datkveiculo.socoprsitcod   ,
       estcvlcod       like datksrr.estcvlcod          ,
       cojnom          like datksrr.cojnom             ,
       srrdpdqtd       like datksrr.srrdpdqtd          ,
       pesalt          like datksrr.pesalt             ,
       pespso          like datksrr.pespso             ,
       srrcmsnum       like datksrr.srrcmsnum          ,
       srrclcnum       like datksrr.srrclcnum          ,
       srrcldnum       like datksrr.srrcldnum          ,
       rgenum          like datksrr.rgenum             ,
       rgeufdcod       like datksrr.rgeufdcod          ,
       vcldtbgrpcod    like datkvcldtbgrp.vcldtbgrpcod ,
       vcldtbgrpdes    char(30)                        ,
       estcvldes       char(30)                        ,
       eqpdes          char(50)                        ,
       srrabvnom       like datksrr.srrabvnom          ,
       cprnum          like datksrr.cprnum             ,
       cprsernum       like datksrr.cprsernum          ,
       cprufdcod       like datksrr.cprufdcod          ,
       cnhnum          like datksrr.cnhnum             ,
       cnhmotctg       like datksrr.cnhmotctg          ,
       cnhpridat       like datksrr.cnhpridat          ,
       exmvctdat       like datksrr.exmvctdat          ,
       empcod          like datksrr.empcod             ,
       srrprnnom       like datksrr.srrprnnom          ,
       caddat          like datksrr.caddat             ,
       viginc          like datrsrrpst.viginc          ,
       vigfnl          like datrsrrpst.vigfnl          ,
       pstvintip       like datrsrrpst.pstvintip       ,
       pstvindes       like iddkdominio.cpodes         ,
       mdtctrcod       like datkmdt.mdtctrcod          ,
       bckcod          like datkveiculo.bckcod         ,
       dpycod          like datkveiculo.dpycod         ,
       bckdes          like dpakbck.bckdes             ,
       dpydes          like dpakdpy.dpydes             ,
       frtrpnflg       like dpaksocor.frtrpnflg        ,
       rdranlultdat    like datksrr.rdranlultdat       ,
       rdranlsitcod    like datksrr.rdranlsitcod       ,
       socanlsitcod    like datksrr.socanlsitcod       ,
       descricao       like iddkdominio.cpodes         ,
       maides_soc      like datksrr.maides             ,
       #PSI237329
       lcvcod          like datklocadora.lcvcod        ,   # Codigo locadora vinculada à loja
       lcvnom          like datklocadora.lcvnom        ,   # Nome da locadora vinculada à loja
       lgdnom          like datklocadora.lgdnom        ,   # Endereço da locadora vinculada à loja
       brrnom          like datklocadora.brrnom        ,   # Bairro da locadora vinculada à loja
       cidnom          like datklocadora.cidnom        ,   # Cidade da locadora vinculada à loja
       endufd_loc      like datklocadora.endufd        ,   # UF da Locadora
       dddcod_loc      like datklocadora.dddcod        ,   # DDD da locadoura
       teltxt_loc      like datklocadora.teltxt        ,   # Telefone da locadora vinculada à loja
       facnum_loc      like datklocadora.facnum        ,   # Fax da locadora vinculada à loja
       adcsgrtaxvlr    like datklocadora.adcsgrtaxvlr  ,   # Tx Seguro da locadora vinculada à loja
       cdtsegtaxvlr    like datklocadora.cdtsegtaxvlr  ,   # Tx 2.º Condutor da locadora vinculada à loja
       cgccpfnum_loc   like datklocadora.cgccpfnum     ,   # CNPJ da locadora vinculada à loja
       cgcord_loc      like datklocadora.cgcord        ,   #
       cgccpfdig_loc   like datklocadora.cgccpfdig     ,   #
       lcvresenvcod    like datklocadora.lcvresenvcod  ,   # "Enviar Fax para" da locadora vinculada à loja
       envdsc          char(20)                        ,   #
       lcvstt          like datklocadora.lcvstt        ,   # Situação da locadora vinculada à loja
       lcvSttdes       char(15)                        ,   #
       acntip          like datklocadora.acntip        ,   # "Tipo Acionamento" da locadora vinculada à loja
       acndes          char(15)                        ,   #
       maides_loc      like datklocadora.maides        ,   # Email da locadora vinculada à loja
       caddat_loc      like datklocadora.caddat        ,   # Data Cadastro da locadora vinculada à loja
       atldat_loc      like datklocadora.atldat        ,   # Data Atualização do Cadastro da locadora vinculada à loja
       lcvextcod       like datkavislocal.lcvextcod    ,   # Código da loja
       aviestcod       like datkavislocal.aviestcod    ,   # Sigla da loja
       aviestnom       like datkavislocal.aviestnom    ,   # Nome da loja
       lcvlojtip       like datkavislocal.lcvlojtip    ,   # Tipo da loja
       lcvlojdes       char(15)                        ,   #
       lojqlfcod       like datkavislocal.lojqlfcod    ,   # Qualidade da loja
       desqualific     char(15)                        ,   #
       endlgd_loj      like datkavislocal.endlgd       ,   # Endereço da loja
       endbrr_loj      like datkavislocal.endbrr       ,   # Bairro da loja
       endcid_loj      like datkavislocal.endcid       ,   # Cidade da loja
       endufd_loj      like datkavislocal.endufd       ,   # UF da loja
       endcep_loj      like datkavislocal.endcep       ,   # CEP da loja
       endcepcmp_loj   like datkavislocal.endcepcmp    ,   #
       refptodes       like datkavislocal.refptodes    ,   # Ponto de referência da loja
       succod          like datkavislocal.succod       ,   # Sucursal da loja
       sucnom          like gabksuc.sucnom             ,   #
       dddcod_loj      like datkavislocal.dddcod       ,   # DDD da loja
       teltxt_loj      like datkavislocal.teltxt       ,   # Telefone da loja
       facnum_loj      like datkavislocal.facnum       ,   # Fax (com DDD) da loja
       horsegsexinc    like datkavislocal.horsegsexinc ,   # Horário de 2.ª a 6.ª inicio
       horsegsexfnl    like datkavislocal.horsegsexfnl ,   # Horário de 2.ª a 6.ª final
       horsabinc       like datkavislocal.horsabinc    ,   # Horário de sabado inicio
       horsabfnl       like datkavislocal.horsabfnl    ,   # Horário de sabado final
       hordominc       like datkavislocal.hordominc    ,   # Horário de domingo inicio
       hordomfnl       like datkavislocal.hordomfnl    ,   # Horário de domingo final
       lcvregprccod    like datkavislocal.lcvregprccod ,   # Tarifa
       lcvregprcdes    char(15)                        ,   #
       vclalglojstt    like datkavislocal.vclalglojstt ,   # Situacao
       lojsttdes       char(15)                        ,   #
       cauchqflg       like datkavislocal.cauchqflg    ,   # Cheque caução
       prtaertaxvlr    like datkavislocal.prtaertaxvlr ,   # Tx Aero.Port
       maides_loj      like datkavislocal.maides       ,   # Email
       obs             like datkavislocal.obs          ,   # Observações
       ramcod          like datrclauslocal.ramcod      ,   # Cláusulas da loja
       clscod          like datrclauslocal.clscod      ,   #
       clsdes          like aackcls.clsdes             ,   #
       cidcod          like datklcletgvclext.cidcod    ,   # Cidades e Taxas em que a loja entrega
       cidnom_ent      like glakcid.cidnom             ,   #
       ufdcod          like glakcid.ufdcod             ,   #
       etgtaxvlr       like datklcletgvclext.etgtaxvlr ,   #
       # PSI - 239178
       pstcndcod       like dpakcnd.pstcndcod          ,
       pstcndnom       like dpakcnd.pstcndnom          ,   #
       idade           smallint                        ,   #
       cnhctgcod       like dpakcnd.cnhctgcod          ,   #
       pstcndsitcod    like dpakcnd.pstcndsitcod       ,   #
       pstcndconcod    like dpakcnd.pstcndconcod       ,   #
       caddat_can      datetime year to minute         ,   #
       cademp          like dpakcnd.cademp             ,   #
       cadmat          like dpakcnd.cadmat             ,   #
       cadnome         char(20)                        ,   #
       cadusrtip       like dpakcnd.cadusrtip          ,
       atldat_can      datetime year to minute         ,   #
       atlemp          like dpakcnd.atlemp             ,   #
       atlmat          like dpakcnd.atlmat             ,   #
       atlnome         char(20)                        ,   #
       atlusrtip       like dpakcnd.atlusrtip          ,
       datqra          date                            ,   #
       pcpatvcod       like dpaksocor.pcpatvcod        ,   #
       pcpatvdes       char(30)                        ,
       pisnum          like dpaksocor.pisnum           ,
       simoptpstflg    like dpaksocor.simoptpstflg     ,   # Flag optante simples
       rencod          like datkveiculo.rencod         ,   # Codigo do renavam do veiculo
       vclcadorgcod    like datkveiculo.vclcadorgcod   ,   # Codigo da origem de cadastro da viatura
       pcpprscod       like dpaksocor.pcpprscod        ,   # Codigo do prestador principal 
       gstcdicod       like dpaksocor.gstcdicod        ,   # Codigo da cadeia de gestão
       renfxacod       like dpaksocor.renfxacod	       ,   #Codigo da renda fixa pessoa fisica
       hstcaddat       like datmsrrhst.caddat          ,
       srrhsttxt       like datmsrrhst.srrhsttxt       ,
       srrhstseq       like datmsrrhst.srrhstseq        
end record

define m_dominio record
       erro      smallint  ,
       mensagem  char(100) ,
       cpodes    like iddkdominio.cpodes
end record

# Verificar seguro de Vida
define mrv_bdbsr532Vida record
       critica1 smallint, # segundo o vida quando =   7, possuiu Vital
       critica2 smallint, # segundo o vida quando =  83, possuiu VG
       critica3 smallint, # segundo o vida quando =   6, possui Vital
       critica4 smallint, # segundo o vida quando =  82, possui VG
       critica5 smallint, # segundo o vida quando =  85, possuiu API
       critica6 smallint, # segundo o vida quando =  86, possui API
       critica7 smallint  # segundo o vida quando = 321, possui VN
end record

define m_path   char(1000)

main

   initialize mr_relat.*, m_path to null

   call cts40g03_exibe_info("I", "BDBSR532")

   call bdbsr532_prepare()

   call bdbsr532_periodo()

   call bdbsr532_processa_relat_blq()

   call cts40g03_exibe_info("F", "BDBSR532")

end main

#------------------------#
 function bdbsr532_prepare()
#------------------------#

        define l_sql char(10000)

        let l_sql = " select grlinf ",
                      " from datkgeral ",
                     " where grlchv = ? "

        prepare prelat_01 from l_sql
        declare crelat_01 cursor for prelat_01

        let l_sql = " select srr.srrcoddig,",
                           " srr.srrnom,",
                           " srr.srrtip,",
                           " ende.lgdtip,",
                           " ende.lgdnom,",
                           " ende.lgdnum,",
                           " ende.endlgdcmp,",
                           " ende.brrnom,",
                           " ende.cidnom,",
                           " ende.ufdcod,",
                           " ende.endcep,",
                           " ende.endcepcmp,",
                           " ende.dddcod,",
                           " ende.telnum,",
                           " srr.celdddcod,",
                           " srr.celtelnum,",
                           " '',",
                           " srr.nxtdddcod, ",
                           " srr.nxtide, ",
                           " srr.nxtnum, ",
                           " srr.srrabvnom,",
                           " srr.srrstt,",
                           " srr.sexcod,",
                           " srr.nscdat,",
                           " srr.painom,",
                           " srr.maenom,",
                           " srr.nacdes,",
                           " srr.ufdcod,",
                           " srr.estcvlcod,",
                           " srr.cojnom,",
                           " srr.srrdpdqtd,",
                           " srr.pesalt,",
                           " srr.pespso,",
                           " srr.srrcmsnum,",
                           " srr.srrclcnum,",
                           " srr.srrcldnum,",
                           " srr.rgenum,",
                           " srr.rgeufdcod,",
                           " srr.cgccpfnum,",
                           " srr.cgccpfdig,",
                           " srr.cprnum,",
                           " srr.cprsernum,",
                           " srr.cprufdcod,",
                           " srr.cnhnum,",
                           " srr.cnhautctg,",
                           " srr.cnhmotctg,",
                           " srr.cnhpridat,",
                           " srr.exmvctdat,",
                           " srr.empcod,",
                           " srr.srrprnnom,",
                           " srr.caddat,",
                           " srr.atldat,",
                           " srr.rdranlultdat,",
                           " srr.rdranlsitcod,",
                           " srr.socanlsitcod, ",
                           " srr.maides, ",
                           " hst.caddat, ",
                           " hst.srrhsttxt, ",
                           " hst.srrhstseq ",
                      " from datmsrrhst hst,",
                           " datksrr srr,",
                           " outer datksrrend ende ",
                     " where hst.caddat >= ? ",
		     "   and hst.caddat <= ? ",
		     "   and (hst.srrhsttxt[01,19]='BLOQUEIO AUTOMATICO' or ",
		     "        hst.srrhsttxt[01,22]='DESBLOQUEIO AUTOMATICO')",
		     "   and srr.srrcoddig  = hst.srrcoddig ",
                     "   and ende.srrcoddig = srr.srrcoddig ",
                     " order by hst.caddat, srr.srrcoddig, hst.srrhstseq "

        prepare prelat_08a from l_sql
        declare crelat_08a cursor for prelat_08a

        let l_sql = " select asitipdes  ",
                      " from datrsrrasi a, ",
                           " datkasitip b",
                     " where srrcoddig = ? ",
                       " and a.asitipcod = b.asitipcod "

        prepare prelat_10 from l_sql
        declare crelat_10 cursor for prelat_10

        let l_sql = " select socntzdes, espdes ",
                      " from dbsrntzpstesp a, ",
                           " datksocntz    b, ",
                           " dbskesp c        ",
                     " where srrcoddig = ? ",
                      "  and a.espcod = c.espcod ",
                      "  and a.socntzcod = b.socntzcod "

        prepare prelat_11 from l_sql
        declare crelat_11 cursor for prelat_11

        let l_sql = " select cpodes ",
                      " from iddkdominio ",
                     " where cponom = ? ",
                       " and cpocod = ? "

        prepare prelat_15 from l_sql
        declare crelat_15 cursor for prelat_15

        let l_sql = "select viginc, ",
                          " vigfnl, ",
                          " pstcoddig, ",
                          " pstvintip  ",
                     " from datrsrrpst ",
                    " where srrcoddig  = ? ",
                    " order by viginc desc "

        prepare prelat_19 from l_sql
        declare crelat_19 cursor for prelat_19

        let l_sql = " select srrhsttxt, srrhstseq  ",
                      " from datmsrrhst ",
                     " where srrcoddig = ? ",
                       " order by srrhstseq desc "

        prepare prelat_26 from l_sql
        declare crelat_26 cursor for prelat_26

 end function

#---------------------------#
 function bdbsr532_periodo()
#---------------------------#

    define l_grlchv like datkgeral.grlchv
    define l_grlinf like datkgeral.grlinf
    define l_qtdia  smallint
    define l_dia    decimal(2,0)
    define i        smallint

    let l_dia      = ""
    let l_qtdia    = ""
    let l_grlchv   = ""
    let l_grlinf   = ""
    let m_data_ini = ""
    let m_data_fin = ""

    let l_grlchv = "PSOBDBSR532DIAS"
    whenever error stop 
    open  crelat_01 using l_grlchv
    fetch crelat_01 into l_grlinf
    whenever error continue 
    if sqlca.sqlcode <> 0 or l_grlinf is null then 
       let l_qtdia = 0
    else
       let l_qtdia = l_grlinf
    end if 

    let l_grlchv = "PSOBDBSR532PROC"
    whenever error stop 
    open  crelat_01 using l_grlchv
    fetch crelat_01 into l_grlinf
    whenever error continue 
    if sqlca.sqlcode <> 0 or l_grlinf is null or l_grlinf = " " then 
       display "BDBSR532 - Processamento interrompido. Parametros nao encontrados."
       exit program(1)
    end if 
    for i = 1 to 39
	if l_grlinf[i,i+1] = day(today) then
	   let l_dia = day(today)
	   exit for
        end if 
    end for

    let m_data_fin = today
    let m_data_ini = today - l_qtdia units day 

    display "Dias cadastrados para processamento : ",l_grlinf clipped
    display "Qtde. de dias anteriores para extracao : ",l_qtdia

    if l_dia is not null then 
       display ""
       display "BDBSR532 - Processando periodo : de ", m_data_ini, " ate ", m_data_fin
       display ""
    else
       display ""
       display "BDBSR532 - O dia de hoje nao esta cadastrado para processamento"
       display ""
       exit program(0)
    end if 
        
 end function

#--------------------------------------#
 function bdbsr532_processa_relat_blq()
#--------------------------------------#

    call bdbsr532_busca_path()

    start report relat_blq to m_path
 
    open crelat_08a using m_data_ini
			, m_data_fin

    foreach crelat_08a into mr_relat.srrcoddig  ,
                           mr_relat.nomrazsoc  ,
                           mr_relat.srrtip     ,
                           mr_relat.endtiplgd  ,
                           mr_relat.endlgd     ,
                           mr_relat.lgdnum     ,
                           mr_relat.endcmp     ,
                           mr_relat.endbrr     ,
                           mr_relat.endcid     ,
                           mr_relat.endufdcod  ,
                           mr_relat.endcep     ,
                           mr_relat.endcepcmp  ,
                           mr_relat.dddcod     ,
                           mr_relat.telnum     ,
                           mr_relat.celdddcod  ,
                           mr_relat.teltxt     ,
                           mr_relat.pstobs     ,
                           mr_relat.nxtdddcod  ,
                           mr_relat.nxtide     ,
                           mr_relat.nxtnum     ,
                           mr_relat.srrabvnom  ,
                           mr_relat.prssitcod  ,
                           mr_relat.sexcod     ,
                           mr_relat.nscdat     ,
                           mr_relat.painom     ,
                           mr_relat.maenom     ,
                           mr_relat.nacdes     ,
                           mr_relat.endufd     ,
                           mr_relat.estcvlcod  ,
                           mr_relat.cojnom     ,
                           mr_relat.srrdpdqtd  ,
                           mr_relat.pesalt     ,
                           mr_relat.pespso     ,
                           mr_relat.srrcmsnum  ,
                           mr_relat.srrclcnum  ,
                           mr_relat.srrcldnum  ,
                           mr_relat.rgenum     ,
                           mr_relat.rgeufdcod  ,
                           mr_relat.cgccpfnum  ,
                           mr_relat.cgccpfdig  ,
                           mr_relat.cprnum     ,
                           mr_relat.cprsernum  ,
                           mr_relat.cprufdcod  ,
                           mr_relat.cnhnum     ,
                           mr_relat.cnhautctg  ,
                           mr_relat.cnhmotctg  ,
                           mr_relat.cnhpridat  ,
                           mr_relat.exmvctdat  ,
                           mr_relat.empcod     ,
                           mr_relat.srrprnnom  ,
                           mr_relat.caddat     ,
                           mr_relat.atldat     ,
                           mr_relat.rdranlultdat,
                           mr_relat.rdranlsitcod,
                           mr_relat.socanlsitcod,
                           mr_relat.maides_soc  ,
                           mr_relat.hstcaddat   ,
                           mr_relat.srrhsttxt   ,
                           mr_relat.srrhstseq    

            output to report relat_blq()
            initialize mr_relat.* to null

      end foreach

      finish report relat_blq

      call relat_envia_mail(m_path)

 end function

#---------------------------------#
 function relat_envia_mail(l_path)
#---------------------------------#

        define  l_assunto     char(0100),
                l_erro_envio  integer,
                l_comando     char(0200),
                l_anexo       char(1000),
                l_path        char(1000)

        # ---> INICIALIZACAO DAS VARIAVEIS
        let l_comando    = null
        let l_erro_envio = null
        let l_assunto = "Relatório de Socorristas bloqueados e desbloqueados automaticamente"

        # COMPACTA O ARQUIVO DO RELATORIO
        let l_comando = "gzip -f ", l_path
        run l_comando

        let l_path = l_path  clipped, ".gz "

        # ENVIA E-MAIL
        let l_erro_envio = ctx22g00_envia_email("BDBSR532", l_assunto, l_path)

        if  l_erro_envio <> 0 then
            if  l_erro_envio <> 99 then
                display "Erro ao enviar email(ctx22g00) - ", l_erro_envio
            else
                display "Nao existe email cadastrado para o modulo - BDBSR532"
            end if
        end if

 end function

#------------------------------#
 function bdbsr532_busca_path()
#------------------------------#

     let m_path = null

     let m_path = f_path("DBS","RELATO")

     if  m_path is null then
         let m_path = "."
     end if

     let m_path = m_path clipped, "/bdbsr532Temp.xls"

 end function
 
#-----------------#
 report relat_blq()
#-----------------#

        define l_aux             char(0300),
               l_hist            char(1000),
               l_ntz             char(0500),
               l_esp             char(0100),
               l_ass             char(1000),
               l_par             char(0100),
               l_emp             char(0100),
               l_crn             char(0100),
               l_data            char(0010),
               l_vig             char(3000),
               l_primeiro        smallint,
               l_count           integer

        define l_socvidseg  char(1) # Saber se tem ou nao seguro de vida

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

        format

            first page header

                print "RELATORIO DE SOCORRISTAS."

                print ""

                print "DATA",                   ASCII(09),
                      "CÓDIGO",                 ASCII(09),
                      "NOME SOCORRISTA",        ASCII(09),
                      "TIPO SOCORRISTA",        ASCII(09),
                      "TIPO LOGRADOURO",        ASCII(09),
                      "LOGRADOURO",             ASCII(09),
                      "NUMERO",                 ASCII(09),
                      "COMPLEMENTO",            ASCII(09),
                      "BAIRRO",                 ASCII(09),
                      "CIDADE",                 ASCII(09),
                      "UF",                     ASCII(09),
                      "CEP",                    ASCII(09),
                      "CEPCMP",                 ASCII(09),
                      "DDD",                    ASCII(09),
                      "TELEFONE",               ASCII(09),
                      "DDD CEL",                ASCII(09),
                      "TELEFONE  CEL",          ASCII(09),
                      "OBSERVACAO",             ASCII(09),
                      "DDD NEXTEL",             ASCII(09),
                      "ID NEXTEL",              ASCII(09),
                      "NÚMERO NEXTEL",          ASCII(09),
                      "NOME SIGLA",             ASCII(09),
                      "SITUAÇÃO",               ASCII(09),
                      "SEXO",                   ASCII(09),
                      "DT. NASCIMENTO",         ASCII(09),
                      "NOME DO PAI",            ASCII(09),
                      "NOME DA MAE",            ASCII(09),
                      "NACIONALIDADE",          ASCII(09),
                      "NATURAL DE",             ASCII(09),
                      "ESTADO CIVIL",           ASCII(09),
                      "NOME CONJUGUE",          ASCII(09),
                      "QTDE. DEPENDENTES",      ASCII(09),
                      "ALTURA",                 ASCII(09),
                      "PESO",                   ASCII(09),
                      "CAMISA",                 ASCII(09),
                      "CALÇA",                  ASCII(09),
                      "CALÇADO",                ASCII(09),
                      "RG",                     ASCII(09),
                      "EMISSO RG",              ASCII(09),
                      "CPF",                    ASCII(09),
                      "DIGITO CPF",             ASCII(09),
                      "NUMERO CART. PROF.",     ASCII(09),
                      "SERIE CART. PROF.",      ASCII(09),
                      "EMISSOR CART. PROF.",    ASCII(09),
                      "NUMERO DE CNH",          ASCII(09),
                      "CATEGORIA AUTO",         ASCII(09),
                      "CATEGORIA MOTO",         ASCII(09),
                      "1ª HABILITACAO",         ASCII(09),
                      "VALIDADE EXAME MED.",    ASCII(09),
                      "FUNCIONARIO PORTO",      ASCII(09),
                      "PARENTE",                ASCII(09),
                      "DT. CADASTRO",           ASCII(09),
                      "DT. ATUALIZACAO",        ASCII(09),
                      "VIGENCIA PRESTADORES",   ASCII(09),
                      "VINCULO",                ASCII(09),
                      "ASSISTENCIAS",           ASCII(09),
                      "NATUREZA",               ASCII(09),
                      "EMAIL SOCORRISTA",       ascii(09),
                      "DATA ULT ANALISE RADAR", ASCII(09),
                      "SITUACAO DA ANALISE RADAR", ASCII(09),
                      "SITUACAO DA ANALISE P.S. ", ASCII(09),
                      "SEGURO DE VIDA"           , ASCII(09),
                      "HISTORICO"                , ASCII(09)

            on every row

                let l_ntz = " "
                open crelat_11 using mr_relat.srrcoddig
                fetch crelat_11 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_ntz = " "
                                let l_primeiro = true

                                foreach crelat_11 into l_aux, l_esp
                                        if  l_primeiro then
                                                let l_ntz = l_aux clipped, " ", l_esp clipped
                                                let l_primeiro = false
                                        else
                                                let l_ntz = l_ntz clipped,  "; ",  l_aux clipped, " ", l_esp clipped
                                        end if
                                end foreach
                        when 100
                                let l_ntz = ' '
                        otherwise
                                error 'ERRO BUSCA DE NATUREZA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                let l_ass = " "
                open crelat_10 using mr_relat.srrcoddig
                fetch crelat_10 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_ass = " "
                                let l_primeiro = true

                                foreach crelat_10 into l_aux
                                        if  l_primeiro then
                                                let l_ass = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_ass = l_ass clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_ass = '  '
                        otherwise
                                error 'ERRO BUSCA DE ASSISTENCIA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                let l_aux = 'srrstt'
                open crelat_15 using l_aux,
                                     mr_relat.prssitcod
                fetch crelat_15 into mr_relat.prssitdes

                if mr_relat.prssitcod = 2 then
                   let mr_relat.prssitdes = mr_relat.prssitdes clipped, "/",
                                            cty38g00_motivo(mr_relat.srrcoddig)
                end if

                let l_aux = 'estcvlcod'
                open crelat_15 using l_aux,
                                     mr_relat.estcvlcod
                fetch crelat_15 into mr_relat.estcvldes

                let l_aux = 'srrtip'
                open crelat_15 using l_aux,
                                     mr_relat.srrtip
                fetch crelat_15 into mr_relat.srrtipdes

		print  mr_relat.hstcaddat, ' ' , ASCII(09);

                print  mr_relat.srrcoddig  clipped,' ' , ASCII(09);

                if mr_relat.nomrazsoc is not null and  mr_relat.nomrazsoc <> " " then
                    print mr_relat.nomrazsoc        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.srrtip is not null and  mr_relat.srrtip <> " " then
                    print mr_relat.srrtip clipped, " - ", mr_relat.srrtipdes  clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endtiplgd is not null and  mr_relat.endtiplgd <> " " then
                    print mr_relat.endtiplgd        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endlgd is not null and  mr_relat.endlgd <> " " then
                    print mr_relat.endlgd        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.lgdnum is not null and  mr_relat.lgdnum <> " " then
                    print mr_relat.lgdnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endcmp is not null and  mr_relat.endcmp <> " " then
                    print mr_relat.endcmp        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endbrr is not null and  mr_relat.endbrr <> " " then
                    print mr_relat.endbrr        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endcid is not null and  mr_relat.endcid <> " " then
                    print mr_relat.endcid        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endufdcod is not null and  mr_relat.endufdcod <> " " then
                    print mr_relat.endufdcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if  mr_relat.endcep is not null and  mr_relat.endcep <> " " then
                    print mr_relat.endcep clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endcepcmp is not null and  mr_relat.endcepcmp <> " " then
                    print mr_relat.endcepcmp clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if  mr_relat.dddcod is not null and  mr_relat.dddcod <> " " then
                    print mr_relat.dddcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if  mr_relat.telnum is not null and  mr_relat.telnum <> " " then
                    print mr_relat.telnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if  mr_relat.celdddcod is not null and  mr_relat.celdddcod <> " " then
                    print mr_relat.celdddcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if  mr_relat.teltxt is not null and  mr_relat.teltxt <> " " then
                    print mr_relat.teltxt        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pstobs is not null and  mr_relat.pstobs <> " " then
                    print mr_relat.pstobs        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.nxtdddcod is not null and  mr_relat.nxtdddcod <> " " then
                    print mr_relat.nxtdddcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.nxtide is not null and  mr_relat.nxtide <> " " then
                    print mr_relat.nxtide        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.nxtnum is not null and  mr_relat.nxtnum <> " " then
                    print mr_relat.nxtnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if  mr_relat.srrabvnom is not null and  mr_relat.srrabvnom <> " " then
                    print mr_relat.srrabvnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.prssitdes is not null and  mr_relat.prssitdes <> " " then
                    print mr_relat.prssitdes        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.sexcod is not null and  mr_relat.sexcod <> " " then
                    print mr_relat.sexcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let l_data = extend(mr_relat.nscdat, year to year ),'-',
                             extend(mr_relat.nscdat, month to month),'-',
                             extend(mr_relat.nscdat, day to day)


                print l_data              clipped ,' ', ASCII(09);

                if  mr_relat.painom is not null and  mr_relat.painom <> " " then
                    print mr_relat.painom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.maenom is not null and  mr_relat.maenom <> " " then
                    print mr_relat.maenom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.nacdes is not null and  mr_relat.nacdes <> " " then
                    print mr_relat.nacdes        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endufd is not null and  mr_relat.endufd <> " " then
                    print mr_relat.endufd        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.estcvldes is not null and  mr_relat.estcvldes <> " " then
                    print mr_relat.estcvldes        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cojnom is not null and  mr_relat.cojnom <> " " then
                    print mr_relat.cojnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.srrdpdqtd is not null and  mr_relat.srrdpdqtd <> " " then
                    print mr_relat.srrdpdqtd        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pesalt is not null and  mr_relat.pesalt <> " " then
                    print mr_relat.pesalt        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pespso is not null and  mr_relat.pespso <> " " then
                    print mr_relat.pespso        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.srrcmsnum is not null and  mr_relat.srrcmsnum <> " " then
                    print mr_relat.srrcmsnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.srrclcnum is not null and  mr_relat.srrclcnum <> " " then
                    print mr_relat.srrclcnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.srrcldnum is not null and  mr_relat.srrcldnum <> " " then
                    print mr_relat.srrcldnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.rgenum is not null and  mr_relat.rgenum <> " " then
                    print mr_relat.rgenum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.rgeufdcod is not null and  mr_relat.rgeufdcod <> " " then
                    print mr_relat.rgeufdcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgccpfnum is not null and  mr_relat.cgccpfnum <> " " then
                    print mr_relat.cgccpfnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgccpfdig is not null and  mr_relat.cgccpfdig <> " " then
                    print mr_relat.cgccpfdig        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cprnum is not null and  mr_relat.cprnum <> " " then
                    print mr_relat.cprnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cprsernum is not null and  mr_relat.cprsernum <> " " then
                    print mr_relat.cprsernum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cprufdcod is not null and  mr_relat.cprufdcod <> " " then
                    print mr_relat.cprufdcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cnhnum is not null and  mr_relat.cnhnum <> " " then
                    print mr_relat.cnhnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cnhautctg is not null and  mr_relat.cnhautctg <> " " then
                    print mr_relat.cnhautctg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cnhmotctg is not null and  mr_relat.cnhmotctg <> " " then
                    print mr_relat.cnhmotctg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let l_data = extend(mr_relat.cnhpridat, year to year ),'-',
                             extend(mr_relat.cnhpridat, month to month),'-',
                             extend(mr_relat.cnhpridat, day to day)

                print l_data              clipped ,' ', ASCII(09);

                let l_data = extend(mr_relat.exmvctdat, year to year ),'-',
                             extend(mr_relat.exmvctdat, month to month),'-',
                             extend(mr_relat.exmvctdat, day to day)

                print l_data              clipped ,' ', ASCII(09);

                if  mr_relat.empcod = 1 then
                    print 'SIM' clipped ,' ', ASCII(09);
                else
                    print 'NAO' clipped ,' ', ASCII(09);
                end if

                print mr_relat.srrprnnom  clipped ,' ', ASCII(09);

                let l_data = extend(mr_relat.caddat, year to year ),'-',
                             extend(mr_relat.caddat, month to month),'-',
                             extend(mr_relat.caddat, day to day)

                print l_data              clipped ,' ', ASCII(09);

                let l_data = extend(mr_relat.atldat, year to year ),'-',
                             extend(mr_relat.atldat, month to month),'-',
                             extend(mr_relat.atldat, day to day)

                print l_data              clipped ,' ', ASCII(09);

                let l_vig = ""
                let mr_relat.pstvindes = null
                open crelat_19 using mr_relat.srrcoddig
                foreach crelat_19 into mr_relat.viginc,
                                       mr_relat.vigfnl,
                                       mr_relat.pstcoddig,
                                       mr_relat.pstvintip
                    let l_vig = l_vig clipped, mr_relat.pstcoddig clipped, ";",
                                               mr_relat.viginc    clipped, ";",
                                               mr_relat.vigfnl

                    if mr_relat.pstvindes is null then
                        let l_aux = 'pstvintip'
                        open crelat_15 using l_aux,
                                             mr_relat.pstvintip
                        fetch crelat_15 into mr_relat.pstvindes
                    end if
                end foreach

                if  l_vig is not null and l_vig <> " " then
                    print l_vig        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pstvindes is not null and mr_relat.pstvindes <> " " then
                    print mr_relat.pstvindes        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_ass is not null and l_ass <> " " then
                    print l_ass        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_ntz is not null and  l_ntz <> " " then
                    print l_ntz        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.maides_soc is not null then
                   print mr_relat.maides_soc clipped, ASCII(09);
                else
                   print 'NAO CADASTRADO' , ASCII(09);
                end if

                let l_data = extend(mr_relat.rdranlultdat, year to year ),'-',
                             extend(mr_relat.rdranlultdat, month to month),'-',
                             extend(mr_relat.rdranlultdat, day to day)

                if l_data is not null then
                   print l_data, ASCII(09);
                else
                   print 'NAO CADASTRADO' , ASCII(09);
                end if

                let l_aux = 'rdranlsitcod'
                open crelat_15 using l_aux,
                                     mr_relat.rdranlsitcod
                fetch crelat_15 into mr_relat.descricao

                print  mr_relat.descricao  clipped,' ' , ASCII(09);

                let l_aux = 'socanlsitcod'
                open crelat_15 using l_aux,
                                     mr_relat.socanlsitcod
                fetch crelat_15 into mr_relat.descricao

                print  mr_relat.descricao  clipped,' ' , ASCII(09);

                # APENAS VERIFICA SERVICO DE CPF VALIDO
                if mr_relat.cgccpfnum is null then
                   let l_socvidseg = 'NAO'
                   print  l_socvidseg       clipped, ASCII(09);
                else
                   initialize mrv_bdbsr532Vida.* to null
                   call ovgea017(0,
                                 0,
                                 mr_relat.cgccpfnum,
                                 0,
                                 mr_relat.cgccpfdig,
                                 6)
                       returning mrv_bdbsr532Vida.critica1,
                                 mrv_bdbsr532Vida.critica2,
                                 mrv_bdbsr532Vida.critica3,
                                 mrv_bdbsr532Vida.critica4,
                                 mrv_bdbsr532Vida.critica5,
                                 mrv_bdbsr532Vida.critica6,
                                 mrv_bdbsr532Vida.critica7

                   if mrv_bdbsr532Vida.critica1 is null and
                      mrv_bdbsr532Vida.critica2 is null and
                      mrv_bdbsr532Vida.critica3 is null and
                      mrv_bdbsr532Vida.critica4 is null and
                      mrv_bdbsr532Vida.critica5 is null and
                      mrv_bdbsr532Vida.critica6 is null and
                      mrv_bdbsr532Vida.critica7 is null then
                      let l_socvidseg = 'NAO'
                      print  l_socvidseg       clipped, ASCII(09);
                   else
                      let l_socvidseg = 'SIM'
                      print  l_socvidseg       clipped, ASCII(09);
                   end if
                end if

                print mr_relat.srrhsttxt clipped, ASCII(09)
 end report
