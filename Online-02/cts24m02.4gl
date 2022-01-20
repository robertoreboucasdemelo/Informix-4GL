#############################################################################
# Nome do Modulo: cts24m02                                          Kevellin#
#                                                                           #
# Envio de mensagens MID                                            MAR/2009#
#                                                                           #
# Data: 16/03/2009                                                          #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#                                                                           #
#############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_sigla array[3000] of record
    siglas like datkveiculo.atdvclsgl
end record

define m_mdtcod array[3000] of record
    mdtcod like datkmdt.mdtcod
end record

define m_id_msg array[3000] of record
    mdtmsgnum like datmmdtmsg.mdtmsgnum
end record

define m_contador smallint, m_flg smallint

#------------------------------------------------------------
 function cts24m02()
#------------------------------------------------------------

 define d_cts24m02   record
        atdvclsgl    like  datkveiculo.atdvclsgl,
        vcldes       char(58),
        mdtcod       like  datkveiculo.mdtcod,
        pstcoddig    like  datkveiculo.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        mdtctrcod    like  datkmdt.mdtctrcod,
        mdtfqcdes    like  datkmdtctr.mdtfqcdes,
        vcldtbgrpcod like  dattfrotalocal.vcldtbgrpcod,
        vcldtbgrpdes like  datkvcldtbgrp.vcldtbgrpdes,
        c24tltgrpnum like  datktltgrp.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        socvcltip    like  datkveiculo.socvcltip,
        vcltipdes    char(35),
        socntzcod    like  datksocntz.socntzcod,
        socntzdes    like  datksocntz.socntzdes,
        asitipcod    like  datkasitip.asitipcod,
        asitipdes    like  datkasitip.asitipdes,
        ufdcod       like  datkmpacid.ufdcod,
        cidnom       like  datkmpacid.cidnom,
        vclcoddig    like  datkveiculo.vclcoddig,
        socoprsitcod like  datkveiculo.socoprsitcod,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtcfgcod    like  datkmdt.mdtcfgcod,
        mdtcfgdes    like datkmdtcfg.mdtcfgdes,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(50),
        informa      char(60)
 end record

 define ws_count     smallint

        let     ws_count  =  null

        initialize  d_cts24m02.*  to  null

 let int_flag = false
 initialize d_cts24m02.*  to null

 #if not get_niv_mod(g_issk.prgsgl, "cts24m02") then
 #   error " Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 open window cts24m02 at 04,2 with form "cts24m02"

 menu "MENSAGEM MID"

 before menu
     hide option all
     show option all
     if g_issk.acsnivcod >= g_issk.acsnivcns  then
        show option "Inclui", "eNvia", "Encerra"
     end if
     show option "Encerra"

 command key ("I") "Inclui"
                   "Inclui para envio!"
          message ""
          call cts24m02_input(d_cts24m02.*)
            returning d_cts24m02.*

 command key ("N") "eNvia"
                   "Envia para MID selecionado!"
          message ""
          if m_flg then
             call cts24m02_envia(d_cts24m02.*)
          else
             error "Digite a Mensagem!"
          end if
          #initialize d_cts24m02.*  to null

 command key (interrupt,E) "Encerra"
         "Retorna ao menu anterior"
          exit menu
 end menu

 let int_flag = false
 close window cts24m02

 end function  # cts24m02

#--------------------------------------------------------------------
 function cts24m02_input(d_cts24m02)
