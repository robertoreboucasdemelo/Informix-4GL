#############################################################################
# Nome do Modulo: CTB03m04                                         Wagner   #
#                                                                           #
# Consulta acionamento de servicos da locadora  selecionada        Mai/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 16/07/2001  PSI 13448-1  Wagner       Incluir acesso/display loja         #
#############################################################################

 database porto

#------------------------------------------------------------------------
 function ctb03m04(param)
#------------------------------------------------------------------------

 define param         record
    datpsq            date,
    datpsq_a          date,
    lcvcod            like datklocadora.lcvcod,
    aviestcod         like datkavislocal.aviestcod
 end record

 define a_ctb03m04 array[4000] of record
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdetpdes         like datketapa.atdetpdes,
    txt1              char (02),
    cnldat            like datmservico.cnldat,
    txt2              char (02),
    atdfnlhor         char (05),
    avilocnom         like datmavisrent.avilocnom
 end record

 define ws            record
    lcvnom            like datklocadora.lcvnom,
    lcvextcod         like datkavislocal.lcvextcod,
    aviestnom         like datkavislocal.aviestnom,
    sql               char (800),
    srvqtd            dec (6,0),
    srvqtdtxt         char (12),
    c24opemat         like datmservico.c24opemat,
    atdetpcod         like datketapa.atdetpcod,
    aviestcod         like datkavislocal.aviestcod
 end record

 define arr_aux       smallint


 open window w_ctb03m04 at  06,02 with form "ctb03m04"
             attribute(form line first)

 set isolation to dirty read

 initialize ws.*          to null
 initialize a_ctb03m04    to null

 select lcvnom
   into ws.lcvnom
   from datklocadora
  where datklocadora.lcvcod = param.lcvcod

 if param.aviestcod is not null then
    select lcvextcod, aviestnom
      into ws.lcvextcod, ws.aviestnom
      from datkavislocal
     where datkavislocal.lcvcod    = param.lcvcod
       and datkavislocal.aviestcod = param.aviestcod
 end if

 display by name param.datpsq thru param.lcvcod
 display ws.lcvnom to lcvnom
 display ws.lcvextcod to lcvextcod
 display ws.aviestnom to aviestnom

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

 declare c_ctb03m04 cursor for
    select datmservico.atdsrvnum,
           datmservico.atdsrvano,
           datmservico.cnldat   ,
           datmservico.atdfnlhor,
           datmservico.atdsrvorg,
           datmavisrent.avilocnom,
           datmavisrent.aviestcod
      from datmservico, datmavisrent, datklocadora
     where datmservico.atddat    between param.datpsq and param.datpsq_a
       and datmservico.atdsrvorg = 8
       and datmservico.atdfnlflg = 'S'
       and datmservico.srvprlflg = 'N'
       and datmavisrent.atdsrvnum = datmservico.atdsrvnum
       and datmavisrent.atdsrvano = datmservico.atdsrvano
       and datklocadora.lcvcod    = datmavisrent.lcvcod
       and datklocadora.lcvcod    = param.lcvcod


 foreach c_ctb03m04 into a_ctb03m04[arr_aux].atdsrvnum,
                         a_ctb03m04[arr_aux].atdsrvano,
                         a_ctb03m04[arr_aux].cnldat,
                         a_ctb03m04[arr_aux].atdfnlhor,
                         a_ctb03m04[arr_aux].atdsrvorg,
                         a_ctb03m04[arr_aux].avilocnom,
                         ws.aviestcod

    if param.aviestcod is not null and
       param.aviestcod <> 0        then
       if param.aviestcod <> ws.aviestcod then
          continue foreach
       end if
    end if

    open  c_datmsrvacp using a_ctb03m04[arr_aux].atdsrvnum,
                             a_ctb03m04[arr_aux].atdsrvano,
                             a_ctb03m04[arr_aux].atdsrvnum,
                             a_ctb03m04[arr_aux].atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    let a_ctb03m04[arr_aux].atdetpdes = "**NAO CADASTRADA**"
    open  c_datketapa using ws.atdetpcod
    fetch c_datketapa into  a_ctb03m04[arr_aux].atdetpdes
    close c_datketapa

    let a_ctb03m04[arr_aux].txt1 = "em"
    let a_ctb03m04[arr_aux].txt2 = "as"

    let ws.srvqtd = ws.srvqtd + 1

    let arr_aux = arr_aux + 1
    if arr_aux  >  4000   then
       error " Limite excedido, pesquisa com mais de 4000 servicos!"
       exit foreach
    end if

 end foreach

 message ""
 if arr_aux  >  1   then
    let ws.srvqtdtxt = "Total: ", ws.srvqtd using "<<<<<#"
    display by name ws.srvqtdtxt attribute (reverse)

    message " (F17)Abandona"
    call set_count(arr_aux-1)

    display array  a_ctb03m04 to s_ctb03m04.*
       on key (interrupt)
          initialize a_ctb03m04  to null
          exit display
    end display
 else
    error " Nao foi encontrado nenhum servico para a locadora selecionada!"
 end if

 set isolation to committed read

 let int_flag = false

 close window w_ctb03m04

end function  ###  ctb03m04
