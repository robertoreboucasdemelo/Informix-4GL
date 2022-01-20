#############################################################################
# Nome do Modulo: CTS01G00                                         Marcelo  #
#                                                                  Gilberto #
# Rotinas genericas de tratamento de inconsistencias               Fev/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 10/08/1999  PSI 9018-1   Wagner       Excluir pesquisa para (R)elatorio   #
#                                       qdo. o item for LIMITE ATENDIMENTO  #
#                                       (034/035) ATINGIDO, e tambem excluir#
#                                       codigo G13-COLISAO C/GUINCHO.       #
#---------------------------------------------------------------------------#
# 30/08/1999  PSI 9235-5   Wagner       Incluir pesquisa para (R)elatorio   #
#                                       qdo. o item for LIMITE ATENDIMENTO  #
#                                       (034/035) ATINGIDO.                 #
#---------------------------------------------------------------------------#
# 11/10/1999  PSI 9429-3   Wagner       Alterar pesquisa para (R)elatorio   #
#                                       qdo. o item for LIMITE ATENDIMENTO  #
#                                       (034/035) listar qdo atingir o 5o.  #
#                                       (quinto inclusive) atendimanto.     #
#---------------------------------------------------------------------------#
# 20/10/1999  PSI 9527-3   Gilberto     Substituicao da funcao VERDAF.      #
#---------------------------------------------------------------------------#
# 25/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-  #
#                                       coes, com a utilizacao de funcoes.  #
#---------------------------------------------------------------------------#
# 16/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 16/06/2000  PSI 10924-0  Wagner       Disponibilizar critica de atendi-   #
#                                       mento por proposta.                 #
#---------------------------------------------------------------------------#
# 28/09/2001  PSI 14013-9  Wagner       Disponibilizar acesso clausulas     #
#                                       34A e 35A.                          #
#---------------------------------------------------------------------------#
# 09/10/2001  PSI 14063-5  Wagner       Disponibilizar acesso clausulas     #
#                                       34A e 35A igual a 034 e 035.        #
#---------------------------------------------------------------------------#
# 29/07/2002  PSI 15655-8  Ruiz         Inclusao de incosistencia de        #
#                                       Oficina Cortada.                    #
#---------------------------------------------------------------------------#
# 27/04/2004 - CT-203904  Leandro - Ramo igual a Tranp selecionar com seq 1.#
#---------------------------------------------------------------------------#
#                        * * * A L T E R A C A O * * *                      #
#  Analista Resp. : Kiandra Antonello                                       #
#  CT             : 205540                                                  #
#...........................................................................#
#  Data        Autor Fabrica  Alteracao                                     #
#  03/05/2004  Gustavo(FSW)   Na  selecao  da tabela gtakram, fazer "select #
#                             unique".                                      #
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 15/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32            #
#---------------------------------------------------------------------------#
# 24/11/2008 Priscila Staingel 230650  Nao utilizar a 1 posicao do assunto  #
#                                      como sendo o agrupamento, buscar cod #
#                                      agrupamento.                         #
#---------------------------------------------------------------------------#
# 07/10/2010 Robert Lima   ct 10104356 Adicionado o cursor, ccts01g00002    #
#---------------------------------------------------------------------------#
# 25/10/2010 Carla Rampazzo  PSI 00762 Tratar novas Clausulas 46/46R        #
#---------------------------------------------------------------------------#
# 19/07/2011 Helder Oliveira           Funcao cts01g00_azul somente batch   #
#                                      Tratamento de inconsistencias AZUL   #
#---------------------------------------------------------------------------#
# 20/07/2011 Helder Oliveira           Funcao cts01g00_itau somente batch   #
#                                      Tratamento de inconsistencias ITAU   #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_cts01g00_sql smallint

#==========================================================================
 function cts01g00_prepare()
#==========================================================================
 define l_sql char(5000)

 #azul
 let l_sql = " SELECT datrligprp.prpnumdig                       "
            ,"   FROM datmligacao                                "
            ,"  INNER JOIN datrligprp                            "
            ,"     ON datrligprp.lignum     = datmligacao.lignum "
            ,"  where datmligacao.atdsrvnum = ?                  "
            ,"    and datmligacao.atdsrvano = ?                  "
 prepare p1_cts01g00_001 from l_sql
 declare c1_cts01g00_001 cursor for p1_cts01g00_001

 #azul
 let l_sql = " SELECT c24srvdsc     "
            ,"   FROM datmservhist  "
            ,"  WHERE atdsrvnum = ? "
            ,"    AND atdsrvano = ? "
            ,"    AND c24txtseq = 1 "
 prepare p1_cts01g00_002 from l_sql
 declare c1_cts01g00_002 cursor for p1_cts01g00_002

 let l_sql = "  SELECT itaciacod         "
            ,"   FROM datrligitaaplitm   "
            ,"  WHERE itaramcod    = ?   "
            ,"    AND itaaplnum    = ?   "
            ,"    AND aplseqnum    = ?   "
            ,"    AND itaaplitmnum = ?   "
 prepare p1_cts01g00_003 from l_sql
 declare c1_cts01g00_003 cursor for p1_cts01g00_003

 let m_cts01g00_sql = true

 end function

#==========================================================================
 function cts01g00(param)
