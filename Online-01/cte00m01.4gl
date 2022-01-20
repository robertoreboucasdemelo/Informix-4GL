##############################################################################
# Nome do Modulo: CTE00M01                                              Ruiz #
#                                                                       Akio #
# Cadastro de codigos de agrupamento                                Abr/2000 #
#########################################################################333##
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
##############################################################################
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 19/09/2003 robson            PSI175250  Incluir os campos departamento     #
#                              OSF25565   (dptsgl) e dptassagputztip na tela.#
#                                         O departamento informa que o agru- #
#                                         pamento sera de uso do departamento#
#                                         O outro campo informa que o agrupa-#
#                                         mento eh exclusivo ou bloqueado pa-#
#                                         ra o departamento. Os dois campos  #
#                                         nullos indica que o agrupamento eh #
#                                         valido para toda a Cia.            #
# ---------- ----------------- ---------- -----------------------------------#
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso   #
##############################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_erro          smallint,                         # PSI175250
        m_cte00m01_prep smallint                          # PSI175250

#------------------------#
function cte00m01_prep()                                  # PSI175250 - inicio
#------------------------#

 define l_sql_stmt  char(500)

 let l_sql_stmt = " select dptnom "
                 ,"   from isskdepto   "
                 ,"  where dptsgl = ? "

 prepare pcte00m01001 from l_sql_stmt
 declare ccte00m01001 cursor for pcte00m01001

 let l_sql_stmt = " select corassagpcod, ",
                         " corassagpdes, ",
                         " corassagpsgl, ",
                         " slccctcod, ",
                         " corasspsocod, ",
                         " dptsgl, ",
                         " dptassagputztip, ",
                         " corassagpstt, ",
                         " caddat, ",
                         " cadmat, ",
                         " atldat, ",
                         " atlmat ",
                    " from dackassagp ",
                  " where corassagpcod = ? "

 prepare pcte00m01002 from l_sql_stmt
 declare ccte00m01002 cursor for pcte00m01002

 let l_sql_stmt = ' update dackassagp ',
                  '    set corassagpdes    = ?, ',
                  '        corassagpsgl    = ?, ',
                  '        slccctcod       = ?, ',
                  '        corasspsocod    = ?, ',
                  '        dptsgl          = ?, ',
                  '        dptassagputztip = ?, ',
                  '        corassagpstt    = ?, ',
                  '        atldat          = ?, ',
                  '        atlmat          = ? ',
                  '  where corassagpcod    = ? '
 
 prepare pcte00m01003 from l_sql_stmt

 let l_sql_stmt = ' insert into dackassagp (corassagpcod, corassagpdes, ',
                  '  corassagpsgl, slccctcod, corasspsocod, dptsgl, ',
                  '  dptassagputztip, corassagpstt, caddat, cademp, ',
                  '  cadmat, atldat, atlemp, atlmat ) ',
                  '  values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ) '

 prepare pcte00m01004 from l_sql_stmt

 let l_sql_stmt = " select funnom ",
                  "   from isskfunc ",
                  "  where isskfunc.funmat = ? "
                  
 prepare pcte00m01005 from l_sql_stmt
 declare ccte00m01005 cursor for pcte00m01005

 let m_cte00m01_prep = true

end function                                              # PSI175250 - fim

#------------------------------------------------------------
 function cte00m01()
