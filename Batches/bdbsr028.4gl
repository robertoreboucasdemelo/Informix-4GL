###############################################################################
# Nome do Modulo: bdbsr028                                         Marcelo    #
#                                                                  Gilberto   #
# Relacao mensal de reservas pagas                                 Set/1996   #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 11/09/2001 PSI 13552-6   Wagner       Mudanca total na estrutura do prg.    #
#-----------------------------------------------------------------------------#
# 01/10/2002  Correio      Wagner       Troca de e-mail Francisco Castro p/   #
#                                       Roberto Costa.                        #
#-----------------------------------------------------------------------------#
# 05/02/2003               Raji         Inclusco do campo Apolice no corpo    #
#                                       do relatorio.                         #
############################################################################  #
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ----------------------------------- #
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
# ----------------------------------------------------------------------------#
# 12/04/2005 Adriana, Meta     PSI191167  Unificacao do acesso as tabelas de  #
#                                         centro de custos                    #
# ----------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
# ---------- --------------------- ------ ------------------------------------#
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#-----------------------------------------------------------------------------#
# 18/07/06   Junior, Meta       AS112372  Migracao de versao do 4gl.          #
#-----------------------------------------------------------------------------#
# 08/05/2015 Fornax, RCP        080515    Incluir coluna data no relatorio.   #
#-----------------------------------------------------------------------------#
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
#-----------------------------------------------------------------------------#

database porto


 define d_bdbsr028    record
    atdsrvnum         like dbsmopgitm.atdsrvnum   ,
    atdsrvano         like dbsmopgitm.atdsrvano   ,
    apolice           char(20)                    ,
    c24pagdiaqtd      like dbsmopgitm.c24pagdiaqtd,
    slcsuccod         like datmavisrent.slcsuccod ,
    slccctcod         like datmavisrent.slccctcod ,
    cctnom            like ctokcentrosuc.cctnom   ,
    lcvnom            like datklocadora.lcvnom    ,
    lcvextcod         like datkavislocal.lcvextcod,
    c24solnom         like datmservico.c24solnom  ,
    avilocnom         like datmavisrent.avilocnom ,
    aviretdat         like datmavisrent.aviretdat ,
    entrega           like datmavisrent.aviretdat ,
    socopgitmvlr      like dbsmopgitm.socopgitmvlr,
    socfatpgtdat      like dbsmopg.socfatpgtdat #--> Fx-080515
 end record

 define ws_datade     date
 define ws_dataate    date
 define ws_flgcab     smallint
 define sql_comando   char(500)

 main
    call fun_dba_abre_banco("CT24HS")
    call bdbsr028()
 end main

#---------------------------------------------------------------
 function bdbsr028()
#---------------------------------------------------------------

 define ws            record
    datchr            char (10),
    c24utidiaqtd      like dbsmopgitm.c24utidiaqtd ,
    lcvcod            like datmavisrent.lcvcod     ,
    aviestcod         like datmavisrent.aviestcod  ,
    avialgmtv         like datmavisrent.avialgmtv  ,
    aviprvent         like datmavisrent.aviprvent  ,
    dirfisnom         like ibpkdirlog.dirfisnom    ,
    pathrel01         char (60)                    ,
    pathrel01_txt     char (60)                    , #--> RELTXT
    aviprodiaqtd      like datmprorrog.aviprodiaqtd,
    aviprodiaqtd_pro  like datmprorrog.aviprodiaqtd,
    cctempcod         like datmprorrog.cctempcod   ,
    socopgitmvlr_pro  like dbsmopgitm.socopgitmvlr ,
    saldo             like dbsmopgitm.c24utidiaqtd ,
    rsrincdat         like dbsmopgitm.rsrincdat    ,
    rsrfnldat         like dbsmopgitm.rsrfnldat    ,
    executa           char (400)
 end record

  define lr_param     record
         empcod       like ctgklcl.empcod,         ## Empresa
         succod       like ctgklcl.succod,         ## Sucursal
         cctlclcod    like ctgklcl.cctlclcod,      ## Local
         cctdptcod    like ctgrlcldpt.cctdptcod    ## Departamento
 end record

 define lr_ret record
        erro          smallint, ## 0-Ok,1-erro
        mens          char(40),
        cctlclnom     like ctgklcl.cctlclnom,       ## Nome do local
        cctdptnom     like ctgkdpt.cctdptnom,       ## Nome do departamento (antigo cctnom)
        cctdptrspnom  like ctgrlcldpt.cctdptrspnom, ## Responsavel pelo  departamento
        cctdptlclsit  like ctgrlcldpt.cctdptlclsit, ## Situagco do depto (A)tivo ou (I)nativo
        cctdpttip     like ctgkdpt.cctdpttip        ## Tipo de departamento
 end record


 define l_retorno     smallint                                # Marcio Meta - PSI185035

  define l_dataarq char(8)
  define l_data    date

  let l_data = today
  display "l_data: ", l_data
  let l_dataarq = extend(l_data, year to year),
                  extend(l_data, month to month),
                  extend(l_data, day to day)
  display "l_dataarq: ", l_dataarq



 initialize d_bdbsr028.*  to null
 initialize ws.*          to null
 let ws_flgcab = 0

