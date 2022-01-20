#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTA01M15                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 202720 - SAUDE + CASA                                      #
#                  BUSCA DAS INFORMACOES DA TABELA DATKSEGSAU.                #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 21/09/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cta01m15_prep smallint

#-------------------------#
function cta01m15_prepare()
#-------------------------#

  define l_sql char(600)

  let l_sql = null

  let l_sql = ' select count(*) ',
                ' from datksegsau ',
               ' where cgccpfnum = ? ',
                 ' and cgccpfdig = ? '

  prepare p_cta01m15_001 from l_sql
  declare c_cta01m15_001 cursor for p_cta01m15_001

  let l_sql = " insert into datksegsau(succod, ",
                                     " ramcod, ",
                                     " aplnumdig, ",
                                     " crtsaunum, ",
                                     " crtstt, ",
                                     " plncod, ",
                                     " segnom, ",
                                     " cgccpfnum, ",
                                     " cgcord, ",
                                     " cgccpfdig, ",
                                     " empnom, ",
                                     " corsus, ",
                                     " cornom, ",
                                     " cntanvdat, ",
                                     " bnfnum, ",
                                     " incdat) ",
                              " values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "

  prepare p_cta01m15_002 from l_sql

  let l_sql = " update datksegsau set(succod, ",
                                    " ramcod, ",
                                    " aplnumdig, ",
                                    " crtstt, ",
                                    " plncod, ",
                                    " segnom, ",
                                    " cgccpfnum, ",
                                    " cgcord, ",
                                    " cgccpfdig, ",
                                    " empnom, ",
                                    " corsus, ",
                                    " cornom, ",
                                    " cntanvdat, ",
                                    " excdat) = ",
                                   " (?,?,?,?,?,?,?,?,?,?,?,?,?,?) ",
                              " where bnfnum = ? ",
                                " and crtsaunum = ? "

  prepare p_cta01m15_003 from l_sql

  let l_sql = " select succod, ",
                     " ramcod, ",
                     " aplnumdig, ",
                     " crtsaunum, ",
                     " crtstt, ",
                     " plncod, ",
                     " segnom, ",
                     " cgccpfnum, ",
                     " cgcord, ",
                     " cgccpfdig, ",
                     " empnom, ",
                     " corsus, ",
                     " cornom, ",
                     " cntanvdat, ",
                     " incdat, ",
                     " excdat ",
                " from datksegsau ",
               " where bnfnum = ? ",
               "   and crtsaunum = ? ",
               " order by incdat desc, ",
                        " excdat desc "

  prepare p_cta01m15_004 from l_sql
  declare c_cta01m15_002 cursor for p_cta01m15_004

  let m_cta01m15_prep = true

end function

