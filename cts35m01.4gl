#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS35M01                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ/RAJI JAHCHAN                           #
# PSI/OSF........: 201456                                                     #
#                  CARGA DA CONTINGENCIA PARA SINISTRO RE(V12)                #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR           ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 28/07/06   Ruiz            psi 201456 versao inicial                        #
#----------------------------------------------------------------------------#
# 17/04/2008 Federicce     PSI 214566 Comentario da funcao que gera servico  #
#                                     de JIT                                 #
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

 define aux_ano2      char (02)
 define aux_ano4      char (04)
 define aux_today     char (10)
 define aux_hora      char (05)

#main
#
#  call fun_dba_abre_banco("CT24HS")
#  set lock mode to wait 10
#  set isolation to dirty read
#
#  let g_issk.funmat = 601566
#  let g_issk.empcod = 1
#  let g_issk.usrtip = "F"
#  call startlog("cts35m01.log")
#  call cts35m01()
#
#end main

------------------------------------------------------------------------------#
function cts35m01_prepare()
------------------------------------------------------------------------------#

  define l_cmd char(5000)

  --[ Tabela Interface de Servico ]--

  #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

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

  prepare p_cts35m01_001 from l_cmd
  declare c_cts35m01_001 cursor with hold for p_cts35m01_001

  let l_cmd = " select sinramgrp from gtakram "
            , "  where empcod = 1 "
            , "    and ramcod = ? "

  prepare p_cts35m01_002 from l_cmd
  declare c_cts35m01_002 cursor for p_cts35m01_002

  let l_cmd = " select cbttip   ,    ",
              "        sinntzcod,    ",
              "        cbtvlr        ",
              "  from datrcntsrvcbt  ",
              "  where seqregcnt = ? "
  prepare pcts35m01003 from l_cmd
  declare ccts35m01003 cursor for pcts35m01003

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

  prepare pcts35m01004 from l_cmd

  let l_cmd = " update datmcntsrv ",
                " set (dstsrvnum, dstsrvano, prcflg)= (?,?,'S') ",
               " where seqreg = ? "

  prepare pcts35m01005 from l_cmd

  let l_cmd = " insert into datrpedvistnatcob ",
                          "  (sinvstnum,      ",
                          "   sinvstano,      ",
                          "   cbttip,         ",
                          "   sinramgrp,      ",
                          "   sinntzcod,      ",
                          "   orcvlr)         ",
                   " values (?,?,?,?,?,?)     "

  prepare pcts35m01006 from l_cmd

end function
---------------------------------------------------------------------------#
function cts35m01(param)
---------------------------------------------------------------------------#
   define param           record
          seqreg          like datmcntsrv.seqreg,
          funmat          like datmcntsrv.funmat,
          c24opemat       like datmcntsrv.c24opemat,
          succod          like datrservapol.succod,
          ramcod          like datrservapol.ramcod,
          aplnumdig       like datrservapol.aplnumdig,
          itmnumdig       like datrservapol.itmnumdig
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
          sinramgrp       like gtakram.sinramgrp    ,
          tabname         like systables.tabname    ,
          cbttip          like datrcntsrvcbt.cbttip ,
          sinntzcod       like datrcntsrvcbt.sinntzcod,
          cbtvlr          like datrcntsrvcbt.cbtvlr,
          c24txtseq       like datmsinhist.c24txtseq,
          c24vstdsc       like datmsinhist.c24vstdsc
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

   call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
   let aux_today = l_data

   let aux_hora  = l_hora2
   let aux_ano4  = aux_today[7,10]
   let aux_ano2  = aux_today[9,10]

   initialize  l_datmcntsrv.*  to  null
   initialize  ws.*            to  null
   initialize  lr_cts05g00.*   to  null

   call cts35m01_prepare()

##display "* param = ", param.*    # ruiz

   open c_cts35m01_001 using param.seqreg
   foreach c_cts35m01_001 into l_datmcntsrv.seqreg
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
      call cts10g03_numeracao( 1, "" )
                returning ws.lignum   ,
                          ws.atdsrvnum,
                          ws.atdsrvano,
                          ws.sqlcode  ,
                          ws.msgerro
      if  ws.sqlcode <> 0 then
          rollback work
          return ws.msgerro,
                 ws.sqlcode,
                 ws.sinvstnum
      else
          commit work
      end if
      ----------------[ gera numero de vistoria de sinistro ]---------------
      call cts35m01_gera_numero_vistoria()
                returning ws.msgerro,
                          ws.sinvstnum,
                          ws.sqlcode
      if ws.msgerro is not null then
         rollback work
         return ws.msgerro,
                ws.sqlcode,
                ws.sinvstnum
      end if

