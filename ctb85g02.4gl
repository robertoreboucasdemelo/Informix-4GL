#############################################################################
# Nome do Modulo: ctb85g02                                           Sergio #
#                                                                    Burini #
# Validações de SMS Porto Socorro                                  Dez/2009 #
# ######################################################################### #
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL   DESCRICAO                          #
#---------------------------------------------------------------------------#
# 23/02/2010  PSI 253006   Beatriz       Função que gravar na tabela de     #
#                                        envio de sms os parametro recebidos#
# 09/12/2010  PAS086894    Sergio Burini Inclusao da empresa 84 (ISAR)      #
# 14/04/2010  PSI242853    Adriano Santo Inclusao da envio para PSS e trata-#
#                                        mento do retorno ctb85g02_envia_msg#
#---------------------------------------------------------------------------#
# 21/10/2010  Alberto Rodrigues          Correcao de ^M                     #
# 29/11/2010  PSI01979/PB  Sergio Burini Correções na fraseologia.          #
#                                                                           #
# 15/07/2013  PSI201315767 Jorge Modena  Mecanismo de Seguranca             #
# 17/09/2013               Issamu        Remoção de espaços em branco       #
#---------------------------------------------------------------------------#

 database porto

#------------------------------#
 function ctb85g02_prepare()
#------------------------------#

     define l_sql char(1500)

     let l_sql = "select c24solnom, ",
                       " ciaempcod, ",
                       " atdsrvorg, ",
                       " srvprsacnhordat,",
                       " socvclcod ",
                 "  from datmservico ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? "

     prepare p_ctb85g02_001 from l_sql
     declare c_ctb85g02_001 cursor for p_ctb85g02_001

     let l_sql = "select srrcoddig, ",
                  "      pstcoddig  ",
                  " from datmsrvacp a ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and atdetpcod in (3,4,10) ",
                   " and atdsrvseq in (select max(atdsrvseq) ",
                                       " from datmsrvacp b ",
                                      " where a.atdsrvnum = b.atdsrvnum ",
                                        " and a.atdsrvano = b.atdsrvano) "

     prepare p_ctb85g02_002 from l_sql
     declare c_ctb85g02_002 cursor for p_ctb85g02_002

     let l_sql = "select srrabvnom ",
                  " from datksrr ",
                 " where srrcoddig = ? "

     prepare p_ctb85g02_003 from l_sql
     declare c_ctb85g02_003 cursor for p_ctb85g02_003

     let l_sql = "select empsgl ",
                  " from gabkemp ",
                 " where empcod = ? "

     prepare p_ctb85g02_004 from l_sql
     declare c_ctb85g02_004 cursor for p_ctb85g02_004

     let l_sql = "select 1 ",
                  " from dbsmenvmsgsms ",
                 " where smsenvcod = ? "

     prepare p_ctb85g02_005 from l_sql
     declare c_ctb85g02_005 cursor for p_ctb85g02_005

     let l_sql = "select mpacidcod ",
                  " from datkmpacid ",
                 " where cidnom = ? ",
                   " and ufdcod = ? "

     prepare p_ctb85g02_006 from l_sql
     declare c_ctb85g02_006 cursor for p_ctb85g02_006

     let l_sql = "select 1 ",
                  " from dbsmsmsalrcid ",
                 " where mpacidcod    = ? ",
                   " and envstt = ? "

     prepare p_ctb85g02_007 from l_sql
     declare c_ctb85g02_007 cursor for p_ctb85g02_007

     let l_sql = "select celteldddcod, ",
                       " celtelnum, ",
                       " dddcod, ",
                       " lcltelnum, ",
                       " cidnom, ",
                       " ufdcod ",
                  " from datmlcl ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and c24endtip = 1 "

     prepare p_ctb85g02_008 from l_sql
     declare c_ctb85g02_008 cursor for p_ctb85g02_008
     let l_sql = "insert into dbsmenvmsgsms ",
                 "(smsenvcod,celnum,msgtxt,envdat,incdat,envstt,errmsg,dddcel,envprghor)",
                 " values (?,?,?,?,?,?,?,?,?)"
     prepare pbctb85g02_09 from l_sql
     let l_sql = "select 1 ",
                  " from datkgeral ",
                 " where grlchv in (?,?) "

     prepare pbctb85g02_10 from l_sql
     declare cqctb85g02_10 cursor for pbctb85g02_10

     let l_sql = "select 1 ",
                  " from datmsrvre ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and atdorgsrvnum is not null ",
                   " and atdorgsrvano is not null "
     prepare pbctb85g02_11 from l_sql
     declare cqctb85g02_11 cursor for pbctb85g02_11

     let l_sql = "select 1 ",
                  " from dbsmenvmsgsms ",
                 " where smsenvcod = ? "

     prepare pbctb85g02_12 from l_sql
     declare cqctb85g02_12 cursor for pbctb85g02_12

     let l_sql = "select cidnom, ",
                       " brrnom ",
                  " from datmfrtpos "
                ," where socvclcod = ? "
                ," and   socvcllcltip = 1 "

     prepare pbctb85g02_13 from l_sql
     declare cqctb85g02_13 cursor for pbctb85g02_13

     let l_sql = "select 1 ",
                  " from iddkdominio ",
                 " where cponom = 'VRFTELCELSMS' ",
                   " and cpocod = ? "

     prepare pbctb85g02_14 from l_sql
     declare cqctb85g02_14 cursor for pbctb85g02_14
     # para verificar se já foi enviada uma mensagem para este servico
     let l_sql =  "select smsenvcod   ",
                  "  from dbsmenvmsgsms",
                  " where smsenvcod = ?"
     prepare pbctb85g02_15 from l_sql
     declare cqctb85g02_15 cursor for pbctb85g02_15
     let l_sql =  "select socntzdes         ",
                  "  from datmsrvre srv,    ",
                  "       datksocntz ntz    ",
                  " where atdsrvnum =     ? ",
                  "   and atdsrvano =     ? ",
                  "   and ntz.socntzcod = srv.socntzcod "
     prepare pbctb85g02_16 from l_sql
     declare cqctb85g02_16 cursor for pbctb85g02_16
     let l_sql =  "select nom,          ",
                  "       atdlibdat,    ",
                  "       atdlibhor,    ",
                  "       atddatprg,    ",
                  "       atdhorprg,    ",
                  "       atddfttxt,    ",
                  "       atdprscod     ",
                  "  from datmservico   ",
                  " where atdsrvnum = ? ",
                  "   and atdsrvano = ? "
     prepare pbctb85g02_17 from l_sql
     declare cqctb85g02_17 cursor for pbctb85g02_17
     let l_sql =  "select nomgrr        ",
                  "  from dpaksocor     ",
                  " where pstcoddig = ? "
     prepare pbctb85g02_18 from l_sql
     declare cqctb85g02_18 cursor for pbctb85g02_18
     let l_sql =  "select endcmp        ",
                  "  from datmlcl       ",
                  " where atdsrvnum = ? ",
                  "   and atdsrvano = ? "
     prepare pbctb85g02_19 from l_sql
     declare cqctb85g02_19 cursor for pbctb85g02_19

     let l_sql = "select 1 ",
                  " from iddkdominio ",
                 " where cponom = ? ",
                   " and cpodes = ? "

     prepare pbctb85g02_20 from l_sql
     declare cqctb85g02_20 cursor for pbctb85g02_20

     let l_sql = "select first 1 min(lignum), ",
                       " c24astcod ",
                  " from datmligacao ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                     " group by 2 ",
                     " order by 1 "

     prepare pbctb85g02_21 from l_sql
     declare cqctb85g02_21 cursor for pbctb85g02_21


      let l_sql = "select smsenvflg     ",
                  " from datmservicocmp ",
                 " where atdsrvnum = ?  ",
                  " and atdsrvano = ?   "
      prepare pbctb85g02_22 from l_sql
      declare cqctb85g02_22 cursor for pbctb85g02_22

      let l_sql = " select min(lignum) ",
              " from datmligacao ",
             " where atdsrvnum = ? ",
             "  and  atdsrvano = ? "

      prepare pbctb85g02_23 from l_sql
      declare cqctb85g02_23 cursor for pbctb85g02_23

      let l_sql = " select lgdtip        ",
                  "       ,lgdnom        ",
                  "       ,lgdnum        ",
                  "       ,brrnom        ",
                  "       ,cidnom        ",
                  "   from datmlcl       ",
                  "  where atdsrvnum = ? ",
                  "   and  atdsrvano = ? ",
                  "   and  c24endtip = 1 "
      prepare pbctb85g02_24 from l_sql
      declare cqctb85g02_24 cursor for pbctb85g02_24

      let l_sql = " select lcl.c24lclpdrcod,  ",
                  "        acp.envtipcod     ",
                  "   from datmlcl lcl        ",
                  "       ,datmsrvacp acp     ",
                  "  where acp.atdsrvnum = lcl.atdsrvnum ",
                  "    and acp.atdsrvano = lcl.atdsrvano ",
                  "   and  lcl.atdsrvnum = ? ",
                  "   and  lcl.atdsrvano = ? ",
                  "   and  lcl.c24endtip = 1 ",
                  "   and  acp.atdsrvseq = (select max(atdsrvseq)         ",
                  "                           from datmsrvacp             ",
                  "                          where atdsrvnum  = ?         ",
                  "                            and atdsrvano = ?          ",
                  "                            and atdetpcod in (3,4))    "
      prepare pbctb85g02_25 from l_sql
      declare cqctb85g02_25 cursor for pbctb85g02_25

     let l_sql = "select 1 ",
                  " from datkdominio ",
                 " where cponom = ? ",
                   " and cpodes = ? "

     prepare pbctb85g02_26 from l_sql
     declare cqctb85g02_26 cursor for pbctb85g02_26

 end function

