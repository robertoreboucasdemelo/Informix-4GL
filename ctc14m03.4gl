############################################################################
# Nome do Modulo: CTC14M03                                         Marcelo #
#                                                                 Gilberto #
# Relacao de Assuntos por Agrupamento                             Fev/1996 #
#--------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
############################################################################


 globals "/homedsa/projetos/geral/globals/glct.4gl"   

 define ws_pipe        char(20)

#---------------------------------------------------------------
 function ctc14m03()
#---------------------------------------------------------------

 define d_ctc14m03     record
    c24astagp          like datkassunto.c24astagp,
    c24astagpdes       like datkassunto.c24astdes,
    c24astcod          like datkassunto.c24astcod,
    c24astdes          like datkassunto.c24astdes,
    c24asttltflg       like datkassunto.c24asttltflg,
    c24astatdflg       like datkassunto.c24astatdflg
 end record

 define ws             record
    impr               char(08),
    ok                 integer
 end record


 initialize  d_ctc14m03.*  to null
 initialize  ws.*          to null


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

 start report  rep_assuntos  to  pipe ws_pipe
#start report  rep_assuntos  to  "ruiz.txt"   

 declare c_ctc14m03  cursor for
    select datkastagp.c24astagp,
           datkastagp.c24astagpdes,
           datkassunto.c24astcod,
           datkassunto.c24astdes,
           datkassunto.c24asttltflg,
           datkassunto.c24astatdflg
      from datkastagp, datkassunto
     where datkastagp.c24astagp   is not null
       and datkassunto.c24astagp  =  datkastagp.c24astagp
       and datkassunto.c24aststt  =  "A"

 foreach  c_ctc14m03  into  d_ctc14m03.c24astagp,
                            d_ctc14m03.c24astagpdes,
                            d_ctc14m03.c24astcod,
                            d_ctc14m03.c24astdes,
                            d_ctc14m03.c24asttltflg,
                            d_ctc14m03.c24astatdflg

    output to report rep_assuntos (d_ctc14m03.*)

 end foreach

 finish report rep_assuntos
 close c_ctc14m03

end function   ##-- ctc14m03


#---------------------------------------------------------------------------
 report rep_assuntos(r_ctc14m03)