#==========================================================================

 define param      record
    ramcod         like datrservapol.ramcod    ,
    succod         like datrservapol.succod    ,
    aplnumdig      like datrservapol.aplnumdig ,
    itmnumdig      like datrservapol.itmnumdig ,
    c24astcod      like datmligacao.c24astcod  ,
    atdsrvorg      like datmservico.atdsrvorg  ,
    vcldes         like datmservico.vcldes     ,
    vclanomdl      like datmservico.vclanomdl  ,
    vcllicnum      like datmservico.vcllicnum  ,
    atdsrvnum      like datmservico.atdsrvnum  ,
    atdsrvano      like datmservico.atdsrvano  ,
    atdrefdat      date                        ,
    orgcod         char (01)                     # (T)ela  ou  (R)elatorio
 end record

 define d_cts01g00 record
    viginc         like abamapol.viginc        ,
    vigfnl         like abamapol.vigfnl        ,
    itmsttatu      like abbmitem.itmsttatu     ,
    cbtcod         like abbmcasco.cbtcod       ,
    vclanomdl      like abbmveic.vclanomdl     ,
    vcllicnum      like abbmveic.vcllicnum     ,
    vclchsfnl      like abbmveic.vclchsfnl     ,
    vcldes         like datmservico.vcldes
 end record

 define ws         record
    daftip         char (01)                   ,
    dafdat         date                        ,
    dafdoc         char (01)                   ,
    qtdatd         smallint                    ,
    aplstt         like abamapol.aplstt        ,
    clscod         like abbmclaus.clscod       ,
    clscodant      like abbmclaus.clscod       ,
    dctnumseq      like abbmveic.dctnumseq     ,
    vclcoddig      like abbmveic.vclcoddig     ,
    sgrorg         like rsamseguro.sgrorg      ,
    sgrnumdig      like rsamseguro.sgrnumdig   ,
    rmemdlcod      like rsamseguro.rmemdlcod   ,
    edstip         like rsdmdocto.edstip       ,
    edsstt         like rsdmdocto.edsstt       ,
    prporg         like rsdmdocto.prporg       ,
    prpnumdig      like rsdmdocto.prpnumdig    ,
    atdantflg      char (01)                   ,
    c24srvdsc      like datmservhist.c24srvdsc
 end record
 define l_cod_erro          smallint
 define l_data_calculo      date
 define l_clscod            char(03)
 define l_flag_endosso      char(01)

 define a_cts01g00 array[12] of record
    inccod         smallint ,
    incdsc         char (50)
 end record

 define arr_aux    smallint
 define l_ramsgl   char(15)
 define l_comando  char(500)
 define l_exist    smallint
 define l_c24astagp like datkassunto.c24astagp    ##psi230650
 define l_log      char(100)



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  12
		initialize  a_cts01g00[w_pf1].*  to  null
	end	for

	initialize  d_cts01g00.*  to  null

	initialize  ws.*  to  null

 initialize a_cts01g00   to null
 initialize d_cts01g00.* to null
 initialize ws.*         to null
 let l_cod_erro        = null
 let l_data_calculo    = null
 let l_clscod          = null
 let l_flag_endosso    = null
 let l_c24astagp       = null
 let l_exist = false
 let l_log             = null

 let arr_aux = 0

 if param.orgcod  =  "R"   then
    set isolation to dirty read
 end if

 #--------------------------------------------------------------------------
 # VERIFICA SE OFICINA EM OBSERVACAO
 #--------------------------------------------------------------------------
 select c24srvdsc
      into ws.c24srvdsc
      from datmservhist
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano
       and c24txtseq = 1
 if ws.c24srvdsc = "OF CORT MOTIVO:" then

    let arr_aux = arr_aux + 1
    let a_cts01g00[arr_aux].inccod = 12  # OFICINA CORTADA

    call cts01g00_descr(a_cts01g00[arr_aux].inccod)
              returning a_cts01g00[arr_aux].incdsc
 end if

 if param.orgcod  =  "R"   then
    let l_log = "DOC ", param.ramcod clipped ,"/", param.succod clipped ,"/", param.aplnumdig clipped ,"/", g_ppt.cmnnumdig clipped
    call errorlog(l_log)
 end if

 #--------------------------------------------------------------------------
 # DOCUMENTO NAO INFORMADO
 #--------------------------------------------------------------------------
 if (param.ramcod    is null  or
     param.succod    is null  or
     param.aplnumdig is null ) and
     g_ppt.cmnnumdig is null then

    let arr_aux = arr_aux + 1
    select prpnumdig
      from datmligacao, datrligprp
     where datmligacao.atdsrvnum = param.atdsrvnum
       and datmligacao.atdsrvano = param.atdsrvano
       and datrligprp.lignum     = datmligacao.lignum
    if sqlca.sqlcode = notfound  then

       let g_hdk.sem_docto            = "S" --> Sem Docto
       let a_cts01g00[arr_aux].inccod = 01  # SEM DOC.
    else
       let a_cts01g00[arr_aux].inccod = 11  # SEM DOC.C/PROPOSTA
    end if

    if param.orgcod  =  "R"   then
       let l_log = "Bloco 1 ",  a_cts01g00[arr_aux].inccod
       call errorlog(l_log)
    end if
    call cts01g00_descr(a_cts01g00[arr_aux].inccod)
              returning a_cts01g00[arr_aux].incdsc
    #---------------------------------------------------------------
    # Verifica solicitacao anterior 24/48 horas
    #---------------------------------------------------------------
    if param.orgcod  =  "R"   then
       call cts01g00_solic(param.atdsrvorg, param.ramcod   , param.succod,
                           param.aplnumdig, param.itmnumdig, param.vcllicnum,
                           param.atdsrvnum, param.atdsrvano, param.atdrefdat)
            returning ws.atdantflg
       if ws.atdantflg  =  "S"   then

          let arr_aux = arr_aux + 1
          let a_cts01g00[arr_aux].inccod = 10

          call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                    returning a_cts01g00[arr_aux].incdsc
       end if
    end if
 else
    #------------------------------------------------------------------
    # RAMO 31 - AUTOMOVEL
    #------------------------------------------------------------------

    if param.orgcod  =  "R"   then
       let l_log = "Bloco 2 "
       call errorlog(l_log)
    end if
    if param.ramcod = 31  or
       param.ramcod = 531 then
       call f_funapol_ultima_situacao
            (param.succod, param.aplnumdig, param.itmnumdig)
            returning g_funapol.*
       #------------------------------------------------------------------
       # Situacao e vigencia da apolice
       #------------------------------------------------------------------
       select aplstt, viginc, vigfnl
         into ws.aplstt         ,
              d_cts01g00.viginc ,
              d_cts01g00.vigfnl
         from abamapol
        where succod    = param.succod     and
              aplnumdig = param.aplnumdig
       if (param.atdsrvorg is not null)  and
          (param.atdsrvorg =   5         or     ###  RPT
           param.atdsrvorg =   7      )  then   ###  Replace
       else
          if d_cts01g00.vigfnl < param.atdrefdat  then

             let arr_aux                    = arr_aux + 1
             let g_hdk.vencido              = "S"  --> Vencido
             let a_cts01g00[arr_aux].inccod = 02   --> Vencido

             call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                       returning a_cts01g00[arr_aux].incdsc
          end if
          #---------------------------------------------------------------
          # Situacao do item
          #---------------------------------------------------------------
          select itmsttatu
            into d_cts01g00.itmsttatu
            from abbmitem
           where succod    = param.succod     and
                 aplnumdig = param.aplnumdig  and
                 itmnumdig = param.itmnumdig
          if sqlca.sqlcode = notfound  then
             let d_cts01g00.itmsttatu = "*"
          end if
          if ws.aplstt = "C"  then

             let arr_aux                    = arr_aux + 1
             let g_hdk.cancelado            = "S" --> Cancelado
             let a_cts01g00[arr_aux].inccod = 03  --> Cancelado

             call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                       returning a_cts01g00[arr_aux].incdsc
          else
             if d_cts01g00.itmsttatu <> "A"  then

                let arr_aux                    = arr_aux + 1
                let g_hdk.cancelado            = "S" --> Cancelado
                let a_cts01g00[arr_aux].inccod = 03  --> Cancelado

                call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                          returning a_cts01g00[arr_aux].incdsc
             end if
          end if
       end if

       #PSi 230650
       #Buscar agrupamento do assunto
       select c24astagp into l_c24astagp
           from datkassunto
           where c24astcod = param.c24astcod

       #------------------------------------------------------------------
       # Verifica clausulas para Porto Socorro
       #------------------------------------------------------------------

       #if param.c24astcod[1,1] = "S"  then    ##psi230650
       if l_c24astagp = "S"  then
          declare c_abbmclaus cursor for
           select clscod into ws.clscod
             from abbmclaus
            where succod    = param.succod        and
                  aplnumdig = param.aplnumdig     and
                  itmnumdig = param.itmnumdig     and
                  dctnumseq = g_funapol.dctnumseq and
                  clscod   in ("033","33R","034","34B","34C","035","055","34A","35A", "35R", "046", "46R","047","47R","044","44R","048","48R") ## psi201154 -- ALteração Varani
          open  c_abbmclaus
          let l_exist = false
          foreach c_abbmclaus into ws.clscod
            if ws.clscod <> "034" and
               ws.clscod <> "071" then
              let ws.clscodant = ws.clscod
            end if
                 let l_exist = true

            if ws.clscod = "034" or
               ws.clscod = "071" then

              if cta13m00_verifica_clausula(param.succod        ,
                                            param.aplnumdig     ,
                                            param.itmnumdig     ,
                                            g_funapol.dctnumseq ,
                                            ws.clscod           ) then
                 let ws.clscod = ws.clscodant

               continue foreach
              end if
            end if

          end foreach

          if l_exist = false  then
             if param.c24astcod = "S90"  or     ## Cortesia - Envio de Socorro
                param.c24astcod = "S93"  then   ## Cortesia - Envio de Taxi

                let arr_aux = arr_aux + 1
                let a_cts01g00[arr_aux].inccod = 05

                call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                          returning a_cts01g00[arr_aux].incdsc
             else

                let arr_aux = arr_aux + 1
                let a_cts01g00[arr_aux].inccod = 04

                call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                          returning a_cts01g00[arr_aux].incdsc
             end if
          else
             if (ws.clscod = "034" or ws.clscod = "34A")  and
                 param.c24astcod = "S93"  then

                let arr_aux = arr_aux + 1
                let a_cts01g00[arr_aux].inccod = 05

                call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                          returning a_cts01g00[arr_aux].incdsc
             end if

             if  param.c24astcod = "S60" and
                 ws.clscod <> "34A"      and
                 ws.clscod <> "35A"      then
                 let l_cod_erro = 0
                 call faemc144_clausula(param.succod,
                                        param.aplnumdig,
                                        param.itmnumdig)
                           returning l_cod_erro,
                                     l_clscod,
                                     l_data_calculo,
                                     l_flag_endosso

                 if l_cod_erro =  0 then
                    if l_data_calculo < "01/07/2006" then
                       let l_cod_erro = 1
                    end if
                 end if
                 if l_cod_erro <> 0 then
                    # conforme regra, o alerta so deve ser apresentado em
                    # apolices/endossos com dt calculo < "01/07/06".

                    let arr_aux = arr_aux + 1
                    let a_cts01g00[arr_aux].inccod = 04

                    call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                              returning a_cts01g00[arr_aux].incdsc
                 end if
             end if
          end if
          close c_abbmclaus
       else
          #----------------------------------------------------------------
          # Verifica cobertura
          #----------------------------------------------------------------
          select cbtcod
            into d_cts01g00.cbtcod
            from abbmcasco
           where succod    = param.succod     and
                 aplnumdig = param.aplnumdig  and
                 itmnumdig = param.itmnumdig  and
                 dctnumseq = g_funapol.autsitatu
          if d_cts01g00.cbtcod = 0  then

             let arr_aux = arr_aux + 1
             let a_cts01g00[arr_aux].inccod = 06

             call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                          returning a_cts01g00[arr_aux].incdsc
          else
             if d_cts01g00.cbtcod = 2         and
              ( l_c24astagp = "G"    or
                l_c24astagp = "E" )  then

                let arr_aux = arr_aux + 1
                let a_cts01g00[arr_aux].inccod = 06

                call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                          returning a_cts01g00[arr_aux].incdsc
             end if
          end if
       end if
       #------------------------------------------------------------------
       # Dados do veiculo
       #------------------------------------------------------------------
       select vclcoddig ,
              vclanomdl ,
              vcllicnum
         into ws.vclcoddig         ,
              d_cts01g00.vclanomdl ,
              d_cts01g00.vcllicnum
         from abbmveic
        where succod    = param.succod       and
              aplnumdig = param.aplnumdig    and
              itmnumdig = param.itmnumdig    and
              dctnumseq = g_funapol.vclsitatu
       if sqlca.sqlcode = notfound  then
          select vclcoddig ,
                 vclanomdl ,
                 vcllicnum
            into ws.vclcoddig         ,
                 d_cts01g00.vclanomdl ,
                 d_cts01g00.vcllicnum
            from abbmveic
           where abbmveic.succod    = param.succod       and
                 abbmveic.aplnumdig = param.aplnumdig    and
                 abbmveic.itmnumdig = param.itmnumdig    and
                 abbmveic.dctnumseq = (select max(dctnumseq)
                  from abbmveic
                 where abbmveic.succod    = param.succod       and
                       abbmveic.aplnumdig = param.aplnumdig    and
                       abbmveic.itmnumdig = param.itmnumdig)
       end if
       if sqlca.sqlcode <> notfound  then
          if param.orgcod = "T"  then
             #------------------------------------------------------------------
             # Verifica existencia do dispositivo para servicos de DAF (so tela)
             #------------------------------------------------------------------
             #if param.c24astcod[1,1] = "D"  then     ##psi230650
             if l_c24astagp     = "D"    and
                param.c24astcod <> "D00" and
                param.c24astcod <> "D10" and
                param.c24astcod <> "D11" and
                param.c24astcod <> "D12" then
                call fadic002_daf(d_cts01g00.vclchsfnl,
                                  d_cts01g00.vcllicnum,
                                  ws.vclcoddig)
                        returning ws.dafdoc, ws.dafdat, ws.daftip
                if ws.dafdoc <> "N"  then
                else

                   let arr_aux = arr_aux + 1
                   let a_cts01g00[arr_aux].inccod = 09

                   call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                             returning a_cts01g00[arr_aux].incdsc
                end if
             end if
          else
             if param.c24astcod[1,3] <> "G13"  then
                call cts15g00(ws.vclcoddig) returning d_cts01g00.vcldes
                if d_cts01g00.vcldes    <> param.vcldes     or
                   d_cts01g00.vclanomdl <> param.vclanomdl  or
                   d_cts01g00.vcllicnum <> param.vcllicnum  then

                   let arr_aux = arr_aux + 1
                   let a_cts01g00[arr_aux].inccod = 07

                   call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                             returning a_cts01g00[arr_aux].incdsc
                end if
             end if
          end if
          #---------------------------------------------------------------------
          # Verificacao do limite de TRES atendimentos para clausula 34 e CINCO
          # atendimentos para clausula 35/55 (apolices emitidas apos 01/07/1997)
          #---------------------------------------------------------------------
          if param.orgcod <> "T"  then
             if (ws.clscod ="034" or ws.clscod ="035" or ws.clscod ="055"  or
                 ws.clscod ="34A" or ws.clscod ="35A" or ws.clscod ="35R") and ## PSI201154
                d_cts01g00.viginc >= "01/07/1997"                          then
                call cts01g00_limite(param.ramcod     , param.succod   ,
                                     param.aplnumdig  , param.itmnumdig,
                                     d_cts01g00.viginc, d_cts01g00.vigfnl)
                     returning ws.qtdatd

                if param.orgcod  =  "R"   then
                   set isolation to dirty read
                end if

                if ((ws.clscod = "034" or ws.clscod = "34A")  and
                                          ws.qtdatd >= 5   )  or
                   ((ws.clscod = "035" or ws.clscod = "35A" or ws.clscod = "35R") and ## PSI201154
                                          ws.qtdatd >= 5   )  or
                   (ws.clscod = "055" and ws.qtdatd >= 5   )  then

                   let arr_aux = arr_aux + 1
                   let a_cts01g00[arr_aux].inccod = 08

                   call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                             returning a_cts01g00[arr_aux].incdsc
                end if
                if ((ws.clscod = "034" or ws.clscod = "34A")  and
                                          ws.qtdatd >= 5   )  or
                   ((ws.clscod = "035" or ws.clscod = "35A" or ws.clscod = "35R") and
                                          ws.qtdatd >= 5   )  or
                   (ws.clscod = "055" and ws.qtdatd >= 5   )  then
                else
                   initialize ws.qtdatd to null
                end if
             end if
          end if
       end if
    else


       if param.orgcod  =  "R"   then
          let l_log = "Bloco 3 "
          call errorlog(l_log)
       end if

       #------------------------------------------------------------------
       # OUTROS RAMOS - RAMOS ELEMENTARES
       #------------------------------------------------------------------
       if g_ppt.cmnnumdig is null then
          #Alterado para um cursor devido ao chamado 10104356 - Robert Lima
          let l_comando = "  select sgrorg,               ",
                          "         sgrnumdig,            ",
                          "         rmemdlcod             ",
                          "    from rsamseguro            ",
                          "   where succod    =  ?     and",
                          "         ramcod    =  ?     and",
                          "         aplnumdig =  ?        ",
                          "  order by sgrnumdig desc      "
          prepare pcts01g00002 from l_comando
          declare ccts01g00002 cursor for pcts01g00002

          open ccts01g00002 using param.succod,
                                  param.ramcod,
                                  param.aplnumdig
          fetch ccts01g00002 into ws.sgrorg,
                                  ws.sgrnumdig,
                                  ws.rmemdlcod
       #-------------------------------------------------------------------
       # Vigencia da apolice
       #-------------------------------------------------------------------
          select viginc,
                 edsstt
            into d_cts01g00.viginc,
                 ws.edsstt
            from rsdmdocto
           where prporg    = ws.sgrorg     and
                 prpnumdig = ws.sgrnumdig  and
                 dctnumseq = 1

          let l_comando = "select unique ramsgl "
                         ,"from gtakram         "
                         ,"where ramcod = ?     "

          prepare pcts01g00001 from l_comando
          declare ccts01g00001 cursor for pcts01g00001

          open  ccts01g00001 using param.ramcod
          whenever error continue
          fetch ccts01g00001  into l_ramsgl
          whenever error stop

          if sqlca.sqlcode    <> 0 then
             if sqlca.sqlcode <  0 then
                error "Nao acessou o Ramo (gtakram),"
                     ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&'
                     ,", ", sqlca.sqlerrd[2], " )"
                sleep(3)
                close ccts01g00001
                return a_cts01g00[01].inccod,
                       a_cts01g00[02].inccod,
                       a_cts01g00[03].inccod,
                       a_cts01g00[04].inccod,
                       a_cts01g00[05].inccod,
                       a_cts01g00[06].inccod,
                       a_cts01g00[07].inccod,
                       a_cts01g00[08].inccod,
                       a_cts01g00[09].inccod,
                       a_cts01g00[10].inccod,
                       a_cts01g00[11].inccod,
                       a_cts01g00[12].inccod,
                       ws.qtdatd, ws.clscod
             end if
          end if

	  if l_ramsgl = "TRANSP" then
             select vigfnl,
                    edstip,
                    prporg,
                    prpnumdig
               into d_cts01g00.vigfnl,
                    ws.edstip,
                    ws.prporg,
                    ws.prpnumdig
               from rsdmdocto
              where sgrorg    = ws.sgrorg      and
                    sgrnumdig = ws.sgrnumdig   and
                    dctnumseq = 1
	  else
             select vigfnl,
                    edstip,
                    prporg,
                    prpnumdig
               into d_cts01g00.vigfnl,
                    ws.edstip,
                    ws.prporg,
                    ws.prpnumdig
               from rsdmdocto
              where sgrorg    = ws.sgrorg      and
                    sgrnumdig = ws.sgrnumdig   and
                    dctnumseq = (select max(dctnumseq)
                                   from rsdmdocto
                                  where sgrorg     = ws.sgrorg     and
                                        sgrnumdig  = ws.sgrnumdig  and
                                        prpstt    in (19,65,66,88))
	  end if

          if d_cts01g00.vigfnl < param.atdrefdat  then

             let arr_aux                    = arr_aux + 1
             let g_hdk.vencido              = "S" --> Vencido
             let a_cts01g00[arr_aux].inccod = 02  --> Vencido

             call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                       returning a_cts01g00[arr_aux].incdsc
          end if

          if ws.edsstt <> "A" and
             ws.edstip <> 40  and
             ws.edstip <> 41  then

             let arr_aux                    = arr_aux + 1
             let g_hdk.cancelado            = "S" --> Cancelado
             let a_cts01g00[arr_aux].inccod = 03  --> Cancelado

             call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                       returning a_cts01g00[arr_aux].incdsc
          end if
       end if
    end if
    #----------------------------------------------------------------------
    # Verifica solicitacao anterior 24/48 horas
    #----------------------------------------------------------------------
    if param.orgcod  =  "R"   then
       call cts01g00_solic(param.atdsrvorg, param.ramcod   , param.succod,
                           param.aplnumdig, param.itmnumdig, param.vcllicnum,
                           param.atdsrvnum, param.atdsrvano, param.atdrefdat)
            returning ws.atdantflg

       if ws.atdantflg  =  "S"   then

          let arr_aux = arr_aux + 1
          let a_cts01g00[arr_aux].inccod = 10

          call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                    returning a_cts01g00[arr_aux].incdsc
       end if
    end if
    #----------------------------------------------------------------------
    # Verifica clausula 10 - Porto Residencia
    #----------------------------------------------------------------------
    if param.orgcod  <>  "T"  then
       if param.ramcod  =  45  or
          param.ramcod  =  114 then   #-> Residencia
          select clscod
            into ws.clscod
            from rsdmclaus
           where prporg    = ws.prporg     and
                 prpnumdig = ws.prpnumdig  and
                 lclnumseq = 1             and
                (clscod    = "10"          or
                 clscod    = "10R")        and
                 clsstt    = "A"
       end if
       #--------------------------------------------------------------------
       # Verifica qtde de atendimentos: clausula 10 e ramo 71 modalidade 232
       #--------------------------------------------------------------------
       if (ws.clscod     = "10"   or
           ws.clscod     = "10R") or
          (param.ramcod  =  71    and
           ws.rmemdlcod  = 232)   or
          (param.ramcod  = 171    and
           ws.rmemdlcod  = 232)   then

           call cts01g00_limite(param.ramcod     , param.succod   ,
                                param.aplnumdig  , param.itmnumdig,
                                d_cts01g00.viginc, d_cts01g00.vigfnl)
                returning ws.qtdatd

           if param.orgcod  =  "R"   then
              set isolation to dirty read
           end if

           if ws.qtdatd  <  2   then
              initialize ws.qtdatd  to null
           end if
       end if
    end if
    ## PSI 212296 - Clausula 36 - Envio de Guincho
    whenever error continue
    if param.ramcod    = 118   then
       if ws.rmemdlcod    = 113 or
          param.c24astcod = "S10" then
          select clscod
            from rsdmclaus
           where prporg    = ws.prporg     and
                 prpnumdig = ws.prpnumdig  and
                 lclnumseq = 1             and
                (clscod    = "36"          or
                 clscod    = "036"         or
                 clscod    = "59"          or
                 clscod    = "059"         or
                 clscod    = "60"          or
                 clscod    = "060"         or
                 clscod    = "61"          or
                 clscod    = "061" )       and  ---> Inclusão clausulas 59,60 e 61 - 26/02/08 - Multirisco
                 clsstt    = "A"
       end if
       whenever error stop
       if sqlca.sqlcode = 100 then

          let arr_aux = arr_aux + 1
          let a_cts01g00[arr_aux].inccod = 4

          call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                    returning a_cts01g00[arr_aux].incdsc
       end if
    end if
    ## PSI 212296 - Clausula 36 - Envio de Guincho
 end if
 let arr_aux = arr_aux + 1
 #-------------------------------------------------------------------------
 # Exibe pop-up de erros encontrados
 #-------------------------------------------------------------------------
 if param.orgcod = "T"               and
   (g_abre_tela is null  or
    g_abre_tela = "S"       )        and   --> let em cta02m00
    a_cts01g00[1].inccod is not null then

    open window cts01g00 at 10,18 with form "cts01g00"
                         attribute(form line first, border)

    let int_flag = false

    display "               Inconsistencias              "  to  cabecalho attribute (reverse)

    message " (F17)Abandona"
    call set_count(arr_aux-1)

    display array a_cts01g00 to s_cts01g00.*
       on key (interrupt,control-c)
          exit display
    end display

    close window  cts01g00
 end if
 let int_flag = false


 if param.orgcod  =  "R"   then
    let l_log = "SAI ",a_cts01g00[01].inccod, "/",
                       a_cts01g00[02].inccod, "/",
                       a_cts01g00[03].inccod, "/",
                       a_cts01g00[04].inccod, "/",
                       a_cts01g00[05].inccod, "/",
                       a_cts01g00[06].inccod, "/",
                       a_cts01g00[07].inccod, "/",
                       a_cts01g00[08].inccod, "/",
                       a_cts01g00[09].inccod, "/",
                       a_cts01g00[10].inccod, "/",
                       a_cts01g00[11].inccod, "/",
                       a_cts01g00[12].inccod
    call errorlog(l_log)
 end if


 return a_cts01g00[01].inccod,
        a_cts01g00[02].inccod,
        a_cts01g00[03].inccod,
        a_cts01g00[04].inccod,
        a_cts01g00[05].inccod,
        a_cts01g00[06].inccod,
        a_cts01g00[07].inccod,
        a_cts01g00[08].inccod,
        a_cts01g00[09].inccod,
        a_cts01g00[10].inccod,
        a_cts01g00[11].inccod,
        a_cts01g00[12].inccod,
        ws.qtdatd, ws.clscod

