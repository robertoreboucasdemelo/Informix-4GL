##############################################################################
# Nome do Modulo: CTS22G00                                         Wagner    #
#                                                                            #
# Verifica outros servicos da mesma apolice                        Abr/2001  #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
# 14/01/2002  AS  2639-5   Ruiz         Mostra os servico, sinistro RE, para #
#                                       a apolice.                           #
#----------------------------------------------------------------------------#
# 22/09/06   Ligia Mattge  PSI 202720    Implementacao do grupo/cartao Saude #
#----------------------------------------------------------------------------#
# 19/04/10  Carla Rampazzo 219444       Filtrar Atd. p/ mostrar so os que se #
#                                       relacionam com Local de Risco / Bloco#
#----------------------------------------------------------------------------#
##############################################################################

globals '/homedsa/projetos/geral/globals/glct.4gl'

#-----------------------------------------------------------------------------
 function cts22g00(param)
#-----------------------------------------------------------------------------

 define param          record
        succod         like datrservapol.succod,
        ramcod         like datrservapol.ramcod,
        aplnumdig      like datrservapol.aplnumdig,
        itmnumdig      like datrservapol.itmnumdig,
        atdsrvorg      like datmservico.atdsrvorg,
        vcllicnum      like datmservico.vcllicnum,
        nrdias         integer,
        bnfnum         like datrligsau.bnfnum,
        cgccpfnum      like datrligcgccpf.cgccpfnum ,
        cgcord         like datrligcgccpf.cgcord,
        cgccpfdig      like datrligcgccpf.cgccpfdig,
        programa       char(8)
        end record

 define a_cts22g00     array[50]  of record
        atddat         like datmservico.atddat,
        atdhor         like datmservico.atdhor,
        atdsrvorg      like datmservico.atdsrvorg,
        atdsrvnum      like datmservico.atdsrvnum,
        atdsrvano      like datmservico.atdsrvano,
        srvtipabvdes   char (15)                   ,
        atendente      char (10),
        c24solnom      like datmservico.c24solnom
                       end record

 define ws             record
        retflg         decimal (1,0),
        inidat         date,
        fimdat         date,
        funmat         like datmservico.funmat,
        atdetpcod      like datmsrvacp.atdetpcod,
        sql            char (700),
        descr          char (70),
        tpnat          char (10),
        socntzcod      like datmsrvre.socntzcod,
        viginc         like abbmdoc.viginc,
        vigfnl         like abbmdoc.vigfnl,
        iniper         char (10),
        fimper         char (10),
        confirma       char (01), # PSI 243.647
        utilizados     char (02)  # PSI 243.647
       ,lclnumseq      like datmsrvre.lclnumseq
       ,rmerscseq      like datmsrvre.rmerscseq
 end record

 define arr_aux        smallint
 define scr_aux        smallint
 define l_flag         smallint



