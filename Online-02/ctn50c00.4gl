#############################################################################
# Nome do Modulo: CTN50C00                                             Raji #
# Consultas ao sistema de atendimento ao segurado                  Out/2001 #
#############################################################################
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 08/08/2006 Andrei, Meta  AS112372  Migracao de versao do 4GL               #
# 13/12/2012 Celso Issamu            ajuste na query do cursor c_ctn50c00_lig#
#----------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glcte.4gl"

#-------------------------------------------------------------------------------
function ctn50c00()
#-------------------------------------------------------------------------------

   define d_ctn50c00      record
          datini          date                       ,
          datfim          date                       ,
          selagpnom       char(01)                   ,
          c24astagp       like datkastagp.c24astagp  ,
          selassnom       char(01)                   ,
          c24astcod       like datkassunto.c24astcod
   end record

   define a_ctn50c00      array[5000] of record
          texto           char(76)
   end record

   define ws              record
          comando         char(600)                     ,
          c24astcod       like datkassunto.c24astcod    ,
          c24astdes       like datkassunto.c24astdes    ,
          c24astagp       like datkastagp.c24astagp     ,
          c24astagpdes    like datkastagp.c24astagpdes  ,
          agpant          like datkastagp.c24astagp     ,
          qtde            integer                       ,
          sumagp          integer                       ,
          sumger          integer                       ,
          perc            decimal(5,2)                  ,


          sumtot          integer                       ,
          perctot         decimal(5,2)                  ,
          dias            interval day(3) to day        ,
          hora            char(08)                      ,
          lrpipe          char(200)                     ,
          cvnnum          like apamcapa.cvnnum          ,
          cvncptagnnum    like akckagn.cvncptagnnum
   end record

   define a_asum            array[500] of integer

   define imp           record
          resposta      integer              ,
          impnom        char(08)             ,
          sequencia     like ismkimpr.impseq ,
          dptsgl        like isskfunc.dptsgl
   end record

   define w_ind           smallint
   define w_ind2          smallint
   define w_arr           smallint

   initialize ws to null
   initialize a_asum to null
   let w_ind = null
   let w_ind2 = null
   let w_arr = null

   set isolation to dirty read

   open window win_ctn50c00 at 03,02 with form "ctn50c00"
        attribute (form line first)


      clear form
      message " <F17> Abandona "

    #---------------------------------------------------------------------------
    # Inicializacao de variaveis
    #---------------------------------------------------------------------------
      initialize d_ctn50c00,
                 a_ctn50c00,
                 ws          to null

    #---------------------------------------------------------------------------
    # Input dos parametros
    #---------------------------------------------------------------------------
      let  int_flag = true
      input by name d_ctn50c00.* without defaults

         before field datini
            display by name d_ctn50c00.datini attribute(reverse)

         after  field datini
            display by name d_ctn50c00.datini

            if  d_ctn50c00.datini is null  then
               #error " Informe a data inicial do periodo de consulta !"
                error " Informe a data para consulta !"
                next field datini
            end if

            if  d_ctn50c00.datini > today  then
                error " Data maior que a data de hoje !"
                next field datini
            end if

        before field datfim
           display by name d_ctn50c00.datfim attribute(reverse)

        after  field datfim
           display by name d_ctn50c00.datfim

           if  fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field datini
           end if

           if  d_ctn50c00.datfim is null  then
               error " Informe a data final do periodo de consulta !"
               next field datfim
           end if

           if  d_ctn50c00.datfim < d_ctn50c00.datini  then
               error " Data final menor que data inicial !"
               next field datini
           end if

           let ws.dias = d_ctn50c00.datfim - d_ctn50c00.datini
           if  ws.dias > 5  then
               error " Periodo superior a 5 dias !"
               next field datini
           end if

         before field selagpnom
            display by name d_ctn50c00.selagpnom attribute(reverse)

         after  field selagpnom
            display by name d_ctn50c00.selagpnom

            if  d_ctn50c00.selagpnom is not null  then
                if  d_ctn50c00.selagpnom <> "X" then
                    error "Marque com X a opcao desejada ou deixe em branco !"
                    next field selagpnom
                else
                    let d_ctn50c00.selassnom = "X"
                    display by name d_ctn50c00.selassnom
                end if
            end if

         before field c24astagp
            display by name d_ctn50c00.c24astagp attribute(reverse)

         after  field c24astagp
            display by name d_ctn50c00.c24astagp

            if  fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                next field selagpnom
            end if

            if  d_ctn50c00.c24astagp is not null       then

                select * from datkastagp
                 where c24astagp = d_ctn50c00.c24astagp

                if status = notfound then
                   call ctn50c00_agp()
                        returning d_ctn50c00.c24astagp
                end if
            end if
            display by name d_ctn50c00.c24astagp

         before field selassnom
            display by name d_ctn50c00.selassnom attribute(reverse)

         after  field selassnom
            display by name d_ctn50c00.selassnom

            if  fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                next field c24astagp
            end if

            if  d_ctn50c00.selassnom is not null  then
                if  d_ctn50c00.selassnom <> "X"  then
                    error "Marque com X a opcao desejada ou deixe em branco !"
                    next field selassnom
                end if
            end if

            if ( d_ctn50c00.selagpnom = " "    or
                 d_ctn50c00.selagpnom is null    ) and
               ( d_ctn50c00.selassnom = " "    or
                 d_ctn50c00.selassnom is null    ) then
                error " Selecione uma das chaves de ordenacao !"
                next field selassnom
            end if

         before field c24astcod
            display by name d_ctn50c00.c24astcod attribute(reverse)

         after  field c24astcod
            display by name d_ctn50c00.c24astcod

            if  fgl_lastkey() = fgl_keyval("up")    or
                fgl_lastkey() = fgl_keyval("left")  then
                next field selassnom
            end if

            if  d_ctn50c00.c24astcod is not null       then

                select * from datkassunto
                 where c24astcod = d_ctn50c00.c24astcod

                if status = notfound then
                   call ctn50c00_ast(d_ctn50c00.c24astagp)
                        returning d_ctn50c00.c24astcod
                end if
            end if
            display by name d_ctn50c00.c24astcod

         on key(interrupt)
            let  int_flag = false
            exit input

      end input

   if int_flag = false then
      close window win_ctn50c00
      set isolation to committed read
      return
   end if

   #----------------------------------------------------------------------------
   # Preparacao dos comandos SQL
   #----------------------------------------------------------------------------
   let ws.comando = "select count(*) "          ,
                      "from datmligacao "          ,
                     "where ligdat >= '", d_ctn50c00.datini,"' ",
                       "and ligdat <= '", d_ctn50c00.datfim,"' ",
                       "and c24astcod = ? "
                     #  "and atdsrvnum is not null ",
                     #  "and atdsrvano is not null "

   prepare s_ctn50c00_lig  from   ws.comando
   declare c_ctn50c00_lig  cursor with hold for s_ctn50c00_lig

      error " Aguarde, executando a consulta ... "

    #---------------------------------------------------------------------------
    # Gera  tabela temporaria
    #---------------------------------------------------------------------------
      begin work
      create temp table temp_ctn50c00( c24astagp     char(3),
                                       c24astagpdes  char(40),
                                       c24astcod     char(3),
                                       c24astdes     char(40),
                                       qtde    integer ) with no log

      create index  idx1_ctn50c00 on temp_ctn50c00( c24astagp, c24astcod )

      let ws.comando = "insert into temp_ctn50c00 values( ?,?,?,?,? ) "
      prepare i_temp from ws.comando
      commit work


      declare c_datmligacao cursor for
      select datkastagp.c24astagp,
             datkastagp.c24astagpdes,
             datkassunto.c24astcod,
             datkassunto.c24astdes
        from datkastagp, datkassunto
       where datkassunto.c24astagp = datkastagp.c24astagp

      foreach c_datmligacao into ws.c24astagp,
                                 ws.c24astagpdes,
                                 ws.c24astcod,
                                 ws.c24astdes

          if d_ctn50c00.c24astagp is not null then
             if ws.c24astagp <> d_ctn50c00.c24astagp then
                continue foreach
             end if
          end if

          if d_ctn50c00.c24astcod is not null then
             if ws.c24astcod <> d_ctn50c00.c24astcod then
                continue foreach
             end if
          end if

          open  c_ctn50c00_lig using ws.c24astcod
          fetch c_ctn50c00_lig into  ws.qtde
          close c_ctn50c00_lig

          if ws.qtde = 0 then
             select *
               from datkassunto
              where c24astcod = ws.c24astcod
                and c24aststt = "A"
             if status = notfound then
                continue foreach
             end if
          end if

          execute i_temp using ws.c24astagp,
                               ws.c24astagpdes,
                               ws.c24astcod,
                               ws.c24astdes,
                               ws.qtde
      end foreach

      #-----------------------------------------------------------------------
      # Monta exibicao
      #-----------------------------------------------------------------------
      let a_ctn50c00[1].texto = "PERIODO.: ", d_ctn50c00.datini,
                                     " ATE ", d_ctn50c00.datfim

      if  d_ctn50c00.datfim = today  then
          let ws.hora = time
          let a_ctn50c00[1].texto = a_ctn50c00[1].texto clipped,
                                    " ( ", ws.hora, " )"
      end if

      let w_arr = 3

      select sum(qtde) into ws.sumger from temp_ctn50c00
      if d_ctn50c00.selagpnom is null then
         let ws.sumagp = ws.sumger
      end if

      declare c1_temp cursor with hold for
          select c24astagp,
                 c24astagpdes,
                 c24astcod,
                 c24astdes,
                 qtde
            from temp_ctn50c00
          order by 1,3

       let ws.agpant = "www"
       foreach c1_temp into ws.c24astagp,
                            ws.c24astagpdes,
                            ws.c24astcod,
                            ws.c24astdes,
                            ws.qtde
          if ws.agpant <> ws.c24astagp    and
             d_ctn50c00.selagpnom is not null  then
             if ws.agpant <> "www" then
                if ws.sumger = 0 then
                   let ws.perc = 0
                else
                   let ws.perc = ws.sumagp / ws.sumger * 100
                end if
                let a_ctn50c00[w_arr].texto = "                    ",
                                              "TOTAL               ",
                                              " ", ws.sumagp,
                                              " 100.00%   ",
                                              "( ",ws.perc using "##&.&&", "% )"
                let w_arr = w_arr + 2
             end if

             let a_ctn50c00[w_arr].texto = ws.c24astagp[1,1],
                                           " ", ws.c24astagpdes
             let w_arr = w_arr + 1

             # Total por agrupamento
             select sum(qtde) into ws.sumagp
               from temp_ctn50c00
              where c24astagp = ws.c24astagp
          end if

          if ws.sumagp = 0 then
             let ws.perc = 0
          else
             let ws.perc = ws.qtde / ws.sumagp * 100
          end if

          let a_ctn50c00[w_arr].texto = "  ",ws.c24astcod,
                                         "-",ws.c24astdes
                                            ,ws.qtde using "#####&", " "
                                            ,ws.perc using "##&.&&"
          let ws.agpant = ws.c24astagp
          let w_arr = w_arr + 1
       end foreach

       if ws.sumger = 0 then
          let ws.perc = 0
       else
          let ws.perc = ws.sumagp / ws.sumger * 100
       end if
       let a_ctn50c00[w_arr].texto = "                    ",
                                     "TOTAL               ",
                                     " ", ws.sumagp,
                                     " 100.00%   ",
                                     "( ",ws.perc using "##&.&&", "% )"
       let w_arr = w_arr + 2

       if d_ctn50c00.selagpnom is not null  then
          let a_ctn50c00[w_arr].texto = "                    ",
                                        "TOTAL GERAL         ",
                                        "      ", ws.sumger using "#####&",
                                        "           ( 100.00% )"
       end if

      drop table temp_ctn50c00
      error ""

    #---------------------------------------------------------------------------
    # Exibe array montado
    #---------------------------------------------------------------------------
      message " <F8> Imprime  <F17> Abandona "

      call set_count( w_arr )
      display array a_ctn50c00 to s_ctn50c00.*
         on key (f8)
            initialize imp to null
            let imp.dptsgl    = g_issk.dptsgl
            call fun_print_seleciona(imp.dptsgl, imp.sequencia)
                 returning imp.resposta, imp.impnom

            if  imp.resposta = true  then
                error " Aguarde, gerando impressao ... "
                let ws.lrpipe = "lp -sd ", imp.impnom clipped
                start report rep_ctn50c00 to pipe ws.lrpipe
                   for w_ind = 1 to w_arr
                       output to report rep_ctn50c00( a_ctn50c00[w_ind].texto )
                   end for
                finish report rep_ctn50c00
                error ""
            else
                error "Impressao cancelada !"
            end if
         on key (interrupt)
            let  int_flag = false
            exit display
      end display


   let int_flag = false

   close window win_ctn50c00

   set isolation to committed read

