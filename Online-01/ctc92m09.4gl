###########################################################################
# Nome do Modulo: ctc92m09                                      R.Fornax  #
#                                                                         #
# Cadastro Natureza x Plano                                     Ago/2014  #
###########################################################################


 globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define ma_ctc92m09 array[500] of record
       socntzcod     like datksocntz.socntzcod
     , socntzdes     like datksocntz.socntzdes
     , ctisrvflg     like datritaasiplnnat.ctisrvflg
     , ctinaosrvflg  like datritaasiplnnat.ctinaosrvflg
     , utzlmtqtd     like datritaasiplnnat.utzlmtqtd
 end record

 define param       record
        itaasiplncod   like datkitaasipln.itaasiplncod
      , itaasiplndes   like datkitaasipln.itaasiplndes
      , ressrvlimqtd   like datkitaasipln.ressrvlimqtd
      , ctisrvflg      like datritaasiplnnat.ctisrvflg
      , ctinaosrvflg   like datritaasiplnnat.ctinaosrvflg
 end record

 define r_ctc92m09 record
       atlemp     like datkitaasipln.atlemp
      ,atlmat     like datkitaasipln.atlmat
      ,atldat     like datkitaasipln.atldat
      ,funnom     like isskfunc.funnom
 end record

 define m_operacao  char(1)
 define arr_aux     smallint
 define scr_aux     smallint

 define  m_sql  char(1)

#===============================================================================
 function ctc92m09_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select a.socntzcod                                             '
          ,  '      , a.socntzdes                                             '
          ,  '      , b.ctisrvflg                                             '
          ,  '      , b.ctinaosrvflg                                          '
          ,  '      , b.utzlmtqtd                                             '
          ,  '   from datksocntz a                                            '
          ,  '      , datritaasiplnnat b                                      '
          ,  '      , datkitaasipln c                                         '
          ,  '  where a.socntzcod    = b.socntzcod                            '
          ,  '    and c.itaasiplncod = b.itaasiplncod                         '
          ,  '    and b.itaasiplncod = ?                                      '
          ,  '  order by a.socntzcod                                          '
 prepare p_ctc92m09_001 from l_sql
 declare c_ctc92m09_001 cursor for p_ctc92m09_001

 let l_sql = ' update  datritaasiplnnat     '
           ,  '     set ctisrvflg =  ?   ,  '
           ,  '         ctinaosrvflg = ? ,  '
           ,  '         utzlmtqtd    = ? ,  '
           ,  '         atlmat       = ? ,  '
           ,  '         atldat       = ?    '
           ,  '   where socntzcod =  ?      '
           ,  '     and itaasiplncod =?     '
 prepare p_ctc92m09_002 from l_sql

 let l_sql = '   select atlemp              '
            ,'         ,atlmat              '
            ,'         ,atldat              '
            ,'         ,atlusrtip           '
            ,'     from datritaasiplnnat     '
            ,'    where socntzcod  =  ?     '
            ,'      and itaasiplncod = ?    '
 prepare p_ctc92m09_003 from l_sql
 declare c_ctc92m09_003 cursor for p_ctc92m09_003

  let l_sql = '   select count(socntzcod)        '
            , '     from datritaasiplnnat        '
            , '    where socntzcod = ?           '
            , '      and itaasiplncod = ?        '
 prepare p_ctc92m09_004 from l_sql
 declare c_ctc92m09_004 cursor for p_ctc92m09_004

 let l_sql = '   select socntzdes          '
            , '     from datksocntz        '
            , '    where socntzcod = ?     '
 prepare p_ctc92m09_005 from l_sql
 declare c_ctc92m09_005 cursor for p_ctc92m09_005

 let l_sql =  ' insert into datritaasiplnnat      '
           ,  '   (itaasiplncod                   '
           ,  '   ,socntzcod                      '
           ,  '   ,utzlmtqtd                      '
           ,  '   ,ctisrvflg                      '
           ,  '   ,ctinaosrvflg                   '
           ,  '   ,atlusrtip                      '
           ,  '   ,atlemp                         '
           ,  '   ,atlmat                         '
           ,  '   ,atldat)                        '
           ,  ' values(?,?,?,?,?,?,?,?,?)         '
 prepare p_ctc92m09_006 from l_sql

  let l_sql = '   select count(socntzcod)   '
            , '     from datksocntz         '
            , '    where socntzcod = ?      '
 prepare p_ctc92m09_007 from l_sql
 declare c_ctc92m09_007 cursor for p_ctc92m09_007

 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc92m09_008 from l_sql
 declare c_ctc92m09_008 cursor for p_ctc92m09_008

 let l_sql = '  delete datritaasiplnnat    '
          ,  '   where socntzcod = ?          '
          ,  '     and itaasiplncod = ?       '
 prepare p_ctc92m09_009 from l_sql



 let l_sql = '  delete datrclisgmasiplnntz     '
            ,'  where  socntzcod = ?           '
            ,'  and itaasiplncod = ?           '
 prepare p_ctc92m09_013 from l_sql


