#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m07                                                   #
# Objetivo.......: Cadastro Pacote X Clausula/Plano                           #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 20/08/2013                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m07 array[500] of record
      paccod        integer
    , pacdes        char(60)
    , paclim        integer
    , pacuni        char(60)
    , srvplnclscod  like  datksrvplncls.srvplnclscod
end record

define mr_param   record
       plnclscod  like datkplncls.plnclscod
     , clscod     like datkplncls.clscod
     , clsnom     like datkplncls.clsnom
     , empcod     like datkplncls.empcod
     , ramcod     like datkplncls.ramcod
     , canal      integer
end record

define mr_ctc69m07 record
      empcod          like  datksrvplncls.empcod
     ,usrmatnum       like  datksrvplncls.usrmatnum
     ,regatldat       like  datksrvplncls.regatldat
     ,funnom          like  isskfunc.funnom
     ,usrtipcod       like  datksrvplncls.usrtipcod
end record

define ma_retorno array[200] of record
   paccod  integer  ,
   pacdes  char(60) ,
   paclim  dec(13,2),
   pacuni  char(60) ,
   srvcod  integer  ,
   srvdes  char(60) ,
   espcod  integer  ,
   espdes  char(60) ,
   limcod  integer  ,
   limdes  char(60) ,
   limlim  dec(13,2),
   limuni  char(60)
end record


define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_cod_aux   integer

define  m_prepare  smallint

#===============================================================================
function ctc69m07_prep_temp()
#===============================================================================
define l_sql char(10000)
    let l_sql = 'insert into pacote_temp'
	            , ' values(?,?,?,?)'
    prepare p_ctc69m07_003 from l_sql
    let l_sql = 'insert into servico_temp'
              , ' values(?,?,?)'
    prepare p_ctc69m07_009 from l_sql
    let l_sql = 'insert into especialidade_temp'
              , ' values(?,?,?,?)'
    prepare p_ctc69m07_014 from l_sql
    let l_sql = 'insert into limite_temp'
              , ' values(?,?,?,?,?,?,?)'
    prepare p_ctc69m07_015 from l_sql
end function
#===============================================================================
 function ctc69m07_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select srvplnclscod                       '
          ,  '      , srvcod                             '
          ,  '   from datksrvplncls                      '
          ,  '  where plnclscod = ?                      '
          ,  '  order by srvcod                          '
 prepare p_ctc69m07_001 from l_sql
 declare c_ctc69m07_001 cursor for p_ctc69m07_001

 let l_sql = ' select count(*)          '
          ,  '   from datksrvplncls     '
          ,  '  where srvcod    = ?     '
          ,  '  and   plnclscod = ?     '
 prepare p_ctc69m07_002 from l_sql
 declare c_ctc69m07_002 cursor for p_ctc69m07_002


 let l_sql =  ' insert into datksrvplncls   '
           ,  '   (plnclscod                '
           ,  '   ,srvcod                   '
           ,  '   ,srvplnclsevnlimvlr       '
           ,  '   ,srvplnclsevnlimundnom    '
           ,  '   ,usrtipcod                '
           ,  '   ,empcod                   '
           ,  '   ,usrmatnum                '
           ,  '   ,regatldat)               '
           ,  ' values(?,?,?,?,?,?,?,?)     '
 prepare p_ctc69m07_004 from l_sql


 let l_sql = '   select empcod              '
            ,'         ,usrmatnum           '
            ,'         ,regatldat           '
            ,'         ,usrtipcod           '
            ,'    from datksrvplncls        '
            ,'    where srvplnclscod  =  ?  '
 prepare p_ctc69m07_005    from l_sql
 declare c_ctc69m07_005 cursor for p_ctc69m07_005

 let l_sql = '  delete datksrvplncls      '
         ,  '   where srvplnclscod  =  ?  '
 prepare p_ctc69m07_006 from l_sql


 let l_sql = '   select srvplnclscod    '
            ,'   from datksrvplncls     '
            ,'   where plnclscod =  ?   '
            ,'   and   srvcod    =  ?   '
 prepare p_ctc69m07_007    from l_sql
 declare c_ctc69m07_007 cursor for p_ctc69m07_007


 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc69m07_008 from l_sql
 declare c_ctc69m07_008 cursor for p_ctc69m07_008



 let l_sql =  '    delete datkcbtcss  '
             ,'     where srvclscod = ?      '
 prepare p_ctc69m07_010 from l_sql


 let l_sql =  '    delete datktrfctgcss  '
             ,'     where srvclscod = ?  '
 prepare p_ctc69m07_011 from l_sql


 let l_sql =  '    delete datklclclartc  '
             ,'     where srvclscod = ?  '
 prepare p_ctc69m07_012 from l_sql


 let l_sql = ' delete datkrtcece       '
           , ' where lclclartccod in   '
           , '(select lclclartccod     '
           , ' from datklclclartc      '
           , ' where srvclscod = ?)    '
 prepare p_ctc69m07_013 from l_sql
 
 
 let l_sql = ' select count(*)          '
          ,  '   from datksrvgrp        '
          ,  '  where srvgrpcod    = ?  '
 prepare p_ctc69m07_016 from l_sql
 declare c_ctc69m07_016 cursor for p_ctc69m07_016

 let l_sql =  ' insert into datksrvgrp      '
           ,  '   (srvgrpcod                '
           ,  '   ,srvgrptipcod             '
           ,  '   ,srvcod                   '
           ,  '   ,regsitflg                '
           ,  '   ,usrtipcod                '
           ,  '   ,empcod                   '
           ,  '   ,usrmatnum                '
           ,  '   ,regatldat)               '
           ,  ' values(?,1,?,"A",?,?,?,?)     '
 prepare p_ctc69m07_017 from l_sql
 
 let l_sql = ' select count(*)          '
          ,  '   from datksrv           '
          ,  '  where srvcod    = ?     '
 prepare p_ctc69m07_018 from l_sql
 declare c_ctc69m07_018 cursor for p_ctc69m07_018
 
 let l_sql =  ' insert into datksrv         '
           ,  '   (srvcod                   '
           ,  '   ,srvnom                   '
           ,  '   ,srvsitflg                '
           ,  '   ,usrtipcod                '
           ,  '   ,empcod                   '
           ,  '   ,usrmatnum                '
           ,  '   ,regatldat)               '
           ,  ' values(?,?,"A",?,?,?,?)     '
 prepare p_ctc69m07_019 from l_sql
 
 let l_sql = ' select count(*)          '
          ,  '   from datksrvgrptip     '
          ,  '  where srvgrptipcod = 1  '
 prepare p_ctc69m07_020 from l_sql
 declare c_ctc69m07_020 cursor for p_ctc69m07_020
 
 let l_sql =  ' insert into datksrvgrptip   '
           ,  '   (srvgrptipcod             '
           ,  '   ,srvgrptipnom             '
           ,  '   ,srvgrptipsitflg          '
           ,  '   ,usrtipcod                '
           ,  '   ,empcod                   '
           ,  '   ,usrmatnum                '
           ,  '   ,regatldat)               '
           ,  ' values(1,".","A",?,?,?,?)   '
 prepare p_ctc69m07_021 from l_sql
 
 
 let l_sql = ' select cpodes[8,12]     '  
            ,' from datkdominio        '             
            ,' where cponom =  ?       '                
            ,' and   cpodes[1,2] =  ?  '
            ,' and   cpodes[4,6] =  ?  '             
 prepare p_ctc69m07_022 from l_sql                
 declare c_ctc69m07_022 cursor for p_ctc69m07_022
 
 let m_prepare = true    
 


