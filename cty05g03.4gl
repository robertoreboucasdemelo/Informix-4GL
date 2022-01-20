#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTY05G03                                                   #
# ANALISTA RESP..: LIGIA MARIA MATTGE                                         #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTO.                      #
#                  BUSCA A CATEGORIA TARIFARIA ORIGINAL DO VEICULO.           #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 28/06/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cty05g03_prep smallint

#-------------------------#
function cty05g03_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select rcfctgatu ",
                " from agetdecateg ",
               " where vclcoddig = ? ",
                 " and viginc <= ? ",
                 " and vigfnl >= ? "

  prepare p_cty05g03_001 from l_sql
  declare c_cty05g03_001 cursor for p_cty05g03_001

  let m_cty05g03_prep = true

end function

#-----------------------------------------#
function cty05g03_pesq_catgtf(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         vclcoddig    like agetdecateg.vclcoddig,
         viginc       like itatvig.viginc
  end record

  define l_rcfctgatu  like agetdecateg.rcfctgatu,
         l_msg        char(80),
         l_status     smallint # 0->OK  1->NOTFOUND  2->ERRO DE ACESSO BD


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_rcfctgatu  =  null
        let     l_msg  =  null
        let     l_status  =  null

  if m_cty05g03_prep is null or
     m_cty05g03_prep <> true then
     call cty05g03_prepare()
  end if

  let l_status    = 0

  #------------------------------------------------
  # BUSCA A CATEGORIA TARIFARIA ORIGINAL DO VEICULO
  #------------------------------------------------
  open c_cty05g03_001 using lr_parametro.vclcoddig,
                          lr_parametro.viginc,
                          lr_parametro.viginc
  whenever error continue
  fetch c_cty05g03_001 into l_rcfctgatu
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_rcfctgatu = null
        let l_status    = 1
        let l_msg       = "CTY05G03 - Nao foi encontrada a categoria tarifaria para o veiculo: ",
                          lr_parametro.vclcoddig
        #call errorlog(l_msg)
     else
        let l_status = 2
        let l_msg = "cty05g03/cty05g03_pesq_catgtf() / ", lr_parametro.vclcoddig, "/",
                                                          lr_parametro.viginc
        call errorlog(l_msg)
        let l_msg = "Erro SELECT c_cty05g03_001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        call errorlog(l_msg)
     end if
  end if

  close c_cty05g03_001

  return l_status,
         l_msg,
         l_rcfctgatu

end function