#----------------------------------#
 function ctb85g02_envia_msg(param)
#----------------------------------#

     define param record
         codigo    smallint,
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
     end record

     define l_retorno record
       codigo  smallint, # 0 -> OK, 1 -> Nao enviado sms, 2 -> Erro de banco
       mensagem  char(100)
     end record

     define lr_cidade record
         retorno    smallint,
         mensagem   char(100)
     end record

     define lr_dados record
         lignum          like datmligacao.lignum,
         c24astcod       like datmligacao.c24astcod,
         c24solnom       like datmservico.c24solnom,
         ciaempcod       like datmservico.ciaempcod,
         atdsrvorg       like datmservico.atdsrvorg,
         srvprsacnhordat like datmservico.srvprsacnhordat,
         empsgl          like gabkemp.empsgl,
         srrcoddig       like datksrr.srrcoddig,
         srrabvnom       like datksrr.srrabvnom,
         pstcoddig       like dpaksocor.pstcoddig,
         socvclcod       like datmservico.socvclcod,
         brrnom          like datmfrtpos.brrnom,
         cidnom          like datmfrtpos.cidnom
     end record

     define lr_sms record
         codigo    like dbsmenvmsgsms.smsenvcod,
         dddcel    like datmlcl.celteldddcod,
         celnum    like datmlcl.celtelnum,
         dddcod    like datmlcl.dddcod,
         lcltelnum like datmlcl.lcltelnum,
         texto     like dbsmenvmsgsms.msgtxt,
         cidnom    like datmlcl.cidnom,
         ufdcod    like datmlcl.ufdcod
     end record

     define lr_cts29g00 record
         atdsrvnum    like datratdmltsrv.atdsrvnum,
         atdsrvano    like datratdmltsrv.atdsrvano,
         resultado    smallint,
         mensagem     char(100)
     end record

     define lr_cty28g00 record
        senha           char(04),
        coderro         smallint,
        msgerro         char(40)
     end record

     define lr_endclim18 record
        lgdtip   char(3)
       ,lgdnom   char(19)
       ,lgdnum   like datmlcl.lgdnum
       ,brrnom   char(11)
       ,cidnom   char(7)
       ,endcom   char(55)
     end record

     define lr_datmlclm18 record
        lgdtip   like datmlcl.lgdtip
       ,lgdnom   like datmlcl.lgdnom
       ,lgdnum   like datmlcl.lgdnum
       ,brrnom   like datmlcl.brrnom
       ,cidnom   like datmlcl.cidnom
     end record

     define l_cur       date,
            l_status               smallint,
            l_socntzdes            like datksocntz.socntzdes,
            l_nom                  like datmservico.nom,
            l_atdlibdat            like datmservico.atdlibdat,
            l_atdlibhor            like datmservico.atdlibhor,
            l_atddatprg            like datmservico.atddatprg,
            l_atdhorprg            like datmservico.atdhorprg,
            l_atddfttxt            like datmservico.atddfttxt,
            l_atdprscod            like datmservico.atdprscod,
            l_nomgrr               like dpaksocor.nomgrr,
            l_endcmp               like datmlcl.endcmp,
            l_envstt               like dbsmenvmsgsms.envstt,
            l_aux                  smallint,
            l_codigom18            like dbsmenvmsgsms.smsenvcod,
            l_textom18             like dbsmenvmsgsms.msgtxt,
            l_ufcidm18             char(50),
            l_gravam18             smallint,
            l_sufixolinkm18        char(15),
            l_c24lclpdrcodm18      like datmlcl.c24lclpdrcod,
            l_envtipcodm18         like datmsrvacp.envtipcod,
            l_count                smallint

     let l_socntzdes        = null
     let l_nom              = null
     let l_atdlibdat        = null
     let l_atdlibhor        = null
     let l_atddatprg        = null
     let l_atdhorprg        = null
     let l_atddfttxt        = null
     let l_atdprscod        = null
     let l_nomgrr           = null
     let l_endcmp           = null
     let l_sufixolinkm18    = null
     let l_envstt           = 'A'
     let l_aux              = null
     let l_gravam18         = false
     let l_c24lclpdrcodm18  = null
     let l_count            = 0

     initialize lr_dados.*,
                l_retorno.*,
                lr_sms.*,
                lr_cts29g00.*,
                lr_endclim18.*,
                lr_datmlclm18.* to null

     if param.codigo    is null or
        param.atdsrvnum is null or
        param.atdsrvano is null or
        param.codigo    = " "   or
        param.atdsrvnum = " "   or
        param.atdsrvano = " "   then
        let l_retorno.codigo = 1
        let l_retorno.mensagem = 'Parametros inválidos',param.codigo, ' - ',
                                                        param.atdsrvnum, ' - ',
                                                        param.atdsrvano, ' - '
        return l_retorno.codigo,
               l_retorno.mensagem
     end if
     call ctb85g02_prepare()

     # BUSCA INFORMAÇÕES NA DATMSERVICO
     whenever error continue
     open c_ctb85g02_001 using param.atdsrvnum,
                               param.atdsrvano
    fetch c_ctb85g02_001 into  lr_dados.c24solnom,
                               lr_dados.ciaempcod,
                               lr_dados.atdsrvorg,
                               lr_dados.srvprsacnhordat,
                               lr_dados.socvclcod
     whenever error stop
     if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
        let l_retorno.codigo = 2
        let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_01'
        return l_retorno.codigo,
               l_retorno.mensagem
     end if

     open cqctb85g02_21 using param.atdsrvnum,
                              param.atdsrvano
    fetch cqctb85g02_21 into  lr_dados.lignum,
                              lr_dados.c24astcod

     if  ctb85g02_verifica_assunto("SENHA_ASSUNTO", lr_dados.c24astcod) then
         let l_retorno.codigo   = 2
         let l_retorno.mensagem = "ASSUNTO SEM SMS"
         return l_retorno.codigo,
                l_retorno.mensagem
     end if

     # BUSCA SIGLA DAEMPRESA PARA COLOCAR NO CABECALHO DO SMS
     if lr_dados.ciaempcod = 84 then
        let lr_dados.empsgl = 'ITAU AUTO'
        call ctb85g02_itau(param.atdsrvnum,
                           param.atdsrvano)
           returning l_retorno.codigo,   # 0- Envia SMS, 1 - Nao Envia, 2 - Ocorreu erro
                     l_retorno.mensagem

           if l_retorno.codigo <> 0 then
              return l_retorno.codigo,
                     l_retorno.mensagem
           end if
     else
        whenever error continue
        open c_ctb85g02_004 using lr_dados.ciaempcod
       fetch c_ctb85g02_004 into  lr_dados.empsgl
        whenever error stop
        if sqlca.sqlcode <> 0 and
           sqlca.sqlcode <> 100 then
           let l_retorno.codigo = 2
           let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_04'
           return l_retorno.codigo,
                  l_retorno.mensagem
        end if
     end if
     # BUSCA NOME DO SOCORRISTA
     whenever error continue
     open c_ctb85g02_002 using param.atdsrvnum,
                               param.atdsrvano
    fetch c_ctb85g02_002 into  lr_dados.srrcoddig,
                               lr_dados.pstcoddig

     open cqctb85g02_13 using lr_dados.socvclcod
    fetch cqctb85g02_13 into  lr_dados.cidnom,
                              lr_dados.brrnom

     let lr_dados.cidnom = ctb85g02_limpa_texto_cmp(lr_dados.cidnom)
     let lr_dados.brrnom = ctb85g02_limpa_texto_cmp(lr_dados.brrnom)

     whenever error stop
     if sqlca.sqlcode <> 0 and
        sqlca.sqlcode <> 100 then
        let l_retorno.codigo = 2
        let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_13'
        return l_retorno.codigo,
               l_retorno.mensagem
     end if

     # CASO TENHA O CODIGO DO SOCORRISTA (ACIONAMENTO GPS) BUSCA NOME ABREVIADO
     if  lr_dados.srrcoddig is not null and
         lr_dados.srrcoddig <> " " then
         whenever error continue
         open c_ctb85g02_003 using lr_dados.srrcoddig
        fetch c_ctb85g02_003 into  lr_dados.srrabvnom
         whenever error stop
         if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
            let l_retorno.codigo = 2
            let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_03'
            return l_retorno.codigo,
                   l_retorno.mensagem
         end if

         let lr_dados.srrabvnom = ctb85g02_limpa_texto_all(lr_dados.srrabvnom)

     end if

     let lr_dados.c24solnom = ctb85g02_limpa_texto_all(lr_dados.c24solnom)

     case param.codigo

          when 1 # SMS DE ENTREGA VEICULO NA OFICINA.
               if  lr_dados.atdsrvorg <> 9 and
                   lr_dados.atdsrvorg <> 10 and
                   lr_dados.atdsrvorg <> 13 then
                   let lr_sms.codigo = "E",
                                       param.atdsrvnum using "<<<<<<<<&",
                                       param.atdsrvano using "<&"

                   let lr_sms.texto  = lr_dados.empsgl clipped, " inf: ", lr_dados.c24solnom clipped, ", seu veiculo foi entregue ",
                                       "no destino."
               else
                   let l_retorno.codigo = 1
                   let l_retorno.mensagem = 'Codigo 1: a origem deve ser diferente de 9, 10 e 13'
                   return l_retorno.codigo,
                          l_retorno.mensagem
               end if

          when 2 # SMS PREVISAO DE CHEGADA RE
               if  lr_dados.atdsrvorg = 9 or lr_dados.atdsrvorg = 13 then

                   call cts29g00_consistir_multiplo(param.atdsrvnum,
                                                    param.atdsrvano)
                       returning lr_cts29g00.resultado,
                                 lr_cts29g00.mensagem,
                                 lr_cts29g00.atdsrvnum,
                                 lr_cts29g00.atdsrvano

                   if lr_cts29g00.resultado = 1     or   # Servico Multiplo
                      lr_dados.pstcoddig    = 10573 then # TELEPERFORMANCE
                       let l_retorno.codigo = 1
                       let l_retorno.mensagem = 'Codigo 2: srv nao deve ser multiplo e prs nao deve ser Teleperformance'
                       return l_retorno.codigo,
                              l_retorno.mensagem
                   end if

                   let lr_sms.codigo = "R", param.atdsrvnum using "<<<<<<<<&",
                                            param.atdsrvano using "<&"

                   let lr_sms.texto  = lr_dados.empsgl clipped, " inf: "

                   whenever error continue
                   open cqctb85g02_11 using param.atdsrvnum,
                                            param.atdsrvano
                  fetch cqctb85g02_11 into  l_status
                   whenever error stop

                   if sqlca.sqlcode = 0 then
                       let l_status = 1
                   else
                       if sqlca.sqlcode <> 100 then
                          let l_retorno.codigo = 2
                          let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_11'
                          return l_retorno.codigo,
                                 l_retorno.mensagem
                       end if
                       let l_status = 0
                   end if

                   if  lr_dados.srrabvnom is not null then
                       if l_status then
                           let lr_sms.texto = lr_sms.texto clipped, " confirmamos  o retorno do socorrista."
                       else
                           let lr_sms.texto = lr_sms.texto clipped, " o socorrista ", lr_dados.srrabvnom clipped,
                                              " chegara dentro da previsao. "
                       end if
                   else
                       if l_status then
                           let lr_sms.texto = lr_sms.texto clipped, " confirmamos  o retorno do socorrista."
                       else
                           let lr_sms.texto = lr_sms.texto clipped, " confirmamos o agendamento da sua solicitacao."
                       end if
                   end if

                   ##verificar se serviço possui mecanismo de seguranca
                   if cty28g00_controla_mecanismo_seguranca(param.atdsrvnum, param.atdsrvano, lr_dados.ciaempcod) then
                      ##verifica senha de seguranca
                      call cty28g00_consulta_senha(param.atdsrvnum, param.atdsrvano)
                       returning  lr_cty28g00.senha   ,
                                  lr_cty28g00.coderro ,
                                  lr_cty28g00.msgerro

                      if  lr_cty28g00.coderro <> 0 then
                          let l_retorno.codigo = 1
                          let l_retorno.mensagem = 'Nao foi possivel enviar Senha de Seguranca. Erro: ' ,lr_cty28g00.msgerro
                          return l_retorno.codigo,
                                 l_retorno.mensagem
                      end if
                      let lr_sms.texto = lr_sms.texto clipped, " Para sua seguranca, solicite ao prestador sua senha de atendimento: ", lr_cty28g00.senha clipped
                   end if

                    open cqctb85g02_25 using param.atdsrvnum,
                                             param.atdsrvano,
                                             param.atdsrvnum,
                                             param.atdsrvano
                   fetch cqctb85g02_25 into  l_c24lclpdrcodm18
                                            ,l_envtipcodm18

                   #[M18] Msg com link de acompanhamento apenas para srv indexado por rua e acionado por GPS
                   if l_c24lclpdrcodm18 = 3 and l_envtipcodm18 = 1 then

                       whenever error continue
                       open c_ctb85g02_008 using param.atdsrvnum,
                                                 param.atdsrvano
                       fetch c_ctb85g02_008 into lr_sms.dddcel,
                                                 lr_sms.celnum,
                                                 lr_sms.dddcod,
                                                 lr_sms.lcltelnum,
                                                 lr_sms.cidnom,
                                                 lr_sms.ufdcod
                       whenever error stop
                       if sqlca.sqlcode <> 0 and
                          sqlca.sqlcode <> 100 then
                          let l_retorno.codigo = 2
                          let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_08'
                          return l_retorno.codigo,
                                 l_retorno.mensagem
                       end if
                       close c_ctb85g02_008

                       let l_ufcidm18 = lr_sms.ufdcod clipped, '-', lr_sms.cidnom clipped
                       select count(cpodes)
                         into l_count
                         from datkdominio
                        where cponom = 'UF-CIDADE-M18'
                          and (cpodes = l_ufcidm18
                           or cpodes = 'BR-TODAS')

                          if l_count > 0 then

                             open cqctb85g02_24  using param.atdsrvnum,
                                                       param.atdsrvano
                            fetch cqctb85g02_24  into  lr_datmlclm18.lgdtip
                                                       ,lr_datmlclm18.lgdnom
                                                       ,lr_datmlclm18.lgdnum
                                                       ,lr_datmlclm18.brrnom
                                                       ,lr_datmlclm18.cidnom

                              let lr_endclim18.lgdtip = lr_datmlclm18.lgdtip clipped
                              let lr_endclim18.lgdnom = lr_datmlclm18.lgdnom clipped
                              let lr_endclim18.lgdnum = lr_datmlclm18.lgdnum clipped using "<<<<<<"
                              let lr_endclim18.brrnom = lr_datmlclm18.brrnom clipped
                              let lr_endclim18.cidnom = lr_datmlclm18.cidnom clipped

                              let lr_endclim18.endcom = lr_endclim18.lgdtip, " "
                                                       ,lr_endclim18.lgdnom, " "
                                                       ,lr_endclim18.brrnom, " "
                                                       ,lr_endclim18.cidnom

                              let l_codigom18 = "M", param.atdsrvnum using "<<<<<<<<&", param.atdsrvano using "<&"
                              let l_sufixolinkm18 = ctb85g02_gera_numero(param.atdsrvnum, param.atdsrvano)
                              let l_textom18 = lr_dados.empsgl clipped, " inf: socorrista desloca-se para ",
                                               lr_endclim18.endcom clipped,
                              ". Acompanhe: www.porto.com/s?s=", l_sufixolinkm18
                              let l_gravam18 = true
                          else
                             display "Cidade nao cadastrada no dominio UF-CIDADE-M18 para envio de SMS"
                          end if
                  end if
 
               else
                   let l_retorno.codigo = 1
                   let l_retorno.mensagem = 'Codigo 2: a origem deve ser 9 ou 13'
                   return l_retorno.codigo,
                          l_retorno.mensagem
               end if
          when 3 # PREVISAO DE CHEGADA PARA SEGURADO SERVICO AUTO

               let lr_sms.texto = lr_dados.empsgl clipped, " inf: "

               if  lr_dados.srrabvnom is not null then
                   let lr_sms.texto = lr_sms.texto clipped, " o socorrista ", lr_dados.srrabvnom clipped,
                                                            " chegara dentro da previsao. "
               else
                  let lr_sms.texto = lr_sms.texto clipped, " confirmamos o agendamento da sua solicitacao."
               end if

               ##verificar se serviço possui mecanismo de seguranca
               if cty28g00_controla_mecanismo_seguranca(param.atdsrvnum, param.atdsrvano, lr_dados.ciaempcod) then
                  ##verifica senha de seguranca
                  call cty28g00_consulta_senha(param.atdsrvnum, param.atdsrvano)
                   returning  lr_cty28g00.senha   ,
                              lr_cty28g00.coderro ,
                              lr_cty28g00.msgerro

                  if  lr_cty28g00.coderro <> 0 then
                      let l_retorno.codigo = 1
                      let l_retorno.mensagem = 'Nao foi possivel enviar Senha de Seguranca. Erro: ', 
                                                lr_cty28g00.msgerro
                      return l_retorno.codigo,
                             l_retorno.mensagem
                  end if

                  let lr_sms.texto = lr_sms.texto clipped, 
                                     " Para sua seguranca, solicite ao prestador sua senha de atendimento: ", 
                                     lr_cty28g00.senha clipped

               end if


               let lr_sms.codigo = "S" clipped, param.atdsrvnum using "<<<<<<<<<&", param.atdsrvano using "<<<&&"

               open cqctb85g02_25 using param.atdsrvnum,
                                        param.atdsrvano,
                                        param.atdsrvnum,
                                        param.atdsrvano
              fetch cqctb85g02_25 into  l_c24lclpdrcodm18
                                       ,l_envtipcodm18

              #[M18] Msg com link de acompanhamento apenas para srv indexado por rua e acionado por GPS
	             if l_c24lclpdrcodm18 = 3 and l_envtipcodm18 = 1 then

                  whenever error continue
                  open c_ctb85g02_008 using param.atdsrvnum,
                                            param.atdsrvano
                 fetch c_ctb85g02_008 into  lr_sms.dddcel,
                                            lr_sms.celnum,
                                            lr_sms.dddcod,
                                            lr_sms.lcltelnum,
                                            lr_sms.cidnom,
                                            lr_sms.ufdcod
                  whenever error stop

                  if sqlca.sqlcode <> 0 and
                     sqlca.sqlcode <> 100 then
                     let l_retorno.codigo = 2
                     let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_08'
                     return l_retorno.codigo,
                            l_retorno.mensagem
                  end if
                  close c_ctb85g02_008
                  let l_ufcidm18 = lr_sms.ufdcod clipped, '-', lr_sms.cidnom clipped

		              select count(cpodes)
                    into l_count
                    from datkdominio
                   where cponom = 'UF-CIDADE-M18'
                     and (cpodes = l_ufcidm18
                       or cpodes = 'BR-TODAS')

                     if l_count > 0 then

                        open cqctb85g02_24  using param.atdsrvnum,
                                                  param.atdsrvano
                       fetch cqctb85g02_24  into  lr_datmlclm18.lgdtip
                                                 ,lr_datmlclm18.lgdnom
                                                 ,lr_datmlclm18.lgdnum
                                                 ,lr_datmlclm18.brrnom
                                                 ,lr_datmlclm18.cidnom

                        let lr_endclim18.lgdtip = lr_datmlclm18.lgdtip clipped
                        let lr_endclim18.lgdnom = lr_datmlclm18.lgdnom clipped
                        let lr_endclim18.lgdnum = lr_datmlclm18.lgdnum clipped using "<<<<<<"
                        let lr_endclim18.brrnom = lr_datmlclm18.brrnom clipped
                        let lr_endclim18.cidnom = lr_datmlclm18.cidnom clipped

                        let lr_endclim18.endcom = lr_endclim18.lgdtip, " "
                                                 ,lr_endclim18.lgdnom, " "
                                                 ,lr_endclim18.brrnom, " "
                                                 ,lr_endclim18.cidnom

                        let l_codigom18 = "M", param.atdsrvnum using "<<<<<<<<&", param.atdsrvano using "<&"
                        let l_sufixolinkm18 = ctb85g02_gera_numero(param.atdsrvnum, param.atdsrvano)
                        let l_textom18 = lr_dados.empsgl clipped, " inf: socorrista desloca-se para ",
                                         lr_endclim18.endcom clipped,
                        ". Acompanhe: www.porto.com/s?s=", l_sufixolinkm18
                        let l_gravam18 = true
                     else
                        display "Cidade nao cadastrada no dominio UF-CIDADE-M18 para envio de SMS"
                     end if
               end if


          when 6 # AVISO SMS DE SERVICO PSS PARA A PORTARIA

               whenever error continue
               open cqctb85g02_16 using param.atdsrvnum,
                                        param.atdsrvano
              fetch cqctb85g02_16 into  l_socntzdes
               whenever error stop
               if sqlca.sqlcode <> 0 and
                  sqlca.sqlcode <> 100 then
                  let l_retorno.codigo = 2
                  let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_16'
                  return l_retorno.codigo,
                         l_retorno.mensagem
               end if
               whenever error continue
               open cqctb85g02_17 using param.atdsrvnum,
                                        param.atdsrvano
              fetch cqctb85g02_17 into  l_nom
                                       ,l_atdlibdat
                                       ,l_atdlibhor
                                       ,l_atddatprg
                                       ,l_atdhorprg
                                       ,l_atddfttxt
                                       ,l_atdprscod
               whenever error stop
               if sqlca.sqlcode <> 0 and
                  sqlca.sqlcode <> 100 then
                  let l_retorno.codigo = 2
                  let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_17'
                  return l_retorno.codigo,
                         l_retorno.mensagem
               end if
               whenever error continue
               open cqctb85g02_18 using l_atdprscod
              fetch cqctb85g02_18 into  l_nomgrr
               whenever error stop
               if sqlca.sqlcode <> 0 and
                  sqlca.sqlcode <> 100 then
                  let l_retorno.codigo = 2
                  let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_18'
                  return l_retorno.codigo,
                         l_retorno.mensagem
               end if
               let lr_sms.codigo = "B" clipped, param.atdsrvnum using "<<<<<<<<<&", param.atdsrvano using "<<<&&"
               if l_atddatprg is null or l_atddatprg = " " or
                  l_atdhorprg is null or l_atdhorprg = " " then
                  let l_atddatprg = l_atdlibdat
                  let l_atdhorprg = l_atdlibhor
               end if
               let lr_sms.texto = "O servico ", l_socntzdes clipped," - ", l_atddfttxt clipped,
                                  ", sera realizado no dia ", l_atddatprg," as ", l_atdhorprg," no "  ,l_endcmp clipped,
                                  " de ", l_nom clipped, " pelo prestador ", l_nomgrr clipped, "."
          when 9 # INSERE NA TABELA DE SMS COMO ENVIADO PARA NÃO ENVIAR EMAIL DA PROXIMA BUSCA
              let lr_sms.codigo = "A" clipped, param.atdsrvnum using "<<<<<<<<<&", param.atdsrvano using "<<<&&"
              let lr_sms.texto = 'ENVIADO VIA E-MAIL'
              let l_envstt = 'E'
              let lr_sms.dddcel  = 0
              let lr_sms.celnum  = 0
          otherwise
              let l_retorno.codigo = 1
              let l_retorno.mensagem = 'Codigo ', param.codigo, ' nao esta parametrizado'
              return l_retorno.codigo,
                     l_retorno.mensagem
     end case

     # SE O SMS JÁ FOI ENVIADO VOLTA A ETAPA ANTERIOR
     whenever error continue
     open c_ctb85g02_005 using lr_sms.codigo
    fetch c_ctb85g02_005 into  l_status
     whenever error stop

     if  sqlca.sqlcode = 0 then
         let l_retorno.codigo = 1
         let l_retorno.mensagem = 'O SMS ', lr_sms.codigo,' JÁ FOI ENVIADO'
         return l_retorno.codigo,
                l_retorno.mensagem
     else
         if sqlca.sqlcode <> 100 then
            let l_retorno.codigo = 2
            let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_05'
            return l_retorno.codigo,
                   l_retorno.mensagem
         end if
     end if

     if param.codigo <> 9 then # Controle de envio de email PSS
         # BUSCA INFORMAÇÕES DO CELULAR
         whenever error continue
         open c_ctb85g02_008 using param.atdsrvnum,
                                   param.atdsrvano
        fetch c_ctb85g02_008 into  lr_sms.dddcel,
                                   lr_sms.celnum,
                                   lr_sms.dddcod,
                                   lr_sms.lcltelnum,
                                   lr_sms.cidnom,
                                   lr_sms.ufdcod
         whenever error stop
         if sqlca.sqlcode <> 0 and
            sqlca.sqlcode <> 100 then
            let l_retorno.codigo = 2
            let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_08'
            return l_retorno.codigo,
                   l_retorno.mensagem
         end if
     end if
     if  ctb85g02_verifica_sms_cel(param.codigo) then
         if  not ctb85g02_verifica_celular(lr_sms.celnum) then
             if  not ctb85g02_verifica_celular(lr_sms.lcltelnum) then
                 let l_retorno.codigo = 1
                 let l_retorno.mensagem = "Telefone celualr inválido, SMS de aviso nao enviado."
                 return l_retorno.codigo,
                        l_retorno.mensagem
             else
                 let lr_sms.dddcel = lr_sms.dddcod
                 let lr_sms.celnum = lr_sms.lcltelnum
             end if
         end if
     end if

     call ctb85g02_verifica_cidade(lr_sms.cidnom,
                                   lr_sms.ufdcod,
                                   param.codigo)
         returning lr_cidade.retorno,
                   lr_cidade.mensagem
     # VEIRIFICA SE A CIDADE ESTÁ CADASTRADA NO CTC89M00
     if  lr_cidade.retorno <> 0 then
         let l_retorno.codigo = lr_cidade.retorno
         let l_retorno.mensagem = lr_cidade.mensagem
         return l_retorno.codigo,
                l_retorno.mensagem
     end if

     let l_cur = current

     let l_status = null
     whenever error continue
     open cqctb85g02_12 using lr_sms.codigo
    fetch cqctb85g02_12 into  l_status
     whenever error stop
     
     if sqlca.sqlcode = 100 then
         if lr_sms.codigo is not null and
            lr_sms.dddcel is not null and
            lr_sms.celnum is not null then
            
            #INCLUI NA TABELA DE ENVIO DE SMS
            whenever error continue
            execute pbctb85g02_09 using lr_sms.codigo,
                                        lr_sms.celnum,
                                        lr_sms.texto,
                                        "",
                                        l_cur,
                                        l_envstt,
                                        "",
                                        lr_sms.dddcel,
                                        lr_dados.srvprsacnhordat
            whenever error stop
            if  sqlca.sqlcode = 0 then
                if l_gravam18 = true then

                   execute pbctb85g02_09 using l_codigom18,
                                               lr_sms.celnum,
                                               l_textom18,
                                               "",
                                               l_cur,
                                               l_envstt,
                                               "",
                                               lr_sms.dddcel,
                                               lr_dados.srvprsacnhordat

                end if

		            let l_gravam18 =  false
                let l_retorno.codigo = 0
                let l_retorno.mensagem = "Cadastrando o SMS: ", lr_sms.codigo clipped
                return l_retorno.codigo,
                       l_retorno.mensagem
            else
                let l_retorno.codigo = 2
                let l_retorno.mensagem = "ERRO: Cadastrando o SMS: ", lr_sms.codigo clipped, " SQLCA: ", sqlca.sqlcode, " no cursor pbctb85g02_09"
                return l_retorno.codigo,
                       l_retorno.mensagem
            end if

         else
             let l_retorno.codigo = 1
             let l_retorno.mensagem = 'SMS ', lr_sms.codigo clipped,' sem numero de celular ('
                                      ,lr_sms.dddcel,') ',lr_sms.celnum
             return l_retorno.codigo,
                    l_retorno.mensagem
         end if
     else
         if sqlca.sqlcode <> 0 then
             let l_retorno.codigo = 2
             let l_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_12'
             return l_retorno.codigo,
                    l_retorno.mensagem
         end if
     end if
     let l_retorno.codigo = 1
     let l_retorno.mensagem = 'SMS ', lr_sms.codigo clipped,' ja foi enviado'
     return l_retorno.codigo,
            l_retorno.mensagem

 end function

