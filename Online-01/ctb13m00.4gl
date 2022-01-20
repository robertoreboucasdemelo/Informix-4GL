#############################################################################
# Nome do Modulo: CTB13M00                                         Pedro    #
#                                                                  Marcelo  #
# Horarios e kilometragens da frota-porto                          Dez/1994 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6480-7   Gilberto     Alteracao do limite maximo de valor #
#                                       de $150,00 para $100,00 e inclusao  #
#                                       do limite minimo de valor de $30,00.#
#                                       Gravacao dos dados do array dentro  #
#                                       de uma unica transacao, apos a con- #
#                                       firmacao pelo usuario.              #
#---------------------------------------------------------------------------#
# 03/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
#                                       para verificacao do servico.        #
#---------------------------------------------------------------------------#
# 13/09/1999               Gilberto     Retirada das observacoes do trajeto #
#---------------------------------------------------------------------------#
# 14/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# --------   ------------- --------  ---------------------------------------#
# 18/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.             #
#---------------------------------------------------------------------------#


 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define a_ctb13m00 array[09]  of record
    trjnumseq      like datmtrajeto.trjnumseq,
    trjorghor      like datmtrajeto.trjorghor,
    trjorgkmt      like datmtrajeto.trjorgkmt,
    trjdsthor      like datmtrajeto.trjdsthor,
    trjdstkmt      like datmtrajeto.trjdstkmt,
    trjorglcl      like datmtrajeto.trjorglcl,
    trjdstlcl      like datmtrajeto.trjdstlcl
 end record

 define valor      record
    trbhor         dec(10,5)                 ,
    gchkmt         dec(10,5)                 ,
    vclkmt         dec(10,5)
 end record

 define sql_select char(250)
 define arr_aux    smallint
 define scr_aux    smallint


#-----------------------------------------------------------
 function ctb13m00()
#-----------------------------------------------------------

 if not get_niv_mod(g_issk.prgsgl, "ctb13m00") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 select grlinf [1,16]
   into valor.trbhor
   from igbkgeral
  where mducod = "C24"         and
        grlchv = "HORA-TRABALHADA"

 if sqlca.sqlcode = notfound  then
    error " Valor da HORA TRABALHADA nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 select grlinf [1,16]
   into valor.gchkmt
   from igbkgeral
  where mducod = "C24"    and
        grlchv = "KM-GUINCHO"

  if sqlca.sqlcode = notfound  then
    error " Valor do KM PARA GUINCHO nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 select grlinf [1,16]
   into valor.vclkmt
   from igbkgeral
  where mducod = "C24"    and
        grlchv = "KM-VEICULO"

 if sqlca.sqlcode = notfound  then
    error " Valor do KM PARA VEICULO nao encontrado. AVISE A INFORMATICA!"
    return
 end if

#----------------------------------------
# PREPARA COMANDO SQL
#----------------------------------------
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

 let sql_select = "select atdetpdes    ",
                  "  from datketapa    ",
                  " where atdetpcod = ?"
 prepare sel_datketapa from sql_select
 declare c_datketapa cursor for sel_datketapa


 open window ctb13m00 at 04,02 with form "ctb13m00"
                         attribute (form line 1)

 menu "TRAJETOS"

    before menu
       hide option all

       if g_issk.acsnivcod >= g_issk.acsnivcns  then
          show option "Seleciona", "Consulta"
       end if

       if g_issk.acsnivcod >= g_issk.acsnivatl  then
          show option "Seleciona", "Modifica", "Consulta"
       end if

       show option "Encerra"

    command key ("S") "Seleciona" "Seleciona horario-kilometragem"
       clear form
       call ctb13m00_serv("S")
       clear form

    command key ("M") "Modifica"  "Modifica horario-kilometragem"
       clear form
       call ctb13m00_serv("M")
       clear form

    command key ("C") "Consulta"  "Consulta servicos sem quilometragem digitada"
       call ctb13m01()

    command key (interrupt, E )  "Encerra"
       "Retorna ao Menu Anterior"
       exit menu

 end menu

 let int_flag = false
 close window ctb13m00

 end function  ###  ctb13m00