end function  ###  cts01g00

#==========================================================================
 function cts01g00_limite(param)
#==========================================================================

 define param      record
    ramcod         like datrservapol.ramcod   ,
    succod         like datrservapol.succod   ,
    aplnumdig      like datrservapol.aplnumdig,
    itmnumdig      like datrservapol.itmnumdig,
    viginc         like abamapol.viginc       ,
    vigfnl         like abamapol.vigfnl
 end record

 define ws      record
    qtdatd      smallint,
    atdsrvnum   like datmservico.atdsrvnum,
    atdsrvano   like datmservico.atdsrvano,
    lignum      like datmligacao.lignum,
    atdetpcod   like datmsrvacp.atdetpcod
 end record

 define l_sql     char (500)


	let	l_sql  =  null

	initialize  ws.*  to  null

 initialize ws.* to null

 set isolation to dirty read

 declare c_cts01g00_001 cursor for
    select datmservico.atdsrvnum,
           datmservico.atdsrvano
      from datrservapol, datmservico
     where datrservapol.succod    = param.succod            and
           datrservapol.ramcod    = param.ramcod            and
           datrservapol.aplnumdig = param.aplnumdig         and
           datrservapol.itmnumdig = param.itmnumdig         and
           datmservico.atdsrvnum  = datrservapol.atdsrvnum  and
           datmservico.atdsrvano  = datrservapol.atdsrvano  and
           datmservico.atddat between param.viginc          and
                                      param.vigfnl

 if param.ramcod  =  31 or
    param.ramcod  = 531 then
    #psi230650 - buscar para o agrupamento S
    let l_sql = "select a.lignum from datmligacao a, datkassunto b" ,
              " where a.lignum  =  ?    and " ,
              "       b.c24astagp = 'S' and " ,
              "       a.c24astcod = b.c24astcod "
 else
    let l_sql = "select lignum from datmligacao " ,
              " where lignum  =  ?    and " ,
              "       c24astcod = 'S60'"
 end if

 prepare p_cts01g00_001 from l_sql
 declare c_cts01g00_002 cursor for p_cts01g00_001

 let l_sql = "select atdetpcod    ",
           "  from datmsrvacp   ",
           " where atdsrvnum = ?",
           "   and atdsrvano = ?",
           "   and atdsrvseq = (select max(atdsrvseq)",
                               "  from datmsrvacp    ",
                               " where atdsrvnum = ? ",
                               "   and atdsrvano = ?)"
 prepare p_cts01g00_002 from l_sql
 declare c_cts01g00_003 cursor for p_cts01g00_002

 let ws.qtdatd = 0

 foreach  c_cts01g00_001  into  ws.atdsrvnum, ws.atdsrvano, ws.lignum

    let ws.lignum = cts20g00_servico(ws.atdsrvnum, ws.atdsrvano)

    open  c_cts01g00_002 using ws.lignum
    fetch c_cts01g00_002

    if sqlca.sqlcode = notfound  then
       continue foreach
    else
       open  c_cts01g00_003 using ws.atdsrvnum, ws.atdsrvano,
                                ws.atdsrvnum, ws.atdsrvano
       fetch c_cts01g00_003 into  ws.atdetpcod

       if ws.atdetpcod = 6  then  ###  EXCLUIDOS nao contabilizados
          continue foreach
       end if

       close c_cts01g00_003

       let ws.qtdatd = ws.qtdatd + 1
    end if
    close c_cts01g00_002
 end foreach

 set isolation to committed read

 return ws.qtdatd

