# Nome do Modulo: CTE01M01                                             Akio   #
#                                                                      Ruiz   #
# Atendimento ao corretor - Assuntos                               Abr/2000   #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 11/08/2000  psi 11244-5  Ruiz         gravar os assuntos do agrupamento     #
#                                       "pendencia" c/ assunto 40-generico.   #
#-----------------------------------------------------------------------------#
# 14/08/2000  psi          Ruiz         carregar a agencia na tela orcamento  #
#-----------------------------------------------------------------------------#
# 14/08/2000  psi 11545-2  Raji         chamada da janela do ura fax          #
#-----------------------------------------------------------------------------#
# 02/04/2001  PSI 12801-5  Wagner       Acesso iddkdominio 'c24pndsitcod'     #
#-----------------------------------------------------------------------------#
# 29/10/2001  PSI 14098-8  Ruiz         chamar o agendamento de VP via        #
#                                       cte01m02.                             #
#-----------------------------------------------------------------------------#
# 20/12/2001  PSI          Raji         Reinicializacao do No ligacao no ANO  #
#-----------------------------------------------------------------------------#
# 09/09/2002  PSI          Henrique     carregar o nr da solicitacao de CVN   #
#-----------------------------------------------------------------------------#
# 30/10/2002  PSI 159838   Fabio        registrar todas as ligacoes efetua-   #
#                                       das para a equipe de apoio.           #
#-----------------------------------------------------------------------------#
# 01/09/2003  OSF 25623    Leandro      Inibir a transferência de ligação par #
#                                       a URA 2660 nos assuntos 78 e 90.      #
###############################################################################
#                                                                             #
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 19/09/2003 robson            PSI175250  O atendente deve informar/visualizar#
#                              OSF25565   assunto somente do agrupamento refe-#
#                                         rente ao seu departamento           #
# 06/02/2005 Lucas Scheid      PSI 196541 Implement. da chamada p/ as funcoes:#
#                                          - cts40g20_pesq_web()              #
#                                          - cts40g20_apaga_web()             #
#                                          - cts40g20_insere_web()            #
#                                          - cts40g20_ret_codassu()           #
#-----------------------------------------------------------------------------#
# 15/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32          #
#                                                                             #
#-----------------------------------------------------------------------------#
# 28/10/2008 Amilton, Meta  Psi 230669   Incluir o numero de atendimento na   # 
#                                        na chamada da função                 #
#                                        cts40g20_insere_web                  #
#                                                                             #
#-----------------------------------------------------------------------------#
# 16/03/2009 Carla Rampazzo PSI 235580   Acrescentar Parametro na chamada de  # 
#                                        cts40g20_ret_codassu()               #
#                                        1-Curso Direcao Defensiva            #
#                                        2-Demais Agendamentos                #
#-----------------------------------------------------------------------------#
###############################################################################

globals "/homedsa/projetos/geral/globals/glcte.4gl"

 define   g_cte01m01      char(01),
          m_cte01m01_prep smallint                        # PSI175250
 define m_hostname       char(10) 

#------------------------#
 function cte01m01_prep()                                 # PSI175250 - inicio
#------------------------#

 define l_sql_stmt  char(500)

 let l_sql_stmt = " select corassagpsgl, ",
                         " dptsgl, ",
                         " dptassagputztip ",
                    " from dackassagp ",
                   " where corassagpcod = ? "

 prepare pcte01m01001 from l_sql_stmt
 declare ccte01m01001 cursor with hold for pcte01m01001

 let l_sql_stmt = " select a.sinvstpstnom, ",
                         " b.vstagndat, ",
                         " b.vstagnhor, ",
                         " b.vcllicnum, ",
                         " d.vcltipnom, ",
                         " b.vstatvtipcod, ",
                         " b.vstagnnum ",
                    " from svoksinvstpst a, ",
                         " svomvstagn b, ",
                         " agbkveic c, ",
                         " agbktip d ",
                   " where a.sinvstpstcod = b.sinvstpstcod ",
                     " and a.sinvstpsttip = ? ",
                     " and c.vclcoddig = b.vclcoddig ",
                     " and d.vclmrccod = c.vclmrccod ",
                     " and d.vcltipcod = c.vcltipcod ",
                     " and b.vcllicnum = ? ",
                   " order by b.vstagndat desc, ",
                            " b.vstagnhor desc "

  prepare pcte01m01002 from l_sql_stmt
  declare ccte01m01002 cursor for pcte01m01002

  let l_sql_stmt = " select a.sinvstpstnom, ",
                          " b.vstagndat, ",
                          " b.vstagnhor, ",
                          " b.vcllicnum, ",
                          " d.vcltipnom, ",
                          " b.vstatvtipcod, ",
                          " b.vstagnnum ",
                     " from svoksinvstpst a, ",
                          " svomvstagn b, ",
                          " agbkveic c, ",
                          " agbktip d ",
                    " where a.sinvstpstcod = b.sinvstpstcod ",
                      " and a.sinvstpsttip = ? ",
                      " and c.vclcoddig = b.vclcoddig ",
                      " and d.vclmrccod = c.vclmrccod ",
                      " and d.vcltipcod = c.vcltipcod ",
                      " and b.vclchsfnl = ? ",
                    " order by b.vstagndat desc, ",
                             " b.vstagnhor desc "

  prepare pcte01m01003 from l_sql_stmt
  declare ccte01m01003 cursor for pcte01m01003

 let m_cte01m01_prep = true

end function                                              # PSI175250 - fim

#-------------------------------------------------------------------------------
 function cte01m01( p_cte01m01 )
