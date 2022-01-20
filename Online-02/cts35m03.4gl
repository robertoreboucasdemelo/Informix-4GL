#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS35M03                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ/RAJI JAHCHAN                           #
# PSI/OSF........: 201456                                                     #
#                  CARGA DA CONTINGENCIA PARA FURTO/ROUBO(F10)                #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR           ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 25/10/06   Ruiz            psi 201456 versao inicial                        #
#-----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

 define aux_ano2      char (02)
 define aux_ano4      char (04)
 define aux_today     char (10)
 define aux_hora      char (05)

#main
#  define ws record
#        atdsrvnum        like datmservico.atdsrvnum,
#        atdsrvano        like datmservico.atdsrvano,
#        sqlcode          integer                   ,
#        msg              char(300)
#  end record
#  initialize ws.* to null
#  call fun_dba_abre_banco("CT24HS")
#  set lock mode to wait 10
#  set isolation to dirty read
#
#  let g_issk.funmat = 601566
#  let g_issk.empcod = 1
#  let g_issk.usrtip = "F"
#  call startlog("cts35m03.log")
#  call cts35m03(13273,
#                601566,
#                "1",
#                "531",
#                "19214304",
#                "19",
#                5,
#                "1999",
#                1)
#       returning ws.msg,
#         ws.sqlcode,
#         ws.atdsrvnum,
#         ws.atdsrvano
#
#end main

------------------------------------------------------------------------------#
function cts35m03_prepare()
------------------------------------------------------------------------------#

  define l_cmd char(5000)

  --[ Tabela Interface de Servico ]--

  #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_cmd  =  null

  let l_cmd  =  null

  let l_cmd = "select seqreg "
             ," ,seqregcnt "
             ," ,atdsrvorg "
             ," ,atdsrvnum "
             ," ,atdsrvano "
             ," ,srvtipabvdes "
             ," ,atdnom "
             ," ,funmat "
             ," ,asitipabvdes "
             ," ,c24solnom "
             ," ,vcldes "
             ," ,vclanomdl "
             ," ,vclcor "
             ," ,vcllicnum "
             ," ,vclcamtip "
             ," ,vclcrgflg "
             ," ,vclcrgpso "
             ," ,atddfttxt "
             ," ,segnom "
             ," ,aplnumdig "
             ," ,cpfnum "
             ," ,ocrufdcod "
             ," ,ocrcidnom "
             ," ,ocrbrrnom "
             ," ,ocrlgdnom "
             ," ,ocrendcmp "
             ," ,ocrlclcttnom "
             ," ,ocrlcltelnum "
             ," ,ocrlclrefptotxt "
             ," ,dsttipflg "
             ," ,dstufdcod "
             ," ,dstcidnom "
             ," ,dstbrrnom "
             ," ,dstlgdnom "
             ," ,rmcacpflg "
             ," ,obstxt "
             ," ,srrcoddig "
             ," ,srrabvnom "
             ," ,atdvclsgl "
             ," ,atdprscod "
             ," ,nomgrr "
             ," ,atddat "
             ," ,atdhor "
             ," ,acndat "
             ," ,acnhor "
             ," ,acnprv "
             ," ,c24openom "
             ," ,c24opemat "
             ," ,pasnom1 "
             ," ,pasida1 "
             ," ,pasnom2 "
             ," ,pasida2 "
             ," ,pasnom3 "
             ," ,pasida3 "
             ," ,pasnom4 "
             ," ,pasida4 "
             ," ,pasnom5 "
             ," ,pasida5 "
             ," ,atldat "
             ," ,atlhor "
             ," ,atlmat "
             ," ,atlnom "
             ," ,cnlflg "
             ," ,cnldat "
             ," ,cnlhor "
             ," ,cnlmat "
             ," ,cnlnom "
             ," ,socntzcod "
             ," ,c24astcod "
             ," ,atdorgsrvnum "
             ," ,atdorgsrvano "
             ," ,srvtip "
             ," ,acnifmflg "
             ," ,dstsrvnum "
             ," ,dstsrvano "
             ," ,prcflg "
             ," ,ramcod "
             ," ,succod "
             ," ,itmnumdig "
             ," ,ocrlcldddcod "
             ," ,cpfdig "
             ," ,cgcord "
             ," ,ocrendzoncod "
             ," ,dstendzoncod "
             ," ,sindat "
             ," ,sinhor "
             ," ,bocnum "
             ," ,boclcldes "
             ," ,sinavstip "
             ," ,vclchscod "
             ," ,obscmptxt "
             ," ,crtsaunum "
             ," ,ciaempcod "
             ," ,atdnum    "
        ,"  from datmcntsrv "
       ,"  where seqreg = ?   "

  prepare p_cts35m03_001 from l_cmd
  declare c_cts35m03_001 cursor with hold for p_cts35m03_001

  let l_cmd = " insert into datmlcl(atdsrvnum, ",
                                  " atdsrvano, ",
                                  " c24endtip, ",
                                  " lclidttxt, ",
                                  " lgdtip, ",
                                  " lgdnom, ",
                                  " lgdnum, ",
                                  " lclbrrnom, ",
                                  " brrnom, ",
                                  " cidnom, ",
                                  " ufdcod, ",
                                  " lclrefptotxt, ",
                                  " endzon, ",
                                  " lgdcep, ",
                                  " lgdcepcmp, ",
                                  " lclltt, ",
                                  " lcllgt, ",
                                  " dddcod, ",
                                  " lcltelnum, ",
                                  " lclcttnom, ",
                                  " c24lclpdrcod, ",
                                  " ofnnumdig, ",
                                  " endcmp) ",
                                  " values (?,?,?,?,?,?,?,?,?,?,?, ",
                                          " ?,?,?,?,?,?,?,?,?,?,?,?) "

  prepare p_cts35m03_002 from l_cmd

  let l_cmd = " update datmcntsrv ",
                " set (dstsrvnum, dstsrvano, prcflg)= (?,?,'S') ",
               " where seqreg = ? "

  prepare p_cts35m03_003 from l_cmd

  let l_cmd = " insert into datmservicocmp (atdsrvnum, ",
                                  " atdsrvano, ",
                                  " c24sintip, ",
                                  " c24sinhor, ",
                                  " sindat,    ",
                                  " bocflg,    ",
                                  " bocnum,    ",
                                  " bocemi,    ",
                                  " vicsnh,    ",
                                  " sinhor)    ",
                                  " values (?,?,?,?,?,?,?,?,?,?) "
  prepare p_cts35m03_004 from l_cmd
  let l_cmd = "  select ligdat   , ",
              "         lighorinc, ",
              "         c24txtseq, ",
              "         c24srvdsc  ",
              " from datmservhist  ",
              " where atdsrvnum =? ",
              " and   atdsrvano =? ",
              " order by ligdat   ,",
              "          lighorinc,",
              "          c24txtseq "
  prepare pcts35m03007 from l_cmd
  declare ccts35m03007 cursor with hold for pcts35m03007

