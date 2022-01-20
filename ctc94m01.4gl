#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Macro/Sistema..: Central24h / Cad_PSO - Porto Socorro / Cad Porto Socorro   #
# Modulo.........: ctc94m01.4gl                                               #
# Analista Resp..: Joseli Oliveira                                            #
# Objetivo.......: Manter parametro bloqueio frota irregular por tipo veiculo #
#                                                                             #
# ........................................................................... #
# Desenvolvimento: Jose Kurihara/CDS Baltico                                  #
# Liberacao......: 19/01/2012 - PSI-2011-21476-PR Bloqueio viatura sem seguro #
# ........................................................................... #
#                 * * * Alteracoes Ordem Decrescente * * *                    #
#                                                                             #
# Data        Autor          PSI / CT  Alteracao                              #
# ----------  -------------- --------- -------------------------------------- #
#                                                                             #
#                                                                             #
#                                                                             #
#-----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_preppristt  smallint
 define m_msg         char(200)

#------------------------------------------------------------
 function ctc94m01_prepare()
#------------------------------------------------------------

 define l_sql       char(1000)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let l_sql = null
 let m_msg = null

 let m_preppristt = false

 #--> Preparar pesquisa iddkdominio

 let l_sql = "select iddkdominio.cpodes "
             ," from iddkdominio "
            ," where iddkdominio.cponom = ? "
              ," and iddkdominio.cpocod = ? "

 whenever error continue
    prepare pctc94m01000 from l_sql
    declare cctc94m01000 cursor for pctc94m01000
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro DECLARE cctc94m01000 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc94m01_prepare()"
    return m_preppristt
 end if

 #--> Preparar pesquisa existencia do registro (datksgrirrblqpam)

 let l_sql = "select rowid "
             ," from datksgrirrblqpam "
            ," where datksgrirrblqpam.socvcltip = ? "

 whenever error continue
    prepare pctc94m01001 from l_sql
    declare cctc94m01001 cursor for pctc94m01001
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro DECLARE cctc94m01001 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc94m01_prepare()"
    return m_preppristt
 end if

 #--> Preparar gravacao do parametro bloqueio ( datksgrirrblqpam )

 let l_sql = " insert into datksgrirrblqpam "
                      ," ( socvcltip "
                      ," , csccbtflg "
                      ," , dmavlr "
                      ," , dcpvlr "
                      ," , appvlr "
                      ," , rbcvclensflg "
                      ," , obstxt "
                      ," , atldat "
                      ," , atlfuntip "
                      ," , atlfunemp "
                      ," , atlfunmat ) "
               ," values ( ?,?,?,?,?,?,?,?,?,?, "
                      ,"   ? ) "

 whenever error continue
    prepare pctc94m01002 from l_sql
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro PREPARE pctc94m01002 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc94m01_prepare()"
    return m_preppristt
 end if

 #--> Preparar regravacao do parametro de bloqueio (datksgrirrblqpam)

 let l_sql = " update datksgrirrblqpam "
               ," set csccbtflg    = ? "
                  ,", dmavlr       = ? "
                  ,", dcpvlr       = ? "
                  ,", appvlr       = ? "
                  ,", rbcvclensflg = ? "
                  ,", obstxt       = ? "
                  ,", atldat       = ? "
                  ,", atlfuntip    = ? "
                  ,", atlfunemp    = ? "
                  ,", atlfunmat    = ? "
             ," where socvcltip    = ? "

 whenever error continue
    prepare pctc94m01003 from l_sql
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro PREPARE pctc94m01003 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc94m01_prepare()"
    return m_preppristt
 end if

 #--> Preparar remocao do parametro bloqueio (datksgrirrblqpam)

 let l_sql = " delete from datksgrirrblqpam "
                  ," where socvcltip = ? "

 whenever error continue
    prepare pctc94m01004 from l_sql
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro PREPARE pctc94m01004 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc94m01_prepare()"
    return m_preppristt
 end if

 #--> preparar pesquisa do parametro de bloqueio (datksgrirrblqpam)

 let l_sql = " select datksgrirrblqpam.socvcltip "
                 ," , datksgrirrblqpam.dmavlr "
                 ," , datksgrirrblqpam.dcpvlr "
                 ," , datksgrirrblqpam.appvlr "
                 ," , datksgrirrblqpam.obstxt "
                 ," , datksgrirrblqpam.atldat "
                 ," , datksgrirrblqpam.csccbtflg "
                 ," , datksgrirrblqpam.rbcvclensflg "
                 ," , datksgrirrblqpam.atlfuntip "
                 ," , datksgrirrblqpam.atlfunemp "
                 ," , datksgrirrblqpam.atlfunmat "
              ," from datksgrirrblqpam "
             ," where datksgrirrblqpam.socvcltip = ? "

 whenever error continue
    prepare pctc94m01005 from l_sql
    declare cctc94m01005 cursor for pctc94m01005
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro DECLARE cctc94m01005 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc94m01_prepare()"
    return m_preppristt
 end if

 #--> Preparar pesquisa do proximo tipo veiculo (datksgrirrblqpam)

 let l_sql = " select min(datksgrirrblqpam.socvcltip) "
              ," from datksgrirrblqpam "
             ," where datksgrirrblqpam.socvcltip > ? "

 whenever error continue
    prepare pctc94m01006 from l_sql
    declare cctc94m01006 cursor for pctc94m01006
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro DECLARE cctc94m01006 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc94m01_prepare()"
    return m_preppristt
 end if

 #--> Preparar pesquisa do tipo veiculo anterior (datksgrirrblqpam)

 let l_sql = " select max(datksgrirrblqpam.socvcltip) "
              ," from datksgrirrblqpam "
             ," where datksgrirrblqpam.socvcltip < ? "

 whenever error continue
    prepare pctc94m01007 from l_sql
    declare cctc94m01007 cursor for pctc94m01007
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = "Erro DECLARE cctc94m01007 / ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc94m01_prepare()"
    return m_preppristt
 end if

 let m_preppristt = true

 return m_preppristt

 end function  #--> ctc94m01_prepare()

