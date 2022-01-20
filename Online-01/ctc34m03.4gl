############################################################################
# Nome do Modulo: ctc34m03                                        Marcelo  #
#                                                                Gilberto  #
# Cadastro de apolices dos veiculos do Porto Socorro             Set/1998  #
############################################################################
#                           MANUTENCOES                                    #
# 22/04/2003 PSI.168920     Aguinaldo Costa      Resolucao 86              #
#------------------------------------------------------------------------- #
# 15/09/2010 PSI201000009EV Beatriz  Obrigar o usuario a incluir um seguro #
#                                    quando incluir ou alterar um viatura  #
#                                    que não tenha seguro cadastrado       #
#--------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define obrseguro smallint # verificar se eh obrigatorio a invlusao de um seguro
#------------------------------------------------------------
 function ctc34m03(param)
#------------------------------------------------------------

 define param         record
    socvclcod         like datkvclsgr.socvclcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    vcldes            char (58)
 end record

 define d_ctc34m03    record
    vclsgrseq         like datkvclsgr.vclsgrseq,
    sgdirbcod         like datkvclsgr.sgdirbcod,
    sgdnom            like gcckcong.sgdnom,
    aplporcab         char (13),
    ramcod            like datkvclsgr.ramcod,
    succod            like datkvclsgr.succod,
    aplnumdig         like datkvclsgr.aplnumdig,
    itmnumdig         like datkvclsgr.itmnumdig,
    aplconcab         char (13),
    sgraplnum         like datkvclsgr.sgraplnum,
    viginc            like datkvclsgr.viginc,
    vigfnl            like datkvclsgr.vigfnl,
    cbtcscflg         like datkvclsgr.cbtcscflg,
    cbtrcfflg         like datkvclsgr.cbtrcfflg,
    sgrimsdmvlr       like datkvclsgr.sgrimsdmvlr,
    sgrimsdpvlr       like datkvclsgr.sgrimsdpvlr,
    cbtrcffvrflg      like datkvclsgr.cbtrcffvrflg,
    atldat            like datkvclsgr.atldat,
    funnom            like isskfunc.funnom
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  d_ctc34m03.*  to  null

 let int_flag = false
 initialize d_ctc34m03.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctc34m03") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc34m03 at 4,2 with form "ctc34m03"

 display by name param.socvclcod   attribute(reverse)
 display by name param.atdvclsgl   attribute(reverse)
 display by name param.vcldes      attribute(reverse)

 let d_ctc34m03.aplporcab = "Apolice.....:"
 display by name d_ctc34m03.aplporcab


 menu "SEGUROS"

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
                   "Pesquisa apolice conforme criterios"
          call ctc34m03_seleciona(param.socvclcod)  returning d_ctc34m03.*
          if d_ctc34m03.vclsgrseq  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhuma apolice selecionada!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proxima apolice selecionada"
          message ""
          call ctc34m03_proximo(param.socvclcod, d_ctc34m03.vclsgrseq)
               returning d_ctc34m03.*

 command key ("A") "Anterior"
                   "Mostra apolice anterior selecionada"
          message ""
          if d_ctc34m03.vclsgrseq  is not null then
             call ctc34m03_anterior(param.socvclcod, d_ctc34m03.vclsgrseq)
                  returning d_ctc34m03.*
          else
             error " Nenhuma apolice nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica apolice corrente selecionada"
          message ""
          if d_ctc34m03.vclsgrseq  is not null then
             if d_ctc34m03.vigfnl  <  today   then
              error " Apolice com vigencia ja' encerrada nao deve ser alterada!"
             else
                call ctc34m03_modifica(param.socvclcod, d_ctc34m03.*)
                     returning d_ctc34m03.*
                next option "Seleciona"
             end if
          else
             error " Nenhuma apolice selecionada!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui apolice"
          message ""
          call ctc34m03_inclui(param.socvclcod)
          next option "Seleciona"

   command "Remove" "Remove apolice corrente selecionada"
            message ""
            if d_ctc34m03.vclsgrseq  is not null   then
               call ctc34m03_remove(param.socvclcod, d_ctc34m03.*)
                    returning d_ctc34m03.*
               next option "Seleciona"
            else
               error " Nenhuma apolice selecionada!"
               next option "Seleciona"
            end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc34m03

 end function  # ctc34m03


#------------------------------------------------------------
 function ctc34m03_seleciona(param)
#------------------------------------------------------------

 define param         record
    socvclcod         like datkvclsgr.socvclcod
 end record

 define d_ctc34m03    record
    vclsgrseq         like datkvclsgr.vclsgrseq,
    sgdirbcod         like datkvclsgr.sgdirbcod,
    sgdnom            like gcckcong.sgdnom,
    aplporcab         char (13),
    ramcod            like datkvclsgr.ramcod,
    succod            like datkvclsgr.succod,
    aplnumdig         like datkvclsgr.aplnumdig,
    itmnumdig         like datkvclsgr.itmnumdig,
    aplconcab         char (13),
    sgraplnum         like datkvclsgr.sgraplnum,
    viginc            like datkvclsgr.viginc,
    vigfnl            like datkvclsgr.vigfnl,
    cbtcscflg         like datkvclsgr.cbtcscflg,
    cbtrcfflg         like datkvclsgr.cbtrcfflg,
    sgrimsdmvlr       like datkvclsgr.sgrimsdmvlr,
    sgrimsdpvlr       like datkvclsgr.sgrimsdpvlr,
    cbtrcffvrflg      like datkvclsgr.cbtrcffvrflg,
    atldat            like datkvclsgr.atldat,
    funnom            like isskfunc.funnom
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  d_ctc34m03.*  to  null

 let int_flag = false
 initialize d_ctc34m03.*  to null

 select max(datkvclsgr.vclsgrseq)
   into d_ctc34m03.vclsgrseq
   from datkvclsgr
  where datkvclsgr.socvclcod  =  param.socvclcod

 display by name d_ctc34m03.*

 input by name d_ctc34m03.vclsgrseq   without defaults

    before field vclsgrseq
        display by name d_ctc34m03.vclsgrseq attribute (reverse)

    after  field vclsgrseq
        display by name d_ctc34m03.vclsgrseq

        if d_ctc34m03.vclsgrseq  is null   then
           error " Sequencia deve ser informada!"
           next field vclsgrseq
        end if

        select vclsgrseq
          from datkvclsgr
         where datkvclsgr.socvclcod = param.socvclcod
           and datkvclsgr.vclsgrseq = d_ctc34m03.vclsgrseq

        if sqlca.sqlcode  =  notfound   then
           error " Sequencia nao cadastrada!"
           next field vclsgrseq
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m03.*   to null
    display by name d_ctc34m03.*
    error " Operacao cancelada!"
    return d_ctc34m03.*
 end if

 call ctc34m03_ler(param.socvclcod, d_ctc34m03.vclsgrseq)
      returning d_ctc34m03.*

 if d_ctc34m03.vclsgrseq  is not null   then
    display by name  d_ctc34m03.*
 else
    error " Apolice nao cadastrada!"
    initialize d_ctc34m03.*    to null
 end if

 return d_ctc34m03.*

 end function  # ctc34m03_seleciona


