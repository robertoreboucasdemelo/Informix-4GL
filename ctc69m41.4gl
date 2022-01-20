#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctc69m41                                                   #
# Objetivo.......: Cadastro de Regras Azul                                    #
# Analista Resp. : R.Fornax                                                   #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 27/03/2016                                                 #
#.............................................................................#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define  m_sql       char(1)
define  m_irdclsflg char(1)
define  arr_aux     integer
define  m_prfcod    like datkplncls.prfcod    

define mr_retorno  record
   srvplnclscod     like datksrvplncls.srvplnclscod,
   lclclartccod     like datklclclartc.lclclartccod
end record

#------------------------------------------------------------
 function ctc69m41_prepare()
#------------------------------------------------------------

define l_sql char(10000)


 let l_sql = ' select plnclscod       '
           , '  from datkplncls       '
           , '  where plnclscod = ?   ' 
           , '  and empcod = 35       '  
 prepare p_ctc69m41_001 from l_sql
 declare c_ctc69m41_001 cursor for p_ctc69m41_001


 let l_sql = ' select min(plnclscod)  '
           , '  from datkplncls       '
           , '  where plnclscod  >  ? '
           , '  and empcod = 35       '
 prepare p_ctc69m41_002 from l_sql
 declare c_ctc69m41_002 cursor for p_ctc69m41_002


 let l_sql = ' select max(plnclscod)  '
           , '  from datkplncls       '
           , '  where plnclscod  <  ? '
           , '  and empcod = 35       '
 prepare p_ctc69m41_003 from l_sql
 declare c_ctc69m41_003 cursor for p_ctc69m41_003


 let l_sql = ' update datkplncls set ( empcod          '
           , '                       , ramcod          '
           , '                       , clscod          '
           , '                       , clsnom          '
           , '                       , prfcod          '
           , '                       , clsviginidat    '
           , '                       , clsvigfimdat    '
           , '                       , clssitflg       '
           , '                       , regsitflg       '
           , '                       , regatldat       '
           , '                       , usrempcod       '
           , '                       , usrmatnum       '
           , '                       , usrtipcod )     '
           , '  =  (?,?,?,?,?,?,?,?,?,?,?,?,?)         '
           , '  where plnclscod  =  ?                  '
 prepare p_ctc69m41_004 from l_sql


 let l_sql = 'insert into datkplncls (empcod         '
           , '                      , ramcod         '
           , '                      , clscod         '
           , '                      , clsnom         '
           , '                      , prfcod         '
           , '                      , clsviginidat   '
           , '                      , clsvigfimdat   '
           , '                      , clssitflg      '
           , '                      , irdclsflg      '
           , '                      , regsitflg      '
           , '                      , regatldat      '
           , '                      , usrempcod      '
           , '                      , usrmatnum      '
           , '                      , usrtipcod)     '
           , '    values (?,?,?,?,?,?,?,?,?,?,?,?,?,?) '
 prepare p_ctc69m41_005 from l_sql


 let l_sql = ' select plnclscod        '
           , '  from datkplncls        '
           , '  where empcod = ?       '
           , '  and   ramcod = ?       '
           , '  and   clscod = ?       '
           , '  and   prfcod = ?       '
           , '  and   clsviginidat = ? '
           , '  and   clsvigfimdat = ? '
 prepare p_ctc69m41_006 from l_sql
 declare c_ctc69m41_006 cursor for p_ctc69m41_006


 let l_sql = ' select count(*)           '
           , '   from datkplncls         '
           , '  where empcod =  ?        '
           , '  and   ramcod =  ?        '
           , '  and   clscod =  ?        '
           , '  and   prfcod =  ?        '
           , '  and   clsviginidat <=  ? '
           , '  and   clsvigfimdat >=  ? '
 prepare p_ctc69m41_007 from l_sql
 declare c_ctc69m41_007 cursor for p_ctc69m41_007


 let l_sql = ' select  plnclscod        '
           , '      ,  empcod           '
           , '      ,  ramcod           '
           , '      ,  clscod           '
           , '      ,  clsnom           '
           , '      ,  clsviginidat     '
           , '      ,  clsvigfimdat     '
           , '      ,  clssitflg        '
           , '      ,  irdclsflg        '
           , '      ,  regsitflg        '
           , '      ,  usrtipcod        '
           , '      ,  usrempcod        '
           , '      ,  usrmatnum        '
           , '      ,  regatldat        '
           , '   from  datkplncls       '
           , '   where  plnclscod = ?   '
 prepare p_ctc69m41_008 from l_sql
 declare c_ctc69m41_008 cursor for p_ctc69m41_008


 let l_sql = ' select min(plnclscod)  '
           , '   from datkplncls      '
           , '   where empcod = 35    '
 prepare p_ctc69m41_009 from l_sql
 declare c_ctc69m41_009 cursor for p_ctc69m41_009


 let l_sql = '  select funnom       '
           , '    from isskfunc     '
           , '   where funmat = ?   '
           , '     and empcod = ?   '
           , '     and usrtip = ?   '
 prepare p_ctc69m41_010 from l_sql
 declare c_ctc69m41_010 cursor for p_ctc69m41_010


 let l_sql = ' select min(plnclscod)   '
           , '   from datkplncls       '
           , '   where empcod = 35     '
 prepare p_ctc69m41_011 from l_sql
 declare c_ctc69m41_011 cursor for p_ctc69m41_011


 let l_sql = ' select count(*)        '
           , '  from datksrvplncls    '
           , ' where plnclscod = ?    '
 prepare p_ctc69m41_012 from l_sql
 declare c_ctc69m41_012 cursor for p_ctc69m41_012


 let l_sql = ' select srvcod                ,  '
           , '        srvplnclsevnlimvlr    ,  '
           , '        srvplnclsevnlimundnom ,  '
           , '        srvplnclscod             '
           , ' from datksrvplncls              '
           , ' where plnclscod = ?             '
 prepare p_ctc69m41_013 from l_sql
 declare c_ctc69m41_013 cursor for p_ctc69m41_013


 let l_sql =  ' insert into datksrvplncls   '
          ,  '   (plnclscod                 '
          ,  '   ,srvcod                    '
          ,  '   ,srvplnclsevnlimvlr        '
          ,  '   ,srvplnclsevnlimundnom     '
          ,  '   ,usrtipcod                 '
          ,  '   ,empcod                    '
          ,  '   ,usrmatnum                 '
          ,  '   ,regatldat)                '
          ,  ' values(?,?,?,?,?,?,?,?)      '
 prepare p_ctc69m41_014 from l_sql


 let l_sql = '   select srvplnclscod    '
            ,'   from datksrvplncls     '
            ,'   where plnclscod =  ?   '
            ,'   and   srvcod    =  ?   '
 prepare p_ctc69m41_015    from l_sql
 declare c_ctc69m41_015 cursor for p_ctc69m41_015



 let l_sql = '    select cbtcod             '
            ,'    from datkcbtcss           '
            ,'    where srvclscod   =  ?    '
 prepare p_ctc69m41_018    from l_sql
 declare c_ctc69m41_018 cursor for p_ctc69m41_018


 let l_sql =  ' insert into datkcbtcss   '
           ,  '   (srvclscod             '
           ,  '   ,cbtcod                '
           ,  '   ,usrtipcod             '
           ,  '   ,empcod                '
           ,  '   ,usrmatnum             '
           ,  '   ,regatldat)            '
           ,  ' values(?,?,?,?,?,?)      '
 prepare p_ctc69m41_019 from l_sql


 let l_sql = '   select trfctgcod       '
            ,'   from datktrfctgcss     '
            ,'   where srvclscod   =  ? '
 prepare p_ctc69m41_020    from l_sql
 declare c_ctc69m41_020 cursor for p_ctc69m41_020

 let l_sql =  ' insert into datktrfctgcss   '
           ,  '   (srvclscod                '
           ,  '   ,trfctgcod                '
           ,  '   ,usrtipcod                '
           ,  '   ,empcod                   '
           ,  '   ,usrmatnum                '
           ,  '   ,regatldat)               '
           ,  ' values(?,?,?,?,?,?)         '
 prepare p_ctc69m41_021 from l_sql


 let l_sql = '   select lclclacod,          '
            ,'          lclclartccod        '
            ,'    from datklclclartc        '
            ,'    where srvclscod    =  ?   '
 prepare p_ctc69m41_022    from l_sql
 declare c_ctc69m41_022 cursor for p_ctc69m41_022


 let l_sql =  ' insert into datklclclartc   '
           ,  '   (srvclscod                '
           ,  '   ,lclclacod                '
           ,  '   ,usrtipcod                '
           ,  '   ,empcod                   '
           ,  '   ,usrmatnum                '
           ,  '   ,regatldat)               '
           ,  ' values(?,?,?,?,?,?)         '
 prepare p_ctc69m41_023 from l_sql


 let l_sql = '   select lclclartccod   '
            ,'   from datklclclartc    '
            ,'   where srvclscod  =  ? '
            ,'   and   lclclacod  =  ? '
 prepare p_ctc69m41_024    from l_sql
 declare c_ctc69m41_024 cursor for p_ctc69m41_024


 let l_sql = '   select cidcod                '
            ,'   from datkrtcece              '
            ,'   where lclclartccod    =  ?   '
 prepare p_ctc69m41_025    from l_sql
 declare c_ctc69m41_025 cursor for p_ctc69m41_025


 let l_sql =  ' insert into datkrtcece   '
           ,  '   (lclclartccod          '
           ,  '   ,cidcod                '
           ,  '   ,usrtipcod             '
           ,  '   ,empcod                '
           ,  '   ,usrmatnum             '
           ,  '   ,regatldat)            '
           ,  ' values(?,?,?,?,?,?)      '
 prepare p_ctc69m41_026 from l_sql


 let l_sql = ' select count(*)           '
           , '   from datkplncls         '
           , '  where empcod =  ?        '
           , '  and   ramcod =  ?        '
           , '  and   clscod =  ?        '
           , '  and   prfcod =  ?        '
           , '  and   clsviginidat <=  ? '
           , '  and   clsvigfimdat >=  ? '
           , '  and   plnclscod <> ?     '
 prepare p_ctc69m41_027 from l_sql
 declare c_ctc69m41_027 cursor for p_ctc69m41_027

