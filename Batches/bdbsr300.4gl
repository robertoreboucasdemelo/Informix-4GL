#############################################################################
# Nome do Modulo: BDBSR030                                                  #
#                                                                           #
# Relatorio mensal de total de servicos por prestador              Nov/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 23/07/2001  PSI 135526 Rodrigo Santos Trocar relat. gerados por arquivos  #
#---------------------------------------------------------------------------#
# 09/11/2001  PSI 135526   Wagner       Acertos gerais.                     #
#---------------------------------------------------------------------------#
# 01/10/2002  Correio      Wagner       Troca de e-mail Francisco Castro p/ #
#                                       Roberto Costa.                      #
#---------------------------------------------------------------------------#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 29/06/2004 Marcio , Meta     PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
# --------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#-----------------------------------------------------------------------------#
# 18/07/06   Junior, Meta       AS112372  Migracao de versao do 4gl.          #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
#-----------------------------------------------------------------------------#

database porto

 define ws_data_de     date
 define ws_data_ate    date
 define ws_data_aux    char(10)
 define ws_flgcab1     integer
 define ws_flgcab2     integer

 main
    call fun_dba_abre_banco("CT24HS")
    call bdbsr300()
 end main

#---------------------------------------------------------------
 function bdbsr300()
#---------------------------------------------------------------

 define d_bdbsr300    record
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (25)                  ,
    endufd             like dpaksocor.endufd     ,
    endbrr            like dpaksocor.endbrr      ,
    atdsrvorg         like datmservico.atdsrvorg ,
    asitipcod         like datmservico.asitipcod ,
    pasqtd            smallint                   ,
    qldgracod         like dpaksocor.qldgracod   ,
    cpodes            like iddkdominio.cpodes
 end record

 define ws            record
    atdetpcod         like datmsrvacp.atdetpcod  ,
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    atdfnlflg         like datmservico.atdfnlflg ,
    srvprlflg         like datmservico.srvprlflg ,
    vlrtabflg         like dpaksocor.vlrtabflg   ,
    dirfisnom         like ibpkdirlog.dirfisnom  ,
    pathrel01         char (60)                  ,
    pathrel02         char (60)                  ,
    executa           char (400)
 end record

 define sql_select    char(300)
 define l_retorno     smallint                                # Marcio Meta - PSI185035

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------
 initialize d_bdbsr300.*  to null
 initialize ws.*          to null

 let ws_flgcab1 = 0
 let ws_flgcab2 = 0

#---------------------------------------------------------------
# Preparacao dos comandos SQL
#---------------------------------------------------------------
 let sql_select = "select nomgrr, endcid, vlrtabflg, " ,
                  "       endufd, endbrr, qldgracod  " ,
                  "  from dpaksocor                  " ,
                  " where pstcoddig = ?              "
 prepare select_dpaksocor  from sql_select
 declare c_dpaksocor cursor for select_dpaksocor

 let sql_select = "select count(*)          ",
                  "  from datmpassageiro    ",
                  " where atdsrvnum = ?  and",
                  "       atdsrvano = ?     "
 prepare select_datmpassag  from sql_select
 declare c_datmpassag cursor for select_datmpassag

 let sql_select = "select atdetpcod    ",
                  "  from datmsrvacp   ",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?",
                  "   and atdsrvseq = (select max(atdsrvseq)",
                                      "  from datmsrvacp    ",
                                      " where atdsrvnum = ? ",
                                      "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from sql_select
 declare c_datmsrvacp cursor for sel_datmsrvacp

 let sql_select = "select cpodes               "
                 ,"  from iddkdominio          "
                 ," where cponom = 'qldgracod' "
                 ,"   and cpocod = ?           "
 prepare p_selqualid from sql_select
 declare c_selqualid cursor for p_selqualid

