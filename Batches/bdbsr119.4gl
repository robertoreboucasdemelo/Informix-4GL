#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema.......: Porto Socorro                                               #
# Modulo........: BDBSR119                                                    #
# Analista Resp.: Norton Nery                                                 #
# PSI...........: PSI228389                                                   #
# Objetivo......: Identificar e comunicar os prestadores, atraves de Email,   #
#                 Fax ou SMS dos servicos realizados a mais de 4 meses, que   #
#                 estao no sistema da porto e que ainda estao em aberto(nao   #
#                 foram cobrados).                                            #
#                                                                             #
#.............................................................................#
# Desenvolvimento: Diomar Rockenbach, Meta                                    #
# Liberacao......: 22/09/2008                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
# 02/06/10   Robert Lima             Inclusão das validações sql(pbdbsr119001)#
# 27/10/10   Robert Lima             Alteração da composição do codigo de SMS,#
#                                    aumentado o tamanho da variavel          #
#                                    l_srv_atra                               #
#-----------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/dssqa/producao/I4GLParams.4gl"

   define m_lidos       integer
         ,m_processados integer
         ,teste         char(1)

main

   define l_path               char(100)
         ,l_log                char(100)
         ,l_data_processamento date
         ,l_data_fim           date
         ,l_dataini            datetime year to second
         ,l_datafim            datetime year to second

   let l_path               = null
   let l_log                = null
   let l_data_processamento = null
   let l_dataini            = null
   let l_datafim            = null

   let m_lidos       = 0
   let m_processados = 0

   call fun_dba_abre_banco('CT24HS')

   let l_path = f_path('DBS', 'LOG')

   if l_path is null or
      l_path = ' '   then
      let l_path = '.'
   end if

   let l_path = l_path clipped, "/dbs_bdbsr119.log"
   call startlog(l_path)

   let l_log = 'Inicio do processamento............: ',today,' as: ',time
   call errorlog(l_log)
   display l_log clipped

   let l_data_processamento = arg_val(1)
   let l_data_fim           = arg_val(2)
   let l_datafim            = l_data_fim

   if l_data_processamento is null then
      let l_data_processamento = today
   end if

   if l_data_processamento is not null and
      l_datafim            is not null  then
      let l_dataini = l_data_processamento
    else
     let l_datafim = l_data_processamento - 4 units month
     let l_dataini = l_datafim - 3 units month
   end if

   
   

   call bdbsr119_prepare()

   call bdbsr119(l_dataini
                ,l_datafim)
                
   display "l_dataini: ", l_dataini
   display "l_datafim: ", l_datafim
 
   let l_log = 'Quantidade de registros lidos:.....: ',m_lidos
   call errorlog(l_log)
   display l_log clipped

   let l_log = 'Quantidade de registros processados: ',m_processados
   call errorlog(l_log)
   display l_log clipped

   display ''
   let l_log = 'Final  do processamento............:',today,' as: ',time
   call errorlog(l_log)
   display l_log clipped

end main

