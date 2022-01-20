#############################################################################
#Nome do Modulo: CTS00M10                                          Marcelo  #
#                                                                  Gilberto #
# Acompanhamento de servicos                                       Ago/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 25/09/1998  PSI 6479-3   Gilberto     Gravar campo SOCVCLCOD na tabela de #
#                                       acompanhamento DATMSRVACP.          #
#---------------------------------------------------------------------------#
# 16/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
# 03/02/2004  OSF 31682    Fabrica, Mariana                                 #
#                                       Incluir consistencia para etapa 38- #
#                                       (Recusado)                          #
#                                                                           #
# 07/03/2005  PSI190772    Robson, Meta Alterar a chamada ao programa       #
#                                       cta02m02() por                      #
#                                       cta02m02_consultar_ligacoes()       #
#                                                                           #
# 21/09/2006  psi202720    Ruiz         Implementacao das apolices Saude.   #
#                                       cta02m02_consultar_ligacoes()       #
#                                                                           #
# 13/11/2012  PSI-2012-28815/EV Burini  Melhorias na tela de Acompanhamento #
#                                                                           #
#############################################################################
#############################################################################

globals '/homedsa/projetos/geral/globals/glct.4gl'

#--------------------------------------------------------------------
 function cts00m10()
#--------------------------------------------------------------------

 define d_cts00m10      record
        etpdat          like datmsrvacp.atdetpdat      ,
        etphorini       like datmsrvacp.atdetphor      ,
        etphorfim       like datmsrvacp.atdetphor      ,
        atdsrvorg       like datksrvtip.atdsrvorg      ,
        srvtipdes       like datksrvtip.srvtipabvdes   ,
        empcod          char(02)                       ,
        etpcod          like datketapa.atdetpcod       ,
        etpdes          like datketapa.atdetpdes       ,
        atdsrvnum       like datmsrvacp.atdsrvnum      ,
        atdsrvano       like datmsrvacp.atdsrvano      ,
        pstcoddig       like dpaksocor.pstcoddig       ,
        nomgrr          like dpaksocor.nomgrr          ,
        atdvclsgl       like datkveiculo.atdvclsgl     ,
        vcldtbgrpcod    like datkvcldtbgrp.vcldtbgrpcod,
        dstiniqth       char(001),
        srvidx          char(001),
        ultatv          char(003),
        ordlst          char(001),
        totqtd          char (12)                      ,
        agora           datetime hour to second
                        end record

 define ws              record
        sql             char (1500)                  ,
        condicao        char (500)                   ,
        totqtd          smallint                     ,
        retflg          dec (1,0)                    ,
        succod          like datrservapol.succod     ,
        ramcod          like datrservapol.ramcod     ,
        aplnumdig       like datrservapol.aplnumdig  ,
        itmnumdig       like datrservapol.itmnumdig  ,
        atdsrvseq       like datmsrvacp.atdsrvseq    ,
        prietpcod       like datmsrvacp.atdetpcod    ,
        atdetpcod       like datmsrvacp.atdetpcod    ,
        atdetpdes       like datketapa.atdetpdes     ,
        atdetptipcod    like datketapa.atdetptipcod  ,
        atdsrvetpstt    like datrsrvetp.atdsrvetpstt ,
        atdetpdat       like datmsrvacp.atdetpdat    ,
        atdetphor       like datmsrvacp.atdetphor    ,
        fnletpdat       like datmsrvacp.atdetpdat    ,
        fnletphor       like datmsrvacp.atdetphor    ,
        socopgnum       like dbsmopgitm.socopgnum    ,
        sqlcode         integer,
        crtnum          like datrsrvsau.crtnum
 end record

 define a_cts00m10      array[1500] of record
        tipprg          char(005),
        empsgl          like gabkemp.empsgl,
        servico         char(015),
        hracmb          datetime hour to minute,
        diacmb          char(5),
        etpdessrv       char(008),
        pstcoddigsrv    like dpaksocor.pstcoddig,
        nomgrrsrv       like dpaksocor.nomgrr,
        atdvclsglsrv    like datkveiculo.atdvclsgl,
        ultatvvcl       char(80)
 end record

 define a_cts00m1x      array[1500] of record
        atdsrvnum       like datmservico.atdsrvnum   ,
        atdsrvano       like datmservico.atdsrvano   ,
        atdsrvorg       like datmservico.atdsrvorg   ,
        c24nomctt       like datmsrvacp.c24nomctt    ,
        atdmotnom       like datmsrvacp.atdmotnom    ,
        srrcoddig       like datmsrvacp.srrcoddig    ,
        socvclcod       like datmsrvacp.socvclcod    ,
        atdvclsgl       like datmsrvacp.atdvclsgl    ,
        ultsrvseq       like datmsrvacp.atdsrvseq
 end record

 define lr_retemp     record
        erro           smallint,
        ciaempcod      char(02),
        empnom         like gabkemp.empnom
 end record

 define lr_retorno    record
        erro           smallint,
        msg            char(100),
        empsgl         char(020)
 end record

 define lr_aux        record
        atdsrvnum       like datmservico.atdsrvnum,
        atdsrvano       like datmservico.atdsrvano,
        atdsrvorg       like datmservico.atdsrvorg,
        atddatprg       like datmservico.atddatprg,
        atdhorprg       like datmservico.atdhorprg,
        atdhorpvt       like datmservico.atdhorpvt,
        atdlibdat       like datmservico.atdlibdat,
        atdlibhor       like datmservico.atdlibhor,
        srvprsacnhordat like datmservico.srvprsacnhordat,
        atdetpcod       like datmservico.atdetpcod,
        atdprscod       like dpaksocor.pstcoddig,
        nomgrr          like dpaksocor.nomgrr,
        atdvclsgl       like datkveiculo.atdvclsgl,
        envtipcod       like iddkdominio.cpocod,
        lclltt          like datmlcl.lclltt,
        lcllgt          like datmlcl.lcllgt,
        empcod          like gabkemp.empsgl,
        dstini          decimal(8,2),
        envtipdes       like iddkdominio.cpodes,
        rechor          datetime hour to minute,
        inihor          datetime hour to minute,
        ultatvvcl       char(3),
        hraultatv       datetime hour to minute,
        dathorcomchr    char(20),
        dathorcom       datetime year to minute,
        horsum          interval hour(06) to second,
        horminlim       like datmsrvacp.atdetphor,
        hormaxlim       like datmsrvacp.atdetphor,
        etphorinichr    char(20),
        etphorfimchr    char(20),
        etphorini       datetime year to minute,
        etphorfim       datetime year to minute,
        texto           char(100)


 end record

 define l_atvbto       char(003)
 define arr_aux        smallint
 define scr_aux        smallint
 define l_dstqth       decimal(8,2)
 define l_dstqthdsc    char(01)
 define l_hor          char(02)
 define l_min          char(02)
 define l_tmoacpsrvfim smallint
 define l_tmoacpsrvini smallint
 define l_current      datetime hour to minute
 define l_horaini      char(02)
 define l_horafim      char(02)
 define l_now          datetime hour to second
 define l_display      smallint

 define lr_gps       record
     caddatrec           date,
     cadhorrec           datetime hour to minute,
     caddatini           date,
     cadhorini           datetime hour to minute,
     lcllttini           decimal(8,6),
     lcllgtini           decimal(9,6),
     dstini              dec(8,4),
     caddatfim           date,
     cadhorfim           datetime hour to minute,
     lclltt              decimal(8,6),
     lcllgt              decimal(9,6)

 end record

 define l_sql char (1000)
       ,l_achei smallint
 define l_mdtcod       like datmmdtmvt.mdtcod
       ,l_tip          smallint
       ,l_mdtcod2      like datmmdtmvt.mdtcod
       ,l_mdtbotprgseq like datmmdtmvt.mdtbotprgseq
       ,l_mdtmvttipcod like datmmdtmvt.mdtmvttipcod
       ,l_mdtmvtstt    like datmmdtmvt.mdtmvtstt
