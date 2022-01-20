################################################################################
# Nome do Modulo: bdbsa500                                          Sergio     #
#                                                                              #
# SMS e EMAIL  de aviso de serviço PSS para portaria do condominio Mar/2008    #
################################################################################
#                                                                              #
#                          * * * Alteracoes * * *                              #
#                                                                              #
# Data       Autor Fabrica     Origem       Alteracao                          #
# ---------- ----------------- ----------   -----------------------------------#
# 19/03/2010 Adriano Santos    PSI242853    Substituição da tabela             #
#                                           datrligsemapl por datrcntlig       #
# 25/07/2011 Jorge Modena      PSI201110211 Acerto validacao disparo de        #
#                                           e-mail PSS                         #
#------------------------------------------------------------------------------#
# 01/05/2012 Fornax  PSI03021PR PSI-2012-03021-PR - Resolucao 553 Anatel       #
#------------------------------------------------------------------------------#
# 24/10/2014 Celso Issamu                   Ajustes nas queries, controle de   #
#                                           Liga e Desliga, assuntos por cadas-#
#                                           tro de dominio, relatorio          #
#------------------------------------------------------------------------------#
# 08/07/2015 Celso Issamu                   Mudança na mensagem que é enviada  #
#                                           pelo batch.                        #
#                                                                              #
#------------------------------------------------------------------------------#

 database porto

 define m_path char(100)
       ,m_prepare smallint
       ,m_path2 char(100)
       ,m_mail smallint

 define mr_bdbsa500 record
    atdsrvnum      like datmservico.atdsrvnum
   ,atdsrvano      like datmservico.atdsrvano
   ,srvcbnhor      like datmservico.srvcbnhor
   ,atddatprg      like datmservico.atddatprg
   ,atdhorprg      like datmservico.atdhorprg
   ,lclcttnom      like datmlcl.lclcttnom
   ,celteldddcod   like datmlcl.celteldddcod
   ,celtelnum      like datmlcl.celtelnum
   ,dddcod         like datmlcl.dddcod
   ,lcltelnum      like datmlcl.lcltelnum
   ,c24astcod      like datmligacao.c24astcod
   ,resultado      char(100)
 end record

 define lr_envsms record
    smsenvcod like dbsmenvmsgsms.smsenvcod,
    dddcel    like dbsmenvmsgsms.dddcel,
    celnum    like dbsmenvmsgsms.celnum,
    msgtxt    like dbsmenvmsgsms.msgtxt,
    errmsg    like dbsmenvmsgsms.errmsg,
    errcod    integer,
    msgerr    char(20)
 end record

 define l_sissgl     like pccmcorsms.sissgl,
        l_prioridade smallint,
        l_expiracao  integer,
        l_prcstt     like dpamcrtpcs.prcstt,
        m_numtel     like datkgeral.grlinf,
        m_ativo      like datkgeral.grlinf,
        m_grlchv     like datkgeral.grlchv

 main

     call fun_dba_abre_banco("GUINCHOGPS")

     initialize m_path2 to null

     call bdbsa500_set_log()

     set lock mode to wait 30
     set isolation to dirty read

     call bdbsa500()


 end main

#---------------------------#
 function bdbsa500_set_log()
#---------------------------#

  let m_path = f_path("DBS","LOG")

  if m_path is null then
     let m_path = "."
  end if

  let m_path = m_path clipped,"/bdbsa500.log"

  call startlog(m_path)
  call bdbsa500_set_path()


 end function
#---------------------------#
function bdbsa500_set_path()
#---------------------------#
  initialize m_path2 to null
  let m_path2 = f_path("DBS","RELATO")

  if m_path2 is null then
     let m_path2 = "."
  end if

  let m_path2 = m_path2 clipped,"/bdbsa500.xls"
end function

#----------------------------#
 function bdbsa500_prepare()