#--------------------------------------------#
function cta01m15_sel_datksegsau(lr_parametro)
#--------------------------------------------#

  # -> FUNCAO PARA RELIZAR A BUSCA DAS INFORMACOES
  # -> POR CARTAO, NOME DO SEGURADO OU CPF NA TABELA datksegsau

  define lr_parametro record
         nivel_ret    smallint,                  # -> NIVEL DE RETORNO
         crtsaunum    like datksegsau.crtsaunum, # -> Nº DO CARTAO
         segnom       like datksegsau.segnom,    # -> NOME DO SEGURADO
         cgccpfnum    like datksegsau.cgccpfnum, # -> Nº CPF
         cgccpfdig    like datksegsau.cgccpfdig  # -> DIGITO DO CPF
  end record

  define lr_dados     record
         bnfnum       like datksegsau.bnfnum,
         crtsaunum    like datksegsau.crtsaunum,
         succod       like datksegsau.succod,
         ramcod       like datksegsau.ramcod,
         aplnumdig    like datksegsau.aplnumdig,
         crtstt       like datksegsau.crtstt,
         plncod       like datksegsau.plncod,
         segnom       like datksegsau.segnom,
         cgccpfnum    like datksegsau.cgccpfnum,
         cgcord       like datksegsau.cgcord,
         cgccpfdig    like datksegsau.cgccpfdig,
         empnom       like datksegsau.empnom,
         corsus       like datksegsau.corsus,
         cornom       like datksegsau.cornom,
         cntanvdat    like datksegsau.cntanvdat,
         lgdtip       like datksegsau.lgdtip,
         lgdnom       like datksegsau.lgdnom,
         lgdnum       like datksegsau.lgdnum,
         lclbrrnom    like datksegsau.lclbrrnom,
         cidnom       like datksegsau.cidnom,
         ufdcod       like datksegsau.ufdcod,
         lclrefptotxt like datksegsau.lclrefptotxt,
         endzon       like datksegsau.endzon,
         lgdcep       like datksegsau.lgdcep,
         lgdcepcmp    like datksegsau.lgdcepcmp,
         dddcod       like datksegsau.dddcod,
         lcltelnum    like datksegsau.lcltelnum,
         lclcttnom    like datksegsau.lclcttnom,
         lclltt       like datksegsau.lclltt,
         lcllgt       like datksegsau.lcllgt,
         incdat       like datksegsau.incdat,
         excdat       like datksegsau.excdat,
         brrnom       like datksegsau.brrnom,
         c24lclpdrcod like datksegsau.c24lclpdrcod
  end record

  define l_sql        char(600),
         l_msg        char(80),
         l_status     smallint

  #---------------------------------
  # DESCRICAO DO l_status DE RETORNO
  #---------------------------------
  # 1 -> OK, ENCONTROU AS INFORMACOES
  # 2 -> NAO ENCONTROU AS INFORMACOES
  # 3 -> ERRO DE ACESSO A BASE DE DADOS

  let l_sql    = null
  let l_msg    = null
  let l_status = 0

  initialize lr_dados.*  to null

  let l_sql = ' select bnfnum, ',
                     ' crtsaunum, ',
                     ' succod, ',
                     ' ramcod, ',
                     ' aplnumdig, ',
                     ' crtstt, ',
                     ' plncod, ',
                     ' segnom, ',
                     ' cgccpfnum, ',
                     ' cgcord, ',
                     ' cgccpfdig, ',
                     ' empnom, ',
                     ' corsus, ',
                     ' cornom, ',
                     ' cntanvdat, ',
                     ' lgdtip, ',
                     ' lgdnom, ',
                     ' lgdnum, ',
                     ' lclbrrnom, ',
                     ' cidnom, ',
                     ' ufdcod, ',
                     ' lclrefptotxt, ',
                     ' endzon, ',
                     ' lgdcep, ',
                     ' lgdcepcmp, ',
                     ' dddcod, ',
                     ' lcltelnum, ',
                     ' lclcttnom, ',
                     ' lclltt, ',
                     ' lcllgt, ',
                     ' incdat, ',
                     ' excdat, ',
                     ' brrnom, ',
                     ' c24lclpdrcod ',
                ' from datksegsau '

  if lr_parametro.crtsaunum is not null then
     # -> PESQUISA PELO NUMERO DO CARTAO
     let l_sql = l_sql clipped,
                 ' where crtsaunum = ',
                 '"',
                 lr_parametro.crtsaunum clipped,
                 '"'
  else
     if lr_parametro.cgccpfnum is not null and
        lr_parametro.cgccpfnum <> 0        and
        lr_parametro.cgccpfdig is not null then
        # -> PESQUISA PELO CPF
        let l_sql = l_sql clipped,
                    ' where cgccpfnum = ',
                    lr_parametro.cgccpfnum,
                    ' and cgccpfdig = ',
                    lr_parametro.cgccpfdig,
                    " and crtstt <> 'C' "
     else
        if lr_parametro.segnom is not null then
           # -> PESQUISA PELO NOME DO SEGURADO
           let l_sql = l_sql clipped,
                       ' where segnom = ',
                       '"',
                       lr_parametro.segnom clipped,
                       '"'
        end if
     end if
  end if

  prepare p_cta01m15_005 from l_sql
  declare c_cta01m15_003 cursor for p_cta01m15_005

  open c_cta01m15_003
  whenever error continue
  fetch c_cta01m15_003 into lr_dados.bnfnum,
                          lr_dados.crtsaunum,
                          lr_dados.succod,
                          lr_dados.ramcod,
                          lr_dados.aplnumdig,
                          lr_dados.crtstt,
                          lr_dados.plncod,
                          lr_dados.segnom,
                          lr_dados.cgccpfnum,
                          lr_dados.cgcord,
                          lr_dados.cgccpfdig,
                          lr_dados.empnom,
                          lr_dados.corsus,
                          lr_dados.cornom,
                          lr_dados.cntanvdat,
                          lr_dados.lgdtip,
                          lr_dados.lgdnom,
                          lr_dados.lgdnum,
                          lr_dados.lclbrrnom,
                          lr_dados.cidnom,
                          lr_dados.ufdcod,
                          lr_dados.lclrefptotxt,
                          lr_dados.endzon,
                          lr_dados.lgdcep,
                          lr_dados.lgdcepcmp,
                          lr_dados.dddcod,
                          lr_dados.lcltelnum,
                          lr_dados.lclcttnom,
                          lr_dados.lclltt,
                          lr_dados.lcllgt,
                          lr_dados.incdat,
                          lr_dados.excdat,
                          lr_dados.brrnom,
                          lr_dados.c24lclpdrcod
  #whenever error stop
  if sqlca.sqlcode = 0 then
    let l_status = 1
  else
     if sqlca.sqlcode = notfound then
        initialize lr_dados.* to null
        let l_status = 2
     else
        let l_status = 3
        let l_msg    = 'Erro SELECT c_cta01m15_003 /',
                        sqlca.sqlcode, '/',
                        sqlca.sqlerrd[2]
     end if
  end if

  close c_cta01m15_003

  #----------------------------
  # VERIFICA O NIVEL DE RETORNO
  #----------------------------
  case lr_parametro.nivel_ret

     when(1) # RETORNA TODAS AS INFORMACOES DA TABELA
        return l_status,
               l_msg,
               lr_dados.bnfnum,
               lr_dados.crtsaunum,
               lr_dados.succod,
               lr_dados.ramcod,
               lr_dados.aplnumdig,
               lr_dados.crtstt,
               lr_dados.plncod,
               lr_dados.segnom,
               lr_dados.cgccpfnum,
               lr_dados.cgcord,
               lr_dados.cgccpfdig,
               lr_dados.empnom,
               lr_dados.corsus,
               lr_dados.cornom,
               lr_dados.cntanvdat,
               lr_dados.lgdtip,
               lr_dados.lgdnom,
               lr_dados.lgdnum,
               lr_dados.lclbrrnom,
               lr_dados.cidnom,
               lr_dados.ufdcod,
               lr_dados.lclrefptotxt,
               lr_dados.endzon,
               lr_dados.lgdcep,
               lr_dados.lgdcepcmp,
               lr_dados.dddcod,
               lr_dados.lcltelnum,
               lr_dados.lclcttnom,
               lr_dados.lclltt,
               lr_dados.lcllgt,
               lr_dados.incdat,
               lr_dados.excdat,
               lr_dados.brrnom,
               lr_dados.c24lclpdrcod

     when(2) # RETORNA O CODIGO E NOME DO CORRETOR
        return l_status,
               l_msg,
               lr_dados.corsus,
               lr_dados.cornom

     when(3) # RETORNA O NOME/DDD/TELEFONE DO SEGURADO
        return l_status,
               l_msg,
               lr_dados.segnom,
               lr_dados.dddcod,
               lr_dados.lcltelnum

     when(4) # RETORNA O PLANO DE SAUDE E A DATA DE ANIVERSARIO
        return l_status,
               l_msg,
               lr_dados.plncod,
               lr_dados.cntanvdat

     when(5) # RETORNA O NOME DO SEGURADO
        return l_status,
               l_msg,
               lr_dados.segnom

     when(6) # RETORNA O CARTAO E NR. BENEFICIO DO SEGURADO
        return l_status,
               l_msg,
               lr_dados.crtsaunum,
               lr_dados.bnfnum

     when(7) # RETORNA A SITUACAO DO CARTAO
        return l_status,
               l_msg,
               lr_dados.crtstt

     when(8) # RETORNA O CGCCPF DO SEGURADO
        return l_status,
               l_msg,
               lr_dados.segnom,
               lr_dados.cgccpfnum,
               lr_dados.cgcord,
               lr_dados.cgccpfdig

  end case