end function  ###  cts01g00_limite


#==========================================================================
 function cts01g00_solic(param)
#==========================================================================

 define param        record
    atdsrvorg        like datmservico.atdsrvorg,
    ramcod           like datrservapol.ramcod,
    succod           like datrservapol.succod,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    vcllicnum        like datmservico.vcllicnum,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdrefdat        date
 end record

 define ws           record
    atddat           like datmservico.atddat,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdetpcod        like datmsrvacp.atdetpcod,
    inidat           date,
    fimdat           date,
    atdantflg        char (01),
    sql_dados        char (1000)
 end record

 define arr_aux      smallint


#------------------------------------------------------------------------
# Verifica parametros
#------------------------------------------------------------------------

	let	arr_aux  =  null

	initialize  ws.*  to  null

 initialize ws.*    to null
 let ws.atdantflg = "N"

 if param.aplnumdig  is null   and
    param.vcllicnum  is null   then
    return ws.atdantflg
 end if

 if param.atdsrvorg  <>   4    and
    param.atdsrvorg  <>   6    and
    param.atdsrvorg  <>   1    and
    param.atdsrvorg  <>   13   and
    param.atdsrvorg  <>   9    then
    return ws.atdantflg
 end if

 let int_flag  = false
 let ws.inidat = param.atdrefdat - 1 units day
 let ws.fimdat = param.atdrefdat

 if param.atdsrvorg  =   4     or
    param.atdsrvorg  =   6     or
    param.atdsrvorg  =   1     then
    let ws.sql_dados = " datmservico.atdsrvorg in ('4','6','1')"
 else
    let ws.sql_dados = " datmservico.atdsrvorg in ('9','13')"
 end if

 if param.succod    is not null  and
    param.ramcod    is not null  and
    param.aplnumdig is not null  then
    let ws.sql_dados = "select datmservico.atddat   ,",
                 "       datmservico.atdsrvnum,",
                 "       datmservico.atdsrvano ",
                 "  from datrservapol,datmservico",
                 " where datrservapol.ramcod     = ?                      and",
                 "       datrservapol.succod     = ?                      and",
                 "       datrservapol.aplnumdig  = ?                      and",
                 "       datrservapol.itmnumdig  = ?                      and",
                 "       datmservico.atdsrvnum   = datrservapol.atdsrvnum and",
                 "       datmservico.atdsrvano   = datrservapol.atdsrvano and",
                 "       datmservico.atddat     between  ?  and  ?        and",
                 ws.sql_dados clipped
 else
    let ws.sql_dados = "select datmservico.atddat   ,",
                 "       datmservico.atdsrvnum,",
                 "       datmservico.atdsrvano ",
                 "  from datmservico",
                 " where datmservico.vcllicnum    =  ?       and",
                 "       datmservico.atddat between  ? and ? and",
                 ws.sql_dados clipped
 end if

 prepare p_cts01g00_003 from ws.sql_dados
 declare c_cts01g00_004 cursor for p_cts01g00_003

 let ws.sql_dados = "select atdetpcod    ",
              "  from datmsrvacp   ",
              " where atdsrvnum = ?",
              "   and atdsrvano = ?",
              "   and atdsrvseq = (select max(atdsrvseq)",
                                  "  from datmsrvacp    ",
                                  " where atdsrvnum = ? ",
                                  "   and atdsrvano = ?)"
 prepare p_cts01g00_004  from ws.sql_dados
 declare c_cts01g00_005  cursor for p_cts01g00_004

 #------------------------------------------------------------------------
 # Ler servicos conforme parametros
 #------------------------------------------------------------------------
 if param.aplnumdig   is not null   then
    open c_cts01g00_004 using param.ramcod,
                             param.succod,
                             param.aplnumdig,
                             param.itmnumdig,
                             ws.inidat,
                             ws.fimdat
 else
    open c_cts01g00_004 using param.vcllicnum,
                             ws.inidat,
                             ws.fimdat
 end if


 foreach c_cts01g00_004 into  ws.atddat,
                             ws.atdsrvnum,
                             ws.atdsrvano

    if ws.atdsrvnum  =  param.atdsrvnum   and
       ws.atdsrvano  =  param.atdsrvano   then
       continue foreach
    end if

    open  c_cts01g00_005  using ws.atdsrvnum, ws.atdsrvano,
                             ws.atdsrvnum, ws.atdsrvano
    fetch c_cts01g00_005  into  ws.atdetpcod
    if ws.atdetpcod = 5  or    ###  Atendimento CANCELADO
       ws.atdetpcod = 6  then  ###  Atendimento EXCLUIDO
       continue foreach
    end if
    close c_cts01g00_005

    let ws.atdantflg = "S"
    exit foreach
 end foreach

 return ws.atdantflg

