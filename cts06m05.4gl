#############################################################################
# Nome do Modulo: CTS06M05                                            Pedro #
#                                                                   Marcelo #
# Relacao de Vistorias Previas Domiciliares                        Fev/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 06/04/1999  PSI 5591-3   Gilberto     Utilizacao dos campos padronizados  #
#                                       atraves do guia postal.             #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 16/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 26/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# --------   ------------- --------  ---------------------------------------#
# 19/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.             #
# 13/08/2009 Sergio Burini 244236    Inclusão do Sub-Dairro                 #
#---------------------------------------------------------------------------#
#############################################################################
# 27/09/2012  Raul Biztalking         Retirar empresa 1 fixa p/ funcionario #
#---------------------------------------------------------------------------#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define  wsg          record
    traco             char(80),
    aux_pipe          char(20),
    impr              char(08)
 end record

#---------------------------------------------------------------
 function cts06m05(param)
#---------------------------------------------------------------

 define param         record
    vstnumdig         like datmvistoria.vstnumdig
 end record

 define d_cts06m05    record
    vstdat            like datmvistoria.vstdat,
    succod            like datmvistoria.succod,
    vstc24tip         like datmvistoria.vstc24tip,
    vstnumdig         like datmvistoria.vstnumdig,
    dptsgl            like isskdepto.dptsgl
 end record

 define ws            record
    ok                integer,
    cont              dec(6,0),
    vstc24tip         like datmvistoria.vstc24tip,
    atdfnlflg         like datmservico.atdfnlflg,
    succod            like datmvistoria.succod,
    sucnom            like gabksuc.sucnom
 end record




	initialize  d_cts06m05.*  to  null

	initialize  ws.*  to  null

 initialize d_cts06m05.*   to null
 initialize ws.*           to null
 let d_cts06m05.vstnumdig  =  param.vstnumdig


 open window cts06m05 at 06,02 with form "cts06m05"
             attribute(form line first)

 input by name d_cts06m05.*   without defaults

     before field vstdat
        if d_cts06m05.vstnumdig  is not null   then
           next field vstnumdig
        end if
        display by name d_cts06m05.vstdat    attribute (reverse)

     after field vstdat
        display by name d_cts06m05.vstdat

        if d_cts06m05.vstdat  is null   then
           initialize d_cts06m05.vstc24tip  to null
           display by name d_cts06m05.vstc24tip
           next field vstnumdig
        end if

      before field succod
         display by name d_cts06m05.succod    attribute (reverse)

         let d_cts06m05.succod = g_issk.succod

         select sucnom  into  ws.sucnom
           from gabksuc
          where succod = d_cts06m05.succod
          display by name ws.sucnom

      after field succod
         display by name d_cts06m05.succod

         if d_cts06m05.succod  is null   then
            error " Sucursal deve ser informada!"
            next field succod
         end if

         select sucnom  into  ws.sucnom
           from gabksuc
          where succod = d_cts06m05.succod
          display by name ws.sucnom

         if g_issk.dptsgl  <>  "desenv"   then
            if d_cts06m05.succod  <>  g_issk.succod   then
               error " Nao devem ser impressas vistorias de outra sucursal!"
               next field succod
            end if
         end if

         let ws.cont = 0
         select count(*)  into  ws.cont
           from datmvistoria
          where vstdat  =  d_cts06m05.vstdat

         if ws.cont  =  0   then
            error " Nao existem vistorias marcadas para a data informada!"
            next field vstdat
         end if

     before field vstc24tip
        display by name d_cts06m05.vstc24tip attribute (reverse)

     after field vstc24tip
        if d_cts06m05.vstc24tip  is  null   then
           let d_cts06m05.vstc24tip = 0
        end if
        display by name d_cts06m05.vstc24tip

        if fgl_lastkey() = fgl_keyval("up")     or
           fgl_lastkey() = fgl_keyval("left")   then
           next field vstdat
        end if

        if ((d_cts06m05.vstc24tip  is null)  or
            (d_cts06m05.vstc24tip  <> 0      and
             d_cts06m05.vstc24tip  <> 1))    then
           error " Tipo da vistoria: (0)Volante ou (1)Central 24 Horas!"
           next field vstc24tip
        end if

