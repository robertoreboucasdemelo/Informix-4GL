#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24Hrs                                               #
# Modulo.........: ctb30m00                                                    #
# Objetivo.......: Enviar Email ao cliente e aos representantes da empresa,    #
#                  SMS e QRU com informacoes de alteracao de destinos de       #
#                  servicos                                                    #
# Analista Resp. :                                                             #
# Desenvolvido   : Caroline Moliterno, BizTalking                              #
# PSI            : PSI-201122603/PR                                            #
#..............................................................................#
# Data           : 26/03/2012                                                  #
#..............................................................................#
#                 * * *  ALTERACOES  * * *                                     #
#                                                                              #
# Data       Autor  Fabrica Origem    Alteracao                                #
# ---------- -------------- --------- -----------------------------------------#
# 23/07/2012 Joao Gradin    PSI 22603 Ajuste no texto email enviado para a     #
#                                     empresa e cliente.                       #
#                                     Ajuste no texto sms enviado ao cliente.  #
#                                     Reenvio da QRU enviada ao prestador.     #
#------------------------------------------------------------------------------#
 database porto

#globals "glct.4gl"
globals "/homedsa/projetos/geral/globals/glct.4gl"

 define mr_de         record
        atdsrvnum     like datmlcl.atdsrvnum        #Servico
       ,atdsrvano     like datmlcl.atdsrvano        #Ano
       ,lgdcep        char(9)                       #CEP (00000-000)
       ,cidnom        like datmlcl.cidnom           #Cidade
       ,ufdcod        like datmlcl.ufdcod           #UF
       ,lgdtip        like datmlcl.lgdtip           #Tipo Lgrd
       ,lgdnom        like datmlcl.lgdnom           #Logradouro
       ,lgdnum        like datmlcl.lgdnum           #Numero
       ,brrnom        like datmlcl.brrnom           #Bairro
 end record

 define mr_para       record
        atdsrvnum     like datmlcl.atdsrvnum        #Servico
       ,atdsrvano     like datmlcl.atdsrvano        #Ano
       ,lgdcep        char(9)                       #CEP (00000-000)
       ,cidnom        like datmlcl.cidnom           #Cidade
       ,ufdcod        like datmlcl.ufdcod           #UF
       ,lgdtip        like datmlcl.lgdtip           #Tipo Lgrd
       ,lgdnom        like datmlcl.lgdnom           #Logradouro
       ,lgdnum        like datmlcl.lgdnum           #Numero
       ,brrnom        like datmlcl.brrnom           #Bairro
 end record

 define mr_ret        record
        errcod        smallint                      #Cod. Erro
       ,errdes        char(150)                     #Descricao Erro
 end record

 define m_empcod        like datmservico.empcod     #Empresa
       ,m_nome          char(50)                    #Nome
       ,m_chave         char(20)                    #Chave envio email Empresa
       ,m_atdsrvorg     like datmservico.atdsrvorg  #Origem do Servico
       ,m_qthqti        decimal(8,4)                #Distancia
       ,m_segnumdig     like gsakendmai.segnumdig   #Segurado
       ,m_maides        like gsakendmai.maides      #Email segurado
       ,m_segnom        like gsakseg.segnom         #Nome segurado
       ,m_asitipcod     like datmservico.asitipcod  #Assistencia
       ,m_asitipdes     like datkasitip.asitipdes   #Descricao Tipo Assistencia
       ,m_nomlaudo      like datmservico.nom        #Nome Cliente no Laudo
       ,m_c24pbmdes     like datrsrvpbm.c24pbmdes   #Problema
       ,m_dddcod        like datmlcl.dddcod         #DDD
       ,m_lcltelnum     like datmlcl.lcltelnum      #Tel
       ,m_lclcttnom     like datmlcl.lclcttnom      #Nome
       ,m_lclrefptotxt  like datmlcl.lclrefptotxt   #Referencia  
       ,m_ciaempnom     char(50)                    #Moreira - #Nome da Empresa