#------------------------------------------------------------
 function ctc94m01_manterParamBloqTipoVeic()
#------------------------------------------------------------

 define lr_par_key    record
    socvcltip         like datksgrirrblqpam.socvcltip
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_key.*  to null
 let int_flag = false

 if (m_preppristt is null or m_preppristt = false) then
    if not ctc94m01_prepare() then
       error m_msg; sleep 5
       return
    end if
 end if

 if not get_niv_mod(g_issk.prgsgl, "ctc94m01") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window wi_ctc94m01 at 4,2 with form "ctc94m01"

 menu "BLOQUEIO_TIPO_VEICULO"

  before menu
     hide option all
     if g_issk.acsnivcod >= g_issk.acsnivcns  then
        show option "Seleciona", "Proximo", "Anterior"
     end if
     if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "Remove"
     end if

     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa parametro tipo veiculo conforme criterios"
          call ctc94m01_seleciona()  returning lr_par_key.*
          if lr_par_key.socvcltip  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum parametro cadastrado para este tipo de veiculo"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo parametro tipo veiculo selecionado"
          message ""
          call ctc94m01_proximo(lr_par_key.socvcltip)
               returning lr_par_key.*

 command key ("A") "Anterior"
                   "Mostra parametro tipo veiculo anterior selecionado"
          message ""
          if lr_par_key.socvcltip is not null then
             call ctc94m01_anterior(lr_par_key.socvcltip)
                  returning lr_par_key.*
          else
             error " Nenhum tipo de veiculo nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica parametro tipo veiculo corrente selecionado"
          message ""
          if lr_par_key.socvcltip  is not null then
             call ctc94m01_modifica(lr_par_key.socvcltip)
                  returning lr_par_key.*
             next option "Seleciona"
          else
             error " Nenhum tipo de veiculo selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui parametro bloqueio por tipo de veiculo"
          message ""
          call ctc94m01_inclui()
          next option "Seleciona"

   command "Remove" "Remove parametro tipo veiculo corrente selecionado"
            message ""
            if lr_par_key.socvcltip  is not null   then
               call ctc94m01_remove(lr_par_key.socvcltip)
                    returning lr_par_key.*
               next option "Seleciona"
            else
               error " Nenhum tipo de veiculo selecionado!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window wi_ctc94m01
 let int_flag = false