#----------------------------------------------------
# Critica inibida em 30/07/1998 conforme PSI 57614
#----------------------------------------------------
#       if d_cts06m05.succod     <>  01   and
#          d_cts06m05.vstc24tip  <>  0    then
#          error " Tipo da vistoria somente (0)Volante!"
#          next field vstc24tip
#       end if

        initialize  wsg.aux_pipe, ws.ok, wsg.impr  to null

        call fun_print_seleciona (g_issk.dptsgl, "")
             returning  ws.ok, wsg.impr

        if ws.ok  =  0   then
           error " Departamento/Impressora nao cadastrada!"
           next field vstc24tip
        end if

        if wsg.impr  is null   then
           error " Uma impressora deve ser selecionada!"
           next field vstc24tip
        end if

        let wsg.aux_pipe = "lp -sd ", wsg.impr

        if cts08g01("C","S","","EMITE RELATORIO ?","","") = "S"  then
           call cts06m05r(d_cts06m05.vstdat,
                          d_cts06m05.vstc24tip,
                          d_cts06m05.vstnumdig)
        else
           let int_flag = false
        end if
        next field vstdat

     before field vstnumdig
        display by name d_cts06m05.vstnumdig attribute (reverse)

     after field vstnumdig
        display by name d_cts06m05.vstnumdig

        if fgl_lastkey() = fgl_keyval("up")     or
           fgl_lastkey() = fgl_keyval("left")   then
           initialize d_cts06m05.vstnumdig  to null
           display by name d_cts06m05.vstnumdig
           next field vstdat
        end if

        if d_cts06m05.vstdat     is null   and
           d_cts06m05.vstnumdig  is null   then
           error " Informe a data de realizacao ou o numero da vistoria!"
           next field vstnumdig
        end if

        initialize ws.vstc24tip, ws.atdfnlflg  to null
        select vstc24tip, atdfnlflg, succod
          into ws.vstc24tip, ws.atdfnlflg, ws.succod
          from datmvistoria, datmservico
         where datmvistoria.vstnumdig = d_cts06m05.vstnumdig
           and datmservico.atdsrvnum  = datmvistoria.atdsrvnum
           and datmservico.atdsrvano  = datmvistoria.atdsrvano

        if sqlca.sqlcode = notfound   then
           error " Vistoria Previa nao cadastrada!"
           next field vstnumdig
        end if

        if g_issk.dptsgl  <>  "desenv"   then
           if ws.succod  <>  g_issk.succod   then
              error " Nao devem ser impressas vistorias de outra sucursal!"
              next field vstnumdig
           end if
        end if

        if ws.vstc24tip  =  1   and
           ws.atdfnlflg  = "S"  then
           error " Vistoria Previa ja' acionada!"
           next field vstnumdig
        end if

        select datmvistoria.vstnumdig
          from datmvistoria, datmvstcanc
         where datmvistoria.vstnumdig = d_cts06m05.vstnumdig
           and datmvstcanc.atdsrvnum  = datmvistoria.atdsrvnum
           and datmvstcanc.atdsrvano  = datmvistoria.atdsrvano

        if sqlca.sqlcode <> notfound   then
           error " Vistoria Previa cancelada!"
           next field vstnumdig
        end if

     before field dptsgl
        display by name d_cts06m05.dptsgl  attribute (reverse)

     after field dptsgl
        display by name d_cts06m05.dptsgl

        if fgl_lastkey() = fgl_keyval("up")     or
           fgl_lastkey() = fgl_keyval("left")   then
           initialize d_cts06m05.dptsgl     to null
           display by name d_cts06m05.dptsgl
           next field vstnumdig
        end if

        if d_cts06m05.dptsgl  is null   then
           error " Informe nome do departamento para exibir impressoras!"
           next field dptsgl
        end if

        initialize  wsg.aux_pipe, ws.ok, wsg.impr  to null

        call fun_print_seleciona (d_cts06m05.dptsgl, "")
             returning  ws.ok, wsg.impr

        if ws.ok  =  0   then
           error " Departamento/Impressora nao cadastrada!"
           next field dptsgl
        end if

        if wsg.impr  is null   then
           error " Uma impressora deve ser selecionada!"
           next field dptsgl
        end if

        let wsg.aux_pipe = "lp -sd ", wsg.impr

        if cts08g01("C","S","","EMITE RELATORIO ?","","") = "S"  then
           message " Aguarde, gerando relatorio..." attribute (reverse)
           call cts06m05r(d_cts06m05.vstdat,
                          d_cts06m05.vstc24tip,
                          d_cts06m05.vstnumdig)
           message ""
        else
           let int_flag = false
           next field vstnumdig
        end if

     on key (interrupt)
        exit input

 end input

 close window cts06m05
 let int_flag = false

 end function   ###  cts06m05


