#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Porto Seguro                                              #
# Modulo.........: ctb85g00                                                  #
# Objetivo.......: Realizar a implementacao e consulta do historico generico #
#                                                                            #
#                                                                            #
# Analista Resp. : Norton Nery Santanna                                      #
# PSI            : 226300                                                    #
#............................................................................#
# Desenvolvimento: Diomar Rockenbach, META                                   #
# Liberacao      : 05/08/2008                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# XX/XX/XXXX XXXXXX, META  XXXXXXXXX XXXXXXXXXX                              #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

   define am_ctb85g00 array[200] of record
                      texto char(70)
                      end record
 define teste char(1)

#--------------------------
function ctb85g00(lr_param)
#--------------------------

   define lr_param record
                   tipo_tab  smallint
                  ,titulo    char(20)
                  ,codigo    char(10)
                  ,coddes    char(40)
                   end record

   define l_titulo  char(72)
         ,l_titulo2 char(54)

   let int_flag = false

   open window w_ctb85g00 at 03,02 with form 'ctb85g00'

   display by name lr_param.codigo
   display by name lr_param.coddes

   initialize am_ctb85g00 to null

   let l_titulo2 = 'Consulta historico do ',lr_param.titulo clipped,' selecionado'
   let l_titulo  = 'Insere um novo item de historico para o ',lr_param.titulo clipped,' selecionado'
   menu 'Historico'
      before menu

      command key ('I') 'Implementa' l_titulo
         call ctb85g00_input_array(lr_param.tipo_tab
                                  ,lr_param.codigo)
         display by name lr_param.codigo
         display by name lr_param.coddes


      command key ('C') 'Consulta' l_titulo2
         call ctb85g00_carrega(lr_param.tipo_tab
                              ,lr_param.codigo)
         display by name lr_param.codigo
         display by name lr_param.coddes

      command key ('E') 'Encerra' 'Encerra o programa'
         exit menu
   end menu

   close window w_ctb85g00
   let int_flag = false

end function

#--------------------------------------
function ctb85g00_input_array(lr_param)
#--------------------------------------

   define lr_param record
          tipo_tab  smallint
         ,codigo    char(10)
   end record

   define l_arr          smallint
         ,l_tela         smallint

   define l_data  date
         ,l_hora2 datetime hour to minute
         ,l_stt   smallint

   define lr_retorno     record
          erro           smallint
         ,mensagem       char(60)
         ,funnom         like isskfunc.funnom
   end record

   let l_data  = null
   let l_hora2 = null
   let l_stt   = null
   let l_arr   = 0

   initialize lr_retorno  to null

   call cts40g03_data_hora_banco(2)
      returning l_data
               ,l_hora2

   call cty08g00_nome_func(g_issk.empcod
                          ,g_issk.funmat
                          ,g_issk.usrtip)
      returning lr_retorno.erro
               ,lr_retorno.mensagem
               ,lr_retorno.funnom


   while true
      call set_count(l_arr)

      input array am_ctb85g00 without defaults from s_ctb85g00.*

         before row

            let l_tela = scr_line()
            let l_arr  = arr_curr()

         before field texto
            display am_ctb85g00[l_arr].texto  to s_ctb85g00[l_tela].texto attribute (reverse)
         after field texto
            display am_ctb85g00[l_arr].texto  to s_ctb85g00[l_tela].texto

            if fgl_lastkey() = fgl_keyval("left") or
               fgl_lastkey() = fgl_keyval("up")   then
               error " Alteracoes e/ou correcoes nao sao permitidas!" sleep 2
               next field texto
            end if

            if am_ctb85g00[l_arr].texto is null or
               am_ctb85g00[l_arr].texto =  " "  then
               error "Informe o Complemento" sleep 2
               next field texto
            end if

         after row

            begin work
            let l_stt = ctb85g00_grava_hist(lr_param.tipo_tab
                                           ,lr_param.codigo
                                           ,l_data
                                           ,l_arr
                                           ,l_tela)
            if l_stt <> 0 then
               rollback work
               exit input
            end if
            commit work

         on key(f17,control-c,interrupt)
            let int_flag = false
            clear form
            exit input

      end input

      exit while

   end while

end function

