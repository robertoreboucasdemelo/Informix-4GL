#-----------------------------------------------------------------------------#
# Sistema....: Porto Socorro                                                  #
# Modulo.....: bdbsa106                                                       #
# Analista Resp.: Robert Lima                                                 #
# PSI......:   Cria OP e envia (via e-mail) aos prestadores - Carro extra     #
# --------------------------------------------------------------------------- #
# Desenvolvimento: Robert Lima                                                #
# Liberacao...: 14/06/2011                                                    #
# --------------------------------------------------------------------------- #
#                                 Alteracoes                                  #
# --------------------------------------------------------------------------- #
# Data        Autor           Origem     Alteracao                            #
# ----------  --------------  ---------- -------------------------------------#
# 22/11/2012  Sergio Burini              Inclusa�o das horas efetivas no      #
#                                        relatorio da OP                      #
#-----------------------------------------------------------------------------#
# 07/08/2014 Brunno Silva     CT:14082892 Criacao da funcao                   #
#                                         bdbsa106_validarFavLocadora e       #
#                                         chamada da funcao                   #
#                                         ctx22g00_mail_corpo                 #
#-----------------------------------------------------------------------------#

database porto

define m_path          char(100)
define ws_incdat       date
define ws_fnldat       date
define ws_crnpgtcod    decimal(2,0)
define ws_countfor     smallint
define ws_socfatentdat date
define ws_socfatpgtdat date
define m_empcod        like dbsmopg.empcod
define m_transacao     decimal (1,0)
define m_atdsrvnum     like dbsmcctrat.atdsrvnum
define m_atdsrvano     like dbsmcctrat.atdsrvano

main

  define l_path char(3000)

  call fun_dba_abre_banco("CT24HS")

  initialize m_path,ws_incdat, ws_fnldat, ws_crnpgtcod,
             ws_countfor, ws_socfatentdat, ws_socfatpgtdat to null

  let m_path = f_path("DBS","LOG")

  if m_path is null then
     let m_path = "."
  end if

  call bdbsa106_prepare()

  set isolation to dirty read

  call bdbsa106()

end main

#------------------
function bdbsa106_prepare()
#------------------

  define l_sql char(3000)

  let l_sql = "select lcvcod",
              "  from datklocadora  ",
              " where pgtcrncod = ? "
  prepare pbdbsa106002 from l_sql
  declare cbdbsa106002 cursor for pbdbsa106002

  let l_sql = "select a.atdsrvnum,             ",
              "       a.atdsrvano,             ",
              "       b.srvprlflg,             ",
              "       b.ciaempcod,             ",
              "       a.lcvcod   ,             ",
              "       a.aviestcod,             ",
              "       b.atddat   ,             ",
              "       b.atdhor   ,             ",
              "       b.atdfnlflg,             ",
              "       a.avialgmtv              ",
              "  from datmavisrent a,          ",
              "       datmservico  b           ",
              " where a.lcvcod = ?             ",
              "   and a.atdsrvnum = b.atdsrvnum",
              "   and a.atdsrvano = b.atdsrvano",
              "   and b.pgtdat is null         ",
              "   and b.atdetpcod = 4          ",
              "   and b.atdsrvorg = 8          ",
              "   and b.pgtdat    is null      ",
              "   and b.atddat between ? and ? "
  prepare pbdbsa106004 from l_sql
  declare cbdbsa106004 cursor for pbdbsa106004

  #--------------------------------------------------------------------
  # Preparando SQL ITENS OP
  #--------------------------------------------------------------------
  let l_sql  = "select dbsmopgitm.socopgnum     ",
               "  from dbsmopgitm, dbsmopg      ",
               " where dbsmopgitm.atdsrvnum = ? ",
               "   and dbsmopgitm.atdsrvano = ? ",
               "   and dbsmopgitm.socopgnum    = dbsmopg.socopgnum ",
               "   and dbsmopg.socopgsitcod <> 8 "

  prepare pbdbsa106006 from l_sql
  declare cbdbsa106006 cursor for pbdbsa106006

  let l_sql = "select nrosrv, anosrv,     ",
              "       pgttipcodps, empcod,",
              "       succod, cctcod      ",
              "  from dbscadtippgt        ",
              " where nrosrv = ?          ",
              "   and anosrv = ?          "
  prepare pbdbsa106008 from l_sql
  declare cbdbsa106008 cursor for pbdbsa106008

  let l_sql = "select atdsrvnum, atdsrvano, cctcod ",
              "  from dbsmcctrat    ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "
  prepare pbdbsa106009 from l_sql
  declare cbdbsa106009 cursor for pbdbsa106009

  let l_sql = "select atdetpcod    ",
              "  from datmsrvacp   ",
              " where atdsrvnum = ?",
              "   and atdsrvano = ?",
              "   and atdsrvseq = (select max(atdsrvseq)",
                                  "  from datmsrvacp    ",
                                  " where atdsrvnum = ? ",
                                  "   and atdsrvano = ?)"
  prepare pbdbsa106012 from l_sql
  declare cbdbsa106012 cursor for pbdbsa106012

  let l_sql = "select atdfnlflg   , atdsrvorg    ",
              "  from datmservico                ",
              " where atdsrvnum = ?              ",
              "   and atdsrvano = ?              "
  prepare pbdbsa106013 from l_sql
  declare cbdbsa106013 cursor for pbdbsa106013

  let l_sql = " select relpamtxt "
              ,"   from igbmparam "
              ,"  where relsgl = ? "
  prepare pbdbsa106015 from l_sql
  declare cbdbsa106015 cursor for pbdbsa106015
  
  #---------------------------------------------------------------------------
  # CT: 14082892
  # Preparando SQL que valida se a locadora possui favorecido para receber O.P
  #---------------------------------------------------------------------------
  #Busca codigo da loja favorecida e nome da locadora
  let l_sql =  " select fvrlojcod        "
              ,"    from datklocadora    "
              ,"    where lcvcod = ?     "
   prepare pbdbsa106017 from l_sql
   declare cbdbsa106017 cursor for pbdbsa106017           
  
   #Busca codigo da loja da locadora
   let l_sql = " select aviestcod     "
              ," from datkavislocal   "
              ,"   where lcvcod = ?   "
              ,"    and lcvextcod = ? "
   prepare pbdbsa106018 from l_sql
   declare cbdbsa106018 cursor for pbdbsa106018
   
   #Busca o FAVORECIDO da locadora
   let l_sql = " select favnom     "      
              ,"   from datklcvfav "
              ,"    where lcvcod = ? "
              ,"      and aviestcod = ? "
   prepare pbdbsa106019 from l_sql
   declare cbdbsa106019 cursor for pbdbsa106019
      
  #---------------------------------------------------------------------------
  # FIM CT: 14082892
  #--------------------------------------------------------------------------- 
  
