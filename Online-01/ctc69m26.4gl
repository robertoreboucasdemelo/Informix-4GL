#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Cadastro Central                                           #
# Modulo.........: ctc69m26                                                   #
# Objetivo.......: Cadastro de Parametros Azul                                #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 13/03/2015                                                 #
#.............................................................................#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define  m_sql       char(1)
define  arr_aux     integer

define mr_ctc69m26 record
      processa            char(01)
     ,flag_full           char(01)
     ,flag_diaria         char(01)
     ,azlaplcod_ini_full  integer
     ,azlaplcod_fim_full  integer
     ,azlaplcod_ini_dia   integer
     ,azlaplcod_fim_dia   integer
     ,qtd_quebra          integer
     ,atldat              date
     ,funmat              char(20)
end record

#------------------------------------------------------------
 function ctc69m26_prepare()
#------------------------------------------------------------

define l_sql char(10000)


 let l_sql =  ' select cpodes        '
             ,' from datkdominio     '
             ,' where cponom =  ?    '
             ,' and   cpocod =  ?    '
 prepare p_ctc69m26_001 from l_sql
 declare c_ctc69m26_001 cursor for p_ctc69m26_001


 let l_sql =  ' update datkdominio  '
          ,  '     set cpodes  = ?  '
          ,  '     ,   atlult  = ?  '
          ,  '   where cpocod  = ?  '
          ,  '     and cponom  = ?  '
 prepare p_ctc69m26_002 from l_sql

 let l_sql = '   select cpodes[01,10]        '
            ,'         ,cpodes[12,18]        '
            ,'    from datkdominio           '
            ,'    where cponom  =  ?         '
            ,'    and   cpocod  =  ?         '
 prepare p_ctc69m26_003 from l_sql
 declare c_ctc69m26_003 cursor for p_ctc69m26_003


 let l_sql =  ' insert into datkdominio   '
           ,  '   (cpocod                 '
           ,  '   ,cpodes                 '
           ,  '   ,cponom                 '
           ,  '   ,atlult)                '
           ,  ' values(?,?,?,?)           '
 prepare p_ctc69m26_005 from l_sql


 let l_sql = ' select count(*)    '
          ,  '   from datkdominio '
          ,  '  where cponom = ?  '
          ,  '  and   cpocod = ?  '
 prepare p_ctc69m26_007 from l_sql
 declare c_ctc69m26_007 cursor for p_ctc69m26_007

 let l_sql = ' select max(azlaplcod)     '
           , '  from datkazlapl          '
 prepare p_ctc69m26_008 from l_sql
 declare c_ctc69m26_008 cursor for p_ctc69m26_008



let m_sql = 'S'

end function

#------------------------------------------------------------
 function ctc69m26()
#------------------------------------------------------------

 let int_flag = false
 initialize mr_ctc69m26.* to null


 open window ctc69m26 at 4,2 with form "ctc69m26"

 call ctc69m26_prepare()

 call ctc69m26_consulta()

 call ctc69m26_input()


 close window ctc69m26

 end function


#------------------------------------------------------------
 function ctc69m26_consulta()
#------------------------------------------------------------


 let int_flag = false

 initialize mr_ctc69m26.*  to null

 #--------------------------------------------------------
 # Recupera Flag de Processamento Azul
 #--------------------------------------------------------
 call ctc69m26_recupera_dados("bdata007_azul")
 returning mr_ctc69m26.processa

 #--------------------------------------------------------
 # Recupera Flag de Processamento Full
 #--------------------------------------------------------
 call ctc69m26_recupera_dados("bdata007_full")
 returning mr_ctc69m26.flag_full

 #--------------------------------------------------------
 # Recupera Codigo Inicial da Apolice Full
 #--------------------------------------------------------
 call ctc69m26_recupera_dados("bdata007_full_ini")
 returning mr_ctc69m26.azlaplcod_ini_full

 #--------------------------------------------------------
 # Recupera Codigo Final da Apolice Full
 #--------------------------------------------------------
 call ctc69m26_recupera_dados("bdata007_full_ult")
 returning mr_ctc69m26.azlaplcod_fim_full

 #--------------------------------------------------------
 # Recupera Flag de Processamento Diaria
 #--------------------------------------------------------
 call ctc69m26_recupera_dados("bdata007_diaria")
 returning mr_ctc69m26.flag_diaria

 #--------------------------------------------------------
 # Recupera Codigo Inicial da Apolice Diaria
 #--------------------------------------------------------
 call ctc69m26_recupera_dados("bdata007_dia_ini")
 returning mr_ctc69m26.azlaplcod_ini_dia

 #--------------------------------------------------------
 # Recupera Codigo Final da Apolice Diaria
 #--------------------------------------------------------
 call ctc69m26_recupera_codigo_ultimo_diario()
 returning mr_ctc69m26.azlaplcod_fim_dia

 #--------------------------------------------------------
 # Recupera a Quantidade de Registros para Commit
 #--------------------------------------------------------
 call ctc69m26_recupera_dados("bdata007_quebra")
 returning mr_ctc69m26.qtd_quebra

 #--------------------------------------------------------
 # Recupera Matricula
 #--------------------------------------------------------
 call ctc69m26_recupera_matricula("ctc69m26_mat")
 returning mr_ctc69m26.atldat,
           mr_ctc69m26.funmat

 display by name mr_ctc69m26.*