#----------------------------#

 define l_sql  char(1000)
 let l_sql = ' select srv.atdsrvnum, srv.atdsrvano '
            ,'       ,srv.srvcbnhor, srv.atddatprg, srv.atdhorprg '
            ,'       ,lcl.lclcttnom, lcl.celteldddcod, lcl.celtelnum '
            ,'       ,lcl.dddcod,    lcl.lcltelnum '
            ,'   from datmservico srv, datmlcl lcl '
            ,'  where srv.atdsrvnum = lcl.atdsrvnum '
            ,'    and srv.atdsrvano = lcl.atdsrvano '
            ,'    and srv.ciaempcod = 43  '
            ,'    and srv.atddatprg = today + 1 units day  '
            ,'    and srv.atdetpcod not in (5) '
            ,'    and lcl.c24endtip = 1 '
 prepare pbdbsa500_01 from l_sql
 declare cbdbsa500_01 cursor for pbdbsa500_01

 let l_sql = ' select lig.c24astcod '
            ,'   from datmligacao lig '
            ,'  where lig.atdsrvnum = ? '
            ,'    and lig.atdsrvano = ? '
            ,'    and lig.lignum = (select min(lignum) from datmligacao li2 '
            ,'                      where li2.atdsrvnum = lig.atdsrvnum '
            ,'                        and li2.atdsrvano = lig.atdsrvano )'
 prepare pbdbsa500_02 from l_sql
 declare cbdbsa500_02 cursor for pbdbsa500_02

 let l_sql = ' select grlinf from datkgeral '
            ,'  where grlchv = ?'
 prepare pbdbsa500_03 from l_sql
 declare cbdbsa500_03 cursor for pbdbsa500_03

 let l_sql = "insert into dbsmenvmsgsms "
            ,"(smsenvcod,celnum,msgtxt,envdat,incdat,envstt,"
            ,"errmsg,dddcel,envprghor)"
            ," values (?,?,?,?,?,?,?,?,?)"
 prepare pbdbsa500_04 from l_sql

 let m_prepare = true


 end function

#--------------------#
 function bdbsa500()
