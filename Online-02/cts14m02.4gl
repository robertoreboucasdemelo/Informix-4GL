###############################################################################
# Nome do Modulo: CTS14M02                                              Pedro #
#                                                                     Marcelo #
# Localiza Vistoria Sinistro - Auto                                  Jun/1995 #
###############################################################################
#                           A  T  E  N  C  A  O                               #
###############################################################################
#  Este modulo possui uma versao de consulta no sistema de sinistro(ssatc100) #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 21/08/2001  PSI 132322    Ruiz        consulta a vistoria atraves do        #
#                                       sistema de atendimento.               #
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

  define m_cts14m02_prep smallint

#-------------------------#
function cts14m02_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select 1 ",
                " from datmvstsin ",
               " where sinvstnum = ? ",
                 " and sinvstano = ? "

  prepare p_cts14m02_001 from l_sql
  declare c_cts14m02_001 cursor for p_cts14m02_001

  let l_sql = " select lignum ",
                " from datrligsinvst ",
               " where sinvstnum = ? ",
                 " and sinvstano = ? ",
            " order by lignum desc  "

  prepare p_cts14m02_002 from l_sql
  declare c_cts14m02_002 cursor for p_cts14m02_002

  let l_sql = " select c24astcod ",
                " from datmligacao ",
               " where lignum = ? "

  prepare p_cts14m02_003 from l_sql
  declare c_cts14m02_003 cursor for p_cts14m02_003

  let m_cts14m02_prep = true

end function