#------------------------------------------------------------

 define cte00m01      record
    corassagpcod      like dackassagp.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    corassagpsgl      like dackassagp.corassagpsgl,
    slccctcod         like dackassagp.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackassagp.corasspsocod,
    dptsgl            like dackassagp.dptsgl,                   # PSI175250
    dptnom            like isskdepto.dptnom,                    # PSI175250
    dptassagputztip   like dackassagp.dptassagputztip,          # PSI175250
    status            char(09),                                 # PSI175250
    corassagpstt      like dackassagp.corassagpstt,
    caddat            like dackassagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackassagp.atldat,
    funnom            like isskfunc.funnom
 end record

 define param record
    corassagpcod      like dackassagp.corassagpcod
 end record

 if m_cte00m01_prep is null or
    m_cte00m01_prep <> true then
    call cte00m01_prep()
 end if

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "cte00m01") then
 #   error "Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 let int_flag = false

 initialize cte00m01.*  to null

 open window cte00m01 at 04,02 with form "cte00m01"


 menu "AGRUPAMENTOS"

  before menu
          clear form
          hide option all
          show option all
          #PSI 202290
          #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
          #      show option "Seleciona", "Proximo", "Anterior"
          #end if
          #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica" , "Inclui"
          #end if
          show option "Encerra"

  command key ("S") "Seleciona"
                   "Pesquisa agrupamento conforme criterios"
          call cte00m01_seleciona()  returning param.*
          if param.corassagpcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum agrupamento selecionado!"
             message ""
             next option "Seleciona"
          end if

  command key ("P") "Proximo"
                   "Mostra proximo agrupamento selecionado"
          message ""
          call cte00m01_proximo(param.corassagpcod)
               returning param.*

  command key ("A") "Anterior"
                   "Mostra agrupamento anterior selecionado"
          message ""
          if param.corassagpcod is not null then
             call cte00m01_anterior(param.corassagpcod)
                  returning param.*
          else
             error " Nenhum agrupamento nesta direcao!"
             next option "Seleciona"
          end if

  command key ("M") "Modifica"
                   "Modifica agrupamento corrente selecionado"
          message ""
          if param.corassagpcod  is not null then
             call cte00m01_modifica(param.*)
                  returning param.*
             next option "Seleciona"
          else
             error " Nenhum agrupamento selecionado!"
             next option "Seleciona"
          end if

  command key ("I") "Inclui"
                   "Inclui agrupamento"
          message ""
          call cte00m01_inclui()
          next option "Seleciona"

  command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window cte00m01

 end function  # cte00m01


#------------------------------------------------------------
 function cte00m01_seleciona()
#------------------------------------------------------------

 define cte00m01      record
    corassagpcod      like dackassagp.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    corassagpsgl      like dackassagp.corassagpsgl,
    slccctcod         like dackassagp.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackassagp.corasspsocod,
    dptsgl            like dackassagp.dptsgl,                   # PSI175250
    dptnom            like isskdepto.dptnom,                    # PSI175250
    dptassagputztip   like dackassagp.dptassagputztip,          # PSI175250
    status            char(09),                                 # PSI175250
    corassagpstt      like dackassagp.corassagpstt,
    caddat            like dackassagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackassagp.atldat,
    funnom            like isskfunc.funnom
 end record

 define param         record
    corassagpcod      like dackassagp.corassagpcod
 end record

 let int_flag = false
 initialize cte00m01.*  to null
 initialize param.*     to null
 display by name cte00m01.*

 input by name cte00m01.corassagpcod

    before field corassagpcod
        display by name cte00m01.corassagpcod attribute (reverse)

    after  field corassagpcod
        display by name cte00m01.corassagpcod

        if cte00m01.corassagpcod is null   then
           call cto00m03() returning cte00m01.corassagpcod,
                                     cte00m01.corassagpdes
           if cte00m01.corassagpcod is null  then
              error " Codigo do Agrupamento deve ser informado!"
              next field corassagpcod
           end if
        end if
        display by name cte00m01.corassagpcod
        display by name cte00m01.corassagpdes

        select corassagpcod
            from dackassagp
            where corassagpcod = cte00m01.corassagpcod

           if sqlca.sqlcode  =  notfound then
              error " Codigo do agrupamento nao cadastrado!"
              next field corassagpcod
           end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize cte00m01.*   to null
    display by name cte00m01.*
    error " Operacao cancelada!"
    return param.*
 end if

 call cte00m01_ler(cte00m01.corassagpcod)
      returning cte00m01.*

 if cte00m01.corassagpcod  is not null   then
    display by name  cte00m01.*
 else
    error " agrupamento nao cadastrado!"
    initialize cte00m01.*    to null
 end if

 let param.corassagpcod = cte00m01.corassagpcod
 return param.*

 end function  # cte00m01_seleciona


#------------------------------------------------------------
 function cte00m01_proximo(param)