#--------------------------
function bdbsr119_prepare()
#--------------------------

   define l_sql char(1000)

   let l_sql = ' select atdsrvnum                  '
              ,'       ,atdsrvano                  '
              ,'       ,atdprscod                  '
              ,'  from datmservico,dpaksocor       '
              ,' where srvprsacnhordat >= ?        '
              ,'   and srvprsacnhordat <= ?        '
              ,'   and atdprscod = pstcoddig       '
              ,'   and prssitcod = "A"             '
              ,'   and datmservico.empcod <> 40    '
              ,'   and atdetpcod in (3,4)          '
              ,'   and atdprscod is not null       '
              ,'   and srvprsacnhordat is not null '
              ,'   and atdsrvorg not in (10, 13)   '
              ,'   and atdprscod > 99              '
              ,' order by 3                        '                         
                                                    
   prepare pbdbsr119001 from l_sql                  
   declare cbdbsr119001 cursor with hold for pbdbsr119001

   let l_sql = ' select 1 '
              ,'   from dbsmopgitm a, dbsmopg b '         
              ,'  where a.socopgnum = b.socopgnum '       
              ,'    and a.atdsrvnum = ? '                 
              ,'    and a.atdsrvano = ? '                 
              ,'    and b.socopgsitcod <> 8 '             

   prepare pbdbsr119002 from l_sql
   declare cbdbsr119002 cursor for pbdbsr119002

   let l_sql = ' select maides '
              ,'       ,dddcod '
              ,'       ,faxnum '
              ,'       ,celdddnum '
              ,'       ,celtelnum '
              ,'       ,nomgrr '
              ,'   from dpaksocor '
              ,'  where pstcoddig = ? '

   prepare pbdbsr119003 from l_sql
   declare cbdbsr119003 cursor for pbdbsr119003

   let l_sql = ' select max(dbsseqcod) '
              ,'   from dbsmhstprs '
              ,'  where pstcoddig = ? '

   prepare pbdbsr119004 from l_sql
   declare cbdbsr119004 cursor for pbdbsr119004

   let l_sql = ' insert into dbsmhstprs '
              ,'            (dbsseqcod '
              ,'            ,pstcoddig '
              ,'            ,prshstdes '
              ,'            ,caddat '
              ,'            ,cademp '
              ,'            ,cadusrtip '
              ,'            ,cadmat) '
              ,'            values '
              ,'            (?,?,?,today,?,?,?) '

   prepare pbdbsr119005 from l_sql

   let l_sql = ' select max(smsenvcod[7,10]) '
              ,'   from dbsmenvmsgsms '
              ,'  where smsenvcod[1,6] = ? '

   prepare pbdbsr119006 from l_sql
   declare cbdbsr119006 cursor for pbdbsr119006

   let l_sql = ' insert into dbsmenvmsgsms '
              ,'            (smsenvcod '
              ,'            ,dddcel  '
              ,'            ,celnum  '
              ,'            ,msgtxt  '
              ,'            ,incdat  '
              ,'            ,envstt) '
              ,'             values  '
              ,'           (?,?,?,?,current,"A") '

   prepare pbdbsr119007 from l_sql

   let l_sql  = "select fntidxseq, "         ,
                "lgtcvscod "          ,
                "from IGBKLOGO "           ,
                "where impfrmcod = 'FVP08' ",
                "and cvnnum = 0 "

   prepare s_igbklogo from l_sql
   declare c_igbklogo cursor for s_igbklogo

end function

#--------------------------
function bdbsr119(lr_param)
#--------------------------

   define lr_param record
          dataini  datetime year to second
         ,datafim  datetime year to second
   end record

   define lr_bdbsr119 record
          atdsrvnum     like datmservico.atdsrvnum
         ,atdsrvano     like datmservico.atdsrvano
         ,atdprscod     like datmservico.atdprscod
         ,atdprscod_ant like datmservico.atdprscod
   end record

   define lr_retorno     record
      totanl             smallint
     ,c24evtcod_svl      like datkevt.c24evtcod
     ,c24fsecod_svl      like datkevt.c24fsecod
   end record

   define l_srv_atra  char(10000)
         ,l_log       char(200)
         ,l_path      char(100)
         ,l_stt       smallint
         ,l_ctserv    integer

   initialize lr_bdbsr119, lr_retorno to null

   let l_srv_atra  = null
   let l_log       = null
   let l_stt       = null
   let l_ctserv    = 0

   begin work

   let l_path = f_path('DBS', 'RELATO')

   if l_path is null or
      l_path = ' '   then
      let l_path = '.'
   end if

   let l_path = l_path clipped, "/dbs_bdbsr119.xls"

   start report report_bdbsr119 to l_path

   open cbdbsr119001 using lr_param.dataini
                          ,lr_param.datafim

   foreach cbdbsr119001 into lr_bdbsr119.atdsrvnum
                            ,lr_bdbsr119.atdsrvano
                            ,lr_bdbsr119.atdprscod

      let m_lidos = m_lidos + 1

      open cbdbsr119002 using lr_bdbsr119.atdsrvnum
                             ,lr_bdbsr119.atdsrvano
      whenever error continue
      fetch cbdbsr119002
      whenever error stop

      if sqlca.sqlcode = 0 then
         continue foreach
      else
         if sqlca.sqlcode <> notfound then
            let l_log = 'Erro SELECT cbdbsr119002 | ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
            call errorlog(l_log)
            display l_log clipped
            let l_log = 'BDBSR119 | bdbsr119() | '
            call errorlog(l_log)
            display l_log clipped
            rollback work
            exit program(1)
         end if
      end if

      call ctb00g01_srvanl(lr_bdbsr119.atdsrvnum
                          ,lr_bdbsr119.atdsrvano
                          ,'N')
         returning lr_retorno.totanl
                  ,lr_retorno.c24evtcod_svl
                  ,lr_retorno.c24fsecod_svl

      if lr_retorno.totanl > 0 then
         continue foreach
      end if

      let m_processados = m_processados + 1

      if lr_bdbsr119.atdprscod <> lr_bdbsr119.atdprscod_ant then
            call bdbsr119_envia(lr_bdbsr119.atdprscod_ant
                               ,l_srv_atra
                               ,l_ctserv)
         let l_srv_atra = null
         let l_ctserv   = 0
      end if

      let lr_bdbsr119.atdprscod_ant = lr_bdbsr119.atdprscod
      let l_ctserv   = l_ctserv + 1

      if l_srv_atra is null or  ### NAO alterar a formatacao dos servicos sem mexer na gravao do historico do servico
         l_srv_atra = ' ' then
         let l_srv_atra = lr_bdbsr119.atdsrvnum using "&&&&&&&",'/',lr_bdbsr119.atdsrvano using '&&'
      else
         let l_srv_atra = l_srv_atra clipped,', ',lr_bdbsr119.atdsrvnum using "&&&&&&&",'/',lr_bdbsr119.atdsrvano using '&&'
      end if

      if m_lidos mod 100 = 0 then
         commit work
         begin work
      end if

   end foreach

   if m_lidos > 0 then
      call bdbsr119_envia(lr_bdbsr119.atdprscod_ant
                         ,l_srv_atra
                         ,l_ctserv)
   end if

   commit work
   finish report report_bdbsr119

   if m_lidos > 0 then
      let l_stt = ctx22g00_envia_email('BDBSR119'
                                      ,'Relacao de prestadores pendentes comunicados'
                                      ,l_path)
   end if

