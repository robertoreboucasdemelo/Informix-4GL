#############################################################################
# Nome do Modulo: BDATA038                                        Marcelo   #
#                                                                 Gilberto  #
# Limpeza mensal das ligacoes                                     Abr/1997  #
#############################################################################
#                                                                           #
# datmligacao    datrligapol      datmlighist       datrligmens             #
# datmreclam     datmsitrecl      datrligpac        datmligfrm              #
# datrligsrv     datrligsinvst    datrligsinavs     work:datmlimplig        #
# datmservico    datrservapol     datmservhist      datmservicocmp          #
# datmsrvacp     datmpesquisa     datrpesqaval      datmpesqhist            #
# datmtrajeto    datmavisrent     datmalugveic      datmprorrog             #
# dblmpagto      dblmpagitem      datmassistpassag  datmpassageiro          #
# datmsrvre      datrsrvvstsin    datmlcl           datmavssin              #
# datmcntsrv 	 datmmdtsrv	  datmpreacp        datmsrvanlhst           #
# datmsrvint     datmsrvintale    datmsrvintcmp     datmsrvintseqult        #
# datmsrvjit     datmsrvretexc    datmtrxfila       datmvclapltrc           #
# datmvistoria   datmvstcanc  	  datratdmltsrv     datrligtrp              #
# datrsrvcnd     datrsrvpbm	  datmligatd	    datmsrvext              #
# datrligagn	 datrligcgccpf	  datrligcnslig	    datrligcor              #
# datrligmat	 datrligppt	  datrligprp	    datrligrcuccsmtv        #
# datrligsin	 datrligtel	  datrligtrpavb     datrdrscrsagdlig        #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 27/11/1998  PSI 6467-0   Gilberto     Incluir a tabela DATMLIGFRM na lim- #
#                                       peza.                               #
#---------------------------------------------------------------------------#
# 09/04/1999  PSI 5591-3   Gilberto     Incluir a tabela DATMLCL na limpeza #
#---------------------------------------------------------------------------#
# 13/07/1999  PSI 7547-7   Gilberto     Incluir as tabelas DATMTRPPSGAER,   #
#                                       DATMTRPTAXI e DATMHOSPED na limpeza #
#---------------------------------------------------------------------------#
# 26/07/1999  PSI 7952-9   Wagner       Incluir a tabela DATMRPT na limpeza #
#---------------------------------------------------------------------------#
# 04/11/1999  PSI 9118-9   Gilberto     Incluir as tabelas de relacionamen- #
#                                       to DATRLIGSRV, DATRLIGSINVST e      #
#                                       DATRLIGSINAVS na limpeza.           #
#---------------------------------------------------------------------------#
# 16/12/1999  PSI 7263-0   Gilberto     Incluir a tabela de relacionamento  #
#                                       DATRLIGPRP na limpeza.              #
#---------------------------------------------------------------------------#
# 14/02/2000               Gilberto     Substituir campo ATLULT por ATLDAT  #
#                                       e ATLHOR.                           #
#---------------------------------------------------------------------------#
# 10/09/2005               Helio (Meta) Melhorias incluida funcao           #
#                                       fun_dba_abre_banco.                 #
#---------------------------------------------------------------------------#
# 10/03/2009  PSI 235580 Carla Rampazzo Auto Jovem - Curso Direcao Defensiva#
#                                       Inlcuir datrdrscrsagdlig na limpeza #
#############################################################################

 database porto

 main
   call fun_dba_abre_banco("CT24HS")
    set lock mode to wait 10
    call startlog("/ldat/ldata038")

    call bdata038()
 end main

#--------------------------------------------------------------------------
 function bdata038()
#--------------------------------------------------------------------------

 define d_bdata038  record
    lignum          like datmligacao.lignum   ,
    atdsrvnum       like datmligacao.atdsrvnum,
    atdsrvano       like datmligacao.atdsrvano,
    ligexcflg       char (001)
 end record

 define ws          record
    sql             char (500),
    srvexcflg       smallint  ,
    atldat          like datmlimpeza.atldat,
    atlhor          like datmlimpeza.atlhor
 end record

 # define a_bdata038  array[35] of record
 define a_bdata038  array[68] of record
    tabnom          char (20),
    qtdexc          integer
 end record

 define arr_aux     smallint

