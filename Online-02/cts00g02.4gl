#############################################################################
# Nome do Modulo: cts00g02                                          Marcelo #
#                                                                  Gilberto #
# Formata/Grava mensagem a ser enviada para MDT                    Ago/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 02/03/2000  Miriam       Gilberto     Reduzir tamanho da mensagem confor- #
#                                       me layout enviado pelo correio.     #
#---------------------------------------------------------------------------#
# 07/07/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 14/12/2000  PSI 11923-7  Wagner       Reduzir tamanho da mensagem confor- #
#                                       me layout enviado.                  #
#---------------------------------------------------------------------------#
# 24/01/2001  PSI 12018-7  Wagner       Retirar envio da referencia do end. #
#                                       pois o mesmo sera enviado Teletrim  #
#---------------------------------------------------------------------------#
# 24/04/2001  PSI 12955-0  Marcus       Inclusao da funcao de calculo de pre#
#                                       visao automatica para Socorrista    #
#---------------------------------------------------------------------------#
# 17/10/2001  PSI 14064-3  Wagner       Incluir consistencia retorno funcao #
#                                       ctb00g00 cancod = 4 srv pago.       #
#---------------------------------------------------------------------------#
# 28/05/2002  PSI 15456-3  Wagner       Alterar mens.mdt para viaturas RE.  #
#---------------------------------------------------------------------------#
# 25/06/2002  PSI 15426-1  Ruiz         Informar se veic. e blindado ou nao.#
#---------------------------------------------------------------------------#
# 18/09/2003  OSF26522     Marcelo(Meta) Incluir mensagem para a origem     #
#             PSI178381                  JIT                                #
#---------------------------------------------------------------------------#
# 05/11/2004  PSI188336    Julianna,Meta Adicionar nome do segurado na msg  #
#                                        de acionamento do MDT/WVT          #
#---------------------------------------------------------------------------#
# 05/04/2005  PSI.188603   META,MarcosMP Considerar a soma entre a "Previsao#
#                 Analista Carlos Zyon   de Atendimento" e a "Data da Ultima#
#                                        Etapa" na Mensagem de Servico para #
#                                        MDT/WVT.                           #
#---------------------------------------------------------------------------#
# 11/04/2005  PSI189790    Ronaldo, Meta Obter os servicos multiplos, conca-#
#                                        tenar os servicos multiplos, a na -#
#                                        tureza dos servicos multiplos e o  #
#                                        problema dos servicos multiplos.   #
#---------------------------------------------------------------------------#
# 28/10/2005  PSI195138    Lucas Scheid  Obter a descricao da especialidade #
#                                        do servico.                        #
#---------------------------------------------------------------------------#
# 07/03/2006  Zeladoria    Priscila      Buscar data e hora do banco de dado#
# 22/09/06   Ligia Mattge  PSI 202720    Implementacao do grupo/cartao Saude#
#---------------------------------------------------------------------------#
# 22/11/2006 Cristiane Silva PSI205125   Enviar o ramo no acionamento do    #
#                                        servico.                           #
#---------------------------------------------------------------------------#
# 02/12/2006 Ligia Mattge    PSI 205206  ciaempcod/empnom                   #
#---------------------------------------------------------------------------#
# 22/01/2007 Cristiane Silva PSI205117   Enviar coordenada Mapograf         #
# 30/07/2008 Ligia Mattge    PSI         Escrever MOTO na msg MDT           #
#---------------------------------------------------------------------------#
# 17/04/2009  Kevellin       PSI237337   Funções cts00g02_env_msg_ctg_ctr,  #
#                                        cts00g02_laudo_sms,                #
#                                        cts00g02_busca_cel                 #
#---------------------------------------------------------------------------#
# 23/02/2010  Beatriz       PSI253006    Na função cts00g02_busca_cel       #
#                                        verifica se oque a consulta        #
#                                        retornou é nulo, para não mandar   #
# 02/03/2010  Adriano S     PSI 252891   Inclusao do padrao idx 4 e 5       #
#---------------------------------------------------------------------------#
# 23/01/2012  Celso Yamahaki CT201201879 Verificação se a data e hora são   #
#                                        nulas para enviar informações nos  #
#                                        serviços leva e traz               #
#---------------------------------------------------------------------------#
# 13/06/2013  Fornax        PSI-2013-06224/PR                               #
#             Tecnologia                 Identificacao no Acionamento do    #
#                                        Laudo SAPS (Inclusao do campo      #
#                                        MensagemMDT).                      #
#---------------------------------------------------------------------------#
# 15/07/2013 Jorge Modena   PSI201315767 Mecanismo de Seguranca             #
#############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"  #Marcelo - psi178381

  define m_cts00g02_prep smallint,
         m_veiculo_compl smallint,
         m_desc_veiculo  like datmservico.vcldes,
         m_caminhao     char(1)

#----------------------------#
function cts00g02_prepare()
#----------------------------#

  define l_sql char(800)

  #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_sql = null

  let l_sql = " select espcod ",
                " from datmsrvre ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
  prepare p_cts00g02_001 from l_sql
  declare c_cts00g02_001 cursor for p_cts00g02_001

  let l_sql = " select vclcndlclcod ",
                " from datrcndlclsrv ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
  prepare p_cts00g02_002 from l_sql
  declare c_cts00g02_002 cursor for p_cts00g02_002

  let l_sql = "select count(distinct mpg.pltpgncod) ",
  	      " from dpatmpgcrg mpg, datmlcl lcl, glakcid cid ",
  	     " where mpg.lgdauxdes = lcl.lgdnom ",
  	       " and mpg.lgdtip = lcl.lgdtip ",
  	       " and mpg.cidcod = cid.cidcod ",
  	       " and cid.ufdcod = lcl.ufdcod ",
  	       " and cid.cidnom = lcl.cidnom ",
  	       " and lcl.atdsrvnum = ? ",
  	       " and lcl.atdsrvano = ? ",
  	       " and lcl.c24endtip = 1  "
  prepare p_cts00g02_003 from l_sql
  declare c_cts00g02_003 cursor for p_cts00g02_003

  let l_sql = "select mpg.pltpgncod, mpg.pltcrdcod ",
               " from dpatmpgcrg mpg, datmlcl lcl, glakcid cid ",
  	      " where mpg.lgdauxdes = lcl.lgdnom ",
  	        " and mpg.lgdtip = lcl.lgdtip ",
  	        " and mpg.cidcod = cid.cidcod ",
   	        " and cid.ufdcod = lcl.ufdcod ",
                " and cid.cidnom = lcl.cidnom ",
  	        " and lcl.atdsrvnum = ? ",
  	        " and lcl.atdsrvano = ? ",
  	        " and lcl.c24endtip = 1 "
  prepare p_cts00g02_004 from l_sql
  declare c_cts00g02_004 cursor for p_cts00g02_004


  let l_sql = "select cgccpfnum, "   ,
              " cgcord    , "        ,
              " cgccpfdig   "        ,
              " from datrligcgccpf " ,
              " where lignum = ?   "
  prepare p_cts00g02_005 from l_sql
  declare c_cts00g02_005 cursor for p_cts00g02_005


  let l_sql = "select 1 ",
              "  from datkgeral  ",
              " where grlchv = ? ",
              "   and grlinf = 'S' "
  prepare p_cts00g02_006 from l_sql
  declare c_cts00g02_006 cursor for p_cts00g02_006

  let l_sql = " select celdddcod, ",
                     " celtelnum  ",
                " from datkveiculo ",
               " where socvclcod = ? "
  prepare p_cts00g02_007 from l_sql
  declare c_cts00g02_007 cursor for p_cts00g02_007

  let l_sql = " select nxtdddcod, ",
                 "     nxtnum ",
                " from datkveiculo ",
               " where socvclcod = ? "

  prepare p_cts00g02_008 from l_sql
  declare c_cts00g02_008 cursor for p_cts00g02_008

  let l_sql = " select srr.celdddcod, ",
                 "     srr.celtelnum ",
                " from datksrr srr, ",
                "      dattfrotalocal frt ",
               " where frt.socvclcod = ? ",
               "   and frt.srrcoddig = srr.srrcoddig "

  prepare p_cts00g02_009 from l_sql
  declare c_cts00g02_009 cursor for p_cts00g02_009

  let l_sql = "insert into dbsmenvmsgsms (smsenvcod,",
                                       " dddcel, ",
                                       " celnum, ",
                                       " msgtxt, ",
                                       " incdat, ",
                                       " envstt) ",
                               " values (?,?,?,?,?,?)"
    prepare p_cts00g02_010 from l_sql

  let l_sql = " select srr.nxtdddcod, ",
                 "     srr.nxtnum ",
                " from datksrr srr, ",
                "      dattfrotalocal frt ",
               " where frt.socvclcod = ? ",
               "   and frt.srrcoddig = srr.srrcoddig "

  prepare p_cts00g02_011 from l_sql
  declare c_cts00g02_011 cursor for p_cts00g02_011


  let l_sql = "select 1 ",
               " from datmsrvre, ",
                    " iddkdominio ",
              " where atdsrvnum = ? ",
                " and atdsrvano = ? ",
                " and socntzcod = cpodes ",
                " and cponom    = 'ntzenvmsghdcasa' "

  prepare p_cts00g02_012 from l_sql
  declare c_cts00g02_012 cursor for p_cts00g02_012

  let l_sql = "select a.ramcod,    ",
            "       a.aplnumdig, ",
            "       a.itmnumdig, ",
            "       a.edsnumref, ",
            "       b.itaciacod  ",
            " from datrligapol a,",
            "      datrligitaaplitm b ",
            "where a.lignum = (select MIN(lignum)",
            "                    from datmligacao",
            "                   where atdsrvnum = ?",
            "                     and atdsrvano = ? )",
            "   and a.lignum = b.lignum"

  prepare p_cts00g02_013 from l_sql
  declare c_cts00g02_013 cursor for p_cts00g02_013

  let l_sql = "select grlinf ",
              "  from datkgeral  ",
              " where grlchv = ? "
  prepare p_cts00g02_014 from l_sql
  declare c_cts00g02_014 cursor for p_cts00g02_014
  
  let l_sql = " select min(lignum) ",               
              " from datmligacao ",                     
              " where atdsrvnum = ? ",                   
              "  and  atdsrvano = ? "                    
  prepare p_cts00g02_015 from l_sql                  
  declare c_cts00g02_015 cursor for p_cts00g02_015 
  
  let l_sql = "select ciaempcod,    ",
              "       asitipcod,    ",
              "       atdsrvorg     ",
              " from  datmservico   ",
              "  where atdsrvnum = ?",
              "    and atdsrvano = ?"
  prepare p_cts00g02_016 from l_sql                  
  declare c_cts00g02_016 cursor for p_cts00g02_016  
  
  let l_sql = " select datkveiculo.pstcoddig, ",
                     " datkveiculo.socvclcod, ",
                     " dattfrotalocal.srrcoddig ",
                " from datkveiculo, dattfrotalocal ",
               " where dattfrotalocal.socvclcod = datkveiculo.socvclcod ",
                 " and datkveiculo.mdtcod = ? "
  prepare p_cts00g02_017 from l_sql
  declare c_cts00g02_017 cursor for p_cts00g02_017
  
   

  let m_cts00g02_prep = true

end function

#-------------------------------------------------#
function cts00g02_busca_especialidade(lr_parametro)
#-------------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmsrvre.atdsrvnum,
         atdsrvano    like datmsrvre.atdsrvano
  end record

  define l_espcod like datmsrvre.espcod,
         l_espdes like dbskesp.espdes

  if m_cts00g02_prep is null or
     m_cts00g02_prep <> true then
     call cts00g02_prepare()
  end if

  let l_espcod = null
  let l_espdes = null

  # --BUSCA O CODIGO DA ESPECIALIDADE
  open c_cts00g02_001 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano
  whenever error continue
  fetch c_cts00g02_001 into l_espcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_espcod = null
     else
        error "Erro SELECT c_cts00g02_001 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 5
        error "CTS00G02/cts00g02_busca_especialidade() ", lr_parametro.atdsrvnum, "/",
                                                          lr_parametro.atdsrvano sleep 5
     end if
  end if

  close c_cts00g02_001

  # --SE EXISTIR O CODIGO DA ESPECIALIDADE
  if l_espcod is not null then

     # --BUSCA A DESCRICAO DA ESPECIALIDADE
     let l_espdes = cts31g00_descricao_esp(l_espcod, "")

  end if

  return l_espdes

end function

#----------------------------------------------------------------------
 function cts00g02_env_msg_mdt(param)
#----------------------------------------------------------------------

 define param       record
    apltipcod       dec (1,0),
    atdsrvnum       like datmmdtsrv.atdsrvnum,
    atdsrvano       like datmmdtsrv.atdsrvano,
    mdtmsgtxt       like datmmdtmsgtxt.mdtmsgtxt,
    socvclcod       like datkveiculo.socvclcod
 end record

 define ws          record
    mdtmsgnum       like datmmdtmsg.mdtmsgnum,
    mdtcod          like datmmdtmsg.mdtcod,
    mdtmsgtxt       like datmmdtmsgtxt.mdtmsgtxt,
    tabname         like systables.tabname,
    mdtctrcod       like datkmdtctr.mdtctrcod,
    parametroctg    char(20),
    sqlcode         integer,
    laudo           char (4500),
    erroflg         char (01),
    hora            char (08),
    data            char (10),
    vez             integer,
    qtdchar         dec  (4,0),
    qtdregtxt       dec  (1,0),
    pgrnum          like datkveiculo.pgrnum,
    dataatu         date,
    horaatu         datetime hour to second,
    socntzcod       like datmsrvre.socntzcod
 end record

 define lr_hd record
     codigo smallint,
     texto  char(140)
 end record

 define l_data     date,
        l_hora1    datetime hour to second,
        l_status   smallint
      , l_errcod   integer

 initialize l_errcod to null
 
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

 if m_cts00g02_prep is null or
    m_cts00g02_prep <> true then
    call cts00g02_prepare()
 end if

 initialize  ws.*  to  null

 call cts40g03_data_hora_banco(1)
      returning l_data, l_hora1

 initialize ws.* to null
 let ws.erroflg  =  "N"
 let ws.data     =  l_data

 #-------------------------------------------------------------------------
 # Checa parametros informados
 #-------------------------------------------------------------------------
 if (param.apltipcod  is null)  or
    (param.apltipcod  <>  1     and    #-> 1-Online, 2-Batch
     param.apltipcod  <>  2)    then
    let ws.erroflg  =  "S"
    error " Parametro tipo aplicacao incorreto, AVISE INFORMATICA!"
    return ws.erroflg
 end if

 if (param.atdsrvnum  is null   or
     param.atdsrvano  is null)  and
     param.mdtmsgtxt  is null   then
    let ws.erroflg  =  "S"
    if param.apltipcod  =  1   then
       error   " Texto ou nro servico nao informado, AVISE INFORMATICA!"
    else
       display " Texto ou nro servico nao informado, AVISE INFORMATICA!"
    end if
    return ws.erroflg
 end if

 if (param.atdsrvnum  is not null   or
     param.atdsrvano  is not null)  and
     param.mdtmsgtxt  is not null   then
    let ws.erroflg  =  "S"
    if param.apltipcod  =  1   then
       error   " Texto e nro servico informados, AVISE INFORMATICA!"
    else
       display " Texto e nro servico informados, AVISE INFORMATICA!"
    end if
    return ws.erroflg
 end if

 if param.socvclcod  is null   then
    let ws.erroflg  =  "S"
    if param.apltipcod  =  1   then
       error   " Codigo do veiculo nao informado, AVISE INFORMATICA!"
    else
       display " Codigo do veiculo nao informado, AVISE INFORMATICA!"
    end if
    return ws.erroflg
 end if

 #-------------------------------------------------------------------------
 # Monta mensagem com texto informado ou laudo de servico
 #-------------------------------------------------------------------------
 if param.atdsrvnum   is not null   then
    call cts00g02_laudo(param.atdsrvnum,
                        param.atdsrvano,
                        param.socvclcod)
         returning  ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode

    if ws.sqlcode  <>  0   then
       let ws.erroflg  =  "S"
       if param.apltipcod  =  1   then
          error   " Erro (",ws.sqlcode,") na tabela ", ws.tabname," !"
       else
          call cts40g03_data_hora_banco(1)
               returning l_data, l_hora1
          let ws.hora  =  l_hora1
          display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                                       "-", param.atdsrvano using "&&"    ,
                          ": Erro (", ws.sqlcode using "<<<<<&",
                          ") na inclusao da tabela ", ws.tabname
       end if
       return ws.erroflg
    end if
 else
    let ws.laudo  =  param.mdtmsgtxt

    select mdtcod,
           pgrnum
      into ws.mdtcod,
           ws.pgrnum
      from datkveiculo
     where socvclcod  =  param.socvclcod

 end if

 open c_cts00g02_012 using param.atdsrvnum,
                           param.atdsrvano
 fetch c_cts00g02_012 into l_status

 if  sqlca.sqlcode = 0 then

     call ctf00m10_hst_prt(param.atdsrvnum,
                           param.atdsrvano)
          returning lr_hd.codigo,
                    lr_hd.texto

     if  lr_hd.codigo = 0 then
         let ws.laudo = ws.laudo clipped, " ", lr_hd.texto
     end if
 end if

 #-------------------------------------------------------------------------
 # Grava tabelas para envio de mensagem
 #-------------------------------------------------------------------------
 whenever error continue

   insert into datmmdtmsg ( mdtmsgnum,
                            mdtmsgorgcod,
                            mdtcod,
                            mdtmsgstt,
                            mdtmsgavstip )
                 values   ( 0,
                            1,
                            ws.mdtcod,
                            1,           #--> Aguardando transmissao
                            3 )          #--> Sinal bip e sirene

   if sqlca.sqlcode  <>  0   then
      let ws.erroflg  =  "S"
      if param.apltipcod  =  1   then
         error   " Erro (",sqlca.sqlcode,") na inclusao tabela datmmdtmsg !"
      else
         call cts40g03_data_hora_banco(1)
              returning l_data, l_hora1
         let ws.hora  =  l_hora1
         display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                                      "-", param.atdsrvano using "&&"    ,
                         ": Erro (", sqlca.sqlcode using "<<<<<&",
                         ") na inclusao da tabela datmmdtmsg"
      end if
      return ws.erroflg
   end if

   let ws.mdtmsgnum  =  sqlca.sqlerrd[2]

   #select today, current
   #  into ws.dataatu, ws.horaatu
   #  from dual                # BUSCA DATA E HORA DO BANCO
   call cts40g03_data_hora_banco(1)
      returning ws.dataatu, ws.horaatu

   insert into datmmdtlog ( mdtmsgnum,
                            mdtlogseq,
                            mdtmsgstt,
                            atldat,
                            atlhor,
                            atlemp,
                            atlmat )
                  values  ( ws.mdtmsgnum,
                            1,
                            1,
                            ws.dataatu,
                            ws.horaatu,
                            g_issk.empcod,
                            g_issk.funmat )

   if sqlca.sqlcode  <>  0   then
      let ws.erroflg  =  "S"
      if param.apltipcod  =  1   then
         error   " Erro (",sqlca.sqlcode,") na inclusao tabela datmmdtlog !"
      else
         call cts40g03_data_hora_banco(1)
              returning l_data, l_hora1
         let ws.hora  =  l_hora1
         display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                                      "-", param.atdsrvano using "&&"    ,
                         ": Erro (", sqlca.sqlcode using "<<<<<&",
                         ") na inclusao da tabela datmmdtlog"
      end if
      return ws.erroflg
   end if

   let ws.qtdchar  =  length(ws.laudo)

   if ws.qtdchar  <  2001   then
      let ws.qtdregtxt  =  1
   else
      let ws.qtdregtxt  =  2
   end if

   for ws.vez = 1  to  ws.qtdregtxt

     if ws.vez  =  1   then
        let ws.mdtmsgtxt  =  ws.laudo[0001,2000]
     else
        let ws.mdtmsgtxt  =  ws.laudo[2001,4000]
     end if

     insert into datmmdtmsgtxt ( mdtmsgnum,
                                 mdtmsgtxtseq,
                                 mdtmsgtxt )
                     values    ( ws.mdtmsgnum,
                                 ws.vez,
                                 ws.mdtmsgtxt )
                                 
     let l_errcod = sqlca.sqlcode

     if l_errcod  <>  0   then
        let ws.erroflg  =  "S"
        if param.apltipcod  =  1   then
           error " Erro (", l_errcod,") na inclusao tabela datmmdtmsgtxt !"
        else
           call cts40g03_data_hora_banco(1) returning l_data, l_hora1
           
           let ws.hora  =  l_hora1
           
           display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                           "-", param.atdsrvano using "&&"    ,
                           ": Erro (", l_errcod using "<<<<<&",
                           ") na inclusao da tabela datmmdtmsgtxt"
        end if
        return ws.erroflg
     end if

   end for

   if param.atdsrvnum  is not null   then

      insert into datmmdtsrv ( mdtmsgnum,
                               atdsrvnum,
                               atdsrvano )
                     values  ( ws.mdtmsgnum,
                               param.atdsrvnum,
                               param.atdsrvano )

      if sqlca.sqlcode  <>  0   then
         let ws.erroflg  =  "S"
         if param.apltipcod  =  1   then
            error   " Erro (",sqlca.sqlcode,") na inclusao tabela datmmdtsrv !"
         else
           call cts40g03_data_hora_banco(1)
                returning l_data, l_hora1
            let ws.hora  =  l_hora1
            display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                                         "-", param.atdsrvano using "&&"    ,
                            ": Erro (", sqlca.sqlcode using "<<<<<&",
                            ") na inclusao da tabela datmmdtsrv"
         end if
         return ws.erroflg
      end if

   end if

 whenever error stop

 if param.apltipcod  =  1   then
    error " *** MENSAGEM SENDO TRANSMITIDA PARA O MDT, PROSSIGA ***"
 end if

 ###PSI 237337 - VERIFICA SE CONTROLADORA ESTÁ EM CONTINGÊNCIA
 select mdtctrcod
   into ws.mdtctrcod
   from datkmdt
  where mdtcod = ws.mdtcod

 let ws.parametroctg = 'PSOCTGCTR', ws.mdtctrcod
 open  c_cts00g02_006 using ws.parametroctg
 fetch c_cts00g02_006

 if sqlca.sqlcode  <>  notfound   then
    #error " Controladora ",  ws.mdtctrcod, " em contingencia, servico enviado por sms!"
    error "Servico enviado tambem por SMS! (controladora da viatura em contingencia SMS)"

    #CHAMAR FUNÇÃO PARA ENVIO DE MENSAGEM SMS
    call cts00g02_env_msg_ctg_ctr(param.atdsrvnum,
                                  param.atdsrvano,
                                  param.socvclcod)
        returning ws.erroflg

 end if

 close c_cts00g02_006
 #####

 return ws.erroflg

end function  ###--- cts00g02


#--------------------------------------------------------------------------#
 function cts00g02_laudo(param)