#------------------------------------------------------------
 function ctc34m03_proximo(param)
#------------------------------------------------------------

 define param         record
    socvclcod         like datkvclsgr.socvclcod,
    vclsgrseq         like datkvclsgr.vclsgrseq
 end record

 define d_ctc34m03    record
    vclsgrseq         like datkvclsgr.vclsgrseq,
    sgdirbcod         like datkvclsgr.sgdirbcod,
    sgdnom            like gcckcong.sgdnom,
    aplporcab         char (13),
    ramcod            like datkvclsgr.ramcod,
    succod            like datkvclsgr.succod,
    aplnumdig         like datkvclsgr.aplnumdig,
    itmnumdig         like datkvclsgr.itmnumdig,
    aplconcab         char (13),
    sgraplnum         like datkvclsgr.sgraplnum,
    viginc            like datkvclsgr.viginc,
    vigfnl            like datkvclsgr.vigfnl,
    cbtcscflg         like datkvclsgr.cbtcscflg,
    cbtrcfflg         like datkvclsgr.cbtrcfflg,
    sgrimsdmvlr       like datkvclsgr.sgrimsdmvlr,
    sgrimsdpvlr       like datkvclsgr.sgrimsdpvlr,
    cbtrcffvrflg      like datkvclsgr.cbtrcffvrflg,
    atldat            like datkvclsgr.atldat,
    funnom            like isskfunc.funnom
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  d_ctc34m03.*  to  null

 let int_flag = false
 initialize d_ctc34m03.*   to null

 if param.vclsgrseq  is null   then
    let param.vclsgrseq = 0
 end if

 select min(datkvclsgr.vclsgrseq)
   into d_ctc34m03.vclsgrseq
   from datkvclsgr
  where datkvclsgr.socvclcod  =  param.socvclcod
    and datkvclsgr.vclsgrseq  >  param.vclsgrseq

 if d_ctc34m03.vclsgrseq  is not null   then
    call ctc34m03_ler(param.socvclcod, d_ctc34m03.vclsgrseq)
         returning d_ctc34m03.*

    if d_ctc34m03.vclsgrseq  is not null   then
       display by name d_ctc34m03.*
    else
       error " Nao ha' apolice nesta direcao!"
       initialize d_ctc34m03.*    to null
    end if
 else
    error " Nao ha' apolice nesta direcao!"
    initialize d_ctc34m03.*    to null
 end if

 return d_ctc34m03.*

 end function    # ctc34m03_proximo


#------------------------------------------------------------
 function ctc34m03_anterior(param)
#------------------------------------------------------------

 define param         record
    socvclcod         like datkvclsgr.socvclcod,
    vclsgrseq         like datkvclsgr.vclsgrseq
 end record

 define d_ctc34m03    record
    vclsgrseq         like datkvclsgr.vclsgrseq,
    sgdirbcod         like datkvclsgr.sgdirbcod,
    sgdnom            like gcckcong.sgdnom,
    aplporcab         char (13),
    ramcod            like datkvclsgr.ramcod,
    succod            like datkvclsgr.succod,
    aplnumdig         like datkvclsgr.aplnumdig,
    itmnumdig         like datkvclsgr.itmnumdig,
    aplconcab         char (13),
    sgraplnum         like datkvclsgr.sgraplnum,
    viginc            like datkvclsgr.viginc,
    vigfnl            like datkvclsgr.vigfnl,
    cbtcscflg         like datkvclsgr.cbtcscflg,
    cbtrcfflg         like datkvclsgr.cbtrcfflg,
    sgrimsdmvlr       like datkvclsgr.sgrimsdmvlr,
    sgrimsdpvlr       like datkvclsgr.sgrimsdpvlr,
    cbtrcffvrflg      like datkvclsgr.cbtrcffvrflg,
    atldat            like datkvclsgr.atldat,
    funnom            like isskfunc.funnom
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  d_ctc34m03.*  to  null

 let int_flag = false
 initialize d_ctc34m03.*  to null

 if param.vclsgrseq  is null   then
    let param.vclsgrseq = 0
 end if

 select max(datkvclsgr.vclsgrseq)
   into d_ctc34m03.vclsgrseq
   from datkvclsgr
  where datkvclsgr.socvclcod  =  param.socvclcod
    and datkvclsgr.vclsgrseq  <  param.vclsgrseq

 if d_ctc34m03.vclsgrseq  is not null   then

    call ctc34m03_ler(param.socvclcod, d_ctc34m03.vclsgrseq)
         returning d_ctc34m03.*

    if d_ctc34m03.vclsgrseq  is not null   then
       display by name  d_ctc34m03.*
    else
       error " Nao ha' apolice nesta direcao!"
       initialize d_ctc34m03.*    to null
    end if
 else
    error " Nao ha' apolice nesta direcao!"
    initialize d_ctc34m03.*    to null
 end if

 return d_ctc34m03.*

 end function    # ctc34m03_anterior


#------------------------------------------------------------
 function ctc34m03_modifica(param, d_ctc34m03)