#------------------------------------------------------------------------------#
function ctb30m00_prepare()
#------------------------------------------------------------------------------#

   define l_sql   char(500)

   let l_sql = ' select ciaempcod     '
              ,'       ,atdsrvorg     '
              ,'       ,asitipcod     '
              ,'       ,nom           '
              ,'   from datmservico   '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
   prepare pctb30m00001 from l_sql
   declare cctb30m00001 cursor for pctb30m00001

   let l_sql = ' select cpodes      '
              ,'   from iddkdominio '
              ,'  where cponom = ?  '
   prepare pctb30m00002 from l_sql
   declare cctb30m00002 cursor for pctb30m00002

   let l_sql = ' insert into dbsmenvmsgsms (smsenvcod  '
              ,'                           ,celnum     '
              ,'                           ,msgtxt     '
              ,'                           ,envdat     '
              ,'                           ,incdat     '
              ,'                           ,envstt     '
              ,'                           ,errmsg     '
              ,'                           ,dddcel     '
              ,'                           ,envprghor )'
              ,' values (?,?,?,?,?,?,?,?,?)            '
   prepare pctb30m00003 from l_sql

   let l_sql = ' select socvclcod      '
              ,'   from dattfrotalocal '
              ,'  where atdsrvnum = ?  '
              ,'    and atdsrvano = ?  '
   prepare pctb30m00004 from l_sql
   declare cctb30m00004 cursor for pctb30m00004

   let l_sql = ' select lclcttnom     '
              ,'       ,celteldddcod  '
              ,'       ,celtelnum     '
              ,'       ,lclrefptotxt  '
              ,'   from datmlcl       '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
   prepare pctb30m00005 from l_sql
   declare cctb30m00005 cursor for pctb30m00005

   let l_sql = ' select vclanomdl     '
              ,'       ,vcllicnum     '
              ,'       ,vcldes        '
              ,'       ,nom           '
              ,'       ,vclcorcod     '
              ,'   from datmservico   '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
   prepare pctb30m00006 from l_sql
   declare cctb30m00006 cursor for pctb30m00006

   let l_sql = ' select cpodes     '
              ,'  from iddkdominio '
              ,' where cponom = "vclcorcod" '
              ,'   and cpocod = ?  '
   prepare pctb30m00007 from l_sql
   declare cctb30m00007 cursor for pctb30m00007

   let l_sql = ' select segnumdig     '
              ,'   from abbmdoc       '
              ,'  where succod    = ? '
              ,'    and aplnumdig = ? '
              ,'    and itmnumdig = ? '
              ,'    and dctnumseq = ? '
   prepare pctb30m00008 from l_sql
   declare cctb30m00008 cursor for pctb30m00008

   let l_sql = ' select maides        '
              ,'   from gsakendmai    '
              ,'  where segnumdig = ? '
   prepare pctb30m00009 from l_sql
   declare cctb30m00009 cursor for pctb30m00009

   let l_sql = ' select segnom        '
              ,'   from gsakseg       '
              ,'  where segnumdig = ? '
   prepare pctb30m00010 from l_sql
   declare cctb30m00010 cursor for pctb30m00010

   let l_sql = ' select c24pbmdes     '
              ,'   from datrsrvpbm    '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
              ,'    and c24pbmseq = 1 '
   prepare pctb30m00011 from l_sql
   declare cctb30m00011 cursor for pctb30m00011

   let l_sql = ' select empnom      '
              ,'   from gabkemp     '
              ,'  where empcod  = ? '
   prepare pctb30m00012 from l_sql
   declare cctb30m00012 cursor for pctb30m00012

   let l_sql = ' select rmcacpflg      '
              ,'   from datmservicocmp '
              ,'  where atdsrvnum = ?  '
              ,'    and atdsrvano = ?  '
   prepare pctb30m00013 from l_sql
   declare cctb30m00013 cursor for pctb30m00013

   let l_sql = ' select b.socopgnum, b.socopgsitcod  '
              ,'   from dbsmopgitm a  '
              ,'       ,dbsmopg b     '
              ,'  where a.socopgnum = b.socopgnum '
              ,'    and a.atdsrvnum = ?     '
              ,'    and a.atdsrvano = ?     '
              ,'    and b.socopgsitcod <> 8 '
   prepare pctb30m00014 from l_sql
   declare cctb30m00014 cursor for pctb30m00014

   let l_sql = ' select asitipdes  '
              ,'   from datkasitip '
              ,'  where asitipcod = ? '
   prepare pctb30m00015 from l_sql
   declare cctb30m00015 cursor for pctb30m00015

end function

