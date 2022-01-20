 ############################################################################
 # Menu de Modulo: ctc44m06                                        Gilberto #
 #                                                                  Marcelo #
 # Manutencao no Relacionamento Socorristas/Tipos de Assistencia   Nov/1999 #
 ############################################################################
 # Alteracoes:                                                              #
 #                                                                          #
 # DATA        SOLICITACAO    RESPONSAVEL  DESCRICAO                        #
 #--------------------------------------------------------------------------# 
 #30/11/2010                  Burini       Filtro por naturezas ativas      #
 ############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc44m06(param)
#---------------------------------------------------------------

 define param        record
    srrcoddig        like datrsrrasi.srrcoddig,
    srrnom           like datksrr.srrnom
 end record

 define a_ctc44m06   array[30] of record
    asitipcod        like datrsrrasi.asitipcod,
    asitipdes        like datkasitip.asitipdes,
    caddat           like datrsrrasi.caddat,
    cadfunnom        like isskfunc.funnom
 end record

 define ws           record
    asitipcod        like datrsrrasi.asitipcod,
    asitipstt        like datkasitip.asitipstt,
    cademp           like datrsrrasi.cademp,
    cadmat           like datrsrrasi.cadmat,
    operacao         char (01),
    confirma         char (01)
 end record

 define arr_aux      integer
 define scr_aux      integer
 define l_msg        char(500)
 define l_mensagem   char(100)
 define l_erro       smallint
 define  teste       char(1)