end function  ### cts01g00_solic

#==========================================================================
 function cts01g00_descr(param)
#==========================================================================

 define param   record
    inccod      smallint
 end record

 define retorno record
    incdsc      char (50)
 end record



	initialize  retorno.*  to  null

 initialize retorno.* to null

 case param.inccod
    when 01   let retorno.incdsc = "ATENDIMENTO SEM DOCUMENTO INFORMADO"
    when 02   let retorno.incdsc = "DOCUMENTO VENCIDO"
    when 03   let retorno.incdsc = "DOCUMENTO CANCELADO"
    when 04   let retorno.incdsc = "DOCUMENTO SEM CLAUSULA CONTRATADA"
    when 05   let retorno.incdsc = "CORTESIA - DOCUMENTO SEM CLAUSULA"
    #when 06   let retorno.incdsc = "DOCUMENTO SEM A RESPECTIVA COBERTURA"
    when 06   let retorno.incdsc = "DOCUMENTO SEM A COBERTURA CASCO"
    when 07   let retorno.incdsc = "DADOS DO VEICULO NAO CONFEREM"
    when 08   let retorno.incdsc = "LIM.ATENDIM.(CLS.034/035/34A/35A) ATINGIDO"
    when 09   let retorno.incdsc = "VEICULO NAO POSSUI DAF INSTALADO"
    when 10   let retorno.incdsc = "OUTRA SOLICITACAO NO PRAZO DE 24/48 HORAS"
    when 11   let retorno.incdsc = "ATENDIMENTO POR PROPOSTA"
    when 12   let retorno.incdsc = "SERVICOS COM OFICINAS EM OBSERVACAO"
 end case

 return retorno.incdsc

end function  ###  cts01g00_descr


#==========================================================================
 function cts01g00_valida_endosso(lr_param)
#==========================================================================

define lr_param record
       succod    like datrservapol.succod    ,
       ramcod    like datrservapol.ramcod    ,
       aplnumdig like datrservapol.aplnumdig
end record

define lr_retorno record
      edsnumref like datrservapol.edsnumref ,
      ramsgl    char(15)                    ,
      resultado smallint                    ,
      mensagem  char(60)                    ,
      descricao char(60)
end record

define lr_cty06g00    record
       resultado      smallint                   ,
       mensagem       char(60)                   ,
       sgrorg         like rsamseguro.sgrorg     ,
       sgrnumdig      like rsamseguro.sgrnumdig  ,
       vigfnl         like rsdmdocto.vigfnl      ,
       aplstt         like rsdmdocto.edsstt      ,
       prporg         like rsdmdocto.prporg      ,
       prpnumdig      like rsdmdocto.prpnumdig   ,
       segnumdig      like rsdmdocto.segnumdig   ,
       edsnumref      like rsdmdocto.edsnumdig
end record

initialize lr_retorno.* ,
           lr_cty06g00.* to null



     #Obter descricao do ramo

     call cty10g00_descricao_ramo(lr_param.ramcod, 1)
     returning lr_retorno.resultado
              ,lr_retorno.mensagem
              ,lr_retorno.descricao
              ,lr_retorno.ramsgl


     # Verifica se e Automovel

     if lr_param.ramcod = 31  or
        lr_param.ramcod = 531 then

        call cty05g00_edsnumref(1,
                                lr_param.succod     ,
                                lr_param.aplnumdig  ,
                                g_funapol.dctnumseq)
        returning lr_retorno.edsnumref
     else

        # Verifica se e RE

        if lr_retorno.ramsgl = "RE"  then
           call cty06g00_dados_apolice(lr_param.succod     ,
                                       lr_param.ramcod     ,
                                       lr_param.aplnumdig  ,
                                       lr_retorno.ramsgl   )
           returning lr_cty06g00.*

           let lr_retorno.edsnumref = lr_cty06g00.edsnumref
        end if

     end if

     # Verifica Apolices do Itau
     if g_documento.ciaempcod = 84 then
        call cty22g00_rec_ult_sequencia(g_documento.itaciacod ,
                                        lr_param.ramcod       ,
                                        lr_param.aplnumdig       )
        returning lr_retorno.edsnumref,
                  lr_retorno.resultado,
                  lr_retorno.mensagem
     end if

     # Se continuar nulo seta para 0

     if lr_retorno.edsnumref is null then
        let lr_retorno.edsnumref = 0
     end if

     return lr_retorno.edsnumref

end function

#==========================================================================
 function cts01g00_azul(lr_param)
#==========================================================================