#--------------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------------

 initialize d_bdata038.*  to null
 initialize ws.*          to null

 let a_bdata038[01].tabnom = "datmligacao"
 let a_bdata038[02].tabnom = "datrligapol"
 let a_bdata038[03].tabnom = "datrligpac"
 let a_bdata038[04].tabnom = "datrligprp"
 let a_bdata038[05].tabnom = "datmlighist"
 let a_bdata038[06].tabnom = "datrligmens"
 let a_bdata038[07].tabnom = "datrligsrv"
 let a_bdata038[08].tabnom = "datrligsinvst"
 let a_bdata038[09].tabnom = "datrligsinavs"
 let a_bdata038[10].tabnom = "datmreclam"
 let a_bdata038[11].tabnom = "datmsitrecl"
 let a_bdata038[12].tabnom = "datmligfrm"
 let a_bdata038[13].tabnom = "datmservico"
 let a_bdata038[14].tabnom = "datrservapol"
 let a_bdata038[15].tabnom = "datmservhist"
 let a_bdata038[16].tabnom = "datmservicocmp"
 let a_bdata038[17].tabnom = "datmsrvacp"
 let a_bdata038[18].tabnom = "datmpesquisa"
 let a_bdata038[19].tabnom = "datrpesqaval"
 let a_bdata038[20].tabnom = "datmpesqhist"
 let a_bdata038[21].tabnom = "datmtrajeto"
 let a_bdata038[22].tabnom = "datmavisrent"
 let a_bdata038[23].tabnom = "datmalugveic"
 let a_bdata038[24].tabnom = "datmprorrog"
 let a_bdata038[25].tabnom = "dblmpagto"
 let a_bdata038[26].tabnom = "dblmpagitem"
 let a_bdata038[27].tabnom = "datmassistpassag"
 let a_bdata038[28].tabnom = "datmpassageiro"
 let a_bdata038[29].tabnom = "datmsrvre"
 let a_bdata038[30].tabnom = "datrsrvvstsin"
 let a_bdata038[31].tabnom = "datmlcl"
 let a_bdata038[32].tabnom = "datmtrptaxi"
 let a_bdata038[33].tabnom = "datmtrppsgaer"
 let a_bdata038[34].tabnom = "datmhosped"
 let a_bdata038[35].tabnom = "datmrpt"
 let a_bdata038[37].tabnom = "datmavssin"
 let a_bdata038[38].tabnom = "datmcntsrv"
 let a_bdata038[39].tabnom = "datmmdtsrv"
 let a_bdata038[40].tabnom = "datmpreacp"
 let a_bdata038[41].tabnom = "datmsrvanlhst"
 let a_bdata038[42].tabnom = "datmsrvint"
 let a_bdata038[43].tabnom = "datmsrvintale"
 let a_bdata038[44].tabnom = "datmsrvintcmp"
 let a_bdata038[45].tabnom = "datmsrvintseqult"
 let a_bdata038[46].tabnom = "datmsrvjit"
 let a_bdata038[47].tabnom = "datmsrvretexc"
 let a_bdata038[48].tabnom = "datmtrxfila"
 let a_bdata038[49].tabnom = "datmvclapltrc"
 let a_bdata038[50].tabnom = "datmvistoria"
 let a_bdata038[51].tabnom = "datmvstcanc"
 let a_bdata038[52].tabnom = "datratdmltsrv"
 let a_bdata038[53].tabnom = "datrligtrp"
 let a_bdata038[54].tabnom = "datrsrvcnd"
 let a_bdata038[55].tabnom = "datrsrvpbm"
 let a_bdata038[56].tabnom = "datmligatd"
 let a_bdata038[57].tabnom = "datmsrvext"
 let a_bdata038[58].tabnom = "datrligagn"
 let a_bdata038[59].tabnom = "datrligcgccpf"
 let a_bdata038[60].tabnom = "datrligcnslig"
 let a_bdata038[61].tabnom = "datrligcor"
 let a_bdata038[62].tabnom = "datrligmat"
 let a_bdata038[63].tabnom = "datrligppt"
 let a_bdata038[64].tabnom = "datrligrcuccsmtv"
 let a_bdata038[65].tabnom = "datrligsin"
 let a_bdata038[66].tabnom = "datrligtel"
 let a_bdata038[67].tabnom = "datrligtrpavb"
 let a_bdata038[68].tabnom = "datrdrscrsagdlig"

 #for arr_aux = 1 to 35
 for arr_aux = 1 to 68
   let a_bdata038[arr_aux].qtdexc = 0
 end for