#--------------------------------------------------------------------

 define d_cts24m02   record
        atdvclsgl    like  datkveiculo.atdvclsgl,
        vcldes       char(58),
        mdtcod       like  datkveiculo.mdtcod,
        pstcoddig    like  datkveiculo.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        mdtctrcod    like  datkmdt.mdtctrcod,
        mdtfqcdes    like  datkmdtctr.mdtfqcdes,
        vcldtbgrpcod like  dattfrotalocal.vcldtbgrpcod,
        vcldtbgrpdes like  datkvcldtbgrp.vcldtbgrpdes,
        c24tltgrpnum like  datktltgrp.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        socvcltip    like  datkveiculo.socvcltip,
        vcltipdes    char(35),
        socntzcod    like  datksocntz.socntzcod,
        socntzdes    like  datksocntz.socntzdes,
        asitipcod    like  datkasitip.asitipcod,
        asitipdes    like  datkasitip.asitipdes,
        ufdcod       like  datkmpacid.ufdcod,
        cidnom       like  datkmpacid.cidnom,
        vclcoddig    like  datkveiculo.vclcoddig,
        socoprsitcod like  datkveiculo.socoprsitcod,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtcfgcod    like  datkmdt.mdtcfgcod,
        mdtcfgdes    like datkmdtcfg.mdtcfgdes,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(50),
        informa      char(60)
 end record

 define ws           record
        pstcoddig    like dpaksocor.pstcoddig,
        mdtcod       like  datkveiculo.mdtcod,
        cidcod       like glakcid.cidcod,
        vcldtbgrpstt like datkvcldtbgrp.vcldtbgrpstt,
        c24tltgrpstt like datktltgrp.c24tltgrpstt,
        count        smallint,
        campo        char(13),
        resp         char(01),
        erro         smallint
 end record

 #DEFINIÇÃO DE VARIÁVEIS PARA POP-UP##########################
 define lr_popup       record
        lin            smallint   # Nro da linha
       ,col            smallint   # Nro da coluna
       ,titulo         char (054) # Titulo do Formulario
       ,tit2           char (012) # Titulo da 1a.coluna
       ,tit3           char (040) # Titulo da 2a.coluna
       ,tipcod         char (001) # Tipo do Codigo a retornar
                                  # 'N' - Numerico
                                  # 'A' - Alfanumerico
       ,cmd_sql        char (1999)# Comando SQL p/ pesquisa
       ,aux_sql        char (200) # Complemento SQL apos where
       ,tipo           char (001) # Tipo de Popup
                                  # 'D' Direto
                                  # 'E' Com entrada
 end  record

 define lr_retorno     record
        erro           smallint,
        cpocod         like iddkdominio.cpocod,
        cpodes         like iddkdominio.cpodes
 end record
 #############################################################
 clear form
 initialize d_cts24m02.* to null
 initialize ws.*  to null
 initialize lr_retorno.* to null
 let int_flag     =  false


 input by name d_cts24m02.atdvclsgl , d_cts24m02.mdtcod,
               d_cts24m02.pstcoddig,  d_cts24m02.mdtctrcod,
               d_cts24m02.vcldtbgrpcod, d_cts24m02.c24tltgrpnum,
               d_cts24m02.socvcltip, d_cts24m02.socntzcod,
               d_cts24m02.asitipcod, d_cts24m02.cidnom,
               d_cts24m02.mdtcfgcod, d_cts24m02.tltmsgcod ,
               d_cts24m02.tltmsgtxt1, d_cts24m02.tltmsgtxt2,
               d_cts24m02.tltmsgtxt3, d_cts24m02.tltmsgtxt4,
               d_cts24m02.tltmsgtxt5  without defaults

    #SIGLA DO VEÍCULO
    before field atdvclsgl
           initialize d_cts24m02.vcldes, d_cts24m02.nomrazsoc to null
           display by name d_cts24m02.vcldes
           display by name d_cts24m02.nomrazsoc
           display by name d_cts24m02.atdvclsgl attribute (reverse)

    after  field atdvclsgl
           display by name d_cts24m02.atdvclsgl

           if d_cts24m02.atdvclsgl is null then
              next field mdtcod
           end if

           select vclcoddig, mdtcod, socoprsitcod, pstcoddig
             into d_cts24m02.vclcoddig    , ws.mdtcod,
                  d_cts24m02.socoprsitcod,  ws.pstcoddig
             from datkveiculo
            where atdvclsgl = d_cts24m02.atdvclsgl

           if sqlca.sqlcode <> 0 then
              error "Veiculo nao existe!"
              next field atdvclsgl
           else
              if d_cts24m02.socoprsitcod <> 1 then
                 error "Viatura Bloqueda/Cancelada!"
              else

                  call cts15g00(d_cts24m02.vclcoddig)
                       returning d_cts24m02.vcldes

                  select nomrazsoc
                    into d_cts24m02.nomrazsoc
                    from dpaksocor
                   where pstcoddig   = ws.pstcoddig

                  display by name ws.mdtcod
                  display by name d_cts24m02.vcldes
                  display by name ws.pstcoddig
                  display by name d_cts24m02.nomrazsoc

                  #Verifica se a viatura tem MDTCOD
                  if ws.mdtcod is null then
                     error "Viatura não possui MID para envio da mensagem!"
                     next field atdvclsgl
                  end if

              end if

           end if

           if d_cts24m02.atdvclsgl is not null   then
              next field tltmsgcod
           end if

    #CÓDIGO DO MDT
    before field mdtcod
        display by name d_cts24m02.mdtcod attribute (reverse)

    after field mdtcod
        display by name d_cts24m02.mdtcod

        if fgl_lastkey() = fgl_keyval("up")      or
           fgl_lastkey() = fgl_keyval ("left")   then
           if d_cts24m02.mdtcod is null then
              next field atdvclsgl
           end if
        end if

        if d_cts24m02.mdtcod is null then
           next field pstcoddig
        end if

        select mdtcod
          into d_cts24m02.mdtcod
          from datkveiculo
         where mdtcod = d_cts24m02.mdtcod

         if sqlca.sqlcode <> 0 then
            error "MDT nao existe!"
            next field mdtcod
         else
            next field tltmsgcod
         end if

    #CÓDIGO DO PRESTADOR
    before field pstcoddig
           initialize d_cts24m02.nomrazsoc to null
           display by name d_cts24m02.nomrazsoc
           display by name d_cts24m02.pstcoddig attribute (reverse)

    after field pstcoddig
           display by name d_cts24m02.pstcoddig

           if fgl_lastkey() = fgl_keyval("up")      or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_cts24m02.pstcoddig is null then
                 next field mdtcod
              end if
           end if

           if d_cts24m02.pstcoddig is null then
              next field mdtctrcod
           end if

           select nomrazsoc, prssitcod
             into d_cts24m02.nomrazsoc, d_cts24m02.prssitcod
             from dpaksocor
           where pstcoddig = d_cts24m02.pstcoddig

           if sqlca.sqlcode <> 0 then
              error "Prestador nao existe!"
              next field pstcoddig
           else
               if d_cts24m02.prssitcod <> "A"  then
                  error " Prestador Bloqueado/Cancelado!"
                  next field pstcoddig
               end if

               display by name d_cts24m02.nomrazsoc
           end if

    #CÓDIGO DA CONTROLADORA
    before field mdtctrcod
           initialize d_cts24m02.mdtfqcdes  to null
           display by name d_cts24m02.mdtfqcdes
           display by name d_cts24m02.mdtctrcod attribute (reverse)

    after field mdtctrcod
           display by name d_cts24m02.mdtctrcod

            if fgl_lastkey() = fgl_keyval("up")      or
               fgl_lastkey() = fgl_keyval ("left")   then
               if d_cts24m02.mdtctrcod is null       then
                  next field pstcoddig
               end if
           end if

           if d_cts24m02.mdtctrcod is null then
              next field vcldtbgrpcod
           end if

           select mdtctrcod, mdtctrstt, mdtfqcdes
             into d_cts24m02.mdtctrcod, d_cts24m02.mdtctrstt,
                  d_cts24m02.mdtfqcdes
             from datkmdtctr
            where mdtctrcod = d_cts24m02.mdtctrcod

           if sqlca.sqlcode <> 0 then
              error "Controladora nao existe!"
              next field mdtctrcod
           else
             if d_cts24m02.mdtctrstt <> 0 then
                error "Controladora Bloqueada/Cancelada!"
                next field mdtctrcod
             end if

             display by name d_cts24m02.mdtctrcod
             display by name d_cts24m02.mdtfqcdes
            end if

    #GRUPO DE DISTRIBUIÇÃO
    before field vcldtbgrpcod
        display by name d_cts24m02.vcldtbgrpcod  attribute (reverse)

    after field vcldtbgrpcod
        display by name d_cts24m02.vcldtbgrpcod

        if fgl_lastkey() = fgl_keyval("up")      or
           fgl_lastkey() = fgl_keyval ("left")   then
           if d_cts24m02.vcldtbgrpcod is null then
              next field mdtctrcod
           end if
        end if

        if d_cts24m02.vcldtbgrpcod is null then
            let d_cts24m02.vcldtbgrpdes = null
            display by name d_cts24m02.vcldtbgrpdes
            next field c24tltgrpnum
        end if

        select vcldtbgrpstt,
               vcldtbgrpdes
          into ws.vcldtbgrpstt,
               d_cts24m02.vcldtbgrpdes
          from datkvcldtbgrp
         where datkvcldtbgrp.vcldtbgrpcod = d_cts24m02.vcldtbgrpcod

        if ws.vcldtbgrpstt  <>  "A"   then
           error " Grupo de distribuicao cancelado!"
           next field vcldtbgrpcod
        end if

        if sqlca.sqlcode  <>  0   then
           error " Grupo de distribuicao nao cadastrado, escolha um grupo cadastrado"
           #next field vcldtbgrpcod

           #CHAMAR POP-UP############################################
           let lr_popup.lin    = 6
           let lr_popup.col    = 2
           let lr_popup.titulo = "Grupos de distribuicao"
           let lr_popup.tit2   = "Codigo"
           let lr_popup.tit3   = "Descricao"
           let lr_popup.tipcod = "A"
           let lr_popup.cmd_sql = " select vcldtbgrpcod, vcldtbgrpdes ",
                                  "   from datkvcldtbgrp ",
                                  "  where vcldtbgrpstt = 'A' ",
                                  " order by vcldtbgrpcod "
           let lr_popup.aux_sql = " "
           let lr_popup.tipo   = "D"

           call ofgrc001_popup(lr_popup.*)
                returning lr_retorno.*

           let d_cts24m02.vcldtbgrpcod = lr_retorno.cpocod
           let d_cts24m02.vcldtbgrpdes = lr_retorno.cpodes
           display by name d_cts24m02.vcldtbgrpcod

           initialize lr_retorno.* to null
           ##########################################################

        end if

        display by name d_cts24m02.vcldtbgrpdes

    #CÓDIGO DO GRUPO DE MENSAGENS
    before field c24tltgrpnum
        display by name d_cts24m02.c24tltgrpnum  attribute (reverse)

    after field c24tltgrpnum
        display by name d_cts24m02.c24tltgrpnum

        if fgl_lastkey() = fgl_keyval("up")      or
           fgl_lastkey() = fgl_keyval ("left")   then
           if d_cts24m02.c24tltgrpnum is null then
              next field vcldtbgrpcod
           end if
        end if

        if d_cts24m02.c24tltgrpnum is null then
            let d_cts24m02.c24tltgrpdes = null
            display by name d_cts24m02.c24tltgrpdes
            next field socvcltip
        end if

        select c24tltgrpdes, c24tltgrpstt
          into d_cts24m02.c24tltgrpdes,
               ws.c24tltgrpstt
          from datktltgrp
         where datktltgrp.c24tltgrpnum = d_cts24m02.c24tltgrpnum

        if ws.c24tltgrpstt  <>  "A"   then
           error " Grupo de mensagem cancelado!"
           next field c24tltgrpnum
        end if

        if sqlca.sqlcode  <>  0   then
           error " Grupo de mensagens nao cadastrado, escolha um grupo cadastrado"
           #next field mdtmsggrpcod

           #CHAMAR POP-UP############################################
           let lr_popup.lin    = 6
           let lr_popup.col    = 2
           let lr_popup.titulo = "Grupos de mensagem"
           let lr_popup.tit2   = "Codigo"
           let lr_popup.tit3   = "Descricao"
           let lr_popup.tipcod = "A"
           let lr_popup.cmd_sql = " select c24tltgrpnum, c24tltgrpdes ",
                                  "   from datktltgrp ",
                                  "  where c24tltgrpstt = 'A' ",
                                  " order by c24tltgrpnum "
           let lr_popup.aux_sql = " "
           let lr_popup.tipo   = "D"

           call ofgrc001_popup(lr_popup.*)
                returning lr_retorno.*

           let d_cts24m02.c24tltgrpnum = lr_retorno.cpocod
           let d_cts24m02.c24tltgrpdes = lr_retorno.cpodes
           display by name d_cts24m02.c24tltgrpnum

           initialize lr_retorno.* to null
           ##########################################################

        end if

        display by name d_cts24m02.c24tltgrpdes

    #TIPO DE VEÍCULO
    before field socvcltip
        display by name d_cts24m02.socvcltip  attribute (reverse)

    after field socvcltip
        display by name d_cts24m02.socvcltip

        if fgl_lastkey() = fgl_keyval("up")      or
           fgl_lastkey() = fgl_keyval ("left")   then
           if d_cts24m02.socvcltip is null then
              next field c24tltgrpnum
           end if
        end if

        if d_cts24m02.socvcltip is null then
            let d_cts24m02.vcltipdes = null
            display by name d_cts24m02.vcltipdes
            next field socntzcod
        end if

        select cpodes
          into d_cts24m02.vcltipdes
          from iddkdominio
         where cponom = 'socvcltip'
           and cpocod = d_cts24m02.socvcltip

        if sqlca.sqlcode  <>  0   then
           error " Tipo de veículo nao cadastrado, escolha um tipo cadastrado"
           #next field socvcltip

           #CHAMAR POP-UP############################################
           let lr_popup.lin    = 6
           let lr_popup.col    = 2
           let lr_popup.titulo = "Tipo de veiculo"
           let lr_popup.tit2   = "Codigo"
           let lr_popup.tit3   = "Descricao"
           let lr_popup.tipcod = "A"
           let lr_popup.cmd_sql = " select cpocod, cpodes ",
                                  "   from iddkdominio ",
                                  "  where cponom = 'socvcltip' ",
                                  " order by cpocod "
           let lr_popup.aux_sql = " "
           let lr_popup.tipo   = "D"

           call ofgrc001_popup(lr_popup.*)
                returning lr_retorno.*

           let d_cts24m02.socvcltip = lr_retorno.cpocod
           let d_cts24m02.vcltipdes = lr_retorno.cpodes
           display by name d_cts24m02.socvcltip

           initialize lr_retorno.* to null
           ##########################################################

        end if

        display by name d_cts24m02.vcltipdes

    #NATUREZA
    before field socntzcod
        display by name d_cts24m02.socntzcod  attribute (reverse)

    after field socntzcod
        display by name d_cts24m02.socntzcod

        if fgl_lastkey() = fgl_keyval("up")      or
           fgl_lastkey() = fgl_keyval ("left")   then
           if d_cts24m02.socntzcod is null then
              next field socvcltip
           end if
        end if

        if d_cts24m02.socntzcod is null then
            let d_cts24m02.socntzdes = null
            display by name d_cts24m02.socntzdes
            next field asitipcod
        end if

        select socntzdes
          into d_cts24m02.socntzdes
          from datksocntz
         where socntzcod = d_cts24m02.socntzcod

        if sqlca.sqlcode  <>  0   then
           error " Natureza nao cadastrada, escolha uma natureza cadastrada"
           #next field socntzcod

           #CHAMAR POP-UP############################################
           let lr_popup.lin    = 6
           let lr_popup.col    = 2
           let lr_popup.titulo = "Naturezas QRA"
           let lr_popup.tit2   = "Codigo"
           let lr_popup.tit3   = "Descricao"
           let lr_popup.tipcod = "A"
           let lr_popup.cmd_sql = " select socntzcod, socntzdes ",
                                  "   from datksocntz ",
                                  " order by socntzcod "
           let lr_popup.aux_sql = " "
           let lr_popup.tipo   = "D"

           call ofgrc001_popup(lr_popup.*)
                returning lr_retorno.*

           let d_cts24m02.socntzcod = lr_retorno.cpocod
           let d_cts24m02.socntzdes = lr_retorno.cpodes
           display by name d_cts24m02.socntzcod

           initialize lr_retorno.* to null
           ##########################################################

        end if

        display by name d_cts24m02.socntzdes

    #ASSISTÊNCIA
    before field asitipcod
        display by name d_cts24m02.asitipcod  attribute (reverse)

    after field asitipcod
        display by name d_cts24m02.asitipcod

        if fgl_lastkey() = fgl_keyval("up")      or
           fgl_lastkey() = fgl_keyval ("left")   then
           if d_cts24m02.asitipcod is null then
              next field socntzcod
           end if
        end if

        if d_cts24m02.asitipcod is null then
            let d_cts24m02.asitipdes = null
            display by name d_cts24m02.asitipdes
            next field cidnom
        end if

        select asitipdes
          into d_cts24m02.asitipdes
          from datkasitip
         where asitipcod = d_cts24m02.asitipcod

        if sqlca.sqlcode  <>  0   then
           error " Assistência nao cadastrada, escolha uma assistencia cadastrada"
           #next field asitipcod

           #CHAMAR POP-UP############################################
           let lr_popup.lin    = 6
           let lr_popup.col    = 2
           let lr_popup.titulo = "Assistencias"
           let lr_popup.tit2   = "Codigo"
           let lr_popup.tit3   = "Descricao"
           let lr_popup.tipcod = "A"
           let lr_popup.cmd_sql = " select asitipcod, asitipdes ",
                                  "   from datkasitip ",
                                  " order by asitipcod "
           let lr_popup.aux_sql = " "
           let lr_popup.tipo   = "D"

           call ofgrc001_popup(lr_popup.*)
                returning lr_retorno.*

           let d_cts24m02.asitipcod = lr_retorno.cpocod
           let d_cts24m02.asitipdes = lr_retorno.cpodes
           display by name d_cts24m02.asitipcod

           initialize lr_retorno.* to null
           ##########################################################

        end if

        display by name d_cts24m02.asitipdes

    #CIDADE SEDE DO SINAL
    before field cidnom
        display by name d_cts24m02.cidnom  attribute (reverse)

    after field cidnom
        display by name d_cts24m02.cidnom

        if fgl_lastkey() = fgl_keyval("up")      or
           fgl_lastkey() = fgl_keyval ("left")   then
           if d_cts24m02.cidnom is null then
              next field asitipcod
           end if
        end if

        if d_cts24m02.cidnom is null then
            next field mdtcfgcod
        end if

        select cidnom, ufdcod
          into d_cts24m02.cidnom, d_cts24m02.ufdcod
          from datkmpacid
         where cidnom = d_cts24m02.cidnom

        if sqlca.sqlcode  <>  0   then
           error " Nenhuma cidade encontrada!"

           call cts06g04(d_cts24m02.cidnom, d_cts24m02.ufdcod)
                returning ws.cidcod, d_cts24m02.cidnom, d_cts24m02.ufdcod

        end if

        display by name d_cts24m02.cidnom
        display by name d_cts24m02.ufdcod

    #TIPO GPS
    before field mdtcfgcod
        display by name d_cts24m02.mdtcfgcod  attribute (reverse)

    after field mdtcfgcod
        display by name d_cts24m02.mdtcfgcod

        if fgl_lastkey() = fgl_keyval("up")      or
           fgl_lastkey() = fgl_keyval ("left")   then
           if d_cts24m02.mdtcfgcod is null then
              next field cidnom
           end if
        end if

        if d_cts24m02.mdtcfgcod is null then
            next field tltmsgcod
        end if

        select unique(mdtcfgcod)
          into d_cts24m02.mdtcfgcod
          from datkmdt
         where mdtcfgcod = d_cts24m02.mdtcfgcod

        if sqlca.sqlcode  <>  0   then
           error " Tipo GPS nao cadastrado!"

           call cty09g00_popup_iddkdominio("eqttipcod")
                returning ws.erro,
                          d_cts24m02.mdtcfgcod,
                          d_cts24m02.mdtcfgdes

        else

            select cpodes
              into d_cts24m02.mdtcfgdes
              from iddkdominio
             where cponom  =  'eqttipcod'
               and cpocod  =  d_cts24m02.mdtcfgcod

        end if

        display by name d_cts24m02.mdtcfgcod
        display by name d_cts24m02.mdtcfgdes

    #CÓDIGO DA MENSAGEM
    before field tltmsgcod
           error "PARA ENVIAR A MENSAGEM DIGITE ENTER ATE O FINAL"
           display by name d_cts24m02.tltmsgcod attribute (reverse)

    after field tltmsgcod
           display by name d_cts24m02.tltmsgcod

           if fgl_lastkey() = fgl_keyval("up")      or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_cts24m02.tltmsgcod is not null   then
                 next field mdtcfgcod
              end if
           end if

           if d_cts24m02.tltmsgcod is null then
              #if param.operacao = "p" then
                 #error " Informe o codigo da mensagem para a pesquisa!"
                 #next field tltmsgcod
              #end if
              initialize d_cts24m02.tltmsgtxt to null
           else
              select tltmsgtxt,  tltmsgstt
                into d_cts24m02.tltmsgtxt , d_cts24m02.tltmsgstt
                from datktltmsg
               where tltmsgcod = d_cts24m02.tltmsgcod

              if sqlca.sqlcode <> 0 then
                 call cts24m01() returning d_cts24m02.tltmsgcod
                 next field tltmsgcod
              else
                 if d_cts24m02.tltmsgstt <> "A" then
                    error "Mensagem Bloqueada/Cancelada!"
                    next field tltmsgcod
                 end if
              end if
            end if

            let d_cts24m02.tltmsgtxt1 =  d_cts24m02.tltmsgtxt[001,049]
            let d_cts24m02.tltmsgtxt2 =  d_cts24m02.tltmsgtxt[050,099]
            let d_cts24m02.tltmsgtxt3 =  d_cts24m02.tltmsgtxt[100,149]
            let d_cts24m02.tltmsgtxt4 =  d_cts24m02.tltmsgtxt[150,199]
            let d_cts24m02.tltmsgtxt5 =  d_cts24m02.tltmsgtxt[200,239]

            display by name d_cts24m02.tltmsgtxt1, d_cts24m02.tltmsgtxt2,
                            d_cts24m02.tltmsgtxt3, d_cts24m02.tltmsgtxt4,
                            d_cts24m02.tltmsgtxt5

            #next field mdtcfgcod

    before field tltmsgtxt1
           display by name d_cts24m02.tltmsgtxt1 attribute (reverse)

    after field tltmsgtxt1
           display by name d_cts24m02.tltmsgtxt1

           if fgl_lastkey() = fgl_keyval("up")   and
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt1
           end if

    before field tltmsgtxt2
           display by name d_cts24m02.tltmsgtxt2 attribute (reverse)

    after field tltmsgtxt2
           display by name d_cts24m02.tltmsgtxt2

           if fgl_lastkey() = fgl_keyval("up")   and
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt1
           end if

    before field tltmsgtxt3
           display by name d_cts24m02.tltmsgtxt3 attribute (reverse)

    after field tltmsgtxt3
           display by name d_cts24m02.tltmsgtxt3

           if fgl_lastkey() = fgl_keyval("up")   and
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt2
           end if

    before field tltmsgtxt4
           display by name d_cts24m02.tltmsgtxt4 attribute (reverse)

    after field tltmsgtxt4
           display by name d_cts24m02.tltmsgtxt4

           if fgl_lastkey() = fgl_keyval("up")   and
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt3
           end if

    before field tltmsgtxt5
           display by name d_cts24m02.tltmsgtxt5 attribute (reverse)

    after field tltmsgtxt5
           display by name d_cts24m02.tltmsgtxt5

           if fgl_lastkey() = fgl_keyval("up")   and
              fgl_lastkey() = fgl_keyval ("left")   then
              next field tltmsgtxt5
           end if

           if d_cts24m02.tltmsgtxt1 is null and
              d_cts24m02.tltmsgtxt2 is null and
              d_cts24m02.tltmsgtxt3 is null and
              d_cts24m02.tltmsgtxt4 is null and
              d_cts24m02.tltmsgtxt5 is null then
              error "Sera' necessario informar a mensagem para ser enviada!"
              next field tltmsgtxt1
           end if

           #VERIFICA SE ALGUM PARÂMETRO FOI INFORMADO
           if  d_cts24m02.atdvclsgl     is null and
               d_cts24m02.mdtcod        is null and
               d_cts24m02.pstcoddig     is null and
               d_cts24m02.mdtctrcod     is null and
               d_cts24m02.vcldtbgrpcod  is null and
               d_cts24m02.c24tltgrpnum  is null and
               d_cts24m02.socvcltip     is null and
               d_cts24m02.socntzdes     is null and
               d_cts24m02.asitipdes     is null and
               d_cts24m02.cidnom        is null and
               d_cts24m02.mdtcfgcod     is null and
               d_cts24m02.tltmsgcod     is null then
               error "Sera' necessario informar algum critério de pesquisa!"
               next field atdvclsgl
           end if
           let m_flg = true

           exit input

    on key (interrupt)

           error " Envio cancelado! "
           initialize d_cts24m02.*  to null
           clear form 
           let m_flg = false
           return d_cts24m02.*

 end input

 if int_flag  then
    initialize d_cts24m02.*  to null
 else
    let d_cts24m02.tltmsgtxt = d_cts24m02.tltmsgtxt1, d_cts24m02.tltmsgtxt2,
                               d_cts24m02.tltmsgtxt3, d_cts24m02.tltmsgtxt4,
                               d_cts24m02.tltmsgtxt5
 end if

 return d_cts24m02.*

 end function   # cts24m02_input