let m_sql = 'S'


end function

#===============================================================================
 function ctc92m09(lr_param)
#===============================================================================

 define lr_param record
  itaasiplncod like datkitaasipln.itaasiplncod ,
  itaasiplndes like datkitaasipln.itaasiplndes ,
  ressrvlimqtd like datkitaasipln.ressrvlimqtd
 end record

 define l_ret                smallint
 define m_itaasiplncod_aux   like datksocntz.socntzcod
 define l_flag               smallint

 let param.itaasiplncod = lr_param.itaasiplncod
 let param.itaasiplndes = lr_param.itaasiplndes
 let param.ressrvlimqtd = lr_param.ressrvlimqtd

 let arr_aux = 1

 if m_sql is null or
    m_sql <> 'S' then
    call ctc92m09_prepare()
 end if

 options delete key F2

 open window w_ctc92m09 at 6,2 with form 'ctc92m09'
 attribute(form line 1)

 message ' (F17)Abandona, (F1)Inclui, (F2)Exclui, (F7)Segmentos'

  display by name param.itaasiplncod
                , param.itaasiplndes
                , param.ressrvlimqtd



  open c_ctc92m09_001  using param.itaasiplncod
  foreach c_ctc92m09_001 into ma_ctc92m09[arr_aux].socntzcod
                            , ma_ctc92m09[arr_aux].socntzdes
                            , ma_ctc92m09[arr_aux].ctisrvflg
                            , ma_ctc92m09[arr_aux].ctinaosrvflg
                            , ma_ctc92m09[arr_aux].utzlmtqtd

    
       let arr_aux = arr_aux + 1

       if arr_aux > 500 then
          error " Limite excedido! Foram encontrados mais de 500 Naturezas!"
          exit foreach
       end if

  end foreach


  if arr_aux = 1  then
       error "Nao Foi encontrado Nenhum Registro!"
    end if

 let m_operacao = " "

 call set_count(arr_aux - 1 )

 input array ma_ctc92m09 without defaults from s_ctc92m09.*

      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             if ma_ctc92m09[arr_aux].socntzcod is null or
                ma_ctc92m09[arr_aux].socntzcod = 0     then
                let m_operacao = 'i'
             end if
          end if

      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         initialize  ma_ctc92m09[arr_aux] to null

         display ma_ctc92m09[arr_aux].socntzcod  to s_ctc92m09[scr_aux].socntzcod
         display ma_ctc92m09[arr_aux].socntzdes  to s_ctc92m09[scr_aux].socntzdes

      #---------------------------------------------
       before field socntzcod
      #---------------------------------------------
         if ma_ctc92m09[arr_aux].socntzcod is null then
            display ma_ctc92m09[arr_aux].socntzcod to s_ctc92m09[scr_aux].socntzcod attribute(reverse)
            let m_operacao = 'i'
         else
           let m_itaasiplncod_aux  = ma_ctc92m09[arr_aux].socntzcod
           display ma_ctc92m09[arr_aux].* to s_ctc92m09[scr_aux].* attribute(reverse)
         end if

         if m_operacao <> 'i' then
            call ctc92m09_dados_alteracao(ma_ctc92m09[arr_aux].socntzcod)
         end if

      #---------------------------------------------
       after field socntzcod
      #---------------------------------------------
         if fgl_lastkey() = fgl_keyval ("down")     or
            fgl_lastkey() = fgl_keyval ("return")   then

            if m_operacao = 'i' then
               if ma_ctc92m09[arr_aux].socntzcod is null then

                   if fgl_lastkey() = fgl_keyval ("down")   or
                      fgl_lastkey() = fgl_keyval ("return")     then

                      call cto00m10_popup(16)
                         returning ma_ctc92m09[arr_aux].socntzcod
                                 , ma_ctc92m09[arr_aux].socntzdes

                         display ma_ctc92m09[arr_aux].socntzcod to s_ctc92m09[scr_aux].socntzcod
                         display ma_ctc92m09[arr_aux].socntzdes to s_ctc92m09[scr_aux].socntzdes


                        let l_ret = 0

                        open c_ctc92m09_007 using ma_ctc92m09[arr_aux].socntzcod
                        fetch c_ctc92m09_007 into l_ret

                        if l_ret < 1 then
                           error 'Codigo de Natureza Nao Existe!'
                           next field socntzcod
                        end if


                        let l_ret = 0

                        open c_ctc92m09_004 using ma_ctc92m09[arr_aux].socntzcod
                                                , param.itaasiplncod
                        fetch c_ctc92m09_004 into l_ret

                        if l_ret > 0  then
                           error 'Esse Codigo Ja Esta Cadastrado!'
                           next field socntzcod
                        end if
                   else
                      let m_operacao = ' '
                   end if
               else


                  let l_ret = 0

                  open c_ctc92m09_007 using ma_ctc92m09[arr_aux].socntzcod
                  fetch c_ctc92m09_007 into l_ret

                  if l_ret < 1 then
                     error 'Codigo da Natureza Nao Existe!'
                     next field socntzcod
                  end if


                  let l_ret = 0

                  open c_ctc92m09_004 using ma_ctc92m09[arr_aux].socntzcod
                                          , param.itaasiplncod
                  fetch c_ctc92m09_004 into l_ret

                  if l_ret > 0  then
                     error 'Esse Codigo Ja Esta Cadastrado!'
                     next field socntzcod
                  end if


                   open c_ctc92m09_005 using ma_ctc92m09[arr_aux].socntzcod
                   fetch c_ctc92m09_005 into ma_ctc92m09[arr_aux].socntzdes

                   display ma_ctc92m09[arr_aux].socntzcod to s_ctc92m09[scr_aux].socntzcod
                   display ma_ctc92m09[arr_aux].socntzdes to s_ctc92m09[scr_aux].socntzdes

               end if

            else
              let ma_ctc92m09[arr_aux].socntzcod = m_itaasiplncod_aux
              display ma_ctc92m09[arr_aux].* to s_ctc92m09[scr_aux].*
            end if

         else
           if m_operacao = 'i' then
              let ma_ctc92m09[arr_aux].socntzcod = ''
              display ma_ctc92m09[arr_aux].* to s_ctc92m09[scr_aux].*
              let m_operacao = ' '
           else
              let ma_ctc92m09[arr_aux].socntzcod = m_itaasiplncod_aux
              display ma_ctc92m09[arr_aux].* to s_ctc92m09[scr_aux].*
           end if

         end if


    #---------------------------------------------
     before field ctisrvflg
    #---------------------------------------------
        display ma_ctc92m09[arr_aux].ctisrvflg   to s_ctc92m09[scr_aux].ctisrvflg   attribute(reverse)


    #---------------------------------------------
     after  field ctisrvflg
    #---------------------------------------------
        display ma_ctc92m09[arr_aux].ctisrvflg   to s_ctc92m09[scr_aux].ctisrvflg

        if fgl_lastkey() = fgl_keyval ("up")     or
           fgl_lastkey() = fgl_keyval ("left")   then
              next field socntzcod
        end if

        if ma_ctc92m09[arr_aux].ctisrvflg <> "S"   and
        	 ma_ctc92m09[arr_aux].ctisrvflg <> "N"   then
           error "Por Favor Informe Somente S ou N"
           next field ctisrvflg
        end if

     #---------------------------------------------
      before field ctinaosrvflg
     #---------------------------------------------
         display ma_ctc92m09[arr_aux].ctinaosrvflg   to s_ctc92m09[scr_aux].ctinaosrvflg   attribute(reverse)


     #---------------------------------------------
      after  field ctinaosrvflg
     #---------------------------------------------
         display ma_ctc92m09[arr_aux].ctinaosrvflg   to s_ctc92m09[scr_aux].ctinaosrvflg

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
               next field ctisrvflg
         end if

         if ma_ctc92m09[arr_aux].ctinaosrvflg <> "S"   and
         	  ma_ctc92m09[arr_aux].ctinaosrvflg <> "N"  then
            error "Por Favor Informe Somente S ou N"
            next field ctinaosrvflg
         end if

      #---------------------------------------------
       before field utzlmtqtd
      #---------------------------------------------
          display ma_ctc92m09[arr_aux].utzlmtqtd   to s_ctc92m09[scr_aux].utzlmtqtd   attribute(reverse)


      #---------------------------------------------
       after  field utzlmtqtd
      #---------------------------------------------
          display ma_ctc92m09[arr_aux].utzlmtqtd   to s_ctc92m09[scr_aux].utzlmtqtd

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
                next field ctinaosrvflg
          end if

          if ma_ctc92m09[arr_aux].utzlmtqtd is null   then
             error "Por Favor Informe um Limite"
             next field utzlmtqtd
          end if



         if m_operacao = 'i' then

            let m_operacao = ' '

            execute p_ctc92m09_006 using param.itaasiplncod
                                       , ma_ctc92m09[arr_aux].socntzcod
                                       , ma_ctc92m09[arr_aux].utzlmtqtd
                                       , ma_ctc92m09[arr_aux].ctisrvflg
                                       , ma_ctc92m09[arr_aux].ctinaosrvflg
                                       , g_issk.usrtip
                                       , g_issk.empcod
                                       , g_issk.funmat
                                       , 'today'

             if sqlca.sqlcode = 0 then
                error 'Dados Incluidos com Sucesso!'
                let m_operacao = ' '
             else
                error 'ERRO(',sqlca.sqlcode,') na Insercao de Dados! AVISE A INFORMATICA!! (datritaasiplnnat)'
             end if

         else
              call ctc92m09_altera()
         end if


      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input


      #---------------------------------------------
       on key (F7)
      #---------------------------------------------

          if ma_ctc92m09[arr_aux].socntzcod is not null then

              call ctc91m27(lr_param.itaasiplncod          ,
                            lr_param.itaasiplndes          ,
                            ma_ctc92m09[arr_aux].socntzcod ,
                            ma_ctc92m09[arr_aux].socntzdes)

          end if

      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc92m09[arr_aux].socntzcod  is null   then
            continue input
         else
            if not ctc92m09_delete(ma_ctc92m09[arr_aux].socntzcod) then
                let l_flag = 1
                exit input
            end if
         end if

  end input

 close window w_ctc92m09

 if l_flag = 1 then
    call ctc92m09(param.itaasiplncod ,
                  param.itaasiplndes ,
                  param.ressrvlimqtd  )
 end if