#--------------------------------------------------------------------------
# Preparacao dos comandos SQL
#--------------------------------------------------------------------------

 let ws.sql = "delete from datmligacao",
              " where lignum = ?      "
 prepare del_datmligacao from ws.sql

 let ws.sql = "delete from datrligapol",
              " where lignum = ?      "
 prepare del_datrligapol from ws.sql

 let ws.sql = "delete from datrligpac",
              " where lignum = ?     "
 prepare del_datrligpac from ws.sql

 let ws.sql = "delete from datrligprp",
              " where lignum = ?     "
 prepare del_datrligprp from ws.sql

 let ws.sql = "delete from datmlighist",
              " where lignum = ?      "
 prepare del_datmlighist from ws.sql

 let ws.sql = "delete from datrligmens",
              " where lignum = ?      "
 prepare del_datrligmens from ws.sql

 let ws.sql = "delete from datrligsrv",
              " where lignum = ?     "
 prepare del_datrligsrv from ws.sql

 let ws.sql = "delete from datrligsinvst",
              " where lignum = ?        "
 prepare del_datrligsinvst from ws.sql

 let ws.sql = "delete from datrligsinavs",
              " where lignum = ?        "
 prepare del_datrligsinavs from ws.sql

 let ws.sql = "delete from datmreclam ",
              " where lignum = ?      "
 prepare del_datmreclam  from ws.sql

 let ws.sql = "delete from datmsitrecl",
              " where lignum = ?      "
 prepare del_datmsitrecl from ws.sql

 let ws.sql = "delete from datmligfrm",
              " where lignum = ?     "
 prepare del_datmligfrm  from ws.sql

 let ws.sql = "delete from datmservico ",
              " where atdsrvnum = ? and",
              "       atdsrvano = ?    "
 prepare del_datmservico from ws.sql

 let ws.sql = "delete from datrservapol  ",
              " where atdsrvnum = ? and  ",
              "       atdsrvano = ?      "
 prepare del_datrservapol from ws.sql

 let ws.sql = "delete from datmservhist " ,
              " where atdsrvnum = ? and " ,
              "       atdsrvano = ?     "
 prepare del_datmservhist from ws.sql

 let ws.sql = "delete from datmservicocmp",
              " where atdsrvnum = ? and  ",
              "       atdsrvano = ?      "
 prepare del_datmservicocmp from ws.sql

 let ws.sql = "delete from datmsrvacp   ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmsrvacp from ws.sql

 let ws.sql = "delete from datmpesquisa " ,
              " where atdsrvnum = ? and " ,
              "       atdsrvano = ?     "
 prepare del_datmpesquisa from ws.sql

 let ws.sql = "delete from datrpesqaval " ,
              " where atdsrvnum = ? and " ,
              "       atdsrvano = ?     "
 prepare del_datrpesqaval from ws.sql

 let ws.sql = "delete from datmpesqhist " ,
              " where atdsrvnum = ? and " ,
              "       atdsrvano = ?     "
 prepare del_datmpesqhist from ws.sql

 let ws.sql = "delete from datmtrajeto  " ,
              " where atdsrvnum = ? and " ,
              "       atdsrvano = ?     "
 prepare del_datmtrajeto from ws.sql

 let ws.sql = "delete from datmavisrent ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmavisrent from ws.sql

 let ws.sql = "delete from datmalugveic ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmalugveic from ws.sql

 let ws.sql = "delete from datmprorrog  ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmprorrog from ws.sql

 let ws.sql = "delete from dblmpagto    ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_dblmpagto from ws.sql

 let ws.sql = "delete from dblmpagitem  ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_dblmpagitem from ws.sql

 let ws.sql = "delete from datmassistpassag ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmassistpassag from ws.sql

 let ws.sql = "delete from datmpassageiro ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmpassageiro from ws.sql

 let ws.sql = "delete from datmsrvre    ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmsrvre from ws.sql

 let ws.sql = "delete from datrsrvvstsin",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datrsrvvstsin from ws.sql

 let ws.sql = "delete from datmlcl      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmlcl from ws.sql

 let ws.sql = "delete from datmtrptaxi  ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmtrptaxi from ws.sql

 let ws.sql = "delete from datmtrppsgaer",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmtrppsgaer from ws.sql

 let ws.sql = "delete from datmhosped   ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmhosped from ws.sql

 let ws.sql = "delete from datmrpt      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmrpt from ws.sql

 let ws.sql = "delete from datmavssin      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmavssin from ws.sql

 let ws.sql = "delete from datmcntsrv      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmcntsrv from ws.sql

 let ws.sql = "delete from datmmdtsrv      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmmdtsrv from ws.sql

 let ws.sql = "delete from datmpreacp      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmpreacp from ws.sql

 let ws.sql = "delete from datmsrvanlhst      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmsrvanlhst from ws.sql

 let ws.sql = "delete from datmsrvint      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmsrvint from ws.sql

 let ws.sql = "delete from datmsrvintale      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmsrvintale from ws.sql

 let ws.sql = "delete from datmsrvintcmp      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmsrvintcmp from ws.sql

 let ws.sql = "delete from datmsrvintseqult      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmsrvintseqult from ws.sql

 let ws.sql = "delete from datmsrvjit      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmsrvjit from ws.sql

 let ws.sql = "delete from datmsrvretexc      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmsrvretexc from ws.sql

 let ws.sql = "delete from datmtrxfila      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmtrxfila from ws.sql

 let ws.sql = "delete from datmvclapltrc      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmvclapltrc from ws.sql

 let ws.sql = "delete from datmvistoria      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmvistoria from ws.sql

 let ws.sql = "delete from datmvstcanc      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datmvstcanc from ws.sql

 let ws.sql = "delete from datratdmltsrv      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datratdmltsrv from ws.sql

 let ws.sql = "delete from datrligtrp      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datrligtrp from ws.sql

 let ws.sql = "delete from datrsrvcnd      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datrsrvcnd from ws.sql

 let ws.sql = "delete from datrsrvpbm      ",
              " where atdsrvnum = ? and ",
              "       atdsrvano = ?     "
 prepare del_datrsrvpbm from ws.sql

 let ws.sql = "delete from datmligatd   ",
              " where lignum = ?     "
 prepare del_datmligatd from ws.sql

 let ws.sql = "delete from datrligagn ",
              " where lignum = ? 	 "
 prepare del_datrligagn from ws.sql

 let ws.sql = "delete from datrligcgccpf      ",
              " where lignum = ? 	  "
 prepare del_datrligcgccpf from ws.sql

 let ws.sql = "delete from datrligcnslig      ",
              " where lignum = ? "
 prepare del_datrligcnslig from ws.sql

 let ws.sql = "delete from datrligcor      ",
              " where lignum = ?    "
 prepare del_datrligcor from ws.sql

 let ws.sql = "delete from datrligmat      ",
              " where lignum = ? "
 prepare del_datrligmat from ws.sql

 let ws.sql = "delete from datrligppt      ",
              " where lignum = ? "
 prepare del_datrligppt from ws.sql

 let ws.sql = "delete from datrligrcuccsmtv      ",
              " where lignum = ? "
 prepare del_datrligrcuccsmtv from ws.sql

 let ws.sql = "delete from datrligsin      ",
              " where lignum = ? "
 prepare del_datrligsin from ws.sql

 let ws.sql = "delete from datrligtel      ",
              " where lignum = ? "
 prepare del_datrligtel from ws.sql

 let ws.sql = "delete from datrligtrpavb      ",
              " where lignum = ? "
 prepare del_datrligtrpavb from ws.sql

 let ws.sql = "delete from datrdrscrsagdlig ",
              " where lignum = ? 	 "
 prepare del_datrdrscrsagdlig from ws.sql

 let ws.sql = "select datrligsrv.atdsrvnum,  ",
              "       datrligsrv.atdsrvano   ",
              "  from datrligsrv, datmservico",
              " where datrligsrv.lignum    = ?                      and",
              "       datrligsrv.atdsrvnum = datmservico.atdsrvnum  and",
              "       datrligsrv.atdsrvano = datmservico.atdsrvano     "
 prepare sel_datmservico from ws.sql
 declare c_datmservico cursor with hold for sel_datmservico

 let ws.sql = "insert into datmlimpeza",
              "       (atdsrvnum, atdsrvano, excflg, atldat, atlhor)",
              "values (?, ?, 'S', ?, ?)"
 prepare ins_datmlimpeza from ws.sql

 let ws.sql = "update work:datmlimplig",
              "   set ligexcflg = 'S' ",
              " where lignum = ? "
 prepare upd_datmlimplig from ws.sql