#-----------------------------------------------------------
 function ctb13m00_serv(par_operacao)
#-----------------------------------------------------------
 define par_operacao  char(01)

 define d_ctb13m00 record
    atdsrvnum      like datmtrajeto.atdsrvnum,
    atdsrvano      like datmtrajeto.atdsrvano,
    atdfnlflg      like datmservico.atdfnlflg,
    sitdes         char (10)                 ,
    atdprscod      like gkpkpos.pstcoddig    ,
    nomrazsoc      like gkpkpos.nomrazsoc    ,
    srrcoddig      like datmservico.srrcoddig,
    srrabvnom      like datksrr.srrabvnom    ,
    atdvclsgl      like datmservico.atdvclsgl,
    socvclcod      like datmservico.socvclcod,
    vcldes         char (30)                 ,
    atdcstvlr      like datmservico.atdcstvlr
 end record

 define ws         record
    atdsrvorg      like datmservico.atdsrvorg,
    atddat         like datmservico.atddat   ,
    atdmotnom      like datmservico.atdmotnom,
    vclcoddig      like datkveiculo.vclcoddig,
    pstcoddig      like datkveiculo.pstcoddig,
    socoprsitcod   like datkveiculo.socoprsitcod,
    atdetpcod      like datmsrvacp.atdetpcod,
    srrstt         like datksrr.srrstt
 end record


 while true

    initialize ws.*          to null
    initialize a_ctb13m00    to null
    initialize d_ctb13m00.*  to null
    display by name d_ctb13m00.*

    let int_flag   =  false
    let arr_aux = 1

    input by name d_ctb13m00.atdsrvnum,
                  d_ctb13m00.atdsrvano,
                  d_ctb13m00.srrcoddig,
                  d_ctb13m00.atdvclsgl

       before field atdsrvnum
          initialize ws.atdsrvorg   to null
          display by name ws.atdsrvorg
          display by name d_ctb13m00.atdsrvnum  attribute (reverse)

       after field atdsrvnum
          display by name d_ctb13m00.atdsrvnum

          if d_ctb13m00.atdsrvnum  is null   then
             error " Numero do servico deve ser informado!"
             next field atdsrvnum
          end if

       before field atdsrvano
          display by name d_ctb13m00.atdsrvano  attribute (reverse)

       after field atdsrvano
          display by name d_ctb13m00.atdsrvano

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdsrvnum
          end if

          if d_ctb13m00.atdsrvano  is null   then
             error " Ano do servico deve ser informado!"
             next field atdsrvano
          end if

          #---------------------------------------------------------
          # Dados do servico realizado
          #---------------------------------------------------------
          select datmservico.atdprscod,
                 datmservico.srrcoddig,
                 datmservico.atdmotnom,
                 datmservico.atdvclsgl,
                 datmservico.socvclcod,
                 datmservico.atdfnlflg,
                 datmservico.atdcstvlr,
                 datmservico.atdsrvorg,
                 datmservico.atddat
            into d_ctb13m00.atdprscod,
                 d_ctb13m00.srrcoddig,
                 ws.atdmotnom,
                 d_ctb13m00.atdvclsgl,
                 d_ctb13m00.socvclcod,
                 d_ctb13m00.atdfnlflg,
                 d_ctb13m00.atdcstvlr,
                 ws.atdsrvorg        ,
                 ws.atddat
            from datmservico
           where datmservico.atdsrvnum = d_ctb13m00.atdsrvnum
             and datmservico.atdsrvano = d_ctb13m00.atdsrvano

          if sqlca.sqlcode = notfound  then
             error " Servico nao cadastrado!"
             next field atdsrvnum
          end if

          display by name ws.atdsrvorg

          if ws.atdsrvorg  <> 13  and
             ws.atdsrvorg  <>  4  and
             ws.atdsrvorg  <>  6  and
             ws.atdsrvorg  <>  1  and
             ws.atdsrvorg  <>  5  and
             ws.atdsrvorg  <>  7  and
             ws.atdsrvorg  <> 17  and  #Replace - RPT s/ docto
             ws.atdsrvorg  <>  9  then
             error " Servico nao tem acionamento de prestador/frota!"
             next field atdsrvnum
          end if

          if d_ctb13m00.atdprscod  <>  1   and
             d_ctb13m00.atdprscod  <>  4   and
             d_ctb13m00.atdprscod  <>  8   then
             error " Servico nao foi realizado pela Frota Porto Seguro!"
             next field atdsrvnum
          end if

          if par_operacao  =  "M"   then
             if ctb13m00_data(ws.atddat) = false  then
                error " ATENCAO! Servico realizado no mes anterior!"