end function

#=========================================================
 function ctc92m09_dados_alteracao(l_socntzcod)
#=========================================================
define l_socntzcod smallint

define l_usrtip  like datritaasiplnnat.atlusrtip

   initialize r_ctc92m09.* to null

   whenever error continue
   open c_ctc92m09_003 using l_socntzcod
                           , param.itaasiplncod
   fetch c_ctc92m09_003 into  r_ctc92m09.atlemp
                             ,r_ctc92m09.atlmat
                             ,r_ctc92m09.atldat
                             ,l_usrtip

    if sqlca.sqlcode <> 0  then
        whenever error stop
    end if

   call ctc92m09_func(r_ctc92m09.atlemp, r_ctc92m09.atlmat, l_usrtip)
   returning r_ctc92m09.funnom

   display by name  r_ctc92m09.atldat
                   ,r_ctc92m09.funnom

end function


#===============================================================
 function ctc92m09_func(l_empcod, l_funmat, l_usrtip)
#===============================================================

 define  l_empcod      like   datkitaasipln.atlemp
 define  l_funmat      like   datkitaasipln.atlmat
 define  l_funnom      char(100)
 define  l_usrtip      like datritaasiplnnat.atlusrtip

 whenever error continue
 open c_ctc92m09_008 using l_empcod,
                           l_funmat,
                           l_usrtip

 fetch c_ctc92m09_008 into l_funnom

   if sqlca.sqlcode = notfound then
    whenever error stop
    let l_funnom = '    '
 end if

 close c_ctc92m09_008
 return l_funnom