#------------------------------------------#
 function ctb85g02_verifica_cidade(lr_param)
#------------------------------------------#

     define lr_param record
         cidnom like datmlcl.cidnom,
         ufdcod like datmlcl.ufdcod,
         tipo   char(2)
     end record

     define lr_retorno record
         retorno    smallint,
         mensagem   char(100)
     end record
     define lr_ctd01g00 record
         retorno    smallint,
         mensagem   char(100),
         cidsedcod  like datrcidsed.cidsedcod
     end record

     define l_ind    smallint,
            l_opcao  integer,
            l_status integer,
            l_char1  char(15),
            l_char2  char(15)

     define l_mpacidcod like datkmpacid.mpacidcod

     initialize lr_ctd01g00.* to null

     let l_opcao = lr_param.tipo
     let l_mpacidcod = null

     whenever error continue
     open c_ctb85g02_006 using lr_param.cidnom,
                              lr_param.ufdcod
     fetch c_ctb85g02_006 into l_mpacidcod
     whenever error stop
     if sqlca.sqlcode <> 0 and
        sqlca.sqlcode <> 100 then
        let lr_retorno.retorno  = 2
        let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_06'
        return lr_retorno.retorno,
               lr_retorno.mensagem
     end if

     call 	ctd01g00_obter_cidsedcod(1,l_mpacidcod)
         returning lr_ctd01g00.retorno,
                   lr_ctd01g00.mensagem,
                   lr_ctd01g00.cidsedcod
     if lr_ctd01g00.retorno = 1 then
         whenever error continue
         open c_ctb85g02_007 using lr_ctd01g00.cidsedcod,
                                  l_opcao
         fetch c_ctb85g02_007 into l_status
         whenever error stop
         if  sqlca.sqlcode = 0 then
             let lr_retorno.retorno  = 0
             let lr_retorno.mensagem = ''
             return lr_retorno.retorno,
                    lr_retorno.mensagem
         else
             if sqlca.sqlcode <> 100 then
                let lr_retorno.retorno  = 2
                let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_07'
                return lr_retorno.retorno,
                       lr_retorno.mensagem
             end if
         end if

     end if

     let l_char1 = "CIDXSMS", lr_param.ufdcod, l_opcao using '<<<'
     let l_char2 = "CIDXSMSTD", l_opcao using '<<<'

     whenever error continue
     open cqctb85g02_10 using l_char1,
                              l_char2
     fetch cqctb85g02_10 into l_status
     whenever error stop

     if  sqlca.sqlcode = 0 then
         let lr_retorno.retorno  = 0
         let lr_retorno.mensagem = ''
         return lr_retorno.retorno,
                lr_retorno.mensagem
     else
         if sqlca.sqlcode <> 100 then
            let lr_retorno.retorno  = 2
            let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode,' no cursor cqctb85g02_10'
            return lr_retorno.retorno,
                   lr_retorno.mensagem
         end if
     end if

     let lr_retorno.retorno  = 1
     let lr_retorno.mensagem = "NAO ACHOU A CIDADE: ", lr_param.cidnom
     return lr_retorno.retorno,
            lr_retorno.mensagem

 end function