end function

#------------------
function bdbsa106()
#------------------
  define bdbsa106 record
      atdsrvnum like datmavisrent.atdsrvnum ,
      atdsrvano like datmavisrent.atdsrvano ,
      lcvcod    like datmavisrent.lcvcod    ,
      aviestcod like datmavisrent.aviestcod ,
      srvprlflg like datmservico.srvprlflg  ,
      ciaempcod like datmservico.ciaempcod  ,
      c24evtcod like datmsrvanlhst.c24evtcod,
      atddat    like datmservico.atddat     ,
      atdhor    like datmservico.atdhor     ,
      flgtiplja smallint                    ,
      quebra    integer
  end record

  define ws     record
      auxdat    char (10),
      opsrvdias smallint ,
      lcvlojtip like datkavislocal.lcvlojtip,
      socopgnum like dbsmopgitm.socopgnum,
      atdfnlflg like datmservico.atdfnlflg,
      atdsrvorg like datmservico.atdsrvorg,
      contador  integer,
      avialgmtv like datmavisrent.avialgmtv
  end record

  define l_ctb00g01  record
     totanl          smallint
    ,c24evtcod       like datkevt.c24evtcod
    ,c24fsecod       like datkevt.c24fsecod
  end record

  define r_tempsrv record
     atdsrvnum        decimal (10,0),
     atdsrvano        decimal (2,0)
  end record

  define l_arq    char(30)
  define l_etpa   smallint
  define l_erro   char(15)
  define l_path02 char(100)
  define l_data   char(10)
  define l_exec   smallint
  
  #CT: 14082892 
  define l_flgTemFavorecido smallint 
  define l_locadoras varchar(255)
  define l_msgEmail varchar(255)
  define l_flgEnviarEmail smallint
  define l_retorno smallint
  define l_codLocAnt smallint
  define l_auxChar char(100)
  
  let l_msgEmail = ""
  let l_locadoras = null
  let l_flgEnviarEmail = false
  let l_codLocAnt = 0
  let l_auxChar = null
  #CT: 14082892 - fim 

  initialize ws.*          to null

  let l_arq = null

  #--------------------------------------------------------------------
  # Cria tabelas temporarias auxiliares
  #--------------------------------------------------------------------
  create temp table tbtemp_op
    (socopgnum        decimal (8,0),
     socopgitmnum     decimal (4,0),
     atdsrvnum        decimal (10,0),
     atdsrvano        decimal (2,0),
     atddat           date ,
     atdhor           char (05),
     c24utidiaqtd     smallint,
     c24pagdiaqtd     smallint,
     socopgitmvlr     decimal (15,5)) with no log

  create temp table tbtemp_op_nint
    (atdsrvnum        decimal (10,0),
     atdsrvano        decimal (2,0)) with no log

  create temp table tbtemp_for
   (lcvcod    smallint) with no log

  #--------------------------------------------------------------------
  # Definicao das datas parametro
  #--------------------------------------------------------------------
  let ws.auxdat = arg_val(1)

  if ws.auxdat is null       or
     ws.auxdat =  "  "       then
     let ws.auxdat = today
  else
     if ws.auxdat > today       or
        length(ws.auxdat) < 10  then
        display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
        exit program
     end if
  end if

  select grlinf into ws.opsrvdias
    from datkgeral
   where grlchv = "PSOOPSRVDIAS"
  if sqlca.sqlcode <> 0 then
     let ws.opsrvdias = 180
  end if

  display "CASO NAO SEJA PASSADO POR PARAMETRO O QUANTIDADE DE DIAS", ws.opsrvdias

  let ws_fnldat       = ws.auxdat
  let ws_incdat       = ws_fnldat - ws.opsrvdias units day

  display " Busca servicos a partir de ", ws_incdat, " (", ws.opsrvdias using "<<<&", " dias)"

  display " DATA DE PROCESSAMENTO = ",ws_fnldat

  #let ws_crnpgtcod = 9
  #let l_exec       = 0
  #
  ## VERIFICA SE � DIA DE EXECU��O DO CRONOGRAMA 9
  #whenever error continue
  #select 1
  #  into l_exec             
  #  from dbsmcrnpgtetg  
  # where crnpgtcod = ws_crnpgtcod 
  #   and crnpgtetgdat = today
  #whenever error stop     
  #
  #display "EXECUTA? ",  l_exec
  #
  #if  not l_exec then
  #    display "NAO EXECUTA CRONOGRAMA 9 - LOCADORAS"
  #    exit program
  #else
  #    display "EXECUTA CRONOGRAMA 9 - LOCADORAS"
  #end if 
 
 
 #Processo automatico dever� respeitar cronograma cadastrado para cada Locadora
 #Alterado por: Jorge Modena Em: 05/08/2013
 #------------------------------------------------------
 # Pesquisa todos os codigos de cronograma em funcao da data
 #------------------------------------------------------
 declare c_cronograma cursor for
  select dbsmcrnpgtetg.crnpgtcod
    from dbsmcrnpgtetg
   where dbsmcrnpgtetg.crnpgtetgdat = ws_fnldat

  foreach c_cronograma into ws_crnpgtcod                              
     open cbdbsa106002 using ws_crnpgtcod                          
     foreach cbdbsa106002 into bdbsa106.lcvcod                     
        display "CRONOGRAMA: ", ws_crnpgtcod, " LOCADORAS COM O CRONOGRAMA: ", bdbsa106.lcvcod     
        insert into tbtemp_for values (bdbsa106.lcvcod)
     end foreach
  end foreach 
  
 

  #------------------------------------------------------
  # Verifica se h� algum cronograma na data
  #------------------------------------------------------
  whenever error continue
  select count(*)
  into ws_countfor
  from tbtemp_for
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode < 0 then
        display "Erro no SELECT da tabela tbtemp_for.",sqlca.sqlcode
               ,sqlca.sqlerrd[2]
        exit program(1)
     end if
     if sqlca.sqlcode = 100 then
        let ws_countfor = 0
     end if
  end if

  if ws_countfor is null or
     ws_countfor = 0     then
      display "Nao ha locadoras com cronograma nesta data ", ws_fnldat
      exit program
  end if

  let ws_socfatentdat = ws_fnldat  # DATA ENTREGA DO PRESTADOR

  let ws_socfatpgtdat = dias_uteis(ws_socfatentdat, 7, "", "S", "S")

  let m_path = f_path("DBS","ARQUIVO")
  if m_path is null then
     let m_path = "."
  end if

  let l_path02 = m_path
  let l_arq  = m_path clipped ,"/bdbsa106.txt"

  #------------------------------------------------------
  # Busca todos as locadoras da tabela temporaria
  #------------------------------------------------------
  declare cbdbsa106003 cursor for
    select lcvcod
      from tbtemp_for

  start report bdbsa106_rel to l_arq

  begin work
  foreach cbdbsa106003 into bdbsa106.lcvcod

      open cbdbsa106004 using bdbsa106.lcvcod,
                              ws_incdat,
                              ws_fnldat
      foreach cbdbsa106004 into bdbsa106.atdsrvnum,
                                bdbsa106.atdsrvano,
                                bdbsa106.srvprlflg,
                                bdbsa106.ciaempcod,
                                bdbsa106.lcvcod,
                                bdbsa106.aviestcod,
                                bdbsa106.atddat,
                                bdbsa106.atdhor,
                                ws.atdfnlflg,
                                ws.avialgmtv

           display "SERVICO: ", bdbsa106.atdsrvnum, bdbsa106.atdsrvano
                                 
           ### VERIFICA SE SERVICO JA' EXISTE EM ALGUMA OP
           initialize ws.socopgnum to null
           open  cbdbsa106006 using bdbsa106.atdsrvnum, bdbsa106.atdsrvano
           fetch cbdbsa106006 into  ws.socopgnum
           close cbdbsa106006

           if ws.socopgnum is not null  then   # servico encontrado
              display " Ja existe em uma op : ", bdbsa106.atdsrvnum clipped, " ",bdbsa106.atdsrvano clipped,
                      " OP: ",ws.socopgnum clipped
              initialize bdbsa106.* to null
              continue foreach
           end if

           if bdbsa106.srvprlflg = "S" or ws.avialgmtv = 5 then # SERVICO PARTICULAR

              display "SERVICO PARTICULAR"
              insert into tbtemp_op_nint
                     values(bdbsa106.atdsrvnum,
                            bdbsa106.atdsrvano)

              if sqlca.sqlcode  <>  0   then
                 display "Erro (",sqlca.sqlcode,") inclusao tabela TEMPORARIA OK"
                 rollback work
                 exit program (1)
              end if

              initialize bdbsa106.* to null
              continue foreach
           end if

           # VERIFICA SE SERVICO ESTA DENTRO DA INTEGRA��O
           call cty24g00_chk_int(bdbsa106.atdsrvnum,
                                 bdbsa106.atdsrvano,
                                 "C")
                returning l_erro

           if l_erro is null then

              display "SERVICO NAO INTEGRACAO ", bdbsa106.atdsrvnum, bdbsa106.atdsrvano
              insert into tbtemp_op_nint
                     values(bdbsa106.atdsrvnum,
                            bdbsa106.atdsrvano)

              if sqlca.sqlcode  <>  0   then
                 display "Erro (",sqlca.sqlcode,") inclusao tabela TEMPORARIA OK"
                 rollback work
                 exit program (1)
              end if

              initialize bdbsa106.* to null
              continue foreach
           end if

           # VERIFICA SE A ETAPA DO SERVICO � 4
           open cbdbsa106012 using bdbsa106.atdsrvnum,
                                   bdbsa106.atdsrvano,
                                   bdbsa106.atdsrvnum,
                                   bdbsa106.atdsrvano
           fetch cbdbsa106012 into l_etpa
           close cbdbsa106012

           if l_etpa <> 4 then
              display "Etapa do servico diferente de 4 (acionado/finalizado) - ",
                      bdbsa106.atdsrvnum clipped, " ", bdbsa106.atdsrvano clipped
              initialize bdbsa106.* to null
              display "SERVICO NAO ACIONADO"
              continue foreach
           end if

           # VERIFICA RA E SE O SERVICO ESTA FINALIZADO
           if ws.atdfnlflg = "N"  then
              display " Ordem de servico nao finalizada nao pode ser paga - ",
                      bdbsa106.atdsrvnum clipped, " ", bdbsa106.atdsrvano clipped
              initialize bdbsa106.* to null
              continue foreach
           end if

           initialize l_ctb00g01.* to null

           # ---------------------------------------------- #
           # VERIFICA SE FASE DO SERVICO ESTA EM ANALISE    #
           # ---------------------------------------------- #
           #call ctb00g01_srvanl( bdbsa106.atdsrvnum
           #                     ,bdbsa106.atdsrvano
           #                     ,"S" )
           #     returning l_ctb00g01.totanl
           #              ,l_ctb00g01.c24evtcod
           #              ,l_ctb00g01.c24fsecod
           #
           #if l_ctb00g01.totanl > 0 then
           #   display "Ordem de servico nao pode ser paga, pendencia(s) em analise - ",
           #           bdbsa106.atdsrvnum clipped, " ", bdbsa106.atdsrvano clipped
           #   initialize bdbsa106.* to null
           #   continue foreach
           #end if

           let bdbsa106.c24evtcod = 0
           
           #CT: 14082892
           #Para nao validar sempre a MESMA LOCADORA!
           if bdbsa106.lcvcod <> l_codLocAnt then
              let l_flgTemFavorecido = bdbsa106_validarFavLocadora(bdbsa106.lcvcod)
           end if
           #CT: 14082892 - fim
           
           #CT: 14082892
           if l_flgTemFavorecido = true then 
           #CT: 14082892 - fim
              let l_codLocAnt = bdbsa106.lcvcod
           
              whenever error continue
                 select lcvlojtip
                   into ws.lcvlojtip
                   from datkavislocal
                  where lcvcod = bdbsa106.lcvcod
                    and aviestcod = bdbsa106.aviestcod
              whenever error stop
              
              if ws.lcvlojtip = 1 then
                 display "CORPORACAO"
                 let bdbsa106.quebra = bdbsa106.lcvcod + bdbsa106.ciaempcod + 1
                 let bdbsa106.flgtiplja = true
              else
                 display "LOJA"
                 let bdbsa106.quebra = bdbsa106.lcvcod + bdbsa106.ciaempcod
                 let bdbsa106.flgtiplja = false
              end if
              
              output to report bdbsa106_rel(bdbsa106.*)
                         
           else

              if bdbsa106.lcvcod <> l_codLocAnt then
                 display "#LOCADORA sem FAVORECIDO!#"
                 let l_auxChar = bdbsa106.lcvcod
                 let l_locadoras = l_locadoras,l_auxChar clipped,","
                 let l_flgEnviarEmail = true
                 let l_codLocAnt = bdbsa106.lcvcod
              end if
           
           end if
          
      end foreach

  end foreach

  #CT: 14082892
  if l_flgEnviarEmail = true then
     display "l_locadoras ", l_locadoras
     let l_msgEmail = "Favor cadastrar um favorecido para as locadoras"
                      ," informadas neste email para que a O.P de carro extra "
                      ," seja processada: "
     
     let l_msgEmail = l_msgEmail,l_locadoras clipped
     
     let l_retorno = ctx22g00_mail_corpo("BDBSA106","ERRO O.P: Locadoras SEM favorecido",l_msgEmail)
                      
     if l_retorno <> 0 then
        if l_retorno <> 99 then
           display "Erro ao enviar Email(ctx22g00)"
        else
           display "Nao foi encontrado email para esse modulo - BDBSA106"
        end if
     end if
  end if
  #CT: 14082892 - fim
  
  finish report bdbsa106_rel

  if m_transacao = 1 then
     commit work
  end if

  # ENVIA ARQUIVO COM SERVICO FORA DA INTEGRA��O

  let l_data = today using "ddMMyyyy"
  let l_path02 = l_path02 clipped, "/SRVNAOINT",l_data using "&&&&&&&&",".xls"

  let ws.contador = null

  select count(*)
    into ws.contador
    from tbtemp_op_nint

  if ws.contador is not null and
     ws.contador > 0         then

     declare cbdbsa106014 cursor for
     select * from tbtemp_op_nint
      order by atdsrvnum, atdsrvano

     let l_data = current
     display " INICIO ARQUIVO DE SERVI�OS N�O INTEGRA��O: ", l_data
     start report rel_tempsrv to l_path02

     output to report rel_tempsrv( 1, r_tempsrv.* )

     foreach cbdbsa106014 into  r_tempsrv.*
        output to report rel_tempsrv( 2, r_tempsrv.* )
     end foreach

     finish report rel_tempsrv
     let l_data = current
     display " FINALIZOU CRIA��O DE ARQUIVO DE SERVI�OS N�O INTEGRA��O: ", l_data

  end if
  call bdbsa106_enviaSrvNaoInt(l_path02)