end function


#==============================================
 function ctc92m09_delete(l_socntzcod)
#==============================================
define l_socntzcod like datksocntz.socntzcod
define l_confirma char(1)


  call cts08g01("A","S"
               ,""
               ,"CONFIRMA EXCLUSAO "
               ,"DA NATUREZA ?"
               ," ")
     returning l_confirma

     if l_confirma = "S" then
        let m_operacao = 'd'


        whenever error continue
        execute p_ctc92m09_013 using l_socntzcod
                                   , param.itaasiplncod

        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') delete, AVISE A INFORMATICA!! (datrclisgmasiplnntz)'
           return false
           whenever error stop
        end if


        whenever error continue
        execute p_ctc92m09_009 using l_socntzcod
                                   , param.itaasiplncod

        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') delete, AVISE A INFORMATICA!! (datritaasiplnnat)'
           return false
           whenever error stop
        end if


        return true
     else
        return false
     end if

end function

#---------------------------------------------------------
 function ctc92m09_altera()
#---------------------------------------------------------

define lr_retorno record
   data_atual date                 ,
   funmat     like isskfunc.funmat
end record

initialize lr_retorno.* to null

    let lr_retorno.data_atual = today
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"

    whenever error continue
    execute p_ctc92m09_002 using ma_ctc92m09[arr_aux].ctisrvflg
                               , ma_ctc92m09[arr_aux].ctinaosrvflg
                               , ma_ctc92m09[arr_aux].utzlmtqtd
                               , lr_retorno.funmat
                               , lr_retorno.data_atual
                               , ma_ctc92m09[arr_aux].socntzcod
                               , param.itaasiplncod
    whenever error continue

    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao da Natureza!'

    else
    	  error 'Dados Alterados com Sucesso!'
    end if

    let m_operacao = ' '

end function




