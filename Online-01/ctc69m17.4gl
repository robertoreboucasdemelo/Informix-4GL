#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m17                                                   #
# Objetivo.......: Cadastro Classe Localizacao X Cidade                       #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 28/08/2013                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m17 array[500] of record
      cidcod    like datkrtcece.cidcod
    , cidnom    char(60)
    , ufdcod    char(02)
    , rtcececod like datkrtcece.rtcececod
end record

define mr_param   record
       lclclartccod  like datkrtcece.lclclartccod
     , clscod        like datkplncls.clscod
     , clsnom        char(60)
     , srvcod        like datksrv.srvcod
     , srvnom        like datksrv.srvnom
     , lclclacod     like datklclclartc.lclclacod
     , clalcldes     char(60)
     , codufd        char(02)
end record

define mr_ctc69m17 record
      empcod        like datkrtcece.empcod
     ,usrmatnum     like datkrtcece.usrmatnum
     ,regatldat     like datkrtcece.regatldat
     ,funnom        like isskfunc.funnom
     ,usrtipcod     like datkrtcece.usrtipcod
end record


define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_cod_aux   like datkrtcece.cidcod

define  m_prepare  smallint

#===============================================================================
 function ctc69m17_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select a.rtcececod           '
          ,  '      , a.cidcod              '
          ,  '      , b.cidnom              '
          ,  '      , b.ufdcod              '
          ,  '   from datkrtcece a,         '
          ,  '        glakcid b             '
          ,  '  where a.cidcod  = b.cidcod  '
          ,  '  and   a.lclclartccod = ?    '
          ,  '  order by a.cidcod           '
 prepare p_ctc69m17_001 from l_sql
 declare c_ctc69m17_001 cursor for p_ctc69m17_001

 let l_sql = ' select count(*)         '
          ,  '   from datkrtcece       '
          ,  '  where cidcod       = ? '
          ,  '   and  lclclartccod = ? '
 prepare p_ctc69m17_002 from l_sql
 declare c_ctc69m17_002 cursor for p_ctc69m17_002


 let l_sql =  ' insert into datkrtcece   '
           ,  '   (lclclartccod          '
           ,  '   ,cidcod                '
           ,  '   ,usrtipcod             '
           ,  '   ,empcod                '
           ,  '   ,usrmatnum             '
           ,  '   ,regatldat)            '
           ,  ' values(?,?,?,?,?,?)      '
 prepare p_ctc69m17_004 from l_sql


 let l_sql = '   select empcod           '
            ,'         ,usrmatnum        '
            ,'         ,regatldat        '
            ,'         ,usrtipcod        '
            ,'     from datkrtcece       '
            ,'    where rtcececod   =  ? '
 prepare p_ctc69m17_005    from l_sql
 declare c_ctc69m17_005 cursor for p_ctc69m17_005


 let l_sql = '  delete datkrtcece    '
         ,  '   where rtcececod  =  ?  '
 prepare p_ctc69m17_006 from l_sql


 let l_sql = '   select rtcececod          '
            ,'    from datkrtcece          '
            ,'    where lclclartccod =  ?  '
            ,'    and   cidcod       =  ?  '
 prepare p_ctc69m17_007    from l_sql
 declare c_ctc69m17_007 cursor for p_ctc69m17_007



 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc69m17_008 from l_sql
 declare c_ctc69m17_008 cursor for p_ctc69m17_008


 let m_prepare = true


end function

#===============================================================================
 function ctc69m17(lr_param)
#===============================================================================

define lr_param record
    lclclartccod  like datkrtcece.lclclartccod,
    clscod        like datkplncls.clscod      ,
    clsnom        char(60)                    ,
    srvcod        like datksrv.srvcod         ,
    srvnom        like datksrv.srvnom         ,
    lclclacod     like datklclclartc.lclclacod,
    clalcldes     char(60)                    ,
    codufd        char(02)
end record

define lr_retorno record
    flag                smallint ,
    cont                integer  ,
    cidnom              char(60) ,
    confirma            char(01)
