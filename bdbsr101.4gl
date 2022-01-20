###############################################################################
# Nome do Modulo: bdbsr101 - antigo BAEXTPGT                       Wagner     #
#                 Programa de valores de sinistros pagos para as clausulas    #
#                 071, 034 e 035                     Cristina - 21/09/01      #
#                                                                  Abr/2002   #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 09/12/2002  PSI 166111   Wagner       Incluir RE, aviao, ambulancia,        #
#                                       translado, rodoviario                 #
#-----------------------------------------------------------------------------#
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                          #
###############################################################################
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 28/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#-----------------------------------------------------------------------------#
# 16/11/2006 Alberto Rodrigues    205206  implementado leitura campo ciaempcod#
#                                        para desprezar qdo for Azul Segur.   #
#-----------------------------------------------------------------------------#
# 04/06/2007 Cristiane Silva    PSI207373 Atendimento clausulas 33,34,94      #
###############################################################################

database porto

  define w_comando  char(2000)

  define r_reg        record
         succod       like abamdoc.succod,
         aplnumdig    like abamdoc.aplnumdig,
         edsnumdig    like abamdoc.edsnumdig,
         itmnumdig    like abbmitem.itmnumdig,
         dctnumseq    like abbmclaus.dctnumseq,
         segnumdig    integer,
         cbtcod       like abbmcasco.cbtcod,
         modvclcoddig like agbkveic.modvclcoddig,
         vclanomdl    like abbmveic.vclanomdl,
         vclcoddig    like abbmveic.vclcoddig,
         ctgtrfcod    like abbmcasco.ctgtrfcod,
         clalclcod    like abbmdoc.clalclcod,
         vlrtotal     decimal(15,5) ,
         pgtdat       date,
         sexo         char(01),
         data_nasc    char(10),
         rnvsuccod    like abbmitem.rnvsuccod,
         rnvaplnum    like abbmitem.rnvaplnum,
         rnvitmnum    like abbmitem.rnvitmnum,
         sinano       char(4),
         sinnum       integer
  end record

  define w_vcllicnum      like adimvdrrpr.vcllicnum,
         w_vclchsfnl      like adimvdrrpr.vclchsfnl,
         w_caddat         like adimvdrrpr.caddat,
         w_vdrrprnum      like adimvdrrpr.vdrrprnum,
         w_pestip         char(1),
         w_ctgtrfcod_cia  like abbmcasco.ctgtrfcod,
         w_ctgtrfcod      like abbmcasco.ctgtrfcod,
         w_viginc         like abbmitem.viginc,
         w_vigfnl         like abbmitem.vigfnl,
         ws_aplnumdig     like abamdoc.aplnumdig,
         ws_count         integer,
         ws_emsdat        date,
         w_grlinf         like igbkgeral.grlinf,
         w_pgto           decimal(20,5),
         w_sem_cls        decimal(20,5),
         w_param          char(15),
         ws_datade        date,
         ws_dataate       date,
         ws_aux_dat       char(10),
         ws_run           char(400),
         ws_nometxt       char(50),
         ws_pestip_cia    like gsakseg.pestip,
         ws_segsex_cia    like gsakseg.segsex,
         ws_nscdat_cia    char(10),
         ws_clalclcod_cia like abbmdoc.clalclcod

  define m_path char(100)

main

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr101.log"

    call startlog(m_path)
    # PSI 185035 - Final

   call bdbsr101()
end main

#---------------------------------------------------------------
 function bdbsr101()
#---------------------------------------------------------------

 define l_retorno  smallint

 #----------------
 #Cria tabela work
 #----------------
 database work

 whenever error continue
    drop table work:auto_pgtos
   #delete from work:auto_pgtos
 whenever error stop

 create table work:auto_pgtos
       (empcod       dec(2,0) ,
        succod       dec(2,0) ,
        ramcod       dec(4,0) ,
        sinano       char(4)  ,
        sinnum       dec(9,0) ,
        aplnumdig    dec(9,0) ,
        itmnumdig    dec(7,0) ,
        sinmvtcod    smallint ,
        pgtdat       date     ,
        sinciavlr    dec(15,5),
        cosseguro    dec(15,5),
        resseguro    dec(15,5),
        total        dec(15,5))

