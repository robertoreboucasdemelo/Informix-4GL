#------------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                              #
# ...........................................................................  #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                            #
# MODULO.........: BDBSR510                                                    #
# ANALISTA RESP..: SERGIO BURINI                                               #
# PSI/OSF........: RELATORIOS DE PRESTADORES, SOCORRISTAS, VEICULOS, LOJA      #
#                  DE CARRO EXTRA E CANDIDATOS.                                #
# ...........................................................................  #
# DESENVOLVIMENTO: SERGIO BURINI                                               #
# LIBERACAO......: 22/11/2007                                                  #
# ...........................................................................  #
#                                                                              #
#                           * * * ALTERACOES * * *                             #
#                                                                              #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                              #
# --------   --------------  ---------- -------------------------------------  #
# 15/05/08   Ligia Mattge    PSI220710  Inclusao dos campos do socorrista      #
#------------------------------------------------------------------------------#  
# 25/06/08   Thomas META     PSI225134  Inclusao do campo email do sorrorista  #
#------------------------------------------------------------------------------#  
# 27/02/2009 Adriano Santos  PSI237329  Inclusão do Relatorio de Locadoras     #
#------------------------------------------------------------------------------#  
# 09/03/2009 Kevellin        PSI237337  Inclusão DDD, Id e Número Nextel nos   #
# relatórios de socorristas e veículos                                         #
#------------------------------------------------------------------------------#  
# 27/03/2009 Adriano Santos  PSI239178  Inclusão do Relatorio de Candidatos    #
#------------------------------------------------------------------------------#  
# 05/08/2009 Kevellin        PSI198404  Inclusão atividade principal pst       #
#------------------------------------------------------------------------------#  
# 16/10/2009 Beatriz Araujo  PSI249530  Inclusão do campo seguro de vida       #
#------------------------------------------------------------------------------#  
# 04/02/2010 Fabio Costa     PSI198404  Inclusão PIS e sucursal rel. prestador #
#------------------------------------------------------------------------------#  
# 22/02/2010 Fabio Costa     PSI198404  Inclusão flag opt simpl rel. prestador #
#------------------------------------------------------------------------------#  
# 26/08/2010 Beatriz Araujo  PAS102938  Buscar o codigo,descricao do fabricante#
#                                       do equipamento do veiculo              #
#------------------------------------------------------------------------------#
# 01/03/2011 Danilo Santos              Inclusão de seguro porto socorrista e  #
#                                       viatura                                #
#------------------------------------------------------------------------------#
# 04/04/2011 Ueslei Oliveira		Incluindo campos no rel. prestador e   #                    #                                       lojas, Circular 380 Susep              #
#------------------------------------------------------------------------------#
# 03/05/2011 Celso Yamahaki		Alteracao no campo de responsaveis nos #
#					Relatorios de Prestadores e Locadoras  #
#------------------------------------------------------------------------------#
# 21/02/2013 Sergio Burini PSI-2012-23608 Tabela de Etabelecimento - Tributos  #
#------------------------------------------------------------------------------#
# 22/05/2013 Celso Yamahaki             Divisao do Relatorio de Socorristas    #
#                                       em duas partes                         #
#------------------------------------------------------------------------------#
# 01/10/2014 Fornax, RCP   PSI-21950    Tratamento do motivo do bloqueio.      #
#------------------------------------------------------------------------------#
# 08/05/2015 Fornax, RCP   FX-080515    Incluir coluna data no relatorio.      #
#------------------------------------------------------------------------------#

database porto

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
       lcvsttdes       char(15)                        ,   #
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
       gstcdicod       like dpaksocor.gstcdicod        ,    # Codigo da cadeia de gestão
       renfxacod       like dpaksocor.renfxacod	           #Codigo da renda fixa pessoa fisica
end record

define m_dominio record
       erro      smallint  ,
       mensagem  char(100) ,
       cpodes    like iddkdominio.cpodes
end record

# Verificar seguro de Vida
define mrv_bdbsr510Vida record
       critica1 smallint, # segundo o vida quando =   7, possuiu Vital
       critica2 smallint, # segundo o vida quando =  83, possuiu VG
       critica3 smallint, # segundo o vida quando =   6, possui Vital
       critica4 smallint, # segundo o vida quando =  82, possui VG
       critica5 smallint, # segundo o vida quando =  85, possuiu API
       critica6 smallint, # segundo o vida quando =  86, possui API
       critica7 smallint  # segundo o vida quando = 321, possui VN
end record

define m_apolice record
    aplnumdig      like datkvclsgr.aplnumdig,
    sgraplnum      like datkvclsgr.sgraplnum,
    ramcod         like datkvclsgr.ramcod   ,
    succod         like datkvclsgr.succod   ,
    itmnumdig      like datkvclsgr.itmnumdig,
    sgdirbcod      like datkvclsgr.sgdirbcod,
    sgdnom         like gcckcong.sgdnom     ,
    viginc         like datkvclsgr.viginc   ,
    vigfnl         like datkvclsgr.vigfnl   ,
    cbtcscflg      like datkvclsgr.cbtcscflg,    
    cbtrcfflg      like datkvclsgr.cbtrcfflg,     
    sgrimsdmvlr    like datkvclsgr.sgrimsdmvlr,  
    sgrimsdpvlr    like datkvclsgr.sgrimsdpvlr, 
    cbtrcffvrflg   like datkvclsgr.cbtrcffvrflg,
    apol_descricao char(6000)
end record


define m_path      char(1000)
define m_path_txt  char(1000)

main

   initialize mr_relat.*,
              m_path,
              m_path_txt to null
              
   call cts40g03_exibe_info("I", "BDBSR510")

   call bdbsr510_prepare()
   
   set isolation to dirty read

   display " Prestador: "
   call bdbsr510_processa_relat_pst()

   display " Socorrista: "
   call bdbsr510_processa_relat_srr(1)

   display " Socorristas 2: "   
   call bdbsr510_processa_relat_srr(2)

   display " Veiculo: "
   call bdbsr510_processa_relat_vcl()

   display " Loja de carro extra: "
   call bdbsr510_processa_relat_loj()

   display " Candidatos: "
   call bdbsr510_processa_relat_can() 

   call cts40g03_exibe_info("F", "BDBSR510")

end main

#------------------------#
 function bdbsr510_prepare()
#------------------------#

        define l_sql char(10000)

        let l_sql = " select pst.pstcoddig, ",
                           " pst.nomgrr   , ",
                           " pst.nomrazsoc, ",
                           " pst.prssitcod, ",
                           " pst.pestip   , ",
                           " pst.cgccpfnum, ",
                           " pst.cgcord   , ",
                           " pst.cgccpfdig, ",
                           " pst.muninsnum, ",
                           " pst.lgdtip   , ",
                           " pst.endlgd   , ",
                           " pst.lgdnum   , ",
                           " pst.endcmp   , ",
                           " pst.endbrr   , ",
                           " pst.endcid   , ",
                           " pst.endufd   , ",
                           " pst.endcep   , ",
                           " pst.endcepcmp, ",
                           " pst.dddcod   , ",
                           " pst.teltxt   , ",
                           " pst.faxnum   , ",
                           " pst.celdddnum, ",
                           " pst.celtelnum, ",
                           " pst.maides   , ",
                           " pst.pptnom   , ",
                           " pst.rspnom   , ",
                           " pgt.socfavnom, ",
                           " pgt.pestip   , ",
                           " pgt.cgccpfnum, ",
                           " pgt.cgcord   , ",
                           " pgt.cgccpfdig, ",
                           " pgt.bcoctatip, ",
                           " pgt.bcocod   , ",
                           " pgt.bcoagnnum, ",
                           " pgt.bcoagndig, ",
                           " pgt.bcoctanum, ",
                           " pgt.bcoctadig, ",
                           " pgt.socpgtopccod, ",
                           " pst.patpprflg, ",
                           " pst.srvnteflg, ",
                           " pst.qldgracod, ",
                           " pst.prscootipcod, ",
                           " pst.vlrtabflg, ",
                           " pst.soctrfcod, ",
                           " pst.rmesoctrfcod, ",
                           " pst.pstobs, ",
                           " pst.intsrvrcbflg, ",
                           " pst.risprcflg, ",
                           " pst.cmtdat, ",
                           " pst.atldat, ",
                           " pst.frtrpnflg, ",
                           " pst.pcpatvcod, ",
                           " pst.succod, ",
                           " pst.pisnum, ",
                           " pst.simoptpstflg, ",
                           " pst.pcpprscod, ",
                           " pst.renfxacod, ",
                           " pst.gstcdicod ",
                      " from dpaksocor    pst, ",
                           " dpaksocorfav pgt ",
                     " where pst.pstcoddig = pgt.pstcoddig "

        prepare prelat_01 from l_sql
        declare crelat_01 cursor for prelat_01

        let l_sql = " select prshstdes ",
                      " from dbsmhstprs ",
                     " where pstcoddig = ? "

        prepare prelat_02 from l_sql
        declare crelat_02 cursor for prelat_02

        let l_sql = 'select grp.socntzgrpdes ',
                     ' from dparpstgrpntz ntz, ',
                          ' datksocntzgrp grp ' ,
                    ' where ntz.socntzgrpcod = grp.socntzgrpcod ',
                      ' and ntz.pstcoddig = ? '

        prepare prelat_03 from l_sql
        declare crelat_03 cursor for prelat_03

        let l_sql = " select atdfnlnum ",
                      " from dpakdtbpst ",
                     " where pstcoddig = ? "

        prepare prelat_04 from l_sql
        declare crelat_04 cursor for prelat_04

        let l_sql = " select b.asitipdes ",
                      " from datrassprs a, ",
                           " datkasitip b ",
                     " where b.asitipcod  =  a.asitipcod ",
                       " and a.pstcoddig  =  ? "

        prepare prelat_05 from l_sql
        declare crelat_05 cursor for prelat_05

        let l_sql = " select empsgl ",
                      " from dparpstemp, ",
                           " gabkemp ",
                     " where ciaempcod = empcod ",
                       " and pstcoddig = ? "

        prepare prelat_06 from l_sql
        declare crelat_06 cursor for prelat_06

        let l_sql = " select crnpgtdes ",
                      " from dpaksocor a, ",
                           " dbsmcrnpgt b ",
                     " where a.crnpgtcod = b.crnpgtcod ",
                       " and a.pstcoddig = ? "

        prepare prelat_07 from l_sql
        declare crelat_07 cursor for prelat_07

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
                           " srr.maides ",
                      " from datksrr    srr,",
                           " outer datksrrend ende ",
                     " where ende.srrcoddig = srr.srrcoddig",
                     "   and srr.srrstt = 1"


        prepare prelat_08 from l_sql
        declare crelat_08 cursor for prelat_08

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
                           " srr.maides ",
                      " from datksrr    srr,",
                           " outer datksrrend ende ",
                     " where ende.srrcoddig = srr.srrcoddig",
                     "   and srr.srrstt != 1"


        prepare prelat_08a from l_sql
        declare crelat_08a cursor for prelat_08a



        let l_sql = " select pst.pstcoddig, ",
                           " pst.nomgrr, ",
                           " pst.pestip, ",
                           " pst.cgccpfnum, ",
                           " pst.cgcord, ",
                           " pst.cgccpfdig, ",
                           " pst.pptnom, ",
                           " pst.dddcod, ",
                           " pst.teltxt, ",
                           " pst.maides, ",
                           " pst.prssitcod, ",
                           " pst.cmtdat, ",
                           " pst.atldat, ",
                           " vcl.socvclcod, ",
                           " vcl.atdvclsgl, ",
                           " vcl.vclanomdl, ",
                           " vcl.socoprsitcod, ",
                           " vcl.vcllicnum, ",
                           " vcl.vclanofbc, ",
                           " vcl.mdtcod, ",
                           " vcl.pgrnum, ",
                           " vcl.caddat, ",
                           " vcl.atldat, ",
                           " pst.endcid, ",
                           " pst.endufd, ",
                           " vcl.celdddcod, ",
                           " vcl.celtelnum, ",
                           " vcl.nxtdddcod, ",
                           " vcl.nxtide, ",
                           " vcl.nxtnum, ",
                           " vcl.vclctfnom, ",
                           " vcl.vclaqstipcod, ",
                           " vcl.vclaqsnom, ",
                           " vcl.vclcoddig, ",
                           " vcl.socvcltip, ",
                           " vcl.vclchsinc || vcl.vclchsfnl, ",
                           " vcl.vclcorcod, ",
                           " vcl.vclpnttip, ",
                           " vcl.vclcmbcod, ",
                           " vcl.socvstdiaqtd, ",
                           " vcl.socvstlclcod, ",
                           " vcl.socvstlautipcod, ",
                           " vcl.socctrposflg, ",
                           " pst.pstobs, ",
                           " vcl.bckcod, ",
                           " vcl.dpycod,  ",
                           " pst.frtrpnflg, ",
                           " vcl.rencod,      ",      
                           " vcl.vclcadorgcod ",
                     " from datkveiculo vcl, ",
                          " dpaksocor pst ",
                    " where vcl.pstcoddig = pst.pstcoddig ",
                    " order by pstcoddig desc "

        prepare prelat_09 from l_sql
        declare crelat_09 cursor for prelat_09

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


        let l_sql = " select soceqpcod ",
                      " from datreqpvcl ",
                     " where socvclcod = ? "

        prepare prelat_12 from l_sql
        declare crelat_12 cursor for prelat_12

        let l_sql = " select empsgl ",
                      " from datrvclemp, ",
                           " gabkemp ",
                     " where ciaempcod = empcod ",
                       " and socvclcod = ? "

        prepare prelat_14 from l_sql
        declare crelat_14 cursor for prelat_14

        let l_sql = " select cpodes ",
                      " from iddkdominio ",
                     " where cponom = ? ",
                       " and cpocod = ? "

        prepare prelat_15 from l_sql
        declare crelat_15 cursor for prelat_15

        let l_sql = " select vcldtbgrpdes ",
                      " from dattfrotalocal a, ",
                           " datkvcldtbgrp b ",
                     " where socvclcod = ? ",
                       " and a.vcldtbgrpcod = b.vcldtbgrpcod "

        prepare prelat_16 from l_sql
        declare crelat_16 cursor for prelat_16
         
        # 26/08/2010 Beatriz Araujo  PAS102938 - só foi alterado o select
        #A funcao NVL verifica se uma expressao eh NULA, se sim retorna o valor da 
        # segunda expressao no lugar, se nao for NULA retorna a propria expressao. EX: nvl(b.eqpfabcod,'')
        let l_sql = "select a.soceqpcod||' - '||soceqpdes||'/ '||nvl(b.eqpfabcod,'')||' - '||nvl(c.eqpfababv,'')",
                     " from datkvcleqp a, ",
                         "  datreqpvcl  b, ",
                         "  outer datkeqpfab c ",
                    " where a.soceqpcod = b.soceqpcod ",
                      " and b.eqpfabcod = c.eqpfabcod ",
                      " and socvclcod = ? "

        prepare prelat_17 from l_sql
        declare crelat_17 cursor for prelat_17

        let l_sql = "select socvstlclnom ",
                     " from datkvstlcl ",
                    " where socvstlclcod = ? "

        prepare prelat_18 from l_sql
        declare crelat_18 cursor for prelat_18

        let l_sql = "select viginc, ",
                          " vigfnl, ",
                          " pstcoddig, ",
                          " pstvintip  ",
                     " from datrsrrpst ",
                    " where srrcoddig  = ? ",
                    " order by viginc desc "

        prepare prelat_19 from l_sql
        declare crelat_19 cursor for prelat_19

        let l_sql = "select mdtctrcod ",
                     " from datkmdt ",
                    " where mdtcod = ? "

        prepare prelat_20 from l_sql
        declare crelat_20 cursor for prelat_20


        let l_sql = "select asitipdes ",
                     " from datrvclasi a, outer datkasitip b ",
                    " where a.socvclcod = ? ",
                      " and a.asitipcod = b.asitipcod"

        prepare prelat_21 from l_sql
        declare crelat_21 cursor for prelat_21

        let l_sql = " select bckdes ",
                      " from dpakbck ",
                     " where bckcod = ? "

        prepare prelat_22 from l_sql
        declare crelat_22 cursor for prelat_22

        let l_sql = " select dpydes ",
                      " from dpakdpy ",
                     " where dpycod = ? "

        prepare prelat_23 from l_sql
        declare crelat_23 cursor for prelat_23

        let l_sql = " select srrhsttxt, srrhstseq  ",
                      " from datmsrrhst ",
                     " where srrcoddig = ? ",
                       " order by srrhstseq desc "

        prepare prelat_26 from l_sql
        declare crelat_26 cursor for prelat_26

        let l_sql = "  select cpodes ",
                    "  from iddkdominio ",
                    " where iddkdominio.cponom ='frtrpnflg' ",
                    "   and iddkdominio.cpocod = ? "
        prepare prelat_24 from l_sql
        declare crelat_24 cursor for prelat_24

        let l_sql = "  select frtrpnflg ",
                    "  from   dpaksocor ",
                    " where pstcoddig = ? "
        prepare prelat_25 from l_sql
        declare crelat_25 cursor for prelat_25

        let l_sql = "select mdtcfgcod ",
                     " from datkmdt ",
                    " where mdtcod = ? "

        prepare prelat_27 from l_sql
        declare crelat_27 cursor for prelat_27

        let l_sql = "  select dpckserv.pstsrvdes                   ",
                   # "       dpatserv.pstsrvtip,                      ",
                   # "       dpatserv.pstsrvctg                       ",
                    "  from dpatserv, dpckserv                       ",
                    " where dpatserv.pstcoddig = ?                   ",
                    "   and dpckserv.pstsrvtip = dpatserv.pstsrvtip  ",
                    " order by  dpatserv.pstsrvtip                   "

        prepare prelat_28 from l_sql
        declare crelat_28 cursor for prelat_28

        let l_sql = " select loc.lcvcod                , ",
                    "        loc.lcvnom                , ",
                    "        loc.lgdnom                , ",
                    "        loc.brrnom                , ",
                    "        loc.cidnom                , ",
                    "        loc.endufd                , ",
                    "        loc.dddcod                , ",
                    "        loc.teltxt                , ",
                    "        loc.facnum                , ",
                    "        loc.adcsgrtaxvlr          , ",
                    "        loc.cdtsegtaxvlr          , ",
                    "        loc.cgccpfnum             , ",
                    "        loc.cgcord                , ",
                    "        loc.cgccpfdig             , ",
                    "        loc.lcvresenvcod          , ",
                    "        loc.lcvstt                , ",
                    "        loc.acntip                , ",
                    "        loc.maides                , ",
                    "        loc.caddat                , ",
                    "        loc.atldat                , ",
                    "        loj.lcvextcod             , ",
                    "        loj.aviestcod             , ",
                    "        loj.aviestnom             , ",
                    "        loj.lcvlojtip             , ",
                    "        loj.lojqlfcod             , ",
                    "        loj.endlgd                , ",
                    "        loj.endbrr                , ",
                    "        loj.endcid                , ",
                    "        loj.endufd                , ",
                    "        loj.endcep                , ",
                    "        loj.endcepcmp             , ",
                    "        loj.refptodes             , ",
                    "        loj.succod                , ",
                    "        loj.dddcod                , ",
                    "        loj.teltxt                , ",
                    "        loj.facnum                , ",
                    "        loj.horsegsexinc          , ",
                    "        loj.horsegsexfnl          , ",
                    "        loj.horsabinc             , ",
                    "        loj.horsabfnl             , ",
                    "        loj.hordominc             , ",
                    "        loj.hordomfnl             , ",
                    "        loj.lcvregprccod          , ",
                    "        loj.vclalglojstt          , ",
                    "        loj.cauchqflg             , ",
                    "        loj.prtaertaxvlr          , ",
                    "        loj.maides                , ",
                    "        loj.obs                     ",
                    "    from datkavislocal loj        , ",
                    "         datklocadora  loc          ",
                    "    where loc.lcvcod = loj.lcvcod   ",
                    "    order by loc.lcvcod,            ",
                    "             loj.aviestcod          "

        prepare prelat_29 from l_sql
        declare crelat_29 cursor for prelat_29

        let l_sql = "  select cpodes                       ",
                    "    from iddkdominio                  ",
                    "    where cponom = 'PSOLOCQLD'        ",
                    "      and cpocod = ?                  "

        prepare prelat_30 from l_sql
        declare crelat_30 cursor for prelat_30


        let l_sql = "  select sucnom                       ",
                    "    from gabksuc                      ",
                    "    where succod = ?                  "

        prepare prelat_31 from l_sql
        declare crelat_31 cursor for prelat_31


        let l_sql = " select ramcod,        ",
                    "        clscod         ",
                    "   from datrclauslocal ",
                    " where lcvcod = ?      ",
                    "   and aviestcod = ?   ",
                    " order by 1, 2         "

        prepare prelat_32 from l_sql
        declare crelat_32 cursor for prelat_32


        let l_sql = " select clsdes ",
                " from aackcls ",
               " where ramcod = ? ",
                 " and clscod = ? "

        prepare prelat_33 from l_sql
        declare crelat_33 cursor for prelat_33

        #Buscar registros de cidades de entrega para a loja
        let l_sql = ' select cidcod, etgtaxvlr  '
                   ,' from datklcletgvclext     '
                   ,' where lcvcod = ?          '
                   ,'   and aviestcod = ?       '
        prepare prelat_34 from l_sql
        declare crelat_34 cursor for prelat_34

        let l_sql = 'select recsinflg,     ',
                    '       cdssimintcod,  ',
                    '       celoprcod      ',
                    '  from datksimmdt mdt,',
                    '       datkcdssim sim ',
                    ' where mdt.cdssimide = sim.cdssimide ',
                    '   and mdtcod = ? '
        prepare prelat_35 from l_sql
        declare crelat_35 cursor for prelat_35

        let l_sql = "select oprnom ",
                     " from pcckceltelopr ",
                    " where oprcod = ? "
        prepare prelat_36 from l_sql
        declare crelat_36 cursor for prelat_36

        let l_sql = ' select pstcndcod '
                   ,' ,pestip '
                   ,' ,cgccpfnum '
                   ,' ,cgcord '
                   ,' ,cgccpfdig '
                   ,' ,pstcndnom '
                   ,' ,rgenum '
                   ,' ,rgeufdcod '
                   ,' ,nscdat '
                   ,' ,cnhnum '
                   ,' ,cnhctgcod '
                   ,' ,cnhpridat '
                   ,' ,pstcndsitcod '
                   ,' ,rdranlultdat '
                   ,' ,caddat '
                   ,' ,cademp '
                   ,' ,cadmat '
                   ,' ,atldat '
                   ,' ,atlemp '
                   ,' ,atlmat '
                   ,' ,atlusrtip '
                   ,' ,cadusrtip '
                   ,' ,atlusrtip '
                   ,' ,pstcndconcod '
                   ,' ,srrcoddig '
                ,'   from dpakcnd '
                ,'  order by  pstcndcod'

        prepare prelat_37 from l_sql
        declare crelat_37 cursor for prelat_37

        let l_sql = ' select caddat        '
              ,'   from datksrr       '
              ,'  where srrcoddig = ? '
        prepare prelat_38 from l_sql
        declare crelat_38 cursor for prelat_38

        let l_sql = ' select pstcoddig, caddat'
                   ,'   from dparpstcnd       '
                   ,'  where pstcndcod = ?    '
        prepare prelat_39 from l_sql
        declare crelat_39 cursor for prelat_39

        let l_sql = " select 1 ",
                      " from dparbnfprt ",
                     " where pstcoddig = ? ",
                       " and prtbnfprccod = ? "
        prepare prelat_40 from l_sql
        declare crelat_40 cursor for prelat_40

        let l_sql = 'select ntz.socntzdes ',
                     ' from dparpstntz pn, ',
                          ' datksocntz ntz ' ,
                    ' where pn.socntzcod = ntz.socntzcod ',
                      ' and pn.pstcoddig = ? '

        prepare prelat_41 from l_sql
        declare crelat_41 cursor for prelat_41


        let l_sql = 'select dpakprscntvigctr.cntvigincdat,  ',
                    '       dpakprscntvigctr.cntvigfnldat   ',
                    '  from dpakprscntvigctr                ',
                    ' where dpakprscntvigctr.pstcoddig  = ? ',
                    ' order by cntvigincdat desc            '

        prepare prelat_42 from l_sql
        declare crelat_42 cursor for prelat_42
        
        
        # 15/09/2010 Beatriz Araujo  PSI-2010-00009EV - Trazer as informacoes da apolice Porto Seguro
        #A funcao NVL verifica se uma expressao eh NULA, se sim retorna o valor da 
        # segunda expressao no lugar, se nao for NULA retorna a propria expressao. EX: nvl(c.sgdnom,'')
        let l_sql = "select a.aplnumdig,a.sgraplnum,",
                    "       a.ramcod,a.succod, ",
                    "       a.itmnumdig,a.sgdirbcod ,nvl(c.sgdnom,''),", 
                    "       a.viginc,a.vigfnl,                    ",
                    "       a.cbtcscflg,a.cbtrcfflg,              ",
                    "       a.sgrimsdmvlr,a.sgrimsdpvlr,          ",
                    "       a.cbtrcffvrflg                        ",
                    "  from datkvclsgr  a,                        ",
                    "       datkveiculo b,                        ",
                    "       outer gcckcong c                      ",
                    " where a.socvclcod = b.socvclcod             ",
                    "   and a.sgdirbcod = c.sgdirbcod             ",
                    "   and a.socvclcod = ?                       "
        prepare prelat_43 from l_sql
        declare crelat_43 cursor for prelat_43
        
        
       # 24/09/2010 Beatriz Araujo  PSI-2010-00009EV - Trazer o nome do prestador principal
       let l_sql = "select pstcoddig||'- '||nvl(nomgrr,'') from dpaksocor",
                 "  where pstcoddig = ?       "
       prepare prelat_44 from l_sql                    
       declare crelat_44 cursor for prelat_44
       
       # 24/09/2010 Beatriz Araujo  PSI-2010-00009EV - Trazer os dados da cadeia de gestao 
       let l_sql = "select gstcdicod||'-'||nvl(sprnom,'')||'/ '||nvl(gernom,'')||'/ '||nvl(cdnnom,'')||'/ '||nvl(anlnom,'')  ",
                 "  from dpakprsgstcdi   ", 
                 "  where gstcdicod = ?  "  
       prepare prelat_45 from l_sql              
       declare crelat_45 cursor for prelat_45  
       
       #27/09/2010 Beatriz Araujo  PSI-2010-00009EV - Trazer todas as bonificacoes do prestador
       let l_sql = "select prtbnfprccod  ",
                   "  from dparbnfprt    ",
                   " where  pstcoddig = ?"
       prepare prelat_46 from l_sql                  
       declare crelat_46 cursor for prelat_46
       
       #27/09/2010 Beatriz Araujo  PSI-2010-00009EV - Trazer todas as descricoes das bonificacoes do prestador
       let l_sql = "select prtbnfprcdes    ",
                   "  from dpakprtbnfprc   ",     
                   "where  prtbnfprccod = ?"     
       prepare prelat_47 from l_sql            
       declare crelat_47 cursor for prelat_47 

      #31/03/2011 Ueslei Oliveira - Trazer os responsaveis pela prestadora.
      let l_sql = "select a.ctdnom,              ",
		  "       a.cgccpfnumdig,        ",
       		  "       a.pepindcod  	         ",
		  " from dpakctd a, dparpstctd b ", 
		  "where a.ctdcod = b.ctdcod     ", 
		  "  and b.pstcoddig =  ?        ", 
		  "  and a.ctdtip = ?            "  
		
       prepare prelat_48 from l_sql            
       declare crelat_48 cursor for prelat_48
       
       #04/04/2011 Ueslei Oliveira - Trazer os responsaveis pela locadora.
       let l_sql = "select   a.ctdnom,		     ",
       		   " 	     a.cgccpfnumdig,         ",
       		   " 	     a.pepindcod  	     ",
                   "    from dpakctd a, dparavictd b ",
                   "   where a.ctdcod = b.ctdcod     ",
                   "  and (                          ",
                   "       b.lcvcod =  ?             ",
                   "  and                            ",
                   "      b.aviestcod =  ?           ",             
                   "  )                              ",
                   "  and a.ctdtip = ?               " 
                                                    
       prepare prelat_49 from l_sql                     
       declare crelat_49 cursor for prelat_49
       
       let l_sql = "select ciaempcod ",
                    " from datrlcdljaemprlc ",
                   " where lcvcod    = ? ",
                     " and aviestcod = ? "
       
       prepare prelat_50 from l_sql                 
       declare crelat_50 cursor for prelat_50
       
       let l_sql = " select cpocod                 ",
                   "   from iddkdominio            ",
                   "  where cponom = 'endtipcod'   ",
                   "  order by cpocod               "
       
       prepare prelat_51 from l_sql                 
       declare crelat_51 cursor for prelat_51


 end function

