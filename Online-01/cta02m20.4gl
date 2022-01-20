#--------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                          #
# .........................................................................#
# Sistema       : CENTRAL 24H                                              #
# Modulo        : cta02m20                                                 #
# Analista Resp.: Marcio Candido                                           #
# PSI           : 172081                                                   #
# OSF           : 028240                                                   #
#                 Controle de atendimentos simultaneos                     #
#..........................................................................#
# Desenvolvimento: Robson, META                                            #
# Liberacao      : 04/11/2003                                              #
#..........................................................................#
#                                                                          #
#                  * * * Alteracoes * * *                                  #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ------------------------------------#
# 06/03/2006  Priscila       Zeladoria Buscar data e hora do banco de dados#
#--------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_succod         like datmatdlig.succod,
        m_ramcod         like datmatdlig.ramcod,
        m_aplnumdig      like datmatdlig.aplnumdig,
        m_itmnumdig      like datmatdlig.itmnumdig,
        m_prporg         like datmatdlig.prporg,
        m_prpnumdig      like datmatdlig.prpnumdig

 define m_cta02m20_prep  smallint,
        m_chamada        smallint,
        m_erro           smallint

 define mr_datmatdlig record like datmatdlig.*

#------------------------#
 function cta02m20_prep()
#------------------------#
 define l_sql_stmt  char(800)

 let l_sql_stmt = ' select * ',
                    ' from datmatdlig ',
                   ' where succod    = ? ',
                     ' and ramcod    = ? ',
                     ' and aplnumdig = ? ',
                     ' and itmnumdig = ? '

 prepare p_cta02m20_001 from l_sql_stmt
 declare c_cta02m20_001 cursor with hold for p_cta02m20_001

 let l_sql_stmt = ' select * ',
                    ' from datmatdlig ',
                   ' where prporg    = ? ',
                     ' and prpnumdig = ? '

 prepare p_cta02m20_002 from l_sql_stmt
 declare c_cta02m20_002 cursor with hold for p_cta02m20_002

 let l_sql_stmt = ' select funnom ',
                    ' from isskfunc ',
                   ' where funmat = ? ',
                     ' and empcod = ? ',
                     ' and usrtip = ? '

 prepare p_cta02m20_003 from l_sql_stmt
 declare c_cta02m20_003 cursor for p_cta02m20_003

 let l_sql_stmt = ' insert into datmatdlig (atdmat, atdempcod, atdusrtip, c24paxnum, succod, ',
                  ' ramcod, aplnumdig, itmnumdig, prporg, prpnumdig, c24solnom, c24astcod, ',
                  ' atldat, atlhor) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
 prepare pcta02m20004 from l_sql_stmt

 let l_sql_stmt = ' delete from datmatdlig ',
                   ' where succod    = ? ',
                     ' and ramcod    = ? ',
                     ' and aplnumdig = ? ',
                     ' and itmnumdig = ? '

 prepare pcta02m20005 from l_sql_stmt

 let l_sql_stmt = ' delete from datmatdlig ',
                   ' where prporg      = ? ',
                     ' and prpnumdig   = ? '

 prepare pcta02m20006 from l_sql_stmt

 let l_sql_stmt = ' update datmatdlig set c24astcod = ? ',
                   ' where atdmat    = ? ',
                     ' and atdempcod = ? ',
                     ' and atdusrtip = ? ',
                     ' and c24paxnum = ? '

 prepare pcta02m20007 from l_sql_stmt

 let l_sql_stmt = ' delete from datmatdlig ',
                   ' where atdmat    = ? ',
                     ' and atdempcod = ? ',
                     ' and atdusrtip = ? ',
                     ' and c24paxnum = ? '

 prepare pcta02m20008 from l_sql_stmt

 let m_cta02m20_prep = true

 end function

#funcao chamada pelo cta01m00 e cta02m00#
#--------------------------------------------------------------------------------------#
 function cta02m20(l_succod, l_ramcod, l_aplnumdig, l_itmnumdig, l_prporg, l_prpnumdig)
