#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m11                                                   #
# Objetivo.......: Cadastro Servico X Clausula/Plano X Classe Localizacao     #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 22/08/2013                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m11 array[500] of record
      lclclacod    like datklclclartc.lclclacod
    , clalcldes    char(60)
    , lclclartccod like datklclclartc.lclclartccod
end record

define mr_param   record
       plnclscod  like datkplncls.plnclscod
     , srvclscod  like datklclclartc.srvclscod
     , clscod     like datkplncls.clscod
     , clsnom     char(60)
     , srvcod     like datksrv.srvcod
     , srvnom     like datksrv.srvnom
end record

define mr_ctc69m11 record
      empcod         like datklclclartc.empcod
     ,usrmatnum      like datklclclartc.usrmatnum
     ,regatldat      like datklclclartc.regatldat
     ,funnom         like isskfunc.funnom
     ,usrtipcod      like datklclclartc.usrtipcod
end record

define ma_retorno array[500] of record
     ufdcod        char(02)
end record

define mr_replica   record
     cidcod   like datkrtcece.cidcod
end record



define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_cod_aux   like datklclclartc.lclclacod

define  m_prepare  smallint

#===============================================================================
 function ctc69m11_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select a.lclclartccod               '
          ,  '      , a.lclclacod                  '
          ,  '      , b.clalcldes                  '
          ,  '      , b.ufdcod                     '
          ,  '   from datklclclartc a,             '
          ,  '        agekregiao b,                '
          ,  '        itatvig c                    '
          ,  '  where a.lclclacod  = b.clalclcod   '
          ,  '  and   b.tabnum     = c.tabnum      '
          ,  '  and   c.tabnom     = "agekregiao"  '
          ,  '  and   c.viginc <= a.regatldat      '
          ,  '  and   c.vigfnl >= a.regatldat      '
          ,  '  and   a.srvclscod = ?              '
          ,  '  order by a.lclclacod               '
 prepare p_ctc69m11_001 from l_sql
 declare c_ctc69m11_001 cursor for p_ctc69m11_001

 let l_sql = ' select count(*)         '
          ,  '   from datklclclartc    '
          ,  '  where lclclacod = ?    '
          ,  '   and  srvclscod = ?    '
 prepare p_ctc69m11_002 from l_sql
 declare c_ctc69m11_002 cursor for p_ctc69m11_002


 let l_sql =  ' insert into datklclclartc   '
           ,  '   (srvclscod                '
           ,  '   ,lclclacod                '
           ,  '   ,usrtipcod                '
           ,  '   ,empcod                   '
           ,  '   ,usrmatnum                '
           ,  '   ,regatldat)               '
           ,  ' values(?,?,?,?,?,?)         '
 prepare p_ctc69m11_004 from l_sql


 let l_sql = '   select empcod             '
            ,'         ,usrmatnum          '
            ,'         ,regatldat          '
            ,'         ,usrtipcod          '
            ,'     from datklclclartc      '
            ,'    where lclclartccod =  ?  '
 prepare p_ctc69m11_005    from l_sql
 declare c_ctc69m11_005 cursor for p_ctc69m11_005


 let l_sql = '  delete datklclclartc      '
         ,  '   where lclclartccod  =  ?  '
 prepare p_ctc69m11_006 from l_sql


 let l_sql = '   select lclclartccod    '
            ,'    from datklclclartc    '
            ,'    where srvclscod =  ?  '
            ,'    and   lclclacod =  ?  '
 prepare p_ctc69m11_007    from l_sql
 declare c_ctc69m11_007 cursor for p_ctc69m11_007



 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc69m11_008 from l_sql
 declare c_ctc69m11_008 cursor for p_ctc69m11_008


 let l_sql = ' delete datkrtcece       '
           , '  where lclclartccod = ? '
 prepare p_ctc69m11_009 from l_sql


 let l_sql = ' select srvplnclscod     '
          ,  ' from datksrvplncls      '
          ,  ' where srvcod = ?        '
          ,  ' order by 1              '
 prepare p_ctc69m11_010 from l_sql
 declare c_ctc69m11_010 cursor for p_ctc69m11_010


 let l_sql = ' select cidcod            '
          ,  '   from datkrtcece        '
          ,  '  where lclclartccod = ?  '
          ,  '  order by cidcod         '
 prepare p_ctc69m11_011 from l_sql
 declare c_ctc69m11_011 cursor for p_ctc69m11_011


 let l_sql = ' select count(*)         '
          ,  '   from datkrtcece       '
          ,  '  where cidcod       = ? '
          ,  '   and  lclclartccod = ? '
 prepare p_ctc69m11_012 from l_sql
 declare c_ctc69m11_012 cursor for p_ctc69m11_012


 let l_sql =  ' insert into datkrtcece   '
           ,  '   (lclclartccod          '
           ,  '   ,cidcod                '
           ,  '   ,usrtipcod             '
           ,  '   ,empcod                '
           ,  '   ,usrmatnum             '
           ,  '   ,regatldat)            '
           ,  ' values(?,?,?,?,?,?)      '
 prepare p_ctc69m11_013 from l_sql


 let m_prepare = true


