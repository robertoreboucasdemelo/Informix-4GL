#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: CENTRAL 24HS                                               #
# Modulo.........: cts00m38                                                   #
# Analista Resp..: Ligia Mattge                                               #
# PSI/OSF........: 190.489                                                    #
#                  Modulo responsavel pela verificacao do resumo dos Servicos #
#                  Pendentes.                                                 #
# ........................................................................... #
# Desenvolvimento: Meta, Lucas Scheid                                         #
# Liberacao......: 27/01/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 07/11/2005 Ligia Mattge    PSI195138  a.atdfnlflg in("N","A")               #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts00m38_prep smallint,
         m_contador      smallint

  define am_cts00m38     array[200] of record
         descricao       char(30),
         ufdcod          char(02),
         qtde            smallint
  end record

  define am_cts00m38_aux array[200] of record
         codigo_filtro   like datksocntz.socntzgrpcod
  end record

#-------------------------#
function cts00m38_prepare()
#-------------------------#

  define l_sql char(200)

  let l_sql = ' select ufdcod ',
                ' from datmlcl ',
               ' where atdsrvnum = ? ',
                 ' and atdsrvano = ? ',
                 ' and c24endtip = ? '

  prepare p_cts00m38_001 from l_sql
  declare c_cts00m38_001 cursor for p_cts00m38_001

  let m_cts00m38_prep = true

end function

#---------------------------------#
function cts00m38_cria_temporaria()
#---------------------------------#

  define l_sql char(200)

  let l_sql = null
  whenever error continue
  drop table cts00m38_temp
  create temp table cts00m38_temp
                   (atdsrvnum     decimal(10,0),
                    atdsrvano     decimal(2,0),
                    codigo_filtro smallint,
                    ufdcod        char(02)) with no log
  create index cts00m38_temp_ind on cts00m38_temp (atdsrvnum, atdsrvano, codigo_filtro)
  whenever error stop

  let l_sql = ' insert into cts00m38_temp ',
                         ' (atdsrvnum, ',
                          ' atdsrvano, ',
                          ' codigo_filtro, ',
                          ' ufdcod) ',
                  ' values (?,?,?,?) '

  prepare pcts00m38003 from l_sql

  let l_sql = ' select codigo_filtro, ',
                     ' ufdcod, ',
                     ' count(*) ',
                ' from cts00m38_temp ',
               ' group by codigo_filtro, ',
                        ' ufdcod ',
               ' order by 3 desc '

  prepare pcts00m38004 from l_sql
  declare ccts00m38004 cursor for pcts00m38004

end function

