###########################################################################
# Nome do Modulo: ctc32m00                                        Marcelo #
#                                                                Gilberto #
# Cadastro de bloqueios de atendimento                           Abr/1998 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
# 06/06/2001  PSI 13253-5  Wagner       Inclusao nova situacao prestador  #
#                                       B-Bloqueado.                      #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#-------------------------------------------------------------------------#
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso#
###########################################################################


 globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_dtresol86      date

#------------------------------------------------------------
 function ctc32m00()
#------------------------------------------------------------

 define ctc32m00      record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    chassi            char (20),
    corsus            like datkblq.corsus,
    cornom            like gcakcorr.cornom,
    pstcoddig         like datkblq.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    segnumdig         like datkblq.segnumdig,
    segnom            like gsakseg.segnom,
    ctgtrfcod         like datkblq.ctgtrfcod,
    ctgtrfdes         like agekcateg.ctgtrfdes,
    blqnivcod         like datkblq.blqnivcod,
    blqnivdes         char(15),
    blqanlflg         like datkblq.blqanlflg,
    caddat            like datkblq.caddat,
    cadhor            like datkblq.cadhor,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkblq.atldat,
    atlhor            like datkblq.atlhor,
    funnom            like isskfunc.funnom
 end record

 define ws_ramcod     like datkblq.ramcod
 define ws_confirma   char (01)

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc32m00") then
 #   error "Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 let int_flag = false

 initialize ctc32m00.*  to null

 open window ctc32m00 at 04,02 with form "ctc32m00"


 menu "BLOQUEIOS"

 before menu
          hide option all
          #PSI 202290
          #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
          #      show option "Seleciona", "Proximo", "Anterior"
          #end if
          #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica" , "assunTos", "matriCulas",
                            "Observacoes", "Inclui", "Remove"
          #end if

          show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa bloqueio conforme criterios"
          call ctc32m00_seleciona()  returning ctc32m00.*
          if ctc32m00.blqnum  is not null   then
             message ""
             next option "Proximo"
          else
             error " Nenhum bloqueio selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo bloqueio selecionado"
          message ""
          call ctc32m00_proximo(ctc32m00.blqnum)  returning ctc32m00.*

 command key ("A") "Anterior"
                   "Mostra bloqueio anterior selecionado"
          message ""
          if ctc32m00.blqnum  is not null   then
             call ctc32m00_anterior(ctc32m00.blqnum)  returning ctc32m00.*
          else
             error " Nenhum bloqueio nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica bloqueio corrente selecionado"
          message ""
          if ctc32m00.blqnum  is not null   then
             if ctc32m00.vigfnl  <  today   then
                error " Bloqueio com vigencia encerrada nao deve ser alterado!"
             else
                call ctc32m00_modifica(ctc32m00.*)  returning ctc32m00.*
                next option "Seleciona"
             end if
          else
             error " Nenhum bloqueio selecionado!"
             next option "Seleciona"
          end if

 command key ("T") "assunTos"
                   "Assuntos cadastrados para bloqueio selecionado"
          message ""
          if ctc32m00.blqnum  is not null   then
             let ws_ramcod = ctc32m00.ramcod
             if ctc32m00.vcllicnum  is not null   or
                ctc32m00.chassi     is not null   then

                select grlinf[01,10] into m_dtresol86
                    from datkgeral
                    where grlchv='ct24resolucao86'

                if m_dtresol86 <= today then
                   let ws_ramcod = 531
                else
                   let ws_ramcod = 31
                end if
             end if
             call ctc32m01(ctc32m00.blqnum, ctc32m00.vigfnl, ws_ramcod)
          else
             error " Nenhum bloqueio selecionado!"
             next option "Seleciona"
          end if

 command key ("C") "matriCulas"
                   "Matriculas com permissao de liberar bloqueio selecionado"
          message ""
          if ctc32m00.blqnum  is not null   then
             if ctc32m00.blqnivcod  <>  2   then
                error " Cadastramento de matriculas apenas p/ nivel de bloqueio (2)!"
             else
                call ctc32m02(ctc32m00.blqnum, ctc32m00.vigfnl)
                next option "Seleciona"
             end if
          else
             error " Nenhum bloqueio selecionado!"
             next option "Seleciona"
          end if

 command key ("O") "Observacoes"
                   "Observacoes para o bloqueio selecionado"
          message ""
          if ctc32m00.blqnum  is not null   then
             call ctc32m03(ctc32m00.blqnum, ctc32m00.vigfnl)
          else
             error " Nenhum bloqueio selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui bloqueio"
          message ""
          call cts08g01("A","N","PARA QUE O SISTEMA REALIZE O BLOQUEIO",
                                "E' NECESSARIO QUE OS  ( ASSUNTOS ),",
                                "( OBSERVACOES ),  ( MATRICULAS )",
                                "SEJAM CADASTRADOS")
                returning ws_confirma

          call ctc32m00_inclui()
          next option "Seleciona"

 command key ("R") "Remove"
                   "Remove bloqueio corrente selecionado"
          message ""
          if ctc32m00.blqnum  is not null   then
             if ctc32m00.vigfnl  <  today   then
                error " Bloqueio com vigencia encerrada nao deve ser removido!"
             else
                if ctc32m00.viginc  <=  today   then
                   error " Bloqueio vigente nao deve ser removido!"
                else
                   call ctc32m00_remove(ctc32m00.*)  returning ctc32m00.*
                   next option "Seleciona"
                end if
             end if
          else
             error " Nenhum bloqueio selecionado!"
             next option "Seleciona"
          end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc32m00

 end function  # ctc32m00


#------------------------------------------------------------
 function ctc32m00_seleciona()
#------------------------------------------------------------

 define ctc32m00      record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    chassi            char (20),
    corsus            like datkblq.corsus,
    cornom            like gcakcorr.cornom,
    pstcoddig         like datkblq.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    segnumdig         like datkblq.segnumdig,
    segnom            like gsakseg.segnom,
    ctgtrfcod         like datkblq.ctgtrfcod,
    ctgtrfdes         like agekcateg.ctgtrfdes,
    blqnivcod         like datkblq.blqnivcod,
    blqnivdes         char(15),
    blqanlflg         like datkblq.blqanlflg,
    caddat            like datkblq.caddat,
    cadhor            like datkblq.cadhor,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkblq.atldat,
    atlhor            like datkblq.atlhor,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize ctc32m00.*  to null
 display by name ctc32m00.*

 input by name ctc32m00.blqnum

    before field blqnum
        display by name ctc32m00.blqnum  attribute (reverse)

    after  field blqnum
        display by name ctc32m00.blqnum

        if ctc32m00.blqnum   is null   then
           error " Codigo de bloqueio deve ser informado!"
           next field blqnum
        end if

        select datkblq.blqnum
          from datkblq
         where datkblq.blqnum = ctc32m00.blqnum

        if sqlca.sqlcode  =  notfound   then
           error " Codigo de bloqueio nao cadastrado!"
           next field blqnum
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc32m00.*   to null
    display by name ctc32m00.*
    error " Operacao cancelada!"
    return ctc32m00.*
 end if

 call ctc32m00_ler(ctc32m00.blqnum)  returning ctc32m00.*

 if ctc32m00.blqnum  is not null   then
    display by name  ctc32m00.*
 else
    error " Bloqueio nao cadastrado!"
    initialize ctc32m00.*    to null
 end if

 return ctc32m00.*

 end function  # ctc32m00_seleciona