#-----------------------------------------------#
 function ctb85g02_verifica_celular(l_celtelnum)
#-----------------------------------------------#

 define l_celtelnum char(10),
        l_ind       smallint
 if  l_celtelnum <> " " and l_celtelnum is not null then
     if  l_celtelnum[1] >= 6 and l_celtelnum[1] <> " " then
         return true
     end if
     return false
 else
     return false
 end if

 end function

#-----------------------------------------#
 function ctb85g02_verifica_sms_cel(param)
#-----------------------------------------#

     define param record
         codsms smallint
     end record
     define l_sttcod smallint

     open cqctb85g02_14 using param.codsms
     fetch cqctb85g02_14 into l_sttcod

     if  sqlca.sqlcode = 0 then
         return true
     end if

     return false

 end function
 #################-------------------------------------
   function ctb85g02_envia_sms(param)
#################-------------------------------------
  define param record
    smsenvcod  like dbsmenvmsgsms.smsenvcod ,
    celnum     like dbsmenvmsgsms.celnum    ,
    msgtxt     like dbsmenvmsgsms.msgtxt    ,
    envdat     like dbsmenvmsgsms.envdat    ,
    incdat     like dbsmenvmsgsms.incdat    ,
    dddcel     like dbsmenvmsgsms.dddcel
  end record
  define l_retorno record
    codido  smallint, # esse código é o sqlca.sqlcode
    mensagem  char(30)
  end record
 define l_status smallint
 initialize l_retorno.* , l_status to null
  call ctb85g02_prepare()
  # para verificar se já foi enviada uma mensagem para este servico
    open cqctb85g02_15 using param.smsenvcod
    whenever error continue
     fetch cqctb85g02_15 into l_status
    whenever error stop
    let l_retorno.codido = sqlca.sqlcode
    if l_retorno.codido = 100 then
       whenever error continue
        execute pbctb85g02_09 using param.smsenvcod,
                                    param.celnum   ,
                                    param.msgtxt   ,
                                    param.envdat   ,
                                    param.incdat   ,
                                    "A"            ,
                                    " "            ,
                                    param.dddcel   ,
                                    " " # data e hora do servicço programado
       whenever error stop
       let l_retorno.mensagem = ""
    else
       if l_retorno.codido <> 0 then
          let l_retorno.mensagem = "ERRO: ctb85g02_envia_sms() com codigo: ", param.smsenvcod clipped, " SQLCA: ", sqlca.sqlcode
       else
          let l_retorno.mensagem = "Já foi enviado sms para este servico: ", param.smsenvcod clipped
       end if
    end if
    close cqctb85g02_15
   return l_retorno.mensagem,l_retorno.codido
  end function
