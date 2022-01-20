############################################################################
# Nome de Modulo: CTB25M01                                          Raji   #
#                                                                          #
# Analise/Manutencao do valor e itens adicionais                  Mar/2003 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 07/06/2004  Teresinha Silva - CT 206768 - Alterar o vlr do km de *5 para #
#                               * 6                                        #
############################################################################
#                   * * * Alteracoes * * *                                 #
#                                                                          #
# Data       Autor Fabrica     Origem     Alteracao                        #
# ---------- ----------------- ---------- ---------------------------------#
# 24/03/2004 Robson, Meta      PSI187143  Mudar caminho das globais, prompt#
#                                         e condicao de gravacao. Tambem   #
#                                         mudar a gravacao do registro.    #
#--------------------------------------------------------------------------#
# 05/10/2004 Adriana,Meta      PSI197801  Inclusao do Motivo de Pendencia/ #
#                                         Observacoes                      #
#--------------------------------------------------------------------------#
# 25/11/2004 Cristina,EME     CH4096266   Incluir o campo incvlr no update #
#                                         pctb25m01001                     #
#--------------------------------------------------------------------------#
#..........................................................................#
#                                                                          #
#                  * * * Alteracoes * * *                                  #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ------------------------------------#
# 03/12/2004  Mariana,Meta   PSI188220 Mostrar a media de km extra         #
#                                     (dpakmedkmt.medkmtqtd)               #
# 29/12/2005  Cristiane Silva PSI197467 Apresentar valor automático quando #
#                                       implementar qtde de KM Auto        #
# 30/06/2006  Cristiane Silva CT432490  Alterar calculo KM excedente       #
#--------------------------------------------------------------------------#
# 12/01/2007  Priscila       PSI205206 Incluir empresa do servico e limite #
#                                      de kilometragem                     #
#--------------------------------------------------------------------------#
# 02/07/2007  Burini         CT7068512 Alteração das mensagens de erro de  #
#                                      dados nao encontrados (ERRO 100)    #
# 08/10/2009  PSI 247790   Burini      Adequação de tabelas                #
#--------------------------------------------------------------------------#
# 15/03/2012  Celso Yamahaki PSI03847  Manter o valor informado pelo       #
#                                      Prestador                           #
#--------------------------------------------------------------------------#
# 03/07/2012  Beatriz Araujo PR-2012-00808 Segunda Fase do REALIZAR        #
#--------------------------------------------------------------------------#
# 15/01/2013  Ueslei Oliveira PSI07388 Remocao do campo kmmedio            #
#--------------------------------------------------------------------------#
# 09/03/2016  ElianeK, Fornax          Tratamento de mudanca de situacao   #
#                                      considerando a ALCADA               #
#--------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl" # PSI187143 - robson

  define d_ctb25m01  record
     vlrcstini       like datmservico.atdcstvlr,
     totcstadc       like datmservico.atdcstvlr,
     atdcstvlr       like datmservico.atdcstvlr,
     empresa         like gabkemp.empsgl,     #PSI 205206
     limite          char(52)                 #PSI 205206
    ,custopeca       char(45)
    ,segpgoexdvlr    like dbsmsrvacr.segpgoexdvlr
  end record

  define a_ctb25m01  array[50] of record
     soccstcod       like dbsmopgcst.soccstcod,
     soccstdes       like dbskcustosocorro.soccstdes,
     cstqtd          like dbsmsrvcst.socadccstqtd,
     socopgitmcst    like dbsmsrvcst.socadccstvlr,
     soccstclccod    like dbskcustosocorro.soccstclccod
  end record

 define ma_ret       array[500] of record
     flgsrv          char(01),
     atdsrvnum       like datmservico.atdsrvnum,
     atdsrvano       like datmservico.atdsrvano,
     atdetpdat       like datmsrvacp.atdetpdat,
     pstcoddig       like dpaksocor.pstcoddig,
     nomgrr          like dpaksocor.nomgrr,
     atdcstvlr       like datmservico.atdcstvlr
 end record

 define mr_semprr    record
     pdgqtd          integer,
     pdgttlvlr       decimal(15,2),
     totsrv          decimal(13,2)
 end record


define am_ctb25m01    array[05] of record
       dbsmsrvacrobs   like dbsmsrvacrobs.srvacrobs
end record

define m_totobs    smallint,
       m_existe    char(01),
       l_lixo      smallint,
       m_cadsemprr smallint

# PSI187143 - robson - inicio

define m_prep_sql smallint

#--------------------------#
function ctb25m01_prepare()
#--------------------------#
 define l_sql char(800)

 let l_sql = ' update dbsmsrvacr '
               ,' set (incvlr, fnlvlr, anlokaflg, anlokadat, anlokahor, '
                    ,' anlusrtip, anlemp, anlmat) '
                 ,' = (?, ?, ?, today, current,?,?,?) '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '

 prepare pctb25m01001 from l_sql

 #PSI03847 Inicio
 let l_sql = ' select fnlvlr ',
             '   from dbsmsrvacr ',
             '  where atdsrvnum = ? ',
             '    and atdsrvano = ? '
 prepare pctb25m01022 from l_sql
 declare cctb25m01022 cursor for pctb25m01022

 let l_sql = ' update dbsmsrvacr '
               ,' set (prsvlr)'
                 ,' = (?) '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '

 prepare pctb25m01021 from l_sql

 let l_sql = ' select prsvlr ',
             '   from dbsmsrvacr ',
             '  where atdsrvnum = ? ',
             '    and atdsrvano = ? '
 prepare pctb25m01023 from l_sql
 declare cctb25m01023 cursor for pctb25m01023

 let l_sql = ' update dbsmsrvacr  '
            ,'    set (anlokahor, '
            ,'         anlusrtip, '
            ,'         anlemp,    '
            ,'         anlmat   ) '
            ,'      = (current,   '
            ,'         ?,?,?)     '
            ,'  where atdsrvnum = ? '
            ,'    and atdsrvano = ? '
 prepare pctb25m01024 from l_sql

 #PSI03847 Fim

let l_sql = ""
let l_sql = " select srvacrobslinseq,srvacrobs from  dbsmsrvacrobs  ",
            " where atdsrvnum = ? and ",
            "       atdsrvano = ?     ",
            " order by srvacrobslinseq "
prepare pctb25m01002 from l_sql
whenever error continue
declare cctb25m01002 cursor for  pctb25m01002
whenever error stop

if sqlca.sqlcode < 0 then
   error "Erro cctb25m01002:",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
   sleep 2
   error "ctb25m01_prepare/"
   sleep 2
   error ""
   return
end if


let l_sql = ""
let l_sql = " insert into dbsmsrvacrobs values (?,?,?,?) "
whenever error continue
prepare pctb25m01003 from l_sql
whenever error stop
if sqlca.sqlcode < 0 then
   error "Erro pctb25m01003:",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
   sleep 2
   error "ctb25m01_prepare/"
   sleep 2
   error ""
   return
end if

#let l_sql = ""
#let l_sql = " update dbsmsrvacrobs set srvacrobs = ? ",
#            " where atdsrvnum = ? and ",
#            "       atdsrvano = ? and ",
#            "       srvacrobslinseq = ? "
#
#whenever error continue
#prepare pctb25m01004 from l_sql
#whenever error stop
#if sqlca.sqlcode < 0 then
#   error "Erro pctb25m01004:",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
#   sleep 2
#   error "ctb25m01_prepare/"
#   sleep 2
#   error ""
#   return
#end if

let l_sql = " delete from dbsmsrvacrobs ",
            " where atdsrvnum = ? and ",
            "       atdsrvano = ? and ",
            "       srvacrobslinseq = ? "
whenever error continue
prepare pctb25m01004 from l_sql


let l_sql = ' delete from dbsmsrvacrobs '
           ,'  where atdsrvnum = ? '
           ,'    and atdsrvano = ? '
prepare pctb25m01005 from l_sql


let l_sql = ' select a.medkmtqtd '
           ,'   from dpakmedkmt a,datmlcl b, datmlcl c '
           ,'  where a.ufdorgcod = b.ufdcod    '
           ,'    and a.cidorgnom = b.cidnom    '
           ,'    and a.ufddstcod = c.ufdcod    '
           ,'    and a.ciddstnom = c.cidnom    '
           ,'    and b.atdsrvnum = ?           '
           ,'    and b.atdsrvano = ?           '
           ,'    and b.c24endtip = 1           '
           ,'    and c.c24endtip = 2           '
           ,'    and c.atdsrvnum = b.atdsrvnum '
           ,'    and c.atdsrvano = b.atdsrvano '

prepare pctb25m01006 from l_sql
declare cctb25m01006 cursor for pctb25m01006


#Identifica a tarifa do socorrista
let l_sql = ' select socor.soctrfcod from dpaksocor socor, datmservico srv ',
            ' where socor.pstcoddig = srv.atdprscod ',
            ' and srv.atdsrvnum = ? ',
            ' and srv.atdsrvano = ? '