end function


#--------------------------------------------------------------------
 function ctc69m26_input()
#--------------------------------------------------------------------

 define lr_retorno record
     erro        smallint,
     mensagem    char(60),
     count       smallint,
     confirma    char(01)
 end record


 let lr_retorno.count    = 0
 let lr_retorno.erro     = 0
 let lr_retorno.mensagem = null

 let int_flag = false

 input by name  mr_ctc69m26.processa
 	             ,mr_ctc69m26.flag_full
 	             ,mr_ctc69m26.flag_diaria
 	             ,mr_ctc69m26.azlaplcod_ini_full
 	             ,mr_ctc69m26.azlaplcod_fim_full
 	             ,mr_ctc69m26.azlaplcod_ini_dia
 	             ,mr_ctc69m26.qtd_quebra   without defaults



    before field processa
           display by name mr_ctc69m26.processa attribute (reverse)

    after  field processa
           display by name mr_ctc69m26.processa


           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
                 next field processa
           end if

           if  mr_ctc69m26.processa   is null or
           	  (mr_ctc69m26.processa  <> "S"   and
           	   mr_ctc69m26.processa  <> "N")  then
                 error "Por Favor Informe <S> ou <N>!!"
                 next field processa
           end if


    before field flag_full
           display by name mr_ctc69m26.flag_full attribute (reverse)

    after  field flag_full
           display by name mr_ctc69m26.flag_full


           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
                 next field processa
           end if

           if  mr_ctc69m26.flag_full   is null or
           	  (mr_ctc69m26.flag_full  <> "S"   and
           	   mr_ctc69m26.flag_full  <> "N")  then
                 error "Por Favor Informe <S> ou <N>!!"
                 next field flag_full
           end if


     before field flag_diaria
            display by name mr_ctc69m26.flag_diaria attribute (reverse)

     after  field flag_diaria
            display by name mr_ctc69m26.flag_diaria


            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
                  next field flag_full
            end if

            if   mr_ctc69m26.flag_diaria   is null or
            	  (mr_ctc69m26.flag_diaria  <> "S"   and
            	   mr_ctc69m26.flag_diaria  <> "N")  then
                  error "Por Favor Informe <S> ou <N>!!"
                  next field flag_diaria
            end if


     before field azlaplcod_ini_full
            display by name mr_ctc69m26.azlaplcod_ini_full attribute (reverse)

     after  field azlaplcod_ini_full
            display by name mr_ctc69m26.azlaplcod_ini_full


            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
                  next field flag_diaria
            end if

            if  mr_ctc69m26.azlaplcod_ini_full   is null then
                  error "Por Favor Informe um Codigo de Apolice!!"
                  next field azlaplcod_ini_full
            end if


     before field azlaplcod_fim_full
            display by name mr_ctc69m26.azlaplcod_fim_full attribute (reverse)

     after  field azlaplcod_fim_full
            display by name mr_ctc69m26.azlaplcod_fim_full


            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
                  next field azlaplcod_ini_full
            end if

            if  mr_ctc69m26.azlaplcod_fim_full   is null then
                  error "Por Favor Informe um Codigo de Apolice!!"
                  next field azlaplcod_fim_full
            end if


            if  mr_ctc69m26.azlaplcod_ini_full > mr_ctc69m26.azlaplcod_fim_full then
                  error "Codigo de Apolice Inicial Maior que Final!!"
                  next field azlaplcod_fim_full
            end if




     before field azlaplcod_ini_dia
            display by name mr_ctc69m26.azlaplcod_ini_dia attribute (reverse)

     after  field azlaplcod_ini_dia
            display by name mr_ctc69m26.azlaplcod_ini_dia


            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
                  next field azlaplcod_fim_full
            end if

            if   mr_ctc69m26.azlaplcod_ini_dia   is null then
                  error "Por Favor Informe um Codigo de Apolice!!"
                  next field azlaplcod_ini_dia
            end if


            if  mr_ctc69m26.azlaplcod_ini_dia > mr_ctc69m26.azlaplcod_fim_dia then
                 error "Codigo de Apolice Inicial Maior que Final!!"
                 next field azlaplcod_ini_dia
            end if



     before field qtd_quebra
            display by name mr_ctc69m26.qtd_quebra attribute (reverse)

     after  field qtd_quebra
            display by name mr_ctc69m26.qtd_quebra


            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
                  next field azlaplcod_ini_dia
            end if

            if   mr_ctc69m26.qtd_quebra   is null then
                  error "Por Favor Informe uma Quantidade Valida!!"
                  next field qtd_quebra
            end if

            call ctc69m26_grava_dados()

            display by name mr_ctc69m26.*



    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize mr_ctc69m26.*  to null
 end if

 prompt "Digite CTRL<C> para Sair" for char lr_retorno.confirma


 end function