end function

#===============================================================================
 function ctc69m07(lr_param)
#===============================================================================

define lr_param record
    plnclscod   like datkplncls.plnclscod ,
    clscod      like datkplncls.clscod    ,
    clsnom      like datkplncls.clsnom    ,
    empcod      like datkplncls.empcod    ,
    ramcod      like datkplncls.ramcod    ,
    canal       integer
end record

define lr_retorno record
    flag                 smallint                               ,
    cont                 integer                                ,
    pacdes               char(60)                               ,
    paclim               integer                                ,
    pacuni               char(60)                               ,
    confirma             char(01)                               ,
    procod               integer                  
end record

 let mr_param.plnclscod   = lr_param.plnclscod
 let mr_param.clscod      = lr_param.clscod
 let mr_param.clsnom      = lr_param.clsnom
 let mr_param.empcod      = lr_param.empcod
 let mr_param.ramcod      = lr_param.ramcod
 let mr_param.canal       = lr_param.canal

 for  arr_aux  =  1  to  500
    initialize  ma_ctc69m07[arr_aux].* to  null
 end  for
 
 initialize mr_ctc69m07.*, lr_retorno.* to null

 let arr_aux = 1

 if m_prepare is null or
    m_prepare <> true then
    call ctc69m07_prepare()
 end if


 options insert   key F1
 options delete   key F2

 open window w_ctc69m07 at 6,2 with form 'ctc69m07'
 attribute(form line 1)
 message 'Aguarde, Pesquisando Pacotes...'
 
  
 let lr_retorno.procod = ctc69m07_recupera_produto(lr_param.ramcod,lr_param.empcod)
 
 if not ctc69m07_pesquisa_xml(lr_param.empcod   , 
 	                            lr_retorno.procod ,
 	                            lr_param.ramcod)  then
 	 close window w_ctc69m07
 	 return
 end if
   
  case mr_param.canal
  	when 1
       message '(F17)Abandona,(F1)Inclui,(F2)Exclui,(F7)Classe,(F8)Cober,(F9)Categ'  
    when 2
    	 message '(F17)Abandona,(F1)Inclui,(F2)Exclui,(F7)Classe,(F9)Categ'
    when 3                                                               	 
    	 message '(F17)Abandona,(F1)Inclui,(F2)Exclui,(F9)Categ'	
    when 4
       message '(F17)Abandona,(F1)Inclui,(F2)Exclui,(F7)Classe,(F8)Cober,(F9)Categ'   
    when 5                                                              	 
    	 message '(F17)Abandona,(F1)Inclui,(F2)Exclui,(F9)Categ'	               
  end case
  
  

  display by name mr_param.plnclscod
                , mr_param.clscod
                , mr_param.clsnom


  #--------------------------------------------------------
  # Recupera os Dados do Pacote X Clausula
  #--------------------------------------------------------

  open c_ctc69m07_001  using  mr_param.plnclscod
  foreach c_ctc69m07_001 into ma_ctc69m07[arr_aux].srvplnclscod
  	                        , ma_ctc69m07[arr_aux].paccod

       #--------------------------------------------------------
       # Recupera a Descricao do Pacote
       #--------------------------------------------------------
       call ctc69m03_recupera_descricao(ma_ctc69m07[arr_aux].paccod)
       returning ma_ctc69m07[arr_aux].pacdes
               , ma_ctc69m07[arr_aux].paclim
               , ma_ctc69m07[arr_aux].pacuni

       let arr_aux = arr_aux + 1

       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontrados Mais de 500 Pacotes!"
          exit foreach
       end if

  end foreach


  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if

 let m_operacao = " "

 call set_count(arr_aux - 1 )

 input array ma_ctc69m07 without defaults from s_ctc69m07.*

      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then

             if ma_ctc69m07[arr_aux].paccod is null then
                let m_operacao = 'i'
             end if

          end if

      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'

         initialize  ma_ctc69m07[arr_aux] to null

         display ma_ctc69m07[arr_aux].paccod     to s_ctc69m07[scr_aux].paccod
         display ma_ctc69m07[arr_aux].pacdes     to s_ctc69m07[scr_aux].pacdes
         display ma_ctc69m07[arr_aux].paclim     to s_ctc69m07[scr_aux].paclim
         display ma_ctc69m07[arr_aux].pacuni     to s_ctc69m07[scr_aux].pacuni


      #---------------------------------------------
       before field paccod
      #---------------------------------------------

        if ma_ctc69m07[arr_aux].paccod is null then
           display ma_ctc69m07[arr_aux].paccod to s_ctc69m07[scr_aux].paccod attribute(reverse)
           let m_operacao = 'i'
        else
          let m_cod_aux  = ma_ctc69m07[arr_aux].paccod
          display ma_ctc69m07[arr_aux].* to s_ctc69m07[scr_aux].* attribute(reverse)
          display ""  to s_ctc69m07[scr_aux].srvplnclscod
        end if


        if m_operacao <> 'i' then

        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Pacote X Clausula
        	 #--------------------------------------------------------

           call ctc69m07_dados_alteracao(ma_ctc69m07[arr_aux].srvplnclscod)
        end if

      #---------------------------------------------
       after field paccod
      #---------------------------------------------

         if fgl_lastkey() = fgl_keyval ("down")     or
            fgl_lastkey() = fgl_keyval ("return")   then
              if m_operacao = 'i' then

              	if ma_ctc69m07[arr_aux].paccod is null then


              		 #--------------------------------------------------------
              		 # Abre o Popup do Pacote
              		 #--------------------------------------------------------

              		 call ctc69m03_popup()
              		 returning ma_ctc69m07[arr_aux].paccod
              		         , ma_ctc69m07[arr_aux].pacdes
              		         , ma_ctc69m07[arr_aux].paclim
              		         , ma_ctc69m07[arr_aux].pacuni

              		 if ma_ctc69m07[arr_aux].paccod is null then
              		    next field paccod
              		 end if
              	else

              		#--------------------------------------------------------
              		# Recupera a Descricao do Pacote
              		#--------------------------------------------------------

              		call ctc69m03_recupera_descricao(ma_ctc69m07[arr_aux].paccod)
              		returning ma_ctc69m07[arr_aux].pacdes
              		        , ma_ctc69m07[arr_aux].paclim
              		        , ma_ctc69m07[arr_aux].pacuni
              		if ma_ctc69m07[arr_aux].pacdes is null then
              		   next field paccod
              		end if

                end if


                #--------------------------------------------------------
                # Valida Se a Associacao Clausula X Pacote Ja Existe
                #--------------------------------------------------------

                open c_ctc69m07_002 using ma_ctc69m07[arr_aux].paccod ,
                                          mr_param.plnclscod
                whenever error continue
                fetch c_ctc69m07_002 into lr_retorno.cont
                whenever error stop

                if lr_retorno.cont >  0   then
                   error " Associacao ja Cadastrada!"
                   next field paccod
                end if

                display ma_ctc69m07[arr_aux].paccod to s_ctc69m07[scr_aux].paccod
                display ma_ctc69m07[arr_aux].pacdes to s_ctc69m07[scr_aux].pacdes
                display ma_ctc69m07[arr_aux].paclim to s_ctc69m07[scr_aux].paclim
                display ma_ctc69m07[arr_aux].pacuni to s_ctc69m07[scr_aux].pacuni
              else
              	let ma_ctc69m07[arr_aux].paccod = m_cod_aux
              	display ma_ctc69m07[arr_aux].* to s_ctc69m07[scr_aux].*
              end if
        else
        	 if m_operacao = 'i' then
        	    let ma_ctc69m07[arr_aux].paccod = ''
        	    display ma_ctc69m07[arr_aux].* to s_ctc69m07[scr_aux].*
        	    let m_operacao = ' '
        	 else
        	    let ma_ctc69m07[arr_aux].paccod = m_cod_aux
        	    display ma_ctc69m07[arr_aux].* to s_ctc69m07[scr_aux].*
        	 end if
        end if


         if m_operacao = 'i' then

            if ctc69m07_valida_inclusao() then


                #--------------------------------------------------------
                # Inclui Associacao Pacote X Clausula
                #--------------------------------------------------------
                call ctc69m07_inclui()

                #--------------------------------------------------------
                # Recupera Serial da Associacao Pacote X Clausula
                #--------------------------------------------------------
                call ctc69m07_recupera_chave()
                next field paccod
            end if
         end if

         display ma_ctc69m07[arr_aux].paccod                 to s_ctc69m07[scr_aux].paccod
         display ma_ctc69m07[arr_aux].pacdes                 to s_ctc69m07[scr_aux].pacdes
         display ma_ctc69m07[arr_aux].paclim                 to s_ctc69m07[scr_aux].paclim
         display ma_ctc69m07[arr_aux].pacuni                 to s_ctc69m07[scr_aux].pacuni


      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input


      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc69m07[arr_aux].srvplnclscod  is null   then
            continue input
         else

            #--------------------------------------------------------------
            # Valida Se a Associacao Pacote X Clausula Pode Ser Excluida
            #--------------------------------------------------------------

            if ctc69m06_valida_exclusao() then

                #--------------------------------------------------------
                # Exclui Associacao Pacote X Clausula
                #--------------------------------------------------------

                if not ctc69m07_delete(ma_ctc69m07[arr_aux].srvplnclscod) then
                    let lr_retorno.flag = 1
                    exit input
                end if
            else
            	  let lr_retorno.flag = 1
            	  exit input
            end if

            next field paccod

         end if



      #---------------------------------------------
       on key (F7)
      #---------------------------------------------

          if mr_param.canal = 1 or 
          	 mr_param.canal = 2 or 
             mr_param.canal = 4 then
                         
                if ma_ctc69m07[arr_aux].paccod is not null then
                
                    call ctc69m11(mr_param.plnclscod                  ,
                                  ma_ctc69m07[arr_aux].srvplnclscod   ,
                                  mr_param.clscod                     ,
                                  mr_param.clsnom                     ,
                                  ma_ctc69m07[arr_aux].paccod         ,
                                  ma_ctc69m07[arr_aux].pacdes         )
                end if
           
          end if

      #---------------------------------------------
       on key (F8)
      #---------------------------------------------

          
          if mr_param.canal = 1 or    
          	 mr_param.canal = 4 then  
          
             if ma_ctc69m07[arr_aux].paccod is not null then
             
                 call ctc69m09(mr_param.plnclscod                  ,
                               ma_ctc69m07[arr_aux].srvplnclscod   ,
                               mr_param.clscod                     ,
                               mr_param.clsnom                     ,
                               ma_ctc69m07[arr_aux].paccod         ,
                               ma_ctc69m07[arr_aux].pacdes         ,
                               lr_param.empcod                     )
             end if 
         
          end if

      #---------------------------------------------
       on key (F9)
      #---------------------------------------------

          
          if mr_param.canal = 1 or   
          	 mr_param.canal = 2 or 
          	 mr_param.canal = 3 or   
             mr_param.canal = 4 or
             mr_param.canal = 5 then 
          
             if ma_ctc69m07[arr_aux].paccod is not null then
             
                 call ctc69m10(mr_param.plnclscod                  ,
                               ma_ctc69m07[arr_aux].srvplnclscod   ,
                               mr_param.clscod                     ,
                               mr_param.clsnom                     ,
                               ma_ctc69m07[arr_aux].paccod         ,
                               ma_ctc69m07[arr_aux].pacdes         )
             end if
          
          end if





  end input

 close window w_ctc69m07

 if lr_retorno.flag = 1 then
    call ctc69m07(mr_param.*)
 end if