let m_sql = 'S'

end function

#------------------------------------------------------------
 function ctc69m41()
#------------------------------------------------------------

 define lr_ctc69m41     record
    plnclscod      like datkplncls.plnclscod      ,
    empcod         like datkplncls.empcod         ,
    empnom         like gabkemp.empnom            ,
    ramcod         like datkplncls.ramcod         ,
    ramnom         like gtakram.ramnom            ,
    clscod         like datkplncls.clscod         ,
    clsnom         char(60)                       ,
    clsviginidat   like datkplncls.clsviginidat   ,
    clsvigfimdat   like datkplncls.clsvigfimdat   ,
    clssitflg      like datkplncls.clssitflg      ,
    irdclsflg      like datkplncls.irdclsflg      ,
    regsitflg      like datkplncls.regsitflg      ,
    obs1           char(60)                       ,
    regatldat      like datkplncls.regatldat      ,
    funnom         like isskfunc.funnom
 end record

 let int_flag    = false
 let m_irdclsflg = null
 let m_prfcod    = 0
 
 initialize lr_ctc69m41.*  to null


 call ctc69m41_prepare()

 open window ctc69m41 at 4,2 with form "ctc69m41"


 menu "REGRAS AZUL"
 command key ("O") "Consulta"
                   "Consulta Regra Conforme Criterios"
          call ctc69m31()

 command key ("S") "Seleciona"
                   "Pesquisa Regra Conforme Criterios"

          call ctc69m41_seleciona()  returning lr_ctc69m41.*

          if lr_ctc69m41.plnclscod  is not null  then
             message ""
             next option "Proximo"
          end if

 command key ("P") "Proximo"
                   "Mostra Proxima Regra Selecionada"
          message ""

             call ctc69m41_proximo(lr_ctc69m41.plnclscod)
                  returning lr_ctc69m41.*

             if lr_ctc69m41.plnclscod is null then
                call ctc69m41_display(lr_ctc69m41.*)
                next option "Seleciona"
             end if


 command key ("A") "Anterior"
                   "Mostra Regra Anterior Selecionada"
          message ""

          if lr_ctc69m41.plnclscod is not null then
             call ctc69m41_anterior(lr_ctc69m41.plnclscod)
                  returning lr_ctc69m41.*

             if lr_ctc69m41.plnclscod is null then
                call ctc69m41_display(lr_ctc69m41.*)
                next option "Seleciona"
             end if
          end if

 command key ("M") "Modifica"
                   "Modifica Regra"
          message ""

          if lr_ctc69m41.plnclscod  is not null then
             call ctc69m41_modifica(lr_ctc69m41.plnclscod, lr_ctc69m41.*)
                  returning lr_ctc69m41.*
             next option "Seleciona"
          else
             error " Nenhuma Regra Selecionada!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui Regra"
          message ""
          call ctc69m41_inclui()
          next option "Seleciona"


 command key ("T") "Pacotes"
                   "Pacotes da Regra"
          if lr_ctc69m41.plnclscod  is not null then

             let m_irdclsflg = lr_ctc69m41.irdclsflg

             call ctc69m07(lr_ctc69m41.plnclscod     ,
                           lr_ctc69m41.clscod        ,
                           lr_ctc69m41.clsnom        ,
                           lr_ctc69m41.empcod        ,
                           lr_ctc69m41.ramcod        ,
                           2)
          else
             error " Nenhuma Regra Selecionada!"
             next option "Seleciona"
          end if

 command key ("C") "Copia"
                   "Copia Regra"
          message ""

          if lr_ctc69m41.plnclscod  is not null then
             call ctc69m41_copia(lr_ctc69m41.plnclscod, lr_ctc69m41.*)
             call ctc69m41_display(lr_ctc69m41.*)
             next option "Seleciona"
          else
             error " Nenhuma Regra Selecionada!"
             next option "Seleciona"
          end if




 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc69m41

 end function


#------------------------------------------------------------
 function ctc69m41_seleciona()
