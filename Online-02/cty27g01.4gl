#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: Central 24hs                                               #
# Modulo.........: cty27g01.4gl                                               #
# Analista Resp..: Amilton Lourenco                                           #
# PSI............: PSI-2012-22101                                             #
# Objetivo.......: Acionamento Cobrança e Porto Socorro                       #
# ........................................................................... #
# Desenvolvimento: Kleiton Nascimento                                         #
# Liberacao......: 04/01/2013                                                 #
#=============================================================================#
#                 * * * A L T E R A C A O * * *                               #
#.............................................................................#
#  Data      Autor Fabrica     Alteracao                                      #
#-----------------------------------------------------------------------------#
# 30/01/2013 Alberto CDS-EGEU  Ajuste nos parametros,Vld Cartao,ngcidttipcod, #
#                              eltfisnotnum, vctdat                           #
#-----------------------------------------------------------------------------#
# 20/08/2013 Alberto Madeira   Ajuste para chamada da funcao,passando o tipo  #
#                              de pessoa correta(PF/PJ)                       #
#-----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"
database porto

define m_prepsql smallint

#--------------------------
function cty27g01_prepare()
#--------------------------
   define l_sql char(500)

   let l_sql = "select orgnum, prpnum, pgtfrmcod "
              ,"from datmpgtinf                  "
              ,"where atdsrvnum = ?              "
              ,"and atdsrvano = ?                "
   prepare p_cty27g01_001 from l_sql
   declare c_cty27g01_001 cursor for p_cty27g01_001

   let l_sql = " select crtnum, crtvlddat, clinom, bndcod "
              ," from datmcrdcrtinf                       "
              ," where orgnum = ?                         "
              ," and prpnum = ?                           "
              ," and pgtseqnum = (select max(pgtseqnum)   "
              ," from datmcrdcrtinf a                     "
              ," where a.orgnum = ?                       "
              ," and prpnum = ?)                          "
   prepare p_cty27g01_002 from l_sql
   declare c_cty27g01_002 cursor for p_cty27g01_002

   let l_sql = " select a.cgccpfnum, a.cgcord, a.cgccpfdig "
              ," from datrligcgccpf a, datmligacao b       "
              ," where a.lignum = b.lignum                 "
              ," and b.atdsrvnum = ?                       "
              ," and b.atdsrvano = ?                       "
   prepare p_cty27g01_003 from l_sql
   declare c_cty27g01_003 cursor for p_cty27g01_003

   let l_sql = " insert into datmefutrn                    "
              ," (atdsrvnum, atdsrvano, pgtfrmcod, cbrvlr, "
              ,"  cbrparqtd, prsvlr, trnsttcod, atldat)    "
              ," values  (?,?,?,?,?,?,?, today)            "
   prepare p_cty27g01_004 from l_sql

   #let l_sql = " insert into datmtrnnsu                   "
   #           ," (atdsrvnum, atdsrvano, nsunum) values    "
   #           ," (?,?,?)                                  "
   #prepare p_cty27g01_005 from l_sql

   let l_sql = " insert into datmtrnerrmsg                "
              ," (atdsrvnum, atdsrvano, trnerrmsgtxt)     "
              ," values (?,?,?)                           "
   prepare p_cty27g01_006 from l_sql

   let l_sql = " insert into datmtit (atdsrvnum, atdsrvano, "
              ," titseqnum, titnum, titsitnum)              "
              ," values (?,?,?,?,?)                         "
   prepare p_cty27g01_007 from l_sql

   let l_sql = " select max(titseqnum) from  datmtit       "
              ," where atdsrvnum =?                        "
              ," and atdsrvano = ?                         "
   prepare p_cty27g01_008 from l_sql
   declare c_cty27g01_004 cursor for p_cty27g01_008

   let l_sql = " select titnum from  datmtit               "
              ," where atdsrvnum =?                        "
              ," and atdsrvano = ?                         "
              ," order by titseqnum                        "
   prepare p_cty27g01_009 from l_sql
   declare c_cty27g01_005 cursor for p_cty27g01_009

   let l_sql = " update datmtit set titsitnum = 2           "
              ," where atdsrvnum =?                         "
              ," and atdsrvano = ?                          "
              ," and titnum = ?                             "
   prepare p_cty27g01_010 from l_sql

   let l_sql = " select 1             "
              ," from   datmefutrn    " 
              ," where  atdsrvnum = ? "
              ," and    atdsrvano = ? "
   prepare p_cty27g01_011 from l_sql               
   declare c_cty27g01_006 cursor for p_cty27g01_011

   let m_prepsql = true