#------------------------------------------------------------

 define param         record
    corassagpcod         like dackassagp.corassagpcod
 end record

 define cte00m01      record
    corassagpcod      like dackassagp.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    corassagpsgl      like dackassagp.corassagpsgl,
    slccctcod         like dackassagp.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackassagp.corasspsocod,
    dptsgl            like dackassagp.dptsgl,                   # PSI175250
    dptnom            like isskdepto.dptnom,                    # PSI175250
    dptassagputztip   like dackassagp.dptassagputztip,          # PSI175250
    status            char(09),                                 # PSI175250
    corassagpstt      like dackassagp.corassagpstt,
    caddat            like dackassagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackassagp.atldat,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false
#initialize cte00m01.*   to null

#if param.corassagpcod  is null  then
#   let param.corassagpcod = " "
#end if

 select min(dackassagp.corassagpcod)
   into cte00m01.corassagpcod
   from dackassagp
  where dackassagp.corassagpcod > param.corassagpcod

 if cte00m01.corassagpcod  is not null   then
    let param.corassagpcod = cte00m01.corassagpcod
    call cte00m01_ler(cte00m01.corassagpcod)
         returning cte00m01.*

    if cte00m01.corassagpcod  is not null   then
       display by name  cte00m01.*
    else
       error " Nao ha' agrupamento nesta direcao!"
      #initialize cte00m01.*    to null
    end if
 else
    error " Nao ha' agrupamento nesta direcao!"
    initialize cte00m01.*    to null
 end if

 return param.*

 end function    # cte00m01_proximo


#------------------------------------------------------------
 function cte00m01_anterior(param)
#------------------------------------------------------------

 define param         record
    corassagpcod      like dackassagp.corassagpcod
 end record

 define cte00m01      record
    corassagpcod      like dackassagp.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    corassagpsgl      like dackassagp.corassagpsgl,
    slccctcod         like dackassagp.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackassagp.corasspsocod,
    dptsgl            like dackassagp.dptsgl,                   # PSI175250
    dptnom            like isskdepto.dptnom,                    # PSI175250
    dptassagputztip   like dackassagp.dptassagputztip,          # PSI175250
    status            char(09),                                 # PSI175250
    corassagpstt      like dackassagp.corassagpstt,
    caddat            like dackassagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackassagp.atldat,
    funnom            like isskfunc.funnom
 end record

 let int_flag = false
#initialize cte00m01.*  to null

#if param.corassagpcod  is null  then
#   let param.corassagpcod = " "
#end if

 select max(dackassagp.corassagpcod)
   into cte00m01.corassagpcod
   from dackassagp
  where dackassagp.corassagpcod     < param.corassagpcod

 if cte00m01.corassagpcod  is not null   then
    let param.corassagpcod = cte00m01.corassagpcod
    call cte00m01_ler(cte00m01.corassagpcod)
         returning cte00m01.*

    if cte00m01.corassagpcod  is not null   then
       display by name  cte00m01.*
    else
       error " Nao ha' agrupamento nesta direcao!"
#      initialize cte00m01.*    to null
    end if
 else
    error " Nao ha' agrupamento nesta direcao!"
#   initialize cte00m01.*    to null
 end if

 return param.*

 end function    # cte00m01_anterior

#------------------------------------------------------------
 function cte00m01_modifica(param)