end function


#----------------------------------#
function cta01m15_psq_nome(l_segnom)
#----------------------------------#

  # -> PESQUISA A QTD. DE REGISTROS POR NOME

  define l_segnom   like datksegsau.segnom,
         l_qtd_reg  smallint,
         l_sql      char(200)

  let l_qtd_reg = 0
  let l_sql     = null

  let l_sql = ' select count(*) ',
                ' from datksegsau ',
               ' where segnom like "', l_segnom clipped, '%"'

  prepare p_cta01m15_006 from l_sql
  declare c_cta01m15_004 cursor for p_cta01m15_006

  let l_qtd_reg = 0

  open c_cta01m15_004
  whenever error continue
  fetch c_cta01m15_004 into l_qtd_reg
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_qtd_reg = 0
     error 'Erro SELECT c_cta01m15_004 ', sqlca.sqlcode, '/',
                                        sqlca.sqlerrd[2] sleep 2
     error 'cta01m15_psq_nome() ', l_segnom clipped sleep 2
  end if

  close c_cta01m15_004

  if l_qtd_reg is null then
     let l_qtd_reg = 0
  end if

  return l_qtd_reg

end function

#-------------------------------------#
function cta01m15_psq_cpf(lr_parametro)
#-------------------------------------#

  # -> PESQUISA A QTD. DE REGISTROS POR CPF

  define lr_parametro record
         cgccpfnum    like datksegsau.cgccpfnum,
         cgccpfdig    like datksegsau.cgccpfdig
  end record

  define l_qtd_reg    smallint

  if m_cta01m15_prep is null or
     m_cta01m15_prep <> true then
     call cta01m15_prepare()
  end if

  let l_qtd_reg = 0

  open c_cta01m15_001 using lr_parametro.cgccpfnum,
                            lr_parametro.cgccpfdig
  whenever error continue
  fetch c_cta01m15_001 into l_qtd_reg
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_qtd_reg = 0
     error 'Erro SELECT c_cta01m15_001 ', sqlca.sqlcode, '/',
                                        sqlca.sqlerrd[2] sleep 2
     error 'cta01m15_psq_cpf() ', lr_parametro.cgccpfnum, '-',
                                  lr_parametro.cgccpfdig sleep 2
  end if

  close c_cta01m15_001

  if l_qtd_reg is null then
     let l_qtd_reg = 0
  end if

  return l_qtd_reg