#------------------------------------------------------------------------------#
function ctb30m00_apos_alt_end_dst(lr_de, lr_para, l_qthqti)
#------------------------------------------------------------------------------#
   define lr_de         record
          atdsrvnum     like datmlcl.atdsrvnum
         ,atdsrvano     like datmlcl.atdsrvano
         ,lgdcep        char(9)
         ,cidnom        like datmlcl.cidnom
         ,ufdcod        like datmlcl.ufdcod
         ,lgdtip        like datmlcl.lgdtip
         ,lgdnom        like datmlcl.lgdnom
         ,lgdnum        like datmlcl.lgdnum
         ,brrnom        like datmlcl.brrnom
   end record

   define lr_para       record
          atdsrvnum     like datmlcl.atdsrvnum
         ,atdsrvano     like datmlcl.atdsrvano
         ,lgdcep        char(9)
         ,cidnom        like datmlcl.cidnom
         ,ufdcod        like datmlcl.ufdcod
         ,lgdtip        like datmlcl.lgdtip
         ,lgdnom        like datmlcl.lgdnom
         ,lgdnum        like datmlcl.lgdnum
         ,brrnom        like datmlcl.brrnom
   end record

   define l_qthqti      decimal(8,4)

   define lr_documento  record
          succod        like datrligapol.succod       # Codigo Sucursal
         ,aplnumdig     like datrligapol.aplnumdig    # Numero Apolice
         ,itmnumdig     like datrligapol.itmnumdig    # Numero do Item
         ,edsnumref     like datrligapol.edsnumref    # Numero do Endosso
         ,ramcod        like datrservapol.ramcod      # Codigo aamo
         ,corsus        char(06)                      # SUSEP
   end record

   define lr_documento2 record
          viginc        date
         ,vigfnl        date
         ,segcod        integer
         ,segnom        char(50)
         ,vcldes        char(25)
         ,resultado     smallint
         ,emsdat        date
         ,doc_handle    integer
         ,mensagem      char(50)
         ,situacao      char(10)
   end record

   define l_lignum      like datrligsrv.lignum  #Num. da ligacao

   initialize mr_ret
             ,m_empcod
             ,m_atdsrvorg
             ,m_asitipcod
             ,m_asitipdes
             ,m_nomlaudo
             ,m_chave
             ,m_nome
             ,mr_de
             ,mr_para
             ,m_qthqti
             ,m_c24pbmdes to null

   let mr_de.*   = lr_de.*
   let mr_para.* = lr_para.*
   let m_qthqti  = l_qthqti

   let mr_ret.errcod = 0

   call ctb30m00_prepare()

   #Busca empresa e origem do servico
   open cctb30m00001 using mr_de.atdsrvnum
                          ,mr_de.atdsrvano
   whenever error continue
   fetch cctb30m00001 into m_empcod
                          ,m_atdsrvorg
                          ,m_asitipcod
                          ,m_nomlaudo
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let mr_ret.errcod = sqlca.sqlcode
      if sqlca.sqlcode = 100 then
         let mr_ret.errdes = 'Empresa nao identificada para o Ano: '
                             ,mr_de.atdsrvano,' e Servico: '
                             ,mr_de.atdsrvnum
      else
         let mr_ret.errdes = 'Erro ao identificar a empresa com Ano: '
                             ,mr_de.atdsrvano,' e Servico: '
                             ,mr_de.atdsrvnum
      end if

      close cctb30m00001

      return mr_ret.errcod
            ,mr_ret.errdes
   end if
   close cctb30m00001

   #Busca descricao do tipo de assistencia
   open cctb30m00015 using m_asitipcod

   whenever error continue
   fetch cctb30m00015 into m_asitipdes

   whenever error stop
   if sqlca.sqlcode <> 0 then
      let mr_ret.errcod = sqlca.sqlcode
      if sqlca.sqlcode = 100 then
         let mr_ret.errdes = 'Descricao do tipo de assistencia nao cadastrada'
      else
         let mr_ret.errdes = 'Erro ao selecionar descricao tipo de assistencia'
      end if

      close cctb30m00015

      return mr_ret.errcod
            ,mr_ret.errdes
   end if
   close cctb30m00015

   #Busca Tel do segurado
   open cctb30m00005 using mr_de.atdsrvnum
                          ,mr_de.atdsrvano
   whenever error continue
   fetch cctb30m00005 into m_lclcttnom
                          ,m_dddcod
                          ,m_lcltelnum
                          ,m_lclrefptotxt
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let mr_ret.errcod = sqlca.sqlcode
      if sqlca.sqlcode = 100 then
         let mr_ret.errdes = 'Atendimento nao iniciado - SMS. Ano: '
                             ,mr_de.atdsrvano,' e Servico: '
                             ,mr_de.atdsrvnum
      else
         let mr_ret.errdes = 'Erro ao verificar dados do atendimento Ano: '
                             ,mr_de.atdsrvano,' e Servico: '
                             ,mr_de.atdsrvnum
      end if

      close cctb30m00005
      return mr_ret.errcod
            ,mr_ret.errdes
   end if

   close cctb30m00005

   if m_dddcod is null then
      let m_dddcod = 0
   end if

   #Busca o problema de acordo com o servico
   open cctb30m00011 using mr_de.atdsrvnum
                          ,mr_de.atdsrvano
   whenever error continue
   fetch cctb30m00011 into m_c24pbmdes
   whenever error stop
   if sqlca.sqlcode < 0 then
      let mr_ret.errcod = sqlca.sqlcode
      let mr_ret.errdes = 'Erro ao identificar o problema com Ano: '
                          ,mr_de.atdsrvano,' e Servico: '
                          ,mr_de.atdsrvnum

      close cctb30m00011
      return mr_ret.errcod
            ,mr_ret.errdes
   end if

   close cctb30m00011

   #Busca o nome da empresa
   open cctb30m00012 using m_empcod
   whenever error continue
   fetch cctb30m00012 into m_nome
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let mr_ret.errcod = sqlca.sqlcode
      if sqlca.sqlcode = 100 then
         let mr_ret.errdes = 'Nome da empresa nao encontrado. Empresa: '
                             ,m_empcod
      else
         let mr_ret.errdes = 'Erro ao buscar o nome da empresa. Empresa: '
                             ,m_empcod
      end if

      close cctb30m00012
      return mr_ret.errcod
            ,mr_ret.errdes
   end if

   close cctb30m00012

   #Busca a ligacao referente ao servico/ano
   let l_lignum = cts20g00_servico(mr_de.atdsrvnum, mr_de.atdsrvano)

   #Busca dados do Documento - apolice
   call cts20g01_docto(l_lignum)
             returning g_documento.succod,
                       g_documento.ramcod,
                       g_documento.aplnumdig,
                       g_documento.itmnumdig,
                       g_documento.edsnumref,
                       g_documento.prporg,
                       g_documento.prpnumdig,
                       g_documento.fcapacorg,
                       g_documento.fcapacnum,
                       g_documento.itaciacod

   #Busca a situacao atual da apolice
   call f_funapol_ultima_situacao (g_documento.succod,
                                   g_documento.aplnumdig,
                                   g_documento.itmnumdig)
                         returning g_funapol.*

     #display "apolice: ", g_documento.aplnumdig
   if g_documento.aplnumdig is not null and
      g_documento.itmnumdig is not null then
      call cts38m00_dados_apolice(g_documento.succod
                                 ,g_documento.aplnumdig
                                 ,g_documento.itmnumdig
                                 ,g_documento.ramcod)
                        returning lr_documento.aplnumdig
                                 ,lr_documento.itmnumdig
                                 ,lr_documento.edsnumref
                                 ,lr_documento.succod
                                 ,lr_documento.ramcod
                                 ,lr_documento2.emsdat
                                 ,lr_documento2.viginc
                                 ,lr_documento2.vigfnl
                                 ,lr_documento2.segcod
                                 ,lr_documento2.segnom
                                 ,lr_documento2.vcldes
                                 ,lr_documento.corsus
                                 ,lr_documento2.doc_handle
                                 ,lr_documento2.resultado
                                 ,lr_documento2.mensagem
                                 ,lr_documento2.situacao
   end if

   close cctb30m00010

   #Trata o nome e a chave para envio dos emails
   case m_empcod
      when 1
         let m_chave = 'EMAILALTDEST01'

         #Busca Segurado
         open cctb30m00008 using g_documento.succod
                                ,g_documento.aplnumdig
                                ,g_documento.itmnumdig
                                ,g_funapol.dctnumseq
         whenever error continue
         fetch cctb30m00008 into m_segnumdig
         whenever error stop
         if sqlca.sqlcode <> 0   and
            sqlca.sqlcode <> 100 then
            let mr_ret.errcod = sqlca.sqlcode
            let mr_ret.errdes = 'Problemas ao buscar Segurado. Sucursal: '
                               ,g_documento.succod,' Apolice: '
                               ,g_documento.aplnumdig,' Item: '
                               ,g_documento.itmnumdig,' Doc: '
                               ,g_funapol.dctnumseq

            close cctb30m00008
            return mr_ret.errcod
                  ,mr_ret.errdes
         end if

         close cctb30m00008

         #Busca o nome do segurado
         open cctb30m00010 using m_segnumdig
         whenever error continue
         fetch cctb30m00010 into m_segnom
         whenever error stop
         if sqlca.sqlcode <> 0 and
            sqlca.sqlcode <> 100 then
            let mr_ret.errcod = sqlca.sqlcode
             let mr_ret.errdes = 'Problemas ao buscar nome do Segurado. '
                                ,'Sucursal: '
                                ,g_documento.succod,' Apolice: '
                                ,g_documento.aplnumdig,' Item: '
                                ,g_documento.itmnumdig,' Doc: '
                                ,g_funapol.dctnumseq
             close cctb30m00010
             return mr_ret.errcod
                   ,mr_ret.errdes
         end if
         close cctb30m00010

         #Busca email do segurado para envio de email
         open cctb30m00009 using m_segnumdig
         whenever error continue
         fetch cctb30m00009 into m_maides
         whenever error stop
         if sqlca.sqlcode <> 0   and
            sqlca.sqlcode <> 100 then
            let mr_ret.errcod = sqlca.sqlcode
            let mr_ret.errdes = 'Problemas ao buscar email do Segurado. '
                               ,'Segurado: '
                               ,m_segnumdig

            close cctb30m00009
            return mr_ret.errcod
                  ,mr_ret.errdes
         end if
         close cctb30m00009

      when 35

         let m_chave  = 'EMAILALTDEST35'
         if g_documento.aplnumdig is not null and
               g_documento.itmnumdig is not null then
               let m_segnom =  lr_documento2.segnom
          else
               let m_segnom =  ''
          end if
         let m_maides =
             figrc011_xpath(lr_documento2.doc_handle,"/APOLICE/SEGURADO/EMAIL")
             call figrc011_fim_parse()

      when 43
         let m_chave  = 'EMAILALTDEST43'
         let m_segnom =  null
         let m_maides =  null

      when 84
         let m_chave  = 'EMAILALTDEST84'
         let m_segnom =  g_doc_itau[1].segnom
         let m_maides =  null

   end case

   #Carregar nome segurado nulo com nome cliente do laudo
   if m_segnom is null or m_segnom = "" then
      let m_segnom = m_nomlaudo
   end if

   call figrc009_mail_open()                # 10.08.12 Kurihara lote email ini
        returning mr_ret.errcod, mr_ret.errdes
   if mr_ret.errcod <> 0 then
      error mr_ret.errdes sleep 2
      call figrc009_mail_close()
      return mr_ret.errcod
            ,mr_ret.errdes
   end if                                   # 10.08.12 Kurihara lote email fim
      
   #Se a origem do servico for 4 5 6 ou 7 envia email
   if m_atdsrvorg = 4 or
      m_atdsrvorg = 5 or
      m_atdsrvorg = 6 or
      m_atdsrvorg = 7 then
      
      #Aciona funcao para enviar email a empresa
      call ctb30m00_empresa()
      if mr_ret.errcod <> 0 then
         error mr_ret.errdes sleep 2
         call figrc009_mail_close()        # 10.08.12 Kurihara lote email
         return mr_ret.errcod
               ,mr_ret.errdes
      end if
      
      #Aciona funcao para enviar email ao cliente
      if m_empcod <> 43 and      --> Empresa Porto Servico
         m_empcod <> 84 then     --> Empresa Itau
         call ctb30m00_cliente()
         if mr_ret.errcod <> 0 then
            error mr_ret.errdes sleep 2
            call figrc009_mail_close()        # 10.08.12 Kurihara lote email
            return mr_ret.errcod
                  ,mr_ret.errdes
         end if
      end if
      
   end if
      
   call figrc009_mail_close()               # 10.08.12 Kurihara lote email


   
   initialize mr_ret to null

   #Se a origem do servico for 4 5 ou 7 envia sms ao cliente
   if m_atdsrvorg = 4 or
      m_atdsrvorg = 5 or
      m_atdsrvorg = 7 then
      call ctb30m00_sms()
      if mr_ret.errcod <> 0 then
         error mr_ret.errdes sleep 2
         return mr_ret.errcod
               ,mr_ret.errdes
      end if
   end if

   #Envia QRU ao prestador
   call ctb30m00_qru()
   if mr_ret.errcod <> 0 then
      error mr_ret.errdes sleep 2
      return mr_ret.errcod
            ,mr_ret.errdes
   end if

   let mr_ret.errcod = true
   let mr_ret.errdes = ''

   return mr_ret.errcod
         ,mr_ret.errdes

