##############################################################################
#  Programa : bdbsa014                                                       #
#             Atualiza valores susep135 (ATUAL CIRCULAR 135)                 #
#  Programa de valores de sinistros pagos para as clausulas 071, 034 e035    #
#                                                     Cristina - 21/09/01    #
##############################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# 16/11/2006 Alberto Rodrigues   205206  implementado leitura campo ciaempcod #
#                                        para desprezar qdo for Azul Segur.   #
# 04/06/2007 Cristiane Silva PSI207373   Atendimento clausulas 33, 34, 94     #
###############################################################################

database porto

define w_comando  char(2000)

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
       vlrtotal      dec(14,02) ,
       ultdat        date,
       sexo          char(01),
       data_nasc     char(10),
       rnvsuccod     like abbmitem.rnvsuccod,
       rnvaplnum     like abbmitem.rnvaplnum,
       rnvitmnum     like abbmitem.rnvitmnum,
       endcep        like gsakend.endcep,
       endcepcmp     like gsakend.endcepcmp
end record

define w_vcllicnum       like adimvdrrpr.vcllicnum
define w_vclchsfnl       like adimvdrrpr.vclchsfnl
define w_caddat          like adimvdrrpr.caddat
define w_pestip          char(1)
define w_ctgtrfcod_cia   like abbmcasco.ctgtrfcod
define w_ctgtrfcod       like abbmcasco.ctgtrfcod
define w_viginc          like abbmitem.viginc
define w_vigfnl          like abbmitem.vigfnl
define ws_aplnumdig      like abamdoc.aplnumdig
define ws_count          integer
define w_grlinf          like igbkgeral.grlinf
define w_pgto            dec (20,5)
define w_sem_cls         dec (20,5)
define w_param           char(15)
define ws_datade         date
define ws_dataate        date
define ws_d_ocorr        date
define ws_ultalt         char(10)
define ws_pestip_cia     like gsakseg.pestip,
       ws_segsex_cia     like gsakseg.segsex,
       ws_nscdat_cia     char(10),
       ws_clalclcod_cia  like abbmdoc.clalclcod

define ws_dtchar         char (10)
define ws_mes            smallint
define ws_ano            smallint
define ws_anomes         integer
define ws_anomes2        char (07)
define ws_sinano         char (04)
define ws_sinnum         integer

define m_path            char(100)

main

    call fun_dba_abre_banco("CT24HS")

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsa014.log"

    call startlog(m_path)
    # PSI 185035 - Final

  #------------------------------
  # Verifica paramentro IGBKGERAL
  #------------------------------
  select grlinf
    into w_grlinf
    from igbkgeral
   where mducod = "CT"
     and grlchv = "CIR-135"

  let ws_anomes2 = w_grlinf[01,07]     # anomes referencia
  let ws_sinano  = w_grlinf[01,04]     # sinistro ano
  let ws_dtchar  = w_grlinf[09,18]
  let ws_datade  = ws_dtchar           # data inicial
  let ws_dtchar  = w_grlinf[20,29]
  let ws_dataate = ws_dtchar           # data final


  let ws_ultalt  = today
  call bdbsa014_prepares()
  call beaig105_prepare()

  display  "======> CARGA P.SOCORRO "
  call bdbsa014()

  display  "======> CARGA VIDROS "
  call vidros()

  display  "Total Atendimento Sem clausula ",  w_sem_cls
  display  "Total pagamento   Sem apolice  ",  w_pgto
end main


