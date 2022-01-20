 ###########################################################################
 # Nome do Modulo: ctc42m00                                        Marcelo #
 #                                                                Gilberto #
 # Cadastro de MDT's                                              Jul/1999 #
 ###########################################################################
 #                                                                         #
 #                  * * * Alteracoes * * *                                 #
 #                                                                         #
 # Data       Autor Fabrica  Origem    Alteracao                           #
 # ---------- -------------- --------- ----------------------------------- #
 # 25/09/2006 Priscila       PSI202290 Remover verificacao nivel de acesso #
 #                                                                         #
 # 25/09/2006 Priscila       PSI225223 Alterar campo 'Configuração' para   #
 #                                     'Equipamento'                       #
 # 27/05/2010 Robert Lima    PSI257206 Inclusao do filtro por sigla veiculo#
 #-------------------------------------------------------------------------#


 database porto

 define m_aux char(50)

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------#
 function ctc42m00_prepare_atdvclsgl()
#---------------------------#
     define l_sql char(1000)

     let l_sql =  " select datkmdt.mdtcod                             ",
                  " from datkmdt ,  datkveiculo               ",
                  " where datkmdt.mdtcod = datkveiculo.mdtcod ",
                  " and datkveiculo.atdvclsgl = ?             "
     prepare p_slgctc42m00001 from l_sql
     declare c_slgctc42m00001 cursor for p_slgctc42m00001
 
     let l_sql = "select datkmdt.mdtcod, ",
                       " datkmdt.mdtctrcod, ",
                       " datkmdt.mdtcfgcod, ",
                       " datkmdt.mdtprgcod, ",
                       " datkmdt.mdtmsggrpcod, ",
                       " datkmdt.mdtstt, ",
                       " datkmdt.caddat, ",
                       " datkmdt.cademp, ",
                       " datkmdt.cadmat, ",
                       " datkmdt.atldat, ",
                       " datkmdt.atlemp, ",
                       " datkmdt.atlmat ",
                  " from datkmdt ,  datkveiculo",
                 " where datkmdt.mdtcod = datkveiculo.mdtcod",
                 "   and datkveiculo.atdvclsgl = ? "

    prepare p_slgctc42m00010 from l_sql
    declare c_slgctc42m00010 cursor for p_slgctc42m00010
        
 end function
#---------------------------#
 function ctc42m00_prepare()