#-----------------------------------------------#
 function ctb85g02_ntz_cartao_pss(l_socntzcod)
#-----------------------------------------------#

 define l_socntzcod like datksocntz.socntzcod,
        l_sttcod    smallint,
        l_cponom    like iddkdominio.cponom

     call ctb85g02_prepare()

     let l_cponom = "PSONTZCRTPAGPSS"
     open cqctb85g02_20 using l_cponom,
                              l_socntzcod
     fetch cqctb85g02_20 into l_sttcod

     if  sqlca.sqlcode = 0 then
         return true
     end if

     return false

 end function

#-----------------------------------------------#
 function ctb85g02_asi_cartao_pss(l_asitipcod)
#-----------------------------------------------#

 define l_asitipcod like datkasitip.asitipcod,
        l_sttcod    smallint,
        l_cponom    like iddkdominio.cponom

     call ctb85g02_prepare()

     let l_cponom = "PSOASICRTPAGPSS"
     open cqctb85g02_20 using l_cponom,
                              l_asitipcod
     fetch cqctb85g02_20 into l_sttcod

     if  sqlca.sqlcode = 0 then
         return true
     end if

     return false

 end function

#------------------------------------------#
 function ctb85g02_limpa_texto_all(l_texto)
#------------------------------------------#


define l_texto   char(100),
       l_aux     char(100),
       l_retorno char(100),
       l_ind     smallint

     initialize l_retorno,
                l_aux to null

     call ctb85g02_prepare()

     let l_texto = ctb85g02_limpa_texto_cmp(l_texto)

     for l_ind=1 to length(l_texto)+1

         if  not ctb85g02_verifica_dominio("PLVIGNSMS", l_texto[l_ind]) and l_texto[l_ind] <> " " then
             let l_aux = l_aux clipped, l_texto[l_ind]
         else
             if  l_texto[l_ind] = " " then
                 if  length(l_aux) <= 1 then
                     let l_aux = ""
                     continue for
                 end if

                 if  ctb85g02_verifica_dominio('PLVRSVSMS', l_aux) then
                     let l_aux = ""
                     continue for
                 end if

                 if  length(l_retorno) > 1 then
                     let l_retorno = l_retorno clipped, " ", l_aux
                     let l_aux = ""
                 else
                     let l_retorno = l_aux
                     let l_aux = ""
                     continue for
                 end if
             else
                 if  length(l_retorno) > 1 then
                     let l_retorno = l_retorno clipped, " ", l_aux
                     let l_aux = ""
                 else
                     let l_retorno = l_aux
                     let l_aux = ""
                 end if

                 exit for
             end if
         end if
     end for

     return l_retorno

 end function

