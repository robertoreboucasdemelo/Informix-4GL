###############################################################################
# Nome do Modulo: ctc32m05                                            Marcelo #
#                                                                    Gilberto #
# Relacao de Bloqueio de Atendimento                                 Mai/1998 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
# 13/07/2001  Claudinha    Ruiz         tirar o prepare gcaksusep,gcakfilial, #
#                                       gcakcorr.                             #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#-----------------------------------------------------------------------------#
# 31/12/2009  Amilton, Meta                      Projetos Succod Smallint     #
#-----------------------------------------------------------------------------#
###############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"

 define ws_pipe        char(20)

#---------------------------------------------------------------
 function ctc32m05()
#---------------------------------------------------------------

 define d_ctc32m05    record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    vclchsinc         like datkblq.vclchsinc,
    vclchsfnl         like datkblq.vclchsfnl,
    corsus            like datkblq.corsus,
    cornom            like gcakcorr.cornom,
    pstcoddig         like datkblq.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    segnumdig         like datkblq.segnumdig,
    segnom            like gsakseg.segnom,
    ctgtrfcod         like datkblq.ctgtrfcod,
    blqnivcod         like datkblq.blqnivcod,
    blqnivdes         char(15),
    blqanlflg         like datkblq.blqanlflg,
    caddat            like datkblq.caddat,
    blqchvcod         dec(1,0)
 end record

 define ws            record
    impr              char(08),
    ok                integer,
    comando           char(500)
 end record


 initialize  d_ctc32m05.*  to null
 initialize  ws.*          to null

 let ws.comando = " select nomrazsoc ",
                  "   from dpaksocor ",
                  "  where pstcoddig = ? "
 prepare select_prest   from        ws.comando
 declare c_ctc32m05prs  cursor for  select_prest

 let ws.comando = " select segnom    ",
                  "   from gsakseg   ",
                  "  where segnumdig = ? "
 prepare select_segur   from        ws.comando
 declare c_ctc32m05seg  cursor for  select_segur

#let ws.comando = " select cornom ",
#                 "   from gcaksusep, gcakcorr ",
#                 "  where gcaksusep.corsus     = ? ",
#                 "    and gcakcorr.corsuspcp   = gcaksusep.corsuspcp "
#prepare select_corret  from        ws.comando
#declare c_ctc32m05cor  cursor for  select_corret


 call fun_print_seleciona (g_issk.dptsgl,"")
      returning  ws.ok, ws.impr

 if ws.ok  =  0   then
    error " Departamento/Impressora nao cadastrada!"
    return
 else
    if ws.impr  is null   then
       error " Uma impressora deve ser selecionada!"
       return
    else
       let ws_pipe = "lp -sd ", ws.impr
    end if
 end if

 start report  rep_bloqueios  to  pipe ws_pipe

 declare c_ctc32m05  cursor for
    select blqnum   , viginc   ,  vigfnl,
           ramcod   , succod   , aplnumdig,
           itmnumdig, vcllicnum, vclchsinc,
           vclchsfnl, corsus   , pstcoddig,
           segnumdig, ctgtrfcod, blqnivcod,
           blqanlflg, caddat
      from datkblq
     where datkblq.blqnum > 0

 foreach  c_ctc32m05  into  d_ctc32m05.blqnum,
                            d_ctc32m05.viginc,
                            d_ctc32m05.vigfnl,
                            d_ctc32m05.ramcod,
                            d_ctc32m05.succod,
                            d_ctc32m05.aplnumdig,
                            d_ctc32m05.itmnumdig,
                            d_ctc32m05.vcllicnum,
                            d_ctc32m05.vclchsinc,
                            d_ctc32m05.vclchsfnl,
                            d_ctc32m05.corsus,
                            d_ctc32m05.pstcoddig,
                            d_ctc32m05.segnumdig,
                            d_ctc32m05.ctgtrfcod,
                            d_ctc32m05.blqnivcod,
                            d_ctc32m05.blqanlflg,
                            d_ctc32m05.caddat

    let d_ctc32m05.blqchvcod = 0
    initialize d_ctc32m05.cornom     to null
    initialize d_ctc32m05.segnom     to null
    initialize d_ctc32m05.nomrazsoc  to null

    if d_ctc32m05.ramcod   is not null   then
       let d_ctc32m05.blqchvcod = 1
    end if

    if d_ctc32m05.vcllicnum   is not null   then
       let d_ctc32m05.blqchvcod = 2
    end if

    if d_ctc32m05.vclchsfnl   is not null   then
       let d_ctc32m05.blqchvcod = 3
    end if

    if d_ctc32m05.corsus      is not null   then
       let d_ctc32m05.blqchvcod = 4

      #open  c_ctc32m05cor using d_ctc32m05.corsus
      #fetch c_ctc32m05cor into  d_ctc32m05.cornom
       select cornom
          into d_ctc32m05.cornom
          from gcaksusep, gcakcorr
         where gcaksusep.corsus     = d_ctc32m05.corsus
           and gcakcorr.corsuspcp   = gcaksusep.corsuspcp
    end if

    if d_ctc32m05.pstcoddig   is not null   then
       let d_ctc32m05.blqchvcod = 5

       open  c_ctc32m05prs using d_ctc32m05.pstcoddig
       fetch c_ctc32m05prs into  d_ctc32m05.nomrazsoc
    end if

    if d_ctc32m05.segnumdig   is not null   then
       let d_ctc32m05.blqchvcod = 6

       open  c_ctc32m05seg using d_ctc32m05.segnumdig
       fetch c_ctc32m05seg into  d_ctc32m05.segnom
    end if

    if d_ctc32m05.ctgtrfcod   is not null   then
       let d_ctc32m05.blqchvcod = 7
    end if

    output to report rep_bloqueios (d_ctc32m05.*)

 end foreach

 finish report rep_bloqueios
 close c_ctc32m05