#--------------------------------------------------------------------
# Preparacao dos comandos SQL
#--------------------------------------------------------------------

 define w_pf1 integer

 let arr_aux  =  null
 let scr_aux  =  null
 let l_sql = null
 for w_pf1  =  1  to  1500
    initialize  a_cts00m10[w_pf1].*  to  null
 end for

 for w_pf1  =  1  to  1500
    initialize  a_cts00m1x[w_pf1].*  to  null
 end for

 initialize  d_cts00m10.*  to  null

 initialize  ws.*  to  null

 set isolation to dirty read
 let ws.sql = "select srvtipabvdes ",
              "  from datksrvtip   ",
              " where atdsrvorg = ?   "
 prepare p_cts00m10_001 from ws.sql
 declare c_cts00m10_001 cursor with hold for p_cts00m10_001

 let ws.sql = "select atdetpdes,   ",
              "       atdetptipcod ",
              "  from datketapa    ",
              " where atdetpcod = ?"
 prepare p_cts00m10_002 from ws.sql
 declare c_cts00m10_002 cursor with hold for p_cts00m10_002

 let ws.sql = "select atdsrvetpstt      ",
              "  from datrsrvetp        ",
              " where atdetpcod = ?  and",
              "       atdsrvorg    = ?     "
 prepare p_cts00m10_003 from ws.sql
 declare c_cts00m10_003 cursor with hold for p_cts00m10_003

 let ws.sql = "select atdsrvorg,        ",
              "       atddatprg,        ",
              "       atdhorprg         ",
              "  from datmservico       ",
              " where atdsrvnum = ?  and",
              "       atdsrvano = ?     "
 prepare p_cts00m10_004 from ws.sql
 declare c_cts00m10_004 cursor with hold for p_cts00m10_004

 let ws.sql = "select max(atdsrvseq)    ",
              "  from datmsrvacp        ",
              " where atdsrvnum = ?  and",
              "       atdsrvano = ?     "
 prepare p_cts00m10_005  from ws.sql
 declare c_cts00m10_005  cursor with hold for p_cts00m10_005

 let ws.sql = "select datmsrvacp.atdetpcod,",
              "       datmsrvacp.pstcoddig,",
              "       dpaksocor.nomgrr    ,",
              "       datmsrvacp.atdmotnom,",
              "       datmsrvacp.srrcoddig,",
              "       datmsrvacp.socvclcod,",
              "       datmsrvacp.atdvclsgl,",
              "       datmsrvacp.c24nomctt ",
              "  from datmsrvacp, outer dpaksocor     ",
              " where datmsrvacp.atdsrvnum = ?  and   ",
              "       datmsrvacp.atdsrvano = ?  and   ",
              "       datmsrvacp.atdsrvseq = ?  and   ",
              "       datmsrvacp.pstcoddig = dpaksocor.pstcoddig"
 prepare p_cts00m10_006 from ws.sql
 declare c_cts00m10_006 cursor with hold for p_cts00m10_006

 let ws.sql = "select dbsmopg.socopgnum   ",
              "  from dbsmopgitm, dbsmopg ",
              " where dbsmopgitm.atdsrvnum = ?                     and",
              "       dbsmopgitm.atdsrvano = ?                     and",
              "       dbsmopg.socopgnum    = dbsmopgitm.socopgnum  and",
              "       dbsmopg.socopgsitcod <> 8                       "
 prepare p_cts00m10_007 from ws.sql
 declare c_cts00m10_007 cursor with hold for p_cts00m10_007

 let ws.sql = "select datketapa.atdetptipcod,        ",
              "       datmsrvacp.atdetpdat  ,        ",
              "       datmsrvacp.atdetphor           ",
              "  from datmsrvacp, datketapa          ",
              " where datmsrvacp.atdsrvnum  =  ?  and",
              "       datmsrvacp.atdsrvano  =  ?  and",
              "       datmsrvacp.atdsrvseq  =  ?  and",
              "       datmsrvacp.atdetpcod  =  datketapa.atdetpcod"
 prepare p_cts00m10_008 from ws.sql
 declare c_cts00m10_008 cursor with hold for p_cts00m10_008

 let ws.sql = "select datmsrvacp.atdetpdat,          ",
              "       datmsrvacp.atdetphor           ",
              "  from datmsrvacp                     ",
              " where atdsrvnum  =  ?   and          ",
              "       atdsrvano  =  ?   and          ",
              "       atdetpcod  =  1                "
 prepare p_cts00m10_009     from ws.sql
 declare c_cts00m10_009     cursor with hold for p_cts00m10_009


 open window w_cts00m10 at 04,02 with form "cts00m10"
             attribute(border, form line first, message line last)

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------
 initialize a_cts00m10     to null
 initialize a_cts00m1x     to null
 initialize ws.*           to null
 initialize lr_gps.*       to null
 initialize l_tmoacpsrvfim to null
 initialize l_tmoacpsrvini to null
 initialize l_current      to null
 initialize l_horaini      to null
 initialize l_horafim      to null
 initialize l_dstqth       to null
 initialize l_display      to null

 whenever error continue
    select 1
      from iddkdominio
    where cponom = 'PSOATLUSRPOR'
      and cpodes = g_issk.funmat
    if sqlca.sqlcode = 0 then
       let l_display = true
    else
       let l_display = false
    end if
 whenever error stop


 call cts00m10_create_temp()

 while true
    let int_flag             = false

    initialize d_cts00m10.*  to null

    let d_cts00m10.agora     = current
    let d_cts00m10.totqtd    = null

    clear form
    display by name d_cts00m10.*

    options comment line last

    input by name d_cts00m10.atdsrvnum,
                  d_cts00m10.atdsrvano,
                  d_cts00m10.etpdat,
                  d_cts00m10.etphorini,
                  d_cts00m10.etphorfim,
                  d_cts00m10.atdsrvorg,
                  d_cts00m10.etpcod   ,
                  d_cts00m10.pstcoddig,
                  d_cts00m10.atdvclsgl,
                  d_cts00m10.empcod   ,
                  d_cts00m10.vcldtbgrpcod,
                  d_cts00m10.srvidx,
                  d_cts00m10.dstiniqth,
                  d_cts00m10.ultatv,
                  d_cts00m10.ordlst  without defaults

       before field atdsrvnum
          display by name d_cts00m10.atdsrvnum  attribute (reverse)

       after  field atdsrvnum
          display by name d_cts00m10.atdsrvnum

             if d_cts00m10.atdsrvnum is null  then
                let d_cts00m10.atdsrvano = ''
                display by name d_cts00m10.atdsrvano
                next field etpdat
             end if


       before field atdsrvano
          display by name d_cts00m10.atdsrvano  attribute (reverse)

       after  field atdsrvano
          display by name d_cts00m10.atdsrvano

          if  d_cts00m10.atdsrvano is not null  then
              open  c_cts00m10_004 using d_cts00m10.atdsrvnum, d_cts00m10.atdsrvano
              fetch c_cts00m10_004

              if sqlca.sqlcode = notfound  then
                 error " Servico ", d_cts00m10.atdsrvnum using "&&&&&&&", "-", d_cts00m10.atdsrvano using "&&", " nao encontrado!"
                 let d_cts00m10.atdsrvnum = ''
                 let d_cts00m10.atdsrvano = ''
                 display by name d_cts00m10.atdsrvnum
                 display by name d_cts00m10.atdsrvano
                 next field atdsrvnum
              else
                 exit input
              end if
              close c_cts00m10_004
          end if

       before field etpdat

          if  d_cts00m10.etpdat is null then
              let d_cts00m10.etpdat = today
          end if
          display by name d_cts00m10.etpdat  attribute (reverse)

       after  field etpdat
          display by name d_cts00m10.etpdat

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             let d_cts00m10.etpdat    = ''
             let d_cts00m10.etphorini = ''
             let d_cts00m10.etphorfim = ''
             display by name d_cts00m10.etpdat
             display by name d_cts00m10.etphorini
             display by name d_cts00m10.etphorfim
             next field atdsrvnum
          end if

          if d_cts00m10.etpdat is null  then
             let d_cts00m10.etpdat = today
          end if

          display by name d_cts00m10.etpdat

       before field etphorini
          if  d_cts00m10.etphorini is null or d_cts00m10.etphorini = " " then

              let l_current = current

              if  l_current >= '00:30' then
                  let d_cts00m10.etphorini = l_current - 30 units minute
              else
                  let d_cts00m10.etphorini = '00:00'
              end if

              next field etphorini
          end if

       after field etphorini
          display by name d_cts00m10.etphorini

          if  d_cts00m10.etphorini is null or d_cts00m10.etphorini = " " then

              let l_current = current

              if  l_current >= '00:30' then
                  let d_cts00m10.etphorini = l_current - 30 units minute
              else
                  let d_cts00m10.etphorini = '00:00'
              end if

              next field etphorini
          end if

       before field etphorfim
          display by name d_cts00m10.etphorfim  attribute (reverse)

          if  d_cts00m10.etphorfim is null or d_cts00m10.etphorfim = " " then

              if  d_cts00m10.etphorini >= '23:30' then
                  let d_cts00m10.etphorfim = '23:59'
              else
                  let d_cts00m10.etphorfim = d_cts00m10.etphorini + 1 units hour
              end if

              display by name d_cts00m10.etphorfim

          end if

       after field etphorfim
          display by name d_cts00m10.etphorfim

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field etphorini
          end if

          if  d_cts00m10.etphorfim is null or d_cts00m10.etphorfim = " " then

              if  d_cts00m10.etphorini >= '23:30' then
                  let d_cts00m10.etphorfim = '23:59'
              else
                  let d_cts00m10.etphorfim = d_cts00m10.etphorini + 30 units minute
              end if

              display by name d_cts00m10.etphorfim

          end if

          if  d_cts00m10.etphorini > d_cts00m10.etphorfim then
              error "Hora final deve ser maior que a hora inicial"
              next field etphorfim
          end if

       before field atdsrvorg
          display by name d_cts00m10.atdsrvorg  attribute (reverse)

       after  field atdsrvorg
          display by name d_cts00m10.atdsrvorg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field etphorfim
          end if

          if d_cts00m10.atdsrvorg is null  or
             d_cts00m10.atdsrvorg =  " "   then
             let d_cts00m10.srvtipdes = ""
             display by name d_cts00m10.srvtipdes
             error " Um tipo de servico deve ser informado!"
             call cts00m09() returning d_cts00m10.atdsrvorg
             next field atdsrvorg
          else
             open  c_cts00m10_001 using d_cts00m10.atdsrvorg
             fetch c_cts00m10_001 into  d_cts00m10.srvtipdes
             if sqlca.sqlcode = notfound  then
                error " Tipo de servico invalido!"
                call cts00m09() returning d_cts00m10.atdsrvorg
                next field atdsrvorg
             end if
             close c_cts00m10_001
          end if

          display by name d_cts00m10.srvtipdes

       before field empcod
          display by name d_cts00m10.empcod  attribute (reverse)

       after  field empcod
          display by name d_cts00m10.atdsrvorg

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field atdvclsgl
          end if

          if d_cts00m10.empcod is null  or
             d_cts00m10.empcod =  " "   then
             let d_cts00m10.empcod = "TD"
             display by name d_cts00m10.empcod
          else
             if  d_cts00m10.empcod <> "TD" then
                 call cty14g00_empresa_abv(d_cts00m10.empcod) returning lr_retorno.*

                 if  lr_retorno.empsgl = 'N/D' then

                     error " Empresa invalida."
                     let d_cts00m10.empcod = ""

                     call cty14g00_popup_empresa() returning lr_retemp.*
                     let d_cts00m10.empcod = lr_retemp.ciaempcod
                     next field empcod

                     display by name d_cts00m10.empcod
                     next field empcod

                 end if
             end if

          end if

          display by name d_cts00m10.srvtipdes

       before field etpcod
          display by name d_cts00m10.etpcod     attribute (reverse)

       after  field etpcod
          display by name d_cts00m10.etpcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field atdsrvorg
          end if

          if d_cts00m10.etpcod is null  then
             let d_cts00m10.etpdes = "TODAS ETAPAS"
          else
             open  c_cts00m10_002 using d_cts00m10.etpcod
             fetch c_cts00m10_002 into  d_cts00m10.etpdes, ws.atdetptipcod
             if sqlca.sqlcode = notfound  then
                error " Etapa invalida!"
                call ctn26c00(d_cts00m10.atdsrvorg)
                    returning d_cts00m10.etpcod
                next field etpcod
             end if
             close c_cts00m10_002

             initialize ws.atdsrvetpstt to null

             if d_cts00m10.atdsrvorg is not null  then
                open  c_cts00m10_003 using d_cts00m10.etpcod,
                                         d_cts00m10.atdsrvorg
                fetch c_cts00m10_003 into  ws.atdsrvetpstt
                close c_cts00m10_003

                if ws.atdsrvetpstt = "A"  then
                else
                   error " Etapa nao pertence a este tipo de servico!"
                   call ctn26c00(d_cts00m10.atdsrvorg)
                       returning d_cts00m10.etpcod
                   next field etpcod
                end if
             end if
          end if

          display by name d_cts00m10.etpcod
          display by name d_cts00m10.etpdes

       before field pstcoddig
          display by name d_cts00m10.pstcoddig  attribute (reverse)

       after  field pstcoddig
          display by name d_cts00m10.pstcoddig

          if  d_cts00m10.pstcoddig is not null and
              d_cts00m10.pstcoddig <> " " then

              whenever error continue
              select nomgrr
                into d_cts00m10.nomgrr
                from dpaksocor
               where pstcoddig = d_cts00m10.pstcoddig
              whenever error stop

              if  sqlca.sqlcode = notfound then
                  error "Prestador não encontrado"
                  let d_cts00m10.nomgrr = ""
                  display by name d_cts00m10.nomgrr
                  call ctn24c00() returning d_cts00m10.pstcoddig
                  next field pstcoddig
              else
                  display by name d_cts00m10.nomgrr
                  next field atdvclsgl
              end if

          end if

       before field atdvclsgl
          display by name d_cts00m10.atdvclsgl  attribute (reverse)

       after  field atdvclsgl
          display by name d_cts00m10.atdvclsgl

          if  d_cts00m10.atdvclsgl is not null and
              d_cts00m10.atdvclsgl <> " " then

              whenever error stop
              select 1
                from datkveiculo
               where atdvclsgl = d_cts00m10.atdvclsgl
              whenever error continue

              if  sqlca.sqlcode = notfound then
                  error "Viatura não encontrada"
                  let d_cts00m10.atdvclsgl = ""
                  display by name d_cts00m10.atdvclsgl
                  next field atdvclsgl
              end if

          end if

       before field vcldtbgrpcod
          display by name d_cts00m10.vcldtbgrpcod  attribute (reverse)

       after  field vcldtbgrpcod
          display by name d_cts00m10.vcldtbgrpcod

          if  d_cts00m10.vcldtbgrpcod is not null and
              d_cts00m10.vcldtbgrpcod <> " " then

              whenever error stop
                select 1
                  from datkvcldtbgrp
                 where datkvcldtbgrp.vcldtbgrpstt  =  "A"
                   and vcldtbgrpcod = d_cts00m10.vcldtbgrpcod
              whenever error continue

              if  sqlca.sqlcode = notfound then
                  error "Grupo de distribuição não encontrado"
                  let d_cts00m10.vcldtbgrpcod = ""
                  display by name d_cts00m10.vcldtbgrpcod
                  call ctn39c00() returning d_cts00m10.vcldtbgrpcod
                  next field vcldtbgrpcod
              end if

          end if

       before field dstiniqth
          let d_cts00m10.dstiniqth = "T"
          display by name d_cts00m10.dstiniqth

       after  field dstiniqth

          if  d_cts00m10.dstiniqth is null or
              d_cts00m10.dstiniqth = " " then
              let d_cts00m10.dstiniqth = "T"
          else
              if  d_cts00m10.dstiniqth <> "L" and
                  d_cts00m10.dstiniqth <> "P" and
                  d_cts00m10.dstiniqth <> "T" then
                  error "Opcao invalida."
                  let d_cts00m10.dstiniqth = ""
                  next field dstiniqth
              end if
          end if

          display by name d_cts00m10.dstiniqth


       before field srvidx

          let d_cts00m10.srvidx = "T"
          display by name d_cts00m10.srvidx

       after field srvidx

          if  d_cts00m10.srvidx is null or
              d_cts00m10.srvidx = " " then
              let d_cts00m10.srvidx = "T"
          else
              if  d_cts00m10.srvidx <> "S" and
                  d_cts00m10.srvidx <> "N" and
                  d_cts00m10.srvidx <> "T" then
                  error "Opcao invalida."
                  let d_cts00m10.srvidx = ""
                  next field srvidx
              end if
          end if

          display by name d_cts00m10.srvidx

       after field ultatv

          if  d_cts00m10.ultatv is not null and
              d_cts00m10.ultatv <> " " then

              if d_cts00m10.ultatv  <> "QTP"   and
                 d_cts00m10.ultatv  <> "QRX"   and
                 d_cts00m10.ultatv  <> "QRV"   and
                 d_cts00m10.ultatv  <> "QRA"   and
                 d_cts00m10.ultatv  <> "QRU"   and
                 d_cts00m10.ultatv  <> "REC"   and
                 d_cts00m10.ultatv  <> "INI"   and
                 d_cts00m10.ultatv  <> "REM"   and
                 d_cts00m10.ultatv  <> "FIM"   and
                 d_cts00m10.ultatv  <> "NIL"   and
                 d_cts00m10.ultatv  <> "RET"   and
                 d_cts00m10.ultatv  <> "ROD"   then
                 error " Codigo da atividade invalido!"
                 let d_cts00m10.ultatv = ""
                 display by name d_cts00m10.ultatv
                 next field ultatv
              end if

          else
              let d_cts00m10.ordlst = "D"
          end if

       after field ordlst

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field ultatv
          end if

          if  d_cts00m10.ordlst is not null and
              d_cts00m10.ordlst <> " " then

              if  d_cts00m10.ordlst <> "D" and
                  d_cts00m10.ordlst <> "U" then
                  error "Opcao invalida."
                  let d_cts00m10.ordlst = ""
                  next field ordlst
              end if
          else
              let d_cts00m10.ordlst = "D"
              next field ordlst
          end if

       on key (interrupt)
          let int_flag = true
          exit input
    end input

    if int_flag = true  then
       let arr_aux = 1
       initialize a_cts00m10[arr_aux].* to null
       exit while
    end if

    while true

      delete from temp_srvacpcom

      whenever error continue
      select grlinf
        into l_dstqth
        from datkgeral
       where grlchv = 'PSOQTHDSTACP'
      whenever error stop

      if  l_dstqth is null or l_dstqth = ' ' then
          let l_dstqth = 0.500
      end if

      initialize a_cts00m10  to null

      message " Aguarde, pesquisando..."  attribute(reverse)

      let ws.totqtd = 0
      let arr_aux   = 1

      let ws.sql = "select acp.atdsrvnum , ",
                         " acp.atdsrvano , ",
                         " srv.atdsrvorg,  ",
                         " srv.atddatprg, ",
                         " srv.atdhorprg, ",
                         " srv.ciaempcod,    ",
                         " srv.atdlibdat, ",
                         " srv.atdlibhor, ",
                         " srv.atdhorpvt, ",
                         " srv.srvprsacnhordat, ",
                         " acp.atdetpcod, ",
                         " srv.atdprscod, ",
                         " vcl.atdvclsgl, ",
                         " acp.envtipcod, ",
                         " lcl.lclltt, ",
                         " lcl.lcllgt ",
                    " from datmservico    srv, ",
                         " datmsrvacp     acp, "

      if  d_cts00m10.atdvclsgl is not null and d_cts00m10.atdvclsgl <> " " then
          let ws.sql = ws.sql clipped,  " datkveiculo    vcl, "
      else
          let ws.sql = ws.sql clipped,  " outer datkveiculo vcl, "
      end if

      let ws.sql = ws.sql clipped,  " datmlcl        lcl, ",
                      " outer dpaksocor      pst "

      # FILTRA GRUPO DE DISTRIBUIÇÃO - INCLUIR TABELA DE FROTA LOCAL
      if  d_cts00m10.vcldtbgrpcod is not null and d_cts00m10.vcldtbgrpcod <> " " then
          let ws.sql = ws.sql clipped, ", dattfrotalocal frt "
      end if

      let ws.sql = ws.sql clipped, " where "

      # CASO PROCURE UM SERVIÇO ESPECIFICO
      if d_cts00m10.atdsrvnum is not null  and
         d_cts00m10.atdsrvano is not null  then
         let ws.sql = ws.sql clipped, "     srv.atdsrvnum    = ", d_cts00m10.atdsrvnum,
                                      " and srv.atdsrvano    = ", d_cts00m10.atdsrvano
      else
         # FILTRA POR ETAPA
         if  d_cts00m10.etpdat is not null then
             let ws.sql = ws.sql clipped, " acp.atdetpdat = '", d_cts00m10.etpdat, "'"
         end if

         # MONTA O PERIODO DE EXTRAÇÃO
         if  d_cts00m10.etphorini is not null and
             d_cts00m10.etphorfim is not null then

             whenever error continue
             select grlinf
               into l_tmoacpsrvini
               from datkgeral
              where grlchv = 'PSOTMPACPSRVINI'
             whenever error stop

             if  sqlca.sqlcode <> 0 then
                 let l_tmoacpsrvini = 1
             end if

             whenever error continue
             select grlinf
               into l_tmoacpsrvfim
               from datkgeral
              where grlchv = 'PSOTMPACPSRVFIM'
             whenever error stop

             if  sqlca.sqlcode <> 0 then
                 let l_tmoacpsrvfim = 1
             end if

             let l_horaini = extend(d_cts00m10.etphorini, hour to hour)
             let l_horafim = extend(d_cts00m10.etphorfim, hour to hour)

             # CASO A HORA INICIAL SEJA MENOR DE 01:00, SETAMOS A INICIAL PARA 00:00
             if  (d_cts00m10.etphorini <= '01:00') or (l_horaini < l_tmoacpsrvini) then
                 let lr_aux.horminlim = '00:00'
             else
                 let lr_aux.horminlim = d_cts00m10.etphorini - l_tmoacpsrvini units hour
             end if

             let l_horafim = l_horafim + l_tmoacpsrvfim

             # CASO A HORA FINAL SEJA MAIOR DE 23:00, SETAMOS A FINAL PARA 23:59
             if  d_cts00m10.etphorfim >= '23:00' or (l_horafim > 23) then
                 let lr_aux.hormaxlim = '23:59'
             else
                 let lr_aux.hormaxlim = d_cts00m10.etphorfim + l_tmoacpsrvfim units hour
             end if

             let ws.sql = ws.sql clipped, " and acp.atdetphor between '", lr_aux.horminlim, "' and '", lr_aux.hormaxlim, "'"
         end if

         # FILTRO POR EMPRESA
         if  d_cts00m10.empcod is not null  and d_cts00m10.empcod <> 'TD' then
             let ws.sql = ws.sql clipped, " and srv.ciaempcod = ", d_cts00m10.empcod
         end if

         # FILTRO POR ETAPA
         if  d_cts00m10.etpcod is not null  then
             let ws.sql = ws.sql clipped, " and srv.atdetpcod = ", d_cts00m10.etpcod
         end if

         #FILTRO POR PRESTADOR
         if  d_cts00m10.pstcoddig is not null  then
             let ws.sql = ws.sql clipped, " and srv.atdprscod = ", d_cts00m10.pstcoddig
         end if

         # FILTRO POR ORIGEM
         if  d_cts00m10.atdsrvorg is not null  then
             let ws.sql = ws.sql clipped, " and srv.atdsrvorg = ", d_cts00m10.atdsrvorg
         end if

         # FILTRA POR VIATURA
         if  d_cts00m10.atdvclsgl is not null  then
             let ws.sql = ws.sql clipped, " and vcl.atdvclsgl = '", d_cts00m10.atdvclsgl clipped, "'"
         end if

         # FILTRO POR SERVIÇOS INDEXADOS (QUANDO O SERVIÇO É INDEXADO O CÓDIGO SERÁ 3)
         if  d_cts00m10.srvidx = 'S'  then
             let ws.sql = ws.sql clipped, "    and lcl.c24lclpdrcod = 3 "
         else
             if  d_cts00m10.srvidx = 'N'  then
                 let ws.sql = ws.sql clipped, "    and lcl.c24lclpdrcod <> 3 "
             end if
         end if

         # FILTRA GRUPO DE DISTRIBUIÇÃO - INCLUI O FILTRO
         if  d_cts00m10.vcldtbgrpcod is not null and d_cts00m10.vcldtbgrpcod <> " " then
             let ws.sql = ws.sql clipped, " and frt.vcldtbgrpcod = ", d_cts00m10.vcldtbgrpcod,
                                          " and frt.socvclcod	 = vcl.socvclcod ",
                                          " and acp.srrcoddig    = frt.srrcoddig ",
                                          " and srv.atdprscod    = vcl.pstcoddig ",
                                          " and srv.socvclcod    = vcl.socvclcod "
         end if

      end if

      let ws.sql = ws.sql clipped, " and srv.atdsrvnum    = acp.atdsrvnum ",
                                   " and srv.atdsrvano    = acp.atdsrvano ",
                                   " and srv.atdsrvnum    = lcl.atdsrvnum ",
                                   " and srv.atdsrvano    = lcl.atdsrvano ",
                                   " and srv.atdprscod    = pst.pstcoddig ",
                                   " and lcl.c24endtip    = 1 ",
                                   " and srv.atdsrvseq    = acp.atdsrvseq ",
                                   " and acp.socvclcod    = vcl.socvclcod "

      prepare p_cts00m10_010 from ws.sql
      declare c_cts00m10_010 cursor for p_cts00m10_010

      initialize lr_aux.* to null

      if l_display then
         display 'ws.sql: ', ws.sql clipped
         let l_now = current
         display 'Pesquisando a principal', 'às ', l_now
      end if

      message " Aguarde, pesquisando..."  attribute(reverse)


    let l_sql = 'select caddat, cadhor, lclltt, lcllgt'
              , '      ,mdtcod, mdtmvttipcod, mdtmvtstt, mdtbotprgseq '
              ,'   from datmmdtmvt  mvt '
              ,'  where atdsrvnum     = ?  '
              ,'    and atdsrvano     = ?  '
              ,'  order by mvt.caddat, mvt.cadhor     '

 prepare pq_sinaisgps from l_sql
 declare cq_sinaisgps cursor for pq_sinaisgps

 let l_achei = false

      open c_cts00m10_010
      foreach c_cts00m10_010 into  lr_aux.atdsrvnum ,
                                   lr_aux.atdsrvano,
                                   lr_aux.atdsrvorg,
                                   lr_aux.atddatprg,
                                   lr_aux.atdhorprg,
                                   lr_aux.empcod,
                                   lr_aux.atdlibdat,
                                   lr_aux.atdlibhor,
                                   lr_aux.atdhorpvt,
                                   lr_aux.srvprsacnhordat,
                                   lr_aux.atdetpcod,
                                   lr_aux.atdprscod,
                                   lr_aux.atdvclsgl,
                                   lr_aux.envtipcod,
                                   lr_aux.lclltt,
                                   lr_aux.lcllgt

          let lr_aux.dathorcom = ''
          let lr_aux.dathorcomchr = ''
          let lr_aux.ultatvvcl = ''
          let lr_aux.hraultatv = ''
          let l_min = ''
          let l_hor = ''
          let lr_aux.dstini = ''
          initialize lr_gps.* to null

          #----------------- CALCULANDO A HORA COMBINADA COM O CLIENTE -----------------#
          if (lr_aux.atddatprg is not null and  lr_aux.atddatprg <> ' ') and
             (lr_aux.atdhorprg is not null and  lr_aux.atdhorprg <> ' ') then
              # SE A HORA DO SERVIÇO FOR PROGRAMADO, A HORA COMBINADA SERÁ A MESMA DA PROGRAMADA
              let lr_aux.dathorcomchr = extend(lr_aux.atddatprg,year to day)," ", lr_aux.atdhorprg
          else
              let lr_aux.dathorcomchr = extend(lr_aux.atdlibdat,year to day)," ", lr_aux.atdlibhor

              # ADICIONA A PREVISÃO APENAS SE ELA NAO FOR NULA
              if  lr_aux.atdhorpvt is not null and lr_aux.atdhorpvt <> ' ' then

                  # TRANSFORMA O CHAR PARA DATETIME YEAR TO SECOND
                  let lr_aux.dathorcom = lr_aux.dathorcomchr

                  # ADICIONA A HORA DA PREVISÃO
                  let l_hor = extend(lr_aux.atdhorpvt, hour to hour)
                  let l_min = extend(lr_aux.atdhorpvt, minute to minute)
                  let lr_aux.dathorcom = lr_aux.dathorcom + l_min units minute
                  let lr_aux.dathorcom = lr_aux.dathorcom + l_hor units hour
                  let lr_aux.dathorcomchr = lr_aux.dathorcom

              end if
          end if
          if l_display then
             let l_now = current
             display 'Terminou calculo da hora combinada ', 'às ', l_now,lr_aux.atdsrvnum, '-',lr_aux.atdsrvano
          end if
          #-----------------------------------------------------------------------------#

          #----------- CASO O SERVIÇO SEJA ACIONADO VIA GPS VERIFICA SINAIS -------------#

          initialize lr_gps.* to null

          if  lr_aux.envtipcod = 1 then

              whenever error continue
                 if lr_aux.atdvclsgl is not null then

                    select mdtcod
                      into l_mdtcod
                      from datkveiculo
                     where atdvclsgl = lr_aux.atdvclsgl
                    if sqlca.sqlcode = 100 then
                       continue foreach
                    end if
              end if
              whenever error stop

              #----- BUSCA SINAL DO REC -----#
              let l_tip = 1
              if lr_aux.atdvclsgl is not null then
                 let l_achei = false
                 open cq_sinaisgps using  lr_aux.atdsrvnum, lr_aux.atdsrvano #, l_mdtcod, l_tip
                 foreach cq_sinaisgps into lr_gps.caddatrec, lr_gps.cadhorrec
                                           ,lr_gps.lclltt
                                           ,lr_gps.lcllgt
                                           ,l_mdtcod2
                                           ,l_mdtmvttipcod
                                           ,l_mdtmvtstt
                                           ,l_mdtbotprgseq

                    if l_mdtcod2      = l_mdtcod and
                       l_mdtmvttipcod = 2        and
                       l_mdtmvtstt    = 2        and
                       l_mdtbotprgseq = l_tip    then
                       let l_achei = true
                       exit foreach
                    else
                       let l_achei = false
                    end if
                 end foreach
                 if  l_achei then
                  # UTLIMA ATIVIDADE REC
                  let lr_aux.ultatvvcl = 'REC'
                  let lr_aux.hraultatv = lr_gps.cadhorrec
                 end if
              else

                 if l_display then
                    display '# Servico: ', lr_aux.atdsrvnum,'-', lr_aux.atdsrvano, ' - Viatura sem sigla'
                 end if

                 continue foreach
              end if

              #----- BUSCA SINAL DO INI -----#
              let l_tip = 2
              let l_achei = false
              if lr_aux.atdvclsgl is not null then

                 open cq_sinaisgps using  lr_aux.atdsrvnum, lr_aux.atdsrvano #, l_mdtcod, l_tip
                 foreach cq_sinaisgps into lr_gps.caddatini, lr_gps.cadhorini
                                           ,lr_gps.lcllttini
                                           ,lr_gps.lcllgtini
                                           ,l_mdtcod2
                                           ,l_mdtmvttipcod
                                           ,l_mdtmvtstt
                                           ,l_mdtbotprgseq

                    if l_mdtcod2      = l_mdtcod  and
                       l_mdtmvttipcod = 2         and
                       l_mdtmvtstt    = 2         and
                       l_mdtbotprgseq = l_tip     then
                          let l_achei = true
                          exit foreach
                    else
                       let l_achei = false
                    end if
                 end foreach

                 if  l_achei then
                  # UTLIMA ATIVIDADE INI
                  let lr_aux.ultatvvcl = 'INI'
                  let lr_aux.hraultatv = lr_gps.cadhorini
                 else
                  let lr_gps.cadhorini = null

                 end if
                 if l_achei then

                     if (lr_gps.lcllttini is not null and lr_gps.lcllttini <> 0) and
                        (lr_gps.lcllgtini is not null and lr_gps.lcllgtini <> 0) and
                        (lr_aux.lclltt    is not null and lr_aux.lclltt    <> 0) and
                        (lr_aux.lcllgt    is not null and lr_aux.lcllgt    <> 0) then
                        let lr_aux.dstini = cts18g00(lr_gps.lcllttini,
                                                     lr_gps.lcllgtini,
                                                     lr_aux.lclltt,
                                                     lr_aux.lcllgt)
                     else
                         let lr_aux.dstini = 9999
                     end if
                end if


              else

                 if l_display then
                    display '# Servico: ', lr_aux.atdsrvnum,'-', lr_aux.atdsrvano, ' - Viatura sem sigla'
                 end if
                 continue foreach
              end if

              #----- BUSCA SINAL DO FIM -----#
              let l_tip = 3
              if lr_aux.atdvclsgl is not null then
                 let l_achei = false
                 open cq_sinaisgps using  lr_aux.atdsrvnum, lr_aux.atdsrvano #, l_mdtcod, l_tip
                 foreach cq_sinaisgps into lr_gps.caddatfim, lr_gps.cadhorfim
                                           ,lr_gps.lclltt
                                           ,lr_gps.lcllgt
                                           ,l_mdtcod2
                                           ,l_mdtmvttipcod
                                           ,l_mdtmvtstt
                                           ,l_mdtbotprgseq

                    if l_mdtcod2      = l_mdtcod and
                       l_mdtmvttipcod = 2        and
                       l_mdtmvtstt    = 2        and
                       l_mdtbotprgseq = l_tip    then
                       let l_achei = true
                       exit foreach
                    else
                       let l_achei = false
                    end if
                 end foreach
                 if  l_achei then
                  # UTLIMA ATIVIDADE FIM
                  let lr_aux.ultatvvcl = 'FIM'
                  let lr_aux.hraultatv = lr_gps.cadhorfim
                  end if

              else
                 if l_display then
                    display '# Servico: ', lr_aux.atdsrvnum,'-', lr_aux.atdsrvano, ' - Viatura sem sigla'
                 end if
                 continue foreach
              end if
          end if

          if l_display then
             let l_now = current
             display 'Terminou busca dos sinais ', 'às ', l_now,lr_aux.atdsrvnum, '-',lr_aux.atdsrvano
          end if

          let lr_aux.dathorcom = lr_aux.dathorcomchr

          insert into temp_srvacpcom (atdsrvnum      ,
                                      atdsrvano      ,
                                      atdsrvorg      ,
                                      atddatprg      ,
                                      atdhorprg      ,
                                      empcod         ,
                                      atdlibdat      ,
                                      atdlibhor      ,
                                      atdhorpvt      ,
                                      srvprsacnhordat,
                                      atdetpcod      ,
                                      atdprscod      ,
                                      atdvclsgl      ,
                                      envtipcod      ,
                                      dathorcom      ,
                                      caddatrec      ,
                                      cadhorrec      ,
                                      caddatini      ,
                                      cadhorini      ,
                                      lcllttini      ,
                                      lcllgtini      ,
                                      dstini         ,
                                      caddatfim      ,
                                      cadhorfim      ,
                                      ultatvvcl      ,
                                      hraultatv)
                              values (lr_aux.atdsrvnum,
                                      lr_aux.atdsrvano,
                                      lr_aux.atdsrvorg,
                                      lr_aux.atddatprg,
                                      lr_aux.atdhorprg,
                                      lr_aux.empcod,
                                      lr_aux.atdlibdat,
                                      lr_aux.atdlibhor,
                                      lr_aux.atdhorpvt,
                                      lr_aux.srvprsacnhordat,
                                      lr_aux.atdetpcod,
                                      lr_aux.atdprscod,
                                      lr_aux.atdvclsgl,
                                      lr_aux.envtipcod,
                                      lr_aux.dathorcom,
                                      lr_gps.caddatrec,
                                      lr_gps.cadhorrec,
                                      lr_gps.caddatini,
                                      lr_gps.cadhorini,
                                      lr_gps.lcllttini,
                                      lr_gps.lcllgtini,
                                      lr_aux.dstini   ,
                                      lr_gps.caddatfim,
                                      lr_gps.cadhorfim,
                                      lr_aux.ultatvvcl,
                                      lr_aux.hraultatv)
         if l_display then
            let l_now = current
            display 'Terminou inserção na temporaria ', 'às ', l_now,lr_aux.atdsrvnum, '-',lr_aux.atdsrvano
         end if
         initialize lr_aux.atdsrvnum ,
                    lr_aux.atdsrvano,
                    lr_aux.atdsrvorg,
                    lr_aux.atddatprg,
                    lr_aux.atdhorprg,
                    lr_aux.empcod,
                    lr_aux.atdlibdat,
                    lr_aux.atdlibhor,
                    lr_aux.atdhorpvt,
                    lr_aux.srvprsacnhordat,
                    lr_aux.atdetpcod,
                    lr_aux.atdprscod,
                    lr_aux.atdvclsgl,
                    lr_aux.envtipcod,
                    lr_aux.lclltt,
                    lr_aux.lcllgt   to null

      end foreach

      if l_display then
         let l_now = current
         display 'Terminou a query principal as: ', l_now
      end if

      # TABELA TEMPORARIA PARA PEGAR APENAS OS SERVIÇOS QUE FORAM COMBINADOS

      let ws.sql =" select atdsrvnum      , ",
                         " atdsrvano      , ",
                         " atdsrvorg      , ",
                         " atddatprg      , ",
                         " atdhorprg      , ",
                         " empcod         , ",
                         " atdlibdat      , ",
                         " atdlibhor      , ",
                         " atdhorpvt      , ",
                         " srvprsacnhordat, ",
                         " atdetpcod      , ",
                         " atdprscod      , ",
                         " atdvclsgl      , ",
                         " envtipcod      , ",
                         " dathorcom      , ",
                         " caddatrec      , ",
                         " cadhorrec      , ",
                         " caddatini      , ",
                         " cadhorini      , ",
                         " lcllttini      , ",
                         " lcllgtini      , ",
                         " dstini         , ",
                         " caddatfim      , ",
                         " cadhorfim      , ",
                         " ultatvvcl      , ",
                         " hraultatv        ",
                    " from temp_srvacpcom   "

      if  d_cts00m10.etpdat is not null and d_cts00m10.etpdat <> ' ' then

          let lr_aux.etphorinichr = extend (d_cts00m10.etpdat, year to day), " ", d_cts00m10.etphorini
          let lr_aux.etphorfimchr = extend (d_cts00m10.etpdat, year to day), " ", d_cts00m10.etphorfim

          let lr_aux.etphorini = lr_aux.etphorinichr
          let lr_aux.etphorfim = lr_aux.etphorfimchr

          let ws.condicao = " where dathorcom between '", lr_aux.etphorini, "' and '", lr_aux.etphorfim, "'"

          if  d_cts00m10.dstiniqth = 'L' or d_cts00m10.dstiniqth = 'P' then

              let ws.condicao = ws.condicao clipped, ' and dstini is not null '

              if  d_cts00m10.dstiniqth = 'L' then
                  let ws.condicao = ws.condicao clipped, ' and dstini > ', l_dstqth
              else
                  if  d_cts00m10.dstiniqth = 'P' then
		      let ws.condicao = ws.condicao clipped, ' and dstini < ', l_dstqth
                  end if
              end if
          end if

          if  d_cts00m10.ultatv is not null and d_cts00m10.ultatv <> ' ' then
              let ws.condicao = ws.condicao clipped, " and ultatvvcl = '", d_cts00m10.ultatv clipped, "'"
          end if

          if  d_cts00m10.ordlst = 'D' then
              let ws.condicao = ws.condicao clipped, " order by dathorcom"
          else
              let ws.condicao = ws.condicao clipped, " order by ultatvvcl desc"
          end if

          let ws.sql = ws.sql clipped, " ", ws.condicao

      end if

      initialize lr_gps.*, lr_aux.* to null

      if l_display then
         display '----------------------------------------------------'
         display 'Query temporaria: ', ws.sql clipped
         let l_now = current
         display 'Pesquisando a Temporaria às: ', l_now
      end if

      prepare p_cts00m10_011 from ws.sql
      declare c_cts00m10_011 cursor with hold for p_cts00m10_011

      foreach c_cts00m10_011 into lr_aux.atdsrvnum      ,
                                  lr_aux.atdsrvano      ,
                                  lr_aux.atdsrvorg      ,
                                  lr_aux.atddatprg      ,
                                  lr_aux.atdhorprg      ,
                                  lr_aux.empcod         ,
                                  lr_aux.atdlibdat      ,
                                  lr_aux.atdlibhor      ,
                                  lr_aux.atdhorpvt      ,
                                  lr_aux.srvprsacnhordat,
                                  lr_aux.atdetpcod      ,
                                  lr_aux.atdprscod      ,
                                  lr_aux.atdvclsgl      ,
                                  lr_aux.envtipcod      ,
                                  lr_aux.dathorcom      ,
                                  lr_gps.caddatrec      ,
                                  lr_gps.cadhorrec      ,
                                  lr_gps.caddatini      ,
                                  lr_gps.cadhorini      ,
                                  lr_gps.lcllttini      ,
                                  lr_gps.lcllgtini      ,
                                  lr_gps.dstini         ,
                                  lr_gps.caddatfim      ,
                                  lr_gps.cadhorfim       ,
                                  lr_aux.ultatvvcl       ,
                                  lr_aux.hraultatv

         #PRIMEIRA LINHA - INFORMAÇÕES DO SERVICO
         if  lr_aux.atddatprg is not null then
             let a_cts00m10[arr_aux].tipprg = 'PROG'
         else
             let a_cts00m10[arr_aux].tipprg = 'IMED'
         end if

         let a_cts00m10[arr_aux].diacmb = extend(lr_aux.dathorcom, day to day),"/", extend(lr_aux.dathorcom, month to month)
         let a_cts00m10[arr_aux].hracmb = extend(lr_aux.dathorcom, hour to minute)

         let a_cts00m10[arr_aux].servico = lr_aux.atdsrvorg using "&&" , "/",
                                           lr_aux.atdsrvnum using "&&&&&&&"

         whenever error continue
           select atdetpdes
             into a_cts00m10[arr_aux].etpdessrv
             from datketapa
            where atdetpcod = lr_aux.atdetpcod
         whenever error stop

         let a_cts00m10[arr_aux].pstcoddigsrv = lr_aux.atdprscod
         #let a_cts00m10[arr_aux].nomgrrsrv    = lr_aux.nomgrr
         let a_cts00m10[arr_aux].atdvclsglsrv = lr_aux.atdvclsgl

         let a_cts00m1x[arr_aux].atdsrvnum = lr_aux.atdsrvnum
         let a_cts00m1x[arr_aux].atdsrvano = lr_aux.atdsrvano

         whenever error continue
           select nomgrr
             into a_cts00m10[arr_aux].nomgrrsrv
             from dpaksocor
            where pstcoddig = lr_aux.atdprscod
         whenever error stop

         whenever error continue
           select empsgl
             into a_cts00m10[arr_aux].empsgl
             from gabkemp
            where empcod = lr_aux.empcod
         whenever error stop

         whenever error continue
           select cpodes
             into lr_aux.envtipdes
             from iddkdominio
            where cponom = 'envtipcod'
              and cpocod = lr_aux.envtipcod
         whenever error stop

         if  lr_aux.envtipcod = 1 then

             let lr_aux.texto = lr_aux.envtipdes[1,3]

             #if  lr_gps.cadhorrec is not null and lr_gps.cadhorrec <> " " then
                 let lr_aux.texto = lr_aux.texto[1,4], 'REC as ', lr_gps.cadhorrec
             #else
             #    let lr_aux.texto = lr_aux.texto clipped, ' REC NÂO ENV.'
             #end if

             #if  lr_gps.cadhorini is not null and lr_gps.cadhorini <> " " then
                 let lr_aux.texto = lr_aux.texto[1,19], 'INI as ', lr_gps.cadhorini
             #else
             #    let lr_aux.texto = lr_aux.texto clipped, '   INI NÂO ENV.'
             #end if

             if  lr_gps.dstini = 9999 then
                 let lr_aux.texto = lr_aux.texto[1,31], " SEM COORDENADA VALIDA"
             else
                 let lr_aux.texto = lr_aux.texto[1,31], " a ", lr_gps.dstini  using "&&&&.&&&", " Mt do QTH"
             end if

             #if  lr_aux.ultatvvcl is not null and lr_aux.ultatvvcl <> " " then
                 let lr_aux.texto = lr_aux.texto[1,56] , "ÚltAtv: ", lr_aux.ultatvvcl,
                                    ' as ', lr_aux.hraultatv
             #end if

             let a_cts00m10[arr_aux].ultatvvcl = lr_aux.texto

         else
             if  lr_aux.envtipdes is null or lr_aux.envtipdes = ' ' then
                 let a_cts00m10[arr_aux].ultatvvcl = '                   SERVIÇO SEM INFORMAÇÃO DE TIPO DE ENVIO'
             else
                 let a_cts00m10[arr_aux].ultatvvcl = '                   ACIONAMENTO VIA ', lr_aux.envtipdes
             end if
         end if

         let ws.totqtd = ws.totqtd + 1
         let arr_aux = arr_aux + 1

         initialize lr_aux.* to null

      end foreach

      if l_display then
         let l_now = current
         display 'Terminou a temporaria às ', l_now
      end if

      let d_cts00m10.totqtd = ws.totqtd using "<<<<&"
      display by name d_cts00m10.totqtd  attribute(reverse)

      if arr_aux = 1  then
         message ""
         error " Nao existem servicos para acompanhamento!"
         let int_flag = true
         exit while
      else
         call set_count(arr_aux-1)

         message "   (F4)Sinais (F6)Nova consulta (F7)Lig. (F8)Laudo (F9)Etapas (F17)Abandona "

         display array a_cts00m10 to s_cts00m10.*

            on key (interrupt)
               let int_flag = true
               initialize a_cts00m10 to null
               let arr_aux = arr_curr()
               exit display

            on key (F6)
               let d_cts00m10.agora  =  current
               display by name d_cts00m10.agora  attribute(reverse)
               let int_flag = false
               exit display

            on key (F7)
               options comment line last

               let arr_aux = arr_curr()
               let scr_aux = scr_line()

               initialize g_documento.succod    to null
               initialize g_documento.ramcod    to null
               initialize g_documento.aplnumdig to null
               initialize g_documento.itmnumdig to null
               let ws.succod    = null
               let ws.ramcod    = null
               let ws.aplnumdig = null
               let ws.itmnumdig = null
               let ws.crtnum    = null

               select succod   ,
                      ramcod   ,
                      aplnumdig,
                      itmnumdig
                 into ws.succod   ,
                      ws.ramcod   ,
                      ws.aplnumdig,
                      ws.itmnumdig
                 from datrservapol
                where atdsrvnum = a_cts00m1x[arr_aux].atdsrvnum
                  and atdsrvano = a_cts00m1x[arr_aux].atdsrvano

               if sqlca.sqlcode <> 0  then
                  select succod  ,
                         ramcod  ,
                         aplnumdig ,
                         crtnum
                    into ws.succod,
                         ws.ramcod,
                         ws.aplnumdig,
                         ws.crtnum
                   from datrsrvsau
                  where atdsrvnum = a_cts00m1x[arr_aux].atdsrvnum
                    and atdsrvano = a_cts00m1x[arr_aux].atdsrvano
                  if sqlca.sqlcode <> 0  then
                     error " Nao e' possivel consultar ligacoes para servico sem documento informado!"
                  end if
               else