end function  # ctc94m01_manterParamBloqTipoVeic()


#------------------------------------------------------------
 function ctc94m01_seleciona()
#------------------------------------------------------------

 define lr_par_out    record
    socvcltip         like datksgrirrblqpam.socvcltip,
    socvcltipdes      like iddkdominio.cpodes,
    csccbtflg         char(1),
    dmavlr            like datksgrirrblqpam.dmavlr,
    dcpvlr            like datksgrirrblqpam.dcpvlr,
    appvlr            like datksgrirrblqpam.appvlr,
    rbcvclensflg      char(01),
    obstxt            like datksgrirrblqpam.obstxt,
    atldat            like datksgrirrblqpam.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define l_codres      smallint
 define l_msgerr      char(80)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.*  to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let l_codres = null
 let l_msgerr = null

 let int_flag = false
 display by name lr_par_out.*

 input by name lr_par_out.socvcltip

    before field socvcltip
        display by name lr_par_out.socvcltip attribute (reverse)

    after  field socvcltip
        display by name lr_par_out.socvcltip

        if lr_par_out.socvcltip is null or
           lr_par_out.socvcltip  < 1    then
           call cty09g00_popup_iddkdominio( "socvcltip" )
                returning l_codres
                         ,lr_par_out.socvcltip
                         ,lr_par_out.socvcltipdes

           if l_codres <> 1 then
              next field socvcltip
           end if
           display by name lr_par_out.socvcltip
           display by name lr_par_out.socvcltipdes
           exit input
        else
           call ctc94m01_obterDescIddkDominio( "socvcltip"           # cponom
                                              ,lr_par_out.socvcltip) # cpocod
                returning l_codres
                        , l_msgerr
                        , lr_par_out.socvcltipdes
           if l_codres <> 0 then
              if l_codres = 2 then
                 error " Tipo Veiculo nao cadastrado!"
              else
                 error l_msgerr
              end if
              next field socvcltip
           end if
           display by name lr_par_out.socvcltipdes
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize lr_par_out.*   to null
    display by name lr_par_out.*
    error " Operacao cancelada!"
    return lr_par_out.socvcltip
 end if

 call ctc94m01_ler(lr_par_out.socvcltip)
      returning lr_par_out.*

 if lr_par_out.socvcltip is null then
    error " Parametro para Tipo de Veiculo nao cadastrado!"
    initialize lr_par_out.*    to null
 end if

 return lr_par_out.socvcltip

end function  # ctc94m01_seleciona


#------------------------------------------------------------
 function ctc94m01_proximo( lr_par_in )
#------------------------------------------------------------

 define lr_par_in     record
    socvcltip         like datksgrirrblqpam.socvcltip
 end record

 define lr_par_out    record
    socvcltip         like datksgrirrblqpam.socvcltip,
    socvcltipdes      like iddkdominio.cpodes,
    csccbtflg         char(1),
    dmavlr            like datksgrirrblqpam.dmavlr,
    dcpvlr            like datksgrirrblqpam.dcpvlr,
    appvlr            like datksgrirrblqpam.appvlr,
    rbcvclensflg      char(01),
    obstxt            like datksgrirrblqpam.obstxt,
    atldat            like datksgrirrblqpam.atldat,
    atlfunnom         like isskfunc.funnom
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.*   to null

 let int_flag = false

 if lr_par_in.socvcltip is null then
    let lr_par_in.socvcltip = 0
 end if

 open cctc94m01006 using lr_par_in.socvcltip

 whenever error continue
    fetch cctc94m01006 into lr_par_out.socvcltip
 whenever error stop
 if sqlca.sqlcode <> 0 then
    initialize lr_par_out.* to null
 end if
 close cctc94m01006

 if lr_par_out.socvcltip is not null then

    call ctc94m01_ler(lr_par_out.socvcltip)
         returning lr_par_out.*

 end if
 if lr_par_out.socvcltip is null then
    error " Nao ha' parametro bloqueio tipo veiculo nesta direcao!"
    return lr_par_in.socvcltip
 else
    return lr_par_out.socvcltip
 end if

 end function    # ctc94m01_proximo


