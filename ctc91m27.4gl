#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Cadastro Itau                                              #
# Modulo.........: ctc91m27                                                   #
# Objetivo.......: Cadastro Segmento X Natureza                               #
# Analista Resp. : Moises Gabel                                               #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 31/07/2014                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc91m27 array[500] of record
      itaclisgmcod    like datrclisgmasiplnntz.itaclisgmcod
    , itaclisgmdes    like datkitaclisgm.itaclisgmdes
    , vigincdat       like datrclisgmasiplnntz.vigincdat
    , vigfnldat       like datrclisgmasiplnntz.vigfnldat
end record
define ma_retorno array[500] of record
      ntzplnordnum    like datrclisgmasiplnntz.ntzplnordnum
end record

define mr_param   record
     socntzcod      like datrclisgmasiplnntz.socntzcod     ,
     socntzdes      like datksocntz.socntzdes              ,
     itaasiplncod   like datrclisgmasiplnntz.itaasiplncod  ,
     itaasiplndes   like datkitaasipln.itaasiplndes
end record

define mr_ctc91m27 record
      atlempcod       like datrclisgmasiplnntz.atlempcod
     ,atlmatnum       like datrclisgmasiplnntz.atlmatnum
     ,atldat          like datrclisgmasiplnntz.atldat
     ,funnom          like isskfunc.funnom
     ,atlusrtipcod    like datrclisgmasiplnntz.atlusrtipcod
     ,msg             char(80)
end record


define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

#===============================================================================
 function ctc91m27_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select a.itaclisgmcod           '
          ,  '      , b.itaclisgmdes           '
          ,  '      , a.vigincdat              '
          ,  '      , a.vigfnldat              '
          ,  '      , a.ntzplnordnum           '
          ,  '   from datrclisgmasiplnntz a ,  '
          ,  '        datkitaclisgm b          '
          ,  '  where a.itaclisgmcod  = b.itaclisgmcod  '
          ,  '  and   a.socntzcod  = ?                  '
          ,  '  and   a.itaasiplncod = ?                '
          ,  '  order by a.itaclisgmcod                 '
 prepare p_ctc91m27_001 from l_sql
 declare c_ctc91m27_001 cursor for p_ctc91m27_001

 let l_sql = ' select count(*)                '
          ,  '  from datrclisgmasiplnntz      '
          ,  '  where itaclisgmcod    = ?     '
          ,  '  and   socntzcod  = ?          '
          ,  '  and itaasiplncod = ?          '
 prepare p_ctc91m27_002 from l_sql
 declare c_ctc91m27_002 cursor for p_ctc91m27_002


 let l_sql =  ' update datrclisgmasiplnntz    '
           ,  '     set vigincdat    = ? ,    '
           ,  '         vigfnldat    = ? ,    '
           ,  '         atldat       = ? ,    '
           ,  '         atlmatnum    = ?      '
           ,  '  where itaclisgmcod  = ?      '
           ,  '  and   socntzcod     = ?      '
           ,  '  and   itaasiplncod  = ?      '
           ,  '  and   ntzplnordnum  = ?    '
 prepare p_ctc91m27_003 from l_sql
 let l_sql =  ' insert into datrclisgmasiplnntz   '
           ,  '   (socntzcod                      '
           ,  '   ,itaasiplncod                   '
           ,  '   ,itaclisgmcod                   '
           ,  '   ,ntzplnordnum                   '
           ,  '   ,vigincdat                      '
           ,  '   ,vigfnldat                      '
           ,  '   ,atlusrtipcod                   '
           ,  '   ,atlempcod                      '
           ,  '   ,atlmatnum                      '
           ,  '   ,atldat)                        '
           ,  ' values(?,?,?,?,?,?,?,?,?,?)       '
 prepare p_ctc91m27_004 from l_sql


 let l_sql = '   select atlempcod               '
            ,'         ,atlmatnum               '
            ,'         ,atldat                  '
            ,'         ,atlusrtipcod            '
            ,'     from datrclisgmasiplnntz     '
            ,'    where socntzcod  =  ?         '
            ,'    and   itaclisgmcod = ?        '
            ,'    and   itaasiplncod = ?        '
            ,'    and   ntzplnordnum = ?        '
 prepare p_ctc91m27_005    from l_sql
 declare c_ctc91m27_005 cursor for p_ctc91m27_005


 let l_sql = '  delete datrclisgmasiplnntz     '
            ,'  where  socntzcod = ?           '
            ,'  and itaclisgmcod = ?           '
            ,'  and itaasiplncod = ?           '
            ,'  and ntzplnordnum = ?           '
 prepare p_ctc91m27_006 from l_sql


 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc91m27_008 from l_sql
 declare c_ctc91m27_008 cursor for p_ctc91m27_008


 let l_sql = '  select max(ntzplnordnum) + 1     '
            ,'  from datrclisgmasiplnntz         '
            ,'  where  socntzcod = ?             '
            ,'  and itaasiplncod = ?             '
            ,'  and itaclisgmcod = ?             '
 prepare p_ctc91m27_009 from l_sql
 declare c_ctc91m27_009 cursor for p_ctc91m27_009
 let l_sql = '  select count(*)                  '
            ,'  from datrclisgmasiplnntz         '
            ,'  where  socntzcod = ?             '
            ,'  and itaasiplncod = ?             '
            ,'  and itaclisgmcod = ?             '
            ,'  and ntzplnordnum <> ?            '
            ,'  and vigincdat <=  ?              '
            ,'  and vigfnldat >=  ?              '
 prepare p_ctc91m27_010 from l_sql
 declare c_ctc91m27_010 cursor for p_ctc91m27_010
 let l_sql = ' select vigincdat             '
          ,  '      , vigfnldat             '
          ,  '  from datrclisgmasiplnntz    '
          ,  '  where  socntzcod = ?        '
          ,  '  and itaasiplncod = ?        '
          ,  '  and itaclisgmcod = ?        '
          ,  '  and ntzplnordnum <> ?       '
 prepare p_ctc91m27_011 from l_sql
 declare c_ctc91m27_011 cursor for p_ctc91m27_011

 let m_prepare = true


