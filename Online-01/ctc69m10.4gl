#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m10                                                   #
# Objetivo.......: Cadastro Servico X Clausula/Plano X Categoria Tarifaria    #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 22/08/2013                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc69m10 array[500] of record
      trfctgcod    integer
    , ctgtrfdes    char(60)
    , trfctgcsscod like datktrfctgcss.trfctgcsscod
end record

define mr_param   record
       plnclscod  like datkplncls.plnclscod
     , srvclscod  like datktrfctgcss.srvclscod
     , clscod     like datkplncls.clscod
     , clsnom     char(60)
     , srvcod     like datksrv.srvcod
     , srvnom     like datksrv.srvnom
end record

define mr_ctc69m10 record
      empcod      like datktrfctgcss.empcod
     ,usrmatnum   like datktrfctgcss.usrmatnum
     ,regatldat   like datktrfctgcss.regatldat
     ,funnom      like isskfunc.funnom
     ,usrtipcod   like datktrfctgcss.usrtipcod
end record


define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint
define m_cod_aux   integer

define  m_prepare  smallint

#===============================================================================
 function ctc69m10_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select a.trfctgcsscod                '
          ,  '      , a.trfctgcod                   '
          ,  '      , b.ctgtrfdes                   '
          ,  '   from datktrfctgcss a,              '
          ,  '        agekcateg b,                  '
          ,  '        itatvig c                     '
          ,  '  where a.trfctgcod  = b.ctgtrfcod    '
          ,  '  and   b.tabnum     = c.tabnum       '
          ,  '  and   c.tabnom     = "agekcateg"    '
          ,  '  and   c.viginc <= a.regatldat       '
          ,  '  and   c.vigfnl >= a.regatldat       '
          ,  '  and   b.ramcod = "531"              '
          ,  '  and   a.srvclscod = ?               '
          ,  '  order by a.trfctgcod                '
 prepare p_ctc69m10_001 from l_sql
 declare c_ctc69m10_001 cursor for p_ctc69m10_001

 let l_sql = ' select count(*)         '
          ,  '   from datktrfctgcss    '
          ,  '  where trfctgcod  = ?   '
          ,  '   and  srvclscod  = ?   '
 prepare p_ctc69m10_002 from l_sql
 declare c_ctc69m10_002 cursor for p_ctc69m10_002


 let l_sql =  ' insert into datktrfctgcss   '
           ,  '   (srvclscod                '
           ,  '   ,trfctgcod                '
           ,  '   ,usrtipcod                '
           ,  '   ,empcod                   '
           ,  '   ,usrmatnum                '
           ,  '   ,regatldat)               '
           ,  ' values(?,?,?,?,?,?)         '
 prepare p_ctc69m10_004 from l_sql


 let l_sql = '   select empcod              '
            ,'         ,usrmatnum           '
            ,'         ,regatldat           '
            ,'         ,usrtipcod           '
            ,'     from datktrfctgcss       '
            ,'    where trfctgcsscod   =  ? '
 prepare p_ctc69m10_005    from l_sql
 declare c_ctc69m10_005 cursor for p_ctc69m10_005


 let l_sql = '   select trfctgcsscod       '
            ,'   from datktrfctgcss        '
            ,'   where srvclscod =  ?      '
            ,'   and   trfctgcod =  ?      '
 prepare p_ctc69m10_006    from l_sql
 declare c_ctc69m10_006 cursor for p_ctc69m10_006


 let l_sql = '   delete datktrfctgcss    '
            ,'   where trfctgcsscod =  ? '
 prepare p_ctc69m10_007    from l_sql


 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '
             ,'       and usrtip = ?      '
 prepare p_ctc69m10_008 from l_sql
 declare c_ctc69m10_008 cursor for p_ctc69m10_008


 let l_sql = ' select srvplnclscod     '
          ,  ' from datksrvplncls      '
          ,  ' where srvcod = ?        '
          ,  ' order by 1              '
 prepare p_ctc69m10_009 from l_sql
 declare c_ctc69m10_009 cursor for p_ctc69m10_009


 let m_prepare = true


end function

#===============================================================================
 function ctc69m10(lr_param)
#===============================================================================

define lr_param record
	  plnclscod   like datkplncls.plnclscod   ,
    srvclscod   like datktrfctgcss.srvclscod,
    clscod      like datkplncls.clscod      ,
    clsnom      char(60)                    ,
    srvcod      like datksrv.srvcod         ,
    srvnom      like datksrv.srvnom
end record

define lr_retorno record
    flag                smallint ,
    cont                integer  ,
    ctgtrfdes           char(60) ,
    confirma            char(01)
