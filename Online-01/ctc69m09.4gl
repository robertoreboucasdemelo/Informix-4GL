#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m09                                                   #
# Objetivo.......: Cadastro Servico X Clausula/Plano X Cobertura              #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 22/08/2013                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m09 array[500] of record
      cbtcod     like datkcbtcss.cbtcod
    , cbtdes     char(60)
    , cbtcsscod  like datkcbtcss.cbtcsscod
end record

define mr_param   record
       plnclscod      like datkplncls.plnclscod
     , srvclscod      like datkcbtcss.srvclscod
     , clscod         like datkplncls.clscod
     , clsnom         char(60)
     , srvcod         like datksrv.srvcod
     , srvnom         like datksrv.srvnom
     , empcod         like datkplncls.empcod
end record

define mr_ctc69m09 record
      empcod          like datkcbtcss.empcod
     ,usrmatnum       like datkcbtcss.usrmatnum
     ,regatldat       like datkcbtcss.regatldat
     ,funnom          like isskfunc.funnom
     ,usrtipcod       like datkcbtcss.usrtipcod
end record


define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_cod_aux   like datkcbtcss.cbtcod

define  m_prepare  smallint

#===============================================================================
 function ctc69m09_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select a.cbtcsscod           '
          ,  '      , a.cbtcod              '
          ,  '      , b.cpodes              '
          ,  '   from datkcbtcss a,         '
          ,  '        iddkdominio b         '
          ,  '  where a.cbtcod  = b.cpocod  '
          ,  '  and   a.srvclscod = ?       '
          ,  '  and   b.cponom = "cbtcod"   '
          ,  '  order by a.cbtcod           '
 prepare p_ctc69m09_001 from l_sql
 declare c_ctc69m09_001 cursor for p_ctc69m09_001

 let l_sql = ' select count(*)     '
          ,  '  from datkcbtcss    '
          ,  '  where cbtcod   = ? '
          ,  '  and  srvclscod = ? '
 prepare p_ctc69m09_002 from l_sql
 declare c_ctc69m09_002 cursor for p_ctc69m09_002

 let l_sql = ' select a.cbtcsscod           '
          ,  '      , a.cbtcod              '
          ,  '      , b.cpodes              '
          ,  '   from datkcbtcss a,         '
          ,  '        datkdominio b         '
          ,  '  where a.cbtcod  = b.cpocod  '
          ,  '  and   a.srvclscod = ?       '
          ,  '  and   b.cponom = "cob_azul" '
          ,  '  order by a.cbtcod           '
 prepare p_ctc69m09_003 from l_sql
 declare c_ctc69m09_003 cursor for p_ctc69m09_003

 let l_sql =  ' insert into datkcbtcss     '
           ,  '   (srvclscod               '
           ,  '   ,cbtcod                  '
           ,  '   ,usrtipcod               '
           ,  '   ,empcod                  '
           ,  '   ,usrmatnum               '
           ,  '   ,regatldat)              '
           ,  ' values(?,?,?,?,?,?)        '
 prepare p_ctc69m09_004 from l_sql


 let l_sql = '   select empcod           '
            ,'         ,usrmatnum        '
            ,'         ,regatldat        '
            ,'         ,usrtipcod        '
            ,'     from datkcbtcss       '
            ,'    where  cbtcsscod  =  ? '
 prepare p_ctc69m09_005    from l_sql
 declare c_ctc69m09_005 cursor for p_ctc69m09_005


 let l_sql = '  delete datkcbtcss     '
            ,'  where  cbtcsscod =  ? '
 prepare p_ctc69m09_006 from l_sql


 let l_sql = '    select  cbtcsscod    '
            ,'    from datkcbtcss      '
            ,'    where srvclscod =  ? '
            ,'    and   cbtcod    =  ? '
 prepare p_ctc69m09_007    from l_sql
 declare c_ctc69m09_007 cursor for p_ctc69m09_007


 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc69m09_008 from l_sql
 declare c_ctc69m09_008 cursor for p_ctc69m09_008


 let l_sql = ' select srvplnclscod     '
          ,  ' from datksrvplncls      '
          ,  ' where srvcod = ?        '
          ,  ' order by 1              '
 prepare p_ctc69m09_009 from l_sql
 declare c_ctc69m09_009 cursor for p_ctc69m09_009






 let m_prepare = true