end function

#--------------------------------
function bdbsr119_envia(lr_param)
#--------------------------------

   define lr_param record
          atdprscod  like datmservico.atdprscod
         ,srv_atra   char(10000)
         ,ctserv   integer
   end record

   define lr_dados record
          maides     like dpaksocor.maides
         ,dddcod     like dpaksocor.dddcod
         ,faxnum     like dpaksocor.faxnum
         ,celdddnum  like dpaksocor.celdddnum
         ,celtelnum  like dpaksocor.celtelnum
         ,nomgrr     like dpaksocor.nomgrr
   end record

   define l_stt      smallint
         ,l_log      char(200)
         ,l_corpo    char(10000)
         ,l_mensagem char(10000)
         ,l_tipo     char(5)

   let l_stt      = 0
   let l_log      = null
   let l_corpo    = null
   let l_mensagem = null
   let l_tipo     = null

   initialize lr_dados to null

   call bdbsr119_busca_dados(lr_param.atdprscod)
      returning lr_dados.maides
               ,lr_dados.dddcod
               ,lr_dados.faxnum
               ,lr_dados.celdddnum
               ,lr_dados.celtelnum
               ,lr_dados.nomgrr

   if lr_dados.maides is not null and
      lr_dados.maides <> ' '      then

      if lr_param.ctserv = 1 then
         let l_corpo = 'Sr. Prestador \\n','\\n'
                     ,'Localizamos em nosso sistema um  servico que ainda nao foi cobrado: '
                     ,lr_param.srv_atra clipped,'.\\n','\\n',
                     'Em caso de dúvidas contatar 3366-6068 (para serviços automotivos)'
                     ,' ou 3366-6316 (para serviços residenciais)'
        else
         let l_corpo = 'Sr. Prestador \\n','\\n'
                     ,'Localizamos em nosso sistema alguns servicos que ainda nao foram cobrados: '
                     ,lr_param.srv_atra clipped,'.\\n','\\n',' Em caso de dúvidas contatar 3366-6068 (para serviços automotivos)'
                     ,' ou 3366-6316 (para serviços residenciais)'
      end if

      let l_stt = bdbsr119_envia_mail(l_corpo
                                     ,lr_dados.maides
                                     ,lr_dados.nomgrr)

      if l_stt <> 0 then
         let l_mensagem = 'Prestador nao comunicado. Erro no envio do EMAIL.' clipped
         call bdbsr119_grava_historico(lr_param.atdprscod
                                      ,l_mensagem
                                      ,""
                                      ,"EMAIL")
      else
         let l_tipo ='EMAIL'
         let l_mensagem = 'Servico(s) ',lr_param.srv_atra clipped,' com pagamento em aberto. Prestador comunicado atraves de e-mail' clipped
         call bdbsr119_grava_historico(lr_param.atdprscod
                                      ,l_mensagem
                                      ,lr_param.srv_atra
                                      ,l_tipo)
      end if

   else
      if lr_dados.celdddnum is not null and
         lr_dados.celdddnum <> ' '      and
         lr_dados.celtelnum is not null then
    
         let l_stt = bdbsr119_envia_sms(lr_param.atdprscod
                                        ,lr_dados.celdddnum
                                       ,lr_dados.celtelnum
                                       ,lr_param.srv_atra
                                       ,lr_param.ctserv)
         if l_stt <> 0 then
            let l_mensagem = 'Prestador nao comunicado. Erro no envio do SMS.'
            call bdbsr119_grava_historico(lr_param.atdprscod
                                         ,l_mensagem
                                         ,""
                                         ,"SMS")
         else
            let l_tipo ='SMS'
            let l_mensagem = 'Servico ',lr_param.srv_atra clipped,' com pagamento em aberto. Prestador comunicado atraves de SMS'
            call bdbsr119_grava_historico(lr_param.atdprscod
                                         ,l_mensagem
                                         ,lr_param.srv_atra
                                         ,l_tipo)
         end if

      else
         let l_tipo ='ERRO'
         let l_mensagem = 'Prestador nao comunicado. Nao existe Email, FAX ou Celular cadastrado.'
         call bdbsr119_grava_historico(lr_param.atdprscod
                                      ,l_mensagem
                                      ,""
                                      ,"NAO COMUNICADO")
         let l_stt = 3
      end if
   end if

   #if l_stt = 0 then
      output to report report_bdbsr119(lr_param.atdprscod
                                      ,lr_dados.nomgrr
                                      ,lr_param.srv_atra
                                      ,l_tipo)
   #end if

