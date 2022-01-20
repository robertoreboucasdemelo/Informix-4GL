#############################################################################
# Nome do Modulo: CTB12M10                                         Marcelo  #
#                                                                  Gilberto #
# Consulta acionamento de servicos do prestador selecionado        Mai/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 13/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 26/03/2001  AS  23787    Wagner       Inclusao periodo de pesquisa.       #
#############################################################################

 database porto

#------------------------------------------------------------------------
 function ctb12m10(param,l_ciaempcod)
#------------------------------------------------------------------------

 define param         record
    datpsq            date,
    datpsq_a          date,
    pstcoddig         like dpaksocor.pstcoddig
 end record

 define l_ciaempcod   like datmservico.ciaempcod

 define a_ctb12m10 array[4000] of record
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdetpdes         like datketapa.atdetpdes,
    funnom            like isskfunc.funnom,
    txt1              char (02),
    cnldat            like datmservico.cnldat,
    txt2              char (02),
    atdfnlhor         char (05),
    atdvclsgl         like datkveiculo.atdvclsgl
 end record

 define ws            record
    nomgrr            like dpaksocor.nomgrr,
    sql               char (800),
    srvqtd            dec (6,0),
    srvqtdtxt         char (12),
    c24opemat         like datmservico.c24opemat,
    atdetpcod         like datketapa.atdetpcod
 end record

 define arr_aux       smallint

 display "l_ciaempcod: ", l_ciaempcod

 open window w_ctb12m10 at  06,02 with form "ctb12m10"
             attribute(form line first)

 set isolation to dirty read

 initialize ws.*          to null
 initialize a_ctb12m10    to null

 select nomgrr into ws.nomgrr
   from dpaksocor
  where pstcoddig = param.pstcoddig

 display by name param.*
 display ws.nomgrr to nomgrr

 let int_flag  = false

 let arr_aux   = 1

 let ws.srvqtd = 0

 message " Aguarde, pesquisando..."  attribute(reverse)

 let ws.sql = "select atdetpcod    ",
              "  from datmsrvacp   ",
              " where atdsrvnum = ?",
              "   and atdsrvano = ?",
              "   and atdsrvseq = (select max(atdsrvseq)",
                                  "  from datmsrvacp    ",
                                  " where atdsrvnum = ? ",
                                  "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from ws.sql
 declare c_datmsrvacp cursor for sel_datmsrvacp

 let ws.sql = "select atdetpdes ",
              "  from datketapa ",
              " where atdetpcod = ?"
 prepare sel_datketapa from ws.sql
 declare c_datketapa cursor for sel_datketapa

 let ws.sql = "select funnom    ",
              "  from isskfunc  ",
              " where funmat = ?"
 prepare sel_isskfunc from ws.sql
 declare c_isskfunc cursor for sel_isskfunc

 if l_ciaempcod is not null then
    let ws.sql = " select datmservico.atdsrvnum, ",
                        " datmservico.atdsrvano, ",
                        " datmservico.cnldat, ",
                        " datmservico.atdfnlhor, ",
                        " datmservico.c24opemat, ",
                        " datmservico.atdsrvorg, ",
                        " datkveiculo.atdvclsgl ",
                   " from datmservico, outer datkveiculo ",
                  " where datmservico.atddat between ",
                  "'", param.datpsq, "'", " and ", "'", param.datpsq_a, "'",
                    " and datmservico.atdsrvorg in (1,2,3,4,5,6,7,12,15,16,17,18) ",
                    " and datmservico.atdfnlflg = 'S' ",
                    " and datmservico.atdprscod = ", param.pstcoddig,
                    " and datmservico.ciaempcod = ", l_ciaempcod,
                    " and datmservico.srvprlflg = 'N' ",
                    " and datkveiculo.socvclcod = datmservico.socvclcod ",
                  " order by cnldat, atdfnlhor "
 else
    let ws.sql = " select datmservico.atdsrvnum, ",
                        " datmservico.atdsrvano, ",
                        " datmservico.cnldat, ",
                        " datmservico.atdfnlhor, ",
                        " datmservico.c24opemat, ",
                        " datmservico.atdsrvorg, ",
                        " datkveiculo.atdvclsgl ",
                   " from datmservico, outer datkveiculo ",
                  " where datmservico.atddat between ",
                  "'", param.datpsq, "'", " and ", "'", param.datpsq_a, "'",
                    " and datmservico.atdsrvorg in (1,2,3,4,5,6,7,12,15,16,17,18) ",
                    " and datmservico.atdfnlflg = 'S' ",
                    " and datmservico.atdprscod = ", param.pstcoddig,
                    " and datmservico.srvprlflg = 'N' ",
                    " and datkveiculo.socvclcod = datmservico.socvclcod ",
                  " order by cnldat, atdfnlhor "
 end if

 prepare pctb12m09001 from ws.sql
 declare cctb12m09001 cursor for pctb12m09001

 ##declare c_ctb12m10 cursor for
 ##   select datmservico.atdsrvnum,
 ##          datmservico.atdsrvano,
 ##          datmservico.cnldat   ,
 ##          datmservico.atdfnlhor,
 ##          datmservico.c24opemat,
 ##          datmservico.atdsrvorg,
 ##          datkveiculo.atdvclsgl
 ##     from datmservico, outer datkveiculo
 ##    where datmservico.atddat    between param.datpsq and param.datpsq_a
 ##      and datmservico.atdsrvorg   in (1, 2, 3, 4, 5, 6, 7, 9, 13)
 ##      and datmservico.atdfnlflg = 'S'
 ##      and datmservico.atdprscod = param.pstcoddig
 ##      and datmservico.ciaempcod = l_ciaempcod
 ##      and datmservico.srvprlflg = 'N'
 ##      and datkveiculo.socvclcod = datmservico.socvclcod
 ##    order by cnldat, atdfnlhor

 foreach cctb12m09001 into a_ctb12m10[arr_aux].atdsrvnum,
                           a_ctb12m10[arr_aux].atdsrvano,
                           a_ctb12m10[arr_aux].cnldat,
                           a_ctb12m10[arr_aux].atdfnlhor,
                           ws.c24opemat,
                           a_ctb12m10[arr_aux].atdsrvorg,
                           a_ctb12m10[arr_aux].atdvclsgl

    let a_ctb12m10[arr_aux].funnom = "**NAO CADASTRADO**"

    open  c_isskfunc using ws.c24opemat
    fetch c_isskfunc into  a_ctb12m10[arr_aux].funnom
    close c_isskfunc

    let a_ctb12m10[arr_aux].funnom = upshift(a_ctb12m10[arr_aux].funnom)

    open  c_datmsrvacp using a_ctb12m10[arr_aux].atdsrvnum,
                             a_ctb12m10[arr_aux].atdsrvano,
                             a_ctb12m10[arr_aux].atdsrvnum,
                             a_ctb12m10[arr_aux].atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    let a_ctb12m10[arr_aux].atdetpdes = "**NAO CADASTRADA**"

    open  c_datketapa using ws.atdetpcod
    fetch c_datketapa into  a_ctb12m10[arr_aux].atdetpdes
    close c_datketapa

    let a_ctb12m10[arr_aux].txt1 = "em"
    let a_ctb12m10[arr_aux].txt2 = "as"

    let ws.srvqtd = ws.srvqtd + 1

    let arr_aux = arr_aux + 1
    if arr_aux  >  4000   then
       error " Limite excedido, pesquisa com mais de 4000 servicos!"
       exit foreach
    end if

 end foreach
 close cctb12m09001

 message ""
 if arr_aux  >  1   then
    let ws.srvqtdtxt = "Total: ", ws.srvqtd using "<<<<<#"
    display by name ws.srvqtdtxt attribute (reverse)

    message " (F17)Abandona"
    call set_count(arr_aux-1)

    display array  a_ctb12m10 to s_ctb12m10.*
       on key (interrupt)
          initialize a_ctb12m10  to null
          exit display
    end display
 else
    error " Nao foi encontrado nenhum servico para o prestador selecionado!"
 end if

 set isolation to committed read

 let int_flag = false

 close window w_ctb12m10

end function  ###  ctb12m10