end function

#Funcao responsavel por enviar email com as alteracoes efetuadas a empresa
#------------------------------------------------------------------------------#
function ctb30m00_empresa()
#------------------------------------------------------------------------------#
   define lr_mail   record
          rem       char(50)
         ,des       char(250)
         ,ccp       char(250)
         ,cco       char(250)
         ,ass       char(150)
         ,msg       char(3000)
         ,idr       char(20)
         ,tip       char(4)
   end record

   define l_email   char(60)
         ,l_hora    datetime hour to minute
         ,l_data    date

   initialize mr_ret, lr_mail, l_email to null

   case m_empcod
      when 1
         let m_ciaempnom = "Porto Seguro"
      when 35                            
         let m_ciaempnom = "Azul Seguros"
      when 43                            
         let m_ciaempnom = "Porto Seguro Faz"
      when 84                           
         let m_ciaempnom = "Itau Seguro"
   end case


   #Monta texto do email
   let mr_ret.errcod =  0
   let lr_mail.rem   = "porto.socorro@portoseguro.com.br"
   let lr_mail.ccp   = ""
   let lr_mail.cco   = ""
   let lr_mail.ass   = "Alteracao endereco de destino - ",
                       "Servico: ", 
                       m_atdsrvorg using "<&&", "/",
                       mr_de.atdsrvnum using "<<<<<<<<<&", 
                       "-", mr_de.atdsrvano using "<&",
                       " - ", m_ciaempnom	clipped		
   let lr_mail.idr   =  g_issk.funmat clipped
   let lr_mail.tip   = "html"
   let l_data        =  today
   let l_hora        =  current

   #Seleciona emails cadastrados de acordo com a chave
   open cctb30m00002 using m_chave
   foreach cctb30m00002 into l_email
      if lr_mail.des is null then
         let lr_mail.des = l_email clipped
      else
         let lr_mail.des = lr_mail.des clipped
                          ,',',l_email clipped
      end if
   end foreach

   #display "EMAIL EMPRESA: ", lr_mail.des sleep 3

   let lr_mail.msg = "<html>"
                        ,"<body>"
                           ,"<table>"
                               ,"<tr>"
                                   ,"<td ><font>"
                                    ,m_nome
                                   ,"</td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>","Sucursal: "
                                                 ,g_documento.succod clipped
                                                 ," - "
                                                 ," Ap&oacute;lice: "
                                                 ,g_documento.aplnumdig
                                   ,"</td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>",m_segnom clipped
                                   ,"</td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Alterado destino em: ",l_data
                                               , "  As: ",l_hora
                                               ,"  Por: ",g_issk.funnom clipped
                                   ,"</td>"
                               ,"</tr>"
                           ,"</table>"
                           ,"<br>"
                           ,"<table >"
                               ,"<tr>"
                                  ,"<td ><font> Servi&ccedil;o.: ",
                                       m_atdsrvorg using "<&&", "/",
                                       mr_de.atdsrvnum using "<<<<<<<<<&", 
                                       "-", mr_de.atdsrvano using "<&",
                                       " - ", m_ciaempnom	clipped		
                                   ,"</td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Problema.: ",m_c24pbmdes
                                   ,"</td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Tipo Assist&ecirc;ncia: "
                                               ,m_asitipdes
                                   ,"</td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Dist&acirc;ncia.: "
                                                ,m_qthqti clipped, " Kms"
                                   ,"</td>"
                               ,"</tr>"
                           ,"</table>"
                           ,"<br>"
                           ,"<table >"
                               ,"<tr>"
                                   ,"<td ><font>DE: </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>CEP Local: ",mr_de.lgdcep
                                   ," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Cidade: "
                                          ,mr_de.cidnom clipped," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>UF: ",mr_de.ufdcod," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Tipo Logradouro: "
                                          ,mr_de.lgdtip clipped," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Logradouro: "
                                          ,mr_de.lgdnom clipped," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Numero: ",mr_de.lgdnum," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Bairro: ",mr_de.brrnom clipped
                                          ," </td>"
                               ,"</tr>"
                           ,"</table>"
                           ,"<br>"
                           ,"<table >"
                               ,"<tr>"
                                   ,"<td ><font>PARA: </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>CEP Local: "
                                               ,mr_para.lgdcep," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Cidade: "
                                               ,mr_para.cidnom clipped," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>UF: ",mr_para.ufdcod," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Tipo Logradouro: "
                                         ,mr_para.lgdtip clipped," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Logradouro: "
                                         ,mr_para.lgdnom clipped," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Numero: "
                                         ,mr_para.lgdnum," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Bairro: "
                                         ,mr_para.brrnom clipped," </td>"
                               ,"</tr>"
                           ,"</table>"
                   ,"</boby></html>"

   let mr_ret.errcod = 0

    #display "email:", lr_mail.msg sleep 10

   #Envia email
   call figrc009_mail_send (lr_mail.rem       # 10.08.12 Kurihara lote email
                           ,lr_mail.des
                           ,lr_mail.ccp
                           ,lr_mail.cco
                           ,lr_mail.ass
                           ,lr_mail.msg
                           ,lr_mail.idr
                           ,lr_mail.tip)
   returning mr_ret.errcod
            ,mr_ret.errdes

     #display "erro cod:", mr_ret.errcod, mr_ret.errdes sleep 3

   if mr_ret.errcod <> 0 then
      let mr_ret.errdes = 'Erro no envio de e-mail para o colaborador: '
                          ,lr_mail.des clipped
   else
      let mr_ret.errdes = 'E-mail enviado com SUCESSO!'
   end if