end function   ##-- ctc32m05


#---------------------------------------------------------------------------
 report rep_bloqueios(r_ctc32m05)
#---------------------------------------------------------------------------

 define r_ctc32m05    record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    vclchsinc         like datkblq.vclchsinc,
    vclchsfnl         like datkblq.vclchsfnl,
    corsus            like datkblq.corsus,
    cornom            like gcakcorr.cornom,
    pstcoddig         like datkblq.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    segnumdig         like datkblq.segnumdig,
    segnom            like gsakseg.segnom,
    ctgtrfcod         like datkblq.ctgtrfcod,
    blqnivcod         like datkblq.blqnivcod,
    blqnivdes         char(15),
    blqanlflg         like datkblq.blqanlflg,
    caddat            like datkblq.caddat,
    blqchvcod         dec(1,0)
 end record

 define ws2           record
    comando           char(300),
    traco             char(134),
    privez            char(01),
    cabrestr          char(11),
    blqtotqtd         dec(6,0),
    blqtotchv         dec(6,0),
    empcod            like datrastfun.empcod,
    funmat            like datrastfun.funmat,
    funnom            like isskfunc.funnom,
    c24astcod         like datrastblq.c24astcod,
    c24astdes         char(72),
    blqchvcod         dec(1,0),
    blqchvdes         char(09),
    blqchvcnt         char(25),
    blqnivdes         char(08),
    blqanldes         char(03),
    blqobstxt         like datmblqobs.blqobstxt,
    descricao         char(43)
 end record


 output report to  pipe  ws_pipe
    left   margin  00
    right  margin  134
    top    margin  00
    bottom margin  00
    page   length  60

 order by  r_ctc32m05.blqchvcod,
           r_ctc32m05.viginc

 format

    page header
       if pageno  =  1   then

          let ws2.blqtotqtd = 0
          let ws2.blqtotchv = 0

          case r_ctc32m05.blqchvcod
               when  1   let ws2.blqchvdes = "APOLICE"
               when  2   let ws2.blqchvdes = "PLACA"
               when  3   let ws2.blqchvdes = "CHASSI"
               when  4   let ws2.blqchvdes = "SUSEP"
               when  5   let ws2.blqchvdes = "PRESTADOR"
               when  6   let ws2.blqchvdes = "SEGURADO"
               when  7   let ws2.blqchvdes = "C.TARIF."
          end case

          let ws2.traco ="-------------------------------------------------------------------------------------------------------------------------------------"

          let ws2.comando = "select blqobstxt ",
                           "  from datmblqobs ",
                           " where blqnum = ? "
          prepare select_observ  from        ws2.comando
          declare c_ctc32m05o    cursor for  select_observ

          let ws2.comando = "select c24astcod ",
                           "  from datrastblq ",
                           " where blqnum    = ? ",
                           "   and astblqsit = 'A' "
          prepare select_assunto from        ws2.comando
          declare c_ctc32m05a    cursor for  select_assunto

          let ws2.comando = "select datrfunblqlib.empcod, ",
                            "       datrfunblqlib.funmat, ",
                            "       isskfunc.funnom     ",
                            "  from datrfunblqlib, isskfunc",
                            " where datrfunblqlib.blqnum = ? ",
                            "   and isskfunc.empcod = datrfunblqlib.empcod ",
                            "   and isskfunc.funmat = datrfunblqlib.funmat "
          prepare select_matric from        ws2.comando
          declare c_ctc32m05m   cursor for  select_matric

       end if

       print column 104, "CTC32M05",
             column 115, "PAGINA : ", pageno using "##,###,##&"

       print column 115, "DATA   : ", today
       print column 044, "RELACAO DE BLOQUEIOS DE ATENDIMENTO",
             column 115, "HORA   :   ", time
       print column 001, "CHAVE : ", ws2.blqchvdes

       print column 001, ws2.traco
       print column 001, "NR.BLOQUEIO",
             column 015, "DT.CADASTRO",
             column 029, "VIG.INICIAL",
             column 044, "VIG.FINAL",
             column 056, "NIVEL",
             column 068, "ANALISE",
             column 078, "CHAVE"

       print ws2.traco
       skip 1 line

    before group of r_ctc32m05.blqchvcod
       case r_ctc32m05.blqchvcod
            when  1   let ws2.blqchvdes = "APOLICE"
            when  2   let ws2.blqchvdes = "PLACA"
            when  3   let ws2.blqchvdes = "CHASSI"
            when  4   let ws2.blqchvdes = "SUSEP"
            when  5   let ws2.blqchvdes = "PRESTADOR"
            when  6   let ws2.blqchvdes = "SEGURADO"
            when  7   let ws2.blqchvdes = "C.TARIF."
       end case
       skip to top of page

    after group of r_ctc32m05.blqchvcod
      need 6 lines
      skip 3 lines
      print column 001, ws2.traco
      print column 001, "TOTAL DE BLOQUEIOS      : ",
                        ws2.blqtotchv  using "###,#&&"
      print column 001, ws2.traco

      let ws2.blqtotqtd = ws2.blqtotqtd + ws2.blqtotchv
      let ws2.blqtotchv = 0

    on every row
       initialize ws2.descricao  to null

       case r_ctc32m05.blqnivcod
            when 01   let ws2.blqnivdes = "ALERTA"
            when 02   let ws2.blqnivdes = "SENHA"
            when 03   let ws2.blqnivdes = "N.ATENDE"
       end case

       case r_ctc32m05.blqanlflg
            when "S"  let ws2.blqanldes = "SIM"
            when "N"  let ws2.blqanldes = "NAO"
       end case

       if r_ctc32m05.ramcod      is not null   then

          if r_ctc32m05.ramcod  =  31  or  
             r_ctc32m05.ramcod  =  531  then
             let ws2.blqchvcnt =
                 r_ctc32m05.ramcod     using "&&&&"       clipped, "/",
                 r_ctc32m05.succod     using "###&&"      clipped, "/",#using "&&"         clipped, "/", #Projeto Succod
                 r_ctc32m05.aplnumdig  using "<<<<<<<<<"  clipped, "/",
                 r_ctc32m05.itmnumdig  using "<<<<<<<"    clipped
          else
             let ws2.blqchvcnt =
                 r_ctc32m05.ramcod     using "&&&&"       clipped, "/",
                 r_ctc32m05.succod     using "###&&"      clipped, "/", #using "&&"         clipped, "/", # Projeto Succod
                 r_ctc32m05.aplnumdig  using "<<<<<<<<<"
          end if
       end if

       if r_ctc32m05.vcllicnum   is not null   then
          let ws2.blqchvcnt = r_ctc32m05.vcllicnum
       end if

       if r_ctc32m05.vclchsinc   is not null   then
          let ws2.blqchvcnt = r_ctc32m05.vclchsinc clipped, r_ctc32m05.vclchsfnl
       end if

       if r_ctc32m05.corsus      is not null   then
          let ws2.blqchvcnt = r_ctc32m05.corsus
          let ws2.descricao = " - ", r_ctc32m05.cornom
       end if

       if r_ctc32m05.pstcoddig   is not null   then
          let ws2.blqchvcnt = r_ctc32m05.pstcoddig
          let ws2.descricao = " - ", r_ctc32m05.nomrazsoc
       end if

       if r_ctc32m05.segnumdig   is not null   then
          let ws2.blqchvcnt = r_ctc32m05.segnumdig
          let ws2.descricao = " - ", r_ctc32m05.segnom
       end if

       if r_ctc32m05.ctgtrfcod   is not null   then
          let ws2.blqchvcnt = r_ctc32m05.ctgtrfcod
       end if

       print column 005, r_ctc32m05.blqnum     using "###,#&&",
             column 016, r_ctc32m05.caddat,
             column 030, r_ctc32m05.viginc,
             column 043, r_ctc32m05.vigfnl,
             column 056, ws2.blqnivdes,
             column 070, ws2.blqanldes,
             column 078, ws2.blqchvcnt  clipped, ws2.descricao

       #-------------------------------------------------------------------
       # Verifica se existe observacoes para o bloqueio
       #-------------------------------------------------------------------
       let ws2.privez  =  "s"
       let ws2.cabrestr = "OBSERVACAO:"

       open    c_ctc32m05o using r_ctc32m05.blqnum
       foreach c_ctc32m05o into  ws2.blqobstxt

         if ws2.privez  =  "s"   then
            skip 1 line
            print column 023, ws2.cabrestr;
            let ws2.privez  =  "n"
         end if

         print column 036, ws2.blqobstxt
         initialize ws2.cabrestr  to null

       end foreach

       #--------------------------------------------------------------------
       # Verifica se existe assuntos para o bloqueio
       #--------------------------------------------------------------------
       let ws2.privez  =  "s"
       let ws2.cabrestr = "ASSUNTOS  :"

       open    c_ctc32m05a using r_ctc32m05.blqnum
       foreach c_ctc32m05a into  ws2.c24astcod

         if ws2.privez  =  "s"   then
            skip 1 line
            print column 023, ws2.cabrestr;
            let ws2.privez  =  "n"
         end if

         call c24geral8(ws2.c24astcod)  returning ws2.c24astdes

         print column 036, ws2.c24astcod, " - ", ws2.c24astdes
         initialize ws2.cabrestr  to null

       end foreach

       #--------------------------------------------------------------------
       # Verifica se existe matriculas para o bloqueio
       #--------------------------------------------------------------------
       initialize  ws2.empcod, ws2.funmat, ws2.funnom  to null
       let ws2.privez  =  "s"
       let ws2.cabrestr = "MATRICULAS:"

       open    c_ctc32m05m using r_ctc32m05.blqnum
       foreach c_ctc32m05m into  ws2.empcod,
                                 ws2.funmat,
                                 ws2.funnom

         if ws2.privez  =  "s"   then
            skip 1 line
            print column 023, ws2.cabrestr;
            let ws2.privez  =  "n"
         end if

         print column 036, ws2.funmat  using "<<<<&&",
                    " - ", ws2.funnom
         initialize ws2.cabrestr  to null

       end foreach
       let ws2.blqtotchv = ws2.blqtotchv + 1
       skip 1 line

    on last row
      need 6 lines
      skip 3 lines
      print column 001, ws2.traco
      print column 001, "TOTAL GERAL DE BLOQUEIOS: ",
                        ws2.blqtotqtd  using "###,#&&"
      print column 001, ws2.traco

end report   ##-- ctc32m05