#whenever error stop

#if sqlca.sqlcode <> 0 then
#   display  'ERRO - CREATE BAYARRI, st.: ', sqlca.sqlcode
#   sleep 2
#   whenever error continue
#   drop table work:auto_pgtos
#   delete from work:auto_pgtos
#   whenever error stop
#end if

#whenever error continue
   create index auto_pgtos_idx on auto_pgtos
           (succod, aplnumdig, itmnumdig, sinano, sinnum)
   create index auto_pgtos_dta on auto_pgtos (pgtdat)
#whenever error stop

  close database
  database porto

  call fun_dba_abre_banco("CT24HS")

  set isolation to dirty read

 #-----------------------------------------------------
 # Data para execucao
 #-----------------------------------------------------
 let ws_aux_dat = arg_val(1)

 if ws_aux_dat is null  or
    ws_aux_dat =  "  "  then
    let ws_aux_dat = today
 else
    if length(ws_aux_dat) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws_aux_dat = "01","/", ws_aux_dat[4,5],"/", ws_aux_dat[7,10]
 let ws_dataate = ws_aux_dat
 let ws_dataate = ws_dataate - 1 units day
 let ws_aux_dat = ws_dataate
 let ws_aux_dat = "01","/", ws_aux_dat[4,5],"/", ws_aux_dat[7,10]
 let ws_datade  = ws_aux_dat

 call bdbsr101_prepares()
 call beaig105_prepare()
 call bdbsr101a()
 call vidros()

 display  "Total Atendimento Sem clausula ",  w_sem_cls
 display  "Total pagamento   Sem apolice  ",  w_pgto

 #---------------------------
 # Envia arquivo de OK!
 #---------------------------

     # PSI 185035 - Inicio
    let m_path = f_path("DBS","ARQUIVO")
    if m_path is null then
       let m_path = "."
    end if
    # PSI 185035 - Final

 let ws_nometxt = m_path clipped,"/bdbsr101.txt"

 let ws_run = "echo 'Carga desempenho por corretor de ", ws_datade ,
              " a ", ws_dataate, " concluida! ",ascii(13),"' > ",
              ws_nometxt clipped
 run ws_run

 let ws_run = "Carga desempenho corretor"
 let l_retorno = ctx22g00_envia_email("BDBSR101",
                                     ws_run,
                                     ws_nometxt)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display "Erro ao enviar email(ctx22g00) - ",ws_nometxt
    else
       display "Nao existe email cadastrado para este modulo - BDBSR101"
    end if
 end if

 #let ws_run = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
 #             " -s 'Carga desempenho corretor' ",
 #             "ruiz_carlos/spaulo_info_sistemas@u55 < ",
 #             ws_nometxt clipped
 #run ws_run
 #
 #let ws_run = "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
 #             " -s 'Carga desempenho corretor' ",
 #             "roveri_alcione/spaulo_info_sistemas@u55 < ",
 #             ws_nometxt clipped
 #run ws_run

 let ws_run =  "rm ", ws_nometxt clipped
 run ws_run

end function # -- bdbsr101


#-----------------------------------------------------------
 function bdbsr101_prepares()
