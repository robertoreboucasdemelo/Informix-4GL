#############################################################################
# Nome do Modulo: CTE02M02                                           Raji   #
#                                                                           #
# Acompanhamento de Pendencias(impressao) - Atendimento corretor   Set/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 02/04/2001  PSI 12801-5  Wagner       Acesso iddkdominio 'c24pndsitcod'   #
#############################################################################

# ...............................................................................#
#                                                                                #
#                           * * * Alteracoes * * *                               #
#                                                                                #
# Data       Autor Fabrica   Origem        Alteracao                             #
# ---------- --------------  ----------    --------------------------------------#
# 10/09/2005 T. Solda,Meta   PSIMelhorias  Chamada da funcao "fun_dba_abre_banco"#
#                                          e troca da "systables" por "dual"     #
#--------------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

define ws_pipe      char(80)

#--------------------------------------------------------------
 function cte02m02( p_cte02m02 )
#---------------------------------------------------------------
 define p_cte02m02  record
    corlignum       like dacmligasshst.corlignum   ,
    corligano       like dacmligasshst.corligano   ,
    corligitmseq    like dacmligasshst.corligitmseq
 end record

 define ws           record
    errflg           smallint                     ,
    totqtd           smallint                     ,
    pndfnldat        like dacmatdpndsit.caddat    ,
    pndfnlhor        like dacmatdpndsit.cadhor    ,
    pndrlzhor        char (08)                    ,
    pndsitcod        like dacmatdpndsit.c24pndsitcod,
    c24astcod        like dackass.corasscod       ,
    c24rclsitcod     like dacmatdpndsit.c24pndsitcod,
    corassdes        like dackass.corassdes       ,
    seq              smallint,
    impr             char(08),
    ok               integer
 end record

 define l_cte02m02   record
    corlignum        like dacmatdpndsit.corlignum ,
    corligano        like dacmatdpndsit.corligano ,
    caddat           like dacmatdpndsit.caddat    ,
    cadhor           char (05)                    ,
    dddcod           like dacmpndret.dddcod       ,
    ctttel           like dacmpndret.ctttel       ,
    pndretcttnom     like dacmpndret.pndretcttnom ,
    corligitmseq     like dacmatdpndsit.corligitmseq,
    corasscod        like dacmligass.corasscod    ,
    corassdes        like dackass.corassdes       ,
    c24pndsitcod     like dacmatdpndsit.c24pndsitcod,
    pndsitdes        char (15)                    ,
    pndtmp           interval hour(04) to minute
 end record

 define  sql_comando char(900)

#--------------------------------------------------------------------
# Cursor principal ligacoes pendentes
#--------------------------------------------------------------------
 let sql_comando  = "select corlignum,             ",
                    "       corligano,             ",
                    "       corligitmseq           ",
                    " from dacmatdpndsit           ",
                    " where corlignum = ?     and  ",
                    "       corligano = ?     and  ",
                    "       c24pndsitcod = 0       ",
                    " group by corlignum,corligano,corligitmseq ",
                    " order by corligano,corlignum "
 prepare select_main  from sql_comando
 declare c_cte02m02 cursor with hold for select_main

#--------------------------------------------------------------------
# Cursor para obtencao da ultima situacao da pendencia
#--------------------------------------------------------------------
 let sql_comando = "select c24pndsitcod  ,",
                   "       caddat        ,",
                   "       cadhor         ",
                   "  from dacmatdpndsit  ",
                   " where corlignum = ?  ",
                   "   and corligano = ?  ",
                   "   and c24pndsitcod = (select max(c24pndsitcod)",
                                          "  from dacmatdpndsit",
                                          " where corlignum = ?",
                                          "   and corligano = ?)"

 prepare select_sitrecl from sql_comando
 declare c_cte02m02_sitrecl cursor with hold for select_sitrecl

#--------------------------------------------------------------------
# Cursor para obtencao dos dados adicionais da pendencia
#--------------------------------------------------------------------
 let sql_comando = "select dacmlig.ligdat             , ",
                   "       dacmlig.lighorinc          , ",
                   "       dacmpndret.dddcod          , ",
                   "       dacmpndret.ctttel          , ",
                   "       dacmpndret.pndretcttnom    , ",
                   "       dacmligass.corasscod         ",
                   "  from dacmlig,dacmpndret,dacmligass",
                   " where dacmligass.corlignum    = ?  ",
                   "   and dacmligass.corligano    = ?  ",
                   "   and dacmligass.corligitmseq = ?  ",
                   "   and dacmpndret.corlignum = dacmligass.corlignum",
                   "   and dacmpndret.corligano = dacmligass.corligano",
                   "   and dacmlig.corlignum    = dacmligass.corlignum",
                   "   and dacmlig.corligano    = dacmligass.corligano"

 prepare select_ligrecl from sql_comando
 declare c_cte02m02_ligrecl cursor with hold for select_ligrecl