#----------------------------------
function ctb85g00_carrega(lr_param)
#----------------------------------

   define lr_param record
          tipo_tab  smallint
         ,codigo    char(10)
   end record

   define lr_retorno record
          stt       smallint
         ,srrcoddig like  datmsrrhst.srrcoddig
         ,srrhstseq like  datmsrrhst.srrhstseq
         ,srrhsttxt like  datmsrrhst.srrhsttxt
         ,caddat    like  datmsrrhst.caddat
         ,cademp    like  datmsrrhst.cademp
         ,cadmat    like  datmsrrhst.cadmat
         ,cadusrtip like  datmsrrhst.cadusrtip
   end record

   define lr_retorno2 record
          stt      smallint
         ,mensagem char(60)
         ,funnom   like isskfunc.funnom
   end record

   define l_cont         smallint
         ,l_aux_linha    smallint
         ,l_data_antes   like datmsrrhst.caddat
         ,l_cadmat_antes like datmsrrhst.cadmat
         ,teste   char(1)

   let l_cont         = 1
   let l_aux_linha    = 1
   let l_data_antes   = null
   let l_cadmat_antes = null

   initialize am_ctb85g00 to null
   initialize lr_retorno  to null
   initialize lr_retorno2 to null

   while true

      call ctb85g01_consult_hist(lr_param.tipo_tab
                                ,lr_param.codigo
                                ,l_cont)
         returning lr_retorno.stt
                  ,lr_retorno.srrcoddig
                  ,lr_retorno.srrhstseq
                  ,lr_retorno.srrhsttxt
                  ,lr_retorno.caddat
                  ,lr_retorno.cademp
                  ,lr_retorno.cadmat
                  ,lr_retorno.cadusrtip


      if lr_retorno.stt <> 0 then
         exit while
      end if

      call cty08g00_nome_func(lr_retorno.cademp
                             ,lr_retorno.cadmat
                             ,lr_retorno.cadusrtip)
         returning lr_retorno2.stt
                  ,lr_retorno2.mensagem
                  ,lr_retorno2.funnom

      if l_data_antes is null                 or
         l_data_antes   <> lr_retorno.caddat or
         l_cadmat_antes <> lr_retorno.cadmat then

         if l_data_antes is not null then
            let am_ctb85g00[l_aux_linha].texto = null

            let l_aux_linha = l_aux_linha + 1
            if l_aux_linha > 200 then
               error 'Numero de registros excedeu o limite' sleep 2
               exit while
            end if
         end if

         let am_ctb85g00[l_aux_linha].texto = "Em: "  , lr_retorno.caddat
                                             ," Por: ", lr_retorno2.funnom
         let l_aux_linha = l_aux_linha + 1
         if l_aux_linha > 200 then
            error 'Numero de registros excedeu o limite' sleep 2
            exit while
         end if
      end if

      let am_ctb85g00[l_aux_linha].texto = lr_retorno.srrhsttxt
      let l_aux_linha = l_aux_linha + 1
      if l_aux_linha > 200 then
         error 'Numero de registros excedeu o limite' sleep 2
         exit while
      end if

      let l_data_antes   = lr_retorno.caddat
      let l_cadmat_antes = lr_retorno.cadmat

      initialize lr_retorno.* to null

      let l_cont = l_cont + 1

   end while

   let l_aux_linha = l_aux_linha - 1

   if l_aux_linha = 0 then
      error 'Nenhum registro encontrado' sleep 2
   else

      call set_count(l_aux_linha)

      display array am_ctb85g00 to s_ctb85g00.*

         on key(f2,control-c,interrupt)
            let int_flag = false
            clear form
            exit display

      end display
   end if

end function

#--------------------------------------------------
function ctb85g00_grava_hist(lr_param,l_arr,l_tela)
#--------------------------------------------------

   define lr_param record
          tipo_tab smallint
         ,codigo   char(10)
         ,em       date
   end record

   define lr_retorno record
                     stt smallint
                    ,msg char(50)
          end record

   define l_erro     smallint
         ,l_path     char(100)
         ,l_mensagem char(100)
         ,l_arr      smallint
         ,l_tela     smallint
         ,l_stt     smallint

   let l_stt  = 0
   let l_path = null
   let l_mensagem = 'Notificacao de alteracao no cadastro de loja de locadora de veiculos'
   initialize lr_retorno to null

   call ctb85g01_grava_hist(lr_param.tipo_tab
                           ,lr_param.codigo
                           ,am_ctb85g00[l_arr].texto
                           ,lr_param.em
                           ,g_issk.empcod
                           ,g_issk.funmat
                           ,g_issk.usrtip)
      returning lr_retorno.stt
               ,lr_retorno.msg

   error lr_retorno.msg sleep 2

   if lr_retorno.stt = 0 then

      call ctb85g01_mtcorpo_email_html("CTB85G00",
					 lr_param.em,
                                         current hour to minute,
                                         g_issk.empcod,
                                         g_issk.usrtip,
                                         g_issk.funmat,
					 l_mensagem,
                                         am_ctb85g00[l_arr].texto clipped)
                    returning l_erro

      if l_erro <> 0 then
         error 'Erro no envio do e-mail : ',l_erro  sleep 2
      end if

   else
      error 'Erro na gravacao do historico' sleep 2
      initialize am_ctb85g00 to null
      clear form
      let l_stt = 2
   end if

   return l_stt

end function
