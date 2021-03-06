###########################################################################
# Nome do Modulo: ctc92m01                               Helder Oliveira  #
#                                                                         #
# Cadastro de Plano                                              Mar/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descri��o                    #
# -----------  ------------- -------------   ---------------------------- #
# 13/05/2015   Roberto       PJ              PJ                           #
#-------------------------------------------------------------------------#
#                                                                         #
#-------------------------------------------------------------------------#

#                                                                         #
###########################################################################
 globals  "/homedsa/projetos/geral/globals/glct.4gl"

define  m_sql  char(1)

#------------------------------------------------------------
 function ctc92m01_prepare()
#------------------------------------------------------------

define l_sql char(10000)

 let l_sql = ' select itaasiplncod                     '
           , '   from datkitaasipln                    '
           , '  where datkitaasipln.itaasiplncod = ?   '
 prepare p_ctc92m01_001 from l_sql
 declare c_ctc92m01_001 cursor for p_ctc92m01_001

 let l_sql = ' select min(datkitaasipln.itaasiplncod)  '
           , '   from datkitaasipln                    '
           , '  where datkitaasipln.itaasiplncod  >  ? '
 prepare p_ctc92m01_002 from l_sql
 declare c_ctc92m01_002 cursor for p_ctc92m01_002

 let l_sql = ' select max(datkitaasipln.itaasiplncod)  '
           , '   from datkitaasipln                    '
           , '  where datkitaasipln.itaasiplncod  <  ? '
 prepare p_ctc92m01_003 from l_sql
 declare c_ctc92m01_003 cursor for p_ctc92m01_003

 let l_sql = ' update datkitaasipln set (  itaasiplncod    '
           , '                           , itaasiplndes    '
           , '                           , pansoclmtqtd    '
           , '                           , ressrvlimqtd    '
           , '                           , srvlimdat       '
           , '                           , socqlmqtd       '
           , '                           , atldat          '
           , '                           , atlemp          '
           , '                           , atlmat          '
           , '                           , altusrtip )     '
           , '                       =  (?,?,?,?,?,?,?,?,?,?)  '
           , '  where datkitaasipln.itaasiplncod  =  ?     '
 prepare p_ctc92m01_004 from l_sql

 let l_sql = 'insert into datkitaasipln ( itaasiplncod  '
           , '                 , itaasiplndes           '
           , '                 , pansoclmtqtd           '
           , '                 , ressrvlimqtd           '
           , '                 , srvlimdat              '
           , '                 , socqlmqtd              '
           , '                 , atldat                 '
           , '                 , atlemp                 '
           , '                 , atlmat                 '
           , '                 , altusrtip              '
           , '                 )                        '
           , '          values ( ?,?,?,?,?,?,?,?,?,?)   '
 prepare p_ctc92m01_005 from l_sql

 let l_sql = ' select count(*)           '
            , '   from datkitaasipln     '
            , '  where itaasiplncod = ?  '
 prepare p_ctc92m01_006 from l_sql
 declare c_ctc92m01_006 cursor for p_ctc92m01_006

 let l_sql = ' select count(*)           '
           , '   from datkitaasipln      '
           , '  where itaasiplndes =  ?  '
           , '    and itaasiplncod <> ?  '
 prepare p_ctc92m01_007 from l_sql
 declare c_ctc92m01_007 cursor for p_ctc92m01_007

 let l_sql = ' select  itaasiplncod                   '
           , '      ,  itaasiplndes                   '
           , '      ,  pansoclmtqtd                   '
           , '      ,  ressrvlimqtd                   '
           , '      ,  srvlimdat                      '
           , '      ,  socqlmqtd                      '
           , '      ,  altusrtip                      '
           , '      ,  atlemp                         '
           , '      ,  atlmat                         '
           , '      ,  atldat                         '
           , '   from  datkitaasipln                  '
           , '  where  datkitaasipln.itaasiplncod = ? '
 prepare p_ctc92m01_008 from l_sql
 declare c_ctc92m01_008 cursor for p_ctc92m01_008

 let l_sql = ' select count(*)           '
           , '  from datkitacbtintrgr    '
           , ' where itaasiplncod = ?    '
 prepare p_ctc92m01_009 from l_sql
 declare c_ctc92m01_009 cursor for p_ctc92m01_009

 let l_sql = '  select funnom               '
           , '    from isskfunc             '
           , '   where isskfunc.funmat = ?  '
           , '     and empcod = ?           '
           , '     and usrtip = ?           '
 prepare p_ctc92m01_010 from l_sql
 declare c_ctc92m01_010 cursor for p_ctc92m01_010

 let l_sql = ' select min(itaasiplncod)   '
           , '   from datkitaasipln       '
 prepare p_ctc92m01_011 from l_sql
 declare c_ctc92m01_011 cursor for p_ctc92m01_011


 let l_sql = "SELECT MAX(NVL(itaasiplncod,0)) + 1 ",
             "FROM datkitaasipln "
 prepare p_ctc92m01_012 from l_sql
 declare c_ctc92m01_012 cursor with hold for p_ctc92m01_012

 let l_sql = ' select count(*)           '
           , '  from datritaasiplnast    '
           , ' where itaasiplncod = ?    '
 prepare p_ctc92m01_013 from l_sql
 declare c_ctc92m01_013 cursor for p_ctc92m01_013
 	
 	
 let l_sql = ' select count(*)         '      
        ,  '  from datkdominio        '      
        ,  '  where cponom = ?        '      
        ,  '  and   cpodes = ?        '      
 prepare p_ctc92m01_014 from l_sql              
 declare c_ctc92m01_014 cursor for p_ctc92m01_014 


