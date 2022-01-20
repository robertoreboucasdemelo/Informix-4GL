#-----------------------------------------------------------------------------#
#                      PORTO SEGURO CIA DE SEGUROS GERAIS                     #
#.............................................................................#
#                                                                             #
#  Modulo              : cts00g05                                             #
#  Analista Responsavel: Raji Jahchan                                         #
#  PSI/OSF             : 166480/19372 - Funcoes Ponto a Ponto.                #
#                                                                             #
#.............................................................................#
#                                                                             #
#  Desenvolvimento     : Fabrica de Software - Gustavo Bayarri                #
#  Data                : 27/05/2003                                           #
#-----------------------------------------------------------------------------#
#                  * * *  ALTERACOES  * * *                                   #  
#                                                                             #  
# Data       Autor Fabrica PSI       Alteracao                                #  
# --------   ------------- ------    -----------------------------------------#  
# 08/08/2006 Andrei, Meta  AS112372  Migracao de versao do 4GL                #  
#-----------------------------------------------------------------------------#  

database porto

define m_comando    char(1500)
      ,m_log        char(1000)
      ,m_prep_pst   char(01)
      ,m_prep_qth   char(01)

#----------------------------------------------
function cts00g05_prepare_pst()
#----------------------------------------------

  let m_comando = null

  let m_comando = "select caddat, cadhor,       "
                 ,"mdtbotprgseq, mdtcod         "
                 ,"from datmmdtmvt              "
                 ,"where mdtbotprgseq in(8,11)  "
                 ,"  and mdtmvtstt = 2          "
                 ,"  and caddat between ? and ? "
                 ,"order by 1,2                 "

  prepare pcts00g05001 from m_comando
  declare ccts00g05001 cursor for pcts00g05001

  let m_comando = "select rowid                 "
                 ,"from datkveiculo             "
                 ,"where mdtcod    = ?          "
                 ,"  and pstcoddig = ?          "

  prepare pcts00g05002 from m_comando
  declare ccts00g05002 cursor for pcts00g05002

end function

#----------------------------------------------
function cts00g05_prepare_qth()
#----------------------------------------------

  let m_comando = null

  let m_comando = "select lclltt, lcllgt  "
                 ,"from datmlcl           "
                 ,"where atdsrvnum = ?    "
                 ,"  and atdsrvano = ?    "
                 ,"  and c24endtip = 1    "

  prepare pcts00g05003 from m_comando
  declare ccts00g05003 cursor for pcts00g05003

  let m_comando = "select lclltt, lcllgt  "
                 ,"from datmmdtmvt        "
                 ,"where atdsrvnum    = ? "
                 ,"  and atdsrvano    = ? "
                 ,"  and mdtbotprgseq = 2 "

  prepare pcts00g05004 from m_comando
  declare ccts00g05004 cursor for pcts00g05004

end function

#-----------------------------------------------------------------------------
# Acumula tempo que o prestador esta' em servico QRA(mdtbotprgseq=8) ate'  QTP
# (mdtbotprgseq=11) no periodo passado como parametro.
#-----------------------------------------------------------------------------

#--------------------------------------
function cts00g05_pstnoar(l_param)
#--------------------------------------
 
  define l_param      record
         pstcoddig    decimal(6,0)
        ,dt_inicial   date
        ,dt_final     date
  end record

  define l_datmmdtmvt record
         caddat       like datmmdtmvt.caddat
        ,cadhor       like datmmdtmvt.cadhor
        ,mdtbotprgseq like datmmdtmvt.mdtbotprgseq
        ,mdtcod       like datmmdtmvt.mdtcod
  end record

  define l_conv_data  datetime year to day
        ,l_aux_conv   char(19)
        ,l_conversao  datetime year to second
        ,l_qra        datetime year to second
        ,l_qtp        datetime year to second
        ,l_flg_qra    char(01)
        ,l_flg_qtp    char(01)
        ,l_tmpdsp     interval hour(4) to minute
        ,l_hr_char    char(10)
        ,l_hr_dec     decimal(07,02)
        ,l_hr_int     integer
        ,l_hr_1_dec   decimal(07,02)
        ,l_ret_tmp    decimal(07,02)

  if m_prep_pst is null then
     call cts00g05_prepare_pst()
     let m_prep_pst = "S"
  end if

  initialize l_datmmdtmvt.* to null
  let l_flg_qra = null
  let l_flg_qtp = null
  let l_ret_tmp = 0
  open    ccts00g05001 using l_param.dt_inicial
                            ,l_param.dt_final

  foreach ccts00g05001 into  l_datmmdtmvt.caddat
                            ,l_datmmdtmvt.cadhor
                            ,l_datmmdtmvt.mdtbotprgseq
                            ,l_datmmdtmvt.mdtcod

     open  ccts00g05002 using l_datmmdtmvt.mdtcod
                             ,l_param.pstcoddig
     whenever error continue
     fetch ccts00g05002
     whenever error stop

     if sqlca.sqlcode    <> 0 then
        if sqlca.sqlcode <  0 then
           let m_log = null
           let m_log = '** Programa - cts00g05 '
                      ,'** Erro no cursor CCTS00G05002'
                      ,'   Sqlcode = ', sqlca.sqlcode using '-<<<<<&'
           call errorlog(m_log)
           close ccts00g05002
           exit program(1)
        end if
        continue foreach
        close ccts00g05002
     end if
     close ccts00g05002

     let l_conv_data = null
     let l_aux_conv  = null
     let l_conversao = null

     let l_conv_data = l_datmmdtmvt.caddat
     let l_aux_conv  = l_conv_data
                      ," "
                      ,l_datmmdtmvt.cadhor

     let l_conversao = l_aux_conv

     if l_datmmdtmvt.mdtbotprgseq = 8 then
        if l_flg_qra     is null then
           let l_qra     = null
           let l_qra     = l_conversao
           let l_flg_qra = 'A'
        end if
     end if

     if l_flg_qra is not null          and
        l_datmmdtmvt.mdtbotprgseq = 11 then
        if l_flg_qtp     is null then
           let l_qtp     = null
           let l_qtp     = l_conversao
           let l_flg_qtp = 'P'
        end if
     end if

     let l_tmpdsp     = null
     let l_hr_char    = null
     let l_hr_dec     = 0
     let l_hr_int     = 0
     let l_hr_1_dec   = 0

     if l_flg_qra     = 'A' and
        l_flg_qtp     = 'P' then
        let l_flg_qra = null
        let l_flg_qtp = null

        let l_tmpdsp  = l_qtp - l_qra

        #--------------------------
        # Converte Horas em decimal
        #--------------------------

        let l_hr_char  = l_tmpdsp
        let l_hr_char  = l_hr_char[01,05], l_hr_char[07,08]
        let l_hr_dec   = l_hr_char using "&&&&&&&&&&&&&"
        let l_hr_dec   = l_hr_dec/100
        let l_hr_int   = l_hr_dec
        let l_hr_dec   = (((l_hr_dec - l_hr_int) * 100)/60)
        let l_hr_1_dec = l_hr_int + l_hr_dec

        ### Acumula na variavel
        let l_ret_tmp = l_ret_tmp + l_hr_1_dec

     end if

  end foreach

  return l_ret_tmp