#--------------------------------------#
 function bdbsr510_processa_relat_pst()
#--------------------------------------#

        open crelat_01
        fetch crelat_01 into mr_relat.pstcoddig        ,
                             mr_relat.nomgrr           ,
                             mr_relat.nomrazsoc        ,
                             mr_relat.prssitcod        ,
                             mr_relat.pestip           ,
                             mr_relat.cgccpfnum        ,
                             mr_relat.cgcord           ,
                             mr_relat.cgccpfdig        ,
                             mr_relat.muninsnum        ,
                             mr_relat.endtiplgd        ,
                             mr_relat.endlgd           ,
                             mr_relat.lgdnum           ,
                             mr_relat.endcmp           ,
                             mr_relat.endbrr           ,
                             mr_relat.endcid           ,
                             mr_relat.endufd           ,
                             mr_relat.endcep           ,
                             mr_relat.endcepcmp        ,
                             mr_relat.dddcod           ,
                             mr_relat.teltxt           ,
                             mr_relat.faxnum           ,
                             mr_relat.celdddnum        ,
                             mr_relat.celtelnum        ,
                             mr_relat.maides           ,
                             mr_relat.pptnom           ,
                             mr_relat.rspnom           ,
                             mr_relat.socfavnom        ,
                             mr_relat.pestip2          ,
                             mr_relat.cgccpfnum2       ,
                             mr_relat.cgcord2          ,
                             mr_relat.cgccpfdig2       ,
                             mr_relat.bcoctatip        ,
                             mr_relat.bcocod           ,
                             mr_relat.bcoagnnum        ,
                             mr_relat.bcoagndig        ,
                             mr_relat.bcoctanum        ,
                             mr_relat.bcoctadig        ,
                             mr_relat.socpgtopccod2    ,
                             mr_relat.patpprflg        ,
                             mr_relat.srvnteflg        ,
                             mr_relat.qldgracod        ,
                             mr_relat.prscootipcod     ,
                             mr_relat.vlrtabflg        ,
                             mr_relat.soctrfcod        ,
                             mr_relat.rmesoctrfcod     ,
                             mr_relat.pstobs           ,
                             mr_relat.intsrvrcbflg     ,
                             mr_relat.risprcflg        ,
                             mr_relat.cmtdat           ,
                             mr_relat.atldat           ,
                             mr_relat.frtrpnflg        ,
                             mr_relat.pcpatvcod        ,
                             mr_relat.succod           ,
                             mr_relat.pisnum           ,
                             mr_relat.simoptpstflg     ,
                             mr_relat.pcpprscod        ,
                             mr_relat.renfxacod	       ,
                             mr_relat.gstcdicod
        case sqlca.sqlcode
                when 0
                        call bdbsr510_busca_path("PST")

                        start report relat_pst to m_path
                        start report relat_pst_txt to m_path_txt

                        foreach  crelat_01 into mr_relat.pstcoddig        ,
                                                mr_relat.nomgrr           ,
                                                mr_relat.nomrazsoc        ,
                                                mr_relat.prssitcod        ,
                                                mr_relat.pestip           ,
                                                mr_relat.cgccpfnum        ,
                                                mr_relat.cgcord           ,
                                                mr_relat.cgccpfdig        ,
                                                mr_relat.muninsnum        ,
                                                mr_relat.endtiplgd        ,
                                                mr_relat.endlgd           ,
                                                mr_relat.lgdnum           ,
                                                mr_relat.endcmp           ,
                                                mr_relat.endbrr           ,
                                                mr_relat.endcid           ,
                                                mr_relat.endufd           ,
                                                mr_relat.endcep           ,
                                                mr_relat.endcepcmp        ,
                                                mr_relat.dddcod           ,
                                                mr_relat.teltxt           ,
                                                mr_relat.faxnum           ,
                                                mr_relat.celdddnum        ,
                                                mr_relat.celtelnum        ,
                                                mr_relat.maides           ,
                                                mr_relat.pptnom           ,
                                                mr_relat.rspnom           ,
                                                mr_relat.socfavnom        ,
                                                mr_relat.pestip2          ,
                                                mr_relat.cgccpfnum2       ,
                                                mr_relat.cgcord2          ,
                                                mr_relat.cgccpfdig2       ,
                                                mr_relat.bcoctatip        ,
                                                mr_relat.bcocod           ,
                                                mr_relat.bcoagnnum        ,
                                                mr_relat.bcoagndig        ,
                                                mr_relat.bcoctanum        ,
                                                mr_relat.bcoctadig        ,
                                                mr_relat.socpgtopccod2    ,
                                                mr_relat.patpprflg        ,
                                                mr_relat.srvnteflg        ,
                                                mr_relat.qldgracod        ,
                                                mr_relat.prscootipcod     ,
                                                mr_relat.vlrtabflg        ,
                                                mr_relat.soctrfcod        ,
                                                mr_relat.rmesoctrfcod     ,
                                                mr_relat.pstobs           ,
                                                mr_relat.intsrvrcbflg     ,
                                                mr_relat.risprcflg        ,
                                                mr_relat.cmtdat           ,
                                                mr_relat.atldat           ,
                                                mr_relat.frtrpnflg        ,
                                                mr_relat.pcpatvcod        ,
                                                mr_relat.succod           ,
                                                mr_relat.pisnum           ,
                                                mr_relat.simoptpstflg     ,
                                                mr_relat.pcpprscod        ,
                                                mr_relat.renfxacod	  ,
                                                mr_relat.gstcdicod         
                                output to report relat_pst()
                                output to report relat_pst_txt()

                                initialize mr_relat.* to null

                        end foreach

                        finish report relat_pst
                        finish report relat_pst_txt

                       call relat_envia_mail("PST", m_path)

                when 100
                        error 'NENHUM PRESTADOR A SER LISTADO.'
                otherwise
                        error 'ERRO', sqlca.sqlcode, ' NENHUM PRESTADOR LISTADO.'

        end case

 end function

#--------------------------------------#
 function bdbsr510_processa_relat_srr(l_tipo)
#--------------------------------------#

        define l_teste char(15),
               l_tipo  smallint

        
        if l_tipo = 1 then
        
        call bdbsr510_busca_path("SRR")
        start report relat_srr to m_path
        start report relat_srr_txt to m_path_txt
        open crelat_08
        
        foreach crelat_08 into mr_relat.srrcoddig  ,
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
                               mr_relat.maides_soc

                               output to report relat_srr()
                               output to report relat_srr_txt()
                               
                               initialize mr_relat.* to null

                        end foreach

                        finish report relat_srr
                        finish report relat_srr_txt

                        call relat_envia_mail("SRR", m_path)

                
 else
    call bdbsr510_busca_path("SR2")

    start report relat_srr to m_path
    start report relat_srr_txt to m_path_txt
 
    open crelat_08a
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
                           mr_relat.maides_soc

            output to report relat_srr()
            output to report relat_srr_txt()
            initialize mr_relat.* to null

      end foreach

      finish report relat_srr
      finish report relat_srr_txt

      call relat_envia_mail("SR2", m_path)

 
 end if
 end function

#--------------------------------------#
 function bdbsr510_processa_relat_vcl()
#--------------------------------------#

        define l_teste char(15)
        define seq smallint
         
        call bdbsr510_busca_path("VCL")
        start report relat_vcl to m_path
        start report relat_vcl_txt to m_path_txt
        initialize mr_relat.* to null
        initialize m_apolice.* to null
        let seq = 0
        foreach crelat_09 into mr_relat.pstcoddig,
                               mr_relat.nomgrr,
                               mr_relat.pestip,
                               mr_relat.cgccpfnum,
                               mr_relat.cgcord,
                               mr_relat.cgccpfdig,
                               mr_relat.pptnom,
                               mr_relat.dddcod,
                               mr_relat.teltxt,
                               mr_relat.maides,
                               mr_relat.prssitcod,
                               mr_relat.cmtdat,
                               mr_relat.atldat,
                               mr_relat.socvclcod,
                               mr_relat.atdvclsgl,
                               mr_relat.vclanomdl,
                               mr_relat.socoprsitcod,
                               mr_relat.vcllicnum,
                               mr_relat.vclanofbc,
                               mr_relat.mdtcod,
                               mr_relat.pgrnum,
                               mr_relat.caddat,
                               mr_relat.atldat2,
                               mr_relat.endcid,
                               mr_relat.endufd,
                               mr_relat.celdddcod,
                               mr_relat.celtelnum,
                               mr_relat.nxtdddcod,
                               mr_relat.nxtide,
                               mr_relat.nxtnum,
                               mr_relat.vclctfnom,
                               mr_relat.vclaqstipcod,
                               mr_relat.vclaqsnom,
                               mr_relat.vclcoddig,
                               mr_relat.eqptip,
                               mr_relat.vclchs,
                               mr_relat.vclcorcod,
                               mr_relat.vclpnttip,
                               mr_relat.vclcmbcod,
                               mr_relat.socvstdiaqtd,
                               mr_relat.socvstlclcod,
                               mr_relat.socvstlautipcod,
                               mr_relat.socctrposflg,
                               mr_relat.pstobs,
                               mr_relat.bckcod,
                               mr_relat.dpycod,
                               mr_relat.frtrpnflg,
                               mr_relat.rencod,      
                               mr_relat.vclcadorgcod
                               
                # procurar as apolices de seguro da viatura
                open crelat_43  using mr_relat.socvclcod 
                foreach crelat_43 into m_apolice.aplnumdig, 
                                     m_apolice.sgraplnum, 
                                     m_apolice.ramcod   , 
                                     m_apolice.succod   , 
                                     m_apolice.itmnumdig, 
                                     m_apolice.sgdirbcod, 
                                     m_apolice.sgdnom   , 
                                     m_apolice.viginc   , 
                                     m_apolice.vigfnl   , 
                                     m_apolice.cbtcscflg  ,   
                                     m_apolice.cbtrcfflg ,  
                                     m_apolice.sgrimsdmvlr , 
                                     m_apolice.sgrimsdpvlr , 
                                     m_apolice.cbtrcffvrflg             
                    
                     let seq = seq +1
                    call bdbsr510_monta_descricao(seq)
                    
                end foreach
                display "==============================================="                        
                output to report relat_vcl()
                output to report relat_vcl_txt()
                 let seq = 0
                initialize m_apolice.* to null
                   
        end foreach
        finish report relat_vcl
        finish report relat_vcl_txt
        call relat_envia_mail("VCL", m_path)
 end function


#--------------------------------------#
 function bdbsr510_processa_relat_loj() # PSI 237329
#--------------------------------------#

        define l_teste char(15)

     whenever error continue
        open crelat_29
        fetch crelat_29 into mr_relat.lcvcod        ,
                             mr_relat.lcvnom        ,
                             mr_relat.lgdnom        ,
                             mr_relat.brrnom        ,
                             mr_relat.cidnom        ,
                             mr_relat.endufd_loc    ,
                             mr_relat.dddcod_loc    ,
                             mr_relat.teltxt_loc    ,
                             mr_relat.facnum_loc    ,
                             mr_relat.adcsgrtaxvlr  ,
                             mr_relat.cdtsegtaxvlr  ,
                             mr_relat.cgccpfnum_loc ,
                             mr_relat.cgcord_loc    ,
                             mr_relat.cgccpfdig_loc ,
                             mr_relat.lcvresenvcod  ,
                             mr_relat.lcvstt        ,
                             mr_relat.acntip        ,
                             mr_relat.maides_loc    ,
                             mr_relat.caddat_loc    ,
                             mr_relat.atldat_loc    ,
                             mr_relat.lcvextcod     ,
                             mr_relat.aviestcod     ,
                             mr_relat.aviestnom     ,
                             mr_relat.lcvlojtip     ,
                             mr_relat.lojqlfcod     ,
                             mr_relat.endlgd_loj    ,
                             mr_relat.endbrr_loj    ,
                             mr_relat.endcid_loj    ,
                             mr_relat.endufd_loj    ,
                             mr_relat.endcep_loj    ,
                             mr_relat.endcepcmp_loj ,
                             mr_relat.refptodes     ,
                             mr_relat.succod        ,
                             mr_relat.dddcod_loj    ,
                             mr_relat.teltxt_loj    ,
                             mr_relat.facnum_loj    ,
                             mr_relat.horsegsexinc  ,
                             mr_relat.horsegsexfnl  ,
                             mr_relat.horsabinc     ,
                             mr_relat.horsabfnl     ,
                             mr_relat.hordominc     ,
                             mr_relat.hordomfnl     ,
                             mr_relat.lcvregprccod  ,
                             mr_relat.vclalglojstt  ,
                             mr_relat.cauchqflg     ,
                             mr_relat.prtaertaxvlr  ,
                             mr_relat.maides_loj    ,
                             mr_relat.obs

     whenever error stop

        case sqlca.sqlcode
                when 0
                        call bdbsr510_busca_path("LOJ")

                        start report relat_loj to m_path
                        start report relat_loj_txt to m_path_txt

                            initialize mr_relat.* to null

                        foreach crelat_29 into mr_relat.lcvcod        ,
                                               mr_relat.lcvnom        ,
                                               mr_relat.lgdnom        ,
                                               mr_relat.brrnom        ,
                                               mr_relat.cidnom        ,
                                               mr_relat.endufd_loc    ,
                                               mr_relat.dddcod_loc    ,
                                               mr_relat.teltxt_loc    ,
                                               mr_relat.facnum_loc    ,
                                               mr_relat.adcsgrtaxvlr  ,
                                               mr_relat.cdtsegtaxvlr  ,
                                               mr_relat.cgccpfnum_loc ,
                                               mr_relat.cgcord_loc    ,
                                               mr_relat.cgccpfdig_loc ,
                                               mr_relat.lcvresenvcod  ,
                                               mr_relat.lcvstt        ,
                                               mr_relat.acntip        ,
                                               mr_relat.maides_loc    ,
                                               mr_relat.caddat_loc    ,
                                               mr_relat.atldat_loc    ,
                                               mr_relat.lcvextcod     ,
                                               mr_relat.aviestcod     ,
                                               mr_relat.aviestnom     ,
                                               mr_relat.lcvlojtip     ,
                                               mr_relat.lojqlfcod     ,
                                               mr_relat.endlgd_loj    ,
                                               mr_relat.endbrr_loj    ,
                                               mr_relat.endcid_loj    ,
                                               mr_relat.endufd_loj    ,
                                               mr_relat.endcep_loj    ,
                                               mr_relat.endcepcmp_loj ,
                                               mr_relat.refptodes     ,
                                               mr_relat.succod        ,
                                               mr_relat.dddcod_loj    ,
                                               mr_relat.teltxt_loj    ,
                                               mr_relat.facnum_loj    ,
                                               mr_relat.horsegsexinc  ,
                                               mr_relat.horsegsexfnl  ,
                                               mr_relat.horsabinc     ,
                                               mr_relat.horsabfnl     ,
                                               mr_relat.hordominc     ,
                                               mr_relat.hordomfnl     ,
                                               mr_relat.lcvregprccod  ,
                                               mr_relat.vclalglojstt  ,
                                               mr_relat.cauchqflg     ,
                                               mr_relat.prtaertaxvlr  ,
                                               mr_relat.maides_loj    ,
                                               mr_relat.obs

                                output to report relat_loj()
                                output to report relat_loj_txt()

                        end foreach

                        finish report relat_loj
                        finish report relat_loj_txt

                        call relat_envia_mail("LOJ", m_path)

                when 100
                        error 'NENHUMA LOJA A SER LISTADO.'
                otherwise
                        error 'ERRO', sqlca.sqlcode, ' NENHUMA LOJA LISTADO.'
        end case

 end function

#################################################################################

#--------------------------------------#
 function bdbsr510_processa_relat_can() # PSI 239178
#--------------------------------------#

        define l_teste char(15)

     whenever error continue
        open crelat_37
        fetch crelat_37 into mr_relat.pstcndcod      ,
                             mr_relat.pestip         ,
                             mr_relat.cgccpfnum      ,
                             mr_relat.cgcord         ,
                             mr_relat.cgccpfdig      ,
                             mr_relat.pstcndnom      ,
                             mr_relat.rgenum         ,
                             mr_relat.rgeufdcod      ,
                             mr_relat.nscdat         ,
                             mr_relat.cnhnum         ,
                             mr_relat.cnhctgcod      ,
                             mr_relat.cnhpridat      ,
                             mr_relat.pstcndsitcod   ,
                             mr_relat.rdranlultdat   ,
                             mr_relat.caddat_can     ,
                             mr_relat.cademp         ,
                             mr_relat.cadmat         ,
                             mr_relat.atldat_can     ,
                             mr_relat.atlemp         ,
                             mr_relat.atlmat         ,
                             mr_relat.atlusrtip      ,
                             mr_relat.cadusrtip      ,
                             mr_relat.atlusrtip      ,
                             mr_relat.pstcndconcod   ,
                             mr_relat.srrcoddig


     whenever error stop

        case sqlca.sqlcode
                when 0
                        call bdbsr510_busca_path("CAN")

                        start report relat_can to m_path
                        start report relat_can_txt to m_path_txt

                            initialize mr_relat.* to null

                        foreach crelat_37 into mr_relat.pstcndcod      ,
                                               mr_relat.pestip         ,
                                               mr_relat.cgccpfnum      ,
                                               mr_relat.cgcord         ,
                                               mr_relat.cgccpfdig      ,
                                               mr_relat.pstcndnom      ,
                                               mr_relat.rgenum         ,
                                               mr_relat.rgeufdcod      ,
                                               mr_relat.nscdat         ,
                                               mr_relat.cnhnum         ,
                                               mr_relat.cnhctgcod      ,
                                               mr_relat.cnhpridat      ,
                                               mr_relat.pstcndsitcod   ,
                                               mr_relat.rdranlultdat   ,
                                               mr_relat.caddat_can     ,
                                               mr_relat.cademp         ,
                                               mr_relat.cadmat         ,
                                               mr_relat.atldat_can     ,
                                               mr_relat.atlemp         ,
                                               mr_relat.atlmat         ,
                                               mr_relat.atlusrtip      ,
                                               mr_relat.cadusrtip      ,
                                               mr_relat.atlusrtip      ,
                                               mr_relat.pstcndconcod   ,
                                               mr_relat.srrcoddig

                                output to report relat_can()
                                output to report relat_can_txt()

                        end foreach

                        finish report relat_can
                        finish report relat_can_txt

                        call relat_envia_mail("CAN", m_path)

                when 100
                        error 'NENHUM CANDIDATO A SER LISTADO.'
                otherwise
                        error 'ERRO', sqlca.sqlcode, ' NENHUM CANDIDATO LISTADO.'
        end case

 end function

#################################################################################

#----------------------------------------#
 function relat_envia_mail(l_tip, l_path)
#----------------------------------------#

        define  l_assunto     char(0100),
                l_erro_envio  integer,
                l_comando     char(0200),
                l_anexo       char(1000),
                l_tip         char(0003),
                l_path        char(1000)

        # ---> INICIALIZACAO DAS VARIAVEIS
        let l_comando    = null
        let l_erro_envio = null

        case l_tip
             when "PST"
                  let l_assunto = "Relatório de Prestadores Porto Seguro"
             when "SRR"
                  let l_assunto = "Relatório de Socorristas Ativos Porto Seguro"
             when "VCL"
                  let l_assunto = "Relatório de Veiculos Porto Seguro"
             when "LOJ"
                  let l_assunto = "Relatório de Lojas do Carro Extra Porto Seguro"
             when "CAN"
                  let l_assunto = "Relatório de Candidatos Porto Seguro"
             when "SR2"
                  let l_assunto = "Relatório de Socorristas Não Ativos Porto Seguro"
        end case

        # COMPACTA O ARQUIVO DO RELATORIO
        let l_comando = "gzip -f ", l_path
        run l_comando

        let l_path = l_path  clipped, ".gz "

        # ENVIA E-MAIL
        let l_erro_envio = ctx22g00_envia_email("BDBSR510", l_assunto, l_path)

        if  l_erro_envio <> 0 then
            if  l_erro_envio <> 99 then
                display "Erro ao enviar email(ctx22g00) - ", l_erro_envio
            else
                display "Nao existe email cadastrado para o modulo - BDBSR510"
            end if
        end if

 end function

#-----------------------------------#
 function bdbsr510_busca_path(l_tip)
#-----------------------------------#

     define l_tip      char(0003)
     define l_dataarq  char(8)
     define l_data     date

     let m_path = null 
       
     let l_data = today

     let l_dataarq = extend(l_data, year to year),
                     extend(l_data, month to month),
                     extend(l_data, day to day)

     let m_path = f_path("DBS","RELATO")

     if  m_path is null then
         let m_path = "."
     end if
     
     let m_path_txt = m_path

     # ---> Cria o primeiro relatorio (Todos os tributos)
     case l_tip
          when "PST"
               let m_path = m_path clipped, "/bdbsr510Temp_", l_dataarq, ".xls"
               let m_path_txt = m_path_txt clipped, "/bdbsr510Temp_", l_dataarq, ".txt"
          when "SRR"
               let m_path = m_path clipped, "/bdbsr5101Temp_", l_dataarq, ".xls"
               let m_path_txt = m_path_txt clipped, "/bdbsr5101Temp_", l_dataarq, ".txt"
          when "VCL"
               let m_path = m_path clipped, "/bdbsr5102Temp_", l_dataarq, ".xls"
               let m_path_txt = m_path_txt clipped, "/bdbsr5102Temp_", l_dataarq, ".txt"
          when "LOJ"
               let m_path = m_path clipped, "/bdbsr5103Temp_", l_dataarq, ".xls"
               let m_path_txt = m_path_txt clipped, "/bdbsr5103Temp_", l_dataarq, ".txt"
          when "CAN"
               let m_path = m_path clipped, "/bdbsr5104Temp_", l_dataarq, ".xls"
               let m_path_txt = m_path_txt clipped, "/bdbsr5104Temp_", l_dataarq, ".txt"
          when "SR2"
               let m_path = m_path clipped, "/bdbsr51012Temp_", l_dataarq, ".xls"
               let m_path_txt = m_path_txt clipped, "/bdbsr51012Temp_", l_dataarq, ".txt"
     end case

 end function
 
#################################################################################

#----------------------------------------#
 function bdbsr510_monta_descricao(seq)