#               error " Servico realizado no mes anterior nao pode ser digitado!"
#               next field atdsrvnum
             end if
          end if

          if ws.atdmotnom  is not null   and
             ws.atdmotnom  <>  "  "      then
             let d_ctb13m00.srrabvnom  =  ws.atdmotnom
          else
             if d_ctb13m00.srrcoddig  is not null   then
                select srrabvnom
                  into d_ctb13m00.srrabvnom
                  from datksrr
                 where srrcoddig  =  d_ctb13m00.srrcoddig
             end if
          end if

          #------------------------------------------------------------
          # Verifica finalizacao/etapa do servico
          #------------------------------------------------------------
          if d_ctb13m00.atdfnlflg  = "N"     then
             error " Servico nao foi concluido!"
             next field atdsrvano
          end if

          open  c_datmsrvacp using d_ctb13m00.atdsrvnum, d_ctb13m00.atdsrvano,
                                   d_ctb13m00.atdsrvnum, d_ctb13m00.atdsrvano
          fetch c_datmsrvacp into  ws.atdetpcod
          close c_datmsrvacp

          if sqlca.sqlcode = 0  then
             open  c_datketapa using ws.atdetpcod
             fetch c_datketapa into  d_ctb13m00.sitdes
             close c_datketapa
            else
             let d_ctb13m00.sitdes = "N/PREVISTO"
          end if

          if ws.atdetpcod  =  1    or
             ws.atdetpcod  =  2    or
             ws.atdetpcod  =  6    or
             ws.atdetpcod  =  7    or
             ws.atdetpcod  =  13   then
             error " Situacao do servico nao permite digitacao de trajeto!"
             next field atdsrvano
          end if

          #---------------------------------------------------------
          # Razao social do prestador
          #---------------------------------------------------------
          select nomrazsoc
            into d_ctb13m00.nomrazsoc
            from dpaksocor
           where pstcoddig = d_ctb13m00.atdprscod

          #---------------------------------------------------------
          # Descricao do veiculo
          #---------------------------------------------------------
          if d_ctb13m00.socvclcod  is not null   then
             select vclcoddig,
                    atdvclsgl
               into ws.vclcoddig,
                    d_ctb13m00.atdvclsgl
               from datkveiculo
              where datkveiculo.socvclcod  =  d_ctb13m00.socvclcod

             if sqlca.sqlcode  <>  0   then
                error " Veiculo nao encontrado. AVISE INFORMATICA!"
                return
             end if

             call cts15g00(ws.vclcoddig)  returning d_ctb13m00.vcldes
          end if


          display by name  d_ctb13m00.*
          display by name  d_ctb13m00.sitdes  attribute(reverse)

          if d_ctb13m00.atdvclsgl  is not null   and
             d_ctb13m00.atdvclsgl  <> " "        and
             ws.atdmotnom          is not null   and
             ws.atdmotnom          <> " "        then
             exit input
          end if

          if d_ctb13m00.atdvclsgl  is not null   and
             d_ctb13m00.atdvclsgl  <> " "        and
             d_ctb13m00.srrcoddig  is not null   and
             d_ctb13m00.srrcoddig  <> " "        then
             exit input
          end if

       before field srrcoddig
          display by name d_ctb13m00.srrcoddig attribute (reverse)

       after field srrcoddig
          display by name d_ctb13m00.srrcoddig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdsrvano
          end if

          #-----------------------------------------------------------------
          # Verifica socorrista
          #-----------------------------------------------------------------
          initialize d_ctb13m00.srrabvnom  to null
          initialize ws.pstcoddig          to null
          initialize ws.srrstt             to null

          if d_ctb13m00.srrcoddig  is null   then
             error " Socorrista deve ser informado!"
             call ctn45c00(d_ctb13m00.atdprscod, "")
                  returning d_ctb13m00.srrcoddig
             next field srrcoddig
          end if

          select srrabvnom,
                 srrstt
            into d_ctb13m00.srrabvnom,
                 ws.srrstt
            from datksrr
           where srrcoddig  =  d_ctb13m00.srrcoddig

          if sqlca.sqlcode  =  notfound   then
             error " Socorrista nao cadastrado!"
             call ctn45c00(d_ctb13m00.atdprscod, "")
                  returning d_ctb13m00.srrcoddig
             next field srrcoddig
          end if
          display by name d_ctb13m00.srrabvnom

          if ws.srrstt  <>  1   then
             error " Socorrista bloqueado/cancelado!"
             next field srrcoddig
          end if

          declare c_datrsrrpst  cursor for
            select pstcoddig, vigfnl
              from datrsrrpst
             where srrcoddig  =  d_ctb13m00.srrcoddig
             order by vigfnl desc

          open  c_datrsrrpst
          fetch c_datrsrrpst  into  ws.pstcoddig
          close c_datrsrrpst

          if ws.pstcoddig  is null   then
             error " Socorrista nao possui vinculo com nenhum prestador!"
             next field srrcoddig
          end if

          if d_ctb13m00.atdprscod  <>  ws.pstcoddig   then
             error " Socorrista nao esta vinculado a este prestador!"
             next field srrcoddig
          end if

       before field atdvclsgl
          display by name d_ctb13m00.atdvclsgl  attribute (reverse)

       after field atdvclsgl
          display by name d_ctb13m00.atdvclsgl

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field srrcoddig
          end if

          if d_ctb13m00.atdvclsgl  is null   or
             d_ctb13m00.atdvclsgl  =  "  "   then
             error " Sigla do veiculo deve ser informada!"
             next field atdvclsgl
          end if

          #---------------------------------------------------------
          # Descricao do veiculo
          #---------------------------------------------------------
          select socvclcod,
                 pstcoddig,
                 socoprsitcod,
                 vclcoddig
            into d_ctb13m00.socvclcod,
                 ws.pstcoddig,
                 ws.socoprsitcod,
                 ws.vclcoddig
            from datkveiculo
           where datkveiculo.atdvclsgl  =  d_ctb13m00.atdvclsgl

          if sqlca.sqlcode  <>  0   then
             error " Veiculo nao cadastrado!"
             next field atdvclsgl
          end if

          if ws.pstcoddig  <>  d_ctb13m00.atdprscod   then
             error " Prestador do veiculo e do servico sao diferentes!"
             next field atdvclsgl
          end if

          if ws.socoprsitcod  <>  1   then
             error " Veiculo bloqueado ou cancelado!"
             next field atdvclsgl
          end if

          call cts15g00(ws.vclcoddig)  returning d_ctb13m00.vcldes

          display by name d_ctb13m00.socvclcod
          display by name d_ctb13m00.vcldes

          #---------------------------------------------------------
          # Grava dados do servico (Veiculo/Motorista)
          #---------------------------------------------------------
          update datmservico set ( srrcoddig,
                                   socvclcod )
                              =  ( d_ctb13m00.srrcoddig,
                                   d_ctb13m00.socvclcod )
           where datmservico.atdsrvnum = d_ctb13m00.atdsrvnum
             and datmservico.atdsrvano = d_ctb13m00.atdsrvano

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") na atualizacao do motorista/veiculo da frota. AVISE A INFORMATICA!"
             return
          else
             call cts00g07_apos_grvlaudo(d_ctb13m00.atdsrvnum,d_ctb13m00.atdsrvano)
          end if

       on key (interrupt)
          exit input

    end input

    if int_flag  then
       exit while
    end if

    declare  c_ctb13m00     cursor for
       select trjnumseq, trjorghor, trjorgkmt, trjdsthor,
              trjdstkmt, trjorglcl, trjdstlcl
         from datmtrajeto
        where atdsrvnum = d_ctb13m00.atdsrvnum   and
              atdsrvano = d_ctb13m00.atdsrvano

    let arr_aux = 1

    foreach c_ctb13m00 into a_ctb13m00[arr_aux].trjnumseq,
                            a_ctb13m00[arr_aux].trjorghor,
                            a_ctb13m00[arr_aux].trjorgkmt,
                            a_ctb13m00[arr_aux].trjdsthor,
                            a_ctb13m00[arr_aux].trjdstkmt,
                            a_ctb13m00[arr_aux].trjorglcl,
                            a_ctb13m00[arr_aux].trjdstlcl

       let arr_aux = arr_aux + 1

       if arr_aux > 09  then
          error " Limite excedido! Existem mais de 9 trajetos para este servico!"
          exit foreach
       end if

    end foreach

    call set_count(arr_aux-1)

    for arr_aux = 1  to  5
       if a_ctb13m00[arr_aux].trjnumseq is null   then
          exit for
       end if

       display a_ctb13m00[arr_aux].* to s_ctb13m00[arr_aux].*
    end for

    if par_operacao = "M"  then
       if d_ctb13m00.atdvclsgl  is null   then
          error " Sigla nao encontrada. AVISE A INFORMATICA!"
       else
          if ctb13m00_kmt(d_ctb13m00.atdsrvnum,
                          d_ctb13m00.atdsrvano,
                          d_ctb13m00.atdvclsgl) = false then
             return
          end if
       end if
    else
       display array a_ctb13m00 to s_ctb13m00.*
          on key (interrupt)
             exit display
       end display
    end if

    for arr_aux = 1  to  5
        clear s_ctb13m00[arr_aux].trjnumseq
        clear s_ctb13m00[arr_aux].trjorghor
        clear s_ctb13m00[arr_aux].trjorgkmt
        clear s_ctb13m00[arr_aux].trjdsthor
        clear s_ctb13m00[arr_aux].trjdstkmt
        clear s_ctb13m00[arr_aux].trjorglcl
        clear s_ctb13m00[arr_aux].trjdstlcl
    end for

    if int_flag  then
       exit while
    end if
 end while

 end function  ###  ctb13m00_serv