#------------------------------------------------------------

 define param         record
    corassagpcod         like dackassagp.corassagpcod
 end record

 define cte00m01      record
    corassagpcod      like dackassagp.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    corassagpsgl      like dackassagp.corassagpsgl,
    slccctcod         like dackassagp.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackassagp.corasspsocod,
    dptsgl            like dackassagp.dptsgl,                   # PSI175250
    dptnom            like isskdepto.dptnom,                    # PSI175250
    dptassagputztip   like dackassagp.dptassagputztip,          # PSI175250
    status            char(09),                                 # PSI175250
    corassagpstt      like dackassagp.corassagpstt,
    caddat            like dackassagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackassagp.atldat,
    funnom            like isskfunc.funnom
 end record

 call cte00m01_ler(param.corassagpcod)
       returning cte00m01.*
 if cte00m01.corassagpcod  is null then
    error " Registro nao Localizado "
    return param.*
 end if

 call cte00m01_input("a", param.*, cte00m01.*)
         returning param.*, cte00m01.*

 if m_erro = true then     # PSI175250 - inicio
    let int_flag = false
    initialize param to null
    return param.*
 end if                    # PSI175250 - fim

 if int_flag  then
    let int_flag = false
    initialize cte00m01.*  to null
    display by name  cte00m01.*
    error " Operacao cancelada!"
    return param.*
 end if

 let cte00m01.atldat = today

 begin work
    whenever error continue
       execute pcte00m01003 using cte00m01.corassagpdes,
                                  cte00m01.corassagpsgl,
                                  cte00m01.slccctcod,
                                  cte00m01.corasspsocod,
                                  cte00m01.dptsgl,
                                  cte00m01.dptassagputztip,
                                  cte00m01.corassagpstt,
                                  cte00m01.atldat,
                                  g_issk.funmat,
                                  param.corassagpcod
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode < 0 then
          error 'Erro Sql pcte00m01003: ' , sqlca.sqlcode, " | ",sqlca.sqlerrd[2]
       else
          error " Erro (",sqlca.sqlcode,") na alteracao do agrupamento!"
       end if
       rollback work
       initialize cte00m01.*   to null
       initialize param.*      to null
       return param.*
    end if
    error " Alteracao efetuada com sucesso! "
 commit work

 initialize cte00m01.*  to null
 display by name  cte00m01.*
 message ""
 return param.*

 end function   #  cte00m01_modifica


#------------------------------------------------------------
 function cte00m01_inclui()
#------------------------------------------------------------

 define cte00m01      record
    corassagpcod      like dackassagp.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    corassagpsgl      like dackassagp.corassagpsgl,
    slccctcod         like dackassagp.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackassagp.corasspsocod,
    dptsgl            like dackassagp.dptsgl,                   # PSI175250
    dptnom            like isskdepto.dptnom,                    # PSI175250
    dptassagputztip   like dackassagp.dptassagputztip,          # PSI175250
    status            char(09),                                 # PSI175250
    corassagpstt      like dackassagp.corassagpstt,
    caddat            like dackassagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackassagp.atldat,
    funnom            like isskfunc.funnom
 end record

 define param         record
    corassagpcod      like dackassagp.corassagpcod
 end record

 define  ws_resp       char(01)

 initialize cte00m01.*, param.*    to null

 display by name  cte00m01.*

 call cte00m01_input("i", param.*,  cte00m01.*)
               returning param.*,  cte00m01.*

 if m_erro = true then     # PSI175250
    return                 # PSI175250
 end if                    # PSI175250

 if int_flag  then
    let int_flag = false
    initialize cte00m01.*  to null
    display by name  cte00m01.*
    error " Operacao cancelada!"
    return
 end if

 let cte00m01.atldat = today
 let cte00m01.caddat = today


 whenever error continue
 begin work
    execute pcte00m01004 using cte00m01.corassagpcod,
                               cte00m01.corassagpdes,
                               cte00m01.corassagpsgl,
                               cte00m01.slccctcod,
                               cte00m01.corasspsocod,
                               cte00m01.dptsgl,
                               cte00m01.dptassagputztip,
                               cte00m01.corassagpstt,
                               cte00m01.caddat,
                               g_issk.empcod,
                               g_issk.funmat,
                               cte00m01.atldat,
                               g_issk.empcod,
                               g_issk.funmat 
    if sqlca.sqlcode <> 0 then 
       if sqlca.sqlcode < 0 then 
          error 'Erro Sql pcte00m01004: ' , sqlca.sqlcode, " | ",sqlca.sqlerrd[2]
       else
          error " Erro (",sqlca.sqlcode,") na Inclusao do agrupamento! "
       end if
       rollback work
       return
    end if
 commit work
 whenever error stop

 call cte00m01_func(g_issk.funmat)
      returning cte00m01.cadfunnom

 call cte00m01_func(g_issk.funmat)
      returning cte00m01.funnom

 display by name  cte00m01.*

 display by name cte00m01.corassagpcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize cte00m01.*  to null
 display by name cte00m01.*

 end function   #  cte00m01_inclui


