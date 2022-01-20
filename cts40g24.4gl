#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTS40G24                                                   #
# ANALISTA RESP..: CARLOS A. RUIZ                                             #
# PSI/OSF........: QUANDO EXISTIR NOVOS PLANOS NO SAUDE+CASA REALIZA A INCLUS-#
#                  AO NAS TABELAS DATRRAMCLS E DATRSOCNTZSRVRE.               #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 01/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g24_prep smallint

#-------------------------#
function cts40g24_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select 1 ",
                " from datrramcls ",
               " where ramcod = ? ",
                 " and clscod = ? ",
                 " and rmemdlcod = 0 "

  prepare pcts40g24001 from l_sql
  declare ccts40g24001 cursor for pcts40g24001

  let l_sql = " select 1 ",
                " from datrsocntzsrvre ",
               " where socntzcod = ? ",
                 " and ramcod = ? ",
                 " and clscod = ? ",
                 " and rmemdlcod = 0 "

  prepare pcts40g24002 from l_sql
  declare ccts40g24002 cursor for pcts40g24002

  let l_sql = " insert into datrramcls ",
                         " (ramcod, ",
                          " clscod, ",
                          " clsatdqtd, ",
                          " rmemdlcod) ",
                   " values(?,?,1,0) "

  prepare pcts40g24003 from l_sql

  let l_sql = " insert into datrsocntzsrvre ",
                         " (socntzcod, ",
                          " ramcod, ",
                          " clscod, ",
                          " ntzatdqtd, ",
                          " rmemdlcod, ",
                          " c24pbmgrpcod) ",
                   " values(?,?,?,1,0,?) "

  prepare pcts40g24004 from l_sql

  let m_cts40g24_prep = true

end function

#-----------------------------------------------#
function cts40g24_existe_datrramcls(lr_parametro)
#-----------------------------------------------#

  define lr_parametro record
         ramcod       like datrramcls.ramcod,
         clscod       like datrramcls.clscod
  end record

  define l_existe     smallint,
         l_msg        char(100)

  if m_cts40g24_prep is null or
     m_cts40g24_prep <> true then
     call cts40g24_prepare()
  end if

  let l_existe = true
  let l_msg    = null

  open ccts40g24001 using lr_parametro.ramcod,
                          lr_parametro.clscod
  whenever error continue
  fetch ccts40g24001
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_existe = false
     else
        let l_msg = "Erro SELECT ccts40g24001 / ",
                     sqlca.sqlcode, "/",
                     sqlca.sqlerrd[2]
        call errorlog(l_msg)
     end if
  end if

  close ccts40g24001

  return l_existe

end function

#----------------------------------------------------#
function cts40g24_existe_datrsocntzsrvre(lr_parametro)
#----------------------------------------------------#

  define lr_parametro record
         socntzcod    like datrsocntzsrvre.socntzcod,
         ramcod       like datrsocntzsrvre.ramcod,
         clscod       like datrsocntzsrvre.clscod
  end record

  define l_existe     smallint,
         l_msg        char(100)

  if m_cts40g24_prep is null or
     m_cts40g24_prep <> true then
     call cts40g24_prepare()
  end if

  let l_existe = true
  let l_msg    = null

  open ccts40g24002 using lr_parametro.socntzcod,
                          lr_parametro.ramcod,
                          lr_parametro.clscod
  whenever error continue
  fetch ccts40g24002
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_existe = false
     else
        let l_msg = "Erro SELECT ccts40g24002 / ",
                     sqlca.sqlcode, "/",
                     sqlca.sqlerrd[2]
        call errorlog(l_msg)
     end if
  end if

  close ccts40g24002

  return l_existe

end function

#--------------------------------------------#
function cts40g24_ins_datrramcls(lr_parametro)
#--------------------------------------------#

  define lr_parametro record
         ramcod       like datrramcls.ramcod,
         clscod       like datrramcls.clscod
  end record

  define l_msg        char(200)

  if m_cts40g24_prep is null or
     m_cts40g24_prep <> true then
     call cts40g24_prepare()
  end if

  let l_msg = null

  whenever error continue
  execute pcts40g24003 using lr_parametro.ramcod,
                             lr_parametro.clscod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro INSERT pcts40g24003 / ",
                  sqlca.sqlcode, "/",
                  sqlca.sqlerrd[2], "/",
                  "RAMO: ", lr_parametro.ramcod, "/",
                  "CLSCOD: ", lr_parametro.clscod
     call errorlog(l_msg)
  end if