end function


#---------------------------------------------------------
 function ctc69m07_func(lr_param)
#---------------------------------------------------------

 define lr_param    record
    funmat       like isskfunc.funmat,
    empcod       like isskfunc.empcod,
    usrtipcod    like isskfunc.usrtip
 end record

 define lr_retorno  record
    funnom   like isskfunc.funnom
 end record

if m_prepare is null or
  m_prepare <> true then
  call ctc69m07_prepare()
end if

 initialize lr_retorno.*    to null

   if lr_param.empcod is null or
      lr_param.empcod = " " then

      let lr_param.empcod = 1

   end if


   #--------------------------------------------------------
   # Recupera os Dados do Pacote X Clausula
   #--------------------------------------------------------

   open c_ctc69m07_008 using lr_param.empcod ,
                             lr_param.funmat ,
                             lr_param.usrtipcod
   whenever error continue
   fetch c_ctc69m07_008 into lr_retorno.funnom
   whenever error stop

 return lr_retorno.funnom

 end function


#---------------------------------------------------------
 function ctc69m07_dados_alteracao(lr_param)
#---------------------------------------------------------

define lr_param record
	srvplnclscod like  datksrvplncls.srvplnclscod
end record


   initialize mr_ctc69m07.* to null


   open c_ctc69m07_005 using lr_param.srvplnclscod

   whenever error continue
   fetch c_ctc69m07_005 into  mr_ctc69m07.empcod
                             ,mr_ctc69m07.usrmatnum
                             ,mr_ctc69m07.regatldat
                             ,mr_ctc69m07.usrtipcod

   whenever error stop

   call ctc69m07_func(mr_ctc69m07.usrmatnum, mr_ctc69m07.empcod, mr_ctc69m07.usrtipcod)
   returning mr_ctc69m07.funnom

   display by name  mr_ctc69m07.regatldat
                   ,mr_ctc69m07.funnom