#--------------------#

   define lr_bdbsa500 record
       atdsrvnum       like datmservico.atdsrvnum,
       atdsrvano       like datmservico.atdsrvano,
       atddatprg       like datmservico.atddatprg,
       atdhorprg       like datmservico.atdhorprg,
       atdlibhor       like datmservico.atdlibhor,
       atdlibdat       like datmservico.atdlibdat,
       srvprsacnhordat like datmservico.srvprsacnhordat
   end record

   define l_relpamtxt  char(75),
          l_erro       integer,
          l_msg        char(20),
          m_tmpexp     datetime year to second,
          l_prcstt     like dpamcrtpcs.prcstt,
          l_data_atual date,
          l_hora_atual datetime hour to minute,
          l_hora_str   char(20),
          l_hora_dat   datetime year to second,
          l_current    datetime year to second,
          l_tmpacn     like datrgrpntz.atmacnatchorqtd,
          l_status     smallint,
          l_psscntcod  like datrcntlig.psscntcod,
          l_smsenvcod  like dbsmenvmsgsms.smsenvcod,
          l_hora       char(19),
          l_agora      char(20),
          l_execucao   char(08)

   define lr_alerta record
          ddd       char(4)      ,
          celnum    decimal(10,0),
          mail      char(50)
   end record

   define l_prcdat date,
          l_prchor datetime hour to second,
          l_tamanho smallint,
          l_numchar char(10),
          l_horadisplay datetime year to second


   call bdbsa500_prepare()

   let  m_tmpexp = current
   let l_sissgl = "PSocorro"
   let l_prioridade = figrc007_prioridade_alta()
   let l_expiracao = figrc007_expiracao_1h()
   let m_mail = true

   initialize lr_bdbsa500.*,
              lr_alerta.*, lr_envsms.* to null

   # BUSCAR A DATA E HORA DO BANCO
   call cts40g03_data_hora_banco(1) returning l_prcdat, l_prchor

   display l_prcdat, " ", l_prchor, " - ", "Carga"


   while true
      #Recupera a frase do envio
      let m_grlchv = 'PSOSMS_PSFAZ'
      open cbdbsa500_03 using m_grlchv
      fetch cbdbsa500_03 into m_numtel
      close cbdbsa500_03

      #Verifica o horario da execucao
      let m_grlchv = 'PSOSMS_PSFAZ_HR'
      open cbdbsa500_03 using m_grlchv
      fetch cbdbsa500_03 into l_execucao
      close cbdbsa500_03
      let m_mail = true

      let l_current = current
      let l_agora = l_current
      let l_agora = l_agora[12,19]
      #Monitor de rotinas criticas
      call ctx28g00("bdbsa500", fgl_getenv("SERVIDOR"), m_tmpexp)
            returning m_tmpexp, l_prcstt

      #inicia o relatorio
      start report bdbsa500_relatorio to m_path2

      if  l_agora > l_execucao and
          l_agora < '22:00:00' then
       let m_mail = true

       #Monitor de rotinas criticas
       call ctx28g00("bdbsa500", fgl_getenv("SERVIDOR"), m_tmpexp)
            returning m_tmpexp, l_prcstt

         if  l_prcstt = 'A' then
            #Verifica se o processo Esta ativo pelo Porto Seguro FAZ
            let m_mail = true
            let m_grlchv = 'PSOSMS_PSFAZ_ON'
            open cbdbsa500_03 using m_grlchv
            fetch cbdbsa500_03 into m_ativo
            close cbdbsa500_03

            if m_ativo = "ATIVO" then
               # BUSCAR A DATA E HORA DO BANCO
               call cts40g03_data_hora_banco(1) returning l_prcdat, l_prchor
               display l_prcdat, " ", l_prchor, " - ", "Inicio"

               #Abre cursor principal
               let m_mail = true
               open cbdbsa500_01
               foreach cbdbsa500_01 into mr_bdbsa500.atdsrvnum
                                        ,mr_bdbsa500.atdsrvano
                                        ,mr_bdbsa500.srvcbnhor
                                        ,mr_bdbsa500.atddatprg
                                        ,mr_bdbsa500.atdhorprg
                                        ,mr_bdbsa500.lclcttnom
                                        ,mr_bdbsa500.celteldddcod
                                        ,mr_bdbsa500.celtelnum
                                        ,mr_bdbsa500.dddcod
                                        ,mr_bdbsa500.lcltelnum


                  #Busca o assunto do servico
                  open cbdbsa500_02 using mr_bdbsa500.atdsrvnum
                                         ,mr_bdbsa500.atdsrvano
                  fetch cbdbsa500_02 into mr_bdbsa500.c24astcod
                  close cbdbsa500_02

                  let l_numchar = mr_bdbsa500.celtelnum
                  let l_tamanho = length(l_numchar)


                  #Se Celular estiver nulo, pega o campo residencial.
                  if mr_bdbsa500.celtelnum = " " or
                     mr_bdbsa500.celtelnum is null or
                     l_tamanho < 8 then

                     let mr_bdbsa500.celteldddcod = mr_bdbsa500.dddcod
                     let mr_bdbsa500.celtelnum = mr_bdbsa500.lcltelnum

                  end if

                  let l_numchar = mr_bdbsa500.celtelnum
                  let l_tamanho = length(l_numchar)

                  if l_tamanho < 8 then
                     display 'Servico: ', mr_bdbsa500.atdsrvnum using '<<<<<<<&'
                                        ,mr_bdbsa500.atdsrvano using '<<&&'
                                        ,' Com Telefone Invalido: '
                                        ,mr_bdbsa500.celteldddcod using '<<&&'
                                        ,'-', mr_bdbsa500.celtelnum using '<<<<<<<<<&'
                     let mr_bdbsa500.resultado = 'NUMERO CELULAR INVALIDO'
                     output to report bdbsa500_relatorio()
                     initialize mr_bdbsa500.*, lr_envsms.* to null
                     continue foreach
                  end if

                  #Envia somente se o assunto estiver cadastrado no dominio
                  if bdbsa500_validaAssunto(mr_bdbsa500.c24astcod) then

                     if mr_bdbsa500.celteldddcod is not null and
                        mr_bdbsa500.celtelnum    is not null then

                        #Adiciona 2 horas no horario programado
                        let mr_bdbsa500.srvcbnhor = mr_bdbsa500.srvcbnhor + 2 units hour
                        #Converte em string
                        let l_hora = mr_bdbsa500.srvcbnhor
                        #Monta a Mensagem
                        let lr_envsms.msgtxt = "PORTO SEGURO FAZ: "
                                           ,"Seu servico esta programado para o dia "
                                           ,mdy(month(mr_bdbsa500.atddatprg)
                                           ,day(mr_bdbsa500.atddatprg)
                                           ,year(mr_bdbsa500.atddatprg))
                                           ," no horario das " ,mr_bdbsa500.atdhorprg,'h'
                                           ," as " ,l_hora[12,16],'h'
                                           ,". Acesse "
                                           ,m_numtel clipped

                        let lr_envsms.dddcel = mr_bdbsa500.celteldddcod
                        let lr_envsms.celnum = mr_bdbsa500.celtelnum
                        #Monta chave do sms
                        let lr_envsms.smsenvcod = 'F',mr_bdbsa500.atdsrvnum using '<<<<<<<&'
                                                     ,mr_bdbsa500.atdsrvano using '<<&&'

                        #Verifica se o sms já foi enviado para o servico
                        if not bdbsa500_verificaEnvio(lr_envsms.smsenvcod) then
                           display 'Chave SMS: ', lr_envsms.smsenvcod, ' Enviando...'
                           display 'MENSAGEM: ', lr_envsms.msgtxt clipped
                           display 'Telefone: ', mr_bdbsa500.celteldddcod using '<<&&'
                                               , '-', mr_bdbsa500.celtelnum using '<<<<<<<<<&'

                           #Faz o envio da Mensagem
                           call figrc007_sms_send1 (lr_envsms.dddcel,
                                                    lr_envsms.celnum,
                                                    lr_envsms.msgtxt,
                                                    l_sissgl,
                                                    l_prioridade,
                                                    l_expiracao)
                                          returning lr_envsms.errcod,
                                                    lr_envsms.msgerr
                            #Registra o envio
                            if lr_envsms.errcod = 0 then
                               whenever error continue
                                  let l_current = current
                                  execute pbdbsa500_04 using lr_envsms.smsenvcod
                                                            ,lr_envsms.celnum
                                                            ,lr_envsms.msgtxt
                                                            ,l_current
                                                            ,l_current
                                                            ,'E'
                                                            ,""
                                                            ,lr_envsms.dddcel
                                                            ,""
                                  if sqlca.sqlcode <> 0 then
                                     display 'Erro',sqlca.sqlcode
                                            ,' ao inserir na tabela de sms chave '
                                            ,lr_envsms.smsenvcod
                                  end if
                               whenever error stop
                            else
                               display 'Erro ao enviar o SMS, chave: ', lr_envsms.smsenvcod
                               display 'lr_envsms.errcod',lr_envsms.errcod
                               display 'lr_envsms.msgerr',lr_envsms.msgerr clipped
                               let mr_bdbsa500.resultado = 'Erro no envio da mensagem - ', lr_envsms.errcod using '<&&&&&',
                                                           ' ', lr_envsms.msgerr clipped
                               output to report bdbsa500_relatorio()
                               initialize mr_bdbsa500.*, lr_envsms.* to null
                               continue foreach
                            end if
                         else
                            display 'SMS Chave SMS: ', lr_envsms.smsenvcod, ' Ja enviado'
                            let mr_bdbsa500.resultado = 'SMS JA ENVIADO '

                            output to report bdbsa500_relatorio()
                            initialize mr_bdbsa500.*, lr_envsms.* to null
                            continue foreach
                         end if

                     else
                        display 'SERVICO: ',mr_bdbsa500.atdsrvnum using'<<<<<<<&', '-'
                                           ,mr_bdbsa500.atdsrvano using'<<&&'    , 'sem celular cadastrado.'
                        let mr_bdbsa500.resultado = 'SEM CELULAR CADASTRADO'
                        output to report bdbsa500_relatorio()
                        initialize mr_bdbsa500.*, lr_envsms.* to null
                        continue foreach
                     end if
                  else
                     #let mr_bdbsa500.resultado = 'ASSUNTO NAO CADASTRO PARA ENVIO DE SMS'
                     #output to report bdbsa500_relatorio()
                     initialize mr_bdbsa500.*, lr_envsms.* to null
                     continue foreach
                  end if
                  let mr_bdbsa500.resultado = 'OK'
                  output to report bdbsa500_relatorio()
                  initialize mr_bdbsa500.*, lr_envsms.* to null
                  display '----------------------------------------------------------------------'

                  let m_tmpexp = current
                  call ctx28g00("bdbsa500", fgl_getenv("SERVIDOR"), m_tmpexp)
                     returning m_tmpexp, l_prcstt
               end foreach

            else
              let m_mail = false
              let l_horadisplay = current
              display '[',l_horadisplay,']','CHAVE PSFAZ INATIVO '
            end if
         else
            let m_mail = false
            let l_horadisplay = current
            display '[',l_horadisplay,']','INATIVO Monitor rotina'
         end if
      else
        let m_mail = false
        let l_horadisplay = current
        display '[',l_horadisplay,']','Fora do horario de execução, programado para: ',l_execucao
      end if
      finish report bdbsa500_relatorio

      #envia email somente se ativo
      if m_mail then
         call bdbsa500_mail()
      end if
      #Aguarda 20 minutos para a proxima execução
      #sleep 100
      sleep 1200


   end while

   # BUSCAR A DATA E HORA DO BANCO
   call cts40g03_data_hora_banco(1) returning l_prcdat, l_prchor

   display l_prcdat, " ", l_prchor, " - ", "Fim"

 end function