#------------------------------------------------------------
 function ctc94m01_anterior(lr_par_in)
#------------------------------------------------------------

 define lr_par_in         record
    socvcltip         like datksgrirrblqpam.socvcltip
 end record

 define lr_par_out    record
    socvcltip         like datksgrirrblqpam.socvcltip,
    socvcltipdes      like iddkdominio.cpodes,
    csccbtflg         char(1),
    dmavlr            like datksgrirrblqpam.dmavlr,
    dcpvlr            like datksgrirrblqpam.dcpvlr,
    appvlr            like datksgrirrblqpam.appvlr,
    rbcvclensflg      char(01),
    obstxt            like datksgrirrblqpam.obstxt,
    atldat            like datksgrirrblqpam.atldat,
    atlfunnom         like isskfunc.funnom
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.*   to null

 let int_flag = false

 if lr_par_in.socvcltip  is null   then
    let lr_par_in.socvcltip = 0
 end if

 open cctc94m01007 using lr_par_in.socvcltip

 whenever error continue
    fetch cctc94m01007 into lr_par_out.socvcltip
 whenever error stop
 if sqlca.sqlcode <> 0 then
    initialize lr_par_out.* to null
 end if
 close cctc94m01007

 if lr_par_out.socvcltip is not null then

    call ctc94m01_ler(lr_par_out.socvcltip)
         returning lr_par_out.*

 end if

 if lr_par_out.socvcltip is null then
    error " Nao ha' parametro bloqueio tipo veiculo nesta direcao!"
    return lr_par_in.socvcltip
 else
    return lr_par_out.socvcltip
 end if

 end function    # ctc94m01_anterior


#------------------------------------------------------------
 function ctc94m01_modifica(lr_par_in )
#------------------------------------------------------------

 define lr_par_in      record
    socvcltip          like datksgrirrblqpam.socvcltip
 end record

 define lr_par_out     record
    socvcltip          like datksgrirrblqpam.socvcltip,
    socvcltipdes       like iddkdominio.cpodes,
    csccbtflg          char(1),
    dmavlr             like datksgrirrblqpam.dmavlr,
    dcpvlr             like datksgrirrblqpam.dcpvlr,
    appvlr             like datksgrirrblqpam.appvlr,
    rbcvclensflg       char(01),
    obstxt             like datksgrirrblqpam.obstxt,
    atldat             like datksgrirrblqpam.atldat,
    atlfunnom          like isskfunc.funnom
 end record

 define l_csccbtflg    like datksgrirrblqpam.csccbtflg
 define l_rbcvclensflg like datksgrirrblqpam.rbcvclensflg

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.*   to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let l_csccbtflg    = null
 let l_rbcvclensflg = null

 call ctc94m01_ler(lr_par_in.socvcltip)
      returning lr_par_out.*

 if lr_par_out.socvcltip is null then
    error " Parametro bloqueio tipo veiculo removido!"
    initialize lr_par_out.*    to null
    return lr_par_out.socvcltip
 end if

 call ctc94m01_input("a", lr_par_out.*)
      returning lr_par_out.*

 if int_flag  then
    let int_flag = false
    initialize lr_par_out.*  to null
    display by name lr_par_out.*
    error " Operacao cancelada!"
    return lr_par_out.socvcltip
 end if

 if lr_par_out.csccbtflg = "S" then
    let l_csccbtflg = 1
 else
    let l_csccbtflg = 0
 end if
 if lr_par_out.rbcvclensflg = "S" then
    let l_rbcvclensflg = 1
 else
    let l_rbcvclensflg = 0
 end if

 let lr_par_out.atldat = today

 begin work

 whenever error continue
    execute pctc94m01003 using l_csccbtflg
                             , lr_par_out.dmavlr
                             , lr_par_out.dcpvlr
                             , lr_par_out.appvlr
                             , l_rbcvclensflg
                             , lr_par_out.obstxt
                             , lr_par_out.atldat
                             , g_issk.usrtip
                             , g_issk.empcod
                             , g_issk.funmat
                             , lr_par_out.socvcltip
 whenever error stop
 if sqlca.sqlcode <>  0 then
    let m_msg = "Erro UPDATE pctc94m01003, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " alteracao parametro"
    initialize lr_par_out.*   to null
 else
    if sqlca.sqlerrd[3] = 1 then
       let m_msg = null
    else
       let m_msg = " Erro: nenhum registro foi alterado!"
    end if
 end if
 if m_msg is null then
    error " Alteracao efetuada com sucesso!"
    commit work
 else
    error m_msg
    rollback work
 end if

 message ""
 return lr_par_out.socvcltip

 end function   #  ctc94m01_modifica