end function


#==============================================
 function ctc69m07_delete(lr_param)
#==============================================

define lr_param record
		srvplnclscod like  datksrvplncls.srvplnclscod
end record

define lr_retorno record
	confirma char(1)
end record

initialize lr_retorno.* to null

  call cts08g01("A","S"
               ,"CONFIRMA EXCLUSAO"
               ,"DO CODIGO "
               ,"DO PACOTE?"
               ," ")
     returning lr_retorno.confirma

     if lr_retorno.confirma  = "S" then
        let m_operacao = 'd'

        begin work

        whenever error continue
        execute p_ctc69m07_006 using lr_param.srvplnclscod

        whenever error stop
        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Pacote!'
           rollback work
           return false
        end if


        if not ctc69m07_remove_associacao(lr_param.srvplnclscod) then
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
 function ctc69m07_inclui()
#---------------------------------------------------------

define lr_retorno record
   data_atual date
end record
initialize lr_retorno.* to null
    let lr_retorno.data_atual = today
    whenever error continue
    execute p_ctc69m07_004 using mr_param.plnclscod
                               , ma_ctc69m07[arr_aux].paccod
                               , ma_ctc69m07[arr_aux].paclim
                               , ma_ctc69m07[arr_aux].pacuni
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
 function ctc69m07_recupera_chave()
#---------------------------------------------------------

    open c_ctc69m07_007 using mr_param.plnclscod,
                              ma_ctc69m07[arr_aux].paccod
    whenever error continue
    fetch c_ctc69m07_007 into  ma_ctc69m07[arr_aux].srvplnclscod
    whenever error stop

    if sqlca.sqlcode <> 0 then
       error 'Erro (',sqlca.sqlcode,') ao Recuperar a Chave!'
    end if

