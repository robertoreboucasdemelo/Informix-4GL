#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Macro/Sistema..: Central24h / Pso_ct24h / Cadastro de Prestadores           #
# Modulo.........: ctc00m24.4gl                                               #
# Analista Resp..: Sergio Burini                                              # 
# Objetivo.......: Funcoes auxiliares Ordem Pagamento de Prestadores          #
#                                                                             #
# ........................................................................... #
# Desenvolvimento: Jose Kurihara/CDS Baltico                                  #
# Liberacao......: 22/05/2012 - PSI-2011-19199-PR Prestador Optante Simples   #
# ........................................................................... #
#                 * * * Alteracoes Ordem Decrescente * * *                    #
#                                                                             #
# Data        Autor          PSI / CT  Alteracao                              #
# ----------  -------------- --------- -------------------------------------- #
#                                                                             #
#                                                                             #
#                                                                             #
#-----------------------------------------------------------------------------#
database porto

 define m_preppristt  smallint
 define m_msg         char(200)

#------------------------------------------------------------
 function ctc00m24_prepare()
#------------------------------------------------------------

 define l_sql       char(1000)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let l_sql = null
 let m_msg = null

 let m_preppristt = false

 #--> Preparar pesquisa lista da iddkdominio

 let l_sql = "select iddkdominio.cpocod "
             ,"     ,iddkdominio.cpodes "
             ," from iddkdominio "
            ," where iddkdominio.cponom = ? "
             ," order by 1 "

 whenever error continue
    prepare pctc00m24000 from l_sql
    declare cctc00m24000 cursor for pctc00m24000
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro DECLARE cctc00m24000 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc00m24_prepare()"
    return m_preppristt
 end if

 #--> Preparar pesquisa existencia de Aceite Termo Opcao Simples

 let l_sql = "select dbsmhstprs.dbsseqcod "
             ," from dbsmhstprs "
            ," where dbsmhstprs.pstcoddig = ? "
            ,"   and dbsmhstprs.prshstdes like '%Optante Simples%' "

 whenever error continue
    prepare pctc00m24001 from l_sql
    declare cctc00m24001 cursor for pctc00m24001
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro DECLARE cctc00m24001 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc00m24_prepare()"
    return m_preppristt
 end if

 #--> Preparar pesquisa iddkdominio

 let l_sql = "select iddkdominio.cpodes "
             ," from iddkdominio "
            ," where iddkdominio.cponom = ? "
              ," and iddkdominio.cpocod = ? "

 whenever error continue
    prepare pctc00m24002 from l_sql
    declare cctc00m24002 cursor for pctc00m24002
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro DECLARE cctc00m24002 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc00m24_prepare()"
    return m_preppristt
 end if

 #--> Preparar regravacao do cadastro de prestador

 let l_sql = " update dpaksocor "
               ," set simoptpstflg = ? "
               ,"   , atldat       = today "
             ," where pstcoddig    = ? "

 whenever error continue
    prepare pctc00m24003 from l_sql
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro PREPARE pctc00m24003 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc00m24_prepare()"
    return m_preppristt
 end if

 #--> Preparar pesquisa ultima sequencia historico

 let l_sql = " select max(dbsmhstprs.dbsseqcod) "
            ,"   from dbsmhstprs "
            ,"  where dbsmhstprs.pstcoddig = ? "

 whenever error continue
    prepare pctc00m24004 from l_sql
    declare cctc00m24004 cursor for pctc00m24004
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro DECLARE cctc00m24004 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc00m24_prepare()"
    return m_preppristt
 end if

 #--> Preparar gravacao historico do prestador

 let l_sql = " insert into dbsmhstprs "    # historico prestador
                ,"  ( dbsseqcod  "
                ,"  , pstcoddig  "
                ,"  , prshstdes  "
                ,"  , caddat     "
                ,"  , cademp     "
                ,"  , cadusrtip  "
                ,"  , cadmat   ) "
          ," values (?,?,?,today,?,?,? ) "

 whenever error continue
    prepare pctc00m24005 from l_sql
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro PREPARE pctc00m24005 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc00m24_prepare()"
    return m_preppristt
 end if

 #--> Preparar regravacao da Ordem Pagto Prestador

 let l_sql = " update dbsmopg "     # Mov. de O.P do porto socorro
              ,"  set infissalqvlr = ? "
              ,"    , atldat       = today "
              ,"  where socopgnum  = ? "

 whenever error continue
    prepare pctc00m24006 from l_sql
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro PREPARE pctc00m24006 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc00m24_prepare()"
    return m_preppristt
 end if

 #--> Preparar pesquisa ultima sequencia historico OP

 let l_sql = " select max(dbsmopgobs.socopgobsseq) "
            ,"   from dbsmopgobs "
            ,"  where dbsmopgobs.socopgnum = ? "

 whenever error continue
    prepare pctc00m24007 from l_sql
    declare cctc00m24007 cursor for pctc00m24007
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro DECLARE cctc00m24007 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc00m24_prepare()"
    return m_preppristt
 end if

 #--> Preparar gravacao historico da Ordem Pagto 

 let l_sql = " insert into dbsmopgobs "    # historico OP
                ,"  ( socopgnum     "
                ,"  , socopgobsseq  "
                ,"  , socopgobs   ) "
          ," values (?,?,? ) "

 whenever error continue
    prepare pctc00m24008 from l_sql
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro PREPARE pctc00m24008 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc00m24_prepare()"
    return m_preppristt
 end if

 #--> Preparar pesquisa iddkdominio pela descricao

 let l_sql = "select iddkdominio.cpocod "
             ," from iddkdominio "
            ," where iddkdominio.cponom = ? "
              ," and iddkdominio.cpodes = ? "

 whenever error continue
    prepare pctc00m24009 from l_sql
    declare cctc00m24009 cursor for pctc00m24009
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro DECLARE cctc00m24009 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc00m24_prepare()"
    return m_preppristt
 end if

 let m_preppristt = true

 return m_preppristt

 end function  #--> ctc00m24_prepare()