#---------------------------------------------------------------
# Criacao de tabelas temporarias
#---------------------------------------------------------------

 create temp table t_ccusto (atdsrvnum    decimal(10,0),
                             atdsrvano    decimal(2,0),
                             apolice      char(20),
                             c24pagdiaqtd integer,
                             slcsuccod    decimal(2,0),
                             slccctcod    integer,
                             cctnom       char(40),
                             lcvnom       char(40),
                             lcvextcod    char(07),
                             c24solnom    char(15),
                             avilocnom    char(40),
                             aviretdat    date,
                             entrega      date,
                           # socopgitmvlr decimal (15,2))  with no log #--> FX-080515
                             socopgitmvlr decimal (15,2),              #--> FX-080515
                             socfatpgtdat date) with no log            #--> FX-080515

 if sqlca.sqlcode <> 0  then
    display "Erro (", sqlca.sqlcode using "<<<<<<", ") na criacao da tabela temporaria T_CCUSTO!"
    exit program (1)
 end if


#---------------------------------------------------------------
# Definicao do cursor LOCADORA
#---------------------------------------------------------------
 let sql_comando = " select lcvnom",
                   "   from datklocadora  " ,
                   "  where lcvcod = ?    "
 prepare select_loc  from sql_comando
 declare c_bdbsr028_loc  cursor for select_loc

#---------------------------------------------------------------
# Definicao do cursor LOJA
#---------------------------------------------------------------
 let sql_comando = " select lcvextcod ",
                   "   from datkavislocal ",
                   "  where lcvcod    = ? ",
                   "    and aviestcod = ? "
 prepare select_loj  from sql_comando
 declare c_bdbsr028_loj  cursor for select_loj

## Inibido PSI:191167
#---------------------------------------------------------------
# Definicao do cursor Departamento
#---------------------------------------------------------------
#let sql_comando = " select cctnom ",
#                  "  from ctokcentrosuc ",
#                  " where empcod = ? ",
#                  "   and succod = ? ",
#                  "   and cctcod = ? "
#prepare select_dep  from sql_comando
#declare c_bdbsr028_dep  cursor for select_dep
#

#---------------------------------------------------------------
# Definicao do cursor APOLICE
#---------------------------------------------------------------
 let sql_comando = " select succod || '-' || ",
                           "ramcod || '-' || ",
                           "aplnumdig || ' ' || ",
                           "itmnumdig" ,
                   "   from datrservapol  " ,
                   "  where atdsrvnum = ? " ,
                   "    and atdsrvano = ? "
 prepare select_apl  from sql_comando
 declare c_bdbsr028_apl  cursor for select_apl