#------------------------------------------#
 function ctb85g02_limpa_texto_cmp(l_texto)
#------------------------------------------#

     define l_texto   char(100),
            l_retorno char(100),
            l_ind     smallint

     initialize l_retorno to null

     for l_ind=1 to length(l_texto)

         if  l_texto[l_ind] <> "(" and
             l_texto[l_ind] <> ")" and
             l_texto[l_ind] <> "[" and
             l_texto[l_ind] <> "]" and
             l_texto[l_ind] <> "{" and
             l_texto[l_ind] <> "}" then
             if  l_texto[l_ind] = " " then
                 let l_ind = l_ind + 1
                 let l_retorno = l_retorno clipped, " ", l_texto[l_ind]
             else
                 let l_retorno = l_retorno clipped, l_texto[l_ind]
             end if
         else
             exit for
         end if

     end for

     return l_retorno

 end function

#-----------------------------------------#
 function ctb85g02_verifica_dominio(param)
#-----------------------------------------#

     define param record
            cponom like iddkdominio.cponom,
            cpodes like iddkdominio.cpodes
     end record

     define l_status smallint

     if  param.cponom is null or param.cponom = " " and
         param.cpodes is null or param.cpodes = " " then
         return false
     end if

     open cqctb85g02_20 using param.cponom,
                              param.cpodes
     fetch cqctb85g02_20 into l_status

     if  sqlca.sqlcode = 0 then
         return true
     end if

     return false

 end function

 #-----------------------------------------#
 function ctb85g02_verifica_assunto(param)