end function

#-------------------------------------------------#
function cts40g24_ins_datrsocntzsrvre(lr_parametro)
#-------------------------------------------------#

  define lr_parametro record
         socntzcod    like datrsocntzsrvre.socntzcod,
         ramcod       like datrsocntzsrvre.ramcod,
         clscod       like datrsocntzsrvre.clscod,
         c24pbmgrpcod like datrsocntzsrvre.c24pbmgrpcod
  end record

  define l_msg        char(200)

  if m_cts40g24_prep is null or
     m_cts40g24_prep <> true then
     call cts40g24_prepare()
  end if

  let l_msg = null

  whenever error continue
  execute pcts40g24004 using lr_parametro.socntzcod,
                             lr_parametro.ramcod,
                             lr_parametro.clscod,
                             lr_parametro.c24pbmgrpcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro INSERT pcts40g24004 / ",
                  sqlca.sqlcode, "/",
                  sqlca.sqlerrd[2], "/",
                 "SOCNTZCOD: ", lr_parametro.socntzcod, "/",
                 "RAMCOD ", lr_parametro.ramcod, "/",
                 "CLSCOD ", lr_parametro.clscod, "/",
                 "C24PBMGRPCOD ", lr_parametro.c24pbmgrpcod
     call errorlog(l_msg)
  end if

end function

#--------------------------------#
function cts40g24_regras(l_clscod)
#--------------------------------#

  define l_clscod like datrramcls.clscod

  #---------------------------------------------------------
  # VERIFICA SE EXISTE PLANO CADASTRADO NA TABELA DATRRAMCLS
  #---------------------------------------------------------

  # -> RAMO 85
  if not cts40g24_existe_datrramcls(85, l_clscod) then
     call cts40g24_ins_datrramcls(85, l_clscod)
  end if

  # -> RAMO 86
  if not cts40g24_existe_datrramcls(86,l_clscod) then
     call cts40g24_ins_datrramcls(86, l_clscod)
  end if

  # -> RAMO 87
  if not cts40g24_existe_datrramcls(87,l_clscod) then
     call cts40g24_ins_datrramcls(87, l_clscod)
  end if

  #--------------------------------------------------------------
  # VERIFICA SE EXISTE PLANO CADASTRADO NA TABELA DATRSOCNTZSRVRE
  #--------------------------------------------------------------

  # -> RAMO 85
  if not cts40g24_existe_datrsocntzsrvre(1,85,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(1,85,l_clscod,6)
  end if

  if not cts40g24_existe_datrsocntzsrvre(2,85,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(2,85,l_clscod,9)
  end if

  if not cts40g24_existe_datrsocntzsrvre(3,85,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(3,85,l_clscod,10)
  end if

  if not cts40g24_existe_datrsocntzsrvre(5,85,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(5,85,l_clscod,8)
  end if

  if not cts40g24_existe_datrsocntzsrvre(10,85,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(10,85,l_clscod,7)
  end if

  # -> RAMO 86
  if not cts40g24_existe_datrsocntzsrvre(1,86,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(1,86,l_clscod,6)
  end if

  if not cts40g24_existe_datrsocntzsrvre(2,86,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(2,86,l_clscod,9)
  end if

  if not cts40g24_existe_datrsocntzsrvre(3,86,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(3,86,l_clscod,10)
  end if

  if not cts40g24_existe_datrsocntzsrvre(5,86,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(5,86,l_clscod,8)
  end if

  if not cts40g24_existe_datrsocntzsrvre(10,86,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(10,86,l_clscod,7)
  end if

  # -> RAMO 87
  if not cts40g24_existe_datrsocntzsrvre(1,87,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(1,87,l_clscod,6)
  end if

  if not cts40g24_existe_datrsocntzsrvre(2,87,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(2,87,l_clscod,9)
  end if

  if not cts40g24_existe_datrsocntzsrvre(3,87,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(3,87,l_clscod,10)
  end if

  if not cts40g24_existe_datrsocntzsrvre(5,87,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(5,87,l_clscod,8)
  end if

  if not cts40g24_existe_datrsocntzsrvre(10,87,l_clscod) then
     call cts40g24_ins_datrsocntzsrvre(10,87,l_clscod,7)
  end if

end function
                                     