let m_sql = 'S'

end function

#------------------------------------------------------------
 function ctc92m01()
#------------------------------------------------------------

 define ctc92m01      record
      cod             like datkitaasipln.itaasiplncod
    , descricao       like datkitaasipln.itaasiplndes
    , limite          like datkitaasipln.pansoclmtqtd
    , ressrvlimqtd    like datkitaasipln.ressrvlimqtd
    , srvlimdat       like datkitaasipln.srvlimdat
    , km              like datkitaasipln.socqlmqtd
    , atldat          like datkitaasipln.atldat
    , funnom          like isskfunc.funnom
    , obs1            char(58)
    , obs2            char(58)
 end record

 let int_flag = false
 initialize ctc92m01.*  to null

 call ctc92m01_prepare()

 open window ctc92m01 at 4,2 with form "ctc92m01"


 menu "PLANOS"

 command key ("S") "Seleciona"
                   "Pesquisa Planos conforme criterios"
          call ctc92m01_seleciona()  returning ctc92m01.*
          if ctc92m01.cod  is not null  then
             message ""
             next option "Proximo"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo plano selecionado"
          message ""
          #if ctc92m01.cod is not null then
             call ctc92m01_proximo(ctc92m01.cod)
                  returning ctc92m01.*

             if ctc92m01.cod is null then
                display by name ctc92m01.*
                next option "Seleciona"
             end if
         # end if

 command key ("A") "Anterior"
                   "Mostra plano anterior selecionado"
          message ""
          if ctc92m01.cod is not null then
             call ctc92m01_anterior(ctc92m01.cod)
                  returning ctc92m01.*

             if ctc92m01.cod is null then
                display by name ctc92m01.*
                next option "Seleciona"
             end if
          end if

 command key ("M") "Modifica"
                   "Modifica Planos"
          message ""
          if ctc92m01.cod  is not null then
             call ctc92m01_modifica(ctc92m01.cod, ctc92m01.*)
                  returning ctc92m01.*
             next option "Seleciona"
          else
             error " Nenhum plano selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui Planos"
          message ""
          call ctc92m01_inclui()
          next option "Seleciona"

 command key ("C") "Coberturas"
                   "Coberturas de Plano"
           call ctc92m03(ctc92m01.cod)
           next option "Seleciona"

 command key ("R") "Residencia"
                   "Residencia do Plano"
          if ctc92m01.cod  is not null then
             if ctc92m01.cod = 3 then
                 call ctc92m09(ctc92m01.cod           ,
                               ctc92m01.descricao     ,
                               ctc92m01.ressrvlimqtd  )
             else
             	   call ctc92m04(ctc92m01.cod,ctc92m01.descricao)
             end if
          else
             error " Nenhum plano selecionado!"
             next option "Seleciona"
          end if

 command key ("U") "AssUntos"
                 "Assuntos do Plano"
          if ctc92m01.cod  is not null then
             call ctc92m05(ctc92m01.cod)
                  #returning ctc92m01.*
             next option "Seleciona"
          else
             error " Nenhum plano selecionado!"
             next option "Seleciona"
          end if
          
 command key ("L") "Empresarial"
                 "Menu Empresarial"
          if ctc92m01.cod  is not null then
             
             if ctc92m01_verifica_empresarial(ctc92m01.cod) then
                call ctc92m01_submenu(ctc92m01.cod,
                                      ctc92m01.descricao)
                next option "Seleciona"  
             else
             	  error " Este Plano nao e Empresarial!"  
             	  next option "Seleciona"             
             end if	
          else
             error " Nenhum plano selecionado!"
             next option "Seleciona"
          end if         

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc92m01

 end function  # ctc92m01