#--------------------------------------------------------------------------
# Le o arquivo DATMLIMPLIG (work) e remove os dados gravados anteriormente.
#--------------------------------------------------------------------------

 declare c_bdata038 cursor with hold for
    select lignum, ligexcflg
      from work:datmlimplig
       for update

 foreach c_bdata038 into d_bdata038.lignum   ,
                         d_bdata038.ligexcflg

    if d_bdata038.ligexcflg = "S"  then
       continue foreach
    end if

    open  c_datmservico using d_bdata038.lignum
    fetch c_datmservico into  d_bdata038.atdsrvnum,
                              d_bdata038.atdsrvano

    if sqlca.sqlcode = 0  then
       let ws.srvexcflg = true
    else
       let ws.srvexcflg = false
    end if
    close c_datmservico

    let arr_aux = 1

    begin work
       execute del_datmligacao  using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0  then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMLIGACAO!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute del_datrligapol   using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGAPOL!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute del_datrligpac    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGPAC!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute del_datrligprp    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGPRP!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute del_datmlighist  using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0  then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMLIGHIST!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute del_datrligmens   using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGMENS!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute del_datrligsrv    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGSRV!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute del_datrligsinvst using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGSINVST!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute del_datrligsinavs using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGSINAVS!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute del_datmreclam    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMRECLAM!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute del_datmsitrecl   using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSITRECL!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute del_datmligfrm    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMLIGFRM!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

	 execute del_datmligatd    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMLIGATD!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

	 execute del_datrligagn   using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGAGN!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

	 execute del_datrligcgccpf    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGCGCCPF!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

	 execute del_datrligcnslig    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGCNSLIG!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1


	 execute del_datrligcor    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGCOR!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1


	 execute del_datrligmat    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGMAT!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1


	 execute del_datrligppt    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGPPT!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1


	 execute del_datrligrcuccsmtv    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGRCUCCSMTV!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1


	 execute del_datrligsin    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGSIN!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1


	 execute del_datrligtel    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGTEL!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1


	 execute del_datrligtrpavb    using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGTRPAVB!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1


       execute del_datrdrscrsagdlig   using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGCURSO!"
          rollback work
          exit program (1)
       end if

       let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
       let arr_aux = arr_aux + 1

       execute upd_datmlimplig  using  d_bdata038.lignum
       if sqlca.sqlcode  <>  0   then
          display "Erro (", sqlca.sqlcode, ") na atualizacao da tabela DATMLIMPLIG!"
          rollback work
          exit program (1)
       end if