#------------------------------------------------------------
# Objetivo: Retornar lista de Cod/Descricao de um Dominio
#------------------------------------------------------------
 function ctc00m24_obterListaDominio( lr_par_in )

 define lr_par_in     record
    cponom            like iddkdominio.cponom,
    acao              smallint                  # 0-Open 1-Next
 end record

 define lr_par_out    record
    codres            smallint,              # 0 = OK, 1 = err, 2 = notfound
    msgerr            char(100),
    cpodes            like iddkdominio.cpodes,
    cpocod            like iddkdominio.cpocod
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.* to null

 if (m_preppristt is null or m_preppristt = false) then
    if not ctc00m24_prepare() then
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = m_msg
       return lr_par_out.*
    end if
    let lr_par_in.acao = 0
 end if

 if lr_par_in.acao = 0 then
    open cctc00m24000 using lr_par_in.cponom
 end if
 whenever error continue
    fetch cctc00m24000 into lr_par_out.cpocod
                          , lr_par_out.cpodes
 whenever error stop
 if sqlca.sqlcode = 0 then
    let lr_par_out.codres = 0
 else
    if sqlca.sqlcode = NOTFOUND then
       let lr_par_out.codres = 2
       close cctc00m24000
    else
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = "Erro SELECT cctc00m24000, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&",  " ctc00m24_obterListaDominio()"
       close cctc00m24000
    end if
 end if

 return lr_par_out.*

 end function  #--> ctc00m24_obterListaDominio()


