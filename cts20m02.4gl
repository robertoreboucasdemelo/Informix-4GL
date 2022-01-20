#############################################################################
# Nome do Modulo: CTS20M02                                            Pedro #
#                                                                   Marcelo #
# Laudo Aviso de Sinistro Roubo/Furto Total via Anel               Jan/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 05/04/1999  PSI 5591-3   Marcelo      Padronizacao na digitacao do ende-  #
#                                       reco atraves do guia postal.        #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 25/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-  #
#                                       coes, com a utilizacao de funcoes.  #
#---------------------------------------------------------------------------#
# 14/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
# 13/08/2009  Sergio Burini       PSI 244236     Inclusão do Sub-Dairro     #
#---------------------------------------------------------------------------#
# 05/01/2010  Amilton                   Projeto sucursal smallint           #
#############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"

 define k_cts20m02    record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record
 
 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record 

#------------------------------------------------------------------
 function cts20m02()
#------------------------------------------------------------------

 define ws            record
    datatu            date,
    horatu            datetime hour to minute
 end record

 let int_flag  = false

 let ws.datatu = today
 let ws.horatu = current hour to minute
 initialize m_subbairro to null

 initialize k_cts20m02.*  to null

 open window cts20m02 at 04,02 with form "cts20m02"

 menu "AVISO_FURTO"

   command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
           clear form
           call seleciona_cts20m02()
           if k_cts20m02.atdsrvnum is not null  then
              next option "Historico"
           else
              error " Nenhum aviso selecionado!"
              next option "Seleciona"
           end if

   command key ("H") "Historico" "Historico aviso corrente selecionado"
           if k_cts20m02.atdsrvnum is not null then
              call cts10n00(k_cts20m02.atdsrvnum, k_cts20m02.atdsrvano,
                            g_issk.funmat       , ws.datatu, ws.horatu)
              next option "Seleciona"
           else
              error " Nenhum aviso selecionado!"
              next option "Seleciona"
           end if

   command key ("I") "Imprime"   "Imprime aviso corrente selecionado"
           if k_cts20m02.atdsrvnum is not null then
              call ctr03m02(k_cts20m02.atdsrvnum, k_cts20m02.atdsrvano)
           else
              error " Nenhum aviso selecionado!"
              next option "Seleciona"
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
 end menu

 close window cts20m02

end function  ###  cts20m02

#------------------------------------------------------------------
 function seleciona_cts20m02()