#---------------------------------------------------------------
# Data para execucao
#---------------------------------------------------------------
 let ws_data_aux = arg_val(1)

 if ws_data_aux is null   or
    ws_data_aux =  "  "   then
    if time  >= "17:00"   and
       time  <= "23:59"   then
       let ws_data_aux = today
    else
       let ws_data_aux = today - 1
    end if
 else
    if length(ws_data_aux) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws_data_aux = "01","/", ws_data_aux[4,5],"/", ws_data_aux[7,10]
 let ws_data_ate = ws_data_aux
 let ws_data_ate = ws_data_ate - 1 units day

 let ws_data_aux = ws_data_ate
 let ws_data_aux = "01","/", ws_data_aux[4,5],"/", ws_data_aux[7,10]
 let ws_data_de  = ws_data_aux

#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
#WWWXcall f_path("DAT", "ARQUIVO")
#WWWX      returning ws.dirfisnom
#WWWX -->TESTe
## let ws.dirfisnom = "/rdat"
#WWWX STe
                                                                 # Marcio Meta - PSI185035
 call f_path("DBS", "ARQUIVO")
    returning ws.dirfisnom

 if ws.dirfisnom is null then
    let ws.dirfisnom = '.'
 end if

 let ws.pathrel01 = ws.dirfisnom clipped, "/RDBS30001.TXT"
 let ws.pathrel02 = ws.dirfisnom clipped, "/RDBS30002.TXT"
                                                                 # Marcio Meta - PSI185035
#---------------------------------------------------------------
# Inicio da leitura principal
#---------------------------------------------------------------
 declare c_bdbsr300 cursor for
    select datmservico.atdsrvnum ,
           datmservico.atdsrvano ,
           datmservico.atdprscod ,
           datmservico.atdsrvorg ,
           datmservico.atdfnlflg ,
           datmservico.srvprlflg ,
           datmservico.asitipcod
      from datmservico
     where atddat between ws_data_de  and ws_data_ate

 start report  rep_prssrv  to  ws.pathrel01
 start report  rep_totsrv  to  ws.pathrel01
 start report  rep_tottax  to  ws.pathrel02

 foreach c_bdbsr300  into  ws.atdsrvnum        ,
                           ws.atdsrvano        ,
                           d_bdbsr300.atdprscod,
                           d_bdbsr300.atdsrvorg,
                           ws.atdfnlflg        ,
                           ws.srvprlflg        ,
                           d_bdbsr300.asitipcod

    if d_bdbsr300.atdprscod is null or    ###  Nao contem codigo de prestador.
       d_bdbsr300.atdprscod =  0    or    ###  Codigo de Prestador e' zero.
       d_bdbsr300.atdsrvorg = 10    or    ###  Vistoria Previa Domiciliar
       d_bdbsr300.atdsrvorg = 11    or    ###  Aviso Furto/Roubo
       d_bdbsr300.atdsrvorg = 12    or    ###  Servico de Apoio
       d_bdbsr300.atdsrvorg = 8     then  ###  Reserva Carro Extra
       continue foreach
    end if

    if ws.srvprlflg = "S"  then
       continue foreach
    end if

    if ws.atdfnlflg = "N"  then
       continue foreach
    end if

    #-----------------------------
    # Verifica etapa dos servicos
    #-----------------------------
    open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano,
                             ws.atdsrvnum, ws.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if ws.atdetpcod = 5  or     ###  Servico CANCELADO
       ws.atdetpcod = 6  then   ###  Servico EXCLUIDO
       continue foreach
    end if

    #-----------------------------
    # Informacoes para relatorio de assistencia a passageiros - Taxi
    #-----------------------------
    let d_bdbsr300.pasqtd = 0
    if d_bdbsr300.atdsrvorg = 3    or
       d_bdbsr300.atdsrvorg = 2    then
       open  c_datmpassag using ws.atdsrvnum, ws.atdsrvano
       fetch c_datmpassag into  d_bdbsr300.pasqtd
       close c_datmpassag
    end if

    output to report rep_prssrv(d_bdbsr300.*)

 end foreach

 finish report rep_prssrv
 finish report rep_totsrv
 finish report rep_tottax
                                                               # Marcio Meta - PSI185035
 #------------------------------------------------------------------
 # E-MAIL PORTO SOCORRO
 #------------------------------------------------------------------
 let ws.executa = ' PSocorro mensal atendidos: '

 let l_retorno = ctx22g00_envia_email('BDBSR300',
                                       ws.executa,
                                       ws.pathrel01)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display " Erro ao enviar email(ctx22g00)-", ws.pathrel01
    else
       display " Email nao encontrado para este modulo BDBSR300 "
    end if
 end if

 let ws.executa = ' Ass.Pass. mensal atendidos: '

 let l_retorno = ctx22g00_envia_email('BDBSR300',
                                       ws.executa,
                                       ws.pathrel02)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display " Erro ao enviar email(ctx22g00)-", ws.pathrel02
    else
       display " Email nao encontrado para este modulo BDBSR300 "
    end if
 end if
                                                                  # Marcio Meta - PSI185035