#--------------------------------------------------------------------------#

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    socvclcod         like datmservico.socvclcod
 end record

 define d_cts00g02    record
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    srvtipabvdes      like datksrvtip.srvtipabvdes ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    c24opemat         like datmservico.c24opemat   ,
    rmcacpdes         char (03)                    ,
    atdrsddes         char (03)                    ,
    atdlclflg         like datmservico.atdlclflg   ,
    nom               like datmservico.nom         ,
    dddcod            like gsakend.dddcod          ,
    teltxt            like gsakend.teltxt          ,
    vcldes            like datmservico.vcldes      ,
    vclcordes         char (20)                    ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    bocflg            like datmservicocmp.bocflg   ,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    atddfttxt         like datmservico.atddfttxt   ,
    roddantxt         like datmservicocmp.roddantxt,
    nomgrr            like dpaksocor.nomgrr        ,
    atdmotnom         like datmservico.atdmotnom   ,
    atdvclsgl         like datmservico.atdvclsgl   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atdprvdat         interval hour to minute,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    ramcod            like datrservapol.ramcod     ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,

    ntzdes            like datksocntz.socntzdes    ,
    orrdat            like datmsrvre.orrdat        ,
    orrhor            like datmsrvre.orrhor        ,

    vstnumdig         like datmvistoria.vstnumdig  ,
    vstflddes         char (30)                    ,
    corsus            like datmvistoria.corsus     ,
    cornom            like datmvistoria.cornom     ,
    segnom            like datmvistoria.segnom     ,
    vclchsnum         like datmvistoria.vclchsnum  ,
    vclanofbc         like datmvistoria.vclanofbc,
    crtsaunum         like datrligsau.crtnum     ,
    edsnumref         like datrservapol.edsnumref
 end record

 define a_cts00g02    array[2] of record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtxt           char (80),
    lclbrrnom        like datmlcl.lclbrrnom,
    endzon           like datmlcl.endzon,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom
 end record

 define ws            record
    campo             char (40)                    ,
    msgpvt            char (40)                    ,
    fim               char (03)                    ,
    cponom            like iddkdominio.cponom      ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    asitipcod         like datmservico.asitipcod   ,
    atdprscod         like datmservico.atdprscod   ,
    vclcorcod         like datmservico.vclcorcod   ,
    atdrsdflg         like datmservico.atdrsdflg   ,
    rmcacpflg         like datmservicocmp.rmcacpflg,
    c24srvdsc         like datmservhist.c24srvdsc  ,
    c24txtseq         like datmservhist.c24txtseq  ,
    vstfld            like datmvistoria.vstfld     ,
    vclmrcnom         like datmvistoria.vclmrcnom  ,
    vcltipnom         like datmvistoria.vcltipnom  ,
    vclmdlnom         like datmvistoria.vclmdlnom  ,
    lclrsccod         like datmsrvre.lclrsccod     ,
    socntzcod         like datmsrvre.socntzcod     ,
    sinntzcod         like datmsrvre.sinntzcod     ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    srvprlflg         like datmservico.srvprlflg   ,
    mdtcod            like datkveiculo.mdtcod      ,
    pgrnum            like datkveiculo.pgrnum      ,
    ustcod            like htlrust.ustcod          ,
    canpgtcod         dec (1,0)                    ,
    difcanhor         datetime hour to minute      ,
    msgpgttxt         char (50)                    ,
    tabname           like systables.tabname       ,
    sqlcode           integer                      ,
    laudo             char (4000)                  ,
    vclcoddig         like datmservico.vclcoddig   ,
    errcod            integer                      ,
    sqlcod            integer                      ,
    mstnum            integer                      ,
    imsvlr            like abbmcasco.imsvlr        ,
    imsvlrdes         char (08)                    ,
    atdetpdat         like datmsrvacp.atdetpdat    , #=> PSI.188603
    atdetphor         interval hour to minute      , #=> PSI.188603
    datahoraqtr       datetime year to minute      , #=> PSI.188603
    dispdata          date                         , #=> PSI.188603
    disphora          datetime hour to minute,        #=> PSI.188603
    mensagem          char (80),
    resultado         smallint,
    vclcndlclcod    like datrcndlclsrv.vclcndlclcod,
    vclcndlcldes    like datkvclcndlcl.vclcndlcldes,
    ramcod          like gtakram.ramcod,
    ramnom          like gtakram.ramnom,
    ramsgl          like gtakram.ramsgl,
    ciaempcod       like datmservico.ciaempcod,
    empnom          like gabkemp.empnom,
    pltpgncod       like dpatmpgcrg.pltpgncod, #=> PSI205117
    pltcrdcod       like dpatmpgcrg.pltcrdcod, #=> PSI205117
    conta           smallint , #PSI205117
    lignum          like datrligsrv.lignum,

    lclltt          like datmlcl.lclltt,
    lcllgt          like datmlcl.lcllgt,
    mdtctrcod       like datkmdt.mdtctrcod,
    txtlclltt       char(20),
    txtlcllgt       char(20),

    grlchv          like datkgeral.grlchv,
    acnmsgcan001    like datkgeral.grlinf,
    acnmsgcan002    like datkgeral.grlinf,
    acnmsgcan       char(100),
    lgdtip          like datmlcl.lgdtip,     
    lgdnom          like datmlcl.lgdnom,     
    lgdnum          like datmlcl.lgdnum,     
    endcmp          like datmlcl.endcmp,
    brrnom          like datmlcl.brrnom,
    lgdcep          like datmlcl.lgdcep,
    lgdcepcmp       like datmlcl.lgdcepcmp,
    c24lclpdrcod    like datmlcl.c24lclpdrcod     
 end record

 define l_ind        smallint,
        l_passou     smallint,
        l_condicao   char(200)

 define al_retorno   array[10] of record
        atdmltsrvnum like datratdmltsrv.atdmltsrvnum,
        atdmltsrvano like datratdmltsrv.atdmltsrvano,
        socntzdes    like datksocntz.socntzdes,
        espdes       like dbskesp.espdes,
        atddfttxt    like datmservico.atddfttxt
 end record

 define lr_ffpfc073 record
        cgccpfnumdig char(18) ,
        cgccpfnum    char(12) ,
        cgcord       char(4)  ,
        cgccpfdig    char(2)  ,
        mens         char(50) ,
        erro         smallint
 end record


 define l_status      smallint,
        l_atdprvdat   like datmservico.atdprvdat,
        l_hour        datetime hour to minute,
        l_espdes      like dbskesp.espdes

  define l_resultado   smallint,
        l_mensagem    char(100),
        l_segnom      like gsakseg.segnom,
        l_grupo       like gtakram.ramgrpcod,
        l_documento   char(200),
        l_doc_handle  integer,
        l_data_atual  date,
        l_hora_atual  datetime hour to minute,
        l_ctgtrfcod   like datrctggch.ctgtrfcod,
        l_msginicial  char(150),
        l_msginicmdt  char(150),  #--> PSI-2013-06224/PR
        l_errcod      integer  ,
        l_msgininat   char(150),
        l_msgcancela  char(150),
        l_kmazul      char(3),
        l_qtdeazul    char(3),
        l_kmazulint   integer,
        l_ris         smallint,
        l_lgdnum      char(06)         

  define l_retnumpassageiros record
          erro           smallint                   ,
          mensagem       char(100)                  ,
          numpassageiros like datmpassageiro.passeq
  end record

  define lr_retorno record
     pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
     socqlmqtd     like datkitaasipln.socqlmqtd    ,
     erro          integer,
     mensagem      char(50)
  end record

  define l_mensagem_passageiros char(100)

  define l_limpecas  char(500),
         l_mobrefvlr like dpakpecrefvlr.mobrefvlr,
         l_pecmaxvlr like dpakpecrefvlr.pecmaxvlr

  define  w_pf1   integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let l_ind        = null
        let l_status     = null
        let l_atdprvdat  = null
        let l_hour       = null
        let l_espdes     = null
        let w_pf1        = null
        let l_data_atual = null
        let l_hora_atual = null
        let l_resultado  = null
        let l_ctgtrfcod  = null
        let l_msginicial = ""
        let l_msginicmdt = ""   #--> PSI-2013-06224/PR
        let l_msgcancela = ""
        let l_kmazul     = null
        let l_kmazulint  = 0
        let l_qtdeazul   = null
        let l_ris        = false
        let l_limpecas   = null
        let l_lgdnum     = null

        if m_cts00g02_prep is null or
           m_cts00g02_prep <> true then
           call cts00g02_prepare()
        end if


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  2
                initialize  a_cts00g02[w_pf1].*  to  null
        end     for

        for     w_pf1  =  1  to  10
                initialize  al_retorno[w_pf1].*  to  null
        end     for

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_cts00g02.*  to  null

        initialize  ws.*          to  null
        initialize  lr_ffpfc073.* to null
        initialize  lr_retorno.* to null

  for     w_pf1  =  1  to  2
          initialize  a_cts00g02[w_pf1].*  to  null
  end     for

  initialize  d_cts00g02.*  to  null

  initialize  ws.*  to  null
  initialize l_errcod to null
  
 let l_atdprvdat = null
 let l_hour      = "00:00"
 let l_doc_handle = null

 initialize d_cts00g02.*  to null
 initialize a_cts00g02    to null
 initialize ws.*          to null
 let ws.fim  =  "#"

 let l_resultado   = null
 let l_mensagem    = null
 let l_segnom      = null
 let l_grupo       = null
 let l_documento   = null
 
 select datmservico.atdsrvnum,
        datmservico.atdsrvano,
        datmservico.vclcorcod,
        datmservico.c24opemat,
        datmservicocmp.rmcacpflg,
        datmservico.srvprlflg,
        datmservico.atdlclflg,
        datmservico.atdsrvorg,
        datmservico.asitipcod,
        datmservico.atdrsdflg,
        datmservico.nom,
        datmservico.vcldes,
        datmservico.vclanomdl,
        datmservico.vcllicnum,
        datmservicocmp.bocflg,
        datmservicocmp.bocnum,
        datmservicocmp.bocemi,
        datmservico.atddfttxt,
        datmservicocmp.roddantxt,
        datmservico.atdprscod,
        datmservico.atdmotnom,
        datmservico.atddat,
        datmservico.atdhor,
        datmservico.atdhorpvt,
        datmservico.atdprvdat,
        datmservico.atddatprg,
        datmservico.atdhorprg,
        datmservico.cnldat,
        datmservico.atdfnlhor,
        datmservico.vclcoddig,
        datmservico.ciaempcod
   into d_cts00g02.atdsrvnum,
        d_cts00g02.atdsrvano,
        ws.vclcorcod,
        d_cts00g02.c24opemat,
        ws.rmcacpflg,
        ws.srvprlflg,
        d_cts00g02.atdlclflg,
        ws.atdsrvorg,
        ws.asitipcod,
        ws.atdrsdflg,
        d_cts00g02.nom,
        d_cts00g02.vcldes,
        d_cts00g02.vclanomdl,
        d_cts00g02.vcllicnum,
        d_cts00g02.bocflg,
        d_cts00g02.bocnum,
        d_cts00g02.bocemi,
        d_cts00g02.atddfttxt,
        d_cts00g02.roddantxt,
        ws.atdprscod,
        d_cts00g02.atdmotnom,
        d_cts00g02.atddat,
        d_cts00g02.atdhor,
        d_cts00g02.atdhorpvt,
        l_atdprvdat,
        d_cts00g02.atddatprg,
        d_cts00g02.atdhorprg,
        ws.cnldat,
        ws.atdfnlhor,
        ws.vclcoddig,
        ws.ciaempcod
   from datmservico, outer datmservicocmp
  where datmservico.atdsrvnum    = param.atdsrvnum
    and datmservico.atdsrvano    = param.atdsrvano
    and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
    and datmservicocmp.atdsrvano = datmservico.atdsrvano

 if sqlca.sqlcode <> 0  then
    let ws.tabname = "datmservico"
    let ws.sqlcode = sqlca.sqlcode

    return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
 end if

 #------------------------------
 # BUSCAR A DATA E HORA DO BANCO
 #------------------------------
 call cts40g03_data_hora_banco(2)
      returning l_data_atual,
                l_hora_atual

 #------------------------------
 # BUSCAR TEXTO DE CANCELAMENTO
 #------------------------------
 let ws.acnmsgcan = ''
 let ws.grlchv = 'PSOACNMSGCAN001'
 open c_cts00g02_014 using ws.grlchv
 fetch c_cts00g02_014 into ws.acnmsgcan001
 if sqlca.sqlcode = 0 then
    let ws.acnmsgcan = ws.acnmsgcan001
 end if
 close c_cts00g02_014

 let ws.grlchv = 'PSOACNMSGCAN002'
 open c_cts00g02_014 using ws.grlchv
 fetch c_cts00g02_014 into ws.acnmsgcan002
 if sqlca.sqlcode = 0 then
    if ws.acnmsgcan = '' or ws.acnmsgcan = ' ' then
       let ws.acnmsgcan = ws.acnmsgcan002
    else
       let ws.acnmsgcan = ws.acnmsgcan clipped, ' ', ws.acnmsgcan002
    end if
 end if
 close c_cts00g02_014


 if ws.atdsrvorg <> 9 then

    #--------------------------------------
    # OBTER O CODIGO DA CATEGORIA TARIFARIA
    #--------------------------------------
    call cty05g03_pesq_catgtf(ws.vclcoddig,
                              l_data_atual)
         returning l_resultado,
                   l_mensagem,
                   l_ctgtrfcod

    if l_resultado <> 0 then
       if l_resultado = 1 then
          error "Categoria tarifaria nao encontrada, veiculo: ",
                ws.vclcoddig sleep 2
       else
          error "Erro de acesso a banco na funcao cty05g03_pesq_catgtf()" sleep 2
       end if
    end if
 end if

 let m_veiculo_compl = false # NAO ENVIAR A DESCRICAO COMPLETA DO VEICULO
 let m_desc_veiculo  = null

 # -> VERIFICA SE A CATEGORIA TARIFARIA CORRESPONDE A CAMINHAO
 call cts02m01_ctgtrfcod(l_ctgtrfcod)
      returning m_caminhao
 {if l_ctgtrfcod = 40 or
    l_ctgtrfcod = 41 or
    l_ctgtrfcod = 42 or
    l_ctgtrfcod = 43 or
    l_ctgtrfcod = 50 or
    l_ctgtrfcod = 51 or
    l_ctgtrfcod = 52 or
    l_ctgtrfcod = 43 then}
  if m_caminhao = "S" then

    # -> CONFORME SOLICITACAO DO CESAR(GUILHERME) DO RADIO, QUANDO O VEICULO
    #    FOR CAMINHAO, ENVIAR A DESCRICAO COMPLETA NA MENSAGEM MDT.
    #    DATA: 04/12/2006
    #    CHAMADO: 6116004
    #    AUTOR: LUCAS SCHEID

    let m_veiculo_compl = true # ENVIAR A DESCRICAO COMPLETA DO VEICULO
    let m_desc_veiculo  = d_cts00g02.vcldes

 end if

 if l_ctgtrfcod = 30 or l_ctgtrfcod = 31 then  ### MOTO
    let m_desc_veiculo = "MOTO"
 end if

 ## VERIFICA SE SOLICITA PREENCHIMENTO DE RIS
 call ctb28g00_com_ris(param.atdsrvnum,
                       param.atdsrvano,
                       "WEB")
      returning l_ris
      
 call cty14g00_empresa(1, ws.ciaempcod)
      returning l_resultado, l_mensagem, ws.empnom
      
 if l_ris then
    let l_msginicial = "***SERVICO PORTO C/ RIS***"
 else
    let l_msginicial = "***SERVICO PORTO***"
 end if

 let l_msgcancela = "***SERVICO CANCELADO ", ws.acnmsgcan clipped, "- PORTO***"

 let d_cts00g02.atdprvdat = l_atdprvdat - l_hour

 #call ctx04g00_local_reduzido(param.atdsrvnum, param.atdsrvano, 1)
 #    returning a_cts00g02[1].lclidttxt thru a_cts00g02[1].lclcttnom,ws.sqlcode
 #
 #if ws.sqlcode <> 0  then
 #   let ws.tabname = "datmlcl"
 #   return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
 #end if
 
 call ctx04g00_local_completo(param.atdsrvnum, param.atdsrvano, 1)    
                          returning a_cts00g02[1].lclidttxt   ,      
                                    ws.lgdtip      ,      
                                    ws.lgdnom      ,      
                                    ws.lgdnum      ,      
                                    a_cts00g02[1].lclbrrnom   ,      
                                    ws.brrnom      ,      
                                    a_cts00g02[1].cidnom      ,      
                                    a_cts00g02[1].ufdcod      ,      
                                    a_cts00g02[1].lclrefptotxt,      
                                    a_cts00g02[1].endzon      ,      
                                    ws.lgdcep      ,      
                                    ws.lgdcepcmp   ,      
                                    a_cts00g02[1].dddcod      ,      
                                    a_cts00g02[1].lcltelnum   ,      
                                    a_cts00g02[1].lclcttnom   ,      
                                    ws.c24lclpdrcod,      
                                    ws.sqlcode,                      
                                    ws.endcmp    
     
     
 if ws.sqlcode <> 0  then
    let ws.tabname = "datmlcl"
    return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
 end if
 
 let l_lgdnum = ws.lgdnum using "<<<<#"   
 
 ##verifica se servico possui controle de seguranca
 if cty28g00_controla_mecanismo_seguranca(param.atdsrvnum, param.atdsrvano,ws.ciaempcod) then 
    if ws.lgdnum is not null then         
       if ws.lgdnum >= 1000  then
          let l_lgdnum = l_lgdnum[1,2] clipped, "XX"
       else 
         if ws.lgdnum >= 100 then
             let l_lgdnum = l_lgdnum[1,1] clipped, "XX"  	  
         else  	     
            let l_lgdnum = "XX"    	     	
         end if
       end if    
    end if
 end if
 
 let a_cts00g02[1].lgdtxt       = ws.lgdtip clipped, " ",             
                                  ws.lgdnom clipped, " ", 
                                  l_lgdnum  clipped, " ",       
                                  ws.endcmp clipped                   

 
 
 # PSI 244589 - Inclusão de Sub-Bairro - Burini                 
 call cts06g10_monta_brr_subbrr(ws.brrnom,           
                               a_cts00g02[1].lclbrrnom)        
     returning a_cts00g02[1].lclbrrnom  
 
 
 

 call ctx04g00_local_reduzido(param.atdsrvnum, param.atdsrvano, 2)
     returning a_cts00g02[2].lclidttxt thru a_cts00g02[2].lclcttnom,ws.sqlcode

 if ws.sqlcode < 0  then
    let ws.tabname = "datmlcl"
    return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
 end if

 #---------------------------------------------------------
 # Identificando cod ramo e descricao
 #---------------------------------------------------------
 #PSI205125 - Inicio
 #open ccts00g02004 using param.atdsrvnum, param.atdsrvano
 #fetch ccts00g02004 into ws.ramcod, ws.ramnom
 #close ccts00g02004
 #PSI205125 - Fim


 #---------------------------------------------------------
 # Sigla/MDT do veiculo
 #---------------------------------------------------------
 select atdvclsgl, mdtcod, pgrnum
   into d_cts00g02.atdvclsgl, ws.mdtcod, ws.pgrnum
   from datkveiculo
  where socvclcod = param.socvclcod

 if sqlca.sqlcode <> 0  then
    let ws.tabname = "datkveiculo"
    let ws.sqlcode = sqlca.sqlcode
    return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
 end if

 #---------------------------------------------------------
 # Apolice do servico
 #---------------------------------------------------------
 select ramcod,
        succod,
        aplnumdig,
        itmnumdig,
        edsnumref
   into d_cts00g02.ramcod,
        d_cts00g02.succod,
        d_cts00g02.aplnumdig,
        d_cts00g02.itmnumdig,
        d_cts00g02.edsnumref
   from datrservapol
  where atdsrvnum = d_cts00g02.atdsrvnum
    and atdsrvano = d_cts00g02.atdsrvano

 if sqlca.sqlcode < 0  then
    let ws.tabname = "datrservapol"
    let ws.sqlcode = sqlca.sqlcode
    return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
 end if

 # Quando o servico tem apolice
 if sqlca.sqlcode = 0 then
    #PSI205125 - Inicio
    #REALIZAR FASE II
    let ws.ramcod = d_cts00g02.ramcod
    if ws.ciaempcod <> 84 then

       call cty10g00_descricao_ramo(d_cts00g02.ramcod,1)
            returning l_resultado, l_mensagem, ws.ramnom, ws.ramsgl
       #PSI205125 - Fim

       ### PSI 202720
       call cty10g00_grupo_ramo(1, d_cts00g02.ramcod)
            returning l_resultado, l_mensagem, l_grupo
    else
       whenever error continue
          select itaramdes
            into ws.ramnom
            from datkitaram
           where itaramcod = d_cts00g02.ramcod
       whenever error stop
    end if
 end if
 
 if l_grupo = 5 then ## Saude
    call cts20g10_cartao(1, d_cts00g02.atdsrvnum, d_cts00g02.atdsrvano)
         returning l_resultado, l_mensagem, d_cts00g02.crtsaunum

    call cta01m15_sel_datksegsau (3, d_cts00g02.crtsaunum, "","","")
         returning l_resultado, l_mensagem, l_segnom, d_cts00g02.dddcod,
                   d_cts00g02.teltxt
 else

    #---------------------------------------------------------
    # Busca telefone do segurado
    #---------------------------------------------------------

    case ws.ciaempcod
       when 1
          call cts09g00(d_cts00g02.ramcod,
                        d_cts00g02.succod,
                        d_cts00g02.aplnumdig,
                        d_cts00g02.itmnumdig,
                        false)
              returning d_cts00g02.dddcod,
                        d_cts00g02.teltxt

       when 35
          if d_cts00g02.aplnumdig is not null then
              call cts42g00_doc_handle(d_cts00g02.succod, d_cts00g02.ramcod,
                                       d_cts00g02.aplnumdig, d_cts00g02.itmnumdig,
                                       d_cts00g02.edsnumref)
                   returning l_resultado, l_mensagem, l_doc_handle

              call cts40g02_extraiDoXML(l_doc_handle, "FONE_SEGURADO")
                   returning d_cts00g02.dddcod,  d_cts00g02.teltxt

              ---> Busca Limites da Azul
              call cts49g00_clausulas(l_doc_handle)
                   returning l_kmazul, l_qtdeazul

              let l_kmazulint = l_kmazul
              let l_kmazulint = l_kmazulint * 2

              if l_ris then
                 let l_msginicial = "***SERVICO AZUL SEGUROS C/ RIS. EM CASO DE VIAGEM AUTORIZADA PELA CT, LIMITE DE ", l_kmazulint using "<<<#", "KM TOTAIS. COBRAR KM EXCEDENTE DO SEGURADO***"
              else
                 let l_msginicial = "***SERVICO AZUL SEGUROS. EM CASO DE VIAGEM AUTORIZADA PELA CT, LIMITE DE ", l_kmazulint using "<<<#", "KM TOTAIS. COBRAR KM EXCEDENTE DO SEGURADO***"
              end if
            else
              if l_ris then
                 let l_msginicial = "***SERVICO AZUL SEGUROS C/ RIS***"
              else
                 let l_msginicial = "***SERVICO AZUL SEGUROS***"
              end if
          end if
            let l_msgcancela = "***SERVICO CANCELADO ", ws.acnmsgcan clipped, "- AZUL***"

       when 40
            let l_msginicial = "***ATENCAO, SERVICO DO CARTAO DE CREDITO PORTO SEGURO***"

            #---------------------------------------------------------------
            # Dados da ligacao
            #---------------------------------------------------------------
            let ws.lignum = cts20g00_servico(d_cts00g02.atdsrvnum, d_cts00g02.atdsrvano)

            whenever error continue
            open c_cts00g02_005 using ws.lignum

            fetch c_cts00g02_005 into lr_ffpfc073.cgccpfnum ,
                                    lr_ffpfc073.cgcord    ,
                                    lr_ffpfc073.cgccpfdig

            whenever error stop

            let lr_ffpfc073.cgccpfnumdig = ffpfc073_formata_cgccpf(lr_ffpfc073.cgccpfnum ,
                                                                   lr_ffpfc073.cgcord    ,
                                                                   lr_ffpfc073.cgccpfdig )

               call ffpfc073_rec_tel(lr_ffpfc073.cgccpfnumdig,'F')
                     returning d_cts00g02.dddcod ,
                               d_cts00g02.teltxt ,
                               lr_ffpfc073.mens  ,
                               lr_ffpfc073.erro

               if lr_ffpfc073.erro <> 0 then
                   error lr_ffpfc073.mens
               end if

       when 43   #--> PSI-2013-06224/PR
          whenever error continue
          call cts59g00_idt_srv_saps(2, param.atdsrvnum,param.atdsrvano)
               returning l_errcod, l_msginicmdt
          whenever error stop
          
          if l_errcod = 0 and l_msginicmdt is not null
             then
             let l_msginicial = "***", l_msginicmdt clipped, "***"
          end if

       when 84
          if l_ris then
             let l_msginicial = "***SERVICO ITAU AUTO E RESIDENCIA C/ RIS***"
          else
             let l_msginicial = "***SERVICO ITAU AUTO E RESIDENCIA ***"
          end if
          
          open c_cts00g02_013 using d_cts00g02.atdsrvnum, d_cts00g02.atdsrvano
          whenever error continue
          fetch c_cts00g02_013 into g_documento.ramcod,
                                    g_documento.aplnumdig,
                                    g_documento.itmnumdig,
                                    g_documento.edsnumref,
                                    g_documento.itaciacod

          whenever error stop

       if g_documento.ramcod = 531 or g_documento.ramcod = 31 then
          call cty22g00_rec_dados_itau(g_documento.itaciacod,
		   	               g_documento.ramcod   ,
		   	               g_documento.aplnumdig,
		   	               g_documento.edsnumref,
		   	               g_documento.itmnumdig)
               returning lr_retorno.erro,
                         lr_retorno.mensagem

          if lr_retorno.erro = 0 then
              call cty22g00_rec_plano_assistencia(g_doc_itau[1].itaasiplncod)
                                 returning lr_retorno.pansoclmtqtd,
                                           lr_retorno.socqlmqtd,
                                           lr_retorno.erro,
                                           lr_retorno.mensagem

               let l_kmazulint = lr_retorno.socqlmqtd
               let l_kmazulint = l_kmazulint * 2

               let d_cts00g02.dddcod = g_doc_itau[1].segresteldddnum
               let d_cts00g02.teltxt = g_doc_itau[1].segrestelnum
               if l_ris then
                  let l_msginicial = "***SERVICO ITAU AUTO E RESIDENCIA C/ RIS. EM CASO DE VIAGEM AUTORIZADA PELA CT, LIMITE DE ", l_kmazulint using "<<<#"," KM TOTAIS. COBRAR KM EXCEDENTE DO SEGURADO***"
               else
                  let l_msginicial = "***SERVICO ITAU AUTO E RESIDENCIA . EM CASO DE VIAGEM AUTORIZADA PELA CT, LIMITE DE ", l_kmazulint using "<<<#"," KM TOTAIS. COBRAR KM EXCEDENTE DO SEGURADO***"
               end if
          else
             let d_cts00g02.dddcod = 0
             let d_cts00g02.teltxt = 0

          end if
          
       else

	       call cty25g01_rec_dados_itau (g_documento.itaciacod,
	                                     g_documento.ramcod   ,
	                                     g_documento.aplnumdig,
	                                     g_documento.edsnumref,
	                                     g_documento.itmnumdig)

	            returning lr_retorno.erro,
	                      lr_retorno.mensagem

          if lr_retorno.erro = 0 then

             whenever error continue

               select socntzcod
                 into ws.socntzcod
                 from datmsrvre
                where atdsrvnum = d_cts00g02.atdsrvnum
                  and atdsrvano = d_cts00g02.atdsrvano

               select mobrefvlr,
                      pecmaxvlr
                 into l_mobrefvlr,
                      l_pecmaxvlr
                 from dpakpecrefvlr
                where socntzcod = ws.socntzcod
                  and empcod    = ws.ciaempcod
            whenever error stop

             if (l_mobrefvlr is not null or l_mobrefvlr <> '') and
                     (l_pecmaxvlr is not null or l_pecmaxvlr <> '') then

                let d_cts00g02.dddcod = g_doc_itau[1].segresteldddnum
                let d_cts00g02.teltxt = g_doc_itau[1].segrestelnum
                if l_ris then
                   let l_msginicial = "***SERVICO ITAU AUTO E RESIDENCIA C/ RIS. EM CASO DE FORNECIMENTO DE PECAS, LIMITADO AO VALOR DE ", l_pecmaxvlr using "<<<<<<<.<<",". CASO HAJA EXCEDENTE ENTRAR EM CONTATO COM A C.O ***"
                else
                   let l_msginicial = "***SERVICO ITAU AUTO E RESIDENCIA. EM CASO DE FORNECIMENTO DE PECAS, LIMITADO AO VALOR DE ", l_pecmaxvlr using "<<<<<<<.<<",". CASO HAJA EXCEDENTE ENTRAR EM CONTATO COM A C.O ***"
                end if
             else
                 let d_cts00g02.dddcod = 0
                 let d_cts00g02.teltxt = 0
             end if
          else
             let d_cts00g02.dddcod = 0
             let d_cts00g02.teltxt = 0
          end if

          let ws.socntzcod = null
	    end if

	    let l_msgcancela = "***SERVICO CANCELADO ", ws.acnmsgcan clipped, "- ITAU AUTO E RESIDENCIA ***"

    end case

 end if

 #---------------------------------------------------------
 # Descricao do tipo do servico
 #---------------------------------------------------------
 let d_cts00g02.srvtipabvdes = "NAO PREV."

 select srvtipabvdes
   into d_cts00g02.srvtipabvdes
   from datksrvtip
  where atdsrvorg = ws.atdsrvorg

 #---------------------------------------------------------
 # Descricao do tipo de assistencia
 #---------------------------------------------------------
 let d_cts00g02.asitipabvdes = "NAO PREV."

 select asitipabvdes
   into d_cts00g02.asitipabvdes
   from datkasitip
  where asitipcod = ws.asitipcod

 #---------------------------------------------------------
 # Cor do veiculo
 #---------------------------------------------------------
 let ws.cponom         = "vclcorcod"
 let d_cts00g02.vclcordes = "NAO INFORMADA"

 select cpodes
   into d_cts00g02.vclcordes
   from iddkdominio
  where cponom = ws.cponom
    and cpocod = ws.vclcorcod

 #--------------------------------------------------------------
 # Verifica se veiculo e BLINDADO.
 #--------------------------------------------------------------
 call f_funapol_ultima_situacao (d_cts00g02.succod,
                                 d_cts00g02.aplnumdig,
                                 d_cts00g02.itmnumdig)
     returning g_funapol.*
     
 let ws.imsvlr = 0
 select imsvlr
   into ws.imsvlr
   from abbmbli
  where succod    = d_cts00g02.succod    and
        aplnumdig = d_cts00g02.aplnumdig and
        itmnumdig = d_cts00g02.itmnumdig and
        dctnumseq = g_funapol.autsitatu

 initialize ws.imsvlrdes to null
 if ws.imsvlr > 0 then
    let ws.imsvlrdes = "BLINDADO"
 end if

 #-----------------------------------------------------------------------
 # Formata mensagem de: Vistoria Previa
 #-----------------------------------------------------------------------
 if ws.atdsrvorg  =  10    then
    select vstnumdig, vstfld   ,
           corsus   , cornom   ,
           segnom   , vclmrcnom,
           vcltipnom, vclmdlnom,
           vcllicnum, vclchsnum,
           vclanomdl, vclanofbc
      into d_cts00g02.vstnumdig, ws.vstfld           ,
           d_cts00g02.corsus   , d_cts00g02.cornom   ,
           d_cts00g02.segnom   , ws.vclmrcnom        ,
           ws.vcltipnom        , ws.vclmdlnom        ,
           d_cts00g02.vcllicnum, d_cts00g02.vclchsnum,
           d_cts00g02.vclanomdl, d_cts00g02.vclanofbc
      from datmvistoria
     where atdsrvnum = d_cts00g02.atdsrvnum
       and atdsrvano = d_cts00g02.atdsrvano

    if sqlca.sqlcode <> 0  then
       let ws.tabname = "datmvistoria"
       let ws.sqlcode = sqlca.sqlcode
       return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
    end if

    #-------------------------------------------------------------------
    # Envia a linha do historico (se houver)
    #-------------------------------------------------------------------
    initialize ws.c24srvdsc  to null

    declare ccts00g02002 cursor for
      select c24srvdsc   , c24txtseq
        from datmservhist
       where atdsrvnum = d_cts00g02.atdsrvnum
         and atdsrvano = d_cts00g02.atdsrvano
       order by c24txtseq

    open  ccts00g02002
    fetch ccts00g02002 into  ws.c24srvdsc,
                               ws.c24txtseq
    close ccts00g02002

    let ws.cponom            = "vstfld"
    let d_cts00g02.vstflddes = "*** NAO PREVISTA ***"

    select cpodes
      into d_cts00g02.vstflddes
      from iddkdominio
     where cponom = ws.cponom
       and cpocod = ws.vstfld

    if sqlca.sqlcode = 0  then
       let d_cts00g02.vstflddes = upshift(d_cts00g02.vstflddes)
    end if

    #   let d_cts00g02.vcldes = ws.vclmrcnom clipped, " ",
    #                           ws.vcltipnom clipped, " ",
    #                           ws.vclmdlnom
    
    let d_cts00g02.vcldes = ws.vcltipnom clipped," ",ws.imsvlrdes
    if m_desc_veiculo = "MOTO" then
       let d_cts00g02.vcldes = "MOTO ", d_cts00g02.vcldes
    end if

    if d_cts00g02.corsus  is not null   then
       whenever error continue
       select cornom
         into d_cts00g02.cornom
         from gcaksusep, gcakcorr
        where gcaksusep.corsus     = d_cts00g02.corsus
          and gcakcorr.corsuspcp   = gcaksusep.corsuspcp
       whenever error stop
    end if

    if m_veiculo_compl = true then
       let d_cts00g02.vcldes = m_desc_veiculo
    end if

    let ws.laudo = d_cts00g02.srvtipabvdes    clipped, " ",
        #       "Ordem Servico: ",   ws.atdsrvorg               "&&"     , "/",
        #                            d_cts00g02.atdsrvnum using "&&&&&&&", "-",
        #                            d_cts00g02.atdsrvano using "&&",   " ",
        "No. Vistoria: ",    d_cts00g02.vstnumdig using "&&&&&&&&&", " ",
        "Solicitado: ",      d_cts00g02.atddat          clipped, " as ",
                             d_cts00g02.atdhor          clipped, " ",
        "Finalidade: ",      d_cts00g02.vstflddes       clipped, " ",
        "Viatura: ",         d_cts00g02.atdvclsgl       clipped, " ",

        "Corretor: ",        d_cts00g02.corsus          clipped, " ",
                             d_cts00g02.cornom          clipped, " ",

        "Segurado: ",        d_cts00g02.segnom          clipped, " ",
        "QTH: ",             a_cts00g02[1].lgdtxt       clipped, " ",
                             a_cts00g02[1].lclbrrnom    clipped, " ",
                             a_cts00g02[1].cidnom       clipped, " ",

        "Ref: ",             a_cts00g02[1].lclrefptotxt clipped, " ",
        "Procurar por: ",    a_cts00g02[1].lclcttnom    clipped, " ",

        "Veiculo: ",         d_cts00g02.vcldes          clipped, " ",
        "Fabricacao: ",      d_cts00g02.vclanofbc       clipped, " ",
        "Modelo: ",          d_cts00g02.vclanomdl       clipped, " ",
        "Cor: ",             d_cts00g02.vclcordes       clipped, " ",
        "QNR: ",             d_cts00g02.vcllicnum       clipped, " ",
        "Chassi: ",          d_cts00g02.vclchsnum       clipped, " ",
        "Historico: ",       ws.c24srvdsc               clipped,
                             ws.fim clipped
 else
    #Marcelo - psi178381 - inicio
    if ws.atdsrvorg  = 15 then
       call cts00g04_msgjittxt(param.atdsrvnum,
                               param.atdsrvano)
                               returning ws.laudo,
                                         l_status
       if l_status <> 0 then
          error ws.laudo
          sleep 3
          let ws.laudo   = null
          let ws.mdtcod  = null
          let ws.tabname = null
          let ws.sqlcode = null
          return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
       end if
    end if
    #Marcelo - psi178381 - fim

    #CT201201879 Inicio
    if d_cts00g02.atdhorpvt  is not null and
       d_cts00g02.atddatprg is null      and
       d_cts00g02.atdhorprg is null      then
       #CT201201879 Fim

       #=>    PSI.188603 - RECUPERA A DATA E HORA DA ULTIMA ETAPA
       let l_atdprvdat = null
       
       whenever error continue
       select atdetpdat, atdetphor
         into ws.atdetpdat, l_atdprvdat
         from datmsrvacp
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = param.atdsrvnum
                              and atdsrvano = param.atdsrvano)
       whenever error stop
       
       if sqlca.sqlcode <> 0  then
          let ws.tabname = "datmsrvacp"
          let ws.sqlcode = sqlca.sqlcode
          return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
       end if
       
       let ws.atdetphor = l_atdprvdat - l_hour

       #=>    PSI.188603 - SOMAR 'DATA DA ULTIMA ETAPA' A 'PREVISAO DE ATENDIMENTO'
       if d_cts00g02.atdprvdat is null then
          let d_cts00g02.atdprvdat = "00:20"
       end if
       let ws.datahoraqtr = ws.atdetpdat
       let ws.datahoraqtr = ws.datahoraqtr + ws.atdetphor
       let ws.datahoraqtr = ws.datahoraqtr + d_cts00g02.atdprvdat
       #let ws.dispdata    = ws.datahoraqtr
       let ws.disphora    = ws.datahoraqtr

       let ws.msgpvt = "QTR:", extend(ws.datahoraqtr, month to day), " ", ws.disphora
    else
       let ws.msgpvt = "Programado:", d_cts00g02.atddatprg  clipped, " ",
                                      d_cts00g02.atdhorprg
    end if

    case ws.atdrsdflg
       when "S"  let d_cts00g02.atdrsddes = "SIM"
       when "N"  let d_cts00g02.atdrsddes = "NAO"
    end case

    case ws.rmcacpflg
       when "S"  let d_cts00g02.rmcacpdes = "SIM"
       when "N"  let d_cts00g02.rmcacpdes = "NAO"
    end case

    select nomgrr
      into d_cts00g02.nomgrr
      from dpaksocor
     where pstcoddig = ws.atdprscod

    #-----------------------------------
    # Nome Reduzido do Veiculo
    #-----------------------------------
    select vcltipnom
      into ws.vcltipnom
      from agbkveic, outer agbktip
     where agbkveic.vclcoddig  = ws.vclcoddig
       and agbktip.vclmrccod   = agbkveic.vclmrccod
       and agbktip.vcltipcod   = agbkveic.vcltipcod

    if sqlca.sqlcode = 0 then
       let d_cts00g02.vcldes = ws.vcltipnom clipped," ",ws.imsvlrdes
    end if

    if m_desc_veiculo = "MOTO" then
       let d_cts00g02.vcldes = "MOTO ", d_cts00g02.vcldes
    end if

    #PSI205117 - INICIO
    whenever error continue
    open c_cts00g02_003 using param.atdsrvnum, param.atdsrvano
    fetch c_cts00g02_003 into ws.conta
    whenever error stop
    
    if sqlca.sqlcode <> 0 then
            error "Erro ao selecionar endereco mapograf"
            let ws.conta = 0
    end if
    close c_cts00g02_003
    
    if ws.conta = 1 then
            whenever error continue
                    open c_cts00g02_004 using param.atdsrvnum, param.atdsrvano
                    fetch c_cts00g02_004 into ws.pltpgncod, ws.pltcrdcod
            whenever error stop
                    if sqlca.sqlcode <> 0 then
                            error "Erro ao selecionar coordenada mapograf"
                            let ws.pltpgncod = null
                            let ws.pltcrdcod = null
                    end if
            close c_cts00g02_004
    end if
    
    if ws.conta > 1 then
            let ws.pltpgncod = null
            let ws.pltcrdcod = null
    end if
    #PSI205117 - FIM

    #----------------------------------------------------------------------
    # Formata mensagem de: Remocao, DAF, Socorro, RPT, Replace (AUTOMOVEL)
    #----------------------------------------------------------------------
    if ws.atdsrvorg  =   4    or
       ws.atdsrvorg  =   6    or
       ws.atdsrvorg  =   1    or
       ws.atdsrvorg  =   5    or
       ws.atdsrvorg  =   7    or
      (ws.atdsrvorg  =   2    and ws.asitipcod = 5) or
       ws.atdsrvorg  =  17    then

       if d_cts00g02.roddantxt is not null  then
          let ws.campo = ws.campo clipped, "Rodas Danif:", d_cts00g02.roddantxt clipped
       end if

       if d_cts00g02.atddfttxt is not null  then
          if ws.atdsrvorg =  5   or
             ws.atdsrvorg =  7   or
             ws.atdsrvorg = 17   then
          else
             let ws.campo = ws.campo clipped, " Prob:", d_cts00g02.atddfttxt clipped
          end if
       end if

       ## obter local/condicoes do veiculo
       let l_passou = false
       let l_condicao = null

       open c_cts00g02_002 using param.atdsrvnum, param.atdsrvano
       foreach c_cts00g02_002 into ws.vclcndlclcod

               if l_passou = false then
                  let l_passou = true
                  let l_condicao = "LOC/COND.VCL:"
               end if

               call ctc61m03 (1,ws.vclcndlclcod) returning ws.vclcndlcldes

               let l_condicao = l_condicao clipped, "/",
                                ws.vclcndlcldes clipped

       end foreach

       initialize ws.msgpgttxt to null

       select atdetpcod
         into ws.atdetpcod
         from datmsrvacp
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = param.atdsrvnum
                              and atdsrvano = param.atdsrvano)

       #-------------------------------------------------------------------
       # Formata mensagem para servico cancelado
       #-------------------------------------------------------------------
       if ws.atdetpcod = 5   then
          call ctb00g00(param.atdsrvnum, param.atdsrvano,
                        ws.cnldat      , ws.atdfnlhor)
              returning ws.canpgtcod, ws.difcanhor

          if m_veiculo_compl = true then
             let d_cts00g02.vcldes = m_desc_veiculo
          end if

          let ws.laudo = d_cts00g02.atdvclsgl clipped, " ",
                         l_msgcancela clipped, " ",

              "QRU:",    ws.atdsrvorg          using "&&"     ,"/",
                         d_cts00g02.atdsrvnum using "&&&&&&&", "-",
                         d_cts00g02.atdsrvano using "&&",   " ",

                         d_cts00g02.asitipabvdes   clipped, " ",

                         ws.msgpvt                 clipped, " ",

              "Tel:",    "PARA FALAR COM O CLIENTE UTILIZE A URA DE ATENDIMENTO", " ",

                         d_cts00g02.vcldes         clipped, " ",
                         d_cts00g02.vclanomdl      clipped, " ",
              "QNR:",    d_cts00g02.vcllicnum      clipped, " ",
                         d_cts00g02.vclcordes      clipped, " "
          #PSI205117 - inicio
          if ws.pltpgncod is not null and ws.pltcrdcod is not null then
             let ws.laudo = ws.laudo clipped, " ",
                            "Guia:", "Pg.", ws.pltpgncod, "-", ws.pltcrdcod
          end if
          let ws.laudo = ws.laudo clipped, ws.fim
          #PSI205117 - fim

          #-------------------------------------
          #Envia tambem pelo TELETRIM
          #-------------------------------------

          if ws.pgrnum is not null   and
             ws.pgrnum <> 0          then
             #-----------------------------------
             # Acessa nro codigo tabela teletrim
             #-----------------------------------
             select ustcod
               into ws.ustcod
               from htlrust
              where pgrnum = ws.pgrnum

              if sqlca.sqlcode <> 0 then
                 error "PAGER nao cadastrado no sistema TELETRIM !"
              else
                 call cts00g04_env_msgtel(ws.ustcod,
                      "CENTRAL 24H - TRANSMISSAO DE REFERENCIA",
                      ws.laudo,
                      g_issk.funmat,
                      g_issk.empcod,
                      g_issk.maqsgl,
                      0,
                      "O")
                 returning ws.errcod,
                           ws.sqlcod,
                           ws.mstnum
              end if
          end if
       else
          if m_veiculo_compl = true then
             let d_cts00g02.vcldes = m_desc_veiculo
          end if
          
          if ws.ciaempcod = 84 then
             if ws.atdsrvorg <> 2 then
                let ws.laudo = d_cts00g02.atdvclsgl clipped,
                               l_msginicial ## psi 211982
             else
                let ws.laudo = d_cts00g02.atdvclsgl clipped, "***SERVICO ITAU AUTO E RESIDENCIA ."
             end if
          else
             let ws.laudo = d_cts00g02.atdvclsgl clipped,
                            l_msginicial ## psi 211982
          end if
          
          if ws.ramcod is not null then
             let ws.laudo = ws.laudo clipped,
                 "Ramo:", ws.ramcod using "<<<<<&", "-", ws.ramnom
          end if

          #PSI 217587 - Busca o número de passageiros
          initialize l_retnumpassageiros.numpassageiros to null
          initialize l_mensagem_passageiros to null
          if(ws.asitipcod = 5) then
              call ctd22g00_inf_numpassageiros(d_cts00g02.atdsrvnum, d_cts00g02.atdsrvano)
                  returning l_retnumpassageiros.*

              if(l_retnumpassageiros.erro <> 1) then
                  error "Erro ao tentar buscar numero de passageiros para o servico de taxi "
              else
                  if l_retnumpassageiros.numpassageiros > 1 then
                     let l_mensagem_passageiros = l_retnumpassageiros.numpassageiros using "<<<<#", "-PASSAGEIROS "
                  else
                     let l_mensagem_passageiros = l_retnumpassageiros.numpassageiros using "<<<<#", "-PASSAGEIRO "
                  end if
              end if
          end if

          let ws.laudo = ws.laudo clipped, " ",
              "QRU:",    ws.atdsrvorg         using "&&"     , "/",
                         d_cts00g02.atdsrvnum using "&&&&&&&", "-",
                         d_cts00g02.atdsrvano using "&&",   " ",

                         d_cts00g02.asitipabvdes   clipped, " ",

                         #PSI 217587
                         l_mensagem_passageiros clipped, " ",

                         ws.msgpvt                 clipped, " ",

              "QNC:",    d_cts00g02.nom             clipped, " ",
                         d_cts00g02.vcldes          clipped, " ",
                         d_cts00g02.vclanomdl       clipped, " ",

              "QNR:",    d_cts00g02.vcllicnum       clipped, " ",
                         d_cts00g02.vclcordes       clipped, " ",

                         ws.campo                   clipped, " ",

              "QTH:",    a_cts00g02[1].lclidttxt    clipped, " ",
                         a_cts00g02[1].lgdtxt       clipped, "-",
                         a_cts00g02[1].lclbrrnom    clipped, "-",
                         a_cts00g02[1].cidnom       clipped, "-",

                         a_cts00g02[1].ufdcod       clipped, " "
                         
          #PSI205117 - inicio
          if ws.pltpgncod is not null and ws.pltcrdcod is not null then
            let ws.laudo = ws.laudo clipped, " ",
                           "Guia:", "Pg.", ws.pltpgncod, "-", ws.pltcrdcod
          end if
          
          let ws.laudo = ws.laudo clipped, " ",
                         "Ref: ", a_cts00g02[1].lclrefptotxt
          #PSI205117 - fim

          if  d_cts00g02.atdrsddes = "SIM"  then
              let ws.laudo = ws.laudo clipped, " ",
              "Na Res:", d_cts00g02.atdrsddes
          end if

          let ws.laudo = ws.laudo clipped, " ",
          "Resp:",           a_cts00g02[1].lclcttnom    clipped, " ",
          "Tel:",            "PARA FALAR COM O CLIENTE UTILIZE A URA DE ATENDIMENTO", " "                              

          if  d_cts00g02.rmcacpdes = "SIM"  then
              let ws.laudo = ws.laudo clipped, " ",
              "Acomp:", d_cts00g02.rmcacpdes
          end if

          if l_condicao is not null then
             let ws.laudo = ws.laudo clipped, " ", l_condicao
          end if

          if a_cts00g02[2].cidnom is not null  and
             a_cts00g02[2].ufdcod is not null  and
             cts47g00_mesma_cidsed_cid(a_cts00g02[1].cidnom,
                                       a_cts00g02[1].ufdcod,
                                       a_cts00g02[2].cidnom,
                                       a_cts00g02[2].ufdcod) <> 1 then #mesma cidade
             let ws.laudo = ws.laudo clipped, " ",
                 "QTI:", a_cts00g02[2].lclidttxt    clipped, " ",
                         a_cts00g02[2].lgdtxt       clipped, "-",
                         a_cts00g02[2].lclbrrnom    clipped, "-",
                         a_cts00g02[2].cidnom       clipped, "-",
                         a_cts00g02[2].ufdcod
          end if

          if ws.srvprlflg = "S"  then
             let ws.laudo = ws.laudo clipped, " ",
                 "**SERVICO PARTICULAR: PAGTO POR CONTA DO CLIENTE**"
          end if

          let ws.laudo = ws.laudo clipped, ws.fim

          # VERIFICA QUAL A CONTROLADORA DO GPS
          select mdtctrcod into ws.mdtctrcod
            from datkmdt
           where mdtcod = ws.mdtcod

          if ws.mdtctrcod = 2 or ws.mdtctrcod = 3 then
             ## ENVIA COORDENADA PARA MDT PLUS
             select lclltt, lcllgt into ws.lclltt, ws.lcllgt
               from datmlcl
              where atdsrvnum = d_cts00g02.atdsrvnum
                and atdsrvano = d_cts00g02.atdsrvano
                and c24endtip = 1
                and c24lclpdrcod in (3,4,5) # PSI 252891

             if sqlca.sqlcode = 0 then
                let ws.txtlclltt = ws.lclltt using "&&&.&&&&&"
                if ws.lclltt > 0 then
                   let ws.lclltt = ws.txtlclltt[1,3]
                else
                   let ws.lclltt = ws.txtlclltt[1,3]
                   let ws.lclltt = ws.lclltt * -1
                end if
                let ws.txtlclltt = ws.lclltt using "-<<&", ws.txtlclltt[5,9]

                let ws.txtlcllgt = ws.lcllgt using "&&&.&&&&&"
                if ws.lcllgt > 0 then
                   let ws.lcllgt = ws.txtlcllgt[1,3]
                else
                   let ws.lcllgt = ws.txtlcllgt[1,3]
                   let ws.lcllgt = ws.lcllgt * -1
                end if
                let ws.txtlcllgt = ws.lcllgt using "-<<&", ws.txtlcllgt[5,9]

                let ws.laudo = ws.laudo clipped, "|</LO>",ws.txtlclltt clipped, ";" , ws.txtlcllgt

             end if
          end if
       end if
    end if

    #----------------------------------------------------------------------
    # Formata mensagem de: Sinistro, Socorro (RAMOS ELEMENTARES)
    #----------------------------------------------------------------------
    if ws.atdsrvorg  =  9     or
       ws.atdsrvorg  = 13     then

       select orrdat   , orrhor   ,
              socntzcod, sinntzcod,
              lclrsccod
         into d_cts00g02.orrdat, d_cts00g02.orrhor,
              ws.socntzcod     , ws.sinntzcod     ,
              ws.lclrsccod
         from datmsrvre
        where atdsrvnum = d_cts00g02.atdsrvnum
          and atdsrvano = d_cts00g02.atdsrvano

       if sqlca.sqlcode <> 0  then
          let ws.tabname = "datmsrvre"
          let ws.sqlcode = sqlca.sqlcode
          return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
       end if

       if ws.socntzcod is not null  then
          select socntzdes
            into d_cts00g02.ntzdes
            from datksocntz
           where socntzcod = ws.socntzcod

       else
          select sinntzdes
            into d_cts00g02.ntzdes
            from sgaknatur
           where sinramgrp = '4'
             and sinntzcod = ws.sinntzcod
       end if

       if d_cts00g02.atddfttxt is not null  then
          let ws.campo = ws.campo clipped, " Prob:", d_cts00g02.atddfttxt clipped
       end if

       #hpn -- ini
       initialize ws.msgpgttxt to null

       select atdetpcod
         into ws.atdetpcod
         from datmsrvacp
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = param.atdsrvnum
                              and atdsrvano = param.atdsrvano)

       #-------------------------------------------------------------------
       # Formata mensagem para servico cancelado
       #-------------------------------------------------------------------
       call cts29g00_obter_multiplo(1,
                                    param.atdsrvnum,
                                    param.atdsrvano)
            returning ws.resultado,
                      ws.mensagem,
                      al_retorno[1].*,
                      al_retorno[2].*,
                      al_retorno[3].*,
                      al_retorno[4].*,
                      al_retorno[5].*,
                      al_retorno[6].*,
                      al_retorno[7].*,
                      al_retorno[8].*,
                      al_retorno[9].*,
                      al_retorno[10].*

       if ws.resultado = 3 then
          display ws.mensagem clipped
          let ws.tabname = "cts29g00"
          return ws.resultado, ws.mensagem
       end if

       if al_retorno[1].atdmltsrvnum is not null and ws.ciaempcod = 84 then
          let l_limpecas = cts29g00_texto_itau_limite_multiplo(d_cts00g02.atdsrvnum,d_cts00g02.atdsrvano)
          let l_msginicial = "***SERVICO ITAU AUTO E RESIDENCIA. EM CASO DE FORNECIMENTO DE PECAS, LIMITADO AO VALOR ", l_limpecas clipped,". CASO HAJA EXCEDENTE ENTRAR EM CONTATO COM A C.O ***"
          let ws.laudo = d_cts00g02.atdvclsgl clipped,l_msginicial clipped ## psi 211982
       end if

       let ws.laudo = d_cts00g02.atdvclsgl clipped,l_msginicial clipped ## psi 211982

       if l_msginicial is null and ws.ciaempcod = 84 then
          let ws.laudo = d_cts00g02.atdvclsgl clipped, "***SERVICO ITAU AUTO E RESIDENCIA ."
       end if

       if ws.atdetpcod >= 5   then
          if ws.atdetpcod <> 10 then
             let ws.laudo = ws.laudo clipped, " ", l_msgcancela
          end if
       end if

       if ws.ramcod is not null then
          let ws.laudo = ws.laudo clipped, " ",
              "Ramo:", ws.ramcod using "<<<<<&", "-", ws.ramnom clipped
       end if

       let ws.laudo = ws.laudo clipped, " ",
           "QRU:",         ws.atdsrvorg         using "&&"     , "/",
           d_cts00g02.atdsrvnum using "&&&&&&&", "-",
           d_cts00g02.atdsrvano using "&&"," "

       for l_ind = 1 to 10
          if al_retorno[l_ind].atdmltsrvnum is not null then
             let ws.laudo = ws.laudo clipped," ",
                            ws.atdsrvorg using "&&", "/",
                            al_retorno[l_ind].atdmltsrvnum using "&&&&&&&", "-",
                            al_retorno[l_ind].atdmltsrvano using "&&", " "
          end if
       end for

       let ws.laudo = ws.laudo clipped," ",ws.msgpvt clipped, " "

       if ws.atdetpcod = 10  then
           let ws.laudo = ws.laudo clipped," RETORNO"
       end if

       let l_espdes = null

       # --BUSCA A DESCRICAO DA ESPECIALIDADE DO SERVICO
       let l_espdes = cts00g02_busca_especialidade(d_cts00g02.atdsrvnum,
                                                   d_cts00g02.atdsrvano)

       let ws.laudo = ws.laudo clipped, " ",

       "QNC:",         d_cts00g02.nom             clipped

       ###           "Solicitado: ", d_cts00g02.atddat          clipped, " as ",
       ###                           d_cts00g02.atdhor          clipped, " ",

       # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
       if l_espdes is not null and
          l_espdes <> " " then
          let ws.laudo = ws.laudo clipped,
                         " ", "Natureza:",
                         d_cts00g02.ntzdes clipped, " - ", l_espdes clipped, " "
       else
          let ws.laudo = ws.laudo clipped,
                         " ", "Natureza:",
                         d_cts00g02.ntzdes clipped, " "
       end if

       for l_ind = 1 to 10
          if al_retorno[l_ind].atdmltsrvnum is not null then
  
             let l_espdes = null
  
             # --BUSCA A DESCRICAO DA ESPECIALIDADE DO SERVICO
             let l_espdes = cts00g02_busca_especialidade(al_retorno[l_ind].atdmltsrvnum,
                                                         al_retorno[l_ind].atdmltsrvano)
  
             # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
             if l_espdes is not null and
                l_espdes <> " " then
                let ws.laudo = ws.laudo clipped, ' / ',
                               al_retorno[l_ind].socntzdes clipped, " - ",
                               l_espdes
             else
                let ws.laudo = ws.laudo clipped, ' / ',
                               al_retorno[l_ind].socntzdes
             end if
  
          end if
       end for
  
       let ws.laudo = ws.laudo clipped, " ",  ws.campo clipped, " "
  
       for l_ind = 1 to 10
         if al_retorno[l_ind].atdmltsrvnum is not null then
            let ws.laudo = ws.laudo clipped, ' / ', al_retorno[l_ind].atddfttxt
         end if
       end for

       let ws.laudo = ws.laudo clipped, " ",
       "QTH:",         a_cts00g02[1].lclidttxt    clipped, " ",
                       a_cts00g02[1].lgdtxt       clipped, "-",
                       a_cts00g02[1].lclbrrnom    clipped, "-",
                       a_cts00g02[1].cidnom       clipped, "-",
                       a_cts00g02[1].ufdcod       clipped, " ",

       "Resp:",        a_cts00g02[1].lclcttnom    clipped, " ",
       "Tel:",         "PARA FALAR COM O CLIENTE UTILIZE A URA DE ATENDIMENTO", " "
                      
       #PSI205117 - inicio
         if ws.pltpgncod is not null and ws.pltcrdcod is not null then
                 let ws.laudo = ws.laudo clipped, " ",
                 "Guia:", "Pg.", ws.pltpgncod, "-", ws.pltcrdcod
         end if
         let ws.laudo = ws.laudo clipped, " ",
                        "Ref:", a_cts00g02[1].lclrefptotxt clipped, ws.fim
       #PSI205117 - fim

    end if
 end if

 let ws.sqlcode = 0

 return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode

end function  ###  cts00g02_laudo

#--------------------------------------------------------------------------#
 function cts00g02_sms(param)
#--------------------------------------------------------------------------#

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record

 define d_cts00g02    record
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    srvtipabvdes      like datksrvtip.srvtipabvdes ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    c24opemat         like datmservico.c24opemat   ,
    rmcacpdes         char (03)                    ,
    atdrsddes         char (03)                    ,
    atdlclflg         like datmservico.atdlclflg   ,
    nom               like datmservico.nom         ,
    dddcod            like gsakend.dddcod          ,
    teltxt            like gsakend.teltxt          ,
    vcldes            like datmservico.vcldes      ,
    vclcordes         char (20)                    ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    bocflg            like datmservicocmp.bocflg   ,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    atddfttxt         like datmservico.atddfttxt   ,
    roddantxt         like datmservicocmp.roddantxt,
    nomgrr            like dpaksocor.nomgrr        ,
    atdmotnom         like datmservico.atdmotnom   ,
    atdvclsgl         like datmservico.atdvclsgl   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atdprvdat         interval hour to minute,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    ramcod            like datrservapol.ramcod     ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,

    ntzdes            like datksocntz.socntzdes    ,
    orrdat            like datmsrvre.orrdat        ,
    orrhor            like datmsrvre.orrhor        ,

    vstnumdig         like datmvistoria.vstnumdig  ,
    vstflddes         char (30)                    ,
    corsus            like datmvistoria.corsus     ,
    cornom            like datmvistoria.cornom     ,
    segnom            like datmvistoria.segnom     ,
    vclchsnum         like datmvistoria.vclchsnum  ,
    vclanofbc         like datmvistoria.vclanofbc,
    crtsaunum         like datrligsau.crtnum     ,
    edsnumref         like datrservapol.edsnumref
 end record

 define a_cts00g02    array[2] of record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtxt           char (65),
    lclbrrnom        like datmlcl.lclbrrnom,
    endzon           like datmlcl.endzon,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom
 end record

 define ws            record
    campo             char (40)                    ,
    msgpvt            char (40)                    ,
    fim               char (03)                    ,
    cponom            like iddkdominio.cponom      ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    asitipcod         like datmservico.asitipcod   ,
    atdprscod         like datmservico.atdprscod   ,
    vclcorcod         like datmservico.vclcorcod   ,
    atdrsdflg         like datmservico.atdrsdflg   ,
    rmcacpflg         like datmservicocmp.rmcacpflg,
    c24srvdsc         like datmservhist.c24srvdsc  ,
    c24txtseq         like datmservhist.c24txtseq  ,
    vstfld            like datmvistoria.vstfld     ,
    vclmrcnom         like datmvistoria.vclmrcnom  ,
    vcltipnom         like datmvistoria.vcltipnom  ,
    vclmdlnom         like datmvistoria.vclmdlnom  ,
    lclrsccod         like datmsrvre.lclrsccod     ,
    socntzcod         like datmsrvre.socntzcod     ,
    sinntzcod         like datmsrvre.sinntzcod     ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    srvprlflg         like datmservico.srvprlflg   ,
    mdtcod            like datkveiculo.mdtcod      ,
    pgrnum            like datkveiculo.pgrnum      ,
    ustcod            like htlrust.ustcod          ,
    canpgtcod         dec (1,0)                    ,
    difcanhor         datetime hour to minute      ,
    msgpgttxt         char (50)                    ,
    tabname           like systables.tabname       ,
    sqlcode           integer                      ,
    laudo             char (4000)                  ,
    vclcoddig         like datmservico.vclcoddig   ,
    errcod            integer                      ,
    sqlcod            integer                      ,
    mstnum            integer                      ,
    imsvlr            like abbmcasco.imsvlr        ,
    imsvlrdes         char (08)                    ,
    atdetpdat         like datmsrvacp.atdetpdat    , #=> PSI.188603
    atdetphor         interval hour to minute      , #=> PSI.188603
    datahoraqtr       datetime year to minute      , #=> PSI.188603
    dispdata          date                         , #=> PSI.188603
    disphora          datetime hour to minute,        #=> PSI.188603
    mensagem          char (80),
    resultado         smallint,
    vclcndlclcod    like datrcndlclsrv.vclcndlclcod,
    vclcndlcldes    like datkvclcndlcl.vclcndlcldes,
    ramcod          like gtakram.ramcod,
    ramnom          like gtakram.ramnom,
    ramsgl          like gtakram.ramsgl,
    ciaempcod       like datmservico.ciaempcod,
    empnom          like gabkemp.empnom,
    pltpgncod       like dpatmpgcrg.pltpgncod, #=> PSI205117
    pltcrdcod       like dpatmpgcrg.pltcrdcod, #=> PSI205117
    conta           smallint , #PSI205117
    lignum          like datrligsrv.lignum,

    lclltt          like datmlcl.lclltt,
    lcllgt          like datmlcl.lcllgt,
    mdtctrcod       like datkmdt.mdtctrcod,
    txtlclltt       char(20),
    txtlcllgt       char(20),
    lgdtip          like datmlcl.lgdtip,
    lgdnom          like datmlcl.lgdnom,
    lgdnum          like datmlcl.lgdnum,
    endcmp          like datmlcl.endcmp,
    brrnom          like datmlcl.brrnom,
    lgdcep          like datmlcl.lgdcep,
    lgdcepcmp       like datmlcl.lgdcepcmp,
    c24lclpdrcod    like datmlcl.c24lclpdrcod 

 end record

 define l_ind        smallint,
        l_passou     smallint,
        l_condicao   char(200)

 define al_retorno   array[10] of record
        atdmltsrvnum like datratdmltsrv.atdmltsrvnum,
        atdmltsrvano like datratdmltsrv.atdmltsrvano,
        socntzdes    like datksocntz.socntzdes,
        espdes       like dbskesp.espdes,
        atddfttxt    like datmservico.atddfttxt
 end record

