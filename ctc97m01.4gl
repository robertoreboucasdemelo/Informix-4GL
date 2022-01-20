#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Central 24hs                                                #
# Modulo........: ctc97m00                                                    #
# Analista Resp.: Amilton Pinto                                               #
# PSI...........: PSI-2012-15798                                              #
# Objetivo......: Tela de cadastro de plano Assistencia                       #
#.............................................................................#
# Desenvolvimento: Amilton Pinto                                              #
# Liberacao......:                                                            #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#


 globals  "/homedsa/projetos/geral/globals/glct.4gl"

define  m_ctc97m01_prepare  smallint

#------------------------------------------------------------
 function ctc97m01_prepare()
#------------------------------------------------------------

define l_sql char(10000)

 let l_sql = ' select srvcod '
           , '   from datkresitaasipln'
           , '  where srvcod = ?   '
 prepare p_ctc97m01_001 from l_sql
 declare c_ctc97m01_001 cursor for p_ctc97m01_001

 let l_sql = ' select min(srvcod)  '
           , '   from datkresitaasipln                    '
           , '  where srvcod  >  ? '
 prepare p_ctc97m01_002 from l_sql
 declare c_ctc97m01_002 cursor for p_ctc97m01_002

 let l_sql = ' select max(srvcod)  '
           , '  from datkresitaasipln                    '
           , '  where srvcod  <  ? '
 prepare p_ctc97m01_003 from l_sql
 declare c_ctc97m01_003 cursor for p_ctc97m01_003

 #let l_sql = ' update datkresitaasipln set (  itaasiplncod    '
 #          , '                               , itaasiplndes    '
 #          , '                           , pansoclmtqtd          '
 #          , '                           , socqlmqtd           '
 #          , '                           , atldat          '
 #          , '                           , atlemp          '
 #          , '                           , atlmat          '
 #          , '                           , altusrtip )     '
 #          , '                       =  (?,?,?,?,?,?,?,?)  '
 #          , '  where datkitaasipln.itaasiplncod  =  ?     '
 #prepare p_ctc97m01_004 from l_sql

 let l_sql = 'insert into datkresitaasipln   '
           , '                 ( asiplncod              '
           , '                 , srvcod                 '
           , '                 , atldat                 '
           , '                 , atlempcod              '
           , '                 , atlmatnum              '
           , '                 , atlusrtipcod           '
           , '                 )                        '
           , '          values ( ?,?,?,?,?,?)       '
 prepare p_ctc97m01_005 from l_sql

 let l_sql = ' select count(*)           '
            , '   from datkresitaasipln     '
            , '  where srvcod = ?  '
 prepare p_ctc97m01_006 from l_sql
 declare c_ctc97m01_006 cursor for p_ctc97m01_006

 #let l_sql = ' select count(*)           '
 #          , '   from datkresitapln      '
 #          , '  where asiplndes =  ?  '
 #          , '    and asiplncod <> ?  '
 #prepare p_ctc97m01_007 from l_sql
 #declare c_ctc97m01_007 cursor for p_ctc97m01_007

 let l_sql = ' select  srvcod                      '
           , '      ,  asiplncod                   '
           , '      ,  atlusrtipcod                '
           , '      ,  atlempcod                   '
           , '      ,  atlmatnum                   '
           , '      ,  atldat                      '
           , '   from  datkresitaasipln '
           , '  where  srvcod = ? '
 prepare p_ctc97m01_008 from l_sql
 declare c_ctc97m01_008 cursor for p_ctc97m01_008

 let l_sql = '  select funnom               '
           , '    from isskfunc             '
           , '   where isskfunc.funmat = ?  '
           , '     and empcod = ?           '
           , '     and usrtip = ?           '
 prepare p_ctc97m01_010 from l_sql
 declare c_ctc97m01_010 cursor for p_ctc97m01_010

 let l_sql = ' select min(srvcod)   '
           , '   from datkresitaasipln       '
 prepare p_ctc97m01_011 from l_sql
 declare c_ctc97m01_011 cursor for p_ctc97m01_011


 let l_sql = "SELECT MAX(NVL(asiplncod,0)) + 1 ",
             "FROM datkresitaasipln "
 prepare p_ctc97m01_012 from l_sql
 declare c_ctc97m01_012 cursor with hold for p_ctc97m01_012

 let l_sql = ' select count(*)           '
            , '   from datkresitaasipln     '
            , '  where srvcod = ?  '
 prepare p_ctc97m01_014 from l_sql
 declare c_ctc97m01_014 cursor for p_ctc97m01_014

 let l_sql = ' select srvdes  '
            , '   from datkresitasrv  '
            , '  where srvcod = ?     '
 prepare p_ctc97m01_015 from l_sql
 declare c_ctc97m01_015 cursor for p_ctc97m01_015