end record

 let mr_param.plnclscod  = lr_param.plnclscod
 let mr_param.srvclscod  = lr_param.srvclscod
 let mr_param.clscod     = lr_param.clscod
 let mr_param.clsnom     = lr_param.clsnom
 let mr_param.srvcod     = lr_param.srvcod
 let mr_param.srvnom     = lr_param.srvnom

 for  arr_aux  =  1  to  500
    initialize  ma_ctc69m10[arr_aux].* to  null
 end  for


 initialize mr_ctc69m10.*, lr_retorno.* to null

 let arr_aux = 1

 if m_prepare is null or
    m_prepare <> true then
    call ctc69m10_prepare()
 end if



 open window w_ctc69m10 at 6,2 with form 'ctc69m10'
 attribute(form line 1)

 message ' (F17)Abandona,(F1)Inclui,(F2)Exclui,(F7)Replica Categoria,(F8)Replica Todas '

  display by name mr_param.clscod
                , mr_param.clsnom
                , mr_param.srvcod
                , mr_param.srvnom

  #--------------------------------------------------------
  # Recupera os Dados da Categoria
  #--------------------------------------------------------

  open c_ctc69m10_001  using  mr_param.srvclscod
  foreach c_ctc69m10_001 into ma_ctc69m10[arr_aux].trfctgcsscod
  	                        , ma_ctc69m10[arr_aux].trfctgcod
                            , ma_ctc69m10[arr_aux].ctgtrfdes


       let arr_aux = arr_aux + 1

       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontradas Mais de 500 Categorias!"
          exit foreach
       end if

  end foreach


  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if

 let m_operacao = " "

 call set_count(arr_aux - 1 )

 input array ma_ctc69m10 without defaults from s_ctc69m10.*

      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then

             if ma_ctc69m10[arr_aux].trfctgcod  is null then
                let m_operacao = 'i'
             end if

          end if

      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'

         initialize  ma_ctc69m10[arr_aux] to null

         display ma_ctc69m10[arr_aux].trfctgcod   to s_ctc69m10[scr_aux].trfctgcod



      #---------------------------------------------
       before field trfctgcod
      #---------------------------------------------

        if ma_ctc69m10[arr_aux].trfctgcod  is null then
           display ma_ctc69m10[arr_aux].trfctgcod  to s_ctc69m10[scr_aux].trfctgcod  attribute(reverse)
           let m_operacao = 'i'
        else
        	let m_cod_aux  = ma_ctc69m10[arr_aux].trfctgcod
          display ma_ctc69m10[arr_aux].* to s_ctc69m10[scr_aux].* attribute(reverse)
          display ""  to s_ctc69m10[scr_aux].trfctgcsscod
        end if


        if m_operacao <> 'i' then
           call ctc69m10_dados_alteracao(ma_ctc69m10[arr_aux].trfctgcsscod)
        end if

      #---------------------------------------------
       after field trfctgcod
      #---------------------------------------------

        if fgl_lastkey() = fgl_keyval ("down")     or
           fgl_lastkey() = fgl_keyval ("return")   then
            if m_operacao = 'i' then

            	if ma_ctc69m10[arr_aux].trfctgcod  is null then

            		 #--------------------------------------------------------
            		 # Abre o Popup da Categoria
            		 #--------------------------------------------------------

            		 call ctc69m04_popup(6)
            		 returning ma_ctc69m10[arr_aux].trfctgcod
            		         , ma_ctc69m10[arr_aux].ctgtrfdes

            		 if ma_ctc69m10[arr_aux].trfctgcod  is null then
            		    next field trfctgcod
            		 end if
            	else

            		#--------------------------------------------------------
            		# Recupera a Descricao da Categoria
            		#--------------------------------------------------------

            		call ctc69m04_recupera_descricao(6,ma_ctc69m10[arr_aux].trfctgcod )
            		returning ma_ctc69m10[arr_aux].ctgtrfdes

            		if ma_ctc69m10[arr_aux].ctgtrfdes is null then
            		   next field trfctgcod
            		end if

              end if


              #--------------------------------------------------------
              # Valida Se a Categoria Ja Foi Cadastrada
              #--------------------------------------------------------

              if not ctc69m10_valida() then
                 error " Associacao ja Cadastrada!"
                 next field trfctgcod
              end if


              display ma_ctc69m10[arr_aux].trfctgcod  to s_ctc69m10[scr_aux].trfctgcod
              display ma_ctc69m10[arr_aux].ctgtrfdes  to s_ctc69m10[scr_aux].ctgtrfdes

              #--------------------------------------------------------
              # Inclui a Categoria
              #--------------------------------------------------------
              call ctc69m10_inclui()

              #--------------------------------------------------------
              # Recupera a Serial da Categoria
              #--------------------------------------------------------
              call ctc69m10_recupera_chave()

              next field trfctgcod
            else
               let ma_ctc69m10[arr_aux].trfctgcod = m_cod_aux
           	   display ma_ctc69m10[arr_aux].* to s_ctc69m10[scr_aux].*
            end if
      else
       	 if m_operacao = 'i' then
       	    let ma_ctc69m10[arr_aux].trfctgcod = ''
       	    display ma_ctc69m10[arr_aux].* to s_ctc69m10[scr_aux].*
       	    let m_operacao = ' '
       	 else
       	    let ma_ctc69m10[arr_aux].trfctgcod = m_cod_aux
       	    display ma_ctc69m10[arr_aux].* to s_ctc69m10[scr_aux].*
       	 end if
      end if


      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input


     #---------------------------------------------
      on key (F7)
     #---------------------------------------------

         if ma_ctc69m10[arr_aux].trfctgcod is not null then
              call ctc69m10_replica_categoria()
         end if

     #---------------------------------------------
      on key (F8)
     #---------------------------------------------
         if ma_ctc69m10[arr_aux].trfctgcod is not null then
              call ctc69m10_replica_todas_categorias()
         end if

      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc69m10[arr_aux].trfctgcsscod  is null   then
            continue input
         else

            if ctc69m06_valida_exclusao() then
               if not ctc69m10_delete(ma_ctc69m10[arr_aux].trfctgcsscod) then
                   let lr_retorno.flag = 1
                   exit input
               end if
            else
            	 let lr_retorno.flag = 1
            	 exit input
            end if

            next field trfctgcod

         end if

  end input

 close window w_ctc69m10

 if lr_retorno.flag = 1 then
    call ctc69m10(mr_param.*)
 end if