define lr_param  record
   ramcod         like datrservapol.ramcod    ,
   succod         like datrservapol.succod    ,
   aplnumdig      like datrservapol.aplnumdig ,
   itmnumdig      like datrservapol.itmnumdig ,
   edsnumref      like datrservapol.edsnumref ,
   c24astcod      like datmligacao.c24astcod  ,
   atdsrvorg      like datmservico.atdsrvorg  ,
   vcldes         like datmservico.vcldes     ,
   vclanomdl      like datmservico.vclanomdl  ,
   vcllicnum      like datmservico.vcllicnum  ,
   atdsrvnum      like datmservico.atdsrvnum  ,
   atdsrvano      like datmservico.atdsrvano  ,
   atdrefdat      date                        ,
   orgcod         char (01)                     # (T)ela  ou  (R)elatorio
end record

define a_cts01g00 array[12] of record
    inccod         smallint ,
    incdsc         char (50)
end record

 define ws         record
    daftip         char (01)                   ,
    dafdat         date                        ,
    dafdoc         char (01)                   ,
    qtdatd         smallint                    ,
    aplstt         like abamapol.aplstt        ,
    clscod         like abbmclaus.clscod       ,
    clscodant      like abbmclaus.clscod       ,
    dctnumseq      like abbmveic.dctnumseq     ,
    vclcoddig      like abbmveic.vclcoddig     ,
    sgrorg         like rsamseguro.sgrorg      ,
    sgrnumdig      like rsamseguro.sgrnumdig   ,
    rmemdlcod      like rsamseguro.rmemdlcod   ,
    edstip         like rsdmdocto.edstip       ,
    edsstt         like rsdmdocto.edsstt       ,
    prporg         like rsdmdocto.prporg       ,
    prpnumdig      like rsdmdocto.prpnumdig    ,
    atdantflg      char (01)                   ,
    c24srvdsc      like datmservhist.c24srvdsc
 end record

 define l_log      char(100)
 define l_resultado        smallint
 define arr_aux            smallint
 define l_doc_handle       integer
 define l_franqvlr         decimal(9,2)
 define l_mensagem         char(60)
 define l_sitdes           char(15)
 define l_vclchs           char(20)
 define l_veic_codigo      char(10)
 define l_veic_marca       char(30)
 define l_veic_tipo        char(30)
 define l_veic_modelo      char(30)
 define l_veic_chassi      char(20)
 define l_veic_placa       char(07)
 define l_veic_anofab      char(04)
 define l_veic_anomod      char(04)
 define l_veic_catgtar     char(10)
 define l_veic_automatico  char(03)
 define l_atdantflg        char(1)
 define l_viginc           like abamapol.viginc
 define l_vigfnl           like abamapol.vigfnl
 define l_autimsvlr        like abbmcasco.imsvlr
 define l_imsvlr           like abbmbli.imsvlr
 define l_dmtimsvlr        like abbmdm.imsvlr
 define l_dpsimsvlr        like abbmdp.imsvlr
 define l_imsmorvlr        like abbmapp.imsmorvlr
 define l_imsinvvlr        like abbmapp.imsinvvlr
 define l_imsdmhvlr        like abbmapp.imsdmhvlr
 define l_vclmrcnom        like agbkmarca.vclmrcnom
 define l_vcltipnom        like agbktip.vcltipnom
 define l_vclmdlnom        like agbkveic.vclmdlnom
 define l_vcllicnum        like abbmveic.vcllicnum
 define l_vclanofbc        like abbmveic.vclanofbc
 define l_vclanomdl        like abbmveic.vclanomdl
 define l_prpnumdig        like datrligprp.prpnumdig
 define l_c24srvdsc        like datmservhist.c24srvdsc
 define l_vcldes           like datmservico.vcldes

 initialize   a_cts01g00   to null
 let l_resultado       =   0
 let arr_aux           =   0
 let l_doc_handle      =   0
 let l_franqvlr        =   null
 let l_mensagem        =   null
 let l_sitdes          =   null
 let l_vclchs          =   null
 let l_veic_codigo     =   null
 let l_veic_marca      =   null
 let l_veic_tipo       =   null
 let l_veic_modelo     =   null
 let l_veic_chassi     =   null
 let l_veic_placa      =   null
 let l_veic_anofab     =   null
 let l_veic_anomod     =   null
 let l_veic_catgtar    =   null
 let l_veic_automatico =   null
 let l_atdantflg       =   null
 let l_viginc          =   null
 let l_vigfnl          =   null
 let l_autimsvlr       =   null
 let l_imsvlr          =   null
 let l_dmtimsvlr       =   null
 let l_dpsimsvlr       =   null
 let l_imsmorvlr       =   null
 let l_imsinvvlr       =   null
 let l_imsdmhvlr       =   null
 let l_vclmrcnom       =   null
 let l_vcltipnom       =   null
 let l_vclmdlnom       =   null
 let l_vcllicnum       =   null
 let l_vclanofbc       =   null
 let l_vclanomdl       =   null
 let l_prpnumdig       =   null
 let l_c24srvdsc       =   null
 let l_vcldes          =   null

 if m_cts01g00_sql is null or
    m_cts01g00_sql = false then
    call cts01g00_prepare()
 end if

 #---------------------------------------------------
 # 01 - Verifica ATENDIMENTO SEM DOCUMENTO INFORMADO
 #---------------------------------------------------
 if (lr_param.ramcod    is null  or
     lr_param.succod    is null  or
     lr_param.aplnumdig is null )  and
     g_ppt.cmnnumdig is null       then

    let arr_aux = arr_aux + 1

    select prpnumdig
      from datmligacao, datrligprp
     where datmligacao.atdsrvnum = lr_param.atdsrvnum
       and datmligacao.atdsrvano = lr_param.atdsrvano
       and datrligprp.lignum     = datmligacao.lignum

    if sqlca.sqlcode = notfound  then
       let g_hdk.sem_docto            = "S" --> Sem Docto
       let a_cts01g00[arr_aux].inccod = 01  # SEM DOC.
    else
       let A_Cts01G00[Arr_Aux].Inccod = 11  # Sem Doc.C/Proposta
    end if

    if lr_param.orgcod  =  "R"   then
       let l_log = "Bloco 1 ",  a_cts01g00[arr_aux].inccod
       call errorlog(l_log)
    end if

     call cts01g00_descr(a_cts01g00[arr_aux].inccod)
          returning a_cts01g00[arr_aux].incdsc

    #---------------------------------------------------------------
    # Verifica solicitacao anterior 24/48 horas
    #---------------------------------------------------------------
    if lr_param.orgcod  =  "R"   then
       call cts01g00_solic(lr_param.atdsrvorg, lr_param.ramcod   , lr_param.succod,
                           lr_param.aplnumdig, lr_param.itmnumdig, lr_param.vcllicnum,
                           lr_param.atdsrvnum, lr_param.atdsrvano, lr_param.atdrefdat)
            returning ws.atdantflg
       if ws.atdantflg  =  "S"   then

          let arr_aux = arr_aux + 1
          let a_cts01g00[arr_aux].inccod = 10

          call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                    returning a_cts01g00[arr_aux].incdsc
       end if
    end if

 else
     #---------------------------------------------------
     # >> BUSCA L_DOC_HANDLE
     #---------------------------------------------------
     call cts42g00_doc_handle(lr_param.succod,
                              lr_param.ramcod,
                              lr_param.aplnumdig,
                              lr_param.itmnumdig,
                              lr_param.edsnumref)
          returning l_resultado
                  , l_mensagem
                  , l_doc_handle

     if l_doc_handle is not null then
        #---------------------------------------------------
        # 02 - Verifica DOCUMENTO VENCIDO
        #---------------------------------------------------
        call cts38m00_extrai_vigencia(l_doc_handle)
             returning l_viginc,
                       l_vigfnl

        if l_vigfnl < today then
           let arr_aux = arr_aux + 1
           let a_cts01g00[arr_aux].inccod = 02

           call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                returning a_cts01g00[arr_aux].incdsc
        end if

        #---------------------------------------------------
        # 03 - Verifica DOCUMENTO CANCELADO
        #---------------------------------------------------
        call cts38m00_extrai_situacao(l_doc_handle)
             returning l_sitdes

        if l_sitdes = "CANCELADA" then
           let arr_aux = arr_aux + 1
           let a_cts01g00[arr_aux].inccod = 03

           call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                returning a_cts01g00[arr_aux].incdsc
        end if

        #---------------------------------------------------
        # 05 - Verifica CORTESIA - DOCUMENTO SEM CLAUSULA
        #---------------------------------------------------
        if lr_param.c24astcod = "K90"  or
           lr_param.c24astcod = "K93"  then
           let arr_aux = arr_aux + 1
           let a_cts01g00[arr_aux].inccod = 05

           call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                returning a_cts01g00[arr_aux].incdsc
        end if

        #---------------------------------------------------
        # 06 - Verifica DOCUMENTO SEM A COBERTURA CASCO
        #---------------------------------------------------
         call cts40g02_extraiDoXML(l_doc_handle,'IS')
                 returning l_autimsvlr
                         , l_imsvlr
                         , l_dmtimsvlr
                         , l_dpsimsvlr
                         , l_imsmorvlr
                         , l_imsinvvlr
                         , l_imsdmhvlr
                         , l_franqvlr

        if l_autimsvlr is null or
           l_autimsvlr = 0 then
           let arr_aux = arr_aux + 1
           let a_cts01g00[arr_aux].inccod = 06

           call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                returning a_cts01g00[arr_aux].incdsc
        end if

        #---------------------------------------------------
        # 07 - Verifica DADOS DO VEICULO NAO CONFEREM
        #---------------------------------------------------
         call cts38m00_extrai_dados_veicul(l_doc_handle)
              returning l_vclmrcnom,
                        l_vcltipnom,
                        l_vclmdlnom,
                        l_vclchs,
                        l_vcllicnum,
                        l_vclanofbc,
                        l_vclanomdl

        # PEGA VCLDES
          call cts40g02_extraiDoXML(l_doc_handle,
                                        "VEICULO")
               returning l_veic_codigo,
                         l_veic_marca,
                         l_veic_tipo,
                         l_veic_modelo,
                         l_veic_chassi,
                         l_veic_placa,
                         l_veic_anofab,
                         l_veic_anomod,
                         l_veic_catgtar,
                         l_veic_automatico

          let l_vcldes = cts15g00(l_veic_codigo)

         if lr_param.vclanomdl <> l_vclanomdl or
            lr_param.vcllicnum <> l_vcllicnum or
            lr_param.vcldes    <> l_vcldes    then
            let arr_aux = arr_aux + 1
            let a_cts01g00[arr_aux].inccod = 07

            call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                 returning a_cts01g00[arr_aux].incdsc
         end if