#-------------------------------------------------------------------------------
   define p_cte01m01      record
          data            date                  ,
          hora            datetime hour to minute,
          solnom          like dacmlig.c24solnom,
          corsus          like dacrligsus.corsus,
          cornom          like gcakcorr.cornom  ,
          empcod          like dacrligfun.empcod,
          funmat          like dacrligfun.funmat,
          funnom          like isskfunc.funnom  ,
          corligorg       like dacmlig.corligorg,
          corasscod       like dacmligass.corasscod,
          cvncptagnnum    like akckagn.cvncptagnnum,
          c24soltipcod    like dacmlig.c24soltipcod,  ---> PSI - 224030
          ciaempcod       like gabkemp.empcod         ---> PSI - 224030
   end record

   define d_cte01m01      record
          infasscod       like dacmligass.corasscod
   end record

   define a_cte01m01      array[3] of record
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
          docto           char(18)
   end record

   define w_cta02m08      record
          dddcod          like dacmpndret.dddcod,
          ctttel          like dacmpndret.ctttel,
          faxnum          like dacmpndret.faxnum,
          pndretcttnom    like dacmpndret.pndretcttnom
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
          corligitmseq    like dacmligass.corligitmseq,
          corligitmaux    like dacmligass.corligitmseq,

          corassstt       like dackass.corassstt      ,
          corasspndflg    like dackass.corasspndflg   ,
          corasshstflg    like dackass.corasshstflg   ,
          webrlzflg       like dackass.webrlzflg      ,
          corassagpcod    like dackassagp.corassagpcod,
          infassagpcod    like dackassagp.corassagpcod,
          infassagpsgl    like dackassagp.corassagpsgl,
          infassdes       like dackass.corassdes      ,
          prgextcod       like dackass.prgextcod      ,
          ret             smallint,
          ret1            smallint,
          corlignum_sel   like dacmlig.corlignum      ,
          corligano_sel   like dacmlig.corligano      ,
          vstagnnum       like dacrligagnvst.vstagnnum,
          vstagnstt       like dacrligagnvst.vstagnstt,
          cvnslcnum       like dacrligpndcvn.cvnslcnum,
          corasscod_web   like dackass.corasscod,
          prporgpcp_web   like dacrligorc.prporgpcp   ,
          prpnumpcp_web   like dacrligorc.prpnumpcp   ,
          statusq         smallint,
          informix        char(1),
          confirma        char(1),
          assunto3435     char(1),
          promptq         char(1),
          corasscod       like dacmligass.corasscod   ,
          prporgpcp_pes   like dacrligorc.prporgpcp   ,
          prpnumpcp_pes   like dacrligorc.prpnumpcp
   end record

   define l_sttweb       like datmagnwebsrv.sttweb,
          l_status       smallint,
          l_ligorgcod    like datmagnwebsrv.ligorgcod,
          l_abnwebflg    like datmagnwebsrv.abnwebflg,
          l_ligasscod    like datmagnwebsrv.ligasscod,
          l_vstagnnum    like datmagnwebsrv.vstagnnum,
          l_vstagnstt    like datmagnwebsrv.vstagnstt,
          l_orgvstagnnum like datmagnwebsrv.orgvstagnnum,
          l_tp_agenda    smallint


   define w_ind           integer
   define w_comando       char(600)
   define w_datalimite    date
   define l_dptsgl          like dackassagp.dptsgl,           # PSI175250
          l_dptassagputztip like dackassagp.dptassagputztip,  # PSI175250
          l_flag            smallint,                         # PSI175250
          l_st_erro       smallint,
          l_msg           char(100)

 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------
   initialize d_cte01m01,
              a_cte01m01,
              w_cta02m08,
              w_ind     ,
              w_datalimite,
              ws             to null

  let l_sttweb       = null
  let l_status       = null
  let l_ligorgcod    = null
  let l_abnwebflg    = null
  let l_ligasscod    = null
  let l_vstagnnum    = null
  let l_vstagnstt    = null
  let l_orgvstagnnum = null
  let l_tp_agenda    = null
  let l_st_erro      = 1 

 #------------------------------------------------------------------------------
 # Preparacao dos comandos SQL
 #------------------------------------------------------------------------------

   if m_cte01m01_prep is null or                          # PSI175250
      m_cte01m01_prep <> true then                        # PSI175250
      call cte01m01_prep()                                # PSI175250
   end if                                                 # PSI175250
   let l_flag = false                                     # PSI175250
   if  p_cte01m01.corsus is not null  then
      let w_comando = "select corlignum,      ",
                      "       corligano       ",
                      "  from dacrligsus      ",
                      " where corsus = ?      ",
                      "order by corligano desc",
                      "        ,corlignum desc"
   else
      IF g_atdcor.apoio = "S" AND g_atdcor.empcod IS NOT NULL AND
         g_atdcor.funmat IS NOT NULL THEN

         LET w_comando = 'select corlignum, ',
                         '       corligano  ',
                         '  from dacmligatd ',
                         ' where atdemp  = ?',
                         '   and atdmat  = ?',
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
   END IF

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
                    " from DACMLIG, "          ,
                          "DACMLIGASS "        ,
                    "where dacmlig.corlignum = ? "             ,
                      "and dacmlig.corligano = ? "             ,
                      "and dacmligass.corlignum = dacmlig.corlignum "   ,
                      "and dacmligass.corligano = dacmlig.corligano "   ,
                 "order by DACMLIGASS.corligitmseq desc "
   prepare s_dacmligass from   w_comando
   declare c_dacmligass cursor with hold for s_dacmligass


   if  g_cte01m01 is null  then
       let g_cte01m01 = "N"

       let w_comando = "select funnom "          ,
                         "from ISSKFUNC "        ,
                              "where empcod = ? ",
                                "and funmat = ? "

       prepare s_isskfunc  from   w_comando
       declare c_isskfunc  cursor with hold for s_isskfunc

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

       let w_comando = "select vstagnnum,"             ,
                              "vstagnstt "             ,
                         "from DACRLIGAGNVST "         ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "
       prepare s_dacrligagnvst from   w_comando
       declare c_dacrligagnvst cursor with hold for s_dacrligagnvst

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

       let w_comando = "select cvnslcnum "             ,
                         "from DACRLIGPNDCVN "         ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligpndcvn from   w_comando
       declare c_dacrligpndcvn cursor with hold for s_dacrligpndcvn

       let w_comando = "select grlinf "          ,
                         "from IGBKGERAL "       ,
                              "where mducod = ? ",
                                "and grlchv = ? ",
                                "for update "

       prepare s_igbkgeral from   w_comando
       declare c_igbkgeral cursor with hold for s_igbkgeral

       let w_comando = "select grlinf "          ,
                         "from DATKGERAL "       ,
                              "where grlchv = ? ",
                                "for update "

       prepare s_datkgeral from   w_comando
       declare c_datkgeral cursor with hold for s_datkgeral

       let w_comando = "select corassdes   , "                ,
                              "corassagpcod, "                ,
                              "corassstt   , "                ,
                              "prgextcod   , "                ,
                              "corasspndflg,"                 ,
                              "corasshstflg,"                 ,
                              "webrlzflg    "                 ,
                         "from DACKASS "                      ,
                              "where corasscod = ?  "

       prepare s_dackass   from   w_comando
       declare c_dackass   cursor with hold for s_dackass

       let w_comando = "select corlignum "                    ,
                         "from DACMPNDRET "                   ,
                              "where corlignum = ? "          ,
                                "and corligano = ? "

       prepare s_dacmpndret   from   w_comando
       declare c_dacmpndret   cursor with hold for s_dacmpndret

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

       let w_comando = "update IGBKGERAL "                    ,
                          "set grlinf = ? "                   ,
                              "where mducod = ?"              ,
                                "and grlchv = ? "

       prepare u_igbkgeral from   w_comando

       let w_comando = "update DATKGERAL "                    ,
                          "set grlinf = ? "                   ,
                              "where grlchv = ? "

       prepare u_datkgeral from   w_comando

       let w_comando = "insert into DACMLIG( corlignum, " ,
                                            "corligano, " ,
                                            "ligdat   , " ,
                                            "lighorinc, " ,
                                            "c24paxnum, " ,
                                            "c24solnom, " ,
                                            "corligorg, " ,
                                            "cademp   , " ,
                                            "cadmat   , " ,
                                            "c24soltipcod, ", ---> PSI - 224030
                                            "empcod      ) ", ---> PSI - 224030
                         "values( ?,?,?,?,?,?,?,?,?,?,? ) "

       prepare i_dacmlig   from   w_comando

       let w_comando = "update DACMLIG "            ,
                          "set lighorfnl = ? "      ,
                              "where corlignum = ? ",
                                "and corligano = ? "

       prepare u_dacmlig   from   w_comando

       let w_comando = "insert into DACMLIGASS( corlignum, "    ,
                                               "corligano, "    ,
                                               "corligitmseq,"  ,
                                               "corasscod, "    ,
                                               "ligasshorinc ) ",
                         "values( ?,?,?,?,? ) "

       prepare i_dacmligass from   w_comando

       let w_comando = "update DACMLIGASS " ,
                       "set (ligasshorfnl," ,
                       "     corasscod) = " ,
                       "    (?,?) "  ,
                              "where corlignum    = ? ",
                                "and corligano    = ? ",
                                "and corligitmseq = ? "

       prepare u_dacmligass from   w_comando

       let w_comando = 'insert into dacrligorc(corlignum,',
                                              'corligano,',
                                              'corligitmseq,',
                                              'prporgpcp,',
                                              'prpnumpcp,',
                                              'prporgidv,',
                                              'prpnumidv)',
                               'values(?,?,?,?,?,?,?)'

       PREPARE i_dacrligorc FROM w_comando

       let w_comando = 'insert into dacmwebitf(corlignum,',
                                              'corligano,',
                                              'c24solnom,',
                                              'atdcademp,',
                                              'atdcadmat,',
                                              'corsus,',
                                              'c24paxnum,',
                                              'empcod,',
                                              'funmat,',
                                              'corasscod,',
                                              'sttweb, ',
                                              'c24soltipcod, ', ---> PSI 224030
                                              'c24soltipdes) ', ---> PSI 224030
                               'values(?,?,?,?,?,?,?,?,?,?,?,?,?)'

       PREPARE i_dacmwebitf FROM w_comando

       LET w_comando = 'insert into dacmligatd(corlignum,',
                                             'corligitmseq,',
                                             'corligano,',
                                             'atdemp,',
                                             'atdmat,',
                                             'atdtip,',
                                             'apoemp,',
                                             'apomat,',
                                             'apotip) ',
                                     'values(?,?,?,?,?,?,?,?,?)'

       PREPARE i_dacmligatd FROM w_comando


       let w_comando = "insert into DACRLIGSUS( corlignum, "    ,
                                               "corligano, "    ,
                                               "corsus ) ",
                         "values( ?,?,? ) "

       prepare i_dacrligsus from   w_comando

       let w_comando = "insert into DACRLIGFUN( corlignum, " ,
                                               "corligano, " ,
                                               "empcod   , " ,
                                               "funmat    ) ",
                         "values( ?,?,?,? ) "

       prepare i_dacrligfun from   w_comando

       let w_comando = "insert into DACMATDPNDSIT( corlignum, "   ,
                                                  "corligano, "   ,
                                                  "corligitmseq, ",
                                                  "c24pndsitcod, ",
                                                  "caddat, ",
                                                  "cadhor, ",
                                                  "cademp, ",
                                                  "cadmat ) ",
                         "values( ?,?,?,0,?,?,?,? ) "

       prepare i_dacmatdpndsit from   w_comando

       let w_comando = "insert into DACMPNDRET( corlignum, "    ,
                                               "corligano, "    ,
                                               "dddcod, "       ,
                                               "ctttel, "       ,
                                               "faxnum, "       ,
                                               "pndretcttnom ) ",
                         "values( ?,?,?,?,?,? ) "

       prepare i_dacmpndret from   w_comando

       let w_comando = "delete from DACMLIGASS "       ,
                              "where corlignum = ? and corligano = ? "   ,
                                "and corligitmseq = ? "
       prepare d_dacmligass from w_comando


       let w_comando = "delete from DACMLIG ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacmlig from w_comando

       let w_comando = "delete from DACMLIGASS ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacmligass from w_comando

       let w_comando = "delete from DACMLIGASSHST ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacmligasshst from w_comando

       let w_comando = "delete from DACRLIGSUS ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacrligsus from w_comando

       let w_comando = "delete from DACRLIGFUN ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacrligfun from w_comando

       let w_comando = "delete from DACRLIGVST ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacrligvst from w_comando

       let w_comando = "delete from DACRLIGORC ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacrligorc from w_comando

       let w_comando = "delete from DACRLIGPAC ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacrligpac from w_comando

       let w_comando = "delete from DACRLIGSMPRNV ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacrligsmprnv from w_comando

       let w_comando = "delete from DACMATDPNDSIT ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacmatdpndsit from w_comando

       let w_comando = "delete from DACMPNDRET ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacmpndret from w_comando

       let w_comando = "delete from DACRLIGPNDCVN ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacrligpndcvn from w_comando

       let w_comando = "delete from DACRLIGRMEORC ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacrligrmeorc from w_comando

       let w_comando = "delete from DACRLIGAGNVST ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacrligagnvst from w_comando

       ---> Agendamento do Curso de Direcao Defensiva
       let w_comando = "delete from DACRDRSCRSAGDLIG ",
                              "where corlignum = ? and corligano = ? "
       prepare d2_dacrdrscrsagdlig from w_comando


       let w_comando = "delete from IGBKGERAL "  ,
                              "where mducod = ? ",
                                "and grlchv = ? "
       prepare d_igbkgeral from w_comando


       ---> Agendamento do Curso de Direcao Defensiva
       let w_comando = "select drscrsagdcod," ,
                             " agdligrelstt " ,
                         "from DACRDRSCRSAGDLIG " ,
                        "where corlignum    = ? "   ,
                          "and corligano    = ? "   ,
                          "and corligitmseq = ? "
       prepare s_dacrdrscrsagdlig from   w_comando
       declare c_dacrdrscrsagdlig cursor with hold for s_dacrdrscrsagdlig

       #---> 10/12/2009 - Orçamento duplicado.
       let w_comando = "select 1 " ,
                         "from DACRLIGORC " ,
                        "where corlignum = ? " ,
                          "and corligano = ? " ,
                          "and corligitmseq = ? "
       prepare s_dacrligorc2 from   w_comando
       declare c_dacrligorc2 cursor with hold for s_dacrligorc2


   end if


 #------------------------------------------------------------------------------
 # Liga flag para gravacao da ligacao / Zera a sequencia de assuntos
 #------------------------------------------------------------------------------
   let ws.ligacao = false
   let ws.corligitmseq = 0


 #------------------------------------------------------------------------------
 # Monta header da tela
 #------------------------------------------------------------------------------
   IF g_atdcor.apoio = "S" THEN
      IF p_cte01m01.corsus IS NULL THEN
         let ws.solcab = "ATENDENTE: ",g_atdcor.funmat," - ",g_atdcor.funnom
      ELSE
         LET ws.solcab = "CORRETOR: ", p_cte01m01.corsus,
                              " - ", p_cte01m01.cornom CLIPPED
      END IF
   ELSE
      if p_cte01m01.corsus <> " "       and
         p_cte01m01.corsus is not null  then
         let ws.solcab = "CORRETOR: ", p_cte01m01.corsus,
                              " - ", p_cte01m01.cornom clipped
      else
         let ws.solcab = "FUNCION.: ", p_cte01m01.empcod using "&&",
                                     p_cte01m01.funmat using "&&&&&&",
                              " - ", p_cte01m01.funnom
      end if
   END IF

 #------------------------------------------------------------------------------
 # Inicio da tela
 #------------------------------------------------------------------------------

   open window win_cte01m01 at 03,02 with form "cte01m01"
        attribute (form line first)


   while true

     clear form

   #----------------------------------------------------------------------------
   # Inicializacao das variaveis
   #----------------------------------------------------------------------------
     let int_flag     = false

     let ws.data      = today
     let ws.hora      = current hour to minute
     let d_cte01m01.infasscod =  null
   #----------------------------------------------------------------------------
   # Exibe header e ultimos 3 assuntos atendidos
   #----------------------------------------------------------------------------
     display by name ws.solcab,
                     p_cte01m01.solnom  attribute(reverse)

     let w_ind = 1

     IF p_cte01m01.corsus IS NOT NULL THEN
         open c_dacmlignum using p_cte01m01.corsus
     ELSE
        IF g_atdcor.apoio = "S" AND
           g_atdcor.empcod IS NOT NULL AND
           g_atdcor.funmat IS NOT NULL THEN

           OPEN c_dacmlignum USING g_atdcor.empcod,
                                   g_atdcor.funmat

        ELSE

           open c_dacmlignum using p_cte01m01.empcod,
                                p_cte01m01.funmat
        end if
     END IF

     foreach c_dacmlignum into  ws.corlignum_sel,
                                ws.corligano_sel

        open c_dacmligass using ws.corlignum_sel,
                                ws.corligano_sel
        foreach c_dacmligass into a_cte01m01[w_ind].corlignum   ,
                                  a_cte01m01[w_ind].corligano   ,
                                  ws.corligitmaux               ,
                                  a_cte01m01[w_ind].ligdat      ,
                                  a_cte01m01[w_ind].ligasshorinc,
                                  a_cte01m01[w_ind].ligasshorfnl,
                                  a_cte01m01[w_ind].c24paxnum   ,
                                  a_cte01m01[w_ind].c24solnom   ,
                                  ws.cademp                     ,
                                  ws.cadmat                     ,
                                  a_cte01m01[w_ind].corasscod
            if ws.cadmat = 999999 then
               # ---> AGENDAMENTO MARCADO VIA PORTAL
               let a_cte01m01[w_ind].atendente = "PORTAL"
            else
               open  c_isskfunc using  ws.cademp, ws.cadmat
               fetch c_isskfunc into   a_cte01m01[w_ind].atendente

               if  sqlca.sqlcode <> 0  then
                   let a_cte01m01[w_ind].atendente = "NAO CADASTR."
               end if

               close c_isskfunc

            end if

            open  c_dackass  using  a_cte01m01[w_ind].corasscod
            fetch c_dackass  into   a_cte01m01[w_ind].corassdes,
                                    ws.corassagpcod            ,
                                    ws.corassstt               ,
                                    ws.prgextcod               ,
                                    ws.corasspndflg            ,
                                    ws.corasshstflg            ,
                                    ws.webrlzflg

            whenever error continue                       # PSI175250
            open  ccte01m01001  using  ws.corassagpcod
            fetch ccte01m01001  into   a_cte01m01[w_ind].corassagpsgl,
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
            end if

            if g_issk.dptsgl[4,6] = 'hum' then
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

            #-----------------------------------------------------------------
            # 1-MARCACAO VISTORIA PREVIA DOMICILIAR
	    # 2-ALT. MARCACAO VIST.PREVIA
            #-----------------------------------------------------------------
            if  ws.prgextcod = 1  or
                ws.prgextcod = 2  then
                let ws.vstnumdig = ""
                open  c_dacrligvst using  a_cte01m01[w_ind].corlignum,
                                          a_cte01m01[w_ind].corligano,
                                          ws.corligitmaux
                fetch c_dacrligvst into   ws.vstnumdig

                let a_cte01m01[w_ind].docto = "     ",
                                              ws.vstnumdig using "########&"
            else
             #-----------------------------------------------------------------
             # 3-ORCAMENTO DE AUTOMOVEL
             #-----------------------------------------------------------------
             if  ws.prgextcod = 3  then
                 open  c_dacrligorc using  a_cte01m01[w_ind].corlignum,
                                           a_cte01m01[w_ind].corligano,
                                           ws.corligitmaux
                 fetch c_dacrligorc into   ws.prporgpcp,
                                           ws.prpnumpcp,
                                           ws.prporgidv,
                                           ws.prpnumidv

                 let a_cte01m01[w_ind].docto = "   ", ws.prporgpcp using "&&",
                                            "/", ws.prpnumpcp using "&&&&&&&&"
             else

              #-----------------------------------------------------------------
              # 4-MANUTENCAO DE PROPOSTAS
              #-----------------------------------------------------------------
              if  ws.prgextcod = 4  then
                  open  c_dacrligsmprnv using  a_cte01m01[w_ind].corlignum,
                                               a_cte01m01[w_ind].corligano,
                                               ws.corligitmaux
                  fetch c_dacrligsmprnv into   ws.prporgpcp,
                                               ws.prpnumpcp,
                                               ws.prporgidv,
                                               ws.prpnumidv

                  let a_cte01m01[w_ind].docto = "   ", ws.prporgpcp using "&&",
                                            "/", ws.prpnumpcp using "&&&&&&&&"
              else
               #--------------------------------------------------------------
               # 11-CONSULTA AO PAC
               #--------------------------------------------------------------
               if  ws.prgextcod = 11  then
                   open  c_dacrligpac using  a_cte01m01[w_ind].corlignum,
                                             a_cte01m01[w_ind].corligano,
                                             ws.corligitmaux
                   fetch c_dacrligpac into   ws.fcapacorg,
                                             ws.fcapacnum

                   let a_cte01m01[w_ind].docto = "   ", ws.fcapacorg using "&&",
                                            "/", ws.fcapacnum using "&&&&&&&&"
               else
                #--------------------------------------------------------------
                # 13-FAX R.S DE R.E
                # 14-CONS/ALT R.S DE R.E
                # 15-TRANSM. ORC DE R.E VIA FAX
                # 16-EMISSAO SEGUNDA VIA R.S
                # 17-ORCAMENTO DE R.E
                #--------------------------------------------------------------
                if  ws.prgextcod = 13 or
                    ws.prgextcod = 14 or
                    ws.prgextcod = 15 or
                    ws.prgextcod = 16 or
                    ws.prgextcod = 17 then
                    open  c_dacrligrmeorc using  a_cte01m01[w_ind].corlignum,
                                                 a_cte01m01[w_ind].corligano,
                                                 ws.corligitmaux
                    fetch c_dacrligrmeorc into   ws.prporgpcp,
                                                 ws.prpnumpcp
                   let a_cte01m01[w_ind].docto = "   ", ws.prporgpcp using "&&",
                                             "/", ws.prpnumpcp using "&&&&&&&&"
                else
                 #--------------------------------------------------------------
                 # 21-INCLUSAO DE AGENDAMENTO DE VP               
                 # 22-CANCELAMENTO DE AGENDAMENTO DE VP.               
                 # 31-AGENDAMENTO DE SERVICOS WEB               
                 #--------------------------------------------------------------
                 if ws.prgextcod = 21 or
                    ws.prgextcod = 22 or
                    ws.prgextcod = 31 then
                    let ws.vstagnnum = null
                    let ws.vstagnstt = null
                    open c_dacrligagnvst using a_cte01m01[w_ind].corlignum,
                                               a_cte01m01[w_ind].corligano,
                                               ws.corligitmaux
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
                            let a_cte01m01[w_ind].docto = "AGEND.",ws.vstagnnum
                         when  "C"
                            let a_cte01m01[w_ind].docto = "CANC. ",ws.vstagnnum
                         when  "A"
                            let a_cte01m01[w_ind].docto = "AG/CAN",ws.vstagnnum
                         otherwise
                            let a_cte01m01[w_ind].docto = "INVALI", ws.vstagnstt
                        end case
                       else
                        if ws.vstagnstt = "A" then
                           let a_cte01m01[w_ind].docto = "AGEND ",ws.vstagnnum
                        else
                           let a_cte01m01[w_ind].docto = "CANC  ",ws.vstagnnum
                        end if
                       end if
                    end if
                 else
                   #-----------------------------------------------------------
                   # 23-TELA DE CONVENIOS
                   #-----------------------------------------------------------
                   if ws.prgextcod = 23 then
                      open c_dacrligpndcvn using a_cte01m01[w_ind].corlignum,
                                                 a_cte01m01[w_ind].corligano,
                                                 ws.corligitmaux
                      fetch c_dacrligpndcvn into ws.cvnslcnum
                      let a_cte01m01[w_ind].docto = "   ",ws.cvnslcnum
                   else
                    #----------------------------------------------------------
                    # 34-AGENDAMENTO DO CURSO DE DIRECAO DEFENSIVA
                    #----------------------------------------------------------
		    if ws.prgextcod = 34 then

                       let ws.vstagnnum = null
                       let ws.vstagnstt = null

                       open c_dacrdrscrsagdlig using a_cte01m01[w_ind].corlignum
                                                    ,a_cte01m01[w_ind].corligano
                                                    ,ws.corligitmaux
                       fetch c_dacrdrscrsagdlig into ws.vstagnnum,
                                                     ws.vstagnstt

                       if ws.vstagnnum is not null then

                          if ws.vstagnstt = "A" then
                             let a_cte01m01[w_ind].docto = "AGEND ",ws.vstagnnum
                          else
                             let a_cte01m01[w_ind].docto = "CANC  ",ws.vstagnnum
                          end if
                       end if
		    else
                     if ws.corassagpcod  =  8  and
                        a_cte01m01[w_ind].corasscod <> 38  then
                        open c_dacmatdpndsit using a_cte01m01[w_ind].corlignum,
                                                   a_cte01m01[w_ind].corligano
                        fetch c_dacmatdpndsit into ws.c24pndsitcod
                        if sqlca.sqlcode = 0  then
                           let a_cte01m01[w_ind].docto = ""
                           open  c_iddkdominio  using ws.c24pndsitcod
                           fetch c_iddkdominio  into  a_cte01m01[w_ind].docto
                           close c_iddkdominio
                        end if
                        close c_dacmatdpndsit
                     else
                        let a_cte01m01[w_ind].docto = ""
                     end if
                    end if
                   end if
                  end if
                 end if
                end if
               end if
              end if
            end if
            display a_cte01m01[w_ind].* to s_cte01m01[w_ind].*

            let w_ind = w_ind + 1

            if  w_ind > 3  then
                exit foreach
            end if
        end foreach  ##### LIGACAO
        if l_flag = true then                             # PSI175250
           exit foreach                                   # PSI175250
        end if                                            # PSI175250
        if  w_ind > 3  then
            exit foreach
        end if
     end foreach     ##### CORRETOR
     if l_flag = true then                                # PSI175250
        exit while                                        # PSI175250
     end if                                               # PSI175250
     if  p_cte01m01.corsus <> " "       and
         p_cte01m01.corsus is not null  then
         message " <F17> Abandona   <F5> Espelho Corretor   <F6> Todas Ligacoes"
     else
         message " <F17> Abandona   <F6> Todas Ligacoes"
     end if

   #----------------------------------------------------------------------------
   # Solicita o assunto
   #----------------------------------------------------------------------------
     input by name d_cte01m01.* without defaults

        before field infasscod
           if  p_cte01m01.corasscod <> 0         and
               p_cte01m01.corasscod is not null  then
               let d_cte01m01.infasscod = p_cte01m01.corasscod

               open  c_dackass  using  d_cte01m01.infasscod
               fetch c_dackass  into   ws.infassdes   ,
                                       ws.infassagpcod,
                                       ws.corassstt   ,
                                       ws.prgextcod   ,
                                       ws.corasspndflg,
                                       ws.corasshstflg,
                                       ws.webrlzflg

               whenever error continue                     # PSI175250
               open  ccte01m01001  using  ws.infassagpcod
               fetch ccte01m01001  into   ws.infassagpsgl,
                                          l_dptsgl,        # PSI175250 - inicio
                                          l_dptassagputztip
               whenever error stop

               if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode < 0 then {Erro de acesso a base}
                     error " Erro de acesso a base de dados tabela dackassagp ", sqlca.sqlcode, " | ",sqlca.sqlerrd[2] sleep 2
                  else
                     error " Registro nao encontrado tabela dackassagp " sleep 2
                  end if
                  let int_flag = true
                  let l_flag = true
                  exit input
               end if                                         # PSI175250 - fim

               display by name ws.infassagpsgl,
                               ws.infassdes
                          attribute(reverse)
           end if
           display by name d_cte01m01.infasscod  attribute(reverse)


        after  field infasscod
           display by name d_cte01m01.infasscod

           if  d_cte01m01.infasscod = 0      or
               d_cte01m01.infasscod is null  then
               error " Informe o codigo do assunto!"
               call cto00m03()
                    returning ws.infassagpcod,
                              ws.infassagpsgl
               if  ws.infassagpcod is null  then
                   error " Informe o codigo do assunto!"
                   next field infasscod
               else
                   call cto00m04( ws.infassagpcod,"" )
                        returning d_cte01m01.infasscod,
                                  ws.infassdes
               end if
              #next field infasscod
           end if

           if d_cte01m01.infasscod = 1 or
              d_cte01m01.infasscod = 3 then

              call cts08g01( "A", "N",
                            "","OBRIGATORIO PRECO ONLINE",
                            "","") returning ws.confirma
           else
                if d_cte01m01.infasscod = 315 then

                   call cts08g01( "A", "N",
                                  "","OBRIGATORIO CALCULO ",
                                  "ATRAVES DO COL","") returning ws.confirma

                end if

           end if



           open  c_dackass  using  d_cte01m01.infasscod  # PSI175250 - inicio
           fetch c_dackass  into   ws.infassdes   ,
                                   ws.infassagpcod,
                                   ws.corassstt   ,
                                   ws.prgextcod   ,
                                   ws.corasspndflg,
                                   ws.corasshstflg,
                                   ws.webrlzflg
           whenever error continue

           open  ccte01m01001  using  ws.infassagpcod
           fetch ccte01m01001  into   ws.infassagpsgl,
                                      l_dptsgl,
                                      l_dptassagputztip
           whenever error stop

           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode < 0 then {Erro de acesso a base}
                 error " Erro de acesso a base de dados tabela dackassagp ", sqlca.sqlcode, " | ",sqlca.sqlerrd[2] sleep 2
                 let int_flag = true
                 let l_flag = true
                 exit input
              end if
           end if                                         # PSI175250 - fim

           if (g_issk.acsnivcod < 8) and                  # PSI175250 inicio
              (p_cte01m01.corasscod is null or
               p_cte01m01.corasscod = 0) then
              if l_dptassagputztip = "E" then
                 if l_dptsgl <> g_issk.dptsgl then
                    error " Assunto nao disponivel para seu departamento "
                    next field infasscod
                 end if
              end if
              if l_dptassagputztip = "B" then
                 if l_dptsgl = g_issk.dptsgl then
                    error " Assunto nao disponivel para seu departamento "
                    next field infasscod
                 end if
              end if
           end if                                         # PSI175250 fim

           open  c_dackass using d_cte01m01.infasscod
           fetch c_dackass into  ws.infassdes   ,
                                 ws.infassagpcod,
                                 ws.corassstt   ,
                                 ws.prgextcod   ,
                                 ws.corasspndflg,
                                 ws.corasshstflg,
                                 ws.webrlzflg
              if  sqlca.sqlcode <> 0  then
                  if  sqlca.sqlcode = 100  then
                      error " Assunto nao cadastrado!"
                  else
                      error " Erro (", sqlca.sqlcode, ") durante ",
                            "a escolha do assunto. AVISE A INFORMATICA!"
                  end if
                  next field infasscod
              end if

           if  ws.corassstt <> "A"  then
               error " O assunto esta cancelado! "
               next field infasscod
           end if
           if ws.infassagpcod = 8 then            # pendencias
              if d_cte01m01.infasscod <> 38 then  # consulta pendencia
                #let d_cte01m01.infasscod = 40    # generico
                 open  c_dackass using d_cte01m01.infasscod
                 fetch c_dackass into  ws.infassdes   ,
                                       ws.infassagpcod,
                                       ws.corassstt   ,
                                       ws.prgextcod   ,
                                       ws.corasspndflg,
                                       ws.corasshstflg,
                                       ws.webrlzflg
                 if  sqlca.sqlcode <> 0  then
                     if  sqlca.sqlcode = 100  then
                         error " Assunto nao cadastrado!"
                     else
                         error " Erro (", sqlca.sqlcode, ") durante ",
                               "a escolha do assunto. AVISE A INFORMATICA!"
                     end if
                     next field infasscod
                 end if
              end if
           end if

           whenever error continue                        # PSI175250
           open  ccte01m01001 using ws.infassagpcod
           fetch ccte01m01001 into  ws.infassagpsgl,
                                    l_dptsgl,             # PSI175250 - inicio
                                    l_dptassagputztip
           whenever error stop

           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode < 0 then {Erro de acesso a base}
                 error " Erro de acesso a base de dados tabela dackassagp ", sqlca.sqlcode, " | ",sqlca.sqlerrd[2] sleep 2
              else
                 error " Registro nao encontrado tabela dackassagp " sleep 2
              end if
              let int_flag = true
              let l_flag = true
              exit input
           end if                                         # PSI175250 - fim

           display by name ws.infassdes
           display by name ws.infassagpsgl

           exit input

        on key (f5)
           
           let m_hostname = null 
           # Função colocada Devido o Desligamento do Banco U37 29/09/2010
           call cta13m00_verifica_instancias_u37()
             returning l_st_erro,l_msg                  
                                                        
           if l_st_erro = true then                     
              if  p_cte01m01.corsus <> " "       and
                  p_cte01m01.corsus is not null  then
                  call ctn09c00( p_cte01m01.corsus )
              end if
           else
              error "Tecla F5 não disponivel no momento ! ",l_msg ," ! Avise a Informatica " 
              sleep 2                                                                                              
           end if    

        on key (f6)
           call cte01m03( p_cte01m01.data ,
                          p_cte01m01.hora ,
                          p_cte01m01.solnom,
                          p_cte01m01.corsus,
                          p_cte01m01.cornom,
                          p_cte01m01.empcod,
                          p_cte01m01.funmat,
                          p_cte01m01.funnom,
                          p_cte01m01.corligorg,
                          p_cte01m01.corasscod)
        on key (interrupt)
           exit input

     end input

     if  int_flag  then
         let int_flag = false
         if l_flag = true then
            exit while
         end if

         if  cts08g01( "A", "S",
                            "","DESEJA SAIR DO ATENDIMENTO ?",
                            "",""                            ) = "S"  then
            #if  g_issk.dptsgl <> "desenv"  then
                 if  ws.corligitmseq = 0  then
                     error " E obrigatorio o registro de um assunto!"
                 else
                     exit while
                 end if
            #else
            #    exit while
            #end if
         end if
     else
       #----------------------------------------------------------------------
       # Pega o ultimo numero de ligacao - apenas 1 vez
       #----------------------------------------------------------------------
         if ws.ligacao = false  then
            let ws.corligano = year(today)

            begin work
               let ws.grlchv = "ULTCORLIG", ws.corligano using "####"
               open  c_datkgeral using ws.grlchv
               fetch c_datkgeral into  ws.grlinf

               if sqlca.sqlcode = notfound then
                  insert into datkgeral (grlchv,
                                         grlinf,
                                         atldat,
                                         atlhor,
                                         atlemp,
                                         atlmat)
                              values    (ws.grlchv,
                                         "0000000000",
                                         today,
                                         current hour to minute,
                                         g_issk.empcod,
                                         g_issk.funmat)

                  open  c_datkgeral using ws.grlchv
                  fetch c_datkgeral into  ws.grlinf
               end if

               if sqlca.sqlcode <> 0  then
                   error " Erro (", sqlca.sqlcode, ") durante ",
                      "a geracao do numero da ligacao. AVISE A INFORMATICA!"
                   sleep 3
                   rollback work
                   return
               end if

               let ws.corlignum = ws.grlinf[01,10]
               let ws.corlignum = ws.corlignum + 1
               let ws.grlinf[01,10] = ws.corlignum using "&&&&&&&&&&"

               execute u_datkgeral using ws.grlinf,
                                         ws.grlchv

               if  sqlca.sqlcode <> 0  then
                   error " Erro (", sqlca.sqlcode, ") durante ",
                         "a atualizacao do numero da ligacao. ",
                         "AVISE A INFORMATICA!"
                   sleep 3
                   rollback work
                   return
               end if

            commit work
         end if