prepare pctb25m01007 from l_sql
declare cctb25m01007 cursor for pctb25m01007

#identifica a data do servico
let l_sql = ' select  atddat, vclcoddig, asitipcod from datmservico ',
            ' where atdsrvnum = ? ',
            ' and atdsrvano = ? '
prepare pctb25m01008 from l_sql
declare cctb25m01008 cursor for pctb25m01008

#Identifica a vigencia
let l_sql = ' select soctrfvignum ',
' from dbsmvigtrfsocorro ',
' where soctrfcod = ? ',
' and soctrfvigincdat <= ? ',
' and soctrfvigfnldat >= ?'
prepare pctb25m01009 from l_sql
declare cctb25m01009 cursor for pctb25m01009

#identifica o valor do custo
let l_sql = ' select socgtfcstvlr ',
            ' from dbstgtfcst ',
            ' where soctrfvignum  = ? ',
            ' and socgtfcod     = ? ',
            ' and soccstcod     = ? '
prepare pctb25m01010 from l_sql
declare cctb25m01010 cursor for pctb25m01010

let l_sql  = "  select pasasivcldes "
                 , "    from datmtrptaxi  "
                 , "   where atdsrvnum = ?"
                ,  "     and atdsrvano = ?"
prepare pctb25m01011 from l_sql
declare cctb25m01011 cursor for pctb25m01011

let l_sql  = "  select grlinf, "
                 , "         grlchv "
                 , "    from datkgeral  "
                 , "   where grlchv >= ? "
                 , "     and grlchv <= ? "
                 , "    order by grlchv desc "
prepare pctb25m01012 from l_sql
declare cctb25m01012 cursor for pctb25m01012


let l_sql  = "select atdetphor    ",
              "  from datmsrvacp   ",
              " where atdsrvnum = ?",
              "   and atdsrvano = ?",
              "   and atdsrvseq = (select max(atdsrvseq)",
                                  "  from datmsrvacp    ",
                                  " where atdsrvnum = ? ",
                                  "   and atdsrvano = ?)"
prepare pctb25m01013 from l_sql
declare cctb25m01013 cursor for pctb25m01013

let l_sql  ="select pdgqtd, ",
                  " pdgttlvlr ",
             " from dbarsemprrsrv ",
            " where atdsrvnum = ? ",
              " and atdsrvano = ? "

prepare pctb25m01014 from l_sql
declare cctb25m01014 cursor for pctb25m01014

let l_sql  = "insert into dbarsemprrsrv values (?,?,?,?) "

prepare pctb25m01015 from l_sql

let l_sql  = "update dbarsemprrsrv ",
               " set pdgqtd    = ? ,",
                   " pdgttlvlr = ? ",
             " where atdsrvnum = ? ",
               " and atdsrvano = ? "

prepare pctb25m01016 from l_sql

let l_sql  = "delete from dbarsemprrsrv ",
             " where atdsrvnum = ? ",
               " and atdsrvano = ? "

prepare pctb25m01017 from l_sql

let l_sql  = "select atdprscod ",
              " from datmservico ",
             " where atdsrvnum = ? ",
               " and atdsrvano = ? "

prepare pctb25m01018 from l_sql
declare cctb25m01018 cursor for pctb25m01018


let l_sql = "select a.ramcod,    ",
            "       a.aplnumdig, ",
            "       a.itmnumdig, ",
            "       a.edsnumref, ",
            "       b.itaciacod  ",
            " from datrligapol a,",
            "      datrligitaaplitm b ",
            "where a.lignum = (select MIN(lignum)",
            "                    from datmligacao",
            "                   where atdsrvnum = ?",
            "                     and atdsrvano = ? )",
            "   and a.lignum = b.lignum"

  prepare pctb25m01019 from l_sql
  declare cctb25m01019 cursor for pctb25m01019


 let l_sql = ' update dbsmsrvacr  '
            ,'    set anlokaflg = ? '
            ,'  where atdsrvnum = ? '
            ,'    and atdsrvano = ? '
 prepare pctb25m01025 from l_sql


  let l_sql = " select cpodes[1,6] ",
              " from datkdominio ",
	      " where  cponom = 'ALCADA' "
  prepare pctb25m01030 from l_sql
  declare cctb25m01030 cursor for pctb25m01030

let m_prep_sql = true

end function

# PSI187143 - robson - fim

#--------------------------------------------------------------------
function ctb25m01(param)
#--------------------------------------------------------------------
  define param       record
     atdsrvnum       like dbsmsrvacr.atdsrvnum,
     atdsrvano       like dbsmsrvacr.atdsrvano,
     situacao        char(01)
  end record

  define ws          record
     totcstvlr       like datmservico.atdcstvlr,
     pgtdat          like datmservico.pgtdat   ,
     socopgnum       like dbsmopg.socopgnum    ,
     sqlca_preacp    integer,
     atdsrvorg       like datmservico.atdsrvorg,
     soccstexbseq    like dbskcustosocorro.soccstexbseq,
     operacao        char (01),
     confirma        char (01),
     flgsai          smallint,
     comando         char (800),
     socntzdes       like datksocntz.socntzdes,
     socntzcod       like datmsrvre.socntzcod,
     vlrsugerido     like dbsmopgitm.socopgitmvlr,
     vlrmaximo       like dbsmopgitm.socopgitmvlr,
     vlrdiferenc     like dbsksrvrmeprc.srvrmedifvlr,
     vlrmltdesc      like dbsksrvrmeprc.srvrmedscmltvlr,
     qtdsrv          smallint,   # (1-OK um srv)(2-demais srvs.)
     flgtab          smallint,    # (1-tabela) (2-tabela inexistente)
     atddat          like datmservico.atddat,
     soctrfcod       like dpaksocor.soctrfcod,
     soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum,
     socgtfcstvlr    like dbstgtfcst.socgtfcstvlr,
     socgtfcod       like dbstgtfcst.socgtfcod,
     erro            char(01),
     vclcoddig       like datmservico.vclcoddig,
     valor           decimal(10,5),
     asitipcod       like datmservico.asitipcod,
     atdetphor       like datmsrvacp.atdetphor,
     atdprscod       like datmservico.atdprscod,
     vlrprm          like dbsmopgitm.socopgitmvlr
  end record

  define l_histerr   smallint
  define arr_aux     smallint
  define scr_aux     smallint
  define l_confirma  char (01)
  define l_lighorinc    like datmservhist.lighorinc

  define l_cont   smallint,
         l_srvacrobslinseq smallint
        ,l_for   smallint


  define l_pasasivcldes  like datmtrptaxi.pasasivcldes
  define l_inicio    like datkgeral.grlchv
  define l_final     like datkgeral.grlchv
  define l_lixo      char(50)
  define l_valor     like dbsmopgitm.socopgitmvlr
  define l_data      char(12)
  define l_ciaempcod like datmservico.ciaempcod    #PSI 205206
  define l_succod    like datrservapol.succod   ,
         l_ramcod    like datrservapol.ramcod   ,
         l_aplnumdig like datrservapol.aplnumdig,
         l_itmnumdig like datrservapol.itmnumdig,
         l_edsnumref like datrservapol.edsnumref,
         l_azlaplcod like datkazlapl.azlaplcod,
         l_doc_handle integer,
         l_kmlimite  char(3),
         l_kmqtde    char(3),
         l_kmlimiteaux integer,
         l_mobrefvlr like dpakpecrefvlr.mobrefvlr,
         l_pecmaxvlr like dpakpecrefvlr.pecmaxvlr

  define l_retorno   smallint,
         l_saida     smallint,
         l_mensagem  char(50),
         l_param     char(03)

  define lr_erro record
                     err             smallint,
                     msgerr          char(100)
  end record


   define lr_retorno record
         pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
         socqlmqtd     like datkitaasipln.socqlmqtd    ,
         erro          integer,
         mensagem      char(50)
  end record

  define l_vlrpst like dbsmsrvacr.fnlvlr,
         l_prsvlr like dbsmsrvacr.prsvlr #PSI03847

  define lr_bnfpst    record
         prmqtd           smallint,
         prmvlr           decimal(5,2)
  end record

  define l_libera         char(01),
	 l_msg            char(80),
	 l_funmat         dec (06),
	 l_pode_liberar   char(01) 

  initialize d_ctb25m01      to null
  initialize a_ctb25m01      to null
  #initialize g_ppt.cmnnumdig to null
  initialize ws.*            to null
  initialize lr_retorno.* to null
  initialize lr_bnfpst.*  to null

  let l_ciaempcod   = null
  let l_succod      = null
  let l_ramcod      = null
  let l_aplnumdig   = null
  let l_itmnumdig   = null
  let l_edsnumref   = null
  let l_azlaplcod   = null
  let l_doc_handle  = null
  let l_kmlimite    = null
  let l_kmlimiteaux = null
  let l_kmqtde      = null
  let l_retorno     = null
  let l_mensagem    = null
  let m_cadsemprr   = null
  let l_confirma    = null
  let l_lighorinc   = null
  let l_funmat      = null
  let l_pode_liberar = null
  initialize l_vlrpst, l_prsvlr to null #PSI03847

