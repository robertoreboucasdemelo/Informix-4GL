#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Central 24hs                                                #
# Modulo........: ctc97m03                                                    #
# Analista Resp.: Amilton Pinto                                               #
# PSI...........: PSI-2012-15798                                              #
# Objetivo......: Tela de cadastro de plano Assistencia                       #
#.............................................................................#
# Desenvolvimento: Amilton Pinto                                              #
# Liberacao......:                                                            #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
 globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define ma_ctc97m03 array[500] of record
        grpcod     like datkresitagrp.grpcod
       ,desnom     like datkresitagrp.desnom
       ,lmtgrp     like datrntzasipln.grpivcqtd
       ,nat_cod    like datksocntz.socntzcod
       ,nat_desc   like datksocntz.socntzdes
       ,limite     smallint
       ,lmtvlr     integer
 end record

 define param       record
        cod         like datkitaasipln.itaasiplncod   # codigo do Plano
      , descricao   like datkitaasipln.itaasiplndes   # descricao do Plano
 end record

   define r_ctc97m03 record
         atlemp     like datkitaasipln.atlemp
        ,atlmat     like datkitaasipln.atlmat
        ,atldat     like datkitaasipln.atldat
        ,funnom     like isskfunc.funnom
        end record

 define m_operacao  char(1)
 define arr_aux     smallint
 define scr_aux     smallint

 define  m_ctc97m03_prepare  smallint

#===============================================================================
 function ctc97m03_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select a.grpcod,b.desnom,a.grpivcqtd, '
            ,'a.socntzcod,c.socntzdes,a.ntzivcqtd,a.ntzvlr '
            ,'from datrntzasipln a, datkresitagrp b, datksocntz c '
            ,'where  '
            ,'a.grpcod = b.grpcod and  '
            ,'a.socntzcod = c.socntzcod and  '
            ,'asiplncod = ? '
 prepare p_ctc97m03_001 from l_sql
 declare c_ctc97m03_001 cursor for p_ctc97m03_001

 let l_sql = ' update datrntzasipln  '
           ,  '     set grpivcqtd =  ?   '
           ,  '     ,   ntzivcqtd =  ?   '
           ,  '     ,   ntzvlr    =  ?   '
           ,  '   where socntzcod =  ?   '
           ,  '     and grpcod    = ?    '
           ,  '     and asiplncod = ?    '
 prepare p_ctc97m03_002 from l_sql

 let l_sql = '   select atlemp              '
            ,'         ,atlmat              '
            ,'         ,atldat              '
            ,'         ,atlusrtip           '
            ,'     from datritaasiplnnat '     # porto@u07:datkitaempasi
            ,'    where socntzcod  =  ?     '
            ,'      and itaasiplncod = ?    '
 prepare p_ctc97m03_003 from l_sql
 declare c_ctc97m03_003 cursor for p_ctc97m03_003

  let l_sql = '   select count(grpcod)        '
            , '     from datrntzasipln     '
            , '    where grpcod = ?           '
            , '      and asiplncod = ?        '
 prepare p_ctc97m03_004 from l_sql
 declare c_ctc97m03_004 cursor for p_ctc97m03_004

 let l_sql = '   select desnom          '
            , '     from datkresitagrp        '
            , '    where grpcod = ?     '
 prepare p_ctc97m03_005 from l_sql
 declare c_ctc97m03_005 cursor for p_ctc97m03_005

 let l_sql =  ' insert into datrntzasipln   '
           ,  '   (socntzcod                   '
           ,  '   ,grpcod                      '
           ,  '   ,asiplncod                   '
           ,  '   ,grpivcqtd                   '
           ,  '   ,ntzvlr                      '
           ,  '   ,ntzivcqtd )                 '
           ,  ' values(?,?,?,?,?,?)             '
 prepare p_ctc97m03_006 from l_sql

  let l_sql = '   select count(grpcod)   '
            , '     from datkresitagrp         '
            , '    where grpcod = ?      '
 prepare p_ctc97m03_007 from l_sql
 declare c_ctc97m03_007 cursor for p_ctc97m03_007

 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc97m03_008 from l_sql
 declare c_ctc97m03_008 cursor for p_ctc97m03_008

 let l_sql = '  delete datrntzasipln    '
          ,  '   where socntzcod = ?               '
          ,  '     and asiplncod = ?               '
          ,  '     and grpcod    = ?               '
  prepare p_ctc97m03_009 from l_sql

 let l_sql = '   select count(socntzcod)   '
            , '     from datksocntz        '
            , '    where socntzcod = ?      '
 prepare p_ctc97m03_010 from l_sql
 declare c_ctc97m03_010 cursor for p_ctc97m03_010

  let l_sql = '   select count(grpcod)        '
            , '    from datrntzasipln     '
            , '    where grpcod = ?           '
            , '    and socntzcod = ?          '
            , '    and asiplncod = ?       '
 prepare p_ctc97m03_011 from l_sql
 declare c_ctc97m03_011 cursor for p_ctc97m03_011

  let l_sql = '   select socntzdes          '
           , '     from datksocntz        '
           , '    where socntzcod = ?     '
  prepare p_ctc97m03_012 from l_sql
  declare c_ctc97m03_012 cursor for p_ctc97m03_012

  let l_sql =  ' insert into datrntzgrp   '
            ,  '   (socntzcod                   '
            ,  '   ,grpcod )                      '
            ,  ' values(?,?)             '
  prepare p_ctc97m03_013 from l_sql

  let l_sql = '  delete datrntzgrp    '
           ,  '   where socntzcod = ? '
           ,  '     and grpcod    = ? '
  prepare p_ctc97m03_014 from l_sql

  let l_sql = '  select count(*) from datrntzgrp    '
           ,  '   where socntzcod = ? '
           ,  '     and grpcod    = ? '
  prepare p_ctc97m03_015 from l_sql
  declare c_ctc97m03_015 cursor for p_ctc97m03_015