#---------------------------------------------------------------
 function cts06m05r(param)
#---------------------------------------------------------------

 define param         record
   vstdat             like datmvistoria.vstdat,
   vstc24tip          like datmvistoria.vstc24tip,
   vstnumdig          like datmvistoria.vstnumdig
 end record

 define d_cts06m05    record
    vstnumdig         like datmvistoria.vstnumdig,
    atdsrvnum         like datmvistoria.atdsrvnum,
    atdsrvano         like datmvistoria.atdsrvano,
    atdsrvorg         like datmservico.atdsrvorg ,
    c24solnom         like datmvistoria.c24solnom,
    c24soltipcod      like datmvistoria.c24soltipcod,
    vstdat            like datmvistoria.vstdat   ,
    vstc24des         char (07)                  ,
    vstfld            like datmvistoria.vstfld   ,
    vstflddes         char (30)                  ,
    corsus            like gcaksusep.corsus      ,
    cornom            like gcakcorr.cornom       ,
    cordddcod         like datmvistoria.cordddcod,
    cortelnum         like datmvistoria.cortelnum,
    segnom            like gsakseg.segnom        ,
    pestip            like gsakseg.pestip        ,
    cgccpfnum         like datmvistoria.cgccpfnum,
    cgcord            like datmvistoria.cgcord   ,
    cgccpfdig         like datmvistoria.cgccpfdig,
    lclidttxt         like datmlcl.lclidttxt     ,
    lgdtxt            char (65)                  ,
    lgdtip            like datmlcl.lgdtip        ,
    lgdnom            like datmlcl.lgdnom        ,
    lgdnum            like datmlcl.lgdnum        ,
    brrnom            like datmlcl.brrnom        ,
    lclbrrnom         like datmlcl.lclbrrnom     ,
    endzon            like datmlcl.endzon        ,
    cidnom            like datmlcl.cidnom        ,
    ufdcod            like datmlcl.ufdcod        ,
    lgdcep            like datmlcl.lgdcep        ,
    lgdcepcmp         like datmlcl.lgdcepcmp     ,
    dddcod            like datmlcl.dddcod        ,
    lcltelnum         like datmlcl.lcltelnum     ,
    lclcttnom         like datmlcl.lclcttnom     ,
    lclrefptotxt      like datmlcl.lclrefptotxt  ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod  ,
    atdhorprg         like datmservico.atdhorprg ,
    atdatznom         like datmvistoria.atdatznom,
    vclmrcnom         like datmvistoria.vclmrcnom,
    vcltipnom         like datmvistoria.vcltipnom,
    vclmdlnom         like datmvistoria.vclmdlnom,
    vclcordes         char (11)                  ,
    vclanofbc         like datmvistoria.vclanofbc,
    vclanomdl         like datmvistoria.vclanomdl,
    vcllicnum         like datmvistoria.vcllicnum,
    vclchsnum         like datmvistoria.vclchsnum,
    atddat            like datmservico.atddat    ,
    atdhor            like datmservico.atdhor    ,
    dptsgl            like isskfunc.dptsgl       ,
    funmat            like isskfunc.funmat       ,
    funnom            like isskfunc.funnom
 end record

 define ws2           record
    privez            smallint,
    vclcorcod         like datmservico.vclcorcod ,
    vstc24tip         like datmvistoria.vstc24tip,
    atdfnlflg         like datmservico.atdfnlflg,
    comando1          char(1200),
    comando2          char(300),
    codesql           integer
 end record

 define l_empcod      like datmservico.empcod                         #Raul, Biz


	initialize  d_cts06m05.*  to  null

	initialize  ws2.*  to  null

 let wsg.traco  = "-------------------------------------------------------------------------------"
 initialize d_cts06m05.*  to null
 initialize ws2.*         to null

 let ws2.privez = true

 let ws2.comando1 = "select datmvistoria.vstc24tip, datmvistoria.corsus  ,",
                         " datmvistoria.segnom   , datmvistoria.pestip   ,",
                         " datmvistoria.cgccpfnum, datmvistoria.cgcord   ,",
                         " datmvistoria.cgccpfdig,                        ",
                         " datmvistoria.vclmrcnom, datmvistoria.vclmdlnom,",
                         " datmvistoria.vcltipnom, datmvistoria.vclanomdl,",
                         " datmvistoria.vclanofbc, datmvistoria.vcllicnum,",
                         " datmvistoria.vclchsnum, datmservico.vclcorcod ,",
                         " datmvistoria.vstfld   , datmvistoria.atdatznom,",
                         " datmvistoria.vstnumdig, datmvistoria.vstdat   ,",
                         " datmservico.atdhorprg ,                        ",
                         " datmvistoria.c24solnom, datmvistoria.c24soltipcod,",
                         " datmservico.atddat    , datmservico.atdhor    ,",
                         " datmservico.funmat    , datmservico.atdfnlflg ,",
                         " datmvistoria.atdsrvnum, datmvistoria.atdsrvano,",
                         " datmservico.atdsrvorg , datmvistoria.cornom   ,",
                         " datmvistoria.cordddcod, datmvistoria.cortelnum,",
                         " datmservico.empcod "                       #Raul, Biz

 if param.vstdat is not null  then
    let ws2.comando2 = " from datmvistoria, datmservico ",
                       "where datmvistoria.vstdat   = ? ",
                       "  and datmvistoria.succod   = ? ",
                       "  and datmservico.atdsrvnum = datmvistoria.atdsrvnum ",
                       "  and datmservico.atdsrvano = datmvistoria.atdsrvano "
 else
    let ws2.comando2 = " from datmvistoria, datmservico ",
                      "where datmvistoria.vstnumdig = ? ",
                      "  and datmservico.atdsrvnum = datmvistoria.atdsrvnum ",
                      "  and datmservico.atdsrvano = datmvistoria.atdsrvano "
 end if

 let ws2.comando1 = ws2.comando1 clipped," ", ws2.comando2
 prepare p_cts06m05_001  from       ws2.comando1
 declare c_cts06m05_001 cursor for p_cts06m05_001

 if param.vstdat is not null   then
    open c_cts06m05_001 using param.vstdat, g_issk.succod
 else
    open c_cts06m05_001 using param.vstnumdig
 end if

 start report  rep_vpdomiciliar

 foreach c_cts06m05_001 into ws2.vstc24tip       , d_cts06m05.corsus   ,
                         d_cts06m05.segnom   , d_cts06m05.pestip   ,
                         d_cts06m05.cgccpfnum, d_cts06m05.cgcord   ,
                         d_cts06m05.cgccpfdig,
                         d_cts06m05.vclmrcnom, d_cts06m05.vclmdlnom,
                         d_cts06m05.vcltipnom, d_cts06m05.vclanomdl,
                         d_cts06m05.vclanofbc, d_cts06m05.vcllicnum,
                         d_cts06m05.vclchsnum, ws2.vclcorcod       ,
                         d_cts06m05.vstfld   , d_cts06m05.atdatznom,
                         d_cts06m05.vstnumdig, d_cts06m05.vstdat   ,
                         d_cts06m05.atdhorprg,
                         d_cts06m05.c24solnom, d_cts06m05.c24soltipcod,
                         d_cts06m05.atddat   , d_cts06m05.atdhor   ,
                         d_cts06m05.funmat   , ws2.atdfnlflg        ,
                         d_cts06m05.atdsrvnum, d_cts06m05.atdsrvano,
                         d_cts06m05.atdsrvorg,
                         d_cts06m05.cornom   , d_cts06m05.cordddcod,
                         d_cts06m05.cortelnum, l_empcod     #Raul, Biz

    if param.vstdat is not null   then
       if param.vstc24tip   =  0   then
          if ws2.vstc24tip  <> 0   then
             continue foreach
          end if
       else
          if ws2.vstc24tip  =  0     then
             continue foreach
          end if
       end if
    end if

    select atdsrvnum from datmvstcanc
     where atdsrvnum = d_cts06m05.atdsrvnum
       and atdsrvano = d_cts06m05.atdsrvano

    if sqlca.sqlcode = 0  then
       continue foreach
    end if

    call ctx04g00_local_prepare(d_cts06m05.atdsrvnum,
                                d_cts06m05.atdsrvano,
                                1, ws2.privez)
                      returning d_cts06m05.lclidttxt,
                                d_cts06m05.lgdtip,
                                d_cts06m05.lgdnom,
                                d_cts06m05.lgdnum,
                                d_cts06m05.lclbrrnom,
                                d_cts06m05.brrnom,
                                d_cts06m05.cidnom,
                                d_cts06m05.ufdcod,
                                d_cts06m05.lclrefptotxt,
                                d_cts06m05.endzon,
                                d_cts06m05.lgdcep,
                                d_cts06m05.lgdcepcmp,
                                d_cts06m05.dddcod,
                                d_cts06m05.lcltelnum,
                                d_cts06m05.lclcttnom,
                                d_cts06m05.c24lclpdrcod,
                                ws2.codesql

    if ws2.codesql <> 0  then
       display " Erro (", ws2.codesql using "<<<<<&", ") na localizacao do endereco. AVISE A INFORMATICA!"
       exit program (1)
    end if

    if ws2.privez = true  then
       let ws2.privez = false
    end if

    let d_cts06m05.lgdtxt = d_cts06m05.lgdtip clipped, " ",
                            d_cts06m05.lgdnom clipped, " ",
                            d_cts06m05.lgdnum using "<<<<#"

    if ws2.vclcorcod is not null  then
      select cpodes into d_cts06m05.vclcordes
         from iddkdominio
        where cponom  =  "vclcorcod"    and
              cpocod  =  ws2.vclcorcod
    end if

    initialize d_cts06m05.vstc24des  to null
    if ws2.vstc24tip = 0  then
       let d_cts06m05.vstc24des = "VOLANTE"
   else
       if ws2.vstc24tip = 1  then
          if ws2.atdfnlflg = "S"  then
             continue foreach
          end if
          let d_cts06m05.vstc24des = "CENTRAL"
       end if
    end if

    initialize d_cts06m05.vstflddes  to null
    select cpodes into d_cts06m05.vstflddes
      from iddkdominio
     where cponom = "vstfld"
       and cpocod = d_cts06m05.vstfld

    let d_cts06m05.vstflddes = upshift(d_cts06m05.vstflddes)

    if d_cts06m05.corsus is not null  then
      initialize d_cts06m05.cornom  to null
       select cornom
         into d_cts06m05.cornom
         from gcaksusep, gcakcorr
        where gcaksusep.corsus   = d_cts06m05.corsus   and
              gcakcorr.corsuspcp = gcaksusep.corsuspcp
    end if

    initialize d_cts06m05.funnom  to null
    initialize d_cts06m05.dptsgl  to null

    select funnom, dptsgl
      into d_cts06m05.funnom, d_cts06m05.dptsgl
      from isskfunc
     where empcod = l_empcod                                          #Raul, Biz
       and funmat = d_cts06m05.funmat

    if sqlca.sqlcode = notfound   then
       let d_cts06m05.funnom = "NAO CADASTRADO"
    else
       let d_cts06m05.funnom = upshift(d_cts06m05.funnom)
    end if

    output to report rep_vpdomiciliar(param.vstdat, d_cts06m05.*)

 end foreach

 finish report rep_vpdomiciliar

 end function  ###  cts06m05