# let ws.executa =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'PSocorro mensal atendidos: ",ws_data_aux[4,5],"/",
#                ws_data_aux[7,10], "' ",
#               "agostinho_wagner/spaulo_info_sistemas@u55 < ",
#               ws.pathrel01 clipped
# run ws.executa
# let ws.executa =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'PSocorro mensal atendidos: ",ws_data_aux[4,5],"/",
#                ws_data_aux[7,10], "' ",
#               "costa_roberto/spaulo_psocorro_qualidade@u23 < ",
#               ws.pathrel01 clipped
# run ws.executa
#
# let ws.executa =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'Ass.Pass. mensal atendidos: ",ws_data_aux[4,5],"/",
#                ws_data_aux[7,10], "' ",
#               "agostinho_wagner/spaulo_info_sistemas@u55 < ",
#               ws.pathrel02 clipped
# run ws.executa
# let ws.executa =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
#               " -s 'Ass.Pass. mensal atendidos: ",ws_data_aux[4,5],"/",
#                ws_data_aux[7,10], "' ",
#               "costa_roberto/spaulo_psocorro_qualidade@u23 < ",
#               ws.pathrel02 clipped
# run ws.executa
#
#

end function  ###  bdbsr300

#---------------------------------------------------------------------------
 report rep_prssrv(par_bdbsr300)