#------------------------------------------------------------

 define param         record
    socvclcod         like datkvclsgr.socvclcod
 end record

 define d_ctc34m03    record
    vclsgrseq         like datkvclsgr.vclsgrseq,
    sgdirbcod         like datkvclsgr.sgdirbcod,
    sgdnom            like gcckcong.sgdnom,
    aplporcab         char (13),
    ramcod            like datkvclsgr.ramcod,
    succod            like datkvclsgr.succod,
    aplnumdig         like datkvclsgr.aplnumdig,
    itmnumdig         like datkvclsgr.itmnumdig,
    aplconcab         char (13),
    sgraplnum         like datkvclsgr.sgraplnum,
    viginc            like datkvclsgr.viginc,
    vigfnl            like datkvclsgr.vigfnl,
    cbtcscflg         like datkvclsgr.cbtcscflg,
    cbtrcfflg         like datkvclsgr.cbtrcfflg,
    sgrimsdmvlr       like datkvclsgr.sgrimsdmvlr,
    sgrimsdpvlr       like datkvclsgr.sgrimsdpvlr,
    cbtrcffvrflg      like datkvclsgr.cbtrcffvrflg,
    atldat            like datkvclsgr.atldat,
    funnom            like isskfunc.funnom
 end record



 call ctc34m03_input("a", param.socvclcod, d_ctc34m03.*) returning d_ctc34m03.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m03.*  to null
    display by name d_ctc34m03.*
    error " Operacao cancelada!"
    return d_ctc34m03.*
 end if

 if d_ctc34m03.aplnumdig   is null   and
    d_ctc34m03.sgraplnum   is null   then
    error " Erro alteracao da apolice, apolice Porto ou Congenere nao informada!"
    return d_ctc34m03.*
 end if

 if d_ctc34m03.aplnumdig   is not null   and
    d_ctc34m03.sgraplnum   is not null   then
    error " Erro na alteracao da apolice, apolice Porto e Congenere informadas!"
    return d_ctc34m03.*
 end if

 whenever error continue

 let d_ctc34m03.atldat = today
 
  # o campo nao pode ser nulo
 if d_ctc34m03.aplnumdig is null or
    d_ctc34m03.aplnumdig = " " then
       let d_ctc34m03.aplnumdig = 0
 end if
 
 begin work
    update datkvclsgr set  ( viginc,
                             vigfnl,
                             sgdirbcod,
                             ramcod,
                             succod,
                             aplnumdig,
                             itmnumdig,
                             sgraplnum,
                             cbtcscflg,
                             cbtrcfflg,
                             sgrimsdmvlr,
                             sgrimsdpvlr,
                             cbtrcffvrflg,
                             atldat,
                             atlemp,
                             atlmat )
                        =  ( d_ctc34m03.viginc,
                             d_ctc34m03.vigfnl,
                             d_ctc34m03.sgdirbcod,
                             d_ctc34m03.ramcod,
                             d_ctc34m03.succod,
                             d_ctc34m03.aplnumdig,
                             d_ctc34m03.itmnumdig,
                             d_ctc34m03.sgraplnum,
                             d_ctc34m03.cbtcscflg,
                             d_ctc34m03.cbtrcfflg,
                             d_ctc34m03.sgrimsdmvlr,
                             d_ctc34m03.sgrimsdpvlr,
                             d_ctc34m03.cbtrcffvrflg,
                             d_ctc34m03.atldat,
                             g_issk.empcod,
                             g_issk.funmat )
           where datkvclsgr.socvclcod  =  param.socvclcod
             and datkvclsgr.vclsgrseq  =  d_ctc34m03.vclsgrseq

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao da apolice!"
       rollback work
       initialize d_ctc34m03.*   to null
       return d_ctc34m03.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_ctc34m03.*  to null
 display by name d_ctc34m03.*
 message ""
 return d_ctc34m03.*

 end function   #  ctc34m03_modifica


#------------------------------------------------------------
 function ctc34m03_inclui(param)