end function

#------------------------------------
function bdbsr119_envia_sms(lr_param)
#------------------------------------

   define lr_param record
          atdprscod like datmservico.atdprscod
         ,ddd       like dpaksocor.dddcod
         ,celtelnum like dpaksocor.celtelnum
         ,srv_atra  char(10000)
         ,ctserv    integer
   end record

   define lr_retorno  record
      stt             smallint             # 1=Ok 2=Notfound 3-Erro Sql
     ,oprcod          like pcckceltelopr.oprcod
     ,oprnom          like pcckceltelopr.oprnom
     ,opratvflg       like pcckceltelopr.opratvflg
     ,msgerr          char(80)
   end record

   define l_smsenvcod    char(10)
         ,l_smsenvcodaux char(10)
         ,l_sequencial   smallint #decimal(3,0)
         ,l_log          char(200)
         ,l_mensagem     char(10000)
         ,l_mensagem2    char(255)
         ,l_count        smallint
         ,l_iter         integer
         ,l_length       integer
         ,l_length2      integer

   let l_sequencial = 0
   let l_mensagem   = null
   let l_mensagem2  = null
   let l_iter       = 0
   let l_length     = 0
   let l_length2    = 0

   initialize lr_retorno to null

   call fpccc016_obterOperadora(lr_param.ddd
                               ,lr_param.celtelnum)
      returning lr_retorno.stt
               ,lr_retorno.oprcod
               ,lr_retorno.oprnom
               ,lr_retorno.opratvflg
               ,lr_retorno.msgerr

   if lr_retorno.stt = 1 then
      let lr_retorno.stt = 0
      
      let l_smsenvcodaux = "A", lr_param.atdprscod using "&&&&&"
      
      open cbdbsr119006 using l_smsenvcodaux 
      whenever error continue
      fetch cbdbsr119006 into l_sequencial
      whenever error stop
      
      if sqlca.sqlcode <> 0 then
         let l_log = 'Erro SELECT cbdbsr119006 | ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
         call errorlog(l_log)
         display l_log clipped
         let l_log = 'bdbsr119 | bdbsr119_envia_sms() | '
         call errorlog(l_log)
         display l_log clipped
         rollback work
         exit program(1)
      end if

      if l_sequencial is null then
         let l_sequencial = 0
      else
         let l_sequencial = l_sequencial + 1
      end if

      let l_smsenvcod = "A" clipped
                       ,lr_param.atdprscod using "&&&&&"
                       ,l_sequencial using "&&&&"

      if lr_param.ctserv = 1 then
         let l_mensagem =  'Sr. Prestador: o seguinte servico ainda nao foi cobrado:'
                          ,lr_param.srv_atra clipped
                          ,' - Em caso de duvidas contatar 3366-6068 (para servicos automotivos)'
                          ,' ou 3366-6316 (para servicos residenciais)'
        else
         let l_mensagem =  'Sr. Prestador: os seguintes servicos ainda nao foram cobrados:'
                          ,lr_param.srv_atra clipped
                          ,' - Em caso de duvidas contatar 3366-6068 (para servicos automotivos)'
                          ,' ou 3366-6316 (para servicos residenciais)'

      end if

      let l_length = length(l_mensagem)
      if  l_length mod 255 = 0 then
         let l_iter = l_length / 255
      else
         let l_iter = l_length / 255 + 1
      end if

      for l_count = 1 to l_iter
         if  l_count = l_iter then
             let l_mensagem2 = l_mensagem[l_length2 + 1, l_length]
         else
             let l_length2   = l_length2 + 255
             let l_mensagem2 = l_mensagem[l_length2 - 254, l_length2]
         end if

         whenever error continue
         execute pbdbsr119007 using l_smsenvcod
                                   ,lr_param.ddd
                                   ,lr_param.celtelnum
                                   ,l_mensagem2
         whenever error stop

         if sqlca.sqlcode <> 0 then
            let l_log = 'Erro INSERT pbdbsr119007 | ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
            call errorlog(l_log)
            display l_log clipped
            let l_log = 'bdbsr119 | bdbsr119_envia_sms() | ',l_smsenvcod,' | '
                                                            ,lr_param.ddd,' | '
                                                            ,lr_param.celtelnum,' | '
                                                            ,l_mensagem2
            call errorlog(l_log)
            display l_log clipped
            rollback work
            exit program(1)
         end if

         let l_sequencial = l_sequencial + 1

         let l_smsenvcod = "A" clipped
                          ,lr_param.atdprscod using "&&&&&"
                          ,l_sequencial using "&&&&"

      end for
   else
      if lr_retorno.stt = 3 then
         let l_log = 'Erro no retorno da funcao fpccc016_obterOperadora'
         call errorlog(l_log)
         display l_log clipped
         rollback work
         exit program(1)
      end if
      let lr_retorno.stt = 1
   end if

   return lr_retorno.stt