end function

#---------------------------------------------------------------------------
report bdbsa106_rel(r_bdbsa106)
#---------------------------------------------------------------------------

  define r_bdbsa106 record
      atdsrvnum like datmavisrent.atdsrvnum,
      atdsrvano like datmavisrent.atdsrvano,
      lcvcod    like datmavisrent.lcvcod   ,
      aviestcod like datmavisrent.aviestcod,
      srvprlflg like datmservico.srvprlflg ,
      ciaempcod like datmservico.ciaempcod ,
      c24evtcod like datmsrvanlhst.c24evtcod,
      atddat    like datmservico.atddat     ,
      atdhor    like datmservico.atdhor     ,
      flgtiplja smallint                    ,
      quebra    integer
  end record

  define ws record
     socopgnum        like dbsmopg.socopgnum      ,
     socfatitmqtd     like dbsmopg.socfatitmqtd   ,
     socfattotvlr     like dbsmopg.socfattotvlr   ,
     empcod           like dbsmopg.empcod         ,
     cctcod           like dbsmopg.cctcod         ,
     cgccpfnum        like dbsmopg.cgccpfnum      ,
     cgcord           like dbsmopg.cgcord         ,
     cgccpfdig        like dbsmopg.cgccpfdig      ,
     succod           like dbsmopg.succod         ,
     socpgtdoctip     like dbsmopg.socpgtdoctip   ,
     pgtdstcod        like dbsmopg.pgtdstcod      ,
     socopgfavnom_fav like dbsmopgfav.socopgfavnom,
     socpgtopccod_fav like dbsmopgfav.socpgtopccod,
     pestip_fav       like dbsmopgfav.pestip      ,
     cgccpfnum_fav    like dbsmopgfav.cgccpfnum   ,
     cgcord_fav       like dbsmopgfav.cgcord      ,
     cgccpfdig_fav    like dbsmopgfav.cgccpfdig   ,
     bcocod_fav       like dbsmopgfav.bcocod      ,
     bcoagnnum_fav    like dbsmopgfav.bcoagnnum   ,
     bcoagndig_fav    like dbsmopgfav.bcoagndig   ,
     bcoctanum_fav    like dbsmopgfav.bcoctanum   ,
     bcoctatip_fav    like dbsmopgfav.bcoctatip   ,
     tempo            char (08)                   ,
     hora             char (05)                   ,
     transacao        decimal (1,0)               ,
     socopgitmnum     like dbsmopgitm.socopgitmnum,
     socopgitmvlr     like dbsmopgitm.socopgitmvlr,
     c24utidiaqtd     like dbsmopgitm.c24utidiaqtd,
     c24pagdiaqtd     like dbsmopgitm.c24pagdiaqtd,
     contador         integer                     ,
     rodar            char (500)
  end record

  define r_tempop record
     socopgnum        decimal (8,0),
     socopgitmnum     decimal (4,0),
     atdsrvnum        decimal (10,0),
     atdsrvano        decimal (2,0),
     atddat           date,
     atdhor           char (05),
     socopgitmvlr     decimal (15,5),
     c24utidiaqtd     like dbsmopgitm.c24utidiaqtd,
     c24pagdiaqtd     like dbsmopgitm.c24pagdiaqtd
  end record

  define ws_fase       integer
  define l_path01      char(100)

  define l_path03      char(100)
  define l_diassol     smallint
  define l_result      smallint
  define l_atdsrvnum   like dbscadtippgt.nrosrv
  define l_atdsrvano   like dbscadtippgt.anosrv
  define l_pgttipcodps like dbscadtippgt.pgttipcodps
  define l_empcod      like dbscadtippgt.empcod
  define l_succod      like dbscadtippgt.succod
  define l_cctcod      like dbscadtippgt.cctcod
  define l_data        char(20)
  define l_param       char(300)
  define l_retorno     smallint
  define l_hour        datetime hour to minute
  define l_fvrlojcod   like datklocadora.fvrlojcod
  define l_aviestcod   like datkavislocal.aviestcod

  output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

  order by r_bdbsa106.ciaempcod,
           r_bdbsa106.lcvcod,
           r_bdbsa106.quebra,
           r_bdbsa106.c24evtcod,
           r_bdbsa106.atdsrvnum,
           r_bdbsa106.atdsrvano

  format
     before group of r_bdbsa106.quebra
       delete from tbtemp_op

       # DEFINIR EMPRESA DA OP, EMPRESA DO PRIMEIRO ITEM
       if m_empcod is null or m_empcod != r_bdbsa106.ciaempcod
          then
          let m_empcod = r_bdbsa106.ciaempcod
       end if

         let m_transacao = 1
         if r_bdbsa106.c24evtcod is not null  and
            r_bdbsa106.c24evtcod <> 0         then
            let ws.socopgnum = 0
         else
            select max(socopgnum)
              into ws.socopgnum
              from dbsmopg
             where lcvcod    =  r_bdbsa106.lcvcod
               and socopgsitcod  =  7

            select empcod      , cctcod   ,
                   cgccpfnum   , cgcord   ,
                   cgccpfdig   , succod   ,
                   socpgtdoctip, pgtdstcod
              into ws.empcod   , ws.cctcod,
                   ws.cgccpfnum, ws.cgcord,
                   ws.cgccpfdig, ws.succod,
                   ws.socpgtdoctip, ws.pgtdstcod
              from dbsmopg
             where socopgnum = ws.socopgnum

            select fvrlojcod
              into l_fvrlojcod
              from datklocadora
             where lcvcod = r_bdbsa106.lcvcod

            select aviestcod
              into l_aviestcod
              from datkavislocal
             where lcvcod = r_bdbsa106.lcvcod
               and lcvextcod = l_fvrlojcod

            select favnom             , pgtopccod          , pestip,
                   cgccpfnum          , cgcord             , cgccpfdig,
                   bcocod             , bcoagnnum          , bcoagndig,
                   bcoctanum          , bcoctatip
              into ws.socopgfavnom_fav, ws.socpgtopccod_fav, ws.pestip_fav,
                   ws.cgccpfnum_fav   , ws.cgcord_fav      , ws.cgccpfdig_fav,
                   ws.bcocod_fav      , ws.bcoagnnum_fav   , ws.bcoagndig_fav,
                   ws.bcoctanum_fav   , ws.bcoctatip_fav
              from datklcvfav
             where lcvcod = r_bdbsa106.lcvcod
               and aviestcod = l_aviestcod

            select max(socopgnum)
              into ws.socopgnum
              from dbsmopg
             where socopgnum > 0

            if ws.socopgnum is null   then
               let ws.socopgnum = 0
            end if

            let ws.socopgnum    = ws.socopgnum + 1
            let ws.socfatitmqtd = 0
            let ws.socfattotvlr = 0
            let ws.tempo = time
            let ws.hora  = ws.tempo[1,5]

            whenever error continue

            # EMPRESA DA OP DO PRIMEIRO ITEM NAO DISPONIVEL, ASSUME A DA OP ANTERIOR
            if m_empcod is null then
               let m_empcod = ws.empcod
            end if

            let ws.socfattotvlr = ws.socfattotvlr using "&&&&&&&&&&&&&&&.&&"

            display "OP_LOCA NUM: ",ws.socopgnum
            display "--->ws.socopgnum         = ",ws.socopgnum
            display "--->ws_socfatentdat      = ",ws_socfatentdat
            display "--->ws_socfatpgtdat      = ",ws_socfatpgtdat
            display "--->ws_socfatpgtdat      = ",ws_socfatpgtdat
            display "--->r_bdbsa106.lcvcod    = ",r_bdbsa106.lcvcod

            insert into dbsmopg(socopgnum,
                                socfatentdat,
                                socfatpgtdat,
                                socfatitmqtd,
                                socfattotvlr,
                                empcod,
                                cctcod,
                                pestip,
                                cgccpfnum,
                                cgcord,
                                cgccpfdig,
                                socopgsitcod,
                                atldat,
                                funmat,
                                socpgtdoctip,
                                socemsnfsdat,
                                pgtdstcod,
                                socopgorgcod,
                                soctip,
                                lcvcod,
                                aviestcod,
                                favtip)
                        values (ws.socopgnum,
                                ws_socfatentdat,
                                ws_socfatpgtdat,
                                ws.socfatitmqtd,
                                ws.socfattotvlr,
                                m_empcod,
                                ws.cctcod,
                                ws.pestip_fav,
                                ws.cgccpfnum,
                                ws.cgcord,
                                ws.cgccpfdig,
                                9,
                                today,
                                999999,
                                ws.socpgtdoctip,
                                ws_socfatpgtdat,
                                ws.pgtdstcod,
                                2,
                                2,
                                r_bdbsa106.lcvcod,
                                l_aviestcod,
                                4)
            if sqlca.sqlcode  <>  0   then
                display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPG!"
                rollback work
                exit program (1)
            end if

            insert into dbsmopgfav (socopgnum   ,
                                    socopgfavnom,
                                    socpgtopccod,
                                    pestip      ,
                                    cgccpfnum   ,
                                    cgcord      ,
                                    cgccpfdig   ,
                                    bcocod      ,
                                    bcoagnnum   ,
                                    bcoagndig   ,
                                    bcoctanum   ,
                                    bcoctatip   )
                            values (ws.socopgnum,
                                    ws.socopgfavnom_fav,
                                    ws.socpgtopccod_fav,
                                    ws.pestip_fav,
                                    ws.cgccpfnum_fav,
                                    ws.cgcord_fav,
                                    ws.cgccpfdig_fav,
                                    ws.bcocod_fav,
                                    ws.bcoagnnum_fav,
                                    ws.bcoagndig_fav,
                                    ws.bcoctanum_fav,
                                    ws.bcoctatip_fav)
            if sqlca.sqlcode  <>  0   then
               display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGFAV!"
               rollback work
               exit program (1)
            end if

            for ws_fase = 1 to 3
               insert into dbsmopgfas (socopgnum,
                                       socopgfascod,
                                       socopgfasdat,
                                       socopgfashor,
                                       funmat)
                              values  (ws.socopgnum,
                                       ws_fase,     # protoc./analise/digit.
                                       today,
                                       ws.hora,
                                       999999)

               if sqlca.sqlcode  <>  0   then
                  display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGFAS!"
                  rollback work
                  exit program (1)
               end if
            end for

            whenever error stop
         end if

     after group of r_bdbsa106.quebra
       if ws.socopgnum is not null and
          ws.socopgnum <> 0        then
          update dbsmopg set (socfatitmqtd, socfattotvlr )
                          =  (ws.socfatitmqtd, ws.socfattotvlr )
                 where  socopgnum = ws.socopgnum
          if sqlca.sqlcode  <>  0   then
             display "Erro (",sqlca.sqlcode,") alteracao tabela DBSMOPG!"
             rollback work
             exit program (1)
          end if
       end if


       whenever error continue

       let l_path01 = f_path("DBS","ARQUIVO")
       if l_path01 is null then
          let l_path01 = "."
       end if

       if r_bdbsa106.flgtiplja = true then
          let l_path01 = l_path01 clipped,"/OPRE",r_bdbsa106.lcvcod using "&&&" ,m_empcod using "&&", ".xls"
       else
          let l_path03 = l_path01 clipped,"/OPREFRN",r_bdbsa106.lcvcod using "&&&" ,m_empcod using "&&", ".xls"
       end if

       let l_param = "OP LOCADORA ",r_bdbsa106.lcvcod using '#&&&&&'

       select count(*)
         into ws.contador
         from tbtemp_op

       if ws.contador is not null and
          ws.contador > 0         then

          declare cbdbsa106011 cursor for
          select * from tbtemp_op
           order by socopgitmnum

          let l_data = current
          display "Inicio Cria��o de OP: ", l_data

          if r_bdbsa106.flgtiplja = true then
             let l_param = l_param clipped," CORPORACAO "," de ",ws_socfatentdat
             start report rel_tempop to l_path01
          else
             let l_param = l_param clipped," FRANQUIA "," de ",ws_socfatentdat
             start report rel_tempop to l_path03
          end if

          output to report rel_tempop( 1, r_tempop.*,l_param )

          foreach cbdbsa106011 into  r_tempop.*
             output to report rel_tempop( 2, r_tempop.*,l_param )
          end foreach

          finish report rel_tempop
          let l_data = current
          display "Finalizou Cria��o de OP: ", l_data

          #envio de email a loja
          if r_bdbsa106.flgtiplja = true then
             call cty24g00_enviar_op(ws.socopgnum,l_path01)
          else
             call cty24g00_enviar_op(ws.socopgnum,l_path03)
          end if

       else
          initialize ws.rodar  to null
          let ws.rodar = "echo 'ARQUIVO DO PERIODO ", ws_incdat ,
                         " A ", ws_fnldat, " SEM MOVIMENTO",ascii(13),"' > ",
                         l_path01 clipped
          run ws.rodar
       end if

       if r_bdbsa106.flgtiplja = true then

          let l_param = l_param clipped," CORPORACAO "," de ",ws_socfatentdat

          let l_retorno = ctx22g00_envia_email("BDBSA106",
                                               l_param,
                                               l_path01)
       else

          let l_param = l_param clipped," FRANQUIA "," de ",ws_socfatentdat

          let l_retorno = ctx22g00_envia_email("BDBSA106",
                                               l_param,
                                               l_path03)
       end if

       if l_retorno <> 0 then
          if l_retorno <> 99 then
             display " ERRO AO ENVIAR EMAIL(CTX22G00) - ",l_path01
          else
             display " NAO FOI ENCONTRADO EMAIL PARA ESSE MODULO - BDBSA106"
          end if
       end if

       whenever error stop

    on every row
       initialize l_diassol,
                  ws.c24utidiaqtd,
                  ws.c24pagdiaqtd,
                  ws.socopgitmvlr to null

       call cty24g00(r_bdbsa106.atdsrvnum,
                      r_bdbsa106.atdsrvano)
            returning l_result,
                      l_diassol,
                      ws.c24utidiaqtd,
                      ws.c24pagdiaqtd,
                      ws.socopgitmvlr

       if l_result = true then
          select max(socopgitmnum)
            into ws.socopgitmnum
            from dbsmopgitm
           where socopgnum = ws.socopgnum

          if ws.socopgitmnum   is null   then
             let ws.socopgitmnum = 0
          end if
          let ws.socopgitmnum = ws.socopgitmnum + 1

          let ws.socopgitmvlr = ws.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

           insert into dbsmopgitm (socopgnum,
                                  socopgitmnum,
                                  atdsrvnum,
                                  atdsrvano,
                                  socopgitmvlr,
                                  vlrfxacod,
                                  funmat,
                                  socconlibflg,
                                  c24utidiaqtd,
                                  c24pagdiaqtd)
                          values (ws.socopgnum,
                                  ws.socopgitmnum,
                                  r_bdbsa106.atdsrvnum,
                                  r_bdbsa106.atdsrvano,
                                  ws.socopgitmvlr,
                                  1 ,
                                  999999,
                                  "N",
                                  ws.c24utidiaqtd,
                                  ws.c24pagdiaqtd)

          if sqlca.sqlcode  <>  0   then
             display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGITM!"
             rollback work
             exit program (1)
          end if

          let ws.socfatitmqtd = ws.socfatitmqtd + 1
          let ws.socfattotvlr = ws.socfattotvlr + ws.socopgitmvlr

          open cbdbsa106008 using r_bdbsa106.atdsrvnum,
                                  r_bdbsa106.atdsrvano
          fetch cbdbsa106008 into l_atdsrvnum,
             		       l_atdsrvano,
             		       l_pgttipcodps,
             		       l_empcod,
             		       l_succod,
             		       l_cctcod
          close cbdbsa106008

          if l_pgttipcodps = 3 then
             whenever error continue
                open cbdbsa106009 using l_atdsrvnum,
                                        l_atdsrvano
                fetch cbdbsa106009 into m_atdsrvnum,
                                        m_atdsrvano
             whenever error stop

             if sqlca.sqlcode <> 0 then
                display "Erro selecao dbsmcctrat"
             end if

             if m_atdsrvnum is null or m_atdsrvnum = 0 then
                whenever error continue

                   let ws.socopgitmvlr = ws.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

                   insert into dbsmcctrat values (l_atdsrvnum,
                                                  l_atdsrvano,
                                                  l_empcod,
                                                  l_succod,
                                                  l_cctcod,
                                                  ws.socopgitmvlr)
                whenever error stop
                   if sqlca.sqlcode <> 0 then
                      display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMCCTRAT"
                      rollback work
                         exit program (1)
                   end if
             end if

          end if

          insert into tbtemp_op
                     values(ws.socopgnum,
                            ws.socopgitmnum,
                            r_bdbsa106.atdsrvnum,
                            r_bdbsa106.atdsrvano,
                            r_bdbsa106.atddat,
                            r_bdbsa106.atdhor,
                            ws.c24utidiaqtd,
                            ws.c24pagdiaqtd,
                            ws.socopgitmvlr)

          if sqlca.sqlcode  <>  0   then
             display "Erro (",sqlca.sqlcode,") inclusao tabela TEMPORARIA OK!"
             rollback work
             exit program (1)
          end if
       end if