#------------------------------------------------------------
 function cts24m02_display(d_cts24m02)
#------------------------------------------------------------

 define d_cts24m02   record
        atdvclsgl    like  datkveiculo.atdvclsgl,
        vcldes       char(58),
        mdtcod       like  datkveiculo.mdtcod,
        pstcoddig    like  datkveiculo.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        mdtctrcod    like  datkmdt.mdtctrcod,
        mdtfqcdes    like  datkmdtctr.mdtfqcdes,
        vcldtbgrpcod like  dattfrotalocal.vcldtbgrpcod,
        vcldtbgrpdes like  datkvcldtbgrp.vcldtbgrpdes,
        c24tltgrpnum like  datktltgrp.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        socvcltip    like  datkveiculo.socvcltip,
        vcltipdes    char(35),
        socntzcod    like  datksocntz.socntzcod,
        socntzdes    like  datksocntz.socntzdes,
        asitipcod    like  datkasitip.asitipcod,
        asitipdes    like  datkasitip.asitipdes,
        ufdcod       like  datkmpacid.ufdcod,
        cidnom       like  datkmpacid.cidnom,
        vclcoddig    like  datkveiculo.vclcoddig,
        socoprsitcod like  datkveiculo.socoprsitcod,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtcfgcod    like  datkmdt.mdtcfgcod,
        mdtcfgdes    like datkmdtcfg.mdtcfgdes,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(50),
        informa      char(60)
 end record

 display by name d_cts24m02.atdvclsgl , d_cts24m02.mdtcod,
                 d_cts24m02.pstcoddig,  d_cts24m02.mdtctrcod,
                 d_cts24m02.vcldtbgrpcod, d_cts24m02.c24tltgrpnum,
                 d_cts24m02.socvcltip, d_cts24m02.socntzdes,
                 d_cts24m02.asitipdes, #Cidade sede
                 d_cts24m02.mdtcfgcod, d_cts24m02.tltmsgcod ,
                 d_cts24m02.tltmsgtxt1, d_cts24m02.tltmsgtxt2,
                 d_cts24m02.tltmsgtxt3, d_cts24m02.tltmsgtxt4,
                 d_cts24m02.tltmsgtxt5

 end function    # cts24m02_display