#------------------------------------------------------------
 function ctc32m00_proximo(param)
#------------------------------------------------------------

 define param         record
    blqnum            like datkblq.blqnum
 end record

 define ctc32m00      record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    chassi            char (20),
    corsus            like datkblq.corsus,
    cornom            like gcakcorr.cornom,
    pstcoddig         like datkblq.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    segnumdig         like datkblq.segnumdig,
    segnom            like gsakseg.segnom,
    ctgtrfcod         like datkblq.ctgtrfcod,
    ctgtrfdes         like agekcateg.ctgtrfdes,
    blqnivcod         like datkblq.blqnivcod,
    blqnivdes         char(15),
    blqanlflg         like datkblq.blqanlflg,
    caddat            like datkblq.caddat,
    cadhor            like datkblq.cadhor,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkblq.atldat,
    atlhor            like datkblq.atlhor,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize ctc32m00.*   to null

 if param.blqnum  is null  then
    let param.blqnum = 0
 end if

 select min(datkblq.blqnum)
   into ctc32m00.blqnum
   from datkblq
  where datkblq.blqnum > param.blqnum

 if ctc32m00.blqnum  is not null   then

    call ctc32m00_ler(ctc32m00.blqnum)  returning ctc32m00.*

    if ctc32m00.blqnum  is not null   then
       display by name  ctc32m00.*
    else
       error " Nao ha' bloqueio nesta direcao!"
       initialize ctc32m00.*    to null
    end if
 else
    error " Nao ha' bloqueio nesta direcao!"
    initialize ctc32m00.*   to null
 end if

 return ctc32m00.*

 end function    # ctc32m00_proximo


#------------------------------------------------------------
 function ctc32m00_anterior(param)
#------------------------------------------------------------

 define param         record
    blqnum            like datkblq.blqnum
 end record

 define ctc32m00      record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    chassi            char (20),
    corsus            like datkblq.corsus,
    cornom            like gcakcorr.cornom,
    pstcoddig         like datkblq.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    segnumdig         like datkblq.segnumdig,
    segnom            like gsakseg.segnom,
    ctgtrfcod         like datkblq.ctgtrfcod,
    ctgtrfdes         like agekcateg.ctgtrfdes,
    blqnivcod         like datkblq.blqnivcod,
    blqnivdes         char(15),
    blqanlflg         like datkblq.blqanlflg,
    caddat            like datkblq.caddat,
    cadhor            like datkblq.cadhor,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkblq.atldat,
    atlhor            like datkblq.atlhor,
    funnom            like isskfunc.funnom
 end record


 let int_flag = false
 initialize ctc32m00.*  to null

 if param.blqnum  is null   then
    let param.blqnum = 0
 end if

 select max(datkblq.blqnum)
   into ctc32m00.blqnum
   from datkblq
  where datkblq.blqnum < param.blqnum

 if ctc32m00.blqnum  is not null   then

    call ctc32m00_ler(ctc32m00.blqnum)  returning ctc32m00.*

    if ctc32m00.blqnum  is not null   then
       display by name  ctc32m00.*
    else
       error " Nao ha' bloqueio nesta direcao!"
       initialize ctc32m00.*    to null
    end if
 else
    error " Nao ha' bloqueio nesta direcao!"
    initialize ctc32m00.*   to null
 end if

 return ctc32m00.*

 end function    # ctc32m00_anterior


#------------------------------------------------------------
 function ctc32m00_modifica(ctc32m00)
#------------------------------------------------------------

 define ctc32m00      record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    chassi            char (20),
    corsus            like datkblq.corsus,
    cornom            like gcakcorr.cornom,
    pstcoddig         like datkblq.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    segnumdig         like datkblq.segnumdig,
    segnom            like gsakseg.segnom,
    ctgtrfcod         like datkblq.ctgtrfcod,
    ctgtrfdes         like agekcateg.ctgtrfdes,
    blqnivcod         like datkblq.blqnivcod,
    blqnivdes         char(15),
    blqanlflg         like datkblq.blqanlflg,
    caddat            like datkblq.caddat,
    cadhor            like datkblq.cadhor,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkblq.atldat,
    atlhor            like datkblq.atlhor,
    funnom            like isskfunc.funnom
 end record


 call ctc32m00_input("a", ctc32m00.*)  returning ctc32m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc32m00.*  to null
    display by name ctc32m00.*
    error " Operacao cancelada!"
    return ctc32m00.*
 end if

 whenever error continue

 begin work
    update datkblq set  ( viginc,
                          vigfnl,
                          blqnivcod,
                          blqanlflg,
                          atldat,
                          atlhor,
                          atlemp,
                          atlmat )
                    =
                        ( ctc32m00.viginc,
                          ctc32m00.vigfnl,
                          ctc32m00.blqnivcod,
                          ctc32m00.blqanlflg,
                          today,
                          current hour to minute,
                          g_issk.empcod,
                          g_issk.funmat )
           where datkblq.blqnum  =  ctc32m00.blqnum

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do bloqueio!"
       rollback work
       initialize ctc32m00.*   to null
       return ctc32m00.*
    end if

    #-----------------------------------------------------------------
    # Niveis nao necessitam de liberacao (matriculas)
    #-----------------------------------------------------------------
    if ctc32m00.blqnivcod  =  1  or
       ctc32m00.blqnivcod  =  3  then

       delete from datrfunblqlib
        where blqnum = ctc32m00.blqnum

       if sqlca.sqlcode <>  0  then
          error " Erro (",sqlca.sqlcode,") na alteracao do bloqueio!"
          rollback work
          initialize ctc32m00.*   to null
          return ctc32m00.*
       end if
    end if
    error " Alteracao efetuada com sucesso!"

 commit work

 whenever error stop

 if ctc32m00.blqnivcod  =  2   then
   error " Cadastre/verifique as matriculas com permissao p/ liberar o bloqueio"
    call ctc32m02(ctc32m00.blqnum, ctc32m00.vigfnl)
 end if

 initialize ctc32m00.*  to null
 display by name ctc32m00.*
 message ""
 return ctc32m00.*

 end function   #  ctc32m00_modifica


#------------------------------------------------------------
 function ctc32m00_inclui()