end function

#--------------------------
function cty27g01(lr_param)
#--------------------------

define lr_param record
       atdsrvnum   like datmservico.atdsrvnum,
       atdsrvano   like datmservico.atdsrvano,
       cbrvlr      like datmefutrn.cbrvlr,
       prsvlr      like datmefutrn.prsvlr,
       cbrparqtd   like datmefutrn.cbrparqtd
end record

define lr_retorno record
       codigo      smallint,
       mensagem    char(300)
end record

define lr_retAutoriza record
       codigo      smallint,
       mensagem    char(300)
end record


define lr_pagamento record
       orgnum      like datmpgtinf.orgnum,
       prpnum      like datmpgtinf.prpnum,
       pgtfrmcod   like datmpgtinf.pgtfrmcod
end record

define lr_cartao record
       crtnum      like datmcrdcrtinf.crtnum,
       crtvlddat   like datmcrdcrtinf.crtvlddat,
       clinom      like datmcrdcrtinf.clinom,
       bndcod      like datmcrdcrtinf.bndcod
end record

define l_cartaoCripto like fcomcaraut.pcapticod

define lr_autoriza record
       operacao         char(50)
      ,empcod           like gtakmodal.empcod
      ,ramcod           like gtakmodal.ramcod
      ,rmemdlcod        like gtakmodal.rmemdlcod
      ,titnumdig        like fctmtitulos.titnumdig
      ,vssnum           like fctmpgttrnhst.vssnum
      ,dscsac           like fctmpgttrnhst.dscsac
      ,usridn           char(255)
      ,prporg           like fcomcaraut.prporg
      ,prpnumdig        like fcomcaraut.prpnumdig
      ,ramgrpcod        like fcomcaraut.ramgrpcod
      ,pgtfrm           like fctmdct.pgtfrm
      ,debvlr           decimal(10,2)
      ,pcapticod        like fcomcaraut.pcapticod
      ,carvlddat        char(4)
      ,acao             smallint
      ,viginc           date
      ,parnum           like fcomcaraut.parnum
      ,parqtd           decimal(2,0)
      ,vlrtotal         decimal(10,2)
      ,pednum           like fctmpgttrnhst.pednum
      ,trnstt           like fctmpgttrnhst.trnstt
      ,rcbbcocod        like fctmpag.rcbbcocod
      ,corsus           char(6)
      ,cgccpfnum        decimal(12,0)
      ,cgcord           decimal(4,0)
      ,cgccpfdig        decimal(2,0)
end record

define lr_geraTitulo record
       ngctipcod     	like fctktipngc.ngctipcod
      ,corsus        	like gcaksusep.corsus
      ,segnom        	like fctmproponente.segnom
      ,pestip        	like fctmproponente.pestip
      ,cgccpfnum 	like fctmproponente.cgccpfnum
      ,cgcord        	like fctmproponente.cgcord
      ,cgccpfdig     	like fctmproponente.cgccpfdig
      ,endcep        	like fctmproponente.endcep
      ,endcepcmp     	like fctmproponente.endcepcmp
      ,endlgd        	like fctmproponente.endlgd
      ,endnum        	like fctmproponente.endnum
      ,endcmp        	like fctmproponente.endcmp
      ,endbrr        	like fctmproponente.endbrr
      ,endcid        	like fctmproponente.endcid
      ,endufd        	like fctmproponente.endufd
      ,dddnum        	like fctmproponente.dddnum
      ,telnum        	like fctmproponente.telnum
      ,telrmlnum     	like fctmproponente.telrmlnum
      ,maides        	like fctmproponente.maides
      ,ngcidttipcod  	like fctmnegocio.ngcidttipcod
      ,vossonum      	like fctmnegocio.vossonum
      ,prporg        	like fctmnegocio.prporg
      ,prpnumdig        like fctmnegocio.prpnumdig
      ,succod        	like fctmnegocio.succod
      ,ramcod        	like fctmnegocio.ramcod
      ,aplnumdig     	like fctmnegocio.aplnumdig
      ,edsnumdig     	like fctmnegocio.edsnumdig
      ,parnum        	like fctmnegocio.parnum
      ,parvlr        	like pemmctmfpg.parvlr
      ,pgtmtvdsc     	like fctmnegocio.pgtmtvdsc
      ,cobtip       	like fctmtitulos.cobtip
      ,bltemstip     	like fctmnegocio.bltemstip
      ,bltemsslcorg  	like fctmnegocio.bltemsslcorg
      ,usridn        	like fctmnegocio.usridn
      ,pgtfrm        	like fctmnegocio.pgtfrm
      ,parqtd        	like fctmnegocio.parqtd
      ,vctdat        	like fctmtitulos.vctdat
      ,iofvlr        	like fctmtitulos.iofvlr
      ,parmda        	like fctmtitulos.parmda
      ,empcod        	like fctrpevparc.empcod
      ,sbttipcod     	like fctkgeral.grlchv
      ,eltfisnotnum  	like fctmcbrtitagp.eltfisnotnum