#------------------------------------------------------------
 function ctc94m01_inclui()
#------------------------------------------------------------

 define lr_par_out     record
    socvcltip          like datksgrirrblqpam.socvcltip,
    socvcltipdes       like iddkdominio.cpodes,
    csccbtflg          char(1),
    dmavlr             like datksgrirrblqpam.dmavlr,
    dcpvlr             like datksgrirrblqpam.dcpvlr,
    appvlr             like datksgrirrblqpam.appvlr,
    rbcvclensflg       char(01),
    obstxt             like datksgrirrblqpam.obstxt,
    atldat             like datksgrirrblqpam.atldat,
    atlfunnom          like isskfunc.funnom
 end record

 define l_csccbtflg    like datksgrirrblqpam.csccbtflg
 define l_rbcvclensflg like datksgrirrblqpam.rbcvclensflg
 define l_resp         char(01)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.*   to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let l_csccbtflg    = null
 let l_rbcvclensflg = null
 let l_resp         = null


 display by name lr_par_out.*

 call ctc94m01_input("i", lr_par_out.*)
      returning lr_par_out.*

 if int_flag  then
    let int_flag = false
    initialize lr_par_out.*  to null
    display by name lr_par_out.*
    error " Operacao cancelada!"
    return
 end if

 let lr_par_out.atldat = today

 if lr_par_out.csccbtflg = "S" then
    let l_csccbtflg = 1
 else
    let l_csccbtflg = 0
 end if
 if lr_par_out.rbcvclensflg = "S" then
    let l_rbcvclensflg = 1
 else
    let l_rbcvclensflg = 0
 end if

 begin work

 whenever error continue
    execute pctc94m01002 using lr_par_out.socvcltip
                             , l_csccbtflg
                             , lr_par_out.dmavlr
                             , lr_par_out.dcpvlr
                             , lr_par_out.appvlr
                             , l_rbcvclensflg
                             , lr_par_out.obstxt
                             , lr_par_out.atldat
                             , g_issk.usrtip
                             , g_issk.empcod
                             , g_issk.funmat

 whenever error stop
 if sqlca.sqlcode <> 0 then
    let m_msg = " Erro INSERT pctc94m01002, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " incluir parametro "
    error m_msg
    rollback work
    return
 end if

 commit work

 let lr_par_out.atlfunnom = g_issk.funnom

 display by name lr_par_out.atldat
 display by name lr_par_out.atlfunnom

 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char l_resp

 initialize lr_par_out.*  to null
 display by name lr_par_out.*

 end function   #  ctc94m01_inclui


#--------------------------------------------------------------------
 function ctc94m01_input(lr_par_act, lr_par_in)
