#############################################################################
# Nome do Modulo: cts00m20                                         Gilberto #
#                                                                   Marcelo #
# Localiza veiculo mais proximo da ocorrencia                      Out/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 01/02/2000  PSI 10204-0  Wagner       Incluir filtro para tipo de assist. #
#---------------------------------------------------------------------------#
# 08/03/2000  CORREIO      Wagner       Incluir tecla (f9) msg MDT          #
#---------------------------------------------------------------------------#
# 09/03/2000  CORREIO      Gilberto     Incluir tempo de espera desde o ul- #
#                                       timo sinal enviado pelo GPS.        #
#---------------------------------------------------------------------------#
# 10/03/2000  CORREIO      Gilberto     Otimizacao do acesso para o calculo #
#                                       do tempo desde o ultimo sinal GPS.  #
#---------------------------------------------------------------------------#
# 04/07/2000  PSI 110264   Marcus       Calculo do tempo da ultima atualiza #
#                                       cao de movimento enviada pelo MDT   #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 17/08/2000  PSI 11450-2  Wagner       Inclusao da janela de questionamento#
#                                       em virtude do prestador escolhido.  #
#---------------------------------------------------------------------------#
# 30/08/2000  PSI 11459-6  Ruiz         Conclusao de Servico pelo Atendente #
#---------------------------------------------------------------------------#
# 27/10/2000  PSI 11816-8 Marcus        Filtro viaturas + 20 min sem sinal  #
#---------------------------------------------------------------------------#
# 01/12/2000  PSI 12024-3  Marcus       Acionamento parametrizado para      #
#                                       trabalhar com os Grupos de Aciona-  #
#                                       mento .                             #
#---------------------------------------------------------------------------#
# 17/04/2001  PSI 12955-0  Marcus       Inclusao da funcao de calculo de pre#
#                                       visao automatica para Socorrista    #
#---------------------------------------------------------------------------#
# 08/05/2001  PSI 13241-1  Marcus       Campo Previsao e Distancia          #
#---------------------------------------------------------------------------#
# 28/05/2002  PSI 15456-3  Wagner       Limitar pesquisa para viaturas RE.  #
#---------------------------------------------------------------------------#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica   PSI/OSF Alteracao                              #
# ---------- --------------- ------- ---------------------------------------#
# 17/11/2003 Meta, Jefferson 179345  Localizar as viaturas de acordo com    #
#                            28851   a demanda acionada                     #
#---------------------------------------------------------------------------#
#---------------------------------------------------------------------------#
#                       * * * A L T E R A C A O * * *                       #
# ......................................................................... #
# Data        Autor Fabrica   OSF/PSI     Alteracao                         #
# ---------- -------------  ------------- ----------------------------------#
# 27/01/2004 Sonia Sasaki   31631/177903  Inclusao F6 e execucao da funcao  #
#                                         cta11m00 (Motivos de recusa).     #
#                                                                           #
#                                                                           #
#                                                                           #
#---------------------------------------------------------------------------#
# 30/03/2004 Teresinha S.   33952/184250  Desprezar o grupo 5               #
# --------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                          #
#                                                                           #
# Data       Autor Fabrica   Origem     Alteracao                           #
# ---------- --------------  ---------- ------------------------------------#
# 21/10/2004 Lucas, Meta     PSI188590  Justificar o acionamento nao padrao #
#                                       dos servicos.                       #
#---------------------------------------------------------------------------#
# 08/11/2004 Katiucia        CT 257958  Mudar lugar onde e' enviado email   #
#---------------------------------------------------------------------------#
# 08/04/2005 Pietro - Meta   PSI189790  obter servico multiplo, atualizar   #
#                                       o prestador no servico, concatenar  #
#                                       servico multiplo no cabecalho do    #
#                                       e-mail, gravar justificativa no     #
#                                       no historico de servicos multiplos  #
#---------------------------------------------------------------------------#
# 24/08/2005 James, Meta     PSI 192015 Chamar funcao para Locais Condicoes #
#                                       do veiculo (ctc61m02)               #
#---------------------------------------------------------------------------#
# 28/04/2006 Priscila        PSI 198714 Validar se prestador escolhido      #
#                                       atende natureza ou assistencia do   #
#                                       servico                             #
#---------------------------------------------------------------------------#
# 28/11/2006 Priscila        PSI 205206 Incluir campo empresa no filtro     #
# 12/11/2007 Ligia Mattge    Input da atividade                             #
#---------------------------------------------------------------------------#
# 06/06/2008 Norton,Meta     PSI 223700 inclusao funcao cts00m20_verif_auto #
# 28/01/2009 Adriano Santos  PSI 235849 Considerar tipo de serviço SINISTRO RE#
# 02/03/2010 Adriano Santos  PSI 252891 Inclusao do padrao idx 4 e 5        #
#---------------------------------------------------------------------------#



globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepara_sql   smallint

#---------------------------#
function cts00m20_prepara()
#---------------------------#

   define l_sql  char(500)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

   let l_sql = " select grlinf, grlchv "
              ,"   from igbkgeral "
              ,"  where mducod = 'C24' "
              ,"    and grlchv matches 'RADIO-DEM*' "
              ,"    and grlinf = '1'"

   prepare p_cts00m20_001 from l_sql
   declare c_cts00m20_001 cursor for p_cts00m20_001

   let l_sql = " select c24opemat, c24opeempcod, c24opeusrtip "
              ,"   from datkveiculo "
              ,"  where socvclcod = ? "

   prepare p_cts00m20_002 from l_sql
   declare c_cts00m20_002 cursor for p_cts00m20_002

   let l_sql = " select funnom "
              ,"   from isskfunc "
              ,"  where funmat = ? "
              ,"    and empcod = ? "
              ,"    and usrtip = ? "

   prepare p_cts00m20_003 from l_sql
   declare c_cts00m20_003 cursor for p_cts00m20_003

   let l_sql = " update datkveiculo "
              ,"    set socacsflg = ? "
              ,"       ,c24opemat = ? "
              ,"       ,c24opeempcod = ? "
              ,"       ,c24opeusrtip = ? "
              ,"  where socvclcod = ? "

   prepare p_cts00m20_004 from l_sql

   let l_sql = " select atdsrvnum, atdsrvano "
              ,"   from dattfrotalocal "
              ,"  where socvclcod = ? "

   prepare p_cts00m20_005 from l_sql
   declare c_cts00m20_004 cursor for p_cts00m20_005

   let l_sql = " select vcldtbgrpdes ",
               "   from datkvcldtbgrp ",
               "  where vcldtbgrpcod = ? "

   prepare p_cts00m20_006 from l_sql
   declare c_cts00m20_005 cursor for p_cts00m20_006

 let l_sql = "select socvcltip ",
              " from datkveiculo ",
             " where socvclcod = ? "
 prepare p_cts00m20_007  from l_sql
 declare c_cts00m20_006   cursor for p_cts00m20_007

 let l_sql = " select soceqpabv ",
                  "   from datreqpvcl, outer datkvcleqp",
                  "  where datreqpvcl.socvclcod = ? ",
                  "    and datkvcleqp.soceqpcod = datreqpvcl.soceqpcod "
 prepare p_cts00m20_008    from l_sql
 declare c_cts00m20_007  cursor for p_cts00m20_008

 let l_sql = " select srrcoddig  ",
                  "   from datrsrrasi ",
                  "  where datrsrrasi.srrcoddig = ? ",
                  "    and datrsrrasi.asitipcod in ( ? )"
 prepare p_cts00m20_009    from l_sql
 declare c_cts00m20_008  cursor for p_cts00m20_009

 let l_sql = " select socvclcod  ",
                  "   from datrvclasi ",
                  "  where datrvclasi.socvclcod = ? ",
                  "    and datrvclasi.asitipcod = ? "
 prepare p_cts00m20_010    from l_sql
 declare c_cts00m20_009  cursor for p_cts00m20_010

   #PSI198714
  let l_sql = " select socntzcod , espcod "
             ," from datmsrvre            "
             ," where atdsrvnum =  ?      "
             ,"   and atdsrvano = ?       "
  prepare p_cts00m20_011 from l_sql
  declare c_cts00m20_010 cursor for p_cts00m20_011
  let l_sql = " select cpodes from iddkdominio ",
               " where cponom = 'socvcltip' ",
                 " and cpocod = ? "
  prepare pcts00m20016 from l_sql
  declare ccts00m20016 cursor for pcts00m20016

   let m_prepara_sql = true

end function

#------------------------------------------------------------
 function cts00m20(param)
