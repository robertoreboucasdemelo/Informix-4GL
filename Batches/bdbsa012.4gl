##############################################################################
#  Programa : bdbsa012                                                       #
#             Atualiza valores susep147 (ATUAL CIRCULAR 169)                 #
##############################################################################
#                     * * * * A L T E R A C O E S * * * *                    #
# DATA       AUTHOR               DESCRICAO RESUMIDA DA ALTERACAO            #
# 22/04/2003 FERNANDO - FSW       RESOLUCAO 86                               #
#----------------------------------------------------------------------------#
##############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Marcio, Meta      PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# 16/11/2006 Alberto Rodrigues   205206  implementado leitura campo ciaempcod #
#                                        para desprezar qdo for Azul Segur.   #
###############################################################################

database porto

define w_comando  char(2000)

define g_reg    record
   anomes       integer,
   orrdat       date,
   pgtdat       date,
   ramcod       dec(4,0),
   total        dec(15,5)
end record

define r_reg record
       succod        like abamdoc.succod,
       aplnumdig     like abamdoc.aplnumdig,
       edsnumdig     like abamdoc.edsnumdig,
       itmnumdig     like abbmitem.itmnumdig,
       dctnumseq     like abbmclaus.dctnumseq,
       segnumdig     integer,
       cbtcod        like abbmcasco.cbtcod,
       modvclcoddig  like agbkveic.modvclcoddig,
       vclanomdl     like abbmveic.vclanomdl,
       vclcoddig     like abbmveic.vclcoddig,
       ctgtrfcod     like abbmcasco.ctgtrfcod,
       clalclcod     like abbmdoc.clalclcod,
       vlrtotal      dec(15,5) ,
       pgtdat        date,
       sexo          char(01),
       data_nasc     char(10),
       rnvsuccod     like abbmitem.rnvsuccod,
       rnvaplnum     like abbmitem.rnvaplnum,
       rnvitmnum     like abbmitem.rnvitmnum,
       sinano        char(4),
       sinnum        integer
end record

define w_vcllicnum       like adimvdrrpr.vcllicnum
define w_vclchsfnl       like adimvdrrpr.vclchsfnl
define w_caddat          like adimvdrrpr.caddat
define w_vdrrprnum       like adimvdrrpr.vdrrprnum
define w_pestip          char(1)
define w_ctgtrfcod_cia   like  abbmcasco.ctgtrfcod
define w_ctgtrfcod       like     abbmcasco.ctgtrfcod
define w_viginc          like abbmitem.viginc
define w_vigfnl          like abbmitem.vigfnl
define ws_aplnumdig      like abamdoc.aplnumdig
define ws_count          integer
define ws_emsdat         date
define w_grlinf          like igbkgeral.grlinf
define w_pgto            dec (20,5)
define w_sem_cls         dec (20,5)
define w_param           char(15)
define ws_datade         date
define ws_dataate        date
define w_aux_dat         char(10)
define arr_aux           integer
define ws_dtchar         char (10)
define ws_mes            smallint
define ws_ano            smallint
define ws_anomes         integer
define ws_anomes2        char (07)
define ws_perde          integer
define ws_perate         integer
define ws_sinano         char (04)
define ws_sinnum         integer

