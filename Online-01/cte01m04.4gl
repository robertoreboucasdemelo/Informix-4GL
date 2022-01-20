#############################################################################
# Nome do Modulo: CTE01M04                                             Akio #
#                                                                      Ruiz #
# Atendimento ao corretor - Historico do assunto da ligacao        Abr/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################
#                        * * * A L T E R A C A O * * *                      #
#  Analista Resp. : Ligia Mattge                                            #
#  PSI            : 170178 - OSF: 18902                                     #
#...........................................................................#
#  Data        Autor Fabrica  Alteracao                                     #
#  ----------  -------------  ----------------------------------------------#
#  20/05/2003  Gustavo(FSW)   Inclusao  do  f5, que  abrira' tela popup das #
#                             acoes padroes, ira' gerar um arquivo para ser #
#                             enviado  por  e-mail ao tecnico do PAC e seus #
#                             coordenadores.                                #
#  05/03/2004  Cesar Lucca    CT 172871                                     #
#---------------------------------------------------------------------------#
# 24/01/2005   Lucas, Meta    Inclusao da chamada da funcao oaacc190() para #
#                             a tecla de atalho F10.                        #
# 08/03/2010  Adriano Santos  CT10029839  Retirar emails com padrao antigo  #
#---------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#############################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define   g_cte01m04      smallint

 define m_ret_fgrhc001    record
        result            smallint
       ,mailgicod         like grhkmai.mailgicod
       ,endfunc           char(86)
       ,endchefe1         char(86)
       ,endchefe2         char(86)
 end record

 define m_file            char(14)
       ,m_cmd             char(500)
       ,m_ret_insere      smallint
       ,m_ret             integer
       ,m_c24txtseq       like dacmligasshst.c24txtseq
       ,m_desc_acao       char(01)

#--------------------------------
function cte01m04_prepare()
#--------------------------------

  define l_sql char(1000)

 #------------------------------------------------------------------------------
 # Preparacao dos comandos SQL
 #------------------------------------------------------------------------------

       let l_sql = "select dacmligasshst.corligitmseq, ",
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

       prepare s_dacmligasshst from   l_sql
       declare c_dacmligasshst cursor with hold for s_dacmligasshst

       let l_sql = "select funnom "                       ,
                         "from ISSKFUNC "                     ,
                              "where empcod = ? "             ,
                                "and funmat = ? "

       prepare s_isskfunc  from   l_sql
       declare c_isskfunc  cursor with hold for s_isskfunc

       let l_sql = "select corassdes   , "                ,
                              "corassagpcod, "                ,
                              "maienvflg "                    ,
                         "from DACKASS "                      ,
                              "where corasscod = ?  "

       prepare s_dackass   from   l_sql
       declare c_dackass   cursor with hold for s_dackass

       let l_sql = "select corassagpsgl "                 ,
                         "from DACKASSAGP "                   ,
                              "where corassagpcod = ?  "

       prepare s_dackassagp   from   l_sql
       declare c_dackassagp   cursor with hold for s_dackassagp

       let l_sql = "select max(c24txtseq) "        ,
                         "from DACMLIGASSHST "            ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare sm_dacmligasshst from   l_sql
       declare cm_dacmligasshst cursor with hold for sm_dacmligasshst

       let l_sql = "select fcapacorg, fcapacnum "
                      ,"from dacrligpac             "
                      ,"where corlignum    = ?      "
                      ,"  and corligano    = ?      "
                      ,"  and corligitmseq = ?      "

       prepare pcte01m04001 from l_sql
       declare ccte01m04001 cursor with hold for pcte01m04001

       let l_sql = "select funmat               "
                      ,"from mfimpar                "
                      ,"where fcapacorg = ?         "
                      ,"  and fcapacnum = ?         "
                      ,"  and fcaparseq = (select   "
                      ,"max(fcaparseq) from mfimpar "
                      ,"where fcapacorg = ?         "
                      ,"  and fcapacnum = ?)        "

       prepare pcte01m04002 from l_sql
       declare ccte01m04002 cursor with hold for pcte01m04002

       let l_sql = "select grlinf               "
                      ,"from datkgeral              "
                      ,"where grlchv = ?            "

       prepare pcte01m04003 from l_sql
       declare ccte01m04003 cursor with hold for pcte01m04003

       let l_sql = "select pfsnom               "
                      ,"from mfimpfs                "
                      ,"where fcapacorg = ?         "
                      ,"  and fcapacnum = ?         "
                      ,"  and pfsseq    = 0         "

       prepare pcte01m04004 from l_sql
       declare ccte01m04004 cursor with hold for pcte01m04004

       let l_sql = "select corsus               "
                      ,"from dacrligsus             "
                      ,"where corlignum = ?         "
                      ,"  and corligano = ?         "

       prepare pcte01m04005 from l_sql
       declare ccte01m04005 cursor with hold for pcte01m04005

       let l_sql = "select corsuspcp            "
                      ,"from gcaksusep              "
                      ,"where corsus = ?            "

       prepare pcte01m04006 from l_sql
       declare ccte01m04006 cursor with hold for pcte01m04006

       let l_sql = "select cornom               "
                      ,"from gcakcorr               "
                      ,"where corsuspcp = ?         "

       prepare pcte01m04007 from l_sql
       declare ccte01m04007 cursor with hold for pcte01m04007

       let l_sql = "select c24solnom            "
                      ,"from dacmlig                "
                      ,"where corlignum = ?         "
                      ,"  and corligano = ?         "

       prepare pcte01m04008 from l_sql
       declare ccte01m04008 cursor with hold for pcte01m04008

       let l_sql = "select c24ligdsc, c24txtseq "
                      ,"from dacmligasshst          "
                      ,"where corlignum    = ?      "
                      ,"  and corligano    = ?      "
                      ,"  and corligitmseq = ?      "
                      ,"order by c24txtseq          "

       prepare pcte01m04009 from l_sql
       declare ccte01m04009 cursor with hold for pcte01m04009

       let l_sql = " select sitename[1,3] "
                      ," from dual "

       prepare pcte01m04010 from l_sql
       declare ccte01m04010 cursor for pcte01m04010

       #--
       #-- CT 172871
       let l_sql = "select cgccpfnum, cgcord    "
                      ,"from mfimanalise            "
                      ,"where fcapacorg = ?         "
                      ,"  and fcapacnum = ?         "

       prepare pcte01m04011 from l_sql
       declare ccte01m04011 cursor with hold for pcte01m04011

       let l_sql = "select segnom               "
                      ,"from gsakseg             "
                      ,"where cgccpfnum = ?         "
                      ,"  and cgcord    = ?         "
                      ,"  and pestip    = 'J'       "

       prepare pcte01m04012 from l_sql
       declare ccte01m04012 cursor with hold for pcte01m04012

       let l_sql = " insert into dacmligasshst(corlignum, ",
                                                 " corligano, ",
                                                 " corligitmseq, ",
                                                 " c24txtseq, ",
                                                 " c24ligdsc, ",
                                                 " cademp, ",
                                                 " cadmat, ",
                                                 " caddat, ",
                                                 " cadhor) ",
                                          " values(?,?,?,?,?,?,?,?,?) "

       prepare pcte01m04013 from l_sql

  let g_cte01m04 = true