define lr_ffpfc073 record
       cgccpfnumdig char(18) ,
       cgccpfnum    char(12) ,
       cgcord       char(4)  ,
       cgccpfdig    char(2)  ,
       mens         char(50) ,
       erro         smallint
end record


 define l_status      smallint,
        l_atdprvdat   like datmservico.atdprvdat,
        l_hour        datetime hour to minute,
        l_espdes      like dbskesp.espdes,
        l_lgdnum      char(06)

  define l_resultado   smallint,
        l_mensagem    char(100),
        l_segnom      like gsakseg.segnom,
        l_grupo       like gtakram.ramgrpcod,
        l_documento   char(200),
        l_doc_handle  integer,
        l_data_atual  date,
        l_hora_atual  datetime hour to minute,
        l_ctgtrfcod   like datrctggch.ctgtrfcod,
        l_msginicial  char(150),
        l_msginicmdt  char(150),    #--> PSI-2013-06224/PR
        l_errcod      integer  ,
        l_msgcancela  char(150),
        l_kmazul      char(3),
        l_qtdeazul    char(3),
        l_kmazulint   integer

  define l_retnumpassageiros record
          erro           smallint                   ,
          mensagem       char(100)                  ,
          numpassageiros like datmpassageiro.passeq
  end record

  define lr_retorno record
     pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
     socqlmqtd     like datkitaasipln.socqlmqtd    ,
     erro          integer,
     mensagem      char(50)
  end record


  define l_mensagem_passageiros char(100)

  define l_limpecas char(50),
         l_mobrefvlr like dpakpecrefvlr.mobrefvlr,
         l_pecmaxvlr like dpakpecrefvlr.pecmaxvlr

  define  w_pf1   integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let l_ind        = null
        let l_status     = null
        let l_atdprvdat  = null
        let l_hour       = null
        let l_espdes     = null
        let w_pf1        = null
        let l_data_atual = null
        let l_hora_atual = null
        let l_resultado  = null
        let l_ctgtrfcod  = null
        let l_msginicial = ""
        let l_msginicmdt = ""   #--> PSI-2013-06224/PR
        let l_msgcancela = ""
        let l_kmazul     = null
        let l_kmazulint  = 0
        let l_qtdeazul   = null
        let l_limpecas   = null
        let l_lgdnum     = null

        if m_cts00g02_prep is null or
           m_cts00g02_prep <> true then
           call cts00g02_prepare()
        end if


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  2
                initialize  a_cts00g02[w_pf1].*  to  null
        end     for

        for     w_pf1  =  1  to  10
                initialize  al_retorno[w_pf1].*  to  null
        end     for

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_cts00g02.*  to null

        initialize  ws.*          to null
        initialize  lr_ffpfc073.* to null
        initialize  lr_retorno.*  to null

  for     w_pf1  =  1  to  2
          initialize  a_cts00g02[w_pf1].*  to  null
  end     for

  initialize  d_cts00g02.*  to  null

  initialize  ws.*  to  null
  initialize l_errcod to null

 let l_atdprvdat = null
 let l_hour      = "00:00"
 let l_doc_handle = null

 initialize d_cts00g02.*  to null
 initialize a_cts00g02    to null
 initialize ws.*          to null
 let ws.fim  =  "#"

 let l_resultado   = null
 let l_mensagem    = null
 let l_segnom      = null
 let l_grupo       = null
 let l_documento   = null

 select datmservico.atdsrvnum,
        datmservico.atdsrvano,
        datmservico.vclcorcod,
        datmservico.c24opemat,
        datmservicocmp.rmcacpflg,
        datmservico.srvprlflg,
        datmservico.atdlclflg,
        datmservico.atdsrvorg,
        datmservico.asitipcod,
        datmservico.atdrsdflg,
        datmservico.nom,
        datmservico.vcldes,
        datmservico.vclanomdl,
        datmservico.vcllicnum,
        datmservicocmp.bocflg,
        datmservicocmp.bocnum,
        datmservicocmp.bocemi,
        datmservico.atddfttxt,
        datmservicocmp.roddantxt,
        datmservico.atdprscod,
        datmservico.atdmotnom,
        datmservico.atddat,
        datmservico.atdhor,
        datmservico.atdhorpvt,
        datmservico.atdprvdat,
        datmservico.atddatprg,
        datmservico.atdhorprg,
        datmservico.cnldat,
        datmservico.atdfnlhor,
        datmservico.vclcoddig,
        datmservico.ciaempcod
   into d_cts00g02.atdsrvnum,
        d_cts00g02.atdsrvano,
        ws.vclcorcod,
        d_cts00g02.c24opemat,
        ws.rmcacpflg,
        ws.srvprlflg,
        d_cts00g02.atdlclflg,
        ws.atdsrvorg,
        ws.asitipcod,
        ws.atdrsdflg,
        d_cts00g02.nom,
        d_cts00g02.vcldes,
        d_cts00g02.vclanomdl,
        d_cts00g02.vcllicnum,
        d_cts00g02.bocflg,
        d_cts00g02.bocnum,
        d_cts00g02.bocemi,
        d_cts00g02.atddfttxt,
        d_cts00g02.roddantxt,
        ws.atdprscod,
        d_cts00g02.atdmotnom,
        d_cts00g02.atddat,
        d_cts00g02.atdhor,
        d_cts00g02.atdhorpvt,
        l_atdprvdat,
        d_cts00g02.atddatprg,
        d_cts00g02.atdhorprg,
        ws.cnldat,
        ws.atdfnlhor,
        ws.vclcoddig,
        ws.ciaempcod
   from datmservico, outer datmservicocmp
  where datmservico.atdsrvnum    = param.atdsrvnum
    and datmservico.atdsrvano    = param.atdsrvano
    and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
    and datmservicocmp.atdsrvano = datmservico.atdsrvano

 if sqlca.sqlcode <> 0  then
    let ws.tabname = "datmservico"
    let ws.sqlcode = sqlca.sqlcode

    return ws.laudo, ws.tabname, ws.sqlcode
 end if

 #------------------------------
 # BUSCAR A DATA E HORA DO BANCO
 #------------------------------
 call cts40g03_data_hora_banco(2)
      returning l_data_atual,
                l_hora_atual

 if ws.atdsrvorg <> 9 then

    #--------------------------------------
    # OBTER O CODIGO DA CATEGORIA TARIFARIA
    #--------------------------------------
    call cty05g03_pesq_catgtf(ws.vclcoddig,
                              l_data_atual)
         returning l_resultado,
                   l_mensagem,
                   l_ctgtrfcod

    if l_resultado <> 0 then
       if l_resultado = 1 then
          error "Categoria tarifaria nao encontrada, veiculo: ",
                ws.vclcoddig sleep 2
       else
          error "Erro de acesso a banco na funcao cty05g03_pesq_catgtf()" sleep 2
       end if
    end if
 end if

 let m_veiculo_compl = false # NAO ENVIAR A DESCRICAO COMPLETA DO VEICULO
 let m_desc_veiculo  = null

 # -> VERIFICA SE A CATEGORIA TARIFARIA CORRESPONDE A CAMINHAO
 call cts02m01_ctgtrfcod(l_ctgtrfcod)
      returning m_caminhao
 {if l_ctgtrfcod = 40 or
    l_ctgtrfcod = 41 or
    l_ctgtrfcod = 42 or
    l_ctgtrfcod = 43 or
    l_ctgtrfcod = 50 or
    l_ctgtrfcod = 51 or
    l_ctgtrfcod = 52 or
    l_ctgtrfcod = 43 then}
 if m_caminhao = "S" then

    # -> CONFORME SOLICITACAO DO CESAR(GUILHERME) DO RADIO, QUANDO O VEICULO
    #    FOR CAMINHAO, ENVIAR A DESCRICAO COMPLETA NA MENSAGEM MDT.
    #    DATA: 04/12/2006
    #    CHAMADO: 6116004
    #    AUTOR: LUCAS SCHEID

    let m_veiculo_compl = true # ENVIAR A DESCRICAO COMPLETA DO VEICULO
    let m_desc_veiculo  = d_cts00g02.vcldes

 end if

 if l_ctgtrfcod = 30 or l_ctgtrfcod = 31 then  ### MOTO
    let m_desc_veiculo = "MOTO"
 end if

 call cty14g00_empresa(1, ws.ciaempcod)
      returning l_resultado, l_mensagem, ws.empnom

 let l_msginicial = "***SERVICO PORTO***"
 let l_msgcancela = "***SERVICO CANCELADO - PORTO***"

 let d_cts00g02.atdprvdat = l_atdprvdat - l_hour

 #call ctx04g00_local_reduzido(param.atdsrvnum, param.atdsrvano, 1)
 #    returning a_cts00g02[1].lclidttxt thru a_cts00g02[1].lclcttnom,ws.sqlcode
     
     
 call ctx04g00_local_completo(param.atdsrvnum, param.atdsrvano, 1)    
                          returning a_cts00g02[1].lclidttxt   ,      
                                    ws.lgdtip      ,      
                                    ws.lgdnom      ,      
                                    ws.lgdnum      ,      
                                    a_cts00g02[1].lclbrrnom   ,      
                                    ws.brrnom      ,      
                                    a_cts00g02[1].cidnom      ,      
                                    a_cts00g02[1].ufdcod      ,      
                                    a_cts00g02[1].lclrefptotxt,      
                                    a_cts00g02[1].endzon      ,      
                                    ws.lgdcep      ,      
                                    ws.lgdcepcmp   ,      
                                    a_cts00g02[1].dddcod      ,      
                                    a_cts00g02[1].lcltelnum   ,      
                                    a_cts00g02[1].lclcttnom   ,      
                                    ws.c24lclpdrcod,      
                                    ws.sqlcode,                      
                                    ws.endcmp    
     
     
 if ws.sqlcode <> 0  then
    let ws.tabname = "datmlcl"
    return ws.laudo, ws.tabname, ws.sqlcode
 end if
 
 let l_lgdnum = ws.lgdnum using "<<<<#"
 
 ##verifica se servico possui controle de seguranca                                               
 if cty28g00_controla_mecanismo_seguranca(param.atdsrvnum, param.atdsrvano,ws.ciaempcod) then
    if ws.lgdnum is not null then     
       if ws.lgdnum >= 1000  then
          let l_lgdnum = l_lgdnum[1,2] clipped, "XX"
       else 
         if ws.lgdnum >= 100 then
             let l_lgdnum = l_lgdnum[1,1] clipped, "XX"  	  
         else  	     
            let l_lgdnum = "XX"    	     	
         end if
       end if    
    end if 
 end if
 
 let a_cts00g02[1].lgdtxt       = ws.lgdtip clipped, " ",             
                                  ws.lgdnom clipped, " ", 
                                  l_lgdnum  clipped, " ",       
                                  ws.endcmp clipped                   

 
 
 # PSI 244589 - Inclusão de Sub-Bairro - Burini                 
 call cts06g10_monta_brr_subbrr(ws.brrnom,           
                               a_cts00g02[1].lclbrrnom)        
     returning a_cts00g02[1].lclbrrnom  
 

 call ctx04g00_local_reduzido(param.atdsrvnum, param.atdsrvano, 2)
     returning a_cts00g02[2].lclidttxt thru a_cts00g02[2].lclcttnom,ws.sqlcode

 if ws.sqlcode < 0  then
    let ws.tabname = "datmlcl"
    return ws.laudo, ws.tabname, ws.sqlcode
 end if

 #---------------------------------------------------------
 # Identificando cod ramo e descricao
 #---------------------------------------------------------
 #PSI205125 - Inicio
 #open ccts00g02004 using param.atdsrvnum, param.atdsrvano
 #fetch ccts00g02004 into ws.ramcod, ws.ramnom
 #close ccts00g02004
 #PSI205125 - Fim


 #---------------------------------------------------------
 # Sigla/MDT do veiculo
 #---------------------------------------------------------
 #select atdvclsgl, mdtcod, pgrnum
 #  into d_cts00g02.atdvclsgl, ws.mdtcod, ws.pgrnum
 #  from datkveiculo
 # where socvclcod = param.socvclcod
 #
 #if sqlca.sqlcode <> 0  then
 #   let ws.tabname = "datkveiculo"
 #   let ws.sqlcode = sqlca.sqlcode
 #   return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
 #end if

 #---------------------------------------------------------
 # Apolice do servico
 #---------------------------------------------------------
 select ramcod,
        succod,
        aplnumdig,
        itmnumdig,
        edsnumref
   into d_cts00g02.ramcod,
        d_cts00g02.succod,
        d_cts00g02.aplnumdig,
        d_cts00g02.itmnumdig,
        d_cts00g02.edsnumref
   from datrservapol
  where atdsrvnum = d_cts00g02.atdsrvnum
    and atdsrvano = d_cts00g02.atdsrvano

 if sqlca.sqlcode < 0  then
    let ws.tabname = "datrservapol"
    let ws.sqlcode = sqlca.sqlcode
    return ws.laudo, ws.tabname, ws.sqlcode
 end if

 # Quando o servico tem apolice
 if sqlca.sqlcode = 0 then

    #REALISAR FASE II
    if ws.ciaempcod <> 84 then
       #PSI205125 - Inicio
       let ws.ramcod = d_cts00g02.ramcod
       call cty10g00_descricao_ramo(d_cts00g02.ramcod,1)
            returning l_resultado, l_mensagem, ws.ramnom, ws.ramsgl
       #PSI205125 - Fim

       ### PSI 202720
       call cty10g00_grupo_ramo(1, d_cts00g02.ramcod)
            returning l_resultado, l_mensagem, l_grupo
    else
       whenever error continue
          if d_cts00g02.ramcod is not null then
             select itaramdes
               into ws.ramnom
               from datkitaram
              where itaramcod = d_cts00g02.ramcod
          end if
       whenever error stop

    end if

 end if

 if l_grupo = 5 then ## Saude
    call cts20g10_cartao(1, d_cts00g02.atdsrvnum, d_cts00g02.atdsrvano)
         returning l_resultado, l_mensagem, d_cts00g02.crtsaunum

    call cta01m15_sel_datksegsau (3, d_cts00g02.crtsaunum, "","","")
         returning l_resultado, l_mensagem, l_segnom, d_cts00g02.dddcod,
                   d_cts00g02.teltxt
 else

    #---------------------------------------------------------
    # Busca telefone do segurado
    #---------------------------------------------------------
    case ws.ciaempcod
       when 1
          call cts09g00(d_cts00g02.ramcod,
                        d_cts00g02.succod,
                        d_cts00g02.aplnumdig,
                        d_cts00g02.itmnumdig,
                        false)
              returning d_cts00g02.dddcod,
                        d_cts00g02.teltxt

       when 35
          if d_cts00g02.aplnumdig is not null then
              call cts42g00_doc_handle(d_cts00g02.succod, d_cts00g02.ramcod,
                                       d_cts00g02.aplnumdig, d_cts00g02.itmnumdig,
                                       d_cts00g02.edsnumref)
                   returning l_resultado, l_mensagem, l_doc_handle

              call cts40g02_extraiDoXML(l_doc_handle, "FONE_SEGURADO")
                   returning d_cts00g02.dddcod,  d_cts00g02.teltxt


              ---> Busca Limites da Azul
              call cts49g00_clausulas(l_doc_handle)
                   returning l_kmazul, l_qtdeazul

              let l_kmazulint = l_kmazul
              let l_kmazulint = l_kmazulint * 2

              let l_msginicial = "***SERVICO AZUL SEGUROS. EM CASO DE VIAGEM AUTORIZADA PELA CT, LIMITE DE ", l_kmazulint using "<<<#", "KM TOTAIS. COBRAR KM EXCEDENTE DO SEGURADO***"
            else
               let l_msginicial = "***SERVICO AZUL SEGUROS***"
            end if
            let l_msgcancela = "***SERVICO CANCELADO - AZUL***"

       when 40
            let l_msginicial = "***ATENCAO, SERVICO DO CARTAO DE CREDITO PORTO SEGURO***"

            #---------------------------------------------------------------
            # Dados da ligacao
            #---------------------------------------------------------------
            let ws.lignum = cts20g00_servico(d_cts00g02.atdsrvnum, d_cts00g02.atdsrvano)

            whenever error continue
            open c_cts00g02_005 using ws.lignum

            fetch c_cts00g02_005 into lr_ffpfc073.cgccpfnum ,
                                    lr_ffpfc073.cgcord    ,
                                    lr_ffpfc073.cgccpfdig

            whenever error stop

            let lr_ffpfc073.cgccpfnumdig = ffpfc073_formata_cgccpf(lr_ffpfc073.cgccpfnum ,
                                                                   lr_ffpfc073.cgcord    ,
                                                                   lr_ffpfc073.cgccpfdig )

               call ffpfc073_rec_tel(lr_ffpfc073.cgccpfnumdig,'F')
                     returning d_cts00g02.dddcod ,
                               d_cts00g02.teltxt ,
                               lr_ffpfc073.mens  ,
                               lr_ffpfc073.erro

               if lr_ffpfc073.erro <> 0 then
                   error lr_ffpfc073.mens
               end if

      when 43   #--> PSI-2013-06224/PR
         whenever error continue
         call cts59g00_idt_srv_saps(2, param.atdsrvnum,param.atdsrvano)
              returning l_errcod, l_msginicmdt
         whenever error stop
         
         if l_errcod = 0 and l_msginicmdt is not null
            then
            let l_msginicial = "***", l_msginicmdt clipped, "***"
         end if
          
      when 84
        let l_msginicial = "***SERVICO ITAU AUTO E RESIDENCIA ***"

        open c_cts00g02_013 using d_cts00g02.atdsrvnum, d_cts00g02.atdsrvano
        whenever error continue
        fetch c_cts00g02_013 into g_documento.ramcod,
                                  g_documento.aplnumdig,
                                  g_documento.itmnumdig,
                                  g_documento.edsnumref,
                                  g_documento.itaciacod

        whenever error stop

        if g_documento.ramcod = 531 or g_documento.ramcod = 31 then
            call cty22g00_rec_dados_itau(g_documento.itaciacod,
			                                   g_documento.ramcod   ,
			                                   g_documento.aplnumdig,
			                                   g_documento.edsnumref,
			                                   g_documento.itmnumdig)
	           returning lr_retorno.erro,
	                     lr_retorno.mensagem

	        if lr_retorno.erro = 0 then


	             call cty22g00_rec_plano_assistencia(g_doc_itau[1].itaasiplncod)
                                  returning lr_retorno.pansoclmtqtd,
                                            lr_retorno.socqlmqtd,
                                            lr_retorno.erro,
                                            lr_retorno.mensagem

	             let l_kmazulint = lr_retorno.socqlmqtd
	             let l_kmazulint = l_kmazulint * 2

	             let d_cts00g02.dddcod = g_doc_itau[1].segresteldddnum
	             let d_cts00g02.teltxt = g_doc_itau[1].segrestelnum
	             let l_msginicial = "***SERVICO ITAU AUTO E RESIDENCIA . EM CASO DE VIAGEM AUTORIZADA PELA CT, LIMITE DE ", l_kmazulint using "<<<#"," KM TOTAIS. COBRAR KM EXCEDENTE DO SEGURADO***"
	        else
	           let d_cts00g02.dddcod = 0
             let d_cts00g02.teltxt = 0
	        end if
	      else

	          call cty25g01_rec_dados_itau (g_documento.itaciacod,
	                                        g_documento.ramcod   ,
	                                        g_documento.aplnumdig,
	                                        g_documento.edsnumref,
	                                        g_documento.itmnumdig)

	            returning lr_retorno.erro,
	                      lr_retorno.mensagem

	        if lr_retorno.erro = 0 then

	            whenever error continue

                select socntzcod
                  into ws.socntzcod
                  from datmsrvre
                 where atdsrvnum = d_cts00g02.atdsrvnum
                   and atdsrvano = d_cts00g02.atdsrvano

                select mobrefvlr,
                       pecmaxvlr
                  into l_mobrefvlr,
                       l_pecmaxvlr
                  from dpakpecrefvlr
                 where socntzcod = ws.socntzcod
                   and empcod    = ws.ciaempcod
             whenever error stop

	           if (l_mobrefvlr is not null or l_mobrefvlr <> '') and
                (l_pecmaxvlr is not null or l_pecmaxvlr <> '') then

	               let d_cts00g02.dddcod = g_doc_itau[1].segresteldddnum
	               let d_cts00g02.teltxt = g_doc_itau[1].segrestelnum
	               let l_msginicial = "***SERVICO ITAU AUTO E RESIDENCIA . EM CASO DE FORNECIMENTO DE PECAS, LIMITADO AO VALOR DE ", l_pecmaxvlr using "<<<<<<<.<<"," . CASO HAJA EXCEDENTE ENTRAR EM CONTATO COM A C.O ***"
	            else
	               let d_cts00g02.dddcod = 0
	               let d_cts00g02.teltxt = 0
	            end if
	        else
	          let d_cts00g02.dddcod = 0
	          let d_cts00g02.teltxt = 0
	        end if
	         let ws.socntzcod = null

	      end if

	  let l_msgcancela = "***SERVICO CANCELADO - ITAÚ AUTO E RESIDÊNCIA ***"

    end case
 end if

 #---------------------------------------------------------
 # Descricao do tipo do servico
 #---------------------------------------------------------
 let d_cts00g02.srvtipabvdes = "NAO PREV."

 select srvtipabvdes
   into d_cts00g02.srvtipabvdes
   from datksrvtip
  where atdsrvorg = ws.atdsrvorg

 #---------------------------------------------------------
 # Descricao do tipo de assistencia
 #---------------------------------------------------------
 let d_cts00g02.asitipabvdes = "NAO PREV."

 select asitipabvdes
   into d_cts00g02.asitipabvdes
   from datkasitip
  where asitipcod = ws.asitipcod

 #---------------------------------------------------------
 # Cor do veiculo
 #---------------------------------------------------------
 let ws.cponom         = "vclcorcod"
 let d_cts00g02.vclcordes = "NAO INFORMADA"

 select cpodes
   into d_cts00g02.vclcordes
   from iddkdominio
  where cponom = ws.cponom
    and cpocod = ws.vclcorcod

 #--------------------------------------------------------------
 # Verifica se veiculo e BLINDADO.
 #--------------------------------------------------------------
 call f_funapol_ultima_situacao (d_cts00g02.succod,
                                 d_cts00g02.aplnumdig,
                                 d_cts00g02.itmnumdig)
     returning g_funapol.*
 let ws.imsvlr = 0
 select imsvlr
   into ws.imsvlr
   from abbmbli
  where succod    = d_cts00g02.succod    and
        aplnumdig = d_cts00g02.aplnumdig and
        itmnumdig = d_cts00g02.itmnumdig and
        dctnumseq = g_funapol.autsitatu

 initialize ws.imsvlrdes to null
 if ws.imsvlr > 0 then
    let ws.imsvlrdes = "BLINDADO"
 end if

 #-----------------------------------------------------------------------
 # Formata mensagem de: Vistoria Previa
 #-----------------------------------------------------------------------
 if ws.atdsrvorg  =  10    then
    select vstnumdig, vstfld   ,
           corsus   , cornom   ,
           segnom   , vclmrcnom,
           vcltipnom, vclmdlnom,
           vcllicnum, vclchsnum,
           vclanomdl, vclanofbc
      into d_cts00g02.vstnumdig, ws.vstfld           ,
           d_cts00g02.corsus   , d_cts00g02.cornom   ,
           d_cts00g02.segnom   , ws.vclmrcnom        ,
           ws.vcltipnom        , ws.vclmdlnom        ,
           d_cts00g02.vcllicnum, d_cts00g02.vclchsnum,
           d_cts00g02.vclanomdl, d_cts00g02.vclanofbc
      from datmvistoria
     where atdsrvnum = d_cts00g02.atdsrvnum
       and atdsrvano = d_cts00g02.atdsrvano

    if sqlca.sqlcode <> 0  then
       let ws.tabname = "datmvistoria"
       let ws.sqlcode = sqlca.sqlcode
       return ws.laudo, ws.tabname, ws.sqlcode
    end if

    #-------------------------------------------------------------------
    # Envia a linha do historico (se houver)
    #-------------------------------------------------------------------
    initialize ws.c24srvdsc  to null

    declare ccts00g02002a cursor for
      select c24srvdsc   , c24txtseq
        from datmservhist
       where atdsrvnum = d_cts00g02.atdsrvnum
         and atdsrvano = d_cts00g02.atdsrvano
       order by c24txtseq

    open  ccts00g02002a
    fetch ccts00g02002a into  ws.c24srvdsc,
                               ws.c24txtseq
    close ccts00g02002a

    let ws.cponom            = "vstfld"
    let d_cts00g02.vstflddes = "*** NAO PREVISTA ***"

    select cpodes
      into d_cts00g02.vstflddes
      from iddkdominio
     where cponom = ws.cponom
       and cpocod = ws.vstfld

    if sqlca.sqlcode = 0  then
       let d_cts00g02.vstflddes = upshift(d_cts00g02.vstflddes)
    end if