#----------------------------------------#

define seq smallint

#-------------------------------------------------|
# VERIFICA SE EH A PRIMEIRA APOLICE DA VIATURA    |
#-------------------------------------------------|
if seq = 1 then
   
   #---------------------------------------|
   # VERIFICA SE EH APOLICE PORTO SEGURO   |
   #---------------------------------------| 
   if m_apolice.aplnumdig is not null then
      let m_apolice.apol_descricao = m_apolice.ramcod,' ',           
                                     m_apolice.succod,' ',           
                                     m_apolice.aplnumdig,'-',        
                                     m_apolice.itmnumdig,'; ',      
                                     m_apolice.sgdirbcod,#' / ',      
                                     #m_apolice.sgdnom clipped,
                                     '; ', 
                                     m_apolice.viginc,' a ',         
                                     m_apolice.vigfnl,'; ',
                                     m_apolice.cbtcscflg clipped,'; ',   
                                     m_apolice.cbtrcfflg clipped,'; ',  
                                     m_apolice.sgrimsdmvlr,'; ', 
                                     m_apolice.sgrimsdpvlr,'; ', 
                                     m_apolice.cbtrcffvrflg clipped 
   else
      #------------------------------|
      # APOLICE DE OUTRA COMPANHIA   |
      #------------------------------|
      let m_apolice.apol_descricao = m_apolice.sgraplnum,';',            
                                     m_apolice.sgdirbcod,#' / ',          
                                     #m_apolice.sgdnom clipped,
                                     '; ',      
                                     m_apolice.viginc,' a ',             
                                     m_apolice.vigfnl,'; ',              
                                     m_apolice.cbtcscflg clipped,'; ',   
                                     m_apolice.cbtrcfflg clipped,'; ',   
                                     m_apolice.sgrimsdmvlr,'; ',         
                                     m_apolice.sgrimsdpvlr,'; ',         
                                     m_apolice.cbtrcffvrflg clipped      
   end if 
#-------------------------------------------------|
# VERIFICA SE SAO AS DEMAIS APOLICE DA VIATURA    |
#-------------------------------------------------|   
else
   #---------------------------------------|
   # VERIFICA SE EH APOLICE PORTO SEGURO   |
   #---------------------------------------|
   if m_apolice.aplnumdig is not null then
      let m_apolice.apol_descricao = m_apolice.apol_descricao clipped,' -- ',
                                     m_apolice.ramcod,' ',           
                                     m_apolice.succod,' ',           
                                     m_apolice.aplnumdig,'-',        
                                     m_apolice.itmnumdig,'; ',      
                                     m_apolice.sgdirbcod,#' / ',      
                                     #m_apolice.sgdnom clipped,
                                     '; ', 
                                     m_apolice.viginc,' a ',         
                                     m_apolice.vigfnl,'; ',
                                     m_apolice.cbtcscflg clipped,'; ',   
                                     m_apolice.cbtrcfflg clipped,'; ',  
                                     m_apolice.sgrimsdmvlr,'; ', 
                                     m_apolice.sgrimsdpvlr,'; ', 
                                     m_apolice.cbtrcffvrflg clipped 
   else  
      #------------------------------|
      # APOLICE DE OUTRA COMPANHIA   |
      #------------------------------|
      let m_apolice.apol_descricao = m_apolice.apol_descricao clipped,' -- ',
                                     m_apolice.sgraplnum,';',            
                                     m_apolice.sgdirbcod,#' / ',          
                                     #m_apolice.sgdnom clipped,
                                     '; ',      
                                     m_apolice.viginc,' a ',             
                                     m_apolice.vigfnl,'; ',              
                                     m_apolice.cbtcscflg clipped,'; ',   
                                     m_apolice.cbtrcfflg clipped,'; ',   
                                     m_apolice.sgrimsdmvlr,'; ',         
                                     m_apolice.sgrimsdpvlr,'; ',         
                                     m_apolice.cbtrcffvrflg clipped      
   end if       
end if  
                    
end function
#################################################################################

#-----------------#
 report relat_pst()
#-----------------#

        define l_aux      	  char(0400),
               l_auxcpf   	  char(0100),
               l_auxpep   	  char(0100),               	
               l_hist     	  char(1000),
               l_grpntz   	  char(0500),
               l_ntz      	  char(0500),
               l_ass      	  char(1000),
               l_srv      	  char(1000),
               l_vig      	  char(1000),
               l_par      	  char(0100),
               l_emp      	  char(0100),
               l_crn      	  char(0100),
               l_primeiro 	  smallint,
               l_data     	  char(010),
               l_resp     	  char(1000),
               l_prtbnfprccod 	  like dparbnfprt.prtbnfprccod,
               l_descricao 	  char(1000),
               l_codbonificacao   smallint,
               l_desbonificacao   char(1000),
               l_respst_a 	  char(1000), 				# Administrador da prestadora            
               l_respst_c 	  char(1000), 				# Controlador da prestadora
               l_respst_p 	  char(1000), 				# Procurador da prestadora
               l_cpfresp  	  char(0100), 				# CPF Responsavel
               l_pepresp  	  char(0100), 				# PEP Responsavel
               l_anobrtoprrctvlr  like dpaksocor.anobrtoprrctvlr, 	# Codigo da receita bruta anual
               l_liqptrfxacod     like dpaksocor.liqptrfxacod,  	# Codigo do patrimonio liquido
               l_empcod           like dpaksocor.empcod,          	# Codigo da empresa Porto  
               l_cpodes_anobrtrct like iddkdominio.cpodes, 		# Descricao da receita bruta anual 
               l_liqptrfxaincvlr  like gsakliqptrfxa.liqptrfxaincvlr,	# Descricao inicial do patrimonio liq
	       l_liqptrfxafnlvlr  like gsakliqptrfxa.liqptrfxafnlvlr, 	# Descricao final do patrimonio liq  
	       l_resadm 	  char(1),				# Sigla do tipo de responsavel Administrador
	       l_rescon 	  char(1),				# Sigla do tipo de responsavel Controlador
	       l_respro 	  char(1), 				# Sigla do tipo de responsavel Procurador
	       l_renfxaincvlr     like gsakmenrenfxa.renfxaincvlr, 	# Valor inicial da faixa de renda mensal do pst pf
               l_renfxafnlvlr     like gsakmenrenfxa.renfxaincvlr, 	# Valor final da faixa de renda mensal do pst pf               
               l_pepindcod        like dpakctd.pepindcod,
               l_ctdnom		  like dpakctd.ctdnom,
               l_desend           like iddkdominio.cpodes
	
        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

        format

            first page header

                initialize l_aux,
                           l_hist,
                           l_grpntz,
                           l_ntz,
                           l_primeiro,
                           l_desend to null

                print "RELATORIO DE PRESTADORES."

                print ""

                print "CÓDIGO",                 ASCII(09),
                      "NOME GUERRA",            ASCII(09),
                      "RAZAO SOCIAL",           ASCII(09),
                      "SIT.",                   ASCII(09),
                      "TIP. PES.",              ASCII(09),
                      "CPF/CNPJ",               ASCII(09),
                      "INS. MUNICIPAL",         ASCII(09);

                      # PSI-2012-23608PR - TABELA DE FATURAMENTO – TRIBUTOS
                      
                      declare cq_endereco cursor for
                        select cpodes 
                          from iddkdominio 
                         where cponom = 'endtipcod'
                         order by cpocod

                      foreach cq_endereco into l_desend

                          print "TIPO LOGRADOURO "   ,l_desend clipped,       ASCII(09),
                                "NOME LOGRADOURO "   ,l_desend clipped,       ASCII(09),  
                                "NUMERO LOGRADOURO " ,l_desend clipped,       ASCII(09),  
                                "COMP. DO ENDERECO " ,l_desend clipped,       ASCII(09),  
                                "BAIRRO "            ,l_desend clipped,       ASCII(09),  
                                "CIDADE PST "        ,l_desend clipped,       ASCII(09),  
                                "UF PST "            ,l_desend clipped,       ASCII(09),  
                                "CEP "               ,l_desend clipped,       ASCII(09),  
                                "CEPCMP "            ,l_desend clipped,       ASCII(09);  

                      end foreach
                      
                      #"TIPO LOGRADOURO",        ASCII(09),
                      #"NOME LOGRADOURO",        ASCII(09),
                      #"NUMERO LOGRADOURO",      ASCII(09),
                      #"COMP. DO ENDERECO",      ASCII(09),
                      #"BAIRRO",                 ASCII(09),
                      #"CIDADE PST",             ASCII(09),
                      #"UF PST",                 ASCII(09),
                      #"CEP",                    ASCII(09),
                      #"CEPCMP",                 ASCII(09),

                print "DDD TEL",                ASCII(09),
                      "NR. TEL",                ASCII(09),
                      "FAX",                    ASCII(09),
                      "DDD CEL",                ASCII(09),
                      "NR. CEL",                ASCII(09),
                      "PROPRIETARIO",           ASCII(09),
                      "CONTATO",                ASCII(09),
                      "FAVORECIDO",             ASCII(09),
                      "TIP. PES. FAV.",         ASCII(09),
                      "CPF/CNPJ FAV.",          ASCII(09),
                      "TIP. CONTA",             ASCII(09),
                      "NR. BANCO",              ASCII(09),
                      "NR. AGEN.",              ASCII(09),
                      "DIG. AGEN.",             ASCII(09),
                      "NR. CONTA",              ASCII(09),
                      "DIG CONTA",              ASCII(09),
                      "FORMA DE PAG.",          ASCII(09),
                      "PATIO",                  ASCII(09),
                      "ATENDE 24H",             ASCII(09),
                      "QUALI. PREST.",          ASCII(09),
                      "TIP. COOPER.",           ASCII(09),
                      "USA TABELA",             ASCII(09),
                      "TAR PS",                 ASCII(09),
                      "TAR RE",                 ASCII(09),
                      #"OBS.",                   ASCII(09),
                      "ACI.",                   ASCII(09),
                      "RIS",                    ASCII(09),
                      #"HISTÓRICO",              ASCII(09),
                      "RE",                     ASCII(09),
                      "NATUREZA",               ASCII(09),
                      "PARAMETROS",             ASCII(09),
                      "ASSISTENCIA",            ASCII(09),
                      "SERVICOS",               ASCII(09),
                      "EMPRESA",                ASCII(09),
                      "CRONOGRAMA",             ASCII(09),
                      "E-MAIL",                 ASCII(09),
                      "RESPONSAVEL",            ASCII(09),
                      "BONIFICACAO",            ASCII(09),
                      "DT. INC.",               ASCII(09),
                      "DT. ATL.",               ASCII(09),
                      "ATIVIDADE PRINCIPAL",    ASCII(09),
                      "VIGENCIA DO CONTRATO",   ASCII(09),
                      "SUCURSAL",               ASCII(09),
                      "PIS"     ,               ASCII(09),
                      "OPTANTE SIMPLES",        ASCII(09),
                      "PRESTADOR PRINCIPAL",    ASCII(09),
                      "CADEIA DE GESTAO",       ASCII(09),
                      "ADMINISTRADOR(ES)",      ASCII(09),  
                      #"CPF",      		ASCII(09),
                      #"PEP",			ASCII(09),
                      "CONTROLADOR(ES)",        ASCII(09), 
                      #"CPF",      		ASCII(09),																																
                      #"PEP",			ASCII(09),																																
                      "PROCURADOR(ES)",         ASCII(09),
                      #"CPF",      		ASCII(09),
                      #"PEP",			ASCII(09),                      
                      "PF - FAIXA RENDA MENSAL",ASCII(09),
                      "PF - PEP",		ASCII(09),                     
                      "PJ - RECEITA BRUTA",     ASCII(09),
                      "PJ - PATRIMONIO LIQUIDO",ASCII(09),
		      "DATA",                   ASCII(09) #--> FX-080515

            on every row
                set isolation to dirty read
                #open crelat_02 using mr_relat.pstcoddig
                #fetch crelat_02 into l_aux
                #
                #case sqlca.sqlcode
                #       when 0
                #               let l_hist = " "
                #
                #               foreach crelat_02 into l_aux
                #                       let l_hist = l_hist clipped, " ", l_aux
                #               end foreach
                #       when 100
                #               let l_hist = ' '
                #       otherwise
                #               error 'ERRO BUSCA DE HISTORICO: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                #end case

                open crelat_03 using mr_relat.pstcoddig
                fetch crelat_03 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_grpntz = " "
                                let l_primeiro = true

                                foreach crelat_03 into l_aux
                                        if  l_primeiro then
                                                let l_grpntz = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_grpntz = l_grpntz clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_grpntz = ' '
                        otherwise
                                error 'ERRO BUSCA DE GRUPO NATUREZA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_41 using mr_relat.pstcoddig
                fetch crelat_41 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_ntz = " "
                                let l_primeiro = true

                                foreach crelat_41 into l_aux
                                        if  l_primeiro then
                                                let l_ntz = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_ntz = l_ntz clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_ntz = ' '
                        otherwise
                                error 'ERRO BUSCA DE NATUREZA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_04 using mr_relat.pstcoddig
                fetch crelat_04 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_par = " "
                                let l_primeiro = true

                                foreach crelat_04 into l_aux
                                        if  l_primeiro then
                                                let l_par = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_par = l_par clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_par = '  '
                        otherwise
                                error 'ERRO BUSCA DE PARAMETRO: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_05 using mr_relat.pstcoddig
                fetch crelat_05 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_ass = " "
                                let l_primeiro = true

                                foreach crelat_05 into l_aux
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

                open crelat_28 using mr_relat.pstcoddig
                fetch crelat_28 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_srv = " "
                                let l_primeiro = true

                                foreach crelat_28 into l_aux
                                        if  l_primeiro then
                                                let l_srv = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_srv = l_srv clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_srv = '  '
                        otherwise
                                error 'ERRO BUSCA DE ASSISTENCIA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_06 using mr_relat.pstcoddig
                fetch crelat_06 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_emp = " "
                                let l_primeiro = true

                                foreach crelat_06 into l_aux
                                        if  l_primeiro then
                                                let l_emp = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_emp = l_emp clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_emp = '  '
                        otherwise
                                error 'ERRO BUSCA DE EMPRESA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_07 using mr_relat.pstcoddig
                fetch crelat_07 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_crn = " "
                                let l_primeiro = true

                                foreach crelat_07 into l_aux
                                        if  l_primeiro then
                                                let l_crn = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_crn = l_crn clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_crn = '  '
                        otherwise
                                error 'ERRO BUSCA DE EMPRESA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                print  mr_relat.pstcoddig     clipped, ASCII(09);

                if  mr_relat.nomgrr is not null and  mr_relat.nomgrr <> " " then
                    print mr_relat.nomgrr        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.nomrazsoc is not null and  mr_relat.nomrazsoc <> " " then
                    print mr_relat.nomrazsoc        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.prssitcod is not null and  mr_relat.prssitcod <> " " then
                    print mr_relat.prssitcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pestip is not null and  mr_relat.pestip <> " " then
                    print mr_relat.pestip        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgcord is null or mr_relat.cgcord = " " then
                    let mr_relat.cgcord = 0
                end if

                if  mr_relat.cgccpfnum is not null and mr_relat.cgccpfnum <> ' ' then
                    if  mr_relat.pestip = 'F' then
                        print mr_relat.cgccpfnum  using '<<<<<<<<<<&'   clipped, '-',
                              mr_relat.cgccpfdig  using '<<<&&' clipped, ASCII(09);
                    else
                        print mr_relat.cgccpfnum   using '<<<<<<<<<<&'   clipped, '/',
                              mr_relat.cgcord      using '<<<<&&&&' clipped, '-',
                              mr_relat.cgccpfdig   using '<<<&&' clipped, ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if


                if  mr_relat.muninsnum is not null and  mr_relat.muninsnum <> " " then
                    print mr_relat.muninsnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                # PSI-2012-23608PR - TABELA DE FATURAMENTO – TRIBUTOS
                declare cq_enderecopst cursor for                   
                  select cpocod                                  
                    from iddkdominio                             
                   where cponom = 'endtipcod'                    
                   order by cpocod                               
                                                                 
                foreach cq_enderecopst into l_desend                
                
                    let mr_relat.endtiplgd = null
                    let mr_relat.endlgd    = null
                    let mr_relat.lgdnum    = null
                    let mr_relat.endcmp    = null
                    let mr_relat.endbrr    = null
                    let mr_relat.endcid    = null
                    let mr_relat.endufd    = null
                    let mr_relat.endcep    = null
                    let mr_relat.endcepcmp = null

                    whenever error continue
                      select lgdtip,         
                             endlgd,         
                             lgdnum,         
                             lgdcmp,         
                             endbrr,         
                             endcid,         
                             ufdsgl,         
                             endcep,         
                             endcepcmp       
                        into mr_relat.endtiplgd,
                             mr_relat.endlgd,
                             mr_relat.lgdnum,
                             mr_relat.endcmp,
                             mr_relat.endbrr,
                             mr_relat.endcid,
                             mr_relat.endufd,
                             mr_relat.endcep,
                             mr_relat.endcepcmp
                        from dpakpstend      
                       where pstcoddig = mr_relat.pstcoddig
                         and endtipcod = l_desend  
                    whenever error stop
                    
                    if  mr_relat.endtiplgd is not null and mr_relat.endtiplgd <> " " then
                        print mr_relat.endtiplgd        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.endlgd is not null and mr_relat.endlgd <> " " then
                        print mr_relat.endlgd        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.lgdnum is not null and mr_relat.lgdnum <> " " then
                        print mr_relat.lgdnum        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.endcmp is not null and mr_relat.endcmp <> " " then
                        print mr_relat.endcmp        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.endbrr is not null and  mr_relat.endbrr <> " " then
                        print mr_relat.endbrr        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.endcid is not null and mr_relat.endcid <> " " then
                        print mr_relat.endcid        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.endufd is not null and  mr_relat.endufd <> " " then
                        print mr_relat.endufd        clipped, ASCII(09);
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

                end foreach

                if  mr_relat.dddcod is not null and  mr_relat.dddcod <> " " then
                    print mr_relat.dddcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.teltxt is not null and  mr_relat.teltxt <> " " then
                    print mr_relat.teltxt        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.faxnum is not null and  mr_relat.faxnum <> " " then
                    print mr_relat.faxnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.celdddnum is not null and  mr_relat.celdddnum <> " " then
                    print mr_relat.celdddnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.celtelnum is not null and  mr_relat.celtelnum <> " " then
                    print mr_relat.celtelnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pptnom is not null and  mr_relat.pptnom <> " " then
                    print mr_relat.pptnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.rspnom is not null and  mr_relat.rspnom <> " " then
                    print mr_relat.rspnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.socfavnom is not null and  mr_relat.socfavnom <> " " then
                    print mr_relat.socfavnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pestip2 is not null and mr_relat.pestip2 <> " " then
                    print mr_relat.pestip2        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgcord2 is null or mr_relat.cgcord2 = " " then
                    let mr_relat.cgcord2 = 0
                end if

                if  mr_relat.cgccpfnum2 is not null and mr_relat.cgccpfnum2 <> ' ' then
                    if  mr_relat.pestip2 = 'F' then
                        print mr_relat.cgccpfnum2  using '<<<<<<<<<<&'   clipped, '-',
                              mr_relat.cgccpfdig2  using '<<<&&' clipped, ASCII(09);
                    else
                        print mr_relat.cgccpfnum2   using '<<<<<<<<<<&'   clipped, '/',
                              mr_relat.cgcord2      using '<<<<&&&&' clipped, '-',
                              mr_relat.cgccpfdig2   using '<<<&&' clipped, ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcoctatip is not null and  mr_relat.bcoctatip <> " " then
                    print mr_relat.bcoctatip        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcocod is not null and  mr_relat.bcocod <> " " then
                    print mr_relat.bcocod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcoagnnum is not null and  mr_relat.bcoagnnum <> " " then
                    print mr_relat.bcoagnnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcoagndig is not null and  mr_relat.bcoagndig <> " " then
                    print mr_relat.bcoagndig        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcoctanum is not null and  mr_relat.bcoctanum <> " " then
                    print mr_relat.bcoctanum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcoctadig is not null and  mr_relat.bcoctadig <> " " then
                    print mr_relat.bcoctadig        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.socpgtopccod2 is not null and  mr_relat.socpgtopccod2 <> " " then
                    print mr_relat.socpgtopccod2        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.patpprflg is not null and  mr_relat.patpprflg <> " " then
                    print mr_relat.patpprflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.srvnteflg is not null and  mr_relat.srvnteflg <> " " then
                    print mr_relat.srvnteflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.qldgracod is not null and  mr_relat.qldgracod <> " " then
                    print mr_relat.qldgracod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.prscootipcod is not null and  mr_relat.prscootipcod <> " " then
                    print mr_relat.prscootipcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.vlrtabflg is not null and  mr_relat.vlrtabflg <> " " then
                    print mr_relat.vlrtabflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.soctrfcod is not null and  mr_relat.soctrfcod <> " " then
                    print mr_relat.soctrfcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.rmesoctrfcod is not null and  mr_relat.rmesoctrfcod <> " " then
                    print mr_relat.rmesoctrfcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                 #if  mr_relat.pstobs is not null and  mr_relat.pstobs <> " " then
                 #    print mr_relat.pstobs        clipped, ASCII(09);
                 #else
                 #    print 'NAO CADASTRADO' , ASCII(09);
                 #end if

                if  mr_relat.intsrvrcbflg is not null and  mr_relat.intsrvrcbflg <> " " then
                    print mr_relat.intsrvrcbflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.risprcflg is not null and  mr_relat.risprcflg <> " " then
                    print mr_relat.risprcflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                #if  l_hist is not null and  l_hist <> " " then
                #    print l_hist        clipped, ASCII(09);
                #else
                #    print 'NAO CADASTRADO' , ASCII(09);
                #end if

                if  l_grpntz is not null and  l_grpntz <> " " then
                    print l_grpntz        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_ntz is not null and  l_ntz <> " " then
                    print l_ntz        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_par is not null and  l_par <> " " then
                    print l_par        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_ass is not null and  l_ass <> " " then
                    print l_ass        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_srv is not null and  l_srv <> " " then
                    print l_srv        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_emp is not null and  l_emp <> " " then
                    print l_emp        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_crn is not null and  l_crn <> " " then
                    print l_crn        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.maides is not null and  mr_relat.maides <> " " then
                    print mr_relat.maides        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                #Busca o responsavel - frtrpnflg
                open crelat_24 using mr_relat.frtrpnflg
                fetch crelat_24 into l_resp

                if  l_resp is not null and  l_resp <> " " then
                    print l_resp        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if
                let l_resp = null
               
                #-----------------------------------------------------|
                # VERIFICA SE EXISTE BINIFICACAO PARA O PRESTADOR     |
                #-----------------------------------------------------|
                  initialize l_descricao to null
                   
                  open crelat_46  using mr_relat.pstcoddig
                  foreach crelat_46 into l_codbonificacao
                     open crelat_47  using l_codbonificacao
                     fetch crelat_47 into l_desbonificacao
                        if l_descricao is not null then
                           let l_descricao = l_descricao clipped,"; ",l_codbonificacao,"-",l_desbonificacao clipped
                        else
                           let l_descricao = l_codbonificacao,"-",l_desbonificacao clipped
                        end if
                     close crelat_47
                     let l_desbonificacao = null
                  end foreach
                  if l_descricao is not null or l_descricao <> " " then
                     print l_descricao clipped, ASCII(09);
                  else 
                     print "NAO CADASTRADO", ASCII(09);
                  end if
                 # Fim do teste bonificação  


                let l_data = extend(mr_relat.cmtdat, year to year ),'-',
                             extend(mr_relat.cmtdat, month to month),'-',
                             extend(mr_relat.cmtdat, day to day)

                print l_data              clipped , ' ', ASCII(09);

                let l_data = extend(mr_relat.atldat, year to year ),'-',
                             extend(mr_relat.atldat, month to month),'-',
                             extend(mr_relat.atldat, day to day)

                print l_data              clipped , ' ', ASCII(09);

                if  mr_relat.pcpatvcod is not null and mr_relat.pcpatvcod > 0 then

                    # BUSCAR DESCRICAO DA ATIVIDADE PRINCIPAL
                    initialize m_dominio.* to null

                    call cty11g00_iddkdominio('pcpatvcod', mr_relat.pcpatvcod)
                        returning m_dominio.*

                    if m_dominio.erro = 1
                       then
                       let mr_relat.pcpatvdes = m_dominio.cpodes clipped
                    else
                       initialize mr_relat.pcpatvdes to null
                       display "Atividade principal: ", m_dominio.mensagem
                    end if

                    if  mr_relat.pcpatvdes is not null and mr_relat.pcpatvcod <> " " then
                        print mr_relat.pcpatvdes clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if

                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let l_vig = ""
                open  crelat_42  using mr_relat.pstcoddig
                foreach crelat_42 into mr_relat.cntvigincdat,
                                       mr_relat.cntvigfnldat
                    let l_vig = l_vig clipped, mr_relat.cntvigincdat, "-",
                                               mr_relat.cntvigfnldat, "; "
                end foreach

                if  l_vig is not null and l_vig <> " " then
                    print l_vig clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.succod is not null and
                   mr_relat.succod > 0
                   then
                   print mr_relat.succod, ASCII(09);
                else
                   print 'NAO CADASTRADO', ASCII(09);
                end if

                if mr_relat.pisnum is not null and
                   mr_relat.pisnum > 0
                   then
                   print mr_relat.pisnum, ASCII(09);
                else
                   print 'NAO CADASTRADO', ASCII(09);
                end if

                if mr_relat.simoptpstflg is not null
                   then
                   print mr_relat.simoptpstflg, ASCII(09);
                else
                   print 'NAO CADASTRADO', ASCII(09);
                end if
                
                # Codigo do prestador principal
                initialize l_descricao to null
                if mr_relat.pcpprscod is not null and mr_relat.pcpprscod <> 0
                   then
                    open  crelat_44  using mr_relat.pcpprscod
                    fetch crelat_44 into l_descricao
                   print l_descricao clipped, ASCII(09);
                else
                   print 'NAO CADASTRADO', ASCII(09);
                end if
                
                initialize l_descricao to null
                
                # Codigo da cadeia de gestao
                if mr_relat.gstcdicod is not null and mr_relat.gstcdicod <> 0 then  
                    open  crelat_45  using mr_relat.gstcdicod
                    fetch crelat_45 into l_descricao
                   print l_descricao clipped, ASCII(09);
                else
                   print 'NAO CADASTRADO', ASCII(09);
                end if                
                
                # Pegando os responsáveis pela prestadora                
                initialize l_aux    to null
                initialize l_auxcpf to null
                initialize l_auxpep to null                
                               
                let l_cpfresp = " "
                let l_pepresp = " " 
                let l_respst_a = " "
                let l_resadm = 'A'	# Administrador
                let l_rescon = 'C'	# Controlador
                let l_respro = 'P'	# Procurador
                let l_primeiro = true
                
                
                # Busca Administradores
                open  crelat_48  using mr_relat.pstcoddig ,l_resadm
                		  
                   foreach crelat_48 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if 
                      
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if                 
                   
                                
                initialize l_aux to null
                initialize l_auxcpf to null
                initialize l_auxpep to null                
                               
                let l_cpfresp = " "
                let l_pepresp = " "                 
                let l_respst_c = " "
                let l_primeiro = true
                
                # Busca pelos Controladores
                open  crelat_48  using mr_relat.pstcoddig,l_rescon
                   foreach crelat_48 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if             
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if
                
                
                initialize l_aux to null
                initialize l_auxcpf to null
                initialize l_auxpep to null                
                               
                let l_cpfresp = " "
                let l_pepresp = " "  
                let l_respst_p = " "                
                let l_primeiro = true
                
                #Busca pelos Procuradores
                open  crelat_48  using mr_relat.pstcoddig,l_respro
                   foreach crelat_48 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if                              
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if
               #Busca faixa de renda mensal, se for pessoa fisica
               
               if  mr_relat.pestip = 'F' then
	            	   whenever error continue                                        
		     	    select renfxaincvlr,          
                                   renfxafnlvlr
                              into l_renfxaincvlr,
                                   l_renfxafnlvlr          
                              from gsakmenrenfxa           
                            where empcod    = 1 
                             and renfxacod = mr_relat.renfxacod                         
                    	   whenever error stop                                        
                    	                                                                  
                    	   if sqlca.sqlcode <> 0 then                                     
	            	        print ' ' clipped, ASCII(09);                
	            	   else                                                           
	            	        case mr_relat.renfxacod
                                  when 1
                                     print 'SEM RENDA' clipped, ASCII(09); 
                                  when 2
		     	             print 'ATE 'clipped,l_renfxafnlvlr clipped, ASCII(09);                             	 	
                                  otherwise
                                     print 'DE 'clipped,l_renfxaincvlr clipped,' ATE 'clipped,l_renfxafnlvlr clipped, ASCII(09);
                             end case	
	            	   end if
	            	  else
	            	  print '' clipped, ASCII(09); 
	           end if 
               
               
               
               #Busca PEP se o prestador for pessoa física
               
               if mr_relat.pestip = 'F' then
               	 
               	 whenever error continue               	 
	             select a.pepindcod
		     into l_pepindcod
		     from dpakctd a,dparpstctd b
		     where a.ctdcod = b.ctdcod
		     and b.pstcoddig = mr_relat.pstcoddig   
		     
		     if status = notfound then 
		        print '' clipped, ASCII(09);
		     else
		     	print l_pepindcod clipped, ASCII(09);
		     end if               
                 whenever error stop
               else
               	 print '' clipped, ASCII(09);
               end if
               
               #Receita bruta 
	
	       if  mr_relat.pestip = 'J' then
	       	   let l_anobrtoprrctvlr = " "
	           whenever error continue
                       select anobrtoprrctvlr                         
                         into l_anobrtoprrctvlr                     	  
                         from dpaksocor 
                        where pstcoddig = mr_relat.pstcoddig
                   whenever error stop   
	       
               	   whenever error continue                                        
               	      select cpodes                                              
               	       	into l_cpodes_anobrtrct                                 
               	       	from iddkdominio                                        
               	       where cponom = 'anobrtoprrctvlr'                           
               	       	and cpocod = l_anobrtoprrctvlr                          
               	   whenever error stop                                        
               	                                                                  
               	   if sqlca.sqlcode <> 0 then                                     
	       	        print '' clipped, ASCII(09);                
	       	   else                                                           
	       	   	    print l_cpodes_anobrtrct clipped, ASCII(09);	
	       	   end if                                                         
	       else 
	       	   print '' clipped, ASCII(09); #--> FX-080515   
	       end if  	        
	        
                
               #Patrimonio liquido
   	       let l_liqptrfxacod = " "
               let l_empcod       = " "
               whenever error continue
                 select liqptrfxacod                   	  
                 into   l_liqptrfxacod                     	  
                 from   dpaksocor 
                 where  pstcoddig = mr_relat.pstcoddig
               whenever error stop   
                             
	       if l_liqptrfxacod is not null then 
               whenever error continue                                      
                   select liqptrfxaincvlr,
		          liqptrfxafnlvlr  
		   into   l_liqptrfxaincvlr
		   	 ,l_liqptrfxafnlvlr 
		   from   gsakliqptrfxa                               
		   where liqptrfxacod = l_liqptrfxacod
               whenever error stop           
               if sqlca.sqlcode <> 0 then
	            print '' clipped, ASCII(09);
	       else 
	            print 'DE 'clipped,l_liqptrfxaincvlr clipped,' ATE 'clipped,l_liqptrfxafnlvlr clipped, ASCII(09);
	       end if 
               
               else 
               print '' clipped, ASCII(09);
               
               end if
               
               print today,ASCII(09) #--> 080515
                
 end report     
                