end function    #ctb30m00_empresa

#Funcao responsavel por enviar email com as alteracoes efetuadas ao cliente
#------------------------------------------------------------------------------#
function ctb30m00_cliente()
#------------------------------------------------------------------------------#
   define lr_mail   record
          rem       char(50)
         ,des       char(250)
         ,ccp       char(250)
         ,cco       char(250)
         ,ass       char(150)
         ,msg       char(3000)
         ,idr       char(20)
         ,tip       char(4)
   end record

   define l_email   char(60)
         ,l_hora    datetime hour to minute
         ,l_data    date

   initialize mr_ret, lr_mail, l_email to null

   case m_empcod
      when 1
         let m_ciaempnom = "Porto Seguro"
      when 35                            
         let m_ciaempnom = "Azul Seguros"
      when 43                            
         let m_ciaempnom = "Porto Seguro Faz"
      when 84                           
         let m_ciaempnom = "Itau Seguro"
   end case
	  	       

   #Monta texto do email
   let mr_ret.errcod =  0
   let lr_mail.rem   = "central.deoperacoes@portoseguro.com.br"
   let lr_mail.ccp   = ""
   let lr_mail.cco   = ""
   let lr_mail.ass   = "Alteracao endereco de destino - ",
                       "Servico: ", 
                       m_atdsrvorg using "<&&", "/",
                       mr_de.atdsrvnum using "<<<<<<<<<&", 
                       "-", mr_de.atdsrvano using "<&",
                       " - ", m_ciaempnom	clipped				                       
   let lr_mail.idr   =  g_issk.funmat clipped
   let lr_mail.tip   = "html"
   let l_data        =  today
   let l_hora        =  current
   let lr_mail.des   =  m_maides clipped

   #display "EMAIL CLIENTE: ", m_maides sleep 3

   let lr_mail.msg   = "<html>"
                        ,"<body>"
                           ,"<table>"
                               ,"<tr>"
                                   ,"<td ><font>"
                                    ,m_nome clipped," - Sucursal: "
                                    ,g_documento.succod clipped ," - "
                                   ," Ap&oacute;lice: ",g_documento.aplnumdig
                                   ,"</td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>",m_segnom clipped
                                   ,"</td>"
                               ,"</tr>"
                           ,"</table>"
                           ,"<br>"
                           ,"<table >"
                               ,"<tr>"
                                  ,"<td ><font> Servi&ccedil;o.: ",
                                       m_atdsrvorg using "<&&", "/",
                                       mr_de.atdsrvnum using "<<<<<<<<<&", 
                                       "-", mr_de.atdsrvano using "<&",
                                       " - ", m_ciaempnom	clipped		
                                   ,"</td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Problema.: ",m_c24pbmdes
                                   ,"</td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Tipo Assist&ecirc;ncia: "
                                               ,m_asitipdes
                                   ,"</td>"
                               ,"</tr>"
                           ,"</table>"
                           ,"<br>"
                           ,"<table >"
                               ,"<tr>"
                                   ,"<td ><font>Alterado destino em: ",l_data
                                  , "  &agrave;s: ",l_hora
                                   #,"  Por: ",g_issk.funnom clipped
                                   ,"</td>"
                               ,"</tr>"
                           ,"</table>"
                           ,"<br>"
                           ,"<table >"
                               ,"<tr>"
                                   ,"<td ><font>DE: </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>CEP Local: ",mr_de.lgdcep
                                   ," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Cidade: ",mr_de.cidnom clipped
                                   ," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>UF: ",mr_de.ufdcod," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Tipo Logradouro: "
                                   ,mr_de.lgdtip clipped," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Logradouro: "
                                   ,mr_de.lgdnom clipped," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Numero: ",mr_de.lgdnum," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Bairro: ",mr_de.brrnom clipped
                                   ," </td>"
                               ,"</tr>"
                           ,"</table>"
                           ,"<br>"
                           ,"<table >"
                               ,"<tr>"
                                   ,"<td ><font>PARA: </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>CEP Local: ",mr_para.lgdcep
                                   ," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Cidade: "
                                   ,mr_para.cidnom clipped," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>UF: ",mr_para.ufdcod," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Tipo Logradouro: "
                                   ,mr_para.lgdtip clipped," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Logradouro: "
                                   ,mr_para.lgdnom clipped," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Numero: ",mr_para.lgdnum
                                   ," </td>"
                               ,"</tr>"
                               ,"<tr>"
                                   ,"<td ><font>Bairro: "
                                   ,mr_para.brrnom clipped," </td>"
                               ,"</tr>"
                           ,"</table>"
                      ,"</boby></html>"

   let mr_ret.errcod = 0

   #Envia email
   call figrc009_mail_send (lr_mail.rem    # 10.08.12 Kurihara lote email
                           ,lr_mail.des
                           ,lr_mail.ccp
                           ,lr_mail.cco
                           ,lr_mail.ass
                           ,lr_mail.msg
                           ,lr_mail.idr
                           ,lr_mail.tip)
   returning mr_ret.errcod
            ,mr_ret.errdes

   if mr_ret.errcod <> 0 then
      let mr_ret.errdes = 'Erro no envio de e-mail para o colaborador: '
                          ,lr_mail.des clipped
   else
      let mr_ret.errdes = 'E-mail enviado com SUCESSO!'
   end if