end function

#-------------------------------------------------------------------------------
function ctn50c00_agp()
#-------------------------------------------------------------------------------
 define a_ctn50c00 array[100] of record
    funcod      like datkastagp.c24astagp,
    fundes      like datkastagp.c24astagpdes
 end record


 define scr_aux  smallint
 define arr_aux  smallint

 define sql_comando char(300)

   open window ctn50c00a at 09,02 with form "ctn50c00a"
                        attribute(border,form line 1)

   let int_flag = false
   initialize a_ctn50c00    to null

   let sql_comando = "select c24astcod          ",
                     "  from datkassunto        ",
                     " where c24astagp = ?      ",
                     "   and c24aststt = 'A'    "

   prepare sql_select from sql_comando
   declare c_assunto  cursor for sql_select

   declare c_ctn50c00  cursor for
      select c24astagp, c24astagpdes
        from datkastagp
       order by c24astagpdes

   let arr_aux  =  1

   foreach c_ctn50c00 into a_ctn50c00[arr_aux].funcod,
                           a_ctn50c00[arr_aux].fundes

      open  c_assunto using a_ctn50c00[arr_aux].funcod
      fetch c_assunto
      if sqlca.sqlcode = notfound  then
         continue foreach
      end if
      close c_assunto

      if arr_aux  >  100   then
         error " Limite excedido. Tabela de agrupamentos com mais de 100 itens!"
         exit foreach
      end if
      let arr_aux = arr_aux + 1

   end foreach

   call set_count(arr_aux-1)

   display "Agrupamentos" to titulo
   display array a_ctn50c00 to s_ctn50c00a.*

      on key (interrupt, control-c)
         initialize a_ctn50c00   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let scr_aux = scr_line()

         exit display

   end display

   close window ctn50c00a
   let int_flag = false

   return a_ctn50c00[arr_aux].funcod