end function
---------------------------------------------------------------------------#
function cts35m03(param)
---------------------------------------------------------------------------#
   define param           record
          seqreg          like datmcntsrv.seqreg,
          funmat          like datmcntsrv.funmat,
          c24opemat       like datmcntsrv.c24opemat,
          succod          like datrservapol.succod,
          ramcod          like datrservapol.ramcod,
          aplnumdig       like datrservapol.aplnumdig,
          itmnumdig       like datrservapol.itmnumdig,
          atdsrvorg       like datmservico.atdsrvorg,
          vclanomdl       like datmcntsrv.vclanomdl,
          cpocod          decimal (2,0)
   end record
   define l_datmcntsrv    record
          seqreg          like datmcntsrv.seqreg,
          seqregcnt       like datmcntsrv.seqregcnt,
          atdsrvorg       like datmcntsrv.atdsrvorg,
          atdsrvnum       like datmcntsrv.atdsrvnum,
          atdsrvano       like datmcntsrv.atdsrvano,
          srvtipabvdes    like datmcntsrv.srvtipabvdes,
          atdnom          like datmcntsrv.atdnom,
          funmat          like datmcntsrv.funmat,
          asitipabvdes    like datmcntsrv.asitipabvdes,
          c24solnom       like datmcntsrv.c24solnom,
          vcldes          like datmcntsrv.vcldes,
          vclanomdl       like datmcntsrv.vclanomdl,
          vclcor          like datmcntsrv.vclcor,
          vcllicnum       like datmcntsrv.vcllicnum,
          vclcamtip       like datmcntsrv.vclcamtip,
          vclcrgflg       like datmcntsrv.vclcrgflg,
          vclcrgpso       like datmcntsrv.vclcrgpso,
          atddfttxt       like datmcntsrv.atddfttxt,
          segnom          like datmcntsrv.segnom,
          aplnumdig       like datmcntsrv.aplnumdig,
          cpfnum          like datmcntsrv.cpfnum,
          ocrufdcod       like datmcntsrv.ocrufdcod,
          ocrcidnom       like datmcntsrv.ocrcidnom,
          ocrbrrnom       like datmcntsrv.ocrbrrnom,
          ocrlgdnom       like datmcntsrv.ocrlgdnom,
          ocrendcmp       like datmcntsrv.ocrendcmp,
          ocrlclcttnom    like datmcntsrv.ocrlclcttnom,
          ocrlcltelnum    like datmcntsrv.ocrlcltelnum,
          ocrlclrefptotxt like datmcntsrv.ocrlclrefptotxt,
          dsttipflg       like datmcntsrv.dsttipflg,
          dstufdcod       like datmcntsrv.dstufdcod,
          dstcidnom       like datmcntsrv.dstcidnom,
          dstbrrnom       like datmcntsrv.dstbrrnom,
          dstlgdnom       like datmcntsrv.dstlgdnom,
          rmcacpflg       like datmcntsrv.rmcacpflg,
          obstxt          like datmcntsrv.obstxt,
          srrcoddig       like datmcntsrv.srrcoddig,
          srrabvnom       like datmcntsrv.srrabvnom,
          atdvclsgl       like datmcntsrv.atdvclsgl,
          atdprscod       like datmcntsrv.atdprscod,
          nomgrr          like datmcntsrv.nomgrr,
          atddat          like datmcntsrv.atddat,
          atdhor          like datmcntsrv.atdhor,
          acndat          like datmcntsrv.acndat,
          acnhor          like datmcntsrv.acnhor,
          acnprv          like datmcntsrv.acnprv,
          c24openom       like datmcntsrv.c24openom,
          c24opemat       like datmcntsrv.c24opemat,
          pasnom1         like datmcntsrv.pasnom1,
          pasida1         like datmcntsrv.pasida1,
          pasnom2         like datmcntsrv.pasnom2,
          pasida2         like datmcntsrv.pasida2,
          pasnom3         like datmcntsrv.pasnom3,
          pasida3         like datmcntsrv.pasida3,
          pasnom4         like datmcntsrv.pasnom4,
          pasida4         like datmcntsrv.pasida4,
          pasnom5         like datmcntsrv.pasnom5,
          pasida5         like datmcntsrv.pasida5,
          atldat          like datmcntsrv.atldat,
          atlhor          like datmcntsrv.atlhor,
          atlmat          like datmcntsrv.atlmat,
          atlnom          like datmcntsrv.atlnom,
          cnlflg          like datmcntsrv.cnlflg,
          cnldat          like datmcntsrv.cnldat,
          cnlhor          like datmcntsrv.cnlhor,
          cnlmat          like datmcntsrv.cnlmat,
          cnlnom          like datmcntsrv.cnlnom,
          socntzcod       like datmcntsrv.socntzcod,
          c24astcod       like datmcntsrv.c24astcod,
          atdorgsrvnum    like datmcntsrv.atdorgsrvnum,
          atdorgsrvano    like datmcntsrv.atdorgsrvano,
          srvtip          like datmcntsrv.srvtip,
          acnifmflg       like datmcntsrv.acnifmflg,
          dstsrvnum       like datmcntsrv.dstsrvnum,
          dstsrvano       like datmcntsrv.dstsrvano,
          prcflg          like datmcntsrv.prcflg,
          ramcod          like datmcntsrv.ramcod,
          succod          like datmcntsrv.succod,
          itmnumdig       like datmcntsrv.itmnumdig,
          ocrlcldddcod    like datmcntsrv.ocrlcldddcod,
          cpfdig          like datmcntsrv.cpfdig,
          cgcord          like datmcntsrv.cgcord,
          ocrendzoncod    like datmcntsrv.ocrendzoncod,
          dstendzoncod    like datmcntsrv.dstendzoncod,
          sindat          like datmcntsrv.sindat,
          sinhor          like datmcntsrv.sinhor,
          bocnum          like datmcntsrv.bocnum ,
          boclcldes       like datmcntsrv.boclcldes,
          sinavstip       like datmcntsrv.sinavstip,
          vclchscod       like datmcntsrv.vclchscod,
          obscmptxt       like datmcntsrv.obscmptxt,
          crtsaunum       like datmcntsrv.crtsaunum,
          ciaempcod       like datmcntsrv.ciaempcod,
          atdnum          like datmcntsrv.atdnum
   end record
   define ws              record
          lignum          like datmligacao.lignum   ,
          atdsrvnum       like datmservico.atdsrvnum,
          atdsrvano       like datmservico.atdsrvano,
          sqlcode         integer                   ,
          msgerro         char (300)                ,
          sinvstnum       like datmpedvist.sinvstnum,
          tabname         like systables.tabname    ,
          sinntzcod       like datmavssin.sinntzcod ,
          eqprgicod       like datmavssin.eqprgicod ,
          cidcod          like glakcid.cidcod       ,
          vclanofbc       like abbmveic.vclanofbc   ,
          vigfnl          like abbmdoc.vigfnl       ,
          viginc          like abbmdoc.viginc       ,
          bocflg          char (01),
          hist            like datmservhist.c24srvdsc,
          histerr         smallint                   ,
          ligdat          like datmservhist.ligdat   ,
          lighorinc       like datmservhist.lighorinc,
          c24txtseq       like datmservhist.c24txtseq,
          c24srvdsc       like datmservhist.c24srvdsc,
          historico       like dafmintavs.sinres
   end record

   define lr_cts05g00     record
          segnom          like gsakseg.segnom       ,
          corsus          like datmservico.corsus   ,
          cornom          like datmservico.cornom   ,
          cvnnom          char (20)                 ,
          vclcoddig       like datmservico.vclcoddig,
          vcldes          like datmservico.vcldes   ,
          vclanomdl       like datmservico.vclanomdl,
          vcllicnum       like datmservico.vcllicnum,
          vclchsinc       like abbmveic.vclchsinc   ,
          vclchsfnl       like abbmveic.vclchsfnl   ,
          vclcordes       char (12)
   end record
   define l_data       date,
          l_hora2      datetime hour to minute


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_data  =  null
	let	l_hora2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  l_datmcntsrv.*  to  null

	initialize  ws.*  to  null

	initialize  lr_cts05g00.*  to  null

   call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
   let aux_today = l_data

   let aux_hora  = l_hora2
   let aux_ano4  = aux_today[7,10]
   let aux_ano2  = aux_today[9,10]

   initialize  l_datmcntsrv.*  to  null
   initialize  ws.*            to  null
   initialize  lr_cts05g00.*   to  null

   call cts35m03_prepare()
   open c_cts35m03_001 using param.seqreg
   foreach c_cts35m03_001 into l_datmcntsrv.seqreg
                            ,l_datmcntsrv.seqregcnt
                            ,l_datmcntsrv.atdsrvorg
                            ,l_datmcntsrv.atdsrvnum
                            ,l_datmcntsrv.atdsrvano
                            ,l_datmcntsrv.srvtipabvdes
                            ,l_datmcntsrv.atdnom
                            ,l_datmcntsrv.funmat
                            ,l_datmcntsrv.asitipabvdes
                            ,l_datmcntsrv.c24solnom
                            ,l_datmcntsrv.vcldes
                            ,l_datmcntsrv.vclanomdl
                            ,l_datmcntsrv.vclcor
                            ,l_datmcntsrv.vcllicnum
                            ,l_datmcntsrv.vclcamtip
                            ,l_datmcntsrv.vclcrgflg
                            ,l_datmcntsrv.vclcrgpso
                            ,l_datmcntsrv.atddfttxt
                            ,l_datmcntsrv.segnom
                            ,l_datmcntsrv.aplnumdig
                            ,l_datmcntsrv.cpfnum
                            ,l_datmcntsrv.ocrufdcod
                            ,l_datmcntsrv.ocrcidnom
                            ,l_datmcntsrv.ocrbrrnom
                            ,l_datmcntsrv.ocrlgdnom
                            ,l_datmcntsrv.ocrendcmp
                            ,l_datmcntsrv.ocrlclcttnom
                            ,l_datmcntsrv.ocrlcltelnum
                            ,l_datmcntsrv.ocrlclrefptotxt
                            ,l_datmcntsrv.dsttipflg
                            ,l_datmcntsrv.dstufdcod
                            ,l_datmcntsrv.dstcidnom
                            ,l_datmcntsrv.dstbrrnom
                            ,l_datmcntsrv.dstlgdnom
                            ,l_datmcntsrv.rmcacpflg
                            ,l_datmcntsrv.obstxt
                            ,l_datmcntsrv.srrcoddig
                            ,l_datmcntsrv.srrabvnom
                            ,l_datmcntsrv.atdvclsgl
                            ,l_datmcntsrv.atdprscod
                            ,l_datmcntsrv.nomgrr
                            ,l_datmcntsrv.atddat
                            ,l_datmcntsrv.atdhor
                            ,l_datmcntsrv.acndat
                            ,l_datmcntsrv.acnhor
                            ,l_datmcntsrv.acnprv
                            ,l_datmcntsrv.c24openom
                            ,l_datmcntsrv.c24opemat
                            ,l_datmcntsrv.pasnom1
                            ,l_datmcntsrv.pasida1
                            ,l_datmcntsrv.pasnom2
                            ,l_datmcntsrv.pasida2
                            ,l_datmcntsrv.pasnom3
                            ,l_datmcntsrv.pasida3
                            ,l_datmcntsrv.pasnom4
                            ,l_datmcntsrv.pasida4
                            ,l_datmcntsrv.pasnom5
                            ,l_datmcntsrv.pasida5
                            ,l_datmcntsrv.atldat
                            ,l_datmcntsrv.atlhor
                            ,l_datmcntsrv.atlmat
                            ,l_datmcntsrv.atlnom
                            ,l_datmcntsrv.cnlflg
                            ,l_datmcntsrv.cnldat
                            ,l_datmcntsrv.cnlhor
                            ,l_datmcntsrv.cnlmat
                            ,l_datmcntsrv.cnlnom
                            ,l_datmcntsrv.socntzcod
                            ,l_datmcntsrv.c24astcod
                            ,l_datmcntsrv.atdorgsrvnum
                            ,l_datmcntsrv.atdorgsrvano
                            ,l_datmcntsrv.srvtip
                            ,l_datmcntsrv.acnifmflg
                            ,l_datmcntsrv.dstsrvnum
                            ,l_datmcntsrv.dstsrvano
                            ,l_datmcntsrv.prcflg
                            ,l_datmcntsrv.ramcod
                            ,l_datmcntsrv.succod
                            ,l_datmcntsrv.itmnumdig
                            ,l_datmcntsrv.ocrlcldddcod
                            ,l_datmcntsrv.cpfdig
                            ,l_datmcntsrv.cgcord
                            ,l_datmcntsrv.ocrendzoncod
                            ,l_datmcntsrv.dstendzoncod
                            ,l_datmcntsrv.sindat
                            ,l_datmcntsrv.sinhor
                            ,l_datmcntsrv.bocnum
                            ,l_datmcntsrv.boclcldes
                            ,l_datmcntsrv.sinavstip
                            ,l_datmcntsrv.vclchscod
                            ,l_datmcntsrv.obscmptxt
                            ,l_datmcntsrv.crtsaunum
                            ,l_datmcntsrv.ciaempcod
                            ,l_datmcntsrv.atdnum
      let l_datmcntsrv.c24opemat = param.c24opemat
      let l_datmcntsrv.funmat    = param.funmat

      begin work
      -------------[ gera numero de ligacao ]---------------
      call cts10g03_numeracao( 2, "5" )
                returning ws.lignum   ,
                          ws.atdsrvnum,
                          ws.atdsrvano,
                          ws.sqlcode  ,
                          ws.msgerro
      if  ws.sqlcode <> 0 then
          rollback work
          return ws.msgerro,
                 ws.sqlcode,
                 ws.atdsrvnum,
                 ws.atdsrvano
      else
          commit work
      end if

