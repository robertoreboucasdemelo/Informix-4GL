 #############################################################################
 # Nome do Modulo: cts00g03                                          Marcelo #
 #                                                                  Gilberto #
 # Funcoes para tratamento de mensagens para MDT                    Ago/1999 #
 #############################################################################

 database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

  define m_cts00g03_prep smallint

#-------------------------#
function cts00g03_prepare()
#-------------------------#

  define l_sql char(200)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select atdvclsgl, ",
                     " mdtcod, ",
                     " socoprsitcod ",
                " from datkveiculo ",
               " where socvclcod = ? "

  prepare p_cts00g03_001 from l_sql
  declare c_cts00g03_001 cursor for p_cts00g03_001

  let l_sql = " select mdtstt ",
                " from datkmdt ",
               " where mdtcod = ? "

  prepare p_cts00g03_002 from l_sql
  declare c_cts00g03_002 cursor for p_cts00g03_002

  let m_cts00g03_prep = true

end function

#----------------------------------------------------------------------
 function cts00g03_checa_mdt(param)
#----------------------------------------------------------------------

 define param       record
    apltipcod       dec (1,0),                  #--> 1-Online, 2-Batch 3-Batch Acionamento Automatico
    socvclcod       like datkveiculo.socvclcod
 end record

 define ws          record
    atdvclsgl       like datkveiculo.atdvclsgl,
    mdtcod          like datkveiculo.mdtcod,
    socoprsitcod    like datkveiculo.socoprsitcod,
    mdtstt          like datkmdt.mdtstt,
    confirma        char (01),
    erroflg         char (01),
    hora            char (08),
    data            char (10),
    linhamsg        char (40)
 end record

 define l_data      date,
        l_hora1     datetime hour to second


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

 if m_cts00g03_prep is null or
    m_cts00g03_prep <> true then
    call cts00g03_prepare()
 end if

 initialize ws to null

 call cts40g03_data_hora_banco(1)
      returning l_data, l_hora1

 let ws.erroflg  =  "N"
 let ws.data     =  l_data

 #-------------------------------------------------------------------------
 # Checa parametros informados
 #-------------------------------------------------------------------------
 if param.socvclcod  is null   then
    let ws.erroflg  =  "S"
    error " Codigo do veiculo nao informado, AVISE INFORMATICA!"
    return ws.erroflg
 end if

 #-------------------------------------------------------------------------
 # Verifica veiculo e MDT
 #-------------------------------------------------------------------------
 open c_cts00g03_001 using param.socvclcod
 whenever error continue
 fetch c_cts00g03_001 into ws.atdvclsgl, ws.mdtcod, ws.socoprsitcod
 whenever error stop

 if sqlca.sqlcode  <>  0   then
    let ws.erroflg  =  "S"
    if param.apltipcod  =  1   then
       call cts08g01("A","N", "",
                              "NAO E' POSSIVEL TRANSMITIR A MENSAGEM !", "",
                              "VEICULO NAO CADASTRADO")
            returning ws.confirma
    else
       call cts40g03_data_hora_banco(1)
            returning l_data, l_hora1
       let ws.hora  =  l_hora1
       display ws.hora," ===> Veiculo ", param.socvclcod using "&&&&&&",
                       ": Erro (", sqlca.sqlcode using "<<<<<&",
                       ") na leitura da tabela datkveiculo"
    end if
    return ws.erroflg
 end if

 close c_cts00g03_001

 if ws.mdtcod  is null   then
    let ws.erroflg  =  "S"

    if param.apltipcod <> 3 then
       if param.apltipcod  =  1   then
          let ws.linhamsg = "VEICULO ", ws.atdvclsgl clipped, " NAO POSSUI"
          call cts08g01("A","N", ws.linhamsg,
                                "MDT INSTALADO",
                                "",
                                "FAVOR TRANSMITIR A MENSAGEM VIA VOZ !")
               returning ws.confirma
       else
          call cts40g03_data_hora_banco(1)
               returning l_data, l_hora1
          let ws.hora  =  l_hora1
          display ws.hora," ===> Veiculo ", param.socvclcod using "&&&&&&",
                          " nao possui MDT instalado"
       end if
    end if

    return ws.erroflg
 end if

 if ws.socoprsitcod  <>  1   then
    let ws.erroflg  =  "S"
    if param.apltipcod  =  1   then
       let ws.linhamsg = "VEICULO ", ws.atdvclsgl clipped, " NAO ESTA ATIVO"
       call cts08g01("A","N", "",
                              "NAO E' POSSIVEL TRANSMITIR A MENSAGEM !",
                              "",
                              ws.linhamsg)
            returning ws.confirma
    else
       call cts40g03_data_hora_banco(1)
            returning l_data, l_hora1
       let ws.hora  =  l_hora1
       display ws.hora," ===> Veiculo ", param.socvclcod using "&&&&&&",
                       " nao esta ativo"
    end if
    return ws.erroflg
 end if

 open c_cts00g03_002 using ws.mdtcod
 whenever error continue
 fetch c_cts00g03_002 into ws.mdtstt
 whenever error stop

 if ws.mdtstt  <>  0   then
    let ws.erroflg  =  "S"
    if param.apltipcod  =  1   then
       let ws.linhamsg ="MDT DO VEICULO ",ws.atdvclsgl clipped," NAO ESTA ATIVO"
       call cts08g01("A","N", "",
                              "NAO E' POSSIVEL TRANSMITIR A MENSAGEM !",
                              "",
                              ws.linhamsg)
            returning ws.confirma
    else
       call cts40g03_data_hora_banco(1)
            returning l_data, l_hora1
       let ws.hora  =  l_hora1
       display ws.hora," ===> Veiculo ", param.socvclcod using "&&&&&&",
                       " MDT nao esta ativo"
    end if
    return ws.erroflg
 end if

 close c_cts00g03_002

 return ws.erroflg