#--------------------------------------------------------------------
# Cursor para obtencao da descricao do assunto da pendencia
#--------------------------------------------------------------------
 let sql_comando = "select corassdes from dackass",
                   " where corasscod = ? "

 prepare select_assunto from sql_comando
 declare c_cte02m02_assunto cursor with hold for select_assunto

#--------------------------------------------------------------------
# Cursor para obtencao da descricao do codigo de situacao
#--------------------------------------------------------------------
 let sql_comando = "select cpodes from iddkdominio",
                   " where cponom = 'c24rclsitcod'",
                   "   and cpocod = ?"

 prepare select_dominio from sql_comando
 declare c_cte02m02_dominio cursor with hold for select_dominio
#--------------------------------------------------------------------
# Cursor busca Historicos
#--------------------------------------------------------------------
 let sql_comando = "select dacmligasshst.corligitmseq, ",
                 "corasscod, "                 ,
                 "c24ligdsc, "                 ,
                 "cademp   , "                 ,
                 "cadmat   , "                 ,
                 "caddat   , "                 ,
                 "cadhor     "                 ,
                 "from DACMLIGASSHST, "             ,
                      "DACMLIGASS "                 ,
                      "where dacmligasshst.corlignum = ? " ,
                        "and dacmligasshst.corligano = ? " ,
                        "and dacmligasshst.corligitmseq = ? " ,
                        "and dacmligass.corlignum = "      ,
                            "dacmligasshst.corlignum "     ,
                        "and dacmligass.corligano = "      ,
                            "dacmligasshst.corligano "     ,
                        "and dacmligass.corligitmseq = "   ,
                            "dacmligasshst.corligitmseq "

 prepare s_dacmligasshst from   sql_comando
 declare c_dacmligasshst cursor with hold for s_dacmligasshst
#--------------------------------------------------------------------
# Cursor busca Funcionarioponsavel
#--------------------------------------------------------------------
 let sql_comando = "select funnom "                       ,
                 "from ISSKFUNC "                     ,
                 "where empcod = ? "             ,
                 "and funmat = ? "

 prepare s_isskfunc  from   sql_comando
 declare c_isskfunc  cursor with hold for s_isskfunc

  call fun_print_seleciona (g_issk.dptsgl,"")
        returning  ws.ok, ws.impr

  if ws.ok  =  0   then
     error " Departamento/Impressora nao cadastrada!"
  else
    if ws.impr  is null   then
       error " Uma impressora deve ser selecionada!"
    else
      let ws_pipe = "lp -sd ", ws.impr
    end if
 end if

 message "Aguarde, imprimindo"  attribute(reverse)

 start report cte02m02_rpt

 open c_cte02m02  using  p_cte02m02.corlignum,
                         p_cte02m02.corligano
 foreach c_cte02m02  into   l_cte02m02.corlignum,
                            l_cte02m02.corligano,
                            l_cte02m02.corligitmseq

   open  c_cte02m02_sitrecl  using  l_cte02m02.corlignum,
                                    l_cte02m02.corligano,
                                    l_cte02m02.corlignum,
                                    l_cte02m02.corligano
                                    #l_cte02m02.corligitmseq
   fetch c_cte02m02_sitrecl  into   l_cte02m02.c24pndsitcod,
                                    ws.pndfnldat,
                                    ws.pndfnlhor
   close c_cte02m02_sitrecl

   open  c_cte02m02_ligrecl  using  l_cte02m02.corlignum,
                                    l_cte02m02.corligano,
                                    l_cte02m02.corligitmseq
   fetch c_cte02m02_ligrecl  into   l_cte02m02.caddat   ,
                                    ws.pndrlzhor        ,
                                    l_cte02m02.dddcod   ,
                                    l_cte02m02.ctttel   ,
                                    l_cte02m02.pndretcttnom   ,
                                    l_cte02m02.corasscod
   close c_cte02m02_ligrecl

   let l_cte02m02.cadhor    = ws.pndrlzhor[1,5]

   open  c_cte02m02_assunto  using  l_cte02m02.corasscod
   fetch c_cte02m02_assunto  into   l_cte02m02.corassdes
   close c_cte02m02_assunto

   open  c_cte02m02_dominio  using  l_cte02m02.c24pndsitcod
   fetch c_cte02m02_dominio  into   l_cte02m02.pndsitdes
   close c_cte02m02_dominio

   if l_cte02m02.c24pndsitcod >= 2  then
      call cte02m00_espera(l_cte02m02.caddat,
                           l_cte02m02.cadhor,
                           ws.pndfnldat, ws.pndrlzhor)
                 returning l_cte02m02.pndtmp
   else
      call cte02m00_espera(l_cte02m02.caddat   ,
                           l_cte02m02.cadhor   ,"","")
                 returning l_cte02m02.pndtmp
   end if

   output to report cte02m02_rpt( l_cte02m02.* )

end foreach

finish report cte02m02_rpt
message ""

end function



#---------------------------------------------------------------------------
 report cte02m02_rpt(l_cte02m02)
