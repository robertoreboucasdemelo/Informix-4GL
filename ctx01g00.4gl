#-----------------------------------------------------------------------------#
# Nome do Modulo: CTX01G00                                         Marcelo    #
#                                                                  Gilberto   #
# Calcula saldo de diarias de clausulas Carro Extra                Mar/1998   #
#-----------------------------------------------------------------------------#
# Alteracoes:                                                                 #
#                                                                             #
# DATA       SOLICITACAO RESPONSAVEL    DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 29/10/1998 PSI 6903-5  Gilberto       Incluir clausula 80 (Carro Extra p/   #
#                                       taxistas), nos moldes clausula  26    #
#-----------------------------------------------------------------------------#
# 11/11/1998 PSI 6471-8  Gilberto       Incluir clausula 26D (Carro Extra     #
#                                       Deficiente Fisico) para calculo de    #
#                                       saldo.                                #
#-----------------------------------------------------------------------------#
# 19/11/1998 ** ERRO **  Gilberto       Retirar a tabela DATKAVISVEIC do      #
#                                       'join' para evitar 'sequential scan  '#
#-----------------------------------------------------------------------------#
# 20/11/1998 PSI 7056-4  Gilberto       Alterar a pesquisa no cadastro de     #
#                                       veiculos que teve codigo da locado-   #
#                                       ra incluido na chave primaria.        #
#-----------------------------------------------------------------------------#
# 23/12/1998 ** ERRO **  Gilberto       Colocar clausula OUTER no 'join'      #
#                                       para evitar 'sequential scan'         #
#-----------------------------------------------------------------------------#
# 08/02/1999 PSI 7669-4  Wagner         Data do calculo para saldo de dias    #
#                                       foi alterado de (data atendimento)    #
#                                       para (data do sinistro).              #
#-----------------------------------------------------------------------------#
# 04/05/1999 PSI 7547-7  Wagner         Adaptacao leitura tabela de etapas    #
#                                       para verificacao do servico.          #
#-----------------------------------------------------------------------------#
# 08/07/1999 PSI 7547-7  Gilberto       Quebrado 'join' no acesso principal   #
#                                       pois estava ocorrendo 'sequential     #
#                                       scan' e tornando sistema lento.       #
#-----------------------------------------------------------------------------#
# 28/06/2000 PSI 10866-9 Wagner         Adaptacao nova numeracao servico.     #
#-----------------------------------------------------------------------------#
# 22/04/2003 PSI168920   Aguinaldo CostaResolucao 86                          #
#-----------------------------------------------------------------------------#
# 16/03/2004 OSF 33367   Teresinha S.   Inclusao do motivo 6                  #
# ----------------------------------------------------------------------------#
# 16/12/2006 psi 205206  Ruiz           Apurar saldo para empresa Azul        #
#-----------------------------------------------------------------------------#
# 03/11/2009             Carla Rampazzo Tratar novas clausulas do Carro Extra #
#                                       Livre Escolha: 58E-05dias / 58F-10dias#
#                                                      58G-15dias / 58H-30dias#
#----------------------------------------------------------------------------##
# 15/07/2010 Carla Rampazzo             Tratar novas clausulas do Carro Extra #
#                                       Referenciada : 58I -  7 dias          #
#                                                      58J - 15 dias          #
#                                                      58K - 15 dias          #
#                                                                             #
#                                       Livre Escolha: 58L -  7 dias          #
#                                                      58M - 15 dias          #
#                                                      58N - 15 dias          #
#-----------------------------------------------------------------------------#
# 11/06/2013 AS-2013-10854  Humberto Santos  Projeto Tapete Azul - benefícios #
#-----------------------------------------------------------------------------#
# 10/07/2013 Gabriel, Fornax P13070041   Inclusao da variavel param2.avialgmtv#
#                                        na chamada da funcao                 #
#                                        ctx01g01_claus_novo                  #
#-----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"
database porto

#------------------------------------------------------------------
 function ctx01g00_saldo(param)
#------------------------------------------------------------------

 define param      record
    succod         like abbmitem.succod      ,
    aplnumdig      like abbmitem.aplnumdig   ,
    itmnumdig      like abbmitem.itmnumdig   ,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    clcdat         date                      , ### Data para calculo do saldo
    clctip         smallint                  , ### (1)Normal/(2)So' confirmadas
    privez         smallint                  ,
    ciaempcod      like datmservico.ciaempcod
 end record

 define d_ctx01g00 record
    sldqtd         smallint
 end record

 initialize d_ctx01g00.*  to null

 if param.succod    is null  or
    param.aplnumdig is null  or
    param.itmnumdig is null  then
    return d_ctx01g00.*
 end if

 if param.clcdat    is null  then
    let param.clcdat = today
 end if

 if param.privez = true  then
    call ctx01g00_prepare()
 end if

 call ctx01g00_select(param.succod   ,
                      param.aplnumdig,
                      param.itmnumdig,
                      param.atdsrvnum,
                      param.atdsrvano,
                      param.clcdat   ,
                      param.clctip   ,
                      param.privez   ,
                      param.ciaempcod)
            returning d_ctx01g00.*

 return d_ctx01g00.*

