#############################################################################
# Nome do Modulo: cts24m00                                          GUSTAVO #
#                                                                           #
# Cadastro de movimento teletrim conforme crierios                  JAN/2001#
#                                                                           #
# Data: 08/01/2001                                                          #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 02/03/2001  PSI 12669-1  Wagner       Inclusao do modulo de pesquisa de   #
#                                       envio.                              #
#---------------------------------------------------------------------------#
# 21/05/2001  PSI .......  Wagner       Acerto de mensagens e inclusao da   #
#                                       funcao cts00g04 par aenvio padrao.  #
#############################################################################

 database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function cts24m00()
#------------------------------------------------------------

 define d_cts24m00   record
        tltmvtnum    like  datmtlt.tltmvtnum,
        dtini        date,
        dtfim        date,
        atdvclsgl    like  datmtlt.atdvclsgl,
        vclcoddig    like  datkveiculo.vclcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        socoprsitcod like  datkveiculo.socoprsitcod,
        vcldes       char(58),
        pstcoddig    like  datmtlt.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtctrcod    like  datmtlt.mdtctrcod,
        c24tltgrpnum like  datmtlt.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        c24tltgrpstt like  datktltgrp.c24tltgrpstt,
        pgrnum       like  datmtlt.pgrnum,
        ustnom       like  htlrust.ustnom,
        ustsit       like  htlrust.ustsit,
        ustcod       like  htlrust.ustcod,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        informa      char(60),
        mdtfqcdes    like  datkmdtctr.mdtfqcdes
 end record

 define ws_count     smallint


        let     ws_count  =  null

        initialize  d_cts24m00.*  to  null

 let int_flag = false
 initialize d_cts24m00.*  to null

 #if not get_niv_mod(g_issk.prgsgl, "cts24m00") then
 #   error " Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 open window cts24m00 at 04,2 with form "cts24m00"

 menu "MOVIMENTO TELETRIM"

 before menu
     hide option all
     show option all
     if g_issk.acsnivcod >= g_issk.acsnivcns  then
        show option "Seleciona", "Proximo", "Anterior", "eNvia", "pesQuisa"
     end if
     if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Inclui"   , "Seleciona", "Proximo" , "Anterior",
                    "Modifica" , "eNvia"    , "pesQuisa"
     end if
     show option "Encerra"

 command key ("I") "Inclui"
                   "Inclui Movimento Teletrim"
          message ""
          call cts24m00_inclui()
          next option "Seleciona"
          initialize d_cts24m00.*  to null
          next option "Inclui"

 command key ("S") "Seleciona"
                   "Pesquisa Movimento Teletrim conforme criterios"
          call cts24m00_seleciona(d_cts24m00.tltmvtnum)
               returning d_cts24m00.*
          if d_cts24m00.tltmvtnum  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum Movimento Teletrim selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo Movimento Teletrim selecionado"
          message ""
          if d_cts24m00.tltmvtnum is not null then
             call cts24m00_proximo(d_cts24m00.tltmvtnum)
                  returning d_cts24m00.*
          else
             error " Nenhum Movimento Teletrim nesta direcao!"
             next option "Seleciona"
          end if

 command key ("A") "Anterior"
                   "Mostra Movimento Teletrim anterior selecionado"
          message ""
          if d_cts24m00.tltmvtnum is not null then
             call cts24m00_anterior(d_cts24m00.tltmvtnum)
                  returning d_cts24m00.*
          else
             error " Nenhum Movimento Teletrim nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                    "Modifica Movimento Teletrim selecionado"
          message ""
          if d_cts24m00.tltmvtnum is not null then
             select count(*)
                 into ws_count
                 from datmtltmsglog
                 where tltmvtnum = d_cts24m00.tltmvtnum

     #WWW    if ws_count = 0 then
                call cts24m00_modifica(d_cts24m00.tltmvtnum, d_cts24m00.*)
                     returning d_cts24m00.*
                next option "Seleciona"
     #WWW    else
     #WWW       error "Nao pode Modificar! Mensagem ja' enviada!"
     #WWW       next option "Seleciona"
     #WWW    end if
          else
             error " Nenhum Movimento Teletrim selecionado!"
             next option "Seleciona"
          end if
          initialize d_cts24m00.*  to null

 command key ("N") "eNvia"
                   "Envia Movimento para Teletrim selecionado!"
          message ""
          if d_cts24m00.tltmvtnum is not null then
             call cts24m00_envia(d_cts24m00.tltmvtnum, d_cts24m00.*)
             error   ""
             next option "Inclui"
          else
             error " Nenhum Movimento Teletrim selecionado para ser enviado!"
             next option "Seleciona"
          end if
          initialize d_cts24m00.*  to null

 command key ("Q") "pesQuisa"
                   "Pesquisa envio de mensagens Teletrim"
          message ""
          call cts24m00_pesquisa()
          next option "Seleciona"
          initialize d_cts24m00.*  to null
          next option "Inclui"

 command key (interrupt,E) "Encerra"
         "Retorna ao menu anterior"
          exit menu
 end menu

 let int_flag = false
 close window cts24m00

 end function  # cts24m00

#------------------------------------------------------------
 function cts24m00_seleciona(param)
#------------------------------------------------------------

 define param        record
        tltmvtnum    like datmtlt.tltmvtnum
 end record

 define d_cts24m00   record
        tltmvtnum    like  datmtlt.tltmvtnum,
        dtini        date,
        dtfim        date,
        atdvclsgl    like  datmtlt.atdvclsgl,
        vclcoddig    like  datkveiculo.vclcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        socoprsitcod like  datkveiculo.socoprsitcod,
        vcldes       char(58),
        pstcoddig    like  datmtlt.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtctrcod    like  datmtlt.mdtctrcod,
        c24tltgrpnum like  datmtlt.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        c24tltgrpstt like  datktltgrp.c24tltgrpstt,
        pgrnum       like  datmtlt.pgrnum,
        ustnom       like  htlrust.ustnom,
        ustsit       like  htlrust.ustsit,
        ustcod       like  htlrust.ustcod,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        informa      char(60),
        mdtfqcdes    like  datkmdtctr.mdtfqcdes
 end record



        initialize  d_cts24m00.*  to  null

 let int_flag = false
 initialize d_cts24m00.*  to null
 let d_cts24m00.tltmvtnum  =  param.tltmvtnum
 clear form

 input  d_cts24m00.tltmvtnum   without defaults
  from tltmvtnum

    before field tltmvtnum
        display by name d_cts24m00.tltmvtnum attribute (reverse)

    after  field tltmvtnum
        display by name d_cts24m00.tltmvtnum

        if d_cts24m00.tltmvtnum is null   then
           error " Movimento Teletrim deve ser informado!"
           next field tltmvtnum
        end if

        select tltmvtnum
          from datmtlt
        where datmtlt.tltmvtnum = d_cts24m00.tltmvtnum

        if sqlca.sqlcode  =  notfound   then
           error " Movimento Teletrim nao existe!"
           next field tltmvtnum
        end if

        on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_cts24m00.*   to null
    let d_cts24m00.tltmvtnum  =  param.tltmvtnum
    error " Operacao cancelada!"
    return d_cts24m00.*
 end if

 call cts24m00_ler(d_cts24m00.tltmvtnum)
      returning d_cts24m00.*

 if d_cts24m00.tltmvtnum is not null   then
    call cts24m00_display(d_cts24m00.*)
 else
    error " Movimento Teletrim nao existe!"
    initialize d_cts24m00.*    to null
 end if

 return d_cts24m00.*

 end function  # cts24m00_seleciona