options
     prompt line last,
     insert key f1,
  --   delete key control-y
      delete key f2
     
 if not get_niv_mod(g_issk.prgsgl, "ctc44m06") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 initialize a_ctc44m06  to null
 initialize ws.*        to null
 let int_flag  = false
 let arr_aux   = 1
 let l_msg     = null

 open window w_ctc44m06 at 6,2 with form "ctc44m06"
      attribute(form line first, comment line last - 2)

 display by name param.srrcoddig   attribute(reverse)
 display by name param.srrnom      attribute(reverse)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    message " (F17)Abandona"
 else
    message " (F17)Abandona, (F1)Inclui, (F2)Exclui"
 end if


 declare c_ctc44m06  cursor for
    select datrsrrasi.asitipcod,                            
           datrsrrasi.caddat,                           
           datrsrrasi.cademp,                           
           datrsrrasi.cadmat,                           
           datkasitip.asitipdes                         
      from datrsrrasi,                                  
           datkasitip                                              
     where datrsrrasi.srrcoddig  =  param.srrcoddig                  
       and datkasitip.asitipcod  =  datrsrrasi.asitipcod
       and datkasitip.asitipstt  = 'A'                  
       
 foreach c_ctc44m06 into  a_ctc44m06[arr_aux].asitipcod,
                          a_ctc44m06[arr_aux].caddat,
                          ws.cademp,
                          ws.cadmat,
                          a_ctc44m06[arr_aux].asitipdes

    call ctc44m06_func (ws.cademp, ws.cadmat)
         returning a_ctc44m06[arr_aux].cadfunnom

    let arr_aux = arr_aux + 1
    if arr_aux  >  30   then
       error " Limite excedido, socorrista com mais de 30 tipos de assistencia!"
       exit foreach
    end if
 end foreach


 #---------------------------------------------------------------
 # Nivel de acesso apenas para consulta
 #---------------------------------------------------------------
 call set_count(arr_aux-1)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    display array a_ctc44m06 to s_ctc44m06.*

       on key (interrupt,control-c)
          initialize a_ctc44m06  to null
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

    input array a_ctc44m06  without defaults from  s_ctc44m06.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao    = "a"
             let ws.asitipcod   =  a_ctc44m06[arr_aux].asitipcod
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc44m06[arr_aux]  to null
          display a_ctc44m06[arr_aux].*  to  s_ctc44m06[scr_aux].*

       before field asitipcod
          display a_ctc44m06[arr_aux].asitipcod   to
                  s_ctc44m06[scr_aux].asitipcod   attribute (reverse)

       after field asitipcod
          display a_ctc44m06[arr_aux].asitipcod   to
                  s_ctc44m06[scr_aux].asitipcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = fgl_keyval("left")   then
             let ws.operacao = " "
          end if

          if a_ctc44m06[arr_aux].asitipcod   is null   then
             error " Tipo de assistencia deve ser informado!"
             call ctn25c00("")  returning  a_ctc44m06[arr_aux].asitipcod
             next field asitipcod
          end if

          select asitipstt, asitipdes
            into ws.asitipstt, a_ctc44m06[arr_aux].asitipdes
            from datkasitip
           where datkasitip.asitipcod = a_ctc44m06[arr_aux].asitipcod

          if sqlca.sqlcode  =  notfound   then
             error " Tipo de assistencia nao cadastrada!"
             call ctn25c00("")  returning  a_ctc44m06[arr_aux].asitipcod
             next field asitipcod
          end if

          if ws.asitipstt  <>  "A"   then
             error " Tipo de assistencia cancelada!"
             next field asitipcod
          end if

          display a_ctc44m06[arr_aux].asitipdes   to
                  s_ctc44m06[scr_aux].asitipdes

          #-------------------------------------------------------------
          # Verifica se assistencia ja' cadastrada (inclusao)
          #-------------------------------------------------------------
          if ws.operacao  =  "i"   then
             select asitipcod
               from datrsrrasi
              where datrsrrasi.srrcoddig = param.srrcoddig
                and datrsrrasi.asitipcod = a_ctc44m06[arr_aux].asitipcod
             if sqlca.sqlcode  =  0   then
                error " Tipo de assistencia ja' cadastrada p/ este socorrista!"
                next field asitipcod
             end if

             let a_ctc44m06[arr_aux].caddat = today

             display a_ctc44m06[arr_aux].caddat      to
                     s_ctc44m06[scr_aux].caddat

             call ctc44m06_func (g_issk.empcod, g_issk.funmat)
                  returning a_ctc44m06[arr_aux].cadfunnom

             display a_ctc44m06[arr_aux].cadfunnom   to
                     s_ctc44m06[scr_aux].cadfunnom
          end if

          if ws.operacao  =  "a"   then
             if ws.asitipcod  <>  a_ctc44m06[arr_aux].asitipcod    then
                error " Tipo de assistencia nao deve ser alterado!"
                next field asitipcod
             end if
          end if

      on key (interrupt)
          exit input

      before delete
         let ws.operacao = "d"
         if a_ctc44m06[arr_aux].asitipcod   is null   then
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
                 from datrsrrasi
                where datrsrrasi.srrcoddig = param.srrcoddig
                  and datrsrrasi.asitipcod = a_ctc44m06[arr_aux].asitipcod

            if sqlca.sqlcode = 0 then
               #-------------------------------------------------------------
               # SE O DEPARTAMENTO FOR CT24HS ENVIA E-MAIL PARA PORTO SOCORRO
               #-------------------------------------------------------------
               if g_issk.dptsgl = "ct24hs" or
                  g_issk.dptsgl = "tlprod" or
                  g_issk.dptsgl = "dsvatd" then
                  let l_msg = "Socorrista.: ",
                               param.srrcoddig using "<<<<<<<&" ,
                               " - ", param.srrnom clipped, ascii(13),
                              "Assistencia: ",
                               a_ctc44m06[arr_aux].asitipcod using "<<<<&",
                               " - ", a_ctc44m06[arr_aux].asitipdes

                  call cts20g08("ASSISTENCIAS DO SOCORRISTA", # NOME DO CADASTRO
                                "Exclusao",                   # TIPO DA OPERACAO
                                "CTC44M06",                   # NOME DO 4GL
                                g_issk.empcod,
                                g_issk.usrtip,
                                g_issk.funmat,
                                l_msg)
                           
                 
               end if
               let l_mensagem = 'Exclusao no cadastro do socorrista. Codigo : ',
	                  param.srrcoddig
               let l_msg =  "Assistencia: [", a_ctc44m06[arr_aux].asitipcod clipped,
                                     " - ", a_ctc44m06[arr_aux].asitipdes clipped,"] Excluida !"
                                                                
               let l_erro =  ctc44m00_grava_hist(param.srrcoddig
                                                 ,l_msg clipped
                                                 ,today
                                                 ,l_mensagem,"I")
                                         
            end if

            commit work

            initialize a_ctc44m06[arr_aux].* to null
            display    a_ctc44m06[arr_aux].* to s_ctc44m06[scr_aux].*
         end if

       after row
      
          begin work
             case ws.operacao
               when "i"
                   insert into datrsrrasi ( srrcoddig,
                                            asitipcod,
                                            caddat,
                                            cademp,
                                            cadmat )
                               values     ( param.srrcoddig,
                                            a_ctc44m06[arr_aux].asitipcod,
                                            a_ctc44m06[arr_aux].caddat,
                                            g_issk.empcod,
                                            g_issk.funmat )

  
                   if sqlca.sqlcode = 0 then
                      #-------------------------------------------------------------
                      # SE O DEPARTAMENTO FOR CT24HS ENVIA E-MAIL PARA PORTO SOCORRO
                      #-------------------------------------------------------------
                      if g_issk.dptsgl = "ct24hs" or
                         g_issk.dptsgl = "tlprod" or
                         g_issk.dptsgl = "dsvatd" then

                         let l_msg = "Socorrista.: ",
                                     param.srrcoddig using "<<<<<<<&" ,
                                     " - ", param.srrnom clipped, ascii(13),
                                    "Assistencia: ",
                                     a_ctc44m06[arr_aux].asitipcod using "<<<<&",
                                     " - ", a_ctc44m06[arr_aux].asitipdes

                         call cts20g08("ASSISTENCIAS DO SOCORRISTA", # NOME DO CADASTRO
                                       "Inclusao",                   # TIPO DA OPERACAO
                                       "CTC44M06",                   # NOME DO 4GL
                                       g_issk.empcod,
                                       g_issk.usrtip,
                                       g_issk.funmat,
                                       l_msg)
                                       
                                 
                      end if
                       let l_msg =  "Assistencia: [", a_ctc44m06[arr_aux].asitipcod clipped,
                                     " - ", a_ctc44m06[arr_aux].asitipdes clipped,"] Incluida !"
                                                 
                       let l_mensagem = 'Inclusao no cadastro do socorrista. Codigo : ',
		                  param.srrcoddig
 	               let l_erro =  ctc44m00_grava_hist(param.srrcoddig
                                                         ,l_msg clipped
                                                         ,today
                                                         ,l_mensagem,"I")     
                   end if

             end case
          commit work

          let ws.operacao = " "

    end input

    if int_flag   then
       exit while
    end if

 end while

 options
     delete key f2
     
 let int_flag = false
 close c_ctc44m06

 close window w_ctc44m06

end function   ###-- ctc44m06


#---------------------------------------------------------
 function ctc44m06_func(param)
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

 end function   # ctc44m06_func


