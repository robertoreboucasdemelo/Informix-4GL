###########################################################################
# Nome do Modulo: ctc92m06                               Helder Oliveira  #
#                                                                         #
# Cadastro Motivo                                                Mar/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descri��o                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################
 globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define ma_ctc92m06 array[500] of record
       mtv_cod    like datkitarsrcaomtv.itarsrcaomtvcod
     , mtv_des    like datkitarsrcaomtv.itarsrcaomtvdes
     , srvlimdat  like datkitarsrcaomtv.srvlimdat
     , sinatdflg  like datkitarsrcaomtv.sinatdflg
     , dialimqtd  like datkitarsrcaomtv.dialimqtd
 end record


  define r_ctc92m06 record
         atlemp     like datkitarsrcaomtv.atlemp
        ,atlmat     like datkitarsrcaomtv.atlmat
        ,atldat     like datkitarsrcaomtv.atldat
        ,funnom     like isskfunc.funnom
  end record

 define m_operacao  char(1)
 define arr_aux     smallint
 define scr_aux     smallint

 define m_mtv_cod     like datkitarsrcaomtv.itarsrcaomtvcod
 define m_mtv_des     like datkitarsrcaomtv.itarsrcaomtvdes
 define m_mtv_diaria  like datkitarsrcaomtv.dialimqtd
 define m_srvlimdat   like datkitarsrcaomtv.srvlimdat
 define m_sinatdflg   like datkitarsrcaomtv.sinatdflg

 define  m_ctc92m06_prepare  char(1)

#===============================================================================
 function ctc92m06_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc92m06_001 from l_sql
 declare c_ctc92m06_001 cursor for p_ctc92m06_001

 let l_sql =  ' select itarsrcaomtvcod     '
             ,'      , itarsrcaomtvdes     '
             ,'      , srvlimdat           '
             ,'      , sinatdflg           '
             ,'      , dialimqtd           '
             ,'   from datkitarsrcaomtv    '
             ,'   order by 1               '
 prepare p_ctc92m06_002 from l_sql
 declare c_ctc92m06_002 cursor for p_ctc92m06_002

 let l_sql =  ' select  atlemp             '
             ,'        ,atlmat             '
             ,'        ,atldat             '
             ,'        ,atlusrtip          '
             ,'   from datkitarsrcaomtv    '
             ,'  where itarsrcaomtvcod = ? '
 prepare p_ctc92m06_003 from l_sql
 declare c_ctc92m06_003 cursor for p_ctc92m06_003

  let l_sql =  ' insert into datkitarsrcaomtv                         '
             ,'  (itarsrcaomtvcod,itarsrcaomtvdes,dialimqtd           '
             ,'  ,srvlimdat,sinatdflg,atlusrtip,atlemp,atlmat,atldat) '
             ,'  values                                               '
             ,'  (?,?,?,?,?,?,?,?,?)                                  '
 prepare p_ctc92m06_004 from l_sql

  let l_sql =  ' update datkitarsrcaomtv set  '
              ,' (itarsrcaomtvdes,            '
              ,' dialimqtd,                   '
              ,' srvlimdat,                   '
              ,' sinatdflg,                   '
              ,' atlusrtip,                   '
              ,' atlemp,                      '
              ,' atlmat,                      '
              ,' atldat)                      '
              ,' = (?,?,?,?,?,?,?,?)          '
              ,' where itarsrcaomtvcod = ?    '
 prepare p_ctc92m06_005 from l_sql

 let l_sql =  '  select count(itarsrcaomtvcod) '
             ,'    from datkitarsrcaomtv       '
             ,'   where itarsrcaomtvcod = ?    '
 prepare p_ctc92m06_006 from l_sql
 declare c_ctc92m06_006 cursor for p_ctc92m06_006

 let l_sql =  '  delete datkitarsrcaomtv       '
             ,'   where itarsrcaomtvcod = ?    '
 prepare p_ctc92m06_007 from l_sql

 let l_sql = '  delete datrclisgmrsrcaomtv   '
            ,'  where  itarsrcaomtvcod = ?   '
 prepare p_ctc92m06_008 from l_sql