#---------------------------#
     
     define l_sql char(1000)
     
     let l_sql = "select mdtcod ",
                  " from datkmdt ",
                 " where datkmdt.mdtcod = ? "
     
     prepare pctc42m00001 from l_sql
     declare cctc42m00001 cursor for pctc42m00001
     
     let l_sql = "select min(datkmdt.mdtcod) ",
                  " from datkmdt ",
                 " where datkmdt.mdtcod > ? "

     prepare pctc42m00002 from l_sql
     declare cctc42m00002 cursor for pctc42m00002

     let l_sql = "select max(datkmdt.mdtcod) ",
                  " from datkmdt ",
                 " where datkmdt.mdtcod < ? "

     prepare pctc42m00003 from l_sql
     declare cctc42m00003 cursor for pctc42m00003

     let l_sql = "select max(mdtcod) ",
                  " from datkmdt ",
                 " where datkmdt.mdtcod > 0 "

     prepare pctc42m00004 from l_sql
     declare cctc42m00004 cursor for pctc42m00004

     let l_sql = "select mdtctrstt, gpsacngrpcod ",
                  " from datkmdtctr ",
                 " where mdtctrcod  = ? "

     prepare pctc42m00005 from l_sql
     declare cctc42m00005 cursor for pctc42m00005

     let l_sql = "select mdtprgdes, ",
                       " mdtprgstt ",
                  " from datkmdtprg ",
                 " where mdtprgcod = ? "

     prepare pctc42m00006 from l_sql
     declare cctc42m00006 cursor for pctc42m00006

     let l_sql = "select cpodes ",
                  " from iddkdominio ",
                 " where cponom  =  ? ",
                   " and cpocod  =  ? "

     prepare pctc42m00007 from l_sql
     declare cctc42m00007 cursor for pctc42m00007

     let l_sql = "select socvclcod ",
                  " from datkveiculo ",
                 " where datkveiculo.mdtcod = ? "

    prepare pctc42m00008 from l_sql
    declare cctc42m00008 cursor for pctc42m00008

     let l_sql = "select max(mdtmvtseq) ",
                  " from datmmdtmvt ",
                 " where datmmdtmvt.mdtcod = ? "

    prepare pctc42m00009 from l_sql
    declare cctc42m00009 cursor for pctc42m00009

     let l_sql = "select mdtcod, ",
                       " mdtctrcod, ",
                       " mdtcfgcod, ",
                       " mdtprgcod, ",
                       " mdtmsggrpcod, ",
                       " mdtstt, ",
                       " caddat, ",
                       " cademp, ",
                       " cadmat, ",
                       " atldat, ",
                       " atlemp, ",
                       " atlmat ",
                  " from datkmdt ",
                 " where datkmdt.mdtcod = ? "

    prepare pctc42m00010 from l_sql
    declare cctc42m00010 cursor for pctc42m00010

    let l_sql = "select mdtprgdes ",
                 " from datkmdtprg ",
                " where mdtprgcod = ? "

    prepare pctc42m00011 from l_sql
    declare cctc42m00011 cursor for pctc42m00011

    let l_sql = "select atdvclsgl, ",
                      " socvclcod, ",
                      " vclcoddig ",
                 " from datkveiculo ",
                " where mdtcod = ? "

    prepare pctc42m00012 from l_sql
    declare cctc42m00012 cursor for pctc42m00012

    let l_sql = "select vclmrcnom, ",
                      " vcltipnom, ",
                      " vclmdlnom ",
                 " from agbkveic, ",
                " outer agbkmarca, ",
                " outer agbktip ",
                " where agbkveic.vclcoddig  = ? ",
                  " and agbkmarca.vclmrccod = agbkveic.vclmrccod ",
                  " and agbktip.vclmrccod   = agbkveic.vclmrccod ",
                  " and agbktip.vcltipcod   = agbkveic.vcltipcod "

    prepare pctc42m00013 from l_sql
    declare cctc42m00013 cursor for pctc42m00013

    let l_sql = "select funnom ",
                 " from isskfunc ",
                " where isskfunc.empcod = ? ",
                  " and isskfunc.funmat = ? "

    prepare pctc42m00014 from l_sql
    declare cctc42m00014 cursor for pctc42m00014

    let l_sql = "insert into datkmdt(mdtcod, ",
                                   " mdtctrcod, ",
                                   " mdtcfgcod, ",
                                   " mdtprgcod, ",
                                   " mdtmsggrpcod, ",
                                   " mdtstt, ",
                                   " caddat, ",
                                   " cademp, ",
                                   " cadmat, ",
                                   " atldat, ",
                                   " atlemp, ",
                                   " atlmat, ",
                                   " gtwfisenddes ) ",
                           " values (?,?,?,?,?,?,?,?,?,?,?,?, 0)"

    prepare pctc42m00015 from l_sql

    let l_sql = "update datkmdt set (mdtctrcod, ",
                                   " mdtcfgcod, ",
                                   " mdtprgcod, ",
                                   " mdtmsggrpcod, ",
                                   " mdtstt, ",
                                   " atldat, ",
                                   " atlemp, ",
                                   " atlmat) = ",
                                  " (?,?,?,?,?,?,?,?) ",
                             " where mdtcod  =  ? "

    prepare pctc42m00016 from l_sql

    let l_sql = "update dattfrotalocal ",
                  " set gpsacngrpcod = ? ",
                " where socvclcod = ? "

    prepare pctc42m00017 from l_sql

 end function

#------------------------------------------------------------
 function ctc42m00()