#------------------------------------------------------------
 function cts24m00_proximo(param)
#------------------------------------------------------------

 define param        record
        tltmvtnum    like datmtlt.tltmvtnum
 end record

 define d_cts24m00   record
        tltmvtnum    like  datmtlt.tltmvtnum,
        dtini        date,
        dtfim        date,
        atdvclsgl    like  datmtlt.atdvclsgl,
        vclcoddig    like  datkveiculo.vclcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        socoprsitcod like  datkveiculo.socoprsitcod,
        vcldes       char  (58),
        pstcoddig    like  datmtlt.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtctrcod    like  datmtlt.mdtctrcod,
        c24tltgrpnum like  datmtlt.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        c24tltgrpstt like  datktltgrp.c24tltgrpstt,
        pgrnum       like  datmtlt.pgrnum,
        ustnom       like  htlrust.ustnom,
        ustsit       like  htlrust.ustsit,
        ustcod       like  htlrust.ustcod,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        informa      char(60),
        mdtfqcdes    like  datkmdtctr.mdtfqcdes
 end record



        initialize  d_cts24m00.*  to  null

 let int_flag = false

 initialize d_cts24m00.*   to null

 if param.tltmvtnum is null   then
    let param.tltmvtnum = 0
 end if

 select min(datmtlt.tltmvtnum)
   into d_cts24m00.tltmvtnum
   from datmtlt
 where datmtlt.tltmvtnum  >  param.tltmvtnum

 if d_cts24m00.tltmvtnum is not null   then
    call cts24m00_ler(d_cts24m00.tltmvtnum)
         returning d_cts24m00.*

    if d_cts24m00.tltmvtnum is not null   then
       call cts24m00_display(d_cts24m00.*)
    else
       error " Nao ha' Movimento Teletrim nesta direcao!"
       initialize d_cts24m00.*    to null
    end if
 else
    error " Nao ha' Movimento Teletrim nesta direcao!"
    initialize d_cts24m00.*    to null
 end if

 return d_cts24m00.*

 end function    # cts24m00_proximo

#------------------------------------------------------------
 function cts24m00_anterior(param)
#------------------------------------------------------------

 define param        record
        tltmvtnum    like datmtlt.tltmvtnum
 end record

 define d_cts24m00   record
        tltmvtnum    like  datmtlt.tltmvtnum,
        dtini        date,
        dtfim        date,
        atdvclsgl    like  datmtlt.atdvclsgl,
        vclcoddig    like  datkveiculo.vclcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        socoprsitcod like  datkveiculo.socoprsitcod,
        vcldes       char(58),
        pstcoddig    like  datmtlt.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtctrcod    like  datmtlt.mdtctrcod,
        c24tltgrpnum like  datmtlt.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        c24tltgrpstt like  datktltgrp.c24tltgrpstt,
        pgrnum       like  datmtlt.pgrnum,
        ustnom       like  htlrust.ustnom,
        ustsit       like  htlrust.ustsit,
        ustcod       like  htlrust.ustcod,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        informa      char(60),
        mdtfqcdes    like  datkmdtctr.mdtfqcdes
 end record



        initialize  d_cts24m00.*  to  null

 let int_flag = false
 initialize d_cts24m00.*  to null

 if param.tltmvtnum  is null   then
    let param.tltmvtnum = 0
 end if

 select max(datmtlt.tltmvtnum)
   into d_cts24m00.tltmvtnum
   from datmtlt
 where datmtlt.tltmvtnum  <  param.tltmvtnum

 if d_cts24m00.tltmvtnum is not null   then

    call cts24m00_ler(d_cts24m00.tltmvtnum)
         returning d_cts24m00.*

    if d_cts24m00.tltmvtnum is not null   then
       call cts24m00_display(d_cts24m00.*)
    else
       error " Nao ha' Movimento teletrim nesta direcao!"
       initialize d_cts24m00.*    to null
    end if
 else
    error " Nao ha' Movimento Teletrim nesta direcao!"
    initialize d_cts24m00.*    to null
 end if

 return d_cts24m00.*

 end function    # cts24m00_anterior

#------------------------------------------------------------
 function cts24m00_modifica(param, d_cts24m00)
#------------------------------------------------------------

 define param        record
        tltmvtnum    like datmtlt.tltmvtnum
 end record

 define d_cts24m00   record
        tltmvtnum    like  datmtlt.tltmvtnum,
        dtini        date,
        dtfim        date,
        atdvclsgl    like  datmtlt.atdvclsgl,
        vclcoddig    like  datkveiculo.vclcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        socoprsitcod like  datkveiculo.socoprsitcod,
        vcldes       char(58),
        pstcoddig    like  datmtlt.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtctrcod    like  datmtlt.mdtctrcod,
        c24tltgrpnum like  datmtlt.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        c24tltgrpstt like  datktltgrp.c24tltgrpstt,
        pgrnum       like  datmtlt.pgrnum,
        ustnom       like  htlrust.ustnom,
        ustsit       like  htlrust.ustsit,
        ustcod       like  htlrust.ustcod,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        informa      char(60),
        mdtfqcdes    like  datkmdtctr.mdtfqcdes
 end record



 call cts24m00_ler(d_cts24m00.tltmvtnum)
      returning d_cts24m00.*

 if d_cts24m00.tltmvtnum is null then
    error " Registro nao localizado "
    return param.*
 end if

 call cts24m00_input("a", d_cts24m00.*) returning d_cts24m00.*

 if int_flag  then
    let int_flag = false
    initialize d_cts24m00.*  to null
    error " Operacao cancelada!"
    return d_cts24m00.*
 end if

 whenever error continue

 begin work
    update datmtlt       set  ( atdvclsgl,
                                pstcoddig,
                                mdtctrcod,
                                c24tltgrpnum,
                                pgrnum,
                                tltmsgcod,
                                tltmsgtxt)
                           =  ( d_cts24m00.atdvclsgl,
                                d_cts24m00.pstcoddig,
                                d_cts24m00.mdtctrcod,
                                d_cts24m00.c24tltgrpnum,
                                d_cts24m00.pgrnum,
                                d_cts24m00.tltmsgcod,
                                d_cts24m00.tltmsgtxt)
    where datmtlt.tltmvtnum = param.tltmvtnum

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do grupo!"
       rollback work
       initialize d_cts24m00.*   to null
       return d_cts24m00.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize d_cts24m00.*  to null
 message ""
 return d_cts24m00.*
 end function   #  cts24m00_modifica

#------------------------------------------------------------
 function cts24m00_inclui()