#------------------------------------------------------------

 define param         record
    socvclcod         like datkvclsgr.socvclcod
 end record

 define d_ctc34m03    record
    vclsgrseq         like datkvclsgr.vclsgrseq,
    sgdirbcod         like datkvclsgr.sgdirbcod,
    aplporcab         char (13),
    sgdnom            like gcckcong.sgdnom,
    ramcod            like datkvclsgr.ramcod,
    succod            like datkvclsgr.succod,
    aplnumdig         like datkvclsgr.aplnumdig,
    itmnumdig         like datkvclsgr.itmnumdig,
    aplconcab         char (13),
    sgraplnum         like datkvclsgr.sgraplnum,
    viginc            like datkvclsgr.viginc,
    vigfnl            like datkvclsgr.vigfnl,
    cbtcscflg         like datkvclsgr.cbtcscflg,
    cbtrcfflg         like datkvclsgr.cbtrcfflg,
    sgrimsdmvlr       like datkvclsgr.sgrimsdmvlr,
    sgrimsdpvlr       like datkvclsgr.sgrimsdpvlr,
    cbtrcffvrflg      like datkvclsgr.cbtrcffvrflg,
    atldat            like datkvclsgr.atldat,
    funnom            like isskfunc.funnom
 end record

 define  ws_resp       char(01)



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	ws_resp  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  d_ctc34m03.*  to  null

 initialize d_ctc34m03.*   to null
 display by name d_ctc34m03.*
 let obrseguro = false
 
 call ctc34m03_input("i", param.socvclcod, d_ctc34m03.*) returning d_ctc34m03.*
  
 if int_flag  then
    let obrseguro = int_flag
    let int_flag = false
    initialize d_ctc34m03.*  to null
    display by name d_ctc34m03.*
    error " Operacao cancelada!"
    return
 end if

 if d_ctc34m03.aplnumdig   is null   and
    d_ctc34m03.sgraplnum   is null   then
    error " Erro inclusao da apolice, apolice Porto ou Congenere nao informada!"
    return
 end if

 if d_ctc34m03.aplnumdig   is not null   and
    d_ctc34m03.sgraplnum   is not null   then
    error " Erro na inclusao da apolice, apolice Porto e Congenere informadas!"
    return
 end if

 let d_ctc34m03.atldat = today


 declare cctc34m03001  cursor with hold  for
    select max(vclsgrseq)
      from datkvclsgr
     where datkvclsgr.socvclcod  =  param.socvclcod

 foreach cctc34m03001  into  d_ctc34m03.vclsgrseq
     exit foreach
 end foreach

 if d_ctc34m03.vclsgrseq  is null   then
    let d_ctc34m03.vclsgrseq = 0
 end if
 let d_ctc34m03.vclsgrseq = d_ctc34m03.vclsgrseq + 1

 # o campo nao pode ser nulo
 if d_ctc34m03.aplnumdig is null or
    d_ctc34m03.aplnumdig = " " then
       let d_ctc34m03.aplnumdig = 0
 end if
 whenever error continue

 begin work
    insert into datkvclsgr ( socvclcod,
                             vclsgrseq,
                             sgdirbcod,
                             viginc,
                             vigfnl,
                             ramcod,
                             succod,
                             aplnumdig,
                             itmnumdig,
                             sgraplnum,
                             cbtcscflg,
                             cbtrcfflg,
                             sgrimsdmvlr,
                             sgrimsdpvlr,
                             cbtrcffvrflg,
                             atldat,
                             atlemp,
                             atlmat )
                  values
                           ( param.socvclcod,
                             d_ctc34m03.vclsgrseq,
                             d_ctc34m03.sgdirbcod,
                             d_ctc34m03.viginc,
                             d_ctc34m03.vigfnl,
                             d_ctc34m03.ramcod,
                             d_ctc34m03.succod,
                             d_ctc34m03.aplnumdig,
                             d_ctc34m03.itmnumdig,
                             d_ctc34m03.sgraplnum,
                             d_ctc34m03.cbtcscflg,
                             d_ctc34m03.cbtrcfflg,
                             d_ctc34m03.sgrimsdmvlr,
                             d_ctc34m03.sgrimsdpvlr,
                             d_ctc34m03.cbtrcffvrflg,
                             d_ctc34m03.atldat,
                             g_issk.empcod,
                             g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao da apolice!"
       rollback work
       return
    end if

 commit work
 
 let obrseguro = false
 
 whenever error stop

 call ctc34m03_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc34m03.funnom

 display by name  d_ctc34m03.*

 display by name d_ctc34m03.vclsgrseq  attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize d_ctc34m03.*  to null
 display by name d_ctc34m03.*

 end function   #  ctc34m03_inclui


#--------------------------------------------------------------------
 function ctc34m03_input(param, d_ctc34m03)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1),
    socvclcod         like datkvclsgr.socvclcod
 end record

 define d_ctc34m03    record
    vclsgrseq         like datkvclsgr.vclsgrseq,
    sgdirbcod         like datkvclsgr.sgdirbcod,
    sgdnom            like gcckcong.sgdnom,
    aplporcab         char (13),
    ramcod            like datkvclsgr.ramcod,
    succod            like datkvclsgr.succod,
    aplnumdig         like datkvclsgr.aplnumdig,
    itmnumdig         like datkvclsgr.itmnumdig,
    aplconcab         char (13),
    sgraplnum         like datkvclsgr.sgraplnum,
    viginc            like datkvclsgr.viginc,
    vigfnl            like datkvclsgr.vigfnl,
    cbtcscflg         like datkvclsgr.cbtcscflg,
    cbtrcfflg         like datkvclsgr.cbtrcfflg,
    sgrimsdmvlr       like datkvclsgr.sgrimsdmvlr,
    sgrimsdpvlr       like datkvclsgr.sgrimsdpvlr,
    cbtrcffvrflg      like datkvclsgr.cbtrcffvrflg,
    atldat            like datkvclsgr.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    viginc            like abamapol.viginc,
    vigfnl            like abamapol.vigfnl,
    aplstt            like abamapol.aplstt,
    itmsttatu         like abbmitem.itmsttatu,
    dmimsvlrapl       like abbmdm.imsvlr,
    dpimsvlrapl       like abbmdp.imsvlr,
    vclcoddig         like datkveiculo.vclcoddig,
    vcllicnum         like datkveiculo.vcllicnum,
    vclcoddigapl      like abbmveic.vclcoddig,
    vcllicnumapl      like abbmveic.vcllicnum,
    clscod            like abbmclaus.clscod,
    cbtcscflg         char (01),
    vigerro           char (01)
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  ws.*  to  null

 let int_flag = false
 initialize ws.*   to null

 input by name d_ctc34m03.sgdirbcod,
               d_ctc34m03.ramcod,
               d_ctc34m03.succod,
               d_ctc34m03.aplnumdig,
               d_ctc34m03.itmnumdig,
               d_ctc34m03.sgraplnum,
               d_ctc34m03.viginc,
               d_ctc34m03.vigfnl,
               d_ctc34m03.cbtcscflg,
               d_ctc34m03.cbtrcfflg,
               d_ctc34m03.sgrimsdmvlr,
               d_ctc34m03.sgrimsdpvlr,
               d_ctc34m03.cbtrcffvrflg  without defaults

    before field sgdirbcod
           display by name d_ctc34m03.sgdirbcod    attribute (reverse)

    after  field sgdirbcod
           display by name d_ctc34m03.sgdirbcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  sgdirbcod
           end if

           if d_ctc34m03.sgdirbcod   is null   then
              error " Codigo da seguradora deve ser infomado!"
              call ctn41c00()  returning d_ctc34m03.sgdirbcod
              next field sgdirbcod
           end if

           initialize d_ctc34m03.sgdnom  to null
           select sgdnom
             into d_ctc34m03.sgdnom
             from gcckcong
            where gcckcong.sgdirbcod  =  d_ctc34m03.sgdirbcod

           if sqlca.sqlcode  <>  0   then
              error " Seguradora nao cadastrada!"
              call ctn41c00()  returning d_ctc34m03.sgdirbcod
              next field sgdirbcod
           end if
           display by name d_ctc34m03.sgdnom

           if d_ctc34m03.sgdirbcod  <>  5886   then   #--> Porto Seguro
              let d_ctc34m03.aplconcab = "Apolice.....:"
              display by name d_ctc34m03.aplconcab
              initialize d_ctc34m03.aplporcab  to null
              display by name  d_ctc34m03.aplporcab

              initialize d_ctc34m03.ramcod     to null
              display by name  d_ctc34m03.ramcod
              initialize d_ctc34m03.succod     to null
              display by name  d_ctc34m03.succod
              initialize d_ctc34m03.aplnumdig  to null
              display by name  d_ctc34m03.aplnumdig
              initialize d_ctc34m03.itmnumdig  to null
              display by name  d_ctc34m03.itmnumdig

              next field sgraplnum
           else
              let d_ctc34m03.aplporcab = "Apolice.....:"
              display by name d_ctc34m03.aplporcab
              initialize d_ctc34m03.aplconcab  to null
              display by name  d_ctc34m03.aplconcab

              initialize d_ctc34m03.sgraplnum  to null
              display by name  d_ctc34m03.sgraplnum
           end if

    before field ramcod
           let d_ctc34m03.ramcod  =  531
           display by name d_ctc34m03.ramcod    attribute (reverse)

    after  field ramcod
           display by name d_ctc34m03.ramcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  sgdirbcod
           end if

           if d_ctc34m03.ramcod   is null   then
              error " Codigo do ramo deve ser informado!"
              next field ramcod
           end if

           if d_ctc34m03.ramcod  <>  31     and
              d_ctc34m03.ramcod  <>  531    then
              error " Codigo do ramo deve ser 531 (automovel)!"
              next field ramcod
           end if

           select ramcod
             from gtakram
            where gtakram.ramcod  =  d_ctc34m03.ramcod
              and gtakram.empcod  = 1
           if sqlca.sqlcode  <>  0   then
              error " Ramo nao cadastrado!"
              next field ramcod
           end if

    before field succod
           display by name d_ctc34m03.succod    attribute (reverse)

    after  field succod
           display by name d_ctc34m03.succod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  ramcod
           end if

           if d_ctc34m03.succod   is null   then
              error " Codigo da sucursal deve ser informada!"
              next field succod
           end if

           select succod
             from gabksuc
            where gabksuc.succod  =  d_ctc34m03.succod

           if sqlca.sqlcode  <>  0   then
              error " Sucursal nao cadastrada!"
              next field succod
           end if

    before field aplnumdig
           display by name d_ctc34m03.aplnumdig    attribute (reverse)

    after  field aplnumdig
           display by name d_ctc34m03.aplnumdig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_ctc34m03.sgdirbcod  =  5886   then  #--> Porto Seguro
                 next field  succod
              end if
              next field  sgdirbcod
           end if

           if d_ctc34m03.aplnumdig   is null   then
              error " Numero da apolice deve ser informada!"
              next field aplnumdig
           end if

           if d_ctc34m03.sgdirbcod  =  5886   then
              select viginc,
                     vigfnl,
                     aplstt
                into ws.viginc,
                     ws.vigfnl,
                     ws.aplstt
                from abamapol
               where abamapol.succod     =  d_ctc34m03.succod
                 and abamapol.aplnumdig  =  d_ctc34m03.aplnumdig

              if sqlca.sqlcode  <>  0   then
                 error " Apolice nao cadastrada!"
                 next field aplnumdig
              end if

              let d_ctc34m03.viginc = ws.viginc
              let d_ctc34m03.vigfnl = ws.vigfnl
              display by name d_ctc34m03.viginc
              display by name d_ctc34m03.vigfnl

              if ws.vigfnl  <  today   then
                 error " Apolice vencida!"
                 next field aplnumdig
              end if

              if ws.aplstt  <>  "A"   then
                 error " Apolice cancelada!"
                 next field aplnumdig
              end if

          else
             next field viginc
          end if

    before field itmnumdig
           display by name d_ctc34m03.itmnumdig    attribute (reverse)

    after  field itmnumdig
           display by name d_ctc34m03.itmnumdig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  aplnumdig
           end if

           if d_ctc34m03.itmnumdig   is null   then
              error " Item da apolice deve ser informado!"
              next field itmnumdig
           end if

           select itmsttatu
             into ws.itmsttatu
             from abbmitem
            where abbmitem.succod     =  d_ctc34m03.succod
              and abbmitem.aplnumdig  =  d_ctc34m03.aplnumdig
              and abbmitem.itmnumdig  =  d_ctc34m03.itmnumdig

           if sqlca.sqlcode  <>  0   then
              error " Item nao cadastrado para a apolice!"
              next field itmnumdig
           end if

           if ws.itmsttatu  <>  "A"   then
              error " Item cancelado!"
              next field itmnumdig
           end if

           #------------------------------------------------------------
           # Busca ultima situacao da apolice
           #------------------------------------------------------------
           initialize g_funapol.*     to null
           initialize ws.dmimsvlrapl  to null
           initialize ws.dpimsvlrapl  to null

           call f_funapol_ultima_situacao
                (d_ctc34m03.succod, d_ctc34m03.aplnumdig, d_ctc34m03.itmnumdig)
                returning g_funapol.*

           #------------------------------------------------------------
           # Verifica codigo veiculo/placa do veiculo
           #------------------------------------------------------------
           initialize ws.vclcoddig     to null
           initialize ws.vcllicnum     to null
           initialize ws.vclcoddigapl  to null
           initialize ws.vcllicnumapl  to null

           select vclcoddig,
                  vcllicnum
             into ws.vclcoddig,
                  ws.vcllicnum
             from datkveiculo
            where datkveiculo.socvclcod = param.socvclcod

           select vclcoddig,
                  vcllicnum
             into ws.vclcoddigapl,
                  ws.vcllicnumapl
             from abbmveic
            where abbmveic.succod     = d_ctc34m03.succod
              and abbmveic.aplnumdig  = d_ctc34m03.aplnumdig
              and abbmveic.itmnumdig  = d_ctc34m03.itmnumdig
              and abbmveic.dctnumseq  = g_funapol.vclsitatu

           if ws.vclcoddigapl  <>  ws.vclcoddig   then
              error " Codigo da descricao do veiculo difere da apolice --> ",
                    ws.vclcoddigapl
              next field itmnumdig
           end if

           if ws.vcllicnumapl  <>  ws.vcllicnum   then
              error " Placa do veiculo difere da apolice --> ", ws.vcllicnumapl
              next field itmnumdig
           end if

           #------------------------------------------------------------
           # Busca cobertura de casco
           #------------------------------------------------------------
           select cbtcod
             from abbmcasco
            where abbmcasco.succod    = d_ctc34m03.succod
              and abbmcasco.aplnumdig = d_ctc34m03.aplnumdig
              and abbmcasco.itmnumdig = d_ctc34m03.itmnumdig
              and abbmcasco.dctnumseq = g_funapol.autsitatu

           if sqlca.sqlcode  =  0   then
              let d_ctc34m03.cbtcscflg = "S"
           else
              let d_ctc34m03.cbtcscflg = "N"
           end if
           let ws.cbtcscflg = d_ctc34m03.cbtcscflg
           display by name d_ctc34m03.cbtcscflg

           #------------------------------------------------------------
           # Busca valor de Danos Materiais na apolice
           #------------------------------------------------------------
           select imsvlr
             into ws.dmimsvlrapl
             from abbmdm
            where succod    = d_ctc34m03.succod
              and aplnumdig = d_ctc34m03.aplnumdig
              and itmnumdig = d_ctc34m03.itmnumdig
              and dctnumseq = g_funapol.dmtsitatu

           let d_ctc34m03.sgrimsdmvlr = ws.dmimsvlrapl
           display by name d_ctc34m03.sgrimsdmvlr

           #------------------------------------------------------------
           # Busca valor de Danos Pessoais na apolice
           #------------------------------------------------------------
           select imsvlr
             into ws.dpimsvlrapl
             from abbmdp
            where succod    = d_ctc34m03.succod
              and aplnumdig = d_ctc34m03.aplnumdig
              and itmnumdig = d_ctc34m03.itmnumdig
              and dctnumseq = g_funapol.dpssitatu

           let d_ctc34m03.sgrimsdpvlr = ws.dpimsvlrapl
           display by name d_ctc34m03.sgrimsdpvlr

           if ws.dmimsvlrapl  is not null   or
              ws.dpimsvlrapl  is not null   then
              let d_ctc34m03.cbtrcfflg = "S"
           else
              let d_ctc34m03.cbtrcfflg = "N"
           end if
           display by name d_ctc34m03.cbtrcfflg

           #------------------------------------------------------------
           # Busca clausula 111 - Cobertura RC Operacional
           #------------------------------------------------------------
           initialize ws.clscod   to null
           select clscod
             into ws.clscod
             from abbmclaus
            where succod    = d_ctc34m03.succod
              and aplnumdig = d_ctc34m03.aplnumdig
              and itmnumdig = d_ctc34m03.itmnumdig
              and dctnumseq = g_funapol.dctnumseq
              and clscod    = "111"

           if ws.clscod  is not null   then
              let d_ctc34m03.cbtrcffvrflg = "S"
           else
              let d_ctc34m03.cbtrcffvrflg = "N"
           end if
           display by name d_ctc34m03.cbtrcffvrflg
           next field viginc

    before field sgraplnum
           display by name d_ctc34m03.sgraplnum    attribute (reverse)

    after  field sgraplnum
           display by name d_ctc34m03.sgraplnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  sgdirbcod
           end if

           if d_ctc34m03.sgraplnum   is null   then
              error " Numero da apolice deve ser informado!"
              next field sgraplnum
           end if

    before field viginc
           display by name d_ctc34m03.viginc    attribute (reverse)

    after  field viginc
           display by name d_ctc34m03.viginc

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_ctc34m03.sgdirbcod  =  5886   then   #--> Porto Seguro
                 next field  itmnumdig
              end if
              next field  sgraplnum
           end if

           if d_ctc34m03.viginc   is null   then
              error " Vigencia inicial da apolice deve ser informada!"
              next field viginc
           end if

      ###  if d_ctc34m03.viginc   <  today - 60 units day   then
      ###     error " Vigencia inicial nao deve ser anterior a 60 dias!"
      ###     next field viginc
      ###  end if

           if d_ctc34m03.viginc   >  today + 60 units day   then
              error " Vigencia inicial nao deve ser superior a 60 dias!"
              next field viginc
           end if

    before field vigfnl
           display by name d_ctc34m03.vigfnl    attribute (reverse)

    after  field vigfnl
           display by name d_ctc34m03.vigfnl

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  viginc
           end if

           if d_ctc34m03.vigfnl   is null   then
              error " Vigencia final da apolice deve ser informada!"
              next field vigfnl
           end if

           if d_ctc34m03.vigfnl  <  d_ctc34m03.viginc   then
              error " Vigencia final nao deve ser anterior a vigencia inicial!"
              next field vigfnl
           end if

           if d_ctc34m03.vigfnl  >  d_ctc34m03.viginc + 730 units day   then
              error " Periodo entre vigencia inicial/final nao deve ser superior a 2 anos!"
              next field vigfnl
           end if

           if d_ctc34m03.vigfnl  <  d_ctc34m03.viginc + 30 units day   then
              error " Periodo entre vigencia inicial/final nao deve ser inferior a 30 dias!"
              next field vigfnl
           end if

           if d_ctc34m03.sgdirbcod  =  5886   then   #--> Porto Seguro
              if d_ctc34m03.viginc  <>  ws.viginc   or
                 d_ctc34m03.vigfnl  <>  ws.vigfnl   then
                 error " Vigencia informada difere da apolice --> ",
                       ws.viginc, " a ", ws.vigfnl
                 next field vigfnl
              end if
           end if

           call ctc34m03_vigencia (param.socvclcod  , d_ctc34m03.vclsgrseq,
                                   d_ctc34m03.viginc, d_ctc34m03.vigfnl)
                returning ws.vigerro

           if ws.vigerro  =  "s"   then
              next field vigfnl
           end if

    before field cbtcscflg
           display by name d_ctc34m03.cbtcscflg    attribute (reverse)

    after  field cbtcscflg
           display by name d_ctc34m03.cbtcscflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vigfnl
           end if

           if d_ctc34m03.cbtcscflg   is null   or
              (d_ctc34m03.cbtcscflg  <>  "N"   and
               d_ctc34m03.cbtcscflg  <>  "S")  then
              error " Apolice com cobertura Casco: (S)im ou (N)ao!"
              next field cbtcscflg
           end if

           if d_ctc34m03.sgdirbcod  =  5886   then  #--> Porto Seguro
              if d_ctc34m03.cbtcscflg  =  "S"   and
                 ws.cbtcscflg          =  "N"   then
                 error " Apolice nao possui cobertura Casco!"
                 next field cbtcscflg
              end if

              if d_ctc34m03.cbtcscflg  =  "N"   and
                 ws.cbtcscflg          =  "S"   then
                 error " Apolice possui cobertura Casco!"
                 next field cbtcscflg
              end if
           end if

    before field cbtrcfflg
           display by name d_ctc34m03.cbtrcfflg    attribute (reverse)

    after  field cbtrcfflg
           display by name d_ctc34m03.cbtrcfflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  cbtcscflg
           end if

           if d_ctc34m03.cbtrcfflg   is null   or
              (d_ctc34m03.cbtrcfflg  <>  "N"   and
               d_ctc34m03.cbtrcfflg  <>  "S")  then
              error " Apolice com cobertura Risco Civil Facultativo: (S)im ou (N)ao!"
              next field cbtrcfflg
           end if

           if d_ctc34m03.sgdirbcod  =  5886   then   #--> Porto Seguro
              if ws.dmimsvlrapl  is not null   or
                 ws.dpimsvlrapl  is not null   then
                 if d_ctc34m03.cbtrcfflg  =  "N"   then
                    error " Apolice possui cobertura Risco Civil Facultativo!"
                    next field cbtrcfflg
                 end if
              end if

              if ws.dmimsvlrapl  is null   and
                 ws.dpimsvlrapl  is null   then
                 if d_ctc34m03.cbtrcfflg  =  "S"   then
                    error " Apolice nao possui cobertura Risco Civil Facultativo!"
                    next field cbtrcfflg
                 end if
              end if
           end if

           if d_ctc34m03.cbtrcfflg  =  "N"    then
              initialize d_ctc34m03.sgrimsdmvlr  to null
              display by name d_ctc34m03.sgrimsdmvlr
              initialize d_ctc34m03.sgrimsdpvlr  to null
              display by name d_ctc34m03.sgrimsdpvlr

              next field cbtrcffvrflg
           end if

    before field sgrimsdmvlr
           display by name d_ctc34m03.sgrimsdmvlr    attribute (reverse)

    after  field sgrimsdmvlr
           display by name d_ctc34m03.sgrimsdmvlr

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  cbtrcfflg
           end if

           if d_ctc34m03.sgrimsdmvlr  <  10000.00      or
              d_ctc34m03.sgrimsdmvlr  >  1000000.00   then
              error " Valor da IS - Danos Materiais deve ser de 10.000,00 a 1.000.000,00!"
              next field sgrimsdmvlr
           end if

           if d_ctc34m03.sgdirbcod  =  5886   then   #--> Porto Seguro
              if d_ctc34m03.sgrimsdmvlr  is null       and
                 ws.dmimsvlrapl          is not null   then
                 error " Apolice possui Imp. Seg. para Danos Materiais --> ",
                      ws.dmimsvlrapl
                 next field sgrimsdmvlr
              end if

              if d_ctc34m03.sgrimsdmvlr  is not null   and
                 ws.dmimsvlrapl          is null       then
                 error " Apolice nao possui Imp. Seg. para Danos Materiais!"
                 next field sgrimsdmvlr
              end if

              if d_ctc34m03.sgrimsdmvlr  <>  ws.dmimsvlrapl   then
                error " Valor Imp. Seg. Danos Materiais difere da apolice --> ",
                      ws.dmimsvlrapl
                 next field sgrimsdmvlr
              end if
          end if

    before field sgrimsdpvlr
           display by name d_ctc34m03.sgrimsdpvlr    attribute (reverse)

    after  field sgrimsdpvlr
           display by name d_ctc34m03.sgrimsdpvlr

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  sgrimsdmvlr
           end if

           if d_ctc34m03.sgrimsdpvlr  <  10000.00      or
              d_ctc34m03.sgrimsdpvlr  >  1000000.00   then
              error " Valor da IS - Danos Pessoais deve ser de 10.000,00 a 1.000.000,00!"
              next field sgrimsdpvlr
           end if

           if d_ctc34m03.sgrimsdmvlr  is null   and
              d_ctc34m03.sgrimsdpvlr  is null   then
              error " Valor da IS - Danos Materiais ou Danos Pessoais deve ser informado!"
              next field sgrimsdpvlr
           end if

           if d_ctc34m03.sgdirbcod  =  5886   then   #--> Porto Seguro
              if d_ctc34m03.sgrimsdpvlr  is null       and
                 ws.dpimsvlrapl          is not null   then
                 error " Apolice possui Imp. Seg. para Danos Pessoais --> ",
                      ws.dpimsvlrapl
                 next field sgrimsdpvlr
              end if

              if d_ctc34m03.sgrimsdpvlr  is not null   and
                 ws.dpimsvlrapl          is null       then
                 error " Apolice nao possui Imp. Seg. para Danos Pessoais!"
                 next field sgrimsdpvlr
              end if

              if d_ctc34m03.sgrimsdpvlr  <>  ws.dpimsvlrapl   then
                error " Valor Imp. Seg. Danos Pessoais difere da apolice --> ",
                      ws.dpimsvlrapl
                 next field sgrimsdpvlr
              end if
          end if

    before field cbtrcffvrflg
           display by name d_ctc34m03.cbtrcffvrflg    attribute (reverse)

    after  field cbtrcffvrflg
           display by name d_ctc34m03.cbtrcffvrflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_ctc34m03.cbtrcfflg  =  "N"   then
                 next field  cbtrcfflg
              end if
              next field  sgrimsdpvlr
           end if

           if d_ctc34m03.cbtrcffvrflg   is null   or
              (d_ctc34m03.cbtrcffvrflg  <>  "N"   and
               d_ctc34m03.cbtrcffvrflg  <>  "S")  then
              error " Apolice com cobertura Risco Civil Operacional: (S)im ou (N)ao!"
              next field cbtrcffvrflg
           end if

           if d_ctc34m03.sgdirbcod  =  5886   then   #--> Porto Seguro
              if d_ctc34m03.cbtrcffvrflg  =  "N"        and
                 ws.clscod                is not null   then
                 error " Apolice possui cobertura Risco Civil Operacional (Clausula 111)!"
                 next field cbtrcffvrflg
              end if

              if d_ctc34m03.cbtrcffvrflg  =  "S"    and
                 ws.clscod                is null   then
                 error " Apolice nao possui cobertura Risco Civil Operacional (Clausula 111)!"
                 next field cbtrcffvrflg
              end if
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize d_ctc34m03.*  to null
    let obrseguro = int_flag
 end if

 return d_ctc34m03.*