#========================================================================
 function ctc69m26_recupera_dados(lr_param)
#========================================================================

define lr_param record
	cponom  like datkdominio.cponom
end record

define lr_retorno record
	cpocod  like datkdominio.cpocod,
	cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cpocod = 1


  open c_ctc69m26_001 using  lr_param.cponom   ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_ctc69m26_001 into lr_retorno.cpodes
  whenever error stop

  return lr_retorno.cpodes

#========================================================================
end function
#========================================================================

#========================================================================
 function ctc69m26_recupera_codigo_ultimo_diario()
#========================================================================

define lr_retorno record
	azlaplcod  like datkazlapl.azlaplcod
end record

initialize lr_retorno.* to null


  open c_ctc69m26_008
  whenever error continue
  fetch c_ctc69m26_008 into lr_retorno.azlaplcod
  whenever error stop

  return lr_retorno.azlaplcod

#========================================================================
end function
#========================================================================

#========================================================================
 function ctc69m26_valida_dados(lr_param)
#========================================================================

define lr_param record
	cponom  like datkdominio.cponom
end record

define lr_retorno record
	cpocod  like datkdominio.cpocod,
	cont    integer
end record

initialize lr_retorno.* to null

let lr_retorno.cpocod = 1
let lr_retorno.cont   = 0

  open c_ctc69m26_007 using  lr_param.cponom   ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_ctc69m26_007 into lr_retorno.cont
  whenever error stop

  if lr_retorno.cont > 0 then
  	return true
  else
  	return false
  end if

#========================================================================
end function
#========================================================================


#========================================================================
 function ctc69m26_grava_dados()
#========================================================================


 #--------------------------------------------------------
 # Grava Dados Flag de Processamento Azul
 #--------------------------------------------------------
 if ctc69m26_valida_dados("bdata007_azul") then
    call ctc69m26_atualiza_dados("bdata007_azul", mr_ctc69m26.processa)
 else
 	  call ctc69m26_inclui_dados("bdata007_azul", mr_ctc69m26.processa)
 end if

 #--------------------------------------------------------
 # Grava Dados Flag de Processamento Full
 #--------------------------------------------------------
 if ctc69m26_valida_dados("bdata007_full") then
    call ctc69m26_atualiza_dados("bdata007_full", mr_ctc69m26.flag_full)
 else
 	  call ctc69m26_inclui_dados("bdata007_full", mr_ctc69m26.flag_full)
 end if

 #--------------------------------------------------------
 # Grava Dados Codigo Inicial Apolice Full
 #--------------------------------------------------------
 if ctc69m26_valida_dados("bdata007_full_ini") then
    call ctc69m26_atualiza_dados("bdata007_full_ini", mr_ctc69m26.azlaplcod_ini_full)
 else
 	  call ctc69m26_inclui_dados("bdata007_full_ini", mr_ctc69m26.azlaplcod_ini_full)
 end if

 #--------------------------------------------------------
 # Grava Dados Codigo Final Apolice Full
 #--------------------------------------------------------
 if ctc69m26_valida_dados("bdata007_full_ult") then
    call ctc69m26_atualiza_dados("bdata007_full_ult", mr_ctc69m26.azlaplcod_fim_full)
 else
 	  call ctc69m26_inclui_dados("bdata007_full_ult", mr_ctc69m26.azlaplcod_fim_full)
 end if

 #--------------------------------------------------------
 # Grava Dados Flag de Processamento Diaria
 #--------------------------------------------------------
 if ctc69m26_valida_dados("bdata007_diaria") then
    call ctc69m26_atualiza_dados("bdata007_diaria", mr_ctc69m26.flag_diaria)
 else
 	  call ctc69m26_inclui_dados("bdata007_diaria", mr_ctc69m26.flag_diaria)
 end if

 #--------------------------------------------------------
 # Grava Dados Codigo Inicial Apolice Diaria
 #--------------------------------------------------------
 if ctc69m26_valida_dados("bdata007_dia_ini") then
    call ctc69m26_atualiza_dados("bdata007_dia_ini", mr_ctc69m26.azlaplcod_ini_dia)
 else
 	  call ctc69m26_inclui_dados("bdata007_dia_ini", mr_ctc69m26.azlaplcod_ini_dia)
 end if


 #--------------------------------------------------------
 # Grava Dados da Quebra de Commit
 #--------------------------------------------------------
 if ctc69m26_valida_dados("bdata007_quebra") then
    call ctc69m26_atualiza_dados("bdata007_quebra", mr_ctc69m26.qtd_quebra)
 else
 	  call ctc69m26_inclui_dados("bdata007_quebra", mr_ctc69m26.qtd_quebra)
 end if

 #--------------------------------------------------------
 # Grava Dados Matricula
 #--------------------------------------------------------
 if ctc69m26_valida_dados("ctc69m26_mat") then
    call ctc69m26_atualiza_matricula("ctc69m26_mat")
 else
 	  call ctc69m26_inclui_matricula("ctc69m26_mat")
 end if


