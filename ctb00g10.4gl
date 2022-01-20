#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Porto Socorro                                               #
# Modulo         : ctb00g10                                                    #
#                  Identificar servico original pago em casos de acionamento   #
#                  de retorno. Bloqueio e geracao de alerta para retornos      #
#                  concluidos por prestador diferente do servico original      #
# Analista Resp. : Cristiane Silva                                             #
# PSI            : 201022 (Express)                                            #
#..............................................................................#
# Desenvolvimento: Porto                                                       #
# Data           : 05/06/2006                                                  #
#..............................................................................#
#                                                                              #
#                          * * *  ALTERACOES  * * *                            #
#                                                                              #
# Data       Analista Resp/Autor Fabrica  PSI/Alteracao                        #
# ---------- ---------------------------- -------------------------------------#
# 03/07/2007 Burini              Isabel   Buscar o ultimo prestador da ultima  #
#                                         sequencia de retorno, ao inves de    #
#                                         buscar o prestador da origem         #
#------------------------------------------------------------------------------#
database porto

define m_flgprep smallint

#=> PREPARA COMANDOS SQL DO MODULO
#------------------------#
 function ctb00g10_prep()
#------------------------#
   define l_sql char(1500)

   if  m_flgprep then
       return true
   end if

   let l_sql = " select atdorgsrvnum, atdorgsrvano ",
                 " from datmsrvre ",
                " where atdsrvnum = ? ",
                  " and atdsrvano = ? "
   prepare p_ctb00g10_001 from l_sql
   declare c_ctb00g10_001 cursor for p_ctb00g10_001

   let l_sql = " select count(atdsrvnum)",
                 " from datmsrvanlhst",
                " where atdsrvnum = ?",
                  " and atdsrvano = ?",
                  " and c24evtcod = 37"
   prepare p_ctb00g10_002 from l_sql
   declare c_ctb00g10_002 cursor for p_ctb00g10_002

   {let l_sql = " select itm.atdsrvnum, itm.atdsrvano, itm.socopgnum ",
                 " from dbsmopgitm itm, dbsmopg opg ",
                " where itm.socopgnum = opg.socopgnum ",
                  " and itm.atdsrvnum = ? ",
                  " and itm.atdsrvano = ? ",
                  " and opg.socopgsitcod <> 8 "}
   let l_sql = " select count(itm.atdsrvnum)",
                 " from dbsmopgitm itm,",
                      " dbsmopg opg",
                " where itm.socopgnum = opg.socopgnum",
                  " and itm.atdsrvnum = ?",
                  " and itm.atdsrvano = ?",
                  " and opg.socopgsitcod <> 8"
   prepare p_ctb00g10_003 from l_sql
   declare c_ctb00g10_003 cursor for p_ctb00g10_003

   {let l_sql = " select prslocflg from datmservico ",
                " where atdsrvnum = ? ",
                  " and atdsrvano = ? "
   prepare p_ctb00g10_003 from l_sql
   declare c_ctb00g10_003 cursor for p_ctb00g10_003

   let l_sql = " select socor.qldgracod ",
                 " from dpaksocor socor, datmservico serv ",
                " where socor.pstcoddig = serv.atdprscod ",
                  " and serv.atdsrvnum = ? ",
                  " and serv.atdsrvano = ? "
   prepare p_ctb00g10_005 from l_sql
   declare c_ctb00g10_005 cursor for pctb00g10004}

   #Seleciona o ultimo registro de servico
   #relacionado ao servico original
   let l_sql =
        "select acp.atdsrvnum,",
              " acp.atdsrvano,",
              " acp.pstcoddig,",
              " acp.srrcoddig,",
              " acp.socvclcod",
         " from datmsrvre re, datmsrvacp acp",
        " where re.atdorgsrvnum = ?",
          " and re.atdorgsrvano = ?",
          " and acp.atdsrvnum = re.atdsrvnum",
          " and acp.atdsrvano = re.atdsrvano",
          " and acp.atdetpcod in (3,10)",
          " and atdsrvseq = (select max(atdsrvseq)",
                             " from datmsrvacp acpmax",
                            " where acpmax.atdsrvnum = acp.atdsrvnum",
                              " and acpmax.atdsrvano = acp.atdsrvano)",
        " order by acp.atdsrvano desc, acp.atdsrvnum desc"
   prepare p_ctb00g10_006 from l_sql
   declare c_ctb00g10_006 cursor for p_ctb00g10_006

   #No caso de nao encontrar servico anterior
   #busca o servico original
   let l_sql =
        "select acp.atdsrvnum,",
              " acp.atdsrvano,",
              " acp.pstcoddig,",
              " acp.srrcoddig,",
              " acp.socvclcod",
         " from datmsrvacp acp",
        " where acp.atdsrvnum = ?",
          " and acp.atdsrvano = ?",
          " and acp.atdetpcod in (3,10)",
          " and atdsrvseq = (select max(atdsrvseq)",
                             " from datmsrvacp acpmax",
                            " where acpmax.atdsrvnum = acp.atdsrvnum",
                              " and acpmax.atdsrvano = acp.atdsrvano)"
   prepare p_ctb00g10_007 from l_sql
   declare c_ctb00g10_007 cursor for p_ctb00g10_007

   #Seleciona os dados do servico
   #(prestador, socorrista e veiculo)
   let l_sql =
        "select pstcoddig,",
              " srrcoddig,",
              " socvclcod",
         " from datmsrvacp acp",
        " where acp.atdsrvnum = ?",
          " and acp.atdsrvano = ?",
          " and acp.atdetpcod in (3,10)",
          " and acp.atdsrvseq = (select max(atdsrvseq)",
                                 " from datmsrvacp acpmax",
                                " where acpmax.atdsrvnum = acp.atdsrvnum",
                                  " and acpmax.atdsrvano = acp.atdsrvano)"
   prepare pctb00g10007 from l_sql
   declare cctb00g10007 cursor for pctb00g10007

   #Seleciona servicos anteriores ao servico atual
   #No caso de nao encontrar servico anterior
   #busca o servico original
   let l_sql =
        "select acp.atdsrvnum,",
              " acp.atdsrvano,",
              " acp.pstcoddig,",
              " acp.srrcoddig,",
              " acp.socvclcod",
         " from datmsrvre re, datmsrvacp acp",
        " where ((re.atdsrvnum = ?",
          " and re.atdsrvano = ?)",
          " or (re.atdorgsrvnum = ?",
          " and re.atdorgsrvano = ?",
          " and (acp.atdsrvnum <> ?",
          " or acp.atdsrvano <> ?)))",
          " and acp.atdsrvnum = re.atdsrvnum",
          " and acp.atdsrvano = re.atdsrvano",
          " and acp.atdetpcod in (3,10)",
          " and atdsrvseq = (select max(atdsrvseq)",
                             " from datmsrvacp acpmax",
                            " where acpmax.atdsrvnum = acp.atdsrvnum",
                              " and acpmax.atdsrvano = acp.atdsrvano)",
        " order by acp.atdsrvano desc, acp.atdsrvnum desc"
   prepare pctb00g10008 from l_sql
   declare cctb00g10008 cursor with hold for pctb00g10008

 end function