#---------------------------------------------------------------------------

 define par_bdbsr300  record
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint                   ,
    nomgrr            like dpaksocor.nomgrr      ,
    endcid            char (25)                  ,
    endufd            like dpaksocor.endufd      ,
    endbrr            like dpaksocor.endbrr      ,
    atdsrvorg         like datmservico.atdsrvorg ,
    asitipcod         like datmservico.asitipcod ,
    pasqtd            smallint                   ,
    qldgracod         like dpaksocor.qldgracod   ,
    cpodes            like iddkdominio.cpodes
 end record

 define r_bdbsr300    record
    rem               dec (06,0)                 ,
    soc               dec (06,0)                 ,
    gui               dec (06,0)                 ,
    tec               dec (06,0)                 ,
    amb               dec (06,0)                 ,
    cha               dec (06,0)                 ,
    daf               dec (06,0)                 ,
    rpt               dec (06,0)                 ,
    rep               dec (06,0)                 ,
    sre               dec (06,0)                 ,
    grl               dec (06,0)                 ,
    tax               dec (06,0)                 ,
    pas               dec (06,0)
 end record

 define r_ws          record
    txqtdsrv          dec(6,0),
    txqtdpas          dec(6,0),
    avqtdsrv          dec(6,0),
    avqtdpas          dec(6,0),
    rdqtdsrv          dec(6,0),
    rdqtdpas          dec(6,0),
    abqtdsrv          dec(6,0),
    abqtdpas          dec(6,0),
    trqtdsrv          dec(6,0),
    trqtdpas          dec(6,0),
    hpqtdsrv          dec(6,0),
    hpqtdpas          dec(6,0)
 end record

   output
      left   margin  000
      right  margin  001
      top    margin  000
      bottom margin  000
      page   length  080

   order by  par_bdbsr300.atdprscod

   format

      before group of par_bdbsr300.atdprscod
             let r_bdbsr300.rem = 0
             let r_bdbsr300.soc = 0
             let r_bdbsr300.gui = 0
             let r_bdbsr300.tec = 0
             let r_bdbsr300.amb = 0
             let r_bdbsr300.cha = 0
             let r_bdbsr300.daf = 0
             let r_bdbsr300.rpt = 0
             let r_bdbsr300.rep = 0
             let r_bdbsr300.sre = 0
             let r_bdbsr300.grl = 0
             let r_bdbsr300.tax = 0
             let r_bdbsr300.pas = 0
             let r_ws.txqtdsrv  = 0
             let r_ws.txqtdpas  = 0
             let r_ws.avqtdsrv  = 0
             let r_ws.avqtdpas  = 0
             let r_ws.rdqtdsrv  = 0
             let r_ws.rdqtdpas  = 0
             let r_ws.abqtdsrv  = 0
             let r_ws.abqtdpas  = 0
             let r_ws.trqtdsrv  = 0
             let r_ws.trqtdpas  = 0
             let r_ws.hpqtdsrv  = 0
             let r_ws.hpqtdpas  = 0

      after  group of par_bdbsr300.atdprscod
             if r_bdbsr300.grl > 0  then
                output to report rep_totsrv(par_bdbsr300.*,
                                            r_bdbsr300.*)
             end if

             if r_bdbsr300.tax > 0  then
                output to report rep_tottax(par_bdbsr300.*,
                                            r_bdbsr300.*  ,
                                            r_ws.*        )
             end if

      on every row
             case par_bdbsr300.atdsrvorg
                when 1  let r_bdbsr300.soc = r_bdbsr300.soc + 1 # P.Socorro
                   case par_bdbsr300.asitipcod
                      when  1      # Guincho
                         let r_bdbsr300.gui = r_bdbsr300.gui + 1
                      when  2      # Tecnico
                         let r_bdbsr300.tec = r_bdbsr300.tec + 1
                      when  3      # Ambos
                         let r_bdbsr300.amb = r_bdbsr300.amb + 1
                      when  4      # Chaveiro
                         let r_bdbsr300.cha = r_bdbsr300.cha + 1
                      when  8      # Chaveiro/Dispositivo
                         let r_bdbsr300.cha = r_bdbsr300.cha + 1
                   end case
                when 2          # Assist. Passageiros
                   let r_bdbsr300.tax = r_bdbsr300.tax + 1
                   let r_bdbsr300.pas = r_bdbsr300.pas + par_bdbsr300.pasqtd
                   case par_bdbsr300.asitipcod
                      when  5      # Taxi
                         let r_ws.txqtdsrv = r_ws.txqtdsrv + 1
                         let r_ws.txqtdpas = r_ws.txqtdpas + par_bdbsr300.pasqtd
                      when 10      # Aviao
                         let r_ws.avqtdsrv = r_ws.avqtdsrv + 1
                         let r_ws.avqtdpas = r_ws.avqtdpas + par_bdbsr300.pasqtd
                      when 16      # Rodoviario
                         let r_ws.rdqtdsrv = r_ws.rdqtdsrv + 1
                         let r_ws.rdqtdpas = r_ws.rdqtdpas + par_bdbsr300.pasqtd
                      when 11      # Ambulancia
                         let r_ws.abqtdsrv = r_ws.abqtdsrv + 1
                         let r_ws.abqtdpas = r_ws.abqtdpas + par_bdbsr300.pasqtd
                      when 12      # Translado
                         let r_ws.trqtdsrv = r_ws.trqtdsrv + 1
                         let r_ws.trqtdpas = r_ws.trqtdpas + par_bdbsr300.pasqtd
                   end case
                when 3  let r_bdbsr300.tax = r_bdbsr300.tax + 1 # Ass.Pass.
                   let r_bdbsr300.pas = r_bdbsr300.pas + par_bdbsr300.pasqtd
                   if par_bdbsr300.asitipcod =  13  then      # Hospedagem
                      let r_ws.hpqtdsrv = r_ws.hpqtdsrv + 1
                      let r_ws.hpqtdpas = r_ws.hpqtdpas + par_bdbsr300.pasqtd
                   end if
                when 4  let r_bdbsr300.rem = r_bdbsr300.rem + 1 # Remocoes
                when 5  let r_bdbsr300.rpt = r_bdbsr300.rpt + 1 # RPT
                when 6  let r_bdbsr300.daf = r_bdbsr300.daf + 1 # D.A.F.
                when 7  let r_bdbsr300.rep = r_bdbsr300.rep + 1 # Replace
                when 9  let r_bdbsr300.sre = r_bdbsr300.sre + 1 # Socorro RE
                when 13 let r_bdbsr300.sre = r_bdbsr300.sre + 1 # Sinis   RE
             end case

             if par_bdbsr300.atdsrvorg <> 3  and
                par_bdbsr300.atdsrvorg <> 2  then
                let r_bdbsr300.grl = r_bdbsr300.grl + 1
             end if