#------------------------------------------------------------

 define ctc32m00      record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    chassi            char (20),
    corsus            like datkblq.corsus,
    cornom            like gcakcorr.cornom,
    pstcoddig         like datkblq.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    segnumdig         like datkblq.segnumdig,
    segnom            like gsakseg.segnom,
    ctgtrfcod         like datkblq.ctgtrfcod,
    ctgtrfdes         like agekcateg.ctgtrfdes,
    blqnivcod         like datkblq.blqnivcod,
    blqnivdes         char(15),
    blqanlflg         like datkblq.blqanlflg,
    caddat            like datkblq.caddat,
    cadhor            like datkblq.cadhor,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkblq.atldat,
    atlhor            like datkblq.atlhor,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    vclchsinc         like datkblq.vclchsinc,
    vclchsfnl         like datkblq.vclchsfnl
 end record

 define ws_resp       char(01)


 initialize ws.*         to null
 initialize ctc32m00.*   to null
 display by name ctc32m00.*

 call ctc32m00_input("i", ctc32m00.*)  returning ctc32m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc32m00.*  to null
    display by name ctc32m00.*
    error " Operacao cancelada!"
    return
 end if

 declare c_ctc32m00m  cursor with hold  for
    select max(blqnum)
      from datkblq
     where datkblq.blqnum > 0

 foreach c_ctc32m00m  into  ctc32m00.blqnum
    exit foreach
 end foreach

 if ctc32m00.blqnum   is null   then
    let ctc32m00.blqnum = 0
 end if
 let ctc32m00.blqnum = ctc32m00.blqnum + 1

 let ctc32m00.caddat = today
 let ctc32m00.cadhor = current hour to minute
 let ctc32m00.atldat = today
 let ctc32m00.atlhor = current hour to minute

 #---------------------------------------------------------------------
 # Divide em 2 campos (Chassi inicial/Chassi final)
 #---------------------------------------------------------------------
 let ws.vclchsinc = ctc32m00.chassi[01,12]
 let ws.vclchsfnl = ctc32m00.chassi[13,20]


 whenever error continue

 begin work
    insert into datkblq ( blqnum,
                          viginc,
                          vigfnl,
                          ramcod,
                          succod,
                          aplnumdig,
                          itmnumdig,
                          vcllicnum,
                          vclchsinc,
                          vclchsfnl,
                          corsus,
                          pstcoddig,
                          segnumdig,
                          ctgtrfcod,
                          blqnivcod,
                          blqanlflg,
                          caddat,
                          cadhor,
                          cademp,
                          cadmat,
                          atldat,
                          atlhor,
                          atlemp,
                          atlmat )
                values
                        ( ctc32m00.blqnum,
                          ctc32m00.viginc,
                          ctc32m00.vigfnl,
                          ctc32m00.ramcod,
                          ctc32m00.succod,
                          ctc32m00.aplnumdig,
                          ctc32m00.itmnumdig,
                          ctc32m00.vcllicnum,
                          ws.vclchsinc,
                          ws.vclchsfnl,
                          ctc32m00.corsus,
                          ctc32m00.pstcoddig,
                          ctc32m00.segnumdig,
                          ctc32m00.ctgtrfcod,
                          ctc32m00.blqnivcod,
                          ctc32m00.blqanlflg,
                          today,
                          current hour to minute,
                          g_issk.empcod,
                          g_issk.funmat,
                          today,
                          current hour to minute,
                          g_issk.empcod,
                          g_issk.funmat )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do bloqueio!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc32m00_func(g_issk.empcod, g_issk.funmat)
      returning ctc32m00.cadfunnom

 call ctc32m00_func(g_issk.empcod, g_issk.funmat)
      returning ctc32m00.funnom

 display by name  ctc32m00.*

 display by name ctc32m00.blqnum attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 error " Cadastre observacoes para o bloqueio incluido"
 call ctc32m03(ctc32m00.blqnum, ctc32m00.vigfnl)

 error " Cadastre os assuntos para o bloqueio incluido"
 call ctc32m01(ctc32m00.blqnum, ctc32m00.vigfnl, ctc32m00.ramcod)

 if ctc32m00.blqnivcod  =  2   then
    error " Cadastre as matriculas com permissao p/ liberar o bloqueio incluido"
    call ctc32m02(ctc32m00.blqnum, ctc32m00.vigfnl)
 end if

 initialize ctc32m00.*  to null
 display by name ctc32m00.*

 end function   #  ctc32m00_inclui


#--------------------------------------------------------------------
function ctc32m00_remove(ctc32m00)
#--------------------------------------------------------------------

 define ctc32m00      record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    chassi            char (20),
    corsus            like datkblq.corsus,
    cornom            like gcakcorr.cornom,
    pstcoddig         like datkblq.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    segnumdig         like datkblq.segnumdig,
    segnom            like gsakseg.segnom,
    ctgtrfcod         like datkblq.ctgtrfcod,
    ctgtrfdes         like agekcateg.ctgtrfdes,
    blqnivcod         like datkblq.blqnivcod,
    blqnivdes         char(15),
    blqanlflg         like datkblq.blqanlflg,
    caddat            like datkblq.caddat,
    cadhor            like datkblq.cadhor,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkblq.atldat,
    atlhor            like datkblq.atlhor,
    funnom            like isskfunc.funnom
 end record


 menu "Confirma Exclusao ?"

    command "Nao" "Nao exclui o bloqueio"
            clear form
            initialize ctc32m00.*   to null
            error " Exclusao cancelada!"
            exit menu

    command "Sim" "Exclui bloqueio"

            select blqnum
              from datkblq
             where blqnum = ctc32m00.blqnum

            if sqlca.sqlcode = notfound  then
               initialize ctc32m00.*   to null
               error " Bloqueio nao localizado!"
            else

               begin work
                  delete from datkblq
                   where datkblq.blqnum = ctc32m00.blqnum

                  delete from datmblqobs
                   where datmblqobs.blqnum = ctc32m00.blqnum

                  delete from datrastblq
                   where datrastblq.blqnum = ctc32m00.blqnum

                  delete from datrfunblqlib
                   where datrfunblqlib.blqnum = ctc32m00.blqnum
               commit work

               if sqlca.sqlcode <> 0   then
                  initialize ctc32m00.*   to null
                  error " Erro (",sqlca.sqlcode,") na exlusao do bloqueio!"
               else
                  initialize ctc32m00.*   to null
                  error   " Bloqueio excluido!"
                  message ""
                  clear form
               end if
            end if
            exit menu
 end menu

 return ctc32m00.*

end function    # ctc32m00_remove


