#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Cadastro Central                                           #
# Modulo.........: ctc53m07                                                   #
# Objetivo.......: Cadastro Limite X Assunto                                  #
# Analista Resp. : Humberto Benedito                                          #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 02/04/2014                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define ma_ctc53m07 array[500] of record
      clscod        like aackcls.clscod
    , clsdes        like aackcls.clsdes
    , datini        date
    , datfim        date
    , is            char(01)
    , okm           char(01)
    , limite        integer
    , flag_lim      char(01)
end record
define ma_retorno array[500] of record
    cpocod        like datkdominio.cpocod
end record

define mr_param   record
     codper     smallint,
     desper     char(60),
     c24astcod  like  datkassunto.c24astcod,
     c24astdes  like  datkassunto.c24astdes
end record

define mr_ctc53m07 record
      atldat          date
     ,funmat          char(20)
     ,msg             char(80)
     ,cpocod          like datkdominio.cpocod
end record

define m_operacao  char(1)
define arr_aux     smallint
define scr_aux     smallint

define  m_prepare  smallint

define m_chave     like datkdominio.cponom

#===============================================================================
 function ctc53m07_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = '  select cpodes[01,03],         '
         ,  '          cpodes[05,14],         '
         ,  '          cpodes[16,25],         '
         ,  '          cpodes[27,27],         '
         ,  '          cpodes[29,29],         '
         ,  '          cpodes[31,31],         '
         ,  '          cpodes[33,35],         '
         ,  '          cpocod                 '
         ,  '  from datkdominio               '
         ,  '  where cponom = ?               '
         ,  '  order by cpodes                '
 prepare p_ctc53m07_001 from l_sql
 declare c_ctc53m07_001 cursor for p_ctc53m07_001

 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '
          ,  ' where cponom = ?               '
          ,  ' and   cpodes[01,03] = ?        '
          ,  ' and   cpodes[05,14] <= ?       '
          ,  ' and   cpodes[16,25] >= ?       '
          ,  ' and   cpocod <>  ?             '
 prepare p_ctc53m07_002 from l_sql
 declare c_ctc53m07_002 cursor for p_ctc53m07_002

 let l_sql =  ' update datkdominio             '
           ,  '     set cpodes[05,14]    = ? , '
           ,  '         cpodes[16,25]    = ? , '
           ,  '         cpodes[27,27]    = ? , '
           ,  '         cpodes[29,29]    = ? , '
           ,  '         cpodes[31,31]    = ? , '
           ,  '         cpodes[33,35]    = ? , '
           ,  '         atlult[01,10]    = ? , '
           ,  '         atlult[12,18]    = ?   '
           ,  ' where cponom = ?               '
           ,  ' and cpodes[01,03] = ?          '
           ,  ' and cpocod = ?                 '
 prepare p_ctc53m07_003 from l_sql

 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 '
           ,  '   ,atlult)                '
           ,  ' values(?,?,?,?)           '
 prepare p_ctc53m07_004 from l_sql


 let l_sql = '   select atlult[01,10]        '
            ,'         ,atlult[12,18]        '
            ,'    from datkdominio           '
            ,'    where cponom  =  ?         '
            ,'    and   cpodes[01,03]  =  ?  '
 prepare p_ctc53m07_005    from l_sql
 declare c_ctc53m07_005 cursor for p_ctc53m07_005


 let l_sql = '  delete datkdominio           '
            ,'    where cponom  =  ?         '
            ,'    and   cpodes[01,03]  =  ?  '
            ,'    and   cpocod = ?           '
 prepare p_ctc53m07_006 from l_sql

 let l_sql = '   select max(cpocod)     '
            ,'   from datkdominio       '
            ,'   where cponom  =  ?     '
 prepare p_ctc53m07_007    from l_sql
 declare c_ctc53m07_007 cursor for p_ctc53m07_007


 let l_sql = ' select count(*)                '
          ,  ' from datkdominio               '
          ,  ' where cponom = ?               '
 prepare p_ctc53m07_008 from l_sql
 declare c_ctc53m07_008 cursor for p_ctc53m07_008

 let l_sql = ' select cpodes[05,14],          '
          ,  '        cpodes[16,25]   	      '
          ,  ' from datkdominio               '
          ,  ' where cponom = ?               '
          ,  ' and   cpodes[01,03] = ?        '
          ,  ' and   cpocod <> ?              '
 prepare p_ctc53m07_009 from l_sql
 declare c_ctc53m07_009 cursor for p_ctc53m07_009


 let m_prepare = true