main

  DATABASE work

  whenever error continue
  create table work:pgtos_psoc
         (anomes       integer,
          orrdat       date,
          pgtdat       date,
          ramcod       dec(4,0),
          total        dec(15,5))

  whenever error stop
  if sqlca.sqlcode = 0  then
     create index idx_pgtos_psoc on pgtos_psoc (anomes, orrdat, pgtdat)
  end if

  close database
  database porto

  call fun_dba_abre_banco("CT24HS")

  #------------------------------
  # Verifica paramentro IGBKGERAL
  #------------------------------
  select grlinf
    into w_grlinf
    from igbkgeral
   where mducod = "CT"
     and grlchv = "CIR-169"

  let ws_anomes2 = w_grlinf[01,07]
  let ws_sinano  = w_grlinf[01,04]
  let ws_dtchar  = w_grlinf[15,18], w_grlinf[12,13]
  let ws_perde   = ws_dtchar           # PERIODO DE
  let ws_dtchar  = w_grlinf[26,29], w_grlinf[23,24]
  let ws_perate  = ws_dtchar           # PERIODO ATE

  #------------------------------------------------
  # Limpa periodos anteriores
  #------------------------------------------------
  delete from work:pgtos_psoc
   where anomes < ws_perde

  #------------------------------------------------
  # Obtem o ultimo periodo processado
  #------------------------------------------------
  select max(anomes)
    into ws_anomes
    from work:pgtos_psoc

  if ws_anomes is null or
     ws_anomes = 0     then
     let ws_anomes = ws_perde
  else
     delete from work:pgtos_psoc
      where anomes = ws_anomes
  end if

  call bdbsa012_prepares()
  for arr_aux = ws_anomes to ws_perate
      let ws_dtchar = arr_aux using "&&&&&&&&&&"
      if ws_dtchar[9,10] = "13" then
         let arr_aux = arr_aux + 88
         let ws_dtchar = arr_aux using "&&&&&&&&&&"
      end if
      let ws_mes    = ws_dtchar[9,10]
      let ws_ano    = ws_dtchar[5,8]
      let ws_dtchar = "01/",ws_mes using "&&", ws_ano using "&&&&"
      let ws_datade   = ws_dtchar
      let ws_dtchar = "01/",
                      month(ws_datade + 32) using "&&" ,"/",
                      year (ws_datade + 32) using "&&&&"
      let ws_dataate  = ws_dtchar
      let ws_dataate  = ws_dataate - 1

      display " Aguarde... processando periodo : ",ws_datade," a ",ws_dataate

      call bdbsa012()
      call vidros()
  end for

  display " Fim processamento!!! aguarde para a carga da tab.SUSEP147 !"

  let ws_sinnum = 600000       # NRO SINISTO INICIAL

  declare c_total cursor for
   select orrdat, pgtdat, ramcod, total
     from work:pgtos_psoc

  foreach c_total into  g_reg.orrdat, g_reg.pgtdat,
                        g_reg.ramcod, g_reg.total

     insert into work@u15:susep147
                     values ( ws_anomes2  ,  #anomes
                              g_reg.ramcod,  #ramcod
                              ws_sinano   ,  #sinano
                              ws_sinnum   ,  #sinnum
                              1           ,  #sinitmseq
                              g_reg.orrdat,  #avsdat
                              g_reg.orrdat,  #arrdat
                              g_reg.pgtdat,  #pgtdat
                              g_reg.total ,  #sinmvtvl
                              g_reg.total ,  #vlbruto
                              0           ,  #vlreseg
                              0           ,  #vlcoscd
                              0           ,  #vlcosac
                              0           ,  #vlsalva
                              0           ,  #vlressa
                              0           ,  #vldesre
                              0           )  #vlestim

     let ws_sinnum = ws_sinnum + 1
  end foreach

  display " Fim processamento!!! "

end main