##-----------------------------------------------------------
function bdbsa014_prepares()
##-----------------------------------------------------------
  let w_comando = " select itmnumdig, rnvsuccod, ",
                  "        rnvaplnum, rnvitmnum, viginc ",
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
                  "    and clscod in ('034','035','34A','35A','35R','033','33R','34B','34C') " ## PSI207373
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

  let w_comando = " select vdrrprpgtdat,vdrrprvlr,vcllicnum,vclchsfnl  ",
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

  let w_comando = " insert into work@u15:susep135 (",
    " anomes      , ",        # Ano/Mes Referencia -(p/ pesquisa)
    " ramcod      , ",        # Ramo            -(p/ pesquisa)
    " subcod      , ",        # subcod          -(p/ pesquisa)
    " sinano      , ",        # Ano do Sinistro -(p/ pesquisa)
    " sinnum      , ",        # Num do Sinistro -(p/ pesquisa)
    " itmnumdig   , ",        # 4. Item
    " succod      , ",        # 2. (Succod + Aplnumdig em APOLICE)
    " aplnumdig   , ",        # 2. (Succod + Aplnumdig em APOLICE)
    " segcod      , ",        # 1. Codigo da SEGURADORA Fixo: 05886
    " edsnumref   , ",        # 3. ENDOSSO
    " cbtcod      , ",        # 5. COBERTURA
    " modvclcoddig, ",        # 6. MODELO do VEICULO
    " vclanomdl   , ",        # 7. ANO-MODELO VEICULO
    " ctgtrfcod   , ",        # 8. CATEGORIA TARIFARIA
    " clalclcod   , ",        # 9. LOCAL DE RISCO
    " ind_outros  , ",        # 14. IND. OUTROS (DESPESAS)
    " d_ocorr     , ",        # 25. DT. OCORRENCIA
    " sinntzcod   , ",        # 26. CAUSA
    " sexo        , ",        # 27. SEXO DO SEGURADO
    " data_nasc   , ",        # 28. DT. NASCIMENTO SEGURADO
    " rnvsuccod   , ",        #     Sucursal Renovacao
    " rnvaplnum   , ",        #     Apolice  Renovacao
    " rnvitmnum   , ",        #     Item     Renovacao
    " endcep      , ",        #     Cep
    " endcepcmp   ) ",        #     Cep complemento
    " values (?,31,0,?,0,?,?,?,'05886',?,?,?,?,?,?,?,?,9,?,?,?,?,?,?,? ) "
  prepare p_insert from w_comando

end function #------Fim dos Prepares--------


##-----------------------------------------------------------
function bdbsa014()
##-----------------------------------------------------------
 define ws         record
    atdsrvnum      like datmservico.atdsrvnum  ,  # Nro.servico
    atdsrvano      like datmservico.atdsrvano  ,  # Ano servico
    atdsrvorg      like datmservico.atdsrvorg  ,  # Origem servico
    asitipcod      like datmservico.asitipcod  ,  # Tipo assistencia
    socfatpgtdat   like dbsmopg.socfatpgtdat   ,  # Data atendimento
    socopgitmvlr   like dbsmopgitm.socopgitmvlr,  # Valor pago
    ramcod         like datrservapol.ramcod    ,  # Ramo
    succod         like datrservapol.succod    ,  # Sucursal
    aplnumdig      like datrservapol.aplnumdig ,  # Apolice
    itmnumdig      like datrservapol.itmnumdig ,  # Item
    ciaempcod      like datmservico.ciaempcod  ,  # Azul
    sql            char (300)                     # Sql
 end record

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
#---------------------------------------------------------------
# Cursor principal PAGOS
#---------------------------------------------------------------
 declare  c_modelo     cursor for
    select datmservico.atdsrvnum, datmservico.atdsrvano,
           datmservico.atdsrvorg, datmservico.asitipcod,
           dbsmopg.socfatpgtdat , dbsmopgitm.socopgitmvlr,
           datmservico.ciaempcod
      from dbsmopg, dbsmopgitm, datmservico
     where dbsmopg.socfatpgtdat   between ws_datade and ws_dataate
       and dbsmopg.pstcoddig      <> 0
       and dbsmopg.socopgsitcod   =  7
       and dbsmopgitm.socopgnum   = dbsmopg.socopgnum
       and datmservico.atdsrvnum  = dbsmopgitm.atdsrvnum #Nro servico
       and datmservico.atdsrvano  = dbsmopgitm.atdsrvano #Ano servico
     order by dbsmopg.socfatpgtdat

 foreach c_modelo  into ws.atdsrvnum, ws.atdsrvano,
                        ws.atdsrvorg, ws.asitipcod,
                        ws.socfatpgtdat , ws.socopgitmvlr,
                        ws.ciaempcod

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
       ws.atdsrvorg <> 17 and     #Replace congenere
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
       if ws.aplnumdig is null and
          ws.itmnumdig is null then
          let w_pgto = w_pgto + ws.socopgitmvlr
          continue foreach
       end if
    close c_servapol
    initialize     r_reg.edsnumdig,
                   r_reg.itmnumdig,
                   r_reg.dctnumseq,
                   r_reg.segnumdig,
                   r_reg.cbtcod,
                   r_reg.modvclcoddig,
                   r_reg.vclanomdl,
                   r_reg.vclcoddig,
                   r_reg.ctgtrfcod,
                   r_reg.clalclcod,
                   r_reg.vlrtotal ,
                   r_reg.ultdat,
                   r_reg.sexo,
                   r_reg.data_nasc,
                   r_reg.rnvsuccod,
                   r_reg.rnvaplnum,
                   r_reg.rnvitmnum to null

    let  r_reg.succod    = ws.succod
    let  r_reg.aplnumdig = ws.aplnumdig
    let  r_reg.itmnumdig = ws.itmnumdig
    let  r_reg.vlrtotal  = ws.socopgitmvlr
    let  r_reg.ultdat    = ws.socfatpgtdat
    call continua()
 end foreach