#------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    gpsacngrpcod      like datkmpacid.gpsacngrpcod,
    tipo_demanda      char(15) #psi179345
 end record

 define d_cts00m20    record
    vcldtbgrpcod      like dattfrotalocal.vcldtbgrpcod,
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    asitipcod         like datmservico.asitipcod,
    asitipabvdes      like datkasitip.asitipabvdes,
    ciaempcod         like datrvclemp.ciaempcod,             #PSI 205206
    empsgl            like gabkemp.empsgl,                   #PSI 205206
    c24atvpsq         like dattfrotalocal.c24atvcod          #PSI 205206
 end record

 define a_cts00m20    array[2000]  of  record
    atdvclsgl         like datkveiculo.atdvclsgl,
    c24atvcod         like dattfrotalocal.c24atvcod,
    socvclcod         like dattfrotalocal.socvclcod,
    socvcltipdes      char (50),
    vcleqpdes         char (15),
    srrcoddig         like dattfrotalocal.srrcoddig,
    srrabvnom         like datksrr.srrabvnom,
    srrasides         char (100),
    ufdcod_gps        like datmfrtpos.ufdcod,
    cidnom_gps        like datmfrtpos.cidnom,
    brrnom_gps        like datmfrtpos.brrnom,
    endzon_gps        like datmfrtpos.endzon,
    obspostxt         like dattfrotalocal.obspostxt,
    espera            interval hour(2) to second,
    dstqtd            dec  (8,4),
    atdprscod         like datmservico.atdprscod,
    lclltt            like datmfrtpos.lclltt,
    lcllgt            like datmfrtpos.lcllgt
 end record

 define a_cts00m20b   array[2000]  of  record
    atdvclsgl         like datkveiculo.atdvclsgl,
    c24atvcod         like dattfrotalocal.c24atvcod,
    socvclcod         like dattfrotalocal.socvclcod,
    socvcltipdes      char (50),
    vcleqpdes         char (15),
    srrcoddig         like dattfrotalocal.srrcoddig,
    srrabvnom         like datksrr.srrabvnom,
    srrasides         char (100),
    ufdcod_gps        like datmfrtpos.ufdcod,
    cidnom_gps        like datmfrtpos.cidnom,
    brrnom_gps        like datmfrtpos.brrnom,
    endzon_gps        like datmfrtpos.endzon,
    obspostxt         like dattfrotalocal.obspostxt,
    espera            interval hour(2) to second,
    dstqtd            dec  (8,4),
    atdprscod         like datmservico.atdprscod,
    lclltt            like datmfrtpos.lclltt,
    lcllgt            like datmfrtpos.lcllgt
 end record


 define a_cts00m20c   array[2000]  of  record
    atdvclsgl         like datkveiculo.atdvclsgl,
    c24atvcod         like dattfrotalocal.c24atvcod,
    socvclcod         like dattfrotalocal.socvclcod,
    socvcltipdes      char (50),
    vcleqpdes         char (15),
    srrcoddig         like dattfrotalocal.srrcoddig,
    srrabvnom         like datksrr.srrabvnom,
    srrasides         char (100),
    ufdcod_gps        like datmfrtpos.ufdcod,
    cidnom_gps        like datmfrtpos.cidnom,
    brrnom_gps        like datmfrtpos.brrnom,
    endzon_gps        like datmfrtpos.endzon,
    obspostxt         like dattfrotalocal.obspostxt,
    espera            interval hour(2) to second,
    dstqtd            dec  (8,4),
    atdprscod         like datmservico.atdprscod,
    lclltt            like datmfrtpos.lclltt,
    lcllgt            like datmfrtpos.lcllgt
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
    c24lclpdrcod_srv  like datmlcl.c24lclpdrcod,
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

 define l_srvrcumtvcod    like datmsrvacp.srvrcumtvcod

#psi179345
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

 define la_cts00m20 array[50] of record
        grlinf like igbkgeral.grlinf
       ,grlchv like igbkgeral.grlchv
 end record

 define l_tmp_flg   smallint,
        l_posicao   smallint

  define l_socntzcod   like datmsrvre.socntzcod,
         l_espcod      like datmsrvre.espcod,
         l_sql         char(600),
         l_srrcoddig   like datrsrrasi.srrcoddig,
         l_tipasivalidos char(15),
         l_socvcltip   char(300)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_resultado  =  null
        let     l_mensagem  =  null
        let     l_i  =  null
        let     prompt_key  =  null
        let     arr_aux  =  null
        let     arr_aux1  =  null
        let     arr_aux2  =  null
        let     arr_aux3  =  null
        let     arr_aux4  =  null
        let     ws_cont  =  null
        let     l_retorno  =  null
        let     l_primeiro  =  null
        let     l_srvrcumtvcod  =  null
        let     l_cont  =  null
        let     l_cont_a  =  null
        let     l_stringop  =  null
        let     l_op  =  null
        let     l_desc  =  null
        let     l_c24opemat  =  null
        let     l_c24opeempcod  =  null
        let     l_c24opeusrtip  =  null
        let     l_funnom  =  null
        let     l_socacsflg  =  null
        let     l_tmp_flg  =  null
        let     l_posicao  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize a_cts00m20  to null
  initialize a_cts00m20b to null
  initialize a_cts00m20c to null
  initialize al_saida    to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize d_cts00m20              to null
  initialize ws                      to null
  initialize lr_frota                to null
  initialize la_cts00m20, l_stringop to null

  let l_cont = 1
  let l_primeiro = false
#fim psi179345

  initialize al_saida to null
  let l_resultado = null
  let l_mensagem  = null
  let l_i         = 1
  let l_posicao   = null

 if m_prepara_sql is null or m_prepara_sql <> true then
    call cts00m20_prepara()
 end if

  let     prompt_key  =  null
  let     arr_aux     =  null
  let     arr_aux1    =  null
  let     arr_aux2    =  null
  let     arr_aux3    =  null
  let     arr_aux4    =  null


  initialize  a_cts00m20  to null
  initialize  a_cts00m20b to null
  initialize  a_cts00m20c to null
  initialize  d_cts00m20  to null
  initialize  ws          to null

 let arr_aux  =  1
 let ws.tempodif  = "00:20:00"

 #------------------------------------------------------------------
 # Verifica parametros informados
 #------------------------------------------------------------------

#psi179345 - Inicio

 if param.tipo_demanda is not null then
    let  l_cont = 1
    open c_cts00m20_001
    foreach c_cts00m20_001 into la_cts00m20[l_cont].grlinf,
                              la_cts00m20[l_cont].grlchv
       let l_cont = l_cont + 1
       if l_cont > 50 then
          error "Limite de array excedido"
          exit foreach
       end if
    end foreach
    let l_cont = l_cont - 1
    if l_cont < 1 then
       error "Nao existe demanda ativa!!!" sleep 2
       return a_cts00m20[arr_aux].atdprscod,
              a_cts00m20[arr_aux].atdvclsgl,
              a_cts00m20[arr_aux].srrcoddig,
              a_cts00m20[arr_aux].socvclcod,
              ws.prvcalc,
              a_cts00m20[arr_aux].dstqtd,
              ws.flag_cts00m02
    end if
    if l_cont = 1 then
       let param.tipo_demanda = la_cts00m20[1].grlchv
       if  param.tipo_demanda = "RADIO-DEMAU" then
           let ws.atdsrvorg = 1
       end if
       if  param.tipo_demanda = "RADIO-DEMRE" then
           let ws.atdsrvorg = 9
       end if
       if  param.tipo_demanda = "RADIO-DEMJI" then
           let ws.atdsrvorg = 15
       end if
       if  param.tipo_demanda = "RADIO-DEMVP" then
           let ws.atdsrvorg = 10
       end if
    else
       let l_stringop = null
       for l_cont_a = 1 to l_cont
          if la_cts00m20[l_cont_a].grlchv = "RADIO-DEMAU" then
             if  l_stringop is null then
                 let l_stringop = "AUTO"
             else
                 let l_stringop = l_stringop clipped,"|AUTO"
             end if
          end if
          if la_cts00m20[l_cont_a].grlchv = "RADIO-DEMRE" then
             if  l_stringop is null then
                 let l_stringop = "RE"
             else
                 let l_stringop = l_stringop clipped,"|RE"
             end if
          end if
          if la_cts00m20[l_cont_a].grlchv = "RADIO-DEMJI" then
             if  l_stringop is null then
                 let l_stringop = "JIT"
             else
                 let l_stringop = l_stringop clipped,"|JIT"
             end if
          end if
          if la_cts00m20[l_cont_a].grlchv = "RADIO-DEMVP" then
             if  l_stringop is null then
                 let l_stringop = "VP"
             else
                 let l_stringop = l_stringop clipped,"|VP"
             end if
          end if
       end for
       call ctx14g00("DEMANDA", l_stringop) returning l_op, l_desc
       if l_op = 0 then
          return a_cts00m20[arr_aux].atdprscod,
                 a_cts00m20[arr_aux].atdvclsgl,
                 a_cts00m20[arr_aux].srrcoddig,
                 a_cts00m20[arr_aux].socvclcod,
                 ws.prvcalc,
                 a_cts00m20[arr_aux].dstqtd,
                 ws.flag_cts00m02
       end if
       if l_desc = 'AUTO' then
          let param.tipo_demanda = "RADIO-DEMAU"
          let ws.atdsrvorg = 1
       end if
       if l_desc = 'RE' then
          let param.tipo_demanda = "RADIO-DEMRE"
          let ws.atdsrvorg = 9
       end if
       if l_desc = 'JIT' then
          let param.tipo_demanda = "RADIO-DEMJI"
          let ws.atdsrvorg = 15
       end if
       if l_desc = 'VP' then
          let param.tipo_demanda = "RADIO-DEMVP"
          let ws.atdsrvorg = 10
       end if
    end if
 else