end report  ###  rep_prssrv

#---------------------------------------------------------------------------
 report rep_totsrv(r_bdbsr300)
#---------------------------------------------------------------------------

 define r_bdbsr300    record
    atdprscod         like datmservico.atdprscod ,
    atdprstip         smallint,
    nomgrr            like dpaksocor.nomgrr,
    endcid            char (25),
    endufd            like dpaksocor.endufd,
    endbrr            like dpaksocor.endbrr,
    atdsrvorg         like datmservico.atdsrvorg,
    asitipcod         like datmservico.asitipcod,
    pasqtd            smallint,
    qldgracod         like dpaksocor.qldgracod,
    cpodes            like iddkdominio.cpodes,
    rem               dec (6,0),
    soc               dec (6,0),
    gui               dec (6,0),
    tec               dec (6,0),
    amb               dec (6,0),
    cha               dec (6,0),
    daf               dec (6,0),
    rpt               dec (6,0),
    rep               dec (6,0),
    sre               dec (6,0),
    grl               dec (6,0),
    tax               dec (6,0),
    pas               dec (6,0)
 end record

 define a_bdbsr300    array[04] of record
    dsc               char (06),
    rem               dec (6,0),
    soc               dec (6,0),
    gui               dec (6,0),
    tec               dec (6,0),
    amb               dec (6,0),
    cha               dec (6,0),
    daf               dec (6,0),
    rpt               dec (6,0),
    rep               dec (6,0),
    sre               dec (6,0),
    grl               dec (6,0)
 end record

 define ws           record
    vlrtabflg        like dpaksocor.vlrtabflg,
    tipo             char(10)
 end record

   output
      left   margin  000
      right  margin  145
      top    margin  000
      bottom margin  000
      page   length  066

   order by r_bdbsr300.atdprscod

   format
      on every row
         #-----------------------------
         # Dados do prestador
         #-----------------------------
         let r_bdbsr300.nomgrr = "*** NAO CADASTRADO ***"
         let r_bdbsr300.endcid = "*** NAO CADASTRADO ***"
         open  c_dpaksocor using r_bdbsr300.atdprscod
         fetch c_dpaksocor into  r_bdbsr300.nomgrr    , r_bdbsr300.endcid    ,
                                 ws.vlrtabflg         , r_bdbsr300.endufd    ,
                                 r_bdbsr300.endbrr    , r_bdbsr300.qldgracod
         close c_dpaksocor

         open c_selqualid using r_bdbsr300.qldgracod
         fetch c_selqualid into r_bdbsr300.cpodes
         close c_selqualid

         if r_bdbsr300.atdprscod = 1  or
            r_bdbsr300.atdprscod = 4  or
            r_bdbsr300.atdprscod = 8  then
            let r_bdbsr300.atdprstip = 1     ###  Frota Porto Seguro
         else
            if ws.vlrtabflg = "S" then
               let r_bdbsr300.atdprstip = 2  ###  Tabela
            else
               let r_bdbsr300.atdprstip = 3  ###  Outros
            end if
         end if
         case r_bdbsr300.atdprstip
              when 1  let ws.tipo = "FROTA"
              when 2  let ws.tipo = "TABELA"
              when 3  let ws.tipo = "OUTROS"
              when 4  let ws.tipo = "TODOS"
         end case

         if ws_flgcab1 = 0 then
            let ws_flgcab1 = 1
            print column 001, "Cod_prestador",  "|"
                            , "Nome_prestador", "|"
                            , "Tipo",           "|"
                            , "Cidade",         "|"
                            , "UF",             "|"
                            , "Qualidade",      "|"
                            , "Qtd_Remocoes",   "|"
                            , "Guincho",        "|"
                            , "Tecnico",        "|"
                            , "Ambos",          "|"
                            , "Cheveiro",       "|"
                            , "DAF",            "|"
                            , "RPT",            "|"
                            , "Replace",        "|"
                            , "RE",             "|"
                            , ascii(13)
         end if

         print r_bdbsr300.atdprscod using "&&&&&" , "|", #cod prest
               r_bdbsr300.nomgrr clipped,           "|", #nom prest
               ws.tipo clipped,                     "|", #tipo prest
               r_bdbsr300.endcid clipped,           "|", #cidade prest
               r_bdbsr300.endufd,                   "|", #uf prest
               r_bdbsr300.cpodes clipped,           "|", #qual prest
               r_bdbsr300.rem using "<<<<<&" ,      "|", #qtde remocao
               r_bdbsr300.gui using "<<<<<&" ,      "|", #guincho
               r_bdbsr300.tec using "<<<<<&" ,      "|", #tecnico
               r_bdbsr300.amb using "<<<<<&" ,      "|", #ambos
               r_bdbsr300.cha using "<<<<<&" ,      "|", #chaveiro
               r_bdbsr300.daf using "<<<<<&" ,      "|", #D.A.F
               r_bdbsr300.rpt using "<<<<<&" ,      "|", #R.P.T
               r_bdbsr300.rep using "<<<<<&" ,      "|", #replace
               r_bdbsr300.sre using "<<<<<&" ,      "|", #RE
               ascii(13)