#-----------------#
 report relat_srr()
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
               l_hst             char(9000),
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

                print "CÓDIGO",                 ASCII(09),
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
                      #,"HISTORICO",                 ASCII(09)
                      "DATA",                   ASCII(09) #--> FX-080515

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

                #--> PSI-21950 - Inicio
                if mr_relat.prssitcod = 2 then
                   let mr_relat.prssitdes = mr_relat.prssitdes clipped, "/",
                                            cty38g00_motivo(mr_relat.srrcoddig)
                end if
                #--> PSI-21950 - Final

                let l_aux = 'estcvlcod'
                open crelat_15 using l_aux,
                                     mr_relat.estcvlcod
                fetch crelat_15 into mr_relat.estcvldes

                let l_aux = 'srrtip'
                open crelat_15 using l_aux,
                                     mr_relat.srrtip
                fetch crelat_15 into mr_relat.srrtipdes

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

                let l_hst = " "
                { open crelat_26 using mr_relat.srrcoddig
                 fetch crelat_26 into l_aux

                 case sqlca.sqlcode
                        when 0
                                let l_hst = " "
                                let l_primeiro = true

                                foreach crelat_26 into l_aux
                                        if  l_primeiro then
                                                let l_hst = l_aux
                                                let l_primeiro = false
                                                let l_count = 1
                                        else
                                                let l_hst = l_hst clipped,  "; ",  l_aux
                                                let l_count = l_count + 1
                                        end if

                                        if l_count >= 50 then
                                                exit foreach
                                        end if
                                end foreach
                        when 100
                                let l_ass = '  '
                        otherwise
                                error 'ERRO BUSCA DO HISTORICO: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                 end case

                 if  l_hst is not null and l_hst <> " " then
                 print l_hst        clipped, ASCII(09);
                 else
                     print 'NAO CADASTRADO' , ASCII(09);
                 end if}

                 # APENAS VERIFICA SERVICO DE CPF VALIDO
                 if mr_relat.cgccpfnum is null then
                       let l_socvidseg = 'NAO'
                       print  l_socvidseg       clipped, ASCII(09);
                 else
                    initialize mrv_bdbsr510Vida.* to null
                    call ovgea017(0,
                                  0,
                                  mr_relat.cgccpfnum,
                                  0,
                                  mr_relat.cgccpfdig,
                                  6)
                        returning mrv_bdbsr510Vida.critica1,
                                  mrv_bdbsr510Vida.critica2,
                                  mrv_bdbsr510Vida.critica3,
                                  mrv_bdbsr510Vida.critica4,
                                  mrv_bdbsr510Vida.critica5,
                                  mrv_bdbsr510Vida.critica6,
                                  mrv_bdbsr510Vida.critica7

                    if mrv_bdbsr510Vida.critica1 is null and
                       mrv_bdbsr510Vida.critica2 is null and
                       mrv_bdbsr510Vida.critica3 is null and
                       mrv_bdbsr510Vida.critica4 is null and
                       mrv_bdbsr510Vida.critica5 is null and
                       mrv_bdbsr510Vida.critica6 is null and
                       mrv_bdbsr510Vida.critica7 is null then
                       let l_socvidseg = 'NAO'
                       print  l_socvidseg       clipped, ASCII(09);
                    else
                       let l_socvidseg = 'SIM'
                       print  l_socvidseg       clipped, ASCII(09);
                    end if
                 end if

                ## call fvdgc308(mr_relat.cgccpfnum,mr_relat.cgccpfdig,current)
                ##                     returning l_fvdgc308.coderro,
                ##                               l_fvdgc308.msgerro,
                ##                               l_fvdgc308.valorbas,
                ##                               l_fvdgc308.valoripd,
                ##                               l_fvdgc308.valoripa,
                ##                               l_fvdgc308.valormap
                ##if(l_fvdgc308.coderro == 4) then
                ##        let l_fvdgc308.socvidseg = "NAO"
                ##        print  l_fvdgc308.socvidseg        clipped, ASCII(09)
                ##else
                ##        let l_fvdgc308.socvidseg = "SIM"
                ##        print  l_fvdgc308.socvidseg        clipped, ASCII(09)
                ##end if
                #print l_hst        clipped, ASCII(09);

                print today,ASCII(09) #--> 080515

 end report

#-----------------#
 report relat_vcl()
#-----------------#

        define l_teste           char(0100),
               l_equip           char(1000),
               l_ass             char(1000),
               l_emp             char(1000),
               l_aux             char(0100),
               l_aux2            char(0100),
               l_equipdes        char(0100),
               l_equips          char(1000),
               l_primeiro        smallint,
               l_data            char(010),
               l_resp            char(1000),
               l_simcard         char(1000),
               l_recsinflg       like datkcdssim.recsinflg,
               l_cdssimintcod    like datkcdssim.cdssimintcod,
               l_celoprcod       like datkcdssim.celoprcod,
               l_sinoprdes       char(30),
               l_sinflg          char(20),
               l_vclcadorgdes    char(100) 

	define l_viavidseg  char(1) # Saber se tem ou nao seguro da viatura 
	
	define l_ret  record                                                   
       		coderro     integer,  ## Codigo erro retorno / 0=Ok <>0=Error   
       		msgerro     char(50), ## Mensagem erro retorno                  
       		qualificado char(01),  ## Sim ou Nao                            
       		socvcltip   like datkveiculo.socvcltip                          
	end record                                                             

	
	
        
        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

        format

            first page header

                print "RELATORIO DE VIATURA."

                print ""

                print "CÓDIGO"               clipped, ASCII(09),
                      "NOME DE GUERRA"       clipped, ASCII(09),
                      "TIP. PESSOA"          clipped, ASCII(09),
                      "CPF/CGC"              clipped, ASCII(09),
                      "PROPRIETARIO"         clipped, ASCII(09),
                      "DDD PREST."           clipped, ASCII(09),
                      "FONE PREST."          clipped, ASCII(09),
                      "E-MAIL PREST."        clipped, ASCII(09),
                      "SITUACAO PREST."      clipped, ASCII(09),
                      "DT. CAD. PREST."      clipped, ASCII(09),
                      "DT. ALT. PREST."      clipped, ASCII(09),
                      "CODIGO VEICULO"       clipped, ASCII(09),
                      "SIGLA"                clipped, ASCII(09),
                      #"VEICULO ANO"          clipped, ASCII(09),
                      "ANO MODELO"           clipped, ASCII(09),
                      "SITUACAO"             clipped, ASCII(09),
                      "PLACA"                clipped, ASCII(09),
                      "VEICULO ANO"          clipped, ASCII(09),
                      #"ANO MODELO"           clipped, ASCII(09),
                      "MDT"                  clipped, ASCII(09),
                      "MODELO MDT"           clipped, ASCII(09),
                      "PAGER/TELETRIM"       clipped, ASCII(09),
                      "DAT. CADASTRO"        clipped, ASCII(09),
                      "ALT. DATA"            clipped, ASCII(09),
                      "CIDADE"               clipped, ASCII(09),
                      "ESTADO"               clipped, ASCII(09),
                      "GRUP. DE DISTR."      clipped, ASCII(09),
                      "DDD CELULAR"          clipped, ASCII(09),
                      "NR. CELULAR"          clipped, ASCII(09),
                      "DDD NEXTEL"           clipped, ASCII(09),
                      "ID NEXTEL"            clipped, ASCII(09),
                      "NÚMERO NEXTEL"        clipped, ASCII(09),
                      "TIPO DE AQUISIÇÃO"    clipped, ASCII(09),
                      "NOME DA AQUISIÇÃO"    clipped, ASCII(09),
                      "TIP. EQUIPAMENTO"     clipped, ASCII(09),
                      "COD. VEICULO"         clipped, ASCII(09),
                      "NOM. VEICULO"         clipped, ASCII(09),
                      "CHASSI"               clipped, ASCII(09),
                      "COR"                  clipped, ASCII(09),
                      "TIP. PINTURA"         clipped, ASCII(09),
                      "TIP. COMBUSTIVEL"     clipped, ASCII(09),
                      "PER.VISTORIA"         clipped, ASCII(09),
                      "LOCAL VISTORIA"       clipped, ASCII(09),
                      "TIPO DE LAUDO"        clipped, ASCII(09),
                      "CONTROLE"             clipped, ASCII(09),
                      "CONTROLADORA"         clipped, ASCII(09),
                      "EQUIPAMENTO"          clipped, ASCII(09),
                      "BACKLIGHT"            clipped, ASCII(09),
                      "DISPLAY"              clipped, ASCII(09),
                      "ASSISTENCIA"          clipped, ASCII(09),
                      "EMPRESA"              clipped, ASCII(09),
                      "RESPONSAVEL"          clipped, ASCII(09),
                      "SIMCARD"              clipped, ASCII(09),
                      "RENAVAM"              clipped, ASCII(09),
                      "ORIGEM DO CADASTRO"   clipped, ASCII(09),
                      "APOLICE DE SEGURO"    clipped, ASCII(09),
                      "SEGURO PORTO" 	     clipped, ASCII(09),
                      "DATA"         	     clipped, ASCII(09) #--> FX-080515
                      

            on every row

                let mr_relat.vclcordes    = ""
                let mr_relat.vclpntdes    = ""
                let mr_relat.vclcmbdes    = ""
                let mr_relat.vclaqstipdes = ""
                let mr_relat.socoprsitdes = ""

                let l_equips = ""
                open crelat_17 using mr_relat.socvclcod
                fetch crelat_17 into l_equips

               case sqlca.sqlcode
                when 0
                        let l_equips = ""
                        let l_equipdes = ""

                        let l_primeiro = true

                        foreach crelat_17 into l_equipdes

                                if  l_primeiro then
                                        let l_equips = l_equipdes
                                        let l_primeiro = false
                                else
                                        let l_equips = l_equips clipped,  "; ",  l_equipdes
                                end if
                        end foreach
                when 100
                        let l_equips = ''
                otherwise
                        error 'ERRO BUSCA DE EQUIPAMENTO: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
               end case

                open crelat_21 using mr_relat.socvclcod
                fetch crelat_21 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_ass = ""
                                let l_primeiro = true

                                foreach crelat_21 into l_aux
                                        if  l_primeiro then
                                                let l_ass = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_ass = l_ass clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_ass = ' '
                        otherwise
                                error 'ERRO BUSCA DE ASSISTENCIA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_14 using mr_relat.socvclcod
                fetch crelat_14 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_emp = " "
                                let l_primeiro = true

                                foreach crelat_14 into l_aux2
                                        if  l_primeiro then
                                                let l_emp = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_emp = l_emp clipped,  "; ",  l_aux2 clipped
                                        end if
                                end foreach
                        when 100
                                let l_emp = ' '
                        otherwise
                                error 'ERRO BUSCA DE EMPRESA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                let mr_relat.vclcordes = null
                let l_aux = 'vclcorcod'
                open crelat_15 using l_aux,
                                     mr_relat.vclcorcod
                fetch crelat_15 into mr_relat.vclcordes

                if mr_relat.vclcordes is null or
                    mr_relat.vclcordes = " " then
                    let mr_relat.vclcordes = 'NAO CADASTRADA'
                end if

                let mr_relat.vclpntdes = null
                let l_aux = 'vclpnttip'
                open crelat_15 using l_aux,
                                     mr_relat.vclpnttip
                fetch crelat_15 into mr_relat.vclpntdes

                if  mr_relat.vclpntdes is null or
                    mr_relat.vclpntdes = " " then
                    let mr_relat.vclpntdes = 'NAO CADASTRADA'
                end if

                let mr_relat.vclcmbdes = null
                let l_aux = 'vclcmbcod'
                open crelat_15 using l_aux,
                                     mr_relat.vclcmbcod
                fetch crelat_15 into mr_relat.vclcmbdes

                if  mr_relat.vclcordes is null or
                    mr_relat.vclcordes = " " then
                    let mr_relat.vclcordes = 'NAO CADASTRADA'
                end if

                let mr_relat.vcldtbgrpdes = null
                open crelat_16 using mr_relat.socvclcod
                fetch crelat_16 into mr_relat.vcldtbgrpdes

                let mr_relat.vclaqstipdes = null
                let l_aux = 'vclaqstipcod'
                open crelat_15 using l_aux,
                                     mr_relat.vclaqstipcod
                fetch crelat_15 into mr_relat.vclaqstipdes

                let mr_relat.mdtcfgcod = null
                let mr_relat.mdtdes = null

                open crelat_27 using mr_relat.mdtcod
                fetch crelat_27 into mr_relat.mdtcfgcod

                let l_aux = 'eqttipcod'
                open crelat_15 using l_aux,
                                     mr_relat.mdtcfgcod
                fetch crelat_15 into mr_relat.mdtdes
                #INICIO#

                print mr_relat.pstcoddig clipped, ' ', ASCII(09);

                if  mr_relat.nomgrr is not null and mr_relat.nomgrr <> " " then
                    print mr_relat.nomgrr        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pestip is not null and mr_relat.pestip <> " " then
                    print mr_relat.pestip        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgccpfnum is not null and mr_relat.cgccpfnum <> ' ' then
                    if  mr_relat.pestip = 'F' then
                        print mr_relat.cgccpfnum  using '<<<<<<<<<<&'   clipped, '-',
                              mr_relat.cgccpfdig  using '<<<&&' clipped, ASCII(09);
                    else
                        print mr_relat.cgccpfnum   using '<<<<<<<<<<&'   clipped, '/',
                              mr_relat.cgcord      using '<<<<&&&&' clipped, '-',
                              mr_relat.cgccpfdig   using '<<<&&' clipped, ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pptnom is not null and mr_relat.pptnom <> " " then
                    print mr_relat.pptnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if  mr_relat.dddcod is not null and mr_relat.dddcod <> " " then
                    print mr_relat.dddcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if  mr_relat.teltxt is not null and mr_relat.teltxt <> " " then
                    print mr_relat.teltxt        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.maides is not null and mr_relat.maides <> " " then
                    print mr_relat.maides        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                case mr_relat.prssitcod
                     when "A"
                          let mr_relat.prsitdes = "ATIVO"
                     when "B"
                          let mr_relat.prsitdes = "BLOQUEADO"
                     when "C"
                          let mr_relat.prsitdes = "CANCELADO"
                     when "P"
                          let mr_relat.prsitdes = "PROPOSTA"
                     otherwise
                          let mr_relat.prsitdes = "NAO CADASTRADO"
                end case

                print mr_relat.prssitcod clipped  , ' - ',
                      mr_relat.prsitdes clipped, ' ', ASCII(09);

                let l_data = extend(mr_relat.cmtdat, year to year ),'-',
                             extend(mr_relat.cmtdat, month to month),'-',
                             extend(mr_relat.cmtdat, day to day)

                print l_data              clipped , ' ', ASCII(09);

                let l_data = extend(mr_relat.atldat, year to year ),'-',
                             extend(mr_relat.atldat, month to month),'-',
                             extend(mr_relat.atldat, day to day)

                print l_data              clipped , ' ', ASCII(09);

                print   mr_relat.socvclcod    clipped, ' ', ASCII(09);

                if  mr_relat.atdvclsgl is not null and mr_relat.atdvclsgl <> " " then
                    print  mr_relat.atdvclsgl   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.vclanomdl is not null and mr_relat.vclanomdl <> " " then
                     print upshift(mr_relat.vclanomdl)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let mr_relat.socoprsitdes = null
                let l_aux = 'socoprsitcod'
                open crelat_15 using l_aux,
                                     mr_relat.socoprsitcod
                fetch crelat_15 into mr_relat.socoprsitdes

                if mr_relat.socoprsitdes is not null and mr_relat.socoprsitdes <> " " then
                     print upshift(mr_relat.socoprsitdes)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if




                if mr_relat.vcllicnum is not null and mr_relat.vcllicnum <> " " then
                     print upshift(mr_relat.vcllicnum)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if


                if mr_relat.vclanofbc is not null and mr_relat.vclanofbc <> " " then
                     print upshift(mr_relat.vclanofbc)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.mdtcod is not null and mr_relat.mdtcod <> " " then
                     print upshift(mr_relat.mdtcod)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.mdtdes is not null and mr_relat.mdtdes <> " " then
                     print upshift(mr_relat.mdtcfgcod), ' - ' ,upshift(mr_relat.mdtdes)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.pgrnum is not null and mr_relat.pgrnum <> " " then
                     print upshift(mr_relat.pgrnum)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let l_data = extend(mr_relat.caddat, year to year ),'-',
                             extend(mr_relat.caddat, month to month),'-',
                             extend(mr_relat.caddat, day to day)

                print l_data              clipped , ' ', ASCII(09);

                let l_data = extend(mr_relat.atldat2, year to year ),'-',
                             extend(mr_relat.atldat2, month to month),'-',
                             extend(mr_relat.atldat2, day to day)

                print l_data              clipped , ' ', ASCII(09);

                if mr_relat.endcid is not null and mr_relat.endcid <> " " then
                     print upshift(mr_relat.endcid)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.endufd is not null and mr_relat.endufd <> " " then
                     print upshift(mr_relat.endufd)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.vcldtbgrpdes is not null and mr_relat.vcldtbgrpdes <> " " then
                    print  mr_relat.vcldtbgrpdes  clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if mr_relat.celdddcod is not null and mr_relat.celdddcod <> " " then
                     print upshift(mr_relat.celdddcod)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if mr_relat.celtelnum is not null and mr_relat.celtelnum <> " " then
                     print upshift(mr_relat.celtelnum)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.nxtdddcod is not null and mr_relat.nxtdddcod <> " " then
                     print upshift(mr_relat.nxtdddcod)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.nxtide is not null and mr_relat.nxtide <> " " then
                     print upshift(mr_relat.nxtide)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.nxtnum is not null and mr_relat.nxtnum <> " " then
                     print upshift(mr_relat.nxtnum)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                #if  mr_relat.vclctfnom is not null and mr_relat.vclctfnom <> " " then
                #    print mr_relat.vclctfnom        clipped, ASCII(09);
                #else
                #    print 'NAO CADASTRADO' , ASCII(09);
                #end if

                if  mr_relat.vclaqstipdes is not null and mr_relat.vclaqstipdes <> " " then
                    print mr_relat.vclaqstipcod, " - ", mr_relat.vclaqstipdes clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.vclaqsnom is not null and mr_relat.vclaqsnom <> " " then
                    print mr_relat.vclaqsnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let mr_relat.eqpdes = ""
                let l_aux = 'socvcltip'
                open crelat_15 using l_aux,
                                     mr_relat.eqptip
                fetch crelat_15 into mr_relat.eqpdes

                if  mr_relat.eqpdes is not null and mr_relat.eqpdes <> " " then
                    print mr_relat.eqptip clipped," - ", mr_relat.eqpdes clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                call cts15g00(mr_relat.vclcoddig)
                     returning mr_relat.vcldes

                if  mr_relat.vclcoddig is not null and mr_relat.vclcoddig <> " " then
                    print mr_relat.vclcoddig        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print mr_relat.vcldes    clipped, ' ', ASCII(09);

                if  mr_relat.vclchs is not null and mr_relat.vclchs <> " " then
                    print mr_relat.vclchs        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.vclcordes is not null and mr_relat.vclcordes <> " " then
                     print upshift(mr_relat.vclcordes)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.vclpntdes is not null and mr_relat.vclpntdes <> " " then
                    print  upshift(mr_relat.vclpntdes)   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.vclcmbdes is not null and mr_relat.vclcmbdes <> " " then
                    print  upshift(mr_relat.vclcmbdes)   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.socvstdiaqtd is not null and mr_relat.socvstdiaqtd <> " " then
                    print  mr_relat.socvstdiaqtd   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let mr_relat.socvstlcldes = null
                open crelat_18 using mr_relat.socvstlclcod
                fetch crelat_18 into mr_relat.socvstlcldes

                if  mr_relat.socvstlcldes is not null and mr_relat.socvstlcldes <> " " then
                    print  mr_relat.socvstlcldes   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.socvstlautipcod is not null and mr_relat.socvstlautipcod <> " " then
                    print  mr_relat.socvstlautipcod   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.socctrposflg is not null and mr_relat.socctrposflg <> " " then
                    print  mr_relat.socctrposflg   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                #if  mr_relat.pstobs is not null and  mr_relat.pstobs <> " " then
                #    print mr_relat.pstobs        clipped, ASCII(09);
                #else
                #    print 'NAO CADASTRADO' , ASCII(09);
                #end if

                let mr_relat.mdtctrcod  = null
                open crelat_20 using mr_relat.mdtcod
                fetch crelat_20 into mr_relat.mdtctrcod

                if  mr_relat.mdtctrcod is not null and mr_relat.mdtctrcod <> " " then
                    print  mr_relat.mdtctrcod   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_equips is not null and l_equips <> " " then
                    print  l_equips   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bckcod is not null and mr_relat.bckcod <> " " then

                    open crelat_22 using mr_relat.bckcod
                    fetch crelat_22 into mr_relat.bckdes

                    if  sqlca.sqlcode = 0 then
                        print mr_relat.bckdes , ASCII(09);
                    else
                        print 'BACKLIGHT INVALIDO' , ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.dpycod is not null and mr_relat.dpycod <> " " then

                    open crelat_23 using mr_relat.dpycod
                    fetch crelat_23 into mr_relat.dpydes

                    if  sqlca.sqlcode = 0 then
                        print mr_relat.dpydes , ASCII(09);
                    else
                        print 'DISPLAY INVALIDO' , ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if


                if  l_ass is not null and l_ass <> " " then
                    print  l_ass  clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_emp is not null and l_emp <> " " then
                    print  l_emp   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                #Busca o responsavel - frtrpnflg
                #open crelat_25 using mr_relat.pstcoddig
                #fetch crelat_25 into mr_relat.frtrpnflg

                let l_resp = null
                open crelat_24 using mr_relat.frtrpnflg
                fetch crelat_24 into l_resp

                if  l_resp is not null and  l_resp <> " " then
                    print l_resp        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                # Busca simcard
                let l_simcard = " "
                let l_primeiro = true
                open crelat_35 using mr_relat.mdtcod
                foreach crelat_35 into l_recsinflg,
                                       l_cdssimintcod,
                                       l_celoprcod

                   let l_sinflg = ""
                   let l_aux = "RECSINFLG"
                   open crelat_15 using l_aux,
                                        l_recsinflg
                   fetch crelat_15 into l_sinflg

                   let l_sinoprdes = ""
                   open crelat_36 using l_celoprcod
                   fetch crelat_36 into l_sinoprdes

                   if  l_primeiro then
                        let l_simcard = l_cdssimintcod clipped, "|", l_sinoprdes clipped, "|", l_sinflg
                        let l_primeiro = false
                   else
                        let l_simcard = l_simcard clipped,  ";",  l_cdssimintcod clipped, "|", l_sinoprdes clipped, "|", l_sinflg
                   end if
                end foreach
                if  l_simcard is not null and  l_simcard <> " " then
                    print l_simcard        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if
                
                
                # Renavam
                if  mr_relat.rencod  is not null and  mr_relat.rencod  <> " " then
                    print mr_relat.rencod   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if
                
                # Origem do cadastro da viatura
                if  mr_relat.vclcadorgcod   is not null and  mr_relat.vclcadorgcod <> 0 then
                   let l_vclcadorgdes = 'ctc34m03_orgcadvcl'
                   open crelat_15 using l_vclcadorgdes,
                                        mr_relat.vclcadorgcod 
                   fetch crelat_15 into l_vclcadorgdes
                   
                   let l_vclcadorgdes = mr_relat.vclcadorgcod clipped," - ", l_vclcadorgdes clipped
                    print l_vclcadorgdes clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if 
                
                # descricao da apolice de seguro do veiculo
                if  m_apolice.apol_descricao  is not null and  m_apolice.apol_descricao  <> " " then
 		    let l_viavidseg = 'SIM'               
                    print l_viavidseg   clipped  ;
                else
                    let l_viavidseg = 'NAO'
                    print l_viavidseg ;
                end if
		print ASCII(09);
		
		call ctb00g08_qualifvcl("", mr_relat.socvclcod, "", "", today, today)
		returning l_ret.coderro,    
			  l_ret.msgerro,   
			  l_ret.qualificado,
			  l_ret.socvcltip
			  
                print l_ret.qualificado, ASCII(09); #--> FX-080515
                 
		print today #--> FX-080515