#----------------------#
function cts14m02(param)
#----------------------#

 define param         record
    pgm               char (08)
 end record
 define d_cts14m02    record
    vstdat            like datmvstsin.vstdat   ,
    sinvstnum         like datmvstsin.sinvstnum,
    sinvstano         like datmvstsin.sinvstano,
    placa             like datmvstsin.vcllicnum
 end record

 define a_cts14m02 array[400] of record
    vstretdat         like datmvstsin.vstretdat,
    sinvstnum         like datmvstsin.sinvstnum,
    sinvstano         like datmvstsin.sinvstano,
    veiculo           char(40)                 ,
    vcllicnum         like datmvstsin.vcllicnum
 end record

 define ws            record
    comando1          char(200),
    comando2          char(120),
    vstdat            char(10),
    total             char(10)
 end record

 define retorno       record
    sinvstnum         like datmvstsin.sinvstnum,
    sinvstano         like datmvstsin.sinvstano
 end record

 define arr_aux       integer,
        l_pesq_num    smallint,
        l_proc_vidro  smallint,
        l_lignum      like datmligacao.lignum,
        l_c24astcod   like datmligacao.c24astcod

 define  w_pf1   integer

  if m_cts14m02_prep is null or
     m_cts14m02_prep <> true then
     call cts14m02_prepare()
  end if

  let     arr_aux  =  null

  for     w_pf1  =  1  to  400
          initialize  a_cts14m02[w_pf1].*  to  null
  end     for

  initialize  d_cts14m02.*  to  null

  initialize  ws.*  to  null

  initialize  retorno.*  to  null

 let l_pesq_num   = false
 let l_proc_vidro = false
 let l_lignum     = null
 let l_c24astcod  = null

 open window w_cts14m02 at 06,02 with form "cts14m02"
    attribute(form line first)

 while true

    initialize ws.*        to null
    initialize retorno.*   to null
    initialize a_cts14m02  to null
    let int_flag = false
    let arr_aux  = 1
    let l_lignum     = null
    let l_c24astcod  = null

    input by name d_cts14m02.*

       before field vstdat
              display by name d_cts14m02.vstdat    attribute (reverse)

              let d_cts14m02.vstdat = today + 1 units day

       after  field vstdat
              display by name d_cts14m02.vstdat

              if d_cts14m02.vstdat  is null   then
                 error " Informe a data para pesquisa!"
                 next field vstdat
              end if

       before field sinvstnum
              display by name d_cts14m02.sinvstnum attribute (reverse)

       after  field sinvstnum
              display by name d_cts14m02.sinvstnum

       before field sinvstano
              display by name d_cts14m02.sinvstano attribute (reverse)

       after  field sinvstano
              display by name d_cts14m02.sinvstano

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 next field sinvstnum
              end if
              if d_cts14m02.sinvstnum     is null    then
                 if d_cts14m02.sinvstano  is not null   then
                    error " Numero da vistoria deve ser informado !!"
                    next field sinvstnum
                 end if
              else
                 if d_cts14m02.sinvstano  is null   then
                    error " Ano da vistoria deve ser informado !!"
                    next field sinvstano
                 end if
              end if

              if d_cts14m02.sinvstnum is not null  and
                 d_cts14m02.sinvstano is not null  then
                 exit input
              end if

       before field placa
              display by name d_cts14m02.placa attribute (reverse)

       after  field placa
              display by name d_cts14m02.placa

              if d_cts14m02.vstdat is null and
                 d_cts14m02.sinvstnum is null and
                 d_cts14m02.placa     is null then
                 error " Informe uma chave para pesquisa!"
                 next field vstdat
              end if

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    let l_pesq_num = false
    #-------------------------------------------
    # CONSULTA AS VISTORIAS MARCADAS
    #-------------------------------------------
    if d_cts14m02.placa  is not null   then
       let ws.comando2 = " from datmvstsin ",
                         " where ",
                         " datmvstsin.vstretdat = ? and ",
                         " datmvstsin.vcllicnum = ? "
    else
       if d_cts14m02.sinvstnum is not null   and
          d_cts14m02.sinvstnum <> 0          then
          let l_pesq_num  = true # VAI PESQUISAR POR NUMERO
          let ws.comando2 = " from datmvstsin ",
                            " where ",
                            " datmvstsin.sinvstnum = ? and ",
                            " datmvstsin.sinvstano = ? "
       else
          let ws.comando2 = " from datmvstsin ",
                            " where ",
                            " datmvstsin.vstretdat = ? "
       end if
    end if

    let ws.comando1="select vstretdat, sinvstnum, sinvstano, vcldes, vcllicnum",
                        ws.comando2  clipped

    prepare p_cts14m02_004 from ws.comando1
    declare c_cts14m02_004 cursor for p_cts14m02_004

    if d_cts14m02.placa  is not null   then
       open c_cts14m02_004  using d_cts14m02.vstdat, d_cts14m02.placa
    else
       if d_cts14m02.sinvstnum  is not null   then
          open c_cts14m02_004  using d_cts14m02.sinvstnum, d_cts14m02.sinvstano
       else
          open c_cts14m02_004  using d_cts14m02.vstdat
       end if
    end if

    let l_proc_vidro = false
    foreach  c_cts14m02_004  into  a_cts14m02[arr_aux].vstretdat,
                               a_cts14m02[arr_aux].sinvstnum,
                               a_cts14m02[arr_aux].sinvstano,
                               a_cts14m02[arr_aux].veiculo  ,
                               a_cts14m02[arr_aux].vcllicnum

       # -> ACESSA A TABELA datrligsinvst BUSCANDO O lignum
       open c_cts14m02_002 using a_cts14m02[arr_aux].sinvstnum,
                               a_cts14m02[arr_aux].sinvstano
       whenever error continue
       fetch c_cts14m02_002 into l_lignum
       whenever error stop

       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             let l_lignum = null
          else
             error "Erro SELECT c_cts14m02_002 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
             close c_cts14m02_002
             exit foreach
          end if
       end if

       close c_cts14m02_002

       if l_lignum is not null then
          # -> ACESSA A TABELA datmligacao BUSCANDO O ASSUNTO(c24astcod)
          open c_cts14m02_003 using l_lignum
          whenever error continue
          fetch c_cts14m02_003 into l_c24astcod
          whenever error stop

          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = notfound then
                let l_c24astcod = null
             else
                error "Erro SELECT c_cts14m02_003 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
                close c_cts14m02_003
                exit foreach
             end if
          end if

          close c_cts14m02_003

          if l_c24astcod is not null then
             if l_c24astcod = "B14" then # PROCESSO DE VIDROS
                let l_proc_vidro = true # INDICA QUE E UM PROCESSO DE VIDROS
                continue foreach
             end if
          end if

       end if

       open c_cts14m02_001 using a_cts14m02[arr_aux].sinvstnum,
                               a_cts14m02[arr_aux].sinvstano
       whenever error continue
       fetch c_cts14m02_001
       whenever error stop

       # -> VERIFICA SE A VISTORIA EXISTE NA TABELA datmvstsin
       if sqlca.sqlcode <> 0 then
          close c_cts14m02_001
          if sqlca.sqlcode = notfound then
             continue foreach
          else
             error "Erro SELECT c_cts14m02_001 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
             exit foreach
          end if
       end if

       close c_cts14m02_001

       let arr_aux = arr_aux + 1

       if arr_aux > 400  then
          error " Limite excedido! Foram encontradas mais de 400 marcacoes!"
          exit foreach
       end if
    end foreach

    let ws.total = "Total: ", arr_aux - 1 using "&&&"
    display by name ws.total  attribute (reverse)

    if arr_aux  >  1   then
       message " (F17)Abandona, (F8)Seleciona"
       call set_count(arr_aux-1)

       display array  a_cts14m02 to s_cts14m02.*
          on key(interrupt)
             initialize ws.total to null
             display by name ws.total
             exit display

          on key(f8)
             let arr_aux = arr_curr()
             if param.pgm = "cta00m01"  then
                let retorno.sinvstnum = a_cts14m02[arr_aux].sinvstnum
                let retorno.sinvstano = a_cts14m02[arr_aux].sinvstano
                exit display
             end if
             error " Selecione e tecle ENTER!"
             call cts14m01(a_cts14m02[arr_aux].sinvstnum,
                           a_cts14m02[arr_aux].sinvstano)
       end display

       for arr_aux = 1 to 11
          clear s_cts14m02[arr_aux].vstretdat
          clear s_cts14m02[arr_aux].sinvstnum2
          clear s_cts14m02[arr_aux].sinvstano2
          clear s_cts14m02[arr_aux].veiculo
          clear s_cts14m02[arr_aux].vcllicnum
       end for
    else
       if l_pesq_num = true then # REALIZOU A PESQUISA POR NUMERO
          if l_proc_vidro = true then # NUMERO PERTENCE A UM B14
             error "Este numero refere-se a um PROCESSO DE VIDROS(B14) !"
          else
             error " Nao existem vistorias programadas para pesquisa!"
          end if
       else
          error " Nao existem vistorias programadas para pesquisa!"
       end if

    end if
    close c_cts14m02_004
    if param.pgm = "cta00m01"  and
       retorno.sinvstnum is not null then
       exit while
    end if
 end while

 let int_flag = false
 close window  w_cts14m02
 if param.pgm = "cta00m01" then
    return retorno.sinvstnum,
           retorno.sinvstano
 end if
end function  ###  cts14m02