let m_ctc97m01_prepare = true

end function

#------------------------------------------------------------
 function ctc97m01()
#------------------------------------------------------------

  define ctc97m01      record
       cod             like datkresitasrv.srvcod
     , descricao       like datkresitasrv.srvdes
     , asiplncod       like datkitaasipln.itaasiplncod
     , asiplndes       like datkitaasipln.itaasiplndes
     , atldat          like datkitaasipln.atldat
     , funnom          like isskfunc.funnom
  end record



 let int_flag = false
 initialize ctc97m01.*  to null

 if m_ctc97m01_prepare is null or
    m_ctc97m01_prepare = false then
    call ctc97m01_prepare()
 end if

 open window ctc97m01 at 4,2 with form "ctc97m01"


 menu "PLANOS"

 command key ("S") "Seleciona"
                   "Pesquisa Planos conforme criterios"
          call ctc97m01_seleciona()  returning ctc97m01.*
          if ctc97m01.cod  is not null  then
             message ""
             next option "Proximo"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo plano selecionado"
          message ""
          #if ctc97m01.cod is not null then
             call ctc97m01_proximo(ctc97m01.cod)
                  returning ctc97m01.*

             if ctc97m01.cod is null then
                display by name ctc97m01.*
                next option "Seleciona"
             end if
         # end if

 command key ("A") "Anterior"
                   "Mostra plano anterior selecionado"
          message ""
          if ctc97m01.cod is not null then
             call ctc97m01_anterior(ctc97m01.cod)
                  returning ctc97m01.*

             if ctc97m01.cod is null then
                display by name ctc97m01.*
                next option "Seleciona"
             end if
          end if

 #command key ("M") "Modifica"
 #                  "Modifica Planos"
 #         message ""
 #         if ctc97m01.cod  is not null then
 #            call ctc97m01_modifica(ctc97m01.cod, ctc97m01.*)
 #                 returning ctc97m01.*
 #            next option "Seleciona"
 #         else
 #            error " Nenhum plano selecionado!"
 #            next option "Seleciona"
 #         end if

 command key ("I") "Inclui"
                   "Inclui Planos"
          message ""
          call ctc97m01_inclui()
          next option "Seleciona"

 command key ("C") "Grupo e Naturezas"
                   "naturezas  de Plano"
           call ctc97m03(ctc97m01.asiplncod,ctc97m01.descricao)
           next option "Seleciona"

  command key ("H") "Help_Desk"
                    "Limites Help Desk"
           if ctc97m01.cod  is not null then
              call ctc97m04(ctc97m01.cod,ctc97m01.descricao)
           else
              error " Nenhum plano selecionado!"
              next option "Seleciona"
           end if
  
 #command key ("U") "AssUntos"
 #                "Assuntos do Plano"
 #         if ctc97m01.cod  is not null then
 #            call ctc92m05(ctc97m01.cod)
 #                 #returning ctc97m01.*
 #            next option "Seleciona"
 #         else
 #            error " Nenhum plano selecionado!"
 #            next option "Seleciona"
 #         end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc97m01

 end function  # ctc97m01