#--------------------------------------------------------------------------------------#
 define l_succod         like datmatdlig.succod,
        l_ramcod         like datmatdlig.ramcod,
        l_aplnumdig      like datmatdlig.aplnumdig,
        l_itmnumdig      like datmatdlig.itmnumdig,
        l_prporg         like datmatdlig.prporg,
        l_prpnumdig      like datmatdlig.prpnumdig

 initialize m_chamada        to null
 initialize mr_datmatdlig to null

 let m_erro = false

 let m_succod    = l_succod
 let m_ramcod    = l_ramcod
 let m_aplnumdig = l_aplnumdig
 let m_itmnumdig = l_itmnumdig
 let m_prporg    = l_prporg
 let m_prpnumdig = l_prpnumdig

 if m_cta02m20_prep is null or
    m_cta02m20_prep <> true then
    call cta02m20_prep()
 end if
 let m_chamada = 0

 if m_succod    is not null and
    m_ramcod    is not null and
    m_aplnumdig is not null and
    m_itmnumdig is not null then
    let m_chamada = 1
 else
    if m_prporg    is not null and
       m_prpnumdig is not null then
       let m_chamada = 2
    end if
 end if

 if m_chamada > 0 then
    call cta02m20_busca_datmatdlig()
 end if

 end function

#---------------------------------------#
 function cta02m20_busca_datmatdlig()
#---------------------------------------#
 define l_achou       smallint

 define l_hora        datetime hour to second,
        l_dif         char(10),
        l_constante   datetime hour to second,
        l_diferenca   datetime hour to second

 define lr_alerta     record
        atdmat        like datmatdlig.atdmat,
        atdempcod     like datmatdlig.atdempcod,
        atdusrtip     like datmatdlig.atdusrtip,
        c24paxnum     like datmatdlig.c24paxnum,
        c24solnom     like datmatdlig.c24solnom,
        c24astcod     like datmatdlig.c24astcod
 end record

 define l_data       date

 let l_achou = false

 if m_chamada = 1 then
    open c_cta02m20_001 using m_succod,
                            m_ramcod,
                            m_aplnumdig,
                            m_itmnumdig
    whenever error continue
    fetch c_cta02m20_001 into mr_datmatdlig.*
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> notfound then
          error " Erro Cursor c_cta02m20_001 ", sqlca.sqlcode, " / ",sqlca.sqlerrd[2] sleep 2
          error "cta02m20/cta02m20_busca_datmatdlig/",m_succod, " ",m_ramcod, " ",
                                              m_aplnumdig, " ", m_itmnumdig
          let m_erro = true
          return
       end if
    else
       let l_achou = true
    end if
 else
    open c_cta02m20_002 using m_prporg,
                            m_prpnumdig
    whenever error continue
    fetch c_cta02m20_002 into mr_datmatdlig.*
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> notfound then
          error " Erro Cursor c_cta02m20_002 ", sqlca.sqlcode, " / ",sqlca.sqlerrd[2] sleep 2
          error "cta02m20/cta02m20_busca_datmatdlig/",m_prporg, " ",m_prpnumdig
          let m_erro = true
          return
       end if
    else
       let l_achou = true
    end if
 end if
 if l_achou then
    if mr_datmatdlig.atdmat    = g_issk.funmat and
       mr_datmatdlig.atdempcod = g_issk.empcod and
       mr_datmatdlig.atdusrtip = g_issk.usrtip and
       mr_datmatdlig.c24paxnum = g_c24paxnum then
       call cta02m20_excluir_atendimento()
       if m_erro = true then
          return
       end if
       call cta02m20_inclui_atendimento()
    else
       initialize  lr_alerta  to null
       let lr_alerta.atdmat    = mr_datmatdlig.atdmat
       let lr_alerta.atdempcod = mr_datmatdlig.atdempcod
       let lr_alerta.atdusrtip = mr_datmatdlig.atdusrtip
       let lr_alerta.c24paxnum = mr_datmatdlig.c24paxnum
       let lr_alerta.c24solnom = mr_datmatdlig.c24solnom
       let lr_alerta.c24astcod = mr_datmatdlig.c24astcod
       let l_constante = '01:00:00'
       call cts40g03_data_hora_banco(1)
            returning l_data, l_hora
       let l_dif  = l_hora - mr_datmatdlig.atlhor
       let l_diferenca = l_dif
       if l_diferenca > l_constante then
          call cta02m20_excluir_atendimento()
          if m_erro = true then
             return
          end if
          call cta02m20_inclui_atendimento()
       else
          call cta02m20_inclui_atendimento()
          if m_erro = true then
             return
          end if
          call cta02m20_exibe_alerta(lr_alerta.*)
       end if
    end if
 else
    call cta02m20_inclui_atendimento()
 end if
 end function

#---------------------------------------#
 function cta02m20_exibe_alerta(lr_parm)