end report

#-----------------#
 report relat_loj()
#-----------------#
        define l_teste        char(0100),
               l_equip        char(1000),
               l_ass          char(1000),
               l_emp          char(1000),
               l_aux          char(0300),
               l_auxemp       char(0300),
               l_auxcpf       char(0300),
               l_auxpep       char(0100), 
               l_equipdes     char(0100),
               l_equips       char(1000),
               l_primeiro     smallint,
               l_data         char(010),
               l_resp         char(1000),
               l_clausula     char(1000),
               l_cidtx        char(1000),
               l_ciaempcod    smallint,
               l_cep_loj      char(09),
               l_sucursal     char(0100),
               l_mensagem     char (60),
               l_resultado    smallint,
               l_respst_a char(1000), # Administrador da prestadora            
               l_respst_c char(1000), # Controlador da prestadora
               l_respst_p char(1000), # Procurador da prestadora
               l_cpfresp  char(0100), # CPF Responsavel   
               l_pepresp  char(0100), # PEP Responsavel                  
               l_anobrtoprrctvlr like dpaksocor.anobrtoprrctvlr, #Codigo da receita bruta anual
               l_liqptrfxacod    like dpaksocor.liqptrfxacod,  #Codigo do patrimonio liquido
               l_empcod          like dpaksocor.empcod,          #Codigo da empresa Porto  
               l_cpodes_anobrtrct like iddkdominio.cpodes, #Descricao da receita bruta anual 
               l_liqptrfxaincvlr  like gsakliqptrfxa.liqptrfxaincvlr,#Descricao inicial do patrimonio liq
	       l_liqptrfxafnlvlr  like gsakliqptrfxa.liqptrfxafnlvlr, #Descricao final do patrimonio liq  
	       l_resadm char(1),#Sigla do tipo de responsavel Administrador
	       l_rescon char(1),#Sigla do tipo de responsavel Controlador
	       l_respro char(1), #Sigla do tipo de responsavel Procurador
	       l_ctdnom like dpakctd.ctdnom

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

        format

            first page header

                print "RELATORIO DE LOJAS DO CARRO EXTRA"

                print ""

                print "CODIGO DA LOCADORA"                    clipped, ASCII(09),
                      "NOME DA LOCADORA"                      clipped, ASCII(09),
                      "LOGRADOURO"                            clipped, ASCII(09),
                      "BAIRRO"                                clipped, ASCII(09),
                      "CIDADE"                                clipped, ASCII(09),
                      "UF"                                    clipped, ASCII(09),
                      "DDD"                                   clipped, ASCII(09),
                      "TELEFONE"                              clipped, ASCII(09),
                      "FAX"                                   clipped, ASCII(09),
                      "TX SEGURO"                             clipped, ASCII(09),
                      "TX 2.º CONDUTOR"                       clipped, ASCII(09),
                      "CNPJ LOCADORA"                         clipped, ASCII(09),
                      "RECEBER FAX"                           clipped, ASCII(09),
                      "SITUACAO"                              clipped, ASCII(09),
                      "TIPO ACIONAMENTO"                      clipped, ASCII(09),
                      "EMAIL"                                 clipped, ASCII(09),
                      "DATA CADASTRO"                         clipped, ASCII(09),
                      "DATA ATUALIZACAO"                      clipped, ASCII(09),
                      "CODIGO DA LOJA"                        clipped, ASCII(09),
                      "SIGLA"                                 clipped, ASCII(09),
                      "NOME DA LOJA"                          clipped, ASCII(09),
                      "TIPO"                                  clipped, ASCII(09),
                      "DESCRICAO TIPO"                        clipped, ASCII(09),
                      "QUALIDADE"                             clipped, ASCII(09),
                      "LOGRADOURO"                            clipped, ASCII(09),
                      "BAIRRO"                                clipped, ASCII(09),
                      "CIDADE"                                clipped, ASCII(09),
                      "UF"                                    clipped, ASCII(09),
                      "CEP"                                   clipped, ASCII(09),
                      "PONTO DE REFERENCIA"                   clipped, ASCII(09),
                      "SUCURSAL NUMERO"                       clipped, ASCII(09),
                      "SUCURSAL NOME"                         clipped, ASCII(09),
                      "DDD"                                   clipped, ASCII(09),
                      "TELEFONE"                              clipped, ASCII(09),
                      "FAX"                                   clipped, ASCII(09),
                      "HORARIO DE 2.ª A 6.ª INICIO"           clipped, ASCII(09),
                      "HORARIO DE 2.ª A 6.ª FINAL"            clipped, ASCII(09),
                      "HORARIO DE SABADO INICIO"              clipped, ASCII(09),
                      "HORARIO DE SABADO FINAL"               clipped, ASCII(09),
                      "HORARIO DE DOMINGO INICIO"             clipped, ASCII(09),
                      "HORARIO DE DOMINGO FINAL"              clipped, ASCII(09),
                      "TARIFA"                                clipped, ASCII(09),
                      "SITUACAO"                              clipped, ASCII(09),
                      "CHEQUE CAUCAO"                         clipped, ASCII(09),
                      "TX AERO.PORT"                          clipped, ASCII(09),
                      "EMAIL"                                 clipped, ASCII(09),
                      "OBSERVACAO"                            clipped, ASCII(09),
                      "CLAUSULAS"                             clipped, ASCII(09),
                      "CIDADES-TAXAS EM QUE A LOJA ENTREGA"   clipped, ASCII(09),
		      "ADMINISTRADOR(ES)" 		      clipped, ASCII(09),    
		      #"CPF"      			      clipped, ASCII(09),      
		      #"PEP"				      clipped, ASCII(09),      
		      "CONTROLADOR(ES)"        	              clipped, ASCII(09),    
		      #"CPF"      			      clipped, ASCII(09),	
		      #"PEP"				      clipped, ASCII(09),	
		      "PROCURADOR(ES)"         	              clipped, ASCII(09),    
		      #"CPF"      			      clipped, ASCII(09),      
		      #"PEP"				      clipped, ASCII(09),      
		      "PJ - RECEITA BRUTA"     	              clipped, ASCII(09),    
		      "PJ - PATRIMONIO LIQUIDO"	              clipped, ASCII(09),
		      "EMPRESAS RELACIONADAS"                 clipped, ASCII(09),
		      "DATA" #--> FX-080515
                                                       
            on every row                   
                                           
                set isolation to dirty read
                case mr_relat.lcvresenvcod
                   when 1 let mr_relat.envdsc = "Central Reservas"
                   when 2 let mr_relat.envdsc = "Loja"
                   otherwise
                      let mr_relat.envdsc = "NAO CADASTRADO"
                end case

                case mr_relat.lcvstt
                   when "A" let mr_relat.lcvsttdes = "ATIVA"
                   when "C" let mr_relat.lcvsttdes = "CANCELADA"
                   otherwise
                      let mr_relat.lcvsttdes = "NAO CADASTRADO"
                end case

                case mr_relat.acntip
                   when 1 let mr_relat.acndes = 'Internet'
                   when 2 let mr_relat.acndes = 'Fax'
                   otherwise
                      let mr_relat.acndes = "NAO CADASTRADO"
                end case


                open crelat_30 using mr_relat.lojqlfcod
                fetch crelat_30 into mr_relat.desqualific

                if sqlca.sqlcode = 100 then
                        let mr_relat.desqualific = "NAO CADASTRADO"
                else
                    if sqlca.sqlcode < 0 then
                        error 'ERRO BUSCA DE DESCRICAO DA QUALIDADE DA LOJA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                    end if
                end if

                case mr_relat.lcvlojtip
                   when 1 let mr_relat.lcvlojdes = "CORPORACAO"
                   when 2 let mr_relat.lcvlojdes = "FRANQUIA"
                   when 3 let mr_relat.lcvlojdes = "FRANQUIA/REDE"
                   otherwise let mr_relat.lcvlojdes = "NAO CADASTRADO"
                end case

                open crelat_31 using mr_relat.succod
                fetch crelat_31 into mr_relat.sucnom

                if sqlca.sqlcode = 100 then
                    let mr_relat.sucnom = "NAO CADASTRADO"
                else
                    if sqlca.sqlcode < 0 then
                        error 'ERRO BUSCA DE SUCURSAL DA LOJA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                    end if
                end if

                case mr_relat.lcvregprccod
                   when 1    let mr_relat.lcvregprcdes = "PADRAO        "
                   when 2    let mr_relat.lcvregprcdes = "REGIAO II     "
                   when 3    let mr_relat.lcvregprcdes = "  LIVRE     "
                   otherwise let mr_relat.lcvregprcdes = "NAO CADASTRADO"
                end case

                case mr_relat.vclalglojstt
                   when  1   let mr_relat.lojsttdes = "ATIVA"
                   when  2   let mr_relat.lojsttdes = "BLOQUEADA"
                   when  3   let mr_relat.lojsttdes = "CANCELADA"
                   when  4   let mr_relat.lojsttdes = "DESATIVADA"
                   otherwise let mr_relat.lojsttdes = "NAO CADASTRADO"
                end case

                let l_clausula = ""
                open crelat_32 using mr_relat.lcvcod,
                                     mr_relat.aviestcod
                fetch crelat_32 into mr_relat.ramcod,
                                     mr_relat.clscod

                case sqlca.sqlcode
                    when 0
                        open crelat_32 using mr_relat.lcvcod,
                                             mr_relat.aviestcod
                             foreach crelat_32 into mr_relat.ramcod,
                                                    mr_relat.clscod

                                 #open crelat_33 using mr_relat.ramcod,
                                 #                     mr_relat.clscod
                                 #fetch crelat_33 into mr_relat.clsdes
                                 #if sqlca.sqlcode < 0 then
                                 #   error 'ERRO BUSCA DE CLAUSULAS DA LOJA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                                 #end if
                                 let l_clausula = l_clausula clipped, ' ', mr_relat.ramcod using '<<<<<', ', ', mr_relat.clscod clipped, ';'
                                 #let l_clausula = l_clausula , mr_relat.ramcod using '<<<<<', ', ', mr_relat.clscod clipped, '; '

                             end foreach
                        close crelat_32
                    when 100
                        let l_clausula = "NAO CADASTRADO"
                    otherwise
                        error 'ERRO BUSCA DE CLAUSULAS DA LOJA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                let l_cidtx = ""
                open crelat_34 using mr_relat.lcvcod,
                                     mr_relat.aviestcod
                fetch crelat_34 into mr_relat.cidcod,
                                     mr_relat.etgtaxvlr
                case sqlca.sqlcode
                    when 0
                        open crelat_34 using mr_relat.lcvcod,
                                             mr_relat.aviestcod
                        foreach crelat_34 into mr_relat.cidcod,
                                               mr_relat.etgtaxvlr
                            call cty10g00_cidade_uf(mr_relat.cidcod)
                            returning l_resultado,
                                      l_mensagem,
                                      mr_relat.cidnom_ent,
                                      mr_relat.ufdcod

                            let l_cidtx = l_cidtx clipped, ' ',mr_relat.cidnom_ent clipped, ', ', mr_relat.ufdcod clipped, ', ', mr_relat.etgtaxvlr  using '<<<<&.&&', ';'

                        end foreach
                        close crelat_34
                    when 100
                        let l_cidtx = "NAO CADASTRADO"
                    otherwise
                        error 'ERRO BUSCA DE CIDADES E TAXAS DE ENTREGA DA LOJA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case



                #INICIO#

                print mr_relat.lcvcod using '<<<<<&' clipped, ' ', ASCII(09);

                if  mr_relat.lcvnom is not null and mr_relat.lcvnom <> " " then
                    print mr_relat.lcvnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.lgdnom is not null and mr_relat.lgdnom <> " " then
                    print mr_relat.lgdnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.brrnom is not null and mr_relat.brrnom <> " " then
                    print mr_relat.brrnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cidnom is not null and mr_relat.cidnom <> " " then
                    print mr_relat.cidnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endufd_loc is not null and mr_relat.endufd_loc <> " " then
                    print mr_relat.endufd_loc        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.dddcod_loc is not null and mr_relat.dddcod_loc <> " " then
                    print mr_relat.dddcod_loc  using '<&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.teltxt_loc is not null and mr_relat.teltxt_loc <> " " then

                    print mr_relat.teltxt_loc clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.facnum_loc is not null and mr_relat.facnum_loc <> " " then

                    print mr_relat.facnum_loc clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.adcsgrtaxvlr is not null and mr_relat.adcsgrtaxvlr <> " " then
                    print mr_relat.adcsgrtaxvlr using '<<<&.&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cdtsegtaxvlr is not null and mr_relat.cdtsegtaxvlr <> " " then
                    print mr_relat.cdtsegtaxvlr using '<<<&.&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgccpfnum_loc is not null and mr_relat.cgccpfnum_loc <> ' ' then
                    print mr_relat.cgccpfnum_loc   using '<<<<<<<<<<&'   clipped, '/',
                          mr_relat.cgcord_loc      using '<<<<&&&&' clipped, '-',
                          mr_relat.cgccpfdig_loc   using '<<<&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print mr_relat.envdsc        clipped, ASCII(09);

                print mr_relat.lcvsttdes        clipped, ASCII(09);

                print mr_relat.acndes        clipped, ASCII(09);

                if  mr_relat.maides_loc is not null and mr_relat.maides_loc <> " " then
                    print mr_relat.maides_loc        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.caddat_loc is not null and mr_relat.caddat_loc <> " " then
                    print mr_relat.caddat_loc        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.atldat_loc is not null and mr_relat.atldat_loc <> " " then
                    print mr_relat.atldat_loc        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.aviestcod is not null and mr_relat.aviestcod <> " " then
                    print mr_relat.aviestcod  using '<<<<<&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.lcvextcod is not null and mr_relat.lcvextcod <> " " then
                    print mr_relat.lcvextcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.aviestnom is not null and mr_relat.aviestnom <> " " then
                    print mr_relat.aviestnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.lcvlojtip is not null and mr_relat.lcvlojtip <> " " then
                    print mr_relat.lcvlojtip  using '<<<<&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print mr_relat.lcvlojdes        clipped, ASCII(09);

                if  mr_relat.desqualific is not null and mr_relat.desqualific <> " " then
                    print mr_relat.desqualific        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endlgd_loj is not null and mr_relat.endlgd_loj <> " " then
                    print mr_relat.endlgd_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endbrr_loj is not null and mr_relat.endbrr_loj <> " " then
                    print mr_relat.endbrr_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endcid_loj is not null and mr_relat.endcid_loj <> " " then
                    print mr_relat.endcid_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endufd_loj is not null and mr_relat.endufd_loj <> " " then
                    print mr_relat.endufd_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let l_cep_loj = ''
                if  mr_relat.endcep_loj is not null and mr_relat.endcep_loj <> " " then
                    let l_cep_loj = mr_relat.endcep_loj using '<<&&&&&' clipped, '-', mr_relat.endcepcmp_loj using '<&&&' clipped
                    print l_cep_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.refptodes is not null and mr_relat.refptodes <> " " then
                    print mr_relat.refptodes        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.succod is not null and mr_relat.succod <> " " then
                    print mr_relat.succod using '<<<<&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.sucnom is not null and mr_relat.sucnom <> " " then
                    print mr_relat.sucnom clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.dddcod_loj is not null and mr_relat.dddcod_loj <> " " then
                    print mr_relat.dddcod_loj using '<&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.teltxt_loj is not null and mr_relat.teltxt_loj <> " " then

                    print mr_relat.teltxt_loj clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.facnum_loj is not null and mr_relat.facnum_loj <> " " then

                    print mr_relat.facnum_loj clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.horsegsexinc is not null and mr_relat.horsegsexinc <> " " then
                    print mr_relat.horsegsexinc, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.horsegsexfnl is not null and mr_relat.horsegsexfnl <> " " then
                    print mr_relat.horsegsexfnl, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.horsabinc is not null and mr_relat.horsabinc <> " " then
                    print mr_relat.horsabinc, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.horsabfnl is not null and mr_relat.horsabfnl <> " " then
                    print mr_relat.horsabfnl, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.hordominc is not null and mr_relat.hordominc <> " " then
                    print mr_relat.hordominc, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.hordomfnl is not null and mr_relat.hordomfnl <> " " then
                    print mr_relat.hordomfnl, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print mr_relat.lcvregprcdes        clipped, ASCII(09);

                print mr_relat.lojsttdes        clipped, ASCII(09);

                if  mr_relat.cauchqflg is not null and mr_relat.cauchqflg <> " " then
                    print mr_relat.cauchqflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.prtaertaxvlr is not null and mr_relat.prtaertaxvlr <> " " then
                    print mr_relat.prtaertaxvlr using '<<<<<<&.&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.maides_loj is not null and mr_relat.maides_loj <> " " then
                    print mr_relat.maides_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.obs is not null and mr_relat.obs <> " " then
                    print mr_relat.obs        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print l_clausula        clipped, ASCII(09);

                print l_cidtx        clipped, ASCII(09);
                
                # Pegando os responsáveis pela locadora                
                
                initialize l_aux to null
                initialize l_auxemp to null
                initialize l_auxcpf to null
                initialize l_auxpep to null                
                initialize l_ctdnom to null               
                let l_cpfresp = " "
                let l_pepresp = " "
                let l_respst_a = " "
                let l_resadm = 'A'
                let l_rescon = 'C'
                let l_respro = 'P'
                let l_primeiro = true 
                 
                open  crelat_49  using mr_relat.lcvcod
                		       ,mr_relat.aviestcod
                		       ,l_resadm
                		  
                   foreach crelat_49 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                       
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if 
                      
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if 
                                
                initialize l_aux to null
                initialize l_auxcpf to null
                initialize l_auxpep to null                
                initialize l_ctdnom to null               
                let l_cpfresp = " "
                let l_pepresp = " "
                let l_respst_c = " "
                let l_primeiro = true
                
                open  crelat_49  using mr_relat.lcvcod
                		       ,mr_relat.aviestcod
                		       ,l_rescon
                		  
                   foreach crelat_49 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                       
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if                
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if            
                
                initialize l_aux to null
                initialize l_ctdnom to null
                let l_respst_p = " "                
                let l_primeiro = true
                open  crelat_49  using mr_relat.lcvcod
                		       ,mr_relat.aviestcod
                		       ,l_respro
                		  
                   foreach crelat_49 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if                   
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if  
               
               #Receita bruta 
               
               let l_anobrtoprrctvlr = " "
               
               whenever error continue
                    select anobrtoprrctvlr                         
                     into l_anobrtoprrctvlr                     	  
                     from datkavislocal              
                    where aviestcod = mr_relat.aviestcod
               whenever error stop   

               whenever error continue
                   select cpodes 
                   	into l_cpodes_anobrtrct 
                   	from iddkdominio 
                   where cponom = 'anobrtoprrctvlr' 
                   	and cpocod = l_anobrtoprrctvlr
               whenever error stop           
               
               if sqlca.sqlcode <> 0 then
	            print ' ' clipped, ASCII(09);
	       else
	       	    print l_cpodes_anobrtrct clipped, ASCII(09);	
	       end if 
               
               #Patrimonio liquido
   	       let l_liqptrfxacod = " "
               let l_empcod       = " "
               whenever error continue
                   select liqptrfxacod
                   	  ,cademp 
                     into l_liqptrfxacod
                     	  ,l_empcod
                     from datkavislocal 
                    where aviestcod = mr_relat.aviestcod
               whenever error stop   

               whenever error continue
                   select liqptrfxaincvlr,
		         liqptrfxafnlvlr  
		   into l_liqptrfxaincvlr
		   	,l_liqptrfxafnlvlr 
		    from gsakliqptrfxa                               
		   where empcod       = l_empcod 
		     and liqptrfxacod = l_liqptrfxacod
               whenever error stop           
               
               if sqlca.sqlcode <> 0 then
	            print ' ' clipped, ASCII(09);
	       else 
	            print 'DE 'clipped,l_liqptrfxaincvlr clipped,' ATE 'clipped,l_liqptrfxafnlvlr clipped, ASCII(09);	
	       end if 

	       let l_primeiro = true
	       let l_ciaempcod = null
	       let l_auxemp    = null
               
               open crelat_50 using mr_relat.lcvcod,
               		            mr_relat.aviestcod

               foreach crelat_50 into l_ciaempcod
                                                      
                   if l_primeiro then                      
                     let l_auxemp = l_ciaempcod using '<<<<<'
                     let l_primeiro = false 
                   else                      
                     let l_auxemp = l_auxemp clipped, " ; ", l_ciaempcod using '<<<<<'
                   end if                   
               
               end foreach
                
              if l_auxemp is not null then
              	print l_auxemp clipped, ASCII(09);
              else
              	print 'NAO CADASTRADO' clipped, ASCII(09);
              end if  	       

	      print today, ASCII(09) #--> FX-080515

