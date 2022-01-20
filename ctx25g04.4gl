#-----------------------------------------------------------------------------#
#                       PORTO SEGURO CIA SEGUROS GERAIS                       #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTX25G04                                                   #
# ANALISTA RESP..: RAJI JAHCHAN                                               #
# PSI/OSF........: PSI 198434 - ROTERIZACAO E INTEGRACAO DE MAPAS.            #
#                  LOCALIZA VEICULO MAIS PROXIMO DA OCORRENCIA - ROTERIZADO.  #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 25/06/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 11/12/2006 Priscila        PSI 205206 Exibir empresa                        #
#                                                                             #
# 12/06/2007 Roberto         CT 7061486 Exclusao do Limite de Pesquisa qdo    #
#                                       for Demanda e Acerto dos Filtros de   #
#                                       Consulta                              #
# 12/11/2007 Ligia Mattge    Input da atividade                               #
#-----------------------------------------------------------------------------#
# 06/06/2008 Norton - Meta   Inclusao da chamada da funcao                    #
#                            cts00m20_verif_auto                              #
# 28/01/2009 Adriano Santos  PSI 235849 Considerar tipo de serviço SINISTRO RE#
# 02/03/2010 Adriano Santos  PSI252891  Inclusao do padrao idx 4 e 5          #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctx25g04_prep smallint

  define am_ctx25g04   array[2000] of record
         atdvclsgl     like datkveiculo.atdvclsgl,
         c24atvcod     like dattfrotalocal.c24atvcod,
         socvclcod     like dattfrotalocal.socvclcod,
         socvcltipdes  char (50),
         vcleqpdes     char (15),
         srrcoddig     like dattfrotalocal.srrcoddig,
         srrabvnom     like datksrr.srrabvnom,
         srrasides     char (100),
         ufdcod_gps    like datmfrtpos.ufdcod,
         cidnom_gps    like datmfrtpos.cidnom,
         brrnom_gps    like datmfrtpos.brrnom,
         endzon_gps    like datmfrtpos.endzon,
         obspostxt     like dattfrotalocal.obspostxt,
         temp_rot      datetime hour to minute,
         dist_rot      decimal(8,3),
         espera        interval hour(2) to second,
         dstqtd        decimal(8,4),
         atdprscod     like datmservico.atdprscod,
         lclltt        like datmfrtpos.lclltt,
         lcllgt        like datmfrtpos.lcllgt
  end record

  define am_ctx25g04b   array[2000] of record
         atdvclsgl     like datkveiculo.atdvclsgl,
         c24atvcod     like dattfrotalocal.c24atvcod,
         socvclcod     like dattfrotalocal.socvclcod,
         socvcltipdes  char (50),
         vcleqpdes     char (15),
         srrcoddig     like dattfrotalocal.srrcoddig,
         srrabvnom     like datksrr.srrabvnom,
         srrasides     char (100),
         ufdcod_gps    like datmfrtpos.ufdcod,
         cidnom_gps    like datmfrtpos.cidnom,
         brrnom_gps    like datmfrtpos.brrnom,
         endzon_gps    like datmfrtpos.endzon,
         obspostxt     like dattfrotalocal.obspostxt,
         temp_rot      datetime hour to minute,
         dist_rot      decimal(8,3),
         espera        interval hour(2) to second,
         dstqtd        decimal(8,4),
         atdprscod     like datmservico.atdprscod,
         lclltt        like datmfrtpos.lclltt,
         lcllgt        like datmfrtpos.lcllgt
  end record

  define am_ctx25g04c  array[2000] of record
         atdvclsgl     like datkveiculo.atdvclsgl,
         c24atvcod     like dattfrotalocal.c24atvcod,
         socvclcod     like dattfrotalocal.socvclcod,
         socvcltipdes  char (50),
         vcleqpdes     char (15),
         srrcoddig     like dattfrotalocal.srrcoddig,
         srrabvnom     like datksrr.srrabvnom,
         srrasides     char (100),
         ufdcod_gps    like datmfrtpos.ufdcod,
         cidnom_gps    like datmfrtpos.cidnom,
         brrnom_gps    like datmfrtpos.brrnom,
         endzon_gps    like datmfrtpos.endzon,
         obspostxt     like dattfrotalocal.obspostxt,
         temp_rot      datetime hour to minute,
         dist_rot      decimal(8,3),
         espera        interval hour(2) to second,
         dstqtd        decimal(8,4),
         atdprscod     like datmservico.atdprscod,
         lclltt        like datmfrtpos.lclltt,
         lcllgt        like datmfrtpos.lcllgt
  end record

#-------------------------#
function ctx25g04_prepare()
#-------------------------#

  define l_sql  char(1000)
  

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_sql  =  null

  let l_sql = " select grlinf, grlchv "
             ,"   from igbkgeral "
             ,"  where mducod = 'C24' "
             ,"    and grlchv matches 'RADIO-DEM*' "
             ,"    and grlinf = '1'"

  prepare p_ctx25g04_001 from l_sql
  declare c_ctx25g04_001 cursor for p_ctx25g04_001

  let l_sql = " select c24opemat, c24opeempcod, c24opeusrtip "
             ,"   from datkveiculo "
             ,"  where socvclcod = ? "

  prepare p_ctx25g04_002 from l_sql
  declare c_ctx25g04_002 cursor for p_ctx25g04_002

  let l_sql = " select funnom "
             ,"   from isskfunc "
             ,"  where funmat = ? "
             ,"    and empcod = ? "
             ,"    and usrtip = ? "

  prepare p_ctx25g04_003 from l_sql
  declare c_ctx25g04_003 cursor for p_ctx25g04_003

  let l_sql = " update datkveiculo "
             ,"    set socacsflg = ? "
             ,"       ,c24opemat = ? "
             ,"       ,c24opeempcod = ? "
             ,"       ,c24opeusrtip = ? "
             ,"  where socvclcod = ? "

  prepare p_ctx25g04_004 from l_sql

  let l_sql = " select atdsrvnum, atdsrvano "
             ,"   from dattfrotalocal "
             ,"  where socvclcod = ? "

  prepare p_ctx25g04_005 from l_sql
  declare c_ctx25g04_004 cursor for p_ctx25g04_005

  let l_sql = " select vcldtbgrpdes ",
              "   from datkvcldtbgrp ",
              "  where vcldtbgrpcod = ? "

  prepare p_ctx25g04_006 from l_sql
  declare c_ctx25g04_005 cursor for p_ctx25g04_006

 let l_sql = "select socvcltip ",
              " from datkveiculo ",
             " where socvclcod = ? "

  prepare p_ctx25g04_007  from l_sql
  declare c_ctx25g04_006   cursor for p_ctx25g04_007

  let l_sql = " select soceqpabv ",
              "   from datreqpvcl, outer datkvcleqp",
              "  where datreqpvcl.socvclcod = ? ",
              "    and datkvcleqp.soceqpcod = datreqpvcl.soceqpcod "
  prepare p_ctx25g04_008    from l_sql
  declare c_ctx25g04_007  cursor for p_ctx25g04_008

  let l_sql = " select socntzcod , espcod "
             ," from datmsrvre            "
             ," where atdsrvnum =  ?      "
             ,"   and atdsrvano = ?       "

  prepare p_ctx25g04_009 from l_sql
  declare c_ctx25g04_008 cursor for p_ctx25g04_009

  let l_sql = " select atdsrvorg, asitipcod, atdhorpvt ",
              " ,ciaempcod ",                              #PSI 205206
                " from datmservico ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_ctx25g04_010 from l_sql
  declare c_ctx25g04_009 cursor for p_ctx25g04_010

  let l_sql =  " select lclltt, ",
                      " lcllgt, ",
                      " c24lclpdrcod, ",
                      " cidnom, ",
                      " ufdcod ",
                 " from datmlcl ",
                " where atdsrvnum = ? ",
                  " and atdsrvano = ? ",
                  " and c24endtip = 1 "

  prepare p_ctx25g04_011 from l_sql
  declare c_ctx25g04_010 cursor for p_ctx25g04_011

  let l_sql =  " select socntzgrpcod, ",
                      " datksocntz.socntzcod ",
                 " from datmsrvre, datksocntz ",
                " where datmsrvre.atdsrvnum  = ? ",
                  " and datmsrvre.atdsrvano = ? ",
                  " and datksocntz.socntzcod = datmsrvre.socntzcod "

  prepare p_ctx25g04_012 from l_sql
  declare c_ctx25g04_011 cursor for p_ctx25g04_012

  let l_sql = " select c24atvcod, atdsrvnum, atdsrvano ",
                " from dattfrotalocal ",
               " where socvclcod = ? "

  prepare p_ctx25g04_013 from l_sql
  declare c_ctx25g04_012 cursor for p_ctx25g04_013

  # -> BUSCA A DESCRICAO DA ASSISTENCIA
  let l_sql = " select asitipdes ",
                " from datkasitip ",
               " where asitipcod = ? "

  prepare p_ctx25g04_014 from l_sql
  declare c_ctx25g04_013 cursor for p_ctx25g04_014

  # -> BUSCA A DESCRICAO DA NATUREZA
  let l_sql = " select socntzdes ",
                " from datksocntz ",
               " where socntzcod = ? "

  prepare p_ctx25g04_015 from l_sql
  declare c_ctx25g04_014 cursor for p_ctx25g04_015
  let l_sql = " select cpodes from iddkdominio ",
               " where cponom = 'socvcltip' ",
                 " and cpocod = ? "
  prepare pctx25g04025 from l_sql
  declare cctx25g04025 cursor for pctx25g04025

  let m_ctx25g04_prep = true

end function