end function


#---------------------------------------------------------
 function ctc69m10_func(lr_param)
#---------------------------------------------------------

 define lr_param  record
    funmat       like isskfunc.funmat,
    empcod       like isskfunc.empcod,
    usrtipcod    like isskfunc.usrtip
 end record

 define lr_retorno   record
    funnom    like isskfunc.funnom
 end record

if m_prepare is null or
  m_prepare <> true then
  call ctc69m10_prepare()
end if

 initialize lr_retorno.*    to null

   if lr_param.empcod is null or
      lr_param.empcod = " " then

      let lr_param.empcod = 1

   end if


   #--------------------------------------------------------
   # Recupera os Dados do Funcionario
   #--------------------------------------------------------

   open c_ctc69m10_008 using lr_param.empcod ,
                             lr_param.funmat ,
                             lr_param.usrtipcod
   whenever error continue
   fetch c_ctc69m10_008 into lr_retorno.funnom
   whenever error stop

 return lr_retorno.funnom

 end function


#---------------------------------------------------------
 function ctc69m10_dados_alteracao(lr_param)
#---------------------------------------------------------

define lr_param record
	trfctgcsscod like datktrfctgcss.trfctgcsscod
end record


   initialize mr_ctc69m10.* to null


   open c_ctc69m10_005 using lr_param.trfctgcsscod

   whenever error continue
   fetch c_ctc69m10_005 into  mr_ctc69m10.empcod
                             ,mr_ctc69m10.usrmatnum
                             ,mr_ctc69m10.regatldat
                             ,mr_ctc69m10.usrtipcod

   whenever error stop


   call ctc69m10_func(mr_ctc69m10.usrmatnum, mr_ctc69m10.empcod, mr_ctc69m10.usrtipcod)
   returning mr_ctc69m10.funnom

   display by name  mr_ctc69m10.regatldat
                   ,mr_ctc69m10.funnom

end function

#---------------------------------------------------------
 function ctc69m10_inclui()
#---------------------------------------------------------

    whenever error continue
    execute p_ctc69m10_004 using mr_param.srvclscod
                               , ma_ctc69m10[arr_aux].trfctgcod
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
 function ctc69m10_recupera_chave()
#---------------------------------------------------------

    open c_ctc69m10_006 using mr_param.srvclscod,
                              ma_ctc69m10[arr_aux].trfctgcod
    whenever error continue
    fetch c_ctc69m10_006 into  ma_ctc69m10[arr_aux].trfctgcsscod
    whenever error stop


end function

#==============================================
 function ctc69m10_delete(lr_param)
#==============================================

define lr_param record
	trfctgcsscod   like datktrfctgcss.trfctgcsscod
end record