end report

#-----------------#
 report relat_can()
#-----------------#
        define lr_ret_cty11g00 record
                 erro       smallint
                ,mensagem   char(100)
                ,cpodes     like iddkdominio.cpodes
         end record

        define lr_retornonome     record
               erro           smallint
              ,mensagem       char(60)
              ,funnom         like isskfunc.funnom
        end record

        define lr_ret_ctd12g00 record
               resultado    smallint
              ,mensagem     char(60)
              ,nomrazsoc    like dpaksocor.nomrazsoc
              ,rspnom       like dpaksocor.rspnom
              ,teltxt       like dpaksocor.teltxt
               end record

        define l_prestadores  char(1000)              ,
               l_situacao     char(25)                ,
               l_consultoria  char(25)                ,
               l_char         char(30)                ,
               l_caddat       date                    ,
               l_cadhor       datetime hour to minute ,
               l_atldat       date                    ,
               l_atlhor       datetime hour to minute ,
               l_codpres      decimal(6,0)            ,
               l_datpres      date


        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

        format

            first page header

                print "RELATORIO DE CANDIDATOS"

                print ""

                print "CODIGO"                                clipped, ASCII(09),
                      "NOME DO CANDIDATO"                     clipped, ASCII(09),
                      "TIPO PESSOA"                           clipped, ASCII(09),
                      "CNPJ/CPF"                              clipped, ASCII(09),
                      "RG"                                    clipped, ASCII(09),
                      "UF"                                    clipped, ASCII(09),
                      "DT. NASCIMENTO"                        clipped, ASCII(09),
                      "IDADE"                                 clipped, ASCII(09),
                      "CNH"                                   clipped, ASCII(09),
                      "CATEGORIA"                             clipped, ASCII(09),
                      "DT. 1ª CNH"                            clipped, ASCII(09),
                      "SITUACAO"                              clipped, ASCII(09),
                      "DT. ULT. ANALISE"                      clipped, ASCII(09),
                      "INCLUIDO EM"                           clipped, ASCII(09),
                      "POR"                                   clipped, ASCII(09),
                      "ATUALIZADO EM"                         clipped, ASCII(09),
                      "POR"                                   clipped, ASCII(09),
                      "PRESTADOR"                             clipped, ASCII(09),
                      "CONSULTORIA"                           clipped, ASCII(09),
                      "DATA QRA"                              clipped, ASCII(09),
		                  "DATA"                                  clipped, ASCII(09) #--> FX-080515

            on every row

                initialize lr_ret_ctd12g00.* to null
                set isolation to dirty read

                let l_situacao = ""
                if  mr_relat.pstcndsitcod is not null and mr_relat.pstcndsitcod <> " " then
                    call cty11g00_iddkdominio('pstcndsitcod',mr_relat.pstcndsitcod)
                       returning lr_ret_cty11g00.*

                    let l_situacao = mr_relat.pstcndsitcod using '&&', "-", lr_ret_cty11g00.cpodes clipped
                else
                    let l_situacao = "NAO CADASTRADO"
                end if

                let l_consultoria = ""
                if  mr_relat.pstcndconcod is not null and mr_relat.pstcndconcod <> " " then
                    call cty11g00_iddkdominio('pstcndconcod',mr_relat.pstcndconcod)
                       returning lr_ret_cty11g00.*

                    let l_consultoria = mr_relat.pstcndconcod using '&&', "-", lr_ret_cty11g00.cpodes clipped
                else
                    let l_consultoria = "NAO CADASTRADO"
                end if

                let l_char = extend(today, year to month) - extend(mr_relat.nscdat, year to month)
                let mr_relat.idade = l_char[1,5]

                let l_caddat = date(mr_relat.caddat_can)
                let l_cadhor = extend(mr_relat.caddat_can, hour to minute)
                let l_atldat = date(mr_relat.atldat_can)
                let l_atlhor = extend(mr_relat.atldat_can, hour to minute)

                call cty08g00_nome_func(mr_relat.cademp,mr_relat.cadmat,
                                       "F")
                   returning lr_retornonome.*
                let mr_relat.cadnome = lr_retornonome.funnom

                call cty08g00_nome_func(mr_relat.atlemp,mr_relat.atlmat,"F")
                     returning lr_retornonome.*

                let mr_relat.atlnome = lr_retornonome.funnom

                open crelat_38 using mr_relat.srrcoddig
                fetch crelat_38 into mr_relat.datqra

                if sqlca.sqlcode = 100 then
                    let mr_relat.datqra = null
                else
                    if sqlca.sqlcode < 0 then
                        error 'ERRO BUSCA DE DATA DE QRA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                    end if
                end if

                let l_prestadores = ""
                open crelat_39 using mr_relat.pstcndcod
                foreach crelat_39 into l_codpres
                                      ,l_datpres

                   call ctd12g00_dados_pst(1,l_codpres)
                      returning lr_ret_ctd12g00.*

                   if lr_ret_ctd12g00.resultado <> 1 then
                      continue foreach
                   end if


                   let l_prestadores = l_prestadores clipped, ' ', l_codpres using '<<<<<<<&', ', ', lr_ret_ctd12g00.nomrazsoc clipped, ', ', l_datpres clipped, ';'

                end foreach


                #INICIO#

                print mr_relat.pstcndcod using '<<<<<&' clipped, ' ', ASCII(09);

                if  mr_relat.pstcndnom is not null and mr_relat.pstcndnom <> " " then
                    print mr_relat.pstcndnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pestip is not null and mr_relat.pestip <> " " then
                    print mr_relat.pestip        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgccpfnum is not null and mr_relat.cgccpfnum <> ' ' then
                    if  mr_relat.pestip = 'F' then
                        print mr_relat.cgccpfnum  using '<<<<<<<<<<&'   clipped, '-',
                              mr_relat.cgccpfdig  using '<<<&&' clipped, ASCII(09);
                    else
                        print mr_relat.cgccpfnum   using '<<<<<<<<<<&'   clipped, '/',
                              mr_relat.cgcord      using '<<<<&&&&' clipped, '-',
                              mr_relat.cgccpfdig   using '<<<&&' clipped, ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.rgenum is not null and mr_relat.rgenum <> " " then
                    print mr_relat.rgenum        using '<<<<<<<<<&'   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.rgeufdcod is not null and mr_relat.rgeufdcod <> " " then
                    print mr_relat.rgeufdcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.nscdat is not null and mr_relat.nscdat <> " " then
                    print mr_relat.nscdat  clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.idade is not null and mr_relat.idade <> " " then
                    print mr_relat.idade  clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cnhnum is not null and mr_relat.cnhnum <> " " then
                    print mr_relat.cnhnum         using '<<<<<<<<<<<&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cnhctgcod is not null and mr_relat.cnhctgcod <> " " then
                    print mr_relat.cnhctgcod clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cnhpridat is not null and mr_relat.cnhpridat <> " " then
                    print mr_relat.cnhpridat   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print l_situacao        clipped, ASCII(09);

                if  mr_relat.rdranlultdat is not null and mr_relat.rdranlultdat <> " " then
                    print mr_relat.rdranlultdat        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  (l_caddat is not null and l_caddat <> " ") and
                    (l_cadhor is not null and l_cadhor <> " ")  then
                    print l_caddat, " as ", l_cadhor       clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cadnome is not null and mr_relat.cadnome <> " " then
                    print mr_relat.cademp, " ", mr_relat.cadmat, " ",mr_relat.cadnome        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  (l_atldat is not null and l_atldat <> " ") and
                    (l_atlhor is not null and l_atlhor <> " ")  then
                    print l_atldat, " as ", l_atlhor       clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.atlnome is not null and mr_relat.atlnome <> " " then
                    print mr_relat.atlemp, " ", mr_relat.atlmat, " ",mr_relat.atlnome        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_prestadores is not null and l_prestadores <> " " then
                    print l_prestadores        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print l_consultoria        clipped, ASCII(09);

                if  mr_relat.datqra  is not null and mr_relat.datqra <> " " then
                    print mr_relat.datqra        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

		print today, ASCII(09) #--> FX-080515

end report

#-----------------#
 report relat_can_txt()
#-----------------#
        define lr_ret_cty11g00 record
                 erro       smallint
                ,mensagem   char(100)
                ,cpodes     like iddkdominio.cpodes
         end record

        define lr_retornonome     record
               erro           smallint
              ,mensagem       char(60)
              ,funnom         like isskfunc.funnom
        end record

        define lr_ret_ctd12g00 record
               resultado    smallint
              ,mensagem     char(60)
              ,nomrazsoc    like dpaksocor.nomrazsoc
              ,rspnom       like dpaksocor.rspnom
              ,teltxt       like dpaksocor.teltxt
               end record

        define l_prestadores  char(1000)              ,
               l_situacao     char(25)                ,
               l_consultoria  char(25)                ,
               l_char         char(30)                ,
               l_caddat       date                    ,
               l_cadhor       datetime hour to minute ,
               l_atldat       date                    ,
               l_atlhor       datetime hour to minute ,
               l_codpres      decimal(6,0)            ,
               l_datpres      date


        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    01

        format

            on every row

                initialize lr_ret_ctd12g00.* to null
                set isolation to dirty read

                let l_situacao = ""
                if  mr_relat.pstcndsitcod is not null and mr_relat.pstcndsitcod <> " " then
                    call cty11g00_iddkdominio('pstcndsitcod',mr_relat.pstcndsitcod)
                       returning lr_ret_cty11g00.*

                    let l_situacao = mr_relat.pstcndsitcod using '&&', "-", lr_ret_cty11g00.cpodes clipped
                else
                    let l_situacao = "NAO CADASTRADO"
                end if

                let l_consultoria = ""
                if  mr_relat.pstcndconcod is not null and mr_relat.pstcndconcod <> " " then
                    call cty11g00_iddkdominio('pstcndconcod',mr_relat.pstcndconcod)
                       returning lr_ret_cty11g00.*

                    let l_consultoria = mr_relat.pstcndconcod using '&&', "-", lr_ret_cty11g00.cpodes clipped
                else
                    let l_consultoria = "NAO CADASTRADO"
                end if

                let l_char = extend(today, year to month) - extend(mr_relat.nscdat, year to month)
                let mr_relat.idade = l_char[1,5]

                let l_caddat = date(mr_relat.caddat_can)
                let l_cadhor = extend(mr_relat.caddat_can, hour to minute)
                let l_atldat = date(mr_relat.atldat_can)
                let l_atlhor = extend(mr_relat.atldat_can, hour to minute)

                call cty08g00_nome_func(mr_relat.cademp,mr_relat.cadmat,
                                       "F")
                   returning lr_retornonome.*
                let mr_relat.cadnome = lr_retornonome.funnom

                call cty08g00_nome_func(mr_relat.atlemp,mr_relat.atlmat,"F")
                     returning lr_retornonome.*

                let mr_relat.atlnome = lr_retornonome.funnom

                open crelat_38 using mr_relat.srrcoddig
                fetch crelat_38 into mr_relat.datqra

                if sqlca.sqlcode = 100 then
                    let mr_relat.datqra = null
                else
                    if sqlca.sqlcode < 0 then
                        error 'ERRO BUSCA DE DATA DE QRA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                    end if
                end if

                let l_prestadores = ""
                open crelat_39 using mr_relat.pstcndcod
                foreach crelat_39 into l_codpres
                                      ,l_datpres

                   call ctd12g00_dados_pst(1,l_codpres)
                      returning lr_ret_ctd12g00.*

                   if lr_ret_ctd12g00.resultado <> 1 then
                      continue foreach
                   end if


                   let l_prestadores = l_prestadores clipped, ' ', l_codpres using '<<<<<<<&', ', ', lr_ret_ctd12g00.nomrazsoc clipped, ', ', l_datpres clipped, ';'

                end foreach


                #INICIO#

                print mr_relat.pstcndcod using '<<<<<&' clipped, ' ', ASCII(09);

                if  mr_relat.pstcndnom is not null and mr_relat.pstcndnom <> " " then
                    print mr_relat.pstcndnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pestip is not null and mr_relat.pestip <> " " then
                    print mr_relat.pestip        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgccpfnum is not null and mr_relat.cgccpfnum <> ' ' then
                    if  mr_relat.pestip = 'F' then
                        print mr_relat.cgccpfnum  using '<<<<<<<<<<&'   clipped, '-',
                              mr_relat.cgccpfdig  using '<<<&&' clipped, ASCII(09);
                    else
                        print mr_relat.cgccpfnum   using '<<<<<<<<<<&'   clipped, '/',
                              mr_relat.cgcord      using '<<<<&&&&' clipped, '-',
                              mr_relat.cgccpfdig   using '<<<&&' clipped, ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.rgenum is not null and mr_relat.rgenum <> " " then
                    print mr_relat.rgenum        using '<<<<<<<<<&'   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.rgeufdcod is not null and mr_relat.rgeufdcod <> " " then
                    print mr_relat.rgeufdcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.nscdat is not null and mr_relat.nscdat <> " " then
                    print mr_relat.nscdat  clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.idade is not null and mr_relat.idade <> " " then
                    print mr_relat.idade  clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cnhnum is not null and mr_relat.cnhnum <> " " then
                    print mr_relat.cnhnum         using '<<<<<<<<<<<&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cnhctgcod is not null and mr_relat.cnhctgcod <> " " then
                    print mr_relat.cnhctgcod clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cnhpridat is not null and mr_relat.cnhpridat <> " " then
                    print mr_relat.cnhpridat   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print l_situacao        clipped, ASCII(09);

                if  mr_relat.rdranlultdat is not null and mr_relat.rdranlultdat <> " " then
                    print mr_relat.rdranlultdat        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  (l_caddat is not null and l_caddat <> " ") and
                    (l_cadhor is not null and l_cadhor <> " ")  then
                    print l_caddat, " as ", l_cadhor       clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cadnome is not null and mr_relat.cadnome <> " " then
                    print mr_relat.cademp, " ", mr_relat.cadmat, " ",mr_relat.cadnome        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  (l_atldat is not null and l_atldat <> " ") and
                    (l_atlhor is not null and l_atlhor <> " ")  then
                    print l_atldat, " as ", l_atlhor       clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.atlnome is not null and mr_relat.atlnome <> " " then
                    print mr_relat.atlemp, " ", mr_relat.atlmat, " ",mr_relat.atlnome        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_prestadores is not null and l_prestadores <> " " then
                    print l_prestadores        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print l_consultoria        clipped, ASCII(09);

                if  mr_relat.datqra  is not null and mr_relat.datqra <> " " then
                    print mr_relat.datqra        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

		print today

end report

#-----------------#
 report relat_vcl_txt()
#-----------------#

        define l_teste           char(0100),
               l_equip           char(1000),
               l_ass             char(1000),
               l_emp             char(1000),
               l_aux             char(0100),
               l_aux2            char(0100),
               l_equipdes        char(0100),
               l_equips          char(1000),
               l_primeiro        smallint,
               l_data            char(010),
               l_resp            char(1000),
               l_simcard         char(1000),
               l_recsinflg       like datkcdssim.recsinflg,
               l_cdssimintcod    like datkcdssim.cdssimintcod,
               l_celoprcod       like datkcdssim.celoprcod,
               l_sinoprdes       char(30),
               l_sinflg          char(20),
               l_vclcadorgdes    char(100) 

	define l_viavidseg  char(1) # Saber se tem ou nao seguro da viatura 
	
	define l_ret  record                                                   
       		coderro     integer,  ## Codigo erro retorno / 0=Ok <>0=Error   
       		msgerro     char(50), ## Mensagem erro retorno                  
       		qualificado char(01),  ## Sim ou Nao                            
       		socvcltip   like datkveiculo.socvcltip                          
	end record                                                             

	
	
        
        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    01

        format

            on every row

                let mr_relat.vclcordes    = ""
                let mr_relat.vclpntdes    = ""
                let mr_relat.vclcmbdes    = ""
                let mr_relat.vclaqstipdes = ""
                let mr_relat.socoprsitdes = ""

                let l_equips = ""
                open crelat_17 using mr_relat.socvclcod
                fetch crelat_17 into l_equips

               case sqlca.sqlcode
                when 0
                        let l_equips = ""
                        let l_equipdes = ""

                        let l_primeiro = true

                        foreach crelat_17 into l_equipdes

                                if  l_primeiro then
                                        let l_equips = l_equipdes
                                        let l_primeiro = false
                                else
                                        let l_equips = l_equips clipped,  "; ",  l_equipdes
                                end if
                        end foreach
                when 100
                        let l_equips = ''
                otherwise
                        error 'ERRO BUSCA DE EQUIPAMENTO: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
               end case

                open crelat_21 using mr_relat.socvclcod
                fetch crelat_21 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_ass = ""
                                let l_primeiro = true

                                foreach crelat_21 into l_aux
                                        if  l_primeiro then
                                                let l_ass = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_ass = l_ass clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_ass = ' '
                        otherwise
                                error 'ERRO BUSCA DE ASSISTENCIA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_14 using mr_relat.socvclcod
                fetch crelat_14 into l_aux

                case sqlca.sqlcode
                        when 0
                                let l_emp = " "
                                let l_primeiro = true

                                foreach crelat_14 into l_aux2
                                        if  l_primeiro then
                                                let l_emp = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_emp = l_emp clipped,  "; ",  l_aux2 clipped
                                        end if
                                end foreach
                        when 100
                                let l_emp = ' '
                        otherwise
                                error 'ERRO BUSCA DE EMPRESA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                let mr_relat.vclcordes = null
                let l_aux = 'vclcorcod'
                open crelat_15 using l_aux,
                                     mr_relat.vclcorcod
                fetch crelat_15 into mr_relat.vclcordes

                if mr_relat.vclcordes is null or
                    mr_relat.vclcordes = " " then
                    let mr_relat.vclcordes = 'NAO CADASTRADA'
                end if

                let mr_relat.vclpntdes = null
                let l_aux = 'vclpnttip'
                open crelat_15 using l_aux,
                                     mr_relat.vclpnttip
                fetch crelat_15 into mr_relat.vclpntdes

                if  mr_relat.vclpntdes is null or
                    mr_relat.vclpntdes = " " then
                    let mr_relat.vclpntdes = 'NAO CADASTRADA'
                end if

                let mr_relat.vclcmbdes = null
                let l_aux = 'vclcmbcod'
                open crelat_15 using l_aux,
                                     mr_relat.vclcmbcod
                fetch crelat_15 into mr_relat.vclcmbdes

                if  mr_relat.vclcordes is null or
                    mr_relat.vclcordes = " " then
                    let mr_relat.vclcordes = 'NAO CADASTRADA'
                end if

                let mr_relat.vcldtbgrpdes = null
                open crelat_16 using mr_relat.socvclcod
                fetch crelat_16 into mr_relat.vcldtbgrpdes

                let mr_relat.vclaqstipdes = null
                let l_aux = 'vclaqstipcod'
                open crelat_15 using l_aux,
                                     mr_relat.vclaqstipcod
                fetch crelat_15 into mr_relat.vclaqstipdes

                let mr_relat.mdtcfgcod = null
                let mr_relat.mdtdes = null

                open crelat_27 using mr_relat.mdtcod
                fetch crelat_27 into mr_relat.mdtcfgcod

                let l_aux = 'eqttipcod'
                open crelat_15 using l_aux,
                                     mr_relat.mdtcfgcod
                fetch crelat_15 into mr_relat.mdtdes
                #INICIO#

                print mr_relat.pstcoddig clipped, ' ', ASCII(09);

                if  mr_relat.nomgrr is not null and mr_relat.nomgrr <> " " then
                    print mr_relat.nomgrr        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pestip is not null and mr_relat.pestip <> " " then
                    print mr_relat.pestip        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgccpfnum is not null and mr_relat.cgccpfnum <> ' ' then
                    if  mr_relat.pestip = 'F' then
                        print mr_relat.cgccpfnum  using '<<<<<<<<<<&'   clipped, '-',
                              mr_relat.cgccpfdig  using '<<<&&' clipped, ASCII(09);
                    else
                        print mr_relat.cgccpfnum   using '<<<<<<<<<<&'   clipped, '/',
                              mr_relat.cgcord      using '<<<<&&&&' clipped, '-',
                              mr_relat.cgccpfdig   using '<<<&&' clipped, ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pptnom is not null and mr_relat.pptnom <> " " then
                    print mr_relat.pptnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if  mr_relat.dddcod is not null and mr_relat.dddcod <> " " then
                    print mr_relat.dddcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if  mr_relat.teltxt is not null and mr_relat.teltxt <> " " then
                    print mr_relat.teltxt        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.maides is not null and mr_relat.maides <> " " then
                    print mr_relat.maides        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                case mr_relat.prssitcod
                     when "A"
                          let mr_relat.prsitdes = "ATIVO"
                     when "B"
                          let mr_relat.prsitdes = "BLOQUEADO"
                     when "C"
                          let mr_relat.prsitdes = "CANCELADO"
                     when "P"
                          let mr_relat.prsitdes = "PROPOSTA"
                     otherwise
                          let mr_relat.prsitdes = "NAO CADASTRADO"
                end case

                print mr_relat.prssitcod clipped  , ' - ',
                      mr_relat.prsitdes clipped, ' ', ASCII(09);

                let l_data = extend(mr_relat.cmtdat, year to year ),'-',
                             extend(mr_relat.cmtdat, month to month),'-',
                             extend(mr_relat.cmtdat, day to day)

                print l_data              clipped , ' ', ASCII(09);

                let l_data = extend(mr_relat.atldat, year to year ),'-',
                             extend(mr_relat.atldat, month to month),'-',
                             extend(mr_relat.atldat, day to day)

                print l_data              clipped , ' ', ASCII(09);

                print   mr_relat.socvclcod    clipped, ' ', ASCII(09);

                if  mr_relat.atdvclsgl is not null and mr_relat.atdvclsgl <> " " then
                    print  mr_relat.atdvclsgl   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.vclanomdl is not null and mr_relat.vclanomdl <> " " then
                     print upshift(mr_relat.vclanomdl)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let mr_relat.socoprsitdes = null
                let l_aux = 'socoprsitcod'
                open crelat_15 using l_aux,
                                     mr_relat.socoprsitcod
                fetch crelat_15 into mr_relat.socoprsitdes

                if mr_relat.socoprsitdes is not null and mr_relat.socoprsitdes <> " " then
                     print upshift(mr_relat.socoprsitdes)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if




                if mr_relat.vcllicnum is not null and mr_relat.vcllicnum <> " " then
                     print upshift(mr_relat.vcllicnum)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if


                if mr_relat.vclanofbc is not null and mr_relat.vclanofbc <> " " then
                     print upshift(mr_relat.vclanofbc)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.mdtcod is not null and mr_relat.mdtcod <> " " then
                     print upshift(mr_relat.mdtcod)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.mdtdes is not null and mr_relat.mdtdes <> " " then
                     print upshift(mr_relat.mdtcfgcod), ' - ' ,upshift(mr_relat.mdtdes)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.pgrnum is not null and mr_relat.pgrnum <> " " then
                     print upshift(mr_relat.pgrnum)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let l_data = extend(mr_relat.caddat, year to year ),'-',
                             extend(mr_relat.caddat, month to month),'-',
                             extend(mr_relat.caddat, day to day)

                print l_data              clipped , ' ', ASCII(09);

                let l_data = extend(mr_relat.atldat2, year to year ),'-',
                             extend(mr_relat.atldat2, month to month),'-',
                             extend(mr_relat.atldat2, day to day)

                print l_data              clipped , ' ', ASCII(09);

                if mr_relat.endcid is not null and mr_relat.endcid <> " " then
                     print upshift(mr_relat.endcid)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.endufd is not null and mr_relat.endufd <> " " then
                     print upshift(mr_relat.endufd)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.vcldtbgrpdes is not null and mr_relat.vcldtbgrpdes <> " " then
                    print  mr_relat.vcldtbgrpdes  clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if mr_relat.celdddcod is not null and mr_relat.celdddcod <> " " then
                     print upshift(mr_relat.celdddcod)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

        if mr_relat.celtelnum is not null and mr_relat.celtelnum <> " " then
                     print upshift(mr_relat.celtelnum)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.nxtdddcod is not null and mr_relat.nxtdddcod <> " " then
                     print upshift(mr_relat.nxtdddcod)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.nxtide is not null and mr_relat.nxtide <> " " then
                     print upshift(mr_relat.nxtide)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.nxtnum is not null and mr_relat.nxtnum <> " " then
                     print upshift(mr_relat.nxtnum)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                #if  mr_relat.vclctfnom is not null and mr_relat.vclctfnom <> " " then
                #    print mr_relat.vclctfnom        clipped, ASCII(09);
                #else
                #    print 'NAO CADASTRADO' , ASCII(09);
                #end if

                if  mr_relat.vclaqstipdes is not null and mr_relat.vclaqstipdes <> " " then
                    print mr_relat.vclaqstipcod, " - ", mr_relat.vclaqstipdes clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.vclaqsnom is not null and mr_relat.vclaqsnom <> " " then
                    print mr_relat.vclaqsnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let mr_relat.eqpdes = ""
                let l_aux = 'socvcltip'
                open crelat_15 using l_aux,
                                     mr_relat.eqptip
                fetch crelat_15 into mr_relat.eqpdes

                if  mr_relat.eqpdes is not null and mr_relat.eqpdes <> " " then
                    print mr_relat.eqptip clipped," - ", mr_relat.eqpdes clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                call cts15g00(mr_relat.vclcoddig)
                     returning mr_relat.vcldes

                if  mr_relat.vclcoddig is not null and mr_relat.vclcoddig <> " " then
                    print mr_relat.vclcoddig        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print mr_relat.vcldes    clipped, ' ', ASCII(09);

                if  mr_relat.vclchs is not null and mr_relat.vclchs <> " " then
                    print mr_relat.vclchs        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.vclcordes is not null and mr_relat.vclcordes <> " " then
                     print upshift(mr_relat.vclcordes)        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.vclpntdes is not null and mr_relat.vclpntdes <> " " then
                    print  upshift(mr_relat.vclpntdes)   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.vclcmbdes is not null and mr_relat.vclcmbdes <> " " then
                    print  upshift(mr_relat.vclcmbdes)   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.socvstdiaqtd is not null and mr_relat.socvstdiaqtd <> " " then
                    print  mr_relat.socvstdiaqtd   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let mr_relat.socvstlcldes = null
                open crelat_18 using mr_relat.socvstlclcod
                fetch crelat_18 into mr_relat.socvstlcldes

                if  mr_relat.socvstlcldes is not null and mr_relat.socvstlcldes <> " " then
                    print  mr_relat.socvstlcldes   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.socvstlautipcod is not null and mr_relat.socvstlautipcod <> " " then
                    print  mr_relat.socvstlautipcod   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.socctrposflg is not null and mr_relat.socctrposflg <> " " then
                    print  mr_relat.socctrposflg   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                #if  mr_relat.pstobs is not null and  mr_relat.pstobs <> " " then
                #    print mr_relat.pstobs        clipped, ASCII(09);
                #else
                #    print 'NAO CADASTRADO' , ASCII(09);
                #end if

                let mr_relat.mdtctrcod  = null
                open crelat_20 using mr_relat.mdtcod
                fetch crelat_20 into mr_relat.mdtctrcod

                if  mr_relat.mdtctrcod is not null and mr_relat.mdtctrcod <> " " then
                    print  mr_relat.mdtctrcod   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_equips is not null and l_equips <> " " then
                    print  l_equips   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bckcod is not null and mr_relat.bckcod <> " " then

                    open crelat_22 using mr_relat.bckcod
                    fetch crelat_22 into mr_relat.bckdes

                    if  sqlca.sqlcode = 0 then
                        print mr_relat.bckdes , ASCII(09);
                    else
                        print 'BACKLIGHT INVALIDO' , ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.dpycod is not null and mr_relat.dpycod <> " " then

                    open crelat_23 using mr_relat.dpycod
                    fetch crelat_23 into mr_relat.dpydes

                    if  sqlca.sqlcode = 0 then
                        print mr_relat.dpydes , ASCII(09);
                    else
                        print 'DISPLAY INVALIDO' , ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if


                if  l_ass is not null and l_ass <> " " then
                    print  l_ass  clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_emp is not null and l_emp <> " " then
                    print  l_emp   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                #Busca o responsavel - frtrpnflg
                #open crelat_25 using mr_relat.pstcoddig
                #fetch crelat_25 into mr_relat.frtrpnflg

                let l_resp = null
                open crelat_24 using mr_relat.frtrpnflg
                fetch crelat_24 into l_resp

                if  l_resp is not null and  l_resp <> " " then
                    print l_resp        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                # Busca simcard
                let l_simcard = " "
                let l_primeiro = true
                open crelat_35 using mr_relat.mdtcod
                foreach crelat_35 into l_recsinflg,
                                       l_cdssimintcod,
                                       l_celoprcod

                   let l_sinflg = ""
                   let l_aux = "RECSINFLG"
                   open crelat_15 using l_aux,
                                        l_recsinflg
                   fetch crelat_15 into l_sinflg

                   let l_sinoprdes = ""
                   open crelat_36 using l_celoprcod
                   fetch crelat_36 into l_sinoprdes

                   if  l_primeiro then
                        let l_simcard = l_cdssimintcod clipped, "|", l_sinoprdes clipped, "|", l_sinflg
                        let l_primeiro = false
                   else
                        let l_simcard = l_simcard clipped,  ";",  l_cdssimintcod clipped, "|", l_sinoprdes clipped, "|", l_sinflg
                   end if
                end foreach
                if  l_simcard is not null and  l_simcard <> " " then
                    print l_simcard        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if
                
                
                # Renavam
                if  mr_relat.rencod  is not null and  mr_relat.rencod  <> " " then
                    print mr_relat.rencod   clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if
                
                # Origem do cadastro da viatura
                if  mr_relat.vclcadorgcod   is not null and  mr_relat.vclcadorgcod <> 0 then
                   let l_vclcadorgdes = 'ctc34m03_orgcadvcl'
                   open crelat_15 using l_vclcadorgdes,
                                        mr_relat.vclcadorgcod 
                   fetch crelat_15 into l_vclcadorgdes
                   
                   let l_vclcadorgdes = mr_relat.vclcadorgcod clipped," - ", l_vclcadorgdes clipped
                    print l_vclcadorgdes clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if 
                
                # descricao da apolice de seguro do veiculo
                if  m_apolice.apol_descricao  is not null and  m_apolice.apol_descricao  <> " " then
 		    let l_viavidseg = 'SIM'               
                    print l_viavidseg   clipped  ;
                else
                    let l_viavidseg = 'NAO'
                    print l_viavidseg ;
                end if
		print ASCII(09);
		
		call ctb00g08_qualifvcl("", mr_relat.socvclcod, "", "", today, today)
		returning l_ret.coderro,    
			  l_ret.msgerro,   
			  l_ret.qualificado,
			  l_ret.socvcltip
			  
                print l_ret.qualificado, ASCII(09); #--> FX-080515
                 
		print today #--> FX-080515