end record

 let mr_param.lclclartccod = lr_param.lclclartccod
 let mr_param.clscod       = lr_param.clscod
 let mr_param.clsnom       = lr_param.clsnom
 let mr_param.srvcod       = lr_param.srvcod
 let mr_param.srvnom       = lr_param.srvnom
 let mr_param.lclclacod    = lr_param.lclclacod
 let mr_param.clalcldes    = lr_param.clalcldes
 let mr_param.codufd       = lr_param.codufd

 for  arr_aux  =  1  to  500
    initialize  ma_ctc69m17[arr_aux].* to  null
 end  for


 initialize mr_ctc69m17.*, lr_retorno.* to null

 let arr_aux = 1

 if m_prepare is null or
    m_prepare <> true then
    call ctc69m17_prepare()
 end if



 open window w_ctc69m17 at 6,2 with form 'ctc69m17'
 attribute(form line 1)

 message ' (F17)Abandona, (F1)Inclui, (F2) Exclui '

  display by name mr_param.clscod
                , mr_param.clsnom
                , mr_param.srvcod
                , mr_param.srvnom
                , mr_param.lclclacod
                , mr_param.clalcldes
                , mr_param.codufd


  #--------------------------------------------------------
  # Recupera os Dados da Cidade
  #--------------------------------------------------------

  open c_ctc69m17_001  using  mr_param.lclclartccod
  foreach c_ctc69m17_001 into ma_ctc69m17[arr_aux].rtcececod
  	                        , ma_ctc69m17[arr_aux].cidcod
                            , ma_ctc69m17[arr_aux].cidnom
                            , ma_ctc69m17[arr_aux].ufdcod


       let arr_aux = arr_aux + 1

       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontradas Mais de 500 Cidades!"
          exit foreach
       end if

  end foreach


  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if

 let m_operacao = " "

 call set_count(arr_aux - 1 )

 input array ma_ctc69m17 without defaults from s_ctc69m17.*

      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then

             if ma_ctc69m17[arr_aux].cidcod  is null then
                let m_operacao = 'i'
             end if

          end if


      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'

         initialize  ma_ctc69m17[arr_aux] to null

         display ma_ctc69m17[arr_aux].cidcod   to s_ctc69m17[scr_aux].cidcod


      #---------------------------------------------
       before field cidcod
      #---------------------------------------------

        if ma_ctc69m17[arr_aux].cidcod  is null then
           display ma_ctc69m17[arr_aux].cidcod  to s_ctc69m17[scr_aux].cidcod  attribute(reverse)
           let m_operacao = 'i'
        else
        	let m_cod_aux  = ma_ctc69m17[arr_aux].cidcod
          display ma_ctc69m17[arr_aux].* to s_ctc69m17[scr_aux].* attribute(reverse)
          display ""  to s_ctc69m17[scr_aux].rtcececod
        end if


        if m_operacao <> 'i' then
           call ctc69m17_dados_alteracao(ma_ctc69m17[arr_aux].rtcececod)
        end if

      #---------------------------------------------
       after field cidcod
      #---------------------------------------------

        if fgl_lastkey() = fgl_keyval ("down")     or
           fgl_lastkey() = fgl_keyval ("return")   then
           if m_operacao = 'i' then

           	if ma_ctc69m17[arr_aux].cidcod  is null then

           		 #--------------------------------------------------------
           		 # Abre a Tela de Pesquisa da Cidade
           		 #--------------------------------------------------------

           		 call cts06g04(ma_ctc69m17[arr_aux].cidnom, mr_param.codufd)
           		 returning ma_ctc69m17[arr_aux].cidcod
           		         , ma_ctc69m17[arr_aux].cidnom
           		         , ma_ctc69m17[arr_aux].ufdcod

           		 if ma_ctc69m17[arr_aux].cidcod  is null then
           		    next field cidcod
           		 end if
           	else

           		#--------------------------------------------------------
           		# Recupera a Descricao da Cidade
           		#--------------------------------------------------------

           		call ctc69m04_recupera_descricao_4(11,ma_ctc69m17[arr_aux].cidcod )
           		returning ma_ctc69m17[arr_aux].cidnom
           		        , ma_ctc69m17[arr_aux].ufdcod

           		if ma_ctc69m17[arr_aux].cidnom is null then
           		   next field cidcod
           		end if

             end if

             #--------------------------------------------------------
             # Valida se a Cidade Ja Foi Cadastrada
             #--------------------------------------------------------

             open c_ctc69m17_002 using ma_ctc69m17[arr_aux].cidcod  ,
                                       mr_param.lclclartccod
             whenever error continue
             fetch c_ctc69m17_002 into lr_retorno.cont
             whenever error stop

             if lr_retorno.cont >  0   then
                error " Associacao ja Cadastrada!"
                next field cidcod
             end if

             display ma_ctc69m17[arr_aux].cidcod  to s_ctc69m17[scr_aux].cidcod
             display ma_ctc69m17[arr_aux].cidnom  to s_ctc69m17[scr_aux].cidnom
             display ma_ctc69m17[arr_aux].ufdcod  to s_ctc69m17[scr_aux].ufdcod

             #--------------------------------------------------------
             # Inclui a Cidade
             #--------------------------------------------------------
             call ctc69m17_inclui()

             #--------------------------------------------------------
             # Recupera a Serial da Cidade
             #--------------------------------------------------------
             call ctc69m17_recupera_chave()

             next field cidcod
           else
           	let ma_ctc69m17[arr_aux].cidcod = m_cod_aux
          	display ma_ctc69m17[arr_aux].* to s_ctc69m17[scr_aux].*
          end if
       else
        	 if m_operacao = 'i' then
        	    let ma_ctc69m17[arr_aux].cidcod = ''
        	    display ma_ctc69m17[arr_aux].* to s_ctc69m17[scr_aux].*
        	    let m_operacao = ' '
        	 else
        	    let ma_ctc69m17[arr_aux].cidcod = m_cod_aux
        	    display ma_ctc69m17[arr_aux].* to s_ctc69m17[scr_aux].*
        	 end if
       end if


      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------

         exit input


      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc69m17[arr_aux].rtcececod  is null   then
            continue input
         else

            #--------------------------------------------------------
            # Valida se a Cidade Pode Ser Excluida
            #--------------------------------------------------------

            if ctc69m06_valida_exclusao() then

               #--------------------------------------------------------
               # Exclui a Cidade
               #--------------------------------------------------------

               if not ctc69m17_delete(ma_ctc69m17[arr_aux].rtcececod) then
                   let lr_retorno.flag = 1
                   exit input
               end if



            else
            	 let lr_retorno.flag = 1
            	 exit input
            end if

            next field cidcod

         end if


  end input

 close window w_ctc69m17

 if lr_retorno.flag = 1 then
    call ctc69m17(mr_param.*)
 end if