end function  ###--- cts00g03_checa_mdt

#----------------------------------------------------------------------
 function cts00g03_sit_msg_mdt(param)
#----------------------------------------------------------------------

 define param       record
    mdtmsgnum       like datmmdtmsg.mdtmsgnum,
    mdtmsgstt       like datmmdtmsg.mdtmsgstt
 end record

 define ws          record
    mdtmsgstt       like datmmdtmsg.mdtmsgstt,
    mdtlogseq       like datmmdtlog.mdtlogseq,
    erroflg         char (01),
    hora            char (08),
    data            char (10),
    dataatu         date,
    horaatu         datetime hour to second
 end record

 define l_data      date,
        l_hora1     datetime hour to second

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  ws.*  to  null

 initialize ws.* to null

 call cts40g03_data_hora_banco(1)
      returning l_data, l_hora1

 let ws.erroflg  =  "N"
 let ws.data     =  l_data

 #-------------------------------------------------------------------------
 # Checa parametros informados
 #-------------------------------------------------------------------------
 if param.mdtmsgnum  is null   then
    let ws.erroflg  =  "S"
    error " Numero da transmissao nao informado, AVISE INFORMATICA!"
    return ws.erroflg
 end if

 #-------------------------------------------------------------------------
 # Verifica veiculo e MDT
 #-------------------------------------------------------------------------
 select mdtmsgstt
   into ws.mdtmsgstt
   from datmmdtmsg
  where mdtmsgnum  =  param.mdtmsgnum

 if param.mdtmsgstt  =  2   then           #--> Aguardando retransmissao
    if ws.mdtmsgstt  <>  3   then          #--> Erro na transmissao
       let ws.erroflg  =  "S"
       error " Reenvio apenas para mensagem com erro de transmissao!"
       return ws.erroflg
    end if

    declare c_cts00g03_003  cursor for
       select mdtmsgnum
         from datmmdtlog
        where mdtmsgnum  =  param.mdtmsgnum
          and mdtmsgstt  =  2

    open  c_cts00g03_003
    fetch c_cts00g03_003
    if sqlca.sqlcode  =  0   then
       let ws.erroflg  =  "S"
       error " Reenvio de mensagem deve ser realizada apenas 1 vez!"
       close c_cts00g03_003
       return ws.erroflg
    end if
    close c_cts00g03_003
 end if

 select max(mdtlogseq)
   into ws.mdtlogseq
   from datmmdtlog
  where mdtmsgnum  =  param.mdtmsgnum

 let ws.mdtlogseq  =  ws.mdtlogseq + 1

 #begin work
   update datmmdtmsg  set  mdtmsgstt = param.mdtmsgstt
    where mdtmsgnum  =  param.mdtmsgnum

   #select today, current
   #into ws.dataatu, ws.horaatu
   #from dual                # BUSCA DATA E HORA DO BANCO
   call cts40g03_data_hora_banco(1)
      returning ws.dataatu, ws.horaatu

   insert into datmmdtlog ( mdtmsgnum,
                            mdtlogseq,
                            mdtmsgstt,
                            atldat,
                            atlhor,
                            atlemp,
                            atlmat )
                  values  ( param.mdtmsgnum,
                            ws.mdtlogseq,
                            param.mdtmsgstt,
                            ws.dataatu,
                            ws.horaatu,
                            g_issk.empcod,
                            g_issk.funmat )
 #commit work

 return ws.erroflg

end function  ###--- cts00g03_sit_msg_mdt


#----------------------------------------------------------------------
 function cts00g03_checa_mdt_msg(param)
#----------------------------------------------------------------------

 define param       record
    atdsrvnum       like datmmdtsrv.atdsrvnum,
    atdsrvano       like datmmdtsrv.atdsrvano
 end record

 define ws          record
    mdtmsgstt       like datmmdtmsg.mdtmsgstt,
    erroflg         char (01)
 end record






#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  ws.*  to  null

 initialize ws.*  to null

 #-------------------------------------------------------------------------
 # Verifica se existe mensagem para o mesmo servico
 #-------------------------------------------------------------------------
 if param.atdsrvnum  is not null   then
    declare c_cts00g03_004  cursor for
      select mdtmsgstt
        into ws.mdtmsgstt
        from datmmdtsrv, datmmdtmsg
       where datmmdtsrv.atdsrvnum  =  param.atdsrvnum
         and datmmdtsrv.atdsrvano  =  param.atdsrvano
         and datmmdtmsg.mdtmsgnum  =  datmmdtsrv.mdtmsgnum

    foreach c_cts00g03_004  into  ws.mdtmsgstt
       if ws.mdtmsgstt  =  1   or     #--> Aguardando transmissao
          ws.mdtmsgstt  =  2   or     #--> Aguardando Retransmissao
          ws.mdtmsgstt  =  3   or     #--> Erro na transmissao
          ws.mdtmsgstt  =  4   then   #--> Tempo maximo esgotado
          let ws.erroflg  =  "S"
       end if
    end foreach

    if ws.erroflg  =  "S"   then
       error " Ja' existe transmissao pendente para este servico!"
       return ws.erroflg
    end if
 end if

 return ws.erroflg

end function  ###--- cts00g03_checa_mdt_msg

