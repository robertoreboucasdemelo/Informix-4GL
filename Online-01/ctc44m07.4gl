#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Radar / Porto Socorro                                       #
# Modulo........: ctc44m07                                                    #
# Analista Resp.: Debora Vaz Paez                                             #
# PSI...........: 220710                                                      #
# Objetivo......: Tela para implementacao e consulta                          #
#.............................................................................#
# Desenvolvimento: Thomas Ferrao , META                                       #
# Liberacao......: 28/04/2008                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prep_sql       smallint

#----------------------------------
 function ctc44m07_prepare()
#----------------------------------
   define l_sql char(300)

   let l_sql = 'select srrnom '
              ,'  from datksrr '
              ,' where srrcoddig = ? '

   prepare pctc44m07002 from l_sql
   declare cctc44m07002 cursor for pctc44m07002

   let m_prep_sql = true

end function

#---------------------------------------------------------------
 function ctc44m07(l_srrcoddig)
#---------------------------------------------------------------
   define l_srrcoddig  like datmsrrhst.srrcoddig
         ,l_srrnom     like datksrr.srrnom

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc44m07_prepare()
   end if

   let l_srrnom = null

   open cctc44m07002 using l_srrcoddig

   whenever error continue
   fetch cctc44m07002 into l_srrnom
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         error 'Codigo nao encontrado'  sleep 2
      else
         error 'Erro SELECT cctc44m07002 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
         error 'CTC44M07 / ctc44m07() / ', l_srrcoddig  sleep 2
      end if

      return
   end if

   options
      insert key control-h
     ,delete key control-j

   open window w_ctc44m07 at 04,02 with form "ctc44m07"

   display l_srrcoddig  to srrcoddig
   display l_srrnom     to srrnom

   menu "HISTORICO"
        command key ("I") "Implementa" "Insere um novo item de historico para o prestador selecionado"
           call ctc44m07_implementa(l_srrcoddig)
           display l_srrcoddig  to srrcoddig
           display l_srrnom     to srrnom

        command key ("C") "Consulta" "Consulta historico do prestador selecionado"
           call ctc44m07_consulta(l_srrcoddig)
           display l_srrcoddig  to srrcoddig
           display l_srrnom     to srrnom

        command key ("E") "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window w_ctc44m07
   let int_flag = false

   options
      insert key f1
     ,delete key f2

end function

#--------------------------------------
 function ctc44m07_implementa(l_srrcoddig)
#--------------------------------------
    define l_srrcoddig  like datmsrrhst.srrcoddig

    define lr_ctc44m07_i0 record
         data  date
        ,hora2 datetime hour to minute
    end record

    define al_ctc44m07  array[2000] of record
                        texto          char(70)
                        end record

    define lr_retorno_i record
        erro         smallint
       ,mensagem     char(60)
       ,funnom       like isskfunc.funnom
    end record

    define l_arr_aux    smallint
    define l_scr_aux    smallint
    define l_srrhstseq  smallint
    define l_mensagem   char(70)
    define l_coderro    smallint
    define l_msg        char(100)
          ,l_resp       char(01)

    let l_arr_aux = null
    let l_scr_aux = null
    let l_srrhstseq = null
    let l_mensagem  = null
    let l_resp      = null

    initialize al_ctc44m07  to  null

    call cts40g03_data_hora_banco(2)
      returning lr_ctc44m07_i0.data,
                lr_ctc44m07_i0.hora2

    call cty08g00_nome_func(g_issk.empcod,
                            g_issk.funmat,
                            g_issk.usrtip)

       returning lr_retorno_i.erro,
                 lr_retorno_i.mensagem,
                 lr_retorno_i.funnom

    while true
      input array al_ctc44m07 without defaults from s_ctc44m07.*

         before row
            let l_arr_aux = arr_curr()
            let l_scr_aux = scr_line()

         before field texto
            display al_ctc44m07[l_arr_aux].texto to s_ctc44m07[l_scr_aux].texto attribute (reverse)

         after field texto
            display al_ctc44m07[l_arr_aux].texto to s_ctc44m07[l_scr_aux].texto

            if fgl_lastkey() = fgl_keyval("left") or
               fgl_lastkey() = fgl_keyval("up")   then
               error " Alteracoes e/ou correcoes nao sao permitidas!"
               next field texto
            end if

            if al_ctc44m07[l_arr_aux].texto is null or
               al_ctc44m07[l_arr_aux].texto =  " "  then
               error "Informe o Complemento"
               next field texto
            end if

       after row

            let al_ctc44m07[l_arr_aux].texto = get_fldbuf(texto)

            if al_ctc44m07[l_arr_aux].texto is null  or
               al_ctc44m07[l_arr_aux].texto =  "  "  then
                next field texto
             else

               begin work

               call ctd18g01_grava_hist(l_srrcoddig
                                       ,al_ctc44m07[l_arr_aux].texto
                                       ,lr_ctc44m07_i0.data
                                       ,g_issk.empcod
                                       ,g_issk.funmat
                                       ,g_issk.usrtip)
                  returning l_coderro
                           ,l_msg

               if l_coderro <> 1 then
                  error l_msg  clipped
                  rollback work
                  next field texto
               else
                  commit work
               end if
            end if

       on key(f17,control-c,interrupt)
          exit input

      end input

      if int_flag  then
	 let int_flag = false
         exit while
      end if

    end while

    display '            '  at 19,02
    clear form