#display "*cts35m03 -  param = ", param.*
#display "*cts35m03 -  ligacao=",ws.lignum," atdsrvnum=",ws.atdsrvnum

      -----------------[ Obtem codigo da regiao ]-------------------------
      if l_datmcntsrv.ocrcidnom  = "SANTOS" and
         l_datmcntsrv.ocrufdcod  = "SP"     then
         let ws.eqprgicod  = 3    # SUCURSAL
      else
         initialize ws.cidcod to null
         declare c_cid cursor for
          select cidcod
            from glakcid
           where cidnom = l_datmcntsrv.ocrcidnom
             and cidcep is not null

         foreach c_cid into ws.cidcod
            exit foreach
         end foreach

         declare c_reg cursor for
          select eqprgicod
           from ssakeqprgicid
           where eqprgicidcod = ws.cidcod

         foreach c_reg into ws.eqprgicod
               exit foreach
         end foreach
      end if
      if ws.eqprgicod is null    then
         if l_datmcntsrv.ocrufdcod = "SP"  then
            let ws.eqprgicod  = 2    # SP - INTERIOR
         else
            let ws.eqprgicod  = 3    # SUCURSAIS
         end if
      end if

      if l_datmcntsrv.sinavstip = "R" then
         let ws.sinntzcod       =  30
      else
         let ws.sinntzcod       =  36
      end if

      if l_datmcntsrv.bocnum is not null then
         let ws.bocflg   = "S"
      else
         let ws.bocflg   = "N"
      end if
      if param.aplnumdig is not null and
         param.aplnumdig <> 0        then
         ---------------------[ dados do veiculo ]------------------------
         select vclanofbc
           into ws.vclanofbc
           from abbmveic
          where succod    = param.succod      and
                aplnumdig = param.aplnumdig   and
                itmnumdig = param.itmnumdig   and
                dctnumseq = (select max(dctnumseq)
                               from abbmveic
                              where succod    = param.succod      and
                                    aplnumdig = param.aplnumdig   and
                                    itmnumdig = param.itmnumdig)
         -------------------[ vigencia da apolice ]------------------------
         select viginc, vigfnl
           into ws.viginc   ,
                ws.vigfnl
           from abamapol
          where succod    = param.succod    and
                aplnumdig = param.aplnumdig

         ----------------[ busca dados da apolice ]--------------
         call cts05g00(param.succod,
                       param.ramcod,
                       param.aplnumdig,
                       param.itmnumdig)
             returning lr_cts05g00.segnom,
                       lr_cts05g00.corsus,
                       lr_cts05g00.cornom,
                       lr_cts05g00.cvnnom,
                       lr_cts05g00.vclcoddig,
                       l_datmcntsrv.vcldes,
                       l_datmcntsrv.vclanomdl,
                       l_datmcntsrv.vcllicnum,
                       lr_cts05g00.vclchsinc,
                       lr_cts05g00.vclchsfnl,
                       l_datmcntsrv.vclcor
      end if
      -------------[ grava ligacao ]-----------------------
      if param.ramcod is null then
         let param.ramcod = 531
      end if

      begin work

      call cts10g00_ligacao
                (ws.lignum             ,#
                 l_datmcntsrv.atddat   ,#
                 l_datmcntsrv.atdhor   ,#
                 1                     ,#c24soltipcod
                 l_datmcntsrv.c24solnom,#
                 l_datmcntsrv.c24astcod,#
                 l_datmcntsrv.funmat   ,#
                 0                     ,#ligcvntip
                 0                     ,#c24paxnum
                 ws.atdsrvnum          ,#ws.atdsrvnum
                 ws.atdsrvano          ,#ws.atdsrvano
                 ""                    ,#sinvstnum
                 ""                    ,#sinvstano
                 ""                    ,#sinavsnum
                 ""                    ,#sinavsano
                 param.succod          ,#
                 param.ramcod          ,#
                 param.aplnumdig       ,#
                 param.itmnumdig       ,#
                 ""                    ,#g_documento.edsnumref
                 ""                    ,#g_documento.prporg
                 ""                    ,#g_documento.prpnumdig
                 ""                    ,#g_documento.fcapacorg
                 ""                    ,#g_documento.fcapacnum
                 ""                    ,#sinramcod
                 ""                    ,#sinano
                 ""                    ,#sinnum
                 ""                    ,#sinitmseq
                 ""                    ,#caddat
                 ""                    ,#cadhor
                 ""                    ,#cademp
                 ""                    )#cadmat
             returning ws.tabname,
                       ws.sqlcode

      if ws.sqlcode  <>  0  then
         rollback work
         let ws.msgerro = "Erro - cts10g00_ligacao"
         return ws.msgerro,
                ws.sqlcode,
                ws.atdsrvnum,
                ws.atdsrvano
      end if
      call cts10g02_grava_servico(ws.atdsrvnum          ,
                                  ws.atdsrvano          ,
                                  1                     , # atdsoltip
                                  l_datmcntsrv.c24solnom, # c24solnom
                                  param.cpocod          ,
                                  l_datmcntsrv.funmat   ,
                                  ""                    , # atdlibflg
                                  ""                    , # atdlibhor
                                  ""                    , # atdlibdat
                                  l_datmcntsrv.atldat   ,
                                  l_datmcntsrv.atlhor   ,
                                  "N" , # atdlclflg Docto roubados ?
                                  ""                    , # atdhorpvt
                                  ""                    , # atddatprg
                                  ""                    , # atdhorprg
                                  "5"                   , # ATDTIP
                                  ""                    , # atdmotnom
                                  ""                    , # atdvclsgl
                                  ""                    , # atdprscod
                                  ""                    , # atdcstvlr
                                  "S"                   , # atdfnlflg
                                  ""                    , # atdfnlhor
                                  "N" , # atdrsdflg chassi/placa conferem
                                  l_datmcntsrv.vclchscod,
                                  ""                    , #d_cts05m00.atddoctxt
                                  l_datmcntsrv.c24opemat,
                                  l_datmcntsrv.segnom   ,
                                  l_datmcntsrv.vcldes   ,
                                  param.vclanomdl       ,
                                  l_datmcntsrv.vcllicnum,
                                  lr_cts05g00.corsus    ,
                                  lr_cts05g00.cornom    ,
                                  l_datmcntsrv.atldat   , # cnldat
                                  ""                    , # pgtdat
                                  ""                    , # c24nomctt
                                  ""                    , # atdpvtretflg
                                  ""                    , # atdvcltip
                                  ""                    , # asitipcod
                                  ""                    , # socvclcod
                                  lr_cts05g00.vclcoddig ,
                                  "N"                   , # srvprlflg
                                  ""                    , # srrcoddig
                                  2                   , # atdprinvlcod 2-normal
                                  param.atdsrvorg     ) # ATDSRVORG
         returning ws.tabname,
                   ws.sqlcode
      if ws.sqlcode <> 0 then
         rollback work
         let ws.msgerro = "Erro - cta10g02_grava_servico"
         return ws.msgerro,
                ws.sqlcode,
                ws.atdsrvnum,
                ws.atdsrvano
      end if
      #-------------------------------------------------------------------
      # Grava complemento do servico
      #-------------------------------------------------------------------
      execute p_cts35m03_004 using ws.atdsrvnum,
                                 ws.atdsrvano,
                                 l_datmcntsrv.sinavstip,
                                 ""                 ,
                                 l_datmcntsrv.sindat ,
                                 ws.bocflg           ,
                                 l_datmcntsrv.bocnum ,
                                 ""                  ,
                                 ""                  ,
                                 l_datmcntsrv.sinhor

      if sqlca.sqlcode  <>  0  then
         let ws.sqlcode  =  sqlca.sqlcode
         rollback work
         let ws.msgerro = "Erro - insert - datmservicocmp"
         return ws.msgerro,
                ws.sqlcode,
                ws.atdsrvnum,
                ws.atdsrvano
      end if
      ---------------------[ grava etapa ]---------------------------
      call cts35m00_insere_etapa(ws.atdsrvnum,
                                 ws.atdsrvano,
                                 4                     , # atdetpcod
                                 l_datmcntsrv.atldat   ,
                                 l_datmcntsrv.atlhor   ,
                                 1,     # ---> EMPCOD
                                 l_datmcntsrv.funmat   ,
                                 l_datmcntsrv.atdprscod,
                                 l_datmcntsrv.srrcoddig,
                                 ""                    , # l_socvclcod,
                                 l_datmcntsrv.srrabvnom)
                 returning ws.sqlcode

      if ws.sqlcode  <> 0 then
         rollback work
         let ws.msgerro = "Erro - insert - datmsrvacp"
         return ws.msgerro,
                ws.sqlcode,
                ws.atdsrvnum,
                ws.atdsrvano
      end if
      --------------------[ grava endereco de ocorrencia ]----------------
      if l_datmcntsrv.ocrlgdnom is not null and
         l_datmcntsrv.ocrlgdnom <> " "      then
         execute p_cts35m03_002 using ws.atdsrvnum,
                                    ws.atdsrvano,
                                    "1"       ,
                                    "",
                                    "",
                                    l_datmcntsrv.ocrlgdnom,
                                    "0",
                                    l_datmcntsrv.ocrbrrnom,
                                    l_datmcntsrv.ocrbrrnom,
                                    l_datmcntsrv.ocrcidnom,
                                    l_datmcntsrv.ocrufdcod,
                                    l_datmcntsrv.ocrlclrefptotxt,
                                    l_datmcntsrv.ocrendzoncod,
                                    "",
                                    "",
                                    "",
                                    "",
                                    l_datmcntsrv.ocrlcldddcod,
                                    l_datmcntsrv.ocrlcltelnum,
                                    l_datmcntsrv.ocrlclcttnom,
                                    "3",
                                    "",
                                    l_datmcntsrv.ocrendcmp

         if sqlca.sqlcode    <> 0 then
            rollback work
            let ws.msgerro = "Erro-cts35m03-endereco ocorrencia-datmlcl"
            let ws.sqlcode = sqlca.sqlcode
            return ws.msgerro,
                   ws.sqlcode,
                   ws.atdsrvnum,
                   ws.atdsrvano
         end if
      end if
      ---------------[ Grava relacionamento servico / apolice ]--------------
      if  param.succod    is not null  and
          param.ramcod    is not null  and
          param.aplnumdig is not null  then
          insert into datrservapol ( atdsrvnum,
                                     atdsrvano,
                                     succod   ,
                                     ramcod   ,
                                     aplnumdig,
                                     itmnumdig,
                                     edsnumref )
                            values ( ws.atdsrvnum   ,
                                     ws.atdsrvano   ,
                                     param.succod   ,
                                     param.ramcod   ,
                                     param.aplnumdig,
                                     param.itmnumdig,
                                     0              )  # edsnumref

          if  sqlca.sqlcode <> 0  then
              rollback work
              let ws.msgerro = "Erro-cts35m03-datrservapol "
              let ws.sqlcode = sqlca.sqlcode
              return ws.msgerro,
                     ws.sqlcode,
                     ws.atdsrvnum,
                     ws.atdsrvano
          end if
      end if
      ------[ Grava tabela de relacionamento Servico x Vistoria Sinistro ]----
      insert into datrsrvvstsin( atdsrvnum      ,
                                 atdsrvano      ,
                                 sinvstnum      ,
                                 sinvstano      ,
                                 sinvstlauemsstt )
                         values( ws.atdsrvnum  ,
                                 ws.atdsrvano  ,
                                 ws.atdsrvnum  ,
                                 aux_ano4      ,
                                 1               )
      if  sqlca.sqlcode  <>  0  then
          rollback work
          let ws.msgerro = "Erro-cts35m03-datrsrvvstsin"
          let ws.sqlcode = sqlca.sqlcode
          return ws.msgerro,
                 ws.sqlcode,
                 ws.atdsrvnum,
                 ws.atdsrvano
      end if
      --------------[ Grava tabela de Aviso de sinistro ]----------------------
      insert into datmavssin( sinvstnum,
                              sinvstano,
                              atdsrvnum,
                              atdsrvano,
                              sinntzcod,
                              eqprgicod )
                      values( ws.atdsrvnum       ,
                              aux_ano4            ,
                              ws.atdsrvnum       ,
                              ws.atdsrvano       ,
                              ws.sinntzcod,
                              ws.eqprgicod )
      if  sqlca.sqlcode  <>  0  then
          rollback work
          let ws.msgerro = "Erro-cts35m03-datmavssin"
          let ws.sqlcode = sqlca.sqlcode
          return ws.msgerro,
                 ws.sqlcode,
                 ws.atdsrvnum,
                 ws.atdsrvano
      end if
      ----------------[ atualiza as bases do sinistro ]--------------------
      call smata030_ins (ws.atdsrvnum              ,
                         aux_ano4                  ,
                         param.succod              ,
                         param.aplnumdig           ,
                         param.itmnumdig           ,
                         aux_ano4                  ,
                         ws.atdsrvnum              ,
                         0                         ,
                         l_datmcntsrv.sindat       ,
                         l_datmcntsrv.sinhor       ,
                         l_datmcntsrv.segnom       ,
                         l_datmcntsrv.ocrlcltelnum ,
                         l_datmcntsrv.cpfnum       ,
                         l_datmcntsrv.cgcord       ,
                         l_datmcntsrv.cpfdig       ,
                         lr_cts05g00.vclcoddig     ,
                         ""                        ,
                         l_datmcntsrv.vclchscod    ,
                         l_datmcntsrv.vcllicnum    ,
                         ws.vclanofbc              ,
                         param.vclanomdl           ,
                         ""                        ,  # sinrclsgrflg
                         ""                        ,  # sinrclsgdnom
                         ""                        ,  # sinrclcpdflg
                         ""                        ,  # sinvclguiflg
                         ""                        ,  # sinvclguinom
                         param.ramcod              ,
                         ""                        ,  # subcod
                         ""                        ,  # prporgidv
                         ""                        ,  # prpnumidv
                         "ct24hs"                  ,
                         param.c24opemat           ,
                         ""                        , #a_cts05m00[1].lgdtxt
                         ""                        ,
                         ""                        , #a_cts05m00[1].cidnom
                         ""                        , #a_cts05m00[1].ufdcod
                         ""                        ,
                         ""                        ,
                         ""                        ,
                         ""                        , #sinrclapltxt
                         ws.sinntzcod              ,
                         1                         , #prdtipcod 2=perda total
                         "S",              #d_cts05m00.atdrsdflg chsliccnfflg
                         "N",              #d_cts05m00.atdlclflg docrouflg
                         "" ,              #d_cts05m00.atddoctxt docroutxt
                         "" ,              #d_cts05m00.atddfttxt sinavsobs
                         l_datmcntsrv.sinavstip   , #sinrbftip
                         ""                        , #sinlclcep
                         ""                        , #sinrclbrrnom
                         "N",      #wg_smata030.flgcondutor sinrclprimotflg
                         ""                        , #sinmotidd
                         ""                        , #trcaplvigfnl
                         ""                        , #trcaplviginc
                         ""  ) #wg_smata030.nscdat data nasc. motorista
               returning ws.sqlcode