##-----------------------------------------------------------
function bdbsa012_prepares()
##-----------------------------------------------------------

  let w_comando = " select rnvsuccod,rnvaplnum, rnvitmnum, viginc ",
                  "   from abbmitem       ",
                  "  where succod    = ?  ",
                  "    and aplnumdig = ?  ",
                  "    and itmnumdig = ?   "

  prepare p_abbmitem from w_comando
  declare c_abbmitem cursor for p_abbmitem

  let w_comando = " select vigfnl from abamapol where succod=? and aplnumdig=? "

  prepare p_abamapol from w_comando
  declare c_abamapol cursor for p_abamapol


  let w_comando = " select dctnumseq  ",
                  "   from abbmclaus          ",
                  "  where succod    = ?      ",
                  "    and aplnumdig = ?      ",
                  "    and itmnumdig = ?      ",
                  "    and clscod in ('034','035','34A','35A', '35R') " ## psi201154

  prepare p_abbmclaus_034 from w_comando
  declare c_abbmclaus_034 cursor for p_abbmclaus_034

  let w_comando = " select dctnumseq  ",
                  "   from abbmclaus          ",
                  "  where succod    = ?      ",
                  "    and aplnumdig = ?      ",
                  "    and itmnumdig = ?      ",
                  "    and clscod = '071'  "

  prepare p_abbmclaus_071 from w_comando
  declare c_abbmclaus_071 cursor for p_abbmclaus_071

  let w_comando = " select edsnumdig          ",
                  "   from abamdoc            ",
                  "  where succod  = ?        ",
                  "    and aplnumdig = ?      ",
                  "    and dctnumseq = ?      "

  prepare p_abamdoc_eds from w_comando
  declare c_abamdoc_eds cursor for p_abamdoc_eds

  let w_comando = " select succod,aplnumdig,itmnumdig,dctnumseq ",
                  "   from abbmveic              ",
                  "  where vcllicnum = ?         "
  prepare p_abbmveic_l from w_comando
  declare c_abbmveic_l cursor for p_abbmveic_l

  let w_comando = " select succod,aplnumdig,itmnumdig,dctnumseq ",
                  "   from abbmveic              ",
                  "  where vclchsfnl = ?         "
  prepare p_abbmveic_c from w_comando
  declare c_abbmveic_c cursor for p_abbmveic_c

  let w_comando="select vdrrprpgtdat,vdrrprvlr,vcllicnum,vclchsfnl,vdrrprnum  ",
                  "   from  adimvdrrpr              ",
                  "  where  vdrrprpgtdat >=? and vdrrprpgtdat <=? "

  prepare p_adimvdrrpr from w_comando
  declare c_adimvdrrpr cursor for p_adimvdrrpr

  let w_comando = " select cbtcod             ",
                  "   from abbmcasco          ",
                  "  where succod  = ?        ",
                  "    and aplnumdig = ?      ",
                  "    and itmnumdig = ?      ",
                  "    and dctnumseq = ?      "

  prepare p_abbmcasco from w_comando
  declare c_abbmcasco cursor for p_abbmcasco

  let w_comando = "update igbkgeral ",
                  "set grlinf = ? ",
                  "where  mducod = 'BQG' and grlchv = 'BAQGA097' "

  prepare p_up_igbk from w_comando

end function


##-----------------------------------------------------------
function bdbsa012()
##-----------------------------------------------------------
 define ws         record
    atdsrvnum      like datmservico.atdsrvnum  ,  # Nro.servico
    atdsrvano      like datmservico.atdsrvano  ,  # Ano servico
    atdsrvorg      like datmservico.atdsrvorg  ,  # Origem servico
    asitipcod      like datmservico.asitipcod  ,  # Tipo assistencia
    atddat         like datmservico.atddat     ,  # Data atendimento
    socopgitmvlr   like dbsmopgitm.socopgitmvlr,  # Valor pago
    ramcod         like datrservapol.ramcod    ,  # Ramo
    succod         like datrservapol.succod    ,  # Sucursal
    aplnumdig      like datrservapol.aplnumdig ,  # Apolice
    itmnumdig      like datrservapol.itmnumdig ,  # Item
    socfatpgtdat   like dbsmopg.socfatpgtdat   ,
    ciaempcod      like datmservico.ciaempcod  ,  # Azul
    sql            char (300)                     # Sql
 end record

  let ws_count = 0

  initialize r_reg.* to null
#---------------------------------------------------------------
# Inicia variaveis e prepara SQL
#---------------------------------------------------------------
 initialize ws.* to null


 let ws.sql     = "select ramcod,      ",
                  "       succod,      ",
                  "       aplnumdig,   ",
                  "       itmnumdig    ",
                  "  from datrservapol ",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?"
 prepare sel_servapol from ws.sql
 declare c_servapol cursor for sel_servapol