end function

#-------------------------------------
function bdbsr119_envia_mail(lr_param)
#-------------------------------------

   define lr_param record
          mensagem char(10000)
         ,mail     char(50)
         ,nomgrr   like dpaksocor.nomgrr
   end record

   define l_comando char(10000)
         ,l_assunto char(100)
         ,l_stt     smallint
         
   ### RODOLFO MASSINI - INICIO 
   #---> Variaves para:
   #     remover (comentar) forma de envio de e-mails anterior e inserir
   #     novo componente para envio de e-mails.
   #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
   define lr_mail record       
          rem char(50),        
          des char(250),       
          ccp char(250),       
          cco char(250),       
          ass char(500),       
          msg char(32000),     
          idr char(20),        
          tip char(4)          
   end record 
 
   define l_anexo   char (300)
         ,l_retorno smallint

   initialize lr_mail
             ,l_anexo
             ,l_retorno
   to null
 
   ### RODOLFO MASSINI - FIM 

   let l_comando = null
   let l_assunto = null
   let l_stt     = 0
     
   ### RODOLFO MASSINI - INICIO 
   #---> remover (comentar) forma de envio de e-mails anterior e inserir
   #     novo componente para envio de e-mails.
   #---> feito por Rodolfo Massini (F0113761) em maio/2013
  
   #let l_comando = " echo '",lr_param.mensagem clipped,"' | /usr/bin/send_email.sh "
   #               ," -a ",lr_param.mail
   #               ," -s  '", lr_param.nomgrr clipped, " - Servicos em Atraso Porto Seguro'"
   #               ," -r  porto.socorro@portoseguro.com.br"

   #run l_comando
   #   returning l_stt
      
   let lr_mail.ass = lr_param.nomgrr clipped, " - Servicos em Atraso Porto Seguro"
   let lr_mail.msg = lr_param.mensagem clipped     
   let lr_mail.rem = "porto.socorro@portoseguro.com.br"
   let lr_mail.des = lr_param.mail clipped
   let lr_mail.tip = "text"
   let l_anexo = null
 
   call ctx22g00_envia_email_overload(lr_mail.*
                                     ,l_anexo)
   returning l_retorno     
   
   let l_stt = l_retorno                                   
                                                
   ### RODOLFO MASSINI - FIM 
   

   return l_stt

