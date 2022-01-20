#############################################################################
# Nome do Modulo: CTE00M02                                             Akio #
#                                                                      Ruiz #
#                                                                    Wagner #
# Consultas ao sistema de atendimento ao corretor                  Jul/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# --------   ------------- --------  ---------------------------------------#
# 18/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.             #
#---------------------------------------------------------------------------#

 globals  "/homedsa/projetos/geral/globals/glcte.4gl"

 define   g_cte00m02      char(01)

#-------------------------------------------------------------------------------
 function cte00m02()
#-------------------------------------------------------------------------------

   define d_cte00m02      record
          datini          date                  ,
          datfim          date                  ,
          selcorsus       char(01)              ,
          corsus          like dacrligsus.corsus,
          selagpnom       char(01)              ,
          selassnom       char(01)
   end record

   define a_cte00m02      array[10000] of record
          texto           char(76)
   end record

   define ws              record
          cns             smallint                      ,
          soma            integer                       ,
          sumtot          integer                       ,
          qtde            integer                       ,
          perc            decimal(5,2)                  ,
          perctot         decimal(5,2)                  ,
          dias            interval day(3) to day        ,
          hora            char(08)                      ,
          aux_pipe        char(200)                     ,
          comando         char(600)                     ,
          corlignum       like dacmlig.corlignum        ,
          corligano       like dacmlig.corligano        ,
          corasscod       like dackass.corasscod        ,
          corassdes       like dackass.corassdes        ,
          corassagpcod    like dackassagp.corassagpcod  ,
          corassagpsgl    like dackassagp.corassagpsgl  ,
          corassagpdes    like dackassagp.corassagpdes  ,
          corassagpcodant like dackassagp.corassagpcod  ,
          cvnnum          like apamcapa.cvnnum          ,
          cvncptagnnum    like akckagn.cvncptagnnum
   end record

   define a_asum          array[5000] of integer

   define imp           record
          resposta      integer              ,
          impnom        char(08)             ,
          sequencia     like ismkimpr.impseq ,
          dptsgl        like isskfunc.dptsgl
   end record

   define w_ind           smallint
   define w_ind2          smallint
   define w_arr           smallint

   set isolation to dirty read

   initialize d_cte00m02.* to null
   initialize imp.* to null
   initialize a_cte00m02 to null
   initialize ws.* to null

   initialize a_asum to null

   let w_ind = null
   let w_ind2 = null
   let w_arr = null

 #------------------------------------------------------------------------------
 # Preparacao dos comandos SQL
 #------------------------------------------------------------------------------
   if  g_cte00m02 is null  then
       let g_cte00m02 = "N"

       let ws.comando = "select corsuspcp "          ,
                          "from GCAKSUSEP "          ,
                               "where corsus = ? "

       prepare s_gcaksusep  from   ws.comando
       declare c_gcaksusep  cursor with hold for s_gcaksusep

       let ws.comando = "select corasscod "           ,
                          "from DACMLIGASS "          ,
                               "where corlignum = ?  ",
                                 "and corligano = ?  "

       prepare s_dacmligass from   ws.comando
       declare c_dacmligass cursor with hold for s_dacmligass
   end if



   open window win_cte00m02 at 03,02 with form "cte00m02"
        attribute (form line first)


   while true
      clear form
      message " <F17> Abandona "

      let ws.cns = 0

    #---------------------------------------------------------------------------
    # Input dos parametros
    #---------------------------------------------------------------------------
      input by name d_cte00m02.* without defaults

         before field datini
            display by name d_cte00m02.datini attribute(reverse)

         after  field datini
            display by name d_cte00m02.datini

            if  d_cte00m02.datini is null  then
               #error " Informe a data inicial do periodo de consulta !"
                error " Informe a data para consulta !"
                next field datini
            end if

            if  d_cte00m02.datini > today  then
                error " Data maior que a data de hoje !"
                next field datini
            end if

            if  d_cte00m02.datini < "28/06/2000"  then
                error " Data menor que data da implantacao do sistema !"
                next field datini
            end if