# PSI187143 - robson - inicio
  if m_prep_sql is null or
     m_prep_sql <> true then
     call ctb25m01_prepare()
  end if
# PSI187143 - robson - fim

  let arr_aux = 1

  let ws.valor = 0.00
  let ws.socgtfcstvlr = 0.00

  #----------------------------------
  # Verifica SERVICO
  #----------------------------------
  select atdsrvorg, atdcstvlr, pgtdat, ciaempcod      #PSI 205206
    into ws.atdsrvorg, d_ctb25m01.atdcstvlr, ws.pgtdat, l_ciaempcod   #PSI 205206
    from datmservico
   where atdsrvnum = param.atdsrvnum
     and atdsrvano = param.atdsrvano

  if sqlca.sqlcode <> 0     and
     sqlca.sqlcode <> 100   then
     error " Erro (", sqlca.sqlcode, ") na leitura do servico. AVISE A INFORMATICA!"
     return
  else
     #----------------------------------
     # Verifica se SERVICO ja' pago
     #----------------------------------
     select dbsmopg.socopgnum
       into ws.socopgnum
       from dbsmopgitm, dbsmopg
      where dbsmopgitm.atdsrvnum = param.atdsrvnum
        and dbsmopgitm.atdsrvano = param.atdsrvano
        and dbsmopgitm.socopgnum = dbsmopg.socopgnum
        and dbsmopg.socopgsitcod <> 8

     if sqlca.sqlcode <> 0     and
        sqlca.sqlcode <> 100   then
        error " Erro (", sqlca.sqlcode, ") na leitura da O.P. AVISE A INFORMATICA!"
        return
     end if
  end if

  if ws.pgtdat     is not null   or
     ws.socopgnum  is not null   then
     error " Nao e' possivel fazer o acerto de valor para servico ja' pago!"
     return
  end if

  let ws.comando ="select dbskcustosocorro.soccstexbseq, ",
                  "       dbskcustosocorro.soccstdes, ",
                  "       dbskcustosocorro.soccstclccod, ",
                  "       dbskcustosocorro.soccstcod, ",
                  "       dbsmsrvcst.socadccstqtd, ",
                  "       dbsmsrvcst.socadccstvlr ",
                  "  from dbskcustosocorro, outer dbsmsrvcst ",
                  " where dbskcustosocorro.soccstcod > 0 "

     if ws.atdsrvorg = 9 or
        ws.atdsrvorg = 13 then
        let ws.comando =ws.comando clipped,
                        "   and dbskcustosocorro.soctip    = 3 "
     else
        let ws.comando =ws.comando clipped,
                        "   and dbskcustosocorro.soctip    = 1 "
     end if
  let ws.comando =ws.comando clipped,
                  "   and dbsmsrvcst.soccstcod  = dbskcustosocorro.soccstcod ",
                  "   and dbsmsrvcst.atdsrvnum  = ? ",
                  "   and dbsmsrvcst.atdsrvano  = ? ",
            #      "   and (dbsmsrvcst.socadccstqtd > 0 or dbsmsrvcst.socadccstvlr > 0) "
                  " order by dbskcustosocorro.soccstexbseq "

  #display ws.comando

  prepare comando_aux1  from  ws.comando
  declare c_ctb25m01  cursor for  comando_aux1

  let ws.comando = "select datksocntz.socntzdes ",
                   "  from datmsrvre, datksocntz ",
                   " where datmsrvre.atdsrvnum  = ? ",
                   "   and datmsrvre.atdsrvano  = ? ",
                   "   and datksocntz.socntzcod = datmsrvre.socntzcod "
  prepare comando_aux2  from ws.comando
  declare c_datmsrvre cursor for comando_aux2

  open  c_datmsrvre using  param.atdsrvnum, param.atdsrvano
  fetch c_datmsrvre into   ws.socntzdes
  close c_datmsrvre

  # MONTA DADOS DA ORDEM DE PAGAMENTO
  #----------------------------------
  open window w_ctb25m01 at 03,18 with form "ctb25m01"
       attribute(form line first, border)

  display ws.socntzdes to socntzdes



  #----------------------------------------------------------------------
  #       PARA MONTAR CUSTOS DOS ITENS DA ORDEM DE PAGAMENTO : (c/tarifa)
  # -AGRUPA CUSTOS QUE ESTAO VIGENTES NA DATA DE ATENDIMENTO DO SERVICO
  # -CLASSIFICA POR ORDEM DE EXIBICAO DO CUSTO(PELO CADASTRO DE CUSTOS)
  # -MOSTRA O VALOR SE ESTE JA' FOI DIGITADO
  #----------------------------------------------------------------------
  open c_ctb25m01  using  param.atdsrvnum, param.atdsrvano

  foreach c_ctb25m01 into ws.soccstexbseq,
                          a_ctb25m01[arr_aux].soccstdes,
                          a_ctb25m01[arr_aux].soccstclccod,
                          a_ctb25m01[arr_aux].soccstcod,
                          a_ctb25m01[arr_aux].cstqtd,
                          a_ctb25m01[arr_aux].socopgitmcst

     if (a_ctb25m01[arr_aux].socopgitmcst  is null or
         a_ctb25m01[arr_aux].socopgitmcst = 0) and
        (a_ctb25m01[arr_aux].cstqtd        is null or
         a_ctb25m01[arr_aux].cstqtd       = 0) then
        initialize a_ctb25m01[arr_aux].* to null
        continue foreach
     end if


     #------------------------------------------------------
     # DESPREZA OS CUSTOS REFERENTES AS FAIXAS DE VALOR
     #------------------------------------------------------
     if a_ctb25m01[arr_aux].soccstcod  =  01   or
        a_ctb25m01[arr_aux].soccstcod  =  02   then
        let l_saida = a_ctb25m01[arr_aux].soccstcod
        initialize a_ctb25m01[arr_aux].* to null
        continue foreach
     end if


     #------------------------------------------------------
     # DESPREZA OS CUSTOS REFERENTES A DESCONTO/RESTITUICAO
     #------------------------------------------------------
     if a_ctb25m01[arr_aux].soccstcod  =  07   or
        a_ctb25m01[arr_aux].soccstcod  =  08   then
        initialize a_ctb25m01[arr_aux].* to null
        continue foreach
     end if


     #------------------------------------------------------
     # DESPREZA OS CUSTOS REFERENTES A PREMIACAO/BONIFICACAO
     #------------------------------------------------------
     if a_ctb25m01[arr_aux].soccstcod  =  23   or
        a_ctb25m01[arr_aux].soccstcod  =  24   then
        let lr_bnfpst.prmqtd = a_ctb25m01[arr_aux].cstqtd
        let lr_bnfpst.prmvlr = a_ctb25m01[arr_aux].socopgitmcst
        initialize a_ctb25m01[arr_aux].* to null
        continue foreach
     end if


     let arr_aux = arr_aux + 1
     if arr_aux > 50   then       # PSI187143 - robson
        error " Limite excedido! Tabela de custos com mais de 10 custos!"
        exit foreach
     end if
  end foreach


  #PSI 205206
  #busca nome da empresa do servico
  call cty14g00_empresa (1, l_ciaempcod)
        returning l_retorno,
                  l_mensagem,
                  d_ctb25m01.empresa
  if l_retorno <> 1 then
     error l_mensagem
  end if


  # verifica empresas que temos que buscar o limite de quilometragem
  case l_ciaempcod
      # para a azul esta contida no XML na tag: APOLICE/ASSISTENCIA/GUINCHO/KMLIMITE.
     when 35
        #descobrir a apolice do servico


        call ctd07g02_busca_apolice_servico(1,
                                            param.atdsrvnum,
                                            param.atdsrvano)
            returning l_retorno,
                      l_mensagem,
                      l_succod,
                      l_ramcod,
                      l_aplnumdig,
                      l_itmnumdig,
                      l_edsnumref
        if l_retorno = 1 then


           #descobrir o código para busca do XML
           call ctd02g01_azlaplcod (l_succod,
                                    l_ramcod,
                                    l_aplnumdig,
                                    l_itmnumdig,
                                    l_edsnumref)
                returning l_retorno,
                          l_mensagem,
                          l_azlaplcod


           if l_retorno = 1 then
              #descobrir o doc_handle para busca do XML
              call ctd02g00_agrupaXML (l_azlaplcod)
                   returning l_doc_handle
              #com o doc_handle conseguimos localizar um item do XML de uma
              # apolice da Azul


              #--- Busca Limites da Azul
              call cts49g00_clausulas(l_doc_handle)
                   returning l_kmlimite,
                             l_kmqtde


              #calcular ida e volta
              let l_kmlimiteaux = l_kmlimite
              let l_kmlimiteaux = l_kmlimiteaux * 2

           if l_kmlimiteaux is null or l_kmlimiteaux = 0 then
           			let d_ctb25m01.limite = "ATENCAO: APOLICE SEM LIMITE DE QUILOMETRAGEM"


           else
           			let d_ctb25m01.limite = "ATENCAO: LIMITE QUILOMETRICO DE ",
                                   l_kmlimiteaux using "<<<<<#", "KM TOTAIS."

           end if


           end if
           #se retorno diferente de 1, nao conseguiremos encontrar XML
        end if
        #se retorno diferente de 1, pode ser apolice sem documento
        # entao nao temos como encontrar o XML

     when 84

         call ctb25m01_busca_quilometragem_itau(param.atdsrvnum,
                                          param.atdsrvano)
               returning lr_retorno.pansoclmtqtd,
                         lr_retorno.socqlmqtd,
                         lr_retorno.erro,
                         lr_retorno.mensagem

         # Alteracao Beatriz Araujo PR-2012-00808 segunda fase do REALIZAR
         if  lr_retorno.socqlmqtd is not null then

	          #calcular ida e volta
	          let l_kmlimiteaux = lr_retorno.socqlmqtd
	          let l_kmlimiteaux = l_kmlimiteaux * 2
            let d_ctb25m01.limite = "ATENCAO: LIMITE QUILOMETRICO DE ",
                                   l_kmlimiteaux using "<<<<<#", "KM TOTAIS."
	       else

	           whenever error continue

               select socntzcod
                 into ws.socntzcod
                 from datmsrvre
                where atdsrvnum = param.atdsrvnum
                  and atdsrvano = param.atdsrvano

               select mobrefvlr,
                      pecmaxvlr
                 into l_mobrefvlr,
                      l_pecmaxvlr
                 from dpakpecrefvlr
                where socntzcod = ws.socntzcod
                  and empcod    = l_ciaempcod
             whenever error stop


	          if (l_mobrefvlr is not null or l_mobrefvlr <> '') and
                     (l_pecmaxvlr is not null or l_pecmaxvlr <> '') then
	             let d_ctb25m01.limite = "ATENCAO: LIMITE PARA PECAS ATE ",l_pecmaxvlr using"<<<<<<<.<<"
	          end if

	          let ws.socntzcod = null

	          select segpgoexdvlr
	            into d_ctb25m01.segpgoexdvlr
	            from dbsmsrvacr
	           where atdsrvnum = param.atdsrvnum
	             and atdsrvano = param.atdsrvano

	          if d_ctb25m01.segpgoexdvlr is not null then
	             let d_ctb25m01.custopeca = 'VALOR A SER COBRADO DO SEGURADO: '
	          end if

	       end if

  end case

  call set_count(arr_aux-1)