#------------------------------------------------------------

 define d_cts24m00   record
        tltmvtnum    like  datmtlt.tltmvtnum,
        dtini        date,
        dtfim        date,
        atdvclsgl    like  datmtlt.atdvclsgl,
        vclcoddig    like  datkveiculo.vclcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        socoprsitcod like  datkveiculo.socoprsitcod,
        vcldes       char(58),
        pstcoddig    like  datmtlt.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtctrcod    like  datmtlt.mdtctrcod,
        c24tltgrpnum like  datmtlt.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        c24tltgrpstt like  datktltgrp.c24tltgrpstt,
        pgrnum       like  datmtlt.pgrnum,
        ustnom       like  htlrust.ustnom,
        ustsit       like  htlrust.ustsit,
        ustcod       like  htlrust.ustcod,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        informa      char(60),
        mdtfqcdes    like  datkmdtctr.mdtfqcdes
 end record

 define  ws_resp      char(01)


        let     ws_resp  =  null

        initialize  d_cts24m00.*  to  null

 initialize d_cts24m00.*   to null

 clear form

 call cts24m00_input("i", d_cts24m00.*) returning d_cts24m00.*

 if int_flag  then
    let int_flag = false
    initialize d_cts24m00.*  to null
    error " Operacao cancelada!"
    return
 end if

 declare c_cts24m00_001  cursor with hold  for
  select max(tltmvtnum)
    from datmtlt
   where datmtlt.tltmvtnum > 0

 foreach c_cts24m00_001  into  d_cts24m00.tltmvtnum
     exit foreach
 end foreach

 if d_cts24m00.tltmvtnum is null   then
    let d_cts24m00.tltmvtnum = 0
 end if
 let d_cts24m00.tltmvtnum = d_cts24m00.tltmvtnum + 1

 whenever error continue

 begin work
    insert into datmtlt               (  tltmvtnum,
                                         atdvclsgl,
                                         pstcoddig,
                                         mdtctrcod,
                                         c24tltgrpnum,
                                         pgrnum,
                                         tltmsgcod,
                                         tltmsgtxt)
                         values
                                      ( d_cts24m00.tltmvtnum,
                                        d_cts24m00.atdvclsgl,
                                        d_cts24m00.pstcoddig,
                                        d_cts24m00.mdtctrcod,
                                        d_cts24m00.c24tltgrpnum,
                                        d_cts24m00.pgrnum,
                                        d_cts24m00.tltmsgcod,
                                        d_cts24m00.tltmsgtxt)
    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do Movimento teletrim!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 display by name d_cts24m00.tltmvtnum attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 call cts24m00_envia(d_cts24m00.tltmvtnum, d_cts24m00.*)

 initialize d_cts24m00.*  to null

 clear form

 end function   #  cts24m00_inclui

#--------------------------------------------------------------------
 function cts24m00_input(param, d_cts24m00)