#========================================================================
end function
#========================================================================

#========================================================================
 function ctc69m26_inclui_dados(lr_param)
#========================================================================

define lr_param record
	cponom  like datkdominio.cponom ,
	cpodes  like datkdominio.cpodes
end record

define lr_retorno record
	cpocod     like datkdominio.cpocod ,
	data_atual date                    ,
  atlult     like datkdominio.atlult
end record

initialize lr_retorno.* to null

let lr_retorno.cpocod = 1

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"

    whenever error continue
    execute p_ctc69m26_005 using lr_retorno.cpocod
                               , lr_param.cpodes
                               , lr_param.cponom
                               , lr_retorno.atlult

    whenever error continue

    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
    end if


end function

#========================================================================
 function ctc69m26_atualiza_dados(lr_param)
#========================================================================

define lr_param record
	cponom  like datkdominio.cponom,
	cpodes  like datkdominio.cpodes
end record

define lr_retorno record
	cpocod     like datkdominio.cpocod ,
	data_atual date                    ,
  atlult     like datkdominio.atlult
end record

initialize lr_retorno.* to null

let lr_retorno.cpocod = 1

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"

    whenever error continue
    execute p_ctc69m26_002 using lr_param.cpodes
                               , lr_retorno.atlult
                               , lr_retorno.cpocod
                               , lr_param.cponom
    whenever error continue

    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao dos Dados!'
    else
    	  error 'Dados Alterados com Sucesso!'
    end if

end function

#========================================================================
 function ctc69m26_inclui_matricula(lr_param)
#========================================================================

define lr_param record
	cponom  like datkdominio.cponom
end record

define lr_retorno record
	cpocod     like datkdominio.cpocod ,
	cpodes     like datkdominio.cpodes ,
	data_atual date                    ,
  atlult     like datkdominio.atlult
end record

initialize lr_retorno.* to null

let lr_retorno.cpocod = 1

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"
    let lr_retorno.cpodes = lr_retorno.atlult

    whenever error continue
    execute p_ctc69m26_005 using lr_retorno.cpocod
                               , lr_retorno.cpodes
                               , lr_param.cponom
                               , lr_retorno.atlult

    whenever error continue

    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
    end if

    let mr_ctc69m26.atldat  = lr_retorno.data_atual
    let mr_ctc69m26.funmat  = g_issk.funmat


end function

#========================================================================
 function ctc69m26_atualiza_matricula(lr_param)
#========================================================================

define lr_param record
	cponom  like datkdominio.cponom
end record

define lr_retorno record
	cpocod     like datkdominio.cpocod ,
	cpodes     like datkdominio.cpodes ,
	data_atual date                    ,
  atlult     like datkdominio.atlult
end record

initialize lr_retorno.* to null

let lr_retorno.cpocod = 1

    let lr_retorno.data_atual = today
    let lr_retorno.atlult = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"
    let lr_retorno.cpodes = lr_retorno.atlult

    whenever error continue
    execute p_ctc69m26_002 using lr_retorno.cpodes
                               , lr_retorno.atlult
                               , lr_retorno.cpocod
                               , lr_param.cponom
    whenever error continue

    if sqlca.sqlcode <> 0 then
        error 'ERRO(',sqlca.sqlcode,') na Alteracao dos Dados!'
    else
    	  error 'Dados Alterados com Sucesso!'
    end if

    let mr_ctc69m26.atldat  = lr_retorno.data_atual
    let mr_ctc69m26.funmat  = g_issk.funmat


end function

#========================================================================
 function ctc69m26_recupera_matricula(lr_param)
#========================================================================

define lr_param record
	cponom  like datkdominio.cponom
end record

define lr_retorno record
	cpocod  like datkdominio.cpocod,
	cpodes1 like datkdominio.cpodes,
	cpodes2 like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cpocod = 1


  open c_ctc69m26_003 using  lr_param.cponom   ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_ctc69m26_003 into lr_retorno.cpodes1 ,
                            lr_retorno.cpodes2
  whenever error stop

  return lr_retorno.cpodes1,
         lr_retorno.cpodes2

#========================================================================
end function
#========================================================================