#---------------------------------------------------------------
# Definicao do periodo mensal de extracao
#---------------------------------------------------------------
 let ws.datchr  = arg_val(1)

 if ws.datchr is null  or
    ws.datchr =  "  "  then
    let ws.datchr = today
 else
    if length(ws.datchr) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws.datchr  = "01"     ,"/", ws.datchr[4,5],"/", ws.datchr[7,10]
 let ws_dataate = ws.datchr
 let ws_dataate = ws_dataate - 1 units day

 let ws.datchr  = ws_dataate
 let ws.datchr  = "01"     ,"/", ws.datchr[4,5],"/", ws.datchr[7,10]
 let ws_datade  = ws.datchr
                                                          # Marcio Meta - PSI185035
 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DBS", "ARQUIVO")
   returning ws.dirfisnom

 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS02801", ws.datchr[4,5],".TXT"
 let ws.pathrel01_txt = ws.dirfisnom clipped, "/BDBSR028_", l_dataarq, ".txt"

                                                          # Marcio Meta - PSI185035
 #---------------------------------------------------------------
 # Definicao do cursor PRINCIPAL
 #---------------------------------------------------------------
 declare c_dbsmopg cursor for
  select dbsmopgitm.atdsrvnum   , dbsmopgitm.atdsrvano   ,
         dbsmopgitm.c24pagdiaqtd, datmavisrent.slcsuccod ,
         datmavisrent.slccctcod , datmavisrent.lcvcod    ,
         datmavisrent.aviestcod , datmservico.c24solnom  ,
         datmavisrent.avilocnom , datmavisrent.aviretdat ,
         dbsmopgitm.socopgitmvlr, datmavisrent.avialgmtv ,
         dbsmopgitm.c24utidiaqtd, datmavisrent.aviprvent ,
         dbsmopgitm.rsrincdat   , dbsmopgitm.rsrfnldat   ,
	 dbsmopg.socfatpgtdat #--> FX-080515
    from dbsmopg, dbsmopgitm, outer datmservico, outer datmavisrent
   where dbsmopg.socfatpgtdat between ws_datade and ws_dataate
     and dbsmopg.socopgsitcod   =   7
     and dbsmopg.soctip         =   2
     and dbsmopgitm.socopgnum   = dbsmopg.socopgnum
     and datmservico.atdsrvnum  = dbsmopgitm.atdsrvnum
     and datmservico.atdsrvano  = dbsmopgitm.atdsrvano
     and datmavisrent.atdsrvnum = dbsmopgitm.atdsrvnum
     and datmavisrent.atdsrvano = dbsmopgitm.atdsrvano

 foreach c_dbsmopg  into  d_bdbsr028.atdsrvnum   , d_bdbsr028.atdsrvano ,
                          d_bdbsr028.c24pagdiaqtd, d_bdbsr028.slcsuccod ,
                          d_bdbsr028.slccctcod   , ws.lcvcod            ,
                          ws.aviestcod           , d_bdbsr028.c24solnom ,
                          d_bdbsr028.avilocnom   , d_bdbsr028.aviretdat ,
                          d_bdbsr028.socopgitmvlr, ws.avialgmtv         ,
                          ws.c24utidiaqtd        , ws.aviprvent         ,
                          ws.rsrincdat           , ws.rsrfnldat         ,
			  d_bdbsr028.socfatpgtdat #--> FX-080515

     open  c_bdbsr028_loc using ws.lcvcod
     fetch c_bdbsr028_loc into  d_bdbsr028.lcvnom
     close c_bdbsr028_loc

     open  c_bdbsr028_loj using ws.lcvcod, ws.aviestcod
     fetch c_bdbsr028_loj into  d_bdbsr028.lcvextcod
     close c_bdbsr028_loj

     ## PSI:191167