end report

#-----------------#
 report relat_loj_txt()
#-----------------#
        define l_teste        char(0100),
               l_equip        char(1000),
               l_ass          char(1000),
               l_emp          char(1000),
               l_aux          char(0300),
               l_auxemp       char(0300),
               l_auxcpf       char(0300),
               l_auxpep       char(0100), 
               l_equipdes     char(0100),
               l_equips       char(1000),
               l_primeiro     smallint,
               l_data         char(010),
               l_resp         char(1000),
               l_clausula     char(1000),
               l_cidtx        char(1000),
               l_ciaempcod    smallint,
               l_cep_loj      char(09),
               l_sucursal     char(0100),
               l_mensagem     char (60),
               l_resultado    smallint,
               l_respst_a char(1000), # Administrador da prestadora            
               l_respst_c char(1000), # Controlador da prestadora
               l_respst_p char(1000), # Procurador da prestadora
               l_cpfresp  char(0100), # CPF Responsavel   
               l_pepresp  char(0100), # PEP Responsavel                  
               l_anobrtoprrctvlr like dpaksocor.anobrtoprrctvlr, #Codigo da receita bruta anual
               l_liqptrfxacod    like dpaksocor.liqptrfxacod,  #Codigo do patrimonio liquido
               l_empcod          like dpaksocor.empcod,          #Codigo da empresa Porto  
               l_cpodes_anobrtrct like iddkdominio.cpodes, #Descricao da receita bruta anual 
               l_liqptrfxaincvlr  like gsakliqptrfxa.liqptrfxaincvlr,#Descricao inicial do patrimonio liq
	       l_liqptrfxafnlvlr  like gsakliqptrfxa.liqptrfxafnlvlr, #Descricao final do patrimonio liq  
	       l_resadm char(1),#Sigla do tipo de responsavel Administrador
	       l_rescon char(1),#Sigla do tipo de responsavel Controlador
	       l_respro char(1), #Sigla do tipo de responsavel Procurador
	       l_ctdnom like dpakctd.ctdnom

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    01

        format

            on every row                   
                                           
                set isolation to dirty read
                case mr_relat.lcvresenvcod
                   when 1 let mr_relat.envdsc = "Central Reservas"
                   when 2 let mr_relat.envdsc = "Loja"
                   otherwise
                      let mr_relat.envdsc = "NAO CADASTRADO"
                end case

                case mr_relat.lcvstt
                   when "A" let mr_relat.lcvsttdes = "ATIVA"
                   when "C" let mr_relat.lcvsttdes = "CANCELADA"
                   otherwise
                      let mr_relat.lcvsttdes = "NAO CADASTRADO"
                end case

                case mr_relat.acntip
                   when 1 let mr_relat.acndes = 'Internet'
                   when 2 let mr_relat.acndes = 'Fax'
                   otherwise
                      let mr_relat.acndes = "NAO CADASTRADO"
                end case


                open crelat_30 using mr_relat.lojqlfcod
                fetch crelat_30 into mr_relat.desqualific

                if sqlca.sqlcode = 100 then
                        let mr_relat.desqualific = "NAO CADASTRADO"
                else
                    if sqlca.sqlcode < 0 then
                        error 'ERRO BUSCA DE DESCRICAO DA QUALIDADE DA LOJA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                    end if
                end if

                case mr_relat.lcvlojtip
                   when 1 let mr_relat.lcvlojdes = "CORPORACAO"
                   when 2 let mr_relat.lcvlojdes = "FRANQUIA"
                   when 3 let mr_relat.lcvlojdes = "FRANQUIA/REDE"
                   otherwise let mr_relat.lcvlojdes = "NAO CADASTRADO"
                end case

                open crelat_31 using mr_relat.succod
                fetch crelat_31 into mr_relat.sucnom

                if sqlca.sqlcode = 100 then
                    let mr_relat.sucnom = "NAO CADASTRADO"
                else
                    if sqlca.sqlcode < 0 then
                        error 'ERRO BUSCA DE SUCURSAL DA LOJA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                    end if
                end if

                case mr_relat.lcvregprccod
                   when 1    let mr_relat.lcvregprcdes = "PADRAO        "
                   when 2    let mr_relat.lcvregprcdes = "REGIAO II     "
                   when 3    let mr_relat.lcvregprcdes = "  LIVRE     "
                   otherwise let mr_relat.lcvregprcdes = "NAO CADASTRADO"
                end case

                case mr_relat.vclalglojstt
                   when  1   let mr_relat.lojsttdes = "ATIVA"
                   when  2   let mr_relat.lojsttdes = "BLOQUEADA"
                   when  3   let mr_relat.lojsttdes = "CANCELADA"
                   when  4   let mr_relat.lojsttdes = "DESATIVADA"
                   otherwise let mr_relat.lojsttdes = "NAO CADASTRADO"
                end case

                let l_clausula = ""
                open crelat_32 using mr_relat.lcvcod,
                                     mr_relat.aviestcod
                fetch crelat_32 into mr_relat.ramcod,
                                     mr_relat.clscod

                case sqlca.sqlcode
                    when 0
                        open crelat_32 using mr_relat.lcvcod,
                                             mr_relat.aviestcod
                             foreach crelat_32 into mr_relat.ramcod,
                                                    mr_relat.clscod

                                 #open crelat_33 using mr_relat.ramcod,
                                 #                     mr_relat.clscod
                                 #fetch crelat_33 into mr_relat.clsdes
                                 #if sqlca.sqlcode < 0 then
                                 #   error 'ERRO BUSCA DE CLAUSULAS DA LOJA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                                 #end if
                                 let l_clausula = l_clausula clipped, ' ', mr_relat.ramcod using '<<<<<', ', ', mr_relat.clscod clipped, ';'
                                 #let l_clausula = l_clausula , mr_relat.ramcod using '<<<<<', ', ', mr_relat.clscod clipped, '; '

                             end foreach
                        close crelat_32
                    when 100
                        let l_clausula = "NAO CADASTRADO"
                    otherwise
                        error 'ERRO BUSCA DE CLAUSULAS DA LOJA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                let l_cidtx = ""
                open crelat_34 using mr_relat.lcvcod,
                                     mr_relat.aviestcod
                fetch crelat_34 into mr_relat.cidcod,
                                     mr_relat.etgtaxvlr
                case sqlca.sqlcode
                    when 0
                        open crelat_34 using mr_relat.lcvcod,
                                             mr_relat.aviestcod
                        foreach crelat_34 into mr_relat.cidcod,
                                               mr_relat.etgtaxvlr
                            call cty10g00_cidade_uf(mr_relat.cidcod)
                            returning l_resultado,
                                      l_mensagem,
                                      mr_relat.cidnom_ent,
                                      mr_relat.ufdcod

                            let l_cidtx = l_cidtx clipped, ' ',mr_relat.cidnom_ent clipped, ', ', mr_relat.ufdcod clipped, ', ', mr_relat.etgtaxvlr  using '<<<<&.&&', ';'

                        end foreach
                        close crelat_34
                    when 100
                        let l_cidtx = "NAO CADASTRADO"
                    otherwise
                        error 'ERRO BUSCA DE CIDADES E TAXAS DE ENTREGA DA LOJA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case



                #INICIO#

                print mr_relat.lcvcod using '<<<<<&' clipped, ' ', ASCII(09);

                if  mr_relat.lcvnom is not null and mr_relat.lcvnom <> " " then
                    print mr_relat.lcvnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.lgdnom is not null and mr_relat.lgdnom <> " " then
                    print mr_relat.lgdnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.brrnom is not null and mr_relat.brrnom <> " " then
                    print mr_relat.brrnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cidnom is not null and mr_relat.cidnom <> " " then
                    print mr_relat.cidnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endufd_loc is not null and mr_relat.endufd_loc <> " " then
                    print mr_relat.endufd_loc        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.dddcod_loc is not null and mr_relat.dddcod_loc <> " " then
                    print mr_relat.dddcod_loc  using '<&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.teltxt_loc is not null and mr_relat.teltxt_loc <> " " then

                    print mr_relat.teltxt_loc clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.facnum_loc is not null and mr_relat.facnum_loc <> " " then

                    print mr_relat.facnum_loc clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.adcsgrtaxvlr is not null and mr_relat.adcsgrtaxvlr <> " " then
                    print mr_relat.adcsgrtaxvlr using '<<<&.&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cdtsegtaxvlr is not null and mr_relat.cdtsegtaxvlr <> " " then
                    print mr_relat.cdtsegtaxvlr using '<<<&.&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgccpfnum_loc is not null and mr_relat.cgccpfnum_loc <> ' ' then
                    print mr_relat.cgccpfnum_loc   using '<<<<<<<<<<&'   clipped, '/',
                          mr_relat.cgcord_loc      using '<<<<&&&&' clipped, '-',
                          mr_relat.cgccpfdig_loc   using '<<<&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print mr_relat.envdsc        clipped, ASCII(09);

                print mr_relat.lcvsttdes        clipped, ASCII(09);

                print mr_relat.acndes        clipped, ASCII(09);

                if  mr_relat.maides_loc is not null and mr_relat.maides_loc <> " " then
                    print mr_relat.maides_loc        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.caddat_loc is not null and mr_relat.caddat_loc <> " " then
                    print mr_relat.caddat_loc        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.atldat_loc is not null and mr_relat.atldat_loc <> " " then
                    print mr_relat.atldat_loc        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.aviestcod is not null and mr_relat.aviestcod <> " " then
                    print mr_relat.aviestcod  using '<<<<<&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.lcvextcod is not null and mr_relat.lcvextcod <> " " then
                    print mr_relat.lcvextcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.aviestnom is not null and mr_relat.aviestnom <> " " then
                    print mr_relat.aviestnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.lcvlojtip is not null and mr_relat.lcvlojtip <> " " then
                    print mr_relat.lcvlojtip  using '<<<<&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print mr_relat.lcvlojdes        clipped, ASCII(09);

                if  mr_relat.desqualific is not null and mr_relat.desqualific <> " " then
                    print mr_relat.desqualific        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endlgd_loj is not null and mr_relat.endlgd_loj <> " " then
                    print mr_relat.endlgd_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endbrr_loj is not null and mr_relat.endbrr_loj <> " " then
                    print mr_relat.endbrr_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endcid_loj is not null and mr_relat.endcid_loj <> " " then
                    print mr_relat.endcid_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.endufd_loj is not null and mr_relat.endufd_loj <> " " then
                    print mr_relat.endufd_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let l_cep_loj = ''
                if  mr_relat.endcep_loj is not null and mr_relat.endcep_loj <> " " then
                    let l_cep_loj = mr_relat.endcep_loj using '<<&&&&&' clipped, '-', mr_relat.endcepcmp_loj using '<&&&' clipped
                    print l_cep_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.refptodes is not null and mr_relat.refptodes <> " " then
                    print mr_relat.refptodes        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.succod is not null and mr_relat.succod <> " " then
                    print mr_relat.succod using '<<<<&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.sucnom is not null and mr_relat.sucnom <> " " then
                    print mr_relat.sucnom clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.dddcod_loj is not null and mr_relat.dddcod_loj <> " " then
                    print mr_relat.dddcod_loj using '<&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.teltxt_loj is not null and mr_relat.teltxt_loj <> " " then

                    print mr_relat.teltxt_loj clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.facnum_loj is not null and mr_relat.facnum_loj <> " " then

                    print mr_relat.facnum_loj clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.horsegsexinc is not null and mr_relat.horsegsexinc <> " " then
                    print mr_relat.horsegsexinc, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.horsegsexfnl is not null and mr_relat.horsegsexfnl <> " " then
                    print mr_relat.horsegsexfnl, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.horsabinc is not null and mr_relat.horsabinc <> " " then
                    print mr_relat.horsabinc, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.horsabfnl is not null and mr_relat.horsabfnl <> " " then
                    print mr_relat.horsabfnl, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.hordominc is not null and mr_relat.hordominc <> " " then
                    print mr_relat.hordominc, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.hordomfnl is not null and mr_relat.hordomfnl <> " " then
                    print mr_relat.hordomfnl, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print mr_relat.lcvregprcdes        clipped, ASCII(09);

                print mr_relat.lojsttdes        clipped, ASCII(09);

                if  mr_relat.cauchqflg is not null and mr_relat.cauchqflg <> " " then
                    print mr_relat.cauchqflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.prtaertaxvlr is not null and mr_relat.prtaertaxvlr <> " " then
                    print mr_relat.prtaertaxvlr using '<<<<<<&.&&' clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.maides_loj is not null and mr_relat.maides_loj <> " " then
                    print mr_relat.maides_loj        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.obs is not null and mr_relat.obs <> " " then
                    print mr_relat.obs        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                print l_clausula        clipped, ASCII(09);

                print l_cidtx        clipped, ASCII(09);
                
                # Pegando os responsáveis pela locadora                
                
                initialize l_aux to null
                initialize l_auxemp to null
                initialize l_auxcpf to null
                initialize l_auxpep to null                
                initialize l_ctdnom to null               
                let l_cpfresp = " "
                let l_pepresp = " "
                let l_respst_a = " "
                let l_resadm = 'A'
                let l_rescon = 'C'
                let l_respro = 'P'
                let l_primeiro = true 
                 
                open  crelat_49  using mr_relat.lcvcod
                		       ,mr_relat.aviestcod
                		       ,l_resadm
                		  
                   foreach crelat_49 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                       
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if 
                      
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if 
                                
                initialize l_aux to null
                initialize l_auxcpf to null
                initialize l_auxpep to null                
                initialize l_ctdnom to null               
                let l_cpfresp = " "
                let l_pepresp = " "
                let l_respst_c = " "
                let l_primeiro = true
                
                open  crelat_49  using mr_relat.lcvcod
                		       ,mr_relat.aviestcod
                		       ,l_rescon
                		  
                   foreach crelat_49 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                       
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if                
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if            
                
                initialize l_aux to null
                initialize l_ctdnom to null
                let l_respst_p = " "                
                let l_primeiro = true
                open  crelat_49  using mr_relat.lcvcod
                		       ,mr_relat.aviestcod
                		       ,l_respro
                		  
                   foreach crelat_49 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if                   
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if  
               
               #Receita bruta 
               
               let l_anobrtoprrctvlr = " "
               
               whenever error continue
                    select anobrtoprrctvlr                         
                     into l_anobrtoprrctvlr                     	  
                     from datkavislocal              
                    where aviestcod = mr_relat.aviestcod
               whenever error stop   

               whenever error continue
                   select cpodes 
                   	into l_cpodes_anobrtrct 
                   	from iddkdominio 
                   where cponom = 'anobrtoprrctvlr' 
                   	and cpocod = l_anobrtoprrctvlr
               whenever error stop           
               
               if sqlca.sqlcode <> 0 then
	            print ' ' clipped, ASCII(09);
	       else
	       	    print l_cpodes_anobrtrct clipped, ASCII(09);	
	       end if 
               
               #Patrimonio liquido
   	       let l_liqptrfxacod = " "
               let l_empcod       = " "
               whenever error continue
                   select liqptrfxacod
                   	  ,cademp 
                     into l_liqptrfxacod
                     	  ,l_empcod
                     from datkavislocal 
                    where aviestcod = mr_relat.aviestcod
               whenever error stop   

               whenever error continue
                   select liqptrfxaincvlr,
		         liqptrfxafnlvlr  
		   into l_liqptrfxaincvlr
		   	,l_liqptrfxafnlvlr 
		    from gsakliqptrfxa                               
		   where empcod       = l_empcod 
		     and liqptrfxacod = l_liqptrfxacod
               whenever error stop           
               
               if sqlca.sqlcode <> 0 then
	            print ' ' clipped, ASCII(09);
	       else 
	            print 'DE 'clipped,l_liqptrfxaincvlr clipped,' ATE 'clipped,l_liqptrfxafnlvlr clipped, ASCII(09);	
	       end if 

	       let l_primeiro = true
	       let l_ciaempcod = null
	       let l_auxemp    = null
               
               open crelat_50 using mr_relat.lcvcod,
               		            mr_relat.aviestcod

               foreach crelat_50 into l_ciaempcod
                                                      
                   if l_primeiro then                      
                     let l_auxemp = l_ciaempcod using '<<<<<'
                     let l_primeiro = false 
                   else                      
                     let l_auxemp = l_auxemp clipped, " ; ", l_ciaempcod using '<<<<<'
                   end if                   
               
               end foreach
                
              if l_auxemp is not null then
              	print l_auxemp clipped, ASCII(09);
              else
              	print 'NAO CADASTRADO' clipped, ASCII(09);
              end if  	       

	      print today #--> FX-080515

end report

#-----------------#
 report relat_pst_txt()