end function

#==============================================
 function ctc69m07_remove_associacao(lr_param)
#==============================================

define lr_param record
		srvplnclscod like  datksrvplncls.srvplnclscod
end record


   whenever error continue
   execute p_ctc69m07_010 using lr_param.srvplnclscod

   whenever error stop
   if sqlca.sqlcode <> 0 then
      error 'ERRO (',sqlca.sqlcode,') ao Excluir a Cobertura!'
      return false
   end if

   whenever error continue
   execute p_ctc69m07_011 using lr_param.srvplnclscod

   whenever error stop
   if sqlca.sqlcode <> 0 then
      error 'ERRO (',sqlca.sqlcode,') ao Excluir a Categoria!'
      return false
   end if


   whenever error continue
   execute p_ctc69m07_013 using lr_param.srvplnclscod
   whenever error stop
   if sqlca.sqlcode <> 0 then
      error 'ERRO (',sqlca.sqlcode,') ao Excluir a Cidade!'
      return false
   end if


   whenever error continue
   execute p_ctc69m07_012 using lr_param.srvplnclscod

   whenever error stop
   if sqlca.sqlcode <> 0 then
      error 'ERRO (',sqlca.sqlcode,') ao Excluir a Classe!'
      return false
   end if

   return true


end function

#------------------------------------------------------------
 function ctc69m07_monta_xml(lr_entrada)
#------------------------------------------------------------
define lr_entrada record
    empcod  like datkplncls.empcod    ,
    procod  integer                   ,
    ramcod  like datkplncls.ramcod
end record
define l_xml_request char(3000)
  let l_xml_request = '<ns0:consultarPacoteRequestMQ xmlns:ns0="http://www.portoseguro.com.br/corporativo/business/BeneficioServicoEBS/V1_0/" xmlns:ns1="http://www.portoseguro.com.br/ebo/BeneficioServico/V1_0">',
                       '<ns0:Request>',
                         '<ns1:codigoEmpresa>',lr_entrada.empcod using "<<&",'</ns1:codigoEmpresa>',
                         '<ns1:codigoProduto>',lr_entrada.procod,'</ns1:codigoProduto>',
                         '<ns1:codigoRamo>',lr_entrada.ramcod using "<<<&",'</ns1:codigoRamo>',
                         '</ns0:Request>',
                      '</ns0:consultarPacoteRequestMQ>'

  return l_xml_request
end function

#------------------------------------------------------------
 function ctc69m07_pesquisa_xml(lr_entrada)
#------------------------------------------------------------

define lr_entrada record
    empcod  like datkplncls.empcod    ,
    procod  integer                   ,
    ramcod  like datkplncls.ramcod
end record

define lr_param record
   xml_request   char(32766) ,
   online        smallint    ,
   fila          char(20)    ,
   xml_response  char(32766) ,
   msg           char(200)   ,
   status        integer     ,
   cont1         integer     ,
   cont2         integer     ,
   cont3         integer     ,
   cont4         integer     ,
   descricao     char(1000)  ,
   erro          integer     ,
   msg_erro      char(100)
end record

define l_doc_handle integer
define l_idx1       integer
define l_idx2       integer
define l_idx3       integer
define l_idx4       integer

initialize lr_param.* to null

for l_idx1 = 1 to 200
	 initialize ma_retorno[l_idx1].* to null
end for

if not ctc69m07_cria_temp1() or
	 not ctc69m07_cria_temp2() or
	 not ctc69m07_cria_temp3() or
	 not ctc69m07_cria_temp4() then
    error  "Erro na Criacao da Tabela Temporaria!" sleep 5
    return false
else
	  call ctc69m07_prep_temp()
end if

let l_doc_handle = null
let lr_param.fila = "ATDBASERVPCTSOA01R"
let lr_param.online = online()

# ATIVA BIGCHAR
call setBigChar()

  let lr_param.xml_request = ctc69m07_monta_xml(lr_entrada.empcod,
                                                lr_entrada.procod,
                                                lr_entrada.ramcod)
 
 
 call figrc006_enviar_pseudo_mq(lr_param.fila               ,
                                lr_param.xml_request clipped,
                                lr_param.online)
      returning lr_param.status,
                lr_param.msg   ,
                lr_param.xml_response
 let lr_param.xml_response = figrc100_remove_namespace(lr_param.xml_response)