#------------------------------------------------------------
 function ctc92m01_seleciona()
#------------------------------------------------------------

 define ctc92m01      record
      cod             like datkitaasipln.itaasiplncod
    , descricao       like datkitaasipln.itaasiplndes
    , limite          like datkitaasipln.pansoclmtqtd
    , ressrvlimqtd    like datkitaasipln.ressrvlimqtd
    , srvlimdat       like datkitaasipln.srvlimdat
    , km              like datkitaasipln.socqlmqtd
    , atldat          like datkitaasipln.atldat
    , funnom          like isskfunc.funnom
    , obs1            char(58)
    , obs2            char(58)
 end record

 define l_aux like datkitaasipln.itaasiplncod

  if m_sql <> 'S' then
    call ctc92m01_prepare()
  end if

 let int_flag = false
 initialize ctc92m01.*  to null
 display by name ctc92m01.*

 input by name ctc92m01.cod

    before field cod
        display by name ctc92m01.cod attribute (reverse)

    after  field cod
        display by name ctc92m01.cod

        open c_ctc92m01_001 using ctc92m01.cod
        fetch c_ctc92m01_001 into l_aux

        if l_aux  is null or
           l_aux  = ''    then
           error " Codigo de Plano nao cadastrado!"
           next field cod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc92m01.*   to null
    display by name ctc92m01.*
    error " Operacao cancelada!"
    return ctc92m01.*
 end if

 call ctc92m01_ler(ctc92m01.cod)
      returning ctc92m01.*

 if ctc92m01.cod  is not null   then
    display by name  ctc92m01.*
 else
    error " Codigo de Plano nao cadastrado!"
    initialize ctc92m01.*    to null
 end if

 return ctc92m01.*

 end function  # ctc92m01_seleciona


#------------------------------------------------------------
 function ctc92m01_proximo(param)
#------------------------------------------------------------

 define param         record
        cod         like datkitaasipln.itaasiplncod
 end record

 define ctc92m01      record
      cod             like datkitaasipln.itaasiplncod
    , descricao       like datkitaasipln.itaasiplndes
    , limite          like datkitaasipln.pansoclmtqtd
    , ressrvlimqtd    like datkitaasipln.ressrvlimqtd
    , srvlimdat       like datkitaasipln.srvlimdat
    , km              like datkitaasipln.socqlmqtd
    , atldat          like datkitaasipln.atldat
    , funnom          like isskfunc.funnom
    , obs1            char(58)
    , obs2            char(58)
 end record

  if m_sql <> 'S' then
    call ctc92m01_prepare()
  end if

 let int_flag = false
 initialize ctc92m01.*   to null

 if param.cod  is null   then
    open c_ctc92m01_011
    fetch c_ctc92m01_011 into param.cod
    let param.cod = param.cod - 1
 end if

  open c_ctc92m01_002 using param.cod
  fetch c_ctc92m01_002 into ctc92m01.cod

 if ctc92m01.cod  is not null   then
    call ctc92m01_ler(ctc92m01.cod)
         returning ctc92m01.*

    if ctc92m01.cod  is not null   then
       display by name  ctc92m01.*
    else
       error "Nao ha' plano nesta direcao!"
       initialize ctc92m01.*    to null
    end if
 else
    error " Nao ha' plano nesta direcao!"
    initialize ctc92m01.*    to null
 end if

 return ctc92m01.*

 end function    # ctc92m01_proximo