#-------------------------------------------------------------
# Objetivo: Verificar se o Prestador leu Termo Optante Simples
#-------------------------------------------------------------
 function ctc00m24_leuTermoOptante( lr_par_in )

 define lr_par_in     record
    pstcoddig         like dbsmhstprs.pstcoddig
 end record

 define lr_par_out    record
    codres            smallint,              # 0 = OK, 1 = err, 2 = notfound
    msgerr            char(100)
 end record

 define l_dbsseqcod   like dbsmhstprs.dbsseqcod

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.* to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let l_dbsseqcod = null

 if (m_preppristt is null or m_preppristt = false) then
    if not ctc00m24_prepare() then
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = m_msg
       return lr_par_out.*
    end if
 end if

 open cctc00m24001 using lr_par_in.pstcoddig
 whenever error continue
    fetch cctc00m24001 into l_dbsseqcod

 whenever error stop
 if sqlca.sqlcode = 0 then
    let lr_par_out.codres = 0
 else
    if sqlca.sqlcode = NOTFOUND then
       let lr_par_out.codres = 2
    else
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = "Erro SELECT cctc00m24001, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&",  " ctc00m24_leuTermoOptante()"
    end if
 end if
 close cctc00m24001

 return lr_par_out.*

 end function  #--> ctc00m24_leuTermoOptante()

#-----------------------------------------------------------------------
# Objetivo: metodo generico retornar descricao tabela dominio
#-----------------------------------------------------------------------
 function ctc00m24_obterDescIddkDominio( lr_par_in )

 define lr_par_in     record
    cponom            like iddkdominio.cponom,
    cpocod            like iddkdominio.cpocod
 end record

 define lr_par_out    record
    codres            smallint,              # 0 = OK, 1 = err, 2 = notfound
    msgerr            char(100),
    cpodes            like iddkdominio.cpodes
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.* to null

 if (m_preppristt is null or m_preppristt = false) then
    if not ctc00m24_prepare() then
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = m_msg
       return lr_par_out.*
    end if
 end if

 open cctc00m24002 using lr_par_in.cponom
                       , lr_par_in.cpocod
 whenever error continue
    fetch cctc00m24002 into lr_par_out.cpodes
 whenever error stop
 if sqlca.sqlcode = 0 then
    let lr_par_out.codres = 0
 else
    if sqlca.sqlcode = NOTFOUND then
       let lr_par_out.codres = 2
    else
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = "Erro SELECT cctc00m24002, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&",  " ctc00m24_obterDescIddkDominio()"
    end if
 end if
 close cctc00m24002

 return lr_par_out.*

 end function  #--> ctc00m24_obterDescIddkDominio()

#-----------------------------------------------------------------------
# Objetivo: alterar a flag de optante simples no cad prestador
#-----------------------------------------------------------------------
 function ctc00m24_alterarOptantePrest( lr_par_in )

 define lr_par_in     record
    pstcoddig         like dpaksocor.pstcoddig,
    simoptpstflg      like dpaksocor.simoptpstflg,
    empcod            like isskfunc.empcod,
    usrtip            like isskfunc.usrtip,
    funmat            like isskfunc.funmat
 end record

 define lr_par_out    record
    codres            smallint,              # 0 = OK, 1 = err, 2 = notfound
    msgerr            char(100)
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.* to null

 if (m_preppristt is null or m_preppristt = false) then
    if not ctc00m24_prepare() then
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = m_msg
       return lr_par_out.*
    end if
 end if

 whenever error continue
    execute pctc00m24003 using lr_par_in.simoptpstflg
                             , lr_par_in.pstcoddig
 whenever error stop
 if sqlca.sqlcode = 0 then
    if sqlca.sqlerrd[3] = 1 then
       let lr_par_out.codres = 0
    else
       let lr_par_out.codres = 2
       let lr_par_out.msgerr = "Prestador nao encontrado"
    end if
 else
    let lr_par_out.codres = 1
    let lr_par_out.msgerr = "Erro UPDATE pctc00m24003, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&",  " ctc00m24_alterarOptantePrest()"
 end if

 return lr_par_out.*

 end function  #--> ctc00m24_alterarOptantePrest()