#--------------------------------------------------------------------------
# Remove registros das tabelas de servicos relacionados a ligacao, se houver
#--------------------------------------------------------------------------

       if ws.srvexcflg = true  then
          execute del_datmservico using d_bdata038.atdsrvnum,
                                        d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSERVICO!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datrservapol using d_bdata038.atdsrvnum,
                                         d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRSERVAPOL!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmservhist using d_bdata038.atdsrvnum,
                                         d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSERVHIST!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmservicocmp using d_bdata038.atdsrvnum,
                                           d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSERVICOCMP!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmsrvacp using d_bdata038.atdsrvnum,
                                       d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSRVACP!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmpesquisa using d_bdata038.atdsrvnum,
                                         d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMPESQUISA!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datrpesqaval using d_bdata038.atdsrvnum,
                                         d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRPESQAVAL!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmpesqhist using d_bdata038.atdsrvnum,
                                         d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMPESQHIST!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmtrajeto using d_bdata038.atdsrvnum,
                                        d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMTRAJETO!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmavisrent using d_bdata038.atdsrvnum,
                                         d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMAVISRENT!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmalugveic using d_bdata038.atdsrvnum,
                                         d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMALUGVEIC!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmprorrog using d_bdata038.atdsrvnum,
                                        d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMPRORROG!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_dblmpagto using d_bdata038.atdsrvnum,
                                      d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DBLMPAGTO!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_dblmpagitem using d_bdata038.atdsrvnum,
                                        d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DBLMPAGITEM!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmassistpassag using d_bdata038.atdsrvnum,
                                             d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMASSISTPASSAG!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmpassageiro using d_bdata038.atdsrvnum,
                                           d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMPASSAGEIRO!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmsrvre using d_bdata038.atdsrvnum,
                                      d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSRVRE!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datrsrvvstsin using d_bdata038.atdsrvnum,
                                          d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRSRVVSTSIN!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmlcl using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMLCL!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmtrptaxi using d_bdata038.atdsrvnum,
                                        d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMTRPTAXI!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmtrppsgaer using d_bdata038.atdsrvnum,
                                          d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMTRPPSGAER!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmhosped using d_bdata038.atdsrvnum,
                                       d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMHOSPED!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

          execute del_datmrpt using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMRPT!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmavssin using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMAVSSIN!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmcntsrv using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMCNTSRV!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmmdtsrv using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMMDTSRV!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmpreacp using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMPREACP!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmsrvanlhst using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSRVANLHST!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmsrvint using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSRVINT!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmsrvintale using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSRVINTALE!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmsrvintcmp using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSRVINTCMP!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmsrvintseqult using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSRVINTSEQULT!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmsrvjit using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSRVJIT!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmsrvretexc using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMSRVRETEXC!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmtrxfila using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMTRXFILA!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmvclapltrc using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMVCLAPLTRC!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmvistoria using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMVISTORIA!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datmvstcanc using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATMVSTCANC!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datratdmltsrv using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRATDMLTSRV!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datrligtrp using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRLIGTRP!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datrsrvcnd using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRSRVCND!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

 	    execute del_datrsrvpbm using d_bdata038.atdsrvnum,
                                    d_bdata038.atdsrvano
          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na delecao da tabela DATRSRVPBM!"
             rollback work
             exit program (1)
          end if

          let a_bdata038[arr_aux].qtdexc = a_bdata038[arr_aux].qtdexc + sqlca.sqlerrd[3]
          let arr_aux = arr_aux + 1