## PSI 179345 - Final

    if param.atdsrvnum  is null   or
       param.atdsrvano  is null   then
       error " Numero do servico nao informado, AVISE INFORMATICA!"
       return a_cts00m20[arr_aux].atdprscod,
              a_cts00m20[arr_aux].atdvclsgl,
              a_cts00m20[arr_aux].srrcoddig,
              a_cts00m20[arr_aux].socvclcod,
              ws.prvcalc,
              a_cts00m20[arr_aux].dstqtd,
              ws.flag_cts00m02
    end if

    select atdsrvorg, asitipcod, atdhorpvt,
           ciaempcod                                      #PSI 205206
      into ws.atdsrvorg, d_cts00m20.asitipcod, ws.atdhorpvt,
           d_cts00m20.ciaempcod                           #PSI 205206
      from datmservico
     where atdsrvnum  =  param.atdsrvnum
       and atdsrvano  =  param.atdsrvano

    if sqlca.sqlcode  =  notfound   then
       error " Servico nao encontrado, AVISE INFORMATICA!"
       return a_cts00m20[arr_aux].atdprscod,
              a_cts00m20[arr_aux].atdvclsgl,
              a_cts00m20[arr_aux].srrcoddig,
              a_cts00m20[arr_aux].socvclcod,
              ws.prvcalc,
              a_cts00m20[arr_aux].dstqtd,
              ws.flag_cts00m02
    end if

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
       return a_cts00m20[arr_aux].atdprscod,
              a_cts00m20[arr_aux].atdvclsgl,
              a_cts00m20[arr_aux].srrcoddig,
              a_cts00m20[arr_aux].socvclcod,
              ws.prvcalc,
              a_cts00m20[arr_aux].dstqtd,
              ws.flag_cts00m02
    else
       if ws.atdsrvorg  =  2   and
          d_cts00m20.asitipcod  <>  5    then         #taxi para servico a residencia
          error " Tipo de assistencia nao utiliza localizacao por GPS!"
          return a_cts00m20[arr_aux].atdprscod,
                 a_cts00m20[arr_aux].atdvclsgl,
                 a_cts00m20[arr_aux].srrcoddig,
                 a_cts00m20[arr_aux].socvclcod,
                 ws.prvcalc,
                 a_cts00m20[arr_aux].dstqtd,
                 ws.flag_cts00m02
       end if
    end if

    #------------------------------------------------------------------
    # Verifica se servico possui latitude/longitude
    #------------------------------------------------------------------
    select lclltt,
           lcllgt,
           c24lclpdrcod,
           cidnom,
           ufdcod
      into ws.lclltt_srv,
           ws.lcllgt_srv,
           ws.c24lclpdrcod_srv,
           ws.cidnom_srv,
           ws.ufdcod_srv
      from datmlcl
     where atdsrvnum  =  param.atdsrvnum
       and atdsrvano  =  param.atdsrvano
       and c24endtip  =  1

    if sqlca.sqlcode  =  notfound   then
       error " Local da ocorrencia nao encontrado, AVISE INFORMATICA!"
       return a_cts00m20[arr_aux].atdprscod,
              a_cts00m20[arr_aux].atdvclsgl,
              a_cts00m20[arr_aux].srrcoddig,
              a_cts00m20[arr_aux].socvclcod,
              ws.prvcalc,
              a_cts00m20[arr_aux].dstqtd,
              ws.flag_cts00m02
    end if

    if ws.lclltt_srv  is null   or
       ws.lcllgt_srv  is null   or
       (ws.c24lclpdrcod_srv <> 3 and
        ws.c24lclpdrcod_srv <> 4 and # PSI 252891
        ws.c24lclpdrcod_srv <> 5 and
        (not cts40g12_gpsacncid(ws.cidnom_srv, ws.ufdcod_srv)) # Verifica se o acionamento GPS pode ser realizado pela coordenada da Cidade
        )then
       error " Servico nao possui localizacao por latitude/longitude!"
       return a_cts00m20[arr_aux].atdprscod,
              a_cts00m20[arr_aux].atdvclsgl,
              a_cts00m20[arr_aux].srrcoddig,
              a_cts00m20[arr_aux].socvclcod,
              ws.prvcalc,
              a_cts00m20[arr_aux].dstqtd,
              ws.flag_cts00m02
    end if
 end if
#fim psi179345

 #------------------------------------------------------------------
 # Informa dados para pesquisa
 #------------------------------------------------------------------
 open window w_cts00m20 at  04,02 with form "cts00m20"
             attribute(form line first)

 #local/condicoes veiculo
 call ctc61m02(param.atdsrvnum,param.atdsrvano,"A")

 let l_tmp_flg = ctc61m02_criatmp(2,
                                  param.atdsrvnum,
                                  param.atdsrvano)

 if l_tmp_flg = 1 then
    error "Problemas com temporaria ! <Avise a Informatica>."
 end if

 if ws.atdsrvorg = 9 or ws.atdsrvorg = 13 then
    select socntzgrpcod
      into ws.socntzgrpcod
      from datmsrvre, datksocntz
     where datmsrvre.atdsrvnum  = param.atdsrvnum
       and datmsrvre.atdsrvano  = param.atdsrvano
       and datksocntz.socntzcod = datmsrvre.socntzcod
     if sqlca.sqlcode = notfound then
        let ws.socntzgrpcod = 2
     end if
 end if

 while true

   clear form
   let int_flag  =  false
   let ws.f8flg  =  "N"
   let arr_aux   =  1

   #PSI 205206
   #exibir empresa assim que abrir tela
   if d_cts00m20.ciaempcod is null then
       let d_cts00m20.empsgl = "TODAS"
   else
       #------------------------------------------------------------------
       # Busca descrição da empresa
       #------------------------------------------------------------------
       call cty14g00_empresa(1, d_cts00m20.ciaempcod)
            returning l_retorno,
                      l_mensagem,
                      d_cts00m20.empsgl
   end if
   display by name d_cts00m20.ciaempcod attribute (reverse)
   display by name d_cts00m20.empsgl attribute (reverse)


   input by name d_cts00m20.vcldtbgrpcod,
                 d_cts00m20.ciaempcod,
                 d_cts00m20.c24atvpsq without defaults

      before field vcldtbgrpcod

             display by name d_cts00m20.vcldtbgrpcod thru
                             d_cts00m20.vcldtbgrpdes
             if ws.atdsrvorg = 9 or ws.atdsrvorg = 13 then
                let d_cts00m20.vcldtbgrpcod = 4
                if ws.socntzgrpcod = 1  then    # linha branca
                   let d_cts00m20.vcldtbgrpcod = 3 #somente linha branca
                end if
             end if

## PSI 179345 - Inicio

             if param.tipo_demanda = "RADIO-DEMVP" then
                let d_cts00m20.vcldtbgrpcod = 10
             end if
             if param.tipo_demanda = "RADIO-DEMJI" then
                let d_cts00m20.vcldtbgrpcod = 7
             end if

             let d_cts00m20.vcldtbgrpdes = null

             if d_cts00m20.vcldtbgrpcod is not null then
                open c_cts00m20_005 using d_cts00m20.vcldtbgrpcod
                whenever error continue
                fetch c_cts00m20_005 into d_cts00m20.vcldtbgrpdes
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode <> 100 then
                      error 'Problemas de acesso a tabela datkvcldtbgrp, ',
                            sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                      error 'cts00m20()', d_cts00m20.vcldtbgrpcod sleep 2
                      exit input
                   end if
                end if
             end if

             display by name d_cts00m20.vcldtbgrpcod  attribute (reverse)
             display by name d_cts00m20.vcldtbgrpdes