#------------------------------------------------------------
 function cts24m02_envia(d_cts24m02)
#------------------------------------------------------------

 define d_cts24m02   record
        atdvclsgl    like  datkveiculo.atdvclsgl,
        vcldes       char(58),
        mdtcod       like  datkveiculo.mdtcod,
        pstcoddig    like  datkveiculo.pstcoddig,
        nomrazsoc    like  dpaksocor.nomrazsoc,
        mdtctrcod    like  datkmdt.mdtctrcod,
        mdtfqcdes    like  datkmdtctr.mdtfqcdes,
        vcldtbgrpcod like  dattfrotalocal.vcldtbgrpcod,
        vcldtbgrpdes like  datkvcldtbgrp.vcldtbgrpdes,
        c24tltgrpnum like  datktltgrp.c24tltgrpnum,
        c24tltgrpdes like  datktltgrp.c24tltgrpdes,
        socvcltip    like  datkveiculo.socvcltip,
        vcltipdes    char(35),
        socntzcod    like  datksocntz.socntzcod,
        socntzdes    like  datksocntz.socntzdes,
        asitipcod    like  datkasitip.asitipcod,
        asitipdes    like  datkasitip.asitipdes,
        ufdcod       like  datkmpacid.ufdcod,
        cidnom       like  datkmpacid.cidnom,
        vclcoddig    like  datkveiculo.vclcoddig,
        socoprsitcod like  datkveiculo.socoprsitcod,
        prssitcod    like  dpaksocor.prssitcod,
        mdtctrstt    like  datkmdtctr.mdtctrstt,
        mdtcfgcod    like  datkmdt.mdtcfgcod,
        mdtcfgdes    like datkmdtcfg.mdtcfgdes,
        tltmsgcod    like  datmtlt.tltmsgcod,
        tltmsgtxt    like  datmtlt.tltmsgtxt,
        tltmsgstt    like  datktltmsg.tltmsgstt,
        tltmsgtxt1   char(50),
        tltmsgtxt2   char(50),
        tltmsgtxt3   char(50),
        tltmsgtxt4   char(50),
        tltmsgtxt5   char(50),
        informa      char(60)
 end record

 define ws           record
        errcod       smallint,
        msg_erro     char(200),
        sqlcod       integer,
        comando      char(500),
        comando2     char(500),
        sqlenvia     char(2000),
        mdtcod       like datkveiculo.mdtcod,
        socvclcod    like datkveiculo.socvclcod,
        srrcoddig    like dattfrotalocal.srrcoddig,
        atdvclsgl    like  datkveiculo.atdvclsgl,
        mdtmsgnum    like datmmdtmsg.mdtmsgnum,
        funmat       char(4),
        funnom       char(75),
        confirma     char (01),
        mens         char(100),
        criterios    char(2000),
        grp_msg      smallint,
        ntz          smallint,
        ast          smallint
 end record

 define l_contador_envio smallint

 #-------------------------------
 #PREPARE PARA VERIFICACAO
 #-------------------------------

 initialize  ws.*  to  null

 let ws.comando = " select funnom      ",
                  " from isskfunc      ",
                  " where funmat     = ? "
 prepare s_isskfunc from ws.comando
 declare c_isskfunc cursor for s_isskfunc

 #MATRÍCULA E NOME DO FUNCIONÁRIO
 let ws.funmat = g_issk.funmat
 let ws.funnom = null
 open  c_isskfunc using ws.funmat
    fetch c_isskfunc into ws.funnom
 close c_isskfunc

 #FILTROS
 if d_cts24m02.atdvclsgl is not null then
    let ws.comando2 = " and vcl.atdvclsgl    = '", d_cts24m02.atdvclsgl, "' "
    let ws.criterios = ws.criterios clipped, " Sigla = ", d_cts24m02.atdvclsgl, " - "
 end if

 if d_cts24m02.mdtcod is not null then
    let ws.comando2 = " and vcl.mdtcod       = ", d_cts24m02.mdtcod
    let ws.criterios = ws.criterios clipped, " Mdtcod = ", d_cts24m02.mdtcod, " "
 end if

 if d_cts24m02.pstcoddig is not null then
    let ws.comando2 = " and vcl.pstcoddig    = ", d_cts24m02.pstcoddig
    let ws.criterios = ws.criterios clipped, " Codigo do Prestador = ", d_cts24m02.pstcoddig, " - "
 end if

 if d_cts24m02.mdtctrcod is not null then
    let ws.comando2 = " and mdt.mdtctrcod    = ", d_cts24m02.mdtctrcod, ws.comando2 clipped
    let ws.criterios = ws.criterios clipped, " Codigo da Controladora = ", d_cts24m02.mdtctrcod, " - "
 end if

 if d_cts24m02.vcldtbgrpcod is not null then
    let ws.comando2 = " and frt.vcldtbgrpcod = ", d_cts24m02.vcldtbgrpcod, ws.comando2 clipped
    let ws.criterios = ws.criterios clipped, " Grupo de Distribuicao = ", d_cts24m02.vcldtbgrpcod, " - "
 end if

 let ws.grp_msg = false
 if d_cts24m02.c24tltgrpnum is not null then
    let ws.grp_msg = true;
    let ws.comando2 = " and grpmsg.c24tltgrpnum = ", d_cts24m02.c24tltgrpnum, ws.comando2 clipped
    let ws.criterios = ws.criterios clipped, " Grupo de Mensagem = ", d_cts24m02.c24tltgrpnum, " - "
 end if

 if d_cts24m02.socvcltip is not null then
    let ws.comando2 = " and vcl.socvcltip    = ", d_cts24m02.socvcltip, ws.comando2 clipped
    let ws.criterios = ws.criterios clipped, " Tipo de veiculo = ", d_cts24m02.socvcltip, " - "
 end if

 if d_cts24m02.cidnom is not null then
    let ws.comando2 = " and cidfil.ufdcod    = '", d_cts24m02.ufdcod,"'", ws.comando2 clipped
    let ws.comando2 = " and cidfil.cidnom    = '", d_cts24m02.cidnom,"'", ws.comando2 clipped
    let ws.criterios = ws.criterios clipped, " Nome da Cidade = ", d_cts24m02.cidnom, " ",
                                                                   d_cts24m02.ufdcod, " - "
 end if

 if d_cts24m02.mdtcfgcod is not null then
    let ws.comando2 = " and mdt.mdtcfgcod    = ", d_cts24m02.mdtcfgcod, ws.comando2 clipped
    let ws.criterios = ws.criterios clipped, " Tipo GPS = ", d_cts24m02.mdtcfgcod, " - "
 end if

 let ws.ntz = false
 if d_cts24m02.socntzcod is not null then
    let ws.ntz = true;
    let ws.comando2 = " and ntz.socntzcod = ", d_cts24m02.socntzcod, ws.comando2 clipped
    let ws.criterios = ws.criterios clipped, " Codigo da Natureza = ", d_cts24m02.socntzcod, " - "
 end if

 let ws.ast = false
 if d_cts24m02.asitipcod is not null then
    let ws.ast = true;
    let ws.comando2 = " and srrasi.asitipcod = ", d_cts24m02.asitipcod, ws.comando2 clipped
    let ws.criterios = ws.criterios clipped, " Tipo de Assistencia = ", d_cts24m02.asitipcod, " - "
 end if

 initialize ws.sqlenvia to null
 if ws.ntz = false and
    ws.ast = false and
    ws.grp_msg = false then
     let ws.sqlenvia = "  select vcl.mdtcod,             ",
                "         vcl.socvclcod,                 ",
                "         frt.srrcoddig,                 ",
                "         vcl.atdvclsgl                  ",
                "  from datkveiculo    vcl,              ",
                "       datkmdt        mdt,              ",
                "       dattfrotalocal frt,              ",
                "       datmfrtpos     pos,              ",
                "       datkmpacid     cidpos,           ",
                "       datkmpacid     cidfil,           ",
                "       datrcidsed     cidsed            ",
                " where mdt.mdtcod       = vcl.mdtcod    ",
                "   and frt.socvclcod    = vcl.socvclcod ",
                "   and pos.socvclcod    = vcl.socvclcod ",
                "   and pos.socvcllcltip = 1             ",
                "   and cidpos.cidnom    = pos.cidnom    ",
                "   and cidpos.ufdcod    = pos.ufdcod    ",
                "   and cidpos.mpacidcod = cidsed.cidcod ",
                "   and cidsed.cidsedcod = cidfil.mpacidcod ",
                    ws.comando2 clipped
 end if

 if ws.ntz = false and
    ws.ast = false and
    ws.grp_msg = true then
     let ws.sqlenvia = "  select vcl.mdtcod,             ",
                "         vcl.socvclcod,                 ",
                "         frt.srrcoddig,                 ",
                "         vcl.atdvclsgl                  ",
                "  from datkveiculo    vcl,              ",
                "       datkmdt        mdt,              ",
                "       dattfrotalocal frt,              ",
                "       datmfrtpos     pos,              ",
                "       datkmpacid     cidpos,           ",
                "       datkmpacid     cidfil,           ",
                "       datrcidsed     cidsed,           ",
                "       datktltgrp     grpmsg,           ",
                "       datktltgrpitm  grpitm            ",
                " where mdt.mdtcod       = vcl.mdtcod    ",
                "   and frt.socvclcod    = vcl.socvclcod ",
                "   and pos.socvclcod    = vcl.socvclcod ",
                "   and pos.socvcllcltip = 1             ",
                "   and cidpos.cidnom    = pos.cidnom    ",
                "   and cidpos.ufdcod    = pos.ufdcod    ",
                "   and cidpos.mpacidcod = cidsed.cidcod ",
                "   and cidsed.cidsedcod = cidfil.mpacidcod ",
                "   and grpmsg.c24tltgrpnum = grpitm.c24tltgrpnum ",
                "   and grpitm.atdvclsgl    = vcl.atdvclsgl ",
                    ws.comando2 clipped
 end if

 if ws.ntz = true and
    ws.ast = false and
    ws.grp_msg = false then

    let ws.sqlenvia = "  select distinct vcl.mdtcod,     ",
                "         vcl.socvclcod,                 ",
                "         frt.srrcoddig,                 ",
                "         vcl.atdvclsgl                  ",
                "  from datkveiculo    vcl,              ",
                "       datkmdt        mdt,              ",
                "       dattfrotalocal frt,              ",
                "       datmfrtpos     pos,              ",
                "       datkmpacid     cidpos,           ",
                "       datkmpacid     cidfil,           ",
                "       datrcidsed     cidsed,           ",
                "       dbsrntzpstesp  ntz               ",
                #"       datrsrrasi srrasi,               ",
                #"       datrvclasi vclasi                ",
                " where mdt.mdtcod       = vcl.mdtcod    ",
                "   and frt.socvclcod    = vcl.socvclcod ",
                "   and pos.socvclcod    = vcl.socvclcod ",
                "   and pos.socvcllcltip = 1             ",
                "   and cidpos.cidnom    = pos.cidnom    ",
                "   and cidpos.ufdcod    = pos.ufdcod    ",
                "   and cidpos.mpacidcod = cidsed.cidcod ",
                "   and cidsed.cidsedcod = cidfil.mpacidcod ",
                "   and ntz.srrcoddig = frt.srrcoddig ",
                #"   and vclasi.socvclcod = vcl.socvclcod ",
                #"   and vclasi.asitipcod = srrasi.asitipcod ",
                    ws.comando2 clipped
 end if

 if ws.ntz = false and
    ws.ast = true and
    ws.grp_msg = false then
    let ws.sqlenvia = "  select vcl.mdtcod,              ",
                "         vcl.socvclcod,                 ",
                "         frt.srrcoddig,                 ",
                "         vcl.atdvclsgl                  ",
                "  from datkveiculo    vcl,              ",
                "       datkmdt        mdt,              ",
                "       dattfrotalocal frt,              ",
                "       datmfrtpos     pos,              ",
                "       datkmpacid     cidpos,           ",
                "       datkmpacid     cidfil,           ",
                "       datrcidsed     cidsed,           ",
                "       datrsrrasi srrasi,               ",
                "       datrvclasi vclasi                ",
                " where mdt.mdtcod       = vcl.mdtcod    ",
                "   and frt.socvclcod    = vcl.socvclcod ",
                "   and pos.socvclcod    = vcl.socvclcod ",
                "   and pos.socvcllcltip = 1             ",
                "   and cidpos.cidnom    = pos.cidnom    ",
                "   and cidpos.ufdcod    = pos.ufdcod    ",
                "   and cidpos.mpacidcod = cidsed.cidcod ",
                "   and cidsed.cidsedcod = cidfil.mpacidcod ",
                "   and srrasi.srrcoddig = frt.srrcoddig ",
                "   and vclasi.socvclcod = vcl.socvclcod ",
                "   and vclasi.asitipcod = srrasi.asitipcod ",
                    ws.comando2 clipped
 end if

 if ws.ntz = false and
    ws.ast = true and
    ws.grp_msg = true then
    let ws.sqlenvia = "  select vcl.mdtcod,              ",
                "         vcl.socvclcod,                 ",
                "         frt.srrcoddig,                 ",
                "         vcl.atdvclsgl                  ",
                "  from datkveiculo    vcl,              ",
                "       datkmdt        mdt,              ",
                "       dattfrotalocal frt,              ",
                "       datmfrtpos     pos,              ",
                "       datkmpacid     cidpos,           ",
                "       datkmpacid     cidfil,           ",
                "       datrcidsed     cidsed,           ",
                "       datrsrrasi srrasi,               ",
                "       datrvclasi vclasi,               ",
                "       datktltgrp     grpmsg,           ",
                "       datktltgrpitm  grpitm            ",
                " where mdt.mdtcod       = vcl.mdtcod    ",
                "   and frt.socvclcod    = vcl.socvclcod ",
                "   and pos.socvclcod    = vcl.socvclcod ",
                "   and pos.socvcllcltip = 1             ",
                "   and cidpos.cidnom    = pos.cidnom    ",
                "   and cidpos.ufdcod    = pos.ufdcod    ",
                "   and cidpos.mpacidcod = cidsed.cidcod ",
                "   and cidsed.cidsedcod = cidfil.mpacidcod ",
                "   and srrasi.srrcoddig = frt.srrcoddig ",
                "   and vclasi.socvclcod = vcl.socvclcod ",
                "   and vclasi.asitipcod = srrasi.asitipcod ",
                "   and grpmsg.c24tltgrpnum = grpitm.c24tltgrpnum ",
                "   and grpitm.atdvclsgl    = vcl.atdvclsgl ",
                    ws.comando2 clipped
 end if

 if ws.ntz = true and
    ws.ast = true and
    ws.grp_msg = true then
    let ws.sqlenvia = "  select distinct vcl.mdtcod,     ",
                "         vcl.socvclcod,                 ",
                "         frt.srrcoddig,                 ",
                "         vcl.atdvclsgl                  ",
                "  from datkveiculo    vcl,              ",
                "       datkmdt        mdt,              ",
                "       dattfrotalocal frt,              ",
                "       datmfrtpos     pos,              ",
                "       datkmpacid     cidpos,           ",
                "       datkmpacid     cidfil,           ",
                "       datrcidsed     cidsed,           ",
                "       dbsrntzpstesp ntz,               ",
                "       datrsrrasi srrasi,               ",
                "       datrvclasi vclasi,               ",
                "       datktltgrp     grpmsg,           ",
                "       datktltgrpitm  grpitm            ",
                " where mdt.mdtcod       = vcl.mdtcod    ",
                "   and frt.socvclcod    = vcl.socvclcod ",
                "   and pos.socvclcod    = vcl.socvclcod ",
                "   and pos.socvcllcltip = 1             ",
                "   and cidpos.cidnom    = pos.cidnom    ",
                "   and cidpos.ufdcod    = pos.ufdcod    ",
                "   and cidpos.mpacidcod = cidsed.cidcod ",
                "   and cidsed.cidsedcod = cidfil.mpacidcod ",
                "   and ntz.srrcoddig = frt.srrcoddig    ",
                "   and srrasi.srrcoddig = frt.srrcoddig ",
                "   and vclasi.socvclcod = vcl.socvclcod ",
                "   and vclasi.asitipcod = srrasi.asitipcod ",
                "   and grpmsg.c24tltgrpnum = grpitm.c24tltgrpnum ",
                "   and grpitm.atdvclsgl    = vcl.atdvclsgl ",
                    ws.comando2 clipped
 end if

 if ws.ntz = true and
    ws.ast = false and
    ws.grp_msg = true then
    let ws.sqlenvia = "  select distinct vcl.mdtcod,     ",
                "         vcl.socvclcod,                 ",
                "         frt.srrcoddig,                 ",
                "         vcl.atdvclsgl                  ",
                "  from datkveiculo    vcl,              ",
                "       datkmdt        mdt,              ",
                "       dattfrotalocal frt,              ",
                "       datmfrtpos     pos,              ",
                "       datkmpacid     cidpos,           ",
                "       datkmpacid     cidfil,           ",
                "       datrcidsed     cidsed,           ",
                "       dbsrntzpstesp ntz,               ",
                "       datktltgrp     grpmsg,           ",
                "       datktltgrpitm  grpitm            ",
                " where mdt.mdtcod       = vcl.mdtcod    ",
                "   and frt.socvclcod    = vcl.socvclcod ",
                "   and pos.socvclcod    = vcl.socvclcod ",
                "   and pos.socvcllcltip = 1             ",
                "   and cidpos.cidnom    = pos.cidnom    ",
                "   and cidpos.ufdcod    = pos.ufdcod    ",
                "   and cidpos.mpacidcod = cidsed.cidcod ",
                "   and cidsed.cidsedcod = cidfil.mpacidcod ",
                "   and ntz.srrcoddig = frt.srrcoddig    ",
                "   and grpmsg.c24tltgrpnum = grpitm.c24tltgrpnum ",
                "   and grpitm.atdvclsgl    = vcl.atdvclsgl ",
                    ws.comando2 clipped
 end if

 if ws.ntz = true and
    ws.ast = true and
    ws.grp_msg = false then
    let ws.sqlenvia = "  select distinct vcl.mdtcod,     ",
                "         vcl.socvclcod,                 ",
                "         frt.srrcoddig,                 ",
                "         vcl.atdvclsgl                  ",
                "  from datkveiculo    vcl,              ",
                "       datkmdt        mdt,              ",
                "       dattfrotalocal frt,              ",
                "       datmfrtpos     pos,              ",
                "       datkmpacid     cidpos,           ",
                "       datkmpacid     cidfil,           ",
                "       datrcidsed     cidsed,           ",
                "       dbsrntzpstesp ntz,               ",
                "       datrsrrasi srrasi,               ",
                "       datrvclasi vclasi                ",
                " where mdt.mdtcod       = vcl.mdtcod    ",
                "   and frt.socvclcod    = vcl.socvclcod ",
                "   and pos.socvclcod    = vcl.socvclcod ",
                "   and pos.socvcllcltip = 1             ",
                "   and cidpos.cidnom    = pos.cidnom    ",
                "   and cidpos.ufdcod    = pos.ufdcod    ",
                "   and cidpos.mpacidcod = cidsed.cidcod ",
                "   and cidsed.cidsedcod = cidfil.mpacidcod ",
                "   and ntz.srrcoddig = frt.srrcoddig    ",
                "   and srrasi.srrcoddig = frt.srrcoddig ",
                "   and vclasi.socvclcod = vcl.socvclcod ",
                "   and vclasi.asitipcod = srrasi.asitipcod ",
                    ws.comando2 clipped
 end if

 #######RETIRAR-TESTE#############################
 #display "ws.sqlenvia completo >>>> ", ws.sqlenvia
 #######RETIRAR-TESTE#############################

 prepare pcts24m02001 from ws.sqlenvia
 declare ccts24m02001  cursor with hold for pcts24m02001

 #INICIALIZAÇÃO DE VARIÁVEIS
 let m_contador = 0
 initialize m_sigla to null

 foreach ccts24m02001 into ws.mdtcod, ws.socvclcod,
                           ws.srrcoddig, ws.atdvclsgl

     let m_contador = m_contador + 1
     let m_sigla[m_contador].siglas = ws.atdvclsgl
     let m_mdtcod[m_contador].mdtcod = ws.mdtcod

 end foreach

 close ccts24m02001

 if m_contador <> 0 then
    let ws.mens = m_contador using "<<<&" , " viatura(s) "
    call cts24m03("C","F","","Essa mensagem será transmitida para ", ws.mens, "")
        returning ws.confirma
 else
    error "Nenhuma viatura atende o(s) filtro(s) informado(s)! "
 end if

 if ws.confirma = 'S' then
     error " Aguarde ...  enviando mensagem!"

     #LOOP PARA MANDAR MSGS
     let l_contador_envio = 0;
     while l_contador_envio <= m_contador

        #ENVIO MSG
        let l_contador_envio = l_contador_envio + 1
        call ctx01g07_envia_msg_id("","",m_mdtcod[l_contador_envio].mdtcod,
                                      d_cts24m02.tltmsgtxt)
             returning ws.errcod, ws.mdtmsgnum

        if ws.errcod <> 0 then
            let ws.msg_erro = "Erro ao gravar mensagem para envio MID ", ws.mdtmsgnum
            call errorlog(ws.msg_erro)
        end if

        let m_id_msg[l_contador_envio].mdtmsgnum = ws.mdtmsgnum

     end while

     #RETIRAR - TESTE
     #display "l_contador_envio >>>>> ", l_contador_envio
     #display "m_contador >>>>> ", m_contador

     #Enviar email para destinatários com informações: Data e hora da transmissão,
     #usuário que transmitiu, critérios informados (filtro)
     #e as viaturas que atenderam ao filtro
     #(com o ID da mensagem da controladora ao lado da sigla, para eventual confirmação).

     call cts24m02_envia_email_html("CTS24M02", ws.funmat, ws.funnom,
                                                d_cts24m02.tltmsgtxt, ws.criterios)
     error ""

 end if

 message ""