#display "Status "   ,lr_param.status
#display "Message "  ,lr_param.msg clipped
#display "Response " ,lr_param.xml_response clipped

 call figrc011_fim_parse()
 call figrc011_inicio_parse()

 let l_doc_handle = figrc011_parse_bigchar()


  #--------------------------------------------------------
  # Verifica se h� Erro na Chamada do XML
  #--------------------------------------------------------
 let lr_param.descricao  = "/consultarPacoteResponseMQ/Status/statusCode"
 let lr_param.erro       = figrc011_xpath(l_doc_handle,lr_param.descricao)
 if lr_param.erro <> 0 then
     let lr_param.descricao  = "/consultarPacoteResponseMQ/Status/message"
     let lr_param.msg_erro   = figrc011_xpath(l_doc_handle,lr_param.descricao)
     let lr_param.msg_erro   = figrc005_conv_acento(lr_param.msg_erro,7,5)
     error lr_param.msg_erro sleep 5
     return false
 end if
 let lr_param.cont1 = figrc011_xpath(l_doc_handle,"count(/consultarPacoteResponseMQ/Response/Pacotes/Pacote)")
  #--------------------------------------------------------
  # Estrutura de Pacotes
  #--------------------------------------------------------
  for l_idx1 = 1 to lr_param.cont1
     let lr_param.descricao          = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/codigoPacote"
     let ma_retorno[l_idx1].paccod    = figrc011_xpath(l_doc_handle,lr_param.descricao)
     let lr_param.descricao          = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/descricaoPacote"
     let ma_retorno[l_idx1].pacdes   = figrc011_xpath(l_doc_handle,lr_param.descricao)
     let ma_retorno[l_idx1].pacdes   = figrc005_conv_acento(ma_retorno[l_idx1].pacdes,7,5)
     let lr_param.descricao          = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/valorLimitePacote"
     let ma_retorno[l_idx1].paclim   = figrc011_xpath(l_doc_handle,lr_param.descricao)
     let lr_param.descricao          = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/descricaoUnidadeLimitePacote"
     let ma_retorno[l_idx1].pacuni   = figrc011_xpath(l_doc_handle,lr_param.descricao)
     let ma_retorno[l_idx1].pacuni   = figrc005_conv_acento(ma_retorno[l_idx1].pacuni,7,5)
     let lr_param.descricao          =  "count(/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/Servico)"
     let lr_param.cont2              = figrc011_xpath(l_doc_handle,lr_param.descricao)
     #--------------------------------------------------------
     # Estrutura de Servicos
     #--------------------------------------------------------
     for l_idx2 = 1 to lr_param.cont2
         let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/Servico[", l_idx2 using "<<<<&", "]/codigoServico"
         let ma_retorno[l_idx2].srvcod    = figrc011_xpath(l_doc_handle,lr_param.descricao)
         let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/Servico[", l_idx2 using "<<<<&", "]/descricaoServico"
         let ma_retorno[l_idx2].srvdes    = figrc011_xpath(l_doc_handle,lr_param.descricao)
         let ma_retorno[l_idx2].srvdes    = figrc005_conv_acento(ma_retorno[l_idx2].srvdes,7,5)
         let lr_param.descricao          =  "count(/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&", "]/Servico[", l_idx2 using "<<<<&", "]/Especialidades/Especialidade)"
         let lr_param.cont3              =  figrc011_xpath(l_doc_handle,lr_param.descricao)
         #--------------------------------------------------------
         # Estrutura de Especialidades
         #--------------------------------------------------------
         for l_idx3 = 1 to lr_param.cont3
             let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"
                                              , "]/Servico[", l_idx2 using "<<<<&"
                                              , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"
                                              , "]/codigoEspecialidade"
             let ma_retorno[l_idx3].espcod    = figrc011_xpath(l_doc_handle,lr_param.descricao)
             let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"
                                              , "]/Servico[", l_idx2 using "<<<<&"
                                              , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"
                                              , "]/descricaoEspecialidade"
             let ma_retorno[l_idx3].espdes    = figrc011_xpath(l_doc_handle,lr_param.descricao)
             let ma_retorno[l_idx3].espdes    = figrc005_conv_acento(ma_retorno[l_idx3].espdes,7,5)
             let lr_param.descricao          =  "count(/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"
                                              , "]/Servico[", l_idx2 using "<<<<&"
                                              , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"
                                              , "]/Limites/Limite)"
             let lr_param.cont4              =  figrc011_xpath(l_doc_handle,lr_param.descricao)
             #--------------------------------------------------------
             # Estrutura de Limites
             #--------------------------------------------------------
             for l_idx4 = 1 to lr_param.cont4
                 let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"
                                                  , "]/Servico[", l_idx2 using "<<<<&"
                                                  , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"
                                                  , "]/Limites/Limite[", l_idx4 using "<<<<&"
                                                  , "]/codigoTipoLimiteEspecialidade"
                 let ma_retorno[l_idx4].limcod    = figrc011_xpath(l_doc_handle,lr_param.descricao)
                 let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"
                                                  , "]/Servico[", l_idx2 using "<<<<&"
                                                  , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"
                                                  , "]/Limites/Limite[", l_idx4 using "<<<<&"
                                                  , "]/descricaoTipoLimiteEspecialidade"
                 let ma_retorno[l_idx4].limdes    = figrc011_xpath(l_doc_handle,lr_param.descricao)
                 let ma_retorno[l_idx4].limdes    = figrc005_conv_acento(ma_retorno[l_idx4].limdes,7,5)
                 let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"
                                                  , "]/Servico[", l_idx2 using "<<<<&"
                                                  , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"
                                                  , "]/Limites/Limite[", l_idx4 using "<<<<&"
                                                  , "]/valorLimiteEspecialidade"
                 let ma_retorno[l_idx4].limlim    = figrc011_xpath(l_doc_handle,lr_param.descricao)
                 let lr_param.descricao           = "/consultarPacoteResponseMQ/Response/Pacotes/Pacote[", l_idx1 using "<<<<&"
                                                  , "]/Servico[", l_idx2 using "<<<<&"
                                                  , "]/Especialidades/Especialidade[", l_idx3 using "<<<<&"
                                                  , "]/Limites/Limite[", l_idx4 using "<<<<&"
                                                  , "]/descricaoUnidadeLimiteEspecialidade"
                 let ma_retorno[l_idx4].limuni    = figrc011_xpath(l_doc_handle,lr_param.descricao)
                 let ma_retorno[l_idx4].limuni    = figrc005_conv_acento(ma_retorno[l_idx4].limuni,7,5)
                 #--------------------------------------------------------
                 # Grava os Dados do Limite
                 #--------------------------------------------------------

                 call ctc69m07_grava_limite( ma_retorno[l_idx1].paccod
                                            ,ma_retorno[l_idx2].srvcod
                                            ,ma_retorno[l_idx3].espcod
                                            ,ma_retorno[l_idx4].limcod
                                            ,ma_retorno[l_idx4].limdes
                                            ,ma_retorno[l_idx4].limlim
                                            ,ma_retorno[l_idx4].limuni)
             end for
             #--------------------------------------------------------
             # Grava os Dados da Especialidade
             #--------------------------------------------------------
             call ctc69m07_grava_especialidade( ma_retorno[l_idx1].paccod
                                               ,ma_retorno[l_idx2].srvcod
                                               ,ma_retorno[l_idx3].espcod
                                               ,ma_retorno[l_idx3].espdes)
         end for
         #--------------------------------------------------------
         # Grava os Dados do Servico
         #--------------------------------------------------------
         call ctc69m07_grava_servico( ma_retorno[l_idx1].paccod
                                     ,ma_retorno[l_idx2].srvcod
                                     ,ma_retorno[l_idx2].srvdes)
     end for
     #--------------------------------------------------------
     # Grava os Dados do Pacote
     #--------------------------------------------------------
     call ctc69m07_grava_pacote( ma_retorno[l_idx1].paccod
                                ,ma_retorno[l_idx1].pacdes
                                ,ma_retorno[l_idx1].paclim
                                ,ma_retorno[l_idx1].pacuni)

 end for

 # Desativa o Bigchar
 call unSetBigChar()

 return true