end report

#---------------------------------------------------------------------------
 report rel_tempop( ws_flgcab, r_tempop,l_param)
#---------------------------------------------------------------------------

 define ws_flgcab    smallint

 define r_tempop record
     socopgnum        decimal (8,0),
     socopgitmnum     decimal (4,0),
     atdsrvnum        decimal (10,0),
     atdsrvano        decimal (2,0),
     atddat           date,
     atdhor           char (05),
     c24utidiaqtd     like dbsmopgitm.c24utidiaqtd,
     c24pagdiaqtd     like dbsmopgitm.c24pagdiaqtd,
     socopgitmvlr     decimal (15,5)
  end record
  
  define lr_relat record
      vcleftretdat like datmrsvvcl.vcleftretdat,
      vcleftdvldat like datmrsvvcl.vcleftdvldat
  end record

  define l_param      char(300)

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format

    on every row
        if ws_flgcab = 1 then

           print column 001, "RELA��O DE SERVI�OS POR OP"
           print column 001, " "
           print column 001, l_param clipped,ascii(13)
           print column 001, ascii(13)
           print column 001, "NUMERO DA OP", ascii(09),
                             "ITEM DA OP", ascii(09),
                             "NUMERO DO SERVI�O", ascii(09),
                             "ANO DO SERVI�O", ascii(09),
                             "DATA", ascii(09),
                             "HORA", ascii(09),
                             "QTD DIAS UTIL.", ascii(09),
                             "QTD DIAS PGS", ascii(09),
                             "RETIRADA EFETIVA", ascii(09),
                             "DEVOLU��O EFETIVA", ascii(09),
                             "VALOR TOTAL", ascii(09),                             
                             ascii(13)
        else
           print column 001, r_tempop.socopgnum     using "<<<<<<<#", ascii(09),
                             r_tempop.socopgitmnum  using "<<<#"    , ascii(09),
                             r_tempop.atdsrvnum     using "&&&&&&&" , ascii(09),
                             r_tempop.atdsrvano     using "&&"      , ascii(09),
                             r_tempop.atddat                        , ascii(09),
                             r_tempop.atdhor                        , ascii(09),
                             r_tempop.c24utidiaqtd  using "&&&"     , ascii(09),
                             r_tempop.c24pagdiaqtd  using "&&&"     , ascii(09);
                             
                   whenever error continue          
                    select vcleftretdat, 
                           vcleftdvldat 
                      into lr_relat.vcleftretdat,
                           lr_relat.vcleftdvldat
                      from datmrsvvcl
                     where atdsrvnum = r_tempop.atdsrvnum
                       and atdsrvano = r_tempop.atdsrvano         
                   whenever error stop          

            print lr_relat.vcleftretdat  ,ascii(09),   
                  lr_relat.vcleftdvldat  ,ascii(09),   
                  r_tempop.socopgitmvlr  using "######.##",ascii(09),
                  ascii(13)
        end if

 end report    ### rel_tempop

 #---------------------------------------------------------------------------
 function bdbsa106_enviaSrvNaoInt(param)
 #---------------------------------------------------------------------------

   define param record
      arquivo char(300)
   end record

   define l_param char(3000),
          l_retorno smallint

   initialize l_param to null

   let l_param = "SERVICOS FORA DA INTEGRACAO DE ",ws_socfatentdat

   let l_retorno = ctx22g00_envia_email("BDBSA106",
                                        l_param,
                                        param.arquivo)

   if l_retorno <> 0 then
      if l_retorno <> 99 then
         display "Erro ao enviar Email(ctx22g00) - ",param.arquivo
      else
         display "Nao foi encontrado email para esse modulo - BDBSA106"
      end if
   end if

 end function