end function

#-----------------------------------------------------------------------------
# Retorna  se  o  servico  estava  no  local  da  ocorrencia  quando iniciou o
# atendimento.
#-----------------------------------------------------------------------------

#--------------------------------------
function cts00g05_qth(l_par)
#--------------------------------------
  
  define l_par        record
         atdsrvnum    decimal(10,0)
        ,atdsrvano    decimal(2,0)
  end record

  define l_srrltt     like datmlcl.lclltt
        ,l_srrlgt     like datmlcl.lcllgt
        ,l_srrlttacn  like datmmdtmvt.lclltt
        ,l_srrlgtacn  like datmmdtmvt.lcllgt
        ,l_distancia  decimal(08,04)
        ,l_ret_qth    char(01)

  if m_prep_qth is null then
     call cts00g05_prepare_qth()
     let m_prep_qth = "S"
  end if

  let l_ret_qth = 'N'

  let l_srrltt  = null
  let l_srrlgt  = null

  #---------------------------------------------------------------
  # Busca latitude e longitude do local da ocorrencia.
  #---------------------------------------------------------------

  open  ccts00g05003 using l_par.atdsrvnum
                          ,l_par.atdsrvano
  whenever error continue
  fetch ccts00g05003 into  l_srrltt
                          ,l_srrlgt
  whenever error stop

  if sqlca.sqlcode    <> 0 then
     if sqlca.sqlcode <  0 then
        let m_log = null
        let m_log = '** Programa - cts00g05 '
                   ,'** Erro no cursor CCTS00G05003'
                   ,'   Sqlcode = ', sqlca.sqlcode using '-<<<<<&'
        call errorlog(m_log)
        close ccts00g05003
        exit program(1)
     end if
     return l_ret_qth
     close ccts00g05003
  end if
  close ccts00g05003

  let l_srrlttacn = null
  let l_srrlgtacn = null

  #---------------------------------------------------------------
  # Busca latitude e longitude do inicio do servico.
  #---------------------------------------------------------------

  open  ccts00g05004 using l_par.atdsrvnum
                          ,l_par.atdsrvano
  whenever error continue
  fetch ccts00g05004 into  l_srrlttacn
                          ,l_srrlgtacn
  whenever error stop

  if sqlca.sqlcode    <> 0 then
     if sqlca.sqlcode <  0 then
        let m_log = null
        let m_log = '** Programa - cts00g05 '
                   ,'** Erro no cursor CCTS00G05004'
                   ,'   Sqlcode = ', sqlca.sqlcode using '-<<<<<&'
        call errorlog(m_log)
        close ccts00g05004
        exit program(1)
     end if
     return l_ret_qth
     close ccts00g05004
  end if
  close ccts00g05004

  #---------------------------------------------------------------
  # Calcula distancia entre prestador no acionamento e segurado
  #---------------------------------------------------------------

  if (l_srrltt    = 0     and l_srrlgt    = 0)     or
     (l_srrltt    is null and l_srrltt    is null) or
     (l_srrlttacn = 0     and l_srrlgtacn = 0)     or
     (l_srrlttacn is null and l_srrlgtacn is null) then
     let l_distancia = 0
  else
     let l_distancia = cts18g00(l_srrltt,    l_srrlgt,
                                l_srrlttacn, l_srrlgtacn)
  end if

  if l_distancia > 0.1 then   #--> Maior que 100 metros
     let l_ret_qth = 'N'
  else
     let l_ret_qth = 'S'
  end if
 
  return l_ret_qth

end function