## PSI 179345 - Final

      after  field vcldtbgrpcod
             display by name d_cts00m20.vcldtbgrpcod

             initialize d_cts00m20.vcldtbgrpdes  to null
             display by name d_cts00m20.vcldtbgrpdes

             if d_cts00m20.vcldtbgrpcod  is null   then
                let d_cts00m20.vcldtbgrpdes  =  "TODOS"
             else

## PSI 179345 - Inicio

                open c_cts00m20_005 using d_cts00m20.vcldtbgrpcod
                whenever error continue
                fetch c_cts00m20_005 into d_cts00m20.vcldtbgrpdes
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = 100 then
                      error " Grupo de distribuicao nao cadastrado!"
                      if param.tipo_demanda is not null then
                         call ctn39c00_demanda(l_desc)
                              returning d_cts00m20.vcldtbgrpcod
                      else
                         call ctn39c00() returning d_cts00m20.vcldtbgrpcod
                      end if
                      next field vcldtbgrpcod
                   else
                      error 'Problemas de acesso a tabela datkvcldtbgrp, ',
                            sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                      error 'cts00m20()', d_cts00m20.vcldtbgrpcod sleep 2
                      exit input
                   end if
                end if
             end if

             display by name d_cts00m20.vcldtbgrpdes

            #if d_cts00m20.vcldtbgrpcod  is not null   and
            #   param.tipo_demanda       is not null   then
            #   case param.tipo_demanda
            #        when "RADIO-DEMAU"
            #          if d_cts00m20.vcldtbgrpcod <> 2   and
            #             d_cts00m20.vcldtbgrpcod <> 11  then
            #             error 'Demanda Auto so permite grupo 2 ou 11'
            #             next field vcldtbgrpcod
            #          end if
            #        when "RADIO-DEMRE"
            #          if d_cts00m20.vcldtbgrpcod <> 2   and
            #             d_cts00m20.vcldtbgrpcod <> 3   and
            #             d_cts00m20.vcldtbgrpcod <> 4   and
            #             d_cts00m20.vcldtbgrpcod <> 6   and
            #             d_cts00m20.vcldtbgrpcod <> 8   then
            #             error 'Demanda RE so permite grupo 2,3,4,6,8'
            #             next field vcldtbgrpcod
            #          end if
            #        when "RADIO-DEMJI"
            #          if d_cts00m20.vcldtbgrpcod <> 7   then
            #             error 'Demanda JIT so permite grupo 7'
            #             next field vcldtbgrpcod
            #          end if
            #        when "RADIO-DEMVP"
            #          if d_cts00m20.vcldtbgrpcod <> 10  then
            #             error 'Demanda VP so permite grupo 10'
            #             next field vcldtbgrpcod
            #          end if
            #   end case
            #end if

## PSI 179345 - Final


      #PSI 205206
      before field ciaempcod
           display by name d_cts00m20.ciaempcod attribute (reverse)

      after field ciaempcod
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field vcldtbgrpcod
           end if
           if d_cts00m20.ciaempcod is null then
              let d_cts00m20.empsgl = "TODAS"
           else
              #------------------------------------------------------------------
              # Busca descrição da empresa
              #------------------------------------------------------------------
              call cty14g00_empresa(1, d_cts00m20.ciaempcod)
                   returning l_retorno,
                             l_mensagem,
                             d_cts00m20.empsgl
           end if
           display by name d_cts00m20.ciaempcod attribute (reverse)
           display by name d_cts00m20.empsgl attribute (reverse)

      before field c24atvpsq
           let d_cts00m20.c24atvpsq = "QRV"
           display by name d_cts00m20.c24atvpsq attribute (reverse)

      after field c24atvpsq
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field ciaempcod
           end if

           if d_cts00m20.c24atvpsq is not null and
              d_cts00m20.c24atvpsq <> "QRV" and
              d_cts00m20.c24atvpsq <> "QRA" and
              d_cts00m20.c24atvpsq <> "QTP" and
              d_cts00m20.c24atvpsq <> "INI" and
              d_cts00m20.c24atvpsq <> "FIM" and
              d_cts00m20.c24atvpsq <> "QRU" and
              d_cts00m20.c24atvpsq <> "QRX" then
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
   # Lê todos os veiculos disponiveis para atendimento
   #------------------------------------------------------------------
   message " Aguarde, pesquisando..."  attribute(reverse)

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
           " from dattfrotalocal, datkveiculo, outer datksrr, outer datmfrtpos"

   #PSI 224782
   if d_cts00m20.asitipcod then
       let ws.comando =  ws.comando clipped,
                 " ,datrsrrasi, datkasitip, datrvclasi "
   end if

   if d_cts00m20.vcldtbgrpcod  is not null and
      d_cts00m20.c24atvpsq is not null  then
      let ws.condicao =
              "where dattfrotalocal.vcldtbgrpcod = ? ",
               " and dattfrotalocal.c24atvcod    = ? "

      #PSI 224782
      if d_cts00m20.asitipcod  is not null then
          let ws.condicao = ws.condicao clipped,
                            " and datrsrrasi.asitipcod = ? ",
                            " and datrsrrasi.srrcoddig  = dattfrotalocal.srrcoddig ",
                            #and dattfrotalocal.socvclcod = datkveiculo.socvclcod
                            " and datrsrrasi.asitipcod  = datkasitip.asitipcod ",
                            " and datrvclasi.socvclcod  = datkveiculo.socvclcod ",
                            " and datrvclasi.asitipcod  = datrsrrasi.asitipcod "
      end if

   else if d_cts00m20.vcldtbgrpcod is not null and
           d_cts00m20.c24atvpsq is null  then
           let ws.condicao =
                   "where dattfrotalocal.vcldtbgrpcod = ? "

           #PSI 224782
           if d_cts00m20.asitipcod  is not null then
               let ws.condicao = ws.condicao clipped,
                                 " and datrsrrasi.asitipcod = ? ",
                                 " and datrsrrasi.srrcoddig  = dattfrotalocal.srrcoddig ",
                                 #and dattfrotalocal.socvclcod = datkveiculo.socvclcod
                                 " and datrsrrasi.asitipcod  = datkasitip.asitipcod ",
                                 " and datrvclasi.socvclcod  = datkveiculo.socvclcod ",
                                 " and datrvclasi.asitipcod  = datrsrrasi.asitipcod "
           end if

        else if d_cts00m20.vcldtbgrpcod is null and
                d_cts00m20.c24atvpsq is not null  then
                let ws.condicao =
                         " where dattfrotalocal.vcldtbgrpcod <> 5 ",
                         " and dattfrotalocal.c24atvcod    = ? "

                #PSI 224782
                if d_cts00m20.asitipcod  is not null then
                    let ws.condicao = ws.condicao clipped,
                                     " and datrsrrasi.asitipcod = ? ",
                                     " and datrsrrasi.srrcoddig  = dattfrotalocal.srrcoddig ",
                                     #and dattfrotalocal.socvclcod = datkveiculo.socvclcod
                                     " and datrsrrasi.asitipcod  = datkasitip.asitipcod ",
                                     " and datrvclasi.socvclcod  = datkveiculo.socvclcod ",
                                     " and datrvclasi.asitipcod  = datrsrrasi.asitipcod "
                end if

             else if d_cts00m20.vcldtbgrpcod is null and
                     d_cts00m20.c24atvpsq is null  then
                     let ws.condicao =
                         " where dattfrotalocal.vcldtbgrpcod <> 5 "

                     #PSI 224782
                     if d_cts00m20.asitipcod  is not null then
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

             case param.tipo_demanda
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

   let ws.condicao = ws.condicao clipped,
               " and datkveiculo.socvclcod       = dattfrotalocal.socvclcod ",
               " and datkveiculo.socoprsitcod    = '1' ",
               " and datksrr.srrcoddig           = dattfrotalocal.srrcoddig ",
               " and datmfrtpos.socvclcod        = dattfrotalocal.socvclcod ",
               " and datmfrtpos.socvcllcltip     = '1' ",
               " and datkveiculo.socacsflg       = '0' "

   let ws.comando  =  ws.comando clipped, " ", ws.condicao
   prepare p_cts00m20_012   from  ws.comando
   declare c_cts00m20_011   cursor for p_cts00m20_012

   --CT 321044
   set isolation to dirty read

   if d_cts00m20.vcldtbgrpcod  is not null and
      d_cts00m20.c24atvpsq is not null  then

      #PSI 224782
      if d_cts00m20.asitipcod  is null then
          open c_cts00m20_011  using  d_cts00m20.vcldtbgrpcod,
                                    d_cts00m20.c24atvpsq # param.gpsacngrpcod
      else
          open c_cts00m20_011  using  d_cts00m20.vcldtbgrpcod,
                                    d_cts00m20.c24atvpsq, d_cts00m20.asitipcod
      end if
   else
      if d_cts00m20.vcldtbgrpcod  is not null then
         #PSI 224782
         if d_cts00m20.asitipcod  is null then
             open c_cts00m20_011  using  d_cts00m20.vcldtbgrpcod
         else
             open c_cts00m20_011  using  d_cts00m20.vcldtbgrpcod, d_cts00m20.asitipcod
         end if
      else
         if d_cts00m20.c24atvpsq is not null  then
            #PSI 224782
            if d_cts00m20.asitipcod  is null then
                open c_cts00m20_011 using d_cts00m20.c24atvpsq # param.gpsacngrpcod
            else
                open c_cts00m20_011 using d_cts00m20.c24atvpsq, d_cts00m20.asitipcod
            end if
         else
            #PSI 224782
            if d_cts00m20.asitipcod  is null then
                open c_cts00m20_011
            else
                open c_cts00m20_011 using d_cts00m20.asitipcod
            end if
         end if
      end if
   end if

   foreach  c_cts00m20_011 into  a_cts00m20b[arr_aux].srrcoddig,
                               a_cts00m20b[arr_aux].c24atvcod,
                               a_cts00m20b[arr_aux].obspostxt,
                               a_cts00m20b[arr_aux].socvclcod,
                               a_cts00m20b[arr_aux].atdvclsgl,
                               ws.vclcoddig,
                               a_cts00m20b[arr_aux].atdprscod,
                               a_cts00m20b[arr_aux].srrabvnom,
                               a_cts00m20b[arr_aux].ufdcod_gps,
                               a_cts00m20b[arr_aux].cidnom_gps,
                               a_cts00m20b[arr_aux].brrnom_gps,
                               a_cts00m20b[arr_aux].endzon_gps,
                               a_cts00m20b[arr_aux].lclltt,  # latitude veic.
                               a_cts00m20b[arr_aux].lcllgt,  # longitude veic.
                               ws.atldat,
                               ws.atlhor,
                               ws.vcldtbgrpcod

      if ws.vcldtbgrpcod = 3   or     # Viaturas RE /linha branca e
         ws.vcldtbgrpcod = 4   then   # Viaturas RE nao serao vistas para
         if ws.atdsrvorg <> 9  and    # outros servicos <> RE
            ws.atdsrvorg <> 13 then
            continue foreach
         end if
      end if

      if a_cts00m20b[arr_aux].lclltt  is null or
         a_cts00m20b[arr_aux].lcllgt  is null then
         initialize a_cts00m20b[arr_aux]  to null
         continue foreach
      end if

      #PSI 205206
      #------------------------------------------------------------------
      # Verifica se veiculo atende a empresa solicitada
      #------------------------------------------------------------------
      if d_cts00m20.ciaempcod is not null then
         call ctd05g00_valida_empveic(d_cts00m20.ciaempcod,
                                      a_cts00m20b[arr_aux].socvclcod)
              returning l_retorno,
                        l_mensagem
         if l_retorno <> 1 then
            #veiculo nao atende a empresa solicitada
            continue foreach
         end if
      end if

      #------------------------------------------------------------------
      # Verifica tipo de assistencia do socorrista
      #------------------------------------------------------------------
