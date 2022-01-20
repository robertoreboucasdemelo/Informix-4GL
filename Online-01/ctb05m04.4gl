#############################################################################
# Nome do Modulo: CTB05M04                                         Wagner   #
#                                                                           #
# Consulta distribuicao dos servicos por prestador                 Mar/2002 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

#------------------------------------------------------------------------
 function ctb05m04()
#------------------------------------------------------------------------

 define d_ctb05m04    record
    datapsq           date,
    datapsq_a         date,
    pstcodpsq         like dpaksocor.pstcoddig,
    claconcod         dec (1,0),
    clacondes         char(22)
 end record

 define a_ctb05m04    array[1500] of record
    pstcoddig         like dpaksocor.pstcoddig,
    nomgrr            like dpaksocor.nomgrr,
    endufd            like dpaksocor.endufd,
    endcid            like dpaksocor.endcid,
    srvtotqtd         dec (6,0)
 end record

 define ws            record
    comando1          char(800),
    comando2          char(400),
    prstotgrl         dec(6,0),
    srvtotgrl         dec(6,0)
 end record

 define arr_aux       smallint


 open window w_ctb05m04 at  06,02 with form "ctb05m04"
             attribute(form line first)

 set isolation to dirty read

 while true

    initialize ws.*          to null
    initialize a_ctb05m04    to null
    initialize d_ctb05m04.*  to null

    let int_flag     = false
    let arr_aux      = 1
    let ws.prstotgrl = 0
    let ws.srvtotgrl = 0

    input by name d_ctb05m04.*  without defaults

       before field datapsq
          if d_ctb05m04.datapsq  is null   then
             let d_ctb05m04.datapsq = today
          end if
          display by name d_ctb05m04.datapsq attribute (reverse)

       after  field datapsq
          display by name d_ctb05m04.datapsq

          if d_ctb05m04.datapsq  is null   then
             error " Data de atendimento inicial tem que ser informada!"
             next field datapsq
          end if
          if d_ctb05m04.datapsq  > today   then
             error " Data de atendimento nao deve ser maior que data atual!"
             next field datapsq
          end if

       before field datapsq_a
          if d_ctb05m04.datapsq_a  is null   then
             let d_ctb05m04.datapsq_a  = today
          end if
          display by name d_ctb05m04.datapsq_a attribute (reverse)

       after  field datapsq_a
          display by name d_ctb05m04.datapsq_a

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field datapsq
          end if
          if d_ctb05m04.datapsq_a  is null   then
             error " Data de atendimento final tem que ser informada!"
             next field datapsq_a
          end if
          if d_ctb05m04.datapsq_a  > today   then
             error " Data de atendimento final nao deve ser maior que data atual!"
             next field datapsq_a
          end if
          if d_ctb05m04.datapsq > d_ctb05m04.datapsq_a then
             error " Data de atendimanto inicial nao pode ser maior que data atendimento final!"
             next field datapsq_a
          end if
          if (d_ctb05m04.datapsq_a - d_ctb05m04.datapsq) > 31 then
             error " Periodo da pesquisa nao pode ser maior que 31 dias!"
             next field datapsq_a
          end if

       before field pstcodpsq
          display by name d_ctb05m04.pstcodpsq  attribute (reverse)

       after  field pstcodpsq
          display by name d_ctb05m04.pstcodpsq

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field datapsq_a
          end if

          if d_ctb05m04.pstcodpsq  is not null   then
             select pstcoddig
               from dpaksocor
              where dpaksocor.pstcoddig = d_ctb05m04.pstcodpsq

             if sqlca.sqlcode  =  notfound   then
                error " Codigo de prestador nao cadastrado!"
                next field pstcodpsq
             end if
          end if

          if d_ctb05m04.pstcodpsq  is not null   then
             initialize d_ctb05m04.claconcod  to null
             initialize d_ctb05m04.clacondes  to null

             display by name d_ctb05m04.claconcod
             display by name d_ctb05m04.clacondes
             exit input
          end if

       before field claconcod
          let d_ctb05m04.claconcod = 1
          let d_ctb05m04.clacondes = "QTDE SERVICOS"

          display by name d_ctb05m04.claconcod  attribute (reverse)
          display by name d_ctb05m04.clacondes

       after  field claconcod
          display by name d_ctb05m04.claconcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field pstcodpsq
          end if

          case d_ctb05m04.claconcod
             when  1  let d_ctb05m04.clacondes = "QTDE SERVICOS"
             when  2  let d_ctb05m04.clacondes = "UF/CIDADE PRESTADOR"
             otherwise
                  error " Classificacao: 1-Qtde servicos, 2-UF/Cidade prestador"
                  next field claconcod
          end case
          display by name d_ctb05m04.clacondes

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    #---------------------------------------------------------------
    # Monta cursor para pesquisa
    #---------------------------------------------------------------
    if d_ctb05m04.pstcodpsq   is not null   then
       let ws.comando2 = "  from datmservico, dpaksocor ",
                         " where datmservico.atddat    between ? and ?",
                         "   and datmservico.atdsrvorg in (9,13)",
                         "   and datmservico.atdfnlflg = 'S' ",
                         "   and datmservico.atdprscod = ? ",
                         "   and datmservico.srvprlflg = 'N'",
                         "   and dpaksocor.pstcoddig   = datmservico.atdprscod",
                         " group by datmservico.atdprscod, ",
                         "          dpaksocor.nomgrr, ",
                         "          dpaksocor.endufd, ",
                         "          dpaksocor.endcid  "
    else
       if d_ctb05m04.claconcod  =  1   then
          let ws.comando2 = "  from datmservico, dpaksocor ",
                         " where datmservico.atddat   between ? and ?",
                         "   and datmservico.atdsrvorg in (9,13)",
                         "   and datmservico.atdfnlflg = 'S' ",
                         "   and datmservico.srvprlflg = 'N'",
                         "   and dpaksocor.pstcoddig   = datmservico.atdprscod",
                         " group by datmservico.atdprscod, ",
                         "          dpaksocor.nomgrr, ",
                         "          dpaksocor.endufd, ",
                         "          dpaksocor.endcid  ",
                         " order by 5  desc "
       else
          let ws.comando2 = "  from datmservico, dpaksocor ",
                         " where datmservico.atddat   between ? and ?",
                         "   and datmservico.atdsrvorg in (9,13)",
                         "   and datmservico.atdfnlflg = 'S' ",
                         "   and datmservico.srvprlflg = 'N'",
                         "   and dpaksocor.pstcoddig   = datmservico.atdprscod",
                         " group by datmservico.atdprscod, ",
                         "          dpaksocor.nomgrr, ",
                         "          dpaksocor.endufd, ",
                         "          dpaksocor.endcid  ",
                         " order by 3, 4, 5 desc "
       end if
    end if

     let ws.comando1 = " select datmservico.atdprscod, ",
                       "        dpaksocor.nomgrr,      ",
                       "        dpaksocor.endufd,      ",
                       "        dpaksocor.endcid,      ",
                       "        count(*)               "

    message " Aguarde, pesquisando..."  attribute(reverse)
    let ws.comando1 = ws.comando1 clipped," ", ws.comando2

    prepare comando_aux from ws.comando1

    declare c_ctb05m04  cursor for  comando_aux

    if d_ctb05m04.pstcodpsq  is not null   then
       open  c_ctb05m04  using  d_ctb05m04.datapsq,
                                d_ctb05m04.datapsq_a,
                                d_ctb05m04.pstcodpsq
    else
       open  c_ctb05m04  using  d_ctb05m04.datapsq,
                                d_ctb05m04.datapsq_a
    end if

    foreach c_ctb05m04 into a_ctb05m04[arr_aux].pstcoddig,
                            a_ctb05m04[arr_aux].nomgrr,
                            a_ctb05m04[arr_aux].endufd,
                            a_ctb05m04[arr_aux].endcid,
                            a_ctb05m04[arr_aux].srvtotqtd

       let ws.prstotgrl = ws.prstotgrl + 1
       let ws.srvtotgrl = ws.srvtotgrl + a_ctb05m04[arr_aux].srvtotqtd

       let arr_aux = arr_aux + 1
       if arr_aux  >  1500   then
          error " Limite excedido, pesquisa com mais de 1500 prestadores!"
          exit foreach
       end if

    end foreach

    message ""
    if arr_aux  >  1   then
       display by name ws.prstotgrl
       display by name ws.srvtotgrl

       message " (F17)Abandona, (F8)Consulta Servicos"
       call set_count(arr_aux-1)

       display array  a_ctb05m04 to s_ctb05m04.*
          on key (interrupt)
             for arr_aux = 1 to 9
                 clear s_ctb05m04[arr_aux].*
             end for
             clear prstotgrl
             clear srvtotgrl
             initialize a_ctb05m04  to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             call ctb05m06(d_ctb05m04.datapsq  ,
                           d_ctb05m04.datapsq_a,
                           a_ctb05m04[arr_aux].pstcoddig)
       end display
    else
       error " Nao foi encontrado nenhum servico/prestador para pesquisa!"
    end if

 end while

 set isolation to committed read

 let int_flag = false
 close window  w_ctb05m04

end function  ###  ctb05m04