end function  ###  ctx01g00_saldo

#------------------------------------------------------------------
 function ctx01g00_prepare()
#------------------------------------------------------------------

 define sql  char (1100)

#let sql = "select datmservico.atdsrvnum , datmservico.atdsrvano ,       ",
#          "       datmservico.atddat    , datmavisrent.lcvcod   ,       ",
#          "       datmavisrent.avivclcod, datmavisrent.aviprvent,       ",
#          "       datmavisrent.avialgmtv, datmavisrent.avioccdat        ",
#          "  from datrservapol, datmservico, outer datmavisrent         ",
#          " where datrservapol.succod     =  ?                       and",
#          "       datrservapol.ramcod     in (31,531)                and",
#          "       datrservapol.aplnumdig  =  ?                       and",
#          "       datrservapol.itmnumdig  =  ?                       and",
#          "       datmservico.atdsrvnum   = datrservapol.atdsrvnum   and",
#          "       datmservico.atdsrvano   = datrservapol.atdsrvano   and",
#          "       datmservico.atdsrvorg   =  8                       and",
#     ###  "       datmservico.atdfnlflg   = 'C'                      and",
#          "       datmservico.atdfnlflg   = 'S'                      and",
#          "       datmavisrent.atdsrvnum  = datmservico.atdsrvnum    and",
#          "       datmavisrent.atdsrvano  = datmservico.atdsrvano       "
#
#prepare sel_reservas from sql
#declare c_reservas cursor with hold for sel_reservas


	let	sql  =  null

 let sql = "select datmservico.atdsrvnum , datmservico.atdsrvano ,       ",
           "       datmservico.atddat    , datmservico.atdsrvorg ,       ",
           "       datmservico.atdfnlflg                                 ",
           "  from datrservapol, datmservico                             ",
           " where datrservapol.succod     =  ?                       and",
           "       datrservapol.ramcod     in (31,531)                and",
           "       datrservapol.aplnumdig  =  ?                       and",
           "       datrservapol.itmnumdig  =  ?                       and",
           "       datmservico.atdsrvnum   = datrservapol.atdsrvnum   and",
           "       datmservico.atdsrvano   = datrservapol.atdsrvano      "

 prepare p_ctx01g00_001 from sql
 declare c_ctx01g00_001 cursor with hold for p_ctx01g00_001

 let sql = "select datmavisrent.lcvcod   ,",
           "       datmavisrent.avivclcod,",
           "       datmavisrent.aviprvent,",
           "       datmavisrent.avialgmtv,",
           "       datmavisrent.avioccdat ",
           "  from datmavisrent           ",
           " where atdsrvnum = ?       and",
           "       atdsrvano = ?          "

 prepare p_ctx01g00_002 from sql
 declare c_ctx01g00_002 cursor with hold for p_ctx01g00_002

 let sql = "select avivclgrp    ",
           "  from datkavisveic ",
           " where lcvcod    = ?",
           "   and avivclcod = ?"

 prepare p_ctx01g00_003  from sql
 declare c_ctx01g00_003 cursor with hold for p_ctx01g00_003

 let sql = "select aviprodiaqtd, cctcod ",
           "  from datmprorrog          ",
           "  where atdsrvnum  =  ?  and",
           "        atdsrvano  =  ?  and",
           "        aviprostt  = 'A'    "

 prepare p_ctx01g00_004  from sql
 declare c_ctx01g00_004  cursor with hold for p_ctx01g00_004

 let sql = "select c24pagdiaqtd  ",
           "  from dblmpagto     ",
           " where atdsrvnum = ? ",
           "   and atdsrvano = ? "

 prepare p_ctx01g00_005 from sql
 declare c_ctx01g00_005 cursor with hold for p_ctx01g00_005

 let sql = "select atdetpcod    ",
           "  from datmsrvacp   ",
           " where atdsrvnum = ?",
           "   and atdsrvano = ?",
           "   and atdsrvseq = (select max(atdsrvseq)",
                               "  from datmsrvacp    ",
                               " where atdsrvnum = ? ",
                               "   and atdsrvano = ?)"

 prepare p_ctx01g00_006 from sql
 declare c_ctx01g00_006 cursor for p_ctx01g00_006

 let sql = "select socopgnum, c24pagdiaqtd ",
           "  from dbsmopgitm    ",
           " where atdsrvnum = ? ",
           "   and atdsrvano = ? "

 prepare p_ctx01g00_007 from sql
 declare c_ctx01g00_007 cursor with hold for p_ctx01g00_007

 let sql = "select socopgsitcod  ",
           "  from dbsmopg       ",
           " where socopgnum = ? "

 prepare p_ctx01g00_008 from sql
 declare c_ctx01g00_008 cursor with hold for p_ctx01g00_008

 let sql = ' select sum(diaqtd) from datmrsrsrvrsm ',
             ' where atdsrvnum = ? ',
             ' and atdsrvano =  ? ',
             ' and empcod > 0 ',
             ' and aviproseq in (select aviproseq from datmprorrog',
                                ' where atdsrvnum = ? ',
                                ' and atdsrvano = ? ',
                                ' and aviprostt = ?) '

   prepare p_ctx01g00_009 from sql
   declare c_ctx01g00_009 cursor for p_ctx01g00_009