#  options insert key F40,
#          delete key F45

  message " (F17)Abandona, (F8)Seleciona "

  open cctb25m01002 using param.atdsrvnum,
                          param.atdsrvano
  let l_cont = 1
  initialize am_ctb25m01 to null
  foreach cctb25m01002 into l_srvacrobslinseq,
                            am_ctb25m01[l_cont].*

     let l_cont = l_cont + 1
     if l_cont > 5 then
        exit foreach
     end if

  end foreach

  let l_cont = l_cont - 1
  if l_cont >= 1 then
     for l_for = 1 to 4
         if am_ctb25m01[l_for].dbsmsrvacrobs is null then
            exit for
         end if
         if l_for > 3 then
            exit for
         else
            display am_ctb25m01[l_for].dbsmsrvacrobs to s_ctb25m01a[l_for].dbsmsrvacrobs
         end if
     end for
  end if


  initialize mr_semprr.* to null

  let m_cadsemprr = false

  open cctb25m01014 using param.atdsrvnum,
                          param.atdsrvano
  fetch cctb25m01014 into mr_semprr.pdgqtd,
                          mr_semprr.pdgttlvlr

  if  sqlca.sqlcode <> 0 then
      if  sqlca.sqlcode = notfound then
          let mr_semprr.pdgqtd    = 0
          let mr_semprr.pdgttlvlr = 0.00
      else
          error "Erro SELECT cctb25m01014, " , sqlca.sqlcode, '/'
                                             , sqlca.sqlerrd[2]
          sleep 2
          error "ctb25m01() ", param.atdsrvnum, '/'
                             , param.atdsrvano
      end if
  else
      let m_cadsemprr = true

      display by name mr_semprr.pdgqtd,
                      mr_semprr.pdgttlvlr

  end if

  while true

     #----------------------------------
     # Apura valores
     #----------------------------------
     select fnlvlr
       into d_ctb25m01.atdcstvlr
       from dbsmsrvacr
      where atdsrvnum = param.atdsrvnum
        and atdsrvano = param.atdsrvano

     if d_ctb25m01.atdcstvlr is null then
        let d_ctb25m01.atdcstvlr  = 0
     end if




     let d_ctb25m01.totcstadc  = 0
     for arr_aux = 1 to 20
         if a_ctb25m01[arr_aux].socopgitmcst is null then
            exit for
         else
            let d_ctb25m01.totcstadc  = d_ctb25m01.totcstadc +
                                        a_ctb25m01[arr_aux].socopgitmcst
         end if
     end for

     if d_ctb25m01.totcstadc is null then
        let d_ctb25m01.totcstadc  = 0
     end if

     # BURINI
     if  ws.atdsrvorg = 9 or ws.atdsrvorg = 13 then
     call ctx15g00_vlrre(param.atdsrvnum, param.atdsrvano)
               returning ws.socntzcod , ws.vlrsugerido,
                         ws.vlrmaximo , ws.vlrdiferenc ,
                         ws.vlrmltdesc, ws.qtdsrv, ws.flgtab
     else

         open cctb25m01008 using param.atdsrvnum, param.atdsrvano
         fetch cctb25m01008 into ws.atddat, ws.vclcoddig , ws.asitipcod

         open cctb25m01018 using param.atdsrvnum, param.atdsrvano
         fetch cctb25m01018 into ws.atdprscod

         call ctc00m15_rettrfvig(ws.atdprscod,
                                 l_ciaempcod,
                                 ws.atdsrvorg,
                                 ws.asitipcod,
                                 ws.atddat)
              returning ws.soctrfcod,
                        ws.soctrfvignum,
                        lr_erro.*


         call ctc00m15_retsocgtfcod(ws.vclcoddig)
              returning ws.socgtfcod, lr_erro.*


         call ctc00m15_retvlrvig(ws.soctrfvignum,
                                  ws.socgtfcod,
                                  1)
               returning ws.vlrsugerido, lr_erro.*

	 call ctd00g00_vlrprmpgm(param.atdsrvnum,
                                 param.atdsrvano,
                                 "INI")
              returning ws.vlrprm,
                        lr_erro.err

         let ws.vlrsugerido = ctd00g00_compvlr(ws.vlrsugerido, ws.vlrprm)

         if   lr_erro.err = 0 then
              let ws.flgtab = 1
         else
              let ws.flgtab = 2
         end if

     end if

     if lr_bnfpst.prmvlr is null then
        let lr_bnfpst.prmvlr = 0
     end if

     let d_ctb25m01.vlrcstini  = d_ctb25m01.atdcstvlr - d_ctb25m01.totcstadc -  lr_bnfpst.prmvlr

     #PSI 205206
     display by name d_ctb25m01.empresa attribute(reverse)
     if d_ctb25m01.limite is not null then
        display by name d_ctb25m01.limite  attribute(reverse)
     end if

     if d_ctb25m01.segpgoexdvlr is not null and d_ctb25m01.segpgoexdvlr <> 0 then
        display by name d_ctb25m01.custopeca
        display by name d_ctb25m01.segpgoexdvlr
     end if

     display by name d_ctb25m01.vlrcstini
     display by name d_ctb25m01.totcstadc
     display by name d_ctb25m01.atdcstvlr
     display by name mr_semprr.totsrv
     display by name lr_bnfpst.prmqtd
     display by name lr_bnfpst.prmvlr

     let int_flag = false

     input by name d_ctb25m01.vlrcstini without defaults

        before field vlrcstini
           case ws.flgtab
             when 1  # PRESTADOR C/TABELA
                case ws.qtdsrv
                   when 1 error " Primeiro servico preco tabela cheio!"
                   when 2 error " ATENCAO: Servico multiplo desconto padrao de R$ ", ws.vlrmltdesc using "<<<&.&&"
                end case
             when 2  # PRESTADOR S/TABELA
                error " ATENCAO: Prestador sem tabela de preco!"
           end case
           display by name d_ctb25m01.vlrcstini attribute (reverse)

        after field vlrcstini
           display by name d_ctb25m01.vlrcstini
           if d_ctb25m01.vlrcstini  is null   or
              d_ctb25m01.vlrcstini  =  0.00   then
              error " Valor final deve ser informado!"
              next field vlrcstini
           end if
           if d_ctb25m01.vlrcstini  > 5000    then
              error " Valor digitado superior a R$ 5.000,00!"
              next field vlrcstini
           end if

        on key (interrupt)
        #PSI 03847 INICIO
              whenever error continue
                 execute pctb25m01024 using  g_issk.usrtip
                                            ,g_issk.empcod
                                            ,g_issk.funmat
                                            ,param.atdsrvnum
                                            ,param.atdsrvano
              whenever error stop
              #PSI 03847 FIM
           exit input

        #-------------------------------------------------------------------
        # Aciona servico via radio
        #-------------------------------------------------------------------
        on key (F8)

           call cts04g00('ctb25m00') returning l_lixo
           let int_flag = false

     end input

     if int_flag = true  then
        exit while
     end if

     call set_count(arr_aux)

     input array a_ctb25m01 without defaults from s_ctb25m01.*
        before row
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
             let ws.operacao = "i"
             if arr_aux <= arr_count()  then
                let ws.operacao = "a"
             end if

           before insert
              let ws.operacao = "i"
              initialize a_ctb25m01[arr_aux].*  to null
              display a_ctb25m01[arr_aux].* to s_ctb25m01[scr_aux].*

           before field cstqtd
              case a_ctb25m01[arr_aux].soccstcod
                when  1 error " Qtde"
                when  2 error " Qtde"
                when  3 error " Qtde"
                when  4 error " Qtde"
                when  5 error " Qtde"
                when  9 error " Digite somente 0 ou 1 !"
                when 10 error " Qtde"
                #     if ws.flgtab = 1 then
                #       error " Digite somente 0 ou 1 !"
                #     else
                #       error " Digite somente 0, 1, 2, 3 ou 4 !"
                #     end if
                when 11 error " Qtde de Km!"
                otherwise next field socopgitmcst
              end case
              display a_ctb25m01[arr_aux].cstqtd  to
                      s_ctb25m01[scr_aux].cstqtd  attribute (reverse)

           after field cstqtd
              display a_ctb25m01[arr_aux].cstqtd  to
                      s_ctb25m01[scr_aux].cstqtd

              if fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then

                 if ws.atdsrvorg = 9 or ws.atdsrvorg = 13  then # TABELA RE
                    case a_ctb25m01[arr_aux].soccstcod
                       when 3
                          if a_ctb25m01[arr_aux].cstqtd is null or
                             a_ctb25m01[arr_aux].cstqtd < 0     then
                                  let a_ctb25m01[arr_aux].cstqtd = 0
                                  display a_ctb25m01[arr_aux].cstqtd  to s_ctb25m01[scr_aux].cstqtd
                          end if
                          if a_ctb25m01[arr_aux].socopgitmcst < 0 then
                             let a_ctb25m01[arr_aux].socopgitmcst = 0
                          end if
                          whenever error continue
                             open cctb25m01007 using param.atdsrvnum, param.atdsrvano
                             fetch cctb25m01007 into ws.soctrfcod
                          whenever error stop
                             if sqlca.sqlcode <> 0 then
                                if  sqlca.sqlcode <> 100 then
                                    error 'Erro pctb25m01007: ',sqlca.sqlcode,"/",sqlca.sqlerrd[2] sleep 2
                                else
                                    error "Tarifa nao encontrada para o Prestador."
                                end if
                             end if
                          close cctb25m01007
                          if ws.soctrfcod is not null then
                             whenever error continue
                                open cctb25m01008 using param.atdsrvnum, param.atdsrvano
                                fetch cctb25m01008 into ws.atddat, ws.vclcoddig
                             whenever error stop
                             if sqlca.sqlcode <> 0 then
                                if  sqlca.sqlcode <> 100 then
                                    error 'Erro pctb25m01008: ', sqlca.sqlcode,"/",sqlca.sqlerrd[2] sleep 2
                                else
                                    error "Data de Atendimento e Veiculo não encontrados."
                                end if
                             end if
                             close cctb25m01008
                             call ctb00g01_grptrf( param.atdsrvnum,
                                                   param.atdsrvano,
                                                   ws.vclcoddig,
                                                   2 )
                             returning ws.erro, ws.socgtfcod
                             if ws.erro = "s" then
                                #  Nao achou GRP TAR.VEIC., GRP.TAR. = Veic.passeio
                                let ws.socgtfcod  = 1
                             end if
                             if ws.atddat is not null then
                                whenever error continue
                                   open cctb25m01009 using ws.soctrfcod, ws.atddat, ws.atddat
                                   fetch cctb25m01009 into ws.soctrfvignum
                                whenever error stop
                                if sqlca.sqlcode <> 0 then
                                   if  sqlca.sqlcode <> 100 then
                                       error 'Erro pctb25m01009: ', sqlca.sqlcode,"/",sqlca.sqlerrd[2] sleep 2
                                   else
                                       error "Vigencia nao encontrada."
                                   end if
                                end if
                                close cctb25m01009

                                if ws.soctrfvignum  is not null then
                                   whenever error continue
                                   open cctb25m01010 using ws.soctrfvignum, ws.socgtfcod, a_ctb25m01[arr_aux].soccstcod
                                   fetch cctb25m01010 into ws.socgtfcstvlr
                                   whenever error stop
                                   if sqlca.sqlcode <> 0 then
                                           if  sqlca.sqlcode <> 100 then
                                               error 'Erro pctb25m01010: ', sqlca.sqlcode,"/",sqlca.sqlerrd[2] sleep 2
                                           else
                                               error "Custo tarifario nao encontrado."
                                           end if
                                   end if
                                   close cctb25m01010
                                   if ws.socgtfcstvlr is not null then
                                           let a_ctb25m01[arr_aux].socopgitmcst = a_ctb25m01[arr_aux].cstqtd * ws.socgtfcstvlr
                                   end if
                                end if
                             end if
                          end if

                       when  9
                          case a_ctb25m01[arr_aux].cstqtd
                                  when 0 let a_ctb25m01[arr_aux].socopgitmcst = 0
                                  when 1 # mantem o valor que veio do portal
                                  otherwise next field cstqtd
                          end case

                       when 10
                          #if ws.flgtab = 1 then
                          #       case a_ctb25m01[arr_aux].cstqtd
                          #               when 0 let a_ctb25m01[arr_aux].socopgitmcst = 0
                          #               when 1
                          #                       if ws.vlrdiferenc is not null and
                          #                          ws.vlrdiferenc <> 0        then
                          #                               let a_ctb25m01[arr_aux].socopgitmcst =
                          #                               ws.vlrdiferenc - (ws.vlrsugerido +
                          #                               ws.vlrmltdesc)
                          #                       end if
                          #                       otherwise next field cstqtd
                          #       end case
                          #else
                          #       case a_ctb25m01[arr_aux].cstqtd
                          #               when 0 let a_ctb25m01[arr_aux].socopgitmcst = 0
                          #               when 1 let a_ctb25m01[arr_aux].socopgitmcst = 10
                          #               when 2 let a_ctb25m01[arr_aux].socopgitmcst = 20
                          #               when 3 let a_ctb25m01[arr_aux].socopgitmcst = 30
                          #               when 4 let a_ctb25m01[arr_aux].socopgitmcst = 40
                          #               otherwise next field cstqtd
                          #       end case
                          #end if

                       when 11
                          if a_ctb25m01[arr_aux].cstqtd is null or
                             a_ctb25m01[arr_aux].cstqtd < 0     then
                                let a_ctb25m01[arr_aux].cstqtd = 0
                                display a_ctb25m01[arr_aux].cstqtd  to
                                s_ctb25m01[scr_aux].cstqtd
                          end if

                          #Alterado de 0.7 para 0.85 de acordo com chamado 14027358
                          if ws.flgtab = 1 then
                             #Ao alterar o valor do Km Excedente e necessario alterar tbm a linha 1274
                             #E no Porto.PortoSocorro.Prestador
                             let a_ctb25m01[arr_aux].socopgitmcst = (a_ctb25m01[arr_aux].cstqtd - 40 ) * .9
                          else
                             let a_ctb25m01[arr_aux].socopgitmcst = (a_ctb25m01[arr_aux].cstqtd - 40 ) * .9
                          end if

                          if a_ctb25m01[arr_aux].socopgitmcst < 0 then
                                  let a_ctb25m01[arr_aux].socopgitmcst = 0
                          end if
                    end case

                 else   # TABELA AUTO

                     if ws.atdsrvorg =  2  then #TAXI
                        open cctb25m01011 using param.atdsrvnum
                                              , param.atdsrvano
                        fetch cctb25m01011 into l_pasasivcldes
                        if l_pasasivcldes  = 'V'          then
                           error "ATENCAO TAXI VAN !"
                        end if
                     end if

                     call ctc00m15_retvlrvig(ws.soctrfvignum,
                                             ws.socgtfcod,
                                             a_ctb25m01[arr_aux].soccstcod)
                          returning ws.vlrsugerido, lr_erro.*

                     case a_ctb25m01[arr_aux].soccstcod
                        when 1
                             let l_param = "INI"
                        when 2
                             let l_param = "ADC"
                        otherwise
                             let l_param = ""
                     end case

                     call ctd00g00_vlrprmpgm(param.atdsrvnum,
                                             param.atdsrvano,
                                             l_param)
                          returning ws.vlrprm,
                                    lr_erro.err

                     let ws.vlrsugerido = ctd00g00_compvlr(ws.vlrsugerido, ws.vlrprm)

                     if  ws.socgtfcstvlr is not null then
                         let a_ctb25m01[arr_aux].socopgitmcst = a_ctb25m01[arr_aux].cstqtd * ws.vlrsugerido
                     end if
                 end if

                 display a_ctb25m01[arr_aux].socopgitmcst  to
                 s_ctb25m01[scr_aux].socopgitmcst

                 next field socopgitmcst

              end if

              display a_ctb25m01[arr_aux].socopgitmcst  to
                      s_ctb25m01[scr_aux].socopgitmcst


           before field socopgitmcst

              if a_ctb25m01[arr_aux].soccstcod <= 11 then
                 continue input
              end if
              let ws.valor = 0

              display a_ctb25m01[arr_aux].socopgitmcst  to
                      s_ctb25m01[scr_aux].socopgitmcst  attribute (reverse)

           after field socopgitmcst
              display a_ctb25m01[arr_aux].socopgitmcst  to
                      s_ctb25m01[scr_aux].socopgitmcst

              if a_ctb25m01[arr_aux + 1].soccstcod is null then
                 exit input
              end if