#------------------------------------------------------------
 function ctc97m01_seleciona()
#------------------------------------------------------------

 define ctc97m01      record
      cod             like datkresitasrv.srvcod
    , descricao       like datkresitasrv.srvdes
    , asiplncod       like datkitaasipln.itaasiplncod
    , asiplndes       like datkitaasipln.itaasiplndes
    , atldat          like datkitaasipln.atldat
    , funnom          like isskfunc.funnom
 end record



 define l_aux like datkresitasrv.srvcod

  if m_ctc97m01_prepare is null or
    m_ctc97m01_prepare = false then
    call ctc97m01_prepare()
 end if

 let int_flag = false
 initialize ctc97m01.*  to null
 display by name ctc97m01.*

 input by name ctc97m01.cod

    before field cod
        display by name ctc97m01.cod attribute (reverse)

    after  field cod
        display by name ctc97m01.cod

        open c_ctc97m01_001 using ctc97m01.cod
        fetch c_ctc97m01_001 into l_aux

        if l_aux  is null or
           l_aux  = ''    then
           error " Codigo de servico nao cadastrado!"
           next field cod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc97m01.*   to null
    display by name ctc97m01.*
    error " Operacao cancelada!"
    return ctc97m01.*
 end if

 call ctc97m01_ler(ctc97m01.cod)
      returning ctc97m01.*

 if ctc97m01.cod  is not null   then
    display by name  ctc97m01.*
 else
    error " Codigo de Servico nao cadastrado!"
    initialize ctc97m01.*    to null
 end if

 return ctc97m01.*

 end function  # ctc97m01_seleciona


#------------------------------------------------------------
 function ctc97m01_proximo(param)
#------------------------------------------------------------

 define param         record
        cod         like datkitaasipln.itaasiplncod
 end record

 define ctc97m01      record
      cod             like datkresitasrv.srvcod
    , descricao       like datkresitasrv.srvdes
    , asiplncod       like datkitaasipln.itaasiplncod
    , asiplndes       like datkitaasipln.itaasiplndes
    , atldat          like datkitaasipln.atldat
    , funnom          like isskfunc.funnom
 end record

  if m_ctc97m01_prepare is null or
    m_ctc97m01_prepare = false then
    call ctc97m01_prepare()
 end if

 let int_flag = false
 initialize ctc97m01.*   to null

 if param.cod  is null   then
    open c_ctc97m01_011
    fetch c_ctc97m01_011 into param.cod
    let param.cod = param.cod - 1
 end if

  open c_ctc97m01_002 using param.cod
  fetch c_ctc97m01_002 into ctc97m01.cod

 if ctc97m01.cod  is not null   then
    call ctc97m01_ler(ctc97m01.cod)
         returning ctc97m01.*

    if ctc97m01.cod  is not null   then
       display by name  ctc97m01.*
    else
       error "Nao ha' plano nesta direcao!"
       initialize ctc97m01.*    to null
    end if
 else
    error " Nao ha' plano nesta direcao!"
    initialize ctc97m01.*    to null
 end if

 return ctc97m01.*

 end function    # ctc97m01_proximo


#------------------------------------------------------------
 function ctc97m01_anterior(param)
#------------------------------------------------------------

 define param         record
    cod         like datkitaasipln.itaasiplncod
 end record

define ctc97m01      record
     cod             like datkresitasrv.srvcod
   , descricao       like datkresitasrv.srvdes
   , asiplncod       like datkitaasipln.itaasiplncod
   , asiplndes       like datkitaasipln.itaasiplndes
   , atldat          like datkitaasipln.atldat
   , funnom          like isskfunc.funnom
end record