#display "* lignum   = ",ws.lignum     # ruiz
#display "* vistoria = ",ws.sinvstnum
#display "* ano      = ",aux_ano4

      -------------[ grava ligacao ]-----------------------
      if param.ramcod is null then
         let param.ramcod = 531
      end if
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
                 ""                    ,#ws.atdsrvnum
                 ""                    ,#ws.atdsrvano
                 ws.sinvstnum          ,#sinvstnum
                 aux_ano4              ,#sinvstano
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

#display "* gravei ligacao = ", ws.sqlcode," ",ws.tabname # ruiz

      if ws.sqlcode  <>  0  then
         rollback work
         let ws.msgerro = "Erro - cts10g00_ligacao"
         return ws.msgerro,
                ws.sqlcode,
                ws.sinvstnum
      end if
      if param.aplnumdig is not null and
         param.aplnumdig <> 0        then
         ----------[ busca dados da apolice ]---------
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
      -----[ busca grupo do ramo ]---------
      open c_cts35m01_002 using param.ramcod
      whenever error continue
      fetch c_cts35m01_002 into ws.sinramgrp
      whenever error stop

      insert into datmpedvist (sinvstnum,
                               sinvstano,
                               vstsolnom,
                               vstsoltip,
                               vstsoltipcod,
                               sindat   ,
                               sinhor   ,
                               segnom   ,
                               cornom   ,
                               dddcod   ,
                               teltxt   ,
                              #orcvlr   ,
                               funmat   ,
                               sinntzcod,
                               lclrsccod,
                               lclendflg,
                               lgdtip   ,
                               lgdnom   ,
                               lgdnum   ,
                               endufd   ,
                               lgdnomcmp,
                               endbrr   ,
                               endcid   ,
                               endcep   ,
                               endcepcmp,
                               endddd   ,
                               teldes   ,
                               lclcttnom,
                               endrefpto,
                               sinhst   ,
                               sinobs   ,
                               vstsolstt,
                               sinvstdat,
                               sinvsthor,
                               rglvstflg,
                               sinramgrp)
                     values ( ws.sinvstnum         ,
                              aux_ano4              ,
                              l_datmcntsrv.c24solnom,
                              "O"                   ,# vide cta00m01
                              "1"                   ,# c24soltipcod
                              l_datmcntsrv.sindat   ,
                              l_datmcntsrv.sinhor   ,
                              l_datmcntsrv.segnom   ,
                              lr_cts05g00.cornom    ,
                              l_datmcntsrv.ocrlcldddcod,# d_cts21m00.dddcod
                              l_datmcntsrv.ocrlcltelnum,# d_cts21m00.teltxt
                             #ws.orcvlr             ,
                             #d_cts21m00.orcvlr     ,
                              l_datmcntsrv.funmat   ,# g_issk.funmat
                             #ws.sinntzcod          ,
                              0                     ,# d_cts21m00.sinntzcod
                              ""                    ,# d_cts21m00.lclrsccod
                              ""                    ,# d_cts21m00.lclendflg
                              ""                    ,# d_cts21m00.lgdtip
                              l_datmcntsrv.ocrlgdnom,# d_cts21m00.lgdnom
                              0                     ,# d_cts21m00.lgdnum
                              l_datmcntsrv.ocrufdcod,# d_cts21m00.endufd
                              ""                    ,# d_cts21m00.lgdnomcmp
                              l_datmcntsrv.ocrbrrnom,# d_cts21m00.endbrr
                              l_datmcntsrv.ocrcidnom,# d_cts21m00.endcid
                              ""                    ,# d_cts21m00.endcep
                              ""                    ,# d_cts21m00.endcepcmp
                              l_datmcntsrv.ocrlcldddcod,# d_cts21m00.endddd
                              l_datmcntsrv.ocrlcltelnum,# d_cts21m00.teldes
                              l_datmcntsrv.ocrlclcttnom,# d_cts21m00.lclcttnom
                              ""                       ,# d_cts21m00.endrefpto
                              l_datmcntsrv.ocrlclrefptotxt,# d_cts21m00.sinhst
                              l_datmcntsrv.obstxt   ,# d_cts21m00.sinobs
                              1                     ,
                              l_datmcntsrv.atddat   ,
                              l_datmcntsrv.atdhor   ,
                              "N"                   , # d_cts21m00.rglvstflg
                              ws.sinramgrp)

#display "* grava datmpedvist = ", sqlca.sqlcode  #ruiz

      if sqlca.sqlcode <> 0 then
         rollback work
         let ws.msgerro = "Erro - insert datmpedvist"
         let ws.sqlcode = sqlca.sqlcode
         return ws.msgerro,
                ws.sqlcode,
                ws.sinvstnum
      end if