#PSI 197467 Inicio

              if a_ctb25m01[arr_aux].soccstcod  = 3 then
                if a_ctb25m01[arr_aux].socopgitmcst is not null and
                   a_ctb25m01[arr_aux].socopgitmcst <> 0 then
                        let ws.valor = a_ctb25m01[arr_aux].socopgitmcst / a_ctb25m01[arr_aux].cstqtd
                        if l_valor > 0 then
                                if ws.valor >  l_valor then
                                        error "Valor não confere com quantidade informada!" sleep 2
                                        next field cstqtd
                                else
                                        continue input
                                end if
                        else
                                if ws.socgtfcstvlr > 0 then
                                        if ws.valor >  ws.socgtfcstvlr then
                                                error "Valor não confere com quantidade informada!" sleep 2
                                                next field cstqtd
                                        end if
                                else
                                        continue input
                                end if
                        end if
                end if
              end if

              if a_ctb25m01[arr_aux].soccstcod = 11 then

                if a_ctb25m01[arr_aux].socopgitmcst > 0 then
                        #let ws.valor = (a_ctb25m01[arr_aux].cstqtd - 60) *.6
                        #Alterado de 0.7 para 0.85 de acordo com chamado 14027358
                        let ws.valor = (a_ctb25m01[arr_aux].cstqtd - 40) * .90 #CT432490
                        #Ao alterar o valor do Km Excedente e necessario alterar tbm nas linhas 1166 e 1168
                        #E no Porto.PortoSocorro.Prestador
                        if a_ctb25m01[arr_aux].socopgitmcst > ws.valor then
                                error "Valor não confere com quantidade informada!" sleep 2
                                next field cstqtd
                        else
                                continue input
                        end if
                end if
              end if


