 #############################################################################
 # Nome do Modulo: ctb12m09                                         Marcelo  #
 #                                                                  Gilberto #
 # Consulta distribuicao dos servicos por prestador                 Mai/1998 #
 #############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 28/09/1998  PSI 6523-4   Gilberto     Nao contabilizar servicos atendidos #
 #                                       como particular (srvprlflg = "S")   #
 #---------------------------------------------------------------------------#
 # 28/04/1999  PSI 7547-7   Gilberto     Exibir todos os servicos acionados  #
 #                                       e incluir opcao para consulta dos   #
 #                                       servicos.                           #
 #---------------------------------------------------------------------------#
 # 13/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
 #---------------------------------------------------------------------------#
 # 26/03/2001  AS  23787    Wagner       Criacao data periodo para pesquisa. #
 #---------------------------------------------------------------------------#
 # 19/12/2001  AS  25895    Wagner       Retirar linha prestador nulo.       #
 #                                       solicitado por Eduardo Oriente      #
 #---------------------------------------------------------------------------#
 # 10/03/2004  PSI183644    Marcio,Meta  Colocar origem 10 nos declare's     #
 #             OSF33.430                 abaixo solicitados                  #
 #---------------------------------------------------------------------------#
 # 11/03/2005  CH 5040740   Jeanie       Alterar array de 1500 para 5000.    #
 #---------------------------------------------------------------------------#
 # 05/12/2006  PSI 205206   Priscila     Incluir filtro por empresa          #
 #---------------------------------------------------------------------------#
 #############################################################################

 database porto


#------------------------------------------------------------------------
 function ctb12m09()