end function    # ctc34m03_input


#--------------------------------------------------------------------
 function ctc34m03_remove(param, d_ctc34m03)
#--------------------------------------------------------------------

 define param         record
    socvclcod         like datkvclsgr.socvclcod
 end record

 define d_ctc34m03    record
    vclsgrseq         like datkvclsgr.vclsgrseq,
    sgdirbcod         like datkvclsgr.sgdirbcod,
    sgdnom            like gcckcong.sgdnom,
    aplporcab         char (13),
    ramcod            like datkvclsgr.ramcod,
    succod            like datkvclsgr.succod,
    aplnumdig         like datkvclsgr.aplnumdig,
    itmnumdig         like datkvclsgr.itmnumdig,
    aplconcab         char (13),
    sgraplnum         like datkvclsgr.sgraplnum,
    viginc            like datkvclsgr.viginc,
    vigfnl            like datkvclsgr.vigfnl,
    cbtcscflg         like datkvclsgr.cbtcscflg,
    cbtrcfflg         like datkvclsgr.cbtrcfflg,
    sgrimsdmvlr       like datkvclsgr.sgrimsdmvlr,
    sgrimsdpvlr       like datkvclsgr.sgrimsdpvlr,
    cbtrcffvrflg      like datkvclsgr.cbtrcffvrflg,
    atldat            like datkvclsgr.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    socvclcod         like datreqpvcl.socvclcod
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  ws.*  to  null

 initialize ws.*  to null

 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui a apolice"
            clear form
            initialize d_ctc34m03.* to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui apolice"
            call ctc34m03_ler(param.socvclcod, d_ctc34m03.vclsgrseq)
                 returning d_ctc34m03.*

            if sqlca.sqlcode = notfound  then
               initialize d_ctc34m03.* to null
               error " Apolice nao localizada!"
            else
               if d_ctc34m03.vigfnl  <  today   then
                  initialize d_ctc34m03.* to null
                  error " Apolice com vigencia ja' encerrada nao deve ser removida!"
               else
                  begin work
                     delete from datkvclsgr
                      where datkvclsgr.socvclcod = param.socvclcod
                        and datkvclsgr.vclsgrseq = d_ctc34m03.vclsgrseq
                  commit work

                  if sqlca.sqlcode <> 0   then
                     initialize d_ctc34m03.* to null
                     error " Erro (",sqlca.sqlcode,") na exlusao da apolice!"
                  else
                     initialize d_ctc34m03.* to null
                     error   " Apolice excluida!"
                     message ""
                     clear form
                  end if
               end if
            end if
               exit menu
 end menu

 return d_ctc34m03.*