let m_ctc92m06_prepare = 'S'

end function

#===============================================================================
 function ctc92m06()
#===============================================================================
 define l_ret       smallint
 define m_cod_aux   like datksocntz.socntzcod
 define l_flag      smallint
 define l_index     smallint
 define l_count     smallint
 define m_confirma  char(1)

 let arr_aux = 1
 let l_index = 1

 if m_ctc92m06_prepare is null or
    m_ctc92m06_prepare <> 'S' then
    call ctc92m06_prepare()
 end if

 options delete key F2

 open window w_ctc92m06 at 6,2 with form 'ctc92m06'
 attribute(form line 1)

 message ' (F17)Abandona, (F1)Inclui, (F2)Exclui, (F7)Segmentos'


 #---------------------[ seleciona dados ]------------------------#
  open c_ctc92m06_002
  foreach c_ctc92m06_002 into ma_ctc92m06[l_index].mtv_cod
                            , ma_ctc92m06[l_index].mtv_des
                            , ma_ctc92m06[l_index].srvlimdat
                            , ma_ctc92m06[l_index].sinatdflg
                            , ma_ctc92m06[l_index].dialimqtd

     let l_index = l_index + 1

     if l_index > 500 then
         error " Limite excedido! Foram encontradas mais de 500 regras cadastradas!"
         exit foreach
      end if
  end foreach

  call set_count(l_index - 1)
  input array ma_ctc92m06 without defaults from s_ctc92m06.*
     #---------------------------------------------
      before row
     #---------------------------------------------
         let arr_aux = arr_curr()
         let scr_aux = scr_line()

         if fgl_lastkey() = fgl_keyval ("down")     or
            fgl_lastkey() = fgl_keyval ("return")   then
            if ma_ctc92m06[arr_aux].mtv_cod is null or
               ma_ctc92m06[arr_aux].mtv_cod = 0     then
               let m_operacao = 'i'
            end if
         end if

     #---------------------------------------------
       before insert
     #---------------------------------------------
         let m_operacao = 'i'
         initialize  ma_ctc92m06[arr_aux] to null
         display ma_ctc92m06[arr_aux].mtv_cod  to
                  s_ctc92m06[scr_aux].mtv_cod
         display ma_ctc92m06[arr_aux].mtv_des  to
                  s_ctc92m06[scr_aux].mtv_des

     #---------------------------------------------
      before field mtv_cod
     #---------------------------------------------
         display ma_ctc92m06[arr_aux].mtv_cod to s_ctc92m06[scr_aux].mtv_cod attribute(reverse)

         if ma_ctc92m06[arr_aux].mtv_cod is null and
            ma_ctc92m06[arr_aux].mtv_cod <> 0 then
            let m_operacao = 'i'
         else
            if m_operacao <> 'i'or
               m_operacao is null or
               m_operacao = ' ' then
               display ma_ctc92m06[arr_aux].* to s_ctc92m06[scr_aux].* attribute(reverse)
            end if

            let m_mtv_cod = ma_ctc92m06[arr_aux].mtv_cod

            if fgl_lastkey() <> fgl_keyval ("left")     or
               fgl_lastkey() <> fgl_keyval ("up")   then
               let m_cod_aux  = ma_ctc92m06[arr_aux].mtv_cod
            end if
         end if

         if m_operacao <> 'i' then
            call ctc92m06_dados_alteracao(ma_ctc92m06[arr_aux].mtv_cod)
         end if

     #---------------------------------------------
      after field mtv_cod
     #---------------------------------------------
         display ma_ctc92m06[arr_aux].mtv_cod to s_ctc92m06[scr_aux].mtv_cod
         display ma_ctc92m06[arr_aux].* to s_ctc92m06[scr_aux].*

         if fgl_lastkey() <> fgl_keyval ("left")   and
            fgl_lastkey() <> fgl_keyval ("up")   then
            if ma_ctc92m06[arr_aux].mtv_cod is null then
               error 'Codigo nao pode ser nulo!'
               next field mtv_cod
            end if

            let l_count = 0

           if m_operacao = 'i' then
              whenever error continue
              open c_ctc92m06_006 using ma_ctc92m06[arr_aux].mtv_cod
              fetch c_ctc92m06_006 into l_count
              whenever error stop

              if l_count > 0 then
                 error 'Este codigo ja esta cadastrado. Digite outro!'
                 next field mtv_cod
              end if

              let l_count = 0
           else
              display m_cod_aux to s_ctc92m06[scr_aux].mtv_cod
              let ma_ctc92m06[arr_aux].mtv_cod = m_cod_aux
           end if
         else
            display m_cod_aux to s_ctc92m06[scr_aux].mtv_cod
            let ma_ctc92m06[arr_aux].mtv_cod = m_cod_aux
            let m_operacao = ' '
         end if


     #---------------------------------------------
      before field mtv_des
     #---------------------------------------------
         display ma_ctc92m06[arr_aux].* to s_ctc92m06[scr_aux].*
         display ma_ctc92m06[arr_aux].mtv_des to s_ctc92m06[scr_aux].mtv_des attribute(reverse)
         let m_mtv_des = ma_ctc92m06[arr_aux].mtv_des

     #---------------------------------------------
      after field mtv_des
     #---------------------------------------------
         display ma_ctc92m06[arr_aux].mtv_des to s_ctc92m06[scr_aux].mtv_des

         if fgl_lastkey() <> fgl_keyval ("left") and
            fgl_lastkey() <> fgl_keyval ("up")   then
            if ma_ctc92m06[arr_aux].mtv_des is null or
               ma_ctc92m06[arr_aux].mtv_des = ' '   then
               error 'Digite a Descricao do Motivo'
               next field mtv_des
           end if
         end if

     #---------------------------------------------
      before field srvlimdat
     #---------------------------------------------
         display ma_ctc92m06[arr_aux].* to s_ctc92m06[scr_aux].*
         display ma_ctc92m06[arr_aux].srvlimdat to s_ctc92m06[scr_aux].srvlimdat attribute(reverse)
         let m_srvlimdat = ma_ctc92m06[arr_aux].srvlimdat
     #---------------------------------------------
      after field srvlimdat
     #---------------------------------------------
         display ma_ctc92m06[arr_aux].srvlimdat to s_ctc92m06[scr_aux].srvlimdat
         if fgl_lastkey() <> fgl_keyval ("left") and
            fgl_lastkey() <> fgl_keyval ("up")   then
            if ma_ctc92m06[arr_aux].srvlimdat is null or
               ma_ctc92m06[arr_aux].srvlimdat = ' '   then
               error 'Digite a Data de Corte'
               next field srvlimdat
            end if
         end if
     #---------------------------------------------
      before field sinatdflg
     #---------------------------------------------
         display ma_ctc92m06[arr_aux].* to s_ctc92m06[scr_aux].*
         display ma_ctc92m06[arr_aux].sinatdflg to s_ctc92m06[scr_aux].sinatdflg attribute(reverse)
         let m_sinatdflg = ma_ctc92m06[arr_aux].sinatdflg
     #---------------------------------------------
      after field sinatdflg
     #---------------------------------------------
         display ma_ctc92m06[arr_aux].sinatdflg to s_ctc92m06[scr_aux].sinatdflg
         if fgl_lastkey() <> fgl_keyval ("left") and
            fgl_lastkey() <> fgl_keyval ("up")   then
            if ma_ctc92m06[arr_aux].sinatdflg is null or
               ma_ctc92m06[arr_aux].sinatdflg = ' '   then
               error 'Digite <S>im ou <N>ao'
               next field sinatdflg
            end if
            if ma_ctc92m06[arr_aux].sinatdflg <> "S" and
               ma_ctc92m06[arr_aux].sinatdflg <> "N" then
               error 'Digite <S>im ou <N>ao'
               next field sinatdflg
            end if
         end if
     #---------------------------------------------
      before field dialimqtd
     #---------------------------------------------
         display ma_ctc92m06[arr_aux].dialimqtd to s_ctc92m06[scr_aux].dialimqtd attribute(reverse)
         let m_mtv_diaria = ma_ctc92m06[arr_aux].dialimqtd

     #---------------------------------------------
      after field dialimqtd
     #---------------------------------------------
         display ma_ctc92m06[arr_aux].dialimqtd to s_ctc92m06[scr_aux].dialimqtd

         if fgl_lastkey() <> fgl_keyval ("left")   and
            fgl_lastkey() <> fgl_keyval ("up")   then
            if ma_ctc92m06[arr_aux].dialimqtd is null then
               error 'Quantidade de Diaria(s) nao pode ser nula!'
               next field dialimqtd
            else
               if m_operacao = 'i' then

                 #---[insert]---#
                 execute p_ctc92m06_004 using ma_ctc92m06[arr_aux].mtv_cod
                                            , ma_ctc92m06[arr_aux].mtv_des
                                            , ma_ctc92m06[arr_aux].dialimqtd
                                            , ma_ctc92m06[arr_aux].srvlimdat
                                            , ma_ctc92m06[arr_aux].sinatdflg
                                            , g_issk.usrtip
                                            , g_issk.empcod
                                            , g_issk.funmat
                                            , 'today'
                  if sqlca.sqlcode = 0 then
                     error 'Dados Incluidos com Sucesso!'
                     let m_operacao = ' '
                  else
                     error 'ERRO(',sqlca.sqlcode,') na Insercao de Dados! AVISE A INFORMATICA!! (datkitarsrcaomtv)'
                  end if

               else
                  if m_mtv_cod     <>  ma_ctc92m06[arr_aux].mtv_cod    or
                     m_mtv_des     <>  ma_ctc92m06[arr_aux].mtv_des    or
                     m_srvlimdat   <>  ma_ctc92m06[arr_aux].srvlimdat  or
                     m_sinatdflg   <>  ma_ctc92m06[arr_aux].sinatdflg  or
                     m_mtv_diaria  <>  ma_ctc92m06[arr_aux].dialimqtd then

                      call cts08g01("A","S"
                            ,"CONFIRMA ALTERACAO"
                            ,"DO REGISTRO DE MOTIVO ?"
                            ," "
                            ," ")
                      returning m_confirma

                     if m_confirma = 'S' then
                        #---[update]---#
                        execute p_ctc92m06_005 using ma_ctc92m06[arr_aux].mtv_des
                                                   , ma_ctc92m06[arr_aux].dialimqtd
                                                   , ma_ctc92m06[arr_aux].srvlimdat
                                                   , ma_ctc92m06[arr_aux].sinatdflg
                                                   , g_issk.usrtip
                                                   , g_issk.empcod
                                                   , g_issk.funmat
                                                   , 'today'
                                                   , ma_ctc92m06[arr_aux].mtv_cod
                     else
                        let ma_ctc92m06[arr_aux].mtv_cod   = m_mtv_cod
                        let ma_ctc92m06[arr_aux].mtv_des   = m_mtv_des
                        let ma_ctc92m06[arr_aux].dialimqtd = m_mtv_diaria
                        let ma_ctc92m06[arr_aux].srvlimdat = m_srvlimdat
                        let ma_ctc92m06[arr_aux].sinatdflg = m_sinatdflg

                        display ma_ctc92m06[arr_aux].mtv_cod   to s_ctc92m06[scr_aux].mtv_cod
                        display ma_ctc92m06[arr_aux].mtv_des   to s_ctc92m06[scr_aux].mtv_des
                        display ma_ctc92m06[arr_aux].dialimqtd to s_ctc92m06[scr_aux].dialimqtd
                        display ma_ctc92m06[arr_aux].srvlimdat to s_ctc92m06[scr_aux].srvlimdat
                        display ma_ctc92m06[arr_aux].sinatdflg to s_ctc92m06[scr_aux].sinatdflg

                        error 'Alteracao Cancelada!'
                     end if

                     let m_operacao = ' '
                 end if
               end if
            end if
         end if

      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         let m_operacao = ' '
         exit input
      #---------------------------------------------
       on key (F7)
      #---------------------------------------------
          if ma_ctc92m06[arr_aux].mtv_cod is not null then
              call ctc91m26(ma_ctc92m06[arr_aux].mtv_cod,
                            ma_ctc92m06[arr_aux].mtv_des)
          end if


      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc92m06[arr_aux].mtv_cod  is null   then
            continue input
         else
            if not ctc92m06_delete(ma_ctc92m06[arr_aux].mtv_cod) then
                let l_flag = 1
                exit input
            end if
         end if

      #---------------------------------------------
       after row
      #---------------------------------------------
         if m_operacao <> 'i' then
            display ma_ctc92m06[arr_aux].* to s_ctc92m06[scr_aux].*
         end if

  end input

  close window w_ctc92m06

  if l_flag = 1 then
    call ctc92m06()
  end if