#---------------------------------------#

 define l_cabtip char(01),  ###  Tipo do Cabecalho
        l_conflg char(01),  ###  Flag Confirmacao
        l_linha  char(40),
        l_linha1 char(40),
        l_linha2 char(40),
        l_linha3 char(40),
        l_nom_atendente char(20),
        l_confirma char(01)
 define lr_parm       record
        atdmat        like datmatdlig.atdmat,
        atdempcod     like datmatdlig.atdempcod,
        atdusrtip     like datmatdlig.atdusrtip,
        c24paxnum     like datmatdlig.c24paxnum,
        c24solnom     like datmatdlig.c24solnom,
        c24astcod     like datmatdlig.c24astcod
 end record

 let l_nom_atendente = cta02m20_verifica_isskfunc(lr_parm.atdempcod,
                                                  lr_parm.atdmat,
                                                  lr_parm.atdusrtip)
 let l_cabtip = 'A'
 let l_conflg = 'N'
 let l_linha  = 'Documento sendo consultado por: '
 let l_linha1 = lr_parm.atdmat, ' ', l_nom_atendente, ' PA - ', lr_parm.c24paxnum
 let l_linha2 = 'SOLICITANTE: ', lr_parm.c24solnom
 let l_linha3 = 'Assunto: ', lr_parm.c24astcod

 call cts08g01(l_cabtip, l_conflg, l_linha, l_linha1, l_linha2, l_linha3)
      returning l_confirma

 end function

#---------------------------------------#
 function cta02m20_inclui_atendimento()
#---------------------------------------#
 define l_data date,
        l_hora datetime hour to second

 call cta02m20_remover_atendimento()

 let mr_datmatdlig.atdmat     = g_issk.funmat
 let mr_datmatdlig.atdempcod  = g_issk.empcod
 let mr_datmatdlig.atdusrtip  = g_issk.usrtip
 let mr_datmatdlig.c24paxnum  = g_c24paxnum
 let mr_datmatdlig.succod     = g_documento.succod
 let mr_datmatdlig.ramcod     = g_documento.ramcod
 let mr_datmatdlig.aplnumdig  = g_documento.aplnumdig
 let mr_datmatdlig.itmnumdig  = g_documento.itmnumdig
 let mr_datmatdlig.prporg     = g_documento.prporg
 let mr_datmatdlig.prpnumdig  = g_documento.prpnumdig
 let mr_datmatdlig.c24solnom  = g_documento.solnom

 if m_chamada = 1 then
    let mr_datmatdlig.c24astcod = null
    let mr_datmatdlig.succod    = m_succod
    let mr_datmatdlig.ramcod    = m_ramcod
    let mr_datmatdlig.aplnumdig = m_aplnumdig
    let mr_datmatdlig.itmnumdig = m_itmnumdig
 else
    let mr_datmatdlig.c24astcod = g_documento.c24astcod
    let mr_datmatdlig.prporg    = m_prporg
    let mr_datmatdlig.prpnumdig = m_prpnumdig
 end if

 call cts40g03_data_hora_banco(1)
      returning l_data, l_hora
 let mr_datmatdlig.atldat = l_data
 let mr_datmatdlig.atlhor = l_hora

 begin work
 whenever error continue
 execute pcta02m20004 using mr_datmatdlig.*
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error " Erro INSERT datmatdlig ", sqlca.sqlcode, " / ",sqlca.sqlerrd[2] sleep 2
    error "cta02m20/cta02m20_inclui_atendimento/",mr_datmatdlig.atdmat, " ",
                                                  mr_datmatdlig.atdempcod, " ",
                                                  mr_datmatdlig.atdusrtip, " ",
                                                  mr_datmatdlig.c24paxnum, " ",
                                                  l_data, " ",
                                                  l_hora sleep 2
    rollback work
    let m_erro = true
    return
 end if
 commit work

 end function

#funcao tambem chamada no programa cta02m00#
#---------------------------------------#
 function cta02m20_remover_atendimento()
#---------------------------------------#

 if m_cta02m20_prep is null or
    m_cta02m20_prep <> true then
    call cta02m20_prep()
 end if
 begin work
 whenever error continue
 execute pcta02m20008 using g_issk.funmat,
                            g_issk.empcod,
                            g_issk.usrtip,
                            g_c24paxnum
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error "Erro EXCLUSAO datmatdlig.  - ", sqlca.sqlcode," / ",sqlca.sqlerrd[2] sleep 2
    error "cta02m20/cta02m20_remover_atendimento/",g_issk.funmat, " ",
                                                   g_issk.empcod, " ",
                                                   g_issk.usrtip, " ",
                                                   g_c24paxnum sleep 2
    let m_erro = true
    rollback work
 else
    commit work
 end if

 end function

#---------------------------------------#
 function cta02m20_excluir_atendimento()