end function


#---------------------------------------------------------
 function ctc69m17_func(lr_param)
#---------------------------------------------------------

 define lr_param  record
    funmat       like isskfunc.funmat,
    empcod       like isskfunc.empcod,
    usrtipcod    like isskfunc.usrtip
 end record

 define lr_retorno record
    funnom   like isskfunc.funnom
 end record

if m_prepare is null or
  m_prepare <> true then
  call ctc69m17_prepare()
end if

 initialize lr_retorno.*    to null

   if lr_param.empcod is null or
      lr_param.empcod = " " then

      let lr_param.empcod = 1

   end if

   #--------------------------------------------------------
   # Recupera os Dados do Funcionario
   #--------------------------------------------------------

   open c_ctc69m17_008 using lr_param.empcod ,
                             lr_param.funmat ,
                             lr_param.usrtipcod
   whenever error continue
   fetch c_ctc69m17_008 into lr_retorno.funnom
   whenever error stop

 return lr_retorno.funnom

 end function


#---------------------------------------------------------
 function ctc69m17_dados_alteracao(lr_param)
#---------------------------------------------------------

define lr_param record
	rtcececod like datkrtcece.rtcececod
end record


   initialize mr_ctc69m17.* to null


   open c_ctc69m17_005 using lr_param.rtcececod

   whenever error continue
   fetch c_ctc69m17_005 into  mr_ctc69m17.empcod
                             ,mr_ctc69m17.usrmatnum
                             ,mr_ctc69m17.regatldat
                             ,mr_ctc69m17.usrtipcod

   whenever error stop


   call ctc69m17_func(mr_ctc69m17.usrmatnum, mr_ctc69m17.empcod, mr_ctc69m17.usrtipcod)
   returning mr_ctc69m17.funnom

   display by name  mr_ctc69m17.regatldat
                   ,mr_ctc69m17.funnom

end function

#==============================================
 function ctc69m17_delete(lr_param)
#==============================================

define lr_param record
	rtcececod   like datkrtcece.rtcececod
end record

define lr_retorno record
	confirma char(1)
end record

initialize lr_retorno.* to null

  call cts08g01("A","S"
               ,"CONFIRMA EXCLUSAO"
               ,"DO CODIGO "
               ,"DA CIDADE ?"
               ," ")
     returning lr_retorno.confirma

     if lr_retorno.confirma  = "S" then
        let m_operacao = 'd'

        whenever error continue
        execute p_ctc69m17_006 using lr_param.rtcececod

        whenever error stop
        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Cidade!'
           return false
        end if
        return true
     else
        return false
     end if

end function

#---------------------------------------------------------
 function ctc69m17_inclui()
#---------------------------------------------------------

   whenever error continue
   execute p_ctc69m17_004 using mr_param.lclclartccod
                              , ma_ctc69m17[arr_aux].cidcod
                              , g_issk.usrtip
                              , g_issk.empcod
                              , g_issk.funmat
                              , 'today'

   whenever error continue
   if sqlca.sqlcode = 0 then
      error 'Dados Incluidos com Sucesso!'
      let m_operacao = ' '
   else
      error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
   end if


end function

#---------------------------------------------------------
 function ctc69m17_recupera_chave()
#---------------------------------------------------------

    open c_ctc69m17_007 using mr_param.lclclartccod,
                              ma_ctc69m17[arr_aux].cidcod
    whenever error continue
    fetch c_ctc69m17_007 into  ma_ctc69m17[arr_aux].rtcececod
    whenever error stop


end function