end function

#--------------------------------------
 function ctc44m07_consulta(l_srrcoddig)
#--------------------------------------
   define l_srrcoddig  like datmsrrhst.srrcoddig

   define lr_ctc44m07_c0 record
       erro        smallint
      ,mensagem    char(200)
      ,srrcoddig   like  datmsrrhst.srrcoddig
      ,srrhstseq   like  datmsrrhst.srrhstseq
      ,srrhsttxt   like  datmsrrhst.srrhsttxt
      ,caddat      like  datmsrrhst.caddat
      ,cademp      like  datmsrrhst.cademp
      ,cadmat      like  datmsrrhst.cadmat
      ,cadusrtip   like  datmsrrhst.cadusrtip
   end record

   define lr_ctc44m07_c1 record
       erro         smallint
      ,mensagem     char(100)
      ,srrcoddig     like datksrr.srrcoddig
      ,srrnom        like datksrr.srrnom
      ,pestip        like datksrr.pestip
      ,cgccpfnum     like datksrr.cgccpfnum
      ,cgcord        like datksrr.cgcord
      ,cgccpfdig     like datksrr.cgccpfdig
      ,srrtip        like datksrr.srrtip
      ,rdranlultdat  like datksrr.rdranlultdat
      ,rdranlsitcod  like datksrr.rdranlsitcod
      ,socanlsitcod  like datksrr.socanlsitcod
   end record

   define al_ctc44m07  array[2000] of record
                       texto          char(70)
                       end record

   define lr_retorno_c   record
        erro           smallint
       ,mensagem       char(60)
       ,funnom         like isskfunc.funnom
   end record

   define l_data_antes   like datmsrrhst.caddat
   define l_cadmat_antes like datmsrrhst.cadmat
   define l_aux_linha    smallint
   define l_x            smallint

   let l_data_antes   = null
   let l_cadmat_antes = null
   let l_aux_linha    = 1
   let l_x            = null

   initialize al_ctc44m07  to  null

   for l_x = 1 to 2000
      call ctd18g01_consult_hist(l_srrcoddig, l_x)
         returning lr_ctc44m07_c0.erro
                  ,lr_ctc44m07_c0.mensagem
                  ,lr_ctc44m07_c0.srrcoddig
                  ,lr_ctc44m07_c0.srrhstseq
                  ,lr_ctc44m07_c0.srrhsttxt
                  ,lr_ctc44m07_c0.caddat
                  ,lr_ctc44m07_c0.cademp
                  ,lr_ctc44m07_c0.cadmat
                  ,lr_ctc44m07_c0.cadusrtip

      if lr_ctc44m07_c0.erro <> 01 then
         exit for
      end if

      call ctd18g00_inf_socorrista(l_srrcoddig)
         returning lr_ctc44m07_c1.erro
                  ,lr_ctc44m07_c1.mensagem
                  ,lr_ctc44m07_c1.srrcoddig
                  ,lr_ctc44m07_c1.srrnom
                  ,lr_ctc44m07_c1.pestip
                  ,lr_ctc44m07_c1.cgccpfnum
                  ,lr_ctc44m07_c1.cgcord
                  ,lr_ctc44m07_c1.cgccpfdig
                  ,lr_ctc44m07_c1.srrtip
                  ,lr_ctc44m07_c1.rdranlultdat
                  ,lr_ctc44m07_c1.rdranlsitcod
                  ,lr_ctc44m07_c1.socanlsitcod

      call cty08g00_nome_func(lr_ctc44m07_c0.cademp
                             ,lr_ctc44m07_c0.cadmat
                             ,lr_ctc44m07_c0.cadusrtip)
         returning lr_retorno_c.erro
                  ,lr_retorno_c.mensagem
                  ,lr_retorno_c.funnom

      if l_data_antes is null                    or
         l_data_antes   <> lr_ctc44m07_c0.caddat or
         l_cadmat_antes <> lr_ctc44m07_c0.cadmat then

         if l_data_antes is not null then
            let al_ctc44m07[l_aux_linha].texto = null

            let l_aux_linha = l_aux_linha + 1
            if l_aux_linha > 2000 then
               exit for
            end if
         end if

         let al_ctc44m07[l_aux_linha].texto = "Em: "  , lr_ctc44m07_c0.caddat
                                             ," Por: ", lr_retorno_c.funnom
         let l_aux_linha = l_aux_linha + 1
         if l_aux_linha > 2000 then
            exit for
         end if
      end if

      let al_ctc44m07[l_aux_linha].texto = lr_ctc44m07_c0.srrhsttxt
      let l_aux_linha = l_aux_linha + 1
      if l_aux_linha > 2000 then
         exit for
      end if

      let l_data_antes   = lr_ctc44m07_c0.caddat
      let l_cadmat_antes = lr_ctc44m07_c0.cadmat

      initialize lr_ctc44m07_c0.* to null
   end for

   if l_aux_linha > 2000 then
      error 'Numero de registros excedeu o limite'
   end if

   let l_aux_linha = l_aux_linha - 1

   if l_aux_linha = 0 then
      error 'Nenhum registro encontrado'
   else
      display by name lr_ctc44m07_c1.srrnom

      call set_count(l_aux_linha)

      display array al_ctc44m07 to s_ctc44m07.*

         on key(f2,control-c,interrupt)
            exit display

      end display
   end if

   clear form

end function