#---------------------------------------------------------------
 function ctb13m00_kmt(param)
#---------------------------------------------------------------

 define param     record
    atdsrvnum     like datmservico.atdsrvnum,
    atdsrvano     like datmservico.atdsrvano,
    atdvclsgl     like datmservico.atdvclsgl
 end record

 define ws        record
    h24           datetime hour to minute,
    valint        integer,
    fator         dec (5,3),
    totmin        dec (4,0),
    tothor        char (06),
    totkmt        like datmtrajeto.trjorgkmt,
    atdcstvlr     like datmservico.atdcstvlr,
    inckmt        like datmtrajeto.trjorgkmt,
    fnlkmt        like datmtrajeto.trjdstkmt,
    inchor        datetime hour to minute,
    fnlhor        datetime hour to minute,
    ultseq        like datmtrajeto.trjnumseq,
    operacao      char (01),
    confirma      char (01)
 end record

 options insert key F35

 input array a_ctb13m00 without defaults from s_ctb13m00.*

    before row
       let arr_aux = arr_curr()
       let scr_aux = scr_line()
       if arr_aux <= arr_count()  then
          let ws.operacao = "i"
       else
          let ws.operacao = "a"
       end if

       if a_ctb13m00[arr_aux + 1].trjorghor is null  and
          a_ctb13m00[arr_aux + 1].trjdsthor is null  and
          a_ctb13m00[arr_aux + 1].trjorgkmt is null  and
          a_ctb13m00[arr_aux + 1].trjdstkmt is null  then
          options delete key f2
       else
          options delete key F36
       end if

    before insert
       let ws.operacao = "i"
       initialize a_ctb13m00[arr_aux].*  to  null
       display a_ctb13m00[arr_aux].* to s_ctb13m00[scr_aux].*

    before field trjorghor
       display a_ctb13m00[arr_aux].trjorghor to
               s_ctb13m00[scr_aux].trjorghor attribute (reverse)

    after field trjorghor
       display a_ctb13m00[arr_aux].trjorghor to
               s_ctb13m00[scr_aux].trjorghor

       if fgl_lastkey() = fgl_keyval("up")       and
          a_ctb13m00[arr_aux].trjorghor is null  and
          ws.operacao = "i"                      then
          initialize ws.operacao to null
          initialize a_ctb13m00[arr_aux] to null
          display a_ctb13m00[arr_aux].* to s_ctb13m00[scr_aux].*
       else
          if a_ctb13m00[arr_aux].trjorghor is null  then
             error " Horario de saida deve ser informado!"
             next field trjorghor
          end if
       end if

    before field trjorgkmt
       display a_ctb13m00[arr_aux].trjorgkmt to
               s_ctb13m00[scr_aux].trjorgkmt attribute (reverse)

    after field trjorgkmt
       display a_ctb13m00[arr_aux].trjorgkmt to
               s_ctb13m00[scr_aux].trjorgkmt

       if fgl_lastkey()  =  fgl_keyval("left") then
          next field trjorghor
       end if

       if fgl_lastkey() = fgl_keyval("up")       and
          a_ctb13m00[arr_aux].trjorgkmt is null  and
          ws.operacao = "i"                      then
          initialize ws.operacao to null
          initialize a_ctb13m00[arr_aux] to null
          display a_ctb13m00[arr_aux].* to s_ctb13m00[scr_aux].*
       else
          if a_ctb13m00[arr_aux].trjorgkmt is null  then
             error " KM de saida deve ser informado!"
             next field trjorgkmt
          end if
       end if

       if a_ctb13m00[arr_aux].trjorghor is not null  and
          a_ctb13m00[arr_aux].trjorgkmt is null      then
          error " KM de saida deve ser informado!"
          next field trjorgkmt
       end if

       if a_ctb13m00[arr_aux].trjorgkmt  is not null   and
          arr_aux  >  1                                then

          if a_ctb13m00[arr_aux].trjorgkmt <> a_ctb13m00[arr_aux - 1].trjdstkmt   then
             error " KM de saida diferente de KM de destino anterior!"
             next field trjorgkmt
          end if
       end if

    before field trjdsthor
       display a_ctb13m00[arr_aux].trjdsthor to
               s_ctb13m00[scr_aux].trjdsthor attribute (reverse)

    after field trjdsthor
       display a_ctb13m00[arr_aux].trjdsthor to
               s_ctb13m00[scr_aux].trjdsthor

       if fgl_lastkey()  =  fgl_keyval("left") then
          next field trjorgkmt
       end if

       if fgl_lastkey() = fgl_keyval("up")       and
          a_ctb13m00[arr_aux].trjdsthor is null  and
          ws.operacao = "i"                      then
          initialize ws.operacao to null
          initialize a_ctb13m00[arr_aux] to null
          display a_ctb13m00[arr_aux].* to s_ctb13m00[scr_aux].*
       else
          if a_ctb13m00[arr_aux].trjdsthor is null  then
             error " Horario de chegada deve ser informado!"
             next field trjdsthor
          end if
       end if

    before field trjdstkmt
       display a_ctb13m00[arr_aux].trjdstkmt to
               s_ctb13m00[scr_aux].trjdstkmt attribute (reverse)

    after field trjdstkmt
       display a_ctb13m00[arr_aux].trjdstkmt to
               s_ctb13m00[scr_aux].trjdstkmt

       if fgl_lastkey()  =  fgl_keyval("left") then
          next field trjdsthor
       end if

       if fgl_lastkey() = fgl_keyval("up")       and
          a_ctb13m00[arr_aux].trjdstkmt is null  and
          ws.operacao = "i"                      then
          initialize ws.operacao to null
          initialize a_ctb13m00[arr_aux] to null
          display a_ctb13m00[arr_aux].* to s_ctb13m00[scr_aux].*
       else
          if a_ctb13m00[arr_aux].trjdstkmt is null  then
             error " KM de destino deve ser informado!"
             next field trjdstkmt
          end if
       end if

       if a_ctb13m00[arr_aux].trjdsthor is not null  and
          a_ctb13m00[arr_aux].trjdstkmt is null      then
          error " KM de destino deve ser informado!"
          next field trjdstkmt
       end if

       if a_ctb13m00[arr_aux].trjdstkmt  is not null  and
          a_ctb13m00[arr_aux].trjdstkmt < a_ctb13m00[arr_aux].trjorgkmt  then
          error " KM destino menor que KM origem!"
          next field trjdstkmt
       end if

    before field trjorglcl
        display a_ctb13m00[arr_aux].trjorglcl to
                s_ctb13m00[scr_aux].trjorglcl attribute (reverse)

    after field trjorglcl
       display a_ctb13m00[arr_aux].trjorglcl to
               s_ctb13m00[scr_aux].trjorglcl

       if fgl_lastkey()  =  fgl_keyval("up")   or
          fgl_lastkey()  =  fgl_keyval("left") then
          next field trjdstkmt
       end if

       if a_ctb13m00[arr_aux].trjorghor  is not null  and
          a_ctb13m00[arr_aux].trjorglcl  is null      then
          error " Trajeto inicial deve ser informado!"
          next field trjorglcl
       end if

    before field trjdstlcl
       display a_ctb13m00[arr_aux].trjdstlcl to
               s_ctb13m00[scr_aux].trjdstlcl attribute (reverse)

    after field trjdstlcl
       display a_ctb13m00[arr_aux].trjdstlcl to
               s_ctb13m00[scr_aux].trjdstlcl

       if fgl_lastkey()  =  fgl_keyval("up")   or
          fgl_lastkey()  =  fgl_keyval("left") then
          next field trjorglcl
        end if

        if a_ctb13m00[arr_aux].trjorghor  is not null  and
           a_ctb13m00[arr_aux].trjdstlcl  is null      then
           error " Trajeto final deve ser informado!"
           next field trjdstlcl
       end if

    after row
       let ws.operacao = " "

    on key (interrupt)
       initialize ws.inchor  to null
       initialize ws.fnlhor  to null

       let ws.totmin     = 0
       let ws.atdcstvlr  = 0
       let ws.inckmt     = 0
       let ws.fnlkmt     = 0

       for arr_aux = 1 to 9
          if a_ctb13m00[arr_aux].trjorghor is null  or
             a_ctb13m00[arr_aux].trjdsthor is null  or
             a_ctb13m00[arr_aux].trjorgkmt is null  or
             a_ctb13m00[arr_aux].trjdstkmt is null  then
             exit for
          end if

          if arr_aux = 1   then
             let ws.inckmt = a_ctb13m00[arr_aux].trjorgkmt
             let ws.inchor = a_ctb13m00[arr_aux].trjorghor
          end if
          let ws.fnlkmt = a_ctb13m00[arr_aux].trjdstkmt
          let ws.fnlhor = a_ctb13m00[arr_aux].trjdsthor
       end for