#--------------------------------------------------------------------
 function cte00m01_input( ws_operacao, param, cte00m01)
#--------------------------------------------------------------------

 define ws_operacao   char (1)

 define param         record
    corassagpcod      like dackassagp.corassagpcod
 end record

 define cte00m01      record
    corassagpcod      like dackassagp.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    corassagpsgl      like dackassagp.corassagpsgl,
    slccctcod         like dackassagp.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackassagp.corasspsocod,
    dptsgl            like dackassagp.dptsgl,                   # PSI175250
    dptnom            like isskdepto.dptnom,                    # PSI175250
    dptassagputztip   like dackassagp.dptassagputztip,          # PSI175250
    status            char(09),                                 # PSI175250
    corassagpstt      like dackassagp.corassagpstt,
    caddat            like dackassagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackassagp.atldat,
    funnom            like isskfunc.funnom
 end record

 define l_par_pop record                                  # PSI175250 - inicio
           lin       smallint 
          ,col       smallint 
          ,title     char(54) 
          ,coltit_1  char(10) 
          ,coltit_2  char(10) 
          ,tipcod    char(01) 
          ,com_sql   char(1000) 
          ,compl_sql char(200) 
          ,tipo      char(01)
        end record

 define l_achou  smallint                                 # PSI175250 - fim

 define ws            record
    cont              integer
 end record

 let int_flag = false
 let ws.cont  = 0
 let m_erro = false                                       # PSI175250

 if ws_operacao    = "i"  then
    select max(corassagpcod)
         into ws.cont
         from dackassagp
    if  ws.cont  is null then
        let ws.cont =  1
    else
        let ws.cont = ws.cont + 1
    end if
 end if
 
 input by name
               cte00m01.corassagpcod,
               cte00m01.corassagpdes,
               cte00m01.corassagpsgl,
               cte00m01.slccctcod,
               cte00m01.corasspsocod,
               cte00m01.dptsgl,                           # PSI175250
               cte00m01.dptassagputztip,                  # PSI175250
               cte00m01.corassagpstt  without defaults

    before field corassagpcod
            if ws_operacao  =  "a"   then
               next field  corassagpdes
            end if
            let cte00m01.corassagpcod = ws.cont
            display by name cte00m01.corassagpcod # attribute (reverse)
            next field  corassagpdes

    after  field corassagpcod
           display by name cte00m01.corassagpcod

           if cte00m01.corassagpcod  is null   then
              error " Codigo do agrupamento deve ser informado!"
              next field corassagpcod
           end if

           select corassagpcod
             from dackassagp
            where corassagpcod = cte00m01.corassagpcod

           if sqlca.sqlcode  =  0   then
              error " Codigo do agrupamento ja' cadastrado!"
              next field corassagpcod
           end if

    before field corassagpdes
           display by name cte00m01.corassagpdes #attribute (reverse)

    after  field corassagpdes
           display by name cte00m01.corassagpdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if ws_operacao  =  "i"   then
                 next field  corassagpcod
              else
                 next field  corassagpdes
              end if
           end if

           if cte00m01.corassagpdes  is null   then
              error " Descricao do agrupamento deve ser informado!"
              next field corassagpdes
           end if

       before field corassagpsgl
          display by name cte00m01.corassagpsgl # attribute(reverse)

       after  field corassagpsgl
          display by name cte00m01.corassagpsgl

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field corassagpdes
          end if
          if cte00m01.corassagpsgl is null then
             error " Sigla deve ser informada !"
             next field corassagpsgl
          end if

       before field slccctcod
          display by name cte00m01.slccctcod  attribute (reverse)

       after  field slccctcod
          display by name cte00m01.slccctcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field corassagpsgl
          end if                                                                
                                                                                
          if cte00m01.slccctcod is not null  then
             select ctokcentrosuc.cctnom
               into cte00m01.cctnom
               from ctokcentrosuc
              where empcod = 1
                and succod = 1
                and cctcod = cte00m01.slccctcod

             if sqlca.sqlcode <> 0 then
                error " Centro de custo nao existe!"
                next field slccctcod
             end if
          end if

          display by name cte00m01.cctnom

       before field corasspsocod
          display by name cte00m01.corasspsocod attribute(reverse)

       after  field corasspsocod
          display by name cte00m01.corasspsocod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field slccctcod
          end if

       before field dptsgl                                    # PSI175250 - inicio
          display by name cte00m01.dptsgl attribute(reverse)

       after  field dptsgl
          display by name cte00m01.dptsgl

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field corasspsocod
          end if

          call cte00m01_verifica_depto(cte00m01.dptsgl)
               returning cte00m01.dptnom

          if m_erro = true then
             let int_flag = true
             exit input
          end if
          
          if cte00m01.dptsgl is not null then
             if cte00m01.dptnom is null then
                error " Departamento nao existe "  sleep 2
                let cte00m01.dptsgl = null
             end if
          end if

          if cte00m01.dptsgl is null then
             let l_par_pop.lin      = 6
             let l_par_pop.col      = 2
             let l_par_pop.title    = 'Departamento'
             let l_par_pop.coltit_1 = ' '
             let l_par_pop.coltit_2 = ' '
             let l_par_pop.tipcod   = 'A'
             let l_par_pop.tipo     = 'E'
             let l_par_pop.com_sql  = ' select dptsgl, dptnom ',
                                       ' from isskdepto ',
                                       'where dptnom '

             let l_par_pop.compl_sql =   ' order by dptnom '
             
             call ofgrc001_popup(l_par_pop.*) returning l_achou, # 0- selecionou; 1- nenhum registro selecionado; <0- Erro sql
                                                        cte00m01.dptsgl,
                                                        cte00m01.dptnom

             if l_achou < 0 then
                error " Erro de acesso a base de dados tabela isskdepto ", sqlca.sqlcode, " | ",sqlca.sqlerrd[2] sleep 2
                let int_flag = true
                exit input
             end if
             if l_achou = 1 then
                display by name cte00m01.dptsgl
                display by name cte00m01.dptnom 
                next field corassagpstt
             end if
          end if

          display by name cte00m01.dptsgl                 # PSI175250 - fim.
          display by name cte00m01.dptnom                 # PSI175250 - fim.
          
       before field dptassagputztip
          display by name cte00m01.dptassagputztip attribute(reverse)

       after  field dptassagputztip
          display by name cte00m01.dptassagputztip

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field dptsgl
          end if
          if cte00m01.dptassagputztip = "E" then
             let cte00m01.status = "Exclusivo"
          else
             if cte00m01.dptassagputztip = "B" then
                let cte00m01.status = "Bloqueado"
             else
                if cte00m01.dptassagputztip <> "E" or
                   cte00m01.dptassagputztip <> "B" or
                   cte00m01.dptassagputztip is not null then
                   error 'Preenchimento incorreto'
                   next field dptassagputztip
                else
                   let cte00m01.status = null
                end if
             end if
          end if
          display by name cte00m01.status

    before field corassagpstt
           if ws_operacao  =  "i"   then
              let cte00m01.corassagpstt = "A"
           end if
           display  by name cte00m01.corassagpstt # attribute (reverse)

    after  field corassagpstt
           display by name cte00m01.corassagpstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if  cte00m01.dptsgl is null then
                  next field dptsgl
              else
                  next field dptassagputztip
              end if
           end if

           if cte00m01.corassagpstt  is null   or
             (cte00m01.corassagpstt  <> "A"    and
              cte00m01.corassagpstt  <> "C")   then
              error " Situacao agrupamento deve ser: (A)tivo ou (C)ancelado!"
              next field corassagpstt
           end if

           if ws_operacao         = "i"   and
              cte00m01.corassagpstt  = "C"   then
              error " Nao deve ser incluido agrupamento com situacao (C)ancelado!"
              next field corassagpstt
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize param.*, cte00m01.*  to null
 end if

 return param.*, cte00m01.*

 end function   # cte00m01_input