#--------------------------------------#
 function ctb00g10_verif_serv(lr_param)
#--------------------------------------#
    define lr_param record
        atdorgsrvnum like datmsrvre.atdorgsrvnum,
        atdorgsrvano like datmsrvre.atdorgsrvano,
        atdsrvnum    like datmsrvacp.atdsrvnum,
        atdsrvano    like datmsrvacp.atdsrvano
    end record

    define lr_dados record
        atdantsrvnum like datmsrvre.atdsrvnum,
        atdantsrvano like datmsrvre.atdsrvano,
        atdsrvnum    like datmsrvre.atdsrvnum,
        atdsrvano    like datmsrvre.atdsrvano,
        pstantcoddig like datmsrvacp.pstcoddig,
        srrantcoddig like datmsrvacp.srrcoddig,
        socantvclcod like datmsrvacp.socvclcod,
        socantopgnum like dbsmopgitm.socopgnum,
        atdantetpdat like datmsrvacp.atdetpdat,
        pstcoddig    like datmsrvacp.pstcoddig,
        srrcoddig    like datmsrvacp.srrcoddig,
        socvclcod    like datmsrvacp.socvclcod,
        socopgnum    like dbsmopgitm.socopgnum,
        atdetpdat    like datmsrvacp.atdetpdat,
        mensagem     char(300)
    end record

    define l_retorno smallint

    call ctb00g10_prep()

    #Busca dados do servico atual
    open cctb00g10007 using lr_param.atdsrvnum, lr_param.atdsrvano
    whenever error continue
    fetch cctb00g10007 into lr_dados.pstcoddig,
                            lr_dados.srrcoddig,
                            lr_dados.socvclcod,
                            lr_dados.atdetpdat
    whenever error stop
    if  sqlca.sqlcode <> 0 then
        if  sqlca.sqlcode = notfound then
            let lr_dados.atdsrvnum = null
            let lr_dados.atdsrvano = null
            let lr_dados.socopgnum = null
            let lr_dados.atdetpdat = null
        else
            error "Erro SELECT cctb00g10007 | ", sqlca.sqlcode, " | ", sqlca.sqlerrd[2] sleep 2
        end if
    end if
    close cctb00g10007

    #Verifica servicos anteriores e bloqueia o pagamento,
    #garantindo que o mesmo nao sera pago. Caso o servico
    #esteja pago envia e-mail e inclui bloqueio.
    open cctb00g10008 using lr_param.atdorgsrvnum, lr_param.atdorgsrvano,
                            lr_param.atdorgsrvnum, lr_param.atdorgsrvano,
                            lr_param.atdsrvnum,    lr_param.atdsrvano
    foreach cctb00g10008 into lr_dados.atdantsrvnum, lr_dados.atdantsrvano,
                              lr_dados.pstantcoddig, lr_dados.srrantcoddig,
                              lr_dados.socantvclcod, lr_dados.atdantetpdat

        #Verifica se o prestador do servico atual eh igual ao
        #prestador do servico anterior e se o servico esta fora
        #da garantia. Caso a condicao seja satisfeita, bloqueia
        #o pagamento do servico atual.
        if  lr_dados.pstcoddig = lr_dados.pstantcoddig and
            lr_dados.atdetpdat is not null and
            lr_dados.atdetpdat - lr_dados.atdantetpdat > 90 then

            #Se o servico atual nao estiver bloqueado, o mesmo sera bloqueado
            if  ctb00g10_verif_bloq(lr_dados.atdsrvnum,
                                    lr_dados.atdsrvano) = false then
                call ctb00g01_anlsrv( 37,
                                      "",
                                      lr_dados.atdsrvnum,
                                      lr_dados.atdsrvano,
                                      999999 )
            end if
        else
            #Verifica se servico esta bloqueado, so
            #prossegue se o mesmo nao estiver bloqueado
            if  ctb00g10_verif_bloq(lr_dados.atdantsrvnum,
                                    lr_dados.atdantsrvano) = false then

                #Bloqueia o servico caso o mesmo nao esteja bloqueado
                call ctb00g01_anlsrv( 37,
                                      "",
                                      lr_dados.atdantsrvnum,
                                      lr_dados.atdantsrvano,
                                      999999 )

                #Verifica se o prestador do servico atual eh diferente do
                #prestador do servico anterior e se o servico anterior esta
                #pago, caso as duas condicoes sejam satisfeitas, envia-se
                #e-mail informando do pagamento indevido ao prestador
                if  lr_dados.pstantcoddig <> lr_dados.pstcoddig and
                    ctb00g10_verif_pagto(lr_dados.atdantsrvnum,
                                         lr_dados.atdantsrvano) then
                    let lr_dados.mensagem = " O atendimento do servico ", lr_dados.atdantsrvnum,
                                            " foi concluido por um prestador diferente. Verifique " clipped,
                                            " pagamento para regularizacao da OP ", lr_dados.socantopgnum
                    call ctx22g00_envia_email("CTB00G10", lr_dados.mensagem, "")
                        returning l_retorno
                end if
            end if
        end if

        #Iguala os valores para que o servico anterior se torne o
        #servico atual e busque-se o proximo servico sem perder os
        #dados do servico "anterior" (agora atual)
        let lr_dados.atdsrvnum = lr_dados.atdantsrvnum
        let lr_dados.atdsrvano = lr_dados.atdantsrvano
        let lr_dados.pstcoddig = lr_dados.pstantcoddig
        let lr_dados.srrcoddig = lr_dados.srrantcoddig
        let lr_dados.socvclcod = lr_dados.socantvclcod

    end foreach

 end function