end function

#===============================================================================
 function ctc91m27(lr_param)
#===============================================================================

define lr_param record
	  itaasiplncod  like datrclisgmasiplnntz.itaasiplncod  ,
	  itaasiplndes  like datkitaasipln.itaasiplndes        ,
    socntzcod     like datrclisgmasiplnntz.socntzcod     ,
    socntzdes     like datksocntz.socntzdes
end record

define lr_retorno record
    flag       smallint                               ,
    cont       integer                                ,
    vigincdat  like datrclisgmrsrcaomtv.vigincdat     ,
    vigfnldat  like datrclisgmrsrcaomtv.vigfnldat     ,
    confirma   char(01)
end record

 let mr_param.itaasiplncod  = lr_param.itaasiplncod
 let mr_param.itaasiplndes  = lr_param.itaasiplndes
 let mr_param.socntzcod     = lr_param.socntzcod
 let mr_param.socntzdes     = lr_param.socntzdes


 for  arr_aux  =  1  to  500
    initialize  ma_ctc91m27[arr_aux].* to  null
 end  for


 initialize mr_ctc91m27.*, lr_retorno.* to null

 let arr_aux = 1

 if m_prepare is null or
    m_prepare <> true then
    call ctc91m27_prepare()
 end if


 open window w_ctc91m27 at 5,2 with form 'ctc91m27'
 attribute(form line first, message line last,comment line last - 1, border)

 message ' (F17)Abandona, (F1)Inclui, (F2)Exclui '

  display by name  mr_param.itaasiplncod
                ,  mr_param.itaasiplndes
                ,  mr_param.socntzcod
                ,  mr_param.socntzdes


  #--------------------------------------------------------
  # Recupera os Dados do Motivo
  #--------------------------------------------------------

  open c_ctc91m27_001  using  mr_param.socntzcod    ,
                              mr_param.itaasiplncod
  foreach c_ctc91m27_001 into ma_ctc91m27[arr_aux].itaclisgmcod,
  	                          ma_ctc91m27[arr_aux].itaclisgmdes,
                              ma_ctc91m27[arr_aux].vigincdat   ,
                              ma_ctc91m27[arr_aux].vigfnldat   ,
                              ma_retorno[arr_aux].ntzplnordnum


       let arr_aux = arr_aux + 1

       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontrados Mais de 500 Segmentoss!"
          exit foreach
       end if

  end foreach


  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if

 let m_operacao = " "

 call set_count(arr_aux - 1 )

 input array ma_ctc91m27 without defaults from s_ctc91m27.*

      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then

             if ma_ctc91m27[arr_aux].itaclisgmcod is null then
                let m_operacao = 'i'
             end if

          end if

      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'

         initialize  ma_ctc91m27[arr_aux] to null

         display ma_ctc91m27[arr_aux].itaclisgmcod  to s_ctc91m27[scr_aux].itaclisgmcod
         display ma_ctc91m27[arr_aux].itaclisgmdes  to s_ctc91m27[scr_aux].itaclisgmdes
         display ma_ctc91m27[arr_aux].vigincdat     to s_ctc91m27[scr_aux].vigincdat
         display ma_ctc91m27[arr_aux].vigfnldat     to s_ctc91m27[scr_aux].vigfnldat

      #---------------------------------------------
       before field itaclisgmcod
      #---------------------------------------------

        if ma_ctc91m27[arr_aux].itaclisgmcod is null then
           display ma_ctc91m27[arr_aux].itaclisgmcod to s_ctc91m27[scr_aux].itaclisgmcod attribute(reverse)
           let m_operacao = 'i'
        else
          display ma_ctc91m27[arr_aux].* to s_ctc91m27[scr_aux].* attribute(reverse)
        end if


        if m_operacao <> 'i' then

        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Motivo
        	 #--------------------------------------------------------

           call ctc91m27_dados_alteracao(mr_param.itaasiplncod             ,
                                         mr_param.socntzcod                ,
                                         ma_ctc91m27[arr_aux].itaclisgmcod ,
                                         ma_retorno[arr_aux].ntzplnordnum  )
        end if

      #---------------------------------------------
       after field itaclisgmcod
      #---------------------------------------------

        if m_operacao = 'i' then

        	if ma_ctc91m27[arr_aux].itaclisgmcod is null then


        		 #--------------------------------------------------------
        		 # Abre o Popup do Servico
        		 #--------------------------------------------------------

        		 call ctc91m24_popup(2)
        		 returning ma_ctc91m27[arr_aux].itaclisgmcod
        		         , ma_ctc91m27[arr_aux].itaclisgmdes

        		 if ma_ctc91m27[arr_aux].itaclisgmcod is null then
        		    next field itaclisgmcod
        		 end if
        	else

        		#--------------------------------------------------------
        		# Recupera a Descricao do Servico
        		#--------------------------------------------------------

        		call ctc91m24_recupera_descricao(2,ma_ctc91m27[arr_aux].itaclisgmcod)
        		returning ma_ctc91m27[arr_aux].itaclisgmdes

        		if ma_ctc91m27[arr_aux].itaclisgmdes is null then
        		   next field itaclisgmcod
        		end if

          end if


          ##--------------------------------------------------------
          ## Valida Se o Segmento Ja Existe
          ##--------------------------------------------------------
          #
          #open c_ctc91m27_002 using ma_ctc91m27[arr_aux].itaclisgmcod,
          #                          mr_param.socntzcod               ,
          #                          mr_param.itaasiplncod
          #
          #whenever error continue
          #fetch c_ctc91m27_002 into lr_retorno.cont
          #whenever error stop
          #
          #if lr_retorno.cont >  0   then
          #   error " Segmento ja Cadastrado Para Este Segmento!!"
          #   next field itaclisgmcod
          #end if

          display ma_ctc91m27[arr_aux].itaclisgmcod to s_ctc91m27[scr_aux].itaclisgmcod
          display ma_ctc91m27[arr_aux].itaclisgmdes to s_ctc91m27[scr_aux].itaclisgmdes
          display ma_ctc91m27[arr_aux].vigincdat    to s_ctc91m27[scr_aux].vigincdat
          display ma_ctc91m27[arr_aux].vigfnldat    to s_ctc91m27[scr_aux].vigfnldat


        else
        	display ma_ctc91m27[arr_aux].* to s_ctc91m27[scr_aux].*
        end if


        #---------------------------------------------
         before field vigincdat
        #---------------------------------------------
            display ma_ctc91m27[arr_aux].vigincdat   to s_ctc91m27[scr_aux].vigincdat   attribute(reverse)
            if ma_ctc91m27[arr_aux].vigincdat is null then
                let lr_retorno.vigincdat = "01/01/1900"
            else
                let lr_retorno.vigincdat = ma_ctc91m27[arr_aux].vigincdat
            end if
        #---------------------------------------------
         after field vigincdat
        #---------------------------------------------
            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
                  next field itaclisgmcod
            end if
            if ma_ctc91m27[arr_aux].vigincdat    is null   then
               error "Por Favor Informe a Data Inicial de Vigencia!"
               next field vigincdat
            end if
        #---------------------------------------------
         before field vigfnldat
        #---------------------------------------------
            display ma_ctc91m27[arr_aux].vigfnldat   to s_ctc91m27[scr_aux].vigfnldat   attribute(reverse)
            if ma_ctc91m27[arr_aux].vigfnldat is null then
                let lr_retorno.vigfnldat = "01/01/1900"
            else
                let lr_retorno.vigfnldat = ma_ctc91m27[arr_aux].vigfnldat
            end if
        #---------------------------------------------
         after field vigfnldat
        #---------------------------------------------
            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
                  next field vigincdat
            end if
            if ma_ctc91m27[arr_aux].vigfnldat    is null   then
               error "Por Favor Informe a Data Final de Vigencia!"
               next field vigfnldat
            end if
            if ma_ctc91m27[arr_aux].vigfnldat < ma_ctc91m27[arr_aux].vigincdat      then
               error "Data Final Nao Pode Menor que a Data Inicial"
               next field vigfnldat
            end if
            if not ctc91m27_valida_data() then
                next field vigfnldat
            end if


         if m_operacao <> 'i' then

             if ma_ctc91m27[arr_aux].vigincdat     <> lr_retorno.vigincdat    or
             	  ma_ctc91m27[arr_aux].vigfnldat     <> lr_retorno.vigfnldat    then
                   #--------------------------------------------------------
                   # Atualiza o Segmento
                   #--------------------------------------------------------
                   call ctc91m27_altera()
                   next field itaclisgmcod
             end if
             let m_operacao = ' '
         else
            
            #--------------------------------------------------------
            # Recupera Sequencia
            #--------------------------------------------------------
            call ctc91m27_recupera_sequencia(mr_param.socntzcod                ,    
                                             mr_param.itaasiplncod             ,
                                             ma_ctc91m27[arr_aux].itaclisgmcod )
            returning ma_retorno[arr_aux].ntzplnordnum 
            
            #--------------------------------------------------------
            # Inclui Segmento
            #--------------------------------------------------------
            call ctc91m27_inclui(mr_param.socntzcod                ,
                                 mr_param.itaasiplncod             ,
                                 ma_ctc91m27[arr_aux].itaclisgmcod ,
                                 ma_retorno[arr_aux].ntzplnordnum  ,
                                 ma_ctc91m27[arr_aux].vigincdat    ,
                                 ma_ctc91m27[arr_aux].vigfnldat    )

            next field itaclisgmcod
         end if

         display ma_ctc91m27[arr_aux].itaclisgmcod  to s_ctc91m27[scr_aux].itaclisgmcod
         display ma_ctc91m27[arr_aux].itaclisgmdes  to s_ctc91m27[scr_aux].itaclisgmdes
         display ma_ctc91m27[arr_aux].vigincdat     to s_ctc91m27[scr_aux].vigincdat
         display ma_ctc91m27[arr_aux].vigfnldat     to s_ctc91m27[scr_aux].vigfnldat

      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input


      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc91m27[arr_aux].itaclisgmcod  is null   then
            continue input
         else


            #--------------------------------------------------------
            # Exclui Associacao Natureza X Segmento
            #--------------------------------------------------------

            if not ctc91m27_delete(ma_ctc91m27[arr_aux].itaclisgmcod) then
                let lr_retorno.flag = 1
                exit input
            end if


            next field itaclisgmcod

         end if



  end input

 close window w_ctc91m27

 if lr_retorno.flag = 1 then
    call ctc91m27(mr_param.*)
 end if