end function

function vidros()
open c_adimvdrrpr using ws_datade,ws_dataate
while  true
fetch c_adimvdrrpr into r_reg.ultdat,
                        r_reg.vlrtotal,
                        w_vcllicnum,
                        w_vclchsfnl
if  status = notfound then
    exit while
end if

if   w_vcllicnum > " "  then
     open  c_abbmveic_l using w_vcllicnum
     while true
           fetch c_abbmveic_l into  r_reg.succod,
                                    r_reg.aplnumdig,
                                    r_reg.itmnumdig,
                                    r_reg.dctnumseq
           if  status = notfound  then
               exit while
           end if
           open  c_abamapol  using  r_reg.succod,r_reg.aplnumdig
           fetch c_abamapol into    w_vigfnl
           if    w_vigfnl >= r_reg.ultdat then
                 call  continua()
                 exit while
           end   if
     end while
else
     open  c_abbmveic_c using w_vclchsfnl
     while true
           fetch c_abbmveic_c into  r_reg.succod,
                                    r_reg.aplnumdig,
                                    r_reg.itmnumdig,
                                    r_reg.dctnumseq
           if  status = notfound  then
               exit while
           end if
           open  c_abamapol  using  r_reg.succod,r_reg.aplnumdig
           fetch c_abamapol into    w_vigfnl
           if    w_vigfnl >= r_reg.ultdat then
                 call  continua()
                 exit while
           end   if
     end while
end if
initialize           r_reg.edsnumdig,
                     r_reg.itmnumdig,
                     r_reg.dctnumseq,
                     r_reg.segnumdig,
                     r_reg.cbtcod,
                     r_reg.modvclcoddig,
                     r_reg.vclanomdl,
                     r_reg.vclcoddig,
                     r_reg.ctgtrfcod,
                     r_reg.clalclcod,
                     r_reg.vlrtotal ,
                     r_reg.ultdat,
                     r_reg.sexo,
                     r_reg.data_nasc,
                     r_reg.rnvsuccod,
                     r_reg.rnvaplnum,
                     r_reg.rnvitmnum to null

end while
end function

function continua()

     open c_abbmitem using r_reg.succod,
                           r_reg.aplnumdig,
                           r_reg.itmnumdig
     while true
     fetch   c_abbmitem into r_reg.itmnumdig,
                             r_reg.rnvsuccod,
                             r_reg.rnvaplnum,
                             r_reg.rnvitmnum,
                             w_viginc
     if  status <> notfound  then
         if  w_param = "Porto Socorro"  then
             call bdbsa014_claus034()
         else
             call bdbsa014_claus071()
         end if
     else
        exit while
     end if

     end while

end function


##-----------------------------------------------------------
function bdbsa014_claus034()
##-----------------------------------------------------------

  open c_abbmclaus_034 using r_reg.succod,
                             r_reg.aplnumdig,
                             r_reg.itmnumdig
  fetch c_abbmclaus_034 into r_reg.dctnumseq
     if status <> notfound then
        call bdbsa014_grava()
    else
        let  w_sem_cls = w_sem_cls + r_reg.vlrtotal
    end if
end function



##-----------------------------------------------------------
function bdbsa014_claus071()
##-----------------------------------------------------------

  open c_abbmclaus_071 using r_reg.succod,
                             r_reg.aplnumdig,
                             r_reg.itmnumdig
  fetch c_abbmclaus_071 into r_reg.dctnumseq

     if  status <> notfound  then
         call bdbsa014_grava()
     end if

end function