end function

#===============================================================================
 function ctc69m09(lr_param)
#===============================================================================

define lr_param record
	  plnclscod  like datkplncls.plnclscod ,
    srvclscod  like datkcbtcss.srvclscod ,
    clscod     like datkplncls.clscod    ,
    clsnom     char(60)                  ,
    srvcod     like datksrv.srvcod       ,
    srvnom     like datksrv.srvnom       ,
    empcod     like datkplncls.empcod
end record

define lr_retorno record
    flag                smallint ,
    cont                integer  ,
    cbtdes              char(60) ,
    confirma            char(01)
end record

 let mr_param.plnclscod  = lr_param.plnclscod
 let mr_param.srvclscod  = lr_param.srvclscod
 let mr_param.clscod     = lr_param.clscod
 let mr_param.clsnom     = lr_param.clsnom
 let mr_param.srvcod     = lr_param.srvcod
 let mr_param.srvnom     = lr_param.srvnom
 let mr_param.empcod     = lr_param.empcod

 for  arr_aux  =  1  to  500
    initialize  ma_ctc69m09[arr_aux].* to  null
 end  for


 initialize mr_ctc69m09.*, lr_retorno.* to null

 let arr_aux = 1

 if m_prepare is null or
    m_prepare <> true then
    call ctc69m09_prepare()
 end if



 open window w_ctc69m09 at 6,2 with form 'ctc69m09'
 attribute(form line 1)

 message ' (F17)Abandona,(F1)Inclui,(F2)Exclui,(F7)Replica Cobertura,(F8)Replica Todas'

  display by name mr_param.clscod
                , mr_param.clsnom
                , mr_param.srvcod
                , mr_param.srvnom


  #--------------------------------------------------------
  # Recupera os Dados da Cobertura
  #--------------------------------------------------------

  if mr_param.empcod = 01 then
       open c_ctc69m09_001  using  mr_param.srvclscod
       foreach c_ctc69m09_001 into ma_ctc69m09[arr_aux].cbtcsscod
       	                        , ma_ctc69m09[arr_aux].cbtcod
                                 , ma_ctc69m09[arr_aux].cbtdes

            let arr_aux = arr_aux + 1

            if arr_aux > 500 then
               error " Limite Excedido! Foram Encontradas Mais de 500 Coberturas!"
               exit foreach
            end if
       end foreach
  end if
  if mr_param.empcod = 35 then

       open c_ctc69m09_003  using  mr_param.srvclscod
       foreach c_ctc69m09_003 into ma_ctc69m09[arr_aux].cbtcsscod
       	                         , ma_ctc69m09[arr_aux].cbtcod
                                 , ma_ctc69m09[arr_aux].cbtdes
            let arr_aux = arr_aux + 1
            if arr_aux > 500 then
               error " Limite Excedido! Foram Encontradas Mais de 500 Coberturas!"
               exit foreach
            end if
       end foreach
   end if


   if arr_aux = 1  then
        error "Nao Foi Encontrado Nenhum Registro"
   end if

 let m_operacao = " "

 call set_count(arr_aux - 1 )

 input array ma_ctc69m09 without defaults from s_ctc69m09.*

      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then

             if ma_ctc69m09[arr_aux].cbtcod  is null then
                let m_operacao = 'i'
             end if

          end if

      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'

         initialize  ma_ctc69m09[arr_aux] to null

         display ma_ctc69m09[arr_aux].cbtcod   to s_ctc69m09[scr_aux].cbtcod


      #---------------------------------------------
       before field cbtcod
      #---------------------------------------------

        if ma_ctc69m09[arr_aux].cbtcod  is null then
           display ma_ctc69m09[arr_aux].cbtcod  to s_ctc69m09[scr_aux].cbtcod  attribute(reverse)
           let m_operacao = 'i'
        else
        	let m_cod_aux  = ma_ctc69m09[arr_aux].cbtcod
          display ma_ctc69m09[arr_aux].* to s_ctc69m09[scr_aux].* attribute(reverse)
          display ""  to s_ctc69m09[scr_aux].cbtcsscod
        end if


        if m_operacao <> 'i' then
           call ctc69m09_dados_alteracao(ma_ctc69m09[arr_aux].cbtcsscod)
        end if

      #---------------------------------------------
       after field cbtcod
      #---------------------------------------------

        if fgl_lastkey() = fgl_keyval ("down")     or
           fgl_lastkey() = fgl_keyval ("return")   then
             if m_operacao = 'i' then

             	if ma_ctc69m09[arr_aux].cbtcod  is null then

             		 #--------------------------------------------------------
             		 # Abre o Popup da Cobertura
             		 #--------------------------------------------------------

                 if lr_param.empcod = 01 then
             		     call ctc69m04_popup(7)
             		     returning ma_ctc69m09[arr_aux].cbtcod
             		             , ma_ctc69m09[arr_aux].cbtdes
             		 end if
                 if lr_param.empcod = 35 then
                     call ctc69m04_popup(20)
                     returning ma_ctc69m09[arr_aux].cbtcod
                             , ma_ctc69m09[arr_aux].cbtdes
                 end if
             		 if ma_ctc69m09[arr_aux].cbtcod  is null then
             		    next field cbtcod
             		 end if
             	else

             		#--------------------------------------------------------
             		# Recupera a Descricao da Cobertura
             		#--------------------------------------------------------

             		if lr_param.empcod = 01 then
             		   call ctc69m04_recupera_descricao(7,ma_ctc69m09[arr_aux].cbtcod )
             		   returning ma_ctc69m09[arr_aux].cbtdes
             		end if
             		if lr_param.empcod = 35 then
             		   call ctc69m04_recupera_descricao(20,ma_ctc69m09[arr_aux].cbtcod )
             		   returning ma_ctc69m09[arr_aux].cbtdes
             		end if
             		if ma_ctc69m09[arr_aux].cbtdes is null then
             		   next field cbtcod
             		end if

               end if

               #--------------------------------------------------------
               # Valida Se a Cobertura Ja Foi Cadastrada
               #--------------------------------------------------------

               if not ctc69m09_valida() then
                  error " Associacao ja Cadastrada!"
                  next field cbtcod
               end if


               display ma_ctc69m09[arr_aux].cbtcod  to s_ctc69m09[scr_aux].cbtcod
               display ma_ctc69m09[arr_aux].cbtdes  to s_ctc69m09[scr_aux].cbtdes

               #--------------------------------------------------------
               # Inclui Cobertura
               #--------------------------------------------------------
               call ctc69m09_inclui()

               #--------------------------------------------------------
               # Recupera o Serial da Cobertura
               #--------------------------------------------------------
               call ctc69m09_recupera_chave()

               next field cbtcod
             else
             	let ma_ctc69m09[arr_aux].cbtcod = m_cod_aux
             	display ma_ctc69m09[arr_aux].* to s_ctc69m09[scr_aux].*
           end if
        else
        	 if m_operacao = 'i' then
        	    let ma_ctc69m09[arr_aux].cbtcod = ''
        	    display ma_ctc69m09[arr_aux].* to s_ctc69m09[scr_aux].*
        	    let m_operacao = ' '
        	 else
        	    let ma_ctc69m09[arr_aux].cbtcod = m_cod_aux
        	    display ma_ctc69m09[arr_aux].* to s_ctc69m09[scr_aux].*
        	 end if
        end if


      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input


      #---------------------------------------------
       on key (F7)
      #---------------------------------------------

          if ma_ctc69m09[arr_aux].cbtcod is not null then
               call ctc69m09_replica_cobertura()
          end if
      #---------------------------------------------
       on key (F8)
      #---------------------------------------------

          if ma_ctc69m09[arr_aux].cbtcod is not null then
               call ctc69m09_replica_todas_coberturas()
          end if

      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc69m09[arr_aux].cbtcsscod    is null   then
            continue input
         else

            #--------------------------------------------------------
            # Verifica Se a Cobertura Pode Ser Excluida
            #--------------------------------------------------------

            if ctc69m06_valida_exclusao() then

               #--------------------------------------------------------
               # Exclui Cobertura
               #--------------------------------------------------------

               if not ctc69m09_delete(ma_ctc69m09[arr_aux].cbtcsscod) then
                   let lr_retorno.flag = 1
                   exit input
               end if
            else
            	 let lr_retorno.flag = 1
            	 exit input
            end if
            next field cbtcod

         end if



  end input

 close window w_ctc69m09

 if lr_retorno.flag = 1 then
    call ctc69m09(mr_param.*)
 end if