#------------------------------------------#
 function cte00m01_verifica_depto(l_dptsgl)               # PSI175250 - inicio
#------------------------------------------#
 define l_dptsgl like dackassagp.dptsgl,
        l_dptnom like isskdepto.dptnom

 let l_dptnom = null
 whenever error continue
    open ccte00m01001 using l_dptsgl

    fetch ccte00m01001 into l_dptnom
 whenever error stop 
 if sqlca.sqlcode <> 0 then 
    if sqlca.sqlcode < 0 then {Erro de acesso a base}
       error " Erro de acesso a base de dados tabela isskdepto ", sqlca.sqlcode, " | ",sqlca.sqlerrd[2] sleep 2
       let m_erro = true
    end if
 end if
 return l_dptnom
 end function                                             # PSI175250 - fim

#---------------------------------------------------------
 function cte00m01_ler(param)
#---------------------------------------------------------

 define param         record
    corassagpcod         like dackassagp.corassagpcod
 end record

 define cte00m01      record
    corassagpcod      like dackassagp.corassagpcod,
    corassagpdes      like dackassagp.corassagpdes,
    corassagpsgl      like dackassagp.corassagpsgl,
    slccctcod         like dackassagp.slccctcod,
    cctnom            like ctokcentrosuc.cctnom,
    corasspsocod      like dackassagp.corasspsocod,
    dptsgl            like dackassagp.dptsgl,                   # PSI175250
    dptnom            like isskdepto.dptnom,                    # PSI175250
    dptassagputztip   like dackassagp.dptassagputztip,          # PSI175250
    status            char(09),                                 # PSI175250
    corassagpstt      like dackassagp.corassagpstt,
    caddat            like dackassagp.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like dackassagp.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlmat            like isskfunc.funmat,
    cadmat            like isskfunc.funmat,
    corassagpcod      like dackassagp.corassagpcod
 end record

 initialize cte00m01.*   to null
 initialize ws.*         to null

 whenever error continue
    open ccte00m01002 using param.corassagpcod
 
    fetch ccte00m01002 into cte00m01.corassagpcod,
                            cte00m01.corassagpdes,
                            cte00m01.corassagpsgl,
                            cte00m01.slccctcod,
                            cte00m01.corasspsocod,
                            cte00m01.dptsgl,
                            cte00m01.dptassagputztip,
                            cte00m01.corassagpstt,
                            cte00m01.caddat,
                            ws.cadmat,
                            cte00m01.atldat,
                            ws.atlmat

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode < 0 then {Erro de acesso a base}
       error " Erro de acesso a base de dados tabela dackassagp ", sqlca.sqlcode, " | ",sqlca.sqlerrd[2] sleep 2
    else
       error " Codigo de agrupamento nao cadastrado! " sleep 2
    end if
    initialize cte00m01.*    to null
    return cte00m01.*
 end if

 call cte00m01_func(ws.cadmat)
      returning cte00m01.cadfunnom

 call cte00m01_func(ws.atlmat)
      returning cte00m01.funnom

 select ctokcentrosuc.cctnom       
   into cte00m01.cctnom            
   from ctokcentrosuc              
  where empcod = 1                 
    and succod = 1                 
    and cctcod = cte00m01.slccctcod

## PSI 175250 - Inicio

 if cte00m01.dptsgl is not null then
    call cte00m01_verifica_depto(cte00m01.dptsgl)
         returning cte00m01.dptnom
 end if

## PSI 175250 - Final

 return cte00m01.*

 end function   # cte00m01_ler


#---------------------------------------------------------
 function cte00m01_func(param)
#---------------------------------------------------------

   define param         record
      funmat            like isskfunc.funmat
   end record

   define ws            record
      funnom            like isskfunc.funnom
   end record

   initialize ws.*    to null

   whenever error continue
   open ccte00m01005 using param.funmat
   fetch ccte00m01005 into ws.funnom
   whenever error stop 
   if sqlca.sqlcode <> 0 then 
      if sqlca.sqlcode <> notfound then 
         error " Erro de acesso a base de dados tabela isskfunc ", sqlca.sqlcode, " | ",sqlca.sqlerrd[2] sleep 2
         let m_erro = true
      end if
   end if

   return ws.funnom

 end function   # cte00m01_func