end function

#---------------------------------------------------------------
 function cte01m04( p_cte01m04 )
#---------------------------------------------------------------

   define p_cte01m04      record
          tipo            char(01)                       ,
          obrig           char(01)                       ,
          corlignum       like dacmligasshst.corlignum   ,
          corligano       like dacmligasshst.corligano   ,
          corligitmseq    like dacmligasshst.corligitmseq,
          corasscod       like dacmligass.corasscod
   end record

   define a_cte01m04      array[200] of record
          c24ligdsc       like dacmligasshst.c24ligdsc
   end record

   define x_cte01m04      array[500] of record
          c24ligdsc       like dacmligasshst.c24ligdsc
   end record

   define ws              record
          data            date                        ,
          hora            datetime hour to minute     ,
          corligitmseq    like dacmligasshst.corligitmseq,
          corligitmseqant like dacmligasshst.corligitmseq,
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
          maienvflg       like dackass.maienvflg      ,
          corassagpcod    like dackassagp.corassagpcod,
          corassagpsgl    like dackassagp.corassagpsgl,
          funnom          like isskfunc.funnom        ,
          assunto         char(55)
   end record

   define arr_aux         smallint
   define scr_aux         smallint
   define l_ret_acao      smallint
   define l_msg           char(100)

 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------

        define  w_pf1   integer

        let     arr_aux  =  null
        let     scr_aux  =  null

        for     w_pf1  =  1  to  200
                initialize  a_cte01m04[w_pf1].*  to  null
        end     for

        for     w_pf1  =  1  to  500
                initialize  x_cte01m04[w_pf1].*  to  null
        end     for

        initialize  ws.*  to  null

   initialize a_cte01m04,
              x_cte01m04,
              ws        ,
              arr_aux   ,
              scr_aux   to null

   options insert key f35 ,
           delete key f36

   if g_cte01m04 is null or
      g_cte01m04 <> true then
      call cte01m04_prepare()
   end if

   if  p_cte01m04.tipo = "C"  then
       open window win_cte01m04c at 03,02 with form "cte01m04"
            attribute (form line first)
   else
       open window win_cte01m04a at 03,02 with form "cte01m04"
            attribute (form line first)
   end if

   display by name p_cte01m04.corlignum   ,
                   p_cte01m04.corligano   ,
                   p_cte01m04.corligitmseq


   let arr_aux = 1
   if  p_cte01m04.tipo = "C"  then

       initialize ws.assunto to null
       display by name ws.assunto
       display "CONSULTA" to acao
               attribute(reverse)

       message " <F17> Abandona "

      #let  ws.corligitmseqant = 0
       let  ws.cadempant   =  0
       let  ws.cadmatant   =  0
       let  ws.caddatant   =  0
       let  ws.cadhorant   =  0
       open    c_dacmligasshst using p_cte01m04.corlignum,
                                     p_cte01m04.corligano,
                                     p_cte01m04.corligitmseq
       foreach c_dacmligasshst into  ws.corligitmseq,
                                     ws.corasscod   ,
                                     ws.c24ligdsc   ,
                                     ws.cademp      ,
                                     ws.cadmat      ,
                                     ws.caddat      ,
                                     ws.cadhor

          #if  ws.corligitmseq <> ws.corligitmseqant  then
           if  ws.cademp       <> ws.cadempant  or
               ws.cadmat       <> ws.cadmatant  or
               ws.caddat       <> ws.caddatant  or
               ws.cadhor       <> ws.cadhorant  then
            #if  ws.corligitmseqant <> 0  then
               let x_cte01m04[arr_aux].c24ligdsc =
                                 "------------------------------------------",
                                 "------------------------------------------"
               let arr_aux = arr_aux + 1

               open  c_isskfunc using ws.cademp,
                                      ws.cadmat
               fetch c_isskfunc into  ws.funnom

               let x_cte01m04[arr_aux].c24ligdsc =
                                 "Atualizacao em ", ws.caddat,
                                 " as " , ws.cadhor,
                                 " por ", ws.cademp using "&&",
                                 "/"    , ws.cadmat using "&&&&&&",
                                 " - "  , ws.funnom clipped
               let arr_aux = arr_aux + 1


               open  c_dackass using ws.corasscod
               fetch c_dackass into  ws.corassdes   ,
                                     ws.corassagpcod,
                                     ws.maienvflg

               open  c_dackassagp using ws.corassagpcod
               fetch c_dackassagp into  ws.corassagpsgl

               let x_cte01m04[arr_aux].c24ligdsc =
                                 "Assunto: ", ws.corasscod    using "&&&&",
                                 " ", ws.corassagpsgl clipped     ,
                                 "-", ws.corassdes    clipped

               let arr_aux = arr_aux + 2

               if  arr_aux > 500  then
                   error " Qtde de 500 linhas de historico excedida!"
                   exit foreach
               end if
            #end if

            #let ws.corligitmseqant = ws.corligitmseq

             let ws.cadempant      =  ws.cademp
             let ws.cadmatant      =  ws.cadmat
             let ws.caddatant      =  ws.caddat
             let ws.cadhorant      =  ws.cadhor
           end if

           let x_cte01m04[arr_aux].c24ligdsc = ws.c24ligdsc
           let arr_aux = arr_aux + 1

           if  arr_aux > 500  then
               error " Qtde de 500 linhas de historico excedida!"
               exit foreach
           end if
       end foreach

       if  arr_aux = 1  then
           let x_cte01m04[arr_aux].c24ligdsc = "Atendimento sem historico !"
           let arr_aux = arr_aux + 1
       end if

       call set_count( arr_aux - 1)
       display array x_cte01m04 to s_cte01m04.*
            on key (interrupt)
               exit display
       end display

   else
       let m_c24txtseq = 0

       open  c_dackass using p_cte01m04.corasscod
       fetch c_dackass into  ws.corassdes   ,
                             ws.corassagpcod,
                             ws.maienvflg

       open  c_dackassagp using ws.corassagpcod
       fetch c_dackassagp into  ws.corassagpsgl

       let ws.assunto = "Assunto: ", p_cte01m04.corasscod using "&&&&",
                                " ", ws.corassagpsgl clipped,
                                "-", ws.corassdes    clipped
       display by name ws.assunto
       display "INCLUSAO" to acao
               attribute(reverse)

       message "<F17> Abandona  <F5> E-mail  <F6> Consulta  <F10> Macro sistemas "

       while true
          let ws.data = today
          let ws.hora = current hour to minute

          let int_flag = false

          call set_count(arr_aux - 1)

          input array a_cte01m04 without defaults from s_cte01m04.*
             before row
                let arr_aux = arr_curr()
                let scr_aux = scr_line()

             before insert
                initialize a_cte01m04[arr_aux].c24ligdsc  to null

                display a_cte01m04[arr_aux].c24ligdsc  to
                        s_cte01m04[scr_aux].c24ligdsc

             before field c24ligdsc
                display a_cte01m04[arr_aux].c24ligdsc to
                        s_cte01m04[scr_aux].c24ligdsc attribute (reverse)

             after  field c24ligdsc
                display a_cte01m04[arr_aux].c24ligdsc to
                        s_cte01m04[scr_aux].c24ligdsc

                if  fgl_lastkey() = fgl_keyval("left")  or
                    fgl_lastkey() = fgl_keyval("up")    then
                    error " Alteracoes e/ou correcoes nao sao permitidas!"
                    next field c24ligdsc
                else
                    if  a_cte01m04[arr_aux].c24ligdsc = " "    or
                        a_cte01m04[arr_aux].c24ligdsc is null  then
                        error " Complemento deve ser informado!"
                        next field c24ligdsc
                    end if
                end if

             on key (f5)
                if ws.maienvflg is null or
                   ws.maienvflg = 'N'   then
                   error "Assunto nao permite envio de e-mail!"
                   next field c24ligdsc
                else
                   let l_ret_acao = null
                   call cte01m04_acao(p_cte01m04.*
                                     ,ws.data
                                     ,ws.hora
                                     ,ws.corassdes)
                        returning l_ret_acao

                   if l_ret_acao <> 0 then
                      error "Nao ha' Complemento de Informacao a ser enviado!"
                      next field c24ligdsc
                   end if
                end if
                let int_flag = true
                exit input

             on key (f6)
                call cte01m04( "C","",
                               p_cte01m04.corlignum,
                                       p_cte01m04.corligano,
                               p_cte01m04.corligitmseq, ""  )

            on key(f10)

               # Ini Psi223689
                 call cty02g02_oaacc190(" "," ")
                 returning l_msg
                 if l_msg is not null or
                    l_msg <> " " then
                    error l_msg
                 end if


               # Fim Psi223689

               #call oaacc190('','')

             on key (interrupt)
                if  p_cte01m04.obrig = "S"  then
                    if  m_c24txtseq  = 0  then
                        error " O registro no historico e obrigatorio! "
                        next field c24ligdsc
                    else
                        exit input
                    end if
                else
                    exit input
                end if

             after row
                let m_desc_acao  = 'N'
                let m_ret_insere = null
                call cte01m04_insere (p_cte01m04.*
                                     ,a_cte01m04[arr_aux].c24ligdsc
                                     ,ws.data
                                     ,ws.hora)
                     returning m_ret_insere

                if m_ret_insere <> 0 then
                   next field c24ligdsc
                end if

          end input

          if  int_flag  then
              exit while
          end if

       end while
   end if

   let int_flag = false

   if  p_cte01m04.tipo = "C"  then
       close window win_cte01m04c
   else
       close window win_cte01m04a
   end if