#-----------------------------------------------------------------------
# Objetivo: registrar historico do prestador
#-----------------------------------------------------------------------
 function ctc00m24_logarHistoricoPrest( lr_par_in )

 define lr_par_in     record
    pstcoddig         like dbsmhstprs.pstcoddig,
    prshstdes         like dbsmhstprs.prshstdes,
    empcod            like isskfunc.empcod,
    usrtip            like isskfunc.usrtip,
    funmat            like isskfunc.funmat,
    funnom            like isskfunc.funnom
 end record

 define lr_par_out    record
    codres            smallint,              # 0 = OK, 1 = err, 2 = notfound
    msgerr            char(100),
    dbsseqcod         like dbsmhstprs.dbsseqcod
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.* to null

 if (m_preppristt is null or m_preppristt = false) then
    if not ctc00m24_prepare() then
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = m_msg
       return lr_par_out.*
    end if
 end if

 #--> Obter proxima sequencia
 #
 open cctc00m24004 using lr_par_in.pstcoddig
 whenever error continue
    fetch cctc00m24004 into lr_par_out.dbsseqcod
 whenever error stop
 if sqlca.sqlcode = 0 then
    if lr_par_out.dbsseqcod is null then
       let lr_par_out.dbsseqcod = 0
    end if
 else
    if sqlca.sqlcode = NOTFOUND then
       let lr_par_out.dbsseqcod = 0
    else
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = "Erro SELECT cctc00m24004, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&",  " ctc00m24_logarHistoricoPrest()"
    end if
 end if
 close cctc00m24004

 if lr_par_out.codres is null then

    let lr_par_out.dbsseqcod = lr_par_out.dbsseqcod + 1

    whenever error continue
       execute pctc00m24005 using lr_par_out.dbsseqcod
                                , lr_par_in.pstcoddig
                                , lr_par_in.prshstdes
                                , lr_par_in.empcod
                                , lr_par_in.usrtip
                                , lr_par_in.funmat
    whenever error stop
    if sqlca.sqlcode = 0 then
       let lr_par_out.codres = 0
    else
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = "Erro UPDATE pctc00m24005, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&",  " ctc00m24_logarHistoricoPrest()"
    end if
 end if

 return lr_par_out.*

 end function  #--> ctc00m24_logarHistoricoPrest()


#-----------------------------------------------------------------------
# Objetivo: alterar a aliquota do ISS para a OP
#-----------------------------------------------------------------------
 function ctc00m24_alterarAliqIssOrdPg( lr_par_in )

 define lr_par_in     record
    socopgnum         like dbsmopg.socopgnum,
    infissalqvlr      like dbsmopg.infissalqvlr,
    empcod            like isskfunc.empcod,
    usrtip            like isskfunc.usrtip,
    funmat            like isskfunc.funmat
 end record

 define lr_par_out    record
    codres            smallint,              # 0 = OK, 1 = err, 2 = notfound
    msgerr            char(100)
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.* to null

 if (m_preppristt is null or m_preppristt = false) then
    if not ctc00m24_prepare() then
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = m_msg
       return lr_par_out.*
    end if
 end if

 whenever error continue
    execute pctc00m24006 using lr_par_in.infissalqvlr
                             , lr_par_in.socopgnum
 whenever error stop
 if sqlca.sqlcode = 0 then
    if sqlca.sqlerrd[3] = 1 then
       let lr_par_out.codres = 0
    else
       let lr_par_out.codres = 2
       let lr_par_out.msgerr = "Ordem de Pagamento nao encontrado"
    end if
 else
    let lr_par_out.codres = 1
    let lr_par_out.msgerr = "Erro UPDATE pctc00m24006, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&",  " ctc00m24_alterarAliqIssOrdPg()"
 end if

 return lr_par_out.*

 end function  #--> ctc00m24_alterarAliqIssOrdPg()