#--------------------------------------------------------------------

 define lr_par_act     record
    operacao           char (1)
 end record

 define lr_par_in      record
    socvcltip          like datksgrirrblqpam.socvcltip,
    socvcltipdes       like iddkdominio.cpodes,
    csccbtflg          char(1),
    dmavlr             like datksgrirrblqpam.dmavlr,
    dcpvlr             like datksgrirrblqpam.dcpvlr,
    appvlr             like datksgrirrblqpam.appvlr,
    rbcvclensflg       char(01),
    obstxt             like datksgrirrblqpam.obstxt,
    atldat             like datksgrirrblqpam.atldat,
    atlfunnom          like isskfunc.funnom
 end record

 define lr_get         record
    socvcltip          like datksgrirrblqpam.socvcltip,
    socvcltipdes       like iddkdominio.cpodes,
    csccbtflg          char(1),
    dmavlr             like datksgrirrblqpam.dmavlr,
    dcpvlr             like datksgrirrblqpam.dcpvlr,
    appvlr             like datksgrirrblqpam.appvlr,
    rbcvclensflg       char(01),
    obstxt             like datksgrirrblqpam.obstxt,
    atldat             like datksgrirrblqpam.atldat,
    atlfunnom          like isskfunc.funnom
 end record

 define l_codres       smallint
 define l_msgerr       char(80)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_get.*   to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let l_codres = null
 let l_msgerr = null

 let int_flag = false
 let lr_get.* = lr_par_in.*

 input by name lr_get.socvcltip,
               lr_get.csccbtflg,
               lr_get.dmavlr,
               lr_get.dcpvlr,
               lr_get.appvlr,
               lr_get.rbcvclensflg,
               lr_get.obstxt          without defaults

    before field socvcltip
           if lr_par_act.operacao = "a" then
              next field csccbtflg
           end if
           display by name lr_get.socvcltip attribute (reverse)

    after  field socvcltip
           display by name lr_get.socvcltip

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socvcltip
           end if
           if lr_get.socvcltip is null or
              lr_get.socvcltip  < 1    then
              call cty09g00_popup_iddkdominio( "socvcltip" )
                   returning l_codres
                            ,lr_get.socvcltip
                            ,lr_get.socvcltipdes

              if l_codres <> 1 then
                 next field socvcltip
              end if
              display by name lr_get.socvcltip
              display by name lr_get.socvcltipdes
           else
              call ctc94m01_obterDescIddkDominio( "socvcltip"       # cponom
                                                 ,lr_get.socvcltip) # cpocod
                   returning l_codres
                           , l_msgerr
                           , lr_get.socvcltipdes
              if l_codres <> 0 then
                 if l_codres = 2 then
                    error " Tipo Veiculo nao cadastrado!"
                 else
                    error l_msgerr
                 end if
                 next field socvcltip
              end if
              display by name lr_get.socvcltipdes
           end if

           #--> Verificar se ja existe parametro

           open cctc94m01001 using lr_get.socvcltip

           whenever error continue
              fetch cctc94m01001
           whenever error stop
           if sqlca.sqlcode = 0 then
              let m_msg = " Parametro bloqueio tipo veiculo ja' cadastrada!"
           else
              if sqlca.sqlcode = NOTFOUND then
                 let m_msg = null
              else
                 let m_msg = "Erro SELECT cctc94m01001, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " ctc94m01_input()"
              end if
           end if
           close cctc94m01001

           if m_msg is not null then
              error m_msg
              next field socvcltip
           end if

    before field csccbtflg
           display by name lr_get.csccbtflg attribute (reverse)

    after  field csccbtflg
           display by name lr_get.csccbtflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if lr_par_act.operacao = "a" then
                 error " Nao pode alterar o Tipo de Veiculo"
                 next field csccbtflg
              else
                 next field socvcltip
              end if
           end if

           if lr_get.csccbtflg is null or
              lr_get.csccbtflg  = " "  then
              error " Obrigatorio preenchimento!"
              next field csccbtflg
           end if
           if lr_get.csccbtflg <> "S" and
              lr_get.csccbtflg <> "N" then
              error " Cobertura Casco obrigatorio? (S)im ou (N)ao"
              next field csccbtflg
           end if

    before field dmavlr
           display by name lr_get.dmavlr attribute (reverse)

    after  field dmavlr
           display by name lr_get.dmavlr

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field csccbtflg
           end if

           if lr_get.dmavlr is null then
              let lr_get.dmavlr = 0
              display by name lr_get.dmavlr
           end if

    before field dcpvlr
           display by name lr_get.dcpvlr attribute (reverse)

    after  field dcpvlr
           display by name lr_get.dcpvlr

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field dmavlr
           end if

           if lr_get.dcpvlr is null then
              let lr_get.dcpvlr = 0
              display by name lr_get.dcpvlr
           end if

    before field appvlr
           display by name lr_get.appvlr attribute (reverse)

    after  field appvlr
           display by name lr_get.appvlr

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field dcpvlr
           end if

    before field rbcvclensflg
           display by name lr_get.rbcvclensflg attribute (reverse)

    after  field rbcvclensflg
           display by name lr_get.rbcvclensflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field appvlr
           end if

           if lr_get.rbcvclensflg is null or
              lr_get.rbcvclensflg  = " "  then
              error " Obrigatorio preenchimento!"
              next field rbcvclensflg
           end if
           if lr_get.rbcvclensflg <> "S" and
              lr_get.rbcvclensflg <> "N" then
              error " Necessario Clausula 111 (reboque)? (S)im ou (N)ao"
              next field rbcvclensflg
           end if

    before field obstxt
           display by name lr_get.obstxt attribute (reverse)

    after  field obstxt
           display by name lr_get.obstxt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field rbcvclensflg
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    if lr_par_act.operacao = "a" then
       let lr_get.* = lr_par_in.*
    else
       initialize lr_get.*  to null
    end if
 end if

 return lr_get.*

 end function   # ctc94m01_input