#display "*cts35m03 - smata030_ins, ws.sqlcode = ", ws.sqlcode
      if ws.sqlcode <> 0  then
         rollback work
         let ws.msgerro = "Erro-cts35m03-smata030_ins"
         return ws.msgerro,
                ws.sqlcode,
                ws.atdsrvnum,
                ws.atdsrvano
      end if
      call ssmatmot030_ins (ws.atdsrvnum              ,
                            aux_ano4                  ,
                            "S"                       ,
                            ""                        ,
                            ""                        ,
                            ""                        ,
                            l_datmcntsrv.segnom       ,
                            l_datmcntsrv.cpfnum       ,
                            ""                        ,# wg_smata030.endlgd
                            ""                        ,# wg_smata030.endbrr
                            ""                        ,# wg_smata030.endcid
                            ""                        ,# wg_smata030.endufd
                            l_datmcntsrv.ocrlcldddcod ,
                            l_datmcntsrv.ocrlcltelnum ,
                            ""                        ,# cnhnum
                            ""                        ,# cnhvctdat
                            l_datmcntsrv.ocrlgdnom    ,
                            l_datmcntsrv.ocrufdcod    ,
                            l_datmcntsrv.ocrcidnom    ,
                            ws.bocflg                 ,
                            ""                        ,# sinvcllcldes
                            ""                        ,# sinmotsex
                            ""                        ,# sinmotprfcod
                            ""                        ,# sinsgrvin
                            ""                        ,# sinmotidd
                            ""                        ,# sinmotcplflg
                            l_datmcntsrv.cgcord        ,
                            l_datmcntsrv.cpfdig       ,
                            ""                        ,#vclatulgd
                            ""                        ,#sinmotprfdes
                            l_datmcntsrv.bocnum       ,
                            ""                        ,#cdtestcod
                            "" ) #wg_smata030.nscdat #data nasc. motorista
                   returning ws.sqlcode