#------------------------------------------------------------

 define lr_ctc69m41     record
    plnclscod      like datkplncls.plnclscod      ,
    empcod         like datkplncls.empcod         ,
    empnom         like gabkemp.empnom            ,
    ramcod         like datkplncls.ramcod         ,
    ramnom         like gtakram.ramnom            ,
    clscod         like datkplncls.clscod         ,
    clsnom         char(60)                       ,
    clsviginidat   like datkplncls.clsviginidat   ,
    clsvigfimdat   like datkplncls.clsvigfimdat   ,
    clssitflg      like datkplncls.clssitflg      ,
    irdclsflg      like datkplncls.irdclsflg      ,
    regsitflg      like datkplncls.regsitflg      ,
    obs1           char(60)                       ,
    regatldat      like datkplncls.regatldat      ,
    funnom         like isskfunc.funnom
 end record

 define lr_retorno record
 	  plnclscod   like datkplncls.plnclscod
 end record

  if m_sql <> 'S' then
    call ctc69m41_prepare()
  end if


 let int_flag = false

 initialize lr_ctc69m41.*, lr_retorno.*  to null

 call ctc69m41_display(lr_ctc69m41.*)

 input by name lr_ctc69m41.plnclscod

    before field plnclscod
        display by name lr_ctc69m41.plnclscod attribute (reverse)

    after  field plnclscod
        display by name lr_ctc69m41.plnclscod

        open c_ctc69m41_001 using lr_ctc69m41.plnclscod
        whenever error continue
        fetch c_ctc69m41_001 into lr_retorno.plnclscod
        whenever error stop

        if lr_retorno.plnclscod  is null or
           lr_retorno.plnclscod  = ''    then

           #--------------------------------------------------------
           # Recupera o Primeiro Codigo do Plano/Clausula
           #--------------------------------------------------------

           open c_ctc69m41_009
           whenever error continue
           fetch c_ctc69m41_009 into lr_ctc69m41.plnclscod
           whenever error stop

           if lr_ctc69m41.plnclscod  is null or
              lr_ctc69m41.plnclscod  = ''    then
              next field plnclscod
           end if
        end if

    on key (interrupt)
        exit input


 end input

 if int_flag  then
    let int_flag = false
    initialize lr_ctc69m41.*   to null
    call ctc69m41_display(lr_ctc69m41.*)
    error " Operacao Cancelada!"
    return lr_ctc69m41.*
 end if

 #--------------------------------------------------------
 # Recupera os Dados do Plano/Clausula
 #--------------------------------------------------------

 call ctc69m41_ler(lr_ctc69m41.plnclscod)
 returning lr_ctc69m41.*

 if lr_ctc69m41.plnclscod  is not null   then
    call ctc69m41_display(lr_ctc69m41.*)
 else
    error " Codigo da Regra Nao Cadastrada!"
    initialize lr_ctc69m41.*    to null
 end if

 return lr_ctc69m41.*

 end function


#------------------------------------------------------------
 function ctc69m41_proximo(lr_param)
#------------------------------------------------------------

 define lr_param  record
    plnclscod  like datkplncls.plnclscod
 end record

 define lr_ctc69m41     record
    plnclscod     like datkplncls.plnclscod      ,
    empcod        like datkplncls.empcod         ,
    empnom        like gabkemp.empnom            ,
    ramcod        like datkplncls.ramcod         ,
    ramnom        like gtakram.ramnom            ,   
    clscod        like datkplncls.clscod         ,
    clsnom        char(60)                       ,
    clsviginidat  like datkplncls.clsviginidat   ,
    clsvigfimdat  like datkplncls.clsvigfimdat   ,
    clssitflg     like datkplncls.clssitflg      ,
    irdclsflg     like datkplncls.irdclsflg      ,
    regsitflg     like datkplncls.regsitflg      ,
    obs1          char(60)                       ,
    regatldat     like datkplncls.regatldat      ,
    funnom        like isskfunc.funnom
 end record

  if m_sql <> 'S' then
    call ctc69m41_prepare()
  end if

 let int_flag = false

 initialize lr_ctc69m41.*   to null

 #--------------------------------------------------------
 # Recupera o Proximo Codigo de Plano/Clausula
 #--------------------------------------------------------


 if lr_param.plnclscod  is null   then

    open c_ctc69m41_011
    whenever error continue
    fetch c_ctc69m41_011 into lr_param.plnclscod
    whenever error stop

    let lr_param.plnclscod = lr_param.plnclscod - 1

 end if

  open c_ctc69m41_002 using lr_param.plnclscod
  whenever error continue
  fetch c_ctc69m41_002 into lr_ctc69m41.plnclscod
  whenever error stop

 if lr_ctc69m41.plnclscod  is not null   then

    call ctc69m41_ler(lr_ctc69m41.plnclscod)
         returning lr_ctc69m41.*

    if lr_ctc69m41.plnclscod  is not null   then
       call ctc69m41_display(lr_ctc69m41.*)
    else
       error "Nao ha' Regras Nesta Direcao!"
       initialize lr_ctc69m41.*    to null
    end if
 else
    error " Nao ha' Regras Nesta Direcao!"
    initialize lr_ctc69m41.*    to null
 end if

 return lr_ctc69m41.*

 end function


#------------------------------------------------------------
 function ctc69m41_anterior(lr_param)
#------------------------------------------------------------

 define lr_param  record
     plnclscod  like datkplncls.plnclscod
 end record

 define lr_ctc69m41     record
     plnclscod     like datkplncls.plnclscod      ,
     empcod        like datkplncls.empcod         ,
     empnom        like gabkemp.empnom            ,
     ramcod        like datkplncls.ramcod         ,
     ramnom        like gtakram.ramnom            ,
     clscod        like datkplncls.clscod         ,
     clsnom        char(60)                       ,
     clsviginidat  like datkplncls.clsviginidat   ,
     clsvigfimdat  like datkplncls.clsvigfimdat   ,
     clssitflg     like datkplncls.clssitflg      ,
     irdclsflg     like datkplncls.irdclsflg      ,
     regsitflg     like datkplncls.regsitflg      ,
     obs1          char(60)                       ,
     regatldat     like datkplncls.regatldat      ,
     funnom        like isskfunc.funnom
 end record

  if m_sql <> 'S' then
    call ctc69m41_prepare()
  end if

 let int_flag = false

 initialize lr_ctc69m41.*  to null

 if lr_param.plnclscod  is null   then
    let lr_param.plnclscod = " "
 end if


 #--------------------------------------------------------
 # Recupera o Codigo do Plano/Clausula Anterior
 #--------------------------------------------------------


 open c_ctc69m41_003 using lr_param.plnclscod
 fetch c_ctc69m41_003 into lr_ctc69m41.plnclscod

 if lr_ctc69m41.plnclscod  is not null   then

    call ctc69m41_ler(lr_ctc69m41.plnclscod)
         returning lr_ctc69m41.*

    if lr_ctc69m41.plnclscod  is not null   then
       call ctc69m41_display(lr_ctc69m41.*)
    else
       error " Nao ha' Regras Nesta Direcao!"
       initialize lr_ctc69m41.*    to null
    end if
 else
    error " Nao ha' Regras Nesta Direcao!"
    initialize lr_ctc69m41.*    to null
 end if

 return lr_ctc69m41.*

 end function


#------------------------------------------------------------
 function ctc69m41_modifica(lr_param, lr_ctc69m41)