let m_ctc97m03_prepare = true

end function

#===============================================================================
 function ctc97m03(l_cod, l_descricao)
#===============================================================================
 define l_cod       like datkitaasipln.itaasiplncod   # codigo do Plano
 define l_descricao like datkitaasipln.itaasiplndes   # Descricao do Plano
 define l_ret       smallint
 define m_cod_aux   like datksocntz.socntzcod
 define l_flag      smallint
 define l_count     smallint

 let param.cod = l_cod
 let param.descricao = l_descricao

 let arr_aux = 1
 let l_count = 0

 if m_ctc97m03_prepare is null or
    m_ctc97m03_prepare <> true then
    call ctc97m03_prepare()
 end if

 options delete key F2

 open window w_ctc97m03 at 6,2 with form 'ctc97m03'
 attribute(form line 1)

 message ' (F17)Abandona, (F1)Inclui, (F2)Exclui, (F8)Assunto'

  display by name param.cod
                , param.descricao

 #---------------[ seleciona dados ]----------------#
  open c_ctc97m03_001  using param.cod
  foreach c_ctc97m03_001 into ma_ctc97m03[arr_aux].grpcod
                            , ma_ctc97m03[arr_aux].desnom
                            , ma_ctc97m03[arr_aux].lmtgrp
                            , ma_ctc97m03[arr_aux].nat_cod
                            , ma_ctc97m03[arr_aux].nat_desc
                            , ma_ctc97m03[arr_aux].limite
                            , ma_ctc97m03[arr_aux].lmtvlr

       let arr_aux = arr_aux + 1

       if arr_aux > 500 then
          error " Limite excedido! Foram encontrados mais de 500 empresas!"
          exit foreach
       end if

  end foreach
  #--------------------------------------------------#

  if arr_aux = 1  then
       error "Nao foi encontrado nenhum registro, inclua novos!"
    end if

 let m_operacao = " "

 call set_count(arr_aux - 1 )

 input array ma_ctc97m03 without defaults from s_ctc97m03.*
      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
             if ma_ctc97m03[arr_aux].grpcod is null or
                ma_ctc97m03[arr_aux].grpcod = 0     then
                let m_operacao = 'i'
             end if
          end if

      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'
         initialize  ma_ctc97m03[arr_aux] to null
         display ma_ctc97m03[arr_aux].grpcod        to
                  s_ctc97m03[scr_aux].grpcod
         display ma_ctc97m03[arr_aux].desnom  to
                  s_ctc97m03[scr_aux].desnom

      #---------------------------------------------






       before field grpcod
      #---------------------------------------------
         if ma_ctc97m03[arr_aux].grpcod is null then
            display ma_ctc97m03[arr_aux].grpcod to s_ctc97m03[scr_aux].grpcod attribute(reverse)
            let m_operacao = 'i'
         else
           let m_cod_aux  = ma_ctc97m03[arr_aux].grpcod
           display ma_ctc97m03[arr_aux].* to s_ctc97m03[scr_aux].* attribute(reverse)
         end if

         if m_operacao <> 'i' then
            call ctc97m03_dados_alteracao(ma_ctc97m03[arr_aux].grpcod)
         end if

      #---------------------------------------------
       after field grpcod
      #---------------------------------------------
         if fgl_lastkey() = fgl_keyval ("down")     or
            fgl_lastkey() = fgl_keyval ("return")   then

            if m_operacao = 'i' then
               if ma_ctc97m03[arr_aux].grpcod is null then
                   if fgl_lastkey() = fgl_keyval ("down")   or
                      fgl_lastkey() = fgl_keyval ("return")     then
                      call cto00m10_popup(22)
                         returning ma_ctc97m03[arr_aux].grpcod
                                 , ma_ctc97m03[arr_aux].desnom

                         display ma_ctc97m03[arr_aux].grpcod to s_ctc97m03[scr_aux].grpcod
                         display ma_ctc97m03[arr_aux].desnom to s_ctc97m03[scr_aux].desnom

                        #--------[ verifica se grupo existe ]---------#
                        let l_ret = 0

                        open c_ctc97m03_007 using ma_ctc97m03[arr_aux].grpcod
                        fetch c_ctc97m03_007 into l_ret

                        if l_ret < 1 then
                           error 'Codigo de grupo nao existe!'
                           next field grpcod
                        end if

                        #---------[ verifica codigo duplicado ]----------#
                        let l_ret = 0

                        #if ma_ctc97m03[arr_aux].grpcod <> 999 then
                        #   open c_ctc97m03_004 using ma_ctc97m03[arr_aux].grpcod
                        #                           , param.cod
                        #   fetch c_ctc97m03_004 into l_ret
                        #
                        #   if l_ret > 0  then
                        #      error 'Esse Codigo ja esta cadastrado!'
                        #      next field nat_cod
                        #   end if
                        #end if
                   else
                      let m_operacao = ' '
                   end if
               else

                  #--------[ verifica se grupo existe ]---------#
                  let l_ret = 0

                  open c_ctc97m03_007 using ma_ctc97m03[arr_aux].grpcod
                  fetch c_ctc97m03_007 into l_ret

                  if l_ret < 1 then
                     error 'Codigo de Natureza nao existe!'
                     next field nat_cod
                  end if

                  #---------[ verifica codigo duplicado ]----------#
                  let l_ret = 0

                  if ma_ctc97m03[arr_aux].nat_cod <> 999 then
                     open c_ctc97m03_004 using ma_ctc97m03[arr_aux].nat_cod
                                             , param.cod
                     fetch c_ctc97m03_004 into l_ret

                     if l_ret > 0  then
                        error 'Esse Codigo ja esta cadastrado!'
                        next field nat_cod
                     end if
                  end if

                   #--------[ seleciona descricao ]--------#
                   open c_ctc97m03_005 using ma_ctc97m03[arr_aux].grpcod
                   fetch c_ctc97m03_005 into ma_ctc97m03[arr_aux].desnom

                   display ma_ctc97m03[arr_aux].grpcod to s_ctc97m03[scr_aux].grpcod
                   display ma_ctc97m03[arr_aux].desnom to s_ctc97m03[scr_aux].desnom
                  #---------------------------------------#
               end if


            else
              let ma_ctc97m03[arr_aux].grpcod = m_cod_aux
              display ma_ctc97m03[arr_aux].* to s_ctc97m03[scr_aux].*
            end if

         else
           if m_operacao = 'i' then
              let ma_ctc97m03[arr_aux].grpcod = ''
              display ma_ctc97m03[arr_aux].* to s_ctc97m03[scr_aux].*
              let m_operacao = ' '
           else
              let ma_ctc97m03[arr_aux].grpcod = m_cod_aux
              display ma_ctc97m03[arr_aux].* to s_ctc97m03[scr_aux].*
           end if

         end if


      #---------------------------------------------
       before field desnom
      #---------------------------------------------
         display ma_ctc97m03[arr_aux].desnom to s_ctc97m03[scr_aux].desnom
         next field lmtgrp

      #---------------------------------------------
       before field lmtgrp
      #---------------------------------------------
         display ma_ctc97m03[arr_aux].lmtgrp to s_ctc97m03[scr_aux].lmtgrp attribute(reverse)

         if ma_ctc97m03[arr_aux].grpcod is null then
            display ' ' to s_ctc97m03[scr_aux].lmtgrp
            next field grpcod
         end if


      #---------------------------------------------
       after field lmtgrp
      #---------------------------------------------

         if fgl_lastkey() = fgl_keyval ("down")     or
            fgl_lastkey() = fgl_keyval ("return")   then

            if ma_ctc97m03[arr_aux].lmtgrp is null then
               error 'Limite grupo nao pode ser nulo!'
               next field limite
            end if
         end if

         display ma_ctc97m03[arr_aux].lmtgrp to s_ctc97m03[scr_aux].lmtgrp

      #---------------------------------------------
       before field nat_cod
      #---------------------------------------------
         if ma_ctc97m03[arr_aux].nat_cod is null then
            display ma_ctc97m03[arr_aux].nat_cod to s_ctc97m03[scr_aux].nat_cod attribute(reverse)
            let m_operacao = 'i'
         else
           let m_cod_aux  = ma_ctc97m03[arr_aux].nat_cod
           display ma_ctc97m03[arr_aux].* to s_ctc97m03[scr_aux].* attribute(reverse)
         end if

         if m_operacao <> 'i' then
            call ctc97m03_dados_alteracao(ma_ctc97m03[arr_aux].nat_cod)
         end if

      #---------------------------------------------
       after field nat_cod
      #---------------------------------------------
         if fgl_lastkey() = fgl_keyval ("down")     or
            fgl_lastkey() = fgl_keyval ("return")   then

            if m_operacao = 'i' then
               if ma_ctc97m03[arr_aux].nat_cod is null then
                   if fgl_lastkey() = fgl_keyval ("down")   or
                      fgl_lastkey() = fgl_keyval ("return")     then
                      call cto00m10_popup(16)
                         returning ma_ctc97m03[arr_aux].nat_cod
                                 , ma_ctc97m03[arr_aux].nat_desc

                         display ma_ctc97m03[arr_aux].nat_cod  to s_ctc97m03[scr_aux].nat_cod
                         display ma_ctc97m03[arr_aux].nat_desc to s_ctc97m03[scr_aux].nat_desc

                        #--------[ verifica se natureza existe ]---------#
                        let l_ret = 0

                        open c_ctc97m03_010 using ma_ctc97m03[arr_aux].nat_cod
                        fetch c_ctc97m03_010 into l_ret

                        if l_ret < 1 then
                           error 'Codigo de natureza nao existe!'
                           next field grpcod
                        end if

                        #---------[ verifica codigo duplicado ]----------#
                        let l_ret = 0

                           open c_ctc97m03_011 using ma_ctc97m03[arr_aux].grpcod,
                                                     ma_ctc97m03[arr_aux].nat_cod,
                                                     param.cod
                           fetch c_ctc97m03_011 into l_ret

                           if l_ret > 0  then
                              error 'Esse Codigo ja esta cadastrado!'
                              next field nat_cod
                           end if
                   else
                      let m_operacao = ' '
                   end if
               else

                  #--------[ verifica se natureza existe ]---------#
                  let l_ret = 0

                  open c_ctc97m03_010 using ma_ctc97m03[arr_aux].nat_cod
                  fetch c_ctc97m03_010 into l_ret

                  if l_ret < 1 then
                     error 'Codigo de Natureza nao existe!'
                     next field nat_cod
                  end if

                  #---------[ verifica codigo duplicado ]----------#
                  let l_ret = 0

                  if ma_ctc97m03[arr_aux].nat_cod <> 999 then
                     open c_ctc97m03_011 using ma_ctc97m03[arr_aux].grpcod,
                                               ma_ctc97m03[arr_aux].nat_cod,
                                               param.cod
                     fetch c_ctc97m03_011 into l_ret

                     if l_ret > 0  then
                        error 'Esse Codigo ja esta cadastrado!'
                        next field nat_cod
                     end if
                   end if
                   #--------[ seleciona descricao ]--------#
                   open c_ctc97m03_012 using ma_ctc97m03[arr_aux].nat_cod
                   fetch c_ctc97m03_012 into ma_ctc97m03[arr_aux].nat_desc

                   display ma_ctc97m03[arr_aux].nat_cod to s_ctc97m03[scr_aux].nat_cod
                   display ma_ctc97m03[arr_aux].nat_desc to s_ctc97m03[scr_aux].nat_desc
                  #---------------------------------------#
               end if

            else
              let ma_ctc97m03[arr_aux].nat_cod = m_cod_aux
              display ma_ctc97m03[arr_aux].* to s_ctc97m03[scr_aux].*
            end if

         else
           if m_operacao = 'i' then
              let ma_ctc97m03[arr_aux].nat_cod = ''
              display ma_ctc97m03[arr_aux].* to s_ctc97m03[scr_aux].*
              let m_operacao = ' '
           else
              let ma_ctc97m03[arr_aux].nat_cod = m_cod_aux
              display ma_ctc97m03[arr_aux].* to s_ctc97m03[scr_aux].*
           end if

         end if

      #---------------------------------------------
       before field nat_desc
      #---------------------------------------------
           display ma_ctc97m03[arr_aux].nat_desc to s_ctc97m03[scr_aux].nat_desc
         next field limite

      #---------------------------------------------
       before field limite
      #---------------------------------------------
         display ma_ctc97m03[arr_aux].limite to s_ctc97m03[scr_aux].limite attribute(reverse)

         if ma_ctc97m03[arr_aux].nat_cod is null then
            display ' ' to s_ctc97m03[scr_aux].limite
            next field nat_cod
         end if


      #---------------------------------------------
       after field limite
      #---------------------------------------------

         if fgl_lastkey() = fgl_keyval ("down")     or
            fgl_lastkey() = fgl_keyval ("return")   then

            if ma_ctc97m03[arr_aux].limite is null then
               error 'Limite grupo nao pode ser nulo!'
               next field limite
            end if
         end if
       display ma_ctc97m03[arr_aux].limite to s_ctc97m03[scr_aux].limite
      #---------------------------------------------
       before field lmtvlr
      #---------------------------------------------
         display ma_ctc97m03[arr_aux].lmtvlr to s_ctc97m03[scr_aux].lmtvlr attribute(reverse)

         if ma_ctc97m03[arr_aux].nat_cod is null then
            display ' ' to s_ctc97m03[scr_aux].lmtvlr
            next field nat_cod
         end if


      #---------------------------------------------
       after field lmtvlr
      #---------------------------------------------

         if fgl_lastkey() = fgl_keyval ("down")     or
            fgl_lastkey() = fgl_keyval ("return")   then

            if ma_ctc97m03[arr_aux].lmtvlr is null then
               error 'Limite grupo nao pode ser nulo!'
               next field limite
            end if
         end if

         if m_operacao <> 'i' then
           # -------- [ update de limite ] -------- #
            execute p_ctc97m03_002 using ma_ctc97m03[arr_aux].lmtgrp
                                        , ma_ctc97m03[arr_aux].limite
                                        , ma_ctc97m03[arr_aux].lmtvlr
                                        , ma_ctc97m03[arr_aux].nat_cod
                                        , ma_ctc97m03[arr_aux].grpcod
                                        , param.cod
            let m_operacao = ' '
         else
           # -------- [ grava dados novos] -------- #
           whenever error continue
           open c_ctc97m03_015 using ma_ctc97m03[arr_aux].nat_cod,
                                     ma_ctc97m03[arr_aux].grpcod
           fetch c_ctc97m03_015 into l_count
           whenever error stop

           if l_count = 0 then
             whenever error continue
             execute p_ctc97m03_013 using ma_ctc97m03[arr_aux].nat_cod,
                                          ma_ctc97m03[arr_aux].grpcod
             whenever error stop
           end if

           execute p_ctc97m03_006 using ma_ctc97m03[arr_aux].nat_cod
                                       ,ma_ctc97m03[arr_aux].grpcod
                                       ,param.cod
                                       ,ma_ctc97m03[arr_aux].lmtgrp
                                       ,ma_ctc97m03[arr_aux].lmtvlr
                                       ,ma_ctc97m03[arr_aux].limite


            if sqlca.sqlcode = 0 then
               error 'Dados Incluidos com Sucesso!'
               let m_operacao = ' '
            else
               error 'ERRO(',sqlca.sqlcode,') na Insercao de Dados! AVISE A INFORMATICA!! (datritaasiplnnat)'
            end if

         end if

         display ma_ctc97m03[arr_aux].lmtvlr to s_ctc97m03[scr_aux].lmtvlr

      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input
      #---------------------------------------------
       on key (F8)
      #---------------------------------------------
         if ma_ctc97m03[arr_aux].nat_cod is not null then
             call ctc97m05(l_cod                         ,
                           l_descricao                   ,
                           ma_ctc97m03[arr_aux].grpcod   ,
                           ma_ctc97m03[arr_aux].desnom   ,
                           ma_ctc97m03[arr_aux].nat_cod  ,
                           ma_ctc97m03[arr_aux].nat_desc )
         end if

      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc97m03[arr_aux].grpcod is null   then
            continue input
         else
            if not ctc97m03_delete(ma_ctc97m03[arr_aux].grpcod,
                                   ma_ctc97m03[arr_aux].nat_cod,
                                   param.cod) then
                let l_flag = 1
                exit input
            end if
         end if

  end input

 close window w_ctc97m03

 if l_flag = 1 then
    call ctc97m03(param.*)
 end if