end function


#---------------------------------------------------------
 function ctc91m27_dados_alteracao(lr_param)
#---------------------------------------------------------

define lr_param record
	itaasiplncod  like  datrclisgmasiplnntz.itaasiplncod ,
	socntzcod     like  datrclisgmasiplnntz.socntzcod    ,
	itaclisgmcod  like  datrclisgmasiplnntz.itaclisgmcod ,
	ntzplnordnum  like  datrclisgmasiplnntz.ntzplnordnum
end record


   initialize mr_ctc91m27.* to null


   open c_ctc91m27_005 using lr_param.socntzcod    ,
                             lr_param.itaclisgmcod ,
                             lr_param.itaasiplncod ,
                             lr_param.ntzplnordnum

   whenever error continue
   fetch c_ctc91m27_005 into  mr_ctc91m27.atlempcod
                             ,mr_ctc91m27.atlmatnum
                             ,mr_ctc91m27.atldat
                             ,mr_ctc91m27.atlusrtipcod
   whenever error stop

   call ctc91m27_func(mr_ctc91m27.atlmatnum  , mr_ctc91m27.atlempcod, mr_ctc91m27.atlusrtipcod )
   returning mr_ctc91m27.funnom

   display by name  mr_ctc91m27.atldat
                   ,mr_ctc91m27.funnom