#-----------------------------------------#

     define param record
            cponom like datkdominio.cponom,
            cpodes like datkdominio.cpodes
     end record

     define l_status smallint

     if  param.cponom is null or param.cponom = " " and
         param.cpodes is null or param.cpodes = " " then
         return false
     end if

     open cqctb85g02_26 using param.cponom,
                              param.cpodes
     fetch cqctb85g02_26 into l_status

     if  sqlca.sqlcode = 0 then
         return true
     end if

     return false

 end function

#-----------------------------------------#
 function ctb85g02_itau(param)
#-----------------------------------------#
define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define l_retorno record
     codigo  smallint, # 0 -> OK, 1 -> Nao envia sms, 2 -> Erro
     mensagem  char(100)
  end record

 define l_smsenvflg like datmservicocmp.smsenvflg

 open cqctb85g02_22 using param.atdsrvnum,
                          param.atdsrvano

 fetch cqctb85g02_22 into l_smsenvflg

 if sqlca.sqlcode = 0 then
    if l_smsenvflg = 'S' then
       let l_retorno.codigo = 0
       let l_retorno.mensagem = ''
    else
       if l_smsenvflg = 'N' then
           let l_retorno.codigo = 1
           let l_retorno.mensagem = 'SMS nao sera enviado ao segurado, flag(smsenvflg): ',l_smsenvflg
       else
          let l_retorno.codigo = 2
          let l_retorno.mensagem = 'ERRO<',sqlca.sqlcode,'> ao buscar flag (smsenvflg) de envio do SMS'
       end if
    end if
 else
   let l_retorno.codigo = 2
   let l_retorno.mensagem = 'ERRO<',sqlca.sqlcode,'> ao buscar flag (smsenvflg) de envio do SMS'
 end if

 close cqctb85g02_22

 return  l_retorno.codigo,
         l_retorno.mensagem

 end function