end function

#===============================================================================
 function ctc53m07(lr_param)
#===============================================================================

define lr_param record
    codper     smallint,
    desper     char(60),
    c24astcod  like  datkassunto.c24astcod,
    c24astdes  like  datkassunto.c24astdes
end record

define lr_retorno record
    flag       smallint                     ,
    cont       integer                      ,
    datini     date                         ,
    datfim     date                         ,
    is         char(01)                     ,
    okm        char(01)                     ,
    limite     integer                      ,
    flag_lim   char(01)                     ,
    confirma   char(01)
end record

 let mr_param.codper     = lr_param.codper
 let mr_param.desper     = lr_param.desper
 let mr_param.c24astcod  = lr_param.c24astcod
 let mr_param.c24astdes  = lr_param.c24astdes

 for  arr_aux  =  1  to  500
    initialize  ma_ctc53m07[arr_aux].* to  null
    initialize  ma_retorno[arr_aux].* to null
 end  for


 initialize mr_ctc53m07.*, lr_retorno.* to null

 let arr_aux = 1

 if m_prepare is null or
    m_prepare <> true then
    call ctc53m07_prepare()
 end if

 let m_chave = ctc53m07_monta_chave(mr_param.codper, mr_param.c24astcod)

 open window w_ctc53m07 at 6,2 with form 'ctc53m07'
 attribute(form line 1)

 let mr_ctc53m07.msg =  '              (F17)Abandona,(F1)Inclui,(F2)Exclui,(F6)Naturezas'

  display by name mr_param.codper
                , mr_param.desper
                , mr_param.c24astcod
                , mr_param.c24astdes
                , mr_ctc53m07.msg

  #--------------------------------------------------------
  # Recupera os Dados do Assunto X Limite
  #--------------------------------------------------------

  open c_ctc53m07_001  using  m_chave
  foreach c_ctc53m07_001 into ma_ctc53m07[arr_aux].clscod   ,
  	                          ma_ctc53m07[arr_aux].datini   ,
                              ma_ctc53m07[arr_aux].datfim   ,
                              ma_ctc53m07[arr_aux].is       ,
                              ma_ctc53m07[arr_aux].okm      ,
                              ma_ctc53m07[arr_aux].flag_lim ,
                              ma_ctc53m07[arr_aux].limite   ,
                              ma_retorno[arr_aux].cpocod

       #--------------------------------------------------------
       # Recupera a Descricao da Natureza
       #--------------------------------------------------------

       call ctc69m04_recupera_descricao_6(11,ma_ctc53m07[arr_aux].clscod,531)
       returning ma_ctc53m07[arr_aux].clsdes

       let arr_aux = arr_aux + 1

       if arr_aux > 500 then
          error " Limite Excedido! Foram Encontrados Mais de 500 Clausulas!"
          exit foreach
       end if

  end foreach


  if arr_aux = 1  then
       error "Nao Foi Encontrado Nenhum Registro"
  end if

 let m_operacao = " "

 call set_count(arr_aux - 1 )

 input array ma_ctc53m07 without defaults from s_ctc53m07.*

      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then

             if ma_ctc53m07[arr_aux].clscod is null then
                let m_operacao = 'i'
             end if

          end if

      #---------------------------------------------
       before insert
      #---------------------------------------------
         let m_operacao = 'i'

         initialize  ma_ctc53m07[arr_aux] to null

         display ma_ctc53m07[arr_aux].clscod    to s_ctc53m07[scr_aux].clscod
         display ma_ctc53m07[arr_aux].clsdes    to s_ctc53m07[scr_aux].clsdes
         display ma_ctc53m07[arr_aux].datini    to s_ctc53m07[scr_aux].datini
         display ma_ctc53m07[arr_aux].datfim    to s_ctc53m07[scr_aux].datfim
         display ma_ctc53m07[arr_aux].is        to s_ctc53m07[scr_aux].is
         display ma_ctc53m07[arr_aux].okm       to s_ctc53m07[scr_aux].okm
         display ma_ctc53m07[arr_aux].limite    to s_ctc53m07[scr_aux].limite
         display ma_ctc53m07[arr_aux].flag_lim  to s_ctc53m07[scr_aux].flag_lim


      #---------------------------------------------
       before field clscod
      #---------------------------------------------

        if ma_ctc53m07[arr_aux].clscod is null then
           display ma_ctc53m07[arr_aux].clscod to s_ctc53m07[scr_aux].clscod attribute(reverse)
           let m_operacao = 'i'
        else
          display ma_ctc53m07[arr_aux].* to s_ctc53m07[scr_aux].* attribute(reverse)
        end if


        if m_operacao <> 'i' then

        	 #--------------------------------------------------------
        	 # Recupera os Dados Complementares do Assunto X Limite
        	 #--------------------------------------------------------

           call ctc53m07_dados_alteracao(ma_ctc53m07[arr_aux].clscod)
        end if

      #---------------------------------------------
       after field clscod
      #---------------------------------------------

        if m_operacao = 'i' then

        	if ma_ctc53m07[arr_aux].clscod is null then


        		 #--------------------------------------------------------
        		 # Abre o Popup do Servico
        		 #--------------------------------------------------------

        		 call ctc69m04_popup_2(11,531)
        		 returning ma_ctc53m07[arr_aux].clscod
        		         , ma_ctc53m07[arr_aux].clsdes

        		 if ma_ctc53m07[arr_aux].clscod is null then
        		    next field clscod
        		 end if
        	else

        		#--------------------------------------------------------
        		# Recupera a Descricao do Servico
        		#--------------------------------------------------------

        		call ctc69m04_recupera_descricao_6(11,ma_ctc53m07[arr_aux].clscod,531)
        		returning ma_ctc53m07[arr_aux].clsdes

        		if ma_ctc53m07[arr_aux].clsdes is null then
        		   next field clscod
        		end if

          end if



          display ma_ctc53m07[arr_aux].clscod to s_ctc53m07[scr_aux].clscod
          display ma_ctc53m07[arr_aux].clsdes to s_ctc53m07[scr_aux].clsdes


        else
        	display ma_ctc53m07[arr_aux].* to s_ctc53m07[scr_aux].*
        end if

     #---------------------------------------------
      before field datini
     #---------------------------------------------

         display ma_ctc53m07[arr_aux].datini  to s_ctc53m07[scr_aux].datini  attribute(reverse)
         let lr_retorno.datini = ma_ctc53m07[arr_aux].datini

     #---------------------------------------------
      after  field datini
     #---------------------------------------------


         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
               next field clscod
         end if

         if ma_ctc53m07[arr_aux].datini    is null   then
            error "Por Favor Informe a Data Inicial!"
            next field datini
         end if
         if ma_ctc53m07[arr_aux].datini = lr_retorno.datini then
         else
            if not ctc53m07_valida_data_inicial(ma_retorno[arr_aux].cpocod) then
            	  next field datini
            end if
         end if

     #---------------------------------------------
      before field datfim
     #---------------------------------------------

         display ma_ctc53m07[arr_aux].datfim   to s_ctc53m07[scr_aux].datfim   attribute(reverse)
         let lr_retorno.datfim = ma_ctc53m07[arr_aux].datfim

     #---------------------------------------------
      after  field datfim
     #---------------------------------------------


         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
               if m_operacao = 'i' then
               	  let ma_ctc53m07[arr_aux].datfim = null
               end if
               next field datini
         end if

         if ma_ctc53m07[arr_aux].datfim    is null   then
            error "Por Favor Informe a Data Final!"
            next field datfim
         end if

         if ma_ctc53m07[arr_aux].datfim < ma_ctc53m07[arr_aux].datini then
            error "Data Inicial Nao Pode ser Maior que a Data Final!"
            next field datfim
         end if

         if ma_ctc53m07[arr_aux].datfim = lr_retorno.datfim then
         else
            if not ctc53m07_valida_data_final(ma_retorno[arr_aux].cpocod) then
            	  next field datfim
            end if
         end if

     #---------------------------------------------
      before field is
     #---------------------------------------------

         if m_operacao = 'i' then
             let ma_ctc53m07[arr_aux].is = "N"
         end if

         display ma_ctc53m07[arr_aux].is  to s_ctc53m07[scr_aux].is  attribute(reverse)
         let lr_retorno.is = ma_ctc53m07[arr_aux].is

     #---------------------------------------------
      after  field is
     #---------------------------------------------


         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
               next field datfim
         end if

         if ma_ctc53m07[arr_aux].is  is null or
         	 (ma_ctc53m07[arr_aux].is <> "S"   and
         	  ma_ctc53m07[arr_aux].is <> "N")  then
            error "Por Favor Informe <S>im ou <N>ao!"
            next field is
         end if


     #---------------------------------------------
      before field okm
     #---------------------------------------------

         if m_operacao = 'i' then
             let ma_ctc53m07[arr_aux].okm = "N"
         end if

         display ma_ctc53m07[arr_aux].okm  to s_ctc53m07[scr_aux].okm  attribute(reverse)
         let lr_retorno.okm = ma_ctc53m07[arr_aux].okm

     #---------------------------------------------
      after  field okm
     #---------------------------------------------


         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
               next field is
         end if

         if ma_ctc53m07[arr_aux].okm  is null or
         	 (ma_ctc53m07[arr_aux].okm <> "S"   and
         	  ma_ctc53m07[arr_aux].okm <> "N")  then
            error "Por Favor Informe <S>im ou <N>ao!"
            next field okm
         end if


     #---------------------------------------------
      before field limite
     #---------------------------------------------
         display ma_ctc53m07[arr_aux].limite   to s_ctc53m07[scr_aux].limite   attribute(reverse)
         let lr_retorno.limite = ma_ctc53m07[arr_aux].limite

     #---------------------------------------------
      after  field limite
     #---------------------------------------------


         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
               next field okm
         end if

         if ma_ctc53m07[arr_aux].limite    is null   then
            error "Por Favor Informe o Limite!"
            next field limite
         end if


     #---------------------------------------------
      before field flag_lim
     #---------------------------------------------
         display ma_ctc53m07[arr_aux].flag_lim  to s_ctc53m07[scr_aux].flag_lim  attribute(reverse)
         let lr_retorno.flag_lim = ma_ctc53m07[arr_aux].flag_lim

     #---------------------------------------------
      after  field flag_lim
     #---------------------------------------------


         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
               next field limite
         end if

         if ma_ctc53m07[arr_aux].flag_lim  is null or
         	 (ma_ctc53m07[arr_aux].flag_lim <> "S"   and
         	  ma_ctc53m07[arr_aux].flag_lim <> "N")  then
            error "Por Favor Informe <S>im ou <N>ao!"
            next field flag_lim
         end if



         if m_operacao <> 'i' then

            if ma_ctc53m07[arr_aux].datini     <> lr_retorno.datini   or
               ma_ctc53m07[arr_aux].datfim     <> lr_retorno.datfim   or
               ma_ctc53m07[arr_aux].limite     <> lr_retorno.limite   or
               ma_ctc53m07[arr_aux].is         <> lr_retorno.is       or
               ma_ctc53m07[arr_aux].okm        <> lr_retorno.okm      or
               ma_ctc53m07[arr_aux].flag_lim   <> lr_retorno.flag_lim then


                  #--------------------------------------------------------
                  # Atualiza Associacao Assunto X Limite
                  #--------------------------------------------------------

                  call ctc53m07_altera()
                  next field clscod
            end if

            let m_operacao = ' '
         else

            #--------------------------------------------------------
            # Recupera Codigo da Associacao Perfil X Assunto
            #--------------------------------------------------------
            call ctc53m07_recupera_chave()

            #--------------------------------------------------------
            # Inclui Associacao Limite X Assunto
            #--------------------------------------------------------
            call ctc53m07_inclui()

            next field clscod
         end if

         if ma_ctc53m07[arr_aux].flag_lim = "S" then

             call ctc53m08(mr_param.codper                  ,
                           mr_param.desper                  ,
                           mr_param.c24astcod               ,
                           mr_param.c24astdes               ,
                           ma_ctc53m07[arr_aux].clscod      ,
                           ma_ctc53m07[arr_aux].clsdes      ,
                           ma_retorno[arr_aux].cpocod       )

         end if


         display ma_ctc53m07[arr_aux].clscod     to s_ctc53m07[scr_aux].clscod
         display ma_ctc53m07[arr_aux].clsdes     to s_ctc53m07[scr_aux].clsdes
         display ma_ctc53m07[arr_aux].datini     to s_ctc53m07[scr_aux].datini
         display ma_ctc53m07[arr_aux].datfim     to s_ctc53m07[scr_aux].datfim
         display ma_ctc53m07[arr_aux].is         to s_ctc53m07[scr_aux].is
         display ma_ctc53m07[arr_aux].okm        to s_ctc53m07[scr_aux].okm
         display ma_ctc53m07[arr_aux].limite     to s_ctc53m07[scr_aux].limite
         display ma_ctc53m07[arr_aux].flag_lim   to s_ctc53m07[scr_aux].flag_lim



      #---------------------------------------------
       on key (interrupt)
      #---------------------------------------------
         exit input


      #---------------------------------------------
       before delete
      #---------------------------------------------
         if ma_ctc53m07[arr_aux].clscod  is null   then
            continue input
         else


            if ctc53m08_valida_exclusao(mr_param.codper, mr_param.c24astcod, ma_ctc53m07[arr_aux].clscod, ma_retorno[arr_aux].cpocod) then

                #--------------------------------------------------------
                # Exclui Associacao Servico X Clausula
                #--------------------------------------------------------

                if not ctc53m07_delete(ma_ctc53m07[arr_aux].clscod) then
                    let lr_retorno.flag = 1
                    exit input
                end if


                next field clscod
            else
            	  error "Naturezas Cadastradas para Essa Clausula! Por Favor Exclua-os Primeiro."
            	  let lr_retorno.flag = 1
                exit input
            end if

         end if

   #---------------------------------------------
    on key (F6)
   #---------------------------------------------

       if ma_ctc53m07[arr_aux].flag_lim = "S" then

           call ctc53m08(mr_param.codper                  ,
                         mr_param.desper                  ,
                         mr_param.c24astcod               ,
                         mr_param.c24astdes               ,
                         ma_ctc53m07[arr_aux].clscod      ,
                         ma_ctc53m07[arr_aux].clsdes      ,
                         ma_retorno[arr_aux].cpocod       )

       end if



  end input

 close window w_ctc53m07

 if lr_retorno.flag = 1 then
    call ctc53m07(mr_param.*)
 end if


