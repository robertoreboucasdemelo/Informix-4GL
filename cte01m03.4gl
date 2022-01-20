##############################################################################
# Nome do Modulo: CTE01M03                                              Akio #
#                                                                       Ruiz #
# Atendimento ao corretor - Ultimos atendimentos                    Abr/2000 #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
# 02/04/2001  PSI 12801-5  Wagner       Acesso iddkdominio 'c24pndsitcod'    #
#----------------------------------------------------------------------------#
# 17/09/2002  PSI          Henrique     carregar o nr da solicitacao de CVN  #
#----------------------------------------------------------------------------#
# 24/01/2003  CT 36714     Wagner       Correcao leitura situacao grupo 8    #
##############################################################################
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 19/09/2003 robson            PSI175250  Mostrar as ligacoes do RH, somente #
#                              OSF25565   para os atendentes do departamento #
#                                         do RH. Inibir estas ligacoes para  #
#                                         os outros departamentos.           #
#----------------------------------------------------------------------------#
# 18/03/2009 Carla Rampazzo    PSI 235580 Auto Jovem-Curso Direcao Defensiva #
#                                         Mostrar Nro.do Agendamento         #
##############################################################################

globals  "/homedsa/projetos/geral/globals/glcte.4gl"      # PSI175250

 define   g_cte01m03      char(01),
          m_cte01m03_prep smallint                        # PSI175250

#------------------------#
 function cte01m03_prep()                                 # PSI175250 - inicio
#------------------------#
 define l_sql_stmt  char(300)

 let l_sql_stmt = " select corassagpsgl, ",
                         " dptsgl, ",
                         " dptassagputztip ",
                    " from dackassagp ",
                   " where corassagpcod = ? "

 prepare pcte01m03001 from l_sql_stmt
 declare ccte01m03001 cursor with hold for pcte01m03001

 let m_cte01m03_prep = true

end function                                              # PSI175250 - fim

function cte01m03_criatemp()

    create temp table tmp_pndsit (id_tmp_pndsit serial,
                               corligitmseq smallint,
                               c24pndsitcod smallint) with no log
    whenever error stop

   if sqlca.sqlcode <> 0  then
     error "Erro ao criar a tabela temporaria"
   end if

end function

#------------------------------------------------------------------------------
function cte01m03_prep_temp()
#------------------------------------------------------------------------------

    define w_ins char(1000)

    let w_ins = 'insert into tmp_pndsit'
	     , ' values(?,?,?)'
    prepare p_insert from w_ins

end function



#-------------------------------------------------------------------------------
 function cte01m03( p_cte01m03 )