#-----------------------------------------#
 function ctb00g10_verif_bloq(l_atdsrvnum,
                              l_atdsrvano)
#-----------------------------------------#
    define l_atdsrvnum like datmsrvacp.atdsrvnum,
           l_atdsrvano like datmsrvacp.atdsrvano,
           l_count     smallint

    let l_count = 0
    open c_ctb00g10_002 using l_atdsrvnum, l_atdsrvano
    whenever error continue
    fetch c_ctb00g10_002 into l_count
    whenever error stop
    if  sqlca.sqlcode <> 0 then
        if  sqlca.sqlcode = notfound then
            let l_count = 0
        else
            error "Erro SELECT c_ctb00g10_002 | ", sqlca.sqlcode, " | ", sqlca.sqlerrd[2] sleep 2
        end if
    end if
    close c_ctb00g10_002

    if  l_count > 0 then
        return true
    end if

    return false

 end function

#------------------------------------------#
 function ctb00g10_verif_pagto(l_atdsrvnum,
                               l_atdsrvano)
#------------------------------------------#
    define l_atdsrvnum like datmsrvacp.atdsrvnum,
           l_atdsrvano like datmsrvacp.atdsrvano,
           l_count     smallint

    let l_count = 0
    open c_ctb00g10_003 using l_atdsrvnum, l_atdsrvano
    whenever error continue
    fetch c_ctb00g10_003 into l_count
    whenever error stop
    if  sqlca.sqlcode <> 0 then
        if  sqlca.sqlcode = notfound then
            let l_count = 0
        else
            error "Erro SELECT c_ctb00g10_003 | ", sqlca.sqlcode, " | ", sqlca.sqlerrd[2] sleep 2
        end if
    end if
    close c_ctb00g10_003

    if  l_count > 0 then
        return true
    end if

    return false

 end function