end function


#---------------------------------------------------------
 function ctc53m07_dados_alteracao(lr_param)
#---------------------------------------------------------

define lr_param record
	clscod     like aackcls.clscod
end record


   initialize mr_ctc53m07.* to null


   open c_ctc53m07_005 using m_chave,
                             lr_param.clscod

   whenever error continue
   fetch c_ctc53m07_005 into  mr_ctc53m07.atldat
                             ,mr_ctc53m07.funmat


   whenever error stop


   display by name  mr_ctc53m07.atldat
                   ,mr_ctc53m07.funmat


end function


#==============================================
 function ctc53m07_delete(lr_param)
#==============================================

define lr_param record
		clscod     like aackcls.clscod
end record

define lr_retorno record
	confirma char(1)
end record

initialize lr_retorno.* to null

  call cts08g01("A","S"
               ,"CONFIRMA EXCLUSAO"
               ,"DO CODIGO "
               ,"DO LIMITE ?"
               ," ")
     returning lr_retorno.confirma

     if lr_retorno.confirma  = "S" then
        let m_operacao = 'd'

        begin work

        whenever error continue
        execute p_ctc53m07_006 using m_chave          ,
                                     lr_param.clscod  ,
                                     ma_retorno[arr_aux].cpocod

        whenever error stop
        if sqlca.sqlcode <> 0 then
           error 'ERRO (',sqlca.sqlcode,') ao Excluir o Limite!'
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
 function ctc53m07_altera()