#-----------------------------#
function ctx25g04(lr_parametro)
#-----------------------------#

 define lr_parametro  record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    gpsacngrpcod      like datkmpacid.gpsacngrpcod,
    tipo_demanda      char(15)
 end record

 define d_ctx25g04    record
    vcldtbgrpcod      like dattfrotalocal.vcldtbgrpcod,
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    asitipcod         like datmservico.asitipcod,
    desc_asist_nat    char(20), # -> ARMAZENA A DESCRI DA NATUREZA OU ASSIST.
    asist_nat         smallint,  # -> ARMAZENA A NATUREZA OU ASSISTENCIA
    ciaempcod         like datrvclemp.ciaempcod,             #PSI 205206
    empsgl            like gabkemp.empsgl,                   #PSI 205206
    c24atvpsq         like dattfrotalocal.c24atvcod
 end record

 define ws            record
    atdsrvorg         like datmservico.atdsrvorg,
    lclltt_srv        like datmlcl.lclltt,
    lcllgt_srv        like datmlcl.lcllgt,
    lcllgt_vcl        like datmlcl.lcllgt,
    vclcoddig         like datkveiculo.vclcoddig,
    vclmrcnom         like agbkmarca.vclmrcnom,
    vcltipnom         like agbktip.vcltipnom,
    vclmdlnom         like agbkveic.vclmdlnom,
    soceqpabv         like datkvcleqp.soceqpabv,
    asitipabvdes      like datkasitip.asitipabvdes,
    total             char (10),
    comando           char (3000),
    condicao          char (1500),
    f8flg             char (01),
    srrcoddig         like datrsrrasi.srrcoddig,
    asitipstt         like datkasitip.asitipstt,
    atldat            like datmfrtpos.atldat,
    atlhor            like datmfrtpos.atlhor,
    confirma          char (01),
    socvclcod_datmservico like datmservico.socvclcod,
    socacsflg         like datkveiculo.socacsflg,
    flag_cts00m02     dec(01,0),
    tempodif          interval hour(2) to second,
    atdhorpvt         char(6),
    prvcalc           char(6),
    socntzgrpcod      like datksocntz.socntzgrpcod,
    vcldtbgrpcod      like dattfrotalocal.vcldtbgrpcod,
    c24atvcod         like dattfrotalocal.c24atvcod,
    atdsrvnum         like dattfrotalocal.atdsrvnum,
    atdsrvano         like dattfrotalocal.atdsrvano,
    opcao             smallint,
    opcaodes          char(40),
    linha             char(120),
    nometxt           char(30),
    executa           char(200),
    c24lclpdrcod      like datmlcl.c24lclpdrcod,
    cidnom_srv        like datmlcl.cidnom,
    ufdcod_srv        like datmlcl.ufdcod
 end record

 define al_saida array[10] of record
    atdmltsrvnum like datratdmltsrv.atdmltsrvnum
   ,atdmltsrvano like datratdmltsrv.atdmltsrvano
   ,socntzdes    like datksocntz.socntzdes
   ,espdes       like dbskesp.espdes
   ,atddfttxt    like datmservico.atddfttxt
 end record

 define l_resultado   smallint
 define l_mensagem    char(30)
 define l_i           smallint
 define prompt_key    char(01)
 define arr_aux       smallint
 define arr_aux1      smallint
 define arr_aux2      smallint
 define arr_aux3      smallint
 define arr_aux4      smallint
 define ws_cont       smallint
 define l_retorno     integer
 define l_primeiro    smallint
 define l_dist_max    decimal(8,4)

 define l_srvrcumtvcod    like datmsrvacp.srvrcumtvcod

 define l_cont          smallint
       ,l_cont_a        smallint
       ,l_stringop      char(50)
       ,l_op            smallint
       ,l_desc          char(30)
       ,l_c24opemat     like datkveiculo.c24opemat
       ,l_c24opeempcod  like datkveiculo.c24opeempcod
       ,l_c24opeusrtip  like datkveiculo.c24opeusrtip
       ,l_funnom        like isskfunc.funnom
       ,l_socacsflg     like datkveiculo.socacsflg

 define lr_frota        record
        atdsrvnum       like dattfrotalocal.atdsrvnum
       ,atdsrvano       like dattfrotalocal.atdsrvano
 end record

 define al_ctx25g04 array[50] of record
        grlinf like igbkgeral.grlinf
       ,grlchv like igbkgeral.grlchv
 end record

 define l_tmp_flg    smallint,
        l_posicao    smallint,
        l_tipo_texto char(12)

  define l_socntzcod   like datmsrvre.socntzcod,
         l_espcod      like datmsrvre.espcod,
         l_sql         char(600),
         l_srrcoddig   like datrsrrasi.srrcoddig,
         l_tipasivalidos char(15),
         l_qtde_rotas  smallint,
         l_linha       char(100)

  define l_rota_f7   char(32000),
         l_dist_f7   decimal(8,3),
         l_temp_f7   decimal(6,1),
         l_tipo_rota char(07),
         l_socvcltip char(300)

  if m_ctx25g04_prep is null or
     m_ctx25g04_prep <> true then
     call ctx25g04_prepare()
 end if

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_srrcoddig = null
  let l_sql = null
  let l_espcod = null
  let l_socntzcod = null
  let l_resultado  =  null
  let l_mensagem  =  null
  let l_i  =  null
  let prompt_key  =  null
  let arr_aux  =  null
  let l_qtde_rotas = null
  let arr_aux1  =  null
  let arr_aux2  =  null
  let l_tipo_texto = null
  let arr_aux3  =  null
  let arr_aux4  =  null
  let ws_cont  =  null
  let l_retorno  =  null
  let l_primeiro  =  null
  let l_srvrcumtvcod  =  null
  let l_cont  =  null
  let l_cont_a  =  null
  let l_stringop  =  null
  let l_op  =  null
  let l_desc  =  null
  let l_c24opemat  =  null
  let l_c24opeempcod  =  null
  let l_c24opeusrtip  =  null
  let l_funnom  =  null
  let l_socacsflg  =  null
  let l_tmp_flg  =  null
  let l_posicao  =  null
  let l_rota_f7  = null
  let l_dist_f7  = null
  let l_temp_f7  = null
  let l_tipo_rota = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize am_ctx25g04  to null
  initialize am_ctx25g04b to null
  initialize am_ctx25g04c to null
  initialize al_saida    to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize d_ctx25g04.*            to null
  initialize ws                      to null
  initialize lr_frota                to null
  initialize al_ctx25g04, l_stringop to null

  let l_cont = 1
  let l_primeiro = false

  initialize al_saida to null
  let l_resultado = null
  let l_mensagem  = null
  let l_i         = 1
  let l_posicao   = null

  let prompt_key  =  null
  let arr_aux     =  null
  let arr_aux1    =  null
  let arr_aux2    =  null
  let arr_aux3    =  null
  let arr_aux4    =  null
  let l_dist_max  = ctx25g05_distancia_maxima()

  if l_dist_max is null then
     error "Nao encontrou a dist. max. parametrizada na datkgeral. AVISE A INFORMATICA!" sleep 5
     return "","","","","","",""
  end if

  initialize  am_ctx25g04  to null
  initialize  am_ctx25g04b to null
  initialize  am_ctx25g04c to null
  initialize  d_ctx25g04  to null
  initialize  ws          to null

 let arr_aux  =  1
 let ws.tempodif  = "00:20:00"

 #------------------------------------------------------------------
 # Verifica parametros informados
 #------------------------------------------------------------------
 if lr_parametro.tipo_demanda is not null then
    let  l_cont = 1
    open c_ctx25g04_001
    foreach c_ctx25g04_001 into al_ctx25g04[l_cont].grlinf,
                              al_ctx25g04[l_cont].grlchv
       let l_cont = l_cont + 1
       if l_cont > 50 then
          error "Limite de array excedido"
          exit foreach
       end if
    end foreach
    close c_ctx25g04_001

    let l_cont = l_cont - 1
    if l_cont < 1 then
       error "Nao existe demanda ativa!!!" sleep 2
       return am_ctx25g04[arr_aux].atdprscod,
              am_ctx25g04[arr_aux].atdvclsgl,
              am_ctx25g04[arr_aux].srrcoddig,
              am_ctx25g04[arr_aux].socvclcod,
              ws.prvcalc,
              am_ctx25g04[arr_aux].dstqtd,
              ws.flag_cts00m02
    end if
    if l_cont = 1 then
       let lr_parametro.tipo_demanda = al_ctx25g04[1].grlchv
       if  lr_parametro.tipo_demanda = "RADIO-DEMAU" then
           let ws.atdsrvorg = 1
       end if
       if  lr_parametro.tipo_demanda = "RADIO-DEMRE" then
           let ws.atdsrvorg = 9
       end if
       if  lr_parametro.tipo_demanda = "RADIO-DEMJI" then
           let ws.atdsrvorg = 15
       end if
       if  lr_parametro.tipo_demanda = "RADIO-DEMVP" then
           let ws.atdsrvorg = 10
       end if
    else
       let l_stringop = null
       for l_cont_a = 1 to l_cont
          if al_ctx25g04[l_cont_a].grlchv = "RADIO-DEMAU" then
             if  l_stringop is null then
                 let l_stringop = "AUTO"
             else
                 let l_stringop = l_stringop clipped,"|AUTO"
             end if
          end if
          if al_ctx25g04[l_cont_a].grlchv = "RADIO-DEMRE" then
             if  l_stringop is null then
                 let l_stringop = "RE"
             else
                 let l_stringop = l_stringop clipped,"|RE"
             end if
          end if
          if al_ctx25g04[l_cont_a].grlchv = "RADIO-DEMJI" then
             if  l_stringop is null then
                 let l_stringop = "JIT"
             else
                 let l_stringop = l_stringop clipped,"|JIT"
             end if
          end if
          if al_ctx25g04[l_cont_a].grlchv = "RADIO-DEMVP" then
             if  l_stringop is null then
                 let l_stringop = "VP"
             else
                 let l_stringop = l_stringop clipped,"|VP"
             end if
          end if
       end for
       call ctx14g00("DEMANDA", l_stringop) returning l_op, l_desc
       if l_op = 0 then
          return am_ctx25g04[arr_aux].atdprscod,
                 am_ctx25g04[arr_aux].atdvclsgl,
                 am_ctx25g04[arr_aux].srrcoddig,
                 am_ctx25g04[arr_aux].socvclcod,
                 ws.prvcalc,
                 am_ctx25g04[arr_aux].dstqtd,
                 ws.flag_cts00m02
       end if
       if l_desc = 'AUTO' then
          let lr_parametro.tipo_demanda = "RADIO-DEMAU"
          let ws.atdsrvorg = 1
       end if
       if l_desc = 'RE' then
          let lr_parametro.tipo_demanda = "RADIO-DEMRE"
          let ws.atdsrvorg = 9
       end if
       if l_desc = 'JIT' then
          let lr_parametro.tipo_demanda = "RADIO-DEMJI"
          let ws.atdsrvorg = 15
       end if
       if l_desc = 'VP' then
          let lr_parametro.tipo_demanda = "RADIO-DEMVP"
          let ws.atdsrvorg = 10
       end if
    end if
 else

    if lr_parametro.atdsrvnum  is null   or
       lr_parametro.atdsrvano  is null   then
       error " Numero do servico nao informado, AVISE INFORMATICA!"
       return am_ctx25g04[arr_aux].atdprscod,
              am_ctx25g04[arr_aux].atdvclsgl,
              am_ctx25g04[arr_aux].srrcoddig,
              am_ctx25g04[arr_aux].socvclcod,
              ws.prvcalc,
              am_ctx25g04[arr_aux].dstqtd,
              ws.flag_cts00m02
    end if

    open c_ctx25g04_009 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano
    fetch c_ctx25g04_009 into ws.atdsrvorg, d_ctx25g04.asitipcod, ws.atdhorpvt,
                            d_ctx25g04.ciaempcod                       #PSI 205206

    # -> RECEBE O TIPO DE ASSISTENCIA
    let d_ctx25g04.asist_nat = d_ctx25g04.asitipcod

    if sqlca.sqlcode  =  notfound   then
       error " Servico nao encontrado, AVISE INFORMATICA!"
       close c_ctx25g04_009
       return am_ctx25g04[arr_aux].atdprscod,
              am_ctx25g04[arr_aux].atdvclsgl,
              am_ctx25g04[arr_aux].srrcoddig,
              am_ctx25g04[arr_aux].socvclcod,
              ws.prvcalc,
              am_ctx25g04[arr_aux].dstqtd,
              ws.flag_cts00m02
    end if

    close c_ctx25g04_009

    #------------------------------------------------------------------
    # Verifica tipo do servico/tipo da assistencia
    #------------------------------------------------------------------
    if ws.atdsrvorg  <>  13  and   # Sinistro RE
       ws.atdsrvorg  <>  4   and   # Remocao
       ws.atdsrvorg  <>  6   and   # DAF
       ws.atdsrvorg  <>  1   and   # Socorro
       ws.atdsrvorg  <>  10  and   # Vistoria
       ws.atdsrvorg  <>  5   and   # RPT
       ws.atdsrvorg  <>  7   and   # Replace
       ws.atdsrvorg  <>  17  and   # Replace s/docto
       ws.atdsrvorg  <>  9   and   # Socorro RE
       ws.atdsrvorg  <>  2   and   # Transporte
       ws.atdsrvorg  <>  15  then  # JIT AUTO/RE
       error " Tipo de servico nao utiliza localizacao por GPS!"
       return am_ctx25g04[arr_aux].atdprscod,
              am_ctx25g04[arr_aux].atdvclsgl,
              am_ctx25g04[arr_aux].srrcoddig,
              am_ctx25g04[arr_aux].socvclcod,
              ws.prvcalc,
              am_ctx25g04[arr_aux].dstqtd,
              ws.flag_cts00m02
    else
       if ws.atdsrvorg  =  2   and
          d_ctx25g04.asitipcod  <>  5    then         #taxi para servico a residencia
          error " Tipo de assistencia nao utiliza localizacao por GPS!"
          return am_ctx25g04[arr_aux].atdprscod,
                 am_ctx25g04[arr_aux].atdvclsgl,
                 am_ctx25g04[arr_aux].srrcoddig,
                 am_ctx25g04[arr_aux].socvclcod,
                 ws.prvcalc,
                 am_ctx25g04[arr_aux].dstqtd,
                 ws.flag_cts00m02
       end if
    end if

    #------------------------------------------------------------------
    # Verifica se servico possui latitude/longitude
    #------------------------------------------------------------------
    open c_ctx25g04_010 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano
    fetch c_ctx25g04_010 into ws.lclltt_srv, ws.lcllgt_srv, ws.c24lclpdrcod, ws.cidnom_srv, ws.ufdcod_srv

    if sqlca.sqlcode  =  notfound   then
       close c_ctx25g04_010
       error " Local da ocorrencia nao encontrado, AVISE INFORMATICA!"
       return am_ctx25g04[arr_aux].atdprscod,
              am_ctx25g04[arr_aux].atdvclsgl,
              am_ctx25g04[arr_aux].srrcoddig,
              am_ctx25g04[arr_aux].socvclcod,
              ws.prvcalc,
              am_ctx25g04[arr_aux].dstqtd,
              ws.flag_cts00m02
    end if

    close c_ctx25g04_010

    if ws.lclltt_srv  is null   or
       ws.lcllgt_srv  is null   or
       (ws.c24lclpdrcod <> 3 and
        ws.c24lclpdrcod <> 4 and # PSI 252891
        ws.c24lclpdrcod <> 5 and
        (not cts40g12_gpsacncid(ws.cidnom_srv, ws.ufdcod_srv)) # Verifica se o acionamento GPS pode ser realizado pela coordenada da Cidade
       )then
       error " Servico nao possui localizacao por latitude/longitude!"
       return am_ctx25g04[arr_aux].atdprscod,
              am_ctx25g04[arr_aux].atdvclsgl,
              am_ctx25g04[arr_aux].srrcoddig,
              am_ctx25g04[arr_aux].socvclcod,
              ws.prvcalc,
              am_ctx25g04[arr_aux].dstqtd,
              ws.flag_cts00m02
    end if
 end if

 #------------------------------------------------------------------
 # Informa dados para pesquisa
 #------------------------------------------------------------------
 open window w_ctx25g04 at  04,02 with form "ctx25g04"
             attribute(form line first)

 call ctc61m02(lr_parametro.atdsrvnum,lr_parametro.atdsrvano,"A")

 let l_tmp_flg = ctc61m02_criatmp(2,
                                  lr_parametro.atdsrvnum,
                                  lr_parametro.atdsrvano)

 if l_tmp_flg = 1 then
    error "Problemas com temporaria ! <Avise a Informatica>."
 end if

 if ws.atdsrvorg = 9 or ws.atdsrvorg = 13 then

    open c_ctx25g04_011 using lr_parametro.atdsrvnum,
                            lr_parametro.atdsrvano
    fetch c_ctx25g04_011 into ws.socntzgrpcod,
                            d_ctx25g04.asist_nat # NATUREZA DO SERVICO

    if sqlca.sqlcode = notfound then
       let ws.socntzgrpcod = 2
    end if

    close c_ctx25g04_011

    let l_tipo_texto = "Natureza:"
 else
    let l_tipo_texto = "Assistencia:"
 end if

 while true

   clear form
   display l_tipo_texto to tipo_texto

   if ws.atdsrvorg = 9 or
      ws.atdsrvorg = 13 then
      # -> BUSCA A DESCRICAO DA NATUREZA
      if d_ctx25g04.asist_nat is not null then
         open c_ctx25g04_014 using d_ctx25g04.asist_nat
         whenever error continue
         fetch c_ctx25g04_014 into d_ctx25g04.desc_asist_nat
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               let d_ctx25g04.desc_asist_nat = null
            else
               error "Erro SELECT c_ctx25g04_014 / ", sqlca.sqlcode,
                                             " / ", sqlca.sqlerrd[2]
               sleep 2
            end if
            close c_ctx25g04_013
         end if

         close c_ctx25g04_014
      end if

      display by name d_ctx25g04.desc_asist_nat
   else
      # -> BUSCA A DESCRICAO DA ASSISTENCIA
      if d_ctx25g04.asist_nat is not null then
         open c_ctx25g04_013 using d_ctx25g04.asist_nat
         whenever error continue
         fetch c_ctx25g04_013 into d_ctx25g04.desc_asist_nat
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               let d_ctx25g04.desc_asist_nat = null
            else
               error "Erro SELECT c_ctx25g04_013 / ", sqlca.sqlcode,
                                             " / ", sqlca.sqlerrd[2]
               sleep 2
            end if
            close c_ctx25g04_013
         end if

         close c_ctx25g04_013
      end if

      if d_ctx25g04.desc_asist_nat is null then
         let d_ctx25g04.desc_asist_nat = "TODAS"
      end if

      display by name d_ctx25g04.desc_asist_nat
   end if

   #PSI 205206
   if d_ctx25g04.ciaempcod is null then
      let d_ctx25g04.empsgl = "TODAS"
   else
      #------------------------------------------------------------------
      # Busca descrição da empresa
      #------------------------------------------------------------------
      call cty14g00_empresa(1, d_ctx25g04.ciaempcod)
           returning l_retorno,
                     l_mensagem,
                     d_ctx25g04.empsgl
   end if
   display by name d_ctx25g04.ciaempcod attribute (reverse)
   display by name d_ctx25g04.empsgl attribute (reverse)

   let int_flag  =  false
   let ws.f8flg  =  "N"
   let arr_aux   =  1

   input by name d_ctx25g04.vcldtbgrpcod,
                 d_ctx25g04.asist_nat,
                 d_ctx25g04.ciaempcod,
                 d_ctx25g04.c24atvpsq without defaults

      before field vcldtbgrpcod

             display by name d_ctx25g04.vcldtbgrpcod thru
                             d_ctx25g04.vcldtbgrpdes
             if ws.atdsrvorg = 9 or ws.atdsrvorg = 13 then
                let d_ctx25g04.vcldtbgrpcod = 4
                if ws.socntzgrpcod = 1  then    # linha branca
                   let d_ctx25g04.vcldtbgrpcod = 3 #somente linha branca
                end if
             end if

             if lr_parametro.tipo_demanda = "RADIO-DEMVP" then
                let d_ctx25g04.vcldtbgrpcod = 10
             end if
             if lr_parametro.tipo_demanda = "RADIO-DEMJI" then
                let d_ctx25g04.vcldtbgrpcod = 7
             end if

             let d_ctx25g04.vcldtbgrpdes = null

             if d_ctx25g04.vcldtbgrpcod is not null then
                open c_ctx25g04_005 using d_ctx25g04.vcldtbgrpcod
                whenever error continue
                fetch c_ctx25g04_005 into d_ctx25g04.vcldtbgrpdes
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode <> 100 then
                      error 'Problemas de acesso a tabela datkvcldtbgrp, ',
                            sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                      error 'ctx25g04()', d_ctx25g04.vcldtbgrpcod sleep 2
                      exit input
                   end if
                end if
                close c_ctx25g04_005
             end if

             display by name d_ctx25g04.vcldtbgrpcod  attribute (reverse)
             display by name d_ctx25g04.vcldtbgrpdes


      after  field vcldtbgrpcod
             display by name d_ctx25g04.vcldtbgrpcod

             initialize d_ctx25g04.vcldtbgrpdes  to null
             display by name d_ctx25g04.vcldtbgrpdes

             if d_ctx25g04.vcldtbgrpcod  is null   then
                let d_ctx25g04.vcldtbgrpdes  =  "TODOS"
             else

                open c_ctx25g04_005 using d_ctx25g04.vcldtbgrpcod
                whenever error continue
                fetch c_ctx25g04_005 into d_ctx25g04.vcldtbgrpdes
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                      error " Grupo de distribuicao nao cadastrado!"
                      if lr_parametro.tipo_demanda is not null then
                         call ctn39c00_demanda(l_desc)
                              returning d_ctx25g04.vcldtbgrpcod
                      else
                         call ctn39c00() returning d_ctx25g04.vcldtbgrpcod
                      end if
                      next field vcldtbgrpcod
                   else
                      error 'Problemas de acesso a tabela datkvcldtbgrp, ',
                            sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                      error 'ctx25g04()', d_ctx25g04.vcldtbgrpcod sleep 2
                      exit input
                   end if
                end if
                close c_ctx25g04_005
             end if

             display by name d_ctx25g04.vcldtbgrpdes

      before field asist_nat
         display by name d_ctx25g04.asist_nat attribute(reverse)

      after field asist_nat
         display by name d_ctx25g04.asist_nat

         if ws.atdsrvorg = 9 or
            ws.atdsrvorg = 13 then
            # -> BUSCA A DESCRICAO DA NATUREZA
            if d_ctx25g04.asist_nat is not null then
               open c_ctx25g04_014 using d_ctx25g04.asist_nat
               whenever error continue
               fetch c_ctx25g04_014 into d_ctx25g04.desc_asist_nat
               whenever error stop

               if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode = notfound then
                     error "Natureza nao cadastrada"
                     let d_ctx25g04.desc_asist_nat = null
                  else
                     error "Erro SELECT c_ctx25g04_014 / ", sqlca.sqlcode,
                                                   " / ", sqlca.sqlerrd[2]
                     sleep 2
                  end if
                  close c_ctx25g04_013
                  next field asist_nat
               end if

               close c_ctx25g04_014
            end if

            display by name d_ctx25g04.desc_asist_nat
         else
            # -> BUSCA A DESCRICAO DA ASSISTENCIA
            if d_ctx25g04.asist_nat is not null then
               open c_ctx25g04_013 using d_ctx25g04.asist_nat
               whenever error continue
               fetch c_ctx25g04_013 into d_ctx25g04.desc_asist_nat
               whenever error stop

               if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode = notfound then
                     error "Assistencia nao cadastrada"
                     let d_ctx25g04.desc_asist_nat = null
                  else
                     error "Erro SELECT c_ctx25g04_013 / ", sqlca.sqlcode,
                                                   " / ", sqlca.sqlerrd[2]
                     sleep 2
                  end if
                  close c_ctx25g04_013
                  next field asist_nat
               end if

               close c_ctx25g04_013
            end if

         end if

        if d_ctx25g04.asist_nat is null then
            let d_ctx25g04.desc_asist_nat = "TODAS"
        end if

        display by name d_ctx25g04.desc_asist_nat

      #PSI 205206
      before field ciaempcod
         display by name d_ctx25g04.ciaempcod attribute (reverse)

      after field ciaempcod
         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field asist_nat
         end if
         if d_ctx25g04.ciaempcod is null then
            let d_ctx25g04.empsgl = "TODAS"
         else
            #------------------------------------------------------------------
            # Busca descrição da empresa
            #------------------------------------------------------------------
            call cty14g00_empresa(1, d_ctx25g04.ciaempcod)
                 returning l_retorno,
                           l_mensagem,
                           d_ctx25g04.empsgl
         end if
         display by name d_ctx25g04.ciaempcod attribute (reverse)
         display by name d_ctx25g04.empsgl attribute (reverse)

      before field c24atvpsq
           let d_ctx25g04.c24atvpsq = "QRV"
           display by name d_ctx25g04.c24atvpsq attribute (reverse)

      after field c24atvpsq
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field ciaempcod
           end if

           if d_ctx25g04.c24atvpsq is not null and
              d_ctx25g04.c24atvpsq <> "QRV" and
              d_ctx25g04.c24atvpsq <> "QRA" and
              d_ctx25g04.c24atvpsq <> "QTP" and
              d_ctx25g04.c24atvpsq <> "INI" and
              d_ctx25g04.c24atvpsq <> "FIM" and
              d_ctx25g04.c24atvpsq <> "QRU" and
              d_ctx25g04.c24atvpsq <> "QRX" then
              error "Atividade invalida"
              next field c24atvpsq
           end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   #------------------------------------------------------------------
   # Lê todos os veículos disponíveis para atendimento
   #------------------------------------------------------------------
   message " Favor aguardar, pesquisando veiculos..."  attribute(reverse)

   let ws.comando =
          "select dattfrotalocal.srrcoddig, ",
                " dattfrotalocal.c24atvcod, ",
                " dattfrotalocal.obspostxt, ",
                " datkveiculo.socvclcod, ",
                " datkveiculo.atdvclsgl, ",
                " datkveiculo.vclcoddig, ",
                " datkveiculo.pstcoddig, ",
                " datksrr.srrabvnom, ",
                " datmfrtpos.ufdcod, ",
                " datmfrtpos.cidnom, ",
                " datmfrtpos.brrnom, ",
                " datmfrtpos.endzon, ",
                " datmfrtpos.lclltt, ",
                " datmfrtpos.lcllgt, ",
                " datmfrtpos.atldat, ",
                " datmfrtpos.atlhor, ",
                " dattfrotalocal.vcldtbgrpcod ",
           " from dattfrotalocal, datkveiculo, outer datksrr, outer datmfrtpos "

   #PSI 224782
   if d_ctx25g04.asist_nat is not null and (ws.atdsrvorg <> 9 and ws.atdsrvorg <> 13) then
       let ws.comando =  ws.comando clipped,
                 " ,datrsrrasi, datkasitip, datrvclasi "
   end if

   if d_ctx25g04.vcldtbgrpcod  is not null  and
      d_ctx25g04.c24atvpsq     is not null  then

      let ws.condicao =
              "where dattfrotalocal.vcldtbgrpcod = ? ",
               " and dattfrotalocal.c24atvcod    = ? "

      #PSI 224782
      if d_ctx25g04.asist_nat  is not null and (ws.atdsrvorg <> 9 and ws.atdsrvorg <> 13) then
          let ws.condicao = ws.condicao clipped,
                            " and datrsrrasi.asitipcod = ? ",
                            " and datrsrrasi.srrcoddig  = dattfrotalocal.srrcoddig ",
                            #and dattfrotalocal.socvclcod = datkveiculo.socvclcod
                            " and datrsrrasi.asitipcod  = datkasitip.asitipcod ",
                            " and datrvclasi.socvclcod  = datkveiculo.socvclcod ",
                            " and datrvclasi.asitipcod  = datrsrrasi.asitipcod "
      end if

   else if d_ctx25g04.vcldtbgrpcod  is not null   and
           d_ctx25g04.c24atvpsq     is null       then

           let ws.condicao = "where dattfrotalocal.vcldtbgrpcod = ? ",
                             " and  dattfrotalocal.c24atvcod in ",
                             " ('QRV','QRU','QRA','QRX','QTP','INI','FIM'  ) "
           #PSI 224782
           if d_ctx25g04.asist_nat  is not null and (ws.atdsrvorg <> 9 and ws.atdsrvorg <> 13) then
               let ws.condicao = ws.condicao clipped,
                                 " and datrsrrasi.asitipcod = ? ",
                                 " and datrsrrasi.srrcoddig  = dattfrotalocal.srrcoddig ",
                                 #and dattfrotalocal.socvclcod = datkveiculo.socvclcod
                                 " and datrsrrasi.asitipcod  = datkasitip.asitipcod ",
                                 " and datrvclasi.socvclcod  = datkveiculo.socvclcod ",
                                 " and datrvclasi.asitipcod  = datrsrrasi.asitipcod "
           end if

        else if d_ctx25g04.vcldtbgrpcod  is null   and
                d_ctx25g04.c24atvpsq     is not null then
                let ws.condicao =
                    "where dattfrotalocal.vcldtbgrpcod <> 5 ",
                    " and  dattfrotalocal.c24atvcod = ? "

                #PSI 224782
                if d_ctx25g04.asist_nat  is not null and (ws.atdsrvorg <> 9 and ws.atdsrvorg <> 13) then
                    let ws.condicao = ws.condicao clipped,
                                     " and datrsrrasi.asitipcod = ? ",
                                     " and datrsrrasi.srrcoddig  = dattfrotalocal.srrcoddig ",
                                     #and dattfrotalocal.socvclcod = datkveiculo.socvclcod
                                     " and datrsrrasi.asitipcod  = datkasitip.asitipcod ",
                                     " and datrvclasi.socvclcod  = datkveiculo.socvclcod ",
                                     " and datrvclasi.asitipcod  = datrsrrasi.asitipcod "
                end if

             else if d_ctx25g04.vcldtbgrpcod  is null and
                     d_ctx25g04.c24atvpsq     is null then
                     let ws.condicao =
                         " where dattfrotalocal.vcldtbgrpcod <> 5 ",
                         " and   dattfrotalocal.c24atvcod in ",
                         " ('QRV','QRU','QRA','QRX','QTP','INI','FIM' ) "

                    #PSI 224782
                    if d_ctx25g04.asist_nat  is not null and (ws.atdsrvorg <> 9 and ws.atdsrvorg <> 13) then
                        let ws.condicao = ws.condicao clipped,
                                     " and datrsrrasi.asitipcod = ? ",
                                     " and datrsrrasi.srrcoddig  = dattfrotalocal.srrcoddig ",
                                     #and dattfrotalocal.socvclcod = datkveiculo.socvclcod
                                     " and datrsrrasi.asitipcod  = datkasitip.asitipcod ",
                                     " and datrvclasi.socvclcod  = datkveiculo.socvclcod ",
                                     " and datrvclasi.asitipcod  = datrsrrasi.asitipcod "
                    end if

                  end if

             end if

             case lr_parametro.tipo_demanda

               when "RADIO-DEMAU"
                     let ws.condicao = ws.condicao clipped,
                         " and dattfrotalocal.vcldtbgrpcod in (2,11) "
               when "RADIO-DEMRE"
                    let ws.condicao = ws.condicao clipped,
                        " and dattfrotalocal.vcldtbgrpcod in (2,3,4,6,8) "
               when "RADIO-DEMJI"
                    let ws.condicao = ws.condicao clipped,
                        " and dattfrotalocal.vcldtbgrpcod = 7 "
               when "RADIO-DEMVP"
                    let ws.condicao = ws.condicao clipped,
                        " and dattfrotalocal.vcldtbgrpcod = 10 "
             end case
        end if
   end if

   let ws.condicao =  ws.condicao clipped,
               " and datkveiculo.socvclcod       = dattfrotalocal.socvclcod ",
               " and datkveiculo.socoprsitcod    = '1' ",
               " and datksrr.srrcoddig           = dattfrotalocal.srrcoddig ",
               " and datmfrtpos.socvclcod        = dattfrotalocal.socvclcod ",
               " and datmfrtpos.socvcllcltip     = '1' ",
               " and datkveiculo.socacsflg       = '0' "

   let ws.comando  =  ws.comando clipped, " ", ws.condicao

   prepare p_ctx25g04_016   from  ws.comando
   declare c_ctx25g04_015   cursor for p_ctx25g04_016

   #display "QUERY >>>> ", ws.comando

   set isolation to dirty read

   if d_ctx25g04.vcldtbgrpcod  is not null   and
      d_ctx25g04.c24atvpsq     is not null   then
      #PSI 224782
      if d_ctx25g04.asist_nat is not null and (ws.atdsrvorg <> 9 and ws.atdsrvorg <> 13) then
          #display "if 1"
          open c_ctx25g04_015  using  d_ctx25g04.vcldtbgrpcod, d_ctx25g04.c24atvpsq, d_ctx25g04.asist_nat
      else
          open c_ctx25g04_015  using  d_ctx25g04.vcldtbgrpcod, d_ctx25g04.c24atvpsq
      end if

   else if d_ctx25g04.vcldtbgrpcod  is not null then
        #PSI 224782
        if d_ctx25g04.asist_nat  is not null and (ws.atdsrvorg <> 9 and ws.atdsrvorg <> 13) then
            #display "if 2"
            open c_ctx25g04_015  using  d_ctx25g04.vcldtbgrpcod, d_ctx25g04.asist_nat
        else
            open c_ctx25g04_015  using  d_ctx25g04.vcldtbgrpcod
        end if

        else if d_ctx25g04.c24atvpsq  is not null   then
                #PSI 224782
                if d_ctx25g04.asist_nat  is not null and (ws.atdsrvorg <> 9 and ws.atdsrvorg <> 13) then
                   #display "if 3"
                   open c_ctx25g04_015 using d_ctx25g04.c24atvpsq, d_ctx25g04.asist_nat
                else
                   open c_ctx25g04_015 using d_ctx25g04.c24atvpsq
                end if
             else
                #PSI 224782
                if d_ctx25g04.asist_nat is not null and (ws.atdsrvorg <> 9 and ws.atdsrvorg <> 13) then
                    #display "if 4"
                    open c_ctx25g04_015 using d_ctx25g04.asist_nat
                else
                    open c_ctx25g04_015
                end if
             end if
        end if
   end if

   foreach  c_ctx25g04_015  into  am_ctx25g04b[arr_aux].srrcoddig,
                                am_ctx25g04b[arr_aux].c24atvcod,
                                am_ctx25g04b[arr_aux].obspostxt,
                                am_ctx25g04b[arr_aux].socvclcod,
                                am_ctx25g04b[arr_aux].atdvclsgl,
                                ws.vclcoddig,
                                am_ctx25g04b[arr_aux].atdprscod,
                                am_ctx25g04b[arr_aux].srrabvnom,
                                am_ctx25g04b[arr_aux].ufdcod_gps,
                                am_ctx25g04b[arr_aux].cidnom_gps,
                                am_ctx25g04b[arr_aux].brrnom_gps,
                                am_ctx25g04b[arr_aux].endzon_gps,
                                am_ctx25g04b[arr_aux].lclltt,  # latitude veic.
                                am_ctx25g04b[arr_aux].lcllgt,  # longitude veic.
                                ws.atldat,
                                ws.atlhor,
                                ws.vcldtbgrpcod