end function


#==============================================
 function ctc91m27_delete(lr_param)
#==============================================

define lr_param record
		itaclisgmcod    like  datrclisgmasiplnntz.itaclisgmcod
end record

define lr_retorno record
	confirma char(1)
end record

initialize lr_retorno.* to null

  call cts08g01("A","S"
               ,"CONFIRMA EXCLUSAO"
               ,"DO CODIGO "
               ,"DE SEGMENTO ?"
               ," ")
     returning lr_retorno.confirma

     if lr_retorno.confirma  = "S" then
        let m_operacao = 'd'

        begin work

        whenever error continue
        execute p_ctc91m27_006 using mr_param.socntzcod                  ,
                                     lr_param.itaclisgmcod               ,
                                     mr_param.itaasiplncod               ,
                                     ma_retorno[arr_aux].ntzplnordnum

        whenever error stop
        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Segmento!'
           rollback work
           return false
        end if

        commit work
        return true
     else
        return false
     end if

end function



#---------------------------------------------------------
 function ctc91m27_inclui(lr_param)
#---------------------------------------------------------

define lr_param record
  socntzcod      like datrclisgmasiplnntz.socntzcod    ,
  itaasiplncod   like datrclisgmasiplnntz.itaasiplncod ,
  itaclisgmcod   like datrclisgmasiplnntz.itaclisgmcod ,
  ntzplnordnum   like datrclisgmasiplnntz.ntzplnordnum ,
  vigincdat      like datrclisgmasiplnntz.vigincdat    ,
  vigfnldat      like datrclisgmasiplnntz.vigfnldat