#display "*cts35m03 - ssmatmot030_ins, ws.sqlcode = ", ws.sqlcode
      if ws.sqlcode <> 0  then
         rollback work
         let ws.msgerro = "Erro-cts35m03-ssmatmot030_ins"
         return ws.msgerro,
                ws.sqlcode,
                ws.atdsrvnum,
                ws.atdsrvano
      end if
      let ws.hist = "** CTS35M00-CARGA CONTINGENCIA-seqregcnt = ",l_datmcntsrv.seqregcnt
      call cts10g02_historico(ws.atdsrvnum         ,
                              ws.atdsrvano         ,
                              l_datmcntsrv.atddat  ,
                              l_datmcntsrv.atdhor  ,
                              l_datmcntsrv.funmat  ,
                              ws.hist              ,
                              "","","","")
         returning ws.histerr

      if l_datmcntsrv.obstxt is not null or
         l_datmcntsrv.obscmptxt is not null then
         call cts35m03_historico(ws.atdsrvnum,
                                 ws.atdsrvano,
                                 l_datmcntsrv.funmat,
                                 l_datmcntsrv.atldat,
                                 l_datmcntsrv.atlhor,
                                 l_datmcntsrv.obstxt,
                                 l_datmcntsrv.obscmptxt)
      end if
      if l_datmcntsrv.atdnum <> 0 and
         l_datmcntsrv.atdnum is not null then
                ---------[ grava na tabela de Atendimento Decreto 6523 ]---------
          call ctd24g00_ins_atd(l_datmcntsrv.atdnum      ,
                                l_datmcntsrv.ciaempcod   ,
                                l_datmcntsrv.c24solnom   ,
                                ""                       ,
                                1                        ,
                                param.ramcod             ,
                                ""                       ,
                                l_datmcntsrv.vcllicnum   ,
                                lr_cts05g00.corsus       ,
                                param.succod             ,
                                param.aplnumdig          ,
                                param.itmnumdig          ,
                                ""                       ,
                                l_datmcntsrv.segnom      ,
                                ""                       ,
                                l_datmcntsrv.cpfnum      ,
                                l_datmcntsrv.cgcord      ,
                                l_datmcntsrv.cpfdig      ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                lr_cts05g00.vclchsfnl    ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ws.atdsrvnum             ,
                                aux_ano4                 ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                ""                       ,
                                l_datmcntsrv.funmat      ,
                                l_datmcntsrv.ciaempcod   ,
                                ""                       ,
                                0 )
           returning l_datmcntsrv.atdnum,
                     ws.sqlcode         ,
                     ws.msgerro
           if ws.sqlcode    <> 0 and
              ws.sqlcode    <> 4 then
              rollback work
              return ws.msgerro,
                     ws.sqlcode,
                     ws.atdsrvnum,
                     ws.atdsrvano
           end if
          ---------[ grava relacionamento Atendimento X Ligacao ]-------------
          call ctd25g00_insere_atendimento(l_datmcntsrv.atdnum ,ws.lignum)
          returning ws.sqlcode,ws.msgerro
          if ws.sqlcode    <> 0 then
             rollback work
             return ws.msgerro,
                    ws.sqlcode,
                    ws.atdsrvnum,
                    ws.atdsrvano
          end if
      end if
      -------------[ funcao de interface com sistema daf (inclusao) ]--------
      open ccts35m03007 using ws.atdsrvnum,
                              ws.atdsrvano
      foreach ccts35m03007 into  ws.ligdat   ,
                                 ws.lighorinc,
                                 ws.c24txtseq,
                                 ws.c24srvdsc
        let ws.historico = ws.historico clipped," ",ws.c24srvdsc
      end foreach
      call cty13g00(""                      ,
                    ""                      ,
                    ""                      ,
                    ""                      ,
                    ""                      ,
                    ""                      ,
                    ws.atdsrvnum            ,
                    ws.atdsrvano            ,
                    lr_cts05g00.vclcoddig   ,
                    l_datmcntsrv.vcldes     ,
                    l_datmcntsrv.vcllicnum  ,
                    l_datmcntsrv.c24astcod  ,
                    l_datmcntsrv.vclchscod  ,
                    l_datmcntsrv.segnom     ,
                    l_datmcntsrv.sindat     ,
                    l_datmcntsrv.sinhor     ,
                    ""                      ,
                    ""                      ,
                    ws.historico            ,
                    ""                      ,
                    l_datmcntsrv.succod     ,
                    l_datmcntsrv.aplnumdig  ,
                    l_datmcntsrv.itmnumdig  ,
                    g_funapol.dctnumseq     ,
                    g_documento.edsnumref   ,
                    g_documento.prporg      ,
                    g_documento.prpnumdig   ,
                    ""                      ,
                    ""                      ,
                    ""                      ,
                    ""                      ,
                    ""                      ,
                    ""                      ,
                    "cts35m03"              )
      whenever error continue
      # atualiza "S" no campo prcflg
      execute p_cts35m03_003 using ws.atdsrvnum,
                                 ws.atdsrvano,
                                 l_datmcntsrv.seqreg
      whenever error stop
      if sqlca.sqlcode    <> 0 then
         rollback work
         let ws.msgerro = "Erro-datmcntsrv-pcts35m03005"
         let ws.sqlcode = sqlca.sqlcode
         return ws.msgerro,
                ws.sqlcode,
                ws.atdsrvnum,
                ws.atdsrvano
      end if
      commit work
      
      # War Room
      # Ponto de acesso apos a gravacao do laudo
      call cts00g07_apos_grvlaudo(ws.atdsrvnum,
                                  ws.atdsrvano)

      exit foreach
   end foreach
   return ws.msgerro,
          ws.sqlcode,
          ws.atdsrvnum,
          ws.atdsrvano