#------------------------------------------------------------
 function ctc92m01_anterior(param)
#------------------------------------------------------------

 define param         record
    cod         like datkitaasipln.itaasiplncod
 end record

 define ctc92m01      record
      cod             like datkitaasipln.itaasiplncod
    , descricao       like datkitaasipln.itaasiplndes
    , limite          like datkitaasipln.pansoclmtqtd
    , ressrvlimqtd    like datkitaasipln.ressrvlimqtd
    , srvlimdat       like datkitaasipln.srvlimdat
    , km              like datkitaasipln.socqlmqtd
    , atldat          like datkitaasipln.atldat
    , funnom          like isskfunc.funnom
    , obs1            char(58)
    , obs2            char(58)
 end record

  if m_sql <> 'S' then
    call ctc92m01_prepare()
  end if

 let int_flag = false
 initialize ctc92m01.*  to null

 if param.cod  is null   then
    let param.cod = " "
 end if

 open c_ctc92m01_003 using param.cod
 fetch c_ctc92m01_003 into ctc92m01.cod

 if ctc92m01.cod  is not null   then

    call ctc92m01_ler(ctc92m01.cod)
         returning ctc92m01.*

    if ctc92m01.cod  is not null   then
       display by name  ctc92m01.*
    else
       error " Nao ha' plano nesta direcao!"
       initialize ctc92m01.*    to null
    end if
 else
    error " Nao ha' plano nesta direcao!"
    initialize ctc92m01.*    to null
 end if

 return ctc92m01.*

 end function    # ctc92m01_anterior


#------------------------------------------------------------
 function ctc92m01_modifica(param, ctc92m01)
#------------------------------------------------------------

 define param         record
    cod         like datkitaasipln.itaasiplncod
 end record

 define ctc92m01      record
      cod             like datkitaasipln.itaasiplncod
    , descricao       like datkitaasipln.itaasiplndes
    , limite          like datkitaasipln.pansoclmtqtd
    , ressrvlimqtd    like datkitaasipln.ressrvlimqtd
    , srvlimdat       like datkitaasipln.srvlimdat
    , km              like datkitaasipln.socqlmqtd
    , atldat          like datkitaasipln.atldat
    , funnom          like isskfunc.funnom
    , obs1            char(58)
    , obs2            char(58)
 end record

  if m_sql <> 'S' then
    call ctc92m01_prepare()
  end if

 call ctc92m01_input("a", ctc92m01.*) returning ctc92m01.*

 if int_flag  then
    let int_flag = false
    initialize ctc92m01.*  to null
    display by name ctc92m01.*
    error " Operacao cancelada!"
    return ctc92m01.*
 end if

 whenever error continue

 let ctc92m01.atldat = today

 begin work

  execute p_ctc92m01_004 using  ctc92m01.cod
                              , ctc92m01.descricao
                              , ctc92m01.limite
                              , ctc92m01.ressrvlimqtd
                              , ctc92m01.srvlimdat
                              , ctc92m01.km
                              , ctc92m01.atldat
                              , g_issk.empcod
                              , g_issk.funmat
                              , g_issk.usrtip
                              , ctc92m01.cod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do Plano!"
       rollback work
       initialize ctc92m01.*   to null
       return ctc92m01.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize ctc92m01.*  to null
 display by name ctc92m01.*
 message ""
 return ctc92m01.*

 end function   #  ctc92m01_modifica


#------------------------------------------------------------
 function ctc92m01_inclui()