end function

#------------------------------------------------------------------
function cte01m04_insere(l_cte01m04, l_coracades, lc_data, lc_hora)
#------------------------------------------------------------------

   define l_cte01m04      record
          tipo            char(01)
         ,obrig           char(01)
         ,corlignum       like dacmligasshst.corlignum
         ,corligano       like dacmligasshst.corligano
         ,corligitmseq    like dacmligasshst.corligitmseq
         ,corasscod       like dacmligass.corasscod
   end record

   define l_coracades     like dacmligasshst.c24ligdsc
         ,lc_data         char(10)
         ,lc_hora         datetime hour to minute

   if g_cte01m04 is null or
      g_cte01m04 <> true then
      call cte01m04_prepare()
   end if

   open  cm_dacmligasshst using l_cte01m04.corlignum
                               ,l_cte01m04.corligano
                               ,l_cte01m04.corligitmseq
   whenever error continue
   fetch cm_dacmligasshst into  m_c24txtseq
   whenever error stop

   if sqlca.sqlcode   <> 0 then
      if sqlca.sqlcode <  0 then
         error "Nao foi possivel acessar o Historico, "
              ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
         sleep(2)
         close cm_dacmligasshst
         return 1
      end if
   end if
   close cm_dacmligasshst

   if  m_c24txtseq is null  then
       let m_c24txtseq = 0
   end if

   if m_desc_acao     = 'S' then
      let m_c24txtseq = 0
   else
      let m_c24txtseq = m_c24txtseq + 1
   end if

   #whenever error continue
   execute pcte01m04013 using l_cte01m04.corlignum
                             ,l_cte01m04.corligano
                             ,l_cte01m04.corligitmseq
                             ,m_c24txtseq
                             ,l_coracades
                             ,g_issk.empcod
                             ,g_issk.funmat
                             ,lc_data
                             ,lc_hora

   #whenever error stop

   if  sqlca.sqlcode <> 0  then
       error " Erro (",sqlca.sqlcode,") na inclusao do "
            ,"historico. Favor re-digitar a linha."
       sleep(2)
       return 1
   end if
   return 0