#-----------------------------------------#
 function ctb85g02_gera_numero(lr_param)
#-----------------------------------------#

  define lr_param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
  end record

  define num_servico     char(15)
  define num_convertido  char(15)
  define l_atdsrvnum     char(7)
  define l_atdsrvano     char(2)
  define l_num           float

  initialize num_servico    to null
  initialize num_convertido to null
  initialize l_num          to null
  initialize l_atdsrvnum    to null
  initialize l_atdsrvano    to null

  let l_atdsrvnum = lr_param.atdsrvnum
  let l_atdsrvano = lr_param.atdsrvano

  let num_servico    = l_atdsrvnum clipped, l_atdsrvano
  let num_servico =  num_servico clipped

  let num_convertido = ctb85g02_calculaDigitoVerificador (num_servico)

  let num_servico    = null
  let num_servico    = num_convertido clipped
  let num_convertido = null
  let num_convertido = ctb85g02_calculaDigitoVerificador (num_servico)

  let num_servico    = null
  let num_servico    = num_convertido clipped
  let num_convertido = null
  let num_convertido = ctb85g02_calculaDigitoVerificador (num_servico)

  let num_servico    = null
  let num_servico    = num_convertido clipped
  let num_convertido = null
  let num_convertido = ctb85g02_calculaDigitoVerificador (num_servico)

  let l_num          = num_convertido
  let num_servico    = null
  let num_servico    = ctb85g02_converteToBase (l_num, 36)

  return num_servico

end function


#------------------------------------------------------------------------------
function ctb85g02_converteToBase(num, nbase)
#------------------------------------------------------------------------------

    define num           float
    define nbase         int

    define l_num         float
    define l_i           int

    define param_num     float
    define param_base    float

    define l_r             float
    define l_resto         int
    define l_num_trunc     float
    define l_num_char      char(22)
    define l_num_int       char(22)
    define i               int
    define l_newNumber     char(18)

    define CharList char(36)

    let CharList = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'

    let l_newNumber = null
    let param_base  = nbase
    let param_num   = num

    while (param_num >= param_base)

      # Calculo resto --> funcao MOD

      let l_r = param_num / param_base
      let l_num_char = l_r
      let l_num_int = null
      let i = 1
      while  i <= 22
          if l_num_char[i,i] = '.' then
              exit while
          else
              let l_num_int =  l_num_int clipped, l_num_char[i,i]
          end if
          let i = i+1
      end while

      let l_num_trunc = l_num_int
      let l_resto = param_num - (l_num_trunc * param_base)
      let l_resto = l_resto + 1

      let l_newNumber =  CharList[l_resto,l_resto], l_newNumber clipped

      let l_num = param_num / param_base
      let param_num = l_num

    end while

    let l_i = l_num
    let l_i = l_i + 1
    let l_newNumber = CharList[l_i,l_i],  l_newNumber clipped

    return l_newNumber

end function


#-----------------------------------------------------------------------------
   function ctb85g02_calculaDigitoVerificador( codServicoPassado )
#-----------------------------------------------------------------------------

   define codServicoPassado    varchar(15)

   define l_totalSoma          int
   define i                    int
   define l_tam                int
   define l_num                int
   define l_retorno            int
   define l_aux                char(2)
   define num_convertidood     char(15)
   define num_convertidoodsrv  char(15)
   define l_resto              int
   define num_convertido       char(1)

   initialize l_totalSoma         to null
   initialize i                   to null
   initialize l_tam               to null
   initialize l_num               to null
   initialize l_retorno           to null
   initialize l_aux               to null
   initialize num_convertidood    to null
   initialize num_convertidoodsrv to null
   initialize l_resto             to null
   initialize num_convertido      to null

   let l_totalSoma = 0
   let l_tam = length( codServicoPassado )
   let l_num = 0

   let i = 0


   while ( i < l_tam )
    let l_num = codServicoPassado[i+1,i+1]
    let l_totalSoma = l_totalSoma + ( l_num * (( l_tam + 1 ) - i) )
    let i = i + 1
   end while


   let l_retorno = 0;
   let l_tam = length( codServicoPassado )
   let l_resto = l_totalSoma MOD l_tam


   if ( l_resto  > 2 ) then

       let l_retorno = l_tam - ( l_totalSoma MOD  ( l_tam + 2 ) )


       if l_retorno < 0 then
	        let l_retorno = l_retorno * (-1)
       end if

       if l_retorno > 9 then
          let l_aux = l_retorno
	        let l_retorno = l_aux[2,2]
       end if
   end if


   let num_convertido = l_retorno
   let num_convertidoodsrv = codServicoPassado clipped
   let num_convertidood = num_convertidoodsrv clipped, num_convertido clipped
   return num_convertidood

end function

