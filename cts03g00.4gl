#############################################################################
# Nome do Modulo: CTS03G00                                         Marcelo  #
#                                                                  Gilberto #
# Verifica se existe outros servicos solicitados no dia (inclusao) Mai/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 04/05/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 06/07/1999  PSI 7952-9   Wagner       Inclusao RPT na pesquisa servicos.  #
#---------------------------------------------------------------------------#
# 16/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 09/05/2001  PSI 13042-7  Ruiz         Alteracao para laudo de vidros      #
#---------------------------------------------------------------------------#
# 16/07/2002  PSI 15653-1  Ruiz         Informar a natureza do servico.     #
#---------------------------------------------------------------------------#
# 28/08/2002  PSI 14179-8  Ruiz         Alteracao para laudo de sinis.transp#
#---------------------------------------------------------------------------#
# 21/09/2006  PSI 202720   Ruiz         Alteracao para Saude                #
#---------------------------------------------------------------------------#
# 19/04/2010  PSI 219444   Carla Rampazzo Filtrar Atendimento p/ mostrar so #
#                                         que se relacionam c/ Local/Bloco  #
#---------------------------------------------------------------------------#
#############################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------------------------
 function cts03g00(param)
#-----------------------------------------------------------------------------

#---------------------------------------------------------#
# PARAMETRO - Tipo de Servico (tipsrv)                    #
#            (1) Remocao/Socorro Automovel / D.A.F. / RPT #
#            (2) Aviso de furto/roubo total               #
#            (3) Sinistro/Socorro Ramos Elementares       #
#            (4) Vidros                                   #
#            (5) Sinistro de Transportes                  #
#---------------------------------------------------------#

 define param        record
    tipsrv           smallint,
    ramcod           like datrservapol.ramcod,
    succod           like datrservapol.succod,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    vcllicnum        like datmservico.vcllicnum,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define a_cts03g00   array[07]  of record
    atdsrvdat        char (05),
    atdhor           like datmservico.atdhor,
    servico          char(13)                  ,
    srvtipabvdes     like datksrvtip.srvtipabvdes,
    tipnat           char(07),
    atdprscod        like datmservico.atdprscod,
    nomgrr           like dpaksocor.nomgrr,
    atdvclsgl        like datmservico.atdvclsgl
 end record

 define ws           record
    atdsrvorg        like datmservico.atdsrvorg,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atddat           char (10),
    atdetpcod        like datmsrvacp.atdetpcod,
    socvclcod        like datmservico.socvclcod,
    inidat           date,
    fimdat           date,
    sql              char (850),
    cabec            char (69),
    tippsqdes        char (07),
    socntzcod        like datmsrvre.socntzcod,
    asitipcod        like datmservico.asitipcod
   ,lclnumseq        like datmsrvre.lclnumseq
   ,rmerscseq        like datmsrvre.rmerscseq
 end record

 define arr_aux      smallint

 #------------------------------------------------------------------------
 # Limpa campos / Monta comandos SQL
 #------------------------------------------------------------------------

 define w_pf1 integer

 let arr_aux  =  null

 for w_pf1  =  1  to  7
    initialize  a_cts03g00[w_pf1].*  to  null
 end for