#------------------------------------------------------------

 define lr_param         record
    plnclscod  like datkplncls.plnclscod
 end record

 define lr_ctc69m41     record
    plnclscod       like datkplncls.plnclscod      ,
    empcod          like datkplncls.empcod         ,
    empnom          like gabkemp.empnom            ,
    ramcod          like datkplncls.ramcod         ,
    ramnom          like gtakram.ramnom            ,   
    clscod          like datkplncls.clscod         ,
    clsnom          char(60)                       ,
    clsviginidat    like datkplncls.clsviginidat   ,
    clsvigfimdat    like datkplncls.clsvigfimdat   ,
    clssitflg       like datkplncls.clssitflg      ,
    irdclsflg       like datkplncls.irdclsflg      ,
    regsitflg       like datkplncls.regsitflg      ,
    obs1            char(60)                       ,
    regatldat       like datkplncls.regatldat      ,
    funnom          like isskfunc.funnom
 end record

  if m_sql <> 'S' then
    call ctc69m41_prepare()
  end if

 call ctc69m41_display(lr_ctc69m41.*)
 #--------------------------------------------------------
 # Abre os Campos Para Digitacao
 #--------------------------------------------------------

 call ctc69m41_input("a", lr_ctc69m41.*) returning lr_ctc69m41.*

 if int_flag  then
    let int_flag = false
    initialize lr_ctc69m41.*  to null
    call ctc69m41_display(lr_ctc69m41.*)
    error " Operacao cancelada!"
    return lr_ctc69m41.*
 end if


 #--------------------------------------------------------
 # Valida se a Chave Composta ja Foi Criada
 #--------------------------------------------------------

 if not ctc69m41_valida_modificacao(lr_ctc69m41.empcod       ,
                                    lr_ctc69m41.ramcod       ,
                                    lr_ctc69m41.clscod       ,
                                    lr_ctc69m41.clsviginidat ,
                                    lr_ctc69m41.clsvigfimdat ,
                                    lr_ctc69m41.plnclscod    ) then
    return lr_ctc69m41.*
 end if

 whenever error continue

 let lr_ctc69m41.regatldat = today

 begin work

  #--------------------------------------------------------
  # Atualiza o Plano/Clausula
  #--------------------------------------------------------

  execute p_ctc69m41_004 using  lr_ctc69m41.empcod
                              , lr_ctc69m41.ramcod
                              , lr_ctc69m41.clscod
                              , lr_ctc69m41.clsnom
                              , m_prfcod
                              , lr_ctc69m41.clsviginidat
                              , lr_ctc69m41.clsvigfimdat
                              , lr_ctc69m41.clssitflg
                              , lr_ctc69m41.regsitflg
                              , lr_ctc69m41.regatldat
                              , g_issk.empcod
                              , g_issk.funmat
                              , g_issk.usrtip
                              , lr_ctc69m41.plnclscod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na Alteracao do Regra!"
       rollback work
       initialize lr_ctc69m41.*   to null
       return lr_ctc69m41.*
    else
       error " Alteracao Efetuada Com Sucesso!"
    end if

 commit work

 whenever error stop

 initialize lr_ctc69m41.*  to null
 call ctc69m41_display(lr_ctc69m41.*)
 message ""
 return lr_ctc69m41.*

 end function


#------------------------------------------------------------
 function ctc69m41_inclui()
#------------------------------------------------------------

 define lr_ctc69m41 record
    plnclscod      like datkplncls.plnclscod      ,
    empcod         like datkplncls.empcod         ,
    empnom         like gabkemp.empnom            ,
    ramcod         like datkplncls.ramcod         ,
    ramnom         like gtakram.ramnom            ,    
    clscod         like datkplncls.clscod         ,
    clsnom         char(60)                       ,
    clsviginidat   like datkplncls.clsviginidat   ,
    clsvigfimdat   like datkplncls.clsvigfimdat   ,
    clssitflg      like datkplncls.clssitflg      ,
    irdclsflg      like datkplncls.irdclsflg      ,
    regsitflg      like datkplncls.regsitflg      ,
    obs1           char(60)                       ,
    regatldat      like datkplncls.regatldat      ,
    funnom         like isskfunc.funnom
 end record

 define lr_retorno record
     resp      char(01),
     ret       smallint,
     mensagem  char(60)
 end record

 initialize lr_ctc69m41.*, lr_retorno.*   to null

 let lr_retorno.ret   = 0


  if m_sql <> 'S' then
    call ctc69m41_prepare()
  end if

 call ctc69m41_display(lr_ctc69m41.*)

 #--------------------------------------------------------
 # Abre os Campos Para Digitacao
 #--------------------------------------------------------

 call ctc69m41_input("i", lr_ctc69m41.*) returning lr_ctc69m41.*

 if int_flag  then
    let int_flag = false
    initialize lr_ctc69m41.*  to null
    call ctc69m41_display(lr_ctc69m41.*)
    error " Operacao cancelada!"
    return
 end if

 let lr_ctc69m41.regatldat = today

 #--------------------------------------------------------
 # Valida se a Chave Composta ja Foi Criada
 #--------------------------------------------------------

 if not ctc69m41_valida_geracao(lr_ctc69m41.empcod ,
                                lr_ctc69m41.ramcod ,
                                lr_ctc69m41.clscod ,
                                lr_ctc69m41.clsviginidat ,
                                lr_ctc69m41.clsvigfimdat ) then
    return
 end if


 whenever error continue

 begin work

  #--------------------------------------------------------
  # Inclui o Plano/Clausula
  #--------------------------------------------------------

  whenever error continue
  execute p_ctc69m41_005 using  lr_ctc69m41.empcod
                              , lr_ctc69m41.ramcod
                              , lr_ctc69m41.clscod
                              , lr_ctc69m41.clsnom
                              , m_prfcod
                              , lr_ctc69m41.clsviginidat
                              , lr_ctc69m41.clsvigfimdat
                              , lr_ctc69m41.clssitflg
                              , "N"
                              , lr_ctc69m41.regsitflg
                              , lr_ctc69m41.regatldat
                              , g_issk.empcod
                              , g_issk.funmat
                              , g_issk.usrtip

  whenever error stop
  if sqlca.sqlcode <>  0   then
     error " Erro (",sqlca.sqlcode,") na Inclusao do Regra!"
     rollback work
     return
  end if

 commit work

 whenever error stop


 #--------------------------------------------------------
 # Recupera o Nome do Funcionario
 #--------------------------------------------------------

 call ctc69m41_func(g_issk.funmat,
                    g_issk.empcod,
                    g_issk.usrtip)
 returning lr_ctc69m41.funnom

 #--------------------------------------------------------
 # Recupera a Chave do Plano/Clausula
 #--------------------------------------------------------

 open c_ctc69m41_006 using  lr_ctc69m41.empcod
                           ,lr_ctc69m41.ramcod
                           ,lr_ctc69m41.clscod
                           ,m_prfcod
                           ,lr_ctc69m41.clsviginidat
                           ,lr_ctc69m41.clsvigfimdat
 whenever error continue
 fetch c_ctc69m41_006 into lr_ctc69m41.plnclscod
 whenever error stop

 if sqlca.sqlcode <>  0   then
    error " Erro (",sqlca.sqlcode,") ao Recuperar o Codigo da Regra!"
 end if


 call ctc69m41_display(lr_ctc69m41.*)

 display by name lr_ctc69m41.plnclscod attribute (reverse)

 error " Inclusao Efetuada Com Sucesso, tecle ENTER!"

 prompt "" for char lr_retorno.resp

 initialize lr_ctc69m41.*  to null
 call ctc69m41_display(lr_ctc69m41.*)

 end function