end record

define lr_retorno record
   data_atual date
end record

if m_prepare is null or
   m_prepare <> true then
   call ctc91m27_prepare()
end if

initialize lr_retorno.* to null

   let lr_retorno.data_atual = today

   whenever error continue
   execute p_ctc91m27_004 using lr_param.socntzcod
                              , lr_param.itaasiplncod
                              , lr_param.itaclisgmcod
                              , lr_param.ntzplnordnum
                              , lr_param.vigincdat
                              , lr_param.vigfnldat
                              , g_issk.usrtip
                              , g_issk.empcod
                              , g_issk.funmat
                              , lr_retorno.data_atual

   whenever error continue
   if sqlca.sqlcode = 0 then
      error 'Dados Incluidos com Sucesso!'
      let m_operacao = ' '
   else
      error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
   end if




end function

#---------------------------------------------------------
 function ctc91m27_func(lr_param)
#---------------------------------------------------------

 define lr_param  record
    funmat       like isskfunc.funmat,
    empcod       like isskfunc.empcod,
    atlusrtipcod like isskfunc.usrtip
 end record

 define lr_retorno  record
    funnom    like isskfunc.funnom
 end record

if m_prepare is null or
  m_prepare <> true then
  call ctc91m27_prepare()
end if

 initialize lr_retorno.*    to null

   if lr_param.empcod is null or
      lr_param.empcod = " " then

      let lr_param.empcod = 1

   end if


   #--------------------------------------------------------
   # Recupera os Dados do Funcionario
   #--------------------------------------------------------


   open c_ctc91m27_008 using lr_param.empcod ,
                             lr_param.funmat ,
                             lr_param.atlusrtipcod
   whenever error continue
   fetch c_ctc91m27_008 into lr_retorno.funnom
   whenever error stop

 return lr_retorno.funnom

 end function
 
#---------------------------------------------------------
 function ctc91m27_recupera_sequencia(lr_param)
#---------------------------------------------------------  

define lr_param record                                         
    socntzcod      like datrclisgmasiplnntz.socntzcod     ,  
    itaasiplncod   like datrclisgmasiplnntz.itaasiplncod  ,
    itaclisgmcod   like datrclisgmasiplnntz.itaclisgmcod     
end record                                                       

define lr_retorno record
      ntzplnordnum    like datrclisgmasiplnntz.ntzplnordnum