#-----------------------------------------------------------------------
# Objetivo: registrar historico da Ordem de Pagamento
#-----------------------------------------------------------------------
 function ctc00m24_logarHistoricoOrdPg( lr_par_in )

 define lr_par_in     record
    socopgnum         like dbsmopgobs.socopgnum,
    socopgobs         like dbsmopgobs.socopgobs,
    empcod            like isskfunc.empcod,
    usrtip            like isskfunc.usrtip,
    funmat            like isskfunc.funmat,
    funnom            like isskfunc.funnom
 end record

 define lr_par_out    record
    codres            smallint,              # 0 = OK, 1 = err, 2 = notfound
    msgerr            char(100),
    socopgobsseq      like dbsmopgobs.socopgobsseq
 end record

 define la_hst        array[2] of like dbsmopgobs.socopgobs
 define l_oco         smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.* to null
 initialize la_hst       to null

 let l_oco = null

 if (m_preppristt is null or m_preppristt = false) then
    if not ctc00m24_prepare() then
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = m_msg
       return lr_par_out.*
    end if
 end if

 #--> Obter proxima sequencia
 #
 open cctc00m24007 using lr_par_in.socopgnum
 whenever error continue
    fetch cctc00m24007 into lr_par_out.socopgobsseq
 whenever error stop
 if sqlca.sqlcode = 0 then
    if lr_par_out.socopgobsseq is null then
       let lr_par_out.socopgobsseq = 0
    end if
 else
    if sqlca.sqlcode = NOTFOUND then
       let lr_par_out.socopgobsseq = 0
    else
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = "Erro SELECT cctc00m24007, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&",  " ctc00m24_logarHistoricoOrdPg()"
    end if
 end if
 close cctc00m24007

 if lr_par_out.codres is null then

    let la_hst[1] = "Em: ",today using "dd/mm/yyyy"," Por : ", lr_par_in.funnom
    let la_hst[2] = lr_par_in.socopgobs

    for l_oco = 1 to 2
       let lr_par_out.socopgobsseq = lr_par_out.socopgobsseq + 1
       whenever error continue
          execute pctc00m24008 using lr_par_in.socopgnum
                                   , lr_par_out.socopgobsseq
                                   , la_hst[l_oco]
       whenever error stop
       if sqlca.sqlcode = 0 then
          let lr_par_out.codres = 0
       else
          let lr_par_out.codres = 1
          let lr_par_out.msgerr = "Erro UPDATE pctc00m24008, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&",  " ctc00m24_logarHistoricoOrdPg()"
          exit for
       end if
    end for
 end if

 return lr_par_out.*

 end function  #--> ctc00m24_logarHistoricoOrdPg()


#-----------------------------------------------------------------------
# Objetivo: metodo retornar codigo tabela dominio de uma descricao
#-----------------------------------------------------------------------
 function ctc00m24_obterCodIddkDominio( lr_par_in )

 define lr_par_in     record
    cponom            like iddkdominio.cponom,
    cpodes            like iddkdominio.cpodes
 end record

 define lr_par_out    record
    codres            smallint,              # 0 = OK, 1 = err, 2 = notfound
    msgerr            char(100),
    cpocod            like iddkdominio.cpocod
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.* to null

 if (m_preppristt is null or m_preppristt = false) then
    if not ctc00m24_prepare() then
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = m_msg
       return lr_par_out.*
    end if
 end if

 open cctc00m24009 using lr_par_in.cponom
                       , lr_par_in.cpodes
 whenever error continue
    fetch cctc00m24009 into lr_par_out.cpocod
 whenever error stop
 if sqlca.sqlcode = 0 then
    let lr_par_out.codres = 0
 else
    if sqlca.sqlcode = NOTFOUND then
       let lr_par_out.codres = 2
    else
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = "Erro SELECT cctc00m24009, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&",  " ctc00m24_obterCodIddkDominio()"
    end if
 end if
 close cctc00m24009

 return lr_par_out.*

 end function  #--> ctc00m24_obterCodIddkDominio()


#-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-