#--------------------------------------------------------------------
 function ctc69m41_input(lr_param, lr_ctc69m41)
#--------------------------------------------------------------------

 define lr_param  record
    operacao  char (1)
 end record


 define lr_ctc69m41     record
    plnclscod      like datkplncls.plnclscod      ,
    empcod         like datkplncls.empcod         ,
    empnom         like gabkemp.empnom            ,
    ramcod         like datkplncls.ramcod         ,
    ramnom         like gtakram.ramnom            ,   
    clscod         like datkplncls.clscod         ,
    clsnom         char(60)                       ,
    clsviginidat   like datkplncls.clsviginidat   ,
    clsvigfimdat   like datkplncls.clsvigfimdat   ,
    clssitflg      like datkplncls.clssitflg      ,
    irdclsflg      like datkplncls.irdclsflg      ,
    regsitflg      like datkplncls.regsitflg      ,
    obs1           char(60)                       ,
    regatldat      like datkplncls.regatldat      ,
    funnom         like isskfunc.funnom
 end record

 define lr_retorno record
     erro        smallint,
     mensagem    char(60),
     count       smallint,
     confirma    char(01)
 end record

  if m_sql <> 'S' then
    call ctc69m41_prepare()
  end if

 let lr_retorno.count    = 0
 let lr_retorno.erro     = 0
 let lr_retorno.mensagem = null

 let int_flag = false

 input by name   lr_ctc69m41.empcod
               , lr_ctc69m41.ramcod
               , lr_ctc69m41.clscod
               , lr_ctc69m41.clsnom
               , lr_ctc69m41.clsviginidat
               , lr_ctc69m41.clsvigfimdat
               , lr_ctc69m41.clssitflg
               , lr_ctc69m41.regsitflg without defaults


    before field empcod
           display by name lr_ctc69m41.empcod  attribute (reverse)
           
           let lr_ctc69m41.empcod = 35  
           
           #--------------------------------------------------------               
           # Recupera a Descricao da Empresa                            
           #--------------------------------------------------------    
                                                                        
           call ctc69m04_recupera_descricao(2,lr_ctc69m41.empcod )      
           returning lr_ctc69m41.empnom
           
           display by name lr_ctc69m41.empcod                                    
           display by name lr_ctc69m41.empnom   
           
           next field ramcod 
         
    before field ramcod
       display by name lr_ctc69m41.ramcod   attribute (reverse)

    after  field ramcod
       display by name lr_ctc69m41.ramcod


       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
             next field ramcod 
       end if

       if lr_ctc69m41.ramcod   is null   then
  
          #--------------------------------------------------------
          # Abre o Popup de Ramo
          #--------------------------------------------------------
          
          call ctc69m04_popup(3)
          returning lr_ctc69m41.ramcod
                  , lr_ctc69m41.ramnom
                  

          if lr_ctc69m41.ramcod    is null   then
             next field ramcod
          end if
       else

       	 #--------------------------------------------------------
       	 # Recupera a Descricao do Ramo
       	 #--------------------------------------------------------
      	
       	 call ctc69m04_recupera_descricao(3,lr_ctc69m41.ramcod)
       	 returning lr_ctc69m41.ramnom  
 

       	 if lr_ctc69m41.ramnom  is null then
       	    next field ramcod
       	 end if

       end if

       display by name lr_ctc69m41.ramcod
       display by name lr_ctc69m41.ramnom

    before field clscod
       display by name lr_ctc69m41.clscod   attribute (reverse)

    after  field clscod
       display by name lr_ctc69m41.clscod


       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
             next field ramcod
       end if

       if lr_ctc69m41.clscod   is null   then

          #--------------------------------------------------------
          # Abre o Popup da Clausula 
          #--------------------------------------------------------

                    
          call ctc69m04_popup(16)
          returning lr_ctc69m41.clscod
          	       ,lr_ctc69m41.clsnom
                    
          
           if  lr_ctc69m41.clscod is null then
        		    next field clscod
           end if
       else

       	  #--------------------------------------------------------
       	  # Recupera a Descricao da Clausula
       	  #--------------------------------------------------------
         
          call ctc69m04_recupera_descricao(16,lr_ctc69m41.clscod)
          returning lr_ctc69m41.clsnom
      
        	if lr_ctc69m41.clsnom  is null then
        	   next field clscod
        	end if

       end if

       display by name lr_ctc69m41.clscod
       display by name lr_ctc69m41.clsnom
       
       
   
    before field clsviginidat
       display by name lr_ctc69m41.clsviginidat   attribute (reverse)

    after  field clsviginidat
       display by name lr_ctc69m41.clsviginidat


       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
             next field clscod             
       end if

       if lr_ctc69m41.clsviginidat    is null   then
          error "Por Favor Informe a Vigencia Inicial!"
          next field clsviginidat
       end if

    before field clsvigfimdat
       display by name lr_ctc69m41.clsvigfimdat   attribute (reverse)

    after  field clsvigfimdat
       display by name lr_ctc69m41.clsvigfimdat


       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
             next field clsviginidat
       end if

       if lr_ctc69m41.clsvigfimdat    is null   then
          error "Por Favor Informe a Vigencia Final!"
          next field clsvigfimdat
       end if

       if lr_ctc69m41.clsvigfimdat < lr_ctc69m41.clsviginidat then
       	  error "Data Final Nao Pode Ser Menor que a Inicial!"
       	  next field clsvigfimdat
       end if


    before field clssitflg
       display by name lr_ctc69m41.clssitflg   attribute (reverse)

    after  field clssitflg
       display by name lr_ctc69m41.clssitflg


       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
             next field clsvigfimdat
       end if

       if lr_ctc69m41.clssitflg is null  or
       	  (lr_ctc69m41.clssitflg <> "S"  and
       	   lr_ctc69m41.clssitflg <> "N") then
       	     error "Por Favor Digite 'S' ou 'N' "
             next field clssitflg
       end if


    before field regsitflg
           display by name lr_ctc69m41.regsitflg attribute (reverse)

    after field regsitflg
           display by name lr_ctc69m41.regsitflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then

              next field clssitflg
           end if


           if lr_ctc69m41.regsitflg is null  or
           	  (lr_ctc69m41.regsitflg <> "A"  and
           	   lr_ctc69m41.regsitflg <> "I") then
           	     error "Por Favor Digite 'A' ou 'I' "
                 next field regsitflg
           end if


           if lr_param.operacao = "i" then
               let lr_retorno.confirma = cts08g01("C","S","",
                                                  "DESEJA INCLUIR",
                                                  "A REGRA?",
                                                  "")
           else
               let lr_retorno.confirma = cts08g01("C","S","",
                                                  "DESEJA ALTERAR",
                                                  "A REGRA?",
                                                  "")
           end if
           if lr_retorno.confirma = "N" then
           	  next field regsitflg
           end if

           display by name lr_ctc69m41.regsitflg


    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize lr_ctc69m41.*  to null
 end if

 return lr_ctc69m41.*

 end function


#---------------------------------------------------------
 function ctc69m41_ler(lr_param)