#---------------------------------------------------------------------------
 report rep_vpdomiciliar(par_vstdat, r_cts06m05)
#---------------------------------------------------------------------------

 define par_vstdat    like datmvistoria.vstdat

 define r_cts06m05    record
    vstnumdig         like datmvistoria.vstnumdig,
    atdsrvnum         like datmvistoria.atdsrvnum,
    atdsrvano         like datmvistoria.atdsrvano,
    atdsrvorg         like datmservico.atdsrvorg ,
    c24solnom         like datmvistoria.c24solnom ,
    c24soltipcod      like datmvistoria.c24soltipcod ,
    vstdat            like datmvistoria.vstdat   ,
    vstc24des         char (07)                  ,
    vstfld            like datmvistoria.vstfld   ,
    vstflddes         char (30)                  ,
    corsus            like gcaksusep.corsus      ,
    cornom            like gcakcorr.cornom       ,
    cordddcod         like datmvistoria.cordddcod,
    cortelnum         like datmvistoria.cortelnum,
    segnom            like gsakseg.segnom        ,
    pestip            like gsakseg.pestip        ,
    cgccpfnum         like datmvistoria.cgccpfnum,
    cgcord            like datmvistoria.cgcord   ,
    cgccpfdig         like datmvistoria.cgccpfdig,
    lclidttxt         like datmlcl.lclidttxt     ,
    lgdtxt            char (65)                  ,
    lgdtip            like datmlcl.lgdtip        ,
    lgdnom            like datmlcl.lgdnom        ,
    lgdnum            like datmlcl.lgdnum        ,
    brrnom            like datmlcl.brrnom        ,
    lclbrrnom         like datmlcl.lclbrrnom     ,
    endzon            like datmlcl.endzon        ,
    cidnom            like datmlcl.cidnom        ,
    ufdcod            like datmlcl.ufdcod        ,
    lgdcep            like datmlcl.lgdcep        ,
    lgdcepcmp         like datmlcl.lgdcepcmp     ,
    dddcod            like datmlcl.dddcod        ,
    lcltelnum         like datmlcl.lcltelnum     ,
    lclcttnom         like datmlcl.lclcttnom     ,
    lclrefptotxt      like datmlcl.lclrefptotxt  ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod  ,
    atdhorprg         like datmservico.atdhorprg ,
    atdatznom         like datmvistoria.atdatznom,
    vclmrcnom         like datmvistoria.vclmrcnom,
    vcltipnom         like datmvistoria.vcltipnom,
    vclmdlnom         like datmvistoria.vclmdlnom,
    vclcordes         char (11)                  ,
    vclanofbc         like datmvistoria.vclanofbc,
    vclanomdl         like datmvistoria.vclanomdl,
    vcllicnum         like datmvistoria.vcllicnum,
    vclchsnum         like datmvistoria.vclchsnum,
    atddat            like datmservico.atddat    ,
    atdhor            like datmservico.atdhor    ,
    dptsgl            like isskfunc.dptsgl       ,
    funmat            like isskfunc.funmat       ,
    funnom            like isskfunc.funnom
 end record

 define wsservico     char(13)
 define wssoltipdes   char(08)
 define wsobs         like datmservhist.c24srvdsc

 output report to pipe  wsg.aux_pipe
   left  margin  01
   right margin  80
   top   margin  01