#------------------------------------------------------------------------
# Limpa campos / Monta comandos SQL
#------------------------------------------------------------------------


 define w_pf1 integer

 let arr_aux = null
 let scr_aux = null
 let l_flag = false

 for w_pf1 = 1 to 50
     initialize  a_cts22g00[w_pf1].*  to  null
 end for


 initialize a_cts22g00   to null
 initialize ws.*         to null
 let arr_aux = 1

 if ((param.succod    is null   or
     param.ramcod    is null   or
     param.aplnumdig is null   or
     param.itmnumdig is null)  and
     g_ppt.cmnnumdig is null and
    (param.vcllicnum is null)) and
     param.bnfnum    is null  and
     param.cgccpfnum is null then
    return  a_cts22g00[arr_aux].atdsrvnum,
            a_cts22g00[arr_aux].atdsrvano,
            a_cts22g00[arr_aux].atdsrvorg
 end if


 if param.atdsrvorg = 9 then  # busca vigencia apolice

    if g_ppt.cmnnumdig is null  and
       param.bnfnum    is null  and
       g_documento.ramcod = 531 then

       select viginc, vigfnl
         into ws.viginc,ws.vigfnl
         from abamapol
        where abamapol.succod    = g_documento.succod     and
              abamapol.aplnumdig = g_documento.aplnumdig
       let ws.inidat = ws.viginc
       let ws.fimdat = ws.vigfnl
    else
       if g_ppt.cmnnumdig is not null then
          let ws.inidat = g_ppt.viginc
          let ws.fimdat = g_ppt.vigfnl
       else
          if param.bnfnum is not null then
             --------[ monta periodo para serviços saude psi202720 ]------
             let ws.iniper = '01/01/', year(today) using "####"
             let ws.fimper = '31/12/', year(today) using "####"
             let ws.inidat = ws.iniper
             let ws.fimdat = ws.fimper
          else
             let ws.inidat = today - param.nrdias units day
             let ws.fimdat = today
          end if
       end if
    end if
 else
    let ws.inidat = today - param.nrdias units day
    let ws.fimdat = today
 end if
 let int_flag  = false

 message " Aguarde, pesquisando..." attribute (reverse)

 if param.bnfnum    is not null then
    let ws.sql = "select datmservico.atddat    , ",
                 "       datmservico.atdhor    , ",
                 "       datmservico.atdsrvnum , ",
                 "       datmservico.atdsrvano , ",
                 "       datmservico.funmat    , ",
                 "       datmservico.c24solnom , ",
                 "       datmservico.atdsrvorg   ",
                 "  from datrsrvsau,datmservico",
                 " where datrsrvsau.bnfnum     =  ? ",
                 "   and datmservico.atdsrvnum   =  datrsrvsau.atdsrvnum ",
                 "   and datmservico.atdsrvano   =  datrsrvsau.atdsrvano ",
                 "   and datmservico.atdsrvorg   =  9 ",
                 " order by atddat desc, atdhor asc"

 else
    if param.succod    is not null   and
       param.ramcod    is not null   and
       param.aplnumdig is not null   and
       param.itmnumdig is not null   then
       if param.atdsrvorg = 9 then   # porto socorro RE

          if g_documento.c24astcod = "PE3"  then
             let ws.sql = "select b.atddat    , ",
                          "       b.atdhor    , ",
                          "       b.atdsrvnum , ",
                          "       b.atdsrvano , ",
                          "       b.funmat    , ",
                          "       b.c24solnom , ",
                          "       b.atdsrvorg   ",
                          "  from datrservapol a, datmservico b, datmligacao c ",
                          " where a.succod     =  ? ",
                          "   and a.ramcod     =  ? ",
                          "   and a.aplnumdig  =  ? ",
                          "   and a.edsnumref >=  0 ",
                          "   and b.atdsrvnum   =  a.atdsrvnum ",
                          "   and b.atdsrvano   =  a.atdsrvano ",
                          "   and b.atdsrvnum   =  c.atdsrvnum ",
                          "   and b.atdsrvano   =  c.atdsrvano ",
                          "   and a.atdsrvnum   =  c.atdsrvnum ",
                          "   and a.atdsrvano   =  c.atdsrvano ",
                          "   and b.atdsrvorg   =  9           ",
                          "   and c.c24astcod   =  'PE1' ", # '", g_documento.c24astcod , "'",
                          " order by atddat desc, atdhor asc                   "
          else
            let ws.sql = "select datmservico.atddat    , ",
                         "       datmservico.atdhor    , ",
                         "       datmservico.atdsrvnum , ",
                         "       datmservico.atdsrvano , ",
                         "       datmservico.funmat    , ",
                         "       datmservico.c24solnom , ",
                         "       datmservico.atdsrvorg   ",
                         "  from datrservapol,datmservico",
                         " where datrservapol.succod     =  ? ",
                         "   and datrservapol.ramcod     =  ? ",
                         "   and datrservapol.aplnumdig  =  ? ",
                         "   and datrservapol.itmnumdig  =  ? ",
                         "   and datrservapol.edsnumref >=  0 ",
                         "   and datmservico.atdsrvnum   =  datrservapol.atdsrvnum ",
                         "   and datmservico.atdsrvano   =  datrservapol.atdsrvano ",
                         "   and datmservico.atdsrvorg   =  9 ",
                         " order by atddat desc, atdhor asc "
          end if
       else

          if param.atdsrvorg is null then
             let ws.sql = "select datmservico.atddat    , ",
                    "       datmservico.atdhor    , ",
                    "       datmservico.atdsrvnum , ",
                    "       datmservico.atdsrvano , ",
                    "       datmservico.funmat    , ",
                    "       datmservico.c24solnom , ",
                    "       datmservico.atdsrvorg   ",
                    "  from datrservapol,datmservico",
                    " where datrservapol.succod     =  ? ",
                    "   and datrservapol.ramcod     =  ? ",
                    "   and datrservapol.aplnumdig  =  ? ",
                    "   and datrservapol.itmnumdig  =  ? ",
                    "   and datrservapol.edsnumref >=  0 ",
                    "   and datmservico.atdsrvnum   =  datrservapol.atdsrvnum ",
                    "   and datmservico.atdsrvano   =  datrservapol.atdsrvano ",
                    " order by atddat desc, atdhor asc"
          else

              let ws.sql = "select datmservico.atddat    , ",
                       "       datmservico.atdhor    , ",
                       "       datmservico.atdsrvnum , ",
                       "       datmservico.atdsrvano , ",
                       "       datmservico.funmat    , ",
                       "       datmservico.c24solnom , ",
                       "       datmservico.atdsrvorg   ",
                       "  from datrservapol,datmservico",
                       " where datrservapol.succod     =  ? ",
                       "   and datrservapol.ramcod     =  ? ",
                       "   and datrservapol.aplnumdig  =  ? ",
                       "   and datrservapol.itmnumdig  =  ? ",
                       "   and datrservapol.edsnumref >=  0 ",
                       "   and datmservico.atdsrvnum   =  datrservapol.atdsrvnum ",
                       "   and datmservico.atdsrvano   =  datrservapol.atdsrvano ",
                       "   and datmservico.atdsrvorg   =  ",param.atdsrvorg ,
                       " order by atddat desc, atdhor asc"
          end if
       end if
    else
       if g_ppt.cmnnumdig is not null then

             let ws.sql = "select datmservico.atddat    , ",
                       "          datmservico.atdhor    , ",
                       "          datmservico.atdsrvnum , ",
                       "          datmservico.atdsrvano , ",
                       "          datmservico.funmat    , ",
                       "          datmservico.c24solnom , ",
                       "          datmservico.atdsrvorg   ",
                       "     from datmservico, datmligacao, datrligppt  ",
                       "    where datmservico.atdsrvnum = datmligacao.atdsrvnum ",
                       "      and datmservico.atdsrvano = datmligacao.atdsrvano ",
                       "      and datrligppt.lignum     = datmligacao.lignum ",
                       "      and datrligppt.cmnnumdig  = ? ",
                       "      and datmservico.atddat between  ?  and  ?   ",
                       "    and datmservico.atdsrvorg in (1,2,3,4,5,6,8,9,13,14) ",
                       " order by datmservico.atddat desc, atdhor asc "
       else
          if param.vcllicnum is not null  then

             let ws.sql = "select datmservico.atddat    , ",
                          "       datmservico.atdhor    , ",
                          "       datmservico.atdsrvnum , ",
                          "       datmservico.atdsrvano , ",
                          "       datmservico.funmat    , ",
                          "       datmservico.c24solnom , ",
                          "       datmservico.atdsrvorg   ",
                          "  from datmservico             ",
                          " where datmservico.atddat between  ?  and  ?   ",
                          "  and datmservico.atdsrvorg in (1,2,3,4,5,6,8,9,13,14)",
                          "   and datmservico.vcllicnum   =  ? ",
                          " order by atddat desc, atdhor asc   "
          else
              if param.cgccpfnum is not null then

                   let ws.sql = "select datmservico.atddat    , ",
                                "       datmservico.atdhor    , ",
                                "       datmservico.atdsrvnum , ",
                                "       datmservico.atdsrvano , ",
                                "       datmservico.funmat    , ",
                                "       datmservico.c24solnom , ",
                                "       datmservico.atdsrvorg   ",
                                "  from datrligcgccpf         , ",
                                "       datmligacao           , ",
                                "       datmservico             ",
                                " where datrligcgccpf.lignum = datmligacao.lignum ",
                                " and datmligacao.atdsrvnum = datmservico.atdsrvnum ",
                                " and datmligacao.atdsrvano = datmservico.atdsrvano ",
                                " and datrligcgccpf.cgccpfnum = ? ",
                                " and datrligcgccpf.cgcord = ? ",
                                " and datrligcgccpf.cgccpfdig = ? " ,
                                " and datmligacao.ciaempcod = 40 "
              else
                  initialize a_cts22g00   to null
                  return a_cts22g00[arr_aux].atdsrvnum,
                         a_cts22g00[arr_aux].atdsrvano,
                         a_cts22g00[arr_aux].atdsrvorg
              end if
          end if
       end if
    end if

 end if

 prepare sel_datmservico  from ws.sql
 declare c_cts22g00 cursor for sel_datmservico
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

 set isolation to dirty read

 if param.bnfnum     is not null   then
    open c_cts22g00 using param.bnfnum
 else
    if param.aplnumdig   is not null   then

       if g_documento.c24astcod = "PE3"  then
          open c_cts22g00 using param.succod   ,
                                param.ramcod   ,
                                param.aplnumdig
       else
          open c_cts22g00 using param.succod   ,
                                param.ramcod   ,
                                param.aplnumdig,
                                param.itmnumdig
       end if
    else
       if g_ppt.cmnnumdig is not null then
          open c_cts22g00 using g_ppt.cmnnumdig,
                                ws.inidat,
                                ws.fimdat
       else
           if param.cgccpfnum is not null then
               open c_cts22g00 using param.cgccpfnum ,
                                     param.cgcord    ,
                                     param.cgccpfdig
           else
               open c_cts22g00 using ws.inidat, ws.fimdat,
                                     param.vcllicnum
           end if
       end if
    end if
 end if

 foreach c_cts22g00 into  a_cts22g00[arr_aux].atddat,
                          a_cts22g00[arr_aux].atdhor,
                          a_cts22g00[arr_aux].atdsrvnum,
                          a_cts22g00[arr_aux].atdsrvano,
                          ws.funmat,
                          a_cts22g00[arr_aux].c24solnom,
                          a_cts22g00[arr_aux].atdsrvorg
    if a_cts22g00[arr_aux].atddat < ws.inidat  or
       a_cts22g00[arr_aux].atddat > ws.fimdat  then
       continue foreach
    end if

    if a_cts22g00[arr_aux].atdsrvorg =  1   or
       a_cts22g00[arr_aux].atdsrvorg =  2   or
       a_cts22g00[arr_aux].atdsrvorg =  3   or
       a_cts22g00[arr_aux].atdsrvorg =  4   or
       a_cts22g00[arr_aux].atdsrvorg =  5   or
       a_cts22g00[arr_aux].atdsrvorg =  6   or
       a_cts22g00[arr_aux].atdsrvorg =  8   or
       a_cts22g00[arr_aux].atdsrvorg =  9   or
       a_cts22g00[arr_aux].atdsrvorg = 13   or
       a_cts22g00[arr_aux].atdsrvorg = 14   then
    else
       continue foreach
    end if

    open  c_datmsrvacp using a_cts22g00[arr_aux].atdsrvnum,
                             a_cts22g00[arr_aux].atdsrvano,
                             a_cts22g00[arr_aux].atdsrvnum,
                             a_cts22g00[arr_aux].atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod

    if ws.atdetpcod = 5  or    ### Servico CANCELADO
       ws.atdetpcod = 6  or    ### Servico EXCLUIDO
       ws.atdetpcod = 10 then  ### Retorno
       continue foreach
    end if

    close c_datmsrvacp

    initialize a_cts22g00[arr_aux].srvtipabvdes
              ,ws.lclnumseq
              ,ws.rmerscseq  to null

    if param.atdsrvorg  =  9  then   # porto socorro RE busca natureza

       select socntzcod
             ,lclnumseq
             ,rmerscseq
         into ws.socntzcod
             ,ws.lclnumseq
             ,ws.rmerscseq
         from datmsrvre
        where atdsrvnum = a_cts22g00[arr_aux].atdsrvnum
          and atdsrvano = a_cts22g00[arr_aux].atdsrvano

       if sqlca.sqlcode = 0 then
          select socntzdes
            into a_cts22g00[arr_aux].srvtipabvdes
            from datksocntz
           where socntzcod = ws.socntzcod
       end if
    else
       select srvtipabvdes
          into a_cts22g00[arr_aux].srvtipabvdes
          from datksrvtip
         where atdsrvorg = a_cts22g00[arr_aux].atdsrvorg
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


    initialize a_cts22g00[arr_aux].atendente  to null

    select funnom
      into a_cts22g00[arr_aux].atendente
      from isskfunc
     where empcod = 1
       and funmat = ws.funmat

    let a_cts22g00[arr_aux].atendente = upshift(a_cts22g00[arr_aux].atendente)

    let arr_aux = arr_aux + 1
    if arr_aux  >  50   then
       error " Limite excedido, pesquisa com mais de 50 servicos solicitados!"
       exit foreach
    end if

 end foreach

 message ""