end record

define lr_retGeraTitulo record
        coderro     smallint
       ,msgerro     char(100)
       ,titnumdig   decimal(10,0)
       ,path_boleto char(75)
       ,nome_boleto char(20)
end record

define lr_portoSocorro record
       atdsrvnum       like datmservico.atdsrvnum,
       atdsrvano       like datmservico.atdsrvano,
       vlracrct24      like dbsmsrvacr.incvlr
end record

define lr_retPortoSocorro record
     codigo   smallint,
     mensagem char(100)
end record

define lr_datmefutrn record
       atdsrvnum      like datmefutrn.atdsrvnum,
       atdsrvano      like datmefutrn.atdsrvano,
       pgtfrmcod      like datmefutrn.pgtfrmcod,
       cbrvlr         like datmefutrn.cbrvlr,
       cbrparqtd      like datmefutrn.cbrparqtd,
       prsvlr         like datmefutrn.prsvlr,
       trnsttcod      like datmefutrn.trnsttcod
end record

define lr_retcripto record
       coderro      smallint
      ,msgerro      char(10000)
      ,pcapticrpcod like fcomcaraut.pcapticrpcod
end record

define n_cartao      decimal(19,0)
define l_vldcrt      char(10)
define l_ind         integer
define l_cont        integer
define l_titseqnum   integer
define l_titseqnumaux integer
define l_titnum      decimal(10,0)
define l_retCancel   char(50)
define l_titsitnum   integer
define l_consite_pa  smallint
#-----------------------------------------------
define lr_param_sitef record
       prporg         like fcomcaraut.prporg     # lr_geraTitulo.prporg
      ,prpnumdig      like fcomcaraut.prpnumdig  # lr_geraTitulo.prpnumdig
      ,empcod         like fcpmctbtrn.empcod     # lr_geraTitulo.succod
      ,ramcod         like fcpmctbtrn.ramcod     # lr_geraTitulo.ramcod
      ,rmemdlcod      like fcpmctbtrn.rmemdlcod  # lr_autoriza.rmemdlcod
      ,corsus         like fcpmctbtrn.corsus     # lr_geraTitulo.corsus
      ,cgccpfnum      like gsakseg.cgccpfnum     # lr_geraTitulo.cgccpfnum
      ,cgcord         like gsakseg.cgcord        # lr_geraTitulo.cgcord
      ,cgccpfdig      like gsakseg.cgccpfdig     # lr_geraTitulo.cgccpfdig
      ,pcapticod      like fcomcaraut.pcapticod  # lr_autoriza.pcapticod
      ,pgtfrm         like fctmdct.pgtfrm        # lr_autoriza.pgtfrm
end record

define lr_ret_sitef   record
       errocod        smallint
      ,errodesc       varchar(80)
      ,codsitef       smallint
      ,carautnum      like fcomcaraut.carautnum
      ,carautdat      like fcomcaraut.carautdat