end function

#============================================
 function ctc97m03_dados_alteracao(l_cod)
#============================================
define l_cod char(4)
define l_usrtip  like datritaasiplnnat.atlusrtip

   initialize r_ctc97m03.* to null

   whenever error continue
   open c_ctc97m03_003 using l_cod
                           , param.cod
   fetch c_ctc97m03_003 into  r_ctc97m03.atlemp
                             ,r_ctc97m03.atlmat
                             ,r_ctc97m03.atldat
                             ,l_usrtip

    if sqlca.sqlcode <> 0  then
        whenever error stop
    end if

   call ctc97m03_func(r_ctc97m03.atlemp, r_ctc97m03.atlmat, l_usrtip)
        returning r_ctc97m03.funnom

   display by name  r_ctc97m03.atldat
                   ,r_ctc97m03.funnom

end function


#==============================================
 function ctc97m03_func(l_empcod, l_funmat, l_usrtip)
#==============================================

 define  l_empcod      like   datkitaasipln.atlemp
 define  l_funmat      like   datkitaasipln.atlmat
 define  l_funnom      char(100)
 define  l_usrtip      like datritaasiplnnat.atlusrtip

 whenever error continue
 open c_ctc97m03_008 using l_empcod,
                           l_funmat,
                           l_usrtip

 fetch c_ctc97m03_008 into l_funnom

   if sqlca.sqlcode = notfound then
    whenever error stop
    let l_funnom = '    '
 end if

 close c_ctc97m03_008
 return l_funnom

end function


#==============================================
 function ctc97m03_delete(lr_param)
#==============================================


define lr_param record
       grpcod     like datrntzasipln.grpcod
      ,nat_cod    like datrntzasipln.socntzcod
      ,cod        like datrntzasipln.asiplncod
end record

define l_confirma char(1)
define l_count smallint

let l_count = 0


  call cts08g01("A","S"
               ,"CONFIRMA EXCLUSAO"
               ,"DO REGISTRO DE LIMITE "
               ,"DE NATUREZA ?"
               ," ")
     returning l_confirma

     if l_confirma = "S" then
        let m_operacao = 'd'


        whenever error continue
        open c_ctc97m03_015 using lr_param.nat_cod,
                                  lr_param.grpcod
        fetch c_ctc97m03_015 into l_count
        whenever error stop

        if l_count > 0 then
            whenever error continue
            execute p_ctc97m03_009 using lr_param.nat_cod
                                        ,lr_param.cod
                                        ,lr_param.grpcod

            if sqlca.sqlcode <> 0 then
               error 'ERRO (',sqlca.sqlcode,') delete, AVISE A INFORMATICA!! (datritaasiplnnat)'
               return false
               whenever error stop
            end if
         end if

        return true
     else
        return false
     end if

end function