end function    # ctc34m03_remove


#---------------------------------------------------------
 function ctc34m03_ler(param)
#---------------------------------------------------------

 define param         record
    socvclcod         like datkvclsgr.socvclcod,
    vclsgrseq         like datkvclsgr.vclsgrseq
 end record

 define d_ctc34m03    record
    vclsgrseq         like datkvclsgr.vclsgrseq,
    sgdirbcod         like datkvclsgr.sgdirbcod,
    sgdnom            like gcckcong.sgdnom,
    aplporcab         char (13),
    ramcod            like datkvclsgr.ramcod,
    succod            like datkvclsgr.succod,
    aplnumdig         like datkvclsgr.aplnumdig,
    itmnumdig         like datkvclsgr.itmnumdig,
    aplconcab         char (13),
    sgraplnum         like datkvclsgr.sgraplnum,
    viginc            like datkvclsgr.viginc,
    vigfnl            like datkvclsgr.vigfnl,
    cbtcscflg         like datkvclsgr.cbtcscflg,
    cbtrcfflg         like datkvclsgr.cbtrcfflg,
    sgrimsdmvlr       like datkvclsgr.sgrimsdmvlr,
    sgrimsdpvlr       like datkvclsgr.sgrimsdpvlr,
    cbtrcffvrflg      like datkvclsgr.cbtrcffvrflg,
    atldat            like datkvclsgr.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  d_ctc34m03.*  to  null

	initialize  ws.*  to  null

 initialize d_ctc34m03.*   to null
 initialize ws.*           to null

 select  vclsgrseq,
         viginc,
         vigfnl,
         sgdirbcod,
         ramcod,
         succod,
         aplnumdig,
         itmnumdig,
         sgraplnum,
         cbtcscflg,
         cbtrcfflg,
         sgrimsdmvlr,
         sgrimsdpvlr,
         cbtrcffvrflg,
         atldat,
         atlemp,
         atlmat
   into  d_ctc34m03.vclsgrseq,
         d_ctc34m03.viginc,
         d_ctc34m03.vigfnl,
         d_ctc34m03.sgdirbcod,
         d_ctc34m03.ramcod,
         d_ctc34m03.succod,
         d_ctc34m03.aplnumdig,
         d_ctc34m03.itmnumdig,
         d_ctc34m03.sgraplnum,
         d_ctc34m03.cbtcscflg,
         d_ctc34m03.cbtrcfflg,
         d_ctc34m03.sgrimsdmvlr,
         d_ctc34m03.sgrimsdpvlr,
         d_ctc34m03.cbtrcffvrflg,
         d_ctc34m03.atldat,
         ws.atlemp,
         ws.atlmat
   from  datkvclsgr
  where  datkvclsgr.socvclcod = param.socvclcod
    and  datkvclsgr.vclsgrseq = param.vclsgrseq

 if sqlca.sqlcode = notfound   then
    error " Apolice nao cadastrada!"
    initialize d_ctc34m03.*    to null
    return d_ctc34m03.*
 else

    if d_ctc34m03.sgdirbcod  =  5886   then   #--> Porto Seguro
       let d_ctc34m03.aplporcab = "Apolice.....:"
    else
       let d_ctc34m03.aplconcab = "Apolice.....:"
    end if

    select sgdnom
      into d_ctc34m03.sgdnom
      from gcckcong
     where gcckcong.sgdirbcod = d_ctc34m03.sgdirbcod

    call ctc34m03_func(ws.atlemp, ws.atlmat)
         returning d_ctc34m03.funnom
 end if

 return d_ctc34m03.*

 end function   # ctc34m03_ler