end function

#------------------------------------------------------------------------------
function ctc69m07_cria_temp1()
#------------------------------------------------------------------------------
 call ctc69m07_drop_temp1()
 whenever error continue
      create temp table pacote_temp (paccod  integer
                                    ,pacdes  char(60)
                                    ,paclim  dec(13,2)
                                    ,pacuni  char(60) ) with no log
      create index pacote_temp1 on pacote_temp (paccod)
 whenever error stop
 if sqlca.sqlcode <> 0  then
	  if sqlca.sqlcode = -310 or
	     sqlca.sqlcode = -958 then
	         call ctc69m07_drop_temp1()
	  end if
	  return false
 end if
 return true
end function

#------------------------------------------------------------------------------
function ctc69m07_cria_temp2()
#------------------------------------------------------------------------------
 call ctc69m07_drop_temp2()
 whenever error continue
      create temp table servico_temp (paccod  integer
                                     ,srvcod  integer
                                     ,srvdes  char(60)) with no log
      create index servico_temp1 on servico_temp (paccod)
      create index servico_temp2 on servico_temp (srvcod)
 whenever error stop

 if sqlca.sqlcode <> 0  then
	  if sqlca.sqlcode = -310 or
	     sqlca.sqlcode = -958 then
	         call ctc69m07_drop_temp2()
	  end if
	  return false
 end if
 return true
end function

#------------------------------------------------------------------------------
function ctc69m07_cria_temp3()
#------------------------------------------------------------------------------
 call ctc69m07_drop_temp3()
 whenever error continue
      create temp table especialidade_temp (paccod  integer
                                           ,srvcod  integer
                                           ,espcod  integer
                                           ,espdes  char(60)) with no log
      create index especialidade_temp1 on especialidade_temp (paccod)
      create index especialidade_temp2 on especialidade_temp (srvcod)
      create index especialidade_temp3 on especialidade_temp (espcod)
 whenever error stop

 if sqlca.sqlcode <> 0  then
	  if sqlca.sqlcode = -310 or
	     sqlca.sqlcode = -958 then
	         call ctc69m07_drop_temp3()
	  end if
	  return false
 end if
 return true
end function

#------------------------------------------------------------------------------
function ctc69m07_cria_temp4()
#------------------------------------------------------------------------------
 call ctc69m07_drop_temp4()
 whenever error continue
      create temp table limite_temp (paccod  integer
                                    ,srvcod  integer
                                    ,espcod  integer
                                    ,limcod  integer
                                    ,limdes  char(60)
                                    ,limlim  dec(13,2)
                                    ,limuni  char(60)) with no log
      create index limite_temp1 on limite_temp (paccod)
      create index limite_temp2 on limite_temp (srvcod)
      create index limite_temp3 on limite_temp (espcod)
      create index limite_temp4 on limite_temp (limcod)
 whenever error stop
 if sqlca.sqlcode <> 0  then
	  if sqlca.sqlcode = -310 or
	     sqlca.sqlcode = -958 then
	         call ctc69m07_drop_temp4()
	  end if
	  return false
 end if
 return true
end function

#------------------------------------------------------------------------------
function ctc69m07_drop_temp1()
#------------------------------------------------------------------------------
    whenever error continue
        drop table pacote_temp
    whenever error stop
    return
end function

#------------------------------------------------------------------------------
function ctc69m07_drop_temp2()
#------------------------------------------------------------------------------
    whenever error continue
        drop table servico_temp
    whenever error stop
    return
end function

#------------------------------------------------------------------------------
function ctc69m07_drop_temp3()
#------------------------------------------------------------------------------
    whenever error continue
        drop table especialidade_temp
    whenever error stop
    return
end function

#------------------------------------------------------------------------------
function ctc69m07_drop_temp4()
#------------------------------------------------------------------------------
    whenever error continue
        drop table limite_temp
    whenever error stop
    return
end function

#------------------------------------------------------------------------------
function ctc69m07_grava_pacote(lr_param)
#------------------------------------------------------------------------------
define lr_param record
  paccod  integer  ,
  pacdes  char(60) ,
  paclim  dec(13,2),
  pacuni  char(60)
end record
     whenever error continue
     execute  p_ctc69m07_003 using  lr_param.paccod
                                   ,lr_param.pacdes
                                   ,lr_param.paclim
                                   ,lr_param.pacuni
     whenever error stop
     if sqlca.sqlcode <> 0  then
       error "Erro ao Inserir o Pacote"
     end if