end function   # cts24m02_envia

#-----------------------------------------------------------------------------
 function cts24m03(param)
#-----------------------------------------------------------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    conflg           char (01),  ###  Flag Confirmacao
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40)
 end record

 define d_cts24m03   record
    cabtxt           char (40),
    confirma         char (01)
 end record

 define ws           record
    confirma         char (01),
    cont_array       smallint
 end record

 initialize  d_cts24m03.*  to  null

 initialize  ws.*  to  null

 open window w_cts24m03 at 9,19 with form "cts24m03"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_cts24m03.cabtxt = "CONFIRME"
    when "I"  let  d_cts24m03.cabtxt = "INFORME AO SEGURADO"
    when "Q"  let  d_cts24m03.cabtxt = "QUESTIONE O SEGURADO"
    when "T"  let  d_cts24m03.cabtxt = "INFORME O TERCEIRO"
    when "A"  let  d_cts24m03.cabtxt = "A T E N C A O"
    when "U"  let  d_cts24m03.cabtxt = "QUESTIONE O TERCEIRO"
 end case

 let d_cts24m03.cabtxt = cts24m03_center(d_cts24m03.cabtxt)

 let param.linha1 = cts24m03_center(param.linha1)
 let param.linha2 = cts24m03_center(param.linha2)
 let param.linha3 = cts24m03_center(param.linha3)
 let param.linha4 = cts24m03_center(param.linha4)

 display by name d_cts24m03.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha4

 #NUMERO DE ARRAY
 call set_count(m_contador)
 #input array m_sigla without defaults from s_cts24m03.*
 display array m_sigla to s_cts24m03.*

 let ws.confirma = "N"

 if param.conflg = "S"  then
    open window m_cts24m03 at 18,32 with 02 rows, 20 columns

    if g_documento.atdsrvorg = 9 then
       menu ""
          command key ("S")            "SIM"
             let ws.confirma = "S"
             exit menu

          command key ("N", interrupt) "NAO"
             error " Confirmacao cancelada!"
             exit menu
       end menu
    else
       menu ""
          command key ("N", interrupt) "NAO"
             error " Confirmacao cancelada!"
             exit menu

          command key ("S")            "SIM"
             let ws.confirma = "S"
             exit menu
       end menu
    end if
    close window m_cts24m03
 else
   if param.conflg = 'N' or
      param.conflg is null then
      message " (F17)Abandona"
      input by name d_cts24m03.confirma without defaults
         after field confirma
            next field confirma

         on key (interrupt, control-c)
            exit input
      end input
   else
      if param.conflg = 'F' then
         while true
            prompt 'CONFIRMA S/N? ' for char ws.confirma

            let ws.confirma = upshift(ws.confirma)
            if ws.confirma = 'S' or ws.confirma = 'N' then
               exit while
            end if

         end while
      else
         if  param.conflg = 'I' then
            open window m_cts24m03 at 18,32 with 02 rows, 20 columns
            menu ""
               command key ("N", interrupt) "NAO"
                  error " Confirmacao cancelada!"
                  let ws.confirma = "N"
                  exit menu

               command key ("S")            "SIM"
                  let ws.confirma = "S"
                  exit menu
            end menu
            close window m_cts24m03
         end if
      end if
   end if
 end if

 let int_flag = false
 close window w_cts24m03

 return ws.confirma