#---------------------------------------------------------

define lr_retorno record
   data_atual date,
   funmat     like isskfunc.funmat
end record

initialize lr_retorno.* to null

    let lr_retorno.data_atual = today
    let lr_retorno.funmat     = g_issk.funmat using "&&&&&&"

    whenever error continue
    execute p_ctc53m07_003 using ma_ctc53m07[arr_aux].datini
                               , ma_ctc53m07[arr_aux].datfim
                               , ma_ctc53m07[arr_aux].is
                               , ma_ctc53m07[arr_aux].okm
                               , ma_ctc53m07[arr_aux].flag_lim
                               , ma_ctc53m07[arr_aux].limite
                               , lr_retorno.data_atual
                               , lr_retorno.funmat
                               , m_chave
                               , ma_ctc53m07[arr_aux].clscod
                               , ma_retorno[arr_aux].cpocod
    whenever error continue

    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao do Limite!'
    else
    	  error 'Dados Alterados com Sucesso!'
    end if

    let m_operacao = ' '

end function

#---------------------------------------------------------
 function ctc53m07_inclui()
#---------------------------------------------------------

define lr_retorno record
   data_atual date                    ,
   cpodes     like datkdominio.cpodes ,
   atlult     like datkdominio.atlult
end record

initialize lr_retorno.* to null

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"
    let lr_retorno.cpodes = ma_ctc53m07[arr_aux].clscod               , "|",
                            ma_ctc53m07[arr_aux].datini   clipped     , "|",
                            ma_ctc53m07[arr_aux].datfim   clipped     , "|",
                            ma_ctc53m07[arr_aux].is       clipped     , "|",
                            ma_ctc53m07[arr_aux].okm      clipped     , "|",
                            ma_ctc53m07[arr_aux].flag_lim clipped     , "|",
                            ma_ctc53m07[arr_aux].limite   using "&&&"

    whenever error continue
    execute p_ctc53m07_004 using mr_ctc53m07.cpocod
                               , lr_retorno.cpodes
                               , m_chave
                               , lr_retorno.atlult

    whenever error continue

    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'
       let m_operacao = ' '
       let ma_retorno[arr_aux].cpocod = mr_ctc53m07.cpocod
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao do Limite!'
    end if