#---------------------------------------------------------

 define lr_param  record
    plnclscod   like datkplncls.plnclscod
 end record

 define lr_ctc69m41     record
    plnclscod      like datkplncls.plnclscod      ,
    empcod         like datkplncls.empcod         ,
    empnom         like gabkemp.empnom            ,
    ramcod         like datkplncls.ramcod         ,
    ramnom         like gtakram.ramnom            ,
    clscod         like datkplncls.clscod         ,
    clsnom         char(60)                       ,
    clsviginidat   like datkplncls.clsviginidat   ,
    clsvigfimdat   like datkplncls.clsvigfimdat   ,
    clssitflg      like datkplncls.clssitflg      ,
    irdclsflg      like datkplncls.irdclsflg      ,
    regsitflg      like datkplncls.regsitflg      ,
    obs1           char(60)                       ,
    regatldat      like datkplncls.regatldat      ,
    funnom         like isskfunc.funnom
 end record

 define lr_retorno  record
    usrmatnum      like datkplncls.usrmatnum  ,
    empcod         like datkplncls.empcod     ,
    usrtipcod      like datkplncls.usrtipcod  ,
    cont           integer                    ,
    ret            smallint                   ,
    mensagem       char(60)
 end record


  if m_sql <> 'S' then
    call ctc69m41_prepare()
  end if

 initialize lr_ctc69m41.*, lr_retorno.*   to null

 let lr_retorno.ret  = 0
 let lr_retorno.cont = 0

 #--------------------------------------------------------
 # Recupera os Dados do Plano/Clausula
 #--------------------------------------------------------

 open c_ctc69m41_008 using lr_param.plnclscod
 whenever error continue
 fetch c_ctc69m41_008 into  lr_ctc69m41.plnclscod
                          , lr_ctc69m41.empcod
                          , lr_ctc69m41.ramcod
                          , lr_ctc69m41.clscod
                          , lr_ctc69m41.clsnom
                          , lr_ctc69m41.clsviginidat
                          , lr_ctc69m41.clsvigfimdat
                          , lr_ctc69m41.clssitflg
                          , lr_ctc69m41.irdclsflg
                          , lr_ctc69m41.regsitflg
                          , lr_retorno.usrtipcod
                          , lr_retorno.empcod
                          , lr_retorno.usrmatnum
                          , lr_ctc69m41.regatldat
 whenever error stop

 if lr_ctc69m41.plnclscod  is null  then
    error " Codigo da Regra Nao Cadastrada!"
    initialize lr_ctc69m41.*    to null
    return lr_ctc69m41.*
 else

    call ctc69m41_func(lr_retorno.usrmatnum
                      ,lr_retorno.empcod
                      ,lr_retorno.usrtipcod)
    returning lr_ctc69m41.funnom

    call ctc69m04_recupera_descricao(2,lr_ctc69m41.empcod )
    returning lr_ctc69m41.empnom

    call ctc69m04_recupera_descricao(3,lr_ctc69m41.ramcod )
    returning lr_ctc69m41.ramnom

    call ctc69m41_recupera_obs(lr_ctc69m41.plnclscod)
    returning lr_ctc69m41.obs1


 end if

 return lr_ctc69m41.*

 end function


#---------------------------------------------------------
 function ctc69m41_func(lr_param)
#---------------------------------------------------------

 define lr_param  record
    funmat       like isskfunc.funmat,
    empcod       like isskfunc.empcod,
    usrtipcod    like isskfunc.usrtip
 end record

 define lr_retorno   record
    funnom       like isskfunc.funnom
 end record

  if m_sql <> 'S' then
    call ctc69m41_prepare()
  end if

 initialize lr_retorno.*    to null

   if lr_param.empcod is null or
      lr_param.empcod = " " then

      let lr_param.empcod = 1

   end if


   open c_ctc69m41_010 using lr_param.funmat ,
                             lr_param.empcod ,
                             lr_param.usrtipcod
   whenever error continue
   fetch c_ctc69m41_010 into lr_retorno.funnom
   whenever error stop

 return lr_retorno.funnom

end function

#---------------------------------------------------------
 function ctc69m41_recupera_obs(lr_param)
#---------------------------------------------------------

define lr_param     record
   plnclscod  like datkplncls.plnclscod
end record

define lr_retorno  record
   obs1    char(60) ,
   cont    integer
end record

initialize lr_retorno.* to null

        open c_ctc69m41_012 using lr_param.plnclscod
        whenever error continue
        fetch c_ctc69m41_012 into  lr_retorno.cont
        whenever error stop

        if lr_retorno.cont  >  0   then
           if lr_retorno.cont = 1 then
              let lr_retorno.obs1 =  "EXISTE ", lr_retorno.cont using "<<<,<<<", " PACOTE ASSOCIADO A ESTA REGRA."
           else
              let lr_retorno.obs1 =  "EXISTEM ",lr_retorno.cont using "<<<,<<<", " PACOTES ASSOCIADOS A ESTA REGRA."
           end if
        else
           let lr_retorno.obs1 =  "NAO EXISTEM PACOTES ASSOCIADOS A ESTA REGRA."
        end if


        return lr_retorno.obs1

end function

#---------------------------------------------------------
 function ctc69m41_valida_geracao(lr_param)
#---------------------------------------------------------

define lr_param  record
  empcod         like datkplncls.empcod       ,
  ramcod         like datkplncls.ramcod       ,
  clscod         like datkplncls.clscod       ,
  clsviginidat   like datkplncls.clsviginidat ,
  clsvigfimdat   like datkplncls.clsvigfimdat
end record

define lr_retorno  record
   cont    integer
end record

initialize lr_retorno.* to null


        open c_ctc69m41_007 using lr_param.empcod       ,
                                  lr_param.ramcod       ,
                                  lr_param.clscod       ,
                                  m_prfcod              ,
                                  lr_param.clsviginidat ,
                                  lr_param.clsviginidat

        whenever error continue
        fetch c_ctc69m41_007 into  lr_retorno.cont
        whenever error stop

        if lr_retorno.cont  >  0   then
           error "Clausula Ja Cadastrada para Essa Vigencia Inicial!"
           return false
        end if


        open c_ctc69m41_007 using lr_param.empcod       ,
                                  lr_param.ramcod       ,
                                  lr_param.clscod       ,
                                  m_prfcod              ,
                                  lr_param.clsvigfimdat ,
                                  lr_param.clsvigfimdat

        whenever error continue
        fetch c_ctc69m41_007 into  lr_retorno.cont
        whenever error stop

        if lr_retorno.cont  >  0   then
           error "Clausula Ja Cadastrada para Essa Vigencia Final!"
           return false
        else
           return true
        end if
end function

#---------------------------------------------------------
 function ctc69m41_valida_modificacao(lr_param)
#---------------------------------------------------------
define lr_param  record
  empcod         like datkplncls.empcod       ,
  ramcod         like datkplncls.ramcod       ,
  clscod         like datkplncls.clscod       ,
  clsviginidat   like datkplncls.clsviginidat ,
  clsvigfimdat   like datkplncls.clsvigfimdat ,
  plnclscod      like datkplncls.plnclscod
end record

define lr_retorno  record
   cont    integer
end record