#-----------------------------------------------------------

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
                 "    and clscod in ('034','035','34A','35A','35R','033','33R') " ## PSI207373
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

 let w_comando = " select cbtcod ",
                 "   from abbmcasco ",
                 "  where succod    = ? ",
                 "    and aplnumdig = ? ",
                 "    and itmnumdig = ? ",
                 "    and dctnumseq = ? "
 prepare p_abbmcasco from w_comando
 declare c_abbmcasco cursor for p_abbmcasco

 let w_comando = "update igbkgeral ",
                 "set grlinf = ? ",
                 "where  mducod = 'BQG' and grlchv = 'BAQGA097' "
 prepare p_up_igbk from w_comando

 let w_comando = " insert into work:auto_pgtos (",
                              " empcod   , ",  # Codigo da Empresa
                              " succod   , ",  # (Succod + Aplnumdig em APOLICE)
                              " ramcod   , ",  # Ramo            -(p/ pesquisa)
                              " sinano   , ",  # Ano do Sinistro -(p/ pesquisa)
                              " sinnum   , ",  # Num do Sinistro -(p/ pesquisa)
                              " aplnumdig, ",  # (Succod + Aplnumdig em APOLICE)
                              " itmnumdig, ",  # Item
                              " sinmvtcod, ",  # CAUSA
                              " pgtdat   , ",  # DT. OCORRENCIA
                              " sinciavlr, ",  # IND. OUTROS (DESPESAS)
                              " cosseguro, ",  #
                              " resseguro, ",  #
                              " total    ) ",  # IND. OUTROS (DESPESAS)
                              " values (1,?,31,?,?,?,?,9,?,?,' ',' ',?) "
 prepare p_insert from w_comando

end function  #--- bdbsr101_prepares


#-----------------------------------------------------------
 function bdbsr101a()
#-----------------------------------------------------------
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
    select datmservico.atdsrvnum, datmservico.atdsrvano,
           datmservico.atdsrvorg, datmservico.asitipcod,
           dbsmopg.socfatpgtdat , dbsmopgitm.socopgitmvlr,
           datmservico.ciaempcod
      from dbsmopg, dbsmopgitm, datmservico
     where dbsmopg.socfatpgtdat   between ws_datade and ws_dataate
       and dbsmopg.socopgsitcod   =   7
       and dbsmopgitm.socopgnum   = dbsmopg.socopgnum
       and datmservico.atdsrvnum  = dbsmopgitm.atdsrvnum #Nro servico
       and datmservico.atdsrvano  = dbsmopgitm.atdsrvano #Ano servico

 foreach c_modelo  into ws.atdsrvnum, ws.atdsrvano,
                        ws.atdsrvorg, ws.asitipcod,
                        ws.atddat   , ws.socopgitmvlr,
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
       ws.atdsrvorg <>17  and     #Replace congenere
       ws.atdsrvorg <> 8  and     #Carro Extra
       ws.atdsrvorg <> 9  then    #RE
       continue foreach
    end if
    if ws.atdsrvorg = 2      then  ##Transporte
       if ws.asitipcod =  5  or    ## TAXI
          ws.asitipcod = 10  or    ## AVIAO
          ws.asitipcod = 11  or    ## AMBULANCIA
          ws.asitipcod = 12  or    ## TRANSLADO
          ws.asitipcod = 16  then  ## RODOVIARIO
          # TIPOS DE ASSISTENCIA OK
       else
          continue foreach
       end if
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
                   r_reg.pgtdat,
                   r_reg.sexo,
                   r_reg.data_nasc,
                   r_reg.rnvsuccod,
                   r_reg.rnvaplnum,
                   r_reg.rnvitmnum,
                   r_reg.sinnum ,
                   r_reg.sinano to null

    let  r_reg.succod    = ws.succod
    let  r_reg.aplnumdig = ws.aplnumdig
    let  r_reg.itmnumdig = ws.itmnumdig
    let  r_reg.vlrtotal  = ws.socopgitmvlr
    let  r_reg.pgtdat    = ws.atddat # tem que ser a data do pgto
    let  r_reg.sinnum    = ws.atdsrvnum
    let  r_reg.sinano    = ws.atdsrvano
    open  c_abamapol  using  r_reg.succod,r_reg.aplnumdig
    fetch c_abamapol into    w_vigfnl
    if    w_vigfnl >= r_reg.pgtdat then
          call continua()
    end   if

 end foreach

end function   #--- bdbsr101a()

#--------------------------------------------------
 function vidros()