end function


#---------------------------------------------------------
 function ctc69m09_func(lr_param)
#---------------------------------------------------------

 define lr_param  record
    funmat       like isskfunc.funmat,
    empcod       like isskfunc.empcod,
    usrtipcod    like isskfunc.usrtip
 end record

 define lr_retorno            record
    funnom    like isskfunc.funnom
 end record

if m_prepare is null or
  m_prepare <> true then
  call ctc69m09_prepare()
end if

 initialize lr_retorno.*    to null

   if lr_param.empcod is null or
      lr_param.empcod = " " then

      let lr_param.empcod = 1

   end if


   #--------------------------------------------------------
   # Recupera os Dados do Funcionario
   #--------------------------------------------------------


   open c_ctc69m09_008 using lr_param.empcod ,
                             lr_param.funmat ,
                             lr_param.usrtipcod
   whenever error continue
   fetch c_ctc69m09_008 into lr_retorno.funnom
   whenever error stop

 return lr_retorno.funnom

 end function


#---------------------------------------------------------
 function ctc69m09_dados_alteracao(lr_param)
#---------------------------------------------------------

define lr_param record
	 cbtcsscod   like datkcbtcss.cbtcsscod
end record


   initialize mr_ctc69m09.* to null


   open c_ctc69m09_005 using lr_param.cbtcsscod

   whenever error continue
   fetch c_ctc69m09_005 into  mr_ctc69m09.empcod
                             ,mr_ctc69m09.usrmatnum
                             ,mr_ctc69m09.regatldat
                             ,mr_ctc69m09.usrtipcod

   whenever error stop


   call ctc69m09_func(mr_ctc69m09.usrmatnum , mr_ctc69m09.empcod, mr_ctc69m09.usrtipcod )
   returning mr_ctc69m09.funnom

   display by name  mr_ctc69m09.regatldat
                   ,mr_ctc69m09.funnom