#   let d_cts00g02.vcldes = ws.vclmrcnom clipped, " ",
#                           ws.vcltipnom clipped, " ",
#                           ws.vclmdlnom
    let d_cts00g02.vcldes = ws.vcltipnom clipped," ",ws.imsvlrdes
    if m_desc_veiculo = "MOTO" then
       let d_cts00g02.vcldes = "MOTO ", d_cts00g02.vcldes
    end if

    if d_cts00g02.corsus  is not null   then
       whenever error continue
       select cornom
         into d_cts00g02.cornom
         from gcaksusep, gcakcorr
        where gcaksusep.corsus     = d_cts00g02.corsus
          and gcakcorr.corsuspcp   = gcaksusep.corsuspcp
       whenever error stop
    end if

    if m_veiculo_compl = true then
       let d_cts00g02.vcldes = m_desc_veiculo
    end if

    let ws.laudo =
                             d_cts00g02.srvtipabvdes    clipped, " ",
#       "Ordem Servico: ",   ws.atdsrvorg               "&&"     , "/",
#                            d_cts00g02.atdsrvnum using "&&&&&&&", "-",
#                            d_cts00g02.atdsrvano using "&&",   " ",
        "No. Vistoria: ",    d_cts00g02.vstnumdig using "&&&&&&&&&", " ",
        "Solicitado: ",      d_cts00g02.atddat          clipped, " as ",
                             d_cts00g02.atdhor          clipped, " ",
        "Finalidade: ",      d_cts00g02.vstflddes       clipped, " ",
        #"Viatura: ",         d_cts00g02.atdvclsgl       clipped, " ",

        "Corretor: ",        d_cts00g02.corsus          clipped, " ",
                             d_cts00g02.cornom          clipped, " ",

        "Segurado: ",        d_cts00g02.segnom          clipped, " ",
        "QTH: ",             a_cts00g02[1].lgdtxt       clipped, " ",
                             a_cts00g02[1].lclbrrnom    clipped, " ",
                             a_cts00g02[1].cidnom       clipped, " ",

        "Ref: ",             a_cts00g02[1].lclrefptotxt clipped, " ",
        "Procurar por: ",    a_cts00g02[1].lclcttnom    clipped, " ",

        "Veiculo: ",         d_cts00g02.vcldes          clipped, " ",
        "Fabricacao: ",      d_cts00g02.vclanofbc       clipped, " ",
        "Modelo: ",          d_cts00g02.vclanomdl       clipped, " ",
        "Cor: ",             d_cts00g02.vclcordes       clipped, " ",
        "QNR: ",             d_cts00g02.vcllicnum       clipped, " ",
        "Chassi: ",          d_cts00g02.vclchsnum       clipped, " ",
        "Historico: ",       ws.c24srvdsc               clipped,
                             ws.fim clipped
 else
    #Marcelo - psi178381 - inicio
    if ws.atdsrvorg  = 15 then
       call cts00g04_msgjittxt(param.atdsrvnum,
                               param.atdsrvano)
                               returning ws.laudo,
                                         l_status
       if l_status <> 0 then
          error ws.laudo
          sleep 3
          let ws.laudo   = null
          let ws.tabname = null
          let ws.sqlcode = null
          return ws.laudo, ws.tabname, ws.sqlcode
       end if
    end if
    #Marcelo - psi178381 - fim

    #CT201201879 Inicio
    if d_cts00g02.atdhorpvt  is not null and
       d_cts00g02.atddatprg is null      and
       d_cts00g02.atdhorprg is null      then
    #CT201201879 Fim
#=>    PSI.188603 - RECUPERA A DATA E HORA DA ULTIMA ETAPA
       let l_atdprvdat = null
       whenever error continue
       select atdetpdat, atdetphor
         into ws.atdetpdat, l_atdprvdat
         from datmsrvacp
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = param.atdsrvnum
                              and atdsrvano = param.atdsrvano)
       whenever error stop
       if sqlca.sqlcode <> 0  then
          let ws.tabname = "datmsrvacp"
          let ws.sqlcode = sqlca.sqlcode
          return ws.laudo, ws.tabname, ws.sqlcode
       end if
       let ws.atdetphor = l_atdprvdat - l_hour

#=>    PSI.188603 - SOMAR 'DATA DA ULTIMA ETAPA' A 'PREVISAO DE ATENDIMENTO'
       if d_cts00g02.atdprvdat is null then
          let d_cts00g02.atdprvdat = "00:20"
       end if
       let ws.datahoraqtr = ws.atdetpdat
       let ws.datahoraqtr = ws.datahoraqtr + ws.atdetphor
       let ws.datahoraqtr = ws.datahoraqtr + d_cts00g02.atdprvdat
       let ws.dispdata    = ws.datahoraqtr
       let ws.disphora    = ws.datahoraqtr

       let ws.msgpvt = "QTR:", ws.dispdata, " ", ws.disphora
    else
       let ws.msgpvt = "Programado:", d_cts00g02.atddatprg  clipped, " ",
                                       d_cts00g02.atdhorprg
    end if

    case ws.atdrsdflg
       when "S"  let d_cts00g02.atdrsddes = "SIM"
       when "N"  let d_cts00g02.atdrsddes = "NAO"
    end case

    case ws.rmcacpflg
       when "S"  let d_cts00g02.rmcacpdes = "SIM"
       when "N"  let d_cts00g02.rmcacpdes = "NAO"
    end case

    select nomgrr
      into d_cts00g02.nomgrr
      from dpaksocor
     where pstcoddig = ws.atdprscod

    #-----------------------------------
    # Nome Reduzido do Veiculo
    #-----------------------------------
    select vcltipnom
      into ws.vcltipnom
      from agbkveic, outer agbktip
     where agbkveic.vclcoddig  = ws.vclcoddig
       and agbktip.vclmrccod   = agbkveic.vclmrccod
       and agbktip.vcltipcod   = agbkveic.vcltipcod

    if sqlca.sqlcode = 0 then
       let d_cts00g02.vcldes = ws.vcltipnom clipped," ",ws.imsvlrdes
    end if

    if m_desc_veiculo = "MOTO" then
       let d_cts00g02.vcldes = "MOTO ", d_cts00g02.vcldes
    end if

#PSI205117 - INICIO
    whenever error continue
            open c_cts00g02_003 using param.atdsrvnum, param.atdsrvano
            fetch c_cts00g02_003 into ws.conta
    whenever error stop
            if sqlca.sqlcode <> 0 then
                    error "Erro ao selecionar endereco mapograf"
                    let ws.conta = 0
            end if
    close c_cts00g02_003
    if ws.conta = 1 then
            whenever error continue
                    open c_cts00g02_004 using param.atdsrvnum, param.atdsrvano
                    fetch c_cts00g02_004 into ws.pltpgncod, ws.pltcrdcod
            whenever error stop
                    if sqlca.sqlcode <> 0 then
                            error "Erro ao selecionar coordenada mapograf"
                            let ws.pltpgncod = null
                            let ws.pltcrdcod = null
                    end if
            close c_cts00g02_004
    end if
    if ws.conta > 1 then
            let ws.pltpgncod = null
            let ws.pltcrdcod = null
    end if
#PSI205117 - FIM

    #----------------------------------------------------------------------
    # Formata mensagem de: Remocao, DAF, Socorro, RPT, Replace (AUTOMOVEL)
    #----------------------------------------------------------------------
    if ws.atdsrvorg  =   4    or
       ws.atdsrvorg  =   6    or
       ws.atdsrvorg  =   1    or
       ws.atdsrvorg  =   5    or
       ws.atdsrvorg  =   7    or
      (ws.atdsrvorg  =   2    and ws.asitipcod = 5) or
       ws.atdsrvorg  =  17    then

       if d_cts00g02.roddantxt is not null  then
          let ws.campo = ws.campo clipped, "Rodas Danif:", d_cts00g02.roddantxt clipped
       end if

       if d_cts00g02.atddfttxt is not null  then
          if ws.atdsrvorg =  5   or
             ws.atdsrvorg =  7   or
             ws.atdsrvorg = 17   then
          else
             let ws.campo = ws.campo clipped, " Prob:", d_cts00g02.atddfttxt clipped
          end if
       end if

       ## obter local/condicoes do veiculo
       let l_passou = false
       let l_condicao = null

       open c_cts00g02_002 using param.atdsrvnum, param.atdsrvano
       foreach c_cts00g02_002 into ws.vclcndlclcod

               if l_passou = false then
                  let l_passou = true
                  let l_condicao = "LOC/COND.VCL:"
               end if

               call ctc61m03 (1,ws.vclcndlclcod) returning ws.vclcndlcldes

               let l_condicao = l_condicao clipped, "/",
                                ws.vclcndlcldes clipped

       end foreach

       initialize ws.msgpgttxt to null

       select atdetpcod
         into ws.atdetpcod
         from datmsrvacp
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = param.atdsrvnum
                              and atdsrvano = param.atdsrvano)

       #-------------------------------------------------------------------
       # Formata mensagem para servico cancelado
       #-------------------------------------------------------------------
       if ws.atdetpcod = 5   then
          call ctb00g00(param.atdsrvnum, param.atdsrvano,
                        ws.cnldat      , ws.atdfnlhor)
              returning ws.canpgtcod, ws.difcanhor

          if m_veiculo_compl = true then
             let d_cts00g02.vcldes = m_desc_veiculo
          end if

          let ws.laudo = l_msgcancela clipped, " ",

              "QRU:",    ws.atdsrvorg         using "&&"     ,"/",
                         d_cts00g02.atdsrvnum using "&&&&&&&", "-",
                         d_cts00g02.atdsrvano using "&&",   " ",

                         d_cts00g02.asitipabvdes   clipped, " ",

                         ws.msgpvt                 clipped, " ",

              "Tel:",    "PARA FALAR COM O CLIENTE UTILIZE A URA DE ATENDIMENTO", " ",                   

                         d_cts00g02.vcldes         clipped, " ",
                         d_cts00g02.vclanomdl      clipped, " ",
              "QNR:",    d_cts00g02.vcllicnum      clipped, " ",
                         d_cts00g02.vclcordes      clipped, " "
#PSI205117 - inicio
          if ws.pltpgncod is not null and ws.pltcrdcod is not null then
             let ws.laudo = ws.laudo clipped, " ",
                            "Guia:", "Pg.", ws.pltpgncod, "-", ws.pltcrdcod
          end if
          let ws.laudo = ws.laudo clipped, ws.fim
#PSI205117 - fim

       else
          if m_veiculo_compl = true then
             let d_cts00g02.vcldes = m_desc_veiculo
          end if

          let ws.laudo = l_msginicial

          if ws.ramcod is not null then
             let ws.laudo = ws.laudo clipped,
                 "Ramo:", ws.ramcod using "<<<<<&", "-", ws.ramnom
          end if

          #PSI 217587 - Busca o número de passageiros
          initialize l_retnumpassageiros.numpassageiros to null
          initialize l_mensagem_passageiros to null
          if(ws.asitipcod = 5) then
              call ctd22g00_inf_numpassageiros(d_cts00g02.atdsrvnum, d_cts00g02.atdsrvano)
                  returning l_retnumpassageiros.*

              if(l_retnumpassageiros.erro <> 1) then
                  error "Erro ao tentar buscar numero de passageiros para o servico de taxi "
              else
		  if l_retnumpassageiros.numpassageiros > 1 then
                     let l_mensagem_passageiros = l_retnumpassageiros.numpassageiros using "<<<<#", "-PASSAGEIROS "
                  else
                     let l_mensagem_passageiros = l_retnumpassageiros.numpassageiros using "<<<<#", "-PASSAGEIRO "
		  end if
              end if
          end if

          let ws.laudo = ws.laudo clipped, " ",
              "QRU:",    ws.atdsrvorg         using "&&"     , "/",
                         d_cts00g02.atdsrvnum using "&&&&&&&", "-",
                         d_cts00g02.atdsrvano using "&&",   " ",

                         d_cts00g02.asitipabvdes   clipped, " ",

                         #PSI 217587
                         l_mensagem_passageiros clipped, " ",

                         ws.msgpvt                 clipped, " ",

              "QNC:",    d_cts00g02.nom             clipped, " ",
                         d_cts00g02.vcldes          clipped, " ",
                         d_cts00g02.vclanomdl       clipped, " ",

              "QNR:",    d_cts00g02.vcllicnum       clipped, " ",
                         d_cts00g02.vclcordes       clipped, " ",

                         ws.campo                   clipped, " ",

              "QTH:",    a_cts00g02[1].lclidttxt    clipped, " ",
                         a_cts00g02[1].lgdtxt       clipped, "-",
                         a_cts00g02[1].lclbrrnom    clipped, "-",
                         a_cts00g02[1].cidnom       clipped, "-",

                         a_cts00g02[1].ufdcod       clipped, " "
#PSI205117 - inicio
              if ws.pltpgncod is not null and ws.pltcrdcod is not null then
                let ws.laudo = ws.laudo clipped, " ",
                               "Guia:", "Pg.", ws.pltpgncod, "-", ws.pltcrdcod
              end if
              let ws.laudo = ws.laudo clipped, " ",
                             "Ref: ", a_cts00g02[1].lclrefptotxt