end function  ###  cts24m03

#-----------------------------------------------------------------------------
 function cts24m03_center(param)
#-----------------------------------------------------------------------------

 define param        record
    lintxt           char (40)
 end record

 define i            smallint
 define tamanho      dec (2,0)


        let     i  =  null
        let     tamanho  =  null

 let tamanho = (40 - length(param.lintxt))/2

 for i = 1 to tamanho
    let param.lintxt = " ", param.lintxt clipped
 end for

 return param.lintxt

end function  ###  cts24m03_center

function cts24m02_envia_email_html(lr_informacoes)

    define lr_informacoes record
        modulo       like igbmparam.relsgl,
        funmat       char(4),
        funnom       char(75),
        mensagem     like  datmtlt.tltmsgtxt,
        criterios    char(2000)
    end record

    define l_cod_erro integer,
           l_msg_erro char(20),
           l_siglas char(25000),
           l_sql    char(250),
           l_email  like igbmparam.relpamtxt

    define l_contador_email smallint,
           l_data date,
           l_hora datetime hour to second

    define lr_mail record
        rem char(50),
        des char(800),
        ccp char(250),
        cco char(250),
        ass char(150),
        msg char(32000),
        idr char(20),
        tip char(4)
    end record

    initialize lr_mail to null
    let l_msg_erro = null
    let l_contador_email = 0
    let l_siglas = null
    let l_sql = null

    let l_sql = "select relpamtxt ",
                "  from igbmparam ",
                " where relsgl = ? "

    prepare pcts24m02003 from l_sql
    declare ccts24m02003  cursor with hold for pcts24m02003

    open ccts24m02003 using lr_informacoes.modulo

        foreach ccts24m02003 into l_email

        if lr_mail.des is null then
            let lr_mail.des = l_email
        else
            let lr_mail.des = lr_mail.des clipped,',',l_email
        end if

    end foreach

    close ccts24m02003

    let l_contador_email = 1;
    while l_contador_email <= m_contador

        let l_siglas = l_siglas clipped, "Cod msg: ", m_id_msg[l_contador_email].mdtmsgnum clipped,
                       " - Sigla: ", m_sigla[l_contador_email].siglas clipped clipped, "<br>"
        let l_contador_email = l_contador_email + 1

    end while

    let l_data = current
    let l_hora = current

    let lr_mail.msg = "<html><body><font face='Arial' size=2>               ",
                      #" Informacoes envio de mensagens MID         <br>",
                      " ==================================        <br>",
                      " Data e hora do envio: ", l_data using "dd/mm/yyyy", " ", l_hora, "<br>",
                      " ==================================        <br>",
                      " Funcionario responsavel pelo envio: ",
                        lr_informacoes.funmat clipped, " - ",
                        lr_informacoes.funnom    clipped ,       "<br>",
                      #" Nome: ",lr_informacoes.funnom    clipped      , "<br>",
                      " ==================================        <br>",
                      " Criterios do envio:                       <br>",
                      "<br>", lr_informacoes.criterios clipped,  "<br>",
                      " ==================================        <br>",
                      " Viaturas que receberam a mensagem:        <br>",
                      "<br> ", l_siglas clipped     ,            "<br>",
                      " ==================================        <br>",
                      " Texto da mensagem:                        <br>",
                      "<br> ", lr_informacoes.mensagem clipped,  "<br>",
                      "</body></html>"


    let lr_mail.rem = "porto.socorro@portoseguro.com.br"
    #let lr_mail.des = "kevellin.olivatti@correioporto"
    let lr_mail.ccp = ""
    let lr_mail.cco = ""
    let lr_mail.ass = "Envio de mensagens MID"
    let lr_mail.idr = "F0104191"
    let lr_mail.tip = "html"

    #RETIRAR - TESTE
    #display "lr_mail.msg >>>>> ", lr_mail.msg clipped

    call figrc009_mail_send1(lr_mail.*)
         returning l_cod_erro, l_msg_erro

    if  l_cod_erro <> 0 then
        display "Erro no envio do email: ",
                l_cod_erro using "<<<<<<&", " - ",
                l_msg_erro clipped
    end if

end function