#-------------------------------------------------
function bdbsa500_verificaEnvio(param)
#-------------------------------------------------07

   define param record
      chave char(10)
   end record
   #display 'CHAVE NA FUNCAO: ',param.chave
   whenever error continue
      select 1 from  dbsmenvmsgsms
       where smsenvcod = param.chave

      if sqlca.sqlcode = 0 then
          #display 'then sqlca.sqlcode:', sqlca.sqlcode
          whenever error stop
          return true
      else
          #display 'else sqlca.sqlcode:', sqlca.sqlcode
          whenever error stop
          return false
      end if

end function


#-------------------------------------------------
function bdbsa500_validaAssunto(param)
#-------------------------------------------------

   define param record
      c24astcod like datmligacao.c24astcod
   end record

   whenever error continue
     select 1 from datkdominio
      where cponom = 'AST_SMS_PSFAZ'
        and cpodes = param.c24astcod
     if sqlca.sqlcode = 0 then
        return true
     else
        select 1 from iddkdominio
         where cponom = 'AST_SMS_PSFAZ'
           and cpodes = param.c24astcod
        if sqlca.sqlcode = 0 then
           return true
        else
           return false
        end if
     end if
   whenever error stop

end function


#-------------------------------------------------
report bdbsa500_relatorio()
#-------------------------------------------------


  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        print "SERVICO",       ASCII(09),  # 1
              "ANO",  ASCII(09),  # 2
              "RESULTADO",       ASCII(09),  # 3
              "NOME",       ASCII(09),  # 3
              "DDD",       ASCII(09),  # 3
              "TELEFONE"              # 4

  on every row


     print mr_bdbsa500.atdsrvnum,  ASCII(09);  #1
     print mr_bdbsa500.atdsrvano,  ASCII(09);  #2
     print mr_bdbsa500.resultado,  ASCII(09);  #3
     print mr_bdbsa500.lclcttnom,  ASCII(09);  #4
     print mr_bdbsa500.celteldddcod, ASCII(09);
     print mr_bdbsa500.celtelnum
  on last row
     print 'BDBSA500'