#------------------------------------------------------------

 define ctc92m01      record
      cod             like datkitaasipln.itaasiplncod
    , descricao       like datkitaasipln.itaasiplndes
    , limite          like datkitaasipln.pansoclmtqtd
    , ressrvlimqtd    like datkitaasipln.ressrvlimqtd
    , srvlimdat       like datkitaasipln.srvlimdat
    , km              like datkitaasipln.socqlmqtd
    , atldat          like datkitaasipln.atldat
    , funnom          like isskfunc.funnom
    , obs1            char(58)
    , obs2            char(58)
 end record

 define  ws_resp       char(01)

 define l_ret       smallint,             #PSI 205206
        l_mensagem  char(60)

 initialize ctc92m01.*   to null
 let l_ret = 0                            #PSI 205206
 let l_mensagem = null                    #PSI 205206

  if m_sql <> 'S' then
    call ctc92m01_prepare()
  end if

 display by name ctc92m01.*

 call ctc92m01_input("i", ctc92m01.*) returning ctc92m01.*

 if int_flag  then
    let int_flag = false
    initialize ctc92m01.*  to null
    display by name ctc92m01.*
    error " Operacao cancelada!"
    return
 end if

 let ctc92m01.atldat = today

 whenever error continue

 begin work

  execute p_ctc92m01_005 using  ctc92m01.cod
                              , ctc92m01.descricao
                              , ctc92m01.limite
                              , ctc92m01.ressrvlimqtd
                              , ctc92m01.srvlimdat
                              , ctc92m01.km
                              , ctc92m01.atldat
                              , g_issk.empcod
                              , g_issk.funmat
                              , g_issk.usrtip

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do Plano!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc92m01_func(g_issk.funmat,
                    g_issk.empcod,
                    g_issk.usrtip)
      returning ctc92m01.funnom

 display by name  ctc92m01.*

 display by name ctc92m01.cod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize ctc92m01.*  to null
 display by name ctc92m01.*

 end function   #  ctc92m01_inclui


#--------------------------------------------------------------------
 function ctc92m01_input(param, ctc92m01)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define l_count smallint

 define ctc92m01      record
      cod             like datkitaasipln.itaasiplncod
    , descricao       like datkitaasipln.itaasiplndes
    , limite          like datkitaasipln.pansoclmtqtd
    , ressrvlimqtd    like datkitaasipln.ressrvlimqtd
    , srvlimdat       like datkitaasipln.srvlimdat
    , km              like datkitaasipln.socqlmqtd
    , atldat          like datkitaasipln.atldat
    , funnom          like isskfunc.funnom
    , obs1            char(58)
    , obs2            char(58)
 end record

 define l_erro        smallint,
        l_mensagem    char(60)     #PSI 205206

  if m_sql <> 'S' then
    call ctc92m01_prepare()
  end if

 let l_count = 0
 let l_erro = 0
 let int_flag = false
 let l_mensagem = null

 input by name ctc92m01.cod
             , ctc92m01.descricao
             , ctc92m01.limite
             , ctc92m01.ressrvlimqtd
             , ctc92m01.srvlimdat
             , ctc92m01.km
               without defaults

    before field cod
            if param.operacao  =  "a"   then
               next field  descricao
            end if
           display by name ctc92m01.cod attribute (reverse)

    after  field cod
            display by name ctc92m01.cod

           if ctc92m01.cod = " " or
              ctc92m01.cod is null then
              # Se usuario nao digitou um valor para codigo, buscar o proximo
              call ctc92m01_retorna_proximo_cod()
                 returning ctc92m01.cod
              display by name ctc92m01.cod

              let l_count = 0
              next field descricao
           end if

           if ctc92m01.cod  is null   then
              error " Codigo do Plano deve ser informado!"
              next field cod
           end if

           open c_ctc92m01_006 using ctc92m01.cod
           fetch c_ctc92m01_006 into l_count

           if l_count  >  0   then
              error " Codigo de Plano ja' cadastrado!"
              next field cod
           end if

           let l_count = 0

    before field descricao
           display by name ctc92m01.descricao attribute (reverse)

    after  field descricao
           display by name ctc92m01.descricao

           open c_ctc92m01_007 using ctc92m01.descricao
                                   , ctc92m01.cod
           fetch c_ctc92m01_007 into l_count

           if l_count > 0 then
              error 'DESCRICAO JA CADASTRADA PARA OUTRO PLANO'
              next field descricao
           end if

           let l_count = 0

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.operacao  =  "i"   then
                 next field  cod
              else
                 next field  descricao
              end if
           end if

           if ctc92m01.descricao  is null   then
              error " Descricao do plano deve ser informado!"
              next field descricao
           end if

    #PSI 199850
    before field limite
           display by name ctc92m01.limite attribute (reverse)

    after field limite
           display by name ctc92m01.limite

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  descricao
           end if

           display by name ctc92m01.limite
    before field ressrvlimqtd
           display by name ctc92m01.ressrvlimqtd  attribute (reverse)
    after field ressrvlimqtd
           display by name ctc92m01.ressrvlimqtd
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  limite
           end if
           display by name ctc92m01.ressrvlimqtd

    before field srvlimdat
           display by name ctc92m01.srvlimdat   attribute (reverse)
    after field srvlimdat
           display by name ctc92m01.srvlimdat
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  ressrvlimqtd
           end if
           display by name ctc92m01.srvlimdat

    before field km
           display by name ctc92m01.km attribute (reverse)

    after field km
           display by name ctc92m01.km
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  srvlimdat
           end if


    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize ctc92m01.*  to null
 end if

 return ctc92m01.*

 end function   # ctc92m01_input