end function  ###  ctn50c00_agp

#-------------------------------------------------------------------------------
function ctn50c00_ast(param)
#-------------------------------------------------------------------------------
 # Mostra todos os Assuntos
 define param record
    c24astagp       like datkastagp.c24astagp
 end record

 define a_ctn50c00 array[300] of record
    funcod  like datkassunto.c24astcod,
    fundes  like datkassunto.c24astdes
 end record

 define ws         record
    c24aststt  like datkassunto.c24aststt
 end record

 define arr_aux    smallint
 define scr_aux    smallint

 define sql_comando char(300)

 open window ctn50c00_ast at 09,02 with form "ctn50c00a"
                      attribute(border, form line 1)

   let int_flag = false
   initialize  a_ctn50c00    to null
   initialize  ws.*          to null

   if param.c24astagp is not null then
      let sql_comando = "select c24astcod,   ",
                        "       c24astdes,   ",
                        "       c24aststt    ",
                        "  from datkassunto  ",
                        " where c24astagp =  '", param.c24astagp, "'",
                        " order by c24astcod "
   else
      let sql_comando = "select c24astcod,   ",
                        "       c24astdes,   ",
                        "       c24aststt    ",
                        "  from datkassunto  ",
                        " order by c24astcod "
   end if

   prepare sql_selast from sql_comando
   declare c_ctn50c00_ast    cursor for sql_selast

   let arr_aux = 1

   foreach c_ctn50c00_ast into a_ctn50c00[arr_aux].funcod,
                           a_ctn50c00[arr_aux].fundes,
                           ws.c24aststt

      if ws.c24aststt <> "A"  then
         continue foreach
      end if

      if arr_aux  >=  300   then
         error "Limite excedido. Tabela de assuntos com mais de 300 itens!"
         exit foreach
      end if

      let arr_aux = arr_aux + 1

   end foreach

   call set_count(arr_aux-1)

   display "Assuntos" to titulo
   display array a_ctn50c00 to s_ctn50c00a.*

      on key (interrupt,control-c)
         initialize a_ctn50c00   to null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         exit display

   end display

   close window  ctn50c00_ast
   let int_flag = false

   return a_ctn50c00[arr_aux].funcod

end function  ###  ctn50c00_ast


#-------------------------------------------------------------------------------
 report rep_ctn50c00( w_texto )
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
               column 73, "CTNXXMXX"
         print column 01, "----------------------------------------",
                          "----------------------------------------"

      on every row
         print column 01, w_texto

      on last row
         print column 00, ascii(12)

end report