initialize  ws.*  to  null

 if (param.aplnumdig  is null   and
     param.vcllicnum  is null)  and
     g_ppt.cmnnumdig  is null   then
    error " Nenhuma chave para pesquisa foi informada. AVISE A INFORMATICA!"
    return
 end if

 set isolation to dirty read
 initialize ws.*         to null
 initialize a_cts03g00   to null

 let int_flag  = false
 let arr_aux   = 1
 let ws.inidat = today - 2 units day
 let ws.fimdat = today

 let ws.sql = " order by atddat, atdhor"

 case param.tipsrv
    when  1
       let ws.sql = " datmservico.atdsrvorg in (4,6,1,5) ", ws.sql
    when  2
       let ws.sql = " datmservico.atdsrvorg = 11 ", ws.sql
    when  3
       let ws.sql = " datmservico.atdsrvorg in (9,13) ", ws.sql
    when  4
       let ws.sql = " datmservico.atdsrvorg = 14 ", ws.sql
    when  5
       let ws.sql = " datmservico.atdsrvorg = 16 ", ws.sql
 end case

 if param.aplnumdig  is not null   and
    g_documento.crtsaunum is null  then
    let ws.tippsqdes = "apolice"
    let ws.sql = "select datmservico.atddat    , ",
                 "       datmservico.atdhor    , ",
                 "       datmservico.atdsrvnum , ",
                 "       datmservico.atdsrvano , ",
                 "       datmservico.atdsrvorg , ",
                 "       datmservico.atdprscod , ",
                 "       datmservico.atdvclsgl , ",
                 "       datmservico.socvclcod , ",
                 "       datmservico.asitipcod   ",
                 "  from datrservapol,datmservico",
                 " where datrservapol.ramcod     =  ?                      and",
                 "       datrservapol.succod     =  ?                      and",
                 "       datrservapol.aplnumdig  =  ?                      and",
                 "       datrservapol.itmnumdig  =  ?                      and",
                 "       datmservico.atdsrvnum   =  datrservapol.atdsrvnum and",
                 "       datmservico.atdsrvano   =  datrservapol.atdsrvano and",
                 "       datmservico.atddat      between  ?  and  ?        and",
                 ws.sql clipped
 else
    if g_ppt.cmnnumdig is not null then
       let ws.tippsqdes = "contrato"
       let ws.sql =  "select datmservico.atddat    , ",
                     "       datmservico.atdhor    , ",
                     "       datmservico.atdsrvnum , ",
                     "       datmservico.atdsrvano , ",
                     "       datmservico.atdsrvorg , ",
                     "       datmservico.atdprscod , ",
                     "       datmservico.atdvclsgl , ",
                     "       datmservico.socvclcod , ",
                     "       datmservico.asitipcod   ",
                     "  from datmservico, datmligacao, datrligppt  ",
                     " where datmservico.atdsrvnum = datmligacao.atdsrvnum ",
                     "   and datmservico.atdsrvano = datmligacao.atdsrvano ",
                     "   and datrligppt.cmnnumdig =  ?         ",
                     "   and datmservico.atddat    between  ?  and  ?  ",
                     "   and datrligppt.lignum     = datmligacao.lignum and" ,
                     ws.sql clipped
    else
       if g_documento.crtsaunum is not null then
          let ws.tippsqdes = "Saude"
          let ws.sql =  "select datmservico.atddat    , ",
                        "       datmservico.atdhor    , ",
                        "       datmservico.atdsrvnum , ",
                        "       datmservico.atdsrvano , ",
                        "       datmservico.atdsrvorg , ",
                        "       datmservico.atdprscod , ",
                        "       datmservico.atdvclsgl , ",
                        "       datmservico.socvclcod , ",
                        "       datmservico.asitipcod   ",
                        "  from datmservico, datmligacao, datrligsau  ",
                        " where datmservico.atdsrvnum = datmligacao.atdsrvnum ",
                        "   and datmservico.atdsrvano = datmligacao.atdsrvano ",
                        "   and datrligsau.crtnum    =  ?         ",
                        "   and datmservico.atddat    between  ?  and  ?  ",
                        "   and datrligsau.lignum    = datmligacao.lignum and" ,
                        ws.sql clipped
       else
          let ws.tippsqdes = "placa"
          let ws.sql = "select datmservico.atddat    , ",
                       "       datmservico.atdhor    , ",
                       "       datmservico.atdsrvnum , ",
                       "       datmservico.atdsrvano , ",
                       "       datmservico.atdsrvorg , ",
                       "       datmservico.atdprscod , ",
                       "       datmservico.atdvclsgl , ",
                       "       datmservico.socvclcod , ",
                       "       datmservico.asitipcod   ",
                       "  from datmservico",
                       " where datmservico.vcllicnum   =  ?                and",
                       "       datmservico.atddat      between  ?  and  ?  and",
                       ws.sql clipped
      end if
    end if
 end if
 prepare sel_datmservico  from ws.sql
 declare c_cts03g00 cursor for sel_datmservico

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

 #------------------------------------------------------------------------
 # Ler servicos conforme parametros
 #------------------------------------------------------------------------
 if param.aplnumdig   is not null  and
    g_documento.crtsaunum is null  then
    open    c_cts03g00 using param.ramcod,
                             param.succod,
                             param.aplnumdig,
                             param.itmnumdig,
                             ws.inidat,
                             ws.fimdat
 else
    if g_documento.crtsaunum is not null then
       open c_cts03g00 using g_documento.crtsaunum,
                             ws.inidat,
                             ws.fimdat
    else
       if g_ppt.cmnnumdig is not null then
          open    c_cts03g00 using g_ppt.cmnnumdig,
                                   ws.inidat,
                                   ws.fimdat
       else
          open    c_cts03g00 using param.vcllicnum,
                                   ws.inidat,
                                   ws.fimdat
       end if
    end if
 end if


 foreach c_cts03g00 into  ws.atddat,
                          a_cts03g00[arr_aux].atdhor,
                          ws.atdsrvnum,
                          ws.atdsrvano,
                          ws.atdsrvorg,
                          a_cts03g00[arr_aux].atdprscod,
                          a_cts03g00[arr_aux].atdvclsgl,
                          ws.socvclcod,
                          ws.asitipcod

    if ws.atdsrvnum  =  param.atdsrvnum   and
       ws.atdsrvano  =  param.atdsrvano   then
       initialize a_cts03g00[arr_aux].*   to null
       continue foreach
    end if

    open  c_datmsrvacp using ws.atdsrvnum,
                             ws.atdsrvano,
                             ws.atdsrvnum,
                             ws.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    if ws.atdetpcod = 5  or    ### Servico CANCELADO
       ws.atdetpcod = 6  then  ### Servico EXCLUIDO
       continue foreach
    end if
    close c_datmsrvacp

    initialize a_cts03g00[arr_aux].nomgrr        to null
    initialize a_cts03g00[arr_aux].srvtipabvdes  to null
    initialize ws.lclnumseq, ws.rmerscseq        to null

    let a_cts03g00[arr_aux].atdsrvdat = ws.atddat[01,05]

    select srvtipabvdes
      into a_cts03g00[arr_aux].srvtipabvdes
      from datksrvtip
     where atdsrvorg = ws.atdsrvorg

    if ws.atdsrvorg = 9 then

       select socntzcod
             ,lclnumseq
             ,rmerscseq
         into ws.socntzcod
             ,ws.lclnumseq
             ,ws.rmerscseq
         from datmsrvre
        where atdsrvnum = ws.atdsrvnum
          and atdsrvano = ws.atdsrvano

       if sqlca.sqlcode = 0 then
          select socntzdes
            into a_cts03g00[arr_aux].tipnat
            from datksocntz
           where socntzcod = ws.socntzcod
       end if
    else
       select asitipabvdes
         into a_cts03g00[arr_aux].tipnat
         from datkasitip
        where asitipcod = ws.asitipcod
    end if

    ---> Despreza Atendimentos que nao sao da mesma Seq. Local / Bloco
    ---> Para os casos antigos (sem a Seq./Bloco) que nao tinham a informacao
    ---> mostra para qualquer documento

    if ws.lclnumseq is not null and
       ws.lclnumseq <> 0        then

       if ws.lclnumseq <> g_documento.lclnumseq or
          ws.rmerscseq <> g_documento.rmerscseq then
          continue foreach
       end if
    end if

    if a_cts03g00[arr_aux].atdprscod  is not null   then

       if ws.atdsrvorg   =  14  then
          select vdrrprgrpnom
              into a_cts03g00[arr_aux].nomgrr
              from adikvdrrprgrp
             where vdrrprgrpcod  =  a_cts03g00[arr_aux].atdprscod
       else
          select nomgrr
            into a_cts03g00[arr_aux].nomgrr
            from dpaksocor
           where pstcoddig = a_cts03g00[arr_aux].atdprscod

          if ws.socvclcod  is not null   then
             select atdvclsgl
               into a_cts03g00[arr_aux].atdvclsgl
               from datkveiculo
              where socvclcod  =  ws.socvclcod
          end if
       end if
    end if

    let a_cts03g00[arr_aux].servico = ws.atdsrvorg using "&&", "/",
                                      ws.atdsrvnum using "&&&&&&&", "-",
                                      ws.atdsrvano using "&&"
    let arr_aux = arr_aux + 1
    if arr_aux  >  07   then
       error " Limite excedido, pesquisa com mais de 7 servicos solicitados!"
       exit foreach
    end if
 end foreach

 #------------------------------------------------------------------------
 # Exibe servicos solicitados a 24/48 horas
 #------------------------------------------------------------------------
 call set_count(arr_aux-1)

 if arr_aux  >  1   then
    open window w_cts03g00 at 10,05 with form "cts03g00"
         attribute(form line 1, border, message line last - 1)

    let ws.cabec =
        "Outros servicos solicitados no prazo de 24/48 horas para esta ",
        ws.tippsqdes
    display by name ws.cabec

    message " (F17)Abandona"

    display array a_cts03g00 to s_cts03g00.*
       on key (interrupt)
          exit display
    end display

    close window  w_cts03g00
 end if

 close c_cts03g00
 let int_flag = false

 set isolation to committed read

end function  ###  cts03g00