end function  ###  ctx01g00_prepare

#------------------------------------------------------------------
 function ctx01g00_select(param)
#------------------------------------------------------------------

 define param      record
    succod         like abbmitem.succod      ,
    aplnumdig      like abbmitem.aplnumdig   ,
    itmnumdig      like abbmitem.itmnumdig   ,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    clcdat         date                      ,
    clctip         smallint                  ,
    privez         smallint                  ,
    ciaempcod      like datmservico.ciaempcod
 end record

 define ws         record
    atdsrvnum      like datmservico.atdsrvnum   ,
    atdsrvano      like datmservico.atdsrvano   ,
    atddat         like datmservico.atddat      ,
    atdsrvorg      like datmservico.atdsrvorg   ,
    atdfnlflg      like datmservico.atdfnlflg   ,
    viginc         like abbmclaus.viginc        ,
    vigfnl         like abbmclaus.vigfnl        ,
    lcvcod         like datkavisveic.lcvcod     ,
    avivclcod      like datkavisveic.avivclcod  ,
    avivclgrp      like datkavisveic.avivclgrp  ,
    aviprvent      like datmavisrent.aviprvent  ,
    aviprodiaqtd   array[2] of like datmprorrog.aviprodiaqtd,
    algdiaqtd      like dblmpagto.c24pagdiaqtd  ,
    clscod         like abbmclaus.clscod        ,
    sldqtd         like datmavisrent.aviprvent  ,
    diaqtd         like datmavisrent.aviprvent  ,
    avialgmtv      like datmavisrent.avialgmtv  ,
    avioccdat      like datmavisrent.avioccdat  ,
    atdetpcod      like datmsrvacp.atdetpcod    ,
    socopgnum      like dbsmopg.socopgnum       ,
    socopgsitcod   like dbsmopg.socopgsitcod    ,
    c24pagdiaqtd   like dbsmopgitm.c24pagdiaqtd ,
    flgsaldo       smallint                     ,
    temcls         smallint
 end record

 initialize ws.*     to null

 let ws.sldqtd  =  0
 let ws.diaqtd  =  0

 if param.ciaempcod <> 35 then
    call ctx01g01_claus(param.succod, param.aplnumdig, param.itmnumdig,
                        param.clcdat, param.privez)
              returning ws.clscod, ws.viginc, ws.vigfnl
    case ws.clscod
       when "26A"  let ws.sldqtd = 15
       when "26B"  let ws.sldqtd = 30
       when "26C"  let ws.sldqtd = 07
       when "26D"  let ws.sldqtd = 07  ### Deficiente Fisico
       when "26E"  let ws.sldqtd = 07  ## psi201154
       when "26F"  let ws.sldqtd = 30  ## psi201154
       when "26G"  let ws.sldqtd = 07  ## psi201154
       when "80A"  let ws.sldqtd = 15
       when "80B"  let ws.sldqtd = 30
       when "80C"  let ws.sldqtd = 07  --varani
       when "033"  let ws.sldqtd = 07
       when "33R"  let ws.sldqtd = 07
       when "046"  let ws.sldqtd = 07  -- Alberto
       when "46R"  let ws.sldqtd = 07  -- Alberto
       when "047"  let ws.sldqtd = 07  -- Alberto
       when "47R"  let ws.sldqtd = 07  -- Alberto
       when "26H"  let ws.sldqtd = 15  # Carro Extra Medio Porte
       when "26I"  let ws.sldqtd = 30  # Carro Extra Medio Porte
       when "26J"  let ws.sldqtd = 07  # Carro Extra Medio Porte
       when "26K"  let ws.sldqtd = 07  # Carro Extra Medio Porte
       when "26L"  let ws.sldqtd = 15  # Carro Extra Medio Porte
       when "26M"  let ws.sldqtd = 30  # Carro Extra Medio Porte
       otherwise
          initialize ws.sldqtd  to null
          return ws.sldqtd
    end case
 end if
 if param.ciaempcod = 35 then
    call cts44g01_claus_azul(param.succod,
                             531         ,
                             param.aplnumdig,
                             param.itmnumdig)
            returning ws.temcls,ws.clscod
    case ws.clscod
       when "58A"  let ws.sldqtd = 05  ---> Rede Referenciada
       when "58B"  let ws.sldqtd = 10  --->   "      "
       when "58C"  let ws.sldqtd = 15  --->   "      "
       when "58D"  let ws.sldqtd = 30  --->   "      "

       when "58E"  let ws.sldqtd = 05  ---> Livre Escolha
       when "58F"  let ws.sldqtd = 10  --->   "      "
       when "58G"  let ws.sldqtd = 15  --->   "      "
       when "58H"  let ws.sldqtd = 30  --->   "      "

       when "58I"  let ws.sldqtd = 07  ---> Rede Referenciada - Tarifa Ago/2010
       when "58J"  let ws.sldqtd = 15  --->   "      "
       when "58K"  let ws.sldqtd = 30  --->   "      "

       when "58L"  let ws.sldqtd = 07  ---> Livre Escolha - Tarifa Ago/2010
       when "58M"  let ws.sldqtd = 15  --->   "      "
       when "58N"  let ws.sldqtd = 30  --->   "      "


       otherwise
          initialize ws.sldqtd  to null
          return ws.sldqtd
    end case
 end if

 call ctx01g00_calc_saldo(param.*,ws.sldqtd,
                          ws.clscod, ws.viginc, ws.vigfnl,"")
      returning ws.sldqtd

 return ws.sldqtd