#---------------------------------------------------------------------------
 report rel_tempsrv( ws_flgcab, r_tempop)
#---------------------------------------------------------------------------

 define ws_flgcab    smallint,
        l_flag       smallint

 define r_tempop record
     atdsrvnum        decimal (10,0),
     atdsrvano        decimal (2,0)
  end record
  
  define lr_relat record
         ciaempcod    like datmservico.ciaempcod,   
         avialgmtv    like datmavisrent.avialgmtv,   
         lcvextcod    like datkavislocal.lcvextcod,   
         qtd_solic    smallint,   
         c24utidiaqtd smallint,
         c24pagdiaqtd smallint,
         socopgtotvlr like dbsmopgitm.socopgitmvlr
  end record
  
  
 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format

    on every row
        if ws_flgcab = 1 then
           print column 001, "RELA��O DE SERVI�OS QUE N�O ENTRARAM NA OP"
           print column 001, " "
           print column 001, "SERVI�O",  ascii(09),
                             "ANO",      ascii(09),
                             "EMPRESA",  ascii(09), 
                             "MOTIVO",   ascii(09),
                             "LOJA",     ascii(09),
                             "SOL",      ascii(09),
                             "UTL",      ascii(09),
                             "PAGO",     ascii(09),
                             "VALOR",    ascii(13)           
        else                 
           call cty24g00(r_tempop.atdsrvnum,
                         r_tempop.atdsrvano)
           returning l_flag,
                     lr_relat.qtd_solic,    
                     lr_relat.c24utidiaqtd, 
                     lr_relat.c24pagdiaqtd, 
                     lr_relat.socopgtotvlr                              
                             
           select srv.ciaempcod,                                 
                  rnt.avialgmtv,                                 
                  lja.lcvextcod
             into lr_relat.ciaempcod,
                  lr_relat.avialgmtv,
                  lr_relat.lcvextcod                          
            from datmavisrent  rnt,                              
                 datmservico   srv,                              
                 datkavislocal lja                               
           where srv.atdsrvnum = r_tempop.atdsrvnum
             and srv.atdsrvano = r_tempop.atdsrvano
             and srv.atdsrvnum = rnt.atdsrvnum                   
             and srv.atdsrvano = rnt.atdsrvano                   
             and rnt.aviestcod = lja.aviestcod  
             
           print column 001, r_tempop.atdsrvnum     using "&&&&&&&" , ascii(09),
                             r_tempop.atdsrvano     using "&&"      , ascii(09),
                             lr_relat.ciaempcod                     , ascii(09),
                             lr_relat.avialgmtv                     , ascii(09),
                             lr_relat.lcvextcod                     , ascii(09),
                             lr_relat.qtd_solic                     , ascii(09),
                             lr_relat.c24utidiaqtd                  , ascii(09),
                             lr_relat.c24pagdiaqtd                  , ascii(09),
                             lr_relat.socopgtotvlr                  , ascii(09),
                             ascii(13)            
            
        end if

 end report    ### rel_tempop

 #---------------------------------------------------------------------------
 function bdbsa106_lerarquivo(l_path)
 #---------------------------------------------------------------------------

 define l_path char(3000)
 define l_comando char(3000)

 define l_atdsrvnum   like dbscadtippgt.nrosrv
 define l_atdsrvano   like dbscadtippgt.anosrv
 define l_pgttipcodps like dbscadtippgt.pgttipcodps
 define l_empcod      like dbscadtippgt.empcod
 define l_succod      like dbscadtippgt.succod
 define l_cctcod      like dbscadtippgt.cctcod

 define ws record
      socopgitmnum decimal (4,0)              ,
      atdsrvnum    like datmavisrent.atdsrvnum,
      atdsrvano    like datmavisrent.atdsrvano,
      socopgnum    decimal (8,0)              ,
      atddat       like datmservico.atddat    ,
      atdhor       like datmservico.atdhor    ,
      c24utidiaqtd smallint                   ,
      c24pagdiaqtd smallint                   ,
      socopgitmvlr decimal (15,5)
 end record

 database work;

 whenever error continue
 drop table tbtemp_aux;
 drop table tbtemp_xls;

 create table tbtemp_aux
    (atdsrvnum        decimal (10,0),
     atdsrvano        decimal (2,0) ,
     socopgnum        decimal (8,0) ,
     c24utidiaqtd     smallint,
     c24pagdiaqtd     smallint,
     socopgitmvlr     decimal (15,5))# with no log

 create table tbtemp_xls
    (socopgnum        decimal (8,0),
     socopgitmnum     decimal (4,0),
     atdsrvnum        decimal (10,0),
     atdsrvano        decimal (2,0),
     atddat           date ,
     atdhor           char (05),
     c24utidiaqtd     smallint,
     c24pagdiaqtd     smallint,
     socopgitmvlr     decimal (15,5))# with no log

 #start report rel_dbloadConfig to "./dbload"
 #  output to report rel_dbloadConfig( l_path )
 #finish report rel_dbloadConfig

 #let l_comando = "dbload -d work -c dbload -l 'log1' -i 1"
 #run l_comando
 #
 #let l_comando = "rm dbload"
 #run l_comando

 if sqlca.sqlcode <> 0 then
    display "erro: ",sqlca.sqlcode
    exit program(1)
 end if

 whenever error stop
 database porto;

 call bdbsa106_prepare()

 declare cbdbsa106016 cursor for
    select * from work:tbtemp_aux;

 begin work

 foreach cbdbsa106016 into ws.atdsrvnum,
                           ws.atdsrvano,
                           ws.socopgnum,
                           ws.c24utidiaqtd,
                           ws.c24pagdiaqtd,
                           ws.socopgitmvlr

     select max(socopgitmnum) + 1
       into ws.socopgitmnum
       from dbsmopgitm
      where socopgnum = ws.socopgnum

     if ws.socopgitmnum  is null   then
        let ws.socopgitmnum = 1
     end if

      display "Servico: ",ws.atdsrvnum    using "&&&&&&&&&&", " ",ws.atdsrvano    using "&&" , " ",
                          ws.socopgnum    using "&&&&&&&&"  , " ",ws.c24utidiaqtd using "&&&", " ",
                          ws.c24pagdiaqtd using "&&&"       , " ",ws.socopgitmvlr

      insert into dbsmopgitm (socopgnum,
                              socopgitmnum,
                              atdsrvnum,
                              atdsrvano,
                              socopgitmvlr,
                              vlrfxacod,
                              funmat,
                              socconlibflg,
                              c24utidiaqtd,
                              c24pagdiaqtd)
                      values (ws.socopgnum,
                              ws.socopgitmnum,
                              ws.atdsrvnum,
                              ws.atdsrvano,
                              ws.socopgitmvlr,
                              1 ,
                              999999,
                              "N",
                              ws.c24utidiaqtd,
                              ws.c24pagdiaqtd)

          if sqlca.sqlcode  <>  0   then
             display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMOPGITM!"
             rollback work
             drop table tbtemp_aux;
             drop table tbtemp_xls;
             exit program (1)
          end if

          open cbdbsa106008 using ws.atdsrvnum,
                                  ws.atdsrvano
          fetch cbdbsa106008 into l_atdsrvnum,
             		          l_atdsrvano,
             		          l_pgttipcodps,
             		          l_empcod,
             		          l_succod,
             		          l_cctcod
          close cbdbsa106008

          if l_pgttipcodps = 3 then
             whenever error continue
                open cbdbsa106009 using l_atdsrvnum,
                                        l_atdsrvano
                fetch cbdbsa106009 into m_atdsrvnum,
                                        m_atdsrvano
             whenever error stop

             if sqlca.sqlcode <> 0 then
                display "Erro selecao dbsmcctrat"
             end if

             if m_atdsrvnum is null or m_atdsrvnum = 0 then
                whenever error continue

                   let ws.socopgitmvlr = ws.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

                   insert into dbsmcctrat values (l_atdsrvnum,
                                                  l_atdsrvano,
                                                  l_empcod,
                                                  l_succod,
                                                  l_cctcod,
                                                  ws.socopgitmvlr)
                whenever error stop
                   if sqlca.sqlcode <> 0 then
                      display "Erro (",sqlca.sqlcode,") inclusao tabela DBSMCCTRAT"
                      rollback work
                      drop table tbtemp_aux;
                      drop table tbtemp_xls;
                      exit program (1)
                   end if
             end if

          end if

 end foreach

 commit work

 database work;
 drop table tbtemp_aux;
 drop table tbtemp_xls;