end function    #ctb30m00_cliente

#Funcao responsavel por enviar um SMS ao segurado com status do atendimento
#------------------------------------------------------------------------------#
function ctb30m00_sms()
#------------------------------------------------------------------------------#
   define lr_sms         record
          smsenvcod      like dbsmenvmsgsms.smsenvcod
         ,msgtxt         like dbsmenvmsgsms.msgtxt
         ,incdat         like dbsmenvmsgsms.incdat
         ,envstt         like dbsmenvmsgsms.envstt
   end record

   define l_atdsrvnum    char(10)
         ,l_sissgl       like pccmcorsms.sissgl
         ,l_prioridade   smallint
         ,l_expiracao    integer

   initialize mr_ret
             ,lr_sms
             ,l_atdsrvnum
             ,l_prioridade
             ,l_expiracao    to null

   let mr_ret.errcod = 0
   let l_atdsrvnum = mr_de.atdsrvnum

   let lr_sms.smsenvcod = 'S',l_atdsrvnum clipped,mr_de.atdsrvano clipped

   if m_empcod = 01 or
      m_empcod = 35 then
      let lr_sms.msgtxt = m_nome[1,12]
   else
      let lr_sms.msgtxt = m_nome[1,10]
   end if

   let lr_sms.msgtxt = lr_sms.msgtxt clipped,
                      ', inf: o destino do veiculo foi alterado p/ ',
                       mr_para.lgdtip[1,7] clipped, ': ',
                       mr_para.lgdnom[1,27] clipped, ' - Bairro: ',
                       mr_para.brrnom[1,15] clipped, ' - Cidade: ',
                       mr_para.cidnom[1,15] clipped

   let lr_sms.incdat = current
   let lr_sms.envstt = 'A'

   let l_sissgl     = "PSocorro"
   let l_prioridade = figrc007_prioridade_alta()
   let l_expiracao  = figrc007_expiracao_1h()

   call figrc007_sms_send1 (m_dddcod
                           ,m_lcltelnum
                           ,lr_sms.msgtxt
                           ,l_sissgl
                           ,l_prioridade
                           ,l_expiracao)
   returning mr_ret.errcod
            ,mr_ret.errdes

   #display 	'SMS : ', mr_ret.errcod
    #        ,mr_ret.errdes sleep 3

   if mr_ret.errcod <> 0 then

      let mr_ret.errdes = 'Erro ao incluir dados do SMS!'

      return
   end if