end function

#------------------------------------------------------------------
 function ctx01g00_saldo_novo(param, param2)
#------------------------------------------------------------------

 define param      record
    succod         like abbmitem.succod      ,
    aplnumdig      like abbmitem.aplnumdig   ,
    itmnumdig      like abbmitem.itmnumdig   ,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    clcdat         date                      , ### Data para calculo do saldo
    clctip         smallint                  , ### (1)Normal/(2)So' confirmadas
    privez         smallint                  ,
    ciaempcod      like datmservico.ciaempcod
 end record

 define param2     record
    avialgmtv      like datmavisrent.avialgmtv,
    c24astcod      like datkassunto.c24astcod
 end record

 define d_ctx01g00 record
    limite         integer,
    sldqtd         smallint
 end record

 initialize d_ctx01g00.*  to null

 if param.succod    is null  or
    param.aplnumdig is null  or
    param.itmnumdig is null  then
    return d_ctx01g00.*
 end if

 if param.clcdat    is null  then
    let param.clcdat = today
 end if

 if param.privez = true  then
    call ctx01g00_prepare()
 end if

 call ctx01g00_select_novo(param.succod   ,
                           param.aplnumdig,
                           param.itmnumdig,
                           param.atdsrvnum,
                           param.atdsrvano,
                           param.clcdat   ,
                           param.clctip   ,
                           param.privez   ,
                           param.ciaempcod,
                           param2.*)
       returning d_ctx01g00.*

 return d_ctx01g00.*

end function  ###  ctx01g00_saldo

#------------------------------------------------------------------
 function ctx01g00_select_novo(param, param2)