#            let d_cte00m02.datfim = d_cte00m02.datini

        before field datfim
           display by name d_cte00m02.datfim attribute(reverse)

        after  field datfim
           display by name d_cte00m02.datfim

           if  fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field datini
           end if

           if  d_cte00m02.datfim is null  then
               error " Informe a data final do periodo de consulta !"
               next field datfim
           end if

           if  d_cte00m02.datfim < d_cte00m02.datini  then
               error " Data final menor que data inicial !"
               next field datini
           end if

           let ws.dias = d_cte00m02.datfim - d_cte00m02.datini
           if  ws.dias > 5  then
               error " Periodo superior a 5 dias !"
               next field datini
           end if


         before field selcorsus
            display by name d_cte00m02.selcorsus attribute(reverse)

         after  field selcorsus
            display by name d_cte00m02.selcorsus

            if  fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
               #next field datfim
                next field datini
            end if

            if  d_cte00m02.selcorsus is not null  then
                if  d_cte00m02.selcorsus <> "X"  then
                    error "Marque com X a opcao desejada ou deixe em branco !"
                    next field selcorsus
                else
                    let d_cte00m02.selagpnom = "X"
                    let d_cte00m02.selassnom = "X"
                    display by name d_cte00m02.selagpnom
                    display by name d_cte00m02.selassnom
                end if
            else
                initialize d_cte00m02.corsus   ,
                           d_cte00m02.selagpnom,
                           d_cte00m02.selassnom to null
                display by name d_cte00m02.corsus
                display by name d_cte00m02.selagpnom
                display by name d_cte00m02.selassnom
                next field selagpnom
            end if

         before field corsus
            display by name d_cte00m02.corsus attribute(reverse)

         after  field corsus
            display by name d_cte00m02.corsus

            if  fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                next field selcorsus
            end if

            if  d_cte00m02.corsus is null       then
                error " Selecione o corretor desejado ! "
                call aggucora()
                     returning d_cte00m02.corsus,
                               ws.cvnnum        ,
                               ws.cvncptagnnum
                next field corsus
            else
                if  d_cte00m02.corsus <>  "99999J"  then
                    open  c_gcaksusep using d_cte00m02.corsus
                    fetch c_gcaksusep

                      if  sqlca.sqlcode <> 0  then
                       if  sqlca.sqlcode = 100  then
                           error " Susep nao cadastrada!"
                           call aggucora()
                                returning d_cte00m02.corsus,
                                          ws.cvnnum        ,
                                          ws.cvncptagnnum
                       else
                           error " Erro (", sqlca.sqlcode, ") durante ",
                                 "a pesquisa da susep. AVISE A INFORMATICA!"
                       end if
                       next field corsus
                      end if
                    close c_gcaksusep
                end if
            end if

            let ws.cns = 1
            exit input

         before field selagpnom
            display by name d_cte00m02.selagpnom attribute(reverse)

         after  field selagpnom
            display by name d_cte00m02.selagpnom

            if  fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                if  d_cte00m02.selcorsus is null  then
                    next field selcorsus
                else
                    next field corsus
                end if
            end if

            if  d_cte00m02.selagpnom is not null  then
                if  d_cte00m02.selagpnom <> "X" then
                    error "Marque com X a opcao desejada ou deixe em branco !"
                    next field selagpnom
                else
                    let d_cte00m02.selassnom = "X"
                    display by name d_cte00m02.selassnom

                    let ws.cns = 2
                    exit input
                end if
            end if

         before field selassnom
            display by name d_cte00m02.selassnom attribute(reverse)

         after  field selassnom
            display by name d_cte00m02.selassnom

            if  fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                next field selagpnom
            end if

            if  d_cte00m02.selassnom is not null  then
                if  d_cte00m02.selassnom <> "X"  then
                    error "Marque com X a opcao desejada ou deixe em branco !"
                    next field selassnom
                end if
            end if

            if ( d_cte00m02.selcorsus = " "    or
                 d_cte00m02.selcorsus is null    ) and
               ( d_cte00m02.selagpnom = " "    or
                 d_cte00m02.selagpnom is null    ) and
               ( d_cte00m02.selassnom = " "    or
                 d_cte00m02.selassnom is null    ) then
                error " Selecione uma das chaves de ordenacao !"
                next field selcorsus
            end if

            let ws.cns = 3

         on key(interrupt)
            exit input

      end input

      if  int_flag  then
          exit while
      end if

      error " Aguarde, executando a consulta ... "



    #---------------------------------------------------------------------------
    # Gera  tabela temporaria
    #---------------------------------------------------------------------------
      begin work    
      
      create temp table temp_cte00m02( seqnum  smallint,
                                       asscod  smallint,
                                       assdes  char(40),
                                       agpcod  smallint,
                                       agpsgl  char(05),
                                       agpdes  char(40),
                                       qtde    integer ) with no log                                       
      

      create index  idx1_cte00m02 on temp_cte00m02( asscod )
      create index  idx2_cte00m02 on temp_cte00m02( agpcod )
      create index  idx3_cte00m02 on temp_cte00m02( qtde desc, agpsgl, assdes )
      create index  idx4_cte00m02 on temp_cte00m02( seqnum, qtde desc, assdes )

      let ws.comando = "insert into temp_cte00m02 values( 0,?,?,?,?,?,0 ) "
      prepare i_temp from ws.comando

      let ws.comando = "update temp_cte00m02 "   ,
                          "set qtde = qtde + 1 " ,
                              "where asscod = ? "
      prepare u1_temp from ws.comando

      let ws.comando = "update temp_cte00m02 "   ,
                          "set seqnum = ? "      ,
                              "where agpcod = ? "
      prepare u2_temp from ws.comando


      insert into temp_cte00m02
      select 0,
             dackass.corasscod,
             dackass.corassdes,
             dackassagp.corassagpcod,
             dackassagp.corassagpsgl,
             dackassagp.corassagpdes,
             0
        from DACKASS,
             DACKASSAGP
             where dackassagp.corassagpcod = dackass.corassagpcod

      commit work
    
    #---------------------------------------------------------------------------
    # Monta querys de acesso
    #---------------------------------------------------------------------------
      if  ws.cns = 1  then
          let ws.comando = "select dacmlig.corlignum, "                      ,
                                  "dacmlig.corligano "                       ,
                             "from DACMLIG, "                                ,
                                  "DACRLIGSUS "                              ,
                            "where ligdat between ? and ? "                  ,
                              "and dacrligsus.corlignum = dacmlig.corlignum ",
                              "and dacrligsus.corligano = dacmlig.corligano ",
                              "and corsus = ? "
      else
          let ws.comando = "select corlignum, "                  ,
                                  "corligano  "                  ,
                             "from DACMLIG "                     ,
                                  "where ligdat between ? and ? "
      end if
      prepare s_dacmlig from   ws.comando
      declare c_dacmlig cursor with hold for s_dacmlig

      if  ws.cns = 1  then
          open  c_dacmlig using d_cte00m02.datini,
                                d_cte00m02.datfim,
                                d_cte00m02.corsus
      else
          open  c_dacmlig using d_cte00m02.datini,
                                d_cte00m02.datfim
      end if

      begin work
      let w_ind   = 0
      let ws.hora = time

      foreach c_dacmlig into ws.corlignum,
                             ws.corligano
          open    c_dacmligass using ws.corlignum,
                                     ws.corligano
          foreach c_dacmligass into  ws.corasscod

             execute u1_temp using ws.corasscod

          end foreach
      end foreach

      commit work

      select sum(qtde)
        into ws.sumtot
        from temp_cte00m02

      if  ws.sumtot > 0  then
        #-----------------------------------------------------------------------
        # Monta exibicao
        #-----------------------------------------------------------------------
         let a_cte00m02[1].texto = "PERIODO.: ", d_cte00m02.datini,
                                        " ATE ", d_cte00m02.datfim
         # let a_cte00m02[1].texto = "           ",
         #                           "RELACAO DE ATENDIMENTOS AO CORRETOR EM ",
         #                           d_cte00m02.datini

          if  d_cte00m02.datfim = today  then
              let a_cte00m02[1].texto = a_cte00m02[1].texto clipped,
                                        " ( ", ws.hora, " )"
          end if

          if  ws.cns = 1  then
              let a_cte00m02[3].texto = "                       ",
                                        "SUSEP...: ", d_cte00m02.corsus
              let w_arr = 5
          else
              let w_arr = 3
          end if

          if  ws.cns = 3  then
              let ws.comando = "select agpsgl, ",
                                      "assdes, ",
                                      "qtde, "  ,
                                    "100 * qtde / ", ws.sumtot using "<<<<<<<<",
                                " from temp_cte00m02 ",
                                      "where qtde >= 0 "

              prepare s1_temp from ws.comando
              declare c1_temp cursor with hold for s1_temp
              foreach c1_temp into ws.corassagpsgl,
                                   ws.corassdes,
                                   ws.qtde     ,
                                   ws.perc
                 let a_cte00m02[w_arr].texto = "  ", ws.corassagpsgl,
                                                "-", ws.corassdes,
                                               "  ", ws.qtde using "#####&",
                                               "  ", ws.perc using "##&.&&"
                 let w_arr = w_arr + 1
              end foreach

              let w_arr = w_arr + 1
              let a_cte00m02[w_arr].texto = "       "                     ,
                                            " TOTAL               "       ,
                                            "                    "        ,
                                            "  ", ws.sumtot using "#####&",
                                            "  100.00%"
          else
              declare c2_temp cursor with hold for
                select agpcod,
                       agpdes,
                       sum(qtde)
                  from temp_cte00m02
                       group by 1, 2
                       order by 3 desc, 2

              begin work
              let w_ind2 = 0
              foreach c2_temp into w_ind,
                                   ws.corassagpdes,
                                   ws.soma
                  let a_asum[w_ind] = ws.soma
                  let w_ind2 = w_ind2 + 1
                  execute u2_temp using w_ind2,
                                        w_ind
              end foreach
              commit work

              declare c3_temp cursor with hold for
                 select seqnum,
                        agpcod,
                        agpdes,
                        assdes,
                        qtde
                   from temp_cte00m02
                        where seqnum > 0

              let ws.corassagpcodant = 0
              foreach c3_temp into w_ind2         ,
                                   ws.corassagpcod,
                                   ws.corassagpdes,
                                   ws.corassdes   ,
                                   ws.qtde
                  let w_ind = ws.corassagpcod
                  let ws.perc = 100 * ws.qtde / a_asum[w_ind]

                  if  ws.corassagpcod <> ws.corassagpcodant  then
                      if  ws.corassagpcodant <> 0  then
                          let w_ind = ws.corassagpcodant
                          let ws.perctot = 100 * a_asum[w_ind] / ws.sumtot
                          let a_cte00m02[w_arr].texto =
                                "                         "   ,
                                "                      "      ,
                                "  ------  -------"
                          let w_arr = w_arr + 1
                          let a_cte00m02[w_arr].texto =
                                "                         "              ,
                                "  TOTAL               "                 ,
                                "  ", a_asum[w_ind] using "#####&"      ,
                                "  100.00%  "                            ,
                                " (", ws.perctot     using "##&.&&", "%)"
                          let w_arr = w_arr + 1
                      end if

                      let w_arr = w_arr + 1
                      let a_cte00m02[w_arr].texto =
                            ws.corassagpdes[01,25]      ,
                            "  ", ws.corassdes[01,20]   ,
                            "  ", ws.qtde using "#####&",
                            "  ", ws.perc using "##&.&&"
                      let ws.corassagpcodant = ws.corassagpcod
                  else
                      let a_cte00m02[w_arr].texto =
                            "                         " ,
                            "  ", ws.corassdes[01,20]   ,
                            "  ", ws.qtde using "#####&",
                            "  ", ws.perc using "##&.&&"
                  end if
                  let w_arr = w_arr + 1
              end foreach

              let w_ind = ws.corassagpcodant
              let ws.perctot = 100 * a_asum[w_ind] / ws.sumtot
              let a_cte00m02[w_arr].texto =
                    "                         "   ,
                    "                      "      ,
                    "  ------  -------"
              let w_arr = w_arr + 1
              let a_cte00m02[w_arr].texto =
                    "                         "        ,
                    "  TOTAL               "           ,
                    "  ", a_asum[w_ind] using "#####&",
                    "  100.00 % "                      ,
                    " (", ws.perctot     using "##&.&&", "%)"
              let w_arr = w_arr + 2

              let a_cte00m02[w_arr].texto = "TOTAL GERAL              "     ,
                                             "                      "       ,
                                             "  ", ws.sumtot using "#####&" ,
                                             "            (100.00%)"
          end if

      else
          let w_arr = 1
          let a_cte00m02[w_arr].texto =
              "Nao existem informacoes para os parametros informados !"
      end if

      drop table temp_cte00m02
      error ""

    #---------------------------------------------------------------------------
    # Exibe array montado
    #---------------------------------------------------------------------------
      message " <F8> Imprime  <F17> Abandona "

      call set_count( w_arr )
      display array a_cte00m02 to s_cte00m02.*
         on key (f8)
            initialize imp to null
            let imp.dptsgl    = g_issk.dptsgl
            call fun_print_seleciona(imp.dptsgl, imp.sequencia)
                 returning imp.resposta, imp.impnom

            if  imp.resposta = true  then
                error " Aguarde, gerando impressao ... "
                let ws.aux_pipe = "lp -sd ", imp.impnom clipped
                start report rep_cte00m02 to pipe ws.aux_pipe
                   for w_ind = 1 to w_arr
                       output to report rep_cte00m02( a_cte00m02[w_ind].texto )
                   end for
                finish report rep_cte00m02
                error ""
            else
                error "Impressao cancelada !"
            end if

         on key (interrupt)
            let  int_flag = false
            exit display
      end display

   end while

   let int_flag = false

   close window win_cte00m02

   set isolation to committed read

end function


#-------------------------------------------------------------------------------
 report rep_cte00m02( w_texto )
#-------------------------------------------------------------------------------

   define w_texto     char(76)

   output
      left margin 0
      top  margin 0
      bottom margin  00
      page   length  60

   format
      first page header
         print column 13, "PORTO SEGURO COMPANHIA DE SEGUROS GERAIS",
               column 73, "CTE00M02"
         print column 01, "----------------------------------------",
                          "----------------------------------------"

      on every row
         print column 01, w_texto

      on last row
         print column 00, ascii(12)

end report