#                 call cta02m02(ws.succod, ws.ramcod, ws.aplnumdig, ws.itmnumdig, "", "", "", "")
                  call cta02m02_consultar_ligacoes(ws.succod   , ws.ramcod,
                                                   ws.aplnumdig, ws.itmnumdig,
                                                   '', '',
                                                   '', '',
                                                   '', '',
                                                   '', '',
                                                   '', '',
                                                   '', '',
                                                   '', '',
                                                   '', '',
                                                   ws.crtnum,"","")
               end if

               options comment line 07

               display a_cts00m10[arr_aux].* to s_cts00m10[scr_aux].*

            on key (F8)
               options comment line last

               let arr_aux = arr_curr()
               let scr_aux = scr_line()

               if a_cts00m10[arr_aux].servico  is not null   then
                  let g_documento.atdsrvnum = a_cts00m1x[arr_aux].atdsrvnum
                  let g_documento.atdsrvano = a_cts00m1x[arr_aux].atdsrvano

                  call cts04g00('cts00m10') returning ws.retflg

                  options comment line 07

                  display a_cts00m10[arr_aux].* to s_cts00m10[scr_aux].*
               else
                  error " Servico nao selecionado!"
               end if

            on key (F9)
               options comment line last

               let arr_aux = arr_curr()
               let scr_aux = scr_line()

               if a_cts00m10[arr_aux].servico  is not null   then

                  call cts00m11(a_cts00m1x[arr_aux].atdsrvnum,
                                a_cts00m1x[arr_aux].atdsrvano)

                  options comment line 07

                  display a_cts00m10[arr_aux].* to s_cts00m10[scr_aux].*
               else
                  error " Servico nao selecionado!"
               end if

            on key (F4)
               let arr_aux = arr_curr()
               if  a_cts00m10[arr_aux].atdvclsglsrv is not null and a_cts00m10[arr_aux].atdvclsglsrv <> " " then
                   call ctn44c00(2, a_cts00m10[arr_aux].atdvclsglsrv,"")
               else
                   error "Nao existem sinais para serem pesquisados"
               end if

         end display
      end if

      if int_flag = true  then
         exit while
      end if

    end while

 end while

 drop table temp_srvacpcom

 let int_flag = false
 close window w_cts00m10