order by r_cts06m05.vstc24des,
         r_cts06m05.vstnumdig

 format

   on every row
          select c24soltipdes
            into wssoltipdes
            from datksoltip
                 where c24soltipcod = r_cts06m05.c24soltipcod


        print column 001, wsg.traco
        print column 001, "PORTO SEGURO CIA. DE SEGUROS GERAIS",
              column 050, "CTS06M05",
              column 061, "PAGINA : ", pageno using "##,###,###"
        print column 061, "DATA   : ", today
        print column 017, "AGENDA DE VISTORIA PREVIA DOMICILIAR",
              column 061, "HORA   :   ", time
        print column 001, wsg.traco
        skip 1 line

        print column 001, "REALIZACAO..: ", r_cts06m05.vstdat,
              column 031, "SOLICITANTE.: ", r_cts06m05.c24solnom clipped,
                                      " (", wssoltipdes clipped, ")"
        skip 1 line

        print column 001, "VISTORIA....: ",
              r_cts06m05.vstnumdig using "#########",
              column 031, "FINALIDADE..: ", r_cts06m05.vstfld using "##",
              column 047, " - ", r_cts06m05.vstflddes
        skip 1 line

        print column 001, "VISTORIADOR.: ", r_cts06m05.vstc24des;
        if r_cts06m05.vstc24des = "CENTRAL"  then
           let wsservico =   r_cts06m05.atdsrvorg  using "&&",
                        "/", r_cts06m05.atdsrvnum  using "&&&&&&&",
                        "-", r_cts06m05.atdsrvano using "&&"
           print column 031, "No.SERVICO..: ", wsservico;
        end if
        print column 020, "     "
        skip 1 line

        print column 001, "CORRETOR....: ", r_cts06m05.corsus,
              column 020, " - ", r_cts06m05.cornom
        skip 1 line

        print column 001, "TELEFONE....: ",
              r_cts06m05.cordddcod, " ", r_cts06m05.cortelnum
        skip 1 line

        print column 001, "---------------------------  DADOS DO SEGURADO/LOCAL  -------------------------"
        skip 1 line

        print column 001, "NOME/RAZAO..: ", r_cts06m05.segnom
        skip 1 line

        print column 001, "CPF/CGC.....: ";
        if r_cts06m05.cgccpfnum is not null  then
           print r_cts06m05.cgccpfnum  using "############";
           if r_cts06m05.pestip  =  "J"   then
              print "/", r_cts06m05.cgcord   using "&&&&";
           end if
           print "-", r_cts06m05.cgccpfdig  using "&&";
        else
           print "CGC/CPF NAO INFORMADO" ;
        end if
        print column 048, "PESSOA..: ";
        if r_cts06m05.pestip = "F"  then
           print "FISICA"
        else
           print "JURIDICA"
        end if
        skip 1 line

        print column 001, "LOCAL.......: ", r_cts06m05.lgdtxt
        skip 1 line

        # PSI 244589 - Inclusão de Sub-Bairro - Burini
        call cts06g10_monta_brr_subbrr(r_cts06m05.brrnom,
                                       r_cts06m05.lclbrrnom)
             returning r_cts06m05.lclbrrnom
        print column 001, "BAIRRO......: ", r_cts06m05.lclbrrnom
        skip 1 line

        print column 001, "CIDADE......: ", r_cts06m05.cidnom  clipped ," - ",
                                            r_cts06m05.ufdcod
        skip 1 line

        print column 001, "REFERENCIA..: ", r_cts06m05.lclrefptotxt[1,40],
              column 048, "TELEFONE: "    , r_cts06m05.dddcod, " ",
                                            r_cts06m05.lcltelnum

        if r_cts06m05.lclrefptotxt[41,80] is not null then
           print column 015, r_cts06m05.lclrefptotxt[41,80]
        end if
        if r_cts06m05.lclrefptotxt[81,120] is not null then
           print column 015, r_cts06m05.lclrefptotxt[81,120]
        end if
        if r_cts06m05.lclrefptotxt[121,160] is not null then
           print column 015, r_cts06m05.lclrefptotxt[121,160]
        end if
        if r_cts06m05.lclrefptotxt[161,200] is not null then
           print column 015, r_cts06m05.lclrefptotxt[161,200]
        end if
        if r_cts06m05.lclrefptotxt[201,250] is not null then
           print column 015, r_cts06m05.lclrefptotxt[201,250]
        end if
        skip 1 line

        print column 001, "PROCURAR POR: ", r_cts06m05.lclcttnom,
              column 048, "HORARIO.: ",     r_cts06m05.atdhorprg
        skip 1 line

        if r_cts06m05.atdatznom is not null  then
           print column 001, "AUTORIZADO..: ", r_cts06m05.atdatznom
           skip 1 line
        end if

        print column 001, "-----------------------------  DADOS DO VEICULO  ------------------------------"
        skip 1 line

        print column 001, "MARCA.......: ", r_cts06m05.vclmrcnom,
              column 031, "TIPO..: "      , r_cts06m05.vcltipnom
        skip 1 line
        print column 001, "MODELO......: ", r_cts06m05.vclmdlnom
        skip 1 line

        print column 001, "ANO MOD/FAB.: ", r_cts06m05.vclanomdl, "/",
                                            r_cts06m05.vclanofbc,
              column 031, "COR...: "      , upshift(r_cts06m05.vclcordes)
        skip 1 line

        print column 001, "PLACA.......: ", r_cts06m05.vcllicnum,
              column 031, "CHASSI: ", r_cts06m05.vclchsnum
        skip 1 line

        print column 001, "--------------------------------  ATENDIMENTO  --------------------------------"
        skip 1 line

        print column 001, "ATENDENTE...: ", r_cts06m05.funmat using "&&&&&&",
              column 021, " - ",
              column 024, upshift(r_cts06m05.funnom),
              column 050, "DEPTO...: ", upshift(r_cts06m05.dptsgl)
        print column 001, "HORARIO.....: ", r_cts06m05.atddat,
                                    " AS ", r_cts06m05.atdhor
        skip 1 line

        print column 001, "--------------------------------  OBSERVACOES  --------------------------------"
        skip 1 line

        declare c_cts06m05obs  cursor for
           select c24srvdsc
             from datmservhist
            where atdsrvnum = r_cts06m05.atdsrvnum   and
                  atdsrvano = r_cts06m05.atdsrvano

        initialize wsobs  to null
        foreach c_cts06m05obs into wsobs
           print column 005, wsobs
        end foreach

        skip to top of page

end report  ###  rep_vistoria