#PSI 197467 Fim

           on key(interrupt)
           #PSI 03847 INICIO
              whenever error continue
                 execute pctb25m01024 using  g_issk.usrtip
                                            ,g_issk.empcod
                                            ,g_issk.funmat
                                            ,param.atdsrvnum
                                            ,param.atdsrvano
              whenever error stop
              #PSI 03847 FIM
              exit input

           on key (F8)

              call cts04g00('ctb25m00') returning l_lixo
              let int_flag = false

           on key (F6)

              display "APERTOU F6"

              call ctb25m01_retorno(param.atdsrvnum,
                                    param.atdsrvano)

           after row
              display a_ctb25m01[arr_aux].* to s_ctb25m01[scr_aux].*
              let ws.operacao = " "

     end input

     let d_ctb25m01.totcstadc  = 0
     for arr_aux = 1 to 20
         if a_ctb25m01[arr_aux].socopgitmcst is null then
            exit for
         else
            let d_ctb25m01.totcstadc  = d_ctb25m01.totcstadc +
                                      a_ctb25m01[arr_aux].socopgitmcst
         end if
     end for

     if d_ctb25m01.totcstadc is null then
        let d_ctb25m01.totcstadc  = 0
     end if

     if lr_bnfpst.prmvlr is null then
        let lr_bnfpst.prmvlr = 0
     end if

     let d_ctb25m01.atdcstvlr = d_ctb25m01.vlrcstini + d_ctb25m01.totcstadc + lr_bnfpst.prmvlr

     #estou exibindo vlrcstini novamente pq ele pode sofrer input
     display by name d_ctb25m01.vlrcstini
     display by name d_ctb25m01.totcstadc
     display by name d_ctb25m01.atdcstvlr

     #-------------------------------------------
     # QUANDO DIGITAR O ULTIMO CUSTO, ## SAI DA TELA
     # CHAMO AS OBSERVACOES PSI:187801
     #-------------------------------------------

     if int_flag then
        let int_flag = false
        message ""
        close window w_ctb25m01
        return
     end if

     input by name mr_semprr.* without defaults

        before field pdgqtd

            display by name mr_semprr.pdgqtd  attribute (reverse)

        after field pdgqtd

            display by name  mr_semprr.pdgqtd

            if  mr_semprr.pdgqtd is null or mr_semprr.pdgqtd = " " then
                let mr_semprr.pdgqtd = 0
                let mr_semprr.pdgttlvlr = 0

                display by name mr_semprr.pdgqtd,
                                mr_semprr.pdgttlvlr
            end if

            # BURINI if  mr_semprr.pdgqtd = 0 then
            # BURINI     let mr_semprr.pdgttlvlr = 0
            # BURINI     display by name mr_semprr.pdgttlvlr
            # BURINI
            # BURINI     call cts08g01("A","S"," ","NENHUM SEM PARAR CADASTRADO.","DESEJA CONTINUAR?"," ")
            # BURINI          returning l_confirma
            # BURINI
            # BURINI     if  l_confirma = 'S' then
            # BURINI         exit input
            # BURINI     else
            # BURINI         next field pdgqtd
            # BURINI     end if
            # BURINI end if

        before field pdgttlvlr

            display by name mr_semprr.pdgttlvlr attribute (reverse)

        after field pdgttlvlr

            display by name mr_semprr.pdgttlvlr

            if  mr_semprr.pdgttlvlr is null or mr_semprr.pdgttlvlr = " " then
                let mr_semprr.pdgttlvlr = 0

                display by name mr_semprr.pdgttlvlr
            end if

     end input

     if  int_flag then
         let int_flag = false
         message ""
         close window w_ctb25m01
         return
     else
         let mr_semprr.totsrv = mr_semprr.pdgttlvlr + d_ctb25m01.atdcstvlr
         display by name mr_semprr.totsrv attribute (reverse)
     end if

     call ctb25m01_obs(param.atdsrvnum, param.atdsrvano)

     while true
        let ws.flgsai = 0
        prompt " Confirma (S)im, (N)Nao, (P)Pendencia ou (A)Abandona? : " for ws.confirma   # PSI187143 - robson
        let ws.confirma = upshift(ws.confirma)
        if ws.confirma = "A" then
           let ws.flgsai = 1
           exit while
        else
            #ElianeK, Fornax    09/03/2016
            let l_pode_liberar = "N"
	    if ws.confirma = "N" or ws.confirma = "S" then
               if param.situacao  = "L" then
                  open cctb25m01030
                  foreach cctb25m01030 into l_funmat
                     if l_funmat = g_issk.funmat then
		         let l_pode_liberar = "S"
	                 exit foreach
	             end if
	           end foreach

		   if l_pode_liberar = "N" then
                    error "Sem alcada para Analise/Manutencao do valor e itens adicionais"	
                    let ws.flgsai = 1
	            exit while
      		   end if
	       end if
              end if
              #fim 09/03/2016

           if ws.confirma = "N" then
              #PSI 03847 INICIO
              whenever error continue
                 execute pctb25m01024 using  g_issk.usrtip
                                            ,g_issk.empcod
                                            ,g_issk.funmat
                                            ,param.atdsrvnum
                                            ,param.atdsrvano
              whenever error stop
              #PSI 03847 FIM
              exit while
           else
              if ws.confirma = "S" or            # PSI187143 - robson
                 ws.confirma = "P" then          # PSI187143 - robson
                 let ws.totcstvlr = 0
                 for arr_aux = 1 to 20
                     if a_ctb25m01[arr_aux].socopgitmcst is null then
                        exit for
                     else
                        let ws.totcstvlr = ws.totcstvlr +
                                           a_ctb25m01[arr_aux].socopgitmcst
                     end if
                 end for

                 ##display "arr_aux", arr_aux

                 #recoloca valor do premio como custo adicional
                 if lr_bnfpst.prmvlr > 0 then
                    if ws.atdsrvorg = 9 or ws.atdsrvorg = 13 then
                       let a_ctb25m01[arr_aux].soccstcod = 23 ## PREMIO RE
                    else
                       let a_ctb25m01[arr_aux].soccstcod = 24
                    end if

                    let a_ctb25m01[arr_aux].socopgitmcst = lr_bnfpst.prmvlr
                    let a_ctb25m01[arr_aux].cstqtd = lr_bnfpst.prmqtd

                    let ws.totcstvlr = ws.totcstvlr +
                                       a_ctb25m01[arr_aux].socopgitmcst
                 end if

                 if ws.totcstvlr > d_ctb25m01.atdcstvlr then
                    error "ATENCAO: A somatoria dos adicionais nao pode ser superior ao total do custo!"
                    let ws.flgsai = 0
                    exit while
                 end if
                 #----------------------------------
                 # Grava Servico e vlr inicial
                 #----------------------------------