initialize lr_retorno.* to null

        open c_ctc69m41_027 using lr_param.empcod       ,
                                  lr_param.ramcod       ,
                                  lr_param.clscod       ,
                                  m_prfcod              ,
                                  lr_param.clsviginidat ,
                                  lr_param.clsviginidat ,
                                  lr_param.plnclscod
        whenever error continue
        fetch c_ctc69m41_027 into  lr_retorno.cont
        whenever error stop
        
        if lr_retorno.cont  >  0   then
           error "Clausula Ja Cadastrada para Essa Vigencia Inicial!"
           return false
        end if
        
        open c_ctc69m41_027 using lr_param.empcod       ,
                                  lr_param.ramcod       ,
                                  lr_param.clscod       ,
                                  m_prfcod              ,
                                  lr_param.clsvigfimdat ,
                                  lr_param.clsvigfimdat ,
                                  lr_param.plnclscod
        whenever error continue
        fetch c_ctc69m41_027 into  lr_retorno.cont
        whenever error stop
        
        if lr_retorno.cont  >  0   then
           error "Clausula Ja Cadastrada para Essa Vigencia Final!"
           return false
        else
           return true
        end if
        
end function

#------------------------------------------------------------
 function ctc69m41_valida_exclusao()
#------------------------------------------------------------

  # Solicitado por Vinicius Henrique a Nao Validacao da Exclusao
  #if m_irdclsflg = "S" then
  #   error "Codigo Nao Pode Ser Excluido, Clausula/Plano Ja Exportado!"
  #   return false
  #end if

  return true

end function

#------------------------------------------------------------
 function ctc69m41_copia(lr_param, lr_ctc69m41)
#------------------------------------------------------------

 define lr_param         record
    plnclscod  like datkplncls.plnclscod
 end record

 define lr_ctc69m41     record
    plnclscod      like datkplncls.plnclscod      ,
    empcod         like datkplncls.empcod         ,
    empnom         like gabkemp.empnom            ,
    ramcod         like datkplncls.ramcod         ,
    ramnom         like gtakram.ramnom            ,   
    clscod         like datkplncls.clscod         ,
    clsnom         char(60)                       ,
    clsviginidat   like datkplncls.clsviginidat   ,
    clsvigfimdat   like datkplncls.clsvigfimdat   ,
    clssitflg      like datkplncls.clssitflg      ,
    irdclsflg      like datkplncls.irdclsflg      ,
    regsitflg      like datkplncls.regsitflg      ,
    obs1           char(60)                       ,
    regatldat      like datkplncls.regatldat      ,
    funnom         like isskfunc.funnom
 end record

 define lr_retorno record
     resp      char(01),
     ret       smallint,
     mensagem  char(60)
 end record

  initialize lr_ctc69m41.*, lr_retorno.*, mr_retorno.*   to null
  clear form

  if m_sql <> 'S' then
    call ctc69m41_prepare()
  end if

  call ctc69m41_display(lr_ctc69m41.*)
 #--------------------------------------------------------
 # Abre a Tela Para a Digitacao
 #--------------------------------------------------------

 call ctc69m41_input("i", lr_ctc69m41.*) returning lr_ctc69m41.*

 if int_flag  then
    let int_flag = false
    initialize lr_ctc69m41.*  to null
    call ctc69m41_display(lr_ctc69m41.*)
    error " Operacao cancelada!"
    return
 end if


 #--------------------------------------------------------
 # Valida se a Chave Composta Ja Foi Criada
 #--------------------------------------------------------

 if not ctc69m41_valida_geracao(lr_ctc69m41.empcod       ,
                                lr_ctc69m41.ramcod       ,
                                lr_ctc69m41.clscod       ,
                                lr_ctc69m41.clsviginidat ,
                                lr_ctc69m41.clsvigfimdat ) then
    return
 end if

 whenever error continue

 let lr_ctc69m41.regatldat = today

 begin work

 #--------------------------------------------------------
 # Inclui Plano/Clausula
 #--------------------------------------------------------

 whenever error continue
  execute p_ctc69m41_005 using  lr_ctc69m41.empcod
                              , lr_ctc69m41.ramcod
                              , lr_ctc69m41.clscod
                              , lr_ctc69m41.clsnom
                              , m_prfcod
                              , lr_ctc69m41.clsviginidat
                              , lr_ctc69m41.clsvigfimdat
                              , lr_ctc69m41.clssitflg
                              , "N"
                              , lr_ctc69m41.regsitflg
                              , lr_ctc69m41.regatldat
                              , g_issk.empcod
                              , g_issk.funmat
                              , g_issk.usrtip

  whenever error stop
  if sqlca.sqlcode <>  0   then
     error " Erro (",sqlca.sqlcode,") na Inclusao da Regra!"
     rollback work
     return
  end if

 #--------------------------------------------------------
 # Recupera o Nome de Funcionario
 #--------------------------------------------------------


 call ctc69m41_func(g_issk.funmat,
                    g_issk.empcod,
                    g_issk.usrtip)
 returning lr_ctc69m41.funnom

 #--------------------------------------------------------
 # Recupera a Chave do Plano/Clausula
 #--------------------------------------------------------

 open c_ctc69m41_006 using  lr_ctc69m41.empcod
                           ,lr_ctc69m41.ramcod
                           ,lr_ctc69m41.clscod
                           ,m_prfcod
                           ,lr_ctc69m41.clsviginidat
                           ,lr_ctc69m41.clsvigfimdat
 whenever error continue
 fetch c_ctc69m41_006 into lr_ctc69m41.plnclscod
 whenever error stop

 if sqlca.sqlcode <>  0   then
    error " Erro (",sqlca.sqlcode,") ao Recuperar o Codigo da Regra!"
 end if


 #--------------------------------------------------------
 # Grava a Copia
 #--------------------------------------------------------

 if not ctc69m41_grava_copia(lr_param.plnclscod,
                             lr_ctc69m41.plnclscod) then

    rollback work
    return
 end if


 commit work

 call ctc69m41_display(lr_ctc69m41.*)

 display by name lr_ctc69m41.plnclscod attribute (reverse)

 error " Copia Efetuada Com Sucesso, tecle ENTER!"

 prompt "" for char lr_retorno.resp

 initialize lr_ctc69m41.*  to null
 call ctc69m41_display(lr_ctc69m41.*)


 end function

#------------------------------------------------------------
 function ctc69m41_grava_copia(lr_copia, lr_param)
#------------------------------------------------------------

define lr_copia   record
   plnclscod  like datkplncls.plnclscod
end record

define lr_param   record
   plnclscod  like datkplncls.plnclscod
end record

define lr_retorno record
	srvcod                 like   datksrvplncls.srvcod                ,
  srvplnclsevnlimvlr     like   datksrvplncls.srvplnclsevnlimvlr    ,
  srvplnclsevnlimundnom  like   datksrvplncls.srvplnclsevnlimundnom ,
  srvplnclscod           like   datksrvplncls.srvplnclscod          ,
  srvespcod              like   datkclssrvesp.srvespcod             ,
  clssrvesplimvlr        like   datkclssrvesp.clssrvesplimvlr       ,
  clssrvesplimundnom     like   datkclssrvesp.clssrvesplimundnom    ,
  undsrvcusvlr           like   datkclssrvesp.undsrvcusvlr          ,
  undsrvcusundnom        like   datkclssrvesp.undsrvcusundnom       ,
  cbtcod                 like   datkcbtcss.cbtcod                   ,
  trfctgcod              like   datktrfctgcss.trfctgcod             ,
  lclclacod              like   datklclclartc.lclclacod             ,
  lclclartccod           like   datklclclartc.lclclartccod          ,
  cidcod                 like   datkrtcece.cidcod                   ,
  cont                   integer