#------------------------------------------------------------------

 define param      record
    succod         like abbmitem.succod      ,
    aplnumdig      like abbmitem.aplnumdig   ,
    itmnumdig      like abbmitem.itmnumdig   ,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    clcdat         date                      ,
    clctip         smallint                  ,
    privez         smallint                  ,
    ciaempcod      like datmservico.ciaempcod
 end record

 define param2     record
    avialgmtv      like datmavisrent.avialgmtv,
    c24astcod      like datkassunto.c24astcod
 end record

 define ws         record
    atdsrvnum      like datmservico.atdsrvnum   ,
    atdsrvano      like datmservico.atdsrvano   ,
    atddat         like datmservico.atddat      ,
    atdsrvorg      like datmservico.atdsrvorg   ,
    atdfnlflg      like datmservico.atdfnlflg   ,
    viginc         like abbmclaus.viginc        ,
    vigfnl         like abbmclaus.vigfnl        ,
    lcvcod         like datkavisveic.lcvcod     ,
    avivclcod      like datkavisveic.avivclcod  ,
    avivclgrp      like datkavisveic.avivclgrp  ,
    aviprvent      like datmavisrent.aviprvent  ,
    aviprodiaqtd   array[2] of like datmprorrog.aviprodiaqtd,
    algdiaqtd      like dblmpagto.c24pagdiaqtd  ,
    clscod         like abbmclaus.clscod        ,
    sldqtd         like datmavisrent.aviprvent  ,
    diaqtd         like datmavisrent.aviprvent  ,
    avialgmtv      like datmavisrent.avialgmtv  ,
    avioccdat      like datmavisrent.avioccdat  ,
    atdetpcod      like datmsrvacp.atdetpcod    ,
    socopgnum      like dbsmopg.socopgnum       ,
    socopgsitcod   like dbsmopg.socopgsitcod    ,
    c24pagdiaqtd   like dbsmopgitm.c24pagdiaqtd ,
    flgsaldo       smallint                     ,
    temcls         smallint
 end record

 define l_lim integer

 let l_lim = 0 ## limite de diarias por motivo/assunto e clausula

 initialize ws.*     to null

 let ws.sldqtd  =  0
 let ws.diaqtd  =  0

 if param.ciaempcod <> 35 then
    call ctx01g01_claus_novo(param.succod, param.aplnumdig, param.itmnumdig,
                             param.clcdat, param.privez, param2.avialgmtv)
              returning ws.clscod, ws.viginc, ws.vigfnl
    if ws.clscod[1,2] = '26' then
       if cty31g00_nova_regra_clausula(param2.c24astcod) then
          call cty31g00_valida_diaria(param2.c24astcod ,
                                      ws.clscod        ,
                                      g_nova.perfil    ,
                                      param2.avialgmtv )
          returning l_lim
       else

           if param2.avialgmtv = 1 then
              case ws.clscod
                when "26A"  let l_lim     = 15
                when "26B"  let l_lim     = 30
                when "26C"  let l_lim     = 07

                when "26D"  let l_lim     = 07  ### Deficiente Fisico
                when "26E"  let l_lim     = 07  ## psi201154
                when "26F"  let l_lim     = 30  ## psi201154
                when "26G"  let l_lim     = 07  ## psi201154

                when "26H"  let l_lim     = 15  # Carro Extra Medio Porte
                when "26I"  let l_lim     = 30  # Carro Extra Medio Porte
                when "26J"  let l_lim     = 07  # Carro Extra Medio Porte
                when "26K"  let l_lim     = 07  # Carro Extra Medio Porte
                when "26L"  let l_lim     = 15  # Carro Extra Medio Porte
                when "26M"  let l_lim     = 30  # Carro Extra Medio Porte
              end case
           end if

           if (param2.avialgmtv = 3 and param2.c24astcod = "H10")   or
              (param2.avialgmtv = 6 and param2.c24astcod = "H11")   or
              (param2.avialgmtv = 8 and param2.c24astcod = "H10")   then
               let l_lim = 07
           end if

           if (param2.avialgmtv = 3 and param2.c24astcod = "H12")   or
              (param2.avialgmtv = 6 and param2.c24astcod = "H13")   then
               let l_lim = 15
           end if
           
       end if
   end if

   if ws.clscod = "034"  then

      if cty31g00_nova_regra_clausula(param2.c24astcod) then
         call cty31g00_valida_diaria(param2.c24astcod ,
                                     ws.clscod        ,
                                     g_nova.perfil    ,
                                     param2.avialgmtv )
         returning l_lim
      else
         if (param2.avialgmtv = 2 and param2.c24astcod = "H10") or
            (param2.avialgmtv = 3 and param2.c24astcod = "H10") or
            (param2.avialgmtv = 6 and param2.c24astcod = "H11") or
            (param2.avialgmtv = 9 and
            ( param2.c24astcod = "H10" or param2.c24astcod = "H12" ) ) then
            let l_lim = 07
         end if

         if (param2.avialgmtv = 3 and param2.c24astcod = "H12") or
            (param2.avialgmtv = 6 and param2.c24astcod = "H13") then
            let l_lim = 15
         end if
      end if
   end if


   if ws.clscod = "33R"  then

      if cty31g00_nova_regra_clausula(param2.c24astcod) then
         call cty31g00_valida_diaria(param2.c24astcod ,
                                     ws.clscod        ,
                                     g_nova.perfil    ,
                                     param2.avialgmtv )
         returning l_lim
      else
         if (param2.avialgmtv = 2 and param2.c24astcod = "H10") or
            (param2.avialgmtv = 3 and param2.c24astcod = "H10") or
            (param2.avialgmtv = 6 and param2.c24astcod = "H11") or
            (param2.avialgmtv = 9 and
                    (param2.c24astcod = "H10" or
                     param2.c24astcod = "H12"   ) ) then
            let l_lim = 07
         end if

         if (param2.avialgmtv = 3 and param2.c24astcod = "H12") or
            (param2.avialgmtv = 6 and param2.c24astcod = "H13") then
            let l_lim = 15
         end if
      end if
   else
      if ws.clscod[1,2] = '33' or ws.clscod = '033' then
      	 if cty31g00_nova_regra_clausula(param2.c24astcod) then
      	    call cty31g00_valida_diaria(param2.c24astcod ,
      	                                ws.clscod        ,
      	                                g_nova.perfil    ,
      	                                param2.avialgmtv )
      	    returning l_lim
      	 else

           if (param2.avialgmtv = 0 and (param2.c24astcod = "H10" or
                                         param2.c24astcod = "H12"   )) or
              (param2.avialgmtv =14 and (param2.c24astcod = "H10" or
                                         param2.c24astcod = "H12"   )) then
               let l_lim =  999
           end if

           if (param2.avialgmtv = 2 and param2.c24astcod = "H10")      or
              (param2.avialgmtv = 3 and param2.c24astcod = "H10")      or
              (param2.avialgmtv = 6 and param2.c24astcod = "H11")      or
              (param2.avialgmtv = 7 and (param2.c24astcod = "H11" or
                                         param2.c24astcod = "H13"   )) or
              (param2.avialgmtv = 8 and param2.c24astcod = "H10")      then
              let l_lim = 07
           end if

           if (param2.avialgmtv = 3 and param2.c24astcod = "H12")   or
              (param2.avialgmtv = 6 and param2.c24astcod = "H13")   then
              let l_lim = 15
           end if

           if (param2.avialgmtv =13 and (param2.c24astcod = "H10" or
                                         param2.c24astcod = "H12"   )) then
              let l_lim = 30
           end if

         end if
      end if
   end if

   if ws.clscod[1,2] = "35"  or ws.clscod = '035' then
      if cty31g00_nova_regra_clausula(param2.c24astcod) then
         call cty31g00_valida_diaria(param2.c24astcod ,
                                     ws.clscod        ,
                                     g_nova.perfil    ,
                                     param2.avialgmtv )
         returning l_lim
      else
         if (param2.avialgmtv = 3 and param2.c24astcod = "H10")   or
            (param2.avialgmtv = 6 and param2.c24astcod = "H11")   then
            let l_lim = 07
         end if

         if (param2.avialgmtv = 3 and param2.c24astcod = "H12")   or
            (param2.avialgmtv = 6 and param2.c24astcod = "H13")   then
            let l_lim = 15
         end if
         if (param2.avialgmtv = 21 and param2.c24astcod = "H10")   or
            (param2.avialgmtv = 21 and param2.c24astcod = "H12")   then
            let l_lim = 15
         end if
                                 
      end if  
   end if

   if ws.clscod[1,2] = "46" or ws.clscod = '046' or
      ws.clscod[1,2] = "47" or ws.clscod = '047' then
      if (param2.avialgmtv = 2 and param2.c24astcod = "H10")   or
         (param2.avialgmtv = 3 and param2.c24astcod = "H10")   or
         (param2.avialgmtv = 6 and param2.c24astcod = "H11")   then
          let l_lim = 07
      end if

      if (param2.avialgmtv = 3 and param2.c24astcod = "H12")   or
         (param2.avialgmtv = 6 and param2.c24astcod = "H13")   then
         let l_lim = 15
      end if

      if ws.clscod <> '46R' and ws.clscod <> '47R' then
         if (param2.avialgmtv = 7 and (param2.c24astcod = "H11" or
                                       param2.c24astcod = "H13"  )) or
            (param2.avialgmtv = 8 and  param2.c24astcod = "H10")    then
            let l_lim = 07
         end if

         if (param2.avialgmtv =13 and (param2.c24astcod = "H10" or
                                       param2.c24astcod = "H12"  )) then
             let l_lim = 30
         end if

         if (param2.avialgmtv =14 and (param2.c24astcod = "H10" or
                                       param2.c24astcod = "H12"  )) then
             let l_lim = 999
         end if
      else
         if (param2.avialgmtv = 9 and (param2.c24astcod = "H10" or
                                       param2.c24astcod = "H12"  )) then
            let l_lim = 7
         end if
      end if
   end if

       #ligia ver o que fazer com isso
       #when "80A"  let ws.sldqtd = 15
       #when "80B"  let ws.sldqtd = 30
       #when "80C"  let ws.sldqtd = 07  --varani

    if not cty31g00_nova_regra_clausula(param2.c24astcod) then
       if (param2.avialgmtv = 4 and (param2.c24astcod = "H10" or
                                     param2.c24astcod = "H11" or
                                     param2.c24astcod = "H12" or
                                     param2.c24astcod = "H13" )) or
          (param2.avialgmtv = 5 and (param2.c24astcod = "H10" or
                                     param2.c24astcod = "H11" or
                                     param2.c24astcod = "H12" or
                                     param2.c24astcod = "H13" )) or
          (param2.avialgmtv = 20 and param2.c24astcod = "H10") then
          let l_lim = 999
       end if
    end if

    if ws.clscod[1,2] = "44" or ws.clscod = '044' or   ### JUNIOR(FORNAX)
       ws.clscod[1,2] = "48" or ws.clscod = '048' then
       call cty26g01_lim_cext(ws.clscod       ,
			      param2.avialgmtv,
			      param2.c24astcod)
            returning l_lim
    end if
 end if

 #falta implementar para a empresa AZul - ligia 25/05/11

 if param.ciaempcod = 35 then
    if param2.avialgmtv = 1 then

       call cts44g01_claus_azul(param.succod,
                                531         ,
                                param.aplnumdig,
                                param.itmnumdig)
               returning ws.temcls,ws.clscod
       case ws.clscod
          when "58A"  let l_lim     = 05  ---> Rede Referenciada
          when "58B"  let l_lim     = 10  --->   "      "
          when "58C"  let l_lim     = 15  --->   "      "
          when "58D"  let l_lim     = 30  --->   "      "

          when "58E"  let l_lim     = 05  ---> Livre Escolha
          when "58F"  let l_lim     = 10  --->   "      "
          when "58G"  let l_lim     = 15  --->   "      "
          when "58H"  let l_lim     = 30  --->   "      "

          when "58I"  let l_lim     = 07  ---> Rede Referenciada - Tarifa Ago/2010
          when "58J"  let l_lim     = 15  --->   "      "
          when "58K"  let l_lim     = 30  --->   "      "

          when "58L"  let l_lim     = 07  ---> Livre Escolha - Tarifa Ago/2010
          when "58M"  let l_lim     = 15  --->   "      "
          when "58N"  let l_lim     = 30  --->   "      "

          otherwise
             let l_lim = 0
             return l_lim, ws.sldqtd
       end case
    else
      if param.ciaempcod = 35 then
         if param2.avialgmtv = 3 then
            let l_lim     = 8
         else
            if param2.avialgmtv = 18 then
               let l_lim = 7
            end if
         end if
     else
         let l_lim = 999
      end if
    end if
 end if
 
  if (param2.avialgmtv = 21      or              
      param2.avialgmtv = 23      or    
      param2.avialgmtv = 24  )   and   
     (param2.c24astcod = "H10")  then   
       let l_lim = 15                   
  end if     
  
  if param2.avialgmtv = 20  then        
       let l_lim = 02                        
  end if                                                               
 

 if l_lim = 0 then
    return 0,0
 end if

 let ws.sldqtd = l_lim
 call ctx01g00_calc_saldo(param.*,ws.sldqtd,
                          ws.clscod, ws.viginc, ws.vigfnl,
			  param2.avialgmtv)
      returning ws.sldqtd

 if ws.sldqtd is null then
    let ws.sldqtd = l_lim
 end if

 return l_lim, ws.sldqtd