#-------------------------------------------------------------------------------
   define p_cte01m03      record
          data            date                  ,
          hora            datetime hour to minute,
          solnom          like dacmlig.c24solnom,
          corsus          like dacrligsus.corsus,
          cornom          like gcakcorr.cornom  ,
          empcod          like dacrligfun.empcod,
          funmat          like dacrligfun.funmat,
          funnom          like isskfunc.funnom  ,
          corligorg       like dacmlig.corligorg,
          corasscod       like dacmligass.corasscod
   end record

   define a_cte01m03      array[500] of record
          ligdat          like dacmlig.ligdat         ,
          ligasshorinc    like dacmligass.ligasshorinc,
          ligasshorfnl    like dacmligass.ligasshorfnl,
          atendente       char(15)                    ,
          c24paxnum       like dacmlig.c24paxnum      ,
          c24solnom       like dacmlig.c24solnom      ,
          corlignum       like dacmlig.corlignum      ,
          corligano       like dacmlig.corligano      ,
          corasscod       like dacmligass.corasscod   ,
          corassagpsgl    like dackassagp.corassagpsgl,
          corassdes       like dackass.corassdes      ,
          descr           char(06)                    ,
          docto           char(14)
   end record

   define a2_cte01m03     array[500] of record
          corligitmseq    like dacmligass.corligitmseq
   end record

   define ws              record
          ligacao         smallint                    ,
          data            date                        ,
          hora            datetime hour to minute     ,
          solcab          char(50)                    ,
          solnom          like dacmlig.c24solnom      ,
          cademp          like dacmlig.cademp         ,
          cadmat          like dacmlig.cadmat         ,

          vstnumdig       like dacrligvst.vstnumdig   ,
          prporgpcp       like dacrligorc.prporgpcp   ,
          prpnumpcp       like dacrligorc.prpnumpcp   ,
          prporgidv       like dacrligorc.prporgidv   ,
          prpnumidv       like dacrligorc.prpnumidv   ,
          fcapacorg       like dacrligpac.fcapacorg   ,
          fcapacnum       like dacrligpac.fcapacnum   ,
          c24pndsitcod    like dacmatdpndsit.c24pndsitcod,

          mducod          like igbkgeral.mducod       ,
          grlchv          like igbkgeral.grlchv       ,
          grlinf          like igbkgeral.grlinf       ,
          corlignum       like dacmlig.corlignum      ,
          corligano       like dacmlig.corligano      ,
          corassagpcod    like dackassagp.corassagpcod,
          prgextcod       like dackass.prgextcod      ,
          corligitmaux    like dacmligass.corligitmseq,
          vstagnnum       like dacrligagnvst.vstagnnum,
          vstagnstt       like dacrligagnvst.vstagnstt,
          cvnslcnum       like dacrligpndcvn.cvnslcnum,
          drscrsagdcod    like dacrdrscrsagdlig.drscrsagdcod,
          agdligrelstt    like dacrdrscrsagdlig.agdligrelstt
   end record

   define w_ind           integer
   define w_comando       char(900)

   define ws_id           integer
   define ws_corligitmseq like dacmatdpndsit.corligitmseq
   define ws_c24pndsitcod like dacmatdpndsit.c24pndsitcod
   define ws_rowid        integer
   define ws_corasscod    like dacmligass.corasscod

   define l_dptsgl          like dackassagp.dptsgl,           # PSI175250
          l_dptassagputztip like dackassagp.dptassagputztip,  # PSI175250
          l_flag            smallint,                         # PSI175250
          l_aux1            char(1),                          # PSI175250
          l_aux2            char(1),                          # PSI175250
          l_aux3            char(1)                           # PSI175250

   define l_id           integer
   define l_corligitmseq smallint
   define l_c24pndsitcod smallint

 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------

	define	w_pf1	integer



	let	w_ind  =  null
	let	w_comando  =  null
	let	ws_corligitmseq  =  null
	let	ws_c24pndsitcod  =  null
	let	ws_rowid  =  null
	let	ws_corasscod  =  null
        let l_flag = false                                     # PSI175250

	for	w_pf1  =  1  to  500
		initialize  a_cte01m03[w_pf1].*  to  null
	end	for

	for	w_pf1  =  1  to  500
		initialize  a2_cte01m03[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

   initialize a_cte01m03,
              a2_cte01m03,
              ws         ,
              w_ind      ,
              w_comando     to null

 #------------------------------------------------------------------------------
 # Preparacao dos comandos SQL
 #------------------------------------------------------------------------------
   if m_cte01m03_prep is null or                          # PSI175250
      m_cte01m03_prep <> true then                        # PSI175250
      call cte01m03_prep()                                # PSI175250
   end if                                                 # PSI175250

   IF  p_cte01m03.corsus IS NOT NULL THEN
      LET w_comando = "select corlignum,      ",
                      "       corligano       ",
                      "  from dacrligsus      ",
                      " where corsus = ?      ",
                      "order by corligano desc",
                      "        ,corlignum desc"
   ELSE
      IF g_atdcor.apoio = "S" AND g_atdcor.empcod IS NOT NULL AND
         g_atdcor.funmat IS NOT NULL THEN

         LET w_comando = 'select corlignum,',
                                'corligano',
                          ' from dacmligatd',
                         ' where atdemp = ?',
                          '   and atdmat = ?',
                         'order by corligano desc',
                         '        ,corlignum desc'
      ELSE
         let w_comando = "select corlignum,      ",
                         "       corligano       ",
                         "  from dacrligfun      ",
                         " where empcod = ?      ",
                         "   and funmat = ?      ",
                         "order by corligano desc",
                         "        ,corlignum desc"
      END IF
   END if

   prepare s_dacmlignum from   w_comando
   declare c_dacmlignum cursor with hold for s_dacmlignum

   let w_comando = "select dacmligass.corlignum, ",
                          "dacmligass.corligano, ",
                          "corligitmseq, "     ,
                          "ligdat      , "     ,
                          "ligasshorinc, "     ,
                          "ligasshorfnl, "     ,
                          "c24paxnum   , "     ,
                          "c24solnom   , "     ,
                          "cademp      , "     ,
                          "cadmat      , "     ,
                          "corasscod "         ,
                    " from DACMLIG, "                    ,
                          "DACMLIGASS "                  ,
                    "where dacmlig.corlignum = ? "             ,
                      "and dacmlig.corligano = ? "             ,
                      "and dacmligass.corlignum = dacmlig.corlignum "   ,
                      "and dacmligass.corligano = dacmlig.corligano "   ,
                 "order by DACMLIGASS.corligitmseq desc "
   prepare s_dacmligass from   w_comando
   declare c_dacmligass cursor with hold for s_dacmligass

   if  g_cte01m03 is null  then
       let g_cte01m03 = "N"

       let w_comando = "select funnom "          ,
                         "from ISSKFUNC "        ,
                              "where empcod = ? ",
                                "and funmat = ? "

       prepare s_isskfunc  from   w_comando
       declare c_isskfunc  cursor with hold for s_isskfunc


       let w_comando = "select grlinf "          ,
                         "from IGBKGERAL "       ,
                              "where mducod = ? ",
                                "and grlchv = ? ",
                                "for update "

       prepare s_igbkgeral from   w_comando
       declare c_igbkgeral cursor with hold for s_igbkgeral

       let w_comando = "select corassdes   , "                ,
                              "corassagpcod, "                ,
                              "prgextcod "                    ,
                         "from DACKASS "                      ,
                              "where corasscod = ?  "

       prepare s_dackass   from   w_comando
       declare c_dackass   cursor with hold for s_dackass

       let w_comando = "select vstnumdig "             ,
                         "from DACRLIGVST "            ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligvst from   w_comando
       declare c_dacrligvst cursor with hold for s_dacrligvst

       let w_comando = "select prporgpcp, "            ,
                              "prpnumpcp, "            ,
                              "prporgidv, "            ,
                              "prpnumidv "             ,
                         "from DACRLIGORC "            ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligorc from   w_comando
       declare c_dacrligorc cursor with hold for s_dacrligorc

       let w_comando = "select fcapacorg, "            ,
                              "fcapacnum "             ,
                         "from DACRLIGPAC "            ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligpac from   w_comando
       declare c_dacrligpac cursor with hold for s_dacrligpac

       let w_comando = "select prporg,"                ,
                              "prpnumdig "             ,
                         "from DACRLIGRMEORC "         ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligrmeorc from   w_comando
       declare c_dacrligrmeorc cursor with hold for s_dacrligrmeorc

       let w_comando = "select cvnslcnum "             ,
                         "from DACRLIGPNDCVN "         ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "
       prepare s_dacrligpndcvn from   w_comando
       declare c_dacrligpndcvn cursor with hold for s_dacrligpndcvn

       let w_comando = "select vstagnnum,"             ,
                              "vstagnstt "             ,
                         "from DACRLIGAGNVST "         ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligagnvst from   w_comando
       declare c_dacrligagnvst cursor with hold for s_dacrligagnvst

       ---> Agendamento do Curso de Direcao Defensiva
       let w_comando = "select drscrsagdcod,"             ,
                              "agdligrelstt "             ,
                         "from dacrdrscrsagdlig "         ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "
       prepare s_dacrdrscrsagdlig from   w_comando
       declare c_dacrdrscrsagdlig cursor with hold for s_dacrdrscrsagdlig

       let w_comando = "select prporgpcp, "            ,
                              "prpnumpcp, "            ,
                              "prporgidv, "            ,
                              "prpnumidv "             ,
                         "from DACRLIGSMPRNV "         ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligsmprnv from   w_comando
       declare c_dacrligsmprnv cursor with hold for s_dacrligsmprnv

       let w_comando = "select max(c24pndsitcod)",
                       "  from DACMATDPNDSIT    ",
                       " where corlignum = ?    ",
                       "   and corligano = ?    "
       prepare s_dacmatdpndsit   from w_comando
       declare c_dacmatdpndsit  cursor with hold for s_dacmatdpndsit

       let w_comando = "select cpodes from iddkdominio",
                   " where cponom = 'c24pndsitcod'",
                   "   and cpocod = ? "
       prepare s_iddkdominio from w_comando
       declare c_iddkdominio cursor for s_iddkdominio
   end if

 #------------------------------------------------------------------------------
 # Monta header da tela
 #------------------------------------------------------------------------------
  { if  p_cte01m03.corsus <> " "       and
       p_cte01m03.corsus is not null  then
       let ws.solcab = "CORRETOR: ", p_cte01m03.corsus,
                              " - ", p_cte01m03.cornom clipped
   else
       let ws.solcab = "FUNCION.: ", p_cte01m03.empcod using "&&",
                                     p_cte01m03.funmat using "&&&&&&",
                              " - ", p_cte01m03.funnom
   end if}

   #--- alteração psi 159638 - osf 8540 -----
   IF g_atdcor.apoio = "S" THEN
      IF p_cte01m03.corsus IS NULL THEN
         let ws.solcab = "ATENDENTE: ",g_atdcor.funmat," - ",g_atdcor.funnom
      ELSE
         LET ws.solcab = "CORRETOR: ", p_cte01m03.corsus,
                              " - ", p_cte01m03.cornom CLIPPED
      END IF
   ELSE
      if p_cte01m03.corsus <> " "       and
         p_cte01m03.corsus is not null  then
         let ws.solcab = "CORRETOR: ", p_cte01m03.corsus,
                              " - ", p_cte01m03.cornom clipped
      else
         let ws.solcab = "FUNCION.: ", p_cte01m03.empcod using "&&",
                                     p_cte01m03.funmat using "&&&&&&",
                              " - ", p_cte01m03.funnom
      end if
   END IF



 #------------------------------------------------------------------------------
 # Inicio da tela
 #------------------------------------------------------------------------------

   open window win_cte01m03 at 03,02 with form "cte01m03"
        attribute (form line first)


   while true

     clear form

    #call cte01m03_criatemp()
    #call cte01m03_prep_temp()
   #----------------------------------------------------------------------------
   # Inicializacao das variaveis
   #----------------------------------------------------------------------------
     let int_flag     = false

     let ws.data      = today
     let ws.hora      = current hour to minute

   #----------------------------------------------------------------------------
   # Exibe ultimos atendimentos
   #----------------------------------------------------------------------------
     display by name ws.solcab,
                     p_cte01m03.solnom  attribute(reverse)

     let w_ind = 1
     IF  p_cte01m03.corsus IS NOT NULL THEN
         OPEN c_dacmlignum USING p_cte01m03.corsus
     ELSE
        IF g_atdcor.apoio = "S"        AND
           g_atdcor.empcod IS NOT NULL AND
           g_atdcor.funmat IS NOT NULL THEN

           OPEN c_dacmlignum USING g_atdcor.empcod,
                                   g_atdcor.funmat

        ELSE
           open c_dacmlignum using p_cte01m03.empcod,
                                 p_cte01m03.funmat
        END IF
     END IF

     foreach c_dacmlignum into  ws.corlignum,
                                ws.corligano

        open c_dacmligass using ws.corlignum,
                                ws.corligano
        foreach c_dacmligass into a_cte01m03[w_ind].corlignum   ,
                                  a_cte01m03[w_ind].corligano   ,
                                  a2_cte01m03[w_ind].corligitmseq,
                                  a_cte01m03[w_ind].ligdat      ,
                                  a_cte01m03[w_ind].ligasshorinc,
                                  a_cte01m03[w_ind].ligasshorfnl,
                                  a_cte01m03[w_ind].c24paxnum   ,
                                  a_cte01m03[w_ind].c24solnom   ,
                                  ws.cademp                     ,
                                  ws.cadmat                     ,
                                  a_cte01m03[w_ind].corasscod


            if ws.cadmat = 999999 then
               let a_cte01m03[w_ind].atendente = "PORTAL"
            else

               open  c_isskfunc using  ws.cademp, ws.cadmat
               fetch c_isskfunc into   a_cte01m03[w_ind].atendente

               if  sqlca.sqlcode <> 0  then
                   let a_cte01m03[w_ind].atendente = "NAO CADASTR."
               end if

               close c_isskfunc

            end if

            open  c_dackass  using  a_cte01m03[w_ind].corasscod
            fetch c_dackass  into   a_cte01m03[w_ind].corassdes   ,
                                    ws.corassagpcod               ,
                                 ws.prgextcod

            whenever error continue                       # PSI175250
            open  ccte01m03001  using  ws.corassagpcod
            fetch ccte01m03001  into   a_cte01m03[w_ind].corassagpsgl,
                                       l_dptsgl,          # PSI175250 - inicio
                                       l_dptassagputztip
            whenever error stop

            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode < 0 then {Erro de acesso a base}
                  error " Erro de acesso a base de dados tabela dackassagp ", sqlca.sqlcode, " | ",sqlca.sqlerrd[2] sleep 2
                  let l_flag = true
                  exit foreach
               else
                  continue foreach
               end if
            end if                                        # PSI175250 - fim

            if g_issk.dptsgl[4,6] = 'hum' then              # PSI175250 - inicio
               if l_dptsgl is null or
                  (l_dptsgl <> g_issk.dptsgl and l_dptsgl[4,6] <> 'hum') then
                  continue foreach
               end if
            end if

            if g_issk.dptsgl[4,6] <> 'hum' and
               g_issk.acsnivcod < 8 then
               if l_dptsgl[4,6] = 'hum' then
                  continue foreach
               end if
            end if                                        # PSI175250 - fim

            initialize a_cte01m03[w_ind].descr to null
            if  g_atdcor.apoio = "S" then
                let a_cte01m03[w_ind].descr  = "Apoio"
            end if

            if  ws.prgextcod = 1  or
                ws.prgextcod = 2  then
                let ws.vstnumdig = ""
                open  c_dacrligvst using  a_cte01m03[w_ind].corlignum,
                                          a_cte01m03[w_ind].corligano,
                                          a2_cte01m03[w_ind].corligitmseq
                fetch c_dacrligvst into   ws.vstnumdig

                let a_cte01m03[w_ind].docto = "     ",
                                              ws.vstnumdig using "########&"
            else
             if  ws.prgextcod = 3  then
                 open  c_dacrligorc using  a_cte01m03[w_ind].corlignum,
                                           a_cte01m03[w_ind].corligano,
                                           a2_cte01m03[w_ind].corligitmseq
                 fetch c_dacrligorc into   ws.prporgpcp,
                                           ws.prpnumpcp,
                                           ws.prporgidv,
                                           ws.prpnumidv
                 let a_cte01m03[w_ind].docto = "   ", ws.prporgpcp using "&&",
                                              "/", ws.prpnumpcp using "&&&&&&&&"
             else
              if  ws.prgextcod = 4  then
                  open  c_dacrligsmprnv using  a_cte01m03[w_ind].corlignum,
                                               a_cte01m03[w_ind].corligano,
                                               a2_cte01m03[w_ind].corligitmseq
                  fetch c_dacrligsmprnv into   ws.prporgpcp,
                                               ws.prpnumpcp,
                                               ws.prporgidv,
                                               ws.prpnumidv

                  let a_cte01m03[w_ind].docto = "   ", ws.prporgpcp using "&&",
                                            "/", ws.prpnumpcp using "&&&&&&&&"
              else
               if  ws.prgextcod = 11  then
                   open  c_dacrligpac using  a_cte01m03[w_ind].corlignum,
                                             a_cte01m03[w_ind].corligano,
                                             a2_cte01m03[w_ind].corligitmseq
                   fetch c_dacrligpac into   ws.fcapacorg,
                                             ws.fcapacnum

                   let a_cte01m03[w_ind].docto = "   ", ws.fcapacorg using "&&",
                                            "/", ws.fcapacnum using "&&&&&&&&"
               else
                if  ws.prgextcod = 13 or
                    ws.prgextcod = 14 or
                    ws.prgextcod = 15 or
                    ws.prgextcod = 16 or
                    ws.prgextcod = 17 then
                    open  c_dacrligrmeorc using  a_cte01m03[w_ind].corlignum,
                                                 a_cte01m03[w_ind].corligano,
                                                 a2_cte01m03[w_ind].corligitmseq
                    fetch c_dacrligrmeorc into   ws.prporgpcp,
                                                 ws.prpnumpcp
                   let a_cte01m03[w_ind].docto = "   ", ws.prporgpcp using "&&",
                                              "/", ws.prpnumpcp using "&&&&&&&&"
                else
                 if ws.prgextcod = 21 or
                    ws.prgextcod = 22 or
                    ws.prgextcod = 31 then  # agendamento via web
                    let ws.vstagnnum = null
                    let ws.vstagnstt = null
                    open c_dacrligagnvst using a_cte01m03[w_ind].corlignum,
                                               a_cte01m03[w_ind].corligano,
                                              a2_cte01m03[w_ind].corligitmseq
                    fetch c_dacrligagnvst into ws.vstagnnum,
                                               ws.vstagnstt
                    if ws.vstagnnum is not null then
                       # verifica se o agendamento e do sistema novo(web)
                        select agncod
                            from avgmagn
                           where agncod = ws.vstagnnum
                        if sqlca.sqlcode = 0 then
                         case ws.vstagnstt
                          when  "I"
                             let a_cte01m03[w_ind].docto = "AGEND.",ws.vstagnnum
                          when  "C"
                             let a_cte01m03[w_ind].docto = "CANC. ",ws.vstagnnum
                          when  "A"
                             let a_cte01m03[w_ind].docto = "AG/CAN",ws.vstagnnum
                          otherwise
                             let a_cte01m03[w_ind].docto = "INVALI",ws.vstagnstt
                          end case
                        else
                          if ws.vstagnstt = "A" then
                             let a_cte01m03[w_ind].docto = "AGEND ",ws.vstagnnum
                          else
                             let a_cte01m03[w_ind].docto = "CANC  ",ws.vstagnnum
                          end if
                        end if
                    end if
                 else
                   if ws.prgextcod = 23 then
                      open c_dacrligpndcvn using a_cte01m03[w_ind].corlignum,
                                                 a_cte01m03[w_ind].corligano,
                                                a2_cte01m03[w_ind].corligitmseq
                      fetch c_dacrligpndcvn into ws.cvnslcnum
                      let a_cte01m03[w_ind].docto = "   ",ws.cvnslcnum
                   else
                    if ws.corassagpcod  =  8  and
                      a_cte01m03[w_ind].corasscod <> 38  then
#---( busca o max da situacao da ligacao somente para assunto grupo = 8 )---

                       call cte01m03_criatemp()
                       call cte01m03_prep_temp()

                       initialize ws_id to null

                       #INSERT INTO TMP_PNDSIT
                       select corlignum, corligano, corligitmseq, c24pndsitcod
                         into ws_id, ws_corligitmseq, ws_c24pndsitcod
                         from dacmatdpndsit
                        where corlignum    = a_cte01m03[w_ind].corlignum
                          and corligano    = a_cte01m03[w_ind].corligano
                          and corligitmseq = a2_cte01m03[w_ind].corligitmseq
                          and c24pndsitcod = (select max(c24pndsitcod)
                                                from dacmatdpndsit
                                               where corlignum = a_cte01m03[w_ind].corlignum
                                                 and corligano = a_cte01m03[w_ind].corligano
                                                 and corligitmseq = a2_cte01m03[w_ind].corligitmseq)

                         whenever error continue
                            execute p_insert using ws_id, ws_corligitmseq, ws_c24pndsitcod
                         whenever error stop

                         if sqlca.sqlcode <> 0  then
                           display "Erro ao inserir na tabela temporaria"
                         end if

                       declare c_pndsit cursor for
                        select corligitmseq, id_tmp_pndsit from tmp_pndsit

                       foreach c_pndsit into ws_corligitmseq, ws_rowid
                          select corasscod
                            into ws_corasscod
                            from dacmligass
                           where corlignum    = a_cte01m03[w_ind].corlignum
                             and corligano    = a_cte01m03[w_ind].corligano
                             and corligitmseq = ws_corligitmseq

                          if sqlca.sqlcode = 0 then
                             select corasscod
                               from dackass
                              where corasscod    = ws_corasscod
                                and corassagpcod = 8

                             if sqlca.sqlcode = notfound then
                                delete from tmp_pndsit
                                 where id_tmp_pndsit = ws_rowid
                             end if
                          end if
                       end foreach

                       whenever error continue
                       select max(c24pndsitcod)
                         into ws_c24pndsitcod
                         from tmp_pndsit
                       drop table tmp_pndsit
                       whenever error stop

                       if ws_c24pndsitcod is null then
                          select max(c24pndsitcod)
                            into ws_c24pndsitcod
                            from dacmatdpndsit
                           where corlignum = a_cte01m03[w_ind].corlignum
                             and corligano = a_cte01m03[w_ind].corligano
                       end if
#--------------------------------------------------------------------------
                      if ws_c24pndsitcod is not null then
                         let a_cte01m03[w_ind].docto = ""
                         open  c_iddkdominio  using ws_c24pndsitcod
                         fetch c_iddkdominio  into  a_cte01m03[w_ind].docto
                         close c_iddkdominio
                      end if
                    else
                     if ws.prgextcod = 34 then ---> Curso Direcao Defensiva
                        let ws.drscrsagdcod = null
                        let ws.agdligrelstt = null

                        open c_dacrdrscrsagdlig using a_cte01m03[w_ind].corlignum,
                                                      a_cte01m03[w_ind].corligano,
                                                      a2_cte01m03[w_ind].corligitmseq
                        fetch c_dacrdrscrsagdlig into ws.drscrsagdcod,
                                                      ws.agdligrelstt

                        if ws.drscrsagdcod is not null then
                           if ws.agdligrelstt = "A" then
                             let a_cte01m03[w_ind].docto = "AGEND ",ws.drscrsagdcod
                           else
                             let a_cte01m03[w_ind].docto = "CANC  ",ws.drscrsagdcod
                           end if
                        end if
                     else
                        let a_cte01m03[w_ind].docto = ""
                    end if
                   end if
                  end if
                 end if
                end if
               end if
              end if
             end if
            end if
            let w_ind = w_ind + 1

            if  w_ind > 500   then
                error "Limite de 500 atendimentos excedido." sleep 3
                exit foreach
            end if
        end foreach
        if l_flag = true then
           exit foreach
        end if

            if  w_ind > 500   then
                exit foreach
            end if
     end foreach
     if l_flag = true then
        exit while
     end if
     message " <F17> Abandona   <F6> Historico "

   #----------------------------------------------------------------------------
   # Solicita o assunto
   #----------------------------------------------------------------------------
     call set_count(w_ind - 1)
     display array a_cte01m03 to s_cte01m03.*

        on key (f6)
           let w_ind = arr_curr()

## PSI 175250 - Inicio

           let l_aux1 = "A"
           let l_aux2 = "N"
           let l_aux3 = ""
           let l_flag = true
           let l_dptsgl = null

           open  c_dackass  using  a_cte01m03[w_ind].corasscod
           whenever error continue
           fetch c_dackass  into   a_cte01m03[w_ind].corassdes   ,
                                   ws.corassagpcod               ,
                                   ws.prgextcod

           open  ccte01m03001  using  ws.corassagpcod
           whenever error continue
           fetch ccte01m03001  into   a_cte01m03[w_ind].corassagpsgl,
                                      l_dptsgl,
                                      l_dptassagputztip
           whenever error stop

           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = notfound then
                 let l_flag = false
              else
                 error " Erro de acesso a base de dados tabela dackassagp ", sqlca.sqlcode, " | ",sqlca.sqlerrd[2] sleep 2
                 let int_flag = true
                 exit display
              end if
           end if

           if l_flag = true and l_dptassagputztip is not null then
              if upshift(l_dptassagputztip) = "E" then
                 if l_dptsgl <> g_issk.dptsgl then
                      if g_issk.dptsgl <> 'ct24hs' and
                         g_issk.dptsgl <> 'dsvatd' then
                             let l_aux1 = "C"
                      else
                           if l_dptsgl <> 'ct24hs' and
                              l_dptsgl <> 'dsvatd' then
                                 let l_aux1 = "C"
                           end if
                      end if
                 end if
              end if
              if upshift(l_dptassagputztip) = "B" then
                 if l_dptsgl = g_issk.dptsgl then
                    let l_aux1 = "C"
                 end if
              end if
           end if

           call cte01m04( l_aux1, l_aux2,
                          a_cte01m03[w_ind].corlignum,
                          a_cte01m03[w_ind].corligano,
                          a2_cte01m03[w_ind].corligitmseq,
                          l_aux3 )

## PSI 175250 - Final

        on key (interrupt)
           exit display

     end display

     if  int_flag  then
         let int_flag = false
         exit while
     end if

   end while

   close window win_cte01m03

end function