define lr_retorno record
	confirma char(1)
end record

initialize lr_retorno.* to null

  call cts08g01("A","S"
               ,"CONFIRMA EXCLUSAO"
               ,"DO CODIGO "
               ,"DA CATEGORIA ?"
               ," ")
     returning lr_retorno.confirma

     if lr_retorno.confirma  = "S" then
        let m_operacao = 'd'

        whenever error continue
        execute p_ctc69m10_007 using lr_param.trfctgcsscod

        whenever error stop
        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') ao Excluir a Categoria!'
           return false
        end if
        return true
     else
        return false
     end if

end function

#---------------------------------------------------------
 function ctc69m10_valida()
#---------------------------------------------------------

define lr_retorno record
	 cont integer
end record

   #--------------------------------------------------------
   # Valida Se a Categoria Ja Foi Cadastrada
   #--------------------------------------------------------

   open c_ctc69m10_002 using ma_ctc69m10[arr_aux].trfctgcod  ,
                             mr_param.srvclscod
   whenever error continue
   fetch c_ctc69m10_002 into lr_retorno.cont
   whenever error stop

   if lr_retorno.cont >  0   then
      return false
   end if


   return true


end function

#---------------------------------------------------------
 function ctc69m10_replica_categoria()
#---------------------------------------------------------

define lr_retorno record
	confirma  char(1)                   ,
	srvclscod like datkcbtcss.srvclscod
end record

initialize lr_retorno.* to null

let lr_retorno.srvclscod = mr_param.srvclscod

  call cts08g01("A","S"
               ,"CONFIRMA REPLICACAO"
               ,"DA CATEGORIA "
               ,"EM TODOS OS "
               ,"PACOTES? ")
     returning lr_retorno.confirma

     if lr_retorno.confirma  = "S" then


         #--------------------------------------------------------
         # Recupera os Dados do Servico
         #--------------------------------------------------------

         open c_ctc69m10_009 using mr_param.srvcod
         foreach c_ctc69m10_009 into mr_param.srvclscod


               #--------------------------------------------------------
               # Valida Se a Categoria Ja Foi Cadastrada
               #--------------------------------------------------------

               if not ctc69m10_valida() then
                  continue foreach
               end if

               #--------------------------------------------------------
               # Inclui Categoria
               #--------------------------------------------------------
               call ctc69m10_inclui()


         end foreach

         let mr_param.srvclscod = lr_retorno.srvclscod

     end if



end function
#---------------------------------------------------------
 function ctc69m10_replica_todas_categorias()
#---------------------------------------------------------
define lr_retorno record
	confirma      char(1)                               ,
	srvclscod     like datkcbtcss.srvclscod             ,
	trfctgcod     integer                               ,
	ctgtrfdes     char(60)                              ,
	trfctgcsscod  like datktrfctgcss.trfctgcsscod       ,
	trfctgcod_ant integer
end record
initialize lr_retorno.* to null
let lr_retorno.srvclscod     = mr_param.srvclscod
let lr_retorno.trfctgcod_ant = ma_ctc69m10[arr_aux].trfctgcod
  call cts08g01("A","S"
               ,"CONFIRMA REPLICACAO"
               ,"DE TODAS CATEGORIAS "
               ,"EM TODOS OS "
               ,"PACOTES? ")
     returning lr_retorno.confirma
     if lr_retorno.confirma  = "S" then
     	    #--------------------------------------------------------
          # Recupera os Dados da Categoria
          #--------------------------------------------------------
          open c_ctc69m10_001  using  mr_param.srvclscod
          foreach c_ctc69m10_001 into lr_retorno.trfctgcsscod
          	                        , lr_retorno.trfctgcod
                                    , lr_retorno.ctgtrfdes
                 let ma_ctc69m10[arr_aux].trfctgcod = lr_retorno.trfctgcod
                 #--------------------------------------------------------
                 # Recupera os Dados do Servico
                 #--------------------------------------------------------
                 open c_ctc69m10_009 using mr_param.srvcod
                 foreach c_ctc69m10_009 into mr_param.srvclscod
                       #--------------------------------------------------------
                       # Valida Se a Categoria Ja Foi Cadastrada
                       #--------------------------------------------------------
                       if not ctc69m10_valida() then
                          continue foreach
                       end if
                       #--------------------------------------------------------
                       # Inclui Categoria
                       #--------------------------------------------------------
                       call ctc69m10_inclui()
                 end foreach
         end foreach
         let mr_param.srvclscod             = lr_retorno.srvclscod
         let ma_ctc69m10[arr_aux].trfctgcod = lr_retorno.trfctgcod_ant
     end if
end function