end function

#-------------------------------------------------------------------------
function ctx01g00_calc_saldo(param, param2)
#-------------------------------------------------------------------------

 define param      record
    succod         like abbmitem.succod      ,
    aplnumdig      like abbmitem.aplnumdig   ,
    itmnumdig      like abbmitem.itmnumdig   ,
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    clcdat         date                      , ### Data para calculo do saldo
    clctip         smallint                  , ### (1)Normal/(2)So' confirmadas
    privez         smallint                  ,
    ciaempcod      like datmservico.ciaempcod
 end record

 define param2     record
        saldo      like datmavisrent.aviprvent,
        clscod     like abbmclaus.clscod        ,
        viginc     like abbmclaus.viginc        ,
        vigfnl     like abbmclaus.vigfnl        ,
        avialgmtv  like datmavisrent.avialgmtv
 end record

 define ws         record
    atdsrvnum      like datmservico.atdsrvnum   ,
    atdsrvano      like datmservico.atdsrvano   ,
    atddat         like datmservico.atddat      ,
    atdsrvorg      like datmservico.atdsrvorg   ,
    atdfnlflg      like datmservico.atdfnlflg   ,
    viginc         like abbmclaus.viginc        ,
    vigfnl         like abbmclaus.vigfnl        ,
    lcvcod         like datkavisveic.lcvcod     ,
    avivclcod      like datkavisveic.avivclcod  ,
    avivclgrp      like datkavisveic.avivclgrp  ,
    aviprvent      like datmavisrent.aviprvent  ,
    aviprodiaqtd   array[2] of like datmprorrog.aviprodiaqtd,
    algdiaqtd      like dblmpagto.c24pagdiaqtd  ,
    clscod         like abbmclaus.clscod        ,
    sldqtd         like datmavisrent.aviprvent  ,
    diaqtd         like datmavisrent.aviprvent  ,
    avialgmtv      like datmavisrent.avialgmtv  ,
    avioccdat      like datmavisrent.avioccdat  ,
    atdetpcod      like datmsrvacp.atdetpcod    ,
    socopgnum      like dbsmopg.socopgnum       ,
    socopgsitcod   like dbsmopg.socopgsitcod    ,
    c24pagdiaqtd   like dbsmopgitm.c24pagdiaqtd ,
    flgsaldo       smallint                     ,
    temcls         smallint
 end record

 define l_stt char(1)
 let l_stt = null

 let ws.sldqtd = param2.saldo
 let ws.clscod = param2.clscod
 let ws.viginc = param2.viginc
 let ws.vigfnl = param2.vigfnl
 let ws.diaqtd  =  0