end function

#===============================================================================
 function ctc53m07_monta_chave(lr_param)
#===============================================================================

define lr_param record
    codper     smallint,
    c24astcod  like  datkassunto.c24astcod
end record

define lr_retorno record
	  chave like datkdominio.cponom
end record

initialize lr_retorno.* to null

 let lr_retorno.chave = "PF_", lr_param.codper using "&&", "_ASS" ,"_LIM_", lr_param.c24astcod clipped

 return lr_retorno.chave

end function

#---------------------------------------------------------
 function ctc53m07_recupera_chave()
#---------------------------------------------------------

    open c_ctc53m07_007 using m_chave
    whenever error continue
    fetch c_ctc53m07_007 into mr_ctc53m07.cpocod
    whenever error stop

    if mr_ctc53m07.cpocod is null or
    	 mr_ctc53m07.cpocod = ""    or
    	 mr_ctc53m07.cpocod = 0     then
    	 	let mr_ctc53m07.cpocod = 1
    else
    	  let mr_ctc53m07.cpocod = mr_ctc53m07.cpocod + 1
    end if

end function

#---------------------------------------------------------
 function ctc53m07_valida_exclusao(lr_param)
#---------------------------------------------------------

define lr_param record
    codper     smallint,
    c24astcod  like  datkassunto.c24astcod