#    let ws.cctempcod = 1
#    open  c_bdbsr028_dep using ws.cctempcod        ,
#                               d_bdbsr028.slcsuccod,
#                               d_bdbsr028.slccctcod
#    fetch c_bdbsr028_dep into  d_bdbsr028.cctnom
#    close c_bdbsr028_dep

     let ws.cctempcod       = 1
     let lr_param.empcod    = ws.cctempcod
     let lr_param.succod    = d_bdbsr028.slcsuccod
     let lr_param.cctlclcod = (d_bdbsr028.slccctcod / 10000)
     let lr_param.cctdptcod = (d_bdbsr028.slccctcod mod 10000)
     call fctgc102_vld_dep(lr_param.*) returning lr_ret.*

     if lr_ret.erro <> 0 then
        display lr_ret.mens
     end if

     let d_bdbsr028.cctnom = lr_ret.cctdptnom

     ## Fim

     let d_bdbsr028.apolice = ""
     open  c_bdbsr028_apl using d_bdbsr028.atdsrvnum, d_bdbsr028.atdsrvano
     fetch c_bdbsr028_apl into  d_bdbsr028.apolice
     close c_bdbsr028_apl

     let d_bdbsr028.entrega = d_bdbsr028.aviretdat + ws.c24utidiaqtd units day

     # DATAS DE PRORROGACAO
     if ws.rsrincdat is not null then
        let d_bdbsr028.aviretdat = ws.rsrincdat
     end if
     if ws.rsrfnldat is not null then
        let d_bdbsr028.entrega   = ws.rsrfnldat
     end if

     if ws.avialgmtv = 4 then
          insert into t_ccusto values (d_bdbsr028.atdsrvnum   ,
                                       d_bdbsr028.atdsrvano   ,
                                       d_bdbsr028.apolice     ,
                                       d_bdbsr028.c24pagdiaqtd,
                                       d_bdbsr028.slcsuccod   ,
                                       d_bdbsr028.slccctcod   ,
                                       d_bdbsr028.cctnom      ,
                                       d_bdbsr028.lcvnom      ,
                                       d_bdbsr028.lcvextcod   ,
                                       d_bdbsr028.c24solnom   ,
                                       d_bdbsr028.avilocnom   ,
                                       d_bdbsr028.aviretdat   ,
                                       d_bdbsr028.entrega     ,
                                       d_bdbsr028.socopgitmvlr,
                                       d_bdbsr028.socfatpgtdat) #--> FX-080515
     else
        #----------------------------
        # Verifica se tem prorrogacao
        #----------------------------
        select sum(aviprodiaqtd)
          into ws.aviprodiaqtd_pro
          from datmprorrog
         where atdsrvnum = d_bdbsr028.atdsrvnum
           and atdsrvano = d_bdbsr028.atdsrvano
           and cctcod    is not null
           and aviprostt = "A"

         if ws.aviprodiaqtd_pro is not null and
            ws.aviprodiaqtd_pro <> 0        then

            let ws.saldo = d_bdbsr028.c24pagdiaqtd - ws.aviprvent
            if ws.saldo <=0  then
               continue foreach
            end if

            declare c_prorrog cursor for
             select aviprodiaqtd, cctempcod, cctsuccod, cctcod
               from datmprorrog
              where atdsrvnum = d_bdbsr028.atdsrvnum
                and atdsrvano = d_bdbsr028.atdsrvano
                and cctcod    is not null
                and aviprostt = "A"

            foreach c_prorrog into ws.aviprodiaqtd     ,
                                   ws.cctempcod        ,
                                   d_bdbsr028.slcsuccod,
                                   d_bdbsr028.slccctcod

               if ws.saldo < ws.aviprodiaqtd then
                  let ws.aviprodiaqtd = ws.saldo
               end if

               let ws.socopgitmvlr_pro = d_bdbsr028.socopgitmvlr /
                                         d_bdbsr028.c24pagdiaqtd *
                                         ws.aviprodiaqtd

               ##- PSI:191167
#              open  c_bdbsr028_dep using ws.cctempcod        ,
#                                         d_bdbsr028.slcsuccod,
#                                         d_bdbsr028.slccctcod
#              fetch c_bdbsr028_dep into  d_bdbsr028.cctnom
#              close c_bdbsr028_dep

               let lr_param.empcod    = ws.cctempcod
               let lr_param.succod    = d_bdbsr028.slcsuccod
               let lr_param.cctlclcod = (d_bdbsr028.slccctcod / 10000)
               let lr_param.cctdptcod = (d_bdbsr028.slccctcod mod 10000)
               call fctgc102_vld_dep(lr_param.*) returning lr_ret.*

               if lr_ret.erro <> 0 then
                  display lr_ret.mens
               end if

               let d_bdbsr028.cctnom = lr_ret.cctdptnom

               ##Fim

               insert into t_ccusto values (d_bdbsr028.atdsrvnum   ,
                                            d_bdbsr028.atdsrvano   ,
                                            d_bdbsr028.apolice     ,
                                            ws.aviprodiaqtd        ,
                                            d_bdbsr028.slcsuccod   ,
                                            d_bdbsr028.slccctcod   ,
                                            d_bdbsr028.cctnom      ,
                                            d_bdbsr028.lcvnom      ,
                                            d_bdbsr028.lcvextcod   ,
                                            d_bdbsr028.c24solnom   ,
                                            d_bdbsr028.avilocnom   ,
                                            d_bdbsr028.aviretdat   ,
                                            d_bdbsr028.entrega     ,
                                            ws.socopgitmvlr_pro    ,
                                            d_bdbsr028.socfatpgtdat) #--> FX-080515

               let ws.saldo = ws.saldo - ws.aviprodiaqtd

            end foreach
         end if
     end if

 end foreach

 #-------------------------------------------
 # DESCARREGANDO TABELA TEMPORARIA EM ARQUIVO
 #-------------------------------------------
 declare c_bdbsr028_tmp cursor for
  select * from t_ccusto

 start report rel_bdbsr028 to ws.pathrel01
 start report rel_bdbsr028_txt to ws.pathrel01_txt #--> RELTXT

 foreach c_bdbsr028_tmp into d_bdbsr028.*
   output to report rel_bdbsr028()
   output to report rel_bdbsr028_txt() #--> RELTXT
 end foreach

 finish report rel_bdbsr028
 finish report rel_bdbsr028_txt #--> RELTXT
                                                               # Marcio Meta - PSI185035
 #------------------------------------------------------------------
 # E-MAIL PORTO SOCORRO
 #------------------------------------------------------------------
 let ws.executa = ' Reservas Deptos de '

 let l_retorno = ctx22g00_envia_email('BDBSR028',
                                       ws.executa,
                                       ws.pathrel01)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display " Erro ao enviar email(ctx22g00)-", ws.pathrel01
    else
       display " Email nao encontrado para este modulo BDBSR028 "
    end if
 end if
                                                               # Marcio Meta - PSI185035