end function

#------------------------------------------------------------------------------
function cts35m03_historico(param)
#------------------------------------------------------------------------------
   define param record
          atdsrvnum    like datmservico.atdsrvnum,
          atdsrvano    like datmservico.atdsrvano,
          funmat       like datmcntsrv.funmat,
          atldat       like datmcntsrv.atldat,
          atlhor       like datmcntsrv.atlhor,
          obstxt       like datmcntsrv.obstxt,
          obscmptxt    like datmcntsrv.obscmptxt
   end record
   define hist     record
          hist1        like datmservhist.c24srvdsc ,
          hist2        like datmservhist.c24srvdsc ,
          hist3        like datmservhist.c24srvdsc ,
          hist4        like datmservhist.c24srvdsc ,
          hist5        like datmservhist.c24srvdsc
   end record
   define l_indice     smallint,
          l_caracteres smallint,
          l_limite_inf smallint,
          l_limite_sup smallint,
          l_status     smallint,
          l_msg_erro   char(300),
          l_erro       char(50),
          l_historico  char(1000),
          l_historico1 char(70)

   # ---> INICIALIZACAO DAS VARIAVEIS

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_indice  =  null
	let	l_caracteres  =  null
	let	l_limite_inf  =  null
	let	l_limite_sup  =  null
	let	l_status  =  null
	let	l_msg_erro  =  null
	let	l_erro  =  null
	let	l_historico  =  null
	let	l_historico1  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  hist.*  to  null

   let l_indice     = null
   let l_historico  = null
   let l_historico1 = null
   let l_status     = null
   let l_erro       = null
   let l_caracteres = 0
   let l_limite_inf = 0
   let l_limite_sup = 0
   initialize hist.* to null

   let l_historico = param.obstxt    clipped,
                     param.obscmptxt clipped

   if length(l_historico) <= 70 then
      let hist.hist1 = l_historico
      call cts10g02_historico(param.atdsrvnum  ,
                              param.atdsrvano  ,
                              param.atldat     ,
                              param.atlhor     ,
                              param.funmat     ,
                              hist.*  )
           returning l_status
   else
     for l_indice = 1 to length(l_historico)
         let l_caracteres = l_caracteres + 1
         if l_caracteres = 70 then # ---> UMA LINHA DE HISTORICO
            # ---> MONTA O LIMITE SUPERIOR E INFERIOR DA STRING DO HISTORICO
            let l_limite_inf = (l_indice + 1 - l_caracteres)
            let l_limite_sup = (l_indice + 1)
            # ---> HISTORICO QUE VAI SER INSERIDO(70 POSICOES)
            let l_historico1 = l_historico[l_limite_inf, l_limite_sup]
            let hist.hist1   = l_historico1
            call cts10g02_historico(param.atdsrvnum  ,
                                    param.atdsrvano  ,
                                    param.atldat     ,
                                    param.atlhor     ,
                                    param.funmat     ,
                                    hist.*  )
               returning l_status
            if l_status <> 0 then
               exit for
            end if
            let l_caracteres = 0
            let l_limite_inf = 0
            let l_limite_sup = 0
         end if
     end for
     if l_caracteres <> 0  and
       (l_status     =  0  or
        l_status    is null)  then
        let l_limite_inf = (l_indice  - l_caracteres)
        let l_limite_sup = (l_indice + 1)
        let l_historico1 = l_historico[l_limite_inf, l_limite_sup]
        let hist.hist1   = l_historico1
        call cts10g02_historico(param.atdsrvnum  ,
                                param.atdsrvano  ,
                                param.atldat     ,
                                param.atlhor     ,
                                param.funmat     ,
                                hist.*  )
           returning l_status
        let l_caracteres = 0
        let l_limite_inf = 0
        let l_limite_sup = 0
     end if
   end if
end function