#--------------------------------------------------------------------

 define param        record
        operacao     char(1)
 end record

 define d_cts24m00   record
        tltmvtnum    like  datmtlt.tltmvtnum,
        dtini        date,
        dtfim        date,
        atdvclsgl    like  datmtlt.atdvclsgl,
        vclcoddig    like  datkveiculo.vclcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        socoprsitcod like  datkveiculo.socoprsitcod,
        vcldes       char(58),
        pstcoddig    like  datmtlt.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtctrcod    like  datmtlt.mdtctrcod,
        c24tltgrpnum like  datmtlt.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        c24tltgrpstt like  datktltgrp.c24tltgrpstt,
        pgrnum       like  datmtlt.pgrnum,
        ustnom       like  htlrust.ustnom,
        ustsit       like  htlrust.ustsit,
        ustcod       like  htlrust.ustcod,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        informa      char(60),
        mdtfqcdes    like  datkmdtctr.mdtfqcdes
 end record

 define ws           record
        pstcoddig    like dpaksocor.pstcoddig,
        tltmvtnum    like datmtlt.tltmvtnum,
        count        smallint,
        campo        char(13),
        resp         char(01)
 end record



        initialize  ws.*  to  null

 initialize ws.*  to null
 let int_flag     =  false

 input by name d_cts24m00.dtini     , d_cts24m00.dtfim,
               d_cts24m00.atdvclsgl , d_cts24m00.pstcoddig,
               d_cts24m00.mdtctrcod , d_cts24m00.c24tltgrpnum,
               d_cts24m00.pgrnum    , d_cts24m00.tltmsgcod,
               d_cts24m00.tltmsgtxt1, d_cts24m00.tltmsgtxt2,
               d_cts24m00.tltmsgtxt3, d_cts24m00.tltmsgtxt4,
               d_cts24m00.tltmsgtxt5  without defaults

    before field dtini
           if param.operacao <> "p" then
              next field atdvclsgl
           end if
           let ws.campo = "Periodo de..:"
           display ws.campo to perde
           let ws.campo = "ate:"
           display ws.campo to perat
           display by name d_cts24m00.dtini attribute (reverse)

    after  field dtini
           display by name d_cts24m00.dtini
           if d_cts24m00.dtini is null then
              error " Data inicial do periodo deve ser informada!"
              next field dtini
           end if

    before field dtfim
           if param.operacao <> "p" then
              next field atdvclsgl
           end if
           display by name d_cts24m00.dtfim attribute (reverse)

    after  field dtfim
           display by name d_cts24m00.dtfim

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field dtini
           end if
           if d_cts24m00.dtfim is null then
              error " Data final do periodo deve ser informada!"
              next field dtfim
           end if
           if d_cts24m00.dtfim < d_cts24m00.dtini then
              error " Data final nao pode ser menor que data inicial!"
              next field dtfim
           end if
           if (d_cts24m00.dtfim - d_cts24m00.dtini) > 30  then
              error " Periodo da pesquisa nao pode ser superior a 30 dias!"
              next field dtfim
           end if

    before field atdvclsgl
           initialize d_cts24m00.vcldes, d_cts24m00.nomrazsoc to null
           display by name d_cts24m00.vcldes
           display by name d_cts24m00.nomrazsoc

           if param.operacao = "a" then
              if d_cts24m00.atdvclsgl is null then
                 next field pstcoddig
              else
                 let param.operacao = "X"
                 next field atdvclsgl
              end if
           end if

           display by name d_cts24m00.atdvclsgl attribute (reverse)

    after  field atdvclsgl
           display by name d_cts24m00.atdvclsgl

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field dtfim
           end if

           if d_cts24m00.atdvclsgl is null then
              next field pstcoddig
           end if

           select vclcoddig, mdtcod, socoprsitcod, pstcoddig
             into d_cts24m00.vclcoddig    , d_cts24m00.mdtcod,
                  d_cts24m00.socoprsitcod, ws.pstcoddig
             from datkveiculo
            where atdvclsgl = d_cts24m00.atdvclsgl

           if sqlca.sqlcode <> 0 then
              error "Veiculo nao existe!"
              next field atdvclsgl
           else
              if d_cts24m00.socoprsitcod <> 1 then
                 error "Viatura Bloqueda/Cancelada!"
              else
                 call cts15g00(d_cts24m00.vclcoddig)
                      returning d_cts24m00.vcldes

                 select nomrazsoc
                   into d_cts24m00.nomrazsoc
                   from dpaksocor
                  where pstcoddig   = ws.pstcoddig

                 display by name d_cts24m00.vcldes
                 display by name d_cts24m00.nomrazsoc
              end if
           end if

           if d_cts24m00.atdvclsgl is not null   then
              next field tltmsgcod
           end if

    before field pstcoddig

           initialize d_cts24m00.nomrazsoc to null
           display by name d_cts24m00.nomrazsoc

           if param.operacao = "a" then
              if d_cts24m00.pstcoddig is null then
                 next field mdtctrcod
              else
                 let param.operacao = "X"
                 next field pstcoddig
              end if
           end if

           display by name d_cts24m00.pstcoddig attribute (reverse)

    after field pstcoddig
           display by name d_cts24m00.pstcoddig

           if fgl_lastkey() = fgl_keyval("up")      or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_cts24m00.pstcoddig is null then
                 next field atdvclsgl
              end if
           end if

           if d_cts24m00.pstcoddig is null then
              next field mdtctrcod
           end if

           select nomrazsoc, prssitcod
             into d_cts24m00.nomrazsoc, d_cts24m00.prssitcod
             from dpaksocor
           where pstcoddig = d_cts24m00.pstcoddig

           if sqlca.sqlcode <> 0 then
              error "Prestador nao existe!"
              next field pstcoddig
           else
              if param.operacao <> "p" then
                 if d_cts24m00.prssitcod <> "A"  then
                    error " Prestador Bloqueado/Cancelado!"
                    next field pstcoddig
                 end if

                 select count(*)
                   into ws.count
                   from dpaksocor, datkveiculo
                  where dpaksocor.pstcoddig     = d_cts24m00.pstcoddig
                    and dpaksocor.pstcoddig   <> 0
                    and datkveiculo.pstcoddig = dpaksocor.pstcoddig
                    and dpaksocor.prssitcod   = "A"
                    and datkveiculo.pgrnum is not null

                 if ws.count  is null  or
                    ws.count  = 0      then
                    error "Frota nao contem nenhuma viatura relacionada!"
                    next field pstcoddig
                 else
                    error "Frota contem ",ws.count using "###"," viatura(s) relacionada(s)!"
                 end if
              end if
              display by name d_cts24m00.nomrazsoc
           end if

           if d_cts24m00.pstcoddig is not null then
              next field tltmsgcod
           end if

    before field mdtctrcod
           initialize d_cts24m00.mdtfqcdes  to null
           display by name d_cts24m00.mdtfqcdes
           if param.operacao = "a" then
              if d_cts24m00.mdtctrcod is null then
                 next field c24tltgrpnum
              else
                 let param.operacao = "X"
                 next field mdtctrcod
              end if
           end if

           display by name d_cts24m00.mdtctrcod attribute (reverse)

    after field mdtctrcod
           display by name d_cts24m00.mdtctrcod

            if fgl_lastkey() = fgl_keyval("up")      or
               fgl_lastkey() = fgl_keyval ("left")   then
               if d_cts24m00.mdtctrcod is null       then
                  next field pstcoddig
               end if
           end if

           if d_cts24m00.mdtctrcod is null then
              next field c24tltgrpnum
           end if

           select mdtctrcod, mdtctrstt, mdtfqcdes
             into d_cts24m00.mdtctrcod, d_cts24m00.mdtctrstt,
                  d_cts24m00.mdtfqcdes
             from datkmdtctr
            where mdtctrcod = d_cts24m00.mdtctrcod

           if sqlca.sqlcode <> 0 then
              error "Controladora nao existe!"
              next field mdtctrcod
           else
              if param.operacao <> "p" then
                 if d_cts24m00.mdtctrstt <> 0 then
                    error "Controladora Bloqueada/Cancelada!"
                    next field mdtctrcod
                 end if

                 select count(*)
                   into ws.count
                   from datkmdt, datkveiculo
                  where datkmdt.mdtctrcod        = d_cts24m00.mdtctrcod
                    and datkmdt.mdtcod           <> 0
                    and datkveiculo.mdtcod       = datkmdt.mdtcod
                    and datkveiculo.socoprsitcod = 1

                 if ws.count   is null or
                    ws.count = 0       then
                    error "Controladora nao contem nenhum veiculo relacionado!"
                    next field mdtctrcod
                 else
                    error "Controladora contem ",ws.count using "###"," veiculo(s) relacionado(s)!"
                 end if
              end if
              display by name d_cts24m00.mdtctrcod
              display by name d_cts24m00.mdtfqcdes
            end if

            if d_cts24m00.mdtctrcod is not null then
               next field tltmsgcod
            end if

    before field c24tltgrpnum

           initialize d_cts24m00.c24tltgrpdes to null
           display by name d_cts24m00.c24tltgrpdes

           if param.operacao = "a" then
              if d_cts24m00.c24tltgrpnum is null then
                 next field pgrnum
              else
                 let param.operacao = "X"
                 next field c24tltgrpnum
              end if
           end if

           display by name d_cts24m00.c24tltgrpnum attribute (reverse)

    after field c24tltgrpnum
           display by name d_cts24m00.c24tltgrpnum

           if fgl_lastkey() = fgl_keyval("up")      or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_cts24m00.c24tltgrpnum is null then
                 next field mdtctrcod
              end if
           end if

           if d_cts24m00.c24tltgrpnum is null then
              next field pgrnum
           end if

           select c24tltgrpdes, c24tltgrpstt
             into d_cts24m00.c24tltgrpdes, d_cts24m00.c24tltgrpstt
             from datktltgrp
            where c24tltgrpnum = d_cts24m00.c24tltgrpnum

           if sqlca.sqlcode <> 0 then
              error "Grupo nao existe!"
              next field c24tltgrpnum
           else
              if param.operacao <> "p" then
                 if d_cts24m00.c24tltgrpstt <> "A" then
                    error "Grupo Bloqueado/Cancelado!"
                    next field c24tltgrpnum
                 end if

                 select count(*)
                   into ws.count
                   from datktltgrp, datktltgrpitm
                  where datktltgrp.c24tltgrpnum    = d_cts24m00.c24tltgrpnum
                    and datktltgrp.c24tltgrpnum    <> 0
                    and datktltgrpitm.c24tltgrpnum = datktltgrp.c24tltgrpnum
                    and datktltgrp.c24tltgrpstt    = "A"

                 if ws.count   is null or
                    ws.count = 0       then
                    error "Grupo nao contem nenhum viatura relacionada!"
                    next field c24tltgrpnum
                 else
                    error "Grupo contem ",ws.count using "###"," viatura(s) relacionada(s)!"
                 end if
              end if
              display by name d_cts24m00.c24tltgrpdes
            end if

            if d_cts24m00.c24tltgrpnum is not null then
               next field tltmsgcod
            else
               next field pgrnum
            end if

    before field pgrnum

           initialize d_cts24m00.ustnom to null
           display by name d_cts24m00.ustnom

           if param.operacao = "a" then
              if d_cts24m00.pgrnum is null then
                 next field pgrnum
              else
                 let param.operacao = "X"
                 next field pgrnum
              end if
           end if

           display by name d_cts24m00.pgrnum attribute (reverse)

    after field pgrnum
           display by name d_cts24m00.pgrnum

           if fgl_lastkey() = fgl_keyval("up")      or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_cts24m00.pgrnum is null          then
                 next field c24tltgrpnum
              end if
           end if

           if d_cts24m00.pgrnum is null then
              error "Informe o Nr. do Teletrim"
              next field pgrnum
           end if

           select ustnom, ustsit
             into d_cts24m00.ustnom, d_cts24m00.ustsit
             from htlrust
            where pgrnum = d_cts24m00.pgrnum

           if sqlca.sqlcode <> 0 then
              error "Pager nao existe!"
              next field pgrnum
           else
              if d_cts24m00.ustsit <> "A" then
                 error "Pager Bloqueado/Cancelado!"
                 next field pgrnum
              else
                 display by name d_cts24m00.ustnom
              end if
           end if

           if d_cts24m00.pgrnum is not null then
              next field tltmsgcod
           end if

    before field tltmsgcod
           display by name d_cts24m00.tltmsgcod attribute (reverse)

    after field tltmsgcod
           display by name d_cts24m00.tltmsgcod

           if fgl_lastkey() = fgl_keyval("up")      or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_cts24m00.atdvclsgl is not null   then
                 next field atdvclsgl
              end if
              if d_cts24m00.pstcoddig is not null   then
                 next field pstcoddig
              end if
              if d_cts24m00.mdtctrcod is not null   then
                 next field mdtctrcod
              end if
              if d_cts24m00.c24tltgrpnum is not null then
                 next field c24tltgrpnum
              end if
              if d_cts24m00.pgrnum is not null       then
                 next field pgrnum
              end if
           end if

           if d_cts24m00.tltmsgcod is null   then
              if param.operacao = "p" then
                 error " Informe o codigo da mensagem para a pesquisa!"
                 next field tltmsgcod
              end if
              initialize d_cts24m00.tltmsgtxt to null
           else
              select tltmsgtxt,  tltmsgstt
                into d_cts24m00.tltmsgtxt , d_cts24m00.tltmsgstt
                from datktltmsg
               where tltmsgcod = d_cts24m00.tltmsgcod

              if sqlca.sqlcode <> 0 then
                 call cts24m01() returning d_cts24m00.tltmsgcod
                 next field tltmsgcod
              else
                 if d_cts24m00.tltmsgstt <> "A" then
                    error "Mensagem Bloqueada/Cancelada!"
                    next field tltmsgcod
                 end if
              end if
            end if

            let d_cts24m00.tltmsgtxt1 =  d_cts24m00.tltmsgtxt[001,049]
            let d_cts24m00.tltmsgtxt2 =  d_cts24m00.tltmsgtxt[050,099]
            let d_cts24m00.tltmsgtxt3 =  d_cts24m00.tltmsgtxt[100,149]
            let d_cts24m00.tltmsgtxt4 =  d_cts24m00.tltmsgtxt[150,199]
            let d_cts24m00.tltmsgtxt5 =  d_cts24m00.tltmsgtxt[200,239]

            display by name d_cts24m00.tltmsgtxt1, d_cts24m00.tltmsgtxt2,
                            d_cts24m00.tltmsgtxt3, d_cts24m00.tltmsgtxt4,
                            d_cts24m00.tltmsgtxt5

            if param.operacao = "p" then
               exit input
            end if

    before field tltmsgtxt1
           display by name d_cts24m00.tltmsgtxt1 attribute (reverse)

    after field tltmsgtxt1
           display by name d_cts24m00.tltmsgtxt1

           if fgl_lastkey() = fgl_keyval("up")   and
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt1
           end if

    before field tltmsgtxt2
           display by name d_cts24m00.tltmsgtxt2 attribute (reverse)

    after field tltmsgtxt2
           display by name d_cts24m00.tltmsgtxt2

           if fgl_lastkey() = fgl_keyval("up")   and
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt1
           end if

    before field tltmsgtxt3
           display by name d_cts24m00.tltmsgtxt3 attribute (reverse)

    after field tltmsgtxt3
           display by name d_cts24m00.tltmsgtxt3

           if fgl_lastkey() = fgl_keyval("up")   and
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt2
           end if

    before field tltmsgtxt4
           display by name d_cts24m00.tltmsgtxt4 attribute (reverse)

    after field tltmsgtxt4
           display by name d_cts24m00.tltmsgtxt4

           if fgl_lastkey() = fgl_keyval("up")   and
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt3
           end if

    before field tltmsgtxt5
           display by name d_cts24m00.tltmsgtxt5 attribute (reverse)

    after field tltmsgtxt5
           display by name d_cts24m00.tltmsgtxt5

           if fgl_lastkey() = fgl_keyval("up")   and
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt5
           end if

           if d_cts24m00.tltmsgtxt1 is null and
              d_cts24m00.tltmsgtxt2 is null and
              d_cts24m00.tltmsgtxt3 is null and
              d_cts24m00.tltmsgtxt4 is null and
              d_cts24m00.tltmsgtxt5 is null then
              error "Sera' necessario informar a mensagem para ser enviada!"
              next field tltmsgtxt1
           end if

    on key (interrupt)
           exit input

 end input

 if int_flag   then
    initialize d_cts24m00.*  to null
 else
    let d_cts24m00.tltmsgtxt = d_cts24m00.tltmsgtxt1, d_cts24m00.tltmsgtxt2,
                               d_cts24m00.tltmsgtxt3, d_cts24m00.tltmsgtxt4,
                               d_cts24m00.tltmsgtxt5
 end if

 return d_cts24m00.*

 end function   # cts24m00_input