#PSI205117 - fim

              if  d_cts00g02.atdrsddes = "SIM"  then
                  let ws.laudo = ws.laudo clipped, " ",
                  "Na Res:", d_cts00g02.atdrsddes
              end if

              let ws.laudo = ws.laudo clipped, " ",
              "Resp:",           a_cts00g02[1].lclcttnom    clipped, " ",
              "Tel:",            "PARA FALAR COM O CLIENTE UTILIZE A URA DE ATENDIMENTO", " "                                

              if  d_cts00g02.rmcacpdes = "SIM"  then
                  let ws.laudo = ws.laudo clipped, " ",
                  "Acomp:", d_cts00g02.rmcacpdes
              end if

              if l_condicao is not null then
                 let ws.laudo = ws.laudo clipped, " ", l_condicao
              end if

              if a_cts00g02[2].cidnom is not null  and
                 a_cts00g02[2].ufdcod is not null  and
                 cts47g00_mesma_cidsed_cid(a_cts00g02[1].cidnom,
                                           a_cts00g02[1].ufdcod,
                                           a_cts00g02[2].cidnom,
                                           a_cts00g02[2].ufdcod) <> 1 then #mesma cidade
                 let ws.laudo = ws.laudo clipped, " ",
                     "QTI:", a_cts00g02[2].lclidttxt    clipped, " ",
                             a_cts00g02[2].lgdtxt       clipped, "-",
                             a_cts00g02[2].lclbrrnom    clipped, "-",
                             a_cts00g02[2].cidnom       clipped, "-",
                             a_cts00g02[2].ufdcod
              end if

              if ws.srvprlflg = "S"  then
                 let ws.laudo = ws.laudo clipped, " ",
                     "**SERVICO PARTICULAR: PAGTO POR CONTA DO CLIENTE**"
              end if

            let ws.laudo = ws.laudo clipped, ws.fim
       end if
    end if

    #----------------------------------------------------------------------
    # Formata mensagem de: Sinistro, Socorro (RAMOS ELEMENTARES)
    #----------------------------------------------------------------------
    if ws.atdsrvorg  =  9     or
       ws.atdsrvorg  = 13     then

       select orrdat   , orrhor   ,
              socntzcod, sinntzcod,
              lclrsccod
         into d_cts00g02.orrdat, d_cts00g02.orrhor,
              ws.socntzcod     , ws.sinntzcod     ,
              ws.lclrsccod
         from datmsrvre
        where atdsrvnum = d_cts00g02.atdsrvnum
          and atdsrvano = d_cts00g02.atdsrvano

       if sqlca.sqlcode <> 0  then
          let ws.tabname = "datmsrvre"
          let ws.sqlcode = sqlca.sqlcode
          return ws.laudo, ws.tabname, ws.sqlcode
       end if

       if ws.socntzcod is not null  then
          select socntzdes
            into d_cts00g02.ntzdes
            from datksocntz
           where socntzcod = ws.socntzcod

       else
          select sinntzdes
            into d_cts00g02.ntzdes
            from sgaknatur
           where sinramgrp = '4'
             and sinntzcod = ws.sinntzcod
       end if

       if d_cts00g02.atddfttxt is not null  then
          let ws.campo = ws.campo clipped, " Prob:", d_cts00g02.atddfttxt clipped
       end if

#hpn -- ini
       initialize ws.msgpgttxt to null

       select atdetpcod
         into ws.atdetpcod
         from datmsrvacp
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
          and atdsrvseq = (select max(atdsrvseq)
                             from datmsrvacp
                            where atdsrvnum = param.atdsrvnum
                              and atdsrvano = param.atdsrvano)

       #-------------------------------------------------------------------
       # Formata mensagem para servico cancelado
       #-------------------------------------------------------------------
       call cts29g00_obter_multiplo(1,
                                    param.atdsrvnum,
                                    param.atdsrvano)
       returning ws.resultado,
                 ws.mensagem,
                 al_retorno[1].*,
                 al_retorno[2].*,
                 al_retorno[3].*,
                 al_retorno[4].*,
                 al_retorno[5].*,
                 al_retorno[6].*,
                 al_retorno[7].*,
                 al_retorno[8].*,
                 al_retorno[9].*,
                 al_retorno[10].*

       if ws.resultado = 3 then
          display ws.mensagem clipped
          let ws.tabname = "cts29g00"
          return ws.resultado, ws.mensagem
       end if

       if al_retorno[1].atdmltsrvnum is not null and ws.ciaempcod = 84 then
          let l_limpecas = cts29g00_texto_itau_limite_multiplo(d_cts00g02.atdsrvnum,d_cts00g02.atdsrvano)
          let l_msginicial = "***SERVICO ITAU AUTO E RESIDENCIA. EM CASO DE FORNECIMENTO DE PECAS, LIMITADO AO VALOR ", l_limpecas clipped,". CASO HAJA EXCEDENTE ENTRAR EM CONTATO COM A C.O ***"
       end if

       let ws.laudo = l_msginicial ## psi 211982

       if ws.atdetpcod >= 5   then
          if ws.atdetpcod <> 10 then
             let ws.laudo = ws.laudo clipped, " ", l_msgcancela
          end if
       end if

       if ws.ramcod is not null then
          let ws.laudo = ws.laudo clipped, " ",
              "Ramo:", ws.ramcod using "<<<<<&", "-", ws.ramnom clipped
       end if

       let ws.laudo = ws.laudo clipped, " ",
           "QRU:",         ws.atdsrvorg         using "&&"     , "/",
           d_cts00g02.atdsrvnum using "&&&&&&&", "-",
           d_cts00g02.atdsrvano using "&&"," "

       for l_ind = 1 to 10
          if al_retorno[l_ind].atdmltsrvnum is not null then
             let ws.laudo = ws.laudo clipped," ",
                            ws.atdsrvorg using "&&", "/",
                            al_retorno[l_ind].atdmltsrvnum using "&&&&&&&", "-",
                            al_retorno[l_ind].atdmltsrvano using "&&", " "
          end if
       end for

       let ws.laudo = ws.laudo clipped," ",ws.msgpvt clipped, " "

                              if ws.atdetpcod = 10  then
                                  let ws.laudo = ws.laudo clipped," RETORNO"
                              end if

              let l_espdes = null

              # --BUSCA A DESCRICAO DA ESPECIALIDADE DO SERVICO
              let l_espdes = cts00g02_busca_especialidade(d_cts00g02.atdsrvnum,
                                                          d_cts00g02.atdsrvano)

              let ws.laudo = ws.laudo clipped, " ",

              "QNC:",         d_cts00g02.nom             clipped

###           "Solicitado: ", d_cts00g02.atddat          clipped, " as ",
###                           d_cts00g02.atdhor          clipped, " ",

              # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
              if l_espdes is not null and
                 l_espdes <> " " then
                 let ws.laudo = ws.laudo clipped,
                                " ", "Natureza:",
                                d_cts00g02.ntzdes clipped, " - ", l_espdes clipped, " "
              else
                 let ws.laudo = ws.laudo clipped,
                                " ", "Natureza:",
                                d_cts00g02.ntzdes clipped, " "
              end if

               for l_ind = 1 to 10
                  if al_retorno[l_ind].atdmltsrvnum is not null then

                     let l_espdes = null

                     # --BUSCA A DESCRICAO DA ESPECIALIDADE DO SERVICO
                     let l_espdes = cts00g02_busca_especialidade(al_retorno[l_ind].atdmltsrvnum,
                                                                 al_retorno[l_ind].atdmltsrvano)

                     # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
                     if l_espdes is not null and
                        l_espdes <> " " then
                        let ws.laudo = ws.laudo clipped, ' / ',
                                       al_retorno[l_ind].socntzdes clipped, " - ",
                                       l_espdes
                     else
                        let ws.laudo = ws.laudo clipped, ' / ',
                                       al_retorno[l_ind].socntzdes
                     end if

                  end if
               end for

               let ws.laudo = ws.laudo clipped, " ",  ws.campo clipped, " "

                for l_ind = 1 to 10
                  if al_retorno[l_ind].atdmltsrvnum is not null then
                     let ws.laudo = ws.laudo clipped, ' / ', al_retorno[l_ind].atddfttxt
                  end if
                end for

              let ws.laudo = ws.laudo clipped, " ",
              "QTH:",         a_cts00g02[1].lclidttxt    clipped, " ",
                              a_cts00g02[1].lgdtxt       clipped, "-",
                              a_cts00g02[1].lclbrrnom    clipped, "-",
                              a_cts00g02[1].cidnom       clipped, "-",
                              a_cts00g02[1].ufdcod       clipped, " ",

              "Resp:",        a_cts00g02[1].lclcttnom    clipped, " ",
              "Tel:",         "PARA FALAR COM O CLIENTE UTILIZE A URA DE ATENDIMENTO", " "                             
#PSI205117 - inicio
                if ws.pltpgncod is not null and ws.pltcrdcod is not null then
                        let ws.laudo = ws.laudo clipped, " ",
                        "Guia:", "Pg.", ws.pltpgncod, "-", ws.pltcrdcod
                end if
                let ws.laudo = ws.laudo clipped, " ",
                               "Ref:", a_cts00g02[1].lclrefptotxt clipped, ws.fim
#PSI205117 - fim

    end if
 end if

 let ws.sqlcode = 0

 return ws.laudo, ws.tabname, ws.sqlcode

end function  ###  cts00g02_laudo

#PSI 237337 - FUNÇÃO RESPONSÁVEL POR ENVIAR MENSAGEM
#QUANDO ATIVO CONTINGÊNCIA DE ALGUMA CONTROLADORA
#----------------------------------------------------------------------
function cts00g02_env_msg_ctg_ctr(param)
#----------------------------------------------------------------------

    define param         record
        atdsrvnum  like datmservico.atdsrvnum,
        atdsrvano  like datmservico.atdsrvano,
        socvclcod  like datmservico.socvclcod
    end record

    define dbsmenvmsgsms record
        smsenvcod like dbsmenvmsgsms.smsenvcod,
        celnum    like dbsmenvmsgsms.celnum,
        msgtxt    like dbsmenvmsgsms.msgtxt,
        envdat    like dbsmenvmsgsms.envdat,
        incdat    like dbsmenvmsgsms.incdat,
        envstt    like dbsmenvmsgsms.envstt,
        errmsg    like dbsmenvmsgsms.errmsg,
        dddcel    like dbsmenvmsgsms.dddcel
    end record

    define ws record
        tabname   like systables.tabname,
        sqlcode   integer,
        erroflg   char (01),
        mdtcod    like datkveiculo.mdtcod,
        laudo     char (4000),
        celular   char(13),
        celddd    char(2),
        celnum    char(9),
        smsenvcod like dbsmenvmsgsms.smsenvcod,
        incdat    like dbsmenvmsgsms.incdat
    end record

    initialize dbsmenvmsgsms.* to null
    initialize ws.* to null
    let ws.erroflg  =  "N"

    if m_cts00g02_prep is null or
        m_cts00g02_prep <> true then
        call cts00g02_prepare()
    end if

    call cts00g02_laudo_sms (param.atdsrvnum,
                             param.atdsrvano,
                             param.socvclcod)
         returning  ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode

    if ws.sqlcode  <>  0   then
       let ws.erroflg  =  "S"
       error "Erro ao enviar sms, srv: ", param.atdsrvnum using "&&&&&&&",
                                     "-", param.atdsrvano using "&&"
       return ws.erroflg
    end if

    #Buscar celulares
    call cts00g02_busca_cel(param.socvclcod)
        returning ws.celular

    if ws.celular is null or ws.celular = "" then
        error "Mensagem nao enviada, nenhum numero de envio cadastrado ", param.socvclcod sleep 4
        let ws.erroflg = 'S'
        return ws.erroflg
    else

        #display "LAUDO >>>>> ", ws.laudo clipped

        #INSERE TABELA dbsmenvmsgsms PARA ENVIO SMS
        let ws.smsenvcod = param.atdsrvnum using "<<<<<<<<<&","/",
                           param.atdsrvano using "<<<<<<<<<&"

        let ws.celddd = ws.celular[1,2]
        let ws.celnum = ws.celular[5,13]
        let ws.incdat = current

        whenever error continue
        execute p_cts00g02_010 using ws.smsenvcod,
                                   ws.celddd,
                                   ws.celnum,
                                   ws.laudo,
                                   ws.incdat,
                                   "A"

        if  sqlca.sqlcode <> 0 then
            display 'Erro : ', sqlca.sqlcode clipped, " Tabela de Envio de SMS"
            display "ws.smsenvcod          : ", ws.smsenvcod
            display "ws.celddd             : ", ws.celddd
            display "ws.celnum             : ", ws.celnum
            display "ws.msgsms             : ", ws.laudo
            display "ws.incdat             : ", ws.incdat
        end if
        whenever error stop

    end if

    return ws.erroflg

end function #function cts00g02_env_msg_ctg_ctr

#PSI 2327337 - FUNÇÃO RESPONSÁVEL POR FORMATAR LAUDO PARA ENVIO DE MSG SMS
#----------------------------------------------------------------------
function cts00g02_laudo_sms(param)
#----------------------------------------------------------------------
define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    socvclcod         like datmservico.socvclcod
 end record

 define d_cts00g02    record
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    c24opemat         like datmservico.c24opemat   ,
    atdrsddes         char (03)                    ,
    atdlclflg         like datmservico.atdlclflg   ,
    nom               like datmservico.nom         ,
    dddcod            like gsakend.dddcod          ,
    teltxt            like gsakend.teltxt          ,
    vcldes            like datmservico.vcldes      ,
    vclcordes         char (20)                    ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    bocflg            like datmservicocmp.bocflg   ,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    atddfttxt         like datmservico.atddfttxt   ,
    roddantxt         like datmservicocmp.roddantxt,
    atdmotnom         like datmservico.atdmotnom   ,
    atdvclsgl         like datmservico.atdvclsgl   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atdprvdat         interval hour to minute,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    ramcod            like datrservapol.ramcod     ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,
    ntzdes            like datksocntz.socntzdes    ,
    orrdat            like datmsrvre.orrdat        ,
    orrhor            like datmsrvre.orrhor        ,
    vstnumdig         like datmvistoria.vstnumdig  ,
    vstflddes         char (30)                    ,
    corsus            like datmvistoria.corsus     ,
    cornom            like datmvistoria.cornom     ,
    segnom            like datmvistoria.segnom     ,
    vclchsnum         like datmvistoria.vclchsnum  ,
    vclanofbc         like datmvistoria.vclanofbc,
    crtsaunum         like datrligsau.crtnum     ,
    edsnumref         like datrservapol.edsnumref
 end record

 define a_cts00g02    array[2] of record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtxt           char (28),
    lgdnum           char (5),
    lclbrrnom        like datmlcl.lclbrrnom,
    endzon           like datmlcl.endzon,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom
 end record

 define ws            record
    campo             char (15)                    ,
    msgpvt            char (11)                    ,
    fim               char (03)                    ,
    cponom            like iddkdominio.cponom      ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    asitipcod         like datmservico.asitipcod   ,
    atdprscod         like datmservico.atdprscod   ,
    vclcorcod         like datmservico.vclcorcod   ,
    atdrsdflg         like datmservico.atdrsdflg   ,
    rmcacpflg         like datmservicocmp.rmcacpflg,
    c24srvdsc         like datmservhist.c24srvdsc  ,
    c24txtseq         like datmservhist.c24txtseq  ,
    vstfld            like datmvistoria.vstfld     ,
    vclmrcnom         like datmvistoria.vclmrcnom  ,
    vcltipnom         like datmvistoria.vcltipnom  ,
    vclmdlnom         like datmvistoria.vclmdlnom  ,
    lclrsccod         like datmsrvre.lclrsccod     ,
    socntzcod         like datmsrvre.socntzcod     ,
    sinntzcod         like datmsrvre.sinntzcod     ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    srvprlflg         like datmservico.srvprlflg   ,
    mdtcod            like datkveiculo.mdtcod      ,
    pgrnum            like datkveiculo.pgrnum      ,
    ustcod            like htlrust.ustcod          ,
    canpgtcod         dec (1,0)                    ,
    difcanhor         datetime hour to minute      ,
    msgpgttxt         char (50)                    ,
    tabname           like systables.tabname       ,
    sqlcode           integer                      ,
    laudo             char (130)                   ,
    vclcoddig         like datmservico.vclcoddig   ,
    errcod            integer                      ,
    sqlcod            integer                      ,
    mstnum            integer                      ,
    imsvlr            like abbmcasco.imsvlr        ,
    imsvlrdes         char (08)                    ,
    atdetpdat         like datmsrvacp.atdetpdat    , #=> PSI.188603
    atdetphor         interval hour to minute      , #=> PSI.188603
    datahoraqtr       datetime year to minute      , #=> PSI.188603
    dispdata          date                         , #=> PSI.188603
    disphora          datetime hour to minute,       #=> PSI.188603
    mensagem          char (80),
    resultado         smallint,
    ramcod            like gtakram.ramcod,
    ramnom            like gtakram.ramnom,
    ramsgl            like gtakram.ramsgl,
    ciaempcod         like datmservico.ciaempcod,
    empnom            like gabkemp.empnom,
    conta             smallint , #PSI205117
    lignum            like datrligsrv.lignum,
    lclltt            like datmlcl.lclltt,
    lcllgt            like datmlcl.lcllgt,
    mdtctrcod         like datkmdt.mdtctrcod,
    txtlclltt         char(20),
    txtlcllgt         char(20),
    vcldesc           char(10),    #Truncamento campo veículo
    placa             char(7),     #Truncamento placa
    cor               char(6),     #Truncamento cor do veículo
    logradouro        char(22),    #Truncamento logradouro
    logradouro_re     char(28),
    num_logradouro    char(5),     #Truncamento número do logradouro
    bairro            char(12),    #Truncamento bairro
    bairro_re         char(15),
    cidade            char(10),    #Truncamento cidade
    ntzdes            char(22),    #Descrição Natureza da Ocorrência
    resp              char(9)
 end record

 define l_ind        smallint

 define al_retorno   array[10] of record
        atdmltsrvnum like datratdmltsrv.atdmltsrvnum,
        atdmltsrvano like datratdmltsrv.atdmltsrvano,
        socntzdes    like datksocntz.socntzdes,
        espdes       like dbskesp.espdes,
        atddfttxt    like datmservico.atddfttxt
 end record

define lr_ffpfc073 record
       cgccpfnumdig char(18) ,
       cgccpfnum    char(12) ,
       cgcord       char(4)  ,
       cgccpfdig    char(2)  ,
       mens         char(50) ,
       erro         smallint
end record