{
      if  am_ctx25g04b[arr_aux].srrcoddig is null or
          am_ctx25g04b[arr_aux].srrcoddig = " " then

          let l_linha = "O VEICULO ", am_ctx25g04b[arr_aux].atdvclsgl clipped, " ESTA SEM QRA. "

          call cts08g01("A", "N", "", l_linha,
                        "AVISE A COORDENAOCAO PARA REGULARIZACAO", "")
               returning ws.confirma

          continue foreach

      end if
} #ligia 22/11/07

      if ws.vcldtbgrpcod = 3   or     # Viaturas RE /linha branca e
         ws.vcldtbgrpcod = 4   then   # Viaturas RE nao serao vistas para
         if ws.atdsrvorg <> 9  and    # outros servicos <> RE
            ws.atdsrvorg <> 13 then
            continue foreach
         end if
      end if

      if am_ctx25g04b[arr_aux].lclltt  is null or
         am_ctx25g04b[arr_aux].lcllgt  is null then
         initialize am_ctx25g04b[arr_aux]  to null
         continue foreach
      end if

      #PSI 205206
      # Validar se veiculo atende empresa solicitada
      if d_ctx25g04.ciaempcod is not null then
         call ctd05g00_valida_empveic(d_ctx25g04.ciaempcod,
                                      am_ctx25g04b[arr_aux].socvclcod)
              returning l_retorno,
                        l_mensagem
         if l_retorno <> 1 then
            #veiculo nao atende a empresa solicitada
            continue foreach
         end if
      end if



      #PSI198714 - Validar se socorrista atende assistencia/natureza do servico
      # apenas quando já tenho servico selecionado - quando não tenho é busca por demanda

      if lr_parametro.atdsrvnum is not null and
         lr_parametro.atdsrvano is not null and
         d_ctx25g04.asist_nat   is not null then


         if (ws.atdsrvorg = 1 or
            ws.atdsrvorg = 2 or
            ws.atdsrvorg = 3 or
            ws.atdsrvorg = 4 or
            ws.atdsrvorg = 5 or
            ws.atdsrvorg = 6 or
            ws.atdsrvorg = 7 or
            ws.atdsrvorg = 17) and
            am_ctx25g04b[arr_aux].srrcoddig is not null then

             #Qualquer outra origem de servico validar se socorrista atende tipo assistencia
             let l_sql = "select srrcoddig  ",
                         "   from datrsrrasi a",
                         "  where a.srrcoddig = ",am_ctx25g04b[arr_aux].srrcoddig
             case d_ctx25g04.asist_nat             #quando tipo de assistencia do servico e:
                 when 1                            #GUINCHO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #GUINCHO e GUINCHO/TECNICO
                        " and a.asitipcod in (1, 3)"
                 when 2                            #TECNICO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #TECNICO - GUINCHO/TECNICO - CHAVEIRO/TECNICO
                        " and a.asitipcod in (2,3,9)"
                 when 3                            #GUI/TEC podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #GUI/TEC ou GUINCHO e TECNICO juntos
                        " and (a.asitipcod = 3 or "
                       ,"      (a.asitipcod = 1 and    "
                       ,"        exists (select b.asitipcod               "
                       ,"                 from datrsrrasi b               "
                       ,"                 where b.srrcoddig = a.srrcoddig "
                       ,"                 and b.asitipcod = 2) ) )        "
                 when 4                            #CHAVEIRO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #CHAVEIRO E CHAVEIRO TECNICO
                        " and a.asitipcod in (4,9,40)"
                 when 9                            #CHAVEIRO TECNICO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #CHAVEIRO TECNICO OU TECNICO e Chaveiro ou Chavauto juntos
                        " and (a.asitipcod = 9 or   "
                       ,"      (a.asitipcod = 2 and "
                       ,"        exists (select b.asitipcod                "
                       ,"                  from datrsrrasi b               "
                       ,"                  where b.srrcoddig = a.srrcoddig "
                       ,"                  and (b.asitipcod = 4 or         "
                       ,"                        b.asitipcod = 40) ) ) )   "
                 when 40                           #CHAVAUTO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #CHAVEIRO - CHAVEIRO TECNICO - CHAVAUTO
                        " and a.asitipcod in (4,9,40)"

                 otherwise
                    let l_sql = l_sql clipped, " and asitipcod in (",d_ctx25g04.asist_nat,")"
             end case
             #OBS.: Hoje estamos fazendo essas conversoes de tipo de assitencia do
             # socorrista porque o cadastro deles não está integro.
             # Os códigos 3, 9 e 40 nao deveriam mais existir
             # exemplo: os socorristas que atendem assistencia 3 deveriam atender
             # assistencia 1 e 2.
             #Quando o cadastro de assistencia dos socorristas estiver correto,
             # podemos retirar essas conversoes

             prepare p_ctx25g04_017 from l_sql
             declare c_ctx25g04_016  cursor for p_ctx25g04_017
             open c_ctx25g04_016
             fetch c_ctx25g04_016  into   l_srrcoddig
             if sqlca.sqlcode = notfound then
                close c_ctx25g04_016
                continue foreach
             end if
             close c_ctx25g04_016
         end if

         if ws.atdsrvorg = 9 or
            ws.atdsrvorg = 13 then
            #Se origem servico = 9 ou 13 validar se socorrista atende natureza do servico
            #buscar natureza e especialidade do servico re
            open c_ctx25g04_008 using  lr_parametro.atdsrvnum
                                    ,lr_parametro.atdsrvano

            fetch c_ctx25g04_008 into l_socntzcod,
                                    l_espcod
            close c_ctx25g04_008

            if l_socntzcod is not null and
            	am_ctx25g04b[arr_aux].srrcoddig is not null then
            	
               let l_sql= "select socntzcod     "
                        ," from dbsrntzpstesp  "
                        ," where srrcoddig = ", am_ctx25g04b[arr_aux].srrcoddig
                        ,"   and socntzcod = ", l_socntzcod
               if l_espcod is not null then
                  #servico tem especialidade verificar se socorrista atende natureza e especialidade
                  let l_sql = l_sql clipped, " and espcod = ", l_espcod
               end if

               prepare p_ctx25g04_018 from l_sql
               declare c_ctx25g04_017 cursor for p_ctx25g04_018
               open c_ctx25g04_017
               fetch c_ctx25g04_017 into l_socntzcod

               if sqlca.sqlcode = notfound then
                  close c_ctx25g04_017
                  continue foreach
               end if

               close c_ctx25g04_017

            end if

         end if
      end if

       #CT7061486-Roberto

      if lr_parametro.atdsrvnum is  null and
         lr_parametro.atdsrvano is  null and
         d_ctx25g04.asist_nat   is not null then


         if (ws.atdsrvorg = 1 or
            ws.atdsrvorg = 2 or
            ws.atdsrvorg = 3 or
            ws.atdsrvorg = 4 or
            ws.atdsrvorg = 5 or
            ws.atdsrvorg = 6 or
            ws.atdsrvorg = 7 or
            ws.atdsrvorg = 17) and
            am_ctx25g04b[arr_aux].srrcoddig is not null then

             #Qualquer outra origem de servico validar se socorrista atende tipo assistencia
             let l_sql = "select srrcoddig  ",
                         "   from datrsrrasi a",
                         "  where a.srrcoddig = ",am_ctx25g04b[arr_aux].srrcoddig
             case d_ctx25g04.asist_nat             #quando tipo de assistencia do servico e:
                 when 1                            #GUINCHO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #GUINCHO e GUINCHO/TECNICO
                        " and a.asitipcod in (1, 3)"
                 when 2                            #TECNICO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #TECNICO - GUINCHO/TECNICO - CHAVEIRO/TECNICO
                        " and a.asitipcod in (2,3,9)"
                 when 3                            #GUI/TEC podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #GUI/TEC ou GUINCHO e TECNICO juntos
                        " and (a.asitipcod = 3 or "
                       ,"      (a.asitipcod = 1 and    "
                       ,"        exists (select b.asitipcod               "
                       ,"                 from datrsrrasi b               "
                       ,"                 where b.srrcoddig = a.srrcoddig "
                       ,"                 and b.asitipcod = 2) ) )        "
                 when 4                            #CHAVEIRO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #CHAVEIRO E CHAVEIRO TECNICO
                        " and a.asitipcod in (4,9,40)"
                 when 9                            #CHAVEIRO TECNICO podemos enviar socorrista qu
                    let l_sql = l_sql clipped,     #CHAVEIRO TECNICO OU TECNICO e Chaveiro ou Cha
                        " and (a.asitipcod = 9 or   "
                       ,"      (a.asitipcod = 2 and "
                       ,"        exists (select b.asitipcod                "
                       ,"                  from datrsrrasi b               "
                       ,"                  where b.srrcoddig = a.srrcoddig "
                       ,"                  and (b.asitipcod = 4 or         "
                       ,"                        b.asitipcod = 40) ) ) )   "
                 when 40                           #CHAVAUTO podemos enviar socorrista que atende
                    let l_sql = l_sql clipped,     #CHAVEIRO - CHAVEIRO TECNICO - CHAVAUTO
                        " and a.asitipcod in (4,9,40)"

                 otherwise
                    let l_sql = l_sql clipped, " and asitipcod in (",d_ctx25g04.asist_nat,")"
             end case

             prepare p_ctx25g04_019 from l_sql
             declare c_ctx25g04_018  cursor for p_ctx25g04_019
             open c_ctx25g04_018
             fetch c_ctx25g04_018  into   l_srrcoddig
             if sqlca.sqlcode = notfound then
                close c_ctx25g04_018
                continue foreach
             end if
             close c_ctx25g04_018
         end if


         if ws.atdsrvorg = 9 or
            ws.atdsrvorg = 13 then


            open c_ctx25g04_008 using  lr_parametro.atdsrvnum
                                    ,lr_parametro.atdsrvano

            fetch c_ctx25g04_008 into l_socntzcod,
                                    l_espcod
            close c_ctx25g04_008

            if l_socntzcod is not null and
               am_ctx25g04b[arr_aux].srrcoddig is not null then
               let l_sql= "select socntzcod     "
                        ," from dbsrntzpstesp  "
                        ," where srrcoddig = ", am_ctx25g04b[arr_aux].srrcoddig
                        ,"   and socntzcod = ", d_ctx25g04.asist_nat




               prepare p_ctx25g04_020 from l_sql
               declare c_ctx25g04_019 cursor for p_ctx25g04_020
               open c_ctx25g04_019
               fetch c_ctx25g04_019 into l_socntzcod

               if sqlca.sqlcode = notfound then
                  close c_ctx25g04_019
                  continue foreach
               end if

               close c_ctx25g04_019

            end if

         end if
      end if


      #------------------------------------------------------------------
      # Busca assistencias do socorrista
      #------------------------------------------------------------------
      let am_ctx25g04b[arr_aux].srrasides = null

      # --SE ORIGEM = 9(RE) BUSCA OS DADOS DA TABELA dbsrntzpstesp
      if ws.atdsrvorg = 9 or
         ws.atdsrvorg = 13 then # PSI 235849 Adriano Santos 28/01/2009
         #busca naturezas do prestador
         let am_ctx25g04b[arr_aux].srrasides = cts00m03_busca_natureza(am_ctx25g04b[arr_aux].srrcoddig)
      else
         #PSI 224782
         #busca assistencias do prestador
         let am_ctx25g04b[arr_aux].srrasides = cts00m03_busca_assistencia(am_ctx25g04b[arr_aux].srrcoddig, am_ctx25g04b[arr_aux].socvclcod)
      end if

      #---------------------------------------------------------------
      # Busca descricao do veiculo
      #---------------------------------------------------------------
      initialize am_ctx25g04b[arr_aux].socvcltipdes  to null

      open  c_ctx25g04_006 using am_ctx25g04b[arr_aux].socvclcod
      fetch c_ctx25g04_006 into l_socvcltip
      close c_ctx25g04_006

      open cctx25g04025 using l_socvcltip
      fetch cctx25g04025 into am_ctx25g04b[arr_aux].socvcltipdes

      #---------------------------------------------------------------
      # Busca equipamentos do veiculo
      #---------------------------------------------------------------
      initialize  am_ctx25g04b[arr_aux].vcleqpdes  to null

      open    c_ctx25g04_007  using  am_ctx25g04b[arr_aux].socvclcod
      foreach c_ctx25g04_007  into   ws.soceqpabv
         let am_ctx25g04b[arr_aux].vcleqpdes =
             am_ctx25g04b[arr_aux].vcleqpdes clipped, ws.soceqpabv clipped, "/"
      end foreach
      close c_ctx25g04_007

      #---------------------------------------------------------------
      # Calcula distancia entre local do servico e local do veiculo
      #---------------------------------------------------------------
      initialize am_ctx25g04b[arr_aux].dstqtd  to null
      if lr_parametro.tipo_demanda is null then
         let am_ctx25g04b[arr_aux].dstqtd = cts18g00(ws.lclltt_srv, ws.lcllgt_srv,
                                                     am_ctx25g04b[arr_aux].lclltt,
                                                     am_ctx25g04b[arr_aux].lcllgt)
      end if

      #-----------------------------------------------------------------------
      # Despresa veiculos com distancia superior a distancia maxima permitida
      #-----------------------------------------------------------------------
      if am_ctx25g04b[arr_aux].dstqtd > l_dist_max then
         initialize am_ctx25g04b[arr_aux] to null
         continue foreach
      end if

      #---------------------------------------------------------------
      # Calcula tempo de espera do ultimo sinal GPS recebido
      #---------------------------------------------------------------

      initialize am_ctx25g04b[arr_aux].espera  to null

      let  am_ctx25g04b[arr_aux].espera = ctx25g04_espera(ws.atldat, ws.atlhor)

      let arr_aux = arr_aux + 1
      if arr_aux > 2000  then
         error " Limite excedido, pesquisa com mais de 2000 veiculos!"
         exit foreach
      end if

   end foreach

   set lock mode to wait

   let ws.total = "Total: ", arr_aux - 1  using "&&&"
   display by name ws.total  attribute(reverse)

   if arr_aux =  1   then
      error " Nao existem veiculos com essa atividade na cidade do Servico !"
   else
      #---------------------------------------------------------------
      # Classifica o array por ordem crescente de distancia
      #---------------------------------------------------------------
      if lr_parametro.tipo_demanda is null then
         for arr_aux2 = 1 to arr_aux - 1
            for arr_aux1 = 1 to arr_aux - 1
               if am_ctx25g04b[arr_aux1].dstqtd  is not null   then
                  if am_ctx25g04b[arr_aux1].dstqtd < am_ctx25g04[arr_aux2].dstqtd  or
                     am_ctx25g04[arr_aux2].dstqtd  is null                        then
                     let am_ctx25g04[arr_aux2].*  =  am_ctx25g04b[arr_aux1].*
                     let arr_aux3  =  arr_aux1
                  end if
               end if
            end for
            initialize am_ctx25g04b[arr_aux3]  to null
         end for
      else
         for arr_aux2 = 1 to arr_aux - 1
             let am_ctx25g04[arr_aux2].* = am_ctx25g04b[arr_aux2].*
         end for
      end if

      message "F2-Srv F5-Cnd.Veic F6-Recusa F7-Percurso F8-Sel F9-Msg MDT F10 +Inf"

      if lr_parametro.tipo_demanda is null then
         let arr_aux4 = 1
         # 1 Laco , so menores que 20 Minutos
         for arr_aux2 = 1 to arr_aux - 1
            if am_ctx25g04[arr_aux2].espera <= ws.tempodif then
               let am_ctx25g04c[arr_aux4].* = am_ctx25g04[arr_aux2].*
               let arr_aux4 = arr_aux4 + 1
            end if
         end for
         # 2 Laco , so maiores que 20 Minutos
         for arr_aux2 = 1 to arr_aux - 1
            if am_ctx25g04[arr_aux2].espera > ws.tempodif then
               let am_ctx25g04c[arr_aux4].* = am_ctx25g04[arr_aux2].*
               let arr_aux4 = arr_aux4 + 1
            end if
         end for
         let l_qtde_rotas = ctx25g05_qtde_rotas()
      else
         for arr_aux2 = 1 to arr_aux - 1
             let am_ctx25g04c[arr_aux2].* = am_ctx25g04[arr_aux2].*
         end for
           #CT7061486 - Roberto
           if (arr_aux - 1) > 300 then
               let l_qtde_rotas = 300
           else
               let l_qtde_rotas = arr_aux - 1
           end if
      end if

      message " "
      message " Roterizando os veiculos..." attribute(reverse)


      # -> ROTERIZA OS VEICULOS ENCONTRADOS
      call ctx25g04_rot_veiculo(ws.lclltt_srv,
                                ws.lcllgt_srv,
                                l_qtde_rotas)

      message "F2-Srv F5-Cnd.Veic F6-Recusa F7-Percurso F8-Sel F9-Msg MDT F10 +Inf"

      call ctx25g04_ordena_array(l_qtde_rotas)

      call set_count(l_qtde_rotas)

      display array  am_ctx25g04c to s_ctx25g04.*
         on key (interrupt)
            initialize am_ctx25g04   to null
            initialize am_ctx25g04b  to null
            initialize am_ctx25g04c  to null
            exit display

          #---------------------------------------------------------#
          # Consulta e exibe as Naturezas atendidas pelos prestadores
          #---------------------------------------------------------#
          on key (f2)
             let l_posicao = arr_curr()
             call cts00m03_exibe_natz_atend(am_ctx25g04c[l_posicao].srrcoddig,am_ctx25g04c[l_posicao].socvclcod)

         ## Implementar Consulta de Locais e Condicoes do Veiculo
         on key (f5)
            let arr_aux = arr_curr()
            call ctc61m02(lr_parametro.atdsrvnum,lr_parametro.atdsrvano,"A")
            let l_tmp_flg = ctc61m02_criatmp(2,
                                             lr_parametro.atdsrvnum,
                                             lr_parametro.atdsrvano)
            if l_tmp_flg = 1 then
               error "Problemas com temporaria ! <Avise a Informatica>."
            end if

         on key (F6)
            #continue while
            let arr_aux = arr_curr()
            call cta11m00 ( ws.atdsrvorg
                           ,lr_parametro.atdsrvnum
                           ,lr_parametro.atdsrvano
                           ,am_ctx25g04c[arr_aux].atdprscod
                           ,"S" )
                 returning l_srvrcumtvcod

         on key(f7)
            let arr_aux = arr_curr()

            # -> BUSCA O TIPO DE ROTA
            let l_tipo_rota = null
            let l_tipo_rota = ctx25g05_tipo_rota()

            call ctx25g02(am_ctx25g04c[arr_aux].lclltt,
                          am_ctx25g04c[arr_aux].lcllgt,
                          ws.lclltt_srv,
                          ws.lcllgt_srv,
                          l_tipo_rota,
                          1) # -> GERA PERCURSO

                 returning l_dist_f7,
                           l_temp_f7,
                           l_rota_f7

            call ctx25g03_percurso(l_rota_f7)

            message "(F2)Serv. (F5)Cond.Veic. (F6)Recusa (F7)Percurso (F8)Selec. (F9)Msg MDT"

         on key (F8)

            let l_posicao = arr_curr()
            if lr_parametro.tipo_demanda is not null or
               am_ctx25g04c[l_posicao].c24atvcod = "QRV" then

            let l_primeiro = false
            let arr_aux    = arr_curr()
            let ws.f8flg   = "S"

            #PSI198714 - Validar se socorrista atende assistencia/natureza do servico
            # apenas quando já tenho servico selecionado - quando não tenho é busca por demanda
            if lr_parametro.atdsrvnum is not null and
               lr_parametro.atdsrvano is not null then
               if ws.atdsrvorg = 9 or
                  ws.atdsrvorg = 13 then # PSI 235849 Adriano Santos 28/01/2009
               #Se origem servico = 9 ou 13 validar se socorrista atende natureza do servico
               #buscar natureza e especialidade do servico re
                   open c_ctx25g04_008 using  lr_parametro.atdsrvnum
                                           ,lr_parametro.atdsrvano
                   fetch c_ctx25g04_008 into l_socntzcod,
                                           l_espcod
                   close c_ctx25g04_008
                   if l_socntzcod is not null then
                      let l_sql= "select socntzcod     "
                               ," from dbsrntzpstesp  "
                               ," where srrcoddig = ", am_ctx25g04c[arr_aux].srrcoddig
                               ,"   and socntzcod = ", l_socntzcod
                      if l_espcod is not null then
                         #servico tem especialidade verificar se socorrista atende natureza e especialidade
                         let l_sql = l_sql clipped, " and espcod = ", l_espcod
                      end if
                      prepare p_ctx25g04_021 from l_sql
                      declare c_ctx25g04_020  cursor for p_ctx25g04_021
                      open c_ctx25g04_020
                      fetch c_ctx25g04_020 into l_socntzcod
                      if sqlca.sqlcode = notfound then
                           call cts08g01("A", "N", "",
                                         "SOCORRISTA NAO ATENDE NATUREZA / ",
                                         "ESPECIALIDADE DO SERVICO", "")
                           returning ws.confirma
                           let ws.f8flg = "N"
                      else
                           #socorrista atende natureza/especialidade do servico RE
                           let ws.f8flg = "S"
                      end if
                   else
                      let ws.f8flg = "S"
                   end if
               end if
               if ws.atdsrvorg = 1 or
                  ws.atdsrvorg = 2 or
                  ws.atdsrvorg = 3 or
                  ws.atdsrvorg = 4 or
                  ws.atdsrvorg = 5 or
                  ws.atdsrvorg = 6 or
                  ws.atdsrvorg = 7 or
                  ws.atdsrvorg = 17 then
                   #Qualquer outra origem de servico validar se socorrista atende tipo assistencia
                   let l_sql = "select srrcoddig  ",
                               "   from datrsrrasi a",
                               "  where a.srrcoddig = ",am_ctx25g04c[arr_aux].srrcoddig
                   case d_ctx25g04.asitipcod             #quando tipo de assistencia do servico e:
                       when 1                            #GUINCHO podemos enviar socorrista que atende
                          let l_sql = l_sql clipped,     #GUINCHO e GUINCHO/TECNICO
                              " and a.asitipcod in (1, 3)"
                       when 2                            #TECNICO podemos enviar socorrista que atende
                          let l_sql = l_sql clipped,     #TECNICO - GUINCHO/TECNICO - CHAVEIRO/TECNICO
                              " and a.asitipcod in (2,3,9)"
                       when 3                            #GUI/TEC podemos enviar socorrista que atende
                          let l_sql = l_sql clipped,     #GUI/TEC ou GUINCHO e TECNICO juntos
                              " and (a.asitipcod = 3 or "
                             ,"      (a.asitipcod = 1 and    "
                             ,"        exists (select b.asitipcod               "
                             ,"                 from datrsrrasi b               "
                             ,"                 where b.srrcoddig = a.srrcoddig "
                             ,"                 and b.asitipcod = 2) ) )        "
                       when 4                            #CHAVEIRO podemos enviar socorrista que atende
                          let l_sql = l_sql clipped,     #CHAVEIRO E CHAVEIRO TECNICO
                              " and a.asitipcod in (4,9,40)"
                       when 9                            #CHAVEIRO TECNICO podemos enviar socorrista que atende
                          let l_sql = l_sql clipped,     #CHAVEIRO TECNICO OU TECNICO e Chaveiro ou Chavauto juntos
                              " and (a.asitipcod = 9 or   "
                             ,"      (a.asitipcod = 2 and "
                             ,"        exists (select b.asitipcod                "
                             ,"                  from datrsrrasi b               "
                             ,"                  where b.srrcoddig = a.srrcoddig "
                             ,"                  and (b.asitipcod = 4 or         "
                             ,"                        b.asitipcod = 40) ) ) )   "
                       when 40                           #CHAVAUTO podemos enviar socorrista que atende
                          let l_sql = l_sql clipped,     #CHAVEIRO - CHAVEIRO TECNICO - CHAVAUTO
                              " and a.asitipcod in (4,9,40)"

                       otherwise
                          let l_sql = l_sql clipped, " and asitipcod in (",d_ctx25g04.asitipcod,")"
                   end case
                   #OBS.: Hoje estamos fazendo essas conversoes de tipo de assitencia do
                   # socorrista porque o cadastro deles não está integro.
                   # Os códigos 3, 9 e 40 nao deveriam mais existir
                   # exemplo: os socorristas que atendem assistencia 3 deveriam atender
                   # assistencia 1 e 2.
                   #Quando o cadastro de assistencia dos socorristas estiver correto,
                   # podemos retirar essas conversoes

                   prepare p_ctx25g04_022 from l_sql
                   declare c_ctx25g04_021  cursor for p_ctx25g04_022
                   open c_ctx25g04_021
                   fetch c_ctx25g04_021  into   l_srrcoddig
                   if sqlca.sqlcode = notfound then
                      call cts08g01("A", "N", "", "SOCORRISTA NAO ATENDE TIPO ",
                                       "DE ASSISTENCIA DO SERVICO", "")
                           returning ws.confirma
                      let ws.f8flg = "N"
                   else
                      #socorrista atende assistencia
                      let ws.f8flg = "S"
                   end if
                   close c_ctx25g04_021
               end if
            end if

            if  ws.f8flg = "S" and
                lr_parametro.atdsrvnum is not null and
                lr_parametro.atdsrvano is not null then

                call cts00m20_verif_auto( lr_parametro.atdsrvnum,
                     lr_parametro.atdsrvano, d_ctx25g04.ciaempcod,
                     d_ctx25g04.asitipcod  , am_ctx25g04c[arr_aux].socvclcod,
                     am_ctx25g04c[arr_aux].dist_rot, am_ctx25g04c[arr_aux].srrcoddig)
                returning l_retorno

                if l_retorno = 0 then
                    let ws.f8flg = "N"
                end if
            end if

            if ws.f8flg = "S" then
               let ws.f8flg = "N"
               if arr_aux =  1  then
                  let ws.f8flg  = "S"
                  let l_primeiro = true
                  exit display
               else
                  if lr_parametro.tipo_demanda is null then
                     call cts08g01("A","S","VIATURA  SELECIONADA  NAO E' A MAIS",
                                           "PROXIMA DISPONIVEL PARA ATENDIMENTO",
                                           "AO SEGURADO !",
                                           "CONFIRMA A ESCOLHA ?")
                         returning ws.confirma

                  else
                     let ws.confirma = "S"
                  end if

                  if ws.confirma = "S"   then
                     let ws.f8flg = "S"
                     exit display
                  end if
               end if
            end if

            end if ## QRV

         #---------------------------------------------------------------
         # Consulta mensagens recebidas dos MDTs
         #---------------------------------------------------------------
         on key (F9)
            let arr_aux = arr_curr()
            call ctn44c00(2, am_ctx25g04c[arr_aux].atdvclsgl, 1)

         on key (F10)
            let arr_aux = arr_curr()
            call cts00m32(am_ctx25g04c[arr_aux].socvclcod)

      end display
   end if

    #--------------------------------------------------------------
    # Limpa tela (array)
    #--------------------------------------------------------------
    if ws.f8flg = "S" then
        if lr_parametro.tipo_demanda is not null then

             open c_ctx25g04_012 using am_ctx25g04c[arr_aux].socvclcod
             fetch c_ctx25g04_012 into ws.c24atvcod, ws.atdsrvnum, ws.atdsrvano

            if sqlca.sqlcode = notfound then
                error "Posicao da Frota nao encontrada !!!"
                initialize ws.*         to null
                initialize am_ctx25g04   to null
                initialize am_ctx25g04b  to null
                initialize am_ctx25g04c  to null
                let arr_aux = 1
                let ws.f8flg = "N"
            else
                if ws.c24atvcod <> "QRV" and
                   ws.atdsrvnum is not null and
                   ws.atdsrvano is not null then
                   error "Viatura ja acionada para o servico: ",
                         ws.atdsrvnum using "&&&&&&&", "-",
                         ws.atdsrvano using "&&"

                   let g_documento.atdprscod = am_ctx25g04c[arr_aux].atdprscod
                   let g_documento.atdvclsgl = am_ctx25g04c[arr_aux].atdvclsgl
                   let g_documento.srrcoddig = am_ctx25g04c[arr_aux].srrcoddig
                   let g_documento.socvclcod = am_ctx25g04c[arr_aux].socvclcod
                   let g_documento.lclltt    = am_ctx25g04c[arr_aux].lclltt
                   let g_documento.lcllgt    = am_ctx25g04c[arr_aux].lcllgt

                   call cts00m00(ws.atdsrvorg
                                ,''
                                ,lr_parametro.tipo_demanda
                                ,g_documento.lclltt
                                ,g_documento.lcllgt
                                ,am_ctx25g04c[arr_aux].cidnom_gps
                                ,d_ctx25g04.vcldtbgrpcod
                                ,am_ctx25g04c[arr_aux].srrcoddig
                                ,am_ctx25g04c[arr_aux].socvclcod)

                   initialize ws.*         to null
                   initialize am_ctx25g04   to null
                   initialize am_ctx25g04b  to null
                   initialize am_ctx25g04c  to null
                   let arr_aux = 1
                   let ws.f8flg = "N"
                end if
            end if
            close c_ctx25g04_012
        end if
    end if

    if ws.f8flg  =  "S"   then

    #psi 189790
    ## obter servico multiplo
       call cts29g00_obter_multiplo(2, lr_parametro.atdsrvnum, lr_parametro.atdsrvano)
       returning l_resultado
                ,l_mensagem
                ,al_saida[1].*
                ,al_saida[2].*
                ,al_saida[3].*
                ,al_saida[4].*
                ,al_saida[5].*
                ,al_saida[6].*
                ,al_saida[7].*
                ,al_saida[8].*
                ,al_saida[9].*
                ,al_saida[10].*

       if l_resultado = 3 then
           error l_mensagem sleep 2
           continue while
       end if

        whenever error continue
        set lock mode to not wait

        begin work
            update datkveiculo
               set socacsflg = "1",
                   c24opemat = g_issk.funmat,
                   c24opeempcod = g_issk.empcod,
                   c24opeusrtip = g_issk.usrtip
             where socvclcod = am_ctx25g04c[arr_aux].socvclcod
               and socacsflg = "0"

            if sqlca.sqlcode <> 0  then
                if sqlca.sqlcode = -243 or
                   sqlca.sqlcode = -245 or
                   sqlca.sqlcode = -246 then
                   error " Veiculo em acionamento(1) !"
                else
                   error " Erro (", sqlca.sqlcode, ")",
                         " na atz. do veiculo(1). AVISE A INFORMATICA!"
                end if
                rollback work

                prompt "" for char prompt_key
                initialize ws.*         to null
                initialize am_ctx25g04   to null
                initialize am_ctx25g04b  to null
                initialize am_ctx25g04c  to null
                continue while
            else
                if sqlca.sqlerrd[3] = 0 then
                   rollback work

                   open c_ctx25g04_002 using am_ctx25g04c[arr_aux].socvclcod
                   whenever error continue
                   fetch c_ctx25g04_002 into l_c24opemat, l_c24opeempcod, l_c24opeusrtip
                   whenever error stop

                   if sqlca.sqlcode <> 0 then
                      if sqlca.sqlcode <> 100 then
                         error 'Problemas de acesso a tabela DATKVEICULO, ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                         error 'ctx25g04()' sleep 2
                         error am_ctx25g04c[arr_aux].socvclcod sleep 2
                      else
                         error "Dados nao encontrados selecionando DATKVEICULO"
                      end if
                      initialize l_c24opemat to null
                   end if

                   close c_ctx25g04_002

                   if l_c24opemat is not null then
                      open c_ctx25g04_003 using l_c24opemat
                                             ,l_c24opeempcod
                                             ,l_c24opeusrtip
                      whenever error continue
                      fetch c_ctx25g04_003 into l_funnom
                      whenever error stop
                      let l_funnom = upshift(l_funnom)
                      if sqlca.sqlcode <> 0 then
                         if sqlca.sqlcode <> 100 then
                            error 'Problemas de acesso a tabela ISSKFUNC, ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                            error 'ctx25g04()' sleep 2
                            error l_c24opemat," - "
                                 ,l_c24opeempcod," - "
                                 ,l_c24opeusrtip," - " sleep 2
                         else
                            error "Dados nao encontrados selecionando ISSKFUNC"
                         end if
                      else
                         error "Veiculo sendo acionado por ",l_funnom clipped
                      end if

                      close c_ctx25g04_003

                   end if

                   initialize ws.*         to null
                   initialize am_ctx25g04   to null
                   initialize am_ctx25g04b  to null
                   initialize am_ctx25g04c  to null
                   continue while
                end if
            end if

            #-----------------------------------------------------------------
            # Calcula previsao no acionamento
            #-----------------------------------------------------------------

            if lr_parametro.tipo_demanda is null then
                ##call cts21g00_calc_prev(am_ctx25g04c[arr_aux].dstqtd,ws.atdhorpvt)
                ##returning ws.prvcalc

               # -> RECEBE OS VALORES ROTERIZADOS
               let ws.prvcalc                   = am_ctx25g04c[arr_aux].temp_rot
               let am_ctx25g04c[arr_aux].dstqtd = am_ctx25g04c[arr_aux].dist_rot

               call cts10g09_registrar_prestador(2
                                                ,lr_parametro.atdsrvnum
                                                ,lr_parametro.atdsrvano
                                                ,am_ctx25g04c[arr_aux].socvclcod
                                                ,am_ctx25g04c[arr_aux].srrcoddig
                                                ,am_ctx25g04c[arr_aux].lclltt
                                                ,am_ctx25g04c[arr_aux].lcllgt
                                                ,ws.prvcalc)
                  returning l_resultado
                           ,l_mensagem

               if l_resultado <> 1  then
                   error l_mensagem sleep 2
                   rollback work
                   prompt "" for char prompt_key
                   exit while
               end if

               ## atualizar servico multiplo
               for l_i = 1 to 10
                  if al_saida[l_i].atdmltsrvnum is not null then
                     call cts10g09_registrar_prestador(2
                                                      ,al_saida[l_i].atdmltsrvnum
                                                      ,al_saida[l_i].atdmltsrvano
                                                      ,am_ctx25g04c[arr_aux].socvclcod
                                                      ,am_ctx25g04c[arr_aux].srrcoddig
                                                      ,am_ctx25g04c[arr_aux].lclltt
                                                      ,am_ctx25g04c[arr_aux].lcllgt
                                                      ,ws.prvcalc)
                     returning l_resultado
                              ,l_mensagem

                     if l_resultado <> 1  then
                         error l_mensagem sleep 2
                         rollback work
                         prompt "" for char prompt_key
                         exit while
                     end if
                  end if
               end for

            end if

        commit work
        set lock mode to wait
        whenever error stop
        let ws.flag_cts00m02 = 1

        if lr_parametro.tipo_demanda is not null then

            let g_documento.atdprscod = am_ctx25g04c[arr_aux].atdprscod
            let g_documento.atdvclsgl = am_ctx25g04c[arr_aux].atdvclsgl
            let g_documento.srrcoddig = am_ctx25g04c[arr_aux].srrcoddig
            let g_documento.socvclcod = am_ctx25g04c[arr_aux].socvclcod
            let g_documento.lclltt    = am_ctx25g04c[arr_aux].lclltt
            let g_documento.lcllgt    = am_ctx25g04c[arr_aux].lcllgt

            call cts00m00(ws.atdsrvorg
                         ,''
                         ,lr_parametro.tipo_demanda
                         ,g_documento.lclltt
                         ,g_documento.lcllgt
                         ,am_ctx25g04c[arr_aux].cidnom_gps
                         ,d_ctx25g04.vcldtbgrpcod
                         ,am_ctx25g04c[arr_aux].srrcoddig
                         ,am_ctx25g04c[arr_aux].socvclcod)

            open c_ctx25g04_004 using g_documento.socvclcod

            whenever error continue
            fetch c_ctx25g04_004 into lr_frota.*
            whenever error stop

            if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> 100 then
                    error 'Problemas de acesso a tabela DATTFROTALOCAL, ',
                           sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                    error 'ctx25g04()', g_documento.socvclcod sleep 2
                    exit while
                end if
            else
                if lr_frota.atdsrvnum is null then

                    let l_socacsflg = '0'
                    let l_c24opemat = null
                    let l_c24opeempcod = null
                    let l_c24opeusrtip = null
                    execute p_ctx25g04_004 using l_socacsflg
                                              ,l_c24opemat
                                              ,l_c24opeempcod
                                              ,l_c24opeusrtip
                                              ,g_documento.socvclcod
                    whenever error stop
                    if sqlca.sqlcode <> 0  then
                       if sqlca.sqlcode = -243 or
                          sqlca.sqlcode = -245 or
                          sqlca.sqlcode = -246 then
                          error " Veiculo em acionamento(2) !"
                       else
                          error " Erro (", sqlca.sqlcode, ")",
                                " na atz. do veiculo(3). AVISE A INFORMATICA!"
                       end if
                       rollback work
                       prompt "" for char prompt_key
                    end if
                end if
            end if
            close c_ctx25g04_004
            continue while

        else

            if l_primeiro then
                exit while
            end if

            while true
                call ctx14g00("Justifique sua escolha",
                              "Tecnico nao habilitado|Veiculo inadequado|Rodizio Municipal|Ver motivo no historico")
                returning ws.opcao,
                          ws.opcaodes
                if ws.opcao <> 0 then
                    exit while
                end if
            end while

            # Define o nome do arquivo temporario
            let ws.nometxt = "~/ACN", lr_parametro.atdsrvnum using "&&&&&&&" , ".txt"

            # Inclui indicacao no arquivo temporario
            let ws.linha   = "Espelho do acionamento"
            let ws.executa = 'echo "', ws.linha clipped, '" > ', ws.nometxt
            run ws.executa

            # Carrega no arquivo temporario os dados das viaturas ate a selecionada
            for ws_cont = 1 to arr_aux

                let ws.linha   = "Veiculo:",am_ctx25g04c[ws_cont].atdvclsgl
                                ," ",am_ctx25g04c[ws_cont].c24atvcod
                                ," ",am_ctx25g04c[ws_cont].socvclcod
                                ," ",am_ctx25g04c[ws_cont].socvcltipdes
                                ," ",am_ctx25g04c[ws_cont].vcleqpdes
                let ws.executa = 'echo "', ws.linha clipped, '" >> ', ws.nometxt
                run ws.executa

                let ws.linha   = "Socorr.: ",am_ctx25g04c[ws_cont].srrcoddig
                                ," ",am_ctx25g04c[ws_cont].srrabvnom
                                ," ",am_ctx25g04c[ws_cont].srrasides
                let ws.executa = 'echo "', ws.linha clipped, '" >> ', ws.nometxt
                run ws.executa

                let ws.linha   = "G.P.S .: ",am_ctx25g04c[ws_cont].ufdcod_gps
                                ," ",am_ctx25g04c[ws_cont].cidnom_gps
                                ," ",am_ctx25g04c[ws_cont].brrnom_gps
                                ," ",am_ctx25g04c[ws_cont].endzon_gps
                let ws.executa = 'echo "', ws.linha clipped, '" >> ', ws.nometxt
                run ws.executa

                let ws.linha   = "OBS ...: ",am_ctx25g04c[ws_cont].obspostxt
                                ,"  Sinal.: ",am_ctx25g04c[ws_cont].espera
                                ,"  Dist: ",am_ctx25g04c[ws_cont].dstqtd," Km"
                let ws.executa = 'echo "', ws.linha clipped, '" >> ', ws.nometxt
                run ws.executa

                let ws.linha   = ""
                let ws.executa = 'echo "', ws.linha clipped, '" >> ', ws.nometxt
                run ws.executa

            end for

            # Monta cabecalho do e-mail
            let ws.linha = "Justificativa acionamento SRV: "
                          , lr_parametro.atdsrvnum using "&&&&&&&"
                          , "-", lr_parametro.atdsrvano using "&&"

            ## Concatenar servico multiplo no cabecalho do e-mail
            let l_i = 1

            for l_i = 1 to 10
               if al_saida[l_i].atdmltsrvnum is not null then
                  let ws.linha = ws.linha clipped
                                   ,"  "
                                   ,al_saida[l_i].atdmltsrvnum using "&&&&&&&"
                                   ,"-"
                                   ,al_saida[l_i].atdmltsrvano using "&&"
               end if
            end for

            let ws.linha = ws.linha clipped, " ", ws.opcaodes

            # Envia e-mail
            let l_retorno = ctx22g00_envia_email("ctx25g04",
                                                 ws.linha,
                                                 ws.nometxt)
            if l_retorno <> 0 then
                if l_retorno <> 99 then
                    display "Erro ao envia email(ctx21g00)-",ws.nometxt
                else
                    display "Nao ha email cadastrado para o modulo ctx25g04 "
                end if
            end if

            # Grava justificativa no historico do servico
            call cts10g02_historico(lr_parametro.atdsrvnum,
                                    lr_parametro.atdsrvano,
                                    current,
                                    current,
                                    g_issk.funmat,
                                    "Justificativa acionamento nao padrao",
                                    ws.opcaodes,
                                    "","","")
            returning l_retorno


            ## Grava justificativa no historico dos servicos multiplos
            let l_i = 1
            for l_i = 1 to 10
               if al_saida[l_i].atdmltsrvnum is not null then
                  call cts10g02_historico(al_saida[l_i].atdmltsrvnum
                                         ,al_saida[l_i].atdmltsrvano
                                         ,current
                                         ,current
                                         ,g_issk.funmat
                                         ,"Justificativa acionamento nao padrao"
                                         ,ws.opcaodes
                                         ,""
                                         ,""
                                         ,"")
                  returning l_retorno
               end if
            end for

            # Remove arquivo temporario
            let ws.executa = "rm ", ws.nometxt
            run ws.executa

        end if
        #fim psi179345

        exit while

  else
      for arr_aux = 1 to 2
         clear s_ctx25g04[arr_aux].*
      end for
   end if
 end while

 close window  w_ctx25g04
 let int_flag = false

 return am_ctx25g04c[arr_aux].atdprscod,
        am_ctx25g04c[arr_aux].atdvclsgl,
        am_ctx25g04c[arr_aux].srrcoddig,
        am_ctx25g04c[arr_aux].socvclcod,
        ws.prvcalc,
        am_ctx25g04c[arr_aux].dstqtd,
        ws.flag_cts00m02