#------------------------------------------------------------
 function cts24m00_pesquisa()
#------------------------------------------------------------

 define d_cts24m00   record
        tltmvtnum    like  datmtlt.tltmvtnum,
        dtini        date,
        dtfim        date,
        atdvclsgl    like  datmtlt.atdvclsgl,
        vclcoddig    like  datkveiculo.vclcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        socoprsitcod like  datkveiculo.socoprsitcod,
        vcldes       char(58),
        pstcoddig    like  datmtlt.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtctrcod    like  datmtlt.mdtctrcod,
        c24tltgrpnum like  datmtlt.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        c24tltgrpstt like  datktltgrp.c24tltgrpstt,
        pgrnum       like  datmtlt.pgrnum,
        ustnom       like  htlrust.ustnom,
        ustsit       like  htlrust.ustsit,
        ustcod       like  htlrust.ustcod,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        informa      char(60),
        mdtfqcdes    like  datkmdtctr.mdtfqcdes
 end record

 define ws           record
        comando      char(500),
        tltmvtnum    like  datmtltmsglog.tltmvtnum,
        tltmvtnum_qb like  datmtltmsglog.tltmvtnum,
        atldat       like  datmtltmsglog.atldat,
        atldat_qb    like  datmtltmsglog.atldat,
        atlhor       char(08),
        atlhor_qb    char(08),
        conta        integer,
        total        integer,
        confirma     char(01)
 end record



        initialize  d_cts24m00.*  to  null

        initialize  ws.*  to  null

 initialize d_cts24m00.*   to null
 initialize ws.*           to null

 clear form

 call cts24m00_input("p", d_cts24m00.*) returning d_cts24m00.*

 if int_flag  then
    let int_flag = false
    initialize d_cts24m00.*  to null
    error " Operacao cancelada!"
    return
 end if

 message " Aguarde pesquisando !!!"

 let ws.conta = 0
 let ws.total = 0

 let ws.comando = " select count(*)       ",
                  " from datmtlt          ",
                  "where tltmvtnum    = ? ",
                  "  and tltmsgcod    = ", d_cts24m00.tltmsgcod,
                  "  and "

 if d_cts24m00.atdvclsgl is not null then
    let ws.comando = ws.comando clipped,
                     " atdvclsgl = '",d_cts24m00.atdvclsgl,"'"
 end if
 if d_cts24m00.pstcoddig is not null then
    let ws.comando = ws.comando clipped,
                     " pstcoddig = ",d_cts24m00.pstcoddig
 end if
 if d_cts24m00.mdtctrcod is not null then
    let ws.comando = ws.comando clipped,
                     " mdtctrcod = ",d_cts24m00.mdtctrcod
 end if
 if d_cts24m00.c24tltgrpnum is not null then
    let ws.comando = ws.comando clipped,
                     " c24tltgrpnum = ",d_cts24m00.c24tltgrpnum
 end if
 if d_cts24m00.pgrnum is not null then
    let ws.comando = ws.comando clipped,
                     " pgrnum = ",d_cts24m00.pgrnum
 end if
 prepare p_cts24m00_001 from ws.comando
 declare c_cts24m00_002 cursor for p_cts24m00_001

 declare c_cts24m00_003 cursor for
  select tltmvtnum, atldat, atlhor
    from datmtltmsglog
   where mstnum    > 0
     and mstnumseq = 1
     and atldat    between d_cts24m00.dtini
                       and d_cts24m00.dtfim

 foreach c_cts24m00_003 into ws.tltmvtnum, ws.atldat, ws.atlhor

    if ws.atlhor_qb      is not null      and
       ws.tltmvtnum_qb   = ws.tltmvtnum   and
       ws.atldat_qb      = ws.atldat      and
       ws.atlhor_qb[1,5] = ws.atlhor[1,5] then
       continue foreach
    end if

    let ws.tltmvtnum_qb = ws.tltmvtnum
    let ws.atldat_qb    = ws.atldat
    let ws.atlhor_qb    = ws.atlhor

    open  c_cts24m00_002 using ws.tltmvtnum
    fetch c_cts24m00_002 into  ws.conta
    close c_cts24m00_002

    if ws.conta is null then
       let ws.conta = 0
    end if

    let ws.total = ws.total + ws.conta

 end foreach

 prompt " Esta pesquisa totalizou ",ws.total using "<<<&"," envio(s)! " for char ws.confirma

 message ""
 clear form

 end function   #  cts24m00_pesquisa