#------------------------------------------------------------

 define d_ctc42m00    record
    mdtcod            like datkmdt.mdtcod,
    mdtctrcod         like datkmdt.mdtctrcod,
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdtprgcod         like datkmdt.mdtprgcod,
    mdtprgdes         like datkmdtprg.mdtprgdes,
    mdtmsggrpcod      like datkmdt.mdtmsggrpcod,
    mdtmsggrpdes      char (35),
    mdtsttdes         char (20),
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    mdtstt            like datkmdt.mdtstt,
    caddat            like datkmdt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdt.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod
 end record


 let int_flag = false
 initialize d_ctc42m00.*  to null

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc42m00") then
 #   error " Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 call ctc42m00_prepare()
 call ctc42m00_prepare_atdvclsgl()

 open window ctc42m00 at 4,2 with form "ctc42m00"

 menu "MDTs"

  before menu
     hide option all
     #PSI 202290
     #if g_issk.acsnivcod >= g_issk.acsnivcns  then
     #   show option "Seleciona", "Proximo", "Anterior"
     #end if
     #if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                    "Modifica" , "Inclui" , "Remove"
     #end if

     if  ctc42m01_verifica_usu(g_issk.funmat) then
         show option "SIMCards"
         show option "Con_SinCard"
     end if


     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa MDT conforme criterios"
          call ctc42m00_seleciona()  returning d_ctc42m00.*
          if d_ctc42m00.mdtcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum MDT selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo MDT selecionado"
          message ""
          call ctc42m00_proximo(d_ctc42m00.mdtcod)
               returning d_ctc42m00.*

 command key ("A") "Anterior"
                   "Mostra MDT anterior selecionado"
          message ""
          if d_ctc42m00.mdtcod is not null then
             call ctc42m00_anterior(d_ctc42m00.mdtcod)
                  returning d_ctc42m00.*
          else
             error " Nenhum MDT nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica MDT corrente selecionado"
          message ""
          if d_ctc42m00.mdtcod  is not null then
             call ctc42m00_modifica(d_ctc42m00.mdtcod, d_ctc42m00.*)
                  returning d_ctc42m00.*
             next option "Seleciona"
          else
             error " Nenhum MDT selecionado!"
             next option "Seleciona"
          end if
          initialize d_ctc42m00.*  to null

 command key ("I") "Inclui"
                   "Inclui MDT"
          message ""
          call ctc42m00_inclui()
          next option "Seleciona"
          initialize d_ctc42m00.*  to null

   command "Remove" "Remove MDT corrente selecionado"
          message ""
          if d_ctc42m00.mdtcod  is not null   then
             call ctc42m00_remove(d_ctc42m00.*)
                  returning d_ctc42m00.*
             next option "Seleciona"
          else
             error " Nenhum MDT selecionado!"
             next option "Seleciona"
          end if
          initialize d_ctc42m00.*  to null

   command key ("C") "simCards" "Cadastros de SIMCards do aparelho."
          message ""
          if d_ctc42m00.mdtcod  is not null   then
             call ctc42m01(d_ctc42m00.mdtcod)
          else
             error " Nenhum MDT selecionado!"
             next option "Seleciona"
          end if

   command key ("N") "con_siNcard" "Consulta de SinCards."
          message ""
             call ctc42m01_consulta()

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc42m00

 end function  # ctc42m00


#------------------------------------------------------------
 function ctc42m00_seleciona()
#------------------------------------------------------------

 define d_ctc42m00    record
    mdtcod            like datkmdt.mdtcod,
    mdtctrcod         like datkmdt.mdtctrcod,
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdtprgcod         like datkmdt.mdtprgcod,
    mdtprgdes         like datkmdtprg.mdtprgdes,
    mdtmsggrpcod      like datkmdt.mdtmsggrpcod,
    mdtmsggrpdes      char (35),
    mdtsttdes         char (20),
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    mdtstt            like datkmdt.mdtstt,
    caddat            like datkmdt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdt.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod
 end record


 let int_flag = false
 initialize d_ctc42m00.*  to null
 display by name d_ctc42m00.*

 input by name d_ctc42m00.mdtcod,
 	       d_ctc42m00.atdvclsgl

    before field mdtcod
        display by name d_ctc42m00.mdtcod attribute (reverse)

    after  field mdtcod
        display by name d_ctc42m00.mdtcod

        if d_ctc42m00.mdtcod  is null   then
           #error " MDT deve ser informado!"
           #next field mdtcod
           next field atdvclsgl
        else
           open cctc42m00001 using d_ctc42m00.mdtcod
           fetch cctc42m00001

           if sqlca.sqlcode  =  notfound   then
             error " MDT nao cadastrado!!!"
             next field mdtcod
           end if
        end if
        
    before field atdvclsgl
        if d_ctc42m00.mdtcod  is null   then
           display by name d_ctc42m00.atdvclsgl attribute (reverse)
        else
           exit input
        end if
    
    after  field atdvclsgl
        display by name d_ctc42m00.atdvclsgl
        
        if d_ctc42m00.atdvclsgl is null then
           next field mdtcod
        end if 
        
        open c_slgctc42m00001 using d_ctc42m00.atdvclsgl
        fetch c_slgctc42m00001
    
        if sqlca.sqlcode  =  notfound   then
           error " Sigla nao cadastrada!"
           next field atdvclsgl
        end if
    
    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc42m00.*   to null
    display by name d_ctc42m00.*
    error " Operacao cancelada!"
    return d_ctc42m00.*
 end if

 call ctc42m00_ler(d_ctc42m00.mdtcod,d_ctc42m00.atdvclsgl)
      returning d_ctc42m00.*

 if d_ctc42m00.mdtcod  is not null   then
    display by name  d_ctc42m00.*
 else
    error " MDT nao cadastrado!"
    initialize d_ctc42m00.*    to null
 end if

 return d_ctc42m00.*

 end function  # ctc42m00_seleciona