end function

#==============================================
 function ctc69m09_delete(lr_param)
#==============================================

define lr_param record
	 cbtcsscod  like datkcbtcss.cbtcsscod
end record

define lr_retorno record
	confirma char(1)
end record

initialize lr_retorno.* to null

  call cts08g01("A","S"
               ,"CONFIRMA EXCLUSAO"
               ,"DO CODIGO "
               ,"DE COBERTURA ?"
               ," ")
     returning lr_retorno.confirma

     if lr_retorno.confirma  = "S" then
        let m_operacao = 'd'

        whenever error continue
        execute p_ctc69m09_006 using lr_param.cbtcsscod

        whenever error stop
        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Cobertura!'
           return false
        end if
        return true
     else
        return false
     end if

end function

#---------------------------------------------------------
 function ctc69m09_inclui()
#---------------------------------------------------------

   whenever error continue
   execute p_ctc69m09_004 using mr_param.srvclscod
                              , ma_ctc69m09[arr_aux].cbtcod
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
 function ctc69m09_recupera_chave()
#---------------------------------------------------------

    open c_ctc69m09_007 using mr_param.srvclscod,
                              ma_ctc69m09[arr_aux].cbtcod
    whenever error continue
    fetch c_ctc69m09_007 into  ma_ctc69m09[arr_aux].cbtcsscod
    whenever error stop


end function


#---------------------------------------------------------
 function ctc69m09_valida()
#---------------------------------------------------------

define lr_retorno record
	 cont integer
end record


   #--------------------------------------------------------
   # Valida Se a Cobertura Ja Foi Cadastrada
   #--------------------------------------------------------

   open c_ctc69m09_002 using ma_ctc69m09[arr_aux].cbtcod  ,
                             mr_param.srvclscod
   whenever error continue
   fetch c_ctc69m09_002 into lr_retorno.cont
   whenever error stop

   if lr_retorno.cont >  0   then
      return false
   end if


   return true


end function

#---------------------------------------------------------
 function ctc69m09_replica_cobertura()
#---------------------------------------------------------

define lr_retorno record
	confirma  char(1)                   ,
	srvclscod like datkcbtcss.srvclscod
end record

initialize lr_retorno.* to null

