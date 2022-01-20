 ############################################################################
 # Menu de Modulo: ctc34m06                                        Gilberto #
 #                                                                  Marcelo #
 # Manutencao no Relacionamento Veiculos/Tipos de Assistencia      Set/1998 #
 ############################################################################
 # .........................................................................#
 #                                                                          #
 #                           * * * ALTERACOES * * *                         #
 #                                                                          #
 # DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                          #
 # ---------- --------------  ---------- -----------------------------------#
 # 06/08/2008 Diomar,Meta     PSI226300  Incluido gravacao do historico     #
 # 30/11/2010 Burini                     Filtro por naturezas ativas        #
 #--------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc34m06(param)
#---------------------------------------------------------------

 define param        record
    socvclcod        like datrvclasi.socvclcod,
    atdvclsgl        like datkveiculo.atdvclsgl,
    vcldes           char (58)
 end record

 define a_ctc34m06   array[30] of record
    asitipcod        like datrvclasi.asitipcod,
    asitipdes        like datkasitip.asitipdes,
    caddat           like datrvclasi.caddat,
    cadfunnom        like isskfunc.funnom
 end record

 define ws           record
    asitipcod        like datrvclasi.asitipcod,
    asitipstt        like datkasitip.asitipstt,
    cademp           like datrvclasi.cademp,
    cadmat           like datrvclasi.cadmat,
    operacao         char (01),
    confirma         char (01)
 end record

 define arr_aux      integer
 define scr_aux      integer

 #########################RETIRAR
 define l_destinatarios char(4000)
 define l_comando       char(4000)
 define l_assunto       char(1000)
 define l_runstt        smallint
 define l_anexo         char(300)
       ,l_mensagem      char(100)
       ,l_mensagem2     char(3000)
       ,l_stt           smallint

  define lr_retorno     record
         erro           smallint,
         mensagem       char(100),
         funnom         char(300)
 end record
 ################################


 if not get_niv_mod(g_issk.prgsgl, "ctc34m06") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 initialize a_ctc34m06  to null
 initialize ws.*        to null
 let int_flag    =  false
 let arr_aux     =  1
 let l_mensagem  = null
 let l_mensagem2 = null
 let l_stt       = null

 open window w_ctc34m06 at 6,2 with form "ctc34m06"
      attribute(form line first, comment line last - 2)

 display by name param.socvclcod   attribute(reverse)
 display by name param.atdvclsgl   attribute(reverse)
 display by name param.vcldes      attribute(reverse)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    message " (F17)Abandona"
 else
    message " (F17)Abandona, (F1)Inclui, (F2)Exclui"
 end if


 declare c_ctc34m06  cursor for
    select datrvclasi.asitipcod,
           datrvclasi.caddat,
           datrvclasi.cademp,
           datrvclasi.cadmat,
           datkasitip.asitipdes
      from datrvclasi, 
           datkasitip
     where datrvclasi.socvclcod  =  param.socvclcod
       and datkasitip.asitipcod  =  datrvclasi.asitipcod
       and datkasitip.asitipstt  = 'A'       

 foreach c_ctc34m06 into  a_ctc34m06[arr_aux].asitipcod,
                          a_ctc34m06[arr_aux].caddat,
                          ws.cademp,
                          ws.cadmat,
                          a_ctc34m06[arr_aux].asitipdes

    call ctc34m06_func (ws.cademp, ws.cadmat)
         returning a_ctc34m06[arr_aux].cadfunnom

    let arr_aux = arr_aux + 1
    if arr_aux  >  30   then
       error " Limite excedido, veiculo com mais de 30 tipos de assistencia!"
       exit foreach
    end if
 end foreach


#---------------------------------------------------------------
# Nivel de acesso apenas para consulta
#---------------------------------------------------------------
 call set_count(arr_aux-1)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    display array a_ctc34m06 to s_ctc34m06.*

       on key (interrupt,control-c)
          initialize a_ctc34m06  to null
          exit display

    end display
 end if

