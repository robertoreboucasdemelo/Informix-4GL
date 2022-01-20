#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CT24H                                                      #
# MODULO.........: CTB28M01                                                   #
# ANALISTA RESP..: CARLOS ZYON                                                #
# PSI/OSF........: 188.751                                                    #
# OBJETIVO.......: CONSULTAR OS PRESTADORES COM SERVICOS PENDENTES.           #
# ........................................................................... #
# DESENVOLVIMENTO: META, LUCAS SCHEID                                         #
# LIBERACAO......: 22/03/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

  define m_ctb28m01_prep smallint

#-------------------------#
function ctb28m01_prepare()
#-------------------------#

  define l_sql char(500)

  let l_sql = ' select nomgrr ',
                ' from dpaksocor ',
               ' where pstcoddig = ? '

  prepare pctb28m01001 from l_sql
  declare cctb28m01001 cursor for pctb28m01001

  let l_sql = ' select a.atddat, ',
                     ' a.atdsrvorg, ',
                     ' a.atdsrvnum, ',
                     ' a.atdsrvano ',
                ' from datmservico a, ',
                     ' dpamris b ',
               ' where a.atdsrvnum = b.atdsrvnum ',
                 ' and a.atdsrvano = b.atdsrvano ',
                 ' and a.atddat >= ? ',
                 ' and a.atddat <= ? ',
                 ' and a.atdprscod = ? ',
                 ' and b.risldostt = 0 ',
               ' order by 1, 4, 3 '

  prepare pctb28m01002 from l_sql
  declare cctb28m01002 cursor for pctb28m01002

  let m_ctb28m01_prep = true

end function

#-----------------------------#
function ctb28m01(lr_parametro)
#-----------------------------#

  define lr_parametro record
         perini       date,
         perfim       date,
         pstcoddig    like dpaksocor.pstcoddig
  end record

  define al_ctb28m01  array[1500] of record
         atddat       like datmservico.atddat,
         servico      char(13)
  end record

  define lr_ctb28m01  record
         atdsrvorg    like datmservico.atdsrvorg,
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_nomgrr     like dpaksocor.nomgrr,
         l_contador   smallint,
         l_cts04g00   smallint

  if m_ctb28m01_prep is null or
     m_ctb28m01_prep <> true then
     call ctb28m01_prepare()
  end if

  initialize al_ctb28m01, lr_ctb28m01 to null

  let l_contador = 1
  let l_nomgrr   = null
  let l_cts04g00 = null

  open window w_ctb28m01 at 4,2 with form 'ctb28m01'
     attribute(form line 1)

  # --RECUPERA O NOME DE GUERRA DO PRESTADOR-- #
  open cctb28m01001 using lr_parametro.pstcoddig
  whenever error continue
  fetch cctb28m01001 into l_nomgrr
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_nomgrr = null
     else
        error 'Erro SELECT cctb28m01001 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2] sleep 2
        error 'ctb28m01() | ', lr_parametro.pstcoddig sleep 2
        return
     end if
  end if

  # --EXIBE CABECALHO-- #
  display by name lr_parametro.perini, lr_parametro.perfim, lr_parametro.pstcoddig

  display l_nomgrr to nomgrr

  open cctb28m01002 using lr_parametro.perini, lr_parametro.perfim, lr_parametro.pstcoddig

  foreach cctb28m01002 into al_ctb28m01[l_contador].atddat,
                            lr_ctb28m01.*

     let al_ctb28m01[l_contador].servico = lr_ctb28m01.atdsrvorg using '&&', '/',
                                           lr_ctb28m01.atdsrvnum using '&&&&&&&', '-',
                                           lr_ctb28m01.atdsrvano using '&&'

     let l_contador = l_contador + 1

     if l_contador > 1500 then
        error 'A QUANTIDADE DE REGISTROS SUPEROU O LIMITE DO ARRAY' sleep 2
        exit foreach
     end if

  end foreach

  let l_contador = l_contador - 1

  display l_contador to total

  call set_count(l_contador)

  display array al_ctb28m01 to s_ctb28m01.*

     on key(f8)
        let l_contador = arr_curr()

        let g_documento.atdsrvorg = al_ctb28m01[l_contador].servico[1,2]
        let g_documento.atdsrvnum = al_ctb28m01[l_contador].servico[4,10]
        let g_documento.atdsrvano = al_ctb28m01[l_contador].servico[12,13]

        let l_cts04g00 = cts04g00('ctb28m01')

     on key(f17, control-c, interrupt, accept)
        exit display

  end display

  close window w_ctb28m01

  let int_flag = false

end function