#display "* lendo datrcntsrvcbt = ", l_datmcntsrv.seqregcnt # ruiz

      --------------------[ gravar natureza e corbertura ]----------------
      open ccts35m01003 using l_datmcntsrv.seqregcnt
      foreach ccts35m01003 into ws.cbttip,
                                ws.sinntzcod,
                                ws.cbtvlr
#display "* grava datrpedvistnatcob = ",ws.sinvstnum," ",aux_ano4," ",ws.cbttip, " ",ws.sinramgrp," ",ws.sinntzcod," ",ws.cbtvlr # ruiz
         execute pcts35m01006 using  ws.sinvstnum,
                                     aux_ano4    ,
                                     ws.cbttip   ,
                                     ws.sinramgrp,
                                     ws.sinntzcod,
                                     ws.cbtvlr
         if sqlca.sqlcode <> 0 then
            rollback work
            let ws.msgerro = "Erro-insert datrpedvistnatcob"
            let ws.sqlcode = sqlca.sqlcode
            return ws.msgerro,
                   ws.sqlcode,
                   ws.sinvstnum
         end if
      end foreach
      if param.succod    is not null and
         param.aplnumdig is not null then
         call osrea140 (1,                    ###  Codigo da Central
                        3,                    ###  Tipo Documento: Apolice
                        param.aplnumdig,
                        param.succod,
                        param.ramcod,
                        6936,                 ###  Matricula ROSIMEIRE SILVA
                        5178,                 ###  Ramal para contato
                        aux_ano4,             ###  Ano Vistoria Sinistro R.E.
                        ws.sinvstnum,         ###  Numero Vistoria Sinistro R.E.
                        aux_today,
                        1)                    ###  Codigo da Empresa
              returning ws.sqlcode

#display "* grava osrea140 = ", ws.sqlcode # ruiz

         if ws.sqlcode    <> 0 then
            rollback work
            let ws.msgerro = "Erro-interface CEDOCxSinisRE osrea140"
            return ws.msgerro,
                   ws.sqlcode,
                   ws.sinvstnum
         end if
      end if
      --------------------[ grava endereco de ocorrencia ]----------------
      if l_datmcntsrv.ocrlgdnom is not null and
         l_datmcntsrv.ocrlgdnom <> " "      then
         execute pcts35m01004 using ws.sinvstnum,
                                    aux_ano2    ,
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

#display "* grava endereço = ", sqlca.sqlcode # ruiz

         if sqlca.sqlcode    <> 0 then
            rollback work
            let ws.msgerro = "Erro-endereco ocorrencia-datmlcl"
            let ws.sqlcode = sqlca.sqlcode
            return ws.msgerro,
                   ws.sqlcode,
                   ws.sinvstnum
         end if
      end if

      commit work

      --------------------[ gera registro de JIT ]--------------------

#display "* gravando JIT, cts00m17 "    # ruiz

      if param.ramcod = 31  or
         param.ramcod = 531 then
         if g_documento.lignum is null then
            let g_documento.lignum = ws.lignum
         end if
         if g_documento.c24soltipcod is null then
            let g_documento.c24soltipcod = 1
         end if
         if g_documento.solnom is null then
            let g_documento.solnom = "CARGA CTG"
         end if
         if g_documento.ligcvntip is null then
            let g_documento.ligcvntip = 0
         end if
         if g_c24paxnum is null then
            let g_c24paxnum = 0
         end if
      end if
      if param.ramcod <>  31  and
         param.ramcod <>  531 then
         ---------------------[ grava historico para RE ]----------------
         select max (c24txtseq)
             into ws.c24txtseq
             from datmsinhist
            where sinvstnum = ws.sinvstnum and
                  sinvstano = aux_ano4
         if ws.c24txtseq is null then
            let ws.c24txtseq = 0
         end if

         let ws.c24vstdsc = "** CTS35M00-CARGA CONTINGENCIA-seqregcnt = ",
                                l_datmcntsrv.seqregcnt
         let ws.c24txtseq = ws.c24txtseq + 1
         insert into datmsinhist ( sinvstnum ,
                                   sinvstano ,
                                   c24funmat ,
                                   lighorinc ,
                                   ligdat    ,
                                   c24txtseq ,
                                   c24vstdsc )
                values           ( ws.sinvstnum ,
                                   aux_ano4,
                                   l_datmcntsrv.funmat  ,
                                   l_datmcntsrv.atdhor  ,
                                   l_datmcntsrv.atddat  ,
                                   ws.c24txtseq         ,
                                   ws.c24vstdsc )
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
                                ws.sinvstnum             ,
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
                     ws.sinvstnum
           end if
           ---------[ grava relacionamento Atendimento X Ligacao ]-------------
           call ctd25g00_insere_atendimento(l_datmcntsrv.atdnum ,ws.lignum)
           returning ws.sqlcode,ws.msgerro
           if ws.sqlcode    <> 0 then
              rollback work
              return ws.msgerro,
                     ws.sqlcode,
                     ws.sinvstnum
           end if
      end if
      whenever error continue
      # atualiza "S" no campo prcflg
      execute pcts35m01005 using ws.sinvstnum,
                                 aux_ano2    ,
                                 l_datmcntsrv.seqreg
      whenever error stop
      if sqlca.sqlcode    <> 0 then
         rollback work
         let ws.msgerro = "Erro-datmcntsrv-pcts35m01005"
         let ws.sqlcode = sqlca.sqlcode
         return ws.msgerro,
                ws.sqlcode,
                ws.sinvstnum
      end if
      exit foreach

   end foreach
   return ws.msgerro,
          ws.sqlcode,
          ws.sinvstnum