end function

#------------------------------------------------------------------------------
function ctc69m07_grava_servico(lr_param)
#------------------------------------------------------------------------------
define lr_param record
  paccod  integer  ,
  srvcod  integer  ,
  srvdes  char(60)
end record
     whenever error continue
     execute  p_ctc69m07_009 using  lr_param.paccod
                                   ,lr_param.srvcod
                                   ,lr_param.srvdes
     whenever error stop
     if sqlca.sqlcode <> 0  then
       error "Erro ao Inserir o Servico"
     end if
end function

#------------------------------------------------------------------------------
function ctc69m07_grava_especialidade(lr_param)
#------------------------------------------------------------------------------
define lr_param record
  paccod  integer  ,
  srvcod  integer  ,
  espcod  integer  ,
  espdes  char(60)
end record
     whenever error continue
     execute  p_ctc69m07_014 using  lr_param.paccod
                                   ,lr_param.srvcod
                                   ,lr_param.espcod
                                   ,lr_param.espdes
     whenever error stop
     if sqlca.sqlcode <> 0  then
       error "Erro ao Inserir a Especialidade"
     end if
end function

#------------------------------------------------------------------------------
function ctc69m07_grava_limite(lr_param)
#------------------------------------------------------------------------------
define lr_param record
  paccod  integer  ,
  srvcod  integer  ,
  espcod  integer  ,
  limcod  integer  ,
  limdes  char(60) ,
  limlim  dec(13,2),
  limuni  char(60)
end record
     whenever error continue
     execute  p_ctc69m07_015 using  lr_param.paccod
                                   ,lr_param.srvcod
                                   ,lr_param.espcod
                                   ,lr_param.limcod
                                   ,lr_param.limdes
                                   ,lr_param.limlim
                                   ,lr_param.limuni
     whenever error stop
     if sqlca.sqlcode <> 0  then
       error "Erro ao Inserir o Limite"
     end if
end function

#---------------------------------------------------------
 function ctc69m07_valida_inclusao()
#---------------------------------------------------------

define lr_retorno record
   data_atual date,
   cont       integer
end record

initialize lr_retorno.* to null

     #--------------------------------------------------------
     # Valida Se o Pacote Ja Existe
     #--------------------------------------------------------
     open c_ctc69m07_018 using ma_ctc69m07[arr_aux].paccod
     whenever error continue
     fetch c_ctc69m07_018 into lr_retorno.cont
     whenever error stop
     close c_ctc69m07_018
     if lr_retorno.cont =  0   then
         let lr_retorno.data_atual = today
         whenever error continue
         execute p_ctc69m07_019 using ma_ctc69m07[arr_aux].paccod
                                    , ma_ctc69m07[arr_aux].pacdes
                                    , g_issk.usrtip
                                    , g_issk.empcod
                                    , g_issk.funmat
                                    , lr_retorno.data_atual
         whenever error continue
         if sqlca.sqlcode = 0 then
            error 'Dados Incluidos com Sucesso!'
         else
            error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
            return false
         end if
     end if
     #--------------------------------------------------------
     # Valida Se o Agrupamento Ja Existe
     #--------------------------------------------------------
     open c_ctc69m07_020
     whenever error continue
     fetch c_ctc69m07_020 into lr_retorno.cont
     whenever error stop
     close c_ctc69m07_020
     if lr_retorno.cont =  0   then
         let lr_retorno.data_atual = today
         whenever error continue
         execute p_ctc69m07_021 using g_issk.usrtip
                                    , g_issk.empcod
                                    , g_issk.funmat
                                    , lr_retorno.data_atual
         whenever error continue
         if sqlca.sqlcode = 0 then
            error 'Dados Incluidos com Sucesso!'
         else
            error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
            return false
         end if
     end if
     #--------------------------------------------------------
     # Valida Se o Pacote Ja Existe na Associacao
     #--------------------------------------------------------
     open c_ctc69m07_016 using ma_ctc69m07[arr_aux].paccod
     whenever error continue
     fetch c_ctc69m07_016 into lr_retorno.cont
     whenever error stop
     close c_ctc69m07_016
     if lr_retorno.cont =  0   then
         let lr_retorno.data_atual = today
         whenever error continue
         execute p_ctc69m07_017 using ma_ctc69m07[arr_aux].paccod
                                    , ma_ctc69m07[arr_aux].paccod
                                    , g_issk.usrtip
                                    , g_issk.empcod
                                    , g_issk.funmat
                                    , lr_retorno.data_atual
         whenever error continue
         if sqlca.sqlcode = 0 then
            error 'Dados Incluidos com Sucesso!'
         else
            error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
            return false
         end if
     end if
     return true
end function



#------------------------------------------------------------
 function ctc69m07_recupera_produto(lr_param)                
#------------------------------------------------------------
                                                                            
define lr_param record                   
  ramcod  like datkplncls.ramcod,        
  empcod  like datkplncls.empcod                  
end record                                 

define lr_retorno record                                                    
  cponom  like datkdominio.cponom,                                                                              
  procod  integer                                           
end record                                                                  
                                                                            
initialize lr_retorno.* to null                                             
                                                                            
let lr_retorno.cponom = "ctc69m07_prod"                                     
                                                  
                                                                                                                                                       
  open c_ctc69m07_022 using  lr_retorno.cponom ,                            
                             lr_param.empcod   ,
                             lr_param.ramcod                            
  whenever error continue                                                   
  fetch c_ctc69m07_022 into lr_retorno.procod                               
  whenever error stop                                                       
                                                                                                      
                                                                            
  return lr_retorno.procod                                                           
  
end function                                                                
   