end function

#===============================================================================
 function ctc69m11(lr_param)
#===============================================================================

define lr_param record
    plnclscod  like datkplncls.plnclscod   ,
    srvclscod  like datklclclartc.srvclscod,
    clscod     like datkplncls.clscod      ,
    clsnom     char(60)                    ,
    srvcod     like datksrv.srvcod         ,
    srvnom     like datksrv.srvnom
end record

define lr_retorno record
    flag                smallint ,
    cont                integer  ,
    clalcldes           char(60) ,
    confirma            char(01)
end record

 let mr_param.plnclscod = lr_param.plnclscod
 let mr_param.srvclscod = lr_param.srvclscod
 let mr_param.clscod    = lr_param.clscod
 let mr_param.clsnom    = lr_param.clsnom
 let mr_param.srvcod    = lr_param.srvcod
 let mr_param.srvnom    = lr_param.srvnom

 for  arr_aux  =  1  to  500
    initialize  ma_ctc69m11[arr_aux].*, ma_retorno[arr_aux].* to  null
 end  for


 initialize mr_ctc69m11.*, lr_retorno.* to null

 let arr_aux = 1

 if m_prepare is null or
    m_prepare <> true then
    call ctc69m11_prepare()
 end if



 open window w_ctc69m11 at 6,2 with form 'ctc69m11'
 attribute(form line 1)

 message ' (F17)Sair(F1)Inclui(F2)Exclui(F7)Replica Classe(F8)Replica Todas(F9)Permite '

  display by name mr_param.clscod
                , mr_param.clsnom
                , mr_param.srvcod
                , mr_param.srvnom

 #--------------------------------------------------------
 # Recupera os Dados da Classe
 #--------------------------------------------------------

  open c_ctc69m11_001  using  mr_param.srvclscod
  foreach c_ctc69m11_001 into ma_ctc69m11[arr_aux].lclclartccod
  	                        , ma_ctc69m11[arr_aux].lclclacod
                            , ma_ctc69m11[arr_aux].clalcldes
                            , ma_retorno[arr_aux].ufdcod

       let arr_aux = arr_aux + 1

       if arr_aux > 500 then
          error " Localizacao Excedida! Foram Encontradas Mais de 500 Localizacoes!"
          exit foreach
       end if

  end foreach


  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if

 let m_operacao = " "

 call set_count(arr_aux - 1 )

 input array ma_ctc69m11 without defaults from s_ctc69m11.*

      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then

             if ma_ctc69m11[arr_aux].lclclacod  is null then
                let m_operacao = 'i'
             end if

          end if

      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'

         initialize  ma_ctc69m11[arr_aux] to null

         display ma_ctc69m11[arr_aux].lclclacod   to s_ctc69m11[scr_aux].lclclacod


      #---------------------------------------------
       before field lclclacod
      #---------------------------------------------

        if ma_ctc69m11[arr_aux].lclclacod  is null then
           display ma_ctc69m11[arr_aux].lclclacod  to s_ctc69m11[scr_aux].lclclacod  attribute(reverse)
           let m_operacao = 'i'
        else
          let m_cod_aux  = ma_ctc69m11[arr_aux].lclclacod
          display ma_ctc69m11[arr_aux].* to s_ctc69m11[scr_aux].* attribute(reverse)
          display ""  to s_ctc69m11[scr_aux].lclclartccod
        end if


        if m_operacao <> 'i' then
           call ctc69m11_dados_alteracao(ma_ctc69m11[arr_aux].lclclartccod)
        end if

      #---------------------------------------------
       after field lclclacod
      #---------------------------------------------

        if fgl_lastkey() = fgl_keyval ("down")     or
           fgl_lastkey() = fgl_keyval ("return")   then
           if m_operacao = 'i' then

           	if ma_ctc69m11[arr_aux].lclclacod  is null then

           		 #--------------------------------------------------------
           		 # Abre o Popup da Classe
           		 #--------------------------------------------------------

           		 call ctc69m04_popup_5(9)
           		 returning ma_ctc69m11[arr_aux].lclclacod
           		         , ma_ctc69m11[arr_aux].clalcldes
           		         , ma_retorno[arr_aux].ufdcod

           		 if ma_ctc69m11[arr_aux].lclclacod  is null then
           		    next field lclclacod
           		 end if
           	else

           		#--------------------------------------------------------
           		# Recupera a Descricao da Classe
           		#--------------------------------------------------------

           		call ctc69m04_recupera_descricao_5(9,ma_ctc69m11[arr_aux].lclclacod )
           		returning ma_ctc69m11[arr_aux].clalcldes,
           		          ma_retorno[arr_aux].ufdcod

           		if ma_ctc69m11[arr_aux].clalcldes is null then
           		   next field lclclacod
           		end if

             end if

             #--------------------------------------------------------
             # Valida Se a Classe Ja Foi Cadastrada
             #--------------------------------------------------------

             if not ctc69m11_valida() then
                error " Associacao ja Cadastrada!"
                next field lclclacod
             end if


             display ma_ctc69m11[arr_aux].lclclacod  to s_ctc69m11[scr_aux].lclclacod
             display ma_ctc69m11[arr_aux].clalcldes  to s_ctc69m11[scr_aux].clalcldes

             #--------------------------------------------------------
             # Inclui a Classe
             #--------------------------------------------------------
             call ctc69m11_inclui()

             #--------------------------------------------------------
             # Recupera o Serial da Classe
             #--------------------------------------------------------
             call ctc69m11_recupera_chave()

             next field lclclacod
           else
           	let ma_ctc69m11[arr_aux].lclclacod = m_cod_aux
           	display ma_ctc69m11[arr_aux].* to s_ctc69m11[scr_aux].*
           end if
       else
        	 if m_operacao = 'i' then
        	    let ma_ctc69m11[arr_aux].lclclacod = ''
        	    display ma_ctc69m11[arr_aux].* to s_ctc69m11[scr_aux].*
        	    let m_operacao = ' '
        	 else
        	    let ma_ctc69m11[arr_aux].lclclacod = m_cod_aux
        	    display ma_ctc69m11[arr_aux].* to s_ctc69m11[scr_aux].*
        	 end if
       end if


      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------

         exit input


      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc69m11[arr_aux].lclclartccod  is null   then
            continue input
         else

            if ctc69m06_valida_exclusao() then

               #--------------------------------------------------------
               # Exclui a Classe
               #--------------------------------------------------------

               if not ctc69m11_delete(ma_ctc69m11[arr_aux].lclclartccod) then
                   let lr_retorno.flag = 1
                   exit input
               end if

            else
            	 let lr_retorno.flag = 1
            	 exit input
            end if

            next field lclclacod

         end if


      #---------------------------------------------
       on key (F7)
      #---------------------------------------------

          if ma_ctc69m11[arr_aux].lclclacod is not null then
               call ctc69m11_replica_classe()
          end if
     #---------------------------------------------
      on key (F8)
     #---------------------------------------------

         if ma_ctc69m11[arr_aux].lclclacod is not null then
              call ctc69m11_replica_todas_classes()
         end if

     #---------------------------------------------
      on key (F9)
     #---------------------------------------------

         if ma_ctc69m11[arr_aux].lclclacod  is not null then

             call ctc69m17(ma_ctc69m11[arr_aux].lclclartccod  ,
                           mr_param.clscod                    ,
                           mr_param.clsnom                    ,
                           mr_param.srvcod                    ,
                           mr_param.srvnom                    ,
                           ma_ctc69m11[arr_aux].lclclacod     ,
                           ma_ctc69m11[arr_aux].clalcldes     ,
                           ma_retorno[arr_aux].ufdcod         )
         end if


  end input

 close window w_ctc69m11

 if lr_retorno.flag = 1 then
    call ctc69m11(mr_param.*)
 end if