end report  ###  rep_totsrv

#---------------------------------------------------------------------------
 report rep_tottax(r_bdbsr300)
#---------------------------------------------------------------------------

 define r_bdbsr300   record
    atdprscod        like datmservico.atdprscod ,
    atdprstip        smallint,
    nomgrr           like dpaksocor.nomgrr,
    endcid           char (030),
    endufd           like dpaksocor.endufd,
    endbrr           like dpaksocor.endbrr,
    atdsrvorg        like datmservico.atdsrvorg ,
    asitipcod        like datmservico.asitipcod ,
    pasqtd           smallint,
    qldgracod        like dpaksocor.qldgracod,
    cpodes           like iddkdominio.cpodes,
    rem              dec (6,0),
    soc              dec (6,0),
    gui              dec (6,0),
    tec              dec (6,0),
    amb              dec (6,0),
    cha              dec (6,0),
    daf              dec (6,0),
    rpt              dec (6,0),
    rep              dec (6,0),
    sre              dec (6,0),
    grl              dec (6,0),
    tax              dec (6,0),
    pas              dec (6,0),
    txqtdsrv         dec (6,0),
    txqtdpas         dec (6,0),
    avqtdsrv         dec (6,0),
    avqtdpas         dec (6,0),
    rdqtdsrv         dec (6,0),
    rdqtdpas         dec (6,0),
    abqtdsrv         dec (6,0),
    abqtdpas         dec (6,0),
    trqtdsrv         dec (6,0),
    trqtdpas         dec (6,0),
    hpqtdsrv         dec (6,0),
    hpqtdpas         dec (6,0)
 end record

 define ws           record
    pasmed           dec (13,2),
    totger           dec (13,2),
    vlrtabflg        like dpaksocor.vlrtabflg,
    tipo             char(20)
 end record

 output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr300.tax  desc

   format
      on every row
         #-----------------------------
         # Dados do prestador
         #-----------------------------
         let r_bdbsr300.nomgrr = "*** NAO CADASTRADO ***"
         let r_bdbsr300.endcid = "*** NAO CADASTRADO ***"
         open  c_dpaksocor using r_bdbsr300.atdprscod
         fetch c_dpaksocor into  r_bdbsr300.nomgrr    , r_bdbsr300.endcid    ,
                                 ws.vlrtabflg         , r_bdbsr300.endufd    ,
                                 r_bdbsr300.endbrr    , r_bdbsr300.qldgracod
         close c_dpaksocor

         open c_selqualid using r_bdbsr300.qldgracod
         fetch c_selqualid into r_bdbsr300.cpodes
         close c_selqualid

         if r_bdbsr300.atdprscod = 1  or
            r_bdbsr300.atdprscod = 4  or
            r_bdbsr300.atdprscod = 8  then
            let r_bdbsr300.atdprstip = 1     ###  Frota Porto Seguro
         else
            if ws.vlrtabflg = "S" then
               let r_bdbsr300.atdprstip = 2  ###  Tabela
            else
               let r_bdbsr300.atdprstip = 3  ###  Outros
            end if
         end if
         case r_bdbsr300.atdprstip
              when 1  let ws.tipo = "FROTA"
              when 2  let ws.tipo = "TABELA"
              when 3  let ws.tipo = "OUTROS"
              when 4  let ws.tipo = "TODOS"
         end case

         let ws.totger = r_bdbsr300.txqtdsrv + r_bdbsr300.avqtdsrv  +
                         r_bdbsr300.rdqtdsrv + r_bdbsr300.abqtdsrv  +
                         r_bdbsr300.trqtdsrv + r_bdbsr300.hpqtdsrv

         let ws.pasmed = (r_bdbsr300.pas / ws.totger)

         if ws_flgcab2 = 0 then
            let ws_flgcab2 = 1
            print column 001, "Cod_prestador",  "|"
                            , "Nome_prestador", "|"
                            , "Tipo",           "|"
                            , "Cidade",         "|"
                            , "UF",             "|"
                            , "Qualidade",      "|"
                            , "Taxi",           "|"
                            , "Aviao",          "|"
                            , "Rodoviario",     "|"
                            , "Ambulancia",     "|"
                            , "Translado",      "|"
                            , "Hospedagem",     "|"
                            , "Tot_Geral",      "|"
                            , "Qtd_Passag.",    "|"
                            , "Media",          "|"
                            , ascii(13)
         end if

         print r_bdbsr300.atdprscod using "&&&&&", "|", #cod prest
               r_bdbsr300.nomgrr clipped,          "|", #nom prest
               ws.tipo clipped,                    "|", #tipo prest
               r_bdbsr300.endcid clipped,          "|", #cidade prest
               r_bdbsr300.endufd,                  "|", #uf prest
               r_bdbsr300.cpodes clipped,          "|", #qual prest
               r_bdbsr300.txqtdsrv using "<<<<<&" ,"|", #taxi
               r_bdbsr300.avqtdsrv using "<<<<<&" ,"|", #aviao
               r_bdbsr300.rdqtdsrv using "<<<<<&" ,"|", #rodoviario
               r_bdbsr300.abqtdsrv using "<<<<<&" ,"|", #ambulancia
               r_bdbsr300.trqtdsrv using "<<<<<&" ,"|", #translado
               r_bdbsr300.hpqtdsrv using "<<<<<&" ,"|", #hospedagem
               ws.totger        using "<<<<<&" ,   "|", #total geral
               r_bdbsr300.pas   using "<<<<<&" ,   "|", #qtde passagens
               ws.pasmed,                          "|", #media
               ascii(13)

end report  ###  rep_tottax