end function

#---------------------------------------------------------------
function cte01m04_acao(l_acao, l_data, l_hora, l_corassdes)
#---------------------------------------------------------------

   define l_acao          record
          tipo            char(01)
         ,obrig           char(01)
         ,corlignum       like dacmligasshst.corlignum
         ,corligano       like dacmligasshst.corligano
         ,corligitmseq    like dacmligasshst.corligitmseq
         ,corasscod       like dacmligass.corasscod
   end record

   define l_data          date
         ,l_hora          datetime hour to minute
         ,l_corassdes     like dackass.corassdes

   define l_pop           record
          sql             char(300) ## Comando sql passado para a popup
         ,result          smallint  ## Flag de verificacao (retorno popup)
   end record

   define l_dackaca       record
          coracacod       like dackaca.coracacod
         ,coracades       like dackaca.coracades
   end record

   define l_dacrligpac    record
          fcapacorg       like dacrligpac.fcapacorg
         ,fcapacnum       like dacrligpac.fcapacnum
   end record

   define l_mfimpar       record
          funmat          like mfimpar.funmat
   end record

   define l_mfimpfs       record
          pfsnom          like mfimpfs.pfsnom
   end record

   define l_dacrligsus    record
          corsus          like dacrligsus.corsus
   end record

   define l_gcaksusep     record
          corsuspcp       like gcaksusep.corsuspcp
   end record

   define l_gcakcorr      record
          cornom          like gcakcorr.cornom
   end record

   define l_dacmlig       record
          c24solnom       like dacmlig.c24solnom
   end record

   define l_datkgeral     record
          grlinf          like datkgeral.grlinf
   end record

   #--
   #-- CT 172871
   define l_mfimanalise   record
          cgccpfnum       like mfimanalise.cgccpfnum
         ,cgcord          like mfimanalise.cgcord
   end record

   define l_gsakseg    record
          segnom          like gsakseg.segnom
   end record
   #--

   define l_dt_corrente   date
         ,l_aux_hora      datetime hour to second
         ,l_hora_for      char(08)
         ,l_h_corrente    char(05)
         ,l_conv_cod      like datkgeral.grlchv
         ,l_aux_coord_tec char(06)
         ,l_aux_coord_anl char(06)
         ,l_coord_tec     decimal(6,0)
         ,l_coord_anl     decimal(6,0)

   if g_cte01m04 is null or
      g_cte01m04 <> true then
      call cte01m04_prepare()
   end if

   open  ccte01m04010
   whenever error continue
   fetch ccte01m04010
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         error 'Hostname nao encontrado' sleep 2
      else
         error 'Erro SELECT ccte01m04010 ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
         error 'cte01m04_acao()' sleep 2
      end if
      return 1
   end if

   initialize l_pop.*        to null
   initialize l_dackaca.*    to null
   let l_pop.sql = "select coracacod, coracades "
                  ,"from dackaca                "
                  ,"where corasscod =           ", l_acao.corasscod
                  ,"order by 2                  "

   call ofgrc001_popup(08,10,'Popup de Codigo de Acao'
                      ,'Codigo','Descricao','A',l_pop.sql,'','X')
        returning l_pop.result
                 ,l_dackaca.coracacod
                 ,l_dackaca.coracades

   if l_pop.result <> 0 then
      return 1
   end if

   let m_desc_acao  = 'S'
   let m_ret_insere = null
   call cte01m04_insere (l_acao.*
                        ,l_dackaca.coracades
                        ,l_data
                        ,l_hora)
        returning m_ret_insere

   if m_ret_insere <> 0 then
      return 1
   end if

   initialize l_dacrligpac.* to null
   open  ccte01m04001 using l_acao.corlignum
                           ,l_acao.corligano
                           ,l_acao.corligitmseq
   whenever error continue
   fetch ccte01m04001 into  l_dacrligpac.fcapacorg
                           ,l_dacrligpac.fcapacnum
   whenever error stop

   if sqlca.sqlcode   <> 0 then
     if sqlca.sqlcode <  0 then
        error "Nao foi possivel acessar a ligacao PAC, "
             ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
        sleep(2)
        close ccte01m04001
        return 1
     end if
     error "Ligacao PAC nao localizado, "
          ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
     sleep(2)
     close ccte01m04001
     return 1
   end if
   close ccte01m04001

   initialize l_mfimpar.*    to null
   open  ccte01m04002 using l_dacrligpac.fcapacorg
                           ,l_dacrligpac.fcapacnum
                           ,l_dacrligpac.fcapacorg
                           ,l_dacrligpac.fcapacnum
   whenever error continue
   fetch ccte01m04002 into  l_mfimpar.funmat
   whenever error stop

   if sqlca.sqlcode   <> 0 then
     if sqlca.sqlcode <  0 then
        error "Nao foi possivel acessar a matricula do functionario, "
             ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
        sleep(2)
        close ccte01m04002
        return 1
     end if
     error "Matricula do functionario nao localizada, "
          ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
     sleep(2)
     close ccte01m04002
     return 1
   end if
   close ccte01m04002

   let l_conv_cod  = l_acao.corasscod
   initialize l_datkgeral.* to null
   open  ccte01m04003 using l_conv_cod
   whenever error continue
   fetch ccte01m04003 into  l_datkgeral.grlinf
   whenever error stop

   if sqlca.sqlcode   <> 0 then
     if sqlca.sqlcode <  0 then
        error "Nao foi possivel acessar a matricula do coordenador, "
             ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
        sleep(2)
        close ccte01m04003
        return 1
     end if
     error "Matricula do coordenador nao localizada, "
          ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
     sleep(2)
     close ccte01m04003
     return 1
   end if
   close ccte01m04003

   initialize m_ret_fgrhc001.* to null
   if l_mfimpar.funmat is not null then
      call fgrhc001_mailgicod (g_issk.usrtip
                              ,g_issk.empcod
                              ,l_mfimpar.funmat)
           returning m_ret_fgrhc001.result
                    ,m_ret_fgrhc001.mailgicod
                    ,m_ret_fgrhc001.endfunc
   end if

   let l_aux_coord_tec = l_datkgeral.grlinf[01,06]
   if l_aux_coord_tec <> '000000' then
      let l_coord_tec  = l_aux_coord_tec
      call fgrhc001_mailgicod (g_issk.usrtip
                              ,g_issk.empcod
                              ,l_coord_tec)
           returning m_ret_fgrhc001.result
                    ,m_ret_fgrhc001.mailgicod
                    ,m_ret_fgrhc001.endchefe1
   end if

   let l_aux_coord_anl = l_datkgeral.grlinf[07,12]
   if l_aux_coord_anl <> '000000' then
      let l_coord_anl  = l_aux_coord_anl
      call fgrhc001_mailgicod (g_issk.usrtip
                              ,g_issk.empcod
                              ,l_coord_anl)
           returning m_ret_fgrhc001.result
                    ,m_ret_fgrhc001.mailgicod
                    ,m_ret_fgrhc001.endchefe2
   end if

   initialize l_mfimpfs.* to null
   open  ccte01m04004 using l_dacrligpac.fcapacorg
                           ,l_dacrligpac.fcapacnum
   whenever error continue
   fetch ccte01m04004 into  l_mfimpfs.pfsnom
   whenever error stop

   if sqlca.sqlcode   <> 0 then
     if sqlca.sqlcode <  0 then
        error "Nao foi possivel acessar o pretendente, "
             ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
        sleep(2)
        close ccte01m04004
        return 1
     else
        #--
        #-- CT 172871
        if l_mfimpfs.pfsnom = ""
        or l_mfimpfs.pfsnom is null then
           open  ccte01m04011 using l_dacrligpac.fcapacorg
                                   ,l_dacrligpac.fcapacnum
           whenever error continue
           fetch ccte01m04011 into  l_mfimanalise.cgccpfnum
                                   ,l_mfimanalise.cgcord
           whenever error stop

           if sqlca.sqlcode   <> 0 then
             if sqlca.sqlcode <  0 then
                error "Nao foi possivel acessar o CPF/CNPJ, "
                     ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
                sleep(2)
                close ccte01m04011
                return 1
             end if
             error "CPF/CNPJ nao localizado, "
                  ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
             sleep(2)
             close ccte01m04011
             return 1
           end if
           close ccte01m04011

           open  ccte01m04012 using l_mfimanalise.cgccpfnum
                                   ,l_mfimanalise.cgcord
           whenever error continue
           fetch ccte01m04012 into  l_gsakseg.segnom
           whenever error stop

           if sqlca.sqlcode   <> 0 then
             if sqlca.sqlcode <  0 then
                error "Nao foi possivel acessar o Nome do Segurado, "
                     ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
                sleep(2)
                close ccte01m04012
                return 1
             end if
             error "Pretendente nao localizado, "
                  ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
             sleep(2)
             close ccte01m04012
             return 1
           end if
           close ccte01m04012
        end if
        #--
     end if
   end if

   close ccte01m04004

   initialize l_dacrligsus.* to null
   open  ccte01m04005 using l_acao.corlignum
                           ,l_acao.corligano
   whenever error continue
   fetch ccte01m04005 into  l_dacrligsus.corsus
   whenever error stop

   if sqlca.sqlcode   <> 0 then
     if sqlca.sqlcode <  0 then
        error "Nao foi possivel acessar o corretor, (corsus) "
             ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
        sleep(2)
        close ccte01m04005
        return 1
     end if
     error "Corretor (corsus) nao localizado "
          ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
     sleep(2)
     close ccte01m04005
     return 1
   end if
   close ccte01m04005

   initialize l_gcaksusep.* to null
   open  ccte01m04006 using l_dacrligsus.corsus
   whenever error continue
   fetch ccte01m04006 into  l_gcaksusep.corsuspcp
   whenever error stop

   if sqlca.sqlcode   <> 0 then
     if sqlca.sqlcode <  0 then
        error "Nao foi possivel acessar o corretor, (corsuspcp) "
             ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
        sleep(2)
        close ccte01m04006
        return 1
     end if
     error "Corretor (corsuspcp) nao localizado, "
          ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
     sleep(2)
     close ccte01m04006
     return 1
   end if
   close ccte01m04006

   initialize l_gcakcorr.* to null
   open  ccte01m04007 using l_gcaksusep.corsuspcp
   whenever error continue
   fetch ccte01m04007 into  l_gcakcorr.cornom
   whenever error stop

   if sqlca.sqlcode   <> 0 then
     if sqlca.sqlcode <  0 then
        error "Nao foi possivel acessar o nome corretor, "
             ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
        sleep(2)
        close ccte01m04007
        return 1
     end if
     error "Nome corretor nao localizado, "
          ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
     sleep(2)
     close ccte01m04007
     return 1
   end if
   close ccte01m04007

   let l_dt_corrente = null
   let l_aux_hora    = null
   let l_hora_for    = null
   let l_h_corrente  = null

   let l_dt_corrente = today
   let l_aux_hora    = current
   let l_hora_for    = l_aux_hora
   let l_h_corrente  = l_hora_for[01,05]

   initialize l_dacmlig.* to null
   open  ccte01m04008 using l_acao.corlignum
                           ,l_acao.corligano
   whenever error continue
   fetch ccte01m04008 into  l_dacmlig.c24solnom
   whenever error stop

   if sqlca.sqlcode   <> 0 then
     if sqlca.sqlcode <  0 then
        error "Nao foi possivel acessar o nome solicitante, "
             ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
        sleep(2)
        close ccte01m04008
        return 1
     end if
     error "Nome solicitante nao localizado, "
          ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
     sleep(2)
     close ccte01m04008
     return 1
   end if
   close ccte01m04008

   let m_file = "PAC"
               ,l_dacrligpac.fcapacorg using '&&'
               ,"-"
               ,l_dacrligpac.fcapacnum using '&&&&&&&&'

   start report cte01m04_report to m_file

   output to report cte01m04_report(l_acao.corasscod
                                   ,l_corassdes
                                   ,l_mfimpfs.pfsnom
                                   ,l_dacrligsus.corsus
                                   ,l_gcakcorr.cornom
                                   ,l_dacrligpac.fcapacorg
                                   ,l_dacrligpac.fcapacnum
                                   ,l_dackaca.coracades
                                   ,l_dt_corrente
                                   ,l_h_corrente
                                   ,l_acao.corlignum
                                   ,l_acao.corligano
                                   ,l_acao.corligitmseq
                                   ,l_dacmlig.c24solnom)

   finish report cte01m04_report

   call cte01m04_envia_mail(l_dacrligpac.fcapacorg
                           ,l_dacrligpac.fcapacnum)

   let m_cmd = "rm ", m_file
   run m_cmd

   if m_ret = 0 then
      error "E-mail enviado."
      sleep(2)
      return 0
   else
      error "Erro ",m_ret ," no envio do e-mail."
      sleep(2)
      return 1
   end if