end function

#------------------------------------
function bdbsr119_envia_fax(lr_param)
#------------------------------------

   define lr_param record
          atdprscod  like datmservico.atdprscod
         ,nomgrr     like dpaksocor.nomgrr
         ,srv_atra   char(10000)
         ,ddd        like dpaksocor.dddcod
         ,faxnum     like dpaksocor.faxnum
         ,ctserv     integer
   end record

   define lr_retorno   record
      faxch1           like gfxmfax.faxch1
     ,faxch2           like gfxmfax.faxch2
     ,envflg           smallint
   end record

   define l_faxtxt char (12)
         ,l_path   char(200)
         ,l_cmd    char(400)
         ,l_stt    smallint
         ,l_log    char(400)


   let l_faxtxt = null
   let l_path   = null
   let l_cmd    = null
   let l_log    = null
   let l_stt    = 0

   initialize lr_retorno to null

   let l_path = f_path('DBS', 'RELATO')

   if l_path is null or
      l_path = ' '   then
      let l_path = '.'
   end if

   let l_path = l_path clipped, "/dbs_bdbsr119_fax.txt"

   call cts10g01_enviofax (''
                          ,''
                          ,lr_param.atdprscod
                          ,'PS'
                          ,g_issk.funmat)
      returning lr_retorno.envflg
               ,lr_retorno.faxch1
               ,lr_retorno.faxch2

   if not lr_retorno.envflg then
      let l_log = 'Erro na funcao cts10g01_enviofax'
      call errorlog(l_log)
      display l_log clipped
      rollback work
      exit program(1)
   end if

   let l_faxtxt = cts02g01_fax(lr_param.ddd
                              ,lr_param.faxnum)

   start report report_bdbsr119_fax to l_path

   output to report report_bdbsr119_fax(lr_param.atdprscod
                                       ,lr_param.nomgrr
                                       ,lr_param.srv_atra
                                       ,lr_param.ddd
                                       ,lr_param.faxnum
                                       ,lr_retorno.faxch1
                                       ,lr_retorno.faxch2
                                       ,lr_param.ctserv)

   finish report report_bdbsr119_fax

 #--------------------------------------
 # Envio de FAX cancelado
 # Por Eliane K., Fornax em 10/11/2015
 #----------------------------------------    
 #  let l_cmd = "cat ",l_path clipped,"|","vfxCTPS ",l_faxtxt clipped," ", ascii 34
 #                    ,lr_param.atdprscod, ascii 34, " "
 #                     ,lr_retorno.faxch1 using "<<<<<<<<<<", " "
 #                     ,lr_retorno.faxch2 using "<<<<<<<<<<"
 #
 #  run l_cmd
 #      returning l_stt
 #
 #   if l_stt <> 0 then
 #      let l_log = 'Erro no envio do FAX para prestador: ',lr_param.atdprscod
 #      call errorlog(l_log)
 #      display l_log clipped
 #      let l_stt = 1
 #   else
 #      let l_cmd = 'rm -f ', l_path
 #      run l_cmd
 #   end if

   return l_stt

end function