# PSI187143 - robson - inicio
             ### verificar o valor, para não ter mais de duas casas depois da virgula - Beatriz Araujo
                 let d_ctb25m01.atdcstvlr = d_ctb25m01.atdcstvlr using "&&,&&&,&&&,&&&.&&"
             #### fim
                 whenever error continue
                 #PSI03847 Inicio
                 #Verifica o valor inicial
                 open cctb25m01022 using param.atdsrvnum
                                         ,param.atdsrvano
                 fetch cctb25m01022 into l_vlrpst

                 open cctb25m01023 using param.atdsrvnum
                                         ,param.atdsrvano
                 fetch cctb25m01023 into l_prsvlr

                 if l_prsvlr is null then

                    #somente grava, se for a primeira vez que entrou no servico
                    execute pctb25m01021 using l_vlrpst
                                               ,param.atdsrvnum
                                               ,param.atdsrvano

                 end if
                 #PSI03847 Fim

                 execute pctb25m01001 using d_ctb25m01.vlrcstini
                                           ,d_ctb25m01.atdcstvlr
                                           ,ws.confirma
                                           ,g_issk.usrtip
                                           ,g_issk.empcod
                                           ,g_issk.funmat
                                           ,param.atdsrvnum
                                           ,param.atdsrvano

                 whenever error stop
                 if sqlca.sqlcode <> 0 then
                    error " Erro (", sqlca.sqlcode, ") na atualizacao do valor. AVISE A INFORMATICA!" sleep 3
                    error 'Erro UPDATE pctb25m01001: ' , sqlca.sqlcode, "/",sqlca.sqlerrd[2] sleep 2
                    error ' Funcao ctb25m01() ', d_ctb25m01.atdcstvlr, '/'
                                               , ws.confirma, '/'
                                               , param.atdsrvnum, '/'
                                               , param.atdsrvano sleep 2
                    let ws.flgsai = 1
                    exit while
                 end if

# PSI187143 - robson - fim

# PSI187801 - Adriana - Inicio
                 whenever error continue
                 execute pctb25m01005 using param.atdsrvnum
                                           ,param.atdsrvano
                 whenever error stop
                 if sqlca.sqlcode <> 0 then
                    error 'Erro DELETE pctb25m01005: ',sqlca.sqlcode,"/",sqlca.sqlerrd[2] sleep 2
                    error ' Funcao ctb25m01()/',param.atdsrvnum,'/',param.atdsrvano sleep 2
                    let ws.flgsai = 1
                    exit while
                 end if

               if  m_cadsemprr then
                   if  mr_semprr.pdgqtd = 0 then
                       execute pctb25m01017  using param.atdsrvnum,
                                                   param.atdsrvano
                   else
                       execute pctb25m01016 using mr_semprr.pdgqtd,
                                                  mr_semprr.pdgttlvlr,
                                                  param.atdsrvnum,
                                                  param.atdsrvano
                   end if
               else
                   execute pctb25m01015 using param.atdsrvnum,
                                              param.atdsrvano,
                                              mr_semprr.pdgqtd,
                                              mr_semprr.pdgttlvlr

               end if

               if sqlca.sqlcode <> 0 then
                  error 'Erro ATUALIZACAO/INSERT  dbarsemprrsrv: ' , sqlca.sqlcode, "/",sqlca.sqlerrd[2]
                  sleep 2
                  error ' Funcao ctb25m01() ', mr_semprr.pdgqtd, '/'
                                             , mr_semprr.pdgttlvlr, '/'
                                             , param.atdsrvnum, '/'
                                             , param.atdsrvano
                  sleep 2
                  let ws.flgsai = 1
                  exit while
               end if

               for i = 1 to 5
               if am_ctb25m01[i].dbsmsrvacrobs is not null then
                  let am_ctb25m01[i].dbsmsrvacrobs = am_ctb25m01[i].dbsmsrvacrobs clipped
                  whenever error continue
                  execute pctb25m01003 using param.atdsrvnum
                                            ,param.atdsrvano
                                            ,i
                                            ,am_ctb25m01[i].dbsmsrvacrobs
                  whenever error stop
                  if sqlca.sqlcode <> 0 then
                     error 'Erro INSERT  pctb25m01003: ' , sqlca.sqlcode, "/",sqlca.sqlerrd[2]
                     sleep 2
                     error ' Funcao ctb25m01() ', param.atdsrvnum, '/'
                                                , param.atdsrvano, '/'
                                                , i, '/'
                                                , am_ctb25m01[i].dbsmsrvacrobs
                     sleep 2
                     let ws.flgsai = 1
                     exit while
                  end if
               end if
              end for

              if ws.confirma = "P" then
                 let l_histerr = cts10g02_historico(param.atdsrvnum,
                                                     param.atdsrvano,
                                                     current,
                                                     current,
                                                     g_issk.funmat,
                                                     am_ctb25m01[1].dbsmsrvacrobs clipped,
                                                     am_ctb25m01[2].dbsmsrvacrobs clipped,
                                                     am_ctb25m01[3].dbsmsrvacrobs clipped,
                                                     am_ctb25m01[4].dbsmsrvacrobs clipped,
                                                     am_ctb25m01[5].dbsmsrvacrobs clipped)
                 if l_histerr <> 0 then
                    error "Funcao cts10g02_historico() "
                    sleep 2
                    let ws.flgsai = 1
                    exit while
                 end if
              end if
#  PSI187801 - Adriana - Fim


                 #----------------------------------
                 # Grava adicionais do servico
                 #----------------------------------
                 delete from dbsmsrvcst
                  where atdsrvnum    = param.atdsrvnum
                    and atdsrvano    = param.atdsrvano

                 for arr_aux = 1 to 20
                     if a_ctb25m01[arr_aux].cstqtd is null then
                        let a_ctb25m01[arr_aux].cstqtd = 0
                     end if
                     if a_ctb25m01[arr_aux].socopgitmcst is null then
                        exit for
                     else
                        begin work
                         insert into dbsmsrvcst
                                      (soccstcod,
                                       socadccstqtd,
                                       socadccstvlr,
                                       atdsrvnum,
                                       atdsrvano)
                               values (a_ctb25m01[arr_aux].soccstcod,
                                       a_ctb25m01[arr_aux].cstqtd,
                                       a_ctb25m01[arr_aux].socopgitmcst,
                                       param.atdsrvnum,
                                       param.atdsrvano)

                           commit work
                     end if
                  end for

                  if ws.confirma = "L" or ws.confirma = "S" then

                     #fornax jan/2016 - Liberacao por Alcada
		     let g_documento.atdsrvnum = param.atdsrvnum
		     let g_documento.atdsrvano = param.atdsrvano
   
                     if param.situacao <> "L" then
                        call ctb25m00_alcada( param.situacao ) returning l_libera, l_msg
   
	                if l_libera = "L" then
                           execute pctb25m01025 using 
			          l_libera, param.atdsrvnum, param.atdsrvano
		           let ws.confirma = l_libera
                        else
		           let l_msg ="SERVICO ANALISADO E LIBERADO PARA PAGAMENTO"
                        end if
   
                     else
		        let l_msg ="SERVICO ANALISADO E LIBERADO PARA PAGAMENTO"
		     end if
   
	   	     let l_lighorinc = current
                     call ctd07g01_ins_datmservhist(param.atdsrvnum,
                                                    param.atdsrvano,
                                                    g_issk.funmat,
                                                    l_msg,
                                                    today,
                                                    l_lighorinc,
                                                    g_issk.empcod,
                                                    g_issk.usrtip)
                          returning l_saida,
                                    l_mensagem
   
                     if l_saida <> 1 then
                         error l_mensagem
                     end if
                 end if

                 let ws.flgsai = 1

                 exit while

              end if
           end if
        end if
     end while

     if ws.flgsai = 1 then
        let int_flag = false
        exit while
     end if

 end while

 #options insert key F1,
 #        delete key F2

 let int_flag = false
 message ""
 close window w_ctb25m01