let lr_retorno.srvclscod = mr_param.srvclscod

  call cts08g01("A","S"
               ,"CONFIRMA REPLICACAO"
               ,"DA COBERTURA "
               ,"EM TODOS OS "
               ,"PACOTES? ")
     returning lr_retorno.confirma

     if lr_retorno.confirma  = "S" then


         #--------------------------------------------------------
         # Recupera os Dados do Servico
         #--------------------------------------------------------

         open c_ctc69m09_009 using mr_param.srvcod
         foreach c_ctc69m09_009 into mr_param.srvclscod


               #--------------------------------------------------------
               # Valida Se a Cobertura Ja Foi Cadastrada
               #--------------------------------------------------------

               if not ctc69m09_valida() then
                  continue foreach
               end if

               #--------------------------------------------------------
               # Inclui Cobertura
               #--------------------------------------------------------
               call ctc69m09_inclui()


         end foreach

         let mr_param.srvclscod = lr_retorno.srvclscod

     end if



end function
#---------------------------------------------------------
 function ctc69m09_replica_todas_coberturas()
#---------------------------------------------------------
define lr_retorno record
	confirma    char(1)                   ,
	srvclscod   like datkcbtcss.srvclscod ,
  cbtcod      like datkcbtcss.cbtcod    ,
	cbtdes      char(60)                  ,
	cbtcsscod   like datkcbtcss.cbtcsscod ,
	cbtcod_ant  like datkcbtcss.cbtcod
end record
initialize lr_retorno.* to null
let lr_retorno.srvclscod     = mr_param.srvclscod
let lr_retorno.cbtcod_ant    = ma_ctc69m09[arr_aux].cbtcod
  call cts08g01("A","S"
               ,"CONFIRMA REPLICACAO"
               ,"DE TODAS AS COBERTURAS "
               ,"EM TODOS OS "
               ,"PACOTES? ")
     returning lr_retorno.confirma
     if lr_retorno.confirma  = "S" then
          #--------------------------------------------------------
          # Recupera os Dados da Cobertura
          #--------------------------------------------------------
          if mr_param.empcod = 01 then
             open c_ctc69m09_001  using  mr_param.srvclscod
             foreach c_ctc69m09_001 into lr_retorno.cbtcsscod
             	                        , lr_retorno.cbtcod
                                       , lr_retorno.cbtdes
                     let ma_ctc69m09[arr_aux].cbtcod = lr_retorno.cbtcod
                     #--------------------------------------------------------
                     # Recupera os Dados do Servico
                     #--------------------------------------------------------
                     open c_ctc69m09_009 using mr_param.srvcod
                     foreach c_ctc69m09_009 into mr_param.srvclscod
                           #--------------------------------------------------------
                           # Valida Se a Cobertura Ja Foi Cadastrada
                           #--------------------------------------------------------
                           if not ctc69m09_valida() then
                              continue foreach
                           end if
                           #--------------------------------------------------------
                           # Inclui Cobertura
                           #--------------------------------------------------------
                           call ctc69m09_inclui()
                     end foreach
             end foreach
         end if
         if mr_param.empcod = 35 then
             open c_ctc69m09_003  using  mr_param.srvclscod
             foreach c_ctc69m09_003 into lr_retorno.cbtcsscod
             	                         , lr_retorno.cbtcod
                                       , lr_retorno.cbtdes
                     let ma_ctc69m09[arr_aux].cbtcod = lr_retorno.cbtcod
                     #--------------------------------------------------------
                     # Recupera os Dados do Servico
                     #--------------------------------------------------------
                     open c_ctc69m09_009 using mr_param.srvcod
                     foreach c_ctc69m09_009 into mr_param.srvclscod
                           #--------------------------------------------------------
                           # Valida Se a Cobertura Ja Foi Cadastrada
                           #--------------------------------------------------------
                           if not ctc69m09_valida() then
                              continue foreach
                           end if
                           #--------------------------------------------------------
                           # Inclui Cobertura
                           #--------------------------------------------------------
                           call ctc69m09_inclui()
                     end foreach
             end foreach
         end if
         let mr_param.srvclscod           = lr_retorno.srvclscod
         let ma_ctc69m09[arr_aux].cbtcod  = lr_retorno.cbtcod_ant
     end if
end function