#--------------------------------------------------------------------
 function cts24m00_ler(param)
#--------------------------------------------------------------------

 define param        record
        tltmvtnum    like datmtlt.tltmvtnum
 end record

 define d_cts24m00   record
        tltmvtnum    like  datmtlt.tltmvtnum,
        dtini        date,
        dtfim        date,
        atdvclsgl    like  datmtlt.atdvclsgl,
        vclcoddig    like  datkveiculo.vclcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        socoprsitcod like  datkveiculo.socoprsitcod,
        vcldes       char(58),
        pstcoddig    like  datmtlt.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtctrcod    like  datmtlt.mdtctrcod,
        c24tltgrpnum like  datmtlt.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        c24tltgrpstt like  datktltgrp.c24tltgrpstt,
        pgrnum       like  datmtlt.pgrnum,
        ustnom       like  htlrust.ustnom,
        ustsit       like  htlrust.ustsit,
        ustcod       like  htlrust.ustcod,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        informa      char(60),
        mdtfqcdes    like  datkmdtctr.mdtfqcdes
 end record

 define ws         record
    pstcoddig      like dpaksocor.pstcoddig,
    funnom         like isskfunc.funnom,
    mstnum         like datmtltmsglog.mstnum,
    atldat         like datmtltmsglog.atldat,
    atlhor         like datmtltmsglog.atlhor,
    atlemp         like datmtltmsglog.atlemp,
    atlmat         like datmtltmsglog.atlmat
 end record

 define ws_count     smallint


        let     ws_count  =  null

        initialize  d_cts24m00.*  to  null

        initialize  ws.*  to  null

 initialize ws_count to null
 initialize d_cts24m00.* to null
 initialize ws.*         to null

 select tltmvtnum, atdvclsgl   , pstcoddig,
        mdtctrcod, c24tltgrpnum, pgrnum,
        tltmsgcod, tltmsgtxt
   into d_cts24m00.tltmvtnum   , d_cts24m00.atdvclsgl,
        d_cts24m00.pstcoddig   , d_cts24m00.mdtctrcod,
        d_cts24m00.c24tltgrpnum, d_cts24m00.pgrnum,
        d_cts24m00.tltmsgcod   , d_cts24m00.tltmsgtxt
   from datmtlt
  where datmtlt.tltmvtnum = param.tltmvtnum

 if sqlca.sqlcode = notfound   then
    error " Grupo nao existe!"
    initialize d_cts24m00.*    to null
    return d_cts24m00.*
 end if

 if d_cts24m00.atdvclsgl is not null then
    select vclcoddig, mdtcod, socoprsitcod, pstcoddig
      into d_cts24m00.vclcoddig   , d_cts24m00.mdtcod,
           d_cts24m00.socoprsitcod, ws.pstcoddig
        from datkveiculo
       where atdvclsgl    = d_cts24m00.atdvclsgl
         and socoprsitcod = 1

      if sqlca.sqlcode <> 0    then
         error " Erro (",sqlca.sqlcode,") na leitura da Viatura!"
         initialize d_cts24m00.*    to null
         return d_cts24m00.*
      else
         call cts15g00(d_cts24m00.vclcoddig)
             returning d_cts24m00.vcldes

         select nomrazsoc
           into d_cts24m00.nomrazsoc
           from dpaksocor
          where pstcoddig = ws.pstcoddig

      end if
   end if

   if d_cts24m00.pstcoddig is not null then
      select nomrazsoc, prssitcod
        into d_cts24m00.nomrazsoc, d_cts24m00.prssitcod
        from dpaksocor
       where pstcoddig = d_cts24m00.pstcoddig
         and prssitcod = "A"

      if sqlca.sqlcode <> 0    then
         error " Erro (",sqlca.sqlcode,") na leitura do Prestador!"
         initialize d_cts24m00.*    to null
         return d_cts24m00.*
      else
         select count(*)
           into ws_count
           from dpaksocor, datkveiculo
          where dpaksocor.pstcoddig   = d_cts24m00.pstcoddig
            and dpaksocor.pstcoddig   <> 0
            and datkveiculo.pstcoddig = dpaksocor.pstcoddig
            and dpaksocor.prssitcod   = "A"
            and datkveiculo.pgrnum is not null

         if ws_count  is null  or
            ws_count  = 0      then
            error "Frota nao contem nenhuma viatura relacionada!"
         else
            error "Frota contem ",ws_count using "###"," viatura(s) relacionada(s)!"
         end if
      end if
   end if

     if d_cts24m00.mdtctrcod is not null then
        select mdtctrcod, mdtctrstt, mdtfqcdes
          into d_cts24m00.mdtctrcod,
               d_cts24m00.mdtctrstt,
               d_cts24m00.mdtfqcdes
          from datkmdtctr
         where mdtctrcod = d_cts24m00.mdtctrcod

        if sqlca.sqlcode <> 0    then
           error " Erro (",sqlca.sqlcode,") na leitura da Controladora!"
           initialize d_cts24m00.*    to null
           return d_cts24m00.*
        else
           select count(*)
                    into ws_count
                    from datkmdt, datkveiculo
                    where datkmdt.mdtctrcod        = d_cts24m00.mdtctrcod
                      and datkmdt.mdtcod           <> 0
                      and datkveiculo.mdtcod       = datkmdt.mdtcod
                      and datkveiculo.socoprsitcod = 1

                  if ws_count   is null or
                     ws_count = 0       then
                     error "Controladora nao contem nenhum veiculo relacionado!"
                  else
                     error "Controladora contem ",ws_count using "###"," veiculo(s) relacionado(s)!"
                  end if
         end if
      end if

      if d_cts24m00.c24tltgrpnum is not null then
         select c24tltgrpdes, c24tltgrpstt
            into d_cts24m00.c24tltgrpdes, d_cts24m00.c24tltgrpstt
            from datktltgrp
          where c24tltgrpnum = d_cts24m00.c24tltgrpnum

         if sqlca.sqlcode <> 0    then
            error " Erro (",sqlca.sqlcode,") na leitura do Grupo!"
            initialize d_cts24m00.*    to null
            return d_cts24m00.*
         else
            select count(*)
               into ws_count
               from datktltgrp, datktltgrpitm
             where datktltgrp.c24tltgrpnum      = d_cts24m00.c24tltgrpnum
               and   datktltgrp.c24tltgrpnum    <> 0
               and   datktltgrpitm.c24tltgrpnum = datktltgrp.c24tltgrpnum
               and   datktltgrp.c24tltgrpstt    = "A"

               if ws_count   is null or
                  ws_count = 0       then
                  error "Grupo nao contem nenhum viatura relacionada!"
               else
                  error "Grupo contem ",ws_count using "###"," viatura(s) relacionada(s)!"
               end if
         end if
      end if

      if d_cts24m00.pgrnum is not null then
         select ustnom, ustsit
            into d_cts24m00.ustnom, d_cts24m00.ustsit
            from htlrust
         where pgrnum = d_cts24m00.pgrnum

         if sqlca.sqlcode <> 0    then
            error " Erro (",sqlca.sqlcode,") na leitura do Pager!"
            initialize d_cts24m00.*    to null
            return d_cts24m00.*
         end if
      end if

      let d_cts24m00.tltmsgtxt1 =  d_cts24m00.tltmsgtxt[001,050]
      let d_cts24m00.tltmsgtxt2 =  d_cts24m00.tltmsgtxt[051,100]
      let d_cts24m00.tltmsgtxt3 =  d_cts24m00.tltmsgtxt[101,150]
      let d_cts24m00.tltmsgtxt4 =  d_cts24m00.tltmsgtxt[151,200]
      let d_cts24m00.tltmsgtxt5 =  d_cts24m00.tltmsgtxt[201,240]

      select max(mstnum)
        into ws.mstnum
        from datmtltmsglog
       where tltmvtnum = d_cts24m00.tltmvtnum

      if ws.mstnum is not null  or
         ws.mstnum <> 0         then
         select atldat, atlhor, atlemp, atlmat
           into ws.atldat, ws.atlhor, ws.atlemp, ws.atlmat
           from datmtltmsglog
          where mstnum    = ws.mstnum
            and mstnumseq = 1

         let ws.funnom = "NAO CADASTRADO!"

         select funnom
           into ws.funnom
           from isskfunc
          where empcod = ws.atlemp
            and funmat = ws.atlmat

         let ws.funnom = upshift(ws.funnom)

         let d_cts24m00.informa = "Ultimo envio: ",ws.atldat,
                                            " as ",ws.atlhor,
                                           " por ",ws.funnom

      end if


  return d_cts24m00.*

 end function   # cts24m00_ler