define lr_retorno record
     pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
     socqlmqtd     like datkitaasipln.socqlmqtd    ,
     erro          integer,
     mensagem      char(50)
  end record

 define l_status      smallint,
        l_atdprvdat   like datmservico.atdprvdat,
        l_hour        datetime hour to minute

  define l_resultado   smallint,
        l_mensagem    char(100),
        l_segnom      like gsakseg.segnom,
        l_grupo       like gtakram.ramgrpcod,
        l_documento   char(200),
        l_doc_handle  integer,
        l_data_atual  date,
        l_hora_atual  datetime hour to minute,
        l_ctgtrfcod   like datrctggch.ctgtrfcod,
        l_msginicial  char(150),
        l_msgcancela  char(150),
        l_kmazul      char(3),
        l_qtdeazul    char(3),
        l_kmazulint   integer

  define  w_pf1   integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let l_ind        = null
        let l_status     = null
        let l_atdprvdat  = null
        let l_hour       = null
        let w_pf1        = null
        let l_data_atual = null
        let l_hora_atual = null
        let l_resultado  = null
        let l_ctgtrfcod  = null
        let l_msginicial = ""
        let l_msgcancela = ""
        let l_kmazul     = null
        let l_kmazulint  = 0
        let l_qtdeazul   = null

        if m_cts00g02_prep is null or
           m_cts00g02_prep <> true then
           call cts00g02_prepare()
        end if


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  2
                initialize  a_cts00g02[w_pf1].*  to  null
        end     for

        for     w_pf1  =  1  to  10
                initialize  al_retorno[w_pf1].*  to  null
        end     for

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_cts00g02.*  to  null
        initialize  lr_retorno.*  to null
        initialize  ws.*          to  null
        initialize  lr_ffpfc073.* to null

  for     w_pf1  =  1  to  2
          initialize  a_cts00g02[w_pf1].*  to  null
  end     for

  initialize  d_cts00g02.*  to  null

  initialize  ws.*  to  null

 let l_atdprvdat = null
 let l_hour      = "00:00"
 let l_doc_handle = null

 initialize d_cts00g02.*  to null
 initialize a_cts00g02    to null
 initialize ws.*          to null
 let ws.fim  =  "#"

 let l_resultado   = null
 let l_mensagem    = null
 let l_segnom      = null
 let l_grupo       = null
 let l_documento   = null

 select datmservico.atdsrvnum,
        datmservico.atdsrvano,
        datmservico.vclcorcod,
        datmservico.c24opemat,
        datmservicocmp.rmcacpflg,
        datmservico.srvprlflg,
        datmservico.atdlclflg,
        datmservico.atdsrvorg,
        datmservico.asitipcod,
        datmservico.atdrsdflg,
        datmservico.nom,
        datmservico.vcldes,
        datmservico.vclanomdl,
        datmservico.vcllicnum,
        datmservicocmp.bocflg,
        datmservicocmp.bocnum,
        datmservicocmp.bocemi,
        datmservico.atddfttxt,
        datmservicocmp.roddantxt,
        datmservico.atdprscod,
        datmservico.atdmotnom,
        datmservico.atddat,
        datmservico.atdhor,
        datmservico.atdhorpvt,
        datmservico.atdprvdat,
        datmservico.atddatprg,
        datmservico.atdhorprg,
        datmservico.cnldat,
        datmservico.atdfnlhor,
        datmservico.vclcoddig,
        datmservico.ciaempcod
   into d_cts00g02.atdsrvnum,
        d_cts00g02.atdsrvano,
        ws.vclcorcod,
        d_cts00g02.c24opemat,
        ws.rmcacpflg,
        ws.srvprlflg,
        d_cts00g02.atdlclflg,
        ws.atdsrvorg,
        ws.asitipcod,
        ws.atdrsdflg,
        d_cts00g02.nom,
        d_cts00g02.vcldes,
        d_cts00g02.vclanomdl,
        d_cts00g02.vcllicnum,
        d_cts00g02.bocflg,
        d_cts00g02.bocnum,
        d_cts00g02.bocemi,
        d_cts00g02.atddfttxt,
        d_cts00g02.roddantxt,
        ws.atdprscod,
        d_cts00g02.atdmotnom,
        d_cts00g02.atddat,
        d_cts00g02.atdhor,
        d_cts00g02.atdhorpvt,
        l_atdprvdat,
        d_cts00g02.atddatprg,
        d_cts00g02.atdhorprg,
        ws.cnldat,
        ws.atdfnlhor,
        ws.vclcoddig,
        ws.ciaempcod
   from datmservico, outer datmservicocmp
  where datmservico.atdsrvnum    = param.atdsrvnum
    and datmservico.atdsrvano    = param.atdsrvano
    and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
    and datmservicocmp.atdsrvano = datmservico.atdsrvano

 if sqlca.sqlcode <> 0  then
    let ws.tabname = "datmservico"
    let ws.sqlcode = sqlca.sqlcode

    return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
 end if

 #------------------------------
 # BUSCAR A DATA E HORA DO BANCO
 #------------------------------
 call cts40g03_data_hora_banco(2)
      returning l_data_atual,
                l_hora_atual

 if ws.atdsrvorg <> 9 then

    #--------------------------------------
    # OBTER O CODIGO DA CATEGORIA TARIFARIA
    #--------------------------------------
    call cty05g03_pesq_catgtf(ws.vclcoddig,
                              l_data_atual)
         returning l_resultado,
                   l_mensagem,
                   l_ctgtrfcod

    if l_resultado <> 0 then
       if l_resultado = 1 then
          error "Categoria tarifaria nao encontrada, veiculo: ",
                ws.vclcoddig sleep 2
       else
          error "Erro de acesso a banco na funcao cty05g03_pesq_catgtf()" sleep 2
       end if
    end if
 end if

 let m_veiculo_compl = false # NAO ENVIAR A DESCRICAO COMPLETA DO VEICULO
 let m_desc_veiculo  = null

 call cts02m01_ctgtrfcod(l_ctgtrfcod)
      returning m_caminhao
 # -> VERIFICA SE A CATEGORIA TARIFARIA CORRESPONDE A CAMINHAO
 {if l_ctgtrfcod = 40 or
    l_ctgtrfcod = 41 or
    l_ctgtrfcod = 42 or
    l_ctgtrfcod = 43 or
    l_ctgtrfcod = 50 or
    l_ctgtrfcod = 51 or
    l_ctgtrfcod = 52 or
    l_ctgtrfcod = 43 then}
 if m_caminhao = "S" then

    # -> CONFORME SOLICITACAO DO CESAR(GUILHERME) DO RADIO, QUANDO O VEICULO
    #    FOR CAMINHAO, ENVIAR A DESCRICAO COMPLETA NA MENSAGEM MDT.
    #    DATA: 04/12/2006
    #    CHAMADO: 6116004
    #    AUTOR: LUCAS SCHEID

    let m_veiculo_compl = true # ENVIAR A DESCRICAO COMPLETA DO VEICULO
    let m_desc_veiculo  = d_cts00g02.vcldes

 end if

 if l_ctgtrfcod = 30 or l_ctgtrfcod = 31 then  ### MOTO
    let m_desc_veiculo = "MOTO"
 end if

 call cty14g00_empresa(1, ws.ciaempcod)
      returning l_resultado, l_mensagem, ws.empnom
 let l_msginicial = "PORTO"
 let l_msgcancela = "CAN PORTO"

 let d_cts00g02.atdprvdat = l_atdprvdat - l_hour

 call ctx04g00_local_reduzido_ctg(param.atdsrvnum, param.atdsrvano, 1)
     returning a_cts00g02[1].lclidttxt thru a_cts00g02[1].lclcttnom,ws.sqlcode

 if ws.sqlcode <> 0  then
    let ws.tabname = "datmlcl"
    return ws.laudo, ws.tabname, ws.sqlcode
 end if     

 call ctx04g00_local_reduzido_ctg(param.atdsrvnum, param.atdsrvano, 2)
     returning a_cts00g02[2].lclidttxt thru a_cts00g02[2].lclcttnom,ws.sqlcode

 if ws.sqlcode < 0  then
    let ws.tabname = "datmlcl"
    return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
 end if

 #---------------------------------------------------------
 # Identificando cod ramo e descricao
 #---------------------------------------------------------
 #PSI205125 - Inicio
 #open ccts00g02004 using param.atdsrvnum, param.atdsrvano
 #fetch ccts00g02004 into ws.ramcod, ws.ramnom
 #close ccts00g02004
 #PSI205125 - Fim


 #---------------------------------------------------------
 # Sigla/MDT do veiculo
 #---------------------------------------------------------
 select atdvclsgl, mdtcod, pgrnum
   into d_cts00g02.atdvclsgl, ws.mdtcod, ws.pgrnum
   from datkveiculo
  where socvclcod = param.socvclcod

 if sqlca.sqlcode <> 0  then
    let ws.tabname = "datkveiculo"
    let ws.sqlcode = sqlca.sqlcode
    return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
 end if

 #---------------------------------------------------------
 # Apolice do servico
 #---------------------------------------------------------
 select ramcod,
        succod,
        aplnumdig,
        itmnumdig,
        edsnumref
   into d_cts00g02.ramcod,
        d_cts00g02.succod,
        d_cts00g02.aplnumdig,
        d_cts00g02.itmnumdig,
        d_cts00g02.edsnumref
   from datrservapol
  where atdsrvnum = d_cts00g02.atdsrvnum
    and atdsrvano = d_cts00g02.atdsrvano

 if sqlca.sqlcode < 0  then
    let ws.tabname = "datrservapol"
    let ws.sqlcode = sqlca.sqlcode
    return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
 end if

 # Quando o servico tem apolice
 if sqlca.sqlcode = 0 then
    #PSI205125 - Inicio
    let ws.ramcod = d_cts00g02.ramcod
    call cty10g00_descricao_ramo(d_cts00g02.ramcod,1)
         returning l_resultado, l_mensagem, ws.ramnom, ws.ramsgl
    #PSI205125 - Fim

    ### PSI 202720
    call cty10g00_grupo_ramo(1, d_cts00g02.ramcod)
         returning l_resultado, l_mensagem, l_grupo

 end if

 if l_grupo = 5 then ## Saude
    call cts20g10_cartao(1, d_cts00g02.atdsrvnum, d_cts00g02.atdsrvano)
         returning l_resultado, l_mensagem, d_cts00g02.crtsaunum

    call cta01m15_sel_datksegsau (3, d_cts00g02.crtsaunum, "","","")
         returning l_resultado, l_mensagem, l_segnom, d_cts00g02.dddcod,
                   d_cts00g02.teltxt
 else

    #---------------------------------------------------------
    # Busca telefone do segurado
    #---------------------------------------------------------
    case ws.ciaempcod
       when 1
          call cts09g00(d_cts00g02.ramcod,
                        d_cts00g02.succod,
                        d_cts00g02.aplnumdig,
                        d_cts00g02.itmnumdig,
                        false)
              returning d_cts00g02.dddcod,
                        d_cts00g02.teltxt

       when 35
          if d_cts00g02.aplnumdig is not null then
              call cts42g00_doc_handle(d_cts00g02.succod, d_cts00g02.ramcod,
                                       d_cts00g02.aplnumdig, d_cts00g02.itmnumdig,
                                       d_cts00g02.edsnumref)
                   returning l_resultado, l_mensagem, l_doc_handle

              call cts40g02_extraiDoXML(l_doc_handle, "FONE_SEGURADO")
                   returning d_cts00g02.dddcod,  d_cts00g02.teltxt


              ---> Busca Limites da Azul
              call cts49g00_clausulas(l_doc_handle)
                   returning l_kmazul, l_qtdeazul

              let l_kmazulint = l_kmazul
              let l_kmazulint = l_kmazulint * 2

              #let l_msginicial = "***SERVICO AZUL SEGUROS. EM CASO DE VIAGEM AUTORIZADA PELA CT, LIMITE DE ", l_kmazulint using "<<<#", "KM TOTAIS. COBRAR KM EXCEDENTE DO SEGURADO***"
            else
               let l_msginicial = "AZUL"
            end if
            let l_msgcancela = "CAN AZUL"

       when 40
            #---------------------------------------------------------------
            # Dados da ligacao
            #---------------------------------------------------------------
            let ws.lignum = cts20g00_servico(d_cts00g02.atdsrvnum, d_cts00g02.atdsrvano)

            whenever error continue
            open c_cts00g02_005 using ws.lignum

            fetch c_cts00g02_005 into lr_ffpfc073.cgccpfnum ,
                                    lr_ffpfc073.cgcord    ,
                                    lr_ffpfc073.cgccpfdig

            whenever error stop

            let lr_ffpfc073.cgccpfnumdig = ffpfc073_formata_cgccpf(lr_ffpfc073.cgccpfnum ,
                                                                   lr_ffpfc073.cgcord    ,
                                                                   lr_ffpfc073.cgccpfdig )

               call ffpfc073_rec_tel(lr_ffpfc073.cgccpfnumdig,'F')
                     returning d_cts00g02.dddcod ,
                               d_cts00g02.teltxt ,
                               lr_ffpfc073.mens  ,
                               lr_ffpfc073.erro

               if lr_ffpfc073.erro <> 0 then
                   error lr_ffpfc073.mens
               end if

      when 84
          let l_msginicial = "ITAU AUTO "

          open c_cts00g02_013 using d_cts00g02.atdsrvnum, d_cts00g02.atdsrvano
          whenever error continue
          fetch c_cts00g02_013 into g_documento.ramcod,
                                    g_documento.aplnumdig,
                                    g_documento.itmnumdig,
                                    g_documento.edsnumref,
                                    g_documento.itaciacod

          whenever error stop
          if g_documento.ramcod = 531 or g_documento.ramcod = 31 then
              call cty22g00_rec_dados_itau(g_documento.itaciacod,
			                                     g_documento.ramcod   ,
			                                     g_documento.aplnumdig,
			                                     g_documento.edsnumref,
			                                     g_documento.itmnumdig)
	           returning lr_retorno.erro,
	                     lr_retorno.mensagem

	           display "lr_retorno.erro2: ",lr_retorno.erro
	           if lr_retorno.erro = 0 then

	              let d_cts00g02.dddcod = g_doc_itau[1].segresteldddnum
	              let d_cts00g02.teltxt = g_doc_itau[1].segrestelnum
	           else
	              let d_cts00g02.dddcod = 0
	              let d_cts00g02.teltxt = 0
	           end if
	        else
	           # buscar dados da apolice de resindecia
	           call cty25g01_rec_dados_itau (g_documento.itaciacod,
	                                         g_documento.ramcod   ,
	                                         g_documento.aplnumdig,
	                                         g_documento.edsnumref,
	                                         g_documento.itmnumdig)

	            returning lr_retorno.erro,
	                      lr_retorno.mensagem

	            if lr_retorno.erro = 0 then

	               let d_cts00g02.dddcod = g_doc_itau[1].segresteldddnum
	               let d_cts00g02.teltxt = g_doc_itau[1].segrestelnum
	            else
	               let d_cts00g02.dddcod = 0
	               let d_cts00g02.teltxt = 0
	            end if
	        end if
	  let l_msgcancela = "CAN ITAU AUTO "

    end case
 end if

 #---------------------------------------------------------
 # Descricao do tipo de assistencia
 #---------------------------------------------------------
 let d_cts00g02.asitipabvdes = "NAO PREV."

 select asitipabvdes
   into d_cts00g02.asitipabvdes
   from datkasitip
  where asitipcod = ws.asitipcod

 #---------------------------------------------------------
 # Cor do veiculo
 #---------------------------------------------------------
 let ws.cponom         = "vclcorcod"
 let d_cts00g02.vclcordes = "NAO INFORMADA"

 select cpodes
   into d_cts00g02.vclcordes
   from iddkdominio
  where cponom = ws.cponom
    and cpocod = ws.vclcorcod

 #--------------------------------------------------------------
 # Verifica se veiculo e BLINDADO.
 #--------------------------------------------------------------
 call f_funapol_ultima_situacao (d_cts00g02.succod,
                                 d_cts00g02.aplnumdig,
                                 d_cts00g02.itmnumdig)
     returning g_funapol.*
 let ws.imsvlr = 0
 select imsvlr
   into ws.imsvlr
   from abbmbli
  where succod    = d_cts00g02.succod    and
        aplnumdig = d_cts00g02.aplnumdig and
        itmnumdig = d_cts00g02.itmnumdig and
        dctnumseq = g_funapol.autsitatu

 initialize ws.imsvlrdes to null
 if ws.imsvlr > 0 then
    let ws.imsvlrdes = "BLINDADO"
 end if

 #Marcelo - psi178381 - inicio
 if ws.atdsrvorg  = 15 then
    call cts00g04_msgjittxt(param.atdsrvnum,
                            param.atdsrvano)
                            returning ws.laudo,
                                      l_status
    if l_status <> 0 then
       error ws.laudo
       sleep 3
       let ws.laudo   = null
       let ws.mdtcod  = null
       let ws.tabname = null
       let ws.sqlcode = null
       return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
    end if
 end if
 #Marcelo - psi178381 - fim

 #CT201201879 Inicio
 if d_cts00g02.atdhorpvt  is not null and
       d_cts00g02.atddatprg is null   and
       d_cts00g02.atdhorprg is null   then
 #CT201201879 Fim

#   PSI.188603 - RECUPERA A DATA E HORA DA ULTIMA ETAPA
    let l_atdprvdat = null
    whenever error continue
    select atdetpdat, atdetphor
      into ws.atdetpdat, l_atdprvdat
      from datmsrvacp
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano
       and atdsrvseq = (select max(atdsrvseq)
                          from datmsrvacp
                         where atdsrvnum = param.atdsrvnum
                           and atdsrvano = param.atdsrvano)
    whenever error stop
    if sqlca.sqlcode <> 0  then
       let ws.tabname = "datmsrvacp"
       let ws.sqlcode = sqlca.sqlcode
       return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
    end if
    let ws.atdetphor = l_atdprvdat - l_hour

#   PSI.188603 - SOMAR 'DATA DA ULTIMA ETAPA' A 'PREVISAO DE ATENDIMENTO'
    if d_cts00g02.atdprvdat is null then
       let d_cts00g02.atdprvdat = "00:20"
    end if
    let ws.datahoraqtr = ws.atdetpdat
    let ws.datahoraqtr = ws.datahoraqtr + ws.atdetphor
    let ws.datahoraqtr = ws.datahoraqtr + d_cts00g02.atdprvdat
    #let ws.dispdata    = ws.datahoraqtr #using "dd/mm"
    let ws.disphora    = ws.datahoraqtr

    let ws.msgpvt = extend(ws.datahoraqtr, day to day) clipped, "/",
                    extend(ws.datahoraqtr, month to month) clipped, " ", ws.disphora
 else
    let ws.msgpvt = "Prg:", d_cts00g02.atddatprg , " ",
                            d_cts00g02.atdhorprg
 end if

 #-----------------------------------
 # Nome Reduzido do Veiculo
 #-----------------------------------
 select vcltipnom
   into ws.vcltipnom
   from agbkveic, outer agbktip
  where agbkveic.vclcoddig  = ws.vclcoddig
    and agbktip.vclmrccod   = agbkveic.vclmrccod
    and agbktip.vcltipcod   = agbkveic.vcltipcod

 if sqlca.sqlcode = 0 then
    let d_cts00g02.vcldes = ws.vcltipnom clipped," ",ws.imsvlrdes
 end if

 if m_desc_veiculo = "MOTO" then
    let d_cts00g02.vcldes = "MOTO ", d_cts00g02.vcldes
 end if

 #----------------------------------------------------------------------
 # Formata mensagem de: Remocao, DAF, Socorro, RPT, Replace (AUTOMOVEL)
 #----------------------------------------------------------------------
 if ws.atdsrvorg  =   4    or
    ws.atdsrvorg  =   6    or
    ws.atdsrvorg  =   1    or
    ws.atdsrvorg  =   5    or
    ws.atdsrvorg  =   7    or
   (ws.atdsrvorg  =   2    and ws.asitipcod = 5) or
    ws.atdsrvorg  =  17    then

    if d_cts00g02.roddantxt is not null  then
       let ws.campo = ws.campo clipped, "Rodas Danif:", d_cts00g02.roddantxt clipped
    end if

    if d_cts00g02.atddfttxt is not null  then
       if ws.atdsrvorg =  5   or
          ws.atdsrvorg =  7   or
          ws.atdsrvorg = 17   then
       else
          let ws.campo = ws.campo clipped, d_cts00g02.atddfttxt clipped
       end if
    end if


    if m_veiculo_compl = true then
        let d_cts00g02.vcldes = m_desc_veiculo
    end if

    #TRUNCAMENTO DE CAMPO
    let ws.vcldesc = d_cts00g02.vcldes
    let ws.placa = d_cts00g02.vcllicnum
    let ws.cor = d_cts00g02.vclcordes

    initialize ws.msgpgttxt to null

    select atdetpcod
      into ws.atdetpcod
      from datmsrvacp
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano
       and atdsrvseq = (select max(atdsrvseq)
                          from datmsrvacp
                         where atdsrvnum = param.atdsrvnum
                           and atdsrvano = param.atdsrvano)

       #-------------------------------------------------------------------
       # Formata mensagem para servico cancelado
       #-------------------------------------------------------------------
       if ws.atdetpcod = 5   then
          call ctb00g00(param.atdsrvnum, param.atdsrvano,
                        ws.cnldat      , ws.atdfnlhor)
              returning ws.canpgtcod, ws.difcanhor

          let ws.laudo = l_msgcancela clipped, " ",

                         d_cts00g02.atdsrvnum using "&&&&&&&", "-",
                         d_cts00g02.atdsrvano using "&&",   " ",

                         d_cts00g02.asitipabvdes   clipped, " ",

                         ws.msgpvt                 clipped, " ", #DATA SERVIÇO

              #"QNC:",    ws.vcldesc                clipped, " ", #VEÍCULO ATENDIDO
                         ws.vcldesc                clipped, " ",  #VEÍCULO ATENDIDO
                         #d_cts00g02.vclanomdl      clipped, " ",
              #"QNR:",    d_cts00g02.vcllicnum      clipped, " ",
                         #d_cts00g02.vclcordes      clipped, " "
                         ws.placa                   clipped, " ",  #PLACA
                         ws.cor                     clipped, " "   #COR DO VEÍCULO

          let ws.laudo = ws.laudo clipped, ws.fim

       else

          #TRUNCAMENTO DOS CAMPOS ENDEREÇO
          #let ws.logradouro = a_cts00g02[1].lclidttxt
          let ws.logradouro = a_cts00g02[1].lgdtxt
          let ws.num_logradouro = a_cts00g02[1].lgdnum
          let ws.bairro = a_cts00g02[1].lclbrrnom
          let ws.cidade = a_cts00g02[1].cidnom
          
          ##verifica se servico possui controle de seguranca                                               
          if cty28g00_controla_mecanismo_seguranca(param.atdsrvnum, param.atdsrvano,ws.ciaempcod) then 
             if a_cts00g02[1].lgdnum is not null then
                if a_cts00g02[1].lgdnum >= 1000  then
    	            let ws.num_logradouro = ws.num_logradouro[1,2] clipped, "XX"
    	        else 
    	           if a_cts00g02[1].lgdnum >= 100 then
    	               let ws.num_logradouro = ws.num_logradouro[1,1] clipped, "XX"  	  
    	           else  	     
    	              let ws.num_logradouro = "XX"    	     	
    	           end if
    	        end if
    	     end if 
    	  end if   

          let ws.laudo = l_msginicial

          let ws.laudo = ws.laudo clipped, " ",
                         d_cts00g02.atdsrvnum using "&&&&&&&", "-", #NÚMERO DO SERVIÇO
                         #d_cts00g02.atdsrvano using "&&",   " ",

                         ws.msgpvt                 clipped, "-",  #DATA SERVIÇO

              #"QNC:",   ws.vcldesc                clipped, " ",  #VEÍCULO ATENDIDO
                         ws.vcldesc                 clipped, " ",  #VEÍCULO ATENDIDO
                         #d_cts00g02.vclanomdl       clipped, " ",

              #"QNR:",    d_cts00g02.vcllicnum       clipped, " ",
                         #d_cts00g02.vclcordes       clipped, " ",
                         ws.placa                   clipped, " ",  #PLACA
                         ws.cor                     clipped, " ",  #COR DO VEÍCULO

                         ws.campo                   clipped, " ", #PROBLEMA

              #"QTH:",   a_cts00g02[1].lclidttxt    clipped, " ",

                         #ws.logradouro clipped, " ",
                         ws.logradouro clipped, " ",
                         ws.num_logradouro clipped, " ",
                         ws.bairro clipped, "-",
                         ws.cidade clipped

                         #a_cts00g02[1].lgdtxt       clipped, "-",
                         #a_cts00g02[1].lclbrrnom    clipped, "-",
                         #a_cts00g02[1].cidnom       clipped
                         #a_cts00g02[1].ufdcod       clipped, " "

              if  d_cts00g02.atdrsddes = "SIM"  then
                  let ws.laudo = ws.laudo clipped, " ",
                  "Na Res:", d_cts00g02.atdrsddes
              end if

              #Truncamento do campo responsável
              let ws.resp = a_cts00g02[1].lclcttnom

              let ws.laudo = ws.laudo clipped, " ",
              #"Resp:",           a_cts00g02[1].lclcttnom    clipped, " "  #RESPONSAVEL NO LOCAL
              ws.resp    #RESPONSAVEL NO LOCAL
              {"Tel:",            a_cts00g02[1].dddcod       clipped, " ",
                                  a_cts00g02[1].lcltelnum using "<<<<<<<<"}

            let ws.laudo = ws.laudo clipped, ws.fim
       end if

 end if

 #----------------------------------------------------------------------
 # Formata mensagem de: Sinistro, Socorro (RAMOS ELEMENTARES)
 #----------------------------------------------------------------------
 if ws.atdsrvorg  =  9     or
    ws.atdsrvorg  = 13     then

    select orrdat   , orrhor   ,
           socntzcod, sinntzcod,
           lclrsccod
      into d_cts00g02.orrdat, d_cts00g02.orrhor,
           ws.socntzcod     , ws.sinntzcod     ,
           ws.lclrsccod
      from datmsrvre
     where atdsrvnum = d_cts00g02.atdsrvnum
       and atdsrvano = d_cts00g02.atdsrvano

    if sqlca.sqlcode <> 0  then
       let ws.tabname = "datmsrvre"
       let ws.sqlcode = sqlca.sqlcode
       return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode
    end if

    if ws.socntzcod is not null  then
       select socntzdes
         into d_cts00g02.ntzdes
         from datksocntz
        where socntzcod = ws.socntzcod

    else
       select sinntzdes
         into d_cts00g02.ntzdes
         from sgaknatur
        where sinramgrp = '4'
          and sinntzcod = ws.sinntzcod
    end if

    if d_cts00g02.atddfttxt is not null  then
       let ws.campo = ws.campo clipped, d_cts00g02.atddfttxt clipped
    end if

    #hpn -- ini
    initialize ws.msgpgttxt to null

    select atdetpcod
      into ws.atdetpcod
      from datmsrvacp
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano
       and atdsrvseq = (select max(atdsrvseq)
                          from datmsrvacp
                         where atdsrvnum = param.atdsrvnum
                           and atdsrvano = param.atdsrvano)

    #-------------------------------------------------------------------
    # Formata mensagem para servico cancelado
    #-------------------------------------------------------------------
    call cts29g00_obter_multiplo(1,
                                 param.atdsrvnum,
                                 param.atdsrvano)
    returning ws.resultado,
              ws.mensagem,
              al_retorno[1].*,
              al_retorno[2].*,
              al_retorno[3].*,
              al_retorno[4].*,
              al_retorno[5].*,
              al_retorno[6].*,
              al_retorno[7].*,
              al_retorno[8].*,
              al_retorno[9].*,
              al_retorno[10].*

    if ws.resultado = 3 then
       display ws.mensagem clipped
       let ws.tabname = "cts29g00"
       return ws.resultado, ws.mensagem
    end if

    #let ws.laudo = d_cts00g02.atdvclsgl clipped,
                    #l_msginicial ## psi 211982

    if ws.atdetpcod >= 5   then
       if ws.atdetpcod <> 10 then
          let ws.laudo = ws.laudo clipped, " ", l_msgcancela
       end if
    end if

    let ws.laudo = ws.laudo clipped, " ",
                d_cts00g02.atdsrvnum using "&&&&&&&"#, "-",
                #d_cts00g02.atdsrvano using "&&"," "

    for l_ind = 1 to 10
       if al_retorno[l_ind].atdmltsrvnum is not null then
          let ws.laudo = ws.laudo clipped," ",
                         al_retorno[l_ind].atdmltsrvnum using "&&&&&&&"#, "-",
                         #al_retorno[l_ind].atdmltsrvano using "&&", " "
       end if
    end for

    let ws.laudo = ws.laudo clipped,"-",ws.msgpvt clipped, " "

           if ws.atdetpcod = 10  then
               let ws.laudo = ws.laudo clipped," RET"
           end if

           let ws.laudo = ws.laudo clipped, " "

###        "Solicitado: ", d_cts00g02.atddat          clipped, " as ",
###                        d_cts00g02.atdhor          clipped, " ",

            #let ws.laudo = ws.laudo clipped, " ",  ws.campo clipped, " "

             for l_ind = 1 to 10
               if al_retorno[l_ind].atdmltsrvnum is not null then
                  let ws.laudo = ws.laudo clipped, ' / ', al_retorno[l_ind].atddfttxt
               end if
             end for

           #TRUNCAMENTO DOS CAMPOS ENDEREÇO E RESPONSÁVEL
           #let ws.logradouro = a_cts00g02[1].lclidttxt
           let ws.logradouro_re = a_cts00g02[1].lgdtxt
           let ws.num_logradouro = a_cts00g02[1].lgdnum
           let ws.bairro_re = a_cts00g02[1].lclbrrnom
           let ws.cidade = a_cts00g02[1].cidnom
           let ws.resp = a_cts00g02[1].lclcttnom
           let ws.ntzdes = d_cts00g02.ntzdes
            
           ##verifica se servico possui controle de seguranca                                               
           if cty28g00_controla_mecanismo_seguranca(param.atdsrvnum, param.atdsrvano,ws.ciaempcod) then  
              if a_cts00g02[1].lgdnum is not null then
                 if a_cts00g02[1].lgdnum >= 1000  then
    	            let ws.num_logradouro = ws.num_logradouro[1,2] clipped, "XX"
    	         else 
    	           if a_cts00g02[1].lgdnum >= 100 then
    	               let ws.num_logradouro = ws.num_logradouro[1,1] clipped, "XX"  	  
    	           else  	     
    	              let ws.num_logradouro = "XX"    	     	
    	           end if
    	         end if
    	      end if 
    	   end if   
           
           

           let ws.laudo = ws.laudo clipped, "-",
                          #ws.logradouro clipped, " ",
                          ws.logradouro_re clipped, " ",
                          ws.num_logradouro clipped, " ",
                          ws.bairro_re clipped, " ",
                          ws.cidade clipped, "-",
                          ws.ntzdes clipped, " ",
                          ws.campo clipped, "-",

           #"Resp:",        a_cts00g02[1].lclcttnom    clipped  #" ", #RESPONSAVEL NO LOCAL
                          ws.resp clipped    #RESPONSAVEL NO LOCAL

           {"Tel:",        a_cts00g02[1].dddcod       clipped, " ",
                           a_cts00g02[1].lcltelnum using "<<<<<<<<"}

    end if

 let ws.sqlcode = 0

 let ws.laudo = ws.laudo clipped

 return ws.laudo, ws.mdtcod, ws.tabname, ws.sqlcode

end function    #LAUDO SMS

