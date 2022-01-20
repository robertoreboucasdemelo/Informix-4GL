#############################################################################
# Nome do Modulo: ctb03m03                                         Wagner   #
#                                                                           #
# Consulta distribuicao dos servicos por locadora                  Mai/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 16/07/2001  PSI 13448-1  Wagner       Incluir pesquisa por loja locadora. #
#############################################################################

 database porto

#------------------------------------------------------------------------
 function ctb03m03()
#------------------------------------------------------------------------

 define d_ctb03m03    record
    datapsq           date,
    datapsq_a         date,
    lcvcod            like datklocadora.lcvcod,
    lcvnom            like datklocadora.lcvnom,
    lcvextcod         like datkavislocal.lcvextcod,
    aviestnom         like datkavislocal.aviestnom
 end record

 define a_ctb03m03 array[1500] of record
    lcvcod_dsp        like datklocadora.lcvcod,
    lcvnom_dsp        like datklocadora.lcvnom,
    lcvextcod_dsp     like datkavislocal.lcvextcod,
    srvtotqtd         dec (6,0),
    aviestcod_dsp     like datkavislocal.aviestcod
 end record

 define ws            record
    aviestcod         like datkavislocal.aviestcod,
    comando1          char(700),
    comando2          char(600),
    prstotgrl         dec(6,0),
    srvtotgrl         dec(6,0)
 end record

 define arr_aux       smallint


 open window w_ctb03m03 at  06,02 with form "ctb03m03"
             attribute(form line first)

 set isolation to dirty read

 while true

    initialize ws.*          to null
    initialize a_ctb03m03    to null
    initialize d_ctb03m03.*  to null

    let int_flag     = false
    let arr_aux      = 1
    let ws.prstotgrl = 0
    let ws.srvtotgrl = 0

    input by name d_ctb03m03.*  without defaults

       before field datapsq
          if d_ctb03m03.datapsq  is null   then
             let d_ctb03m03.datapsq = today
          end if
          display by name d_ctb03m03.datapsq attribute (reverse)

       after  field datapsq
          display by name d_ctb03m03.datapsq

          if d_ctb03m03.datapsq  is null   then
             error " Data de atendimento inicial tem que ser informada!"
             next field datapsq
          end if
          if d_ctb03m03.datapsq  > today   then
             error " Data de atendimento nao deve ser maior que data atual!"
             next field datapsq
          end if

       before field datapsq_a
          if d_ctb03m03.datapsq_a  is null   then
             let d_ctb03m03.datapsq_a  = today
          end if
          display by name d_ctb03m03.datapsq_a attribute (reverse)

       after  field datapsq_a
          display by name d_ctb03m03.datapsq_a

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field datapsq
          end if
          if d_ctb03m03.datapsq_a  is null   then
             error " Data de atendimento final tem que ser informada!"
             next field datapsq_a
          end if
          if d_ctb03m03.datapsq_a  > today   then
             error " Data de atendimento final nao deve ser maior que data atual!"
             next field datapsq_a
          end if
          if d_ctb03m03.datapsq > d_ctb03m03.datapsq_a then
             error " Data de atendimanto inicial nao pode ser maior que data atendimento final!"
             next field datapsq_a
          end if
          if (d_ctb03m03.datapsq_a - d_ctb03m03.datapsq) > 31 then
             error " Periodo da pesquisa nao pode ser maior que 31 dias!"
             next field datapsq_a
          end if

       before field lcvcod
          display by name d_ctb03m03.lcvcod  attribute (reverse)

       after  field lcvcod
          display by name d_ctb03m03.lcvcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field datapsq_a
          end if

          if d_ctb03m03.lcvcod  is not null   then
             select lcvnom
               into d_ctb03m03.lcvnom
               from datklocadora
              where datklocadora.lcvcod = d_ctb03m03.lcvcod

             if sqlca.sqlcode  =  notfound   then
                error " Codigo da locadora nao cadastrado!"
                next field lcvcod
             end if
             display by name d_ctb03m03.lcvnom
          else
             exit input
          end if

       before field lcvextcod
          display by name d_ctb03m03.lcvextcod attribute (reverse)

       after  field lcvextcod
          display by name d_ctb03m03.lcvextcod

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
              next field  lcvcod
          end if

          initialize d_ctb03m03.aviestnom, ws.aviestcod to null
          if d_ctb03m03.lcvextcod  is not null then
             select aviestnom, aviestcod
               into d_ctb03m03.aviestnom, ws.aviestcod
               from datkavislocal
              where lcvcod    = d_ctb03m03.lcvcod
                and lcvextcod = d_ctb03m03.lcvextcod

             if sqlca.sqlcode <> 0  then
                error " Loja/Locadora nao cadastrada!"
                call ctc30m02(d_ctb03m03.lcvcod)
                    returning d_ctb03m03.lcvextcod
                next field lcvextcod
             end if
          end if
          display by name d_ctb03m03.aviestnom

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    #---------------------------------------------------------------
    # Monta cursor para pesquisa
    #---------------------------------------------------------------
    if d_ctb03m03.lcvcod   is not null   then
       let ws.comando2 =" from datmservico , datmavisrent, datklocadora ",
                        " where datmservico.atddat    between ? and ?",
                        " and datmservico.atdsrvorg = 8 ",
                        " and datmservico.atdfnlflg = 'S' ",
                        " and datmservico.srvprlflg = 'N'",
                        " and datmavisrent.atdsrvnum = datmservico.atdsrvnum ",
                        " and datmavisrent.atdsrvano = datmservico.atdsrvano ",
                        " and datklocadora.lcvcod    = datmavisrent.lcvcod ",
                        " and datklocadora.lcvcod    = ? ",
                        " group by datklocadora.lcvcod, ",
                        "          datklocadora.lcvnom, ",
                        "          datmavisrent.aviestcod "
    else
       let ws.comando2 =" from datmservico , datmavisrent, datklocadora ",
                        " where datmservico.atddat    between ? and ?",
                        " and datmservico.atdsrvorg = 8 ",
                        " and datmservico.atdfnlflg = 'S' ",
                        " and datmservico.srvprlflg = 'N'",
                        " and datmavisrent.atdsrvnum = datmservico.atdsrvnum ",
                        " and datmavisrent.atdsrvano = datmservico.atdsrvano ",
                        " and datklocadora.lcvcod    = datmavisrent.lcvcod ",
                        " group by datklocadora.lcvcod, ",
                        "          datklocadora.lcvnom  ",
                        " order by datklocadora.lcvcod  "
    end if

    if d_ctb03m03.lcvcod  is not null then
       let ws.comando1 = " select datklocadora.lcvcod   , ",
                         "        datklocadora.lcvnom   , ",
                         "        datmavisrent.aviestcod, ",
                         "        count(*)             "
    else
       let ws.comando1 = " select datklocadora.lcvcod   , ",
                         "        datklocadora.lcvnom   , ",
                         "        count(*)             "
    end if

    message " Aguarde, pesquisando..."  attribute(reverse)
    let ws.comando1 = ws.comando1 clipped," ", ws.comando2

    if d_ctb03m03.lcvcod  is not null   then
       prepare comando_auxa from ws.comando1
       declare c_ctb03m03a cursor for  comando_auxa
       open  c_ctb03m03a   using  d_ctb03m03.datapsq,
                                  d_ctb03m03.datapsq_a,
                                  d_ctb03m03.lcvcod
       foreach c_ctb03m03a into a_ctb03m03[arr_aux].lcvcod_dsp,
                               a_ctb03m03[arr_aux].lcvnom_dsp,
                               a_ctb03m03[arr_aux].aviestcod_dsp,
                               a_ctb03m03[arr_aux].srvtotqtd

          if d_ctb03m03.lcvextcod  is not null then
             if a_ctb03m03[arr_aux].aviestcod_dsp <> ws.aviestcod then
                continue foreach
             end if
          end if

          select lcvextcod
            into a_ctb03m03[arr_aux].lcvextcod_dsp
            from datkavislocal
           where lcvcod    = a_ctb03m03[arr_aux].lcvcod_dsp
             and aviestcod = a_ctb03m03[arr_aux].aviestcod_dsp

          let ws.prstotgrl = ws.prstotgrl + 1
          let ws.srvtotgrl = ws.srvtotgrl + a_ctb03m03[arr_aux].srvtotqtd

          let arr_aux = arr_aux + 1
          if arr_aux  >  1500   then
             error " Limite excedido, pesquisa com mais de 1500 locadoras!"
             exit foreach
          end if

       end foreach
    else
       prepare comando_auxb from ws.comando1
       declare c_ctb03m03b  cursor for  comando_auxb
       open  c_ctb03m03b using  d_ctb03m03.datapsq,
                                d_ctb03m03.datapsq_a
       foreach c_ctb03m03b into a_ctb03m03[arr_aux].lcvcod_dsp,
                                a_ctb03m03[arr_aux].lcvnom_dsp,
                                a_ctb03m03[arr_aux].srvtotqtd

          initialize a_ctb03m03[arr_aux].lcvextcod_dsp to null

          let ws.prstotgrl = ws.prstotgrl + 1
          let ws.srvtotgrl = ws.srvtotgrl + a_ctb03m03[arr_aux].srvtotqtd

          let arr_aux = arr_aux + 1
          if arr_aux  >  1500   then
             error " Limite excedido, pesquisa com mais de 1500 locadoras!"
             exit foreach
          end if

       end foreach
    end if

    message ""
    if arr_aux  >  1   then
       display by name ws.prstotgrl
       display by name ws.srvtotgrl

       message " (F17)Abandona, (F8)Consulta Servicos"
       call set_count(arr_aux-1)

       display array  a_ctb03m03 to s_ctb03m03.*
          on key (interrupt)
             for arr_aux = 1 to 8
                 clear s_ctb03m03[arr_aux].*
             end for
             clear prstotgrl
             clear srvtotgrl
             initialize a_ctb03m03  to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             call ctb03m04(d_ctb03m03.datapsq  ,
                           d_ctb03m03.datapsq_a,
                           a_ctb03m03[arr_aux].lcvcod_dsp,
                           a_ctb03m03[arr_aux].aviestcod_dsp)
       end display
    else
       error " Nao foi encontrado nenhum servico/locadora para pesquisa!"
    end if

 end while

 set isolation to committed read

 let int_flag = false
 close window  w_ctb03m03

end function  ###  ctb03m03