#     if d_cts00m20.asitipcod  is not null    then
#        open  c_cts00m20_008  using  a_cts00m20b[arr_aux].srrcoddig,
#                                   d_cts00m20.asitipcod
#        fetch c_cts00m20_008  into   ws.srrcoddig
#           if sqlca.sqlcode = notfound then
#              initialize a_cts00m20b[arr_aux]  to null
#              continue foreach
#           end if
#        close c_cts00m20_008
#     end if

      #------------------------------------------------------------------
      # Verifica tipo de assistencia do veiculo   (### ATUALIZAR ###)
      #------------------------------------------------------------------
 #    if d_cts00m20.?????????  is not null    then
 #       open  c_cts00m20_009  using  a_cts00m20b[arr_aux].socvclcod,
 #                                  d_cts00m20.asitipcod
 #       fetch c_cts00m20_009  into   ws.socvclcod
 #          if sqlca.sqlcode = notfound then
 #             initialize a_cts00m20b[arr_aux]  to null
 #             continue foreach
 #          end if
 #       close c_cts00m20_009
 #    end if

      #------------------------------------------------------------------
      # Busca assistencias do socorrista
      #------------------------------------------------------------------
      let a_cts00m20b[arr_aux].srrasides = null

      # --SE ORIGEM = 9(RE) ou 13(SINISTRORE) BUSCA OS DADOS DA TABELA dbsrntzpstesp

      if ws.atdsrvorg = 9 or
         ws.atdsrvorg = 13 then # PSI 235849 Adriano Santos 28/01/2009
         #busca naturezas do prestador
         let a_cts00m20b[arr_aux].srrasides = cts00m03_busca_natureza(a_cts00m20b[arr_aux].srrcoddig)
      else
         #PSI 224782
         #busca assistencias do prestador
         let a_cts00m20b[arr_aux].srrasides = cts00m03_busca_assistencia(a_cts00m20b[arr_aux].srrcoddig, a_cts00m20b[arr_aux].socvclcod)
      end if

      #---------------------------------------------------------------
      # Busca descricao do veiculo
      #---------------------------------------------------------------
      initialize a_cts00m20b[arr_aux].socvcltipdes to null

      open  c_cts00m20_006 using a_cts00m20b[arr_aux].socvclcod
      fetch c_cts00m20_006 into l_socvcltip
      close c_cts00m20_006
      open ccts00m20016 using l_socvcltip
      fetch ccts00m20016 into a_cts00m20b[arr_aux].socvcltipdes

      #---------------------------------------------------------------
      # Busca equipamentos do veiculo
      #---------------------------------------------------------------
      initialize  a_cts00m20b[arr_aux].vcleqpdes  to null

      open    c_cts00m20_007  using  a_cts00m20b[arr_aux].socvclcod
      foreach c_cts00m20_007  into   ws.soceqpabv
         let a_cts00m20b[arr_aux].vcleqpdes =
             a_cts00m20b[arr_aux].vcleqpdes clipped, ws.soceqpabv clipped, "/"
      end foreach
      close c_cts00m20_007

      #---------------------------------------------------------------
      # Calcula distancia entre local do servico e local do veiculo
      #---------------------------------------------------------------
      initialize a_cts00m20b[arr_aux].dstqtd  to null
#psi179345
      if param.tipo_demanda is null then
         call cts18g00(ws.lclltt_srv, ws.lcllgt_srv,
                       a_cts00m20b[arr_aux].lclltt,
                       a_cts00m20b[arr_aux].lcllgt)
             returning a_cts00m20b[arr_aux].dstqtd
      end if
#fim psi179345
      #---------------------------------------------------------------
      # Calcula tempo de espera do ultimo sinal GPS recebido
      #---------------------------------------------------------------

      initialize a_cts00m20b[arr_aux].espera  to null

      call cts00m20_espera(ws.atldat, ws.atlhor)
                 returning a_cts00m20b[arr_aux].espera

      let arr_aux = arr_aux + 1
      if arr_aux > 2000  then
         error " Limite excedido, pesquisa com mais de 2000 veiculos!"
         exit foreach
      end if

   end foreach

   --CT 321044
   set lock mode to wait

   let ws.total = "Total: ", arr_aux - 1  using "&&&"
   display by name ws.total  attribute(reverse)

   if arr_aux =  1   then
      error " Nao existem veiculos com esta atividade na cidade do Servico !"
   else
      #---------------------------------------------------------------
      # Classifica o array por ordem crescente de distancia
      #---------------------------------------------------------------