end function


#---------------------------------------------------------
 function ctc69m11_func(lr_param)
#---------------------------------------------------------

 define lr_param   record
    funmat      like isskfunc.funmat,
    empcod      like isskfunc.empcod,
    usrtipcod   like isskfunc.usrtip
 end record

 define lr_retorno record
    funnom      like isskfunc.funnom
 end record

if m_prepare is null or
  m_prepare <> true then
  call ctc69m11_prepare()
end if

 initialize lr_retorno.*    to null

   if lr_param.empcod is null or
      lr_param.empcod = " " then

      let lr_param.empcod = 1

   end if

   #--------------------------------------------------------
   # Recupera os Dados do Funcionario
   #--------------------------------------------------------


   open c_ctc69m11_008 using lr_param.empcod ,
                             lr_param.funmat ,
                             lr_param.usrtipcod
   whenever error continue
   fetch c_ctc69m11_008 into lr_retorno.funnom
   whenever error stop

 return lr_retorno.funnom

 end function


#---------------------------------------------------------
 function ctc69m11_dados_alteracao(lr_param)
#---------------------------------------------------------

define lr_param record
	lclclartccod like datklclclartc.lclclartccod
end record


   initialize mr_ctc69m11.* to null


   open c_ctc69m11_005 using lr_param.lclclartccod

   whenever error continue
   fetch c_ctc69m11_005 into  mr_ctc69m11.empcod
                             ,mr_ctc69m11.usrmatnum
                             ,mr_ctc69m11.regatldat
                             ,mr_ctc69m11.usrtipcod

   whenever error stop


   call ctc69m11_func(mr_ctc69m11.usrmatnum, mr_ctc69m11.empcod, mr_ctc69m11.usrtipcod)
   returning mr_ctc69m11.funnom

   display by name  mr_ctc69m11.regatldat
                   ,mr_ctc69m11.funnom