end function  ###  cts00m10


#-----------------------------------------------------------
 function cts00m10_espera(param)
#-----------------------------------------------------------

 define param        record
    atdetpdat        like datmsrvacp.atdetpdat ,
    atdetphor        char (05)                 ,
    fnletpdat        like datmsrvacp.atdetpdat ,
    fnletphor        char (05)                 ,
    atddatprg        like datmservico.atddatprg,
    atdhorprg        char (05)
 end record

 define ws           record
    incdat           date,
    fnldat           date,
    resdat           integer,
    time             char (05),
    chrhor           char (07),
    inchor           interval hour(05) to minute,
    fnlhor           interval hour(05) to minute,
    reshor           interval hour(06) to minute
 end record

	initialize  ws.*  to  null

 initialize ws.*  to null

 if param.atddatprg is not null  and
    param.atdhorprg is not null  then
    let ws.incdat = param.atddatprg
    let ws.inchor = param.atdhorprg
 else
    let ws.incdat = param.atdetpdat
    let ws.inchor = param.atdetphor
 end if

 if param.fnletpdat is null  or
    param.fnletpdat < param.atdetpdat  then
    let ws.fnldat = today
 else
    let ws.fnldat = param.fnletpdat
 end if

 if param.fnletphor is null  then
    let ws.time = time
 else
    let ws.time = param.fnletphor
 end if

 let ws.fnlhor = ws.time

 if ws.fnldat < ws.incdat  then
    let ws.resdat = (ws.incdat - ws.fnldat) * 24
    let ws.reshor = (ws.inchor - ws.fnlhor)
 else
    let ws.resdat = (ws.fnldat - ws.incdat) * 24
    let ws.reshor = (ws.fnlhor - ws.inchor)
 end if

 let ws.chrhor = ws.resdat using "###&" , ":00"
 let ws.reshor = ws.reshor + ws.chrhor

 return ws.reshor