end function          #ctb30m00_sms

#Funcao responsavel por enviar o QRU
#------------------------------------------------------------------------------#
function ctb30m00_qru()
#------------------------------------------------------------------------------#

   define lr_qti        record
          lclidttxt     like datmlcl.lclidttxt
         ,lgdtxt        char (65)
         ,brrnom        like datmlcl.brrnom
         ,endzon        like datmlcl.endzon
         ,cidnom        like datmlcl.cidnom
         ,ufdcod        like datmlcl.ufdcod
         ,lclrefptotxt  like datmlcl.lclrefptotxt
         ,dddcod        like datmlcl.dddcod
         ,lcltelnum     like datmlcl.lcltelnum
         ,lclcttnom     like datmlcl.lclcttnom
   end record

   define l_socvclcod   like dattfrotalocal.socvclcod      #Cod veiculo
         ,l_resultado   char(1)
         ,l_hora        datetime hour to minute
         ,l_data        date
         ,l_nom         like datmservico.nom               #Nome
         ,l_dddcod      like gsakend.dddcod
         ,l_teltxt      like gsakend.teltxt
         ,l_vcldes      like datmservico.vcldes            #Desc. Veiculo
         ,l_vclcorcod   like datmservico.vclcorcod         #Cod. Cor Veiculo
         ,l_vclcordes   char (20)                          #Desc. da Cor
         ,l_vclanomdl   like datmservico.vclanomdl         #Ano/Modelo
         ,l_vcllicnum   like datmservico.vcllicnum         #Licenca Veiculo
         ,l_texto       char(200)
         ,l_mensagem    char(500)
         ,l_rmcacpflg   char(1)                            #Acompanhante (S/N)
         ,l_acomp       char(3)                            #Acompanhante
         ,l_confirma    char (01)

   initialize mr_ret
             ,lr_qti
             ,l_socvclcod
             ,l_resultado
             ,l_hora
             ,l_data
             ,l_nom
             ,l_dddcod
             ,l_teltxt
             ,l_vcldes
             ,l_vclcorcod
             ,l_vclcordes
             ,l_vclanomdl
             ,l_vcllicnum
             ,l_texto
             ,l_mensagem
             ,l_rmcacpflg
             ,l_acomp       to null

   let mr_ret.errcod = 0

   #Busca cod do veiculo de socorro
   open cctb30m00004 using mr_de.atdsrvnum
                          ,mr_de.atdsrvano
   whenever error continue
   fetch cctb30m00004 into l_socvclcod
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let mr_ret.errcod = sqlca.sqlcode
      if sqlca.sqlcode = 100 then
         let mr_ret.errdes = ''
         let mr_ret.errcod = 0
      else
          call cts08g01("A","N","*** ENDEREÇO DE DESTINO ALTERADO ***"
                   ," ","HOUVE UM ERRO NO ENVIO DA QRU"
                   ,"FAVOR TRANSMITIR A MENSAGEM VIA VOZ")
          returning l_confirma

         let mr_ret.errdes = 'Erro ao verificar andamento do atendimento Ano: '
                            ,mr_de.atdsrvano,' e Servico: '
                            ,mr_de.atdsrvnum
      end if

      close cctb30m00004
      return
   end if

   close cctb30m00004

   open cctb30m00013 using mr_de.atdsrvnum
                          ,mr_de.atdsrvano
   whenever error continue
   fetch cctb30m00013 into l_rmcacpflg
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let mr_ret.errcod = sqlca.sqlcode
      if sqlca.sqlcode = 100 then
         let l_rmcacpflg = 'N'
      else
         let mr_ret.errdes = 'Erro ao verificar andamento do atendimento Ano: '
                            ,mr_de.atdsrvano,' e Servico: '
                            ,mr_de.atdsrvnum
         close cctb30m00013
         return
      end if
   end if

   close cctb30m00013

   case l_rmcacpflg
      when 'S'
         let l_acomp = 'SIM'
      otherwise
         let l_acomp = 'NAO'
   end case

   #Busca dados do Local
   call ctx04g00_local_reduzido(mr_de.atdsrvnum
                               ,mr_de.atdsrvano,2) #QTI
   returning lr_qti.*, l_resultado

   #Busca dados do veiculo
   open cctb30m00006 using mr_de.atdsrvnum
                          ,mr_de.atdsrvano
   whenever error continue
   fetch cctb30m00006 into l_vclanomdl
                         ,l_vcllicnum
                         ,l_vcldes
                         ,l_nom
                         ,l_vclcorcod
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let mr_ret.errcod = sqlca.sqlcode
      if sqlca.sqlcode = 100 then
         let mr_ret.errdes = ''
         let mr_ret.errcod = 0
      else
         let mr_ret.errdes = 'Erro ao consultar dados do veiculo. Ano: '
                            ,mr_de.atdsrvano,' e Servico: '
                            ,mr_de.atdsrvnum
      end if

      close cctb30m00006
      return
   end if

   close cctb30m00006

   #Busca descricao da cor do veiculo
   open cctb30m00007 using l_vclcorcod
   whenever error continue
   fetch cctb30m00007 into l_vclcordes
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let mr_ret.errcod = sqlca.sqlcode
      if sqlca.sqlcode = 100 then
         let l_vclcordes = 'NAO INFORMADO'
      else
         let mr_ret.errdes = 'Erro ao verificar a cor do veiculo Cod: '
                            ,l_vclcorcod

         close cctb30m00007
         return
      end if
   end if

   close cctb30m00007

   #Monta o Texto do QRU
   let l_data = today
   let l_hora = current

   let l_texto = 'ATENCAO: ALTERACAO DE DESTINO DA QRU ',
                  m_nome clipped, '. ALTERACAO DE QTI ***Ramo:531-AUTOMOVEIS '

   let l_mensagem = l_texto clipped
                   ," QRU: ", m_atdsrvorg using "&&"
                        ,"/", mr_de.atdsrvnum using "&&&&&&&"
                        ,"-", mr_de.atdsrvano using "&&"
                   ," QTR: ", l_data, " ", l_hora
                   ," QNC: ", l_nom             clipped, " "
                            , l_vcldes          clipped, " "
                            , l_vclanomdl       clipped, " "
                   ," QNR: ", l_vcllicnum       clipped, " "
                            , l_vclcordes       clipped, " "
                   ," QTI: ", lr_qti.lclidttxt  clipped, " - "
                            , lr_qti.lgdtxt     clipped, " - "
                            , lr_qti.brrnom     clipped, " - "
                            , lr_qti.cidnom     clipped, " - "
                            , lr_qti.ufdcod     clipped, " "
                   ," Ref: ", m_lclrefptotxt    clipped, " "
                  ," Resp: ", m_lclcttnom       clipped, " "
                  ," Tel: (", m_dddcod          clipped, ") "
                            , m_lcltelnum       clipped, " "
                 ," Acomp: ", l_acomp           clipped, "#"

   #Envia QRU
   call cts00g02_env_msg_mdt(1
                            ,""
                            ,""
                            ,l_mensagem
                            ,l_socvclcod)

   returning mr_ret.errdes

   if mr_ret.errdes = 'S' then
      call cts08g01("A","N","*** ENDEREÇO DE DESTINO ALTERADO ***"
                   ," ","HOUVE UM ERRO NO ENVIO DA QRU"
                   ,"FAVOR TRANSMITIR A MENSAGEM VIA VOZ")
     returning l_confirma
   else
      call cts08g01("A","N","*** ENDEREÇO DE DESTINO ALTERADO ***"
                   ," ","QRU ENVIADA AUTOMATICAMENTE ","")
     returning l_confirma
   end if

   let mr_ret.errdes = ''