#------------------------------------------------------------------------
# Exibe servicos solicitados
#------------------------------------------------------------------------
 call set_count(arr_aux-1)

 let ws.utilizados = arr_aux - 1

 if arr_aux  >  1  then
    open window w_cts22g00 at 10,05 with form "cts22g00"
         attribute(form line 1, border, message line last - 1)

    display param.nrdias to nrdias attribute (reverse)

    if param.atdsrvorg = 9 then
       let ws.tpnat = "Natureza"
       let ws.descr = "Servicos de P.S. RE solicitados por esta apolice ",
                      "nos ultimos"

       if g_documento.c24astcod = "PE3" then
          let ws.descr = "Consta(m) ", ws.utilizados , " atendimento(s) na apolice ",
                         "nos ultimos"
       end if
    else
       let ws.tpnat = "Tipo    "
       let ws.descr = "      Servicos solicitados por esta apolice nos ultimos"
    end if

    display ws.descr to descr attribute (reverse)
    display ws.tpnat to tpnat
    if param.programa = "cta02m00" then
           message " (F17)Abandona, (F7)Laudo, (F8)Seleciona"
    else
           message "                  (F17)Abandona (F7)Laudo"
    end if

    display array a_cts22g00 to s_cts22g00.*

       on key (interrupt)
          initialize a_cts22g00   to null
          let arr_aux = 1
          exit display

       on key (F7)
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          let g_documento.atdsrvnum = a_cts22g00[arr_aux].atdsrvnum
          let g_documento.atdsrvano = a_cts22g00[arr_aux].atdsrvano

          display a_cts22g00[arr_aux].atdsrvnum  to
                  s_cts22g00[scr_aux].atdsrvnum  attribute(reverse)
          display a_cts22g00[arr_aux].atdsrvano  to
                  s_cts22g00[scr_aux].atdsrvano  attribute(reverse)

          call cts04g00('cts22g00') returning ws.retflg

          display a_cts22g00[arr_aux].atdsrvnum  to
                  s_cts22g00[scr_aux].atdsrvnum
          display a_cts22g00[arr_aux].atdsrvano  to
                  s_cts22g00[scr_aux].atdsrvano


       on key (F8)
          let arr_aux = arr_curr()
          exit display

    end display

    close window  w_cts22g00
 else
    if g_documento.c24astcod = "PE3" then
       call cts08g01 ("A","N","" ,"ATÉ O MOMENTO, NÃO CONSTA ATENDIMENTO" ,
                                  "DE CONSULTA VETERINÁRIA." ,
                                  "LIMITE DISPONÍVEL: 03 ATENDIMENTOS.")
            returning ws.confirma

    end if

    error " Nao existe servicos anteriores para pesquisa!"

    initialize a_cts22g00   to null

    let a_cts22g00[arr_aux].atdsrvorg = 0
 end if

 let int_flag = false

 set isolation to committed read

 return a_cts22g00[arr_aux].atdsrvnum,
        a_cts22g00[arr_aux].atdsrvano,
        a_cts22g00[arr_aux].atdsrvorg

end function  ###  cts22g00