#------------------------------------------------------------------------

 define d_ctb12m09    record
    datapsq           date,
    datapsq_a         date,
    pstcodpsq         like dpaksocor.pstcoddig,
    claconcod         dec (1,0),
    clacondes         char(22),
    ciaempcod         like datmservico.ciaempcod,    #PSI 205206
    empsgl            like gabkemp.empsgl            #PSI 205206
 end record

 define a_ctb12m09 array[5000] of record
    pstcoddig         like dpaksocor.pstcoddig,
    nomgrr            like dpaksocor.nomgrr,
    endufd            like dpaksocor.endufd,
    endcid            like dpaksocor.endcid,
    srvtotqtd         dec (6,0)
 end record

 define ws            record
    comando1          char(800),
    comando2          char(1000),
    comando3          char(500),    #PSI 205206
    comando4          char(100),    #PSI 205206
    prstotgrl         dec(6,0),
    srvtotgrl         dec(6,0)
 end record

 define arr_aux       smallint,
        l_ret         smallint,
        l_mensagem    char(50)


 open window w_ctb12m09 at  06,02 with form "ctb12m09"
             attribute(form line first)

 set isolation to dirty read

 while true

    initialize ws.*          to null
    initialize a_ctb12m09    to null
    initialize d_ctb12m09.*  to null

    let int_flag     = false
    let arr_aux      = 1
    let ws.prstotgrl = 0
    let ws.srvtotgrl = 0

    input by name d_ctb12m09.*  without defaults

       before field datapsq
          if d_ctb12m09.datapsq  is null   then
             let d_ctb12m09.datapsq = today
          end if
          display by name d_ctb12m09.datapsq attribute (reverse)

       after  field datapsq
          display by name d_ctb12m09.datapsq

          if d_ctb12m09.datapsq  is null   then
             error " Data de atendimento inicial tem que ser informada!"
             next field datapsq
          end if
          if d_ctb12m09.datapsq  > today   then
             error " Data de atendimento nao deve ser maior que data atual!"
             next field datapsq
          end if

       before field datapsq_a
          if d_ctb12m09.datapsq_a  is null   then
             let d_ctb12m09.datapsq_a  = today
          end if
          display by name d_ctb12m09.datapsq_a attribute (reverse)

       after  field datapsq_a
          display by name d_ctb12m09.datapsq_a

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field datapsq
          end if
          if d_ctb12m09.datapsq_a  is null   then
             error " Data de atendimento final tem que ser informada!"
             next field datapsq_a
          end if
          if d_ctb12m09.datapsq_a  > today   then
             error " Data de atendimento final nao deve ser maior que data atual!"
             next field datapsq_a
          end if
          if d_ctb12m09.datapsq > d_ctb12m09.datapsq_a then
             error " Data de atendimanto inicial nao pode ser maior que data atendimento final!"
             next field datapsq_a
          end if
          if (d_ctb12m09.datapsq_a - d_ctb12m09.datapsq) > 31 then
             error " Periodo da pesquisa nao pode ser maior que 31 dias!"
             next field datapsq_a
          end if

       before field pstcodpsq
          display by name d_ctb12m09.pstcodpsq  attribute (reverse)

       after  field pstcodpsq
          display by name d_ctb12m09.pstcodpsq

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field datapsq_a
          end if

          if d_ctb12m09.pstcodpsq  is not null   then
             select pstcoddig
               from dpaksocor
              where dpaksocor.pstcoddig = d_ctb12m09.pstcodpsq

             if sqlca.sqlcode  =  notfound   then
                error " Codigo de prestador nao cadastrado!"
                next field pstcodpsq
             end if
          end if

          if d_ctb12m09.pstcodpsq  is not null   then
             initialize d_ctb12m09.claconcod  to null
             initialize d_ctb12m09.clacondes  to null

             display by name d_ctb12m09.claconcod
             display by name d_ctb12m09.clacondes
             exit input
          end if

       before field claconcod
          let d_ctb12m09.claconcod = 1
          let d_ctb12m09.clacondes = "QTDE SERVICOS"

          display by name d_ctb12m09.claconcod  attribute (reverse)
          display by name d_ctb12m09.clacondes

       after  field claconcod
          display by name d_ctb12m09.claconcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field pstcodpsq
          end if

          case d_ctb12m09.claconcod
             when  1  let d_ctb12m09.clacondes = "QTDE SERVICOS"
             when  2  let d_ctb12m09.clacondes = "UF/CIDADE PRESTADOR"
             otherwise
                  error " Classificacao: 1-Qtde servicos, 2-UF/Cidade prestador"
                  next field claconcod
          end case
          display by name d_ctb12m09.clacondes

       #PSI 205206
       before field ciaempcod
          display by name d_ctb12m09.ciaempcod  attribute (reverse)

       after field ciaempcod
          display by name d_ctb12m09.ciaempcod

          if fgl_lastkey() = fgl_keyval("left")   or
             fgl_lastkey() = fgl_keyval("up")     then
             next field claconcod
          end if

          initialize d_ctb12m09.empsgl  to null

          #Buscar descricao da empresa informada
          if d_ctb12m09.ciaempcod is not null then
             call cty14g00_empresa(1, d_ctb12m09.ciaempcod)
                  returning l_ret,
                            l_mensagem,
                            d_ctb12m09.empsgl
             if l_ret <> 1 then
                #erro ao buscar descricao
                error l_mensagem
                next field ciaempcod
             end if
          else
             let d_ctb12m09.empsgl = "TODAS"
          end if
          display by name d_ctb12m09.empsgl

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    #---------------------------------------------------------------
    # Monta cursor para pesquisa
    #---------------------------------------------------------------

    let ws.comando1 = " select datmservico.atdprscod, ",
                      "        dpaksocor.nomgrr,      ",
                      "        dpaksocor.endufd,      ",
                      "        dpaksocor.endcid,      ",
                      "        count(*)               "

    if d_ctb12m09.pstcodpsq   is not null   then
       let ws.comando2 = "  from datmservico, dpaksocor ",
                         " where datmservico.atddat    between ? and ?",
                         "   and datmservico.atdsrvorg in (1,2,3,4,5,6,7,12,15,16,17,18)",
                         "   and datmservico.atdfnlflg = 'S' ",
                         "   and datmservico.atdprscod = ? ",
                         "   and datmservico.srvprlflg = 'N'",
                         "   and dpaksocor.pstcoddig   = datmservico.atdprscod"

       let ws.comando3 = " group by datmservico.atdprscod, ",
                         "          dpaksocor.nomgrr, ",
                         "          dpaksocor.endufd, ",
                         "          dpaksocor.endcid  "
    else
       if d_ctb12m09.claconcod  =  1   then
          let ws.comando2 = "  from datmservico, dpaksocor ",
                         " where datmservico.atddat   between ? and ?",
                         "   and datmservico.atdsrvorg in (1,2,3,4,5,6,7,12,15,16,17,18)",
                         "   and datmservico.atdfnlflg = 'S' ",
                         "   and datmservico.srvprlflg = 'N'",
                         "   and dpaksocor.pstcoddig   = datmservico.atdprscod"

          let ws.comando3 = " group by datmservico.atdprscod, ",
                            "          dpaksocor.nomgrr, ",
                            "          dpaksocor.endufd, ",
                            "          dpaksocor.endcid  ",
                            " order by 5  desc "
       else
          let ws.comando2 = "  from datmservico, dpaksocor ",
                         " where datmservico.atddat   between ? and ?",
                         "   and datmservico.atdsrvorg in (1,2,3,4,5,6,7,12,15,16,17,18)",
                         "   and datmservico.atdfnlflg = 'S' ",
                         "   and datmservico.srvprlflg = 'N'",
                         "   and dpaksocor.pstcoddig   = datmservico.atdprscod"

          let ws.comando3 = " group by datmservico.atdprscod, ",
                            "          dpaksocor.nomgrr, ",
                            "          dpaksocor.endufd, ",
                            "          dpaksocor.endcid  ",
                            " order by 3, 4, 5 desc "
       end if
    end if

    #PSI 205206 - buscar apenas os servicos de acordo com a empresa solicitada
    if d_ctb12m09.ciaempcod is not null then
       let ws.comando2 = ws.comando2 clipped, " and datmservico.ciaempcod = ? "
    end if

    message " Aguarde, pesquisando..."  attribute(reverse)
    let ws.comando1 = ws.comando1 clipped," ", ws.comando2 clipped," ", ws.comando3

    prepare comando_aux from ws.comando1

    declare c_ctb12m09  cursor for  comando_aux

    #PSI 205206 - abrir cursor de forma diferente caso tenha informado empresa
    if d_ctb12m09.ciaempcod is null then
       if d_ctb12m09.pstcodpsq  is not null   then
          open  c_ctb12m09  using  d_ctb12m09.datapsq,
                                   d_ctb12m09.datapsq_a,
                                   d_ctb12m09.pstcodpsq
       else
          open  c_ctb12m09  using  d_ctb12m09.datapsq,
                                   d_ctb12m09.datapsq_a
       end if
    else
       #caso tenha informado empresa
       if d_ctb12m09.pstcodpsq  is not null   then
          open  c_ctb12m09  using  d_ctb12m09.datapsq,
                                   d_ctb12m09.datapsq_a,
                                   d_ctb12m09.pstcodpsq,
                                   d_ctb12m09.ciaempcod
       else
          open  c_ctb12m09  using  d_ctb12m09.datapsq,
                                   d_ctb12m09.datapsq_a,
                                   d_ctb12m09.ciaempcod
       end if
    end if

    foreach c_ctb12m09 into a_ctb12m09[arr_aux].pstcoddig,
                            a_ctb12m09[arr_aux].nomgrr,
                            a_ctb12m09[arr_aux].endufd,
                            a_ctb12m09[arr_aux].endcid,
                            a_ctb12m09[arr_aux].srvtotqtd

       let ws.prstotgrl = ws.prstotgrl + 1
       let ws.srvtotgrl = ws.srvtotgrl + a_ctb12m09[arr_aux].srvtotqtd

       let arr_aux = arr_aux + 1
       if arr_aux  >  5000   then
          error " Limite excedido, pesquisa com mais de 5000 prestadores!"
          exit foreach
       end if

    end foreach

    message ""
    if arr_aux  >  1   then
       display by name ws.prstotgrl
       display by name ws.srvtotgrl

       message " (F17)Abandona, (F8)Consulta Servicos"
       call set_count(arr_aux-1)

       display array  a_ctb12m09 to s_ctb12m09.*
          on key (interrupt)
             for arr_aux = 1 to 8    #qtde linhas da tela
                 clear s_ctb12m09[arr_aux].*
             end for
             clear prstotgrl
             clear srvtotgrl
             initialize a_ctb12m09  to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             call ctb12m10(d_ctb12m09.datapsq  ,
                           d_ctb12m09.datapsq_a,
                           a_ctb12m09[arr_aux].pstcoddig,
                           d_ctb12m09.ciaempcod)
       end display
    else
       error " Nao foi encontrado nenhum servico/prestador para pesquisa!"
    end if

 end while

 set isolation to committed read

 let int_flag = false
 close window  w_ctb12m09

end function  ###  ctb12m09