#------------------------------------------------------------
 function ctc42m00_proximo(param)
#------------------------------------------------------------

 define param         record
    mdtcod            like datkmdt.mdtcod
 end record

 define d_ctc42m00    record
    mdtcod            like datkmdt.mdtcod,
    mdtctrcod         like datkmdt.mdtctrcod,
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdtprgcod         like datkmdt.mdtprgcod,
    mdtprgdes         like datkmdtprg.mdtprgdes,
    mdtmsggrpcod      like datkmdt.mdtmsggrpcod,
    mdtmsggrpdes      char (35),
    mdtsttdes         char (20),
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    mdtstt            like datkmdt.mdtstt,
    caddat            like datkmdt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdt.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod
 end record


 let int_flag = false
 initialize d_ctc42m00.*   to null

 if param.mdtcod  is null   then
    let param.mdtcod = 0
 end if

 open cctc42m00002 using param.mdtcod
 fetch cctc42m00002 into d_ctc42m00.mdtcod

 if d_ctc42m00.mdtcod  is not null   then

    call ctc42m00_ler(d_ctc42m00.mdtcod,d_ctc42m00.atdvclsgl)
         returning d_ctc42m00.*

    if d_ctc42m00.mdtcod  is not null   then
       display by name d_ctc42m00.*
    else
       error " Nao ha' MDT nesta direcao!"
       initialize d_ctc42m00.*    to null
    end if
 else
    error " Nao ha' MDT nesta direcao!"
    initialize d_ctc42m00.*    to null
 end if

 return d_ctc42m00.*

 end function    # ctc42m00_proximo


#------------------------------------------------------------
 function ctc42m00_anterior(param)
#------------------------------------------------------------

 define param         record
    mdtcod            like datkmdt.mdtcod
 end record

 define d_ctc42m00    record
    mdtcod            like datkmdt.mdtcod,
    mdtctrcod         like datkmdt.mdtctrcod,
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdtprgcod         like datkmdt.mdtprgcod,
    mdtprgdes         like datkmdtprg.mdtprgdes,
    mdtmsggrpcod      like datkmdt.mdtmsggrpcod,
    mdtmsggrpdes      char (35),
    mdtsttdes         char (20),
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    mdtstt            like datkmdt.mdtstt,
    caddat            like datkmdt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdt.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod
 end record


 let int_flag = false
 initialize d_ctc42m00.*  to null

 if param.mdtcod  is null   then
    let param.mdtcod = 0
 end if

 open cctc42m00003 using param.mdtcod
 fetch cctc42m00003 into d_ctc42m00.mdtcod

 if d_ctc42m00.mdtcod  is not null   then

    call ctc42m00_ler(d_ctc42m00.mdtcod,d_ctc42m00.atdvclsgl)
         returning d_ctc42m00.*

    if d_ctc42m00.mdtcod  is not null   then
       display by name  d_ctc42m00.*
    else
       error " Nao ha' MDT nesta direcao!"
       initialize d_ctc42m00.*    to null
    end if
 else
    error " Nao ha' MDT nesta direcao!"
    initialize d_ctc42m00.*    to null
 end if

 return d_ctc42m00.*

 end function    # ctc42m00_anterior


#------------------------------------------------------------
 function ctc42m00_modifica(param, d_ctc42m00)
#------------------------------------------------------------

 define param         record
    mdtcod            like datkmdt.mdtcod
 end record

 define d_ctc42m00    record
    mdtcod            like datkmdt.mdtcod,
    mdtctrcod         like datkmdt.mdtctrcod,
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdtprgcod         like datkmdt.mdtprgcod,
    mdtprgdes         like datkmdtprg.mdtprgdes,
    mdtmsggrpcod      like datkmdt.mdtmsggrpcod,
    mdtmsggrpdes      char (35),
    mdtsttdes         char (20),
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    mdtstt            like datkmdt.mdtstt,
    caddat            like datkmdt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdt.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod
 end record


 call ctc42m00_input("a", d_ctc42m00.*) returning d_ctc42m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc42m00.*  to null
    display by name d_ctc42m00.*
    error " Operacao cancelada!"
    return d_ctc42m00.*
 end if

 whenever error continue

 let d_ctc42m00.atldat = today

 begin work
    execute pctc42m00016 using d_ctc42m00.mdtctrcod,
                               d_ctc42m00.mdtcfgcod,
                               d_ctc42m00.mdtprgcod,
                               d_ctc42m00.mdtmsggrpcod,
                               d_ctc42m00.mdtstt,
                               d_ctc42m00.atldat,
                               g_issk.empcod,
                               g_issk.funmat,
                               d_ctc42m00.mdtcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do MDT!"
       rollback work
       initialize d_ctc42m00.*   to null
       return d_ctc42m00.*
    else

      execute pctc42m00017 using d_ctc42m00.gpsacngrpcod,
                                 d_ctc42m00.socvclcod

      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteracao do Grupo de Acionamento!"
         rollback work
         initialize d_ctc42m00.*   to null
         return d_ctc42m00.*
      else
         error " Alteracao efetuada com sucesso!"
      end if
    end if

 commit work

 whenever error stop

 initialize d_ctc42m00.*  to null
 display by name d_ctc42m00.*
 message ""
 return d_ctc42m00.*

 end function   #  ctc42m00_modifica