#----------------------------------#
function cts00m38_resumo(l_pesq_tip)
#----------------------------------#

  define l_pesq_tip    char(03),
         l_sql         char(400),
         l_arr         smallint,
         l_scr         smallint,
         l_resultado   smallint,
         l_mensagem    char(80),
         l_ufdcod      like datmlcl.ufdcod,
         l_flag        smallint

  define lr_cts00m38   record
         atdsrvnum     like datmservico.atdsrvnum,
         atdsrvano     like datmservico.atdsrvano,
         codigo_filtro like datksocntz.socntzgrpcod,
         c24opemat     like datmservico.c24opemat
  end record

  define lr_retorno    record
         codigo_filtro like datksocntz.socntzgrpcod,
         ufdcod        like datmlcl.ufdcod
  end record

  initialize lr_cts00m38, am_cts00m38, lr_retorno, am_cts00m38_aux to null

  let l_arr       = null
  let l_scr       = null
  let l_resultado = null
  let l_mensagem  = null
  let m_contador  = null
  let l_ufdcod    = null

  let l_sql = ' select a.atdsrvnum, ',
                     ' a.atdsrvano, ',
                     ' c.socntzgrpcod, ',
                     ' a.c24opemat ',
                ' from datmservico a, ',
                     ' datmsrvre b, ',
                     ' datksocntz c, ',
                     ' datksocntzgrp d ',
               ' where a.atdlibflg = "S" ',
                 ' and a.atdfnlflg in("N","A") ', #psi 195138
                 ' and a.atdsrvnum = b.atdsrvnum ',
                 ' and a.atdsrvano = b.atdsrvano ',
                 ' and b.socntzcod = c.socntzcod ',
                 ' and c.socntzgrpcod = d.socntzgrpcod '

  if l_pesq_tip = 'tpa' then
     let l_sql = ' select a.atdsrvnum, ',
                        ' a.atdsrvano, ',
                        ' a.asitipcod, ',
                        ' a.c24opemat ',
                   ' from datmservico a, ',
                        ' datkasitip b, ',
                        ' datrasitipsrv c ',
                  ' where a.atdlibflg = "S" ',
                    ' and a.atdfnlflg = "N" ',
                    ' and a.atdsrvorg not in (10,9,13) ',
                    ' and a.asitipcod = b.asitipcod ',
                    ' and a.asitipcod = c.asitipcod ',
                    ' and a.atdsrvorg = c.atdsrvorg '
  end if

  prepare p_cts00m38_002 from l_sql
  declare c_cts00m38_002 cursor for p_cts00m38_002

  call cts00m38_cria_temporaria()

  foreach c_cts00m38_002 into lr_cts00m38.*

     if lr_cts00m38.c24opemat is not null then
        continue foreach
     end if

     call cts00m38_ufdcod(lr_cts00m38.atdsrvnum, lr_cts00m38.atdsrvano, 1)
          returning l_resultado, l_mensagem, l_ufdcod

     if l_resultado <> 1 then
        continue foreach
     end if

     whenever error continue
     execute pcts00m38003 using lr_cts00m38.atdsrvnum,
                                lr_cts00m38.atdsrvano,
                                lr_cts00m38.codigo_filtro,
                                l_ufdcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
        error 'Erro INSERT pcts00m38003 ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
        error 'cts00m38_resumo() ', lr_cts00m38.atdsrvnum, ' / ',
                                    lr_cts00m38.atdsrvano, ' / ',
                                    lr_cts00m38.codigo_filtro, ' / ',
                                    l_ufdcod sleep 2
        exit foreach
     end if

  end foreach

  open window w_cts00m38 at 9,30 with form 'cts00m38'
     attribute(border, form line 1)
  let l_flag = true
  while l_flag
     clear form

     if l_pesq_tip = 'tpa' then
         display 'Tipo Assistencia  ' to campo
     else
         display 'Grupo de Naturezas' to campo
     end if

     call cts00m38_carrega_array(l_pesq_tip)
     let m_contador = m_contador - 1
     call set_count(m_contador)
     display array am_cts00m38 to s_cts00m38.*
        on key(f6)
           exit display
        on key(F8)
           let l_arr = arr_curr()
           let l_scr = scr_line()
           let lr_retorno.codigo_filtro = am_cts00m38_aux[l_arr].codigo_filtro
           let lr_retorno.ufdcod        = am_cts00m38[l_arr].ufdcod
           let l_flag = false
           exit display
        on key(control-c, f17, interrupt)
           initialize lr_retorno.* to null
           let l_flag = false
           exit display
     end display

  end while

  close window w_cts00m38
  let int_flag = false

  return lr_retorno.*

end function

#------------------------------------#
function cts00m38_ufdcod(lr_parametro)
#------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmlcl.atdsrvnum,
         atdsrvano    like datmlcl.atdsrvano,
         c24endtip    like datmlcl.c24endtip
  end record

  define l_ufdcod     like datmlcl.ufdcod,
         l_resultado  smallint,
         l_mensagem   char(80)

  if m_cts00m38_prep is null or
     m_cts00m38_prep <> true then
     call cts00m38_prepare()
  end if

  let l_ufdcod    = null
  let l_resultado = null
  let l_mensagem  = null

  open c_cts00m38_001 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano, lr_parametro.c24endtip
  whenever error continue
  fetch c_cts00m38_001 into l_ufdcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_resultado = 2
        let l_mensagem= 'Endereco do servico nao encontrado'
     else
        error 'Erro SELECT c_cts00m38_001 ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
        error 'cts00m38_ufdcod() / ', lr_parametro.atdsrvnum, ' / ',
                                      lr_parametro.atdsrvano, ' / ',
                                      lr_parametro.c24endtip sleep 2
        let l_resultado = 3
        let l_mensagem = 'Erro ', sqlca.sqlcode, ' em datmlcl'
     end if
  end if

  return l_resultado, l_mensagem, l_ufdcod

end function

#-----------------------------------------#
function cts00m38_carrega_array(l_pesq_tip)
#-----------------------------------------#

  define l_resultado     smallint,
         l_mensagem      char(80),
         l_codigo_filtro smallint,
         l_pesq_tip      char(03)

  let l_codigo_filtro = null
  let l_resultado     = null
  let l_mensagem      = null
  initialize am_cts00m38     to null
  initialize am_cts00m38_aux to null

  let m_contador = 1

  foreach ccts00m38004 into l_codigo_filtro,
                            am_cts00m38[m_contador].ufdcod,
                            am_cts00m38[m_contador].qtde
     let am_cts00m38_aux[m_contador].codigo_filtro = l_codigo_filtro

     if l_pesq_tip = 'tpa' then
        call ctn25c00_descricao(l_codigo_filtro)
             returning l_resultado, l_mensagem, am_cts00m38[m_contador].descricao
     else
        call ctx24g00_descricao(l_codigo_filtro)
             returning l_resultado, l_mensagem, am_cts00m38[m_contador].descricao
     end if

     let m_contador = m_contador + 1

     if m_contador > 200 then
        error 'O numero de registros superou o limite do array' sleep 2
        exit foreach
     end if

  end foreach
  close ccts00m38004

end function