end function

#------------------------------------------
function cts35m01_gera_numero_vistoria()
#------------------------------------------
 define l_data       date,
        l_hora2      datetime hour to minute

 define aux_grlchv    like igbkgeral.grlchv     ,
        aux_grlinf    like igbkgeral.grlinf     ,
        aux_sinvstnum like datmpedvist.sinvstnum,
        aux_vistoria  char (10)                 ,
        aux_atdsrvnum like datmservico.atdsrvnum,
        aux_atdsrvano like datmservico.atdsrvano,
        aux_retorno   integer,
        aux_msgerro   char (300)

 let aux_grlchv    = null
 let aux_grlinf    = null
 let aux_sinvstnum = null
 let aux_vistoria  = null
 let aux_atdsrvnum = null
 let aux_atdsrvano = null
 let aux_retorno   = null
 let aux_msgerro   = null
 let aux_ano2      = null
 let aux_ano4      = null
 let aux_today     = null
 let aux_hora      = null
 let l_data        = null
 let l_hora2       = null

 call cts40g03_data_hora_banco(2)
     returning l_data, l_hora2
 let aux_today  = l_data
 let aux_hora   = l_hora2
 let aux_ano4   = aux_today[7,10]
 let aux_ano2   = aux_today[9,10]

 let aux_grlchv = aux_ano2,"VSTSINRE"

 whenever error continue
 declare c_cts35m01_003 cursor with hold for
         select grlinf [1,6]
           from igbkgeral
          where mducod = "C24"      and
                grlchv = aux_grlchv
            for update
 foreach c_cts35m01_003 into aux_vistoria
    exit foreach
 end foreach

 if aux_vistoria is null then
    let aux_grlinf    = 400000             -- 700000 PSI 189685
    let aux_sinvstnum = 400000             -- 700000 PSI 189685

    begin work
    insert into igbkgeral ( mducod , grlinf ,
                            grlchv , atlult )
                  values  ( "C24"      ,
                            aux_grlinf ,
                            aux_grlchv ,
                            l_data      )

    if sqlca.sqlcode <> 0 then
       let aux_retorno = sqlca.sqlcode
       let aux_msgerro = "Erro na criacao do numero da vistoria"
       rollback work
       return aux_msgerro,
              aux_sinvstnum,
              aux_retorno
    end if
 else
    begin work
    declare c_cts35m01_004 cursor for
       select grlinf [1,6]
         from igbkgeral
        where mducod = "C24"      and
              grlchv = aux_grlchv
          for update

    foreach c_cts35m01_004  into aux_vistoria
       let aux_sinvstnum = aux_vistoria[1,6]
       let aux_sinvstnum = aux_sinvstnum + 1
       if aux_ano2 <> "04" then
          if aux_sinvstnum  > 499999 then      -- 749999 PSI 189685
             let aux_msgerro="Faixa de vistoria de sinistro para R.E. esgotada"
             rollback work
             return aux_msgerro,
                    aux_sinvstnum,
                    aux_retorno
           end if
       else
          if aux_sinvstnum  > 749999 then      -- 749999 PSI 189685
             let aux_msgerro="Faixa de vistoria de sinistro para R.E. esgotada"
             rollback work
             return aux_msgerro,
                    aux_sinvstnum,
                    aux_retorno
          end if
       end if
       update igbkgeral
          set (grlinf       , atlult) =
              (aux_sinvstnum, l_data)
        where mducod = "C24"
          and grlchv = aux_grlchv

       if sqlca.sqlcode <>  0  then
          let aux_retorno = sqlca.sqlcode
          let aux_msgerro = "Erro na gravacao da ultima vistoria de sinis RE."
          rollback work
          return aux_msgerro,
                 aux_sinvstnum,
                 aux_retorno
       end if
    end foreach
 end if
 return aux_msgerro,
        aux_sinvstnum,
        aux_retorno

end function