#-------------------------------------------------------------------------
# Reservas solicitadas
#-------------------------------------------------------------------------

 open    c_ctx01g00_001 using param.succod, param.aplnumdig, param.itmnumdig
 foreach c_ctx01g00_001 into  ws.atdsrvnum,
                             ws.atdsrvano,
                             ws.atddat   ,
                             ws.atdsrvorg,
                             ws.atdfnlflg

    if ws.atdsrvorg <>  8   then
       continue foreach
    end if

    if ws.atdfnlflg <> "S"  then
       continue foreach
    end if

#-------------------------------------------------------------------------
# Caso a reserva seja passada como parametro, nao considerar no calculo
#-------------------------------------------------------------------------

#ligia 26/05/11
    #if param.atdsrvnum is not null      and
    #   param.atdsrvano is not null      and
    #   param.atdsrvnum  = ws.atdsrvnum  and
    #   param.atdsrvano  = ws.atdsrvano  then
    #   continue foreach
    #end if

#------------------------------------------------------------
# Verifica etapa do servico
#------------------------------------------------------------
    open  c_ctx01g00_006 using ws.atdsrvnum, ws.atdsrvano,
                             ws.atdsrvnum, ws.atdsrvano
    fetch c_ctx01g00_006 into  ws.atdetpcod
    close c_ctx01g00_006

    if ws.atdetpcod <> 4 and
       ws.atdetpcod <> 1 then   # somente servico etapa concluida
       continue foreach
    end if

    open  c_ctx01g00_002 using ws.atdsrvnum,
                               ws.atdsrvano
    fetch c_ctx01g00_002 into  ws.lcvcod   ,
                               ws.avivclcod,
                               ws.aviprvent,
                               ws.avialgmtv,
                               ws.avioccdat
    if ws.avialgmtv = 4 or
       ws.avialgmtv = 5 then
       continue foreach
    end if

    #if ws.avialgmtv = 9 then
    #   let ws.sldqtd = 0
    #   return ws.sldqtd
    #end if

    if sqlca.sqlcode = notfound  then
       continue foreach
    end if

    close c_ctx01g00_002
    if param2.avialgmtv is not null then
       if param2.avialgmtv <> ws.avialgmtv then
	  continue foreach
       end if
    end if