end record

initialize lr_retorno.* to null

let lr_retorno.cont = 0


     #--------------------------------------------------
     # Seleciona os Dados dos Pacotes - Processo(1)
     #--------------------------------------------------

     open c_ctc69m41_013 using lr_copia.plnclscod

     foreach c_ctc69m41_013 into  lr_retorno.srvcod
                                , lr_retorno.srvplnclsevnlimvlr
                                , lr_retorno.srvplnclsevnlimundnom
                                , lr_retorno.srvplnclscod

           let lr_retorno.cont =  lr_retorno.cont + 1

           #--------------------------------------------------
           # Grava - Processo(1)
           #--------------------------------------------------

           whenever error continue
           execute p_ctc69m41_014 using lr_param.plnclscod
                                      , lr_retorno.srvcod
                                      , lr_retorno.srvplnclsevnlimvlr
                                      , lr_retorno.srvplnclsevnlimundnom
                                      , g_issk.usrtip
                                      , g_issk.empcod
                                      , g_issk.funmat
                                      , 'today'

           whenever error continue

           if sqlca.sqlcode <> 0 then
              error 'ERRO(',sqlca.sqlcode,') na Insercao dos Pacotes da Clausula!'
              return false
           end if


           #--------------------------------------------------
           # Chave - Processo(1)
           #--------------------------------------------------

           open c_ctc69m41_015 using lr_param.plnclscod   ,
                                     lr_retorno.srvcod
           whenever error continue
           fetch c_ctc69m41_015 into mr_retorno.srvplnclscod
           whenever error stop

           if sqlca.sqlcode <> 0 then
              error 'Erro (',sqlca.sqlcode,') ao Recuperar a Chave!'
              return false
           end if



           #-----------------------------------------------------
           # Seleciona os Dados das Coberturas - Processo(2)
           #-----------------------------------------------------

           open c_ctc69m41_018 using lr_retorno.srvplnclscod

           foreach c_ctc69m41_018 into  lr_retorno.cbtcod

                #--------------------------------------------------
                # Grava - Processo(2)
                #--------------------------------------------------

                whenever error continue
                execute p_ctc69m41_019 using mr_retorno.srvplnclscod
                                           , lr_retorno.cbtcod
                                           , g_issk.usrtip
                                           , g_issk.empcod
                                           , g_issk.funmat
                                           , 'today'

                whenever error continue

                if sqlca.sqlcode <> 0 then
                   error 'ERRO(',sqlca.sqlcode,') na Insercao das Coberturas da Clausula!'
                   return false
                end if


           end foreach


           #-----------------------------------------------------
           # Seleciona os Dados das Categorias - Processo(3)
           #-----------------------------------------------------

           open c_ctc69m41_020 using lr_retorno.srvplnclscod

           foreach c_ctc69m41_020 into  lr_retorno.trfctgcod

                #--------------------------------------------------
                # Grava - Processo(3)
                #--------------------------------------------------

                whenever error continue
                execute p_ctc69m41_021 using mr_retorno.srvplnclscod
                                           , lr_retorno.trfctgcod
                                           , g_issk.usrtip
                                           , g_issk.empcod
                                           , g_issk.funmat
                                           , 'today'

                whenever error continue

                if sqlca.sqlcode <> 0 then
                   error 'ERRO(',sqlca.sqlcode,') na Insercao das Categorias da Clausula!'
                   return false
                end if


           end foreach


           #-----------------------------------------------------
           # Seleciona os Dados das Classes - Processo(4)
           #-----------------------------------------------------

           open c_ctc69m41_022 using lr_retorno.srvplnclscod


           foreach c_ctc69m41_022 into  lr_retorno.lclclacod,
           	                            lr_retorno.lclclartccod

                #--------------------------------------------------
                # Grava - Processo(4)
                #--------------------------------------------------

                whenever error continue
                execute p_ctc69m41_023 using mr_retorno.srvplnclscod
                                           , lr_retorno.lclclacod
                                           , g_issk.usrtip
                                           , g_issk.empcod
                                           , g_issk.funmat
                                           , 'today'

                whenever error continue

                if sqlca.sqlcode <> 0 then
                   error 'ERRO(',sqlca.sqlcode,') na Insercao das Classes da Clausula!'
                   return false
                end if


                #--------------------------------------------------
                # Chave - Processo(4)
                #--------------------------------------------------

                open c_ctc69m41_024 using mr_retorno.srvplnclscod  ,
                                          lr_retorno.lclclacod
                whenever error continue
                fetch c_ctc69m41_024 into mr_retorno.lclclartccod
                whenever error stop

                if sqlca.sqlcode <> 0 then
                   error 'Erro (',sqlca.sqlcode,') ao Recuperar a Chave de Classes!'
                   return false
                end if


                #-----------------------------------------------------
                # Seleciona os Dados das Cidades - Processo(5)
                #-----------------------------------------------------

                open c_ctc69m41_025 using lr_retorno.lclclartccod

                foreach c_ctc69m41_025 into  lr_retorno.cidcod

                     #--------------------------------------------------
                     # Grava - Processo(5)
                     #--------------------------------------------------

                     whenever error continue
                     execute p_ctc69m41_026 using mr_retorno.lclclartccod
                                                , lr_retorno.cidcod
                                                , g_issk.usrtip
                                                , g_issk.empcod
                                                , g_issk.funmat
                                                , 'today'

                     whenever error continue

                     if sqlca.sqlcode <> 0 then
                        error 'ERRO(',sqlca.sqlcode,') na Insercao das Cidades da Classe!'
                        return false
                     end if

                end foreach

           end foreach

     end foreach

     if lr_retorno.cont = 0 then
         error "Copia Nao Efetuada!"
         return false
     end if

     return true

end function

#---------------------------------------------------------
 function ctc69m41_display(lr_param)
#---------------------------------------------------------

 define lr_param     record
    plnclscod      like datkplncls.plnclscod      ,
    empcod         like datkplncls.empcod         ,
    empnom         like gabkemp.empnom            ,
    ramcod         like datkplncls.ramcod         ,
    ramnom         like gtakram.ramnom            , 
    clscod         like datkplncls.clscod         ,
    clsnom         char(60)                       ,               
    clsviginidat   like datkplncls.clsviginidat   ,
    clsvigfimdat   like datkplncls.clsvigfimdat   ,
    clssitflg      like datkplncls.clssitflg      ,
    irdclsflg      like datkplncls.irdclsflg      ,
    regsitflg      like datkplncls.regsitflg      ,
    obs1           char(60)                       ,
    regatldat      like datkplncls.regatldat      ,
    funnom         like isskfunc.funnom
 end record
 
 
 display by name lr_param.plnclscod
 display by name lr_param.empcod
 display by name lr_param.empnom
 display by name lr_param.ramcod
 display by name lr_param.ramnom
 display by name lr_param.clscod
 display by name lr_param.clsnom
 display by name lr_param.clsviginidat
 display by name lr_param.clsvigfimdat
 display by name lr_param.clssitflg
 display by name lr_param.irdclsflg
 display by name lr_param.regsitflg
 display by name lr_param.obs1
 display by name lr_param.regatldat
 display by name lr_param.funnom

 
end function