end record
#-----------------------------------------------
   initialize lr_param_sitef.* to null
   initialize lr_ret_sitef.* to null
   initialize lr_retcripto.* to null
   initialize lr_autoriza.* to null
   initialize lr_retAutoriza.* to null
   initialize lr_retorno.* to null
   initialize lr_pagamento.* to null
   initialize lr_cartao.* to null
   initialize lr_geraTitulo.* to null
   initialize lr_retGeraTitulo.* to null
   initialize lr_portoSocorro.* to null
   initialize lr_retPortoSocorro.* to null
   initialize lr_datmefutrn.* to null
   initialize l_ind to null
   initialize l_vldcrt to null
   initialize l_consite_pa to null 
   let lr_retorno.codigo = 0 using '&'
   let lr_retorno.mensagem = 'OK'
   if g_issk.empcod = 43 and
      g_issk.funmat = 3029 then
         display "<309> cty27g01->  Inicio.... "
   end if
   if m_prepsql is null or
      m_prepsql <> true then
      call cty27g01_prepare()
   end if

   ##Realiza acerto com Porto Socorro
   let lr_portoSocorro.atdsrvnum  = lr_param.atdsrvnum
   let lr_portoSocorro.atdsrvano  = lr_param.atdsrvano
   let lr_portoSocorro.vlracrct24 = lr_param.prsvlr
   if g_issk.empcod = 43 and
      g_issk.funmat = 3029 then
         display "<319> cty27g01-> Chamando  ctx36g00_acerto ...  "
   end if
   call ctx36g00_acerto(lr_portoSocorro.*)
     returning lr_retPortoSocorro.codigo,
               lr_retPortoSocorro.mensagem
   if g_issk.empcod = 43 and
      g_issk.funmat = 3029 then
       display "<323>Retorno porto socorro-> ctx36g00_acerto"
       display "<324>lr_retPortoSocorro.codigo   = ",lr_retPortoSocorro.codigo
       display "<325>lr_retPortoSocorro.mensagem = ",lr_retPortoSocorro.mensagem
   end if

   if lr_retPortoSocorro.codigo <> 0 then
      let lr_retorno.mensagem = lr_retPortoSocorro.mensagem
      let lr_retorno.codigo = 1 using '&'
      return lr_retorno.codigo,lr_retorno.mensagem
   end if
   whenever error continue

   if g_issk.empcod = 43 and
      g_issk.funmat = 3029 then
         display "<333> Busca forma de pagamento associada ao atendimento <",lr_param.atdsrvnum,"-",lr_param.atdsrvano,">"
   end if
   ##Busca forma de pagamento associada ao atendimento
   open c_cty27g01_001 using lr_param.atdsrvnum,
                             lr_param.atdsrvano

   #whenever error continue
   fetch c_cty27g01_001 into lr_pagamento.orgnum
                            ,lr_pagamento.prpnum
                            ,lr_pagamento.pgtfrmcod
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode <> notfound then
        let lr_retorno.mensagem = 'Erro SELECT c_cty27g01_001 / ', sqlca.sqlcode
        let lr_retorno.codigo = 1 using '&'

        return lr_retorno.codigo,lr_retorno.mensagem
      end if
   end if
   if g_issk.empcod = 43 and
      g_issk.funmat = 3029 then
      display "<352> Forma de Pagamento <",lr_pagamento.pgtfrmcod,">"
   end if
   let l_consite_pa = 0
   # Consistencia solicitada pelo Ronald, onde Willian devera desabilitar o botao encerrar para nao haver duplicidade.
   if lr_pagamento.pgtfrmcod = 1 then
      whenever error continue
      open c_cty27g01_006 using  lr_param.atdsrvnum
                                ,lr_param.atdsrvano
      fetch c_cty27g01_006 into  l_consite_pa
      whenever error stop
      if sqlca.sqlcode <> 100 then
         let lr_retorno.codigo   = 0 
         let lr_retorno.mensagem = "Processo ja efetuado !"
         return lr_retorno.codigo, lr_retorno.mensagem
      end if
   end if   

   ##Busca dados do cartão caso a forma de pagamento seja Cartao Outras Bandeiras
   if lr_pagamento.pgtfrmcod = 1 then

        open c_cty27g01_002 using lr_pagamento.orgnum
                                 ,lr_pagamento.prpnum
                                 ,lr_pagamento.orgnum
                                 ,lr_pagamento.prpnum

        whenever error continue
        fetch c_cty27g01_002 into lr_cartao.crtnum
                                 ,lr_cartao.crtvlddat
                                 ,lr_cartao.clinom
                                 ,lr_cartao.bndcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode <> notfound then
             let lr_retorno.mensagem = 'Erro SELECT c_cty27g01_002 / ', sqlca.sqlcode
             let lr_retorno.codigo = 1 using '&'

             return lr_retorno.codigo,lr_retorno.mensagem
           end if
        end if

        ##Descriptografa o numero do cartao
        initialize lr_retcripto.* to null
        initialize l_cartaoCripto, n_cartao to null

        call ffctc890("D",lr_cartao.crtnum )
             returning lr_retcripto.*
        let n_cartao       = lr_retcripto.pcapticrpcod
        let l_cartaoCripto = n_cartao
        let l_vldcrt       = lr_cartao.crtvlddat

        ###Aciona Autorização Cartão SITEF##
        let lr_autoriza.operacao   = "pagamentoCartaoOnline"
        let lr_autoriza.empcod     = 43
        let lr_autoriza.ramcod     = 0
        let lr_autoriza.rmemdlcod  = 0
        let lr_autoriza.ramgrpcod  = 5
        let lr_autoriza.pgtfrm     = 62
        let lr_autoriza.acao       = 1
        let lr_autoriza.prporg     = lr_pagamento.orgnum
        let lr_autoriza.prpnumdig  = lr_pagamento.prpnum
        let lr_autoriza.debvlr     = 0
        let lr_autoriza.vlrtotal   = lr_param.cbrvlr
        let lr_autoriza.pcapticod  = l_cartaoCripto
        let lr_autoriza.carvlddat  = l_vldcrt[4,5],l_vldcrt[9,10] # lr_cartao.crtvlddat
        let lr_autoriza.parnum     = 1
        let lr_autoriza.parqtd     = lr_param.cbrparqtd
        let lr_autoriza.corsus     = '000000'
        let lr_geraTitulo.succod   = 0

        if g_issk.empcod = 43 and
           g_issk.funmat = 3029 then
           display "<421> AUTORIZA.prporg= ",lr_autoriza.prporg
           display "<422> AUTORIZA.prpnumdig= ",lr_autoriza.prpnumdig
           display "<423> AUTORIZA.vlrtotal= ",lr_autoriza.vlrtotal
           display "<424> AUTORIZA.cartaoCripto= ",lr_autoriza.pcapticod
           display "<425> AUTORIZA.carvlddat= ",lr_autoriza.carvlddat
           display "<426> AUTORIZA.cbrparqtd= ",lr_autoriza.parqtd
        end if
        whenever error continue
        open c_cty27g01_003 using  lr_param.atdsrvnum
                                  ,lr_param.atdsrvano
        fetch c_cty27g01_003 into  lr_geraTitulo.cgccpfnum
                                  ,lr_geraTitulo.cgcord
                                  ,lr_geraTitulo.cgccpfdig
        whenever error stop
        if lr_geraTitulo.cgcord <> 0 then 
           let lr_geraTitulo.pestip = 'J' 
        end if                            
        if sqlca.sqlcode <> 0 then
           let lr_geraTitulo.cgccpfnum = 0
           let lr_geraTitulo.cgcord    = 0
           let lr_geraTitulo.cgccpfdig = 0
        end if
        if g_issk.empcod = 43 and           
           g_issk.funmat = 3029 then        
              display "<442> CGC/CPF ->> ", lr_geraTitulo.cgccpfnum,"/",lr_geraTitulo.cgcord,"-",lr_geraTitulo.cgccpfdig
        end if
        for l_cont = 1 to 2
             call ffcta908_autoriza_cartao(lr_autoriza.*)
                  returning lr_retAutoriza.mensagem
                           ,lr_retAutoriza.codigo
             let lr_retAutoriza.codigo = lr_retAutoriza.codigo using '&'
             if g_issk.empcod = 43 and   
                g_issk.funmat = 3029 then
                   display "<448> AUTORIZA.mensagem= ",lr_retAutoriza.mensagem clipped
                   display "<449> AUTORIZA.codigo= ",lr_retAutoriza.codigo
             end if
             if lr_retAutoriza.codigo = 0 then
               exit for
             end if
        end for


        if lr_retAutoriza.codigo = 0 then
             ##Consulta status da autorização do SITEF
             if g_issk.empcod = 43 and   
                g_issk.funmat = 3029 then
                   display "<458> Consulta status da autorização do SITEF"
             end if
             for l_cont = 1 to 2
             if g_issk.empcod = 43 and       
                g_issk.funmat = 3029 then    
                 display "<460> CONSULTA.prporg    = ",lr_autoriza.prporg
                 display "<461> CONSULTA.prpnumdig = ",lr_autoriza.prpnumdig
                 display "<462> CONSULTA.succod    = ",lr_geraTitulo.succod
                 display "<463> CONSULTA.ramcod    = ",lr_autoriza.ramcod
                 display "<464> CONSULTA.rmemdlcod = ",lr_autoriza.rmemdlcod
                 display "<465> CONSULTA.corsus    = ",lr_autoriza.corsus
                 display "<466> CONSULTA.cgccpfnum = ",lr_geraTitulo.cgccpfnum
                 display "<467> CONSULTA.cgcord    = ",lr_geraTitulo.cgcord
                 display "<468> CONSULTA.cgccpfdig = ",lr_geraTitulo.cgccpfdig
                 display "<469> CONSULTA.pcapticod = ",lr_autoriza.pcapticod
                 display "<470> CONSULTA.pgtfrm    = ",lr_autoriza.pgtfrm
                 display "<471> Tipo de Pessoa     = ",lr_geraTitulo.pestip
             end if
                 call ffcoc001_consautorizado2( lr_autoriza.prporg  # Obrigatório
                                              ,lr_autoriza.prpnumdig # Obrigatório
                                              ,lr_geraTitulo.succod
                                              ,lr_autoriza.ramcod
                                              ,lr_autoriza.rmemdlcod
                                              ,lr_autoriza.corsus
                                              ,lr_geraTitulo.cgccpfnum
                                              ,lr_geraTitulo.cgcord
                                              ,lr_geraTitulo.cgccpfdig
                                              ,lr_autoriza.pcapticod
                                              ,lr_autoriza.pgtfrm )    # Obrigatório
                      returning lr_ret_sitef.errocod,
                                lr_ret_sitef.errodesc,
                                lr_ret_sitef.codsitef,
                                lr_ret_sitef.carautnum,
                                lr_ret_sitef.carautdat
                 if g_issk.empcod = 43 and   
                    g_issk.funmat = 3029 then
                       display "<488> CONSULTA.errocod= ",lr_ret_sitef.errocod
                       display "<489> CONSULTA.errodesc= ",lr_ret_sitef.errodesc
                       display "<490> CONSULTA.FIM"
                 end if
                 if lr_ret_sitef.errocod = 0 then
                   if g_issk.empcod = 43 and   
                      g_issk.funmat = 3029 then
                         display "CONSULTA.EXIT"
                   end if
                   exit for
                 else
                    if g_issk.empcod = 43 and   
                       g_issk.funmat = 3029 then
                          display "<495> Erro:",lr_ret_sitef.errocod,"-", lr_ret_sitef.errodesc sleep 2
                    end if
                    continue for
                 end if
             end for
        end if
        let lr_datmefutrn.atdsrvnum = lr_param.atdsrvnum
        let lr_datmefutrn.atdsrvano = lr_param.atdsrvano
        let lr_datmefutrn.pgtfrmcod = lr_pagamento.pgtfrmcod
        let lr_datmefutrn.cbrvlr    = lr_param.cbrvlr
        let lr_datmefutrn.cbrparqtd = lr_param.cbrparqtd
        let lr_datmefutrn.prsvlr    = lr_param.prsvlr
        if lr_pagamento.pgtfrmcod <> 1 then
           let lr_datmefutrn.trnsttcod = 3
        else
            if lr_retAutoriza.codigo = 0 and
               lr_ret_sitef.errocod = 0 then
                let lr_datmefutrn.trnsttcod = 1
            else
                let lr_datmefutrn.trnsttcod = 2
            end if
        end if
        whenever error continue
        execute p_cty27g01_004 using lr_datmefutrn.atdsrvnum,
                                     lr_datmefutrn.atdsrvano,
                                     lr_datmefutrn.pgtfrmcod,
                                     lr_datmefutrn.cbrvlr,
                                     lr_datmefutrn.cbrparqtd,
                                     lr_datmefutrn.prsvlr,
                                     lr_datmefutrn.trnsttcod
        whenever error stop
        if sqlca.sqlcode <> 0 then
           let lr_retorno.mensagem = 'Erro INSERT p_cty27g01_004 / ', sqlca.sqlcode
           let lr_retorno.codigo = 1  using '&'
           return lr_retorno.codigo,lr_retorno.mensagem
        end if
        #Grava motivo do erro na autorizacao ou consulta sitef
        if lr_retAutoriza.codigo <> 0 then
           if g_issk.empcod = 43 and   
              g_issk.funmat = 3029 then
                 display "<532> cty27g01-> Erro .......................... <" , sqlca.sqlcode , "><",lr_retorno.codigo,">" sleep 2
           end if 
          whenever error continue
             execute p_cty27g01_006 using lr_datmefutrn.atdsrvnum,
                                          lr_datmefutrn.atdsrvano,
                                          lr_retAutoriza.mensagem
          whenever error stop

          if sqlca.sqlcode <> 0 then
                let lr_retorno.mensagem = 'Erro INSERT p_cty27g01_006 / ', sqlca.sqlcode
                let lr_retorno.codigo = 1  using '&'
                return lr_retorno.codigo,lr_retorno.mensagem
          end if

        else

          if lr_ret_sitef.errocod <> 0 then
               whenever error continue
                  execute p_cty27g01_006 using lr_datmefutrn.atdsrvnum,
                                               lr_datmefutrn.atdsrvano,
                                               lr_ret_sitef.errodesc
               whenever error stop

               if sqlca.sqlcode <> 0 then
                     let lr_retorno.mensagem = 'Erro INSERT p_cty27g01_006 / ', sqlca.sqlcode
                     let lr_retorno.codigo = 1  using '&'
                     return lr_retorno.codigo,lr_retorno.mensagem
               end if
          end if
        end if

        if lr_ret_sitef.errocod = 0 then
           let lr_geraTitulo.ngctipcod    = 22 -- 24 -- 22
           let lr_geraTitulo.ngcidttipcod = 1 # Solicitado por Karina para testes.
           let lr_geraTitulo.eltfisnotnum = 0 # Solicitado por Daniel/Mayra para testes.
           let lr_geraTitulo.pgtfrm       = lr_autoriza.pgtfrm # Solicitado por Karina. Estamos gravando na Tabela (datmpgtinf) = 1
           let lr_geraTitulo.segnom       = lr_cartao.clinom
           let lr_geraTitulo.pestip       = 'F'
           if lr_geraTitulo.cgcord <> 0 then 
              let lr_geraTitulo.pestip = 'J' 
           end if                                       
           let lr_geraTitulo.prporg       = lr_pagamento.orgnum
           let lr_geraTitulo.prpnumdig    = lr_pagamento.prpnum
           let lr_geraTitulo.parvlr       = lr_param.cbrvlr/lr_param.cbrparqtd
           let lr_geraTitulo.vctdat       = today # Solicitado por Karina
           if lr_cartao.bndcod = 4 then  # VISA cobtip = 33
              let lr_geraTitulo.cobtip = 33
           else
              if lr_cartao.bndcod = 5 then # MASTERCARD cobtip = 35
                 let lr_geraTitulo.cobtip = 35
              end if
           end if
           for l_ind = 1 to lr_param.cbrparqtd
                let lr_geraTitulo.parnum = l_ind
                let l_titseqnum = l_ind
                for l_cont = 1 to 2
                     if g_issk.empcod = 43 and   
                        g_issk.funmat = 3029 then
                           display "<587> GERA_TITULO. ACIONANDO_FUNCAO"
                     end if
                     call ffcta471_emitir_cobranca2(lr_geraTitulo.*)
                          returning  lr_retGeraTitulo.coderro
                                    ,lr_retGeraTitulo.msgerro
                                    ,lr_retGeraTitulo.titnumdig
                                    ,lr_retGeraTitulo.path_boleto
                                    ,lr_retGeraTitulo.nome_boleto
                     if g_issk.empcod = 43 and   
                        g_issk.funmat = 3029 then
                           display "<594> GERA_TITULO.coderro= ", lr_retGeraTitulo.coderro
                           display "<595> GERA_TITULO.titnumdig= ",lr_retGeraTitulo.titnumdig
                     end if
                     if lr_retGeraTitulo.coderro = 0 then
                         whenever error continue
                            let l_titsitnum = 1
                            if g_issk.empcod = 43 and   
                               g_issk.funmat = 3029 then
                                  display "<599> GERA_TITULO.atdsrvnum= ",lr_param.atdsrvnum
                                  display "<600> GERA_TITULO.atdsrvano= ",lr_param.atdsrvano
                                  display "<601> GERA_TITULO.l_titseqnum= ",l_titseqnum
                                  display "<602> GERA_TITULO.titnumdig= ",lr_retGeraTitulo.titnumdig
                                  display "<603> GERA_TITULO.l_titsitnum= ",l_titsitnum
                                  display "<604> Insere na Entidade datmtit"
                            end if
                            execute p_cty27g01_007 using lr_param.atdsrvnum,
                                                         lr_param.atdsrvano ,
                                                         l_titseqnum,
                                                         lr_retGeraTitulo.titnumdig,
                                                         l_titsitnum
                         if sqlca.sqlcode <> 0 then
                               let lr_retorno.mensagem = 'Erro INSERT p_cty27g01_007 / ', sqlca.sqlcode
                               let lr_retorno.codigo = 1  using '&'
                               if g_issk.empcod = 43 and   
                                  g_issk.funmat = 3029 then
                                     display "<613> cty27g01-> Erro .......................... <" , sqlca.sqlcode , "><",lr_retorno.codigo,"-",lr_retGeraTitulo.msgerro,">"
                                     display "<614> cty27g01-> Msg  .......................... <" , lr_retorno.mensagem clipped,lr_retorno.codigo,">"
                               end if
                               return lr_retorno.codigo,lr_retorno.mensagem
                         else
                               exit for
                         end if
                         whenever error stop
                         if g_issk.empcod = 43 and   
                            g_issk.funmat = 3029 then
                               display "<620> GERA_TITULO.salvo"
                         end if
                     end if
                end for

                if g_issk.empcod = 43 and   
                   g_issk.funmat = 3029 then
                      display "<625> GERA_TITULO.FIM FOR"
                end if

                #Verifica se ocorreu erro na geracao titulo
                if lr_retGeraTitulo.coderro <> 0 then
                     display "<629> cty27g01-> Deu erro na geracao de Titulos<", lr_retGeraTitulo.coderro,">"
                     whenever error continue
                     open c_cty27g01_005 using  lr_param.atdsrvnum
                                               ,lr_param.atdsrvano
                     foreach c_cty27g01_005 into l_titnum
                        #Aciona cancelamento de titulo informando o
                        #numero do titulo, tipo emissao, data atualizacao
                        #e acao executada
                        call fcigfa01(l_titnum, 40, today, 'C')
                        returning l_retCancel

                        if l_retCancel = "" then
                             whenever error continue
                               execute p_cty27g01_010 using lr_datmefutrn.atdsrvnum,
                                                            lr_datmefutrn.atdsrvano,
                                                            l_titnum
                             display "<645> cty27g01-> Atualiza situacao do titulo em datmtit para 2(set titsitnum = 2)"
                             whenever error stop

                             if sqlca.sqlcode <> 0 then
                                display "<649> cty27g01-> Deu erro na Atualizacao da situacao do titulo em datmtit para 2(set titsitnum = 2)"
                             end if
                        end if
                     end foreach

                     exit for
                end if

           end for
        end if
   else
      if g_issk.empcod = 43 and   
         g_issk.funmat = 3029 then
            display "<660> Forma de Pagamento nao eh Cartao <",lr_pagamento.pgtfrmcod,">"
      end if
   end if
   if g_issk.empcod = 43 and   
      g_issk.funmat = 3029 then
         display "<662> cty27g01-> FIM .......................... <" , sqlca.sqlcode ,"><",lr_retorno.codigo,">"
   end if 
   return lr_retorno.codigo,lr_retorno.mensagem
end function 