#--------------------------------------------------------------------
 function ctc94m01_remove(lr_par_in)
#--------------------------------------------------------------------

 define lr_par_in      record
    socvcltip          like datksgrirrblqpam.socvcltip
 end record

 define lr_par_out     record
    socvcltip          like datksgrirrblqpam.socvcltip,
    socvcltipdes       like iddkdominio.cpodes,
    csccbtflg          char(1),
    dmavlr             like datksgrirrblqpam.dmavlr,
    dcpvlr             like datksgrirrblqpam.dcpvlr,
    appvlr             like datksgrirrblqpam.appvlr,
    rbcvclensflg       char(01),
    obstxt             like datksgrirrblqpam.obstxt,
    atldat             like datksgrirrblqpam.atldat,
    atlfunnom          like isskfunc.funnom
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.*   to null


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o parametro bloqueio para tipo veiculo"
       clear form
       error " Exclusao cancelada!"
       exit menu

    command "Sim" "Exclui o parametro bloqueio para tipo veiculo"
       call ctc94m01_ler(lr_par_in.socvcltip)
            returning lr_par_out.*

       if lr_par_out.socvcltip is null then
          error " Parametro bloqueio tipo veiculo nao localizado!"
       else

          begin work

          whenever error continue
             execute pctc94m01004 using lr_par_in.socvcltip
          whenever error stop

          if sqlca.sqlcode <> 0   then
             let m_msg = "Erro DELETE pctc94m01004, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " excluir parametro"
             rollback work
             error m_msg
          else
             commit work
             initialize lr_par_out.* to null
             error   " Parametro bloqueio tipo veiculo excluido!"
             message ""
             clear form
             exit menu
          end if
       end if
 end menu

 return lr_par_out.socvcltip

end function    # ctc94m01_remove


#---------------------------------------------------------
 function ctc94m01_ler(lr_par_in)