end function

#============================================
 function ctc92m06_dados_alteracao(l_cod)
#============================================
define l_cod char(4)
define l_usrtip  like datkitarsrcaomtv.atlusrtip

   initialize r_ctc92m06.* to null

   whenever error continue
   open c_ctc92m06_003 using l_cod

   fetch c_ctc92m06_003 into  r_ctc92m06.atlemp
                             ,r_ctc92m06.atlmat
                             ,r_ctc92m06.atldat
                             ,l_usrtip

    if sqlca.sqlcode <> 0  then
        whenever error stop
    end if

   call ctc92m06_func(r_ctc92m06.atlemp, r_ctc92m06.atlmat, l_usrtip)
        returning r_ctc92m06.funnom

   display by name  r_ctc92m06.atldat
                   ,r_ctc92m06.funnom

end function


#==============================================
 function ctc92m06_func(l_empcod, l_funmat, l_usrtip)
#==============================================

 define  l_empcod      like   datkitaasipln.atlemp
 define  l_funmat      like   datkitaasipln.atlmat
 define  l_funnom      char(100)
 define  l_usrtip      like datkitarsrcaomtv.atlusrtip

 whenever error continue
 open c_ctc92m06_001 using l_empcod,
                           l_funmat,
                           l_usrtip

 fetch c_ctc92m06_001 into l_funnom

   if sqlca.sqlcode = notfound then
    whenever error stop
    let l_funnom = '    '
 end if

 close c_ctc92m06_001
 return l_funnom

end function


#==============================================
 function ctc92m06_delete(l_cod)
#==============================================
define l_cod like datksocntz.socntzcod
define l_confirma char(1)


  call cts08g01("A","S"
               ,"CONFIRMA EXCLUSAO"
               ,"DO REGISTRO DE MOTIVO ?"
               ," "
               ," ")
     returning l_confirma

     if l_confirma = "S" then
        let m_operacao = 'd'

        whenever error continue
        execute p_ctc92m06_008 using l_cod
        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') delete, AVISE A INFORMATICA!! (datrclisgmrsrcaomtv)'
           return false
           whenever error stop
        end if
        whenever error continue
        execute p_ctc92m06_007 using l_cod

        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') delete, AVISE A INFORMATICA!! (datkitarsrcaomtv)'
           return false
           whenever error stop
        end if

        return true
     else
        error 'Exclusao Cancelada'
        return false
     end if

end function