end function

#==============================================
 function ctc69m11_delete(lr_param)
#==============================================

define lr_param record
	lclclartccod   like datklclclartc.lclclartccod
end record

define lr_retorno record
	confirma char(1)
end record

initialize lr_retorno.* to null

  call cts08g01("A","S"
               ,"CONFIRMA EXCLUSAO"
               ,"DO CODIGO "
               ,"DA CLASSE DE LOCALIZACAO ?"
               ," ")
     returning lr_retorno.confirma

     if lr_retorno.confirma  = "S" then
        let m_operacao = 'd'

        begin work

        whenever error continue
        execute p_ctc69m11_006 using lr_param.lclclartccod

        whenever error stop
        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Classe de Localizacao!'
           rollback work
           return false
        end if

        #--------------------------------------------------------
        # Exclui a Associacao com a Cidade
        #--------------------------------------------------------

        if not ctc69m11_remove_associacao(lr_param.lclclartccod) then
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
 function ctc69m11_inclui()
#---------------------------------------------------------

   whenever error continue
   execute p_ctc69m11_004 using mr_param.srvclscod
                              , ma_ctc69m11[arr_aux].lclclacod
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
 function ctc69m11_recupera_chave()
#---------------------------------------------------------

    open c_ctc69m11_007 using mr_param.srvclscod,
                              ma_ctc69m11[arr_aux].lclclacod
    whenever error continue
    fetch c_ctc69m11_007 into  ma_ctc69m11[arr_aux].lclclartccod
    whenever error stop