#--------------------------------------------------------------------------
# Grava tabela de controle de servicos removidos
#--------------------------------------------------------------------------

          let ws.atldat = today
          let ws.atlhor = current hour to minute

          execute ins_datmlimpeza using d_bdata038.atdsrvnum,
                                        d_bdata038.atdsrvano,
                                        ws.atldat, ws.atlhor

          if sqlca.sqlcode <> 0  then
             display "Erro (", sqlca.sqlcode, ") na gravacao da tabela DATMLIMPEZA!"
             rollback work
             exit program (1)
          end if
       end if

    commit work

 end foreach

#----------------------------------------------------------
# Atualiza STATISTICS
#----------------------------------------------------------

 #update statistics for table  datmligacao   # - Chamado: 8079800                   
 #update statistics for table  datrligapol   # - Amarildo disse que é feito   
 #update statistics for table  datrligpac    # Update Statistic semanalmente. 
 #update statistics for table  datrligprp
 #update statistics for table  datmlighist
 #update statistics for table  datrligmens
 #update statistics for table  datrligsrv
 #update statistics for table  datrligsinvst
 #update statistics for table  datrligsinavs
 #update statistics for table  datmreclam
 #update statistics for table  datmsitrecl
 #update statistics for table  datmligfrm
 #
 #update statistics for table  datmservico
 #update statistics for table  datrservapol
 #update statistics for table  datmservhist
 #update statistics for table  datmservicocmp
 #update statistics for table  datmsrvacp
 #update statistics for table  datmpesquisa
 #update statistics for table  datrpesqaval
 #update statistics for table  datmpesqhist
 #update statistics for table  datmtrajeto
 #update statistics for table  datmavisrent
 #update statistics for table  datmalugveic
 #update statistics for table  datmprorrog
 #update statistics for table  dblmpagto
 #update statistics for table  dblmpagitem
 #update statistics for table  datmassistpassag
 #update statistics for table  datmpassageiro
 #update statistics for table  datmsrvre
 #update statistics for table  datrsrvvstsin
 #update statistics for table  datmlcl
 #update statistics for table  datmtrptaxi
 #update statistics for table  datmtrppsgaer
 #update statistics for table  datmhosped
 #update statistics for table  datmrpt
 #update statistics for table  datmavssin
 #update statistics for table  datmcntsrv
 #update statistics for table  datmpreacp
 #update statistics for table  datmsrvanlhst
 #update statistics for table  datmsrvint
 #update statistics for table  datmsrvintale
 #update statistics for table  datmsrvintcmp
 #update statistics for table  datmsrvintseqult
 #update statistics for table  datmsrvjit
 #update statistics for table  datmsrvretexc
 #update statistics for table  datmtrxfila
 #update statistics for table  datmvclapltrc
 #update statistics for table  datmvistoria
 #update statistics for table  datmvstcanc
 #update statistics for table  datratdmltsrv
 #update statistics for table  datrsrvcnd
 #update statistics for table  datrsrvpbm
 #update statistics for table  datmligatd
 #update statistics for table  datrligcgccpf
 #update statistics for table  datrligcnslig
 #update statistics for table  datrligcor
 #update statistics for table  datrligmat
 #update statistics for table  datrligppt
 #update statistics for table  datrligprp
 #update statistics for table  datrligrcuccsmtv
 #update statistics for table  datrligsin
 #update statistics for table  datrligtel
 #update statistics for table  datrligtrpavb

 #----------------------------------------------
 # Atualiza STATISTICS das tabelas do banco U18W
 #----------------------------------------------
 call fun_dba_abre_banco("GUINCHOGPS")

 #update statistics for table datmmdtsrv

#--------------------------------------------------------------------------
# Exibe total de registros removidos por tabela
#--------------------------------------------------------------------------

 display "                                 "
 display " <<< RESUMO DE PROCESSAMENTO >>> "
 display "                                 "
 display " TABELA               QUANTIDADE "
 display " ------------------------------- "
 # for arr_aux = 1 to 35
 for arr_aux = 1 to 68
    display " ", a_bdata038[arr_aux].tabnom, " ", a_bdata038[arr_aux].qtdexc using "##,###,##&"
 end for
 display " -----------------------fim----- "
 display " "

#----------------------------------------------------------
# Apos finalizacao do processo, 'dropa' tabela do WORK
#----------------------------------------------------------

 close database
 database work

 call DB_drop()

end function   ###  bdata038

#----------------------------------------------------------
 function DB_drop()
#----------------------------------------------------------

 drop table datmlimplig

 if sqlca.sqlcode <> 0 then
    display "*** ERRO (", sqlca.sqlcode, ") na exclusao da tabela! ***"
    exit program (1)
 end if

end function  ###  DB_drop