#psi179345

      if param.tipo_demanda is null then
         for arr_aux2 = 1 to arr_aux - 1
            for arr_aux1 = 1 to arr_aux - 1
               if a_cts00m20b[arr_aux1].dstqtd  is not null   then
                  if a_cts00m20b[arr_aux1].dstqtd < a_cts00m20[arr_aux2].dstqtd  or
                     a_cts00m20[arr_aux2].dstqtd  is null                        then
                     let a_cts00m20[arr_aux2].*  =  a_cts00m20b[arr_aux1].*
                     let arr_aux3  =  arr_aux1
                  end if
               end if
            end for
            initialize a_cts00m20b[arr_aux3]  to null
         end for
      else
         for arr_aux2 = 1 to arr_aux - 1
             let a_cts00m20[arr_aux2].* = a_cts00m20b[arr_aux2].*
         end for
      end if
#fim psi179345
      message "F2-Srv. F17-Sair F5-Cnd.Veic F6-Recusa F8-Sel F9-Msg MDT F10 +Inf"
      call set_count(arr_aux-1)

#psi179345
      if param.tipo_demanda is null then
         let arr_aux4 = 1
         # 1 Laco , so menores que 20 Minutos
         for arr_aux2 = 1 to arr_aux - 1
            if a_cts00m20[arr_aux2].espera <= ws.tempodif then
               let a_cts00m20c[arr_aux4].* = a_cts00m20[arr_aux2].*
               let arr_aux4 = arr_aux4 + 1
            end if
         end for
         # 2 Laco , so maiores que 20 Minutos
         for arr_aux2 = 1 to arr_aux - 1
            if a_cts00m20[arr_aux2].espera > ws.tempodif then
               let a_cts00m20c[arr_aux4].* = a_cts00m20[arr_aux2].*
               let arr_aux4 = arr_aux4 + 1
            end if
         end for
      else
         for arr_aux2 = 1 to arr_aux - 1
             let a_cts00m20c[arr_aux2].* = a_cts00m20[arr_aux2].*
         end for
      end if