#------------------------------------------------------------------

 define d_cts20m02    record
    atdsrvorg         like datmservico.atdsrvorg   ,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    c24solnom         like datmligacao.c24solnom   ,
    nom               like datmservico.nom         ,
    doctxt            char (32)                    ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    cvnnom            char (19)                    ,
    vclcoddig         like datmservico.vclcoddig   ,
    vcldes            like datmservico.vcldes      ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    vclcordes         char (11)                    ,
    atdrsdflg         like datmservico.atdrsdflg   ,
    atddfttxt         like datmservico.atddfttxt   ,
    atdlclflg         like datmservico.atdlclflg   ,
    atddoctxt         like datmservico.atddoctxt   ,
    c24sintip         like datmservicocmp.c24sintip,
    sintipdes         char (05)                    ,
    lgdtxt            char (80)                    ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    endzon            like datmlcl.endzon          ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    sindat            like datmservicocmp.sindat   ,
    sinhor            like datmservicocmp.sinhor   ,
    c24sinhor         like datmservicocmp.c24sinhor,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    atdtxt            char (55)    
 end record

 define ws            record
    succod            like datrservapol.succod   ,
    ramcod            like datrservapol.ramcod   ,
    aplnumdig         like datrservapol.aplnumdig,
    atddat            like datmservico.atddat    ,
    atdhor            like datmservico.atdhor    ,
    funmat            like datmservico.funmat    ,
    dptsgl            like isskfunc.dptsgl       ,
    funnom            like isskfunc.funnom       ,
    vclcorcod         like datmservico.vclcorcod ,
    lignum            like datrligsrv.lignum     ,
    ligcvntip         like datmligacao.ligcvntip ,
    lclidttxt         like datmlcl.lclidttxt     ,
    lgdtip            like datmlcl.lgdtip        ,
    lgdnom            like datmlcl.lgdnom        ,
    lgdnum            like datmlcl.lgdnum        ,
    brrnom            like datmlcl.brrnom        ,
    endzon            like datmlcl.endzon        ,
    lgdcep            like datmlcl.lgdcep        ,
    lgdcepcmp         like datmlcl.lgdcepcmp     ,
    dddcod            like datmlcl.dddcod        ,
    lcltelnum         like datmlcl.lcltelnum     ,
    lclcttnom         like datmlcl.lclcttnom     ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod  ,
    sqlcode           integer,
    endcmp            like datmlcl.endcmp
 end record

 let int_flag = false

 initialize d_cts20m02.*  to null
 initialize k_cts20m02.*  to null
 initialize ws.*          to null

 input by name k_cts20m02.atdsrvnum,
               k_cts20m02.atdsrvano  without defaults

      before field atdsrvnum
         display by name k_cts20m02.atdsrvnum  attribute (reverse)

      after  field atdsrvnum
         display by name k_cts20m02.atdsrvnum

         if k_cts20m02.atdsrvnum is null  then
            error " Numero do servico deve ser informado!"
            next field atdsrvnum
         end if

      before field atdsrvano
         display by name k_cts20m02.atdsrvano  attribute (reverse)

      after  field atdsrvano
         display by name k_cts20m02.atdsrvano

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdsrvnum
         end if

         if k_cts20m02.atdsrvano is null      and
            k_cts20m02.atdsrvnum is not null  then
            error " Ano do servico deve ser informado!"
            next field atdsrvano
         end if

         select atdsrvorg
           into d_cts20m02.atdsrvorg
           from datmservico
          where atdsrvnum = k_cts20m02.atdsrvnum  and
                atdsrvano = k_cts20m02.atdsrvano

         if sqlca.sqlcode  =  notfound   then
            error " Numero de servico nao cadastrado!"
            next field atdsrvnum
         end if

         if d_cts20m02.atdsrvorg  <>  11  then
            error " Numero de servico informado nao e' um aviso de Furto/Roubo!"
            next field atdsrvnum
         end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize k_cts20m02.* to null
    error " Operacao cancelada!"
    clear form
    return
 end if

 let d_cts20m02.atdsrvnum = k_cts20m02.atdsrvnum
 let d_cts20m02.atdsrvano = k_cts20m02.atdsrvano

#------------------------------------------------------------------
# Dados do servico
#------------------------------------------------------------------
 select nom      ,
        vcldes   , vclanomdl,
        vcllicnum, cornom   ,
        corsus   , vclcorcod,
        atdrsdflg, atddfttxt,
        atdlclflg, atddoctxt,
        funmat   , atddat   ,
        atdhor
   into d_cts20m02.nom      ,
        d_cts20m02.vcldes   , d_cts20m02.vclanomdl,
        d_cts20m02.vcllicnum, d_cts20m02.cornom   ,
        d_cts20m02.corsus   , ws.vclcorcod        ,
        d_cts20m02.atdrsdflg, d_cts20m02.atddfttxt,
        d_cts20m02.atdlclflg, d_cts20m02.atddoctxt,
        ws.funmat           , ws.atddat           ,
        ws.atdhor
   from datmservico
  where atdsrvnum = k_cts20m02.atdsrvnum and
        atdsrvano = k_cts20m02.atdsrvano