end function

#------------------------------------#
function ctx25g04_espera(lr_parametro)
#------------------------------------#

  define lr_parametro record
         data         date,
         hora         datetime hour to second
  end record

  define hora         record
         atual        datetime hour to second,
         h24          datetime hour to second,
         espera       char (09)
  end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
  initialize  hora.*  to  null
  initialize  hora.*  to  null

  let hora.atual = time

  if lr_parametro.data  =  today  then
     let hora.espera = (hora.atual - lr_parametro.hora)
  else
     let hora.h24    = "23:59:59"
     let hora.espera = (hora.h24 - lr_parametro.hora)
     let hora.h24    = "00:00:00"
     let hora.espera = hora.espera + (hora.atual - hora.h24) + "00:00:01"
  end if

  return hora.espera

end function

#-----------------------------------------#
function ctx25g04_rot_veiculo(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         qtde_rotas   smallint
  end record

  define l_i          smallint,
         l_rota_final char(1),
         l_temp_total decimal(6,1),
         l_tipo_rota  char(07)

  let l_i          = null
  let l_rota_final = null
  let l_temp_total = null

  # -> BUSCA O TIPO DE ROTA
  let l_tipo_rota = null
  let l_tipo_rota = ctx25g05_tipo_rota()

  if lr_parametro.qtde_rotas is null then
     error "Nao encontrou a qtd. de rotas parametrizadas na datkgeral. AVISE A INFORMATICA!" sleep 5
  else
     for l_i = 1 to lr_parametro.qtde_rotas

        let am_ctx25g04c[l_i].dist_rot = null
        let l_temp_total               = null
        let am_ctx25g04c[l_i].temp_rot = null

        call ctx25g02(am_ctx25g04c[l_i].lclltt,
                      am_ctx25g04c[l_i].lcllgt,
                      lr_parametro.lclltt,
                      lr_parametro.lcllgt,
                      l_tipo_rota,
                      0) # -> NAO GERA PERCURSO COMPLETO

             returning am_ctx25g04c[l_i].dist_rot,
                       l_temp_total,
                       l_rota_final

        let l_temp_total               = (l_temp_total * 2)
        let am_ctx25g04c[l_i].temp_rot = "00:03"
        let am_ctx25g04c[l_i].temp_rot = (am_ctx25g04c[l_i].temp_rot + l_temp_total units minute)

        if am_ctx25g04c[l_i].temp_rot > "01:00" then
           let am_ctx25g04c[l_i].temp_rot = "01:00"
        end if

     end for
  end if

end function

#---------------------------------------#
function ctx25g04_ordena_array(l_tamanho)
#---------------------------------------#

  define l_tamanho   integer,
         l_contador1 integer,
         l_contador2 integer

  define lr_aux      record
         atdvclsgl   like datkveiculo.atdvclsgl,
         c24atvcod   like dattfrotalocal.c24atvcod,
         socvclcod   like dattfrotalocal.socvclcod,
         socvcltipdes      char (50),
         vcleqpdes   char (15),
         srrcoddig   like dattfrotalocal.srrcoddig,
         srrabvnom   like datksrr.srrabvnom,
         srrasides   char (50),
         ufdcod_gps  like datmfrtpos.ufdcod,
         cidnom_gps  like datmfrtpos.cidnom,
         brrnom_gps  like datmfrtpos.brrnom,
         endzon_gps  like datmfrtpos.endzon,
         obspostxt   like dattfrotalocal.obspostxt,
         temp_rot    datetime hour to minute,
         dist_rot    decimal(8,3),
         espera      interval hour(2) to second,
         dstqtd      decimal(8,4),
         atdprscod   like datmservico.atdprscod,
         lclltt      like datmfrtpos.lclltt,
         lcllgt      like datmfrtpos.lcllgt
  end record

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_contador1 = null
  let l_contador2 = null

  #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize  lr_aux.*  to  null

   # --ORDENA O ARRAY POR ORDEM CRESCENTE DE DISTANCIA
   for l_contador1 = 1 to l_tamanho
      for l_contador2 = l_contador1 + 1 to l_tamanho
         if am_ctx25g04c[l_contador1].dist_rot > am_ctx25g04c[l_contador2].dist_rot then
            let lr_aux.atdvclsgl                       = am_ctx25g04c[l_contador1].atdvclsgl
            let lr_aux.c24atvcod                       = am_ctx25g04c[l_contador1].c24atvcod
            let lr_aux.socvclcod                       = am_ctx25g04c[l_contador1].socvclcod
            let lr_aux.socvcltipdes                    = am_ctx25g04c[l_contador1].socvcltipdes
            let lr_aux.vcleqpdes                       = am_ctx25g04c[l_contador1].vcleqpdes
            let lr_aux.srrcoddig                       = am_ctx25g04c[l_contador1].srrcoddig
            let lr_aux.srrabvnom                       = am_ctx25g04c[l_contador1].srrabvnom
            let lr_aux.srrasides                       = am_ctx25g04c[l_contador1].srrasides
            let lr_aux.ufdcod_gps                      = am_ctx25g04c[l_contador1].ufdcod_gps
            let lr_aux.cidnom_gps                      = am_ctx25g04c[l_contador1].cidnom_gps
            let lr_aux.brrnom_gps                      = am_ctx25g04c[l_contador1].brrnom_gps
            let lr_aux.endzon_gps                      = am_ctx25g04c[l_contador1].endzon_gps
            let lr_aux.obspostxt                       = am_ctx25g04c[l_contador1].obspostxt
            let lr_aux.temp_rot                        = am_ctx25g04c[l_contador1].temp_rot
            let lr_aux.dist_rot                        = am_ctx25g04c[l_contador1].dist_rot
            let lr_aux.espera                          = am_ctx25g04c[l_contador1].espera
            let lr_aux.dstqtd                          = am_ctx25g04c[l_contador1].dstqtd
            let lr_aux.atdprscod                       = am_ctx25g04c[l_contador1].atdprscod
            let lr_aux.lclltt                          = am_ctx25g04c[l_contador1].lclltt
            let lr_aux.lcllgt                          = am_ctx25g04c[l_contador1].lcllgt

            let am_ctx25g04c[l_contador1].atdvclsgl    = am_ctx25g04c[l_contador2].atdvclsgl
            let am_ctx25g04c[l_contador1].c24atvcod    = am_ctx25g04c[l_contador2].c24atvcod
            let am_ctx25g04c[l_contador1].socvclcod    = am_ctx25g04c[l_contador2].socvclcod
            let am_ctx25g04c[l_contador1].socvcltipdes = am_ctx25g04c[l_contador2].socvcltipdes
            let am_ctx25g04c[l_contador1].vcleqpdes    = am_ctx25g04c[l_contador2].vcleqpdes
            let am_ctx25g04c[l_contador1].srrcoddig    = am_ctx25g04c[l_contador2].srrcoddig
            let am_ctx25g04c[l_contador1].srrabvnom    = am_ctx25g04c[l_contador2].srrabvnom
            let am_ctx25g04c[l_contador1].srrasides    = am_ctx25g04c[l_contador2].srrasides
            let am_ctx25g04c[l_contador1].ufdcod_gps   = am_ctx25g04c[l_contador2].ufdcod_gps
            let am_ctx25g04c[l_contador1].cidnom_gps   = am_ctx25g04c[l_contador2].cidnom_gps
            let am_ctx25g04c[l_contador1].brrnom_gps   = am_ctx25g04c[l_contador2].brrnom_gps
            let am_ctx25g04c[l_contador1].endzon_gps   = am_ctx25g04c[l_contador2].endzon_gps
            let am_ctx25g04c[l_contador1].obspostxt    = am_ctx25g04c[l_contador2].obspostxt
            let am_ctx25g04c[l_contador1].temp_rot     = am_ctx25g04c[l_contador2].temp_rot
            let am_ctx25g04c[l_contador1].dist_rot     = am_ctx25g04c[l_contador2].dist_rot
            let am_ctx25g04c[l_contador1].espera       = am_ctx25g04c[l_contador2].espera
            let am_ctx25g04c[l_contador1].dstqtd       = am_ctx25g04c[l_contador2].dstqtd
            let am_ctx25g04c[l_contador1].atdprscod    = am_ctx25g04c[l_contador2].atdprscod
            let am_ctx25g04c[l_contador1].lclltt       = am_ctx25g04c[l_contador2].lclltt
            let am_ctx25g04c[l_contador1].lcllgt       = am_ctx25g04c[l_contador2].lcllgt

            let am_ctx25g04c[l_contador2].atdvclsgl    = lr_aux.atdvclsgl
            let am_ctx25g04c[l_contador2].c24atvcod    = lr_aux.c24atvcod
            let am_ctx25g04c[l_contador2].socvclcod    = lr_aux.socvclcod
            let am_ctx25g04c[l_contador2].socvcltipdes = lr_aux.socvcltipdes
            let am_ctx25g04c[l_contador2].vcleqpdes    = lr_aux.vcleqpdes
            let am_ctx25g04c[l_contador2].srrcoddig    = lr_aux.srrcoddig
            let am_ctx25g04c[l_contador2].srrabvnom    = lr_aux.srrabvnom
            let am_ctx25g04c[l_contador2].srrasides    = lr_aux.srrasides
            let am_ctx25g04c[l_contador2].ufdcod_gps   = lr_aux.ufdcod_gps
            let am_ctx25g04c[l_contador2].cidnom_gps   = lr_aux.cidnom_gps
            let am_ctx25g04c[l_contador2].brrnom_gps   = lr_aux.brrnom_gps
            let am_ctx25g04c[l_contador2].endzon_gps   = lr_aux.endzon_gps
            let am_ctx25g04c[l_contador2].obspostxt    = lr_aux.obspostxt
            let am_ctx25g04c[l_contador2].temp_rot     = lr_aux.temp_rot
            let am_ctx25g04c[l_contador2].dist_rot     = lr_aux.dist_rot
            let am_ctx25g04c[l_contador2].espera       = lr_aux.espera
            let am_ctx25g04c[l_contador2].dstqtd       = lr_aux.dstqtd
            let am_ctx25g04c[l_contador2].atdprscod    = lr_aux.atdprscod
            let am_ctx25g04c[l_contador2].lclltt       = lr_aux.lclltt
            let am_ctx25g04c[l_contador2].lcllgt       = lr_aux.lcllgt

         end if
      end for
   end for

end function