#------------------------------------------------------------
 function ctc42m00_inclui()
#------------------------------------------------------------

 define d_ctc42m00    record
    mdtcod            like datkmdt.mdtcod,
    mdtctrcod         like datkmdt.mdtctrcod,
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdtprgcod         like datkmdt.mdtprgcod,
    mdtprgdes         like datkmdtprg.mdtprgdes,
    mdtmsggrpcod      like datkmdt.mdtmsggrpcod,
    mdtmsggrpdes      char (35),
    mdtsttdes         char (20),
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    mdtstt            like datkmdt.mdtstt,
    caddat            like datkmdt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdt.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod
 end record

 define  ws_resp       char(01)


 initialize d_ctc42m00.*   to null
 display by name d_ctc42m00.*

 call ctc42m00_input("i", d_ctc42m00.*) returning d_ctc42m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc42m00.*  to null
    display by name d_ctc42m00.*
    error " Operacao cancelada!"
    return
 end if

 let d_ctc42m00.atldat = today
 let d_ctc42m00.caddat = today

 open cctc42m00004
 foreach cctc42m00004 into d_ctc42m00.mdtcod
     exit foreach
 end foreach

 if d_ctc42m00.mdtcod is null   then
    let d_ctc42m00.mdtcod = 0
 end if
 let d_ctc42m00.mdtcod = d_ctc42m00.mdtcod + 1

 whenever error continue

 begin work
    execute pctc42m00015 using d_ctc42m00.mdtcod,
                               d_ctc42m00.mdtctrcod,
                               d_ctc42m00.mdtcfgcod,
                               d_ctc42m00.mdtprgcod,
                               d_ctc42m00.mdtmsggrpcod,
                               d_ctc42m00.mdtstt,
                               d_ctc42m00.caddat,
                               g_issk.empcod,
                               g_issk.funmat,
                               d_ctc42m00.atldat,
                               g_issk.empcod,
                               g_issk.funmat

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do MDT!"
       rollback work
       return
    end if

 commit work
 whenever error stop

 call ctc42m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc42m00.cadfunnom

 call ctc42m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc42m00.funnom

 display by name  d_ctc42m00.*

 display by name d_ctc42m00.mdtcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc42m00.*  to null
 display by name d_ctc42m00.*

 end function   #  ctc42m00_inclui