##-----------------------------------------------------------
function bdbsa014_grava()
##-----------------------------------------------------------

     open c_abamdoc_eds using r_reg.succod,
                              r_reg.aplnumdig,
                              r_reg.dctnumseq
     fetch c_abamdoc_eds into r_reg.edsnumdig

   # Acesso ao Codigo do SEGURADO
    call beaig105_segnumdig(r_reg.succod,
                            r_reg.aplnumdig,
                            r_reg.itmnumdig,
                            r_reg.edsnumdig)
    returning r_reg.segnumdig

   # Acesso ao CEP do SEGURADO
    call beaig105_cep_segurado(r_reg.succod,
                               r_reg.aplnumdig,
                               r_reg.itmnumdig)
    returning r_reg.endcep, r_reg.endcepcmp

   # Acesso a COBERTURA - ABBMCASCO
     open c_abbmcasco using r_reg.succod,
                            r_reg.aplnumdig,
                            r_reg.itmnumdig,
                            r_reg.dctnumseq
     fetch c_abbmcasco into r_reg.cbtcod
     close c_abbmcasco

  # Pesquisa dados do veiculo : codigo, ano modelo       #
    call beaig105_vclcoddig(r_reg.succod,
                            r_reg.aplnumdig,
                            r_reg.itmnumdig,
                            r_reg.edsnumdig)
    returning r_reg.vclcoddig,
              r_reg.vclanomdl

  # Acesso a Classe de Localizacao - Regiao (9. LOCAL DE RISCO)
    call beaig105_cls_localizacao_auto(r_reg.succod,
                                       r_reg.aplnumdig,
                                       r_reg.itmnumdig,
                                       r_reg.edsnumdig)
    returning  ws_clalclcod_cia, r_reg.clalclcod

  # Acesso a pessoas, sexo e data nascimento - funcao Auto
  # Data Nascimento precisa inverter p/ aaaa/mm/dd
    call beaig105_cadastrais_auto(r_reg.segnumdig)
    returning ws_pestip_cia,
              ws_segsex_cia,
              ws_nscdat_cia,
              w_pestip,
              r_reg.sexo,
              r_reg.data_nasc

  # Categoria Tarifaria/Codigo ModeloVeiculo
    call beaig105_categoria_auto(w_viginc, r_reg.vclcoddig)
    returning w_ctgtrfcod_cia,
              r_reg.ctgtrfcod,
              r_reg.modvclcoddig

#   display "suc/apol/item/endosso/dct = ", r_reg.succod," ",r_reg.aplnumdig,
#                                        " ", r_reg.itmnumdig,
#                                        " ", r_reg.edsnumdig,
#                                        " ", r_reg.dctnumseq
#   display "r_reg.segnumdig = ", r_reg.segnumdig
#   display "cbtcod/codveic/anomod = ", r_reg.cbtcod, " ", r_reg.modvclcoddig
#                                      ," ", r_reg.vclanomdl
#   display "catgoria/classe = ",r_reg.ctgtrfcod," ",r_reg.clalclcod
#   display "vlrtotal/ultdat/sexo  = ", r_reg.vlrtotal, " ",
#                                     r_reg.ultdat, " ",
#                                     r_reg.sexo, " "

#   display "r_reg.data_nasc = ", r_reg.data_nasc
#   display "r_reg.rnvsuccod = ", r_reg.rnvsuccod
#   display "r_reg.rnvaplnum = ", r_reg.rnvaplnum
#   display "r_reg.rnvitmnum = ", r_reg.rnvitmnum


#-------------------------------------------#
# Inserindo dados na tabela work@u15:susep135   #
#---------------------------------------- --#
    execute p_insert using ws_anomes2        , ws_sinano         ,
                           r_reg.itmnumdig   , r_reg.succod      ,
                           r_reg.aplnumdig   , r_reg.edsnumdig   ,
                           r_reg.cbtcod      , r_reg.modvclcoddig,
                           r_reg.vclanomdl   , r_reg.ctgtrfcod   ,
                           r_reg.clalclcod   , r_reg.vlrtotal    ,
                           r_reg.ultdat      , r_reg.sexo        ,
                           r_reg.data_nasc   , r_reg.rnvsuccod   ,
                           r_reg.rnvaplnum   , r_reg.rnvitmnum   ,
                           r_reg.endcep      , r_reg.endcepcmp

    if sqlca.sqlcode = 0 then                    # OK p/tabela susep135
       let w_grlinf = " "
       let w_grlinf = r_reg.ultdat, " " clipped, r_reg.succod,
                      " " clipped, r_reg.aplnumdig
#      execute p_up_igbk using w_grlinf, ws_ultalt
       let w_grlinf = " "
    end if


#  if sqlca.sqlcode = 0 then                    # OK p/tabela susep135
#      display "Inclusao OK na tabela susep135 "
#      commit work@u15
#  e  else
#      display "Erro inserindo susep135 - Status: ", sqlca.sqlcode
#      rollback work@u15
#   end if

end function