#---------------------------------------------------------
 function ctc34m03_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  ws.*  to  null

 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = param.empcod
    and isskfunc.funmat = param.funmat

 return ws.funnom

 end function   # ctc34m03_func


#---------------------------------------------------------
 function ctc34m03_vigencia(param)
#---------------------------------------------------------

 define param         record
    socvclcod         like datkvclsgr.socvclcod,
    vclsgrseq         like datkvclsgr.vclsgrseq,
    viginc            like datkvclsgr.viginc,
    vigfnl            like datkvclsgr.vigfnl
 end record

 define ws            record
    vclsgrseq         like datkvclsgr.vclsgrseq,
    vigtip            integer,
    vigtipdes         char(14),
    vigdat            like datkvclsgr.vigfnl,
    errotip           char(01),
    vigerro           char(01)
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  ws.*  to  null

 initialize ws.*          to null
 let ws.vigerro = "n"

 if param.vclsgrseq   is null    then
    let param.vclsgrseq = 0
 end if

 for ws.vigtip = 1 to 2

    case ws.vigtip
         when  1  let ws.vigtipdes  =  "(vig.inicial)"
                  let ws.vigdat     =  param.viginc
         when  2  let ws.vigtipdes  =  "(vig.final)"
                  let ws.vigdat     =  param.vigfnl
    end case

    select vclsgrseq
      into ws.vclsgrseq
      from datkvclsgr
     where datkvclsgr.socvclcod  =  param.socvclcod
       and ws.vigdat  between viginc and vigfnl
       and datkvclsgr.vclsgrseq  <>  param.vclsgrseq

     if ws.vclsgrseq  is not null   then
        let ws.errotip  =  1
     else
        select vclsgrseq
          into ws.vclsgrseq
          from datkvclsgr
         where datkvclsgr.socvclcod  =  param.socvclcod
           and datkvclsgr.viginc     >  param.viginc
           and datkvclsgr.vigfnl     <  param.vigfnl
           and datkvclsgr.vclsgrseq  <> param.vclsgrseq

        if ws.vclsgrseq  is not null   then
           let ws.errotip = 2
        end if
     end if

    if ws.vclsgrseq  is not null   then
       if ws.errotip  =  1   then
          error " Existe apolice vigente ", ws.vigtipdes  clipped,
                " --> ", ws.vclsgrseq
       else
          error " Existe apolice vigente neste periodo",
                " --> ", ws.vclsgrseq
       end if

       let ws.vigerro = "s"
       exit for
    end if
 end for

 return ws.vigerro

 end function   # ctc34m03_vigencia
 