#--------------------------------------------------------------------
 function ctc42m00_input(param, d_ctc42m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc42m00    record
    mdtcod            like datkmdt.mdtcod,
    mdtctrcod         like datkmdt.mdtctrcod,
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdtprgcod         like datkmdt.mdtprgcod,
    mdtprgdes         like datkmdtprg.mdtprgdes,
    mdtmsggrpcod      like datkmdt.mdtmsggrpcod,
    mdtmsggrpdes      char (35),
    mdtsttdes         char (20),
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    mdtstt            like datkmdt.mdtstt,
    caddat            like datkmdt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdt.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod

 end record

 define ws            record
    mdtctrcod         like datkmdtctr.mdtctrcod,
    mdtctrstt         like datkmdtctr.mdtctrstt,
    mdtprgcod         like datkmdtprg.mdtprgcod,
    mdtprgstt         like datkmdtprg.mdtprgstt,
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgstt         like datkmdtcfg.mdtcfgstt,
    erro              smallint
 end record


 initialize ws.*  to null
 let int_flag      =  false
 let ws.mdtctrcod  =  d_ctc42m00.mdtctrcod
 let ws.mdtcfgcod  =  d_ctc42m00.mdtcfgcod
 let ws.mdtprgcod  =  d_ctc42m00.mdtprgcod

 input by name d_ctc42m00.mdtctrcod,
               d_ctc42m00.mdtcfgcod,
               d_ctc42m00.mdtprgcod,
               d_ctc42m00.mdtmsggrpcod,
               d_ctc42m00.mdtstt  without defaults

    before field mdtctrcod
           display by name d_ctc42m00.mdtctrcod attribute (reverse)

    after  field mdtctrcod
           display by name d_ctc42m00.mdtctrcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtctrcod
           end if

           if d_ctc42m00.mdtctrcod  is null   then
              error " Controladora deve ser informada!"
              next field mdtctrcod
           end if

           open cctc42m00005 using d_ctc42m00.mdtctrcod
           fetch cctc42m00005 into ws.mdtctrstt,
                                   d_ctc42m00.gpsacngrpcod

           if sqlca.sqlcode  =  notfound   then
              error " Controladora nao cadastrada!"
              next field mdtctrcod
           end if

           if param.operacao  =  "i"                   or
              d_ctc42m00.mdtctrcod  <>  ws.mdtctrcod   then
              if ws.mdtctrstt  <>  0   then
                 error " Controladora nao esta ativa!"
                 next field mdtctrcod
              end if
           end if

    before field mdtcfgcod
           display by name d_ctc42m00.mdtcfgcod attribute (reverse)

    after  field mdtcfgcod
           display by name d_ctc42m00.mdtcfgcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtctrcod
           end if

#           if d_ctc42m00.mdtcfgcod  is null   then
#              error " Configuracao deve ser informada!"
#              next field mdtcfgcod
#           end if
#
           if  d_ctc42m00.mdtcfgcod is null or d_ctc42m00.mdtcfgcod = " " then
               call cty09g00_popup_iddkdominio("eqttipcod")
                    returning ws.erro,
                              d_ctc42m00.mdtcfgcod,
                              d_ctc42m00.mdtcfgdes
           else
               #PSI 222020 - Burini
               let m_aux = "eqttipcod"
               open cctc42m00007 using m_aux,
                                       d_ctc42m00.mdtcfgcod
               fetch cctc42m00007 into d_ctc42m00.mdtcfgdes

               if  sqlca.sqlcode <> 0 then
                   error 'Responsavel nao cadastrado.'
                   let d_ctc42m00.mdtcfgcod = ""
                   let d_ctc42m00.mdtcfgdes = ""
                   next field mdtcfgcod
               end if
           end if

    before field mdtprgcod
           display by name d_ctc42m00.mdtprgcod attribute (reverse)

    after  field mdtprgcod
           display by name d_ctc42m00.mdtprgcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field mdtcfgcod
           end if

           if d_ctc42m00.mdtprgcod  is null   then
              error " Programacao deve ser informada!"
              next field mdtprgcod
           end if

           open cctc42m00006 using d_ctc42m00.mdtprgcod
           fetch cctc42m00006 into d_ctc42m00.mdtprgdes,
                                   ws.mdtprgstt

           if sqlca.sqlcode  =  notfound   then
              error " Programacao nao cadastrada!"
              next field mdtprgcod
           end if
           display by name d_ctc42m00.mdtprgdes

           if param.operacao  =  "i"                   or
              d_ctc42m00.mdtprgcod  <>  ws.mdtprgcod   then
              if ws.mdtprgstt  <>  "A"   then
                 error " Programacao nao esta ativa!"
                 next field mdtprgcod
              end if
           end if

    before field mdtmsggrpcod
           display by name d_ctc42m00.mdtmsggrpcod attribute (reverse)

    after  field mdtmsggrpcod
           display by name d_ctc42m00.mdtmsggrpcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtprgcod
           end if

           if d_ctc42m00.mdtmsggrpcod  is null   then
              error " Grupo de mensagem deve ser informado!"
              call ctn36c00("Grupo de mensagem MDT", "mdtmsggrpcod")
                   returning  d_ctc42m00.mdtmsggrpcod
              next field mdtmsggrpcod
           end if

           let m_aux = "mdtmsggrpcod"
           open cctc42m00007 using m_aux,
                                   d_ctc42m00.mdtmsggrpcod
           fetch cctc42m00007 into d_ctc42m00.mdtmsggrpdes

           if sqlca.sqlcode  =  notfound   then
              error " Grupo de mensagem nao cadastrado!"
              call ctn36c00("Grupo de mensagem MDT", "mdtmsggrpcod")
                   returning  d_ctc42m00.mdtmsggrpcod
              next field mdtmsggrpcod
           end if
           display by name d_ctc42m00.mdtmsggrpdes

    before field mdtstt
           if param.operacao  =  "i"   then
              let d_ctc42m00.mdtstt = 0

              let m_aux = "mdtstt"
              open cctc42m00007 using m_aux,
                                      d_ctc42m00.mdtstt
              fetch cctc42m00007 into d_ctc42m00.mdtsttdes

              display by name d_ctc42m00.mdtsttdes
           end if
           display by name d_ctc42m00.mdtstt attribute (reverse)

    after  field mdtstt
           display by name d_ctc42m00.mdtstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  mdtmsggrpcod
           end if

           if d_ctc42m00.mdtstt  is null   then
              error " Situacao do MDT deve ser informado!"
              call ctn36c00("Situacao do MDT", "mdtstt")
                   returning  d_ctc42m00.mdtstt
              next field mdtstt
           end if

           let m_aux = "mdtstt"
           open cctc42m00007 using m_aux,
                                   d_ctc42m00.mdtstt
           fetch cctc42m00007 into d_ctc42m00.mdtsttdes

           if sqlca.sqlcode  =  notfound   then
              error " Situacao do MDT nao cadastrado!"
              call ctn36c00("Situacao do MDT", "mdtstt")
                   returning  d_ctc42m00.mdtstt
              next field mdtstt
           end if

           if param.operacao     =  "i"  and
              d_ctc42m00.mdtstt  <>  0   then
              error " Na inclusao situacao deve ser ATIVO!"
              next field mdtstt
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc42m00.*  to null
 end if

 return d_ctc42m00.*

 end function   # ctc42m00_input


#--------------------------------------------------------------------
 function ctc42m00_remove(d_ctc42m00)
#--------------------------------------------------------------------

 define d_ctc42m00    record
    mdtcod            like datkmdt.mdtcod,
    mdtctrcod         like datkmdt.mdtctrcod,
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdtprgcod         like datkmdt.mdtprgcod,
    mdtprgdes         like datkmdtprg.mdtprgdes,
    mdtmsggrpcod      like datkmdt.mdtmsggrpcod,
    mdtmsggrpdes      char (35),
    mdtsttdes         char (20),
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    mdtstt            like datkmdt.mdtstt,
    caddat            like datkmdt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdt.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod
 end record

 define ws            record
    socvclcod         like datkveiculo.socvclcod,
    mdtmvtseq         like datmmdtmvt.mdtmvtseq
 end record


 initialize ws.*  to null

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o MDT"
            clear form
            initialize d_ctc42m00.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui MDT"
            call ctc42m00_ler(d_ctc42m00.mdtcod,d_ctc42m00.atdvclsgl) returning d_ctc42m00.*

            if d_ctc42m00.mdtcod  is null   then
               initialize d_ctc42m00.* to null
               error " MDT nao localizado!"
            else

               initialize ws.mdtmvtseq  to null
               initialize ws.socvclcod  to null

               open cctc42m00008 using d_ctc42m00.mdtcod
               fetch cctc42m00008 into ws.socvclcod

               if ws.socvclcod  is not null   and
                  ws.socvclcod  > 0           then
                  error " MDT esta cadastrado em um veiculo, portanto nao deve ser removido!"
                  exit menu
               end if

               open cctc42m00009 using d_ctc42m00.mdtcod
               fetch cctc42m00009 into ws.mdtmvtseq

               if ws.mdtmvtseq  is not null   and
                  ws.mdtmvtseq  > 0           then
                  error " MDT possui movimento cadastrado, portanto nao deve ser removido!"
                  exit menu
               end if

               begin work
                  delete from datkmdt
                   where datkmdt.mdtcod = d_ctc42m00.mdtcod
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize d_ctc42m00.* to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do MDT!"
               else
                  initialize d_ctc42m00.* to null
                  error   " MDT excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return d_ctc42m00.*

end function    # ctc42m00_remove


#---------------------------------------------------------
 function ctc42m00_ler(param)
#---------------------------------------------------------

 define param         record
    mdtcod            like datkmdt.mdtcod,
    atdvclsgl         like datkveiculo.atdvclsgl
 end record

 define d_ctc42m00    record
    mdtcod            like datkmdt.mdtcod,
    mdtctrcod         like datkmdt.mdtctrcod,
    mdtcfgcod         like datkmdtcfg.mdtcfgcod,
    mdtcfgdes         like datkmdtcfg.mdtcfgdes,
    mdtprgcod         like datkmdt.mdtprgcod,
    mdtprgdes         like datkmdtprg.mdtprgdes,
    mdtmsggrpcod      like datkmdt.mdtmsggrpcod,
    mdtmsggrpdes      char (35),
    mdtsttdes         char (20),
    atdvclsgl         like datkveiculo.atdvclsgl,
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (50),
    mdtstt            like datkmdt.mdtstt,
    caddat            like datkmdt.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkmdt.atldat,
    funnom            like isskfunc.funnom,
    gpsacngrpcod      like datkmdtctr.gpsacngrpcod
 end record

 define ws            record
    vclcoddig         like datkveiculo.vclcoddig,
    vclmrcnom         like agbkmarca.vclmrcnom,
    vcltipnom         like agbktip.vcltipnom,
    vclmdlnom         like agbkveic.vclmdlnom,
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat
 end record

 define l_mesg        char(20)

 initialize d_ctc42m00.*   to null
 initialize ws.*           to null

 if param.mdtcod is not null then
    open cctc42m00010 using param.mdtcod
    fetch cctc42m00010 into d_ctc42m00.mdtcod,
                            d_ctc42m00.mdtctrcod,
                            d_ctc42m00.mdtcfgcod,
                            d_ctc42m00.mdtprgcod,
	                    d_ctc42m00.mdtmsggrpcod,
	                    d_ctc42m00.mdtstt,
	                    d_ctc42m00.caddat,
	                    ws.cademp,
	                    ws.cadmat,
	                    d_ctc42m00.atldat,
	                    ws.atlemp,
	                    ws.atlmat
	
	 if sqlca.sqlcode = notfound   then
	    error " MDT nao cadastrado!"
	    initialize d_ctc42m00.*    to null
	    return d_ctc42m00.*
	 end if
 else
   open c_slgctc42m00010  using param.atdvclsgl
   fetch c_slgctc42m00010 into  d_ctc42m00.mdtcod,
                                d_ctc42m00.mdtctrcod,
                                d_ctc42m00.mdtcfgcod,
                                d_ctc42m00.mdtprgcod,
	                        d_ctc42m00.mdtmsggrpcod,
	                        d_ctc42m00.mdtstt,
	                        d_ctc42m00.caddat,
	                        ws.cademp,
	                        ws.cadmat,
	                        d_ctc42m00.atldat,
	                        ws.atlemp,
	                        ws.atlmat
	
	 if sqlca.sqlcode = notfound   then
	    error " MDT nao cadastrado para esta Sigla!"
	    initialize d_ctc42m00.*    to null
	    return d_ctc42m00.*
	 end if
 end if
 
 call ctc42m00_func(ws.cademp, ws.cadmat)
      returning d_ctc42m00.cadfunnom

 call ctc42m00_func(ws.atlemp, ws.atlmat)
      returning d_ctc42m00.funnom
 
 let m_aux = "eqttipcod"
 open cctc42m00007 using m_aux,
                         d_ctc42m00.mdtcfgcod
 fetch cctc42m00007 into d_ctc42m00.mdtcfgdes

 open cctc42m00011 using d_ctc42m00.mdtprgcod
 fetch cctc42m00011 into d_ctc42m00.mdtprgdes

 let m_aux = "mdtmsggrpcod"
 open cctc42m00007 using m_aux,
                         d_ctc42m00.mdtmsggrpcod
 fetch cctc42m00007 into d_ctc42m00.mdtmsggrpdes

 let m_aux = "mdtstt"
 open cctc42m00007 using m_aux,
                         d_ctc42m00.mdtstt
 fetch cctc42m00007 into d_ctc42m00.mdtsttdes

 #-----------------------------------------------------------------------
 # Verifica se ja' existe veiculo com este MDT instalado
 #-----------------------------------------------------------------------
 open cctc42m00012 using d_ctc42m00.mdtcod
 fetch cctc42m00012 into d_ctc42m00.atdvclsgl,
                         d_ctc42m00.socvclcod,
                         ws.vclcoddig

 if ws.vclcoddig  is not null   then
    open cctc42m00013 using ws.vclcoddig
    fetch cctc42m00013 into ws.vclmrcnom,
                            ws.vcltipnom,
                            ws.vclmdlnom

    let d_ctc42m00.vcldes = ws.vclmrcnom clipped, " ",
                            ws.vcltipnom clipped, " ",
                            ws.vclmdlnom
 end if

 return d_ctc42m00.*

 end function   # ctc42m00_ler


#---------------------------------------------------------
 function ctc42m00_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record

 initialize ws.*    to null

 open cctc42m00014 using param.empcod,
                         param.funmat
 fetch cctc42m00014 into ws.funnom

 return ws.funnom

 end function   # ctc42m00_func