#
#        #---------------------------------------------------
#        # 10 - Verifica OUTRA SOLICITACAO NO PRAZO DE 24/48 HORAS
#        #---------------------------------------------------
#        if lr_param.orgcod  =  "R"   then
#             call cts01g00_solic( lr_param.atdsrvorg
#                                , lr_param.ramcod
#                                , lr_param.succod
#                                , lr_param.aplnumdig
#                                , lr_param.itmnumdig
#                                , lr_param.vcllicnum
#                                , lr_param.atdsrvnum
#                                , lr_param.atdsrvano
#                                , lr_param.atdrefdat   )
#                   returning l_atdantflg
#
#              if l_atdantflg  =  "S"   then
#                 let arr_aux = arr_aux + 1
#                 let a_cts01g00[arr_aux].inccod = 10
#
#                 call cts01g00_descr(a_cts01g00[arr_aux].inccod)
#                      returning a_cts01g00[arr_aux].incdsc
#              end if
#           end if
#
#        #---------------------------------------------------
#        # 11 - Verifica ATENDIMENTO POR PROPOSTA
#        #---------------------------------------------------
#           whenever error continue
#             open c1_cts01g00_001 using lr_param.atdsrvnum
#                                      , lr_param.atdsrvano
#             fetch c1_cts01g00_001 into l_prpnumdig
#           whenever error stop
#
#           if sqlca.sqlcode = 0  then
#              let arr_aux = arr_aux + 1
#              let a_cts01g00[arr_aux].inccod = 11
#
#              call cts01g00_descr(a_cts01g00[arr_aux].inccod)
#                   returning a_cts01g00[arr_aux].incdsc
#           end if

        #---------------------------------------------------
        # 12 - Verifica SERVICOS COM OFICINAS EM OBSERVACAO
        #---------------------------------------------------
           whenever error continue
             open c1_cts01g00_002 using lr_param.atdsrvnum
                                      , lr_param.atdsrvano
             fetch c1_cts01g00_002 into l_c24srvdsc
           whenever error stop

        if l_c24srvdsc = "OF CORT MOTIVO:" then
           let arr_aux = arr_aux + 1
           let a_cts01g00[arr_aux].inccod = 12

           call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                returning a_cts01g00[arr_aux].incdsc
        end if
     end if # l_doc_handle is not null
  end if # com/sem documento

# COMENTADO : PROCESSO ABORDA SOMENTE BATCH
#
# #-------------------------------------------------------------------------
# # Exibe pop-up de erros encontrados
# #-------------------------------------------------------------------------
#let arr_aux = arr_aux + 1
#
# if lr_param.orgcod = "T"             and
#    (   g_abre_tela is null or
#        g_abre_tela = "S"       )     then   --> let em cta02m00
#
#    open window cts01g00 at 10,18 with form "cts01g00"
#                         attribute(form line first, border)
#
#    display "               Inconsistencias              "  to  cabecalho attribute (reverse)
#
#    let int_flag = false
#
#    message " (F17)Abandona"
#    call set_count(arr_aux)
#
#
#    display array a_cts01g00 to s_cts01g00.*
#       #on key (interrupt,control-c)
#       #   exit display
#    end display
#
#    close window  cts01g00
# end if
#
#
# let int_flag = false

 return a_cts01g00[01].inccod,
        a_cts01g00[02].inccod,
        a_cts01g00[03].inccod,
        a_cts01g00[04].inccod,
        a_cts01g00[05].inccod,
        a_cts01g00[06].inccod,
        a_cts01g00[07].inccod,
        a_cts01g00[08].inccod,
        a_cts01g00[09].inccod,
        a_cts01g00[10].inccod,
        a_cts01g00[11].inccod,
        a_cts01g00[12].inccod

end function


#==========================================================================
 function cts01g00_itau(lr_param)
#==========================================================================

define lr_param  record
   ramcod         like datrservapol.ramcod    ,
   succod         like datrservapol.succod    ,
   aplnumdig      like datrservapol.aplnumdig ,
   itmnumdig      like datrservapol.itmnumdig ,
   edsnumref      like datrservapol.edsnumref ,  #--> aplseqnum
   c24astcod      like datmligacao.c24astcod  ,
   atdsrvorg      like datmservico.atdsrvorg  ,
   vcldes         like datmservico.vcldes     ,
   vclanomdl      like datmservico.vclanomdl  ,
   vcllicnum      like datmservico.vcllicnum  ,
   atdsrvnum      like datmservico.atdsrvnum  ,
   atdsrvano      like datmservico.atdsrvano  ,
   atdrefdat      date                        ,
   orgcod         char (01)                     # (T)ela  ou  (R)elatorio
end record

define a_cts01g00 array[12] of record
    inccod         smallint ,
    incdsc         char (50)
end record

 define ws         record
    daftip         char (01)                   ,
    dafdat         date                        ,
    dafdoc         char (01)                   ,
    qtdatd         smallint                    ,
    aplstt         like abamapol.aplstt        ,
    clscod         like abbmclaus.clscod       ,
    clscodant      like abbmclaus.clscod       ,
    dctnumseq      like abbmveic.dctnumseq     ,
    vclcoddig      like abbmveic.vclcoddig     ,
    sgrorg         like rsamseguro.sgrorg      ,
    sgrnumdig      like rsamseguro.sgrnumdig   ,
    rmemdlcod      like rsamseguro.rmemdlcod   ,
    edstip         like rsdmdocto.edstip       ,
    edsstt         like rsdmdocto.edsstt       ,
    prporg         like rsdmdocto.prporg       ,
    prpnumdig      like rsdmdocto.prpnumdig    ,
    atdantflg      char (01)                   ,
    c24srvdsc      like datmservhist.c24srvdsc
 end record

define arr_aux            smallint
define l_flag             smallint
define l_erro             integer
define l_mensagem         char(50)
define l_sitdes           char(1)
define l_vcldes           char(75)
define l_atdantflg        char(1)
define l_itaciacod        like datrligitaaplitm.itaciacod
define l_prpnumdig        like datrligprp.prpnumdig
define l_c24srvdsc        like datmservhist.c24srvdsc
define l_log              char(100)

 let arr_aux     = 0
 let l_flag      = 0
 let l_erro      = 0
 let l_mensagem  = null
 let l_itaciacod = null
 let l_sitdes    = null
 let l_vcldes    = null
 let l_itaciacod = null
 let l_atdantflg = null
 let l_prpnumdig = null
 let l_c24srvdsc = null
 initialize a_cts01g00 to null

 if m_cts01g00_sql is null or
    m_cts01g00_sql = false then
    call cts01g00_prepare()
 end if

 #---------------------------------------------------
 # 01 - Verifica ATENDIMENTO SEM DOCUMENTO INFORMADO
 #---------------------------------------------------