# 15/09/2010 PSI201000009EV Beatriz - 
# Funcao que obriga a inclusao de ao menos um seguro de vida para a viatura
#------------------------------------------------------------   
 function ctc34m03_obrigaseg(param)                             
#------------------------------------------------------------   
 
 define param         record
       socvclcod         like datkvclsgr.socvclcod,
       atdvclsgl         like datkveiculo.atdvclsgl,
       vcldes            char (58),
       socvcltip         like datkveiculo.socvcltip
 end record
 
 define d_ctc34m03 record
    vclsgrseq   like datkvclsgr.vclsgrseq,
    aplporcab   char (13),
    cabec       char (200),
    cpodes      like iddkdominio.cpodes
 end record 
 
 define l_confirma       char(1) 
 
 initialize l_confirma to null
  
  # select que verifica se a viatura tem seguro  
  select max(datkvclsgr.vclsgrseq)
    into d_ctc34m03.vclsgrseq
    from datkvclsgr
  where datkvclsgr.socvclcod  =  param.socvclcod
  
  if d_ctc34m03.vclsgrseq  is null then
  
    select cpodes 
      from iddkdominio
     where cponom = 'ctc34m03_sgrvcl'
       and cpodes = param.socvcltip
    if sqlca.sqlcode = 0 then 
       let obrseguro = true 
       if not get_niv_mod(g_issk.prgsgl, "ctc34m03") then
          error " Modulo sem nivel de consulta e atualizacao!"
          return
       end if
       
       open window ctc34m03 at 4,2 with form "ctc34m03"
       
       let d_ctc34m03.cabec = "PARA ESTE TIPO DE VEÍCULO DEVE HAVER AO MENOS UMA APOLICE DE SEGURO"
       display by name param.socvclcod   attribute(reverse)
       display by name param.atdvclsgl   attribute(reverse)
       display by name param.vcldes      attribute(reverse)
       display by name d_ctc34m03.cabec  attribute(reverse)
       
       let d_ctc34m03.aplporcab = "Apolice.....:"
       display by name d_ctc34m03.aplporcab
       
       
       menu "SEGUROS"
       
          before menu
             hide option all
             show option "Inclui"  
             show option "Encerra"           
             
             command key ("I") "Inclui"
                               "Inclui apolice"
                      message ""
                      call ctc34m03_inclui(param.socvclcod)
                      display "int_flag no menu: ",int_flag 
                      display "obrseguro no menu: ",obrseguro
                      if int_flag = true or
                         obrseguro = true then
                         call cts08g01("A","N",
                                          " Senhor Usuario,  ",
                                          "","E obrigatorio infomar pelo menos uma","apolice de seguro.")
                                 returning l_confirma
                         call ctc34m03_inclui(param.socvclcod) 
                      end if  
                      
             command key (interrupt,E) "Encerra" 
                                       "Retorna ao menu anterior"
                      display "int_flag  para sair: ",int_flag 
                      display "obrseguro para sair: ",obrseguro
                      if int_flag = true or
                         obrseguro = true then
                         call cts08g01("A","N",
                                          " Senhor Usuario,  ",
                                          "","E obrigatorio infomar pelo menos uma","apolice de seguro.")
                                 returning l_confirma
                         call ctc34m03_inclui(param.socvclcod)
                      else
                         exit menu            
                      end if                     
       end menu
       
       close window ctc34m03
    end if  
  end if   
end function