end function

#----------------------------------------------------#
function cta01m15_nossa_base(l_bnfnum, l_crtsaunum)
#----------------------------------------------------#

  # -> FUNCAO PARA RELIZAR A BUSCA DAS INFORMACOES
  # -> POR NUMERO DO BENEFICIO
  # -> ESTA FUNCAO E UTILIZADA NO PROGRAMA BDATA124

  define l_bnfnum    like datksegsau.bnfnum
  define l_crtsaunum like datksegsau.crtsaunum

  define lr_dados  record
         succod    like datksegsau.succod,
         ramcod    like datksegsau.ramcod,
         aplnumdig like datksegsau.aplnumdig,
         crtsaunum like datksegsau.crtsaunum,
         crtstt    like datksegsau.crtstt,
         plncod    like datksegsau.plncod,
         segnom    like datksegsau.segnom,
         cgccpfnum like datksegsau.cgccpfnum,
         cgcord    like datksegsau.cgcord,
         cgccpfdig like datksegsau.cgccpfdig,
         empnom    like datksegsau.empnom,
         corsus    like datksegsau.corsus,
         cornom    like datksegsau.cornom,
         cntanvdat like datksegsau.cntanvdat,
         incdat    like datksegsau.incdat,
         excdat    like datksegsau.excdat
  end record

  define l_status  smallint,
         l_msg     char(80)

  #---------------------------------
  # DESCRICAO DO l_status DE RETORNO
  #---------------------------------
  # 1 -> OK, ENCONTROU AS INFORMACOES
  # 2 -> NAO ENCONTROU AS INFORMACOES
  # 3 -> ERRO DE ACESSO A BASE DE DADOS

  if m_cta01m15_prep is null or
     m_cta01m15_prep <> true then
     call cta01m15_prepare()
  end if

  initialize lr_dados.* to null

  let l_status = 0
  let l_msg    = null

  open c_cta01m15_002 using l_bnfnum,
                            l_crtsaunum
  whenever error continue
  fetch c_cta01m15_002 into lr_dados.succod,
                            lr_dados.ramcod,
                            lr_dados.aplnumdig,
                            lr_dados.crtsaunum,
                            lr_dados.crtstt,
                            lr_dados.plncod,
                            lr_dados.segnom,
                            lr_dados.cgccpfnum,
                            lr_dados.cgcord,
                            lr_dados.cgccpfdig,
                            lr_dados.empnom,
                            lr_dados.corsus,
                            lr_dados.cornom,
                            lr_dados.cntanvdat,
                            lr_dados.incdat,
                            lr_dados.excdat
    if sqlca.sqlcode = 0 then
       let l_status = 1
    else
      if sqlca.sqlcode = notfound then
        initialize lr_dados.* to null
        let l_status = 2
      else
        let l_status = 3
        let l_msg    = "Erro SELECT c_cta01m15_002 /",
                          sqlca.sqlcode, "/",
                          sqlca.sqlerrd[2]
      end if
    end if
  { whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        initialize lr_dados.* to null
        let l_status = 2
     else
        let l_status = 3
        let l_msg    = "Erro SELECT c_cta01m15_002 /",
                       sqlca.sqlcode, "/",
                       sqlca.sqlerrd[2]
     end if
  end if}
  whenever error stop
  close c_cta01m15_002

  return l_status,
         l_msg,
         lr_dados.succod,
         lr_dados.ramcod,
         lr_dados.aplnumdig,
         lr_dados.crtsaunum,
         lr_dados.crtstt,
         lr_dados.plncod,
         lr_dados.segnom,
         lr_dados.cgccpfnum,
         lr_dados.cgcord,
         lr_dados.cgccpfdig,
         lr_dados.empnom,
         lr_dados.corsus,
         lr_dados.cornom,
         lr_dados.cntanvdat