#PSI 2327337 - FUNÇÃO RESPONSÁVEL POR BUSCAR CELULARES PARA ENVIO DO LAUDO SMS
#O SMS deverá ser enviado para: Celular da viatura OU Número do Nextel da viatura
#OU Celular do Socorrista OU Número do Nextel do Socorrista, nessa ordem de prioridade
#----------------------------------------------------------------------
function cts00g02_busca_cel(param)
#----------------------------------------------------------------------
    define param         record
        socvclcod  like datmservico.socvclcod
    end record

    define ws record
        celdddcod like datkveiculo.celdddcod,
        celtelnum like datkveiculo.celtelnum,
        vclnxtdddcod like datkveiculo.nxtide,
        vclnxtnum like datkveiculo.nxtnum,
        celular   char(13)
    end record

    initialize ws.* to null

    if m_cts00g02_prep is null or
        m_cts00g02_prep <> true then
        call cts00g02_prepare()
    end if

    #BUSCA O CELULAR DO VEÍCULO
    open c_cts00g02_007 using param.socvclcod
    whenever error continue
    fetch c_cts00g02_007 into ws.celdddcod, ws.celtelnum
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let ws.celdddcod = null
          let ws.celtelnum = null
          let ws.celular = null
       else
          error "Erro SELECT c_cts00g02_007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
          error "cts00g02_busca_cel() / ", param.socvclcod sleep 4
       end if
    else
       if (ws.celdddcod is not null and ws.celtelnum is not null)
           or
          (ws.celdddcod <> "" and ws.celtelnum <> "") then
           let ws.celular = ws.celdddcod  clipped,"", ws.celtelnum
           return ws.celular
       end if
    end if
    close c_cts00g02_007

    #BUSCA O ID NEXTEL DO VEÍCULO
    open c_cts00g02_008 using param.socvclcod
    whenever error continue
    fetch c_cts00g02_008 into ws.vclnxtdddcod, ws.vclnxtnum
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let ws.vclnxtdddcod = null
          let ws.vclnxtnum = null
          let ws.celular = null
       else
          error "Erro SELECT c_cts00g02_008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
          error "cts00g02_busca_cel() / ", param.socvclcod sleep 4
       end if
    else
       if (ws.vclnxtdddcod is not null and ws.vclnxtnum is not null)
           or
          (ws.vclnxtdddcod <> "" and ws.vclnxtnum <> "") then
           let ws.celular = ws.vclnxtdddcod  clipped,"", ws.vclnxtnum
            return ws.celular
       end if
    end if
    close c_cts00g02_008

    #BUSCA O CELULAR DO SOCORRISTA
    open c_cts00g02_009 using param.socvclcod
    whenever error continue
    fetch c_cts00g02_009 into ws.vclnxtdddcod, ws.vclnxtnum
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let ws.vclnxtdddcod = null
          let ws.vclnxtnum = null
          let ws.celular = null
       else
           error "Erro SELECT c_cts00g02_009 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
           error "cts00g02_busca_cel() / ", param.socvclcod sleep 4
       end if
    else
      if (ws.vclnxtdddcod is not null and ws.vclnxtnum is not null)
          or
         (ws.vclnxtdddcod <> "" and ws.vclnxtnum <> "") then
           let ws.celular = ws.vclnxtdddcod  clipped,"", ws.vclnxtnum
           return ws.celular
      end if
    end if
    close c_cts00g02_009

    #BUSCAR O NEXTEL DO SOCORRISTA
    open c_cts00g02_011 using param.socvclcod
    whenever error continue
    fetch c_cts00g02_011 into ws.vclnxtdddcod, ws.vclnxtnum
    whenever error stop
    if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           let ws.vclnxtdddcod = null
           let ws.vclnxtnum = null
           let ws.celular = null
        else
           error "Erro SELECT c_cts00g02_011 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
           error "cts00g02_busca_cel() / ", param.socvclcod sleep 4
        end if
    else
      if (ws.vclnxtdddcod is not null and ws.vclnxtnum is not null)
          or
         (ws.vclnxtdddcod <> "" and ws.vclnxtnum <> "") then
          let ws.celular = ws.vclnxtdddcod  clipped,"", ws.vclnxtnum
      end if
    end if
    close c_cts00g02_011

    return ws.celular

end function

##envio de mensagem de complemento
#----------------------------------------------------------------------
 function cts00g02_env_msg_cmp(param)
#----------------------------------------------------------------------

 define param       record
    apltipcod       dec (1,0),
    atdsrvnum       like datmmdtsrv.atdsrvnum,
    atdsrvano       like datmmdtsrv.atdsrvano,
    mdtmsgtxt       like datmmdtmsgtxt.mdtmsgtxt,
    socvclcod       like datkveiculo.socvclcod
 end record

 define ws          record
    mdtmsgnum       like datmmdtmsg.mdtmsgnum,
    mdtcod          like datmmdtmsg.mdtcod,
    mdtmsgtxt       like datmmdtmsgtxt.mdtmsgtxt,
    tabname         like systables.tabname,
    atdvclsgl       like datkveiculo.atdvclsgl,
    mdtctrcod       like datkmdtctr.mdtctrcod,
    parametroctg    char(20),
    sqlcode         integer,
    laudo           char (4500),
    erroflg         char (01),
    hora            char (08),
    data            char (10),
    vez             integer,
    qtdchar         dec  (4,0),
    qtdregtxt       dec  (1,0),
    pgrnum          like datkveiculo.pgrnum,
    dataatu         date,
    horaatu         datetime hour to second,    
    atdsrvorg       like datmservico.atdsrvorg,
    asitipcod       like datmservico.asitipcod,
    ciaempcod       like datmservico.ciaempcod,
    celular         char(13),
    srvtipabvdes    like datksrvtip.srvtipabvdes,
    asitipabvdes    like datkasitip.asitipabvdes,
    socntzcod       like datmsrvre.socntzcod,
    sinntzcod       like datmsrvre.sinntzcod,
    ntzdes          like datksocntz.socntzdes, 
    mensagem        char (80),
    resultado       smallint
 end record

 define lr_sms      record                              
  smsenvcod         like dbsmenvmsgsms.smsenvcod ,      
  celnum            like dbsmenvmsgsms.celnum    ,      
  msgtxt            like dbsmenvmsgsms.msgtxt    ,      
  envdat            like dbsmenvmsgsms.envdat    ,      
  incdat            like dbsmenvmsgsms.incdat    ,      
  celddd            like dbsmenvmsgsms.dddcel           
 end record  
 
 define endereco    record
   lclidttxt        like datmlcl.lclidttxt,
   lgdtxt           char (80),
   lclbrrnom        like datmlcl.lclbrrnom,
   endzon           like datmlcl.endzon,
   cidnom           like datmlcl.cidnom,
   ufdcod           like datmlcl.ufdcod,
   lclrefptotxt     like datmlcl.lclrefptotxt,
   dddcod           like datmlcl.dddcod,
   lcltelnum        like datmlcl.lcltelnum,
   lclcttnom        like datmlcl.lclcttnom
 end record
 
 define l_retorno  record
    codido         smallint, # esse código é o sqlca.sqlcode
    mensagem       char(30)
 end record

 define l_data      date,
        l_hora1     datetime hour to second,
        l_status    smallint,
        l_espdes    like dbskesp.espdes,
        l_natureza  char (200),
        l_mdtmsgstt smallint,
        l_cod_erro   smallint,
        l_msg_erro   char(200),
        l_mdtmsgnum  like datmmdtmsg.mdtmsgnum,
        l_pstcoddig  like dpaksocor.pstcoddig,
        l_socvclcod  like datkveiculo.socvclcod,
        l_srrcoddig  like datksrr.srrcoddig
        
 define lr_cty28g00 record 
        coderro  smallint,
        msgerro  char(40),
        senha    char(04)
 end record
 
 define al_retorno   array[10] of record                  
        atdmltsrvnum like datratdmltsrv.atdmltsrvnum,     
        atdmltsrvano like datratdmltsrv.atdmltsrvano,     
        socntzdes    like datksocntz.socntzdes,           
        espdes       like dbskesp.espdes,                 
        atddfttxt    like datmservico.atddfttxt           
 end record 

 define  w_pf1      integer 
 define l_problema  char(30)
        
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize  ws.*          to  null
 initialize  endereco.*    to  null 
 initialize  lr_sms.*      to  null
 initialize  l_retorno.*   to  null
 initialize  lr_cty28g00.* to  null
 
 for w_pf1 = 1  to  10
     initialize  al_retorno[w_pf1].*  to  null
 end for
 
 # -->INICIALIZACAO DAS VARIAVEIS
  let l_cod_erro  = 0
  let l_msg_erro  = null
  let l_mdtmsgnum = null 
  let l_pstcoddig = null
  let l_socvclcod = null
  let l_srrcoddig = null   
  
 if m_cts00g02_prep is null or
    m_cts00g02_prep <> true then
    call cts00g02_prepare()
 end if

 initialize  ws.*  to  null

 call cts40g03_data_hora_banco(1)
      returning l_data, l_hora1

 initialize ws.* to null
 let ws.erroflg  =  "N"
 let ws.data     =  l_data
 let l_problema  = null

 #-------------------------------------------------------------------------
 # Checa parametros informados
 #-------------------------------------------------------------------------
 if (param.apltipcod  is null)  or
    (param.apltipcod  <>  1     and    #-> 1-Online, 2-Batch
     param.apltipcod  <>  2)    then
    let ws.erroflg  =  "S"
    error " Parametro tipo aplicacao incorreto, AVISE INFORMATICA!"
    return ws.erroflg
 end if

 if (param.atdsrvnum  is null   or
     param.atdsrvano  is null)  and
     param.mdtmsgtxt  is null   then
    let ws.erroflg  =  "S"
    if param.apltipcod  =  1   then
       error   " Texto ou nro servico nao informado, AVISE INFORMATICA!"
    else
       display " Texto ou nro servico nao informado, AVISE INFORMATICA!"
    end if
    return ws.erroflg
 end if

 if (param.atdsrvnum  is not null   or
     param.atdsrvano  is not null)  and
     param.mdtmsgtxt  is not null   then
    let ws.erroflg  =  "S"
    if param.apltipcod  =  1   then
       error   " Texto e nro servico informados, AVISE INFORMATICA!"
    else
       display " Texto e nro servico informados, AVISE INFORMATICA!"
    end if
    return ws.erroflg
 end if

 if param.socvclcod  is null   then
    let ws.erroflg  =  "S"
    if param.apltipcod  =  1   then
       error   " Codigo do veiculo nao informado, AVISE INFORMATICA!"
    else
       display " Codigo do veiculo nao informado, AVISE INFORMATICA!"
    end if
    return ws.erroflg
 end if
 
 whenever error continue
 ##verifica endereco  
 call ctx04g00_local_reduzido(param.atdsrvnum, param.atdsrvano, 1)
     returning endereco.lclidttxt thru endereco.lclcttnom,ws.sqlcode
 

 if ws.sqlcode  <>  0   then
    let ws.erroflg  =  "S"
    if param.apltipcod  =  1   then
       error   " Erro (",ws.sqlcode,") na tabela ", ws.tabname," !"
    else
       call cts40g03_data_hora_banco(1)
            returning l_data, l_hora1
       let ws.hora  =  l_hora1
       display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                                    "-", param.atdsrvano using "&&"    ,
                       ": Erro (", ws.sqlcode using "<<<<<&",
                       ") na inclusao da tabela ", ws.tabname
    end if
    return ws.erroflg
 end if 
 
 ##verifica informacoes veiculo
 select mdtcod,
        pgrnum,
        atdvclsgl 
   into ws.mdtcod,
        ws.pgrnum, 
        ws.atdvclsgl
   from datkveiculo
  where socvclcod  =  param.socvclcod
  
  ##verifica informações serviço
  open c_cts00g02_016 using param.atdsrvnum, param.atdsrvano     
   fetch c_cts00g02_016 into ws.ciaempcod, ws.asitipcod, ws.atdsrvorg                             
  close c_cts00g02_016   
  
  ##verifica informações tipo do serviço
  select srvtipabvdes               
  into ws.srvtipabvdes    
  from datksrvtip                 
 where atdsrvorg = ws.atdsrvorg 
  
  
  #----------------------------------------------------------------------
  # Formata mensagem de: Sinistro, Socorro (RAMOS ELEMENTARES)
  #----------------------------------------------------------------------
  if ws.atdsrvorg  =  9     or
     ws.atdsrvorg  = 13     then

     select socntzcod, sinntzcod            
       into ws.socntzcod , ws.sinntzcod   
       from datmsrvre
      where atdsrvnum = param.atdsrvnum
        and atdsrvano = param.atdsrvano

     if sqlca.sqlcode <> 0  then
        let ws.erroflg  =  "S"
        if param.apltipcod  =  1   then
           error   " Erro (",ws.sqlcode,") na tabela datmsrvre!"
        else
           call cts40g03_data_hora_banco(1)
                returning l_data, l_hora1
           let ws.hora  =  l_hora1
           display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                                        "-", param.atdsrvano using "&&"    ,
                           ": Erro (", ws.sqlcode using "<<<<<&",
                           ") na inclusao da tabela datmsrvre"
        end if
        return ws.erroflg 
     end if

     if ws.socntzcod is not null  then
        select socntzdes
          into ws.ntzdes
          from datksocntz
         where socntzcod = ws.socntzcod

     else
        select sinntzdes
          into ws.ntzdes
          from sgaknatur
         where sinramgrp = '4'
           and sinntzcod = ws.sinntzcod
     end if

   
     call cts29g00_obter_multiplo(1,
                                  param.atdsrvnum,
                                  param.atdsrvano)
     returning ws.resultado,
               ws.mensagem,
               al_retorno[1].*,
               al_retorno[2].*,
               al_retorno[3].*,
               al_retorno[4].*,
               al_retorno[5].*,
               al_retorno[6].*,
               al_retorno[7].*,
               al_retorno[8].*,
               al_retorno[9].*,
               al_retorno[10].*

     if ws.resultado = 3 then
         let ws.erroflg  =  "S"
         if param.apltipcod  =  1   then
            error   " Erro (",ws.mensagem,") cts29g00_obter_multiplo!"
         else
            call cts40g03_data_hora_banco(1)
                 returning l_data, l_hora1
            let ws.hora  =  l_hora1
            display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                                         "-", param.atdsrvano using "&&"    ,
                            ": Erro (", ws.mensagem using "<<<<<&",
                            ") na funcao cts29g00_obter_multiplo"
         end if
         return ws.erroflg        
     end if 

     let l_natureza = null                            

     let l_espdes = null

     # --BUSCA A DESCRICAO DA ESPECIALIDADE DO SERVICO
     let l_espdes = cts00g02_busca_especialidade(param.atdsrvnum,
                                                 param.atdsrvano)

     

     # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
     if l_espdes is not null and
        l_espdes <> " " then
        let l_natureza = "Natureza:",
                         ws.ntzdes clipped, " - ", l_espdes clipped, " "
     else
        let l_natureza = "Natureza:",
                          ws.ntzdes clipped, " "
     end if
     
     let l_problema  = ws.ntzdes clipped

     for w_pf1 = 1 to 10
        if al_retorno[w_pf1].atdmltsrvnum is not null then

           let l_espdes = null

           # --BUSCA A DESCRICAO DA ESPECIALIDADE DO SERVICO
           let l_espdes = cts00g02_busca_especialidade(al_retorno[w_pf1].atdmltsrvnum,
                                                       al_retorno[w_pf1].atdmltsrvano)

           # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
           if l_espdes is not null and
              l_espdes <> " " then
              let l_natureza = l_natureza clipped, ' / ',
                               al_retorno[w_pf1].socntzdes clipped, " - ",
                               l_espdes
           else
              let l_natureza = l_natureza clipped, ' / ',
                               al_retorno[w_pf1].socntzdes
           end if
        end if
     end for             
  else 
      # Descricao do tipo de assistencia             
      let ws.asitipabvdes = "NAO PREV."              
                                                     
      select asitipabvdes                            
        into ws.asitipabvdes                         
        from datkasitip                              
       where asitipcod = ws.asitipcod  
  end if
     
       
  whenever error stop
  
  ##verifica senha de seguranca   
  call cty28g00_consulta_senha(param.atdsrvnum, param.atdsrvano)
   returning  lr_cty28g00.senha   ,
              lr_cty28g00.coderro ,
              lr_cty28g00.msgerro 
           
  if  lr_cty28g00.coderro <> 0 then 
      let ws.erroflg  =  "S"
      if param.apltipcod  =  1   then
         error lr_cty28g00.msgerro   clipped  
      else
         display lr_cty28g00.msgerro clipped
      end if
      return ws.erroflg 
  end if          

  let ws.laudo = "ATENCAO ",                          ws.atdvclsgl          clipped, " ",     
                 "MENSAGEM DE COMPLEMENTO DA QRU: ",  ws.atdsrvorg          using    "&&"     , "/",            
                                                      param.atdsrvnum       using    "&&&&&&&", "-",            
                                                      param.atdsrvano       using    "&&" 
                  
  if ws.atdsrvorg  =  9     or                                         
     ws.atdsrvorg  = 13     then  
     
     let ws.laudo = ws.laudo clipped, " ", l_natureza            clipped     
  else
     let ws.laudo = ws.laudo clipped, " ", ws.asitipabvdes       clipped    
     let l_problema  = ws.asitipabvdes       clipped  
  end if
  
  
  let ws.laudo = ws.laudo clipped , " QTH: ",                             endereco.lgdtxt       clipped, " ",              
                                                                         endereco.lclbrrnom    clipped, " ",              
                                                                         endereco.cidnom       clipped, " ", 
                                    "SENHA DE ATENDIMENTO:",             lr_cty28g00.senha     clipped, " ",
                                    "INFORME A SUA SENHA DE ATENDIMENTO AO CLIENTE CASO SEJA SOLICITADA"
 
 ##se acionamento WEB ATIVO grava no informix transmissão como enviada e envia mensagem pelo AW
 if ctx34g00_ver_acionamentoWEB(2) then
    let l_mdtmsgstt = 6 ##RECEBIDA OK
    
    # -->BUSCA O CODIGO PRESTADOR, VEICULO E SOCORRISTA DO MDT
     open c_cts00g02_017 using ws.mdtcod

     whenever error continue
     fetch c_cts00g02_017 into l_pstcoddig,
                               l_socvclcod,
                               l_srrcoddig
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let l_cod_erro = sqlca.sqlcode
        if sqlca.sqlcode <> notfound then
           let l_msg_erro = "Erro SELECT c_cts00g02_017 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           call errorlog(l_msg_erro)
           let l_msg_erro = "ctx00g02_env_msg_cmp() / ", ws.mdtcod
           call errorlog(l_msg_erro)
        end if
     end if

     close c_cts00g02_017

     if l_cod_erro = 0 then
        call ctx34g02_enviar_msg_gps(l_pstcoddig,
                                     l_socvclcod,
                                     l_srrcoddig,
                                     ws.laudo)
             returning l_cod_erro, l_mdtmsgnum
        #display "l_cod_erro", l_cod_erro
        #display "l_mdtmsgnum", l_mdtmsgnum
     end if   
     
 else
    let l_mdtmsgstt = 1 ##AGUARDANDO TRANSMISSAO 
 end if 
  
 #-------------------------------------------------------------------------
 # Grava tabelas para envio de mensagem
 #-------------------------------------------------------------------------
 whenever error continue

   insert into datmmdtmsg ( mdtmsgnum,                                      
                            mdtmsgorgcod,                                   
                            mdtcod,                                         
                            mdtmsgstt,                                      
                            mdtmsgavstip )                                  
                 values   ( 0,                                              
                            2,           #--> Origem identifica que mensagem é de complemento                                    
                            ws.mdtcod,                                      
                            l_mdtmsgstt,        
                            3 )          #--> Sinal bip e sirene            
                                                                            
   if sqlca.sqlcode  <>  0   then
      let ws.erroflg  =  "S"
      if param.apltipcod  =  1   then
         error   " Erro (",sqlca.sqlcode,") na inclusao tabela datmmdtmsg !"
      else
         call cts40g03_data_hora_banco(1)
              returning l_data, l_hora1
         let ws.hora  =  l_hora1
         display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                                      "-", param.atdsrvano using "&&"    ,
                         ": Erro (", sqlca.sqlcode using "<<<<<&",
                         ") na inclusao da tabela datmmdtmsg"
      end if
      return ws.erroflg
   end if

   let ws.mdtmsgnum  =  sqlca.sqlerrd[2]

   #select today, current                                            
   #  into ws.dataatu, ws.horaatu                                    
   #  from dual                # BUSCA DATA E HORA DO BANCO          
   call cts40g03_data_hora_banco(1)
      returning ws.dataatu, ws.horaatu

   insert into datmmdtlog ( mdtmsgnum,
                            mdtlogseq,
                            mdtmsgstt,
                            atldat,
                            atlhor,
                            atlemp,
                            atlmat )
                  values  ( ws.mdtmsgnum,
                            1,
                            l_mdtmsgstt,
                            ws.dataatu,
                            ws.horaatu,
                            g_issk.empcod,
                            g_issk.funmat )

   if sqlca.sqlcode  <>  0   then
      let ws.erroflg  =  "S"
      if param.apltipcod  =  1   then
         error   " Erro (",sqlca.sqlcode,") na inclusao tabela datmmdtlog !"
      else
         call cts40g03_data_hora_banco(1)
              returning l_data, l_hora1
         let ws.hora  =  l_hora1
         display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                                      "-", param.atdsrvano using "&&"    ,
                         ": Erro (", sqlca.sqlcode using "<<<<<&",
                         ") na inclusao da tabela datmmdtlog"
      end if
      return ws.erroflg
   end if

   let ws.qtdchar  =  length(ws.laudo)

   if ws.qtdchar  <  2001   then
      let ws.qtdregtxt  =  1
   else
      let ws.qtdregtxt  =  2
   end if

   for ws.vez = 1  to  ws.qtdregtxt

     if ws.vez  =  1   then
        let ws.mdtmsgtxt  =  ws.laudo[0001,2000]
     else
        let ws.mdtmsgtxt  =  ws.laudo[2001,4000]
     end if


     insert into datmmdtmsgtxt ( mdtmsgnum,
                                 mdtmsgtxtseq,
                                 mdtmsgtxt )
                     values    ( ws.mdtmsgnum,
                                 ws.vez,
                                 ws.mdtmsgtxt )

     if sqlca.sqlcode  <>  0   then
        let ws.erroflg  =  "S"
        if param.apltipcod  =  1   then
           error " Erro (",sqlca.sqlcode,") na inclusao tabela datmmdtmsgtxt !"
        else
           call cts40g03_data_hora_banco(1)
                returning l_data, l_hora1
           let ws.hora  =  l_hora1
           display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                                        "-", param.atdsrvano using "&&"    ,
                           ": Erro (", sqlca.sqlcode using "<<<<<&",
                           ") na inclusao da tabela datmmdtmsgtxt"
        end if
        return ws.erroflg
     end if

   end for

   if param.atdsrvnum  is not null   then

      insert into datmmdtsrv ( mdtmsgnum,
                               atdsrvnum,
                               atdsrvano )
                     values  ( ws.mdtmsgnum,
                               param.atdsrvnum,
                               param.atdsrvano )

      if sqlca.sqlcode  <>  0   then
         let ws.erroflg  =  "S"
         if param.apltipcod  =  1   then
            error   " Erro (",sqlca.sqlcode,") na inclusao tabela datmmdtsrv !"
         else
           call cts40g03_data_hora_banco(1)
                returning l_data, l_hora1
            let ws.hora  =  l_hora1
            display ws.hora," ===> SERVICO ", param.atdsrvnum using "&&&&&&&",
                                         "-", param.atdsrvano using "&&"    ,
                            ": Erro (", sqlca.sqlcode using "<<<<<&",
                            ") na inclusao da tabela datmmdtsrv"
         end if
         return ws.erroflg
      end if

   end if

 whenever error stop

 if param.apltipcod  =  1   then
    error " *** MENSAGEM SENDO TRANSMITIDA PARA O MDT, PROSSIGA ***"
 end if

 ###PSI 237337 - VERIFICA SE CONTROLADORA ESTÁ EM CONTINGÊNCIA
 select mdtctrcod
   into ws.mdtctrcod
   from datkmdt
  where mdtcod = ws.mdtcod

 let ws.parametroctg = 'PSOCTGCTR', ws.mdtctrcod
 open  c_cts00g02_006 using ws.parametroctg
 fetch c_cts00g02_006

 if sqlca.sqlcode  <>  notfound   then
    
    
    if param.apltipcod  =  1   then
       error "Servico enviado tambem por SMS! (controladora da viatura em contingencia SMS)" 
    else
       display "Servico enviado tambem por SMS! (controladora da viatura em contingencia SMS)"    
    end if   
    
    #Buscar celulares
    call cts00g02_busca_cel(param.socvclcod)
        returning ws.celular
    
    if ws.celular is null or ws.celular = "" then
        if param.apltipcod  =  1   then
           error "Mensagem nao enviada, nenhum numero de envio cadastrado ", param.socvclcod sleep 4
        else 
           display "Mensagem nao enviada, nenhum numero de envio cadastrado "
        end if
        let ws.erroflg = 'S'
        return ws.erroflg
    else  
    
        #INSERE TABELA dbsmenvmsgsms PARA ENVIO SMS
        let lr_sms.smsenvcod = "C"                                   ,
                           param.atdsrvnum using "<<<<<<<<<&",
                           param.atdsrvano using "<<<<<<<<<&"
    
        let lr_sms.celddd = ws.celular[1,2]
        let lr_sms.celnum = ws.celular[5,13]
        let lr_sms.incdat = current
        let lr_sms.envdat = current
        
        #formata msg sms
        let ws.laudo = "ATENCAO ",                  ws.atdvclsgl          clipped,                
                " COMPLEMENTO DA QRU: ",            ws.atdsrvorg          using "&&"     , "/",            
                                                    param.atdsrvnum       using "&&&&&&&", "-",            
                                                    param.atdsrvano       using "&&",   " ",  
                                                    l_problema            clipped, " ",                                                                          
                "QTH: ",                            endereco.lgdtxt       clipped, " ",              
                                                    endereco.lclbrrnom    clipped, " ",              
                                                    endereco.cidnom       clipped, " ", 
                "SENHA DE ATENDIMENTO:",            lr_cty28g00.senha     clipped
               
        let lr_sms.msgtxt = ws.laudo clipped
    
        call ctb85g02_envia_sms(lr_sms.smsenvcod,
                                lr_sms.celnum   ,
                                lr_sms.msgtxt   ,
                                lr_sms.envdat   ,
                                lr_sms.incdat   ,
                                lr_sms.celddd   )
                       returning l_retorno.mensagem,
                                 l_retorno.codido
                                 
        if l_retorno.codido <> 100 then
           if param.apltipcod  =  1   then
              error l_retorno.mensagem clipped," ", l_retorno.codido
           else 
             display  l_retorno.mensagem clipped," ", l_retorno.codido
           end if
        end if      
    
        
        whenever error stop

    end if

 end if
 close c_cts00g02_006
 return ws.erroflg

end function  ###--- cts00g02