#--------------------------------------------------
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
           if    w_vigfnl >= r_reg.pgtdat then
                 let  r_reg.sinnum    = w_vdrrprnum
                 let  ws_aux_dat      = r_reg.pgtdat
                 let  r_reg.sinano    = ws_aux_dat[7,10]
                 call continua()
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
           if    w_vigfnl >= r_reg.pgtdat then
                 let  r_reg.sinnum    = w_vdrrprnum
                 let  ws_aux_dat      = r_reg.pgtdat
                 let  r_reg.sinano    = ws_aux_dat[7,10]
                 call continua()
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
                     r_reg.pgtdat,
                     r_reg.sexo,
                     r_reg.data_nasc,
                     r_reg.rnvsuccod,
                     r_reg.rnvaplnum,
                     r_reg.rnvitmnum,
                     r_reg.sinnum   ,
                     r_reg.sinano  to null

end while
end function   #--  VIDROS

#-------------------------------------------
 function continua()
#-------------------------------------------

     open c_abbmitem using r_reg.succod,
                           r_reg.aplnumdig,
                           r_reg.itmnumdig
     while true
     fetch   c_abbmitem #into r_reg.rnvsuccod
                           # r_reg.rnvaplnum,
                           # r_reg.rnvitmnum
     #                       w_viginc
     if  status <> notfound  then
         if  w_param = "Porto Socorro"  then
             call bdbsr101_claus034()
         else
             call bdbsr101_claus071()
         end if
     else
        exit while
     end if

     end while


end function  ##-- continua()


#-----------------------------------------------------------
 function bdbsr101_claus034()
#-----------------------------------------------------------

  open c_abbmclaus_034 using r_reg.succod,
                             r_reg.aplnumdig,
                             r_reg.itmnumdig
  fetch c_abbmclaus_034 into r_reg.dctnumseq
     if status <> notfound then
        call bdbsr101_grava()
    else
        let  w_sem_cls = w_sem_cls + r_reg.vlrtotal
    end if

end function   ##-- bdbsr101_claus034


#-----------------------------------------------------------
 function bdbsr101_claus071()
#-----------------------------------------------------------

  open c_abbmclaus_071 using r_reg.succod,
                             r_reg.aplnumdig,
                             r_reg.itmnumdig
  fetch c_abbmclaus_071 into r_reg.dctnumseq

     if  status <> notfound  then
         call bdbsr101_grava()
     end if

end function  ##-- bdbsr101_claus071


#-----------------------------------------------------------
 function bdbsr101_grava()
#-----------------------------------------------------------

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

   # Acesso a COBERTUTA - ABBMCASCO
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
#   display "vlrtotal/pgtdat/sexo  = ", r_reg.vlrtotal, " ",
#                                     r_reg.pgtdat, " ",
#                                     r_reg.sexo, " "

#   display "r_reg.data_nasc = ", r_reg.data_nasc
#   display "r_reg.rnvsuccod = ", r_reg.rnvsuccod
#   display "r_reg.rnvaplnum = ", r_reg.rnvaplnum
#   display "r_reg.rnvitmnum = ", r_reg.rnvitmnum


 #--------------------------------------------#
 # Inserindo dados na tabela work:auto_pgtos
 #--------------------------------------------#

    select succod from work:auto_pgtos
    where succod    = r_reg.succod
      and aplnumdig = r_reg.aplnumdig
      and itmnumdig = r_reg.itmnumdig
      and sinano    = r_reg.sinano
      and sinnum    = r_reg.sinnum

    if sqlca.sqlcode <> 0 then
       execute p_insert using
                              r_reg.succod        ,
                              r_reg.sinano        ,
                              r_reg.sinnum        ,
                              r_reg.aplnumdig     ,
                              r_reg.itmnumdig     ,
                              r_reg.pgtdat        ,
                              r_reg.vlrtotal      ,
                              r_reg.vlrtotal

         if sqlca.sqlcode = 0 then                    # OK p/tabela auto_pgtos
            let w_grlinf = ws_emsdat, " " clipped, r_reg.succod,
                           " " clipped, r_reg.aplnumdig
            execute p_up_igbk using w_grlinf
            let w_grlinf = " "
         end if
   end if

end function  #-- bdbsr101_grava