end function

#==============================================
 function ctc69m11_remove_associacao(lr_param)
#==============================================

define lr_param record
		lclclartccod like datklclclartc.lclclartccod
end record

   whenever error continue
   execute p_ctc69m11_009 using lr_param.lclclartccod

   whenever error stop
   if sqlca.sqlcode <> 0 then
      error 'ERRO (',sqlca.sqlcode,') ao Excluir a Cidade!'
      return false
   end if

   return true


end function

#---------------------------------------------------------
 function ctc69m11_valida()
#---------------------------------------------------------

define lr_retorno record
	 cont integer
end record

   #--------------------------------------------------------
   # Valida Se a Classe Ja Foi Cadastrada
   #--------------------------------------------------------

   open c_ctc69m11_002 using ma_ctc69m11[arr_aux].lclclacod  ,
                             mr_param.srvclscod
   whenever error continue
   fetch c_ctc69m11_002 into lr_retorno.cont
   whenever error stop

   if lr_retorno.cont >  0   then
      return false
   end if


   return true


end function

#---------------------------------------------------------
 function ctc69m11_replica_classe()
#---------------------------------------------------------

define lr_retorno record
	confirma  char(1)                              ,
	srvclscod     like datkcbtcss.srvclscod        ,
	lclclartccod  like datklclclartc.lclclartccod
end record

initialize lr_retorno.*, mr_replica.* to null

let lr_retorno.srvclscod    = mr_param.srvclscod
let lr_retorno.lclclartccod = ma_ctc69m11[arr_aux].lclclartccod

  call cts08g01("A","S"
               ,"CONFIRMA REPLICACAO"
               ,"DA CLASSE "
               ,"EM TODOS OS "
               ,"PACOTES? ")
     returning lr_retorno.confirma

     if lr_retorno.confirma  = "S" then


         #--------------------------------------------------------
         # Recupera os Dados do Servico
         #--------------------------------------------------------

         open c_ctc69m11_010 using mr_param.srvcod
         foreach c_ctc69m11_010 into mr_param.srvclscod


               #--------------------------------------------------------
               # Valida Se a Classe Ja Foi Cadastrada
               #--------------------------------------------------------

               if not ctc69m11_valida() then
                  continue foreach
               end if

               #--------------------------------------------------------
               # Inclui Classe
               #--------------------------------------------------------
               call ctc69m11_inclui()


               #--------------------------------------------------------
               # Recupera o Serial da Classe
               #--------------------------------------------------------
               call ctc69m11_recupera_chave()

               #--------------------------------------------------------
               # Recupera os Dados das Cidades
               #--------------------------------------------------------


               open c_ctc69m11_011 using lr_retorno.lclclartccod
               foreach c_ctc69m11_011 into mr_replica.cidcod

                   #--------------------------------------------------------
                   # Valida Se a Cidade Ja Foi Cadastrada
                   #--------------------------------------------------------

                   if not ctc69m11_valida_cidade() then
                      continue foreach
                   end if

                   #--------------------------------------------------------
                   # Inclui Cidade
                   #--------------------------------------------------------
                   call ctc69m11_inclui_cidade()


               end foreach


         end foreach

         let mr_param.srvclscod                 = lr_retorno.srvclscod
         let ma_ctc69m11[arr_aux].lclclartccod  = lr_retorno.lclclartccod

     end if



end function

#---------------------------------------------------------
 function ctc69m11_valida_cidade()
#---------------------------------------------------------

define lr_retorno record
	 cont integer