end function

#-----------------------------------------------------
function cte01m04_envia_mail(l_fcapacorg, l_fcapacnum)
#-----------------------------------------------------

   define l_fcapacorg      like dacrligpac.fcapacorg
         ,l_fcapacnum      like dacrligpac.fcapacnum
         ,l_copia          char(01)

   define l_mensagem       record
          sistema          char(10)
         ,de               char(100)
         ,para             char(300)
         ,cc               char(300)
         ,bcc              char(300)
         ,subject          char(50)
         ,msg              char(300)
   end record

   define  l_mail             record
      de                 char(500)   # De
     ,para               char(5000)  # Para
     ,cc                 char(500)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
   end  record
   define l_coderro  smallint
   define msg_erro char(500)
   #let l_mensagem.de       = "Coordenacao_Teleatendimento/spaulo_ct24hs_teleatendimento@porto-seguro.com.br"
   let l_mensagem.subject  = "PAC "
                            ,l_fcapacorg using '&&'
                            ,"-"
                            ,l_fcapacnum using '&&&&&&&&'
                            ," Complemento de Informação"

   let l_mensagem.cc       = null
   let l_copia             = 'N'
   if m_ret_fgrhc001.endchefe1 is not null and
      m_ret_fgrhc001.endchefe2 is not null then
      let l_mensagem.cc    = m_ret_fgrhc001.endchefe1 clipped, ","
                            ,m_ret_fgrhc001.endchefe2
      let l_copia          = 'S'
   else
      if m_ret_fgrhc001.endchefe1 is null then
         let l_mensagem.cc = m_ret_fgrhc001.endchefe2
         let l_copia       = 'S'
      else
         let l_mensagem.cc = m_ret_fgrhc001.endchefe1
         let l_copia       = 'S'
      end if
   end if

   if l_mensagem.cc is not null then
      let l_mensagem.cc = l_mensagem.cc clipped, ",",  l_mensagem.de
   else
      let l_mensagem.cc = l_mensagem.de
   end if

 #PSI-2013-23297 - Inicio
   let l_mail.de = l_mensagem.de
   #let l_mail.para = "kleiton.nascimento@correioporto"
   let l_mail.para = m_ret_fgrhc001.endfunc
   let l_mail.cco = ""
   let l_mail.assunto = l_mensagem.subject
   let l_mail.mensagem = ""
   let l_mail.id_remetente = "CT24HS"
   let l_mail.tipo = "text"
   let m_cmd    = null
   if l_copia   = 'S' then
      let l_mail.cc = l_mensagem.cc
   end if

   #display "Arquivo: ",m_file
   #call figrc009_attach_file(m_file)
   #display "Arquivo anexado com sucesso"
   #call figrc009_mail_send1 (l_mail.*)
   #   returning l_coderro,msg_erro