{
    if param.ciaempcod <> 35 then
       if ws.avialgmtv  =  2   or          ### Reserva motivo SOCORRO
          ws.avialgmtv  =  3   or          ### Reserva motivo BENEF.OFICINA
          ws.avialgmtv  =  5   or          ### Reserva motivo PARTICULARES
          ws.avialgmtv  =  6   then        ### TERC.SEGPORTO
          ## Alberto ws.avialgmtv  =  9   then        ### Reserva motivo Ind.Integral
          continue foreach
       end if

       if ws.avioccdat > param.clcdat then   ### Reserva apos data de calculo
          continue foreach
       end if
    end if

    if ws.viginc is not null  then
       if ws.avioccdat < ws.viginc then  ### Reserva antes contratacao clausula
          continue foreach
       end if
    end if

    if ws.vigfnl is not null  then
       if ws.avioccdat > ws.vigfnl then  ### Reserva depois contratacao clausula
          continue foreach
       end if
    end if


    open  c_ctx01g00_003 using ws.lcvcod   ,
                          ws.avivclcod
    fetch c_ctx01g00_003 into  ws.avivclgrp
    close c_ctx01g00_003

    if ws.avivclgrp <> "A" and
       (ws.avialgmtv <> 1  and
        (ws.clscod <> "26H" and
         ws.clscod <> "26I" and
         ws.clscod <> "26J" and
         ws.clscod <> "26K" and
         ws.clscod <> "26L" and
         ws.clscod <> "26M" )) then ### Reserva com veiculo NAO BASICO
       continue foreach
    end if

} #ligia 31/05/11
#-------------------------------------------------------------------------
# Prorrogacoes solicitadas
#-------------------------------------------------------------------------

    #select sum(aviprodiaqtd)
    #  into ws.aviprodiaqtd[1]       # Prorrogacoes do segurado
    #  from datmprorrog
    # where atdsrvnum = ws.atdsrvnum
    #   and atdsrvano = ws.atdsrvano
    #   and aviprostt = "A"
    #   and cctcod    is null

    let l_stt = "A"
    open c_ctx01g00_009 using ws.atdsrvnum, ws.atdsrvano,
                              ws.atdsrvnum, ws.atdsrvano, l_stt
    fetch c_ctx01g00_009 into ws.aviprodiaqtd[1]
    close c_ctx01g00_009

    if ws.aviprodiaqtd[1] is null  then
       let ws.aviprodiaqtd[1] = 0
    end if

    let ws.aviprvent = ws.aviprvent + ws.aviprodiaqtd[1]

    select sum(aviprodiaqtd)
      into ws.aviprodiaqtd[2]       # Prorrogacoes do C.Cento
      from datmprorrog
     where atdsrvnum = ws.atdsrvnum
       and atdsrvano = ws.atdsrvano
       and aviprostt = "A"
       and cctcod    is not null

    if ws.aviprodiaqtd[2] is null  then
       let ws.aviprodiaqtd[2] = 0
    end if

#-------------------------------------------------------------------------
# Reservas confirmadas
#-------------------------------------------------------------------------

    initialize ws.algdiaqtd  to null

    let ws.flgsaldo = 0  # controle de baixa para apurar saldo

    open  c_ctx01g00_005  using  ws.atdsrvnum, ws.atdsrvano
    fetch c_ctx01g00_005  into   ws.algdiaqtd
    if sqlca.sqlcode = 0  then
       let ws.diaqtd   = ws.diaqtd + ws.algdiaqtd
       let ws.flgsaldo = 1
    end if
    close c_ctx01g00_005

    if ws.flgsaldo = 0 then
       open  c_ctx01g00_007   using ws.atdsrvnum, ws.atdsrvano
       foreach c_ctx01g00_007 into  ws.socopgnum, ws.c24pagdiaqtd
          open  c_ctx01g00_008 using ws.socopgnum
          fetch c_ctx01g00_008 into  ws.socopgsitcod
             if ws.socopgsitcod = 8  then   # OP ->CANCELADA
                # OP CANCELADA NAO ABATE SALDO
             else
                let ws.diaqtd   = ws.diaqtd + ws.c24pagdiaqtd
                                  - ws.aviprodiaqtd[2]   # (-)RESERVAS p/C.CUSTO
                let ws.flgsaldo = 1
             end if
          close c_ctx01g00_008
          if ws.flgsaldo = 1 then
             exit foreach
          end if
       end foreach
    end if


    if ws.flgsaldo = 0 then
       if param.clctip = 1  then
          let ws.diaqtd = ws.diaqtd + ws.aviprvent
       end if
    end if

 end foreach

 if ws.diaqtd > ws.sldqtd   then
    let ws.sldqtd = 0
 else
    let ws.sldqtd = ws.sldqtd - ws.diaqtd
 end if

 let int_flag = false

 return ws.sldqtd

end function  ###  ctx01g00_select