end function

#--------------------------------------------#
function cta01m15_ins_datksegsau(lr_parametro)
#--------------------------------------------#

  define lr_parametro record
         succod       like datksegsau.succod,
         ramcod       like datksegsau.ramcod,
         aplnumdig    like datksegsau.aplnumdig,
         crtsaunum    like datksegsau.crtsaunum,
         crtstt       like datksegsau.crtstt,
         plncod       like datksegsau.plncod,
         segnom       like datksegsau.segnom,
         cgccpfnum    like datksegsau.cgccpfnum,
         cgcord       like datksegsau.cgcord,
         cgccpfdig    like datksegsau.cgccpfdig,
         empnom       like datksegsau.empnom,
         corsus       like datksegsau.corsus,
         cornom       like datksegsau.cornom,
         cntanvdat    like datksegsau.cntanvdat,
         bnfnum       like datksegsau.bnfnum,
         incdat       like datksegsau.incdat
  end record

  define l_status smallint,
         l_msg    char(200)  # 1 - OK    2 - ERRO

  if m_cta01m15_prep is null or
     m_cta01m15_prep <> true then
     call cta01m15_prepare()
  end if

  let l_status = 0
  let l_msg    = null

  whenever error continue
  execute p_cta01m15_002 using lr_parametro.succod,
                             lr_parametro.ramcod,
                             lr_parametro.aplnumdig,
                             lr_parametro.crtsaunum,
                             lr_parametro.crtstt,
                             lr_parametro.plncod,
                             lr_parametro.segnom,
                             lr_parametro.cgccpfnum,
                             lr_parametro.cgcord,
                             lr_parametro.cgccpfdig,
                             lr_parametro.empnom,
                             lr_parametro.corsus,
                             lr_parametro.cornom,
                             lr_parametro.cntanvdat,
                             lr_parametro.bnfnum,
                             lr_parametro.incdat
  whenever error stop

  if sqlca.sqlcode = 0 then
     let l_status = 1
  else
     let l_status = 2
     let l_msg    = "Erro INSERT p_cta01m15_002 /",
                    sqlca.sqlcode, "/",
                    sqlca.sqlerrd[2], "/",
                    "Beneficio: ",
                    lr_parametro.bnfnum clipped, "/",
                    "Cartao: ",
                    lr_parametro.crtsaunum
     call errorlog(l_msg)
  end if

  return l_status,
         l_msg