#------------------------------------------
function bdbsr119_grava_historico(lr_param)
#------------------------------------------

   define lr_param record
          atdprscod like datmservico.atdprscod
         ,mensagem  char(10000)
         ,servicos  char(10000)
         ,tipo      char(12)
   end record

   define l_seq       smallint
         ,l_mensagem  char(70)
         ,l_count     smallint
         ,l_iter      integer
         ,l_length    integer
         ,l_length2   integer
         ,l_log       char(300)
         ,l_empcod    like dbsmhstprs.cademp
         ,l_usrtip    like dbsmhstprs.cadusrtip
         ,l_funmat    like dbsmhstprs.cadmat
         ,l_data      date
         ,l_hora      datetime hour to minute
         ,l_atdsrvnum like datmservico.atdsrvnum
         ,l_atdsrvano like datmservico.atdsrvano
         ,l_retorno   smallint
         ,l_msgsrv    char(70)

   let l_seq      = 0
   let l_mensagem = null
   let l_iter     = 0
   let l_length   = 0
   let l_length2  = 0
   let l_log      = null

   #Busca data e hora do banco
    call cts40g03_data_hora_banco(2)
        returning l_data, l_hora

   open cbdbsr119004 using lr_param.atdprscod

   whenever error continue
   fetch cbdbsr119004 into l_seq
   whenever error stop
   
   if sqlca.sqlcode <> 0 then
      let l_log = 'Erro SELECT cbdbsr119004 | ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
      call errorlog(l_log)
      display l_log clipped
      let l_log = 'bdbsr119 | bdbsr119_grava_historico() | ',lr_param.atdprscod
      call errorlog(l_log)
      display l_log clipped
      rollback work
      exit program(1)
   end if

   if l_seq is null then
      let l_seq = 0
   end if

   let l_seq = l_seq +1

   let l_length = length(lr_param.mensagem)
   if  l_length mod 70 = 0 then
      let l_iter = l_length / 70
   else
      let l_iter = l_length / 70 + 1
   end if

   let l_empcod = 1
   let l_usrtip = "F"
   let l_funmat = 999999

   for l_count = 1 to l_iter
      if  l_count = l_iter then
          let l_mensagem = lr_param.mensagem[l_length2 + 1, l_length]
      else
          let l_length2 = l_length2 + 70
          let l_mensagem = lr_param.mensagem[l_length2 - 69, l_length2]
      end if
      
      if l_mensagem is not null then
        whenever error continue
         execute pbdbsr119005 using l_seq
                                ,lr_param.atdprscod
                                ,l_mensagem
                                ,l_empcod
                                ,l_usrtip
                                ,l_funmat

        whenever error stop

         if sqlca.sqlcode <> 0 then
            let l_log = 'Erro INSERT pbdbsr119005 | ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
            call errorlog(l_log)
            display l_log clipped
            let l_log = 'bdbsr119 | bdbsr119_grava_historico() | ',lr_param.atdprscod
                                                                 ,l_seq
                                                                 ,l_mensagem
                                                                 ,l_empcod
                                                                 ,l_usrtip
                                                                 ,l_funmat
            call errorlog(l_log)
            display l_log clipped
            rollback work
            exit program(1)
         end if
      end if
          
      open cbdbsr119004 using lr_param.atdprscod

      whenever error continue
      fetch cbdbsr119004 into l_seq
      whenever error stop     
      
      let l_seq = l_seq + 1           
      
   end for

   let l_msgsrv = "SERVICO COM PAGAMENTO EM ABERTO. PRESTADOR COMUNICADO POR ", lr_param.tipo
   let l_length = length(lr_param.servicos)
   for l_count = 1 to l_length step 12
       let l_atdsrvnum = lr_param.servicos[l_count, l_count + 6]
       let l_atdsrvano = lr_param.servicos[l_count + 8, l_count + 9]

       call ctd07g01_ins_datmservhist(l_atdsrvnum,
                                      l_atdsrvano,
                                      l_funmat,
                                      l_msgsrv,
                                      l_data,
                                      l_hora,
                                      l_empcod,
                                      l_usrtip)
                            returning l_retorno,
                                      l_mensagem

  end for

end function