if (lr_param.ramcod    is null  or
     lr_param.succod    is null  or
     lr_param.aplnumdig is null )  and
     g_ppt.cmnnumdig is null       then

    let arr_aux = arr_aux + 1

    select prpnumdig
      from datmligacao, datrligprp
     where datmligacao.atdsrvnum = lr_param.atdsrvnum
       and datmligacao.atdsrvano = lr_param.atdsrvano
       and datrligprp.lignum     = datmligacao.lignum

    if sqlca.sqlcode = notfound  then
       let g_hdk.sem_docto            = "S" --> Sem Docto
       let a_cts01g00[arr_aux].inccod = 01  # SEM DOC.
    else
       let a_cts01g00[arr_aux].inccod = 11  # SEM DOC.C/PROPOSTA
    end if

    if lr_param.orgcod  =  "R"   then
       let l_log = "Bloco 1 ",  a_cts01g00[arr_aux].inccod
       call errorlog(l_log)
    end if

     call cts01g00_descr(a_cts01g00[arr_aux].inccod)
          returning a_cts01g00[arr_aux].incdsc
    #---------------------------------------------------------------
    # Verifica solicitacao anterior 24/48 horas
    #---------------------------------------------------------------
     if lr_param.orgcod  =  "R"   then
       call cts01g00_solic(lr_param.atdsrvorg, lr_param.ramcod   , lr_param.succod,
                           lr_param.aplnumdig, lr_param.itmnumdig, lr_param.vcllicnum,
                           lr_param.atdsrvnum, lr_param.atdsrvano, lr_param.atdrefdat)
            returning ws.atdantflg
       if ws.atdantflg  =  "S"   then

          let arr_aux = arr_aux + 1
          let a_cts01g00[arr_aux].inccod = 10

          call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                    returning a_cts01g00[arr_aux].incdsc
       end if
    end if

 else
    #---------------------------------------------------
    # >> RECUPERA COMPANHIA ITAU - itaciacod
    #---------------------------------------------------
    whenever error continue
      open c1_cts01g00_003 using lr_param.ramcod
                               , lr_param.aplnumdig
                               , lr_param.edsnumref #--> aplseqnum
                               , lr_param.itmnumdig
      fetch c1_cts01g00_003 into l_itaciacod
    whenever error stop

    if sqlca.sqlcode <> 0 and
       sqlca.sqlcode <> 100 then
       display 'Erro (',sqlca.sqlcode,') ao recuperar Companhia Itau! Avise a Inf.'
       let l_flag = 1
    end if

    if l_itaciacod is null or
       l_itaciacod = ' ' then
       display 'Companhia Itau nao encontrada - (cts01g00_itau)'
       let l_flag = 1
    end if

    #---------------------------------------------------
    # >> RECUPERA DADOS DO ITAU - global g_doc_itau (glct)
    #---------------------------------------------------
    if l_flag = 0 then
       call cty22g00_rec_dados_itau( l_itaciacod
                                   , lr_param.ramcod
                                   , lr_param.aplnumdig
                                   , lr_param.edsnumref #--> aplseqnum
                                   , lr_param.itmnumdig )
             returning l_erro,
                       l_mensagem



      #---------------------------------------------------
      # 02 - Verifica DOCUMENTO VENCIDO
      #---------------------------------------------------
       if g_doc_itau[1].itaaplvigfnldat < today then
          let arr_aux = arr_aux + 1
          let a_cts01g00[arr_aux].inccod = 02

          call cts01g00_descr(a_cts01g00[arr_aux].inccod)
               returning a_cts01g00[arr_aux].incdsc
       end if

      #---------------------------------------------------
      # 03 - Verifica DOCUMENTO CANCELADO
      #---------------------------------------------------
       if g_doc_itau[1].itaaplitmsttcod = "C" then
          let arr_aux = arr_aux + 1
          let a_cts01g00[arr_aux].inccod = 03

          call cts01g00_descr(a_cts01g00[arr_aux].inccod)
               returning a_cts01g00[arr_aux].incdsc
       end if


      #---------------------------------------------------
      # 05 - Verifica CORTESIA - DOCUMENTO SEM CLAUSULA
      #---------------------------------------------------
       if lr_param.c24astcod = "I31"  or
          lr_param.c24astcod = "I32"  then
          let arr_aux = arr_aux + 1
          let a_cts01g00[arr_aux].inccod = 05

          call cts01g00_descr(a_cts01g00[arr_aux].inccod)
               returning a_cts01g00[arr_aux].incdsc
       end if

      #---------------------------------------------------
      # 07 - Verifica DADOS DO VEICULO NAO CONFEREM
      #---------------------------------------------------
       let l_vcldes = g_doc_itau[1].autfbrnom clipped, " ",
                      g_doc_itau[1].autlnhnom clipped, " ",
                      g_doc_itau[1].autmodnom

       if lr_param.vclanomdl <> g_doc_itau[1].autmodano or
          lr_param.vcllicnum <> g_doc_itau[1].autplcnum or
          lr_param.vcldes    <> l_vcldes    then
          let arr_aux = arr_aux + 1
          let a_cts01g00[arr_aux].inccod = 07

          call cts01g00_descr(a_cts01g00[arr_aux].inccod)
               returning a_cts01g00[arr_aux].incdsc
       end if

#      #---------------------------------------------------
#      # 10 - Verifica OUTRA SOLICITACAO NO PRAZO DE 24/48 HORAS
#      #---------------------------------------------------
#       if lr_param.orgcod  =  "R"   then
#             call cts01g00_solic( lr_param.atdsrvorg
#                                , lr_param.ramcod
#                                , lr_param.succod
#                                , lr_param.aplnumdig
#                                , lr_param.itmnumdig
#                                , lr_param.vcllicnum
#                                , lr_param.atdsrvnum
#                                , lr_param.atdsrvano
#                                , lr_param.atdrefdat   )
#                   returning l_atdantflg
#
#              if l_atdantflg  =  "S"   then
#                 let arr_aux = arr_aux + 1
#                 let a_cts01g00[arr_aux].inccod = 10
#
#                 call cts01g00_descr(a_cts01g00[arr_aux].inccod)
#                      returning a_cts01g00[arr_aux].incdsc
#              end if
#        end if
#
#      #---------------------------------------------------
#      # 11 - Verifica ATENDIMENTO POR PROPOSTA
#      #---------------------------------------------------
#          whenever error continue
#            open c1_cts01g00_001 using lr_param.atdsrvnum
#                                     , lr_param.atdsrvano
#            fetch c1_cts01g00_001 into l_prpnumdig
#          whenever error stop
#
#          if sqlca.sqlcode = 0  then
#             let arr_aux = arr_aux + 1
#             let a_cts01g00[arr_aux].inccod = 11
#
#             call cts01g00_descr(a_cts01g00[arr_aux].inccod)
#                  returning a_cts01g00[arr_aux].incdsc
#          end if

      #---------------------------------------------------
      # 12 - Verifica SERVICOS COM OFICINAS EM OBSERVACAO
      #---------------------------------------------------
          whenever error continue
            open c1_cts01g00_002 using lr_param.atdsrvnum
                                     , lr_param.atdsrvano
            fetch c1_cts01g00_002 into l_c24srvdsc
          whenever error stop

        if l_c24srvdsc = "OF CORT MOTIVO:" then
           let arr_aux = arr_aux + 1
           let a_cts01g00[arr_aux].inccod = 12

           call cts01g00_descr(a_cts01g00[arr_aux].inccod)
                returning a_cts01g00[arr_aux].incdsc
        end if


    end if

 end if     # com/sem documento

 return a_cts01g00[01].inccod,
        a_cts01g00[02].inccod,
        a_cts01g00[03].inccod,
        a_cts01g00[04].inccod,
        a_cts01g00[05].inccod,
        a_cts01g00[06].inccod,
        a_cts01g00[07].inccod,
        a_cts01g00[08].inccod,
        a_cts01g00[09].inccod,
        a_cts01g00[10].inccod,
        a_cts01g00[11].inccod,
        a_cts01g00[12].inccod

end function

#==========================================================================
 function cts01g00_valida_endosso_itau(lr_param)
#==========================================================================
define lr_param record
       succod    like datrservapol.succod    ,
       ramcod    like datrservapol.ramcod    ,
       aplnumdig like datrservapol.aplnumdig
end record
define lr_retorno record
      edsnumref like datrservapol.edsnumref ,
      ramsgl    char(15)                    ,
      resultado smallint                    ,
      mensagem  char(60)                    ,
      descricao char(60)
end record
initialize lr_retorno.* to null
    call cty22g00_rec_ult_sequencia(g_documento.itaciacod ,
                                    lr_param.ramcod       ,
                                    lr_param.aplnumdig    )
    returning lr_retorno.edsnumref,
              lr_retorno.resultado,
              lr_retorno.mensagem
     # Se continuar nulo seta para 1
     if lr_retorno.edsnumref is null then
        let lr_retorno.edsnumref = 1
     end if
     return lr_retorno.edsnumref
end function