end record

    initialize lr_retorno.* to null
    
    if m_prepare is null or      
      m_prepare <> true then     
      call ctc91m27_prepare()    
    end if                       
    
    #--------------------------------------------------------
    # Recupera a Sequencia do Registro
    #--------------------------------------------------------
    open c_ctc91m27_009 using  lr_param.socntzcod                ,
                               lr_param.itaasiplncod             ,
                               lr_param.itaclisgmcod
    whenever error continue
    fetch c_ctc91m27_009 into  lr_retorno.ntzplnordnum 
    whenever error stop
    
    if lr_retorno.ntzplnordnum  is null or
    	 lr_retorno.ntzplnordnum  = " "   then
    	 	   let lr_retorno.ntzplnordnum  = 0
    end if
    
    return lr_retorno.ntzplnordnum 
    
end function
#---------------------------------------------------------
 function ctc91m27_valida_data()
#---------------------------------------------------------
define lr_retorno  record
   cont       integer
 , vigincdat  like datrclisgmasiplnntz.vigincdat
 , vigfnldat  like datrclisgmasiplnntz.vigfnldat
end record
initialize lr_retorno.* to null
        open c_ctc91m27_010 using mr_param.socntzcod                 ,
                                  mr_param.itaasiplncod              ,
                                  ma_ctc91m27[arr_aux].itaclisgmcod  ,
                                  ma_retorno[arr_aux].ntzplnordnum   ,
                                  ma_ctc91m27[arr_aux].vigincdat     ,
                                  ma_ctc91m27[arr_aux].vigincdat
        whenever error continue
        fetch c_ctc91m27_010 into  lr_retorno.cont
        whenever error stop
        if lr_retorno.cont  >  0   then
           error "Segmento Ja Cadastrado para Essa Vigencia Inicial!"
           return false
        end if
        open c_ctc91m27_010 using mr_param.socntzcod                 ,
                                  mr_param.itaasiplncod              ,
                                  ma_ctc91m27[arr_aux].itaclisgmcod  ,
                                  ma_retorno[arr_aux].ntzplnordnum   ,
                                  ma_ctc91m27[arr_aux].vigfnldat     ,
                                  ma_ctc91m27[arr_aux].vigfnldat
        whenever error continue
        fetch c_ctc91m27_010 into  lr_retorno.cont
        whenever error stop
        if lr_retorno.cont  >  0   then
           error "Segmento Ja Cadastrado para Essa Vigencia Final!"
           return false
        end if
       #--------------------------------------------------------
       # Recupera as Datas Ja Existentes
       #--------------------------------------------------------
       open c_ctc91m27_011  using  mr_param.socntzcod                 ,
                                   mr_param.itaasiplncod              ,
                                   ma_ctc91m27[arr_aux].itaclisgmcod  ,
                                   ma_retorno[arr_aux].ntzplnordnum
       foreach c_ctc91m27_011 into lr_retorno.vigincdat   ,
       	                           lr_retorno.vigfnldat
            if  ma_ctc91m27[arr_aux].vigincdat <= lr_retorno.vigincdat and
                ma_ctc91m27[arr_aux].vigfnldat >= lr_retorno.vigincdat then
                   error "Ja Existe um Segmento que Contem essa Vigencia Inicial!"
                   return false
            end if
            if  ma_ctc91m27[arr_aux].vigincdat <= lr_retorno.vigfnldat and
                ma_ctc91m27[arr_aux].vigfnldat >= lr_retorno.vigfnldat then
                   error "Ja Existe um Segmento que Contem essa Vigencia Final!"
                   return false
            end if
       end foreach
       return true
end function
#---------------------------------------------------------
 function ctc91m27_altera()
#---------------------------------------------------------

define lr_retorno record
   data_atual date,
   funmat     like isskfunc.funmat
end record

initialize lr_retorno.* to null
    let lr_retorno.data_atual = today
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"
    whenever error continue
    execute p_ctc91m27_003 using ma_ctc91m27[arr_aux].vigincdat
                               , ma_ctc91m27[arr_aux].vigfnldat
                               , lr_retorno.data_atual
                               , lr_retorno.funmat
                               , ma_ctc91m27[arr_aux].itaclisgmcod
                               , mr_param.socntzcod
                               , mr_param.itaasiplncod
                               , ma_retorno[arr_aux].ntzplnordnum
    whenever error continue
    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao do Segmento!'
    else
    	  error 'Dados Alterados com Sucesso!'
    end if
    let m_operacao = ' '
end function