#---------------------------------------------------------------
# Nivel de acesso para consulta/atualizacao
#---------------------------------------------------------------
 while true

    if g_issk.acsnivcod  <  g_issk.acsnivatl   then
       exit while
    end if

    let int_flag = false

    input array a_ctc34m06  without defaults from  s_ctc34m06.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao    = "a"
             let ws.asitipcod   =  a_ctc34m06[arr_aux].asitipcod
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc34m06[arr_aux]  to null
          display a_ctc34m06[arr_aux].*  to  s_ctc34m06[scr_aux].*

       before field asitipcod
          display a_ctc34m06[arr_aux].asitipcod   to
                  s_ctc34m06[scr_aux].asitipcod   attribute (reverse)

       after field asitipcod
          display a_ctc34m06[arr_aux].asitipcod   to
                  s_ctc34m06[scr_aux].asitipcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = fgl_keyval("left")   then
             let ws.operacao = " "
          end if

          if a_ctc34m06[arr_aux].asitipcod   is null   then
             error " Tipo de assistencia deve ser informado!"
             call ctn25c00("")  returning  a_ctc34m06[arr_aux].asitipcod
             next field asitipcod
          end if

          select asitipstt, asitipdes
            into ws.asitipstt, a_ctc34m06[arr_aux].asitipdes
            from datkasitip
           where datkasitip.asitipcod = a_ctc34m06[arr_aux].asitipcod

          if sqlca.sqlcode  =  notfound   then
             error " Tipo de assistencia nao cadastrada!"
             call ctn25c00("")  returning  a_ctc34m06[arr_aux].asitipcod
             next field asitipcod
          end if

          if ws.asitipstt  <>  "A"   then
             error " Tipo de assistencia cancelada!"
             next field asitipcod
          end if

          display a_ctc34m06[arr_aux].asitipdes   to
                  s_ctc34m06[scr_aux].asitipdes

          #-------------------------------------------------------------
          # Verifica se assistencia ja' cadastrada (inclusao)
          #-------------------------------------------------------------
          if ws.operacao  =  "i"   then
             select asitipcod
               from datrvclasi
              where datrvclasi.socvclcod = param.socvclcod
                and datrvclasi.asitipcod = a_ctc34m06[arr_aux].asitipcod
             if sqlca.sqlcode  =  0   then
                error " Tipo de assistencia ja' cadastrada para este veiculo!"
                next field asitipcod
             end if

             let a_ctc34m06[arr_aux].caddat = today

             display a_ctc34m06[arr_aux].caddat      to
                     s_ctc34m06[scr_aux].caddat

             call ctc34m06_func (g_issk.empcod, g_issk.funmat)
                  returning a_ctc34m06[arr_aux].cadfunnom

             display a_ctc34m06[arr_aux].cadfunnom   to
                     s_ctc34m06[scr_aux].cadfunnom
          end if

          if ws.operacao  =  "a"   then
             if ws.asitipcod  <>  a_ctc34m06[arr_aux].asitipcod    then
                error " Tipo de assistencia nao deve ser alterado!"
                next field asitipcod
             end if
          end if

      on key (interrupt)
          exit input

      before delete
         let ws.operacao = "d"
         if a_ctc34m06[arr_aux].asitipcod   is null   then
            continue input
         else
            let  ws.confirma = "N"
            call cts08g01("A","S","","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                 returning ws.confirma

            if ws.confirma = "N" then
               exit input
            end if

            begin work
               delete
                 from datrvclasi
                where datrvclasi.socvclcod = param.socvclcod
                  and datrvclasi.asitipcod = a_ctc34m06[arr_aux].asitipcod
            commit work
            
            let l_mensagem  = "Tipo de Assistencia do veiculo [",a_ctc34m06[arr_aux].asitipcod clipped,
                              "] Excluido !"
            let l_mensagem2 = "Delecao  no cadastro de tipo de assistencia. Veiculo Codigo = ",
                              param.socvclcod            
                                                                                                       
            let l_stt = ctc34m06_grava_hist(param.socvclcod                                            
                                           ,l_mensagem                                                 
                                           ,today                                 
                                           ,l_mensagem2)                                               

            ##########################################RETIRAR
            #COMENTADO PARA POSTERIOR VERIFICACAO
            {call cty08g00_nome_func(g_issk.empcod,
                                    g_issk.funmat,
                                    g_issk.usrtip)
                 returning lr_retorno.*

            let l_destinatarios = " kevellin.olivatti@correioporto"
                                  ,",ligia.mattge@correioporto"
                                  ,",sergio.burini@correioporto"

            let l_assunto = "DELETE AST VCL - ",lr_retorno.funnom, " - ", param.socvclcod, " - ", a_ctc34m06[arr_aux].asitipcod

            let l_comando = "send_email.sh "
                    ,' -s   "',l_assunto clipped, '" '
                    ," -a ",l_destinatarios clipped

            run l_comando returning l_runstt}
            ##################################################

            initialize a_ctc34m06[arr_aux].* to null
            display    a_ctc34m06[arr_aux].* to s_ctc34m06[scr_aux].*
         end if

       after row
          begin work
             case ws.operacao
               when "i"
                   insert into datrvclasi ( socvclcod,
                                            asitipcod,
                                            caddat,
                                            cademp,
                                            cadmat )
                               values     ( param.socvclcod,
                                            a_ctc34m06[arr_aux].asitipcod,
                                            a_ctc34m06[arr_aux].caddat,
                                            g_issk.empcod,
                                            g_issk.funmat )
             end case
          commit work
          
         if ws.operacao = "i" then
            let l_mensagem  = "Tipo de Assistencia do veiculo [",a_ctc34m06[arr_aux].asitipcod clipped,"] Incluido !"
            let l_mensagem2 = "Inclusao no cadastro de tipo de assistencia. Veiculo codigo =  ", param.socvclcod
            
            let l_stt = ctc34m06_grava_hist(param.socvclcod
                                           ,l_mensagem                                  
                                           ,today
                                           ,l_mensagem2) 
         end if
          let ws.operacao = " "

    end input

    if int_flag   then
       exit while
    end if

 end while

 let int_flag = false
 close c_ctc34m06

 close window w_ctc34m06

end function   ###-- ctc34m06


#---------------------------------------------------------
 function ctc34m06_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = param.empcod
    and isskfunc.funmat = param.funmat

 return ws.funnom

 end function   # ctc34m06_func

#------------------------------------------------
function ctc34m06_grava_hist(lr_param,l_mensagem)
#------------------------------------------------

   define lr_param record
          socvclcod  like datrvclasi.socvclcod
         ,mensagem   char(100)
         ,data       date
          end record

   define lr_retorno record
                     stt smallint
                    ,msg char(50)
          end record

   define l_mensagem  char(3000)
         ,l_stt       smallint
         ,l_erro      smallint
         ,l_path      char(100)

   let l_stt  = true
   let l_path = null

   initialize lr_retorno to null

   call ctb85g01_grava_hist(1
                           ,lr_param.socvclcod
                           ,lr_param.mensagem
                           ,lr_param.data
                           ,g_issk.empcod
                           ,g_issk.funmat
                           ,g_issk.usrtip)
      returning lr_retorno.stt
               ,lr_retorno.msg

   if lr_retorno.stt = 0 then

       call ctb85g01_mtcorpo_email_html('CTC34M01',
		                   lr_param.data,
		                   current hour to minute,
		                   g_issk.empcod,
		                   g_issk.usrtip,
		                   g_issk.funmat,
		                   l_mensagem,
		                   lr_param.mensagem)
		returning l_erro

      if l_erro <> 0 then
         error 'Erro no envio do email ' sleep 2
      end if 
   else
      error 'Erro na gravacao do historico' sleep 2
      let l_stt = false
   end if

   return l_stt

end function