#---------------------------------------#
 begin work
 if  m_chamada = 1 then
     whenever error continue
     execute pcta02m20005 using m_succod,
                                m_ramcod,
                                m_aplnumdig,
                                m_itmnumdig
     whenever error stop
     if sqlca.sqlcode <> 0 then
        error "Erro EXCLUSAO datmatdlig.  - ", sqlca.sqlcode," / ",sqlca.sqlerrd[2] sleep 2
        error "cta02m20/cta02m20_remover_atendimento/",m_succod, " ",
                                                       m_ramcod, " ",
                                                       m_aplnumdig, " ",
                                                       m_itmnumdig sleep 2
        rollback work
        let m_erro = true
        return
     end if
 else
     whenever error continue
     execute pcta02m20006 using m_prporg,
                                m_prpnumdig
     whenever error stop
     if sqlca.sqlcode <> 0 then
        error "Erro EXCLUSAO datmatdlig.  - ", sqlca.sqlcode," / ",sqlca.sqlerrd[2] sleep 2
        error "cta02m20/cta02m20_remover_atendimento/",m_prporg, " ", m_prpnumdig  sleep 2
        rollback work
        let m_erro = true
        return
     end if
 end if
 commit work

 end function

#--------------------------------------------#
 function cta02m20_verifica_isskfunc(lr_parm)
#--------------------------------------------#

 define lr_parm         record
        empcod          like isskfunc.empcod,
        funmat          like isskfunc.funmat,
        usrtip          like isskfunc.usrtip
 end record

 define l_nom_atendente char(20)
 let l_nom_atendente = null

 whenever error continue
    open c_cta02m20_003 using lr_parm.funmat,
                            lr_parm.empcod,
                            lr_parm.usrtip
    fetch c_cta02m20_003 into l_nom_atendente
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode < 0 then                             ## Erro de acesso a base
       error " Erro ACESSO isskfunc ", sqlca.sqlcode, "/",sqlca.sqlerrd[2] sleep 2
       error "cta02m20/cta02m20_verifica_isskfunc/",lr_parm.funmat, ' ',
                                                    lr_parm.empcod, ' ',
                                                    lr_parm.usrtip sleep 2
       let m_erro = true
    else
       error " Matricula nao cadastrada na tabela isskfunc ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 2
    end if
 end if

 return l_nom_atendente

 end function

#funcao chamada tambem do programa cta02m00#
#-------------------------------------------------------------------------------#
 function cta02m20_inclui_assunto(l_succod, l_ramcod, l_aplnumdig, l_itmnumdig )
#-------------------------------------------------------------------------------#
 define l_succod    like datmatdlig.succod,
        l_ramcod    like datmatdlig.ramcod,
        l_aplnumdig like datmatdlig.aplnumdig,
        l_itmnumdig like datmatdlig.itmnumdig

 if m_cta02m20_prep is null or
    m_cta02m20_prep <> true then
    call cta02m20_prep()
 end if

 whenever error continue
 execute pcta02m20007 using g_documento.c24astcod,
                            g_issk.funmat,
                            g_issk.empcod,
                            g_issk.usrtip,
                            g_c24paxnum
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error "Erro UPDATE datmatdlig.  - ", sqlca.sqlcode," / ",sqlca.sqlerrd[2] sleep 2
    error "cta02m20/cta02m20_inclui_assunto/",g_documento.c24astcod, " ",
                                              g_issk.funmat, " ",
                                              g_issk.empcod, " ",
                                              g_issk.usrtip, " ",
                                              g_c24paxnum sleep 2
    return
 end if

 initialize mr_datmatdlig to null

 open c_cta02m20_001 using l_succod,
                         l_ramcod,
                         l_aplnumdig,
                         l_itmnumdig
 whenever error continue
 fetch c_cta02m20_001 into mr_datmatdlig.*
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       error " Erro Cursor c_cta02m20_001 ", sqlca.sqlcode, " / ",sqlca.sqlerrd[2] sleep 2
       error "cta02m20/cta02m20_inclui_assunto/",l_succod, " ",l_ramcod, " ",
                                                 l_aplnumdig, " ", l_itmnumdig
       let m_erro = true
       return
    end if
 else
    if mr_datmatdlig.atdmat    <> g_issk.funmat and
       mr_datmatdlig.c24paxnum <> g_c24paxnum   and
       mr_datmatdlig.c24astcod <> g_documento.c24astcod then
       call cta02m20_exibe_alerta(mr_datmatdlig.atdmat,
                                  mr_datmatdlig.atdempcod,
                                  mr_datmatdlig.atdusrtip,
                                  mr_datmatdlig.c24paxnum,
                                  mr_datmatdlig.c24solnom,
                                  mr_datmatdlig.c24astcod)
    end if
 end if

 end function