#--------------------------------------------------------------------
# Informacoes do local da ocorrencia
#--------------------------------------------------------------------
 call ctx04g00_local_completo(k_cts20m02.atdsrvnum,
                              k_cts20m02.atdsrvano,
                              1)
                    returning ws.lclidttxt           ,
                              ws.lgdtip              ,
                              ws.lgdnom              ,
                              ws.lgdnum              ,
                              d_cts20m02.lclbrrnom   ,
                              ws.brrnom              ,
                              d_cts20m02.cidnom      ,
                              d_cts20m02.ufdcod      ,
                              d_cts20m02.lclrefptotxt,
                              ws.endzon              ,
                              ws.lgdcep              ,
                              ws.lgdcepcmp           ,
                              ws.dddcod              ,
                              ws.lcltelnum           ,
                              ws.lclcttnom           ,
                              ws.c24lclpdrcod        ,
                              ws.sqlcode,
                              ws.endcmp 
                              
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 let m_subbairro[1].lclbrrnom = d_cts20m02.lclbrrnom

 call cts06g10_monta_brr_subbrr(ws.brrnom,
                                d_cts20m02.lclbrrnom)
      returning d_cts20m02.lclbrrnom 

 let d_cts20m02.lgdtxt = ws.lgdtip clipped, " ",
                         ws.lgdnom clipped, " ",
                         ws.lgdnum using "<<<<#", " ",
                         ws.endcmp clipped

#------------------------------------------------------------------
# Busca dados complementares do servico
#------------------------------------------------------------------
 select bocnum   , bocemi   ,
        sindat   , c24sintip,
        c24sinhor, sinhor
   into d_cts20m02.bocnum   ,
        d_cts20m02.bocemi   ,
        d_cts20m02.sindat   ,
        d_cts20m02.c24sintip,
        d_cts20m02.c24sinhor,
        d_cts20m02.sinhor
   from datmservicocmp
  where atdsrvnum = k_cts20m02.atdsrvnum and
        atdsrvano = k_cts20m02.atdsrvano

#------------------------------------------------------------------
# Busca sucursal/apolice/item do servico
#------------------------------------------------------------------
 select succod   ,
        ramcod   ,
        aplnumdig
   into ws.succod   ,
        ws.ramcod   ,
        ws.aplnumdig
   from datrservapol
  where atdsrvnum = k_cts20m02.atdsrvnum and
        atdsrvano = k_cts20m02.atdsrvano

 if sqlca.sqlcode = 0  then
    let d_cts20m02.doctxt = "Apolice.: ", ws.succod    using "<<<&&",#"&&", projeto succod
                                     " ", ws.ramcod    using "##&&",
                                     " ", ws.aplnumdig using "<<<<<<<& &"
 end if

#------------------------------------------------------------------
# Dados da ligacao
#------------------------------------------------------------------
 let ws.lignum = cts20g00_servico(k_cts20m02.atdsrvnum, k_cts20m02.atdsrvano)

 select c24solnom, ligcvntip
   into d_cts20m02.c24solnom,
        ws.ligcvntip
   from datmligacao
  where lignum = ws.lignum

#------------------------------------------------------------------
# Nome do convenio
#------------------------------------------------------------------
 select cpodes
   into d_cts20m02.cvnnom
   from datkdominio
  where cponom = "ligcvntip"
    and cpocod = ws.ligcvntip

 select cpodes
   into d_cts20m02.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"
    and cpocod = ws.vclcorcod

 let ws.funnom = "**NAO CADASTRADO**"

 select funnom, dptsgl
   into ws.funnom, ws.dptsgl
   from isskfunc
  where funmat = ws.funmat
    and empcod = g_issk.empcod
    and rhmfunsitcod = "A"

 let ws.funnom = upshift(ws.funnom)

 let d_cts20m02.atdtxt = ws.atddat,                          " ",
                         ws.atdhor,                          " ",
                         upshift(ws.dptsgl)         clipped, " ",
                         ws.funmat  using "&&&&&&"  clipped, " ",
                         upshift(ws.funnom)

 if d_cts20m02.c24sintip is not null then
    if d_cts20m02.c24sintip = "R" then
       let d_cts20m02.sintipdes = "ROUBO"
    else
       let d_cts20m02.sintipdes = "FURTO"
    end if
 end if

 display by name d_cts20m02.*
 display by name d_cts20m02.c24solnom attribute (reverse)
 display by name d_cts20m02.cvnnom    attribute (reverse)

end function  ###  seleciona_cts20m02