if m_ctc97m01_prepare is null or
    m_ctc97m01_prepare = false then
    call ctc97m01_prepare()
 end if

 let int_flag = false
 initialize ctc97m01.*  to null

 if param.cod  is null   then
    let param.cod = " "
 end if

 open c_ctc97m01_003 using param.cod
 fetch c_ctc97m01_003 into ctc97m01.cod

 if ctc97m01.cod  is not null   then

    call ctc97m01_ler(ctc97m01.cod)
         returning ctc97m01.*

    if ctc97m01.cod  is not null   then
       display by name  ctc97m01.*
    else
       error " Nao ha' plano nesta direcao!"
       initialize ctc97m01.*    to null
    end if
 else
    error " Nao ha' plano nesta direcao!"
    initialize ctc97m01.*    to null
 end if

 return ctc97m01.*

 end function    # ctc97m01_anterior


##------------------------------------------------------------
# function ctc97m01_modifica(param, ctc97m01)
##------------------------------------------------------------
#
# define param         record
#    cod         like datkitaasipln.itaasiplncod
# end record
#
# define ctc97m01      record
#      cod             like datkresitasrv.srvcod
#    , descricao       like datkresitasrv.srvdes
#    , asiplncod       like datkitaasipln.itaasiplncod
#    , asiplndes       like datkresitaasipln.asiplndes
#    , atldat          like datkitaasipln.atldat
#    , funnom          like isskfunc.funnom
# end record
#
#
#
#  if m_sql <> 'S' then
#    call ctc97m01_prepare()
#  end if
#
# call ctc97m01_input("a", ctc97m01.*) returning ctc97m01.*
#
# if int_flag  then
#    let int_flag = false
#    initialize ctc97m01.*  to null
#    display by name ctc97m01.*
#    error " Operacao cancelada!"
#    return ctc97m01.*
# end if
#
# whenever error continue
#
# let ctc97m01.atldat = today
#
# begin work
#
#  execute p_ctc97m01_004 using  ctc97m01.cod
#                              , ctc97m01.descricao
#                              , ctc97m01.limite
#                              , ctc97m01.km
#                              , ctc97m01.atldat
#                              , g_issk.empcod
#                              , g_issk.funmat
#                              , g_issk.usrtip
#                              , ctc97m01.cod
#
#    if sqlca.sqlcode <>  0  then
#       error " Erro (",sqlca.sqlcode,") na alteracao do Plano!"
#       rollback work
#       initialize ctc97m01.*   to null
#       return ctc97m01.*
#    else
#       error " Alteracao efetuada com sucesso!"
#    end if
#
# commit work
#
# whenever error stop
#
# initialize ctc97m01.*  to null
# display by name ctc97m01.*
# message ""
# return ctc97m01.*
#
# end function   #  ctc97m01_modifica


#------------------------------------------------------------
 function ctc97m01_inclui()
#------------------------------------------------------------

define ctc97m01      record
     cod             like datkresitasrv.srvcod
   , descricao       like datkresitasrv.srvdes
   , asiplncod       like datkitaasipln.itaasiplncod
   , asiplndes       like datkitaasipln.itaasiplndes
   , atldat          like datkitaasipln.atldat
   , funnom          like isskfunc.funnom
end record


 define  ws_resp       char(01)

 define l_ret       smallint,             #PSI 205206
        l_mensagem  char(60)

 initialize ctc97m01.*   to null
 let l_ret = 0                            #PSI 205206
 let l_mensagem = null                    #PSI 205206

  if m_ctc97m01_prepare is null or
    m_ctc97m01_prepare = false then
    call ctc97m01_prepare()
 end if

 display by name ctc97m01.*

 call ctc97m01_input("i", ctc97m01.*) returning ctc97m01.*

 if int_flag  then
    let int_flag = false
    initialize ctc97m01.*  to null
    display by name ctc97m01.*
    error " Operacao cancelada!"
    return
 end if

 let ctc97m01.atldat = today

 whenever error continue

 begin work

  execute p_ctc97m01_005 using  ctc97m01.asiplncod
                              , ctc97m01.cod
                              , ctc97m01.atldat
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

 call ctc97m01_func(g_issk.funmat,
                    g_issk.empcod,
                    g_issk.usrtip)
      returning ctc97m01.funnom

 display by name  ctc97m01.*

 display by name ctc97m01.cod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize ctc97m01.*  to null
 display by name ctc97m01.*

 end function   #  ctc97m01_inclui