#---------------------------------------------------------
 function ctc92m01_ler(param)
#---------------------------------------------------------

 define param         record
    cod         like datkitaasipln.itaasiplncod
 end record

 define ctc92m01      record
      cod             like datkitaasipln.itaasiplncod
    , descricao       like datkitaasipln.itaasiplndes
    , limite          like datkitaasipln.pansoclmtqtd
    , ressrvlimqtd    like datkitaasipln.ressrvlimqtd
    , srvlimdat       like datkitaasipln.srvlimdat
    , km              like datkitaasipln.socqlmqtd
    , atldat          like datkitaasipln.atldat
    , funnom          like isskfunc.funnom
    , obs1            char(58)
    , obs2            char(58)
 end record

 define ws            record
    atlmat            like isskfunc.funmat,
    atlemp            like isskfunc.empcod,
    atlusrtip         like isskfunc.usrtip,
    cont              integer
 end record

 define l_ret       smallint,
        l_mensagem  char(60)

  if m_sql <> 'S' then
    call ctc92m01_prepare()
  end if

 initialize ctc92m01.*   to null
 initialize ws.*         to null
 let l_ret = 0
 let l_mensagem = null


 open c_ctc92m01_008 using param.cod
 fetch c_ctc92m01_008 into  ctc92m01.cod
                         ,  ctc92m01.descricao
                         ,  ctc92m01.limite
                         ,  ctc92m01.ressrvlimqtd
                         ,  ctc92m01.srvlimdat
                         ,  ctc92m01.km
                         ,  ws.atlusrtip
                         ,  ws.atlemp
                         ,  ws.atlmat
                         ,  ctc92m01.atldat

 if ctc92m01.cod is null  then
    error " Codigo de Plano nao cadastrado!"
    initialize ctc92m01.*    to null
    return ctc92m01.*
 else

    call ctc92m01_func(ws.atlmat,ws.atlemp,ws.atlusrtip)
         returning ctc92m01.funnom

      open c_ctc92m01_009 using param.cod
      fetch c_ctc92m01_009 into ws.cont

      if ws.cont  >  0   then
         if ws.cont = 1 then
            let ctc92m01.obs1 =  "EXISTE ", ws.cont using "<<<,<<<", " COBERTURA ASSOCIADA A ESTE PLANO."
         else
            let ctc92m01.obs1 =  "EXISTEM ", ws.cont using "<<<,<<<", " COBERTURAS ASSOCIADAS A ESTE PLANO."
         end if
      else
         let ctc92m01.obs1 =  "NAO EXISTEM COBERTURAS ASSOCIADAS A ESTE PLANO."
      end if


      open c_ctc92m01_013 using param.cod
      fetch c_ctc92m01_013 into ws.cont

      if ws.cont  >  0   then
         if ws.cont = 1 then
            let ctc92m01.obs2 =  "EXISTE ", ws.cont using "<<<,<<<", " ASSUNTO ASSOCIADO A ESTE PLANO."
         else
            let ctc92m01.obs2 =  "EXISTEM ", ws.cont using "<<<,<<<", " ASSUNTOS ASSOCIADOS A ESTE PLANO."
         end if
      else
         let ctc92m01.obs2 =  "NAO EXISTEM ASSUNTOS ASSOCIADOS A ESTE PLANO."
      end if


 end if

 return ctc92m01.*

 end function   # ctc92m01_ler