#fim psi179345

      display array  a_cts00m20c to s_cts00m20.*
         on key (interrupt)
            initialize a_cts00m20   to null
            initialize a_cts00m20b  to null
            initialize a_cts00m20c  to null
            exit display

          #---------------------------------------------------------#
          # Consulta e exibe as Naturezas atendidas pelos prestadores
          #---------------------------------------------------------#
          on key (f2)

             let l_posicao = arr_curr()

             call cts00m03_exibe_natz_atend(a_cts00m20c[l_posicao].srrcoddig,a_cts00m20c[l_posicao].socvclcod)

         ## Implementar Consulta de Locais e Condicoes do Veiculo
         on key (f5)
            let arr_aux = arr_curr()
            call ctc61m02(param.atdsrvnum,param.atdsrvano,"A")
            let l_tmp_flg = ctc61m02_criatmp(2,
                                             param.atdsrvnum,
                                             param.atdsrvano)
            if l_tmp_flg = 1 then
               error "Problemas com temporaria ! <Avise a Informatica>."
            end if

         on key (F6)
            #continue while
            let arr_aux = arr_curr()
            call cta11m00 ( ws.atdsrvorg
                           ,param.atdsrvnum
                           ,param.atdsrvano
                           ,a_cts00m20[arr_aux].atdprscod
                           ,"S" )
                 returning l_srvrcumtvcod

         on key (F8)
            let l_posicao = arr_curr()
            if param.tipo_demanda is not null or
               a_cts00m20[l_posicao].c24atvcod = "QRV" then

            let l_primeiro = false
            let arr_aux = arr_curr()
            let ws.f8flg = "S"

            #PSI198714 - Validar se socorrista atende assistencia/natureza do servico
            # apenas quando já tenho servico selecionado - quando não tenho é busca por demanda
            if param.atdsrvnum is not null and
               param.atdsrvano is not null then
               if ws.atdsrvorg = 9 or
                  ws.atdsrvorg = 13 then # PSI 235849 Adriano Santos 28/01/2009
               #Se origem servico = 9 ou 13 validar se socorrista atende natureza do servico
               #buscar natureza e especialidade do servico re
                   open c_cts00m20_010 using  param.atdsrvnum
                                           ,param.atdsrvano
                   fetch c_cts00m20_010 into l_socntzcod,
                                           l_espcod
                   if l_socntzcod is not null then
                      let l_sql= "select socntzcod     "
                               ," from dbsrntzpstesp  "
                               ," where srrcoddig = ", a_cts00m20c[arr_aux].srrcoddig
                               ,"   and socntzcod = ", l_socntzcod
                      if l_espcod is not null then
                         #servico tem especialidade verificar se socorrista atende natureza e especialidade
                         let l_sql = l_sql clipped, " and espcod = ", l_espcod
                      end if
                      prepare pcts00m20013 from l_sql
                      declare ccts00m20013  cursor for pcts00m20013
                      open ccts00m20013
                      fetch ccts00m20013 into l_socntzcod
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
                               "  where a.srrcoddig = ",a_cts00m20c[arr_aux].srrcoddig
                   case d_cts00m20.asitipcod             #quando tipo de assistencia do servico e:
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
                          let l_sql = l_sql clipped, " and asitipcod in (",d_cts00m20.asitipcod,")"
                   end case
                   #OBS.: Hoje estamos fazendo essas conversoes de tipo de assitencia do
                   # socorrista porque o cadastro deles não está integro.
                   # Os códigos 3, 9 e 40 nao deveriam mais existir
                   # exemplo: os socorristas que atendem assistencia 3 deveriam atender
                   # assistencia 1 e 2.
                   #Quando o cadastro de assistencia dos socorristas estiver correto,
                   # podemos retirar essas conversoes

                   prepare pcts00m20015 from l_sql
                   declare ccts00m20015  cursor for pcts00m20015
                   open ccts00m20015
                   fetch ccts00m20015  into   l_srrcoddig
                   if sqlca.sqlcode = notfound then
                      call cts08g01("A", "N", "", "SOCORRISTA NAO ATENDE TIPO ",
                                       "DE ASSISTENCIA DO SERVICO", "")
                           returning ws.confirma
                      let ws.f8flg = "N"
                   else
                      #socorrista atende assistencia
                      let ws.f8flg = "S"
                   end if
                   close ccts00m20015
               end if
            end if

            if  ws.f8flg = "S" and
                param.atdsrvnum is not null and
                param.atdsrvano is not null then
                call cts00m20_verif_auto(param.atdsrvnum,param.atdsrvano,
		                         d_cts00m20.ciaempcod,
		                         d_cts00m20.asitipcod,
		                         a_cts00m20c[arr_aux].socvclcod,
		                         a_cts00m20c[arr_aux].dstqtd,
		                         a_cts00m20c[arr_aux].srrcoddig)
		returning l_retorno
                if  l_retorno = 0 then
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
                  if param.tipo_demanda is null then
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

            end if ##QRV

         #---------------------------------------------------------------
         # Consulta mensagens recebidas dos MDTs
         #---------------------------------------------------------------
         on key (F9)
            let arr_aux = arr_curr()
            call ctn44c00(2, a_cts00m20c[arr_aux].atdvclsgl, 1)

         on key (f10)
            let arr_aux = arr_curr()
            call cts00m32(a_cts00m20c[arr_aux].socvclcod)

      end display
   end if

    #--------------------------------------------------------------
    # Limpa tela (array)
    #--------------------------------------------------------------
    if ws.f8flg = "S" then
        if param.tipo_demanda is not null then
                select c24atvcod,atdsrvnum,atdsrvano
              into ws.c24atvcod,ws.atdsrvnum,ws.atdsrvano
              from dattfrotalocal
             where socvclcod = a_cts00m20c[arr_aux].socvclcod
            if sqlca.sqlcode = notfound then
                error "Posicao da Frota nao encontrada !!!"
                initialize ws.*         to null
                initialize a_cts00m20   to null
                initialize a_cts00m20b  to null
                initialize a_cts00m20c  to null
                let arr_aux = 1
                let ws.f8flg = "N"
            else
                if ws.c24atvcod <> "QRV" and
                   ws.atdsrvnum is not null and
                   ws.atdsrvano is not null then
                   error "Viatura ja acionada para o servico: ",
                         ws.atdsrvnum using "&&&&&&&", "-",
                         ws.atdsrvano using "&&"

                   let g_documento.atdprscod = a_cts00m20c[arr_aux].atdprscod
                   let g_documento.atdvclsgl = a_cts00m20c[arr_aux].atdvclsgl
                   let g_documento.srrcoddig = a_cts00m20c[arr_aux].srrcoddig
                   let g_documento.socvclcod = a_cts00m20c[arr_aux].socvclcod
                   let g_documento.lclltt    = a_cts00m20c[arr_aux].lclltt
                   let g_documento.lcllgt    = a_cts00m20c[arr_aux].lcllgt

                   call cts00m00(ws.atdsrvorg
                                ,''
                                ,param.tipo_demanda
                                ,g_documento.lclltt
                                ,g_documento.lcllgt
                                ,a_cts00m20c[arr_aux].cidnom_gps
                                ,d_cts00m20.vcldtbgrpcod
                                ,a_cts00m20c[arr_aux].srrcoddig,
                                '')

                   initialize ws.*         to null
                   initialize a_cts00m20   to null
                   initialize a_cts00m20b  to null
                   initialize a_cts00m20c  to null
                   let arr_aux = 1
                   let ws.f8flg = "N"
                end if
            end if
        end if
    end if

    if ws.f8flg  =  "S"   then

    #psi 189790
    ## obter servico multiplo
       call cts29g00_obter_multiplo(2, param.atdsrvnum, param.atdsrvano)
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
             where socvclcod = a_cts00m20c[arr_aux].socvclcod
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
                initialize a_cts00m20   to null
                initialize a_cts00m20b  to null
                initialize a_cts00m20c  to null
                continue while
            else
                if sqlca.sqlerrd[3] = 0 then
                   rollback work

                   open c_cts00m20_002 using a_cts00m20c[arr_aux].socvclcod
                   whenever error continue
                   fetch c_cts00m20_002 into l_c24opemat, l_c24opeempcod, l_c24opeusrtip
                   whenever error stop

                   if sqlca.sqlcode <> 0 then
                      if sqlca.sqlcode <> 100 then
                         error 'Problemas de acesso a tabela DATKVEICULO, ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                         error 'cts00m20()' sleep 2
                         error a_cts00m20c[arr_aux].socvclcod sleep 2
                      else
                         error "Dados nao encontrados selecionando DATKVEICULO"
                      end if
                      initialize l_c24opemat to null
                   end if

                   if l_c24opemat is not null then
                      open c_cts00m20_003 using l_c24opemat
                                             ,l_c24opeempcod
                                             ,l_c24opeusrtip
                      whenever error continue
                      fetch c_cts00m20_003 into l_funnom
                      whenever error stop
                      let l_funnom = upshift(l_funnom)
                      if sqlca.sqlcode <> 0 then
                         if sqlca.sqlcode <> 100 then
                            error 'Problemas de acesso a tabela ISSKFUNC, ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                            error 'cts00m20()' sleep 2
                            error l_c24opemat," - "
                                 ,l_c24opeempcod," - "
                                 ,l_c24opeusrtip," - " sleep 2
                         else
                            error "Dados nao encontrados selecionando ISSKFUNC"
                         end if
                      else
                         error "Veiculo sendo acionado por ",l_funnom clipped
                      end if
                   end if

                   initialize ws.*         to null
                   initialize a_cts00m20   to null
                   initialize a_cts00m20b  to null
                   initialize a_cts00m20c  to null
                   continue while
                end if
            end if

            #-----------------------------------------------------------------
            # Calcula previsao no acionamento
            #-----------------------------------------------------------------
            #psi179345

            if param.tipo_demanda is null then
                call cts21g00_calc_prev(a_cts00m20c[arr_aux].dstqtd,ws.atdhorpvt)
                returning ws.prvcalc

               ## atualizar o prestador no servico

               call cts10g09_registrar_prestador(2
                                                ,param.atdsrvnum
                                                ,param.atdsrvano
                                                ,a_cts00m20c[arr_aux].socvclcod
                                                ,a_cts00m20c[arr_aux].srrcoddig
                                                ,a_cts00m20c[arr_aux].lclltt
                                                ,a_cts00m20c[arr_aux].lcllgt
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
                                                      ,a_cts00m20c[arr_aux].socvclcod
                                                      ,a_cts00m20c[arr_aux].srrcoddig
                                                      ,a_cts00m20c[arr_aux].lclltt
                                                      ,a_cts00m20c[arr_aux].lcllgt
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
        let ws.flag_cts00m02 = 1           ---- ruiz
        #psi179345

        if param.tipo_demanda is not null then

            let g_documento.atdprscod = a_cts00m20c[arr_aux].atdprscod
            let g_documento.atdvclsgl = a_cts00m20c[arr_aux].atdvclsgl
            let g_documento.srrcoddig = a_cts00m20c[arr_aux].srrcoddig
            let g_documento.socvclcod = a_cts00m20c[arr_aux].socvclcod
            let g_documento.lclltt    = a_cts00m20c[arr_aux].lclltt
            let g_documento.lcllgt    = a_cts00m20c[arr_aux].lcllgt

            call cts00m00(ws.atdsrvorg
                         ,''
                         ,param.tipo_demanda
                         ,g_documento.lclltt
                         ,g_documento.lcllgt
                         ,a_cts00m20c[arr_aux].cidnom_gps
                         ,d_cts00m20.vcldtbgrpcod
                         ,a_cts00m20c[arr_aux].srrcoddig,
                         '')

            open c_cts00m20_004 using g_documento.socvclcod

            whenever error continue
            fetch c_cts00m20_004 into lr_frota.*
            whenever error stop

            if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode <> 100 then
                    error 'Problemas de acesso a tabela DATTFROTALOCAL, ',
                           sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                    error 'cts00m20()', g_documento.socvclcod sleep 2
                    exit while
                end if
            else
                if lr_frota.atdsrvnum is null then

                    let l_socacsflg = '0'
                    let l_c24opemat = null
                    let l_c24opeempcod = null
                    let l_c24opeusrtip = null
                    execute p_cts00m20_004 using l_socacsflg
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
            continue while

        else

            # -- CT 257958 - Katiucia -- #
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
            let ws.nometxt = "~/ACN", param.atdsrvnum using "&&&&&&&" , ".txt"

            # Inclui indicacao no arquivo temporario
            let ws.linha   = "Espelho do acionamento"
            let ws.executa = 'echo "', ws.linha clipped, '" > ', ws.nometxt
            run ws.executa

            # Carrega no arquivo temporario os dados das viaturas ate a selecionada
            for ws_cont = 1 to arr_aux

                let ws.linha   = "Veiculo:",a_cts00m20c[ws_cont].atdvclsgl
                                ," ",a_cts00m20c[ws_cont].c24atvcod
                                ," ",a_cts00m20c[ws_cont].socvclcod
                                ," ",a_cts00m20c[ws_cont].socvcltipdes
                                ," ",a_cts00m20c[ws_cont].vcleqpdes
                let ws.executa = 'echo "', ws.linha clipped, '" >> ', ws.nometxt
                run ws.executa

                let ws.linha   = "Socorr.: ",a_cts00m20c[ws_cont].srrcoddig
                                ," ",a_cts00m20c[ws_cont].srrabvnom
                                ," ",a_cts00m20c[ws_cont].srrasides
                let ws.executa = 'echo "', ws.linha clipped, '" >> ', ws.nometxt
                run ws.executa

                let ws.linha   = "G.P.S .: ",a_cts00m20c[ws_cont].ufdcod_gps
                                ," ",a_cts00m20c[ws_cont].cidnom_gps
                                ," ",a_cts00m20c[ws_cont].brrnom_gps
                                ," ",a_cts00m20c[ws_cont].endzon_gps
                let ws.executa = 'echo "', ws.linha clipped, '" >> ', ws.nometxt
                run ws.executa

                let ws.linha   = "OBS ...: ",a_cts00m20c[ws_cont].obspostxt
                                ,"  Sinal.: ",a_cts00m20c[ws_cont].espera
                                ,"  Dist: ",a_cts00m20c[ws_cont].dstqtd," Km"
                let ws.executa = 'echo "', ws.linha clipped, '" >> ', ws.nometxt
                run ws.executa

                let ws.linha   = ""
                let ws.executa = 'echo "', ws.linha clipped, '" >> ', ws.nometxt
                run ws.executa

            end for

            # Monta cabecalho do e-mail
            let ws.linha = "Justificativa acionamento SRV: "
                          , param.atdsrvnum using "&&&&&&&"
                          , "-", param.atdsrvano using "&&"

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
            let l_retorno = ctx22g00_envia_email("CTS00M20",
                                                 ws.linha,
                                                 ws.nometxt)
            if l_retorno <> 0 then
                if l_retorno <> 99 then
                    display "Erro ao envia email(ctx21g00)-",ws.nometxt
                else
                    display "Nao ha email cadastrado para o modulo CTS00M20 "
                end if
            end if

            # Grava justificativa no historico do servico
            call cts10g02_historico(param.atdsrvnum,
                                    param.atdsrvano,
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
         clear s_cts00m20[arr_aux].*
      end for
  end if
 end while

 close window  w_cts00m20
 let int_flag = false

 return a_cts00m20c[arr_aux].atdprscod,
        a_cts00m20c[arr_aux].atdvclsgl,
        a_cts00m20c[arr_aux].srrcoddig,
        a_cts00m20c[arr_aux].socvclcod,
        ws.prvcalc,
        a_cts00m20c[arr_aux].dstqtd,
        ws.flag_cts00m02

 end function  ###  cts00m20

#--------------------------------------------------------------------------
 function cts00m20_espera(param)
#--------------------------------------------------------------------------

 define param       record
    data            date,
    hora            datetime hour to second
 end record

 define hora        record
    atual           datetime hour to second,
    h24             datetime hour to second,
    espera          char (09)
 end record






#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  hora.*  to  null

        initialize  hora.*  to  null

 initialize hora.*  to null
 let hora.atual = time

 if param.data  =  today  then
    let hora.espera = hora.atual - param.hora
 else
    let hora.h24    = "23:59:59"
    let hora.espera = hora.h24 - param.hora
    let hora.h24    = "00:00:00"
    let hora.espera = hora.espera + (hora.atual - hora.h24) + "00:00:01"
 end if

 return hora.espera

 end function  ###  cts00m20_espera

 #-----------------------------------------#
function cts00m20_verif_auto(lr_param)
#-----------------------------------------#

  define lr_param         record
     atdsrvnum         like datmservico.atdsrvnum,
     atdsrvano         like datmservico.atdsrvano,
     ciaempcod         like datrvclemp.ciaempcod,
     asitipcod         like datmservico.asitipcod,
     socvclcod         like dattfrotalocal.socvclcod,
     dstqtd            dec  (8,4),
     srrcoddig         like dattfrotalocal.srrcoddig
  end record

  define la_equip     array[2000]  of  record
     soceqpcod         like datreqpvcl.soceqpcod,
     ims                 char(1),
     Dist                char(1)
  end record

  define  l_imsvlr      like abbmcasco.imsvlr,
	  l_eqpimsvlr   like datkvcleqp.eqpimsvlr,
	  l_eqpacndst   like datkvcleqp.eqpacndst,
	  l_eqpacndst_k dec(15,5),
	  l_soceqpcod   like datreqpvcl.soceqpcod,
          l_vclcoddig   like agetdecateg.vclcoddig,
	  l_rcfctgatu   like agetdecateg.rcfctgatu,
	  l_resultado   smallint,
	  l_mensagem    char(30),
	  l_confirma    char(1),
	  l_sql         char(4000),
	  l_sql_regra   char(2000),
	  l_data_atual  date,
          l_hora_atual  datetime hour to minute,
	  l_mens1       char(40),
	  l_mens2       char(40),
	  l_mens3       char(40),
	  l_mens4       char(40),
	  l_flagret     smallint,
	  l_flag_dist   char(1),
          l_flag_is     char(1),
          l_flag_cat    char(1),
	  ind           integer,
	  n             integer,
          teste   char(1)

  let l_imsvlr  = 0
  let l_flagret = 1
  let l_mens1   = null
  let l_mens2   = null
  let l_mens3   = null
  let l_mens4   = null

  initialize la_equip   to null

  #-------------------------
  # BUSCAR O CODIGO VEICULO
  #-------------------------

   call cts10g06_dados_servicos(17,lr_param.atdsrvnum, lr_param.atdsrvano)
            returning l_resultado, l_mensagem, l_vclcoddig

   if l_resultado <> 1 then
      let l_flagret =   0
   end if

   if l_vclcoddig is not null and l_flagret = 1 then
     #------------------------------
     # BUSCAR A DATA E HORA DO BANCO
     #------------------------------
      call cts40g03_data_hora_banco(2)
                returning l_data_atual,
                          l_hora_atual

      #-------------------------------------
      # OBTER IS DA APOLICE
      #-------------------------------------

       call cts40g26_obter_is_apol( lr_param.atdsrvnum,
                                    lr_param.atdsrvano,
                                    lr_param.ciaempcod)
                    returning l_resultado, l_mensagem, l_imsvlr

       if l_imsvlr is not null then

      #-------------------------------------
      # BUSCAR CATEGORIA TARIFARIA SEGURADO
      #-------------------------------------

          call cty05g03_pesq_catgtf(l_vclcoddig,l_data_atual)
                       returning l_resultado, l_mensagem, l_rcfctgatu

          if l_rcfctgatu is not null then

             --- Informacoes do Veiculo do Segurado

             let l_sql_regra = cts40g13_regra_eqp(l_rcfctgatu,
                                                  l_vclcoddig,
                                                  lr_param.atdsrvnum,
                                                  lr_param.atdsrvano,
                                                  lr_param.asitipcod)

             --- informacoes do veiculo do socorrista

             let l_sql = " select d.soceqpcod  ",
                         " from datreqpvcl  d",
                         " where d.socvclcod = ",lr_param.socvclcod, " ",
                         l_sql_regra clipped

             prepare p_cts00m20_013 from l_sql
             declare c_cts00m20_012 cursor with hold for p_cts00m20_013

             let l_flag_cat  = 0
	     let ind         = 1
             open c_cts00m20_012
             foreach  c_cts00m20_012 into  la_equip[ind].soceqpcod

               let la_equip[ind].dist = 0
	       let la_equip[ind].ims  = 0

               ## obter eqps do veiculo do socorrista
               call ctd13g00_dados_eqp(1,la_equip[ind].soceqpcod)
                      returning l_resultado, l_mens2, l_eqpacndst, l_eqpimsvlr

                  ## distancia = 999 flag para nao comparar distancia
               if lr_param.dstqtd <> 9999 then
                  ## se dist. do srv > que dist do eqp, desprezar veiculo
                  if l_resultado is null then
                     ## Converte metros p/km.
                     let l_eqpacndst_k  = l_eqpacndst / 1000
                     if l_eqpacndst_k is not null and l_eqpacndst_k <> 0 then
                        if lr_param.dstqtd > l_eqpacndst_k then
	   		   let la_equip[ind].dist = 1
                        end if
                     end if
                  end if
               end if

               ## se l_imsvlr da apolice > que do eqp, desprezar veiculo
               if l_imsvlr is not null and l_imsvlr <> 0 then
                  if l_eqpimsvlr is not null and l_eqpimsvlr <> 0 then
                     if l_imsvlr > l_eqpimsvlr then
			let la_equip[ind].ims  = 1
                     end if
                  end if
               end if

	       let ind = ind + 1

             end foreach

             if ind > 1 then
                let l_flag_dist = 'N'
                let l_flag_is   = 'N'

                for n = 1 to 2000

                  if la_equip[n].soceqpcod is null then
                     exit for
                  end if

                  if la_equip[n].dist  = 0 then
                     let l_flag_dist = 'S'
                  end if

                  if la_equip[n].ims   = 0 then
                     let l_flag_is   = 'S'
                  end if
	        end for

                if l_flag_dist = 'N' then
                   let l_mens1 = 'Distancia do Prestador ' clipped
                end if
                if l_flag_is = 'N' then
		   if l_flag_dist = 'N' then
                     let l_mens2 = 'e Valor do IS segurado '
		    else
                     let l_mens2 = 'Valor do IS segurado '
                   end if
                end if
                if l_flag_is   = 'N' or
                   l_flag_dist = 'N' then
                   if l_flag_is   = 'N' and
                      l_flag_dist = 'N' then
                      let l_mens3 = 'Superam o limite cadastrado para equip.'
                    else
                      let l_mens3 = 'Supera o limite cadastrado para equip.'
                   end if
		end if
              else
                 let l_mens2 = 'Equipamento nao atende Categ. Tarifaria'
             end if
           else
              let l_mens2 = 'Equipamento nao atende Categ. Tarifaria'
          end if

          if (l_mens1 is not null or
              l_mens2 is not null or
              l_mens3 is not null) then
 	    let l_mens4= " Deseja continuar(S/N)?"
            call cts08g01("A", "S", l_mens1,l_mens2,l_mens3,l_mens4)
                         returning l_confirma
            let l_confirma = upshift (l_confirma)
            if l_confirma = "S" then
               let l_flagret =   1
             else
              let l_flagret =   0
            end if
          end if
       end if
   end if

  return l_flagret

end function