end record


define lr_retorno record
	cont integer
end record

if m_prepare is null or
    m_prepare <> true then
    call ctc53m07_prepare()
end if

   initialize lr_retorno.* to null

   let m_chave = ctc53m07_monta_chave(lr_param.codper, lr_param.c24astcod)

   open c_ctc53m07_008 using m_chave

   whenever error continue
   fetch c_ctc53m07_008 into  lr_retorno.cont
   whenever error stop

   if lr_retorno.cont > 0 then
      return false
   else
   	  return true
   end if

end function
#---------------------------------------------------------
 function ctc53m07_valida_data_inicial(lr_param)
#---------------------------------------------------------
define lr_param record
   cpocod like datkdominio.cpocod
end record
define lr_retorno  record
   cont       integer
 , vigincdat  date
 , vigfnldat  date
end record
initialize lr_retorno.* to null
        if lr_param.cpocod is null then
        	 let lr_param.cpocod = 0
        end if
        #--------------------------------------------------------
        # Valida Se a Associacao Assunto X Limite Ja Existe
        #--------------------------------------------------------
        open c_ctc53m07_002 using m_chave,
                                  ma_ctc53m07[arr_aux].clscod,
                                  ma_ctc53m07[arr_aux].datini,
                                  ma_ctc53m07[arr_aux].datini,
                                  lr_param.cpocod
        whenever error continue
        fetch c_ctc53m07_002 into lr_retorno.cont
        whenever error stop
        if lr_retorno.cont >  0   then
           error " Clausula ja Cadastrada Para Este Assunto e Data Inicial!!"
           return false
        end if
       #--------------------------------------------------------
       # Recupera as Datas Ja Existentes
       #--------------------------------------------------------
       open c_ctc53m07_009  using  m_chave                      ,
                                   ma_ctc53m07[arr_aux].clscod  ,
                                   lr_param.cpocod
       foreach c_ctc53m07_009 into lr_retorno.vigincdat   ,
       	                           lr_retorno.vigfnldat
            if  ma_ctc53m07[arr_aux].datini <= lr_retorno.vigincdat and
                ma_ctc53m07[arr_aux].datfim >= lr_retorno.vigincdat then
                   error "Ja Existe uma Clausula que Contem essa Vigencia Inicial!"
                   return false
            end if
       end foreach
       return true
