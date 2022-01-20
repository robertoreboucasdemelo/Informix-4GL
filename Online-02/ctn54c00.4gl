#############################################################################
# Nome do Modulo: ctn54c00                                             Raji #
# Consultas ao sistema de atendimento ao prestador                 NOV/2008 #
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# --------   ------------- ------    ---------------------------------------#
# 08/08/2006 Andrei, Meta  AS112372  Migracao de versao do 4GL              #
#---------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glcte.4gl"

#----------------------------------------------------------------------------
function ctn54c00()
#----------------------------------------------------------------------------

   define d_ctn54c00      record
          datini          date                       ,
          datfim          date
   end record

   define a_ctn54c00      array[1000] of record
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
          cvncptagnnum    like akckagn.cvncptagnnum     ,
          ligdctnum       like datrligsemapl.ligdctnum  ,
          dctitm          like datrligsemapl.dctitm     ,
          astdes          char(25)                      ,
          pstdes          char(25)                      ,
          qrades          char(10)                      ,
          nomgrr          like dpaksocor.nomgrr
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

   open window win_ctn54c00 at 03,02 with form "ctn54c00"
        attribute (form line first)


      clear form
      message " <F17> Abandona "

    #---------------------------------------------------------------------------
    # Inicializacao de variaveis
    #---------------------------------------------------------------------------
      initialize d_ctn54c00,
                 a_ctn54c00,
                 ws          to null

    #---------------------------------------------------------------------------
    # Input dos parametros
    #---------------------------------------------------------------------------
      let  int_flag = true
      input by name d_ctn54c00.* without defaults

         before field datini
            display by name d_ctn54c00.datini attribute(reverse)

         after  field datini
            display by name d_ctn54c00.datini

            if  d_ctn54c00.datini is null  then
               #error " Informe a data inicial do periodo de consulta !"
                error " Informe a data para consulta !"
                next field datini
            end if

            if  d_ctn54c00.datini > today  then
                error " Data maior que a data de hoje !"
                next field datini
            end if

        before field datfim
           display by name d_ctn54c00.datfim attribute(reverse)

        after  field datfim
           display by name d_ctn54c00.datfim

           if  fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field datini
           end if

           if  d_ctn54c00.datfim is null  then
               error " Informe a data final do periodo de consulta !"
               next field datfim
           end if

           if  d_ctn54c00.datfim < d_ctn54c00.datini  then
               error " Data final menor que data inicial !"
               next field datini
           end if

           let ws.dias = d_ctn54c00.datfim - d_ctn54c00.datini
           if  ws.dias > 5  then
               error " Periodo superior a 5 dias !"
               next field datini
           end if


         on key(interrupt)
            let  int_flag = false
            exit input

      end input

   if int_flag = false then
      close window win_ctn54c00
      set isolation to committed read
      return
   end if

      error " Aguarde, executando a consulta ... "

      declare c_datmligacao cursor for
      select datkassunto.c24astcod,
             datkassunto.c24astdes,
             datrligsemapl.ligdctnum,
             datrligsemapl.dctitm,
             count(*)
        from datkassunto, datrligsemapl, datmligacao
       where datkassunto.c24astagp = "CO"
         and datrligsemapl.lignum = datmligacao.lignum
         and datmligacao.c24astcod = datkassunto.c24astcod
         and ligdat >= d_ctn54c00.datini
         and ligdat <= d_ctn54c00.datfim
      group by 1,2,3,4
      order by 1,3,4


      #-----------------------------------------------------------------------
      # Monta exibicao
      #-----------------------------------------------------------------------
      let a_ctn54c00[1].texto = "PERIODO.: ", d_ctn54c00.datini,
                                     " ATE ", d_ctn54c00.datfim

      if  d_ctn54c00.datfim = today  then
          let ws.hora = time
          let a_ctn54c00[1].texto = a_ctn54c00[1].texto clipped,
                                    " ( ", ws.hora, " )"
      end if

      let w_arr = 3

      let ws.astdes = "Assunto"
      let ws.pstdes = "Prestador"
      let ws.qrades = "QRA"
      let a_ctn54c00[w_arr].texto = ws.astdes, "  ",
                                    ws.pstdes, "  ",
                                    ws.qrades, "  ",
                                    "Quantidade"
      let w_arr = w_arr + 1


      let ws.sumger = 0

      foreach c_datmligacao into ws.c24astcod,
                                 ws.c24astdes,
                                 ws.ligdctnum,
                                 ws.dctitm,
                                 ws.qtde

          if ws.agpant <> ws.c24astcod and ws.sumger > 0 then
             let ws.astdes = ""
             let ws.pstdes = ""
             let ws.qrades = ""
             let a_ctn54c00[w_arr].texto = ws.astdes, "  ",
                                           ws.pstdes, "  ",
                                           ws.qrades, "  ",
                                           "------------"

             let w_arr = w_arr + 1
             let a_ctn54c00[w_arr].texto = ws.astdes, "  ",
                                           ws.pstdes, "  ",
                                           ws.qrades, "  ",
                                           ws.sumger using "#####&"
             let w_arr = w_arr + 2

             let ws.astdes = "Assunto"
             let ws.pstdes = "Prestador"
             let ws.qrades = "QRA"
             let a_ctn54c00[w_arr].texto = ws.astdes, "  ",
                                           ws.pstdes, "  ",
                                           ws.qrades, "  ",
                                           "Quantidade"
             let w_arr = w_arr + 1

             let ws.sumger = 0
          end if

          let ws.sumger = ws.sumger + ws.qtde

          let ws.nomgrr = ""
          select nomgrr into ws.nomgrr
            from dpaksocor
           where pstcoddig = ws.ligdctnum

          let ws.astdes = ws.c24astcod, "-", ws.c24astdes
          let ws.pstdes = ws.ligdctnum using "&&&&&", "-", ws.nomgrr
          let ws.qrades = ws.dctitm

          let a_ctn54c00[w_arr].texto = ws.astdes, "  ",
                                        ws.pstdes, "  ",
                                        ws.qrades, "  ",
                                        ws.qtde using "#####&"
          let w_arr = w_arr + 1
          let ws.agpant = ws.c24astcod

      end foreach

      if ws.sumger > 0 then
         let ws.astdes = ""
         let ws.pstdes = ""
         let ws.qrades = ""
         let a_ctn54c00[w_arr].texto = ws.astdes, "  ",
                                       ws.pstdes, "  ",
                                       ws.qrades, "  ",
                                       "------------"

         let w_arr = w_arr + 1
         let a_ctn54c00[w_arr].texto = ws.astdes, "  ",
                                       ws.pstdes, "  ",
                                       ws.qrades, "  ",
                                       ws.sumger using "#####&"
      end if
      error ""

    #---------------------------------------------------------------------------
    # Exibe array montado
    #---------------------------------------------------------------------------
      message " <F8> Imprime  <F17> Abandona "

      call set_count( w_arr )
      display array a_ctn54c00 to s_ctn54c00.*
         on key (f8)
            initialize imp to null
            let imp.dptsgl    = g_issk.dptsgl
            call fun_print_seleciona(imp.dptsgl, imp.sequencia)
                 returning imp.resposta, imp.impnom

            if  imp.resposta = true  then
                error " Aguarde, gerando impressao ... "
                let ws.lrpipe = "lp -sd ", imp.impnom clipped
                start report rep_ctn54c00 to pipe ws.lrpipe
                   for w_ind = 1 to w_arr
                       output to report rep_ctn54c00( a_ctn54c00[w_ind].texto )
                   end for
                finish report rep_ctn54c00
                error ""
            else
                error "Impressao cancelada !"
            end if
         on key (interrupt)
            let  int_flag = false
            exit display
      end display


   let int_flag = false

   close window win_ctn54c00

   set isolation to committed read

end function


#-------------------------------------------------------------------------------
 report rep_ctn54c00( w_texto )
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
               column 73, "CTN54C00"
         print column 01, "----------------------------------------",
                          "----------------------------------------"

      on every row
         print column 01, w_texto

      on last row
         print column 00, ascii(12)

end report