#--------------------------------------------------------------------
 function ctc32m00_input(param, ctc32m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char(01)
 end record

 define ctc32m00      record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    chassi            char (20),
    corsus            like datkblq.corsus,
    cornom            like gcakcorr.cornom,
    pstcoddig         like datkblq.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    segnumdig         like datkblq.segnumdig,
    segnom            like gsakseg.segnom,
    ctgtrfcod         like datkblq.ctgtrfcod,
    ctgtrfdes         like agekcateg.ctgtrfdes,
    blqnivcod         like datkblq.blqnivcod,
    blqnivdes         char(15),
    blqanlflg         like datkblq.blqanlflg,
    caddat            like datkblq.caddat,
    cadhor            like datkblq.cadhor,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkblq.atldat,
    atlhor            like datkblq.atlhor,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    aplstt            like abamapol.aplstt,
    vigfnl            like abamapol.vigfnl,
    itmsttatu         like abbmitem.itmsttatu,
    prssitcod         like dpaksocor.prssitcod,
    blqnum            like datkblq.blqnum,
    sgrorg            like rsamseguro.sgrorg,
    sgrnumdig         like rsamseguro.sgrnumdig,
    vigerro           char(01),
    contpos           integer,
    contpos2          integer,
    sqlca             integer,
    confirma          char (01)
 end record


 let int_flag = false
 initialize ws.*  to null

 input by name  ctc32m00.blqnum,
                ctc32m00.viginc,
                ctc32m00.vigfnl,
                ctc32m00.ramcod,
                ctc32m00.succod,
                ctc32m00.aplnumdig,
                ctc32m00.itmnumdig,
                ctc32m00.vcllicnum,
                ctc32m00.chassi,
                ctc32m00.corsus,
                ctc32m00.pstcoddig,
                ctc32m00.segnumdig,
                ctc32m00.ctgtrfcod,
                ctc32m00.blqnivcod,
                ctc32m00.blqanlflg   without defaults

    before field blqnum
            if param.operacao  =  "i"  then
               next field viginc
            else
               if ctc32m00.viginc  >  today   then
                  next field viginc
               else
                  next field vigfnl
               end if
            end if

    before field viginc
           display by name ctc32m00.viginc  attribute (reverse)

    after  field viginc
           display by name ctc32m00.viginc

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field viginc
           end if

           if ctc32m00.viginc  is null   then
              error " Vigencia inicial deve ser informada!"
              next field viginc
           end if

           if ctc32m00.viginc  <  today   then
              error " Vigencia inicial nao deve ser anterior a data atual!"
              next field viginc
           end if

           if ctc32m00.viginc  >  today + 15 units day  then
              error " Vigencia inicial nao deve ser superior a 15 dias!"
              next field viginc
           end if

    before field vigfnl
           display by name ctc32m00.vigfnl  attribute (reverse)

    after  field vigfnl
           display by name ctc32m00.vigfnl

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.operacao  =  "a"     and
                 ctc32m00.viginc <= today   then
                 next field vigfnl
              end if
              next field viginc
           end if

           if ctc32m00.vigfnl  is null   then
              error " Vigencia final deve ser informada!"
              next field vigfnl
           end if

           if ctc32m00.vigfnl  <  today   then
              error " Vigencia final deve ser maior ou igual a data atual!"
              next field vigfnl
           end if

           if ctc32m00.vigfnl  <  ctc32m00.viginc  then
             error " Vigencia final deve ser maior ou igual a vigencia inicial!"
              next field vigfnl
           end if

           if param.operacao  =  "a"   then

              call ctc32m00_vigencia(ctc32m00.blqnum   , ctc32m00.viginc   ,
                                     ctc32m00.vigfnl   , ctc32m00.ramcod   ,
                                     ctc32m00.succod   , ctc32m00.aplnumdig,
                                     ctc32m00.itmnumdig, ctc32m00.vcllicnum,
                                     ctc32m00.chassi   , ctc32m00.corsus   ,
                                     ctc32m00.pstcoddig, ctc32m00.segnumdig,
                                     ctc32m00.ctgtrfcod)
                   returning ws.vigerro

              if ws.vigerro  =  "s"   then
                 next field vigfnl
              end if

              next field blqnivcod
           end if

    before field ramcod
           display by name ctc32m00.ramcod  attribute (reverse)

    after  field ramcod
           display by name ctc32m00.ramcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field vigfnl
           end if

           if ctc32m00.ramcod  is null   then
              initialize ctc32m00.succod     to null
              initialize ctc32m00.aplnumdig  to null
              initialize ctc32m00.itmnumdig  to null

              display by name ctc32m00.succod
              display by name ctc32m00.aplnumdig
              display by name ctc32m00.itmnumdig
              next field vcllicnum
           end if

           select ramcod
             from gtakram
            where ramcod = ctc32m00.ramcod
              and empcod = 1

           if sqlca.sqlcode  =  notfound   then
              error " Ramo nao cadastrado!"
              next field ramcod
           end if

           if ctc32m00.ramcod  is not null   and
              ctc32m00.ramcod  <>  31        and 
              ctc32m00.ramcod  <> 531        then
              initialize ctc32m00.itmnumdig  to null
              display by name ctc32m00.itmnumdig
           end if

    before field succod
           display by name ctc32m00.succod  attribute (reverse)

    after  field succod
           display by name ctc32m00.succod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field ramcod
           end if

           if ctc32m00.succod  is null   then
              error " Codigo da sucursal deve ser informado!"
              next field succod
           end if

           select succod
             from gabksuc
            where succod = ctc32m00.succod

           if sqlca.sqlcode  =  notfound   then
              error " Sucursal nao cadastrada!"
              next field succod
           end if

    before field aplnumdig
           display by name ctc32m00.aplnumdig  attribute (reverse)

    after  field aplnumdig
           display by name ctc32m00.aplnumdig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field succod
           end if

           if ctc32m00.aplnumdig  is null   then
              error " Numero da apolice deve ser informado!"
              next field aplnumdig
           end if

           #-----------------------------------------------------------
           # Consulta apolice de Automovel
           #-----------------------------------------------------------
           initialize ws.aplstt  to null
           initialize ws.vigfnl  to null

           if ctc32m00.ramcod  =  31   or  
              ctc32m00.ramcod  =  531   then
              select vigfnl, aplstt
                into ws.vigfnl, ws.aplstt
                from abamapol
               where succod    = ctc32m00.succod
                 and aplnumdig = ctc32m00.aplnumdig

              if sqlca.sqlcode  =  notfound   then
                 error " Apolice nao cadastrada!"
                 next field aplnumdig
              end if

              if ws.aplstt  <>  "A"   then
                 error " Apolice cancelada!"
                 call cts08g01("A", "N", "", "APOLICE CANCELADA", "", "")
                      returning ws.confirma
              end if

              if ctc32m00.vigfnl  >  ws.vigfnl + 30 units day   then
                 error " Vig. final bloqueio superior vig.final apolice + 30 dias --> ", ws.vigfnl
                 next field aplnumdig
              end if

              if ctc32m00.vigfnl  >  ws.vigfnl   then
                 error " Vig. final bloqueio maior que vig.final apolice --> ",
                       ws.vigfnl
                 call cts08g01("A", "N", "",
                                   "VIGENCIA FINAL DO BLOQUEIO MAIOR",
                                   "QUE A VIGENCIA FINAL DA APOLICE", "")
                      returning ws.confirma

              end if

           end if

           #-----------------------------------------------------------
           # Consulta apolice de Ramos Elementares
           #-----------------------------------------------------------
           initialize ws.sgrorg     to null
           initialize ws.sgrnumdig  to null
           initialize ws.vigfnl     to null

           if ctc32m00.ramcod  <>  31    and 
              ctc32m00.ramcod  <>  531   then
              select sgrorg    , sgrnumdig
                 into ws.sgrorg, ws.sgrnumdig
                from rsamseguro
               where succod    = ctc32m00.succod
                 and ramcod    = ctc32m00.ramcod
                 and aplnumdig = ctc32m00.aplnumdig

              if sqlca.sqlcode  =  notfound   then
                 error " Apolice nao cadastrada!"
                 next field aplnumdig
              end if

              select vigfnl
                into ws.vigfnl
                from rsdmdocto
               where sgrorg    = ws.sgrorg      and
                     sgrnumdig = ws.sgrnumdig   and
                     dctnumseq = 1

              if ctc32m00.vigfnl  >  ws.vigfnl + 30 units day   then
                 error " Vig. final bloqueio superior vig.final apolice + 30 dias --> ", ws.vigfnl
                 next field aplnumdig
              end if

              if ctc32m00.vigfnl  >  ws.vigfnl   then
                 error " Vig. final bloqueio maior que vig.final apolice --> ",
                       ws.vigfnl
                 call cts08g01("A", "N", "",
                                     "VIGENCIA FINAL DO BLOQUEIO MAIOR",
                                     "QUE A VIGENCIA FINAL DA APOLICE     ",
                                     "")
                      returning ws.confirma
              end if

              call ctc32m00_vigencia(ctc32m00.blqnum   , ctc32m00.viginc   ,
                                     ctc32m00.vigfnl   , ctc32m00.ramcod   ,
                                     ctc32m00.succod   , ctc32m00.aplnumdig,
                                     ctc32m00.itmnumdig, ctc32m00.vcllicnum,
                                     ctc32m00.chassi   , ctc32m00.corsus   ,
                                     ctc32m00.pstcoddig, ctc32m00.segnumdig,
                                     ctc32m00.ctgtrfcod)
                   returning ws.vigerro

              if ws.vigerro  =  "s"   then
                 next field aplnumdig
              end if

              next field blqnivcod
           end if

    before field itmnumdig
           display by name ctc32m00.itmnumdig  attribute (reverse)

    after  field itmnumdig
           display by name ctc32m00.itmnumdig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field aplnumdig
           end if

           if ctc32m00.itmnumdig  is null   then
              error " Numero do item da apolice deve ser informado!"
              next field itmnumdig
           end if

           initialize ws.itmsttatu  to null

           select itmsttatu
             into ws.itmsttatu
             from abbmitem
            where succod    = ctc32m00.succod
              and aplnumdig = ctc32m00.aplnumdig
              and itmnumdig = ctc32m00.itmnumdig

           if sqlca.sqlcode  =  notfound   then
              error " Item nao cadastrado!"
              next field itmnumdig
           end if

           if ws.itmsttatu  <>  "A"   then
              error " Item cancelado!"
              call cts08g01("A", "N", "", "ITEM CANCELADO", "", "")
                   returning ws.confirma
           end if

           call ctc32m00_vigencia(ctc32m00.blqnum   , ctc32m00.viginc   ,
                                  ctc32m00.vigfnl   , ctc32m00.ramcod   ,
                                  ctc32m00.succod   , ctc32m00.aplnumdig,
                                  ctc32m00.itmnumdig, ctc32m00.vcllicnum,
                                  ctc32m00.chassi   , ctc32m00.corsus   ,
                                  ctc32m00.pstcoddig, ctc32m00.segnumdig,
                                  ctc32m00.ctgtrfcod)
                returning ws.vigerro

           if ws.vigerro  =  "s"  then
              next field itmnumdig
           end if

           next field blqnivcod

    before field vcllicnum
           display by name ctc32m00.vcllicnum  attribute (reverse)

    after  field vcllicnum
           display by name ctc32m00.vcllicnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              initialize ctc32m00.vcllicnum  to null
              display by name ctc32m00.vcllicnum
              next field ramcod
           end if

           if ctc32m00.vcllicnum  is not null   then
              if not srp1415(ctc32m00.vcllicnum)  then
                 error " Placa invalida!"
                 next field vcllicnum
              end if

              let ws.contpos = length(ctc32m00.vcllicnum)
              if ws.contpos  <  7   then
                error " Nao deve ser cadastrada placa c/ menos de 7 caracteres!"
                 next field vcllicnum
              end if

              call ctc32m00_vigencia(ctc32m00.blqnum   , ctc32m00.viginc   ,
                                     ctc32m00.vigfnl   , ctc32m00.ramcod   ,
                                     ctc32m00.succod   , ctc32m00.aplnumdig,
                                     ctc32m00.itmnumdig, ctc32m00.vcllicnum,
                                     ctc32m00.chassi   , ctc32m00.corsus   ,
                                     ctc32m00.pstcoddig, ctc32m00.segnumdig,
                                     ctc32m00.ctgtrfcod)
                   returning ws.vigerro

              if ws.vigerro  =  "s"  then
                 next field vcllicnum
              end if

              next field blqnivcod
           end if

    before field chassi
           display by name ctc32m00.chassi  attribute (reverse)

    after  field chassi
           display by name ctc32m00.chassi

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              initialize ctc32m00.chassi  to null
              display by name ctc32m00.chassi
              next field vcllicnum
           end if

           if ctc32m00.chassi  is not null   then
              let ws.contpos = 20 - length(ctc32m00.chassi)

              if ws.contpos  >  12  then
               error " Nao deve ser cadastrado chassi c/ menos de 8 caracteres!"
                 next field chassi
              end if

              #-------------------------------------------------------------
              # Alinha numero do chassi a direita
              #-------------------------------------------------------------
              if ws.contpos  >  0   then
                 for ws.contpos2 = 1 to ws.contpos
                     let ctc32m00.chassi = " ", ctc32m00.chassi clipped
                 end for
              end if
              display by name ctc32m00.chassi

              call ctc32m00_vigencia(ctc32m00.blqnum   , ctc32m00.viginc   ,
                                     ctc32m00.vigfnl   , ctc32m00.ramcod   ,
                                     ctc32m00.succod   , ctc32m00.aplnumdig,
                                     ctc32m00.itmnumdig, ctc32m00.vcllicnum,
                                     ctc32m00.chassi   , ctc32m00.corsus   ,
                                     ctc32m00.pstcoddig, ctc32m00.segnumdig,
                                     ctc32m00.ctgtrfcod)
                   returning ws.vigerro

              if ws.vigerro  =  "s"  then
                 next field chassi
              end if

              next field blqnivcod
           end if

    before field corsus
           display by name ctc32m00.corsus  attribute (reverse)

    after  field corsus
           display by name ctc32m00.corsus

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              initialize ctc32m00.corsus  to null
              initialize ctc32m00.cornom  to null
              display by name ctc32m00.corsus
              display by name ctc32m00.cornom
              next field chassi
           end if

           initialize ctc32m00.cornom  to null
           display by name ctc32m00.cornom

           if ctc32m00.corsus  is not null   then
              select cornom
                into ctc32m00.cornom
                from gcaksusep, gcakcorr, gcakfilial
               where gcaksusep.corsus     = ctc32m00.corsus
                 and gcakcorr.corsuspcp   = gcaksusep.corsuspcp
                 and gcakfilial.corsuspcp = gcaksusep.corsuspcp
                 and gcakfilial.corfilnum = gcaksusep.corfilnum

              if sqlca.sqlcode  =  notfound  then
                 error " Susep nao cadastrado!"
                 next field corsus
              end if
	      display by name ctc32m00.cornom

              call ctc32m00_vigencia(ctc32m00.blqnum   , ctc32m00.viginc   ,
                                     ctc32m00.vigfnl   , ctc32m00.ramcod   ,
                                     ctc32m00.succod   , ctc32m00.aplnumdig,
                                     ctc32m00.itmnumdig, ctc32m00.vcllicnum,
                                     ctc32m00.chassi   , ctc32m00.corsus   ,
                                     ctc32m00.pstcoddig, ctc32m00.segnumdig,
                                     ctc32m00.ctgtrfcod)
                   returning ws.vigerro

              if ws.vigerro  =  "s"  then
                 next field corsus
              end if

              call cts08g01("A", "N", "",
                                "PARA CHAVE DE BLOQUEIO SUSEP NAO",
                                "SERA' EXIBIDO ALERTA EM TELA",
                                "")
                   returning ws.confirma

              next field blqnivcod
           end if

    before field pstcoddig
           display by name ctc32m00.pstcoddig  attribute (reverse)

    after  field pstcoddig
           display by name ctc32m00.pstcoddig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              initialize ctc32m00.pstcoddig  to null
              initialize ctc32m00.nomrazsoc  to null
              display by name ctc32m00.pstcoddig
              display by name ctc32m00.nomrazsoc
              next field corsus
           end if

           initialize ws.prssitcod        to null
           initialize ctc32m00.nomrazsoc  to null
           display by name ctc32m00.nomrazsoc

           if ctc32m00.pstcoddig  is not null   then
              select nomrazsoc, prssitcod
                into ctc32m00.nomrazsoc, ws.prssitcod
                from dpaksocor
               where dpaksocor.pstcoddig  = ctc32m00.pstcoddig

              if sqlca.sqlcode  =  notfound  then
                 error " Prestador nao cadastrado!"
                 next field pstcoddig
              end if
	      display by name ctc32m00.nomrazsoc

              if ws.prssitcod  <>  "A"   then
                 case ws.prssitcod
                    when "C"  error " Prestador cancelado!"
                    when "P"  error " Prestador em proposta!"
                    when "B"  error " Prestador bloqueado!"
                 end case
                 next field pstcoddig
              end if

              call ctc32m00_vigencia(ctc32m00.blqnum   , ctc32m00.viginc   ,
                                     ctc32m00.vigfnl   , ctc32m00.ramcod   ,
                                     ctc32m00.succod   , ctc32m00.aplnumdig,
                                     ctc32m00.itmnumdig, ctc32m00.vcllicnum,
                                     ctc32m00.chassi   , ctc32m00.corsus   ,
                                     ctc32m00.pstcoddig, ctc32m00.segnumdig,
                                     ctc32m00.ctgtrfcod)
                   returning ws.vigerro

              if ws.vigerro  =  "s"  then
                 next field pstcoddig
              end if

              call cts08g01("A", "N", "",
                                 "PARA CHAVE DE BLOQUEIO PRESTADOR",
                                 "NAO SERA' EXIBIDO ALERTA EM TELA",
                                 "")
                   returning ws.confirma

              next field blqnivcod
           end if

    before field segnumdig
           display by name ctc32m00.segnumdig  attribute (reverse)

    after  field segnumdig
           display by name ctc32m00.segnumdig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              initialize ctc32m00.segnumdig  to null
              initialize ctc32m00.segnom     to null
              display by name ctc32m00.segnumdig
              display by name ctc32m00.segnom
              next field pstcoddig
           end if

           display by name ctc32m00.segnumdig
           display by name ctc32m00.segnom

           if ctc32m00.segnumdig  is not null   then
              initialize ctc32m00.segnom  to null
              select segnom
                into ctc32m00.segnom
                from gsakseg
               where gsakseg.segnumdig = ctc32m00.segnumdig

              if sqlca.sqlcode  =  notfound  then
                 error " Segurado nao cadastrado!"
                 next field segnumdig
              end if
	      display by name ctc32m00.segnom

              call ctc32m00_vigencia(ctc32m00.blqnum   , ctc32m00.viginc   ,
                                     ctc32m00.vigfnl   , ctc32m00.ramcod   ,
                                     ctc32m00.succod   , ctc32m00.aplnumdig,
                                     ctc32m00.itmnumdig, ctc32m00.vcllicnum,
                                     ctc32m00.chassi   , ctc32m00.corsus   ,
                                     ctc32m00.pstcoddig, ctc32m00.segnumdig,
                                     ctc32m00.ctgtrfcod)
                   returning ws.vigerro

              if ws.vigerro  =  "s"  then
                 next field segnumdig
              end if

              next field blqnivcod
           end if

    before field ctgtrfcod
           display by name ctc32m00.ctgtrfcod  attribute (reverse)

    after  field ctgtrfcod
           display by name ctc32m00.ctgtrfcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              initialize ctc32m00.ctgtrfcod  to null
              initialize ctc32m00.ctgtrfdes  to null
              display by name ctc32m00.ctgtrfcod
              display by name ctc32m00.ctgtrfdes
              next field segnumdig
           end if

           if ctc32m00.ctgtrfcod  is not null   then

              call ctc32m00_ctgdes (today, ctc32m00.ctgtrfcod)
                   returning ws.sqlca, ctc32m00.ctgtrfdes

              if ws.sqlca  <>  0   then
                 error " Categoria tarifaria nao cadastrada!"
                 next field ctgtrfcod
              end if

              display by name ctc32m00.ctgtrfdes

              call ctc32m00_vigencia(ctc32m00.blqnum   , ctc32m00.viginc   ,
                                     ctc32m00.vigfnl   , ctc32m00.ramcod   ,
                                     ctc32m00.succod   , ctc32m00.aplnumdig,
                                     ctc32m00.itmnumdig, ctc32m00.vcllicnum,
                                     ctc32m00.chassi   , ctc32m00.corsus   ,
                                     ctc32m00.pstcoddig, ctc32m00.segnumdig,
                                     ctc32m00.ctgtrfcod)
                   returning ws.vigerro

              if ws.vigerro  =  "s"  then
                 next field ctgtrfcod
              end if

              call cts08g01("A", "N", "",
                                 "PARA CHAVE DE BLOQUEIO CTG TARIFARIA",
                                 "NAO SERA' EXIBIDO ALERTA EM TELA",
                                 "")
                   returning ws.confirma
           end if

    before field blqnivcod
           if ctc32m00.ramcod     is null   and
              ctc32m00.vcllicnum  is null   and
              ctc32m00.chassi     is null   and
              ctc32m00.corsus     is null   and
              ctc32m00.pstcoddig  is null   and
              ctc32m00.segnumdig  is null   and
              ctc32m00.ctgtrfcod  is null   then
              error " Uma chave para o bloqueio deve ser informada!"
              next field ramcod
           end if
           display by name ctc32m00.blqnivcod  attribute (reverse)

    after  field blqnivcod
           display by name ctc32m00.blqnivcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then

              if param.operacao  =  "a"   then
                 next field blqnivcod
              end if

              if ctc32m00.ramcod  is not null   then
                 next field ramcod
              end if
              if ctc32m00.vcllicnum  is not null   then
                 next field vcllicnum
              end if
              if ctc32m00.chassi     is not null   then
                 next field chassi
              end if
              if ctc32m00.corsus     is not null   then
                 next field corsus
              end if
              if ctc32m00.pstcoddig  is not null   then
                 next field pstcoddig
              end if
              if ctc32m00.segnumdig  is not null   then
                 next field segnumdig
              end if
              if ctc32m00.ctgtrfcod  is not null   then
                 next field ctgtrfcod
              end if

           end if

           case ctc32m00.blqnivcod
                when 01   let ctc32m00.blqnivdes = "ALERTA"
                when 02   let ctc32m00.blqnivdes = "SENHA"
                when 03   let ctc32m00.blqnivdes = "NAO ATENDE"
                otherwise error " Nivel: (1)Alerta, (2)Senha, (3)Nao atende!"
                          next field blqnivcod
           end case
           display by name ctc32m00.blqnivdes

           if ctc32m00.blqnivcod  =  02   or
              ctc32m00.blqnivcod  =  03   then

              if ctc32m00.pstcoddig  is not null   then
                 error " Para prestador e' permitido somente nivel (1)!"
                 next field blqnivcod
              end if

              if ctc32m00.corsus  is not null   then
                 error " Para susep e' permitido somente nivel (1)!"
                 next field blqnivcod
              end if

              if ctc32m00.ctgtrfcod  is not null   then
               error " Para categoria tarifaria e' permitido somente nivel (1)!"
                 next field blqnivcod
              end if
           end if

    before field blqanlflg
           if ctc32m00.pstcoddig  is not null   or
              ctc32m00.corsus     is not null   or
              ctc32m00.ctgtrfcod  is not null   then
              let  ctc32m00.blqanlflg = "S"
           end if
           display by name ctc32m00.blqanlflg  attribute (reverse)

    after  field blqanlflg
           display by name ctc32m00.blqanlflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field blqnivcod
           end if

           if ((ctc32m00.blqanlflg  is null)   or
               (ctc32m00.blqanlflg  <>  "S"    and
                ctc32m00.blqanlflg  <>  "N"))  then
              error " Emite no relatorio de analise: (S)im, (N)ao!"
              next field blqanlflg
           end if

           if ctc32m00.pstcoddig  is not null   or
              ctc32m00.corsus     is not null   or
              ctc32m00.ctgtrfcod  is not null   then
              if ctc32m00.blqanlflg  =  "N"   then
                 error " Chave/nivel bloqueio informado relatorio deve ser emitido!"
                 next field blqanlflg
              end if
           end if
    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize ctc32m00.*  to null
 end if

 return ctc32m00.*

 end function   # ctc32m00_input


#---------------------------------------------------------
 function ctc32m00_ler(param)
#---------------------------------------------------------

 define param         record
    blqnum            like datkblq.blqnum
 end record

 define ctc32m00      record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    chassi            char (20),
    corsus            like datkblq.corsus,
    cornom            like gcakcorr.cornom,
    pstcoddig         like datkblq.pstcoddig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    segnumdig         like datkblq.segnumdig,
    segnom            like gsakseg.segnom,
    ctgtrfcod         like datkblq.ctgtrfcod,
    ctgtrfdes         like agekcateg.ctgtrfdes,
    blqnivcod         like datkblq.blqnivcod,
    blqnivdes         char(15),
    blqanlflg         like datkblq.blqanlflg,
    caddat            like datkblq.caddat,
    cadhor            like datkblq.cadhor,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkblq.atldat,
    atlhor            like datkblq.atlhor,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    cademp            like datkblq.cademp,
    cadmat            like datkblq.cadmat,
    atlemp            like datkblq.atlemp,
    atlmat            like datkblq.atlmat,
    vclchsinc         like datkblq.vclchsinc,
    vclchsfnl         like datkblq.vclchsfnl,
    sqlca             integer
 end record


 initialize ctc32m00.*   to null
 initialize ws.*         to null

 select  blqnum,
         viginc,
         vigfnl,
         ramcod,
         succod,
         aplnumdig,
         itmnumdig,
         vcllicnum,
         vclchsinc,
         vclchsfnl,
         corsus,
         pstcoddig,
         segnumdig,
         ctgtrfcod,
         blqnivcod,
         blqanlflg,
         caddat,
         cadhor,
         cademp,
         cadmat,
         atldat,
         atlhor,
         atlemp,
         atlmat
   into  ctc32m00.blqnum,
         ctc32m00.viginc,
         ctc32m00.vigfnl,
         ctc32m00.ramcod,
         ctc32m00.succod,
         ctc32m00.aplnumdig,
         ctc32m00.itmnumdig,
         ctc32m00.vcllicnum,
         ws.vclchsinc,
         ws.vclchsfnl,
         ctc32m00.corsus,
         ctc32m00.pstcoddig,
         ctc32m00.segnumdig,
         ctc32m00.ctgtrfcod,
         ctc32m00.blqnivcod,
         ctc32m00.blqanlflg,
         ctc32m00.caddat,
         ctc32m00.cadhor,
         ws.cademp,
         ws.cadmat,
         ctc32m00.atldat,
         ctc32m00.atlhor,
         ws.atlemp,
         ws.atlmat
   from  datkblq
  where  datkblq.blqnum = param.blqnum

 if sqlca.sqlcode = notfound   then
    error " Codigo de bloqueio nao cadastrado!"
    initialize ctc32m00.*    to null
    return ctc32m00.*
 end if

 let ctc32m00.chassi = ws.vclchsinc, ws.vclchsfnl
 if ws.vclchsinc  is null   and
    ws.vclchsfnl  is null   then
    initialize ctc32m00.chassi  to null
 end if

 call ctc32m00_func(ws.cademp, ws.cadmat)
      returning ctc32m00.cadfunnom

 call ctc32m00_func(ws.atlemp, ws.atlmat)
      returning ctc32m00.funnom

 if ctc32m00.pstcoddig  is not null   then
    select nomrazsoc
      into ctc32m00.nomrazsoc
      from dpaksocor
     where dpaksocor.pstcoddig  = ctc32m00.pstcoddig
 end if

 if ctc32m00.segnumdig  is not null   then
    select segnom
      into ctc32m00.segnom
      from gsakseg
     where gsakseg.segnumdig = ctc32m00.segnumdig
 end if

 if ctc32m00.corsus  is not null   then
   select cornom
     into ctc32m00.cornom
     from gcaksusep, gcakcorr, gcakfilial
    where gcaksusep.corsus     = ctc32m00.corsus
      and gcakcorr.corsuspcp   = gcaksusep.corsuspcp
      and gcakfilial.corsuspcp = gcaksusep.corsuspcp
      and gcakfilial.corfilnum = gcaksusep.corfilnum
 end if

 if ctc32m00.ctgtrfcod  is not null   then
    call ctc32m00_ctgdes (ctc32m00.caddat, ctc32m00.ctgtrfcod)
         returning ws.sqlca, ctc32m00.ctgtrfdes
 end if

 case ctc32m00.blqnivcod
      when 01   let ctc32m00.blqnivdes = "ALERTA"
      when 02   let ctc32m00.blqnivdes = "SENHA"
      when 03   let ctc32m00.blqnivdes = "NAO ATENDE"
 end case

 return ctc32m00.*

 end function   # ctc32m00_ler


#---------------------------------------------------------
 function ctc32m00_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = param.empcod
    and isskfunc.funmat = param.funmat

 return ws.funnom

 end function   # ctc32m00_func


#---------------------------------------------------------
 function ctc32m00_vigencia(param)
#---------------------------------------------------------

 define param         record
    blqnum            like datkblq.blqnum,
    viginc            like datkblq.viginc,
    vigfnl            like datkblq.vigfnl,
    ramcod            like datkblq.ramcod,
    succod            like datkblq.succod,
    aplnumdig         like datkblq.aplnumdig,
    itmnumdig         like datkblq.itmnumdig,
    vcllicnum         like datkblq.vcllicnum,
    chassi            char (20),
    corsus            like datkblq.corsus,
    pstcoddig         like datkblq.pstcoddig,
    segnumdig         like datkblq.segnumdig,
    ctgtrfcod         like datkblq.ctgtrfcod
 end record

 define ws            record
    blqnum            like datkblq.blqnum,
    vigtip            integer,
    vigtipdes         char(14),
    vigdat            like datkblq.vigfnl,
    errotip           char(01),
    vigerro           char(01),
    vclchsfnl         like datkblq.vclchsfnl
 end record


 if param.blqnum   is null    then   ##--> quando for inclusao
    let param.blqnum = 0
 end if

 initialize ws.*          to null
 let ws.vigerro = "n"

 for ws.vigtip = 1 to 2

    case ws.vigtip
         when  1  let ws.vigtipdes = "(vig.inicial)"
                  let ws.vigdat    = param.viginc
         when  2  let ws.vigtipdes = "(vig.final)"
                  let ws.vigdat    = param.vigfnl
    end case

    if param.ramcod  is not null   then
       if param.ramcod  <> 31    and  
          param.ramcod  <> 531   then
          select blqnum
            into ws.blqnum
            from datkblq
           where datkblq.ramcod    = param.ramcod
             and datkblq.succod    = param.succod
             and datkblq.aplnumdig = param.aplnumdig
             and ws.vigdat   between viginc and vigfnl
             and datkblq.blqnum   <> param.blqnum

           if ws.blqnum  is not null   then
              let ws.errotip = 1
           else
              select blqnum
                into ws.blqnum
                from datkblq
               where datkblq.ramcod    = param.ramcod
                 and datkblq.succod    = param.succod
                 and datkblq.aplnumdig = param.aplnumdig
                 and datkblq.viginc    > param.viginc
                 and datkblq.vigfnl    < param.vigfnl
                 and datkblq.blqnum   <> param.blqnum

              if ws.blqnum  is not null   then
                 let ws.errotip = 2
              end if
           end if
       else
          select blqnum
            into ws.blqnum
            from datkblq
           where datkblq.ramcod    = param.ramcod
             and datkblq.succod    = param.succod
             and datkblq.aplnumdig = param.aplnumdig
             and datkblq.itmnumdig = param.itmnumdig
             and ws.vigdat   between viginc and vigfnl
             and datkblq.blqnum   <> param.blqnum

          if ws.blqnum  is not null   then
             let ws.errotip = 1
          else
             select blqnum
               into ws.blqnum
               from datkblq
              where datkblq.ramcod    = param.ramcod
                and datkblq.succod    = param.succod
                and datkblq.aplnumdig = param.aplnumdig
                and datkblq.itmnumdig = param.itmnumdig
                and datkblq.viginc    > param.viginc
                and datkblq.vigfnl    < param.vigfnl
                and datkblq.blqnum   <> param.blqnum

             if ws.blqnum  is not null   then
                let ws.errotip = 2
             end if
          end if
       end if
    end if

    if param.chassi  is not null   then
       let ws.vclchsfnl = param.chassi[13,20]

       select blqnum
         into ws.blqnum
         from datkblq
        where datkblq.vclchsfnl = ws.vclchsfnl
          and ws.vigdat   between viginc and vigfnl
          and datkblq.blqnum   <> param.blqnum

       if ws.blqnum  is not null   then
          let ws.errotip = 1
       else
          select blqnum
            into ws.blqnum
            from datkblq
           where datkblq.vclchsfnl = ws.vclchsfnl
             and datkblq.viginc    > param.viginc
             and datkblq.vigfnl    < param.vigfnl
             and datkblq.blqnum   <> param.blqnum

          if ws.blqnum  is not null   then
             let ws.errotip = 2
          end if
       end if
    end if

    if param.vcllicnum  is not null   then
       select blqnum
         into ws.blqnum
         from datkblq
        where datkblq.vcllicnum = param.vcllicnum
          and ws.vigdat   between viginc and vigfnl
          and datkblq.blqnum   <> param.blqnum

       if ws.blqnum  is not null   then
          let ws.errotip = 1
       else
          select blqnum
            into ws.blqnum
            from datkblq
           where datkblq.vcllicnum = param.vcllicnum
             and datkblq.viginc    > param.viginc
             and datkblq.vigfnl    < param.vigfnl
             and datkblq.blqnum   <> param.blqnum

          if ws.blqnum  is not null   then
             let ws.errotip = 2
          end if
       end if
    end if

    if param.corsus  is not null   then
       select blqnum
         into ws.blqnum
         from datkblq
        where datkblq.corsus  = param.corsus
          and ws.vigdat  between viginc and vigfnl
          and datkblq.blqnum <> param.blqnum

       if ws.blqnum  is not null   then
          let ws.errotip = 1
       else
          select blqnum
            into ws.blqnum
            from datkblq
           where datkblq.corsus  = param.corsus
             and datkblq.viginc  > param.viginc
             and datkblq.vigfnl  < param.vigfnl
             and datkblq.blqnum <> param.blqnum

          if ws.blqnum  is not null   then
             let ws.errotip = 2
          end if
       end if
    end if

    if param.pstcoddig  is not null   then
       select blqnum
         into ws.blqnum
         from datkblq
        where datkblq.pstcoddig = param.pstcoddig
          and ws.vigdat  between viginc and vigfnl
          and datkblq.blqnum   <> param.blqnum

       if ws.blqnum  is not null   then
          let ws.errotip = 1
       else
          select blqnum
            into ws.blqnum
            from datkblq
           where datkblq.pstcoddig = param.pstcoddig
             and datkblq.viginc    > param.viginc
             and datkblq.vigfnl    < param.vigfnl
             and datkblq.blqnum   <> param.blqnum

          if ws.blqnum  is not null   then
             let ws.errotip = 2
          end if
       end if
    end if

    if param.segnumdig  is not null   then
       select blqnum
         into ws.blqnum
         from datkblq
        where datkblq.segnumdig = param.segnumdig
          and ws.vigdat  between viginc and vigfnl
          and datkblq.blqnum   <> param.blqnum

       if ws.blqnum  is not null   then
          let ws.errotip = 1
       else
          select blqnum
            into ws.blqnum
            from datkblq
           where datkblq.segnumdig = param.segnumdig
             and datkblq.viginc    > param.viginc
             and datkblq.vigfnl    < param.vigfnl
             and datkblq.blqnum   <> param.blqnum

          if ws.blqnum  is not null   then
             let ws.errotip = 2
          end if
       end if
    end if

    if param.ctgtrfcod  is not null   then
       select blqnum
         into ws.blqnum
         from datkblq
        where datkblq.ctgtrfcod = param.ctgtrfcod
          and ws.vigdat  between viginc and vigfnl
          and datkblq.blqnum   <> param.blqnum

       if ws.blqnum  is not null   then
          let ws.errotip = 1
       else
          select blqnum
            into ws.blqnum
            from datkblq
           where datkblq.ctgtrfcod = param.ctgtrfcod
             and datkblq.viginc    > param.viginc
             and datkblq.vigfnl    < param.vigfnl
             and datkblq.blqnum   <> param.blqnum

          if ws.blqnum  is not null   then
             let ws.errotip = 2
          end if
       end if
    end if

    if ws.blqnum  is not null   then
       if ws.errotip  =  1   then
          error " Existe bloqueio vigente ", ws.vigtipdes  clipped,
                " com esta chave --> ", ws.blqnum
       else
          error " Existe bloqueio vigente neste periodo",
                " com esta chave --> ", ws.blqnum
       end if

       let ws.vigerro = "s"
       exit for
    end if

 end for

 return ws.vigerro

 end function   # ctc32m00_func


#---------------------------------------------------------
 function ctc32m00_ctgdes(param)
#---------------------------------------------------------

 define param         record
    data              date,
    ctgtrfcod         like datkblq.ctgtrfcod
 end record

 define ws            record
    ctgtrfdes         like agekcateg.ctgtrfdes,
    sqlca             integer
 end record


 initialize ws.*  to null

 select ctgtrfdes
   into ws.ctgtrfdes
   from itatvig, agekcateg
  where itatvig.tabnom       =  "agekcateg"    and
        itatvig.viginc      <=  param.data     and
        itatvig.vigfnl      >=  param.data     and

        agekcateg.tabnum     =  itatvig.tabnum and
        agekcateg.ramcod     =  531            and
        agekcateg.ctgtrfcod  =  param.ctgtrfcod

 let ws.sqlca = sqlca.sqlcode

 return ws.sqlca, ws.ctgtrfdes

 end function   # ctc32m00_ctgdes