end function  ###  ctb25m01

##---------------------------##
function ctb25m01_obs(lr_param)
##---------------------------##
define lr_param record
       atdsrvnum   like dbsmsrvacr.atdsrvnum,
       atdsrvano   like dbsmsrvacr.atdsrvano
end record

define l_cont,l_scr,l_arr smallint,
       l_srvacrobslinseq smallint

initialize am_ctb25m01 to null
let l_cont = 1
let m_existe = "N"
open cctb25m01002 using lr_param.atdsrvnum,lr_param.atdsrvano
foreach cctb25m01002 into l_srvacrobslinseq,am_ctb25m01[l_cont].*

   let m_existe = "S"
   let l_cont = l_cont + 1
   if l_cont > 5 then
      exit foreach
   end if

end foreach

let l_cont = l_cont -1
call set_count(l_cont)

input array am_ctb25m01 without defaults from s_ctb25m01a.*

 before row
      let l_arr    = arr_curr()
      let l_scr    = scr_line()
      let m_totobs = arr_count()

      display am_ctb25m01[l_arr].dbsmsrvacrobs to
              s_ctb25m01a[l_scr].dbsmsrvacrobs attribute(reverse)

 after field dbsmsrvacrobs
      if fgl_lastkey() <> fgl_keyval("up") and
         fgl_lastkey() <> fgl_keyval("left")  then
         if l_arr = 5 then
            exit input
         end if
      end if

 after row
      let l_arr    = arr_curr()
      let l_scr    = scr_line()
      let m_totobs = arr_count()

      display am_ctb25m01[l_arr].dbsmsrvacrobs to s_ctb25m01a[l_scr].dbsmsrvacrobs

      if  am_ctb25m01[l_arr].dbsmsrvacrobs is null then
          exit input
      end if

on key(escape,f17,interrupt)
   exit input

end input

end function

#--------------------------------#
 function ctb25m01_retorno(param)
#--------------------------------#

 define param record
                  atdsrvnum like datmservico.atdsrvnum,
                  atdsrvano like datmservico.atdsrvano
              end record

 define mr_ret record
                   atdorgsrvnum like datmservico.atdsrvnum,
                   atdorgsrvano like datmservico.atdsrvano,
                   atdsrvnum    like datmservico.atdsrvnum,
                   atdsrvano    like datmservico.atdsrvano
               end record



 define l_ind          integer,
        l_atdorgsrvnum like datmservico.atdsrvnum,
        l_atdorgsrvano like datmservico.atdsrvano


 initialize ma_ret to null

 select distinct atdorgsrvnum,
        atdorgsrvano
   into mr_ret.atdorgsrvnum,
        mr_ret.atdorgsrvano
   from datmsrvre
  where datmsrvre.atdorgsrvnum = param.atdsrvnum
    and datmsrvre.atdorgsrvano = param.atdsrvano

 display "SQL 1 = ", sqlca.sqlcode

 if  sqlca.sqlcode = notfound then

      select atdorgsrvnum,
             atdorgsrvano
        into mr_ret.atdorgsrvnum,
             mr_ret.atdorgsrvano
        from datmsrvre
       where datmsrvre.atdsrvnum = param.atdsrvnum
         and datmsrvre.atdsrvano = param.atdsrvano

     display "SQL 2 = ", sqlca.sqlcode

     if  sqlca.sqlcode = notfound then
         #NAO EXISTEM SERVIÇOS
         return
     end if

 end if

 declare cq_cursor cursor for
 select atdsrvnum,
        atdsrvano
   into l_atdorgsrvnum,
        l_atdorgsrvano
   from datmsrvre
  where datmsrvre.atdorgsrvnum = mr_ret.atdorgsrvnum
    and datmsrvre.atdorgsrvano = mr_ret.atdorgsrvano


 let l_ind = 1

 foreach cq_cursor into mr_ret.atdsrvnum,
                        mr_ret.atdsrvano

     if  l_ind = 1 then
         call ctb25m01_montaarray(mr_ret.atdorgsrvnum,
                                  mr_ret.atdorgsrvano,
         			  l_ind)
         if  param.atdsrvnum = mr_ret.atdorgsrvnum and
             param.atdsrvano = mr_ret.atdorgsrvano then
             let ma_ret[l_ind].flgsrv = "X"
         end if

         let l_ind = l_ind + 1

     end if

     if  param.atdsrvnum = mr_ret.atdsrvnum and
         param.atdsrvano = mr_ret.atdsrvano then
         let ma_ret[l_ind].flgsrv = "X"
     end if

     call ctb25m01_montaarray(mr_ret.atdsrvnum,
                              mr_ret.atdsrvano,
 			      l_ind)

     let l_ind = l_ind + 1

 end foreach

 call set_count(l_ind-1)

 open window w_ctb25m01a at 03,02 with form "ctb25m01a"
      attribute(form line first)

 display array ma_ret to s_ctb25m01a.*

 close window w_ctb25m01a

 end function

#-----------------------------------#
 function ctb25m01_montaarray(param)
#-----------------------------------#

 define param record
                  atdsrvnum like datmservico.atdsrvnum,
                  atdsrvano like datmservico.atdsrvano,
                  ind       integer
              end record

 define l_atdetpdat like datmsrvacp.atdetpdat,
        l_pstcoddig like datmsrvacp.pstcoddig,
        l_atdcstvlr like datmservico.atdcstvlr,
        l_nomgrr    like dpaksocor.nomgrr,
        l_ind       integer

 let l_ind = param.ind

 initialize l_atdetpdat,
            l_pstcoddig,
            l_nomgrr to null

     select atdetpdat,
            pstcoddig,
            atdcstvlr
       into l_atdetpdat,
            l_pstcoddig,
            l_atdcstvlr
       from datmservico srv,
            datmsrvacp  acp
      where srv.atdsrvnum = param.atdsrvnum
        and srv.atdsrvano = param.atdsrvano
        and srv.atdsrvnum = acp.atdsrvnum
        and srv.atdsrvano = acp.atdsrvano
        and acp.atdsrvseq = (select max(atdsrvseq)
                               from datmsrvacp  acp2
                              where acp.atdsrvnum = acp2.atdsrvnum
                                and acp.atdsrvano = acp2.atdsrvano)

     select nomgrr
       into l_nomgrr
       from dpaksocor
      where pstcoddig = l_pstcoddig

     let ma_ret[l_ind].atdsrvnum = param.atdsrvnum
     let ma_ret[l_ind].atdsrvano = param.atdsrvano
     let ma_ret[l_ind].atdetpdat = l_atdetpdat
     let ma_ret[l_ind].pstcoddig = l_pstcoddig
     let ma_ret[l_ind].nomgrr    = l_nomgrr
     let ma_ret[l_ind].atdcstvlr = l_atdcstvlr

 end function

#----------------------------
 function ctb25m01_busca_quilometragem_itau(param)
#--------------------------------

  define param       record
     atdsrvnum       like dbsmsrvacr.atdsrvnum,
     atdsrvano       like dbsmsrvacr.atdsrvano
  end record

  define lr_retorno record
         pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
         socqlmqtd     like datkitaasipln.socqlmqtd    ,
         erro          integer,
         mensagem      char(50)
  end record

  initialize lr_retorno.* to null

if m_prep_sql is null or
     m_prep_sql <> true then
     call ctb25m01_prepare()
  end if

   open cctb25m01019 using param.atdsrvnum,param.atdsrvano
   whenever error continue
     fetch cctb25m01019 into g_documento.ramcod,
                             g_documento.aplnumdig,
                             g_documento.itmnumdig,
                             g_documento.edsnumref,
                             g_documento.itaciacod
   whenever error stop

   call cty22g00_rec_dados_itau(g_documento.itaciacod,
	   	                g_documento.ramcod   ,
	      	                g_documento.aplnumdig,
		                g_documento.edsnumref,
		                g_documento.itmnumdig)
	     returning lr_retorno.erro,
	               lr_retorno.mensagem

   display "lr_retorno.erro: ",lr_retorno.erro
   if lr_retorno.erro = 0 then

      # Alteracao Beatriz Araujo PR-2012-00808 segunda fase do REALIZAR
      if g_documento.ramcod = 531 or g_documento.ramcod = 31 then

         call cty22g00_rec_plano_assistencia(g_doc_itau[1].itaasiplncod)
                 returning lr_retorno.pansoclmtqtd,
                           lr_retorno.socqlmqtd,
                           lr_retorno.erro,
                           lr_retorno.mensagem
      else

        initialize lr_retorno to null

      end if
   end if

   return lr_retorno.pansoclmtqtd,
          lr_retorno.socqlmqtd,
          lr_retorno.erro,
          lr_retorno.mensagem

 end function