end function

#--------------------------------------------#
function cta01m15_upd_datksegsau(lr_parametro)
#--------------------------------------------#

  define lr_parametro record
         succod       like datksegsau.succod,
         ramcod       like datksegsau.ramcod,
         aplnumdig    like datksegsau.aplnumdig,
         crtsaunum    like datksegsau.crtsaunum,
         crtstt       like datksegsau.crtstt,
         plncod       like datksegsau.plncod,
         segnom       like datksegsau.segnom,
         cgccpfnum    like datksegsau.cgccpfnum,
         cgcord       like datksegsau.cgcord,
         cgccpfdig    like datksegsau.cgccpfdig,
         empnom       like datksegsau.empnom,
         corsus       like datksegsau.corsus,
         cornom       like datksegsau.cornom,
         cntanvdat    like datksegsau.cntanvdat,
         bnfnum       like datksegsau.bnfnum,
         excdat       like datksegsau.excdat
  end record

  define l_status  smallint,
         l_msg     char(200) # 1 - OK    2 - ERRO

  if m_cta01m15_prep is null or
     m_cta01m15_prep <> true then
     call cta01m15_prepare()
  end if

  let l_status  = 0
  let l_msg     = null

  whenever error continue
  execute p_cta01m15_003 using lr_parametro.succod,
                               lr_parametro.ramcod,
                               lr_parametro.aplnumdig,
                               lr_parametro.crtstt,
                               lr_parametro.plncod,
                               lr_parametro.segnom,
                               lr_parametro.cgccpfnum,
                               lr_parametro.cgcord,
                               lr_parametro.cgccpfdig,
                               lr_parametro.empnom,
                               lr_parametro.corsus,
                               lr_parametro.cornom,
                               lr_parametro.cntanvdat,
                               lr_parametro.excdat,
                               lr_parametro.bnfnum,
                               lr_parametro.crtsaunum
  whenever error stop

  if sqlca.sqlcode = 0 then
    let l_status = 1
  else
     let l_status = 2
     let l_msg    = "Erro UPDATE p_cta01m15_003 /",
                    sqlca.sqlcode, "/",
                    sqlca.sqlerrd[2], "/",
                    "Beneficio: ",
                    lr_parametro.bnfnum clipped, "/",
                    "Cartao: ",
                    lr_parametro.crtsaunum
  end if

  return l_status,
         l_msg

end function