end function       #ctb30m00_qru

#------------------------------------------------------------------------------#
function ctb30m00_permite_alt_end_dst (lr_param)
#------------------------------------------------------------------------------#

   define lr_param      record
          atdsrvano     like dbsmopgitm.atdsrvano
         ,atdsrvnum     like dbsmopgitm.atdsrvnum
   end record

   define lr_ret        record
          socopgnum     like dbsmopg.socopgnum
         ,socopgsitcod  like dbsmopg.socopgsitcod
         ,sttop         smallint
         ,errcod        smallint
         ,errdes        char(150)
   end record

   initialize lr_ret to null

   call ctb30m00_prepare()

   let lr_ret.sttop = false
   let lr_ret.errcod = 0

   open cctb30m00014 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
   whenever error continue
   fetch cctb30m00014 into lr_ret.socopgnum
                          ,lr_ret.socopgsitcod
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = 100 then
         let lr_ret.sttop = false
         let lr_ret.errdes = 'Nenhuma OP encontrada para este Ano : '
                            ,lr_param.atdsrvano,' e Servico : '
                            ,lr_param.atdsrvnum
      else
         let lr_ret.errcod = sqlca.sqlcode
         let lr_ret.errdes = 'Erro ao consultar situacao da OP com Ano : '
                            ,lr_param.atdsrvano,' e Servico : '
                            ,lr_param.atdsrvnum
      end if
   else
      let lr_ret.sttop = true
   end if

   close cctb30m00014

   return lr_ret.sttop
         ,lr_ret.errcod
         ,lr_ret.errdes

end function