end report

#-------------------------------------------------
function bdbsa500_mail()
#-------------------------------------------------

 define lr_mail record
         rem     char(50)
        ,des     char(10000)
        ,ccp     char(10000)
        ,cco     char(10000)
        ,ass     char(500)
        ,msg     char(32000)
        ,idr     char(20)
        ,tip     char(4)
 end record
 define l_email char(50)
       ,l_cod_erro  integer
       ,l_msg_erro  char(20)
       ,l_comando char(100)
       ,l_data datetime year to second
       ,l_char char(19)

 initialize lr_mail.* to null
 let lr_mail.rem = 'portosegurofaz@portoseguro.com.br'

  let l_comando = "gzip -f ", m_path2

  run l_comando
  let m_path2 = m_path2 clipped, ".gz"

 declare c01 cursor for
    select relpamtxt
      from igbmparam
     where relsgl = 'BDBSA500'
 foreach c01 into l_email

    if lr_mail.des is null then
       let lr_mail.des = l_email clipped
    else
       let lr_mail.des = lr_mail.des clipped,',',l_email clipped
    end if

 end foreach
 if lr_mail.des is null or lr_mail.des = ' ' then
    display 'Emails não cadastrados, assumindo valores fixos'
    let lr_mail.des = 'celso.yamahaki@portoseguro.com.br, klecio.portela@portoseguro.com.br'
 end if

 display 'email enviado para: ', lr_mail.des clipped

 if m_path2 is not null then
    call figrc009_attach_file(m_path2)
 end if

 let l_data = current
 let l_char = l_data
 let lr_mail.ccp = ""
 let lr_mail.cco = ""
 let lr_mail.ass = 'SMS enviados hoje: ', l_char
 let lr_mail.idr = "P0603000"
 let lr_mail.tip = "html"
 let lr_mail.msg = 'BDBSA500'
 call figrc009_mail_send1(lr_mail.*)
      returning l_cod_erro, l_msg_erro
 if l_cod_erro <> 0 then
    display 'l_cod_erro, l_msg_erro',l_cod_erro, l_msg_erro clipped
 end if
 let l_comando = 'rm ', m_path2 clipped

 run l_comando

 call bdbsa500_set_path()




end function