#---------------------------------------------------------------------------

 define r_ctc14m03     record
    c24astagp          like datkassunto.c24astagp,
    c24astagpdes       like datkassunto.c24astdes,
    c24astcod          like datkassunto.c24astcod,
    c24astdes          like datkassunto.c24astdes,
    c24asttltflg       like datkassunto.c24asttltflg,
    c24astatdflg       like datkassunto.c24astatdflg
 end record

 define ws2            record
    comando            char(300),
    traco              char(134),
    privez             char(01),
    cabrestr           char(10),
    asttotqtd          dec(6,0),
    c24asttltdes       char(03),
    c24astatddes       char(03),
    ramcod             like datrclassassunto.ramcod,
    astrgrcod          like datrclassassunto.astrgrcod,
    astrgrdes          char(10),
    empcod             like datrastfun.empcod,
    funmat             like datrastfun.funmat,
    funnom             like isskfunc.funnom
 end record


 output report to  pipe  ws_pipe
    left   margin  00
    right  margin  134
    top    margin  00
    bottom margin  00
    page   length  60

 order by  r_ctc14m03.c24astagp,
           r_ctc14m03.c24astcod

 format

    page header
       if pageno  =  1   then
          let ws2.asttotqtd = 0
          let ws2.traco ="-------------------------------------------------------------------------------------------------------------------------------------"

          let ws2.comando = "select ramcod, astrgrcod ",
                           "  from datrclassassunto  ",
                           " where c24astcod = ?     "
          prepare select_ramos  from        ws2.comando
          declare c_ctc14m03r   cursor for  select_ramos

          let ws2.comando = "select datrastfun.empcod,  ",
                           "        datrastfun.funmat,  ",
                           "        isskfunc.funnom     ",
                           "  from datrastfun, isskfunc",
                           " where datrastfun.c24astcod = ? ",
                           "   and isskfunc.empcod = datrastfun.empcod ",
                           "   and isskfunc.funmat = datrastfun.funmat "
          prepare select_matric from        ws2.comando
          declare c_ctc14m03m   cursor for  select_matric

       end if

       print column 104, "CTC14M03",
             column 115, "PAGINA : ", pageno using "##,###,##&"

       print column 115, "DATA   : ", today
       print column 044, "RELACAO DE ASSUNTOS POR AGRUPAMENTO",
             column 115, "HORA   :   ", time
       skip 1 line

       print column 001, ws2.traco
       print column 001, "AGRUPAMENTO",
             column 014, "ASSUNTO",
             column 023, "DESCRICAO",
             column 107, "MSG CORRETOR",
             column 121, "ADV ATENDENTE"

       print ws2.traco
       skip 1 line

    after group of r_ctc14m03.c24astagp
       skip 1 line

    on every row

       let ws2.asttotqtd = ws2.asttotqtd + 1
       initialize  ws2.c24asttltdes  to null
       case r_ctc14m03.c24asttltflg
            when "S"  let ws2.c24asttltdes = "SIM"
            when "N"  let ws2.c24asttltdes = "NAO"
       end case

       initialize  ws2.c24astatddes  to null
       case r_ctc14m03.c24astatdflg
            when "S"  let ws2.c24astatddes = "SIM"
            when "N"  let ws2.c24astatddes = "NAO"
       end case

       print column 006, r_ctc14m03.c24astagp,
             column 016, r_ctc14m03.c24astcod,
             column 023, r_ctc14m03.c24astagpdes clipped, " ",
                         r_ctc14m03.c24astdes,
             column 112, ws2.c24asttltdes,
             column 126, ws2.c24astatddes

       #-------------------------------------------------------------------
       # Verifica se existe restricoes de ramos para o codigo de assunto
       #-------------------------------------------------------------------
       initialize  ws2.ramcod, ws2.astrgrcod  to null
       let ws2.privez  =  "s"
       let ws2.cabrestr = "RAMO     :"

       open    c_ctc14m03r using r_ctc14m03.c24astcod
       foreach c_ctc14m03r into  ws2.ramcod,
                                 ws2.astrgrcod

         if ws2.privez  =  "s"   then
            print column 023, "RESTRICOES : ";
            let ws2.privez  =  "n"
         end if

         case ws2.astrgrcod
            when  1    let ws2.astrgrdes = "REGRA"
            when  2    let ws2.astrgrdes = "EXCECAO"
            otherwise  let ws2.astrgrdes = ""
         end case

         print column 037, ws2.cabrestr, "    ", ws2.ramcod   using "##&&",
                                  "   ", ws2.astrgrdes
         initialize ws2.cabrestr  to null

       end foreach

       #--------------------------------------------------------------------
       # Verifica se existe restricoes de matricula para o codigo de assunto
       #--------------------------------------------------------------------
       initialize  ws2.empcod, ws2.funmat, ws2.funnom  to null
       let ws2.privez  =  "s"
       let ws2.cabrestr = "MATRICULA:"

       open    c_ctc14m03m using r_ctc14m03.c24astcod
       foreach c_ctc14m03m into  ws2.empcod,
                                 ws2.funmat,
                                 ws2.funnom

         if ws2.privez  =  "s"   then
            skip 1 line
            print column 023, "RESTRICOES : ";
            let ws2.privez  =  "n"
         end if

         print column 037, ws2.cabrestr, ws2.funmat  using "####&&",
                                  " - ", ws2.funnom
         initialize ws2.cabrestr  to null

      end foreach
      skip 1 line

    on last row
      need 6 lines
      skip 3 lines
      print column 001, ws2.traco
      print column 001, "TOTAL DE ASSUNTOS : ", ws2.asttotqtd  using "###,#&&"
      print column 001, ws2.traco

end report   ##-- ctc14m03