#------------------------------------------------------------
 function cts24m00_display(d_cts24m00)
#------------------------------------------------------------

 define d_cts24m00   record
        tltmvtnum    like  datmtlt.tltmvtnum,
        dtini        date,
        dtfim        date,
        atdvclsgl    like  datmtlt.atdvclsgl,
        vclcoddig    like  datkveiculo.vclcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        socoprsitcod like  datkveiculo.socoprsitcod,
        vcldes       char  (58),
        pstcoddig    like  datmtlt.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtctrcod    like  datmtlt.mdtctrcod,
        c24tltgrpnum like  datmtlt.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        c24tltgrpstt like  datktltgrp.c24tltgrpstt,
        pgrnum       like  datmtlt.pgrnum,
        ustnom       like  htlrust.ustnom,
        ustsit       like  htlrust.ustsit,
        ustcod       like  htlrust.ustcod,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        informa      char(60),
        mdtfqcdes    like  datkmdtctr.mdtfqcdes
 end record



 display by name d_cts24m00.tltmvtnum,
                 d_cts24m00.atdvclsgl,
                 d_cts24m00.vcldes,
                 d_cts24m00.pstcoddig,
                 d_cts24m00.nomrazsoc,
                 d_cts24m00.mdtctrcod,
                 d_cts24m00.c24tltgrpnum,
                 d_cts24m00.c24tltgrpdes,
                 d_cts24m00.pgrnum,
                 d_cts24m00.ustnom,
                 d_cts24m00.tltmsgcod,
                 d_cts24m00.tltmsgtxt1,
                 d_cts24m00.tltmsgtxt2,
                 d_cts24m00.tltmsgtxt3,
                 d_cts24m00.tltmsgtxt4,
                 d_cts24m00.tltmsgtxt5,
                 d_cts24m00.informa,
                 d_cts24m00.mdtfqcdes

 end function    # cts24m00_display

#------------------------------------------------------------
 function cts24m00_envia(param, d_cts24m00)