#---------------------------------------------------------------
# Calcula horas trabalhadas
#---------------------------------------------------------------

       if ws.inchor <= ws.fnlhor  then
          let ws.tothor = ws.fnlhor - ws.inchor
       else
          let ws.h24    = "23:59"
          let ws.tothor = ws.h24 - ws.inchor
          let ws.h24    = "00:00"
          let ws.tothor = ws.tothor + (ws.fnlhor - ws.h24) + "00:01"
       end if

       let ws.totmin    = (ws.tothor[2,3] * 60) + ws.tothor[5,6]

       let ws.fator     = ws.totmin / 60
       let ws.valint    = ws.fator * 100
       let ws.fator     = ws.valint / 100
       let ws.atdcstvlr = ws.atdcstvlr + (ws.fator  *  valor.trbhor)

#---------------------------------------------------------------
# Calcula quilometros rodados
#---------------------------------------------------------------

       let ws.totkmt = ws.fnlkmt - ws.inckmt

       if param.atdvclsgl[1,1] = "T"   then
          let ws.atdcstvlr = ws.atdcstvlr + (ws.totkmt * valor.vclkmt)
       else
          if param.atdvclsgl[1,1] = "G"   then
             let ws.atdcstvlr = ws.atdcstvlr + (ws.totkmt * valor.gchkmt)
          end if
       end if

       display ws.atdcstvlr  to  atdcstvlr attribute(reverse)

       if ws.atdcstvlr <  30.00  then
          call cts08g01("C","S","CONFIRA NOVAMENTE OS DADOS!","",
                                "VALOR DO SERVICO ESTA' ABAIXO DO",
                                "LIMITE MINIMO DE R$ 30,00 !")
               returning ws.confirma

          if ws.confirma = "N"  then
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
             next field trjorghor
          end if
       end if

       if ws.atdcstvlr > 100.00  then
          call cts08g01("C","S","CONFIRA NOVAMENTE OS DADOS!","",
                                "VALOR DO SERVICO ESTA' ACIMA DO",
                                "LIMITE MAXIMO DE R$ 100,00 !")
               returning ws.confirma

          if ws.confirma = "N"  then
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
             next field trjorghor
          end if
       end if

       exit input
 end input

 options insert key F1
 options delete key F2

 begin work

 delete from datmtrajeto
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na gravacao do trajeto. AVISE A INFORMATICA!"
    rollback work
    return false
 end if

 for arr_aux = 1 to 9
    if a_ctb13m00[arr_aux].trjorghor is null  or
       a_ctb13m00[arr_aux].trjdsthor is null  or
       a_ctb13m00[arr_aux].trjorgkmt is null  or
       a_ctb13m00[arr_aux].trjdstkmt is null  then
       exit for
    end if
    initialize ws.ultseq  to null

    select max(trjnumseq)
      into ws.ultseq
      from datmtrajeto
     where atdsrvnum = param.atdsrvnum   and
           atdsrvano = param.atdsrvano

    if ws.ultseq  is null   then
       let ws.ultseq = 1
    else
       let ws.ultseq = ws.ultseq + 1
    end if

    let a_ctb13m00[arr_aux].trjnumseq = ws.ultseq

    insert into datmtrajeto (atdsrvnum, atdsrvano, trjnumseq,
                             trjorghor, trjorgkmt, trjdsthor,
                             trjdstkmt, trjorglcl, trjdstlcl)
                values      (param.atdsrvnum,
                             param.atdsrvano,
                             ws.ultseq,
                             a_ctb13m00[arr_aux].trjorghor,
                             a_ctb13m00[arr_aux].trjorgkmt,
                             a_ctb13m00[arr_aux].trjdsthor,
                             a_ctb13m00[arr_aux].trjdstkmt,
                             a_ctb13m00[arr_aux].trjorglcl,
                             a_ctb13m00[arr_aux].trjdstlcl)

    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao do trajeto. AVISE A INFORMATICA!"
       rollback work
       return false
    end if
 end for

#---------------------------------------------------------
# Grava custo do servico
#---------------------------------------------------------

 update datmservico
    set atdcstvlr = ws.atdcstvlr
  where atdsrvnum = param.atdsrvnum   and
        atdsrvano = param.atdsrvano

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na gravacao do custo do servico. AVISE A INFORMATICA!"
    rollback work
    return false
 else
    commit work
    call cts00g07_apos_grvlaudo(param.atdsrvnum,param.atdsrvano)
    return true
 end if

end function  ###  ctb13m00_kmt

#-----------------------------------------------------------------------
 function ctb13m00_data(param)
#-----------------------------------------------------------------------

 define param   record
    atddat      like datmservico.atddat
 end record

 define ws      record
    data_aux    char (10),
    data_lmt    date
 end record

 initialize ws.*  to null

 let param.atddat = param.atddat + 30 units day
 let ws.data_aux  = param.atddat
 let ws.data_aux  = "02","/",ws.data_aux[4,5],"/",ws.data_aux[7,10]
 let ws.data_lmt  = ws.data_aux

 if today > ws.data_lmt  then
    return false
 else
    return true
 end if

end function  ###  ctb13m00_data