#--------------------------------------------------------------------
 function ctc97m01_input(param, ctc97m01)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define l_count smallint

define ctc97m01      record
     cod             like datkresitasrv.srvcod
   , descricao       like datkresitasrv.srvdes
   , asiplncod       like datkitaasipln.itaasiplncod
   , asiplndes       like datkitaasipln.itaasiplndes
   , atldat          like datkitaasipln.atldat
   , funnom          like isskfunc.funnom
end record


 define l_erro        smallint,
        l_mensagem    char(60)     #PSI 205206

 if m_ctc97m01_prepare is null or
    m_ctc97m01_prepare = false then
    call ctc97m01_prepare()
 end if

 let l_count = 0
 let l_erro = 0
 let int_flag = false
 let l_mensagem = null

 input by name ctc97m01.cod
             , ctc97m01.descricao
             , ctc97m01.asiplncod
             , ctc97m01.asiplndes
               without defaults

    before field cod
            if param.operacao  =  "a"   then
               next field  descricao
            end if
           display by name ctc97m01.cod attribute (reverse)

    after  field cod
           display by name ctc97m01.cod

           if ctc97m01.cod = " " or
              ctc97m01.cod is null then

              while true
                call cto00m10_popup(21)
                           returning ctc97m01.cod
                                   , ctc97m01.descricao

                if ctc97m01.cod is not null then
                   exit while
                else
                   error "É NECESSARIO ESCOLHER UM SERVICO !"
                end if
             end while

              # Se usuario nao digitou um valor para codigo, buscar o proximo

              display by name ctc97m01.cod
              display by name ctc97m01.descricao

              #let l_count = 0
              next field descricao
           else
              call ctc97m01_busca_servico(ctc97m01.cod)
                   returning ctc97m01.descricao
           end if

           open c_ctc97m01_006 using ctc97m01.cod
           fetch c_ctc97m01_006 into l_count

           if l_count  >  0   then
              error " Codigo de Servico já está vinculando ao plano!"
              next field cod
           end if

           let l_count = 0

    before field descricao
           display by name ctc97m01.descricao attribute (reverse)
           next field asiplncod



    before field asiplncod
           display by name ctc97m01.asiplncod attribute (reverse)

    after field asiplncod
           display by name ctc97m01.asiplncod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  descricao
           end if

            display by name ctc97m01.asiplncod

           if ctc97m01.asiplncod = " " or
              ctc97m01.asiplncod is null then

              # Se usuario nao digitou um valor para codigo, buscar o proximo
              call ctc97m01_retorna_proximo_cod()
                 returning ctc97m01.asiplncod

              display by name ctc97m01.asiplncod

              let l_count = 0
              next field descricao
           end if

           if ctc97m01.asiplncod  is null   then
              error " Codigo do Plano deve ser informado!"
              next field cod
           end if

           open c_ctc97m01_006 using ctc97m01.cod
           fetch c_ctc97m01_006 into l_count

           if l_count  >  0   then
              error " Codigo de Servico já está vinculando ao plano!"
              next field cod
           end if

           let l_count = 0

    before field asiplndes
           display by name ctc97m01.asiplndes attribute (reverse)

    after field asiplndes
           display by name ctc97m01.asiplndes

           #open c_ctc97m01_007 using ctc97m01.asiplndes
           #                        , ctc97m01.asiplncod
           #fetch c_ctc97m01_007 into l_count
           #
           #if l_count > 0 then
           #   error 'DESCRICAO JA CADASTRADA PARA OUTRO PLANO'
           #   next field descricao
           #end if

           let l_count = 0

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.operacao  =  "i"   then
                 next field  cod
              else
                 next field  descricao
              end if
           end if

           if ctc97m01.descricao  is null   then
              error " Descricao do plano deve ser informado!"
              next field descricao
           end if


    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize ctc97m01.*  to null
 end if

 return ctc97m01.*

 end function   # ctc97m01_input