end record


   #--------------------------------------------------------
   # Valida se a Cidade Ja Foi Cadastrada
   #--------------------------------------------------------

   open c_ctc69m11_012 using mr_replica.cidcod                ,
                             ma_ctc69m11[arr_aux].lclclartccod
   whenever error continue
   fetch c_ctc69m11_012 into lr_retorno.cont
   whenever error stop

   if lr_retorno.cont >  0   then
      return false
   end if


   return true


end function

#---------------------------------------------------------
 function ctc69m11_inclui_cidade()
#---------------------------------------------------------

   whenever error continue
   execute p_ctc69m11_013 using ma_ctc69m11[arr_aux].lclclartccod
                              , mr_replica.cidcod
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
 function ctc69m11_replica_todas_classes()
#---------------------------------------------------------

define lr_retorno record
	confirma         char(1)                          ,
	srvclscod        like datkcbtcss.srvclscod        ,
	lclclartccod     like datklclclartc.lclclartccod  ,
	lclclacod        like datklclclartc.lclclacod     ,
	clalcldes        char(60)                         ,
	lclclartccod_ant like datklclclartc.lclclartccod  ,
	lclclacod_ant    like datklclclartc.lclclacod     ,
	ufcod            char(02)
end record

initialize lr_retorno.*, mr_replica.* to null

let lr_retorno.srvclscod        = mr_param.srvclscod
let lr_retorno.lclclartccod_ant = ma_ctc69m11[arr_aux].lclclartccod
let lr_retorno.lclclacod_ant    = ma_ctc69m11[arr_aux].lclclacod


  call cts08g01("A","S"
               ,"CONFIRMA REPLICACAO"
               ,"DE TODAS AS CLASSES "
               ,"EM TODOS OS "
               ,"PACOTES? ")
     returning lr_retorno.confirma

     if lr_retorno.confirma  = "S" then


         #--------------------------------------------------------
         # Recupera os Dados da Classe
         #--------------------------------------------------------

          open c_ctc69m11_001  using  mr_param.srvclscod
          foreach c_ctc69m11_001 into lr_retorno.lclclartccod
          	                        , lr_retorno.lclclacod
                                    , lr_retorno.clalcldes
                                    , lr_retorno.ufcod


               let ma_ctc69m11[arr_aux].lclclartccod = lr_retorno.lclclartccod
               let ma_ctc69m11[arr_aux].lclclacod    = lr_retorno.lclclacod
               #--------------------------------------------------------
               # Recupera os Dados do Servico
               #--------------------------------------------------------
               open c_ctc69m11_010 using mr_param.srvcod
               foreach c_ctc69m11_010 into mr_param.srvclscod
                     #--------------------------------------------------------
                     # Valida Se a Classe Ja Foi Cadastrada
                     #--------------------------------------------------------
                     if not ctc69m11_valida() then
                        continue foreach
                     end if
                     #--------------------------------------------------------
                     # Inclui Classe
                     #--------------------------------------------------------
                     call ctc69m11_inclui()
                     #--------------------------------------------------------
                     # Recupera o Serial da Classe
                     #--------------------------------------------------------
                     call ctc69m11_recupera_chave()
                     #--------------------------------------------------------
                     # Recupera os Dados das Cidades
                     #--------------------------------------------------------
                     open c_ctc69m11_011 using lr_retorno.lclclartccod
                     foreach c_ctc69m11_011 into mr_replica.cidcod
                         #--------------------------------------------------------
                         # Valida Se a Cidade Ja Foi Cadastrada
                         #--------------------------------------------------------
                         if not ctc69m11_valida_cidade() then
                            continue foreach
                         end if
                         #--------------------------------------------------------
                         # Inclui Cidade
                         #--------------------------------------------------------
                         call ctc69m11_inclui_cidade()
                     end foreach
               end foreach

         end foreach
         let mr_param.srvclscod                 = lr_retorno.srvclscod
         let ma_ctc69m11[arr_aux].lclclartccod  = lr_retorno.lclclartccod_ant
         let ma_ctc69m11[arr_aux].lclclacod     = lr_retorno.lclclacod_ant
     end if
end function