#-----------------------------------
report report_bdbsr119_fax(lr_param)
#-----------------------------------

   define lr_param record
          atdprscod  like datmservico.atdprscod
         ,nomgrr     like dpaksocor.nomgrr
         ,srv_atra   char(10000)
         ,ddd        like dpaksocor.dddcod
         ,faxnum     like dpaksocor.faxnum
         ,faxch1     like gfxmfax.faxch1
         ,faxch2     like gfxmfax.faxch2
         ,ctserv     integer
   end record

   define l_mensagem   char(10000)
          ,l_mensagem2 char(132)
          ,l_count     smallint
          ,l_iter      integer
          ,l_length    integer
          ,l_length2   integer
          ,l_servaux   char(20)
          ,l_servaux2  char(20)
          ,l_logotipo  char(13)

   define w_indx1     char(01)
   define w_logo1     char(02)

   output
      top    margin 0
      left   margin 0
      bottom margin 0
      right  margin 80

   format

      on every row

         print column 001, ascii 27, "&k2S"
         print             ascii 27, "(s7b"
         print             ascii 27, "(s4102T"
         print             ascii 27, "&l08D"
         print

        # print column 000, ascii 27, "&k2S";        #--> Caracteres
        # print             ascii 27, "(s7b";        #--> de controle
        # print             ascii 27, "(s4102T";     #--> para 132
        # print             ascii 27, "&l08D";       #--> colunas
         print             ascii 27, "&l00E";       #--> Logo no topo
         print column 001, "@+IMAGE[porto.tif;x=0cm;y=0cm]"

         skip 11 lines

         print column 001, "Enviar para: ",lr_param.atdprscod
                         , " Fax: ", "(",lr_param.ddd, ")",lr_param.faxnum
         skip 1 line

         let l_mensagem  = null
         let l_mensagem2 = null
         let l_iter      = 0
         let l_length    = 0
         let l_length2   = 0

         print  column 001, '============='
         print  column 001, 'Sr. Prestador : ',lr_param.nomgrr
         skip 1 line

         if lr_param.ctserv = 1 then
            print  column 001, 'Localizamos em nosso sistema um  servico que ainda nao foi cobrado: '
            skip 1 line
            print  column 001, lr_param.srv_atra clipped
          else

            print  column 001, 'Localizamos em nosso sistema alguns servicos que ainda nao foram cobrados: '

            let l_length = length(lr_param.srv_atra)
            let l_iter   = l_length + 1
            let l_servaux = null
            for l_count = 1 to l_iter
                if  l_count = l_iter then
                    skip 1 line
                    print  column 001,  l_servaux
                end if

                if lr_param.srv_atra[l_count,l_count] = ","  then
                    skip 1 line
                    print  column 001,  l_servaux
                    let l_servaux = null
                 else
                   let l_servaux = l_servaux clipped, lr_param.srv_atra[l_count,l_count]
                end if
            end for
         end if

         skip  1 line
         print  column 001, 'Em caso de dúvidas contatar 3366-6068 (para serviços automotivos) ',
                            ' ou 3366-6316 (para serviços residenciais) '

end report

#-------------------------------
report report_bdbsr119(lr_param)
#-------------------------------

   define lr_param record
           atdprscod  like datmservico.atdprscod
          ,nomgrr     like dpaksocor.nomgrr
          ,srv_atra   char(10000)
          ,TIPo       char(5)
   end record

   output
      top    margin 0
      left   margin 0
      bottom margin 0
      right  margin 80
      page   length 1

   format

      on every row
         if pageno = 1 then
            print column 01,'Prestador_Codigo', ascii(9)
                           ,'Prestador_nome', ascii(9)
                           ,'Servicos Pendentes', ascii(9)
                           ,'Tipo do comunicado'
         end if

         print column 01,lr_param.atdprscod ,ascii(9)
                        ,lr_param.nomgrr clipped   ,ascii(9)
                        ,lr_param.srv_atra clipped ,ascii(9)
                        ,lr_param.tipo
end report

#-----------------------------------------
function bdbsr119_busca_dados(l_atdprscod)
#-----------------------------------------

   define l_atdprscod like datmservico.atdprscod

   define lr_dados record
          maides     like dpaksocor.maides
         ,dddcod     like dpaksocor.dddcod
         ,faxnum     like dpaksocor.faxnum
         ,celdddnum  like dpaksocor.celdddnum
         ,celtelnum  like dpaksocor.celtelnum
         ,nomgrr     like dpaksocor.nomgrr
   end record

   define l_log char(300)

   initialize lr_dados to null

   open cbdbsr119003 using l_atdprscod

   whenever error continue
   fetch cbdbsr119003 into lr_dados.maides
                          ,lr_dados.dddcod
                          ,lr_dados.faxnum
                          ,lr_dados.celdddnum
                          ,lr_dados.celtelnum
                          ,lr_dados.nomgrr
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_log = 'Dados do prestador :',l_atdprscod,' nao cadastrados'
         call errorlog(l_log)
      else
         let l_log = 'Erro SELECT cbdbsr119003 | ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
         call errorlog(l_log)
         display l_log clipped
         let l_log = 'bdbsr119 | bdbsr119_busca_dados() | ',l_atdprscod
         call errorlog(l_log)
         display l_log clipped
         rollback work
         exit program(1)
      end if
   end if

   return lr_dados.maides
         ,lr_dados.dddcod
         ,lr_dados.faxnum
         ,lr_dados.celdddnum
         ,lr_dados.celtelnum
         ,lr_dados.nomgrr

end function