#---------------------------------------------------------

 define lr_par_in     record
    socvcltip         like datksgrirrblqpam.socvcltip
 end record

 define lr_par_out    record
    socvcltip         like datksgrirrblqpam.socvcltip,
    socvcltipdes      like iddkdominio.cpodes,
    csccbtflg         char(01),
    dmavlr            like datksgrirrblqpam.dmavlr,
    dcpvlr            like datksgrirrblqpam.dcpvlr,
    appvlr            like datksgrirrblqpam.appvlr,
    rbcvclensflg      char(01),
    obstxt            like datksgrirrblqpam.obstxt,
    atldat            like datksgrirrblqpam.atldat,
    atlfunnom         like isskfunc.funnom
 end record

 define lr_aux        record
    csccbtflg         like datksgrirrblqpam.csccbtflg,
    rbcvclensflg      like datksgrirrblqpam.rbcvclensflg,
    atlfuntip         like isskfunc.usrtip,
    atlfunemp         like isskfunc.empcod,
    atlfunmat         like isskfunc.funmat
 end record

 define l_codres      smallint
 define l_msgerr      char(80)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize lr_par_out.* to null
 initialize lr_aux.*     to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let l_codres = null
 let l_msgerr = null

 open cctc94m01005 using lr_par_in.socvcltip

 whenever error continue
    fetch cctc94m01005 into lr_par_out.socvcltip
                          , lr_par_out.dmavlr
                          , lr_par_out.dcpvlr
                          , lr_par_out.appvlr
                          , lr_par_out.obstxt
                          , lr_par_out.atldat
                          , lr_aux.csccbtflg
                          , lr_aux.rbcvclensflg
                          , lr_aux.atlfuntip
                          , lr_aux.atlfunemp
                          , lr_aux.atlfunmat
 whenever error stop
 if sqlca.sqlcode = 0 then
    let m_msg = null
 else
    if sqlca.sqlcode = notfound   then
       let m_msg = " Parametro tipo veiculo nao cadastrado!"
    else
       let m_msg = " Erro SELECT cctc94m01005, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&", " pesquisar parametro"
    end if
 end if

 if m_msg is not null then
    error m_msg
    initialize lr_par_out.*    to null
    return lr_par_out.*
 end if

 call ctc94m00_getFunc(lr_aux.atlfunemp, lr_aux.atlfunmat)
      returning lr_par_out.atlfunnom

 if lr_aux.csccbtflg is null or
    lr_aux.csccbtflg  = 0    then
    let lr_par_out.csccbtflg = "N"
 else
    let lr_par_out.csccbtflg = "S"
 end if

 if lr_aux.rbcvclensflg is null or
    lr_aux.rbcvclensflg  = 0    then
    let lr_par_out.rbcvclensflg = "N"
 else
    let lr_par_out.rbcvclensflg = "S"
 end if

 call ctc94m01_obterDescIddkDominio( "socvcltip"           # cponom
                                    ,lr_par_out.socvcltip) # cpocod
      returning l_codres
              , l_msgerr
              , lr_par_out.socvcltipdes

 display by name lr_par_out.*

 return lr_par_out.*

 end function   # ctc94m01_ler

#-----------------------------------------------------------------------
 function ctc94m01_obterDescIddkDominio( lr_par_in )
#-----------------------------------------------------------------------

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

 open cctc94m01000 using lr_par_in.cponom
                       , lr_par_in.cpocod
 whenever error continue
    fetch cctc94m01000 into lr_par_out.cpodes
 whenever error stop
 if sqlca.sqlcode = 0 then
    let lr_par_out.codres = 0
 else
    if sqlca.sqlcode = NOTFOUND then
       let lr_par_out.codres = 2
    else
       let lr_par_out.codres = 1
       let lr_par_out.msgerr = "Erro SELECT cctc94m01000, st ", sqlca.sqlcode using "-<<<<<<<<&", " / ", sqlca.sqlerrd[2] using "-<<<<<<<<&",  " ctc94m01_obterDescIddkDominio()"
    end if
 end if
 close cctc94m01000

 return lr_par_out.*

 end function  #--> ctc94m01_obterDescIddkDominio()


#-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-