{#######  alexson
         if p_cte01m01.data is null then
           let p_cte01m01.data      = today
         end if
         if  p_cte01m01.hora is null then
           let p_cte01m01.hora      = "10:00"
         end if
         if g_c24paxnum is null then
           let g_c24paxnum          = 1
         end if
         if p_cte01m01.solnom is null then
           let p_cte01m01.solnom    = "Alexson Teste. "
         end if
         if p_cte01m01.corligorg is null then
           let p_cte01m01.corligorg = 1
         end if
         if   g_issk.empcod is null then
           let g_issk.empcod        = 1
         end if
         if g_issk.funmat is null then
           let g_issk.funmat        = 89299
         end if

######}

       #----------------------------------------------------------------------
       # Abre a ligacao - apenas 1 vez
       #----------------------------------------------------------------------
         begin work
         if  ws.ligacao = false  then
             let ws.ligacao = true
             execute i_dacmlig using ws.corlignum        ,
                                     ws.corligano        ,
                                     p_cte01m01.data     ,
                                     p_cte01m01.hora     ,
                                     g_c24paxnum         ,
                                     p_cte01m01.solnom   ,
                                     p_cte01m01.corligorg,
                                     g_issk.empcod       ,
                                     g_issk.funmat       ,
                                     p_cte01m01.c24soltipcod,---> PSI - 224030
                                     p_cte01m01.ciaempcod    ---> PSI - 224030

             if  sqlca.sqlcode <> 0  then
                 error " Erro (", sqlca.sqlcode, ") durante ",
                       "a abertura da ligacao. AVISE A INFORMATICA!"
                 sleep 3
                 rollback work
                 return
             end if

           #------------------------------------------------------------------
           # Grava solicitante atendente
           #------------------------------------------------------------------
             IF g_atdcor.apoio = "S"        AND
                g_atdcor.empcod <> 0        AND
                g_atdcor.empcod IS NOT NULL AND
                g_atdcor.funmat <> 0        AND
                g_atdcor.funmat IS NOT NULL THEN

                EXECUTE i_dacmligatd USING ws.corlignum,
                                           ws.corligitmseq,
                                           ws.corligano,
                                           g_atdcor.empcod,
                                           g_atdcor.funmat,
                                           g_atdcor.usrtip,
                                           g_issk.empcod,
                                           g_issk.funmat,
                                           g_issk.usrtip
             END IF
           #------------------------------------------------------------------
           # Grava solicitante corretor
           #------------------------------------------------------------------
             if  p_cte01m01.corsus <> " "       and
                 p_cte01m01.corsus is not null  then
                 execute i_dacrligsus using ws.corlignum     ,
                                            ws.corligano     ,
                                            p_cte01m01.corsus

                 if  sqlca.sqlcode <> 0  then
                     error " Erro (", sqlca.sqlcode, ") durante ",
                           "a gravacao do solic-corretor. AVISE A INFORMATICA!"
                     sleep 3
                     rollback work
                     return
                 end if
             end if

           #------------------------------------------------------------------
           # Grava solicitante funcionario
           #------------------------------------------------------------------
             if  p_cte01m01.empcod <> 0         and
                 p_cte01m01.empcod is not null  and
                 p_cte01m01.funmat <> 0         and
                 p_cte01m01.funmat is not null  then
                 execute i_dacrligfun using ws.corlignum     ,
                                            ws.corligano     ,
                                            p_cte01m01.empcod,
                                            p_cte01m01.funmat

                 if  sqlca.sqlcode <> 0  then
                     error " Erro (", sqlca.sqlcode, ") durante ",
                         "a gravacao do solic-funcionario. AVISE A INFORMATICA!"
                     sleep 3
                     rollback work
                     return
                 end if
             end if

           #------------------------------------------------------------------
           # Grava numero da ligacao no registro de simulacao
           #------------------------------------------------------------------
             if  g_simulacao   then
                 let ws.mducod = "C24"
                 let ws.grlchv = "ATDCOR-SIMUL"
                 execute u_igbkgeral using ws.grlinf,
                                           ws.mducod,
                                           ws.grlchv

                 if  sqlca.sqlcode <> 0  then
                     error " Erro (", sqlca.sqlcode, ") durante ",
                           "a gravacao do controle . AVISE A INFORMATICA!"
                     sleep 3
                     rollback work
                     return
                 end if
             end if
         end if

       #----------------------------------------------------------------------
       # Abre o assunto
       #----------------------------------------------------------------------
         let ws.corligitmseq = ws.corligitmseq + 1
         let ws.hora = current hour to minute

         execute i_dacmligass using ws.corlignum          ,
                                    ws.corligano          ,
                                    ws.corligitmseq       ,
                                    d_cte01m01.infasscod  ,
                                    ws.hora

         if  sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") durante ",
                   "a abertura do assunto ", ws.corligitmseq using "#&",
                   ". AVISE A INFORMATICA!"
             sleep 3
             rollback work
             return
         end if

         commit work

       #------------------------------------------------------------------------
       # Confirma assunto ?
       #------------------------------------------------------------------------
         let w_comando = ws.infassagpsgl clipped, "-",
                         ws.infassdes clipped

         let ws.informix    = "S"

         let ws.assunto3435 = null

         if  cts08g01( "A", "S",
                       "","CONFIRMA O ASSUNTO INFORMADO ?",
                       "",
                       w_comando[1,40] ) = "S"  then
             let ws.corasscod = d_cte01m01.infasscod

             if ws.webrlzflg  = "S"  then
                if ws.prgextcod = 3  then  # (cod.programa-orcamento automovel)
                   select sttweb                    # se existir o registro
                     from dacmwebitf                # significa que o atendente
                    where atdcademp = g_issk.empcod # saiu da web pelo "X" ou
                      and atdcadmat = g_issk.funmat # expirou a sessao na web.
                   if sqlca.sqlcode = 0 then
                      delete from dacmwebitf
                         where atdcademp = g_issk.empcod
                           and atdcadmat = g_issk.funmat
                   end if
                   while true
                     call cte01m01_verifica_web
                               (ws.corlignum,
                                ws.corligano,
                                d_cte01m01.infasscod,
                                ws.infassagpcod,
                                p_cte01m01.solnom,
                                p_cte01m01.corsus,
                                p_cte01m01.empcod,
                                p_cte01m01.funmat, # matr. ligacao
                                g_c24paxnum,
                                g_issk.empcod,
                                g_issk.funmat,     # matr. atendente
                                p_cte01m01.c24soltipcod, ---> PSI - 224030
                                p_cte01m01.ciaempcod   ) ---> PSI - 224030
                      returning ws.statusq,
                                ws.corasscod_web,
                                ws.prporgpcp_web,
                                ws.prpnumpcp_web
                     case ws.statusq
                       when 1  # matricula nao tem acesso a web
                            let ws.informix = "S"

                       when 2  # matricula tem acesso a web
                            call cte01m01_mens()
                            continue while  # fica no while ate status=3

                       when 3  # orcamento realizado pela web
                            delete from dacmwebitf
                               where corlignum = ws.corlignum
                                 and corligano = ws.corligano
                                 and atdcademp = g_issk.empcod
                                 and atdcadmat = g_issk.funmat
                            let d_cte01m01.infasscod = ws.corasscod_web
                            let ws.informix = "N"

                     end case
                     exit while
                   end while
                else
                   if ws.prgextcod = 31 then    # agendamento pela web

                      call cts40g20_pesq_web(g_issk.empcod, g_issk.funmat)
                              returning l_status,
                                        l_sttweb,
                                        l_abnwebflg,
                                        l_ligasscod,
                                        l_vstagnnum,
                                        l_vstagnstt,
                                        l_orgvstagnnum

                      if l_status = 0 then # ---> ENCONTROU REGISTRO
                         # ---> APAGA O REGISTRO DA WEB
                         call cts40g20_apaga_web(g_issk.empcod, g_issk.funmat)
                      end if

                      # --> BUSCA O CODIGO DA ORIGEM DA LIGACAO
                      if g_issk.dptsgl = "c24tpf" then
                         let l_ligorgcod = 2 # --> ATENDIMENTO TELEFORMANCE
                      else
                         let l_ligorgcod = 1 # --> ATENDIMENTO PORTO
                      end if

                      call cts40g20_insere_web(g_issk.empcod,
                                               g_issk.funmat,
                                               "", # --> SUCURSAL
                                               "", # --> RAMO
                                               "", # --> APOLICE
                                               "", # --> ITEM
                                               "", # --> ORIGEM PROPOSTA
                                               "", # --> NUMERO PROPOSTA
                                               p_cte01m01.solnom,
                                               p_cte01m01.c24soltipcod, 
                                               p_cte01m01.corsus,
                                               "", # --> NUMERO AGENDAMENTO
                                               "", # --> LIGNUM
                                               ws.corlignum,
                                               ws.corligano,
                                               "A", # --> SITUACAO ATENDIMENTO
                                               "", # --> TIPO OPERACAO
                                               l_ligorgcod,
                                               "", # --> (S)ABANDONO (N)CONCLUIU
                                               p_cte01m01.empcod,
                                               p_cte01m01.funmat,
                                               p_cte01m01.funnom,
                                               p_cte01m01.cornom,
                                               "", # --> STATUS AGENDAMENTO
                                               ws.corasshstflg,
                                               "", # --> NUMERO AGEND.(ORIGINAL)                                                
                                               "" ) # --> NUMERO ATENDIMENTO
                      let l_sttweb = "A"

                      # ---> ATENDIMENTO SENDO REALIZADO VIA WEB
                      while l_sttweb = "A"
                         # ---> EXIBE A MENSAGEM PARA O USUARIO
                         call cte01m01_mens()

                         # ---> BUSCA O STATUS DE RETORNO DA WEB
                         call cts40g20_pesq_web(g_issk.empcod, g_issk.funmat)
                              returning l_status,
                                        l_sttweb,
                                        l_abnwebflg,
                                        l_ligasscod,
                                        l_vstagnnum,
                                        l_vstagnstt,
                                        l_orgvstagnnum
                      end while

                      if l_sttweb = "F" then  # ---> ASSUNTO FINALIZADO NA WEB

                         let ws.informix = "N"

                         if l_abnwebflg = "S" then
                            let d_cte01m01.infasscod = "58" # ---> ABANDONO
                         else

			    ---> Define Tipo de Agendamento
                            let l_tp_agenda = 2   # agendamento pela web


                            # ---> BUSCA O CODIGO DO ASSUNTO
                            let d_cte01m01.infasscod =
                                cts40g20_ret_codassu("C", # --> ATD. CORRETOR
                                                     l_ligorgcod,
                                                     l_ligasscod,
                                                     l_tp_agenda)
                         end if
                      end if

                      # ---> APAGA O REGISTRO DA WEB
                      call cts40g20_apaga_web(g_issk.empcod, g_issk.funmat)
                   end if
                end if
             end if
           #--------------------------------------------------------------------
           # Chama modulo para execucao de programas externos
           #--------------------------------------------------------------------

             if  ws.prgextcod <> 0   and
                 ws.informix  =  "S" then  # ruiz

                 call cte01m02( ws.prgextcod   ,
                                ws.corlignum   ,
                                year(today)    ,
                                ws.corligitmseq,
                                p_cte01m01.cvncptagnnum,
                                p_cte01m01.corsus ) returning ws.ret

             else
                 let ws.ret = true
             end if
             -------[ abre um questionario de pesquisa para o corretor ]-----
             if (ws.corasscod = 1 or  # seguro novo
                 ws.corasscod = 3 or  # renov.congenere
                 ws.corasscod = 78) then
                 #p_cte01m01.corsus is not null  then



                 let ws.prporgpcp_pes = ws.prporgpcp_web
                 let ws.prpnumpcp_pes = ws.prpnumpcp_web
                 if ws.prpnumpcp_pes is null  or
                    ws.prpnumpcp_pes = "    " then
                    ---------[ orcamento realizado no ifx ]---------
                    select prporgpcp,
                           prpnumpcp
                      into ws.prporgpcp_pes,
                           ws.prpnumpcp_pes
                      from dacrligorc
                     where corlignum    = ws.corlignum
                       and corligano    = year(today)
                       and corligitmseq = ws.corligitmseq
                    if sqlca.sqlcode <> 0 then
                       error "Orcamento nao encontrado(dacrligorc)para questionario"  sleep 2
                    end if
                 end if


                 if ws.prpnumpcp_pes <> 0  then
                    call cte01m01_questoes2(ws.corlignum,
                                            year(today) ,
                                            ws.prporgpcp_pes,
                                            ws.prpnumpcp_pes,
                                            ws.corligitmseq)
                 end if
             end if
         else
             let ws.ret = false
         end if

         if ws.corasscod = 36 then  # orcamento manual
              let ws.prporgpcp_web = null
              let ws.prpnumpcp_web = null
         end if


         begin work
         if  ws.ret  then
           #--------------------------------------------------------------------
           # Verifica gravacao de pendencia
           #--------------------------------------------------------------------
             if  ws.corasspndflg = "S"  then
                 call cta02m08( w_cta02m08.* )
                      returning w_cta02m08.*
             end if


             if ws.prporgpcp_web is not null and # orcamento gerado na web
                ws.prpnumpcp_web is not null and
                ws.webrlzflg    =  "S"      then
                
                #---> 10/12/2009 - Orçamento duplicado.
                open  c_dacrligorc2 using  ws.corlignum,
                                           ws.corligano,
                                           ws.corligitmseq
                fetch c_dacrligorc2

                #---> 10/12/2009 - Orçamento duplicado.
                if sqlca.sqlcode = 100 then

                   execute i_dacrligorc using ws.corlignum,
                                              ws.corligano,
                                              ws.corligitmseq,
                                              ws.prporgpcp_web,
                                              ws.prpnumpcp_web,
                                              ws.prporgpcp_web,
                                              ws.prpnumpcp_web
                   if  sqlca.sqlcode <> 0  then
                       error " Erro (", sqlca.sqlcode, ") durante ",
                             "a gravacao dacrligorc_web ", ws.corligitmseq using "#&",
                             ". AVISE A INFORMATICA!"
                       sleep 3
                       rollback work
                       return
                   end if
                end if
             end if

             if ws.webrlzflg  = "S"   and
                ws.prgextcod  = 31    and # agendamento
                l_vstagnnum   <> 0    and
                l_vstagnnum   <> 99999 then
                # --> GRAVA O AGENDAMENTO
                let l_status = cts40g20_grava_agend
                                  ("C", # --> ATENDIMENTO CORRETOR
                                   l_orgvstagnnum,
                                   ws.corlignum,
                                   ws.corligitmseq,
                                   l_vstagnnum,
                                   l_vstagnstt,
                                   ws.corligano,
                                   "")
                if l_status = 2 then # --> ERRO DE ACESSO AO BD
                   rollback work
                   return
                end if
             end if

           #--------------------------------------------------------------------
           # Se o pgm externo OK, finaliza o assunto
           #--------------------------------------------------------------------
             let ws.hora = current hour to minute

             execute u_dacmligass using ws.hora        ,
                                        d_cte01m01.infasscod,  # ruiz'
                                        ws.corlignum   ,
                                        ws.corligano   ,
                                        ws.corligitmseq

             if  sqlca.sqlcode <> 0  then
                 error " Erro (", sqlca.sqlcode, ") durante ",
                       "a finalizacao do assunto ", ws.corligitmseq using "#&",
                       ". AVISE A INFORMATICA!"
                 sleep 3
                 rollback work
                 return
             end if

           #--------------------------------------------------------------------
           # Grava pendencias para determinados assuntos
           #--------------------------------------------------------------------
             let ws.data = today
             let ws.hora = current hour to minute

             if  ws.corasspndflg = "S"  then
                 execute i_dacmatdpndsit using ws.corlignum   ,
                                               ws.corligano   ,
                                               ws.corligitmseq,
                                               ws.data        ,
                                               ws.hora        ,
                                               g_issk.empcod  ,
                                               g_issk.funmat

                 open  c_dacmpndret using ws.corlignum   ,
                                          ws.corligano
                 fetch c_dacmpndret
                   if  sqlca.sqlcode = 100 then
                       execute i_dacmpndret using ws.corlignum     ,
                                                  ws.corligano     ,
                                                  w_cta02m08.dddcod,
                                                  w_cta02m08.ctttel,
                                                  w_cta02m08.faxnum,
                                                  w_cta02m08.pndretcttnom
                   end if
             end if

         else
           #--------------------------------------------------------------------
           # Se o pgm externo NOK, exclui o assunto
           #--------------------------------------------------------------------
             execute d_dacmligass using ws.corlignum   ,
                                        ws.corligano   ,
                                        ws.corligitmseq

             if  sqlca.sqlcode <> 0  then
                 error " Erro (", sqlca.sqlcode, ") durante ",
                       "a exclusao do assunto ", ws.corligitmseq using "#&",
                       ". AVISE A INFORMATICA!"
                 sleep 3
                 rollback work
                 return
             end if

             let ws.corligitmseq = ws.corligitmseq - 1

         end if

         commit work

         if  ws.ret  then
           #--------------------------------------------------------------------
           # Chama modulo para registro de historico - assunto <> vp
           # Para vp, e replicado o historico do servico para a ligacao
           #--------------------------------------------------------------------
             if  ws.prgextcod <> 1  and   ### Marcacao
                 ws.prgextcod <> 2  and   ### Alteracao da marcacao
                 ws.prgextcod <> 31 and   ### Agendamento via web
                 ws.corasshstflg = "S"  then
                 call cte01m04( "A", "S",
                                ws.corlignum,
                                year(today),
                                ws.corligitmseq,
                                d_cte01m01.infasscod )
             end if

             ----[ funcao para gravar o relacionamento da central com R.E ]---
             if d_cte01m01.infasscod = 29 or  # Residencia/Condominio
                d_cte01m01.infasscod = 30 or  # R.E PAC
                d_cte01m01.infasscod = 67 then # Empresariais R.E
                if p_cte01m01.corsus is not null then
                   call frama008_atend
                                   (ws.corligano,      # ano da ligacao
                                    ws.corlignum,      # numero da ligacao
                                    ws.data,           # data da ligacao
                                    p_cte01m01.solnom, # nome solicitante
                                    p_cte01m01.corsus, # susep corretor
                                    "",                # nome segurado
                                    "",                # nulo
                                    "",                # nulo
                                    "",                # nulo
                                    "Corretor"   ,     # valor fixo
                                    g_issk.funmat,     # matricula atendente
                                    g_issk.empcod)     # empresa do atendente
                end if
                if  p_cte01m01.empcod <> 0         and
                    p_cte01m01.empcod is not null  and
                    p_cte01m01.funmat <> 0         and
                    p_cte01m01.funmat is not null  then
                    call frama008_atend
                                   (ws.corligano,      # ano da ligacao
                                    ws.corlignum,      # numero da ligacao
                                    ws.data,           # data da ligacao
                                    p_cte01m01.solnom, # nome solicitante
                                    ""               , # susep corretor=nulo
                                    p_cte01m01.funnom, # nome segurado
                                    "",                # nulo
                                    "",                # nulo
                                    "",                # nulo
                                    "Outros",          # valor fixo
                                    g_issk.funmat,     # matricula atendente
                                    g_issk.empcod)     # empresa do atendente
                end if
             end if
             ------------------------------------------------------------------
         end if
     end if
   end while
   if l_flag = true then
      let int_flag = false
      close window win_cte01m01
      return
   end if
 #------------------------------------------------------------------------------
 # Finaliza a ligacao
 #------------------------------------------------------------------------------
   if  ws.ligacao  then
       begin work
       let ws.hora = current hour to minute

       execute u_dacmlig using ws.hora        ,
                               ws.corlignum   ,
                               ws.corligano

       if  sqlca.sqlcode <> 0  then
           error " Erro (", sqlca.sqlcode, ") durante ",
                 "a finalizacao da ligacao. AVISE A INFORMATICA!"
           sleep 3
           rollback work
           return
       end if

       if (g_atdcor.apoio       = "S") and
          (d_cte01m01.infasscod = 78   or
           d_cte01m01.infasscod = 90 ) then
       else
          call cte03m01(ws.corlignum, ws.corligano, g_c24paxnum)
       end if

     #------------------------------------------------------------------
     # Deleta registro de simulacao
     #------------------------------------------------------------------
       if  g_simulacao   then
           execute d2_dacmlig          using ws.corlignum,  ws.corligano
           execute d2_dacmligass       using ws.corlignum,  ws.corligano
           execute d2_dacmligasshst    using ws.corlignum,  ws.corligano
           execute d2_dacrligsus       using ws.corlignum,  ws.corligano
           execute d2_dacrligfun       using ws.corlignum,  ws.corligano
           execute d2_dacrligvst       using ws.corlignum,  ws.corligano
           execute d2_dacrligorc       using ws.corlignum,  ws.corligano
           execute d2_dacrligpac       using ws.corlignum,  ws.corligano
           execute d2_dacrligsmprnv    using ws.corlignum,  ws.corligano
           execute d2_dacmatdpndsit    using ws.corlignum,  ws.corligano
           execute d2_dacmpndret       using ws.corlignum,  ws.corligano
           execute d2_dacrligpndcvn    using ws.corlignum,  ws.corligano
           execute d2_dacrligrmeorc    using ws.corlignum,  ws.corligano
           execute d2_dacrligagnvst    using ws.corlignum,  ws.corligano
           execute d2_dacrdrscrsagdlig using ws.corlignum,  ws.corligano

           let ws.mducod = "C24"
           let ws.grlchv = "ATDCOR-SIMUL"
           execute d_igbkgeral using ws.mducod,
                                     ws.grlchv
       end if

       commit work
   end if

   close window win_cte01m01

end function
-----------------------------------------------------------------------------
function cte01m01_verifica_web(param)
-----------------------------------------------------------------------------
    define param record
           corlignum     like dacmligass.corlignum,
           corligano     like dacmligass.corligano,
           corasscod     like dackass.corasscod,
           corassagpcod  like dackassagp.corassagpcod,
           c24solnom     like dacmlig.c24solnom,
           corsus        like dacrligsus.corsus,
           empcod        like dacrligfun.empcod,
           funmat        like dacrligfun.funmat,
           c24paxnum     like dacmlig.c24paxnum,
           atdcademp     like isskfunc.empcod,
           atdcadmat     like isskfunc.funmat,
           c24soltipcod  like dacmlig.c24soltipcod, ---> PSI - 224030
           ciaempcod     like gabkemp.empcod        ---> PSI - 224030
    end record
    define ws  record
           contador         dec (10,0),
           statusq        dec (1,0),
           corasscod_web like dackass.corasscod,
           prporgpcp_web like dacrligorc.prporgpcp,
           prpnumpcp_web like dacrligorc.prpnumpcp,
           depto         char(1),
           sttweb        like dacmwebitf.sttweb,
           cpodes_mat    like iddkdominio.cpodes
    end record

    define l_c24soltipdes  like datksoltip.c24soltipdes  ---> PSI - 224030
    initialize ws.*  to null
    let ws.statusq = 0
    let ws.contador  = 0
    let ws.depto  = "N"
    let l_c24soltipdes = null  ---> PSI - 224030
    ------------[ Descricao do Solicitante ]------------
    select c24soltipdes into l_c24soltipdes
      from datksoltip
     where c24soltipcod = param.c24soltipcod

    ------------[ pesquisa se todos os atendentes acessa a web ]------------
    select count(*) into ws.contador
      from iddkdominio
     where cponom = "web_depto"
       and cpodes = "ct24hs"
    if ws.contador > 0 then     # todos do depto tem acesso a web
       let ws.depto = "S"
       select sttweb,
              corasscod,
              prporgpcp,
              prpnumpcp   # verificar se tabela existe
           into ws.sttweb,
                ws.corasscod_web,
                ws.prporgpcp_web,
                ws.prpnumpcp_web
           from dacmwebitf
          where corlignum = param.corlignum
            and corligano = param.corligano
            and atdcademp = g_issk.empcod   # matricula atendente
            and atdcadmat = g_issk.funmat
       if sqlca.sqlcode <> 0 then ---[ cria tabela para interface com web ]---
          execute i_dacmwebitf
               using param.corlignum,
                     param.corligano,
                     param.c24solnom,
                     param.atdcademp,  # empresa atendente
                     param.atdcadmat,  # matricula atendente
                     param.corsus,
                     param.c24paxnum,
                     param.empcod,
                     param.funmat,
                     param.corasscod,
                     "A",              # status
                     param.c24soltipcod, ---> PSI 224030
                     l_c24soltipdes      ---> PSI 224030
          let ws.statusq = 2     # matricula liberada para acesso a web
          return ws.statusq,
                 ws.corasscod_web,
                 ws.prporgpcp_web,
                 ws.prpnumpcp_web
       end if
       if ws.sttweb =  "A"  then  # assunto nao finalizado na web
          let ws.statusq = 2       # matricula liberada para acesso a web
          return ws.statusq,
                 ws.corasscod_web,
                 ws.prporgpcp_web,
                 ws.prpnumpcp_web
       end if
       let ws.statusq = 3          # assunto finalizado na web
    end if

    if ws.depto   = "N"  then

       let ws.contador  = 0
       if param.corassagpcod = 27 then #ligia
          ## pesquisa se a matricula tem acesso a endossos do grp 27
          select count(*) into ws.contador from datrastfun
            where c24astcod = param.corasscod
              and empcod = param.atdcademp
              and funmat = param.atdcadmat
       else
          ------------[ pesquisa se a matricula tem acesso a web ]------------
          let ws.cpodes_mat = g_issk.funmat
          select count(*) into ws.contador
            from iddkdominio
          #where cponom = "web_producao"
           where cponom matches  "web_producao*"
             and cpodes = ws.cpodes_mat
       end if

       if ws.contador = 0 then  # matricula sem acesso a web
          let ws.statusq = 1
          return ws.statusq,
                 ws.corasscod_web,
                 ws.prporgpcp_web,
                 ws.prpnumpcp_web
       end if
       --------[ verifica se a tabela existe para matricula ]----------
       select sttweb,
              corasscod,
              prporgpcp,
              prpnumpcp   # verificar se tabela existe
         into ws.sttweb,
              ws.corasscod_web,
              ws.prporgpcp_web,
              ws.prpnumpcp_web
          from dacmwebitf
         where corlignum = param.corlignum
           and corligano = param.corligano
           and atdcademp = g_issk.empcod   # matricula atendente
           and atdcadmat = g_issk.funmat
       if sqlca.sqlcode <> 0 then ---[ cria tabela para interface com web ]---
          execute i_dacmwebitf
               using param.corlignum,
                     param.corligano,
                     param.c24solnom,
                     param.atdcademp,  # empresa atendente
                     param.atdcadmat,  # matricula atendente
                     param.corsus,
                     param.c24paxnum,
                     param.empcod,
                     param.funmat,
                     param.corasscod,
                     "A",              # status
                     param.c24soltipcod, ---> PSI 224030
                     l_c24soltipdes      ---> PSI 224030
          let ws.statusq = 2
          return ws.statusq,
                 ws.corasscod_web,
                 ws.prporgpcp_web,
                 ws.prpnumpcp_web
       end if
       if ws.sttweb <> "F" then
          let ws.statusq = 2
          return ws.statusq,
                 ws.corasscod_web,
                 ws.prporgpcp_web,
                 ws.prpnumpcp_web
       end if
       let ws.statusq = 3
    end if
    return ws.statusq,
           ws.corasscod_web,
           ws.prporgpcp_web,
           ws.prpnumpcp_web
end function
#----------------------------------------------------------------------
function cte01m01_mens()
#----------------------------------------------------------------------

  define ws record
      ret     integer,
      espera  char(1)
  end record
  
  define l_msg char(100)

  open window w_cte01m01a at 11,19 with form "cte01m01a"
        attributes(border, form line 1)

  input by name ws.espera
     after field espera
        next field espera

     on key(f17, control-c, interrupt)
        exit input
     on key(F10)
       #call chama_prog("Emissao",
       #                "abs"    ,
       #                ""      )
       #    returning ws.ret
       
       #call oaacc190(" "," ")
       
       
       # Ini Psi 223689 
        call cty02g02_oaacc190(" "," ")
             returning l_msg 
        if l_msg is not null or
           l_msg <> " " then 
           error l_msg
        end if                    
       # Fim Psi 223689 

  end input
  close window w_cte01m01a
  let int_flag = false
  return

end function

#-----------------------------------#
function cte01m01_tela_temp(lr_param)
#-----------------------------------#

  define lr_param record
         vcllicnum     like abbmveic.vcllicnum,
         vclchsfnl     like abbmveic.vclchsfnl,
         vclchsinc     like abbmveic.vclchsinc
  end record
  define lr_input        record
         dtagenda        date,
         vcllicnum_input like svomvstagn.vcllicnum,
         vclchsinc       like svomvstagn.vclchsinc,
         vclchsfnl       like svomvstagn.vclchsfnl
  end record

  define al_array        array[500] of record
         sinvstpsttip    like svoksinvstpst.sinvstpsttip,
         sinvstpstnom    like svoksinvstpst.sinvstpstnom,
         vstagndat       like svomvstagn.vstagndat,
         vstagnhor       like svomvstagn.vstagnhor,
         vcllicnum       like svomvstagn.vcllicnum,
         vcltipnom       like agbktip.vcltipnom,
         vstatvtipcod    like svomvstagn.vstatvtipcod,
         vstagnnum       like svomvstagn.vstagnnum
  end record

  define l_i             smallint,
         l_vstagnnum     like svomvstagn.vstagnnum,
         l_sinvstpsttip  like svoksinvstpst.sinvstpsttip,
         l_arr           smallint,
         l_dtagenda      date

  if m_cte01m01_prep is null or
     m_cte01m01_prep <> true then
     call cte01m01_prep()
  end if

  let l_i            = null
  let l_arr          = null
  let l_vstagnnum    = null
  let l_sinvstpsttip = 2
  let l_dtagenda     = null

  initialize lr_input.* to null

  for l_i = 1 to 500
     let al_array[l_i].sinvstpsttip  = null
     let al_array[l_i].sinvstpstnom  = null
     let al_array[l_i].vstagndat     = null
     let al_array[l_i].vstagnhor     = null
     let al_array[l_i].vcllicnum     = null
     let al_array[l_i].vcltipnom     = null
     let al_array[l_i].vstatvtipcod  = null
     let al_array[l_i].vstagnnum     = null
  end for

  open window w_cta02m13a at 8,2 with form "cta02m13a"
     attributes(border, form line 1)

  input by name lr_input.dtagenda,
                lr_input.vcllicnum_input,
                lr_input.vclchsinc,
                lr_input.vclchsfnl without defaults

     # -> DATA DO AGENDAMENTO
     before field dtagenda
        display by name lr_input.dtagenda attribute(reverse)

     after field dtagenda
        display by name lr_input.dtagenda

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field dtagenda
        end if
        if lr_input.dtagenda is not null then
           select cpodes
              into l_dtagenda
              from iddkdominio
             where cponom = "dtagendaweb"
           if lr_input.dtagenda >= l_dtagenda then
              let lr_input.vcllicnum_input = null
              error "* ATENCAO - agendamento somente pela WEB *" sleep 3
              exit input
           else
              exit input
           end if
        end if

     # -> LICENCA(PLACA)
     before field vcllicnum_input
        let lr_input.vcllicnum_input = lr_param.vcllicnum
        display by name lr_input.vcllicnum_input attribute(reverse)

     after field vcllicnum_input
        display by name lr_input.vcllicnum_input

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field dtagenda
        end if

        if lr_input.vcllicnum_input is not null then
           exit input
        end if

     # -> CHASSI INICIAL
     before field vclchsinc
        let lr_input.vclchsinc = lr_param.vclchsinc
        display by name lr_input.vclchsinc attribute(reverse)

     after field vclchsinc
        display by name lr_input.vclchsinc

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field vcllicnum_input
        end if

     # -> CHASSI FINAL
     before field vclchsfnl
        let lr_input.vclchsfnl = lr_param.vclchsfnl
        display by name lr_input.vclchsfnl attribute(reverse)

     after field vclchsfnl
        display by name lr_input.vclchsfnl

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field vclchsinc
        end if

        if lr_input.vclchsinc is null or
           lr_input.vclchsfnl is null then
           error "Informe o numero do chassi !"
           next field vclchsinc
        end if

     on key(f17, control-c, interrupt)
        initialize lr_input.* to null
        error "Pesquisa cancelada !" sleep 2
        exit input

  end input

  if lr_input.vcllicnum_input is null and
     lr_input.vclchsinc       is null and
     lr_input.vclchsfnl       is null then
     let l_vstagnnum = null
  else
     let l_i = 1

     message "Favor aguardar, pesquisando..." attribute(reverse)

     if lr_input.vcllicnum_input is not null then
        # -> PESQUISA POR LICENCA(PLACA)
        open ccte01m01002 using l_sinvstpsttip, lr_input.vcllicnum_input
        foreach ccte01m01002 into al_array[l_i].sinvstpstnom,
                                  al_array[l_i].vstagndat,
                                  al_array[l_i].vstagnhor,
                                  al_array[l_i].vcllicnum,
                                  al_array[l_i].vcltipnom,
                                  al_array[l_i].vstatvtipcod,
                                  al_array[l_i].vstagnnum

           let al_array[l_i].sinvstpsttip = l_sinvstpsttip
           let l_i                        = (l_i + 1)

           if l_i > 500 then
              error "A quantidade de registros superou o limite do array!" sleep 3
              exit foreach
           end if

        end foreach
        close ccte01m01002
     else
        # -> PESQUISA POR CHASSI
        open ccte01m01003 using l_sinvstpsttip, lr_input.vclchsfnl
        foreach ccte01m01003 into al_array[l_i].sinvstpstnom,
                                  al_array[l_i].vstagndat,
                                  al_array[l_i].vstagnhor,
                                  al_array[l_i].vcllicnum,
                                  al_array[l_i].vcltipnom,
                                  al_array[l_i].vstatvtipcod,
                                  al_array[l_i].vstagnnum

           let al_array[l_i].sinvstpsttip = l_sinvstpsttip
           let l_i                        = (l_i + 1)

           if l_i > 500 then
              error "A quantidade de registros superou o limite do array!" sleep 3
              exit foreach
           end if

        end foreach
        close ccte01m01003

     end if
     let l_i = (l_i - 1)

     message " "

     if l_i = 0 then
        error "Nenhum agendamento encontrado !" sleep 3
     else
        call set_count(l_i)
        display array al_array to s_cta02m13a.*

           on key(f8)
              let l_arr       = arr_curr()
              let l_vstagnnum = al_array[l_arr].vstagnnum
              exit display

           on key(f17, control-c, interrupt)
              error "Nenhum agendamento selecionado!" sleep 2
              let l_vstagnnum = null
              exit display

        end display
     end if
  end if
  if lr_input.dtagenda is not null then
     if lr_input.dtagenda >= l_dtagenda then
        let l_vstagnnum = null
     else
        let l_vstagnnum = 99999
     end if
  else
     let l_vstagnnum = 99999
  end if
  close window w_cta02m13a
  let int_flag = false

  return l_vstagnnum

end function
#--------------------------------------------------------------------------
 function cte01m01_questoes(param)
#--------------------------------------------------------------------------
  define param record
      corlignum    like dacmlig.corlignum,
      corligano    like dacmlig.corligano,
      prporgpcp    like apamcapa.prporgpcp,
      prpnumpcp    like apamcapa.prpnumpcp,
      corligitmseq like dacmligass.corligitmseq
  end record
  define ws record
      cpodes     like iddkdominio.cpodes,
      texto      char(200),
      solnom     char(70),
      ctpw       char(70),
      ctpwtexto1 char(50),
      ctpwtexto2 char(50),
      ctpwtexto3 char(50),
      ctpwtexto4 char(70),
      po         char(70),
      potexto1   char(50),
      potexto2   char(50),
      potexto3   char(50),
      potexto4   char(50),
      confirma   char(01),
      caddat     char(10),
      cadhor     datetime hour to minute,
      status     smallint,
      poslv      char(01)
  end record
  define d_cte01m01b record
      soltip      char(01),
      ctpw        char(01),
      potxt       char(47),
      po          char(1)
  end record

  initialize ws.*          to null
  initialize d_cte01m01b.* to null

  select cpodes
      into ws.cpodes
      from iddkdominio
     where cponom="pesquisaauto"
  if ws.cpodes <> "sim" or
     sqlca.sqlcode <> 0 then
     return
  end if

  select difpcfflg
    into d_cte01m01b.po
    from porto@u18:apamcapa
   #from apamcapa
   where prporgpcp = param.prporgpcp
     and prpnumpcp = param.prpnumpcp
   if sqlca.sqlcode <> 0  then
      error "Orcamento nao encontrado para questionario"  sleep 2
      let d_cte01m01b.po = null
      return
   end if

   if d_cte01m01b.po = "N" then
      let d_cte01m01b.potxt = "Sem Preco Online,pressione <Enter> para Motivo:"
   end if
   if d_cte01m01b.po = "S" then
      let d_cte01m01b.potxt = "Orcamento realizado com Preco Online"
   end if
   let ws.poslv = d_cte01m01b.po
  open window cte01m01b at 08,15 with form "cte01m01b"
              attribute(border,form line 1)

 while true
  let int_flag = false
  input by name d_cte01m01b.soltip,
                d_cte01m01b.ctpw,
                d_cte01m01b.po      without defaults

      before field soltip
         display by name d_cte01m01b.potxt
         display by name d_cte01m01b.po      attribute (reverse)
         display by name d_cte01m01b.soltip  attribute (reverse)

      after field soltip
         display by name d_cte01m01b.soltip
         if d_cte01m01b.soltip is null then
            error "Tipo de Solicitante e obrigatorio"
            next field soltip
         end if
         if d_cte01m01b.soltip is not null  then
            if d_cte01m01b.soltip < 1  or
               d_cte01m01b.soltip > 3  then
               error "Tipo de Solicitante invalido"
               next field soltip
            end if
            if d_cte01m01b.soltip  =  1  then
               let ws.solnom      =  "TIPO SOLICITANTE:Corretor"
            else
               if d_cte01m01b.soltip  =  2 then
                  let ws.solnom   =  "TIPO SOLICITANTE:Funcionario Corretora"
               else
                  if d_cte01m01b.soltip  = 3 then
                     let ws.solnom = "TIPO SOLICITANTE:Preposto"
                  else
                     let ws.solnom = "TIPO SOLICITANTE:Nao Informado"
                  end if
               end if
            end if
         end if

      before field ctpw
         display by name d_cte01m01b.ctpw    attribute (reverse)

      after field ctpw
         display by name d_cte01m01b.ctpw
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field soltip
         end if
         if d_cte01m01b.ctpw  is null then
            error "Opcao e obrigatoria"
            next field ctpw
         end if
         if d_cte01m01b.ctpw  is not null  then
            if d_cte01m01b.ctpw  < 1  or
               d_cte01m01b.ctpw  > 2  then
               error "Opcao invalida"
               next field ctpw
            end if
            if d_cte01m01b.ctpw = 1 then
               let ws.ctpw = "CENTRALouPORTOPRINT:CENTRAL"
            else
               let ws.ctpw = "CENTRALouPORTOPRINT:PORTOPRINT"
            end if
            let ws.texto=ws.ctpwtexto1,ws.ctpwtexto2,ws.ctpwtexto3,ws.ctpwtexto4
            call cte01m01_texto(1,ws.ctpw,ws.texto) returning ws.texto
            if ws.texto is null or
               ws.texto =  "    " then
               error "Informe o motivo"
               next field ctpw
            end if
            if ws.texto is not null then
              #let ws.ctpwtexto1 = "CENTRALouPORTOPRINT:",ws.texto[1,50]
              #let ws.ctpwtexto2 = "CENTRALouPORTOPRINT:",ws.texto[51,100]
              #let ws.ctpwtexto3 = "CENTRALouPORTOPRINT:",ws.texto[101,150]
              #let ws.ctpwtexto4 = "CENTRALouPORTOPRINT:",ws.texto[151,200]
               let ws.ctpwtexto1 = ws.texto[1,50]
               let ws.ctpwtexto2 = ws.texto[51,100]
               let ws.ctpwtexto3 = ws.texto[101,150]
               let ws.ctpwtexto4 = ws.texto[151,200]
            end if
         end if

      before field po
         display by name d_cte01m01b.po      attribute (reverse)
         if d_cte01m01b.po  = "S" or
            d_cte01m01b.po  is null then
            exit input
         end if

      after field po
         display by name d_cte01m01b.po
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field ctpw
         end if
         if d_cte01m01b.po  is null or
            d_cte01m01b.po  <> ws.poslv then
            let d_cte01m01b.po = ws.poslv
            error "Informe o motivo"
            next field po
         end if
         if d_cte01m01b.po = "N"       then
            let ws.po = "PRECO ONLINE:NAO"
            let ws.texto = null
            let ws.texto = ws.potexto1,ws.potexto2,ws.potexto3,ws.potexto4
            call cte01m01_texto(2,ws.po,ws.texto) returning ws.texto
            if ws.texto is null or
               ws.texto =  "    " then
               error "Informe o motivo"
               next field po
            end if
            if ws.texto is not null then
              #let ws.potexto1 = "PRECO ONLINE:",ws.texto[001,050]
              #let ws.potexto2 = "PRECO ONLINE:",ws.texto[051,100]
              #let ws.potexto3 = "PRECO ONLINE:",ws.texto[101,150]
              #let ws.potexto4 = "PRECO ONLINE:",ws.texto[151,200]
               let ws.potexto1 = ws.texto[001,050]
               let ws.potexto2 = ws.texto[051,100]
               let ws.potexto3 = ws.texto[101,150]
               let ws.potexto4 = ws.texto[151,200]
            end if
         end if

      on key (interrupt)
         exit input
  end input
  if int_flag then
     let int_flag = false
  end if
  if d_cte01m01b.soltip is null or
     d_cte01m01b.soltip = " "   or
     ws.texto           is null or
     ws.texto           = " "   then
     error "O Preenchimento e Obrigatorio"
     continue while
  end if
  exit while
 end while

  close window cte01m01b
  ----------------------[ grava historico ]----------------------
  let ws.caddat = today
  let ws.cadhor = current hour to minute
  call cte01m04_insere("","",
                       param.corlignum,
                       param.corligano,
                       param.corligitmseq,"",
                       ws.solnom,
                       ws.caddat,
                       ws.cadhor)
      returning ws.status
  call cte01m04_insere("","",
                       param.corlignum,
                       param.corligano,
                       param.corligitmseq,"",
                       ws.ctpw  ,
                       ws.caddat,
                       ws.cadhor)
      returning ws.status
  if ws.ctpwtexto1 is not null and
     ws.ctpwtexto1 <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.ctpwtexto1,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if
  if ws.ctpwtexto2 is not null and
     ws.ctpwtexto2 <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.ctpwtexto2,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if
  if ws.ctpwtexto3 is not null and
     ws.ctpwtexto3 <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.ctpwtexto3,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if
  if ws.ctpwtexto4 is not null and
     ws.ctpwtexto4 <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.ctpwtexto4,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if
  if ws.po         is not null and
     ws.po         <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.po        ,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if
  if ws.potexto1   is not null and
     ws.potexto1   <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.potexto1  ,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if
  if ws.potexto2   is not null and
     ws.potexto2   <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.potexto2  ,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if
  if ws.potexto3   is not null and
     ws.potexto3   <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.potexto3  ,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if
  if ws.potexto4   is not null and
     ws.potexto4   <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.potexto4  ,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if

 end function
#---------------------------------------------------------------------------
  function cte01m01_texto(param)
#---------------------------------------------------------------------------
     define param record
          cab   dec(1,0),
          text  char(40),
          texto char(200)
     end record
     define ws  record
          texto char(200)
     end record
     define d_cte01m01c record
          cab   char(50)
     end record
     define a_cte01m01c array[4] of record
          texto      char (50)
     end record
     define arr_aux    smallint
     define scr_aux    smallint

     initialize ws.*          to null
     initialize d_cte01m01c.* to null
     initialize a_cte01m01c   to null

     if param.cab = 1 then
        let d_cte01m01c.cab = param.text clipped,"  POR QUE?"
     else
        let d_cte01m01c.cab = param.text clipped,"  INFORME O MOTIVO"
     end if

     let a_cte01m01c[1].texto = param.texto[001,050]
     let a_cte01m01c[2].texto = param.texto[051,100]
     let a_cte01m01c[3].texto = param.texto[101,150]
     let a_cte01m01c[4].texto = param.texto[151,200]

     open window w_cte01m01c at  11,15 with form "cte01m01c"
                attribute(border,form line first)

     while true
        display by name d_cte01m01c.cab

        let int_flag = false
        let arr_aux = 5
        call set_count(arr_aux - 1)

        input array a_cte01m01c without defaults from s_cte01m01c.*

           before row
              let arr_aux = arr_curr()
              let scr_aux = scr_line()

           before field texto
              display a_cte01m01c[arr_aux].texto to
                      s_cte01m01c[scr_aux].texto attribute (reverse)

           after field texto
              display a_cte01m01c[arr_aux].texto to
                      s_cte01m01c[scr_aux].texto

              if fgl_lastkey() = fgl_keyval("up")    or
                 fgl_lastkey() = fgl_keyval("left")  then
                 next field texto
              end if

           on key (control-c)
             #let int_flag = true
              exit input

           after row
              if arr_aux = 4 then
                 if fgl_lastkey() = fgl_keyval ("up")     or
                    fgl_lastkey() = fgl_keyval ("left")   then
                    continue input
                  else
                    exit input
                 end if
              end if
        end input

       #if int_flag = false then
           if a_cte01m01c[1].texto is not null then
              let ws.texto = a_cte01m01c[1].texto, a_cte01m01c[2].texto,
                             a_cte01m01c[3].texto, a_cte01m01c[4].texto
              exit while
           else
              error "Informe o motivo"
           end if
       #end if
     end while

     let int_flag = false

     close window w_cte01m01c
     return ws.texto

  end function

#--------------------------------------------------------------------------
 function cte01m01_questoes2(param)
#--------------------------------------------------------------------------
  define param record
      corlignum    like dacmlig.corlignum,
      corligano    like dacmlig.corligano,
      prporgpcp    like apamcapa.prporgpcp,
      prpnumpcp    like apamcapa.prpnumpcp,
      corligitmseq like dacmligass.corligitmseq
  end record

  define ws record
      cpodes     like iddkdominio.cpodes,
      texto      char(200),
      mtvnom     char(70),
      mtvwtexto1 char(50),
      mtvwtexto2 char(50),
      mtvwtexto3 char(50),
      mtvwtexto4 char(70),
      confirma   char(01),
      caddat     char(10),
      cadhor     datetime hour to minute,
      status     smallint
  end record

  define d_cte01m01d record
      mtvtip      char(01)
  end record

  define l_cte01m01dpo char(1)

  initialize ws.*          to null
  initialize d_cte01m01d.* to null

  let l_cte01m01dpo = null

  select cpodes
      into ws.cpodes
      from iddkdominio
     where cponom="pesquisaauto"
  if ws.cpodes <> "sim" or
     sqlca.sqlcode <> 0 then
     return
  end if

  select difpcfflg
    into l_cte01m01dpo
    from porto@u18:apamcapa
    #from apamcapa
   where prporgpcp = param.prporgpcp
     and prpnumpcp = param.prpnumpcp
   if sqlca.sqlcode <> 0  then
      error "Orcamento nao encontrado para questionario"  sleep 2
      return
   end if

   if l_cte01m01dpo = "S" then
       return
   end if



  open window cte01m01d at 08,15 with form "cte01m01d"
              attribute(border,form line 1)

 while true
  let int_flag = false
  input by name d_cte01m01d.mtvtip without defaults



      before field mtvtip
           display by name d_cte01m01d.mtvtip  attribute (reverse)

      after field mtvtip
         display by name d_cte01m01d.mtvtip
         if d_cte01m01d.mtvtip is null then
            error "Motivo e obrigatorio"
            next field mtvtip
         end if

         if d_cte01m01d.mtvtip is not null  then
            if d_cte01m01d.mtvtip < 1  or
               d_cte01m01d.mtvtip > 3  then
               error "Motivo Invalido"
               next field mtvtip
            end if

            if d_cte01m01d.mtvtip  =  1  then
               let ws.mtvnom      =  "MOTIVO:Abertura de Consulta"
            else
               if d_cte01m01d.mtvtip  =  2 then
                  let ws.mtvnom   =  "MOTIVO:Veiculo nao Cadastrado no PPW"
               else
                  if d_cte01m01d.mtvtip  = 3 then
                     let ws.mtvnom = "MOTIVO:Outros"
                  end if

                  let ws.texto = null
                  let ws.texto=ws.mtvwtexto1,ws.mtvwtexto2,ws.mtvwtexto3,ws.mtvwtexto4
                  call cte01m01_texto(2,ws.mtvnom,ws.texto) returning ws.texto
                  if ws.texto is null or
                     ws.texto =  "    " then
                     error "Informe o motivo"
                     next field mtvtip
                  end if
                  if ws.texto is not null then
                     let ws.mtvwtexto1 = ws.texto[1,50]
                     let ws.mtvwtexto2 = ws.texto[51,100]
                     let ws.mtvwtexto3 = ws.texto[101,150]
                     let ws.mtvwtexto4 = ws.texto[151,200]
                  end if

               end if
            end if
         end if


      on key (interrupt)
         exit input
  end input

  if int_flag then
     let int_flag = false
  end if
  if d_cte01m01d.mtvtip is null or
     d_cte01m01d.mtvtip = " "   then
           error "O Preenchimento e Obrigatorio"
           continue while
  else
     if d_cte01m01d.mtvtip = 3 and
        (ws.texto           is null or
         ws.texto           = " ")   then
           error "O Preenchimento do texto e Obrigatorio"
           continue while
     end if
  end if
  exit while
 end while

  close window cte01m01d
  ----------------------[ grava historico ]----------------------
  let ws.caddat = today
  let ws.cadhor = current hour to minute
  call cte01m04_insere("","",
                       param.corlignum,
                       param.corligano,
                       param.corligitmseq,"",
                       ws.mtvnom,
                       ws.caddat,
                       ws.cadhor)
      returning ws.status


  if ws.mtvwtexto1 is not null and
     ws.mtvwtexto1 <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.mtvwtexto1,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if
  if ws.mtvwtexto2 is not null and
     ws.mtvwtexto2 <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.mtvwtexto2,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if
  if ws.mtvwtexto3 is not null and
     ws.mtvwtexto3 <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.mtvwtexto3,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if
  if ws.mtvwtexto4 is not null and
     ws.mtvwtexto4 <> "      " then
     call cte01m04_insere("","",
                          param.corlignum,
                          param.corligano,
                          param.corligitmseq,"",
                          ws.mtvwtexto4,
                          ws.caddat,
                          ws.cadhor)
      returning ws.status
  end if


 end function                                                                