end function  ###  cts00m10_espera

#------------------------------------------
function cts00m10_create_temp()
#------------------------------------------
whenever error continue

    drop table temp_srvacpcom

    create temp table temp_srvacpcom (atdsrvnum           decimal(10,0) ,
                                      atdsrvano           decimal(2,0) ,
                                      atdsrvorg           smallint,
                                      atddatprg           date,
                                      atdhorprg           datetime hour to minute,
                                      empcod              decimal(3,0),
                                      atdlibdat           date,
                                      atdlibhor           datetime hour to minute,
                                      atdhorpvt           datetime hour to minute,
                                      srvprsacnhordat     datetime year to second,
                                      atdetpcod           smallint,
                                      atdprscod           decimal(6,0),
                                      atdvclsgl           char(5),
                                      envtipcod           smallint,
                                      dathorcom           datetime year to minute,
                                      caddatrec           date,
                                      cadhorrec           datetime hour to minute,
                                      caddatini           date,
                                      cadhorini           datetime hour to minute,
                                      lcllttini           decimal(8,6),
                                      lcllgtini           decimal(9,6),
                                      dstini              dec(8,4),
                                      caddatfim           date,
                                      cadhorfim           datetime hour to minute,
                                      ultatvvcl           char(03),
                                      hraultatv           datetime hour to minute) with no log

whenever error stop
end function