#-----------------#

        define l_aux      	      char(0400),
               l_auxcpf   	      char(0100),
               l_auxpep   	      char(0100),               	
               l_hist     	      char(1000),
               l_grpntz   	      char(0500),
               l_ntz      	      char(0500),
               l_ass      	      char(1000),
               l_srv      	      char(1000),
               l_vig      	      char(1000),
               l_par      	      char(0100),
               l_emp      	      char(0100),
               l_crn      	      char(0100),
               l_primeiro 	      smallint,
               l_data     	      char(010),
               l_resp     	      char(1000),
               l_prtbnfprccod 	  like dparbnfprt.prtbnfprccod,
               l_descricao 	      char(1000),
               l_codbonificacao   smallint,
               l_desbonificacao   char(1000),
               l_respst_a 	      char(1000), 				                  # Administrador da prestadora            
               l_respst_c 	      char(1000), 				                  # Controlador da prestadora
               l_respst_p 	      char(1000), 				                  # Procurador da prestadora
               l_cpfresp  	      char(0100), 				                  # CPF Responsavel
               l_pepresp  	      char(0100), 				                  # PEP Responsavel
               l_anobrtoprrctvlr  like dpaksocor.anobrtoprrctvlr, 	    # Codigo da receita bruta anual
               l_liqptrfxacod     like dpaksocor.liqptrfxacod,  	      # Codigo do patrimonio liquido
               l_empcod           like dpaksocor.empcod,          	    # Codigo da empresa Porto  
               l_cpodes_anobrtrct like iddkdominio.cpodes, 		          # Descricao da receita bruta anual 
               l_liqptrfxaincvlr  like gsakliqptrfxa.liqptrfxaincvlr,   # Descricao inicial do patrimonio liq
	             l_liqptrfxafnlvlr  like gsakliqptrfxa.liqptrfxafnlvlr,   # Descricao final do patrimonio liq  
	             l_resadm 	        char(1),				                      # Sigla do tipo de responsavel Administrador
	             l_rescon 	        char(1),				                      # Sigla do tipo de responsavel Controlador
	             l_respro 	        char(1), 				                      # Sigla do tipo de responsavel Procurador
	             l_renfxaincvlr     like gsakmenrenfxa.renfxaincvlr,      # Valor inicial da faixa de renda mensal do pst pf
               l_renfxafnlvlr     like gsakmenrenfxa.renfxaincvlr,      # Valor final da faixa de renda mensal do pst pf               
               l_pepindcod        like dpakctd.pepindcod,
               l_ctdnom		        like dpakctd.ctdnom,
               l_desend           like iddkdominio.cpodes
	
        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    01

        format

            on every row
                set isolation to dirty read
                #open crelat_02 using mr_relat.pstcoddig
                #fetch crelat_02 into l_aux
                #
                #case sqlca.sqlcode
                #       when 0
                #               let l_hist = " "
                #
                #               foreach crelat_02 into l_aux
                #                       let l_hist = l_hist clipped, " ", l_aux
                #               end foreach
                #       when 100
                #               let l_hist = ' '
                #       otherwise
                #               error 'ERRO BUSCA DE HISTORICO: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                #end case

                open crelat_03 using mr_relat.pstcoddig
                fetch crelat_03 into l_aux 
                
                display "sqlcode crelat_03: ", sqlca.sqlcode

                case sqlca.sqlcode
                        when 0
                                let l_grpntz = " "
                                let l_primeiro = true

                                foreach crelat_03 into l_aux
                                        if  l_primeiro then
                                                let l_grpntz = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_grpntz = l_grpntz clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_grpntz = ' '
                        otherwise
                                error 'ERRO BUSCA DE GRUPO NATUREZA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_41 using mr_relat.pstcoddig
                fetch crelat_41 into l_aux
                 
                display "sqlcode crelat_41: ", sqlca.sqlcode
                 
                case sqlca.sqlcode
                        when 0
                                let l_ntz = " "
                                let l_primeiro = true

                                foreach crelat_41 into l_aux
                                        if  l_primeiro then
                                                let l_ntz = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_ntz = l_ntz clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_ntz = ' '
                        otherwise
                                error 'ERRO BUSCA DE NATUREZA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_04 using mr_relat.pstcoddig
                fetch crelat_04 into l_aux
                
                display "sqlcode crelat_04: ", sqlca.sqlcode
                
                case sqlca.sqlcode
                        when 0
                                let l_par = " "
                                let l_primeiro = true

                                foreach crelat_04 into l_aux
                                        if  l_primeiro then
                                                let l_par = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_par = l_par clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_par = '  '
                        otherwise
                                error 'ERRO BUSCA DE PARAMETRO: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_05 using mr_relat.pstcoddig
                fetch crelat_05 into l_aux

                display "sqlcode crelat_05: ", sqlca.sqlcode

                case sqlca.sqlcode
                        when 0
                                let l_ass = " "
                                let l_primeiro = true

                                foreach crelat_05 into l_aux
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

                open crelat_28 using mr_relat.pstcoddig
                fetch crelat_28 into l_aux
                
                display "sqlcode crelat_28: ", sqlca.sqlcode
                
                case sqlca.sqlcode
                        when 0
                                let l_srv = " "
                                let l_primeiro = true

                                foreach crelat_28 into l_aux
                                        if  l_primeiro then
                                                let l_srv = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_srv = l_srv clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_srv = '  '
                        otherwise
                                error 'ERRO BUSCA DE ASSISTENCIA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_06 using mr_relat.pstcoddig
                fetch crelat_06 into l_aux
                
                display "sqlcode crelat_06: ", sqlca.sqlcode
                
                case sqlca.sqlcode
                        when 0
                                let l_emp = " "
                                let l_primeiro = true

                                foreach crelat_06 into l_aux
                                        if  l_primeiro then
                                                let l_emp = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_emp = l_emp clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_emp = '  '
                        otherwise
                                error 'ERRO BUSCA DE EMPRESA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case

                open crelat_07 using mr_relat.pstcoddig
                fetch crelat_07 into l_aux
                
                display "sqlcode crelat_07: ", sqlca.sqlcode
                
                case sqlca.sqlcode
                        when 0
                                let l_crn = " "
                                let l_primeiro = true

                                foreach crelat_07 into l_aux
                                        if  l_primeiro then
                                                let l_crn = l_aux
                                                let l_primeiro = false
                                        else
                                                let l_crn = l_crn clipped,  "; ",  l_aux
                                        end if
                                end foreach
                        when 100
                                let l_crn = '  '
                        otherwise
                                error 'ERRO BUSCA DE EMPRESA: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                end case
                
                display "mr_relat.pstcoddig: ", mr_relat.pstcoddig
                
                print  mr_relat.pstcoddig     clipped, ASCII(09);

                if  mr_relat.nomgrr is not null and  mr_relat.nomgrr <> " " then
                    print mr_relat.nomgrr        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.nomrazsoc is not null and  mr_relat.nomrazsoc <> " " then
                    print mr_relat.nomrazsoc        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.prssitcod is not null and  mr_relat.prssitcod <> " " then
                    print mr_relat.prssitcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pestip is not null and  mr_relat.pestip <> " " then
                    print mr_relat.pestip        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgcord is null or mr_relat.cgcord = " " then
                    let mr_relat.cgcord = 0
                end if

                if  mr_relat.cgccpfnum is not null and mr_relat.cgccpfnum <> ' ' then
                    if  mr_relat.pestip = 'F' then
                        print mr_relat.cgccpfnum  using '<<<<<<<<<<&'   clipped, '-',
                              mr_relat.cgccpfdig  using '<<<&&' clipped, ASCII(09);
                    else
                        print mr_relat.cgccpfnum   using '<<<<<<<<<<&'   clipped, '/',
                              mr_relat.cgcord      using '<<<<&&&&' clipped, '-',
                              mr_relat.cgccpfdig   using '<<<&&' clipped, ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if


                if  mr_relat.muninsnum is not null and  mr_relat.muninsnum <> " " then
                    print mr_relat.muninsnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if
                
                # PSI-2012-23608PR - TABELA DE FATURAMENTO – TRIBUTOS
                #declare cq_enderecopst2 cursor for                   
                #  select cpocod                                  
                #    from iddkdominio                             
                #   where cponom = 'endtipcod'                    
                #   order by cpocod
                #foreach cq_enderecopst2 into l_desend
                                    
             foreach crelat_51 into l_desend             

                    let mr_relat.endtiplgd = null
                    let mr_relat.endlgd    = null
                    let mr_relat.lgdnum    = null
                    let mr_relat.endcmp    = null
                    let mr_relat.endbrr    = null
                    let mr_relat.endcid    = null
                    let mr_relat.endufd    = null
                    let mr_relat.endcep    = null
                    let mr_relat.endcepcmp = null

                    whenever error continue
                      select lgdtip,         
                             endlgd,         
                             lgdnum,         
                             lgdcmp,         
                             endbrr,         
                             endcid,         
                             ufdsgl,         
                             endcep,         
                             endcepcmp       
                        into mr_relat.endtiplgd,
                             mr_relat.endlgd,
                             mr_relat.lgdnum,
                             mr_relat.endcmp,
                             mr_relat.endbrr,
                             mr_relat.endcid,
                             mr_relat.endufd,
                             mr_relat.endcep,
                             mr_relat.endcepcmp
                        from dpakpstend      
                       where pstcoddig = mr_relat.pstcoddig
                         and endtipcod = l_desend  
                    whenever error stop
                    
                    if  mr_relat.endtiplgd is not null and mr_relat.endtiplgd <> " " then
                        print mr_relat.endtiplgd        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.endlgd is not null and mr_relat.endlgd <> " " then
                        print mr_relat.endlgd        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.lgdnum is not null and mr_relat.lgdnum <> " " then
                        print mr_relat.lgdnum        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.endcmp is not null and mr_relat.endcmp <> " " then
                        print mr_relat.endcmp        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.endbrr is not null and  mr_relat.endbrr <> " " then
                        print mr_relat.endbrr        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.endcid is not null and mr_relat.endcid <> " " then
                        print mr_relat.endcid        clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if
                    
                    if  mr_relat.endufd is not null and  mr_relat.endufd <> " " then
                        print mr_relat.endufd        clipped, ASCII(09);
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

                end foreach
                
 
                if  mr_relat.dddcod is not null and  mr_relat.dddcod <> " " then
                    print mr_relat.dddcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.teltxt is not null and  mr_relat.teltxt <> " " then
                    print mr_relat.teltxt        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.faxnum is not null and  mr_relat.faxnum <> " " then
                    print mr_relat.faxnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.celdddnum is not null and  mr_relat.celdddnum <> " " then
                    print mr_relat.celdddnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.celtelnum is not null and  mr_relat.celtelnum <> " " then
                    print mr_relat.celtelnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pptnom is not null and  mr_relat.pptnom <> " " then
                    print mr_relat.pptnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.rspnom is not null and  mr_relat.rspnom <> " " then
                    print mr_relat.rspnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.socfavnom is not null and  mr_relat.socfavnom <> " " then
                    print mr_relat.socfavnom        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.pestip2 is not null and mr_relat.pestip2 <> " " then
                    print mr_relat.pestip2        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.cgcord2 is null or mr_relat.cgcord2 = " " then
                    let mr_relat.cgcord2 = 0
                end if

                if  mr_relat.cgccpfnum2 is not null and mr_relat.cgccpfnum2 <> ' ' then
                    if  mr_relat.pestip2 = 'F' then
                        print mr_relat.cgccpfnum2  using '<<<<<<<<<<&'   clipped, '-',
                              mr_relat.cgccpfdig2  using '<<<&&' clipped, ASCII(09);
                    else
                        print mr_relat.cgccpfnum2   using '<<<<<<<<<<&'   clipped, '/',
                              mr_relat.cgcord2      using '<<<<&&&&' clipped, '-',
                              mr_relat.cgccpfdig2   using '<<<&&' clipped, ASCII(09);
                    end if
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcoctatip is not null and  mr_relat.bcoctatip <> " " then
                    print mr_relat.bcoctatip        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcocod is not null and  mr_relat.bcocod <> " " then
                    print mr_relat.bcocod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcoagnnum is not null and  mr_relat.bcoagnnum <> " " then
                    print mr_relat.bcoagnnum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcoagndig is not null and  mr_relat.bcoagndig <> " " then
                    print mr_relat.bcoagndig        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcoctanum is not null and  mr_relat.bcoctanum <> " " then
                    print mr_relat.bcoctanum        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.bcoctadig is not null and  mr_relat.bcoctadig <> " " then
                    print mr_relat.bcoctadig        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.socpgtopccod2 is not null and  mr_relat.socpgtopccod2 <> " " then
                    print mr_relat.socpgtopccod2        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.patpprflg is not null and  mr_relat.patpprflg <> " " then
                    print mr_relat.patpprflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.srvnteflg is not null and  mr_relat.srvnteflg <> " " then
                    print mr_relat.srvnteflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.qldgracod is not null and  mr_relat.qldgracod <> " " then
                    print mr_relat.qldgracod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.prscootipcod is not null and  mr_relat.prscootipcod <> " " then
                    print mr_relat.prscootipcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.vlrtabflg is not null and  mr_relat.vlrtabflg <> " " then
                    print mr_relat.vlrtabflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.soctrfcod is not null and  mr_relat.soctrfcod <> " " then
                    print mr_relat.soctrfcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.rmesoctrfcod is not null and  mr_relat.rmesoctrfcod <> " " then
                    print mr_relat.rmesoctrfcod        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                 #if  mr_relat.pstobs is not null and  mr_relat.pstobs <> " " then
                 #    print mr_relat.pstobs        clipped, ASCII(09);
                 #else
                 #    print 'NAO CADASTRADO' , ASCII(09);
                 #end if

                if  mr_relat.intsrvrcbflg is not null and  mr_relat.intsrvrcbflg <> " " then
                    print mr_relat.intsrvrcbflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.risprcflg is not null and  mr_relat.risprcflg <> " " then
                    print mr_relat.risprcflg        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                #if  l_hist is not null and  l_hist <> " " then
                #    print l_hist        clipped, ASCII(09);
                #else
                #    print 'NAO CADASTRADO' , ASCII(09);
                #end if

                if  l_grpntz is not null and  l_grpntz <> " " then
                    print l_grpntz        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_ntz is not null and  l_ntz <> " " then
                    print l_ntz        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_par is not null and  l_par <> " " then
                    print l_par        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_ass is not null and  l_ass <> " " then
                    print l_ass        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_srv is not null and  l_srv <> " " then
                    print l_srv        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_emp is not null and  l_emp <> " " then
                    print l_emp        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  l_crn is not null and  l_crn <> " " then
                    print l_crn        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if  mr_relat.maides is not null and  mr_relat.maides <> " " then
                    print mr_relat.maides        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                #Busca o responsavel - frtrpnflg
                open crelat_24 using mr_relat.frtrpnflg
                fetch crelat_24 into l_resp

                if  l_resp is not null and  l_resp <> " " then
                    print l_resp        clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if
                let l_resp = null
               
                #-----------------------------------------------------|
                # VERIFICA SE EXISTE BINIFICACAO PARA O PRESTADOR     |
                #-----------------------------------------------------|
                  initialize l_descricao to null
                   
                  open crelat_46  using mr_relat.pstcoddig
                  foreach crelat_46 into l_codbonificacao
                     open crelat_47  using l_codbonificacao
                     fetch crelat_47 into l_desbonificacao
                        if l_descricao is not null then
                           let l_descricao = l_descricao clipped,"; ",l_codbonificacao,"-",l_desbonificacao clipped
                        else
                           let l_descricao = l_codbonificacao,"-",l_desbonificacao clipped
                        end if
                     close crelat_47
                     let l_desbonificacao = null
                  end foreach
                  if l_descricao is not null or l_descricao <> " " then
                     print l_descricao clipped, ASCII(09);
                  else 
                     print "NAO CADASTRADO", ASCII(09);
                  end if
                 # Fim do teste bonificação  


                let l_data = extend(mr_relat.cmtdat, year to year ),'-',
                             extend(mr_relat.cmtdat, month to month),'-',
                             extend(mr_relat.cmtdat, day to day)

                print l_data              clipped , ' ', ASCII(09);

                let l_data = extend(mr_relat.atldat, year to year ),'-',
                             extend(mr_relat.atldat, month to month),'-',
                             extend(mr_relat.atldat, day to day)

                print l_data              clipped , ' ', ASCII(09);

                if  mr_relat.pcpatvcod is not null and mr_relat.pcpatvcod > 0 then

                    # BUSCAR DESCRICAO DA ATIVIDADE PRINCIPAL
                    initialize m_dominio.* to null

                    call cty11g00_iddkdominio('pcpatvcod', mr_relat.pcpatvcod)
                        returning m_dominio.*

                    if m_dominio.erro = 1
                       then
                       let mr_relat.pcpatvdes = m_dominio.cpodes clipped
                    else
                       initialize mr_relat.pcpatvdes to null
                       display "Atividade principal: ", m_dominio.mensagem
                    end if

                    if  mr_relat.pcpatvdes is not null and mr_relat.pcpatvcod <> " " then
                        print mr_relat.pcpatvdes clipped, ASCII(09);
                    else
                        print 'NAO CADASTRADO' , ASCII(09);
                    end if

                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                let l_vig = ""
                open  crelat_42  using mr_relat.pstcoddig
                foreach crelat_42 into mr_relat.cntvigincdat,
                                       mr_relat.cntvigfnldat
                    let l_vig = l_vig clipped, mr_relat.cntvigincdat, "-",
                                               mr_relat.cntvigfnldat, "; "
                end foreach

                if  l_vig is not null and l_vig <> " " then
                    print l_vig clipped, ASCII(09);
                else
                    print 'NAO CADASTRADO' , ASCII(09);
                end if

                if mr_relat.succod is not null and
                   mr_relat.succod > 0
                   then
                   print mr_relat.succod, ASCII(09);
                else
                   print 'NAO CADASTRADO', ASCII(09);
                end if

                if mr_relat.pisnum is not null and
                   mr_relat.pisnum > 0
                   then
                   print mr_relat.pisnum, ASCII(09);
                else
                   print 'NAO CADASTRADO', ASCII(09);
                end if

                if mr_relat.simoptpstflg is not null
                   then
                   print mr_relat.simoptpstflg, ASCII(09);
                else
                   print 'NAO CADASTRADO', ASCII(09);
                end if
                
                # Codigo do prestador principal
                initialize l_descricao to null
                if mr_relat.pcpprscod is not null and mr_relat.pcpprscod <> 0
                   then
                    open  crelat_44  using mr_relat.pcpprscod
                    fetch crelat_44 into l_descricao
                   print l_descricao clipped, ASCII(09);
                else
                   print 'NAO CADASTRADO', ASCII(09);
                end if
                
                initialize l_descricao to null
                
                # Codigo da cadeia de gestao
                if mr_relat.gstcdicod is not null and mr_relat.gstcdicod <> 0 then  
                    open  crelat_45  using mr_relat.gstcdicod
                    fetch crelat_45 into l_descricao
                   print l_descricao clipped, ASCII(09);
                else
                   print 'NAO CADASTRADO', ASCII(09);
                end if                
                
                # Pegando os responsáveis pela prestadora                
                initialize l_aux    to null
                initialize l_auxcpf to null
                initialize l_auxpep to null                
                               
                let l_cpfresp = " "
                let l_pepresp = " " 
                let l_respst_a = " "
                let l_resadm = 'A'	# Administrador
                let l_rescon = 'C'	# Controlador
                let l_respro = 'P'	# Procurador
                let l_primeiro = true
                
                
                # Busca Administradores
                open  crelat_48  using mr_relat.pstcoddig ,l_resadm
                		  
                   foreach crelat_48 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if 
                      
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if                 
                   
                                
                initialize l_aux to null
                initialize l_auxcpf to null
                initialize l_auxpep to null                
                               
                let l_cpfresp = " "
                let l_pepresp = " "                 
                let l_respst_c = " "
                let l_primeiro = true
                
                # Busca pelos Controladores
                open  crelat_48  using mr_relat.pstcoddig,l_rescon
                   foreach crelat_48 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if             
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if
                
                
                initialize l_aux to null
                initialize l_auxcpf to null
                initialize l_auxpep to null                
                               
                let l_cpfresp = " "
                let l_pepresp = " "  
                let l_respst_p = " "                
                let l_primeiro = true
                
                #Busca pelos Procuradores
                open  crelat_48  using mr_relat.pstcoddig,l_respro
                   foreach crelat_48 into l_ctdnom
                   			 ,l_auxcpf
                   			 ,l_auxpep                       
                      if l_primeiro then                      
                        let l_aux = l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                        let l_primeiro = false 
                      else                      
                        let l_aux = l_aux clipped, " / ", l_ctdnom clipped, " ; ", l_auxcpf clipped, " ; ", l_auxpep
                      end if                              
                   end foreach
                   
                   if l_aux is not null then
                   	print l_aux clipped, ASCII(09);
                   else
                   	print ' ' clipped, ASCII(09);
                   end if
               #Busca faixa de renda mensal, se for pessoa fisica
               
               if  mr_relat.pestip = 'F' then
	                 whenever error continue                                        
		     	         select renfxaincvlr,          
                                   renfxafnlvlr
                              into l_renfxaincvlr,
                                   l_renfxafnlvlr          
                              from gsakmenrenfxa           
                            where empcod    = 1 
                             and renfxacod = mr_relat.renfxacod                         
                    	   whenever error stop                                        
                    	                                                                  
                    	   if sqlca.sqlcode <> 0 then                                     
	                           print ' ' clipped, ASCII(09);                
	                       else                                                           
	                          case mr_relat.renfxacod
                                when 1
                                   print 'SEM RENDA' clipped, ASCII(09); 
                                when 2
		     	                         print 'ATE 'clipped,l_renfxafnlvlr clipped, ASCII(09);                             	 	
                                otherwise
                                   print 'DE 'clipped,l_renfxaincvlr clipped,' ATE 'clipped,l_renfxafnlvlr clipped, ASCII(09);
                            end case	
	                       end if
	             else
                  print '' clipped, ASCII(09); 
	             end if               
               
               #Busca PEP se o prestador for pessoa física
               
               if mr_relat.pestip = 'F' then
               	 
               	 whenever error continue               	 
	             select a.pepindcod
		     into l_pepindcod
		     from dpakctd a,dparpstctd b
		     where a.ctdcod = b.ctdcod
		     and b.pstcoddig = mr_relat.pstcoddig   
		     
		     if status = notfound then 
		        print '' clipped, ASCII(09);
		     else
		     	print l_pepindcod clipped, ASCII(09);
		     end if               
                 whenever error stop
               else
               	 print '' clipped, ASCII(09);
               end if
               
               #Receita bruta 
	
	       if  mr_relat.pestip = 'J' then
	       	   let l_anobrtoprrctvlr = " "
	           whenever error continue
                       select anobrtoprrctvlr                         
                         into l_anobrtoprrctvlr                     	  
                         from dpaksocor 
                        where pstcoddig = mr_relat.pstcoddig
                   whenever error stop   
	       
               	   whenever error continue                                        
               	      select cpodes                                              
               	       	into l_cpodes_anobrtrct                                 
               	       	from iddkdominio                                        
               	       where cponom = 'anobrtoprrctvlr'                           
               	       	and cpocod = l_anobrtoprrctvlr                          
               	   whenever error stop                                        
               	                                                                  
               	   if sqlca.sqlcode <> 0 then                                     
	       	        print '' clipped, ASCII(09);                
	       	   else                                                           
	       	   	    print l_cpodes_anobrtrct clipped, ASCII(09);	
	       	   end if                                                         
	       else 
	       	   print '' clipped, ASCII(09); #--> FX-080515   
	       end if  	        
	        
                
               #Patrimonio liquido
   	       let l_liqptrfxacod = " "
               let l_empcod       = " "
               whenever error continue
                 select liqptrfxacod                   	  
                 into   l_liqptrfxacod                     	  
                 from   dpaksocor 
                 where  pstcoddig = mr_relat.pstcoddig
               whenever error stop   
                             
	       if l_liqptrfxacod is not null then 
               whenever error continue                                      
                   select liqptrfxaincvlr,
		          liqptrfxafnlvlr  
		   into   l_liqptrfxaincvlr
		   	 ,l_liqptrfxafnlvlr 
		   from   gsakliqptrfxa                               
		   where liqptrfxacod = l_liqptrfxacod
               whenever error stop           
               if sqlca.sqlcode <> 0 then
	            print '' clipped, ASCII(09);
	       else 
	            print 'DE 'clipped,l_liqptrfxaincvlr clipped,' ATE 'clipped,l_liqptrfxafnlvlr clipped, ASCII(09);
	       end if 
               
               else 
               print '' clipped, ASCII(09);
               
               end if
               
               print today #--> 080515
                
 end report     
                
#-----------------#
 report relat_srr_txt()
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
               l_hst             char(9000),
               l_primeiro        smallint,
               l_count           integer

        define l_socvidseg  char(1) # Saber se tem ou nao seguro de vida

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    01

        format

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

                #--> PSI-21950 - Inicio
                if mr_relat.prssitcod = 2 then
                   let mr_relat.prssitdes = mr_relat.prssitdes clipped, "/",
                                            cty38g00_motivo(mr_relat.srrcoddig)
                end if
                #--> PSI-21950 - Final

                let l_aux = 'estcvlcod'
                open crelat_15 using l_aux,
                                     mr_relat.estcvlcod
                fetch crelat_15 into mr_relat.estcvldes

                let l_aux = 'srrtip'
                open crelat_15 using l_aux,
                                     mr_relat.srrtip
                fetch crelat_15 into mr_relat.srrtipdes

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

                let l_hst = " "
                { open crelat_26 using mr_relat.srrcoddig
                 fetch crelat_26 into l_aux

                 case sqlca.sqlcode
                        when 0
                                let l_hst = " "
                                let l_primeiro = true

                                foreach crelat_26 into l_aux
                                        if  l_primeiro then
                                                let l_hst = l_aux
                                                let l_primeiro = false
                                                let l_count = 1
                                        else
                                                let l_hst = l_hst clipped,  "; ",  l_aux
                                                let l_count = l_count + 1
                                        end if

                                        if l_count >= 50 then
                                                exit foreach
                                        end if
                                end foreach
                        when 100
                                let l_ass = '  '
                        otherwise
                                error 'ERRO BUSCA DO HISTORICO: ', sqlca.sqlcode, ' CONTATE A INFORMATICA'
                 end case

                 if  l_hst is not null and l_hst <> " " then
                 print l_hst        clipped, ASCII(09);
                 else
                     print 'NAO CADASTRADO' , ASCII(09);
                 end if}

                 # APENAS VERIFICA SERVICO DE CPF VALIDO
                 if mr_relat.cgccpfnum is null then
                       let l_socvidseg = 'NAO'
                       print  l_socvidseg       clipped, ASCII(09);
                 else
                    initialize mrv_bdbsr510Vida.* to null
                    call ovgea017(0,
                                  0,
                                  mr_relat.cgccpfnum,
                                  0,
                                  mr_relat.cgccpfdig,
                                  6)
                        returning mrv_bdbsr510Vida.critica1,
                                  mrv_bdbsr510Vida.critica2,
                                  mrv_bdbsr510Vida.critica3,
                                  mrv_bdbsr510Vida.critica4,
                                  mrv_bdbsr510Vida.critica5,
                                  mrv_bdbsr510Vida.critica6,
                                  mrv_bdbsr510Vida.critica7

                    if mrv_bdbsr510Vida.critica1 is null and
                       mrv_bdbsr510Vida.critica2 is null and
                       mrv_bdbsr510Vida.critica3 is null and
                       mrv_bdbsr510Vida.critica4 is null and
                       mrv_bdbsr510Vida.critica5 is null and
                       mrv_bdbsr510Vida.critica6 is null and
                       mrv_bdbsr510Vida.critica7 is null then
                       let l_socvidseg = 'NAO'
                       print  l_socvidseg       clipped, ASCII(09);
                    else
                       let l_socvidseg = 'SIM'
                       print  l_socvidseg       clipped, ASCII(09);
                    end if
                 end if

                ## call fvdgc308(mr_relat.cgccpfnum,mr_relat.cgccpfdig,current)
                ##                     returning l_fvdgc308.coderro,
                ##                               l_fvdgc308.msgerro,
                ##                               l_fvdgc308.valorbas,
                ##                               l_fvdgc308.valoripd,
                ##                               l_fvdgc308.valoripa,
                ##                               l_fvdgc308.valormap
                ##if(l_fvdgc308.coderro == 4) then
                ##        let l_fvdgc308.socvidseg = "NAO"
                ##        print  l_fvdgc308.socvidseg        clipped, ASCII(09)
                ##else
                ##        let l_fvdgc308.socvidseg = "SIM"
                ##        print  l_fvdgc308.socvidseg        clipped, ASCII(09)
                ##end if
                #print l_hst        clipped, ASCII(09);

                print today  #--> 080515

 end report