#------------------------------------------------------------

 define param        record
        tltmvtnum    like datmtlt.tltmvtnum
 end record

 define d_cts24m00   record
        tltmvtnum    like  datmtlt.tltmvtnum,
        dtini        date,
        dtfim        date,
        atdvclsgl    like  datmtlt.atdvclsgl,
        vclcoddig    like  datkveiculo.vclcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        socoprsitcod like  datkveiculo.socoprsitcod,
        vcldes       char(58),
        pstcoddig    like  datmtlt.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtctrcod    like  datmtlt.mdtctrcod,
        c24tltgrpnum like  datmtlt.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        c24tltgrpstt like  datktltgrp.c24tltgrpstt,
        pgrnum       like  datmtlt.pgrnum,
        ustnom       like  htlrust.ustnom,
        ustsit       like  htlrust.ustsit,
        ustcod       like  htlrust.ustcod,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(40),
        informa      char(60),
        mdtfqcdes    like  datkmdtctr.mdtfqcdes
 end record

 define ws           record
        errcod       smallint,
        sqlcod       integer,
        mstnum       like htlmmst.mstnum,
        comando      char(500),
        socvclcod    like datkveiculo.socvclcod
 end record

 #-------------------------------
 #PREPARE PARA VERIFICACAO
 #-------------------------------



        initialize  ws.*  to  null

 let ws.comando = " select pgrnum            ",
                  " from datkveiculo         ",
                  " where pstcoddig    = ?   ",
                  "   and socoprsitcod = 1   "
 prepare p_cts24m00_002 from ws.comando
 declare c_cts24m00_004 cursor for p_cts24m00_002

 let ws.comando = " select mdtcod           ",
                  " from datkmdt            ",
                  " where mdtctrcod     = ? "
 prepare p_cts24m00_003 from ws.comando
 declare c_cts24m00_005 cursor for p_cts24m00_003

 let ws.comando = " select atdvclsgl, pgrnum",
                  " from datktltgrpitm      ",
                  " where c24tltgrpnum  = ? "
 prepare p_cts24m00_004 from ws.comando
 declare c_cts24m00_006 cursor for p_cts24m00_004

 menu "Confirma envio ?"

    command "Nao" "Nao envia mensagem "
            clear form
            initialize d_cts24m00.* to null
            error " Envio cancelado!"
            exit menu

    command "Sim" "Envia mensagem "
            call cts24m00_ler(d_cts24m00.tltmvtnum)
                    returning d_cts24m00.*

            if d_cts24m00.tltmvtnum is null then
               error " Registro nao localizado "
               return
            end if

            message ""
            message " Aguarde ...  enviando mensagem!"

               if d_cts24m00.atdvclsgl is not null then

                  #---------------------------------------
                  #Verifica se a viatura tem Nro. Teletrim
                  #---------------------------------------

                  select pgrnum
                    into  d_cts24m00.pgrnum
                    from datkveiculo
                  where atdvclsgl      = d_cts24m00.atdvclsgl
                    and   socoprsitcod = 1

                  if d_cts24m00.pgrnum is not null and
                     d_cts24m00.pgrnum <> 0        then

                     select ustcod
                       into d_cts24m00.ustcod
                       from htlrust
                     where pgrnum = d_cts24m00.pgrnum

                     if sqlca.sqlcode = 0 then
                        call cts00g04_env_msgtel(d_cts24m00.ustcod,
                                                 "CENTRAL 24H/RADIO - MONITORACAO DA FROTA",
                                                 d_cts24m00.tltmsgtxt,
                                                 g_issk.funmat,
                                                 g_issk.empcod,
                                                 g_issk.maqsgl,
                                                 d_cts24m00.tltmvtnum,"O")
                                       returning ws.errcod,
                                                 ws.sqlcod,
                                                 ws.mstnum
                     end if
                  end if
               else

                  if d_cts24m00.pstcoddig is not null then

                     #----------------------------------------------
                     #Verifica a quantidade de viaturas do prestador
                     #Pegando o Nro. Teletrim
                     #----------------------------------------------

                     open  c_cts24m00_004 using d_cts24m00.pstcoddig

                     while true
                       fetch c_cts24m00_004 into d_cts24m00.pgrnum

                       if sqlca.sqlcode <> 0 then
                          exit while
                       end if

                        if d_cts24m00.pgrnum is not null then

                            select ustcod
                              into d_cts24m00.ustcod
                              from htlrust
                            where pgrnum = d_cts24m00.pgrnum

                            if sqlca.sqlcode = 0 then
                               call cts00g04_env_msgtel(d_cts24m00.ustcod,
                                                        "CENTRAL 24H/RADIO - MONITORACAO DA FROTA",
                                                        d_cts24m00.tltmsgtxt,
                                                        g_issk.funmat,
                                                        g_issk.empcod,
                                                        g_issk.maqsgl,
                                                        d_cts24m00.tltmvtnum,"O")
                                              returning ws.errcod,
                                                        ws.sqlcod,
                                                        ws.mstnum
                            end if
                        end if
                     end while
                     close c_cts24m00_004
                  else

                     if d_cts24m00.mdtctrcod is not null then

                        #-------------------------------------------------
                        #Verifica a quantidade de viaturas da Controladora
                        #Pegando o Nro. Teletrim
                        #-------------------------------------------------

                        open c_cts24m00_005 using d_cts24m00.mdtctrcod

                        while true
                          fetch c_cts24m00_005 into d_cts24m00.mdtcod

                          if sqlca.sqlcode = 0 then
                              select pgrnum
                                 into d_cts24m00.pgrnum
                                 from datkveiculo
                              where mdtcod       = d_cts24m00.mdtcod
                                and socoprsitcod = 1

                              if d_cts24m00.pgrnum is not null then

                                 select ustcod
                                   into d_cts24m00.ustcod
                                   from htlrust
                                 where pgrnum = d_cts24m00.pgrnum

                                 if sqlca.sqlcode = 0 then
                                    call cts00g04_env_msgtel(d_cts24m00.ustcod,
                                                             "CENTRAL 24H/RADIO - MONITORACAO DA FROTA",
                                                             d_cts24m00.tltmsgtxt,
                                                             g_issk.funmat,
                                                             g_issk.empcod,
                                                             g_issk.maqsgl,
                                                             d_cts24m00.tltmvtnum,"O")
                                                   returning ws.errcod,
                                                             ws.sqlcod,
                                                             ws.mstnum
                                 end if
                              end if
                          else
                              exit while
                          end if
                        end while
                        close c_cts24m00_005
                     else

                        if d_cts24m00.c24tltgrpnum is not null then

                           #------------------------------------------
                           #Verifica a quantidade de viaturas do Grupo
                           #Pegando o Nro. Teletrim
                           #------------------------------------------

                           select c24tltgrpnum
                            into d_cts24m00.c24tltgrpnum
                            from datktltgrp
                           where c24tltgrpstt = "A"
                             and c24tltgrpnum = d_cts24m00.c24tltgrpnum

                           if sqlca.sqlcode = 0 then

                              open c_cts24m00_006 using d_cts24m00.c24tltgrpnum
                              while true
                                fetch c_cts24m00_006 into d_cts24m00.atdvclsgl,                                                           d_cts24m00.pgrnum
                                   if sqlca.sqlcode = 0 then
                                     if d_cts24m00.atdvclsgl is not null then
                                        select pgrnum
                                          into d_cts24m00.pgrnum
                                          from datkveiculo
                                         where atdvclsgl    = d_cts24m00.atdvclsgl
                                           and   socoprsitcod = 1
                                     end if

                                     if d_cts24m00.pgrnum is not null and
                                        d_cts24m00.pgrnum <> 0        then

                                         select ustcod
                                           into d_cts24m00.ustcod
                                           from htlrust
                                         where pgrnum = d_cts24m00.pgrnum

                                         if sqlca.sqlcode = 0 then
                                            call cts00g04_env_msgtel(d_cts24m00.ustcod,
                                                                     "CENTRAL 24H/RADIO - MONITORACAO DA FROTA",
                                                                     d_cts24m00.tltmsgtxt,
                                                                     g_issk.funmat,
                                                                     g_issk.empcod,
                                                                     g_issk.maqsgl,
                                                                     d_cts24m00.tltmvtnum,"O")
                                                           returning ws.errcod,
                                                                     ws.sqlcod,
                                                                     ws.mstnum
                                         end if
                                     end if
                                   else
                                     exit while
                                   end if
                              end while
                              close c_cts24m00_006
                           end if
                        else

                           if d_cts24m00.pgrnum is not null then

                              #---------------------------------------
                              #Verifica o Nro. Teletrim
                              #---------------------------------------

                              select ustcod
                                into d_cts24m00.ustcod
                                from htlrust
                              where pgrnum   = d_cts24m00.pgrnum
                                and ustsit   = "A"

                              if sqlca.sqlcode = 0 then
                                 call cts00g04_env_msgtel(d_cts24m00.ustcod,
                                                          "CENTRAL 24H/RADIO - MONITORACAO DA FROTA",
                                                          d_cts24m00.tltmsgtxt,
                                                          g_issk.funmat,
                                                          g_issk.empcod,
                                                          g_issk.maqsgl,
                                                          d_cts24m00.tltmvtnum,"O")
                                                returning ws.errcod,
                                                          ws.sqlcod,
                                                          ws.mstnum
                              end if
                           end if
                        end if
                     end if
                  end if
               end if
            exit menu
 end menu

 message ""

end function   # cts24m00_envia