#---------------------------------------------------------
 function ctc92m01_func(param)
#---------------------------------------------------------

 define param         record
    funmat            like isskfunc.funmat,
    empcod            like isskfunc.empcod,
    usrtip            like isskfunc.usrtip
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record

  if m_sql <> 'S' then
    call ctc92m01_prepare()
  end if

 initialize ws.*    to null

   if param.empcod is null or
      param.empcod = " " then
    let param.empcod = 1
   end if

   open c_ctc92m01_010 using param.funmat ,
                             param.empcod ,
                             param.usrtip
   fetch c_ctc92m01_010 into ws.funnom

 return ws.funnom

 end function   # ctc92m01_func


#---------------------------------------------------------
 function ctc92m01_retorna_proximo_cod()
#---------------------------------------------------------
   define l_retorno smallint

   whenever error continue
   open c_ctc92m01_012
   fetch c_ctc92m01_012 into l_retorno
   whenever error stop
   close c_ctc92m01_012

   return l_retorno

 end function  
 
 #------------------------------------------------------------        
  function ctc92m01_submenu(ctc92m01)                                                 
 #------------------------------------------------------------        
                                                                      
  define ctc92m01      record                                         
       cod             like datkitaasipln.itaasiplncod                
     , descricao       like datkitaasipln.itaasiplndes                                   
  end record                                                          
                                                                                                                                                                    
                                                                                                                  
  menu "EMPRESARIAL"
  
  
  command key ("A") "Assistencias"                         
                  "Assistencias do Plano"                  
                                                        
              call ctc92m12(ctc92m01.cod,               
                            ctc92m01.descricao)         
                                                        
  
  command key ("S") "Assuntos"                         
                  "Assuntos do Plano"                  
                                                        
              call ctc92m11(ctc92m01.cod,               
                            ctc92m01.descricao)         
                                                                                                               
  command key ("M") "Motivos"                         
                "Motivos do Plano"                  
                                                      
              call ctc92m13(ctc92m01.cod,               
                            ctc92m01.descricao)         
                                                      
  
  command key ("P") "Problemas"                                       
                  "Problemas do Plano"                                
                                   
              call ctc92m10(ctc92m01.cod,                             
                            ctc92m01.descricao)                       
                                              
                                                   
                                                                      
  command key (interrupt,E) "Encerra"                                 
                    "Retorna ao menu anterior"                        
           exit menu                                                  
  end menu                                                                                                     
                                                                      
  end function  # ctc92m01 
  
#-------------------------------------------------#                                                             
 function ctc92m01_verifica_empresarial(lr_param)                    
#-------------------------------------------------#                  
                                                                     
define lr_param record                                               
  itaasiplncod     like datkitaasipln.itaasiplncod                   
end record                                                           
                                                                     
define lr_retorno record                                             
  cont       smallint,                                               
  chave      char(20)                                                
end record                                                           
                                                                     
initialize lr_retorno.* to null                                      
                                                                     
                                                                     
    let lr_retorno.chave = "ctc92m01_plano"                          
                                                                     
    #--------------------------------------------------------        
    # Verifica se o Plano e Empresarial                              
    #--------------------------------------------------------        
                                                                     
    open c_ctc92m01_014  using  lr_retorno.chave  ,                  
                                lr_param.itaasiplncod                
    whenever error continue                                          
    fetch c_ctc92m01_014 into lr_retorno.cont                        
    whenever error stop                                              
                                                                     
    if lr_retorno.cont > 0 then                                      
    	 return true                                                   
    end if                                                           
                                                                     
    return false                                                     
                                                                     
                                                                     
end function                                                         