let w_param = "Porto Socorro"
let w_pgto = 0
let w_sem_cls = 0

 declare  c_modelo     cursor for
    select datmservico.atdsrvnum  , datmservico.atdsrvano,
           datmservico.atdsrvorg  , datmservico.asitipcod,
           datmservico.atddat     , dbsmopg.socfatpgtdat ,
           dbsmopgitm.socopgitmvlr, datmservico.ciaempcod
      from dbsmopg, dbsmopgitm, datmservico
     where dbsmopg.socfatpgtdat   between ws_datade and ws_dataate
       and dbsmopg.socopgsitcod   =   7
       and dbsmopgitm.socopgnum   = dbsmopg.socopgnum
       and datmservico.atdsrvnum  = dbsmopgitm.atdsrvnum #Nro servico
       and datmservico.atdsrvano  = dbsmopgitm.atdsrvano #Ano servico

 foreach c_modelo  into ws.atdsrvnum   , ws.atdsrvano,
                        ws.atdsrvorg   , ws.asitipcod,
                        ws.atddat      , ws.socfatpgtdat,
                        ws.socopgitmvlr, ws.ciaempcod

    if ws.ciaempcod = 35  or
       ws.ciaempcod = 40  or
       ws.ciaempcod = 43  or 
       ws.ciaempcod = 27  then # PSI 247936 Empresas 27
       continue foreach
    end if

    #------------------------------------------------------------
    # Verifica tipo do servico
    #------------------------------------------------------------
    if ws.atdsrvorg <> 1  and     #Porto Socorro
       ws.atdsrvorg <> 2  and     #Transporte
       ws.atdsrvorg <> 4  and     #Remocoes
       ws.atdsrvorg <> 5  and     #RPT
       ws.atdsrvorg <> 6  and     #DAF
       ws.atdsrvorg <> 7  and     #Replace
       ws.atdsrvorg <> 8  then    #Carro Extra
       continue foreach
    end if
    if ws.atdsrvorg = 2   and     #Transporte taxi
       ws.asitipcod <> 5  then
       continue foreach
    end if

    #------------------------------------------------------------------
    # Busca numero da apolice do servico
    #------------------------------------------------------------------
    initialize ws.ramcod   , ws.succod  ,
               ws.aplnumdig, ws.itmnumdig  to null
    open  c_servapol  using  ws.atdsrvnum, ws.atdsrvano
    fetch c_servapol  into   ws.ramcod   , ws.succod   ,
                             ws.aplnumdig, ws.itmnumdig
       if  ws.ramcod =  78 or
           ws.ramcod = 171 or
           ws.ramcod = 195 then
           continue foreach
       end if
    close c_servapol

    let g_reg.anomes = arr_aux
    let g_reg.orrdat = ws.atddat
    let g_reg.pgtdat = ws.socfatpgtdat
   #let g_reg.ramcod = 31
    let g_reg.ramcod = ws.ramcod
    let g_reg.total  = ws.socopgitmvlr

    call grava_psoc()

 end foreach

end function

#-------------------------------
function vidros()
#-------------------------------
open c_adimvdrrpr using ws_datade,ws_dataate
while  true
   fetch c_adimvdrrpr into r_reg.pgtdat,
                           r_reg.vlrtotal,
                           w_vcllicnum,
                           w_vclchsfnl,
                           w_vdrrprnum
   if  status = notfound then
       exit while
   end if

   let g_reg.anomes = arr_aux
   let g_reg.orrdat = r_reg.pgtdat
   let g_reg.pgtdat = r_reg.pgtdat
  #let g_reg.ramcod = 31
   let g_reg.ramcod = 531
   let g_reg.total  = r_reg.vlrtotal

   call grava_psoc()
end while

end function

#--------------------------------------------#
function grava_psoc()
#--------------------------------------------#
    select anomes
      from work:pgtos_psoc
     where anomes    = g_reg.anomes
       and orrdat    = g_reg.orrdat
       and pgtdat    = g_reg.pgtdat

    if sqlca.sqlcode = notfound then
       insert into work:pgtos_psoc values (g_reg.*)
    else
       update work:pgtos_psoc set total = total + g_reg.total
        where anomes    = g_reg.anomes
          and orrdat    = g_reg.orrdat
          and pgtdat    = g_reg.pgtdat
    end if

end function  # grava_psoc()