#---------------------------------------------------------
 function ctc97m01_ler(param)
#---------------------------------------------------------

 define param         record
    cod         like datkresitasrv.srvcod
 end record

 define ctc97m01      record
      cod             like datkresitasrv.srvcod
    , descricao       like datkresitasrv.srvdes
    , asiplncod       like datkitaasipln.itaasiplncod
    , asiplndes       like datkitaasipln.itaasiplndes
    , atldat          like datkitaasipln.atldat
    , funnom          like isskfunc.funnom
 end record

 define ws            record
    atlmat            like isskfunc.funmat,
    atlemp            like isskfunc.empcod,
    atlusrtip         like isskfunc.usrtip,
    cont              integer
 end record

 define l_ret       smallint,
        l_mensagem  char(60)

  if m_ctc97m01_prepare is null or
    m_ctc97m01_prepare = false then
    call ctc97m01_prepare()
 end if

 initialize ctc97m01.*   to null
 initialize ws.*         to null
 let l_ret = 0
 let l_mensagem = null




 open c_ctc97m01_008 using param.cod
 fetch c_ctc97m01_008 into  ctc97m01.cod
                         ,  ctc97m01.asiplncod
                         ,  ws.atlusrtip
                         ,  ws.atlemp
                         ,  ws.atlmat
                         ,  ctc97m01.atldat

 if ctc97m01.cod is null  then
    error " Codigo de Servico nao cadastrado!"
    initialize ctc97m01.*    to null
    return ctc97m01.*
 else

    call ctc97m01_func(ws.atlmat,ws.atlemp,ws.atlusrtip)
         returning ctc97m01.funnom

    let ctc97m01.cod = param.cod
    call ctc97m01_busca_servico(ctc97m01.cod)
         returning ctc97m01.descricao



 end if

 return ctc97m01.*

 end function   # ctc97m01_ler


#---------------------------------------------------------
 function ctc97m01_func(param)
#---------------------------------------------------------

 define param         record
    funmat            like isskfunc.funmat,
    empcod            like isskfunc.empcod,
    usrtip            like isskfunc.usrtip
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record

  if m_ctc97m01_prepare is null or
    m_ctc97m01_prepare = false then
    call ctc97m01_prepare()
 end if

 initialize ws.*    to null

   if param.empcod is null or
      param.empcod = " " then
    let param.empcod = 1
   end if

   open c_ctc97m01_010 using param.funmat ,
                             param.empcod ,
                             param.usrtip
   fetch c_ctc97m01_010 into ws.funnom

 return ws.funnom

 end function   # ctc97m01_func


#---------------------------------------------------------
 function ctc97m01_retorna_proximo_cod()
#---------------------------------------------------------
   define l_retorno smallint

   whenever error continue
   open c_ctc97m01_012
   fetch c_ctc97m01_012 into l_retorno
   whenever error stop
   close c_ctc97m01_012

   return l_retorno

 end function   # ctc97m01_retorna_proximo_cod

 function ctc97m01_busca_servico(lr_param)

 define lr_param record
        srvcod like datkresitasrv.srvcod
 end record

 define l_retorno char(40)


 let l_retorno = null

 if m_ctc97m01_prepare is null or
    m_ctc97m01_prepare = false then
    call ctc97m01_prepare()
 end if


 whenever error continue
   open c_ctc97m01_015 using lr_param.srvcod
   fetch c_ctc97m01_015 into l_retorno
 whenever error stop

 return l_retorno


end function