end function


#---------------------------------------------------------------------------
 report rel_dbloadConfig(l_path)
#---------------------------------------------------------------------------

 define l_path char(3000)

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format

    on every row

        print column 001,"file '",l_path clipped,"' DELIMITER '	' 6;"
        print column 001,"insert into tbtemp_aux;"

 end report
 
 #---------------------------------------------------------------------------
 function bdbsa106_validarFavLocadora(p_lcvcod) #CT: 14082892
 #---------------------------------------------------------------------------
 
 define p_lcvcod smallint
 define l_favnom   char(50)
 define l_fvrlojcod varchar(255)
 define l_aviestcod decimal(5,0)
 define l_flgTemFavorecido smallint
 
 #INICIALIZACAO DAS VARIAVEIS LOCAIS
 let l_favnom    = null
 let l_fvrlojcod = null
 let l_aviestcod = null
 let l_flgTemFavorecido = true
 
 display "### Validando se a locadora, ",p_lcvcod," possui FAVORECIDO. ###"

 #Obtem o codigo do favorecido
 open cbdbsa106017 using p_lcvcod
 whenever error continue
  fetch cbdbsa106017 into l_fvrlojcod
 whenever error stop
 
 if sqlca.sqlcode  <>  0   then
   if sqlca.sqlcode = 100 then
      display "NAO possui favorecido!!"
      let l_flgTemFavorecido = false
   else
      display "Erro (",sqlca.sqlcode,") ao buscar codigo do favorecido!"
      exit program (1)
   end if
 end if
 
 #Obtem o codigo da LOJA
 open cbdbsa106018 using p_lcvcod
                        ,l_fvrlojcod
                        
 whenever error continue
  fetch cbdbsa106018 into l_aviestcod
 whenever error stop

 if sqlca.sqlcode  <>  0   then
    if sqlca.sqlcode = 100 then
       display "NAO possui loja ou unidade AVIS!!"
       let l_flgTemFavorecido = false
    else
       display "Erro (",sqlca.sqlcode,") ao buscar loja!"
       exit program (1)
    end if
 end if
 
 #Obtem o codigo da LOJA
 open cbdbsa106019 using p_lcvcod
                        ,l_aviestcod
                        
 whenever error continue
  fetch cbdbsa106019 into l_favnom
 whenever error stop
 
 if sqlca.sqlcode  <>  0   then
    if sqlca.sqlcode = 100 then
       display "NAO possui loja ou unidade AVIS 2!!"
       let l_flgTemFavorecido = false
    else
       display "Erro (",sqlca.sqlcode,") ao buscar loja! 2"
       exit program (1)
    end if
 end if
 
 display "### FIM validacao Favorecido. ###"
 
 return l_flgTemFavorecido                      
 
 end function