end function
#---------------------------------------------------------
 function ctc53m07_valida_data_final(lr_param)
#---------------------------------------------------------
define lr_param record
   cpocod like datkdominio.cpocod
end record
define lr_retorno  record
   cont       integer
 , vigincdat  date
 , vigfnldat  date
end record
initialize lr_retorno.* to null
        if lr_param.cpocod is null then
        	 let lr_param.cpocod = 0
        end if
        #--------------------------------------------------------
        # Valida Se a Associacao Assunto X Limite Ja Existe
        #--------------------------------------------------------
        open c_ctc53m07_002 using m_chave,
                                  ma_ctc53m07[arr_aux].clscod,
                                  ma_ctc53m07[arr_aux].datfim,
                                  ma_ctc53m07[arr_aux].datfim,
                                  lr_param.cpocod
        whenever error continue
        fetch c_ctc53m07_002 into lr_retorno.cont
        whenever error stop
        if lr_retorno.cont >  0   then
           error " Clausula ja Cadastrada Para Este Assunto e Data Final!!"
           return false
        end if
       #--------------------------------------------------------
       # Recupera as Datas Ja Existentes
       #--------------------------------------------------------
       open c_ctc53m07_009  using  m_chave                      ,
                                   ma_ctc53m07[arr_aux].clscod  ,
                                   lr_param.cpocod
       foreach c_ctc53m07_009 into lr_retorno.vigincdat   ,
       	                           lr_retorno.vigfnldat
            if  ma_ctc53m07[arr_aux].datini <= lr_retorno.vigfnldat and
                ma_ctc53m07[arr_aux].datfim >= lr_retorno.vigfnldat then
                   error "Ja Existe um Segmento que Contem essa Vigencia Final!"
                   return false
            end if
       end foreach
       return true
end function