#---------------------------------------------------------------------------
 define l_cte02m02   record
    corlignum        like dacmatdpndsit.corlignum ,
    corligano        like dacmatdpndsit.corligano ,
    caddat           like dacmatdpndsit.caddat    ,
    cadhor           char (05)                    ,
    dddcod           like dacmpndret.dddcod       ,
    ctttel           like dacmpndret.ctttel       ,
    pndretcttnom     like dacmpndret.pndretcttnom ,
    corligitmseq     like dacmatdpndsit.corligitmseq,
    corasscod        like dacmligass.corasscod    ,
    corassdes        like dackass.corassdes       ,
    c24pndsitcod     like dacmatdpndsit.c24pndsitcod,
    pndsitdes        char (15)                    ,
    pndtmp           interval hour(04) to minute
 end record

 define ws              record
        data            date                        ,
        hora            datetime hour to minute     ,
        corligitmseq    like dacmligasshst.corligitmseq,
        corligitmseqant like dacmligasshst.corligitmseq,
        c24txtseq       like dacmligasshst.c24txtseq   ,
        c24ligdsc       like dacmligasshst.c24ligdsc   ,
        cademp          like dacmligasshst.cademp      ,
        cadmat          like dacmligasshst.cadmat      ,
        caddat          like dacmligasshst.caddat      ,
        cadhor          like dacmligasshst.cadhor      ,
        cadempant       like dacmligasshst.cademp      ,
        cadmatant       like dacmligasshst.cadmat      ,
        caddatant       like dacmligasshst.caddat      ,
        cadhorant       like dacmligasshst.cadhor      ,
        corasscod       like dackass.corasscod      ,
        corassdes       like dackass.corassdes      ,
        corassagpcod    like dackassagp.corassagpcod,
        corassagpsgl    like dackassagp.corassagpsgl,
        funnom          like isskfunc.funnom        ,
        assunto         char(55)
 end record

 define w_comando       char(600)


 output report to  pipe ws_pipe
    left   margin  00
    right  margin  80
    top    margin  00
    bottom margin  00
    page   length  66

 format

    page header
       print "--------------------------------------------------------------------------------"
       print "CENTRAL 24 HS     P O R T O   S E G U R O  -  S E G U R O S           ",today
       print "Acompanhamento de Pendencias                                            ",time
       print "--------------------------------------------------------------------------------"
    on every row
       print ""
       print ""
       print           "Ligacao",
             column 21,"Assunto                                  ",
             column 59,"Situacao     ",
             column 72,"Espera"

       print l_cte02m02.corlignum using "#########","/",
             l_cte02m02.corligano using "####","-",
             l_cte02m02.corligitmseq using "&&",
             column 19,l_cte02m02.corasscod," ",
             l_cte02m02.corassdes clipped,
             column 55,l_cte02m02.c24pndsitcod,"  ",
             l_cte02m02.pndsitdes
       print l_cte02m02.caddat,"  ",
             l_cte02m02.cadhor,"  ",
             l_cte02m02.dddcod,"  ",
             l_cte02m02.ctttel,"  ",
             l_cte02m02.pndretcttnom,"  ",
             l_cte02m02.pndtmp

       initialize ws.assunto to null
       let  ws.corligitmseqant = 0
       let  ws.cadempant   =  0
       let  ws.cadmatant   =  0
       let  ws.caddatant   =  0
       let  ws.cadhorant   =  0
       open    c_dacmligasshst using l_cte02m02.corlignum
                                   , l_cte02m02.corligano
                                   , l_cte02m02.corligitmseq
       foreach c_dacmligasshst into  ws.corligitmseq,
                                     ws.corasscod   ,
                                     ws.c24ligdsc   ,
                                     ws.cademp      ,
                                     ws.cadmat      ,
                                     ws.caddat      ,
                                     ws.cadhor

          open c_cte02m02_assunto  using ws.corasscod
         fetch c_cte02m02_assunto into  ws.corassdes   ,
                                ws.corassagpcod
          # if ws.corassagpcod <> 8 then
             # Despresa historicos nao pertecentes ao grupo 8 - Pendecias
             # continue foreach
          # end if

          if  ws.cademp       <> ws.cadempant  or
              ws.cadmat       <> ws.cadmatant  or
              ws.caddat       <> ws.caddatant  or
              ws.cadhor       <> ws.cadhorant  then

                print ""
                print "  ----------------------------------",
                      "-------------------------------------"

                open  c_isskfunc using ws.cademp,
                                       ws.cadmat
                fetch c_isskfunc into  ws.funnom

                print "  Atualizacao em ", ws.caddat,
                      " as " , ws.cadhor,
                      " por ", ws.cademp using "&&",
                      "/"    , ws.cadmat using "&&&&&&",
                      " - "  , ws.funnom clipped
                print ""

                let ws.corligitmseqant = ws.corligitmseq
                let ws.cadempant      =  ws.cademp
                let ws.cadmatant      =  ws.cadmat
                let ws.caddatant      =  ws.caddat
                let ws.cadhorant      =  ws.cadhor
          end if
          print "  ",ws.c24ligdsc
       end foreach
 end report  ###  rep_reclam