# let ws.executa =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'Reservas Deptos de: ",ws.datchr[4,5],"/",
#                ws.datchr[7,10], "' ",
#               "costa_roberto/spaulo_psocorro_qualidade@u23 < ",
#               ws.pathrel01 clipped
# run ws.executa
#
# let ws.executa =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'Reservas Deptos de: ",ws.datchr[4,5],"/",
#                ws.datchr[7,10], "' ",
#               "jahchan_raji/spaulo_info_sistemas@u55 < ",
#               ws.pathrel01 clipped
# run ws.executa

end function  ###  bdbsr028

#----------------------------------------------------------------------------
 report rel_bdbsr028()
#----------------------------------------------------------------------------

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format

    on every row
       if  ws_flgcab = 0 then
           let ws_flgcab = 1
           print column 001, "N._Reserva",     "|"
                           , "Ano",            "|"
                           , "Apolice",        "|"
                           , "Diarias",        "|"
                           , "Sucursal ",      "|"
                           , "C._Custo",       "|"
                           , "Deptos",         "|"
                           , "Locadora",       "|"
                           , "Loja",           "|"
                           , "Solicitante",    "|"
                           , "Usuario",        "|"
                           , "Periodo",        "||"#--> FX-080515
                           , "Periodo",        "|"
                           , "Valor Item OP ", "|"
                           , "Data Pag.",      "|" #--> FX-080515
                           , ascii(13)
       end if

       print column 001, d_bdbsr028.atdsrvnum         ,"|",
                         d_bdbsr028.atdsrvano         ,"|",
                         d_bdbsr028.apolice           ,"|",
                         d_bdbsr028.c24pagdiaqtd      ,"|",
                         d_bdbsr028.slcsuccod         ,"|",
                         d_bdbsr028.slccctcod         ,"|",
                         d_bdbsr028.cctnom clipped    ,"|",
                         d_bdbsr028.lcvnom clipped    ,"|",
                         d_bdbsr028.lcvextcod clipped ,"|",
                         d_bdbsr028.c24solnom clipped ,"|",
                         d_bdbsr028.avilocnom clipped ,"|",
                         d_bdbsr028.aviretdat         ,"|",
                         d_bdbsr028.entrega           ,"|",
                         d_bdbsr028.socopgitmvlr using "-----------#","|",
                         d_bdbsr028.socfatpgtdat      ,"|", #--> FX-080515
                         ascii(13)

end report

#----------------------------------------------------------------------------
 report rel_bdbsr028_txt()
#----------------------------------------------------------------------------

 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format

    on every row


                   print d_bdbsr028.atdsrvnum                              ,ASCII(09),     ##"N._Reserva",
                         d_bdbsr028.atdsrvano                              ,ASCII(09),     ##"Ano",
                         d_bdbsr028.apolice                                ,ASCII(09),     ##"Apolice",
                         d_bdbsr028.c24pagdiaqtd                           ,ASCII(09),     ##"Diarias",
                         d_bdbsr028.slcsuccod                              ,ASCII(09),     ##"Sucursal ",
                         d_bdbsr028.slccctcod                              ,ASCII(09),     ##"C._Custo",
                         d_bdbsr028.cctnom clipped                         ,ASCII(09),     ##"Deptos",
                         d_bdbsr028.lcvnom clipped                         ,ASCII(09),     ##"Locadora",
                         d_bdbsr028.lcvextcod clipped                      ,ASCII(09),     ##"Loja",
                         d_bdbsr028.c24solnom clipped                      ,ASCII(09),     ##"Solicitante",
                         d_bdbsr028.avilocnom clipped                      ,ASCII(09),     ##"Usuario",
                         d_bdbsr028.aviretdat                              ,ASCII(09),     ##"Periodo",
                         d_bdbsr028.entrega                                ,ASCII(09),     ##"Valor",
                         d_bdbsr028.socopgitmvlr using "-----------#"      ,ASCII(09),     ##"Item OP",
                         d_bdbsr028.socfatpgtdat                           #--> FX-080515  ##"Data Pag.",


end report