end function

#------------------------------
report cte01m04_report(l_reg)
#------------------------------

   define l_reg         record
          assunto       like dacmligass.corasscod
         ,desc_assunto  like dackass.corassdes
         ,pretendente   like mfimpfs.pfsnom
         ,corretor      like dacrligsus.corsus
         ,nom_cor       like gcakcorr.cornom
         ,org_pac       like dacrligpac.fcapacorg
         ,num_pac       like dacrligpac.fcapacnum
         ,desc_acao     like dackaca.coracades
         ,dt_corrente   date
         ,h_corrente    char(05)
         ,num_lig       like dacmligasshst.corlignum
         ,ano_lig       like dacmligasshst.corligano
         ,itmseq_lig    like dacmligasshst.corligitmseq
         ,nom_sol       like dacmlig.c24solnom
   end record

   define l_historico   like dacmligasshst.c24ligdsc

   output

         left   margin 0
         bottom margin 0
         top    margin 0
         page   length 10

   format

   on every row

        print column 001, "Assunto.......: ", l_reg.assunto using '&&&'
                        , " - "
                        , l_reg.desc_assunto

        print column 001, "Pretendente...: ", l_reg.pretendente

        print column 001, "Corretor......: ", l_reg.corretor clipped
                        , " - "
                        , l_reg.nom_cor

        print column 001, "Nr. do Pac....: ", l_reg.org_pac using '&&'
                        , "/"
                        , l_reg.num_pac using '&&&&&&&&'

        print column 001, "Ação..........: ", l_reg.desc_acao

        print column 001, "Data/Hora.....: ", l_reg.dt_corrente
                        , " "
                        , l_reg.h_corrente

        print column 001, "Atendente.....: ", g_issk.funmat using '&&&&&&'
                        , " - "
                        , g_issk.funnom

        print column 001, "Histórico.....: Lig.: "
                        , l_reg.num_lig using '&&&&&&&&&&'
                        , "  "
                        , "Sol.: ", l_reg.nom_sol

        open    ccte01m04009 using l_reg.num_lig
                                  ,l_reg.ano_lig
                                  ,l_reg.itmseq_lig
        foreach ccte01m04009 into  l_historico

           if l_historico = " " then
              continue foreach
           end if

           print column 023, l_historico

        end foreach

end report
